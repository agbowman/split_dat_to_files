CREATE PROGRAM cv_omf_sql_readme:dba
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
  EXECUTE dm_readme_include_sql "cer_install:cv_omf_functions.sql"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_person_race_cd", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_person_dob_str", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_person_dob_dq8", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cp_proc_nomen_str", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cp_proc_nomen_id", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cp_proc_result_val", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cp_abstr_result_int", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_case_abstr_result_facts", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_proc_abstr_result_facts", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_les_abstr_result_facts", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_case_hh_mm_str", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_case_result_dt_tm_str", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_proc_result_dt_tm_str", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_les_result_dt_tm_str", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_case_result_dt_tm_q8", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_proc_result_dt_tm_q8", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_les_result_dt_tm_q8", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_case_nomen_id", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_proc_nomen_id", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_les_nomen_id", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_case_nomen_str", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_proc_nomen_str", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_les_nomen_str", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_case_result_val", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_proc_result_val", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_les_result_val", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_case_abstr_result_id", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_proc_abstr_result_id", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_case_abstr_result_int", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_proc_abstr_result_int", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_les_abstr_result_int", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_case_result_cd", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_proc_abstr_result_cd", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_count_data", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_cv_case_result_val3", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_case_result_dt_tm_str3", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
  EXECUTE dm_readme_include_sql_chk "cv_get_primary_insurance", "function"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET readme_data->status = dm_sql_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = dm_sql_reply->msg
 ELSE
  SET readme_data->message = "All CVNET PL/SQL FUNCTIONS exist in database."
 ENDIF
 EXECUTE dm_readme_status
 SET script_version = "MOD 002 BM9013 07/16/04"
END GO
