CREATE PROGRAM afc_encntr_mods_legacy:dba
 IF ("Z"=validate(afc_encntr_mods_vrsn,"Z"))
  DECLARE afc_encntr_mods_vrsn = vc WITH noconstant("XXXXX.XX.XXX"), public
 ENDIF
 SET afc_encntr_mods_vrsn = "521409.116"
 FREE RECORD reqclinchrgfind
 RECORD reqclinchrgfind(
   1 encntr_id = f8
 )
 FREE RECORD replclinencobj
 RECORD replclinencobj(
   1 obj_vrsn_5 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
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
     2 disch_dt_tm = dq8
     2 guarantor_name = vc
     2 org_ind = f8
     2 person_name = vc
     2 person_id = f8
     2 fin_nbr = vc
     2 admit_dt_tm = dq8
     2 co_pay_amount = f8
     2 co_ins_amount = f8
     2 encntr_type_cd = f8
     2 encntr_type_disp = vc
     2 encntr_type_desc = vc
     2 encntr_type_mean = vc
     2 encntr_type_code_set = i4
     2 encntr_type_class_cd = f8
     2 encntr_type_class_disp = vc
     2 encntr_type_class_desc = vc
     2 encntr_type_class_mean = vc
     2 encntr_type_class_code_set = i4
     2 encntr_location = vc
     2 reg_dt_tm = dq8
     2 med_service_cd = f8
     2 med_service_disp = vc
     2 med_service_desc = vc
     2 med_service_mean = vc
     2 med_service_code_set = i4
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = vc
     2 loc_nurse_unit_desc = vc
     2 loc_nurse_unit_mean = vc
     2 loc_nurse_unit_code_set = i4
     2 fin_class_cd = f8
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
 FREE RECORD pmcharge
 RECORD pmcharge(
   1 charge_item_count = i4
   1 charge_items[*]
     2 charge_item_id = f8
     2 parent_charge_item_id = f8
     2 charge_event_act_id = f8
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
     2 process_flg = i4
     2 service_dt_tm = dq8
     2 activity_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
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
     2 verify_phys_id = f8
     2 def_bill_item_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 manual_ind = i2
     2 combine_ind = i2
     2 activity_type_cd = f8
     2 activity_dt_tm = dq8
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
     2 inst_fin_nbr = c50
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
     2 person_name = vc
     2 username = vc
     2 dont_process_this_charge = i2
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 retier_ind = i2
     2 checkprice_ind = i2
     2 checkcpt_ind = i2
     2 uptchargemodflag = i2
     2 pftchargeflag = i2
     2 charge_event_id = f8
     2 upt_quantity = f8
     2 charge_mod_count = i4
     2 charge_mods[*]
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
       3 delmodind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD fincob
 RECORD fincob(
   1 fincob_cnt = i4
   1 fincob[*]
     2 hp_id = f8
     2 priority_seq = i2
     2 selfpay_ind = i2
 )
 FREE RECORD objtmpholdfe
 RECORD objtmpholdfe(
   1 proxy_ind = i2
   1 obj_vrsn_2 = f8
   1 active_flag = i2
   1 ein_type = i4
   1 objarray[*]
     2 prompt_keep_in_array = i2
     2 pft_encntr_id = f8
     2 bo_hp_reltn_id = f8
     2 pft_balance_id = f8
     2 hold_parent_description = vc
     2 pe_status_reason_id = f8
     2 pe_status_reason_cd = f8
     2 pe_status_reason_disp = vc
     2 pe_status_reason_desc = vc
     2 pe_status_reason_mean = vc
     2 pe_status_reason_code_set = i4
     2 hold_type = vc
     2 pe_hold_dt_tm = dq8
     2 pe_release_dt_tm = dq8
     2 pft_hold_id = f8
     2 claim_suppress_ind = i2
     2 interim_claim_suppress_ind = i2
     2 1450_suppress_ind = i2
     2 1500_suppress_ind = i2
     2 bill_hold_rpts_suppress_ind = i2
     2 reason_comment = c40
     2 stmt_suppress_ind = i2
     2 precoll_suppress_ind = i2
     2 coll_suppress_ind = i2
     2 dunning_suppress_ind = i2
     2 pe_sub_status_reason_cd = f8
     2 pe_sub_status_reason_disp = vc
     2 pe_sub_status_reason_desc = vc
     2 pe_sub_status_reason_mean = vc
     2 pe_sub_status_reason_code_set = i4
     2 entity_instance_desc = vc
     2 entity_resource_large_key = vc
     2 entity_resource_small_key = vc
     2 entity_name = vc
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_disp = vc
     2 active_status_desc = vc
     2 active_status_mean = vc
     2 active_status_code_set = i4
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_applctx = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
 )
 RECORD objchargerequest(
   1 objarray[1]
     2 encntr_id = f8
 )
 FREE RECORD objfincharge
 RECORD objfincharge(
   1 obj_vrsn_1 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
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
     2 encntr_type_cd = f8
     2 encntr_type_disp = vc
     2 encntr_type_desc = vc
     2 encntr_type_mean = vc
     2 encntr_type_code_set = f8
     2 pft_charge_status_cd = f8
     2 pft_charge_status_disp = vc
     2 pft_charge_status_desc = vc
     2 pft_charge_status_mean = vc
     2 pft_charge_status_code_set = f8
     2 dr_acct_templ_id = f8
     2 cr_acct_templ_id = f8
     2 dr_acct_id = f8
     2 cr_acct_id = f8
     2 billing_quantity = i4
     2 parent_entity_id = f8
     2 late_chrg_flag = i2
     2 offset_ind = i2
     2 trans_type_cd = f8
     2 trans_amount = f8
     2 item_extended_price = f8
     2 service_dt_tm = dq8
     2 parent_charge_item_id = f8
     2 charge_description = vc
     2 charge_type_cd = f8
     2 charge_type_disp = vc
     2 charge_type_desc = vc
     2 charge_type_mean = vc
     2 charge_type_code_set = f8
     2 item_quantity = f8
     2 item_price = f8
     2 ord_loc_cd = f8
     2 perf_loc_cd = f8
     2 tier_group_cd = f8
     2 charge_bo_reltn_id = f8
     2 revenue_code = f8
     2 hcpcs_code = vc
     2 cpt4_code = vc
     2 pcbr_updt_cnt = i4
     2 alt_billing_amt = f8
     2 alt_billing_qty = i4
     2 ext_master_event_id = f8
     2 ext_master_event_cont_cd = f8
     2 ext_master_reference_id = f8
     2 ext_master_reference_cont_cd = f8
     2 ext_item_event_id = f8
     2 ext_item_event_cont_cd = f8
     2 ext_item_reference_id = f8
     2 ext_item_reference_cont_cd = f8
     2 primary_covered_ind = i2
     2 secondary_covered_ind = i2
     2 tertiary_covered_ind = i2
     2 patient_responsibility_flag = i2
     2 documentation_date = vc
     2 documentation_minutes = f8
     2 number_of_clients = f8
     2 number_of_therapists = f8
     2 session_minutes = f8
     2 travel_minutes = f8
     2 icd9_1 = vc
     2 icd9_desc_1 = vc
     2 bc_type_icd9 = f8
     2 perf_phys_id = f8
     2 charge_event_id = f8
     2 charge_event_act_id = f8
     2 entity_instance_desc = vc
     2 entity_resource_large_key = vc
     2 entity_resource_small_key = vc
     2 entity_name = vc
     2 bim_ind = i2
     2 covered_bitmap = i4
     2 suppress_flag = i2
     2 suppress_txt = vc
     2 provider_specialty_cd = f8
     2 activity_qual[*]
       3 activity_id = f8
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
 )
 FREE RECORD pactbreq
 RECORD pactbreq(
   1 pftcharges[*]
     2 pftchargeid = f8
 )
 FREE RECORD pactbrep
 RECORD pactbrep(
   1 pftencntrs[*]
     2 pftencntrid = f8
     2 pftcharges[*]
       3 pftchargeid = f8
       3 selfpaybenefitorderid = f8
       3 nonselfpaybenefitorderid = f8
       3 chargegroupconditionid = f8
       3 chargegroupconditionname = vc
       3 billtemplateruleid = f8
       3 billtemplaterulename = vc
       3 billtemplateid = f8
       3 billtemplatename = vc
   1 error_cd = f8
   1 error_prog = vc
   1 error_sub = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reply(
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
 RECORD objbobillheaderreply(
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
 RECORD encounterrequest(
   1 objarray[1]
     2 encntr_id = f8
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD crelease(
   1 process_type_cd = f8
   1 charge_event_qual = i2
   1 process_event[*]
     2 charge_event_id = f8
     2 charge_item[*]
       3 charge_item_id = f8
   1 facility_transfer_ind = i2
 )
 RECORD creleasereply(
   1 charges[*]
     2 charge_item_id = f8
     2 charge_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 charge_description = c200
     2 price_sched_id = f8
     2 payor_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 charge_type_cd = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = c200
     2 posted_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 order_id = f8
     2 beg_effective_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 admit_type_cd = f8
     2 med_service_cd = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 service_dt_tm = dq8
     2 process_flg = i2
     2 parent_charge_item_id = f8
     2 interface_id = f8
     2 tier_group_cd = f8
     2 def_bill_item_id = f8
     2 verify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 activity_type_cd = f8
     2 research_acct_id = f8
     2 cost_center_cd = f8
     2 abn_status_cd = f8
     2 perf_loc_cd = f8
     2 inst_fin_nbr = c50
     2 ord_loc_cd = f8
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 manual_ind = i2
     2 updt_ind = i2
     2 payor_type_cd = f8
     2 item_copay = f8
     2 item_reimbursement = f8
     2 posted_dt_tm = dq8
     2 item_interval_id = f8
     2 list_price = f8
     2 list_price_sched_id = f8
     2 realtime_ind = i2
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 alpha_nomen_id = f8
     2 server_process_flag = i2
     2 hp_beg_effective_dt_tm = dq8
     2 hp_end_effective_dt_tm = dq8
     2 mods
       3 charge_mods[*]
         4 mod_id = f8
         4 charge_event_id = f8
         4 charge_event_mod_type_cd = f8
         4 charge_item_id = f8
         4 charge_mod_type_cd = f8
         4 field1 = c200
         4 field2 = c200
         4 field3 = c200
         4 field4 = c200
         4 field5 = c200
         4 field6 = c200
         4 field7 = c200
         4 field8 = c200
         4 field9 = c200
         4 field10 = c200
         4 field1_id = f8
         4 field2_id = f8
         4 field3_id = f8
         4 field4_id = f8
         4 field5_id = f8
         4 nomen_id = f8
         4 cm1_nbr = f8
         4 activity_dt_tm = dq8
     2 offset_charge_item_id = f8
     2 patient_responsibility_flag = i2
     2 item_deductible_amt = f8
   1 srv_diag[*]
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 charge_event_act_id = f8
     2 srv_diag_cd = f8
     2 srv_diag1_id = f8
     2 srv_diag2_id = f8
     2 srv_diag3_id = f8
     2 srv_diag_tier = f8
     2 srv_diag_reason = c200
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD chargeinterfacelist(
   1 charges[*]
     2 charge_item_id = f8
     2 interface_id = f8
     2 charge_type_cd = f8
 )
 RECORD creditonlyinterfacelist(
   1 charges[*]
     2 charge_item_id = f8
     2 interface_id = f8
     2 charge_type_cd = f8
 )
 RECORD chargereleasecopy(
   1 charges[*]
     2 charge_item_id = f8
     2 charge_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 charge_description = c200
     2 price_sched_id = f8
     2 payor_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 charge_type_cd = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = c200
     2 posted_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 order_id = f8
     2 beg_effective_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 admit_type_cd = f8
     2 med_service_cd = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 service_dt_tm = dq8
     2 process_flg = i2
     2 parent_charge_item_id = f8
     2 interface_id = f8
     2 tier_group_cd = f8
     2 def_bill_item_id = f8
     2 verify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 activity_type_cd = f8
     2 research_acct_id = f8
     2 cost_center_cd = f8
     2 abn_status_cd = f8
     2 perf_loc_cd = f8
     2 inst_fin_nbr = c50
     2 ord_loc_cd = f8
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 manual_ind = i2
     2 updt_ind = i2
     2 payor_type_cd = f8
     2 item_copay = f8
     2 item_reimbursement = f8
     2 posted_dt_tm = dq8
     2 item_interval_id = f8
     2 list_price = f8
     2 list_price_sched_id = f8
     2 realtime_ind = i2
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 alpha_nomen_id = f8
     2 server_process_flag = i2
     2 hp_beg_effective_dt_tm = dq8
     2 hp_end_effective_dt_tm = dq8
     2 original_org_id = f8
     2 mods
       3 charge_mods[*]
         4 mod_id = f8
         4 charge_event_id = f8
         4 charge_event_mod_type_cd = f8
         4 charge_item_id = f8
         4 charge_mod_type_cd = f8
         4 field1 = c200
         4 field2 = c200
         4 field3 = c200
         4 field4 = c200
         4 field5 = c200
         4 field6 = c200
         4 field7 = c200
         4 field8 = c200
         4 field9 = c200
         4 field10 = c200
         4 field1_id = f8
         4 field2_id = f8
         4 field3_id = f8
         4 field4_id = f8
         4 field5_id = f8
         4 nomen_id = f8
         4 cm1_nbr = f8
         4 activity_dt_tm = dq8
     2 offset_charge_item_id = f8
     2 patient_responsibility_flag = i2
     2 item_deductible_amt = f8
   1 srv_diag[*]
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 charge_event_act_id = f8
     2 srv_diag_cd = f8
     2 srv_diag1_id = f8
     2 srv_diag2_id = f8
     2 srv_diag3_id = f8
     2 srv_diag_tier = f8
     2 srv_diag_reason = c200
 )
 RECORD pbmchargecopy(
   1 charges[*]
     2 charge_item_id = f8
     2 charge_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 charge_description = c200
     2 price_sched_id = f8
     2 payor_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 charge_type_cd = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = c200
     2 posted_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 order_id = f8
     2 beg_effective_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 admit_type_cd = f8
     2 med_service_cd = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 service_dt_tm = dq8
     2 process_flg = i2
     2 parent_charge_item_id = f8
     2 interface_id = f8
     2 tier_group_cd = f8
     2 def_bill_item_id = f8
     2 verify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 activity_type_cd = f8
     2 research_acct_id = f8
     2 cost_center_cd = f8
     2 abn_status_cd = f8
     2 perf_loc_cd = f8
     2 inst_fin_nbr = c50
     2 ord_loc_cd = f8
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 manual_ind = i2
     2 updt_ind = i2
     2 payor_type_cd = f8
     2 item_copay = f8
     2 item_reimbursement = f8
     2 posted_dt_tm = dq8
     2 item_interval_id = f8
     2 list_price = f8
     2 list_price_sched_id = f8
     2 realtime_ind = i2
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 alpha_nomen_id = f8
     2 server_process_flag = i2
     2 hp_beg_effective_dt_tm = dq8
     2 hp_end_effective_dt_tm = dq8
     2 mods
       3 charge_mods[*]
         4 mod_id = f8
         4 charge_event_id = f8
         4 charge_event_mod_type_cd = f8
         4 charge_item_id = f8
         4 charge_mod_type_cd = f8
         4 field1 = c200
         4 field2 = c200
         4 field3 = c200
         4 field4 = c200
         4 field5 = c200
         4 field6 = c200
         4 field7 = c200
         4 field8 = c200
         4 field9 = c200
         4 field10 = c200
         4 field1_id = f8
         4 field2_id = f8
         4 field3_id = f8
         4 field4_id = f8
         4 field5_id = f8
         4 nomen_id = f8
         4 cm1_nbr = f8
     2 offset_charge_item_id = f8
     2 patient_responsibility_flag = i2
     2 item_deductible_amt = f8
   1 srv_diag[*]
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 charge_event_act_id = f8
     2 srv_diag_cd = f8
     2 srv_diag1_id = f8
     2 srv_diag2_id = f8
     2 srv_diag3_id = f8
     2 srv_diag_tier = f8
     2 srv_diag_reason = c200
 )
 RECORD afcaddcreditreq(
   1 charge_qual = i2
   1 charge[*]
     2 charge_item_id = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = vc
     2 late_charge_processing_ind = i2
 )
 RECORD afcaddcreditrep(
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
 FREE RECORD afcinterfacecharge_request
 RECORD afcinterfacecharge_request(
   1 interface_charge[*]
     2 charge_item_id = f8
 )
 FREE RECORD afcinterfacecharge_reply
 RECORD afcinterfacecharge_reply(
   1 interface_charge[*]
     2 abn_status_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 activity_type_cd = f8
     2 additional_encntr_phys1_id = f8
     2 additional_encntr_phys2_id = f8
     2 additional_encntr_phys3_id = f8
     2 admit_type_cd = f8
     2 adm_phys_id = f8
     2 attending_phys_id = f8
     2 batch_num = i4
     2 bed_cd = f8
     2 beg_effective_dt_tm = dq8
     2 bill_code1 = c50
     2 bill_code1_desc = c200
     2 bill_code2 = c50
     2 bill_code2_desc = c200
     2 bill_code3 = c50
     2 bill_code3_desc = c200
     2 bill_code_more_ind = i2
     2 bill_code_type_cdf = c12
     2 building_cd = f8
     2 charge_description = c200
     2 charge_item_id = f8
     2 charge_type_cd = f8
     2 code_modifier1_cd = f8
     2 code_modifier2_cd = f8
     2 code_modifier3_cd = f8
     2 code_modifier_more_ind = i2
     2 code_revenue_cd = f8
     2 code_revenue_more_ind = i2
     2 cost_center_cd = f8
     2 department_cd = f8
     2 diag_code1 = c50
     2 diag_code2 = c50
     2 diag_code3 = c50
     2 diag_desc1 = c200
     2 diag_desc2 = c200
     2 diag_desc3 = c200
     2 diag_more_ind = i2
     2 discount_amount = f8
     2 encntr_id = f8
     2 encntr_type_cd = f8
     2 end_effective_dt_tm = dq8
     2 facility_cd = f8
     2 fin_nbr = c50
     2 fin_nbr_type_flg = i4
     2 gross_price = f8
     2 icd9_proc_more_ind = i2
     2 institution_cd = f8
     2 interface_charge_id = f8
     2 interface_file_id = f8
     2 level5_cd = f8
     2 manual_ind = i2
     2 med_nbr = c50
     2 med_service_cd = f8
     2 net_ext_price = f8
     2 nurse_unit_cd = f8
     2 order_dept = i4
     2 order_nbr = c200
     2 ord_doc_nbr = c20
     2 ord_phys_id = f8
     2 organization_id = f8
     2 override_desc = c200
     2 payor_id = f8
     2 perf_loc_cd = f8
     2 perf_phys_id = f8
     2 person_id = f8
     2 person_name = c100
     2 posted_dt_tm = dq8
     2 price = f8
     2 prim_cdm = c50
     2 prim_cdm_desc = c200
     2 prim_cpt = c50
     2 prim_cpt_desc = c200
     2 prim_icd9_proc = c50
     2 prim_icd9_proc_desc = c200
     2 process_flg = i4
     2 quantity = f8
     2 referring_phys_id = f8
     2 room_cd = f8
     2 section_cd = f8
     2 service_dt_tm = dq8
     2 subsection_cd = f8
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 user_def_ind = i2
     2 ndc_ident = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD afcprofit_request
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
 RECORD pbm_request(
   1 qual[*]
     2 param_name = vc
     2 param_value = vc
 )
 RECORD pbm_reply(
   1 qual[*]
     2 param_name = vc
     2 param_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD cm_request(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 action_type = c3
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
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 nomen_id = f8
     2 activity_dt_tm = dq8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = f8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 nomen_entity_reltn_id = f8
     2 cm1_nbr = f8
 )
 RECORD cm_reply(
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
 RECORD mic_request(
   1 charge_item_id = f8
   1 charge_type_cd = f8
   1 process_flg = i4
   1 ord_phys_id = f8
   1 research_acct_id = f8
   1 abn_status_cd = f8
   1 verify_phys_id = f8
   1 perf_loc_cd = f8
   1 service_dt_tm = dq8
   1 suspense_rsn_cd = f8
   1 reason_comment = vc
   1 charge_description = vc
   1 item_price = f8
   1 item_extended_price = f8
   1 item_quantity = f8
   1 late_charge_processing_ind = i2
   1 item_copay = f8
   1 item_deductible_amt = f8
   1 patient_responsibility_flag = i2
   1 modified_copy = i2
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_type_cd = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 nomen_entity_reltn_id = f8
     2 nomen_id = f8
     2 field6 = vc
     2 field7 = vc
 )
 RECORD mic_reply(
   1 charge_qual = i2
   1 dequeued_ind = i2
   1 charge[*]
     2 charge_item_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD nt_request(
   1 remove_commit_ind = i2
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
     2 charge_type_cd = f8
 )
 RECORD reproc_request(
   1 process_type_cd = f8
   1 charge_event_qual = i2
   1 process_event[*]
     2 charge_event_id = f8
     2 charge_acts[*]
       3 charge_event_act_id = f8
     2 charge_item_qual = i2
     2 charge_item[*]
       3 charge_item_id = f8
 )
 RECORD em_afc_chk_profit_install_reply(
   1 profit_installed = i2
 )
 FREE RECORD finencntrfindrequest
 RECORD finencntrfindrequest(
   1 objarray[*]
     2 encntr_id = f8
     2 pft_encntr_id = f8
 )
 FREE RECORD objfinencntrmod
 RECORD objfinencntrmod(
   1 obj_vrsn_5 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 ibillholdrel = i2
     2 iskillnurserel = i2
     2 istddelrel = i2
     2 iskllnurse1 = i2
     2 iskllnurse2 = i2
     2 iskllnurse3 = i2
     2 iqualforst = i2
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
     2 person_name = vc
     2 acct_nbr = vc
     2 fin_nbr = vc
     2 encntrloc = vc
     2 combined_into_id = f8
     2 billing_entity_name = vc
     2 parent_be_id = f8
     2 guarantor_name = vc
     2 admit_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 attenddrnum = f8
     2 attenddrname = vc
     2 admitdrnum = f8
     2 payment_plan_flag = i2
     2 self_pay_edit_flag = i2
     2 co_pay_amount = f8
     2 co_ins_amount = f8
     2 trans_type_cd = f8
     2 trans_amount = f8
     2 balance = f8
     2 adjustment_balance = f8
     2 applied_payment_balance = f8
     2 charge_balance = f8
     2 unapplied_payment_balance = f8
     2 bad_debt_balance = f8
     2 orig_bill_submit_dt_tm = dq8
     2 orig_bill_transmit_dt_tm = dq8
     2 last_claim_dt_tm = dq8
     2 last_stmt_dt_tm = dq8
     2 bill_counter_term = vc
     2 dunning_level_change_dt_tm = dq8
     2 dunning_level_cnt = i4
     2 dunning_ind = i2
     2 dunning_hold_ind = i2
     2 dunning_pay_cnt = i4
     2 dunning_unacc_pay_cnt = i4
     2 dunning_no_pay_cnt = i4
     2 consolidation_ind = i2
     2 col_letter_ind = i2
     2 send_col_ind = i2
     2 pft_encntr_alias = vc
     2 route_user_name = vc
     2 statement_cycle_id = f8
     2 ins_pend_bal_fwd = f8
     2 pat_bal_fwd = f8
     2 conversion_ind = i2
     2 nbr_of_stmts = i4
     2 bad_debt_dt_tm = dq8
     2 late_chrg_flag = i2
     2 late_chrg_start_dt_tm = dq8
     2 last_charge_dt_tm = dq8
     2 last_payment_dt_tm = dq8
     2 last_patient_pay_dt_tm = dq8
     2 last_adjustment_dt_tm = dq8
     2 zero_balance_dt_tm = dq8
     2 recur_ind = i2
     2 recur_seq = i4
     2 recur_bill_gen_ind = f8
     2 recur_current_month = i4
     2 recur_current_year = i4
     2 recur_bill_ready_ind = i2
     2 pt_start_dt_tm = dq8
     2 pt_total_visits = i4
     2 ot_start_dt_tm = dq8
     2 ot_total_visits = i4
     2 slt_start_dt_tm = dq8
     2 slt_total_visits = i4
     2 cr_start_dt_tm = dq8
     2 cr_total_visits = i4
     2 pft_collection_agency_id = f8
     2 collection_agency_type = vc
     2 org_ind = i2
     2 interim_ind = i2
     2 ext_billing_ind = i2
     2 good_will_ind = i2
     2 pft_encntr_status_cd = f8
     2 pft_encntr_status_disp = vc
     2 pft_encntr_status_desc = vc
     2 pft_encntr_status_mean = vc
     2 pft_encntr_status_code_set = i4
     2 fin_class_cd = f8
     2 fin_class_disp = vc
     2 fin_class_desc = vc
     2 fin_class_mean = vc
     2 fin_class_code_set = i4
     2 collection_state_cd = f8
     2 collection_state_disp = vc
     2 collection_state_desc = vc
     2 collection_state_mean = vc
     2 collection_state_code_set = i4
     2 pft_encntr_collection_r_id = f8
     2 dunning_level_cd = f8
     2 dunning_level_disp = vc
     2 dunning_level_desc = vc
     2 dunning_level_mean = vc
     2 dunning_level_code_set = i4
     2 payment_plan_status_cd = f8
     2 payment_plan_status_disp = vc
     2 payment_plan_status_desc = vc
     2 payment_plan_status_mean = vc
     2 payment_plan_status_code_set = i4
     2 bill_status_cd = f8
     2 bill_status_disp = vc
     2 bill_status_desc = vc
     2 bill_status_mean = vc
     2 bill_status_code_set = i4
     2 submission_route_cd = f8
     2 submission_route_disp = vc
     2 submission_route_desc = vc
     2 submission_route_mean = vc
     2 submission_route_code_set = i4
     2 encntr_type_class_cd = f8
     2 encntr_type_class_disp = vc
     2 encntr_type_class_desc = vc
     2 encntr_type_class_mean = vc
     2 encntr_type_class_code_set = i4
     2 qualifier_cd = f8
     2 qualifier_disp = vc
     2 qualifier_desc = vc
     2 qualifier_mean = vc
     2 qualifier_code_set = i4
     2 account_balance = f8
     2 days_since_last_payment = i4
     2 reg_dt_tm = dq8
     2 med_service_cd = f8
     2 med_service_disp = vc
     2 med_service_desc = vc
     2 med_service_mean = vc
     2 med_service_code_set = i4
     2 modified_ind = i2
     2 currency_type_cd = f8
     2 encntr_fin_class_cd = f8
     2 encntr_fin_class_disp = vc
     2 encntr_fin_class_desc = vc
     2 encntr_fin_class_mean = vc
     2 encntr_fin_class_code_set = i4
     2 encntr_type_cd = f8
     2 encntr_type_disp = vc
     2 encntr_type_desc = vc
     2 encntr_type_mean = vc
     2 encntr_type_code_set = i4
     2 vip_cd = f8
     2 vip_disp = vc
     2 vip_desc = vc
     2 vip_mean = vc
     2 vip_code_set = i4
     2 health_plan_type_cd = f8
     2 health_plan_type_disp = vc
     2 health_plan_type_desc = vc
     2 health_plan_type_mean = vc
     2 health_plan_type_code_set = i4
     2 last_pay_sub_type_cd = f8
     2 last_pay_sub_type_disp = vc
     2 last_pay_sub_type_desc = vc
     2 last_pay_sub_type_mean = vc
     2 last_pay_sub_type_code_set = i4
     2 last_adj_sub_type_cd = f8
     2 last_adj_sub_type_disp = vc
     2 last_adj_sub_type_desc = vc
     2 last_adj_sub_type_mean = vc
     2 last_adj_sub_type_code_set = i4
     2 newest_upt_dt_tm = dq8
     2 coll_send_dt_tm = dq8
     2 pre_coll_send_dt_tm = dq8
     2 client_number_txt_key = vc
     2 primary_hp_id = f8
     2 secondary_hp_id = f8
     2 tertiary_hp_id = f8
     2 last_adjustment_amt = f8
     2 last_payment_amt = f8
     2 loc_nurse_unit_cd = f8
     2 service_date_from = dq8
     2 service_date_through = dq8
     2 entity_instance_desc = vc
     2 entity_resource_large_key = vc
     2 entity_resource_small_key = vc
     2 entity_name = vc
     2 clin_enc_fin_class_cd = f8
     2 clin_enc_fin_class_disp = vc
     2 clin_enc_fin_class_desc = vc
     2 clin_enc_fin_class_mean = vc
     2 clin_enc_fin_class_code_set = i4
     2 consolidation_cd = f8
     2 consolidation_disp = vc
     2 consolidation_desc = vc
     2 consolidation_mean = vc
     2 consolidation_code_set = i4
     2 total_tx_pay_amount = f8
     2 total_tx_adj_amount = f8
     2 total_tx_chrg_amount = f8
     2 batch_total_amount = f8
     2 remaining_est_due_amt = f8
     2 est_financial_resp_amt = f8
     2 pft_queue_item_id = f8
     2 pft_entity_type_cd = f8
     2 pft_entity_type_disp = vc
     2 pft_entity_type_desc = vc
     2 pft_entity_type_mean = vc
     2 pft_entity_type_code_set = f8
     2 pft_entity_status_cd = f8
     2 pft_entity_status_disp = vc
     2 pft_entity_status_desc = vc
     2 pft_entity_status_mean = vc
     2 pft_entity_status_code_set = f8
     2 pft_entity_sub_status_txt = vc
     2 assigned_prsnl_id = f8
     2 queue_item_created_dt_tm = dq8
     2 queue_item_age = i4
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
 FREE RECORD objsinglefemod
 RECORD objsinglefemod(
   1 obj_vrsn_5 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
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
     2 person_name = vc
     2 acct_nbr = vc
     2 fin_nbr = vc
     2 encntrloc = vc
     2 combined_into_id = f8
     2 billing_entity_name = vc
     2 parent_be_id = f8
     2 guarantor_name = vc
     2 admit_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 attenddrnum = f8
     2 attenddrname = vc
     2 admitdrnum = f8
     2 payment_plan_flag = i2
     2 self_pay_edit_flag = i2
     2 co_pay_amount = f8
     2 co_ins_amount = f8
     2 trans_type_cd = f8
     2 trans_amount = f8
     2 balance = f8
     2 adjustment_balance = f8
     2 applied_payment_balance = f8
     2 charge_balance = f8
     2 unapplied_payment_balance = f8
     2 bad_debt_balance = f8
     2 orig_bill_submit_dt_tm = dq8
     2 orig_bill_transmit_dt_tm = dq8
     2 last_claim_dt_tm = dq8
     2 last_stmt_dt_tm = dq8
     2 bill_counter_term = vc
     2 dunning_level_change_dt_tm = dq8
     2 dunning_level_cnt = i4
     2 dunning_ind = i2
     2 dunning_hold_ind = i2
     2 dunning_pay_cnt = i4
     2 dunning_unacc_pay_cnt = i4
     2 dunning_no_pay_cnt = i4
     2 consolidation_ind = i2
     2 col_letter_ind = i2
     2 send_col_ind = i2
     2 pft_encntr_alias = vc
     2 route_user_name = vc
     2 statement_cycle_id = f8
     2 ins_pend_bal_fwd = f8
     2 pat_bal_fwd = f8
     2 conversion_ind = i2
     2 nbr_of_stmts = i4
     2 bad_debt_dt_tm = dq8
     2 late_chrg_flag = i2
     2 late_chrg_start_dt_tm = dq8
     2 last_charge_dt_tm = dq8
     2 last_payment_dt_tm = dq8
     2 last_patient_pay_dt_tm = dq8
     2 last_adjustment_dt_tm = dq8
     2 zero_balance_dt_tm = dq8
     2 recur_ind = i2
     2 recur_seq = i4
     2 recur_bill_gen_ind = f8
     2 recur_current_month = i4
     2 recur_current_year = i4
     2 recur_bill_ready_ind = i2
     2 pt_start_dt_tm = dq8
     2 pt_total_visits = i4
     2 ot_start_dt_tm = dq8
     2 ot_total_visits = i4
     2 slt_start_dt_tm = dq8
     2 slt_total_visits = i4
     2 cr_start_dt_tm = dq8
     2 cr_total_visits = i4
     2 pft_collection_agency_id = f8
     2 collection_agency_type = vc
     2 org_ind = i2
     2 interim_ind = i2
     2 ext_billing_ind = i2
     2 good_will_ind = i2
     2 pft_encntr_status_cd = f8
     2 pft_encntr_status_disp = vc
     2 pft_encntr_status_desc = vc
     2 pft_encntr_status_mean = vc
     2 pft_encntr_status_code_set = i4
     2 fin_class_cd = f8
     2 fin_class_disp = vc
     2 fin_class_desc = vc
     2 fin_class_mean = vc
     2 fin_class_code_set = i4
     2 collection_state_cd = f8
     2 collection_state_disp = vc
     2 collection_state_desc = vc
     2 collection_state_mean = vc
     2 collection_state_code_set = i4
     2 pft_encntr_collection_r_id = f8
     2 dunning_level_cd = f8
     2 dunning_level_disp = vc
     2 dunning_level_desc = vc
     2 dunning_level_mean = vc
     2 dunning_level_code_set = i4
     2 payment_plan_status_cd = f8
     2 payment_plan_status_disp = vc
     2 payment_plan_status_desc = vc
     2 payment_plan_status_mean = vc
     2 payment_plan_status_code_set = i4
     2 bill_status_cd = f8
     2 bill_status_disp = vc
     2 bill_status_desc = vc
     2 bill_status_mean = vc
     2 bill_status_code_set = i4
     2 submission_route_cd = f8
     2 submission_route_disp = vc
     2 submission_route_desc = vc
     2 submission_route_mean = vc
     2 submission_route_code_set = i4
     2 encntr_type_class_cd = f8
     2 encntr_type_class_disp = vc
     2 encntr_type_class_desc = vc
     2 encntr_type_class_mean = vc
     2 encntr_type_class_code_set = i4
     2 qualifier_cd = f8
     2 qualifier_disp = vc
     2 qualifier_desc = vc
     2 qualifier_mean = vc
     2 qualifier_code_set = i4
     2 account_balance = f8
     2 days_since_last_payment = i4
     2 reg_dt_tm = dq8
     2 med_service_cd = f8
     2 med_service_disp = vc
     2 med_service_desc = vc
     2 med_service_mean = vc
     2 med_service_code_set = i4
     2 modified_ind = i2
     2 currency_type_cd = f8
     2 encntr_fin_class_cd = f8
     2 encntr_fin_class_disp = vc
     2 encntr_fin_class_desc = vc
     2 encntr_fin_class_mean = vc
     2 encntr_fin_class_code_set = i4
     2 encntr_type_cd = f8
     2 encntr_type_disp = vc
     2 encntr_type_desc = vc
     2 encntr_type_mean = vc
     2 encntr_type_code_set = i4
     2 vip_cd = f8
     2 vip_disp = vc
     2 vip_desc = vc
     2 vip_mean = vc
     2 vip_code_set = i4
     2 health_plan_type_cd = f8
     2 health_plan_type_disp = vc
     2 health_plan_type_desc = vc
     2 health_plan_type_mean = vc
     2 health_plan_type_code_set = i4
     2 last_pay_sub_type_cd = f8
     2 last_pay_sub_type_disp = vc
     2 last_pay_sub_type_desc = vc
     2 last_pay_sub_type_mean = vc
     2 last_pay_sub_type_code_set = i4
     2 last_adj_sub_type_cd = f8
     2 last_adj_sub_type_disp = vc
     2 last_adj_sub_type_desc = vc
     2 last_adj_sub_type_mean = vc
     2 last_adj_sub_type_code_set = i4
     2 newest_upt_dt_tm = dq8
     2 coll_send_dt_tm = dq8
     2 pre_coll_send_dt_tm = dq8
     2 client_number_txt_key = vc
     2 primary_hp_id = f8
     2 secondary_hp_id = f8
     2 tertiary_hp_id = f8
     2 last_adjustment_amt = f8
     2 last_payment_amt = f8
     2 loc_nurse_unit_cd = f8
     2 service_date_from = dq8
     2 service_date_through = dq8
     2 entity_instance_desc = vc
     2 entity_resource_large_key = vc
     2 entity_resource_small_key = vc
     2 entity_name = vc
     2 clin_enc_fin_class_cd = f8
     2 clin_enc_fin_class_disp = vc
     2 clin_enc_fin_class_desc = vc
     2 clin_enc_fin_class_mean = vc
     2 clin_enc_fin_class_code_set = i4
     2 consolidation_cd = f8
     2 consolidation_disp = vc
     2 consolidation_desc = vc
     2 consolidation_mean = vc
     2 consolidation_code_set = i4
     2 total_tx_pay_amount = f8
     2 total_tx_adj_amount = f8
     2 total_tx_chrg_amount = f8
     2 batch_total_amount = f8
     2 remaining_est_due_amt = f8
     2 est_financial_resp_amt = f8
     2 pft_queue_item_id = f8
     2 pft_entity_type_cd = f8
     2 pft_entity_type_disp = vc
     2 pft_entity_type_desc = vc
     2 pft_entity_type_mean = vc
     2 pft_entity_type_code_set = f8
     2 pft_entity_status_cd = f8
     2 pft_entity_status_disp = vc
     2 pft_entity_status_desc = vc
     2 pft_entity_status_mean = vc
     2 pft_entity_status_code_set = f8
     2 pft_entity_sub_status_txt = vc
     2 assigned_prsnl_id = f8
     2 queue_item_created_dt_tm = dq8
     2 queue_item_age = i4
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
 FREE RECORD acctfindreply
 RECORD acctfindreply(
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
 FREE RECORD objbenefitorderreq
 RECORD objbenefitorderreq(
   1 objarray[*]
     2 pft_encntr_id = f8
 )
 FREE RECORD objbenefitorderrep
 RECORD objbenefitorderrep(
   1 obj_vrsn_5 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 prior_submitted_ind = i2
     2 benefit_order_id = f8
     2 bo_hp_reltn_id = f8
     2 billing_entity_id = f8
     2 parent_be_id = f8
     2 health_plan_id = f8
     2 fin_class_cd = f8
     2 fin_class_disp = vc
     2 fin_class_desc = vc
     2 fin_class_mean = vc
     2 fin_class_code_set = i4
     2 priority_seq = i4
     2 pft_encntr_id = f8
     2 acct_id = f8
     2 bo_hp_status_cd = f8
     2 bo_hp_status_disp = vc
     2 bo_hp_status_desc = vc
     2 bo_hp_status_mean = vc
     2 bo_hp_status_code_set = i4
     2 amount_owed = f8
     2 total_billed_amount = f8
     2 total_paid_amount = f8
     2 total_adj_amount = f8
     2 last_billed_dt_tm = f8
     2 last_payment_dt_tm = dq8
     2 last_adjust_dt_tm = dq8
     2 roll_dt_tm = dq8
     2 roll_user_id = f8
     2 roll_task_id = f8
     2 roll_reason_cd = f8
     2 roll_reason_disp = vc
     2 roll_reason_desc = vc
     2 roll_reason_mean = vc
     2 roll_reason_code_set = i4
     2 roll_review_ind = i2
     2 resubmission_cnt = i4
     2 stmt_status_cd = f8
     2 stmt_status_disp = vc
     2 stmt_status_desc = vc
     2 stmt_status_mean = vc
     2 stmt_status_code_set = i4
     2 payor_org_id = f8
     2 bill_templ_id = f8
     2 encntr_plan_reltn_id = f8
     2 orig_bill_dt_tm = dq8
     2 orig_bill_submit_dt_tm = dq8
     2 orig_bill_transmit_dt_tm = dq8
     2 reltn_type_cd = f8
     2 reltn_type_disp = vc
     2 reltn_type_desc = vc
     2 reltn_type_mean = vc
     2 reltn_type_code_set = i4
     2 pft_proration_id = f8
     2 curr_amt_due = f8
     2 high_amt = f8
     2 non_covered_amt = f8
     2 orig_amt_due = f8
     2 proration_type_cd = f8
     2 proration_type_disp = vc
     2 proration_type_desc = vc
     2 proration_type_mean = vc
     2 proration_type_code_set = i4
     2 total_pay = f8
     2 total_adj = f8
     2 total_pay_amt = f8
     2 updt_cnt = i4
     2 bo_updt_cnt = i4
     2 bhr_updt_cnt = i4
     2 pro_updt_cnt = i4
     2 bill_type_cd = f8
     2 encntr_type_cd = f8
     2 pft_balance_id = f8
     2 health_plan_name = vc
     2 copay_dollars_amt = f8
     2 copay_percent_amt = f8
     2 coinsurance_dollars_amt = f8
     2 coinsurance_percent_amt = f8
     2 deductible_dollars_amt = f8
     2 deductible_percent_amt = f8
     2 trans_type_cd = f8
     2 trans_amount = f8
     2 bt_condition_id = f8
     2 bo_status_cd = f8
     2 bo_status_disp = vc
     2 bo_status_desc = vc
     2 bo_status_mean = vc
     2 bo_status_code_set = i4
     2 bo_status_reason_cd = f8
     2 bo_status_reason_disp = vc
     2 bo_status_reason_desc = vc
     2 bo_status_reason_mean = vc
     2 bo_status_reason_code_set = i4
     2 cross_over_ind = i2
     2 disp_noncovered_ind = i2
     2 man_edit_ind = i2
     2 subscriber_id = f8
     2 cons_bo_sched_id = f8
     2 total_charge_amt = f8
     2 eop_dt_tm = dq8
     2 proration_flag = i2
     2 previous_pft_encntr_id = f8
     2 chrg_group_disp = vc
     2 total_tx_pay_amount = f8
     2 total_tx_adj_amount = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_disp = vc
     2 active_status_desc = vc
     2 active_status_mean = vc
     2 active_status_code_set = i4
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_applctx = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
 )
 FREE RECORD objuptboreq
 RECORD objuptboreq(
   1 obj_vrsn_2 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 benefit_order_id = f8
     2 bo_hp_reltn_id = f8
     2 bo_status_cd = f8
     2 bo_hp_status_cd = f8
     2 curr_amt_due = f8
     2 curr_amount_dr_cr_flag = i2
     2 bo_updt_cnt = i4
     2 bhr_updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 pft_proration_id = f8
     2 pro_updt_cnt = i4
     2 priority_seq = i4
     2 health_plan_id = f8
     2 encntr_plan_reltn_id = f8
     2 pft_encntr_id = f8
     2 orig_amt_due = f8
 )
 FREE RECORD objuptbospreq
 RECORD objuptbospreq(
   1 obj_vrsn_2 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 benefit_order_id = f8
     2 bo_hp_reltn_id = f8
     2 bo_updt_cnt = i4
     2 bhr_updt_cnt = i4
     2 pft_proration_id = f8
     2 pro_updt_cnt = i4
     2 health_plan_id = f8
     2 priority_seq = i4
     2 encntr_plan_reltn_id = f8
 )
 FREE RECORD objtransfindrep
 RECORD objtransfindrep(
   1 obj_vrsn_2 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 hide_charges_ind = i2
   1 objarray[*]
     2 patient_name = vc
     2 trans_type_cd = f8
     2 trans_type_disp = vc
     2 trans_type_desc = vc
     2 trans_type_mean = vc
     2 trans_type_code_set = f8
     2 trans_sub_type_cd = f8
     2 trans_sub_type_disp = vc
     2 trans_sub_type_desc = vc
     2 trans_sub_type_mean = vc
     2 trans_sub_type_code_set = f8
     2 trans_alias_id = f8
     2 acct_sub_type_cd = f8
     2 acct_sub_type_disp = vc
     2 acct_sub_type_desc = vc
     2 acct_sub_type_mean = vc
     2 acct_sub_type_code_set = f8
     2 total_trans_amount = f8
     2 trans_reason_cd = f8
     2 trans_reason_disp = vc
     2 trans_reason_desc = vc
     2 trans_reason_mean = vc
     2 trans_reason_code_set = f8
     2 trans_comment = vc
     2 trans_status_cd = f8
     2 trans_status_disp = vc
     2 trans_status_desc = vc
     2 trans_status_mean = vc
     2 trans_status_code_set = f8
     2 trans_status_reason_cd = f8
     2 trans_status_reason_disp = vc
     2 trans_status_reason_desc = vc
     2 trans_status_reason_mean = vc
     2 trans_status_reason_code_set = f8
     2 bundle_id = f8
     2 bundle_ind = i2
     2 gl_posted_ind = i2
     2 post_dt_tm = dq8
     2 bill_ind = i2
     2 suppress_flag = i2
     2 suppress_txt = vc
     2 created_dt_tm = dq8
     2 created_prsnl_id = f8
     2 payment_detail_id = f8
     2 tpm_id = f8
     2 cr_acct_id = f8
     2 dr_acct_id = f8
     2 ext_acct_id_txt = vc
     2 acct_bal = f8
     2 cr_be_id = f8
     2 dr_be_id = f8
     2 ar_account_id = f8
     2 nar_account_id = f8
     2 fin_nbr = vc
     2 fin_bal = f8
     2 bo_bal = f8
     2 payment_method_cd = f8
     2 payment_method_disp = vc
     2 payment_method_desc = vc
     2 payment_method_mean = vc
     2 payment_method_code_set = f8
     2 payment_num_desc = vc
     2 payor_name = vc
     2 payor_id = f8
     2 payor_entity_name = vc
     2 cc_beg_eff_dt_tm = dq8
     2 cc_end_eff_dt_tm = dq8
     2 cc_auth_nbr = vc
     2 cc_token_txt = vc
     2 external_ident = vc
     2 current_cur_cd = f8
     2 current_cur_disp = vc
     2 current_cur_desc = vc
     2 current_cur_mean = vc
     2 current_cur_code_set = f8
     2 orig_cur_cd = f8
     2 orig_cur_disp = vc
     2 orig_cur_desc = vc
     2 orig_cur_mean = vc
     2 orig_cur_code_set = f8
     2 check_date = dq8
     2 napplevel_flag = i4
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 parent_activity_id = f8
     2 tendered_amount = f8
     2 change_due_amount = f8
     2 sequence_nbr = i4
     2 reversed_ind = i2
     2 reversed_amount = f8
     2 transfered_ind = i2
     2 transferred_amount = f8
     2 reversal_ind = i2
     2 transfer_ind = i2
     2 preview = vc
     2 batch_trans_reltn_id = f8
     2 error_status_cd = f8
     2 refundable_amount = f8
     2 pending_refund_amount = f8
     2 cc_type_cd = f8
     2 merchant_ident = vc
     2 cc_location_cd = f8
     2 cc_trans_org_id = f8
     2 interchange_trans_ident = vc
     2 cc_app_name = vc
     2 cc_card_entry_mode_txt = vc
     2 cc_cvm_txt = vc
     2 cc_aid_txt = vc
     2 cc_tvr_txt = vc
     2 cc_iad_txt = vc
     2 cc_tsi_txt = vc
     2 cc_arc_txt = vc
     2 cc_app_label = vc
     2 activity_dt_tm = dq8
     2 user_name = vc
     2 pending_dt_tm = dq8
     2 icn_number = i4
     2 hp_name = vc
     2 service_dt_tm = dq8
     2 last_charge_dt_tm = dq8
     2 charge_description = vc
     2 proc_cd = vc
     2 icd9_cd = vc
     2 rev_cd = vc
     2 mod1 = vc
     2 mod2 = vc
     2 diag1 = vc
     2 diag2 = vc
     2 diag3 = vc
     2 diag4 = vc
     2 unit_price = f8
     2 quantity = f8
     2 fin_class_cd = f8
     2 fin_class_disp = vc
     2 fin_class_desc = vc
     2 fin_class_mean = vc
     2 fin_class_code_set = f8
     2 ordering_physician = vc
     2 performing_physician = vc
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 service_resource_desc = vc
     2 service_resource_mean = vc
     2 service_resource_code_set = f8
     2 perf_loc_cd = f8
     2 perf_loc_disp = vc
     2 perf_loc_desc = vc
     2 perf_loc_mean = vc
     2 perf_loc_code_set = f8
     2 department_cd = f8
     2 department_disp = vc
     2 department_desc = vc
     2 department_mean = vc
     2 department_code_set = f8
     2 abn_status_cd = f8
     2 abn_status_disp = vc
     2 abn_status_desc = vc
     2 abn_status_mean = vc
     2 abn_status_code_set = f8
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 activity_type_desc = vc
     2 activity_type_mean = vc
     2 activity_type_code_set = f8
     2 total_payments = f8
     2 total_adjustments = f8
     2 balance = f8
     2 order_id = f8
     2 chrg_group_disp = vc
     2 late_chrg_flag = i2
     2 trans_sub_amount = f8
     2 charge_event_id = f8
     2 charge_event_act_id = f8
     2 gl_trans_log_id = f8
     2 company_alias = vc
     2 company_unit = vc
     2 account_alias = vc
     2 account_unit = vc
     2 gl_interface_dt_tm = dq8
     2 gl_status_cd = f8
     2 gl_status_disp = vc
     2 gl_status_desc = vc
     2 gl_status_mean = vc
     2 gl_status_code_set = f8
     2 non_ar_gl_trans_log_id = f8
     2 non_ar_company_alias = vc
     2 non_ar_company_unit = vc
     2 non_ar_account_alias = vc
     2 non_ar_account_unit = vc
     2 non_ar_gl_interface_dt_tm = dq8
     2 non_ar_gl_status_cd = f8
     2 non_ar_gl_status_disp = vc
     2 non_ar_gl_status_desc = vc
     2 non_ar_gl_status_mean = vc
     2 non_ar_gl_status_code_set = f8
     2 transaction_level = vc
     2 trans_reltn_sub_reason_cd = f8
     2 trans_reltn_reason_cd = f8
     2 trans_trans_reltn_id = f8
     2 ar_balance_id = f8
     2 nar_balance_id = f8
     2 payer_desc = vc
     2 entity_instance_desc = vc
     2 entity_resource_large_key = vc
     2 entity_resource_small_key = vc
     2 entity_name = vc
     2 edi_adj_group_cd = f8
     2 edi_adj_reason_cd = f8
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
 FREE RECORD objreversereq
 RECORD objreversereq(
   1 objarray[*]
     2 activity_id = f8
 )
 FREE RECORD uptbhreq
 RECORD uptbhreq(
   1 objarray[*]
     2 corsp_activity_id = f8
     2 bill_vrsn_nbr = i4
     2 bill_status_cd = f8
     2 updt_cnt = i4
     2 active_ind = i2
 )
 FREE RECORD relholdrequest
 RECORD relholdrequest(
   1 objarray[*]
     2 pft_encntr_id = f8
     2 pe_status_reason_cd = f8
 )
 FREE RECORD applyholdrequest
 RECORD applyholdrequest(
   1 objarray[*]
     2 pft_encntr_id = f8
     2 pe_status_reason_cd = f8
     2 reason_comment = vc
     2 reapply_ind = i4
     2 pft_hold_id = f8
 )
 FREE RECORD reqacctreq
 RECORD reqacctreq(
   1 objarray[1]
     2 pft_encntr_id = f8
 )
 FREE RECORD objsingleacct
 RECORD objsingleacct(
   1 obj_vrsn_1 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 acct_id = f8
     2 acct_sub_type_cd = f8
     2 guarantor_id = f8
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
 FREE RECORD objbobillheader
 RECORD objbobillheader(
   1 obj_vrsn_1 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
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
     2 corsp_activity_id = f8
     2 bill_vrsn_nbr = i4
     2 acct_id = f8
     2 pft_encntr_id = f8
     2 parent_be_id = f8
     2 billing_entity_id = f8
     2 auto_submit_ind = i2
     2 fin_class_cd = f8
     2 fin_class_disp = vc
     2 fin_class_desc = vc
     2 fin_class_mean = vc
     2 fin_class_code_set = i4
     2 auto_submit_cd = f8
     2 auto_submit_disp = vc
     2 auto_submit_desc = vc
     2 auto_submit_mean = vc
     2 auto_submit_code_set = i4
     2 auto_submit_value = f8
     2 balance = f8
     2 balance_due = f8
     2 balance_fwd = f8
     2 bill_class_cd = f8
     2 bill_class_disp = vc
     2 bill_class_desc = vc
     2 bill_class_mean = vc
     2 bill_class_code_set = i4
     2 bill_nbr_disp = vc
     2 bill_nbr_disp_key = vc
     2 bill_status_cd = f8
     2 bill_status_disp = vc
     2 bill_status_desc = vc
     2 bill_status_mean = vc
     2 bill_status_code_set = i4
     2 bill_status_reason_cd = f8
     2 bill_status_reason_disp = vc
     2 bill_status_reason_desc = vc
     2 bill_status_reason_mean = vc
     2 bill_status_reason_code_set = i4
     2 bill_templ_id = f8
     2 bill_type_cd = f8
     2 bill_type_disp = vc
     2 bill_type_desc = vc
     2 bill_type_mean = vc
     2 bill_type_code_set = i4
     2 bt_cond_result_id = f8
     2 dunning_level_cd = f8
     2 dunning_level_disp = vc
     2 dunning_level_desc = vc
     2 dunning_level_mean = vc
     2 dunning_level_code_set = i4
     2 dunning_level_cnt = i4
     2 e_sort_field_1 = vc
     2 e_sort_field_1_cd = f8
     2 e_sort_field_1_disp = vc
     2 e_sort_field_1_desc = vc
     2 e_sort_field_1_mean = vc
     2 e_sort_field_1_code_set = i4
     2 e_sort_field_2 = vc
     2 e_sort_field_2_cd = f8
     2 e_sort_field_2_disp = vc
     2 e_sort_field_2_desc = vc
     2 e_sort_field_2_mean = vc
     2 e_sort_field_2_code_set = i4
     2 e_sort_field_3 = vc
     2 e_sort_field_3_cd = f8
     2 e_sort_field_3_disp = vc
     2 e_sort_field_3_desc = vc
     2 e_sort_field_3_mean = vc
     2 e_sort_field_3_code_set = i4
     2 gen_dt_tm = dq8
     2 gen_reason_cd = f8
     2 gen_reason_disp = vc
     2 gen_reason_desc = vc
     2 gen_reason_mean = vc
     2 gen_reason_code_set = i4
     2 interim_bill_flag = i2
     2 man_review_ind = i2
     2 media_type_cd = f8
     2 media_type_disp = vc
     2 media_type_desc = vc
     2 media_type_mean = vc
     2 media_type_code_set = i4
     2 media_sub_type_cd = f8
     2 media_sub_type_disp = vc
     2 media_sub_type_desc = vc
     2 media_sub_type_mean = vc
     2 media_sub_type_code_set = i4
     2 new_amount = f8
     2 page_cnt = i4
     2 parent_bill_rec_id = f8
     2 parent_bill_vrsn_nbr = i4
     2 payor_ctrl_nbr_txt = vc
     2 sort_field_1 = vc
     2 sort_field_1_cd = f8
     2 sort_field_1_disp = vc
     2 sort_field_1_desc = vc
     2 sort_field_1_mean = vc
     2 sort_field_1_code_set = i4
     2 sort_field_2 = vc
     2 sort_field_2_cd = f8
     2 sort_field_2_disp = vc
     2 sort_field_2_desc = vc
     2 sort_field_2_mean = vc
     2 sort_field_2_code_set = i4
     2 sort_field_3 = vc
     2 sort_field_3_cd = f8
     2 sort_field_3_disp = vc
     2 sort_field_3_desc = vc
     2 sort_field_3_mean = vc
     2 sort_field_3_code_set = i4
     2 transmission_dt_tm = dq8
     2 zip_code_key = vc
     2 batch_event_id = f8
     2 bill_submit_sched_id = f8
     2 claim_file_cd = f8
     2 claim_file_disp = vc
     2 claim_file_desc = vc
     2 claim_file_mean = vc
     2 claim_file_code_set = i4
     2 claim_status_cd = f8
     2 claim_status_disp = vc
     2 claim_status_desc = vc
     2 claim_status_mean = vc
     2 claim_status_code_set = i4
     2 claim_serial_nbr = f8
     2 cm_status_cd = f8
     2 cm_status_disp = vc
     2 cm_status_desc = vc
     2 cm_status_mean = vc
     2 cm_status_code_set = i4
     2 demand_ind = i2
     2 last_adjustment_dt_tm = dq8
     2 last_payment_dt_tm = dq8
     2 pay_adj_to_cm_dt_tm = dq8
     2 ra_claim_field_cd = f8
     2 ra_claim_field_disp = vc
     2 ra_claim_field_desc = vc
     2 ra_claim_field_mean = vc
     2 ra_claim_field_code_set = i4
     2 ra_claim_status_cd = f8
     2 ra_claim_status_disp = vc
     2 ra_claim_status_desc = vc
     2 ra_claim_status_mean = vc
     2 ra_claim_status_code_set = i4
     2 route_user_name = vc
     2 submission_route_cd = f8
     2 submission_route_disp = vc
     2 submission_route_desc = vc
     2 submission_route_mean = vc
     2 submission_route_code_set = i4
     2 submit_dt_tm = dq8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_disp = vc
     2 active_status_desc = vc
     2 active_status_mean = vc
     2 active_status_code_set = i4
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_applctx = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 benefit_order_id = f8
     2 trans_type_cd = f8
     2 trans_amount = f8
     2 consolidation_cd = f8
     2 entity_instance_desc = vc
     2 entity_resource_large_key = vc
     2 entity_resource_small_key = vc
     2 entity_name = vc
     2 service_start_dt_tm = dq8
     2 service_end_dt_tm = dq8
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
 )
 FREE RECORD relholdreply
 RECORD relholdreply(
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
 FREE RECORD applyholdreply
 RECORD applyholdreply(
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
 FREE RECORD bofindreply
 RECORD bofindreply(
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
 FREE RECORD em_pbmrequest
 RECORD em_pbmrequest(
   1 objarray[*]
     2 event_key = vc
     2 category_key = vc
     2 acct_id = f8
     2 pft_encntr_id = f8
     2 encntr_id = f8
     2 bo_hp_reltn_id = f8
     2 corsp_activity_id = f8
     2 bill_vrsn_nbr = i4
     2 activity_id = f8
     2 pft_charge_id = f8
 )
 FREE RECORD em_pbmreply
 RECORD em_pbmreply(
   1 rulesets[*]
     2 ruleset_key = vc
     2 event_key = vc
     2 category_key = vc
     2 flex_type_mean = vc
     2 acct_id = f8
     2 pft_encntr_id = f8
     2 encntr_id = f8
     2 corsp_activity_id = f8
     2 bill_vrsn_nbr = i4
     2 bo_hp_reltn_id = f8
     2 activity_id = f8
     2 pft_charge_id = f8
     2 actions[*]
       3 action_key = vc
       3 action_type = i4
       3 action_value = vc
       3 action_sequence = i4
       3 action_status = c1
       3 params[*]
         4 param_key = vc
         4 param_type = vc
         4 param_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD insertparrequest
 RECORD insertparrequest(
   1 objarray[*]
     2 pft_acct_reltn_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 created_prsnl_id = f8
     2 created_dt_tm = dq8
     2 acct_id = f8
     2 role_type_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
 )
 FREE SET cbosemrequest
 RECORD cbosemrequest(
   1 encntr_id = f8
   1 acct_id = f8
   1 cons_bo_sched_id = f8
   1 pft_encntr_id = f8
 )
 FREE SET cbosemreply
 RECORD cbosemreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET stmtprocrequest
 RECORD stmtprocrequest(
   1 guarantor_id = f8
 )
 FREE SET stmtprocreply
 RECORD stmtprocreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET resetstmtrequest
 RECORD resetstmtrequest(
   1 guarantor_id = f8
   1 stmt_list[*]
     2 pft_encntr_id = f8
     2 corsp_activity_id = f8
     2 bill_vrsn_nbr = i4
     2 acct_id = f8
 )
 FREE RECORD objpmhealthplan
 RECORD objpmhealthplan(
   1 obj_vrsn_1 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 bo_hp_reltn_id = f8
     2 pft_encntr_id = f8
     2 encntr_plan_reltn_id = f8
     2 benefit_order_id = f8
     2 bill_templ_id = f8
     2 hp_name = vc
     2 payer_org = f8
     2 priority_seq = i2
     2 hp_id = f8
     2 fin_class_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 updt_applctx = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
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
 FREE RECORD tempsendpe
 RECORD tempsendpe(
   1 objarray[*]
     2 pft_encntr_id = f8
 )
 FREE RECORD tempbope
 RECORD tempbope(
   1 objarray[*]
     2 pft_encntr_id = f8
     2 guarantor_id = f8
     2 acct_id = f8
     2 billing_entity_id = f8
     2 encntr_type_cd = f8
     2 person_id = f8
 )
 FREE RECORD objcbos
 RECORD objcbos(
   1 obj_vrsn_1 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 billing_entity_id = f8
     2 cons_bo_sched_id = f8
     2 end_effective_dt_tm = dq8
     2 next_bill_dt_tm = dq8
     2 organization_id = f8
     2 person_id = f8
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 last_bill_dt_tm = dq8
     2 proc_ind = i2
     2 statement_cycle_id = f8
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
 FREE RECORD criteriafindrequest
 RECORD criteriafindrequest(
   1 objarray[1]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 FREE RECORD objcriteria
 RECORD objcriteria(
   1 obj_vrsn_1 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 billing_entity_id = f8
     2 hold_cd = f8
     2 hold_criteria_ind = i2
     2 hold_flag = i2
     2 hold_name = c40
     2 hold_reason_cd = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 pft_hold_id = f8
     2 process_priority_nbr = i4
     2 stnd_delay = i4
     2 updt_cnt = i4
     2 active_ind = i2
     2 pft_hold_criteria_id = f8
     2 hold_criteria_cd = f8
     2 hold_criteria = vc
     2 child_criteria_ind = i2
 )
 RECORD interfacefiles(
   1 interface_file_qual = i4
   1 interface_file[*]
     2 interface_file_id = f8
     2 description = vc
     2 file_name = vc
     2 realtime_ind = i2
     2 hl7_ind = i2
     2 cdm_sched_cd = f8
     2 rev_sched_cd = f8
     2 cpt_sched_cd = f8
     2 active_ind = i2
     2 mult_bill_code_sched_cd = f8
     2 contributor_system_cd = f8
     2 doc_nbr_cd = f8
     2 explode_ind = i2
     2 profit_type_cd = f8
     2 fin_nbr_suspend_ind = i2
     2 max_ft1 = vc
     2 perf_phys_cont_ind = i2
     2 round_method_flag = i2
     2 reprocess_ind = i2
     2 reprocess_cpt_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD charge_req(
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
     2 verify_phys_id = f8
     2 activity_dt_tm = dq8
     2 active_ind = i2
     2 active_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 abn_status_cd = f8
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
 )
 RECORD charge_rep(
   1 charge_qual = i2
   1 charge[*]
     2 charge_item_id = f8
     2 perf_loc_cd = f8
     2 perf_loc_disp = c40
     2 perf_loc_desc = c60
     2 perf_loc_mean = c12
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
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD post_rel_nt_request(
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
     2 charge_type_cd = f8
 )
 RECORD nt_request_all(
   1 remove_commit_ind = i2
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
 )
 FREE RECORD objbeinforequest
 RECORD objbeinforequest(
   1 objarray[1]
     2 billing_entity_id = f8
 )
 FREE RECORD objbeinfo
 RECORD objbeinfo(
   1 ein_type = i4
   1 objarray[*]
     2 billing_start_cd = f8
     2 produce_bill_cd = f8
     2 freq_dur_id = f8
     2 be_name_key = vc
     2 current_seq_nbr = f8
     2 proc_code_ind = i2
     2 billing_entity_id = f8
     2 be_name = vc
     2 be_desc = vc
     2 organization_id = f8
     2 org_name = vc
     2 place_of_service = c2
     2 def_pat_templ_id = f8
     2 def_post_method_cd = f8
     2 def_post_method_display = vc
     2 cost_center_cd = f8
     2 currency_type_cd = f8
     2 currency_type_desc = vc
     2 parent_be_id = f8
     2 std_delay = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 post_cd = f8
     2 post_cd_desc = vc
     2 ar_acct_id = f8
     2 ext_acct_desc = vc
     2 default_selfpay_hp_id = f8
     2 self_pay_hp_name = vc
     2 qcf_rounding_flag = i2
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_task = i4
     2 updt_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 recur_bill_opt_flag = i2
     2 recur_bill_what_day = i4
     2 recur_wait_code_flag = i2
     2 recur_gen_delay_ind = i2
     2 recur_gen_delay = i4
     2 rug_cd_order_flag = i2
     2 hcfa_1500_dx_flag = i2
     2 reclass_receive_ind = i2
     2 proc_code_ind = i2
     2 seq_start_nbr = f8
     2 program_cd = f8
     2 program_cd_disp = vc
     2 days_to_eval = i4
     2 encntr_life_ind = i2
     2 bad_debt_check_ind = i2
     2 zero_balance_wait = i4
     2 calculated_balance_ind = i2
     2 suppress_offset_drcr_ind = i2
     2 fee_sched_flag = i2
     2 fiscal_reporting_flag = i2
     2 bill_ent_bus_add1 = vc
     2 bill_ent_bus_add2 = vc
     2 bill_ent_bus_city = vc
     2 bill_ent_bus_state = vc
     2 bill_ent_bus_zip = vc
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
 RECORD objbeinforeply(
   1 objarray[*]
     2 billing_start_cd = f8
     2 produce_bill_cd = f8
     2 freq_dur_id = f8
     2 be_name_key = vc
     2 current_seq_nbr = f8
     2 proc_code_ind = i2
     2 billing_entity_id = f8
     2 be_name = vc
     2 be_desc = vc
     2 organization_id = f8
     2 org_name = vc
     2 place_of_service = c2
     2 def_post_method_cd = f8
     2 def_post_method_display = vc
     2 def_pat_templ_id = f8
     2 cost_center_cd = f8
     2 currency_type_cd = f8
     2 currency_type_desc = vc
     2 parent_be_id = f8
     2 std_delay = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 post_cd = f8
     2 post_cd_desc = vc
     2 ar_acct_id = f8
     2 ext_acct_desc = vc
     2 default_selfpay_hp_id = f8
     2 self_pay_hp_name = vc
     2 qcf_rounding_flag = i2
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_task = i4
     2 updt_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 recur_bill_opt_flag = i2
     2 recur_bill_what_day = i4
     2 recur_wait_code_flag = i2
     2 recur_gen_delay_ind = i2
     2 recur_gen_delay = i4
     2 rug_cd_order_flag = i2
     2 hcfa_1500_dx_flag = i2
     2 reclass_receive_ind = i2
     2 him_suppression_ind = i2
     2 proc_code_ind = i2
     2 seq_start_nbr = f8
     2 program_cd = f8
     2 program_cd_disp = vc
     2 days_to_eval = i4
     2 encntr_life_ind = i2
     2 bad_debt_check_ind = i2
     2 zero_balance_wait = i4
     2 calculated_balance_ind = i2
     2 suppress_offset_drcr_ind = i2
     2 fee_sched_flag = i2
     2 fiscal_reporting_flag = i2
     2 bill_ent_bus_add1 = vc
     2 bill_ent_bus_add2 = vc
     2 bill_ent_bus_city = vc
     2 bill_ent_bus_state = vc
     2 bill_ent_bus_zip = vc
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
 FREE RECORD reclassreq
 RECORD reclassreq(
   1 o_primary_hp_id = f8
   1 n_primary_hp_id = f8
   1 n_encntr_id = f8
   1 o_encntr_id = f8
   1 n_encntr_type_cd = f8
   1 o_encntr_type_cd = f8
   1 n_fin_class_cd = f8
   1 o_fin_class_cd = f8
   1 n_bill_templ_id = f8
   1 o_bill_templ_id = f8
   1 n_pft_encntr_id = f8
   1 o_pft_encntr_id = f8
   1 pft_fin_action_flag = i2
 )
 FREE RECORD reclassrep
 RECORD reclassrep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD wfrequest
 RECORD wfrequest(
   1 pft_queue_event_cd = f8
   1 entity[*]
     2 pft_entity_type_cd = f8
     2 pft_entity_status_cd = f8
     2 entity_id = f8
 )
 FREE RECORD wfreply
 RECORD wfreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD addcommentrequest
 RECORD addcommentrequest(
   1 objarray[*]
     2 pft_encntr_id = f8
     2 corsp_desc = vc
     2 importance_flag = i2
     2 created_dt_tm = dq8
     2 action_code = vc
     2 event_cd = f8
     2 productivity_flag = i2
     2 productivity_weight = f8
 )
 FREE RECORD addcommentreply
 RECORD addcommentreply(
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
 FREE RECORD addbohp
 RECORD addbohp(
   1 obj_vrsn_5 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 benefit_order_id = f8
     2 bo_hp_reltn_id = f8
     2 billing_entity_id = f8
     2 parent_be_id = f8
     2 health_plan_id = f8
     2 fin_class_cd = f8
     2 priority_seq = i4
     2 pft_encntr_id = f8
     2 acct_id = f8
     2 bo_hp_status_cd = f8
     2 amount_owed = f8
     2 total_billed_amount = f8
     2 total_paid_amount = f8
     2 total_adj_amount = f8
     2 last_billed_dt_tm = f8
     2 last_payment_dt_tm = dq8
     2 last_adjust_dt_tm = dq8
     2 roll_dt_tm = dq8
     2 roll_user_id = f8
     2 roll_task_id = f8
     2 roll_reason_cd = f8
     2 roll_review_ind = i2
     2 resubmission_cnt = i4
     2 stmt_status_cd = f8
     2 payor_org_id = f8
     2 bill_templ_id = f8
     2 encntr_plan_reltn_id = f8
     2 orig_bill_dt_tm = dq8
     2 orig_bill_submit_dt_tm = dq8
     2 orig_bill_transmit_dt_tm = dq8
     2 pft_proration_id = f8
     2 curr_amt_due = f8
     2 high_amt = f8
     2 non_covered_amt = f8
     2 orig_amt_due = f8
     2 proration_type_cd = f8
     2 total_pay = f8
     2 total_adj = f8
     2 total_pay_amt = f8
     2 updt_cnt = i4
     2 bo_updt_cnt = i4
     2 bhr_updt_cnt = i4
     2 pro_updt_cnt = i4
     2 bill_type_cd = f8
     2 encntr_type_class_cd = f8
     2 name_last_key = vc
     2 health_plan_name = vc
     2 copay_dollars_amt = f8
     2 copay_percent_amt = f8
     2 coinsurance_dollars_amt = f8
     2 coinsurance_percent_amt = f8
     2 deductible_dollars_amt = f8
     2 deductible_percent_amt = f8
     2 trans_type_cd = f8
     2 trans_amount = f8
     2 bt_condition_id = f8
     2 bo_status_cd = f8
     2 bo_status_reason_cd = f8
     2 cross_over_ind = i2
     2 disp_noncovered_ind = i2
     2 man_edit_ind = i2
     2 subscriber_id = f8
     2 cons_bo_sched_id = f8
     2 total_charge_amt = f8
     2 eop_dt_tm = dq8
     2 proration_flag = i2
     2 previous_pft_encntr_id = f8
     2 chrg_group_disp = vc
     2 encntr_type_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_applctx = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
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
 FREE RECORD objpmhealthtemp
 RECORD objpmhealthplantemp(
   1 obj_vrsn_1 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 bo_hp_reltn_id = f8
     2 pft_encntr_id = f8
     2 encntr_plan_reltn_id = f8
     2 benefit_order_id = f8
     2 bill_templ_id = f8
     2 hp_name = vc
     2 priority_seq = i2
     2 hp_id = f8
     2 fin_class_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 updt_applctx = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
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
 FREE RECORD objaddbo
 RECORD objaddbo(
   1 obj_vrsn_2 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 benefit_order_id = f8
     2 bo_hp_reltn_id = f8
     2 billing_entity_id = f8
     2 parent_be_id = f8
     2 health_plan_id = f8
     2 fin_class_cd = f8
     2 priority_seq = i4
     2 pft_encntr_id = f8
     2 acct_id = f8
     2 bo_hp_status_cd = f8
     2 amount_owed = f8
     2 total_billed_amount = f8
     2 total_paid_amount = f8
     2 total_adj_amount = f8
     2 last_billed_dt_tm = f8
     2 last_payment_dt_tm = dq8
     2 last_adjust_dt_tm = dq8
     2 roll_dt_tm = dq8
     2 roll_user_id = f8
     2 roll_task_id = f8
     2 roll_reason_cd = f8
     2 roll_review_ind = i2
     2 resubmission_cnt = i4
     2 stmt_status_cd = f8
     2 person_id = f8
     2 payor_org_id = f8
     2 bill_templ_id = f8
     2 encntr_plan_reltn_id = f8
     2 orig_bill_dt_tm = dq8
     2 orig_bill_submit_dt_tm = dq8
     2 orig_bill_transmit_dt_tm = dq8
     2 pft_proration_id = f8
     2 curr_amt_due = f8
     2 high_amt = f8
     2 non_covered_amt = f8
     2 orig_amt_due = f8
     2 proration_type_cd = f8
     2 total_pay = f8
     2 total_adj = f8
     2 total_pay_amt = f8
     2 updt_cnt = i4
     2 bo_updt_cnt = i4
     2 bhr_updt_cnt = i4
     2 pro_updt_cnt = i4
     2 bill_type_cd = f8
     2 encntr_type_class_cd = f8
     2 name_last_key = vc
     2 health_plan_name = vc
     2 copay_dollars_amt = f8
     2 copay_percent_amt = f8
     2 coinsurance_dollars_amt = f8
     2 coinsurance_percent_amt = f8
     2 deductible_dollars_amt = f8
     2 deductible_percent_amt = f8
     2 trans_type_cd = f8
     2 trans_amount = f8
     2 bt_condition_id = f8
     2 bo_status_cd = f8
     2 bo_status_reason_cd = f8
     2 cross_over_ind = i2
     2 disp_noncovered_ind = i2
     2 man_edit_ind = i2
     2 subscriber_id = f8
     2 cons_bo_sched_id = f8
     2 total_charge_amt = f8
     2 eop_dt_tm = dq8
     2 proration_flag = i2
     2 previous_pft_encntr_id = f8
     2 chrg_group_disp = vc
     2 encntr_type_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_applctx = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
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
 FREE RECORD reqbh
 RECORD reqbh(
   1 objarray[1]
     2 bo_hp_reltn_id = f8
 )
 FREE RECORD wfdequeuereq
 RECORD wfdequeuereq(
   1 pft_publish_ind = i2
   1 entity[*]
     2 pft_entity_type_cd = f8
     2 pft_entity_status_cd = f8
     2 bo_hp_reltn_id = f8
     2 pft_entity_status_group_cd = f8
     2 pft_entity_sub_status_txt = vc
     2 pft_entity_status_cd_hist = f8
     2 pft_entity_sub_status_txt_hist = vc
     2 entity_balance_hist = f8
     2 entity_balance_hist_dr_cr_flag = i2
     2 pft_queue_item_id = f8
     2 entity_balance = f8
     2 entity_balance_dr_cr_flag = i2
     2 assigned_prsnl_id = f8
     2 contributor_system_cd = f8
     2 corsp_activity_id = f8
     2 pft_encntr_id = f8
     2 acct_id = f8
     2 bill_vrsn_nbr = i4
     2 activity_id = f8
     2 billing_entity_id = f8
     2 encntr_type_cd = f8
     2 med_service_cd = f8
     2 hold_reason_cd = f8
     2 fin_class_cd = f8
     2 payment_plan_flag = i2
     2 primary_hp_fin_class_cd = f8
     2 payor_org_id = f8
     2 primary_hp_org_id = f8
     2 health_plan_id = f8
     2 primary_hp_id = f8
     2 patient_last_name = vc
     2 vip_cd = f8
     2 guarantor_last_name = vc
     2 bill_type_cd = f8
     2 bill_status_reason_cd = f8
     2 bill_temple_id = f8
     2 denial_reason_cd = f8
     2 denial_group_cd = f8
     2 dunning_level_cd = f8
     2 pft_collection_agency_id = f8
     2 rec_exists_ind = i2
     2 change_flag = i2
     2 days_from_discharge = f8
     2 days_from_claim_sub = f8
     2 loc_building_cd = f8
     2 loc_facility_cd = f8
     2 loc_nurseunit_cd = f8
     2 encntr_bal = f8
     2 supervising_physician_id = f8
     2 cal_variance_amt = f8
     2 org_set_id = f8
 )
 RECORD wfdequeuerep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD reqtempfe
 RECORD reqtempfe(
   1 context = vc
   1 objarray[*]
     2 pft_encntr_id = f8
 )
 FREE RECORD emobjrppformal
 RECORD emobjrppformal(
   1 obj_vrsn_1 = c1
   1 ein_type = i4
   1 proxy_ind = i2
   1 objarray[*]
     2 pft_payment_plan_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 guarantor_name = vc
     2 billing_entity_id = f8
     2 total_amount_due = f8
     2 pft_encntr_amount = f8
     2 begin_plan_dt_tm = dq8
     2 installment_amount = f8
     2 duration_plan_dt_tm = dq8
     2 number_of_payments = i4
     2 due_day = i4
     2 cycle_length = i4
     2 current_plan_status_cd = f8
     2 current_plan_status_disp = vc
     2 current_plan_status_desc = vc
     2 current_plan_status_mean = vc
     2 current_plan_status_code_set = f8
     2 current_period_start_dt_tm = dq8
     2 ending_plan_dt_tm = dq8
     2 ending_plan_status_cd = f8
     2 ending_plan_status_disp = vc
     2 ending_plan_status_desc = vc
     2 ending_plan_status_mean = vc
     2 ending_plan_status_code_set = f8
     2 pp_updt_cnt = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_disp = vc
     2 active_status_desc = vc
     2 active_status_mean = vc
     2 active_status_code_set = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 acct_id = f8
     2 pft_pay_plan_pe_reltn_id = f8
     2 pft_encntr_id = f8
     2 orig_encounter_bal = f8
     2 orig_encounter_dt_tm = dq8
     2 ending_encntr_dt_tm = dq8
     2 ending_encntr_status_cd = f8
     2 ending_encntr_status_disp = vc
     2 ending_encntr_status_desc = vc
     2 ending_encntr_status_mean = vc
     2 ending_encntr_status_code_set = f8
     2 ppr_updt_cnt = i4
     2 admit_dt_tm = dq8
     2 encntr_balance = f8
     2 last_patient_pay_dt_tm = dq8
     2 cbos_pe_reltn_id = f8
     2 encounters[*]
       3 pft_encntr_amount = f8
       3 pft_pay_plan_pe_reltn_id = f8
       3 pft_encntr_id = f8
       3 orig_encounter_bal = f8
       3 orig_encounter_dt_tm = dq8
       3 ending_encntr_dt_tm = dq8
       3 ending_encntr_status_cd = f8
       3 ending_encntr_status_disp = vc
       3 ending_encntr_status_desc = vc
       3 ending_encntr_status_mean = vc
       3 ending_encntr_status_code_set = f8
       3 ppr_updt_cnt = i4
       3 admit_dt_tm = dq8
       3 encntr_balance = f8
       3 last_patient_pay_dt_tm = dq8
       3 cbos_pe_reltn_id = f8
     2 ppr_active_ind = i2
 )
 FREE RECORD temprecurencntr
 RECORD temprecurencntr(
   1 objarray[*]
     2 pft_encntr_id = f8
 )
 FREE RECORD temprecbohpupt
 RECORD temprecbohpupt(
   1 objarray[*]
     2 bo_hp_reltn_id = f8
     2 encntr_plan_reltn_id = f8
 )
 FREE RECORD tempprimaryhps
 RECORD tempprimaryhps(
   1 objarray[*]
     2 encntr_plan_reltn_id = f8
     2 health_plan_id = f8
     2 beg_effective_dt_tm = dq8
     2 fin_beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 fin_class_cd = f8
 )
 RECORD emaddchargemodrequest(
   1 charge_mod_qual = i2
   1 skip_charge_event_mod_ind = i2
   1 charge_mod[*]
     2 action_type = c3
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 charge_event_mod_type_cd = f8
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
     2 nomen_entity_reltn_id = f8
     2 cm1_nbr = f8
 )
 FREE RECORD addchargemodreply
 RECORD addchargemodreply(
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
 FREE RECORD reverse_trans_request
 RECORD reverse_trans_request(
   1 inproc_batch_trans_id = f8
   1 batch_type_flag = i2
   1 script_name = vc
   1 suppress_transfer_reversal = i2
   1 objarray[*]
     2 activity_id = f8
     2 amount = f8
 )
 FREE RECORD add_comment_req
 RECORD add_comment_req(
   1 objarray[*]
     2 corsp_desc = vc
     2 importance_flag = i2
     2 acct_id = f8
     2 pft_encntr_id = f8
 )
 FREE RECORD afc_mic_request
 RECORD afc_mic_request(
   1 charge_item_id = f8
   1 charge_type_cd = f8
   1 process_flg = i4
   1 ord_phys_id = f8
   1 research_acct_id = f8
   1 abn_status_cd = f8
   1 verify_phys_id = f8
   1 perf_loc_cd = f8
   1 service_dt_tm = dq8
   1 suspense_rsn_cd = f8
   1 reason_comment = vc
   1 charge_description = vc
   1 item_price = f8
   1 item_extended_price = f8
   1 item_quantity = f8
   1 late_charge_processing_ind = i2
   1 item_copay = f8
   1 item_deductible_amt = f8
   1 patient_responsibility_flag = i2
   1 modified_copy = i2
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_type_cd = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 nomen_entity_reltn_id = f8
     2 nomen_id = f8
     2 field6 = vc
     2 field7 = vc
 )
 FREE RECORD objexistingimebohp
 RECORD objexistingimebohp(
   1 objarray[*]
     2 bo_hp_reltn_id = f8
     2 benefit_order_id = f8
     2 health_plan_id = f8
     2 invalidate_ind = i2
     2 claim_list[*]
       3 corsp_activity_id = f8
       3 bill_vrsn_nbr = f8
       3 updt_cnt = i4
       3 bill_status_cd = f8
       3 submit_dt_tm = dq8
 )
 FREE RECORD currentcob
 RECORD currentcob(
   1 failure_message = vc
   1 objarray[*]
     2 encntr_id = f8
     2 person_id = f8
     2 effective_dt_tm = f8
     2 health_plan_id = f8
     2 health_plan_name = vc
     2 encntr_plan_reltn_id = f8
     2 beg_effective_dt_tm = f8
     2 end_effective_dt_tm = f8
     2 priority_seq = i4
     2 financial_class_cd = f8
     2 payer_org = f8
 )
 FREE RECORD cons_bo_sched_rep
 RECORD cons_bo_sched_rep(
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
 EXECUTE srvrtl
 EXECUTE crmrtl
 IF ("Z"=validate(pft_common_vrsn,"Z"))
  DECLARE pft_common_vrsn = vc WITH noconstant(""), public
 ENDIF
 SET pft_common_vrsn = "500383.087"
 IF ((validate(pft_neither,- (1))=- (1)))
  DECLARE pft_neither = i2 WITH constant(0)
 ENDIF
 IF ((validate(pft_debit,- (1))=- (1)))
  DECLARE pft_debit = i2 WITH constant(1)
 ENDIF
 IF ((validate(pft_credit,- (1))=- (1)))
  DECLARE pft_credit = i2 WITH constant(2)
 ENDIF
 IF (validate(null_f8,0.0)=0.0)
  DECLARE null_f8 = f8 WITH constant(- (0.00001))
 ENDIF
 IF (validate(null_i2,0)=0)
  DECLARE null_i2 = i2 WITH constant(- (1))
 ENDIF
 IF (validate(null_i4,0)=0)
  DECLARE null_i4 = i4 WITH constant(- (1))
 ENDIF
 IF ((validate(null_dt,- (1.0))=- (1.0)))
  DECLARE null_dt = q8 WITH constant(0.0)
 ENDIF
 IF (validate(null_vc,"Z")="Z")
  DECLARE null_vc = vc WITH constant("")
 ENDIF
 IF ((validate(upt_force,- (1))=- (1)))
  DECLARE upt_force = i4 WITH constant(- (99999))
 ENDIF
 IF ((validate(log_error,- (1))=- (1)))
  DECLARE log_error = i4 WITH constant(0)
 ENDIF
 IF ((validate(log_warning,- (1))=- (1)))
  DECLARE log_warning = i4 WITH constant(1)
 ENDIF
 IF ((validate(log_audit,- (1))=- (1)))
  DECLARE log_audit = i4 WITH constant(2)
 ENDIF
 IF ((validate(log_info,- (1))=- (1)))
  DECLARE log_info = i4 WITH constant(3)
 ENDIF
 IF ((validate(log_debug,- (1))=- (1)))
  DECLARE log_debug = i4 WITH constant(4)
 ENDIF
 IF (validate(ein_pft_charge,0)=0)
  DECLARE ein_pft_charge = i4 WITH constant(1)
 ENDIF
 IF (validate(ein_charge_item,0)=0)
  DECLARE ein_charge_item = i4 WITH constant(2)
 ENDIF
 IF (validate(ein_bill_header,0)=0)
  DECLARE ein_bill_header = i4 WITH constant(3)
 ENDIF
 IF (validate(ein_pft_encntr,0)=0)
  DECLARE ein_pft_encntr = i4 WITH constant(4)
 ENDIF
 IF (validate(ein_benefit_order,0)=0)
  DECLARE ein_benefit_order = i4 WITH constant(5)
 ENDIF
 IF (validate(ein_guarantor,0)=0)
  DECLARE ein_guarantor = i4 WITH constant(6)
 ENDIF
 IF (validate(ein_encounter,0)=0)
  DECLARE ein_encounter = i4 WITH constant(7)
 ENDIF
 IF (validate(ein_account,0)=0)
  DECLARE ein_account = i4 WITH constant(8)
 ENDIF
 IF (validate(ein_remittance,0)=0)
  DECLARE ein_remittance = i4 WITH constant(9)
 ENDIF
 IF (validate(ein_eob,0)=0)
  DECLARE ein_eob = i4 WITH constant(10)
 ENDIF
 IF (validate(ein_billing_entity,0)=0)
  DECLARE ein_billing_entity = i4 WITH constant(11)
 ENDIF
 IF (validate(ein_person,0)=0)
  DECLARE ein_person = i4 WITH constant(12)
 ENDIF
 IF (validate(ein_activity,0)=0)
  DECLARE ein_activity = i4 WITH constant(13)
 ENDIF
 IF (validate(ein_fin_nbr,0)=0)
  DECLARE ein_fin_nbr = i4 WITH constant(14)
 ENDIF
 IF (validate(ein_bo_hp_reltn,0)=0)
  DECLARE ein_bo_hp_reltn = i4 WITH constant(15)
 ENDIF
 IF (validate(ein_denial,0)=0)
  DECLARE ein_denial = i4 WITH constant(16)
 ENDIF
 IF (validate(ein_client_account,0)=0)
  DECLARE ein_client_account = i4 WITH constant(17)
 ENDIF
 IF (validate(ein_encntr_clln_reltn,0)=0)
  DECLARE ein_encntr_clln_reltn = i4 WITH constant(18)
 ENDIF
 IF (validate(ein_bill_nbr,0)=0)
  DECLARE ein_bill_nbr = i4 WITH constant(19)
 ENDIF
 IF (validate(ein_trans_alias,0)=0)
  DECLARE ein_trans_alias = i4 WITH constant(20)
 ENDIF
 IF (validate(ein_trans_alias_elements,0)=0)
  DECLARE ein_trans_alias_elements = i4 WITH constant(21)
 ENDIF
 IF (validate(ein_hold,0)=0)
  DECLARE ein_hold = i4 WITH constant(22)
 ENDIF
 IF (validate(ein_hold_prompt,0)=0)
  DECLARE ein_hold_prompt = i4 WITH constant(23)
 ENDIF
 IF (validate(ein_person_at,0)=0)
  DECLARE ein_person_at = i4 WITH constant(24)
 ENDIF
 IF (validate(ein_reversal,0)=0)
  DECLARE ein_reversal = i4 WITH constant(25)
 ENDIF
 IF (validate(ein_ext_acct_id_txt,0)=0)
  DECLARE ein_ext_acct_id_txt = i4 WITH constant(26)
 ENDIF
 IF (validate(ein_organization,0)=0)
  DECLARE ein_organization = i4 WITH constant(27)
 ENDIF
 IF (validate(ein_fifo,0)=0)
  DECLARE ein_fifo = i4 WITH constant(28)
 ENDIF
 IF (validate(ein_nopost,0)=0)
  DECLARE ein_nopost = i4 WITH constant(29)
 ENDIF
 IF (validate(ein_date_time,0)=0)
  DECLARE ein_date_time = i4 WITH constant(30)
 ENDIF
 IF (validate(ein_encntr_package,0)=0)
  DECLARE ein_encntr_package = i4 WITH constant(31)
 ENDIF
 IF (validate(ein_pay_plan_hist,0)=0)
  DECLARE ein_pay_plan_hist = i4 WITH constant(32)
 ENDIF
 IF (validate(ein_report_date,0)=0)
  DECLARE ein_report_date = i4 WITH constant(33)
 ENDIF
 IF (validate(ein_parent_entity,0)=0)
  DECLARE ein_parent_entity = i4 WITH constant(34)
 ENDIF
 IF (validate(ein_pay_plan_suggest,0)=0)
  DECLARE ein_pay_plan_suggest = i4 WITH constant(35)
 ENDIF
 IF (validate(ein_report_instance,0)=0)
  DECLARE ein_report_instance = i4 WITH constant(36)
 ENDIF
 IF (validate(ein_pft_fiscal_daily_id,0)=0)
  DECLARE ein_pft_fiscal_daily_id = i4 WITH constant(37)
 ENDIF
 IF (validate(ein_pft_encntr_fact_active,0)=0)
  DECLARE ein_pft_encntr_fact_active = i4 WITH constant(38)
 ENDIF
 IF (validate(ein_pft_encntr_fact_history,0)=0)
  DECLARE ein_pft_encntr_fact_history = i4 WITH constant(39)
 ENDIF
 IF (validate(ein_invoice,0)=0)
  DECLARE ein_invoice = i4 WITH constant(40)
 ENDIF
 IF (validate(ein_pending_batch,0)=0)
  DECLARE ein_pending_batch = i4 WITH constant(41)
 ENDIF
 IF (validate(ein_application,0)=0)
  DECLARE ein_application = i4 WITH constant(42)
 ENDIF
 IF (validate(ein_view,0)=0)
  DECLARE ein_view = i4 WITH constant(43)
 ENDIF
 IF (validate(ein_test,0)=0)
  DECLARE ein_test = i4 WITH constant(44)
 ENDIF
 IF (validate(ein_trans_alias_best_guess_wo_reason,0)=0)
  DECLARE ein_trans_alias_best_guess_wo_reason = i4 WITH constant(45)
 ENDIF
 IF (validate(ein_submitted_batch,0)=0)
  DECLARE ein_submitted_batch = i4 WITH constant(46)
 ENDIF
 IF (validate(ein_dequeue_wf_batch,0)=0)
  DECLARE ein_dequeue_wf_batch = i4 WITH constant(47)
 ENDIF
 IF (validate(ein_account_date,0)=0)
  DECLARE ein_account_date = i4 WITH constant(48)
 ENDIF
 IF (validate(ein_entity,0)=0)
  DECLARE ein_entity = i4 WITH constant(49)
 ENDIF
 IF (validate(ein_pft_line_item,0)=0)
  DECLARE ein_pft_line_item = i4 WITH constant(50)
 ENDIF
 IF (validate(ein_transfer,0)=0)
  DECLARE ein_transfer = i4 WITH constant(51)
 ENDIF
 IF (validate(ein_suppress,0)=0)
  DECLARE ein_suppress = i4 WITH constant(52)
 ENDIF
 IF (validate(ein_related_trans,0)=0)
  DECLARE ein_related_trans = i4 WITH constant(53)
 ENDIF
 IF (validate(ein_wf_entity_status,0)=0)
  DECLARE ein_wf_entity_status = i4 WITH constant(54)
 ENDIF
 IF (validate(ein_health_plan,0)=0)
  DECLARE ein_health_plan = i4 WITH constant(55)
 ENDIF
 IF (validate(ein_global_preference,0)=0)
  DECLARE ein_global_preference = i4 WITH constant(56)
 ENDIF
 IF (validate(ein_balance,0)=0)
  DECLARE ein_balance = i4 WITH constant(57)
 ENDIF
 IF (validate(ein_user_name,0)=0)
  DECLARE ein_user_name = i4 WITH constant(58)
 ENDIF
 IF (validate(ein_ready_to_bill,0)=0)
  DECLARE ein_ready_to_bill = i4 WITH constant(59)
 ENDIF
 IF (validate(ein_ready_to_bill_claim,0)=0)
  DECLARE ein_ready_to_bill_claim = i4 WITH constant(60)
 ENDIF
 IF (validate(ein_umdap_del,0)=0)
  DECLARE ein_umdap_del = i4 WITH constant(61)
 ENDIF
 IF (validate(ein_umdap_quest,0)=0)
  DECLARE ein_umdap_quest = i4 WITH constant(62)
 ENDIF
 IF (validate(ein_umdap_hist,0)=0)
  DECLARE ein_umdap_hist = i4 WITH constant(63)
 ENDIF
 IF (validate(ein_new_entity,0)=0)
  DECLARE ein_new_entity = i4 WITH constant(64)
 ENDIF
 IF (validate(ein_account_selfpay_bal,0)=0)
  DECLARE ein_account_selfpay_bal = i4 WITH constant(65)
 ENDIF
 IF (validate(ein_guarantor_selfpay_bal,0)=0)
  DECLARE ein_guarantor_selfpay_bal = i4 WITH constant(66)
 ENDIF
 IF (validate(ein_queue,0)=0)
  DECLARE ein_queue = i4 WITH constant(67)
 ENDIF
 IF (validate(ein_supervisor,0)=0)
  DECLARE ein_supervisor = i4 WITH constant(68)
 ENDIF
 IF (validate(ein_ar_management,0)=0)
  DECLARE ein_ar_management = i4 WITH constant(69)
 ENDIF
 IF (validate(ein_status,0)=0)
  DECLARE ein_status = i4 WITH constant(70)
 ENDIF
 IF (validate(ein_status_type_event,0)=0)
  DECLARE ein_status_type_event = i4 WITH constant(71)
 ENDIF
 IF (validate(ein_pftencntr_selfpay_bal,0)=0)
  DECLARE ein_pftencntr_selfpay_bal = i4 WITH constant(72)
 ENDIF
 IF (validate(ein_batch_event,0)=0)
  DECLARE ein_batch_event = i4 WITH constant(73)
 ENDIF
 IF (validate(ein_ready_to_bill_all_sp,0)=0)
  DECLARE ein_ready_to_bill_all_sp = i4 WITH constant(74)
 ENDIF
 IF (validate(ein_account_stmt,0)=0)
  DECLARE ein_account_stmt = i4 WITH constant(75)
 ENDIF
 IF (validate(ein_pft_encntr_stmt,0)=0)
  DECLARE ein_pft_encntr_stmt = i4 WITH constant(76)
 ENDIF
 IF (validate(ein_guarantor_stmt,0)=0)
  DECLARE ein_guarantor_stmt = i4 WITH constant(77)
 ENDIF
 IF (validate(ein_pft_encntr_claim,0)=0)
  DECLARE ein_pft_encntr_claim = i4 WITH constant(78)
 ENDIF
 IF (validate(ein_pftencntr_combine,0)=0)
  DECLARE ein_pftencntr_combine = i4 WITH constant(79)
 ENDIF
 IF (validate(ein_current_eob,0)=0)
  DECLARE ein_current_eob = i4 WITH constant(80)
 ENDIF
 IF (validate(ein_prior_eobs,0)=0)
  DECLARE ein_prior_eobs = i4 WITH constant(81)
 ENDIF
 IF (validate(ein_last,0)=0)
  DECLARE ein_last = i4 WITH constant(82)
 ENDIF
 IF (validate(ein_cob,0)=0)
  DECLARE ein_cob = i4 WITH constant(83)
 ENDIF
 IF (validate(ein_encounter_active,0)=0)
  DECLARE ein_encounter_active = i4 WITH constant(84)
 ENDIF
 IF (validate(ein_remittance_all,0)=0)
  DECLARE ein_remittance_all = i4 WITH constant(85)
 ENDIF
 IF (validate(ein_pay_plan,0)=0)
  DECLARE ein_pay_plan = i4 WITH constant(86)
 ENDIF
 IF (validate(ein_guar_acct,0)=0)
  DECLARE ein_guar_acct = i4 WITH constant(87)
 ENDIF
 IF (validate(ein_report,0)=0)
  DECLARE ein_report = i4 WITH constant(88)
 ENDIF
 IF (validate(ein_ime_benefit_order,0)=0)
  DECLARE ein_ime_benefit_order = i4 WITH constant(89)
 ENDIF
 IF (validate(ein_formal_payment_plan,0)=0)
  DECLARE ein_formal_payment_plan = i4 WITH constant(90)
 ENDIF
 IF (validate(ein_guarantor_account,0)=0)
  DECLARE ein_guarantor_account = i4 WITH constant(91)
 ENDIF
 IF ((validate(gnstat,- (1))=- (1)))
  DECLARE gnstat = i4 WITH noconstant(0)
 ENDIF
 IF (validate(none_action,0)=0
  AND validate(none_action,1)=1)
  DECLARE none_action = i4 WITH public, constant(0)
 ENDIF
 IF (validate(add_action,0)=0
  AND validate(add_action,1)=1)
  DECLARE add_action = i4 WITH public, constant(1)
 ENDIF
 IF (validate(chg_action,0)=0
  AND validate(chg_action,1)=1)
  DECLARE chg_action = i4 WITH public, constant(2)
 ENDIF
 IF (validate(del_action,0)=0
  AND validate(del_action,1)=1)
  DECLARE del_action = i4 WITH public, constant(3)
 ENDIF
 IF (validate(pft_publish_event_flag,null_i2)=null_i2)
  DECLARE pft_publish_event_flag = i2 WITH public, noconstant(0)
 ENDIF
 DECLARE __hpsys = i4 WITH protect, noconstant(0)
 DECLARE __lpsysstat = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(threads)))
  FREE RECORD threads
  RECORD threads(
    1 objarray[*]
      2 request_handle = i4
      2 start_time = dq8
  )
 ENDIF
 IF ( NOT (validate(codevalueslist)))
  RECORD codevalueslist(
    1 codevalues[*]
      2 codevalue = f8
  ) WITH protect
 ENDIF
 IF (validate(logmsg,char(128))=char(128))
  SUBROUTINE (logmsg(sname=vc,smsg=vc,llevel=i4) =null)
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo(concat(sname,": ",smsg))
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __hpsys = 0
    SET __lpsysstat = 0
    CALL uar_syscreatehandle(__hpsys,__lpsysstat)
    IF (__hpsys > 0)
     CALL uar_sysevent(__hpsys,llevel,nullterm(sname),nullterm(smsg))
     CALL uar_sysdestroyhandle(__hpsys)
    ENDIF
    IF (llevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(smsg))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setreply,char(128))=char(128))
  SUBROUTINE (setreply(sstatus=vc,sname=vc,svalue=vc) =null)
    IF (validate(reply,char(128)) != char(128))
     SET reply->status_data.status = nullterm(sstatus)
     SET reply->status_data.subeventstatus[1].operationstatus = nullterm(sstatus)
     SET reply->status_data.subeventstatus[1].operationname = nullterm(sname)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(svalue)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setreplyblock,char(128))=char(128))
  SUBROUTINE (setreplyblock(sstatus=c1,soperstatus=c1,sname=vc,svalue=vc) =null)
   CALL logmsg(sname,svalue,log_debug)
   IF (validate(reply,char(128)) != char(128))
    SET reply->status_data.status = nullterm(sstatus)
    SET reply->status_data.subeventstatus[1].operationstatus = nullterm(soperstatus)
    SET reply->status_data.subeventstatus[1].operationname = nullterm(sname)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(svalue)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(beginscript,char(128))=char(128))
  SUBROUTINE (beginscript(sname=vc) =null)
   CALL logmsg(sname,"Begin Script",log_debug)
   CALL setreply("F",sname,"Begin Script")
  END ;Subroutine
 ENDIF
 IF (validate(exitscript,char(128))=char(128))
  SUBROUTINE (exitscript(sname=vc) =null)
   CALL logmsg(sname,"Exit Script",log_debug)
   CALL setreply("S",sname,"Exit Script")
  END ;Subroutine
 ENDIF
 IF (validate(abortscript,char(128))=char(128))
  SUBROUTINE (abortscript(sname=vc,smsg=vc) =null)
   CALL logmsg(sname,smsg,log_warning)
   CALL setreply("F",sname,smsg)
  END ;Subroutine
 ENDIF
 IF (validate(setfieldheader,char(128))=char(128))
  SUBROUTINE (setfieldheader(sfield=vc,stype=vc,sdisplay=vc) =null)
   DECLARE nheadersize = i2 WITH noconstant(0)
   IF (validate(objreply->headers)=1)
    SET nheadersize = (size(objreply->headers,5)+ 1)
    SET stat = alterlist(objreply->headers,nheadersize)
    SET objreply->headers[nheadersize].field_name = sfield
    SET objreply->headers[nheadersize].field_type = stype
    SET objreply->headers[nheadersize].header_display = sdisplay
   ELSEIF (validate(reply->headers)=1)
    SET nheadersize = (size(reply->headers,5)+ 1)
    SET stat = alterlist(reply->headers,nheadersize)
    SET reply->headers[nheadersize].field_name = sfield
    SET reply->headers[nheadersize].field_type = stype
    SET reply->headers[nheadersize].header_display = sdisplay
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setfieldheaderattr,char(128))=char(128))
  SUBROUTINE (setfieldheaderattr(sfield=vc,stype=vc,sdisplay=vc,sgroupprefix=vc,sgrpaggrprefix=vc,
   sgrpaggrfnctn=vc,stotalprefix=vc,stotalfunction=vc) =null)
   DECLARE nheadersize = i2 WITH noconstant(0)
   IF (validate(objreply->headers,char(128)) != char(128))
    SET nheadersize = (size(objreply->headers,5)+ 1)
    SET stat = alterlist(objreply->headers,nheadersize)
    SET objreply->headers[nheadersize].field_name = sfield
    SET objreply->headers[nheadersize].field_type = stype
    SET objreply->headers[nheadersize].header_display = sdisplay
    SET objreply->headers[nheadersize].group_prefix = sgroupprefix
    SET objreply->headers[nheadersize].group_aggr_prefix = sgrpaggrprefix
    SET objreply->headers[nheadersize].group_aggr_func = sgrpaggrfnctn
    SET objreply->headers[nheadersize].total_prefix = stotalprefix
    SET objreply->headers[nheadersize].total_func = stotalfunction
   ELSEIF (validate(reply->headers,char(128)) != char(128))
    SET nheadersize = (size(reply->headers,5)+ 1)
    SET stat = alterlist(reply->headers,nheadersize)
    SET reply->headers[nheadersize].field_name = sfield
    SET reply->headers[nheadersize].field_type = stype
    SET reply->headers[nheadersize].header_display = sdisplay
    SET reply->headers[nheadersize].group_prefix = sgroupprefix
    SET reply->headers[nheadersize].group_aggr_prefix = sgrpaggrprefix
    SET reply->headers[nheadersize].group_aggr_func = sgrpaggrfnctn
    SET reply->headers[nheadersize].total_prefix = stotalprefix
    SET reply->headers[nheadersize].total_func = stotalfunction
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(formatcurrency,char(128))=char(128))
  SUBROUTINE (formatcurrency(damt=f8) =vc)
    DECLARE sformattedamt = vc WITH noconstant("")
    SET sformattedamt = format(damt,"#########.##;I$,;F")
    IF (damt <= 0)
     SET sformattedamt = trim(sformattedamt,3)
     SET sformattedamt = substring(2,textlen(sformattedamt),sformattedamt)
     SET sformattedamt = concat("(",trim(sformattedamt,3),")")
    ENDIF
    SET sformattedamt = trim(sformattedamt,3)
    RETURN(sformattedamt)
  END ;Subroutine
 ENDIF
 IF (validate(setsrvdouble,char(128))=char(128))
  SUBROUTINE (setsrvdouble(hhandle=i4,sfield=vc,dvalue=f8) =null)
    IF (uar_srvfieldexists(hhandle,nullterm(sfield)))
     SET gnstat = uar_srvsetdouble(hhandle,nullterm(sfield),dvalue)
     IF (gnstat=0)
      CALL logmsg(curprog,concat("Set ",sfield," failed"),log_debug)
     ENDIF
    ELSE
     CALL logmsg(curprog,concat("Field ",sfield," doesn't exist in the request structure"),log_debug)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setsrvstring,char(128))=char(128))
  SUBROUTINE (setsrvstring(hhandle=i4,sfield=vc,svalue=vc) =null)
    IF (uar_srvfieldexists(hhandle,nullterm(sfield)))
     SET gnstat = uar_srvsetstring(hhandle,nullterm(sfield),nullterm(svalue))
     IF (gnstat=0)
      CALL logmsg(curprog,concat("Set ",sfield," failed"),log_debug)
     ENDIF
    ELSE
     CALL logmsg(curprog,concat("Field ",sfield," doesn't exist in the request structure"),log_debug)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setsrvlong,char(128))=char(128))
  SUBROUTINE (setsrvlong(hhandle=i4,sfield=vc,lvalue=i4) =null)
    IF (uar_srvfieldexists(hhandle,nullterm(sfield)))
     SET gnstat = uar_srvsetlong(hhandle,nullterm(sfield),lvalue)
     IF (gnstat=0)
      CALL logmsg(curprog,concat("Set ",sfield," failed"),log_debug)
     ENDIF
    ELSE
     CALL logmsg(curprog,concat("Field ",sfield," doesn't exist in the request structure"),log_debug)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setsrvshort,char(128))=char(128))
  SUBROUTINE (setsrvshort(hhandle=i4,sfield=vc,nvalue=i4) =null)
    IF (uar_srvfieldexists(hhandle,nullterm(sfield)))
     SET gnstat = uar_srvsetshort(hhandle,nullterm(sfield),nvalue)
     IF (gnstat=0)
      CALL logmsg(curprog,concat("Set ",sfield," failed"),log_debug)
     ENDIF
    ELSE
     CALL logmsg(curprog,concat("Field ",sfield," doesn't exist in the request structure"),log_debug)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setsrvdate,char(128))=char(128))
  SUBROUTINE (setsrvdate(hhandle=i4,sfield=vc,dtvalue=q8) =null)
    IF (uar_srvfieldexists(hhandle,nullterm(sfield)))
     SET gnstat = uar_srvsetdate(hhandle,nullterm(sfield),dtvalue)
     IF (gnstat=0)
      CALL logmsg(curprog,concat("Set ",sfield," failed"),log_debug)
     ENDIF
    ELSE
     CALL logmsg(curprog,concat("Field ",sfield," doesn't exist in the request structure"),log_debug)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(publishevent,char(128))=char(128))
  SUBROUTINE (publishevent(dummyvar=i4) =null)
    CALL logmsg(curprog,"IN PublishEvent",log_debug)
    DECLARE nappid = i4 WITH protect, constant(4080000)
    DECLARE ntaskid = i4 WITH protect, constant(4080000)
    DECLARE nreqid = i4 WITH protect, constant(4080140)
    DECLARE sreq = vc WITH protect, constant("pft_manage_event_completion")
    DECLARE happ = i4 WITH protect, noconstant(0)
    DECLARE htask = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrequest = i4 WITH protect, noconstant(0)
    DECLARE hitem = i4 WITH protect, noconstant(0)
    DECLARE hreply = i4 WITH protect, noconstant(0)
    DECLARE hstatus = i4 WITH protect, noconstant(0)
    DECLARE ncnt = i4 WITH protect, noconstant(0)
    DECLARE npidx = i4 WITH protect, noconstant(0)
    DECLARE ipublisheventflg = i2 WITH constant(validate(pft_publish_event_flag,0))
    IF (validate(pft_publish_event_flag))
     CALL logmsg(curprog,concat("pft_publish_event_flag exist. value:: ",cnvtstring(
        pft_publish_event_flag,5)),4)
    ELSE
     CALL logmsg(curprog,"pft_publish_event_flag doesn't exist",4)
    ENDIF
    IF (validate(reply->objarray,char(128))=char(128))
     CALL logmsg(curprog,"No objArray found in reply",log_debug)
     RETURN
    ENDIF
    IF (validate(reply->status_data.status,"F") != "S")
     CALL logmsg(curprog,concat("Reply status as (",validate(reply->status_data.status,"F"),
       "). Not publishing events."),log_debug)
     RETURN
    ENDIF
    CASE (ipublisheventflg)
     OF 0:
      SET curalias eventrec reply->objarray[npidx]
      SET ncnt = size(reply->objarray,5)
     OF 1:
      CALL queueitemstoeventrec(0)
      RETURN
     OF 2:
      SET curalias eventrec pft_event_rec->objarray[npidx]
      SET ncnt = size(pft_event_rec->objarray,5)
    ENDCASE
    IF (ncnt > 0)
     SET npidx = 1
     IF (validate(eventrec->published_ind,null_i2)=null_i2)
      CALL logmsg(curprog,"Field published_ind not found in objArray",log_debug)
      RETURN
     ENDIF
     SET gnstat = uar_crmbeginapp(nappid,happ)
     IF (gnstat != 0)
      CALL logmsg(curprog,"Unable to create application instance (4080000)",log_error)
      RETURN
     ENDIF
     SET gnstat = uar_crmbegintask(happ,ntaskid,htask)
     IF (gnstat != 0)
      CALL logmsg(curprog,"Unable to create task instance (4080000)",log_error)
      IF (happ > 0)
       CALL uar_crmendapp(happ)
      ENDIF
      RETURN
     ENDIF
     FOR (npidx = 1 TO ncnt)
       IF ((eventrec->published_ind=false))
        SET gnstat = uar_crmbeginreq(htask,nullterm(sreq),nreqid,hreq)
        IF (gnstat != 0)
         CALL logmsg(curprog,"Unable to create request instance (4080140)",log_error)
        ELSE
         SET hrequest = uar_crmgetrequest(hreq)
         IF (hrequest=0)
          CALL logmsg(curprog,"Unable to retrieve request handle for (4080140)",log_error)
         ELSE
          SET hitem = uar_srvadditem(hrequest,"objArray")
          IF (hitem=0)
           CALL logmsg(curprog,"Unable to add item to request (4080140)",log_error)
          ELSE
           IF (validate(eventrec->event_key,char(128)) != char(128))
            CALL setsrvstring(hitem,"event_key",eventrec->event_key)
           ELSE
            CALL logmsg(curprog,"Field event_key not found in objArray",log_debug)
           ENDIF
           IF (validate(eventrec->category_key,char(128)) != char(128))
            CALL setsrvstring(hitem,"category_key",eventrec->category_key)
           ELSE
            CALL logmsg(curprog,"Field category_key not found in objArray",log_debug)
           ENDIF
           IF (validate(eventrec->acct_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"acct_id",eventrec->acct_id)
           ENDIF
           IF (validate(eventrec->pft_encntr_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"pft_encntr_id",eventrec->pft_encntr_id)
           ENDIF
           IF (validate(eventrec->encntr_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"encntr_id",eventrec->encntr_id)
           ENDIF
           IF (validate(eventrec->bo_hp_reltn_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"bo_hp_reltn_id",eventrec->bo_hp_reltn_id)
           ENDIF
           IF (validate(eventrec->corsp_activity_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"corsp_activity_id",eventrec->corsp_activity_id)
           ENDIF
           IF (validate(eventrec->activity_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"activity_id",eventrec->activity_id)
           ENDIF
           IF (validate(eventrec->pft_charge_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"pft_charge_id",eventrec->pft_charge_id)
           ENDIF
           IF (validate(eventrec->service_cd,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"entity_service_cd",eventrec->service_cd)
           ENDIF
           IF (validate(eventrec->batch_trans_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"batch_trans_id",eventrec->batch_trans_id)
           ENDIF
           IF (validate(eventrec->pft_bill_activity_id,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"pft_bill_activity_id",eventrec->pft_bill_activity_id)
           ENDIF
           IF (validate(eventrec->bill_vrsn_nbr,null_i4) != null_i4)
            CALL setsrvlong(hitem,"bill_vrsn_nbr",eventrec->bill_vrsn_nbr)
           ENDIF
           IF (validate(eventrec->pe_status_reason_cd,null_f8) != null_f8)
            CALL setsrvdouble(hitem,"pe_status_reason_cd",eventrec->pe_status_reason_cd)
           ENDIF
           CALL logmsg("PFT_COMMON",build("pft_publish_event_binding::",validate(
              pft_publish_event_binding,"N/A")),log_debug)
           IF (validate(pft_publish_event_binding,"") != "")
            SET gnstat = uar_crmperformas(hreq,nullterm(pft_publish_event_binding))
           ELSE
            SET gnstat = uar_crmperform(hreq)
           ENDIF
           IF (gnstat != 0)
            CALL logmsg(curprog,concat("Failed to execute server step (",cnvtstring(nreqid,11),")"),
             log_error)
           ELSE
            SET hreply = uar_crmgetreply(hreq)
            IF (hreply=0)
             CALL logmsg(curprog,"Failed to retrieve reply structure",log_error)
            ELSE
             SET hstatus = uar_srvgetstruct(hreply,"status_data")
             IF (hstatus=0)
              CALL logmsg(curprog,"Failed to retrieve status_block",log_error)
             ELSE
              IF (uar_srvgetstringptr(hstatus,"status")="S")
               SET eventrec->published_ind = true
              ENDIF
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ENDIF
        IF (hreq > 0)
         CALL uar_crmendreq(hreq)
        ENDIF
       ENDIF
     ENDFOR
     IF (htask > 0)
      CALL uar_crmendtask(htask)
     ENDIF
     IF (happ > 0)
      CALL uar_crmendapp(happ)
     ENDIF
    ELSE
     CALL logmsg(curprog,"Not objects in objArray",log_debug)
    ENDIF
    SET curalias eventrec off
  END ;Subroutine
 ENDIF
 IF (validate(queueitemstoeventrec,char(128))=char(128))
  SUBROUTINE (queueitemstoeventrec(dummyvar=i4) =null)
    DECLARE ncnt = i4 WITH protect, noconstant(0)
    DECLARE npeventidx = i4 WITH protect, noconstant(0)
    DECLARE npidx = i4 WITH protect, noconstant(0)
    IF (validate(pft_event_rec,char(128))=char(128))
     CALL logmsg(curprog,"pft_event_rec must be declared by call InitEvents",4)
    ENDIF
    SET curalias event_rec pft_event_rec->objarray[npeventidx]
    SET curalias reply_rec reply->objarray[npidx]
    SET ncnt = size(reply->objarray,5)
    FOR (npidx = 1 TO ncnt)
      IF (validate(reply_rec->published_ind,true)=false)
       SET npeventidx = (size(pft_event_rec->objarray,5)+ 1)
       SET stat = alterlist(pft_event_rec->objarray,npeventidx)
       SET event_rec->published_ind = false
       SET event_rec->event_key = validate(reply_rec->event_key,"")
       SET event_rec->category_key = validate(reply_rec->category_key,"")
       SET event_rec->acct_id = validate(reply_rec->acct_id,0.0)
       SET event_rec->pft_encntr_id = validate(reply_rec->pft_encntr_id,0.0)
       SET event_rec->encntr_id = validate(reply_rec->encntr_id,0.0)
       SET event_rec->bo_hp_reltn_id = validate(reply_rec->bo_hp_reltn_id,0.0)
       SET event_rec->corsp_activity_id = validate(reply_rec->corsp_activity_id,0.0)
       SET event_rec->activity_id = validate(reply_rec->activity_id,0.0)
       SET event_rec->pft_charge_id = validate(reply_rec->pft_charge_id,0.0)
       SET event_rec->service_cd = validate(reply_rec->service_cd,0.0)
       SET event_rec->batch_trans_id = validate(reply_rec->batch_trans_id,0.0)
       SET event_rec->pft_bill_activity_id = validate(reply_rec->pft_bill_activity_id,0.0)
       SET event_rec->bill_vrsn_nbr = validate(reply_rec->bill_vrsn_nbr,0)
       SET event_rec->pe_status_reason_cd = validate(reply_rec->pe_status_reason_cd,0.0)
       SET reply_rec->published_ind = true
      ENDIF
    ENDFOR
    SET curalias event_rec off
    SET curalias reply_rec off
  END ;Subroutine
 ENDIF
 IF (validate(initevents,char(128))=char(128))
  SUBROUTINE (initevents(publishflag=i2) =null)
    SET pft_publish_event_flag = publishflag
    FREE RECORD pft_event_rec
    RECORD pft_event_rec(
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
    ) WITH persistscript
  END ;Subroutine
 ENDIF
 IF (validate(processevents,char(128))=char(128))
  SUBROUTINE (processevents(dummyvar=i4) =null)
    DECLARE itmppublishflag = i2 WITH private, noconstant(pft_publish_event_flag)
    SET pft_publish_event_flag = 2
    CALL publishevent(0)
    SET pft_publish_event_flag = itmppublishflag
  END ;Subroutine
 ENDIF
 IF (validate(stamptime,char(128))=char(128))
  SUBROUTINE (stamptime(dummyvar=i4) =null)
    CALL echo("-----------------TIME STAMP----------------")
    CALL echo(build("-----------",curprog,"-----------"))
    CALL echo(format(curtime3,"hh:mm:ss:cc;3;M"))
    CALL echo("-----------------TIME STAMP----------------")
  END ;Subroutine
 ENDIF
 IF (validate(isequal,char(128))=char(128))
  SUBROUTINE (isequal(damt1=f8,damt2=f8) =i2)
   DECLARE tmpdiff = f8 WITH private, noconstant(abs((abs(damt1) - abs(damt2))))
   IF (tmpdiff < 0.009)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(nextavailablethread,char(128))=char(128))
  DECLARE nextavailablethread(null) = i4
  SUBROUTINE nextavailablethread(null)
    DECLARE thread_cnt = i4 WITH noconstant(size(threads->objarray,5))
    DECLARE i = i4 WITH noconstant(thread_cnt)
    DECLARE looping = i2 WITH noconstant(true)
    WHILE (thread_cnt > 0
     AND looping)
     IF ((threads->objarray[i].request_handle > 0))
      IF ((threads->objarray[i].start_time=null))
       SET threads->objarray[i].start_time = cnvtdatetime(sysdate)
      ENDIF
      IF (uar_crmperformpeek(threads->objarray[i].request_handle) IN (0, 1, 4, 5))
       SET stat = uar_crmsynch(threads->objarray[i].request_handle)
       CALL uar_crmendreq(threads->objarray[i].request_handle)
       SET threads->objarray[i].request_handle = 0
       SET threads->objarray[i].start_time = null
       SET looping = false
      ENDIF
     ELSE
      SET looping = false
     ENDIF
     IF (looping)
      SET i = evaluate(i,1,thread_cnt,(i - 1))
     ENDIF
    ENDWHILE
    RETURN(i)
  END ;Subroutine
 ENDIF
 IF (validate(waituntilthreadscomplete,char(128))=char(128))
  DECLARE waituntilthreadscomplete(null) = i4
  SUBROUTINE waituntilthreadscomplete(null)
    DECLARE thread_cnt = i4 WITH noconstant(size(threads->objarray,5))
    DECLARE i = i4 WITH noconstant(thread_cnt)
    FOR (i = 1 TO thread_cnt)
      IF ((threads->objarray[i].request_handle > 0))
       IF ((threads->objarray[i].start_time=null))
        SET threads->objarray[i].start_time = cnvtdatetime(sysdate)
       ENDIF
       SET stat = uar_crmsynch(threads->objarray[i].request_handle)
       CALL uar_crmendreq(threads->objarray[i].request_handle)
       SET threads->objarray[i].request_handle = 0
       SET threads->objarray[i].start_time = null
      ENDIF
    ENDFOR
    RETURN
  END ;Subroutine
 ENDIF
 IF (validate(waitforthreadtocomplete,char(128))=char(128))
  SUBROUTINE (waitforthreadtocomplete(thread=i4) =i4)
    IF ( NOT (validate(threads)))
     RETURN(0)
    ENDIF
    IF ( NOT (size(threads->objarray,5) > 0))
     RETURN(0)
    ENDIF
    IF ((threads->objarray[thread].request_handle > 0))
     IF ((threads->objarray[thread].start_time=null))
      SET threads->objarray[thread].start_time = cnvtdatetime(sysdate)
     ENDIF
     SET stat = uar_crmsynch(threads->objarray[thread].request_handle)
     CALL uar_crmendreq(threads->objarray[thread].request_handle)
     SET threads->objarray[thread].request_handle = 0
     SET threads->objarray[thread].start_time = null
    ENDIF
    RETURN(thread)
  END ;Subroutine
 ENDIF
 IF (validate(getcodevalueindex,char(128))=char(128))
  SUBROUTINE (getcodevalueindex(pcodevalue=f8,prcodevalueslist=vc(ref)) =i4)
    IF (((pcodevalue <= 0.0) OR (size(prcodevalueslist->codevalues,5)=0)) )
     RETURN(0)
    ENDIF
    DECLARE num = i4 WITH protect, noconstant(0)
    RETURN(locateval(num,1,size(prcodevalueslist->codevalues,5),pcodevalue,prcodevalueslist->
     codevalues[num].codevalue))
  END ;Subroutine
 ENDIF
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
 CALL echo("Including PFT_EVAL_IME_HEALTH_PLAN_INC, version [524001.006)")
 CALL echo(build("Including PFT_XML_COMMON_SUBS.INC, version [",nullterm("356730.006"),"]"))
 SUBROUTINE (begindocument(pbuffer=vc,pencoding=vc) =vc)
   RETURN(concat(pbuffer,'<?xml version="1.0" encoding="',trim(pencoding,3),'"?>'))
 END ;Subroutine
 SUBROUTINE (beginelement(pbuffer=vc,pname=vc) =vc)
   RETURN(concat(pbuffer,"<",trim(pname,3),">"))
 END ;Subroutine
 SUBROUTINE (endelement(pbuffer=vc,pname=vc) =vc)
   RETURN(concat(pbuffer,"</",trim(pname,3),">"))
 END ;Subroutine
 SUBROUTINE (writeelement(pbuffer=vc,pname=vc,pvalue=vc) =vc)
  IF (size(trim(pvalue,3)) > 0)
   RETURN(concat(pbuffer,"<",trim(pname,3),">",trim(replaceescapablecharacters(pvalue),3),
    "</",trim(pname,3),">"))
  ENDIF
  RETURN(pbuffer)
 END ;Subroutine
 SUBROUTINE (writeelementnotrim(pbuffer=vc,pname=vc,pvalue=vc) =vc)
  IF (size(trim(pvalue,3)) > 0)
   RETURN(concat(pbuffer,"<",trim(pname,3),">",replaceescapablecharacters(pvalue),
    "</",trim(pname,3),">"))
  ENDIF
  RETURN(pbuffer)
 END ;Subroutine
 SUBROUTINE (beginelementname(pbuffer=vc,pname=vc) =vc)
   RETURN(concat(pbuffer,"<",trim(pname,3)))
 END ;Subroutine
 SUBROUTINE (writeattribute(pbuffer=vc,pname=vc,pvalue=vc) =vc)
  IF (size(trim(pvalue,3)) > 0)
   RETURN(concat(pbuffer," ",trim(pname,3),'="',trim(replaceescapablecharacters(pvalue),3),
    '"'))
  ENDIF
  RETURN(pbuffer)
 END ;Subroutine
 SUBROUTINE (endelementname(pbuffer=vc) =vc)
   RETURN(concat(pbuffer,">"))
 END ;Subroutine
 SUBROUTINE (writevalue(pbuffer=vc,pvalue=vc) =vc)
   RETURN(concat(pbuffer,trim(replaceescapablecharacters(pvalue),3)))
 END ;Subroutine
 SUBROUTINE (replaceescapablecharacters(ptext=vc) =vc)
   DECLARE str_out = vc WITH protect, noconstant("")
   SET str_out = replace(ptext,"&","&amp;",0)
   SET str_out = replace(str_out,"<","&lt;",0)
   SET str_out = replace(str_out,">","&gt;",0)
   SET str_out = replace(str_out,char(34),"&quot;",0)
   SET str_out = replace(str_out,char(39),"&apos;",0)
   RETURN(str_out)
 END ;Subroutine
 SUBROUTINE (toxmldateformat(pdate=q8) =vc)
   RETURN(format(pdate,"YYYY-MM-DD;;d"))
 END ;Subroutine
 SUBROUTINE (writedateelement(pbuffer=vc,pname=vc,pdate=q8) =vc)
   DECLARE tmp_str = vc WITH protect, noconstant("")
   SET tmp_str = format(pdate,"YYYY-MM-DD;;d")
   IF (size(trim(tmp_str,3)) > 0)
    RETURN(concat(pbuffer,"<",trim(pname,3),">",trim(replaceescapablecharacters(tmp_str),3),
     "</",trim(pname,3),">"))
   ENDIF
   RETURN(pbuffer)
 END ;Subroutine
 SUBROUTINE (writedatetimeelement(pbuffer=vc,pname=vc,pdate=q8) =vc)
   DECLARE datetime = vc WITH protect, noconstant(format(pdate,"YYYY-MM-DDTHH:MM:SS;3;Q"))
   IF (size(trim(datetime,3)) > 0)
    RETURN(concat(pbuffer,"<",trim(pname,3),">",trim(replaceescapablecharacters(datetime),3),
     "</",trim(pname,3),">"))
   ENDIF
   RETURN(pbuffer)
 END ;Subroutine
 SUBROUTINE (writecodetype(pbuffer=vc,pname=vc,pcodevalue=f8) =vc)
   DECLARE meaning = vc WITH protect, noconstant("")
   DECLARE displaykey = vc WITH protect, noconstant("")
   DECLARE alias = vc WITH private, noconstant("")
   DECLARE lindex = i4 WITH protect, noconstant(0)
   DECLARE pbuffer1 = vc WITH protect, noconstant("")
   DECLARE pbuffer2 = vc WITH protect, noconstant("")
   DECLARE pbuffer3 = vc WITH protect, noconstant("")
   DECLARE pbuffer4 = vc WITH protect, noconstant("")
   DECLARE pbuffer5 = vc WITH protect, noconstant("")
   DECLARE pbuffer6 = vc WITH protect, noconstant("")
   DECLARE pbuffer7 = vc WITH protect, noconstant(pbuffer)
   IF (pcodevalue > 0.0)
    IF (validate(gpreferences->currentbatchcontributorsources.contributorsourcecd,0.0) > 0.0)
     SET alias = getcachedcodevalueoutboundalias(gpreferences->currentbatchcontributorsources.
      contributorsourcecd,pcodevalue)
    ENDIF
    IF ( NOT (alias > ""))
     IF (validate(gpreferences->currentbatchcontributorsources.altcontributorsourcecd,0.0) > 0.0)
      SET alias = getcachedcodevalueoutboundalias(gpreferences->currentbatchcontributorsources.
       altcontributorsourcecd,pcodevalue)
     ENDIF
    ENDIF
    SET meaning = uar_get_code_meaning(pcodevalue)
    SET displaykey = cnvtupper(cnvtalphanum(uar_get_code_display(pcodevalue)))
    IF (((size(trim(meaning,3)) > 0) OR (((size(trim(displaykey,3)) > 0) OR (size(trim(alias,3)) > 0
    )) )) )
     SET pbuffer1 = beginelementname(pbuffer,pname)
     SET pbuffer2 = writeattribute(pbuffer1,"id",cnvtstring(pcodevalue,17))
     SET pbuffer3 = writeattribute(pbuffer2,"meaning",meaning)
     SET pbuffer4 = writeattribute(pbuffer3,"displayKey",displaykey)
     SET pbuffer5 = writeattribute(pbuffer4,"outboundAlias",alias)
     SET pbuffer6 = endelementname(pbuffer5)
     SET pbuffer7 = endelement(pbuffer6,pname)
    ENDIF
   ENDIF
   RETURN(pbuffer7)
 END ;Subroutine
 SUBROUTINE (writecodeextendedtype(pbuffer=vc,pname=vc,pcodevalue=f8) =vc)
   DECLARE meaning = vc WITH protect, noconstant(nullterm(""))
   DECLARE displaykey = vc WITH protect, noconstant(nullterm(""))
   DECLARE outboundalias = vc WITH protect, noconstant(nullterm(""))
   DECLARE outboundaliases = vc WITH protect, noconstant(nullterm(""))
   DECLARE pbuffer1 = vc WITH protect, noconstant("")
   DECLARE pbuffer2 = vc WITH protect, noconstant("")
   DECLARE pbuffer3 = vc WITH protect, noconstant("")
   DECLARE pbuffer4 = vc WITH protect, noconstant("")
   DECLARE pbuffer5 = vc WITH protect, noconstant("")
   DECLARE pbuffer6 = vc WITH protect, noconstant("")
   DECLARE pbuffer7 = vc WITH protect, noconstant(pbuffer)
   IF (pcodevalue > 0.0)
    IF (validate(gpreferences->currentbatchcontributorsources.contributorsourcecd,0.0) > 0.0)
     DECLARE bottom = i4 WITH private, noconstant(0)
     DECLARE top = i4 WITH private, noconstant(0)
     DECLARE middle = i4 WITH private, noconstant(0)
     DECLARE done = i2 WITH private, noconstant(false)
     DECLARE sindex = i4 WITH private, noconstant(0)
     DECLARE lindex = i4 WITH protect, noconstant(0)
     DECLARE aidx = i4 WITH private, noconstant(0)
     DECLARE acnt = i4 WITH private, noconstant(0)
     SET sindex = locateval(lindex,1,size(codevalueoutboundaliases->contributorsources,5),
      gpreferences->currentbatchcontributorsources.contributorsourcecd,codevalueoutboundaliases->
      contributorsources[lindex].contributorsourcecd)
     IF (sindex > 0)
      SET bottom = 1
      SET top = size(codevalueoutboundaliases->contributorsources[sindex].codevalues,5)
      IF (top > 0)
       WHILE (done=false
        AND bottom <= top)
        SET middle = ((top+ bottom)/ 2)
        IF ((pcodevalue < codevalueoutboundaliases->contributorsources[sindex].codevalues[middle].
        codevalue))
         SET top = (middle - 1)
        ELSEIF ((pcodevalue > codevalueoutboundaliases->contributorsources[sindex].codevalues[middle]
        .codevalue))
         SET bottom = (middle+ 1)
        ELSE
         SET acnt = size(codevalueoutboundaliases->contributorsources[sindex].codevalues[middle].
          aliases,5)
         IF (acnt > 0)
          FREE RECORD temprec
          RECORD temprec(
            1 xml = vc
          )
          SET temprec->xml = beginelement(temprec->xml,"outboundAliases")
          FOR (aidx = 1 TO acnt)
            IF (aidx=1)
             SET outboundalias = codevalueoutboundaliases->contributorsources[sindex].codevalues[
             middle].aliases[aidx].alias
            ENDIF
            SET temprec->xml = beginelementname(temprec->xml,"outboundAlias")
            SET temprec->xml = writeattribute(temprec->xml,"meaning",codevalueoutboundaliases->
             contributorsources[sindex].codevalues[middle].aliases[aidx].meaning)
            SET temprec->xml = writeattribute(temprec->xml,"alias",codevalueoutboundaliases->
             contributorsources[sindex].codevalues[middle].aliases[aidx].alias)
            SET temprec->xml = concat(temprec->xml,"/")
            SET temprec->xml = endelementname(temprec->xml)
          ENDFOR
          SET outboundaliases = endelement(temprec->xml,"outboundAliases")
          FREE RECORD temprec
         ENDIF
         SET done = true
        ENDIF
       ENDWHILE
      ENDIF
     ENDIF
    ENDIF
    SET meaning = uar_get_code_meaning(pcodevalue)
    SET displaykey = cnvtupper(cnvtalphanum(uar_get_code_display(pcodevalue)))
    IF (((size(trim(meaning,3)) > 0) OR (((size(trim(displaykey,3)) > 0) OR (size(trim(outboundalias,
      3)) > 0)) )) )
     SET pbuffer1 = beginelementname(pbuffer,pname)
     SET pbuffer2 = writeattribute(pbuffer1,"id",cnvtstring(pcodevalue,17))
     SET pbuffer3 = writeattribute(pbuffer2,"meaning",meaning)
     SET pbuffer4 = writeattribute(pbuffer3,"displayKey",displaykey)
     SET pbuffer5 = writeattribute(pbuffer4,"outboundAlias",outboundalias)
     SET pbuffer6 = endelementname(pbuffer5)
     SET pbuffer7 = endelement(concat(pbuffer6,outboundaliases),pname)
    ENDIF
   ENDIF
   RETURN(pbuffer7)
 END ;Subroutine
 CALL echo(build("Including PFT_XML_ACCESS_SUBS.INC, version [",nullterm("356730.006"),"]"))
 IF (validate(uar_xml_readfile,char(128))=char(128))
  DECLARE uar_xml_readfile(source=vc,filehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_closefile,char(128))=char(128))
  DECLARE uar_xml_closefile(filehandle=i4(ref)) = null
 ENDIF
 IF (validate(uar_xml_geterrormsg,char(128))=char(128))
  DECLARE uar_xml_geterrormsg(errorcode=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_listtree,char(128))=char(128))
  DECLARE uar_xml_listtree(filehandle=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_getroot,char(128))=char(128))
  DECLARE uar_xml_getroot(filehandle=i4(ref),nodehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_findchildnode,char(128))=char(128))
  DECLARE uar_xml_findchildnode(nodehandle=i4(ref),nodename=vc,childhandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getchildcount,char(128))=char(128))
  DECLARE uar_xml_getchildcount(nodehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getchildnode,char(128))=char(128))
  DECLARE uar_xml_getchildnode(nodehandle=i4(ref),nodeno=i4(ref),childnode=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getparentnode,char(128))=char(128))
  DECLARE uar_xml_getparentnode(nodehandle=i4(ref),parentnode=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getnodename,char(128))=char(128))
  DECLARE uar_xml_getnodename(nodehandle=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_getnodecontent,char(128))=char(128))
  DECLARE uar_xml_getnodecontent(nodehandle=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_getattrbyname,char(128))=char(128))
  DECLARE uar_xml_getattrbyname(nodehandle=i4(ref),attrname=vc,attributehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getattrbypos,char(128))=char(128))
  DECLARE uar_xml_getattrbypos(nodehandle=i4(ref),ndx=i4(ref),attributehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getattrname,char(128))=char(128))
  DECLARE uar_xml_getattrname(attributehandle=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_getattrvalue,char(128))=char(128))
  DECLARE uar_xml_getattrvalue(attributehandle=i4(ref)) = vc
 ENDIF
 IF (validate(uar_xml_getattributevalue,char(128))=char(128))
  DECLARE uar_xml_getattributevalue(nodehandle=i4(ref),attrname=vc) = vc
 ENDIF
 IF (validate(uar_xml_getattrcount,char(128))=char(128))
  DECLARE uar_xml_getattrcount(nodehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_parsestring,char(128))=char(128))
  DECLARE uar_xml_parsestring(xmlstring=vc,filehandle=i4(ref)) = i4
 ENDIF
 IF ( NOT (validate(sc_unkstat)))
  DECLARE sc_unkstat = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(sc_ok)))
  DECLARE sc_ok = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(sc_parserror)))
  DECLARE sc_parserror = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(sc_nofile)))
  DECLARE sc_nofile = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(sc_nonode)))
  DECLARE sc_nonode = i4 WITH protect, constant(4)
 ENDIF
 IF ( NOT (validate(sc_noattr)))
  DECLARE sc_noattr = i4 WITH protect, constant(5)
 ENDIF
 IF ( NOT (validate(sc_badobjref)))
  DECLARE sc_badobjref = i4 WITH protect, constant(6)
 ENDIF
 IF ( NOT (validate(sc_invindex)))
  DECLARE sc_invindex = i4 WITH protect, constant(7)
 ENDIF
 IF ( NOT (validate(sc_notfound)))
  DECLARE sc_notfound = i4 WITH protect, constant(8)
 ENDIF
 DECLARE __hpxmlroot = i4 WITH protect, noconstant(0)
 DECLARE __hpclaimdata = i4 WITH protect, noconstant(0)
 DECLARE __hpcharges = i4 WITH protect, noconstant(0)
 DECLARE __hpcharge = i4 WITH protect, noconstant(0)
 DECLARE __hppayers = i4 WITH protect, noconstant(0)
 DECLARE __hppayer = i4 WITH protect, noconstant(0)
 DECLARE __hpcontext = i4 WITH protect, noconstant(0)
 DECLARE __hppatient = i4 WITH protect, noconstant(0)
 DECLARE __hpencounter = i4 WITH protect, noconstant(0)
 DECLARE __hpitem = i4 WITH protect, noconstant(0)
 DECLARE __pchidx = i4 WITH protect, noconstant(0)
 DECLARE __posnumber = i4 WITH protect, noconstant(0)
 DECLARE __pchcnt = i4 WITH protect, noconstant(0)
 DECLARE __ptmpnode = i4 WITH protect, noconstant(0)
 IF (validate(parsexmlbuffer,char(128))=char(128))
  SUBROUTINE (parsexmlbuffer(pxmlbuffer=vc,prxmlfilehandle=i4(ref)) =i4)
    SET prxmlfilehandle = 0
    IF (uar_xml_parsestring(nullterm(pxmlbuffer),prxmlfilehandle) != sc_ok)
     RETURN(0)
    ENDIF
    SET __hpxmlroot = 0
    IF (uar_xml_getroot(prxmlfilehandle,__hpxmlroot) != sc_ok)
     RETURN(0)
    ENDIF
    RETURN(__hpxmlroot)
  END ;Subroutine
 ENDIF
 IF (validate(releasexmlresources,char(128))=char(128))
  SUBROUTINE (releasexmlresources(prxmlfilehandle=i4(ref)) =i2)
   CALL uar_xml_closefile(prxmlfilehandle)
   RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getclaimdatachargehandle,char(128))=char(128))
  SUBROUTINE (getclaimdatachargehandle(proothandle=i4,pchargeidx=i4) =i4)
    SET __hpclaimdata = 0
    IF (uar_xml_findchildnode(proothandle,"claimData",__hpclaimdata) != sc_ok)
     RETURN(0)
    ENDIF
    SET __hpcharges = 0
    IF (uar_xml_findchildnode(__hpclaimdata,"charges",__hpcharges) != sc_ok)
     RETURN(0)
    ENDIF
    SET __hpcharge = 0
    IF (uar_xml_getchildnode(__hpcharges,(pchargeidx - 1),__hpcharge) != sc_ok)
     RETURN(0)
    ENDIF
    RETURN(__hpcharge)
  END ;Subroutine
 ENDIF
 IF (validate(getclaimdatapayerhandle,char(128))=char(128))
  SUBROUTINE (getclaimdatapayerhandle(proothandle=i4,ppayeridx=i4) =i4)
    SET __hpclaimdata = 0
    IF (uar_xml_findchildnode(proothandle,"claimData",__hpclaimdata) != sc_ok)
     RETURN(0)
    ENDIF
    SET __hppayers = 0
    IF (uar_xml_findchildnode(__hpclaimdata,"payers",__hppayers) != sc_ok)
     RETURN(0)
    ENDIF
    SET __hppayer = 0
    IF (ppayeridx=0)
     IF (uar_xml_getchildnode(__hppayers,0,__hppayer) != sc_ok)
      RETURN(0)
     ENDIF
    ELSE
     IF (uar_xml_getchildnode(__hppayers,(ppayeridx - 1),__hppayer) != sc_ok)
      RETURN(0)
     ENDIF
    ENDIF
    RETURN(__hppayer)
  END ;Subroutine
 ENDIF
 IF (validate(getclaimdatacontexthandle,char(128))=char(128))
  SUBROUTINE (getclaimdatacontexthandle(proothandle=i4) =i4)
    SET __hpclaimdata = 0
    IF (uar_xml_findchildnode(proothandle,"claimData",__hpclaimdata) != sc_ok)
     RETURN(0)
    ENDIF
    SET __hpcontext = 0
    IF (uar_xml_findchildnode(__hpclaimdata,"context",__hpcontext) != sc_ok)
     RETURN(0)
    ENDIF
    RETURN(__hpcontext)
  END ;Subroutine
 ENDIF
 IF (validate(getclaimdataencounterhandle,char(128))=char(128))
  SUBROUTINE (getclaimdataencounterhandle(proothandle=i4) =i4)
    SET __hpclaimdata = 0
    IF (uar_xml_findchildnode(proothandle,"claimData",__hpclaimdata) != sc_ok)
     RETURN(0)
    ENDIF
    SET __hppatient = 0
    IF (uar_xml_findchildnode(__hpclaimdata,"patient",__hppatient) != sc_ok)
     RETURN(0)
    ENDIF
    SET __hpencounter = 0
    IF (uar_xml_findchildnode(__hppatient,"encounter",__hpencounter) != sc_ok)
     RETURN(0)
    ENDIF
    RETURN(__hpencounter)
  END ;Subroutine
 ENDIF
 IF (validate(getchildnodevalue,char(128))=char(128))
  SUBROUTINE (getchildnodevalue(pparenthandle=i4,pchildname=vc) =vc)
    IF (pparenthandle=0.0)
     RETURN(nullterm(""))
    ENDIF
    SET __hpitem = 0
    IF (uar_xml_findchildnode(pparenthandle,nullterm(pchildname),__hpitem) != sc_ok)
     RETURN(nullterm(""))
    ENDIF
    DECLARE __tmpstring = vc WITH protect, noconstant("")
    SET __tmpstring = nullterm(uar_xml_getnodecontent(__hpitem))
    SET __tmpstring = replace(__tmpstring,"&apos;",char(39),0)
    SET __tmpstring = replace(__tmpstring,"&quot;",char(34),0)
    SET __tmpstring = replace(__tmpstring,"&gt;",">",0)
    SET __tmpstring = replace(__tmpstring,"&lt;","<",0)
    SET __tmpstring = replace(__tmpstring,"&amp;","&",0)
    RETURN(nullterm(__tmpstring))
  END ;Subroutine
 ENDIF
 IF (validate(getattributevalue,char(128))=char(128))
  SUBROUTINE (getattributevalue(pelementhandle=i4,pattrname=vc) =vc)
    DECLARE __tmpstring = vc WITH protect, noconstant("")
    IF (pelementhandle != 0.0)
     SET __tmpstring = nullterm(uar_xml_getattributevalue(pelementhandle,nullterm(pattrname)))
     SET __tmpstring = replace(__tmpstring,"&apos;",char(39),0)
     SET __tmpstring = replace(__tmpstring,"&quot;",char(34),0)
     SET __tmpstring = replace(__tmpstring,"&gt;",">",0)
     SET __tmpstring = replace(__tmpstring,"&lt;","<",0)
     SET __tmpstring = replace(__tmpstring,"&amp;","&",0)
    ENDIF
    RETURN(nullterm(__tmpstring))
  END ;Subroutine
 ENDIF
 IF (validate(getchildnodeattributevalue,char(128))=char(128))
  SUBROUTINE (getchildnodeattributevalue(pparenthandle=i4,pchildname=vc,pattrname=vc) =vc)
    IF (pparenthandle=0.0)
     RETURN(nullterm(""))
    ENDIF
    SET __hpitem = 0
    IF (uar_xml_findchildnode(pparenthandle,nullterm(pchildname),__hpitem) != sc_ok)
     RETURN(nullterm(""))
    ENDIF
    DECLARE __tmpstring = vc WITH protect, noconstant("")
    SET __tmpstring = nullterm(uar_xml_getattributevalue(__hpitem,nullterm(pattrname)))
    SET __tmpstring = replace(__tmpstring,"&apos;",char(39),0)
    SET __tmpstring = replace(__tmpstring,"&quot;",char(34),0)
    SET __tmpstring = replace(__tmpstring,"&gt;",">",0)
    SET __tmpstring = replace(__tmpstring,"&lt;","<",0)
    SET __tmpstring = replace(__tmpstring,"&amp;","&",0)
    RETURN(nullterm(__tmpstring))
  END ;Subroutine
 ENDIF
 IF (validate(writexmlelement,char(128))=char(128))
  SUBROUTINE (writexmlelement(helement=i4) =vc)
    DECLARE childidx = i4 WITH private, noconstant(0)
    DECLARE childcnt = i4 WITH private, noconstant(uar_xml_getchildcount(helement))
    DECLARE attridx = i4 WITH private, noconstant(0)
    DECLARE attrcnt = i4 WITH private, noconstant(uar_xml_getattrcount(helement))
    DECLARE mycontent = vc WITH private, noconstant(nullterm(uar_xml_getnodecontent(helement)))
    DECLARE theelementstring = vc WITH private, noconstant(nullterm(concat(nullterm("<"),nullterm(
        uar_xml_getnodename(helement)))))
    DECLARE thechildelementstring = vc WITH private, noconstant(nullterm(""))
    IF (attrcnt=0
     AND childcnt=0
     AND mycontent="")
     RETURN(nullterm(concat(theelementstring,"/>")))
    ENDIF
    FOR (attridx = 1 TO attrcnt)
      DECLARE hattr = i4 WITH private, noconstant(0)
      CALL uar_xml_getattrbypos(helement,(attridx - 1),hattr)
      DECLARE attrname = vc WITH private, noconstant(nullterm(uar_xml_getattrname(hattr)))
      DECLARE attrvalue = vc WITH private, noconstant(nullterm(uar_xml_getattrvalue(hattr)))
      SET theelementstring = concat(theelementstring," ",attrname,'="',attrvalue,
       '"')
    ENDFOR
    IF (childcnt=0
     AND mycontent="")
     RETURN(concat(theelementstring,"/>"))
    ELSEIF (childcnt=0)
     RETURN(nullterm(concat(theelementstring,">",mycontent,"</",nullterm(uar_xml_getnodename(helement
         )),
       ">")))
    ENDIF
    SET theelementstring = concat(theelementstring,">",mycontent)
    FOR (childidx = 1 TO childcnt)
      DECLARE hchildnode = i4 WITH private, noconstant(0)
      CALL uar_xml_getchildnode(helement,(childidx - 1),hchildnode)
      SET thechildelementstring = writexmlelement(hchildnode)
      SET theelementstring = concat(theelementstring,thechildelementstring)
    ENDFOR
    RETURN(nullterm(concat(theelementstring,"</",nullterm(uar_xml_getnodename(helement)),">")))
  END ;Subroutine
 ENDIF
 IF (validate(getchildelementoccurrencehandle,char(128))=char(128))
  SUBROUTINE (getchildelementoccurrencehandle(pelementhandle=i4,pchildname=vc,poccurrenceindex=i4) =
   i4)
   IF (pelementhandle != 0.0)
    SET __pchidx = 0
    SET __posnumber = 0
    SET __pchcnt = uar_xml_getchildcount(pelementhandle)
    FOR (__pchidx = 1 TO __pchcnt)
      SET __ptmpnode = 0
      IF (uar_xml_getchildnode(pelementhandle,(__pchidx - 1),__ptmpnode) != sc_ok)
       RETURN(0)
      ENDIF
      IF (uar_xml_getnodename(__ptmpnode)=pchildname)
       SET __posnumber += 1
       IF (__posnumber=poccurrenceindex)
        RETURN(__ptmpnode)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
  END ;Subroutine
 ENDIF
 IF (validate(getelementvalue,char(128))=char(128))
  SUBROUTINE (getelementvalue(pelementhandle=i4) =vc)
    DECLARE __tmpstring = vc WITH protect, noconstant("")
    IF (pelementhandle != 0.0)
     SET __tmpstring = nullterm(uar_xml_getnodecontent(pelementhandle))
     SET __tmpstring = replace(__tmpstring,"&apos;",char(39),0)
     SET __tmpstring = replace(__tmpstring,"&quot;",char(34),0)
     SET __tmpstring = replace(__tmpstring,"&gt;",">",0)
     SET __tmpstring = replace(__tmpstring,"&lt;","<",0)
     SET __tmpstring = replace(__tmpstring,"&amp;","&",0)
    ENDIF
    RETURN(nullterm(__tmpstring))
  END ;Subroutine
 ENDIF
 IF (validate(getxpathvalue,char(128))=char(128))
  SUBROUTINE (getxpathvalue(hxmlcontext=i4,xpathexpr=vc) =vc)
    DECLARE expr = vc WITH protect, noconstant(trim(xpathexpr))
    DECLARE exprlen = i4 WITH protect, noconstant(size(expr))
    DECLARE hxmlparent = i4 WITH protect, noconstant(hxmlcontext)
    IF (substring(1,1,expr) != "/")
     SET expr = concat("/",expr)
     SET exprlen += 1
    ENDIF
    DECLARE firstslashpos = i4 WITH protect, noconstant(1)
    DECLARE secondslashpos = i4 WITH protect, noconstant(findstring("/",expr,2))
    DECLARE betweenslashes = vc WITH protect, noconstant("")
    DECLARE openbracketpos = i4 WITH protect, noconstant(0)
    DECLARE closebracketpos = i4 WITH protect, noconstant(0)
    DECLARE betweenbrackets = vc WITH protect, noconstant("")
    WHILE (secondslashpos != 0)
      SET betweenslashes = substring((firstslashpos+ 1),((secondslashpos - firstslashpos) - 1),expr)
      SET openbracketpos = findstring("[",betweenslashes)
      IF (openbracketpos > 0)
       SET closebracketpos = findstring("]",betweenslashes)
       SET betweenbrackets = substring((openbracketpos+ 1),((closebracketpos - openbracketpos) - 1),
        betweenslashes)
       SET betweenslashes = substring(1,(openbracketpos - 1),betweenslashes)
       IF (closebracketpos=0)
        CALL logmsg("getXPathValue",concat("Expected ']' for element '",betweenslashes,"'"),log_error
         )
        RETURN("")
       ELSEIF (((betweenbrackets="") OR ( NOT (isnumeric(betweenbrackets)))) )
        CALL logmsg("getXPathValue",concat("Expected ( [0-9]+ ) between bracket for element '",
          betweenslashes,"'"),log_error)
        RETURN("")
       ENDIF
       SET hxmlparent = getchildelementoccurrencehandle(hxmlparent,trim(betweenslashes),cnvtint(
         betweenbrackets))
      ELSE
       SET hxmlparent = getchildelementoccurrencehandle(hxmlparent,trim(betweenslashes),1)
      ENDIF
      SET expr = substring(secondslashpos,exprlen,expr)
      SET exprlen = size(expr)
      SET firstslashpos = 1
      SET secondslashpos = findstring("/",expr,(firstslashpos+ 1))
    ENDWHILE
    SET expr = substring(2,exprlen,expr)
    SET exprlen -= 1
    IF (substring(1,1,expr)="@")
     SET expr = substring(2,exprlen,expr)
     SET exprlen -= 1
     RETURN(getattributevalue(hxmlparent,trim(expr)))
    ENDIF
    RETURN(getchildnodevalue(hxmlparent,trim(expr)))
  END ;Subroutine
 ENDIF
 IF (validate(getmedianodename,char(128))=char(128))
  SUBROUTINE (getmedianodename(dcorspactivityid=f8,smedianodename=vc(ref)) =i2)
    CASE (uar_get_code_meaning(dmediasubtypecd))
     OF "UB04":
      SET smedianodename = "UB04"
      RETURN(true)
     OF "837I_4010":
      SET smedianodename = "WPC837Q3"
      RETURN(true)
     OF "837I_5010":
      SET smedianodename = "WPC837I5010"
      RETURN(true)
     OF "837R_5010":
      SET smedianodename = "WPC837R5010"
      RETURN(true)
     OF "CMS1500_0805":
      SET smedianodename = "CMS1500_0805"
      RETURN(true)
     OF "CMS1500_0212":
      SET smedianodename = "CMS1500_0212"
      RETURN(true)
     OF "837P_4010":
      SET smedianodename = "WPC837Q1"
      RETURN(true)
     OF "837P_5010":
      SET smedianodename = "WPC837P5010"
      RETURN(true)
     OF "WEB SERVICES":
      SET smedianodename = "claim"
      RETURN(true)
     ELSE
      RETURN(false)
    ENDCASE
  END ;Subroutine
 ENDIF
 IF (validate(getmediaxmlhandle,char(128))=char(128))
  SUBROUTINE (getmediaxmlhandle(dcorspactivityid=f8,dmediasubtypecd=f8,hxmlfile=i4(ref),hxmlroot=i4(
    ref),hxmlmedia=i4(ref)) =i2)
    DECLARE _tmpstr = vc WITH protect, noconstant("")
    SET _tmpstr = nullterm(build("Processing claim [",cnvtint(dcorspactivityid),"]"))
    CALL logmsg("getMediaXMLHandle",_tmpstr,log_debug)
    DECLARE _medianodename = vc WITH protect, noconstant("")
    IF ( NOT (getmedianodename(dmediasubtypecd,_medianodename)))
     CALL logmsg("getMediaXMLHandle","The specified media subtype is not currently supported",
      log_error)
     RETURN(false)
    ENDIF
    SET _medianodename = nullterm(_medianodename)
    DECLARE _mediaxml = gvc WITH protect, noconstant("")
    IF ( NOT (getclaimastargetmedia(dcorspactivityid,dmediasubtypecd,_mediaxml)))
     CALL logmsg("getMediaXMLHandle","Error retrieving claim as target media XML string",log_error)
     RETURN(false)
    ENDIF
    IF (uar_xml_parsestring(nullterm(_mediaxml),hxmlfile) != sc_ok)
     CALL logmsg("getMediaXMLHandle","Error parsing XML string",log_error)
     RETURN(false)
    ENDIF
    IF (uar_xml_getroot(hxmlfile,hxmlroot) != sc_ok)
     CALL logmsg("getMediaXMLHandle","Error retrieving handle to root node",log_error)
     RETURN(false)
    ENDIF
    IF (uar_xml_findchildnode(hxmlroot,nullterm(_medianodename),hxmlmedia) != sc_ok)
     CALL logmsg("getMediaXMLHandle",build2("Error retrieving handle to ",_medianodename," node"),
      log_error)
     RETURN(false)
    ENDIF
    IF (nullterm(uar_xml_getnodename(hxmlmedia)) != _medianodename)
     CALL logmsg("getMediaXMLHandle",build2("The media node name should be ",_medianodename,
       " but is instead ",nullterm(uar_xml_getnodename(hxmlmedia))),log_error)
     RETURN(false)
    ENDIF
    CALL echo("Executed getMediaXMLHandle")
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getclaimastargetmedia,char(128))=char(128))
  SUBROUTINE (getclaimastargetmedia(dcorspactivityid=f8,dmediasubtypecd=f8,smediaxml=gvc(ref)) =i2)
    DECLARE _tmpstr = vc WITH protect, noconstant("")
    SET _tmpstr = nullterm(build("Processing claim [",cnvtint(dcorspactivityid),"]"))
    CALL logmsg("getClaimAsTargetMedia",_tmpstr,log_debug)
    DECLARE _targetsubtypestr = vc WITH protect, noconstant("")
    DECLARE _medianodename = vc WITH protect, noconstant("")
    IF ( NOT (getmedianodename(dmediasubtypecd,_medianodename)))
     CALL logmsg("getClaimAsTargetMedia","The specified media subtype is not currently supported",
      log_error)
     RETURN(false)
    ENDIF
    SET _targetsubtypestr = nullterm(concat("<",_medianodename,">"))
    FREE RECORD longblobrequest
    RECORD longblobrequest(
      1 objarray[*]
        2 longblobid = f8
    )
    FREE RECORD longblobreply
    RECORD longblobreply(
      1 objarray[*]
        2 longblobid = f8
        2 xml = gvc
      1 pft_status_data
        2 subeventstatus[1]
          3 programname = vc
          3 subroutinename = vc
          3 message = vc
        2 pft_stats[*]
          3 programname = vc
          3 executioncnt = i4
          3 executiontime = f8
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET stat = alterlist(longblobrequest->objarray,1)
    SELECT INTO "nl:"
     FROM br_long_blob_reltn brlb
     PLAN (brlb
      WHERE brlb.corsp_activity_id=dcorspactivityid
       AND brlb.data_type_flag=media_xml_flag
       AND brlb.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND brlb.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND brlb.active_ind=true)
     DETAIL
      longblobrequest->objarray[1].longblobid = brlb.long_blob_id
     WITH nocounter
    ;end select
    EXECUTE pft_clm_get_longblob_xml  WITH replace("REQUEST",longblobrequest), replace("REPLY",
     longblobreply)
    CALL echo("Retrieved media xml long blob")
    IF ((longblobreply->status_data.status != "S"))
     CALL logmsg("getClaimAsTargetMedia","Error retrieving media XML string",log_error)
     RETURN(false)
    ENDIF
    DECLARE subtypepos = i4 WITH protect, noconstant(0)
    DECLARE subtypelen = i4 WITH protect, noconstant(0)
    DECLARE subtypestr = vc WITH protect, noconstant("")
    SET subtypepos = (findstring(">",longblobreply->objarray[1].xml,1,0)+ 1)
    SET subtypepos = findstring("<",longblobreply->objarray[1].xml,subtypepos,0)
    SET subtypelen = ((findstring(">",longblobreply->objarray[1].xml,subtypepos,0) - subtypepos)+ 1)
    SET subtypestr = cnvtupper(nullterm(substring(subtypepos,subtypelen,longblobreply->objarray[1].
       xml)))
    SET _tmpstr = nullterm(build("XML Peek [",subtypestr,"]"))
    CALL logmsg("getClaimAsTargetMedia",_tmpstr,log_debug)
    IF (subtypestr=_targetsubtypestr)
     SET smediaxml = longblobreply->objarray[1].xml
     RETURN(true)
    ENDIF
    CALL echo(build2("Claim is ",subtypestr," - Transforming claimData to ",_targetsubtypestr))
    SET stat = alterlist(longblobrequest->objarray,1)
    SELECT INTO "nl:"
     FROM br_long_blob_reltn brlb
     PLAN (brlb
      WHERE brlb.corsp_activity_id=dcorspactivityid
       AND brlb.data_type_flag=claim_data_xml_flag
       AND brlb.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND brlb.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND brlb.active_ind=true)
     DETAIL
      longblobrequest->objarray[1].longblobid = brlb.long_blob_id
     WITH nocounter
    ;end select
    EXECUTE pft_clm_get_longblob_xml  WITH replace("REQUEST",longblobrequest), replace("REPLY",
     longblobreply)
    CALL echo("Retrieved claimdata long blob")
    IF ((longblobreply->status_data.status != "S"))
     FREE RECORD longblobreply
     CALL logmsg("getClaimAsTargetMedia","Error retrieving ClaimData XML string",log_error)
     RETURN(false)
    ENDIF
    RECORD runxsltrequest(
      1 xml
        2 xml = gvc
        2 resources[*]
          3 resourcename = vc
          3 xml = gvc
      1 xsl
        2 stylesheetname = vc
        2 xsl = gvc
        2 resources[*]
          3 resourcename = vc
          3 xml = gvc
    ) WITH protect
    RECORD runxsltreply(
      1 xml = gvc
      1 pft_status_data
        2 subeventstatus[1]
          3 programname = vc
          3 subroutinename = vc
          3 message = vc
        2 pft_stats[*]
          3 programname = vc
          3 executioncnt = i4
          3 executiontime = f8
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SET runxsltrequest->xml.xml = longblobreply->objarray[1].xml
    CASE (_targetsubtypestr)
     OF "<WPC837Q3>":
      SET runxsltrequest->xsl.stylesheetname = "ClaimDataTo837i4010.xslt"
      SET stat = alterlist(runxsltrequest->xsl.resources,5)
      SET runxsltrequest->xsl.resources[1].resourcename = "GlobalTemplates.xslt"
      SET runxsltrequest->xsl.resources[2].resourcename =
      "ClaimDataTo837i4010_StandardPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[3].resourcename =
      "ClaimDataTo837i4010_DefaultPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[4].resourcename =
      "ClaimDataTo837i4010_CustomPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[5].resourcename =
      "ClaimDataTo837i4010_StandardFormattingTemplates.xslt"
     OF "<UB04>":
      SET runxsltrequest->xsl.stylesheetname = "ClaimDataToUB04.xslt"
      SET stat = alterlist(runxsltrequest->xsl.resources,5)
      SET runxsltrequest->xsl.resources[1].resourcename = "GlobalTemplates.xslt"
      SET runxsltrequest->xsl.resources[2].resourcename =
      "ClaimDataToUB04_StandardPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[3].resourcename =
      "ClaimDataToUB04_DefaultPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[4].resourcename =
      "ClaimDataToUB04_CustomPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[5].resourcename =
      "ClaimDataToUB04_StandardFormattingTemplates.xslt"
     OF "<WPC837I5010>":
      SET runxsltrequest->xsl.stylesheetname = "ClaimDataTo837i5010.xslt"
      SET stat = alterlist(runxsltrequest->xsl.resources,5)
      SET runxsltrequest->xsl.resources[1].resourcename = "GlobalTemplates.xslt"
      SET runxsltrequest->xsl.resources[2].resourcename = "GlobalTemplates5010.xslt"
      SET runxsltrequest->xsl.resources[3].resourcename =
      "ClaimDataTo837i5010_StandardPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[4].resourcename =
      "ClaimDataTo837i5010_DefaultPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[5].resourcename =
      "ClaimDataTo837i5010_CustomPopulationTemplates.xslt"
     OF "<WPC837R5010>":
      SET runxsltrequest->xsl.stylesheetname = "ClaimDataTo837r5010_Reporting.xslt"
      SET stat = alterlist(runxsltrequest->xsl.resources,5)
      SET runxsltrequest->xsl.resources[1].resourcename = "GlobalTemplates.xslt"
      SET runxsltrequest->xsl.resources[2].resourcename =
      "ClaimDataTo837r5010_Reporting_StandardPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[3].resourcename =
      "ClaimDataTo837r5010_Reporting_DefaultPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[4].resourcename =
      "ClaimDataTo837r5010_Reporting_CustomPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[5].resourcename =
      "ClaimDataTo837r5010_Reporting_StandardFormattingTemplates.xslt"
     OF "<CMS1500_0805>":
      SET runxsltrequest->xsl.stylesheetname = "ClaimDataToCMS1500_0805.xslt"
      SET stat = alterlist(runxsltrequest->xsl.resources,5)
      SET runxsltrequest->xsl.resources[1].resourcename = "GlobalTemplates.xslt"
      SET runxsltrequest->xsl.resources[2].resourcename =
      "ClaimDataToCMS1500_0805_StandardPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[3].resourcename =
      "ClaimDataToCMS1500_0805_DefaultPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[4].resourcename =
      "ClaimDataToCMS1500_0805_CustomPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[5].resourcename =
      "ClaimDataToCMS1500_0805_StandardFormattingTemplates.xslt"
     OF "<CMS1500_0212>":
      SET runxsltrequest->xsl.stylesheetname = "ClaimDataToCMS1500_0212.xslt"
      SET stat = alterlist(runxsltrequest->xsl.resources,5)
      SET runxsltrequest->xsl.resources[1].resourcename = "GlobalTemplates.xslt"
      SET runxsltrequest->xsl.resources[2].resourcename =
      "ClaimDataToCMS1500_0212_StandardPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[3].resourcename =
      "ClaimDataToCMS1500_0212_DefaultPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[4].resourcename =
      "ClaimDataToCMS1500_0212_CustomPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[5].resourcename =
      "ClaimDataToCMS1500_0212_StandardFormattingTemplates.xslt"
     OF "<WPC837Q1>":
      SET runxsltrequest->xsl.stylesheetname = "ClaimDataTo837p4010.xslt"
      SET stat = alterlist(runxsltrequest->xsl.resources,5)
      SET runxsltrequest->xsl.resources[1].resourcename = "GlobalTemplates.xslt"
      SET runxsltrequest->xsl.resources[2].resourcename =
      "ClaimDataTo837p4010_StandardPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[3].resourcename =
      "ClaimDataTo837p4010_DefaultPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[4].resourcename =
      "ClaimDataTo837p4010_CustomPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[5].resourcename =
      "ClaimDataTo837p4010_StandardFormattingTemplates.xslt"
     OF "<WPC837P5010>":
      SET runxsltrequest->xsl.stylesheetname = "ClaimDataTo837p5010.xslt"
      SET stat = alterlist(runxsltrequest->xsl.resources,5)
      SET runxsltrequest->xsl.resources[1].resourcename = "GlobalTemplates.xslt"
      SET runxsltrequest->xsl.resources[2].resourcename = "GlobalTemplates5010.xslt"
      SET runxsltrequest->xsl.resources[3].resourcename =
      "ClaimDataTo837p5010_StandardPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[4].resourcename =
      "ClaimDataTo837p5010_DefaultPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[5].resourcename =
      "ClaimDataTo837p5010_CustomPopulationTemplates.xslt"
     OF "<claim>":
      SET runxsltrequest->xsl.stylesheetname = "WebServices.xslt"
      SET stat = alterlist(runxsltrequest->xsl.resources,4)
      SET runxsltrequest->xsl.resources[1].resourcename = "GlobalTemplates.xslt"
      SET runxsltrequest->xsl.resources[2].resourcename =
      "WebServices_StandardPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[3].resourcename =
      "WebServices_DefaultPopulationTemplates.xslt"
      SET runxsltrequest->xsl.resources[4].resourcename =
      "WebServices_CustomPopulationTemplates.xslt"
    ENDCASE
    EXECUTE pft_clm_run_xslt  WITH replace("REQUEST",runxsltrequest), replace("REPLY",runxsltreply)
    IF ((runxsltreply->status_data.status != "S"))
     FREE RECORD runxsltrequest
     FREE RECORD runxsltreply
     CALL logmsg("getClaimAsTargetMedia","Error performing media transformation",log_error)
     RETURN(false)
    ENDIF
    CALL echo("Transformation completed")
    SET longblobreply->objarray[1].longblobid = 0.0
    SET smediaxml = runxsltreply->xml
    CALL echo("Executed getClaimAsTargetMedia")
    RETURN(true)
  END ;Subroutine
 ENDIF
 CALL echo(build("Begin PFT_CLM_COMMON_SUBS.INC, version [",nullterm("RCBCLM-23004.017"),"]"))
 RECORD ecicodes(
   1 codes[*]
     2 ecirange = vc
     2 cdfmeaning = vc
     2 extension[*]
       3 fieldname = vc
       3 fieldvalue = vc
 ) WITH protect
 RECORD icdsourcevocab(
   1 icdgrouping[*]
     2 groupname = vc
     2 codes[*]
       3 vocabcd = f8
 ) WITH protect
 RECORD skipclaimdetails(
   1 claims[*]
     2 corspactivityid = f8
     2 skipinternalvalidation = i2
     2 skipexternalvalidation = i2
     2 skipmanualreview = i2
     2 claimdatalitexml = gvc
 ) WITH protect
 RECORD claimdetails(
   1 claims[*]
     2 corspactivityid = f8
 ) WITH protect
 IF ( NOT (validate(eci_cs)))
  DECLARE eci_cs = i4 WITH protect, constant(4060001)
 ENDIF
 IF ( NOT (validate(src_vocab_cs)))
  DECLARE src_vocab_cs = i4 WITH protect, constant(400)
 ENDIF
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 IF ( NOT (validate(null_f8)))
  DECLARE null_f8 = f8 WITH protect, constant(- (0.00001))
 ENDIF
 IF ( NOT (validate(null_i2)))
  DECLARE null_i2 = i2 WITH protect, constant(- (1))
 ENDIF
 IF ( NOT (validate(null_i4)))
  DECLARE null_i4 = i4 WITH protect, constant(- (1))
 ENDIF
 IF ( NOT (validate(null_dt)))
  DECLARE null_dt = q8 WITH protect, constant(0.0)
 ENDIF
 IF ( NOT (validate(null_vc)))
  DECLARE null_vc = vc WITH protect, constant("")
 ENDIF
 IF ( NOT (validate(upt_force)))
  DECLARE upt_force = i4 WITH protect, constant(- (99999))
 ENDIF
 IF ( NOT (validate(xml_encoding)))
  DECLARE xml_encoding = vc WITH protect, constant("UTF-8")
 ENDIF
 IF ( NOT (validate(claim_data_xml_flag)))
  DECLARE claim_data_xml_flag = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(media_xml_flag)))
  DECLARE media_xml_flag = i2 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(manual_edits_xml_flag)))
  DECLARE manual_edits_xml_flag = i2 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(claim_data_lite_xml_flag)))
  DECLARE claim_data_lite_xml_flag = i2 WITH protect, constant(4)
 ENDIF
 IF ( NOT (validate(validation_xml_flag)))
  DECLARE validation_xml_flag = i2 WITH protect, constant(6)
 ENDIF
 IF ( NOT (validate(not_interim)))
  DECLARE not_interim = i2 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(initial_interim)))
  DECLARE initial_interim = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(continuing_interim)))
  DECLARE continuing_interim = i2 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(final_interim)))
  DECLARE final_interim = i2 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(begin_of_code_range)))
  DECLARE begin_of_code_range = vc WITH protect, constant("BEGIN_OF_CODE_RANGE")
 ENDIF
 IF ( NOT (validate(end_of_code_range)))
  DECLARE end_of_code_range = vc WITH protect, constant("END_OF_CODE_RANGE")
 ENDIF
 IF ( NOT (validate(icd_grouper)))
  DECLARE icd_grouper = vc WITH protect, constant("ICD_GROUPER")
 ENDIF
 IF (validate(getcodevalue,char(128))=char(128))
  SUBROUTINE (getcodevalue(pcodeset=i4,pmeaning=vc,poptionflag=i2) =f8)
    DECLARE lcodevalue = f8 WITH private, noconstant(0.0)
    SET lcodevalue = uar_get_code_by("MEANING",value(pcodeset),value(pmeaning))
    IF (lcodevalue > 0.0)
     RETURN(lcodevalue)
    ELSE
     IF (poptionflag=1)
      CALL logmsg("getCodeValue",build("Error : Code Set [",pcodeset,"] : Meaning [",pmeaning,"]"),
       log_error)
      CALL setstatusdata(curprog,"getCodeValue",build("Error : Code Set [",pcodeset,"] : Meaning [",
        pmeaning,"]"))
      GO TO exit_script
     ELSE
      RETURN(0.0)
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(getcodevaluebydisplaykey,char(128))=char(128))
  SUBROUTINE (getcodevaluebydisplaykey(pcodeset=i4,pdisplaykey=vc,poptionflag=i2) =f8)
    DECLARE lcodevalue = f8 WITH private, noconstant(0.0)
    SET lcodevalue = uar_get_code_by("DISPLAYKEY",value(pcodeset),value(pdisplaykey))
    IF (lcodevalue > 0.0)
     RETURN(lcodevalue)
    ELSE
     IF (poptionflag=1)
      CALL logmsg("getCodeValueByDisplayKey",build("Error : Code Set [",pcodeset,"] : DisplayKey [",
        pdisplaykey,"]"),log_error)
      CALL setstatusdata(curprog,"getCodeValueByDisplayKey",build("Error : Code Set [",pcodeset,
        "] : DisplayKey [",pdisplaykey,"]"))
      GO TO exit_script
     ELSEIF (poptionflag=2)
      CALL logmsg("getCodeValueByDisplayKey",build("Warning : Code Set [",pcodeset,"] : DisplayKey [",
        pdisplaykey,"]"),log_warning)
      RETURN(0.0)
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(logmsg,char(128))=char(128))
  SUBROUTINE (logmsg(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE llevel = vc WITH private, noconstant("")
    DECLARE __hpsys = i4 WITH private, noconstant(0)
    DECLARE __lpsysstat = i4 WITH private, noconstant(0)
    CASE (plevel)
     OF log_error:
      SET llevel = "ERROR"
     OF log_warning:
      SET llevel = "WARNING"
     OF log_audit:
      SET llevel = "AUDIT"
     OF log_info:
      SET llevel = "INFO"
     ELSE
      SET llevel = "DEBUG"
    ENDCASE
    IF (size(trim(psubroutine)) > 0)
     CALL echo(concat(llevel," : ",curprog," : ",psubroutine,
       "() : ",pmessage))
    ELSE
     CALL echo(concat(llevel," : ",curprog," : ",pmessage))
    ENDIF
    SET __hpsys = 0
    SET __lpsysstat = 0
    CALL uar_syscreatehandle(__hpsys,__lpsysstat)
    IF (__hpsys > 0)
     CALL uar_sysevent(__hpsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__hpsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET stat = uar_srvsetstring(hobjarray,"timer_ident",nullterm(psubroutine))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setstatusdata,char(128))=char(128))
  SUBROUTINE (setstatusdata(pprogramname=vc(val),psubroutinename=vc(val),pmessage=vc(val)) =null)
    IF (validate(reply->pft_status_data.subeventstatus[1].programname))
     SET reply->pft_status_data.subeventstatus[1].programname = nullterm(pprogramname)
    ENDIF
    IF (validate(reply->pft_status_data.subeventstatus[1].subroutinename))
     SET reply->pft_status_data.subeventstatus[1].subroutinename = nullterm(psubroutinename)
    ENDIF
    IF (validate(reply->pft_status_data.subeventstatus[1].message))
     SET reply->pft_status_data.subeventstatus[1].message = nullterm(pmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addpftstats,char(128))=char(128))
  SUBROUTINE (addpftstats(pprogramname=vc(val),pstarttime=q8(val)) =null)
    DECLARE sindex = i4 WITH private, noconstant(0)
    DECLARE lindex = i4 WITH protect, noconstant(0)
    DECLARE statcnt = i4 WITH protect, noconstant(size(reply->pft_status_data.pft_stats,5))
    SET sindex = locateval(lindex,1,statcnt,pprogramname,reply->pft_status_data.pft_stats[lindex].
     programname)
    IF (sindex=0)
     SET statcnt += 1
     SET stat = alterlist(reply->pft_status_data.pft_stats,statcnt)
     SET reply->pft_status_data.pft_stats[statcnt].programname = pprogramname
     SET reply->pft_status_data.pft_stats[statcnt].executioncnt = 1
     SET reply->pft_status_data.pft_stats[statcnt].executiontime = datetimediff(cnvtdatetime(sysdate),
      pstarttime,5)
    ELSE
     SET reply->pft_status_data.pft_stats[sindex].executioncnt += 1
     SET reply->pft_status_data.pft_stats[sindex].executiontime += datetimediff(cnvtdatetime(sysdate),
      pstarttime,5)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addpftstats2,char(128))=char(128))
  SUBROUTINE (addpftstats2(pprogramname=vc(val),pstarttime=q8(val),pmessage=vc(val)) =null)
    DECLARE sindex = i4 WITH private, noconstant(0)
    DECLARE lindex = i4 WITH protect, noconstant(0)
    DECLARE statcnt = i4 WITH protect, noconstant(size(reply->pft_status_data.pft_stats,5))
    SET statcnt += 1
    SET stat = alterlist(reply->pft_status_data.pft_stats,statcnt)
    SET reply->pft_status_data.pft_stats[statcnt].programname = nullterm(pprogramname)
    SET reply->pft_status_data.pft_stats[statcnt].executioncnt = 1
    SET reply->pft_status_data.pft_stats[statcnt].executiontime = datetimediff(cnvtdatetime(sysdate),
     pstarttime,5)
    SET reply->pft_status_data.pft_stats[statcnt].message = nullterm(pmessage)
  END ;Subroutine
 ENDIF
 IF (validate(getmediatypecd,char(128))=char(128))
  SUBROUTINE (getmediatypecd(pmediasubtypecd=f8) =f8)
    DECLARE retval = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM code_value_group cg,
      code_value cv
     PLAN (cg
      WHERE cg.child_code_value=pmediasubtypecd)
      JOIN (cv
      WHERE cv.code_value=cg.parent_code_value
       AND cv.code_set=21752)
     DETAIL
      retval = cg.parent_code_value
     WITH nocounter
    ;end select
    RETURN(retval)
  END ;Subroutine
 ENDIF
 IF (validate(getbilltypecd,char(128))=char(128))
  SUBROUTINE (getbilltypecd(pmediasubtypecd=f8) =f8)
    DECLARE retval = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM code_value_group cvg,
      code_value cv
     PLAN (cvg
      WHERE cvg.child_code_value=pmediasubtypecd)
      JOIN (cv
      WHERE cv.code_value=cvg.parent_code_value
       AND cv.code_set=21749)
     DETAIL
      retval = cvg.parent_code_value
     WITH nocounter
    ;end select
    RETURN(retval)
  END ;Subroutine
 ENDIF
 IF (validate(isequal,char(128))=char(128))
  SUBROUTINE isequal(damt1,damt2)
   DECLARE tmpdiff = f8 WITH private, noconstant(abs((abs(damt1) - abs(damt2))))
   IF (tmpdiff < 0.009)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(isnewclaimarchitecturemediasubtype,char(128))=char(128))
  SUBROUTINE (isnewclaimarchitecturemediasubtype(pmediasubtypecd=f8) =i2)
    DECLARE mediasubtypecdfmeaning = vc WITH private, noconstant(uar_get_code_meaning(pmediasubtypecd
      ))
    IF (mediasubtypecdfmeaning IN ("UB04", "CMS1500_0805", "837I_4010", "837P_4010", "837I_5010",
    "837P_5010", "WEB SERVICES", "CMS1500_0212"))
     RETURN(true)
    ENDIF
    RETURN(false)
  END ;Subroutine
 ENDIF
 IF (validate(findecicodes,char(128))=char(128))
  SUBROUTINE (findecicodes(sourceidentifier=vc,icdversion=vc) =i2)
    CALL logmsg("findECICodes","ENTERING...",log_debug)
    DECLARE ecodeidx = i4 WITH protect, noconstant(0)
    DECLARE ecodeextidx = i4 WITH protect, noconstant(0)
    DECLARE icdversionind = i2 WITH protect, noconstant(false)
    DECLARE startrangeind = i2 WITH protect, noconstant(false)
    DECLARE endrangeind = i2 WITH protect, noconstant(false)
    FOR (ecodeidx = 1 TO size(ecicodes->codes,5))
      IF ( NOT (startrangeind
       AND endrangeind
       AND icdversionind))
       SET startrangeind = false
       SET endrangeind = false
       SET icdversionind = false
       FOR (ecodeextidx = 1 TO size(ecicodes->codes[ecodeidx].extension,5))
         IF ((ecicodes->codes[ecodeidx].extension[ecodeextidx].fieldname=begin_of_code_range)
          AND compareecicodes(ecicodes->codes[ecodeidx].extension[ecodeextidx].fieldvalue,
          sourceidentifier))
          SET startrangeind = true
         ELSEIF ((ecicodes->codes[ecodeidx].extension[ecodeextidx].fieldname=end_of_code_range)
          AND compareecicodes(sourceidentifier,ecicodes->codes[ecodeidx].extension[ecodeextidx].
          fieldvalue))
          SET endrangeind = true
         ELSEIF ((ecicodes->codes[ecodeidx].extension[ecodeextidx].fieldname=icd_grouper)
          AND (ecicodes->codes[ecodeidx].extension[ecodeextidx].fieldvalue=icdversion))
          SET icdversionind = true
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
    IF ( NOT (startrangeind
     AND endrangeind
     AND icdversionind))
     CALL logmsg("findECICodes","EXITING... eCode missing extensions",log_debug)
     RETURN(false)
    ENDIF
    CALL logmsg("findECICodes","EXITING...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(loadecicodes,char(128))=char(128))
  DECLARE loadecicodes(null) = i2
  SUBROUTINE loadecicodes(null)
    CALL logmsg("loadECICodes","ENTERING...",log_debug)
    DECLARE ecicnt = i4 WITH protect, noconstant(0)
    DECLARE ecodeextidx = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM code_value c,
      code_value_extension cve
     PLAN (c
      WHERE c.code_set=eci_cs
       AND c.active_ind=1
       AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND c.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (cve
      WHERE cve.code_value=c.code_value
       AND cve.code_set=c.code_set)
     ORDER BY c.cdf_meaning
     HEAD c.cdf_meaning
      ecicnt += 1, stat = alterlist(ecicodes->codes,ecicnt), ecicodes->codes[ecicnt].ecirange = c
      .display,
      ecicodes->codes[ecicnt].cdfmeaning = c.cdf_meaning, ecodeextidx = 0
     DETAIL
      ecodeextidx += 1, stat = alterlist(ecicodes->codes[ecicnt].extension,ecodeextidx), ecicodes->
      codes[ecicnt].extension[ecodeextidx].fieldname = cve.field_name,
      ecicodes->codes[ecicnt].extension[ecodeextidx].fieldvalue = cve.field_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL logmsg("loadECICodes","EXITING... no eCodes found",log_debug)
     RETURN(false)
    ENDIF
    CALL logmsg("loadECICodes","EXITING...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(compareecicodes,char(128))=char(128))
  SUBROUTINE (compareecicodes(lowervalue=vc,highervalue=vc) =i2)
    CALL logmsg("compareECICodes","ENTERING...",log_debug)
    DECLARE lowerbeforedecimalstring = vc WITH protect, noconstant("")
    DECLARE lowerafterdecimalstring = vc WITH protect, noconstant("")
    DECLARE lowervalueintpart = i4 WITH protect, noconstant(0)
    DECLARE lowervaluedecimalpart = i4 WITH protect, noconstant(0)
    DECLARE lowervaluedecimalstart = i4 WITH protect, noconstant(0)
    DECLARE islowerdecimalpresent = i2 WITH protect, noconstant(false)
    DECLARE lowercharind = i2 WITH protect, noconstant(true)
    DECLARE lowernumericind = i2 WITH protect, noconstant(true)
    DECLARE lowercharidx = i4 WITH protect, noconstant(1)
    DECLARE lowernumericidx = i4 WITH protect, noconstant(0)
    DECLARE higherbeforedecimalstring = vc WITH protect, noconstant("")
    DECLARE higherafterdecimalstring = vc WITH protect, noconstant("")
    DECLARE highervalueintpart = i4 WITH protect, noconstant(0)
    DECLARE highervaluedecimalpart = i4 WITH protect, noconstant(0)
    DECLARE highervaluedecimalstart = i4 WITH protect, noconstant(0)
    DECLARE ishigherdecimalpresent = i2 WITH protect, noconstant(false)
    DECLARE highercharind = i2 WITH protect, noconstant(true)
    DECLARE highernumericind = i2 WITH protect, noconstant(true)
    DECLARE highercharidx = i4 WITH protect, noconstant(1)
    DECLARE highernumericidx = i4 WITH protect, noconstant(0)
    DECLARE charatpos = vc WITH protect, noconstant("")
    SET lowervalue = cnvtupper(lowervalue)
    SET highervalue = cnvtupper(highervalue)
    WHILE (lowercharind)
     SET charatpos = substring(lowercharidx,1,lowervalue)
     IF (charatpos >= char(65)
      AND charatpos <= char(90))
      SET lowerbeforedecimalstring = concat(lowerbeforedecimalstring,charatpos)
      SET lowercharidx += 1
     ELSE
      SET lowercharind = false
     ENDIF
    ENDWHILE
    WHILE (highercharind)
     SET charatpos = substring(highercharidx,1,highervalue)
     IF (charatpos >= char(65)
      AND charatpos <= char(90))
      SET higherbeforedecimalstring = concat(higherbeforedecimalstring,charatpos)
      SET highercharidx += 1
     ELSE
      SET highercharind = false
     ENDIF
    ENDWHILE
    IF (lowerbeforedecimalstring < higherbeforedecimalstring)
     RETURN(true)
    ELSEIF (lowerbeforedecimalstring=higherbeforedecimalstring)
     SET lowervaluedecimalstart = findstring(".",lowervalue,(lowercharidx+ 1),0)
     SET highervaluedecimalstart = findstring(".",highervalue,(highercharidx+ 1),0)
     IF (lowervaluedecimalstart > 0)
      SET lowervalueintpart = cnvtint(trim(substring(lowercharidx,(lowervaluedecimalstart -
         lowercharidx),lowervalue),3))
     ELSE
      SET lowervalueintpart = cnvtint(trim(substring(lowercharidx,(size(lowervalue,1) - (lowercharidx
          - 1)),lowervalue),3))
     ENDIF
     IF (highervaluedecimalstart > 0)
      SET highervalueintpart = cnvtint(trim(substring(highercharidx,(highervaluedecimalstart -
         highercharidx),highervalue),3))
     ELSE
      SET highervalueintpart = cnvtint(trim(substring(highercharidx,(size(highervalue,1) - (
         highercharidx - 1)),highervalue),3))
     ENDIF
     IF (lowervalueintpart < highervalueintpart)
      RETURN(true)
     ELSEIF (lowervalueintpart=highervalueintpart)
      IF (lowervaluedecimalstart > 0
       AND highervaluedecimalstart > 0)
       SET lowernumericidx = (lowervaluedecimalstart+ 1)
       WHILE (lowernumericind)
        SET charatpos = substring(lowernumericidx,1,lowervalue)
        IF (charatpos >= char(48)
         AND charatpos <= char(57))
         SET lowernumericidx += 1
        ELSE
         SET lowernumericind = false
        ENDIF
       ENDWHILE
       SET lowervaluedecimalpart = cnvtint(trim(substring((lowervaluedecimalstart+ 1),((
          lowernumericidx - 1) - lowervaluedecimalstart),lowervalue),3))
       IF ((lowernumericidx=(lowervaluedecimalstart+ 1)))
        SET lowerafterdecimalstring = substring((lowervaluedecimalstart+ 1),(size(lowervalue,1) -
         lowervaluedecimalstart),lowervalue)
       ELSE
        SET islowerdecimalpresent = true
        SET lowerafterdecimalstring = substring(((lowervaluedecimalstart+ size(trim(cnvtstring(
            lowervaluedecimalpart),3),1))+ 1),(size(lowervalue,1) - (lowervaluedecimalstart+ size(
          trim(cnvtstring(lowervaluedecimalpart),3)))),lowervalue)
       ENDIF
       SET highernumericidx = (highervaluedecimalstart+ 1)
       WHILE (highernumericind)
        SET charatpos = substring(highernumericidx,1,highervalue)
        IF (charatpos >= char(48)
         AND charatpos <= char(57))
         SET highernumericidx += 1
        ELSE
         SET highernumericind = false
        ENDIF
       ENDWHILE
       SET highervaluedecimalpart = cnvtint(trim(substring((highervaluedecimalstart+ 1),((
          highernumericidx - 1) - highervaluedecimalstart),highervalue),3))
       IF ((highernumericidx=(highervaluedecimalstart+ 1)))
        SET higherafterdecimalstring = substring((highervaluedecimalstart+ 1),(size(highervalue,1) -
         highervaluedecimalstart),highervalue)
       ELSE
        SET ishigherdecimalpresent = true
        SET higherafterdecimalstring = substring(((highervaluedecimalstart+ size(trim(cnvtstring(
            highervaluedecimalpart),3),1))+ 1),(size(highervalue,1) - (highervaluedecimalstart+ size(
          trim(cnvtstring(highervaluedecimalpart),3)))),highervalue)
       ENDIF
       IF (islowerdecimalpresent
        AND ishigherdecimalpresent)
        IF (lowervaluedecimalpart < highervaluedecimalpart)
         RETURN(true)
        ELSEIF (lowervaluedecimalpart=highervaluedecimalpart)
         IF (lowerafterdecimalstring <= higherafterdecimalstring)
          RETURN(true)
         ELSE
          RETURN(false)
         ENDIF
        ENDIF
       ELSEIF (islowerdecimalpresent
        AND  NOT (ishigherdecimalpresent))
        IF (size(trim(higherafterdecimalstring,3),1) > 0)
         RETURN(true)
        ELSEIF (size(trim(higherafterdecimalstring,3),1)=0)
         RETURN(false)
        ENDIF
       ELSEIF ( NOT (islowerdecimalpresent)
        AND ishigherdecimalpresent)
        IF (size(trim(lowerafterdecimalstring,3),1) > 0)
         RETURN(false)
        ELSEIF (size(trim(lowerafterdecimalstring,3),1)=0)
         RETURN(true)
        ENDIF
       ELSE
        IF (lowerafterdecimalstring <= higherafterdecimalstring)
         RETURN(true)
        ELSE
         RETURN(false)
        ENDIF
       ENDIF
      ELSEIF (lowervaluedecimalstart > 0
       AND  NOT (highervaluedecimalstart > 0))
       RETURN(false)
      ELSEIF ( NOT (lowervaluedecimalstart > 0)
       AND highervaluedecimalstart > 0)
       RETURN(true)
      ELSE
       RETURN(true)
      ENDIF
     ELSE
      RETURN(false)
     ENDIF
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(retrieveicdsourcevocab,char(128))=char(128))
  SUBROUTINE (retrieveicdsourcevocab(icdgroupname=vc) =i4)
    CALL logmsg("retrieveICDSourceVocab","ENTERING...",log_debug)
    DECLARE icdcnt = i4 WITH protect, noconstant(0)
    DECLARE icdgroupingcnt = i4 WITH protect, noconstant(0)
    DECLARE regex = vc WITH protect, noconstant("")
    SET icdgroupingcnt = (size(icdsourcevocab->icdgrouping,5)+ 1)
    SET stat = alterlist(icdsourcevocab->icdgrouping,icdgroupingcnt)
    SET icdsourcevocab->icdgrouping[icdgroupingcnt].groupname = icdgroupname
    SET regex = concat("*",trim(icdgroupname),"*")
    SELECT INTO "nl:"
     FROM code_value c
     WHERE c.code_set=src_vocab_cs
      AND c.active_ind=1
      AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND c.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND c.cdf_meaning=patstring(regex)
     ORDER BY c.cdf_meaning
     DETAIL
      icdcnt += 1, stat = alterlist(icdsourcevocab->icdgrouping[icdgroupingcnt].codes,icdcnt),
      icdsourcevocab->icdgrouping[icdgroupingcnt].codes[icdcnt].vocabcd = c.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL logmsg("retrieveICDSourceVocab","EXITING...",log_debug)
     RETURN(0)
    ENDIF
    CALL logmsg("retrieveICDSourceVocab","EXITING...",log_debug)
    RETURN(icdgroupingcnt)
  END ;Subroutine
 ENDIF
 IF (validate(getclaimdatalitexml,char(128))=char(128))
  SUBROUTINE (getclaimdatalitexml(claimdetails=vc(ref)) =i2)
    CALL logmsg("getClaimDataLiteXML","ENTERING...",log_debug)
    DECLARE index = i4 WITH protect, noconstant(0)
    DECLARE clmcount = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM br_long_blob_reltn blb,
      long_blob lb
     PLAN (blb
      WHERE expand(index,1,size(claimdetails->claims,5),blb.corsp_activity_id,claimdetails->claims[
       index].corspactivityid)
       AND blb.data_type_flag=claim_data_lite_xml_flag
       AND blb.active_ind=true)
      JOIN (lb
      WHERE lb.long_blob_id=blb.long_blob_id
       AND lb.active_ind=true)
     DETAIL
      clmcount += 1
      IF (mod(clmcount,10)=1)
       stat = alterlist(skipclaimdetails->claims,(clmcount+ 9))
      ENDIF
      outbuf = "", blobsize = blobgetlen(lb.long_blob), stat = memrealloc(outbuf,1,build("C",blobsize
        )),
      totlen = blobget(outbuf,0,lb.long_blob), skipclaimdetails->claims[clmcount].corspactivityid =
      blb.corsp_activity_id, skipclaimdetails->claims[clmcount].claimdatalitexml = notrim(outbuf)
     WITH nocounter, rdbarrayfetch = 1
    ;end select
    SET stat = alterlist(skipclaimdetails->claims,clmcount)
    IF (size(skipclaimdetails->claims,5)=0)
     CALL logmsg("getClaimDataLiteXML","NO qualified claims to get the claimdata lite",log_debug)
     RETURN(false)
    ENDIF
    CALL logmsg("getClaimDataLiteXML","EXITING...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getpcmpreferenceforclaimvalidations,char(128))=char(128))
  SUBROUTINE (getpcmpreferenceforclaimvalidations(skipclaimdetails=vc(ref)) =i2)
    CALL logmsg("getPCMPreferenceForClaimValidations","ENTERING...",log_debug)
    DECLARE hroot = i4 WITH protect, noconstant(0)
    DECLARE hxmlfile = i4 WITH protect, noconstant(0)
    DECLARE hcontextxml = i4 WITH protect, noconstant(0)
    DECLARE index = i4 WITH protect, noconstant(1)
    IF (size(skipclaimdetails->claims,5)=0)
     CALL logmsg("getPCMPreferenceForClaimValidations",
      "No valid claims to extract the skip claim preferences",log_debug)
     RETURN(false)
    ENDIF
    FOR (index = 1 TO size(skipclaimdetails->claims,5))
     SET hroot = parsexmlbuffer(skipclaimdetails->claims[index].claimdatalitexml,hxmlfile)
     IF (((hroot=0) OR (hxmlfile=0)) )
      CALL uar_xml_closefile(hxmlfile)
     ELSE
      SET hcontextxml = getclaimdatacontexthandle(hroot)
      IF (hcontextxml != 0)
       SET skipclaimdetails->claims[index].skipinternalvalidation = evaluate(getchildnodevalue(
         hcontextxml,"skipInternalValidation"),"TRUE",1,0)
       SET skipclaimdetails->claims[index].skipexternalvalidation = evaluate(getchildnodevalue(
         hcontextxml,"skipExternalValidation"),"TRUE",1,0)
       SET skipclaimdetails->claims[index].skipmanualreview = evaluate(getchildnodevalue(hcontextxml,
         "skipManualReview"),"TRUE",1,0)
      ENDIF
      CALL uar_xml_closefile(hxmlfile)
     ENDIF
    ENDFOR
    CALL logmsg("getPCMPreferenceForClaimValidations","EXITING...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(setpcmpreferencesforpreviewclaims,char(128))=char(128))
  SUBROUTINE (setpcmpreferencesforpreviewclaims(reply=vc(ref)) =null)
    CALL logmsg("setPCMPreferencesforPreviewClaims","ENTERING...",log_debug)
    DECLARE counter = i4 WITH protect, noconstant(0)
    DECLARE index = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(reply->claims,5)))
     WHERE (reply->claims[d1.seq].corspactivityid != 0)
     DETAIL
      counter += 1
      IF (mod(counter,10)=1)
       stat = alterlist(claimdetails->claims,(counter+ 9))
      ENDIF
      claimdetails->claims[counter].corspactivityid = reply->claims[d1.seq].corspactivityid
     WITH nocounter
    ;end select
    SET stat = alterlist(claimdetails->claims,counter)
    IF (getclaimdatalitexml(claimdetails))
     IF (getpcmpreferenceforclaimvalidations(skipclaimdetails))
      SELECT INTO "nl:"
       FROM (dummyt d2  WITH seq = value(size(skipclaimdetails->claims,5)))
       WHERE expand(index,1,size(reply->claims,5),skipclaimdetails->claims[d2.seq].corspactivityid,
        reply->claims[index].corspactivityid)
       DETAIL
        reply->claims[index].skipinternalvalidation = skipclaimdetails->claims[d2.seq].
        skipinternalvalidation, reply->claims[index].skipexternalvalidation = skipclaimdetails->
        claims[d2.seq].skipexternalvalidation, reply->claims[index].skipmanualreview =
        skipclaimdetails->claims[d2.seq].skipmanualreview
       WITH nocounter
      ;end select
     ENDIF
    ELSE
     CALL logmsg("setPCMPreferencesforPreviewClaims",
      "There are no valid records to fill the preferences",log_debug)
    ENDIF
  END ;Subroutine
 ENDIF
 CALL echo(build("End PFT_CLM_COMMON_SUBS.INC, version [",nullterm("RCBCLM-23004.017"),"]"))
 CALL echo("Begin PFT_LOGICAL_DOMAIN_SUBS.INC, version [714452.014 w/o 002,005,007,008,009,010]")
 IF (validate(ld_concept_person)=0)
  DECLARE ld_concept_person = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_prsnl)=0)
  DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 ENDIF
 IF (validate(ld_concept_organization)=0)
  DECLARE ld_concept_organization = i2 WITH public, constant(3)
 ENDIF
 IF (validate(ld_concept_healthplan)=0)
  DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 ENDIF
 IF (validate(ld_concept_alias_pool)=0)
  DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 ENDIF
 IF (validate(ld_concept_minvalue)=0)
  DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_maxvalue)=0)
  DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
 ENDIF
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 DECLARE __lpahsys = i4 WITH protect, noconstant(0)
 DECLARE __lpalsysstat = i4 WITH protect, noconstant(0)
 IF (validate(logmessage,char(128))=char(128))
  SUBROUTINE (logmessage(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    IF (size(trim(psubroutine,3)) > 0)
     CALL echo(concat(curprog," : ",psubroutine,"() : ",pmessage))
    ELSE
     CALL echo(concat(curprog," : ",pmessage))
    ENDIF
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __lpahsys = 0
    SET __lpalsysstat = 0
    CALL uar_syscreatehandle(__lpahsys,__lpalsysstat)
    IF (__lpahsys > 0)
     CALL uar_sysevent(__lpahsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__lpahsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(profitlogicaldomaininfo)))
  RECORD profitlogicaldomaininfo(
    1 hasbeenset = i2
    1 logicaldomainid = f8
    1 logicaldomainsystemuserid = f8
  ) WITH persistscript
 ENDIF
 IF ( NOT (validate(ld_concept_batch_trans)))
  DECLARE ld_concept_batch_trans = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_event)))
  DECLARE ld_concept_pft_event = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_ruleset)))
  DECLARE ld_concept_pft_ruleset = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_queue_item_wf_hist)))
  DECLARE ld_concept_pft_queue_item_wf_hist = i2 WITH public, constant(ld_concept_prsnl)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_workflow)))
  DECLARE ld_concept_pft_workflow = i2 WITH public, constant(ld_concept_prsnl)
 ENDIF
 IF ( NOT (validate(ld_entity_account)))
  DECLARE ld_entity_account = vc WITH protect, constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(ld_entity_adjustment)))
  DECLARE ld_entity_adjustment = vc WITH protect, constant("ADJUSTMENT")
 ENDIF
 IF ( NOT (validate(ld_entity_balance)))
  DECLARE ld_entity_balance = vc WITH protect, constant("BALANCE")
 ENDIF
 IF ( NOT (validate(ld_entity_charge)))
  DECLARE ld_entity_charge = vc WITH protect, constant("CHARGE")
 ENDIF
 IF ( NOT (validate(ld_entity_claim)))
  DECLARE ld_entity_claim = vc WITH protect, constant("CLAIM")
 ENDIF
 IF ( NOT (validate(ld_entity_encounter)))
  DECLARE ld_entity_encounter = vc WITH protect, constant("ENCOUNTER")
 ENDIF
 IF ( NOT (validate(ld_entity_invoice)))
  DECLARE ld_entity_invoice = vc WITH protect, constant("INVOICE")
 ENDIF
 IF ( NOT (validate(ld_entity_payment)))
  DECLARE ld_entity_payment = vc WITH protect, constant("PAYMENT")
 ENDIF
 IF ( NOT (validate(ld_entity_person)))
  DECLARE ld_entity_person = vc WITH protect, constant("PERSON")
 ENDIF
 IF ( NOT (validate(ld_entity_pftencntr)))
  DECLARE ld_entity_pftencntr = vc WITH protect, constant("PFTENCNTR")
 ENDIF
 IF ( NOT (validate(ld_entity_statement)))
  DECLARE ld_entity_statement = vc WITH protect, constant("STATEMENT")
 ENDIF
 IF ( NOT (validate(getlogicaldomain)))
  SUBROUTINE (getlogicaldomain(concept=i4,logicaldomainid=f8(ref)) =i2)
    CALL logmessage("getLogicalDomain","Entering...",log_debug)
    IF (arelogicaldomainsinuse(0))
     IF (((concept < ld_concept_minvalue) OR (concept > ld_concept_maxvalue)) )
      CALL logmessage("getLogicalDomain",build2("Invalid logical domain concept: ",concept),log_error
       )
      RETURN(false)
     ENDIF
     FREE RECORD acm_get_curr_logical_domain_req
     RECORD acm_get_curr_logical_domain_req(
       1 concept = i4
     )
     FREE RECORD acm_get_curr_logical_domain_rep
     RECORD acm_get_curr_logical_domain_rep(
       1 logical_domain_id = f8
       1 status_block
         2 status_ind = i2
         2 error_code = i4
     )
     DECLARE currentuserid = f8 WITH protect, constant(reqinfo->updt_id)
     IF ((profitlogicaldomaininfo->hasbeenset=true))
      SET reqinfo->updt_id = profitlogicaldomaininfo->logicaldomainsystemuserid
     ENDIF
     SET acm_get_curr_logical_domain_req->concept = concept
     EXECUTE acm_get_curr_logical_domain
     SET reqinfo->updt_id = currentuserid
     IF ((acm_get_curr_logical_domain_rep->status_block.status_ind != true))
      CALL logmessage("getLogicalDomain","Failed to retrieve logical domain...",log_error)
      CALL echorecord(acm_get_curr_logical_domain_rep)
      RETURN(false)
     ENDIF
     SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
     CALL logmessage("getLogicalDomain",build2("Logical domain for concept [",trim(cnvtstring(concept
         )),"]: ",trim(cnvtstring(logicaldomainid))),log_debug)
     FREE RECORD acm_get_curr_logical_domain_req
     FREE RECORD acm_get_curr_logical_domain_rep
    ELSE
     SET logicaldomainid = 0.0
    ENDIF
    CALL logmessage("getLogicalDomain","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getlogicaldomainforentitytype(pentityname=vc,prlogicaldomainid=f8(ref)) =i2)
   DECLARE entityconcept = i4 WITH protect, noconstant(0)
   CASE (pentityname)
    OF value(ld_entity_person,ld_entity_encounter,ld_entity_pftencntr):
     SET entityconcept = ld_concept_person
    OF value(ld_entity_claim,ld_entity_invoice,ld_entity_statement,ld_entity_adjustment,
    ld_entity_charge,
    ld_entity_payment,ld_entity_account,ld_entity_balance):
     SET entityconcept = ld_concept_organization
   ENDCASE
   RETURN(getlogicaldomain(entityconcept,prlogicaldomainid))
 END ;Subroutine
 IF ( NOT (validate(setlogicaldomain)))
  SUBROUTINE (setlogicaldomain(logicaldomainid=f8) =i2)
    CALL logmessage("setLogicalDomain","Entering...",log_debug)
    IF (arelogicaldomainsinuse(0))
     SELECT INTO "nl:"
      FROM logical_domain ld
      WHERE ld.logical_domain_id=logicaldomainid
      DETAIL
       profitlogicaldomaininfo->logicaldomainsystemuserid = ld.system_user_id
      WITH nocounter
     ;end select
     SET profitlogicaldomaininfo->logicaldomainid = logicaldomainid
     SET profitlogicaldomaininfo->hasbeenset = true
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE (p.person_id=reqinfo->updt_id)
      DETAIL
       IF (p.logical_domain_id != logicaldomainid)
        reqinfo->updt_id = profitlogicaldomaininfo->logicaldomainsystemuserid
       ENDIF
      WITH nocounter
     ;end select
     IF (validate(debug,0))
      CALL echorecord(profitlogicaldomaininfo)
      CALL echo(build("reqinfo->updt_id:",reqinfo->updt_id))
     ENDIF
    ENDIF
    CALL logmessage("setLogicalDomain","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(arelogicaldomainsinuse)))
  DECLARE arelogicaldomainsinuse(null) = i2
  SUBROUTINE arelogicaldomainsinuse(null)
    CALL logmessage("areLogicalDomainsInUse","Entering...",log_debug)
    DECLARE multiplelogicaldomainsdefined = i2 WITH protect, noconstant(false)
    SELECT INTO "nl:"
     FROM logical_domain ld
     WHERE ld.logical_domain_id > 0.0
      AND ld.active_ind=true
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET multiplelogicaldomainsdefined = true
    ENDIF
    CALL logmessage("areLogicalDomainsInUse",build2("Multiple logical domains ",evaluate(
       multiplelogicaldomainsdefined,true,"are","are not")," in use"),log_debug)
    CALL logmessage("areLogicalDomainsInUse","Exiting...",log_debug)
    RETURN(multiplelogicaldomainsdefined)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getparameterentityname(dparmcd=f8) =vc)
   DECLARE parammeaning = vc WITH private, constant(trim(uar_get_code_meaning(dparmcd)))
   DECLARE returnvalue = vc WITH private, noconstant("")
   SET returnvalue = evaluate(parammeaning,"BEID","BILLING_ENTITY","OPTIONALBEID","BILLING_ENTITY",
    "HP ID","HEALTH_PLAN","HP_LIST","HEALTH_PLAN","PRIMARYHP",
    "HEALTH_PLAN","PRIPAYORHPID","HEALTH_PLAN","SECPAYORHPID","HEALTH_PLAN",
    "TERPAYORHPID","HEALTH_PLAN","COLLAGENCY","ORGANIZATION","PAYORORGID",
    "ORGANIZATION","PRECOLAGENCY","ORGANIZATION","PRIPAYORORGI","ORGANIZATION",
    "SECPAYORORGI","ORGANIZATION","TERPAYORORGI","ORGANIZATION","PAYER_LIST",
    "ORGANIZATION","UNKNOWN")
   RETURN(returnvalue)
 END ;Subroutine
 SUBROUTINE (paramsarevalidfordomain(paramstruct=vc(ref),dlogicaldomainid=f8) =i2)
   DECLARE paramidx = i4 WITH private, noconstant(0)
   DECLARE paramentityname = vc WITH private, noconstant("")
   DECLARE paramvalue = f8 WITH protect, noconstant(0.0)
   DECLARE paramerror = i2 WITH protect, noconstant(false)
   FOR (paramidx = 1 TO paramstruct->lparams_qual)
     SET paramentityname = getparameterentityname(paramstruct->aparams[paramidx].dvalue_meaning)
     SET paramvalue = cnvtreal(paramstruct->aparams[paramidx].svalue)
     SET paramerror = true
     IF (paramentityname="BILLING_ENTITY")
      SELECT INTO "nl:"
       FROM billing_entity be,
        organization o
       PLAN (be
        WHERE be.billing_entity_id=paramvalue)
        JOIN (o
        WHERE o.organization_id=be.organization_id
         AND o.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSEIF (paramentityname="HEALTH_PLAN")
      SELECT INTO "nl:"
       FROM health_plan hp
       PLAN (hp
        WHERE hp.health_plan_id=paramvalue
         AND hp.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSEIF (paramentityname="ORGANIZATION")
      SELECT INTO "nl:"
       FROM organization o
       PLAN (o
        WHERE o.organization_id=paramvalue
         AND o.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSE
      SET paramerror = false
     ENDIF
     IF (paramerror)
      RETURN(false)
     ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 IF ( NOT (validate(getlogicaldomainsystemuser)))
  SUBROUTINE (getlogicaldomainsystemuser(logicaldomainid=f8(ref)) =f8)
    DECLARE systempersonnelid = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM logical_domain ld
     WHERE ld.logical_domain_id=logicaldomainid
     DETAIL
      systempersonnelid = ld.system_user_id
     WITH nocounter
    ;end select
    IF (systempersonnelid <= 0.0)
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE p.active_ind=true
       AND p.logical_domain_id=logicaldomainid
       AND p.username="SYSTEM"
      DETAIL
       systempersonnelid = p.person_id
      WITH nocounter
     ;end select
    ENDIF
    IF (systempersonnelid <= 0.0)
     CALL logmessage("getLogicalDomainSystemUser",
      "Failed to determine the default 'SYSTEM' personnel id",log_error)
     RETURN(0.0)
    ENDIF
    CALL logmessage("getLogicalDomainSystemUser","Exiting",log_debug)
    RETURN(systempersonnelid)
  END ;Subroutine
 ENDIF
 FREE RECORD gimebillinghp
 RECORD gimebillinghp(
   1 healthplans[*]
     2 encntrplanreltnid = f8
     2 healthplanid = f8
     2 priorityseq = i4
     2 financialclasscd = f8
     2 begineffectivedatetime = dq8
     2 endeffectivedatetime = dq8
     2 carrierorgid = f8
     2 planname = vc
     2 plannamekey = vc
     2 bohpreltntypecd = f8
     2 skipaddimebohp = i2
 )
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 IF ( NOT (validate(cs4002034_ime_billing_cd)))
  DECLARE cs4002034_ime_billing_cd = f8 WITH protect, constant(getcodevalue(4002034,"IME BILLING",1))
 ENDIF
 IF ( NOT (validate(cs4002027_ime_rule_cd)))
  DECLARE cs4002027_ime_rule_cd = f8 WITH protect, constant(getcodevalue(4002027,"IGIME",1))
 ENDIF
 IF ( NOT (validate(cs8_auth_cd)))
  DECLARE cs8_auth_cd = f8 WITH protect, constant(getcodevalue(8,"AUTH",1))
 ENDIF
 IF ( NOT (validate(cs370_carrier_cd)))
  DECLARE cs370_carrier_cd = f8 WITH protect, constant(getcodevalue(370,"CARRIER",1))
 ENDIF
 IF ( NOT (validate(cs354_selfpay_cd)))
  DECLARE cs354_selfpay_cd = f8 WITH protect, constant(getcodevalue(354,"SELFPAY",1))
 ENDIF
 IF ( NOT (validate(cs24451_invalid_cd)))
  DECLARE cs24451_invalid_cd = f8 WITH protect, constant(getcodevalue(24451,"INVALID",1))
 ENDIF
 IF (validate(getimehealthplans,char(128))=char(128))
  SUBROUTINE (getimehealthplans(benefitorderid=f8) =i2)
    FREE RECORD imebohpevalreq
    RECORD imebohpevalreq(
      1 encntrtypecd = f8
      1 encntrtypeclasscd = f8
      1 healthplans[*]
        2 healthplanid = f8
        2 priorityseq = i4
      1 billingproviderorganizationid = f8
    )
    CALL logmsg("getIMEHealthPlans","Entering...",log_debug)
    IF (benefitorderid > 0.0)
     SELECT INTO "nl:"
      FROM benefit_order bo,
       pft_encntr pe,
       encounter e,
       encntr_plan_reltn epr,
       health_plan hp,
       billing_entity be
      PLAN (bo
       WHERE bo.benefit_order_id=benefitorderid
        AND bo.fin_class_cd != cs354_selfpay_cd
        AND ((bo.bo_status_cd+ 0) != cs24451_invalid_cd)
        AND ((bo.active_ind+ 0)=true))
       JOIN (pe
       WHERE pe.pft_encntr_id=bo.pft_encntr_id)
       JOIN (e
       WHERE e.encntr_id=pe.encntr_id)
       JOIN (epr
       WHERE epr.encntr_id=e.encntr_id
        AND epr.active_ind=true
        AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (hp
       WHERE hp.health_plan_id=epr.health_plan_id
        AND hp.data_status_cd=cs8_auth_cd
        AND hp.active_ind=true)
       JOIN (be
       WHERE be.billing_entity_id=pe.billing_entity_id)
      ORDER BY bo.benefit_order_id, epr.priority_seq
      HEAD bo.benefit_order_id
       cnt = 0, imebohpevalreq->encntrtypecd = e.encntr_type_cd, imebohpevalreq->encntrtypeclasscd =
       e.encntr_type_class_cd,
       imebohpevalreq->billingproviderorganizationid = be.organization_id
      HEAD epr.priority_seq
       cnt += 1, stat = alterlist(imebohpevalreq->healthplans,cnt), imebohpevalreq->healthplans[cnt].
       healthplanid = epr.health_plan_id,
       imebohpevalreq->healthplans[cnt].priorityseq = epr.priority_seq
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL logmsg("getIMEHealthPlans...","Failed to determine fin encntr and health plan info.",
       log_debug)
      FREE RECORD imebohpevalreq
      RETURN(err_unknown)
     ENDIF
    ELSE
     CALL logmsg("getIMEHealthPlans...","benefit order is required",log_debug)
     FREE RECORD imebohpevalreq
     RETURN(err_unknown)
    ENDIF
    IF ( NOT (evaluateimehealthplans(imebohpevalreq)))
     CALL logmsg("getIMEHealthPlans...","Failed to evaluate IME health plans.",log_debug)
     FREE RECORD imebohpevalreq
     RETURN(err_unknown)
    ENDIF
    RETURN(0)
  END ;Subroutine
 ENDIF
 IF (validate(evaluateimehealthplans,char(128))=char(128))
  SUBROUTINE (evaluateimehealthplans(imecriteriarec=vc(ref)) =i2)
    FREE RECORD runxslrequest
    RECORD runxslrequest(
      1 xml
        2 xml = vc
        2 resources[*]
          3 resourcename = vc
          3 xml = vc
      1 xsl
        2 stylesheetname = vc
        2 xsl = vc
        2 resources[*]
          3 resourcename = vc
          3 xml = vc
    )
    FREE RECORD runxslreply
    RECORD runxslreply(
      1 xml = gvc
      1 pft_status_data
        2 subeventstatus[1]
          3 programname = vc
          3 subroutinename = vc
          3 message = vc
        2 pft_stats[*]
          3 programname = vc
          3 executioncnt = i4
          3 executiontime = f8
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    DECLARE inputxml = vc WITH protect, noconstant(nullterm(""))
    DECLARE houtputxmlfile = i4 WITH protect, noconstant(0)
    DECLARE hroot = i4 WITH protect, noconstant(0)
    DECLARE hchargegroups = i4 WITH protect, noconstant(0)
    DECLARE hchargegroup = i4 WITH protect, noconstant(0)
    DECLARE hhealthplans = i4 WITH protect, noconstant(0)
    DECLARE hhealthplan = i4 WITH protect, noconstant(0)
    DECLARE hpidx = i4 WITH protect, noconstant(0)
    DECLARE hpcnt1 = i4 WITH protect, noconstant(0)
    DECLARE planname = vc WITH protect, noconstant(nullterm(""))
    DECLARE plannamekey = vc WITH protect, noconstant(nullterm(""))
    DECLARE idx = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM pft_rule pr
     WHERE pr.rule_type_cd=cs4002027_ime_rule_cd
      AND pr.active_ind=true
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL logmsg("evaluateIMEHealthPlans...","No active IME Billing rules defined",log_debug)
     FREE RECORD runxslrequest
     FREE RECORD runxslreply
     RETURN(true)
    ENDIF
    SELECT INTO "nl:"
     FROM pft_claim_rule pcr
     WHERE pcr.rule_name="InstitutionalIMEBilling.xslt"
      AND pcr.active_ind=true
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL logmsg("evaluateIMEHealthPlans...","No active InsitutionalIMEBilling.xslt",log_debug)
     FREE RECORD runxslrequest
     FREE RECORD runxslreply
     RETURN(true)
    ENDIF
    SET inputxml = begindocument(inputxml,xml_encoding)
    SET inputxml = beginelement(inputxml,"chargeGroups")
    SET inputxml = beginelement(inputxml,"chargeGroup")
    SET inputxml = writeelement(inputxml,"chargeGroupId",cnvtstring(0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(imecriteriarec->healthplans,5)),
      health_plan hp
     PLAN (d)
      JOIN (hp
      WHERE (hp.health_plan_id=imecriteriarec->healthplans[d.seq].healthplanid)
       AND hp.active_ind=true)
     DETAIL
      inputxml = writeelement(inputxml,concat(evaluate(imecriteriarec->healthplans[d.seq].priorityseq,
         1,"primary",2,"secondary",
         3,"tertiary",""),"HealthPlanName"),hp.plan_name), inputxml = writeelement(inputxml,concat(
        evaluate(imecriteriarec->healthplans[d.seq].priorityseq,1,"primary",2,"secondary",
         3,"tertiary",""),"HealthPlanNameKey"),hp.plan_name_key), inputxml = writecodetype(inputxml,
       concat(evaluate(imecriteriarec->healthplans[d.seq].priorityseq,1,"primary",2,"secondary",
         3,"tertiary",""),"HealthPlanFinancialClass"),hp.financial_class_cd)
     WITH nocounter
    ;end select
    SET inputxml = writecodetype(inputxml,"encounterType",imecriteriarec->encntrtypecd)
    SET inputxml = writecodetype(inputxml,"encounterTypeClass",imecriteriarec->encntrtypeclasscd)
    SELECT INTO "nl:"
     FROM organization o
     PLAN (o
      WHERE (o.organization_id=imecriteriarec->billingproviderorganizationid))
     DETAIL
      inputxml = writeelement(inputxml,"billingProviderOrganizationName",o.org_name), inputxml =
      writeelement(inputxml,"billingProviderOrganizationNameKey",o.org_name_key)
     WITH nocounter
    ;end select
    SET inputxml = endelement(inputxml,"chargeGroup")
    SET inputxml = endelement(inputxml,"chargeGroups")
    SET runxslrequest->xml.xml = nullterm(inputxml)
    SET runxslrequest->xsl.stylesheetname = "InstitutionalIMEBilling.xslt"
    CALL echo(build("Input XML =  ",runxslrequest->xml.xml))
    EXECUTE pft_clm_run_xslt  WITH replace("REQUEST",runxslrequest), replace("REPLY",runxslreply)
    CALL echo(build("Input XML =  ",runxslreply->xml))
    IF ((runxslreply->status_data.status != "S"))
     CALL logmsg("evaluateIMEHealthPlans...","Rules evaluation failed",log_error)
     CALL setdetails("evaluateIMEHealthPlans...","Script PFT_CLM_RUN_XSLT failed")
     FREE RECORD runxslrequest
     FREE RECORD runxslreply
     RETURN(false)
    ELSE
     SET hroot = parsexmlbuffer(runxslreply->xml,houtputxmlfile)
     SET hchargegroups = getchildelementoccurrencehandle(hroot,"chargeGroups",1)
     SET hchargegroup = getchildelementoccurrencehandle(hchargegroups,"chargeGroup",1)
     SET hhealthplans = getchildelementoccurrencehandle(hchargegroup,"healthPlans",1)
     IF (hhealthplans != 0)
      SET hpcnt1 = uar_xml_getchildcount(hhealthplans)
      FOR (hpidx = 1 TO hpcnt1)
        SET hhealthplan = getchildelementoccurrencehandle(hhealthplans,"healthPlan",hpidx)
        SET plannamekey = getchildnodevalue(hhealthplan,"nameKey")
        SET idx = 0
        CALL logmsg("PFT_ADD_IME_BOHP_TO_BO",build("Search for IME health plan [",plannamekey,"]"),
         log_debug)
        IF ( NOT (getlogicaldomain(ld_concept_healthplan,logicaldomainid)))
         CALL logmsg("evaluateIMEHealthPlans...","Unable to retrieve logical domain id",log_error)
         RETURN(false)
        ENDIF
        SELECT INTO "nl:"
         FROM health_plan hp,
          org_plan_reltn opr
         PLAN (hp
          WHERE hp.plan_name_key=plannamekey
           AND hp.data_status_cd=cs8_auth_cd
           AND hp.logical_domain_id=logicaldomainid
           AND hp.active_ind=true)
          JOIN (opr
          WHERE opr.health_plan_id=hp.health_plan_id
           AND opr.org_plan_reltn_cd=cs370_carrier_cd
           AND opr.data_status_cd=cs8_auth_cd
           AND opr.active_ind=true)
         DETAIL
          idx += 1, stat = alterlist(gimebillinghp->healthplans,idx), gimebillinghp->healthplans[idx]
          .healthplanid = hp.health_plan_id,
          gimebillinghp->healthplans[idx].planname = hp.plan_name, gimebillinghp->healthplans[idx].
          plannamekey = hp.plan_name_key, gimebillinghp->healthplans[idx].priorityseq = 0,
          gimebillinghp->healthplans[idx].financialclasscd = hp.financial_class_cd, gimebillinghp->
          healthplans[idx].carrierorgid = opr.organization_id, gimebillinghp->healthplans[idx].
          begineffectivedatetime = hp.beg_effective_dt_tm,
          gimebillinghp->healthplans[idx].endeffectivedatetime = hp.end_effective_dt_tm,
          gimebillinghp->healthplans[idx].bohpreltntypecd = cs4002034_ime_billing_cd
         WITH nocounter
        ;end select
        IF (curqual > 0)
         CALL logmsg("evaluateIMEHealthPlans...",build("Adding IME health plan [",plannamekey,"]"),
          log_debug)
        ENDIF
      ENDFOR
     ELSE
      CALL logmsg("evaluateIMEHealthPlans...","No Non-participating Health Plans identified",
       log_debug)
     ENDIF
    ENDIF
    CALL releasexmlresources(houtputxmlfile)
    FREE RECORD runxslreply
    FREE RECORD runxslrequest
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF ( NOT (validate(entity_account)))
  DECLARE entity_account = vc WITH constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(entity_fin_encounter)))
  DECLARE entity_fin_encounter = vc WITH constant("ENCOUNTER")
 ENDIF
 IF ( NOT (validate(entity_balance)))
  DECLARE entity_balance = vc WITH constant("BO_HP_RELTN")
 ENDIF
 IF ( NOT (validate(entity_pft_encounter)))
  DECLARE entity_pft_encounter = vc WITH constant("PFT_ENCNTR")
 ENDIF
 IF ( NOT (validate(entity_person)))
  DECLARE entity_person = vc WITH constant("PERSON")
 ENDIF
 IF ( NOT (validate(entity_bill_record)))
  DECLARE entity_bill_record = vc WITH constant("BILL_RECORD")
 ENDIF
 IF ( NOT (validate(entity_transaction)))
  DECLARE entity_transaction = vc WITH constant("TRANSACTION")
 ENDIF
 IF ( NOT (validate(reltn_account)))
  DECLARE reltn_account = vc WITH constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(reltn_source_account)))
  DECLARE reltn_source_account = vc WITH constant("SOURCE_ACCOUNT")
 ENDIF
 IF ( NOT (validate(reltn_target_account)))
  DECLARE reltn_target_account = vc WITH constant("TARGET_ACCOUNT")
 ENDIF
 IF ( NOT (validate(reltn_fin_encounter)))
  DECLARE reltn_fin_encounter = vc WITH constant("FIN_ENCOUNTER")
 ENDIF
 IF ( NOT (validate(reltn_source_fin_encounter)))
  DECLARE reltn_source_fin_encounter = vc WITH constant("SOURCE_FIN_ENCOUNTER")
 ENDIF
 IF ( NOT (validate(reltn_target_fin_encounter)))
  DECLARE reltn_target_fin_encounter = vc WITH constant("TARGET_FIN_ENCOUNTER")
 ENDIF
 IF ( NOT (validate(reltn_balance)))
  DECLARE reltn_balance = vc WITH constant("BALANCE")
 ENDIF
 IF ( NOT (validate(reltn_source_balance)))
  DECLARE reltn_source_balance = vc WITH constant("SOURCE_BALANCE")
 ENDIF
 IF ( NOT (validate(reltn_target_balance)))
  DECLARE reltn_target_balance = vc WITH constant("TARGET_BALANCE")
 ENDIF
 IF ( NOT (validate(reltn_person)))
  DECLARE reltn_person = vc WITH constant("RELTN_PERSON")
 ENDIF
 IF ( NOT (validate(reltn_bill_record)))
  DECLARE reltn_bill_record = vc WITH constant("RELTN_BILL_RECORD")
 ENDIF
 IF ( NOT (validate(reltn_transaction)))
  DECLARE reltn_transaction = vc WITH constant("RELTN_TRANSACTION")
 ENDIF
 IF ( NOT (validate(cs18669_activity_cd)))
  DECLARE cs18669_activity_cd = f8 WITH constant(getcodevalue(18669,"ACTIVITY",0))
 ENDIF
 IF ( NOT (validate(cs18689_account_combine_cd)))
  DECLARE cs18689_account_combine_cd = f8 WITH constant(getcodevalue(18689,"ACCTCMB",0))
 ENDIF
 IF ( NOT (validate(cs18689_account_uncombine_cd)))
  DECLARE cs18689_account_uncombine_cd = f8 WITH constant(getcodevalue(18689,"ACCTUNCMB",0))
 ENDIF
 IF ( NOT (validate(cs18689_encounter_combine_cd)))
  DECLARE cs18689_encounter_combine_cd = f8 WITH constant(getcodevalue(18689,"ENCNTRCMB",0))
 ENDIF
 IF ( NOT (validate(cs18689_encounter_uncombine_cd)))
  DECLARE cs18689_encounter_uncombine_cd = f8 WITH constant(getcodevalue(18689,"ENCNTRUNCMB",0))
 ENDIF
 IF ( NOT (validate(cs18689_encounter_move_cd)))
  DECLARE cs18689_encounter_move_cd = f8 WITH constant(getcodevalue(18689,"ENCNTRMOVE",0))
 ENDIF
 IF ( NOT (validate(cs18689_transferbal_cd)))
  DECLARE cs18689_transferbal_cd = f8 WITH constant(getcodevalue(18689,"TRANSFERBAL",0))
 ENDIF
 IF ( NOT (validate(cs18689_balstatchg_cd)))
  DECLARE cs18689_balstatchg_cd = f8 WITH constant(getcodevalue(18689,"BALSTATCHG",0))
 ENDIF
 IF ( NOT (validate(cs18689_fincmb_cd)))
  DECLARE cs18689_fincmb_cd = f8 WITH constant(getcodevalue(18689,"FINCMB",0))
 ENDIF
 IF ( NOT (validate(cs18689_finuncmb_cd)))
  DECLARE cs18689_finuncmb_cd = f8 WITH constant(getcodevalue(18689,"FINUNCMB",0))
 ENDIF
 IF ( NOT (validate(cs29421_statuscode)))
  DECLARE cs29421_statuscode = f8 WITH protect, constant(uar_get_code_by("MEANING",29421,"STATUSCODE"
    ))
 ENDIF
 IF ( NOT (validate(cs18689_formal_pay_plan_apply_cd)))
  DECLARE cs18689_formal_pay_plan_apply_cd = f8 WITH constant(getcodevalue(18689,"FPPAPPLY",0))
 ENDIF
 IF ( NOT (validate(cs18689_formal_pay_plan_modify_cd)))
  DECLARE cs18689_formal_pay_plan_modify_cd = f8 WITH constant(getcodevalue(18689,"FPPMODIFY",0))
 ENDIF
 IF ( NOT (validate(cs18689_formal_pay_plan_remove_cd)))
  DECLARE cs18689_formal_pay_plan_remove_cd = f8 WITH constant(getcodevalue(18689,"FPPREMOVE",0))
 ENDIF
 IF ( NOT (validate(cs18689_assign_to_agency_cd)))
  DECLARE cs18689_assign_to_agency_cd = f8 WITH constant(getcodevalue(18689,"ADDCOLAGENCY",0))
 ENDIF
 IF ( NOT (validate(cs18689_remove_from_agency_cd)))
  DECLARE cs18689_remove_from_agency_cd = f8 WITH constant(getcodevalue(18689,"RMVCOLAGENCY",0))
 ENDIF
 IF ( NOT (validate(cs18689_move_charges)))
  DECLARE cs18689_move_charges = f8 WITH constant(getcodevalue(18689,"MOVECHARGES",0))
 ENDIF
 IF ( NOT (validate(cs18689_redistribute_cd)))
  DECLARE cs18689_redistribute_cd = f8 WITH constant(getcodevalue(18689,"REDISTRIBUTE",0))
 ENDIF
 IF ( NOT (validate(cs18689_payment_cd)))
  DECLARE cs18689_payment_cd = f8 WITH constant(getcodevalue(18689,"PAYMENT",0))
 ENDIF
 IF ( NOT (validate(attr_account_number)))
  DECLARE attr_account_number = vc WITH protect, constant("accountNumber")
 ENDIF
 IF ( NOT (validate(attr_account_description)))
  DECLARE attr_account_description = vc WITH protect, constant("accountDescription")
 ENDIF
 IF ( NOT (validate(attr_fin_encounter_number)))
  DECLARE attr_fin_encounter_number = vc WITH protect, constant("encounterNumber")
 ENDIF
 IF ( NOT (validate(attr_bal_health_plan)))
  DECLARE attr_bal_health_plan = vc WITH protect, constant("healthPlan")
 ENDIF
 IF ( NOT (validate(attr_bal_priority_seq)))
  DECLARE attr_bal_priority_seq = vc WITH protect, constant("prioritySeq")
 ENDIF
 IF ( NOT (validate(attr_bal_type)))
  DECLARE attr_bal_type = vc WITH protect, constant("balanceType")
 ENDIF
 IF ( NOT (validate(attr_bal_chargegroup)))
  DECLARE attr_bal_chargegroup = vc WITH protect, constant("chargeGroup")
 ENDIF
 IF ( NOT (validate(attr_bal_transfer_amount)))
  DECLARE attr_bal_transfer_amount = vc WITH protect, constant("transferAmount")
 ENDIF
 IF ( NOT (validate(attr_bal_transfer_reason)))
  DECLARE attr_bal_transfer_reason = vc WITH protect, constant("transferReason")
 ENDIF
 IF ( NOT (validate(attr_bal_orig_status)))
  DECLARE attr_bal_orig_status = vc WITH protect, constant("originalBalanceStatus")
 ENDIF
 IF ( NOT (validate(attr_bal_new_status)))
  DECLARE attr_bal_new_status = vc WITH protect, constant("newBalanceStatus")
 ENDIF
 IF ( NOT (validate(attr_bal_is_selfpay_ind)))
  DECLARE attr_bal_is_selfpay_ind = vc WITH protect, constant("isSelfPay")
 ENDIF
 IF ( NOT (validate(attr_total_plan_amount)))
  DECLARE attr_total_plan_amount = vc WITH protect, constant("totalPlanAmount")
 ENDIF
 IF ( NOT (validate(attr_installment_amount)))
  DECLARE attr_installment_amount = vc WITH protect, constant("installmentAmount")
 ENDIF
 IF ( NOT (validate(attr_no_installments)))
  DECLARE attr_no_installments = vc WITH protect, constant("noInstallments")
 ENDIF
 IF ( NOT (validate(attr_cycle_length)))
  DECLARE attr_cycle_length = vc WITH protect, constant("cycleLength")
 ENDIF
 IF ( NOT (validate(attr_collection_agency)))
  DECLARE attr_collection_agency = vc WITH protect, constant("collectionAgency")
 ENDIF
 IF ( NOT (validate(attr_bad_debt_amount)))
  DECLARE attr_bad_debt_amount = vc WITH protect, constant("badDebtAmount")
 ENDIF
 IF ( NOT (validate(attr_number_of_charges)))
  DECLARE attr_number_of_charges = vc WITH protect, constant("numberOfCharges")
 ENDIF
 IF ( NOT (validate(attr_original_owner)))
  DECLARE attr_original_owner = vc WITH protect, constant("originalOwner")
 ENDIF
 IF ( NOT (validate(attr_redistributed_prsnl)))
  DECLARE attr_redistributed_prsnl = vc WITH protect, constant("redistributedPrsnl")
 ENDIF
 IF ( NOT (validate(attr_contributor_system_cd)))
  DECLARE attr_contributor_system_cd = vc WITH protect, constant("ContributorSystemCd")
 ENDIF
 IF ( NOT (validate(attr_workflow_status)))
  DECLARE attr_workflow_status = vc WITH protect, constant("workflowStatus")
 ENDIF
 IF ( NOT (validate(attr_cancel_pending_trans)))
  DECLARE attr_cancel_pending_trans = vc WITH protect, constant("cancelTransaction")
 ENDIF
 CALL echo("Begin PFT_RCA_I18N_CONSTANTS.INC, version [RCBACM-17290]")
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE hi18n = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 IF ( NOT (validate(i18n_professional)))
  DECLARE i18n_professional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Professional","Professional"))
 ENDIF
 IF ( NOT (validate(i18n_institutional)))
  DECLARE i18n_institutional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Institutional","Institutional"))
 ENDIF
 IF ( NOT (validate(i18n_selfpay)))
  DECLARE i18n_selfpay = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.SelfPay","Self Pay"))
 ENDIF
 IF ( NOT (validate(i18n_account)))
  DECLARE i18n_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Account","Account"))
 ENDIF
 IF ( NOT (validate(i18n_appointment)))
  DECLARE i18n_appointment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Appointment","Appointment"))
 ENDIF
 IF ( NOT (validate(i18n_client_account)))
  DECLARE i18n_client_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Client Account","Client Account"))
 ENDIF
 IF ( NOT (validate(i18n_research_account)))
  DECLARE i18n_research_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Research Account","Research Account"))
 ENDIF
 IF ( NOT (validate(i18n_patient_account)))
  DECLARE i18n_patient_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Patient Account","Patient Account"))
 ENDIF
 IF ( NOT (validate(i18n_encounter)))
  DECLARE i18n_encounter = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter","Encounter"))
 ENDIF
 IF ( NOT (validate(i18n_claim)))
  DECLARE i18n_claim = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Claim","Claim"))
 ENDIF
 IF ( NOT (validate(i18n_imeclaim)))
  DECLARE i18n_imeclaim = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.IME Claim","IME Claim"))
 ENDIF
 IF ( NOT (validate(i18n_charge)))
  DECLARE i18n_charge = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Charge","Charge"))
 ENDIF
 IF ( NOT (validate(i18n_guarantor)))
  DECLARE i18n_guarantor = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Guarantor","Guarantor"))
 ENDIF
 IF ( NOT (validate(i18n_statement)))
  DECLARE i18n_statement = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Statement","Statement"))
 ENDIF
 IF ( NOT (validate(i18n_payment)))
  DECLARE i18n_payment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Payment","Payment"))
 ENDIF
 IF ( NOT (validate(i18n_adjustment)))
  DECLARE i18n_adjustment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Adjustment","Adjustment"))
 ENDIF
 IF ( NOT (validate(i18n_ap_refund)))
  DECLARE i18n_ap_refund = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.A/P Refund","Refund"))
 ENDIF
 IF ( NOT (validate(i18n_batch)))
  DECLARE i18n_batch = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Batch","Batch"))
 ENDIF
 IF ( NOT (validate(i18n_registration)))
  DECLARE i18n_registration = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Registration","Registration"))
 ENDIF
 IF ( NOT (validate(i18n_authorization)))
  DECLARE i18n_authorization = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Authorization","Authorization"))
 ENDIF
 IF ( NOT (validate(i18n_person)))
  DECLARE i18n_person = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Person","Person"))
 ENDIF
 IF ( NOT (validate(i18n_organization)))
  DECLARE i18n_organization = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Organization","Organization"))
 ENDIF
 IF ( NOT (validate(i18n_balance)))
  DECLARE i18n_balance = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance","Balance"))
 ENDIF
 IF ( NOT (validate(i18n_invoice)))
  DECLARE i18n_invoice = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Invoice","Invoice"))
 ENDIF
 IF ( NOT (validate(i18n_research_invoice)))
  DECLARE i18n_research_invoice = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ResearchInvoice","Research Invoice"))
 ENDIF
 IF ( NOT (validate(i18n_client_invoice)))
  DECLARE i18n_client_invoice = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ClientInvoice","Client Invoice"))
 ENDIF
 IF ( NOT (validate(i18n_line_item)))
  DECLARE i18n_line_item = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Line Item","Line Item"))
 ENDIF
 IF ( NOT (validate(i18n_inpatient)))
  DECLARE i18n_inpatient = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Inpatient","Inpatient"))
 ENDIF
 IF ( NOT (validate(i18n_outpatient)))
  DECLARE i18n_outpatient = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Outpatient","Outpatient"))
 ENDIF
 IF ( NOT (validate(i18n_guarantor_account)))
  DECLARE i18n_guarantor_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Guarantor Account","Guarantor Account"))
 ENDIF
 IF ( NOT (validate(i18n_encounter_in_history)))
  DECLARE i18n_encounter_in_history = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter in history","Encounter in history"))
 ENDIF
 IF ( NOT (validate(i18n_balance_status)))
  DECLARE i18n_balance_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance not ready to bill","Balance not ready to bill"))
 ENDIF
 IF ( NOT (validate(i18n_no_formal_payment_plan)))
  DECLARE i18n_no_formal_payment_plan = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No formal payment plan assigned","No formal payment plan assigned"))
 ENDIF
 IF ( NOT (validate(i18n_formal_pay_plan_no_guar)))
  DECLARE i18n_formal_pay_plan_no_guar = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No guarantor found for the encounter.",
    "No guarantor found for the encounter."))
 ENDIF
 IF ( NOT (validate(i18n_formal_pay_plan_unsup_cons_method)))
  DECLARE i18n_formal_pay_plan_unsup_cons_method = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Unsupported consolidated method.","Unsupported consolidated method."))
 ENDIF
 IF ( NOT (validate(i18n_formal_pay_plan_excluded_enc_type)))
  DECLARE i18n_formal_pay_plan_excluded_enc_type = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter type is excluded from payment plans.",
    "Encounter type is excluded from payment plans."))
 ENDIF
 IF ( NOT (validate(i18n_formal_pay_plan_invalid_sp_bal)))
  DECLARE i18n_formal_pay_plan_invalid_sp_bal = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Zero or credit balance on selfpay balance.",
    "Zero or credit balance on selfpay balance."))
 ENDIF
 IF ( NOT (validate(i18n_formal_payment_plan)))
  DECLARE i18n_formal_payment_plan = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Formal payment plan assigned","Formal payment plan assigned"))
 ENDIF
 IF ( NOT (validate(i18n_ext_formal_pay_plan)))
  DECLARE i18n_ext_formal_pay_plan = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Formal payment plan externally managed",
    "Formal payment plan is managed externally"))
 ENDIF
 IF ( NOT (validate(i18n_hold_disable_msg)))
  DECLARE i18n_hold_disable_msg = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter has one or more holds preventing assignment",
    "Encounter has one or more holds preventing assignment"))
 ENDIF
 IF ( NOT (validate(i18n_hold_be_preference_msg)))
  DECLARE i18n_hold_be_preference_msg = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter has holds and billing entity prevent manual claim gen pref set.",
    "Encounter has holds and billing entity prevent manual claim generation preference is set."))
 ENDIF
 IF ( NOT (validate(i18n_encounter_in_pre_collection)))
  DECLARE i18n_encounter_in_pre_collection = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is assigned to pre-collections",
    "Encounter is assigned to pre-collections"))
 ENDIF
 IF ( NOT (validate(i18n_encounter_in_collection)))
  DECLARE i18n_encounter_in_collection = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is assigned to collections",
    "Encounter is assigned to collections"))
 ENDIF
 IF ( NOT (validate(i18n_encounter_not_in_collection)))
  DECLARE i18n_encounter_not_in_collection = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is Removed from collections",
    "Encounter is Removed from collections"))
 ENDIF
 IF ( NOT (validate(i18n_encounter_not_sent_to_collection)))
  DECLARE i18n_encounter_not_sent_to_collection = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is Not in collections","Encounter is Not in collections"))
 ENDIF
 IF ( NOT (validate(i18n_generate_claim)))
  DECLARE i18n_generate_claim = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance is not ready to bill.","Balance is not ready to bill."))
 ENDIF
 IF ( NOT (validate(i18n_generate_on_demand_statement)))
  DECLARE i18n_generate_on_demand_statement = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance is not ready to bill.","Balance is not ready to bill."))
 ENDIF
 IF ( NOT (validate(i18n_credit_charge_status)))
  DECLARE i18n_credit_charge_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Charge previously credited","Charge previously credited"))
 ENDIF
 IF ( NOT (validate(i18n_write_off_charge_status)))
  DECLARE i18n_write_off_charge_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Charge previously written off","Charge previously written off"))
 ENDIF
 IF ( NOT (validate(i18n_write_off_charge_credit_status)))
  DECLARE i18n_write_off_charge_credit_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.A credited charge cannot be written off",
    "A credited charge cannot be written off"))
 ENDIF
 IF ( NOT (validate(i18n_apply_comment_status)))
  DECLARE i18n_apply_comment_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Comment cannot be applied to a denial",
    "Comment cannot be applied to a denial"))
 ENDIF
 IF ( NOT (validate(i18n_transaction_transfered)))
  DECLARE i18n_transaction_transfered = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Transaction previously transfered","Transaction previously transfered"))
 ENDIF
 IF ( NOT (validate(i18n_reverse_trns_for_pay_adj_trans)))
  DECLARE i18n_reverse_trns_for_pay_adj_trans = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Reversal transactions cannot be transferred",
    "Reversal transactions cannot be transferred"))
 ENDIF
 IF ( NOT (validate(i18n_reverse_trns_for_pay_adj_reverse)))
  DECLARE i18n_reverse_trns_for_pay_adj_reverse = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Reversal transactions cannot be reversed",
    "Reversal transactions cannot be reversed"))
 ENDIF
 IF ( NOT (validate(i18n_bad_deb_recovery_adj)))
  DECLARE i18n_bad_deb_recovery_adj = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bad debt recovery cannot be manually transferred",
    "Bad debt recovery cannot be manually transferred"))
 ENDIF
 IF ( NOT (validate(i18n_bad_deb_reversal_adj)))
  DECLARE i18n_bad_deb_reversal_adj = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bad debt reversal cannot be transferred",
    "Bad debt reversal cannot be transferred"))
 ENDIF
 IF ( NOT (validate(i18n_bad_deb_reversal_rev)))
  DECLARE i18n_bad_deb_reversal_rev = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bad debt reversal cannot be reversed",
    "Bad debt reversal cannot be reversed"))
 ENDIF
 IF ( NOT (validate(i18n_reversal_bankruptcy_writeoff)))
  DECLARE i18n_reversal_bankruptcy_writeoff = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bankruptcy write-off cannot be reversed",
    "Bankruptcy write-off cannot be reversed"))
 ENDIF
 IF ( NOT (validate(i18n_reversal_bankruptcy_reversal)))
  DECLARE i18n_reversal_bankruptcy_reversal = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bankruptcy reversal cannot be reversed",
    "Bankruptcy reversal cannot be reversed"))
 ENDIF
 IF ( NOT (validate(i18n_bankruptcy_writeoff)))
  DECLARE i18n_bankruptcy_writeoff = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bankruptcy write-off cannot be transferred",
    "Bankruptcy write-off cannot be transferred"))
 ENDIF
 IF ( NOT (validate(i18n_bankruptcy_reversal)))
  DECLARE i18n_bankruptcy_reversal = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bankruptcy reversal cannot be transferred",
    "Bankruptcy reversal cannot be transferred"))
 ENDIF
 IF ( NOT (validate(i18n_trans_already_transfered)))
  DECLARE i18n_trans_already_transfered = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Transaction previously transferred","Transaction previously transferred")
   )
 ENDIF
 IF ( NOT (validate(i18n_trans_already_reversed)))
  DECLARE i18n_trans_already_reversed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Transaction previously reversed","Transaction previously reversed"))
 ENDIF
 IF ( NOT (validate(i18n_no_to_balances)))
  DECLARE i18n_no_to_balances = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.There are no balances to transfer to.",
    "There are no balances to transfer to."))
 ENDIF
 IF ( NOT (validate(i18n_balance_zero)))
  DECLARE i18n_balance_zero = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is zero.","The balance is zero."))
 ENDIF
 IF ( NOT (validate(i18n_no_alias_to_modify)))
  DECLARE i18n_no_alias_to_modify = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No alias to modify","No alias to modify"))
 ENDIF
 IF ( NOT (validate(i18n_no_unbilled_late_charges)))
  DECLARE i18n_no_unbilled_late_charges = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No unbilled late charges","No unbilled late charges"))
 ENDIF
 IF ( NOT (validate(i18n_no_unbilled_charges)))
  DECLARE i18n_no_unbilled_charges = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No unbilled charges","No unbilled charges"))
 ENDIF
 IF ( NOT (validate(i18n_balance_canceled)))
  DECLARE i18n_balance_canceled = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Associated balance is canceled or invalid.",
    "Associated balance is canceled or invalid."))
 ENDIF
 IF ( NOT (validate(i18n_billed_charge)))
  DECLARE i18n_billed_charge = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Charge has been billed.","Charge has been billed."))
 ENDIF
 IF ( NOT (validate(i18n_selfpay_only_charge)))
  DECLARE i18n_selfpay_only_charge = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Charge is associated to Self Pay Charge Group Only.",
    "Charge is associated to Self Pay Charge Group Only."))
 ENDIF
 IF ( NOT (validate(i18n_remittance_zero_payment)))
  DECLARE i18n_remittance_zero_payment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Remittance with a zero payment amount",
    "Remittance with a zero payment amount"))
 ENDIF
 IF ( NOT (validate(i18n_denial)))
  DECLARE i18n_denial = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Denial","Denial"))
 ENDIF
 IF ( NOT (validate(i18n_remove_charge_batch)))
  DECLARE i18n_remove_charge_batch = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Cannot delete a posted or submitted batch",
    "Cannot delete a posted or submitted batch"))
 ENDIF
 IF ( NOT (validate(i18n_unsupported_task)))
  DECLARE i18n_unsupported_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The task is unsupported.","The task is unsupported."))
 ENDIF
 IF ( NOT (validate(i18n_ime_apply_adjustment_task)))
  DECLARE i18n_ime_apply_adjustment_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Adjustment can not be applied to IME claims.",
    "Adjustment can not be applied to IME claims."))
 ENDIF
 IF ( NOT (validate(i18n_ime_apply_comment_task)))
  DECLARE i18n_ime_apply_comment_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Comment can not be applied to IME claims.",
    "Comment can not be applied to IME claims."))
 ENDIF
 IF ( NOT (validate(i18n_ime_apply_action_code_task)))
  DECLARE i18n_ime_apply_action_code_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Action code can not applied to IME claims.",
    "Action code can not applied to IME claims."))
 ENDIF
 IF ( NOT (validate(i18n_ime_apply_remark_task)))
  DECLARE i18n_ime_apply_remark_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Remark can not be applied to IME claims.",
    "Remark can not be applied to IME claims."))
 ENDIF
 IF ( NOT (validate(i18n_corsp_not_cancelled)))
  DECLARE i18n_corsp_not_cancelled = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Correspondence not in cancellable status.",
    "Correspondence not in cancellable status."))
 ENDIF
 IF ( NOT (validate(i18n_corsp_not_delivered)))
  DECLARE i18n_corsp_not_delivered = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Correspondence not in delivered status.",
    "Correspondence not in delivered status."))
 ENDIF
 IF ( NOT (validate(i18n_encounter_has_baddebt_or_in_coll)))
  DECLARE i18n_encounter_has_baddebt_or_in_coll = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter has bad debt or in collections.",
    "Encounter has bad debt or in collections."))
 ENDIF
 IF ( NOT (validate(i18n_encounter_already_combined_away)))
  DECLARE i18n_encounter_already_combined_away = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is already combined away.",
    "Encounter is already combined away."))
 ENDIF
 IF ( NOT (validate(i18n_pending_reg_mod_hold)))
  DECLARE i18n_pending_reg_mod_hold = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The pending registration modification hold cannot be released.",
    "The pending registration modification hold cannot be released."))
 ENDIF
 IF ( NOT (validate(i18n_encounter_already_packaged)))
  DECLARE i18n_encounter_already_packaged = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is already packaged.","Encounter is already packaged."))
 ENDIF
 IF ( NOT (validate(i18n_statement_cycle_is_workflow_model)))
  DECLARE i18n_statement_cycle_is_workflow_model = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Statement cycle is being managed by a workflow model. See Workflow view.",
    "Statement cycle is being managed by a workflow model. See Workflow view."))
 ENDIF
 IF ( NOT (validate(i18n_pharmanet_charge)))
  DECLARE i18n_pharmanet_charge = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Disabling the task as it is a PharmaNet charge.",
    "Disabling the task as it is a PharmaNet charge."))
 ENDIF
 IF ( NOT (validate(i18n_corsp_img_not_available)))
  DECLARE i18n_corsp_img_not_available = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Correspondence image is not available.",
    "Correspondence image is not available."))
 ENDIF
 IF ( NOT (validate(i18n_posted_unbilled)))
  DECLARE i18n_posted_unbilled = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Posted - Unbilled","Posted - Unbilled"))
 ENDIF
 IF ( NOT (validate(i18n_posted_billed)))
  DECLARE i18n_posted_billed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Posted - Billed","Posted - Billed"))
 ENDIF
 IF ( NOT (validate(i18n_posted_suppressed)))
  DECLARE i18n_posted_suppressed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Posted - Suppressed","Posted - Suppressed"))
 ENDIF
 IF ( NOT (validate(i18n_credited_billed)))
  DECLARE i18n_credited_billed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Credited - Billed","Credited - Billed"))
 ENDIF
 IF ( NOT (validate(i18n_credited_suppressed)))
  DECLARE i18n_credited_suppressed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Credited - Suppressed","Credited - Suppressed"))
 ENDIF
 IF ( NOT (validate(i18n_written_off_unbilled)))
  DECLARE i18n_written_off_unbilled = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Written Off - Unbilled","Written Off - Unbilled"))
 ENDIF
 IF ( NOT (validate(i18n_written_off_billed)))
  DECLARE i18n_written_off_billed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Written Off - Billed","Written Off - Billed"))
 ENDIF
 IF ( NOT (validate(i18n_adjusted_unbilled)))
  DECLARE i18n_adjusted_unbilled = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Adjusted - Unbilled","Adjusted - Unbilled"))
 ENDIF
 IF ( NOT (validate(i18n_adjusted_billed)))
  DECLARE i18n_adjusted_billed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Adjusted - Billed","Adjusted - Billed"))
 ENDIF
 IF ( NOT (validate(i18n_late_debit)))
  DECLARE i18n_late_debit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Late Debit","Late Debit"))
 ENDIF
 IF ( NOT (validate(i18n_late_credit)))
  DECLARE i18n_late_credit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Late Credit","Late Credit"))
 ENDIF
 IF ( NOT (validate(i18n_late_debit_late_credit)))
  DECLARE i18n_late_debit_late_credit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Late Debit / Late Credit","Late Debit / Late Credit"))
 ENDIF
 IF ( NOT (validate(i18n_add_billing_hold)))
  DECLARE i18n_add_billing_hold = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Cannot apply a billing hold to a self pay balance",
    "Cannot apply a billing hold to a self pay balance"))
 ENDIF
 IF ( NOT (validate(i18n_self_pay)))
  DECLARE i18n_self_pay = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Self Pay","Self Pay"))
 ENDIF
 IF ( NOT (validate(i18n_ime)))
  DECLARE i18n_ime = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.IME",
    "IME"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_primary)))
  DECLARE i18n_sequence_primary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Primary","Primary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_secondary)))
  DECLARE i18n_sequence_secondary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Secondary","Secondary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_tertiary)))
  DECLARE i18n_sequence_tertiary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Tertiary","Tertiary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_quaternary)))
  DECLARE i18n_sequence_quaternary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Quaternary","Quaternary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_quinary)))
  DECLARE i18n_sequence_quinary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Quinary","Quinary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_senary)))
  DECLARE i18n_sequence_senary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Senary","Senary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_unknown)))
  DECLARE i18n_sequence_unknown = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Unknown","Unknown"))
 ENDIF
 IF ( NOT (validate(i18n_claim_not_cancelable)))
  DECLARE i18n_claim_not_cancelable = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Claim not in cancelable status","Claim not in cancelable status"))
 ENDIF
 IF ( NOT (validate(i18n_claim_not_replaceble)))
  DECLARE i18n_claim_not_replaceble = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Claim not in a replaceble status","Claim not in a replaceble status"))
 ENDIF
 IF ( NOT (validate(i18n_claim_not_deniable)))
  DECLARE i18n_claim_not_deniable = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Claim not in deniable status","Claim not in deniable status"))
 ENDIF
 IF ( NOT (validate(i18n_claim_not_voidable)))
  DECLARE i18n_claim_not_voidable = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Claim not in a voidable status","Claim not in a voidable status"))
 ENDIF
 IF ( NOT (validate(i18n_no_pricing_detail)))
  DECLARE i18n_no_pricing_detail = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No external identifier found for transaction. Cannot view Pricing Detail.",
    "No external identifier found for transaction. Cannot view Pricing Detail."))
 ENDIF
 IF ( NOT (validate(i18n_no_apply_remark)))
  DECLARE i18n_no_apply_remark = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Remark cannot be applied on Cancelled/Denied/Rejected claim or self",
    "Remark cannot be applied on Cancelled/Denied/Rejected claim or selfpay claims or invalid/cancelled balance."
    ))
 ENDIF
 IF ( NOT (validate(i18n_move_chrg_no_qual_chrg)))
  DECLARE i18n_move_chrg_no_qual_chrg = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No qualifying charges on the source financial encounter.",
    "No qualifying charges on the source financial encounter."))
 ENDIF
 IF ( NOT (validate(i18n_move_chrg_no_enc_reltn)))
  DECLARE i18n_move_chrg_no_enc_reltn = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.There is no relationship between selected encounters",
    "There is no relationship between selected encounters. Unable to move charges."))
 ENDIF
 IF ( NOT (validate(i18n_move_chrg_same_encntrs)))
  DECLARE i18n_move_chrg_same_encntrs = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Same source and target clinical encounters.",
    "Same source and target clinical encounters."))
 ENDIF
 IF ( NOT (validate(i18n_move_chrg_credit)))
  DECLARE i18n_move_chrg_credit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Cannot move a credited charge.","Cannot move a credited charge."))
 ENDIF
 IF ( NOT (validate(i18n_modify_chrg_credit)))
  DECLARE i18n_modify_chrg_credit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Cannot modify a credited charge.","Cannot modify a credited charge."))
 ENDIF
 IF ( NOT (validate(i18n_invalid_balance)))
  DECLARE i18n_invalid_balance = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Voided","Voided"))
 ENDIF
 IF ( NOT (validate(i18n_task_system_error)))
  DECLARE i18n_task_system_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.A system error occurred.","A system error occurred."))
 ENDIF
 IF ( NOT (validate(i18n_separator_semicolon)))
  DECLARE i18n_separator_semicolon = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.SEMICOLON","; "))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_error)))
  DECLARE i18n_task_compl_bal_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The system is unable to complete the balance.",
    "The system is unable to complete the balance."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_not_insurance)))
  DECLARE i18n_task_compl_bal_not_insurance = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is not an insurance balance.",
    "The balance is not an insurance balance."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_invalid_status)))
  DECLARE i18n_task_compl_bal_invalid_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is not currently in a status that can be set as Complete.",
    "The balance is not currently in a status that can be set as Complete."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_next_bal_invalid_status)))
  DECLARE i18n_task_compl_bal_next_bal_invalid_status = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The next balance in the coord of benefits cant be set to Rdy2Bill.",
    "The next balance in the coordination of benefits cannot be set to a Ready to Bill status."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_remaining_credit_amt)))
  DECLARE i18n_task_compl_bal_remaining_credit_amt = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a remaining credit amount.",
    "The balance has a remaining credit amount."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_encntr_hist)))
  DECLARE i18n_task_compl_bal_encntr_hist = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is associated to an encounter in history.",
    "The balance is associated to an encounter in history."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_claim_den_pend_rev)))
  DECLARE i18n_task_compl_bal_claim_den_pend_rev = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance has a claim in a Denied Pending Review status.",
    "The balance has a claim in a Denied Pending Review status."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_success)))
  DECLARE i18n_task_compl_bal_success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance was successfully completed.",
    "The balance was successfully completed."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_error)))
  DECLARE i18n_task_set_bal_rtb_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The system is unable to set the balance as Ready to Bill.",
    "The system is unable to set the balance as Ready to Bill."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_invalid_status)))
  DECLARE i18n_task_set_bal_rtb_invalid_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is not currently in a status that can be set as Ready to Bill.",
    "The balance is not currently in a status that can be set as Ready to Bill."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_remaining_credit_amt)))
  DECLARE i18n_task_set_bal_rtb_remaining_credit_amt = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a remaining credit amount.",
    "The balance has a remaining credit amount."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_encntr_hist)))
  DECLARE i18n_task_set_bal_rtb_encntr_hist = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is associated to an encounter in history.",
    "The balance is associated to an encounter in history."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_claim_den_pend_rev)))
  DECLARE i18n_task_set_bal_rtb_claim_den_pend_rev = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a claim in a Denied Pending Review status.",
    "The balance has a claim in a Denied Pending Review status."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_success)))
  DECLARE i18n_task_set_bal_rtb_success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance status was successfully set as Ready to Bill.",
    "The balance status was successfully set as Ready to Bill."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_error)))
  DECLARE i18n_task_set_bal_wpbc_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The system is unable to set the balance as Waiting Prev Bal Compl",
    "The system is unable to set the balance as Waiting Previous Balance Completion."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_invalid_status)))
  DECLARE i18n_task_set_bal_wpbc_invalid_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is not in a status that can be set as Waiting Prev Bal Compl",
    "The balance is not currently in a status that can be set as Waiting Previous Balance Completion."
    ))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_remaining_credit_amt)))
  DECLARE i18n_task_set_bal_wpbc_remaining_credit_amt = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a remaining credit amount.",
    "The balance has a remaining credit amount."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_encntr_hist)))
  DECLARE i18n_task_set_bal_wpbc_encntr_hist = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is associated to an encounter in history.",
    "The balance is associated to an encounter in history."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_claim_den_pend_rev)))
  DECLARE i18n_task_set_bal_wpbc_claim_den_pend_rev = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a claim in a Denied Pending Review status.",
    "The balance has a claim in a Denied Pending Review status."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_success)))
  DECLARE i18n_task_set_bal_wpbc_success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance status was successfully set as Waiting Prev Bal Compl",
    "The balance status was successfully set as Waiting Previous Balance Completion."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_error)))
  DECLARE i18n_task_set_bal_generated_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The system is unable to set the balance as Generated.",
    "The system is unable to set the balance as Generated."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_invalid_status)))
  DECLARE i18n_task_set_bal_generated_invalid_status = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is not in a status that can be set as Waiting Prev Bal Compl",
    "The balance is not currently in a status that can be set as Waiting Previous Balance Completion."
    ))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_remaining_credit_amt)))
  DECLARE i18n_task_set_bal_generated_remaining_credit_amt = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a remaining credit amount.",
    "The balance has a remaining credit amount."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_encntr_hist)))
  DECLARE i18n_task_set_bal_generated_encntr_hist = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance is associated to an encounter in history.",
    "The balance is associated to an encounter in history."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_claim_den_pend_rev)))
  DECLARE i18n_task_set_bal_generated_claim_den_pend_rev = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance has a claim in a Denied Pending Review status.",
    "The balance has a claim in a Denied Pending Review status."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_no_claim)))
  DECLARE i18n_task_set_bal_generated_no_claim = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance does not currently have a valid claim.",
    "The balance does not currently have a valid claim."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_success)))
  DECLARE i18n_task_set_bal_generated_success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance status was successfully set as Generated.",
    "The balance status was successfully set as Generated."))
 ENDIF
 IF ( NOT (validate(i18n_task_generate_interim_not_available)))
  DECLARE i18n_task_generate_interim_not_available = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The task is not allowed","The task is not allowed"))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_late_charges_claim_den_pend_rev)))
  DECLARE i18n_task_bill_late_charges_claim_den_pend_rev = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance has a claim in a Denied Pending Review status.",
    "The balance has a claim in a Denied Pending Review status."))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_late_charges_encntr_hist)))
  DECLARE i18n_task_bill_late_charges_encntr_hist = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance is associated to an encounter in history.",
    "The balance is associated to an encounter in history."))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_late_charges_error)))
  DECLARE i18n_task_bill_late_charges_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The system is unable to bill late charges.",
    "The system is unable to bill late charges."))
 ENDIF
 IF ( NOT (validate(i18n_task_associate_bal_not_institutional)))
  DECLARE i18n_task_associate_bal_not_institutional = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance is not an institutional balance.",
    "The balance is not an institutional balance."))
 ENDIF
 IF ( NOT (validate(i18n_task_associate_bal_already_billed)))
  DECLARE i18n_task_associate_bal_already_billed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The intitutional balance has already been billed.",
    "The intitutional balance has already been billed."))
 ENDIF
 IF ( NOT (validate(i18n_task_associate_bal_no_professional)))
  DECLARE i18n_task_associate_bal_no_professional = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.There are no professional balances to associate to.",
    "There are no professional balances to associate to."))
 ENDIF
 IF ( NOT (validate(billing_with_professional)))
  DECLARE billing_with_professional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.billing_with_professional","Billing With Professional"))
 ENDIF
 IF ( NOT (validate(billing_on_institutional)))
  DECLARE billing_on_institutional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.billing_on_institutional","Billing On Institutional"))
 ENDIF
 IF ( NOT (validate(billing_with_institutional)))
  DECLARE billing_with_institutional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.billing_with_institutional","Billing With Institutional"))
 ENDIF
 IF ( NOT (validate(billing_on_professional)))
  DECLARE billing_on_professional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.billing_on_professional","Billing On Professional"))
 ENDIF
 IF ( NOT (validate(i18n_assoc_bal_ins_error)))
  DECLARE i18n_assoc_bal_ins_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.assocBalInsError",
    "A system error has occurred. Unable to associate balances for billing."))
 ENDIF
 IF ( NOT (validate(i18n_assoc_bal_upt_error)))
  DECLARE i18n_assoc_bal_upt_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.assocBalUptError",
    "A system error has occurred. Unable to update balance associations for billing."))
 ENDIF
 IF ( NOT (validate(i18n_assoc_bal_success)))
  DECLARE i18n_assoc_bal_success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.assocBalSuccess","Balance associations saved."))
 ENDIF
 IF ( NOT (validate(i18n_task_balance_associated_error)))
  DECLARE i18n_task_balance_associated_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance association made.","Balance association made."))
 ENDIF
 IF ( NOT (validate(i18n_uploaded_via_batch)))
  DECLARE i18n_uploaded_via_batch = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Uploaded via batch","Uploaded via batch"))
 ENDIF
 IF ( NOT (validate(i18n_task_mod_pat_resp_no_single_group_per_cg)))
  DECLARE i18n_task_mod_pat_resp_no_single_group_per_cg = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance must be associated to single-charge charge group",
    "Balance must be associated to single-charge charge group"))
 ENDIF
 IF ( NOT (validate(i18n_task_mod_pat_resp_self_pay)))
  DECLARE i18n_task_mod_pat_resp_self_pay = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Cannot modify patient responsibility for self pay balance",
    "Cannot modify patient responsibility for self pay balance"))
 ENDIF
 IF ( NOT (validate(i18n_task_mod_pat_resp_invalid_cg_status)))
  DECLARE i18n_task_mod_pat_resp_invalid_cg_status = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.Charge group is in an invalid status",
    "Charge group is in an invalid status"))
 ENDIF
 IF ( NOT (validate(i18n_task_mod_pat_resp_invalid_balance_status)))
  DECLARE i18n_task_mod_pat_resp_invalid_balance_status = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.Balance is in an invalid status",
    "Balance is in an invalid status"))
 ENDIF
 IF ( NOT (validate(i18n_task_image_action_unauthorized)))
  DECLARE i18n_task_image_action_unauthorized = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Image action unauthorized for user.",
    "Image action unauthorized for user."))
 ENDIF
 IF ( NOT (validate(i18n_ime_add_image_task)))
  DECLARE i18n_ime_add_image_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Image can not be added to IME claims.",
    "Image can not be added to IME claims."))
 ENDIF
 IF ( NOT (validate(i18n_view_batch_submitted)))
  DECLARE i18n_view_batch_submitted = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.BATCH_SUBMITTED","Waiting to Post"))
 ENDIF
 IF ( NOT (validate(i18n_view_batch_presubmit)))
  DECLARE i18n_view_batch_presubmit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.BATCH_PRESUBMIT","Pre-Submit"))
 ENDIF
 IF ( NOT (validate(i18n_view_batch_posted)))
  DECLARE i18n_view_batch_posted = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.BATCH_POSTED","Posted"))
 ENDIF
 IF ( NOT (validate(i18n_view_batch_pending)))
  DECLARE i18n_view_batch_pending = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.BATCH_PENDING","Open"))
 ENDIF
 IF ( NOT (validate(i18n_view_batch_errored)))
  DECLARE i18n_view_batch_errored = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.BATCH_ERRORED","In Error"))
 ENDIF
 IF ( NOT (validate(i18n_task_cancelbatchtask)))
  DECLARE i18n_task_cancelbatchtask = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.TASK_CANCEL_BATCH","Cancel Remittance"))
 ENDIF
 IF ( NOT (validate(i18n_system)))
  DECLARE i18n_system = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.LABEL_SYSTEM","System"))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_as_prof_error)))
  DECLARE i18n_task_bill_as_prof_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance cannot be billed as professional.",
    "Balance cannot be billed as professional."))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_as_ins_error)))
  DECLARE i18n_task_bill_as_ins_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance cannot be billed as institutional.",
    "Balance cannot be billed as institutional."))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_as_prof_or_ins_error)))
  DECLARE i18n_task_bill_as_prof_or_ins_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance is not in a status to be billed.",
    "Balance is not in a status to be billed."))
 ENDIF
 IF ( NOT (validate(i18n_refund)))
  DECLARE i18n_refund = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Refund","Refund"))
 ENDIF
 IF ( NOT (validate(i18n_refund_id)))
  DECLARE i18n_refund_id = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Refund Id","Refund Id"))
 ENDIF
 IF ( NOT (validate(i18n_refund_amt)))
  DECLARE i18n_refund_amt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Refund Amount","Refund Amount"))
 ENDIF
 IF ( NOT (validate(i18n_voided_refund_payment_desc)))
  DECLARE i18n_voided_refund_payment_desc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Payment to Offset Voided Refund, Refund Id:",
    "Payment to Offset Voided Refund, Refund Id:"))
 ENDIF
 IF ( NOT (validate(i18n_reminder_title)))
  DECLARE i18n_reminder_title = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.REMINDER_TITLE","Reminder"))
 ENDIF
 IF ( NOT (validate(i18n_escalation_title)))
  DECLARE i18n_escalation_title = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ESCALATION_TITLE","Escalation"))
 ENDIF
 IF ( NOT (validate(i18n_reminder_reason_label)))
  DECLARE i18n_reminder_reason_label = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.REMINDER_REASON_LABEL","Reminder Reason:"))
 ENDIF
 IF ( NOT (validate(i18n_escalation_reason_label)))
  DECLARE i18n_escalation_reason_label = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ESCALATION_REASON_LABEL","Escalation Reason:"))
 ENDIF
 IF ( NOT (validate(i18n_reminder_reason_assignee)))
  DECLARE i18n_reminder_reason_assignee = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.REMINDER_REASON_ASSIGNEE","Reminder for assignee of work item"))
 ENDIF
 IF ( NOT (validate(i18n_escalation_reason)))
  DECLARE i18n_escalation_reason = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ESCALATION_REASON","Escalation for incomplete work item"))
 ENDIF
 IF ( NOT (validate(i18n_reminder_message)))
  DECLARE i18n_reminder_message = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.REMINDER_MESSAGE","Reminder: Work Item Overdue"))
 ENDIF
 IF ( NOT (validate(i18n_escalation_message)))
  DECLARE i18n_escalation_message = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ESCALATION_MESSAGE","Escalation: Work Item Overdue"))
 ENDIF
 IF ( NOT (validate(i18n_escalation_text)))
  DECLARE i18n_escalation_text = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ESCALATION_TEXT","ESCALATION: Work Item Overdue for"))
 ENDIF
 IF ( NOT (validate(i18n_resolver_label)))
  DECLARE i18n_resolver_label = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.RESOLVER_LABEL","Resolver:"))
 ENDIF
 IF ( NOT (validate(i18n_auto_approve_failure_workitem_description)))
  DECLARE i18n_auto_approve_failure_workitem_description = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.AUTO_APPROVE_FAILURE_WORKITEM_DESCRIPTION",
    "Adjustment in pending due to failure of WTP auto-approval"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_missing_payee_id_description)))
  DECLARE i18n_fsi_missing_payee_id_description = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.FSI_MISSING_PAYEE_ID_DESCRIPTION","Missing Payee Id"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_fail_locate_logical_domain_description)))
  DECLARE i18n_fsi_fail_locate_logical_domain_description = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.FSI_FAIL_LOCATE_LOGICAL_DOMAIN_DESCRIPTION",
    "Unable to find organization Logical domain"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_fail_set_logical_domain_description)))
  DECLARE i18n_fsi_fail_set_logical_domain_description = vc WITH protect, constant(uar_i18ngetmessage
   (hi18n,"PFT_RCA_I18N_CONSTANTS.FSI_FAIL_SET_LOGICAL_DOMAIN_DESCRIPTION",
    "Failed to set the logical domain"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_fail_missing_payee_and_health_plan_id_description)))
  DECLARE i18n_fsi_fail_missing_payee_and_health_plan_id_description = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.FSI_FAIL_MISSING_PAYEE_AND_HEALTH_PLAN_ID_DESCRIPTION",
    "Missing Payer ID and Health Plan ID"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_fail_find_gl_ar_acct_description)))
  DECLARE i18n_fsi_fail_find_gl_ar_acct_description = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.FSI_FAIL_FIND_GL_AR_ACCT_DESCRIPTION",
    "Unable to Find General A/R Account information"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_fail_find_non_gl_ar_acct_description)))
  DECLARE i18n_fsi_fail_find_non_gl_ar_acct_description = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.FSI_FAIL_FIND_NON_GL_AR_ACCT_DESCRIPTION",
    "Unable to Find Non A/R GL Account information"))
 ENDIF
 CALL echo("End PFT_RCA_I18N_CONSTANTS.INC")
 IF ( NOT (validate(i18n_workflow_model)))
  DECLARE i18n_workflow_model = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.WORKFLOW_MODEL","Workflow Model: "))
 ENDIF
 IF ( NOT (validate(i18n_reset_status)))
  DECLARE i18n_reset_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.RESET_STATUS","model has been Reset."))
 ENDIF
 IF ( NOT (validate(i18n_resume_status)))
  DECLARE i18n_resume_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.RESUME_STATUS","model has been Resumed."))
 ENDIF
 IF ( NOT (validate(i18n_pause_status)))
  DECLARE i18n_pause_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.PAUSE_STATUS","model has been Paused."))
 ENDIF
 IF ( NOT (validate(i18n_cancel_status)))
  DECLARE i18n_cancel_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.CANCEL_STATUS","model has been Cancelled."))
 ENDIF
 IF ( NOT (validate(i18n_complete_status)))
  DECLARE i18n_complete_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.COMPLETE_STATUS","model completed."))
 ENDIF
 IF ( NOT (validate(i18n_workflow_event)))
  DECLARE i18n_workflow_event = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.WORKFLOW_EVENT","Workflow Event : "))
 ENDIF
 IF ( NOT (validate(i18n_error_cancelling_workflow)))
  DECLARE i18n_error_cancelling_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_CANCELLING_WORKFLOW","Workflow Error Occurred Cancelling Workflow")
   )
 ENDIF
 IF ( NOT (validate(i18n_error_resetting_workflow)))
  DECLARE i18n_error_resetting_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_RESETTING_WORKFLOW","Workflow Error Occurred Resetting Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_error_resuming_workflow)))
  DECLARE i18n_error_resuming_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_RESUMING_WORKFLOW","Workflow Error Occurred Resuming Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_error_pausing_workflow)))
  DECLARE i18n_error_pausing_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_PAUSING_WORKFLOW","Workflow Error Occurred Pausing Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_error_starting_workflow)))
  DECLARE i18n_error_starting_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_STARTING_WORKFLOW","Workflow Error Occurred Starting Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_error_progressing_workflow)))
  DECLARE i18n_error_progressing_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_PROGRESSING_WORKFLOW",
    "Workflow Error Occurred Progressing Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_error_publishing_workflow)))
  DECLARE i18n_error_publishing_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_PUBLISHING_WORKFLOW","Workflow Error Occurred Publishing Workflow")
   )
 ENDIF
 IF ( NOT (validate(i18n_error_handling_workflow)))
  DECLARE i18n_error_handling_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_HANDLING_WORKFLOW","Workflow Error Occurred Handling Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_autoactionerror_handling_workflow)))
  DECLARE i18n_autoactionerror_handling_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.AUTOACTIONERROR_HANDLING_WORKFLOW","Automated Action Error"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_default_description)))
  DECLARE i18n_workflow_error_default_description = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.WORKFLOW_ERROR_DEFAULT_DESCRIPTION",
    "Workflow Action Error Occurred"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_default_comment)))
  DECLARE i18n_workflow_error_default_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.WORKFLOW_ERROR_DEFAULT_COMMENT","Model Unidentified"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_cancel_resolution)))
  DECLARE i18n_workflow_error_cancel_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_CANCEL_RESOLUTION",
    "Manually cancel the workflow using the cancel task"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_pause_resolution)))
  DECLARE i18n_workflow_error_pause_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_PAUSE_RESOLUTION",
    "Manually pause the workflow using the pause task"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_progress_resolution)))
  DECLARE i18n_workflow_error_progress_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_PROGRESS_RESOLUTION",
    "Manually cancel the workflow, then use the Identify Work item functionality to identify the next work item in the flow"
    ))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_publish_resolution)))
  DECLARE i18n_workflow_error_publish_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_PUBLISH_RESOLUTION",
    "Manually start the workflow using the Identify Work Item functionality"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_reset_resolution)))
  DECLARE i18n_workflow_error_reset_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_RESET_RESOLUTION",
    "Manually reset the workflow using the reset task"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_resume_resolution)))
  DECLARE i18n_workflow_error_resume_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_RESUME_RESOLUTION",
    "Manually resume the workflow using the resume task"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_start_resolution)))
  DECLARE i18n_workflow_error_start_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_START_RESOLUTION",
    "Manually start the workflow using the Identify Work Item functionalilty"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_handle_resolution)))
  DECLARE i18n_workflow_error_handle_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_HANDLE_RESOLUTION","Handle Error Resolution Text."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_down)))
  DECLARE i18n_pharmacy_claim_server_down = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_DOWN",
    "Pharmacy claims query service is down or not responding."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_returned_invalid)))
  DECLARE i18n_pharmacy_claim_server_returned_invalid = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_RETURNED_INVALID",
    "Pharmacy claims server returned invalid claims."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_error)))
  DECLARE i18n_pharmacy_claim_server_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_ERROR",
    "Pharmacy claims server failed with error : "))
 ENDIF
 IF ( NOT (validate(i18n_faux_claim_creation_failed)))
  DECLARE i18n_faux_claim_creation_failed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_FAUX_CLAIM_CREATION_FAILED","Creation of faux claim returned error."
    ))
 ENDIF
 IF ( NOT (validate(i18n_faux_claim_canceled_failed)))
  DECLARE i18n_faux_claim_canceled_failed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_FAUX_CLAIM_CANCELED_FAILED",
    "Cancelling a faux claim returned error."))
 ENDIF
 IF ( NOT (validate(i18n_balance_status_update_failed)))
  DECLARE i18n_balance_status_update_failed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_BALANCE_STATUS_UPDATE_FAILED",
    "Failed to update the balance status to generated."))
 ENDIF
 IF ( NOT (validate(i18n_health_plans_not_matched)))
  DECLARE i18n_health_plans_not_matched = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_HEALTH_PLANS_NOT_MATCHED",
    "Health plans on pharmacy claims did not match with that on encounter."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_down_resolution)))
  DECLARE i18n_pharmacy_claim_server_down_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_DOWN_RESOLUTION",
    "Verify if Pharmacy claims server is running."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_returned_invalid_resolution)))
  DECLARE i18n_pharmacy_claim_server_returned_invalid_resolution = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_RETURNED_INVALID_RESOLUTION",
    "Verify if the external master event id sent to Pharmacy claims server is valid."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_error_resolution)))
  DECLARE i18n_pharmacy_claim_server_error_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_ERROR_RESOLUTION",
    "Pharmacy claims server is throwing an error that has to be resolved."))
 ENDIF
 IF ( NOT (validate(i18n_faux_claim_creation_failed_resolution)))
  DECLARE i18n_faux_claim_creation_failed_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_FAUX_CLAIM_CREATION_FAILED_RESOLUTION",
    "Verify if the claims returned from pharmacy server are valid."))
 ENDIF
 IF ( NOT (validate(i18n_faux_claim_canceled_failed_resolution)))
  DECLARE i18n_faux_claim_canceled_failed_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_FAUX_CLAIM_CANCELED_FAILED_RESOLUTION",
    "Verify if the claim status is valid for canceling."))
 ENDIF
 IF ( NOT (validate(i18n_balance_status_update_failed_resolution)))
  DECLARE i18n_balance_status_update_failed_resolution = vc WITH protect, constant(uar_i18ngetmessage
   (hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_BALANCE_STATUS_UPDATE_FAILED_RESOLUTION",
    "Verify if the balance is in valid state."))
 ENDIF
 IF ( NOT (validate(i18n_health_plans_not_matched_resolution)))
  DECLARE i18n_health_plans_not_matched_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_HEALTH_PLANS_NOT_MATCHED_RESOLUTION",
    "Verify if all the health plans are added to the encounter."))
 ENDIF
 IF ( NOT (validate(i18n_actioncode_alias_inuse)))
  DECLARE i18n_actioncode_alias_inuse = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ACTIONCODE_ALIAS_INUSE",
    "The alias is already in use. Please enter a unique alias."))
 ENDIF
 IF ( NOT (validate(i18n_actioncode_name_inuse)))
  DECLARE i18n_actioncode_name_inuse = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ACTIONCODE_NAME_INUSE",
    "The name is already in use. Please enter a unique name."))
 ENDIF
 IF ( NOT (validate(i18n_workitem_workflow_status)))
  DECLARE i18n_workitem_workflow_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKITEM_WORKFLOW_STATUS","WorkItem with Workflow Status"))
 ENDIF
 IF ( NOT (validate(i18n_assigned_from)))
  DECLARE i18n_assigned_from = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ASSIGNED_FROM","Assigned from"))
 ENDIF
 IF ( NOT (validate(i18n_assigned_to)))
  DECLARE i18n_assigned_to = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ASSIGNED_TO","Assigned to"))
 ENDIF
 IF ( NOT (validate(i18n_final_coding_upt)))
  DECLARE i18n_final_coding_upt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_FINAL_CODING_UPT",
    "Final coding has been updated after billing has been initiated. Please review to ensure the proper DRG."
    ))
 ENDIF
 IF ( NOT (validate(i18n_other)))
  DECLARE i18n_other = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.OTHER","Other"))
 ENDIF
 IF ( NOT (validate(i18n_adjustmentapproval)))
  DECLARE i18n_adjustmentapproval = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ADJUSTMENTAPPROVAL","Adjustment Approval"))
 ENDIF
 IF ( NOT (validate(i18n_statementgeneration)))
  DECLARE i18n_statementgeneration = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_STATEMENTGENERATION","Statement Generation"))
 ENDIF
 IF ( NOT (validate(i18n_assign_fpp_by_external_system)))
  DECLARE i18n_assign_fpp_by_external_system = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ASSIGN_FPP_BY_EXTERNAL_SYSTEM","Formal payment plan assigned by :"))
 ENDIF
 IF ( NOT (validate(i18n_modify_fpp_by_external_system)))
  DECLARE i18n_modify_fpp_by_external_system = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_MODIFY_FPP_BY_EXTERNAL_SYSTEM","Formal payment plan modified by :"))
 ENDIF
 IF ( NOT (validate(i18n_remove_fpp_by_external_system)))
  DECLARE i18n_remove_fpp_by_external_system = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_REMOVE_FPP_BY_EXTERNAL_SYSTEM","Formal payment plan removed by :"))
 ENDIF
 IF ( NOT (validate(i18n_stmtsuppressionaddedforextfpp)))
  DECLARE i18n_stmtsuppressionaddedforextfpp = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_STMTSUPPRESSIONADDEDFOREXTFPP",
    "Statement Suppression Billing Hold applied."))
 ENDIF
 IF ( NOT (validate(i18n_stmtsuppressionremovedforextfpp)))
  DECLARE i18n_stmtsuppressionremovedforextfpp = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_STMTSUPPRESSIONREMOVEDFOREXTFPP",
    "Statement Suppression Billing Hold removed."))
 ENDIF
 IF ( NOT (validate(i18n_extfppassignedforenc)))
  DECLARE i18n_extfppassignedforenc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_EXTFPPASSIGNEDFORENC",
    "External Payment Plan assigned for encounter."))
 ENDIF
 IF ( NOT (validate(i18n_task_send_bal_to_collections)))
  DECLARE i18n_task_send_bal_to_collections = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_TASK_SEND_BAL_TO_COLLECTIONS",
    "Cannot send balance to collection as dunning track is not at balance level"))
 ENDIF
 IF ( NOT (validate(i18n_task_modifystatementcycle_bal)))
  DECLARE i18n_task_modifystatementcycle_bal = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_TASK_MODIFYSTATEMENTCYCLE_BAL",
    "Cannot apply statement cycle to balance as dunning track is not at balance level"))
 ENDIF
 IF ( NOT (validate(i18n_transfer_of)))
  DECLARE i18n_transfer_of = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Transfer of","Transfer of"))
 ENDIF
 IF ( NOT (validate(i18n_with_alias)))
  DECLARE i18n_with_alias = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.with alias","with alias"))
 ENDIF
 IF ( NOT (validate(i18n_originally_posted)))
  DECLARE i18n_originally_posted = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.originally posted","originally posted"))
 ENDIF
 IF ( NOT (validate(i18n_with_posted_date_of)))
  DECLARE i18n_with_posted_date_of = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.with a posted date of","with a posted date of"))
 ENDIF
 IF ( NOT (validate(i18n_for_amount_of)))
  DECLARE i18n_for_amount_of = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.for the amount of","for the amount of"))
 ENDIF
 IF ( NOT (validate(i18n_from_account)))
  DECLARE i18n_from_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.from account","from account"))
 ENDIF
 IF ( NOT (validate(i18n_to_account)))
  DECLARE i18n_to_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.to account","to account"))
 ENDIF
 IF ( NOT (validate(i18n_health_plan)))
  DECLARE i18n_health_plan = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.health plan","health plan"))
 ENDIF
 IF ( NOT (validate(i18n_performed_by)))
  DECLARE i18n_performed_by = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.performed by","performed by"))
 ENDIF
 IF ( NOT (validate(i18n_on)))
  DECLARE i18n_on = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.on",
    "on"))
 ENDIF
 DECLARE curinsbalid = f8 WITH protect, noconstant(0.0)
 DECLARE curinsbaluptcnt = i4 WITH protect, noconstant(0)
 DECLARE curinsbalstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE pftencntrid = f8 WITH protect, noconstant(0.0)
 DECLARE accountid = f8 WITH protect, noconstant(0.0)
 SUBROUTINE (getcurrentbostatus(pbohpid=f8,oldstatuscd=f8(ref)) =i2)
   SELECT INTO "nl:"
    FROM bo_hp_reltn bhr
    WHERE bhr.bo_hp_reltn_id=pbohpid
     AND bhr.active_ind=true
    DETAIL
     oldstatuscd = bhr.bo_hp_status_cd
    WITH nocounter
   ;end select
   IF (oldstatuscd != 0.0)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE (createactivityforbalstatuschng(curstatus=f8,pbohpid=f8,voidind=i2(value,false)) =i2)
   RECORD activityreq(
     1 activitytypecd = f8
     1 activityspecificattributes[*]
       2 name = vc
       2 value = vc
     1 relatedentities[*]
       2 relationship = vc
       2 entityid = f8
   ) WITH protect
   RECORD activityrep(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SELECT INTO "nl:"
    FROM bo_hp_reltn bhr,
     benefit_order bo,
     pft_encntr pe
    PLAN (bhr
     WHERE bhr.bo_hp_reltn_id=pbohpid
      AND bhr.active_ind=true)
     JOIN (bo
     WHERE bo.benefit_order_id=bhr.benefit_order_id
      AND bo.active_ind=true)
     JOIN (pe
     WHERE pe.pft_encntr_id=bo.pft_encntr_id
      AND pe.active_ind=true)
    DETAIL
     curinsbalid = bhr.bo_hp_reltn_id, curinsbaluptcnt = bhr.updt_cnt, curinsbalstatuscd = bhr
     .bo_hp_status_cd,
     pftencntrid = pe.pft_encntr_id, accountid = pe.acct_id
    WITH nocounter
   ;end select
   IF (curqual != 0)
    SET stat = alterlist(activityreq->relatedentities,3)
    SET stat = alterlist(activityreq->activityspecificattributes,2)
    SET activityreq->activitytypecd = cs18689_balstatchg_cd
    SET activityreq->activityspecificattributes[1].name = attr_bal_orig_status
    SET activityreq->activityspecificattributes[1].value = uar_get_code_display(curstatus)
    SET activityreq->activityspecificattributes[2].name = attr_bal_new_status
    IF (voidind=false)
     SET activityreq->activityspecificattributes[2].value = uar_get_code_display(curinsbalstatuscd)
    ELSE
     SET activityreq->activityspecificattributes[2].value = i18n_invalid_balance
    ENDIF
    SET activityreq->relatedentities[1].relationship = reltn_account
    SET activityreq->relatedentities[1].entityid = accountid
    SET activityreq->relatedentities[2].relationship = reltn_fin_encounter
    SET activityreq->relatedentities[2].entityid = pftencntrid
    SET activityreq->relatedentities[3].relationship = reltn_balance
    SET activityreq->relatedentities[3].entityid = curinsbalid
    EXECUTE pft_create_activity  WITH replace("REQUEST",activityreq), replace("REPLY",activityrep)
    IF ((activityrep->status_data.status != "S"))
     CALL echorecord(activityrep)
     CALL echorecord(activityreq)
     RETURN(false)
    ENDIF
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE (getaccountid(pft_encntr_id=f8,activityacctid=f8(ref)) =i2)
   SELECT INTO "nl:"
    FROM pft_encntr pe
    WHERE pe.pft_encntr_id=pft_encntr_id
     AND pe.active_ind=true
    DETAIL
     activityacctid = pe.acct_id
    WITH nocounter
   ;end select
   IF (activityacctid != 0.0)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 DECLARE doldhealthplanid = f8 WITH public, noconstant(0.0)
 DECLARE dnewhealthplanid = f8 WITH public, noconstant(0.0)
 DECLARE dorigquantity = f8 WITH public, noconstant(0.0)
 DECLARE dcalculatedquantity = f8 WITH public, noconstant(0.0)
 DECLARE doldchargetypecd = f8 WITH public, noconstant(0.0)
 DECLARE dcredittypecd = f8 WITH public, noconstant(0.0)
 DECLARE ddebittypecd = f8 WITH public, noconstant(0.0)
 DECLARE dcreditnowtypecd = f8 WITH public, noconstant(0.0)
 DECLARE dchargetypecd = f8 WITH public, noconstant(0.0)
 DECLARE dreprocesscd = f8 WITH public, noconstant(0.0)
 DECLARE dpromptcd = f8 WITH public, noconstant(0.0)
 DECLARE dsuspensecd = f8 WITH public, noconstant(0.0)
 DECLARE dnopatrespcd = f8 WITH public, noconstant(0.0)
 DECLARE dpromptqtycd = f8 WITH public, noconstant(0.0)
 DECLARE dpftencntrid = f8 WITH public, noconstant(0.0)
 DECLARE dwfeventcd = f8 WITH public, noconstant(0.0)
 DECLARE dwfencntrcd = f8 WITH public, noconstant(0.0)
 DECLARE dwfdemmodcd = f8 WITH public, noconstant(0.0)
 DECLARE dwfcompleteeventcd = f8 WITH public, noconstant(0.0)
 DECLARE dwfinsurancecd = f8 WITH public, noconstant(0.0)
 DECLARE dpataccttypecd = f8 WITH public, noconstant(0.0)
 DECLARE dnonconsenccd = f8 WITH public, noconstant(0.0)
 DECLARE dguarantorcd = f8 WITH public, noconstant(0.0)
 DECLARE dpatstmtcd = f8 WITH public, noconstant(0.0)
 DECLARE dselfpayfccd = f8 WITH public, noconstant(0.0)
 DECLARE dinvalidcd = f8 WITH public, noconstant(0.0)
 DECLARE dbillingcombinecd = f8 WITH public, noconstant(0.0)
 DECLARE dstdelayrefcd = f8 WITH publci, noconstant(0.0)
 DECLARE dcomfromcd = f8 WITH public, noconstant(0.0)
 DECLARE dencntrtypecd = f8 WITH public, noconstant(0.0)
 DECLARE dhealthplancd = f8 WITH public, noconstant(0.0)
 DECLARE dbillcombholdcd = f8 WITH public, noconstant(0.0)
 DECLARE dstdelaycd = f8 WITH public, noconstant(0.0)
 DECLARE demadjcd = f8 WITH public, noconstant(0.0)
 DECLARE dexpreimadjcd = f8 WITH public, noconstant(0.0)
 DECLARE ddefaultspid = f8 WITH public, noconstant(0.0)
 DECLARE dcanceledcd = f8 WITH public, noconstant(0.0)
 DECLARE dtransmittebycrosscd = f8 WITH public, noconstant(0.0)
 DECLARE dsubmittedcd = f8 WITH public, noconstant(0.0)
 DECLARE dreadytobillcd = f8 WITH public, noconstant(0.0)
 DECLARE dwtgforpriorcd = f8 WITH public, noconstant(0.0)
 DECLARE dgeneratedcd = f8 WITH public, noconstant(0.0)
 DECLARE dcompletecd = f8 WITH public, noconstant(0.0)
 DECLARE dreadytobillcd = f8 WITH public, noconstant(0.0)
 DECLARE dhpmodhold = f8 WITH public, noconstant(0.0)
 DECLARE dpatientprocd = f8 WITH public, noconstant(0.0)
 DECLARE dtempbohpstatus = f8 WITH public, noconstant(0.0)
 DECLARE dtransmittedcd = f8 WITH public, noconstant(0.0)
 DECLARE ddeniedcd = f8 WITH public, noconstant(0.0)
 DECLARE ddeniedreviewcd = f8 WITH public, noconstant(0.0)
 DECLARE dtranbycrosscd = f8 WITH public, noconstant(0.0)
 DECLARE dwaitingforcrosscd = f8 WITH public, noconstant(0.0)
 DECLARE dhistorycd = f8 WITH public, noconstant(0.0)
 DECLARE dpendingcd = f8 WITH public, noconstant(0.0)
 DECLARE dinvalidboclm = f8 WITH public, noconstant(0.0)
 DECLARE dinactiveboclm = f8 WITH public, noconstant(0.0)
 DECLARE dselfpaytranbal = f8 WITH public, noconstant(0.0)
 DECLARE dreadytosubmitcd = f8 WITH public, noconstant(0.0)
 DECLARE dautocancelcd = f8 WITH public, noconstant(0.0)
 DECLARE lcereprocesscnt = i4 WITH public, noconstant(0)
 DECLARE lceareprocesscnt = i4 WITH public, noconstant(0)
 DECLARE nnewchargeevent = i2 WITH public, noconstant(0)
 DECLARE nnewchargeeventact = i2 WITH public, noconstant(0)
 DECLARE nneedtoretier = i2 WITH public, noconstant(0)
 DECLARE nneedtocheckprice = i2 WITH public, noconstant(0)
 DECLARE nfinclasschange = i2 WITH public, noconstant(0)
 DECLARE nencntrtypechange = i2 WITH public, noconstant(0)
 DECLARE nlocationchange = i2 WITH public, noconstant(0)
 DECLARE nhpexpirelogicvar = i2 WITH public, noconstant(0)
 DECLARE nchrgcnt = i4 WITH public, noconstant(0)
 DECLARE nchrgmodcnt = i4 WITH public, noconstant(0)
 DECLARE nchrgloop = i4 WITH public, noconstant(0)
 DECLARE nsocloop = i4 WITH public, noconstant(0)
 DECLARE nmodloop = i4 WITH public, noconstant(0)
 DECLARE nmodloop2 = i4 WITH public, noconstant(0)
 DECLARE nreprocessloop = i4 WITH public, noconstant(0)
 DECLARE nreprocessloop2 = i4 WITH public, noconstant(0)
 DECLARE npatientresponsibilityneeded = i2 WITH public, noconstant(0)
 DECLARE nntcnt = i2 WITH public, noconstant(0)
 DECLARE nntallcnt = i2 WITH public, noconstant(0)
 DECLARE nfoundbillrec = i2 WITH public, noconstant(0)
 DECLARE ncount1 = i4 WITH public, noconstant(0)
 DECLARE npecnt1 = i4 WITH public, noconstant(0)
 DECLARE nfinclassuptind = i2 WITH public, noconstant(0)
 DECLARE nacctreltnguarind = i2 WITH public, noconstant(0)
 DECLARE nguarchgind = i2 WITH public, noconstant(0)
 DECLARE nnewcbosind = i2 WITH public, noconstant(0)
 DECLARE nuptcbosind = i2 WITH public, noconstant(0)
 DECLARE ninitcycleind = i2 WITH public, noconstant(0)
 DECLARE npecnt2 = i4 WITH public, noconstant(0)
 DECLARE neprcnt = i4 WITH public, noconstant(0)
 DECLARE nhpcnt = i4 WITH public, noconstant(0)
 DECLARE nbohpcnt = i4 WITH public, noconstant(0)
 DECLARE nnonprimarymod = i2 WITH public, noconstant(0)
 DECLARE nsendpecnt = i4 WITH public, noconstant(0)
 DECLARE nmatchpeacct = i4 WITH public, noconstant(0)
 DECLARE ncovind = i2 WITH public, noconstant(0)
 DECLARE ncovbit = i2 WITH public, noconstant(0)
 DECLARE nspchanged = i2 WITH public, noconstant(0)
 DECLARE nstmtcnt = i2 WITH public, noconstant(0)
 DECLARE bstatusmatch = i4 WITH public, noconstant(0)
 DECLARE nselfpayfound = i4 WITH public, noconstant(0)
 DECLARE nbocnt = i4 WITH public, noconstant(0)
 DECLARE npesize = i4 WITH public, noconstant(0)
 DECLARE nbosize = i4 WITH public, noconstant(0)
 DECLARE nselfpayindex = i4 WITH public, noconstant(0)
 DECLARE ninvalidbocnt = i4 WITH public, noconstant(0)
 DECLARE nstopmatch = i4 WITH public, noconstant(0)
 DECLARE dcalculatedprice = f8 WITH public, noconstant(0.0)
 DECLARE scomment = c250 WITH public, noconstant("")
 DECLARE appid = i4 WITH public, noconstant(0)
 DECLARE taskid = i4 WITH public, noconstant(0)
 DECLARE reqid = i4 WITH public, noconstant(0)
 DECLARE happ = i4 WITH public, noconstant(0)
 DECLARE htask = i4 WITH public, noconstant(0)
 DECLARE hreq = i4 WITH public, noconstant(0)
 DECLARE hrequest = i4 WITH public, noconstant(0)
 DECLARE hlist1 = i4 WITH public, noconstant(0)
 DECLARE hlist2 = i4 WITH public, noconstant(0)
 DECLARE hreply = i4 WITH public, noconstant(0)
 DECLARE hcharge = i4 WITH public, noconstant(0)
 DECLARE crmstatus = i4 WITH public, noconstant(0)
 DECLARE lcreprocesscnt = i4 WITH public, noconstant(0)
 DECLARE npostrelntcnt = i2 WITH public, noconstant(0)
 DECLARE dencntrmodsuspensecd = f8 WITH public, noconstant(0.0)
 DECLARE lpftencntrcount = i4 WITH public, noconstant(0)
 DECLARE lrelholdcount = i4 WITH public, noconstant(0)
 DECLARE nprimarymod = i2 WITH public, noconstant(0)
 DECLARE nprimaryhpmod = i2 WITH public, noconstant(0)
 DECLARE nsecondmod = i2 WITH public, noconstant(0)
 DECLARE ntertmod = i2 WITH public, noconstant(0)
 DECLARE npriexistclincob = i2 WITH public, noconstant(0)
 DECLARE npriexistfincob = i2 WITH public, noconstant(0)
 DECLARE nsecexistclincob = i2 WITH public, noconstant(0)
 DECLARE nsecexistfincob = i2 WITH public, noconstant(0)
 DECLARE nsecspclincob = i2 WITH public, noconstant(0)
 DECLARE nsecspfincob = i2 WITH public, noconstant(0)
 DECLARE nterexistclincob = i2 WITH public, noconstant(0)
 DECLARE nterexistfincob = i2 WITH public, noconstant(0)
 DECLARE nterspclincob = i2 WITH public, noconstant(0)
 DECLARE nterspfincob = i2 WITH public, noconstant(0)
 DECLARE nprispclincob = i2 WITH public, noconstant(0)
 DECLARE nprispfincob = i2 WITH public, noconstant(0)
 DECLARE md1450cd = f8 WITH public, noconstant(0.0)
 DECLARE md1500cd = f8 WITH public, noconstant(0.0)
 DECLARE dreportclaimcd = f8 WITH public, noconstant(0.0)
 DECLARE nsecondarymod = i2 WITH public, noconstant(0)
 DECLARE nrecurrenctypecd = f8 WITH public, noconstant(0.0)
 DECLARE nrecurrenctypeclasscd = f8 WITH public, noconstant(0.0)
 DECLARE dskillednursecd = f8 WITH public, noconstant(0.0)
 DECLARE dnorugcd = f8 WITH public, noconstant(0.0)
 DECLARE dbadrugdaycd = f8 WITH public, noconstant(0.0)
 DECLARE derrrugcd = f8 WITH public, noconstant(0.0)
 DECLARE dclientacctcd = f8 WITH public, noconstant(0.0)
 DECLARE mdclientbilltypecd = f8 WITH public, noconstant(0.0)
 DECLARE mdpatientbilltypecd = f8 WITH public, noconstant(0.0)
 DECLARE uptbohpcnt = i4
 DECLARE ninvalidboexist = i4
 DECLARE mdbillactcd = f8 WITH public, noconstant(0.0)
 DECLARE nnprolledspind = i2 WITH public, noconstant(0)
 DECLARE mdcptcd = f8 WITH public, noconstant(0.0)
 DECLARE mdhpexpirelogic = f8 WITH public, noconstant(0.0)
 DECLARE mdbillcodecd = f8 WITH public, noconstant(0.0)
 DECLARE mdaracct = f8 WITH public, noconstant(0.0)
 DECLARE mdpatient = f8 WITH public, noconstant(0.0)
 DECLARE mdnocommitcd = f8 WITH public, noconstant(0.0)
 DECLARE dpmactivitytypecd = f8 WITH noconstant(0.0)
 DECLARE ncommentqual = i4 WITH noconstant(0)
 DECLARE primaryhp_overlap_ind = i2 WITH noconstant(0)
 DECLARE stm_cycle_assigned_ind = i2 WITH noconstant(0)
 DECLARE copylistindex = i4 WITH noconstant(0)
 DECLARE chargemodindex = i4 WITH noconstant(0)
 DECLARE interfaceindex = i4 WITH noconstant(0)
 DECLARE flexrecurmod = i2 WITH noconstant(0)
 DECLARE mcobcnt = i4 WITH protect, noconstant(0)
 DECLARE mpeidx = i4 WITH protect, noconstant(0)
 DECLARE mpeid = f8 WITH protect, noconstant(0.0)
 DECLARE dtempdate = f8 WITH protect, noconstant(0.0)
 DECLARE mnewhpid = f8 WITH protect, noconstant(0.0)
 DECLARE err_unknown = i2 WITH protect, constant(1)
 DECLARE mprioritycnt = i4 WITH protect, noconstant(0)
 DECLARE mcobidx = i4 WITH protect, noconstant(0)
 DECLARE boverlap = i2 WITH protect, noconstant(false)
 DECLARE voidedclaimcount = i4 WITH protect, noconstant(0)
 DECLARE isvoidedclaimfound = i2 WITH protect, noconstant(false)
 DECLARE num = i4 WITH protect, noconstant(0)
 RECORD voidedclaimslist(
   1 claims[*]
     2 corspactivityid = f8
 )
 SET mdnocommitcd = uar_get_code_by("MEANING",13029,"NOCOMMIT")
 CALL echo(build("NOCOMMIT:  ",mdnocommitcd))
 DECLARE lrulesetidx = i4 WITH public, noconstant(0)
 IF ((validate(deditpending24450cd,- (1))=- (1)))
  DECLARE deditpending24450cd = f8 WITH public, noconstant(0.0)
 ENDIF
 SET stat = uar_get_meaning_by_codeset(24450,"EDITPENDING",1,deditpending24450cd)
 DECLARE neditpendinfoundind = i2 WITH public, noconstant(0)
 DECLARE nwfcfoundind = i2 WITH public, noconstant(0)
 IF ((validate(dwaitforcoding24450cd,- (1))=- (1)))
  DECLARE dwaitforcoding24450cd = f8 WITH public, noconstant(0.0)
 ENDIF
 SET stat = uar_get_meaning_by_codeset(24450,"WAITCODING",1,dwaitforcoding24450cd)
 DECLARE cs18935_submitted_cd = f8 WITH noconstant(getcodevalue(18935,"SUBMITTED",1))
 DECLARE cs18935_transmitted_cd = f8 WITH noconstant(getcodevalue(18935,"TRANSMITTED",1))
 DECLARE cs18935_denied_cd = f8 WITH noconstant(getcodevalue(18935,"DENIED",1))
 DECLARE cs18935_deniedreview_cd = f8 WITH noconstant(getcodevalue(18935,"DENIEDREVIEW",1))
 IF ( NOT (validate(cs18935_canceled_cd)))
  DECLARE cs18935_canceled_cd = f8 WITH protect, constant(getcodevalue(18935,"CANCELED",0))
 ENDIF
 IF ( NOT (validate(cs22089_voided_cd)))
  DECLARE cs22089_voided_cd = f8 WITH protect, constant(getcodevalue(22089,"VOIDED",0))
 ENDIF
 DECLARE oldstatuscd = f8 WITH protect, noconstant(0.0)
 SET appid = 951020
 SET taskid = 951020
 SET reqid = 951359
 SET happ = 0
 SET htask = 0
 SET hreq = 0
 SET hrequest = 0
 SET hlist1 = 0
 SET hlist2 = 0
 SET hreply = 0
 SET hcharge = 0
 SET crmstatus = 0
 SET action_begin = 1
 SET action_end = 1
 DECLARE checkhpexpirelogic(dummyt) = i2
 DECLARE checkhpexpireforrecur(dummyt) = i2
 DECLARE fetchfincharges(chrgcnt=i4) = i2
 DECLARE processprimarychangesp(dummy1) = i2
 DECLARE getcalculatedquantity(ncurcharge,dcurquantity) = f8
 DECLARE checkpatientresponsibility(ncurcharge) = i2
 DECLARE gethealthplanbypriority(npriorityseq=i4) = f8
 DECLARE getencounterinformation(dencntrid=f8) = i2
 DECLARE reevaluatecharges(dummy1) = i2
 DECLARE fetchnewselfpaybalance(dummyt) = f8
 DECLARE fetchspclinseq(hpcnt=i4) = i4
 DECLARE repostcharges(dummyt) = i2
 DECLARE reclassifygl(dummyt) = i2
 DECLARE evaluatebohpchanges(dummyvar) = i2
 DECLARE findfinencntrs(dummyvar) = i2
 DECLARE uptchargemodflag = i2
 DECLARE globalcount = i4
 DECLARE sameflag = i2
 SET stat = uar_get_meaning_by_codeset(13028,"CR",1,dcredittypecd)
 IF (dcredittypecd IN (0.0, null))
  CALL echo("dCreditTypeCD IS NULL")
  CALL logmsg(curprog,"dCreditTypeCD of codeset 13028 IS NULL",log_error)
  GO TO program_exit
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13028,"CREDIT NOW",1,dcreditnowtypecd)
 IF (dcreditnowtypecd IN (0.0, null))
  CALL echo("dCreditNowTypeCD IS NULL")
  CALL logmsg(curprog,"dCreditNowTypeCD of codeset 13028 IS NULL",log_error)
  GO TO program_exit
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13028,"DR",1,ddebittypecd)
 IF (ddebittypecd IN (0.0, null))
  CALL echo("dDebitTypeCD IS NULL")
  CALL logmsg(curprog,"dDebitTypeCD of codeset 13028 IS NULL",log_error)
  GO TO program_exit
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13029,"RELEASED",1,dreprocesscd)
 IF (dreprocesscd IN (0.0, null))
  CALL echo("dReprocessCD IS NULL")
  CALL logmsg(curprog,"dReprocessCD of codeset 13029 IS NULL",log_error)
  GO TO program_exit
 ENDIF
 SET reproc_request->process_type_cd = dreprocesscd
 SET stat = uar_get_meaning_by_codeset(13019,"PROMPT",1,dpromptcd)
 IF (dpromptcd IN (0.0, null))
  CALL echo("dPromptCD IS NULL")
  CALL logmsg(curprog,"dPromptCD of codeset 13019 IS NULL",log_error)
  GO TO program_exit
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13019,"SUSPENSE",1,dsuspensecd)
 IF (dsuspensecd IN (0.0, null))
  CALL echo("dSuspenseCD IS NULL")
  CALL logmsg(curprog,"dSuspenseCD of codeset 13019 IS NULL",log_error)
  GO TO program_exit
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13030,"NOPATRESP",1,dnopatrespcd)
 IF (dnopatrespcd IN (0.0, null))
  CALL echo("dNoPatRespCD IS NULL")
  CALL logmsg(curprog,"dNoPatRespCD of codeset 13030 IS NULL",log_error)
  GO TO program_exit
 ENDIF
 SET stat = uar_get_meaning_by_codeset(305570,"QUANTITY",1,dpromptqtycd)
 IF (dpromptqtycd IN (0.0, null))
  CALL echo("dPromptQtyCD IS NULL")
  CALL logmsg(curprog,"dPromptQtyCD of codeset 305570 IS NULL",log_error)
  GO TO program_exit
 ENDIF
 SET stat = uar_get_meaning_by_codeset(354,"SELFPAY",1,dselfpayfccd)
 SET stat = uar_get_meaning_by_codeset(18649,"ADJUST",1,demadjcd)
 SET stat = uar_get_meaning_by_codeset(18935,"TRANSXOVRPAY",1,dtransmittebycrosscd)
 SET stat = uar_get_meaning_by_codeset(18935,"CANCELED",1,dcanceledcd)
 SET stat = uar_get_meaning_by_codeset(18935,"SUBMITTED",1,dsubmittedcd)
 SET stat = uar_get_meaning_by_codeset(18935,"TRANSMITTED",1,dtransmittedcd)
 SET stat = uar_get_meaning_by_codeset(18935,"DENIED",1,ddeniedcd)
 SET stat = uar_get_meaning_by_codeset(18935,"DENIEDREVIEW",1,ddeniedreviewcd)
 SET stat = uar_get_meaning_by_codeset(18935,"READYSUBMIT",1,dreadytosubmitcd)
 SET stat = uar_get_meaning_by_codeset(18936,"GUARANTOR",1,dguarantorcd)
 SET stat = uar_get_meaning_by_codeset(19049,"NONCONSENCNT",1,dnonconsenccd)
 SET stat = uar_get_meaning_by_codeset(20549,"EXP REIM ADJ",1,dexpreimadjcd)
 SET stat = uar_get_meaning_by_codeset(20849,"PATIENT",1,dpataccttypecd)
 SET stat = uar_get_meaning_by_codeset(21749,"PATIENT_STMT",1,dpatstmtcd)
 SET stat = uar_get_meaning_by_codeset(21749,"HCFA_1450",1,md1450cd)
 SET stat = uar_get_meaning_by_codeset(21749,"HCFA_1500",1,md1500cd)
 SET stat = uar_get_meaning_by_codeset(21749,"RPT_CLAIM",1,dreportclaimcd)
 SET stat = uar_get_meaning_by_codeset(22089,"AUTO CANCEL",1,dautocancelcd)
 SET stat = uar_get_meaning_by_codeset(24269,"HISTORY",1,dhistorycd)
 SET stat = uar_get_meaning_by_codeset(24269,"PENDING",1,dpendingcd)
 SET stat = uar_get_meaning_by_codeset(24450,"HPMODIFIED",1,dhpmodhold)
 SET stat = uar_get_meaning_by_codeset(24450,"BILLCOMBHOLD",1,dbillcombholdcd)
 SET stat = uar_get_meaning_by_codeset(24450,"STDDELAY",1,dstdelaycd)
 SET stat = uar_get_meaning_by_codeset(24450,"NORUGCODE",1,dnorugcd)
 SET stat = uar_get_meaning_by_codeset(24450,"BADRUGCDDAYS",1,dbadrugdaycd)
 SET stat = uar_get_meaning_by_codeset(24450,"ERR_RUGCD",1,derrrugcd)
 SET stat = uar_get_meaning_by_codeset(25872,"SKLD_NRSNG",1,dskillednursecd)
 SET stat = uar_get_meaning_by_codeset(24451,"INVALID",1,dinvalidcd)
 SET stat = uar_get_meaning_by_codeset(24451,"TRANSXOVRPAY",1,dtranbycrosscd)
 SET stat = uar_get_meaning_by_codeset(24451,"WAITCROSOVR",1,dwaitingforcrosscd)
 SET stat = uar_get_meaning_by_codeset(24451,"WAITBOCOMPL",1,dwtgforpriorcd)
 SET stat = uar_get_meaning_by_codeset(24451,"COMPLETE",1,dcompletecd)
 SET stat = uar_get_meaning_by_codeset(24451,"GENERATED",1,dgeneratedcd)
 SET stat = uar_get_meaning_by_codeset(24451,"READYTOBILL",1,dreadytobillcd)
 SET stat = uar_get_meaning_by_codeset(25872,"BILL_COMBINE",1,dbillingcombinecd)
 SET stat = uar_get_meaning_by_codeset(25872,"STND_DELAY",1,dstdelayrefcd)
 SET stat = uar_get_meaning_by_codeset(71,"RECURRING",1,nrecurrenctypecd)
 SET stat = uar_get_meaning_by_codeset(69,"RECURRING",1,nrecurrenctypeclasscd)
 SET stat = uar_get_meaning_by_codeset(26052,"CMBFRMENCTYP",1,dcomfromcd)
 SET stat = uar_get_meaning_by_codeset(26052,"ENCNTR_TYPE",1,dencntrtypecd)
 SET stat = uar_get_meaning_by_codeset(26052,"HEALTHPLAN",1,dhealthplancd)
 SET stat = uar_get_meaning_by_codeset(29920,"PATIENT",1,dpatientprocd)
 SET stat = uar_get_meaning_by_codeset(29320,"PFTENCNTR",1,dwfencntrcd)
 SET stat = uar_get_meaning_by_codeset(29320,"INSURANCE",1,dwfinsurancecd)
 SET stat = uar_get_meaning_by_codeset(29321,"DEMOMODS",1,dwfdemmodcd)
 SET stat = uar_get_meaning_by_codeset(29321,"COMPLETE",1,dwfcompleteeventcd)
 SET stat = uar_get_meaning_by_codeset(29322,"COMBHPMODENC",1,dwfeventcd)
 SET stat = uar_get_meaning_by_codeset(13030,"ENCNTRMOD",1,dencntrmodsuspensecd)
 SET stat = uar_get_meaning_by_codeset(24451,"READYTOBILL",1,dreadytobillcd)
 SET stat = uar_get_meaning_by_codeset(106,"PM",1,dpmactivitytypecd)
 SET stat = uar_get_meaning_by_codeset(20849,"CLIENT",1,dclientacctcd)
 SET stat = uar_get_meaning_by_codeset(22569,"CLIENT",1,mdclientbilltypecd)
 SET stat = uar_get_meaning_by_codeset(22569,"PATIENT",1,mdpatientbilltypecd)
 SET stat = uar_get_meaning_by_codeset(323570,"EOB_REM_AMT",1,mdbillactcd)
 SET stat = uar_get_meaning_by_codeset(14002,"CPT4",1,mdcptcd)
 SET stat = uar_get_meaning_by_codeset(13031,"HPEXPIRE",1,mdhpexpirelogic)
 SET stat = uar_get_meaning_by_codeset(13019,"BILL CODE",1,mdbillcodecd)
 SET stat = uar_get_meaning_by_codeset(18736,"A/R",1,mdaracct)
 IF ((request->transaction="UPDT"))
  CALL echo("TRANSACTION is UPDT")
  CALL logmsg(curprog,"TRANSACTION is UPDT",log_debug)
  CALL logmsg(curprog,build("START PROCESSING: ",format(cnvtdatetime(sysdate),"HH:MM:Ss;;M")),
   log_debug)
  IF ((request->o_fin_class_cd != request->n_fin_class_cd))
   SET nfinclasschange = 1
  ENDIF
  IF ((request->o_encntr_type_cd != request->n_encntr_type_cd))
   SET nencntrtypechange = 1
  ENDIF
  IF ((request->o_location_cd != request->n_location_cd))
   SET nneedtocheckprice = 1
   SET nlocationchange = 1
  ENDIF
  IF (((nfinclasschange=1) OR (nencntrtypechange=1)) )
   SET nneedtocheckprice = 1
   SET nprimarymod = 1
  ENDIF
  SET encounterrequest->objarray[1].encntr_id = request->o_encntr_id
  EXECUTE pft_clinical_encntr_find  WITH replace("REQUEST",encounterrequest), replace("OBJREPLY",
   replclinencobj), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   GO TO program_exit
  ENDIF
  SET reqclinchrgfind->encntr_id = request->o_encntr_id
  EXECUTE afc_charge_find  WITH replace("REQUEST",reqclinchrgfind), replace("REPLY",pmcharge)
  SET nhpexpirelogicvar = checkhpexpirelogic(1)
  CALL echo(build("nHPExpireLogicVar",nhpexpirelogicvar))
  IF (size(pmcharge->charge_items,5) > 0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(pmcharge->charge_items,5)))
    PLAN (d1
     WHERE  NOT ((pmcharge->charge_items[d1.seq].charge_type_cd IN (dcredittypecd, dcreditnowtypecd))
     )
      AND (pmcharge->charge_items[d1.seq].process_flg IN (0, 2, 3, 4, 8,
     100, 999))
      AND (pmcharge->charge_items[d1.seq].active_ind=1))
    ORDER BY pmcharge->charge_items[d1.seq].beg_effective_dt_tm DESC
    DETAIL
     doldhealthplanid = pmcharge->charge_items[d1.seq].health_plan_id
    WITH maxqual(d1,1), nocounter
   ;end select
   IF (nhpexpirelogicvar=1
    AND (replclinencobj->objarray[1].encntr_type_class_cd=nrecurrenctypeclasscd))
    CALL echo("Recurring and HP Expire turned on.")
    CALL checkhpexpireforrecur(1)
    CALL echo("Back from HPEXPIRE check")
   ELSEIF (1=checkhpmodfornonprofit(request->o_encntr_id,doldhealthplanid))
    SET nneedtocheckprice = 1
    SET nprimarymod = 1
    SET nprimaryhpmod = 1
    CALL echo("Not Recurring or no Hp Expire logic.")
   ENDIF
   EXECUTE afc_get_interface_file  WITH replace("REPLY",interfacefiles)
   IF ((interfacefiles->status_data.status != "S"))
    SET reply->status_data.status = interfacefiles->status_data.status
    GO TO program_exit
   ENDIF
   EXECUTE afc_chk_profit_install  WITH replace("REQUEST",afc_chk_profit_install_request), replace(
    "REPLY",em_afc_chk_profit_install_reply)
   CALL echo(build("nNeedToCheckPrice = ",nneedtocheckprice))
   IF (nneedtocheckprice=1)
    CALL processrecurring(0)
    CALL processcharges(pmcharge->charge_item_count)
    CALL getnewprices(pmcharge->charge_item_count)
   ENDIF
   CALL echo(build("nNeedToRetier = ",nneedtoretier))
   IF (nneedtoretier=1)
    CALL echo("Retiering")
    EXECUTE afc_get_person_encounter_info  WITH replace("REQUEST",encounterrequest), replace("REPLY",
     encounterreply)
    IF ((encounterreply->person_encounter_qual > 0))
     CALL echo("Retier")
     CALL retiercharges(pmcharge->charge_item_count)
    ELSE
     SET reply->status_data.status = "F"
     GO TO program_exit
    ENDIF
   ENDIF
  ENDIF
  IF (nfinclasschange=0
   AND nencntrtypechange=0)
   SET nprimarymod = 0
  ENDIF
  IF ((replclinencobj->objarray[1].encntr_type_class_cd=nrecurrenctypeclasscd)
   AND nhpexpirelogicvar=1)
   DECLARE nfecount = i4
   DECLARE nprihps = i4
   DECLARE nprihpupt = i4
   DECLARE neprcnt = i4
   SELECT INTO "nl:"
    FROM encounter e,
     pft_encntr pe,
     benefit_order bo,
     bo_hp_reltn bhr,
     encntr_plan_reltn epr
    PLAN (e
     WHERE (e.encntr_id=replclinencobj->objarray[1].encntr_id))
     JOIN (pe
     WHERE pe.encntr_id=e.encntr_id
      AND pe.pft_encntr_status_cd != dhistorycd
      AND pe.active_ind=1)
     JOIN (bo
     WHERE bo.pft_encntr_id=pe.pft_encntr_id
      AND bo.bo_status_cd != dinvalidcd
      AND bo.active_ind=1)
     JOIN (bhr
     WHERE bhr.benefit_order_id=bo.benefit_order_id
      AND bhr.priority_seq=1
      AND bhr.active_ind=1)
     JOIN (epr
     WHERE epr.encntr_plan_reltn_id=bhr.encntr_plan_reltn_id
      AND epr.priority_seq=1
      AND epr.encntr_plan_reltn_id > 0.0)
    ORDER BY epr.beg_effective_dt_tm
    HEAD REPORT
     nfecount = 0
    HEAD pe.pft_encntr_id
     CALL echo(build("pft_encntr_id, ",pe.pft_encntr_id)),
     CALL echo(build("epr id, ",epr.encntr_plan_reltn_id)), nprimaryhpfoundind = false,
     neprcnt += 1
     IF (month(e.disch_dt_tm)=pe.recur_current_month
      AND year(e.disch_dt_tm)=pe.recur_current_year)
      drecurdate = e.disch_dt_tm
     ELSE
      drecurdate = datetimefind(cnvtdatetime(cnvtdate(build(format(pe.recur_current_month,"##;P0"),
          "01",pe.recur_current_year)),0),"M","E","E")
     ENDIF
     IF (epr.active_ind=0)
      CALL echo("active ind = 0")
      FOR (nprihps = 1 TO size(tempprimaryhps->objarray,5))
       CALL echo("Primary HP's"),
       IF ((drecurdate >= tempprimaryhps->objarray[nprihps].fin_beg_effective_dt_tm)
        AND (drecurdate <= tempprimaryhps->objarray[nprihps].end_effective_dt_tm))
        IF ((tempprimaryhps->objarray[nprihps].health_plan_id != bhr.health_plan_id))
         CALL echo("add new encounter"), nfecount += 1, stat = alterlist(temprecurencntr->objarray,
          nfecount),
         temprecurencntr->objarray[nfecount].pft_encntr_id = pe.pft_encntr_id
        ELSE
         nprihpupt += 1, stat = alterlist(temprecbohpupt->objarray,nprihpupt), temprecbohpupt->
         objarray[nprihpupt].bo_hp_reltn_id = bhr.bo_hp_reltn_id,
         temprecbohpupt->objarray[nprihpupt].encntr_plan_reltn_id = tempprimaryhps->objarray[nprihps]
         .encntr_plan_reltn_id
        ENDIF
        nprimaryhpfoundind = true
       ENDIF
      ENDFOR
      IF ( NOT (nprimaryhpfoundind))
       CALL echo("add new encounter due to removal of primary insurance"), nfecount += 1, stat =
       alterlist(temprecurencntr->objarray,nfecount),
       temprecurencntr->objarray[nfecount].pft_encntr_id = pe.pft_encntr_id
      ENDIF
     ELSE
      IF ( NOT (drecurdate >= epr.beg_effective_dt_tm
       AND drecurdate <= epr.end_effective_dt_tm))
       nfecount += 1, stat = alterlist(temprecurencntr->objarray,nfecount), temprecurencntr->
       objarray[nfecount].pft_encntr_id = pe.pft_encntr_id
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (size(temprecbohpupt->objarray,5) > 0)
    CALL echo("Update for BoHps")
    UPDATE  FROM bo_hp_reltn bhr,
      (dummyt d  WITH seq = value(size(temprecbohpupt->objarray,5)))
     SET bhr.encntr_plan_reltn_id = temprecbohpupt->objarray[d.seq].encntr_plan_reltn_id
     PLAN (d)
      JOIN (bhr
      WHERE (bhr.bo_hp_reltn_id=temprecbohpupt->objarray[d.seq].bo_hp_reltn_id))
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "afc_encntr_mods"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Update Recurrng Encntr Plan Reltn"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Failed updating BOHP for New Encntr Plan Reltn"
     GO TO program_exit
    ENDIF
   ENDIF
   IF (size(temprecurencntr->objarray,5) > 0)
    SET nprimarymod = 1
   ENDIF
   IF (findfinencntrs(1)=false)
    GO TO program_exit
   ENDIF
   SET nsecondmod = 0
   SET ntertmod = 0
  ENDIF
  SET objpmhealthplan->ein_type = ein_cob
  SET objpmhealthplan->proxy_ind = 1
  EXECUTE pft_health_plan_find  WITH replace("REPLY",reply), replace("REQUEST",encounterrequest),
  replace("OBJREPLY",objpmhealthplan)
  IF ((reply->status_data.status="F"))
   GO TO program_exit
  ENDIF
  IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
  nhpexpirelogicvar != 1)) )
   CALL echo("Finding encounters after HP expire")
   IF (findfinencntrs(1)=false)
    GO TO program_exit
   ELSE
    SET nprimarymod = 1
   ENDIF
   IF (size(objfinencntrmod->objarray,5)=0)
    CALL repostcharges(1)
    GO TO program_exit
   ENDIF
   IF (size(objfinencntrmod->objarray,5)=0)
    CALL logmsg(curprog,"Could not locate pft_encntr related to a patient account. Exiting...",
     log_error)
    GO TO program_exit
   ENDIF
  ENDIF
  SET reqacctreq->objarray[1].pft_encntr_id = objfinencntrmod->objarray[1].pft_encntr_id
  SET objsingleacct->ein_type = ein_pft_encntr
  SET objsingleacct->proxy_ind = true
  EXECUTE pft_account_find  WITH replace("REPLY",reply), replace("REQUEST",reqacctreq), replace(
   "OBJREPLY",objsingleacct)
  IF ((reply->status_data.status="F"))
   CALL echo("PFT_ACCOUNT_FIND FAILED.")
   GO TO program_exit
  ELSEIF ((reply->status_data.status="Z"))
   CALL echo("PFT_ACCOUNT_FIND DIDN'T QUALIFY.")
   GO TO program_exit
  ENDIF
  SET objbenefitorderrep->ein_type = ein_pft_encntr
  EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod),
  replace("OBJREPLY",objbenefitorderrep)
  CALL echorecord(objbenefitorderrep)
  IF ((reply->status_data.status="F"))
   SET reply->status_data.status = "F"
   GO TO program_exit
  ELSEIF ((reply->status_data.status="Z"))
   SET reply->status_data.status = "Z"
   GO TO program_exit
  ENDIF
  IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
  nhpexpirelogicvar != 1)) )
   IF (nfinclasschange=0
    AND nencntrtypechange=0)
    SET nprimarymod = 0
   ENDIF
   CALL evaluatebohpchanges(0)
   CALL echo(build("Benefit Order Count = ",size(objbenefitorderrep->objarray,5)))
   CALL retrievefinancilcob(size(objbenefitorderrep->objarray,5))
   CALL evaluatecobchanges(size(objpmhealthplan->objarray,5),fincob->fincob_cnt)
  ENDIF
  CALL echo("Post Evaluating COB CHarges!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
  CALL echo(build("nPriExistFinCOB: ",npriexistfincob))
  CALL echo(build("nPriExistClinCOB: ",npriexistclincob))
  CALL echo(build("nPriSPFinCOB: ",nprispfincob))
  CALL echo(build("nPriSPClinCOB: ",nprispclincob))
  CALL echo(build("Primary Mod: ",nprimarymod))
  CALL echo(build("nSecExistFinCOB: ",nsecexistfincob))
  CALL echo(build("nSecExistClinCOB: ",nsecexistclincob))
  CALL echo(build("Secondary Mod: ",nsecondmod))
  CALL echo(build("Sedondary is SP for Clin: ",nsecspclincob))
  CALL echo(build("Sedondary is SP for Fin: ",nsecspfincob))
  CALL echo(build("nTerExistFinCOB: ",nterexistfincob))
  CALL echo(build("nTerExistClinCOB: ",nterexistclincob))
  CALL echo(build("Tertiary Mod: ",ntertmod))
  IF (nprimarymod=1)
   CALL echo(build("Primary Mod = ",nprimarymod))
   IF (((nprispfincob=1
    AND nprispclincob=1) OR (size(pmcharge->charge_items,5)=0)) )
    CALL processprimarychangesp(1)
   ELSE
    CALL processprimarychange(pmcharge->charge_item_count)
   ENDIF
   DECLARE peidx = i4 WITH protect, noconstant(0)
   FOR (peidx = 1 TO size(objfinencntrmod->objarray,5))
     IF ( NOT (cancelreportingclaims(objfinencntrmod->objarray[peidx].pft_encntr_id)))
      CALL echo("afc_encntr_mods::main::Call to cancelReportingClaims() failed.")
      SET reply->status_data.status = "F"
      GO TO program_exit
     ENDIF
   ENDFOR
   FOR (peidx = 1 TO size(objfinencntrmod->objarray,5))
     IF ( NOT (cancelselfpayclaims(objfinencntrmod->objarray[peidx].pft_encntr_id)))
      CALL echo("afc_encntr_mods::main::Call to cancelSelfpayClaims() failed.")
      SET reply->status_data.status = "F"
      GO TO program_exit
     ENDIF
   ENDFOR
   IF (nneedtoretier=1)
    CALL repostcharges(1)
   ENDIF
   CALL reclassifygl(1)
  ELSEIF (nsecondmod=1)
   CALL echo("Secondary Mod")
   CALL processsecchange(pmcharge->charge_item_count)
   CALL reevaluatecharges(0)
  ELSEIF (ntertmod=1)
   CALL echo("Tertiary Mod")
   CALL processtertchange(pmcharge->charge_item_count)
   CALL reevaluatecharges(0)
  ENDIF
  IF ((replclinencobj->objarray[1].encntr_type_class_cd=nrecurrenctypeclasscd)
   AND nhpexpirelogicvar=1)
   SET stat = initrec(temprecurencntr)
   SET stat = initrec(objuptboreq)
   IF (findfinencntrs(1)=false)
    GO TO program_exit
   ENDIF
   SET objbenefitorderrep->ein_type = ein_pft_encntr
   EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod),
   replace("OBJREPLY",objbenefitorderrep)
   CALL echorecord(objbenefitorderrep)
   IF ((reply->status_data.status="F"))
    SET reply->status_data.status = "F"
    GO TO program_exit
   ELSEIF ((reply->status_data.status="Z"))
    SET reply->status_data.status = "Z"
    GO TO program_exit
   ENDIF
   FOR (mpeidx = 1 TO size(objfinencntrmod->objarray,5))
     IF ((objfinencntrmod->objarray[mpeidx].pft_encntr_status_cd != dhistorycd))
      IF ((((objfinencntrmod->objarray[mpeidx].recur_current_month=0)) OR ((objfinencntrmod->
      objarray[mpeidx].recur_current_year=0)))
       AND (objfinencntrmod->objarray[mpeidx].pft_encntr_status_cd != dhistorycd))
       CALL echo("Improperly built recurring encounter.")
       SET reply->status_data.status = "F"
       GO TO program_exit
      ENDIF
      SET mpeid = objfinencntrmod->objarray[mpeidx].pft_encntr_id
      IF ((month(objfinencntrmod->objarray[mpeidx].disch_dt_tm)=objfinencntrmod->objarray[mpeidx].
      recur_current_month)
       AND (year(objfinencntrmod->objarray[mpeidx].disch_dt_tm)=objfinencntrmod->objarray[mpeidx].
      recur_current_year))
       SET dtempdate = objfinencntrmod->objarray[mpeidx].disch_dt_tm
      ELSE
       SET dtempdate = datetimefind(cnvtdatetime(cnvtdate2(concat(format(objfinencntrmod->objarray[
            mpeidx].recur_current_month,"##;P0"),"01",format(objfinencntrmod->objarray[mpeidx].
            recur_current_year,"####;P0")),"MMDDYYYY"),0),"M","E","E")
      ENDIF
      CALL echo(build("Non-Prim Expire PE_ID:",mpeid))
      CALL echo(build("Non-Prim Expire:",format(dtempdate,";;q")))
      IF ( NOT (getcurrentcob(request->o_encntr_id,dtempdate)))
       CALL echo("afc_encntr_mods::GetCurrentCOB failed.")
       CALL echo(currentcob->failure_message)
       CALL logmsg(curprog,currentcob->failure_message,log_error)
       IF ( NOT (applycommenttoencounteroutofprocess(mpeid,currentcob->failure_message)))
        CALL logmsg(curprog,build("Unable to add comment to financial encounter:",mpeid),log_error)
       ENDIF
       SET reply->status_data.status = "F"
       GO TO program_exit
      ENDIF
      CALL echorecord(currentcob)
      SET mnewhpid = 0.0
      CALL resethpflags(0)
      IF (hpexpireevalbo(objfinencntrmod->objarray[mpeidx].pft_encntr_id,2))
       CALL echo("afc_encntr_mods::Calling ProcessSecChange.")
       CALL processsecchange(2)
       CALL reevaluatecharges(0)
      ENDIF
      SET stat = initrec(objuptboreq)
      SET stat = initrec(objaddbo)
      SET mnewhpid = 0.0
      CALL resethpflags(0)
      IF (hpexpireevalbo(objfinencntrmod->objarray[mpeidx].pft_encntr_id,3))
       CALL echo("afc_encntr_mods::Calling ProcessTertHPExpire.")
       CALL processterthpexpire(3)
       CALL reevaluatecharges(0)
      ENDIF
      SET stat = initrec(currentcob)
      SET stat = initrec(objuptboreq)
      SET stat = initrec(objaddbo)
      SET stat = initrec(objbenefitorderrep)
      SET objbenefitorderrep->ein_type = ein_pft_encntr
      EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod),
      replace("OBJREPLY",objbenefitorderrep)
      CALL echorecord(objbenefitorderrep)
      IF ((reply->status_data.status="F"))
       SET reply->status_data.status = "F"
       GO TO program_exit
      ELSEIF ((reply->status_data.status="Z"))
       SET reply->status_data.status = "Z"
       GO TO program_exit
      ENDIF
     ENDIF
   ENDFOR
   CALL fixselfpaypriority(request->o_encntr_id)
   CALL echorecord(reply)
  ENDIF
  CALL echo("Before Guarantor Update")
  CALL echorecord(objfinencntrmod)
  CALL updateguarantor(0)
  IF (((nprimarymod=1) OR (((nguarchgind=1) OR (nnprolledspind=1)) )) )
   CALL echo("RemovePaymentPlans_begins nonrecurring")
   CALL removepaymentplans(0)
   CALL resetstmtcycles(size(objfinencntrmod->objarray,5))
  ENDIF
  IF (nneedtocheckprice=1)
   IF ( NOT (validate(em_afc_chk_profit_install_reply->profit_installed,- (1)) IN (0, - (1))))
    IF (nhpexpirelogicvar=1)
     CALL uptchargehp(0)
    ENDIF
   ENDIF
  ENDIF
  CALL publishworkflowevent(request->o_encntr_id)
  CALL echorecord(reply)
  GO TO program_exit
 ENDIF
 SUBROUTINE (fixselfpaypriority(encntrid=f8) =i2)
   FREE RECORD felist
   RECORD felist(
     1 cnt = i4
     1 list[*]
       2 pftencntrid = f8
       2 spbohpid = f8
       2 currentpriority = i4
       2 newpriority = i4
   )
   SELECT INTO "nl:"
    FROM pft_encntr pe,
     benefit_order bo,
     bo_hp_reltn bhr
    PLAN (pe
     WHERE pe.encntr_id=encntrid
      AND pe.active_ind=true
      AND pe.recur_current_month > 0
      AND pe.charge_balance > 0
      AND pe.pft_encntr_status_cd != dhistorycd)
     JOIN (bo
     WHERE bo.pft_encntr_id=pe.pft_encntr_id
      AND bo.active_ind=true
      AND bo.bo_status_cd != dinvalidcd
      AND bo.fin_class_cd=dselfpayfccd)
     JOIN (bhr
     WHERE bhr.benefit_order_id=bo.benefit_order_id
      AND bhr.active_ind=true
      AND bhr.bo_hp_status_cd != dinvalidcd)
    ORDER BY pe.pft_encntr_id, bo.benefit_order_id, bhr.bo_hp_reltn_id
    HEAD pe.pft_encntr_id
     felist->cnt += 1, stat = alterlist(felist->list,felist->cnt), felist->list[felist->cnt].
     pftencntrid = pe.pft_encntr_id,
     felist->list[felist->cnt].spbohpid = bhr.bo_hp_reltn_id, felist->list[felist->cnt].
     currentpriority = bhr.priority_seq, felist->list[felist->cnt].newpriority = 1
    DETAIL
     null
    WITH nocounter
   ;end select
   IF ((felist->cnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = felist->cnt),
      benefit_order bo,
      bo_hp_reltn bhr
     PLAN (d1)
      JOIN (bo
      WHERE (bo.pft_encntr_id=felist->list[d1.seq].pftencntrid)
       AND bo.active_ind=true
       AND bo.bo_status_cd != dinvalidcd
       AND bo.fin_class_cd != dselfpayfccd)
      JOIN (bhr
      WHERE bhr.benefit_order_id=bo.benefit_order_id
       AND bhr.active_ind=true
       AND bhr.bo_hp_status_cd != dinvalidcd)
     ORDER BY bo.pft_encntr_id, bo.benefit_order_id, bhr.priority_seq
     DETAIL
      null
     FOOT  bo.benefit_order_id
      felist->list[d1.seq].newpriority = (bhr.priority_seq+ 1)
     WITH nocounter
    ;end select
    UPDATE  FROM (dummyt d1  WITH seq = felist->cnt),
      bo_hp_reltn bhr
     SET bhr.priority_seq = felist->list[d1.seq].newpriority
     PLAN (d1
      WHERE (felist->list[d1.seq].currentpriority != felist->list[d1.seq].newpriority))
      JOIN (bhr
      WHERE (bhr.bo_hp_reltn_id=felist->list[d1.seq].spbohpid))
     WITH nocounter
    ;end update
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE repostcharges(chrgcnt)
   IF ((em_afc_chk_profit_install_reply->profit_installed=1))
    CALL echo("Repost Charges!!!!!!!!!!!!")
    CALL echorecord(nt_request_all)
    CALL echorecord(post_rel_nt_request)
    IF (size(post_rel_nt_request->charges,5) > 0)
     SET nntallcnt = 0
     SET stat = alterlist(nt_request_all->charges,value(size(post_rel_nt_request->charges,5)))
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(post_rel_nt_request->charges,5)))
      PLAN (d
       WHERE (post_rel_nt_request->charges[d.seq].charge_type_cd=ddebittypecd))
      DETAIL
       nntallcnt += 1, nt_request_all->charges[nntallcnt].charge_item_id = post_rel_nt_request->
       charges[d.seq].charge_item_id, nt_request_all->charges[nntallcnt].reprocess_ind =
       post_rel_nt_request->charges[d.seq].reprocess_ind
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(post_rel_nt_request->charges,5)))
      PLAN (d
       WHERE (post_rel_nt_request->charges[d.seq].charge_type_cd != ddebittypecd))
      DETAIL
       nntallcnt += 1, nt_request_all->charges[nntallcnt].charge_item_id = post_rel_nt_request->
       charges[d.seq].charge_item_id, nt_request_all->charges[nntallcnt].reprocess_ind =
       post_rel_nt_request->charges[d.seq].reprocess_ind
      WITH nocounter
     ;end select
     CALL echorecord(nt_request_all)
     CALL echo("Posting New Charges!!!!!!!!!!!")
     EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",nt_request_all), replace("REPLY",
      nt_reply_all)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE reclassifygl(chrgcnt)
   CALL echo("Calling Update Reclass!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
   SET reclassreq->o_primary_hp_id = doldhealthplanid
   SET reclassreq->n_primary_hp_id = dnewhealthplanid
   SET reclassreq->n_encntr_id = request->o_encntr_id
   SET reclassreq->o_encntr_id = request->o_encntr_id
   SET reclassreq->n_encntr_type_cd = request->n_encntr_type_cd
   SET reclassreq->o_encntr_type_cd = request->o_encntr_type_cd
   SET reclassreq->n_fin_class_cd = request->n_fin_class_cd
   SET reclassreq->o_fin_class_cd = request->o_fin_class_cd
   CALL echorecord(reclassreq)
   EXECUTE pft_upt_reclass_receivables  WITH replace("REQUEST",reclassreq), replace("REPLY",
    reclassrep)
   CALL echorecord(reclassrep)
 END ;Subroutine
 SUBROUTINE (evalpriorbohp(priorityseq=i4) =i2)
   DECLARE bohpcnt = i4
   DECLARE billhdcnt = i4
   DECLARE wfcnt = i4
   DECLARE wfind = i2
   DECLARE pftencntr = i4
   DECLARE tempcnt = i4
   DECLARE bodirtyind = i2
   DECLARE bhdirtyind = i2
   DECLARE subcrossoverind = i2
   DECLARE seccrossnochangeind = i2
   FREE RECORD objtempbillheadprior
   RECORD objtempbillheadprior(
     1 obj_vrsn_1 = c1
     1 ein_type = i4
     1 proxy_ind = i2
     1 objarray[*]
       2 benefit_order_id = f8
       2 bill_status_cd = f8
       2 bo_hp_reltn_id = f8
       2 active_ind = i2
       2 corsp_activity_id = f8
       2 bill_vrsn_nbr = i4
       2 updt_cnt = i4
       2 submit_dt_tm = f8
   )
   CALL echo("Finding Previous BOHP's")
   SET stat = alterlist(wfrequest->entity,0)
   SET stat = alterlist(addcommentrequest->objarray,0)
   EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod),
   replace("OBJREPLY",objbenefitorderrep)
   IF ((reply->status_data.status="F"))
    SET reply->status_data.status = "F"
    GO TO program_exit
   ELSEIF ((reply->status_data.status="Z"))
    SET reply->status_data.status = "Z"
    GO TO program_exit
   ENDIF
   SET objtempbillheadprior->ein_type = ein_pft_encntr
   EXECUTE pft_bill_header_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
    objtempbillheadprior), replace("REPLY",reply)
   IF ((reply->status_data="F"))
    CALL echo("pft_bill_header_find FAILED.")
    GO TO program_exit
   ENDIF
   SELECT INTO "nl:"
    benefitorder = objbenefitorderrep->objarray[d1.seq].benefit_order_id, bohpid = objbenefitorderrep
    ->objarray[d1.seq].bo_hp_reltn_id
    FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5)))
    PLAN (d1
     WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[d1.seq].priority_seq < priorityseq)
      AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd)
      AND (objbenefitorderrep->objarray[d1.seq].pft_encntr_id=evaluate(mpeid,0.0,objbenefitorderrep->
      objarray[d1.seq].pft_encntr_id,mpeid)))
    ORDER BY benefitorder, bohpid, objbenefitorderrep->objarray[d1.seq].priority_seq
    HEAD benefitorder
     CALL echo(build("New Benefit Order:",benefitorder)), subcrossoverind = 0, seccrossnochangeind =
     0
    HEAD bohpid
     CALL echo("BoHpID")
    DETAIL
     CALL echo("New BOHP"),
     CALL echo(build("Priority Seq",objbenefitorderrep->objarray[d1.seq].priority_seq)), wfind = 0
     FOR (billhdcnt = 1 TO size(objtempbillheadprior->objarray,5))
      CALL echo("Bill"),
      IF ((objtempbillheadprior->objarray[billhdcnt].bo_hp_reltn_id=objbenefitorderrep->objarray[d1
      .seq].bo_hp_reltn_id)
       AND (((objtempbillheadprior->objarray[billhdcnt].bill_status_cd IN (dsubmittedcd,
      dtransmittedcd, ddeniedcd, ddeniedreviewcd))) OR ((objtempbillheadprior->objarray[billhdcnt].
      submit_dt_tm > 0.0))) )
       CALL echo("Found a submitted claims")
       IF (size(wfrequest->entity,5) > 0)
        pftencntr = locateval(tempcnt,1,size(wfrequest->entity,5),objbenefitorderrep->objarray[d1.seq
         ].pft_encntr_id,wfrequest->entity[tempcnt].entity_id)
        IF (pftencntr=0)
         wfcnt += 1, stat = alterlist(wfrequest->entity,wfcnt), wfrequest->entity[wfcnt].entity_id =
         objbenefitorderrep->objarray[d1.seq].pft_encntr_id,
         wfrequest->entity[wfcnt].pft_entity_status_cd = dwfdemmodcd, wfrequest->entity[wfcnt].
         pft_entity_type_cd = dwfencntrcd, stat = alterlist(addcommentrequest->objarray,wfcnt),
         addcommentrequest->objarray[wfcnt].pft_encntr_id = objbenefitorderrep->objarray[d1.seq].
         pft_encntr_id, addcommentrequest->objarray[wfcnt].corsp_desc =
         "Submitted Claim on Previous Health Plan after encounter modification.", addcommentrequest->
         objarray[wfcnt].importance_flag = 2,
         addcommentrequest->objarray[wfcnt].created_dt_tm = cnvtdatetime(sysdate)
        ENDIF
        wfind = 1, subcrossoverind = 1
       ELSE
        wfcnt += 1, stat = alterlist(wfrequest->entity,wfcnt), wfrequest->entity[wfcnt].entity_id =
        objbenefitorderrep->objarray[d1.seq].pft_encntr_id,
        wfrequest->entity[wfcnt].pft_entity_status_cd = dwfdemmodcd, wfrequest->entity[wfcnt].
        pft_entity_type_cd = dwfencntrcd, stat = alterlist(addcommentrequest->objarray,wfcnt),
        addcommentrequest->objarray[wfcnt].pft_encntr_id = objbenefitorderrep->objarray[d1.seq].
        pft_encntr_id, addcommentrequest->objarray[wfcnt].corsp_desc =
        "Submitted Claim on Previous Health Plan after encounter modification.", addcommentrequest->
        objarray[wfcnt].importance_flag = 2,
        addcommentrequest->objarray[wfcnt].created_dt_tm = cnvtdatetime(sysdate), wfind = 1,
        subcrossoverind = 1
       ENDIF
      ENDIF
     ENDFOR
     IF (wfind=0)
      FOR (billhdcnt = 1 TO size(objtempbillheadprior->objarray,5))
        IF ( NOT ((objtempbillheadprior->objarray[billhdcnt].bill_status_cd IN (dsubmittedcd,
        dtransmittedcd, ddeniedcd, ddeniedreviewcd)))
         AND (objtempbillheadprior->objarray[billhdcnt].bo_hp_reltn_id=objbenefitorderrep->objarray[
        d1.seq].bo_hp_reltn_id))
         bhdirtyind = 1
         IF ((objtempbillheadprior->objarray[billhdcnt].bill_status_cd=dtransmittebycrosscd))
          CALL echo("Cross OVer")
          IF (subcrossoverind != 1)
           objtempbillheadprior->objarray[billhdcnt].bill_status_cd = dcanceledcd
          ELSE
           seccrossnochangeind = 1
          ENDIF
         ELSE
          CALL echo("Cancelling a Claim"), objtempbillheadprior->objarray[billhdcnt].bill_status_cd
           = dcanceledcd
         ENDIF
        ENDIF
      ENDFOR
      IF ((objbenefitorderrep->objarray[d1.seq].priority_seq != 1))
       CALL echo("Looking for Previous Benefit Order")
       IF (seccrossnochangeind=0)
        IF ((((objbenefitorderrep->objarray[(d1.seq - 1)].bo_hp_status_cd=dreadytobillcd)) OR ((((
        objbenefitorderrep->objarray[(d1.seq - 1)].bo_hp_status_cd=dwtgforpriorcd)) OR ((
        objbenefitorderrep->objarray[(d1.seq - 1)].bo_hp_status_cd=dgeneratedcd))) )) )
         CALL echo("Setting to Waiting for Prior"), objbenefitorderrep->objarray[d1.seq].
         bo_hp_status_cd = dwtgforpriorcd
        ELSEIF ((objbenefitorderrep->objarray[(d1.seq - 1)].bo_hp_status_cd=dcompletecd))
         CALL echo("Setting to Ready to Bill"), objbenefitorderrep->objarray[d1.seq].bo_hp_status_cd
          = dreadytobillcd
        ENDIF
        bodirtyind = 1
       ENDIF
      ELSE
       CALL echo("Updating First Benefit Order"), objbenefitorderrep->objarray[d1.seq].
       bo_hp_status_cd = dreadytobillcd, bodirtyind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual != 0)
    IF (size(wfrequest->entity,5) > 0)
     CALL sendencntrtoworkflow(dwfeventcd)
     EXECUTE pft_apply_comment_for_encntr  WITH replace("REQUEST",addcommentrequest), replace("REPLY",
      addcommentreply)
     IF ((addcommentreply->status_data.status != "S"))
      GO TO program_exit
     ENDIF
    ENDIF
    IF (bodirtyind=1)
     EXECUTE pft_benefit_order_save  WITH replace("REQUEST",objbenefitorderrep), replace("REPLY",
      reply)
     IF ((reply->status_data.status != "S"))
      CALL logmsg(curprog,"FAILED EXECUTING PFT BENEFIT ORDER SAVE IN UPTGUARANTOR()",log_warning)
      GO TO program_exit
     ENDIF
    ENDIF
    IF (bhdirtyind=1)
     CALL echo("Cancelling Claims")
     CALL echorecord(objtempbillheadprior)
     EXECUTE pft_bill_header_save  WITH replace("REQUEST",objtempbillheadprior), replace("REPLY",
      reply)
     IF ((reply->status_data.status != "S"))
      GO TO program_exit
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE processtertchange(chrgcnt)
   CALL echo("ProcessTertChange")
   CALL echo(build("nTerExistFinCOB: ",nterexistfincob))
   CALL echo(build("nTerExistClinCOB: ",nterexistclincob))
   CALL echo(build("Tertiary Mod: ",ntertmod))
   DECLARE sp_priority_seq = i4
   DECLARE tempd = i4
   DECLARE hpindex = i4
   DECLARE tertcnt = i4
   DECLARE tertchngseq = i4
   FREE RECORD tempterthps
   RECORD tempterthps(
     1 hps[*]
       2 hpid = f8
       2 priority_seq = i4
       2 changed_ind = i2
   )
   CALL echo("Process Tertiary")
   CALL echo("Tertiary Plans Changed")
   SELECT DISTINCT INTO "nl:"
    objbenefitorderrep->objarray[d1.seq].priority_seq
    FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5)))
    PLAN (d1
     WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[d1.seq].priority_seq > 2)
      AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd))
    ORDER BY objbenefitorderrep->objarray[d1.seq].priority_seq
    DETAIL
     tertcnt += 1, stat = alterlist(tempterthps->hps,tertcnt), tempterthps->hps[tertcnt].hpid =
     objbenefitorderrep->objarray[d1.seq].health_plan_id,
     tempterthps->hps[tertcnt].priority_seq = objbenefitorderrep->objarray[d1.seq].priority_seq
    WITH nocounter
   ;end select
   CALL echorecord(tempterthps)
   IF (size(tempterthps->hps,5) > 0)
    FOR (tertcnt = 1 TO size(tempterthps->hps,5))
      SET dcurrenthpid = 0.0
      SET dcurrenthpid = gethealthplanbypriority(tempterthps->hps[tertcnt].priority_seq,1)
      IF ((tempterthps->hps[tertcnt].hpid != dcurrenthpid))
       CALL echo("Tertiary Changed!!!!!!!!!!")
       SET stat = alterlist(objuptboreq->objarray,0)
       CALL retrievebo(tempterthps->hps[tertcnt].priority_seq)
       IF (size(objuptboreq->objarray,5) > 0)
        CALL echo("BOHP to Update")
        SET objbobillheader->ein_type = ein_benefit_order
        EXECUTE pft_bill_header_find  WITH replace("REQUEST",objuptboreq), replace("OBJREPLY",
         objbobillheader), replace("REPLY",reply)
        IF ((reply->status_data="F"))
         CALL echo("pft_bill_header_find FAILED.")
         GO TO program_exit
        ENDIF
        IF (size(objtransfindrep->objarray,5)=0)
         SET objtransfindrep->hide_charges_ind = 1
         SET objtransfindrep->ein_type = ein_pft_encntr
         EXECUTE pft_transaction_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
          objtransfindrep), replace("REPLY",reply)
         IF ((reply->status_data="F"))
          CALL echo("pft_transaction_find FAILED.")
          GO TO program_exit
         ENDIF
        ENDIF
        CALL echo("Getting Ready to Call to Invalidate BO")
        CALL invalidatebosingle(size(objuptboreq->objarray,5),size(objbobillheader->objarray,5),size(
          objtransfindrep->objarray,5))
        CALL echo("Getting Ready to Call to Inactivate BO")
        CALL inactivatebosingle(size(objuptboreq->objarray,5),size(objbobillheader->objarray,5))
        CALL echorecord(objuptboreq)
        IF (dcurrenthpid=0.0)
         CALL echo("Adding SelfPay to Tertiary, where SP is 0.0")
         CALL remnonprimhptocob(0.0,tempterthps->hps[tertcnt].priority_seq)
         SET tertchngseq = tempterthps->hps[tertcnt].priority_seq
         SET tertcnt = size(tempterthps->hps,5)
        ELSEIF (dcurrenthpid > 0.0)
         SET hpindex = locateval(tempd,1,size(objpmhealthplan->objarray,5),dcurrenthpid,
          objpmhealthplan->objarray[tempd].hp_id)
         IF ((objpmhealthplan->objarray[hpindex].fin_class_cd=dselfpayfccd))
          CALL echo("Adding SelfPay to Tertiary")
          CALL remnonprimhptocob(objpmhealthplan->objarray[hpindex].hp_id,tempterthps->hps[tertcnt].
           priority_seq)
          SET tertchngseq = tempterthps->hps[tertcnt].priority_seq
          SET tertcnt = size(tempterthps->hps,5)
         ELSE
          CALL echo("Adding Tertiary to Tertiary")
          CALL addnonprimhptocob(objpmhealthplan->objarray[hpindex].hp_id,tempterthps->hps[tertcnt].
           priority_seq,size(objuptboreq->objarray,5))
          SET tertcnt = size(tempterthps->hps,5)
          SET tertchngseq = tempterthps->hps[tertcnt].priority_seq
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    CALL echo("call to Reevaluate Previous BOHP's!!!!!!!!!!!!")
    CALL echo(build("Tertiary Chanage Count:",tertchngseq))
    CALL evalpriorbohp(tertchngseq)
   ELSE
    CALL echo("Tertiary Plans Changed and Financial Side is SelfPay.")
    IF (nterexistclincob=1)
     IF ((objpmhealthplan->objarray[3].fin_class_cd=dselfpayfccd))
      CALL echo("Add Selfpay to SelfPay")
      CALL updateselfpaynonprimary(3)
      IF (size(objuptboreq->objarray,5) > 0)
       CALL echo("Calling Invalidate Benefit Order Save!!!!!!!!!")
       EXECUTE pft_benefit_order_save  WITH replace("REQUEST",objuptboreq), replace("REPLY",reply)
       IF ((reply->status_data.status != "S"))
        CALL echo("Benefit Order Failed")
        GO TO program_exit
       ENDIF
      ENDIF
     ELSE
      CALL echo("Added New HP to Tertiary")
      CALL addnonprimhptocob(objpmhealthplan->objarray[3].hp_id,3,0)
      CALL echo("call to Reevaluate Previous BOHP's!!!!!!!!!!!!")
      CALL evalpriorbohp(3)
     ENDIF
    ELSE
     CALL echo("Add Selfpay to SelfPay")
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5)))
      PLAN (d1
       WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
        AND (objbenefitorderrep->objarray[d1.seq].priority_seq > 2)
        AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd=dselfpayfccd))
      DETAIL
       sp_priority_seq = objbenefitorderrep->objarray[d1.seq].priority_seq
      WITH nocounter
     ;end select
     CALL updateselfpaynonprimary(sp_priority_seq)
     IF (size(objuptboreq->objarray,5) > 0)
      CALL echo("Calling Invalidate Benefit Order Save!!!!!!!!!")
      EXECUTE pft_benefit_order_save  WITH replace("REQUEST",objuptboreq), replace("REPLY",reply)
      IF ((reply->status_data.status != "S"))
       CALL echo("Benefit Order Failed")
       GO TO program_exit
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(objbenefitorderrep->objarray,5)))
    PLAN (d
     WHERE (objbenefitorderrep->objarray[d.seq].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[d.seq].bill_type_cd=md1450cd)
      AND (objbenefitorderrep->objarray[d.seq].fin_class_cd != dselfpayfccd))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    IF ( NOT (evaluatenonprimbohpforime(3)))
     CALL echo("Call to EvaluateNonPrimBoHPForIME sub for tertiary health Plan mod failed.")
     GO TO program_exit
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE processsecchange(chrgcnt)
   DECLARE lsecreverseexpcnt = i4
   CALL echo("Process Secondary Change")
   CALL echo(build("nSecSPFinCOB: ",nsecspfincob))
   CALL echo(build("nSecExistClinCOB: ",nsecexistclincob))
   CALL echo(build("nSecExistFinCOB: ",nsecexistfincob))
   IF (nsecexistfincob=1
    AND nsecspfincob=0)
    CALL echo("There has been a change in the Secondary HP")
    CALL echo("It is not SelfPay")
    IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
    nhpexpirelogicvar != 1)) )
     CALL retrievebo(2)
    ENDIF
    CALL echorecord(objuptboreq)
    IF (size(objuptboreq->objarray,5) > 0)
     SET objbobillheader->ein_type = ein_benefit_order
     EXECUTE pft_bill_header_find  WITH replace("REQUEST",objuptboreq), replace("OBJREPLY",
      objbobillheader), replace("REPLY",reply)
     IF ((reply->status_data="F"))
      CALL echo("pft_bill_header_find FAILED.")
      GO TO program_exit
     ENDIF
     CALL echorecord(objbobillheader)
     SET objtransfindrep->hide_charges_ind = 1
     SET objtransfindrep->ein_type = ein_pft_encntr
     EXECUTE pft_transaction_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
      objtransfindrep), replace("REPLY",reply)
     IF ((reply->status_data="F"))
      CALL echo("pft_transaction_find FAILED.")
      GO TO program_exit
     ENDIF
     IF (size(objtransfindrep->objarray,5) > 0
      AND size(objbobillheader->objarray,5) > 0)
      CALL findexpectedtrans(size(objuptboreq->objarray,5))
      IF (size(objreversereq->objarray,5) > 0)
       EXECUTE pft_reverse_transaction  WITH replace("REQUEST",objreversereq), replace("REPLY",reply)
       CALL echorecord(reply)
       IF ((reply->status_data.status != "S"))
        CALL echorecord(reply)
        GO TO program_exit
       ENDIF
       CALL echo("calling Benefit Order find again, after Transactions")
       SET stat = alterlist(objbenefitorderrep->objarray,0)
       EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod
        ), replace("OBJREPLY",objbenefitorderrep)
       CALL echorecord(objbenefitorderrep)
       IF ((reply->status_data.status="F"))
        SET reply->status_data.status = "F"
        GO TO program_exit
       ELSEIF ((reply->status_data.status="Z"))
        SET reply->status_data.status = "Z"
        GO TO program_exit
       ENDIF
       SET stat = initrec(objuptboreq)
       IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
       nhpexpirelogicvar != 1)) )
        CALL retrievebo(2)
       ELSE
        CALL hpexpireevalbo(objfinencntrmod->objarray[mpeidx].pft_encntr_id,2)
       ENDIF
       SET stat = initrec(objtransfindrep)
       CALL echo("Get New Transactions as well")
       EXECUTE pft_transaction_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
        objtransfindrep), replace("REPLY",reply)
       IF ((reply->status_data="F"))
        CALL echo("pft_transaction_find FAILED.")
        GO TO program_exit
       ENDIF
      ENDIF
     ENDIF
     CALL echo("Getting Ready to Call to Invalidate BO")
     CALL invalidatebosingle(size(objuptboreq->objarray,5),size(objbobillheader->objarray,5),size(
       objtransfindrep->objarray,5))
     CALL echo("Getting Ready to Call to Inactivate BO")
     CALL inactivatebosingle(size(objuptboreq->objarray,5),size(objbobillheader->objarray,5))
     IF (nsecexistclincob=1
      AND nsecspclincob=0)
      CALL echo("Changed Secondary HP to New Secondary HP")
      IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
      nhpexpirelogicvar != 1)) )
       CALL addnonprimhptocob(objpmhealthplan->objarray[2].hp_id,2,size(objuptboreq->objarray,5))
      ELSE
       CALL addnonprimhptocob(currentcob->objarray[2].health_plan_id,2,size(objuptboreq->objarray,5))
      ENDIF
     ELSEIF (nsecexistclincob=0)
      CALL echo("Changed Secondary to SelfPay, no Plan")
      CALL remnonprimhptocob(0.0,2)
     ELSEIF (nsecexistclincob=1
      AND nsecspclincob=1)
      CALL echo("Changed Secondary to SelfPay, with Plan")
      CALL remnonprimhptocob(objpmhealthplan->objarray[2].hp_id,2)
     ENDIF
     CALL echo("call to Reevaluate Previous BOHP's!!!!!!!!!!!!")
     CALL evalpriorbohp(2)
    ENDIF
   ELSEIF (nsecexistfincob=1
    AND nsecspfincob=1
    AND nsecexistclincob=1)
    CALL echo("Changed from SP to Secondary HP")
    IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
    nhpexpirelogicvar != 1)) )
     CALL addnonprimhptocob(objpmhealthplan->objarray[2].hp_id,2,0)
    ELSE
     CALL addnonprimhptocob(currentcob->objarray[2].health_plan_id,2,0)
    ENDIF
    CALL evalpriorbohp(2)
   ENDIF
   SELECT INTO "nl:"
    count(*)
    FROM (dummyt d  WITH seq = value(size(objbenefitorderrep->objarray,5)))
    PLAN (d
     WHERE (objbenefitorderrep->objarray[d.seq].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[d.seq].bill_type_cd=md1450cd)
      AND (objbenefitorderrep->objarray[d.seq].fin_class_cd != dselfpayfccd))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    IF ( NOT (evaluatenonprimbohpforime(2)))
     CALL echo("Call to evaluateNonPrimBoHPForIME sub for secondary health Plan mod failed.")
     GO TO program_exit
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addnonprimhptocob(hpid=f8,priority_seq=i4,bouptcnt=i4) =i2)
   CALL echo("AddNonPrimHPtoCOB")
   CALL echo(build("New HP Id:",hpid))
   CALL echo(build("New Priority Seq:",priority_seq))
   CALL echo(build("Bo Hp Cnt:",bouptcnt))
   DECLARE addbohpcnt = i4
   DECLARE bocnt = i4
   DECLARE dpft_encntr_id = f8
   DECLARE encntr_type_cd = f8
   DECLARE beid = f8
   DECLARE uptbohpcnt = i4
   DECLARE priorseqcnt = i4
   DECLARE lcancelclmcnt = i4
   DECLARE lwfcnt = i4
   DECLARE bohpcnt = i4
   DECLARE dtotaltransamt = f8
   FREE RECORD tempbocnt
   RECORD tempbocnt(
     1 temp[*]
       2 benefit_order_id = f8
       2 bt_condition_id = f8
       2 pft_encntr_id = f8
       2 encntr_type_cd = f8
       2 billing_entity_id = f8
   )
   FREE RECORD tempbo
   RECORD tempbo(
     1 obj_vrsn_2 = c1
     1 ein_type = i4
     1 proxy_ind = i2
     1 objarray[1]
       2 bt_condition_id = f8
       2 billing_entity_id = f8
       2 encntr_type_cd = f8
   )
   FREE RECORD temphp
   RECORD temphp(
     1 obj_vrsn_2 = c1
     1 ein_type = i4
     1 proxy_ind = i2
     1 objarray[1]
       2 hp_id = f8
       2 fin_class_cd = f8
       2 bill_templ_id = f8
   )
   IF (bouptcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(bouptcnt)),
      (dummyt d2  WITH seq = value(size(objbenefitorderrep->objarray,5)))
     PLAN (d1)
      JOIN (d2
      WHERE (objbenefitorderrep->objarray[d2.seq].bo_status_cd != dinvalidcd)
       AND (objbenefitorderrep->objarray[d2.seq].bo_hp_status_cd != dinvalidcd)
       AND (objbenefitorderrep->objarray[d2.seq].bo_hp_reltn_id=objuptboreq->objarray[d1.seq].
      bo_hp_reltn_id))
     DETAIL
      CALL echo("New Bohp to Add"), addbohpcnt += 1,
      CALL echo(build("AddBoHPCnt: ",addbohpcnt)),
      stat = alterlist(objaddbo->objarray,addbohpcnt), objaddbo->objarray[addbohpcnt].
      billing_entity_id = objbenefitorderrep->objarray[d2.seq].billing_entity_id, objaddbo->objarray[
      addbohpcnt].pft_encntr_id = objbenefitorderrep->objarray[d2.seq].pft_encntr_id,
      objaddbo->objarray[addbohpcnt].proration_type_cd = dpatientprocd, objaddbo->objarray[addbohpcnt
      ].benefit_order_id = objbenefitorderrep->objarray[d2.seq].benefit_order_id, objaddbo->objarray[
      addbohpcnt].priority_seq = objbenefitorderrep->objarray[d2.seq].priority_seq,
      objaddbo->objarray[addbohpcnt].bt_condition_id = objbenefitorderrep->objarray[d2.seq].
      bt_condition_id, objaddbo->objarray[addbohpcnt].encntr_type_cd = objbenefitorderrep->objarray[
      d2.seq].encntr_type_cd, objaddbo->objarray[addbohpcnt].person_id = objfinencntrmod->objarray[1]
      .person_id
      IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
      nhpexpirelogicvar != 1)) )
       objaddbo->objarray[addbohpcnt].health_plan_id = hpid, objaddbo->objarray[addbohpcnt].
       health_plan_name = objpmhealthplan->objarray[priority_seq].hp_name, objaddbo->objarray[
       addbohpcnt].fin_class_cd = objpmhealthplan->objarray[priority_seq].fin_class_cd,
       objaddbo->objarray[addbohpcnt].encntr_plan_reltn_id = objpmhealthplan->objarray[priority_seq].
       encntr_plan_reltn_id, objaddbo->objarray[addbohpcnt].payor_org_id = objpmhealthplan->objarray[
       priority_seq].payer_org
      ELSE
       objaddbo->objarray[addbohpcnt].health_plan_id = hpid, objaddbo->objarray[addbohpcnt].
       health_plan_name = currentcob->objarray[priority_seq].health_plan_name, objaddbo->objarray[
       addbohpcnt].fin_class_cd = currentcob->objarray[priority_seq].financial_class_cd,
       objaddbo->objarray[addbohpcnt].encntr_plan_reltn_id = currentcob->objarray[priority_seq].
       encntr_plan_reltn_id, objaddbo->objarray[addbohpcnt].payor_org_id = currentcob->objarray[
       priority_seq].payer_org
      ENDIF
      objaddbo->objarray[addbohpcnt].bo_hp_status_cd = dwtgforpriorcd
      FOR (lboindex = 1 TO size(objbenefitorderrep->objarray,5))
        IF ((objbenefitorderrep->objarray[lboindex].benefit_order_id=objbenefitorderrep->objarray[d2
        .seq].benefit_order_id)
         AND (objbenefitorderrep->objarray[lboindex].priority_seq=(priority_seq - 1))
         AND (objbenefitorderrep->objarray[lboindex].bo_hp_status_cd=dcompletecd))
         objaddbo->objarray[addbohpcnt].bo_hp_status_cd = dreadytobillcd
        ENDIF
      ENDFOR
      objaddbo->objarray[addbohpcnt].orig_amt_due = objbenefitorderrep->objarray[d2.seq].orig_amt_due,
      objaddbo->objarray[addbohpcnt].curr_amt_due = objbenefitorderrep->objarray[d2.seq].orig_amt_due
      IF ((objbenefitorderrep->objarray[d2.seq].amount_owed != 0.0))
       objaddbo->objarray[addbohpcnt].amount_owed = (objbenefitorderrep->objarray[d2.seq].amount_owed
        * - (1))
      ENDIF
      stat = alterlist(tempbocnt->temp,addbohpcnt), tempbocnt->temp[addbohpcnt].benefit_order_id =
      objbenefitorderrep->objarray[d2.seq].benefit_order_id, tempbocnt->temp[addbohpcnt].
      bt_condition_id = objbenefitorderrep->objarray[d2.seq].bt_condition_id,
      tempbocnt->temp[addbohpcnt].pft_encntr_id = objbenefitorderrep->objarray[d2.seq].pft_encntr_id,
      tempbocnt->temp[addbohpcnt].encntr_type_cd = objbenefitorderrep->objarray[d2.seq].
      encntr_type_cd, tempbocnt->temp[addbohpcnt].billing_entity_id = objbenefitorderrep->objarray[d2
      .seq].billing_entity_id
     WITH nocounter
    ;end select
    SET addbohpcnt = 0
    SET bocnt = size(objaddbo->objarray,5)
    SET addbohpcnt = 0
    CALL echo("Calling against Benefit Order Struct!!!!!!!!!!")
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5)))
     PLAN (d1
      WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
       AND (objbenefitorderrep->objarray[d1.seq].bo_hp_status_cd != dinvalidcd)
       AND (objbenefitorderrep->objarray[d1.seq].priority_seq > priority_seq)
       AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd)
       AND (objbenefitorderrep->objarray[d1.seq].pft_encntr_id=evaluate(mpeid,0.0,objbenefitorderrep
       ->objarray[d1.seq].pft_encntr_id,mpeid)))
     ORDER BY objbenefitorderrep->objarray[d1.seq].priority_seq
     DETAIL
      CALL echo("Benefit Order Qualified for New Plan!"), uptbohpcnt = (size(objuptboreq->objarray,5)
      + 1), stat = alterlist(objuptboreq->objarray,uptbohpcnt),
      objuptboreq->objarray[uptbohpcnt].bo_hp_reltn_id = objbenefitorderrep->objarray[d1.seq].
      bo_hp_reltn_id, objuptboreq->objarray[uptbohpcnt].bhr_updt_cnt = objbenefitorderrep->objarray[
      d1.seq].bhr_updt_cnt, objuptboreq->objarray[uptbohpcnt].active_ind = 1,
      objuptboreq->objarray[uptbohpcnt].active_status_cd = reqdata->active_status_cd, objuptboreq->
      objarray[uptbohpcnt].pft_proration_id = objbenefitorderrep->objarray[d1.seq].pft_proration_id,
      objuptboreq->objarray[uptbohpcnt].pro_updt_cnt = objbenefitorderrep->objarray[d1.seq].
      pro_updt_cnt,
      objuptboreq->objarray[uptbohpcnt].priority_seq = objbenefitorderrep->objarray[d1.seq].
      priority_seq, objuptboreq->objarray[uptbohpcnt].health_plan_id = objbenefitorderrep->objarray[
      d1.seq].health_plan_id, objuptboreq->objarray[uptbohpcnt].encntr_plan_reltn_id =
      objbenefitorderrep->objarray[d1.seq].encntr_plan_reltn_id,
      objuptboreq->objarray[uptbohpcnt].pft_encntr_id = objbenefitorderrep->objarray[d1.seq].
      pft_encntr_id, objuptboreq->objarray[uptbohpcnt].orig_amt_due = objbenefitorderrep->objarray[d1
      .seq].orig_amt_due
     WITH nocounter
    ;end select
    IF (curqual != 0)
     CALL echo("Additional Changes Qualified for HP Mod")
     FOR (uptbohpcnt = 1 TO size(objuptboreq->objarray,5))
       IF ((objuptboreq->objarray[uptbohpcnt].priority_seq > priority_seq))
        IF (size(objtransfindrep->objarray,5) > 0)
         SELECT INTO "nl:"
          FROM (dummyt d1  WITH seq = value(size(objtransfindrep->objarray,5)))
          PLAN (d1
           WHERE (objtransfindrep->objarray[d1.seq].bo_hp_reltn_id=objuptboreq->objarray[uptbohpcnt].
           bo_hp_reltn_id)
            AND (objtransfindrep->objarray[d1.seq].reversal_ind != 1)
            AND (objtransfindrep->objarray[d1.seq].reversed_ind != 1))
          DETAIL
           dtotaltransamt += objtransfindrep->objarray[d1.seq].total_trans_amount, objuptboreq->
           objarray[uptbohpcnt].curr_amt_due = dtotaltransamt
           IF ((objuptboreq->objarray[uptbohpcnt].curr_amt_due > 0.0))
            objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 1
           ELSEIF ((objuptboreq->objarray[uptbohpcnt].curr_amt_due=0.0))
            objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 0
           ELSE
            objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 2
           ENDIF
           objuptboreq->objarray[uptbohpcnt].bo_hp_status_cd = dinvalidcd
          WITH nocounter
         ;end select
        ENDIF
        SET reqbh->objarray[1].bo_hp_reltn_id = objuptboreq->objarray[uptbohpcnt].bo_hp_reltn_id
        SET stat = alterlist(objbobillheader->objarray,0)
        EXECUTE pft_bill_header_find  WITH replace("REQUEST",objbenefitorderrep), replace("OBJREPLY",
         objbobillheader), replace("REPLY",reply)
        IF ((reply->status_data="F"))
         CALL echo("pft_bill_header_find FAILED.")
         GO TO program_exit
        ENDIF
        IF (size(objbobillheader->objarray,5) > 0)
         SELECT INTO "nl:"
          FROM (dummyt d1  WITH seq = value(size(objbobillheader->objarray,5)))
          PLAN (d1
           WHERE (objbobillheader->objarray[d1.seq].bill_type_cd IN (md1450cd, md1500cd))
            AND (objbobillheader->objarray[d1.seq].bo_hp_reltn_id=objuptboreq->objarray[uptbohpcnt].
           bo_hp_reltn_id))
          DETAIL
           IF ((((objbobillheader->objarray[d1.seq].bill_status_cd IN (dsubmittedcd, dtransmittedcd,
           ddeniedcd, ddeniedreviewcd))) OR ((objbobillheader->objarray[d1.seq].submit_dt_tm > 0))) )
            objuptboreq->objarray[uptbohpcnt].bo_hp_status_cd = dinvalidcd
           ELSE
            lcancelclmcnt = (size(uptbhreq->objarray,5)+ 1), stat = alterlist(uptbhreq->objarray,
             lcancelclmcnt), uptbhreq->objarray[lcancelclmcnt].corsp_activity_id = objbobillheader->
            objarray[d1.seq].corsp_activity_id,
            uptbhreq->objarray[lcancelclmcnt].bill_vrsn_nbr = objbobillheader->objarray[d1.seq].
            bill_vrsn_nbr, uptbhreq->objarray[lcancelclmcnt].bill_status_cd = dcanceledcd, uptbhreq->
            objarray[lcancelclmcnt].updt_cnt = objbobillheader->objarray[d1.seq].updt_cnt,
            uptbhreq->objarray[lcancelclmcnt].active_ind = 0
           ENDIF
          WITH nocounter
         ;end select
        ENDIF
        IF ((objuptboreq->objarray[uptbohpcnt].bo_hp_status_cd != dinvalidcd))
         CALL echo("Inactivating Records")
         SET objuptboreq->objarray[uptbohpcnt].active_ind = 0
         SET objuptboreq->objarray[uptbohpcnt].benefit_order_id = 0.0
         SET objuptboreq->objarray[uptbohpcnt].active_status_cd = reqdata->inactive_status_cd
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
    nhpexpirelogicvar != 1)) )
     FOR (newhpcnt = 1 TO size(objpmhealthplan->objarray,5))
       IF ((objpmhealthplan->objarray[newhpcnt].priority_seq > priority_seq)
        AND (objpmhealthplan->objarray[newhpcnt].fin_class_cd != dselfpayfccd))
        CALL echo("More HP's")
        FOR (addbohpcnt = 1 TO size(tempbocnt->temp,5))
          SET bohpcnt = (size(objaddbo->objarray,5)+ 1)
          SET stat = alterlist(objaddbo->objarray,bohpcnt)
          SET objaddbo->objarray[bohpcnt].benefit_order_id = tempbocnt->temp[addbohpcnt].
          benefit_order_id
          SET objaddbo->objarray[bohpcnt].health_plan_id = objpmhealthplan->objarray[newhpcnt].hp_id
          SET objaddbo->objarray[bohpcnt].health_plan_name = objpmhealthplan->objarray[newhpcnt].
          hp_name
          SET objaddbo->objarray[bohpcnt].fin_class_cd = objpmhealthplan->objarray[newhpcnt].
          fin_class_cd
          SET objaddbo->objarray[bohpcnt].proration_type_cd = dpatientprocd
          SET objaddbo->objarray[bohpcnt].pft_encntr_id = tempbocnt->temp[addbohpcnt].pft_encntr_id
          SET objaddbo->objarray[bohpcnt].encntr_type_cd = tempbocnt->temp[addbohpcnt].encntr_type_cd
          SET objaddbo->objarray[bohpcnt].billing_entity_id = tempbocnt->temp[addbohpcnt].
          billing_entity_id
          SET objaddbo->objarray[bohpcnt].payor_org_id = objpmhealthplan->objarray[newhpcnt].
          payer_org
          SET objaddbo->objarray[bohpcnt].priority_seq = objpmhealthplan->objarray[newhpcnt].
          priority_seq
          SET objaddbo->objarray[bohpcnt].encntr_plan_reltn_id = objpmhealthplan->objarray[newhpcnt].
          encntr_plan_reltn_id
          SET objaddbo->objarray[bohpcnt].person_id = objfinencntrmod->objarray[1].person_id
          SET objaddbo->objarray[bohpcnt].bt_condition_id = tempbocnt->temp[addbohpcnt].
          bt_condition_id
          SET objaddbo->objarray[bohpcnt].bo_hp_status_cd = dwtgforpriorcd
        ENDFOR
       ENDIF
     ENDFOR
    ELSE
     FOR (newhpcnt = 1 TO size(currentcob->objarray,5))
       IF ((currentcob->objarray[newhpcnt].priority_seq > priority_seq)
        AND (currentcob->objarray[newhpcnt].financial_class_cd != dselfpayfccd))
        FOR (addbohpcnt = 1 TO size(tempbocnt->temp,5))
          SET bohpcnt = (size(objaddbo->objarray,5)+ 1)
          SET stat = alterlist(objaddbo->objarray,bohpcnt)
          SET objaddbo->objarray[bohpcnt].benefit_order_id = tempbocnt->temp[addbohpcnt].
          benefit_order_id
          SET objaddbo->objarray[bohpcnt].health_plan_id = currentcob->objarray[newhpcnt].
          health_plan_id
          SET objaddbo->objarray[bohpcnt].health_plan_name = currentcob->objarray[newhpcnt].
          health_plan_name
          SET objaddbo->objarray[bohpcnt].fin_class_cd = currentcob->objarray[newhpcnt].
          financial_class_cd
          SET objaddbo->objarray[bohpcnt].proration_type_cd = dpatientprocd
          SET objaddbo->objarray[bohpcnt].pft_encntr_id = tempbocnt->temp[addbohpcnt].pft_encntr_id
          SET objaddbo->objarray[bohpcnt].encntr_type_cd = tempbocnt->temp[addbohpcnt].encntr_type_cd
          SET objaddbo->objarray[bohpcnt].billing_entity_id = tempbocnt->temp[addbohpcnt].
          billing_entity_id
          SET objaddbo->objarray[bohpcnt].payor_org_id = currentcob->objarray[newhpcnt].payer_org
          SET objaddbo->objarray[bohpcnt].priority_seq = currentcob->objarray[newhpcnt].priority_seq
          SET objaddbo->objarray[bohpcnt].encntr_plan_reltn_id = currentcob->objarray[newhpcnt].
          encntr_plan_reltn_id
          SET objaddbo->objarray[bohpcnt].person_id = currentcob->objarray[1].person_id
          SET objaddbo->objarray[bohpcnt].bt_condition_id = tempbocnt->temp[addbohpcnt].
          bt_condition_id
          SET objaddbo->objarray[bohpcnt].bo_hp_status_cd = dwtgforpriorcd
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
    CALL echo("Getting Bill Template")
    FOR (addbohpcnt = 1 TO size(objaddbo->objarray,5))
      CALL echo("New Bill Template ID")
      SET tempbo->objarray[1].bt_condition_id = objaddbo->objarray[addbohpcnt].bt_condition_id
      SET tempbo->objarray[1].billing_entity_id = objaddbo->objarray[addbohpcnt].billing_entity_id
      SET tempbo->objarray[1].encntr_type_cd = objaddbo->objarray[addbohpcnt].encntr_type_cd
      SET temphp->objarray[1].hp_id = objaddbo->objarray[addbohpcnt].health_plan_id
      SET temphp->objarray[1].fin_class_cd = objaddbo->objarray[addbohpcnt].fin_class_cd
      SET temphp->objarray[1].bill_templ_id = 0.0
      EXECUTE pft_hp_bus_bill_templ  WITH replace("REQUEST",tempbo), replace("OBJREPLY",temphp),
      replace("REPLY",reply)
      IF ((reply->status_data.status="F"))
       CALL echo(build("Failed retrieving bill template for HPID:",hpid))
       GO TO program_exit
      ENDIF
      SET objaddbo->objarray[addbohpcnt].bill_templ_id = temphp->objarray[1].bill_templ_id
    ENDFOR
   ELSE
    CALL echo("Just Insert HP's to COB")
    SELECT INTO "nl:"
     benordid = objbenefitorderrep->objarray[d1.seq].benefit_order_id
     FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5)))
     PLAN (d1
      WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
       AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd)
       AND (objbenefitorderrep->objarray[d1.seq].pft_encntr_id=evaluate(mpeid,0.0,objbenefitorderrep
       ->objarray[d1.seq].pft_encntr_id,mpeid)))
     ORDER BY benordid
     HEAD benordid
      bocnt += 1, stat = alterlist(tempbocnt->temp,bocnt), tempbocnt->temp[bocnt].benefit_order_id =
      objbenefitorderrep->objarray[d1.seq].benefit_order_id,
      tempbocnt->temp[bocnt].bt_condition_id = objbenefitorderrep->objarray[d1.seq].bt_condition_id,
      tempbocnt->temp[bocnt].pft_encntr_id = objbenefitorderrep->objarray[d1.seq].pft_encntr_id
     DETAIL
      CALL echo("New Bohp to Add")
     WITH nocounter
    ;end select
    IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
    nhpexpirelogicvar != 1)) )
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(objpmhealthplan->objarray,5)))
      PLAN (d1
       WHERE (objpmhealthplan->objarray[d1.seq].fin_class_cd != dselfpayfccd)
        AND (objpmhealthplan->objarray[d1.seq].priority_seq >= priority_seq))
      ORDER BY objpmhealthplan->objarray[d1.seq].priority_seq
      DETAIL
       FOR (addbohpcnt = 1 TO bocnt)
         CALL echo("HP's per Benefit Order"), newhpcnt = (size(objaddbo->objarray,5)+ 1), stat =
         alterlist(objaddbo->objarray,newhpcnt),
         objaddbo->objarray[newhpcnt].health_plan_id = objpmhealthplan->objarray[d1.seq].hp_id,
         objaddbo->objarray[newhpcnt].health_plan_name = objpmhealthplan->objarray[d1.seq].hp_name,
         objaddbo->objarray[newhpcnt].fin_class_cd = objpmhealthplan->objarray[d1.seq].fin_class_cd,
         objaddbo->objarray[newhpcnt].proration_type_cd = dpatientprocd, objaddbo->objarray[newhpcnt]
         .pft_encntr_id = tempbocnt->temp[addbohpcnt].pft_encntr_id, objaddbo->objarray[newhpcnt].
         encntr_type_cd = objbenefitorderrep->objarray[1].encntr_type_cd,
         objaddbo->objarray[newhpcnt].billing_entity_id = objbenefitorderrep->objarray[1].
         billing_entity_id, objaddbo->objarray[newhpcnt].priority_seq = objpmhealthplan->objarray[d1
         .seq].priority_seq, objaddbo->objarray[newhpcnt].encntr_plan_reltn_id = objpmhealthplan->
         objarray[d1.seq].encntr_plan_reltn_id,
         objaddbo->objarray[newhpcnt].payor_org_id = objpmhealthplan->objarray[d1.seq].payer_org,
         objaddbo->objarray[newhpcnt].person_id = objfinencntrmod->objarray[1].person_id, objaddbo->
         objarray[newhpcnt].bo_hp_status_cd = dwtgforpriorcd
         FOR (lboindex = 1 TO size(objbenefitorderrep->objarray,5))
           IF ((objbenefitorderrep->objarray[lboindex].benefit_order_id=tempbocnt->temp[addbohpcnt].
           benefit_order_id)
            AND (objbenefitorderrep->objarray[lboindex].priority_seq=(priority_seq - 1))
            AND (objbenefitorderrep->objarray[lboindex].bo_hp_status_cd=dcompletecd))
            objaddbo->objarray[newhpcnt].bo_hp_status_cd = dreadytobillcd
           ENDIF
         ENDFOR
         objaddbo->objarray[newhpcnt].benefit_order_id = tempbocnt->temp[addbohpcnt].benefit_order_id,
         objaddbo->objarray[newhpcnt].bt_condition_id = tempbocnt->temp[addbohpcnt].bt_condition_id
       ENDFOR
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(currentcob->objarray,5)))
      PLAN (d1
       WHERE (currentcob->objarray[d1.seq].financial_class_cd != dselfpayfccd)
        AND (currentcob->objarray[d1.seq].priority_seq >= priority_seq))
      ORDER BY currentcob->objarray[d1.seq].priority_seq
      DETAIL
       FOR (addbohpcnt = 1 TO bocnt)
         CALL echo("HP's per Benefit Order for CurrentCOB"), newhpcnt = (size(objaddbo->objarray,5)+
         1), stat = alterlist(objaddbo->objarray,newhpcnt),
         objaddbo->objarray[newhpcnt].health_plan_id = currentcob->objarray[d1.seq].health_plan_id,
         objaddbo->objarray[newhpcnt].health_plan_name = currentcob->objarray[d1.seq].
         health_plan_name, objaddbo->objarray[newhpcnt].fin_class_cd = currentcob->objarray[d1.seq].
         financial_class_cd,
         objaddbo->objarray[newhpcnt].proration_type_cd = dpatientprocd, objaddbo->objarray[newhpcnt]
         .pft_encntr_id = mpeid, objaddbo->objarray[newhpcnt].encntr_type_cd = objbenefitorderrep->
         objarray[1].encntr_type_cd,
         objaddbo->objarray[newhpcnt].billing_entity_id = objbenefitorderrep->objarray[1].
         billing_entity_id, objaddbo->objarray[newhpcnt].priority_seq = currentcob->objarray[d1.seq].
         priority_seq, objaddbo->objarray[newhpcnt].encntr_plan_reltn_id = currentcob->objarray[d1
         .seq].encntr_plan_reltn_id,
         objaddbo->objarray[newhpcnt].payor_org_id = currentcob->objarray[d1.seq].payer_org, objaddbo
         ->objarray[newhpcnt].person_id = currentcob->objarray[1].person_id, objaddbo->objarray[
         newhpcnt].bo_hp_status_cd = dwtgforpriorcd
         FOR (lboindex = 1 TO size(objbenefitorderrep->objarray,5))
           IF ((objbenefitorderrep->objarray[lboindex].benefit_order_id=tempbocnt->temp[addbohpcnt].
           benefit_order_id)
            AND (objbenefitorderrep->objarray[lboindex].priority_seq=(priority_seq - 1))
            AND (objbenefitorderrep->objarray[lboindex].bo_hp_status_cd=dcompletecd)
            AND (objbenefitorderrep->objarray[lboindex].pft_encntr_id=evaluate(mpeid,0.0,
            objbenefitorderrep->objarray[lboindex].pft_encntr_id,mpeid)))
            objaddbo->objarray[newhpcnt].bo_hp_status_cd = dreadytobillcd
           ENDIF
         ENDFOR
         objaddbo->objarray[newhpcnt].benefit_order_id = tempbocnt->temp[addbohpcnt].benefit_order_id,
         objaddbo->objarray[newhpcnt].bt_condition_id = tempbocnt->temp[addbohpcnt].bt_condition_id
       ENDFOR
      WITH nocounter
     ;end select
    ENDIF
    FOR (addbohpcnt = 1 TO size(objaddbo->objarray,5))
      CALL echo("New Bill Template ID")
      SET tempbo->objarray[1].bt_condition_id = objaddbo->objarray[addbohpcnt].bt_condition_id
      SET tempbo->objarray[1].billing_entity_id = objaddbo->objarray[addbohpcnt].billing_entity_id
      SET tempbo->objarray[1].encntr_type_cd = objaddbo->objarray[addbohpcnt].encntr_type_cd
      SET temphp->objarray[1].hp_id = objaddbo->objarray[addbohpcnt].health_plan_id
      SET temphp->objarray[1].fin_class_cd = objaddbo->objarray[addbohpcnt].fin_class_cd
      SET temphp->objarray[1].bill_templ_id = 0.0
      CALL echorecord(tempbo)
      EXECUTE pft_hp_bus_bill_templ  WITH replace("REQUEST",tempbo), replace("OBJREPLY",temphp),
      replace("REPLY",reply)
      CALL echorecord(temphp)
      IF ((reply->status_data.status="F"))
       CALL echo(build("Failed retrieving bill template for HPID:",hpid))
       GO TO program_exit
      ENDIF
      SET objaddbo->objarray[addbohpcnt].bill_templ_id = temphp->objarray[1].bill_templ_id
    ENDFOR
    CALL echo("Retrieved Bill Template!!!!!!!!!!!")
    CALL unrollselfpaynonprimary(priority_seq)
   ENDIF
   CALL updateselfpaynonprimary(priority_seq)
   CALL echorecord(objaddbo)
   IF (size(objuptboreq->objarray,5) > 0)
    CALL echo("Calling Invalidate Benefit Order Save!!!!!!!!!")
    EXECUTE pft_benefit_order_save  WITH replace("REQUEST",objuptboreq), replace("REPLY",reply)
    IF ((reply->status_data.status != "S"))
     CALL echo("Benefit Order Failed")
     GO TO program_exit
    ENDIF
   ENDIF
   CALL echo("Calling ms_benefit_order_save")
   IF (size(objaddbo->objarray,5) > 0)
    CALL echo("Calling Adding BOHP's")
    EXECUTE pft_benefit_order_save  WITH replace("REQUEST",objaddbo), replace("REPLY",reply)
    IF ((reply->status_data.status != "S"))
     CALL echo("Benefit Order Add Failed")
     GO TO program_exit
    ENDIF
   ENDIF
   SET uptbohpcnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(objuptboreq->objarray,5)))
    PLAN (d1
     WHERE (objuptboreq->objarray[d1.seq].active_ind=0))
    DETAIL
     uptbohpcnt += 1, stat = alterlist(wfdequeuereq->entity,uptbohpcnt), wfdequeuereq->entity[
     uptbohpcnt].pft_entity_type_cd = dwfinsurancecd,
     wfdequeuereq->entity[uptbohpcnt].pft_entity_status_cd = dwfcompleteeventcd, wfdequeuereq->
     entity[uptbohpcnt].bo_hp_reltn_id = objuptboreq->objarray[d1.seq].bo_hp_reltn_id
    WITH nocounter
   ;end select
   SET wfdequeuereq->pft_publish_ind = 1
   EXECUTE pft_wf_publish_state_queue  WITH replace("REQUEST",wfdequeuereq), replace("REPLY",
    wfdequeuerep)
   IF ((wfdequeuerep->status_data="F"))
    GO TO program_exit
   ENDIF
   IF (size(objaddbo->objarray,5) > 0)
    SET stat = alterlist(wfrequest->entity,0)
    SET stat = alterlist(addcommentrequest->objarray,0)
    SELECT INTO "nl:"
     pft_encntr_id = objaddbo->objarray[d1.seq].pft_encntr_id
     FROM (dummyt d1  WITH seq = value(size(objaddbo->objarray,5)))
     PLAN (d1
      WHERE (objaddbo->objarray[d1.seq].bill_templ_id=0.0))
     ORDER BY pft_encntr_id
     HEAD pft_encntr_id
      lwfcnt += 1, stat = alterlist(wfrequest->entity,lwfcnt), wfrequest->entity[lwfcnt].entity_id =
      objfinencntrmod->objarray[d1.seq].pft_encntr_id,
      wfrequest->entity[lwfcnt].pft_entity_status_cd = dwfdemmodcd, wfrequest->entity[lwfcnt].
      pft_entity_type_cd = dwfencntrcd, stat = alterlist(addcommentrequest->objarray,lwfcnt),
      addcommentrequest->objarray[lwfcnt].pft_encntr_id = objfinencntrmod->objarray[d1.seq].
      pft_encntr_id, addcommentrequest->objarray[lwfcnt].corsp_desc =
      "Bill Template is 0.0 on new Health Plan.", addcommentrequest->objarray[lwfcnt].importance_flag
       = 2,
      addcommentrequest->objarray[lwfcnt].created_dt_tm = cnvtdatetime(sysdate)
     DETAIL
      CALL echo("Bill Template is 0")
     WITH nocounter
    ;end select
    IF (curqual != 0)
     CALL sendencntrtoworkflow(dwfeventcd)
     CALL echorecord(addcommentrequest)
     EXECUTE pft_apply_comment_for_encntr  WITH replace("REQUEST",addcommentrequest), replace("REPLY",
      addcommentreply)
     CALL echorecord(addcommentreply)
     IF ((addcommentreply->status_data.status != "S"))
      GO TO program_exit
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (remnonprimhptocob(hpid=f8,priority_seq=i4) =i2)
   CALL echo("RemNonPrimHPtoCOB")
   DECLARE uptbohpcnt = i4
   DECLARE chpsize = i4
   DECLARE spbalcnt = i4
   FREE RECORD sptemp2
   RECORD sptemp2(
     1 temp[*]
       2 pft_encntr_id = f8
       2 bo_hp_reltn_id = f8
       2 balance = f8
   )
   SELECT INTO "nl:"
    pftencntrid = objbenefitorderrep->objarray[d1.seq].pft_encntr_id
    FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5)))
    PLAN (d1
     WHERE (objbenefitorderrep->objarray[d1.seq].priority_seq=priority_seq)
      AND (objbenefitorderrep->objarray[d1.seq].pft_encntr_id=evaluate(mpeid,0.0,objbenefitorderrep->
      objarray[d1.seq].pft_encntr_id,mpeid)))
    ORDER BY pftencntrid
    HEAD pftencntrid
     spbalcnt += 1, stat = alterlist(sptemp2->temp,spbalcnt), sptemp2->temp[spbalcnt].pft_encntr_id
      = objbenefitorderrep->objarray[d1.seq].pft_encntr_id
    DETAIL
     amounttoroll = ((objbenefitorderrep->objarray[d1.seq].curr_amt_due - objbenefitorderrep->
     objarray[d1.seq].total_adj) - objbenefitorderrep->objarray[d1.seq].total_pay_amt), sptemp2->
     temp[spbalcnt].balance += amounttoroll
    WITH nocounter
   ;end select
   CALL echorecord(sptemp2)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5))),
     (dummyt d2  WITH seq = value(size(sptemp2->temp,5)))
    PLAN (d1
     WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd)
      AND (objbenefitorderrep->objarray[d1.seq].priority_seq > priority_seq)
      AND (objbenefitorderrep->objarray[d1.seq].pft_encntr_id=evaluate(mpeid,0.0,objbenefitorderrep->
      objarray[d1.seq].pft_encntr_id,mpeid)))
     JOIN (d2
     WHERE (sptemp2->temp[d2.seq].pft_encntr_id=objbenefitorderrep->objarray[d1.seq].pft_encntr_id))
    DETAIL
     uptbohpcnt = (size(objuptboreq->objarray,5)+ 1), stat = alterlist(objuptboreq->objarray,
      uptbohpcnt), objuptboreq->objarray[uptbohpcnt].bo_hp_reltn_id = objbenefitorderrep->objarray[d1
     .seq].bo_hp_reltn_id,
     objuptboreq->objarray[uptbohpcnt].bhr_updt_cnt = objbenefitorderrep->objarray[d1.seq].
     bhr_updt_cnt, objuptboreq->objarray[uptbohpcnt].active_ind = 1, objuptboreq->objarray[uptbohpcnt
     ].active_status_cd = reqdata->active_status_cd,
     objuptboreq->objarray[uptbohpcnt].pft_proration_id = objbenefitorderrep->objarray[d1.seq].
     pft_proration_id, objuptboreq->objarray[uptbohpcnt].pro_updt_cnt = objbenefitorderrep->objarray[
     d1.seq].pro_updt_cnt, objuptboreq->objarray[uptbohpcnt].priority_seq = objbenefitorderrep->
     objarray[d1.seq].priority_seq,
     objuptboreq->objarray[uptbohpcnt].health_plan_id = objbenefitorderrep->objarray[d1.seq].
     health_plan_id, objuptboreq->objarray[uptbohpcnt].encntr_plan_reltn_id = objbenefitorderrep->
     objarray[d1.seq].encntr_plan_reltn_id, objuptboreq->objarray[uptbohpcnt].pft_encntr_id =
     objbenefitorderrep->objarray[d1.seq].pft_encntr_id,
     objuptboreq->objarray[uptbohpcnt].orig_amt_due, objbenefitorderrep->objarray[d1.seq].
     orig_amt_due, amounttoroll = ((objbenefitorderrep->objarray[d1.seq].curr_amt_due -
     objbenefitorderrep->objarray[d1.seq].total_adj) - objbenefitorderrep->objarray[d1.seq].
     total_pay_amt),
     sptemp2->temp[d2.seq].balance += amounttoroll
    WITH nocounter
   ;end select
   IF (curqual != 0)
    FOR (uptbohpcnt = 1 TO size(objuptboreq->objarray,5))
      IF ((objuptboreq->objarray[uptbohpcnt].priority_seq > priority_seq))
       IF (size(objtransfindrep->objarray,5) > 0)
        DECLARE dtotaltransamt = f8
        SELECT INTO "nl:"
         FROM (dummyt d1  WITH seq = value(size(objtransfindrep->objarray,5)))
         PLAN (d1
          WHERE (objtransfindrep->objarray[d1.seq].bo_hp_reltn_id=objuptboreq->objarray[uptbohpcnt].
          bo_hp_reltn_id)
           AND (objtransfindrep->objarray[d1.seq].reversal_ind != 1)
           AND (objtransfindrep->objarray[d1.seq].reversed_ind != 1))
         DETAIL
          dtotaltransamt += objtransfindrep->objarray[d1.seq].total_trans_amount, objuptboreq->
          objarray[uptbohpcnt].curr_amt_due = dtotaltransamt
          IF ((objuptboreq->objarray[uptbohpcnt].curr_amt_due > 0.0))
           objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 1
          ELSEIF ((objuptboreq->objarray[uptbohpcnt].curr_amt_due=0.0))
           objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 0
          ELSE
           objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 2
          ENDIF
          objuptboreq->objarray[uptbohpcnt].bo_hp_status_cd = dinvalidcd
         WITH nocounter
        ;end select
       ENDIF
       SET reqbh->objarray[1].bo_hp_reltn_id = objuptboreq->objarray[uptbohpcnt].bo_hp_reltn_id
       SET stat = alterlist(objbobillheader->objarray,0)
       EXECUTE pft_bill_header_find  WITH replace("REQUEST",objbenefitorderrep), replace("OBJREPLY",
        objbobillheader), replace("REPLY",reply)
       IF ((reply->status_data="F"))
        CALL echo("pft_bill_header_find FAILED.")
        GO TO program_exit
       ENDIF
       IF (size(objbobillheader->objarray,5) > 0)
        SELECT INTO "nl:"
         FROM (dummyt d1  WITH seq = value(size(objbobillheader->objarray,5)))
         PLAN (d1
          WHERE (objbobillheader->objarray[d1.seq].bill_type_cd IN (md1450cd, md1500cd))
           AND (objbobillheader->objarray[d1.seq].bo_hp_reltn_id=objuptboreq->objarray[uptbohpcnt].
          bo_hp_reltn_id))
         DETAIL
          IF ((((objbobillheader->objarray[d1.seq].bill_status_cd IN (dsubmittedcd, dtransmittedcd,
          ddeniedcd, ddeniedreviewcd))) OR ((objbobillheader->objarray[d1.seq].submit_dt_tm > 0))) )
           objuptboreq->objarray[uptbohpcnt].bo_hp_status_cd = dinvalidcd
          ELSE
           lcancelclmcnt = (size(uptbhreq->objarray,5)+ 1), stat = alterlist(uptbhreq->objarray,
            lcancelclmcnt), uptbhreq->objarray[lcancelclmcnt].corsp_activity_id = objbobillheader->
           objarray[d1.seq].corsp_activity_id,
           uptbhreq->objarray[lcancelclmcnt].bill_vrsn_nbr = objbobillheader->objarray[d1.seq].
           bill_vrsn_nbr, uptbhreq->objarray[lcancelclmcnt].bill_status_cd = dcanceledcd, uptbhreq->
           objarray[lcancelclmcnt].updt_cnt = objbobillheader->objarray[d1.seq].updt_cnt,
           uptbhreq->objarray[lcancelclmcnt].active_ind = 0
          ENDIF
         WITH nocounter
        ;end select
       ENDIF
       IF ((objuptboreq->objarray[uptbohpcnt].bo_hp_status_cd != dinvalidcd))
        CALL echo("Inactivating Records")
        SET objuptboreq->objarray[uptbohpcnt].active_ind = 0
        SET objuptboreq->objarray[uptbohpcnt].benefit_order_id = 0.0
        SET objuptboreq->objarray[uptbohpcnt].active_status_cd = reqdata->inactive_status_cd
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5))),
     (dummyt d2  WITH seq = value(size(sptemp2->temp,5)))
    PLAN (d1
     WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd=dselfpayfccd)
      AND (objbenefitorderrep->objarray[d1.seq].pft_encntr_id=evaluate(mpeid,0.0,objbenefitorderrep->
      objarray[d1.seq].pft_encntr_id,mpeid)))
     JOIN (d2
     WHERE (sptemp2->temp[d2.seq].pft_encntr_id=objbenefitorderrep->objarray[d1.seq].pft_encntr_id))
    DETAIL
     uptbohpcnt = (size(objuptboreq->objarray,5)+ 1), stat = alterlist(objuptboreq->objarray,
      uptbohpcnt), objuptboreq->objarray[uptbohpcnt].benefit_order_id = objbenefitorderrep->objarray[
     d1.seq].benefit_order_id,
     objuptboreq->objarray[uptbohpcnt].bo_hp_reltn_id = objbenefitorderrep->objarray[d1.seq].
     bo_hp_reltn_id, objuptboreq->objarray[uptbohpcnt].bhr_updt_cnt = objbenefitorderrep->objarray[d1
     .seq].bhr_updt_cnt, objuptboreq->objarray[uptbohpcnt].bo_updt_cnt = objbenefitorderrep->
     objarray[d1.seq].bo_updt_cnt,
     objuptboreq->objarray[uptbohpcnt].active_ind = 1, objuptboreq->objarray[uptbohpcnt].
     active_status_cd = reqdata->active_status_cd, objuptboreq->objarray[uptbohpcnt].pft_proration_id
      = objbenefitorderrep->objarray[d1.seq].pft_proration_id,
     objuptboreq->objarray[uptbohpcnt].pro_updt_cnt = objbenefitorderrep->objarray[d1.seq].
     pro_updt_cnt
     IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
     nhpexpirelogicvar != 1)) )
      IF (size(objpmhealthplan->objarray,5) > 0)
       CALL echo("Priority Seq in Fin COB is Greater than one."), chpsize = size(objpmhealthplan->
        objarray,5)
       IF ((objpmhealthplan->objarray[chpsize].fin_class_cd != dselfpayfccd))
        objuptboreq->objarray[uptbohpcnt].priority_seq = (chpsize+ 1)
       ELSE
        objuptboreq->objarray[uptbohpcnt].priority_seq = chpsize
       ENDIF
      ELSE
       objuptboreq->objarray[uptbohpcnt].priority_seq = 1
      ENDIF
     ELSE
      IF (size(currentcob->objarray,5) > 0)
       CALL echo("Priority Seq in Clinical COB is Greater than one."), chpsize = size(currentcob->
        objarray,5)
       IF ((currentcob->objarray[chpsize].financial_class_cd != dselfpayfccd))
        objuptboreq->objarray[uptbohpcnt].priority_seq = (chpsize+ 1)
       ELSE
        objuptboreq->objarray[uptbohpcnt].priority_seq = chpsize
       ENDIF
      ELSE
       objuptboreq->objarray[uptbohpcnt].priority_seq = 1
      ENDIF
     ENDIF
     objuptboreq->objarray[uptbohpcnt].encntr_plan_reltn_id = objbenefitorderrep->objarray[d1.seq].
     encntr_plan_reltn_id, objuptboreq->objarray[uptbohpcnt].pft_encntr_id = objbenefitorderrep->
     objarray[d1.seq].pft_encntr_id, objuptboreq->objarray[uptbohpcnt].bo_hp_status_cd =
     objbenefitorderrep->objarray[d1.seq].bo_hp_status_cd,
     objuptboreq->objarray[uptbohpcnt].curr_amt_due = (objbenefitorderrep->objarray[d1.seq].
     curr_amt_due+ sptemp2->temp[d2.seq].balance)
     IF (hpid > 0.0)
      objuptboreq->objarray[uptbohpcnt].health_plan_id = hpid
     ELSE
      objuptboreq->objarray[uptbohpcnt].health_plan_id = objbenefitorderrep->objarray[d1.seq].
      health_plan_id
     ENDIF
     IF ((objuptboreq->objarray[uptbohpcnt].curr_amt_due > 0.0))
      objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 1
     ELSEIF ((objuptboreq->objarray[uptbohpcnt].curr_amt_due=0.0))
      objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 0
     ELSE
      objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 2
     ENDIF
    WITH nocounter
   ;end select
   CALL echorecord(objuptboreq)
   IF (size(objuptboreq->objarray,5) > 0)
    CALL echo("Calling Invalidate Benefit Order Save!!!!!!!!!")
    EXECUTE pft_benefit_order_save  WITH replace("REQUEST",objuptboreq), replace("REPLY",reply)
    IF ((reply->status_data.status != "S"))
     CALL echo("Benefit Order Failed")
     GO TO program_exit
    ENDIF
   ENDIF
   CALL echorecord(objuptboreq)
   SET uptbohpcnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(objuptboreq->objarray,5)))
    PLAN (d1
     WHERE (objuptboreq->objarray[d1.seq].active_ind=0))
    DETAIL
     uptbohpcnt += 1, stat = alterlist(wfdequeuereq->entity,uptbohpcnt), wfdequeuereq->entity[
     uptbohpcnt].pft_entity_type_cd = dwfinsurancecd,
     wfdequeuereq->entity[uptbohpcnt].pft_entity_status_cd = dwfcompleteeventcd, wfdequeuereq->
     entity[uptbohpcnt].bo_hp_reltn_id = objuptboreq->objarray[d1.seq].bo_hp_reltn_id
    WITH nocounter
   ;end select
   SET wfdequeuereq->pft_publish_ind = 1
   CALL echorecord(wfdequeuereq)
   EXECUTE pft_wf_publish_state_queue  WITH replace("REQUEST",wfdequeuereq), replace("REPLY",
    wfdequeuerep)
   CALL echorecord(wfdequeuerep)
 END ;Subroutine
 SUBROUTINE (updateselfpaynonprimary(priority_seq=i4) =i2)
   DECLARE dsptransbal = f8
   DECLARE dcurrspbalance = f8
   DECLARE duptdatedspbal = f8
   DECLARE spbohpcnt = i4
   DECLARE nsppriorityseq = i4 WITH noconstant(0)
   DECLARE lspcnt2 = i4
   DECLARE dbobalance = f8 WITH protect, noconstant(0.0)
   FREE RECORD sptemp2
   RECORD sptemp2(
     1 temp[*]
       2 bo_hp_reltn_id = f8
       2 balance = f8
   )
   CALL echo("Update SP BoHp")
   IF (size(objtransfindrep->objarray,5)=0)
    SET objtransfindrep->hide_charges_ind = 1
    SET objtransfindrep->ein_type = ein_pft_encntr
    EXECUTE pft_transaction_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
     objtransfindrep), replace("REPLY",reply)
    IF ((reply->status_data="F"))
     CALL echo("pft_transaction_find FAILED.")
     GO TO program_exit
    ENDIF
   ENDIF
   IF (size(objtransfindrep->objarray,5) > 0)
    SELECT INTO "nl:"
     dbohpid = objbenefitorderrep->objarray[d1.seq].bo_hp_reltn_id
     FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5))),
      (dummyt d2  WITH seq = value(size(objtransfindrep->objarray,5)))
     PLAN (d1
      WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
       AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd=dselfpayfccd)
       AND (objbenefitorderrep->objarray[d1.seq].pft_encntr_id=evaluate(mpeid,0.0,objbenefitorderrep
       ->objarray[d1.seq].pft_encntr_id,mpeid)))
      JOIN (d2
      WHERE (objtransfindrep->objarray[d2.seq].bo_hp_reltn_id=objbenefitorderrep->objarray[d1.seq].
      bo_hp_reltn_id)
       AND (objtransfindrep->objarray[d2.seq].reversal_ind != 1)
       AND (objtransfindrep->objarray[d2.seq].reversed_ind != 1))
     ORDER BY dbohpid
     HEAD dbohpid
      lspcnt2 += 1, stat = alterlist(sptemp2->temp,lspcnt2), sptemp2->temp[lspcnt2].bo_hp_reltn_id =
      objbenefitorderrep->objarray[d1.seq].bo_hp_reltn_id,
      dsptransbal = 0.0
     DETAIL
      dsptransbal += objtransfindrep->objarray[d2.seq].total_trans_amount, sptemp2->temp[lspcnt2].
      balance = dsptransbal
     WITH nocounter
    ;end select
   ENDIF
   IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
   nhpexpirelogicvar != 1)) )
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = size(objpmhealthplan->objarray,5))
     PLAN (d1
      WHERE (objpmhealthplan->objarray[d1.seq].fin_class_cd=dselfpayfccd))
     DETAIL
      nsppriorityseq = size(objpmhealthplan->objarray,5)
     WITH nocounter
    ;end select
    SET nsppriorityseq = evaluate(nsppriorityseq,0,(size(objpmhealthplan->objarray,5)+ 1),
     nsppriorityseq)
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = size(currentcob->objarray,5))
     PLAN (d1
      WHERE (currentcob->objarray[d1.seq].financial_class_cd=dselfpayfccd))
     DETAIL
      nsppriorityseq = size(currentcob->objarray,5)
     WITH nocounter
    ;end select
    SET nsppriorityseq = evaluate(nsppriorityseq,0,(size(currentcob->objarray,5)+ 1),nsppriorityseq)
   ENDIF
   CALL echo("Adding SP BoHp to Update Record")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5)))
    PLAN (d1
     WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd=dselfpayfccd)
      AND (objbenefitorderrep->objarray[d1.seq].pft_encntr_id=evaluate(mpeid,0.0,objbenefitorderrep->
      objarray[d1.seq].pft_encntr_id,mpeid)))
    DETAIL
     spbohpcnt = (size(objuptboreq->objarray,5)+ 1), stat = alterlist(objuptboreq->objarray,spbohpcnt
      ), objuptboreq->objarray[spbohpcnt].bo_hp_reltn_id = objbenefitorderrep->objarray[d1.seq].
     bo_hp_reltn_id,
     objuptboreq->objarray[spbohpcnt].bhr_updt_cnt = objbenefitorderrep->objarray[d1.seq].
     bhr_updt_cnt, objuptboreq->objarray[spbohpcnt].active_ind = 1, objuptboreq->objarray[spbohpcnt].
     active_status_cd = reqdata->active_status_cd,
     objuptboreq->objarray[spbohpcnt].pft_proration_id = objbenefitorderrep->objarray[d1.seq].
     pft_proration_id, objuptboreq->objarray[spbohpcnt].pro_updt_cnt = objbenefitorderrep->objarray[
     d1.seq].pro_updt_cnt, objuptboreq->objarray[spbohpcnt].priority_seq = nsppriorityseq,
     objuptboreq->objarray[spbohpcnt].health_plan_id = objbenefitorderrep->objarray[d1.seq].
     health_plan_id, objuptboreq->objarray[spbohpcnt].encntr_plan_reltn_id = objbenefitorderrep->
     objarray[d1.seq].encntr_plan_reltn_id, objuptboreq->objarray[spbohpcnt].pft_encntr_id =
     objbenefitorderrep->objarray[d1.seq].pft_encntr_id,
     objuptboreq->objarray[spbohpcnt].bo_hp_status_cd = dreadytobillcd, dbobalance =
     objbenefitorderrep->objarray[d1.seq].curr_amt_due, objuptboreq->objarray[spbohpcnt].curr_amt_due
      = duptdatedspbal
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(sptemp2->temp,5))),
     (dummyt d2  WITH seq = value(size(objuptboreq->objarray,5)))
    PLAN (d1
     WHERE (sptemp2->temp[d1.seq].bo_hp_reltn_id > 0.0))
     JOIN (d2
     WHERE (objuptboreq->objarray[d2.seq].bo_hp_reltn_id=sptemp2->temp[d1.seq].bo_hp_reltn_id))
    DETAIL
     objuptboreq->objarray[d2.seq].curr_amt_due = sptemp2->temp[d1.seq].balance
     IF ((objuptboreq->objarray[d2.seq].curr_amt_due > 0.0))
      objuptboreq->objarray[d2.seq].curr_amount_dr_cr_flag = 1
     ELSEIF ((objuptboreq->objarray[d2.seq].curr_amt_due=0.0))
      objuptboreq->objarray[d2.seq].curr_amount_dr_cr_flag = 0
     ELSE
      objuptboreq->objarray[d2.seq].curr_amount_dr_cr_flag = 2
     ENDIF
    WITH nocounter
   ;end select
   IF (dbobalance != 0.0
    AND ((dbobalance - dsptransbal) != 0.0))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(objuptboreq->objarray,5))),
      pft_bill_activity pba
     PLAN (d1)
      JOIN (pba
      WHERE (pba.bo_hp_reltn_id=objuptboreq->objarray[d1.seq].bo_hp_reltn_id)
       AND pba.bill_activity_type_cd=mdbillactcd)
     DETAIL
      nnprolledspind = 1
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (invalidatebosingle(bocnt=i4,bhcnt=i4,trancnt=i4) =i2)
   CALL echo("InvalidateBOSingle")
   DECLARE dtotaltransamt = f8
   DECLARE tempboforcrosscnt = i4
   DECLARE tempbocount = i4
   DECLARE tempbillcnt = i4
   FREE RECORD tempboforcross
   RECORD tempboforcross(
     1 bo[*]
       2 benefit_order_id = f8
       2 invalidateind = i2
       2 bohpid = f8
   )
   FREE RECORD reqbo
   RECORD reqbo(
     1 objarray[1]
       2 pft_encntr_id = f8
   )
   FREE RECORD objtempbobillheader
   RECORD objtempbobillheader(
     1 obj_vrsn_1 = c1
     1 ein_type = i4
     1 proxy_ind = i2
     1 objarray[*]
       2 benefit_order_id = f8
       2 bill_status_cd = f8
       2 bo_hp_reltn_id = f8
       2 submit_dt_tm = dq8
   )
   IF (trancnt > 0)
    SELECT INTO "nl:"
     dbohpid = objuptboreq->objarray[d1.seq].bo_hp_reltn_id
     FROM (dummyt d1  WITH seq = value(bocnt)),
      (dummyt d2  WITH seq = value(trancnt))
     PLAN (d1)
      JOIN (d2
      WHERE (objtransfindrep->objarray[d2.seq].bo_hp_reltn_id=objuptboreq->objarray[d1.seq].
      bo_hp_reltn_id)
       AND (objtransfindrep->objarray[d2.seq].reversal_ind != 1)
       AND (objtransfindrep->objarray[d2.seq].reversed_ind != 1))
     ORDER BY dbohpid
     HEAD dbohpid
      dtotaltransamt = 0.0, objuptboreq->objarray[d1.seq].bo_hp_status_cd = dinvalidcd
     DETAIL
      CALL echo(build("Trans Amt: ",objtransfindrep->objarray[d2.seq].total_trans_amount)),
      dtotaltransamt += objtransfindrep->objarray[d2.seq].total_trans_amount, objuptboreq->objarray[
      d1.seq].curr_amt_due = dtotaltransamt
      IF ((objuptboreq->objarray[d1.seq].curr_amt_due > 0.0))
       objuptboreq->objarray[d1.seq].curr_amount_dr_cr_flag = 1
      ELSEIF ((objuptboreq->objarray[d1.seq].curr_amt_due=0.0))
       objuptboreq->objarray[d1.seq].curr_amount_dr_cr_flag = 0
      ELSE
       objuptboreq->objarray[d1.seq].curr_amount_dr_cr_flag = 2
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (bhcnt > 0)
    CALL echo("Looking for submitted Claims")
    SELECT INTO "nl:"
     invalidbohp = objuptboreq->objarray[d1.seq].bo_hp_reltn_id
     FROM (dummyt d1  WITH seq = value(bocnt)),
      (dummyt d2  WITH seq = value(bhcnt))
     PLAN (d1)
      JOIN (d2
      WHERE (objbobillheader->objarray[d2.seq].bill_type_cd IN (md1450cd, md1500cd))
       AND (((objbobillheader->objarray[d2.seq].bill_status_cd IN (dsubmittedcd, dtransmittedcd,
      ddeniedcd, ddeniedreviewcd))) OR ((objbobillheader->objarray[d2.seq].submit_dt_tm > 0)))
       AND (objbobillheader->objarray[d2.seq].bo_hp_reltn_id=objuptboreq->objarray[d1.seq].
      bo_hp_reltn_id))
     ORDER BY invalidbohp
     HEAD invalidbohp
      CALL echo("Invalidate BoHp!!!!!!!!!!!!!!!!!"), objuptboreq->objarray[d1.seq].bo_hp_status_cd =
      dinvalidcd
     DETAIL
      CALL echo("Submitted or Transmitted Claim")
     WITH nocounter
    ;end select
    IF ((objuptboreq->objarray[1].priority_seq=2))
     CALL echo("looking for crossovers")
     SELECT INTO "nl:"
      benefitorder = objbobillheader->objarray[d3.seq].benefit_order_id
      FROM (dummyt d1  WITH seq = value(bocnt)),
       (dummyt d2  WITH seq = value(size(objbenefitorderrep->objarray,5))),
       (dummyt d3  WITH seq = value(bhcnt))
      PLAN (d1
       WHERE (objuptboreq->objarray[d1.seq].priority_seq=2))
       JOIN (d2
       WHERE (objbenefitorderrep->objarray[d2.seq].bo_hp_reltn_id=objuptboreq->objarray[d1.seq].
       bo_hp_reltn_id))
       JOIN (d3
       WHERE (objbobillheader->objarray[d3.seq].bill_type_cd IN (md1450cd, md1500cd))
        AND (objbobillheader->objarray[d3.seq].bill_status_cd=dtransmittebycrosscd)
        AND (objbobillheader->objarray[d3.seq].bo_hp_reltn_id=objbenefitorderrep->objarray[d2.seq].
       bo_hp_reltn_id))
      ORDER BY benefitorder
      HEAD benefitorder
       tempboforcrosscnt += 1, stat = alterlist(tempboforcross->bo,tempboforcrosscnt), tempboforcross
       ->bo[tempboforcrosscnt].benefit_order_id = benefitorder,
       tempboforcross->bo[tempboforcrosscnt].bohpid = objbobillheader->objarray[d3.seq].
       bo_hp_reltn_id
      DETAIL
       CALL echo("Transmitted for Crossover Claims.")
      WITH nocounter
     ;end select
     CALL echorecord(tempboforcross)
     IF (curqual != 0)
      SET objtempbobillheader->ein_type = ein_pft_encntr
      EXECUTE pft_bill_header_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
       objtempbobillheader), replace("REPLY",reply)
      IF ((reply->status_data="F"))
       CALL echo("pft_bill_header_find FAILED.")
       GO TO program_exit
      ENDIF
      CALL echorecord(objtempbobillheader)
      FOR (tempboforcrosscnt = 1 TO size(tempboforcross->bo,5))
       CALL echo(build("BO ID: ",tempboforcross->bo[tempboforcrosscnt].benefit_order_id))
       FOR (tempbocount = 1 TO size(objbenefitorderrep->objarray,5))
         IF ((tempboforcross->bo[tempboforcrosscnt].benefit_order_id=objbenefitorderrep->objarray[
         tempbocount].benefit_order_id)
          AND (objbenefitorderrep->objarray[tempbocount].priority_seq=1))
          CALL echo("Found Priority Seq One for BO.")
          FOR (tempbillcnt = 1 TO size(objtempbobillheader->objarray,5))
           CALL echo("Looping through bills")
           IF ((objtempbobillheader->objarray[tempbillcnt].bo_hp_reltn_id=objbenefitorderrep->
           objarray[tempbocount].bo_hp_reltn_id)
            AND (((objtempbobillheader->objarray[tempbillcnt].bill_status_cd IN (dsubmittedcd,
           dtransmittedcd, ddeniedcd, ddeniedreviewcd))) OR ((objtempbobillheader->objarray[
           tempbillcnt].submit_dt_tm > 0))) )
            CALL echo("Found a Submitted Claim")
            SET tempboforcross->bo[tempboforcrosscnt].invalidateind = 1
           ENDIF
          ENDFOR
         ENDIF
       ENDFOR
      ENDFOR
      CALL echorecord(tempboforcross)
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = value(size(tempboforcross->bo,5))),
        (dummyt d2  WITH seq = value(bocnt))
       PLAN (d1
        WHERE (tempboforcross->bo[d1.seq].invalidateind=1))
        JOIN (d2
        WHERE (objuptboreq->objarray[d2.seq].bo_hp_reltn_id=tempboforcross->bo[d1.seq].bohpid)
         AND (objuptboreq->objarray[d2.seq].priority_seq=2))
       DETAIL
        CALL echo("Invalidate BoHp!!!!!!!!!!!!!!!!!"), objuptboreq->objarray[d2.seq].bo_hp_status_cd
         = dinvalidcd
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (inactivatebosingle(bocnt=i4,bhcnt=i4) =i2)
   CALL echo("InactivateBOSingle")
   DECLARE lcancelclmcnt = i4
   IF (bhcnt > 0)
    SET stat = initrec(voidedclaimslist)
    SET voidedclaimcount = 0
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(bhcnt)),
      bo_hp_reltn bhr,
      bill_reltn brl,
      bill_rec brec
     PLAN (d1
      WHERE (objbobillheader->objarray[d1.seq].bo_hp_reltn_id > 0.00))
      JOIN (bhr
      WHERE (bhr.bo_hp_reltn_id=objbobillheader->objarray[d1.seq].bo_hp_reltn_id)
       AND bhr.active_ind=true)
      JOIN (brl
      WHERE brl.parent_entity_id=bhr.bo_hp_reltn_id
       AND brl.parent_entity_name="BO_HP_RELTN"
       AND brl.active_ind=true)
      JOIN (brec
      WHERE brec.corsp_activity_id=brl.corsp_activity_id
       AND brec.active_ind=true)
     ORDER BY bhr.bo_hp_reltn_id, brec.gen_dt_tm, brec.corsp_activity_id
     HEAD bhr.bo_hp_reltn_id
      isvoidedclaimfound = false
     DETAIL
      IF (isvoidedclaimfound
       AND brec.bill_status_cd != cs18935_canceled_cd)
       voidedclaimcount += 1, stat = alterlist(voidedclaimslist->claims,voidedclaimcount),
       voidedclaimslist->claims[voidedclaimcount].corspactivityid = brec.corsp_activity_id,
       isvoidedclaimfound = false
      ENDIF
      IF (brec.bill_status_cd=cs18935_canceled_cd
       AND brec.bill_status_reason_cd=cs22089_voided_cd)
       isvoidedclaimfound = true
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(bocnt)),
      (dummyt d2  WITH seq = value(bhcnt))
     PLAN (d1)
      JOIN (d2
      WHERE (objbobillheader->objarray[d2.seq].bill_type_cd IN (md1450cd, md1500cd))
       AND  NOT ((objbobillheader->objarray[d2.seq].bill_status_cd IN (dsubmittedcd, dtransmittedcd,
      dcanceledcd, dtransmittebycrosscd, ddeniedcd,
      ddeniedreviewcd)))
       AND (objbobillheader->objarray[d2.seq].submit_dt_tm=0.0)
       AND (objbobillheader->objarray[d2.seq].bo_hp_reltn_id=objuptboreq->objarray[d1.seq].
      bo_hp_reltn_id)
       AND  NOT (expand(num,1,size(voidedclaimslist->claims,5),objbobillheader->objarray[d2.seq].
       corsp_activity_id,voidedclaimslist->claims[num].corspactivityid)))
     DETAIL
      CALL echo("Cancelling Claim"), lcancelclmcnt += 1,
      CALL echo("Claims below submitted and not cancelled"),
      stat = alterlist(uptbhreq->objarray,lcancelclmcnt), uptbhreq->objarray[lcancelclmcnt].
      corsp_activity_id = objbobillheader->objarray[d2.seq].corsp_activity_id, uptbhreq->objarray[
      lcancelclmcnt].bill_vrsn_nbr = objbobillheader->objarray[d2.seq].bill_vrsn_nbr,
      uptbhreq->objarray[lcancelclmcnt].bill_status_cd = dcanceledcd, uptbhreq->objarray[
      lcancelclmcnt].updt_cnt = objbobillheader->objarray[d2.seq].updt_cnt, uptbhreq->objarray[
      lcancelclmcnt].active_ind = 0
     WITH nocounter
    ;end select
    IF (size(uptbhreq->objarray,5) > 0)
     EXECUTE pft_bill_header_save  WITH replace("REQUEST",uptbhreq), replace("REPLY",reply)
     IF ((reply->status_data.status != "S"))
      GO TO program_exit
     ENDIF
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(bocnt))
    PLAN (d1
     WHERE (objuptboreq->objarray[d1.seq].bo_hp_status_cd != dinvalidcd))
    DETAIL
     CALL echo("InActive Count"), objuptboreq->objarray[d1.seq].active_ind = 0, objuptboreq->
     objarray[d1.seq].benefit_order_id = 0.0,
     objuptboreq->objarray[d1.seq].active_status_cd = reqdata->inactive_status_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE findexpectedtrans(bocnt)
  DECLARE lrevexpcnt = i4
  IF (bocnt > 0)
   SELECT INTO "nl:"
    dbohpid = objuptboreq->objarray[d1.seq].bo_hp_reltn_id, dtempactivityid = objtransfindrep->
    objarray[d3.seq].activity_id
    FROM (dummyt d1  WITH seq = value(bocnt)),
     (dummyt d2  WITH seq = value(size(objbobillheader->objarray,5))),
     (dummyt d3  WITH seq = value(size(objtransfindrep->objarray,5)))
    PLAN (d1)
     JOIN (d2
     WHERE (objbobillheader->objarray[d2.seq].bo_hp_reltn_id=objuptboreq->objarray[d1.seq].
     bo_hp_reltn_id)
      AND (objbobillheader->objarray[d2.seq].bill_status_cd IN (dsubmittedcd, dtransmittedcd,
     ddeniedcd, ddeniedreviewcd))
      AND (objbobillheader->objarray[d2.seq].bill_type_cd IN (md1450cd, md1500cd)))
     JOIN (d3
     WHERE (objtransfindrep->objarray[d3.seq].bo_hp_reltn_id=objbobillheader->objarray[d2.seq].
     bo_hp_reltn_id)
      AND (objtransfindrep->objarray[d3.seq].trans_type_cd=demadjcd)
      AND (objtransfindrep->objarray[d3.seq].trans_sub_type_cd=dexpreimadjcd)
      AND (objtransfindrep->objarray[d3.seq].reversal_ind=0)
      AND (objtransfindrep->objarray[d3.seq].reversal_ind=0))
    ORDER BY dbohpid, dtempactivityid
    HEAD dtempactivityid
     lrevexpcnt += 1, stat = alterlist(objreversereq->objarray,lrevexpcnt), objreversereq->objarray[
     lrevexpcnt].activity_id = objtransfindrep->objarray[d3.seq].activity_id
    DETAIL
     CALL echo("Claim submitted for Secondary")
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE (retrievebo(priorityseq=i4) =i2)
  DECLARE bocnt = i4
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5)))
   PLAN (d1
    WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
     AND (objbenefitorderrep->objarray[d1.seq].bo_hp_status_cd != dinvalidcd)
     AND (objbenefitorderrep->objarray[d1.seq].priority_seq=priorityseq)
     AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd))
   DETAIL
    CALL echo("BoHp Qualified"), bocnt = (size(objuptboreq->objarray,5)+ 1), stat = alterlist(
     objuptboreq->objarray,bocnt),
    objuptboreq->objarray[bocnt].bo_hp_reltn_id = objbenefitorderrep->objarray[d1.seq].bo_hp_reltn_id,
    objuptboreq->objarray[bocnt].bhr_updt_cnt = objbenefitorderrep->objarray[d1.seq].bhr_updt_cnt,
    objuptboreq->objarray[bocnt].active_ind = 1,
    objuptboreq->objarray[bocnt].active_status_cd = reqdata->active_status_cd, objuptboreq->objarray[
    bocnt].pft_proration_id = objbenefitorderrep->objarray[d1.seq].pft_proration_id, objuptboreq->
    objarray[bocnt].pro_updt_cnt = objbenefitorderrep->objarray[d1.seq].pro_updt_cnt,
    objuptboreq->objarray[bocnt].priority_seq = objbenefitorderrep->objarray[d1.seq].priority_seq,
    objuptboreq->objarray[bocnt].health_plan_id = objbenefitorderrep->objarray[d1.seq].health_plan_id,
    objuptboreq->objarray[bocnt].encntr_plan_reltn_id = objbenefitorderrep->objarray[d1.seq].
    encntr_plan_reltn_id,
    objuptboreq->objarray[bocnt].pft_encntr_id = objbenefitorderrep->objarray[d1.seq].pft_encntr_id
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE processprimarychangesp(dummvar)
   DECLARE spcnt = i4
   DECLARE ipriority_seq = i2
   DECLARE tencntr_plan_reltn_id = f8 WITH noconstant(0.0)
   SET nselfpayfound = 0
   IF (size(objpmhealthplan->objarray,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = size(objpmhealthplan->objarray,5))
     PLAN (d1
      WHERE (objpmhealthplan->objarray[d1.seq].fin_class_cd=dselfpayfccd))
     DETAIL
      dnewhealthplanid = objpmhealthplan->objarray[d1.seq].hp_id, ipriority_seq = size(
       objpmhealthplan->objarray,5), tencntr_plan_reltn_id = objpmhealthplan->objarray[d1.seq].
      encntr_plan_reltn_id,
      nselfpayfound = 1
     WITH nocounter
    ;end select
   ENDIF
   IF (nselfpayfound=0)
    SET objbeinforequest->objarray[1].billing_entity_id = objfinencntrmod->objarray[1].
    billing_entity_id
    EXECUTE pft_find_billing_entity  WITH replace("REPLY",objbeinforeply), replace("REQUEST",
     objbeinforequest), replace("OBJREPLY",objbeinfo)
    IF ((objbeinforeply->status_data.status != "S"))
     GO TO program_exit
    ELSE
     SET dnewhealthplanid = objbeinforeply->objarray[1].default_selfpay_hp_id
     SET ipriority_seq = (size(objpmhealthplan->objarray,5)+ 1)
    ENDIF
   ENDIF
   CALL echo(build("HP Selfpay ID: ",dnewhealthplanid))
   CALL echo(build("HP Selfpay Priority: ",ipriority_seq))
   IF (((nfinclasschange=1) OR (nencntrtypechange=1)) )
    CALL echo("Fin Class Changed or Encounter Type Change")
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
     PLAN (d1
      WHERE (objfinencntrmod->objarray[d1.seq].active_ind > 0))
     DETAIL
      IF (nfinclasschange=1)
       CALL echo("Fin Class Changed"), objfinencntrmod->objarray[d1.seq].fin_class_cd = request->
       n_fin_class_cd
      ENDIF
     WITH nocounter
    ;end select
    EXECUTE pft_fin_encntr_save  WITH replace("REQUEST",objfinencntrmod), replace("REPLY",reply)
    IF ((reply->status_data.status != "S"))
     CALL echo("Fin Encntr Save Failed!!!!!!!!!!!!!!")
     GO TO program_exit
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5)))
    PLAN (d1
     WHERE (objbenefitorderrep->objarray[d1.seq].fin_class_cd=dselfpayfccd))
    DETAIL
     spcnt += 1, stat = alterlist(objuptbospreq->objarray,spcnt), objuptbospreq->objarray[spcnt].
     benefit_order_id = objbenefitorderrep->objarray[d1.seq].benefit_order_id,
     objuptbospreq->objarray[spcnt].bhr_updt_cnt = objbenefitorderrep->objarray[d1.seq].bhr_updt_cnt,
     objuptbospreq->objarray[spcnt].bo_hp_reltn_id = objbenefitorderrep->objarray[d1.seq].
     bo_hp_reltn_id, objuptbospreq->objarray[spcnt].bo_updt_cnt = objbenefitorderrep->objarray[d1.seq
     ].bo_updt_cnt,
     objuptbospreq->objarray[spcnt].pft_proration_id = objbenefitorderrep->objarray[d1.seq].
     pft_proration_id, objuptbospreq->objarray[spcnt].pro_updt_cnt = objbenefitorderrep->objarray[d1
     .seq].pro_updt_cnt, objuptbospreq->objarray[spcnt].health_plan_id = dnewhealthplanid,
     objuptbospreq->objarray[spcnt].priority_seq = ipriority_seq, objuptbospreq->objarray[spcnt].
     encntr_plan_reltn_id = tencntr_plan_reltn_id
    WITH nocounter
   ;end select
   CALL echorecord(objuptbospreq)
   SET objbobillheader->ein_type = ein_benefit_order
   EXECUTE pft_bill_header_find  WITH replace("REQUEST",objbenefitorderrep), replace("OBJREPLY",
    objbobillheader), replace("REPLY",reply)
   IF ((reply->status_data="F"))
    CALL echo("pft_bill_header_find FAILED.")
    GO TO program_exit
   ENDIF
   IF (size(objuptbospreq->objarray,5) > 0)
    CALL echo("Calling Invalidate Benefit Order Save!!!!!!!!!")
    EXECUTE pft_benefit_order_save  WITH replace("REQUEST",objuptbospreq), replace("REPLY",reply)
    IF ((reply->status_data.status != "S"))
     CALL echo("Benefit Order Failed")
     GO TO program_exit
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (processprimarychange(chrgcnt=i4) =i2)
   CALL echo("Process Primary Change")
   DECLARE dnewbohptotal = f8
   DECLARE lencntcnt = i4
   DECLARE lchargcnt = i4
   DECLARE lwfcnt = i4
   DECLARE lreverseexpcnt = i4
   DECLARE lpbmcnt = i4
   IF (((nfinclasschange=1) OR (nencntrtypechange=1)) )
    CALL echo("Fin Class Changed or Encounter Type Change")
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
     PLAN (d1
      WHERE (objfinencntrmod->objarray[d1.seq].active_ind > 0))
     DETAIL
      IF (nfinclasschange=1)
       CALL echo("Fin Class Changed"), objfinencntrmod->objarray[d1.seq].fin_class_cd = request->
       n_fin_class_cd
      ENDIF
     WITH nocounter
    ;end select
    EXECUTE pft_fin_encntr_save  WITH replace("REQUEST",objfinencntrmod), replace("REPLY",reply)
    IF ((reply->status_data.status != "S"))
     CALL echo("Fin Encntr Save Failed!!!!!!!!!!!!!!")
     GO TO program_exit
    ENDIF
   ENDIF
   IF (size(temprecurencntr->objarray,5) > 0)
    SET objfincharge->ein_type = ein_pft_encntr
    EXECUTE pft_charge_find  WITH replace("REQUEST",temprecurencntr), replace("OBJREPLY",objfincharge
     ), replace("REPLY",reply)
   ELSE
    SET objfincharge->ein_type = ein_encounter
    SET objchargerequest->objarray[1].encntr_id = request->o_encntr_id
    EXECUTE pft_charge_find  WITH replace("REQUEST",objchargerequest), replace("OBJREPLY",
     objfincharge), replace("REPLY",reply)
   ENDIF
   IF ((reply->status_data.status != "S"))
    GO TO program_exit
   ENDIF
   SET objbobillheader->ein_type = ein_benefit_order
   EXECUTE pft_bill_header_find  WITH replace("REQUEST",objbenefitorderrep), replace("OBJREPLY",
    objbobillheader), replace("REPLY",reply)
   IF ((reply->status_data="F"))
    CALL echo("pft_bill_header_find FAILED.")
    GO TO program_exit
   ENDIF
   IF (size(objbobillheader->objarray,5) > 0
    AND nencntrtypechange=1)
    SELECT INTO "nl:"
     finencntrid = objfinencntrmod->objarray[d1.seq].pft_encntr_id
     FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5))),
      (dummyt d2  WITH seq = value(size(objbobillheader->objarray,5)))
     PLAN (d1
      WHERE (objfinencntrmod->objarray[d1.seq].active_ind > 0))
      JOIN (d2
      WHERE (objbobillheader->objarray[d2.seq].pft_encntr_id=objfinencntrmod->objarray[d1.seq].
      pft_encntr_id)
       AND (objbobillheader->objarray[d2.seq].bill_type_cd IN (md1450cd, md1500cd))
       AND (objbobillheader->objarray[d2.seq].bill_status_cd != dcanceledcd))
     ORDER BY finencntrid
     HEAD finencntrid
      lwfcnt += 1, stat = alterlist(wfrequest->entity,lwfcnt), wfrequest->entity[lwfcnt].entity_id =
      objfinencntrmod->objarray[d1.seq].pft_encntr_id,
      wfrequest->entity[lwfcnt].pft_entity_status_cd = dwfdemmodcd, wfrequest->entity[lwfcnt].
      pft_entity_type_cd = dwfencntrcd
     DETAIL
      CALL echo(build("Fin Encntr: ",finencntrid))
     WITH nocounter
    ;end select
    IF (lwfcnt > 0)
     CALL echorecord(wfrequest)
     CALL sendencntrtoworkflow(dwfeventcd)
     CALL echo("Out of Send Encntr to Workflow for Modify Encntr Type")
    ENDIF
    SET lwfcnt = 0
    SET stat = alterlist(wfrequest->entity,0)
    SET stat = alterlist(addcommentrequest->objarray,0)
   ENDIF
   SET objtransfindrep->hide_charges_ind = 1
   SET objtransfindrep->ein_type = ein_pft_encntr
   EXECUTE pft_transaction_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
    objtransfindrep), replace("REPLY",reply)
   CALL echorecord(objtransfindrep)
   IF ((reply->status_data="F"))
    CALL echo("pft_transaction_find FAILED.")
    GO TO program_exit
   ENDIF
   CALL echo("Getting Ready to Find Adjustments to Reverse!!!!!!!!!")
   IF (size(objtransfindrep->objarray,5) > 0
    AND size(objbobillheader->objarray,5))
    SELECT INTO "nl:"
     dbohpid = objbenefitorderrep->objarray[d1.seq].bo_hp_reltn_id, dtempactivityid = objtransfindrep
     ->objarray[d3.seq].activity_id
     FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5))),
      (dummyt d2  WITH seq = value(size(objbobillheader->objarray,5))),
      (dummyt d3  WITH seq = value(size(objtransfindrep->objarray,5)))
     PLAN (d1
      WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
       AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd))
      JOIN (d2
      WHERE (objbobillheader->objarray[d2.seq].bo_hp_reltn_id=objbenefitorderrep->objarray[d1.seq].
      bo_hp_reltn_id)
       AND (objbobillheader->objarray[d2.seq].bill_status_cd IN (dsubmittedcd, dtransmittedcd,
      ddeniedcd, ddeniedreviewcd))
       AND (objbobillheader->objarray[d2.seq].bill_type_cd IN (md1450cd, md1500cd)))
      JOIN (d3
      WHERE (objtransfindrep->objarray[d3.seq].bo_hp_reltn_id=objbobillheader->objarray[d2.seq].
      bo_hp_reltn_id)
       AND (objtransfindrep->objarray[d3.seq].trans_type_cd=demadjcd)
       AND (objtransfindrep->objarray[d3.seq].trans_sub_type_cd=dexpreimadjcd)
       AND (objtransfindrep->objarray[d3.seq].reversal_ind=0)
       AND (objtransfindrep->objarray[d3.seq].reversed_ind=0))
     ORDER BY dbohpid, dtempactivityid
     HEAD dtempactivityid
      lreverseexpcnt += 1, stat = alterlist(objreversereq->objarray,lreverseexpcnt), objreversereq->
      objarray[lreverseexpcnt].activity_id = objtransfindrep->objarray[d3.seq].activity_id
     DETAIL
      CALL echo("Submitted Claims")
     WITH nocounter
    ;end select
   ENDIF
   CALL echorecord(objreversereq)
   IF (size(objreversereq->objarray,5) > 0)
    EXECUTE pft_reverse_transaction  WITH replace("REQUEST",objreversereq), replace("REPLY",reply)
    CALL echorecord(reply)
    IF ((reply->status_data.status != "S"))
     CALL echorecord(reply)
     GO TO program_exit
    ENDIF
    CALL echo("calling Benefit Order find again, after Transactions")
    SET stat = alterlist(objbenefitorderrep->objarray,0)
    EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod),
    replace("OBJREPLY",objbenefitorderrep)
    CALL echorecord(objbenefitorderrep)
    IF ((reply->status_data.status="F"))
     SET reply->status_data.status = "F"
     GO TO program_exit
    ELSEIF ((reply->status_data.status="Z"))
     SET reply->status_data.status = "Z"
     GO TO program_exit
    ENDIF
    SET stat = alterlist(objtransfindrep->objarray,0)
    EXECUTE pft_transaction_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
     objtransfindrep), replace("REPLY",reply)
    IF ((reply->status_data="F"))
     CALL echo("pft_transaction_find FAILED.")
     GO TO program_exit
    ENDIF
    CALL echo("out of Reversals")
    CALL echorecord(objbenefitorderrep)
    CALL echorecord(objtransfindrep)
   ENDIF
   CALL echo("Calling Invalidate Benefit Order!!!!!!!!!!!!!!!!!!!!!!!!!!")
   CALL invalidatebo(size(objbenefitorderrep->objarray,5),size(objbobillheader->objarray,5),size(
     objtransfindrep->objarray,5))
   CALL echorecord(objuptboreq)
   IF (size(objuptboreq->objarray,5) > 0
    AND size(objbobillheader->objarray,5) > 0)
    SELECT INTO "nl:"
     finencntrid = objfinencntrmod->objarray[d1.seq].pft_encntr_id
     FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5))),
      (dummyt d2  WITH seq = value(size(objuptboreq->objarray,5))),
      (dummyt d3  WITH seq = value(size(objbobillheader->objarray,5)))
     PLAN (d1
      WHERE (objfinencntrmod->objarray[d1.seq].active_ind > 0))
      JOIN (d2
      WHERE (objuptboreq->objarray[d2.seq].pft_encntr_id=objfinencntrmod->objarray[d1.seq].
      pft_encntr_id)
       AND (objuptboreq->objarray[d2.seq].bo_status_cd=dinvalidcd))
      JOIN (d3
      WHERE (objbobillheader->objarray[d3.seq].bo_hp_reltn_id=objuptboreq->objarray[d2.seq].
      bo_hp_reltn_id)
       AND (objbobillheader->objarray[d3.seq].bill_type_cd IN (md1450cd, md1500cd))
       AND (objbobillheader->objarray[d3.seq].bill_status_cd IN (dsubmittedcd, dtransmittedcd,
      ddeniedcd, ddeniedreviewcd)))
     ORDER BY finencntrid
     HEAD finencntrid
      lwfcnt += 1, stat = alterlist(wfrequest->entity,lwfcnt), wfrequest->entity[lwfcnt].entity_id =
      objfinencntrmod->objarray[d1.seq].pft_encntr_id,
      wfrequest->entity[lwfcnt].pft_entity_status_cd = dwfdemmodcd, wfrequest->entity[lwfcnt].
      pft_entity_type_cd = dwfencntrcd, stat = alterlist(addcommentrequest->objarray,lwfcnt),
      addcommentrequest->objarray[lwfcnt].pft_encntr_id = objfinencntrmod->objarray[d1.seq].
      pft_encntr_id, addcommentrequest->objarray[lwfcnt].corsp_desc =
      "Modified Health Plan after claim was submitted.", addcommentrequest->objarray[lwfcnt].
      importance_flag = 2,
      addcommentrequest->objarray[lwfcnt].created_dt_tm = cnvtdatetime(sysdate)
     DETAIL
      CALL echo(build("Fin Encntr: ",finencntrid))
     WITH nocounter
    ;end select
    IF (lwfcnt > 0)
     CALL sendencntrtoworkflow(dwfeventcd)
     CALL echorecord(addcommentrequest)
     EXECUTE pft_apply_comment_for_encntr  WITH replace("REQUEST",addcommentrequest), replace("REPLY",
      addcommentreply)
     IF ((addcommentreply->status_data.status != "S"))
      GO TO program_exit
     ENDIF
    ENDIF
    SET lwfcnt = 0
    SET stat = alterlist(wfrequest->entity,0)
    SET stat = alterlist(addcommentrequest->objarray,0)
   ENDIF
   CALL inactivatebo(size(objbenefitorderrep->objarray,5),size(objbobillheader->objarray,5))
   CALL echo("out of InActivate subroutine!!!!!!!!!!!!!!!")
   CALL echorecord(objuptboreq)
   CALL updateselfpay(size(objbenefitorderrep->objarray,5))
   CALL echorecord(objuptboreq)
   IF (size(objuptboreq->objarray,5) > 0)
    CALL echo("Calling Invalidate Benefit Order Save!!!!!!!!!")
    EXECUTE pft_benefit_order_save  WITH replace("REQUEST",objuptboreq), replace("REPLY",reply)
    IF ((reply->status_data.status != "S"))
     CALL echo("Benefit Order Failed")
     GO TO program_exit
    ENDIF
   ENDIF
   IF (findfinencntrs(0)=false)
    GO TO program_exit
   ENDIF
   CALL echo("Checking for copy claims to invalidate...")
   CALL echorecord(objfinencntrmod)
   EXECUTE pft_eval_imebohp_for_encntrmod  WITH replace("REQUEST",objfinencntrmod), replace("REPLY",
    reply)
   CALL echo(build("status of copy claims",reply->status_data.status))
   IF ((reply->status_data.status="F"))
    CALL echo("pft_eval_ccbohp_for_encntrmod failed.")
    GO TO program_exit
   ENDIF
   CALL echo(
    "*****************************Calling pft_add_charge_to_bo ************************************")
   SET lchargcnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(objfincharge->objarray,5))),
     account a
    PLAN (d1)
     JOIN (a
     WHERE (a.acct_id=objfincharge->objarray[d1.seq].acct_id)
      AND a.acct_type_cd=mdaracct
      AND a.acct_sub_type_cd=dpataccttypecd)
    ORDER BY objfincharge->objarray[d1.seq].pft_encntr_id
    DETAIL
     lchargcnt += 1, stat = alterlist(pactbreq->pftcharges,lchargcnt), pactbreq->pftcharges[lchargcnt
     ].pftchargeid = objfincharge->objarray[d1.seq].pft_charge_id
    WITH nocounter
   ;end select
   IF (size(pactbreq->pftcharges,5) > 0)
    CALL echorecord(pactbreq)
    EXECUTE pft_add_charge_to_bo_legacy  WITH replace("REQUEST",pactbreq), replace("REPLY",pactbrep)
    CALL echo(
     "*****************************Back pft_add_charge_to_bo ***********************************")
    IF ((pactbrep->status_data.status != "S"))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "pft_bo_hp_gen"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "New BoHps did not Generate."
     GO TO program_exit
    ENDIF
   ENDIF
   CALL reevaluateholds(size(objfinencntrmod->objarray,5))
   CALL echorecord(relholdrequest)
   CALL echorecord(applyholdrequest)
   IF (size(relholdrequest->objarray,5) > 0)
    EXECUTE pft_rel_bill_hold_suspension  WITH replace("REQUEST",relholdrequest), replace("REPLY",
     reply)
    IF ((reply->status_data.status != "S"))
     CALL echo("Hold Release Suspension Failed")
     GO TO program_exit
    ENDIF
   ENDIF
   IF (size(applyholdrequest->objarray,5) > 0)
    EXECUTE pft_apply_bill_hold_suspension  WITH replace("REQUEST",applyholdrequest), replace("REPLY",
     reply)
    IF ((reply->status_data.status != "S"))
     CALL echo("applyHoldRequest")
     GO TO program_exit
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
    PLAN (d1
     WHERE (objfinencntrmod->objarray[d1.seq].active_ind > 0))
    DETAIL
     lpbmcnt += 1, stat = alterlist(em_pbmrequest->objarray,lpbmcnt), em_pbmrequest->objarray[lpbmcnt
     ].event_key = "ENCNTR_REG_EVAL",
     em_pbmrequest->objarray[lpbmcnt].pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id
    WITH nocounter
   ;end select
   IF (size(em_pbmrequest->objarray,5) > 0)
    EXECUTE pft_pbr_wrapper  WITH replace("REQUEST",em_pbmrequest), replace("REPLY",em_pbmreply)
   ENDIF
   CALL echo("Out of First PBM Call")
   CALL echorecord(em_pbmreply)
   SET stat = alterlist(em_pbmrequest->objarray,0)
   SET lpbmcnt = 0
   CALL echo(build("nWFCFoundInd: ",nwfcfoundind))
   IF (nwfcfoundind=0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
     PLAN (d1
      WHERE (objfinencntrmod->objarray[d1.seq].active_ind > 0))
     DETAIL
      CALL echo("Found More Encounters."), lpbmcnt += 1, stat = alterlist(em_pbmrequest->objarray,
       lpbmcnt),
      em_pbmrequest->objarray[lpbmcnt].event_key = "DRG_EVAL", em_pbmrequest->objarray[lpbmcnt].
      pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id
     WITH nocounter
    ;end select
    IF (size(em_pbmrequest->objarray,5) > 0)
     EXECUTE pft_pbr_wrapper  WITH replace("REQUEST",em_pbmrequest), replace("REPLY",em_pbmreply)
     CALL echo("after Second Call")
     CALL echorecord(em_pbmreply)
     IF ((em_pbmreply->status_data.status="S"))
      SET stat = alterlist(relholdrequest->objarray,0)
      FOR (lrulesetidx = 1 TO size(em_pbmreply->rulesets,5))
        IF (size(em_pbmreply->rulesets[lrulesetidx].actions,5)=0)
         CALL echo("Encounter did not qualify for the edit pending hold")
         IF (neditpendinfoundind=1)
          SELECT INTO "nl:"
           FROM (dummyt d  WITH seq = size(em_pbmrequest->objarray,5))
           PLAN (d)
           DETAIL
            lrelholdcount += 1, stat = alterlist(relholdrequest->objarray,lrelholdcount),
            relholdrequest->objarray[lrelholdcount].pft_encntr_id = em_pbmrequest->objarray[d.seq].
            pft_encntr_id,
            relholdrequest->objarray[lrelholdcount].pe_status_reason_cd = deditpending24450cd
           WITH nocounter
          ;end select
          IF (size(relholdrequest->objarray,5) > 0)
           CALL echo("Encounter Previously had edit pending hold that we need to remove")
           EXECUTE pft_rel_bill_hold_suspension  WITH replace("REQUEST",relholdrequest), replace(
            "REPLY",reply)
          ENDIF
          IF ((reply->status_data.status != "S"))
           GO TO program_exit
          ELSE
           CALL echo("Edit Pending Hold Successfully Removed")
          ENDIF
         ENDIF
        ELSE
         CALL echo("Edit Pending Hold Added Successfully via PBM")
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (sendencntrtoworkflow(dqueueeventcd=f8) =i2)
   CALL echo("AFC_ENCNTR_MODS==============================>ENTERING SendEncntrToWorkflow()")
   CALL echo("Parameters Include:")
   SET wfrequest->pft_queue_event_cd = dqueueeventcd
   EXECUTE pft_wf_publish_queue_event  WITH replace("REQUEST",wfrequest), replace("REPLY",wfreply)
   IF ((wfreply->status_data.status != "S"))
    CALL echo("!!!!!!!!!!!!!Failed executing pft_wf_publish_queue_event from SendEncntrToWorkflow.")
    RETURN
   ENDIF
   CALL echo("AFC_ENCNTR_MODS==============================>LEAVING SendEncntrToWorkflow()")
 END ;Subroutine
 SUBROUTINE (updateguarantor(dummyvar=i4) =i2)
   SET trace = callecho
   CALL echo("AFC_ENCNTR_MODS==============================>ENTERING UpdateGuarantor()")
   DECLARE lpeindex = i4
   DECLARE lboindex = i4
   DECLARE lbocnt = i4
   DECLARE nupdatebo = i4 WITH noconstant(0)
   DECLARE nupdatecbos = i4 WITH noconstant(0)
   RECORD uptspbenefitorder(
     1 objarray[*]
       2 pft_encntr_id = f8
       2 cons_bo_sched_id = f8
       2 benefit_order_id = f8
   )
   SET objbenefitorderrep->ein_type = ein_pft_encntr
   EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod),
   replace("OBJREPLY",objbenefitorderrep)
   IF (size(objbenefitorderrep->objarray,5) > 0)
    SELECT INTO "nl:"
     dpft_encntr_id = objbenefitorderrep->objarray[d1.seq].pft_encntr_id
     FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5)))
     PLAN (d1
      WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
       AND (objbenefitorderrep->objarray[d1.seq].bo_hp_status_cd != dinvalidcd)
       AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd)
       AND (objbenefitorderrep->objarray[d1.seq].cons_bo_sched_id > 0.0))
     ORDER BY dpft_encntr_id
     HEAD dpft_encntr_id
      lbocnt += 1, stat = alterlist(uptspbenefitorder->objarray,lbocnt), uptspbenefitorder->objarray[
      lbocnt].pft_encntr_id = objbenefitorderrep->objarray[d1.seq].pft_encntr_id,
      uptspbenefitorder->objarray[lbocnt].cons_bo_sched_id = objbenefitorderrep->objarray[d1.seq].
      cons_bo_sched_id
     DETAIL
      CALL echo("no Counter")
     WITH nocounter
    ;end select
    IF (size(uptspbenefitorder->objarray,5) > 0)
     CALL echorecord(uptspbenefitorder)
     CALL echo("Before Guarantor Update")
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(uptspbenefitorder->objarray,5))),
       (dummyt d2  WITH seq = value(size(objbenefitorderrep->objarray,5)))
      PLAN (d1)
       JOIN (d2
       WHERE (objbenefitorderrep->objarray[d2.seq].pft_encntr_id=uptspbenefitorder->objarray[d1.seq].
       pft_encntr_id)
        AND (objbenefitorderrep->objarray[d2.seq].fin_class_cd=dselfpayfccd)
        AND (objbenefitorderrep->objarray[d2.seq].cons_bo_sched_id=0.0))
      DETAIL
       objbenefitorderrep->objarray[d2.seq].cons_bo_sched_id = uptspbenefitorder->objarray[d1.seq].
       cons_bo_sched_id
      WITH nocounter
     ;end select
     CALL echo("after update")
     CALL echorecord(objbenefitorderrep)
     IF (curqual != 0)
      UPDATE  FROM benefit_order bo,
        (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5)))
       SET bo.cons_bo_sched_id = objbenefitorderrep->objarray[d1.seq].cons_bo_sched_id
       PLAN (d1
        WHERE (objbenefitorderrep->objarray[d1.seq].fin_class_cd=dselfpayfccd))
        JOIN (bo
        WHERE (bo.benefit_order_id=objbenefitorderrep->objarray[d1.seq].benefit_order_id))
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
   ENDIF
   FOR (lpeindex = 1 TO size(objfinencntrmod->objarray,5))
     SET nguarchgind = 0
     EXECUTE pft_cons_bo_sched_find  WITH replace("REQUEST",objbenefitorderrep), replace("OBJREPLY",
      objcbos), replace("REPLY",cons_bo_sched_rep)
     IF ((cons_bo_sched_rep->status_data.status="F"))
      CALL logmsg(curprog,"afc_encntr_mods::pft_cons_bo_sched_find failed in updateGuarantor.",
       log_audit)
      SET reply->status_data.status = "F"
      GO TO program_exit
     ENDIF
     CALL echorecord(objcbos)
     CALL echorecord(objbenefitorderrep)
     CALL echo(build("Fin Encntr guarantor_id: ",objfinencntrmod->objarray[lpeindex].guarantor_id))
     IF ((objfinencntrmod->objarray[lpeindex].guarantor_id > 0.0)
      AND size(objcbos->objarray,5)=0)
      SET nguarchgind = 1
     ENDIF
     IF (size(objcbos->objarray,5) > 0)
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = size(objbenefitorderrep->objarray,5)),
        (dummyt d2  WITH seq = size(objcbos->objarray,5))
       PLAN (d1
        WHERE (objbenefitorderrep->objarray[d1.seq].pft_encntr_id=objfinencntrmod->objarray[lpeindex]
        .pft_encntr_id))
        JOIN (d2
        WHERE (objcbos->objarray[d2.seq].cons_bo_sched_id=objbenefitorderrep->objarray[d1.seq].
        cons_bo_sched_id))
       DETAIL
        CALL echo("in guarantor match:"),
        CALL echo(objcbos->objarray[d2.seq].cons_bo_sched_id),
        CALL echo(objfinencntrmod->objarray[lpeindex].guarantor_id)
        IF ((objcbos->objarray[d2.seq].cons_bo_sched_id > 0.0))
         IF ((objcbos->objarray[d2.seq].person_id != objfinencntrmod->objarray[lpeindex].guarantor_id
         )
          AND (objcbos->objarray[d2.seq].person_id > 0.0))
          nguarchgind = 1
         ELSEIF ((objcbos->objarray[d2.seq].organization_id != objfinencntrmod->objarray[lpeindex].
         guarantor_id)
          AND (objcbos->objarray[d2.seq].organization_id > 0.0))
          nguarchgind = 1
         ENDIF
        ELSE
         IF ((objfinencntrmod->objarray[lpeindex].guarantor_id > 0.0))
          nguarchgind = 1
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
     CALL echo(build("nGuarChgInd:",nguarchgind))
     IF (nguarchgind=0)
      CALL logmsg(curprog,"Guarantor did not change...exiting.",log_audit)
      CALL echo("Guarantor did not change...exiting.")
      RETURN
     ENDIF
     EXECUTE pft_cons_bo_sched_find  WITH replace("REQUEST",objbenefitorderrep), replace("OBJREPLY",
      objcbos), replace("REPLY",cons_bo_sched_rep)
     IF ((cons_bo_sched_rep->status_data.status="F"))
      CALL logmsg(curprog,"afc_encntr_mods::pft_cons_bo_sched_find failed in updateGuarantor.",
       log_audit)
      SET reply->status_data.status = "F"
      GO TO program_exit
     ENDIF
     IF ((objfinencntrmod->objarray[lpeindex].guarantor_id=0.0))
      FOR (lcbosindex = 1 TO size(objcbos->objarray,5))
       SET objcbos->objarray[lcbosindex].active_ind = 0
       SET objcbos->objarray[lcbosindex].active_status_cd = reqdata->inactive_status_cd
      ENDFOR
      SET nupdatecbos = 1
      FOR (lboindex = 1 TO size(objbenefitorderrep->objarray,5))
        SET objbenefitorderrep->objarray[lboindex].cons_bo_sched_id = 0.00
      ENDFOR
      SET nupdatebo = 1
     ELSE
      IF ((objfinencntrmod->objarray[lpeindex].consolidation_cd=dnonconsenccd))
       CALL echo("Non - Consolidated by Encounter")
       IF ((objsingleacct->objarray[1].guarantor_id=0.0))
        SET stat = alterlist(insertparrequest->objarray,1)
        SET insertparrequest->objarray[1].pft_acct_reltn_id = cnvtreal(seq(pft_reltn_seq,nextval))
        SET insertparrequest->objarray[1].parent_entity_name = "PERSON"
        SET insertparrequest->objarray[1].parent_entity_id = objfinencntrmod->objarray[lpeindex].
        guarantor_id
        SET insertparrequest->objarray[1].created_prsnl_id = reqinfo->updt_id
        SET insertparrequest->objarray[1].created_dt_tm = cnvtdatetime(sysdate)
        SET insertparrequest->objarray[1].acct_id = objfinencntrmod->objarray[lpeindex].acct_id
        SET insertparrequest->objarray[1].role_type_cd = dguarantorcd
        SET insertparrequest->objarray[1].active_ind = 1
        SET insertparrequest->objarray[1].active_status_cd = reqdata->active_status_cd
        SET insertparrequest->objarray[1].beg_effective_dt_tm = cnvtdatetime(sysdate)
        SET insertparrequest->objarray[1].end_effective_dt_tm = cnvtdatetime(
         "31-DEC-2100 00:00:00.00")
        SET insertparrequest->objarray[1].updt_cnt = 0
        EXECUTE pft_da_add_pft_acct_reltn  WITH replace("REQUEST",insertparrequest), replace("REPLY",
         reply)
       ENDIF
       IF (size(objcbos->objarray,5)=0)
        SET cbosemrequest->encntr_id = request->o_encntr_id
        SET cbosemrequest->acct_id = objfinencntrmod->objarray[lpeindex].acct_id
        SET cbosemrequest->pft_encntr_id = objfinencntrmod->objarray[lpeindex].pft_encntr_id
        EXECUTE pft_bo_hp_cbos  WITH replace("REQUEST",cbosemrequest), replace("REPLY",cbosemreply)
        CASE (cbosemreply->status_data.status)
         OF "F":
          CALL echo("Failed executing pft_bo_hp_cbos from afc_encntr_mods.")
          CALL logmsg(curprog,"Failed to execute pft_bo_hp_cbos.",log_error)
          GO TO program_exit
         OF "Z":
          RETURN
         OF "S":
          CALL echo("Successfully executed pft_bo_hp_cbos from afc_encntr_mods.")
         ELSE
          CALL echo("Failed executing pft_bo_hp_cbos from afc_encntr_mods.")
          CALL logmsg(curprog,"Failed to execute pft_bo_hp_cbos.",log_error)
          RETURN
        ENDCASE
        FOR (lboindex = 1 TO size(objbenefitorderrep->objarray,5))
          SET objbenefitorderrep->objarray[lboindex].cons_bo_sched_id = cbosemrequest->
          cons_bo_sched_id
        ENDFOR
        SET nupdatebo = 1
       ELSE
        FOR (lcbosloop = 1 TO size(objcbos->objarray,5))
          IF ((objcbos->objarray[lcbosloop].person_id != 0.0))
           SET objcbos->objarray[lcbosloop].person_id = objfinencntrmod->objarray[lpeindex].
           guarantor_id
          ENDIF
          IF ((objcbos->objarray[lcbosloop].organization_id != 0.0))
           SET objcbos->objarray[lcbosloop].organization_id = objfinencntrmod->objarray[lpeindex].
           guarantor_id
          ENDIF
          SET objcbos->objarray[lcbosloop].next_bill_dt_tm = null
          SET objcbos->objarray[lcbosloop].statement_cycle_id = 0.0
          SET objcbos->objarray[lcbosloop].proc_ind = null
        ENDFOR
        SET nupdatecbos = 1
       ENDIF
      ELSE
       CALL echo("Not 'Non - Consolidated by Encounter'")
       SET cbosemrequest->encntr_id = request->o_encntr_id
       SET cbosemrequest->acct_id = objfinencntrmod->objarray[lpeindex].acct_id
       SET cbosemrequest->pft_encntr_id = objfinencntrmod->objarray[lpeindex].pft_encntr_id
       EXECUTE pft_bo_hp_cbos  WITH replace("REQUEST",cbosemrequest), replace("REPLY",cbosemreply)
       CALL echorecord(cbosemrequest)
       CASE (cbosemreply->status_data.status)
        OF "F":
         CALL echo("Failed executing pft_bo_hp_cbos from afc_encntr_mods.")
         CALL logmsg(curprog,"Failed to execute pft_bo_hp_cbos.",log_error)
         GO TO program_exit
        OF "Z":
         RETURN
        OF "S":
         CALL echo("Successfully executed pft_bo_hp_cbos from afc_encntr_mods.")
        ELSE
         CALL echo("Failed executing pft_bo_hp_cbos from afc_encntr_mods.")
         CALL logmsg(curprog,"Failed to execute pft_bo_hp_cbos.",log_error)
         RETURN
       ENDCASE
       FOR (lboindex = 1 TO size(objbenefitorderrep->objarray,5))
         SET objbenefitorderrep->objarray[lboindex].cons_bo_sched_id = cbosemrequest->
         cons_bo_sched_id
       ENDFOR
       SET nupdatebo = 1
       CALL echorecord(objbenefitorderrep)
      ENDIF
     ENDIF
     IF (nupdatebo=1)
      EXECUTE pft_benefit_order_save  WITH replace("REQUEST",objbenefitorderrep), replace("REPLY",
       reply)
      IF ((reply->status_data.status != "S"))
       CALL logmsg(curprog,"FAILED EXECUTING PFT BENEFIT ORDER SAVE IN UPTGUARANTOR()",log_warning)
       GO TO program_exit
      ENDIF
      SET objbenefitorderrep->ein_type = ein_pft_encntr
      EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod),
      replace("OBJREPLY",objbenefitorderrep)
     ENDIF
     IF (nupdatecbos=1)
      EXECUTE pft_cons_bo_sched_save  WITH replace("REQUEST",objcbos), replace("REPLY",reply)
      IF ((reply->status_data.status != "S"))
       CALL echo("PFT_CONS_BO_SCHED_SAVE failed to execute")
       CALL logmsg(curprog,"FAILED EXECUTING cons_bo_sched_save IN UPTGUARANTOR()",log_warning)
       GO TO program_exit
      ENDIF
     ENDIF
   ENDFOR
   CALL echo("AFC_ENCNTR_MODS==============================>LEAVING UptGuarantor()")
 END ;Subroutine
 SUBROUTINE (removepaymentplans(finenctcnt=i4) =i2)
   DECLARE npayplancnt = i2 WITH public, noconstant(0)
   FREE RECORD fppfindreply
   RECORD fppfindreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE RECORD removepayplanreply
   RECORD removepayplanreply(
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
   SET emobjrppformal->ein_type = ein_pft_encntr
   EXECUTE pft_payment_plan_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
    emobjrppformal), replace("REPLY",fppfindreply)
   CALL echo("Done with Payment plan find")
   CALL echorecord(emobjrppformal)
   CALL echorecord(fppfindreply)
   IF ((fppfindreply->status_data.status="F"))
    GO TO program_exit
   ENDIF
   SET npayplancnt = size(emobjrppformal->objarray,5)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(objfinencntrmod->objarray,5))),
     pft_encntr pe
    PLAN (d)
     JOIN (pe
     WHERE (objfinencntrmod->objarray[d.seq].pft_encntr_id=pe.pft_encntr_id)
      AND pe.payment_plan_status_cd > 0.0
      AND pe.payment_plan_flag != 2)
    DETAIL
     npayplancnt += 1, stat = alterlist(emobjrppformal->objarray,npayplancnt), emobjrppformal->
     objarray[npayplancnt].pft_encntr_id = pe.pft_encntr_id
    WITH nocounter
   ;end select
   IF (size(emobjrppformal->objarray,5) > 0)
    CALL echo("doing a pft_remove_payment_plan")
    EXECUTE pft_remove_payment_plan  WITH replace("REQUEST",emobjrppformal), replace("REPLY",
     removepayplanreply)
    IF ((removepayplanreply->status_data.status="F"))
     CALL logmsg(curprog,"FAILED CALLING PFT_REMOVE_PAYMENT_PLAN",log_error)
     GO TO program_exit
    ENDIF
   ENDIF
   FREE RECORD fppfindreply
   FREE RECORD removepayplanreply
 END ;Subroutine
 SUBROUTINE (resetstmtcycles(finenctcnt=i4) =i2)
   CALL echo("Resetting StatCycles")
   DECLARE lpftencntrcnt = i4 WITH noconstant(0)
   CALL findfinencntrs(0)
   IF (nprimarymod=0)
    SET stat = alterlist(objbobillheader->objarray,0)
    SET objbobillheader->ein_type = ein_benefit_order
    EXECUTE pft_bill_header_find  WITH replace("REQUEST",objbenefitorderrep), replace("OBJREPLY",
     objbobillheader), replace("REPLY",objbobillheaderreply)
   ENDIF
   IF (size(objbobillheader->objarray,5) > 0)
    SELECT INTO "nl:"
     pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id
     FROM (dummyt d1  WITH seq = value(finenctcnt)),
      (dummyt d2  WITH seq = value(size(objbobillheader->objarray,5)))
     PLAN (d1
      WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0))
      JOIN (d2
      WHERE (objbobillheader->objarray[d2.seq].pft_encntr_id=objfinencntrmod->objarray[d1.seq].
      pft_encntr_id)
       AND (objbobillheader->objarray[d2.seq].bill_type_cd=dpatstmtcd))
     DETAIL
      nstmtcnt += 1, stat = alterlist(resetstmtrequest->stmt_list,nstmtcnt), resetstmtrequest->
      guarantor_id = objfinencntrmod->objarray[d1.seq].guarantor_id,
      resetstmtrequest->stmt_list[nstmtcnt].pft_encntr_id = objbobillheader->objarray[d2.seq].
      pft_encntr_id, resetstmtrequest->stmt_list[nstmtcnt].corsp_activity_id = objbobillheader->
      objarray[d2.seq].corsp_activity_id, resetstmtrequest->stmt_list[nstmtcnt].bill_vrsn_nbr =
      objbobillheader->objarray[d2.seq].bill_vrsn_nbr,
      resetstmtrequest->stmt_list[nstmtcnt].acct_id = objfinencntrmod->objarray[d1.seq].acct_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("No Statements")
    ENDIF
    CALL echorecord(resetstmtrequest)
    IF (size(resetstmtrequest->stmt_list,5) > 0)
     EXECUTE pft_reset_stmt_for_fin_encntr  WITH replace("REQUEST",resetstmtrequest), replace("REPLY",
      reply)
     CASE (reply->status_data.status)
      OF "F":
       CALL echo("Failed executing pft_reset_stmt_for_fin_encntr.")
       CALL logmsg(curprog,"Failed to execute pft_reset_stmt_for_fin_encntr.",log_error)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].operationname = "pft_reset_stmt_for_fin_encntr"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "Reset Statement Cycle Failed."
       RETURN
      OF "Z":
       CALL echo("Z")
       RETURN
      OF "S":
       CALL echo("Successfully executed pft_reset_stmt_for_fin_encntr.")
      ELSE
       CALL echo("Failed executing pft_reset_stmt_for_fin_encntr.")
       CALL logmsg(curprog,"Failed to execute pft_reset_stmt_for_fin_encntr.",log_error)
       RETURN
     ENDCASE
    ENDIF
   ENDIF
   SET stm_cycle_assigned_ind = 0
   SET stat = initrec(reqtempfe)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
    PLAN (d1
     WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0.0))
    DETAIL
     lpftencntrcnt += 1, stat = alterlist(reqtempfe->objarray,lpftencntrcnt), reqtempfe->objarray[
     lpftencntrcnt].pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id
     IF ((objfinencntrmod->objarray[d1.seq].statement_cycle_id > 0.0))
      stm_cycle_assigned_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SET reqtempfe->context = "Encounter Mods ResetStmtCycles"
   IF (stm_cycle_assigned_ind)
    IF (size(objfinencntrmod->objarray,5) > 0)
     IF (size(objcbos->objarray,5) > 0)
      EXECUTE pft_remove_fe_stmt_cycle  WITH replace("REQUEST",reqtempfe), replace("REPLY",reply)
     ENDIF
    ENDIF
   ENDIF
   IF ((reply->status_data.status="F"))
    CALL logmsg(curprog,"Remove Fin Encntr Stmt Cycle Failed!",log_error)
    GO TO program_exit
   ENDIF
 END ;Subroutine
 SUBROUTINE reevaluateholds(finenctcnt)
   DECLARE baddbchold = i4
   DECLARE baddrughold = i4
   DECLARE nbillcombcnt = i4
   DECLARE nrughldcnt = i4
   DECLARE lholdpftent = i4
   DECLARE lholdpftentrel = i4
   DECLARE encntryear = c4
   DECLARE encntrmonth = c2
   DECLARE encntrday = c2
   DECLARE adate = i4 WITH noconstant(0)
   DECLARE rug_ind = i2
   DECLARE rug_err_ind = i2
   DECLARE rug_sum = i4
   DECLARE rugholdflag = i2
   DECLARE dcombineholdid = f8
   CALL echo("ReEvaluating Holds!!!!!!!!!!!!!!!!!!!!!!!")
   SET objtmpholdfe->active_flag = 2
   SET objtmpholdfe->ein_type = ein_pft_encntr
   EXECUTE pft_hold_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",objtmpholdfe),
   replace("REPLY",reply)
   IF (size(objtmpholdfe->objarray,5) > 0)
    SELECT INTO "nl:"
     pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id
     FROM (dummyt d1  WITH seq = value(finenctcnt)),
      (dummyt d2  WITH seq = value(size(objtmpholdfe->objarray,5)))
     PLAN (d1
      WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0.0))
      JOIN (d2
      WHERE (objtmpholdfe->objarray[d2.seq].pft_encntr_id=objfinencntrmod->objarray[d1.seq].
      pft_encntr_id))
     ORDER BY pft_encntr_id
     DETAIL
      CALL echo(build("Hold Status Reason Cd: ",objtmpholdfe->objarray[d2.seq].pe_status_reason_cd))
      CASE (objtmpholdfe->objarray[d2.seq].pe_status_reason_cd)
       OF dbillcombholdcd:
        IF ((objtmpholdfe->objarray[d2.seq].active_ind=0))
         objfinencntrmod->objarray[d1.seq].ibillholdrel = 1
        ELSE
         objfinencntrmod->objarray[d1.seq].ibillholdrel = 2
        ENDIF
       OF dstdelaycd:
        IF ((objtmpholdfe->objarray[d2.seq].active_ind=0))
         objfinencntrmod->objarray[d1.seq].istddelrel = 1
        ELSE
         objfinencntrmod->objarray[d1.seq].istddelrel = 2
        ENDIF
       OF dnorugcd:
        IF ((objtmpholdfe->objarray[d2.seq].active_ind=0))
         objfinencntrmod->objarray[d1.seq].iskllnurse1 = 1
        ELSE
         objfinencntrmod->objarray[d1.seq].iskllnurse1 = 2
        ENDIF
       OF dbadrugdaycd:
        IF ((objtmpholdfe->objarray[d2.seq].active_ind=0))
         objfinencntrmod->objarray[d1.seq].iskllnurse2 = 1
        ELSE
         objfinencntrmod->objarray[d1.seq].iskllnurse2 = 2
        ENDIF
       OF derrrugcd:
        IF ((objtmpholdfe->objarray[d2.seq].active_ind=0))
         objfinencntrmod->objarray[d1.seq].iskllnurse3 = 1
        ELSE
         objfinencntrmod->objarray[d1.seq].iskllnurse3 = 2
        ENDIF
       OF dwaitforcoding24450cd:
        IF ((objtmpholdfe->objarray[d2.seq].active_ind=1))
         nwfcfoundind = 1,
         CALL echo("Found Waiting for discharge hold.")
        ENDIF
       OF deditpending24450cd:
        IF ((objtmpholdfe->objarray[d2.seq].active_ind=1))
         neditpendinfoundind = 1
        ENDIF
      ENDCASE
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("St Delay Ref: ",dstdelayrefcd))
   SET criteriafindrequest->objarray[1].parent_entity_id = objfinencntrmod->objarray[1].
   billing_entity_id
   SET criteriafindrequest->objarray[1].parent_entity_name = "BILLING_ENTITY"
   EXECUTE pft_criteria_find  WITH replace("REQUEST",criteriafindrequest), replace("OBJREPLY",
    objcriteria), replace("REPLY",reply)
   IF ((reply->status_data.status != "S"))
    CALL echo("--Error Determining Billing Combine Hold--")
    GO TO program_exit
   ENDIF
   CALL echorecord(objfinencntrmod)
   IF (size(objcriteria->objarray,5) > 0)
    CALL echo("Criteria is Available.")
    SELECT INTO "nl:"
     dholdid = objcriteria->objarray[d1.seq].pft_hold_id
     FROM (dummyt d1  WITH seq = value(size(objcriteria->objarray,5)))
     PLAN (d1
      WHERE (objcriteria->objarray[d1.seq].hold_reason_cd=dbillingcombinecd))
     ORDER BY dholdid
     HEAD dholdid
      CALL echo(build("Hold ID:",dholdid)), nbillcombcnt = 0
     DETAIL
      CASE (objcriteria->objarray[d1.seq].hold_criteria_cd)
       OF dhealthplancd:
        CALL echo(build("Criteria for HP: ",objcriteria->objarray[d1.seq].hold_criteria))
        IF ((objcriteria->objarray[d1.seq].hold_criteria=cnvtstring(objpmhealthplan->objarray[1].
         hp_id,17,2)))
         nbillcombcnt += 1
        ENDIF
       OF dcomfromcd:
        CALL echo(build("Combine from Code: ",objcriteria->objarray[d1.seq].hold_criteria))
        IF ((objcriteria->objarray[d1.seq].hold_criteria=cnvtstring(objfinencntrmod->objarray[1].
         encntr_type_cd,17,2)))
         nbillcombcnt += 1
        ENDIF
      ENDCASE
     FOOT  dholdid
      IF (nbillcombcnt=2)
       baddbchold = 1, dcombineholdid = dholdid,
       CALL echo(build("Combine Hold ID",dcombineholdid))
      ENDIF
     WITH nocounter
    ;end select
    CALL echo(build("bAddBCHold: ",baddbchold))
    CALL echo("Calling Rug Code Criteria")
    SELECT INTO "nl:"
     dholdid = objcriteria->objarray[d1.seq].pft_hold_id
     FROM (dummyt d1  WITH seq = value(size(objcriteria->objarray,5)))
     PLAN (d1
      WHERE (objcriteria->objarray[d1.seq].hold_reason_cd=dskillednursecd))
     ORDER BY dholdid
     HEAD dholdid
      CALL echo(build("Hold ID:",dholdid)), nrughldcnt = 0
     DETAIL
      CALL echo("Rug Codes")
      CASE (objcriteria->objarray[d1.seq].hold_criteria_cd)
       OF dhealthplancd:
        CALL echo(build("Criteria for HP: ",objcriteria->objarray[d1.seq].hold_criteria))
        CALL echo(build("Primary HP: ",objpmhealthplan->objarray[1].hp_id))
        IF ((objcriteria->objarray[d1.seq].hold_criteria=cnvtstring(objpmhealthplan->objarray[1].
         hp_id,17,2)))
         nrughldcnt += 1
        ENDIF
       OF dencntrtypecd:
        CALL echo(build("Encntr Type Cd: ",objcriteria->objarray[d1.seq].hold_criteria))
        IF ((objcriteria->objarray[d1.seq].hold_criteria=cnvtstring(objfinencntrmod->objarray[1].
         encntr_type_cd,17,2)))
         nrughldcnt += 1
        ENDIF
      ENDCASE
     FOOT  dholdid
      IF (nrughldcnt=2)
       baddrughold = 1
      ENDIF
     WITH nocounter
    ;end select
    CALL echo(build("Add Hold: ",baddrughold))
    CALL echo("Calling St Delay Criteria")
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(finenctcnt)),
      (dummyt d2  WITH seq = value(size(objcriteria->objarray,5)))
     PLAN (d1
      WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0.0))
      JOIN (d2
      WHERE (objcriteria->objarray[d2.seq].hold_reason_cd=dstdelayrefcd)
       AND (objcriteria->objarray[d2.seq].hold_cd=objfinencntrmod->objarray[d1.seq].encntr_type_cd))
     DETAIL
      CALL echo("Found Criteria for St Delay"),
      CALL echo(build("Hold Flag: ",objcriteria->objarray[d2.seq].hold_flag))
      IF ((objcriteria->objarray[d2.seq].hold_flag=1))
       CALL echo("Using Dicharge Date")
       IF ((objfinencntrmod->objarray[d1.seq].disch_dt_tm IN (0, null)))
        CALL echo("Dicharge Date does = NULL"), objfinencntrmod->objarray[d1.seq].iqualforst = 1
       ELSEIF ((objfinencntrmod->objarray[d1.seq].disch_dt_tm=null)
        AND (objfinencntrmod->objarray[d1.seq].encntr_type_cd=nrecurrenctypecd))
        CALL echo("Recurring Encounter"), encntryear = cnvtstring(objfinencntrmod->objarray[d1.seq].
         recur_current_year), encntrmonth = cnvtstring(objfinencntrmod->objarray[d1.seq].
         recur_current_month),
        encntrday = "01"
        IF (encntrmonth="12")
         encntrmonth = "01", encntryear = cnvtstring((cnvtint(encntryear)+ 1)), adate = cnvtint(
          concat(format(encntrmonth,"##;P0"),format(encntrday,"##;P0"),encntryear))
         IF ((datetimediff(cnvtdatetime(sysdate),cnvtdatetime(cnvtdate(adate),0),1) < objcriteria->
         objarray[d2.seq].stnd_delay)
          AND cnvtdatetime(sysdate) < cnvtdatetime(cnvtdate(adate),0))
          objfinencntrmod->objarray[d1.seq].iqualforst = 1
         ENDIF
        ELSE
         encntrmonth = cnvtstring((cnvtint(encntrmonth)+ 1)),
         CALL echo("Made it into Month < 11 section"), adate = cnvtint(concat(format(encntrmonth,
            "##;P0"),format(encntrday,"##;P0"),encntryear))
         IF ((datetimediff(cnvtdatetime(sysdate),cnvtdatetime(cnvtdate(adate),0),1) < objcriteria->
         objarray[d2.seq].stnd_delay)
          AND cnvtdatetime(sysdate) < cnvtdatetime(cnvtdate(adate),0)
          AND ((month(cnvtdatetime(sysdate)) < cnvtint(objfinencntrmod->objarray[d1.seq].
          recur_current_month)) OR (year(cnvtdatetime(sysdate)) < cnvtint(objfinencntrmod->objarray[
          d1.seq].recur_current_year))) )
          objfinencntrmod->objarray[d1.seq].iqualforst = 1
         ENDIF
        ENDIF
       ELSEIF ( NOT ((objfinencntrmod->objarray[d1.seq].disch_dt_tm IN (0, null))))
        CALL echo("Dicharge Date does != NULL")
        IF ((datetimediff(cnvtdatetime(sysdate),objfinencntrmod->objarray[d1.seq].disch_dt_tm,1) <
        objcriteria->objarray[d2.seq].stnd_delay))
         CALL echo(build("Date and Time Diff: ",datetimediff(cnvtdatetime(sysdate),objfinencntrmod->
           objarray[d1.seq].disch_dt_tm,1))), objfinencntrmod->objarray[d1.seq].iqualforst = 1
        ENDIF
       ENDIF
      ELSE
       CALL echo("Use Last Charge Date")
       IF ( NOT ((objfinencntrmod->objarray[d1.seq].last_charge_dt_tm IN (0, null))))
        IF ((datetimediff(cnvtdatetime(sysdate),objfinencntrmod->objarray[d1.seq].last_charge_dt_tm,1
         ) < objcriteria->objarray[d2.seq].stnd_delay))
         objfinencntrmod->objarray[d1.seq].iqualforst = 1
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (baddbchold=1)
    CALL echo("--BE Requires bill_combine_hold--")
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
     PLAN (d1
      WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0.0))
     DETAIL
      IF ((objfinencntrmod->objarray[d1.seq].ibillholdrel != 2))
       lholdpftent += 1, stat = alterlist(applyholdrequest->objarray,lholdpftent), applyholdrequest->
       objarray[lholdpftent].pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id,
       applyholdrequest->objarray[lholdpftent].pe_status_reason_cd = dbillcombholdcd,
       applyholdrequest->objarray[lholdpftent].pft_hold_id = dcombineholdid
       IF ((objfinencntrmod->objarray[d1.seq].ibillholdrel=1))
        applyholdrequest->objarray[lholdpftent].reapply_ind = 1
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    CALL echo("Possible Relase Combine Holds")
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
     PLAN (d1
      WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0.0)
       AND (objfinencntrmod->objarray[d1.seq].ibillholdrel=2))
     DETAIL
      lholdpftentrel += 1, stat = alterlist(relholdrequest->objarray,lholdpftentrel), relholdrequest
      ->objarray[lholdpftentrel].pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id,
      relholdrequest->objarray[lholdpftentrel].pe_status_reason_cd = dbillcombholdcd
     WITH nocounter
    ;end select
   ENDIF
   IF (baddrughold=1)
    SELECT INTO "nl:"
     FROM pft_encntr_code pec
     WHERE (pec.encntr_id=objfinencntrmod->objarray[1].encntr_id)
     DETAIL
      CALL echo("Pft_Encntr_Code")
      IF (pec.encntr_code_type_flag=1)
       rug_ind = 1, rug_err_ind = pec.code_error_ind
      ENDIF
      rug_sum += pec.encntr_code_duration_days
     WITH nocounter
    ;end select
    IF (rug_ind=0
     AND rugholdflag IN (0, 1))
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
      PLAN (d1
       WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0.0))
      DETAIL
       IF ((objfinencntrmod->objarray[d1.seq].iskllnurse1=0))
        lholdpftent += 1, stat = alterlist(applyholdrequest->objarray,lholdpftent), applyholdrequest
        ->objarray[lholdpftent].pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id,
        applyholdrequest->objarray[lholdpftent].pe_status_reason_cd = dnorugcd
       ENDIF
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
      PLAN (d1
       WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0.0)
        AND (objfinencntrmod->objarray[d1.seq].iskllnurse1=2))
      DETAIL
       lholdpftentrel += 1, stat = alterlist(relholdrequest->objarray,lholdpftentrel), relholdrequest
       ->objarray[lholdpftentrel].pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id,
       relholdrequest->objarray[lholdpftentrel].pe_status_reason_cd = dnorugcd
      WITH nocounter
     ;end select
    ENDIF
    IF ((rug_sum != (datetimediff(objfinencntrmod->objarray[1].disch_dt_tm,objfinencntrmod->objarray[
     1].reg_dt_tm,1)+ 1))
     AND rugholdflag IN (0, 2))
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
      PLAN (d1
       WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0.0))
      DETAIL
       IF ((objfinencntrmod->objarray[d1.seq].iskllnurse2=0))
        lholdpftent += 1, stat = alterlist(applyholdrequest->objarray,lholdpftent), applyholdrequest
        ->objarray[lholdpftent].pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id,
        applyholdrequest->objarray[lholdpftent].pe_status_reason_cd = dbadrugdaycd
       ENDIF
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
      PLAN (d1
       WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0.0)
        AND (objfinencntrmod->objarray[d1.seq].iskllnurse2=2))
      DETAIL
       lholdpftentrel += 1, stat = alterlist(relholdrequest->objarray,lholdpftentrel), relholdrequest
       ->objarray[lholdpftentrel].pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id,
       relholdrequest->objarray[lholdpftentrel].pe_status_reason_cd = dbadrugdaycd
      WITH nocounter
     ;end select
    ENDIF
    IF (rug_err_ind=1)
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
      PLAN (d1
       WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0.0))
      DETAIL
       IF ((objfinencntrmod->objarray[d1.seq].iskllnurse3=0))
        lholdpftent += 1, stat = alterlist(applyholdrequest->objarray,lholdpftent), applyholdrequest
        ->objarray[lholdpftent].pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id,
        applyholdrequest->objarray[lholdpftent].pe_status_reason_cd = derrrugcd
       ENDIF
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(objfinencntrmod->objarray,5)))
      PLAN (d1
       WHERE (objfinencntrmod->objarray[d1.seq].pft_encntr_id > 0.0)
        AND (objfinencntrmod->objarray[d1.seq].iskllnurse3=2))
      DETAIL
       lholdpftentrel += 1, stat = alterlist(relholdrequest->objarray,lholdpftentrel), relholdrequest
       ->objarray[lholdpftentrel].pft_encntr_id = objfinencntrmod->objarray[d1.seq].pft_encntr_id,
       relholdrequest->objarray[lholdpftentrel].pe_status_reason_cd = derrrugcd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   DECLARE arraycount = i4 WITH private
   DECLARE criteriacount = i4 WITH private
   FOR (arraycount = 1 TO size(objfinencntrmod->objarray,5))
     IF ((objfinencntrmod->objarray[arraycount].istddelrel=0))
      IF ((objfinencntrmod->objarray[arraycount].iqualforst=1))
       SET lholdpftent += 1
       SET stat = alterlist(applyholdrequest->objarray,lholdpftent)
       SET applyholdrequest->objarray[lholdpftent].pft_encntr_id = objfinencntrmod->objarray[
       arraycount].pft_encntr_id
       SET applyholdrequest->objarray[lholdpftent].pe_status_reason_cd = dstdelaycd
       FOR (criteriacount = 1 TO value(size(objcriteria->objarray,5)))
         IF ((objcriteria->objarray[criteriacount].hold_reason_cd=dstdelayrefcd))
          SET applyholdrequest->objarray[lholdpftent].pft_hold_id = objcriteria->objarray[
          criteriacount].pft_hold_id
          SET criteriacount = value(size(objcriteria->objarray,5))
         ENDIF
       ENDFOR
      ENDIF
     ELSEIF ((objfinencntrmod->objarray[arraycount].istddelrel=1))
      IF ((objfinencntrmod->objarray[arraycount].iqualforst=1))
       SET lholdpftent += 1
       SET stat = alterlist(applyholdrequest->objarray,lholdpftent)
       SET applyholdrequest->objarray[lholdpftent].reapply_ind = 1
       SET applyholdrequest->objarray[lholdpftent].pft_encntr_id = objfinencntrmod->objarray[
       arraycount].pft_encntr_id
       SET applyholdrequest->objarray[lholdpftent].pe_status_reason_cd = dstdelaycd
       FOR (criteriacount = 1 TO value(size(objcriteria->objarray,5)))
         IF ((objcriteria->objarray[criteriacount].hold_reason_cd=dstdelayrefcd))
          SET applyholdrequest->objarray[lholdpftent].pft_hold_id = objcriteria->objarray[
          criteriacount].pft_hold_id
          SET criteriacount = value(size(objcriteria->objarray,5))
         ENDIF
       ENDFOR
      ENDIF
     ELSEIF ((objfinencntrmod->objarray[arraycount].istddelrel=2))
      IF ((objfinencntrmod->objarray[arraycount].iqualforst=1))
       SET lholdpftent += 1
       SET stat = alterlist(applyholdrequest->objarray,lholdpftent)
       SET applyholdrequest->objarray[lholdpftent].pft_encntr_id = objfinencntrmod->objarray[
       arraycount].pft_encntr_id
       SET applyholdrequest->objarray[lholdpftent].pe_status_reason_cd = dstdelaycd
       FOR (criteriacount = 1 TO value(size(objcriteria->objarray,5)))
         IF ((objcriteria->objarray[criteriacount].hold_reason_cd=dstdelayrefcd))
          SET applyholdrequest->objarray[lholdpftent].pft_hold_id = objcriteria->objarray[
          criteriacount].pft_hold_id
          SET criteriacount = value(size(objcriteria->objarray,5))
         ENDIF
       ENDFOR
      ELSE
       SET lholdpftentrel += 1
       SET stat = alterlist(relholdrequest->objarray,lholdpftentrel)
       SET relholdrequest->objarray[lholdpftentrel].pft_encntr_id = objfinencntrmod->objarray[
       arraycount].pft_encntr_id
       SET relholdrequest->objarray[lholdpftentrel].pe_status_reason_cd = dstdelaycd
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (updateselfpay(bocnt=i4) =i2)
   CALL echo("Updateing SP Benefit Order")
   DECLARE lspcnt = i4
   FREE RECORD sptemp
   RECORD sptemp(
     1 priority_seq = i4
     1 encntr_plan_reltn_id = f8
     1 hp_id = f8
   )
   FREE RECORD sptemp2
   RECORD sptemp2(
     1 temp[*]
       2 bo_hp_reltn_id = f8
       2 balance = f8
   )
   SET nselfpayfound = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(objpmhealthplan->objarray,5))
    PLAN (d1
     WHERE (objpmhealthplan->objarray[d1.seq].fin_class_cd=dselfpayfccd))
    DETAIL
     nselfpayfound = 1, sptemp->priority_seq = size(objpmhealthplan->objarray,5), sptemp->
     encntr_plan_reltn_id = objpmhealthplan->objarray[d1.seq].encntr_plan_reltn_id,
     sptemp->hp_id = objpmhealthplan->objarray[d1.seq].hp_id
    WITH nocounter
   ;end select
   CALL echo(build("nSelfPayFound: ",nselfpayfound))
   IF (nselfpayfound=1)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(bocnt))
     PLAN (d1
      WHERE (objbenefitorderrep->objarray[d1.seq].fin_class_cd=dselfpayfccd))
     DETAIL
      stat = alterlist(objuptboreq->objarray,(size(objuptboreq->objarray,5)+ 1)), lspcnt = size(
       objuptboreq->objarray,5), objuptboreq->objarray[lspcnt].active_ind = 1,
      objuptboreq->objarray[lspcnt].active_status_cd = reqdata->active_status_cd, objuptboreq->
      objarray[lspcnt].benefit_order_id = objbenefitorderrep->objarray[d1.seq].benefit_order_id,
      objuptboreq->objarray[lspcnt].bhr_updt_cnt = objbenefitorderrep->objarray[d1.seq].bhr_updt_cnt,
      objuptboreq->objarray[lspcnt].bo_hp_reltn_id = objbenefitorderrep->objarray[d1.seq].
      bo_hp_reltn_id, objuptboreq->objarray[lspcnt].bo_hp_status_cd = objbenefitorderrep->objarray[d1
      .seq].bo_hp_status_cd, objuptboreq->objarray[lspcnt].bo_status_cd = objbenefitorderrep->
      objarray[d1.seq].bo_status_cd,
      objuptboreq->objarray[lspcnt].bo_updt_cnt = objbenefitorderrep->objarray[d1.seq].bo_updt_cnt,
      objuptboreq->objarray[lspcnt].pft_proration_id = objbenefitorderrep->objarray[d1.seq].
      pft_proration_id, objuptboreq->objarray[lspcnt].pro_updt_cnt = objbenefitorderrep->objarray[d1
      .seq].pro_updt_cnt,
      objuptboreq->objarray[lspcnt].pft_encntr_id = objbenefitorderrep->objarray[d1.seq].
      pft_encntr_id, objuptboreq->objarray[lspcnt].health_plan_id = sptemp->hp_id, objuptboreq->
      objarray[lspcnt].encntr_plan_reltn_id = sptemp->encntr_plan_reltn_id,
      objuptboreq->objarray[lspcnt].priority_seq = sptemp->priority_seq
     WITH nocounter
    ;end select
   ELSE
    SET objbeinforequest->objarray[1].billing_entity_id = objfinencntrmod->objarray[1].
    billing_entity_id
    EXECUTE pft_find_billing_entity  WITH replace("REPLY",objbeinforeply), replace("REQUEST",
     objbeinforequest), replace("OBJREPLY",objbeinfo)
    IF ((objbeinforeply->status_data.status != "S"))
     GO TO program_exit
    ELSE
     SET sptemp->priority_seq = (size(objpmhealthplan->objarray,5)+ 1)
     SET sptemp->encntr_plan_reltn_id = 0.0
     SET sptemp->hp_id = objbeinforeply->objarray[1].default_selfpay_hp_id
    ENDIF
    CALL echorecord(sptemp)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(bocnt))
     PLAN (d1
      WHERE (objbenefitorderrep->objarray[d1.seq].fin_class_cd=dselfpayfccd))
     DETAIL
      CALL echo("SP for No PM SelfPay!!!!!!!!"),
      CALL echo(build("Upt BO Size: ",size(objuptboreq->objarray,5))), stat = alterlist(objuptboreq->
       objarray,(size(objuptboreq->objarray,5)+ 1)),
      CALL echo(build("Upt BO Size: ",size(objuptboreq->objarray,5))), lspcnt = size(objuptboreq->
       objarray,5), objuptboreq->objarray[lspcnt].active_ind = 1,
      objuptboreq->objarray[lspcnt].active_status_cd = reqdata->active_status_cd, objuptboreq->
      objarray[lspcnt].benefit_order_id = objbenefitorderrep->objarray[d1.seq].benefit_order_id,
      objuptboreq->objarray[lspcnt].bhr_updt_cnt = objbenefitorderrep->objarray[d1.seq].bhr_updt_cnt,
      objuptboreq->objarray[lspcnt].bo_hp_reltn_id = objbenefitorderrep->objarray[d1.seq].
      bo_hp_reltn_id, objuptboreq->objarray[lspcnt].bo_hp_status_cd = objbenefitorderrep->objarray[d1
      .seq].bo_hp_status_cd, objuptboreq->objarray[lspcnt].bo_status_cd = objbenefitorderrep->
      objarray[d1.seq].bo_status_cd,
      objuptboreq->objarray[lspcnt].bo_updt_cnt = objbenefitorderrep->objarray[d1.seq].bo_updt_cnt,
      objuptboreq->objarray[lspcnt].pft_proration_id = objbenefitorderrep->objarray[d1.seq].
      pft_proration_id, objuptboreq->objarray[lspcnt].pro_updt_cnt = objbenefitorderrep->objarray[d1
      .seq].pro_updt_cnt,
      objuptboreq->objarray[lspcnt].pft_encntr_id = objbenefitorderrep->objarray[d1.seq].
      pft_encntr_id, objuptboreq->objarray[lspcnt].health_plan_id = sptemp->hp_id, objuptboreq->
      objarray[lspcnt].encntr_plan_reltn_id = sptemp->encntr_plan_reltn_id,
      objuptboreq->objarray[lspcnt].priority_seq = sptemp->priority_seq
     WITH nocounter
    ;end select
   ENDIF
   SET lspcnt = 0
   SELECT INTO "nl:"
    dbohpid = objbenefitorderrep->objarray[d1.seq].bo_hp_reltn_id
    FROM (dummyt d1  WITH seq = value(bocnt)),
     (dummyt d2  WITH seq = value(size(objtransfindrep->objarray,5)))
    PLAN (d1
     WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd=dselfpayfccd))
     JOIN (d2
     WHERE (objtransfindrep->objarray[d2.seq].bo_hp_reltn_id=objbenefitorderrep->objarray[d1.seq].
     bo_hp_reltn_id)
      AND (objtransfindrep->objarray[d2.seq].reversal_ind != 1)
      AND (objtransfindrep->objarray[d2.seq].reversed_ind != 1))
    ORDER BY dbohpid
    HEAD dbohpid
     lspcnt += 1, stat = alterlist(sptemp2->temp,lspcnt), sptemp2->temp[lspcnt].bo_hp_reltn_id =
     objbenefitorderrep->objarray[d1.seq].bo_hp_reltn_id,
     dselfpaytranbal = 0.0
    DETAIL
     dselfpaytranbal += objtransfindrep->objarray[d2.seq].total_trans_amount, sptemp2->temp[lspcnt].
     balance = dselfpaytranbal
    WITH nocounter
   ;end select
   CALL echorecord(sptemp2)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(sptemp2->temp,5))),
     (dummyt d2  WITH seq = value(size(objuptboreq->objarray,5)))
    PLAN (d1
     WHERE (sptemp2->temp[d1.seq].bo_hp_reltn_id > 0.0))
     JOIN (d2
     WHERE (objuptboreq->objarray[d2.seq].bo_hp_reltn_id=sptemp2->temp[d1.seq].bo_hp_reltn_id))
    DETAIL
     objuptboreq->objarray[d2.seq].curr_amt_due = sptemp2->temp[d1.seq].balance
     IF ((objuptboreq->objarray[d2.seq].curr_amt_due > 0.0))
      objuptboreq->objarray[d2.seq].curr_amount_dr_cr_flag = 1
     ELSEIF ((objuptboreq->objarray[d2.seq].curr_amt_due=0.0))
      objuptboreq->objarray[d2.seq].curr_amount_dr_cr_flag = 0
     ELSE
      objuptboreq->objarray[d2.seq].curr_amount_dr_cr_flag = 2
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (invalidatebo(bocnt=i4,bhcnt=i4,trancnt=i4) =i2)
   DECLARE secsubtrancnt = i4
   DECLARE dtotaltransamt = f8
   DECLARE isubtransind = i2
   IF (trancnt > 0)
    SELECT INTO "nl:"
     dbohpid = objbenefitorderrep->objarray[d1.seq].bo_hp_reltn_id
     FROM (dummyt d1  WITH seq = value(bocnt)),
      (dummyt d2  WITH seq = value(trancnt))
     PLAN (d1
      WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
       AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd))
      JOIN (d2
      WHERE (objtransfindrep->objarray[d2.seq].bo_hp_reltn_id=objbenefitorderrep->objarray[d1.seq].
      bo_hp_reltn_id)
       AND (objtransfindrep->objarray[d2.seq].reversal_ind != 1)
       AND (objtransfindrep->objarray[d2.seq].reversed_ind != 1))
     ORDER BY dbohpid
     HEAD dbohpid
      CALL echo(build("Head BOHP: ",dbohpid))
      IF ((objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd))
       uptbohpcnt += 1, stat = alterlist(objuptboreq->objarray,uptbohpcnt), objuptboreq->objarray[
       uptbohpcnt].benefit_order_id = objbenefitorderrep->objarray[d1.seq].benefit_order_id,
       objuptboreq->objarray[uptbohpcnt].bo_hp_reltn_id = objbenefitorderrep->objarray[d1.seq].
       bo_hp_reltn_id, objuptboreq->objarray[uptbohpcnt].bo_status_cd = dinvalidcd, objuptboreq->
       objarray[uptbohpcnt].bo_hp_status_cd = dcompletecd,
       objuptboreq->objarray[uptbohpcnt].bhr_updt_cnt = objbenefitorderrep->objarray[d1.seq].
       bhr_updt_cnt, objuptboreq->objarray[uptbohpcnt].bo_updt_cnt = objbenefitorderrep->objarray[d1
       .seq].bo_updt_cnt, objuptboreq->objarray[uptbohpcnt].active_ind = 1,
       objuptboreq->objarray[uptbohpcnt].active_status_cd = reqdata->active_status_cd, objuptboreq->
       objarray[uptbohpcnt].pft_proration_id = objbenefitorderrep->objarray[d1.seq].pft_proration_id,
       objuptboreq->objarray[uptbohpcnt].pro_updt_cnt = objbenefitorderrep->objarray[d1.seq].
       pro_updt_cnt,
       objuptboreq->objarray[uptbohpcnt].priority_seq = objbenefitorderrep->objarray[d1.seq].
       priority_seq, objuptboreq->objarray[uptbohpcnt].health_plan_id = objbenefitorderrep->objarray[
       d1.seq].health_plan_id, objuptboreq->objarray[uptbohpcnt].encntr_plan_reltn_id =
       objbenefitorderrep->objarray[d1.seq].encntr_plan_reltn_id,
       objuptboreq->objarray[uptbohpcnt].pft_encntr_id = objbenefitorderrep->objarray[d1.seq].
       pft_encntr_id, objbenefitorderrep->objarray[d1.seq].bo_status_cd = dinvalidcd, ninvalidboexist
        = 1
      ENDIF
      dtotaltransamt = 0.0
     DETAIL
      CALL echo("Transactions"),
      CALL echo(build("Transaction: ",objtransfindrep->objarray[d2.seq].total_trans_amount)),
      dtotaltransamt += objtransfindrep->objarray[d2.seq].total_trans_amount,
      objuptboreq->objarray[uptbohpcnt].curr_amt_due = dtotaltransamt
      IF ((objuptboreq->objarray[uptbohpcnt].curr_amt_due > 0.0))
       objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 1
      ELSEIF ((objuptboreq->objarray[uptbohpcnt].curr_amt_due=0.0))
       objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 0
      ELSE
       objuptboreq->objarray[uptbohpcnt].curr_amount_dr_cr_flag = 2
      ENDIF
     WITH nocounter
    ;end select
    CALL echo(build("SelfPay Trasn Amt: ",dselfpaytranbal))
   ENDIF
   IF (bhcnt > 0)
    CALL echo("Looking for submitted Claims")
    SELECT INTO "nl:"
     invalidbohp = objbenefitorderrep->objarray[d1.seq].bo_hp_reltn_id
     FROM (dummyt d1  WITH seq = value(bocnt)),
      (dummyt d2  WITH seq = value(bhcnt))
     PLAN (d1
      WHERE (objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd))
      JOIN (d2
      WHERE (objbobillheader->objarray[d2.seq].bill_type_cd IN (md1450cd, md1500cd))
       AND (((objbobillheader->objarray[d2.seq].bill_status_cd IN (dsubmittedcd, dtransmittedcd,
      dtransmittebycrosscd, ddeniedcd, ddeniedreviewcd))) OR ((objbobillheader->objarray[d2.seq].
      submit_dt_tm > 0)))
       AND (objbobillheader->objarray[d2.seq].bo_hp_reltn_id=objbenefitorderrep->objarray[d1.seq].
      bo_hp_reltn_id))
     ORDER BY invalidbohp
     HEAD invalidbohp
      CALL echo("Invalidate BoHp!!!!!!!!!!!!!!!!!")
      IF ((objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd))
       uptbohpcnt += 1, stat = alterlist(objuptboreq->objarray,uptbohpcnt), objuptboreq->objarray[
       uptbohpcnt].benefit_order_id = objbenefitorderrep->objarray[d1.seq].benefit_order_id,
       objuptboreq->objarray[uptbohpcnt].bo_hp_reltn_id = objbenefitorderrep->objarray[d1.seq].
       bo_hp_reltn_id, objuptboreq->objarray[uptbohpcnt].bo_status_cd = dinvalidcd
       IF ((objbobillheader->objarray[d2.seq].bill_status_cd=dtransmittebycrosscd))
        objuptboreq->objarray[uptbohpcnt].bo_hp_status_cd = dtransmittebycrosscd
       ELSE
        objuptboreq->objarray[uptbohpcnt].bo_hp_status_cd = dcompletecd
       ENDIF
       objuptboreq->objarray[uptbohpcnt].bhr_updt_cnt = objbenefitorderrep->objarray[d1.seq].
       bhr_updt_cnt, objuptboreq->objarray[uptbohpcnt].bo_updt_cnt = objbenefitorderrep->objarray[d1
       .seq].bo_updt_cnt, objuptboreq->objarray[uptbohpcnt].active_ind = 1,
       objuptboreq->objarray[uptbohpcnt].active_status_cd = reqdata->active_status_cd,
       objbenefitorderrep->objarray[d1.seq].bo_status_cd = dinvalidcd, objuptboreq->objarray[
       uptbohpcnt].pft_proration_id = objbenefitorderrep->objarray[d1.seq].pft_proration_id,
       objuptboreq->objarray[uptbohpcnt].pro_updt_cnt = objbenefitorderrep->objarray[d1.seq].
       pro_updt_cnt, objuptboreq->objarray[uptbohpcnt].priority_seq = objbenefitorderrep->objarray[d1
       .seq].priority_seq, objuptboreq->objarray[uptbohpcnt].health_plan_id = objbenefitorderrep->
       objarray[d1.seq].health_plan_id,
       objuptboreq->objarray[uptbohpcnt].encntr_plan_reltn_id = objbenefitorderrep->objarray[d1.seq].
       encntr_plan_reltn_id, objuptboreq->objarray[uptbohpcnt].pft_encntr_id = objbenefitorderrep->
       objarray[d1.seq].pft_encntr_id, ninvalidboexist = 1
      ENDIF
     DETAIL
      CALL echo("Submitted or Transmitted Claim"), isubtransind = 1
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (inactivatebo(bocnt=i4,bhcnt=i4) =i2)
   DECLARE lcancelclmcnt = i4
   DECLARE linactivecnt = i4
   DECLARE lwfdequeuecnt = i4 WITH noconstant(0)
   SET stat = initrec(voidedclaimslist)
   SET voidedclaimcount = 0
   IF (bhcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(bhcnt)),
      bo_hp_reltn bhr,
      bill_reltn brl,
      bill_rec brec
     PLAN (d1
      WHERE (objbobillheader->objarray[d1.seq].bo_hp_reltn_id > 0.00))
      JOIN (bhr
      WHERE (bhr.bo_hp_reltn_id=objbobillheader->objarray[d1.seq].bo_hp_reltn_id)
       AND bhr.active_ind=true)
      JOIN (brl
      WHERE brl.parent_entity_id=bhr.bo_hp_reltn_id
       AND brl.parent_entity_name="BO_HP_RELTN"
       AND brl.active_ind=true)
      JOIN (brec
      WHERE brec.corsp_activity_id=brl.corsp_activity_id
       AND brec.active_ind=true)
     ORDER BY bhr.bo_hp_reltn_id, brec.gen_dt_tm, brec.corsp_activity_id
     HEAD bhr.bo_hp_reltn_id
      isvoidedclaimfound = false
     DETAIL
      IF (isvoidedclaimfound
       AND brec.bill_status_cd != cs18935_canceled_cd)
       voidedclaimcount += 1, stat = alterlist(voidedclaimslist->claims,voidedclaimcount),
       voidedclaimslist->claims[voidedclaimcount].corspactivityid = brec.corsp_activity_id,
       isvoidedclaimfound = false
      ENDIF
      IF (brec.bill_status_cd=cs18935_canceled_cd
       AND brec.bill_status_reason_cd=cs22089_voided_cd)
       isvoidedclaimfound = true
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(bhcnt))
     PLAN (d1
      WHERE (objbobillheader->objarray[d1.seq].bill_type_cd IN (md1450cd, md1500cd))
       AND  NOT ((objbobillheader->objarray[d1.seq].bill_status_cd IN (dsubmittedcd, dtransmittedcd,
      dcanceledcd, dtransmittebycrosscd, ddeniedcd,
      ddeniedreviewcd)))
       AND (objbobillheader->objarray[d1.seq].submit_dt_tm=0.0)
       AND  NOT (expand(num,1,size(voidedclaimslist->claims,5),objbobillheader->objarray[d1.seq].
       corsp_activity_id,voidedclaimslist->claims[num].corspactivityid)))
     DETAIL
      CALL echo("Cancelling Claim"), lcancelclmcnt += 1,
      CALL echo("Claims below submitted and not cancelled"),
      stat = alterlist(uptbhreq->objarray,lcancelclmcnt), uptbhreq->objarray[lcancelclmcnt].
      corsp_activity_id = objbobillheader->objarray[d1.seq].corsp_activity_id, uptbhreq->objarray[
      lcancelclmcnt].bill_vrsn_nbr = objbobillheader->objarray[d1.seq].bill_vrsn_nbr,
      uptbhreq->objarray[lcancelclmcnt].bill_status_cd = dcanceledcd, uptbhreq->objarray[
      lcancelclmcnt].updt_cnt = objbobillheader->objarray[d1.seq].updt_cnt, uptbhreq->objarray[
      lcancelclmcnt].active_ind = 0
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("No Unsubmitted Claims!!!!!!!!!!!!")
    ENDIF
    IF (size(uptbhreq->objarray,5) > 0)
     EXECUTE pft_bill_header_save  WITH replace("REQUEST",uptbhreq), replace("REPLY",reply)
     IF ((reply->status_data.status != "S"))
      GO TO program_exit
     ENDIF
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(bocnt))
    PLAN (d1
     WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[d1.seq].fin_class_cd != dselfpayfccd))
    DETAIL
     CALL echo("InActive Count"), uptbohpcnt += 1, stat = alterlist(objuptboreq->objarray,uptbohpcnt),
     objuptboreq->objarray[uptbohpcnt].active_ind = 0, objuptboreq->objarray[uptbohpcnt].
     bo_hp_status_cd = objbenefitorderrep->objarray[d1.seq].bo_hp_status_cd, objuptboreq->objarray[
     uptbohpcnt].benefit_order_id = objbenefitorderrep->objarray[d1.seq].benefit_order_id,
     objuptboreq->objarray[uptbohpcnt].active_status_cd = reqdata->inactive_status_cd, objuptboreq->
     objarray[uptbohpcnt].bo_hp_reltn_id = objbenefitorderrep->objarray[d1.seq].bo_hp_reltn_id,
     objuptboreq->objarray[uptbohpcnt].bo_updt_cnt = objbenefitorderrep->objarray[d1.seq].bo_updt_cnt,
     objuptboreq->objarray[uptbohpcnt].bhr_updt_cnt = objbenefitorderrep->objarray[d1.seq].
     bhr_updt_cnt, objuptboreq->objarray[uptbohpcnt].pft_proration_id = objbenefitorderrep->objarray[
     d1.seq].pft_proration_id, objuptboreq->objarray[uptbohpcnt].pro_updt_cnt = objbenefitorderrep->
     objarray[d1.seq].pro_updt_cnt,
     objuptboreq->objarray[uptbohpcnt].pft_encntr_id = objbenefitorderrep->objarray[d1.seq].
     pft_encntr_id, objuptboreq->objarray[uptbohpcnt].health_plan_id = objbenefitorderrep->objarray[
     d1.seq].health_plan_id, objuptboreq->objarray[uptbohpcnt].encntr_plan_reltn_id =
     objbenefitorderrep->objarray[d1.seq].encntr_plan_reltn_id,
     objuptboreq->objarray[uptbohpcnt].priority_seq = objbenefitorderrep->objarray[d1.seq].
     priority_seq
    WITH nocounter
   ;end select
   IF (ninvalidboexist=1)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(objuptboreq->objarray,5))),
      (dummyt d2  WITH seq = value(bocnt))
     PLAN (d1
      WHERE (objuptboreq->objarray[d1.seq].active_ind=0))
      JOIN (d2
      WHERE (objbenefitorderrep->objarray[d2.seq].benefit_order_id=objuptboreq->objarray[d1.seq].
      benefit_order_id))
     DETAIL
      CALL echo("found Bohp to reset")
      IF ((objbenefitorderrep->objarray[d2.seq].bo_status_cd=dinvalidcd))
       objuptboreq->objarray[d1.seq].active_ind = 1, objuptboreq->objarray[d1.seq].active_status_cd
        = reqdata->active_status_cd, objuptboreq->objarray[d1.seq].curr_amt_due = 0.0,
       objuptboreq->objarray[d1.seq].curr_amount_dr_cr_flag = 0
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   RECORD wfdequeuereq(
     1 pft_publish_ind = i2
     1 entity[*]
       2 pft_entity_type_cd = f8
       2 pft_entity_status_cd = f8
       2 bo_hp_reltn_id = f8
       2 pft_entity_status_group_cd = f8
       2 pft_entity_sub_status_txt = vc
       2 pft_entity_status_cd_hist = f8
       2 pft_entity_sub_status_txt_hist = vc
       2 entity_balance_hist = f8
       2 entity_balance_hist_dr_cr_flag = i2
       2 pft_queue_item_id = f8
       2 entity_balance = f8
       2 entity_balance_dr_cr_flag = i2
       2 assigned_prsnl_id = f8
       2 contributor_system_cd = f8
       2 corsp_activity_id = f8
       2 pft_encntr_id = f8
       2 acct_id = f8
       2 bill_vrsn_nbr = i4
       2 activity_id = f8
       2 billing_entity_id = f8
       2 encntr_type_cd = f8
       2 med_service_cd = f8
       2 hold_reason_cd = f8
       2 fin_class_cd = f8
       2 payment_plan_flag = i2
       2 primary_hp_fin_class_cd = f8
       2 payor_org_id = f8
       2 primary_hp_org_id = f8
       2 health_plan_id = f8
       2 primary_hp_id = f8
       2 patient_last_name = vc
       2 vip_cd = f8
       2 guarantor_last_name = vc
       2 bill_type_cd = f8
       2 bill_status_reason_cd = f8
       2 bill_temple_id = f8
       2 denial_reason_cd = f8
       2 denial_group_cd = f8
       2 dunning_level_cd = f8
       2 pft_collection_agency_id = f8
       2 rec_exists_ind = i2
       2 change_flag = i2
       2 days_from_discharge = f8
       2 days_from_claim_sub = f8
       2 loc_building_cd = f8
       2 loc_facility_cd = f8
       2 loc_nurseunit_cd = f8
       2 encntr_bal = f8
       2 supervising_physician_id = f8
       2 cal_variance_amt = f8
       2 org_set_id = f8
   )
   RECORD wfdequeuerep(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET wfdequeuereq->pft_publish_ind = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(objuptboreq->objarray,5)))
    WHERE (objuptboreq->objarray[d.seq].active_ind=0)
    DETAIL
     lwfdequeuecnt += 1, stat = alterlist(wfdequeuereq->entity,lwfdequeuecnt), wfdequeuereq->entity[
     lwfdequeuecnt].pft_entity_type_cd = dwfinsurancecd,
     wfdequeuereq->entity[lwfdequeuecnt].pft_entity_status_cd = dwfcompleteeventcd, wfdequeuereq->
     entity[lwfdequeuecnt].bo_hp_reltn_id = objuptboreq->objarray[d.seq].bo_hp_reltn_id
    WITH nocounter
   ;end select
   CALL echorecord(wfdequeuereq)
   EXECUTE pft_wf_publish_state_queue  WITH replace("REQUEST",wfdequeuereq), replace("REPLY",
    wfdequeuerep)
   CALL echorecord(wfdequeuerep)
   CALL echo("End of Inactive BO's")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE evaluatebohpchanges(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5))),
    dummyt d2
   PLAN (d1
    WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
     AND (objbenefitorderrep->objarray[d1.seq].bo_hp_status_cd != dinvalidcd)
     AND maxrec(d2,value(size(objpmhealthplan->objarray,5))))
    JOIN (d2
    WHERE (objpmhealthplan->objarray[d2.seq].priority_seq=objbenefitorderrep->objarray[d1.seq].
    priority_seq)
     AND (objpmhealthplan->objarray[d2.seq].hp_id=objbenefitorderrep->objarray[d1.seq].health_plan_id
    )
     AND (objpmhealthplan->objarray[d2.seq].encntr_plan_reltn_id != objbenefitorderrep->objarray[d1
    .seq].encntr_plan_reltn_id))
   DETAIL
    objbenefitorderrep->objarray[d1.seq].encntr_plan_reltn_id = objpmhealthplan->objarray[d2.seq].
    encntr_plan_reltn_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   EXECUTE pft_benefit_order_save  WITH replace("REQUEST",objbenefitorderrep), replace("REPLY",reply)
   IF ((reply->status_data.status != "S"))
    CALL logmsg(curprog,"pft_benefit_order_save failed in EvaluateBOHPChanges subroutine!",log_error)
    GO TO program_exit
   ENDIF
   EXECUTE pft_benefit_order_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
    objbenefitorderrep), replace("REPLY",reply)
   IF ((reply->status_data.status != "S"))
    CALL logmsg(curprog,"pft_benefit_order_find failed in EvaluateBOHPChanges subroutine!",log_error)
    GO TO program_exit
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (evaluatecobchanges(ccobcnt=i4,fcobcnt=i4) =i2)
   DECLARE hpcnt = i4
   DECLARE prihp = f8
   DECLARE sechp = f8
   DECLARE terhp = f8
   DECLARE defaultselfpayhealthplanid = f8 WITH private, constant(getdefaultselfpayhealthplan(0))
   IF (fcobcnt >= ccobcnt)
    FOR (hpcnt = 1 TO fcobcnt)
      CALL echo(build("Financial HP: ",hpcnt))
      CASE (hpcnt)
       OF 1:
        SET npriexistfincob = 1
        IF ((fincob->fincob[1].selfpay_ind=1))
         SET nprispfincob = 1
        ENDIF
        SET prihp = gethealthplanbypriority(1,1)
        IF (prihp > 0.0)
         SET npriexistclincob = 1
         IF ((objpmhealthplan->objarray[1].fin_class_cd=dselfpayfccd))
          SET nprispclincob = 1
         ENDIF
        ELSE
         SET nprispclincob = 1
        ENDIF
        IF ((prihp != fincob->fincob[1].hp_id))
         SET nprimarymod = 1
        ENDIF
       OF 2:
        CALL echo("Check Secondary Change")
        SET nsecexistfincob = 1
        IF ((fincob->fincob[2].selfpay_ind=1))
         SET nsecspfincob = 1
        ENDIF
        SET sechp = gethealthplanbypriority(2,1)
        IF (sechp > 0.0)
         SET nsecexistclincob = 1
         IF ((objpmhealthplan->objarray[2].fin_class_cd=dselfpayfccd))
          SET nsecspclincob = 1
         ENDIF
        ELSE
         SET nsecspclincob = 1
        ENDIF
        IF ((sechp != fincob->fincob[2].hp_id))
         SET nsecondmod = 1
        ENDIF
       ELSE
        SET nterexistfincob = 1
        CALL echo("Tiertiary Changes")
        SET terhp = gethealthplanbypriority(hpcnt,1)
        IF (terhp > 0.0)
         SET nterexistclincob = 1
        ELSEIF ((fincob->fincob[hpcnt].selfpay_ind=true))
         SET terhp = defaultselfpayhealthplanid
        ENDIF
        IF ((terhp != fincob->fincob[hpcnt].hp_id))
         SET ntertmod = 1
        ENDIF
      ENDCASE
      SET terhp = 0.0
    ENDFOR
   ELSE
    CALL echo("Loop Through Clinicals")
    FOR (hpcnt = 1 TO ccobcnt)
      CALL echo(build("Clinincal HP: ",hpcnt))
      SET npriexistclincob = 1
      CASE (hpcnt)
       OF 1:
        IF ((objpmhealthplan->objarray[1].fin_class_cd=dselfpayfccd))
         SET nprispclincob = 1
        ENDIF
        SET prihp = gethealthplanbypriority(1,2)
        IF (prihp > 0.0)
         SET npriexistfincob = 1
        ENDIF
        IF ((prihp != objpmhealthplan->objarray[1].hp_id))
         SET nprimarymod = 1
        ENDIF
       OF 2:
        SET nsecexistclincob = 1
        IF ((objpmhealthplan->objarray[2].fin_class_cd=dselfpayfccd))
         SET nsecspclincob = 1
        ENDIF
        SET sechp = gethealthplanbypriority(2,2)
        IF (sechp > 0.0)
         SET nsecexistfincob = 1
         IF ((fincob->fincob[2].selfpay_ind=1))
          SET nsecspfincob = 1
         ENDIF
        ENDIF
        IF ((sechp != objpmhealthplan->objarray[2].hp_id))
         SET nsecondmod = 1
        ENDIF
       ELSE
        SET nterexistclincob = 1
        SET terhp = gethealthplanbypriority(hpcnt,2)
        IF (terhp > 0.0)
         SET nterexistfincob = 1
        ENDIF
        IF ((terhp != objpmhealthplan->objarray[hpcnt].hp_id))
         SET ntertmod = 1
        ENDIF
      ENDCASE
      SET terhp = 0.0
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (retrievefinancilcob(bocnt=i4) =i2)
  DECLARE finbocnt = i4
  SELECT DISTINCT INTO "nl:"
   objbenefitorderrep->objarray[d1.seq].priority_seq
   FROM (dummyt d1  WITH seq = value(bocnt))
   PLAN (d1
    WHERE (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
     AND (objbenefitorderrep->objarray[d1.seq].bo_hp_status_cd != dinvalidcd))
   ORDER BY objbenefitorderrep->objarray[d1.seq].priority_seq
   DETAIL
    CALL echo(build("Priority Sequence",objbenefitorderrep->objarray[d1.seq].priority_seq)),
    CALL echo(build("Bohp: ",objbenefitorderrep->objarray[d1.seq].bo_hp_reltn_id)), finbocnt += 1,
    stat = alterlist(fincob->fincob,finbocnt), fincob->fincob[finbocnt].hp_id = objbenefitorderrep->
    objarray[d1.seq].health_plan_id, fincob->fincob[finbocnt].priority_seq = objbenefitorderrep->
    objarray[d1.seq].priority_seq
    IF ((objbenefitorderrep->objarray[d1.seq].fin_class_cd=dselfpayfccd))
     fincob->fincob[finbocnt].selfpay_ind = 1
    ENDIF
    fincob->fincob_cnt = finbocnt
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE (checkhpmodfornonprofit(dencntr_id=f8,oldhpid=f8) =i2)
   SELECT INTO "nl:"
    FROM encntr_plan_reltn epr
    WHERE epr.encntr_id=dencntr_id
     AND epr.priority_seq=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND epr.active_ind=1
    DETAIL
     dnewhealthplanid = epr.health_plan_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dnewhealthplanid = 0.0
   ENDIF
   IF (doldhealthplanid != dnewhealthplanid)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (processcharges(ncurrchargecnt=i4) =i2)
   CALL echo("AFC_ENCNTR_MODS==============================>ENTERING ProcessCharges()")
   CALL echo(" Parameters Include:")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(ncurrchargecnt)),
     (dummyt d2  WITH seq = value(size(interfacefiles->interface_file,5)))
    PLAN (d1
     WHERE (pmcharge->charge_items[d1.seq].offset_charge_item_id=0.0)
      AND (pmcharge->charge_items[d1.seq].process_flg IN (0, 2, 3, 4, 8,
     100, 999))
      AND (pmcharge->charge_items[d1.seq].activity_type_cd != dpmactivitytypecd))
     JOIN (d2
     WHERE (interfacefiles->interface_file[d2.seq].interface_file_id=pmcharge->charge_items[d1.seq].
     interface_file_id))
    DETAIL
     CALL echo(build("Charge Item Id",pmcharge->charge_items[d1.seq].charge_item_id))
     IF ( NOT ((pmcharge->charge_items[d1.seq].charge_type_cd IN (dcredittypecd, dcreditnowtypecd))))
      IF ((interfacefiles->interface_file[d2.seq].profit_type_cd > 0.0))
       pmcharge->charge_items[d1.seq].pftchargeflag = 1,
       CALL echo(build("Reprocess Ind: ",interfacefiles->interface_file[d2.seq].reprocess_ind))
       IF ((interfacefiles->interface_file[d2.seq].reprocess_ind=1))
        CALL echo("Retier Charge"), pmcharge->charge_items[d1.seq].retier_ind = 1, pmcharge->
        charge_items[d1.seq].checkprice_ind = 1,
        nneedtoretier = 1
       ELSE
        CALL echo("Check Price")
        IF ((interfacefiles->interface_file[d2.seq].reprocess_cpt_ind=1))
         CALL echo("Check CPT and Price"), pmcharge->charge_items[d1.seq].checkcpt_ind = 1, pmcharge
         ->charge_items[d1.seq].checkprice_ind = 1
        ELSE
         CALL echo("Check Price"), pmcharge->charge_items[d1.seq].checkprice_ind = 1
        ENDIF
       ENDIF
      ELSE
       IF ((interfacefiles->interface_file[d2.seq].reprocess_ind=1))
        CALL echo("Retier Non-Profit Charge"), pmcharge->charge_items[d1.seq].retier_ind = 1,
        pmcharge->charge_items[d1.seq].checkprice_ind = 1,
        nneedtoretier = 1
       ELSEIF ((interfacefiles->interface_file[d2.seq].reprocess_cpt_ind=1))
        pmcharge->charge_items[d1.seq].checkcpt_ind = 1, pmcharge->charge_items[d1.seq].
        checkprice_ind = 1
       ENDIF
       CALL echo("Do Nothing with Charge")
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (getnewprices(ncurrchargecnt=i4) =i2)
   CALL echo("AFC_ENCNTR_MODS==============================>ENTERING GetNewPrices()")
   CALL echo(" Parameters Include:")
   DECLARE cecnt2 = i2 WITH noconstant(0)
   DECLARE cicnt2 = i2 WITH noconstant(0)
   IF (ncurrchargecnt > 0)
    CALL echorecord(replclinencobj)
    CALL echorecord(pmcharge)
    SET cecnt2 = 0
    SET crelease->process_type_cd = mdnocommitcd
    SELECT INTO "nl:"
     ce_id = pmcharge->charge_items[d1.seq].charge_event_id
     FROM (dummyt d1  WITH seq = value(ncurrchargecnt))
     PLAN (d1
      WHERE (pmcharge->charge_items[d1.seq].checkprice_ind=1))
     ORDER BY ce_id
     HEAD ce_id
      cecnt2 += 1, cicnt2 = 0, stat = alterlist(crelease->process_event,cecnt2),
      crelease->process_event[cecnt2].charge_event_id = pmcharge->charge_items[d1.seq].
      charge_event_id
     DETAIL
      cicnt2 += 1, stat = alterlist(crelease->process_event[cecnt2].charge_item,cicnt2), crelease->
      process_event[cecnt2].charge_item[cicnt2].charge_item_id = pmcharge->charge_items[d1.seq].
      charge_item_id
     WITH nocounter
    ;end select
    SET crelease->charge_event_qual = cecnt2
   ENDIF
   CALL echo("Calling CS Release Charge")
   CALL echorecord(crelease)
   IF (size(crelease->process_event,5) > 0)
    EXECUTE afc_release_charge_sync  WITH replace("REQUEST",crelease), replace("REPLY",creleasereply)
    CALL echorecord(creleasereply)
    SET copylistindex = 0
    IF (size(creleasereply->charges,5) > 0)
     SELECT INTO "nl:"
      charge_item_id = pmcharge->charge_items[d1.seq].charge_item_id
      FROM (dummyt d1  WITH seq = value(ncurrchargecnt))
      PLAN (d1
       WHERE (pmcharge->charge_items[d1.seq].charge_item_id > 0.0)
        AND (pmcharge->charge_items[d1.seq].checkprice_ind=1))
      DETAIL
       CALL echo(build("Tier Group Cd",pmcharge->charge_items[d1.seq].tier_group_cd))
      WITH nocounter
     ;end select
     DECLARE z = i4
     DECLARE y = i4
     DECLARE mybool = i2
     SET mybool = 0
     SELECT INTO "nl:"
      charge_item_id = pmcharge->charge_items[d1.seq].charge_item_id
      FROM (dummyt d1  WITH seq = value(ncurrchargecnt)),
       (dummyt d2  WITH seq = value(size(creleasereply->charges,5)))
      PLAN (d1
       WHERE (pmcharge->charge_items[d1.seq].charge_item_id > 0.0)
        AND (pmcharge->charge_items[d1.seq].activity_type_cd != dpmactivitytypecd)
        AND (((pmcharge->charge_items[d1.seq].checkprice_ind=1)) OR ((pmcharge->charge_items[d1.seq].
       checkcpt_ind=1))) )
       JOIN (d2
       WHERE (creleasereply->charges[d2.seq].charge_act_id=pmcharge->charge_items[d1.seq].
       charge_event_act_id)
        AND (creleasereply->charges[d2.seq].tier_group_cd=pmcharge->charge_items[d1.seq].
       tier_group_cd)
        AND (creleasereply->charges[d2.seq].bill_item_id=pmcharge->charge_items[d1.seq].bill_item_id)
        AND (creleasereply->charges[d2.seq].item_quantity=pmcharge->charge_items[d1.seq].
       item_quantity)
        AND (creleasereply->charges[d2.seq].service_dt_tm=pmcharge->charge_items[d1.seq].
       service_dt_tm)
        AND (creleasereply->charges[d2.seq].item_interval_id=pmcharge->charge_items[d1.seq].
       item_interval_id))
      ORDER BY charge_item_id
      HEAD charge_item_id
       CALL echo(
       "******************************************************************************************"),
       CALL echo(build("Charge Item Id",charge_item_id)),
       CALL echo(build("Description",pmcharge->charge_items[d1.seq].charge_description)),
       CALL echo(
       "******************************************************************************************")
      DETAIL
       CALL echo("------------------------------------------------------------------"),
       CALL echo("------------------------------------------------------------------"),
       CALL echo(build("CReleaseReply ID:",creleasereply->charges[d2.seq].charge_item_id)),
       CALL echo(build("Tier Group:",creleasereply->charges[d2.seq].tier_group_cd)),
       CALL echo(build("Bill Item:",creleasereply->charges[d2.seq].bill_item_id)),
       CALL echo(build("Charge Event:",creleasereply->charges[d2.seq].charge_event_id)),
       CALL echo(build("New Price: ",creleasereply->charges[d2.seq].item_extended_price)),
       CALL echo(build("Old Price: ",pmcharge->charge_items[d1.seq].item_extended_price)),
       CALL echo(build("New Quan: ",creleasereply->charges[d2.seq].item_quantity)),
       CALL echo(build("Old Quan: ",pmcharge->charge_items[d1.seq].item_quantity))
       IF (((cnvtreal(format(pmcharge->charge_items[d1.seq].item_extended_price,"#########.##")) !=
       cnvtreal(format(creleasereply->charges[d2.seq].item_extended_price,"#########.##"))) OR ((
       pmcharge->charge_items[d1.seq].interface_file_id != creleasereply->charges[d2.seq].
       interface_id))) )
        nneedtoretier = 1, pmcharge->charge_items[d1.seq].retier_ind = 1,
        CALL echo("need to retier"),
        stat = movereclist(creleasereply->charges,chargereleasecopy->charges,d2.seq,copylistindex,1,
         true), copylistindex += 1
       ELSEIF ((pmcharge->charge_items[d1.seq].retier_ind=1))
        nneedtoretier = 1, stat = movereclist(creleasereply->charges,chargereleasecopy->charges,d2
         .seq,copylistindex,1,
         true), copylistindex += 1
       ELSE
        IF ((pmcharge->charge_items[d1.seq].pftchargeflag=0))
         IF ((pmcharge->charge_items[d1.seq].checkcpt_ind=1))
          FOR (z = 1 TO size(pmcharge->charge_items[d1.seq].charge_mods,5))
            IF (uar_get_code_meaning(pmcharge->charge_items[d1.seq].charge_mods[z].field1_id)="CPT4"
             AND (pmcharge->charge_items[d1.seq].charge_mods[z].field2_id=1))
             FOR (y = 1 TO size(creleasereply->charges[d1.seq].mods.charge_mods,5))
               IF (validate(creleasereply->charges[d2.seq].mods.charge_mods[y].field6,"NULL_VC")=
               "NULL_VC")
                pmcharge->charge_items[d1.seq].retier_ind = 1, nneedtoretier = 1,
                CALL echo("Need to Retier"),
                stat = movereclist(creleasereply->charges,chargereleasecopy->charges,d2.seq,
                 copylistindex,1,
                 true), copylistindex += 1
               ELSEIF ((pmcharge->charge_items[d1.seq].charge_mods[z].field6 != creleasereply->
               charges[d2.seq].mods.charge_mods[y].field6))
                pmcharge->charge_items[d1.seq].retier_ind = 1, nneedtoretier = 1, stat = movereclist(
                 creleasereply->charges,chargereleasecopy->charges,d2.seq,copylistindex,1,
                 true),
                copylistindex += 1,
                CALL echo("Need to Retier")
               ENDIF
             ENDFOR
            ENDIF
          ENDFOR
         ENDIF
        ELSE
         CALL echo("Do not Retier")
         IF (((size(pmcharge->charge_items[d1.seq].charge_mods,5) > size(creleasereply->charges[d2
          .seq].mods.charge_mods,5)) OR (size(pmcharge->charge_items[d1.seq].charge_mods,5)=size(
          creleasereply->charges[d2.seq].mods.charge_mods,5))) )
          CALL echo("PMCharge is bigger"), globalcount = 0
          IF ((pmcharge->charge_items[d1.seq].service_dt_tm > cnvtdatetime(creleasereply->charges[d2
           .seq].hp_beg_effective_dt_tm))
           AND (pmcharge->charge_items[d1.seq].service_dt_tm <= cnvtdatetime(creleasereply->charges[
           d2.seq].hp_end_effective_dt_tm)))
           FOR (x = 1 TO size(pmcharge->charge_items[d1.seq].charge_mods,5))
             sameflag = 0
             IF ((pmcharge->charge_items[d1.seq].charge_mods[x].charge_mod_type_cd=mdbillcodecd))
              FOR (y = 1 TO size(creleasereply->charges[d2.seq].mods.charge_mods,5))
                IF ((pmcharge->charge_items[d1.seq].charge_mods[x].field1_id=creleasereply->charges[
                d2.seq].mods.charge_mods[y].field1_id)
                 AND (pmcharge->charge_items[d1.seq].charge_mods[x].field2_id=creleasereply->charges[
                d2.seq].mods.charge_mods[y].field2_id)
                 AND (pmcharge->charge_items[d1.seq].charge_mods[x].field6=creleasereply->charges[d2
                .seq].mods.charge_mods[y].field6)
                 AND (pmcharge->charge_items[d1.seq].charge_mods[x].active_ind=1))
                 sameflag = 1
                ENDIF
              ENDFOR
             ENDIF
             IF (sameflag=1)
              globalcount += 1,
              CALL echo(build("globalCount: ",globalcount))
             ENDIF
           ENDFOR
           IF (globalcount != size(pmcharge->charge_items[d1.seq].charge_mods,5))
            pmcharge->charge_items[d1.seq].uptchargemodflag = 1, uptchargemodflag = 1
           ENDIF
          ENDIF
         ELSE
          CALL echo("CReleaseReply is bigger"), globalcount = 0
          IF ((pmcharge->charge_items[d1.seq].service_dt_tm > cnvtdatetime(creleasereply->charges[d2
           .seq].hp_beg_effective_dt_tm))
           AND (pmcharge->charge_items[d1.seq].service_dt_tm <= cnvtdatetime(creleasereply->charges[
           d2.seq].hp_end_effective_dt_tm)))
           FOR (x = 1 TO size(creleasereply->charges[d2.seq].mods.charge_mods,5))
             sameflag = 0
             IF ((creleasereply->charges[d2.seq].mods.charge_mods[x].charge_mod_type_cd=mdbillcodecd)
             )
              FOR (y = 1 TO size(pmcharge->charge_items[d1.seq].charge_mods,5))
                IF ((creleasereply->charges[d2.seq].mods.charge_mods[x].field1_id=pmcharge->
                charge_items[d1.seq].charge_mods[y].field1_id)
                 AND (creleasereply->charges[d2.seq].mods.charge_mods[x].field2_id=pmcharge->
                charge_items[d1.seq].charge_mods[y].field2_id)
                 AND (creleasereply->charges[d2.seq].mods.charge_mods[x].field6=pmcharge->
                charge_items[d1.seq].charge_mods[y].field6))
                 sameflag = 1
                ENDIF
              ENDFOR
             ENDIF
             IF (sameflag=1)
              globalcount += 1,
              CALL echo(build("globalCount: ",globalcount))
             ENDIF
           ENDFOR
           IF (globalcount != size(pmcharge->charge_items[d1.seq].charge_mods,5))
            pmcharge->charge_items[d1.seq].uptchargemodflag = 1, uptchargemodflag = 1
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF (uptchargemodflag=1)
     CALL uptchargemods(0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (retiercharges(ncurrchargecnt=i4) =i2)
   CALL echo("Retier Charges Subroutine")
   UPDATE  FROM charge_event_act cea,
     (dummyt d1  WITH seq = size(chargereleasecopy->charges,5))
    SET cea.item_deductible_amt = 0.0
    PLAN (d1
     WHERE (chargereleasecopy->charges[d1.seq].charge_item_id > 0.0))
     JOIN (cea
     WHERE (cea.charge_event_act_id=chargereleasecopy->charges[d1.seq].charge_act_id))
    WITH nocounter
   ;end update
   DECLARE pbmcnt = i4 WITH noconstant(0)
   DECLARE newmodsindex = i4 WITH noconstant(0)
   DECLARE newinfocnt = i4 WITH noconstant(0)
   DECLARE copymodsindex = i4 WITH noconstant(0)
   SET stat = alterlist(pbmchargecopy->charges,1)
   FOR (pbmcnt = 1 TO size(pmcharge->charge_items,5))
     IF ((pmcharge->charge_items[pbmcnt].retier_ind=1))
      CALL echo(build("quan is = ",pmcharge->charge_items[pbmcnt].item_quantity))
      FOR (newinfocnt = 1 TO size(chargereleasecopy->charges,5))
        IF ((pmcharge->charge_items[pbmcnt].charge_item_id=chargereleasecopy->charges[newinfocnt].
        charge_item_id))
         SET pbmchargecopy->charges[1].charge_item_id = chargereleasecopy->charges[newinfocnt].
         charge_item_id
         SET pbmchargecopy->charges[1].encntr_id = chargereleasecopy->charges[newinfocnt].encntr_id
         SET pbmchargecopy->charges[1].person_id = chargereleasecopy->charges[newinfocnt].person_id
         SET pbmchargecopy->charges[1].fin_class_cd = chargereleasecopy->charges[newinfocnt].
         fin_class_cd
         SET pbmchargecopy->charges[1].health_plan_id = chargereleasecopy->charges[newinfocnt].
         health_plan_id
         SET pbmchargecopy->charges[1].bill_item_id = chargereleasecopy->charges[newinfocnt].
         bill_item_id
         SET pbmchargecopy->charges[1].activity_type_cd = chargereleasecopy->charges[newinfocnt].
         activity_type_cd
         SET newinfocnt = (size(chargereleasecopy->charges,5)+ 1)
        ENDIF
      ENDFOR
      SET newmodsindex = value(size(pmcharge->charge_items[pbmcnt].charge_mods,5))
      SET stat = alterlist(pbmchargecopy->charges[1].mods.charge_mods,newmodsindex)
      FOR (newmodsindex = 1 TO size(pmcharge->charge_items[pbmcnt].charge_mods,5))
        SET pbmchargecopy->charges[1].mods.charge_mods[newmodsindex].charge_mod_type_cd = pmcharge->
        charge_items[pbmcnt].charge_mods[newmodsindex].charge_mod_type_cd
        SET pbmchargecopy->charges[1].mods.charge_mods[newmodsindex].field1_id = pmcharge->
        charge_items[pbmcnt].charge_mods[newmodsindex].field1_id
        SET pbmchargecopy->charges[1].mods.charge_mods[newmodsindex].field2_id = pmcharge->
        charge_items[pbmcnt].charge_mods[newmodsindex].field2_id
      ENDFOR
      EXECUTE afc_call_pbm  WITH replace("REPLY",pbmchargecopy)
      FOR (newinfocnt = 1 TO size(chargereleasecopy->charges,5))
        IF ((pbmchargecopy->charges[1].charge_item_id=chargereleasecopy->charges[newinfocnt].
        charge_item_id))
         IF ((pbmchargecopy->charges[1].item_quantity > 0))
          SET chargereleasecopy->charges[newinfocnt].item_quantity = pbmchargecopy->charges[1].
          item_quantity
          SET chargereleasecopy->charges[newinfocnt].item_extended_price = (pbmchargecopy->charges[1]
          .item_quantity * chargereleasecopy->charges[newinfocnt].item_price)
          CALL echo("New Quantity Info")
          CALL echo(pbmchargecopy->charges[1].item_quantity)
          CALL echo(chargereleasecopy->charges[newinfocnt].item_extended_price)
         ELSE
          IF ((chargereleasecopy->charges[newinfocnt].item_quantity > 0))
           CALL echo("ChargeReleaseCopy original item quantity.")
           SET chargereleasecopy->charges[newinfocnt].item_extended_price = (chargereleasecopy->
           charges[newinfocnt].item_quantity * chargereleasecopy->charges[newinfocnt].item_price)
          ELSE
           CALL echo("ChargeReleaseCopy quantity of 1.")
           SET chargereleasecopy->charges[newinfocnt].item_quantity = 1
           SET chargereleasecopy->charges[newinfocnt].item_extended_price = (chargereleasecopy->
           charges[newinfocnt].item_quantity * chargereleasecopy->charges[newinfocnt].item_price)
          ENDIF
         ENDIF
         FOR (newmodsindex = 1 TO size(pbmchargecopy->charges[1].mods.charge_mods,5))
           FOR (copymodsindex = 1 TO size(chargereleasecopy->charges[newinfocnt].mods.charge_mods,5))
             IF ((pbmchargecopy->charges[1].mods.charge_mods[newmodsindex].field1_id=
             chargereleasecopy->charges[newinfocnt].mods.charge_mods[copymodsindex].field1_id)
              AND (pbmchargecopy->charges[1].mods.charge_mods[newmodsindex].charge_event_mod_type_cd=
             dpromptcd))
              SET chargereleasecopy->charges[newinfocnt].mods.charge_mods[copymodsindex].
              charge_mod_type_cd = pbmchargecopy->charges[1].mods.charge_mods[newmodsindex].
              charge_mod_type_cd
             ENDIF
           ENDFOR
         ENDFOR
         SET newinfocnt = (size(chargereleasecopy->charges,5)+ 1)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   UPDATE  FROM charge_event_act cea,
     (dummyt d1  WITH seq = size(chargereleasecopy->charges,5))
    SET cea.item_deductible_amt = chargereleasecopy->charges[d1.seq].item_quantity
    PLAN (d1
     WHERE (chargereleasecopy->charges[d1.seq].charge_item_id > 0.0)
      AND (chargereleasecopy->charges[d1.seq].item_quantity > 0.0))
     JOIN (cea
     WHERE (cea.charge_event_act_id=chargereleasecopy->charges[d1.seq].charge_act_id))
    WITH nocounter
   ;end update
   CALL logmsg(curprog,"Look to see if the charges have prompts",log_debug)
   FOR (nchrgloop = 1 TO value(size(pmcharge->charge_items,5)))
     SET dcalculatedquantity = 0.0
     SET dcalculatedprice = 0.0
     IF ((pmcharge->charge_items[nchrgloop].retier_ind=1))
      CALL echo(build("Retier Charge Item ID: ",pmcharge->charge_items[nchrgloop].charge_item_id))
      CALL logmsg(curprog,build("//CID: ",pmcharge->charge_items[nchrgloop].charge_item_id),log_debug
       )
      SET npatientresponsibilityneeded = 0
      SET npatientresponsibilityneeded = checkpatientresponsibility(nchrgloop)
      CALL echo(build("nPatientResponsibilityNeeded: ",npatientresponsibilityneeded))
      IF (npatientresponsibilityneeded=1)
       CALL echo("Patient responsibility needed")
       SET copylistindex = 0
       FOR (copylistindex = 1 TO size(chargereleasecopy->charges,5))
         IF ((pmcharge->charge_items[nchrgloop].charge_item_id=chargereleasecopy->charges[
         copylistindex].charge_item_id))
          SET chargereleasecopy->charges[copylistindex].process_flg = 2
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   CALL creditcharges(0)
   CALL createnewdebits(0)
   SET copylistindex = 0
   SET chargemodindex = 0
   FOR (copylistindex = 1 TO size(chargereleasecopy->charges,5))
     IF ((chargereleasecopy->charges[copylistindex].process_flg=2))
      SET chargemodindex += 1
      SET cm_request->charge_mod_qual = 1
      SET stat = alterlist(cm_request->charge_mod,chargemodindex)
      SET cm_request->charge_mod[chargemodindex].action_type = "ADD"
      SET cm_request->charge_mod[chargemodindex].charge_item_id = chargereleasecopy->charges[
      copylistindex].charge_item_id
      SET cm_request->charge_mod[chargemodindex].charge_mod_type_cd = dsuspensecd
      SET cm_request->charge_mod[chargemodindex].field1_id = dnopatrespcd
      SET cm_request->charge_mod[chargemodindex].field6 = uar_get_code_display(dnopatrespcd)
     ENDIF
   ENDFOR
   IF (size(cm_request->charge_mod,5) > 0)
    EXECUTE afc_add_charge_mod  WITH replace("REQUEST",cm_request), replace("REPLY",cm_reply)
    IF ((cm_reply->status_data.status != "S"))
     CALL echo("afc_encntr_mods::RetierCharges - Script afc_add_charge_mod failed.")
     GO TO program_exit
    ENDIF
   ENDIF
   IF (flexrecurmod=0)
    CALL processinterfaces(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE getcalculatedquantity(ncurcharge,dcurquantity)
   CALL echo("AFC_ENCNTR_MODS==============================>ENTERING GetCalculatedQuantity()")
   CALL echo(" Parameters Include:")
   CALL echo(build("   nCurCharge: ",ncurcharge))
   CALL echo(build(" dCurQuantity: ",dcurquantity))
   DECLARE pbm_qty = f8
   DECLARE pbm_cnt = i4
   SET pbm_qty = dcurquantity
   FOR (pbm_cnt = 1 TO size(creleasereply->charges,5))
     IF ((creleasereply->charges[pbm_cnt].tier_group_cd=pmcharge->charge_items[ncurcharge].
     tier_group_cd))
      IF ((creleasereply->charges[pbm_cnt].item_quantity > 0)
       AND (creleasereply->charges[pbm_cnt].process_flg=0))
       SET pbm_qty = creleasereply->charges[pbm_cnt].item_quantity
       SET pbm_cnt = size(creleasereply->charges,5)
      ENDIF
     ENDIF
   ENDFOR
   CALL logmsg(curprog,build("pbm_qty: ",pbm_qty),log_debug)
   CALL echo("AFC_ENCNTR_MODS==============================>LEAVING GetCalculatedQuantity()")
   RETURN(pbm_qty)
 END ;Subroutine
 SUBROUTINE checkpatientresponsibility(ncurcharge)
   CALL echo("Parameters Include:")
   CALL echo(build("nCurCharge: ",ncurcharge))
   CALL echo("AFC_ENCNTR_MODS==============================>ENTERING CheckPatientResponsibility()")
   DECLARE nstatus = i2
   DECLARE pbm_cnt = i4
   IF ((em_afc_chk_profit_install_reply->profit_installed=0))
    GO TO program_exit
   ENDIF
   SET nstatus = 0
   IF ((encounterreply->person_encounter_qual > 0))
    SET stat = alterlist(pbm_request->qual,0)
    SET pbm_cnt += 1
    SET stat = alterlist(pbm_request->qual,pbm_cnt)
    SET pbm_request->qual[pbm_cnt].param_name = "FACILITY_CD"
    SET pbm_request->qual[pbm_cnt].param_value = cnvtstring(encounterreply->person_encounter[1].
     loc_facility_cd,17,2)
    SET pbm_cnt += 1
    SET stat = alterlist(pbm_request->qual,pbm_cnt)
    SET pbm_request->qual[pbm_cnt].param_name = "BILL_ITEM_ID"
    SET pbm_request->qual[pbm_cnt].param_value = cnvtstring(pmcharge->charge_items[ncurcharge].
     bill_item_id,17,2)
    SET pbm_cnt += 1
    SET stat = alterlist(pbm_request->qual,pbm_cnt)
    SET pbm_request->qual[pbm_cnt].param_name = "HEALTH_PLAN_ID"
    SET pbm_request->qual[pbm_cnt].param_value = cnvtstring(encounterreply->person_encounter[1].
     health_plan_id,17,2)
    SET pbm_cnt += 1
    SET stat = alterlist(pbm_request->qual,pbm_cnt)
    SET pbm_request->qual[pbm_cnt].param_name = "ACTIVITY_TYPE"
    SET pbm_request->qual[pbm_cnt].param_value = cnvtstring(pmcharge->charge_items[ncurcharge].
     activity_type_cd,17,2)
    SET pbm_cnt += 1
    SET stat = alterlist(pbm_request->qual,pbm_cnt)
    SET pbm_request->qual[pbm_cnt].param_name = "ENCNTR_TYPE"
    SET pbm_request->qual[pbm_cnt].param_value = cnvtstring(encounterreply->person_encounter[1].
     encntr_type_cd,17,2)
    SET pbm_cnt += 1
    SET stat = alterlist(pbm_request->qual,pbm_cnt)
    SET pbm_request->qual[pbm_cnt].param_name = "FIN_CLASS"
    SET pbm_request->qual[pbm_cnt].param_value = cnvtstring(encounterreply->person_encounter[1].
     financial_class_cd,17,2)
    SET pbm_cnt += 1
    SET stat = alterlist(pbm_request->qual,pbm_cnt)
    SET pbm_request->qual[pbm_cnt].param_name = "PROGRAM_SERVICE"
    SET pbm_request->qual[pbm_cnt].param_value = cnvtstring(encounterreply->person_encounter[1].
     program_service_cd,17,2)
    SET pbm_cnt += 1
    SET stat = alterlist(pbm_request->qual,pbm_cnt)
    SET pbm_request->qual[pbm_cnt].param_name = "SECONDARY_HEALTH_PLAN_ID"
    SET pbm_request->qual[pbm_cnt].param_value = cnvtstring(encounterreply->person_encounter[1].
     secondary_health_plan_id,17,2)
    SET pbm_cnt += 1
    SET stat = alterlist(pbm_request->qual,pbm_cnt)
    SET pbm_request->qual[pbm_cnt].param_name = "MONTHLY_SOC"
    SET pbm_request->qual[pbm_cnt].param_value = cnvtstring(encounterreply->person_encounter[1].
     deduct_amt,17,2)
    SET pbm_cnt += 1
    SET stat = alterlist(pbm_request->qual,pbm_cnt)
    SET pbm_request->qual[pbm_cnt].param_name = "LOC_NURSE_UNIT_CD"
    SET pbm_request->qual[pbm_cnt].param_value = cnvtstring(encounterreply->person_encounter[1].
     loc_nurse_unit_cd,17,2)
    SET pbm_cnt += 1
    SET stat = alterlist(pbm_request->qual,pbm_cnt)
    SET pbm_request->qual[pbm_cnt].param_name = "LOC_BUILDING_CD"
    SET pbm_request->qual[pbm_cnt].param_value = cnvtstring(encounterreply->person_encounter[1].
     loc_building_cd,17,2)
    CALL echo("Calling PBM Rules for Patient Responsibility!!!!!!!!!!")
    EXECUTE pft_pbm_pat_responsibility  WITH replace("REQUEST",pbm_request), replace("REPLY",
     pbm_reply)
    CALL echorecord(pbm_reply)
    FOR (pbm_cnt = 1 TO size(pbm_reply->qual,5))
      IF ((pbm_reply->qual[pbm_cnt].param_name="DEDUCTIBLE"))
       IF ( NOT ((pbm_reply->qual[pbm_cnt].param_value IN (null, ""))))
        SET nstatus = 1
       ENDIF
      ELSEIF ((pbm_reply->qual[pbm_cnt].param_name="COPAY"))
       IF ( NOT ((pbm_reply->qual[pbm_cnt].param_value IN (null, ""))))
        SET nstatus = 1
       ENDIF
      ELSEIF ((pbm_reply->qual[pbm_cnt].param_name="NONCOVERED"))
       IF ( NOT ((pbm_reply->qual[pbm_cnt].param_value IN (null, ""))))
        SET nstatus = 1
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   CALL echo("AFC_ENCNTR_MODS==============================>LEAVING CheckPatientResponsibility()")
   RETURN(nstatus)
 END ;Subroutine
 SUBROUTINE gethealthplanbypriority(npriorityseq,fccobind)
   DECLARE dhpid = f8
   DECLARE lhpcnt = i4
   CALL echo(build("nPrioritySeq: ",npriorityseq))
   CALL echo(build("FCCobInd",fccobind))
   IF (fccobind=2)
    IF ((fincob->fincob_cnt > 0))
     FOR (lhpcnt = 1 TO fincob->fincob_cnt)
       IF ((fincob->fincob[lhpcnt].priority_seq=npriorityseq))
        SET dhpid = fincob->fincob[lhpcnt].hp_id
        SET lhpcnt = fincob->fincob_cnt
       ENDIF
     ENDFOR
     RETURN(dhpid)
    ELSE
     RETURN(0.0)
    ENDIF
   ELSEIF (fccobind=1)
    IF (size(objpmhealthplan->objarray,5) > 0)
     FOR (lhpcnt = 1 TO size(objpmhealthplan->objarray,5))
      CALL echo(build("Clinical Count in GetHP: ",lhpcnt))
      IF ((objpmhealthplan->objarray[lhpcnt].priority_seq=npriorityseq))
       SET dhpid = objpmhealthplan->objarray[lhpcnt].hp_id
       SET lhpcnt = size(objpmhealthplan->objarray,5)
      ENDIF
     ENDFOR
     RETURN(dhpid)
    ELSE
     RETURN(0.0)
    ENDIF
   ELSE
    RETURN(0.0)
   ENDIF
 END ;Subroutine
 SUBROUTINE reevaluatecharges(dummvar)
   CALL echo("Entering ReEvaluateCharges()")
   DECLARE lboindex = i4 WITH noconstant(0)
   DECLARE lchgindex = i4 WITH noconstant(0)
   RECORD objchargereq(
     1 objarray[*]
       2 benefit_order_id = f8
       2 health_plan_id = f8
       2 encntr_type_cd = f8
   )
   RECORD objcharge(
     1 obj_vrsn_1 = c1
     1 ein_type = i4
     1 proxy_ind = i2
     1 objarray[*]
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
       2 encntr_type_cd = f8
       2 encntr_type_disp = vc
       2 encntr_type_desc = vc
       2 encntr_type_mean = vc
       2 encntr_type_code_set = f8
       2 pft_charge_status_cd = f8
       2 pft_charge_status_disp = vc
       2 pft_charge_status_desc = vc
       2 pft_charge_status_mean = vc
       2 pft_charge_status_code_set = f8
       2 dr_acct_templ_id = f8
       2 cr_acct_templ_id = f8
       2 dr_acct_id = f8
       2 cr_acct_id = f8
       2 billing_quantity = i4
       2 parent_entity_id = f8
       2 late_chrg_flag = i2
       2 offset_ind = i2
       2 trans_type_cd = f8
       2 trans_amount = f8
       2 item_extended_price = f8
       2 service_dt_tm = dq8
       2 parent_charge_item_id = f8
       2 charge_description = vc
       2 charge_type_cd = f8
       2 charge_type_disp = vc
       2 charge_type_desc = vc
       2 charge_type_mean = vc
       2 charge_type_code_set = f8
       2 item_quantity = f8
       2 item_price = f8
       2 ord_loc_cd = f8
       2 perf_loc_cd = f8
       2 tier_group_cd = f8
       2 charge_bo_reltn_id = f8
       2 revenue_code = f8
       2 hcpcs_code = vc
       2 cpt4_code = vc
       2 pcbr_updt_cnt = i4
       2 alt_billing_amt = f8
       2 alt_billing_qty = i4
       2 ext_master_event_id = f8
       2 ext_master_event_cont_cd = f8
       2 ext_master_reference_id = f8
       2 ext_master_reference_cont_cd = f8
       2 ext_item_event_id = f8
       2 ext_item_event_cont_cd = f8
       2 ext_item_reference_id = f8
       2 ext_item_reference_cont_cd = f8
       2 primary_covered_ind = i2
       2 secondary_covered_ind = i2
       2 tertiary_covered_ind = i2
       2 patient_responsibility_flag = i2
       2 documentation_date = vc
       2 documentation_minutes = f8
       2 number_of_clients = f8
       2 number_of_therapists = f8
       2 session_minutes = f8
       2 travel_minutes = f8
       2 icd9_1 = vc
       2 icd9_desc_1 = vc
       2 bc_type_icd9 = f8
       2 perf_phys_id = f8
       2 charge_event_id = f8
       2 charge_event_act_id = f8
       2 entity_instance_desc = vc
       2 entity_resource_large_key = vc
       2 entity_resource_small_key = vc
       2 entity_name = vc
       2 bim_ind = i2
       2 covered_bitmap = i4
       2 suppress_flag = i2
       2 suppress_txt = vc
       2 provider_specialty_cd = f8
       2 activity_qual[*]
         3 activity_id = f8
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
   EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod),
   replace("OBJREPLY",objbenefitorderrep)
   FOR (lboindex = 1 TO size(objbenefitorderrep->objarray,5))
     IF ((objbenefitorderrep->objarray[lboindex].fin_class_cd != dselfpayfccd)
      AND (objbenefitorderrep->objarray[lboindex].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[lboindex].priority_seq > 1)
      AND (objbenefitorderrep->objarray[lboindex].pft_encntr_id=evaluate(mpeid,0.0,objbenefitorderrep
      ->objarray[lboindex].pft_encntr_id,mpeid)))
      SET stat = alterlist(objchargereq->objarray,1)
      SET objchargereq->objarray[1].benefit_order_id = objbenefitorderrep->objarray[lboindex].
      benefit_order_id
      SET objchargereq->objarray[1].health_plan_id = objbenefitorderrep->objarray[lboindex].
      health_plan_id
      SET objchargereq->objarray[1].encntr_type_cd = objbenefitorderrep->objarray[lboindex].
      encntr_type_cd
      SET stat = alterlist(objcharge->objarray,0)
      SET objcharge->ein_type = ein_benefit_order
      EXECUTE pft_charge_find  WITH replace("REQUEST",objchargereq), replace("OBJREPLY",objcharge),
      replace("REPLY",reply)
      CALL echo("after pft_charge_find")
      CALL echorecord(objcharge)
      FOR (lchgindex = 1 TO size(objcharge->objarray,5))
       SET objcharge->objarray.covered_bitmap = band(objcharge->objarray.covered_bitmap,bnot((2** (
         objbenefitorderrep->objarray[lboindex].priority_seq - 1))))
       IF ((objcharge->objarray[lchgindex].bim_ind=0))
        SET objcharge->objarray.covered_bitmap = bor(objcharge->objarray.covered_bitmap,(2** (
         objbenefitorderrep->objarray[lboindex].priority_seq - 1)))
       ENDIF
      ENDFOR
      IF (size(objcharge->objarray,5) > 0)
       CALL echorecord(objcharge)
       EXECUTE pft_charge_save  WITH replace("REQUEST",objcharge), replace("REPLY",reply)
      ENDIF
     ENDIF
   ENDFOR
   FREE RECORD objchargereq
   FREE RECORD objcharge
 END ;Subroutine
 SUBROUTINE (unrollselfpaynonprimary(priority_seq=i4) =i2)
  DECLARE nunrollamount = f8 WITH noconstant(0.0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(objbenefitorderrep->objarray,5))),
    (dummyt d2  WITH seq = value(size(objaddbo->objarray,5)))
   PLAN (d1
    WHERE (objbenefitorderrep->objarray[d1.seq].priority_seq=(priority_seq - 1))
     AND (objbenefitorderrep->objarray[d1.seq].bo_status_cd != dinvalidcd)
     AND (objbenefitorderrep->objarray[d1.seq].curr_amt_due=0.0))
    JOIN (d2
    WHERE (objaddbo->objarray[d2.seq].benefit_order_id=objbenefitorderrep->objarray[d1.seq].
    benefit_order_id)
     AND (objaddbo->objarray[d2.seq].priority_seq=priority_seq))
   DETAIL
    nunrollamount = ((objbenefitorderrep->objarray[d1.seq].orig_amt_due+ objbenefitorderrep->
    objarray[d1.seq].total_pay_amt)+ objbenefitorderrep->objarray[d1.seq].total_adj), objaddbo->
    objarray[d2.seq].orig_amt_due = nunrollamount, objaddbo->objarray[d2.seq].curr_amt_due =
    nunrollamount
   WITH nocounter
  ;end select
 END ;Subroutine
#program_exit
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
  CALL echo(build("ReqInfo:",reqinfo->commit_ind))
 ELSE
  SET reqinfo->commit_ind = 0
  CALL echo(build("ReqInfo:",reqinfo->commit_ind))
 ENDIF
 SUBROUTINE findfinencntrs(dummyvar)
   DECLARE nfeidx = i4 WITH noconstant(0)
   IF (size(temprecurencntr->objarray,5) > 0)
    CALL echo("Finding recurring fin encounters")
    SET objfinencntrmod->ein_type = ein_pft_encntr
    EXECUTE pft_fin_encntr_find  WITH replace("REPLY",reply), replace("REQUEST",temprecurencntr),
    replace("OBJREPLY",objfinencntrmod)
   ELSE
    SET objfinencntrmod->ein_type = ein_encounter_active
    EXECUTE pft_fin_encntr_find  WITH replace("REPLY",reply), replace("REQUEST",encounterrequest),
    replace("OBJREPLY",objfinencntrmod)
   ENDIF
   IF ((reply->status_data.status="F"))
    CALL echo("PFT_FIN_ENCNTR_FIND FAILED.")
    RETURN(false)
   ELSEIF ((reply->status_data.status="Z"))
    CALL echo("PFT_FIN_ENCNTR_FIND DIDN'T QUALIFY.")
    RETURN(false)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(objfinencntrmod->objarray,5))),
     account a
    PLAN (d)
     JOIN (a
     WHERE (a.acct_id=objfinencntrmod->objarray[d.seq].acct_id)
      AND a.acct_sub_type_cd=dclientacctcd
      AND a.active_ind=1)
    DETAIL
     nfeidx = d.seq
    WITH nocounter
   ;end select
   IF (curqual)
    SET stat = alterlist(objfinencntrmod->objarray,(size(objfinencntrmod->objarray,5) - 1),(nfeidx -
     1))
   ENDIF
   CALL echorecord(objfinencntrmod)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE checkhpexpirelogic(dummyvar)
   DECLARE hpexpind = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM bill_org_payor bop
    WHERE bop.bill_org_type_cd=mdhpexpirelogic
     AND bop.active_ind=1
     AND (bop.organization_id=replclinencobj->objarray[1].organization_id)
    DETAIL
     IF (bop.bill_org_type_ind=1)
      hpexpind = 1
     ELSE
      hpexpind = 0
     ENDIF
    WITH nocounter
   ;end select
   RETURN(hpexpind)
 END ;Subroutine
 SUBROUTINE checkhpexpireforrecur(dummyvar)
   CALL echo("Inside CheckHPExpireForRecur")
   DECLARE hpcnt = i4 WITH noconstant(0)
   DECLARE hploopcnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM encntr_plan_reltn epr,
     health_plan hp
    PLAN (epr
     WHERE (epr.encntr_id=replclinencobj->objarray[1].encntr_id)
      AND epr.active_ind=1
      AND epr.priority_seq=1)
     JOIN (hp
     WHERE hp.health_plan_id=epr.health_plan_id)
    ORDER BY epr.beg_effective_dt_tm
    DETAIL
     hpcnt += 1, stat = alterlist(tempprimaryhps->objarray,hpcnt), tempprimaryhps->objarray[hpcnt].
     encntr_plan_reltn_id = epr.encntr_plan_reltn_id,
     tempprimaryhps->objarray[hpcnt].health_plan_id = epr.health_plan_id, tempprimaryhps->objarray[
     hpcnt].beg_effective_dt_tm = epr.beg_effective_dt_tm, tempprimaryhps->objarray[hpcnt].
     end_effective_dt_tm = epr.end_effective_dt_tm,
     tempprimaryhps->objarray[hpcnt].fin_class_cd = hp.financial_class_cd
     IF (hpcnt=1)
      CALL echo(build("Month",month(epr.beg_effective_dt_tm))), tempprimaryhps->objarray[hpcnt].
      fin_beg_effective_dt_tm = cnvtdatetime(cnvtdate(build(format(month(epr.beg_effective_dt_tm),
          "##;P0"),"01",year(epr.beg_effective_dt_tm))),0), primaryhp_overlap_ind = 0
     ELSE
      tempprimaryhps->objarray[hpcnt].fin_beg_effective_dt_tm = epr.beg_effective_dt_tm,
      CALL echo(build("Month",month(epr.beg_effective_dt_tm)))
      IF (epr.beg_effective_dt_tm <= cnvtdatetime(tempprimaryhps->objarray[(hpcnt - 1)].
       end_effective_dt_tm)
       AND epr.beg_effective_dt_tm >= cnvtdatetime(tempprimaryhps->objarray[(hpcnt - 1)].
       beg_effective_dt_tm))
       primaryhp_overlap_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (primaryhp_overlap_ind=1)
    SELECT INTO "nl:"
     FROM pft_encntr pe,
      account acc
     PLAN (pe
      WHERE (pe.encntr_id=replclinencobj->objarray[1].encntr_id)
       AND pe.active_ind=1)
      JOIN (acc
      WHERE acc.acct_id=pe.acct_id
       AND acc.active_ind=1)
     ORDER BY pe.pft_encntr_id
     HEAD pe.pft_encntr_id
      ncommentqual += 1, stat = alterlist(add_comment_req->objarray,ncommentqual), add_comment_req->
      objarray[ncommentqual].pft_encntr_id = pe.pft_encntr_id,
      add_comment_req->objarray[ncommentqual].acct_id = acc.acct_id, add_comment_req->objarray[
      ncommentqual].corsp_desc = build("Evaluate Encounter Modification Failed.",
       " One or more primary health plan(s) with overlapping ",
       " effective dates were found on the encounter."), add_comment_req->objarray[ncommentqual].
      importance_flag = 1
     WITH nocounter
    ;end select
    IF (size(add_comment_req->objarray,5) > 0)
     EXECUTE pft_apply_comment_for_encntr  WITH replace("REQUEST",add_comment_req), replace("REPLY",
      reply)
     IF ((reply->status_data.status != "S"))
      CALL abortscript(curprog,"pft_apply_comment_for_encntr failed")
     ENDIF
    ENDIF
    CALL logmsg(curprog,build("Failed to execute CheckHPExpireForRecur(). ",
      "One or more primary overlapping end effective dates were found ","on the encounter."),
     log_error)
    GO TO program_exit
   ENDIF
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(replclinencobj)
    CALL echorecord(tempprimaryhps)
    CALL echo("PMCharge structure before Select")
    CALL echorecord(pmcharge)
   ENDIF
   FOR (hploopcnt = 1 TO size(tempprimaryhps->objarray,5))
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(pmcharge->charge_items,5)))
      WHERE (pmcharge->charge_items[d1.seq].service_dt_tm >= cnvtdatetime(tempprimaryhps->objarray[
       hploopcnt].beg_effective_dt_tm))
       AND (pmcharge->charge_items[d1.seq].service_dt_tm < cnvtdatetime(tempprimaryhps->objarray[
       hploopcnt].end_effective_dt_tm))
       AND (pmcharge->charge_items[d1.seq].process_flg IN (100, 999))
      DETAIL
       IF ((pmcharge->charge_items[d1.seq].health_plan_id != tempprimaryhps->objarray[hploopcnt].
       health_plan_id))
        pmcharge->charge_items[d1.seq].health_plan_id = tempprimaryhps->objarray[hploopcnt].
        health_plan_id, pmcharge->charge_items[d1.seq].fin_class_cd = tempprimaryhps->objarray[
        hploopcnt].fin_class_cd, nneedtocheckprice = 1
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   IF (validate(debug,- (1)) > 0)
    CALL echo("PMCharge structure after Select")
    CALL echorecord(pmcharge)
   ENDIF
 END ;Subroutine
 SUBROUTINE uptchargehp(dummyvar)
  UPDATE  FROM charge c,
    (dummyt d  WITH seq = value(size(pmcharge->charge_items,5)))
   SET c.health_plan_id = pmcharge->charge_items[d.seq].health_plan_id, c.fin_class_cd = pmcharge->
    charge_items[d.seq].fin_class_cd
   PLAN (d)
    JOIN (c
    WHERE (c.charge_item_id=pmcharge->charge_items[d.seq].charge_item_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "afc_encntr_mods"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CheckHPExpireForRecur"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Failed updating charges with new health plan ids"
   CALL echo("Failed updating charges with new health plan ids")
   GO TO program_exit
  ENDIF
 END ;Subroutine
 SUBROUTINE uptchargemods(dummyvar)
   DECLARE modind = i2 WITH noconstant(0)
   DECLARE chargemodqual = i2 WITH noconstant(0)
   DECLARE modsequence = i4 WITH noconstant(0)
   DECLARE cpthcpcsmeaning = c12
   DECLARE nmodexist = i2 WITH noconstant(0)
   CALL echo("Entering UptChargeMods")
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(pmcharge)
    CALL echorecord(creleasereply)
   ENDIF
   SET chargemodqual = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(pmcharge->charge_items,5))),
     (dummyt d2  WITH seq = value(size(creleasereply->charges,5)))
    PLAN (d1
     WHERE (pmcharge->charge_items[d1.seq].uptchargemodflag=1))
     JOIN (d2
     WHERE (creleasereply->charges[d2.seq].charge_act_id=pmcharge->charge_items[d1.seq].
     charge_event_act_id)
      AND (creleasereply->charges[d2.seq].tier_group_cd=pmcharge->charge_items[d1.seq].tier_group_cd)
      AND (creleasereply->charges[d2.seq].bill_item_id=pmcharge->charge_items[d1.seq].bill_item_id)
      AND (creleasereply->charges[d2.seq].item_quantity=pmcharge->charge_items[d1.seq].item_quantity)
      AND (creleasereply->charges[d2.seq].service_dt_tm=pmcharge->charge_items[d1.seq].service_dt_tm)
     )
    DETAIL
     modsequence = 0, modind = 0,
     CALL echo(build("D1:  ",d1.seq)),
     CALL echo(build("D1 Charge Item:  ",pmcharge->charge_items[d1.seq].charge_item_id))
     FOR (x = 1 TO size(creleasereply->charges[d2.seq].mods.charge_mods,5))
       nmodexist = 0
       FOR (y = 1 TO size(pmcharge->charge_items[d1.seq].charge_mods,5))
         IF ((creleasereply->charges[d2.seq].charge_item_id=pmcharge->charge_items[d1.seq].
         charge_item_id)
          AND (creleasereply->charges[d2.seq].mods.charge_mods[x].field1_id=pmcharge->charge_items[d1
         .seq].charge_mods[y].field1_id)
          AND (creleasereply->charges[d2.seq].mods.charge_mods[x].field2_id=pmcharge->charge_items[d1
         .seq].charge_mods[y].field2_id)
          AND (creleasereply->charges[d2.seq].mods.charge_mods[x].field6=pmcharge->charge_items[d1
         .seq].charge_mods[y].field6)
          AND (pmcharge->charge_items[d1.seq].charge_mods[y].active_ind=1))
          nmodexist = 1
         ENDIF
       ENDFOR
       IF (nmodexist=0)
        chargemodqual += 1, stat = alterlist(emaddchargemodrequest->charge_mod,chargemodqual),
        emaddchargemodrequest->charge_mod[chargemodqual].action_type = "ADD",
        emaddchargemodrequest->charge_mod[chargemodqual].charge_mod_id = 0, emaddchargemodrequest->
        charge_mod[chargemodqual].charge_item_id = pmcharge->charge_items[d1.seq].charge_item_id,
        emaddchargemodrequest->charge_mod[chargemodqual].charge_mod_type_cd = creleasereply->charges[
        d2.seq].mods.charge_mods[x].charge_mod_type_cd,
        emaddchargemodrequest->charge_mod[chargemodqual].charge_event_mod_type_cd = creleasereply->
        charges[d2.seq].mods.charge_mods[x].charge_event_mod_type_cd, emaddchargemodrequest->
        charge_mod[chargemodqual].field1 = creleasereply->charges[d2.seq].mods.charge_mods[x].field1,
        emaddchargemodrequest->charge_mod[chargemodqual].field2 = creleasereply->charges[d2.seq].mods
        .charge_mods[x].field2,
        emaddchargemodrequest->charge_mod[chargemodqual].field3 = creleasereply->charges[d2.seq].mods
        .charge_mods[x].field3, emaddchargemodrequest->charge_mod[chargemodqual].field4 =
        creleasereply->charges[d2.seq].mods.charge_mods[x].field4, emaddchargemodrequest->charge_mod[
        chargemodqual].field5 = creleasereply->charges[d2.seq].mods.charge_mods[x].field5,
        emaddchargemodrequest->charge_mod[chargemodqual].field6 = creleasereply->charges[d2.seq].mods
        .charge_mods[x].field6, emaddchargemodrequest->charge_mod[chargemodqual].field7 =
        creleasereply->charges[d2.seq].mods.charge_mods[x].field7, emaddchargemodrequest->charge_mod[
        chargemodqual].field8 = creleasereply->charges[d2.seq].mods.charge_mods[x].field8,
        emaddchargemodrequest->charge_mod[chargemodqual].field9 = creleasereply->charges[d2.seq].mods
        .charge_mods[x].field9, emaddchargemodrequest->charge_mod[chargemodqual].field10 =
        creleasereply->charges[d2.seq].mods.charge_mods[x].field10, emaddchargemodrequest->
        charge_mod[chargemodqual].active_ind = 1,
        emaddchargemodrequest->charge_mod[chargemodqual].active_status_cd = 0, emaddchargemodrequest
        ->charge_mod[chargemodqual].field1_id = creleasereply->charges[d2.seq].mods.charge_mods[x].
        field1_id
        IF (trim(uar_get_code_meaning(creleasereply->charges[d2.seq].mods.charge_mods[x].field1_id))=
        "MODIFIER")
         modsequence += 1, emaddchargemodrequest->charge_mod[chargemodqual].field2_id = modsequence
        ELSE
         emaddchargemodrequest->charge_mod[chargemodqual].field2_id = creleasereply->charges[d2.seq].
         mods.charge_mods[x].field2_id
        ENDIF
        emaddchargemodrequest->charge_mod[chargemodqual].field3_id = creleasereply->charges[d2.seq].
        mods.charge_mods[x].field3_id, emaddchargemodrequest->charge_mod[chargemodqual].field4_id =
        creleasereply->charges[d2.seq].mods.charge_mods[x].field4_id, emaddchargemodrequest->
        charge_mod[chargemodqual].field5_id = creleasereply->charges[d2.seq].mods.charge_mods[x].
        field5_id,
        emaddchargemodrequest->charge_mod[chargemodqual].nomen_id = creleasereply->charges[d2.seq].
        mods.charge_mods[x].nomen_id, emaddchargemodrequest->charge_mod[chargemodqual].cm1_nbr =
        creleasereply->charges[d2.seq].mods.charge_mods[x].cm1_nbr, emaddchargemodrequest->
        charge_mod[chargemodqual].beg_effective_dt_tm = cnvtdatetime(sysdate),
        emaddchargemodrequest->charge_mod[chargemodqual].end_effective_dt_tm = cnvtdatetime(
         "31-DEC-2100 23:59:59"), emaddchargemodrequest->charge_mod[chargemodqual].activity_dt_tm =
        creleasereply->charges[d2.seq].mods.charge_mods[x].activity_dt_tm, nmodexist = 0
       ENDIF
     ENDFOR
     FOR (x = 1 TO size(pmcharge->charge_items[d1.seq].charge_mods,5))
       nmodexist = 0
       FOR (y = 1 TO size(creleasereply->charges[d2.seq].mods.charge_mods,5))
         IF ((pmcharge->charge_items[d1.seq].charge_mods[x].field1_id=creleasereply->charges[d2.seq].
         mods.charge_mods[y].field1_id)
          AND (pmcharge->charge_items[d1.seq].charge_mods[x].field2_id=creleasereply->charges[d2.seq]
         .mods.charge_mods[y].field2_id)
          AND (pmcharge->charge_items[d1.seq].charge_mods[x].field6=creleasereply->charges[d2.seq].
         mods.charge_mods[y].field6)
          AND (pmcharge->charge_items[d1.seq].charge_item_id=creleasereply->charges[d2.seq].
         charge_item_id))
          nmodexist = 1
         ENDIF
       ENDFOR
       IF (nmodexist=0)
        pmcharge->charge_items[d1.seq].charge_mods[x].delmodind = 1
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   SET emaddchargemodrequest->charge_mod_qual = chargemodqual
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(pmcharge)
    CALL echorecord(creleasereply)
    CALL echorecord(emaddchargemodrequest)
   ENDIF
   FOR (y = 1 TO size(pmcharge->charge_items,5))
     UPDATE  FROM charge_mod cm,
       (dummyt d1  WITH seq = value(size(pmcharge->charge_items[y].charge_mods,5)))
      SET cm.active_ind = 0
      PLAN (d1
       WHERE (pmcharge->charge_items[y].charge_mods[d1.seq].delmodind=1))
       JOIN (cm
       WHERE (cm.charge_mod_id=pmcharge->charge_items[y].charge_mods[d1.seq].charge_mod_id)
        AND cm.charge_mod_type_cd=mdbillcodecd
        AND  NOT (cm.field1_id IN (
       (SELECT
        cv.code_value
        FROM code_value cv
        WHERE cv.code_set=14002
         AND cdf_meaning="ICD9"))))
      WITH nocounter
     ;end update
   ENDFOR
   SET action_begin = 1
   SET action_end = emaddchargemodrequest->charge_mod_qual
   EXECUTE afc_add_charge_mod  WITH replace("REQUEST",emaddchargemodrequest), replace("REPLY",
    addchargemodreply)
   CALL echorecord(addchargemodreply)
   IF ((addchargemodreply->status_data.status="F"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_encntr_mods"
    SET reply->status_data.subeventstatus[1].targetobjectname = "UptChargeMods"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed Executing afc_ens_charge_mod"
    CALL echo("AFC_ENS_CHARGE_MOD failed")
    GO TO program_exit
   ENDIF
 END ;Subroutine
 SUBROUTINE invalidatepftencntr(dummyvar)
   CALL echo("Entering InvalidatePftEncntr...")
   DECLARE j = i4 WITH noconstant(0)
   DECLARE k = i4 WITH noconstant(0)
   DECLARE bocount = i4 WITH noconstant(0)
   RECORD bowithsubclaim(
     1 objarray[*]
       2 benefit_order_id = f8
   )
   RECORD pewithsubclaim(
     1 objarray[*]
       2 pft_encntr_id = f8
       2 pft_encntr_status_cd = f8
       2 end_effective_dt_tm = dq8
       2 active_ind = i2
   )
   SET encounterrequest->objarray[1].encntr_id = request->o_encntr_id
   SET objfinencntrmod->ein_type = ein_encounter_active
   EXECUTE pft_fin_encntr_find  WITH replace("REPLY",reply), replace("REQUEST",encounterrequest),
   replace("OBJREPLY",objfinencntrmod)
   IF ((reply->status_data="F"))
    CALL echo("afc_encntr_mods::InvalidatePftEncntr::pft_fin_encntr_find FAILED.")
    GO TO program_exit
   ENDIF
   CALL echo("InvalidatePftEncntr::pft_fin_encntr_find completed.")
   SET objbenefitorderrep->ein_type = ein_pft_encntr
   EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod),
   replace("OBJREPLY",objbenefitorderrep)
   IF ((reply->status_data="F"))
    CALL echo("afc_encntr_mods::InvalidatePftEncntr::pft_benefit_order_find FAILED.")
    GO TO program_exit
   ENDIF
   CALL echo("InvalidatePftEncntr::pft_benefit_order_find completed.")
   SET objbobillheader->ein_type = ein_pft_encntr
   EXECUTE pft_bill_header_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
    objbobillheader), replace("REPLY",reply)
   IF ((reply->status_data="F"))
    CALL echo("afc_encntr_mods::InvalidatePftEncntr::pft_bill_header_find FAILED.")
    GO TO program_exit
   ENDIF
   CALL echo("InvalidatePftEncntr::pft_bill_header_find completed.")
   CALL echorecord(objbobillheader)
   IF (size(objfinencntrmod->objarray,5) > 0)
    SET objtransfindrep->ein_type = ein_pft_encntr
    SET objtransfindrep->hide_charges_ind = 1
    CALL echo("Calling pft_transaction_find")
    EXECUTE pft_transaction_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
     objtransfindrep), replace("REPLY",reply)
    IF ((reply->status_data.status="F"))
     CALL echo("afc_encntr_mods::InvalidatePftEncntr::pft_transaction_find FAILED.")
     CALL echorecord(reply)
     GO TO program_exit
    ENDIF
    CALL echorecord(objtransfindrep)
   ENDIF
   SET bocount = 0
   FOR (j = 1 TO size(objtransfindrep->objarray,5))
     IF ((objtransfindrep->objarray[j].benefit_order_id=0.0))
      SET bocount += 1
      SET stat = alterlist(reverse_trans_request->objarray,bocount)
      SET reverse_trans_request->objarray[bocount].activity_id = objtransfindrep->objarray[j].
      activity_id
      SET reverse_trans_request->objarray[bocount].amount = (objtransfindrep->objarray[j].
      total_trans_amount * - (1))
     ENDIF
   ENDFOR
   IF (size(reverse_trans_request->objarray,5) > 0)
    EXECUTE pft_reverse_transaction  WITH replace("REQUEST",reverse_trans_request), replace("REPLY",
     reply)
    IF ((reply->status_data.status="F"))
     CALL echo("afc_encntr_mods::InvalidatePftEncntr::pft_reverse_transaction FAILED.")
     CALL echorecord(reply)
     GO TO program_exit
    ENDIF
   ENDIF
   SET bocount = 0
   FOR (j = 1 TO size(objbobillheader->objarray,5))
     IF ((objbobillheader->objarray[j].bill_status_cd IN (dsubmittedcd, dtransmittedcd, ddeniedcd,
     ddeniedreviewcd)))
      SET bocount += 1
      SET stat = alterlist(bowithsubclaim->objarray,bocount)
      SET bowithsubclaim->objarray[bocount].benefit_order_id = objbobillheader->objarray[j].
      benefit_order_id
     ENDIF
   ENDFOR
   SET bocount = 0
   FOR (j = 1 TO size(bowithsubclaim->objarray,5))
     FOR (k = 1 TO size(objbenefitorderrep->objarray,5))
       IF ((bowithsubclaim->objarray[j].benefit_order_id=objbenefitorderrep->objarray[k].
       benefit_order_id))
        SET bocount += 1
        SET stat = alterlist(pewithsubclaim->objarray,bocount)
        SET pewithsubclaim->objarray[bocount].pft_encntr_id = objbenefitorderrep->objarray[k].
        pft_encntr_id
        CALL echo("PFT Encntr found with a submitted claim!")
       ENDIF
     ENDFOR
   ENDFOR
   SET encounterrequest->objarray[1].encntr_id = request->o_encntr_id
   SET objfinencntrmod->ein_type = ein_encounter_active
   EXECUTE pft_fin_encntr_find  WITH replace("REPLY",reply), replace("REQUEST",encounterrequest),
   replace("OBJREPLY",objfinencntrmod)
   IF ((reply->status_data="F"))
    CALL echo("afc_encntr_mods::InvalidatePftEncntr::pft_fin_encntr_find FAILED.")
    GO TO program_exit
   ENDIF
   CALL echo("InvalidatePftEncntr::pft_fin_encntr_find completed.")
   SET objbenefitorderrep->ein_type = ein_pft_encntr
   EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod),
   replace("OBJREPLY",objbenefitorderrep)
   IF ((reply->status_data="F"))
    CALL echo("afc_encntr_mods::InvalidatePftEncntr::pft_benefit_order_find FAILED.")
    GO TO program_exit
   ENDIF
   CALL echo("InvalidatePftEncntr::pft_benefit_order_find completed.")
   SET bocount = 0
   FOR (j = 1 TO size(pewithsubclaim->objarray,5))
     FOR (k = 1 TO size(objfinencntrmod->objarray,5))
       IF ((pewithsubclaim->objarray[j].pft_encntr_id=objfinencntrmod->objarray[k].pft_encntr_id))
        SET objfinencntrmod->objarray[k].pft_encntr_status_cd = dhistorycd
        SET objfinencntrmod->objarray[k].end_effective_dt_tm = cnvtdatetime(sysdate)
       ENDIF
     ENDFOR
   ENDFOR
   DECLARE dtimeoffset = f8
   SET dtimeoffset = curtime3
   FOR (j = 1 TO size(objfinencntrmod->objarray,5))
     IF ((objfinencntrmod->objarray[j].pft_encntr_status_cd != dhistorycd)
      AND (objfinencntrmod->objarray[j].balance=0.0))
      SET dtimeoffset += 100
      SET objfinencntrmod->objarray[j].active_ind = 0
      SET objfinencntrmod->objarray[j].active_status_cd = reqdata->inactive_status_cd
      SET objfinencntrmod->objarray[j].active_status_dt_tm = cnvtdatetime(curdate,dtimeoffset)
     ENDIF
   ENDFOR
   CALL echorecord(objfinencntrmod)
   CALL invalidatebo(size(objbenefitorderrep->objarray,5),size(objbobillheader->objarray,5),0)
   IF (size(objuptboreq->objarray,5) > 0)
    EXECUTE pft_benefit_order_save  WITH replace("REQUEST",objuptboreq), replace("REPLY",reply)
    IF ((reply->status_data.status != "S"))
     CALL echo("afc_encntr_mods::InvalidatePftEncntr::pft_benefit_order_save FAILED.")
     GO TO program_exit
    ENDIF
   ENDIF
   DECLARE iupdatepftencntr = i4
   SET iupdatepftencntr = updateflexiblepftencntr(0)
 END ;Subroutine
 SUBROUTINE updateflexiblepftencntr(dummyvar)
   CALL echo("Entering AfcEncntrMods::updateFlexiblePftEncntr")
   CALL echorecord(objfinencntrmod)
   UPDATE  FROM pft_encntr pe,
     (dummyt dt  WITH seq = value(size(objfinencntrmod->objarray,5)))
    SET pe.active_ind =
     IF ((validate(objfinencntrmod->objarray[dt.seq].active_ind,- (1))=- (1))) pe.active_ind
     ELSE objfinencntrmod->objarray[dt.seq].active_ind
     ENDIF
     , pe.active_status_cd =
     IF (validate(objfinencntrmod->objarray[dt.seq].active_status_cd,0.0)=0.0) pe.active_status_cd
     ELSE objfinencntrmod->objarray[dt.seq].active_status_cd
     ENDIF
     , pe.active_status_dt_tm =
     IF (validate(objfinencntrmod->objarray[dt.seq].active_status_dt_tm,0.0)=0.0) pe
      .active_status_dt_tm
     ELSE cnvtdatetime(objfinencntrmod->objarray[dt.seq].active_status_dt_tm)
     ENDIF
     ,
     pe.pft_encntr_status_cd =
     IF (validate(objfinencntrmod->objarray[dt.seq].pft_encntr_status_cd,0.0)=0.0) pe
      .pft_encntr_status_cd
     ELSE objfinencntrmod->objarray[dt.seq].pft_encntr_status_cd
     ENDIF
     , pe.end_effective_dt_tm =
     IF (validate(objfinencntrmod->objarray[dt.seq].end_effective_dt_tm,0.0)=0.0) pe
      .end_effective_dt_tm
     ELSE cnvtdatetime(objfinencntrmod->objarray[dt.seq].end_effective_dt_tm)
     ENDIF
    PLAN (dt)
     JOIN (pe
     WHERE (pe.pft_encntr_id=objfinencntrmod->objarray[dt.seq].pft_encntr_id))
    WITH nocounter
   ;end update
   IF (curqual=0
    AND size(objfinencntrmod->objarray,5) != 0)
    CALL echo("afc_encntr_mods::updateFlexiblePftEncntr FAILED.")
    GO TO program_exit
   ENDIF
 END ;Subroutine
 SUBROUTINE processrecurring(dummyvar)
   CALL echo("Entering ProcessRecurring")
   DECLARE nhps = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE hpcount = i4 WITH noconstant(0)
   IF ((((request->o_encntr_type_class_cd=nrecurrenctypeclasscd)
    AND (request->n_encntr_type_class_cd != nrecurrenctypeclasscd)) OR ((request->
   o_encntr_type_class_cd != nrecurrenctypeclasscd)
    AND (request->n_encntr_type_class_cd=nrecurrenctypeclasscd))) )
    CALL echo("Recur to Non Recur")
    SET flexrecurmod = 1
    SET stat = alterlist(post_rel_nt_request->charges,size(pmcharge->charge_items,5))
    SET i = 0
    FOR (i = 1 TO size(pmcharge->charge_items,5))
      IF ( NOT ((pmcharge->charge_items[i].charge_type_cd IN (dcredittypecd, dcreditnowtypecd)))
       AND (pmcharge->charge_items[i].offset_charge_item_id=0.0))
       SET pmcharge->charge_items[i].retier_ind = 1
       SET pmcharge->charge_items[i].checkprice_ind = 1
      ENDIF
    ENDFOR
    CALL getnewprices(pmcharge->charge_item_count)
    CALL retiercharges(pmcharge->charge_item_count)
    CALL postcreditsonly(0)
    CALL invalidatepftencntr(0)
    CALL processinterfaces(0)
    CALL updateguarantor(0)
    CALL removepaymentplans(0)
    CALL reposttransactions(0)
    CALL echo("Leaving ProcessRecurring (Recur and non Recur): Success.")
    GO TO program_exit
   ENDIF
   CALL echo("Exiting ProcessRecurring")
 END ;Subroutine
 SUBROUTINE reposttransactions(dummyvar)
   CALL echo("Entering RePostTransactions.")
   FREE RECORD objfinencntrmod
   RECORD objfinencntrmod(
     1 obj_vrsn_5 = c1
     1 ein_type = i4
     1 proxy_ind = i2
     1 objarray[*]
       2 ibillholdrel = i2
       2 iskillnurserel = i2
       2 istddelrel = i2
       2 iskllnurse1 = i2
       2 iskllnurse2 = i2
       2 iskllnurse3 = i2
       2 iqualforst = i2
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
       2 person_name = vc
       2 acct_nbr = vc
       2 fin_nbr = vc
       2 encntrloc = vc
       2 combined_into_id = f8
       2 billing_entity_name = vc
       2 parent_be_id = f8
       2 guarantor_name = vc
       2 admit_dt_tm = dq8
       2 disch_dt_tm = dq8
       2 attenddrnum = f8
       2 attenddrname = vc
       2 admitdrnum = f8
       2 payment_plan_flag = i2
       2 self_pay_edit_flag = i2
       2 co_pay_amount = f8
       2 co_ins_amount = f8
       2 trans_type_cd = f8
       2 trans_amount = f8
       2 balance = f8
       2 adjustment_balance = f8
       2 applied_payment_balance = f8
       2 charge_balance = f8
       2 unapplied_payment_balance = f8
       2 bad_debt_balance = f8
       2 orig_bill_submit_dt_tm = dq8
       2 orig_bill_transmit_dt_tm = dq8
       2 last_claim_dt_tm = dq8
       2 last_stmt_dt_tm = dq8
       2 bill_counter_term = vc
       2 dunning_level_change_dt_tm = dq8
       2 dunning_level_cnt = i4
       2 dunning_ind = i2
       2 dunning_hold_ind = i2
       2 dunning_pay_cnt = i4
       2 dunning_unacc_pay_cnt = i4
       2 dunning_no_pay_cnt = i4
       2 consolidation_ind = i2
       2 col_letter_ind = i2
       2 send_col_ind = i2
       2 pft_encntr_alias = vc
       2 route_user_name = vc
       2 statement_cycle_id = f8
       2 ins_pend_bal_fwd = f8
       2 pat_bal_fwd = f8
       2 conversion_ind = i2
       2 nbr_of_stmts = i4
       2 bad_debt_dt_tm = dq8
       2 late_chrg_flag = i2
       2 late_chrg_start_dt_tm = dq8
       2 last_charge_dt_tm = dq8
       2 last_payment_dt_tm = dq8
       2 last_patient_pay_dt_tm = dq8
       2 last_adjustment_dt_tm = dq8
       2 zero_balance_dt_tm = dq8
       2 recur_ind = i2
       2 recur_seq = i4
       2 recur_bill_gen_ind = f8
       2 recur_current_month = i4
       2 recur_current_year = i4
       2 recur_bill_ready_ind = i2
       2 pt_start_dt_tm = dq8
       2 pt_total_visits = i4
       2 ot_start_dt_tm = dq8
       2 ot_total_visits = i4
       2 slt_start_dt_tm = dq8
       2 slt_total_visits = i4
       2 cr_start_dt_tm = dq8
       2 cr_total_visits = i4
       2 pft_collection_agency_id = f8
       2 collection_agency_type = vc
       2 org_ind = i2
       2 interim_ind = i2
       2 ext_billing_ind = i2
       2 good_will_ind = i2
       2 pft_encntr_status_cd = f8
       2 pft_encntr_status_disp = vc
       2 pft_encntr_status_desc = vc
       2 pft_encntr_status_mean = vc
       2 pft_encntr_status_code_set = i4
       2 fin_class_cd = f8
       2 fin_class_disp = vc
       2 fin_class_desc = vc
       2 fin_class_mean = vc
       2 fin_class_code_set = i4
       2 collection_state_cd = f8
       2 collection_state_disp = vc
       2 collection_state_desc = vc
       2 collection_state_mean = vc
       2 collection_state_code_set = i4
       2 pft_encntr_collection_r_id = f8
       2 dunning_level_cd = f8
       2 dunning_level_disp = vc
       2 dunning_level_desc = vc
       2 dunning_level_mean = vc
       2 dunning_level_code_set = i4
       2 payment_plan_status_cd = f8
       2 payment_plan_status_disp = vc
       2 payment_plan_status_desc = vc
       2 payment_plan_status_mean = vc
       2 payment_plan_status_code_set = i4
       2 bill_status_cd = f8
       2 bill_status_disp = vc
       2 bill_status_desc = vc
       2 bill_status_mean = vc
       2 bill_status_code_set = i4
       2 submission_route_cd = f8
       2 submission_route_disp = vc
       2 submission_route_desc = vc
       2 submission_route_mean = vc
       2 submission_route_code_set = i4
       2 encntr_type_class_cd = f8
       2 encntr_type_class_disp = vc
       2 encntr_type_class_desc = vc
       2 encntr_type_class_mean = vc
       2 encntr_type_class_code_set = i4
       2 qualifier_cd = f8
       2 qualifier_disp = vc
       2 qualifier_desc = vc
       2 qualifier_mean = vc
       2 qualifier_code_set = i4
       2 account_balance = f8
       2 days_since_last_payment = i4
       2 reg_dt_tm = dq8
       2 med_service_cd = f8
       2 med_service_disp = vc
       2 med_service_desc = vc
       2 med_service_mean = vc
       2 med_service_code_set = i4
       2 modified_ind = i2
       2 currency_type_cd = f8
       2 encntr_fin_class_cd = f8
       2 encntr_fin_class_disp = vc
       2 encntr_fin_class_desc = vc
       2 encntr_fin_class_mean = vc
       2 encntr_fin_class_code_set = i4
       2 encntr_type_cd = f8
       2 encntr_type_disp = vc
       2 encntr_type_desc = vc
       2 encntr_type_mean = vc
       2 encntr_type_code_set = i4
       2 vip_cd = f8
       2 vip_disp = vc
       2 vip_desc = vc
       2 vip_mean = vc
       2 vip_code_set = i4
       2 health_plan_type_cd = f8
       2 health_plan_type_disp = vc
       2 health_plan_type_desc = vc
       2 health_plan_type_mean = vc
       2 health_plan_type_code_set = i4
       2 last_pay_sub_type_cd = f8
       2 last_pay_sub_type_disp = vc
       2 last_pay_sub_type_desc = vc
       2 last_pay_sub_type_mean = vc
       2 last_pay_sub_type_code_set = i4
       2 last_adj_sub_type_cd = f8
       2 last_adj_sub_type_disp = vc
       2 last_adj_sub_type_desc = vc
       2 last_adj_sub_type_mean = vc
       2 last_adj_sub_type_code_set = i4
       2 newest_upt_dt_tm = dq8
       2 coll_send_dt_tm = dq8
       2 pre_coll_send_dt_tm = dq8
       2 client_number_txt_key = vc
       2 primary_hp_id = f8
       2 secondary_hp_id = f8
       2 tertiary_hp_id = f8
       2 last_adjustment_amt = f8
       2 last_payment_amt = f8
       2 loc_nurse_unit_cd = f8
       2 service_date_from = dq8
       2 service_date_through = dq8
       2 entity_instance_desc = vc
       2 entity_resource_large_key = vc
       2 entity_resource_small_key = vc
       2 entity_name = vc
       2 clin_enc_fin_class_cd = f8
       2 clin_enc_fin_class_disp = vc
       2 clin_enc_fin_class_desc = vc
       2 clin_enc_fin_class_mean = vc
       2 clin_enc_fin_class_code_set = i4
       2 consolidation_cd = f8
       2 consolidation_disp = vc
       2 consolidation_desc = vc
       2 consolidation_mean = vc
       2 consolidation_code_set = i4
       2 total_tx_pay_amount = f8
       2 total_tx_adj_amount = f8
       2 total_tx_chrg_amount = f8
       2 batch_total_amount = f8
       2 remaining_est_due_amt = f8
       2 est_financial_resp_amt = f8
       2 pft_queue_item_id = f8
       2 pft_entity_type_cd = f8
       2 pft_entity_type_disp = vc
       2 pft_entity_type_desc = vc
       2 pft_entity_type_mean = vc
       2 pft_entity_type_code_set = f8
       2 pft_entity_status_cd = f8
       2 pft_entity_status_disp = vc
       2 pft_entity_status_desc = vc
       2 pft_entity_status_mean = vc
       2 pft_entity_status_code_set = f8
       2 pft_entity_sub_status_txt = vc
       2 assigned_prsnl_id = f8
       2 queue_item_created_dt_tm = dq8
       2 queue_item_age = i4
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
   RECORD repostpaymentrequest(
     1 objarray[*]
       2 pft_encntr_id = f8
       2 trans_type_cd = f8
       2 trans_sub_type_cd = f8
       2 trans_reason_cd = f8
       2 trans_alias_id = f8
       2 amount = f8
       2 guar_acct_id = f8
       2 payment_method_cd = f8
       2 payment_number_desc = vc
       2 payor_name = vc
       2 cc_auth_nbr = vc
       2 cc_beg_eff_dt_tm = dq8
       2 cc_end_eff_dt_tm = dq8
       2 check_date = dq8
       2 current_cur_cd = f8
       2 orig_cur_cd = f8
       2 bo_hp_reltn_id = f8
       2 transfered_ind = i2
       2 parent_activity_id = f8
       2 transaction_comment_text = vc
   )
   RECORD repostadjustmentrequest(
     1 objarray[*]
       2 pft_encntr_id = f8
       2 trans_type_cd = f8
       2 trans_sub_type_cd = f8
       2 trans_reason_cd = f8
       2 trans_alias_id = f8
       2 amount = f8
       2 bo_hp_reltn_id = f8
       2 transfered_ind = i2
       2 parent_activity_id = f8
       2 transaction_comment_text = vc
   )
   DECLARE j = i4 WITH noconstant(0)
   DECLARE paycount = i4 WITH noconstant(0)
   DECLARE adjcount = i4 WITH noconstant(0)
   DECLARE newtransindex = i4 WITH noconstant(0)
   SET objfinencntrmod->ein_type = ein_encounter_active
   EXECUTE pft_fin_encntr_find  WITH replace("REPLY",reply), replace("REQUEST",encounterrequest),
   replace("OBJREPLY",objfinencntrmod)
   IF ((reply->status_data="F"))
    CALL echo("afc_encntr_mods::RePostTransactions::pft_fin_encntr_find FAILED.")
    GO TO program_exit
   ENDIF
   IF (size(objfinencntrmod->objarray,5) > 0)
    FOR (j = 1 TO size(objfinencntrmod->objarray,5))
      IF (newtransindex=0
       AND (objfinencntrmod->objarray[j].pft_encntr_status_cd != dhistorycd))
       SET newtransindex = j
       CALL echo(build("newTransIndex=",newtransindex))
      ENDIF
    ENDFOR
    SET paycount = 0
    SET adjcount = 0
    FOR (j = 1 TO size(objtransfindrep->objarray,5))
      IF ((objtransfindrep->objarray[j].benefit_order_id=0.0))
       IF ((objtransfindrep->objarray[j].trans_type_cd=demadjcd))
        SET adjcount += 1
        SET stat = alterlist(repostadjustmentrequest->objarray,adjcount)
        SET repostadjustmentrequest->objarray[adjcount].pft_encntr_id = validate(objfinencntrmod->
         objarray[newtransindex].pft_encntr_id,0.0)
        SET repostadjustmentrequest->objarray[adjcount].trans_type_cd = validate(objtransfindrep->
         objarray[j].trans_type_cd,0.0)
        SET repostadjustmentrequest->objarray[adjcount].trans_sub_type_cd = validate(objtransfindrep
         ->objarray[j].trans_sub_type_cd,0.0)
        SET repostadjustmentrequest->objarray[adjcount].trans_reason_cd = validate(objtransfindrep->
         objarray[j].trans_reason_cd,0.0)
        SET repostadjustmentrequest->objarray[adjcount].trans_alias_id = validate(objtransfindrep->
         objarray[j].trans_alias_id,0.0)
        SET repostadjustmentrequest->objarray[adjcount].amount = validate(objtransfindrep->objarray[j
         ].total_trans_amount,0.0)
        SET repostadjustmentrequest->objarray[adjcount].transfered_ind = 1
        SET repostadjustmentrequest->objarray[adjcount].parent_activity_id = validate(objtransfindrep
         ->objarray[j].activity_id,0.0)
       ELSE
        SET paycount += 1
        SET stat = alterlist(repostpaymentrequest->objarray,paycount)
        SET repostpaymentrequest->objarray[paycount].pft_encntr_id = validate(objfinencntrmod->
         objarray[newtransindex].pft_encntr_id,0.0)
        SET repostpaymentrequest->objarray[paycount].trans_type_cd = validate(objtransfindrep->
         objarray[j].trans_type_cd,0.0)
        SET repostpaymentrequest->objarray[paycount].trans_sub_type_cd = validate(objtransfindrep->
         objarray[j].trans_sub_type_cd,0.0)
        SET repostpaymentrequest->objarray[paycount].trans_reason_cd = validate(objtransfindrep->
         objarray[j].trans_reason_cd,0.0)
        SET repostpaymentrequest->objarray[paycount].trans_alias_id = validate(objtransfindrep->
         objarray[j].trans_alias_id,0.0)
        SET repostpaymentrequest->objarray[paycount].amount = validate(objtransfindrep->objarray[j].
         total_trans_amount,0.0)
        SET repostpaymentrequest->objarray[paycount].transfered_ind = 1
        SET repostpaymentrequest->objarray[paycount].parent_activity_id = validate(objtransfindrep->
         objarray[j].activity_id,0.0)
        SET repostpaymentrequest->objarray[paycount].guar_acct_id = validate(objtransfindrep->
         objarray[j].guar_acct_id,0.0)
        SET repostpaymentrequest->objarray[paycount].payment_method_cd = validate(objtransfindrep->
         objarray[j].payment_method_cd,0.0)
        SET repostpaymentrequest->objarray[paycount].payment_number_desc = validate(objtransfindrep->
         objarray[j].payment_number_desc,"0.0")
        SET repostpaymentrequest->objarray[paycount].payor_name = validate(objtransfindrep->objarray[
         j].payor_name,"0.0")
        SET repostpaymentrequest->objarray[paycount].cc_auth_nbr = validate(objtransfindrep->
         objarray[j].cc_auth_nbr,"0.0")
        SET repostpaymentrequest->objarray[paycount].cc_beg_eff_dt_tm = validate(objtransfindrep->
         objarray[j].cc_beg_eff_dt_tm,0.0)
        SET repostpaymentrequest->objarray[paycount].cc_end_eff_dt_tm = validate(objtransfindrep->
         objarray[j].cc_end_eff_dt_tm,0.0)
        SET repostpaymentrequest->objarray[paycount].cc_end_eff_dt_tm = validate(objtransfindrep->
         objarray[j].cc_end_eff_dt_tm,0.0)
        SET repostpaymentrequest->objarray[paycount].check_date = validate(objtransfindrep->objarray[
         j].check_date,0.0)
        SET repostpaymentrequest->objarray[paycount].current_cur_cd = validate(objtransfindrep->
         objarray[j].current_cur_cd,0.0)
        SET repostpaymentrequest->objarray[paycount].orig_cur_cd = validate(objtransfindrep->
         objarray[j].orig_cur_cd,0.0)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (size(repostpaymentrequest->objarray,5) > 0)
    EXECUTE pft_apply_doll_pay_for_encntr  WITH replace("REQUEST",repostpaymentrequest), replace(
     "REPLY",reply)
    IF ((reply->status_data="F"))
     CALL echo("afc_encntr_mods::RePostTransactions::pft_apply_doll_pay_for_encntr FAILED.")
     GO TO program_exit
    ENDIF
   ENDIF
   IF (size(repostpaymentrequest->objarray,5) > 0)
    EXECUTE pft_apply_doll_adj_for_encntr  WITH replace("REQUEST",repostadjustmentrequest), replace(
     "REPLY",reply)
    IF ((reply->status_data="F"))
     CALL echo("afc_encntr_mods::RePostTransactions::pft_apply_doll_adj_for_encntr FAILED.")
     GO TO program_exit
    ENDIF
   ENDIF
   CALL echo("Exiting RePostTransactions.")
 END ;Subroutine
 SUBROUTINE (cancelreportingclaims(ppftencntrid=f8) =i2)
   CALL echo("afc_encntr_mods::cancelReportingClaims::Entering...")
   DECLARE rccnt = i4 WITH protect, noconstant(0)
   IF (dreportclaimcd=0.0)
    CALL echo("afc_encntr_mods::cancelReportingClaims::Reporting claim functionality not installed.")
    RETURN(true)
   ENDIF
   FREE RECORD brrequest
   RECORD brrequest(
     1 objarray[*]
       2 corsp_activity_id = f8
       2 bill_vrsn_nbr = i4
       2 bill_status_cd = f8
       2 bill_status_reason_cd = f8
       2 updt_cnt = i4
   )
   FREE RECORD brreply
   RECORD brreply(
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
   CALL echo(build("afc_encntr_mods::cancelReportingClaims::Encounter [",cnvtstring(ppftencntrid,17,2
      ),"]."))
   SELECT INTO "nl:"
    FROM bill_reltn br1,
     bill_rec brec
    PLAN (br1
     WHERE br1.parent_entity_name="PFT_ENCNTR"
      AND br1.parent_entity_id=ppftencntrid
      AND br1.active_ind=true)
     JOIN (brec
     WHERE brec.corsp_activity_id=br1.corsp_activity_id
      AND brec.bill_type_cd=dreportclaimcd
      AND brec.bill_vrsn_nbr=br1.bill_vrsn_nbr
      AND brec.bill_status_cd IN (dsubmittedcd, dtransmittedcd, dreadytosubmitcd)
      AND brec.active_ind=true)
    DETAIL
     rccnt += 1, stat = alterlist(brrequest->objarray,rccnt), brrequest->objarray[rccnt].
     corsp_activity_id = brec.corsp_activity_id,
     brrequest->objarray[rccnt].bill_vrsn_nbr = brec.bill_vrsn_nbr, brrequest->objarray[rccnt].
     updt_cnt = brec.updt_cnt, brrequest->objarray[rccnt].bill_status_cd = dcanceledcd,
     brrequest->objarray[rccnt].bill_status_reason_cd = dautocancelcd
    WITH nocounter
   ;end select
   IF (rccnt > 0)
    EXECUTE pft_da_upt_bill_rec  WITH replace("REQUEST",brrequest), replace("REPLY",brreply)
    IF ((brreply->status_data.status != "S"))
     CALL echo("afc_encntr_mods::cancelReportingClaims::Script PFT_DA_UPT_BILL_REC failed.")
     FREE RECORD brrequest
     FREE RECORD brreply
     RETURN(false)
    ELSE
     CALL echo(build("afc_encntr_mods::cancelReportingClaims::Canceled [",rccnt,"] reporting claims."
       ))
    ENDIF
   ELSE
    CALL echo("afc_encntr_mods::cancelReportingClaims::No reporting claims to cancel.")
   ENDIF
   FREE RECORD brrequest
   FREE RECORD brreply
   RETURN(true)
 END ;Subroutine
 SUBROUTINE cancelselfpayclaims(ppftencntrid)
   CALL echo("afc_encntr_mods::cancelSelfpayClaims::Entering...")
   DECLARE rccnt = i4 WITH protect, noconstant(0)
   FREE RECORD cancelclaimsrequest
   RECORD cancelclaimsrequest(
     1 claims[*]
       2 corspactivityid = f8
       2 billstatusreasoncdf = vc
   )
   FREE RECORD cancelclaimsreply
   RECORD cancelclaimsreply(
     1 pft_status_data
       2 subeventstatus[1]
         3 programname = vc
         3 subroutinename = vc
         3 message = vc
       2 pft_stats[*]
         3 programname = vc
         3 executioncnt = i4
         3 executiontime = f8
         3 message = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   CALL echo(build("afc_encntr_mods::cancelSelfpayClaims::Encounter [",cnvtstring(ppftencntrid,17,2),
     "]."))
   SELECT INTO "nl:"
    FROM benefit_order bo,
     bo_hp_reltn bhr,
     bill_reltn br1,
     bill_rec brec
    PLAN (bo
     WHERE bo.pft_encntr_id=ppftencntrid
      AND bo.fin_class_cd=dselfpayfccd
      AND bo.bo_status_cd != dinvalidcd)
     JOIN (bhr
     WHERE bhr.benefit_order_id=bo.benefit_order_id
      AND bhr.active_ind=true
      AND bhr.fin_class_cd=dselfpayfccd)
     JOIN (br1
     WHERE br1.parent_entity_name="BO_HP_RELTN"
      AND br1.parent_entity_id=bhr.bo_hp_reltn_id
      AND br1.active_ind=true)
     JOIN (brec
     WHERE brec.corsp_activity_id=br1.corsp_activity_id
      AND brec.bill_vrsn_nbr=br1.bill_vrsn_nbr
      AND brec.active_ind=true
      AND brec.bill_status_cd != dcanceledcd)
    HEAD brec.corsp_activity_id
     rccnt += 1, stat = alterlist(cancelclaimsrequest->claims,rccnt), cancelclaimsrequest->claims[
     rccnt].corspactivityid = brec.corsp_activity_id,
     cancelclaimsrequest->claims[rccnt].billstatusreasoncdf = "AUTO CANCEL"
    WITH nocounter
   ;end select
   IF (rccnt > 0)
    EXECUTE pft_clm_cancel_claim  WITH replace("REQUEST",cancelclaimsrequest), replace("REPLY",
     cancelclaimsreply)
    IF ((cancelclaimsreply->status_data.status != "S"))
     CALL echo("afc_encntr_mods::cancelSelfpayClaims::Script PFT_CLM_CANCEL_CLAIM failed.")
     FREE RECORD cancelclaimsrequest
     FREE RECORD cancelclaimsreply
     RETURN(false)
    ELSE
     CALL echo(build("afc_encntr_mods::cancelSelfpayClaims::Canceled [",rccnt,"] selfpay claims."))
    ENDIF
   ELSE
    CALL echo("afc_encntr_mods::cancelSelfpayClaims::No selfpay claims to cancel.")
   ENDIF
   FREE RECORD cancelclaimsrequest
   FREE RECORD cancelclaimsreply
   RETURN(true)
 END ;Subroutine
 SUBROUTINE creditcharges(dummyvar)
   CALL echo("Entering afc_encntr_mods::CreditCharges")
   SET interfaceindex = 0
   SET copylistindex = 0
   FOR (copylistindex = 1 TO size(pmcharge->charge_items,5))
     IF ((pmcharge->charge_items[copylistindex].retier_ind=1))
      SET interfaceindex += 1
      SET stat = alterlist(afcaddcreditreq->charge,interfaceindex)
      SET afcaddcreditreq->charge[interfaceindex].charge_item_id = pmcharge->charge_items[
      copylistindex].charge_item_id
      SET afcaddcreditreq->charge[interfaceindex].reason_comment = build(
       "Afc_encntr_mods::CreditCharges offset charge_item_id:",pmcharge->charge_items[copylistindex].
       charge_item_id)
     ENDIF
   ENDFOR
   SET afcaddcreditreq->charge_qual = interfaceindex
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(afcaddcreditreq)
    CALL echo("Calling afc_add_credit")
   ENDIF
   IF (size(afcaddcreditreq->charge,5) > 0)
    EXECUTE afc_add_credit  WITH replace("REQUEST",afcaddcreditreq), replace("REPLY",afcaddcreditrep)
    CALL echo("Returned from afc_add_credit.")
    IF ((afcaddcreditrep->status_data.status != "S"))
     CALL echo("afc_encntr_mods::CreditCharges::Script afc_add_credit failed.")
     GO TO program_exit
    ENDIF
   ENDIF
   SET copylistindex = 0
   SET interfaceindex = 0
   IF (flexrecurmod=0)
    FOR (copylistindex = 1 TO size(afcaddcreditrep->charge,5))
      SET interfaceindex += 1
      SET stat = alterlist(chargeinterfacelist->charges,interfaceindex)
      SET chargeinterfacelist->charges[interfaceindex].charge_item_id = afcaddcreditrep->charge[
      copylistindex].charge_item_id
      SET chargeinterfacelist->charges[interfaceindex].interface_id = afcaddcreditrep->charge[
      copylistindex].interface_file_id
      SET chargeinterfacelist->charges[interfaceindex].charge_type_cd = afcaddcreditrep->charge[
      copylistindex].charge_type_cd
    ENDFOR
   ELSE
    FOR (copylistindex = 1 TO size(afcaddcreditrep->charge,5))
      SET interfaceindex += 1
      SET stat = alterlist(creditonlyinterfacelist->charges,interfaceindex)
      SET creditonlyinterfacelist->charges[interfaceindex].charge_item_id = afcaddcreditrep->charge[
      copylistindex].charge_item_id
      SET creditonlyinterfacelist->charges[interfaceindex].interface_id = afcaddcreditrep->charge[
      copylistindex].interface_file_id
      SET creditonlyinterfacelist->charges[interfaceindex].charge_type_cd = afcaddcreditrep->charge[
      copylistindex].charge_type_cd
    ENDFOR
   ENDIF
   CALL echo("Exiting afc_encntr_mods::CreditCharges")
 END ;Subroutine
 SUBROUTINE createnewdebits(dummyvar)
   CALL echo("Entering afc_encntr_mods::CreateNewDebits")
   FREE RECORD g_srvproperties
   RECORD g_srvproperties(
     1 globalfactor = f8
     1 billcachesize = ui4
     1 loglevel = i2
     1 workloadind = i2
     1 timerind = i2
     1 phlebotomyind = i2
     1 replyind = i2
     1 logreqrep = i2
     1 rxversion = i2
   )
   FREE RECORD g_cs13028
   RECORD g_cs13028(
     1 charge_now = f8
     1 credit_now = f8
     1 cr = f8
     1 dr = f8
     1 no_charge = f8
     1 collection = f8
     1 workloadonly = f8
     1 pharmcr = f8
     1 pharmdr = f8
     1 pharmnc = f8
   )
   SET g_srvproperties->logreqrep = 0
   SET copylistindex = 0
   SET nntcnt = size(nt_request->charges,5)
   SET interfaceindex = size(chargeinterfacelist->charges,5)
   SET stat = uar_get_meaning_by_codeset(13028,"CR",1,g_cs13028->cr)
   SET stat = uar_get_meaning_by_codeset(13028,"DR",1,g_cs13028->dr)
   FOR (copylistindex = 1 TO size(chargereleasecopy->charges,5))
     SET chargereleasecopy->charges[copylistindex].parent_charge_item_id = chargereleasecopy->
     charges[copylistindex].charge_item_id
     SET chargereleasecopy->charges[copylistindex].reason_comment = build(
      "Afc_encntr_mods::CreateNewDebits for charge_item_id:",chargereleasecopy->charges[copylistindex
      ].charge_item_id)
     SET chargereleasecopy->charges[copylistindex].charge_item_id = 0.0
   ENDFOR
   IF (size(chargereleasecopy->charges,5) > 0)
    EXECUTE cs_srv_add_charge  WITH replace("REPLY",chargereleasecopy)
    IF ((reply->status_data.status != "S"))
     CALL echo("afc_encntr_mods::CreateNewDebits::Script CS_SRV_ADD_CHARGE failed.")
     GO TO program_exit
    ENDIF
   ENDIF
   SET copylistindex = 0
   FOR (copylistindex = 1 TO size(chargereleasecopy->charges,5))
     IF ((chargereleasecopy->charges[copylistindex].process_flg != 2))
      SET interfaceindex += 1
      SET stat = alterlist(chargeinterfacelist->charges,interfaceindex)
      SET chargeinterfacelist->charges[interfaceindex].charge_item_id = chargereleasecopy->charges[
      copylistindex].charge_item_id
      SET chargeinterfacelist->charges[interfaceindex].interface_id = chargereleasecopy->charges[
      copylistindex].interface_id
      SET chargeinterfacelist->charges[interfaceindex].charge_type_cd = chargereleasecopy->charges[
      copylistindex].charge_type_cd
     ENDIF
   ENDFOR
   CALL echo("Exiting afc_encntr_mods::CreateNewDebits")
   CALL echorecord(chargereleasecopy)
 END ;Subroutine
 SUBROUTINE processinterfaces(dummy)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub ProcessInterfaces")
    CALL echo("----------------------------------")
    CALL echorecord(chargeinterfacelist)
   ENDIF
   DECLARE cntfinal = i4 WITH noconstant(0)
   DECLARE cntfinal2 = i4 WITH noconstant(0)
   IF (size(chargeinterfacelist->charges,5) >= 1)
    SELECT INTO "nl:"
     FROM charge c,
      (dummyt d  WITH seq = value(size(chargeinterfacelist->charges,5)))
     PLAN (d)
      JOIN (c
      WHERE (c.charge_item_id=chargeinterfacelist->charges[d.seq].charge_item_id))
     DETAIL
      chargeinterfacelist->charges[d.seq].interface_id = c.interface_file_id
     WITH nocounter
    ;end select
    SET cntfinal = 0
    SET cntfinal2 = 0
    SET stat = alterlist(afcinterfacecharge_request->interface_charge,10)
    SET stat = alterlist(afcprofit_request->charges,10)
    SELECT INTO "nl:"
     FROM interface_file i,
      (dummyt d  WITH seq = value(size(chargeinterfacelist->charges,5)))
     PLAN (d)
      JOIN (i
      WHERE (i.interface_file_id=chargeinterfacelist->charges[d.seq].interface_id))
     DETAIL
      IF (i.realtime_ind=1)
       cntfinal += 1
       IF (mod(cntfinal,10)=1
        AND cntfinal != 1)
        stat = alterlist(afcinterfacecharge_request->interface_charge,(cntfinal+ 10))
       ENDIF
       afcinterfacecharge_request->interface_charge[cntfinal].charge_item_id = chargeinterfacelist->
       charges[d.seq].charge_item_id
      ELSEIF (i.profit_type_cd > 0)
       cntfinal2 += 1
       IF (mod(cntfinal2,10)=1
        AND cntfinal2 != 1)
        stat = alterlist(afcprofit_request->charges,(cntfinal2+ 10))
       ENDIF
       afcprofit_request->charges[cntfinal2].charge_item_id = chargeinterfacelist->charges[d.seq].
       charge_item_id
      ENDIF
     WITH nocounter
    ;end select
    SET stat = alterlist(afcinterfacecharge_request->interface_charge,cntfinal)
    SET stat = alterlist(afcprofit_request->charges,cntfinal2)
    IF (size(afcprofit_request->charges,5) > 0)
     IF (validate(debug,- (1)) > 1)
      CALL echorecord(afcprofit_request)
     ENDIF
     SET afcprofit_request->remove_commit_ind = 1
     EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",afcprofit_request), replace("REPLY",
      afcprofit_reply)
    ENDIF
    IF (size(afcinterfacecharge_request->interface_charge,5) > 0)
     IF (validate(debug,- (1)) > 1)
      CALL echorecord(afcinterfacecharge_request)
     ENDIF
     EXECUTE afc_post_interface_charge  WITH replace("REQUEST",afcinterfacecharge_request), replace(
      "REPLY",afcinterfacecharge_reply)
     IF (validate(debug,- (1)) > 1)
      CALL echorecord(afcinterfacecharge_reply)
     ENDIF
     IF ((afcinterfacecharge_reply->status_data.status="f"))
      CALL echo("afc_srv_interface_charge failed")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE postcreditsonly(dummy)
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub PostCreditsOnly")
    CALL echo("----------------------------------")
    CALL echorecord(creditonlyinterfacelist)
   ENDIF
   DECLARE cntfinal = i4 WITH noconstant(0)
   DECLARE cntfinal2 = i4 WITH noconstant(0)
   IF (size(creditonlyinterfacelist->charges,5) >= 1)
    SELECT INTO "nl:"
     FROM charge c,
      (dummyt d  WITH seq = value(size(creditonlyinterfacelist->charges,5)))
     PLAN (d)
      JOIN (c
      WHERE (c.charge_item_id=creditonlyinterfacelist->charges[d.seq].charge_item_id))
     DETAIL
      creditonlyinterfacelist->charges[d.seq].interface_id = c.interface_file_id
     WITH nocounter
    ;end select
    SET cntfinal = 0
    SET cntfinal2 = 0
    SET stat = alterlist(afcinterfacecharge_request->interface_charge,10)
    SET stat = alterlist(afcprofit_request->charges,10)
    SELECT INTO "nl:"
     FROM interface_file i,
      (dummyt d  WITH seq = value(size(creditonlyinterfacelist->charges,5)))
     PLAN (d)
      JOIN (i
      WHERE (i.interface_file_id=creditonlyinterfacelist->charges[d.seq].interface_id))
     DETAIL
      IF (i.realtime_ind=1)
       cntfinal += 1
       IF (mod(cntfinal,10)=1
        AND cntfinal != 1)
        stat = alterlist(afcinterfacecharge_request->interface_charge,(cntfinal+ 10))
       ENDIF
       afcinterfacecharge_request->interface_charge[cntfinal].charge_item_id =
       creditonlyinterfacelist->charges[d.seq].charge_item_id
      ELSEIF (i.profit_type_cd > 0)
       cntfinal2 += 1
       IF (mod(cntfinal2,10)=1
        AND cntfinal2 != 1)
        stat = alterlist(afcprofit_request->charges,(cntfinal2+ 10))
       ENDIF
       afcprofit_request->charges[cntfinal2].charge_item_id = creditonlyinterfacelist->charges[d.seq]
       .charge_item_id
      ENDIF
     WITH nocounter
    ;end select
    SET stat = alterlist(afcinterfacecharge_request->interface_charge,cntfinal)
    SET stat = alterlist(afcprofit_request->charges,cntfinal2)
    IF (size(afcprofit_request->charges,5) > 0)
     IF (validate(debug,- (1)) > 1)
      CALL echorecord(afcprofit_request)
     ENDIF
     SET afcprofit_request->remove_commit_ind = 1
     EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",afcprofit_request), replace("REPLY",
      afcprofit_reply)
    ENDIF
    IF (size(afcinterfacecharge_request->interface_charge,5) > 0)
     IF (validate(debug,- (1)) > 1)
      CALL echorecord(afcinterfacecharge_request)
     ENDIF
     EXECUTE afc_post_interface_charge  WITH replace("REQUEST",afcinterfacecharge_request), replace(
      "REPLY",afcinterfacecharge_reply)
     IF (validate(debug,- (1)) > 1)
      CALL echorecord(afcinterfacecharge_reply)
     ENDIF
     IF ((afcinterfacecharge_reply->status_data.status="f"))
      CALL echo("afc_srv_interface_charge failed")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (evaluatenonprimbohpforime(priorityseq=i4) =i2)
   FREE RECORD objdelimebohp
   RECORD objdelimebohp(
     1 objarray[*]
       2 bo_hp_reltn_id = f8
   )
   FREE RECORD uptbhrrequest
   RECORD uptbhrrequest(
     1 objarray[*]
       2 bo_hp_reltn_id = f8
       2 bo_hp_status_cd = f8
       2 updt_cnt = i4
   )
   FREE RECORD uptbillrecreq
   RECORD uptbillrecreq(
     1 objarray[*]
       2 corsp_activity_id = f8
       2 bill_vrsn_nbr = f8
       2 active_ind = i2
       2 updt_cnt = i4
   )
   FREE RECORD addbohprequest
   RECORD addbohprequest(
     1 objarray[1]
       2 bo_hp_reltn_id = f8
       2 benefit_order_id = f8
       2 bill_templ_id = f8
       2 bo_hp_status_cd = f8
       2 encntr_plan_reltn_id = f8
       2 fin_class_cd = f8
       2 health_plan_id = f8
       2 priority_seq = i4
       2 payor_org_id = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 active_ind = i2
       2 resubmission_cnt = i4
       2 total_adj_amount = f8
       2 total_adj_dr_cr_flag = i2
       2 total_billed_amount = f8
       2 total_billed_dr_cr_flag = i2
       2 total_paid_amount = f8
       2 total_paid_dr_cr_flag = i2
       2 reltn_type_cd = f8
   )
   FREE RECORD gimebillinghp
   RECORD gimebillinghp(
     1 healthplans[*]
       2 encntrplanreltnid = f8
       2 healthplanid = f8
       2 priorityseq = i4
       2 financialclasscd = f8
       2 begineffectivedatetime = dq8
       2 endeffectivedatetime = dq8
       2 carrierorgid = f8
       2 planname = vc
       2 plannamekey = vc
       2 bohpreltntypecd = f8
       2 skipaddimebohp = i2
   )
   DECLARE lstatus = i4 WITH noconstant(0)
   DECLARE existingimebohpidx = i4 WITH noconstant(0)
   DECLARE imehpidx = i4 WITH noconstant(0)
   DECLARE claimidx = i4 WITH noconstant(0)
   DECLARE cnt = i4 WITH noconstant(0)
   DECLARE billtemplateid = f8 WITH noconstant(0.0)
   DECLARE benefitorderid = f8 WITH noconstant(0.0)
   DECLARE pftencntrid = f8 WITH noconstant(0.0)
   DECLARE keepexistingimebohp = i2 WITH noconstant(false)
   CALL echo("===================================================================")
   CALL echo("Entering EvaluateNonPrimBoHpForIME subroutine...")
   CALL echo("===================================================================")
   IF (size(objbenefitorderrep->objarray,5)=0)
    CALL logmsg("AFC_ENCNTR_MOD","objBenefitOrderRep is empty",log_debug)
    CALL echo("Failed in AFC_ENCNTR_MOD - objBenefitOrderRep is empty")
    FREE RECORD gimebillinghp
    FREE RECORD addbohprequest
    FREE RECORD uptbillrecreq
    FREE RECORD uptbhrrequest
    FREE RECORD objdelimebohp
    RETURN(false)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(objbenefitorderrep->objarray,5)))
    PLAN (d
     WHERE (objbenefitorderrep->objarray[d.seq].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[d.seq].bill_type_cd=md1450cd)
      AND (objbenefitorderrep->objarray[d.seq].fin_class_cd != dselfpayfccd))
    DETAIL
     benefitorderid = objbenefitorderrep->objarray[d.seq].benefit_order_id, pftencntrid =
     objbenefitorderrep->objarray[d.seq].pft_encntr_id
    WITH nocounter
   ;end select
   CALL echo(build("--------------------- benefitOrderId --",benefitorderid))
   CALL echo(build("--------------------- pftEncntrId --",pftencntrid))
   SET lstatus = getimehealthplans(benefitorderid)
   CALL echo("--------------------- gIMEBillingHP --------------")
   CALL echorecord(gimebillinghp)
   IF (lstatus > 0)
    CALL logmsg("AFC_ENCNTR_MOD","getIMEHealthPlans fails",log_debug)
    CALL echo("Failed in AFC_ENCNTR_MOD at getIMEHealthPlans subroutine")
    FREE RECORD gimebillinghp
    FREE RECORD addbohprequest
    FREE RECORD uptbillrecreq
    FREE RECORD uptbhrrequest
    FREE RECORD objdelimebohp
    FREE RECORD benefitorderfindrep
    RETURN(false)
   ENDIF
   IF ( NOT (getexistingimebohpinfo(pftencntrid)))
    CALL logmsg("AFC_ENCNTR_MOD","getExistingIMEBoHpInfo subroutine fails",log_debug)
    CALL echo("Failed in AFC_ENCNTR_MOD at getExistingIMEBoHpInfo subroutine")
    FREE RECORD gimebillinghp
    FREE RECORD addbohprequest
    FREE RECORD uptbillrecreq
    FREE RECORD uptbhrrequest
    FREE RECORD objdelimebohp
    RETURN(false)
   ENDIF
   IF (size(objexistingimebohp->objarray,5))
    FOR (existingimebohpidx = 1 TO size(objexistingimebohp->objarray,5))
      SET claimidx = 0
      FOR (imehpidx = 1 TO size(gimebillinghp->healthplans,5))
        IF ((gimebillinghp->healthplans[imehpidx].healthplanid=objexistingimebohp->objarray[
        existingimebohpidx].health_plan_id))
         SET keepexistingimebohp = true
         SET gimebillinghp->healthplans[imehpidx].skipaddimebohp = true
        ENDIF
      ENDFOR
      CALL echo(build("--------------------- keepExistingIMEBoHp --",keepexistingimebohp))
      IF ( NOT (keepexistingimebohp))
       IF ((objexistingimebohp->objarray[existingimebohpidx].invalidate_ind=true))
        SET stat = alterlist(uptbhrrequest->objarray,1)
        SET uptbhrrequest->objarray[1].bo_hp_reltn_id = objexistingimebohp->objarray[
        existingimebohpidx].bo_hp_reltn_id
        SET uptbhrrequest->objarray[1].bo_hp_status_cd = dinvalidcd
        SET uptbhrrequest->objarray[1].updt_cnt = - (99999)
        CALL echo("--------------------- uptBhrRequest --------------")
        CALL echorecord(uptbhrrequest)
        IF ( NOT (getcurrentbostatus(uptbhrrequest->objarray[1].bo_hp_reltn_id,oldstatuscd)))
         CALL logmsg("AFC_ENCNTR_MOD","getCurrentBOStatus fails",log_debug)
        ENDIF
        EXECUTE pft_da_upt_bo_hp_reltn  WITH replace("REQUEST",uptbhrrequest), replace("REPLY",reply)
        IF ((reply->status_data.status != "S"))
         CALL logmsg("AFC_ENCNTR_MOD","pft_da_upt_bo_hp_reltn fails",log_debug)
         CALL echo("Failed in AFC_ENCNTR_MOD at pft_da_upt_bo_hp_reltn")
         FREE RECORD gimebillinghp
         FREE RECORD addbohprequest
         FREE RECORD uptbillrecreq
         FREE RECORD uptbhrrequest
         FREE RECORD objdelimebohp
         RETURN(false)
        ENDIF
        IF ((oldstatuscd != uptbhrrequest->objarray[1].bo_hp_status_cd))
         IF ( NOT (createactivityforbalstatuschng(oldstatuscd,uptbhrrequest->objarray[1].
          bo_hp_reltn_id)))
          CALL logmsg("AFC_ENCNTR_MOD","createActivityForBalStatusChng fails",log_debug)
         ENDIF
        ENDIF
        SET stat = initrec(uptbhrrequest)
       ELSE
        SET stat = alterlist(objdelimebohp->objarray,1)
        SET objdelimebohp->objarray[1].bo_hp_reltn_id = objexistingimebohp->objarray[
        existingimebohpidx].bo_hp_reltn_id
        CALL echo("--------------------- objDelIMEBoHp --------------")
        CALL echorecord(objdelimebohp)
        EXECUTE pft_da_del_bo_hp_reltn  WITH replace("REQUEST",objdelimebohp), replace("REPLY",reply)
        IF ((reply->status_data.status != "S"))
         CALL logmsg("AFC_ENCNTR_MOD","pft_da_del_bo_hp_reltn fails",log_debug)
         CALL echo("Failed in AFC_ENCNTR_MOD at pft_da_del_bo_hp_reltn")
         FREE RECORD gimebillinghp
         FREE RECORD addbohprequest
         FREE RECORD uptbillrecreq
         FREE RECORD uptbhrrequest
         FREE RECORD objdelimebohp
         RETURN(false)
        ENDIF
        SET stat = initrec(objdelimebohp)
       ENDIF
       FOR (cnt = 1 TO size(objexistingimebohp->objarray[existingimebohpidx].claim_list,5))
         IF ( NOT ((objexistingimebohp->objarray[existingimebohpidx].claim_list[cnt].bill_status_cd
          IN (cs18935_submitted_cd, cs18935_transmitted_cd, cs18935_denied_cd,
         cs18935_deniedreview_cd)))
          AND (objexistingimebohp->objarray[existingimebohpidx].claim_list[cnt].submit_dt_tm=0))
          SET claimidx += 1
          SET stat = alterlist(uptbillrecreq->objarray,claimidx)
          SET uptbillrecreq->objarray[claimidx].corsp_activity_id = objexistingimebohp->objarray[
          existingimebohpidx].claim_list[cnt].corsp_activity_id
          SET uptbillrecreq->objarray[claimidx].bill_vrsn_nbr = objexistingimebohp->objarray[
          existingimebohpidx].claim_list[cnt].bill_vrsn_nbr
          SET uptbillrecreq->objarray[claimidx].updt_cnt = objexistingimebohp->objarray[
          existingimebohpidx].claim_list[cnt].updt_cnt
          SET uptbillrecreq->objarray[claimidx].active_ind = false
         ENDIF
       ENDFOR
       CALL echo("--------------------- uptBillRecReq --------------")
       CALL echorecord(uptbillrecreq)
       IF (size(uptbillrecreq->objarray,5) > 0)
        EXECUTE pft_da_upt_bill_rec  WITH replace("REQUEST",uptbillrecreq), replace("REPLY",reply)
        IF ((reply->status_data.status != "S"))
         CALL logmsg("AFC_ENCNTR_MOD","pft_da_upt_bill_rec fails",log_debug)
         CALL echo("Failed in AFC_ENCNTR_MOD at pft_da_upt_bill_rec")
         FREE RECORD gimebillinghp
         FREE RECORD addbohprequest
         FREE RECORD uptbillrecreq
         FREE RECORD uptbhrrequest
         FREE RECORD objdelimebohp
         RETURN(false)
        ENDIF
        SET stat = initrec(uptbillrecreq)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (size(gimebillinghp->healthplans,5) > 0)
    FOR (imehpidx = 1 TO size(gimebillinghp->healthplans,5))
      IF (validate(gimebillinghp->healthplans[imehpidx].skipaddimebohp,false)=false)
       SELECT INTO "nl:"
        FROM bo_hp_reltn bhr,
         bill_templ bt
        PLAN (bhr
         WHERE bhr.benefit_order_id=benefitorderid
          AND bhr.priority_seq > 0)
         JOIN (bt
         WHERE bt.bill_templ_id=bhr.bill_templ_id
          AND bt.bill_type_cd=md1450cd
          AND bt.active_ind=true)
        ORDER BY bhr.priority_seq
        HEAD bhr.benefit_order_id
         billtemplateid = bt.bill_templ_id
        WITH nocounter
       ;end select
       IF (curqual=0)
        SELECT INTO "nl:"
         FROM bill_templ bt
         WHERE bt.active_ind=true
          AND bt.bill_type_cd=md1450cd
          AND bt.beg_effective_dt_tm >= cnvtdatetime(sysdate)
          AND bt.end_effective_dt_tm < cnvtdatetime(sysdate)
         DETAIL
          billtemplateid = bt.bill_templ_id
         WITH maxrec = 1
        ;end select
       ENDIF
       SET addbohprequest->objarray[1].benefit_order_id = benefitorderid
       SET addbohprequest->objarray[1].bill_templ_id = billtemplateid
       SET addbohprequest->objarray[1].bo_hp_status_cd = dreadytobillcd
       SET addbohprequest->objarray[1].encntr_plan_reltn_id = gimebillinghp->healthplans[imehpidx].
       encntrplanreltnid
       SET addbohprequest->objarray[1].fin_class_cd = gimebillinghp->healthplans[imehpidx].
       financialclasscd
       SET addbohprequest->objarray[1].health_plan_id = gimebillinghp->healthplans[imehpidx].
       healthplanid
       SET addbohprequest->objarray[1].priority_seq = gimebillinghp->healthplans[imehpidx].
       priorityseq
       SET addbohprequest->objarray[1].payor_org_id = gimebillinghp->healthplans[imehpidx].
       carrierorgid
       SET addbohprequest->objarray[1].beg_effective_dt_tm = gimebillinghp->healthplans[imehpidx].
       begineffectivedatetime
       SET addbohprequest->objarray[1].end_effective_dt_tm = gimebillinghp->healthplans[imehpidx].
       endeffectivedatetime
       SET addbohprequest->objarray[1].active_ind = false
       SET addbohprequest->objarray[1].reltn_type_cd = gimebillinghp->healthplans[imehpidx].
       bohpreltntypecd
       SET addbohprequest->objarray[1].resubmission_cnt = 0
       SET addbohprequest->objarray[1].total_adj_amount = 0.0
       SET addbohprequest->objarray[1].total_adj_dr_cr_flag = 0
       SET addbohprequest->objarray[1].total_billed_amount = 0.0
       SET addbohprequest->objarray[1].total_billed_dr_cr_flag = 0
       SET addbohprequest->objarray[1].total_paid_amount = 0.0
       SET addbohprequest->objarray[1].total_paid_dr_cr_flag = 0
       CALL echorecord(addbohprequest)
       EXECUTE pft_da_add_bo_hp_reltn  WITH replace("REQUEST",addbohprequest), replace("REPLY",reply)
       IF ((reply->status_data.status != "S"))
        CALL logmsg("AFC_ENCNTR_MOD","pft_da_add_bo_hp_reltn fails",log_debug)
        CALL echo("Failed in AFC_ENCNTR_MOD at pft_da_upt_bill_rec")
        FREE RECORD gimebillinghp
        FREE RECORD addbohprequest
        FREE RECORD uptbillrecreq
        FREE RECORD uptbhrrequest
        FREE RECORD objdelimebohp
        RETURN(false)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   FREE RECORD gimebillinghp
   FREE RECORD addbohprequest
   FREE RECORD uptbillrecreq
   FREE RECORD uptbhrrequest
   FREE RECORD objdelimebohp
   CALL echo(
    "==========================  EvaluateNonPrimBoHpForIME Successful  ========================================="
    )
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getexistingimebohpinfo(pftencntrid=f8) =i2)
   FREE RECORD benefitorderreq
   RECORD benefitorderreq(
     1 objarray[*]
       2 pft_encntr_id = f8
   )
   FREE RECORD benefitorderfindrep
   RECORD benefitorderfindrep(
     1 obj_vrsn_5 = c1
     1 ein_type = i4
     1 proxy_ind = i2
     1 objarray[*]
       2 prior_submitted_ind = i2
       2 benefit_order_id = f8
       2 bo_hp_reltn_id = f8
       2 billing_entity_id = f8
       2 parent_be_id = f8
       2 health_plan_id = f8
       2 fin_class_cd = f8
       2 fin_class_disp = vc
       2 fin_class_desc = vc
       2 fin_class_mean = vc
       2 fin_class_code_set = i4
       2 priority_seq = i4
       2 pft_encntr_id = f8
       2 acct_id = f8
       2 bo_hp_status_cd = f8
       2 bo_hp_status_disp = vc
       2 bo_hp_status_desc = vc
       2 bo_hp_status_mean = vc
       2 bo_hp_status_code_set = i4
       2 amount_owed = f8
       2 total_billed_amount = f8
       2 total_paid_amount = f8
       2 total_adj_amount = f8
       2 last_billed_dt_tm = f8
       2 last_payment_dt_tm = dq8
       2 last_adjust_dt_tm = dq8
       2 roll_dt_tm = dq8
       2 roll_user_id = f8
       2 roll_task_id = f8
       2 roll_reason_cd = f8
       2 roll_reason_disp = vc
       2 roll_reason_desc = vc
       2 roll_reason_mean = vc
       2 roll_reason_code_set = i4
       2 roll_review_ind = i2
       2 resubmission_cnt = i4
       2 stmt_status_cd = f8
       2 stmt_status_disp = vc
       2 stmt_status_desc = vc
       2 stmt_status_mean = vc
       2 stmt_status_code_set = i4
       2 payor_org_id = f8
       2 bill_templ_id = f8
       2 encntr_plan_reltn_id = f8
       2 orig_bill_dt_tm = dq8
       2 orig_bill_submit_dt_tm = dq8
       2 orig_bill_transmit_dt_tm = dq8
       2 reltn_type_cd = f8
       2 reltn_type_disp = vc
       2 reltn_type_desc = vc
       2 reltn_type_mean = vc
       2 reltn_type_code_set = i4
       2 pft_proration_id = f8
       2 curr_amt_due = f8
       2 high_amt = f8
       2 non_covered_amt = f8
       2 orig_amt_due = f8
       2 proration_type_cd = f8
       2 proration_type_disp = vc
       2 proration_type_desc = vc
       2 proration_type_mean = vc
       2 proration_type_code_set = i4
       2 total_pay = f8
       2 total_adj = f8
       2 total_pay_amt = f8
       2 updt_cnt = i4
       2 bo_updt_cnt = i4
       2 bhr_updt_cnt = i4
       2 pro_updt_cnt = i4
       2 bill_type_cd = f8
       2 encntr_type_cd = f8
       2 pft_balance_id = f8
       2 health_plan_name = vc
       2 copay_dollars_amt = f8
       2 copay_percent_amt = f8
       2 coinsurance_dollars_amt = f8
       2 coinsurance_percent_amt = f8
       2 deductible_dollars_amt = f8
       2 deductible_percent_amt = f8
       2 trans_type_cd = f8
       2 trans_amount = f8
       2 bt_condition_id = f8
       2 bo_status_cd = f8
       2 bo_status_disp = vc
       2 bo_status_desc = vc
       2 bo_status_mean = vc
       2 bo_status_code_set = i4
       2 bo_status_reason_cd = f8
       2 bo_status_reason_disp = vc
       2 bo_status_reason_desc = vc
       2 bo_status_reason_mean = vc
       2 bo_status_reason_code_set = i4
       2 cross_over_ind = i2
       2 disp_noncovered_ind = i2
       2 man_edit_ind = i2
       2 subscriber_id = f8
       2 cons_bo_sched_id = f8
       2 total_charge_amt = f8
       2 eop_dt_tm = dq8
       2 proration_flag = i2
       2 previous_pft_encntr_id = f8
       2 chrg_group_disp = vc
       2 total_tx_pay_amount = f8
       2 total_tx_adj_amount = f8
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_disp = vc
       2 active_status_desc = vc
       2 active_status_mean = vc
       2 active_status_code_set = i4
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 updt_applctx = i4
       2 updt_dt_tm = dq8
       2 updt_id = f8
       2 updt_task = i4
   )
   DECLARE cnt = i4 WITH noconstant(0)
   DECLARE billcnt = i4 WITH noconstant(0)
   SET stat = alterlist(benefitorderreq->objarray,1)
   SET benefitorderreq->objarray[1].pft_encntr_id = pftencntrid
   SET benefitorderfindrep->ein_type = ein_ime_benefit_order
   EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",benefitorderreq),
   replace("OBJREPLY",benefitorderfindrep)
   CALL echorecord(benefitorderfindrep)
   IF ((reply->status_data.status="F"))
    CALL echo("Failed in AFC_ENCNTR_MOD at getExistingIMEBoHpInfo subroutine")
    FREE RECORD benefitorderreq
    RETURN(false)
   ENDIF
   IF (size(benefitorderfindrep->objarray,5) > 0)
    SET cnt = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(benefitorderfindrep->objarray,5))),
      bo_hp_reltn bhr,
      bill_reltn brl,
      bill_rec br
     PLAN (d)
      JOIN (bhr
      WHERE (bhr.bo_hp_reltn_id=benefitorderfindrep->objarray[d.seq].bo_hp_reltn_id)
       AND bhr.bo_hp_status_cd != dinvalidcd)
      JOIN (brl
      WHERE (brl.parent_entity_id= Outerjoin(bhr.bo_hp_reltn_id)) )
      JOIN (br
      WHERE (br.corsp_activity_id= Outerjoin(brl.corsp_activity_id)) )
     HEAD bhr.bo_hp_reltn_id
      cnt += 1, billcnt = 0, stat = alterlist(objexistingimebohp->objarray,cnt),
      objexistingimebohp->objarray[cnt].bo_hp_reltn_id = bhr.bo_hp_reltn_id, objexistingimebohp->
      objarray[cnt].benefit_order_id = bhr.benefit_order_id, objexistingimebohp->objarray[cnt].
      health_plan_id = bhr.health_plan_id,
      objexistingimebohp->objarray[cnt].invalidate_ind = false
     DETAIL
      IF (br.corsp_activity_id > 0.0)
       IF (br.bill_status_cd IN (cs18935_submitted_cd, cs18935_transmitted_cd, cs18935_denied_cd,
       cs18935_deniedreview_cd)
        AND br.submit_dt_tm > 0.0)
        objexistingimebohp->objarray[cnt].invalidate_ind = true
       ENDIF
       billcnt += 1, stat = alterlist(objexistingimebohp->objarray[cnt].claim_list,billcnt),
       objexistingimebohp->objarray[cnt].claim_list[billcnt].corsp_activity_id = br.corsp_activity_id,
       objexistingimebohp->objarray[cnt].claim_list[billcnt].bill_vrsn_nbr = br.bill_vrsn_nbr,
       objexistingimebohp->objarray[cnt].claim_list[billcnt].bill_status_cd = br.bill_status_cd,
       objexistingimebohp->objarray[cnt].claim_list[billcnt].updt_cnt = br.updt_cnt,
       objexistingimebohp->objarray[cnt].claim_list[billcnt].submit_dt_tm = br.submit_dt_tm
      ENDIF
     WITH nocounter
    ;end select
    CALL echo("---- objExistingIMEBoHp Data Structure in getExistingIMEBoHpInfo() ")
    CALL echorecord(objexistingimebohp)
   ENDIF
   FREE RECORD benefitorderfindrep
   FREE RECORD benefitorderreq
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (hpexpireevalbo(mpftencntrid=f8,mpriorityseq=i4) =i2)
   CALL echo("Entering HPExpireEvalBO")
   DECLARE bhpexistfin = i2 WITH protect, noconstant(false)
   DECLARE bhpexistclin = i2 WITH protect, noconstant(false)
   DECLARE mboidx = i4 WITH protect, noconstant(0)
   DECLARE mcobidx = i4 WITH protect, noconstant(0)
   FOR (mboidx = 1 TO size(objbenefitorderrep->objarray,5))
     IF ((objbenefitorderrep->objarray[mboidx].pft_encntr_id=mpftencntrid)
      AND (objbenefitorderrep->objarray[mboidx].priority_seq=mpriorityseq)
      AND (objbenefitorderrep->objarray[mboidx].active_ind=1)
      AND (objbenefitorderrep->objarray[mboidx].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[mboidx].bo_hp_status_cd != dinvalidcd))
      SET bhpexistfin = true
      IF ((objbenefitorderrep->objarray[mboidx].fin_class_cd=dselfpayfccd))
       IF (mpriorityseq=2)
        SET nsecspfincob = 1
       ELSE
        SET nterspfincob = 1
       ENDIF
      ENDIF
      FOR (mcobidx = 1 TO size(currentcob->objarray,5))
        IF ((currentcob->objarray[mcobidx].priority_seq=objbenefitorderrep->objarray[mboidx].
        priority_seq))
         SET bhpexistclin = true
         IF ((currentcob->objarray[mcobidx].health_plan_id != objbenefitorderrep->objarray[mboidx].
         health_plan_id))
          SET mnewhpid = currentcob->objarray[mcobidx].health_plan_id
         ENDIF
         IF ((currentcob->objarray[mcobidx].financial_class_cd=dselfpayfccd))
          IF (mpriorityseq=2)
           SET nsecspclincob = 1
          ELSE
           SET nterspclincob = 1
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      IF (((bhpexistfin
       AND bhpexistclin
       AND mnewhpid > 0.0) OR (bhpexistfin
       AND  NOT (bhpexistclin))) )
       CALL echo("HPExpireEvalBO found a HP to change or remove")
       SET bocnt = (size(objuptboreq->objarray,5)+ 1)
       SET stat = alterlist(objuptboreq->objarray,bocnt)
       SET objuptboreq->objarray[bocnt].bo_hp_reltn_id = objbenefitorderrep->objarray[mboidx].
       bo_hp_reltn_id
       SET objuptboreq->objarray[bocnt].bhr_updt_cnt = objbenefitorderrep->objarray[mboidx].
       bhr_updt_cnt
       SET objuptboreq->objarray[bocnt].active_ind = 1
       SET objuptboreq->objarray[bocnt].active_status_cd = reqdata->active_status_cd
       SET objuptboreq->objarray[bocnt].pft_proration_id = objbenefitorderrep->objarray[mboidx].
       pft_proration_id
       SET objuptboreq->objarray[bocnt].pro_updt_cnt = objbenefitorderrep->objarray[mboidx].
       pro_updt_cnt
       SET objuptboreq->objarray[bocnt].priority_seq = objbenefitorderrep->objarray[mboidx].
       priority_seq
       SET objuptboreq->objarray[bocnt].health_plan_id = objbenefitorderrep->objarray[mboidx].
       health_plan_id
       SET objuptboreq->objarray[bocnt].encntr_plan_reltn_id = objbenefitorderrep->objarray[mboidx].
       encntr_plan_reltn_id
       SET objuptboreq->objarray[bocnt].pft_encntr_id = objbenefitorderrep->objarray[mboidx].
       pft_encntr_id
      ENDIF
     ENDIF
   ENDFOR
   IF (bhpexistfin
    AND bhpexistclin
    AND mnewhpid > 0.0)
    IF (mpriorityseq=2)
     SET nsecexistfincob = 1
     SET nsecexistclincob = 1
    ELSEIF (mpriorityseq=3)
     SET nterexistfincob = 1
     SET nterexistclincob = 1
    ENDIF
   ELSEIF (bhpexistfin
    AND  NOT (bhpexistclin)
    AND mnewhpid=0.0)
    IF (mpriorityseq=2)
     SET nsecexistfincob = 1
     SET nsecexistclincob = 0
    ELSEIF (mpriorityseq=3)
     SET nterexistfincob = 1
     SET nterexistclincob = 0
    ENDIF
   ELSE
    IF (mpriorityseq=2)
     SET nsecexistfincob = 0
     SET nsecexistclincob = 0
    ELSEIF (mpriorityseq=3)
     SET nterexistfincob = 0
     SET nterexistclincob = 0
    ENDIF
   ENDIF
   IF ( NOT (bhpexistfin))
    SET bhpexistfin = false
    SET bhpexistclin = false
    FOR (mcobidx = 1 TO size(currentcob->objarray,5))
      IF ((currentcob->objarray[mcobidx].priority_seq=mpriorityseq))
       SET bhpexistclin = true
       SET mnewhpid = currentcob->objarray[mcobidx].health_plan_id
       CALL echo("HPExpireEvalBO found a HP to add.")
       CALL echo(mpftencntrid)
       CALL echo(mnewhpid)
       CALL echo(currentcob->objarray[mcobidx].financial_class_cd)
       CALL echo(mpriorityseq)
       IF (mpriorityseq=2
        AND bhpexistclin)
        SET nsecexistclincob = 1
       ELSEIF (mpriorityseq=3
        AND bhpexistclin)
        SET nterexistclincob = 1
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (nsecexistfincob=0
    AND nsecexistclincob=0
    AND nterexistfincob=0
    AND nterexistclincob=0)
    CALL echo(build("HPExpireEvalBO determined no changed needed for priority seq:",mpriorityseq))
    RETURN(false)
   ELSE
    CALL echo(build("HPExpireEvalBO success for priority seq:",mpriorityseq))
    CALL echo(mnewhpid)
    CALL echorecord(objuptboreq)
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE processterthpexpire(chrgcnt)
   CALL echo("Process Tertiary HP Expire Change")
   CALL echo(build("nTerSPFinCOB: ",nterspfincob))
   CALL echo(build("nTerExistClinCOB: ",nterexistclincob))
   CALL echo(build("nTerExistFinCOB: ",nterexistfincob))
   IF (nterexistfincob=1
    AND nterspfincob=0)
    CALL echo("There has been a change in the Tert HP")
    CALL echo("It is not SelfPay")
    CALL echorecord(objuptboreq)
    IF (size(objuptboreq->objarray,5) > 0)
     SET objbobillheader->ein_type = ein_benefit_order
     EXECUTE pft_bill_header_find  WITH replace("REQUEST",objuptboreq), replace("OBJREPLY",
      objbobillheader), replace("REPLY",reply)
     IF ((reply->status_data="F"))
      CALL echo("pft_bill_header_find FAILED.")
      GO TO program_exit
     ENDIF
     CALL echorecord(objbobillheader)
     SET objtransfindrep->hide_charges_ind = 1
     SET objtransfindrep->ein_type = ein_pft_encntr
     EXECUTE pft_transaction_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
      objtransfindrep), replace("REPLY",reply)
     IF ((reply->status_data="F"))
      CALL echo("pft_transaction_find FAILED.")
      GO TO program_exit
     ENDIF
     IF (size(objtransfindrep->objarray,5) > 0
      AND size(objbobillheader->objarray,5) > 0)
      CALL findexpectedtrans(size(objuptboreq->objarray,5))
      IF (size(objreversereq->objarray,5) > 0)
       EXECUTE pft_reverse_transaction  WITH replace("REQUEST",objreversereq), replace("REPLY",reply)
       CALL echorecord(reply)
       IF ((reply->status_data.status != "S"))
        CALL echorecord(reply)
        GO TO program_exit
       ENDIF
       SET stat = alterlist(objbenefitorderrep->objarray,0)
       CALL echo("calling Benefit Order find again, after Transactions")
       EXECUTE pft_benefit_order_find  WITH replace("REPLY",reply), replace("REQUEST",objfinencntrmod
        ), replace("OBJREPLY",objbenefitorderrep)
       CALL echorecord(objbenefitorderrep)
       IF ((reply->status_data.status="F"))
        SET reply->status_data.status = "F"
        GO TO program_exit
       ELSEIF ((reply->status_data.status="Z"))
        SET reply->status_data.status = "Z"
        GO TO program_exit
       ENDIF
       SET stat = initrec(objuptboreq)
       CALL hpexpireevalbo(objfinencntrmod->objarray[mpeidx].pft_encntr_id,2)
       SET stat = initrec(objtransfindrep)
       CALL echo("Get New Transactions as well")
       EXECUTE pft_transaction_find  WITH replace("REQUEST",objfinencntrmod), replace("OBJREPLY",
        objtransfindrep), replace("REPLY",reply)
       IF ((reply->status_data="F"))
        CALL echo("pft_transaction_find FAILED.")
        GO TO program_exit
       ENDIF
      ENDIF
     ENDIF
     CALL echo("Getting Ready to Call to Invalidate BO")
     CALL invalidatebosingle(size(objuptboreq->objarray,5),size(objbobillheader->objarray,5),size(
       objtransfindrep->objarray,5))
     CALL echo("Getting Ready to Call to Inactivate BO")
     CALL inactivatebosingle(size(objuptboreq->objarray,5),size(objbobillheader->objarray,5))
     IF (nterexistclincob=1
      AND nterspclincob=0)
      CALL echo("Changed Secondary HP to New Secondary HP")
      IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
      nhpexpirelogicvar != 1)) )
       CALL addnonprimhptocob(objpmhealthplan->objarray[3].hp_id,3,size(objuptboreq->objarray,5))
      ELSE
       CALL addnonprimhptocob(currentcob->objarray[3].health_plan_id,3,size(objuptboreq->objarray,5))
      ENDIF
     ELSEIF (nterexistclincob=0)
      CALL echo("Changed From Tertiary to SelfPay, no SP Plan")
      CALL remnonprimhptocob(0.0,3)
     ELSEIF (nterexistclincob=1
      AND nsecspclincob=1)
      CALL echo("Changed From Tertiary to SelfPay, with SP Plan")
      CALL remnonprimhptocob(mnewhpid,3)
     ENDIF
     CALL echo("call to Reevaluate Previous BOHP's!!!!!!!!!!!!")
     CALL evalpriorbohp(3)
    ENDIF
   ELSEIF (nterexistfincob=1
    AND nterspfincob=1
    AND nterexistclincob=1)
    CALL echo("Changed from SP to Tertiary HP")
    IF ((((replclinencobj->objarray[1].encntr_type_class_cd != nrecurrenctypeclasscd)) OR (
    nhpexpirelogicvar != 1)) )
     CALL addnonprimhptocob(objpmhealthplan->objarray[3].hp_id,3,0)
    ELSE
     CALL addnonprimhptocob(currentcob->objarray[2].health_plan_id,3,0)
    ENDIF
    CALL evalpriorbohp(3)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(objbenefitorderrep->objarray,5)))
    PLAN (d
     WHERE (objbenefitorderrep->objarray[d.seq].bo_status_cd != dinvalidcd)
      AND (objbenefitorderrep->objarray[d.seq].bill_type_cd=md1450cd)
      AND (objbenefitorderrep->objarray[d.seq].fin_class_cd != dselfpayfccd))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    IF ( NOT (evaluatenonprimbohpforime(3)))
     CALL echo("Call to evaluateNonPrimBoHPForIME sub for tertiary health Plan mod failed.")
     GO TO program_exit
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE resethpflags(dummyvar)
   SET nsecexistfincob = 0
   SET nsecexistclincob = 0
   SET nsecspclincob = 0
   SET nsecspfincob = 0
   SET nterexistfincob = 0
   SET nterexistclincob = 0
   SET nterspclincob = 0
   SET nterspfincob = 0
 END ;Subroutine
 SUBROUTINE getcurrentcob(mencntr_id,meffective_dt_tm)
   CALL echo("Entering GetCurrentCOB")
   DECLARE mprioritycnt = i4 WITH protect, noconstant(0)
   DECLARE mcobidx = i4 WITH protect, noconstant(0)
   DECLARE boverlap = i2 WITH protect, noconstant(false)
   DECLARE bcoveragegap = i2 WITH protect, noconstant(false)
   SET mcobidx = size(currentcob->objarray,5)
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_plan_reltn epr,
     health_plan hp
    PLAN (e
     WHERE e.encntr_id=mencntr_id
      AND e.active_ind=true)
     JOIN (epr
     WHERE epr.encntr_id=mencntr_id
      AND epr.active_ind=true
      AND epr.beg_effective_dt_tm <= cnvtdatetime(meffective_dt_tm)
      AND epr.end_effective_dt_tm >= cnvtdatetime(meffective_dt_tm))
     JOIN (hp
     WHERE hp.health_plan_id=epr.health_plan_id
      AND hp.active_ind=true)
    ORDER BY epr.priority_seq, epr.encntr_plan_reltn_id
    HEAD epr.priority_seq
     mprioritycnt = 0
    DETAIL
     mprioritycnt += 1
     IF (mprioritycnt > 1)
      boverlap = true
     ENDIF
    FOOT  epr.encntr_plan_reltn_id
     IF ( NOT (boverlap)
      AND mprioritycnt > 0)
      mcobidx += 1, stat = alterlist(currentcob->objarray,mcobidx), currentcob->objarray[mcobidx].
      encntr_id = mencntr_id,
      currentcob->objarray[mcobidx].effective_dt_tm = meffective_dt_tm, currentcob->objarray[mcobidx]
      .health_plan_id = epr.health_plan_id, currentcob->objarray[mcobidx].encntr_plan_reltn_id = epr
      .encntr_plan_reltn_id,
      currentcob->objarray[mcobidx].beg_effective_dt_tm = epr.beg_effective_dt_tm, currentcob->
      objarray[mcobidx].end_effective_dt_tm = epr.end_effective_dt_tm, currentcob->objarray[mcobidx].
      priority_seq = epr.priority_seq,
      currentcob->objarray[mcobidx].financial_class_cd = hp.financial_class_cd, currentcob->objarray[
      mcobidx].payer_org = epr.organization_id, currentcob->objarray[mcobidx].person_id = e.person_id
     ENDIF
    WITH nocounter
   ;end select
   IF (boverlap)
    SET currentcob->failure_message = "Overlapping health plan relationship found for non-primary."
    CALL echo("Overlapping health plan relationship found for non-primary.")
    CALL echo(currentcob->failure_message)
    RETURN(false)
   ENDIF
   FOR (mcobidx = 1 TO size(currentcob->objarray,5))
     IF (((mcobidx=1
      AND (currentcob->objarray[mcobidx].priority_seq IN (2, 3))) OR (((mcobidx=2
      AND (currentcob->objarray[mcobidx].priority_seq=3)) OR (mcobidx IN (1, 2)
      AND (currentcob->objarray[mcobidx].priority_seq=0))) )) )
      SET bcoveragegap = true
     ENDIF
   ENDFOR
   IF (bcoveragegap)
    SET currentcob->failure_message = "Gap in health plan coverage found."
    CALL echo("Gap in health plan coverage found.")
    CALL echo(currentcob->failure_message)
    RETURN(false)
   ENDIF
   CALL echo("GetCurrentCOB successful.")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE applycommenttoencounteroutofprocess(pftencntrid,commenttext)
   DECLARE comment_app = i4 WITH protect, noconstant(4080000)
   DECLARE comment_task = i4 WITH protect, noconstant(4080000)
   DECLARE comment_request = i4 WITH protect, noconstant(4070039)
   DECLARE happ = i4 WITH protect, noconstant(0)
   DECLARE htask = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hrequest = i4 WITH protect, noconstant(0)
   DECLARE hcommentitem = i4 WITH protect, noconstant(0)
   DECLARE hreply = i4 WITH protect, noconstant(0)
   DECLARE hrepstruct = i4 WITH protect, noconstant(0)
   SET stat = uar_crmbeginapp(comment_app,happ)
   SET stat = uar_crmbegintask(happ,comment_task,htask)
   SET stat = uar_crmbeginreq(htask,"",comment_request,hreq)
   IF (hreq <= 0.0)
    CALL logmsg(curprog,build("Apply comment - Failed to get App[",happ,"] Task[",htask,
      "] or Request[",
      hrequest,"]"),log_error)
    SET stat = uar_crmendreq(hreq)
    SET stat = uar_crmendtask(htask)
    SET stat = uar_crmendapp(happ)
    RETURN(false)
   ENDIF
   SET hrequest = uar_crmgetrequest(hreq)
   SET hcommentitem = uar_srvadditem(hrequest,"objArray")
   IF (hcommentitem <= 0.0)
    CALL logmsg(curprog,"Apply comment - Failed to get comment item",log_error)
    SET stat = uar_crmendreq(hreq)
    SET stat = uar_crmendtask(htask)
    SET stat = uar_crmendapp(happ)
    RETURN(false)
   ENDIF
   SET stat = uar_srvsetdouble(hcommentitem,"pft_encntr_id",pftencntrid)
   SET stat = uar_srvsetstring(hcommentitem,"corsp_desc",nullterm(commenttext))
   SET stat = uar_srvsetshort(hcommentitem,"importance_flag",2)
   SET stat = uar_srvsetdate(hcommentitem,"created_dt_tm",cnvtdatetime(sysdate))
   SET stat = uar_crmperform(hreq)
   SET hreply = uar_crmgetreply(hrequest)
   SET hrepstruct = uar_srvgetstruct(hreply,"status_data")
   SET replystatus = uar_srvgetstringptr(hrepstruct,"status")
   IF (replystatus != "S")
    CALL logmsg(curprog,"Apply comment - Reply did not return (S)uccess",log_error)
    SET stat = uar_crmendreq(hreq)
    SET stat = uar_crmendtask(htask)
    SET stat = uar_crmendapp(happ)
    RETURN(false)
   ENDIF
   SET stat = uar_crmendreq(hreq)
   SET stat = uar_crmendtask(htask)
   SET stat = uar_crmendapp(happ)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getdefaultselfpayhealthplan(dummyvar=i2) =f8)
   DECLARE defaultselfpayhealthplanid = f8 WITH protect, noconstant(0.0)
   IF (size(objfinencntrmod->objarray,5) > 0)
    SELECT INTO "nl:"
     FROM billing_entity be
     PLAN (be
      WHERE (be.billing_entity_id=objfinencntrmod->objarray[1].billing_entity_id)
       AND be.active_ind=true)
     DETAIL
      defaultselfpayhealthplanid = be.default_selfpay_hp_id
     WITH nocounter
    ;end select
   ENDIF
   RETURN(defaultselfpayhealthplanid)
 END ;Subroutine
 SUBROUTINE (publishworkflowevent(encounterid=f8) =i2)
   CALL logmsg("publishWorkflowEvent","Entering",log_debug)
   IF (checkprg("PFT_PUBLISH_EVENT")=0)
    RETURN(true)
   ENDIF
   DECLARE pftencntrid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM pft_encntr pe
    WHERE pe.encntr_id=encounterid
     AND pe.active_ind=true
    DETAIL
     pftencntrid = pe.pft_encntr_id
    WITH nocounter, maxrec = 1
   ;end select
   IF (pftencntrid=0.0)
    RETURN(true)
   ENDIF
   IF ( NOT (validate(cs23369_wfevent)))
    DECLARE cs23369_wfevent = f8 WITH protect, noconstant(0.0)
    SET stat = uar_get_meaning_by_codeset(23369,"WFEVENT",1,cs23369_wfevent)
   ENDIF
   IF ( NOT (validate(cs29322_encntrreg)))
    DECLARE cs29322_encntrreg = f8 WITH protect, noconstant(0.0)
    SET stat = uar_get_meaning_by_codeset(29322,"ENCNTRREG",1,cs29322_encntrreg)
   ENDIF
   IF (((cs23369_wfevent=0.0) OR (cs29322_encntrreg=0.0)) )
    CALL logmsg("publishWorkflowEvent","Could not find required codevalues",log_debug)
    RETURN(true)
   ENDIF
   FREE RECORD publisheventrequest
   RECORD publisheventrequest(
     1 eventlist[1]
       2 entitytypekey = vc
       2 entityid = f8
       2 eventtypecd = f8
       2 eventcd = f8
       2 params[*]
         3 paramcd = f8
         3 paramvalue = f8
   )
   FREE RECORD publisheventreply
   RECORD publisheventreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET publisheventrequest->eventlist[1].entitytypekey = "PFTENCNTR"
   SET publisheventrequest->eventlist[1].entityid = pftencntrid
   SET publisheventrequest->eventlist[1].eventcd = cs29322_encntrreg
   SET publisheventrequest->eventlist[1].eventtypecd = cs23369_wfevent
   EXECUTE pft_publish_event  WITH replace("REQUEST",publisheventrequest), replace("REPLY",
    publisheventreply)
   IF ((publisheventreply->status_data.status != "S"))
    CALL logmessage("publishWorkflowEvent","Call to pft_publish_event failed",log_debug)
   ENDIF
   CALL logmsg("publishWorkflowEvent","Exiting",log_debug)
 END ;Subroutine
 FREE RECORD pmcharge
 FREE RECORD encounterrequest
 FREE RECORD encounterreply
 FREE RECORD crelease
 FREE RECORD creleasereply
 FREE RECORD pbm_request
 FREE RECORD pbm_reply
 FREE RECORD cm_request
 FREE RECORD cm_reply
 FREE RECORD mic_request
 FREE RECORD mic_reply
 FREE RECORD nt_request
 FREE RECORD reproc_request
 FREE RECORD em_afc_chk_profit_install_reply
 FREE RECORD finencntrfindrequest
 FREE RECORD finencntrfindreply
 FREE RECORD objfinencntrmod
 FREE RECORD acctfindreply
 FREE RECORD objsingleacct
 FREE RECORD billheaderreply
 FREE RECORD objbobills
 FREE RECORD relholdrequest
 FREE RECORD relholdreply
 FREE RECORD applyholdrequest
 FREE RECORD applyholdreply
 FREE RECORD bofindreply
 FREE RECORD objbenefitorderrep
 FREE RECORD em_pbmrequest
 FREE RECORD em_pbmreply
 FREE RECORD insertparrequest
 FREE RECORD cbosemrequest
 FREE RECORD cbosemreply
 FREE RECORD stmtprocrequest
 FREE RECORD stmtprocreply
 FREE RECORD resetstmtrequest
 FREE RECORD objpmhealthplan
 FREE RECORD tempsendpe
 FREE RECORD tempbope
 FREE RECORD tempbostruct
 FREE RECORD interfacefiles
 FREE RECORD charge_req
 FREE RECORD charge_rep
 FREE RECORD post_rel_nt_request
 FREE RECORD objbalids
 FREE RECORD nt_request_all
 FREE RECORD temprecurencntr
 FREE RECORD tempprimaryhps
 FREE RECORD emaddchargemodrequest
 FREE RECORD addchargemodreply
 FREE RECORD add_comment_req
 FREE RECORD chargereleasecopy
 FREE RECORD g_cs13028
 FREE RECORD g_srvproperties
 FREE RECORD afcaddcreditrep
 FREE RECORD afcaddcreditreq
 FREE RECORD afcprofit_reply
 FREE RECORD afcprofit_request
 FREE RECORD afcinterfacecharge_reply
 FREE RECORD afcinterfacecharge_request
 FREE RECORD chargeinterfacelist
 FREE RECORD pbmrequest
 FREE RECORD pbmreply
 FREE RECORD temp_encntr_reply
 FREE RECORD creditonlyinterfacelist
END GO
