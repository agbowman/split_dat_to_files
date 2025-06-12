CREATE PROGRAM br_run_name_value:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_run_name_value.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET language_log = fillstring(5," ")
 SET language_log = cnvtupper(logical("CCL_LANG"))
 IF (language_log=" ")
  SET language_log = cnvtupper(logical("LANG"))
  IF (language_log IN (" ", "C"))
   SET language_log = "EN_US"
  ENDIF
 ENDIF
 DELETE  FROM br_name_value b
  WHERE b.br_nv_key1 IN ("APPLICATION_NAME", "FNTRKTAB", "ORCNOMIX", "STEP_CAT_MEAN")
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_name_value: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_name_value b
  WHERE cnvtupper(b.br_nv_key1)="CONTENT_OC"
   AND cnvtupper(b.br_value) IN ("CARDIOLOGY", "SURGERY")
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting br_name_value row: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_name_value b
  WHERE b.br_nv_key1="ELIGPROVSPECIALTY"
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting ELIGPROVSPECIALTY br_name_value rows: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_name_value b
  WHERE b.br_nv_key1="PERSON_SEARCH_CONVERSATION_FLAG"
   AND b.br_name IN ("200", "206", "208", "209", "800",
  "204", "500", "501", "902")
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme Failed: Deleting PERSON_SEARCH_CONVERSATION_FLAG br_name_value rows: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET br_name_value_id = 0.0
 SELECT INTO "NL:"
  FROM br_name_value b
  WHERE b.br_nv_key1="EDAREAROOMRELTN"
   AND b.br_name="2065"
  DETAIL
   br_name_value_id = b.br_name_value_id
  WITH nocounter
 ;end select
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Selecting 2065 from br_name_value: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (br_name_value_id > 0)
  SET upd_name_value_id = 0.0
  SELECT INTO "NL:"
   FROM br_name_value b
   WHERE b.br_nv_key1="EDCOAREA"
   DETAIL
    upd_name_value_id = b.br_name_value_id
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Selecting EDCOAREA from br_name_value: ",errmsg)
   GO TO exit_script
  ENDIF
  IF (upd_name_value_id > 0)
   UPDATE  FROM br_name_value b
    SET b.br_name = cnvtstring(upd_name_value_id), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
     .updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
     updt_applctx
    WHERE b.br_name_value_id=br_name_value_id
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Updating into br_name_value: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
 ENDIF
 SET br_name_value_id = 0.0
 SELECT INTO "NL:"
  FROM br_name_value b
  WHERE b.br_nv_key1="EDAREAROOMRELTN"
   AND b.br_name="2064"
  DETAIL
   br_name_value_id = b.br_name_value_id
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Selecting 2064 from br_name_value: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (br_name_value_id > 0)
  SET upd_name_value_id = 0.0
  SELECT INTO "NL:"
   FROM br_name_value b
   WHERE b.br_nv_key1="EDWAITAREA"
   DETAIL
    upd_name_value_id = b.br_name_value_id
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Selecting EDWAITAREA from br_name_value: ",
    errmsg)
   GO TO exit_script
  ENDIF
  IF (upd_name_value_id > 0)
   UPDATE  FROM br_name_value b
    SET b.br_name = cnvtstring(upd_name_value_id), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
     .updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
     updt_applctx
    WHERE b.br_name_value_id=br_name_value_id
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Updating into br_name_value: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
 ENDIF
 IF (language_log="EN*")
  EXECUTE dm_dbimport "cer_install:name_value.csv", "br_name_value_config", 5000
 ELSE
  EXECUTE dm_dbimport "cer_install:name_value_gen.csv", "br_name_value_config", 5000
 ENDIF
 IF ((readme_data->status != "F"))
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_name_value_config> script"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
