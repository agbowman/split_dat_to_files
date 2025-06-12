CREATE PROGRAM dm_create_v500_read_user_chk:dba
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
 IF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto Success on DB2 sites"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dba_users
  WHERE username="V500_READ"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->message = "Readme Failed.  V500_READ user NOT created successfully."
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SET readme_data->message = "Readme Succeeded.  V500_READ user created successfully."
 SET readme_data->status = "S"
#exit_script
 EXECUTE dm_readme_status
END GO
