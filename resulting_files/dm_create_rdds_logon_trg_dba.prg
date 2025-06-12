CREATE PROGRAM dm_create_rdds_logon_trg:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Fail: dm_rdds_logon trigger was not created"
 IF (currdb="ORACLE")
  EXECUTE dm_drop_obsolete_objects "DM_RDDS_LOGON", "TRIGGER", 1
  EXECUTE dm_readme_include_sql "cer_install:dm_rdds_logon_v500.sql"
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: dm_rdds_logon_v500 trigger not needed on this database"
  GO TO exit_script
 ENDIF
 SET readme_data->status = dm_sql_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dm_rdds_logon_v500", "trigger"
 SET readme_data->status = dm_sql_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "SUCCESS: trigger dm_rdds_logon_v500 was created"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
