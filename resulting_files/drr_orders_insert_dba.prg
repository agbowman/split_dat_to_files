CREATE PROGRAM drr_orders_insert:dba
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
 SET readme_data->message = "Readme failed: DRR_ORDERS_PKG"
 EXECUTE drr_load_cust_sql "DELETE", "DRR_ORDERS_PKG.DRR_ORDERS_DEL_PROT_MISMATCH", 0,
 1
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE drr_load_cust_sql "RESTRICT", "DRR_ORDERS_PKG.DRR_ORDERS_DEL_PROT_MISMATCH", 0,
 1
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme inserted DRR_ORDERS_PKG into drr_load_cust_sql."
#exit_script
 CALL echorecord(readme_data)
END GO
