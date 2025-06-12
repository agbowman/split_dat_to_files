CREATE PROGRAM acm_provider:dba
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 FREE RECORD acm_request
 RECORD acm_request(
   1 call_echo_ind = i2
   1 use_req_updt_ind = i2
   1 force_updt_ind = i2
   1 person_qual[*]
     2 autopsy_cd = f8
     2 beg_effective_dt_tm = dq8
     2 birth_dt_cd = f8
     2 birth_dt_tm = dq8
     2 cause_of_death = vc
     2 cause_of_death_cd = f8
     2 citizenship_cd = f8
     2 conception_dt_tm = dq8
     2 confid_level_cd = f8
     2 contributor_system_cd = f8
     2 data_status_dt_tm = dq8
     2 deceased_cd = f8
     2 deceased_dt_tm = dq8
     2 deceased_source_cd = f8
     2 end_effective_dt_tm = dq8
     2 ethnic_grp_cd = f8
     2 ft_entity_id = f8
     2 ft_entity_idx = i4
     2 ft_entity_name = vc
     2 language_cd = f8
     2 language_dialect_cd = f8
     2 last_encntr_dt_tm = dq8
     2 marital_type_cd = f8
     2 military_base_location = vc
     2 military_rank_cd = f8
     2 military_service_cd = f8
     2 mother_maiden_name = vc
     2 name_first = vc
     2 name_first_key = vc
     2 name_first_phonetic = vc
     2 name_first_synonym_id = f8
     2 name_first_synonym_idx = i4
     2 name_full_formatted = vc
     2 name_last = vc
     2 name_last_key = vc
     2 name_last_phonetic = vc
     2 name_middle = vc
     2 name_middle_key = vc
     2 name_phonetic = vc
     2 nationality_cd = f8
     2 person_id = f8
     2 person_type_cd = f8
     2 race_cd = f8
     2 religion_cd = f8
     2 sex_age_change_ind = i2
     2 sex_cd = f8
     2 species_cd = f8
     2 vet_military_status_cd = f8
     2 vip_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 birth_tz = i4
     2 abs_birth_dt_tm = dq8
     2 birth_prec_flag = i4
     2 age_at_death = i4
     2 age_at_death_unit_cd = f8
     2 age_at_death_prec_mod_flag = i4
     2 deceased_tz = i4
     2 deceased_dt_tm_prec_flag = i4
   1 person_name_qual[*]
     2 beg_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 end_effective_dt_tm = dq8
     2 name_degree = vc
     2 name_first = vc
     2 name_first_key = vc
     2 name_format_cd = f8
     2 name_full = vc
     2 name_initials = vc
     2 name_last = vc
     2 name_last_key = vc
     2 name_middle = vc
     2 name_middle_key = vc
     2 name_prefix = vc
     2 name_suffix = vc
     2 name_title = vc
     2 name_type_cd = f8
     2 person_id = f8
     2 person_idx = i4
     2 person_name_id = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 source_identifier = vc
     2 name_type_seq = i4
   1 prsnl_qual[*]
     2 beg_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 end_effective_dt_tm = dq8
     2 name_first = vc
     2 name_first_key = vc
     2 name_first_key_nls = vc
     2 name_full_formatted = vc
     2 name_last = vc
     2 name_last_key = vc
     2 name_last_key_nls = vc
     2 person_id = f8
     2 person_idx = i4
     2 position_cd = f8
     2 prsnl_type_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 create_dt_tm = dq8
     2 create_prsnl_id = f8
     2 create_prsnl_idx = i4
     2 department_cd = f8
     2 email = vc
     2 free_text_ind = i2
     2 ft_entity_id = f8
     2 ft_entity_idx = i4
     2 ft_entity_name = vc
     2 log_access_ind = i2
     2 log_level = i4
     2 password = vc
     2 physician_ind = i2
     2 physician_status_cd = f8
     2 prim_assign_loc_cd = f8
     2 section_cd = f8
     2 username = vc
   1 prsnl_alias_qual[*]
     2 alias = vc
     2 alias_pool_cd = f8
     2 beg_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 end_effective_dt_tm = dq8
     2 person_id = f8
     2 person_idx = i4
     2 prsnl_alias_id = f8
     2 prsnl_alias_sub_type_cd = f8
     2 prsnl_alias_type_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
   1 prsnl_org_reltn_type_qual[*]
     2 beg_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 end_effective_dt_tm = dq8
     2 organization_id = f8
     2 organization_idx = i4
     2 org_type_cd = f8
     2 position_cd = f8
     2 prsnl_id = f8
     2 prsnl_idx = i4
     2 prsnl_org_reltn_type_cd = f8
     2 prsnl_org_reltn_type_id = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
     2 role_profile = vc
     2 job_role_cd = f8
     2 access_position_cd = f8
   1 preprocess_qual[*]
     2 prog_name = vc
   1 postprocess_qual[*]
     2 prog_name = vc
   1 prsnl_org_reltn_qual[*]
     2 prsnl_org_reltn_id = f8
     2 person_id = f8
     2 person_idx = i4
     2 organization_id = f8
     2 organization_idx = i4
     2 confid_level_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
   1 prsnl_reltn_qual[*]
     2 prsnl_reltn_id = f8
     2 person_id = f8
     2 person_idx = i4
     2 parent_entity_id = f8
     2 parent_entity_idx = i4
     2 parent_entity_name = vc
     2 display_seq = i4
     2 reltn_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
   1 prsnl_reltn_child_qual[*]
     2 prsnl_reltn_child_id = f8
     2 prsnl_reltn_id = f8
     2 prsnl_reltn_idx = i4
     2 parent_entity_id = f8
     2 parent_entity_idx = i4
     2 parent_entity_name = vc
     2 display_seq = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 action_flag = i2
     2 chg_str = vc
     2 updt_cnt = i4
   1 address_qual[*]
     2 address_format_cd = f8
     2 address_id = f8
     2 address_info_status_cd = f8
     2 address_type_cd = f8
     2 address_type_seq = i4
     2 beg_effective_dt_tm = dq8
     2 city = vc
     2 contact_name = vc
     2 contributor_system_cd = f8
     2 country = vc
     2 country_cd = f8
     2 county = vc
     2 county_cd = f8
     2 end_effective_dt_tm = dq8
     2 mail_stop = vc
     2 operation_hours = vc
     2 parent_entity_id = f8
     2 parent_entity_idx = i4
     2 parent_entity_name = vc
     2 postal_barcode_info = vc
     2 residence_cd = f8
     2 residence_type_cd = f8
     2 state = vc
     2 state_cd = f8
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 zipcode = vc
     2 zip_code_group_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 district_health_cd = f8
     2 primary_care_cd = f8
     2 zipcode_key = vc
     2 comment_txt = vc
     2 source_identifier = vc
     2 postal_identifier = vc
     2 postal_identifier_key = vc
   1 phone_qual[*]
     2 beg_effective_dt_tm = dq8
     2 call_instruction = vc
     2 contact = vc
     2 contributor_system_cd = f8
     2 description = vc
     2 end_effective_dt_tm = dq8
     2 extension = vc
     2 long_text_id = f8
     2 long_text_idx = i4
     2 modem_capability_cd = f8
     2 operation_hours = vc
     2 paging_code = vc
     2 parent_entity_id = f8
     2 parent_entity_idx = i4
     2 parent_entity_name = vc
     2 phone_format_cd = f8
     2 phone_id = f8
     2 phone_num = vc
     2 phone_type_cd = f8
     2 phone_type_seq = i4
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 contact_method_cd = f8
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 source_identifier = vc
     2 phone_num_key = vc
   1 prsnl_prsnl_reltn_qual[*]
     2 beg_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 data_status_prsnl_idx = i4
     2 end_effective_dt_tm = dq8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
     2 organization_id = f8
     2 organization_idx = i4
     2 person_id = f8
     2 person_idx = i4
     2 prsnl_prsnl_reltn_cd = f8
     2 prsnl_prsnl_reltn_id = f8
     2 related_person_id = f8
     2 related_person_idx = i4
 )
 FREE RECORD reply
 RECORD reply(
   1 person_qual_cnt = i4
   1 person_qual[*]
     2 person_id = f8
     2 status = i2
   1 person_name_qual_cnt = i4
   1 person_name_qual[*]
     2 person_name_id = f8
     2 status = i2
   1 prsnl_qual_cnt = i4
   1 prsnl_qual[*]
     2 person_id = f8
     2 status = i2
   1 prsnl_alias_qual_cnt = i4
   1 prsnl_alias_qual[*]
     2 prsnl_alias_id = f8
     2 status = i2
   1 prsnl_org_reltn_type_qual_cnt = i4
   1 prsnl_org_reltn_type_qual[*]
     2 prsnl_org_reltn_type_id = f8
     2 status = i2
   1 debug_cnt = i4
   1 debug[*]
     2 line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 preprocess_qual_cnt = i4
   1 preprocess_qual[*]
     2 status = i2
   1 postprocess_qual_cnt = i4
   1 postprocess_qual[*]
     2 status = i2
   1 prsnl_org_reltn_qual_cnt = i4
   1 prsnl_org_reltn_qual[*]
     2 prsnl_org_reltn_id = f8
     2 status = i2
   1 prsnl_reltn_qual_cnt = i4
   1 prsnl_reltn_qual[*]
     2 prsnl_reltn_id = f8
     2 status = i2
   1 prsnl_reltn_child_qual_cnt = i4
   1 prsnl_reltn_child_qual[*]
     2 prsnl_reltn_child_id = f8
     2 status = i2
   1 address_qual_cnt = i4
   1 address_qual[*]
     2 address_id = f8
     2 status = i2
   1 phone_qual_cnt = i4
   1 phone_qual[*]
     2 phone_id = f8
     2 status = i2
   1 prsnl_prsnl_reltn_qual_cnt = i4
   1 prsnl_prsnl_reltn_qual[*]
     2 prsnl_prsnl_reltn_id = f8
     2 status = i2
 )
 SET reply->status_data.status = "F"
 SET failed = false
 SET table_name = curprog
 DECLARE add_action = i2 WITH protect, constant(1)
 DECLARE chg_action = i2 WITH protect, constant(2)
 DECLARE del_action = i2 WITH protect, constant(3)
 DECLARE act_action = i2 WITH protect, constant(4)
 DECLARE ina_action = i2 WITH protect, constant(5)
 DECLARE qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE acm_hist_ind = i2 WITH constant(0)
 IF (validate(request)=1)
  SET acm_request = request
 ENDIF
 SET call_echo_ind = request->call_echo_ind
 IF (size(acm_request->preprocess_qual,5) > 0)
  FOR (idx1 = 1 TO size(acm_request->preprocess_qual,5))
   EXECUTE value(cnvtupper(acm_request->preprocess_qual[idx1].prog_name)) idx1
   IF ((reply->preprocess_qual[idx1].status=0))
    SET failed = execute_error
    SET table_name = build(table_name,": failed in execute ",cnvtupper(acm_request->preprocess_qual[
      idx1].prog_name)," ",idx1)
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 IF (size(acm_request->person_qual,5) > 0)
  EXECUTE acm_write_person
  IF ((reply->status_data.status != "S"))
   SET failed = execute_error
   SET table_name = build(table_name,": failed in execute acm_write_person")
   GO TO exit_script
  ENDIF
 ENDIF
 SET qual_cnt = size(acm_request->person_name_qual,5)
 IF (qual_cnt > 0)
  FOR (idx1 = 1 TO qual_cnt)
    IF ((acm_request->person_name_qual[idx1].person_idx > 0))
     SET acm_request->person_name_qual[idx1].person_id = acm_request->person_qual[acm_request->
     person_name_qual[idx1].person_idx].person_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_person_name
  IF ((reply->status_data.status != "S"))
   SET failed = execute_error
   SET table_name = build(table_name,": failed in execute acm_write_person_name")
   GO TO exit_script
  ENDIF
 ENDIF
 SET qual_cnt = size(acm_request->prsnl_qual,5)
 IF (qual_cnt > 0)
  FOR (idx1 = 1 TO qual_cnt)
    IF ((acm_request->prsnl_qual[idx1].person_idx > 0))
     SET acm_request->prsnl_qual[idx1].person_id = acm_request->person_qual[acm_request->prsnl_qual[
     idx1].person_idx].person_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_prsnl
  IF ((reply->status_data.status != "S"))
   SET failed = execute_error
   SET table_name = build(table_name,": failed in execute acm_write_prsnl")
   GO TO exit_script
  ENDIF
 ENDIF
 SET qual_cnt = size(acm_request->prsnl_alias_qual,5)
 IF (qual_cnt > 0)
  FOR (idx1 = 1 TO qual_cnt)
    IF ((acm_request->prsnl_alias_qual[idx1].person_idx > 0))
     SET acm_request->prsnl_alias_qual[idx1].person_id = acm_request->person_qual[acm_request->
     prsnl_alias_qual[idx1].person_idx].person_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_prsnl_alias
  IF ((reply->status_data.status != "S"))
   SET failed = execute_error
   SET table_name = build(table_name,": failed in execute acm_write_prsnl_alias")
   GO TO exit_script
  ENDIF
 ENDIF
 SET qual_cnt = size(acm_request->prsnl_org_reltn_type_qual,5)
 IF (qual_cnt > 0)
  FOR (idx1 = 1 TO qual_cnt)
    IF ((acm_request->prsnl_org_reltn_type_qual[idx1].prsnl_idx > 0))
     SET acm_request->prsnl_org_reltn_type_qual[idx1].prsnl_id = acm_request->prsnl_qual[acm_request
     ->prsnl_org_reltn_type_qual[idx1].prsnl_idx].person_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_prsnl_org_reltn_type
  IF ((reply->status_data.status != "S"))
   SET failed = execute_error
   SET table_name = build(table_name,": failed in execute acm_write_prsnl_org_reltn_type")
   GO TO exit_script
  ENDIF
 ENDIF
 SET qual_cnt = size(acm_request->prsnl_org_reltn_qual,5)
 IF (qual_cnt > 0)
  FOR (idx1 = 1 TO qual_cnt)
    IF ((acm_request->prsnl_org_reltn_qual[idx1].person_idx > 0))
     SET acm_request->prsnl_org_reltn_qual[idx1].person_id = acm_request->prsnl_qual[acm_request->
     prsnl_org_reltn_qual[idx1].person_idx].person_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_prsnl_org_reltn
  IF ((reply->status_data.status != "S"))
   SET failed = execute_error
   SET table_name = build(table_name,": failed in execute acm_write_prsnl_org_reltn")
   GO TO exit_script
  ENDIF
 ENDIF
 SET qual_cnt = size(acm_request->address_qual,5)
 IF (qual_cnt > 0)
  FOR (idx1 = 1 TO qual_cnt)
    IF ((acm_request->address_qual[idx1].parent_entity_idx > 0)
     AND (acm_request->address_qual[idx1].parent_entity_name="PERSON"))
     SET acm_request->address_qual[idx1].parent_entity_id = acm_request->person_qual[acm_request->
     address_qual[idx1].parent_entity_idx].person_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_address
  IF ((reply->status_data.status != "S"))
   SET failed = execute_error
   SET table_name = build(table_name,": failed in execute acm_write_address")
   GO TO exit_script
  ENDIF
 ENDIF
 SET qual_cnt = size(acm_request->phone_qual,5)
 IF (qual_cnt > 0)
  FOR (idx1 = 1 TO qual_cnt)
    IF ((acm_request->phone_qual[idx1].parent_entity_idx > 0)
     AND (acm_request->phone_qual[idx1].parent_entity_name="PERSON"))
     SET acm_request->phone_qual[idx1].parent_entity_id = acm_request->person_qual[acm_request->
     phone_qual[idx1].parent_entity_idx].person_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_phone
  IF ((reply->status_data.status != "S"))
   SET failed = execute_error
   SET table_name = build(table_name,": failed in execute acm_write_phone")
   GO TO exit_script
  ENDIF
 ENDIF
 SET qual_cnt = size(acm_request->prsnl_reltn_qual,5)
 IF (qual_cnt > 0)
  FOR (idx1 = 1 TO qual_cnt)
    IF ((acm_request->prsnl_reltn_qual[idx1].person_idx > 0))
     SET acm_request->prsnl_reltn_qual[idx1].person_id = acm_request->prsnl_qual[acm_request->
     prsnl_reltn_qual[idx1].person_idx].person_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_prsnl_reltn
  IF ((reply->status_data.status != "S"))
   SET failed = execute_error
   SET table_name = build(table_name,": failed in execute acm_write_prsnl_reltn")
   GO TO exit_script
  ENDIF
 ENDIF
 SET qual_cnt = size(acm_request->prsnl_reltn_child_qual,5)
 IF (qual_cnt > 0)
  FOR (idx1 = 1 TO qual_cnt)
   IF ((acm_request->prsnl_reltn_child_qual[idx1].prsnl_reltn_idx > 0))
    SET acm_request->prsnl_reltn_child_qual[idx1].prsnl_reltn_id = acm_request->prsnl_reltn_qual[
    acm_request->prsnl_reltn_child_qual[idx1].prsnl_reltn_idx].prsnl_reltn_id
   ENDIF
   IF ((acm_request->prsnl_reltn_child_qual[idx1].parent_entity_idx > 0))
    IF ((acm_request->prsnl_reltn_child_qual[idx1].parent_entity_name="PRSNL_ALIAS"))
     SET acm_request->prsnl_reltn_child_qual[idx1].parent_entity_id = acm_request->prsnl_alias_qual[
     acm_request->prsnl_reltn_child_qual[idx1].parent_entity_idx].prsnl_alias_id
    ELSEIF ((acm_request->prsnl_reltn_child_qual[idx1].parent_entity_name="ADDRESS"))
     SET acm_request->prsnl_reltn_child_qual[idx1].parent_entity_id = acm_request->address_qual[
     acm_request->prsnl_reltn_child_qual[idx1].parent_entity_idx].address_id
    ELSEIF ((acm_request->prsnl_reltn_child_qual[idx1].parent_entity_name="PHONE"))
     SET acm_request->prsnl_reltn_child_qual[idx1].parent_entity_id = acm_request->phone_qual[
     acm_request->prsnl_reltn_child_qual[idx1].parent_entity_idx].phone_id
    ENDIF
   ENDIF
  ENDFOR
  EXECUTE acm_write_prsnl_reltn_child
  IF ((reply->status_data.status != "S"))
   SET failed = execute_error
   SET table_name = build(table_name,": failed in execute acm_write_prsnl_reltn_child")
   GO TO exit_script
  ENDIF
 ENDIF
 SET qual_cnt = size(acm_request->prsnl_prsnl_reltn_qual,5)
 IF (qual_cnt > 0)
  FOR (idx1 = 1 TO qual_cnt)
    IF ((acm_request->prsnl_prsnl_reltn_qual[idx1].person_idx > 0))
     SET acm_request->prsnl_prsnl_reltn_qual[idx1].person_id = acm_request->prsnl_qual[acm_request->
     prsnl_prsnl_reltn_qual[idx1].person_idx].person_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_prsnl_prsnl_reltn
  IF ((reply->status_data.status != "S"))
   SET failed = execute_error
   SET table_name = build(table_name,": failed in execute acm_write_prsnl_prsnl_reltn")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (size(acm_request->postprocess_qual,5) > 0)
  FOR (idx1 = 1 TO size(acm_request->postprocess_qual,5))
   EXECUTE value(cnvtupper(acm_request->postprocess_qual[idx1].prog_name)) idx1
   IF ((reply->postprocess_qual[idx1].status=0))
    SET failed = execute_error
    SET table_name = build(table_name,": failed in execute ",cnvtupper(acm_request->postprocess_qual[
      idx1].prog_name)," ",idx1)
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (call_echo_ind)
  CALL echorecord(acm_request)
  CALL echorecord(reply)
 ENDIF
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = true
 ELSE
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    DECLARE s_next_subeventstatus(s_null=i4) = i4
    DECLARE s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) = i4
    DECLARE s_add_subeventstatus_cclerr(s_null=i4) = i4
    DECLARE s_log_subeventstatus(s_null=i4) = i4
    DECLARE s_clear_subeventstatus(s_null=i4) = i4
    SUBROUTINE s_next_subeventstatus(s_null)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 = (stx1+ 1)
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus(s_oname,s_ostatus,s_tname,s_tvalue)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus_cclerr(s_null)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE s_log_subeventstatus(s_null)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE s_clear_subeventstatus(s_null)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    DECLARE s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) = i2
    SUBROUTINE s_sch_msgview(t_event,t_message,t_log_level)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
END GO
