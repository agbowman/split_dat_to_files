CREATE PROGRAM daf_migrator_stage_apptier:dba
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
 IF (validate(request->obj_list,"Z")="Z")
  FREE RECORD request
  RECORD request(
    1 info_domain = vc
    1 info_name = vc
    1 cidb_env_name = vc
    1 obj_list[*]
      2 script_name = vc
      2 script_group = i2
  )
 ENDIF
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
 DECLARE dmsa_user_name = vc WITH public, noconstant(" ")
 DECLARE dmsa_source_name = vc WITH public, noconstant(" ")
 DECLARE dmsa_compile_dt_tm = dq8 WITH public
 DECLARE dmsa_bad_list = i4 WITH public, noconstant(0)
 DECLARE dmsa_hide_updt_task = i4 WITH public, constant(- (2321))
 DECLARE dmsa_true_updt_task = i4 WITH public, constant(3202004)
 UPDATE  FROM dm_csm_script_info dcsi
  SET dcsi.updt_task = dmsa_hide_updt_task
  WHERE dcsi.dm_csm_script_info_id > 0
  WITH nocounter
 ;end update
 FOR (i = 1 TO value(size(request->obj_list,5)))
  SELECT INTO "nl:"
   dp.user_name, dp.source_name, dp.datestamp,
   dp.timestamp
   FROM dprotect dp
   WHERE dp.object="P"
    AND dp.object_name=cnvtupper(request->obj_list[i].script_name)
    AND (dp.group=request->obj_list[i].script_group)
   DETAIL
    dmsa_user_name = dp.user_name, dmsa_source_name = dp.source_name, dmsa_compile_dt_tm =
    cnvtdatetime(dp.datestamp,cnvttime2(format(dp.timestamp,"######;rp0"),"HHMMSS"))
   WITH nocounter
  ;end select
  IF (curqual != 0)
   INSERT  FROM dm_csm_script_info dcsi
    SET dcsi.dm_csm_script_info_id = seq(dm_ref_seq,nextval), dcsi.script_name = cnvtupper(request->
      obj_list[i].script_name), dcsi.script_group = request->obj_list[i].script_group,
     dcsi.user_name = dmsa_user_name, dcsi.source_name = dmsa_source_name, dcsi.compile_dt_tm =
     cnvtdatetime(dmsa_compile_dt_tm),
     dcsi.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcsi.updt_id = reqinfo->updt_id, dcsi
     .updt_task = reqinfo->updt_task,
     dcsi.updt_cnt = 0, dcsi.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to write to dm_csm_script_info:",errmsg)
    GO TO fail_rollback
   ENDIF
   EXECUTE ccl_dic_export_objects request->obj_list[i].script_name, request->obj_list[i].script_group,
   "Y"
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Error exporting ",request->obj_list[i].script_name,": ",errmsg)
    GO TO fail_rollback
   ENDIF
   SELECT INTO "nl:"
    cso.object_name
    FROM ccl_synch_objects cso
    WHERE cso.object_name=cnvtupper(request->obj_list[i].script_name)
     AND (cso.cclgroup=request->obj_list[i].script_group)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dmsa_bad_list = (dmsa_bad_list+ 1)
    SET stat = alterlist(reply->bad_list,dmsa_bad_list)
    SET reply->bad_list[dmsa_bad_list].script_name = request->obj_list[i].script_name
    SET reply->bad_list[dmsa_bad_list].script_group = request->obj_list[i].script_group
    DELETE  FROM dm_csm_script_info dcsi
     WHERE dcsi.script_name=cnvtupper(request->obj_list[i].script_name)
      AND (dcsi.script_group=request->obj_list[i].script_group)
      AND (dcsi.updt_id=reqinfo->updt_id)
      AND (dcsi.updt_task=reqinfo->updt_task)
      AND (dcsi.updt_applctx=reqinfo->updt_applctx)
     WITH nocounter
    ;end delete
    COMMIT
   ENDIF
  ENDIF
 ENDFOR
 DELETE  FROM dm_info di
  WHERE (di.info_domain=request->info_domain)
   AND (di.info_name=request->info_name)
  WITH nocounter
 ;end delete
 DECLARE dmsa_platform_flag = i4 WITH public, noconstant(- (1))
 IF (cursys2="AIX")
  SET dmsa_platform_flag = 2
 ELSEIF (cursys2="VMS")
  SET dmsa_platform_flag = 3
 ELSEIF (cursys2="HPX")
  SET dmsa_platform_flag = 4
 ELSEIF (cursys2="LNX")
  SET dmsa_platform_flag = 5
 ENDIF
 INSERT  FROM dm_info di
  SET di.info_domain = request->info_domain, di.info_name = request->info_name, di.info_char =
   request->cidb_env_name,
   di.info_number = dmsa_platform_flag, di.info_date = cnvtdatetime(curdate,curtime3), di
   .updt_applctx = reqinfo->updt_applctx,
   di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id,
   di.updt_task = reqinfo->updt_task
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to write to DM_INFO row:",errmsg)
  GO TO fail_rollback
 ENDIF
 DELETE  FROM dm_csm_script_info dcsi
  WHERE dcsi.updt_task=dmsa_hide_updt_task
  WITH nocounter
 ;end delete
 COMMIT
 SET reply->status_data.status = "S"
 SET reply->message = "Scripts were staged successfully."
 GO TO exit_script
#fail_rollback
 DELETE  FROM dm_csm_script_info dcsi
  WHERE (dcsi.updt_task=reqinfo->updt_task)
  WITH nocounter
 ;end delete
 UPDATE  FROM dm_csm_script_info dcsi
  SET dcsi.updt_task = dmsa_true_updt_task
  WHERE dcsi.updt_task=dmsa_hide_updt_task
  WITH nocounter
 ;end update
 COMMIT
#exit_script
END GO
