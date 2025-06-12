CREATE PROGRAM afc_ens_release_charge:dba
 IF ("Z"=validate(afc_ens_release_charge_vrsn,"Z"))
  DECLARE afc_ens_release_charge_vrsn = vc WITH noconstant("578750.014")
 ENDIF
 SET afc_ens_release_charge_vrsn = "578750.014"
 RECORD holdreq(
   1 charge_qual = i2
   1 charge[*]
     2 charge_item_id = f8
     2 charge_desc = vc
     2 quantity = f8
     2 item_price = f8
     2 ext_item_price = f8
     2 process_flg = i4
     2 charge_mod_qual = i2
     2 charge_mod[*]
       3 action_type = vc
       3 charge_mod_id = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 bill_code_type_cd = vc
       3 bill_code = vc
       3 description = vc
       3 priority = vc
       3 field3_id = f8
       3 nomen_id = f8
       3 charge_mod_source_cd = f8
     2 reason_qual = i2
     2 reason[*]
       3 action_type = vc
       3 charge_mod_id = f8
 )
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
    1 charge_qual = i2
    1 charge[*]
      2 charge_item_id = f8
      2 perf_loc_cd = f8
      2 ord_phys_id = f8
      2 verify_phys_id = f8
      2 research_acct_id = f8
      2 abn_status_cd = f8
      2 service_dt_tm = dq8
      2 suspense_rsn_cd = f8
      2 reason_comment = vc
      2 process_flg = i4
    1 status_data
      2 status = c1
      2 subeventstatus[5]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
    1 charge_mod_qual = i2
    1 charge_mod[*]
      2 charge_mod_id = f8
      2 charge_item_id = f8
      2 action_type = c3
      2 charge_mod_type_cd = f8
      2 field1_id = f8
      2 field2_id = f8
      2 field3_id = f8
      2 field6 = vc
      2 field7 = vc
      2 nomen_id = f8
      2 nomen_entity_reltn_id = f8
      2 cm1_nbr = f8
  )
  SET action_begin = 1
  SET action_end = request->charge_qual
  SET reply->charge_qual = request->charge_qual
 ENDIF
 SET hafc_ens_charge_event = 0
 SET istatus = 0
 CALL initialize("INIT")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET failed = false
 SET table_name = "CHARGE"
 SET charge_cnt = 0
 FOR (charge_cnt = 1 TO holdreq->charge_qual)
   CALL echo("Calling charge_mod_request, REASON")
   CALL charge_mod_request("REASON",charge_cnt)
   CALL echo("Calling charge_mod_request, BILLCODE")
   CALL charge_mod_request("BILLCODE",charge_cnt)
 ENDFOR
 IF ((holdreq->charge_qual > 0))
  CALL echo("Calling charge_request")
  CALL charge_request(0)
  CALL echo("Returned from charge_request subroutine")
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
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
 ENDIF
 SUBROUTINE initialize(str)
   CALL echo("++++++++++++++++++++++++++ INITIALIZE +++++++++++++++++++++++++++")
   SET reply->status_data.status = "F"
   SET stat = alterlist(holdreq->charge,request->charge_qual)
   SET holdreq->charge_qual = request->charge_qual
   FOR (psub = 1 TO request->charge_qual)
     SET psub2 = 0
     SET holdreq->charge[psub].charge_item_id = request->charge[psub].charge_item_id
     SET holdreq->charge[psub].charge_desc = request->charge[psub].charge_desc
     SET holdreq->charge[psub].quantity = request->charge[psub].quantity
     SET holdreq->charge[psub].item_price = request->charge[psub].item_price
     SET holdreq->charge[psub].ext_item_price = request->charge[psub].ext_item_price
     SET holdreq->charge[psub].process_flg = request->charge[psub].process_flg
     SET holdreq->charge[psub].charge_mod_qual = request->charge[psub].charge_mod_qual
     SET stat = alterlist(holdreq->charge[psub].charge_mod,request->charge[psub].charge_mod_qual)
     SET holdreq->charge[psub].charge_mod_qual = request->charge[psub].charge_mod_qual
     CALL echo("CHARGE_MOD_QUAL ",0)
     CALL echo(cnvtstring(request->charge[psub].charge_mod_qual))
     FOR (psub2 = 1 TO request->charge[psub].charge_mod_qual)
       CALL echo("PSUB: ",0)
       CALL echo(cnvtstring(psub))
       SET holdreq->charge[psub].charge_mod[psub2].action_type = request->charge[psub].charge_mod[
       psub2].action_type
       SET holdreq->charge[psub].charge_mod[psub2].charge_mod_id = request->charge[psub].charge_mod[
       psub2].charge_mod_id
       SET holdreq->charge[psub].charge_mod[psub2].charge_item_id = request->charge[psub].charge_mod[
       psub2].charge_item_id
       SET holdreq->charge[psub].charge_mod[psub2].charge_mod_type_cd = request->charge[psub].
       charge_mod[psub2].charge_mod_type_cd
       SET holdreq->charge[psub].charge_mod[psub2].bill_code_type_cd = request->charge[psub].
       charge_mod[psub2].bill_code_type_cd
       SET holdreq->charge[psub].charge_mod[psub2].bill_code = request->charge[psub].charge_mod[psub2
       ].bill_code
       SET holdreq->charge[psub].charge_mod[psub2].description = request->charge[psub].charge_mod[
       psub2].description
       SET holdreq->charge[psub].charge_mod[psub2].priority = request->charge[psub].charge_mod[psub2]
       .priority
       SET holdreq->charge[psub].charge_mod[psub2].field3_id = request->charge[psub].charge_mod[psub2
       ].field3_id
       IF (validate(request->charge[psub].charge_mod[psub2].nomen_id))
        SET holdreq->charge[psub].charge_mod[psub2].nomen_id = request->charge[psub].charge_mod[psub2
        ].nomen_id
       ENDIF
       IF (validate(request->charge[psub].charge_mod[psub2].charge_mod_source_cd))
        SET holdreq->charge[psub].charge_mod[psub2].charge_mod_source_cd = request->charge[psub].
        charge_mod[psub2].charge_mod_source_cd
       ENDIF
     ENDFOR
     SET stat = alterlist(holdreq->charge[psub].reason,size(request->charge[psub].reason,5))
     SET holdreq->charge[psub].reason_qual = size(request->charge[psub].reason,5)
     CALL echo("REASON_QUAL ",0)
     CALL echo(cnvtstring(size(request->charge[psub].reason,5)))
     FOR (psub2 = 1 TO size(request->charge[psub].reason,5))
      SET holdreq->charge[psub].reason[psub2].action_type = request->charge[psub].reason[psub2].
      action_type
      SET holdreq->charge[psub].reason[psub2].charge_mod_id = request->charge[psub].reason[psub2].
      charge_mod_id
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE charge_request(dummyvar)
   DECLARE updcnt = i4 WITH protect, noconstant(0)
   CALL echo("\\\\\\\\\\\\\\\\\\\\\ CHARGE_REQUEST ////////////////////")
   FREE SET upt_charge_request
   RECORD upt_charge_request(
     1 charge_qual = i2
     1 charge[*]
       2 charge_item_id = f8
       2 parent_charge_item_id = f8
       2 charge_event_act_id = f8
       2 charge_event_id = f8
       2 bill_item_id = f8
       2 order_id = f8
       2 encntr_id = f8
       2 person_id = f8
       2 payor_id = f8
       2 ord_loc_cd = f8
       2 perf_loc_cd = f8
       2 ord_phys_id = f8
       2 perf_phys_id = f8
       2 charge_description = c200
       2 price_sched_id = f8
       2 item_quantity = f8
       2 item_price_ind = i2
       2 item_price = f8
       2 item_extended_price_ind = i2
       2 item_extended_price = f8
       2 item_allowable_ind = i2
       2 item_allowable = f8
       2 item_copay_ind = i2
       2 item_copay = f8
       2 charge_type_cd = f8
       2 research_acct_id = f8
       2 suspense_rsn_cd = f8
       2 reason_comment = c200
       2 posted_cd = f8
       2 posted_dt_tm = dq8
       2 process_flg = i4
       2 service_dt_tm = dq8
       2 activity_dt_tm = dq8
       2 active_status_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 updt_cnt = i4
       2 active_ind = i2
       2 active_ind_ind = i2
       2 verify_phys_id = f8
       2 abn_status_cd = f8
       2 item_deductible_amt = f8
       2 patient_responsibility_flag = i2
   )
   FOR (updcnt = 1 TO holdreq->charge_qual)
     SET stat = alterlist(upt_charge_request->charge,updcnt)
     SET upt_charge_request->charge[updcnt].charge_item_id = holdreq->charge[updcnt].charge_item_id
     SET upt_charge_request->charge[updcnt].charge_description = holdreq->charge[updcnt].charge_desc
     SET upt_charge_request->charge[updcnt].item_quantity = holdreq->charge[updcnt].quantity
     SET upt_charge_request->charge[updcnt].item_price = holdreq->charge[updcnt].item_price
     SET upt_charge_request->charge[updcnt].item_extended_price = holdreq->charge[updcnt].
     ext_item_price
     SET upt_charge_request->charge[updcnt].process_flg = holdreq->charge[updcnt].process_flg
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(upt_charge_request->charge,5)),
     charge c
    PLAN (d1)
     JOIN (c
     WHERE (c.charge_item_id=upt_charge_request->charge[d1.seq].charge_item_id)
      AND c.active_ind=true)
    DETAIL
     upt_charge_request->charge[d1.seq].ord_phys_id = c.ord_phys_id, upt_charge_request->charge[d1
     .seq].verify_phys_id = c.verify_phys_id
    WITH nocounter
   ;end select
   CALL echo("Calling afc_upt_charge from charge_request subroutine")
   SET upt_charge_request->charge_qual = holdreq->charge_qual
   EXECUTE afc_upt_charge  WITH replace("REQUEST",upt_charge_request)
 END ;Subroutine
 SUBROUTINE charge_mod_request(type,qual)
   CALL echo("\\\\\\\\\\\\\\\\\\\  CHARGE_MOD_REQUEST ////////////////////")
   FREE SET ens_charge_mod_request
   RECORD ens_charge_mod_request(
     1 charge_mod_qual = i2
     1 charge_mod[*]
       2 action_type = c3
       2 charge_mod_id = f8
       2 charge_item_id = f8
       2 charge_mod_type_cd = f8
       2 field1 = c200
       2 field2 = c200
       2 field3 = c200
       2 field4 = c200
       2 field5 = c200
       2 field6 = c200
       2 field7 = c200
       2 field8 = c200
       2 field9 = c200
       2 field10 = c200
       2 activity_dt_tm = dq8
       2 active_ind_ind = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 field1_id = f8
       2 field2_id = f8
       2 field3_id = f8
       2 field4_id = f8
       2 field5_id = f8
       2 nomen_id = f8
       2 cm1_nbr = f8
       2 nomen_entity_reltn_id = f8
       2 charge_mod_source_cd = f8
   )
   IF (type="BILLCODE")
    CALL echo(cnvtstring(qual),0)
    CALL echo("     BILLCODE ",0)
    CALL echo(cnvtstring(holdreq->charge[qual].charge_mod_qual),0)
    FOR (modcnt = 1 TO holdreq->charge[qual].charge_mod_qual)
      SET stat = alterlist(ens_charge_mod_request->charge_mod,modcnt)
      SET ens_charge_mod_request->charge_mod_qual = modcnt
      CALL echo("charge_mod_id: ",0)
      CALL echo(cnvtstring(holdreq->charge[qual].charge_mod[modcnt].charge_mod_id,17,2))
      SET ens_charge_mod_request->charge_mod[modcnt].action_type = holdreq->charge[qual].charge_mod[
      modcnt].action_type
      SET ens_charge_mod_request->charge_mod[modcnt].charge_mod_id = holdreq->charge[qual].
      charge_mod[modcnt].charge_mod_id
      SET ens_charge_mod_request->charge_mod[modcnt].charge_item_id = holdreq->charge[qual].
      charge_mod[modcnt].charge_item_id
      SET ens_charge_mod_request->charge_mod[modcnt].charge_item_id = holdreq->charge[qual].
      charge_item_id
      SET ens_charge_mod_request->charge_mod[modcnt].charge_mod_type_cd = holdreq->charge[qual].
      charge_mod[modcnt].charge_mod_type_cd
      SET ens_charge_mod_request->charge_mod[modcnt].field1 = holdreq->charge[qual].charge_mod[modcnt
      ].bill_code_type_cd
      SET ens_charge_mod_request->charge_mod[modcnt].field1_id = cnvtreal(trim(holdreq->charge[qual].
        charge_mod[modcnt].bill_code_type_cd,3))
      SET ens_charge_mod_request->charge_mod[modcnt].field2 = holdreq->charge[qual].charge_mod[modcnt
      ].bill_code
      SET ens_charge_mod_request->charge_mod[modcnt].field6 = holdreq->charge[qual].charge_mod[modcnt
      ].bill_code
      SET ens_charge_mod_request->charge_mod[modcnt].field3 = holdreq->charge[qual].charge_mod[modcnt
      ].description
      SET ens_charge_mod_request->charge_mod[modcnt].field7 = holdreq->charge[qual].charge_mod[modcnt
      ].description
      SET ens_charge_mod_request->charge_mod[modcnt].field4 = holdreq->charge[qual].charge_mod[modcnt
      ].priority
      SET ens_charge_mod_request->charge_mod[modcnt].field2_id = cnvtreal(trim(holdreq->charge[qual].
        charge_mod[modcnt].priority,3))
      SET ens_charge_mod_request->charge_mod[modcnt].field3_id = holdreq->charge[qual].charge_mod[
      modcnt].field3_id
      SET ens_charge_mod_request->charge_mod[modcnt].nomen_id = holdreq->charge[qual].charge_mod[
      modcnt].nomen_id
      SET ens_charge_mod_request->charge_mod[modcnt].charge_mod_source_cd = holdreq->charge[qual].
      charge_mod[modcnt].charge_mod_source_cd
      SET ens_charge_mod_request->charge_mod_qual = modcnt
    ENDFOR
   ELSE
    CALL echo(cnvtstring(qual))
    CALL echo("     REASON ")
    CALL echo(cnvtstring(size(holdreq->charge[qual].reason,5)))
    FOR (modcnt = 1 TO size(holdreq->charge[qual].reason,5))
      SET stat = alterlist(ens_charge_mod_request->charge_mod,modcnt)
      SET ens_charge_mod_request->charge_mod_qual = modcnt
      SET ens_charge_mod_request->charge_mod[modcnt].action_type = holdreq->charge[qual].reason[
      modcnt].action_type
      SET ens_charge_mod_request->charge_mod[modcnt].charge_mod_id = holdreq->charge[qual].reason[
      modcnt].charge_mod_id
    ENDFOR
   ENDIF
   EXECUTE afc_ens_charge_mod  WITH replace("REQUEST",ens_charge_mod_request)
 END ;Subroutine
#end_program
 FREE SET holdreq
END GO
