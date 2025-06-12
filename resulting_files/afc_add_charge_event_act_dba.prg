CREATE PROGRAM afc_add_charge_event_act:dba
 SET afc_add_charge_event_act_vrsn = 001
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
 CALL add_charge_event_act(action_begin,action_end)
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
 SUBROUTINE add_charge_event_act(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET active_code = 0.0
     SET active_code = reqdata->active_status_cd
     SET data_status_code = 0.0
     SET data_status_code = reqdata->data_status_cd
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      y = seq(charge_event_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ELSE
      SET request->charge_event_act[x].charge_event_act_id = new_nbr
     ENDIF
     INSERT  FROM charge_event_act c
      SET c.charge_event_act_id = new_nbr, c.charge_event_id =
       IF (validate(request->charge_event_act[x].charge_event_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].charge_event_id,0)
       ENDIF
       , c.cea_type_cd =
       IF (validate(request->charge_event_act[x].cea_type_cd,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].cea_type_cd,0)
       ENDIF
       ,
       c.cea_prsnl_id =
       IF (validate(request->charge_event_act[x].cea_prsnl_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].cea_prsnl_id,0)
       ENDIF
       , c.service_resource_cd =
       IF (validate(request->charge_event_act[x].service_resource_cd,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].service_resource_cd,0)
       ENDIF
       , c.service_dt_tm =
       IF (((validate(request->charge_event_act[x].service_dt_tm,1) <= 0) OR (validate(request->
        charge_event_act[x].service_dt_tm,cnvtdatetime(sysdate))=blank_date)) ) null
       ELSE
        IF (validate(request->charge_event_act[x].service_dt_tm,0)) cnvtdatetime(request->
          charge_event_act[x].service_dt_tm)
        ELSE null
        ENDIF
       ENDIF
       ,
       c.charge_dt_tm =
       IF (((validate(request->charge_event_act[x].charge_dt_tm,1) <= 0) OR (validate(request->
        charge_event_act[x].charge_dt_tm,cnvtdatetime(sysdate))=blank_date)) ) null
       ELSE
        IF (validate(request->charge_event_act[x].charge_dt_tm,0)) cnvtdatetime(request->
          charge_event_act[x].charge_dt_tm)
        ELSE null
        ENDIF
       ENDIF
       , c.charge_type_cd =
       IF (validate(request->charge_event_act[x].charge_type_cd,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].charge_type_cd,0)
       ENDIF
       , c.reference_range_factor_id =
       IF (validate(request->charge_event_act[x].reference_range_factor_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].reference_range_factor_id,0)
       ENDIF
       ,
       c.alpha_nomen_id =
       IF (validate(request->charge_event_act[x].alpha_nomen_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].alpha_nomen_id,0)
       ENDIF
       , c.quantity =
       IF (validate(request->charge_event_act[x].quantity_ind,true)=false) 0
       ELSE validate(request->charge_event_act[x].quantity,0)
       ENDIF
       , c.units =
       IF (validate(request->charge_event_act[x].units,1)=0) 0
       ELSE validate(request->charge_event_act[x].units,0)
       ENDIF
       ,
       c.unit_type_cd =
       IF (validate(request->charge_event_act[x].unit_type_cd,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].unit_type_cd,0)
       ENDIF
       , c.patient_loc_cd =
       IF (validate(request->charge_event_act[x].patient_loc_cd,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].patient_loc_cd,0)
       ENDIF
       , c.service_loc_cd =
       IF (validate(request->charge_event_act[x].service_loc_cd,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].service_loc_cd,0)
       ENDIF
       ,
       c.reason_cd =
       IF (validate(request->charge_event_act[x].reason_cd,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].reason_cd,0)
       ENDIF
       , c.insert_dt_tm =
       IF (((validate(request->charge_event_act[x].insert_dt_tm,1) <= 0) OR (validate(request->
        charge_event_act[x].insert_dt_tm,cnvtdatetime(sysdate))=blank_date)) ) null
       ELSE
        IF (validate(request->charge_event_act[x].insert_dt_tm,0)) cnvtdatetime(request->
          charge_event_act[x].insert_dt_tm)
        ELSE null
        ENDIF
       ENDIF
       , c.in_lab_dt_tm =
       IF (((validate(request->charge_event_act[x].in_lab_dt_tm,1) <= 0) OR (validate(request->
        charge_event_act[x].in_lab_dt_tm,cnvtdatetime(sysdate))=blank_date)) ) null
       ELSE
        IF (validate(request->charge_event_act[x].in_lab_dt_tm,0)) cnvtdatetime(request->
          charge_event_act[x].in_lab_dt_tm)
        ELSE null
        ENDIF
       ENDIF
       ,
       c.accession_id =
       IF (validate(request->charge_event_act[x].accession_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].accession_id,0)
       ENDIF
       , c.repeat_ind =
       IF (validate(request->charge_event_act[x].repeat_ind_ind,true)=false) null
       ELSE validate(request->charge_event_act[x].repeat_ind,null)
       ENDIF
       , c.result =
       IF (validate(request->charge_event_act[x].result,"Z")="") null
       ELSE validate(request->charge_event_act[x].result,null)
       ENDIF
       ,
       c.cea_misc1 =
       IF (validate(request->charge_event_act[x].cea_misc1,"Z")="") null
       ELSE validate(request->charge_event_act[x].cea_misc1,null)
       ENDIF
       , c.cea_misc1_id =
       IF (validate(request->charge_event_act[x].cea_misc1_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].cea_misc1_id,0)
       ENDIF
       , c.cea_misc2 =
       IF (validate(request->charge_event_act[x].cea_misc2,"Z")="") null
       ELSE validate(request->charge_event_act[x].cea_misc2,null)
       ENDIF
       ,
       c.cea_misc2_id =
       IF (validate(request->charge_event_act[x].cea_misc2_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].cea_misc2_id,0)
       ENDIF
       , c.cea_misc3 =
       IF (validate(request->charge_event_act[x].cea_misc3,"Z")="") null
       ELSE validate(request->charge_event_act[x].cea_misc3,null)
       ENDIF
       , c.cea_misc3_id =
       IF (validate(request->charge_event_act[x].cea_misc3_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].cea_misc3_id,0)
       ENDIF
       ,
       c.cea_misc4_id =
       IF (validate(request->charge_event_act[x].cea_misc4_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].cea_misc4_id,0)
       ENDIF
       , c.srv_diag1_id =
       IF (validate(request->charge_event_act[x].srv_diag1_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].srv_diag1_id,0)
       ENDIF
       , c.srv_diag2_id =
       IF (validate(request->charge_event_act[x].srv_diag2_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].srv_diag2_id,0)
       ENDIF
       ,
       c.srv_diag3_id =
       IF (validate(request->charge_event_act[x].srv_diag3_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].srv_diag3_id,0)
       ENDIF
       , c.srv_diag4_id =
       IF (validate(request->charge_event_act[x].srv_diag4_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].srv_diag4_id,0)
       ENDIF
       , c.srv_diag_cd =
       IF (validate(request->charge_event_act[x].srv_diag_cd,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].srv_diag_cd,0)
       ENDIF
       ,
       c.misc_ind =
       IF (validate(request->charge_event_act[x].misc_ind_ind,true)=false) null
       ELSE validate(request->charge_event_act[x].misc_ind,null)
       ENDIF
       , c.cea_misc5_id =
       IF (validate(request->charge_event_act[x].cea_misc5_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].cea_misc5_id,0)
       ENDIF
       , c.cea_misc6_id =
       IF (validate(request->charge_event_act[x].cea_misc6_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].cea_misc6_id,0)
       ENDIF
       ,
       c.cea_misc7_id =
       IF (validate(request->charge_event_act[x].cea_misc7_id,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].cea_misc7_id,0)
       ENDIF
       , c.activity_dt_tm =
       IF (((validate(request->charge_event_act[x].activity_dt_tm,1) <= 0) OR (validate(request->
        charge_event_act[x].activity_dt_tm,cnvtdatetime(sysdate))=blank_date)) ) null
       ELSE
        IF (validate(request->charge_event_act[x].activity_dt_tm,0)) cnvtdatetime(request->
          charge_event_act[x].activity_dt_tm)
        ELSE null
        ENDIF
       ENDIF
       , c.priority_cd =
       IF (validate(request->charge_event_act[x].priority_cd,1) <= 0) 0
       ELSE validate(request->charge_event_act[x].priority_cd,0)
       ENDIF
       ,
       c.item_price =
       IF (validate(request->charge_event_act[x].item_price_ind,true)=false) 0
       ELSE validate(request->charge_event_act[x].item_price,0)
       ENDIF
       , c.item_ext_price =
       IF (validate(request->charge_event_act[x].item_ext_price_ind,true)=false) 0
       ELSE validate(request->charge_event_act[x].item_ext_price,0)
       ENDIF
       , c.item_copay =
       IF (validate(request->charge_event_act[x].item_copay_ind,true)=false) 0
       ELSE validate(request->charge_event_act[x].item_copay,0)
       ENDIF
       ,
       c.discount_amount =
       IF (validate(request->charge_event_act[x].discount_amount_ind,true)=false) 0
       ELSE validate(request->charge_event_act[x].discount_amount,0)
       ENDIF
       , c.item_reimbursement =
       IF (validate(request->charge_event_act[x].item_reimbursement_ind,true)=false) 0
       ELSE validate(request->charge_event_act[x].item_reimbursement,0)
       ENDIF
       , c.item_deductible_amt =
       IF (validate(request->charge_event_act[x].item_deductible_amt_ind,true)=false) 0
       ELSE validate(request->charge_event_act[x].item_deductible_amt,0)
       ENDIF
       ,
       c.patient_responsibility_flag =
       IF (validate(request->charge_event_act[x].patient_responsibility_flag_ind,true)=false) null
       ELSE validate(request->charge_event_act[x].patient_responsibility_flag,null)
       ENDIF
       , c.data_status_cd =
       IF (validate(request->charge_event_act[x].data_status_cd,1)=0) data_status_code
       ELSE validate(request->charge_event_act[x].data_status_cd,data_status_cd)
       ENDIF
       , c.data_status_dt_tm = cnvtdatetime(sysdate),
       c.data_status_prsnl_id = reqinfo->updt_id, c.beg_effective_dt_tm =
       IF (validate(request->charge_event_act[x].beg_effective_dt_tm,1) <= 0) cnvtdatetime(sysdate)
       ELSE
        IF (validate(request->charge_event_act[x].beg_effective_dt_tm,0)) cnvtdatetime(request->
          charge_event_act[x].beg_effective_dt_tm)
        ELSE cnvtdatetime(sysdate)
        ENDIF
       ENDIF
       , c.end_effective_dt_tm =
       IF (validate(request->charge_event_act[x].end_effective_dt_tm,1) <= 0) cnvtdatetime(
         "31-DEC-2100 00:00:00.00")
       ELSE
        IF (validate(request->charge_event_act[x].end_effective_dt_tm,0)) cnvtdatetime(request->
          charge_event_act[x].end_effective_dt_tm)
        ELSE cnvtdatetime(sysdate)
        ENDIF
       ENDIF
       ,
       c.active_ind =
       IF (validate(request->charge_event_act[x].active_ind_ind,true)=false) true
       ELSE validate(request->charge_event_act[x].active_ind,0)
       ENDIF
       , c.active_status_cd =
       IF (validate(request->charge_event_act[x].active_status_cd,1)=0) active_code
       ELSE validate(request->charge_event_act[x].active_status_cd,0)
       ENDIF
       , c.active_status_prsnl_id = reqinfo->updt_id,
       c.active_status_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(
        sysdate),
       c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
       updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->charge_event_act[x].charge_event_act_id = request->charge_event_act[x].
      charge_event_act_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
