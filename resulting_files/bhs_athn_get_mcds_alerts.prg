CREATE PROGRAM bhs_athn_get_mcds_alerts
 FREE RECORD result
 RECORD result(
   1 incoming_orders_cnt = i4
   1 error_message = vc
   1 interruption_pref_satisfied_ind = i2
   1 pref
     2 master_multum_enabled = i2
     2 drug_drug_enabled = i2
     2 drug_food_enabled = i2
     2 drug_allergy_enabled = i2
     2 duplicate_therapy_enabled = i2
     2 check_duplicate_against_orderable = i2
     2 check_duplicate_against_order_status = i2
     2 drug_drug_severity_level = i2
     2 drug_food_severity_level = i2
     2 drug_drug_interruption = i2
     2 drug_food_interruption = i2
     2 drug_allergy_interruption = i2
     2 duplicate_therapy_interruption = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD output
 RECORD output(
   1 status = c1
   1 drug_drug_alerts[*]
     2 cki = vc
     2 name = vc
     2 subject_order_id = vc
     2 subject_catalog_cd = vc
     2 causing_order_id = vc
     2 causing_catalog_cd = vc
     2 audit_uid = vc
     2 description = vc
     2 severity = vc
     2 medication = vc
     2 order_details = vc
     2 order_status = vc
     2 order_status_dt_tm = vc
     2 interaction_information = vc
   1 drug_food_alerts[*]
     2 cki = vc
     2 name = vc
     2 subject_order_id = vc
     2 subject_catalog_cd = vc
     2 audit_uid = vc
     2 description = vc
     2 severity = vc
     2 medication = vc
   1 drug_allergy_alerts[*]
     2 cki = vc
     2 name = vc
     2 subject_order_id = vc
     2 subject_catalog_cd = vc
     2 audit_uid = vc
     2 description = vc
     2 allergy_id = vc
     2 nomenclature_id = vc
   1 duplicate_therapy_alerts[*]
     2 name = vc
     2 subject_order_id = vc
     2 subject_catalog_cd = vc
     2 causing_order_id = vc
     2 causing_catalog_cd = vc
     2 audit_uid = vc
     2 description = vc
     2 medication = vc
     2 order_details = vc
     2 order_status = vc
     2 order_status_dt_tm = vc
     2 interaction_information = vc
 ) WITH protect
 FREE RECORD incoming_orders
 RECORD incoming_orders(
   1 list[*]
     2 order_id = f8
     2 synonym_id = f8
     2 seq = i2
 ) WITH protect
 FREE RECORD profile_orders
 RECORD profile_orders(
   1 list[*]
     2 order_id = f8
     2 status_dt_tm = dq8
 ) WITH protect
 FREE RECORD synonyms
 RECORD synonyms(
   1 list[*]
     2 synonym_id = f8
     2 catalog_cd = f8
     2 catalog_disp = vc
     2 synonym_mnemonic = vc
 ) WITH protect
 FREE RECORD allergies
 RECORD allergies(
   1 list[*]
     2 allergy_id = f8
     2 name = vc
 ) WITH protect
 FREE RECORD filtered_alerts
 RECORD filtered_alerts(
   1 list[*]
     2 audit_uid = vc
     2 filter_reason = vc
 ) WITH protect
 FREE RECORD req680400
 RECORD req680400(
   1 user_criteria
     2 user_id = f8
   1 patient_criteria
     2 patient_id = f8
   1 drug_drug_checking
     2 drug_drug_criterias[*]
       3 unique_identifier = vc
       3 subjects[*]
         4 synonym_id = f8
       3 severity_criteria
         4 minor_severity_criteria
           5 minor_severity_ind = i2
           5 severity_details
             6 no_severity_details_ind = i2
             6 contraindicated_ind = i2
             6 generally_avoid_ind = i2
             6 monitor_closely_ind = i2
             6 adjust_dosing_interval_ind = i2
             6 adjust_dose_ind = i2
             6 additional_contraception_ind = i2
             6 monitor_ind = i2
         4 moderate_severity_criteria
           5 moderate_severity_ind = i2
           5 severity_details
             6 no_severity_details_ind = i2
             6 contraindicated_ind = i2
             6 generally_avoid_ind = i2
             6 monitor_closely_ind = i2
             6 adjust_dosing_interval_ind = i2
             6 adjust_dose_ind = i2
             6 additional_contraception_ind = i2
             6 monitor_ind = i2
         4 major_severity_criteria
           5 major_severity_ind = i2
           5 severity_details
             6 no_severity_details_ind = i2
             6 contraindicated_ind = i2
             6 generally_avoid_ind = i2
             6 monitor_closely_ind = i2
             6 adjust_dosing_interval_ind = i2
             6 adjust_dose_ind = i2
             6 additional_contraception_ind = i2
             6 monitor_ind = i2
       3 causes_criteria
         4 check_subjects_ind = i2
         4 retail_interaction_days_ind = i2
         4 retrieve_future_orders_ind = i2
   1 drug_food_checking
     2 drug_food_criterias[*]
       3 unique_identifier = vc
       3 subjects[*]
         4 synonym_id = f8
       3 severity_criteria
         4 minor_severity_criteria
           5 minor_severity_ind = i2
           5 severity_details
             6 no_severity_details_ind = i2
             6 contraindicated_ind = i2
             6 generally_avoid_ind = i2
             6 monitor_closely_ind = i2
             6 adjust_dosing_interval_ind = i2
             6 adjust_dose_ind = i2
             6 additional_contraception_ind = i2
             6 monitor_ind = i2
         4 moderate_severity_criteria
           5 moderate_severity_ind = i2
           5 severity_details
             6 no_severity_details_ind = i2
             6 contraindicated_ind = i2
             6 generally_avoid_ind = i2
             6 monitor_closely_ind = i2
             6 adjust_dosing_interval_ind = i2
             6 adjust_dose_ind = i2
             6 additional_contraception_ind = i2
             6 monitor_ind = i2
         4 major_severity_criteria
           5 major_severity_ind = i2
           5 severity_details
             6 no_severity_details_ind = i2
             6 contraindicated_ind = i2
             6 generally_avoid_ind = i2
             6 monitor_closely_ind = i2
             6 adjust_dosing_interval_ind = i2
             6 adjust_dose_ind = i2
             6 additional_contraception_ind = i2
             6 monitor_ind = i2
   1 drug_allergy_checking
     2 drug_allergy_criterias[*]
       3 unique_identifier = vc
       3 subjects[*]
         4 synonym_id = f8
       3 causes_criteria
         4 excluded_reaction_classes[*]
           5 reaction_class_cd = f8
   1 allergy_drug_checking
     2 allergy_drug_criterias[*]
       3 unique_identifier = vc
       3 subjects[*]
         4 allergy_cki = vc
       3 causes_criteria
         4 retail_interaction_days_ind = i2
         4 retrieve_future_orders_ind = i2
       3 synonym_causes[*]
         4 synonym_id = f8
   1 duplicate_therapy_checking
     2 duplicate_therapy_criterias[*]
       3 unique_identifier = vc
       3 subjects[*]
         4 unique_identifier = vc
         4 synonym_id = f8
         4 venue
           5 prescription_ind = i2
           5 acute_ind = i2
           5 ambulatory_ind = i2
         4 profile_order
           5 order_id = f8
         4 profile_orders[*]
           5 order_id = f8
       3 causes_criteria
         4 check_against_venue_ind = i2
         4 check_subjects_ind = i2
         4 retail_interaction_days_ind = i2
         4 retrieve_future_orders_ind = i2
       3 drug_level_checking_ind = i2
       3 category_level_checking_ind = i2
       3 category_levels
         4 first_level_ind = i2
         4 second_level_ind = i2
         4 third_level_ind = i2
 ) WITH protect
 FREE RECORD rep680400
 RECORD rep680400(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 transaction_uid = vc
   1 drug_drug_checking
     2 drug_drug_criterias
       3 unique_identifier = vc
       3 subjects[*]
         4 synonym_id = f8
         4 cki = vc
         4 status
           5 unknown_not_checked_ind = i2
           5 eligible_not_checked_ind = i2
           5 eligible_partially_checked_ind = i2
           5 eligible_fully_checked_ind = i2
           5 not_eligible_ind = i2
           5 ignored_ind = i2
         4 component_drugs[*]
           5 component_cki = vc
         4 drug_drug_alert
           5 interactions[*]
             6 subject_drug
               7 subject_cki = vc
               7 name = vc
             6 causing_drug
               7 causing_cki = vc
               7 name = vc
               7 profile_orders[*]
                 8 order_id = f8
                 8 catalog_cd = f8
               7 subject_synonyms[*]
                 8 synonym_id = f8
               7 parent_causing_cki = vc
             6 interaction_description = vc
             6 severity
               7 minor_ind = i2
               7 moderate_ind = i2
               7 major_ind = i2
               7 severity_details
                 8 contraindicated_ind = i2
                 8 generally_avoid_ind = i2
                 8 monitor_closely_ind = i2
                 8 adjust_dosing_interval_ind = i2
                 8 adjust_dose_ind = i2
                 8 additional_contraception_ind = i2
                 8 monitor_ind = i2
             6 audit_uid = vc
   1 drug_food_checking
     2 drug_food_criterias[*]
       3 unique_identifier = vc
       3 subjects[*]
         4 synonym_id = f8
         4 cki = vc
         4 status
           5 unknown_not_checked_ind = i2
           5 eligible_not_checked_ind = i2
           5 eligible_partially_checked_ind = i2
           5 eligible_fully_checked_ind = i2
           5 not_eligible_ind = i2
           5 ignored_ind = i2
         4 component_drugs[*]
           5 component_cki = vc
         4 drug_food_alert
           5 interactions[*]
             6 subject_drug[*]
               7 subject_cki = vc
               7 name = vc
             6 interaction_description = vc
             6 severity[*]
               7 minor_ind = i2
               7 moderate_ind = i2
               7 major_ind = i2
               7 severity_details
                 8 contraindicated_ind = i2
                 8 generally_avoid_ind = i2
                 8 monitor_closely_ind = i2
                 8 adjust_dosing_interval_ind = i2
                 8 adjust_dose_ind = i2
                 8 additional_contraception_ind = i2
                 8 monitor_ind = i2
             6 audit_uid = vc
   1 drug_allergy_checking
     2 drug_allergy_criterias[*]
       3 unique_identifier = vc
       3 subjects[*]
         4 synonym_id = f8
         4 cki = vc
         4 status
           5 unknown_not_checked_ind = i2
           5 eligible_not_checked_ind = i2
           5 eligible_partially_checked_ind = i2
           5 eligible_fully_checked_ind = i2
           5 not_eligible_ind = i2
           5 ignored_ind = i2
         4 component_drugs[*]
           5 component_cki = vc
         4 drug_allergy_alert
           5 interactions[*]
             6 subject_drug
               7 subject_cki = vc
               7 drug_name = vc
               7 category_name = vc
               7 category_name_plural = vc
               7 class_name = vc
             6 causing_allergy
               7 causing_cki = vc
               7 allergies[*]
                 8 allergy_id = f8
                 8 nomenclature_id = f8
               7 drug_name = vc
               7 category_name = vc
               7 category_name_plural = vc
               7 class_name = vc
             6 interaction_description = vc
             6 interaction_type
               7 drug_ind = i2
               7 category_ind = i2
               7 class_ind = i2
             6 audit_uid = vc
   1 allergy_drug_checking
     2 allergy_drug_criterias[*]
       3 unique_identifier = vc
       3 subjects[*]
         4 allergy_cki = vc
         4 status
           5 unknown_not_checked_ind = i2
           5 eligible_not_checked_ind = i2
           5 eligible_partially_checked_ind = i2
           5 eligible_fully_checked_ind = i2
           5 not_eligible_ind = i2
           5 ignored_ind = i2
         4 component_drugs[*]
           5 component_cki = vc
         4 allergy_drug_alert
           5 interactions[*]
             6 subject_allergy[*]
               7 subject_cki = vc
               7 drug_name = vc
               7 category_name = vc
               7 category_name_plural = vc
               7 class_name = vc
             6 causing_drug
               7 causing_cki = vc
               7 profile_orders[*]
                 8 order_id = f8
                 8 catalog_cd = f8
               7 drug_name = vc
               7 category_name = vc
               7 category_name_plural = vc
               7 class_name = vc
               7 parent_causing_cki = vc
               7 synonym_causes[*]
                 8 synonym_id = f8
             6 interaction_description = vc
             6 interaction_type
               7 drug_ind = i2
               7 category_ind = i2
               7 class_ind = i2
             6 audit_uid = vc
   1 duplicate_therapy_checking
     2 duplicate_therapy_criterias[*]
       3 unique_identifier = vc
       3 subjects[*]
         4 unique_identifier = vc
         4 synonym_id = f8
         4 cki = vc
         4 status
           5 unknown_not_checked_ind = i2
           5 eligible_not_checked_ind = i2
           5 eligible_partially_checked_ind = i2
           5 eligible_fully_checked_ind = i2
           5 not_eligible_ind = i2
           5 ignored_ind = i2
         4 component_drugs[*]
           5 component_cki = vc
         4 drug_duplications[*]
           5 subject_drug
             6 subject_cki = vc
             6 name = vc
           5 maximum_allowed_occurrences = i2
           5 observed_occurrences = i2
           5 causing_drug
             6 profile_orders[*]
               7 order_id = f8
               7 catalog_cd = f8
             6 subject_synonyms[*]
               7 synonym_id = f8
               7 unique_identifier = vc
           5 audit_uid = vc
         4 category_duplications[*]
           5 subject_drug
             6 subject_cki = vc
             6 name = vc
           5 maximum_allowed_occurrences = i2
           5 observed_occurrences = i2
           5 causing_drugs[*]
             6 causing_cki = vc
             6 name = vc
             6 profile_orders[*]
               7 order_id = f8
               7 catalog_cd = f8
             6 subject_synonyms[*]
               7 synonym_id = f8
               7 unique_identifier = vc
           5 category_name = vc
           5 category_level
             6 first_level_ind = i2
             6 second_level_ind = i2
             6 third_level_ind = i2
           5 audit_uid = vc
 ) WITH protect
 FREE RECORD req680204
 RECORD req680204(
   1 orders[*]
     2 order_id = f8
   1 load_indicators
     2 order_indicators
       3 comment_types
         4 load_order_comment_ind = i2
         4 load_administration_note_ind = i2
       3 review_information_criteria
         4 load_review_status_ind = i2
         4 load_renewal_notification_ind = i2
       3 order_set_info_criteria
         4 load_core_ind = i2
         4 load_name_ind = i2
       3 supergroup_info_criteria
         4 load_core_ind = i2
         4 load_components_ind = i2
       3 load_linked_order_info_ind = i2
       3 care_plan_info_criteria
         4 load_core_ind = i2
         4 load_extended_ind = i2
       3 diagnosis_info_criteria
         4 load_core_ind = i2
         4 load_extended_ind = i2
       3 load_encounter_information_ind = i2
       3 load_pending_status_info_ind = i2
       3 load_venue_ind = i2
       3 load_order_schedule_ind = i2
       3 load_order_ingredients_ind = i2
       3 load_last_action_info_ind = i2
       3 load_extended_attributes_ind = i2
       3 load_order_proposal_info_ind = i2
       3 order_relation_criteria
         4 load_core_ind = i2
       3 appointment_criteria
         4 load_core_ind = i2
       3 therapeutic_substitution
         4 load_accepted_ind = i2
       3 accession_criteria
         4 load_core_ind = i2
       3 load_last_populated_action_ind = i2
       3 clinical_intervention_criteria
         4 load_pharmacy_ind = i2
       3 protocol_criteria
         4 load_core_ind = i2
       3 day_of_treatment_criteria
         4 load_extended_ind = i2
       3 load_order_status_reasons_ind = i2
       3 load_referral_information_ind = i2
       3 load_filtered_resp_provider_ind = i2
   1 mnemonic_criteria
     2 load_mnemonic_ind = i2
     2 simple_build_type
       3 reference_ind = i2
       3 reference_clinical_ind = i2
       3 reference_clinical_dept_ind = i2
       3 reference_department_ind = i2
     2 medication_criteria
       3 build_order_level_ind = i2
       3 build_ingredient_level_ind = i2
       3 complex_build_type
         4 reference_ind = i2
         4 clinical_ind = i2
 ) WITH protect
 FREE RECORD rep680204
 RECORD rep680204(
   1 orders[*]
     2 core
       3 order_id = f8
       3 patient_id = f8
       3 version = i4
       3 order_status_cd = f8
       3 department_status_cd = f8
       3 responsible_provider_id = f8
       3 action_sequence = i4
       3 source_cd = f8
       3 future_facility_id = f8
       3 future_nurse_unit_id = f8
     2 encounter
       3 encounter_id = f8
       3 encounter_type_class_cd = f8
       3 encounter_facility_id = f8
     2 displays
       3 reference_name = vc
       3 clinical_name = vc
       3 department_name = vc
       3 clinical_display_line = vc
       3 simplified_display_line = vc
     2 comments
       3 comments_exist
         4 order_comment_ind = i2
         4 mar_note_ind = i2
       3 order_comment = vc
       3 administration_note = vc
     2 schedule
       3 current_start_dt_tm = dq8
       3 current_start_tz = i4
       3 projected_stop_dt_tm = dq8
       3 projected_stop_tz = i4
       3 stop_type_cd = f8
       3 original_order_dt_tm = dq8
       3 original_order_tz = i4
       3 valid_dose_dt_tm = dq8
       3 prn_ind = i2
       3 constant_ind = i2
       3 frequency
         4 frequency_id = f8
         4 one_time_ind = i2
         4 time_of_day_ind = i2
         4 day_of_week_ind = i2
         4 interval_ind = i2
         4 unscheduled_ind = i2
       3 clinically_relevant_dt_tm = dq8
       3 clinically_relevant_tz = i4
       3 suspended_dt_tm = dq8
       3 suspended_tz = i4
       3 start_date_estimated_ind = i2
       3 stop_date_estimated_ind = i2
     2 reference_information
       3 catalog_id = f8
       3 synonym_id = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 clinical_category_cd = f8
       3 order_entry_format_id = f8
     2 review_information
       3 pharmacy_verification_status
         4 not_required_ind = i2
         4 required_ind = i2
         4 rejected_ind = i2
       3 physician_cosignature_status
         4 not_required_ind = i2
         4 required_ind = i2
         4 refused_ind = i2
       3 physician_validation_status
         4 not_required_ind = i2
         4 required_ind = i2
         4 refused_ind = i2
       3 need_nurse_review_ind = i2
       3 need_renewal_ind = i2
       3 pharmacy_clin_review_status
         4 unset_ind = i2
         4 needed_ind = i2
         4 completed_ind = i2
         4 rejected_ind = i2
         4 does_not_apply_ind = i2
         4 superceded_ind = i2
     2 pending_status_information
       3 suspend_ind = i2
       3 suspend_effective_dt_tm = dq8
       3 suspend_effective_tz = i4
       3 resume_ind = i2
       3 resume_effective_dt_tm = dq8
       3 resume_effective_tz = i4
       3 discontinue_ind = i2
       3 discontinue_effective_dt_tm = dq8
       3 discontinue_effective_tz = i4
     2 diagnoses[*]
       3 diagnosis_id = f8
       3 nomenclature_id = f8
       3 priority = i4
       3 description = vc
       3 source_vocabulary_cd = f8
     2 medication_information
       3 medication_order_type_cd = f8
       3 originally_ordered_as_type
         4 normal_ind = i2
         4 prescription_ind = i2
         4 documented_ind = i2
         4 patients_own_ind = i2
         4 charge_only_ind = i2
         4 satellite_ind = i2
       3 ingredients[*]
         4 sequence = i4
         4 catalog_id = f8
         4 synonym_id = f8
         4 clinical_name = vc
         4 department_name = vc
         4 dose
           5 strength = f8
           5 strength_unit_cd = f8
           5 volume = f8
           5 volume_unit_cd = f8
           5 freetext = vc
           5 ordered = f8
           5 ordered_unit_cd = f8
           5 adjustment_display = vc
         4 ingredient_type
           5 unknown_ind = i2
           5 medication_ind = i2
           5 additive_ind = i2
           5 diluent_ind = i2
           5 compound_parent_ind = i2
           5 compound_child_ind = i2
         4 clinically_significant_info
           5 unknown_ind = i2
           5 not_significant_ind = i2
           5 significant_ind = i2
       3 pharmacy_type
         4 sliding_scale_ind = i2
       3 therapeutic_substitution
         4 accepted_ind = i2
         4 accepted_alternate_regimen_ind = i2
         4 overridden_ind = i2
       3 iv_set_synonym_id = f8
       3 prescription
         4 group_id = f8
       3 dosing_method_type
         4 normal_ind = i2
         4 variable_ind = i2
       3 pharmacy_interventions[*]
         4 form_activity_id = f8
         4 last_update_personnel_id = f8
         4 last_update_dt_tm = dq8
         4 task_status_cd = f8
     2 last_action_information
       3 action_personnel_id = f8
       3 action_dt_tm = dq8
       3 action_tz = i4
     2 template_information
       3 template_order_id = f8
       3 template_none_ind = i2
       3 template_order_ind = i2
       3 order_instance_ind = i2
       3 pharmacy_instance_ind = i2
       3 future_recurring_template_ind = i2
       3 future_recurring_instance_ind = i2
       3 task_instance_ind = i2
       3 protocol_order_ind = i2
     2 order_set_information
       3 parent_ind = i2
       3 child_ind = i2
       3 parent_id = f8
       3 parent_name = vc
     2 supergroup_information
       3 parent_ind = i2
       3 child_ind = i2
       3 parent_id = f8
       3 components[*]
         4 order_id = f8
         4 department_status_cd = f8
     2 care_plan_information
       3 care_plan_catalog_id = f8
       3 name = vc
       3 treatment_period_stop_dt_tm = dq8
       3 treatment_period_stop_tz = i4
       3 component
         4 min_tolerance_interval = i4
         4 min_tolerance_interval_unit_cd = f8
       3 patient_mismatch_ind = i2
     2 link_information
       3 link_number = f8
       3 and_link_ind = i2
     2 venue
       3 acute_ind = i2
       3 ambulatory_ind = i2
       3 prescription_ind = i2
       3 unknown_ind = i2
     2 extended
       3 consulting_providers[*]
         4 consulting_provider_id = f8
       3 end_state_reason_cd = f8
       3 patient_pregnant_ind = i2
       3 send_results_to_phys_only_ind = i2
       3 carbon_copied_providers[*]
         4 carbon_copied_provider_id = f8
     2 pending_order_proposal_info
       3 order_proposal_id = f8
       3 source_type_cd = f8
     2 order_relations[*]
       3 order_id = f8
       3 action_sequence = i4
       3 relation_type_cd = f8
     2 appointment
       3 appointment_id = f8
       3 appointment_state_cd = f8
     2 order_mnemonic
       3 mnemonic = vc
       3 may_be_truncated_ind = i2
     2 laboratory_information
       3 accessions[*]
         4 identifier = vc
     2 radiology_information
       3 accessions[*]
         4 identifier = vc
     2 last_populated_action
       3 order_location_id = f8
     2 day_of_treatment_information
       3 protocol_order_id = f8
       3 day_of_treatment_sequence = i4
       3 protocol_type
         4 unknown_ind = i2
         4 powerplan_managed_oncology_ind = i2
         4 future_recurring_ind = i2
     2 warnings[*]
       3 warning_type
         4 protocol_patient_mismatch_ind = i2
     2 protocol_information
       3 protocol_type
         4 unknown_ind = i2
         4 powerplan_managed_oncology_ind = i2
         4 future_recurring_ind = i2
     2 order_status_reasons
       3 incomplete_status_reasons[*]
         4 no_synonym_match_ind = i2
         4 missing_order_details_ind = i2
     2 referral_information
       3 referred_to_provider_id = f8
       3 referred_to_freetext_provider = vc
       3 reason_for_referral = vc
     2 filtered_responsible_provider
       3 provider_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callperformclinicalchecking(null) = i4
 DECLARE checkinterruptionpreferences(null) = i4
 DECLARE getorderdata(null) = i4
 DECLARE getallergydata(null) = i4
 DECLARE parseincomingordersparam(null) = i4
 DECLARE setpreferences(null) = i4
 DECLARE formatdataforoutput(null) = i4
 DECLARE performalertfiltering(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE severity_level_non = i4 WITH protect, constant(0)
 DECLARE severity_level_minor = i4 WITH protect, constant(1)
 DECLARE severity_level_moderate = i4 WITH protect, constant(2)
 DECLARE severity_level_major = i4 WITH protect, constant(3)
 DECLARE severity_level_no_literature = i4 WITH protect, constant(4)
 DECLARE severity_level_major_contraindicated = i4 WITH protect, constant(5)
 DECLARE interruption_severity_level_minor = i4 WITH protect, constant(0)
 DECLARE interruption_severity_level_moderate = i4 WITH protect, constant(1)
 DECLARE interruption_severity_level_major = i4 WITH protect, constant(2)
 DECLARE interruption_severity_level_never = i4 WITH protect, constant(3)
 DECLARE interruption_severity_level_major_contraindicated = i4 WITH protect, constant(4)
 DECLARE check_duplicate_against_orderable_single_drug = i4 WITH protect, constant(0)
 DECLARE check_duplicate_against_orderable_category = i4 WITH protect, constant(1)
 DECLARE check_duplicate_against_orderable_single_drug_and_category = i4 WITH protect, constant(2)
 DECLARE check_duplicate_against_order_status_new_only = i4 WITH protect, constant(0)
 DECLARE check_duplicate_against_order_status_profile_only = i4 WITH protect, constant(1)
 DECLARE check_duplicate_against_order_status_new_and_profile = i4 WITH protect, constant(2)
 DECLARE check_duplicate_against_order_status_new_exclude_same_cki = i4 WITH protect, constant(3)
 DECLARE check_duplicate_against_order_status_new_exclude_same_cki_and_profile = i4 WITH protect,
 constant(4)
 DECLARE not_applicable = vc WITH protect, constant("N/A")
 DECLARE order_status_new = vc WITH protect, constant("Order")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE kdx = i4 WITH protect, noconstant(0)
 DECLARE ldx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE ordercnt = i4 WITH protect, noconstant(0)
 DECLARE syncnt = i4 WITH protect, noconstant(0)
 DECLARE filtercnt = i4 WITH protect, noconstant(0)
 DECLARE allergycnt = i4 WITH protect, noconstant(0)
 DECLARE order_status_dt_tm = dq8 WITH protect, noconstant(0.0)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (size(trim( $4,3)) <= 0)
  CALL echo("INVALID INCOMING ORDERS PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = setpreferences(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = parseincomingordersparam(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->incoming_orders_cnt = size(incoming_orders->list,5)
 IF ((result->incoming_orders_cnt < 1))
  CALL echo("NO ORDERS FOUND...CHECK ORDERS PARAMETER FOR ERRORS")
  GO TO exit_script
 ENDIF
 SET stat = callperformclinicalchecking(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = performalertfiltering(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = checkinterruptionpreferences(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF ((result->interruption_pref_satisfied_ind=1))
  SET stat = getorderdata(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
  SET stat = getallergydata(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET result->status_data.status = "S"
 SET stat = formatdataforoutput(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
#exit_script
 IF (size(trim(moutputdevice,3)) > 0)
  FREE RECORD req680400
  FREE RECORD rep680400
  FREE RECORD req680204
  FREE RECORD rep680204
  FREE RECORD orders
  FREE RECORD profile_orders
  FREE RECORD synonyms
  FREE RECORD allergies
  FREE RECORD filtered_alerts
  IF (validate(_memory_reply_string))
   SET _memory_reply_string = cnvtrectojson(output)
  ELSE
   CALL echojson(output,moutputdevice)
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req680400
 FREE RECORD rep680400
 FREE RECORD req680204
 FREE RECORD rep680204
 FREE RECORD orders
 FREE RECORD profile_orders
 FREE RECORD synonyms
 FREE RECORD allergies
 FREE RECORD filtered_alerts
 FREE RECORD output
 SUBROUTINE setpreferences(null)
   SET result->pref.master_multum_enabled = cnvtint( $5)
   SET result->pref.drug_drug_enabled = cnvtint( $6)
   SET result->pref.drug_food_enabled = cnvtint( $7)
   SET result->pref.drug_allergy_enabled = cnvtint( $8)
   SET result->pref.duplicate_therapy_enabled = cnvtint( $9)
   SET result->pref.check_duplicate_against_orderable = cnvtint( $10)
   SET result->pref.check_duplicate_against_order_status = cnvtint( $11)
   SET result->pref.drug_drug_severity_level = cnvtint( $12)
   SET result->pref.drug_food_severity_level = cnvtint( $13)
   SET result->pref.drug_drug_interruption = cnvtint( $14)
   SET result->pref.drug_food_interruption = cnvtint( $15)
   SET result->pref.drug_allergy_interruption = cnvtint( $16)
   SET result->pref.duplicate_therapy_interruption = cnvtint( $17)
   RETURN(success)
 END ;Subroutine
 SUBROUTINE parseincomingordersparam(null)
   DECLARE ordersparam = vc WITH protect, noconstant("")
   DECLARE blockcnt = i4 WITH protect, noconstant(0)
   DECLARE startpos = i4 WITH protect, noconstant(0)
   DECLARE endpos = i4 WITH protect, noconstant(0)
   DECLARE param = vc WITH protect, noconstant("")
   DECLARE block = vc WITH protect, noconstant("")
   DECLARE fieldcnt = i4 WITH protect, noconstant(0)
   DECLARE fieldcntvalidind = i2 WITH protect, noconstant(0)
   DECLARE orderid = f8 WITH protect, noconstant(0.0)
   SET startpos = 1
   SET ordersparam = trim( $4,3)
   FREE RECORD ordersparamrec
   RECORD ordersparamrec(
     1 list[*]
       2 block = vc
   ) WITH protect
   WHILE (size(ordersparam) > 0)
     SET endpos = (findstring("|",ordersparam,1) - 1)
     IF (endpos <= 0)
      SET endpos = size(ordersparam)
     ENDIF
     CALL echo(build("ENDPOS:",endpos))
     IF (startpos < endpos)
      SET param = substring(1,endpos,ordersparam)
      CALL echo(build("PARAM:",param))
      IF (size(param) > 0)
       SET param = replace(param,"-!pipe!-","|",0)
       CALL echo(build("ADDING FIELD TO BLOCKLIST: ",param))
       SET blockcnt += 1
       CALL echo(build("BLOCKCNT:",blockcnt))
       SET stat = alterlist(ordersparamrec->list,blockcnt)
       SET ordersparamrec->list[blockcnt].block = param
      ENDIF
     ENDIF
     SET ordersparam = substring((endpos+ 2),(size(ordersparam) - endpos),ordersparam)
     CALL echo(build("ORDERSPARAM:",ordersparam))
     CALL echo(build("SIZE(ORDERSPARAM):",size(ordersparam)))
   ENDWHILE
   SET stat = alterlist(incoming_orders->list,blockcnt)
   FOR (idx = 1 TO blockcnt)
     SET block = ordersparamrec->list[idx].block
     SET fieldcnt = 0
     SET startpos = 0
     IF (((idx=1) OR (fieldcntvalidind=1)) )
      SET fieldcntvalidind = 0
      WHILE (size(block) > 0)
        IF (substring(1,1,block)=";")
         SET endpos = 1
         SET param = ""
        ELSE
         SET endpos = (findstring(";",block,1) - 1)
         IF (endpos <= 0)
          SET endpos = size(block)
         ENDIF
         SET param = substring(1,endpos,block)
        ENDIF
        CALL echo(build("ENDPOS:",endpos))
        CALL echo(build("PARAM:",param))
        IF (startpos < endpos)
         SET param = replace(param,"ltscolgt",";",0)
         CALL echo(build("ADDING FIELD TO ORDERSPARAMREC LIST: ",param))
         SET fieldcnt += 1
         CALL echo(build("FIELDCNT:",fieldcnt))
         IF (size(param) > 0
          AND fieldcnt=1)
          SET incoming_orders->list[idx].seq = 0
          SET orderid = cnvtreal(param)
          SET pos = locateval(locidx,1,blockcnt,orderid,incoming_orders->list[locidx].order_id)
          IF (pos > 0)
           SET incoming_orders->list[idx].seq += 1
          ENDIF
          WHILE (pos > 0)
           SET pos = locateval(locidx,(pos+ 1),blockcnt,orderid,incoming_orders->list[locidx].
            order_id)
           IF (pos > 0)
            SET incoming_orders->list[idx].seq += 1
           ENDIF
          ENDWHILE
          SET incoming_orders->list[idx].order_id = orderid
         ELSEIF (size(param) > 0
          AND fieldcnt=2)
          SET incoming_orders->list[idx].synonym_id = cnvtreal(param)
          SET fieldcntvalidind = 1
         ELSEIF (fieldcnt > 2)
          CALL echorecord(ordersparamrec)
          CALL echo("INVALID NUMBER OF FIELDS (TOO MANY)...EXITING")
          CALL echo(
           "CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
          GO TO exit_script
         ENDIF
        ENDIF
        IF (size(trim(param,3)) > 0)
         SET block = substring((endpos+ 2),(size(block) - endpos),block)
        ELSE
         SET block = substring(2,(size(block) - 1),block)
        ENDIF
        CALL echo(build("BLOCK:",block))
        CALL echo(size(block))
      ENDWHILE
     ENDIF
   ENDFOR
   CALL echorecord(incoming_orders)
   IF (fieldcntvalidind=0)
    CALL echo("INVALID NUMBER OF FIELDS (TOO FEW)...EXITING")
    CALL echo("CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE callperformclinicalchecking(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(600060)
   DECLARE requestid = i4 WITH constant(680400)
   IF ((((result->pref.master_multum_enabled=0)) OR ((result->pref.drug_drug_enabled=0)
    AND (result->pref.drug_allergy_enabled=0)
    AND (result->pref.drug_food_enabled=0)
    AND (result->pref.duplicate_therapy_enabled=0))) )
    CALL echo(
     "CLINICAL CHECKING SERVER CALL IS NOT NECESSARY DUE TO MULTUM CHECKING PREFERENCES BEING DISABLED"
     )
    RETURN(success)
   ENDIF
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET req680400->user_criteria.user_id =  $3
   SET req680400->patient_criteria.patient_id =  $2
   IF ((result->pref.drug_drug_enabled=1))
    SET stat = alterlist(req680400->drug_drug_checking.drug_drug_criterias,1)
    SET req680400->drug_drug_checking.drug_drug_criterias[1].unique_identifier =
    "INTERACTION_DRUGDRUG"
    SET stat = alterlist(req680400->drug_drug_checking.drug_drug_criterias[1].subjects,result->
     incoming_orders_cnt)
    FOR (idx = 1 TO result->incoming_orders_cnt)
      SET req680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].synonym_id =
      incoming_orders->list[idx].synonym_id
    ENDFOR
    IF ((((result->pref.drug_drug_severity_level=severity_level_non)) OR ((result->pref.
    drug_drug_severity_level=severity_level_no_literature))) )
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.minor_severity_ind = 0
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.moderate_severity_ind = 0
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.major_severity_ind = 0
    ELSEIF ((result->pref.drug_drug_severity_level=severity_level_minor))
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.minor_severity_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.monitor_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.moderate_severity_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.monitor_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.major_severity_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_ind = 1
    ELSEIF ((result->pref.drug_drug_severity_level=severity_level_moderate))
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.minor_severity_ind = 0
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.moderate_severity_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.monitor_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.major_severity_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_ind = 1
    ELSEIF ((result->pref.drug_drug_severity_level=severity_level_major))
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.minor_severity_ind = 0
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.moderate_severity_ind = 0
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.major_severity_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_ind = 1
    ELSEIF ((result->pref.drug_drug_severity_level=severity_level_major_contraindicated))
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     minor_severity_criteria.minor_severity_ind = 0
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     moderate_severity_criteria.moderate_severity_ind = 0
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.major_severity_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_drug_checking.drug_drug_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.contraindicated_ind = 1
    ENDIF
    SET req680400->drug_drug_checking.drug_drug_criterias[1].causes_criteria.check_subjects_ind = 1
    SET req680400->drug_drug_checking.drug_drug_criterias[1].causes_criteria.
    retrieve_future_orders_ind = 0
   ENDIF
   IF ((result->pref.drug_allergy_enabled=1))
    SET stat = alterlist(req680400->drug_allergy_checking.drug_allergy_criterias,1)
    SET req680400->drug_allergy_checking.drug_allergy_criterias[1].unique_identifier =
    "INTERACTION_DRUGALLERGY"
    SET stat = alterlist(req680400->drug_allergy_checking.drug_allergy_criterias[1].subjects,result->
     incoming_orders_cnt)
    FOR (idx = 1 TO result->incoming_orders_cnt)
      SET req680400->drug_allergy_checking.drug_allergy_criterias[1].subjects[idx].synonym_id =
      incoming_orders->list[idx].synonym_id
    ENDFOR
   ENDIF
   IF ((result->pref.duplicate_therapy_enabled=1))
    SET stat = alterlist(req680400->duplicate_therapy_checking.duplicate_therapy_criterias,1)
    SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].unique_identifier =
    "INTERACTION_DUPTHERAPY"
    SET stat = alterlist(req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
     subjects,result->incoming_orders_cnt)
    FOR (idx = 1 TO result->incoming_orders_cnt)
      SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
      unique_identifier = concat("ORDERID_",trim(cnvtstring(incoming_orders->list[idx].order_id),3),
       ".000000_",trim(cnvtstring(incoming_orders->list[idx].seq),3))
      SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
      synonym_id = incoming_orders->list[idx].synonym_id
      SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].venue.
      acute_ind = 1
      SET stat = alterlist(req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
       subjects[idx].profile_orders,1)
      SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
      profile_orders[1].order_id = incoming_orders->list[idx].order_id
    ENDFOR
    SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].causes_criteria.
    check_against_venue_ind = 1
    SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].causes_criteria.
    check_subjects_ind = 1
    SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].causes_criteria.
    retrieve_future_orders_ind = 1
    IF ((result->pref.check_duplicate_against_orderable=check_duplicate_against_orderable_single_drug
    ))
     SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].drug_level_checking_ind
      = 1
    ELSEIF ((result->pref.check_duplicate_against_orderable=
    check_duplicate_against_orderable_category))
     SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
     category_level_checking_ind = 1
     SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].category_levels.
     first_level_ind = 1
    ELSEIF ((result->pref.check_duplicate_against_orderable=
    check_duplicate_against_orderable_single_drug_and_category))
     SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].drug_level_checking_ind
      = 1
     SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
     category_level_checking_ind = 1
     SET req680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].category_levels.
     first_level_ind = 1
    ENDIF
   ENDIF
   IF ((result->pref.drug_food_enabled=1))
    SET stat = alterlist(req680400->drug_food_checking.drug_food_criterias,1)
    SET req680400->drug_food_checking.drug_food_criterias[1].unique_identifier =
    "INTERACTION_DRUGFOOD"
    SET stat = alterlist(req680400->drug_food_checking.drug_food_criterias[1].subjects,result->
     incoming_orders_cnt)
    FOR (idx = 1 TO result->incoming_orders_cnt)
      SET req680400->drug_food_checking.drug_food_criterias[1].subjects[idx].synonym_id =
      incoming_orders->list[idx].synonym_id
    ENDFOR
    IF ((((result->pref.drug_food_severity_level=severity_level_non)) OR ((result->pref.
    drug_food_severity_level=severity_level_no_literature))) )
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.minor_severity_ind = 0
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.moderate_severity_ind = 0
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.major_severity_ind = 0
    ELSEIF ((result->pref.drug_food_severity_level=severity_level_minor))
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.minor_severity_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.severity_details.monitor_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.moderate_severity_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.monitor_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.major_severity_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_ind = 1
    ELSEIF ((result->pref.drug_food_severity_level=severity_level_moderate))
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.minor_severity_ind = 0
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.moderate_severity_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.severity_details.monitor_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.major_severity_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_ind = 1
    ELSEIF ((result->pref.drug_food_severity_level=severity_level_major))
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     minor_severity_criteria.minor_severity_ind = 0
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     moderate_severity_criteria.moderate_severity_ind = 0
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.major_severity_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.no_severity_details_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.contraindicated_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.generally_avoid_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_closely_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dosing_interval_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.adjust_dose_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.additional_contraception_ind = 1
     SET req680400->drug_food_checking.drug_food_criterias[1].severity_criteria.
     major_severity_criteria.severity_details.monitor_ind = 1
    ENDIF
   ENDIF
   CALL echorecord(req680400)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req680400,
    "REC",rep680400,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep680400)
   IF ((rep680400->transaction_status.success_ind=1))
    RETURN(success)
   ELSE
    SET result->error_message = rep680400->transaction_status.debug_error_message
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE performalertfiltering(null)
   IF (size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
     subjects,5))
     FOR (jdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
      subjects[idx].drug_duplications,5))
       IF ((((result->check_duplicate_against_order_status=
       check_duplicate_against_order_status_new_only)) OR ((result->
       check_duplicate_against_order_status=check_duplicate_against_order_status_new_exclude_same_cki
       ))) )
        IF (size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
         drug_duplications[jdx].causing_drug.profile_orders,5) > 0)
         SET filtercnt += 1
         SET stat = alterlist(filtered_alerts->list,filtercnt)
         SET filtered_alerts->list[filtercnt].audit_uid = rep680400->duplicate_therapy_checking.
         duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].audit_uid
         SET filtered_alerts->list[filtercnt].filter_reason =
         "CAUSING DRUG IS PROFILE ORDER WHILE CHECK_DUPLICATE_AGAINST_ORDER_STATUS IS SET TO NEW ONLY"
        ENDIF
       ELSEIF ((result->check_duplicate_against_order_status=
       check_duplicate_against_order_status_profile_only))
        IF (size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
         drug_duplications[jdx].causing_drug.profile_orders,5)=0
         AND size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
         drug_duplications[jdx].causing_drug.subject_synonyms,5) > 0)
         SET filtercnt += 1
         SET stat = alterlist(filtered_alerts->list,filtercnt)
         SET filtered_alerts->list[filtercnt].audit_uid = rep680400->duplicate_therapy_checking.
         duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].audit_uid
         SET filtered_alerts->list[filtercnt].filter_reason =
         "CAUSING DRUG IS NEW ORDER WHILE CHECK_DUPLICATE_AGAINST_ORDER_STATUS IS SET TO PROFILE ONLY"
        ENDIF
       ENDIF
     ENDFOR
     FOR (jdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
      subjects[idx].category_duplications,5))
       FOR (kdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
        subjects[idx].category_duplications[jdx].causing_drugs,5))
         IF ((((result->check_duplicate_against_order_status=
         check_duplicate_against_order_status_new_only)) OR ((result->
         check_duplicate_against_order_status=
         check_duplicate_against_order_status_new_exclude_same_cki))) )
          IF (size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx]
           .category_duplications[jdx].causing_drugs[kdx].profile_orders,5) > 0)
           SET filtercnt += 1
           SET stat = alterlist(filtered_alerts->list,filtercnt)
           SET filtered_alerts->list[filtercnt].audit_uid = rep680400->duplicate_therapy_checking.
           duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].audit_uid
           SET filtered_alerts->list[filtercnt].filter_reason =
           "CAUSING DRUG IS PROFILE ORDER WHILE CHECK_DUPLICATE_AGAINST_ORDER_STATUS IS SET TO NEW ONLY"
          ENDIF
         ELSEIF ((result->check_duplicate_against_order_status=
         check_duplicate_against_order_status_profile_only))
          IF (size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx]
           .category_duplications[jdx].causing_drugs[kdx].profile_orders,5)=0
           AND size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx
           ].category_duplications[jdx].causing_drugs[kdx].subject_synonyms,5) > 0)
           SET filtercnt += 1
           SET stat = alterlist(filtered_alerts->list,filtercnt)
           SET filtered_alerts->list[filtercnt].audit_uid = rep680400->duplicate_therapy_checking.
           duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].audit_uid
           SET filtered_alerts->list[filtercnt].filter_reason =
           "CAUSING DRUG IS NEW ORDER WHILE CHECK_DUPLICATE_AGAINST_ORDER_STATUS IS SET TO PROFILE ONLY"
          ENDIF
         ENDIF
       ENDFOR
     ENDFOR
    ENDFOR
   ENDIF
   CALL echorecord(filtered_alerts)
   RETURN(success)
 END ;Subroutine
 SUBROUTINE checkinterruptionpreferences(null)
   SET result->interruption_pref_satisfied_ind = 0
   IF ((result->pref.drug_drug_interruption != interruption_severity_level_never)
    AND (result->interruption_pref_satisfied_ind=0)
    AND size(rep680400->drug_drug_checking.drug_drug_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects,5))
      FOR (jdx = 1 TO size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
       drug_drug_alert.interactions,5))
       SET pos = locateval(locidx,1,filtercnt,rep680400->drug_drug_checking.drug_drug_criterias[1].
        subjects[idx].drug_drug_alert.interactions[jdx].audit_uid,filtered_alerts->list[locidx].
        audit_uid)
       IF (pos=0)
        IF ((result->pref.drug_drug_interruption=interruption_severity_level_minor)
         AND (((rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.
        interactions[jdx].severity.minor_ind=1)) OR ((((rep680400->drug_drug_checking.
        drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].severity.moderate_ind=
        1)) OR ((rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.
        interactions[jdx].severity.major_ind=1))) )) )
         SET result->interruption_pref_satisfied_ind = 1
        ELSEIF ((result->pref.drug_drug_interruption=interruption_severity_level_moderate)
         AND (((rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.
        interactions[jdx].severity.moderate_ind=1)) OR ((rep680400->drug_drug_checking.
        drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].severity.major_ind=1)
        )) )
         SET result->interruption_pref_satisfied_ind = 1
        ELSEIF ((result->pref.drug_drug_interruption=interruption_severity_level_major)
         AND (rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.
        interactions[jdx].severity.major_ind=1))
         SET result->interruption_pref_satisfied_ind = 1
        ELSEIF ((result->pref.drug_drug_interruption=
        interruption_severity_level_major_contraindicated)
         AND (rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.
        interactions[jdx].severity.major_ind=1)
         AND (rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.
        interactions[jdx].severity.severity_details.contraindicated_ind=1))
         SET result->interruption_pref_satisfied_ind = 1
        ENDIF
       ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((result->pref.drug_food_interruption != interruption_severity_level_never)
    AND (result->interruption_pref_satisfied_ind=0)
    AND size(rep680400->drug_food_checking.drug_food_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->drug_food_checking.drug_food_criterias[1].subjects,5))
      FOR (jdx = 1 TO size(rep680400->drug_food_checking.drug_food_criterias[1].subjects[idx].
       drug_food_alert.interactions,5))
       SET pos = locateval(locidx,1,filtercnt,rep680400->drug_food_checking.drug_food_criterias[1].
        subjects[idx].drug_food_alert.interactions[jdx].audit_uid,filtered_alerts->list[locidx].
        audit_uid)
       IF (pos=0)
        IF ((result->pref.drug_food_interruption=interruption_severity_level_minor)
         AND (((rep680400->drug_food_checking.drug_food_criterias[1].subjects[idx].drug_food_alert.
        interactions[jdx].severity.minor_ind=1)) OR ((((rep680400->drug_food_checking.
        drug_food_criterias[1].subjects[idx].drug_food_alert.interactions[jdx].severity.moderate_ind=
        1)) OR ((rep680400->drug_food_checking.drug_food_criterias[1].subjects[idx].drug_food_alert.
        interactions[jdx].severity.major_ind=1))) )) )
         SET result->interruption_pref_satisfied_ind = 1
        ELSEIF ((result->pref.drug_food_interruption=interruption_severity_level_moderate)
         AND (((rep680400->drug_food_checking.drug_food_criterias[1].subjects[idx].drug_food_alert.
        interactions[jdx].severity.moderate_ind=1)) OR ((rep680400->drug_food_checking.
        drug_food_criterias[1].subjects[idx].drug_food_alert.interactions[jdx].severity.major_ind=1)
        )) )
         SET result->interruption_pref_satisfied_ind = 1
        ELSEIF ((result->pref.drug_food_interruption=interruption_severity_level_major)
         AND (rep680400->drug_food_checking.drug_food_criterias[1].subjects[idx].drug_food_alert.
        interactions[jdx].severity.major_ind=1))
         SET result->interruption_pref_satisfied_ind = 1
        ENDIF
       ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((result->pref.drug_allergy_interruption=1)
    AND (result->interruption_pref_satisfied_ind=0)
    AND size(rep680400->drug_allergy_checking.drug_allergy_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->drug_allergy_checking.drug_allergy_criterias[1].subjects,5))
      FOR (jdx = 1 TO size(rep680400->drug_allergy_checking.drug_allergy_criterias[1].subjects[idx].
       drug_allergy_alert.interactions,5))
       SET pos = locateval(locidx,1,filtercnt,rep680400->drug_allergy_checking.
        drug_allergy_criterias[1].subjects[idx].drug_allergy_alert.interactions[jdx].audit_uid,
        filtered_alerts->list[locidx].audit_uid)
       IF (pos=0)
        SET result->interruption_pref_satisfied_ind = 1
       ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((result->pref.duplicate_therapy_interruption=1)
    AND (result->interruption_pref_satisfied_ind=0)
    AND size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
     subjects,5))
      FOR (jdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
       subjects[idx].drug_duplications,5))
       SET pos = locateval(locidx,1,filtercnt,rep680400->duplicate_therapy_checking.
        duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].audit_uid,filtered_alerts
        ->list[locidx].audit_uid)
       IF (pos=0)
        SET result->interruption_pref_satisfied_ind = 1
       ENDIF
      ENDFOR
    ENDFOR
    IF ((result->interruption_pref_satisfied_ind=0))
     FOR (idx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
      subjects,5))
       FOR (jdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
        subjects[idx].category_duplications,5))
        SET pos = locateval(locidx,1,filtercnt,rep680400->duplicate_therapy_checking.
         duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].audit_uid,
         filtered_alerts->list[locidx].audit_uid)
        IF (pos=0)
         SET result->interruption_pref_satisfied_ind = 1
        ENDIF
       ENDFOR
     ENDFOR
    ENDIF
   ENDIF
   CALL echo(build("RESULT->INTERRUPTION_PREF_SATISFIED_IND:",result->interruption_pref_satisfied_ind
     ))
   RETURN(success)
 END ;Subroutine
 SUBROUTINE getorderdata(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(600060)
   DECLARE requestid = i4 WITH constant(680204)
   IF (size(rep680400->drug_drug_checking.drug_drug_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects,5))
      SET pos = locateval(locidx,1,syncnt,rep680400->drug_drug_checking.drug_drug_criterias[1].
       subjects[idx].synonym_id,synonyms->list[locidx].synonym_id)
      IF (pos=0)
       SET syncnt += 1
       SET stat = alterlist(synonyms->list,syncnt)
       SET synonyms->list[syncnt].synonym_id = rep680400->drug_drug_checking.drug_drug_criterias[1].
       subjects[idx].synonym_id
      ENDIF
      FOR (jdx = 1 TO size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
       drug_drug_alert.interactions,5))
       FOR (kdx = 1 TO size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
        drug_drug_alert.interactions[jdx].causing_drug.profile_orders,5))
        SET pos = locateval(locidx,1,ordercnt,rep680400->drug_drug_checking.drug_drug_criterias[1].
         subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.profile_orders[kdx].order_id,
         profile_orders->list[locidx].order_id)
        IF (pos=0)
         SET ordercnt += 1
         SET stat = alterlist(profile_orders->list,ordercnt)
         SET profile_orders->list[ordercnt].order_id = rep680400->drug_drug_checking.
         drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.
         profile_orders[kdx].order_id
        ENDIF
       ENDFOR
       FOR (kdx = 1 TO size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
        drug_drug_alert.interactions[jdx].causing_drug.subject_synonyms,5))
        SET pos = locateval(locidx,1,syncnt,rep680400->drug_drug_checking.drug_drug_criterias[1].
         subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.subject_synonyms[kdx].
         synonym_id,synonyms->list[locidx].synonym_id)
        IF (pos=0)
         SET syncnt += 1
         SET stat = alterlist(synonyms->list,syncnt)
         SET synonyms->list[syncnt].synonym_id = rep680400->drug_drug_checking.drug_drug_criterias[1]
         .subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.subject_synonyms[kdx].
         synonym_id
        ENDIF
       ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
   IF (size(rep680400->drug_food_checking.drug_food_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->drug_food_checking.drug_food_criterias[1].subjects,5))
     SET pos = locateval(locidx,1,syncnt,rep680400->drug_food_checking.drug_food_criterias[1].
      subjects[idx].synonym_id,synonyms->list[locidx].synonym_id)
     IF (pos=0)
      SET syncnt += 1
      SET stat = alterlist(synonyms->list,syncnt)
      SET synonyms->list[syncnt].synonym_id = rep680400->drug_food_checking.drug_food_criterias[1].
      subjects[idx].synonym_id
     ENDIF
    ENDFOR
   ENDIF
   IF (size(rep680400->drug_allergy_checking.drug_allergy_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->drug_allergy_checking.drug_allergy_criterias[1].subjects,5))
     SET pos = locateval(locidx,1,syncnt,rep680400->drug_allergy_checking.drug_allergy_criterias[1].
      subjects[idx].synonym_id,synonyms->list[locidx].synonym_id)
     IF (pos=0)
      SET syncnt += 1
      SET stat = alterlist(synonyms->list,syncnt)
      SET synonyms->list[syncnt].synonym_id = rep680400->drug_allergy_checking.
      drug_allergy_criterias[1].subjects[idx].synonym_id
     ENDIF
    ENDFOR
   ENDIF
   IF (size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
     subjects,5))
      SET pos = locateval(locidx,1,syncnt,rep680400->duplicate_therapy_checking.
       duplicate_therapy_criterias[1].subjects[idx].synonym_id,synonyms->list[locidx].synonym_id)
      IF (pos=0)
       SET syncnt += 1
       SET stat = alterlist(synonyms->list,syncnt)
       SET synonyms->list[syncnt].synonym_id = rep680400->duplicate_therapy_checking.
       duplicate_therapy_criterias[1].subjects[idx].synonym_id
      ENDIF
      FOR (jdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
       subjects[idx].drug_duplications,5))
       FOR (kdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
        subjects[idx].drug_duplications[jdx].causing_drug.profile_orders,5))
        SET pos = locateval(locidx,1,ordercnt,rep680400->duplicate_therapy_checking.
         duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].causing_drug.
         profile_orders[kdx].order_id,profile_orders->list[locidx].order_id)
        IF (pos=0)
         SET ordercnt += 1
         SET stat = alterlist(profile_orders->list,ordercnt)
         SET profile_orders->list[ordercnt].order_id = rep680400->duplicate_therapy_checking.
         duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].causing_drug.
         profile_orders[kdx].order_id
        ENDIF
       ENDFOR
       FOR (kdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
        subjects[idx].drug_duplications[jdx].causing_drug.subject_synonyms,5))
        SET pos = locateval(locidx,1,syncnt,rep680400->duplicate_therapy_checking.
         duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].causing_drug.
         subject_synonyms[kdx].synonym_id,synonyms->list[locidx].synonym_id)
        IF (pos=0)
         SET syncnt += 1
         SET stat = alterlist(synonyms->list,syncnt)
         SET synonyms->list[syncnt].synonym_id = rep680400->duplicate_therapy_checking.
         duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].causing_drug.
         subject_synonyms[kdx].synonym_id
        ENDIF
       ENDFOR
      ENDFOR
      FOR (jdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
       subjects[idx].category_duplications,5))
        FOR (kdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
         subjects[idx].category_duplications[jdx].causing_drugs,5))
         FOR (ldx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
          subjects[idx].category_duplications[jdx].causing_drugs[kdx].profile_orders,5))
          SET pos = locateval(locidx,1,ordercnt,rep680400->duplicate_therapy_checking.
           duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].causing_drugs[kdx]
           .profile_orders[ldx].order_id,profile_orders->list[locidx].order_id)
          IF (pos=0)
           SET ordercnt += 1
           SET stat = alterlist(profile_orders->list,ordercnt)
           SET profile_orders->list[ordercnt].order_id = rep680400->duplicate_therapy_checking.
           duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].causing_drugs[kdx]
           .profile_orders[ldx].order_id
          ENDIF
         ENDFOR
         FOR (ldx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
          subjects[idx].category_duplications[jdx].causing_drugs[kdx].subject_synonyms,5))
          SET pos = locateval(locidx,1,syncnt,rep680400->duplicate_therapy_checking.
           duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].causing_drugs[kdx]
           .subject_synonyms[ldx].synonym_id,synonyms->list[locidx].synonym_id)
          IF (pos=0)
           SET syncnt += 1
           SET stat = alterlist(synonyms->list,syncnt)
           SET synonyms->list[syncnt].synonym_id = rep680400->duplicate_therapy_checking.
           duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].causing_drugs[kdx]
           .subject_synonyms[ldx].synonym_id
          ENDIF
         ENDFOR
        ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
   IF (syncnt > 0)
    SELECT INTO "NL:"
     FROM order_catalog_synonym ocs
     PLAN (ocs
      WHERE expand(idx,1,syncnt,ocs.synonym_id,synonyms->list[idx].synonym_id))
     HEAD ocs.synonym_id
      pos = locateval(locidx,1,syncnt,ocs.synonym_id,synonyms->list[locidx].synonym_id)
      IF (pos > 0)
       synonyms->list[pos].catalog_cd = ocs.catalog_cd, synonyms->list[pos].catalog_disp =
       uar_get_code_display(ocs.catalog_cd), synonyms->list[pos].synonym_mnemonic = ocs.mnemonic
      ENDIF
     WITH expand = 1, time = 30
    ;end select
   ENDIF
   IF (ordercnt > 0)
    SET stat = alterlist(req680204->orders,ordercnt)
    FOR (idx = 1 TO ordercnt)
      SET req680204->orders[idx].order_id = profile_orders->list[idx].order_id
    ENDFOR
    CALL echorecord(req680204)
    SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req680204,
     "REC",rep680204,1)
    IF (stat > 0)
     SET errcode = error(errmsg,1)
     CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
       errmsg))
     RETURN(fail)
    ENDIF
    CALL echorecord(rep680204)
    IF ((rep680204->status_data.status="S"))
     SELECT INTO "NL:"
      FROM orders o
      PLAN (o
       WHERE expand(idx,1,ordercnt,o.order_id,profile_orders->list[idx].order_id))
      HEAD o.order_id
       pos = locateval(locidx,1,ordercnt,o.order_id,profile_orders->list[locidx].order_id)
       IF (pos > 0)
        profile_orders->list[pos].status_dt_tm = o.status_dt_tm
       ENDIF
      WITH expand = 1, time = 30
     ;end select
     RETURN(success)
    ELSE
     IF (size(rep680204->status_data.subeventstatus,5) > 0)
      SET result->error_message = rep680204->status_data.subeventstatus[1].targetobjectvalue
     ENDIF
    ENDIF
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE getallergydata(null)
   IF (size(rep680400->drug_allergy_checking.drug_allergy_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->drug_allergy_checking.drug_allergy_criterias[1].subjects,5))
      FOR (jdx = 1 TO size(rep680400->drug_allergy_checking.drug_allergy_criterias[1].subjects[idx].
       drug_allergy_alert.interactions,5))
        FOR (kdx = 1 TO size(rep680400->drug_allergy_checking.drug_allergy_criterias[1].subjects[idx]
         .drug_allergy_alert.interactions[jdx].causing_allergy.allergies,5))
         SET pos = locateval(locidx,1,allergycnt,rep680400->drug_allergy_checking.
          drug_allergy_criterias[1].subjects[idx].drug_allergy_alert.interactions[jdx].
          causing_allergy.allergies[kdx].allergy_id,allergies->list[locidx].allergy_id)
         IF (pos=0)
          SET allergycnt += 1
          SET stat = alterlist(allergies->list,allergycnt)
          SET allergies->list[allergycnt].allergy_id = rep680400->drug_allergy_checking.
          drug_allergy_criterias[1].subjects[idx].drug_allergy_alert.interactions[jdx].
          causing_allergy.allergies[kdx].allergy_id
         ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
   IF (allergycnt > 0)
    SELECT INTO "NL:"
     FROM allergy a,
      nomenclature n
     PLAN (a
      WHERE expand(idx,1,allergycnt,a.allergy_id,allergies->list[idx].allergy_id)
       AND ((a.person_id+ 0)= $2)
       AND ((a.active_ind+ 0)=1))
      JOIN (n
      WHERE (n.nomenclature_id= Outerjoin(a.substance_nom_id))
       AND (n.active_ind= Outerjoin(1)) )
     HEAD a.allergy_id
      pos = locateval(locidx,1,allergycnt,a.allergy_id,allergies->list[locidx].allergy_id)
      IF (pos > 0)
       IF (size(trim(a.substance_ftdesc,3)) > 0)
        allergies->list[pos].name = a.substance_ftdesc
       ELSEIF (n.nomenclature_id > 0)
        allergies->list[pos].name = n.source_string
       ELSE
        allergies->list[pos].name = "unknown"
       ENDIF
      ENDIF
     WITH expand = 1, time = 30
    ;end select
   ENDIF
   CALL echorecord(allergies)
   RETURN(success)
 END ;Subroutine
 SUBROUTINE (getseveritydisplay(minor_ind=i2,moderate_ind=i2,major_ind=i2,contraindicated_ind=i2) =vc
  )
   DECLARE severity_disp = vc WITH protect, noconstant("Unknown")
   IF (minor_ind=1)
    SET severity_disp = "Minor"
   ELSEIF (moderate_ind=1)
    SET severity_disp = "Moderate"
   ELSEIF (major_ind=1)
    SET severity_disp = "Major"
   ENDIF
   IF (contraindicated_ind=1)
    SET severity_disp = concat(severity_disp,"-Contraindicated")
   ENDIF
   RETURN(severity_disp)
 END ;Subroutine
 SUBROUTINE formatdataforoutput(null)
   DECLARE drugdrugalertcnt = i4 WITH protect, noconstant(0)
   DECLARE drugfoodalertcnt = i4 WITH protect, noconstant(0)
   DECLARE drugallergyalertcnt = i4 WITH protect, noconstant(0)
   DECLARE duptherapyalertcnt = i4 WITH protect, noconstant(0)
   DECLARE incoming_orders_size = i4 WITH protect, constant(size(incoming_orders->list,5))
   DECLARE synonyms_size = i4 WITH protect, constant(size(synonyms->list,5))
   DECLARE subject_order_id = f8 WITH protect, noconstant(0.0)
   DECLARE subject_catalog_cd = f8 WITH protect, noconstant(0.0)
   DECLARE fltpos = i4 WITH protect, noconstant(0)
   DECLARE audpos = i4 WITH protect, noconstant(0)
   DECLARE ordpos = i4 WITH protect, noconstant(0)
   SET output->status = result->status_data.status
   IF ((result->interruption_pref_satisfied_ind=1)
    AND size(rep680400->drug_drug_checking.drug_drug_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects,5))
      SET pos = locateval(locidx,1,incoming_orders_size,rep680400->drug_drug_checking.
       drug_drug_criterias[1].subjects[idx].synonym_id,incoming_orders->list[locidx].synonym_id)
      IF (pos > 0)
       SET subject_order_id = incoming_orders->list[pos].order_id
      ELSE
       SET subject_order_id = 0.0
      ENDIF
      SET pos = locateval(locidx,1,synonyms_size,rep680400->drug_drug_checking.drug_drug_criterias[1]
       .subjects[idx].synonym_id,synonyms->list[locidx].synonym_id)
      IF (pos > 0)
       SET subject_catalog_cd = synonyms->list[pos].catalog_cd
      ELSE
       SET subject_catalog_cd = 0.0
      ENDIF
      FOR (jdx = 1 TO size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
       drug_drug_alert.interactions,5))
        SET audpos = locateval(locidx,1,drugdrugalertcnt,rep680400->drug_drug_checking.
         drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].audit_uid,output->
         drug_drug_alerts[locidx].audit_uid)
        SET fltpos = locateval(locidx,1,filtercnt,rep680400->drug_drug_checking.drug_drug_criterias[1
         ].subjects[idx].drug_drug_alert.interactions[jdx].audit_uid,filtered_alerts->list[locidx].
         audit_uid)
        IF (audpos=0
         AND fltpos=0)
         IF (size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.
          interactions[jdx].causing_drug.profile_orders,5) > 0)
          FOR (kdx = 1 TO size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
           drug_drug_alert.interactions[jdx].causing_drug.profile_orders,5))
            SET drugdrugalertcnt += 1
            SET stat = alterlist(output->drug_drug_alerts,drugdrugalertcnt)
            SET output->drug_drug_alerts[drugdrugalertcnt].cki = rep680400->drug_drug_checking.
            drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.
            causing_cki
            SET output->drug_drug_alerts[drugdrugalertcnt].name = rep680400->drug_drug_checking.
            drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.name
            SET output->drug_drug_alerts[drugdrugalertcnt].subject_order_id = cnvtstring(
             subject_order_id)
            SET output->drug_drug_alerts[drugdrugalertcnt].subject_catalog_cd = cnvtstring(
             subject_catalog_cd)
            SET output->drug_drug_alerts[drugdrugalertcnt].causing_order_id = cnvtstring(rep680400->
             drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx
             ].causing_drug.profile_orders[kdx].order_id)
            SET output->drug_drug_alerts[drugdrugalertcnt].causing_catalog_cd = cnvtstring(rep680400
             ->drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[
             jdx].causing_drug.profile_orders[kdx].catalog_cd)
            SET output->drug_drug_alerts[drugdrugalertcnt].audit_uid = rep680400->drug_drug_checking.
            drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].audit_uid
            SET output->drug_drug_alerts[drugdrugalertcnt].description = rep680400->
            drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx]
            .interaction_description
            SET output->drug_drug_alerts[drugdrugalertcnt].severity = getseveritydisplay(rep680400->
             drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx
             ].severity.minor_ind,rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
             drug_drug_alert.interactions[jdx].severity.moderate_ind,rep680400->drug_drug_checking.
             drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].severity.
             major_ind,rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
             drug_drug_alert.interactions[jdx].severity.severity_details.contraindicated_ind)
            SET pos = locateval(locidx,1,ordercnt,rep680400->drug_drug_checking.drug_drug_criterias[1
             ].subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.profile_orders[kdx].
             order_id,profile_orders->list[locidx].order_id)
            IF (pos > 0)
             SET order_status_dt_tm = profile_orders->list[pos].status_dt_tm
            ELSE
             SET order_status_dt_tm = 0.0
            ENDIF
            SET pos = locateval(locidx,1,ordercnt,rep680400->drug_drug_checking.drug_drug_criterias[1
             ].subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.profile_orders[kdx].
             order_id,rep680204->orders[locidx].core.order_id)
            IF (pos > 0)
             IF (trim(rep680204->orders[pos].displays.reference_name,3)=trim(rep680204->orders[pos].
              displays.clinical_name,3))
              SET output->drug_drug_alerts[drugdrugalertcnt].medication = rep680204->orders[pos].
              displays.reference_name
             ELSE
              SET output->drug_drug_alerts[drugdrugalertcnt].medication = concat(rep680204->orders[
               pos].displays.reference_name," (",rep680204->orders[pos].displays.clinical_name,")")
             ENDIF
             SET output->drug_drug_alerts[drugdrugalertcnt].order_details = rep680204->orders[pos].
             displays.simplified_display_line
             SET output->drug_drug_alerts[drugdrugalertcnt].order_status = uar_get_code_display(
              rep680204->orders[pos].core.order_status_cd)
             SET output->drug_drug_alerts[drugdrugalertcnt].order_status_dt_tm = evaluate(
              order_status_dt_tm,0,"",format(order_status_dt_tm,"MM/DD/YYYY HH:MM;;D"))
             SET output->drug_drug_alerts[drugdrugalertcnt].interaction_information = cnvtlower(
              concat(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
               drug_drug_alert.interactions[jdx].subject_drug.name,"-",rep680204->orders[pos].
               displays.reference_name))
            ENDIF
          ENDFOR
         ELSEIF (size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
          drug_drug_alert.interactions[jdx].causing_drug.subject_synonyms,5) > 0)
          FOR (kdx = 1 TO size(rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
           drug_drug_alert.interactions[jdx].causing_drug.subject_synonyms,5))
            SET drugdrugalertcnt += 1
            SET stat = alterlist(output->drug_drug_alerts,drugdrugalertcnt)
            SET output->drug_drug_alerts[drugdrugalertcnt].cki = rep680400->drug_drug_checking.
            drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.
            causing_cki
            SET output->drug_drug_alerts[drugdrugalertcnt].name = rep680400->drug_drug_checking.
            drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.name
            SET output->drug_drug_alerts[drugdrugalertcnt].audit_uid = rep680400->drug_drug_checking.
            drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].audit_uid
            SET output->drug_drug_alerts[drugdrugalertcnt].subject_order_id = cnvtstring(
             subject_order_id)
            SET output->drug_drug_alerts[drugdrugalertcnt].subject_catalog_cd = cnvtstring(
             subject_catalog_cd)
            SET pos = locateval(locidx,1,result->incoming_orders_cnt,rep680400->drug_drug_checking.
             drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.
             subject_synonyms[kdx].synonym_id,incoming_orders->list[locidx].synonym_id)
            SET output->drug_drug_alerts[drugdrugalertcnt].causing_order_id = evaluate(pos,0,"",
             cnvtstring(incoming_orders->list[pos].order_id))
            SET output->drug_drug_alerts[drugdrugalertcnt].description = rep680400->
            drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx]
            .interaction_description
            SET output->drug_drug_alerts[drugdrugalertcnt].severity = getseveritydisplay(rep680400->
             drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx
             ].severity.minor_ind,rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
             drug_drug_alert.interactions[jdx].severity.moderate_ind,rep680400->drug_drug_checking.
             drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].severity.
             major_ind,rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].
             drug_drug_alert.interactions[jdx].severity.severity_details.contraindicated_ind)
            SET pos = locateval(locidx,1,syncnt,rep680400->drug_drug_checking.drug_drug_criterias[1].
             subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.subject_synonyms[kdx].
             synonym_id,synonyms->list[locidx].synonym_id)
            IF (pos > 0)
             IF (trim(synonyms->list[pos].catalog_disp,3)=trim(synonyms->list[pos].synonym_mnemonic,3
              ))
              SET output->drug_drug_alerts[drugdrugalertcnt].medication = synonyms->list[pos].
              catalog_disp
             ELSE
              SET output->drug_drug_alerts[drugdrugalertcnt].medication = concat(synonyms->list[pos].
               catalog_disp," (",synonyms->list[pos].synonym_mnemonic,")")
             ENDIF
             SET output->drug_drug_alerts[drugdrugalertcnt].causing_catalog_cd = cnvtstring(synonyms
              ->list[pos].catalog_cd)
            ENDIF
            SET output->drug_drug_alerts[drugdrugalertcnt].order_details = not_applicable
            SET output->drug_drug_alerts[drugdrugalertcnt].order_status = order_status_new
            SET output->drug_drug_alerts[drugdrugalertcnt].order_status_dt_tm = not_applicable
            SET output->drug_drug_alerts[drugdrugalertcnt].interaction_information = cnvtlower(concat
             (rep680400->drug_drug_checking.drug_drug_criterias[1].subjects[idx].drug_drug_alert.
              interactions[jdx].subject_drug.name,"-",rep680400->drug_drug_checking.
              drug_drug_criterias[1].subjects[idx].drug_drug_alert.interactions[jdx].causing_drug.
              name))
          ENDFOR
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((result->interruption_pref_satisfied_ind=1)
    AND size(rep680400->drug_food_checking.drug_food_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->drug_food_checking.drug_food_criterias[1].subjects,5))
      SET pos = locateval(locidx,1,incoming_orders_size,rep680400->drug_food_checking.
       drug_food_criterias[1].subjects[idx].synonym_id,incoming_orders->list[locidx].synonym_id)
      IF (pos > 0)
       SET subject_order_id = incoming_orders->list[pos].order_id
      ELSE
       SET subject_order_id = 0.0
      ENDIF
      SET pos = locateval(locidx,1,synonyms_size,rep680400->drug_food_checking.drug_food_criterias[1]
       .subjects[idx].synonym_id,synonyms->list[locidx].synonym_id)
      IF (pos > 0)
       SET subject_catalog_cd = synonyms->list[pos].catalog_cd
      ELSE
       SET subject_catalog_cd = 0.0
      ENDIF
      FOR (jdx = 1 TO size(rep680400->drug_food_checking.drug_food_criterias[1].subjects[idx].
       drug_food_alert.interactions,5))
        SET audpos = locateval(locidx,1,drugfoodalertcnt,rep680400->drug_food_checking.
         drug_food_criterias[1].subjects[idx].drug_food_alert.interactions[jdx].audit_uid,output->
         drug_food_alerts[locidx].audit_uid)
        SET fltpos = locateval(locidx,1,filtercnt,rep680400->drug_food_checking.drug_food_criterias[1
         ].subjects[idx].drug_food_alert.interactions[jdx].audit_uid,filtered_alerts->list[locidx].
         audit_uid)
        IF (audpos=0
         AND fltpos=0)
         SET drugfoodalertcnt += 1
         SET stat = alterlist(output->drug_food_alerts,drugfoodalertcnt)
         SET output->drug_food_alerts[drugfoodalertcnt].cki = rep680400->drug_food_checking.
         drug_food_criterias[1].subjects[idx].drug_food_alert.interactions[jdx].subject_drug.
         subject_cki
         SET output->drug_food_alerts[drugfoodalertcnt].name = concat(rep680400->drug_food_checking.
          drug_food_criterias[1].subjects[idx].drug_food_alert.interactions[jdx].subject_drug.name,
          "-Food")
         SET output->drug_food_alerts[drugfoodalertcnt].subject_order_id = cnvtstring(
          subject_order_id)
         SET output->drug_food_alerts[drugfoodalertcnt].subject_catalog_cd = cnvtstring(
          subject_catalog_cd)
         SET output->drug_food_alerts[drugfoodalertcnt].description = rep680400->drug_food_checking.
         drug_food_criterias[1].subjects[idx].drug_food_alert.interactions[jdx].
         interaction_description
         SET output->drug_food_alerts[drugfoodalertcnt].medication = "Food"
         SET output->drug_food_alerts[drugfoodalertcnt].audit_uid = rep680400->drug_food_checking.
         drug_food_criterias[1].subjects[idx].drug_food_alert.interactions[jdx].audit_uid
         SET output->drug_food_alerts[drugfoodalertcnt].severity = getseveritydisplay(rep680400->
          drug_food_checking.drug_food_criterias[1].subjects[idx].drug_food_alert.interactions[jdx].
          severity.minor_ind,rep680400->drug_food_checking.drug_food_criterias[1].subjects[idx].
          drug_food_alert.interactions[jdx].severity.moderate_ind,rep680400->drug_food_checking.
          drug_food_criterias[1].subjects[idx].drug_food_alert.interactions[jdx].severity.major_ind,
          rep680400->drug_food_checking.drug_food_criterias[1].subjects[idx].drug_food_alert.
          interactions[jdx].severity.severity_details.contraindicated_ind)
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((result->interruption_pref_satisfied_ind=1)
    AND size(rep680400->drug_allergy_checking.drug_allergy_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->drug_allergy_checking.drug_allergy_criterias[1].subjects,5))
      SET pos = locateval(locidx,1,incoming_orders_size,rep680400->drug_allergy_checking.
       drug_allergy_criterias[1].subjects[idx].synonym_id,incoming_orders->list[locidx].synonym_id)
      IF (pos > 0)
       SET subject_order_id = incoming_orders->list[pos].order_id
      ELSE
       SET subject_order_id = 0.0
      ENDIF
      SET pos = locateval(locidx,1,synonyms_size,rep680400->drug_allergy_checking.
       drug_allergy_criterias[1].subjects[idx].synonym_id,synonyms->list[locidx].synonym_id)
      IF (pos > 0)
       SET subject_catalog_cd = synonyms->list[pos].catalog_cd
      ELSE
       SET subject_catalog_cd = 0.0
      ENDIF
      FOR (jdx = 1 TO size(rep680400->drug_allergy_checking.drug_allergy_criterias[1].subjects[idx].
       drug_allergy_alert.interactions,5))
        SET audpos = locateval(locidx,1,drugallergyalertcnt,rep680400->drug_allergy_checking.
         drug_allergy_criterias[1].subjects[idx].drug_allergy_alert.interactions[jdx].audit_uid,
         output->drug_allergy_alerts[locidx].audit_uid)
        SET fltpos = locateval(locidx,1,filtercnt,rep680400->drug_allergy_checking.
         drug_allergy_criterias[1].subjects[idx].drug_allergy_alert.interactions[jdx].audit_uid,
         filtered_alerts->list[locidx].audit_uid)
        IF (audpos=0
         AND fltpos=0)
         FOR (kdx = 1 TO size(rep680400->drug_allergy_checking.drug_allergy_criterias[1].subjects[idx
          ].drug_allergy_alert.interactions[jdx].causing_allergy.allergies,5))
           SET drugallergyalertcnt += 1
           SET stat = alterlist(output->drug_allergy_alerts,drugallergyalertcnt)
           SET output->drug_allergy_alerts[drugallergyalertcnt].description = rep680400->
           drug_allergy_checking.drug_allergy_criterias[1].subjects[idx].drug_allergy_alert.
           interactions[jdx].interaction_description
           SET output->drug_allergy_alerts[drugallergyalertcnt].audit_uid = rep680400->
           drug_allergy_checking.drug_allergy_criterias[1].subjects[idx].drug_allergy_alert.
           interactions[jdx].audit_uid
           SET output->drug_allergy_alerts[drugallergyalertcnt].cki = rep680400->
           drug_allergy_checking.drug_allergy_criterias[1].subjects[idx].drug_allergy_alert.
           interactions[jdx].causing_allergy.causing_cki
           SET pos = locateval(locidx,1,allergycnt,rep680400->drug_allergy_checking.
            drug_allergy_criterias[1].subjects[idx].drug_allergy_alert.interactions[jdx].
            causing_allergy.allergies[kdx].allergy_id,allergies->list[locidx].allergy_id)
           IF (pos > 0)
            SET output->drug_allergy_alerts[drugallergyalertcnt].name = cnvtlower(allergies->list[pos
             ].name)
           ENDIF
           SET output->drug_allergy_alerts[drugallergyalertcnt].subject_order_id = cnvtstring(
            subject_order_id)
           SET output->drug_allergy_alerts[drugallergyalertcnt].subject_catalog_cd = cnvtstring(
            subject_catalog_cd)
           SET output->drug_allergy_alerts[drugallergyalertcnt].allergy_id = cnvtstring(rep680400->
            drug_allergy_checking.drug_allergy_criterias[1].subjects[idx].drug_allergy_alert.
            interactions[jdx].causing_allergy.allergies[kdx].allergy_id)
           SET output->drug_allergy_alerts[drugallergyalertcnt].nomenclature_id = cnvtstring(
            rep680400->drug_allergy_checking.drug_allergy_criterias[1].subjects[idx].
            drug_allergy_alert.interactions[jdx].causing_allergy.allergies[kdx].nomenclature_id)
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((result->interruption_pref_satisfied_ind=1)
    AND size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias,5) > 0)
    FOR (idx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
     subjects,5))
      SET pos = locateval(locidx,1,incoming_orders_size,rep680400->duplicate_therapy_checking.
       duplicate_therapy_criterias[1].subjects[idx].synonym_id,incoming_orders->list[locidx].
       synonym_id)
      IF (pos > 0)
       SET subject_order_id = incoming_orders->list[pos].order_id
      ELSE
       SET subject_order_id = 0.0
      ENDIF
      SET pos = locateval(locidx,1,synonyms_size,rep680400->duplicate_therapy_checking.
       duplicate_therapy_criterias[1].subjects[idx].synonym_id,synonyms->list[locidx].synonym_id)
      IF (pos > 0)
       SET subject_catalog_cd = synonyms->list[pos].catalog_cd
      ELSE
       SET subject_catalog_cd = 0.0
      ENDIF
      FOR (jdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
       subjects[idx].drug_duplications,5))
        SET audpos = locateval(locidx,1,duptherapyalertcnt,rep680400->duplicate_therapy_checking.
         duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].audit_uid,output->
         duplicate_therapy_alerts[locidx].audit_uid)
        SET fltpos = locateval(locidx,1,filtercnt,rep680400->duplicate_therapy_checking.
         duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].audit_uid,
         filtered_alerts->list[locidx].audit_uid)
        IF (audpos=0
         AND fltpos=0)
         IF (size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
          drug_duplications[jdx].causing_drug.profile_orders,5) > 0)
          FOR (kdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
           subjects[idx].drug_duplications[jdx].causing_drug.profile_orders,5))
            SET duptherapyalertcnt += 1
            SET stat = alterlist(output->duplicate_therapy_alerts,duptherapyalertcnt)
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].name = uar_get_code_display(
             rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
             drug_duplications[jdx].causing_drug.profile_orders[kdx].catalog_cd)
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].subject_order_id = cnvtstring(
             subject_order_id)
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].subject_catalog_cd = cnvtstring(
             subject_catalog_cd)
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].causing_order_id = cnvtstring(
             rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
             drug_duplications[jdx].causing_drug.profile_orders[kdx].order_id)
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].causing_catalog_cd = cnvtstring(
             rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
             drug_duplications[jdx].causing_drug.profile_orders[kdx].catalog_cd)
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].audit_uid = rep680400->
            duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
            drug_duplications[jdx].audit_uid
            SET pos = locateval(locidx,1,ordercnt,rep680400->duplicate_therapy_checking.
             duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].causing_drug.
             profile_orders[kdx].order_id,profile_orders->list[locidx].order_id)
            IF (pos > 0)
             SET order_status_dt_tm = profile_orders->list[pos].status_dt_tm
            ELSE
             SET order_status_dt_tm = 0.0
            ENDIF
            SET pos = locateval(locidx,1,ordercnt,rep680400->duplicate_therapy_checking.
             duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].causing_drug.
             profile_orders[kdx].order_id,rep680204->orders[locidx].core.order_id)
            IF (pos > 0)
             IF (trim(rep680204->orders[pos].displays.reference_name,3)=trim(rep680204->orders[pos].
              displays.clinical_name,3))
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].medication = rep680204->
              orders[pos].displays.reference_name
             ELSE
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].medication = concat(rep680204
               ->orders[pos].displays.reference_name," (",rep680204->orders[pos].displays.
               clinical_name,")")
             ENDIF
             SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_details = rep680204->
             orders[pos].displays.simplified_display_line
             SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_status =
             uar_get_code_display(rep680204->orders[pos].core.order_status_cd)
             SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_status_dt_tm = evaluate(
              order_status_dt_tm,0,"",format(order_status_dt_tm,"MM/DD/YYYY HH:MM;;D"))
             SET output->duplicate_therapy_alerts[duptherapyalertcnt].interaction_information =
             cnvtlower(concat(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
               subjects[idx].drug_duplications[jdx].subject_drug.name,"-",rep680204->orders[pos].
               displays.reference_name))
             SET output->duplicate_therapy_alerts[duptherapyalertcnt].description = concat(trim(
               cnvtstring(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
                subjects[idx].drug_duplications[jdx].observed_occurrences),3)," active orders for ",
              rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
              drug_duplications[jdx].subject_drug.name,
              " exist and may represent therapeutic duplication.")
            ENDIF
          ENDFOR
         ELSEIF (size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[
          idx].drug_duplications[jdx].causing_drug.subject_synonyms,5) > 0)
          FOR (kdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
           subjects[idx].drug_duplications[jdx].causing_drug.subject_synonyms,5))
            SET duptherapyalertcnt += 1
            SET stat = alterlist(output->duplicate_therapy_alerts,duptherapyalertcnt)
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].name = not_applicable
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].subject_order_id = cnvtstring(
             subject_order_id)
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].subject_catalog_cd = cnvtstring(
             subject_catalog_cd)
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].causing_order_id = cnvtstring(
             cnvtint(replace(replace(rep680400->duplicate_therapy_checking.
                duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].causing_drug.
                subject_synonyms[kdx].unique_identifier,"ORDERID_","",0),"0_0","",0)))
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].audit_uid = rep680400->
            duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
            drug_duplications[jdx].audit_uid
            SET pos = locateval(locidx,1,syncnt,rep680400->duplicate_therapy_checking.
             duplicate_therapy_criterias[1].subjects[idx].drug_duplications[jdx].causing_drug.
             subject_synonyms[kdx].synonym_id,synonyms->list[locidx].synonym_id)
            IF (pos > 0)
             IF (trim(synonyms->list[pos].catalog_disp,3)=trim(synonyms->list[pos].synonym_mnemonic,3
              ))
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].medication = synonyms->list[
              pos].catalog_disp
             ELSE
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].medication = concat(synonyms->
               list[pos].catalog_disp," (",synonyms->list[pos].synonym_mnemonic,")")
             ENDIF
             SET output->duplicate_therapy_alerts[duptherapyalertcnt].interaction_information =
             cnvtlower(concat(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
               subjects[idx].drug_duplications[jdx].subject_drug.name,"-",synonyms->list[pos].
               catalog_disp))
             SET output->duplicate_therapy_alerts[duptherapyalertcnt].description = concat(trim(
               cnvtstring(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
                subjects[idx].drug_duplications[jdx].observed_occurrences),3)," active orders for ",
              rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
              drug_duplications[jdx].subject_drug.name,
              " exist and may represent therapeutic duplication.")
             SET output->duplicate_therapy_alerts[duptherapyalertcnt].causing_catalog_cd = cnvtstring
             (synonyms->list[pos].catalog_cd)
            ENDIF
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_details = not_applicable
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_status = order_status_new
            SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_status_dt_tm =
            not_applicable
          ENDFOR
         ENDIF
        ENDIF
      ENDFOR
      FOR (jdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
       subjects[idx].category_duplications,5))
        SET audpos = locateval(locidx,1,duptherapyalertcnt,rep680400->duplicate_therapy_checking.
         duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].audit_uid,output->
         duplicate_therapy_alerts[locidx].audit_uid)
        SET fltpos = locateval(locidx,1,filtercnt,rep680400->duplicate_therapy_checking.
         duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].audit_uid,
         filtered_alerts->list[locidx].audit_uid)
        IF (audpos=0
         AND fltpos=0)
         FOR (kdx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
          subjects[idx].category_duplications[jdx].causing_drugs,5))
           IF (size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx
            ].category_duplications[jdx].causing_drugs[kdx].profile_orders,5) > 0)
            FOR (ldx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1]
             .subjects[idx].category_duplications[jdx].causing_drugs[kdx].profile_orders,5))
              SET duptherapyalertcnt += 1
              SET stat = alterlist(output->duplicate_therapy_alerts,duptherapyalertcnt)
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].name = uar_get_code_display(
               rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
               category_duplications[jdx].causing_drugs[kdx].profile_orders[ldx].catalog_cd)
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].subject_order_id = cnvtstring(
               subject_order_id)
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].subject_catalog_cd =
              cnvtstring(subject_catalog_cd)
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].causing_order_id = cnvtstring(
               rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
               category_duplications[jdx].causing_drugs[kdx].profile_orders[ldx].order_id)
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].causing_catalog_cd =
              cnvtstring(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
               subjects[idx].category_duplications[jdx].causing_drugs[kdx].profile_orders[ldx].
               catalog_cd)
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].audit_uid = rep680400->
              duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
              category_duplications[jdx].audit_uid
              SET pos = locateval(locidx,1,ordercnt,rep680400->duplicate_therapy_checking.
               duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].causing_drugs[
               kdx].profile_orders[ldx].order_id,profile_orders->list[locidx].order_id)
              IF (pos > 0)
               SET order_status_dt_tm = profile_orders->list[pos].status_dt_tm
              ELSE
               SET order_status_dt_tm = 0.0
              ENDIF
              SET pos = locateval(locidx,1,ordercnt,rep680400->duplicate_therapy_checking.
               duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].causing_drugs[
               kdx].profile_orders[ldx].order_id,rep680204->orders[locidx].core.order_id)
              IF (pos > 0)
               IF (trim(rep680204->orders[pos].displays.reference_name,3)=trim(rep680204->orders[pos]
                .displays.clinical_name,3))
                SET output->duplicate_therapy_alerts[duptherapyalertcnt].medication = rep680204->
                orders[pos].displays.reference_name
               ELSE
                SET output->duplicate_therapy_alerts[duptherapyalertcnt].medication = concat(
                 rep680204->orders[pos].displays.reference_name," (",rep680204->orders[pos].displays.
                 clinical_name,")")
               ENDIF
               SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_details = rep680204->
               orders[pos].displays.simplified_display_line
               SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_status =
               uar_get_code_display(rep680204->orders[pos].core.order_status_cd)
               SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_status_dt_tm = evaluate
               (order_status_dt_tm,0,"",format(order_status_dt_tm,"MM/DD/YYYY HH:MM;;D"))
               SET output->duplicate_therapy_alerts[duptherapyalertcnt].interaction_information =
               cnvtlower(concat(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
                 subjects[idx].category_duplications[jdx].subject_drug.name,"-",rep680204->orders[pos
                 ].displays.reference_name))
               SET output->duplicate_therapy_alerts[duptherapyalertcnt].description = concat(trim(
                 cnvtstring(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
                  subjects[idx].category_duplications[jdx].observed_occurrences),3),
                " active orders for ",rep680400->duplicate_therapy_checking.
                duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].subject_drug.
                name," exist and may represent therapeutic duplication.")
              ENDIF
            ENDFOR
           ELSEIF (size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
            subjects[idx].category_duplications[jdx].causing_drugs[kdx].subject_synonyms,5) > 0)
            FOR (ldx = 1 TO size(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1]
             .subjects[idx].category_duplications[jdx].causing_drugs[kdx].subject_synonyms,5))
              SET duptherapyalertcnt += 1
              SET stat = alterlist(output->duplicate_therapy_alerts,duptherapyalertcnt)
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].name = rep680400->
              duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
              category_duplications[jdx].causing_drugs[kdx].name
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].subject_order_id = cnvtstring(
               subject_order_id)
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].subject_catalog_cd =
              cnvtstring(subject_catalog_cd)
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].causing_order_id = cnvtstring(
               cnvtint(replace(replace(rep680400->duplicate_therapy_checking.
                  duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].
                  causing_drugs[kdx].subject_synonyms[ldx].unique_identifier,"ORDERID_","",0),"0_0",
                 "",0)))
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].audit_uid = rep680400->
              duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
              category_duplications[jdx].audit_uid
              SET pos = locateval(locidx,1,syncnt,rep680400->duplicate_therapy_checking.
               duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].causing_drugs[
               kdx].subject_synonyms[ldx].synonym_id,synonyms->list[locidx].synonym_id)
              IF (pos > 0)
               IF (trim(synonyms->list[pos].catalog_disp,3)=trim(synonyms->list[pos].synonym_mnemonic,
                3))
                SET output->duplicate_therapy_alerts[duptherapyalertcnt].medication = synonyms->list[
                pos].catalog_disp
               ELSE
                SET output->duplicate_therapy_alerts[duptherapyalertcnt].medication = concat(synonyms
                 ->list[pos].catalog_disp," (",synonyms->list[pos].synonym_mnemonic,")")
               ENDIF
               SET output->duplicate_therapy_alerts[duptherapyalertcnt].causing_catalog_cd =
               cnvtstring(synonyms->list[pos].catalog_cd)
              ENDIF
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_details = not_applicable
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_status =
              order_status_new
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].order_status_dt_tm =
              not_applicable
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].interaction_information =
              cnvtlower(concat(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
                subjects[idx].category_duplications[jdx].subject_drug.name,"-",rep680400->
                duplicate_therapy_checking.duplicate_therapy_criterias[1].subjects[idx].
                category_duplications[jdx].causing_drugs[kdx].name))
              SET output->duplicate_therapy_alerts[duptherapyalertcnt].description = concat(trim(
                cnvtstring(rep680400->duplicate_therapy_checking.duplicate_therapy_criterias[1].
                 subjects[idx].category_duplications[jdx].observed_occurrences),3),
               " active orders for ",rep680400->duplicate_therapy_checking.
               duplicate_therapy_criterias[1].subjects[idx].category_duplications[jdx].subject_drug.
               name," exist and may represent therapeutic duplication.")
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   CALL echorecord(output)
   RETURN(success)
 END ;Subroutine
END GO
