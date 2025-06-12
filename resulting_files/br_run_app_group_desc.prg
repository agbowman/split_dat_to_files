CREATE PROGRAM br_run_app_group_desc
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
 SET readme_data->message = "Readme Failed: Starting <br_run_app_group_desc.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DELETE  FROM br_long_text b
  WHERE b.parent_entity_name="CODE_VALUE"
   AND (b.parent_entity_id=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_value=b.parent_entity_id
    AND cv.code_set=500))
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
 EXECUTE dm_dbimport "cer_install:ps_app_group_desc.csv", "br_app_group_desc_config", 5000
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
