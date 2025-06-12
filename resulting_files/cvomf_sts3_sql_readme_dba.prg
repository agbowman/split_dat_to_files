CREATE PROGRAM cvomf_sts3_sql_readme:dba
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
 SET readme_data->message = "Readme Failed: Starting cvomf_sts3_sql_readme.prg script"
 IF (currdb="ORACLE")
  EXECUTE dm_readme_include_sql "cer_install:cvnet_omf_sts3_functions.sql"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cvomf_case_nom_st", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cvomf_case_nom_id", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cvomf_case_rst_vl", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cvomf_cabs_rst_it", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cvomf_cabs_rst_fs", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cvomf_cprc_nom_st", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cvomf_cprc_nom_id", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cvomf_cprc_rst_vl", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cvomf_cpbs_rst_it", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cvomf_crst_dat_st", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cvomf_case_h_m_st", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cv_get_cv_cnt_data", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
#exit_script
 SET readme_data->status = dm_sql_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = dm_sql_reply->msg
 ELSE
  SET readme_data->message = "All CVNET PL/SQL FUNCTIONS exist in database."
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 SET script_version = "MOD 001 BM9013 09/30/05"
END GO
