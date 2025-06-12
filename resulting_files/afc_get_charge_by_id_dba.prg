CREATE PROGRAM afc_get_charge_by_id:dba
 SET afc_get_charge_by_id_vrsn = 000
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 charge_item_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 abn_status_cd = f8
     2 department_cd = f8
     2 institution_cd = f8
     2 item_extended_price = f8
     2 item_price = f8
     2 item_quantity = f8
     2 level5_cd = f8
     2 ord_phys_id = f8
     2 perf_loc_cd = f8
     2 reason_comment = vc
     2 research_acct_id = f8
     2 section_cd = f8
     2 service_dt_tm = dq8
     2 subsection_cd = f8
     2 suspense_reason_cd = f8
     2 user_defined_field = vc
     2 verify_phys_id = f8
     2 activity_type_cd = f8
     2 adjusted_dt_tm = dq8
     2 charge_description = vc
     2 charge_type_cd = f8
     2 cost_center_cd = f8
     2 credited_dt_tm = dq8
     2 encntr_id = f8
     2 perf_phys_id = f8
     2 process_flg = i4
     2 ref_phys_id = f8
     2 tier_group_cd = f8
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 charge_event_act_id = f8
     2 activity_dt_tm = dq8
     2 bundle_id = f8
     2 combine_ind = i2
     2 def_bill_item_id = f8
     2 discount_amount = f8
     2 epsdt_ind = i2
     2 fin_class_cd = f8
     2 gross_price = f8
     2 health_plan_id = f8
     2 inst_fin_nbr = c50
     2 interface_file_id = f8
     2 item_allowable = f8
     2 item_copay = f8
     2 item_interval_id = f8
     2 item_list_price = f8
     2 item_reimbursement = f8
     2 list_price_sched_id = f8
     2 manual_ind = i2
     2 med_service_cd = f8
     2 ord_loc_cd = f8
     2 ord_id = f8
     2 parent_charge_item_id = f8
     2 payor_id = f8
     2 payor_type_cd = f8
     2 person_id = f8
     2 posted_cd = f8
     2 posted_dt_tm = dq8
     2 price_sched_id = f8
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 udf_charge_mod_id = f8
     2 diagnosis[*]
       3 charge_mod_id = f8
       3 nomen_entity_reltn_id = f8
       3 charge_mod_type_cd = f8
       3 field1_id = f8
       3 field3_id = f8
       3 field2_id = i2
     2 service[*]
       3 charge_mod_id = f8
       3 nomen_entity_reltn_id = f8
       3 charge_mod_type_cd = f8
       3 field1_id = f8
       3 nomen_id = f8
       3 field2_id = i2
       3 field7 = vc
     2 modifier[*]
       3 charge_mod_id = f8
       3 charge_mod_type_cd = f8
       3 field1_id = f8
       3 field3_id = f8
       3 field2_id = i2
     2 revenue[*]
       3 charge_mod_id = f8
       3 charge_mod_type_cd = f8
       3 field1_id = f8
       3 field3_id = f8
       3 field2_id = i2
     2 cdm[*]
       3 charge_mod_id = f8
       3 charge_mod_type_cd = f8
       3 field1_id = f8
       3 field6 = vc
       3 field7 = vc
       3 field2_id = i2
     2 suspense_reason[*]
       3 charge_mod_id = f8
       3 charge_mod_type_cd = f8
       3 field1_id = f8
       3 field2_id = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE udf13019 = f8 WITH noconstant(0.0)
 DECLARE diag14002 = f8 WITH noconstant(0.0)
 DECLARE servhcpcs14002 = f8 WITH noconstant(0.0)
 DECLARE servcpt414002 = f8 WITH noconstant(0.0)
 DECLARE servproccode14002 = f8 WITH noconstant(0.0)
 DECLARE mod14002 = f8 WITH noconstant(0.0)
 DECLARE rev14002 = f8 WITH noconstant(0.0)
 DECLARE cdm14002 = f8 WITH noconstant(0.0)
 DECLARE suspreason13019 = f8 WITH noconstant(0.0)
 DECLARE lcount = i4 WITH noconstant(0)
 DECLARE ldiagnosiscnt = i4 WITH noconstant(0)
 DECLARE lservicecnt = i4 WITH noconstant(0)
 DECLARE lmodifiercnt = i4 WITH noconstant(0)
 DECLARE lrevenuecnt = i4 WITH noconstant(0)
 DECLARE lcdmcnt = i4 WITH noconstant(0)
 DECLARE lsuspreasonscnt = i4 WITH noconstant(0)
 SET stat = uar_get_meaning_by_codeset(13019,"USER DEF",1,udf13019)
 SET stat = uar_get_meaning_by_codeset(14002,"ICD9",1,diag14002)
 SET stat = uar_get_meaning_by_codeset(14002,"HCPCS",1,servhcpcs14002)
 SET stat = uar_get_meaning_by_codeset(14002,"CPT4",1,servcpt414002)
 SET stat = uar_get_meaning_by_codeset(14002,"PROCCODE",1,servproccode14002)
 SET stat = uar_get_meaning_by_codeset(14002,"MODIFIER",1,mod14002)
 SET stat = uar_get_meaning_by_codeset(14002,"REVENUE",1,rev14002)
 SET stat = uar_get_meaning_by_codeset(14002,"CDM_SCHED",1,cdm14002)
 SET stat = uar_get_meaning_by_codeset(13019,"SUSPENSE",1,suspreason13019)
 IF ((request->charge_item_ind=true)
  AND (request->diagnosis_ind=false)
  AND (request->service_ind=false)
  AND (request->modifier_ind=false)
  AND (request->revenue_ind=false)
  AND (request->cdm_ind=false)
  AND (request->suspense_ind=false))
  SELECT INTO "Nl:"
   FROM (dummyt d  WITH seq = size(request->qual,5)),
    charge c,
    charge_mod cm
   PLAN (d)
    JOIN (c
    WHERE (c.charge_item_id=request->qual[d.seq].charge_item_id)
     AND c.active_ind=1)
    JOIN (cm
    WHERE outerjoin(c.charge_item_id)=cm.charge_item_id
     AND outerjoin(1)=cm.active_ind
     AND outerjoin(udf13019)=cm.charge_mod_type_cd
     AND outerjoin("USERDEFINEFIELD")=trim(cm.field6,3))
   ORDER BY c.charge_item_id DESC
   DETAIL
    lcount = (lcount+ 1), stat = alterlist(reply->qual,lcount), reply->qual[lcount].charge_item_id =
    c.charge_item_id,
    reply->qual[lcount].charge_event_id = c.charge_event_id, reply->qual[lcount].bill_item_id = c
    .bill_item_id, reply->qual[lcount].abn_status_cd = c.abn_status_cd,
    reply->qual[lcount].department_cd = c.department_cd, reply->qual[lcount].institution_cd = c
    .institution_cd, reply->qual[lcount].item_extended_price = c.item_extended_price,
    reply->qual[lcount].item_price = c.item_price, reply->qual[lcount].item_quantity = c
    .item_quantity, reply->qual[lcount].level5_cd = c.level5_cd,
    reply->qual[lcount].ord_phys_id = c.ord_phys_id, reply->qual[lcount].perf_loc_cd = c.perf_loc_cd,
    reply->qual[lcount].reason_comment = trim(c.reason_comment,3),
    reply->qual[lcount].research_acct_id = c.research_acct_id, reply->qual[lcount].section_cd = c
    .section_cd, reply->qual[lcount].service_dt_tm = c.service_dt_tm,
    reply->qual[lcount].subsection_cd = c.subsection_cd, reply->qual[lcount].suspense_reason_cd = c
    .suspense_rsn_cd, reply->qual[lcount].verify_phys_id = c.verify_phys_id,
    reply->qual[lcount].activity_type_cd = c.activity_type_cd, reply->qual[lcount].adjusted_dt_tm = c
    .adjusted_dt_tm, reply->qual[lcount].charge_description = c.charge_description,
    reply->qual[lcount].charge_type_cd = c.charge_type_cd, reply->qual[lcount].cost_center_cd = c
    .cost_center_cd, reply->qual[lcount].credited_dt_tm = c.credited_dt_tm,
    reply->qual[lcount].encntr_id = c.encntr_id, reply->qual[lcount].perf_phys_id = c.perf_phys_id,
    reply->qual[lcount].process_flg = c.process_flg,
    reply->qual[lcount].ref_phys_id = c.ref_phys_id, reply->qual[lcount].tier_group_cd = c
    .tier_group_cd, reply->qual[lcount].updt_id = c.updt_id,
    reply->qual[lcount].updt_dt_tm = c.updt_dt_tm, reply->qual[lcount].charge_event_act_id = c
    .charge_event_act_id, reply->qual[lcount].activity_dt_tm = c.activity_dt_tm,
    reply->qual[lcount].bundle_id = c.bundle_id, reply->qual[lcount].combine_ind = c.combine_ind,
    reply->qual[lcount].def_bill_item_id = c.def_bill_item_id,
    reply->qual[lcount].discount_amount = c.discount_amount, reply->qual[lcount].epsdt_ind = c
    .epsdt_ind, reply->qual[lcount].fin_class_cd = c.fin_class_cd,
    reply->qual[lcount].gross_price = c.gross_price, reply->qual[lcount].health_plan_id = c
    .health_plan_id, reply->qual[lcount].inst_fin_nbr = trim(c.inst_fin_nbr,3),
    reply->qual[lcount].interface_file_id = c.interface_file_id, reply->qual[lcount].item_allowable
     = c.item_allowable, reply->qual[lcount].item_copay = c.item_copay,
    reply->qual[lcount].item_interval_id = c.item_interval_id, reply->qual[lcount].item_list_price =
    c.item_list_price, reply->qual[lcount].item_reimbursement = c.item_reimbursement,
    reply->qual[lcount].list_price_sched_id = c.list_price_sched_id, reply->qual[lcount].manual_ind
     = c.manual_ind, reply->qual[lcount].med_service_cd = c.med_service_cd,
    reply->qual[lcount].ord_loc_cd = c.ord_loc_cd, reply->qual[lcount].ord_id = c.order_id, reply->
    qual[lcount].parent_charge_item_id = c.parent_charge_item_id,
    reply->qual[lcount].payor_id = c.payor_id, reply->qual[lcount].payor_type_cd = c.payor_type_cd,
    reply->qual[lcount].person_id = c.person_id,
    reply->qual[lcount].posted_cd = c.posted_cd, reply->qual[lcount].posted_dt_tm = c.posted_dt_tm,
    reply->qual[lcount].price_sched_id = c.price_sched_id,
    reply->qual[lcount].start_dt_tm = c.start_dt_tm, reply->qual[lcount].stop_dt_tm = c.stop_dt_tm,
    reply->qual[lcount].user_defined_field = trim(cm.field7,3),
    reply->qual[lcount].udf_charge_mod_id = cm.charge_mod_id
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   EXECUTE pft_log "Afc_Get_Charge_By_Id", "Unable To Retrieve Any Charge Items", 1
   SET reply->status_data.status = "Z"
   GO TO exitscript
  ENDIF
 ELSEIF ((request->charge_item_ind=true)
  AND (((request->diagnosis_ind=true)) OR ((((request->service_ind=true)) OR ((((request->
 modifier_ind=true)) OR ((((request->revenue_ind=true)) OR ((((request->cdm_ind=true)) OR ((request->
 suspense_ind=true))) )) )) )) )) )
  SELECT INTO "Nl:"
   FROM (dummyt d  WITH seq = size(request->qual,5)),
    charge c,
    charge_mod cm,
    nomen_entity_reltn ner
   PLAN (d)
    JOIN (c
    WHERE (c.charge_item_id=request->qual[d.seq].charge_item_id)
     AND c.active_ind=1)
    JOIN (cm
    WHERE outerjoin(c.charge_item_id)=cm.charge_item_id
     AND outerjoin(1)=cm.active_ind)
    JOIN (ner
    WHERE outerjoin("CHARGE")=ner.parent_entity_name
     AND outerjoin(cm.charge_item_id)=ner.parent_entity_id
     AND outerjoin(1)=ner.active_ind
     AND outerjoin(cm.nomen_id)=ner.nomenclature_id)
   ORDER BY c.charge_item_id DESC, cm.charge_mod_id DESC
   HEAD c.charge_item_id
    lcount = (lcount+ 1), stat = alterlist(reply->qual,lcount), reply->qual[lcount].charge_item_id =
    c.charge_item_id,
    reply->qual[lcount].charge_event_id = c.charge_event_id, reply->qual[lcount].bill_item_id = c
    .bill_item_id, reply->qual[lcount].abn_status_cd = c.abn_status_cd,
    reply->qual[lcount].department_cd = c.department_cd, reply->qual[lcount].institution_cd = c
    .institution_cd, reply->qual[lcount].item_extended_price = c.item_extended_price,
    reply->qual[lcount].item_price = c.item_price, reply->qual[lcount].item_quantity = c
    .item_quantity, reply->qual[lcount].level5_cd = c.level5_cd,
    reply->qual[lcount].ord_phys_id = c.ord_phys_id, reply->qual[lcount].perf_loc_cd = c.perf_loc_cd,
    reply->qual[lcount].reason_comment = trim(c.reason_comment,3),
    reply->qual[lcount].research_acct_id = c.research_acct_id, reply->qual[lcount].section_cd = c
    .section_cd, reply->qual[lcount].service_dt_tm = c.service_dt_tm,
    reply->qual[lcount].subsection_cd = c.subsection_cd, reply->qual[lcount].suspense_reason_cd = c
    .suspense_rsn_cd, reply->qual[lcount].verify_phys_id = c.verify_phys_id,
    reply->qual[lcount].activity_type_cd = c.activity_type_cd, reply->qual[lcount].adjusted_dt_tm = c
    .adjusted_dt_tm, reply->qual[lcount].charge_description = c.charge_description,
    reply->qual[lcount].charge_type_cd = c.charge_type_cd, reply->qual[lcount].cost_center_cd = c
    .cost_center_cd, reply->qual[lcount].credited_dt_tm = c.credited_dt_tm,
    reply->qual[lcount].encntr_id = c.encntr_id, reply->qual[lcount].perf_phys_id = c.perf_phys_id,
    reply->qual[lcount].process_flg = c.process_flg,
    reply->qual[lcount].ref_phys_id = c.ref_phys_id, reply->qual[lcount].tier_group_cd = c
    .tier_group_cd, reply->qual[lcount].updt_id = c.updt_id,
    reply->qual[lcount].updt_dt_tm = c.updt_dt_tm, reply->qual[lcount].charge_event_act_id = c
    .charge_event_act_id, reply->qual[lcount].activity_dt_tm = c.activity_dt_tm,
    reply->qual[lcount].bundle_id = c.bundle_id, reply->qual[lcount].combine_ind = c.combine_ind,
    reply->qual[lcount].def_bill_item_id = c.def_bill_item_id,
    reply->qual[lcount].discount_amount = c.discount_amount, reply->qual[lcount].epsdt_ind = c
    .epsdt_ind, reply->qual[lcount].fin_class_cd = c.fin_class_cd,
    reply->qual[lcount].gross_price = c.gross_price, reply->qual[lcount].health_plan_id = c
    .health_plan_id, reply->qual[lcount].inst_fin_nbr = trim(c.inst_fin_nbr,3),
    reply->qual[lcount].interface_file_id = c.interface_file_id, reply->qual[lcount].item_allowable
     = c.item_allowable, reply->qual[lcount].item_copay = c.item_copay,
    reply->qual[lcount].item_interval_id = c.item_interval_id, reply->qual[lcount].item_list_price =
    c.item_list_price, reply->qual[lcount].item_reimbursement = c.item_reimbursement,
    reply->qual[lcount].list_price_sched_id = c.list_price_sched_id, reply->qual[lcount].manual_ind
     = c.manual_ind, reply->qual[lcount].med_service_cd = c.med_service_cd,
    reply->qual[lcount].ord_loc_cd = c.ord_loc_cd, reply->qual[lcount].ord_id = c.order_id, reply->
    qual[lcount].parent_charge_item_id = c.parent_charge_item_id,
    reply->qual[lcount].payor_id = c.payor_id, reply->qual[lcount].payor_type_cd = c.payor_type_cd,
    reply->qual[lcount].person_id = c.person_id,
    reply->qual[lcount].posted_cd = c.posted_cd, reply->qual[lcount].posted_dt_tm = c.posted_dt_tm,
    reply->qual[lcount].price_sched_id = c.price_sched_id,
    reply->qual[lcount].start_dt_tm = c.start_dt_tm, reply->qual[lcount].stop_dt_tm = c.stop_dt_tm,
    ldiagnosiscnt = 0,
    lservicecnt = 0, lmodifiercnt = 0, lrevenuecnt = 0,
    lcdmcnt = 0, lsuspreasonscnt = 0
   HEAD cm.charge_mod_id
    IF (cm.charge_mod_type_cd=udf13019
     AND trim(cm.field6,3)="USERDEFINEFIELD")
     reply->qual[lcount].user_defined_field = trim(cm.field7,3), reply->qual[lcount].
     udf_charge_mod_id = cm.charge_mod_id
    ENDIF
    IF ((request->diagnosis_ind=true))
     IF (cm.field1_id=diag14002)
      ldiagnosiscnt = (ldiagnosiscnt+ 1), stat = alterlist(reply->qual[lcount].diagnosis,
       ldiagnosiscnt), reply->qual[lcount].diagnosis[ldiagnosiscnt].charge_mod_id = cm.charge_mod_id,
      reply->qual[lcount].diagnosis[ldiagnosiscnt].nomen_entity_reltn_id = ner.nomen_entity_reltn_id,
      reply->qual[lcount].diagnosis[ldiagnosiscnt].charge_mod_type_cd = cm.charge_mod_type_cd, reply
      ->qual[lcount].diagnosis[ldiagnosiscnt].field1_id = cm.field1_id,
      reply->qual[lcount].diagnosis[ldiagnosiscnt].field3_id = cm.field3_id, reply->qual[lcount].
      diagnosis[ldiagnosiscnt].field2_id = cm.field2_id
     ENDIF
    ENDIF
    IF ((request->service_ind=true))
     IF (cm.field1_id IN (servhcpcs14002, servcpt414002, servproccode14002))
      lservicecnt = (lservicecnt+ 1), stat = alterlist(reply->qual[lcount].service,lservicecnt),
      reply->qual[lcount].service[lservicecnt].charge_mod_id = cm.charge_mod_id,
      reply->qual[lcount].service[lservicecnt].nomen_entity_reltn_id = ner.nomen_entity_reltn_id,
      reply->qual[lcount].service[lservicecnt].charge_mod_type_cd = cm.charge_mod_type_cd, reply->
      qual[lcount].service[lservicecnt].field1_id = cm.field1_id,
      reply->qual[lcount].service[lservicecnt].field2_id = cm.field2_id, reply->qual[lcount].service[
      lservicecnt].nomen_id = cm.nomen_id, reply->qual[lcount].service[lservicecnt].field7 = cm
      .field7
     ENDIF
    ENDIF
    IF ((request->modifier_ind=true))
     IF (cm.field1_id=mod14002)
      lmodifiercnt = (lmodifiercnt+ 1), stat = alterlist(reply->qual[lcount].modifier,lmodifiercnt),
      reply->qual[lcount].modifier[lmodifiercnt].charge_mod_id = cm.charge_mod_id,
      reply->qual[lcount].modifier[lmodifiercnt].charge_mod_type_cd = cm.charge_mod_type_cd, reply->
      qual[lcount].modifier[lmodifiercnt].field1_id = cm.field1_id, reply->qual[lcount].modifier[
      lmodifiercnt].field3_id = cm.field3_id,
      reply->qual[lcount].modifier[lmodifiercnt].field2_id = cm.field2_id
     ENDIF
    ENDIF
    IF ((request->revenue_ind=true))
     IF (cm.field1_id=rev14002)
      lrevenuecnt = (lrevenuecnt+ 1), stat = alterlist(reply->qual[lcount].revenue,lrevenuecnt),
      reply->qual[lcount].revenue[lrevenuecnt].charge_mod_id = cm.charge_mod_id,
      reply->qual[lcount].revenue[lrevenuecnt].charge_mod_type_cd = cm.charge_mod_type_cd, reply->
      qual[lcount].revenue[lrevenuecnt].field1_id = cm.field1_id, reply->qual[lcount].revenue[
      lrevenuecnt].field3_id = cm.field3_id,
      reply->qual[lcount].revenue[lrevenuecnt].field2_id = cm.field2_id
     ENDIF
    ENDIF
    IF ((request->cdm_ind=true))
     IF (cm.field1_id=cdm14002)
      lcdmcnt = (lcdmcnt+ 1), stat = alterlist(reply->qual[lcount].cdm,lcdmcnt), reply->qual[lcount].
      cdm[lcdmcnt].charge_mod_id = cm.charge_mod_id,
      reply->qual[lcount].cdm[lcdmcnt].charge_mod_type_cd = cm.charge_mod_type_cd, reply->qual[lcount
      ].cdm[lcdmcnt].field1_id = cm.field1_id, reply->qual[lcount].cdm[lcdmcnt].field6 = cm.field6,
      reply->qual[lcount].cdm[lcdmcnt].field7 = cm.field7, reply->qual[lcount].cdm[lcdmcnt].field2_id
       = cm.field2_id
     ENDIF
    ENDIF
    IF ((request->suspense_ind=true))
     IF (cm.charge_mod_type_cd=suspreason13019)
      lsuspreasonscnt = (lsuspreasonscnt+ 1), stat = alterlist(reply->qual[lcount].suspense_reason,
       lsuspreasonscnt), reply->qual[lcount].suspense_reason[lsuspreasonscnt].charge_mod_id = cm
      .charge_mod_id,
      reply->qual[lcount].suspense_reason[lsuspreasonscnt].charge_mod_type_cd = cm.charge_mod_type_cd,
      reply->qual[lcount].suspense_reason[lsuspreasonscnt].field1_id = cm.field1_id, reply->qual[
      lcount].suspense_reason[lsuspreasonscnt].field2_id = cm.field2_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   EXECUTE pft_log "Afc_Get_Charge_By_Id", "Unable To Retrieve Any Charge Items", 1
   SET reply->status_data.status = "Z"
   GO TO exitscript
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exitscript
 CALL echorecord(reply)
END GO
