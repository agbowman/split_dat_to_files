CREATE PROGRAM br_run_pos_desc:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_run_pos_desc.prg> script"
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
 DELETE  FROM br_long_text b
  WHERE b.parent_entity_name="CODE_VALUE"
   AND (b.parent_entity_id=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_value=b.parent_entity_id
    AND cv.code_set=88))
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_long_text: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (language_log IN ("EN_AU", "EN_CD", "EN_US"))
  EXECUTE dm_dbimport "cer_install:ps_pos_desc.csv", "br_pos_desc_config", 5000
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_pos_desc_config.prg> script"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
