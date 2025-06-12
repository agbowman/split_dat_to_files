CREATE PROGRAM ecf_install_sql_pkg:dba
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
 SET readme_data->message = "Readme failure. Starting ecf_install_sql_pkg script"
 DECLARE smsg = c255
 EXECUTE dm_readme_include_sql "cer_install:ecf_db_locking_pkg.sql"
 CALL echorecord(dm_sql_reply)
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 SET smsg = "All functions from ecf_db_locking_pkg.sql exist in the database"
 EXECUTE dm_readme_include_sql_chk "ecf_db_locking_pkg", "PACKAGE"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "ecf_db_locking_pkg", "PACKAGE BODY"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
#exit_script
 SET readme_data->status = dm_sql_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = dm_sql_reply->msg
 ELSE
  SET readme_data->message = smsg
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
