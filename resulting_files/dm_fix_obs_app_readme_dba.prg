CREATE PROGRAM dm_fix_obs_app_readme:dba
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
 EXECUTE dm_ocd_upd_atr_col "APP", "14100", "DIRECT_ACCESS_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "14300", "DIRECT_ACCESS_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "14700", "DIRECT_ACCESS_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "14800", "DIRECT_ACCESS_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "15200", "DIRECT_ACCESS_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "14100", "ACTIVE_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "14300", "ACTIVE_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "14700", "ACTIVE_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "14800", "ACTIVE_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "15200", "ACTIVE_IND",
 "0"
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
#exit_script
 EXECUTE dm_readme_status
END GO
