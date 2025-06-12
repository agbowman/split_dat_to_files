CREATE PROGRAM dm_fix_ocd_upd_atr_col_80:dba
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
 EXECUTE dm_ocd_upd_atr_col "TASK", "3010000", "SUBORDINATE_TASK_IND",
 "1"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "TASK", "3070001", "SUBORDINATE_TASK_IND",
 "1"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "TASK", "3072000", "SUBORDINATE_TASK_IND",
 "1"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "TASK", "3010003", "SUBORDINATE_TASK_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "TASK", "3010001", "SUBORDINATE_TASK_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "TASK", "3010003", "DESCRIPTION",
 "RUN Expert Knowledge Modules"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "TASK", "3010001", "DESCRIPTION",
 "RUN Templates"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "REQ", "225803", "CACHETIME",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "REQ", "225804", "CACHETIME",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "REQ", "225805", "CACHETIME",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "REQ", "225806", "CACHETIME",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "REQ", "225807", "CACHETIME",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "REQ", "225815", "CACHETIME",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "REQ", "225825", "CACHETIME",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "REQ", "305605", "requestclass",
 "1"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "1336000", "object_name",
 "ChartFormatAudit.Application"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "1336000", "application_ini_ind",
 "1"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "1336000", "direct_access_ind",
 "1"
#exit_script
 EXECUTE dm_readme_status
END GO
