CREATE PROGRAM acm_registration:dba
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
 IF ((validate(run_acm_entity_updt,- (999))=- (999)))
  DECLARE run_acm_entity_updt = i2 WITH noconstant(1)
  DECLARE s_lacm_chg_entity_updt_status = i2 WITH noconstant(false)
  DECLARE s_entity_curprog = vc WITH protected, noconstant(curprog)
  RECORD acm_chg_entity_updt_request(
    1 call_echo_ind = i2
    1 curprog = vc
    1 entity_type_cnt = i4
    1 entity_type_qual[*]
      2 entity_type = vc
      2 entity_id_cnt = i4
      2 entity_id_qual[*]
        3 entity_id = f8
  )
  RECORD acm_chg_entity_updt_reply(
    1 entity_type_cnt = i4
    1 entity_type_qual[*]
      2 entity_type = vc
      2 entity_id_cnt = i4
      2 entity_id_qual[*]
        3 entity_id = f8
        3 status = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  RECORD entityprimarykeys(
    1 primarykeylistsize = i4
    1 primarykeycurrentsize = i4
    1 ids_qual[*]
      2 primary_key_id = f8
  )
 ELSEIF (run_acm_entity_updt=0)
  SET run_acm_entity_updt = 1
  SET stat = alterlist(acm_chg_entity_updt_request->entity_type_qual,0)
  SET acm_chg_entity_updt_request->entity_type_cnt = 0
  SET s_entity_curprog = curprog
 ENDIF
 DECLARE s_executeentityupdates(_null) = i2
 DECLARE s_getprimarylistsize(_null) = i4
 DECLARE s_clearall(_null) = i2
 DECLARE s_clearprimarykeys(_null) = i2
 DECLARE s_getdeclaringprog(_null) = vc
 SUBROUTINE (s_requestaddtoprimarykeyslist(dprimarykeyid=f8) =i2)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE s_getprimarylistsize(_null)
   RETURN(entityprimarykeys->primarykeylistsize)
 END ;Subroutine
 SUBROUTINE s_clearprimarykeys(_null)
   SET stat = alterlist(entityprimarykeys->ids_qual,0)
   SET entityprimarykeys->primarykeylistsize = 0
   SET entityprimarykeys->primarykeycurrentsize = 0
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (s_requestaddtolist(dentityid=f8,sentitytype=vc) =i2)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE s_executeentityupdates(_null)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (s_getrequestlistsize(sentitytype=vc) =i4)
   SET sentitytype = cnvtupper(sentitytype)
   DECLARE s_idx = i4 WITH protect, noconstant(0)
   FOR (s_idx = 1 TO acm_chg_entity_updt_request->entity_type_cnt)
     IF ((sentitytype=acm_chg_entity_updt_request->entity_type_qual[s_idx].entity_type))
      RETURN(acm_chg_entity_updt_request->entity_type_qual[s_idx].entity_id_cnt)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE s_clearall(_null)
   FREE RECORD entityprimarykeys
   FREE RECORD acm_chg_entity_updt_request
   FREE RECORD acm_chg_entity_updt_reply
   SET s_lacm_chg_entity_updt_status = 0
   RETURN(true)
 END ;Subroutine
 SUBROUTINE s_getdeclaringprog(_null)
   RETURN(s_entity_curprog)
 END ;Subroutine
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 transaction_info_qual_cnt = i4
    1 transaction_info_qual[*]
      2 transaction_id = f8
      2 pm_hist_tracking_id = f8
      2 person_id = f8
      2 person_idx = i4
      2 encntr_id = f8
      2 encntr_idx = i4
      2 status = i2
    1 address_qual_cnt = i4
    1 address_qual[*]
      2 address_id = f8
      2 status = i2
    1 encntr_alias_qual_cnt = i4
    1 encntr_alias_qual[*]
      2 encntr_alias_id = f8
      2 status = i2
    1 encntr_code_value_r_qual_cnt = i4
    1 encntr_code_value_r_qual[*]
      2 encntr_code_value_r_id = f8
      2 status = i2
    1 encntr_domain_qual_cnt = i4
    1 encntr_domain_qual[*]
      2 encntr_domain_id = f8
      2 status = i2
    1 encntr_financial_qual_cnt = i4
    1 encntr_financial_qual[*]
      2 encntr_financial_id = f8
      2 status = i2
    1 encntr_info_qual_cnt = i4
    1 encntr_info_qual[*]
      2 encntr_info_id = f8
      2 status = i2
    1 encntr_loc_hist_qual_cnt = i4
    1 encntr_loc_hist_qual[*]
      2 encntr_loc_hist_id = f8
      2 status = i2
    1 encntr_org_reltn_qual_cnt = i4
    1 encntr_org_reltn_qual[*]
      2 encntr_org_reltn_id = f8
      2 status = i2
    1 encntr_person_reltn_qual_cnt = i4
    1 encntr_person_reltn_qual[*]
      2 encntr_person_reltn_id = f8
      2 status = i2
    1 encntr_plan_reltn_qual_cnt = i4
    1 encntr_plan_reltn_qual[*]
      2 encntr_plan_reltn_id = f8
      2 status = i2
    1 encntr_prsnl_reltn_qual_cnt = i4
    1 encntr_prsnl_reltn_qual[*]
      2 encntr_prsnl_reltn_id = f8
      2 status = i2
    1 encounter_qual_cnt = i4
    1 encounter_qual[*]
      2 encntr_id = f8
      2 status = i2
    1 health_plan_qual_cnt = i4
    1 health_plan_qual[*]
      2 health_plan_id = f8
      2 status = i2
    1 person_qual_cnt = i4
    1 person_qual[*]
      2 person_id = f8
      2 status = i2
    1 person_alias_qual_cnt = i4
    1 person_alias_qual[*]
      2 person_alias_id = f8
      2 status = i2
    1 person_code_value_r_qual_cnt = i4
    1 person_code_value_r_qual[*]
      2 person_code_value_r_id = f8
      2 status = i2
    1 person_name_qual_cnt = i4
    1 person_name_qual[*]
      2 person_name_id = f8
      2 status = i2
    1 person_org_reltn_qual_cnt = i4
    1 person_org_reltn_qual[*]
      2 person_org_reltn_id = f8
      2 status = i2
    1 person_patient_qual_cnt = i4
    1 person_patient_qual[*]
      2 person_id = f8
      2 status = i2
    1 person_person_reltn_qual_cnt = i4
    1 person_person_reltn_qual[*]
      2 person_person_reltn_id = f8
      2 status = i2
    1 person_plan_reltn_qual_cnt = i4
    1 person_plan_reltn_qual[*]
      2 person_plan_reltn_id = f8
      2 status = i2
    1 person_prsnl_reltn_qual_cnt = i4
    1 person_prsnl_reltn_qual[*]
      2 person_prsnl_reltn_id = f8
      2 status = i2
    1 phone_qual_cnt = i4
    1 phone_qual[*]
      2 phone_id = f8
      2 status = i2
    1 service_category_hist_qual_cnt = i4
    1 service_category_hist_qual[*]
      2 svc_cat_hist_id = f8
      2 status = i2
    1 preprocess_qual_cnt = i4
    1 preprocess_qual[*]
      2 status = i2
    1 postprocess_qual_cnt = i4
    1 postprocess_qual[*]
      2 status = i2
    1 p_rx_plan_coverage_qual_cnt = i4
    1 person_rx_plan_coverage_qual[*]
      2 person_rx_plan_coverage_id = f8
      2 status = i2
    1 p_rx_plan_reltn_qual_cnt = i4
    1 person_rx_plan_reltn_qual[*]
      2 person_rx_plan_reltn_id = f8
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
    1 error_info[1]
      2 line1 = vc
      2 line2 = vc
      2 line3 = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE add_action = i2 WITH constant(1)
 DECLARE chg_action = i2 WITH constant(2)
 DECLARE del_action = i2 WITH constant(3)
 DECLARE act_action = i2 WITH constant(4)
 DECLARE ina_action = i2 WITH constant(5)
 DECLARE qual_cnt = i4 WITH noconstant(0)
 DECLARE acm_hist_ind = i2 WITH noconstant(0)
 DECLARE history_cd = f8 WITH protect, constant(loadcodevalue(20790,"HISTORY",0))
 DECLARE var_i = i4 WITH noconstant(0)
 DECLARE person_idx = i4 WITH noconstant(0)
 DECLARE person_id = f8 WITH noconstant(0), protect
 DECLARE t1 = i4 WITH noconstant(0), protect
 DECLARE t2 = i4 WITH noconstant(0), protect
 DECLARE max_val = i4 WITH noconstant(200), protect
 DECLARE t_val = i4 WITH noconstant(1), protect
 DECLARE f_val = i4 WITH noconstant(1), protect
 DECLARE encntr_idx = i4 WITH noconstant(0)
 DECLARE encntr_id = f8 WITH noconstant(0), protect
 DECLARE nbr = i4 WITH noconstant(0), protect
 DECLARE reply_str = c130 WITH noconstant("")
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE xref_idx = i4 WITH protect, noconstant(0)
 DECLARE ft_count = i4 WITH protect, noconstant(0)
 DECLARE tbl = vc WITH protect, noconstant("")
 DECLARE old_use_req_updt_ind = i2 WITH protect, noconstant(0)
 DECLARE sx_beg = i4 WITH protect, noconstant(1)
 DECLARE sx_pad_tot = i4 WITH protect, noconstant(0)
 DECLARE sx_slice = i4 WITH protect, noconstant(20)
 DECLARE changed_entity_map(mode=vc,mapkey=f8,mapval=vc) = i4 WITH map = "HASH"
 DECLARE changed_entity_map_cnt = i4 WITH protect, noconstant(0)
 DECLARE changed_entity_map_key = f8 WITH protect, noconstant(0.0)
 DECLARE changed_entity_map_value = vc WITH protect, noconstant("")
 DECLARE changed_person_map(mode=vc,mapkey=f8,mapval=vc) = i4 WITH map = "HASH"
 DECLARE changed_person_map_cnt = i4 WITH protect, noconstant(0)
 DECLARE changed_person_map_key = f8 WITH protect, noconstant(0.0)
 DECLARE changed_person_map_value = vc WITH protect, noconstant("")
 SET error_str0 = "ERROR: request->"
 SET error_str1 = "does not "
 SET error_str2 = "have a pointer to the "
 SET error_str3 = " must not be 0 "
 SET encntr_str = " encntr_id in encounter_qual"
 SET person_str = " person_id in person_qual"
 SET req_str = "request->"
 SET qual_name = "acm_service_category_hist_qual_cnt"
 SET call_echo_ind = request->call_echo_ind
 IF (curcclver >= 81206)
  SET modify = recmemberset
 ELSE
  CALL echo("Setting recmemberset unavailable on CCL 8.12.5 or older")
 ENDIF
 IF (validate(request,"-1") != "-1")
  SET stat = copyrec(request,acm_request,1)
 ENDIF
 SET reply->preprocess_qual_cnt = size(acm_request->preprocess_qual,5)
 SET reply->address_qual_cnt = size(acm_request->address_qual,5)
 SET reply->encntr_alias_qual_cnt = size(acm_request->encntr_alias_qual,5)
 SET reply->person_qual_cnt = size(acm_request->person_qual,5)
 SET reply->encntr_code_value_r_qual_cnt = size(acm_request->encntr_code_value_r_qual,5)
 SET reply->encntr_domain_qual_cnt = size(acm_request->encntr_domain_qual,5)
 SET reply->encntr_financial_qual_cnt = size(acm_request->encntr_financial_qual,5)
 SET reply->encntr_info_qual_cnt = size(acm_request->encntr_info_qual,5)
 SET reply->encntr_loc_hist_qual_cnt = size(acm_request->encntr_loc_hist_qual,5)
 SET reply->encntr_org_reltn_qual_cnt = size(acm_request->encntr_org_reltn_qual,5)
 SET reply->encntr_person_reltn_qual_cnt = size(acm_request->encntr_person_reltn_qual,5)
 SET reply->encntr_plan_reltn_qual_cnt = size(acm_request->encntr_plan_reltn_qual,5)
 SET reply->encntr_prsnl_reltn_qual_cnt = size(acm_request->encntr_prsnl_reltn_qual,5)
 SET reply->encounter_qual_cnt = size(acm_request->encounter_qual,5)
 SET reply->health_plan_qual_cnt = size(acm_request->health_plan_qual,5)
 SET reply->person_name_qual_cnt = size(acm_request->person_name_qual,5)
 SET reply->phone_qual_cnt = size(acm_request->phone_qual,5)
 SET reply->person_org_reltn_qual_cnt = size(acm_request->person_org_reltn_qual,5)
 SET reply->person_code_value_r_qual_cnt = size(acm_request->person_code_value_r_qual,5)
 SET reply->person_plan_reltn_qual_cnt = size(acm_request->person_plan_reltn_qual,5)
 SET reply->person_patient_qual_cnt = size(acm_request->person_patient_qual,5)
 SET reply->person_prsnl_reltn_qual_cnt = size(acm_request->person_prsnl_reltn_qual,5)
 SET reply->person_alias_qual_cnt = size(acm_request->person_alias_qual,5)
 SET reply->transaction_info_qual_cnt = size(acm_request->transaction_info_qual,5)
 SET reply->person_person_reltn_qual_cnt = size(acm_request->person_person_reltn_qual,5)
 SET reply->service_category_hist_qual_cnt = size(acm_request->service_category_hist_qual,5)
 SET reply->p_rx_plan_coverage_qual_cnt = size(acm_request->person_rx_plan_coverage_qual,5)
 SET reply->p_rx_plan_reltn_qual_cnt = size(acm_request->person_rx_plan_reltn_qual,5)
 SELECT INTO "nl:"
  FROM code_value_extension cve
  WHERE cve.code_value=history_cd
   AND cve.field_name="OPTION"
   AND cve.code_set=20790
  DETAIL
   IF (trim(cve.field_value,3)="1")
    acm_hist_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->person_qual_cnt=0)
  AND acm_hist_ind=1)
  SET reply->error_info.line1 = "ERROR: person_qual is empty"
  GO TO exit_script
 ELSEIF ((reply->transaction_info_qual_cnt=0)
  AND acm_hist_ind=1)
  SET reply->error_info.line1 = "ERROR: transaction_info_qual is empty"
  GO TO exit_script
 ENDIF
 IF ((reply->preprocess_qual_cnt > 0))
  CALL alterlist(reply->preprocess_qual,reply->preprocess_qual_cnt)
  FOR (preproc_i = 1 TO reply->preprocess_qual_cnt)
    SET reply->status_data.status = "F"
    EXECUTE value(acm_request->preprocess_qual[preproc_i].prog_name) preproc_i
    IF ((reply->status_data.status != "S"))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 CALL alterlist(reply->transaction_info_qual,reply->transaction_info_qual_cnt)
 SET qual_name = "transaction_info_qual"
 FOR (index = 1 TO reply->transaction_info_qual_cnt)
   FREE RECORD pm_ens_transaction_req
   RECORD pm_ens_transaction_req(
     1 pm_hist_tracking_id = f8
     1 transaction_id = f8
     1 transaction = vc
     1 transaction_dt_tm = dq8
     1 hl7_event = vc
     1 person_id = f8
     1 encntr_id = f8
     1 contributor_system_cd = f8
     1 transaction_reason = vc
     1 transaction_reason_cd = f8
     1 task_number = i4
     1 trans
       2 transaction_id = f8
       2 activity_dt_tm = dq8
       2 transaction = c4
       2 n_person_id = f8
       2 o_person_id = f8
       2 n_encntr_id = f8
       2 o_encntr_id = f8
       2 n_encntr_fin_id = f8
       2 o_encntr_fin_id = f8
       2 n_mrn = c20
       2 o_mrn = c20
       2 n_fin_nbr = c20
       2 o_fin_nbr = c20
       2 n_name_last = c20
       2 o_name_last = c20
       2 n_name_first = c20
       2 o_name_first = c20
       2 n_name_middle = c20
       2 o_name_middle = c20
       2 n_name_formatted = c30
       2 o_name_formatted = c30
       2 n_birth_dt_cd = f8
       2 o_birth_dt_cd = f8
       2 n_birth_dt_tm = dq8
       2 o_birth_dt_tm = dq8
       2 n_person_sex_cd = f8
       2 o_person_sex_cd = f8
       2 n_ssn = c15
       2 o_ssn = c15
       2 n_person_type_cd = f8
       2 o_person_type_cd = f8
       2 n_autopsy_cd = f8
       2 o_autopsy_cd = f8
       2 n_conception_dt_tm = dq8
       2 o_conception_dt_tm = dq8
       2 n_cause_of_death = c40
       2 o_cause_of_death = c40
       2 n_deceased_cd = f8
       2 o_deceased_cd = f8
       2 n_deceased_dt_tm = dq8
       2 o_deceased_dt_tm = dq8
       2 n_ethnic_grp_cd = f8
       2 o_ethnic_grp_cd = f8
       2 n_language_cd = f8
       2 o_language_cd = f8
       2 n_marital_type_cd = f8
       2 o_marital_type_cd = f8
       2 n_race_cd = f8
       2 o_race_cd = f8
       2 n_religion_cd = f8
       2 o_religion_cd = f8
       2 n_sex_age_chg_ind_ind = i2
       2 n_sex_age_chg_ind = i2
       2 o_sex_age_chg_ind_ind = i2
       2 o_sex_age_chg_ind = i2
       2 n_lang_dialect_cd = f8
       2 o_lang_dialect_cd = f8
       2 n_species_cd = f8
       2 o_species_cd = f8
       2 n_confid_level_cd = f8
       2 o_confid_level_cd = f8
       2 n_person_vip_cd = f8
       2 o_person_vip_cd = f8
       2 n_citizenship_cd = f8
       2 o_citizenship_cd = f8
       2 n_vet_mil_stat_cd = f8
       2 o_vet_mil_stat_cd = f8
       2 n_mthr_maid_name = c20
       2 o_mthr_maid_name = c20
       2 n_nationality_cd = f8
       2 o_nationality_cd = f8
       2 n_encntr_class_cd = f8
       2 o_encntr_class_cd = f8
       2 n_encntr_type_cd = f8
       2 o_encntr_type_cd = f8
       2 n_encntr_type_class_cd = f8
       2 o_encntr_type_class_cd = f8
       2 n_encntr_status_cd = f8
       2 o_encntr_status_cd = f8
       2 n_pre_reg_dt_tm = dq8
       2 o_pre_reg_dt_tm = dq8
       2 n_pre_reg_prsnl_id = f8
       2 o_pre_reg_prsnl_id = f8
       2 n_reg_dt_tm = dq8
       2 o_reg_dt_tm = dq8
       2 n_reg_prsnl_id = f8
       2 o_reg_prsnl_id = f8
       2 n_est_arrive_dt_tm = dq8
       2 o_est_arrive_dt_tm = dq8
       2 n_est_depart_dt_tm = dq8
       2 o_est_depart_dt_tm = dq8
       2 n_arrive_dt_tm = dq8
       2 o_arrive_dt_tm = dq8
       2 n_depart_dt_tm = dq8
       2 o_depart_dt_tm = dq8
       2 n_admit_type_cd = f8
       2 o_admit_type_cd = f8
       2 n_admit_src_cd = f8
       2 o_admit_src_cd = f8
       2 n_admit_mode_cd = f8
       2 o_admit_mode_cd = f8
       2 n_admit_with_med_cd = f8
       2 o_admit_with_med_cd = f8
       2 n_refer_comment = c40
       2 o_refer_comment = c40
       2 n_disch_disp_cd = f8
       2 o_disch_disp_cd = f8
       2 n_disch_to_loctn_cd = f8
       2 o_disch_to_loctn_cd = f8
       2 n_preadmit_nbr = c20
       2 o_preadmit_nbr = c20
       2 n_preadmit_test_cd = f8
       2 o_preadmit_test_cd = f8
       2 n_readmit_cd = f8
       2 o_readmit_cd = f8
       2 n_accom_cd = f8
       2 o_accom_cd = f8
       2 n_accom_req_cd = f8
       2 o_accom_req_cd = f8
       2 n_alt_result_dest_cd = f8
       2 o_alt_result_dest_cd = f8
       2 n_amb_cond_cd = f8
       2 o_amb_cond_cd = f8
       2 n_courtesy_cd = f8
       2 o_courtesy_cd = f8
       2 n_diet_type_cd = f8
       2 o_diet_type_cd = f8
       2 n_isolation_cd = f8
       2 o_isolation_cd = f8
       2 n_med_service_cd = f8
       2 o_med_service_cd = f8
       2 n_result_dest_cd = f8
       2 o_result_dest_cd = f8
       2 n_encntr_vip_cd = f8
       2 o_encntr_vip_cd = f8
       2 n_encntr_sex_cd = f8
       2 o_encntr_sex_cd = f8
       2 n_disch_dt_tm = dq8
       2 o_disch_dt_tm = dq8
       2 n_guar_type_cd = f8
       2 o_guar_type_cd = f8
       2 n_loc_temp_cd = f8
       2 o_loc_temp_cd = f8
       2 n_reason_for_visit = c40
       2 o_reason_for_visit = c40
       2 n_fin_class_cd = f8
       2 o_fin_class_cd = f8
       2 n_location_cd = f8
       2 o_location_cd = f8
       2 n_loc_facility_cd = f8
       2 o_loc_facility_cd = f8
       2 n_loc_building_cd = f8
       2 o_loc_building_cd = f8
       2 n_loc_nurse_unit_cd = f8
       2 o_loc_nurse_unit_cd = f8
       2 n_loc_room_cd = f8
       2 o_loc_room_cd = f8
       2 n_loc_bed_cd = f8
       2 o_loc_bed_cd = f8
       2 n_admit_doc_name = c30
       2 o_admit_doc_name = c30
       2 n_admit_doc_id = f8
       2 o_admit_doc_id = f8
       2 n_attend_doc_name = c30
       2 o_attend_doc_name = c30
       2 n_attend_doc_id = f8
       2 o_attend_doc_id = f8
       2 n_consult_doc_name = c30
       2 o_consult_doc_name = c30
       2 n_consult_doc_id = f8
       2 o_consult_doc_id = f8
       2 n_refer_doc_name = c30
       2 o_refer_doc_name = c30
       2 n_refer_doc_id = f8
       2 o_refer_doc_id = f8
       2 n_admit_doc_nbr = c16
       2 o_admit_doc_nbr = c16
       2 n_attend_doc_nbr = c16
       2 o_attend_doc_nbr = c16
       2 n_consult_doc_nbr = c16
       2 o_consult_doc_nbr = c16
       2 n_refer_doc_nbr = c16
       2 o_refer_doc_nbr = c16
       2 n_per_home_address_id = f8
       2 o_per_home_address_id = f8
       2 n_per_home_addr_street = c100
       2 o_per_home_addr_street = c100
       2 n_per_home_addr_city = c40
       2 o_per_home_addr_city = c40
       2 n_per_home_addr_state = c20
       2 o_per_home_addr_state = c20
       2 n_per_home_addr_zipcode = c20
       2 o_per_home_addr_zipcode = c20
       2 n_per_bus_address_id = f8
       2 o_per_bus_address_id = f8
       2 n_per_bus_addr_street = c100
       2 o_per_bus_addr_street = c100
       2 n_per_bus_addr_city = c40
       2 o_per_bus_addr_city = c40
       2 n_per_bus_addr_state = c20
       2 o_per_bus_addr_state = c20
       2 n_per_bus_addr_zipcode = c20
       2 o_per_bus_addr_zipcode = c20
       2 n_per_home_phone_id = f8
       2 o_per_home_phone_id = f8
       2 n_per_home_ph_format_cd = f8
       2 o_per_home_ph_format_cd = f8
       2 n_per_home_ph_number = c20
       2 o_per_home_ph_number = c20
       2 n_per_home_ext = c10
       2 o_per_home_ext = c10
       2 n_per_bus_phone_id = f8
       2 o_per_bus_phone_id = f8
       2 n_per_bus_ph_format_cd = f8
       2 o_per_bus_ph_format_cd = f8
       2 n_per_bus_ph_number = c20
       2 o_per_bus_ph_number = c20
       2 n_per_bus_ext = c10
       2 o_per_bus_ext = c10
       2 n_per_home_addr_street2 = c100
       2 o_per_home_addr_street2 = c100
       2 n_per_bus_addr_street2 = c100
       2 o_per_bus_addr_street2 = c100
       2 n_per_home_addr_county = c20
       2 o_per_home_addr_county = c20
       2 n_per_home_addr_country = c20
       2 o_per_home_addr_country = c20
       2 n_per_bus_addr_county = c20
       2 o_per_bus_addr_county = c20
       2 n_per_bus_addr_country = c20
       2 o_per_bus_addr_country = c20
       2 n_encntr_complete_dt_tm = dq8
       2 o_encntr_complete_dt_tm = dq8
       2 n_organization_id = f8
       2 o_organization_id = f8
       2 n_contributor_system_cd = f8
       2 o_contributor_system_cd = f8
       2 hl7_event = c10
       2 n_assign_to_loc_dt_tm = dq8
       2 o_assign_to_loc_dt_tm = dq8
       2 n_alt_lvl_care_cd = f8
       2 o_alt_lvl_care_cd = f8
       2 n_program_service_cd = f8
       2 o_program_service_cd = f8
       2 n_specialty_unit_cd = f8
       2 o_specialty_unit_cd = f8
       2 n_birth_tz = i4
       2 o_birth_tz = i4
       2 abs_n_birth_dt_tm = dq8
       2 abs_o_birth_dt_tm = dq8
       2 n_service_category_cd = f8
       2 o_service_category_cd = f8
   )
   FREE RECORD pm_ens_transaction_rep
   RECORD pm_ens_transaction_rep(
     1 trans
       2 transaction_id = f8
       2 pm_hist_tracking_id = f8
       2 activity_dt_tm = dq8
       2 transaction_dt_tm = dq8
       2 transaction = c4
       2 n_person_id = f8
       2 o_person_id = f8
       2 n_encntr_id = f8
       2 o_encntr_id = f8
       2 n_encntr_fin_id = f8
       2 o_encntr_fin_id = f8
       2 n_mrn = c20
       2 o_mrn = c20
       2 n_fin_nbr = c20
       2 o_fin_nbr = c20
       2 n_name_last = c20
       2 o_name_last = c20
       2 n_name_first = c20
       2 o_name_first = c20
       2 n_name_middle = c20
       2 o_name_middle = c20
       2 n_name_formatted = c30
       2 o_name_formatted = c30
       2 n_birth_dt_cd = f8
       2 o_birth_dt_cd = f8
       2 n_birth_dt_tm = dq8
       2 o_birth_dt_tm = dq8
       2 n_person_sex_cd = f8
       2 o_person_sex_cd = f8
       2 n_ssn = c15
       2 o_ssn = c15
       2 n_person_type_cd = f8
       2 o_person_type_cd = f8
       2 n_autopsy_cd = f8
       2 o_autopsy_cd = f8
       2 n_conception_dt_tm = dq8
       2 o_conception_dt_tm = dq8
       2 n_cause_of_death = c40
       2 o_cause_of_death = c40
       2 n_deceased_cd = f8
       2 o_deceased_cd = f8
       2 n_deceased_dt_tm = dq8
       2 o_deceased_dt_tm = dq8
       2 n_ethnic_grp_cd = f8
       2 o_ethnic_grp_cd = f8
       2 n_language_cd = f8
       2 o_language_cd = f8
       2 n_marital_type_cd = f8
       2 o_marital_type_cd = f8
       2 n_race_cd = f8
       2 o_race_cd = f8
       2 n_religion_cd = f8
       2 o_religion_cd = f8
       2 n_sex_age_chg_ind_ind = i2
       2 n_sex_age_chg_ind = i2
       2 o_sex_age_chg_ind_ind = i2
       2 o_sex_age_chg_ind = i2
       2 n_lang_dialect_cd = f8
       2 o_lang_dialect_cd = f8
       2 n_species_cd = f8
       2 o_species_cd = f8
       2 n_confid_level_cd = f8
       2 o_confid_level_cd = f8
       2 n_person_vip_cd = f8
       2 o_person_vip_cd = f8
       2 n_citizenship_cd = f8
       2 o_citizenship_cd = f8
       2 n_vet_mil_stat_cd = f8
       2 o_vet_mil_stat_cd = f8
       2 n_mthr_maid_name = c20
       2 o_mthr_maid_name = c20
       2 n_nationality_cd = f8
       2 o_nationality_cd = f8
       2 n_encntr_class_cd = f8
       2 o_encntr_class_cd = f8
       2 n_encntr_type_cd = f8
       2 o_encntr_type_cd = f8
       2 n_encntr_type_class_cd = f8
       2 o_encntr_type_class_cd = f8
       2 n_encntr_status_cd = f8
       2 o_encntr_status_cd = f8
       2 n_pre_reg_dt_tm = dq8
       2 o_pre_reg_dt_tm = dq8
       2 n_pre_reg_prsnl_id = f8
       2 o_pre_reg_prsnl_id = f8
       2 n_reg_dt_tm = dq8
       2 o_reg_dt_tm = dq8
       2 n_reg_prsnl_id = f8
       2 o_reg_prsnl_id = f8
       2 n_est_arrive_dt_tm = dq8
       2 o_est_arrive_dt_tm = dq8
       2 n_est_depart_dt_tm = dq8
       2 o_est_depart_dt_tm = dq8
       2 n_arrive_dt_tm = dq8
       2 o_arrive_dt_tm = dq8
       2 n_depart_dt_tm = dq8
       2 o_depart_dt_tm = dq8
       2 n_admit_type_cd = f8
       2 o_admit_type_cd = f8
       2 n_admit_src_cd = f8
       2 o_admit_src_cd = f8
       2 n_admit_mode_cd = f8
       2 o_admit_mode_cd = f8
       2 n_admit_with_med_cd = f8
       2 o_admit_with_med_cd = f8
       2 n_refer_comment = c40
       2 o_refer_comment = c40
       2 n_disch_disp_cd = f8
       2 o_disch_disp_cd = f8
       2 n_disch_to_loctn_cd = f8
       2 o_disch_to_loctn_cd = f8
       2 n_preadmit_nbr = c20
       2 o_preadmit_nbr = c20
       2 n_preadmit_test_cd = f8
       2 o_preadmit_test_cd = f8
       2 n_readmit_cd = f8
       2 o_readmit_cd = f8
       2 n_accom_cd = f8
       2 o_accom_cd = f8
       2 n_accom_req_cd = f8
       2 o_accom_req_cd = f8
       2 n_alt_result_dest_cd = f8
       2 o_alt_result_dest_cd = f8
       2 n_amb_cond_cd = f8
       2 o_amb_cond_cd = f8
       2 n_courtesy_cd = f8
       2 o_courtesy_cd = f8
       2 n_diet_type_cd = f8
       2 o_diet_type_cd = f8
       2 n_isolation_cd = f8
       2 o_isolation_cd = f8
       2 n_med_service_cd = f8
       2 o_med_service_cd = f8
       2 n_result_dest_cd = f8
       2 o_result_dest_cd = f8
       2 n_encntr_vip_cd = f8
       2 o_encntr_vip_cd = f8
       2 n_encntr_sex_cd = f8
       2 o_encntr_sex_cd = f8
       2 n_disch_dt_tm = dq8
       2 o_disch_dt_tm = dq8
       2 n_guar_type_cd = f8
       2 o_guar_type_cd = f8
       2 n_loc_temp_cd = f8
       2 o_loc_temp_cd = f8
       2 n_reason_for_visit = c40
       2 o_reason_for_visit = c40
       2 n_fin_class_cd = f8
       2 o_fin_class_cd = f8
       2 n_location_cd = f8
       2 o_location_cd = f8
       2 n_loc_facility_cd = f8
       2 o_loc_facility_cd = f8
       2 n_loc_building_cd = f8
       2 o_loc_building_cd = f8
       2 n_loc_nurse_unit_cd = f8
       2 o_loc_nurse_unit_cd = f8
       2 n_loc_room_cd = f8
       2 o_loc_room_cd = f8
       2 n_loc_bed_cd = f8
       2 o_loc_bed_cd = f8
       2 n_admit_doc_name = c30
       2 o_admit_doc_name = c30
       2 n_admit_doc_id = f8
       2 o_admit_doc_id = f8
       2 n_attend_doc_name = c30
       2 o_attend_doc_name = c30
       2 n_attend_doc_id = f8
       2 o_attend_doc_id = f8
       2 n_consult_doc_name = c30
       2 o_consult_doc_name = c30
       2 n_consult_doc_id = f8
       2 o_consult_doc_id = f8
       2 n_refer_doc_name = c30
       2 o_refer_doc_name = c30
       2 n_refer_doc_id = f8
       2 o_refer_doc_id = f8
       2 n_admit_doc_nbr = c16
       2 o_admit_doc_nbr = c16
       2 n_attend_doc_nbr = c16
       2 o_attend_doc_nbr = c16
       2 n_consult_doc_nbr = c16
       2 o_consult_doc_nbr = c16
       2 n_refer_doc_nbr = c16
       2 o_refer_doc_nbr = c16
       2 n_per_home_address_id = f8
       2 o_per_home_address_id = f8
       2 n_per_home_addr_street = c100
       2 o_per_home_addr_street = c100
       2 n_per_home_addr_city = c40
       2 o_per_home_addr_city = c40
       2 n_per_home_addr_state = c20
       2 o_per_home_addr_state = c20
       2 n_per_home_addr_zipcode = c20
       2 o_per_home_addr_zipcode = c20
       2 n_per_bus_address_id = f8
       2 o_per_bus_address_id = f8
       2 n_per_bus_addr_street = c100
       2 o_per_bus_addr_street = c100
       2 n_per_bus_addr_city = c40
       2 o_per_bus_addr_city = c40
       2 n_per_bus_addr_state = c20
       2 o_per_bus_addr_state = c20
       2 n_per_bus_addr_zipcode = c20
       2 o_per_bus_addr_zipcode = c20
       2 n_per_home_phone_id = f8
       2 o_per_home_phone_id = f8
       2 n_per_home_ph_format_cd = f8
       2 o_per_home_ph_format_cd = f8
       2 n_per_home_ph_number = c20
       2 o_per_home_ph_number = c20
       2 n_per_home_ext = c10
       2 o_per_home_ext = c10
       2 n_per_bus_phone_id = f8
       2 o_per_bus_phone_id = f8
       2 n_per_bus_ph_format_cd = f8
       2 o_per_bus_ph_format_cd = f8
       2 n_per_bus_ph_number = c20
       2 o_per_bus_ph_number = c20
       2 n_per_bus_ext = c10
       2 o_per_bus_ext = c10
       2 n_per_home_addr_street2 = c100
       2 o_per_home_addr_street2 = c100
       2 n_per_bus_addr_street2 = c100
       2 o_per_bus_addr_street2 = c100
       2 n_per_home_addr_county = c20
       2 o_per_home_addr_county = c20
       2 n_per_home_addr_country = c20
       2 o_per_home_addr_country = c20
       2 n_per_bus_addr_county = c20
       2 o_per_bus_addr_county = c20
       2 n_per_bus_addr_country = c20
       2 o_per_bus_addr_country = c20
       2 n_encntr_complete_dt_tm = dq8
       2 o_encntr_complete_dt_tm = dq8
       2 n_organization_id = f8
       2 o_organization_id = f8
       2 n_contributor_system_cd = f8
       2 o_contributor_system_cd = f8
       2 n_assign_to_loc_dt_tm = dq8
       2 o_assign_to_loc_dt_tm = dq8
       2 n_alt_lvl_care_cd = f8
       2 o_alt_lvl_care_cd = f8
       2 n_program_service_cd = f8
       2 o_program_service_cd = f8
       2 n_specialty_unit_cd = f8
       2 o_specialty_unit_cd = f8
       2 n_birth_tz = i4
       2 o_birth_tz = i4
       2 abs_n_birth_dt_tm = dq8
       2 abs_o_birth_dt_tm = dq8
       2 n_service_category_cd = f8
       2 o_service_category_cd = f8
       2 output_dest_cd = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET transaction_dt_tm = acm_request->transaction_info_qual[index].transaction_dt_tm
   SET person_idx = acm_request->transaction_info_qual[index].person_idx
   SET encntr_idx = acm_request->transaction_info_qual[index].encntr_idx
   IF (person_idx > 0)
    SET person_id = acm_request->person_qual[person_idx].person_id
   ELSE
    SET person_id = acm_request->transaction_info_qual[index].person_id
   ENDIF
   IF (encntr_idx > 0)
    SET encntr_id = acm_request->encounter_qual[encntr_idx].encntr_id
   ELSE
    SET encntr_id = acm_request->transaction_info_qual[index].encntr_id
   ENDIF
   IF (request->incld_req_trans_info_in_rep_ind)
    SET reply->transaction_info_qual[index].person_id = person_id
    SET reply->transaction_info_qual[index].encntr_id = encntr_id
    SET reply->transaction_info_qual[index].person_idx = person_idx
    SET reply->transaction_info_qual[index].encntr_idx = encntr_idx
   ENDIF
   SET pm_ens_transaction_req->transaction = acm_request->transaction_info_qual[index].transaction
   SET pm_ens_transaction_req->transaction_dt_tm = transaction_dt_tm
   SET pm_ens_transaction_req->transaction_reason = acm_request->transaction_info_qual[index].
   transaction_reason
   SET pm_ens_transaction_req->transaction_reason_cd = acm_request->transaction_info_qual[index].
   transaction_reason_cd
   SET pm_ens_transaction_req->task_number = reqinfo->updt_task
   SET pm_ens_transaction_req->person_id = person_id
   SET pm_ens_transaction_req->encntr_id = encntr_id
   SET reply->status_data.status = "F"
   EXECUTE pm_ens_transaction  WITH replace("REQUEST","PM_ENS_TRANSACTION_REQ"), replace("REPLY",
    "PM_ENS_TRANSACTION_REP")
   IF ((pm_ens_transaction_rep->status_data.status != "S"))
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   SET reply->transaction_info_qual[index].transaction_id = pm_ens_transaction_rep->trans.
   transaction_id
   SET reply->transaction_info_qual[index].pm_hist_tracking_id = pm_ens_transaction_rep->trans.
   pm_hist_tracking_id
   IF (person_idx > 0)
    SET acm_request->person_qual[person_idx].pm_hist_tracking_id = reply->transaction_info_qual[index
    ].pm_hist_tracking_id
    SET acm_request->person_qual[person_idx].transaction_dt_tm = transaction_dt_tm
   ENDIF
   IF (encntr_idx > 0)
    SET acm_request->encounter_qual[encntr_idx].pm_hist_tracking_id = reply->transaction_info_qual[
    index].pm_hist_tracking_id
    SET acm_request->encounter_qual[encntr_idx].transaction_dt_tm = transaction_dt_tm
   ENDIF
   IF ( NOT (((person_idx > 0) OR (encntr_idx > 0)) )
    AND acm_hist_ind=1)
    IF ((acm_request->transaction_info_qual[index].person_id > 0))
     SET reply->status_data.status = "F"
     SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
     SET reply->error_info.line2 = build2(error_str2,person_str)
     SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",index,"]",
      "->","person_idx ",error_str3)
     GO TO exit_script
    ELSEIF ((acm_request->transaction_info_qual[index].encntr_id > 0))
     SET reply->status_data.status = "F"
     SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
     SET reply->error_info.line2 = build2(error_str2,encntr_str)
     SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",index,"]",
      "->","encntr_idx ",error_str3)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 FOR (index = 1 TO reply->person_person_reltn_qual_cnt)
   SET person_idx = acm_request->person_person_reltn_qual[index].person_idx
   SET related_person_idx = acm_request->person_person_reltn_qual[index].related_person_idx
   IF (person_idx > 0
    AND related_person_idx > 0
    AND (acm_request->person_qual[related_person_idx].pm_hist_tracking_id <= 0))
    SET acm_request->person_qual[related_person_idx].pm_hist_tracking_id = acm_request->person_qual[
    person_idx].pm_hist_tracking_id
    SET acm_request->person_qual[related_person_idx].transaction_dt_tm = acm_request->person_qual[
    person_idx].transaction_dt_tm
   ENDIF
 ENDFOR
 FOR (index = 1 TO reply->encntr_person_reltn_qual_cnt)
   SET encntr_idx = acm_request->encntr_person_reltn_qual[index].encntr_idx
   SET related_person_idx = acm_request->encntr_person_reltn_qual[index].related_person_idx
   IF (encntr_idx > 0
    AND related_person_idx > 0
    AND (acm_request->person_qual[related_person_idx].pm_hist_tracking_id <= 0))
    SET acm_request->person_qual[related_person_idx].pm_hist_tracking_id = acm_request->
    encounter_qual[encntr_idx].pm_hist_tracking_id
    SET acm_request->person_qual[related_person_idx].transaction_dt_tm = acm_request->encounter_qual[
    encntr_idx].transaction_dt_tm
   ENDIF
 ENDFOR
 IF ((reply->person_qual_cnt > 0))
  EXECUTE acm_write_person
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
  FOR (i = 1 TO reply->person_qual_cnt)
    IF ((acm_request->person_qual[i].action_flag != 0))
     SET stat = changed_person_map("A",acm_request->person_qual[i].person_id,"PERSON")
    ENDIF
  ENDFOR
 ENDIF
 SET nbr = 0
 IF ((reply->person_name_qual_cnt > 0))
  SET qual_name = "person_name_qual"
  FOR (i = 1 TO reply->person_name_qual_cnt)
    SET person_idx = acm_request->person_name_qual[i].person_idx
    IF (person_idx > 0)
     SET acm_request->person_name_qual[i].person_id = acm_request->person_qual[person_idx].person_id
     SET acm_request->person_name_qual[i].transaction_dt_tm = acm_request->person_qual[person_idx].
     transaction_dt_tm
     SET acm_request->person_name_qual[i].pm_hist_tracking_id = acm_request->person_qual[person_idx].
     pm_hist_tracking_id
    ELSEIF (acm_hist_ind=1
     AND (((acm_request->person_name_qual[i].action_flag=add_action)) OR ((acm_request->
    person_name_qual[i].action_flag=chg_action))) )
     SET reply->status_data.status = "F"
     SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
     SET reply->error_info.line2 = build2(error_str2,person_str)
     SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",i,"]",
      "->","person_idx ",error_str3)
     GO TO exit_script
    ENDIF
    IF ((acm_request->person_name_qual[i].person_id > 0))
     SET stat = changed_entity_map("A",acm_request->person_name_qual[i].person_id,"PERSON")
    ELSE
     SET nbr = 1
    ENDIF
  ENDFOR
  IF (nbr > 0)
   SET qual_cnt = reply->person_name_qual_cnt
   SET f_val = 1
   SET t_val = qual_cnt
   SET max_val = 200
   IF (t_val <= max_val)
    SET max_val = t_val
    CALL getpersonnamedata(max_val)
   ELSE
    SET t_val = max_val
    WHILE (qual_cnt > 0)
      CALL getpersonnamedata(max_val)
      SET qual_cnt -= max_val
      SET f_val = (t_val+ 1)
      IF (qual_cnt > max_val)
       SET t_val += max_val
      ELSE
       SET t_val += qual_cnt
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
  EXECUTE acm_write_person_name
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 SET nbr = 0
 IF ((reply->person_alias_qual_cnt > 0))
  SET qual_name = "person_alias_qual"
  FOR (i = 1 TO reply->person_alias_qual_cnt)
    SET person_idx = acm_request->person_alias_qual[i].person_idx
    IF (person_idx > 0)
     SET acm_request->person_alias_qual[i].person_id = acm_request->person_qual[person_idx].person_id
     SET acm_request->person_alias_qual[i].transaction_dt_tm = acm_request->person_qual[person_idx].
     transaction_dt_tm
     SET acm_request->person_alias_qual[i].pm_hist_tracking_id = acm_request->person_qual[person_idx]
     .pm_hist_tracking_id
    ELSEIF (acm_hist_ind=1
     AND (((acm_request->person_alias_qual[i].action_flag=add_action)) OR ((acm_request->
    person_alias_qual[i].action_flag=chg_action))) )
     SET reply->status_data.status = "F"
     SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
     SET reply->error_info.line2 = build2(error_str2,person_str)
     SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",i,"]",
      "->","person_idx ",error_str3)
     GO TO exit_script
    ENDIF
    IF ((acm_request->person_alias_qual[i].person_id > 0))
     SET stat = changed_entity_map("A",acm_request->person_alias_qual[i].person_id,"PERSON")
    ELSE
     SET nbr = 1
    ENDIF
  ENDFOR
  IF (nbr > 0)
   SET qual_cnt = reply->person_alias_qual_cnt
   SET f_val = 1
   SET t_val = qual_cnt
   SET max_val = 200
   IF (t_val <= max_val)
    SET max_val = t_val
    CALL getpersonaliasdata(max_val)
   ELSE
    SET t_val = max_val
    WHILE (qual_cnt > 0)
      CALL getpersonaliasdata(max_val)
      SET qual_cnt -= max_val
      SET f_val = (t_val+ 1)
      IF (qual_cnt > max_val)
       SET t_val += max_val
      ELSE
       SET t_val += qual_cnt
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
  EXECUTE acm_write_person_alias
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 SET nbr = 0
 IF ((reply->person_person_reltn_qual_cnt > 0))
  FOR (i = 1 TO reply->person_person_reltn_qual_cnt)
    IF ((acm_request->person_person_reltn_qual[i].person_idx > 0))
     SET acm_request->person_person_reltn_qual[i].person_id = acm_request->person_qual[acm_request->
     person_person_reltn_qual[i].person_idx].person_id
    ENDIF
    IF ((acm_request->person_person_reltn_qual[i].related_person_idx > 0))
     SET acm_request->person_person_reltn_qual[i].related_person_id = acm_request->person_qual[
     acm_request->person_person_reltn_qual[i].related_person_idx].person_id
    ENDIF
    IF ((acm_request->person_person_reltn_qual[i].person_id > 0))
     SET stat = changed_entity_map("A",acm_request->person_person_reltn_qual[i].person_id,"PERSON")
    ELSE
     SET nbr = 1
    ENDIF
  ENDFOR
  IF (nbr > 0)
   SET qual_cnt = reply->person_person_reltn_qual_cnt
   SET f_val = 1
   SET t_val = qual_cnt
   SET max_val = 200
   IF (t_val <= max_val)
    SET max_val = t_val
    CALL getpersonpersonreltndata(max_val)
   ELSE
    SET t_val = max_val
    WHILE (qual_cnt > 0)
      CALL getpersonpersonreltndata(max_val)
      SET qual_cnt -= max_val
      SET f_val = (t_val+ 1)
      IF (qual_cnt > max_val)
       SET t_val += max_val
      ELSE
       SET t_val += qual_cnt
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
  EXECUTE acm_write_person_person_reltn
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 SET nbr = 0
 IF ((reply->person_prsnl_reltn_qual_cnt > 0))
  SET qual_name = "person_prsnl_reltn_qual"
  FOR (i = 1 TO reply->person_prsnl_reltn_qual_cnt)
    SET person_idx = acm_request->person_prsnl_reltn_qual[i].person_idx
    IF (person_idx > 0)
     SET acm_request->person_prsnl_reltn_qual[i].person_id = acm_request->person_qual[person_idx].
     person_id
     SET acm_request->person_prsnl_reltn_qual[i].transaction_dt_tm = acm_request->person_qual[
     person_idx].transaction_dt_tm
     SET acm_request->person_prsnl_reltn_qual[i].pm_hist_tracking_id = acm_request->person_qual[
     person_idx].pm_hist_tracking_id
    ELSEIF (acm_hist_ind=1
     AND (((acm_request->person_prsnl_reltn_qual[i].action_flag=add_action)) OR ((acm_request->
    person_prsnl_reltn_qual[i].action_flag=chg_action))) )
     SET reply->status_data.status = "F"
     SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
     SET reply->error_info.line2 = build2(error_str2,person_str)
     SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",i,"]",
      "->","person_idx ",error_str3)
     GO TO exit_script
    ENDIF
    IF ((acm_request->person_prsnl_reltn_qual[i].person_id > 0))
     SET stat = changed_entity_map("A",acm_request->person_prsnl_reltn_qual[i].person_id,"PERSON")
    ELSE
     SET nbr = 1
    ENDIF
  ENDFOR
  IF (nbr > 0)
   SET qual_cnt = reply->person_prsnl_reltn_qual_cnt
   SET f_val = 1
   SET t_val = qual_cnt
   SET max_val = 200
   IF (t_val <= max_val)
    SET max_val = t_val
    CALL getpersonprsnlreltndata(max_val)
   ELSE
    SET t_val = max_val
    WHILE (qual_cnt > 0)
      CALL getpersonprsnlreltndata(max_val)
      SET qual_cnt -= max_val
      SET f_val = (t_val+ 1)
      IF (qual_cnt > max_val)
       SET t_val += max_val
      ELSE
       SET t_val += qual_cnt
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
  EXECUTE acm_write_person_prsnl_reltn
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->person_patient_qual_cnt > 0))
  SET qual_name = "person_patient_qual"
  FOR (i = 1 TO reply->person_patient_qual_cnt)
    SET person_idx = acm_request->person_patient_qual[i].person_idx
    IF (person_idx > 0)
     SET acm_request->person_patient_qual[i].person_id = acm_request->person_qual[person_idx].
     person_id
     SET acm_request->person_patient_qual[i].transaction_dt_tm = acm_request->person_qual[person_idx]
     .transaction_dt_tm
     SET acm_request->person_patient_qual[i].pm_hist_tracking_id = acm_request->person_qual[
     person_idx].pm_hist_tracking_id
    ELSEIF (acm_hist_ind=1
     AND (((acm_request->person_patient_qual[i].action_flag=add_action)) OR ((acm_request->
    person_patient_qual[i].action_flag=chg_action))) )
     SET reply->status_data.status = "F"
     SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
     SET reply->error_info.line2 = build2(error_str2,person_str)
     SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",i,"]",
      "->","person_idx ",error_str3)
     GO TO exit_script
    ENDIF
    IF ((acm_request->person_patient_qual[i].person_id > 0)
     AND (acm_request->person_patient_qual[i].action_flag=chg_action))
     SELECT INTO "nl:"
      FROM person_patient pp
      WHERE (pp.person_id=acm_request->person_patient_qual[i].person_id)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET acm_request->person_patient_qual[i].action_flag = add_action
     ENDIF
    ENDIF
    IF ((acm_request->person_patient_qual[i].person_id > 0)
     AND (acm_request->person_patient_qual[i].action_flag != 0))
     SET stat = changed_entity_map("A",acm_request->person_patient_qual[i].person_id,"PERSON")
    ENDIF
  ENDFOR
  EXECUTE acm_write_person_patient
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 FREE SET code_value_reltn_ref
 RECORD code_value_reltn_ref(
   1 list_cnt = i4
   1 list_qual[*]
     2 person_id = f8
     2 code_set = i4
     2 code_value = f8
 )
 SET nbr = 0
 IF ((reply->person_code_value_r_qual_cnt > 0))
  SET code_value_reltn_ref->list_cnt = 0
  FOR (i = 1 TO reply->person_code_value_r_qual_cnt)
    SET person_idx = acm_request->person_code_value_r_qual[i].person_idx
    SET qual_name = "person_code_value_r"
    IF (person_idx > 0)
     SET acm_request->person_code_value_r_qual[i].person_id = acm_request->person_qual[person_idx].
     person_id
     SET acm_request->person_code_value_r_qual[i].transaction_dt_tm = acm_request->person_qual[
     person_idx].transaction_dt_tm
     SET acm_request->person_code_value_r_qual[i].pm_hist_tracking_id = acm_request->person_qual[
     person_idx].pm_hist_tracking_id
    ELSEIF (acm_hist_ind=1
     AND (((acm_request->person_code_value_r_qual[i].action_flag=add_action)) OR ((acm_request->
    person_code_value_r_qual[i].action_flag=chg_action))) )
     SET reply->status_data.status = "F"
     SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
     SET reply->error_info.line2 = build2(error_str2,person_str)
     SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",i,"]",
      "->","person_idx ",error_str3)
     GO TO exit_script
    ENDIF
    IF ((acm_request->person_code_value_r_qual[i].action_flag != add_action)
     AND (acm_request->person_code_value_r_qual[i].person_code_value_r_id=0))
     SET code_value_reltn_ref->list_cnt += 1
     IF (mod(code_value_reltn_ref->list_cnt,10)=1)
      CALL alterlist(code_value_reltn_ref->list_qual,(code_value_reltn_ref->list_cnt+ 9))
     ENDIF
     SET code_value_reltn_ref->list_qual[code_value_reltn_ref->list_cnt].code_set = acm_request->
     person_code_value_r_qual[i].code_set
     SET code_value_reltn_ref->list_qual[code_value_reltn_ref->list_cnt].code_value = acm_request->
     person_code_value_r_qual[i].code_value
     SET code_value_reltn_ref->list_qual[code_value_reltn_ref->list_cnt].person_id = acm_request->
     person_code_value_r_qual[i].person_id
    ENDIF
    IF ((acm_request->person_code_value_r_qual[i].person_id > 0))
     SET stat = changed_entity_map("A",acm_request->person_code_value_r_qual[i].person_id,"PERSON")
    ELSE
     SET nbr = 1
    ENDIF
  ENDFOR
  IF (nbr > 0)
   SET qual_cnt = reply->person_code_value_r_qual_cnt
   SET f_val = 1
   SET t_val = qual_cnt
   SET max_val = 200
   IF (t_val <= max_val)
    SET max_val = t_val
    CALL getpersoncodevaluerdata(max_val)
   ELSE
    SET t_val = max_val
    WHILE (qual_cnt > 0)
      CALL getpersoncodevaluerdata(max_val)
      SET qual_cnt -= max_val
      SET f_val = (t_val+ 1)
      IF (qual_cnt > max_val)
       SET t_val += max_val
      ELSE
       SET t_val += qual_cnt
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
  IF ((code_value_reltn_ref->list_cnt <= 1))
   SET sx_slice = 1
  ENDIF
  SET sx_pad_tot = (ceil((cnvtreal(code_value_reltn_ref->list_cnt)/ sx_slice)) * sx_slice)
  CALL alterlist(code_value_reltn_ref->list_qual,sx_pad_tot)
  FOR (t1 = (code_value_reltn_ref->list_cnt+ 1) TO sx_pad_tot)
    SET code_value_reltn_ref->list_qual[t1].person_id = code_value_reltn_ref->list_qual[
    code_value_reltn_ref->list_cnt].person_id
    SET code_value_reltn_ref->list_qual[t1].code_set = code_value_reltn_ref->list_qual[
    code_value_reltn_ref->list_cnt].code_set
    SET code_value_reltn_ref->list_qual[t1].code_value = code_value_reltn_ref->list_qual[
    code_value_reltn_ref->list_cnt].code_value
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((sx_pad_tot/ sx_slice))),
    person_code_value_r pcr
   PLAN (d
    WHERE assign(sx_beg,evaluate(d.seq,1,1,(sx_beg+ sx_slice))))
    JOIN (pcr
    WHERE expand(t1,sx_beg,(sx_beg+ (sx_slice - 1)),pcr.person_id,code_value_reltn_ref->list_qual[t1]
     .person_id,
     pcr.code_set,code_value_reltn_ref->list_qual[t1].code_set,pcr.code_value,code_value_reltn_ref->
     list_qual[t1].code_value)
     AND pcr.person_code_value_r_id > 0
     AND ((pcr.active_ind+ 0)=1)
     AND ((pcr.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
     AND ((pcr.end_effective_dt_tm+ 0) > cnvtdatetime(sysdate)))
   DETAIL
    t2 = locateval(t1,1,reply->person_code_value_r_qual_cnt,pcr.person_id,acm_request->
     person_code_value_r_qual[t1].person_id,
     pcr.code_set,acm_request->person_code_value_r_qual[t1].code_set,pcr.code_value,acm_request->
     person_code_value_r_qual[t1].code_value), acm_request->person_code_value_r_qual[t2].
    person_code_value_r_id = pcr.person_code_value_r_id
   WITH nocounter
  ;end select
  EXECUTE acm_write_person_code_value_r
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 SET nbr = 0
 IF ((reply->person_org_reltn_qual_cnt > 0))
  FOR (i = 1 TO reply->person_org_reltn_qual_cnt)
   IF ((acm_request->person_org_reltn_qual[i].person_idx > 0))
    SET acm_request->person_org_reltn_qual[i].person_id = acm_request->person_qual[acm_request->
    person_org_reltn_qual[i].person_idx].person_id
   ENDIF
   IF ((acm_request->person_org_reltn_qual[i].person_id > 0))
    SET stat = changed_entity_map("A",acm_request->person_org_reltn_qual[i].person_id,"PERSON")
   ELSE
    SET nbr = 1
   ENDIF
  ENDFOR
  IF (nbr > 0)
   SET qual_cnt = reply->person_org_reltn_qual_cnt
   SET f_val = 1
   SET t_val = qual_cnt
   SET max_val = 200
   IF (t_val <= max_val)
    SET max_val = t_val
    CALL getpersonorgreltndata(max_val)
   ELSE
    SET t_val = max_val
    WHILE (qual_cnt > 0)
      CALL getpersonorgreltndata(max_val)
      SET qual_cnt -= max_val
      SET f_val = (t_val+ 1)
      IF (qual_cnt > max_val)
       SET t_val += max_val
      ELSE
       SET t_val += qual_cnt
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
  EXECUTE acm_write_person_org_reltn
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->address_qual_cnt > 0))
  SET qual_name = "address_qual"
  FOR (index = 1 TO reply->address_qual_cnt)
    SET parent_entity_idx = acm_request->address_qual[index].parent_entity_idx
    IF (parent_entity_idx > 0)
     SET acm_request->address_qual[index].parent_entity_id = acm_request->person_qual[
     parent_entity_idx].person_id
     SET acm_request->address_qual[index].transaction_dt_tm = acm_request->person_qual[
     parent_entity_idx].transaction_dt_tm
     SET acm_request->address_qual[index].pm_hist_tracking_id = acm_request->person_qual[
     parent_entity_idx].pm_hist_tracking_id
    ELSEIF (acm_hist_ind=1
     AND (((acm_request->address_qual[index].action_flag=add_action)) OR ((acm_request->address_qual[
    index].action_flag=chg_action))) )
     SET reply->status_data.status = "F"
     SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
     SET reply->error_info.line2 = build2(error_str2,person_str)
     SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",index,"]",
      "->","parent_entity_idx ",error_str3)
     GO TO exit_script
    ENDIF
    IF ((acm_request->address_qual[index].action_flag=add_action)
     AND (acm_request->address_qual[index].parent_entity_name="PERSON"))
     SET stat = changed_entity_map("A",acm_request->address_qual[index].parent_entity_id,"PERSON")
    ENDIF
  ENDFOR
  SET qual_cnt = reply->address_qual_cnt
  SET f_val = 1
  SET t_val = qual_cnt
  SET max_val = 200
  IF (t_val <= max_val)
   SET max_val = t_val
   CALL getaddressdata(max_val)
  ELSE
   SET t_val = max_val
   WHILE (qual_cnt > 0)
     CALL getaddressdata(max_val)
     SET qual_cnt -= max_val
     SET f_val = (t_val+ 1)
     IF (qual_cnt > max_val)
      SET t_val += max_val
     ELSE
      SET t_val += qual_cnt
     ENDIF
   ENDWHILE
  ENDIF
  EXECUTE acm_write_address
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->phone_qual_cnt > 0))
  SET qual_name = "phone_qual"
  FOR (index = 1 TO reply->phone_qual_cnt)
    SET parent_entity_idx = acm_request->phone_qual[index].parent_entity_idx
    IF (parent_entity_idx > 0)
     SET acm_request->phone_qual[index].parent_entity_id = acm_request->person_qual[parent_entity_idx
     ].person_id
     SET acm_request->phone_qual[index].transaction_dt_tm = acm_request->person_qual[
     parent_entity_idx].transaction_dt_tm
     SET acm_request->phone_qual[index].pm_hist_tracking_id = acm_request->person_qual[
     parent_entity_idx].pm_hist_tracking_id
    ELSEIF (acm_hist_ind=1
     AND (((acm_request->phone_qual[index].action_flag=add_action)) OR ((acm_request->phone_qual[
    index].action_flag=chg_action))) )
     SET reply->status_data.status = "F"
     SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
     SET reply->error_info.line2 = build2(error_str2,person_str)
     SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",index,"]",
      "->","parent_entity_idx ",error_str3)
     GO TO exit_script
    ENDIF
    IF ((acm_request->phone_qual[index].action_flag=add_action)
     AND (acm_request->phone_qual[index].parent_entity_name IN ("PERSON", "PERSON_PATIENT")))
     SET stat = changed_entity_map("A",acm_request->phone_qual[index].parent_entity_id,"PERSON")
    ENDIF
  ENDFOR
  SET qual_cnt = reply->phone_qual_cnt
  SET f_val = 1
  SET t_val = qual_cnt
  SET max_val = 200
  IF (t_val <= max_val)
   SET max_val = t_val
   CALL getphonedata(max_val)
  ELSE
   SET t_val = max_val
   WHILE (qual_cnt > 0)
     CALL getphonedata(max_val)
     SET qual_cnt -= max_val
     SET f_val = (t_val+ 1)
     IF (qual_cnt > max_val)
      SET t_val += max_val
     ELSE
      SET t_val += qual_cnt
     ENDIF
   ENDWHILE
  ENDIF
  EXECUTE acm_write_phone
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->encntr_financial_qual_cnt > 0))
  FOR (i = 1 TO reply->encntr_financial_qual_cnt)
    IF ((acm_request->encntr_financial_qual[i].person_idx > 0))
     SET acm_request->encntr_financial_qual[i].person_id = acm_request->person_qual[acm_request->
     encntr_financial_qual[i].person_idx].person_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_encntr_financial
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->encounter_qual_cnt > 0))
  EXECUTE acm_write_encounter
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->encntr_loc_hist_qual_cnt > 0))
  FOR (i = 1 TO reply->encntr_loc_hist_qual_cnt)
    IF ((acm_request->encntr_loc_hist_qual[i].encntr_idx > 0))
     SET acm_request->encntr_loc_hist_qual[i].encntr_id = acm_request->encounter_qual[acm_request->
     encntr_loc_hist_qual[i].encntr_idx].encntr_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_encntr_loc_hist
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->service_category_hist_qual_cnt > 0))
  FOR (i = 1 TO reply->service_category_hist_qual_cnt)
    IF ((acm_request->service_category_hist_qual[i].encntr_idx > 0))
     SET acm_request->service_category_hist_qual[i].encntr_id = acm_request->encounter_qual[
     acm_request->service_category_hist_qual[i].encntr_idx].encntr_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_service_category_hist
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->encntr_alias_qual_cnt > 0))
  SET qual_name = "encntr_alias_qual"
  FOR (i = 1 TO reply->encntr_alias_qual_cnt)
   SET encntr_idx = acm_request->encntr_alias_qual[i].encntr_idx
   IF (encntr_idx > 0)
    SET acm_request->encntr_alias_qual[i].encntr_id = acm_request->encounter_qual[encntr_idx].
    encntr_id
    SET acm_request->encntr_alias_qual[i].pm_hist_tracking_id = acm_request->encounter_qual[
    encntr_idx].pm_hist_tracking_id
    SET acm_request->encntr_alias_qual[i].transaction_dt_tm = acm_request->encounter_qual[encntr_idx]
    .transaction_dt_tm
   ELSEIF (acm_hist_ind=1
    AND (((acm_request->encntr_alias_qual[i].action_flag=add_action)) OR ((acm_request->
   encntr_alias_qual[i].action_flag=chg_action))) )
    SET reply->status_data.status = "F"
    SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
    SET reply->error_info.line2 = build2(error_str2,encntr_str)
    SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",i,"]",
     "->","encntr_idx ",error_str3)
    GO TO exit_script
   ENDIF
  ENDFOR
  EXECUTE acm_write_encntr_alias
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->encntr_code_value_r_qual_cnt > 0))
  FOR (i = 1 TO reply->encntr_code_value_r_qual_cnt)
    IF ((acm_request->encntr_code_value_r_qual[i].encntr_idx > 0))
     SET acm_request->encntr_code_value_r_qual[i].encntr_id = acm_request->encounter_qual[acm_request
     ->encntr_code_value_r_qual[i].encntr_idx].encntr_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_encntr_code_value_r
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->encntr_domain_qual_cnt > 0))
  FOR (i = 1 TO reply->encntr_domain_qual_cnt)
   IF ((acm_request->encntr_domain_qual[i].encntr_idx > 0))
    SET acm_request->encntr_domain_qual[i].encntr_id = acm_request->encounter_qual[acm_request->
    encntr_domain_qual[i].encntr_idx].encntr_id
   ENDIF
   IF ((acm_request->encntr_domain_qual[i].person_idx > 0))
    SET acm_request->encntr_domain_qual[i].person_id = acm_request->person_qual[acm_request->
    encntr_domain_qual[i].person_idx].person_id
   ENDIF
  ENDFOR
  EXECUTE acm_write_encntr_domain
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->encntr_info_qual_cnt > 0))
  SET qual_name = "encntr_info_qual"
  FOR (i = 1 TO reply->encntr_info_qual_cnt)
   SET encntr_idx = acm_request->encntr_info_qual[i].encntr_idx
   IF (encntr_idx > 0)
    SET acm_request->encntr_info_qual[i].encntr_id = acm_request->encounter_qual[encntr_idx].
    encntr_id
    SET acm_request->encntr_info_qual[i].pm_hist_tracking_id = acm_request->encounter_qual[encntr_idx
    ].pm_hist_tracking_id
    SET acm_request->encntr_info_qual[i].transaction_dt_tm = acm_request->encounter_qual[encntr_idx].
    transaction_dt_tm
   ELSEIF (acm_hist_ind=1
    AND (((acm_request->encntr_info_qual[i].action_flag=add_action)) OR ((acm_request->
   encntr_info_qual[i].action_flag=chg_action))) )
    SET reply->status_data.status = "F"
    SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
    SET reply->error_info.line2 = build2(error_str2,encntr_str)
    SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",i,"]",
     "->","encntr_idx ",error_str3)
    GO TO exit_script
   ENDIF
  ENDFOR
  EXECUTE acm_write_encntr_info
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->encntr_org_reltn_qual_cnt > 0))
  FOR (i = 1 TO reply->encntr_org_reltn_qual_cnt)
    IF ((acm_request->encntr_org_reltn_qual[i].encntr_idx > 0))
     SET acm_request->encntr_org_reltn_qual[i].encntr_id = acm_request->encounter_qual[acm_request->
     encntr_org_reltn_qual[i].encntr_idx].encntr_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_encntr_org_reltn
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->encntr_person_reltn_qual_cnt > 0))
  FOR (i = 1 TO reply->encntr_person_reltn_qual_cnt)
   IF ((acm_request->encntr_person_reltn_qual[i].encntr_idx > 0))
    SET acm_request->encntr_person_reltn_qual[i].encntr_id = acm_request->encounter_qual[acm_request
    ->encntr_person_reltn_qual[i].encntr_idx].encntr_id
   ENDIF
   IF ((acm_request->encntr_person_reltn_qual[i].related_person_idx > 0))
    SET acm_request->encntr_person_reltn_qual[i].related_person_id = acm_request->person_qual[
    acm_request->encntr_person_reltn_qual[i].related_person_idx].person_id
   ENDIF
  ENDFOR
  EXECUTE acm_write_encntr_person_reltn
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->health_plan_qual_cnt > 0))
  EXECUTE acm_write_health_plan
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 SET nbr = 0
 IF ((reply->person_plan_reltn_qual_cnt > 0))
  FOR (i = 1 TO reply->person_plan_reltn_qual_cnt)
    IF ((acm_request->person_plan_reltn_qual[i].health_plan_idx > 0))
     SET acm_request->person_plan_reltn_qual[i].health_plan_id = acm_request->health_plan_qual[
     acm_request->person_plan_reltn_qual[i].health_plan_idx].health_plan_id
    ENDIF
    IF ((acm_request->person_plan_reltn_qual[i].person_idx > 0))
     SET acm_request->person_plan_reltn_qual[i].person_id = acm_request->person_qual[acm_request->
     person_plan_reltn_qual[i].person_idx].person_id
    ENDIF
    IF ((acm_request->person_plan_reltn_qual[i].person_org_reltn_idx > 0))
     SET acm_request->person_plan_reltn_qual[i].person_org_reltn_id = acm_request->
     person_org_reltn_qual[acm_request->person_plan_reltn_qual[i].person_org_reltn_idx].
     person_org_reltn_id
    ENDIF
    IF ((acm_request->person_plan_reltn_qual[i].person_id > 0))
     SET stat = changed_entity_map("A",acm_request->person_plan_reltn_qual[i].person_id,"PERSON")
    ELSE
     SET nbr = 1
    ENDIF
  ENDFOR
  IF (nbr > 0)
   SET qual_cnt = reply->person_plan_reltn_qual_cnt
   SET f_val = 1
   SET t_val = qual_cnt
   SET max_val = 200
   IF (t_val <= max_val)
    SET max_val = t_val
    CALL getpersonplanreltndata(max_val)
   ELSE
    SET t_val = max_val
    WHILE (qual_cnt > 0)
      CALL getpersonplanreltndata(max_val)
      SET qual_cnt -= max_val
      SET f_val = (t_val+ 1)
      IF (qual_cnt > max_val)
       SET t_val += max_val
      ELSE
       SET t_val += qual_cnt
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
  EXECUTE acm_write_person_plan_reltn
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->encntr_plan_reltn_qual_cnt > 0))
  FOR (i = 1 TO reply->encntr_plan_reltn_qual_cnt)
    IF ((acm_request->encntr_plan_reltn_qual[i].encntr_idx > 0))
     SET acm_request->encntr_plan_reltn_qual[i].encntr_id = acm_request->encounter_qual[acm_request->
     encntr_plan_reltn_qual[i].encntr_idx].encntr_id
    ENDIF
    IF ((acm_request->encntr_plan_reltn_qual[i].person_idx > 0))
     SET acm_request->encntr_plan_reltn_qual[i].person_id = acm_request->person_qual[acm_request->
     encntr_plan_reltn_qual[i].person_idx].person_id
    ENDIF
    IF ((acm_request->encntr_plan_reltn_qual[i].person_org_reltn_idx > 0))
     SET acm_request->encntr_plan_reltn_qual[i].person_org_reltn_id = acm_request->
     encntr_plan_reltn_qual[acm_request->encntr_plan_reltn_qual[i].person_org_reltn_idx].
     person_org_reltn_id
    ENDIF
    IF ((acm_request->encntr_plan_reltn_qual[i].person_plan_reltn_idx > 0))
     SET acm_request->encntr_plan_reltn_qual[i].person_plan_reltn_id = acm_request->
     person_plan_reltn_qual[acm_request->encntr_plan_reltn_qual[i].person_plan_reltn_idx].
     person_plan_reltn_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_encntr_plan_reltn
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->encntr_prsnl_reltn_qual_cnt > 0))
  SET qual_name = "encntr_prsnl_reltn_qual"
  FOR (i = 1 TO reply->encntr_prsnl_reltn_qual_cnt)
   SET encntr_idx = acm_request->encntr_prsnl_reltn_qual[i].encntr_idx
   IF (encntr_idx > 0)
    SET acm_request->encntr_prsnl_reltn_qual[i].encntr_id = acm_request->encounter_qual[encntr_idx].
    encntr_id
    SET acm_request->encntr_prsnl_reltn_qual[i].pm_hist_tracking_id = acm_request->encounter_qual[
    encntr_idx].pm_hist_tracking_id
    SET acm_request->encntr_prsnl_reltn_qual[i].transaction_dt_tm = acm_request->encounter_qual[
    encntr_idx].transaction_dt_tm
   ELSEIF (acm_hist_ind=1
    AND (((acm_request->encntr_prsnl_reltn_qual[i].action_flag=add_action)) OR ((acm_request->
   encntr_prsnl_reltn_qual[i].action_flag=chg_action))) )
    SET reply->status_data.status = "F"
    SET reply->error_info.line1 = build2(error_str0,trim(qual_name)," ",error_str1)
    SET reply->error_info.line2 = build2(error_str2,encntr_str)
    SET reply->error_info.line3 = build2(req_str,trim(qual_name),"[",i,"]",
     "->","encntr_idx ",error_str3)
    GO TO exit_script
   ENDIF
  ENDFOR
  EXECUTE acm_write_encntr_prsnl_reltn
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 SET nbr = 0
 IF ((reply->p_rx_plan_reltn_qual_cnt > 0))
  FOR (i = 1 TO reply->p_rx_plan_reltn_qual_cnt)
    IF ((acm_request->person_rx_plan_reltn_qual[i].health_plan_idx > 0))
     SET acm_request->person_rx_plan_reltn_qual[i].health_plan_id = acm_request->health_plan_qual[
     acm_request->person_rx_plan_reltn_qual[i].health_plan_idx].health_plan_id
    ENDIF
    IF ((acm_request->person_rx_plan_reltn_qual[i].person_idx > 0))
     SET acm_request->person_rx_plan_reltn_qual[i].person_id = acm_request->person_qual[acm_request->
     person_rx_plan_reltn_qual[i].person_idx].person_id
    ENDIF
    IF ((acm_request->person_rx_plan_reltn_qual[i].person_id > 0))
     SET stat = changed_entity_map("A",acm_request->person_rx_plan_reltn_qual[i].person_id,"PERSON")
    ELSE
     SET nbr = 1
    ENDIF
  ENDFOR
  IF (nbr > 0)
   SET qual_cnt = reply->person_rx_plan_reltn_qual_cnt
   SET f_val = 1
   SET t_val = qual_cnt
   SET max_val = 200
   IF (t_val <= max_val)
    SET max_val = t_val
    CALL getpersonrxplanreltndata(max_val)
   ELSE
    SET t_val = max_val
    WHILE (qual_cnt > 0)
      CALL getpersonrxplanreltndata(max_val)
      SET qual_cnt -= max_val
      SET f_val = (t_val+ 1)
      IF (qual_cnt > max_val)
       SET t_val += max_val
      ELSE
       SET t_val += qual_cnt
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
  EXECUTE acm_write_person_rx_plan_reltn
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->p_rx_plan_coverage_qual_cnt > 0))
  FOR (i = 1 TO reply->p_rx_plan_coverage_qual_cnt)
    IF ((acm_request->person_rx_plan_coverage_qual[i].person_rx_plan_reltn_idx > 0))
     SET acm_request->person_rx_plan_coverage_qual[i].person_rx_plan_reltn_id = acm_request->
     person_rx_plan_reltn_qual[acm_request->person_rx_plan_coverage_qual[i].person_rx_plan_reltn_idx]
     .person_rx_plan_reltn_id
    ENDIF
  ENDFOR
  EXECUTE acm_write_person_rx_plan_coverage
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 FREE RECORD acm_request_bounds
 RECORD acm_request_bounds(
   1 lbound = i4
   1 ubound = i4
 )
 FOR (index = 1 TO reply->person_qual_cnt)
   IF ((acm_request->person_qual[index].ft_entity_idx > 0)
    AND (((acm_request->person_qual[index].action_flag=chg_action)) OR ((acm_request->person_qual[
   index].action_flag=add_action))) )
    IF (ft_count=0)
     SET acm_request_bounds->lbound = (reply->person_qual_cnt+ 1)
    ENDIF
    SET ft_count += 1
    IF (mod(ft_count,10)=1)
     CALL alterlist(acm_request->person_qual,((reply->person_qual_cnt+ ft_count)+ 9))
    ENDIF
    SET tbl = acm_request->person_qual[index].ft_entity_name
    SET xref_idx = acm_request->person_qual[index].ft_entity_idx
    SET reply_str = concat("reply->",tbl,"_qual[",trim(cnvtstring(xref_idx)),"]->",
     tbl,"_id")
    SET acm_request->person_qual[(reply->person_qual_cnt+ ft_count)].ft_entity_id = parser(reply_str)
    SET old_use_req_updt_ind = acm_request->use_req_updt_ind
    SET acm_request->use_req_updt_ind = 1
    SET acm_request->person_qual[(reply->person_qual_cnt+ ft_count)].action_flag = chg_action
    SET acm_request->person_qual[(reply->person_qual_cnt+ ft_count)].person_id = reply->person_qual[
    index].person_id
    SET acm_request->person_qual[(reply->person_qual_cnt+ ft_count)].updt_cnt = 0
    SET acm_request->person_qual[(reply->person_qual_cnt+ ft_count)].chg_str =
    "FT_ENTITY_ID, UPDT_CNT,"
   ENDIF
 ENDFOR
 IF (ft_count > 0)
  SET reply->person_qual_cnt += ft_count
  CALL alterlist(acm_request->person_qual,reply->person_qual_cnt)
  SET acm_request_bounds->ubound = reply->person_qual_cnt
  EXECUTE acm_write_person
  IF ((reply->status_data.status != "S"))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  SET reply->person_qual_cnt = (acm_request_bounds->lbound - 1)
  CALL alterlist(acm_request->person_qual,reply->person_qual_cnt)
  CALL alterlist(reply->person_qual,reply->person_qual_cnt)
  SET acm_request->use_req_updt_ind = old_use_req_updt_ind
 ENDIF
 FREE RECORD acm_request_bounds
 CALL s_executeentityupdates(0)
 SET changed_person_map_cnt = changed_person_map("C")
 IF (changed_person_map_cnt > 0)
  FOR (index = 1 TO changed_person_map_cnt)
   SET stat = changed_person_map("L",index,changed_person_map_key,changed_person_map_value)
   IF (changed_person_map_key > 0)
    SET stat = changed_entity_map("D",changed_person_map_key)
   ENDIF
  ENDFOR
 ENDIF
 SET changed_entity_map_cnt = changed_entity_map("C")
 IF (changed_entity_map_cnt > 0)
  SET acm_chg_entity_updt_request->curprog = curprog
  SET acm_chg_entity_updt_request->entity_type_cnt = 1
  CALL alterlist(acm_chg_entity_updt_request->entity_type_qual,acm_chg_entity_updt_request->
   entity_type_cnt)
  SET acm_chg_entity_updt_request->entity_type_qual[1].entity_type = "PERSON"
  SET acm_chg_entity_updt_request->entity_type_qual[1].entity_id_cnt = changed_entity_map_cnt
  CALL alterlist(acm_chg_entity_updt_request->entity_type_qual[1].entity_id_qual,
   changed_entity_map_cnt)
  FOR (index = 1 TO changed_entity_map_cnt)
   SET stat = changed_entity_map("L",index,changed_entity_map_key,changed_entity_map_value)
   SET acm_chg_entity_updt_request->entity_type_qual[1].entity_id_qual[index].entity_id =
   changed_entity_map_key
  ENDFOR
  EXECUTE acm_chg_entity_updt
  IF ((acm_chg_entity_updt_reply->status_data.status != "S"))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (index = 1 TO reply->transaction_info_qual_cnt)
   FREE RECORD pm_ens_transaction_req
   RECORD pm_ens_transaction_req(
     1 pm_hist_tracking_id = f8
     1 transaction_id = f8
     1 transaction = vc
     1 transaction_dt_tm = dq8
     1 hl7_event = vc
     1 person_id = f8
     1 encntr_id = f8
     1 contributor_system_cd = f8
     1 transaction_reason = vc
     1 transaction_reason_cd = f8
     1 task_number = i4
     1 trans
       2 transaction_id = f8
       2 activity_dt_tm = dq8
       2 transaction = c4
       2 n_person_id = f8
       2 o_person_id = f8
       2 n_encntr_id = f8
       2 o_encntr_id = f8
       2 n_encntr_fin_id = f8
       2 o_encntr_fin_id = f8
       2 n_mrn = c20
       2 o_mrn = c20
       2 n_fin_nbr = c20
       2 o_fin_nbr = c20
       2 n_name_last = c20
       2 o_name_last = c20
       2 n_name_first = c20
       2 o_name_first = c20
       2 n_name_middle = c20
       2 o_name_middle = c20
       2 n_name_formatted = c30
       2 o_name_formatted = c30
       2 n_birth_dt_cd = f8
       2 o_birth_dt_cd = f8
       2 n_birth_dt_tm = dq8
       2 o_birth_dt_tm = dq8
       2 n_person_sex_cd = f8
       2 o_person_sex_cd = f8
       2 n_ssn = c15
       2 o_ssn = c15
       2 n_person_type_cd = f8
       2 o_person_type_cd = f8
       2 n_autopsy_cd = f8
       2 o_autopsy_cd = f8
       2 n_conception_dt_tm = dq8
       2 o_conception_dt_tm = dq8
       2 n_cause_of_death = c40
       2 o_cause_of_death = c40
       2 n_deceased_cd = f8
       2 o_deceased_cd = f8
       2 n_deceased_dt_tm = dq8
       2 o_deceased_dt_tm = dq8
       2 n_ethnic_grp_cd = f8
       2 o_ethnic_grp_cd = f8
       2 n_language_cd = f8
       2 o_language_cd = f8
       2 n_marital_type_cd = f8
       2 o_marital_type_cd = f8
       2 n_race_cd = f8
       2 o_race_cd = f8
       2 n_religion_cd = f8
       2 o_religion_cd = f8
       2 n_sex_age_chg_ind_ind = i2
       2 n_sex_age_chg_ind = i2
       2 o_sex_age_chg_ind_ind = i2
       2 o_sex_age_chg_ind = i2
       2 n_lang_dialect_cd = f8
       2 o_lang_dialect_cd = f8
       2 n_species_cd = f8
       2 o_species_cd = f8
       2 n_confid_level_cd = f8
       2 o_confid_level_cd = f8
       2 n_person_vip_cd = f8
       2 o_person_vip_cd = f8
       2 n_citizenship_cd = f8
       2 o_citizenship_cd = f8
       2 n_vet_mil_stat_cd = f8
       2 o_vet_mil_stat_cd = f8
       2 n_mthr_maid_name = c20
       2 o_mthr_maid_name = c20
       2 n_nationality_cd = f8
       2 o_nationality_cd = f8
       2 n_encntr_class_cd = f8
       2 o_encntr_class_cd = f8
       2 n_encntr_type_cd = f8
       2 o_encntr_type_cd = f8
       2 n_encntr_type_class_cd = f8
       2 o_encntr_type_class_cd = f8
       2 n_encntr_status_cd = f8
       2 o_encntr_status_cd = f8
       2 n_pre_reg_dt_tm = dq8
       2 o_pre_reg_dt_tm = dq8
       2 n_pre_reg_prsnl_id = f8
       2 o_pre_reg_prsnl_id = f8
       2 n_reg_dt_tm = dq8
       2 o_reg_dt_tm = dq8
       2 n_reg_prsnl_id = f8
       2 o_reg_prsnl_id = f8
       2 n_est_arrive_dt_tm = dq8
       2 o_est_arrive_dt_tm = dq8
       2 n_est_depart_dt_tm = dq8
       2 o_est_depart_dt_tm = dq8
       2 n_arrive_dt_tm = dq8
       2 o_arrive_dt_tm = dq8
       2 n_depart_dt_tm = dq8
       2 o_depart_dt_tm = dq8
       2 n_admit_type_cd = f8
       2 o_admit_type_cd = f8
       2 n_admit_src_cd = f8
       2 o_admit_src_cd = f8
       2 n_admit_mode_cd = f8
       2 o_admit_mode_cd = f8
       2 n_admit_with_med_cd = f8
       2 o_admit_with_med_cd = f8
       2 n_refer_comment = c40
       2 o_refer_comment = c40
       2 n_disch_disp_cd = f8
       2 o_disch_disp_cd = f8
       2 n_disch_to_loctn_cd = f8
       2 o_disch_to_loctn_cd = f8
       2 n_preadmit_nbr = c20
       2 o_preadmit_nbr = c20
       2 n_preadmit_test_cd = f8
       2 o_preadmit_test_cd = f8
       2 n_readmit_cd = f8
       2 o_readmit_cd = f8
       2 n_accom_cd = f8
       2 o_accom_cd = f8
       2 n_accom_req_cd = f8
       2 o_accom_req_cd = f8
       2 n_alt_result_dest_cd = f8
       2 o_alt_result_dest_cd = f8
       2 n_amb_cond_cd = f8
       2 o_amb_cond_cd = f8
       2 n_courtesy_cd = f8
       2 o_courtesy_cd = f8
       2 n_diet_type_cd = f8
       2 o_diet_type_cd = f8
       2 n_isolation_cd = f8
       2 o_isolation_cd = f8
       2 n_med_service_cd = f8
       2 o_med_service_cd = f8
       2 n_result_dest_cd = f8
       2 o_result_dest_cd = f8
       2 n_encntr_vip_cd = f8
       2 o_encntr_vip_cd = f8
       2 n_encntr_sex_cd = f8
       2 o_encntr_sex_cd = f8
       2 n_disch_dt_tm = dq8
       2 o_disch_dt_tm = dq8
       2 n_guar_type_cd = f8
       2 o_guar_type_cd = f8
       2 n_loc_temp_cd = f8
       2 o_loc_temp_cd = f8
       2 n_reason_for_visit = c40
       2 o_reason_for_visit = c40
       2 n_fin_class_cd = f8
       2 o_fin_class_cd = f8
       2 n_location_cd = f8
       2 o_location_cd = f8
       2 n_loc_facility_cd = f8
       2 o_loc_facility_cd = f8
       2 n_loc_building_cd = f8
       2 o_loc_building_cd = f8
       2 n_loc_nurse_unit_cd = f8
       2 o_loc_nurse_unit_cd = f8
       2 n_loc_room_cd = f8
       2 o_loc_room_cd = f8
       2 n_loc_bed_cd = f8
       2 o_loc_bed_cd = f8
       2 n_admit_doc_name = c30
       2 o_admit_doc_name = c30
       2 n_admit_doc_id = f8
       2 o_admit_doc_id = f8
       2 n_attend_doc_name = c30
       2 o_attend_doc_name = c30
       2 n_attend_doc_id = f8
       2 o_attend_doc_id = f8
       2 n_consult_doc_name = c30
       2 o_consult_doc_name = c30
       2 n_consult_doc_id = f8
       2 o_consult_doc_id = f8
       2 n_refer_doc_name = c30
       2 o_refer_doc_name = c30
       2 n_refer_doc_id = f8
       2 o_refer_doc_id = f8
       2 n_admit_doc_nbr = c16
       2 o_admit_doc_nbr = c16
       2 n_attend_doc_nbr = c16
       2 o_attend_doc_nbr = c16
       2 n_consult_doc_nbr = c16
       2 o_consult_doc_nbr = c16
       2 n_refer_doc_nbr = c16
       2 o_refer_doc_nbr = c16
       2 n_per_home_address_id = f8
       2 o_per_home_address_id = f8
       2 n_per_home_addr_street = c100
       2 o_per_home_addr_street = c100
       2 n_per_home_addr_city = c40
       2 o_per_home_addr_city = c40
       2 n_per_home_addr_state = c20
       2 o_per_home_addr_state = c20
       2 n_per_home_addr_zipcode = c20
       2 o_per_home_addr_zipcode = c20
       2 n_per_bus_address_id = f8
       2 o_per_bus_address_id = f8
       2 n_per_bus_addr_street = c100
       2 o_per_bus_addr_street = c100
       2 n_per_bus_addr_city = c40
       2 o_per_bus_addr_city = c40
       2 n_per_bus_addr_state = c20
       2 o_per_bus_addr_state = c20
       2 n_per_bus_addr_zipcode = c20
       2 o_per_bus_addr_zipcode = c20
       2 n_per_home_phone_id = f8
       2 o_per_home_phone_id = f8
       2 n_per_home_ph_format_cd = f8
       2 o_per_home_ph_format_cd = f8
       2 n_per_home_ph_number = c20
       2 o_per_home_ph_number = c20
       2 n_per_home_ext = c10
       2 o_per_home_ext = c10
       2 n_per_bus_phone_id = f8
       2 o_per_bus_phone_id = f8
       2 n_per_bus_ph_format_cd = f8
       2 o_per_bus_ph_format_cd = f8
       2 n_per_bus_ph_number = c20
       2 o_per_bus_ph_number = c20
       2 n_per_bus_ext = c10
       2 o_per_bus_ext = c10
       2 n_per_home_addr_street2 = c100
       2 o_per_home_addr_street2 = c100
       2 n_per_bus_addr_street2 = c100
       2 o_per_bus_addr_street2 = c100
       2 n_per_home_addr_county = c20
       2 o_per_home_addr_county = c20
       2 n_per_home_addr_country = c20
       2 o_per_home_addr_country = c20
       2 n_per_bus_addr_county = c20
       2 o_per_bus_addr_county = c20
       2 n_per_bus_addr_country = c20
       2 o_per_bus_addr_country = c20
       2 n_encntr_complete_dt_tm = dq8
       2 o_encntr_complete_dt_tm = dq8
       2 n_organization_id = f8
       2 o_organization_id = f8
       2 n_contributor_system_cd = f8
       2 o_contributor_system_cd = f8
       2 hl7_event = c10
       2 n_assign_to_loc_dt_tm = dq8
       2 o_assign_to_loc_dt_tm = dq8
       2 n_alt_lvl_care_cd = f8
       2 o_alt_lvl_care_cd = f8
       2 n_program_service_cd = f8
       2 o_program_service_cd = f8
       2 n_specialty_unit_cd = f8
       2 o_specialty_unit_cd = f8
       2 n_birth_tz = i4
       2 o_birth_tz = i4
       2 abs_n_birth_dt_tm = dq8
       2 abs_o_birth_dt_tm = dq8
       2 n_service_category_cd = f8
       2 o_service_category_cd = f8
   )
   FREE RECORD pm_ens_transaction_rep
   RECORD pm_ens_transaction_rep(
     1 trans
       2 transaction_id = f8
       2 pm_hist_tracking_id = f8
       2 activity_dt_tm = dq8
       2 transaction_dt_tm = dq8
       2 transaction = c4
       2 n_person_id = f8
       2 o_person_id = f8
       2 n_encntr_id = f8
       2 o_encntr_id = f8
       2 n_encntr_fin_id = f8
       2 o_encntr_fin_id = f8
       2 n_mrn = c20
       2 o_mrn = c20
       2 n_fin_nbr = c20
       2 o_fin_nbr = c20
       2 n_name_last = c20
       2 o_name_last = c20
       2 n_name_first = c20
       2 o_name_first = c20
       2 n_name_middle = c20
       2 o_name_middle = c20
       2 n_name_formatted = c30
       2 o_name_formatted = c30
       2 n_birth_dt_cd = f8
       2 o_birth_dt_cd = f8
       2 n_birth_dt_tm = dq8
       2 o_birth_dt_tm = dq8
       2 n_person_sex_cd = f8
       2 o_person_sex_cd = f8
       2 n_ssn = c15
       2 o_ssn = c15
       2 n_person_type_cd = f8
       2 o_person_type_cd = f8
       2 n_autopsy_cd = f8
       2 o_autopsy_cd = f8
       2 n_conception_dt_tm = dq8
       2 o_conception_dt_tm = dq8
       2 n_cause_of_death = c40
       2 o_cause_of_death = c40
       2 n_deceased_cd = f8
       2 o_deceased_cd = f8
       2 n_deceased_dt_tm = dq8
       2 o_deceased_dt_tm = dq8
       2 n_ethnic_grp_cd = f8
       2 o_ethnic_grp_cd = f8
       2 n_language_cd = f8
       2 o_language_cd = f8
       2 n_marital_type_cd = f8
       2 o_marital_type_cd = f8
       2 n_race_cd = f8
       2 o_race_cd = f8
       2 n_religion_cd = f8
       2 o_religion_cd = f8
       2 n_sex_age_chg_ind_ind = i2
       2 n_sex_age_chg_ind = i2
       2 o_sex_age_chg_ind_ind = i2
       2 o_sex_age_chg_ind = i2
       2 n_lang_dialect_cd = f8
       2 o_lang_dialect_cd = f8
       2 n_species_cd = f8
       2 o_species_cd = f8
       2 n_confid_level_cd = f8
       2 o_confid_level_cd = f8
       2 n_person_vip_cd = f8
       2 o_person_vip_cd = f8
       2 n_citizenship_cd = f8
       2 o_citizenship_cd = f8
       2 n_vet_mil_stat_cd = f8
       2 o_vet_mil_stat_cd = f8
       2 n_mthr_maid_name = c20
       2 o_mthr_maid_name = c20
       2 n_nationality_cd = f8
       2 o_nationality_cd = f8
       2 n_encntr_class_cd = f8
       2 o_encntr_class_cd = f8
       2 n_encntr_type_cd = f8
       2 o_encntr_type_cd = f8
       2 n_encntr_type_class_cd = f8
       2 o_encntr_type_class_cd = f8
       2 n_encntr_status_cd = f8
       2 o_encntr_status_cd = f8
       2 n_pre_reg_dt_tm = dq8
       2 o_pre_reg_dt_tm = dq8
       2 n_pre_reg_prsnl_id = f8
       2 o_pre_reg_prsnl_id = f8
       2 n_reg_dt_tm = dq8
       2 o_reg_dt_tm = dq8
       2 n_reg_prsnl_id = f8
       2 o_reg_prsnl_id = f8
       2 n_est_arrive_dt_tm = dq8
       2 o_est_arrive_dt_tm = dq8
       2 n_est_depart_dt_tm = dq8
       2 o_est_depart_dt_tm = dq8
       2 n_arrive_dt_tm = dq8
       2 o_arrive_dt_tm = dq8
       2 n_depart_dt_tm = dq8
       2 o_depart_dt_tm = dq8
       2 n_admit_type_cd = f8
       2 o_admit_type_cd = f8
       2 n_admit_src_cd = f8
       2 o_admit_src_cd = f8
       2 n_admit_mode_cd = f8
       2 o_admit_mode_cd = f8
       2 n_admit_with_med_cd = f8
       2 o_admit_with_med_cd = f8
       2 n_refer_comment = c40
       2 o_refer_comment = c40
       2 n_disch_disp_cd = f8
       2 o_disch_disp_cd = f8
       2 n_disch_to_loctn_cd = f8
       2 o_disch_to_loctn_cd = f8
       2 n_preadmit_nbr = c20
       2 o_preadmit_nbr = c20
       2 n_preadmit_test_cd = f8
       2 o_preadmit_test_cd = f8
       2 n_readmit_cd = f8
       2 o_readmit_cd = f8
       2 n_accom_cd = f8
       2 o_accom_cd = f8
       2 n_accom_req_cd = f8
       2 o_accom_req_cd = f8
       2 n_alt_result_dest_cd = f8
       2 o_alt_result_dest_cd = f8
       2 n_amb_cond_cd = f8
       2 o_amb_cond_cd = f8
       2 n_courtesy_cd = f8
       2 o_courtesy_cd = f8
       2 n_diet_type_cd = f8
       2 o_diet_type_cd = f8
       2 n_isolation_cd = f8
       2 o_isolation_cd = f8
       2 n_med_service_cd = f8
       2 o_med_service_cd = f8
       2 n_result_dest_cd = f8
       2 o_result_dest_cd = f8
       2 n_encntr_vip_cd = f8
       2 o_encntr_vip_cd = f8
       2 n_encntr_sex_cd = f8
       2 o_encntr_sex_cd = f8
       2 n_disch_dt_tm = dq8
       2 o_disch_dt_tm = dq8
       2 n_guar_type_cd = f8
       2 o_guar_type_cd = f8
       2 n_loc_temp_cd = f8
       2 o_loc_temp_cd = f8
       2 n_reason_for_visit = c40
       2 o_reason_for_visit = c40
       2 n_fin_class_cd = f8
       2 o_fin_class_cd = f8
       2 n_location_cd = f8
       2 o_location_cd = f8
       2 n_loc_facility_cd = f8
       2 o_loc_facility_cd = f8
       2 n_loc_building_cd = f8
       2 o_loc_building_cd = f8
       2 n_loc_nurse_unit_cd = f8
       2 o_loc_nurse_unit_cd = f8
       2 n_loc_room_cd = f8
       2 o_loc_room_cd = f8
       2 n_loc_bed_cd = f8
       2 o_loc_bed_cd = f8
       2 n_admit_doc_name = c30
       2 o_admit_doc_name = c30
       2 n_admit_doc_id = f8
       2 o_admit_doc_id = f8
       2 n_attend_doc_name = c30
       2 o_attend_doc_name = c30
       2 n_attend_doc_id = f8
       2 o_attend_doc_id = f8
       2 n_consult_doc_name = c30
       2 o_consult_doc_name = c30
       2 n_consult_doc_id = f8
       2 o_consult_doc_id = f8
       2 n_refer_doc_name = c30
       2 o_refer_doc_name = c30
       2 n_refer_doc_id = f8
       2 o_refer_doc_id = f8
       2 n_admit_doc_nbr = c16
       2 o_admit_doc_nbr = c16
       2 n_attend_doc_nbr = c16
       2 o_attend_doc_nbr = c16
       2 n_consult_doc_nbr = c16
       2 o_consult_doc_nbr = c16
       2 n_refer_doc_nbr = c16
       2 o_refer_doc_nbr = c16
       2 n_per_home_address_id = f8
       2 o_per_home_address_id = f8
       2 n_per_home_addr_street = c100
       2 o_per_home_addr_street = c100
       2 n_per_home_addr_city = c40
       2 o_per_home_addr_city = c40
       2 n_per_home_addr_state = c20
       2 o_per_home_addr_state = c20
       2 n_per_home_addr_zipcode = c20
       2 o_per_home_addr_zipcode = c20
       2 n_per_bus_address_id = f8
       2 o_per_bus_address_id = f8
       2 n_per_bus_addr_street = c100
       2 o_per_bus_addr_street = c100
       2 n_per_bus_addr_city = c40
       2 o_per_bus_addr_city = c40
       2 n_per_bus_addr_state = c20
       2 o_per_bus_addr_state = c20
       2 n_per_bus_addr_zipcode = c20
       2 o_per_bus_addr_zipcode = c20
       2 n_per_home_phone_id = f8
       2 o_per_home_phone_id = f8
       2 n_per_home_ph_format_cd = f8
       2 o_per_home_ph_format_cd = f8
       2 n_per_home_ph_number = c20
       2 o_per_home_ph_number = c20
       2 n_per_home_ext = c10
       2 o_per_home_ext = c10
       2 n_per_bus_phone_id = f8
       2 o_per_bus_phone_id = f8
       2 n_per_bus_ph_format_cd = f8
       2 o_per_bus_ph_format_cd = f8
       2 n_per_bus_ph_number = c20
       2 o_per_bus_ph_number = c20
       2 n_per_bus_ext = c10
       2 o_per_bus_ext = c10
       2 n_per_home_addr_street2 = c100
       2 o_per_home_addr_street2 = c100
       2 n_per_bus_addr_street2 = c100
       2 o_per_bus_addr_street2 = c100
       2 n_per_home_addr_county = c20
       2 o_per_home_addr_county = c20
       2 n_per_home_addr_country = c20
       2 o_per_home_addr_country = c20
       2 n_per_bus_addr_county = c20
       2 o_per_bus_addr_county = c20
       2 n_per_bus_addr_country = c20
       2 o_per_bus_addr_country = c20
       2 n_encntr_complete_dt_tm = dq8
       2 o_encntr_complete_dt_tm = dq8
       2 n_organization_id = f8
       2 o_organization_id = f8
       2 n_contributor_system_cd = f8
       2 o_contributor_system_cd = f8
       2 n_assign_to_loc_dt_tm = dq8
       2 o_assign_to_loc_dt_tm = dq8
       2 n_alt_lvl_care_cd = f8
       2 o_alt_lvl_care_cd = f8
       2 n_program_service_cd = f8
       2 o_program_service_cd = f8
       2 n_specialty_unit_cd = f8
       2 o_specialty_unit_cd = f8
       2 n_birth_tz = i4
       2 o_birth_tz = i4
       2 abs_n_birth_dt_tm = dq8
       2 abs_o_birth_dt_tm = dq8
       2 n_service_category_cd = f8
       2 o_service_category_cd = f8
       2 output_dest_cd = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET pm_ens_transaction_req->transaction_id = reply->transaction_info_qual[index].transaction_id
   SET pm_ens_transaction_req->pm_hist_tracking_id = reply->transaction_info_qual[index].
   pm_hist_tracking_id
   SET pm_ens_transaction_req->transaction = acm_request->transaction_info_qual[index].transaction
   SET pm_ens_transaction_req->transaction_dt_tm = acm_request->transaction_info_qual[index].
   transaction_dt_tm
   SET pm_ens_transaction_req->transaction_reason = acm_request->transaction_info_qual[index].
   transaction_reason
   SET pm_ens_transaction_req->transaction_reason_cd = acm_request->transaction_info_qual[index].
   transaction_reason_cd
   IF ((acm_request->transaction_info_qual[index].person_id > 0.0))
    SET pm_ens_transaction_req->person_id = acm_request->transaction_info_qual[index].person_id
   ELSEIF ((acm_request->transaction_info_qual[index].person_idx > 0))
    SET pm_ens_transaction_req->person_id = reply->person_qual[acm_request->transaction_info_qual[
    index].person_idx].person_id
   ELSE
    SET reply->transaction_info_qual[index].status = attribute_error
    GO TO exit_script
   ENDIF
   IF ((acm_request->transaction_info_qual[index].encntr_id > 0.0))
    SET pm_ens_transaction_req->encntr_id = acm_request->transaction_info_qual[index].encntr_id
   ELSEIF ((acm_request->transaction_info_qual[index].encntr_idx > 0))
    SET pm_ens_transaction_req->encntr_id = reply->encounter_qual[acm_request->transaction_info_qual[
    index].encntr_idx].encntr_id
   ENDIF
   SET pm_ens_transaction_req->task_number = reqinfo->updt_task
   EXECUTE pm_ens_transaction  WITH replace("REQUEST","PM_ENS_TRANSACTION_REQ"), replace("REPLY",
    "PM_ENS_TRANSACTION_REP")
 ENDFOR
 SUBROUTINE getpersonnamedata(x)
   SELECT DISTINCT INTO "nl:"
    pn.person_id
    FROM person_name pn
    WHERE expand(t1,f_val,t_val,pn.person_name_id,acm_request->person_name_qual[t1].person_name_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,pn.person_name_id,acm_request->person_name_qual[t1].person_name_id,
      max_val)
     IF ((acm_request->person_name_qual[t2].person_id=0)
      AND (acm_request->person_name_qual[t2].person_name_id != 0))
      stat = changed_entity_map("A",pn.person_id,"PERSON")
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpersonaliasdata(x)
   SELECT DISTINCT INTO "nl:"
    pa.person_id
    FROM person_alias pa
    WHERE expand(t1,f_val,t_val,pa.person_alias_id,acm_request->person_alias_qual[t1].person_alias_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,pa.person_alias_id,acm_request->person_alias_qual[t1].
      person_alias_id,
      max_val)
     IF ((acm_request->person_alias_qual[t2].person_id=0)
      AND (acm_request->person_alias_qual[t2].person_alias_id != 0))
      stat = changed_entity_map("A",pa.person_id,"PERSON")
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpersonorgreltndata(x)
   SELECT INTO "nl:"
    por.person_id
    FROM person_org_reltn por
    WHERE expand(t1,f_val,t_val,por.person_org_reltn_id,acm_request->person_org_reltn_qual[t1].
     person_org_reltn_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,por.person_org_reltn_id,acm_request->person_org_reltn_qual[t1].
      person_org_reltn_id,
      max_val)
     IF ((acm_request->person_org_reltn_qual[t2].person_id=0)
      AND (acm_request->person_org_reltn_qual[t2].person_org_reltn_id != 0))
      stat = changed_entity_map("A",por.person_id,"PERSON")
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getphonedata(x)
   SELECT DISTINCT INTO "nl:"
    ph.parent_entity_id
    FROM phone ph
    WHERE expand(t1,f_val,t_val,ph.phone_id,acm_request->phone_qual[t1].phone_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,ph.phone_id,acm_request->phone_qual[t1].phone_id,
      max_val)
     IF ((acm_request->phone_qual[t2].action_flag != add_action)
      AND (acm_request->phone_qual[t2].phone_id != 0)
      AND ph.parent_entity_name IN ("PERSON", "PERSON_PATIENT"))
      stat = changed_entity_map("A",ph.parent_entity_id,"PERSON")
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getaddressdata(x)
   SELECT DISTINCT INTO "nl:"
    a.parent_entity_id
    FROM address a
    WHERE expand(t1,f_val,t_val,a.address_id,acm_request->address_qual[t1].address_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,a.address_id,acm_request->address_qual[t1].address_id,
      max_val)
     IF ((acm_request->address_qual[t2].action_flag != add_action)
      AND (acm_request->address_qual[t2].address_id != 0)
      AND a.parent_entity_name="PERSON")
      stat = changed_entity_map("A",a.parent_entity_id,"PERSON")
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpersonprsnlreltndata(x)
   SELECT INTO "nl:"
    ppr.person_id
    FROM person_prsnl_reltn ppr
    WHERE expand(t1,f_val,t_val,ppr.person_prsnl_reltn_id,acm_request->person_prsnl_reltn_qual[t1].
     person_prsnl_reltn_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,ppr.person_prsl_reltn_id,acm_request->person_prsnl_reltn_qual[t1].
      person_prsnl_reltn_id,
      max_val)
     IF ((acm_request->person_prsnl_reltn_qual[t2].person_id=0)
      AND (acm_request->person_prsnl_reltn_qual[t2].person_prsnl_reltn_id != 0))
      stat = changed_entity_map("A",ppr.person_id,"PERSON")
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpersonpersonreltndata(x)
   SELECT INTO "nl:"
    ppr.person_id
    FROM person_person_reltn ppr
    WHERE expand(t1,f_val,t_val,ppr.person_person_reltn_id,acm_request->person_person_reltn_qual[t1].
     person_person_reltn_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,ppr.person_person_reltn_id,acm_request->person_person_reltn_qual[
      t1].person_person_reltn_id,
      max_val)
     IF ((acm_request->person_person_reltn_qual[t2].person_id=0)
      AND (acm_request->person_person_reltn_qual[t2].person_person_reltn_id != 0))
      stat = changed_entity_map("A",ppr.person_id,"PERSON")
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpersonplanreltndata(x)
   SELECT INTO "nl:"
    ppr.person_id
    FROM person_plan_reltn ppr
    WHERE expand(t1,f_val,t_val,ppr.person_plan_reltn_id,acm_request->person_plan_reltn_qual[t1].
     person_plan_reltn_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,ppr.person_plan_reltn_id,acm_request->person_plan_reltn_qual[t1].
      person_plan_reltn_id,
      max_val)
     IF ((acm_request->person_plan_reltn_qual[t2].person_id=0)
      AND (acm_request->person_plan_reltn_qual[t2].person_plan_reltn_id != 0))
      stat = changed_entity_map("A",ppr.person_id,"PERSON")
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpersoncodevaluerdata(x)
   SELECT INTO "nl:"
    pcr.person_id
    FROM person_code_value_r pcr
    WHERE expand(t1,f_val,t_val,pcr.person_code_value_r_id,acm_request->person_code_value_r_qual[t1].
     person_code_value_r_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,pcr.person_code_value_r_id,acm_request->person_code_value_r_qual[
      t1].person_code_value_r_id,
      max_val)
     IF ((acm_request->person_code_value_r_qual[t2].person_id=0)
      AND (acm_request->person_code_value_r_qual[t2].person_code_value_r_id != 0))
      stat = changed_entity_map("A",pcr.person_id,"PERSON")
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpersonrxplanreltndata(x)
   SELECT INTO "nl:"
    prr.person_id
    FROM person_rx_plan_reltn prr
    WHERE expand(t1,f_val,t_val,prr.person_rx_plan_reltn_id,acm_request->person_rx_plan_reltn_qual[t1
     ].person_rx_plan_reltn_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,prr.person_rx_plan_reltn_id,acm_request->
      person_rx_plan_reltn_qual[t1].person_rx_plan_reltn_id,
      max_val)
     IF ((acm_request->person_rx_plan_reltn_qual[t2].person_id=0)
      AND (acm_request->person_rx_plan_reltn_qual[t2].person_rx_plan_reltn_id != 0))
      stat = changed_entity_map("A",prr.person_id,"PERSON")
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF (curcclver >= 81206)
  SET modify = norecmemberset
 ENDIF
 IF (call_echo_ind)
  CALL echorecord(request)
  CALL echorecord(reply)
  CALL echo(curcclver)
 ENDIF
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = true
 ENDIF
END GO
