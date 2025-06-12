CREATE PROGRAM dcp_rdm_add_inerr_modify_msg:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 message_key = vc
    1 category = vc
    1 subject = vc
    1 message = vc
    1 active_ind = i2
    1 beg_effective_dt_tm = dq8
    1 end_effective_dt_tm = dq8
    1 applications[*]
      2 app_number = i4
  )
 ENDIF
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
 SET readme_data->message = "Readme failure. dcp_rdm_add_inerr_modify_msg.prg script"
 SET request->message_key = "pvmar.dll_inerror_modify"
 SET request->category = "Order Management -- Bedside Care"
 SET request->subject = "eMAR"
 SET request->message = concat(
  "Users will no longer be able to modify uncharted results from the eMAR.")
 SET request->active_ind = 1
 SET stat = alterlist(request->applications,2)
 SET request->applications[1].app_number = 600005
 SET request->applications[2].app_number = 961000
 EXECUTE sys_add_user_notification
 CALL echorecord(readme_data)
END GO
