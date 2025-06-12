CREATE PROGRAM ct_adjust_profit_charge:dba
 SET ct_adjust_profit_charge_version = "646960.FT.010"
 CALL echo("executing ct_adjust_profit_charge")
 FREE SET tmp_charge_struct
 RECORD tmp_charge_struct(
   1 charge_item_id = f8
   1 parent_charge_item_id = f8
   1 charge_event_act_id = f8
   1 charge_event_id = f8
   1 bill_item_id = f8
   1 order_id = f8
   1 encntr_id = f8
   1 person_id = f8
   1 payor_id = f8
   1 ord_loc_cd = f8
   1 perf_loc_cd = f8
   1 ord_phys_id = f8
   1 perf_phys_id = f8
   1 charge_description = vc
   1 price_sched_id = f8
   1 item_quantity = f8
   1 item_price = f8
   1 item_extended_price = f8
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
   1 updt_cnt = i4
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 updt_task = i4
   1 updt_applctx = f8
   1 active_ind = i2
   1 active_status_cd = f8
   1 active_status_dt_tm = dq8
   1 active_status_prsnl_id = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 credited_dt_tm = dq8
   1 adjusted_dt_tm = dq8
   1 interface_file_id = f8
   1 tier_group_cd = f8
   1 def_bill_item_id = f8
   1 verify_phys_id = f8
   1 gross_price = f8
   1 discount_amount = f8
   1 manual_ind = i2
   1 combine_ind = i2
   1 activity_type_cd = f8
   1 admit_type_cd = f8
   1 bundle_id = f8
   1 department_cd = f8
   1 institution_cd = f8
   1 section_cd = f8
   1 subsection_cd = f8
   1 level5_cd = f8
   1 med_service_cd = f8
   1 abn_status_cd = f8
   1 cost_center_cd = f8
   1 inst_fin_nbr = c50
   1 fin_class_cd = f8
   1 health_plan_id = f8
   1 item_interval_id = f8
   1 item_list_price = f8
   1 item_reimbursement = f8
   1 list_price_sched_id = f8
   1 payor_type_cd = f8
   1 epsdt_ind = i2
   1 ref_phys_id = f8
   1 start_dt_tm = dq8
   1 stop_dt_tm = dq8
   1 alpha_nomen_id = f8
   1 offset_charge_item_id = f8
   1 item_deductible_amt = f8
   1 patient_responsibility_flag = i2
   1 activity_sub_type_cd = f8
   1 provider_specialty_cd = f8
   1 original_org_id = f8
 )
 FREE SET tmp_charge_mod_struct
 RECORD tmp_charge_mod_struct(
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
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_prsnl_id = f8
     2 active_status_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 code1_cd = f8
     2 nomen_id = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
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
 FREE SET temprequest
 RECORD temprequest(
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
 )
 FREE SET tempreply
 RECORD tempreply(
   1 success_ind = i4
   1 failed_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_interface_req
 RECORD temp_interface_req(
   1 interface_charge[*]
     2 charge_item_id = f8
 )
 CALL echo(build("CT_ADJUST_PROFIT_CHARGE::getting current record for charge_item_id: ",request->
   charge_item_id))
 SELECT INTO "nl:"
  FROM charge c
  WHERE (c.charge_item_id=request->charge_item_id)
  DETAIL
   tmp_charge_struct->charge_item_id = c.charge_item_id, tmp_charge_struct->parent_charge_item_id = c
   .parent_charge_item_id, tmp_charge_struct->charge_event_act_id = c.charge_event_act_id,
   tmp_charge_struct->charge_event_id = c.charge_event_id, tmp_charge_struct->bill_item_id = c
   .bill_item_id, tmp_charge_struct->order_id = c.order_id,
   tmp_charge_struct->encntr_id = c.encntr_id, tmp_charge_struct->person_id = c.person_id,
   tmp_charge_struct->payor_id = c.payor_id,
   tmp_charge_struct->ord_loc_cd = c.ord_loc_cd, tmp_charge_struct->perf_loc_cd = c.perf_loc_cd,
   tmp_charge_struct->ord_phys_id = c.ord_phys_id,
   tmp_charge_struct->perf_phys_id = c.perf_phys_id, tmp_charge_struct->charge_description = c
   .charge_description, tmp_charge_struct->price_sched_id = c.price_sched_id,
   tmp_charge_struct->item_quantity = c.item_quantity, tmp_charge_struct->item_price = c.item_price,
   tmp_charge_struct->item_extended_price = c.item_extended_price,
   tmp_charge_struct->item_allowable = c.item_allowable, tmp_charge_struct->item_copay = c.item_copay,
   tmp_charge_struct->charge_type_cd = c.charge_type_cd,
   tmp_charge_struct->research_acct_id = c.research_acct_id, tmp_charge_struct->posted_cd = c
   .posted_cd, tmp_charge_struct->posted_dt_tm = cnvtdatetime(c.posted_dt_tm),
   tmp_charge_struct->process_flg = c.process_flg,
   CALL echo(build("    process_flg is: ",c.process_flg)), tmp_charge_struct->service_dt_tm =
   cnvtdatetime(c.service_dt_tm),
   tmp_charge_struct->activity_dt_tm = cnvtdatetime(c.activity_dt_tm), tmp_charge_struct->updt_cnt =
   c.updt_cnt, tmp_charge_struct->updt_dt_tm = cnvtdatetime(c.updt_dt_tm),
   tmp_charge_struct->updt_id = c.updt_id, tmp_charge_struct->updt_task = c.updt_task,
   tmp_charge_struct->updt_applctx = c.updt_applctx,
   tmp_charge_struct->active_ind = c.active_ind, tmp_charge_struct->active_status_cd = c
   .active_status_cd, tmp_charge_struct->active_status_dt_tm = cnvtdatetime(c.active_status_dt_tm),
   tmp_charge_struct->active_status_prsnl_id = c.active_status_prsnl_id, tmp_charge_struct->
   beg_effective_dt_tm = cnvtdatetime(c.beg_effective_dt_tm), tmp_charge_struct->end_effective_dt_tm
    = cnvtdatetime(c.end_effective_dt_tm),
   tmp_charge_struct->credited_dt_tm = cnvtdatetime(c.credited_dt_tm), tmp_charge_struct->
   adjusted_dt_tm = cnvtdatetime(c.adjusted_dt_tm), tmp_charge_struct->interface_file_id = c
   .interface_file_id,
   tmp_charge_struct->tier_group_cd = c.tier_group_cd, tmp_charge_struct->def_bill_item_id = c
   .def_bill_item_id, tmp_charge_struct->verify_phys_id = c.verify_phys_id,
   tmp_charge_struct->gross_price = c.gross_price, tmp_charge_struct->discount_amount = c
   .discount_amount, tmp_charge_struct->manual_ind = c.manual_ind,
   tmp_charge_struct->combine_ind = c.combine_ind, tmp_charge_struct->activity_type_cd = c
   .activity_type_cd, tmp_charge_struct->activity_sub_type_cd = c.activity_sub_type_cd,
   tmp_charge_struct->provider_specialty_cd = c.provider_specialty_cd, tmp_charge_struct->
   admit_type_cd = c.admit_type_cd, tmp_charge_struct->bundle_id = c.bundle_id,
   tmp_charge_struct->department_cd = c.department_cd, tmp_charge_struct->institution_cd = c
   .institution_cd, tmp_charge_struct->section_cd = c.section_cd,
   tmp_charge_struct->subsection_cd = c.subsection_cd, tmp_charge_struct->level5_cd = c.level5_cd,
   tmp_charge_struct->med_service_cd = c.med_service_cd,
   tmp_charge_struct->abn_status_cd = c.abn_status_cd, tmp_charge_struct->cost_center_cd = c
   .cost_center_cd, tmp_charge_struct->inst_fin_nbr = c.inst_fin_nbr,
   tmp_charge_struct->fin_class_cd = c.fin_class_cd, tmp_charge_struct->health_plan_id = c
   .health_plan_id, tmp_charge_struct->item_interval_id = c.item_interval_id,
   tmp_charge_struct->item_list_price = c.item_list_price, tmp_charge_struct->item_reimbursement = c
   .item_reimbursement, tmp_charge_struct->list_price_sched_id = c.list_price_sched_id,
   tmp_charge_struct->payor_type_cd = c.payor_type_cd, tmp_charge_struct->epsdt_ind = c.epsdt_ind,
   tmp_charge_struct->ref_phys_id = c.ref_phys_id,
   tmp_charge_struct->start_dt_tm = cnvtdatetime(c.start_dt_tm), tmp_charge_struct->stop_dt_tm =
   cnvtdatetime(c.stop_dt_tm), tmp_charge_struct->alpha_nomen_id = c.alpha_nomen_id,
   tmp_charge_struct->offset_charge_item_id = c.offset_charge_item_id, tmp_charge_struct->
   item_deductible_amt = c.item_deductible_amt, tmp_charge_struct->patient_responsibility_flag = c
   .patient_responsibility_flag
  WITH nocounter
 ;end select
 CALL echo(build("CT_ADJUST_PROFIT_CHARGE::getting current mod record for charge_item_id: ",request->
   charge_item_id))
 SET count1 = 0
 SELECT INTO "nl:"
  FROM charge_mod cm
  WHERE (cm.charge_item_id=request->charge_item_id)
  DETAIL
   count1 += 1, stat = alterlist(tmp_charge_mod_struct->charge_mod,count1), tmp_charge_mod_struct->
   charge_mod[count1].charge_item_id = cm.charge_item_id,
   tmp_charge_mod_struct->charge_mod[count1].charge_mod_type_cd = cm.charge_mod_type_cd,
   tmp_charge_mod_struct->charge_mod[count1].field1 = cm.field1, tmp_charge_mod_struct->charge_mod[
   count1].field2 = cm.field2,
   tmp_charge_mod_struct->charge_mod[count1].field3 = cm.field3, tmp_charge_mod_struct->charge_mod[
   count1].field4 = cm.field4, tmp_charge_mod_struct->charge_mod[count1].field5 = cm.field5,
   tmp_charge_mod_struct->charge_mod[count1].field6 = cm.field6, tmp_charge_mod_struct->charge_mod[
   count1].field7 = cm.field7, tmp_charge_mod_struct->charge_mod[count1].field8 = cm.field8,
   tmp_charge_mod_struct->charge_mod[count1].field9 = cm.field9, tmp_charge_mod_struct->charge_mod[
   count1].field10 = cm.field10, tmp_charge_mod_struct->charge_mod[count1].activity_dt_tm =
   cnvtdatetime(cm.activity_dt_tm),
   tmp_charge_mod_struct->charge_mod[count1].updt_cnt = cm.updt_cnt, tmp_charge_mod_struct->
   charge_mod[count1].updt_dt_tm = cnvtdatetime(cm.updt_dt_tm), tmp_charge_mod_struct->charge_mod[
   count1].updt_id = cm.updt_id,
   tmp_charge_mod_struct->charge_mod[count1].updt_task = cm.updt_task, tmp_charge_mod_struct->
   charge_mod[count1].updt_applctx = cm.updt_applctx, tmp_charge_mod_struct->charge_mod[count1].
   active_ind = cm.active_ind,
   tmp_charge_mod_struct->charge_mod[count1].active_status_cd = cm.active_status_cd,
   tmp_charge_mod_struct->charge_mod[count1].active_status_prsnl_id = cm.active_status_prsnl_id,
   tmp_charge_mod_struct->charge_mod[count1].active_status_dt_tm = cnvtdatetime(cm
    .active_status_dt_tm),
   tmp_charge_mod_struct->charge_mod[count1].beg_effective_dt_tm = cnvtdatetime(cm
    .beg_effective_dt_tm), tmp_charge_mod_struct->charge_mod[count1].end_effective_dt_tm =
   cnvtdatetime(cm.end_effective_dt_tm), tmp_charge_mod_struct->charge_mod[count1].code1_cd = cm
   .code1_cd,
   tmp_charge_mod_struct->charge_mod[count1].nomen_id = cm.nomen_id, tmp_charge_mod_struct->
   charge_mod[count1].field1_id = cm.field1_id, tmp_charge_mod_struct->charge_mod[count1].field2_id
    = cm.field2_id,
   tmp_charge_mod_struct->charge_mod[count1].field3_id = cm.field3_id, tmp_charge_mod_struct->
   charge_mod[count1].field4_id = cm.field4_id, tmp_charge_mod_struct->charge_mod[count1].field5_id
    = cm.field5_id
  WITH nocounter
 ;end select
 SET tmp_charge_mod_struct->charge_mod_qual = count1
 CALL echo(build("CT_ADJUST_PROFIT_CHARGE::adding new record from charge_item_id: ",request->
   charge_item_id))
 SET new_nbr = 0.0
 SELECT INTO "nl:"
  temp_var = seq(charge_event_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_nbr = cnvtreal(temp_var)
  WITH format, counter
 ;end select
 INSERT  FROM charge c
  SET c.charge_item_id = new_nbr, c.parent_charge_item_id = request->charge_item_id, c
   .charge_event_act_id = tmp_charge_struct->charge_event_act_id,
   c.charge_event_id = tmp_charge_struct->charge_event_id, c.bill_item_id = tmp_charge_struct->
   bill_item_id, c.order_id = tmp_charge_struct->order_id,
   c.encntr_id = tmp_charge_struct->encntr_id, c.person_id = tmp_charge_struct->person_id, c.payor_id
    = tmp_charge_struct->payor_id,
   c.ord_loc_cd = tmp_charge_struct->ord_loc_cd, c.perf_loc_cd = tmp_charge_struct->perf_loc_cd, c
   .ord_phys_id = tmp_charge_struct->ord_phys_id,
   c.perf_phys_id = tmp_charge_struct->perf_phys_id, c.charge_description = tmp_charge_struct->
   charge_description, c.price_sched_id = tmp_charge_struct->price_sched_id,
   c.item_quantity =
   IF ((request->item_quantity=0)) tmp_charge_struct->item_quantity
   ELSE request->item_quantity
   ENDIF
   , c.item_price =
   IF ((request->item_price=0)) tmp_charge_struct->item_price
   ELSE request->item_price
   ENDIF
   , c.item_extended_price =
   IF ((request->item_quantity=0))
    IF ((request->item_price=0)) (tmp_charge_struct->item_price * tmp_charge_struct->item_quantity)
    ELSE (request->item_price * tmp_charge_struct->item_quantity)
    ENDIF
   ELSE
    IF ((request->item_price=0)) (tmp_charge_struct->item_price * request->item_quantity)
    ELSE (request->item_price * request->item_quantity)
    ENDIF
   ENDIF
   ,
   c.item_allowable = tmp_charge_struct->item_allowable, c.item_copay = tmp_charge_struct->item_copay,
   c.charge_type_cd = tmp_charge_struct->charge_type_cd,
   c.research_acct_id = tmp_charge_struct->research_acct_id, c.suspense_rsn_cd = tmp_charge_struct->
   suspense_rsn_cd, c.reason_comment = tmp_charge_struct->reason_comment,
   c.posted_cd = tmp_charge_struct->posted_cd, c.posted_dt_tm = cnvtdatetime(tmp_charge_struct->
    posted_dt_tm), c.process_flg = 0,
   c.service_dt_tm = cnvtdatetime(tmp_charge_struct->service_dt_tm), c.activity_dt_tm = cnvtdatetime(
    tmp_charge_struct->activity_dt_tm), c.updt_cnt = 0,
   c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.active_ind = 1,
   c.active_status_cd = tmp_charge_struct->active_status_cd, c.active_status_dt_tm = cnvtdatetime(
    sysdate), c.active_status_prsnl_id = reqinfo->updt_id,
   c.beg_effective_dt_tm = cnvtdatetime(tmp_charge_struct->beg_effective_dt_tm), c
   .end_effective_dt_tm = cnvtdatetime(tmp_charge_struct->end_effective_dt_tm), c.adjusted_dt_tm =
   cnvtdatetime(sysdate),
   c.interface_file_id = tmp_charge_struct->interface_file_id, c.tier_group_cd = tmp_charge_struct->
   tier_group_cd, c.def_bill_item_id = tmp_charge_struct->def_bill_item_id,
   c.verify_phys_id = tmp_charge_struct->verify_phys_id, c.gross_price = tmp_charge_struct->
   gross_price, c.discount_amount = tmp_charge_struct->discount_amount,
   c.manual_ind = tmp_charge_struct->manual_ind, c.combine_ind = tmp_charge_struct->combine_ind, c
   .activity_type_cd = tmp_charge_struct->activity_type_cd,
   c.activity_sub_type_cd = tmp_charge_struct->activity_sub_type_cd, c.provider_specialty_cd =
   tmp_charge_struct->provider_specialty_cd, c.admit_type_cd = tmp_charge_struct->admit_type_cd,
   c.bundle_id = tmp_charge_struct->bundle_id, c.department_cd = tmp_charge_struct->department_cd, c
   .institution_cd = tmp_charge_struct->institution_cd,
   c.section_cd = tmp_charge_struct->section_cd, c.subsection_cd = tmp_charge_struct->subsection_cd,
   c.level5_cd = tmp_charge_struct->level5_cd,
   c.med_service_cd = tmp_charge_struct->med_service_cd, c.abn_status_cd = tmp_charge_struct->
   abn_status_cd, c.cost_center_cd = tmp_charge_struct->cost_center_cd,
   c.inst_fin_nbr = tmp_charge_struct->inst_fin_nbr, c.fin_class_cd = tmp_charge_struct->fin_class_cd,
   c.health_plan_id = tmp_charge_struct->health_plan_id,
   c.item_interval_id = tmp_charge_struct->item_interval_id, c.item_list_price = tmp_charge_struct->
   item_list_price, c.item_reimbursement = tmp_charge_struct->item_reimbursement,
   c.list_price_sched_id = tmp_charge_struct->list_price_sched_id, c.payor_type_cd =
   tmp_charge_struct->payor_type_cd, c.epsdt_ind = tmp_charge_struct->epsdt_ind,
   c.ref_phys_id = tmp_charge_struct->ref_phys_id, c.start_dt_tm = cnvtdatetime(tmp_charge_struct->
    start_dt_tm), c.stop_dt_tm = cnvtdatetime(tmp_charge_struct->stop_dt_tm),
   c.alpha_nomen_id = tmp_charge_struct->alpha_nomen_id, c.item_deductible_amt = tmp_charge_struct->
   item_deductible_amt, c.patient_responsibility_flag = tmp_charge_struct->
   patient_responsibility_flag,
   c.original_org_id = tmp_charge_struct->original_org_id, c.original_encntr_id =
   IF (validate(request->charge_item_id,0)=0) tmp_charge_struct->encntr_id
   ELSE
    (SELECT
     c.original_encntr_id
     FROM charge c
     WHERE (c.charge_item_id=request->charge_item_id))
   ENDIF
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  CALL echo(build("CT_ADJUST_PROFIT_CHARGE::new charge created: ",new_nbr))
  SET reply_adjustment->new_charge_item_id = new_nbr
  UPDATE  FROM charge c
   SET c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->
    updt_id,
    c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task
   WHERE (c.charge_item_id=request->charge_item_id)
   WITH nocounter
  ;end update
  IF (curqual > 0)
   CALL echo("CT_CREDIT_PROFIT_CHARGE::Updated old charge successfully!")
  ENDIF
 ENDIF
 CALL echo(build("CT_ADJUST_PROFIT_CHARGE::adding new mod record for new charge_item_id: ",new_nbr))
 FOR (cm_count = 1 TO tmp_charge_mod_struct->charge_mod_qual)
   SET new_mod_nbr = 0.0
   SELECT INTO "nl:"
    temp_var = seq(charge_event_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_mod_nbr = cnvtreal(temp_var)
    WITH format, counter
   ;end select
   INSERT  FROM charge_mod cm
    SET cm.charge_mod_id = new_mod_nbr, cm.charge_item_id = new_nbr, cm.charge_mod_type_cd =
     tmp_charge_mod_struct->charge_mod[cm_count].charge_mod_type_cd,
     cm.field1 = tmp_charge_mod_struct->charge_mod[cm_count].field1, cm.field2 =
     tmp_charge_mod_struct->charge_mod[cm_count].field2, cm.field3 = tmp_charge_mod_struct->
     charge_mod[cm_count].field3,
     cm.field4 = tmp_charge_mod_struct->charge_mod[cm_count].field4, cm.field5 =
     tmp_charge_mod_struct->charge_mod[cm_count].field5, cm.field6 = tmp_charge_mod_struct->
     charge_mod[cm_count].field6,
     cm.field7 = tmp_charge_mod_struct->charge_mod[cm_count].field7, cm.field8 =
     tmp_charge_mod_struct->charge_mod[cm_count].field8, cm.field9 = tmp_charge_mod_struct->
     charge_mod[cm_count].field9,
     cm.field10 = tmp_charge_mod_struct->charge_mod[cm_count].field10, cm.activity_dt_tm =
     cnvtdatetime(sysdate), cm.updt_cnt = 0,
     cm.updt_dt_tm = cnvtdatetime(sysdate), cm.updt_id = reqinfo->updt_id, cm.updt_task = reqinfo->
     updt_task,
     cm.updt_applctx = reqinfo->updt_applctx, cm.active_ind = tmp_charge_mod_struct->charge_mod[
     cm_count].active_ind, cm.active_status_cd = tmp_charge_mod_struct->charge_mod[cm_count].
     active_status_cd,
     cm.active_status_dt_tm = cnvtdatetime(sysdate), cm.active_status_prsnl_id = reqinfo->updt_id, cm
     .beg_effective_dt_tm = cnvtdatetime(tmp_charge_mod_struct->charge_mod[cm_count].
      beg_effective_dt_tm),
     cm.end_effective_dt_tm = cnvtdatetime(tmp_charge_mod_struct->charge_mod[cm_count].
      end_effective_dt_tm), cm.code1_cd = tmp_charge_mod_struct->charge_mod[cm_count].code1_cd, cm
     .nomen_id = tmp_charge_mod_struct->charge_mod[cm_count].nomen_id,
     cm.field1_id = tmp_charge_mod_struct->charge_mod[cm_count].field1_id, cm.field2_id =
     tmp_charge_mod_struct->charge_mod[cm_count].field2_id, cm.field3_id = tmp_charge_mod_struct->
     charge_mod[cm_count].field3_id,
     cm.field4_id = tmp_charge_mod_struct->charge_mod[cm_count].field4_id, cm.field5_id =
     tmp_charge_mod_struct->charge_mod[cm_count].field5_id
    WITH nocounter
   ;end insert
   IF (curqual > 0)
    SET reply_adjustment->charge_mod_qual = tmp_charge_mod_struct->charge_mod_qual
    SET stat = alterlist(reply_adjustment->charge_mods,cm_count)
    SET reply_adjustment->charge_mods[cm_count].charge_mod_id = new_mod_nbr
   ENDIF
 ENDFOR
 IF ((request->process_flg=100))
  SET stat = alterlist(temprequest->charges,1)
  SET temprequest->charges[1].charge_item_id = new_nbr
  CALL echo(build("CT_ADJUST_PROFIT_CHARGE::notifying Profit of newly created charge: ",new_nbr))
  EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",temprequest), replace("REPLY",tempreply)
  CALL echo("CT_ADJUST_PROFIT_CHARGE::back from call to Profit")
 ELSE
  SET nrealtimeind = 0
  SELECT INTO "nl:"
   FROM charge c,
    interface_file i
   PLAN (c
    WHERE (c.charge_item_id=request->charge_item_id))
    JOIN (i
    WHERE i.interface_file_id=c.interface_file_id
     AND i.realtime_ind=1)
   DETAIL
    nrealtimeind = 1
   WITH nocounter
  ;end select
  IF (nrealtimeind=1)
   SET stat = alterlist(temp_interface_req->interface_charge,1)
   SET temp_interface_req->interface_charge[1].charge_item_id = new_nbr
   CALL echo(build("CT_ADJUST_PROFIT_CHARGE::charge is realtime so call interface ",new_nbr))
   EXECUTE afc_post_interface_charge  WITH replace("REQUEST",temp_interface_req)
   CALL echo("CT_ADJUST_PROFIT_CHARGE::back from call to interface")
  ENDIF
 ENDIF
END GO
