CREATE PROGRAM cp_add_cfa_obj_name:dba
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
 EXECUTE dm_ocd_upd_atr_col "APP", "1336000", "object_name",
 "ChartFormatAudit.Application"
 IF ((readme_data->status="F"))
  GO TO exit_program
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "1336000", "application_ini_ind",
 "1"
 IF ((readme_data->status="F"))
  GO TO exit_program
 ENDIF
 EXECUTE dm_ocd_upd_atr_col "APP", "1336000", "direct_access_ind",
 "1"
 IF ((readme_data->status="F"))
  GO TO exit_program
 ENDIF
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
END GO
