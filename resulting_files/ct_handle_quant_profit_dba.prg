CREATE PROGRAM ct_handle_quant_profit:dba
 CALL echo("executing ct_handle_quant_profit")
 FREE SET charge_struct
 RECORD charge_struct(
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
   1 activity_sub_type_cd = f8
   1 provider_specialty_cd = f8
   1 original_org_id = f8
 )
 FREE SET charge_mod_struct
 RECORD charge_mod_struct(
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
   1 charge_qual = i2
   1 charge[*]
     2 charge_item_id = f8
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
 RECORD tempinterfacerequest(
   1 interface_charge[*]
     2 charge_item_id = f8
 )
 SELECT INTO "nl:"
  FROM charge c
  WHERE (c.charge_item_id=request->charge_item_id)
  DETAIL
   charge_struct->charge_item_id = c.charge_item_id, charge_struct->parent_charge_item_id = c
   .parent_charge_item_id, charge_struct->charge_event_act_id = c.charge_event_act_id,
   charge_struct->charge_event_id = c.charge_event_id, charge_struct->bill_item_id = c.bill_item_id,
   charge_struct->order_id = c.order_id,
   charge_struct->encntr_id = c.encntr_id, charge_struct->person_id = c.person_id, charge_struct->
   payor_id = c.payor_id,
   charge_struct->ord_loc_cd = c.ord_loc_cd, charge_struct->perf_loc_cd = c.perf_loc_cd,
   charge_struct->ord_phys_id = c.ord_phys_id,
   charge_struct->perf_phys_id = c.perf_phys_id, charge_struct->charge_description = c
   .charge_description, charge_struct->price_sched_id = c.price_sched_id,
   charge_struct->item_quantity = c.item_quantity, charge_struct->item_price = c.item_price,
   charge_struct->item_extended_price = c.item_extended_price,
   charge_struct->item_allowable = c.item_allowable, charge_struct->item_copay = c.item_copay,
   charge_struct->charge_type_cd = c.charge_type_cd,
   charge_struct->research_acct_id = c.research_acct_id, charge_struct->posted_cd = c.posted_cd,
   charge_struct->posted_dt_tm = cnvtdatetime(c.posted_dt_tm),
   charge_struct->process_flg = c.process_flg, charge_struct->service_dt_tm = cnvtdatetime(c
    .service_dt_tm), charge_struct->activity_dt_tm = cnvtdatetime(c.activity_dt_tm),
   charge_struct->updt_cnt = c.updt_cnt, charge_struct->updt_dt_tm = cnvtdatetime(c.updt_dt_tm),
   charge_struct->updt_id = c.updt_id,
   charge_struct->updt_task = c.updt_task, charge_struct->updt_applctx = c.updt_applctx,
   charge_struct->active_ind = c.active_ind,
   charge_struct->active_status_cd = c.active_status_cd, charge_struct->active_status_dt_tm =
   cnvtdatetime(c.active_status_dt_tm), charge_struct->active_status_prsnl_id = c
   .active_status_prsnl_id,
   charge_struct->beg_effective_dt_tm = cnvtdatetime(c.beg_effective_dt_tm), charge_struct->
   end_effective_dt_tm = cnvtdatetime(c.end_effective_dt_tm), charge_struct->credited_dt_tm =
   cnvtdatetime(c.credited_dt_tm),
   charge_struct->adjusted_dt_tm = cnvtdatetime(c.adjusted_dt_tm), charge_struct->interface_file_id
    = c.interface_file_id, charge_struct->tier_group_cd = c.tier_group_cd,
   charge_struct->def_bill_item_id = c.def_bill_item_id, charge_struct->verify_phys_id = c
   .verify_phys_id, charge_struct->gross_price = c.gross_price,
   charge_struct->discount_amount = c.discount_amount, charge_struct->manual_ind = c.manual_ind,
   charge_struct->combine_ind = c.combine_ind,
   charge_struct->activity_type_cd = c.activity_type_cd, charge_struct->activity_sub_type_cd = c
   .activity_sub_type_cd, charge_struct->provider_specialty_cd = c.provider_specialty_cd,
   charge_struct->admit_type_cd = c.admit_type_cd, charge_struct->bundle_id = c.bundle_id,
   charge_struct->department_cd = c.department_cd,
   charge_struct->institution_cd = c.institution_cd, charge_struct->section_cd = c.section_cd,
   charge_struct->subsection_cd = c.subsection_cd,
   charge_struct->level5_cd = c.level5_cd, charge_struct->med_service_cd = c.med_service_cd,
   charge_struct->abn_status_cd = c.abn_status_cd,
   charge_struct->cost_center_cd = c.cost_center_cd, charge_struct->inst_fin_nbr = c.inst_fin_nbr,
   charge_struct->fin_class_cd = c.fin_class_cd,
   charge_struct->health_plan_id = c.health_plan_id, charge_struct->item_interval_id = c
   .item_interval_id, charge_struct->item_list_price = c.item_list_price,
   charge_struct->item_reimbursement = c.item_reimbursement, charge_struct->list_price_sched_id = c
   .list_price_sched_id, charge_struct->payor_type_cd = c.payor_type_cd,
   charge_struct->epsdt_ind = c.epsdt_ind, charge_struct->ref_phys_id = c.ref_phys_id, charge_struct
   ->start_dt_tm = cnvtdatetime(c.start_dt_tm),
   charge_struct->stop_dt_tm = cnvtdatetime(c.stop_dt_tm), charge_struct->alpha_nomen_id = c
   .alpha_nomen_id, charge_struct->original_org_id = c.original_org_id
  WITH nocounter
 ;end select
 SET count1 = 0
 SELECT INTO "nl:"
  FROM charge_mod cm
  WHERE (cm.charge_item_id=request->charge_item_id)
  DETAIL
   count1 += 1, stat = alterlist(charge_mod_struct->charge_mod,count1), charge_mod_struct->
   charge_mod[count1].charge_item_id = cm.charge_item_id,
   charge_mod_struct->charge_mod[count1].charge_mod_type_cd = cm.charge_mod_type_cd,
   charge_mod_struct->charge_mod[count1].field1 = cm.field1, charge_mod_struct->charge_mod[count1].
   field2 = cm.field2,
   charge_mod_struct->charge_mod[count1].field3 = cm.field3, charge_mod_struct->charge_mod[count1].
   field4 = cm.field4, charge_mod_struct->charge_mod[count1].field5 = cm.field5,
   charge_mod_struct->charge_mod[count1].field6 = cm.field6, charge_mod_struct->charge_mod[count1].
   field7 = cm.field7, charge_mod_struct->charge_mod[count1].field8 = cm.field8,
   charge_mod_struct->charge_mod[count1].field9 = cm.field9, charge_mod_struct->charge_mod[count1].
   field10 = cm.field10, charge_mod_struct->charge_mod[count1].activity_dt_tm = cnvtdatetime(cm
    .activity_dt_tm),
   charge_mod_struct->charge_mod[count1].updt_cnt = cm.updt_cnt, charge_mod_struct->charge_mod[count1
   ].updt_dt_tm = cnvtdatetime(cm.updt_dt_tm), charge_mod_struct->charge_mod[count1].updt_id = cm
   .updt_id,
   charge_mod_struct->charge_mod[count1].updt_task = cm.updt_task, charge_mod_struct->charge_mod[
   count1].updt_applctx = cm.updt_applctx, charge_mod_struct->charge_mod[count1].active_ind = cm
   .active_ind,
   charge_mod_struct->charge_mod[count1].active_status_cd = cm.active_status_cd, charge_mod_struct->
   charge_mod[count1].active_status_prsnl_id = cm.active_status_prsnl_id, charge_mod_struct->
   charge_mod[count1].active_status_dt_tm = cnvtdatetime(cm.active_status_dt_tm),
   charge_mod_struct->charge_mod[count1].beg_effective_dt_tm = cnvtdatetime(cm.beg_effective_dt_tm),
   charge_mod_struct->charge_mod[count1].end_effective_dt_tm = cnvtdatetime(cm.end_effective_dt_tm),
   charge_mod_struct->charge_mod[count1].code1_cd = cm.code1_cd,
   charge_mod_struct->charge_mod[count1].nomen_id = cm.nomen_id, charge_mod_struct->charge_mod[count1
   ].field1_id = cm.field1_id, charge_mod_struct->charge_mod[count1].field2_id = cm.field2_id,
   charge_mod_struct->charge_mod[count1].field3_id = cm.field3_id, charge_mod_struct->charge_mod[
   count1].field4_id = cm.field4_id, charge_mod_struct->charge_mod[count1].field5_id = cm.field5_id
  WITH nocounter
 ;end select
 SET charge_mod_struct->charge_mod_qual = count1
 FOR (intcount = 1 TO 2)
   SET new_nbr = 0.0
   SELECT INTO "nl:"
    temp_var = seq(charge_event_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_nbr = cnvtreal(temp_var)
    WITH format, counter
   ;end select
   IF (intcount=1)
    SET reply_quant->charge_item_id = new_nbr
   ENDIF
   INSERT  FROM charge c
    SET c.charge_item_id = new_nbr, c.parent_charge_item_id = request->charge_item_id, c
     .charge_event_act_id = charge_struct->charge_event_act_id,
     c.charge_event_id = charge_struct->charge_event_id, c.bill_item_id = charge_struct->bill_item_id,
     c.order_id = charge_struct->order_id,
     c.encntr_id = charge_struct->encntr_id, c.person_id = charge_struct->person_id, c.payor_id =
     charge_struct->payor_id,
     c.ord_loc_cd = charge_struct->ord_loc_cd, c.perf_loc_cd = charge_struct->perf_loc_cd, c
     .ord_phys_id = charge_struct->ord_phys_id,
     c.perf_phys_id = charge_struct->perf_phys_id, c.charge_description = charge_struct->
     charge_description, c.price_sched_id = charge_struct->price_sched_id,
     c.item_quantity =
     IF (intcount=1) 1
     ELSE (charge_struct->item_quantity - 1)
     ENDIF
     , c.item_price = charge_struct->item_price, c.item_extended_price =
     IF (intcount=1) charge_struct->item_price
     ELSE ((charge_struct->item_quantity - 1) * charge_struct->item_price)
     ENDIF
     ,
     c.item_allowable = charge_struct->item_allowable, c.item_copay = charge_struct->item_copay, c
     .charge_type_cd = charge_struct->charge_type_cd,
     c.research_acct_id = charge_struct->research_acct_id, c.suspense_rsn_cd = charge_struct->
     suspense_rsn_cd, c.reason_comment = charge_struct->reason_comment,
     c.posted_cd = charge_struct->posted_cd, c.posted_dt_tm = cnvtdatetime(charge_struct->
      posted_dt_tm), c.process_flg = charge_struct->process_flg,
     c.service_dt_tm = cnvtdatetime(charge_struct->service_dt_tm), c.activity_dt_tm = cnvtdatetime(
      charge_struct->activity_dt_tm), c.updt_cnt = 0,
     c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.active_ind = 1,
     c.active_status_cd = charge_struct->active_status_cd, c.active_status_dt_tm = cnvtdatetime(
      sysdate), c.active_status_prsnl_id = reqinfo->updt_id,
     c.beg_effective_dt_tm = cnvtdatetime(charge_struct->beg_effective_dt_tm), c.end_effective_dt_tm
      = cnvtdatetime(charge_struct->end_effective_dt_tm), c.adjusted_dt_tm = cnvtdatetime(sysdate),
     c.interface_file_id = charge_struct->interface_file_id, c.tier_group_cd = charge_struct->
     tier_group_cd, c.def_bill_item_id = charge_struct->def_bill_item_id,
     c.verify_phys_id = charge_struct->verify_phys_id, c.gross_price = charge_struct->gross_price, c
     .discount_amount = charge_struct->discount_amount,
     c.manual_ind = charge_struct->manual_ind, c.combine_ind = charge_struct->combine_ind, c
     .activity_type_cd = charge_struct->activity_type_cd,
     c.activity_sub_type_cd = charge_struct->activity_sub_type_cd, c.provider_specialty_cd =
     charge_struct->provider_specialty_cd, c.admit_type_cd = charge_struct->admit_type_cd,
     c.bundle_id = charge_struct->bundle_id, c.department_cd = charge_struct->department_cd, c
     .institution_cd = charge_struct->institution_cd,
     c.section_cd = charge_struct->section_cd, c.subsection_cd = charge_struct->subsection_cd, c
     .level5_cd = charge_struct->level5_cd,
     c.med_service_cd = charge_struct->med_service_cd, c.abn_status_cd = charge_struct->abn_status_cd,
     c.cost_center_cd = charge_struct->cost_center_cd,
     c.inst_fin_nbr = charge_struct->inst_fin_nbr, c.fin_class_cd = charge_struct->fin_class_cd, c
     .health_plan_id = charge_struct->health_plan_id,
     c.item_interval_id = charge_struct->item_interval_id, c.item_list_price = charge_struct->
     item_list_price, c.item_reimbursement = charge_struct->item_reimbursement,
     c.list_price_sched_id = charge_struct->list_price_sched_id, c.payor_type_cd = charge_struct->
     payor_type_cd, c.epsdt_ind = charge_struct->epsdt_ind,
     c.ref_phys_id = charge_struct->ref_phys_id, c.start_dt_tm = cnvtdatetime(charge_struct->
      start_dt_tm), c.stop_dt_tm = cnvtdatetime(charge_struct->stop_dt_tm),
     c.alpha_nomen_id = charge_struct->alpha_nomen_id, c.original_org_id = charge_struct->
     original_org_id, c.original_encntr_id =
     IF (validate(request->charge_item_id,0)=0) charge_struct->encntr_id
     ELSE
      (SELECT
       c.original_encntr_id
       FROM charge c
       WHERE (c.charge_item_id=request->charge_item_id))
     ENDIF
    WITH nocounter
   ;end insert
   FOR (cm_count = 1 TO charge_mod_struct->charge_mod_qual)
     SET new_mod_nbr = 0.0
     SELECT INTO "nl:"
      temp_var = seq(charge_event_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_mod_nbr = cnvtreal(temp_var)
      WITH format, counter
     ;end select
     INSERT  FROM charge_mod cm
      SET cm.charge_mod_id = new_mod_nbr, cm.charge_item_id = charge_mod_struct->charge_mod[cm_count]
       .charge_item_id, cm.charge_mod_type_cd = charge_mod_struct->charge_mod[cm_count].
       charge_mod_type_cd,
       cm.field1 = charge_mod_struct->charge_mod[cm_count].field1, cm.field2 = charge_mod_struct->
       charge_mod[cm_count].field2, cm.field3 = charge_mod_struct->charge_mod[cm_count].field3,
       cm.field4 = charge_mod_struct->charge_mod[cm_count].field4, cm.field5 = charge_mod_struct->
       charge_mod[cm_count].field5, cm.field6 = charge_mod_struct->charge_mod[cm_count].field6,
       cm.field7 = charge_mod_struct->charge_mod[cm_count].field7, cm.field8 = charge_mod_struct->
       charge_mod[cm_count].field8, cm.field9 = charge_mod_struct->charge_mod[cm_count].field9,
       cm.field10 = charge_mod_struct->charge_mod[cm_count].field10, cm.activity_dt_tm = cnvtdatetime
       (sysdate), cm.updt_cnt = 0,
       cm.updt_dt_tm = cnvtdatetime(sysdate), cm.updt_id = reqinfo->updt_id, cm.updt_task = reqinfo->
       updt_task,
       cm.updt_applctx = reqinfo->updt_applctx, cm.active_ind = charge_mod_struct->charge_mod[
       cm_count].active_ind, cm.active_status_cd = charge_mod_struct->charge_mod[cm_count].
       active_status_cd,
       cm.active_status_dt_tm = cnvtdatetime(sysdate), cm.active_status_prsnl_id = reqinfo->updt_id,
       cm.beg_effective_dt_tm = cnvtdatetime(charge_mod_struct->charge_mod[cm_count].
        beg_effective_dt_tm),
       cm.end_effective_dt_tm = cnvtdatetime(charge_mod_struct->charge_mod[cm_count].
        end_effective_dt_tm), cm.code1_cd = charge_mod_struct->charge_mod[cm_count].code1_cd, cm
       .nomen_id = charge_mod_struct->charge_mod[cm_count].nomen_id,
       cm.field1_id = charge_mod_struct->charge_mod[cm_count].field1_id, cm.field2_id =
       charge_mod_struct->charge_mod[cm_count].field2_id, cm.field3_id = charge_mod_struct->
       charge_mod[cm_count].field3_id,
       cm.field4_id = charge_mod_struct->charge_mod[cm_count].field4_id, cm.field5_id =
       charge_mod_struct->charge_mod[cm_count].field5_id
      WITH nocounter
     ;end insert
   ENDFOR
   IF (intcount=1)
    SET count1 = 0
    SELECT INTO "nl:"
     cm.charge_mod_id
     FROM charge_mod cm
     WHERE (cm.charge_item_id=reply_quant->charge_item_id)
     DETAIL
      count1 += 1, stat = alterlist(reply_quant->charge_mods,count1), reply_quant->charge_mods[count1
      ].charge_mod_id = cm.charge_mod_id
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->process_flg=100))
    SET stat = alterlist(temprequest->charge,1)
    SET temprequest->charge[1].charge_item_id = new_nbr
    EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",temprequest), replace("REPLY",tempreply)
   ELSE
    SET nrealtimeind = 0
    SELECT INTO "nl:"
     FROM charge c,
      interface_file i
     PLAN (c
      WHERE c.charge_item_id=new_nbr)
      JOIN (i
      WHERE i.interface_file_id=c.interface_file_id
       AND i.realtime_ind=1)
     DETAIL
      nrealtimeind = 1
     WITH nocounter
    ;end select
    IF (nrealtimeind=1)
     EXECUTE afc_srv_interface_charge  WITH replace("REQUEST",tempinterfacerequest)
    ENDIF
   ENDIF
 ENDFOR
END GO
