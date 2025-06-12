CREATE PROGRAM djh_l_encounter
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  en.accommodation_cd, en_accommodation_disp = uar_get_code_display(en.accommodation_cd), en
  .accommodation_reason_cd,
  en_accommodation_reason_disp = uar_get_code_display(en.accommodation_reason_cd), en
  .accommodation_request_cd, en_accommodation_request_disp = uar_get_code_display(en
   .accommodation_request_cd),
  en.accomp_by_cd, en_accomp_by_disp = uar_get_code_display(en.accomp_by_cd), en.active_ind,
  en.active_status_cd, en_active_status_disp = uar_get_code_display(en.active_status_cd), en
  .active_status_dt_tm,
  en.active_status_prsnl_id, en.admit_mode_cd, en_admit_mode_disp = uar_get_code_display(en
   .admit_mode_cd),
  en.admit_src_cd, en_admit_src_disp = uar_get_code_display(en.admit_src_cd), en.admit_type_cd,
  en_admit_type_disp = uar_get_code_display(en.admit_type_cd), en.admit_with_medication_cd,
  en_admit_with_medication_disp = uar_get_code_display(en.admit_with_medication_cd),
  en.alc_decomp_dt_tm, en.alc_reason_cd, en_alc_reason_disp = uar_get_code_display(en.alc_reason_cd),
  en.alt_lvl_care_cd, en_alt_lvl_care_disp = uar_get_code_display(en.alt_lvl_care_cd), en
  .alt_lvl_care_dt_tm,
  en.alt_result_dest_cd, en_alt_result_dest_disp = uar_get_code_display(en.alt_result_dest_cd), en
  .ambulatory_cond_cd,
  en_ambulatory_cond_disp = uar_get_code_display(en.ambulatory_cond_cd), en.archive_dt_tm_act, en
  .archive_dt_tm_est,
  en.arrive_dt_tm, en.assign_to_loc_dt_tm, en.bbd_procedure_cd,
  en_bbd_procedure_disp = uar_get_code_display(en.bbd_procedure_cd), en.beg_effective_dt_tm, en
  .birth_dt_cd,
  en_birth_dt_disp = uar_get_code_display(en.birth_dt_cd), en.birth_dt_tm, en.chart_complete_dt_tm,
  en.confid_level_cd, en_confid_level_disp = uar_get_code_display(en.confid_level_cd), en
  .contract_status_cd,
  en_contract_status_disp = uar_get_code_display(en.contract_status_cd), en.contributor_system_cd,
  en_contributor_system_disp = uar_get_code_display(en.contributor_system_cd),
  en.courtesy_cd, en_courtesy_disp = uar_get_code_display(en.courtesy_cd), en.create_dt_tm,
  en.create_prsnl_id, en.data_status_cd, en_data_status_disp = uar_get_code_display(en.data_status_cd
   ),
  en.data_status_dt_tm, en.data_status_prsnl_id, en.depart_dt_tm,
  en.diet_type_cd, en_diet_type_disp = uar_get_code_display(en.diet_type_cd), en.disch_disposition_cd,
  en_disch_disposition_disp = uar_get_code_display(en.disch_disposition_cd), en.disch_dt_tm, en
  .disch_to_loctn_cd,
  en_disch_to_loctn_disp = uar_get_code_display(en.disch_to_loctn_cd), en.doc_rcvd_dt_tm, en
  .encntr_class_cd,
  en_encntr_class_disp = uar_get_code_display(en.encntr_class_cd), en.encntr_complete_dt_tm, en
  .encntr_financial_id,
  en.encntr_id, en.encntr_status_cd, en_encntr_status_disp = uar_get_code_display(en.encntr_status_cd
   ),
  en.encntr_type_cd, en_encntr_type_disp = uar_get_code_display(en.encntr_type_cd), en
  .encntr_type_class_cd,
  en_encntr_type_class_disp = uar_get_code_display(en.encntr_type_class_cd), en.end_effective_dt_tm,
  en.est_arrive_dt_tm,
  en.est_depart_dt_tm, en.est_length_of_stay, en.financial_class_cd,
  en_financial_class_disp = uar_get_code_display(en.financial_class_cd), en.guarantor_type_cd,
  en_guarantor_type_disp = uar_get_code_display(en.guarantor_type_cd),
  en.info_given_by, en.inpatient_admit_dt_tm, en.isolation_cd,
  en_isolation_disp = uar_get_code_display(en.isolation_cd), en.location_cd, en_location_disp =
  uar_get_code_display(en.location_cd),
  en.loc_bed_cd, en_loc_bed_disp = uar_get_code_display(en.loc_bed_cd), en.loc_building_cd,
  en_loc_building_disp = uar_get_code_display(en.loc_building_cd), en.loc_facility_cd,
  en_loc_facility_disp = uar_get_code_display(en.loc_facility_cd),
  en.loc_nurse_unit_cd, en_loc_nurse_unit_disp = uar_get_code_display(en.loc_nurse_unit_cd), en
  .loc_room_cd,
  en_loc_room_disp = uar_get_code_display(en.loc_room_cd), en.loc_temp_cd, en_loc_temp_disp =
  uar_get_code_display(en.loc_temp_cd),
  en.med_service_cd, en_med_service_disp = uar_get_code_display(en.med_service_cd), en
  .mental_category_cd,
  en_mental_category_disp = uar_get_code_display(en.mental_category_cd), en.mental_health_cd,
  en_mental_health_disp = uar_get_code_display(en.mental_health_cd),
  en.mental_health_dt_tm, en.name_first, en.name_first_key,
  en.name_first_synonym_id, en.name_full_formatted, en.name_last,
  en.name_last_key, en.name_phonetic, en.organization_id,
  en.parent_ret_criteria_id, en.patient_classification_cd, en_patient_classification_disp =
  uar_get_code_display(en.patient_classification_cd),
  en.pa_current_status_cd, en_pa_current_status_disp = uar_get_code_display(en.pa_current_status_cd),
  en.pa_current_status_dt_tm,
  en.person_id, en.placement_auth_prsnl_id, en.preadmit_nbr,
  en.preadmit_testing_cd, en_preadmit_testing_disp = uar_get_code_display(en.preadmit_testing_cd), en
  .pre_reg_dt_tm,
  en.pre_reg_prsnl_id, en.program_service_cd, en_program_service_disp = uar_get_code_display(en
   .program_service_cd),
  en.psychiatric_status_cd, en_psychiatric_status_disp = uar_get_code_display(en
   .psychiatric_status_cd), en.purge_dt_tm_act,
  en.purge_dt_tm_est, en.readmit_cd, en_readmit_disp = uar_get_code_display(en.readmit_cd),
  en.reason_for_visit, en.referral_rcvd_dt_tm, en.referring_comment,
  en.refer_facility_cd, en_refer_facility_disp = uar_get_code_display(en.refer_facility_cd), en
  .region_cd,
  en_region_disp = uar_get_code_display(en.region_cd), en.reg_dt_tm, en.reg_prsnl_id,
  en.result_accumulation_dt_tm, en.result_dest_cd, en_result_dest_disp = uar_get_code_display(en
   .result_dest_cd),
  en.rowid, en.safekeeping_cd, en_safekeeping_disp = uar_get_code_display(en.safekeeping_cd),
  en.security_access_cd, en_security_access_disp = uar_get_code_display(en.security_access_cd), en
  .service_category_cd,
  en_service_category_disp = uar_get_code_display(en.service_category_cd), en.sex_cd, en_sex_disp =
  uar_get_code_display(en.sex_cd),
  en.sitter_required_cd, en_sitter_required_disp = uar_get_code_display(en.sitter_required_cd), en
  .specialty_unit_cd,
  en_specialty_unit_disp = uar_get_code_display(en.specialty_unit_cd), en.species_cd, en_species_disp
   = uar_get_code_display(en.species_cd),
  en.trauma_cd, en_trauma_disp = uar_get_code_display(en.trauma_cd), en.trauma_dt_tm,
  en.triage_cd, en_triage_disp = uar_get_code_display(en.triage_cd), en.triage_dt_tm,
  en.updt_applctx, en.updt_cnt, en.updt_dt_tm,
  en.updt_id, en.updt_task, en.valuables_cd,
  en_valuables_disp = uar_get_code_display(en.valuables_cd), en.vip_cd, en_vip_disp =
  uar_get_code_display(en.vip_cd),
  en.visitor_status_cd, en_visitor_status_disp = uar_get_code_display(en.visitor_status_cd), en
  .zero_balance_dt_tm
  FROM encounter en
  WITH maxrec = 10, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
