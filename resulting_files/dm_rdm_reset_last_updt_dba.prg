CREATE PROGRAM dm_rdm_reset_last_updt:dba
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
 FREE RECORD rs_rrlu
 RECORD rs_rrlu(
   1 err_msg = c132
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting dm_rdm_reset_last_updt script."
 DECLARE cmb_lst_updt = c13
 SET cmb_lst_updt = "CMB_LAST_UPDT"
 EXECUTE dm_reset_cmb_last_updt cmb_lst_updt
 IF (error(rs_rrlu->err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = "ERROR: Execution of dm_reset_cmb_last_updt for CMB_LAST_UPDT failed."
  GO TO end_program
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = concat("SUCCESS: Execution of dm_reset_cmb_last_updt complete.")
#end_program
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE RECORD rs_rrlu
END GO
