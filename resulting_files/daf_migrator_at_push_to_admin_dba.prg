CREATE PROGRAM daf_migrator_at_push_to_admin:dba
 RECORD reply(
   1 message = vc
   1 bad_list[*]
     2 script_name = vc
     2 script_group = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 DECLARE dmapta_ccl_exists_ind = i2 WITH public, noconstant(0)
 DECLARE dmapta_cso_exists_ind = i2 WITH public, noconstant(0)
 IF (((size(request->info_domain,1)=0) OR (((size(request->info_name,1)=0) OR (size(request->
  cidb_env_name,1)=0)) )) )
  SET reply->status_data.status = "F"
  SET reply->message = "Request structure contains no DM_INFO data."
  GO TO exit_script
 ENDIF
 IF (size(request->obj_list,5)=0)
  SET reply->status_data.status = "F"
  SET reply->message = "Request structure contains no script data."
  GO TO exit_script
 ENDIF
 DECLARE dmapta_user_name = vc WITH public, noconstant(" ")
 DECLARE dmapta_source_name = vc WITH public, noconstant(" ")
 DECLARE dmapta_compile_dt_tm = dq8 WITH public
 DECLARE dmapta_bad_list = i4 WITH public, noconstant(0)
 DECLARE dmapta_hide_updt_task = i4 WITH public, constant(- (2321))
 DECLARE dmapta_true_updt_task = i4 WITH public, constant(3202004)
 DECLARE dmapta_env_id = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   dmapta_env_id = di.info_number
  WITH nocounter
 ;end select
 IF (dmapta_env_id=0.0)
  SET reply->status_data.status = "F"
  SET reply->message = "No DM_INFO environment ID was found."
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_adm_csm_script_info dacsi
  SET dacsi.updt_task = dmapta_hide_updt_task
  WHERE dacsi.dm_adm_csm_script_info_id > 0
   AND dacsi.environment_id=dmapta_env_id
  WITH nocounter
 ;end update
 FOR (i = 1 TO value(size(request->obj_list,5)))
   SET dmapta_ccl_exists_ind = 0
   SET dmapta_cso_exists_ind = 0
   CALL echo(build2("Processing ",request->obj_list[i].script_name,":",request->obj_list[i].
     script_group))
   SELECT INTO "nl:"
    dp.user_name, dp.source_name, dp.datestamp,
    dp.timestamp
    FROM dprotect dp
    WHERE dp.object IN ("P", "E")
     AND dp.object_name=cnvtupper(request->obj_list[i].script_name)
     AND (dp.group=request->obj_list[i].script_group)
    DETAIL
     dmapta_ccl_exists_ind = 1, dmapta_user_name = dp.user_name, dmapta_source_name = dp.source_name,
     dmapta_compile_dt_tm = cnvtdatetime(dp.datestamp,dp.timestamp)
    WITH nocounter
   ;end select
   IF (dmapta_ccl_exists_ind=1)
    CALL echo("The CCL record exists...")
    SELECT INTO "nl:"
     cso.object_name
     FROM ccl_synch_objects cso
     WHERE cso.object_name=cnvtupper(request->obj_list[i].script_name)
      AND (cso.cclgroup=request->obj_list[i].script_group)
     DETAIL
      dmapta_cso_exists_ind = 1
     WITH nocounter
    ;end select
    IF (dmapta_cso_exists_ind=1)
     CALL echo("delete from dm_adm_ccl_synch_objects...")
     DELETE  FROM dm_adm_ccl_synch_objects dacso
      WHERE dacso.object_name=cnvtupper(request->obj_list[i].script_name)
       AND (dacso.cclgroup=request->obj_list[i].script_group)
      WITH nocounter
     ;end delete
     SET errcode = error(errmsg,1)
     IF (errcode != 0)
      ROLLBACK
      SET reply->status_data.status = "F"
      SET reply->message = concat("Unable to purge dm_adm_csm_script_info: ",errmsg)
      GO TO fail_rollback
     ENDIF
     CALL echo("Inserting the rows into dm_adm_ccl_synch_objects...")
     INSERT  FROM dm_adm_ccl_synch_objects
      (dm_adm_ccl_synch_objects_id, environment_id, object_name,
      object_type, cclgroup, rcode,
      qual, timestamp_dt_tm, node_name,
      dir_name, major_version, minor_version,
      endian_platform, checksum, dic_key0,
      dic_key1, dic_data0, dic_data1,
      updt_applctx, updt_cnt, updt_dt_tm,
      updt_id, updt_task)(SELECT
       seq(dm_seq,nextval), dmapta_env_id, cso.object_name,
       cso.object_type, cso.cclgroup, cso.rcode,
       cso.qual, cso.timestamp_dt_tm, cso.node_name,
       cso.dir_name, cso.major_version, cso.minor_version,
       cso.endian_platform, cso.checksum, cso.dic_key0,
       cso.dic_key1, cso.dic_data0, cso.dic_data1,
       cso.updt_applctx, cso.updt_cnt, cso.updt_dt_tm,
       cso.updt_id, cso.updt_task
       FROM ccl_synch_objects cso
       WHERE cso.object_name=cnvtupper(request->obj_list[i].script_name)
        AND (cso.cclgroup=request->obj_list[i].script_group))
      WITH nocounter
     ;end insert
     SET errcode = error(errmsg,1)
     IF (errcode != 0)
      ROLLBACK
      SET reply->status_data.status = "F"
      SET reply->message = concat("Unable to write to dm_csm_script_info: ",errmsg)
      GO TO fail_rollback
     ENDIF
     CALL echo("Inserting into dm_adm_csm_script_info...")
     INSERT  FROM dm_adm_csm_script_info dacsi
      SET dacsi.dm_adm_csm_script_info_id = seq(dm_seq,nextval), dacsi.environment_id = dmapta_env_id,
       dacsi.script_name = cnvtupper(request->obj_list[i].script_name),
       dacsi.script_group = request->obj_list[i].script_group, dacsi.source_name = dmapta_source_name,
       dacsi.user_name = dmapta_user_name,
       dacsi.compile_dt_tm = cnvtdatetime(dmapta_compile_dt_tm), dacsi.updt_applctx = reqinfo->
       updt_applctx, dacsi.updt_cnt = 0,
       dacsi.updt_dt_tm = cnvtdatetime(curdate,curtime3), dacsi.updt_id = reqinfo->updt_id, dacsi
       .updt_task = dmapta_true_updt_task
      WITH nocounter
     ;end insert
     SET errcode = error(errmsg,1)
     IF (errcode != 0)
      ROLLBACK
      SET reply->status_data.status = "F"
      SET reply->message = concat("Unable to write to dm_csm_script_info: ",errmsg)
      GO TO fail_rollback
     ENDIF
     COMMIT
    ELSE
     CALL echo("No CSO row, add to bad list...")
     SET dmapta_bad_list = (dmapta_bad_list+ 1)
     SET stat = alterlist(reply->bad_list,dmapta_bad_list)
     SET reply->bad_list[dmapta_bad_list].script_name = request->obj_list[i].script_name
     SET reply->bad_list[dmapta_bad_list].script_group = request->obj_list[i].script_group
    ENDIF
   ELSE
    CALL echo("No CCL row, add to bad list...")
    SET dmapta_bad_list = (dmapta_bad_list+ 1)
    SET stat = alterlist(reply->bad_list,dmapta_bad_list)
    SET reply->bad_list[dmapta_bad_list].script_name = request->obj_list[i].script_name
    SET reply->bad_list[dmapta_bad_list].script_group = request->obj_list[i].script_group
   ENDIF
 ENDFOR
 CALL echo("Purging the original DM2_ADMIN_DM_INFO row...")
 DELETE  FROM dm2_admin_dm_info dadi
  WHERE (dadi.info_domain=request->info_domain)
   AND (dadi.info_name=request->info_name)
   AND dadi.info_long_id=dmapta_env_id
  WITH nocounter
 ;end delete
 DECLARE dmapta_platform_flag = i4 WITH public, noconstant(- (1))
 IF (cursys2="AIX")
  SET dmapta_platform_flag = 2
 ELSEIF (cursys2="VMS")
  SET dmapta_platform_flag = 3
 ELSEIF (cursys2="HPX")
  SET dmapta_platform_flag = 4
 ELSEIF (cursys2="LNX")
  SET dmapta_platform_flag = 5
 ENDIF
 CALL echo("Inserting into DM2_ADMIN_DM_INFO...")
 INSERT  FROM dm2_admin_dm_info dadi
  SET dadi.info_domain = request->info_domain, dadi.info_name = request->info_name, dadi.info_char =
   request->cidb_env_name,
   dadi.info_number = dmapta_platform_flag, dadi.info_long_id = dmapta_env_id, dadi.info_date =
   cnvtdatetime(curdate,curtime3),
   dadi.updt_applctx = reqinfo->updt_applctx, dadi.updt_cnt = 0, dadi.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   dadi.updt_id = reqinfo->updt_id, dadi.updt_task = reqinfo->updt_task
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to write to DM_INFO row: ",errmsg)
  GO TO fail_rollback
 ENDIF
 CALL echo("Deleting the old DACSI rows...")
 DELETE  FROM dm_adm_csm_script_info dacsi
  WHERE dacsi.environment_id=dmapta_env_id
   AND dacsi.updt_task=dmapta_hide_updt_task
  WITH nocounter
 ;end delete
 COMMIT
 SET reply->status_data.status = "S"
 SET reply->message = "Scripts were staged successfully."
 GO TO exit_script
#fail_rollback
 DELETE  FROM dm_adm_csm_script_info dacsi
  WHERE dacsi.environment_id=dmapta_env_id
   AND (dacsi.updt_task=reqinfo->updt_task)
  WITH nocounter
 ;end delete
 UPDATE  FROM dm_adm_csm_script_info dacsi
  SET dacsi.updt_task = dmapta_true_updt_task
  WHERE dacsi.environment_id=dmapta_env_id
   AND dacsi.updt_task=dmapta_hide_updt_task
  WITH nocounter
 ;end update
 COMMIT
#exit_script
END GO
