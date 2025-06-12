CREATE PROGRAM dm_cmb_exc_readme_enc_pend:dba
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
 SET readme_data->message = "Starting dm_cmb_custom_master_readme"
 EXECUTE encntr_cmb_encntr_pending
 IF ((readme_data->status != "S"))
  GO TO exit_program
 ENDIF
 EXECUTE encntr_cmb_encntr_pending_hist
 IF ((readme_data->status != "S"))
  GO TO exit_program
 ENDIF
 SET readme_data->message = "maintaining dm_cmb_exception table successfully"
#exit_program
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
