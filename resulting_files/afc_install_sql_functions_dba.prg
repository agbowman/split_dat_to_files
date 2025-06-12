CREATE PROGRAM afc_install_sql_functions:dba
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
 IF (currdb="ORACLE")
  EXECUTE dm_readme_include_sql "cer_install:afc_functions.sql"
  EXECUTE dm_readme_include_sql_chk "afc_get_age", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
 ELSEIF (currdb="DB2UDB")
  EXECUTE dm_readme_include_sql "cer_install:afc_functions_db2.sql"
  EXECUTE dm_readme_include_sql_chk "afc_get_age", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (currdb="ORACLE")
  EXECUTE dm_readme_include_sql "cer_install:afc_functions.sql"
  EXECUTE dm_readme_include_sql_chk "afc_get_cs_wlage_group", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
 ELSEIF (currdb="DB2UDB")
  EXECUTE dm_readme_include_sql "cer_install:afc_functions_db2.sql"
  EXECUTE dm_readme_include_sql_chk "afc_get_cs_wlagegp", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (currdb="ORACLE")
  EXECUTE dm_readme_include_sql "cer_install:afc_functions.sql"
  EXECUTE dm_readme_include_sql_chk "afc_get_cs_wlage_days_group", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
 ELSEIF (currdb="DB2UDB")
  EXECUTE dm_readme_include_sql "cer_install:afc_functions_db2.sql"
  EXECUTE dm_readme_include_sql_chk "afc_get_cs_wdaysgp", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET readme_data->status = dm_sql_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = dm_sql_reply->msg
 ELSE
  SET readme_data->message = "All objects exist in database."
 ENDIF
 EXECUTE dm_readme_status
END GO
