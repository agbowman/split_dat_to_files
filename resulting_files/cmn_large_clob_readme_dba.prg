CREATE PROGRAM cmn_large_clob_readme:dba
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
 SET readme_data->message = "Readme Failed: Starting cmn_large_clob_readme script."
 EXECUTE cmn_create_cnfg_clob_gttd
 IF ((readme_data->status="F"))
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg = readme_data->message
  GO TO exit_script
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: Begin procedure creation."
 ENDIF
 EXECUTE dm_readme_include_sql "cer_install:cmn_plsql_regexp_match.sql"
 EXECUTE dm_readme_include_sql_chk "cmn_plsql_regexp_match", "procedure"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql "cer_install:cmn_plsql_regexp_replace.sql"
 EXECUTE dm_readme_include_sql_chk "cmn_plsql_regexp_replace", "procedure"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
#exit_script
 SET readme_data->status = dm_sql_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = dm_sql_reply->msg
 ELSE
  SET readme_data->message = "All PL/SQL FUNCTIONS exist in database."
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
