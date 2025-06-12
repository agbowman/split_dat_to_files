CREATE PROGRAM dm_combine_srv_call:dba
 DECLARE numparam = i4 WITH protect, noconstant(1)
 DECLARE dcscpar = vc WITH protect, noconstant(" ")
 DECLARE dscsparambreak = i4 WITH protect, noconstant(0)
 DECLARE dm_cmb_app_id = i4 WITH protect
 DECLARE dm_cmb_task_id = i4 WITH protect
 DECLARE dm_cmb_parent = vc WITH protect
 DECLARE dm_cmb_from_id = f8 WITH protect
 DECLARE dm_cmb_to_id = f8 WITH protect
 DECLARE dm_cmb_encntr_id = f8 WITH protect
 DECLARE dm_cmb_request_id = i4 WITH protect, constant(100102)
 DECLARE dm_cmb_tdb_status = i4 WITH protect
 DECLARE error_cnt = i4 WITH protect
 DECLARE error_cnt2 = i4 WITH protect
 DECLARE dcsc_reply_cnt = i4 WITH protect
 DECLARE dcsc_reply2_cnt = i4 WITH protect
 DECLARE dcsc_error_message = vc WITH protect, noconstant(" ")
 RECORD dcsc_request(
   1 parent_table = c50
   1 cmb_mode = c20
   1 error_message = c132
   1 transaction_type = c8
   1 xxx_combine[*]
     2 xxx_combine_id = f8
     2 from_xxx_id = f8
     2 from_mrn = c200
     2 from_alias_pool_cd = f8
     2 from_alias_type_cd = f8
     2 to_xxx_id = f8
     2 to_mrn = c200
     2 to_alias_pool_cd = f8
     2 to_alias_type_cd = f8
     2 encntr_id = f8
     2 application_flag = i2
     2 combine_weight = f8
     2 comment_txt = c250
   1 xxx_combine_det[*]
     2 xxx_combine_det_id = f8
     2 xxx_combine_id = f8
     2 entity_name = c32
     2 entity_id = f8
     2 entity_pk[*]
       3 col_name = c30
       3 data_type = c30
       3 data_char = c100
       3 data_number = f8
       3 data_date = dq8
     2 combine_action_cd = f8
     2 attribute_name = c32
     2 prev_active_ind = i2
     2 prev_active_status_cd = f8
     2 prev_end_eff_dt_tm = dq8
     2 combine_desc_cd = f8
     2 to_record_ind = i2
   1 reverse_cmb_ind = i2
 )
 RECORD dcsc_reply(
   1 xxx_combine_id[*]
     2 combine_id = f8
     2 parent_table = c50
     2 from_xxx_id = f8
     2 to_xxx_id = f8
     2 encntr_id = f8
   1 error[*]
     2 create_dt_tm = dq8
     2 parent_table = c50
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
     2 error_table = c32
     2 error_type = vc
     2 error_msg = vc
     2 combine_error_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 WHILE (dscsparambreak=0)
  SET dcscpar = reflect(parameter(numparam,0))
  IF (dcscpar > " ")
   SET numparam += 1
  ELSE
   SET dscsparambreak = 1
   SET numparam -= 1
  ENDIF
 ENDWHILE
 IF (((numparam > 4) OR (numparam < 4)) )
  SET dcsc_error_message =
  "This program prompts 4 parameters parent table, from id, to id and encntr id (for encounter move)"
  GO TO end_script
 ENDIF
 IF (((reflect(parameter(2,0)) != "I*"
  AND reflect(parameter(2,0)) != "F*") OR (((reflect(parameter(3,0)) != "I*"
  AND reflect(parameter(3,0)) != "F*") OR (reflect(parameter(4,0)) != "I*"
  AND reflect(parameter(4,0)) != "F*")) )) )
  SET dcsc_error_message = "Input ID values must be numeric"
  GO TO end_script
 ENDIF
 SET dcscpar = parameter(1,0)
 SET dm_cmb_parent = substring(1,1,cnvtupper(dcscpar))
 SET dm_cmb_from_id = parameter(2,0)
 SET dm_cmb_to_id = parameter(3,0)
 SET dm_cmb_encntr_id = parameter(4,0)
 IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
  IF ((xxcclseclogin->loggedin != 1))
   SET dcsc_error_message = concat(
    "In order to perform the combine, you are required to be logged in securely",
    " to the Millennium database")
   GO TO end_script
  ENDIF
 ENDIF
 IF (((dm_cmb_from_id=0.0) OR (dm_cmb_to_id=0.0)) )
  SET dcsc_error_message = "Input FROM_ID and TO_ID values must be greater than 0.0"
  GO TO end_script
 ENDIF
 CASE (dm_cmb_parent)
  OF "P":
   SET dm_cmb_parent = "PERSON"
   SET dm_cmb_app_id = 70000
   SET dm_cmb_task_id = 70000
  OF "E":
   SET dm_cmb_parent = "ENCOUNTER"
   SET dm_cmb_app_id = 70000
   SET dm_cmb_task_id = 70000
   IF (dm_cmb_encntr_id > 0)
    SET dcsc_error_message = "Encntr id must be 0 for Encounter Combine"
    GO TO end_script
   ENDIF
  OF "L":
   SET dm_cmb_parent = "LOCATION"
   SET dm_cmb_app_id = 33000
   SET dm_cmb_task_id = 33002
   IF (dm_cmb_encntr_id > 0)
    SET dcsc_error_message = "Encntr id must be 0 for Location Combine"
    GO TO end_script
   ENDIF
  OF "H":
   SET dm_cmb_parent = "HEALTH_PLAN"
   SET dm_cmb_app_id = 5555
   SET dm_cmb_task_id = 5555
   IF (dm_cmb_encntr_id > 0)
    SET dcsc_error_message = "Encntr id must be 0 for Health Plan Combine"
    GO TO end_script
   ENDIF
  OF "O":
   SET dm_cmb_parent = "ORGANIZATION"
   SET dm_cmb_app_id = 18000
   SET dm_cmb_task_id = 18003
   IF (dm_cmb_encntr_id > 0)
    SET dcsc_error_message = "Encntr id must be 0 for Organization Combine"
    GO TO end_script
   ENDIF
  ELSE
   SET dcsc_error_message =
   "Combine type must be (P)erson, (E)ncounter, (O)rganization, (L)ocation or (H)ealth_Plan"
   GO TO end_script
 ENDCASE
 IF ((validate(cmb_test_updt_task,- (1)) != - (1)))
  SET reqinfo->updt_task = cmb_test_updt_task
 ENDIF
 SET error_cnt = 0
 SET error_cnt2 = 0
 SET dcsc_reply_cnt = 0
 SET dcsc_reply2_cnt = 0
 IF ((validate(dm_test_revcmb_ind,- (1)) != - (1)))
  SET dcsc_request->reverse_cmb_ind = dm_test_revcmb_ind
 ENDIF
 SET dm_cmb_tdb_status = alterlist(dcsc_request->xxx_combine,1)
 SET dcsc_request->parent_table = dm_cmb_parent
 SET dcsc_request->cmb_mode = "COMBINE"
 SET dcsc_request->transaction_type = curuser
 SET dcsc_request->xxx_combine[1].from_xxx_id = dm_cmb_from_id
 SET dcsc_request->xxx_combine[1].to_xxx_id = dm_cmb_to_id
 SET dcsc_request->xxx_combine[1].encntr_id = dm_cmb_encntr_id
 SET dcsc_request->xxx_combine[1].application_flag = 5
 SET dm_cmb_tdb_status = tdbexecute(dm_cmb_app_id,dm_cmb_task_id,dm_cmb_request_id,"REC",dcsc_request,
  "REC",dcsc_reply,4)
 SET dcsc_reply_cnt = size(dcsc_reply->xxx_combine_id,5)
 IF (dcsc_reply_cnt > 0)
  CALL echo(".")
  CALL echo(concat("Status        =  ",dcsc_reply->status_data.status))
  CALL echo(".")
 ENDIF
 FOR (dm_t_a = 1 TO dcsc_reply_cnt)
   CALL echo(".")
   CALL echo(concat("Combine_id    =  ",build(format(dcsc_reply->xxx_combine_id[dm_t_a].combine_id,
       "##########;l"))))
   CALL echo(concat("Parent table  =  ",dcsc_reply->xxx_combine_id[dm_t_a].parent_table))
   CALL echo(concat("From id       =  ",build(format(dcsc_reply->xxx_combine_id[dm_t_a].from_xxx_id,
       "##########;l"))))
   CALL echo(concat("To id         =  ",build(format(dcsc_reply->xxx_combine_id[dm_t_a].to_xxx_id,
       "##########;l"))))
   CALL echo(concat("Encntr id     =  ",build(format(dcsc_reply->xxx_combine_id[dm_t_a].encntr_id,
       "##########;l"))))
 ENDFOR
 IF (dm_cmb_tdb_status=1)
  SET dcsc_error_message =
  "An error occurred when attempting to call the Combine Service through TDBEXECUTE"
 ENDIF
 FOR (dm_t_b = 1 TO size(dcsc_reply->error,5))
   CALL echo(".")
   CALL echo(concat("Error ID      =  ",build(format(dcsc_reply->error[dm_t_b].combine_error_id,
       "##########;l"))))
   CALL echo(concat("Error from_id =  ",build(format(dcsc_reply->error[dm_t_b].from_id,"##########;l"
       ))))
   CALL echo(concat("Error to_id   =  ",build(format(dcsc_reply->error[dm_t_b].to_id,"##########;l"))
     ))
   CALL echo(concat("Error msg     =  ",dcsc_reply->error[dm_t_b].error_msg))
   CALL echo(concat("Error table   =  ",dcsc_reply->error[dm_t_b].error_table))
   CALL echo(concat("Error type    =  ",dcsc_reply->error[dm_t_b].error_type))
   CALL echo(".")
   CALL echo(concat("Status        =  ",dcsc_reply->status_data.status))
   CALL echo(".")
 ENDFOR
#end_script
 IF (dcsc_error_message > " ")
  CALL echo(".")
  CALL echo(concat("Combine type = ",build(parameter(1,0))))
  CALL echo(concat("From id =  ",build(parameter(2,0))))
  CALL echo(concat("To id   =  ",build(parameter(3,0))))
  CALL echo(concat("Encntr id = ",build(parameter(4,0))))
  CALL echo(".")
  CALL echo(".")
  CALL echo(dcsc_error_message)
  CALL echo(".")
 ENDIF
END GO
