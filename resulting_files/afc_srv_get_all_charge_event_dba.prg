CREATE PROGRAM afc_srv_get_all_charge_event:dba
 RECORD reply(
   1 charge_event_id = f8
   1 ext_m_event_id = f8
   1 ext_m_event_cd = f8
   1 ext_m_ref_id = f8
   1 ext_m_ref_cd = f8
   1 ext_p_event_id = f8
   1 ext_p_event_cd = f8
   1 ext_p_ref_id = f8
   1 ext_p_ref_cd = f8
   1 ext_i_event_id = f8
   1 ext_i_event_cd = f8
   1 ext_i_ref_id = f8
   1 ext_i_ref_cd = f8
   1 order_id = f8
   1 accession = vc
   1 encntr_type_cd = f8
   1 admit_type_cd = f8
   1 med_service_cd = f8
   1 abn_status_cd = f8
   1 perf_loc_cd = f8
   1 org_id = f8
   1 fin_class_cd = f8
   1 loc_nurse_unit_cd = f8
   1 cancelled_ind = i2
   1 person_id = f8
   1 encntr_id = f8
   1 coll_priority_cd = f8
   1 rpt_priority_cd = f8
   1 contributor_system_cd = f8
   1 reference_nbr = vc
   1 research_acct_id = f8
   1 activity_type_cd = f8
   1 cea_qual = i2
   1 charge_qual = i2
   1 activities[*]
     2 charge_event_act_id = f8
     2 cea_type_cd = f8
     2 cea_prsnl_id = f8
     2 serv_res_cd = f8
     2 serv_dt_tm = dq8
     2 pat_loc_cd = f8
     2 charge_type_cd = f8
     2 charge_dt_tm = dq8
     2 quantity = f8
     2 units = i2
     2 in_lab_dt_tm = dq8
     2 serv_loc_cd = f8
     2 physician_ind = i2
     2 position_cd = f8
     2 result = vc
     2 alpha_nomen_id = f8
     2 cea_misc1 = vc
     2 cea_misc2 = vc
     2 cea_misc3 = vc
     2 cea_misc1_id = f8
     2 cea_misc2_id = f8
     2 cea_misc3_id = f8
     2 cea_misc4_id = f8
     2 reason_cd = f8
     2 misc_ind = i2
   1 charges[*]
     2 charge_item_id = f8
     2 bill_item_id = f8
     2 charge_event_act_id = f8
     2 item_ext_price = f8
     2 charge_type_cd = f8
     2 charge_desc = vc
     2 price_sched_id = f8
     2 payor_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 ord_srv_res_cd = f8
     2 perf_srv_res_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 verify_phys_id = f8
     2 order_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 interface_id = f8
     2 tier_group_cd = f8
     2 def_bill_item_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 process_flg = i2
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 inst_fin_nbr = c50
     2 activity_type_cd = f8
     2 cost_center_cd = f8
     2 parent_charge_item_id = f8
     2 admit_type_cd = f8
     2 med_service_cd = f8
     2 research_acct_id = f8
     2 abn_status_cd = f8
     2 perf_loc_cd = f8
     2 ord_loc_cd = f8
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 manual_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE pid = f8
 DECLARE pcd = f8
 DECLARE cid = f8
 DECLARE ccd = f8
 SET ca_count = 0
 SET c_count = 0
 SET last_c_id = 0.0
 SET pid = 0.0
 SET pcd = 0.0
 SET cid = 0.0
 SET ccd = 0.0
 SELECT INTO "nl:"
  e.encntr_type_cd, e.organization_id, e.financial_class_cd,
  e.loc_nurse_unit_cd, e.med_service_cd, c.accession,
  c.charge_event_id, c.ext_m_event_id, c.ext_m_event_cont_cd,
  c.ext_m_reference_id, c.ext_m_reference_cont_cd, c.ext_p_event_id,
  c.ext_p_event_cont_cd, c.ext_p_reference_id, c.ext_p_reference_cont_cd,
  c.ext_i_event_id, c.ext_i_event_cont_cd, c.ext_i_reference_id,
  c.ext_i_reference_cont_cd, c.order_id, c.cancelled_ind,
  c.person_id, c.encntr_id, c.collection_priority_cd,
  c.report_priority_cd, c.contributor_system_cd, c.reference_nbr,
  c.research_account_id, c.abn_status_cd, c.perf_loc_cd
  FROM charge_event c,
   encounter e
  PLAN (c
   WHERE (c.charge_event_id=request->charge_event_id))
   JOIN (e
   WHERE e.encntr_id=c.encntr_id)
  ORDER BY c.charge_event_id
  DETAIL
   CALL echo(build("charge_event:  ",c.charge_event_id)),
   CALL echo(build("  perf_loc_cd: ",c.perf_loc_cd))
   IF (c.ext_p_reference_id=0
    AND c.ext_p_reference_cont_cd=0)
    pid = c.ext_i_reference_id, pcd = c.ext_i_reference_cont_cd
   ELSE
    pid = c.ext_p_reference_id, pcd = c.ext_p_reference_cont_cd, cid = c.ext_i_reference_id,
    ccd = c.ext_i_reference_cont_cd
   ENDIF
   reply->charge_event_id = c.charge_event_id, reply->ext_m_event_id = c.ext_m_event_id, reply->
   ext_m_event_cd = c.ext_m_event_cont_cd,
   reply->ext_m_ref_id = c.ext_m_reference_id, reply->ext_m_ref_cd = c.ext_m_reference_cont_cd, reply
   ->ext_p_event_id = c.ext_p_event_id,
   reply->ext_p_event_cd = c.ext_p_event_cont_cd, reply->ext_p_ref_id = c.ext_p_reference_id, reply->
   ext_p_ref_cd = c.ext_p_reference_cont_cd,
   reply->ext_i_event_id = c.ext_i_event_id, reply->ext_i_event_cd = c.ext_i_event_cont_cd, reply->
   ext_i_ref_id = c.ext_i_reference_id,
   reply->ext_i_ref_cd = c.ext_i_reference_cont_cd, reply->order_id = c.order_id, reply->accession =
   c.accession,
   reply->encntr_type_cd = e.encntr_type_cd, reply->admit_type_cd = e.encntr_type_cd, reply->
   med_service_cd = e.med_service_cd,
   reply->abn_status_cd = c.abn_status_cd, reply->perf_loc_cd = c.perf_loc_cd, reply->org_id = e
   .organization_id,
   reply->fin_class_cd = e.financial_class_cd, reply->loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply
   ->cancelled_ind = c.cancelled_ind,
   reply->person_id = c.person_id, reply->encntr_id = c.encntr_id, reply->coll_priority_cd = c
   .collection_priority_cd,
   reply->rpt_priority_cd = c.report_priority_cd, reply->contributor_system_cd = c
   .contributor_system_cd, reply->reference_nbr = c.reference_nbr,
   reply->research_acct_id = c.research_account_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  b.ext_owner_cd
  FROM bill_item b
  WHERE b.ext_parent_reference_id=pid
   AND b.ext_parent_contributor_cd=pcd
   AND ((b.ext_child_reference_id+ 0)=cid)
   AND b.ext_child_contributor_cd=ccd
   AND b.active_ind=1
  DETAIL
   reply->activity_type_cd = b.ext_owner_cd
  WITH nocounter
 ;end select
 CALL echo(build("act_type:",reply->activity_type_cd))
 IF ((reply->activity_type_cd <= 0)
  AND cid > 0
  AND ccd > 0)
  SELECT INTO "nl:"
   b.ext_owner_cd
   FROM bill_item b
   WHERE b.ext_parent_reference_id=0
    AND b.ext_parent_contributor_cd=0
    AND ((b.ext_child_reference_id+ 0)=cid)
    AND b.ext_child_contributor_cd=ccd
    AND b.active_ind=1
   DETAIL
    reply->activity_type_cd = b.ext_owner_cd
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->activity_type_cd <= 0)
  AND cid > 0
  AND ccd > 0)
  SELECT INTO "nl:"
   b.ext_owner_cd
   FROM bill_item b
   WHERE b.ext_parent_reference_id=cid
    AND b.ext_parent_contributor_cd=ccd
    AND ((b.ext_child_reference_id+ 0)=0)
    AND b.ext_child_contributor_cd=0
    AND b.active_ind=1
   DETAIL
    reply->activity_type_cd = b.ext_owner_cd
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("act_type:",reply->activity_type_cd))
 SET ca_count = 0
 SELECT INTO "nl:"
  p.physician_ind, p.position_cd, ca.charge_event_act_id,
  ca.cea_type_cd, ca.cea_prsnl_id, ca.service_resource_cd,
  ca.service_dt_tm, ca.patient_loc_cd, ca.charge_type_cd,
  ca.charge_dt_tm, ca.quantity, ca.in_lab_dt_tm,
  ca.service_loc_cd, ca.result, ca.alpha_nomen_id,
  ca.units, ca.cea_misc1, ca.cea_misc2,
  ca.cea_misc3, ca.cea_misc1_id, ca.cea_misc2_id,
  ca.cea_misc3_id, ca.cea_misc4_id, ca.reason_cd,
  ca.misc_ind
  FROM charge_event_act ca,
   dummyt d1,
   prsnl p
  PLAN (ca
   WHERE (ca.charge_event_id=reply->charge_event_id))
   JOIN (d1)
   JOIN (p
   WHERE p.person_id=ca.cea_prsnl_id)
  DETAIL
   CALL echo(build("  charge_event_act: ",ca.charge_event_act_id," ",0)),
   CALL echo(ca.cea_type_cd),
   CALL echo(build("  prsnl_id: ",ca.cea_prsnl_id," physician_ind: ",p.physician_ind)),
   CALL echo(concat("  result:  -",trim(ca.result),"-")), ca_count += 1, stat = alterlist(reply->
    activities,ca_count),
   reply->cea_qual = ca_count, reply->activities[ca_count].charge_event_act_id = ca
   .charge_event_act_id, reply->activities[ca_count].cea_type_cd = ca.cea_type_cd,
   reply->activities[ca_count].cea_prsnl_id = ca.cea_prsnl_id, reply->activities[ca_count].
   serv_res_cd = ca.service_resource_cd, reply->activities[ca_count].serv_dt_tm = ca.service_dt_tm,
   reply->activities[ca_count].pat_loc_cd = ca.patient_loc_cd, reply->activities[ca_count].
   charge_type_cd = ca.charge_type_cd, reply->activities[ca_count].charge_dt_tm = ca.charge_dt_tm,
   reply->activities[ca_count].quantity = ca.quantity, reply->activities[ca_count].units = ca.units,
   reply->activities[ca_count].in_lab_dt_tm = ca.in_lab_dt_tm,
   reply->activities[ca_count].serv_loc_cd = ca.service_loc_cd, reply->activities[ca_count].
   physician_ind = p.physician_ind, reply->activities[ca_count].position_cd = p.position_cd,
   reply->activities[ca_count].alpha_nomen_id = ca.alpha_nomen_id, reply->activities[ca_count].
   cea_misc1 = ca.cea_misc1, reply->activities[ca_count].cea_misc2 = ca.cea_misc2,
   reply->activities[ca_count].cea_misc3 = ca.cea_misc3, reply->activities[ca_count].cea_misc1_id =
   ca.cea_misc1_id, reply->activities[ca_count].cea_misc2_id = ca.cea_misc2_id,
   reply->activities[ca_count].cea_misc3_id = ca.cea_misc3_id, reply->activities[ca_count].
   cea_misc4_id = ca.cea_misc4_id, reply->activities[ca_count].reason_cd = ca.reason_cd,
   reply->activities[ca_count].misc_ind = ca.misc_ind, reply->activities[ca_count].result =
   IF (concat(trim(ca.result),"NULL")="NULL") "NULL"
   ELSE trim(ca.result)
   ENDIF
  WITH outerjoin = d1, nocounter
 ;end select
 SET c_count = 0
 SELECT INTO "nl:"
  ch.charge_item_id, ch.bill_item_id, ch.charge_event_act_id,
  ch.item_extended_price, ch.charge_type_cd, ch.charge_description,
  ch.price_sched_id, ch.payor_id, ch.item_quantity,
  ch.item_price, ch.ord_loc_cd, ch.perf_loc_cd,
  ch.ord_phys_id, ch.perf_phys_id, ch.verify_phys_id,
  ch.order_id, ch.person_id, ch.encntr_id,
  ch.interface_file_id, ch.tier_group_cd, ch.def_bill_item_id,
  ch.process_flg, ch.gross_price, ch.discount_amount,
  ch.institution_cd, ch.department_cd, ch.section_cd,
  ch.subsection_cd, ch.level5_cd, ch.inst_fin_nbr,
  ch.activity_type_cd, ch.cost_center_cd, ch.parent_charge_item_id,
  ch.research_acct_id, ch.abn_status_cd, ch.fin_class_cd,
  ch.health_plan_id, ch.manual_ind
  FROM charge ch
  WHERE (ch.charge_event_id=reply->charge_event_id)
  ORDER BY ch.tier_group_cd, ch.bill_item_id, ch.charge_item_id
  DETAIL
   CALL echo(build("        charge: ",ch.charge_item_id)), c_count += 1, stat = alterlist(reply->
    charges,c_count),
   reply->charges[c_count].charge_item_id = ch.charge_item_id, reply->charges[c_count].bill_item_id
    = ch.bill_item_id, reply->charges[c_count].charge_event_act_id = ch.charge_event_act_id,
   reply->charges[c_count].item_ext_price = ch.item_extended_price, reply->charges[c_count].
   charge_type_cd = ch.charge_type_cd, reply->charges[c_count].charge_desc = ch.charge_description,
   reply->charges[c_count].price_sched_id = ch.price_sched_id, reply->charges[c_count].payor_id = ch
   .payor_id, reply->charges[c_count].item_quantity = ch.item_quantity,
   reply->charges[c_count].item_price = ch.item_price, reply->charges[c_count].ord_srv_res_cd = ch
   .ord_loc_cd, reply->charges[c_count].perf_srv_res_cd = ch.perf_loc_cd,
   reply->charges[c_count].ord_phys_id = ch.ord_phys_id, reply->charges[c_count].perf_phys_id = ch
   .perf_phys_id, reply->charges[c_count].verify_phys_id = ch.verify_phys_id,
   reply->charges[c_count].order_id = ch.order_id, reply->charges[c_count].person_id = ch.person_id,
   reply->charges[c_count].encntr_id = ch.encntr_id,
   reply->charges[c_count].interface_id = ch.interface_file_id, reply->charges[c_count].tier_group_cd
    = ch.tier_group_cd, reply->charges[c_count].def_bill_item_id = ch.def_bill_item_id,
   reply->charges[c_count].gross_price = ch.gross_price, reply->charges[c_count].discount_amount = ch
   .discount_amount, reply->charges[c_count].process_flg = ch.process_flg,
   reply->charges[c_count].institution_cd = ch.institution_cd, reply->charges[c_count].department_cd
    = ch.department_cd, reply->charges[c_count].section_cd = ch.section_cd,
   reply->charges[c_count].subsection_cd = ch.subsection_cd, reply->charges[c_count].level5_cd = ch
   .level5_cd, reply->charges[c_count].inst_fin_nbr = ch.inst_fin_nbr,
   reply->charges[c_count].activity_type_cd = ch.activity_type_cd, reply->charges[c_count].
   cost_center_cd = ch.cost_center_cd, reply->charges[c_count].parent_charge_item_id = ch
   .parent_charge_item_id,
   reply->charges[c_count].admit_type_cd = ch.admit_type_cd, reply->charges[c_count].med_service_cd
    = ch.med_service_cd, reply->charges[c_count].research_acct_id = ch.research_acct_id,
   reply->charges[c_count].abn_status_cd = ch.abn_status_cd, reply->charges[c_count].perf_loc_cd = ch
   .perf_loc_cd, reply->charges[c_count].ord_loc_cd = ch.ord_loc_cd,
   reply->charges[c_count].fin_class_cd = ch.fin_class_cd, reply->charges[c_count].health_plan_id =
   ch.health_plan_id, reply->charges[c_count].manual_ind = ch.manual_ind
  WITH nocounter
 ;end select
 SET reply->cea_qual = ca_count
 SET reply->charge_qual = c_count
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
