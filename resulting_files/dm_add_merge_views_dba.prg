CREATE PROGRAM dm_add_merge_views:dba
 SET c_mod = "DM_ADD_MERGE_VIEWS 000"
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
  GO TO end_of_program
 ENDIF
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 EXECUTE dm_readme_include_sql "cer_install:dm_merge_views.sql"
 SET readme_data->status = "F"
 SET readme_data->message = " "
 EXECUTE dm_readme_include_sql_chk "bill_item_view_cv_cv", "view"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "README FAILED. View 'bill_item_view_cv_cv' is not created."
  GO TO end_of_program
 ELSEIF ((dm_sql_reply->status="S"))
  EXECUTE oragen3 "bill_item_view_cv_cv"
 ENDIF
 EXECUTE dm_readme_include_sql_chk "bill_item_view_ot_cv", "view"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "README FAILED. View 'bill_item_view_ot_cv'is not created."
  GO TO end_of_program
 ELSEIF ((dm_sql_reply->status="S"))
  EXECUTE oragen3 "bill_item_view_ot_cv"
 ENDIF
 EXECUTE dm_readme_include_sql_chk "bill_item_view_cv_n", "view"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "README FAILED. View 'bill_item_view_cv_n'is not created."
  GO TO end_of_program
 ELSEIF ((dm_sql_reply->status="S"))
  EXECUTE oragen3 "bill_item_view_cv_n"
 ENDIF
 EXECUTE dm_readme_include_sql_chk "bill_item_view_cv_ot", "view"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "README FAILED. View 'bill_item_view_cv_ot'is not created."
  GO TO end_of_program
 ELSEIF ((dm_sql_reply->status="S"))
  EXECUTE oragen3 "bill_item_view_cv_ot"
 ENDIF
 EXECUTE dm_readme_include_sql_chk "bill_item_view_cv_na", "view"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "README FAILED. View 'bill_item_view_cv_na'is not created."
  GO TO end_of_program
 ELSEIF ((dm_sql_reply->status="S"))
  EXECUTE oragen3 "bill_item_view_cv_na"
 ENDIF
 EXECUTE dm_readme_include_sql_chk "bill_item_view_na_cv", "view"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "README FAILED. View 'bill_item_view_na_cv'is not created."
  GO TO end_of_program
 ELSEIF ((dm_sql_reply->status="S"))
  EXECUTE oragen3 "bill_item_view_na_cv"
 ENDIF
 EXECUTE dm_readme_include_sql_chk "bill_item_view_ot_na", "view"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "README FAILED. View 'bill_item_view_ot_na'is not created."
  GO TO end_of_program
 ELSEIF ((dm_sql_reply->status="S"))
  EXECUTE oragen3 "bill_item_view_ot_na"
 ENDIF
 EXECUTE dm_readme_include_sql_chk "bill_item_view_na_ot", "view"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "README FAILED. View 'bill_item_view_na_ot'is not created."
  GO TO end_of_program
 ELSEIF ((dm_sql_reply->status="S"))
  EXECUTE oragen3 "bill_item_view_na_ot"
 ENDIF
 EXECUTE dm_readme_include_sql_chk "bill_item_view_bi_na", "view"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "README FAILED. View 'bill_item_view_bi_na'is not created."
  GO TO end_of_program
 ELSEIF ((dm_sql_reply->status="S"))
  EXECUTE oragen3 "bill_item_view_bi_na"
 ENDIF
 EXECUTE dm_readme_include_sql_chk "v500_event_CODE_VIEW", "view"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "README FAILED. View 'v500_event_CODE_VIEW'is not created."
  GO TO end_of_program
 ELSEIF ((dm_sql_reply->status="S"))
  EXECUTE oragen3 "v500_event_CODE_VIEW"
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dm_merge_constraints_view", "view"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "README FAILED. View 'dm_merge_constraints_view'is not created."
  GO TO end_of_program
 ELSEIF ((dm_sql_reply->status="S"))
  EXECUTE oragen3 "dm_merge_constraints_view"
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "README SUCCESS.  All views are created."
#end_of_program
 EXECUTE dm_readme_status
END GO
