CREATE PROGRAM ca_data_drr_load_cust_extsvc:dba
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
 SET readme_data->message = "Readme failed: starting script ca_data_drr_load_cust_extsvc.prg..."
 EXECUTE drr_load_cust_extsvc "CA_DATA_RECORD_RETENTION", "RESTRICT", "EXTCCL",
 "CA_DATA_RECORD_RETENTION", 1
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE drr_load_cust_extsvc "CA_DATA_RECORD_RETENTION", "UNRESTRICT", "EXTCCL",
 "CA_DATA_RECORD_RETENTION", 1
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE drr_load_cust_extsvc "CA_DATA_RECORD_RETENTION", "DELETE", "EXTCCL",
 "CA_DATA_RECORD_RETENTION", 1
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
