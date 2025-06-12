CREATE PROGRAM atg_cps_bcb_get_data:dba
 EXECUTE crmrtl
 EXECUTE srvrtl
 DECLARE atginitsrvreq680200(null) = null
 DECLARE atgperformsrvreq680200(null) = i4
 FREE SET atg_req_680200
 RECORD atg_req_680200(
   1 patient_id = f8
   1 encounter_criteria
     2 encounters[*]
       3 encounter_id = f8
     2 encounter_type_classes[*]
       3 encounter_type_class_cd = f8
     2 override_org_security_ind = i2
   1 user_criteria
     2 user_id = f8
     2 patient_user_relationship_cd = f8
   1 active_orders_criteria
     2 order_statuses
       3 load_ordered_ind = i2
       3 load_future_ind = i2
       3 load_in_process_ind = i2
       3 load_on_hold_ind = i2
       3 load_suspended_ind = i2
       3 load_incomplete_ind = i2
     2 date_criteria
       3 begin_dt_tm = dq8
       3 end_dt_tm = dq8
       3 qualify_on_start_dt_tm_ind = i2
       3 qualify_on_stop_dt_tm_ind = i2
       3 qualify_on_clin_rel_dt_tm_ind = i2
     2 page_criteria
       3 page_size = i2
       3 sort_by_primary_column_asc = i2
   1 inactive_orders_criteria
     2 order_statuses
       3 load_canceled_ind = i2
       3 load_discontinued_ind = i2
       3 load_completed_ind = i2
       3 load_pending_complete_ind = i2
       3 load_voided_with_results_ind = i2
       3 load_voided_without_results_ind = i2
       3 load_transfer_canceled_ind = i2
     2 date_criteria
       3 begin_dt_tm = dq8
       3 end_dt_tm = dq8
       3 qualify_on_start_dt_tm_ind = i2
       3 qualify_on_stop_dt_tm_ind = i2
       3 qualify_on_clin_rel_dt_tm_ind = i2
     2 page_criteria
       3 page_size = i2
       3 sort_by_primary_column_asc = i2
   1 medication_order_criteria
     2 load_normal_ind = i2
     2 load_prescription_ind = i2
     2 load_documented_ind = i2
     2 load_patients_own_ind = i2
     2 load_charge_only_ind = i2
     2 load_satellite_ind = i2
     2 catalogs[*]
       3 catalog_id = f8
   1 non_medication_order_criteria
     2 load_continuing_instances_ind = i2
     2 load_all_catalog_types_ind = i2
     2 catalog_types[*]
       3 catalog_type_cd = f8
     2 activity_types[*]
       3 activity_type_cd = f8
     2 catalogs[*]
       3 catalog_id = f8
   1 clinical_categories[*]
     2 clinical_category_cd = f8
   1 load_indicators
     2 order_profile_indicators
       3 comment_types
         4 load_order_comment_ind = i2
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
     2 profile_proposals_indicators
       3 load_core_ind = i2
       3 comment_types
         4 load_order_comment_ind = i2
       3 diagnosis_info_criteria
         4 load_core_ind = i2
         4 load_extended_ind = i2
       3 load_order_ingredients_ind = i2
       3 load_order_details_ind = i2
       3 load_venue_ind = i2
       3 load_dose_calculator_text_ind = i2
       3 load_order_set_ind = i2
   1 order_proposal_criteria
     2 load_new_pending_proposals_ind = i2
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
 )
 FREE SET atg_reply_680200
 RECORD atg_reply_680200(
   1 active_orders[*]
     2 core
       3 order_id = f8
       3 patient_id = f8
       3 version = i4
       3 order_status_cd = f8
       3 department_status_cd = f8
       3 responsible_provider_id = f8
       3 action_sequence = i4
       3 source_cd = f8
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
     2 last_action_information
       3 action_personnel_id = f8
       3 action_dt_tm = dq8
       3 action_tz = i4
     2 template_information
       3 template_order_id = f8
       3 template_none_ind = i2
       3 template_order_ind = i2
       3 order_instance_ind = i2
       3 future_recurring_template_ind = i2
       3 future_recurring_instance_ind = i2
     2 order_set_information
       3 parent_id = f8
       3 parent_name = vc
     2 supergroup_information
       3 parent_ind = i2
       3 components[*]
         4 order_id = f8
         4 department_status_cd = f8
     2 care_plan_information
       3 care_plan_catalog_id = f8
       3 name = vc
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
     2 pending_order_proposal_info
       3 order_proposal_id = f8
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
   1 active_orders_page_context
     2 context = vc
     2 has_previous_page_ind = i2
     2 has_next_page_ind = i2
   1 inactive_orders[*]
     2 core
       3 order_id = f8
       3 patient_id = f8
       3 version = i4
       3 order_status_cd = f8
       3 department_status_cd = f8
       3 responsible_provider_id = f8
       3 action_sequence = i4
       3 source_cd = f8
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
     2 last_action_information
       3 action_personnel_id = f8
       3 action_dt_tm = dq8
       3 action_tz = i4
     2 template_information
       3 template_order_id = f8
       3 template_none_ind = i2
       3 template_order_ind = i2
       3 order_instance_ind = i2
       3 future_recurring_template_ind = i2
       3 future_recurring_instance_ind = i2
     2 order_set_information
       3 parent_id = f8
       3 parent_name = vc
     2 supergroup_information
       3 parent_ind = i2
       3 components[*]
         4 order_id = f8
         4 department_status_cd = f8
     2 care_plan_information
       3 care_plan_catalog_id = f8
       3 name = vc
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
     2 pending_order_proposal_info
       3 order_proposal_id = f8
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
   1 inactive_orders_page_context
     2 context = vc
     2 has_previous_page_ind = i2
     2 has_next_page_ind = i2
   1 order_proposals[*]
     2 core
       3 order_proposal_id = f8
       3 order_id = f8
       3 projected_order_id = f8
       3 patient_id = f8
       3 encounter_id = f8
       3 responsible_provider_id = f8
       3 data_enterer_id = f8
       3 resolved_by_personnel_id = f8
       3 status_cd = f8
       3 source_type_cd = f8
       3 proposed_action_type_cd = f8
       3 from_action_sequence = i4
       3 to_action_sequence = i4
       3 communication_type_cd = f8
     2 displays
       3 reference_name = vc
       3 clinical_name = vc
       3 department_name = vc
       3 clinical_display_line = vc
       3 simplified_display_line = vc
     2 reference_information
       3 synonym_id = f8
       3 order_entry_format_id = f8
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
         4 synonym_id = f8
         4 clinical_name = vc
         4 department_name = vc
         4 source_type
           5 user_ind = i2
           5 system_balanced_ind = i2
           5 system_auto_product_assign_ind = i2
         4 alter_type
           5 unchanged_ind = i2
           5 added_ind = i2
           5 modified_ind = i2
           5 deleted_ind = i2
         4 dose
           5 strength = f8
           5 strength_unit_cd = f8
           5 volume = f8
           5 volume_unit_cd = f8
           5 freetext = vc
           5 ordered = f8
           5 ordered_unit_cd = f8
           5 calculator_text = vc
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
         4 bag_frequency_cd = f8
         4 include_in_total_volume_type
           5 unknown_ind = i2
           5 not_included_ind = i2
           5 included_ind = i2
         4 normalized_rate = f8
         4 normalized_rate_unit_cd = f8
         4 concentration = f8
         4 concentration_unit_cd = f8
       3 iv_set_synonym_id = f8
     2 comments
       3 order_comment = vc
     2 diagnoses[*]
       3 diagnosis_id = f8
       3 nomenclature_id = f8
       3 priority = i4
       3 description = vc
       3 alter_type
         4 unchanged_ind = i2
         4 added_ind = i2
         4 modified_ind = i2
         4 deleted_ind = i2
       3 source_vocabulary_cd = f8
       3 source_identifier = vc
     2 order_details[*]
       3 oe_field_id = f8
       3 oe_field_meaning = vc
       3 oe_field_meaning_id = f8
       3 detail_values[*]
         4 oe_field_value = f8
         4 oe_field_display_value = vc
         4 oe_field_dt_tm_value = dq8
         4 oe_field_tz = i4
         4 alter_type
           5 unchanged_ind = i2
           5 added_ind = i2
           5 modified_ind = i2
           5 deleted_ind = i2
     2 venue
       3 acute_ind = i2
       3 ambulatory_ind = i2
       3 prescription_ind = i2
       3 unknown_ind = i2
     2 adhoc_frequency_times[*]
       3 sequence = i4
       3 time_of_day = i2
     2 order_set_information
       3 parent_id = f8
       3 parent_name = vc
       3 parent_resolved_ind = i2
     2 proposal_mnemonic
       3 mnemonic = vc
       3 may_be_truncated_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE atginitsrvreq680200(null)
  SET stat = initrec(atg_req_680200)
  SET stat = initrec(atg_reply_680200)
 END ;Subroutine
 SUBROUTINE atgperformsrvreq680200(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(500195)
   DECLARE requestid = i4 WITH protect, constant(680200)
   DECLARE iret = i2 WITH protect, noconstant(0)
   DECLARE happ = i4 WITH protect, noconstant(0)
   DECLARE hitem1 = i4 WITH protect, noconstant(0)
   DECLARE hitem2 = i4 WITH protect, noconstant(0)
   DECLARE hitem3 = i4 WITH protect, noconstant(0)
   DECLARE hitem4 = i4 WITH protect, noconstant(0)
   DECLARE hrep = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hrequest = i4 WITH protect, noconstant(0)
   DECLARE htask = i4 WITH protect, noconstant(0)
   DECLARE nitem1cnt = i4 WITH protect, noconstant(0)
   DECLARE nitem2cnt = i4 WITH protect, noconstant(0)
   DECLARE nitem3cnt = i4 WITH protect, noconstant(0)
   DECLARE nitem1idx = i4 WITH protect, noconstant(0)
   DECLARE nitem2idx = i4 WITH protect, noconstant(0)
   DECLARE nitem3idx = i4 WITH protect, noconstant(0)
   DECLARE temp_string = vc WITH protect, noconstant(" ")
   DECLARE temp_double = f8 WITH protect, noconstant(0.0)
   SET iret = uar_crmbeginapp(applicationid,happ)
   IF (iret=0)
    CALL echo(build("Crm Begin App Successful - App#",applicationid))
    SET iret = uar_crmbegintask(happ,taskid,htask)
    IF (iret=0)
     CALL echo(build("Crm Begin Task Successful - Task#",taskid))
     SET iret = uar_crmbeginreq(htask,"",requestid,hreq)
     IF (iret=0)
      CALL echo(build("Crm Begin Req Successful - Req#",requestid))
      SET hrequest = uar_crmgetrequest(hreq)
      IF (hrequest=0)
       CALL echo(build("Crm Get Request Failed - Req#",requestid))
      ELSE
       CALL echo(build("Crm Get Request Successful - Req#",requestid))
       SET iret = uar_srvsetdouble(hrequest,"patient_id",atg_req_680200->patient_id)
       SET hitem1 = uar_srvgetstruct(hrequest,"encounter_criteria")
       SET nitem2cnt = size(atg_req_680200->encounter_criteria.encounters,5)
       FOR (nitem2idx = 1 TO nitem2cnt)
        SET hitem2 = uar_srvadditem(hitem1,"encounters")
        SET iret = uar_srvsetdouble(hitem2,"encounter_id",atg_req_680200->encounter_criteria.
         encounters[nitem2idx].encounter_id)
       ENDFOR
       SET nitem2cnt = size(atg_req_680200->encounter_criteria.encounter_type_classes,5)
       FOR (nitem2idx = 1 TO nitem2cnt)
        SET hitem2 = uar_srvadditem(hitem1,"encounter_type_classes")
        SET iret = uar_srvsetdouble(hitem2,"encounter_type_class_cd",atg_req_680200->
         encounter_criteria.encounter_type_classes[nitem2idx].encounter_type_class_cd)
       ENDFOR
       SET iret = uar_srvsetshort(hitem1,"override_org_security_ind",atg_req_680200->
        encounter_criteria.override_org_security_ind)
       SET hitem1 = uar_srvgetstruct(hrequest,"user_criteria")
       SET iret = uar_srvsetdouble(hitem1,"user_id",atg_req_680200->user_criteria.user_id)
       SET iret = uar_srvsetdouble(hitem1,"patient_user_relationship_cd",atg_req_680200->
        user_criteria.patient_user_relationship_cd)
       SET hitem1 = uar_srvgetstruct(hrequest,"active_orders_criteria")
       SET hitem2 = uar_srvgetstruct(hitem1,"order_statuses")
       SET iret = uar_srvsetshort(hitem2,"load_ordered_ind",atg_req_680200->active_orders_criteria.
        order_statuses.load_ordered_ind)
       SET iret = uar_srvsetshort(hitem2,"load_future_ind",atg_req_680200->active_orders_criteria.
        order_statuses.load_future_ind)
       SET iret = uar_srvsetshort(hitem2,"load_in_process_ind",atg_req_680200->active_orders_criteria
        .order_statuses.load_in_process_ind)
       SET iret = uar_srvsetshort(hitem2,"load_on_hold_ind",atg_req_680200->active_orders_criteria.
        order_statuses.load_on_hold_ind)
       SET iret = uar_srvsetshort(hitem2,"load_suspended_ind",atg_req_680200->active_orders_criteria.
        order_statuses.load_suspended_ind)
       SET iret = uar_srvsetshort(hitem2,"load_incomplete_ind",atg_req_680200->active_orders_criteria
        .order_statuses.load_incomplete_ind)
       SET hitem2 = uar_srvgetstruct(hitem1,"date_criteria")
       SET iret = uar_srvsetdate(hitem2,"begin_dt_tm",cnvtdatetime(atg_req_680200->
         active_orders_criteria.date_criteria.begin_dt_tm))
       SET iret = uar_srvsetdate(hitem2,"end_dt_tm",cnvtdatetime(atg_req_680200->
         active_orders_criteria.date_criteria.end_dt_tm))
       SET iret = uar_srvsetshort(hitem2,"qualify_on_start_dt_tm_ind",atg_req_680200->
        active_orders_criteria.date_criteria.qualify_on_start_dt_tm_ind)
       SET iret = uar_srvsetshort(hitem2,"qualify_on_stop_dt_tm_ind",atg_req_680200->
        active_orders_criteria.date_criteria.qualify_on_stop_dt_tm_ind)
       SET iret = uar_srvsetshort(hitem2,"qualify_on_clin_rel_dt_tm_ind",atg_req_680200->
        active_orders_criteria.date_criteria.qualify_on_clin_rel_dt_tm_ind)
       SET hitem2 = uar_srvgetstruct(hitem1,"page_criteria")
       SET iret = uar_srvsetshort(hitem2,"page_size",atg_req_680200->active_orders_criteria.
        page_criteria.page_size)
       SET iret = uar_srvsetshort(hitem2,"sort_by_primary_column_asc",atg_req_680200->
        active_orders_criteria.page_criteria.sort_by_primary_column_asc)
       SET hitem1 = uar_srvgetstruct(hrequest,"inactive_orders_criteria")
       SET hitem2 = uar_srvgetstruct(hitem1,"order_statuses")
       SET iret = uar_srvsetshort(hitem2,"load_canceled_ind",atg_req_680200->inactive_orders_criteria
        .order_statuses.load_canceled_ind)
       SET iret = uar_srvsetshort(hitem2,"load_discontinued_ind",atg_req_680200->
        inactive_orders_criteria.order_statuses.load_discontinued_ind)
       SET iret = uar_srvsetshort(hitem2,"load_completed_ind",atg_req_680200->
        inactive_orders_criteria.order_statuses.load_completed_ind)
       SET iret = uar_srvsetshort(hitem2,"load_pending_complete_ind",atg_req_680200->
        inactive_orders_criteria.order_statuses.load_pending_complete_ind)
       SET iret = uar_srvsetshort(hitem2,"load_voided_with_results_ind",atg_req_680200->
        inactive_orders_criteria.order_statuses.load_voided_with_results_ind)
       SET iret = uar_srvsetshort(hitem2,"load_voided_without_results_ind",atg_req_680200->
        inactive_orders_criteria.order_statuses.load_voided_without_results_ind)
       SET iret = uar_srvsetshort(hitem2,"load_transfer_canceled_ind",atg_req_680200->
        inactive_orders_criteria.order_statuses.load_transfer_canceled_ind)
       SET hitem2 = uar_srvgetstruct(hitem1,"date_criteria")
       SET iret = uar_srvsetdate(hitem2,"begin_dt_tm",cnvtdatetime(atg_req_680200->
         inactive_orders_criteria.date_criteria.begin_dt_tm))
       SET iret = uar_srvsetdate(hitem2,"end_dt_tm",cnvtdatetime(atg_req_680200->
         inactive_orders_criteria.date_criteria.end_dt_tm))
       SET iret = uar_srvsetshort(hitem2,"qualify_on_start_dt_tm_ind",atg_req_680200->
        inactive_orders_criteria.date_criteria.qualify_on_start_dt_tm_ind)
       SET iret = uar_srvsetshort(hitem2,"qualify_on_stop_dt_tm_ind",atg_req_680200->
        inactive_orders_criteria.date_criteria.qualify_on_stop_dt_tm_ind)
       SET iret = uar_srvsetshort(hitem2,"qualify_on_clin_rel_dt_tm_ind",atg_req_680200->
        inactive_orders_criteria.date_criteria.qualify_on_clin_rel_dt_tm_ind)
       SET hitem2 = uar_srvgetstruct(hitem1,"page_criteria")
       SET iret = uar_srvsetshort(hitem2,"page_size",atg_req_680200->inactive_orders_criteria.
        page_criteria.page_size)
       SET iret = uar_srvsetshort(hitem2,"sort_by_primary_column_asc",atg_req_680200->
        inactive_orders_criteria.page_criteria.sort_by_primary_column_asc)
       SET hitem1 = uar_srvgetstruct(hrequest,"medication_order_criteria")
       SET iret = uar_srvsetshort(hitem1,"load_normal_ind",atg_req_680200->medication_order_criteria.
        load_normal_ind)
       SET iret = uar_srvsetshort(hitem1,"load_prescription_ind",atg_req_680200->
        medication_order_criteria.load_prescription_ind)
       SET iret = uar_srvsetshort(hitem1,"load_documented_ind",atg_req_680200->
        medication_order_criteria.load_documented_ind)
       SET iret = uar_srvsetshort(hitem1,"load_patients_own_ind",atg_req_680200->
        medication_order_criteria.load_patients_own_ind)
       SET iret = uar_srvsetshort(hitem1,"load_charge_only_ind",atg_req_680200->
        medication_order_criteria.load_charge_only_ind)
       SET iret = uar_srvsetshort(hitem1,"load_satellite_ind",atg_req_680200->
        medication_order_criteria.load_satellite_ind)
       SET nitem2cnt = size(atg_req_680200->medication_order_criteria.catalogs,5)
       FOR (nitem2idx = 1 TO nitem2cnt)
        SET hitem2 = uar_srvadditem(hitem1,"catalogs")
        SET iret = uar_srvsetdouble(hitem2,"catalog_id",atg_req_680200->medication_order_criteria.
         catalogs[nitem2idx].catalog_id)
       ENDFOR
       SET hitem1 = uar_srvgetstruct(hrequest,"non_medication_order_criteria")
       SET iret = uar_srvsetshort(hitem1,"load_continuing_instances_ind",atg_req_680200->
        non_medication_order_criteria.load_continuing_instances_ind)
       SET iret = uar_srvsetshort(hitem1,"load_all_catalog_types_ind",atg_req_680200->
        non_medication_order_criteria.load_all_catalog_types_ind)
       SET nitem2cnt = size(atg_req_680200->non_medication_order_criteria.catalog_types,5)
       FOR (nitem2idx = 1 TO nitem2cnt)
        SET hitem2 = uar_srvadditem(hitem1,"catalog_types")
        SET iret = uar_srvsetdouble(hitem2,"catalog_type_cd",atg_req_680200->
         non_medication_order_criteria.catalog_types[nitem2idx].catalog_type_cd)
       ENDFOR
       SET nitem2cnt = size(atg_req_680200->non_medication_order_criteria.activity_types,5)
       FOR (nitem2idx = 1 TO nitem2cnt)
        SET hitem2 = uar_srvadditem(hitem1,"activity_types")
        SET iret = uar_srvsetdouble(hitem2,"activity_type_cd",atg_req_680200->
         non_medication_order_criteria.activity_types[nitem2idx].activity_type_cd)
       ENDFOR
       SET nitem2cnt = size(atg_req_680200->non_medication_order_criteria.catalogs,5)
       FOR (nitem2idx = 1 TO nitem2cnt)
        SET hitem2 = uar_srvadditem(hitem1,"catalogs")
        SET iret = uar_srvsetdouble(hitem2,"catalog_id",atg_req_680200->non_medication_order_criteria
         .catalogs[nitem2idx].catalog_id)
       ENDFOR
       SET nitem1cnt = size(atg_req_680200->clinical_categories,5)
       FOR (nitem1idx = 1 TO nitem1cnt)
        SET hitem1 = uar_srvadditem(hrequest,"clinical_categories")
        SET iret = uar_srvsetdouble(hitem1,"clinical_category_cd",atg_req_680200->
         clinical_categories[nitem1cnt].clinical_category_cd)
       ENDFOR
       SET hitem1 = uar_srvgetstruct(hrequest,"load_indicators")
       SET hitem2 = uar_srvgetstruct(hitem1,"order_profile_indicators")
       SET hitem3 = uar_srvgetstruct(hitem2,"comment_types")
       SET iret = uar_srvsetshort(hitem3,"load_order_comment_ind",atg_req_680200->load_indicators.
        order_profile_indicators.comment_types.load_order_comment_ind)
       SET hitem3 = uar_srvgetstruct(hitem2,"review_information_criteria")
       SET iret = uar_srvsetshort(hitem3,"load_review_status_ind",atg_req_680200->load_indicators.
        order_profile_indicators.review_information_criteria.load_review_status_ind)
       SET iret = uar_srvsetshort(hitem3,"load_renewal_notification_ind",atg_req_680200->
        load_indicators.order_profile_indicators.review_information_criteria.
        load_renewal_notification_ind)
       SET hitem3 = uar_srvgetstruct(hitem2,"order_set_info_criteria")
       SET iret = uar_srvsetshort(hitem3,"load_core_ind",atg_req_680200->load_indicators.
        order_profile_indicators.order_set_info_criteria.load_core_ind)
       SET iret = uar_srvsetshort(hitem3,"load_name_ind",atg_req_680200->load_indicators.
        order_profile_indicators.order_set_info_criteria.load_name_ind)
       SET hitem3 = uar_srvgetstruct(hitem2,"supergroup_info_criteria")
       SET iret = uar_srvsetshort(hitem3,"load_core_ind",atg_req_680200->load_indicators.
        order_profile_indicators.supergroup_info_criteria.load_core_ind)
       SET iret = uar_srvsetshort(hitem3,"load_components_ind",atg_req_680200->load_indicators.
        order_profile_indicators.supergroup_info_criteria.load_components_ind)
       SET iret = uar_srvsetshort(hitem2,"load_linked_order_info_ind",atg_req_680200->load_indicators
        .order_profile_indicators.load_linked_order_info_ind)
       SET hitem3 = uar_srvgetstruct(hitem2,"care_plan_info_criteria")
       SET iret = uar_srvsetshort(hitem3,"load_core_ind",atg_req_680200->load_indicators.
        order_profile_indicators.care_plan_info_criteria.load_core_ind)
       SET iret = uar_srvsetshort(hitem3,"load_extended_ind",atg_req_680200->load_indicators.
        order_profile_indicators.care_plan_info_criteria.load_extended_ind)
       SET iret = uar_srvsetshort(hitem2,"load_encounter_information_ind",atg_req_680200->
        load_indicators.order_profile_indicators.load_encounter_information_ind)
       SET iret = uar_srvsetshort(hitem2,"load_pending_status_info_ind",atg_req_680200->
        load_indicators.order_profile_indicators.load_pending_status_info_ind)
       SET iret = uar_srvsetshort(hitem2,"load_venue_ind",atg_req_680200->load_indicators.
        order_profile_indicators.load_venue_ind)
       SET iret = uar_srvsetshort(hitem2,"load_order_schedule_ind",atg_req_680200->load_indicators.
        order_profile_indicators.load_order_schedule_ind)
       SET iret = uar_srvsetshort(hitem2,"load_order_ingredients_ind",atg_req_680200->load_indicators
        .order_profile_indicators.load_order_ingredients_ind)
       SET iret = uar_srvsetshort(hitem2,"load_last_action_info_ind",atg_req_680200->load_indicators.
        order_profile_indicators.load_last_action_info_ind)
       SET iret = uar_srvsetshort(hitem2,"load_extended_attributes_ind",atg_req_680200->
        load_indicators.order_profile_indicators.load_extended_attributes_ind)
       SET iret = uar_srvsetshort(hitem2,"load_order_proposal_info_ind",atg_req_680200->
        load_indicators.order_profile_indicators.load_order_proposal_info_ind)
       SET hitem3 = uar_srvgetstruct(hitem2,"order_relation_criteria")
       SET iret = uar_srvsetshort(hitem3,"load_core_ind",atg_req_680200->load_indicators.
        order_profile_indicators.order_relation_criteria.load_core_ind)
       SET hitem3 = uar_srvgetstruct(hitem2,"appointment_criteria")
       SET iret = uar_srvsetshort(hitem3,"load_core_ind",atg_req_680200->load_indicators.
        order_profile_indicators.appointment_criteria.load_core_ind)
       SET hitem3 = uar_srvgetstruct(hitem2,"therapeutic_substitution")
       SET iret = uar_srvsetshort(hitem3,"load_accepted_ind",atg_req_680200->load_indicators.
        order_profile_indicators.therapeutic_substitution.load_accepted_ind)
       SET hitem2 = uar_srvgetstruct(hitem1,"profile_proposals_indicators")
       SET iret = uar_srvsetshort(hitem2,"load_core_ind",atg_req_680200->load_indicators.
        profile_proposals_indicators.load_core_ind)
       SET hitem3 = uar_srvgetstruct(hitem2,"comment_types")
       SET iret = uar_srvsetshort(hitem3,"load_order_comment_ind",atg_req_680200->load_indicators.
        profile_proposals_indicators.comment_types.load_order_comment_ind)
       SET hitem3 = uar_srvgetstruct(hitem2,"diagnosis_info_criteria")
       SET iret = uar_srvsetshort(hitem3,"load_core_ind",atg_req_680200->load_indicators.
        profile_proposals_indicators.diagnosis_info_criteria.load_core_ind)
       SET iret = uar_srvsetshort(hitem3,"load_extended_ind",atg_req_680200->load_indicators.
        profile_proposals_indicators.diagnosis_info_criteria.load_extended_ind)
       SET iret = uar_srvsetshort(hitem2,"load_order_ingredients_ind",atg_req_680200->load_indicators
        .profile_proposals_indicators.load_order_ingredients_ind)
       SET iret = uar_srvsetshort(hitem2,"load_order_details_ind",atg_req_680200->load_indicators.
        profile_proposals_indicators.load_order_details_ind)
       SET iret = uar_srvsetshort(hitem2,"load_venue_ind",atg_req_680200->load_indicators.
        profile_proposals_indicators.load_venue_ind)
       SET iret = uar_srvsetshort(hitem2,"load_dose_calculator_text_ind",atg_req_680200->
        load_indicators.profile_proposals_indicators.load_dose_calculator_text_ind)
       SET iret = uar_srvsetshort(hitem2,"load_order_set_ind",atg_req_680200->load_indicators.
        profile_proposals_indicators.load_order_set_ind)
       SET hitem1 = uar_srvgetstruct(hrequest,"order_proposal_criteria")
       SET iret = uar_srvsetshort(hitem1,"load_new_pending_proposals_ind",atg_req_680200->
        order_proposal_criteria.load_new_pending_proposals_ind)
       SET hitem1 = uar_srvgetstruct(hrequest,"mnemonic_criteria")
       SET iret = uar_srvsetshort(hitem1,"load_mnemonic_ind",atg_req_680200->mnemonic_criteria.
        load_mnemonic_ind)
       SET hitem2 = uar_srvgetstruct(hitem1,"simple_build_type")
       SET iret = uar_srvsetshort(hitem2,"reference_ind",atg_req_680200->mnemonic_criteria.
        simple_build_type.reference_ind)
       SET iret = uar_srvsetshort(hitem2,"reference_clinical_ind",atg_req_680200->mnemonic_criteria.
        simple_build_type.reference_clinical_ind)
       SET iret = uar_srvsetshort(hitem2,"reference_clinical_dept_ind",atg_req_680200->
        mnemonic_criteria.simple_build_type.reference_clinical_dept_ind)
       SET iret = uar_srvsetshort(hitem2,"reference_department_ind",atg_req_680200->mnemonic_criteria
        .simple_build_type.reference_department_ind)
       SET hitem2 = uar_srvgetstruct(hitem1,"medication_criteria")
       SET iret = uar_srvsetshort(hitem2,"build_order_level_ind",atg_req_680200->mnemonic_criteria.
        medication_criteria.build_order_level_ind)
       SET iret = uar_srvsetshort(hitem2,"build_ingredient_level_ind",atg_req_680200->
        mnemonic_criteria.medication_criteria.build_ingredient_level_ind)
       SET hitem3 = uar_srvgetstruct(hitem2,"complex_build_type")
       SET iret = uar_srvsetshort(hitem3,"reference_ind",atg_req_680200->mnemonic_criteria.
        medication_criteria.complex_build_type.reference_ind)
       SET iret = uar_srvsetshort(hitem3,"reference_ind",atg_req_680200->mnemonic_criteria.
        medication_criteria.complex_build_type.reference_ind)
       SET iret = uar_crmperform(hreq)
       IF (iret=0)
        CALL echo(build("Crm Perform Sucessful - Req#",requestid))
        SET hrep = uar_crmgetreply(hreq)
        SET nitem1cnt = uar_srvgetitemcount(hrep,"active_orders")
        SET stat = alterlist(atg_reply_680200->active_orders,nitem1cnt)
        FOR (nitem1idx = 0 TO (nitem1cnt - 1))
          SET hitem1 = uar_srvgetitem(hrep,"active_orders",nitem1idx)
          SET hitem2 = uar_srvgetstruct(hitem1,"core")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].core.order_id = uar_srvgetdouble(hitem2,
           "order_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].core.patient_id = uar_srvgetdouble(
           hitem2,"patient_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].core.version = uar_srvgetlong(hitem2,
           "version")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].core.order_status_cd = uar_srvgetdouble
          (hitem2,"order_status_cd")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].core.department_status_cd =
          uar_srvgetdouble(hitem2,"department_status_cd")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].core.responsible_provider_id =
          uar_srvgetdouble(hitem2,"responsible_provider_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].core.action_sequence = uar_srvgetlong(
           hitem2,"action_sequence")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].core.source_cd = uar_srvgetdouble(
           hitem2,"source_cd")
          SET hitem2 = uar_srvgetstruct(hitem1,"encounter")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].encounter.encounter_id =
          uar_srvgetdouble(hitem2,"encounter_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].encounter.encounter_type_class_cd =
          uar_srvgetdouble(hitem2,"encounter_type_class_cd")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].encounter.encounter_facility_id =
          uar_srvgetdouble(hitem2,"encounter_facility_id")
          SET hitem2 = uar_srvgetstruct(hitem1,"displays")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].displays.reference_name =
          uar_srvgetstringptr(hitem2,"reference_name")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].displays.clinical_name =
          uar_srvgetstringptr(hitem2,"clinical_name")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].displays.department_name =
          uar_srvgetstringptr(hitem2,"department_name")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].displays.clinical_display_line =
          uar_srvgetstringptr(hitem2,"clinical_display_line")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].displays.simplified_display_line =
          uar_srvgetstringptr(hitem2,"simplified_display_line")
          SET hitem2 = uar_srvgetstruct(hitem1,"comments")
          SET hitem3 = uar_srvgetstruct(hitem2,"comments_exist")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].comments.comments_exist.
          order_comment_ind = uar_srvgetshort(hitem3,"order_comment_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].comments.comments_exist.mar_note_ind =
          uar_srvgetshort(hitem3,"mar_note_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].comments.order_comment =
          uar_srvgetstringptr(hitem2,"order_comment")
          SET hitem2 = uar_srvgetstruct(hitem1,"schedule")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.current_start_dt_tm =
          uar_srvgetdateptr(hitem2,"current_start_dt_tm")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.current_start_tz =
          uar_srvgetlong(hitem2,"current_start_tz")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.projected_stop_dt_tm =
          uar_srvgetdateptr(hitem2,"projected_stop_dt_tm")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.projected_stop_tz =
          uar_srvgetlong(hitem2,"projected_stop_tz")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.stop_type_cd =
          uar_srvgetdouble(hitem2,"stop_type_cd")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.original_order_dt_tm =
          uar_srvgetdateptr(hitem2,"original_order_dt_tm")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.original_order_tz =
          uar_srvgetlong(hitem2,"original_order_tz")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.valid_dose_dt_tm =
          uar_srvgetdateptr(hitem2,"valid_dose_dt_tm")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.prn_ind = uar_srvgetshort(
           hitem2,"prn_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.constant_ind = uar_srvgetshort
          (hitem2,"constant_ind")
          SET hitem3 = uar_srvgetstruct(hitem2,"frequency")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.frequency.frequency_id =
          uar_srvgetdouble(hitem3,"frequency_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.frequency.one_time_ind =
          uar_srvgetshort(hitem3,"one_time_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.frequency.time_of_day_ind =
          uar_srvgetshort(hitem3,"time_of_day_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.frequency.day_of_week_ind =
          uar_srvgetshort(hitem3,"day_of_week_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.frequency.interval_ind =
          uar_srvgetshort(hitem3,"interval_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.frequency.unscheduled_ind =
          uar_srvgetshort(hitem3,"unscheduled_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.clinically_relevant_dt_tm =
          uar_srvgetdateptr(hitem2,"clinically_relevant_dt_tm")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].schedule.clinically_relevant_tz =
          uar_srvgetlong(hitem2,"clinically_relevant_tz")
          SET hitem2 = uar_srvgetstruct(hitem1,"reference_information")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].reference_information.catalog_id =
          uar_srvgetdouble(hitem2,"catalog_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].reference_information.synonym_id =
          uar_srvgetdouble(hitem2,"synonym_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].reference_information.catalog_type_cd
           = uar_srvgetdouble(hitem2,"catalog_type_cd")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].reference_information.activity_type_cd
           = uar_srvgetdouble(hitem2,"activity_type_cd")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].reference_information.
          clinical_category_cd = uar_srvgetdouble(hitem2,"clinical_category_cd")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].reference_information.
          order_entry_format_id = uar_srvgetdouble(hitem2,"order_entry_format_id")
          SET hitem2 = uar_srvgetstruct(hitem1,"review_information")
          SET hitem3 = uar_srvgetstruct(hitem2,"pharmacy_verification_status")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          pharmacy_verification_status.not_required_ind = uar_srvgetshort(hitem3,"not_required_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          pharmacy_verification_status.required_ind = uar_srvgetshort(hitem3,"required_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          pharmacy_verification_status.rejected_ind = uar_srvgetshort(hitem3,"rejected_ind")
          SET hitem3 = uar_srvgetstruct(hitem2,"physician_cosignature_status")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          physician_cosignature_status.not_required_ind = uar_srvgetshort(hitem3,"not_required_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          physician_cosignature_status.required_ind = uar_srvgetshort(hitem3,"required_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          physician_cosignature_status.refused_ind = uar_srvgetshort(hitem3,"refused_ind")
          SET hitem3 = uar_srvgetstruct(hitem2,"physician_validation_status")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          physician_validation_status.not_required_ind = uar_srvgetshort(hitem3,"not_required_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          physician_validation_status.required_ind = uar_srvgetshort(hitem3,"required_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          physician_validation_status.refused_ind = uar_srvgetshort(hitem3,"refused_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          need_nurse_review_ind = uar_srvgetshort(hitem2,"need_nurse_review_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.need_renewal_ind =
          uar_srvgetshort(hitem2,"need_renewal_ind")
          SET hitem3 = uar_srvgetstruct(hitem2,"pharmacy_clin_review_status")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.unset_ind = uar_srvgetshort(hitem3,"unset_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.needed_ind = uar_srvgetshort(hitem3,"needed_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.completed_ind = uar_srvgetshort(hitem3,"completed_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.rejected_ind = uar_srvgetshort(hitem3,"rejected_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.does_not_apply_ind = uar_srvgetshort(hitem3,
           "does_not_apply_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.superceded_ind = uar_srvgetshort(hitem3,"superceded_ind")
          SET hitem2 = uar_srvgetstruct(hitem1,"pending_status_information")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].pending_status_information.suspend_ind
           = uar_srvgetshort(hitem2,"suspend_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].pending_status_information.
          suspend_effective_dt_tm = uar_srvgetdateptr(hitem2,"suspend_effective_dt_tm")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].pending_status_information.
          suspend_effective_tz = uar_srvgetlong(hitem2,"suspend_effective_tz")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].pending_status_information.resume_ind
           = uar_srvgetshort(hitem2,"resume_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].pending_status_information.
          resume_effective_dt_tm = uar_srvgetdateptr(hitem2,"resume_effective_dt_tm")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].pending_status_information.
          resume_effective_tz = uar_srvgetlong(hitem2,"resume_effective_tz")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].pending_status_information.
          discontinue_ind = uar_srvgetshort(hitem2,"discontinue_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].pending_status_information.
          discontinue_effective_dt_tm = uar_srvgetdateptr(hitem2,"discontinue_effective_dt_tm")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].pending_status_information.
          discontinue_effective_tz = uar_srvgetlong(hitem2,"discontinue_effective_tz")
          SET nitem2cnt = uar_srvgetitemcount(hitem1,"diagnoses")
          SET stat = alterlist(atg_reply_680200->active_orders[(nitem1idx+ 1)].diagnoses,nitem2cnt)
          FOR (nitem2idx = 0 TO (nitem2cnt - 1))
            SET hitem2 = uar_srvgetitem(hitem1,"diagnoses",nitem2idx)
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            diagnosis_id = uar_srvgetdouble(hitem2,"diagnosis_id")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            nomenclature_id = uar_srvgetdouble(hitem2,"nomenclature_id")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].priority =
            uar_srvgetlong(hitem2,"priority")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].description
             = uar_srvgetstringptr(hitem2,"description")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            source_vocabulary_cd = uar_srvgetdouble(hitem2,"source_vocabulary_cd")
          ENDFOR
          SET hitem2 = uar_srvgetstruct(hitem1,"medication_information")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.
          medication_order_type_cd = uar_srvgetdouble(hitem2,"medication_order_type_cd")
          SET hitem3 = uar_srvgetstruct(hitem2,"originally_ordered_as_type")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.normal_ind = uar_srvgetshort(hitem3,"normal_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.prescription_ind = uar_srvgetshort(hitem3,"prescription_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.documented_ind = uar_srvgetshort(hitem3,"documented_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.patients_own_ind = uar_srvgetshort(hitem3,"patients_own_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.charge_only_ind = uar_srvgetshort(hitem3,"charge_only_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.satellite_ind = uar_srvgetshort(hitem3,"satellite_ind")
          SET nitem3cnt = uar_srvgetitemcount(hitem2,"ingredients")
          SET stat = alterlist(atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information
           .ingredients,nitem3cnt)
          FOR (nitem3idx = 0 TO (nitem3cnt - 1))
            SET hitem3 = uar_srvgetitem(hitem2,"ingredients",nitem3idx)
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].sequence = uar_srvgetlong(hitem3,"sequence")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].catalog_id = uar_srvgetdouble(hitem3,"catalog_id")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].synonym_id = uar_srvgetdouble(hitem3,"synonym_id")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].clinical_name = uar_srvgetstringptr(hitem3,"clinical_name")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].department_name = uar_srvgetstringptr(hitem3,"department_name")
            SET hitem4 = uar_srvgetstruct(hitem3,"dose")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].dose.strength = uar_srvgetdouble(hitem4,"strength")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].dose.strength_unit_cd = uar_srvgetdouble(hitem4,"strength_unit_cd")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].dose.volume = uar_srvgetdouble(hitem4,"volume")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].dose.volume_unit_cd = uar_srvgetdouble(hitem4,"volume_unit_cd")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].dose.freetext = uar_srvgetstringptr(hitem4,"freetext")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].dose.ordered = uar_srvgetdouble(hitem4,"ordered")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].dose.ordered_unit_cd = uar_srvgetdouble(hitem4,"ordered_unit_cd")
            SET hitem4 = uar_srvgetstruct(hitem3,"ingredient_type")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].ingredient_type.unknown_ind = uar_srvgetshort(hitem4,"unknown_ind")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].ingredient_type.medication_ind = uar_srvgetshort(hitem4,"medication_ind")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].ingredient_type.additive_ind = uar_srvgetshort(hitem4,"additive_ind")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].ingredient_type.diluent_ind = uar_srvgetshort(hitem4,"diluent_ind")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].ingredient_type.compound_parent_ind = uar_srvgetshort(hitem4,
             "compound_parent_ind")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].ingredient_type.compound_child_ind = uar_srvgetshort(hitem4,
             "compound_child_ind")
            SET hitem4 = uar_srvgetstruct(hitem3,"clinically_significant_info")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].clinically_significant_info.unknown_ind = uar_srvgetshort(hitem4,
             "unknown_ind")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].clinically_significant_info.not_significant_ind = uar_srvgetshort(hitem4,
             "not_significant_ind")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.ingredients[(
            nitem3idx+ 1)].clinically_significant_info.significant_ind = uar_srvgetshort(hitem4,
             "significant_ind")
          ENDFOR
          SET hitem3 = uar_srvgetstruct(hitem2,"pharmacy_type")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.pharmacy_type.
          sliding_scale_ind = uar_srvgetshort(hitem3,"sliding_scale_ind")
          SET hitem3 = uar_srvgetstruct(hitem2,"therapeutic_substitution")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.
          therapeutic_substitution.accepted_ind = uar_srvgetshort(hitem3,"accepted_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].medication_information.
          therapeutic_substitution.accepted_alternate_regimen_ind = uar_srvgetshort(hitem3,
           "accepted_alternate_regimen_ind")
          SET hitem2 = uar_srvgetstruct(hitem1,"last_action_information")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].last_action_information.
          action_personnel_id = uar_srvgetdouble(hitem2,"action_personnel_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].last_action_information.action_dt_tm =
          uar_srvgetdateptr(hitem2,"action_dt_tm")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].last_action_information.action_tz =
          uar_srvgetlong(hitem2,"action_tz")
          SET hitem2 = uar_srvgetstruct(hitem1,"template_information")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].template_information.template_order_id
           = uar_srvgetdouble(hitem2,"template_order_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].template_information.template_none_ind
           = uar_srvgetshort(hitem2,"template_none_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].template_information.template_order_ind
           = uar_srvgetshort(hitem2,"template_order_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].template_information.order_instance_ind
           = uar_srvgetshort(hitem2,"order_instance_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].template_information.
          future_recurring_template_ind = uar_srvgetshort(hitem2,"future_recurring_template_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].template_information.
          future_recurring_instance_ind = uar_srvgetshort(hitem2,"future_recurring_instance_ind")
          SET hitem2 = uar_srvgetstruct(hitem1,"order_set_information")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].order_set_information.parent_id =
          uar_srvgetdouble(hitem2,"parent_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].order_set_information.parent_name =
          uar_srvgetstringptr(hitem2,"parent_name")
          SET hitem2 = uar_srvgetstruct(hitem1,"supergroup_information")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].supergroup_information.parent_ind =
          uar_srvgetshort(hitem2,"parent_ind")
          SET nitem3cnt = uar_srvgetitemcount(hitem2,"components")
          SET stat = alterlist(atg_reply_680200->active_orders[(nitem1idx+ 1)].supergroup_information
           .components,nitem3cnt)
          FOR (nitem3idx = 0 TO (nitem3cnt - 1))
            SET hitem3 = uar_srvgetitem(hitem2,"components",nitem3idx)
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].supergroup_information.components[(
            nitem3idx+ 1)].order_id = uar_srvgetdouble(hitem3,"order_id")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].supergroup_information.components[(
            nitem3idx+ 1)].department_status_cd = uar_srvgetdouble(hitem3,"department_status_cd")
          ENDFOR
          SET hitem2 = uar_srvgetstruct(hitem1,"care_plan_information")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].care_plan_information.
          care_plan_catalog_id = uar_srvgetdouble(hitem2,"care_plan_catalog_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].care_plan_information.name =
          uar_srvgetstringptr(hitem2,"name")
          SET hitem2 = uar_srvgetstruct(hitem1,"link_information")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].link_information.link_number =
          uar_srvgetdouble(hitem2,"link_number")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].link_information.and_link_ind =
          uar_srvgetshort(hitem2,"and_link_ind")
          SET hitem2 = uar_srvgetstruct(hitem1,"venue")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].venue.acute_ind = uar_srvgetshort(
           hitem2,"acute_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].venue.ambulatory_ind = uar_srvgetshort(
           hitem2,"ambulatory_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].venue.prescription_ind =
          uar_srvgetshort(hitem2,"prescription_ind")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].venue.unknown_ind = uar_srvgetshort(
           hitem2,"unknown_ind")
          SET hitem2 = uar_srvgetstruct(hitem1,"extended")
          SET nitem3cnt = uar_srvgetitemcount(hitem2,"consulting_providers")
          SET stat = alterlist(atg_reply_680200->active_orders[(nitem1idx+ 1)].extended.
           consulting_providers,nitem3cnt)
          FOR (nitem3idx = 0 TO (nitem3cnt - 1))
           SET hitem3 = uar_srvgetitem(hitem2,"consulting_providers",nitem3idx)
           SET atg_reply_680200->active_orders[(nitem1idx+ 1)].extended.consulting_providers[(
           nitem3idx+ 1)].consulting_provider_id = uar_srvgetdouble(hitem3,"consulting_provider_id")
          ENDFOR
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].extended.end_state_reason_cd =
          uar_srvgetdouble(hitem2,"end_state_reason_cd")
          SET hitem2 = uar_srvgetstruct(hitem1,"pending_order_proposal_info")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].pending_order_proposal_info.
          order_proposal_id = uar_srvgetdouble(hitem2,"order_proposal_id")
          SET nitem2cnt = uar_srvgetitemcount(hitem1,"order_relations")
          SET stat = alterlist(atg_reply_680200->active_orders[(nitem1idx+ 1)].order_relations,
           nitem2cnt)
          FOR (nitem2idx = 0 TO (nitem2cnt - 1))
            SET hitem2 = uar_srvgetitem(hitem1,"order_relations",nitem2idx)
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].order_relations[(nitem2idx+ 1)].
            order_id = uar_srvgetdouble(hitem2,"order_id")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].order_relations[(nitem2idx+ 1)].
            action_sequence = uar_srvgetlong(hitem2,"action_sequence")
            SET atg_reply_680200->active_orders[(nitem1idx+ 1)].order_relations[(nitem2idx+ 1)].
            relation_type_cd = uar_srvgetdouble(hitem2,"relation_type_cd")
          ENDFOR
          SET hitem2 = uar_srvgetstruct(hitem1,"appointment")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].appointment.appointment_id =
          uar_srvgetdouble(hitem2,"appointment_id")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].appointment.appointment_state_cd =
          uar_srvgetdouble(hitem2,"appointment_state_cd")
          SET hitem2 = uar_srvgetstruct(hitem1,"order_mnemonic")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].order_mnemonic.mnemonic =
          uar_srvgetstringptr(hitem2,"mnemonic")
          SET atg_reply_680200->active_orders[(nitem1idx+ 1)].order_mnemonic.may_be_truncated_ind =
          uar_srvgetshort(hitem2,"may_be_truncated_ind")
        ENDFOR
        SET hitem1 = uar_srvgetstruct(hrep,"active_orders_page_context")
        SET atg_reply_680200->active_orders_page_context.context = uar_srvgetstringptr(hitem1,
         "context")
        SET atg_reply_680200->active_orders_page_context.has_previous_page_ind = uar_srvgetshort(
         hitem1,"has_previous_page_ind")
        SET atg_reply_680200->active_orders_page_context.has_next_page_ind = uar_srvgetshort(hitem1,
         "has_next_page_ind")
        SET nitem1cnt = uar_srvgetitemcount(hrep,"inactive_orders")
        SET stat = alterlist(atg_reply_680200->inactive_orders,nitem1cnt)
        FOR (nitem1idx = 0 TO (nitem1cnt - 1))
          SET hitem1 = uar_srvgetitem(hrep,"inactive_orders",nitem1idx)
          SET hitem2 = uar_srvgetstruct(hitem1,"core")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].core.order_id = uar_srvgetdouble(
           hitem2,"order_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].core.patient_id = uar_srvgetdouble(
           hitem2,"patient_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].core.version = uar_srvgetlong(hitem2,
           "version")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].core.order_status_cd =
          uar_srvgetdouble(hitem2,"order_status_cd")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].core.department_status_cd =
          uar_srvgetdouble(hitem2,"department_status_cd")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].core.responsible_provider_id =
          uar_srvgetdouble(hitem2,"responsible_provider_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].core.action_sequence = uar_srvgetlong
          (hitem2,"action_sequence")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].core.source_cd = uar_srvgetdouble(
           hitem2,"source_cd")
          SET hitem2 = uar_srvgetstruct(hitem1,"encounter")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].encounter.encounter_id =
          uar_srvgetdouble(hitem2,"encounter_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].encounter.encounter_type_class_cd =
          uar_srvgetdouble(hitem2,"encounter_type_class_cd")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].encounter.encounter_facility_id =
          uar_srvgetdouble(hitem2,"encounter_facility_id")
          SET hitem2 = uar_srvgetstruct(hitem1,"displays")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].displays.reference_name =
          uar_srvgetstringptr(hitem2,"reference_name")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].displays.clinical_name =
          uar_srvgetstringptr(hitem2,"clinical_name")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].displays.department_name =
          uar_srvgetstringptr(hitem2,"department_name")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].displays.clinical_display_line =
          uar_srvgetstringptr(hitem2,"clinical_display_line")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].displays.simplified_display_line =
          uar_srvgetstringptr(hitem2,"simplified_display_line")
          SET hitem2 = uar_srvgetstruct(hitem1,"comments")
          SET hitem3 = uar_srvgetstruct(hitem2,"comments_exist")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].comments.comments_exist.
          order_comment_ind = uar_srvgetshort(hitem3,"order_comment_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].comments.comments_exist.mar_note_ind
           = uar_srvgetshort(hitem3,"mar_note_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].comments.order_comment =
          uar_srvgetstringptr(hitem2,"order_comment")
          SET hitem2 = uar_srvgetstruct(hitem1,"schedule")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.current_start_dt_tm =
          uar_srvgetdateptr(hitem2,"current_start_dt_tm")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.current_start_tz =
          uar_srvgetlong(hitem2,"current_start_tz")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.projected_stop_dt_tm =
          uar_srvgetdateptr(hitem2,"projected_stop_dt_tm")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.projected_stop_tz =
          uar_srvgetlong(hitem2,"projected_stop_tz")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.stop_type_cd =
          uar_srvgetdouble(hitem2,"stop_type_cd")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.original_order_dt_tm =
          uar_srvgetdateptr(hitem2,"original_order_dt_tm")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.original_order_tz =
          uar_srvgetlong(hitem2,"original_order_tz")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.valid_dose_dt_tm =
          uar_srvgetdateptr(hitem2,"valid_dose_dt_tm")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.prn_ind = uar_srvgetshort(
           hitem2,"prn_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.constant_ind =
          uar_srvgetshort(hitem2,"constant_ind")
          SET hitem3 = uar_srvgetstruct(hitem2,"frequency")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.frequency.frequency_id =
          uar_srvgetdouble(hitem3,"frequency_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.frequency.one_time_ind =
          uar_srvgetshort(hitem3,"one_time_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.frequency.time_of_day_ind =
          uar_srvgetshort(hitem3,"time_of_day_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.frequency.day_of_week_ind =
          uar_srvgetshort(hitem3,"day_of_week_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.frequency.interval_ind =
          uar_srvgetshort(hitem3,"interval_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.frequency.unscheduled_ind =
          uar_srvgetshort(hitem3,"unscheduled_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.clinically_relevant_dt_tm =
          uar_srvgetdateptr(hitem2,"clinically_relevant_dt_tm")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].schedule.clinically_relevant_tz =
          uar_srvgetlong(hitem2,"clinically_relevant_tz")
          SET hitem2 = uar_srvgetstruct(hitem1,"reference_information")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].reference_information.catalog_id =
          uar_srvgetdouble(hitem2,"catalog_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].reference_information.synonym_id =
          uar_srvgetdouble(hitem2,"synonym_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].reference_information.catalog_type_cd
           = uar_srvgetdouble(hitem2,"catalog_type_cd")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].reference_information.
          activity_type_cd = uar_srvgetdouble(hitem2,"activity_type_cd")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].reference_information.
          clinical_category_cd = uar_srvgetdouble(hitem2,"clinical_category_cd")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].reference_information.
          order_entry_format_id = uar_srvgetdouble(hitem2,"order_entry_format_id")
          SET hitem2 = uar_srvgetstruct(hitem1,"review_information")
          SET hitem3 = uar_srvgetstruct(hitem2,"pharmacy_verification_status")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          pharmacy_verification_status.not_required_ind = uar_srvgetshort(hitem3,"not_required_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          pharmacy_verification_status.required_ind = uar_srvgetshort(hitem3,"required_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          pharmacy_verification_status.rejected_ind = uar_srvgetshort(hitem3,"rejected_ind")
          SET hitem3 = uar_srvgetstruct(hitem2,"physician_cosignature_status")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          physician_cosignature_status.not_required_ind = uar_srvgetshort(hitem3,"not_required_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          physician_cosignature_status.required_ind = uar_srvgetshort(hitem3,"required_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          physician_cosignature_status.refused_ind = uar_srvgetshort(hitem3,"refused_ind")
          SET hitem3 = uar_srvgetstruct(hitem2,"physician_validation_status")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          physician_validation_status.not_required_ind = uar_srvgetshort(hitem3,"not_required_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          physician_validation_status.required_ind = uar_srvgetshort(hitem3,"required_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          physician_validation_status.refused_ind = uar_srvgetshort(hitem3,"refused_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          need_nurse_review_ind = uar_srvgetshort(hitem2,"need_nurse_review_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.need_renewal_ind
           = uar_srvgetshort(hitem2,"need_renewal_ind")
          SET hitem3 = uar_srvgetstruct(hitem2,"pharmacy_clin_review_status")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.unset_ind = uar_srvgetshort(hitem3,"unset_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.needed_ind = uar_srvgetshort(hitem3,"needed_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.completed_ind = uar_srvgetshort(hitem3,"completed_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.rejected_ind = uar_srvgetshort(hitem3,"rejected_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.does_not_apply_ind = uar_srvgetshort(hitem3,
           "does_not_apply_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].review_information.
          pharmacy_clin_review_status.superceded_ind = uar_srvgetshort(hitem3,"superceded_ind")
          SET hitem2 = uar_srvgetstruct(hitem1,"pending_status_information")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].pending_status_information.
          suspend_ind = uar_srvgetshort(hitem2,"suspend_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].pending_status_information.
          suspend_effective_dt_tm = uar_srvgetdateptr(hitem2,"suspend_effective_dt_tm")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].pending_status_information.
          suspend_effective_tz = uar_srvgetlong(hitem2,"suspend_effective_tz")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].pending_status_information.resume_ind
           = uar_srvgetshort(hitem2,"resume_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].pending_status_information.
          resume_effective_dt_tm = uar_srvgetdateptr(hitem2,"resume_effective_dt_tm")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].pending_status_information.
          resume_effective_tz = uar_srvgetlong(hitem2,"resume_effective_tz")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].pending_status_information.
          discontinue_ind = uar_srvgetshort(hitem2,"discontinue_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].pending_status_information.
          discontinue_effective_dt_tm = uar_srvgetdateptr(hitem2,"discontinue_effective_dt_tm")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].pending_status_information.
          discontinue_effective_tz = uar_srvgetlong(hitem2,"discontinue_effective_tz")
          SET nitem2cnt = uar_srvgetitemcount(hitem1,"diagnoses")
          SET stat = alterlist(atg_reply_680200->inactive_orders[(nitem1idx+ 1)].diagnoses,nitem2cnt)
          FOR (nitem2idx = 0 TO (nitem2cnt - 1))
            SET hitem2 = uar_srvgetitem(hitem1,"diagnoses",nitem2idx)
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            diagnosis_id = uar_srvgetdouble(hitem2,"diagnosis_id")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            nomenclature_id = uar_srvgetdouble(hitem2,"nomenclature_id")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].priority
             = uar_srvgetlong(hitem2,"priority")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            description = uar_srvgetstringptr(hitem2,"description")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            source_vocabulary_cd = uar_srvgetdouble(hitem2,"source_vocabulary_cd")
          ENDFOR
          SET hitem2 = uar_srvgetstruct(hitem1,"medication_information")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.
          medication_order_type_cd = uar_srvgetdouble(hitem2,"medication_order_type_cd")
          SET hitem3 = uar_srvgetstruct(hitem2,"originally_ordered_as_type")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.normal_ind = uar_srvgetshort(hitem3,"normal_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.prescription_ind = uar_srvgetshort(hitem3,"prescription_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.documented_ind = uar_srvgetshort(hitem3,"documented_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.patients_own_ind = uar_srvgetshort(hitem3,"patients_own_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.charge_only_ind = uar_srvgetshort(hitem3,"charge_only_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.satellite_ind = uar_srvgetshort(hitem3,"satellite_ind")
          SET nitem3cnt = uar_srvgetitemcount(hitem2,"ingredients")
          SET stat = alterlist(atg_reply_680200->inactive_orders[(nitem1idx+ 1)].
           medication_information.ingredients,nitem3cnt)
          FOR (nitem3idx = 0 TO (nitem3cnt - 1))
            SET hitem3 = uar_srvgetitem(hitem2,"ingredients",nitem3idx)
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].sequence = uar_srvgetlong(hitem3,"sequence")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].catalog_id = uar_srvgetdouble(hitem3,"catalog_id")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].synonym_id = uar_srvgetdouble(hitem3,"synonym_id")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].clinical_name = uar_srvgetstringptr(hitem3,"clinical_name")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].department_name = uar_srvgetstringptr(hitem3,"department_name")
            SET hitem4 = uar_srvgetstruct(hitem3,"dose")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.strength = uar_srvgetdouble(hitem4,"strength")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.strength_unit_cd = uar_srvgetdouble(hitem4,"strength_unit_cd")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.volume = uar_srvgetdouble(hitem4,"volume")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.volume_unit_cd = uar_srvgetdouble(hitem4,"volume_unit_cd")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.freetext = uar_srvgetstringptr(hitem4,"freetext")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.ordered = uar_srvgetdouble(hitem4,"ordered")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.ordered_unit_cd = uar_srvgetdouble(hitem4,"ordered_unit_cd")
            SET hitem4 = uar_srvgetstruct(hitem3,"ingredient_type")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.unknown_ind = uar_srvgetshort(hitem4,"unknown_ind")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.medication_ind = uar_srvgetshort(hitem4,"medication_ind")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.additive_ind = uar_srvgetshort(hitem4,"additive_ind")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.diluent_ind = uar_srvgetshort(hitem4,"diluent_ind")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.compound_parent_ind = uar_srvgetshort(hitem4,
             "compound_parent_ind")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.compound_child_ind = uar_srvgetshort(hitem4,
             "compound_child_ind")
            SET hitem4 = uar_srvgetstruct(hitem3,"clinically_significant_info")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].clinically_significant_info.unknown_ind = uar_srvgetshort(hitem4,
             "unknown_ind")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].clinically_significant_info.not_significant_ind = uar_srvgetshort(hitem4,
             "not_significant_ind")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].clinically_significant_info.significant_ind = uar_srvgetshort(hitem4,
             "significant_ind")
          ENDFOR
          SET hitem3 = uar_srvgetstruct(hitem2,"pharmacy_type")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.pharmacy_type.
          sliding_scale_ind = uar_srvgetshort(hitem3,"sliding_scale_ind")
          SET hitem3 = uar_srvgetstruct(hitem2,"therapeutic_substitution")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.
          therapeutic_substitution.accepted_ind = uar_srvgetshort(hitem3,"accepted_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].medication_information.
          therapeutic_substitution.accepted_alternate_regimen_ind = uar_srvgetshort(hitem3,
           "accepted_alternate_regimen_ind")
          SET hitem2 = uar_srvgetstruct(hitem1,"last_action_information")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].last_action_information.
          action_personnel_id = uar_srvgetdouble(hitem2,"action_personnel_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].last_action_information.action_dt_tm
           = uar_srvgetdateptr(hitem2,"action_dt_tm")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].last_action_information.action_tz =
          uar_srvgetlong(hitem2,"action_tz")
          SET hitem2 = uar_srvgetstruct(hitem1,"template_information")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].template_information.
          template_order_id = uar_srvgetdouble(hitem2,"template_order_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].template_information.
          template_none_ind = uar_srvgetshort(hitem2,"template_none_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].template_information.
          template_order_ind = uar_srvgetshort(hitem2,"template_order_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].template_information.
          order_instance_ind = uar_srvgetshort(hitem2,"order_instance_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].template_information.
          future_recurring_template_ind = uar_srvgetshort(hitem2,"future_recurring_template_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].template_information.
          future_recurring_instance_ind = uar_srvgetshort(hitem2,"future_recurring_instance_ind")
          SET hitem2 = uar_srvgetstruct(hitem1,"order_set_information")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].order_set_information.parent_id =
          uar_srvgetdouble(hitem2,"parent_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].order_set_information.parent_name =
          uar_srvgetstringptr(hitem2,"parent_name")
          SET hitem2 = uar_srvgetstruct(hitem1,"supergroup_information")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].supergroup_information.parent_ind =
          uar_srvgetshort(hitem2,"parent_ind")
          SET nitem3cnt = uar_srvgetitemcount(hitem2,"components")
          SET stat = alterlist(atg_reply_680200->inactive_orders[(nitem1idx+ 1)].
           supergroup_information.components,nitem3cnt)
          FOR (nitem3idx = 0 TO (nitem3cnt - 1))
            SET hitem3 = uar_srvgetitem(hitem2,"components",nitem3idx)
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].supergroup_information.components[(
            nitem3idx+ 1)].order_id = uar_srvgetdouble(hitem3,"order_id")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].supergroup_information.components[(
            nitem3idx+ 1)].department_status_cd = uar_srvgetdouble(hitem3,"department_status_cd")
          ENDFOR
          SET hitem2 = uar_srvgetstruct(hitem1,"care_plan_information")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].care_plan_information.
          care_plan_catalog_id = uar_srvgetdouble(hitem2,"care_plan_catalog_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].care_plan_information.name =
          uar_srvgetstringptr(hitem2,"name")
          SET hitem2 = uar_srvgetstruct(hitem1,"link_information")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].link_information.link_number =
          uar_srvgetdouble(hitem2,"link_number")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].link_information.and_link_ind =
          uar_srvgetshort(hitem2,"and_link_ind")
          SET hitem2 = uar_srvgetstruct(hitem1,"venue")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].venue.acute_ind = uar_srvgetshort(
           hitem2,"acute_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].venue.ambulatory_ind =
          uar_srvgetshort(hitem2,"ambulatory_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].venue.prescription_ind =
          uar_srvgetshort(hitem2,"prescription_ind")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].venue.unknown_ind = uar_srvgetshort(
           hitem2,"unknown_ind")
          SET hitem2 = uar_srvgetstruct(hitem1,"extended")
          SET nitem3cnt = uar_srvgetitemcount(hitem2,"consulting_providers")
          SET stat = alterlist(atg_reply_680200->inactive_orders[(nitem1idx+ 1)].extended.
           consulting_providers,nitem3cnt)
          FOR (nitem3idx = 0 TO (nitem3cnt - 1))
           SET hitem3 = uar_srvgetitem(hitem2,"consulting_providers",nitem3idx)
           SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].extended.consulting_providers[(
           nitem3idx+ 1)].consulting_provider_id = uar_srvgetdouble(hitem3,"consulting_provider_id")
          ENDFOR
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].extended.end_state_reason_cd =
          uar_srvgetdouble(hitem2,"end_state_reason_cd")
          SET hitem2 = uar_srvgetstruct(hitem1,"pending_order_proposal_info")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].pending_order_proposal_info.
          order_proposal_id = uar_srvgetdouble(hitem2,"order_proposal_id")
          SET nitem2cnt = uar_srvgetitemcount(hitem1,"order_relations")
          SET stat = alterlist(atg_reply_680200->inactive_orders[(nitem1idx+ 1)].order_relations,
           nitem2cnt)
          FOR (nitem2idx = 0 TO (nitem2cnt - 1))
            SET hitem2 = uar_srvgetitem(hitem1,"order_relations",nitem2idx)
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].order_relations[(nitem2idx+ 1)].
            order_id = uar_srvgetdouble(hitem2,"order_id")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].order_relations[(nitem2idx+ 1)].
            action_sequence = uar_srvgetlong(hitem2,"action_sequence")
            SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].order_relations[(nitem2idx+ 1)].
            relation_type_cd = uar_srvgetdouble(hitem2,"relation_type_cd")
          ENDFOR
          SET hitem2 = uar_srvgetstruct(hitem1,"appointment")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].appointment.appointment_id =
          uar_srvgetdouble(hitem2,"appointment_id")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].appointment.appointment_state_cd =
          uar_srvgetdouble(hitem2,"appointment_state_cd")
          SET hitem2 = uar_srvgetstruct(hitem1,"order_mnemonic")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].order_mnemonic.mnemonic =
          uar_srvgetstringptr(hitem2,"mnemonic")
          SET atg_reply_680200->inactive_orders[(nitem1idx+ 1)].order_mnemonic.may_be_truncated_ind
           = uar_srvgetshort(hitem2,"may_be_truncated_ind")
        ENDFOR
        SET hitem1 = uar_srvgetstruct(hrep,"inactive_orders_page_context")
        SET atg_reply_680200->inactive_orders_page_context.context = uar_srvgetstringptr(hitem1,
         "context")
        SET atg_reply_680200->inactive_orders_page_context.has_previous_page_ind = uar_srvgetshort(
         hitem1,"has_previous_page_ind")
        SET atg_reply_680200->inactive_orders_page_context.has_next_page_ind = uar_srvgetshort(hitem1,
         "has_next_page_ind")
        SET nitem1cnt = uar_srvgetitemcount(hrep,"order_proposals")
        SET stat = alterlist(atg_reply_680200->order_proposals,nitem1cnt)
        FOR (nitem1idx = 0 TO (nitem1cnt - 1))
          SET hitem1 = uar_srvgetitem(hrep,"order_proposals",nitem1idx)
          SET hitem2 = uar_srvgetstruct(hitem1,"core")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.order_proposal_id =
          uar_srvgetdouble(hitem2,"order_proposal_id")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.order_id = uar_srvgetdouble(
           hitem2,"order_id")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.projected_order_id =
          uar_srvgetdouble(hitem2,"projected_order_id")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.patient_id = uar_srvgetdouble(
           hitem2,"patient_id")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.encounter_id = uar_srvgetdouble(
           hitem2,"encounter_id")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.responsible_provider_id =
          uar_srvgetdouble(hitem2,"responsible_provider_id")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.data_enterer_id =
          uar_srvgetdouble(hitem2,"data_enterer_id")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.resolved_by_personnel_id =
          uar_srvgetdouble(hitem2,"resolved_by_personnel_id")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.status_cd = uar_srvgetdouble(
           hitem2,"status_cd")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.source_type_cd =
          uar_srvgetdouble(hitem2,"source_type_cd")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.proposed_action_type_cd =
          uar_srvgetdouble(hitem2,"proposed_action_type_cd")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.from_action_sequence =
          uar_srvgetlong(hitem2,"from_action_sequence")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.to_action_sequence =
          uar_srvgetlong(hitem2,"to_action_sequence")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].core.communication_type_cd =
          uar_srvgetdouble(hitem2,"communication_type_cd")
          SET hitem2 = uar_srvgetstruct(hitem1,"displays")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].displays.reference_name =
          uar_srvgetstringptr(hitem2,"reference_name")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].displays.clinical_name =
          uar_srvgetstringptr(hitem2,"clinical_name")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].displays.department_name =
          uar_srvgetstringptr(hitem2,"department_name")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].displays.clinical_display_line =
          uar_srvgetstringptr(hitem2,"clinical_display_line")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].displays.simplified_display_line =
          uar_srvgetstringptr(hitem2,"simplified_display_line")
          SET hitem2 = uar_srvgetstruct(hitem1,"reference_information")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].reference_information.synonym_id =
          uar_srvgetdouble(hitem2,"synonym_id")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].reference_information.
          order_entry_format_id = uar_srvgetdouble(hitem2,"order_entry_format_id")
          SET hitem2 = uar_srvgetstruct(hitem1,"medication_information")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.
          medication_order_type_cd = uar_srvgetdouble(hitem2,"medication_order_type_cd")
          SET hitem3 = uar_srvgetstruct(hitem2,"originally_ordered_as_type")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.normal_ind = uar_srvgetshort(hitem3,"normal_ind")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.prescription_ind = uar_srvgetshort(hitem3,"prescription_ind")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.documented_ind = uar_srvgetshort(hitem3,"documented_ind")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.patients_own_ind = uar_srvgetshort(hitem3,"patients_own_ind")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.charge_only_ind = uar_srvgetshort(hitem3,"charge_only_ind")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.
          originally_ordered_as_type.satellite_ind = uar_srvgetshort(hitem3,"satellite_ind")
          SET nitem3cnt = uar_srvgetitemcount(hitem2,"ingredients")
          SET stat = alterlist(atg_reply_680200->order_proposals[nitem1cnt].medication_information.
           ingredients,nitem3cnt)
          FOR (nitem3idx = 0 TO (nitem3cnt - 1))
            SET hitem3 = uar_srvgetitem(hitem2,"ingredients",nitem3idx)
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].sequence = uar_srvgetlong(hitem3,"sequence")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].synonym_id = uar_srvgetdouble(hitem3,"synonym_id")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].clinical_name = uar_srvgetstringptr(hitem3,"clinical_name")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].department_name = uar_srvgetstringptr(hitem3,"department_name")
            SET hitem4 = uar_srvgetstruct(hitem3,"source_type")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].source_type.user_ind = uar_srvgetshort(hitem4,"user_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].source_type.system_balanced_ind = uar_srvgetshort(hitem4,
             "system_balanced_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].source_type.system_auto_product_assign_ind = uar_srvgetshort(hitem4,
             "system_auto_product_assign_ind")
            SET hitem4 = uar_srvgetstruct(hitem3,"alter_type")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].alter_type.unchanged_ind = uar_srvgetshort(hitem4,"unchanged_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].alter_type.added_ind = uar_srvgetshort(hitem4,"added_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].alter_type.modified_ind = uar_srvgetshort(hitem4,"modified_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].alter_type.deleted_ind = uar_srvgetshort(hitem4,"deleted_ind")
            SET hitem4 = uar_srvgetstruct(hitem3,"dose")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.strength = uar_srvgetdouble(hitem4,"strength")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.strength_unit_cd = uar_srvgetdouble(hitem4,"strength_unit_cd")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.volume = uar_srvgetdouble(hitem4,"volume")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.volume_unit_cd = uar_srvgetdouble(hitem4,"volume_unit_cd")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.freetext = uar_srvgetstringptr(hitem4,"freetext")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.ordered = uar_srvgetdouble(hitem4,"ordered")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.ordered_unit_cd = uar_srvgetdouble(hitem4,"ordered_unit_cd")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].dose.calculator_text = uar_srvgetstringptr(hitem4,"calculator_text")
            SET hitem4 = uar_srvgetstruct(hitem3,"ingredient_type")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.unknown_ind = uar_srvgetshort(hitem4,"unknown_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.medication_ind = uar_srvgetshort(hitem4,"medication_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.additive_ind = uar_srvgetshort(hitem4,"additive_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.diluent_ind = uar_srvgetshort(hitem4,"diluent_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.compound_parent_ind = uar_srvgetshort(hitem4,
             "compound_parent_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].ingredient_type.compound_child_ind = uar_srvgetshort(hitem4,
             "compound_child_ind")
            SET hitem4 = uar_srvgetstruct(hitem3,"clinically_significant_info")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].clinically_significant_info.unknown_ind = uar_srvgetshort(hitem4,
             "unknown_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].clinically_significant_info.not_significant_ind = uar_srvgetshort(hitem4,
             "not_significant_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].clinically_significant_info.significant_ind = uar_srvgetshort(hitem4,
             "significant_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].bag_frequency_cd = uar_srvgetdouble(hitem3,"bag_frequency_cd")
            SET hitem4 = uar_srvgetstruct(hitem3,"include_in_total_volume_type")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].include_in_total_volume_type.unknown_ind = uar_srvgetshort(hitem4,
             "unknown_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].include_in_total_volume_type.not_included_ind = uar_srvgetshort(hitem4,
             "not_included_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].include_in_total_volume_type.included_ind = uar_srvgetshort(hitem4,
             "included_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].normalized_rate = uar_srvgetdouble(hitem3,"normalized_rate")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].normalized_rate_unit_cd = uar_srvgetdouble(hitem3,
             "normalized_rate_unit_cd")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].concentration = uar_srvgetdouble(hitem3,"concentration")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.ingredients[
            (nitem3idx+ 1)].concentration_unit_cd = uar_srvgetdouble(hitem3,"concentration_unit_cd")
          ENDFOR
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].medication_information.
          iv_set_synonym_id = uar_srvgetdouble(hitem2,"iv_set_synonym_id")
          SET hitem2 = uar_srvgetstruct(hitem1,"comments")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].comments.order_comment =
          uar_srvgetstringptr(hitem2,"order_comment")
          SET nitem2cnt = uar_srvgetitemcount(hitem1,"diagnoses")
          SET stat = alterlist(atg_reply_680200->order_proposals[nitem1cnt].diagnoses,nitem2cnt)
          FOR (nitem2idx = 0 TO (nitem2cnt - 1))
            SET hitem2 = uar_srvgetitem(hitem1,"diagnoses",nitem2idx)
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            diagnosis_id = uar_srvgetdouble(hitem2,"diagnosis_id")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            nomenclature_id = uar_srvgetdouble(hitem2,"nomenclature_id")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].priority
             = uar_srvgetlong(hitem2,"proposed_action_type_cd")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            description = uar_srvgetstringptr(hitem2,"description")
            SET hitem3 = uar_srvgetstruct(hitem2,"alter_type")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            alter_type.unchanged_ind = uar_srvgetshort(hitem3,"unchanged_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            alter_type.added_ind = uar_srvgetshort(hitem3,"added_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            alter_type.modified_ind = uar_srvgetshort(hitem3,"modified_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            alter_type.deleted_ind = uar_srvgetshort(hitem3,"deleted_ind")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            source_vocabulary_cd = uar_srvgetdouble(hitem2,"source_vocabulary_cd")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].diagnoses[(nitem2idx+ 1)].
            source_identifier = uar_srvgetstringptr(hitem2,"source_identifier")
          ENDFOR
          SET nitem2cnt = uar_srvgetitemcount(hitem1,"order_details")
          SET stat = alterlist(atg_reply_680200->order_proposals[nitem1cnt].order_details,nitem2cnt)
          FOR (nitem2idx = 0 TO (nitem2cnt - 1))
            SET hitem2 = uar_srvgetitem(hitem1,"order_details",nitem2idx)
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_details[(nitem2idx+ 1)].
            oe_field_id = uar_srvgetdouble(hitem2,"oe_field_id")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_details[(nitem2idx+ 1)].
            oe_field_meaning = uar_srvgetstringptr(hitem2,"oe_field_meaning")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_details[(nitem2idx+ 1)].
            oe_field_meaning_id = uar_srvgetdouble(hitem2,"oe_field_meaning_id")
            SET nitem3cnt = uar_srvgetitemcount(hitem2,"detail_values")
            SET stat = alterlist(atg_reply_680200->order_proposals[nitem1cnt].order_details.
             detail_values,nitem3cnt)
            FOR (nitem3idx = 0 TO (nitem3cnt - 1))
              SET hitem3 = uar_srvgetitem(hitem2,"detail_values",nitem3idx)
              SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_details[(nitem2idx+ 1)].
              detail_values[(nitem3idx+ 1)].oe_field_value = uar_srvgetdouble(hitem3,"oe_field_value"
               )
              SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_details[(nitem2idx+ 1)].
              detail_values[(nitem3idx+ 1)].oe_field_display_value = uar_srvgetstringptr(hitem3,
               "oe_field_display_value")
              SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_details[(nitem2idx+ 1)].
              detail_values[(nitem3idx+ 1)].oe_field_dt_tm_value = uar_srvgetdateptr(hitem3,
               "oe_field_dt_tm_value")
              SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_details[(nitem2idx+ 1)].
              detail_values[(nitem3idx+ 1)].oe_field_tz = uar_srvgetlong(hitem3,"oe_field_tz")
              SET hitem4 = uar_srvgetstruct(hitem3,"alter_type")
              SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_details[(nitem2idx+ 1)].
              detail_values[(nitem3idx+ 1)].alter_type.unchanged_ind = uar_srvgetshort(hitem4,
               "unchanged_ind")
              SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_details[(nitem2idx+ 1)].
              detail_values[(nitem3idx+ 1)].alter_type.added_ind = uar_srvgetshort(hitem4,"added_ind"
               )
              SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_details[(nitem2idx+ 1)].
              detail_values[(nitem3idx+ 1)].alter_type.modified_ind = uar_srvgetshort(hitem4,
               "modified_ind")
              SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_details[(nitem2idx+ 1)].
              detail_values[(nitem3idx+ 1)].alter_type.deleted_ind = uar_srvgetshort(hitem4,
               "deleted_ind")
            ENDFOR
          ENDFOR
          SET hitem2 = uar_srvgetstruct(hitem1,"venue")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].venue.acute_ind = uar_srvgetshort(
           hitem2,"acute_ind")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].venue.ambulatory_ind =
          uar_srvgetshort(hitem2,"ambulatory_ind")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].venue.prescription_ind =
          uar_srvgetshort(hitem2,"prescription_ind")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].venue.unknown_ind = uar_srvgetshort(
           hitem2,"unknown_ind")
          SET nitem2cnt = uar_srvgetitemcount(hitem1,"adhoc_frequency_times")
          SET stat = alterlist(atg_reply_680200->order_proposals[nitem1cnt].adhoc_frequency_times,
           nitem2cnt)
          FOR (nitem2idx = 0 TO (nitem2cnt - 1))
            SET hitem2 = uar_srvgetitem(hitem1,"adhoc_frequency_times",nitem2idx)
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].adhoc_frequency_times[(nitem2idx+ 1
            )].sequence = uar_srvgetlong(hitem2,"sequence")
            SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].adhoc_frequency_times[(nitem2idx+ 1
            )].time_of_day = uar_srvgetshort(hitem2,"time_of_day")
          ENDFOR
          SET hitem2 = uar_srvgetstruct(hitem1,"order_set_information")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_set_information.parent_id =
          uar_srvgetdouble(hitem2,"parent_id")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_set_information.parent_name =
          uar_srvgetstringptr(hitem2,"parent_name")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].order_set_information.
          parent_resolved_ind = uar_srvgetshort(hitem2,"parent_resolved_ind")
          SET hitem2 = uar_srvgetstruct(hitem1,"proposal_mnemonic")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].proposal_mnemonic.mnemonic =
          uar_srvgetstringptr(hitem2,"mnemonic")
          SET atg_reply_680200->order_proposals[(nitem1idx+ 1)].proposal_mnemonic.
          may_be_truncated_ind = uar_srvgetshort(hitem2,"may_be_truncated_ind")
        ENDFOR
        SET hitem1 = uar_srvgetstruct(hrep,"status_data")
        SET atg_reply_680200->status_data.status = uar_srvgetstringptr(hitem1,"status")
        SET hitem2 = uar_srvgetitem(hitem1,"subeventstatus",0)
        SET atg_reply_680200->status_data.subeventstatus[1].operationname = uar_srvgetstringptr(
         hitem2,"OperationName")
        SET atg_reply_680200->status_data.subeventstatus[1].operationstatus = uar_srvgetstringptr(
         hitem2,"OperationStatus")
        SET atg_reply_680200->status_data.subeventstatus[1].targetobjectname = uar_srvgetstringptr(
         hitem2,"TargetObjectName")
        SET atg_reply_680200->status_data.subeventstatus[1].targetobjectvalue = uar_srvgetstringptr(
         hitem2,"TargetObjectValue")
       ELSE
        CALL echo(build("Crm Perform Failed - Req#",requestid))
       ENDIF
      ENDIF
      CALL echo(build("Crm End Request - Req#",requestid))
      CALL uar_crmendreq(hreq)
     ELSE
      CALL echo(build("Crm Begin Req Failed - Req#",requestid))
     ENDIF
     CALL echo(build("Crm End Task - Task#",taskid))
     CALL uar_crmendtask(htask)
    ELSE
     CALL echo(build("Crm Begin Task Failed - Task#",taskid))
    ENDIF
    CALL echo(build("Crm End App - App#",applicationid))
    CALL uar_crmendapp(happ)
   ELSE
    CALL echo(build("Crm Begin App Failed - App#",applicationid))
   ENDIF
 END ;Subroutine
 DECLARE atginitallergy(null) = null
 DECLARE atggetallergy(person_id=f8) = i4
 FREE SET atg_alg_request
 RECORD atg_alg_request(
   1 person_id = f8
 )
 FREE SET atg_alg_reply
 RECORD atg_alg_reply(
   1 person_org_sec_on = i2
   1 allergy_qual = i4
   1 allergy[*]
     2 allergy_id = f8
     2 allergy_instance_id = f8
     2 encntr_id = f8
     2 organization_id = f8
     2 source_string = vc
     2 substance_nom_id = f8
     2 substance_ftdesc = vc
     2 substance_type_cd = f8
     2 substance_type_disp = c40
     2 substance_type_mean = c12
     2 reaction_class_cd = f8
     2 reaction_class_disp = c40
     2 reaction_class_mean = c12
     2 severity_cd = f8
     2 severity_disp = c40
     2 severity_mean = c12
     2 source_of_info_cd = f8
     2 source_of_info_disp = c40
     2 source_of_info_mean = c12
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 onset_precision_cd = f8
     2 onset_precision_disp = c40
     2 onset_precision_flag = i2
     2 reaction_status_cd = f8
     2 reaction_status_disp = c40
     2 reaction_status_mean = c12
     2 reaction_status_dt_tm = dq8
     2 created_dt_tm = dq8
     2 created_prsnl_id = f8
     2 created_prsnl_name = vc
     2 reviewed_dt_tm = dq8
     2 reviewed_tz = i4
     2 reviewed_prsnl_id = f8
     2 reviewed_prsnl_name = vc
     2 cancel_reason_cd = f8
     2 cancel_reason_disp = c40
     2 active_ind = i2
     2 orig_prsnl_id = f8
     2 orig_prsnl_name = vc
     2 updt_id = f8
     2 updt_name = vc
     2 updt_dt_tm = dq8
     2 cki = vc
     2 concept_source_cd = f8
     2 concept_source_disp = c40
     2 concept_source_mean = c12
     2 concept_identifier = vc
     2 cancel_dt_tm = dq8
     2 cancel_prsnl_id = f8
     2 cancel_prsnl_name = vc
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 end_effective_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 source_of_info_ft = vc
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 rec_src_identifier = vc
     2 rec_src_string = vc
     2 rec_src_vocab_cd = f8
     2 verified_status_flag = i2
     2 reaction_qual = i4
     2 cmb_instance_id = f8
     2 cmb_flag = i2
     2 cmb_prsnl_id = f8
     2 cmb_prsnl_name = vc
     2 cmb_person_id = f8
     2 cmb_person_name = vc
     2 cmb_dt_tm = dq8
     2 cmb_tz = i4
     2 reaction[*]
       3 allergy_instance_id = f8
       3 reaction_id = f8
       3 reaction_nom_id = f8
       3 source_string = vc
       3 reaction_ftdesc = vc
       3 beg_effective_dt_tm = dq8
       3 active_ind = i2
       3 end_effective_dt_tm = dq8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 cmb_reaction_id = f8
       3 cmb_flag = i2
       3 cmb_prsnl_id = f8
       3 cmb_prsnl_name = vc
       3 cmb_person_id = f8
       3 cmb_person_name = vc
       3 cmb_dt_tm = dq8
       3 cmb_tz = i4
     2 comment_qual = i4
     2 comment[*]
       3 allergy_comment_id = f8
       3 allergy_instance_id = f8
       3 organization_id = f8
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 comment_prsnl_name = vc
       3 allergy_comment = vc
       3 beg_effective_dt_tm = dq8
       3 beg_effective_tz = i4
       3 active_ind = i4
       3 end_effective_dt_tm = dq8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 cmb_comment_id = f8
       3 cmb_flag = i2
       3 cmb_prsnl_id = f8
       3 cmb_prsnl_name = vc
       3 cmb_person_id = f8
       3 cmb_person_name = vc
       3 cmb_dt_tm = dq8
       3 cmb_tz = i4
   1 adr_knt = i4
   1 adr[*]
     2 activity_data_reltn_id = f8
     2 person_id = f8
     2 activity_entity_name = vc
     2 activity_entity_id = f8
     2 activity_entity_inst_id = f8
     2 reltn_entity_name = vc
     2 reltn_entity_id = f8
     2 reltn_entity_all_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SUBROUTINE atginitallergy(null)
  SET stat = initrec(atg_alg_request)
  SET stat = initrec(atg_alg_reply)
 END ;Subroutine
 SUBROUTINE atggetallergy(person_id)
   SET atg_alg_request->person_id = person_id
   SET trace = recpersist
   EXECUTE cps_get_allergy  WITH replace("REQUEST","ATG_ALG_REQUEST"), replace("REPLY",
    "ATG_ALG_REPLY")
   SET trace = norecpersist
   RETURN(0)
 END ;Subroutine
 DECLARE atginitdiagnosis(null) = null
 DECLARE atggetdiagnosis(diag_id=f8,person_id=f8,encntr_id=f8,except_encntr_ind=i2) = i4
 FREE SET atg_diag_request
 RECORD atg_diag_request(
   1 diag_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 except_encntr_ind = i2
 )
 FREE SET atg_diag_reply
 RECORD atg_diag_reply(
   1 diag_qual = i4
   1 diag[*]
     2 diagnosis_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 nomenclature_id = f8
     2 diag_dt_tm = dq8
     2 diag_type_cd = f8
     2 diagnostic_category_cd = f8
     2 diag_priority = i4
     2 diag_prsnl_id = f8
     2 diag_prsnl_name = vc
     2 diag_class_cd = f8
     2 confid_level_cd = f8
     2 attestation_dt_tm = dq8
     2 reference_nbr = vc
     2 seg_unique_key = vc
     2 diag_ftdesc = vc
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 source_string = vc
     2 string_identifier = c18
     2 source_identifier = vc
     2 concept_identifier = c18
     2 concept_source_cd = f8
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c40
     2 source_vocabulary_desc = c60
     2 source_vocabulary_mean = c12
     2 string_source_cd = f8
     2 principle_type_cd = f8
     2 ranking_cd = f8
     2 confirmation_status_cd = f8
     2 clinical_service_cd = f8
     2 comment = vc
     2 comment_updt_id = f8
     2 comment_updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE atginitdiagnosis(null)
  SET stat = initrec(atg_diag_request)
  SET stat = initrec(atg_diag_reply)
 END ;Subroutine
 SUBROUTINE atggetdiagnosis(diag_id,person_id,encntr_id,except_encntr_ind)
   SET atg_diag_request->diag_id = diag_id
   SET atg_diag_request->person_id = person_id
   SET atg_diag_request->encntr_id = encntr_id
   SET atg_diag_request->except_encntr_ind = except_encntr_ind
   SET trace = recpersist
   EXECUTE cps_get_diagnosis  WITH replace("REQUEST","ATG_DIAG_REQUEST"), replace("REPLY",
    "ATG_DIAG_REPLY")
   SET trace = norecpersist
   RETURN(0)
 END ;Subroutine
 FREE RECORD data
 RECORD data(
   1 name = vc
   1 med_bcb_codes = vc
   1 alg_bcb_codes = vc
   1 diag_bcb_codes = vc
   1 weight = f8
   1 age = i4
   1 gender = c1
   1 pregnancy_length = i4
   1 lactation_ind = i2
   1 err_cnt = i4
   1 err[*]
     2 err_code = i4
     2 err_msg = vc
 )
 FREE RECORD map_request
 FREE RECORD map_reply
 EXECUTE rx_get_multum_bcb_mapping_rr  WITH replace("REQUEST","MAP_REQUEST"), replace("REPLY",
  "MAP_REPLY")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE cfin_nbr = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cicd10ca = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"ICD10CA"))
 DECLARE cmrn = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE cweight = f8 WITH protect, noconstant(0.0)
 DECLARE mencntrid = f8 WITH protect, constant(request->visit[1].encntr_id)
 DECLARE mpersonid = f8 WITH protect, noconstant(0.0)
 DECLARE mprsnlid = f8 WITH protect, constant(reqinfo->updt_id)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE moutputdevice = vc WITH protect, constant(request->output_device)
 DECLARE temp_string = vc WITH protect, noconstant(" ")
 DECLARE callergyactive = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"ACTIVE"))
 DECLARE callergyproposed = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"PROPOSED"))
 DECLARE lsyncnt = i4 WITH protect, noconstant(0)
 DECLARE lordidx = i4 WITH protect, noconstant(0)
 DECLARE lordsize = i4 WITH protect, noconstant(0)
 DECLARE lingredidx = i4 WITH protect, noconstant(0)
 DECLARE lingredsize = i4 WITH protect, noconstant(0)
 DECLARE lreplyorcidx = i4 WITH protect, noconstant(0)
 DECLARE lreplyorcsize = i4 WITH protect, noconstant(0)
 DECLARE bcbdrugid_txt = vc WITH protect, noconstant(" ")
 DECLARE lalgcnt = i4 WITH protect, noconstant(0)
 DECLARE lalgidx = i4 WITH protect, noconstant(0)
 DECLARE lalgsize = i4 WITH protect, noconstant(0)
 DECLARE lreplyalgidx = i4 WITH protect, noconstant(0)
 DECLARE lreplyalgsize = i4 WITH protect, noconstant(0)
 IF (mencntrid=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Data collection"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BRAD_TEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid encntr_id"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=mencntrid)
  DETAIL
   mpersonid = e.person_id
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 WHILE (errcode > 0)
   SET data->err_cnt = (data->err_cnt+ 1)
   SET stat = alterlist(data->err,data->err_cnt)
   SET data->err[data->err_cnt].err_code = errcode
   SET data->err[data->err_cnt].err_msg = errmsg
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET stat = atginitsrvreq680200(null)
 SET atg_req_680200->patient_id = mpersonid
 SET atg_req_680200->encounter_criteria.override_org_security_ind = 1
 SET atg_req_680200->user_criteria.user_id = mprsnlid
 SET atg_req_680200->active_orders_criteria.order_statuses.load_future_ind = 1
 SET atg_req_680200->active_orders_criteria.order_statuses.load_in_process_ind = 1
 SET atg_req_680200->active_orders_criteria.order_statuses.load_incomplete_ind = 1
 SET atg_req_680200->active_orders_criteria.order_statuses.load_on_hold_ind = 1
 SET atg_req_680200->active_orders_criteria.order_statuses.load_ordered_ind = 1
 SET atg_req_680200->active_orders_criteria.order_statuses.load_suspended_ind = 1
 SET atg_req_680200->medication_order_criteria.load_charge_only_ind = 1
 SET atg_req_680200->medication_order_criteria.load_documented_ind = 1
 SET atg_req_680200->medication_order_criteria.load_normal_ind = 1
 SET atg_req_680200->medication_order_criteria.load_patients_own_ind = 1
 SET atg_req_680200->medication_order_criteria.load_prescription_ind = 1
 SET atg_req_680200->medication_order_criteria.load_satellite_ind = 1
 SET atg_req_680200->order_profile_indicators.load_order_ingredients_ind = 1
 SET stat = atgperformsrvreq680200(null)
 SET errcode = error(errmsg,0)
 WHILE (errcode > 0)
   SET data->err_cnt = (data->err_cnt+ 1)
   SET stat = alterlist(data->err,data->err_cnt)
   SET data->err[data->err_cnt].err_code = errcode
   SET data->err[data->err_cnt].err_msg = errmsg
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET lsyncnt = 0
 SET lordidx = 0
 SET lordsize = 0
 SET lingredidx = 0
 SET lingredsize = 0
 SET lreplyorcidx = 0
 SET lreplyorcsize = 0
 SET lordsize = size(atg_reply_680200->active_orders,5)
 CALL echo(build("lOrdSize: ",lordsize))
 FOR (lordidx = 1 TO lordsize)
  SET lingredsize = size(atg_reply_680200->active_orders[lordidx].medication_information.ingredients,
   5)
  IF (lingredsize <= 0
   AND (atg_reply_680200->active_orders[lordidx].reference_information.synonym_id > 0))
   SET lsyncnt = (lsyncnt+ 1)
   SET stat = alterlist(map_request->orc_qual,lsyncnt)
   SET map_request->orc_qual[lsyncnt].synonym_id = atg_reply_680200->active_orders[lordidx].
   reference_information.synonym_id
  ELSE
   FOR (lingredidx = 1 TO lingredsize)
     IF ((atg_reply_680200->active_orders[lordidx].medication_information.ingredients[lingredidx].
     synonym_id > 0))
      SET lsyncnt = (lsyncnt+ 1)
      SET stat = alterlist(map_request->orc_qual,lsyncnt)
      SET map_request->orc_qual[lsyncnt].synonym_id = atg_reply_680200->active_orders[lordidx].
      medication_information.ingredients[lingredidx].synonym_id
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 SET stat = atginitallergy(null)
 SET stat = atggetallergy(mpersonid)
 SET errcode = error(errmsg,0)
 WHILE (errcode > 0)
   SET data->err_cnt = (data->err_cnt+ 1)
   SET stat = alterlist(data->err,data->err_cnt)
   SET data->err[data->err_cnt].err_code = errcode
   SET data->err[data->err_cnt].err_msg = errmsg
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET lalgsize = size(atg_alg_reply->allergy,5)
 CALL echo(build("lAlgSize: ",lalgsize))
 SET stat = alterlist(map_request->allergy_qual,lalgsize)
 FOR (lalgidx = 1 TO lalgsize)
   IF ((atg_alg_reply->allergy[lalgidx].allergy_id > 0)
    AND (atg_alg_reply->allergy[lalgidx].active_ind=1)
    AND (((atg_alg_reply->allergy[lalgidx].reaction_status_cd=callergyactive)) OR ((atg_alg_reply->
   allergy[lalgidx].reaction_status_cd=callergyproposed))) )
    SET lalgcnt = (lalgcnt+ 1)
    SET map_request->allergy_qual[lalgcnt].allergy_id = atg_alg_reply->allergy[lalgidx].allergy_id
   ENDIF
 ENDFOR
 SET stat = alterlist(map_request->allergy_qual,lalgcnt)
 CALL echo("Start calling rx_get_multum_bcb_mapping...")
 EXECUTE rx_get_multum_bcb_mapping  WITH replace("REQUEST","MAP_REQUEST"), replace("REPLY",
  "MAP_REPLY")
 CALL echo("Done calling rx_get_multum_bcb_mapping...")
 SET lreplyorcsize = size(map_reply->orc_qual,5)
 IF (lreplyorcsize > 0)
  FOR (lreplyorcidx = 1 TO lreplyorcsize)
   IF (size(trim(map_reply->orc_qual[lreplyorcidx].bcbdrugid,3),1) > 0)
    SET bcbdrugid_txt = map_reply->orc_qual[lreplyorcidx].bcbdrugid
   ELSE
    SET bcbdrugid_txt = trim(cnvtstring(map_reply->orc_qual[lreplyorcidx].ucd_code),3)
   ENDIF
   IF (size(trim(data->med_bcb_codes,3),1) > 0)
    SET data->med_bcb_codes = concat(data->med_bcb_codes,"@",trim(bcbdrugid_txt,3))
   ELSE
    SET data->med_bcb_codes = trim(bcbdrugid_txt,3)
   ENDIF
  ENDFOR
  CALL echo(build("In atg_cps_bcb_get_data===>data->med_bcb_codes: ",data->med_bcb_codes))
 ENDIF
 SET lreplyalgsize = size(map_reply->allergy_qual,5)
 IF (lreplyalgsize > 0)
  FOR (lreplyalgidx = 1 TO lreplyalgsize)
    IF (size(trim(map_reply->allergy_qual[lreplyalgidx].bcb_code,3),1) > 0)
     IF (size(trim(data->alg_bcb_codes,3),1) > 0)
      SET data->alg_bcb_codes = concat(data->alg_bcb_codes,"@",trim(map_reply->allergy_qual[
        lreplyalgidx].bcb_code,3))
     ELSE
      SET data->alg_bcb_codes = trim(map_reply->allergy_qual[lreplyalgidx].bcb_code,3)
     ENDIF
    ENDIF
  ENDFOR
  CALL echo(build("In atg_cps_bcb_get_data===>data->alg_bcb_codes: ",data->alg_bcb_codes))
 ENDIF
 SET errcode = error(errmsg,0)
 WHILE (errcode > 0)
   SET data->err_cnt = (data->err_cnt+ 1)
   SET stat = alterlist(data->err,data->err_cnt)
   SET data->err[data->err_cnt].err_code = errcode
   SET data->err[data->err_cnt].err_msg = errmsg
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET modify = cnvtage(0,0,12000)
 SELECT INTO "nl:"
  FROM person p
  WHERE p.person_id=mpersonid
  DETAIL
   data->name = p.name_full_formatted
  WITH nocounter
 ;end select
 SET modify = cnvtage(7,4,24)
 SET errcode = error(errmsg,0)
 WHILE (errcode > 0)
   SET data->err_cnt = (data->err_cnt+ 1)
   SET stat = alterlist(data->err,data->err_cnt)
   SET data->err[data->err_cnt].err_code = errcode
   SET data->err[data->err_cnt].err_msg = errmsg
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET data->pregnancy_length = 0
 SET data->lactation_ind = 0
 SET data->gender = " "
 SET errcode = error(errmsg,0)
 WHILE (errcode > 0)
   SET data->err_cnt = (data->err_cnt+ 1)
   SET stat = alterlist(data->err,data->err_cnt)
   SET data->err[data->err_cnt].err_code = errcode
   SET data->err[data->err_cnt].err_msg = errmsg
   SET errcode = error(errmsg,0)
 ENDWHILE
 SELECT INTO value(moutputdevice)
  DETAIL
   temp_string = "<HTML>", col 0, temp_string,
   row + 1, temp_string = "<REPLYMESSAGE>", col 0,
   temp_string, row + 1, temp_string = build("<FULL_NAME>",data->name,"</FULL_NAME>"),
   col 0, temp_string, row + 1,
   temp_string = build("<MED_BCB_CODES>",data->med_bcb_codes,"</MED_BCB_CODES>"), col 0, temp_string,
   row + 1, temp_string = build("<ALG_BCB_CODES>",data->alg_bcb_codes,"</ALG_BCB_CODES>"), col 0,
   temp_string, row + 1, temp_string = build("<DIAG_BCB_CODES>",data->diag_bcb_codes,
    "</DIAG_BCB_CODES>"),
   col 0, temp_string, row + 1,
   temp_string = build("<WEIGHT>",cnvtint(round(data->weight,0)),"</WEIGHT>"), col 0, temp_string,
   row + 1, temp_string = build("<AGE>",data->age,"</AGE>"), col 0,
   temp_string, row + 1, temp_string = build("<GENDER>",data->gender,"</GENDER>"),
   col 0, temp_string, row + 1,
   temp_string = build("<PREGNANCY_LENGTH>",data->pregnancy_length,"</PREGNANCY_LENGTH>"), col 0,
   temp_string,
   row + 1, temp_string = build("<LACTATION_IND>",data->lactation_ind,"</LACTATION_IND>"), col 0,
   temp_string, row + 1, temp_string = "</REPLYMESSAGE>",
   col 0, temp_string, row + 1
   IF ((data->err_cnt > 0))
    temp_string = "<ERRORMESSAGE>", col 0, temp_string,
    row + 1
    FOR (idx = 1 TO size(data->err,5))
      temp_string = "<ERROR>", col 0, temp_string,
      row + 1, temp_string = build("<ERRCODE>",data->err[idx].err_code,"</ERRCODE>"), col 0,
      temp_string, row + 1, temp_string = build("<ERRMSG>",data->err[idx].err_msg,"</ERRMSG>"),
      col 0, temp_string, row + 1,
      temp_string = "</ERROR>", col 0, temp_string,
      row + 1
    ENDFOR
    temp_string = "</ERRORMESSAGE>", col 0, temp_string,
    row + 1
   ENDIF
   temp_string = "</HTML>", col 0, temp_string,
   row + 1
  WITH nocounter, maxrow = 1, maxcol = 500,
   formfeed = none, format = variable
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(data)
 CALL echo(build("Last_Mod: ","006 09/27/2013"))
END GO
