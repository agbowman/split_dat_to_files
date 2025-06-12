CREATE PROGRAM afc_undo_credit:dba
 SET afc_undo_credit_vsn = "CHARGSRV-14536.003"
 RECORD reply(
   1 charge_item_id = f8
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
   1 encntr_id = f8
   1 dorderid = f8
   1 nactiveonly = i2
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
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
     2 item_price_adj_amt = f8
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
     2 item_price_adj_amt = f8
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
   1 skip_charge_event_mod_ind = i2
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
 RECORD afcinterfacecharge_request(
   1 interface_charge[*]
     2 charge_item_id = f8
 )
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
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
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
 FREE SET afcprofit_reply
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
  SUBROUTINE isequal(damt1,damt2)
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
 DECLARE acmcnt = i4 WITH public, noconstant(0)
 DECLARE ninterfaceflag = i2 WITH public, noconstant(0)
 DECLARE duncredit = f8 WITH public, noconstant(0.0)
 DECLARE dmodrsn = f8 WITH public, noconstant(0.0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE l_field6 = vc WITH noconstant("")
 DECLARE l_field7 = vc WITH noconstant("")
 DECLARE nqualify = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET l_field6 = uar_i18ngetmessage(i18nhandle,"k1","Undo Credit")
 SET l_field7 = uar_i18ngetmessage(i18nhandle,"k1",
  "This charge is a result of an 'Undo Credit' action")
 SET stat = uar_get_meaning_by_codeset(4001989,"UNCREDIT",1,duncredit)
 SET stat = uar_get_meaning_by_codeset(13019,"MOD RSN",1,dmodrsn)
 SELECT INTO "nl:"
  FROM charge c
  WHERE (c.parent_charge_item_id=request->charge_item_id)
  DETAIL
   nqualify += 1
  WITH nocounter
 ;end select
 IF (nqualify > 1)
  SET reply->status_data.status = "Z"
  GO TO end_program
 ENDIF
 SET chargefind_request->charge_item_id = request->charge_item_id
 EXECUTE afc_charge_find  WITH replace("REQUEST",chargefind_request), replace("REPLY",
  chargefind_reply)
 IF ((((chargefind_reply->charge_item_count < 1)) OR ((chargefind_reply->status_data.status="F"))) )
  CALL echo(build("Charge Find Reply Status is ",chargefind_reply->status_data.status,
    " Ending Program"))
  CALL logmsg(curprog,build("Charge Find Reply Status is ",chargefind_reply->status_data.status,
    " Ending Program"),log_debug)
  SET reply->status_data.status = "F"
  GO TO end_program
 ENDIF
 SET stat = alterlist(addcharge_request->objarray,1)
 SET addcharge_request->objarray[1].charge_item_id = 0.0
 SET addcharge_request->objarray[1].parent_charge_item_id = chargefind_reply->charge_items[1].
 charge_item_id
 SET addcharge_request->objarray[1].charge_event_act_id = chargefind_reply->charge_items[1].
 charge_event_act_id
 SET addcharge_request->objarray[1].charge_event_id = chargefind_reply->charge_items[1].
 charge_event_id
 SET addcharge_request->objarray[1].bill_item_id = chargefind_reply->charge_items[1].bill_item_id
 SET addcharge_request->objarray[1].order_id = chargefind_reply->charge_items[1].order_id
 SET addcharge_request->objarray[1].encntr_id = chargefind_reply->charge_items[1].encntr_id
 SET addcharge_request->objarray[1].person_id = chargefind_reply->charge_items[1].person_id
 SET addcharge_request->objarray[1].payor_id = chargefind_reply->charge_items[1].payor_id
 SET addcharge_request->objarray[1].perf_loc_cd = chargefind_reply->charge_items[1].perf_loc_cd
 SET addcharge_request->objarray[1].ord_loc_cd = chargefind_reply->charge_items[1].ord_loc_cd
 SET addcharge_request->objarray[1].ord_phys_id = chargefind_reply->charge_items[1].ord_phys_id
 SET addcharge_request->objarray[1].perf_phys_id = chargefind_reply->charge_items[1].perf_phys_id
 SET addcharge_request->objarray[1].charge_description = chargefind_reply->charge_items[1].
 charge_description
 SET addcharge_request->objarray[1].price_sched_id = chargefind_reply->charge_items[1].price_sched_id
 SET addcharge_request->objarray[1].item_quantity = chargefind_reply->charge_items[1].item_quantity
 SET addcharge_request->objarray[1].item_price = chargefind_reply->charge_items[1].item_price
 SET addcharge_request->objarray[1].item_extended_price = chargefind_reply->charge_items[1].
 item_extended_price
 SET addcharge_request->objarray[1].item_allowable = chargefind_reply->charge_items[1].item_allowable
 SET addcharge_request->objarray[1].item_copay = chargefind_reply->charge_items[1].item_copay
 SET addcharge_request->objarray[1].charge_type_cd = chargefind_reply->charge_items[1].charge_type_cd
 SET addcharge_request->objarray[1].research_acct_id = chargefind_reply->charge_items[1].
 research_acct_id
 SET addcharge_request->objarray[1].suspense_rsn_cd = chargefind_reply->charge_items[1].
 suspense_rsn_cd
 SET addcharge_request->objarray[1].reason_comment = chargefind_reply->charge_items[1].reason_comment
 SET addcharge_request->objarray[1].posted_cd = chargefind_reply->charge_items[1].posted_cd
 SET addcharge_request->objarray[1].process_flg = 0
 SET addcharge_request->objarray[1].service_dt_tm = chargefind_reply->charge_items[1].service_dt_tm
 SET addcharge_request->objarray[1].activity_dt_tm = chargefind_reply->charge_items[1].activity_dt_tm
 SET addcharge_request->objarray[1].interface_file_id = chargefind_reply->charge_items[1].
 interface_file_id
 SET addcharge_request->objarray[1].tier_group_cd = chargefind_reply->charge_items[1].tier_group_cd
 SET addcharge_request->objarray[1].def_bill_item_id = chargefind_reply->charge_items[1].
 def_bill_item_id
 SET addcharge_request->objarray[1].verify_phys_id = chargefind_reply->charge_items[1].verify_phys_id
 SET addcharge_request->objarray[1].gross_price = chargefind_reply->charge_items[1].gross_price
 SET addcharge_request->objarray[1].discount_amount = chargefind_reply->charge_items[1].
 discount_amount
 SET addcharge_request->objarray[1].manual_ind = chargefind_reply->charge_items[1].manual_ind
 SET addcharge_request->objarray[1].activity_type_cd = chargefind_reply->charge_items[1].
 activity_type_cd
 SET addcharge_request->objarray[1].activity_sub_type_cd = chargefind_reply->charge_items[1].
 activity_sub_type_cd
 SET addcharge_request->objarray[1].provider_specialty_cd = chargefind_reply->charge_items[1].
 provider_specialty_cd
 SET addcharge_request->objarray[1].admit_type_cd = chargefind_reply->charge_items[1].admit_type_cd
 SET addcharge_request->objarray[1].department_cd = chargefind_reply->charge_items[1].department_cd
 SET addcharge_request->objarray[1].institution_cd = chargefind_reply->charge_items[1].institution_cd
 SET addcharge_request->objarray[1].level5_cd = chargefind_reply->charge_items[1].level5_cd
 SET addcharge_request->objarray[1].med_service_cd = chargefind_reply->charge_items[1].med_service_cd
 SET addcharge_request->objarray[1].section_cd = chargefind_reply->charge_items[1].section_cd
 SET addcharge_request->objarray[1].subsection_cd = chargefind_reply->charge_items[1].subsection_cd
 SET addcharge_request->objarray[1].abn_status_cd = chargefind_reply->charge_items[1].abn_status_cd
 SET addcharge_request->objarray[1].cost_center_cd = chargefind_reply->charge_items[1].cost_center_cd
 SET addcharge_request->objarray[1].inst_fin_nbr = chargefind_reply->charge_items[1].inst_fin_nbr
 SET addcharge_request->objarray[1].fin_class_cd = chargefind_reply->charge_items[1].fin_class_cd
 SET addcharge_request->objarray[1].health_plan_id = chargefind_reply->charge_items[1].health_plan_id
 SET addcharge_request->objarray[1].item_interval_id = chargefind_reply->charge_items[1].
 item_interval_id
 SET addcharge_request->objarray[1].item_list_price = chargefind_reply->charge_items[1].
 item_list_price
 SET addcharge_request->objarray[1].item_reimbursement = chargefind_reply->charge_items[1].
 item_reimbursement
 SET addcharge_request->objarray[1].list_price_sched_id = chargefind_reply->charge_items[1].
 list_price_sched_id
 SET addcharge_request->objarray[1].payor_type_cd = chargefind_reply->charge_items[1].payor_type_cd
 SET addcharge_request->objarray[1].epsdt_ind = chargefind_reply->charge_items[1].epsdt_ind
 SET addcharge_request->objarray[1].ref_phys_id = chargefind_reply->charge_items[1].ref_phys_id
 SET addcharge_request->objarray[1].start_dt_tm = chargefind_reply->charge_items[1].start_dt_tm
 SET addcharge_request->objarray[1].stop_dt_tm = chargefind_reply->charge_items[1].stop_dt_tm
 SET addcharge_request->objarray[1].alpha_nomen_id = chargefind_reply->charge_items[1].alpha_nomen_id
 SET addcharge_request->objarray[1].server_process_flag = chargefind_reply->charge_items[1].
 server_process_flag
 SET addcharge_request->objarray[1].item_deductible_amt = chargefind_reply->charge_items[1].
 item_deductible_amt
 SET addcharge_request->objarray[1].item_price_adj_amt = chargefind_reply->charge_items[1].
 item_price_adj_amt
 SET addcharge_request->objarray[1].patient_responsibility_flag = chargefind_reply->charge_items[1].
 patient_responsibility_flag
 SET addcharge_request->objarray[1].active_ind = 1
 CALL echorecord(addcharge_request)
 CALL echo("Executing AFC_ADD_CHARGE")
 CALL logmsg(curprog,"Executing AFC_ADD_CHARGE",log_debug)
 EXECUTE afc_add_charge  WITH replace("REQUEST",addcharge_request), replace("REPLY",addcharge_reply)
 CALL echorecord(addcharge_reply)
 IF ((addcharge_reply->status_data.status="F"))
  CALL echo(build("Add Charge Reply Status is ",addcharge_reply->status_data.status," Ending Program"
    ))
  CALL logmsg(curprog,build("Add Charge Reply Status is ",addcharge_reply->status_data.status,
    " Ending Program"),log_debug)
  SET reply->status_data.status = "F"
  GO TO end_program
 ENDIF
 SET stat = alterlist(addchargemodreq->charge_mod,size(chargefind_reply->charge_items[1].charge_mods,
   5))
 FOR (acmcnt = 1 TO size(chargefind_reply->charge_items[1].charge_mods,5))
   SET addchargemodreq->charge_mod[acmcnt].charge_mod_id = chargefind_reply->charge_items[1].
   charge_mods[acmcnt].charge_mod_id
   SET addchargemodreq->charge_mod[acmcnt].charge_item_id = cnvtreal(addcharge_reply->mod_objs[1].
    mod_recs[1].pk_values)
   SET addchargemodreq->charge_mod[acmcnt].charge_mod_type_cd = chargefind_reply->charge_items[1].
   charge_mods[acmcnt].charge_mod_type_cd
   SET addchargemodreq->charge_mod[acmcnt].field1 = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field1
   SET addchargemodreq->charge_mod[acmcnt].field2 = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field2
   SET addchargemodreq->charge_mod[acmcnt].field3 = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field3
   SET addchargemodreq->charge_mod[acmcnt].field4 = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field4
   SET addchargemodreq->charge_mod[acmcnt].field5 = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field5
   SET addchargemodreq->charge_mod[acmcnt].field6 = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field6
   SET addchargemodreq->charge_mod[acmcnt].field7 = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field7
   SET addchargemodreq->charge_mod[acmcnt].field8 = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field8
   SET addchargemodreq->charge_mod[acmcnt].field9 = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field9
   SET addchargemodreq->charge_mod[acmcnt].field10 = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field10
   SET addchargemodreq->charge_mod[acmcnt].activity_dt_tm = chargefind_reply->charge_items[1].
   charge_mods[acmcnt].activity_dt_tm
   SET addchargemodreq->charge_mod[acmcnt].field1_id = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field1_id
   SET addchargemodreq->charge_mod[acmcnt].field2_id = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field2_id
   SET addchargemodreq->charge_mod[acmcnt].field3_id = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field3_id
   SET addchargemodreq->charge_mod[acmcnt].field4_id = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field4_id
   SET addchargemodreq->charge_mod[acmcnt].field5_id = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].field5_id
   SET addchargemodreq->charge_mod[acmcnt].nomen_id = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].nomen_id
   SET addchargemodreq->charge_mod[acmcnt].cm1_nbr = chargefind_reply->charge_items[1].charge_mods[
   acmcnt].cm1_nbr
   SET addchargemodreq->charge_mod[acmcnt].action_type = "ADD"
   SET addchargemodreq->charge_mod_qual = size(chargefind_reply->charge_items[1].charge_mods,5)
 ENDFOR
 SET addchargemodreq->charge_mod_qual += 1
 SET stat = alterlist(addchargemodreq->charge_mod,addchargemodreq->charge_mod_qual)
 SET acmcnt = addchargemodreq->charge_mod_qual
 SET addchargemodreq->charge_mod[acmcnt].charge_item_id = cnvtreal(addcharge_reply->mod_objs[1].
  mod_recs[1].pk_values)
 SET addchargemodreq->charge_mod[acmcnt].charge_mod_type_cd = dmodrsn
 SET addchargemodreq->charge_mod[acmcnt].field1_id = duncredit
 SET addchargemodreq->charge_mod[acmcnt].field6 = l_field6
 SET addchargemodreq->charge_mod[acmcnt].field7 = l_field7
 SET addchargemodreq->charge_mod[acmcnt].action_type = "ADD"
 SET addchargemodreq->skip_charge_event_mod_ind = 1
 SET addchargemodrep->status_data.status = "Z"
 SET action_begin = 1
 SET action_end = addchargemodreq->charge_mod_qual
 CALL echo("Executing AFC_ADD_CHARGE_MOD to add charge mods to new charge")
 CALL logmsg(curprog,"Executing AFC_ADD_CHARGE_MOD to add charge mods to new charge",log_debug)
 EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addchargemodreq), replace("REPLY",addchargemodrep
  )
 IF ((addchargemodrep->status_data.status="F"))
  SET reply->status_data.status = "F"
  CALL echo(build("AFC_ADD_CHARGE_MOD Reply Status is ",addcharge_reply->status_data.status,
    " Ending Program"))
  CALL logmsg(curprog,build("AFC_ADD_CHARGE_MOD Reply Status is ",addcharge_reply->status_data.status,
    " Ending Program"),log_debug)
  GO TO end_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  FROM interface_file i
  WHERE (i.interface_file_id=chargefind_reply->charge_items[1].interface_file_id)
  DETAIL
   IF (i.realtime_ind=1)
    ninterfaceflag = 1
   ELSEIF (i.profit_type_cd > 0)
    ninterfaceflag = 2
   ENDIF
  WITH nocounter
 ;end select
 IF (ninterfaceflag=1)
  SET stat = alterlist(afcinterfacecharge_request->interface_charge,1)
  SET afcinterfacecharge_request->interface_charge[1].charge_item_id = cnvtreal(addcharge_reply->
   mod_objs[1].mod_recs[1].pk_values)
  EXECUTE afc_post_interface_charge  WITH replace("REQUEST",afcinterfacecharge_request), replace(
   "REPLY",afcinterfacecharge_reply)
  CALL echorecord(afcinterfacecharge_reply)
  IF ((afcinterfacecharge_reply->status_data.status="F"))
   CALL echo("Afc_Post_Interface_Charge Failed")
   CALL logmsg(curprog,"Afc_Post_Interface_Charge Failed",log_debug)
   GO TO end_program
  ENDIF
 ELSEIF (ninterfaceflag=2)
  SET stat = alterlist(afcprofit_request->charges,1)
  SET afcprofit_request->charges[1].charge_item_id = cnvtreal(addcharge_reply->mod_objs[1].mod_recs[1
   ].pk_values)
  EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",afcprofit_request), replace("REPLY",
   afcprofit_reply)
  IF ((afcprofit_reply->status_data.status="F"))
   CALL echo("Pft_nt_chrg_billing Failed")
   CALL logmsg(curprog,"Pft_nt_chrg_billing Failed",log_debug)
   GO TO end_program
  ENDIF
 ENDIF
 SET reply->charge_item_id = cnvtreal(addcharge_reply->mod_objs[1].mod_recs[1].pk_values)
 FREE SET chargefind_request
 FREE SET chargefind_reply
 FREE SET addcharge_request
 FREE SET addcharge_reply
 FREE SET addchargemodreq
 FREE SET addchargemodrep
 FREE SET afcinterfacecharge_request
 FREE SET afcinterfacecharge_reply
 FREE SET afcprofit_request
 FREE SET afcprofit_reply
#end_program
END GO
