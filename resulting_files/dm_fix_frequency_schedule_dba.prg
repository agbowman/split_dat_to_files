CREATE PROGRAM dm_fix_frequency_schedule:dba
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
 DECLARE rdm_err_msg = c132
 SET rdm_err_msg = fillstring(132," ")
 SET readme_data->status = "F"
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   FROM user_triggers ut
   WHERE ut.trigger_name="TRG_0096_DR_UPDT_DEL*"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET readme_data->status = "S"
   SET readme_data->message = "Success: trigger is already in place."
   GO TO exit_script
  ENDIF
 ELSEIF (currdb="DB2UDB")
  SELECT INTO "nl:"
   FROM user_triggers ut
   WHERE ut.trigger_name IN ("TRG_0096_DRUPD*", "TRG_0096_DRDEL*")
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET readme_data->status = "S"
   SET readme_data->message = "Success: trigger is already in place."
   GO TO exit_script
  ENDIF
 ENDIF
 DELETE  FROM frequency_schedule fs
  WHERE fs.frequency_cd=0
  WITH nocounter
 ;end delete
 IF (error(rdm_err_msg,1) != 0)
  ROLLBACK
  SET readme_data->message = concat("Readme Failure: ",rdm_err_msg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM frequency_schedule fs
  WHERE fs.frequency_cd=0
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: zero rows successfully deleted from frequency_schedule table"
 ELSE
  SET readme_data->message = "Fail: zero rows are still present on the frequency_schedule table"
 ENDIF
 EXECUTE dm2_add_default_rows "frequency_schedule"
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
