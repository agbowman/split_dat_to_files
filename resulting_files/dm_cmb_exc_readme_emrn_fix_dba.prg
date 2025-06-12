CREATE PROGRAM dm_cmb_exc_readme_emrn_fix:dba
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
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Starting dm_cmb_custom_master_readme"
 EXECUTE dm_readme_status
 EXECUTE person_cmb_encntr_alias
 IF ((readme_data->status != "S"))
  GO TO exit_program
 ENDIF
 EXECUTE person_cmb_charge
 IF ((readme_data->status != "S"))
  GO TO exit_program
 ENDIF
 EXECUTE person_ucb_charge
 IF ((readme_data->status != "S"))
  GO TO exit_program
 ENDIF
 EXECUTE encntr_cmb_charge
 IF ((readme_data->status != "S"))
  GO TO exit_program
 ENDIF
 EXECUTE encntr_ucb_charge
 IF ((readme_data->status != "S"))
  GO TO exit_program
 ENDIF
 EXECUTE person_cmb_iclass_person_reltn
 IF ((readme_data->status != "S"))
  GO TO exit_program
 ENDIF
 EXECUTE person_ucb_encntr_alias
 IF ((readme_data->status != "S"))
  GO TO exit_program
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Starting dm_cmb_exception_maint for PERSON"
 SET stat = alterlist(dcem_request->qual,1)
 SET dcem_request->qual[1].parent_entity = "PERSON"
 SET dcem_request->qual[1].child_entity = "CHARGE_MOD"
 SET dcem_request->qual[1].op_type = "UNCOMBINE"
 SET dcem_request->qual[1].script_name = "NONE"
 SET dcem_request->qual[1].single_encntr_ind = 0
 SET dcem_request->qual[1].script_run_order = 0
 SET dcem_request->qual[1].del_chg_id_ind = 0
 SET dcem_request->qual[1].delete_row_ind = 0
 EXECUTE dm_cmb_exception_maint
 IF ((dcem_reply->status != "S"))
  SET readme_data->status = "F"
  SET readme_data->message = dcem_reply->err_msg
  GO TO exit_program
 ELSE
  SET readme_data->status = dcem_reply->status
 ENDIF
 SET stat = alterlist(dcem_request->qual,0)
 SET readme_data->status = "F"
 SET readme_data->message = "Starting dm_cmb_exception_maint for ENCOUNTER"
 SET stat = alterlist(dcem_request->qual,1)
 SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
 SET dcem_request->qual[1].child_entity = "CHARGE_MOD"
 SET dcem_request->qual[1].op_type = "UNCOMBINE"
 SET dcem_request->qual[1].script_name = "NONE"
 SET dcem_request->qual[1].single_encntr_ind = 0
 SET dcem_request->qual[1].script_run_order = 0
 SET dcem_request->qual[1].del_chg_id_ind = 0
 SET dcem_request->qual[1].delete_row_ind = 0
 EXECUTE dm_cmb_exception_maint
 IF ((dcem_reply->status != "S"))
  SET readme_data->status = "F"
  SET readme_data->message = dcem_reply->err_msg
  GO TO exit_program
 ELSE
  SET readme_data->status = dcem_reply->status
 ENDIF
 SET readme_data->message = "maintaining dm_cmb_exception table successfully"
#exit_program
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
