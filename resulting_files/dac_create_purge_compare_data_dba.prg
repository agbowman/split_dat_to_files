CREATE PROGRAM dac_create_purge_compare_data:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE dcpcd_domain = vc WITH protect, noconstant("")
 DECLARE dcpcd_name = vc WITH protect, noconstant("")
 DECLARE dcpcd_flag1 = i2 WITH protect, noconstant(0)
 DECLARE dcpcd_flag2 = i2 WITH protect, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dac_create_purge_compare_data.prg..."
 SET dcpcd_domain = "DM PURGE"
 SET dcpcd_name = "PURGE HISTORY START"
 SELECT INTO "NL:"
  FROM dprotect d
  WHERE d.object="P"
   AND d.object_name="DM_PURGE_DATA_CHILD_BATCH"
  DETAIL
   dcpcd_flag1 = 1
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->message = concat("Failed during select from dprotect:",errmsg)
  GO TO exit_script
 ENDIF
 IF (dcpcd_flag1=0)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain=dcpcd_domain
    AND di.info_name=dcpcd_name
   DETAIL
    dcpcd_flag2 = 1
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed during select from DM_INFO:",errmsg)
   GO TO exit_script
  ENDIF
  IF (dcpcd_flag2=1)
   DELETE  FROM dm_info d
    WHERE d.info_domain=dcpcd_domain
     AND d.info_name=dcpcd_name
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->message = concat("Failed during delete from DM_INFO:",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
  INSERT  FROM dm_info di
   SET info_name = dcpcd_name, di.info_domain = dcpcd_domain, di.info_number = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_cnt = 0, di.updt_id = reqinfo->updt_id,
    di.updt_applctx = reqinfo->updt_applctx, di.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->message = concat("Failed during insert into DM_INFO:",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success: DM_PURGE_DATA_CHILD_BATCH already exists"
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql "cer_install:dm_preserve_purge_start_dt_tm.sql"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = "Failed during DM_README_INCLUDE_SQL execution"
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "DM_PRESERVE_PURGE_START_DT_TM", "TRIGGER"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = "Failed during DM_README_SQL_CHK execution"
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
