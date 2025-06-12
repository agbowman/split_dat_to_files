CREATE PROGRAM afc_add_partial_credit:dba
 SET afc_add_partial_credit = "490084.FT.006"
 RECORD reply(
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
     2 price_sched_id = f8
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
     2 cost_center_disp = c40
     2 cost_center_desc = c60
     2 cost_center_mean = c12
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
       3 field4_id = f8
       3 field5_id = f8
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
       3 nomen_id = f8
       3 cm1_nbr = f8
       3 activity_dt_tm = dq8
   1 original_charge_qual = i2
   1 original_charge[*]
     2 charge_item_id = f8
     2 process_flg = f8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = f8
     2 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD addcredit_request(
   1 charge_qual = i2
   1 charge[*]
     2 charge_item_id = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = vc
     2 late_charge_processing_ind = i2
 )
 RECORD addcredit_reply(
   1 charge_qual = i2
   1 dequeued_ind = i2
   1 charge[*]
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
     2 price_sched_id = f8
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
     2 cost_center_disp = c40
     2 cost_center_desc = c60
     2 cost_center_mean = c12
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
       3 field4_id = f8
       3 field5_id = f8
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
       3 nomen_id = f8
       3 cm1_nbr = f8
       3 activity_dt_tm = dq8
   1 original_charge_qual = i2
   1 original_charge[*]
     2 charge_item_id = f8
     2 process_flg = f8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = f8
     2 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD chargefind_request(
   1 charge_item_id = f8
 )
 RECORD chargefind_reply(
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
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD chargeeventfind_request(
   1 charge_item_id = f8
 )
 RECORD chargeeventfind_reply(
   1 charge_event_id = f8
   1 ext_m_event_id = f8
   1 ext_m_event_cont_cd = f8
   1 ext_m_reference_id = f8
   1 ext_m_reference_cont_cd = f8
   1 ext_p_event_id = f8
   1 ext_p_event_cont_cd = f8
   1 ext_p_reference_id = f8
   1 ext_p_reference_cont_cd = f8
   1 ext_i_event_id = f8
   1 ext_i_event_cont_cd = f8
   1 ext_i_reference_id = f8
   1 ext_i_reference_cont_cd = f8
   1 bill_item_id = f8
   1 p_bill_item_id = f8
   1 m_bill_item_id = f8
   1 p_charge_event_id = f8
   1 m_charge_event_id = f8
   1 order_id = f8
   1 contributor_system_cd = f8
   1 reference_nbr = vc
   1 cancelled_ind = i2
   1 cancelled_dt_tm = dq8
   1 person_id = f8
   1 encntr_id = f8
   1 collection_priority_cd = f8
   1 report_priority_cd = f8
   1 accession = vc
   1 updt_cnt = i4
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 active_ind = i2
   1 active_status_dt_tm = dq8
   1 updt_task = i4
   1 updt_applctx = i4
   1 research_account_id = f8
   1 abn_status_cd = f8
   1 perf_loc_cd = f8
   1 health_plan_id = f8
   1 epsdt_ind = i2
   1 charge_event_act_count = i4
   1 charge_event_act[*]
     2 charge_event_act_id = f8
     2 charge_event_id = f8
     2 cea_type_cd = f8
     2 cea_prsnl_id = f8
     2 service_resource_cd = f8
     2 service_dt_tm = dq8
     2 charge_dt_tm = dq8
     2 charge_type_cd = f8
     2 reference_range_factor_id = f8
     2 alpha_nomen_id = f8
     2 quantity = f8
     2 units = i4
     2 unit_type_cd = f8
     2 patient_loc_cd = f8
     2 service_loc_cd = f8
     2 reason_cd = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_task = i4
     2 active_ind = i2
     2 insert_dt_tm = dq8
     2 updt_id = f8
     2 updt_applctx = i4
     2 in_lab_dt_tm = dq8
     2 accession_id = f8
     2 repeat_ind = i2
     2 result = vc
     2 cea_misc1 = vc
     2 cea_misc1_id = f8
     2 cea_misc2 = vc
     2 cea_misc2_id = f8
     2 cea_misc3 = vc
     2 cea_misc3_id = f8
     2 cea_misc4_id = f8
     2 srv_diag1_id = f8
     2 srv_diag2_id = f8
     2 srv_diag3_id = f8
     2 srv_diag4_id = f8
     2 srv_diag_cd = f8
     2 misc_ind = i2
     2 cea_misc5_id = f8
     2 cea_misc6_id = f8
     2 cea_misc7_id = f8
     2 activity_dt_tm = dq8
     2 priority_cd = f8
     2 item_price = f8
     2 item_ext_price = f8
     2 item_copay = f8
     2 discount_amount = f8
     2 item_reimbursement = f8
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD afcinterfacecharge_request(
   1 interface_charge[*]
     2 charge_item_id = f8
 )
 RECORD afcinterfacecharge_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD encounterrequest(
   1 encntr_id = f8
 )
 RECORD encounterreply(
   1 person_encounter_qual = i2
   1 person_encounter[*]
     2 person_name = vc
     2 person_id = f8
     2 mrn = vc
     2 fin = vc
     2 dob = dq8
     2 age = vc
     2 sex_cd = f8
     2 sex_disp = c40
     2 sex_desc = c60
     2 sex_mean = c12
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 room_cd = f8
     2 room_disp = c40
     2 room_desc = c60
     2 room_mean = c12
     2 bed_cd = f8
     2 bed_disp = c40
     2 bed_desc = c60
     2 bed_mean = c12
     2 attending_physician = vc
     2 physician_id = f8
     2 admitting_physician = vc
     2 admit_phys_id = f8
     2 admit_type_cd = f8
     2 registration_dt_tm = dq8
     2 discharge_dt_tm = dq8
     2 encntr_type_cd = f8
     2 encntr_type_disp = c40
     2 encntr_type_desc = c60
     2 encntr_type_mean = c12
     2 ssn = vc
     2 person_mrn = vc
     2 person_community_mrn = vc
     2 organization_id = f8
     2 loc_nurse_unit_cd = f8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 health_plan_id = f8
     2 primary_health_plan = vc
     2 financial_class_cd = f8
     2 financial_class_disp = c40
     2 financial_class_desc = c60
     2 financial_class_mean = c12
     2 ref_phys_id = f8
     2 referring_physician = vc
     2 ord_phys_id = f8
     2 ordering_physician = vc
     2 ren_phys_id = f8
     2 rendering_physician = vc
     2 perf_loc_cd = f8
     2 perf_loc_disp = c40
     2 perf_loc_desc = c60
     2 perf_loc_mean = c12
     2 secondary_health_plan_id = f8
     2 secondary_health_plan = vc
     2 deduct_amt = f8
     2 program_service_cd = f8
     2 birth_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD bill_item_info(
   1 ext_parent_reference_id = f8
   1 ext_parent_contributor_cd = f8
 )
 RECORD pirequest(
   1 objarray[*]
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ord_loc_cd = f8
     2 perf_loc_cd = f8
     2 encntr_id = f8
     2 person_id = f8
     2 encntr_org_id = f8
     2 fin_class_cd = f8
     2 encntr_type_cd = f8
     2 health_plan_id = f8
     2 loc_nurse_unit_cd = f8
     2 service_dt_tm = dq8
     2 item_quantity = i4
     2 charge_mod[*]
       3 charge_mod_id = f8
       3 charge_item_id = f8
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
       3 activity_dt_tm = dq8
       3 updt_cnt = i4
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 updt_task = i4
       3 updt_applctx = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 code1_cd = f8
       3 nomen_id = f8
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 cm1_nbr = f8
 )
 RECORD pireply(
   1 charges[*]
     2 charge_item_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 charge_description = c200
     2 payor_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 charge_type_cd = f8
     2 person_id = f8
     2 encntr_id = f8
     2 service_dt_tm = dq8
     2 process_flg = i4
     2 parent_charge_item_id = f8
     2 interface_id = f8
     2 tier_group_cd = f8
     2 mods[*]
       3 mod_id = f8
       3 charge_event_id = f8
       3 charge_event_mod_type_cd = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 field1 = vc
       3 field2 = vc
       3 field3 = vc
       3 field4 = vc
       3 field5 = vc
       3 field6 = vc
       3 field7 = vc
       3 field2_id = f8
       3 field1_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
 )
 RECORD addcharge_request(
   1 objarray[*]
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
     2 charge_description = vc
     2 price_sched_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 item_allowable = f8
     2 item_copay = f8
     2 charge_type_cd = f8
     2 research_acct_id = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = vc
     2 posted_cd = f8
     2 posted_dt_tm = dq8
     2 posted_dt_tm_null = i2
     2 process_flg = i4
     2 service_dt_tm = dq8
     2 service_dt_tm_null = i2
     2 activity_dt_tm = dq8
     2 activity_dt_tm_null = i2
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 beg_effective_dt_tm_null = i2
     2 end_effective_dt_tm = dq8
     2 end_effective_dt_tm_null = i2
     2 credited_dt_tm = dq8
     2 credited_dt_tm_null = i2
     2 adjusted_dt_tm = dq8
     2 adjusted_dt_tm_null = i2
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
     2 start_dt_tm_null = i2
     2 stop_dt_tm = dq8
     2 stop_dt_tm_null = i2
     2 alpha_nomen_id = f8
     2 server_process_flag = i2
     2 offset_charge_item_id = f8
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
 )
 RECORD addcharge_reply(
   1 pft_status_data
     2 status = c1
     2 subeventstatus[*]
       3 status = c1
       3 table_name = vc
       3 pk_values = vc
   1 mod_objs[*]
     2 entity_type = vc
     2 mod_recs[*]
       3 table_name = vc
       3 pk_values = vc
       3 mod_flds[*]
         4 field_name = vc
         4 field_type = vc
         4 field_value_obj = vc
         4 field_value_db = vc
   1 failure_stack
     2 failures[*]
       3 programname = vc
       3 routinename = vc
       3 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD addchargemodreq(
   1 charge_mod_qual = i2
   1 charge_mod[*]
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
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 nomen_id = f8
     2 cm1_nbr = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 action_type = c3
 )
 RECORD addchargemodrep(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field6 = vc
     2 field7 = vc
     2 nomen_id = f8
     2 action_type = c3
     2 nomen_entity_reltn_id = f8
     2 cm1_nbr = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD afcprofit_request(
   1 remove_commit_ind = i2
   1 follow_combined_parent_ind = i2
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
 )
 FREE RECORD afcprofit_reply
 RECORD afcprofit_reply(
   1 success_cnt = i4
   1 failed_cnt = i4
   1 pft_status_data
     2 status = c1
     2 subeventstatus[*]
       3 status = c1
       3 table_name = vc
       3 pk_values = vc
   1 mod_objs[*]
     2 entity_type = vc
     2 mod_recs[*]
       3 table_name = vc
       3 pk_values = vc
       3 mod_flds[*]
         4 field_name = vc
         4 field_type = vc
         4 field_value_obj = vc
         4 field_value_db = vc
   1 failure_stack
     2 failures[*]
       3 programname = vc
       3 routinename = vc
       3 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 objarray[*]
     2 service_cd = f8
     2 updt_id = f8
     2 event_key = vc
     2 category_key = vc
     2 published_ind = i2
     2 pe_status_reason_cd = f8
     2 acct_id = f8
     2 activity_id = f8
     2 batch_denial_file_r_id = f8
     2 batch_trans_ext_id = f8
     2 batch_trans_file_id = f8
     2 batch_trans_id = f8
     2 benefit_order_id = f8
     2 bill_item_id = f8
     2 bill_templ_id = f8
     2 bill_vrsn_nbr = i4
     2 billing_entity_id = f8
     2 bo_hp_reltn_id = f8
     2 charge_item_id = f8
     2 chrg_activity_id = f8
     2 claim_status_id = f8
     2 client_org_id = f8
     2 corsp_activity_id = f8
     2 corsp_log_reltn_id = f8
     2 denial_id = f8
     2 dirty_flag = i4
     2 encntr_id = f8
     2 guar_acct_id = f8
     2 guarantor_id = f8
     2 health_plan_id = f8
     2 long_text_id = f8
     2 organization_id = f8
     2 payor_org_id = f8
     2 pe_status_reason_id = f8
     2 person_id = f8
     2 pft_balance_id = f8
     2 pft_bill_activity_id = f8
     2 pft_charge_id = f8
     2 pft_encntr_fact_id = f8
     2 pft_encntr_id = f8
     2 pft_line_item_id = f8
     2 trans_alias_id = f8
     2 pft_payment_plan_id = f8
     2 daily_encntr_bal_id = f8
     2 daily_acct_bal_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_disp = vc
     2 active_status_desc = vc
     2 active_status_mean = vc
     2 active_status_code_set = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_applctx = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = f8
     2 benefit_status_cd = f8
     2 financial_class_cd = f8
     2 payment_plan_flag = i2
     2 payment_location_id = f8
     2 encntr_plan_cob_id = f8
     2 guarantor_account_id = f8
     2 guarantor_id1 = f8
     2 guarantor_id2 = f8
     2 cbos_pe_reltn_id = f8
     2 post_dt_tm = dq8
     2 posting_category_type_flag = i2
 )
 DECLARE charge_event_mod_count = i4 WITH public, noconstant(0)
 DECLARE main_charge_count = i4 WITH public, noconstant(0)
 DECLARE pi_count = i4 WITH public, noconstant(0)
 DECLARE pi_size = i4 WITH public, noconstant(0)
 DECLARE hold_item_price = f8 WITH public, noconstant(0.0)
 DECLARE hold_item_extended_price = f8 WITH public, noconstant(0.0)
 DECLARE hold_process_flg = i4 WITH public, noconstant(0)
 DECLARE profit_count = i4 WITH public, noconstant(0)
 DECLARE orig_chrg_count = i4 WITH public, noconstant(0)
 DECLARE appid = i4
 DECLARE taskid = i4
 DECLARE reqid = i4
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hreq = i4
 DECLARE hrequest = i4
 DECLARE iret = i4
 DECLARE hlist1 = i4
 DECLARE srvstat = i4
 DECLARE hreply = i4
 SET appid = 4050200
 SET taskid = 4050100
 SET reqid = 4050157
 SET curalias main_cfr chargefind_reply->charge_items[1]
 SET reply->status_data.status = "F"
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(request)
 ENDIF
 FOR (a = 1 TO request->charge_qual)
   SET addcredit_request->charge_qual = 1
   SET stat = alterlist(addcredit_request->charge,1)
   SET addcredit_request->charge[1].charge_item_id = request->charge[a].charge_item_id
   SET addcredit_request->charge[1].suspense_rsn_cd = request->charge[a].susp_rsn_cd
   SET addcredit_request->charge[1].reason_comment = request->charge[a].reason_comment
   SET addcredit_request->charge[1].late_charge_processing_ind = 0
   EXECUTE afc_add_credit  WITH replace("REQUEST",addcredit_request), replace("REPLY",addcredit_reply
    )
   IF ((addcredit_reply->status_data.status="F"))
    SET reply->status_data.status = "F"
    GO TO end_program
   ELSE
    FOR (xcnt = 1 TO addcredit_reply->charge_qual)
      SET main_charge_count += 1
      SET stat = alterlist(reply->charge,main_charge_count)
      SET curalias cr reply->charge[main_charge_count]
      SET cr->charge_item_id = addcredit_reply->charge[xcnt].charge_item_id
      SET cr->parent_charge_item_id = addcredit_reply->charge[xcnt].parent_charge_item_id
      SET cr->charge_event_act_id = addcredit_reply->charge[xcnt].charge_event_act_id
      SET cr->charge_event_id = addcredit_reply->charge[xcnt].charge_event_id
      SET cr->bill_item_id = addcredit_reply->charge[xcnt].bill_item_id
      SET cr->order_id = addcredit_reply->charge[xcnt].order_id
      SET cr->encntr_id = addcredit_reply->charge[xcnt].encntr_id
      SET cr->person_id = addcredit_reply->charge[xcnt].person_id
      SET cr->payor_id = addcredit_reply->charge[xcnt].payor_id
      SET cr->perf_loc_cd = addcredit_reply->charge[xcnt].perf_loc_cd
      SET cr->ord_loc_cd = addcredit_reply->charge[xcnt].ord_loc_cd
      SET cr->ord_phys_id = addcredit_reply->charge[xcnt].ord_phys_id
      SET cr->perf_phys_id = addcredit_reply->charge[xcnt].perf_phys_id
      SET cr->charge_description = addcredit_reply->charge[xcnt].charge_description
      SET cr->price_sched_id = addcredit_reply->charge[xcnt].price_sched_id
      SET cr->item_quantity = addcredit_reply->charge[xcnt].item_quantity
      SET cr->item_price = addcredit_reply->charge[xcnt].item_price
      SET cr->item_extended_price = addcredit_reply->charge[xcnt].item_extended_price
      SET cr->item_allowable = addcredit_reply->charge[xcnt].item_allowable
      SET cr->item_copay = addcredit_reply->charge[xcnt].item_copay
      SET cr->charge_type_cd = addcredit_reply->charge[xcnt].charge_type_cd
      SET cr->research_acct_id = addcredit_reply->charge[xcnt].research_acct_id
      SET cr->suspense_rsn_cd = addcredit_reply->charge[xcnt].suspense_rsn_cd
      SET cr->reason_comment = addcredit_reply->charge[xcnt].reason_comment
      SET cr->posted_cd = addcredit_reply->charge[xcnt].posted_cd
      SET cr->posted_dt_tm = addcredit_reply->charge[xcnt].posted_dt_tm
      SET cr->process_flg = addcredit_reply->charge[xcnt].process_flg
      SET cr->service_dt_tm = addcredit_reply->charge[xcnt].service_dt_tm
      SET cr->activity_dt_tm = addcredit_reply->charge[xcnt].activity_dt_tm
      SET cr->credited_dt_tm = addcredit_reply->charge[xcnt].credited_dt_tm
      SET cr->adjusted_dt_tm = addcredit_reply->charge[xcnt].adjusted_dt_tm
      SET cr->interface_file_id = addcredit_reply->charge[xcnt].interface_file_id
      SET cr->tier_group_cd = addcredit_reply->charge[xcnt].tier_group_cd
      SET cr->def_bill_item_id = addcredit_reply->charge[xcnt].def_bill_item_id
      SET cr->verify_phys_id = addcredit_reply->charge[xcnt].verify_phys_id
      SET cr->gross_price = addcredit_reply->charge[xcnt].gross_price
      SET cr->discount_amount = addcredit_reply->charge[xcnt].discount_amount
      SET cr->manual_ind = addcredit_reply->charge[xcnt].manual_ind
      SET cr->combine_ind = addcredit_reply->charge[xcnt].combine_ind
      SET cr->bundle_id = addcredit_reply->charge[xcnt].bundle_id
      SET cr->institution_cd = addcredit_reply->charge[xcnt].institution_cd
      SET cr->department_cd = addcredit_reply->charge[xcnt].department_cd
      SET cr->section_cd = addcredit_reply->charge[xcnt].section_cd
      SET cr->subsection_cd = addcredit_reply->charge[xcnt].subsection_cd
      SET cr->level5_cd = addcredit_reply->charge[xcnt].level5_cd
      SET cr->admit_type_cd = addcredit_reply->charge[xcnt].admit_type_cd
      SET cr->med_service_cd = addcredit_reply->charge[xcnt].med_service_cd
      SET cr->activity_type_cd = addcredit_reply->charge[xcnt].activity_type_cd
      IF (validate(cr->activity_sub_type_cd))
       SET cr->activity_sub_type_cd = addcredit_reply->charge[xcnt].activity_sub_type_cd
      ENDIF
      IF (validate(cr->provider_specialty_cd))
       SET cr->provider_specialty_cd = addcredit_reply->charge[xcnt].provider_specialty_cd
      ENDIF
      SET cr->inst_fin_nbr = addcredit_reply->charge[xcnt].inst_fin_nbr
      SET cr->cost_center_cd = addcredit_reply->charge[xcnt].cost_center_cd
      SET cr->abn_status_cd = addcredit_reply->charge[xcnt].abn_status_cd
      SET cr->health_plan_id = addcredit_reply->charge[xcnt].health_plan_id
      SET cr->fin_class_cd = addcredit_reply->charge[xcnt].fin_class_cd
      SET cr->payor_type_cd = addcredit_reply->charge[xcnt].payor_type_cd
      SET cr->item_reimbursement = addcredit_reply->charge[xcnt].item_reimbursement
      SET cr->item_interval_id = addcredit_reply->charge[xcnt].item_interval_id
      SET cr->item_list_price = addcredit_reply->charge[xcnt].item_list_price
      SET cr->list_price_sched_id = addcredit_reply->charge[xcnt].list_price_sched_id
      SET cr->start_dt_tm = addcredit_reply->charge[xcnt].start_dt_tm
      SET cr->stop_dt_tm = addcredit_reply->charge[xcnt].stop_dt_tm
      SET cr->epsdt_ind = addcredit_reply->charge[xcnt].epsdt_ind
      SET cr->ref_phys_id = addcredit_reply->charge[xcnt].ref_phys_id
      SET cr->item_deductible_amt = addcredit_reply->charge[xcnt].item_deductible_amt
      SET cr->patient_responsibility_flag = addcredit_reply->charge[xcnt].patient_responsibility_flag
      SET cr->person_name = addcredit_reply->charge[xcnt].person_name
      SET cr->username = addcredit_reply->charge[xcnt].username
      SET cr->updt_cnt = addcredit_reply->charge[xcnt].updt_cnt
      SET cr->updt_dt_tm = addcredit_reply->charge[xcnt].updt_dt_tm
      SET cr->updt_id = addcredit_reply->charge[xcnt].updt_id
      SET cr->updt_task = addcredit_reply->charge[xcnt].updt_task
      SET cr->updt_applctx = addcredit_reply->charge[xcnt].updt_applctx
      SET cr->active_ind = addcredit_reply->charge[xcnt].active_ind
      SET cr->active_status_cd = addcredit_reply->charge[xcnt].active_status_cd
      SET cr->active_status_dt_tm = addcredit_reply->charge[xcnt].active_status_dt_tm
      SET cr->active_status_prsnl_id = addcredit_reply->charge[xcnt].active_status_prsnl_id
      SET cr->beg_effective_dt_tm = addcredit_reply->charge[xcnt].beg_effective_dt_tm
      SET cr->end_effective_dt_tm = addcredit_reply->charge[xcnt].end_effective_dt_tm
      FOR (zcnt = 1 TO addcredit_reply->charge[xcnt].charge_mod_qual)
        SET stat = alterlist(cr->charge_mod,zcnt)
        SET cr->charge_mod[zcnt].charge_mod_id = addcredit_reply->charge[xcnt].charge_mod[zcnt].
        charge_mod_id
        SET cr->charge_mod[zcnt].charge_mod_type_cd = addcredit_reply->charge[xcnt].charge_mod[zcnt].
        charge_mod_type_cd
        SET cr->charge_mod[zcnt].field1_id = addcredit_reply->charge[xcnt].charge_mod[zcnt].field1_id
        SET cr->charge_mod[zcnt].field2_id = addcredit_reply->charge[xcnt].charge_mod[zcnt].field2_id
        SET cr->charge_mod[zcnt].field3_id = addcredit_reply->charge[xcnt].charge_mod[zcnt].field3_id
        SET cr->charge_mod[zcnt].field4_id = addcredit_reply->charge[xcnt].charge_mod[zcnt].field4_id
        SET cr->charge_mod[zcnt].field5_id = addcredit_reply->charge[xcnt].charge_mod[zcnt].field5_id
        SET cr->charge_mod[zcnt].field1 = addcredit_reply->charge[xcnt].charge_mod[zcnt].field1
        SET cr->charge_mod[zcnt].field2 = addcredit_reply->charge[xcnt].charge_mod[zcnt].field2
        SET cr->charge_mod[zcnt].field3 = addcredit_reply->charge[xcnt].charge_mod[zcnt].field3
        SET cr->charge_mod[zcnt].field4 = addcredit_reply->charge[xcnt].charge_mod[zcnt].field4
        SET cr->charge_mod[zcnt].field5 = addcredit_reply->charge[xcnt].charge_mod[zcnt].field5
        SET cr->charge_mod[zcnt].field6 = addcredit_reply->charge[xcnt].charge_mod[zcnt].field6
        SET cr->charge_mod[zcnt].field7 = addcredit_reply->charge[xcnt].charge_mod[zcnt].field7
        SET cr->charge_mod[zcnt].field8 = addcredit_reply->charge[xcnt].charge_mod[zcnt].field8
        SET cr->charge_mod[zcnt].field9 = addcredit_reply->charge[xcnt].charge_mod[zcnt].field9
        SET cr->charge_mod[zcnt].field10 = addcredit_reply->charge[xcnt].charge_mod[zcnt].field10
        SET cr->charge_mod[zcnt].nomen_id = addcredit_reply->charge[xcnt].charge_mod[zcnt].nomen_id
        SET cr->charge_mod[zcnt].cm1_nbr = addcredit_reply->charge[xcnt].charge_mod[zcnt].cm1_nbr
        SET cr->charge_mod_qual = zcnt
      ENDFOR
    ENDFOR
   ENDIF
   IF (validate(debug,- (1)) > 0)
    CALL echo("done with add credit")
   ENDIF
   SET chargefind_request->charge_item_id = request->charge[a].charge_item_id
   EXECUTE afc_charge_find  WITH replace("REQUEST",chargefind_request), replace("REPLY",
    chargefind_reply)
   IF ((((chargefind_reply->charge_item_count < 1)) OR ((chargefind_reply->status_data.status="F")))
   )
    SET reply->status_data.status = "F"
    GO TO end_program
   ENDIF
   SET chargeeventfind_request->charge_item_id = chargefind_reply->charge_items[1].charge_item_id
   EXECUTE afc_charge_event_find  WITH replace("REQUEST",chargeeventfind_request), replace("REPLY",
    chargeeventfind_reply)
   IF ((chargeeventfind_reply->status_data.status="F"))
    SET reply->status_data.status = "F"
    GO TO end_program
   ENDIF
   SET orig_chrg_count += 1
   SET reply->original_charge_qual = orig_chrg_count
   SET stat = alterlist(reply->original_charge,orig_chrg_count)
   SET reply->original_charge[orig_chrg_count].charge_item_id = chargefind_reply->charge_items[1].
   charge_item_id
   SET reply->original_charge[orig_chrg_count].process_flg = chargefind_reply->charge_items[1].
   process_flg
   SET reply->original_charge[orig_chrg_count].updt_id = chargefind_reply->charge_items[1].updt_id
   SET reply->original_charge[orig_chrg_count].updt_task = chargefind_reply->charge_items[1].
   updt_task
   SET reply->original_charge[orig_chrg_count].updt_applctx = chargefind_reply->charge_items[1].
   updt_applctx
   SET reply->original_charge[orig_chrg_count].updt_dt_tm = chargefind_reply->charge_items[1].
   updt_dt_tm
   SELECT INTO "nl:"
    FROM bill_item bi
    WHERE (bi.bill_item_id=chargefind_reply->charge_items[1].bill_item_id)
    DETAIL
     bill_item_info->ext_parent_reference_id = bi.ext_parent_reference_id, bill_item_info->
     ext_parent_contributor_cd = bi.ext_parent_contributor_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO end_program
   ENDIF
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(bill_item_info)
   ENDIF
   SET encounterrequest->encntr_id = chargefind_reply->charge_items[1].encntr_id
   EXECUTE afc_get_person_encounter_info  WITH replace("REQUEST",encounterrequest), replace("REPLY",
    encounterreply)
   IF ((encounterreply->status_data.status="F"))
    SET reply->status_data.status = "F"
    GO TO end_program
   ENDIF
   SET stat = alterlist(pirequest->objarray,1)
   SET pirequest->objarray[1].ext_parent_reference_id = bill_item_info->ext_parent_reference_id
   SET pirequest->objarray[1].ext_parent_contributor_cd = bill_item_info->ext_parent_contributor_cd
   SET pirequest->objarray[1].ord_loc_cd = chargefind_reply->charge_items[1].ord_loc_cd
   SET pirequest->objarray[1].perf_loc_cd = chargefind_reply->charge_items[1].perf_loc_cd
   SET pirequest->objarray[1].encntr_id = chargefind_reply->charge_items[1].encntr_id
   SET pirequest->objarray[1].person_id = chargefind_reply->charge_items[1].person_id
   SET pirequest->objarray[1].encntr_org_id = chargefind_reply->charge_items[1].payor_id
   SET pirequest->objarray[1].fin_class_cd = chargefind_reply->charge_items[1].fin_class_cd
   SET pirequest->objarray[1].encntr_type_cd = encounterreply->person_encounter[1].encntr_type_cd
   SET pirequest->objarray[1].health_plan_id = encounterreply->person_encounter[1].health_plan_id
   SET pirequest->objarray[1].loc_nurse_unit_cd = encounterreply->person_encounter[1].
   loc_nurse_unit_cd
   SET pirequest->objarray[1].service_dt_tm = chargefind_reply->charge_items[1].service_dt_tm
   SET pirequest->objarray[1].item_quantity = cnvtint((main_cfr->item_quantity - request->charge[a].
    credit_amt))
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(pirequest)
   ENDIF
   EXECUTE afc_run_price_inquiry  WITH replace("REQUEST",pirequest), replace("REPLY",pireply)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(pireply)
   ENDIF
   SET pi_size = size(pireply->charges,5)
   IF (pi_size > 0)
    FOR (pi_count = 1 TO pi_size)
      IF ((pireply->charges[pi_count].tier_group_cd=chargefind_reply->charge_items[1].tier_group_cd)
       AND (pireply->charges[pi_count].bill_item_id=chargefind_reply->charge_items[1].bill_item_id))
       SET hold_item_price = pireply->charges[pi_count].item_price
       SET hold_item_extended_price = pireply->charges[pi_count].item_extended_price
       SET hold_process_flg = pireply->charges[pi_count].process_flg
       SET pi_count = pi_size
      ENDIF
    ENDFOR
   ELSE
    SET reply->status_data.status = "F"
    GO TO end_program
   ENDIF
   SET stat = alterlist(addcharge_request->objarray,1)
   SET addcharge_request->objarray[1].charge_item_id = 0.0
   SET addcharge_request->objarray[1].parent_charge_item_id = request->charge[a].charge_item_id
   SET addcharge_request->objarray[1].charge_event_act_id = main_cfr->charge_event_act_id
   SET addcharge_request->objarray[1].charge_event_id = main_cfr->charge_event_id
   SET addcharge_request->objarray[1].bill_item_id = main_cfr->bill_item_id
   SET addcharge_request->objarray[1].order_id = main_cfr->order_id
   SET addcharge_request->objarray[1].encntr_id = main_cfr->encntr_id
   SET addcharge_request->objarray[1].person_id = main_cfr->person_id
   SET addcharge_request->objarray[1].payor_id = main_cfr->payor_id
   SET addcharge_request->objarray[1].perf_loc_cd = main_cfr->perf_loc_cd
   SET addcharge_request->objarray[1].ord_loc_cd = main_cfr->ord_loc_cd
   SET addcharge_request->objarray[1].ord_phys_id = main_cfr->ord_phys_id
   SET addcharge_request->objarray[1].perf_phys_id = main_cfr->perf_phys_id
   SET addcharge_request->objarray[1].charge_description = main_cfr->charge_description
   SET addcharge_request->objarray[1].price_sched_id = main_cfr->price_sched_id
   SET addcharge_request->objarray[1].item_quantity = (cnvtreal(main_cfr->item_quantity) - cnvtreal(
    request->charge[a].credit_amt))
   SET addcharge_request->objarray[1].item_price = hold_item_price
   SET addcharge_request->objarray[1].item_extended_price = hold_item_extended_price
   SET addcharge_request->objarray[1].item_allowable = main_cfr->item_allowable
   SET addcharge_request->objarray[1].item_copay = main_cfr->item_copay
   SET addcharge_request->objarray[1].charge_type_cd = main_cfr->charge_type_cd
   SET addcharge_request->objarray[1].research_acct_id = main_cfr->research_acct_id
   SET addcharge_request->objarray[1].suspense_rsn_cd = request->charge[a].susp_rsn_cd
   SET addcharge_request->objarray[1].reason_comment = request->charge[a].reason_comment
   SET addcharge_request->objarray[1].posted_cd = main_cfr->posted_cd
   SET addcharge_request->objarray[1].process_flg = hold_process_flg
   SET addcharge_request->objarray[1].service_dt_tm = main_cfr->service_dt_tm
   SET addcharge_request->objarray[1].activity_dt_tm = cnvtdatetime(sysdate)
   SET addcharge_request->objarray[1].interface_file_id = main_cfr->interface_file_id
   SET addcharge_request->objarray[1].tier_group_cd = main_cfr->tier_group_cd
   SET addcharge_request->objarray[1].def_bill_item_id = main_cfr->def_bill_item_id
   SET addcharge_request->objarray[1].verify_phys_id = main_cfr->verify_phys_id
   SET addcharge_request->objarray[1].gross_price = main_cfr->gross_price
   SET addcharge_request->objarray[1].discount_amount = main_cfr->discount_amount
   SET addcharge_request->objarray[1].manual_ind = main_cfr->manual_ind
   SET addcharge_request->objarray[1].activity_type_cd = main_cfr->activity_type_cd
   SET addcharge_request->objarray[1].activity_sub_type_cd = main_cfr->activity_sub_type_cd
   SET addcharge_request->objarray[1].provider_specialty_cd = main_cfr->provider_specialty_cd
   SET addcharge_request->objarray[1].admit_type_cd = main_cfr->admit_type_cd
   SET addcharge_request->objarray[1].department_cd = main_cfr->department_cd
   SET addcharge_request->objarray[1].institution_cd = main_cfr->institution_cd
   SET addcharge_request->objarray[1].level5_cd = main_cfr->level5_cd
   SET addcharge_request->objarray[1].med_service_cd = main_cfr->med_service_cd
   SET addcharge_request->objarray[1].section_cd = main_cfr->section_cd
   SET addcharge_request->objarray[1].subsection_cd = main_cfr->subsection_cd
   SET addcharge_request->objarray[1].abn_status_cd = main_cfr->abn_status_cd
   SET addcharge_request->objarray[1].cost_center_cd = main_cfr->cost_center_cd
   SET addcharge_request->objarray[1].inst_fin_nbr = main_cfr->inst_fin_nbr
   SET addcharge_request->objarray[1].fin_class_cd = main_cfr->fin_class_cd
   SET addcharge_request->objarray[1].health_plan_id = main_cfr->health_plan_id
   SET addcharge_request->objarray[1].item_interval_id = main_cfr->item_interval_id
   SET addcharge_request->objarray[1].item_list_price = main_cfr->item_list_price
   SET addcharge_request->objarray[1].item_reimbursement = main_cfr->item_reimbursement
   SET addcharge_request->objarray[1].list_price_sched_id = main_cfr->list_price_sched_id
   SET addcharge_request->objarray[1].payor_type_cd = main_cfr->payor_type_cd
   SET addcharge_request->objarray[1].epsdt_ind = main_cfr->epsdt_ind
   SET addcharge_request->objarray[1].ref_phys_id = main_cfr->ref_phys_id
   SET addcharge_request->objarray[1].start_dt_tm = main_cfr->start_dt_tm
   SET addcharge_request->objarray[1].stop_dt_tm = main_cfr->stop_dt_tm
   SET addcharge_request->objarray[1].alpha_nomen_id = main_cfr->alpha_nomen_id
   SET addcharge_request->objarray[1].server_process_flag = main_cfr->server_process_flag
   SET addcharge_request->objarray[1].item_deductible_amt = main_cfr->item_deductible_amt
   SET addcharge_request->objarray[1].patient_responsibility_flag = main_cfr->
   patient_responsibility_flag
   SET addcharge_request->objarray[1].active_ind = 1
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(addcharge_request)
   ENDIF
   EXECUTE afc_add_charge  WITH replace("REQUEST",addcharge_request), replace("REPLY",addcharge_reply
    )
   IF ((addcharge_reply->status_data.status="F"))
    SET reply->status_data.status = "F"
    GO TO end_program
   ENDIF
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(addcharge_reply)
   ENDIF
   SET addchargemodreq->charge_mod_qual = main_cfr->charge_mod_count
   SET stat = alterlist(addchargemodreq->charge_mod,main_cfr->charge_mod_count)
   FOR (zcnt = 1 TO main_cfr->charge_mod_count)
     SET addchargemodreq->charge_mod[zcnt].charge_item_id = addcharge_request->objarray[1].
     charge_item_id
     SET addchargemodreq->charge_mod[zcnt].charge_mod_type_cd = main_cfr->charge_mods[zcnt].
     charge_mod_type_cd
     SET addchargemodreq->charge_mod[zcnt].field1_id = main_cfr->charge_mods[zcnt].field1_id
     SET addchargemodreq->charge_mod[zcnt].field2_id = main_cfr->charge_mods[zcnt].field2_id
     SET addchargemodreq->charge_mod[zcnt].field3_id = main_cfr->charge_mods[zcnt].field3_id
     SET addchargemodreq->charge_mod[zcnt].field4_id = main_cfr->charge_mods[zcnt].field4_id
     SET addchargemodreq->charge_mod[zcnt].field5_id = main_cfr->charge_mods[zcnt].field5_id
     SET addchargemodreq->charge_mod[zcnt].field1 = main_cfr->charge_mods[zcnt].field1
     SET addchargemodreq->charge_mod[zcnt].field2 = main_cfr->charge_mods[zcnt].field2
     SET addchargemodreq->charge_mod[zcnt].field3 = main_cfr->charge_mods[zcnt].field3
     SET addchargemodreq->charge_mod[zcnt].field4 = main_cfr->charge_mods[zcnt].field4
     SET addchargemodreq->charge_mod[zcnt].field5 = main_cfr->charge_mods[zcnt].field5
     SET addchargemodreq->charge_mod[zcnt].field6 = main_cfr->charge_mods[zcnt].field6
     SET addchargemodreq->charge_mod[zcnt].field7 = main_cfr->charge_mods[zcnt].field7
     SET addchargemodreq->charge_mod[zcnt].field8 = main_cfr->charge_mods[zcnt].field8
     SET addchargemodreq->charge_mod[zcnt].field9 = main_cfr->charge_mods[zcnt].field9
     SET addchargemodreq->charge_mod[zcnt].field10 = main_cfr->charge_mods[zcnt].field10
     SET addchargemodreq->charge_mod[zcnt].nomen_id = main_cfr->charge_mods[zcnt].nomen_id
     SET addchargemodreq->charge_mod[zcnt].cm1_nbr = main_cfr->charge_mods[zcnt].cm1_nbr
     SET addchargemodreq->charge_mod[zcnt].activity_dt_tm = main_cfr->charge_mods[zcnt].
     activity_dt_tm
     SET addchargemodreq->charge_mod[zcnt].action_type = "ADD"
   ENDFOR
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(addchargemodreq)
   ENDIF
   SET action_begin = 1
   SET action_end = addchargemodreq->charge_mod_qual
   EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addchargemodreq), replace("REPLY",
    addchargemodrep)
   IF ((addchargemodrep->status_data.status="F"))
    SET reply->status_data.status = "F"
    GO TO end_program
   ENDIF
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(addchargemodrep)
   ENDIF
   SET reply->status_data.status = "S"
   SET stat = alterlist(afcinterfacecharge_request->interface_charge,0)
   SET stat = alterlist(afcprofit_request->charges,0)
   SELECT INTO "nl:"
    FROM interface_file i
    WHERE (i.interface_file_id=addcharge_request->objarray[1].interface_file_id)
    DETAIL
     IF (i.realtime_ind=1)
      stat = alterlist(afcinterfacecharge_request->interface_charge,2), afcinterfacecharge_request->
      interface_charge[1].charge_item_id = addcredit_reply->charge[1].charge_item_id,
      afcinterfacecharge_request->interface_charge[2].charge_item_id = addcharge_request->objarray[1]
      .charge_item_id
     ELSEIF (i.profit_type_cd > 0)
      stat = alterlist(afcprofit_request->charges,2), afcprofit_request->charges[1].charge_item_id =
      addcredit_reply->charge[1].charge_item_id, afcprofit_request->charges[2].charge_item_id =
      addcharge_request->objarray[1].charge_item_id
     ENDIF
    WITH nocounter
   ;end select
   IF (size(afcprofit_request->charges,5) > 0)
    IF (validate(debug,- (1)) > 0)
     CALL echorecord(afcprofit_request)
    ENDIF
    EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",afcprofit_request), replace("REPLY",
     afcprofit_reply)
   ELSEIF (size(afcinterfacecharge_request->interface_charge,5) > 0)
    IF (validate(debug,- (1)) > 0)
     CALL echorecord(afcinterfacecharge_request)
    ENDIF
    EXECUTE afc_srv_interface_charge  WITH replace("REQUEST",afcinterfacecharge_request), replace(
     "REPLY",afcinterfacecharge_reply)
    IF (validate(debug,- (1)) > 0)
     CALL echorecord(afcinterfacecharge_reply)
    ENDIF
    IF ((afcinterfacecharge_reply->status_data.status="F"))
     CALL echo("Afc_Srv_Interface_Charge Failed")
    ENDIF
   ENDIF
   SET chargefind_request->charge_item_id = addcharge_request->objarray[1].charge_item_id
   EXECUTE afc_charge_find  WITH replace("REQUEST",chargefind_request), replace("REPLY",
    chargefind_reply)
   FOR (xcnt = 1 TO chargefind_reply->charge_item_count)
     IF ((chargefind_reply->status_data.status != "F")
      AND (chargefind_reply->charge_item_count > 0))
      SET main_charge_count += 1
      SET stat = alterlist(reply->charge,main_charge_count)
      SET curalias cr reply->charge[main_charge_count]
      SET cr->charge_item_id = main_cfr->charge_item_id
      SET cr->parent_charge_item_id = main_cfr->parent_charge_item_id
      SET cr->charge_event_act_id = main_cfr->charge_event_act_id
      SET cr->charge_event_id = main_cfr->charge_event_id
      SET cr->bill_item_id = main_cfr->bill_item_id
      SET cr->order_id = main_cfr->order_id
      SET cr->encntr_id = main_cfr->encntr_id
      SET cr->person_id = main_cfr->person_id
      SET cr->payor_id = main_cfr->payor_id
      SET cr->perf_loc_cd = main_cfr->perf_loc_cd
      SET cr->ord_loc_cd = main_cfr->ord_loc_cd
      SET cr->ord_phys_id = main_cfr->ord_phys_id
      SET cr->perf_phys_id = main_cfr->perf_phys_id
      SET cr->charge_description = main_cfr->charge_description
      SET cr->price_sched_id = main_cfr->price_sched_id
      SET cr->item_quantity = main_cfr->item_quantity
      SET cr->item_price = main_cfr->item_price
      SET cr->item_extended_price = main_cfr->item_extended_price
      SET cr->item_allowable = main_cfr->item_allowable
      SET cr->item_copay = main_cfr->item_copay
      SET cr->charge_type_cd = main_cfr->charge_type_cd
      SET cr->research_acct_id = main_cfr->research_acct_id
      SET cr->suspense_rsn_cd = main_cfr->suspense_rsn_cd
      SET cr->reason_comment = main_cfr->reason_comment
      SET cr->posted_cd = main_cfr->posted_cd
      SET cr->posted_dt_tm = main_cfr->posted_dt_tm
      SET cr->process_flg = main_cfr->process_flg
      SET cr->service_dt_tm = main_cfr->service_dt_tm
      SET cr->activity_dt_tm = main_cfr->activity_dt_tm
      SET cr->credited_dt_tm = main_cfr->credited_dt_tm
      SET cr->adjusted_dt_tm = main_cfr->adjusted_dt_tm
      SET cr->interface_file_id = main_cfr->interface_file_id
      SET cr->tier_group_cd = main_cfr->tier_group_cd
      SET cr->def_bill_item_id = main_cfr->def_bill_item_id
      SET cr->verify_phys_id = main_cfr->verify_phys_id
      SET cr->gross_price = main_cfr->gross_price
      SET cr->discount_amount = main_cfr->discount_amount
      SET cr->manual_ind = main_cfr->manual_ind
      SET cr->combine_ind = main_cfr->combine_ind
      SET cr->bundle_id = main_cfr->bundle_id
      SET cr->institution_cd = main_cfr->institution_cd
      SET cr->department_cd = main_cfr->department_cd
      SET cr->section_cd = main_cfr->section_cd
      SET cr->subsection_cd = main_cfr->subsection_cd
      SET cr->level5_cd = main_cfr->level5_cd
      SET cr->admit_type_cd = main_cfr->admit_type_cd
      SET cr->med_service_cd = main_cfr->med_service_cd
      SET cr->activity_type_cd = main_cfr->activity_type_cd
      IF (validate(cr->activity_sub_type_cd))
       SET cr->activity_sub_type_cd = main_cfr->activity_sub_type_cd
      ENDIF
      IF (validate(cr->provider_specialty_cd))
       SET cr->provider_specialty_cd = main_cfr->provider_specialty_cd
      ENDIF
      SET cr->inst_fin_nbr = main_cfr->inst_fin_nbr
      SET cr->cost_center_cd = main_cfr->cost_center_cd
      SET cr->abn_status_cd = main_cfr->abn_status_cd
      SET cr->health_plan_id = main_cfr->health_plan_id
      SET cr->fin_class_cd = main_cfr->fin_class_cd
      SET cr->payor_type_cd = main_cfr->payor_type_cd
      SET cr->item_reimbursement = main_cfr->item_reimbursement
      SET cr->item_interval_id = main_cfr->item_interval_id
      SET cr->item_list_price = main_cfr->item_list_price
      SET cr->list_price_sched_id = main_cfr->list_price_sched_id
      SET cr->start_dt_tm = main_cfr->start_dt_tm
      SET cr->stop_dt_tm = main_cfr->stop_dt_tm
      SET cr->epsdt_ind = main_cfr->epsdt_ind
      SET cr->ref_phys_id = main_cfr->ref_phys_id
      SET cr->item_deductible_amt = main_cfr->item_deductible_amt
      SET cr->patient_responsibility_flag = main_cfr->patient_responsibility_flag
      SET cr->person_name = main_cfr->person_name
      SET cr->username = main_cfr->username
      SET cr->updt_cnt = main_cfr->updt_cnt
      SET cr->updt_dt_tm = main_cfr->updt_dt_tm
      SET cr->updt_id = main_cfr->updt_id
      SET cr->updt_task = main_cfr->updt_task
      SET cr->updt_applctx = main_cfr->updt_applctx
      SET cr->active_ind = main_cfr->active_ind
      SET cr->active_status_cd = main_cfr->active_status_cd
      SET cr->active_status_dt_tm = main_cfr->active_status_dt_tm
      SET cr->active_status_prsnl_id = main_cfr->active_status_prsnl_id
      SET cr->beg_effective_dt_tm = main_cfr->beg_effective_dt_tm
      SET cr->end_effective_dt_tm = main_cfr->end_effective_dt_tm
      FOR (zcnt = 1 TO main_cfr->charge_mod_count)
        SET stat = alterlist(cr->charge_mod,zcnt)
        SET cr->charge_mod[zcnt].charge_mod_id = main_cfr->charge_mods[zcnt].charge_mod_id
        SET cr->charge_mod[zcnt].charge_mod_type_cd = main_cfr->charge_mods[zcnt].charge_mod_type_cd
        SET cr->charge_mod[zcnt].field1_id = main_cfr->charge_mods[zcnt].field1_id
        SET cr->charge_mod[zcnt].field2_id = main_cfr->charge_mods[zcnt].field2_id
        SET cr->charge_mod[zcnt].field3_id = main_cfr->charge_mods[zcnt].field3_id
        SET cr->charge_mod[zcnt].field4_id = main_cfr->charge_mods[zcnt].field4_id
        SET cr->charge_mod[zcnt].field5_id = main_cfr->charge_mods[zcnt].field5_id
        SET cr->charge_mod[zcnt].field1 = main_cfr->charge_mods[zcnt].field1
        SET cr->charge_mod[zcnt].field2 = main_cfr->charge_mods[zcnt].field2
        SET cr->charge_mod[zcnt].field3 = main_cfr->charge_mods[zcnt].field3
        SET cr->charge_mod[zcnt].field4 = main_cfr->charge_mods[zcnt].field4
        SET cr->charge_mod[zcnt].field5 = main_cfr->charge_mods[zcnt].field5
        SET cr->charge_mod[zcnt].field6 = main_cfr->charge_mods[zcnt].field6
        SET cr->charge_mod[zcnt].field7 = main_cfr->charge_mods[zcnt].field7
        SET cr->charge_mod[zcnt].field8 = main_cfr->charge_mods[zcnt].field8
        SET cr->charge_mod[zcnt].field9 = main_cfr->charge_mods[zcnt].field9
        SET cr->charge_mod[zcnt].field10 = main_cfr->charge_mods[zcnt].field10
        SET cr->charge_mod[zcnt].nomen_id = main_cfr->charge_mods[zcnt].nomen_id
        SET cr->charge_mod[zcnt].cm1_nbr = main_cfr->charge_mods[zcnt].cm1_nbr
        SET cr->charge_mod_qual = zcnt
      ENDFOR
     ELSE
      SET reply->status_data.status = "F"
     ENDIF
   ENDFOR
 ENDFOR
 SET reply->charge_qual = size(reply->charge,5)
#end_program
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE SET addcredit_request
 FREE SET addcredit_reply
 FREE SET chargefind_request
 FREE SET chargefind_reply
 FREE SET chargeeventfind_request
 FREE SET chargeeventfind_reply
 FREE SET encounterrequest
 FREE SET encounterreply
 FREE SET bill_item_info
 FREE SET pirequest
 FREE SET pireply
 FREE SET addcharge_request
 FREE SET addcharge_reply
 FREE SET addchargemodreq
 FREE SET addchargemodrep
 FREE SET afcprofit_request
 FREE SET afcprofit_reply
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(reply)
 ENDIF
END GO
