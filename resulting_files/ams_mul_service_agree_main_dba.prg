CREATE PROGRAM ams_mul_service_agree_main:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Audit/Commit" = ""
  WITH outdev, auditcommit
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed_mess = false
 SET table_name = fillstring(50," ")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed_mess = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE health_plan = vc
 DECLARE ser_name = vc
 FREE RECORD reply
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 health_plan_id = f8
     2 status = i2
     2 hp_info_qual_cnt = i4
     2 hp_info_qual[*]
       3 health_plan_info_id = f8
       3 long_text_id = f8
       3 status = i2
     2 carrier_qual_cnt = i4
     2 carrier_qual[*]
       3 org_plan_reltn_id = f8
       3 status = i2
     2 phone_qual_cnt = i4
     2 phone_qual[*]
       3 phone_id = f8
       3 status = i2
     2 address_qual_cnt = i4
     2 address_qual[*]
       3 address_id = f8
       3 status = i2
     2 eem_review_reltn_qual_cnt = i4
     2 eem_review_reltn_qual[*]
       3 review_reltn_id = f8
       3 long_text_id = f8
       3 status = i2
       3 phone_qual_cnt = i4
       3 phone_qual[*]
         4 phone_id = f8
         4 status = i2
       3 address_qual_cnt = i4
       3 address_qual[*]
         4 address_id = f8
         4 status = i2
     2 entity_prov_tax_qual_cnt = i4
     2 entity_prov_tax_qual[*]
       3 eem_entity_prov_tax_reltn_id = f8
       3 long_text_id = f8
       3 status = i2
     2 entity_ntwk_qual_cnt = i4
     2 entity_ntwk_qual[*]
       3 entity_ntwk_reltn_id = f8
       3 long_text_id = f8
       3 status = i2
     2 facility_qual_cnt = i4
     2 facility_qual[*]
       3 filter_entity_reltn_id = f8
       3 status = i2
     2 sponsor_qual_cnt = i4
     2 sponsor_qual[*]
       3 org_plan_reltn_id = f8
       3 long_text_id = f8
       3 status = i2
       3 phone_qual_cnt = i4
       3 phone_qual[*]
         4 phone_id = f8
         4 status = i2
       3 address_qual_cnt = i4
       3 address_qual[*]
         4 address_id = f8
         4 status = i2
       3 eem_benefit_reltn_qual_cnt = i4
       3 eem_benefit_reltn_qual[*]
         4 eem_benefit_reltn_id = f8
         4 status = i2
       3 eem_review_reltn_qual_cnt = i4
       3 eem_review_reltn_qual[*]
         4 review_reltn_id = f8
         4 long_text_id = f8
         4 status = i2
         4 phone_qual_cnt = i4
         4 phone_qual[*]
           5 phone_id = f8
           5 status = i2
         4 address_qual_cnt = i4
         4 address_qual[*]
           5 address_id = f8
           5 status = i2
       3 entity_prov_tax_qual_cnt = i4
       3 entity_prov_tax_qual[*]
         4 eem_entity_prov_tax_reltn_id = f8
         4 long_text_id = f8
         4 status = i2
       3 entity_ntwk_qual_cnt = i4
       3 entity_ntwk_qual[*]
         4 entity_ntwk_reltn_id = f8
         4 long_text_id = f8
         4 status = i2
       3 eem_bp_qual_cnt = i4
       3 eem_bp_qual[*]
         4 benefit_plan_id = f8
         4 long_text_id = f8
         4 status = i2
         4 phone_qual_cnt = i4
         4 phone_qual[*]
           5 phone_id = f8
           5 status = i2
         4 address_qual_cnt = i4
         4 address_qual[*]
           5 address_id = f8
           5 status = i2
         4 entity_ntwk_qual_cnt = i4
         4 entity_ntwk_qual[*]
           5 entity_ntwk_reltn_id = f8
           5 long_text_id = f8
           5 status = i2
         4 eem_benefit_reltn_qual_cnt = i4
         4 eem_benefit_reltn_qual[*]
           5 eem_benefit_reltn_id = f8
           5 status = i2
         4 eem_service_type_qual_cnt = i4
         4 eem_service_type_qual[*]
           5 service_type_id = f8
           5 long_text_id = f8
           5 status = i2
           5 phone_qual_cnt = i4
           5 phone_qual[*]
             6 phone_id = f8
             6 status = i2
           5 address_qual_cnt = i4
           5 address_qual[*]
             6 address_id = f8
             6 status = i2
           5 eem_service_list_qual_cnt = i4
           5 eem_service_list_qual[*]
             6 service_list_id = f8
             6 status = i2
           5 eem_benefit_reltn_qual_cnt = i4
           5 eem_benefit_reltn_qual[*]
             6 eem_benefit_reltn_id = f8
             6 status = i2
     2 coop_hp_reltn_qual_cnt = i4
     2 coop_hp_reltn_qual[*]
       3 coop_hp_reltn_id = f8
       3 status = i2
     2 hp_alias_qual_cnt = i4
     2 hp_alias_qual[*]
       3 health_plan_alias_id = f8
       3 status = i2
     2 eem_benefit_reltn_qual_cnt = i4
     2 eem_benefit_reltn_qual[*]
       3 eem_benefit_reltn_id = f8
       3 status = i2
     2 eem_bp_qual_cnt = i4
     2 eem_bp_qual[*]
       3 benefit_plan_id = f8
       3 long_text_id = f8
       3 status = i2
       3 phone_qual_cnt = i4
       3 phone_qual[*]
         4 phone_id = f8
         4 status = i2
       3 address_qual_cnt = i4
       3 address_qual[*]
         4 address_id = f8
         4 status = i2
       3 entity_ntwk_qual_cnt = i4
       3 entity_ntwk_qual[*]
         4 entity_ntwk_reltn_id = f8
         4 long_text_id = f8
         4 status = i2
       3 eem_benefit_reltn_qual_cnt = i4
       3 eem_benefit_reltn_qual[*]
         4 eem_benefit_reltn_id = f8
         4 status = i2
       3 eem_service_type_qual_cnt = i4
       3 eem_service_type_qual[*]
         4 service_type_id = f8
         4 long_text_id = f8
         4 status = i2
         4 phone_qual_cnt = i4
         4 phone_qual[*]
           5 phone_id = f8
           5 status = i2
         4 address_qual_cnt = i4
         4 address_qual[*]
           5 address_id = f8
           5 status = i2
         4 eem_service_list_qual_cnt = i4
         4 eem_service_list_qual[*]
           5 service_list_id = f8
           5 status = i2
         4 eem_benefit_reltn_qual_cnt = i4
         4 eem_benefit_reltn_qual[*]
           5 eem_benefit_reltn_id = f8
           5 status = i2
     2 plan_plan_reltn_qual_cnt = i4
     2 plan_plan_reltn_qual[*]
       3 plan_plan_reltn_id = f8
       3 status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request
 RECORD request(
   1 call_echo_ind = i2
   1 qual[*]
     2 health_plan_id = f8
     2 updt_cnt = i4
     2 data_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 plan_type_cd = f8
     2 plan_name = vc
     2 plan_desc = vc
     2 financial_class_cd = f8
     2 ft_entity_name = c32
     2 ft_entity_id = f8
     2 baby_coverage_cd = f8
     2 comb_baby_bill_cd = f8
     2 plan_class_cd = f8
     2 group_nbr = vc
     2 group_name = vc
     2 policy_nbr = vc
     2 pat_bill_pref_flag = i2
     2 pri_concurrent_ind = i2
     2 sec_concurrent_ind = i2
     2 product_cd = f8
     2 action = i2
     2 force_updt_ind = i2
     2 version_ind = i2
     2 hp_info_qual[*]
       3 health_plan_info_id = f8
       3 hp_info_type_cd = f8
       3 hp_info_sub_type_cd = f8
       3 updt_cnt = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 long_text_action = i2
       3 long_text_id = f8
       3 long_text = vc
       3 long_text_updt_cnt = i4
       3 value_numeric = i4
       3 value_dt_tm = di8
       3 chartable_ind = i2
       3 contributor_system_cd = f8
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
     2 carrier_qual[*]
       3 org_plan_reltn_id = f8
       3 org_plan_reltn_cd = f8
       3 organization_id = f8
       3 updt_cnt = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 contributor_system_cd = f8
       3 group_nbr = vc
       3 group_name = vc
       3 contract_code = vc
       3 data_status_cd = f8
       3 policy_nbr = vc
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
     2 phone_qual[*]
       3 phone_id = f8
       3 phone_type_cd = f8
       3 updt_cnt = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 phone_format_cd = f8
       3 phone_num = vc
       3 phone_type_seq = i4
       3 description = vc
       3 contact = vc
       3 call_instruction = vc
       3 modem_capability_cd = f8
       3 extension = vc
       3 paging_code = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 data_status_cd = f8
       3 beg_effective_mm_dd = i4
       3 end_effective_mm_dd = i4
       3 contributor_system_cd = f8
       3 operation_hours = vc
       3 long_text_id = f8
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
     2 address_qual[*]
       3 address_id = f8
       3 address_type_cd = f8
       3 updt_cnt = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 address_format_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 contact_name = vc
       3 residence_type_cd = f8
       3 comment_txt = vc
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 city = vc
       3 state = vc
       3 state_cd = f8
       3 zipcode = c25
       3 zip_code_group_cd = f8
       3 postal_barcode_info = vc
       3 county = vc
       3 county_cd = f8
       3 country = vc
       3 country_cd = f8
       3 residence_cd = f8
       3 mail_stop = vc
       3 data_status_cd = f8
       3 address_type_seq = i4
       3 beg_effective_mm_dd = i4
       3 end_effective_mm_dd = i4
       3 contributor_system_cd = f8
       3 operation_hours = vc
       3 long_text_id = f8
       3 address_info_status_cd = f8
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
     2 eem_review_reltn_qual[*]
       3 review_reltn_id = f8
       3 specialty_cd = f8
       3 organization_id = f8
       3 long_text_action = i2
       3 long_text_id = f8
       3 long_text = vc
       3 long_text_updt_cnt = i4
       3 seq_nbr = i4
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
       3 active_status_cd = f8
       3 updt_cnt = i4
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
       3 phone_qual[*]
         4 phone_id = f8
         4 phone_type_cd = f8
         4 updt_cnt = i4
         4 active_ind = i2
         4 active_status_cd = f8
         4 phone_format_cd = f8
         4 phone_num = vc
         4 phone_type_seq = i4
         4 description = vc
         4 contact = vc
         4 call_instruction = vc
         4 modem_capability_cd = f8
         4 extension = vc
         4 paging_code = vc
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 data_status_cd = f8
         4 beg_effective_mm_dd = i4
         4 end_effective_mm_dd = i4
         4 contributor_system_cd = f8
         4 operation_hours = vc
         4 long_text_id = f8
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
       3 address_qual[*]
         4 address_id = f8
         4 address_type_cd = f8
         4 updt_cnt = i4
         4 active_ind = i2
         4 active_status_cd = f8
         4 address_format_cd = f8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 contact_name = vc
         4 residence_type_cd = f8
         4 comment_txt = vc
         4 street_addr = vc
         4 street_addr2 = vc
         4 street_addr3 = vc
         4 street_addr4 = vc
         4 city = vc
         4 state = vc
         4 state_cd = f8
         4 zipcode = c25
         4 zip_code_group_cd = f8
         4 postal_barcode_info = vc
         4 county = vc
         4 county_cd = f8
         4 country = vc
         4 country_cd = f8
         4 residence_cd = f8
         4 mail_stop = vc
         4 data_status_cd = f8
         4 address_type_seq = i4
         4 beg_effective_mm_dd = i4
         4 end_effective_mm_dd = i4
         4 contributor_system_cd = f8
         4 operation_hours = vc
         4 long_text_id = f8
         4 address_info_status_cd = f8
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
     2 entity_prov_tax_qual[*]
       3 eem_entity_prov_tax_reltn_id = f8
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 eem_prov_tax_reltn_id = f8
       3 seq_nbr = i4
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 long_text_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
       3 long_text_action = i2
       3 long_text = vc
       3 long_text_updt_cnt = i4
       3 updt_cnt = i4
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
     2 entity_ntwk_qual[*]
       3 entity_ntwk_reltn_id = f8
       3 network_id = f8
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 long_text_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
       3 active_status_cd = f8
       3 long_text_action = i2
       3 long_text = vc
       3 long_text_updt_cnt = i4
       3 updt_cnt = i4
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
     2 facility_qual[*]
       3 filter_entity_reltn_id = f8
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 filter_type_cd = f8
       3 filter_entity1_name = c30
       3 filter_entity1_id = f8
       3 action = i2
     2 sponsor_qual[*]
       3 org_plan_reltn_id = f8
       3 org_plan_reltn_cd = f8
       3 organization_id = f8
       3 updt_cnt = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 contributor_system_cd = f8
       3 group_nbr = vc
       3 group_name = vc
       3 contract_code = vc
       3 data_status_cd = f8
       3 policy_nbr = vc
       3 long_text_action = i2
       3 long_text_id = f8
       3 long_text = vc
       3 long_text_updt_cnt = i4
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
       3 phone_qual[*]
         4 phone_id = f8
         4 phone_type_cd = f8
         4 updt_cnt = i4
         4 active_ind = i2
         4 active_status_cd = f8
         4 phone_format_cd = f8
         4 phone_num = vc
         4 phone_type_seq = i4
         4 description = vc
         4 contact = vc
         4 call_instruction = vc
         4 modem_capability_cd = f8
         4 extension = vc
         4 paging_code = vc
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 data_status_cd = f8
         4 beg_effective_mm_dd = i4
         4 end_effective_mm_dd = i4
         4 contributor_system_cd = f8
         4 operation_hours = vc
         4 long_text_id = f8
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
       3 address_qual[*]
         4 address_id = f8
         4 address_type_cd = f8
         4 updt_cnt = i4
         4 active_ind = i2
         4 active_status_cd = f8
         4 address_format_cd = f8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 contact_name = vc
         4 residence_type_cd = f8
         4 comment_txt = vc
         4 street_addr = vc
         4 street_addr2 = vc
         4 street_addr3 = vc
         4 street_addr4 = vc
         4 city = vc
         4 state = vc
         4 state_cd = f8
         4 zipcode = c25
         4 zip_code_group_cd = f8
         4 postal_barcode_info = vc
         4 county = vc
         4 county_cd = f8
         4 country = vc
         4 country_cd = f8
         4 residence_cd = f8
         4 mail_stop = vc
         4 data_status_cd = f8
         4 address_type_seq = i4
         4 beg_effective_mm_dd = i4
         4 end_effective_mm_dd = i4
         4 contributor_system_cd = f8
         4 operation_hours = vc
         4 long_text_id = f8
         4 address_info_status_cd = f8
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
       3 eem_benefit_reltn_qual[*]
         4 active_ind = i2
         4 active_status_cd = f8
         4 updt_cnt = i4
         4 eem_benefit_reltn_id = f8
         4 eem_benefit_id = f8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 seq_nbr = i4
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
       3 eem_review_reltn_qual[*]
         4 review_reltn_id = f8
         4 specialty_cd = f8
         4 organization_id = f8
         4 seq_nbr = i4
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 active_ind = i2
         4 active_status_cd = f8
         4 updt_cnt = i4
         4 long_text_action = i2
         4 long_text_id = f8
         4 long_text = vc
         4 long_text_updt_cnt = i4
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
         4 phone_qual[*]
           5 phone_id = f8
           5 phone_type_cd = f8
           5 updt_cnt = i4
           5 active_ind = i2
           5 active_status_cd = f8
           5 phone_format_cd = f8
           5 phone_num = vc
           5 phone_type_seq = i4
           5 description = vc
           5 contact = vc
           5 call_instruction = vc
           5 modem_capability_cd = f8
           5 extension = vc
           5 paging_code = vc
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 data_status_cd = f8
           5 beg_effective_mm_dd = i4
           5 end_effective_mm_dd = i4
           5 contributor_system_cd = f8
           5 operation_hours = vc
           5 long_text_id = f8
           5 action = i2
           5 force_updt_ind = i2
           5 version_ind = i2
         4 address_qual[*]
           5 address_id = f8
           5 address_type_cd = f8
           5 updt_cnt = i4
           5 active_ind = i2
           5 active_status_cd = f8
           5 address_format_cd = f8
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 contact_name = vc
           5 residence_type_cd = f8
           5 comment_txt = vc
           5 street_addr = vc
           5 street_addr2 = vc
           5 street_addr3 = vc
           5 street_addr4 = vc
           5 city = vc
           5 state = vc
           5 state_cd = f8
           5 zipcode = c25
           5 zip_code_group_cd = f8
           5 postal_barcode_info = vc
           5 county = vc
           5 county_cd = f8
           5 country = vc
           5 country_cd = f8
           5 residence_cd = f8
           5 mail_stop = vc
           5 data_status_cd = f8
           5 address_type_seq = i4
           5 beg_effective_mm_dd = i4
           5 end_effective_mm_dd = i4
           5 contributor_system_cd = f8
           5 operation_hours = vc
           5 long_text_id = f8
           5 address_info_status_cd = f8
           5 action = i2
           5 force_updt_ind = i2
           5 version_ind = i2
       3 entity_prov_tax_qual[*]
         4 eem_entity_prov_tax_reltn_id = f8
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 eem_prov_tax_reltn_id = f8
         4 seq_nbr = i4
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 long_text_id = f8
         4 active_ind = i2
         4 active_status_cd = f8
         4 long_text_action = i2
         4 long_text = vc
         4 long_text_updt_cnt = i4
         4 updt_cnt = i4
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
       3 entity_ntwk_qual[*]
         4 entity_ntwk_reltn_id = f8
         4 network_id = f8
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 long_text_id = f8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 active_ind = i2
         4 active_status_cd = f8
         4 long_text_action = i2
         4 long_text = vc
         4 long_text_updt_cnt = i4
         4 updt_cnt = i4
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
       3 eem_bp_qual[*]
         4 benefit_plan_id = f8
         4 benefit_plan_cd = f8
         4 optional_cd = f8
         4 description = vc
         4 seq_nbr = i4
         4 contract_code = vc
         4 long_text_action = i2
         4 long_text_id = f8
         4 long_text = vc
         4 long_text_updt_cnt = i4
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 active_ind = i2
         4 active_status_cd = f8
         4 updt_cnt = i4
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
         4 phone_qual[*]
           5 phone_id = f8
           5 phone_type_cd = f8
           5 updt_cnt = i4
           5 active_ind = i2
           5 active_status_cd = f8
           5 phone_format_cd = f8
           5 phone_num = vc
           5 phone_type_seq = i4
           5 description = vc
           5 contact = vc
           5 call_instruction = vc
           5 modem_capability_cd = f8
           5 extension = vc
           5 paging_code = vc
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 data_status_cd = f8
           5 beg_effective_mm_dd = i4
           5 end_effective_mm_dd = i4
           5 contributor_system_cd = f8
           5 operation_hours = vc
           5 long_text_id = f8
           5 action = i2
           5 force_updt_ind = i2
           5 version_ind = i2
         4 address_qual[*]
           5 address_id = f8
           5 address_type_cd = f8
           5 updt_cnt = i4
           5 active_ind = i2
           5 active_status_cd = f8
           5 address_format_cd = f8
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 contact_name = vc
           5 residence_type_cd = f8
           5 comment_txt = vc
           5 street_addr = vc
           5 street_addr2 = vc
           5 street_addr3 = vc
           5 street_addr4 = vc
           5 city = vc
           5 state = vc
           5 state_cd = f8
           5 zipcode = c25
           5 zip_code_group_cd = f8
           5 postal_barcode_info = vc
           5 county = vc
           5 county_cd = f8
           5 country = vc
           5 country_cd = f8
           5 residence_cd = f8
           5 mail_stop = vc
           5 data_status_cd = f8
           5 address_type_seq = i4
           5 beg_effective_mm_dd = i4
           5 end_effective_mm_dd = i4
           5 contributor_system_cd = f8
           5 operation_hours = vc
           5 long_text_id = f8
           5 address_info_status_cd = f8
           5 action = i2
           5 force_updt_ind = i2
           5 version_ind = i2
         4 entity_ntwk_qual[*]
           5 entity_ntwk_reltn_id = f8
           5 network_id = f8
           5 parent_entity_name = vc
           5 parent_entity_id = f8
           5 long_text_id = f8
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 active_ind = i2
           5 active_status_cd = f8
           5 long_text_action = i2
           5 long_text = vc
           5 long_text_updt_cnt = i4
           5 updt_cnt = i4
           5 action = i2
           5 force_updt_ind = i2
           5 version_ind = i2
         4 eem_benefit_reltn_qual[*]
           5 active_ind = i2
           5 active_status_cd = f8
           5 updt_cnt = i4
           5 eem_benefit_reltn_id = f8
           5 eem_benefit_id = f8
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 seq_nbr = i4
           5 action = i2
           5 force_updt_ind = i2
           5 version_ind = i2
         4 eem_service_type_qual[*]
           5 service_type_id = f8
           5 service_type_cd = f8
           5 seq_nbr = i4
           5 description = vc
           5 long_text_action = i2
           5 long_text_id = f8
           5 long_text = vc
           5 long_text_updt_cnt = i4
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 active_ind = i2
           5 active_status_cd = f8
           5 updt_cnt = i4
           5 action = i2
           5 force_updt_ind = i2
           5 version_ind = i2
           5 phone_qual[*]
             6 phone_id = f8
             6 phone_type_cd = f8
             6 updt_cnt = i4
             6 active_ind = i2
             6 active_status_cd = f8
             6 phone_format_cd = f8
             6 phone_num = vc
             6 phone_type_seq = i4
             6 description = vc
             6 contact = vc
             6 call_instruction = vc
             6 modem_capability_cd = f8
             6 extension = vc
             6 paging_code = vc
             6 beg_effective_dt_tm = dq8
             6 end_effective_dt_tm = dq8
             6 data_status_cd = f8
             6 beg_effective_mm_dd = i4
             6 end_effective_mm_dd = i4
             6 contributor_system_cd = f8
             6 operation_hours = vc
             6 long_text_id = f8
             6 action = i2
             6 force_updt_ind = i2
             6 version_ind = i2
           5 address_qual[*]
             6 address_id = f8
             6 address_type_cd = f8
             6 updt_cnt = i4
             6 active_ind = i2
             6 active_status_cd = f8
             6 address_format_cd = f8
             6 beg_effective_dt_tm = dq8
             6 end_effective_dt_tm = dq8
             6 contact_name = vc
             6 residence_type_cd = f8
             6 comment_txt = vc
             6 street_addr = vc
             6 street_addr2 = vc
             6 street_addr3 = vc
             6 street_addr4 = vc
             6 city = vc
             6 state = vc
             6 state_cd = f8
             6 zipcode = c25
             6 zip_code_group_cd = f8
             6 postal_barcode_info = vc
             6 county = vc
             6 county_cd = f8
             6 country = vc
             6 country_cd = f8
             6 residence_cd = f8
             6 mail_stop = vc
             6 data_status_cd = f8
             6 address_type_seq = i4
             6 beg_effective_mm_dd = i4
             6 end_effective_mm_dd = i4
             6 contributor_system_cd = f8
             6 operation_hours = vc
             6 long_text_id = f8
             6 address_info_status_cd = f8
             6 action = i2
             6 force_updt_ind = i2
             6 version_ind = i2
           5 eem_service_list_qual[*]
             6 service_list_id = f8
             6 service_type_id = f8
             6 seq_nbr = i4
             6 type_inc_exc_cd = f8
             6 type_inc_exc_meaning = c12
             6 type_vocab_cd = f8
             6 type_beg_nomen_id = f8
             6 type_beg_ident = vc
             6 type_end_nomen_id = f8
             6 type_end_ident = vc
             6 cause_inc_exc_cd = f8
             6 cause_inc_exc_meaning = c12
             6 cause_vocab_cd = f8
             6 cause_beg_nomen_id = f8
             6 cause_beg_ident = vc
             6 cause_end_nomen_id = f8
             6 cause_end_ident = vc
             6 beg_effective_dt_tm = dq8
             6 end_effective_dt_tm = dq8
             6 active_ind = i2
             6 active_status_cd = f8
             6 updt_cnt = i4
             6 action = i2
             6 force_updt_ind = i2
             6 version_ind = i2
           5 eem_benefit_reltn_qual[*]
             6 active_ind = i2
             6 active_status_cd = f8
             6 updt_cnt = i4
             6 eem_benefit_reltn_id = f8
             6 eem_benefit_id = f8
             6 beg_effective_dt_tm = dq8
             6 end_effective_dt_tm = dq8
             6 seq_nbr = i4
             6 action = i2
             6 force_updt_ind = i2
             6 version_ind = i2
     2 coop_hp_reltn_qual[*]
       3 coop_hp_reltn_id = f8
       3 sec_health_plan_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 updt_cnt = i4
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
     2 hp_alias_qual[*]
       3 plan_alias_type_cd = f8
       3 plan_alias_sub_type_cd = f8
       3 health_plan_alias_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
       3 alias_pool_cd = f8
       3 alias = vc
       3 check_digit = i4
       3 check_digit_method_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 data_status_cd = f8
       3 contributor_system_cd = f8
       3 updt_cnt = i4
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
     2 eem_benefit_reltn_qual[*]
       3 active_ind = i2
       3 active_status_cd = f8
       3 eem_benefit_reltn_id = f8
       3 eem_benefit_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 seq_nbr = i4
       3 updt_cnt = i4
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
     2 eem_bp_qual[*]
       3 benefit_plan_id = f8
       3 benefit_plan_cd = f8
       3 optional_cd = f8
       3 description = vc
       3 seq_nbr = i4
       3 contract_code = vc
       3 long_text_action = i2
       3 long_text_id = f8
       3 long_text = vc
       3 long_text_updt_cnt = i4
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
       3 active_status_cd = f8
       3 updt_cnt = i4
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
       3 phone_qual[*]
         4 phone_id = f8
         4 phone_type_cd = f8
         4 active_ind = i2
         4 active_status_cd = f8
         4 phone_format_cd = f8
         4 phone_num = vc
         4 phone_type_seq = i4
         4 description = vc
         4 contact = vc
         4 call_instruction = vc
         4 modem_capability_cd = f8
         4 extension = vc
         4 paging_code = vc
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 data_status_cd = f8
         4 beg_effective_mm_dd = i4
         4 end_effective_mm_dd = i4
         4 contributor_system_cd = f8
         4 operation_hours = vc
         4 long_text_id = f8
         4 updt_cnt = i4
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
       3 address_qual[*]
         4 address_id = f8
         4 address_type_cd = f8
         4 active_ind = i2
         4 active_status_cd = f8
         4 address_format_cd = f8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 contact_name = vc
         4 residence_type_cd = f8
         4 comment_txt = vc
         4 street_addr = vc
         4 street_addr2 = vc
         4 street_addr3 = vc
         4 street_addr4 = vc
         4 city = vc
         4 state = vc
         4 state_cd = f8
         4 zipcode = c25
         4 zip_code_group_cd = f8
         4 postal_barcode_info = vc
         4 county = vc
         4 county_cd = f8
         4 country = vc
         4 country_cd = f8
         4 residence_cd = f8
         4 mail_stop = vc
         4 data_status_cd = f8
         4 address_type_seq = i4
         4 beg_effective_mm_dd = i4
         4 end_effective_mm_dd = i4
         4 contributor_system_cd = f8
         4 operation_hours = vc
         4 long_text_id = f8
         4 address_info_status_cd = f8
         4 updt_cnt = i4
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
       3 entity_ntwk_qual[*]
         4 entity_ntwk_reltn_id = f8
         4 network_id = f8
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 long_text_id = f8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 active_ind = i2
         4 active_status_cd = f8
         4 long_text_action = i2
         4 long_text = vc
         4 long_text_updt_cnt = i4
         4 updt_cnt = i4
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
       3 eem_benefit_reltn_qual[*]
         4 active_ind = i2
         4 active_status_cd = f8
         4 eem_benefit_reltn_id = f8
         4 eem_benefit_id = f8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 seq_nbr = i4
         4 updt_cnt = i4
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
       3 eem_service_type_qual[*]
         4 service_type_id = f8
         4 service_type_cd = f8
         4 seq_nbr = i4
         4 description = vc
         4 long_text_action = i2
         4 long_text_id = f8
         4 long_text = vc
         4 long_text_updt_cnt = i4
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 active_ind = i2
         4 active_status_cd = f8
         4 updt_cnt = i4
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
         4 phone_qual[*]
           5 phone_id = f8
           5 phone_type_cd = f8
           5 active_ind = i2
           5 active_status_cd = f8
           5 phone_format_cd = f8
           5 phone_num = vc
           5 phone_type_seq = i4
           5 description = vc
           5 contact = vc
           5 call_instruction = vc
           5 modem_capability_cd = f8
           5 extension = vc
           5 paging_code = vc
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 data_status_cd = f8
           5 beg_effective_mm_dd = i4
           5 end_effective_mm_dd = i4
           5 contributor_system_cd = f8
           5 operation_hours = vc
           5 long_text_id = f8
           5 updt_cnt = i4
           5 action = i2
           5 force_updt_ind = i2
           5 version_ind = i2
         4 address_qual[*]
           5 address_id = f8
           5 address_type_cd = f8
           5 active_ind = i2
           5 active_status_cd = f8
           5 address_format_cd = f8
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 contact_name = vc
           5 residence_type_cd = f8
           5 comment_txt = vc
           5 street_addr = vc
           5 street_addr2 = vc
           5 street_addr3 = vc
           5 street_addr4 = vc
           5 city = vc
           5 state = vc
           5 state_cd = f8
           5 zipcode = c25
           5 zip_code_group_cd = f8
           5 postal_barcode_info = vc
           5 county = vc
           5 county_cd = f8
           5 country = vc
           5 country_cd = f8
           5 residence_cd = f8
           5 mail_stop = vc
           5 data_status_cd = f8
           5 address_type_seq = i4
           5 beg_effective_mm_dd = i4
           5 end_effective_mm_dd = i4
           5 contributor_system_cd = f8
           5 operation_hours = vc
           5 long_text_id = f8
           5 address_info_status_cd = f8
           5 updt_cnt = i4
           5 action = i2
           5 force_updt_ind = i2
           5 version_ind = i2
         4 eem_service_list_qual[*]
           5 service_list_id = f8
           5 service_type_id = f8
           5 seq_nbr = i4
           5 type_inc_exc_cd = f8
           5 type_inc_exc_meaning = c12
           5 type_vocab_cd = f8
           5 type_beg_nomen_id = f8
           5 type_beg_ident = vc
           5 type_end_nomen_id = f8
           5 type_end_ident = vc
           5 cause_inc_exc_cd = f8
           5 cause_inc_exc_meaning = c12
           5 cause_vocab_cd = f8
           5 cause_beg_nomen_id = f8
           5 cause_beg_ident = vc
           5 cause_end_nomen_id = f8
           5 cause_end_ident = vc
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 active_ind = i2
           5 active_status_cd = f8
           5 updt_cnt = i4
           5 action = i2
           5 force_updt_ind = i2
           5 version_ind = i2
         4 eem_benefit_reltn_qual[*]
           5 active_ind = i2
           5 active_status_cd = f8
           5 eem_benefit_reltn_id = f8
           5 eem_benefit_id = f8
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 seq_nbr = i4
           5 updt_cnt = i4
           5 action = i2
           5 force_updt_ind = i2
           5 version_ind = i2
     2 service_type_cd = f8
     2 fb_benefit_set_uid = vc
     2 plan_plan_reltn_qual[*]
       3 plan_plan_reltn_id = f8
       3 health_plan_reltn_cd = f8
       3 health_plan_id = f8
       3 active_ind = i2
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 benefit_set_name = vc
 )
 FOR (j = 1 TO value(size(file_content->qual,5)))
   SET health_plan = trim(cnvtupper(file_content->qual[j].health_plan_name))
   SET cnt = 0
   SELECT
    hp.health_plan_id
    FROM health_plan hp
    WHERE hp.plan_name_key=health_plan
    ORDER BY hp.health_plan_id
    HEAD hp.health_plan_id
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(request->qual,(cnt+ 9))
     ENDIF
     request->qual[cnt].health_plan_id = hp.health_plan_id, request->qual[cnt].updt_cnt = hp.updt_cnt,
     request->qual[cnt].plan_desc = hp.plan_desc,
     request->qual[cnt].action = 2, request->qual[cnt].data_status_cd = hp.data_status_cd, request->
     qual[cnt].service_type_cd = hp.service_type_cd,
     request->qual[cnt].plan_name = hp.plan_name, request->qual[cnt].product_cd = hp.product_cd,
     request->qual[cnt].financial_class_cd = hp.financial_class_cd,
     request->qual[cnt].contributor_system_cd = hp.contributor_system_cd, request->qual[cnt].
     plan_class_cd = hp.plan_class_cd, request->qual[cnt].plan_type_cd = hp.plan_type_cd,
     request->qual[cnt].beg_effective_dt_tm = hp.beg_effective_dt_tm, request->qual[cnt].
     end_effective_dt_tm = hp.end_effective_dt_tm, request->qual[cnt].policy_nbr = hp.policy_nbr,
     request->qual[cnt].group_name = hp.group_name, request->qual[cnt].group_nbr = hp.group_nbr,
     request->qual[cnt].pri_concurrent_ind = hp.pri_concurrent_ind,
     request->qual[cnt].sec_concurrent_ind = hp.sec_concurrent_ind, request->qual[cnt].force_updt_ind
      = 0, request->qual[cnt].ft_entity_id = 0
    FOOT REPORT
     stat = alterlist(request->qual,cnt)
    WITH nocounter
   ;end select
   SET ser_name = trim(cnvtupper(file_content->qual[j].service_agree_name))
   SELECT
    eb.eem_benefit_id
    FROM eem_benefit eb
    WHERE eb.mnemonic_key=ser_name
    ORDER BY eb.eem_benefit_id
    HEAD eb.eem_benefit_id
     idx2 = 0, idx2 = (idx2+ 1)
     IF (mod(idx2,10)=1)
      stat = alterlist(request->qual[1].eem_benefit_reltn_qual,(idx2+ 9))
     ENDIF
     CALL echo("6"), request->qual[1].eem_benefit_reltn_qual[idx2].eem_benefit_id = eb.eem_benefit_id
    FOOT  eb.eem_benefit_id
     stat = alterlist(request->qual[1].eem_benefit_reltn_qual,idx2)
    WITH nocounter
   ;end select
   SELECT
    sen = max(ebr.seq_nbr)
    FROM eem_benefit_reltn ebr
    WHERE (ebr.parent_entity_id=request->qual[1].health_plan_id)
    ORDER BY ebr.parent_entity_id
    HEAD REPORT
     request->qual[1].eem_benefit_reltn_qual[1].seq_nbr = 1
    HEAD ebr.parent_entity_id
     idx2 = 0, ipos = 0, idx2 = (idx2+ 1)
     IF (mod(idx2,10)=1)
      stat = alterlist(request->qual[1].eem_benefit_reltn_qual,(idx2+ 9))
     ENDIF
     request->qual[1].eem_benefit_reltn_qual[idx2].action = 1, request->qual[1].
     eem_benefit_reltn_qual[idx2].eem_benefit_reltn_id = 0.00, request->qual[1].
     eem_benefit_reltn_qual[idx2].seq_nbr = (sen+ 1),
     request->qual[1].eem_benefit_reltn_qual[idx2].active_ind = 1, request->qual[1].
     eem_benefit_reltn_qual[idx2].force_updt_ind = 0, request->qual[1].eem_benefit_reltn_qual[idx2].
     updt_cnt = 0
    FOOT  ebr.parent_entity_id
     stat = alterlist(request->qual[1].eem_benefit_reltn_qual,idx2)
    WITH nocounter, nullreport
   ;end select
   CALL echorecord(request)
   SET stat = tdbexecute(4136100,4136101,4136101,"REC",request,
    "REC",reply)
   CALL echorecord(reply)
 ENDFOR
#exit_script
 SET script_ver = " 000 17/12/15 MS035369         Initial Release "
END GO
