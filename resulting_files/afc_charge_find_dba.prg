CREATE PROGRAM afc_charge_find:dba
 DECLARE versionnbr = vc
 SET versionnbr = "0013"
 CALL echo(build("AFC_CHARGE_FIND Version: ",versionnbr))
 SET afc_charge_find = "CHARGSRV-14536.FT.013"
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 charge_item_count = i4
    1 charge_items[*]
      2 charge_item_id = f8
      2 parent_charge_item_id = f8
      2 charge_event_act_id = f8
      2 charge_event_id = f8
      2 bill_item_id = f8
      2 order_id = f8
      2 encntr_id = f8
      2 person_id = f8
      2 person_name = vc
      2 username = vc
      2 payor_id = f8
      2 ord_loc_cd = f8
      2 perf_loc_cd = f8
      2 perf_loc_disp = vc
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
      2 charge_type_disp = vc
      2 charge_type_mean = vc
      2 research_acct_id = f8
      2 suspense_rsn_cd = f8
      2 reason_comment = vc
      2 posted_cd = f8
      2 posted_dt_tm = dq8
      2 process_flg = i4
      2 service_dt_tm = dq8
      2 activity_dt_tm = dq8
      2 updt_cnt = i4
      2 updt_dt_tm = dq8
      2 updt_id = f8
      2 updt_task = i4
      2 updt_applctx = i4
      2 active_status_dt_tm = dq8
      2 active_status_prsnl_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 credited_dt_tm = dq8
      2 adjusted_dt_tm = dq8
      2 interface_file_id = f8
      2 tier_group_cd = f8
      2 def_bill_item_id = f8
      2 verify_phys_id = f8
      2 gross_price = f8
      2 discount_amount = f8
      2 manual_ind = i2
      2 combine_ind = i2
      2 activity_type_cd = f8
      2 admit_type_cd = f8
      2 bundle_id = f8
      2 department_cd = f8
      2 institution_cd = f8
      2 level5_cd = f8
      2 med_service_cd = f8
      2 section_cd = f8
      2 subsection_cd = f8
      2 abn_status_cd = f8
      2 cost_center_cd = f8
      2 inst_fin_nbr = vc
      2 fin_class_cd = f8
      2 health_plan_id = f8
      2 item_interval_id = f8
      2 item_list_price = f8
      2 item_reimbursement = f8
      2 list_price_sched_id = f8
      2 payor_type_cd = f8
      2 epsdt_ind = i2
      2 ref_phys_id = f8
      2 start_dt_tm = dq8
      2 stop_dt_tm = dq8
      2 alpha_nomen_id = f8
      2 server_process_flag = i2
      2 offset_charge_item_id = f8
      2 item_deductible_amt = f8
      2 patient_responsibility_flag = i2
      2 ext_parent_reference_id = f8
      2 ext_parent_contributor_cd = f8
      2 charge_mod_count = i4
      2 charge_mods[*]
        3 charge_mod_id = f8
        3 charge_mod_type_cd = f8
        3 field1 = vc
        3 field2 = vc
        3 field3 = vc
        3 field4 = vc
        3 field5 = vc
        3 field6 = vc
        3 field7 = vc
        3 field8 = vc
        3 field9 = vc
        3 field10 = vc
        3 field1_id = f8
        3 field2_id = f8
        3 field3_id = f8
        3 field4_id = f8
        3 field5_id = f8
        3 nomen_id = f8
        3 cm1_nbr = f8
        3 activity_dt_tm = dq8
        3 active_ind = i2
        3 code1_cd = f8
        3 updt_cnt = i4
        3 charge_mod_source_cd = f8
        3 active_status_cd = f8
        3 active_status_dt_tm = dq8
        3 active_status_prsnl_id = f8
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
        3 updt_applctx = f8
        3 updt_dt_tm = dq8
        3 updt_id = f8
        3 updt_task = i4
      2 activity_sub_type_cd = f8
      2 provider_specialty_cd = f8
      2 original_org_id = f8
      2 item_price_adj_amt = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE charge_count = i4 WITH public, noconstant(0)
 DECLARE charge_mod_count = i4 WITH public, noconstant(0)
 DECLARE msselecttype = vc WITH noconstant("")
 DECLARE mnactivecharge = i2 WITH protect, noconstant(0)
 DECLARE msstat = vc WITH protect, noconstant("")
 DECLARE msstat2 = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 IF (validate(null_i2,0)=0)
  DECLARE null_i2 = i2 WITH constant(- (1))
 ENDIF
 IF (validate(request->encntr_id)=1)
  IF ((request->encntr_id > 0.0))
   SET msselecttype = "ENCOUNTER"
  ENDIF
 ENDIF
 IF (validate(request->dorderid)=1)
  IF ((request->dorderid > 0.0))
   SET msselecttype = "ORDERID"
   IF ((request->nactiveonly=1))
    SET mnactivecharge = 1
   ELSE
    SET mnactivecharge = 0
   ENDIF
  ENDIF
 ENDIF
 IF (validate(request->charge_items))
  IF (size(request->charge_items,5) > 0)
   SET msselecttype = "BATCH"
  ENDIF
 ENDIF
 IF (msselecttype IN ("ENCOUNTER", "ORDERID", "BATCH"))
  SELECT
   IF (msselecttype="ENCOUNTER")INTO "nl:"
    FROM encounter e,
     charge c,
     charge_mod cm,
     bill_item b,
     person p,
     prsnl ps
    PLAN (e
     WHERE (e.encntr_id=request->encntr_id)
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND e.active_ind=true)
     JOIN (c
     WHERE c.encntr_id=e.encntr_id)
     JOIN (b
     WHERE b.bill_item_id=c.bill_item_id)
     JOIN (cm
     WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id)) )
     JOIN (p
     WHERE p.person_id=c.person_id)
     JOIN (ps
     WHERE (ps.person_id= Outerjoin(c.updt_id)) )
   ELSEIF (msselecttype="ORDERID")INTO "nl:"
    FROM encounter e,
     charge c,
     charge_mod cm,
     bill_item b,
     person p,
     prsnl ps
    PLAN (c
     WHERE (c.order_id=request->dorderid)
      AND c.active_ind IN (1, mnactivecharge))
     JOIN (e
     WHERE e.encntr_id=c.encntr_id
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND e.active_ind=true)
     JOIN (b
     WHERE b.bill_item_id=c.bill_item_id)
     JOIN (cm
     WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id)) )
     JOIN (p
     WHERE p.person_id=c.person_id)
     JOIN (ps
     WHERE (ps.person_id= Outerjoin(c.updt_id)) )
   ELSEIF (msselecttype="BATCH")INTO "nl:"
    FROM (dummyt d1  WITH seq = size(request->charge_items,5)),
     encounter e,
     charge c,
     charge_mod cm,
     bill_item b,
     person p,
     prsnl ps
    PLAN (d1)
     JOIN (c
     WHERE (c.charge_item_id=request->charge_items[d1.seq].charge_item_id)
      AND c.active_ind=true)
     JOIN (e
     WHERE e.encntr_id=c.encntr_id
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND e.active_ind=true)
     JOIN (b
     WHERE b.bill_item_id=c.bill_item_id)
     JOIN (cm
     WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id)) )
     JOIN (p
     WHERE p.person_id=c.person_id)
     JOIN (ps
     WHERE (ps.person_id= Outerjoin(c.updt_id)) )
   ELSE
   ENDIF
   ORDER BY c.charge_item_id
   HEAD c.charge_item_id
    charge_mod_count = 0, charge_count += 1, stat = alterlist(reply->charge_items,charge_count),
    reply->charge_items[charge_count].charge_item_id = c.charge_item_id, reply->charge_items[
    charge_count].parent_charge_item_id = c.parent_charge_item_id, reply->charge_items[charge_count].
    charge_event_act_id = c.charge_event_act_id,
    reply->charge_items[charge_count].charge_event_id = c.charge_event_id, reply->charge_items[
    charge_count].bill_item_id = c.bill_item_id, reply->charge_items[charge_count].order_id = c
    .order_id,
    reply->charge_items[charge_count].encntr_id = c.encntr_id, reply->charge_items[charge_count].
    person_id = c.person_id, reply->charge_items[charge_count].payor_id = c.payor_id,
    reply->charge_items[charge_count].ord_loc_cd = c.ord_loc_cd, reply->charge_items[charge_count].
    perf_loc_cd = c.perf_loc_cd, msstat = assign(validate(reply->charge_items[charge_count].
      perf_loc_disp,""),uar_get_code_display(c.perf_loc_cd)),
    reply->charge_items[charge_count].ord_phys_id = c.ord_phys_id, reply->charge_items[charge_count].
    perf_phys_id = c.perf_phys_id, reply->charge_items[charge_count].charge_description = c
    .charge_description,
    reply->charge_items[charge_count].price_sched_id = c.price_sched_id, reply->charge_items[
    charge_count].item_quantity = c.item_quantity, reply->charge_items[charge_count].item_price = c
    .item_price,
    reply->charge_items[charge_count].item_extended_price = c.item_extended_price, reply->
    charge_items[charge_count].item_allowable = c.item_allowable, reply->charge_items[charge_count].
    item_copay = c.item_copay,
    reply->charge_items[charge_count].charge_type_cd = c.charge_type_cd, msstat = assign(validate(
      reply->charge_items[charge_count].charge_type_disp,""),uar_get_code_display(c.charge_type_cd)),
    msstat = assign(validate(reply->charge_items[charge_count].charge_type_mean,""),
     uar_get_code_meaning(c.charge_type_cd)),
    reply->charge_items[charge_count].research_acct_id = c.research_acct_id, reply->charge_items[
    charge_count].suspense_rsn_cd = c.suspense_rsn_cd, reply->charge_items[charge_count].
    reason_comment = c.reason_comment,
    reply->charge_items[charge_count].posted_cd = c.posted_cd, reply->charge_items[charge_count].
    posted_dt_tm = cnvtdatetime(c.posted_dt_tm), reply->charge_items[charge_count].process_flg = c
    .process_flg,
    reply->charge_items[charge_count].service_dt_tm = cnvtdatetime(c.service_dt_tm), reply->
    charge_items[charge_count].activity_dt_tm = cnvtdatetime(c.activity_dt_tm), reply->charge_items[
    charge_count].updt_cnt = c.updt_cnt,
    reply->charge_items[charge_count].active_ind = c.active_ind, reply->charge_items[charge_count].
    active_status_cd = c.active_status_cd, reply->charge_items[charge_count].beg_effective_dt_tm =
    cnvtdatetime(c.beg_effective_dt_tm),
    reply->charge_items[charge_count].end_effective_dt_tm = cnvtdatetime(c.end_effective_dt_tm),
    reply->charge_items[charge_count].credited_dt_tm = cnvtdatetime(c.credited_dt_tm), reply->
    charge_items[charge_count].adjusted_dt_tm = cnvtdatetime(c.adjusted_dt_tm),
    reply->charge_items[charge_count].interface_file_id = c.interface_file_id, reply->charge_items[
    charge_count].tier_group_cd = c.tier_group_cd, reply->charge_items[charge_count].def_bill_item_id
     = c.def_bill_item_id,
    reply->charge_items[charge_count].verify_phys_id = c.verify_phys_id, reply->charge_items[
    charge_count].gross_price = c.gross_price, reply->charge_items[charge_count].discount_amount = c
    .discount_amount,
    reply->charge_items[charge_count].manual_ind = c.manual_ind, reply->charge_items[charge_count].
    combine_ind = c.combine_ind, reply->charge_items[charge_count].activity_type_cd = c
    .activity_type_cd,
    msstat2 = assign(validate(reply->charge_items[charge_count].activity_sub_type_cd,0.0),c
     .activity_sub_type_cd), msstat2 = assign(validate(reply->charge_items[charge_count].
      provider_specialty_cd,0.0),c.provider_specialty_cd), reply->charge_items[charge_count].
    admit_type_cd = c.admit_type_cd,
    reply->charge_items[charge_count].bundle_id = c.bundle_id, reply->charge_items[charge_count].
    department_cd = c.department_cd, reply->charge_items[charge_count].institution_cd = c
    .institution_cd,
    reply->charge_items[charge_count].level5_cd = c.level5_cd, reply->charge_items[charge_count].
    med_service_cd = c.med_service_cd, reply->charge_items[charge_count].section_cd = c.section_cd,
    reply->charge_items[charge_count].subsection_cd = c.subsection_cd, reply->charge_items[
    charge_count].abn_status_cd = c.abn_status_cd, reply->charge_items[charge_count].cost_center_cd
     = c.cost_center_cd,
    reply->charge_items[charge_count].inst_fin_nbr = c.inst_fin_nbr, reply->charge_items[charge_count
    ].fin_class_cd = c.fin_class_cd, reply->charge_items[charge_count].health_plan_id = c
    .health_plan_id,
    reply->charge_items[charge_count].item_interval_id = c.item_interval_id, reply->charge_items[
    charge_count].item_list_price = c.item_list_price, reply->charge_items[charge_count].
    item_reimbursement = c.item_reimbursement,
    reply->charge_items[charge_count].list_price_sched_id = c.list_price_sched_id, reply->
    charge_items[charge_count].payor_type_cd = c.payor_type_cd, reply->charge_items[charge_count].
    epsdt_ind = c.epsdt_ind,
    reply->charge_items[charge_count].ref_phys_id = c.ref_phys_id, reply->charge_items[charge_count].
    start_dt_tm = cnvtdatetime(c.start_dt_tm), reply->charge_items[charge_count].stop_dt_tm =
    cnvtdatetime(c.stop_dt_tm),
    reply->charge_items[charge_count].alpha_nomen_id = c.alpha_nomen_id, reply->charge_items[
    charge_count].server_process_flag = c.server_process_flag, reply->charge_items[charge_count].
    offset_charge_item_id = c.offset_charge_item_id,
    reply->charge_items[charge_count].item_deductible_amt = c.item_deductible_amt, reply->
    charge_items[charge_count].patient_responsibility_flag = c.patient_responsibility_flag, stat =
    assign(validate(reply->charge_items[charge_count].original_org_id),c.original_org_id),
    stat = assign(validate(reply->charge_items[charge_count].item_price_adj_amt),c.item_price_adj_amt
     ), reply->charge_items[charge_count].ext_parent_reference_id = b.ext_parent_reference_id, reply
    ->charge_items[charge_count].ext_parent_contributor_cd = b.ext_parent_contributor_cd,
    reply->charge_items[charge_count].person_name = p.name_full_formatted, reply->charge_items[
    charge_count].username = ps.username
   DETAIL
    IF (cm.charge_mod_id > 0)
     charge_mod_count += 1, stat = alterlist(reply->charge_items[charge_count].charge_mods,
      charge_mod_count), reply->charge_items[charge_count].charge_mods[charge_mod_count].
     charge_mod_id = cm.charge_mod_id,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].charge_mod_type_cd = cm
     .charge_mod_type_cd, reply->charge_items[charge_count].charge_mods[charge_mod_count].field1 = cm
     .field1, reply->charge_items[charge_count].charge_mods[charge_mod_count].field2 = cm.field2,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].field3 = cm.field3, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field4 = cm.field4, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field5 = cm.field5,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].field6 = cm.field6, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field7 = cm.field7, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field8 = cm.field8,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].field9 = cm.field9, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field10 = cm.field10, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field1_id = cm.field1_id,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].field2_id = cm.field2_id, reply
     ->charge_items[charge_count].charge_mods[charge_mod_count].field3_id = cm.field3_id, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field4_id = cm.field4_id,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].field5_id = cm.field5_id, reply
     ->charge_items[charge_count].charge_mods[charge_mod_count].nomen_id = cm.nomen_id, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].cm1_nbr = cm.cm1_nbr,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].activity_dt_tm = cm
     .activity_dt_tm, stat = assign(validate(reply->charge_items[charge_count].charge_mods[
       charge_mod_count].code1_cd),cm.code1_cd), stat = assign(validate(reply->charge_items[
       charge_count].charge_mods[charge_mod_count].updt_cnt),cm.updt_cnt),
     stat = assign(validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].
       charge_mod_source_cd),cm.charge_mod_source_cd), stat = assign(validate(reply->charge_items[
       charge_count].charge_mods[charge_mod_count].active_status_cd),cm.active_status_cd), stat =
     assign(validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].
       active_status_dt_tm),cm.active_status_dt_tm),
     stat = assign(validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].
       active_status_prsnl_id),cm.active_status_prsnl_id), stat = assign(validate(reply->
       charge_items[charge_count].charge_mods[charge_mod_count].beg_effective_dt_tm),cm
      .beg_effective_dt_tm), stat = assign(validate(reply->charge_items[charge_count].charge_mods[
       charge_mod_count].end_effective_dt_tm),cm.end_effective_dt_tm),
     stat = assign(validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].
       updt_applctx),cm.updt_applctx), stat = assign(validate(reply->charge_items[charge_count].
       charge_mods[charge_mod_count].updt_dt_tm),cm.updt_dt_tm), stat = assign(validate(reply->
       charge_items[charge_count].charge_mods[charge_mod_count].updt_id),cm.updt_id),
     stat = assign(validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].updt_task
       ),cm.updt_task)
     IF (validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].active_ind,null_i2)
      != null_i2)
      reply->charge_items[charge_count].charge_mods[charge_mod_count].active_ind = cm.active_ind
     ENDIF
    ENDIF
    reply->charge_items[charge_count].charge_mod_count = size(reply->charge_items[charge_count].
     charge_mods,5)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM charge c,
    charge_mod cm,
    person p,
    prsnl ps
   PLAN (c
    WHERE (c.charge_item_id=request->charge_item_id))
    JOIN (cm
    WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id)) )
    JOIN (p
    WHERE p.person_id=c.person_id)
    JOIN (ps
    WHERE (ps.person_id= Outerjoin(c.updt_id)) )
   ORDER BY c.charge_item_id
   HEAD c.charge_item_id
    charge_mod_count = 0, charge_count += 1, stat = alterlist(reply->charge_items,charge_count),
    reply->charge_items[charge_count].charge_item_id = c.charge_item_id, reply->charge_items[
    charge_count].parent_charge_item_id = c.parent_charge_item_id, reply->charge_items[charge_count].
    charge_event_act_id = c.charge_event_act_id,
    reply->charge_items[charge_count].charge_event_id = c.charge_event_id, reply->charge_items[
    charge_count].bill_item_id = c.bill_item_id, reply->charge_items[charge_count].order_id = c
    .order_id,
    reply->charge_items[charge_count].encntr_id = c.encntr_id, reply->charge_items[charge_count].
    person_id = c.person_id, reply->charge_items[charge_count].payor_id = c.payor_id,
    reply->charge_items[charge_count].ord_loc_cd = c.ord_loc_cd, reply->charge_items[charge_count].
    perf_loc_cd = c.perf_loc_cd, reply->charge_items[charge_count].ord_phys_id = c.ord_phys_id,
    reply->charge_items[charge_count].perf_phys_id = c.perf_phys_id, reply->charge_items[charge_count
    ].charge_description = c.charge_description, reply->charge_items[charge_count].price_sched_id = c
    .price_sched_id,
    reply->charge_items[charge_count].item_quantity = c.item_quantity, reply->charge_items[
    charge_count].item_price = c.item_price, reply->charge_items[charge_count].item_extended_price =
    c.item_extended_price,
    reply->charge_items[charge_count].item_allowable = c.item_allowable, reply->charge_items[
    charge_count].item_copay = c.item_copay, reply->charge_items[charge_count].charge_type_cd = c
    .charge_type_cd,
    reply->charge_items[charge_count].research_acct_id = c.research_acct_id, reply->charge_items[
    charge_count].suspense_rsn_cd = c.suspense_rsn_cd, reply->charge_items[charge_count].
    reason_comment = c.reason_comment,
    reply->charge_items[charge_count].posted_cd = c.posted_cd, reply->charge_items[charge_count].
    posted_dt_tm = cnvtdatetime(c.posted_dt_tm), reply->charge_items[charge_count].process_flg = c
    .process_flg,
    reply->charge_items[charge_count].service_dt_tm = cnvtdatetime(c.service_dt_tm), reply->
    charge_items[charge_count].activity_dt_tm = cnvtdatetime(c.activity_dt_tm), reply->charge_items[
    charge_count].updt_cnt = c.updt_cnt,
    reply->charge_items[charge_count].active_ind = c.active_ind, reply->charge_items[charge_count].
    active_status_cd = c.active_status_cd, reply->charge_items[charge_count].beg_effective_dt_tm =
    cnvtdatetime(c.beg_effective_dt_tm),
    reply->charge_items[charge_count].end_effective_dt_tm = cnvtdatetime(c.end_effective_dt_tm),
    reply->charge_items[charge_count].credited_dt_tm = cnvtdatetime(c.credited_dt_tm), reply->
    charge_items[charge_count].adjusted_dt_tm = cnvtdatetime(c.adjusted_dt_tm),
    reply->charge_items[charge_count].interface_file_id = c.interface_file_id, reply->charge_items[
    charge_count].tier_group_cd = c.tier_group_cd, reply->charge_items[charge_count].def_bill_item_id
     = c.def_bill_item_id,
    reply->charge_items[charge_count].verify_phys_id = c.verify_phys_id, reply->charge_items[
    charge_count].gross_price = c.gross_price, reply->charge_items[charge_count].discount_amount = c
    .discount_amount,
    reply->charge_items[charge_count].manual_ind = c.manual_ind, reply->charge_items[charge_count].
    combine_ind = c.combine_ind, reply->charge_items[charge_count].activity_type_cd = c
    .activity_type_cd,
    msstat2 = assign(validate(reply->charge_items[charge_count].activity_sub_type_cd,0.0),c
     .activity_sub_type_cd), msstat2 = assign(validate(reply->charge_items[charge_count].
      provider_specialty_cd,0.0),c.provider_specialty_cd), reply->charge_items[charge_count].
    admit_type_cd = c.admit_type_cd,
    reply->charge_items[charge_count].bundle_id = c.bundle_id, reply->charge_items[charge_count].
    department_cd = c.department_cd, reply->charge_items[charge_count].institution_cd = c
    .institution_cd,
    reply->charge_items[charge_count].level5_cd = c.level5_cd, reply->charge_items[charge_count].
    med_service_cd = c.med_service_cd, reply->charge_items[charge_count].section_cd = c.section_cd,
    reply->charge_items[charge_count].subsection_cd = c.subsection_cd, reply->charge_items[
    charge_count].abn_status_cd = c.abn_status_cd, reply->charge_items[charge_count].cost_center_cd
     = c.cost_center_cd,
    reply->charge_items[charge_count].inst_fin_nbr = c.inst_fin_nbr, reply->charge_items[charge_count
    ].fin_class_cd = c.fin_class_cd, reply->charge_items[charge_count].health_plan_id = c
    .health_plan_id,
    reply->charge_items[charge_count].item_interval_id = c.item_interval_id, reply->charge_items[
    charge_count].item_list_price = c.item_list_price, reply->charge_items[charge_count].
    item_reimbursement = c.item_reimbursement,
    reply->charge_items[charge_count].list_price_sched_id = c.list_price_sched_id, reply->
    charge_items[charge_count].payor_type_cd = c.payor_type_cd, reply->charge_items[charge_count].
    epsdt_ind = c.epsdt_ind,
    reply->charge_items[charge_count].ref_phys_id = c.ref_phys_id, reply->charge_items[charge_count].
    start_dt_tm = cnvtdatetime(c.start_dt_tm), reply->charge_items[charge_count].stop_dt_tm =
    cnvtdatetime(c.stop_dt_tm),
    reply->charge_items[charge_count].alpha_nomen_id = c.alpha_nomen_id, reply->charge_items[
    charge_count].server_process_flag = c.server_process_flag, reply->charge_items[charge_count].
    offset_charge_item_id = c.offset_charge_item_id,
    reply->charge_items[charge_count].item_deductible_amt = c.item_deductible_amt, reply->
    charge_items[charge_count].patient_responsibility_flag = c.patient_responsibility_flag, stat =
    assign(validate(reply->charge_items[charge_count].original_org_id),c.original_org_id),
    stat = assign(validate(reply->charge_items[charge_count].item_price_adj_amt),c.item_price_adj_amt
     ), reply->charge_items[charge_count].person_name = p.name_full_formatted, reply->charge_items[
    charge_count].username = ps.username
   DETAIL
    IF (cm.charge_mod_id > 0)
     charge_mod_count += 1, stat = alterlist(reply->charge_items[charge_count].charge_mods,
      charge_mod_count), reply->charge_items[charge_count].charge_mods[charge_mod_count].
     charge_mod_id = cm.charge_mod_id,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].charge_mod_type_cd = cm
     .charge_mod_type_cd, reply->charge_items[charge_count].charge_mods[charge_mod_count].field1 = cm
     .field1, reply->charge_items[charge_count].charge_mods[charge_mod_count].field2 = cm.field2,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].field3 = cm.field3, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field4 = cm.field4, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field5 = cm.field5,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].field6 = cm.field6, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field7 = cm.field7, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field8 = cm.field8,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].field9 = cm.field9, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field10 = cm.field10, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field1_id = cm.field1_id,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].field2_id = cm.field2_id, reply
     ->charge_items[charge_count].charge_mods[charge_mod_count].field3_id = cm.field3_id, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].field4_id = cm.field4_id,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].field5_id = cm.field5_id, reply
     ->charge_items[charge_count].charge_mods[charge_mod_count].nomen_id = cm.nomen_id, reply->
     charge_items[charge_count].charge_mods[charge_mod_count].cm1_nbr = cm.cm1_nbr,
     reply->charge_items[charge_count].charge_mods[charge_mod_count].activity_dt_tm = cm
     .activity_dt_tm, stat = assign(validate(reply->charge_items[charge_count].charge_mods[
       charge_mod_count].code1_cd),cm.code1_cd), stat = assign(validate(reply->charge_items[
       charge_count].charge_mods[charge_mod_count].updt_cnt),cm.updt_cnt),
     stat = assign(validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].
       charge_mod_source_cd),cm.charge_mod_source_cd), stat = assign(validate(reply->charge_items[
       charge_count].charge_mods[charge_mod_count].active_status_cd),cm.active_status_cd), stat =
     assign(validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].
       active_status_dt_tm),cm.active_status_dt_tm),
     stat = assign(validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].
       active_status_prsnl_id),cm.active_status_prsnl_id), stat = assign(validate(reply->
       charge_items[charge_count].charge_mods[charge_mod_count].beg_effective_dt_tm),cm
      .beg_effective_dt_tm), stat = assign(validate(reply->charge_items[charge_count].charge_mods[
       charge_mod_count].end_effective_dt_tm),cm.end_effective_dt_tm),
     stat = assign(validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].
       updt_applctx),cm.updt_applctx), stat = assign(validate(reply->charge_items[charge_count].
       charge_mods[charge_mod_count].updt_dt_tm),cm.updt_dt_tm), stat = assign(validate(reply->
       charge_items[charge_count].charge_mods[charge_mod_count].updt_id),cm.updt_id),
     stat = assign(validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].updt_task
       ),cm.updt_task)
     IF (validate(reply->charge_items[charge_count].charge_mods[charge_mod_count].active_ind,null_i2)
      != null_i2)
      reply->charge_items[charge_count].charge_mods[charge_mod_count].active_ind = cm.active_ind
     ENDIF
    ENDIF
    reply->charge_items[charge_count].charge_mod_count = size(reply->charge_items[charge_count].
     charge_mods,5)
   WITH nocounter
  ;end select
 ENDIF
#end_program
 IF (charge_count > 0)
  SET reply->status_data.status = "S"
  SET reply->charge_item_count = size(reply->charge_items,5)
 ELSE
  SET reply->status_data.status = "F"
  SET reply->charge_item_count = 0
  SET stat = alterlist(reply->charge_items,0)
 ENDIF
END GO
