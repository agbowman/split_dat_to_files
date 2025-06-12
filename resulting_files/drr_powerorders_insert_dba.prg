CREATE PROGRAM drr_powerorders_insert:dba
 DECLARE program_version = vc WITH private, constant("001")
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: DRR_POWERORDERS_PKG"
 EXECUTE drr_load_cust_sql "RESTRICT", "DRR_POWERORDERS_PKG.DRR_IB_RX_REQ_ACTION_RES", 0,
 1
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme inserted DRR_POWERORDERS_PKG into drr_load_cust_sql."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
