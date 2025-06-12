CREATE PROGRAM afc_get_charges_for_claim:dba
 DECLARE versionnbr = vc
 SET versionnbr = "000"
 CALL echo(build("AFC_GET_CHARGES_FOR_CLAIM Version: ",versionnbr))
 RECORD charges(
   1 charge_qual = i4
   1 charge[*]
     2 charge_item_id = f8
     2 late_chrg_flag = i4
 )
 SET count1 = 0
 SELECT INTO "nl:"
  pc.pft_charge_id, pc.late_chrg_flag
  FROM pft_charge pc,
   pft_charge_bo_reltn pcbr,
   bill_reltn br
  PLAN (br
   WHERE (br.corsp_activity_id=request->corsp_activity_id)
    AND br.parent_entity_name="BENEFIT ORDER"
    AND br.active_ind=1)
   JOIN (pcbr
   WHERE pcbr.benefit_order_id=br.parent_entity_id
    AND pcbr.active_ind=1)
   JOIN (pc
   WHERE pc.pft_charge_id=pcbr.pft_charge_id
    AND pc.active_ind=1)
  ORDER BY pc.late_chrg_flag, pc.charge_item_id DESC
  DETAIL
   count1 = (count1+ 1), stat = alterlist(charges->charge,count1), charges->charge[count1].
   charge_item_id = pc.charge_item_id,
   charges->charge[count1].late_chrg_flag = pc.late_chrg_flag
  WITH nocounter
 ;end select
 SET charges->charge_qual = count1
 SET count1 = 0
 SELECT INTO "nl:"
  FROM charge c,
   person p,
   encounter e,
   charge_event ce,
   bill_item b,
   (dummyt d1  WITH seq = value(charges->charge_qual))
  PLAN (d1)
   JOIN (c
   WHERE (c.charge_item_id=charges->charge[d1.seq].charge_item_id))
   JOIN (p
   WHERE p.person_id=c.person_id
    AND p.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=c.encntr_id
    AND e.active_ind=1)
   JOIN (ce
   WHERE ce.charge_event_id=c.charge_event_id
    AND ce.active_ind=1)
   JOIN (b
   WHERE b.bill_item_id=c.bill_item_id)
  ORDER BY ce.ext_m_event_id, ce.ext_p_event_id, c.charge_item_id
  HEAD ce.ext_m_event_id
   firstmaster = true
  HEAD c.charge_item_id
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1)
   IF (firstmaster=true
    AND ce.ext_p_event_id <= 0
    AND b.ext_child_reference_id <= 0)
    reply->qual[count1].master_ind = 1, reply->qual[count1].ext_master_reference_id = ce
    .ext_m_reference_id, reply->qual[count1].ext_master_reference_cont_cd = ce
    .ext_m_reference_cont_cd,
    reply->qual[count1].charge_event_id = c.charge_event_id, reply->qual[count1].charge_event_act_id
     = c.charge_event_act_id, reply->qual[count1].accession_nbr = ce.accession,
    reply->qual[count1].charge_item_id = c.charge_item_id, reply->qual[count1].tier_group_cd = c
    .tier_group_cd, reply->qual[count1].encntr_id = c.encntr_id,
    reply->qual[count1].person_id = c.person_id, reply->qual[count1].perf_loc_cd = c.perf_loc_cd,
    reply->qual[count1].payor_id = c.payor_id,
    reply->qual[count1].ord_phys_id = c.ord_phys_id, reply->qual[count1].verify_phys_id = c
    .verify_phys_id, reply->qual[count1].charge_description = c.charge_description,
    reply->qual[count1].item_quantity = c.item_quantity, reply->qual[count1].item_price = c
    .item_price, reply->qual[count1].item_extended_price = c.item_extended_price,
    reply->qual[count1].parent_charge_item_id = c.parent_charge_item_id, reply->qual[count1].
    charge_type_cd = c.charge_type_cd, reply->qual[count1].suspense_rsn_cd = c.suspense_rsn_cd,
    reply->qual[count1].reason_comment = c.reason_comment, reply->qual[count1].interface_file_id = c
    .interface_file_id, reply->qual[count1].process_flg = c.process_flg,
    reply->qual[count1].manual_ind = c.manual_ind, reply->qual[count1].bundle_id = c.bundle_id, reply
    ->qual[count1].cost_center_cd = c.cost_center_cd,
    reply->qual[count1].section_cd = c.section_cd, reply->qual[count1].activity_type_cd = c
    .activity_type_cd, reply->qual[count1].credited_dt_tm = c.credited_dt_tm,
    reply->qual[count1].adjusted_dt_tm = c.adjusted_dt_tm, reply->qual[count1].service_dt_tm = c
    .service_dt_tm, reply->qual[count1].research_acct_id = c.research_acct_id,
    reply->qual[count1].person_name = p.name_full_formatted, reply->qual[count1].person_dob = p
    .birth_dt_tm, reply->qual[count1].person_sex_cd = p.sex_cd,
    reply->qual[count1].department_cd = c.department_cd, reply->qual[count1].reason_for_visit = e
    .reason_for_visit, reply->qual[count1].updt_id = c.updt_id,
    reply->qual[count1].order_id = c.order_id, reply->qual[count1].abn_status_cd = c.abn_status_cd,
    reply->qual[count1].updt_dt_tm = c.updt_dt_tm,
    reply->qual[count1].encntr_type_cd = e.encntr_type_cd, reply->qual[count1].financial_class_cd = e
    .financial_class_cd, reply->qual[count1].building_cd = e.loc_building_cd,
    reply->qual[count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->qual[count1].
    ext_parent_reference_id = b.ext_parent_reference_id, reply->qual[count1].ext_child_contributor_cd
     = b.ext_child_contributor_cd,
    reply->qual[count1].ext_child_reference_id = b.ext_child_reference_id, reply->qual[count1].
    late_chrg_flag = charges->charge[d1.seq].late_chrg_flag, firstmaster = false
   ELSEIF (((firstmaster=true
    AND ce.ext_p_event_id > 0) OR (firstmaster=true
    AND ce.ext_p_event_id <= 0
    AND b.ext_child_reference_id > 0)) )
    reply->qual[count1].master_ind = 1, reply->qual[count1].place_holder = 1, reply->qual[count1].
    bump_up = 1,
    reply->qual[count1].ext_master_reference_id = ce.ext_m_reference_id, reply->qual[count1].
    ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd, reply->qual[count1].charge_item_id = c
    .charge_item_id,
    reply->qual[count1].charge_description = c.charge_description, reply->qual[count1].item_quantity
     = c.item_quantity, reply->qual[count1].payor_id = c.payor_id,
    reply->qual[count1].perf_loc_cd = c.perf_loc_cd, reply->qual[count1].tier_group_cd = c
    .tier_group_cd, reply->qual[count1].charge_type_cd = c.charge_type_cd,
    reply->qual[count1].suspense_rsn_cd = c.suspense_rsn_cd, reply->qual[count1].reason_comment = c
    .reason_comment, reply->qual[count1].interface_file_id = c.interface_file_id,
    reply->qual[count1].process_flg = c.process_flg, reply->qual[count1].manual_ind = c.manual_ind,
    reply->qual[count1].service_dt_tm = c.service_dt_tm,
    reply->qual[count1].research_acct_id = c.research_acct_id, reply->qual[count1].activity_type_cd
     = c.activity_type_cd, reply->qual[count1].encntr_id = c.encntr_id,
    reply->qual[count1].person_id = p.person_id, reply->qual[count1].person_name = p
    .name_full_formatted, reply->qual[count1].person_dob = p.birth_dt_tm,
    reply->qual[count1].person_sex_cd = p.sex_cd, reply->qual[count1].department_cd = c.department_cd,
    reply->qual[count1].ord_phys_id = c.ord_phys_id,
    reply->qual[count1].verify_phys_id = c.verify_phys_id, reply->qual[count1].activity_type_cd = c
    .activity_type_cd, reply->qual[count1].bundle_id = c.bundle_id,
    reply->qual[count1].cost_center_cd = c.cost_center_cd, reply->qual[count1].updt_id = c.updt_id,
    reply->qual[count1].order_id = c.order_id,
    reply->qual[count1].abn_status_cd = c.abn_status_cd, reply->qual[count1].updt_dt_tm = c
    .updt_dt_tm, reply->qual[count1].encntr_type_cd = e.encntr_type_cd,
    reply->qual[count1].financial_class_cd = e.financial_class_cd, reply->qual[count1].building_cd =
    e.loc_building_cd, reply->qual[count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd,
    reply->qual[count1].ext_parent_reference_id = b.ext_parent_reference_id, reply->qual[count1].
    ext_child_contributor_cd = b.ext_child_contributor_cd, reply->qual[count1].ext_child_reference_id
     = b.ext_child_reference_id,
    reply->qual[count1].late_chrg_flag = charges->charge[d1.seq].late_chrg_flag, count1 = (count1+ 1),
    stat = alterlist(reply->qual,count1),
    reply->qual[count1].ext_master_reference_id = ce.ext_m_reference_id, reply->qual[count1].
    ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd, reply->qual[count1].accession_nbr = ce
    .accession,
    reply->qual[count1].charge_item_id = c.charge_item_id, reply->qual[count1].tier_group_cd = c
    .tier_group_cd, reply->qual[count1].encntr_id = c.encntr_id,
    reply->qual[count1].person_id = c.person_id, reply->qual[count1].payor_id = c.payor_id, reply->
    qual[count1].perf_loc_cd = c.perf_loc_cd,
    reply->qual[count1].ord_phys_id = c.ord_phys_id, reply->qual[count1].verify_phys_id = c
    .verify_phys_id, reply->qual[count1].charge_description = c.charge_description,
    reply->qual[count1].item_quantity = c.item_quantity, reply->qual[count1].item_price = c
    .item_price, reply->qual[count1].item_extended_price = c.item_extended_price,
    reply->qual[count1].parent_charge_item_id = c.parent_charge_item_id, reply->qual[count1].
    charge_type_cd = c.charge_type_cd, reply->qual[count1].suspense_rsn_cd = c.suspense_rsn_cd,
    reply->qual[count1].reason_comment = c.reason_comment, reply->qual[count1].interface_file_id = c
    .interface_file_id, reply->qual[count1].process_flg = c.process_flg,
    reply->qual[count1].manual_ind = c.manual_ind, reply->qual[count1].bundle_id = c.bundle_id, reply
    ->qual[count1].cost_center_cd = c.cost_center_cd,
    reply->qual[count1].credited_dt_tm = c.credited_dt_tm, reply->qual[count1].adjusted_dt_tm = c
    .adjusted_dt_tm, reply->qual[count1].service_dt_tm = c.service_dt_tm,
    reply->qual[count1].research_acct_id = c.research_acct_id, reply->qual[count1].activity_type_cd
     = c.activity_type_cd, reply->qual[count1].person_name = p.name_full_formatted,
    reply->qual[count1].person_dob = p.birth_dt_tm, reply->qual[count1].person_sex_cd = p.sex_cd,
    reply->qual[count1].department_cd = c.department_cd,
    reply->qual[count1].reason_for_visit = e.reason_for_visit, reply->qual[count1].updt_id = c
    .updt_id, reply->qual[count1].order_id = c.order_id,
    reply->qual[count1].abn_status_cd = c.abn_status_cd, reply->qual[count1].updt_dt_tm = c
    .updt_dt_tm, reply->qual[count1].encntr_type_cd = e.encntr_type_cd,
    reply->qual[count1].financial_class_cd = e.financial_class_cd, reply->qual[count1].building_cd =
    e.loc_building_cd, reply->qual[count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd,
    reply->qual[count1].ext_parent_reference_id = b.ext_parent_reference_id, reply->qual[count1].
    ext_child_contributor_cd = b.ext_child_contributor_cd, reply->qual[count1].ext_child_reference_id
     = b.ext_child_reference_id,
    reply->qual[count1].late_chrg_flag = charges->charge[d1.seq].late_chrg_flag, firstmaster = false
   ELSE
    reply->qual[count1].ext_master_reference_id = ce.ext_m_reference_id, reply->qual[count1].
    ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd, reply->qual[count1].accession_nbr = ce
    .accession,
    reply->qual[count1].master_ind = 0, reply->qual[count1].charge_item_id = c.charge_item_id, reply
    ->qual[count1].charge_event_id = c.charge_event_id,
    reply->qual[count1].charge_event_act_id = c.charge_event_act_id, reply->qual[count1].
    tier_group_cd = c.tier_group_cd, reply->qual[count1].encntr_id = c.encntr_id,
    reply->qual[count1].person_id = c.person_id, reply->qual[count1].payor_id = c.payor_id, reply->
    qual[count1].perf_loc_cd = c.perf_loc_cd,
    reply->qual[count1].ord_phys_id = c.ord_phys_id, reply->qual[count1].verify_phys_id = c
    .verify_phys_id, reply->qual[count1].charge_description = c.charge_description,
    reply->qual[count1].item_quantity = c.item_quantity, reply->qual[count1].item_price = c
    .item_price, reply->qual[count1].item_extended_price = c.item_extended_price,
    reply->qual[count1].parent_charge_item_id = c.parent_charge_item_id, reply->qual[count1].
    charge_type_cd = c.charge_type_cd, reply->qual[count1].suspense_rsn_cd = c.suspense_rsn_cd,
    reply->qual[count1].reason_comment = c.reason_comment, reply->qual[count1].interface_file_id = c
    .interface_file_id, reply->qual[count1].process_flg = c.process_flg,
    reply->qual[count1].manual_ind = c.manual_ind, reply->qual[count1].bundle_id = c.bundle_id, reply
    ->qual[count1].cost_center_cd = c.cost_center_cd,
    reply->qual[count1].credited_dt_tm = c.credited_dt_tm, reply->qual[count1].adjusted_dt_tm = c
    .adjusted_dt_tm, reply->qual[count1].service_dt_tm = c.service_dt_tm,
    reply->qual[count1].research_acct_id = c.research_acct_id, reply->qual[count1].activity_type_cd
     = c.activity_type_cd, reply->qual[count1].updt_dt_tm = c.updt_dt_tm,
    reply->qual[count1].person_name = p.name_full_formatted, reply->qual[count1].person_dob = p
    .birth_dt_tm, reply->qual[count1].person_sex_cd = p.sex_cd,
    reply->qual[count1].department_cd = c.department_cd, reply->qual[count1].section_cd = c
    .section_cd, reply->qual[count1].reason_for_visit = e.reason_for_visit,
    reply->qual[count1].updt_id = c.updt_id, reply->qual[count1].order_id = c.order_id, reply->qual[
    count1].abn_status_cd = c.abn_status_cd,
    reply->qual[count1].encntr_type_cd = e.encntr_type_cd, reply->qual[count1].financial_class_cd = e
    .financial_class_cd, reply->qual[count1].building_cd = e.loc_building_cd,
    reply->qual[count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->qual[count1].
    ext_parent_reference_id = b.ext_parent_reference_id, reply->qual[count1].ext_child_contributor_cd
     = b.ext_child_contributor_cd,
    reply->qual[count1].ext_child_reference_id = b.ext_child_reference_id, reply->qual[count1].
    late_chrg_flag = charges->charge[d1.seq].late_chrg_flag
   ENDIF
   CALL echo(build("charge_item_id: ",reply->qual[count1].charge_item_id)),
   CALL echo(build("late_chrg_flag: ",reply->qual[count1].late_chrg_flag))
  WITH nocounter
 ;end select
 SET reply->charge_qual = count1
END GO
