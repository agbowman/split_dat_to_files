CREATE PROGRAM afc_upt_charge_event_act:dba
 SET afc_upt_charge_event_act_vrsn = 000
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 charge_event_act_qual = i2
    1 charge_event_act[*]
      2 charge_event_act_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET action_begin = 1
  SET action_end = request->charge_event_act_qual
  SET reply->charge_event_act_qual = request->charge_event_act_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "CHARGE_EVENT_ACT"
 CALL upt_charge_event_act(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE upt_charge_event_act(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET count1 = 0
     SET active_status_code = 0
     UPDATE  FROM charge_event_act c
      SET c.charge_event_id = evaluate(validate(request->charge_event_act[x].charge_event_id,1.0),0.0,
        c.charge_event_id,- (1.0),0.0,
        validate(request->charge_event_act[x].charge_event_id,c.charge_event_id)), c.cea_type_cd =
       evaluate(validate(request->charge_event_act[x].cea_type_cd,1.0),0.0,c.cea_type_cd,- (1.0),0.0,
        validate(request->charge_event_act[x].cea_type_cd,c.cea_type_cd)), c.cea_prsnl_id = evaluate(
        validate(request->charge_event_act[x].cea_prsnl_id,1.0),0.0,c.cea_prsnl_id,- (1.0),0.0,
        validate(request->charge_event_act[x].cea_prsnl_id,c.cea_prsnl_id)),
       c.service_resource_cd = evaluate(validate(request->charge_event_act[x].service_resource_cd,1.0
         ),0.0,c.service_resource_cd,- (1.0),0.0,
        validate(request->charge_event_act[x].service_resource_cd,c.service_resource_cd)), c
       .service_dt_tm = evaluate(request->charge_event_act[x].service_dt_tm,0.0,c.service_dt_tm,
        blank_date,null,
        cnvtdatetime(request->charge_event_act[x].service_dt_tm)), c.charge_dt_tm = evaluate(request
        ->charge_event_act[x].charge_dt_tm,0.0,c.charge_dt_tm,blank_date,null,
        cnvtdatetime(request->charge_event_act[x].charge_dt_tm)),
       c.charge_type_cd = evaluate(validate(request->charge_event_act[x].charge_type_cd,1.0),0.0,c
        .charge_type_cd,- (1.0),0.0,
        validate(request->charge_event_act[x].charge_type_cd,c.charge_type_cd)), c
       .reference_range_factor_id = evaluate(validate(request->charge_event_act[x].
         reference_range_factor_id,1.0),0.0,c.reference_range_factor_id,- (1.0),0.0,
        validate(request->charge_event_act[x].reference_range_factor_id,c.reference_range_factor_id)),
       c.alpha_nomen_id = evaluate(validate(request->charge_event_act[x].alpha_nomen_id,1.0),0.0,c
        .alpha_nomen_id,- (1.0),0.0,
        validate(request->charge_event_act[x].alpha_nomen_id,c.alpha_nomen_id)),
       c.quantity = evaluate(validate(request->charge_event_act[x].quantity_ind,- (1)),0,c.quantity,1,
        validate(request->charge_event_act[x].quantity,0.0),
        c.quantity), c.units = evaluate(validate(request->charge_event_act[x].units,1),0,c.units,- (1
        ),0,
        validate(request->charge_event_act[x].units,c.units)), c.unit_type_cd = evaluate(validate(
         request->charge_event_act[x].unit_type_cd,1.0),0.0,c.unit_type_cd,- (1.0),0.0,
        validate(request->charge_event_act[x].unit_type_cd,c.unit_type_cd)),
       c.patient_loc_cd = evaluate(validate(request->charge_event_act[x].patient_loc_cd,1.0),0.0,c
        .patient_loc_cd,- (1.0),0.0,
        validate(request->charge_event_act[x].patient_loc_cd,c.patient_loc_cd)), c.service_loc_cd =
       evaluate(validate(request->charge_event_act[x].service_loc_cd,1.0),0.0,c.service_loc_cd,- (1.0
        ),0.0,
        validate(request->charge_event_act[x].service_loc_cd,c.service_loc_cd)), c.reason_cd =
       evaluate(validate(request->charge_event_act[x].reason_cd,1.0),0.0,c.reason_cd,- (1.0),0.0,
        validate(request->charge_event_act[x].reason_cd,c.reason_cd)),
       c.insert_dt_tm = evaluate(request->charge_event_act[x].insert_dt_tm,0.0,c.insert_dt_tm,
        blank_date,null,
        cnvtdatetime(request->charge_event_act[x].insert_dt_tm)), c.in_lab_dt_tm = evaluate(request->
        charge_event_act[x].in_lab_dt_tm,0.0,c.in_lab_dt_tm,blank_date,null,
        cnvtdatetime(request->charge_event_act[x].in_lab_dt_tm)), c.accession_id = evaluate(validate(
         request->charge_event_act[x].accession_id,1.0),0.0,c.accession_id,- (1.0),0.0,
        validate(request->charge_event_act[x].accession_id,c.accession_id)),
       c.repeat_ind = evaluate(validate(request->charge_event_act[x].repeat_ind_ind,- (1)),0,c
        .repeat_ind,1,validate(request->charge_event_act[x].repeat_ind,null),
        c.repeat_ind), c.result = evaluate(validate(request->charge_event_act[x].result,"Z")," ",c
        .result,"",null,
        validate(request->charge_event_act[x].result,c.result)), c.cea_misc1 = evaluate(validate(
         request->charge_event_act[x].cea_misc1,"Z")," ",c.cea_misc1,"",null,
        validate(request->charge_event_act[x].cea_misc1,c.cea_misc1)),
       c.cea_misc1_id = evaluate(validate(request->charge_event_act[x].cea_misc1_id,1.0),0.0,c
        .cea_misc1_id,- (1.0),0.0,
        validate(request->charge_event_act[x].cea_misc1_id,c.cea_misc1_id)), c.cea_misc2 = evaluate(
        validate(request->charge_event_act[x].cea_misc2,"Z")," ",c.cea_misc2,"",null,
        validate(request->charge_event_act[x].cea_misc2,c.cea_misc2)), c.cea_misc2_id = evaluate(
        validate(request->charge_event_act[x].cea_misc2_id,1.0),0.0,c.cea_misc2_id,- (1.0),0.0,
        validate(request->charge_event_act[x].cea_misc2_id,c.cea_misc2_id)),
       c.cea_misc3 = evaluate(validate(request->charge_event_act[x].cea_misc3,"Z")," ",c.cea_misc3,"",
        null,
        validate(request->charge_event_act[x].cea_misc3,c.cea_misc3)), c.cea_misc3_id = evaluate(
        validate(request->charge_event_act[x].cea_misc3_id,1.0),0.0,c.cea_misc3_id,- (1.0),0.0,
        validate(request->charge_event_act[x].cea_misc3_id,c.cea_misc3_id)), c.cea_misc4_id =
       evaluate(validate(request->charge_event_act[x].cea_misc4_id,1.0),0.0,c.cea_misc4_id,- (1.0),
        0.0,
        validate(request->charge_event_act[x].cea_misc4_id,c.cea_misc4_id)),
       c.srv_diag1_id = evaluate(validate(request->charge_event_act[x].srv_diag1_id,1.0),0.0,c
        .srv_diag1_id,- (1.0),0.0,
        validate(request->charge_event_act[x].srv_diag1_id,c.srv_diag1_id)), c.srv_diag2_id =
       evaluate(validate(request->charge_event_act[x].srv_diag2_id,1.0),0.0,c.srv_diag2_id,- (1.0),
        0.0,
        validate(request->charge_event_act[x].srv_diag2_id,c.srv_diag2_id)), c.srv_diag3_id =
       evaluate(validate(request->charge_event_act[x].srv_diag3_id,1.0),0.0,c.srv_diag3_id,- (1.0),
        0.0,
        validate(request->charge_event_act[x].srv_diag3_id,c.srv_diag3_id)),
       c.srv_diag4_id = evaluate(validate(request->charge_event_act[x].srv_diag4_id,1.0),0.0,c
        .srv_diag4_id,- (1.0),0.0,
        validate(request->charge_event_act[x].srv_diag4_id,c.srv_diag4_id)), c.srv_diag_cd = evaluate
       (validate(request->charge_event_act[x].srv_diag_cd,1.0),0.0,c.srv_diag_cd,- (1.0),0.0,
        validate(request->charge_event_act[x].srv_diag_cd,c.srv_diag_cd)), c.misc_ind = evaluate(
        validate(request->charge_event_act[x].misc_ind_ind,- (1)),0,c.misc_ind,1,validate(request->
         charge_event_act[x].misc_ind,null),
        c.misc_ind),
       c.cea_misc5_id = evaluate(validate(request->charge_event_act[x].cea_misc5_id,1.0),0.0,c
        .cea_misc5_id,- (1.0),0.0,
        validate(request->charge_event_act[x].cea_misc5_id,c.cea_misc5_id)), c.cea_misc6_id =
       evaluate(validate(request->charge_event_act[x].cea_misc6_id,1.0),0.0,c.cea_misc6_id,- (1.0),
        0.0,
        validate(request->charge_event_act[x].cea_misc6_id,c.cea_misc6_id)), c.cea_misc7_id =
       evaluate(validate(request->charge_event_act[x].cea_misc7_id,1.0),0.0,c.cea_misc7_id,- (1.0),
        0.0,
        validate(request->charge_event_act[x].cea_misc7_id,c.cea_misc7_id)),
       c.activity_dt_tm = evaluate(request->charge_event_act[x].activity_dt_tm,0.0,c.activity_dt_tm,
        blank_date,null,
        cnvtdatetime(request->charge_event_act[x].activity_dt_tm)), c.priority_cd = evaluate(validate
        (request->charge_event_act[x].priority_cd,1.0),0.0,c.priority_cd,- (1.0),0.0,
        validate(request->charge_event_act[x].priority_cd,c.priority_cd)), c.item_price = evaluate(
        validate(request->charge_event_act[x].item_price_ind,- (1)),0,c.item_price,1,validate(request
         ->charge_event_act[x].item_price,0.0),
        c.item_price),
       c.item_ext_price = evaluate(validate(request->charge_event_act[x].item_ext_price_ind,- (1)),0,
        c.item_ext_price,1,validate(request->charge_event_act[x].item_ext_price,0.0),
        c.item_ext_price), c.item_copay = evaluate(validate(request->charge_event_act[x].
         item_copay_ind,- (1)),0,c.item_copay,1,validate(request->charge_event_act[x].item_copay,0.0),
        c.item_copay), c.discount_amount = evaluate(validate(request->charge_event_act[x].
         discount_amount_ind,- (1)),0,c.discount_amount,1,validate(request->charge_event_act[x].
         discount_amount,0.0),
        c.discount_amount),
       c.item_reimbursement = evaluate(validate(request->charge_event_act[x].item_reimbursement_ind,
         - (1)),0,c.item_reimbursement,1,validate(request->charge_event_act[x].item_reimbursement,0.0
         ),
        c.item_reimbursement), c.item_deductible_amt = evaluate(validate(request->charge_event_act[x]
         .item_deductible_amt_ind,- (1)),0,c.item_deductible_amt,1,validate(request->
         charge_event_act[x].item_deductible_amt,0.0),
        c.item_deductible_amt), c.patient_responsibility_flag = evaluate(validate(request->
         charge_event_act[x].patient_responsibility_ind,- (1)),0,c.patient_responsibility_flag,1,
        validate(request->charge_event_act[x].patient_responsibility_flag,null),
        c.patient_responsibility_flag),
       c.active_ind = nullcheck(c.active_ind,request->charge_event_act[x].active_ind,
        IF ((request->charge_event_act[x].active_ind_ind=false)) 0
        ELSE 1
        ENDIF
        ), c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(sysdate),
       c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
       updt_task
      WHERE (c.charge_event_act_id=request->charge_event_act[x].charge_event_act_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->charge_event_act[x].charge_event_act_id = request->charge_event_act[x].
      charge_event_act_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
