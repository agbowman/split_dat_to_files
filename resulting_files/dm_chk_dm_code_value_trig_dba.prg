CREATE PROGRAM dm_chk_dm_code_value_trig:dba
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
 SET readme_data->message = "Executing dm_code_value_trigger program."
 EXECUTE dm_readme_status
 EXECUTE dm_code_value_trigger
 SET readme_data->message =
 "Checking to see if TRG_CODE_VALUE_DELETE & TRG_CODE_VALUE_INS_UPDT are valid."
 EXECUTE dm_readme_status
 SELECT INTO "nl:"
  FROM dba_objects
  WHERE object_name IN ("TRG_CODE_VALUE_DELETE", "TRG_CODE_VALUE_INS_UPDT")
   AND status="VALID"
  WITH nocounter
 ;end select
 IF (curqual=2)
  SET readme_data->message = "Code Value triggers compiled successfully."
  SET readme_data->status = "S"
 ELSE
  SET readme_data->message = "Code Value triggers were NOT successfully compiled."
  SET readme_data->status = "F"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
END GO
