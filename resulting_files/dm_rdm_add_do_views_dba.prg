CREATE PROGRAM dm_rdm_add_do_views:dba
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
 SET readme_data->message = "Readme failed: starting script dm_rdm_add_do_views..."
 EXECUTE dm_readme_include_sql "cer_install:dm_rdm_add_do_views.sql"
 EXECUTE dm_readme_include_sql "cer_install:dm_rdm_add_do_views2.sql"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "DO_CODE_VALUE_VW", "VIEW"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE oragen3 "DO_CODE_VALUE_VW"
 EXECUTE dm_readme_include_sql_chk "DO_CODE_VALUE_CONCEPT_VW", "VIEW"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE oragen3 "DO_CODE_VALUE_CONCEPT_VW"
 EXECUTE dm_readme_include_sql_chk "DO_NOMENCLATURE_VW", "VIEW"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE oragen3 "DO_NOMENCLATURE_VW"
 EXECUTE dm_readme_include_sql_chk "DO_NOMENCLATURE_CONCEPT_VW", "VIEW"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE oragen3 "DO_NOMENCLATURE_CONCEPT_VW"
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
