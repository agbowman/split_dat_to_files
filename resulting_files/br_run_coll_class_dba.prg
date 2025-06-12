CREATE PROGRAM br_run_coll_class:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_run_coll_class.prg> script"
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
 IF (language_log IN ("EN_AU", "EN_CD", "EN_US"))
  EXECUTE dm_dbimport "cer_install:br_coll_class.csv", "br_coll_class_config", 1000
 ELSE
  SELECT INTO "NL:"
   FROM br_name_value b
   WHERE b.br_nv_key1="DEL_BR_COLL_CLASS"
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM br_name_value b
    SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "DEL_BR_COLL_CLASS", b.br_value
      = " ",
     b.br_name = " ", b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed: Updating br_name_value for DEL_BR_COLL_CLASS:",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM br_coll_class
    WHERE collection_class > "   *"
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Deleting from br_coll_class: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
  IF (((language_log="ES_ES") OR (((language_log="SP_SP") OR (language_log="ES_SP")) )) )
   EXECUTE dm_dbimport "cer_install:br_coll_class_es.csv", "br_coll_class_config", 1000
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Readme Succeeded: <br_coll_class_config.prg> script"
  ENDIF
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
