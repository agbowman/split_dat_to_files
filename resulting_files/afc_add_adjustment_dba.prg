CREATE PROGRAM afc_add_adjustment:dba
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
 RECORD reply(
   1 charge_qual = i2
   1 charge[1]
     2 charge_item_id = f8
     2 parent_charge_item_id = f8
     2 charge_event_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 person_name = vc
     2 payor_id = f8
     2 perf_loc_cd = f8
     2 perf_loc_disp = c40
     2 perf_loc_desc = c60
     2 perf_loc_mean = c12
     2 ord_loc_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 charge_description = vc
     2 price_sched_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 item_allowable = f8
     2 item_copay = f8
     2 charge_type_cd = f8
     2 charge_type_disp = c40
     2 charge_type_desc = c60
     2 charge_type_mean = c12
     2 research_acct_id = f8
     2 suspense_rsn_cd = f8
     2 suspense_rsn_disp = c40
     2 suspense_rsn_desc = c60
     2 suspense_rsn_mean = c12
     2 reason_comment = vc
     2 posted_cd = f8
     2 posted_dt_tm = dq8
     2 process_flg = i4
     2 service_dt_tm = dq8
     2 activity_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 username = vc
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 credited_dt_tm = dq8
     2 adjusted_dt_tm = dq8
     2 interface_file_id = f8
     2 tier_group_cd = f8
     2 tier_group_disp = c40
     2 tier_group_desc = c60
     2 tier_group_mean = c12
     2 def_bill_item_id = f8
     2 verify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 manual_ind = i2
     2 combine_ind = i2
     2 bundle_id = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 admit_type_cd = f8
     2 med_service_cd = f8
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_desc = c60
     2 activity_type_mean = c12
     2 inst_fin_nbr = c50
     2 cost_center_cd = f8
     2 abn_status_cd = f8
     2 health_plan_id = f8
     2 fin_class_cd = f8
     2 payor_type_cd = f8
     2 item_reimbursement = f8
     2 item_interval_id = f8
     2 item_list_price = f8
     2 list_price_sched_id = f8
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
     2 charge_mod_qual = i2
     2 charge_mod[*]
       3 charge_mod_id = f8
       3 charge_mod_type_cd = f8
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field6 = vc
       3 field7 = vc
       3 nomen_id = f8
     2 original_org_id = f8
   1 original_charge_qual = i2
   1 original_charge[1]
     2 charge_item_id = f8
     2 process_flg = f8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = f8
     2 updt_dt_tm = dq8
     2 adjusted_dt_tm = dq8
     2 username = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD temprequest(
   1 charge_item_id = f8
   1 parent_charge_item_id = f8
   1 charge_event_act_id = f8
   1 charge_event_id = f8
   1 bill_item_id = f8
   1 charge_description = c200
   1 order_id = f8
   1 encntr_id = f8
   1 person_id = f8
   1 payor_id = f8
   1 ord_loc_cd = f8
   1 perf_loc_cd = f8
   1 ord_phys_id = f8
   1 perf_phys_id = f8
   1 price_sched_id = f8
   1 item_allowable = f8
   1 item_copay = f8
   1 charge_type_cd = f8
   1 research_acct_id = f8
   1 suspense_rsn_cd = f8
   1 reason_comment = vc
   1 posted_cd = f8
   1 posted_dt_tm = dq8
   1 process_flg = i4
   1 service_dt_tm = dq8
   1 activity_dt_tm = dq8
   1 active_ind = i2
   1 active_status_cd = f8
   1 active_status_dt_tm = dq8
   1 active_status_prsnl_id = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 credited_dt_tm = dq8
   1 interface_file_id = f8
   1 tier_group_cd = f8
   1 def_bill_item_id = f8
   1 verify_phys_id = f8
   1 gross_price = f8
   1 discount_amount = f8
   1 manual_ind = i2
   1 combine_ind = i2
   1 bundle_id = f8
   1 institution_cd = f8
   1 department_cd = f8
   1 section_cd = f8
   1 subsection_cd = f8
   1 level5_cd = f8
   1 admit_type_cd = f8
   1 med_service_cd = f8
   1 activity_type_cd = f8
   1 inst_fin_nbr = vc
   1 cost_center_cd = f8
   1 abn_status_cd = f8
   1 health_plan_id = f8
   1 fin_class_cd = f8
   1 payor_type_cd = f8
   1 item_reimbursement = f8
   1 item_interval_id = f8
   1 item_list_price = f8
   1 list_price_sched_id = f8
   1 start_dt_tm = dq8
   1 stop_dt_tm = dq8
   1 epsdt_ind = i2
   1 ref_phys_id = f8
   1 item_deductible_amt = f8
   1 patient_responsibility_flag = i2
   1 activity_sub_type_cd = f8
   1 provider_specialty_cd = f8
   1 original_org_id = f8
 )
 RECORD tempchargemod(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field5 = vc
     2 field6 = vc
     2 field7 = vc
     2 field8 = vc
     2 field9 = vc
     2 field10 = vc
     2 activity_dt_tm = dq8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_prsnl_id = f8
     2 code1_cd = f8
     2 nomen_id = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
 )
 SET reply->status_data.status = "F"
 SET failed = false
 SET x = 1
 SET dummyvar = 1
 SET table_name = "CHARGE"
 CALL add_charge(x)
 IF (failed != false)
  GO TO check_error
 ELSE
  CALL echo("Getting new charge...")
  CALL getnewcharge(dummyvar)
  CALL echo("Getting charge mods...")
  CALL getchargemods(dummyvar)
  CALL echo("Getting personnel...")
  CALL getpersonnel(dummyvar)
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
 SUBROUTINE add_charge(i)
   SET active_code = 0.0
   SET cid_new_nbr = 0.0
   IF ((((request->process_flg=0)) OR ((request->process_flg=3))) )
    SELECT INTO "nl:"
     FROM charge c
     WHERE (c.charge_item_id=request->charge_item_id)
     DETAIL
      temprequest->parent_charge_item_id = request->charge_item_id, temprequest->charge_event_act_id
       = c.charge_event_act_id, temprequest->charge_event_id = c.charge_event_id,
      temprequest->charge_description = c.charge_description, temprequest->bill_item_id = c
      .bill_item_id, temprequest->order_id = c.order_id,
      temprequest->encntr_id = c.encntr_id, temprequest->person_id = c.person_id, temprequest->
      payor_id = c.payor_id,
      temprequest->ord_loc_cd = c.ord_loc_cd, temprequest->perf_loc_cd = c.perf_loc_cd, temprequest->
      ord_phys_id = c.ord_phys_id,
      temprequest->perf_phys_id = c.perf_phys_id, temprequest->price_sched_id = c.price_sched_id,
      temprequest->item_allowable = c.item_allowable,
      temprequest->item_copay = c.item_copay, temprequest->charge_type_cd = c.charge_type_cd,
      temprequest->research_acct_id = c.research_acct_id,
      temprequest->suspense_rsn_cd = request->susp_rsn_cd, temprequest->reason_comment = request->
      reason_comment, temprequest->posted_cd = c.posted_cd,
      temprequest->process_flg = c.process_flg, temprequest->posted_dt_tm = c.posted_dt_tm,
      temprequest->service_dt_tm = c.service_dt_tm,
      temprequest->activity_dt_tm = c.activity_dt_tm, temprequest->active_ind = c.active_ind,
      temprequest->active_status_cd = c.active_status_cd,
      temprequest->active_status_dt_tm = c.active_status_dt_tm, temprequest->active_status_prsnl_id
       = c.active_status_prsnl_id, temprequest->beg_effective_dt_tm = c.beg_effective_dt_tm,
      temprequest->end_effective_dt_tm = c.end_effective_dt_tm, temprequest->credited_dt_tm = c
      .credited_dt_tm, temprequest->interface_file_id = c.interface_file_id,
      temprequest->tier_group_cd = c.tier_group_cd, temprequest->def_bill_item_id = c
      .def_bill_item_id, temprequest->verify_phys_id = c.verify_phys_id,
      temprequest->gross_price = c.gross_price, temprequest->discount_amount = c.discount_amount,
      temprequest->manual_ind = c.manual_ind,
      temprequest->combine_ind = c.combine_ind, temprequest->bundle_id = c.bundle_id, temprequest->
      institution_cd = c.institution_cd,
      temprequest->department_cd = c.department_cd, temprequest->section_cd = c.section_cd,
      temprequest->subsection_cd = c.subsection_cd,
      temprequest->level5_cd = c.level5_cd, temprequest->admit_type_cd = c.admit_type_cd, temprequest
      ->med_service_cd = c.med_service_cd,
      temprequest->activity_type_cd = c.activity_type_cd, temprequest->activity_sub_type_cd = c
      .activity_sub_type_cd, temprequest->provider_specialty_cd = c.provider_specialty_cd,
      temprequest->inst_fin_nbr = c.inst_fin_nbr, temprequest->cost_center_cd = c.cost_center_cd,
      temprequest->abn_status_cd = c.abn_status_cd,
      temprequest->health_plan_id = c.health_plan_id, temprequest->fin_class_cd = c.fin_class_cd,
      temprequest->payor_type_cd = c.payor_type_cd,
      temprequest->item_reimbursement = c.item_reimbursement, temprequest->item_interval_id = c
      .item_interval_id, temprequest->item_list_price = c.item_list_price,
      temprequest->list_price_sched_id = c.list_price_sched_id, temprequest->start_dt_tm = c
      .start_dt_tm, temprequest->stop_dt_tm = c.stop_dt_tm,
      temprequest->epsdt_ind = c.epsdt_ind, temprequest->ref_phys_id = c.ref_phys_id, temprequest->
      item_deductible_amt = c.item_deductible_amt,
      temprequest->patient_responsibility_flag = c.patient_responsibility_flag, temprequest->
      original_org_id = c.original_org_id
     WITH nocounter
    ;end select
    SET count1 = 0
    SELECT INTO "nl:"
     FROM charge_mod cm
     WHERE (cm.charge_item_id=request->charge_item_id)
      AND cm.active_ind=1
     DETAIL
      count1 += 1, stat = alterlist(tempchargemod->charge_mod,count1), tempchargemod->charge_mod[
      count1].charge_mod_type_cd = cm.charge_mod_type_cd,
      tempchargemod->charge_mod[count1].field1 = cm.field1, tempchargemod->charge_mod[count1].field2
       = cm.field2, tempchargemod->charge_mod[count1].field3 = cm.field3,
      tempchargemod->charge_mod[count1].field4 = cm.field4, tempchargemod->charge_mod[count1].field5
       = cm.field5, tempchargemod->charge_mod[count1].field6 = cm.field6,
      tempchargemod->charge_mod[count1].field7 = cm.field7, tempchargemod->charge_mod[count1].field8
       = cm.field8, tempchargemod->charge_mod[count1].field9 = cm.field9,
      tempchargemod->charge_mod[count1].field10 = cm.field10, tempchargemod->charge_mod[count1].
      active_ind = cm.active_ind, tempchargemod->charge_mod[count1].active_status_cd = cm
      .active_status_cd,
      tempchargemod->charge_mod[count1].active_status_prsnl_id = cm.active_status_prsnl_id,
      tempchargemod->charge_mod[count1].code1_cd = cm.code1_cd, tempchargemod->charge_mod[count1].
      nomen_id = cm.nomen_id,
      tempchargemod->charge_mod[count1].field1_id = cm.field1_id, tempchargemod->charge_mod[count1].
      field2_id = cm.field2_id, tempchargemod->charge_mod[count1].field3_id = cm.field3_id,
      tempchargemod->charge_mod[count1].field4_id = cm.field4_id, tempchargemod->charge_mod[count1].
      field5_id = cm.field5_id
     WITH nocounter
    ;end select
    SET tempchargemod->charge_mod_qual = count1
    SET new_nbr = 0.0
    SELECT INTO "nl:"
     y = seq(charge_event_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_nbr = cnvtreal(y),
      CALL echo(concat("New charge_item_id: ",cnvtstring(new_nbr,17,2)))
     WITH format, counter
    ;end select
    SET reply->charge[1].charge_item_id = new_nbr
    IF (curqual=0)
     SET failed = gen_nbr_error
     RETURN
    ELSE
     SET cid_new_nbr = new_nbr
    ENDIF
    INSERT  FROM charge c
     SET c.charge_item_id = new_nbr, c.parent_charge_item_id = request->charge_item_id, c
      .charge_event_act_id = temprequest->charge_event_act_id,
      c.charge_event_id = temprequest->charge_event_id, c.bill_item_id = temprequest->bill_item_id, c
      .order_id = temprequest->order_id,
      c.encntr_id = temprequest->encntr_id, c.person_id = temprequest->person_id, c.payor_id =
      temprequest->payor_id,
      c.ord_loc_cd = temprequest->ord_loc_cd, c.perf_loc_cd = temprequest->perf_loc_cd, c.ord_phys_id
       = temprequest->ord_phys_id,
      c.perf_phys_id = temprequest->perf_phys_id, c.charge_description = request->charge_description,
      c.price_sched_id = temprequest->price_sched_id,
      c.item_quantity =
      IF ((request->item_quantity=0)) null
      ELSE request->item_quantity
      ENDIF
      , c.item_price = request->item_price, c.item_extended_price = request->item_extended_price,
      c.item_allowable = temprequest->item_allowable, c.item_copay = temprequest->item_copay, c
      .charge_type_cd = temprequest->charge_type_cd,
      c.research_acct_id = temprequest->research_acct_id, c.suspense_rsn_cd = temprequest->
      suspense_rsn_cd, c.reason_comment = temprequest->reason_comment,
      c.posted_cd = temprequest->posted_cd, c.posted_dt_tm = cnvtdatetime(temprequest->posted_dt_tm),
      c.process_flg = temprequest->process_flg,
      c.service_dt_tm = cnvtdatetime(temprequest->service_dt_tm), c.activity_dt_tm = cnvtdatetime(
       temprequest->activity_dt_tm), c.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
      c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.99"), c.active_ind = temprequest->
      active_ind, c.active_status_cd = temprequest->active_status_cd,
      c.active_status_prsnl_id = reqinfo->updt_id, c.active_status_dt_tm = cnvtdatetime(sysdate), c
      .credited_dt_tm = cnvtdatetime(temprequest->credited_dt_tm),
      c.interface_file_id = temprequest->interface_file_id, c.tier_group_cd = temprequest->
      tier_group_cd, c.def_bill_item_id = temprequest->def_bill_item_id,
      c.verify_phys_id = temprequest->verify_phys_id, c.gross_price = temprequest->gross_price, c
      .discount_amount = (temprequest->gross_price - request->item_price),
      c.manual_ind =
      IF ((temprequest->charge_description=request->charge_description)) temprequest->manual_ind
      ELSE 1
      ENDIF
      , c.combine_ind = temprequest->combine_ind, c.bundle_id = temprequest->bundle_id,
      c.institution_cd = temprequest->institution_cd, c.department_cd = temprequest->department_cd, c
      .section_cd = temprequest->section_cd,
      c.subsection_cd = temprequest->subsection_cd, c.level5_cd = temprequest->level5_cd, c
      .admit_type_cd = temprequest->admit_type_cd,
      c.med_service_cd = temprequest->med_service_cd, c.activity_type_cd = temprequest->
      activity_type_cd, c.activity_sub_type_cd = temprequest->activity_sub_type_cd,
      c.provider_specialty_cd = temprequest->provider_specialty_cd, c.inst_fin_nbr = temprequest->
      inst_fin_nbr, c.cost_center_cd = temprequest->cost_center_cd,
      c.abn_status_cd = temprequest->abn_status_cd, c.health_plan_id = temprequest->health_plan_id, c
      .fin_class_cd = temprequest->fin_class_cd,
      c.payor_type_cd = temprequest->payor_type_cd, c.item_reimbursement = temprequest->
      item_reimbursement, c.item_interval_id = temprequest->item_interval_id,
      c.item_list_price = temprequest->item_list_price, c.list_price_sched_id = temprequest->
      list_price_sched_id, c.start_dt_tm = cnvtdatetime(temprequest->start_dt_tm),
      c.stop_dt_tm = cnvtdatetime(temprequest->stop_dt_tm), c.epsdt_ind = temprequest->epsdt_ind, c
      .ref_phys_id = temprequest->ref_phys_id,
      c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id,
      c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task, c.item_deductible_amt
       = temprequest->item_deductible_amt,
      c.patient_responsibility_flag = temprequest->patient_responsibility_flag, c.posted_id = reqinfo
      ->updt_id, c.original_org_id = temprequest->original_org_id,
      c.original_encntr_id =
      IF (validate(request->charge_item_id,0)=0) temprequest->encntr_id
      ELSE
       (SELECT
        c.original_encntr_id
        FROM charge c
        WHERE (c.charge_item_id=request->charge_item_id))
      ENDIF
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET reqinfo->commit_ind = true
     SET reply->status_data.status = "S"
    ENDIF
    UPDATE  FROM charge c
     SET c.process_flg = 11, c.adjusted_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = 0,
      c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->
      updt_applctx,
      c.updt_task = reqinfo->updt_task
     WHERE (c.charge_item_id=request->charge_item_id)
     WITH nocounter
    ;end update
    IF (curqual > 0)
     CALL echo("Updated charge!")
     SET reqinfo->commit_ind = true
     SET reply->status_data.status = "S"
     SET reply->original_charge[1].charge_item_id = request->charge_item_id
     SET reply->original_charge[1].updt_id = reqinfo->updt_id
     SET reply->original_charge[1].updt_dt_tm = cnvtdatetime(sysdate)
     SET reply->original_charge[1].updt_applctx = reqinfo->updt_applctx
     SET reply->original_charge[1].updt_task = reqinfo->updt_task
     SET reply->original_charge[1].process_flg = 11
     SET reply->original_charge[1].adjusted_dt_tm = cnvtdatetime(sysdate)
     CALL echo(concat("Original charge_item_id: ",cnvtstring(reply->original_charge[1].charge_item_id,
        17,2)))
     SET reply->original_charge_qual = 1
    ENDIF
    FOR (z = 1 TO tempchargemod->charge_mod_qual)
      SET new_nbr = 0.0
      SELECT INTO "nl:"
       y = seq(charge_event_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_nbr = cnvtreal(y)
       WITH format, counter
      ;end select
      INSERT  FROM charge_mod cm
       SET cm.charge_mod_id = new_nbr, cm.charge_item_id = cid_new_nbr, cm.charge_mod_type_cd =
        tempchargemod->charge_mod[z].charge_mod_type_cd,
        cm.field1 = tempchargemod->charge_mod[z].field1, cm.field2 = tempchargemod->charge_mod[z].
        field2, cm.field3 = tempchargemod->charge_mod[z].field3,
        cm.field4 = tempchargemod->charge_mod[z].field4, cm.field5 = tempchargemod->charge_mod[z].
        field5, cm.field6 = tempchargemod->charge_mod[z].field6,
        cm.field7 = tempchargemod->charge_mod[z].field7, cm.field8 = tempchargemod->charge_mod[z].
        field8, cm.field9 = tempchargemod->charge_mod[z].field9,
        cm.field10 = tempchargemod->charge_mod[z].field10, cm.active_ind = tempchargemod->charge_mod[
        z].active_ind, cm.active_status_cd = tempchargemod->charge_mod[z].active_ind,
        cm.active_status_prsnl_id = tempchargemod->charge_mod[z].active_status_prsnl_id, cm
        .active_status_dt_tm = cnvtdatetime(curdate,curtime), cm.activity_dt_tm = cnvtdatetime(
         curdate,curtime),
        cm.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), cm.end_effective_dt_tm = cnvtdatetime
        ("31-DEC-2100 23:59:59.99"), cm.code1_cd = tempchargemod->charge_mod[z].code1_cd,
        cm.nomen_id = tempchargemod->charge_mod[z].nomen_id, cm.field1_id = tempchargemod->
        charge_mod[z].field1_id, cm.field2_id = tempchargemod->charge_mod[z].field2_id,
        cm.field3_id = tempchargemod->charge_mod[z].field3_id, cm.field4_id = tempchargemod->
        charge_mod[z].field4_id, cm.field5_id = tempchargemod->charge_mod[z].field5_id,
        cm.updt_cnt = 0, cm.updt_task = reqinfo->updt_task, cm.updt_id = reqinfo->updt_id,
        cm.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
    ENDFOR
    IF (curqual > 0)
     CALL echo("Updated charge_mods!")
     SET reqinfo->commit_ind = true
    ENDIF
   ENDIF
   IF (curqual=0)
    SET failed = insert_error
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE getnewcharge(temp)
   SELECT INTO "nl:"
    c.*
    FROM charge c
    WHERE (c.charge_item_id=reply->charge[1].charge_item_id)
    DETAIL
     reply->charge[1].parent_charge_item_id = c.parent_charge_item_id,
     CALL echo(concat("charge_item_id: ",cnvtstring(c.charge_item_id,17,2))),
     CALL echo(concat("    parent_charge_item_id: ",cnvtstring(c.parent_charge_item_id,17,2))),
     reply->charge[1].charge_event_act_id = c.charge_event_act_id, reply->charge[1].charge_event_id
      = c.charge_event_id, reply->charge[1].bill_item_id = c.bill_item_id,
     reply->charge[1].order_id = c.order_id, reply->charge[1].encntr_id = c.encntr_id, reply->charge[
     1].person_id = c.person_id,
     reply->charge[1].payor_id = c.payor_id, reply->charge[1].perf_loc_cd = c.perf_loc_cd, reply->
     charge[1].ord_loc_cd = c.ord_loc_cd,
     reply->charge[1].ord_phys_id = c.ord_phys_id, reply->charge[1].perf_phys_id = c.perf_phys_id,
     reply->charge[1].charge_description = c.charge_description,
     reply->charge[1].price_sched_id = c.price_sched_id, reply->charge[1].item_quantity = c
     .item_quantity, reply->charge[1].item_price = c.item_price,
     reply->charge[1].item_extended_price = c.item_extended_price, reply->charge[1].item_allowable =
     c.item_allowable, reply->charge[1].item_copay = c.item_copay,
     reply->charge[1].charge_type_cd = c.charge_type_cd, reply->charge[1].research_acct_id = c
     .research_acct_id, reply->charge[1].suspense_rsn_cd = c.suspense_rsn_cd,
     reply->charge[1].reason_comment = c.reason_comment, reply->charge[1].posted_cd = c.posted_cd,
     reply->charge[1].posted_dt_tm = c.posted_dt_tm,
     reply->charge[1].process_flg = c.process_flg, reply->charge[1].service_dt_tm = c.service_dt_tm,
     reply->charge[1].activity_dt_tm = c.activity_dt_tm,
     reply->charge[1].updt_cnt = c.updt_cnt, reply->charge[1].updt_dt_tm = c.updt_dt_tm, reply->
     charge[1].updt_id = c.updt_id,
     reply->charge[1].updt_task = c.updt_task, reply->charge[1].updt_applctx = c.updt_applctx, reply
     ->charge[1].active_ind = c.active_ind,
     reply->charge[1].active_status_cd = c.active_status_cd, reply->charge[1].active_status_dt_tm = c
     .active_status_dt_tm, reply->charge[1].active_status_prsnl_id = c.active_status_prsnl_id,
     reply->charge[1].beg_effective_dt_tm = c.beg_effective_dt_tm, reply->charge[1].
     end_effective_dt_tm = c.end_effective_dt_tm, reply->charge[1].credited_dt_tm = c.credited_dt_tm,
     reply->charge[1].adjusted_dt_tm = c.adjusted_dt_tm, reply->charge[1].interface_file_id = c
     .interface_file_id, reply->charge[1].tier_group_cd = c.tier_group_cd,
     reply->charge[1].def_bill_item_id = c.def_bill_item_id, reply->charge[1].verify_phys_id = c
     .verify_phys_id, reply->charge[1].gross_price = c.gross_price,
     reply->charge[1].discount_amount = c.discount_amount, reply->charge[1].manual_ind = c.manual_ind,
     reply->charge[1].combine_ind = c.combine_ind,
     reply->charge[1].bundle_id = c.bundle_id, reply->charge[1].institution_cd = c.institution_cd,
     reply->charge[1].department_cd = c.department_cd,
     reply->charge[1].section_cd = c.section_cd, reply->charge[1].subsection_cd = c.subsection_cd,
     reply->charge[1].level5_cd = c.level5_cd,
     reply->charge[1].admit_type_cd = c.admit_type_cd, reply->charge[1].med_service_cd = c
     .med_service_cd, reply->charge[1].activity_type_cd = c.activity_type_cd,
     reply->charge[1].activity_sub_type_cd = c.activity_sub_type_cd, reply->charge[1].
     provider_specialty_cd = c.provider_specialty_cd, reply->charge[1].inst_fin_nbr = c.inst_fin_nbr,
     reply->charge[1].cost_center_cd = c.cost_center_cd, reply->charge[1].abn_status_cd = c
     .abn_status_cd, reply->charge[1].health_plan_id = c.health_plan_id,
     reply->charge[1].fin_class_cd = c.fin_class_cd, reply->charge[1].payor_type_cd = c.payor_type_cd,
     reply->charge[1].item_reimbursement = c.item_reimbursement,
     reply->charge[1].item_interval_id = c.item_interval_id, reply->charge[1].item_list_price = c
     .item_list_price, reply->charge[1].list_price_sched_id = c.list_price_sched_id,
     reply->charge[1].start_dt_tm = c.start_dt_tm, reply->charge[1].stop_dt_tm = c.stop_dt_tm, reply
     ->charge[1].epsdt_ind = c.epsdt_ind,
     reply->charge[1].ref_phys_id = c.ref_phys_id, reply->charge[1].item_deductible_amt = c
     .item_deductible_amt, reply->charge[1].patient_responsibility_flag = c
     .patient_responsibility_flag,
     reply->charge[1].original_org_id = c.original_org_id
    WITH nocounter
   ;end select
   SET reply->charge_qual = 1
   SELECT INTO "nl:"
    FROM person p
    WHERE (p.person_id=reply->charge[1].person_id)
    DETAIL
     reply->charge[1].person_name = p.name_full_formatted
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getchargemods(temp)
  SET count1 = 0
  SELECT INTO "nl:"
   cm.charge_mod_id
   FROM charge_mod cm
   WHERE (cm.charge_item_id=reply->charge[1].charge_item_id)
   DETAIL
    count1 += 1, stat = alterlist(reply->charge[1].charge_mod,count1), reply->charge[1].charge_mod[
    count1].charge_mod_id = cm.charge_mod_id,
    reply->charge[1].charge_mod[count1].charge_mod_type_cd = cm.charge_mod_type_cd, reply->charge[1].
    charge_mod[count1].field1_id = cm.field1_id, reply->charge[1].charge_mod[count1].field2_id = cm
    .field2_id,
    reply->charge[1].charge_mod[count1].field3_id = cm.field3_id, reply->charge[1].charge_mod[count1]
    .field6 = cm.field6, reply->charge[1].charge_mod[count1].field7 = cm.field7,
    reply->charge[1].charge_mod[count1].nomen_id = cm.nomen_id, reply->charge[1].charge_mod_qual =
    count1
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE getpersonnel(temp)
  CALL echo(concat("getting personnel updt_id: ",cnvtstring(reply->charge[1].updt_id,17,2)))
  SELECT INTO "nl:"
   p.person_id
   FROM prsnl p
   WHERE (p.person_id=reply->charge[1].updt_id)
   DETAIL
    reply->charge[1].username = p.username, reply->original_charge[1].username = p.username,
    CALL echo(concat("username: ",p.username))
   WITH nocounter
  ;end select
 END ;Subroutine
#end_program
END GO
