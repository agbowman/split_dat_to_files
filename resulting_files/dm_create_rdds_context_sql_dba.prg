CREATE PROGRAM dm_create_rdds_context_sql:dba
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
 FREE RECORD dm_error
 RECORD dm_error(
   1 message = vc
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure.  Starting dm_create_rdds_context_sql script."
 IF (currdb="ORACLE")
  EXECUTE dm_readme_include_sql "cer_install:dm_parse_str.sql"
  EXECUTE dm_readme_include_sql "cer_install:dm_refchg_breakup_str.sql"
  IF (error(dm_error->message,1) != 0)
   SET dm_sql_reply->msg = concat("FAIL:",dm_error->message)
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql "cer_install:dm_refchg_num_to_ccl.sql"
  IF (error(dm_error->message,1) != 0)
   SET dm_sql_reply->msg = concat("FAIL:",dm_error->message)
   GO TO exit_script
  ENDIF
 ELSE
  SET dm_sql_reply->status = "S"
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dm_parse_str", "procedure"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dm_refchg_breakup_str", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 IF (error(dm_error->message,1) != 0)
  SET dm_sql_reply->msg = concat("FAIL:",dm_error->message)
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dm_refchg_num_to_ccl", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 IF (error(dm_error->message,1) != 0)
  SET dm_sql_reply->msg = concat("FAIL:",dm_error->message)
 ENDIF
#exit_script
 IF ((dm_sql_reply->status > ""))
  SET readme_data->status = dm_sql_reply->status
 ENDIF
 IF ((readme_data->status="F"))
  SET readme_data->message = dm_sql_reply->msg
 ELSE
  SET readme_data->message = concat(
   "SUCCESS: DM_PARSE_STR procedure, DM_REFCHG_BREAKUP_STR function, and ",
   "DM_REFCHG_NUM_TO_CCL function created on ORACLE databases")
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
