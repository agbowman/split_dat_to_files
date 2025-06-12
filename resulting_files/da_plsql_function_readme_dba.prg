CREATE PROGRAM da_plsql_function_readme:dba
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
 DECLARE smsg = c255
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure.  Starting da_plsql_function_readme script."
 IF (currdb="ORACLE")
  EXECUTE dm_readme_include_sql "cer_install:da_functions.sql"
  IF ((dm_sql_reply->status="F"))
   SET readme_data->message = dm_sql_reply->msg
   GO TO exit_script
  ENDIF
  SET smsg = "All functions from da_functions.sql exist in the database"
 ELSE
  SET readme_data->status = "S"
  SET smsg = concat("Readme skipping due to unsupported RDB platform: ",trim(currdb))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_quarter_begin", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_username", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_format_time", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_format_time_min", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_sched_last_tm", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_sched_occurs_string", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_report_name", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_prsnl_admin_access", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_group_admin_access", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_folder_name", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_table_name", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_table_alias_name", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "omf_get_cv_display", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_grid_display", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_grid_group_display", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_user_group_display", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_omf_folder_name", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_omf_sched_occurrence", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_omf_item_type", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_saved_view_name", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_reconcile_flag_desc", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da_get_prim_per_plan_reltn", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da2_birth_dttm", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da2_birth_dttm_str", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da2_deceased_dttm", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "da2_deceased_dttm_str", "function"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 SET readme_data->status = dm_sql_reply->status
#exit_script
 IF ((readme_data->status="S"))
  SET readme_data->message = smsg
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
