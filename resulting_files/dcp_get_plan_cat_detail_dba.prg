CREATE PROGRAM dcp_get_plan_cat_detail:dba
 SET modify = predeclare
 IF (validate(reply,"N")="N")
  RECORD reply(
    1 pathway_catalog_id = f8
    1 type_mean = c12
    1 description = vc
    1 updt_cnt = i4
    1 active_ind = i2
    1 cross_encntr_ind = i2
    1 version = i4
    1 long_text = vc
    1 long_text_id = f8
    1 long_text_updt_cnt = i4
    1 pathway_type_cd = f8
    1 pathway_type_disp = c40
    1 pathway_type_mean = c12
    1 display_method_cd = f8
    1 display_method_disp = c40
    1 display_method_mean = c12
    1 pathway_class_cd = f8
    1 pathway_class_disp = c40
    1 pathway_class_mean = c12
    1 beg_effective_dt_tm = dq8
    1 end_effective_dt_tm = dq8
    1 version_pw_cat_id = f8
    1 ref_owner_person_id = f8
    1 display_description = vc
    1 sub_phase_ind = i2
    1 hide_flexed_comp_ind = i2
    1 cycle_ind = i2
    1 standard_cycle_nbr = i4
    1 default_view_mean = c12
    1 diagnosis_capture_ind = i2
    1 chemo_ind = i2
    1 chemo_related_ind = i2
    1 provider_prompt_ind = i2
    1 allow_copy_forward_ind = i2
    1 ref_text_ind = i2
    1 care_plan_ref_text_id = f8
    1 pat_ed_ref_text_id = f8
    1 cycle_begin_nbr = i4
    1 cycle_end_nbr = i4
    1 cycle_label_cd = f8
    1 cycle_display_end_ind = i2
    1 cycle_lock_end_ind = i2
    1 cycle_increment_nbr = i4
    1 default_visit_type_flag = i2
    1 prompt_on_selection_ind = i2
    1 power_trial_disp_description = vc
    1 uuid = vc
    1 qual_phase[*]
      2 pathway_catalog_id = f8
      2 description = vc
      2 duration_qty = i4
      2 duration_unit_cd = f8
      2 duration_unit_disp = c40
      2 duration_unit_mean = c12
      2 phase_updt_cnt = i4
      2 time_zero_ind = i2
      2 display_description = vc
      2 start_offset_ind = i2
      2 type_mean = c12
      2 display_method_cd = f8
      2 display_method_disp = c40
      2 display_method_mean = c12
      2 sub_phase_ind = i2
      2 hide_flexed_comp_ind = i2
      2 chemo_ind = i2
      2 chemo_related_ind = i2
      2 high_alert_ind = i2
      2 high_alert_required_ntfy_ind = i2
      2 auto_initiate_ind = i2
      2 alerts_on_plan_ind = i2
      2 alerts_on_plan_upd_ind = i2
      2 ref_text_ind = i2
      2 care_plan_ref_text_id = f8
      2 pat_ed_ref_text_id = f8
      2 default_action_inpt_future_cd = f8
      2 default_action_inpt_now_cd = f8
      2 default_action_outpt_future_cd = f8
      2 default_action_outpt_now_cd = f8
      2 optional_ind = i2
      2 future_ind = i2
      2 period_nbr = i4
      2 period_custom_label = c40
      2 route_for_review_ind = i2
      2 pathway_class_cd = f8
      2 default_start_time_txt = c10
      2 primary_ind = i2
      2 uuid = vc
      2 parent_component_uuid = vc
      2 reschedule_reason_accept_flag = i2
      2 qual_component[*]
        3 pathway_comp_id = f8
        3 dcp_clin_cat_cd = f8
        3 dcp_clin_cat_disp = c40
        3 dcp_clin_cat_mean = c12
        3 dcp_clin_sub_cat_cd = f8
        3 dcp_clin_sub_cat_disp = c40
        3 dcp_clin_sub_cat_mean = c12
        3 ocs_clin_cat_cd = f8
        3 ocs_clin_cat_disp = c40
        3 ocs_clin_cat_mean = c12
        3 sequence = i4
        3 comp_type_cd = f8
        3 comp_type_disp = c40
        3 comp_type_mean = c12
        3 parent_entity_name = vc
        3 parent_entity_id = f8
        3 synonym_id = f8
        3 catalog_cd = f8
        3 catalog_disp = c40
        3 catalog_mean = c12
        3 catalog_type_cd = f8
        3 catalog_type_disp = c40
        3 catalog_type_mean = c12
        3 activity_type_cd = f8
        3 activity_type_disp = c40
        3 activity_type_mean = c12
        3 mnemonic = vc
        3 oe_format_id = f8
        3 rx_mask = i4
        3 orderable_type_flag = i2
        3 linked_to_tf_ind = i2
        3 required_ind = i2
        3 included_ind = i2
        3 persistent_ind = i2
        3 comp_text_id = f8
        3 comp_text = vc
        3 comp_text_updt_cnt = i4
        3 comp_updt_cnt = i4
        3 hna_order_mnemonic = vc
        3 cki = vc
        3 ref_text_ind = i2
        3 ref_text_mask = i4
        3 qual_order_sentence[*]
          4 sequence = i4
          4 order_sentence_id = f8
          4 order_sentence_display_line = vc
          4 iv_comp_syn_id = f8
          4 ord_comment_long_text_id = f8
          4 ord_comment_long_text = vc
          4 rx_type_mean = c12
          4 normalized_dose_unit_ind = i2
          4 missing_required_ind = i2
          4 applicable_to_patient_ind = i2
          4 order_sentence_filter_display = vc
        3 target_type_cd = f8
        3 target_type_disp = c40
        3 target_type_mean = c12
        3 duration_qty = i4
        3 duration_unit_cd = f8
        3 duration_unit_disp = c40
        3 duration_unit_mean = c12
        3 expand_qty = i4
        3 expand_unit_cd = f8
        3 expand_unit_disp = c40
        3 expand_unit_mean = c12
        3 outcome_description = vc
        3 outcome_expectation = vc
        3 outcome_type_cd = f8
        3 outcome_type_disp = c40
        3 outcome_type_mean = c12
        3 time_zero_offset_quantity = f8
        3 time_zero_mean = c12
        3 time_zero_offset_unit_cd = f8
        3 time_zero_offset_unit_disp = c40
        3 time_zero_offset_unit_mean = c12
        3 comp_label = vc
        3 offset_quantity = f8
        3 offset_unit_cd = f8
        3 offset_unit_disp = c40
        3 offset_unit_mean = c12
        3 iv_ingredient[*]
          4 synonym_id = f8
          4 mnemonic = vc
          4 oe_format_id = f8
          4 catalog_cd = f8
          4 comp_seq = i4
        3 parent_active_ind = i2
        3 facility_ind = i2
        3 all_facility_access_ind = i2
        3 facilitylist[*]
          4 facility_cd = f8
        3 parent_phase_desc = vc
        3 parent_phase_display_desc = vc
        3 cross_phase_group_desc = c40
        3 cross_phase_group_nbr = f8
        3 chemo_ind = i2
        3 chemo_related_ind = i2
        3 single_select_ind = i2
        3 hide_expectation_ind = i2
        3 ref_text_reltn_id = f8
        3 high_alert_ind = i2
        3 high_alert_required_ntfy_ind = i2
        3 high_alert_text = vc
        3 default_os_ind = i2
        3 schedule_ind = i2
        3 intermittent_ind = i2
        3 min_tolerance_interval = i4
        3 min_tolerance_interval_unit_cd = f8
        3 reference_text_version_id = f8
        3 uuid = vc
        3 display_format_xml = vc
        3 lock_target_dose_flag = i2
        3 mnemonic_type_cd = f8
      2 qual_phase_reltn[*]
        3 pw_cat_s_id = f8
        3 pw_cat_t_id = f8
        3 type_mean = c12
        3 offset_qty = i4
        3 offset_unit_cd = f8
      2 compgrouplist[*]
        3 pw_comp_group_id = f8
        3 type_mean = c12
        3 memberlist[*]
          4 pathway_comp_id = f8
          4 comp_seq = i4
          4 anchor_component_ind = i2
        3 description = vc
        3 linking_rule_flag = i2
        3 linking_rule_quantity = i4
        3 override_reason_flag = i2
      2 treatment_linked_comp_list[*]
        3 pathway_comp_id = f8
      2 time_zero_exceptions[*]
        3 pw_cat_s_id = f8
        3 pw_cat_t_id = f8
        3 type_mean = c12
        3 offset_qty = i4
        3 offset_unit_cd = f8
        3 offset_quantity = f8
      2 open_by_default_ind = i2
      2 allow_activate_all_ind = i2
      2 review_required_sig_count = i4
      2 linked_phase_ind = i2
    1 planevidencelist[*]
      2 dcp_clin_cat_cd = f8
      2 dcp_clin_sub_cat_cd = f8
      2 pathway_comp_id = f8
      2 evidence_type_mean = c12
      2 pw_evidence_reltn_id = f8
      2 evidence_locator = vc
      2 pathway_catalog_id = f8
      2 text_type_cd = f8
      2 ref_text_reltn_id = f8
      2 evidence_sequence = i4
    1 facilityflexlist[*]
      2 facility_cd = f8
      2 facility_disp = c40
      2 facility_mean = c12
    1 problemdiaglist[*]
      2 concept_cki = vc
      2 nomenclature_id = f8
      2 source_string = vc
    1 compphasereltnlist[*]
      2 pw_comp_cat_reltn_id = f8
      2 pathway_comp_id = f8
      2 pathway_catalog_id = f8
      2 type_mean = c12
    1 synonymlist[*]
      2 pw_cat_synonym_id = f8
      2 synonym_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 restricted_actions_bitmask = i4
    1 open_by_default_ind = i2
    1 override_mrd_on_plan_ind = i2
  )
 ENDIF
 RECORD internal(
   1 pathway_catalog_id = f8
   1 type_mean = c12
   1 description = vc
   1 updt_cnt = i4
   1 active_ind = i2
   1 cross_encntr_ind = i2
   1 version = i4
   1 duration_qty = i4
   1 duration_unit_cd = f8
   1 long_text = vc
   1 long_text_id = f8
   1 long_text_updt_cnt = i4
   1 pathway_type_cd = f8
   1 display_method_cd = f8
   1 pathway_class_cd = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 version_pw_cat_id = f8
   1 ref_owner_person_id = f8
   1 display_description = vc
   1 sub_phase_ind = i2
   1 hide_flexed_comp_ind = i2
   1 cycle_ind = i2
   1 standard_cycle_nbr = i4
   1 default_view_mean = c12
   1 diagnosis_capture_ind = i2
   1 provider_prompt_ind = i2
   1 allow_copy_forward_ind = i2
   1 auto_initiate_ind = i2
   1 alerts_on_plan_ind = i2
   1 alerts_on_plan_upd_ind = i2
   1 cycle_begin_nbr = i4
   1 cycle_end_nbr = i4
   1 cycle_label_cd = f8
   1 cycle_display_end_ind = i2
   1 cycle_lock_end_ind = i2
   1 cycle_increment_nbr = i4
   1 default_action_inpt_future_cd = f8
   1 default_action_inpt_now_cd = f8
   1 default_action_outpt_future_cd = f8
   1 default_action_outpt_now_cd = f8
   1 optional_ind = i2
   1 future_ind = i2
   1 default_visit_type_flag = i2
   1 prompt_on_selection_ind = i2
   1 period_nbr = i4
   1 period_custom_label = c40
   1 route_for_review_ind = i2
   1 pathway_class_cd = f8
   1 default_start_time_txt = c10
   1 primary_ind = i2
   1 uuid = vc
   1 reschedule_reason_accept_flag = i2
   1 restricted_actions_bitmask = i4
   1 open_by_default_ind = i2
   1 allow_activate_all_ind = i2
   1 review_required_sig_count = i4
   1 override_mrd_on_plan_ind = i2
   1 linked_phase_ind = i2
 )
 RECORD temp(
   1 oclist[*]
     2 pathway_catalog_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 ocs_clin_cat_cd = f8
     2 sequence = i4
     2 comp_type_cd = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 synonym_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 mnemonic = vc
     2 oe_format_id = f8
     2 rx_mask = i4
     2 orderable_type_flag = i2
     2 linked_to_tf_ind = i2
     2 required_ind = i2
     2 included_ind = i2
     2 comp_updt_cnt = i4
     2 sort_cd = f8
     2 comp_label = vc
     2 offset_quantity = f8
     2 offset_unit_cd = f8
     2 hna_order_mnemonic = vc
     2 cki = vc
     2 ref_text_ind = i2
     2 ref_text_mask = i4
     2 ordsentlist[*]
       3 order_sentence_seq = i4
       3 order_sentence_id = f8
       3 order_sentence_display_line = vc
       3 iv_comp_syn_id = f8
       3 ord_comment_long_text_id = f8
       3 ord_comment_long_text = vc
       3 rx_type_mean = c12
       3 normalized_dose_unit_ind = i2
       3 missing_required_ind = i2
     2 ingredientlist[*]
       3 synonym_id = f8
       3 oe_format_id = f8
       3 mnemonic = vc
       3 catalog_cd = f8
       3 comp_seq = i4
     2 parent_active_ind = i2
     2 facility_ind = i2
     2 all_facility_access_ind = i2
     2 facilitylist[*]
       3 facility_cd = f8
     2 cross_phase_group_desc = c40
     2 cross_phase_group_nbr = f8
     2 chemo_ind = i2
     2 chemo_related_ind = i2
     2 high_alert_ind = i2
     2 high_alert_required_ntfy_ind = i2
     2 high_alert_long_text_id = f8
     2 high_alert_text = vc
     2 default_os_ind = i2
     2 schedule_ind = i2
     2 intermittent_ind = i2
     2 min_tolerance_interval = i4
     2 min_tolerance_interval_unit_cd = f8
     2 reference_text_version_id = f8
     2 uuid = vc
     2 display_format_xml = vc
     2 lock_target_dose_flag = i2
     2 mnemonic_type_cd = f8
   1 ltlist[*]
     2 pathway_catalog_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 sequence = i4
     2 comp_type_cd = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 persistent_ind = i2
     2 comp_text_id = f8
     2 comp_text = vc
     2 comp_text_updt_cnt = i4
     2 comp_updt_cnt = i4
     2 sort_cd = f8
     2 comp_label = vc
     2 chemo_related_ind = i2
     2 uuid = vc
     2 display_format_xml = vc
   1 outcomelist[*]
     2 pathway_catalog_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 sequence = i4
     2 comp_type_cd = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 required_ind = i2
     2 included_ind = i2
     2 linked_to_tf_ind = i2
     2 comp_updt_cnt = i4
     2 target_type_cd = f8
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 expand_qty = i4
     2 expand_unit_cd = f8
     2 outcome_description = vc
     2 outcome_expectation = vc
     2 outcome_type_cd = f8
     2 single_select_ind = i2
     2 hide_expectation_ind = i2
     2 sort_cd = f8
     2 comp_label = vc
     2 parent_active_ind = i2
     2 offset_quantity = f8
     2 offset_unit_cd = f8
     2 chemo_related_ind = i2
     2 ref_text_reltn_id = f8
     2 uuid = vc
     2 display_format_xml = vc
     2 facility_ind = i2
     2 all_facility_access_ind = i2
     2 facilitylist[*]
       3 facility_cd = f8
   1 splist[*]
     2 pathway_catalog_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 sequence = i4
     2 comp_type_cd = f8
     2 comp_label = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 included_ind = i2
     2 comp_updt_cnt = i4
     2 offset_quantity = f8
     2 offset_unit_cd = f8
     2 facility_ind = i2
     2 sort_cd = f8
     2 parent_active_ind = i2
     2 all_facility_access_ind = i2
     2 parent_phase_desc = vc
     2 parent_phase_display_desc = vc
     2 facilitylist[*]
       3 facility_cd = f8
     2 cross_phase_group_desc = c40
     2 cross_phase_group_nbr = f8
     2 chemo_related_ind = i2
     2 min_tolerance_interval = i4
     2 min_tolerance_interval_unit_cd = f8
     2 uuid = vc
     2 display_format_xml = vc
 )
 RECORD temp2(
   1 phaselist[*]
     2 pathway_catalog_id = f8
     2 comprlist[*]
       3 source_id = f8
       3 target_id = f8
       3 type_mean = c12
       3 offset_quantity = f8
       3 offset_unit_cd = f8
 )
 RECORD temp3(
   1 ivlist[*]
     2 pathway_comp_id = f8
     2 synonym_id = f8
     2 catalog_cd = f8
     2 ingrdlist[*]
       3 synonym_id = f8
       3 catalog_cd = f8
       3 mnemonic = vc
       3 oe_format_id = f8
       3 catalog_cd = f8
       3 comp_seq = i4
 )
 RECORD temp4(
   1 phaselist[*]
     2 pathway_catalog_id = f8
     2 compglist[*]
       3 pw_comp_group_id = f8
       3 type_mean = c12
       3 memberlist[*]
         4 pathway_comp_id = f8
         4 comp_seq = i4
         4 anchor_component_ind = i2
       3 description = c99
       3 linking_rule_flag = i2
       3 linking_rule_quantity = i4
       3 override_reason_flag = i2
 )
 RECORD subphases(
   1 list[*]
     2 orig_pathway_catalog_id = f8
     2 new_pathway_catalog_id = f8
     2 description = vc
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 phase_updt_cnt = i4
     2 display_description = vc
     2 display_method_cd = f8
     2 hide_flexed_comp_ind = i2
     2 active_ind = i2
     2 cat_sub_phase_ind = i2
     2 facility_ind = i2
     2 all_facility_access_ind = i2
     2 uuid = vc
     2 facilitylist[*]
       3 facility_cd = f8
 )
 RECORD comp_phase_reltn(
   1 count = i4
   1 size = i4
   1 batch_size = i4
   1 loop_count = i4
   1 components[*]
     2 pathway_comp_id = f8
 )
 RECORD filter_order_sentences(
   1 patient_criteria
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 postmenstrual_age_in_days = i4
     2 weight = f8
     2 weight_unit_cd = f8
   1 orders[*]
     2 unique_identifier = f8
     2 component_index = i4
     2 reply_phase_index = i4
     2 order_sentences[*]
       3 order_sentence_id = f8
       3 applicable_to_patient_ind = i2
       3 order_sentence_filters[*]
         4 order_sentence_filter_display = vc
         4 order_sentence_filter_type
           5 age_filter_ind = i2
           5 pma_filter_ind = i2
           5 weight_filter_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE phasecnt = i4 WITH noconstant(0), protect
 DECLARE reltncnt = i4 WITH noconstant(0), protect
 DECLARE faccnt = i4 WITH noconstant(0), protect
 DECLARE occnt = i4 WITH noconstant(0), protect
 DECLARE otcnt = i4 WITH noconstant(0), protect
 DECLARE ltcnt = i4 WITH noconstant(0), protect
 DECLARE outcomecnt = i4 WITH noconstant(0), protect
 DECLARE spcnt = i4 WITH noconstant(0), protect
 DECLARE sentcnt = i4 WITH noconstant(0), protect
 DECLARE syncnt = i4 WITH noconstant(0), protect
 DECLARE synsize = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE high = i4 WITH noconstant(0), protect
 DECLARE dummy = i4 WITH noconstant(0), protect
 DECLARE cfailed = c1 WITH noconstant("F"), protect
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE i = i2 WITH noconstant(0), protect
 DECLARE comp_r_cnt = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE ingredcnt = i4 WITH noconstant(0), protect
 DECLARE ivcnt = i4 WITH noconstant(0), protect
 DECLARE filterorc = i2 WITH noconstant(0), protect
 DECLARE facilitycd = f8 WITH noconstant(0.0), protect
 DECLARE getsubphasecompflag = c1 WITH noconstant("N"), protect
 DECLARE planhideflexedcomps = i2 WITH noconstant(0), protect
 DECLARE inactivesubphasefound = c1 WITH noconstant("N"), protect
 DECLARE getactiveversionflag = c1 WITH noconstant("N"), protect
 DECLARE loadhighalerttextflag = c1 WITH noconstant("N"), protect
 DECLARE phasetotal = i4 WITH noconstant(0), protect
 DECLARE lstart = i4 WITH noconstant(0), protect
 DECLARE lcompphasereltncount = i4 WITH noconstant(0), protect
 DECLARE lcompphasereltnsize = i4 WITH noconstant(0), protect
 DECLARE tzexceptidx = i4 WITH noconstant(0), protect
 DECLARE tzexceptcnt = i4 WITH noconstant(0), protect
 DECLARE order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE")), protect
 DECLARE note_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"NOTE")), protect
 DECLARE outcome_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"RESULT OUTCO")), protect
 DECLARE subphase_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"SUBPHASE")), protect
 DECLARE prescription_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"PRESCRIPTION")),
 protect
 DECLARE clin_cat_display_method_cd = f8 WITH constant(uar_get_code_by("MEANING",30720,"CLINCAT")),
 protect
 DECLARE care_plan_cd = f8 WITH constant(uar_get_code_by("MEANING",6009,"CAREPLANINFO")), protect
 DECLARE patient_ed_cd = f8 WITH constant(uar_get_code_by("MEANING",6009,"PATIENT ED")), protect
 IF ((validate(request->facility_flexing_ind,- (999))=- (999)))
  IF ((validate(request->facility_cd,- (1000))=- (1000)))
   SET filterorc = 0
  ELSE
   IF ((request->facility_cd > 0))
    SET filterorc = 1
    SET facilitycd = request->facility_cd
   ELSEIF ((request->facility_cd=- (1)))
    SET filterorc = - (1)
   ELSE
    SET filterorc = 0
   ENDIF
  ENDIF
 ELSE
  SET filterorc = request->facility_flexing_ind
  SET facilitycd = request->facility_cd
 ENDIF
 SELECT INTO "nl:"
  pwc.pathway_catalog_id, lt.long_text_id
  FROM pathway_catalog pwc,
   long_text lt
  PLAN (pwc
   WHERE (pwc.pathway_catalog_id=request->pathway_catalog_id))
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(pwc.long_text_id))
    AND (lt.active_ind= Outerjoin(1)) )
  DETAIL
   internal->pathway_catalog_id = pwc.pathway_catalog_id, internal->type_mean = pwc.type_mean,
   internal->description = pwc.description,
   internal->updt_cnt = pwc.updt_cnt, internal->active_ind = pwc.active_ind, internal->
   cross_encntr_ind = pwc.cross_encntr_ind,
   internal->version = pwc.version, internal->duration_qty = pwc.duration_qty, internal->
   duration_unit_cd = pwc.duration_unit_cd,
   internal->long_text_id = pwc.long_text_id, internal->long_text = trim(lt.long_text), internal->
   long_text_updt_cnt = lt.updt_cnt,
   internal->pathway_type_cd = pwc.pathway_type_cd, internal->display_method_cd = pwc
   .display_method_cd, internal->pathway_class_cd = pwc.pathway_class_cd,
   internal->beg_effective_dt_tm = cnvtdatetime(pwc.beg_effective_dt_tm), internal->
   end_effective_dt_tm = cnvtdatetime(pwc.end_effective_dt_tm), internal->version_pw_cat_id = pwc
   .version_pw_cat_id,
   internal->ref_owner_person_id = pwc.ref_owner_person_id, internal->display_description = pwc
   .display_description, internal->sub_phase_ind = pwc.sub_phase_ind,
   internal->hide_flexed_comp_ind = pwc.hide_flexed_comp_ind, internal->cycle_ind = pwc.cycle_ind,
   internal->standard_cycle_nbr = pwc.standard_cycle_nbr,
   internal->default_view_mean = pwc.default_view_mean, internal->diagnosis_capture_ind = pwc
   .diagnosis_capture_ind, internal->provider_prompt_ind = pwc.provider_prompt_ind,
   internal->allow_copy_forward_ind = pwc.allow_copy_forward_ind, internal->auto_initiate_ind = pwc
   .auto_initiate_ind, internal->alerts_on_plan_ind = pwc.alerts_on_plan_ind,
   internal->alerts_on_plan_upd_ind = pwc.alerts_on_plan_upd_ind, internal->cycle_begin_nbr = pwc
   .cycle_begin_nbr, internal->cycle_end_nbr = pwc.cycle_end_nbr,
   internal->cycle_label_cd = pwc.cycle_label_cd, internal->cycle_display_end_ind = pwc
   .cycle_display_end_ind, internal->cycle_lock_end_ind = pwc.cycle_lock_end_ind,
   internal->cycle_increment_nbr = pwc.cycle_increment_nbr, internal->default_action_inpt_future_cd
    = pwc.default_action_inpt_future_cd, internal->default_action_inpt_now_cd = pwc
   .default_action_inpt_now_cd,
   internal->default_action_outpt_future_cd = pwc.default_action_outpt_future_cd, internal->
   default_action_outpt_now_cd = pwc.default_action_outpt_now_cd, internal->optional_ind = pwc
   .optional_ind,
   internal->future_ind = pwc.future_ind, internal->default_visit_type_flag = pwc
   .default_visit_type_flag, internal->prompt_on_selection_ind = pwc.prompt_on_selection_ind,
   internal->period_custom_label = pwc.period_custom_label, internal->route_for_review_ind = pwc
   .route_for_review_ind, internal->pathway_class_cd = pwc.pathway_class_cd,
   internal->default_start_time_txt = trim(pwc.default_start_time_txt), internal->primary_ind = pwc
   .primary_ind, internal->uuid = trim(pwc.pathway_uuid),
   internal->reschedule_reason_accept_flag = pwc.reschedule_reason_accept_flag, internal->
   restricted_actions_bitmask = pwc.restricted_actions_bitmask, internal->open_by_default_ind = pwc
   .open_by_default_ind,
   planhideflexedcomps = pwc.hide_flexed_comp_ind, internal->allow_activate_all_ind = evaluate(pwc
    .disable_activate_all_ind,1,0,0,1), internal->review_required_sig_count = pwc
   .review_required_sig_count,
   internal->override_mrd_on_plan_ind = validate(pwc.override_mrd_on_plan_ind,0), internal->
   linked_phase_ind = validate(pwc.linked_phase_ind,0)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("SELECT","F","DCP_GET_PLAN_CAT_DETAIL","Unable to find the plan")
  GO TO exit_script
 ENDIF
 IF (validate(request->active_version_ind,999)=1)
  SET getactiveversionflag = "Y"
 ENDIF
 IF ((internal->active_ind=0)
  AND getactiveversionflag="Y")
  SELECT INTO "nl:"
   FROM pathway_catalog pwc,
    long_text lt
   PLAN (pwc
    WHERE (pwc.version_pw_cat_id=internal->version_pw_cat_id)
     AND pwc.active_ind=1
     AND pwc.sub_phase_ind=1)
    JOIN (lt
    WHERE (lt.long_text_id= Outerjoin(pwc.long_text_id))
     AND (lt.active_ind= Outerjoin(1)) )
   DETAIL
    internal->pathway_catalog_id = pwc.pathway_catalog_id, internal->type_mean = pwc.type_mean,
    internal->description = pwc.description,
    internal->updt_cnt = pwc.updt_cnt, internal->active_ind = pwc.active_ind, internal->
    cross_encntr_ind = pwc.cross_encntr_ind,
    internal->version = pwc.version, internal->duration_qty = pwc.duration_qty, internal->
    duration_unit_cd = pwc.duration_unit_cd,
    internal->long_text_id = pwc.long_text_id, internal->long_text = trim(lt.long_text), internal->
    long_text_updt_cnt = lt.updt_cnt,
    internal->pathway_type_cd = pwc.pathway_type_cd, internal->display_method_cd = pwc
    .display_method_cd, internal->pathway_class_cd = pwc.pathway_class_cd,
    internal->beg_effective_dt_tm = cnvtdatetime(pwc.beg_effective_dt_tm), internal->
    end_effective_dt_tm = cnvtdatetime(pwc.end_effective_dt_tm), internal->version_pw_cat_id = pwc
    .version_pw_cat_id,
    internal->ref_owner_person_id = pwc.ref_owner_person_id, internal->display_description = pwc
    .display_description, internal->sub_phase_ind = pwc.sub_phase_ind,
    internal->hide_flexed_comp_ind = pwc.hide_flexed_comp_ind, internal->cycle_ind = pwc.cycle_ind,
    internal->standard_cycle_nbr = pwc.standard_cycle_nbr,
    internal->default_view_mean = pwc.default_view_mean, internal->diagnosis_capture_ind = pwc
    .diagnosis_capture_ind, internal->provider_prompt_ind = pwc.provider_prompt_ind,
    internal->allow_copy_forward_ind = pwc.allow_copy_forward_ind, internal->auto_initiate_ind = pwc
    .auto_initiate_ind, internal->alerts_on_plan_ind = pwc.alerts_on_plan_ind,
    internal->alerts_on_plan_upd_ind = pwc.alerts_on_plan_upd_ind, internal->cycle_begin_nbr = pwc
    .cycle_begin_nbr, internal->cycle_end_nbr = pwc.cycle_end_nbr,
    internal->cycle_label_cd = pwc.cycle_label_cd, internal->cycle_display_end_ind = pwc
    .cycle_display_end_ind, internal->cycle_lock_end_ind = pwc.cycle_lock_end_ind,
    internal->cycle_increment_nbr = pwc.cycle_increment_nbr, internal->default_action_inpt_future_cd
     = pwc.default_action_inpt_future_cd, internal->default_action_inpt_now_cd = pwc
    .default_action_inpt_now_cd,
    internal->default_action_outpt_future_cd = pwc.default_action_outpt_future_cd, internal->
    default_action_outpt_now_cd = pwc.default_action_outpt_now_cd, internal->optional_ind = pwc
    .optional_ind,
    internal->future_ind = pwc.future_ind, internal->default_visit_type_flag = pwc
    .default_visit_type_flag, internal->prompt_on_selection_ind = pwc.prompt_on_selection_ind,
    internal->period_custom_label = pwc.period_custom_label, internal->route_for_review_ind = pwc
    .route_for_review_ind, internal->pathway_class_cd = pwc.pathway_class_cd,
    internal->default_start_time_txt = trim(pwc.default_start_time_txt), internal->primary_ind = pwc
    .primary_ind, internal->uuid = trim(pwc.pathway_uuid),
    internal->reschedule_reason_accept_flag = pwc.reschedule_reason_accept_flag, internal->
    restricted_actions_bitmask = pwc.restricted_actions_bitmask, internal->open_by_default_ind = pwc
    .open_by_default_ind,
    planhideflexedcomps = pwc.hide_flexed_comp_ind, internal->allow_activate_all_ind = evaluate(pwc
     .disable_activate_all_ind,1,0,0,1), internal->review_required_sig_count = pwc
    .review_required_sig_count,
    internal->override_mrd_on_plan_ind = validate(pwc.override_mrd_on_plan_ind,0), internal->
    linked_phase_ind = validate(pwc.linked_phase_ind,0)
   WITH nocounter
  ;end select
 ENDIF
 SET reply->pathway_catalog_id = internal->pathway_catalog_id
 SET reply->type_mean = internal->type_mean
 SET reply->description = internal->description
 SET reply->updt_cnt = internal->updt_cnt
 SET reply->active_ind = internal->active_ind
 SET reply->cross_encntr_ind = internal->cross_encntr_ind
 SET reply->version = internal->version
 SET reply->long_text_id = internal->long_text_id
 SET reply->long_text = internal->long_text
 SET reply->long_text_updt_cnt = internal->long_text_updt_cnt
 SET reply->pathway_type_cd = internal->pathway_type_cd
 SET reply->display_method_cd = internal->display_method_cd
 SET reply->pathway_class_cd = internal->pathway_class_cd
 SET reply->beg_effective_dt_tm = cnvtdatetime(internal->beg_effective_dt_tm)
 SET reply->end_effective_dt_tm = cnvtdatetime(internal->end_effective_dt_tm)
 SET reply->version_pw_cat_id = internal->version_pw_cat_id
 SET reply->ref_owner_person_id = internal->ref_owner_person_id
 SET reply->display_description = internal->display_description
 SET reply->sub_phase_ind = internal->sub_phase_ind
 SET reply->hide_flexed_comp_ind = internal->hide_flexed_comp_ind
 SET reply->cycle_ind = internal->cycle_ind
 SET reply->standard_cycle_nbr = internal->standard_cycle_nbr
 SET reply->default_view_mean = internal->default_view_mean
 SET reply->diagnosis_capture_ind = internal->diagnosis_capture_ind
 SET reply->provider_prompt_ind = internal->provider_prompt_ind
 SET reply->allow_copy_forward_ind = internal->allow_copy_forward_ind
 SET reply->cycle_begin_nbr = internal->cycle_begin_nbr
 SET reply->cycle_end_nbr = internal->cycle_end_nbr
 SET reply->cycle_label_cd = internal->cycle_label_cd
 SET reply->cycle_display_end_ind = internal->cycle_display_end_ind
 SET reply->cycle_lock_end_ind = internal->cycle_lock_end_ind
 SET reply->cycle_increment_nbr = internal->cycle_increment_nbr
 SET reply->default_visit_type_flag = internal->default_visit_type_flag
 SET reply->prompt_on_selection_ind = internal->prompt_on_selection_ind
 SET reply->pathway_class_cd = internal->pathway_class_cd
 SET reply->uuid = trim(internal->uuid)
 SET reply->restricted_actions_bitmask = internal->restricted_actions_bitmask
 SET reply->open_by_default_ind = internal->open_by_default_ind
 SET reply->override_mrd_on_plan_ind = internal->override_mrd_on_plan_ind
 SELECT INTO "nl:"
  pcs.pw_cat_synonym_id, pcs.synonym_name
  FROM pw_cat_synonym pcs
  PLAN (pcs
   WHERE (pcs.pathway_catalog_id=request->pathway_catalog_id))
  HEAD REPORT
   syncnt = 0, synsize = 0
  DETAIL
   syncnt += 1
   IF (syncnt > synsize)
    synsize += 5, stat = alterlist(reply->synonymlist,synsize)
   ENDIF
   reply->synonymlist[syncnt].pw_cat_synonym_id = pcs.pw_cat_synonym_id, reply->synonymlist[syncnt].
   synonym_name = pcs.synonym_name
  FOOT REPORT
   stat = alterlist(reply->synonymlist,syncnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pw_pt_reltn ppr,
   prot_master pm
  PLAN (ppr
   WHERE (ppr.pathway_catalog_id=request->pathway_catalog_id)
    AND ppr.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ppr.active_ind=1)
   JOIN (pm
   WHERE pm.prot_master_id=ppr.prot_master_id)
  DETAIL
   reply->power_trial_disp_description = pm.primary_mnemonic
  WITH nocounter
 ;end select
 IF ((((internal->type_mean="CAREPLAN")) OR ((((internal->type_mean="PHASE")) OR ((internal->
 type_mean="TAPERPLAN"))) )) )
  SET stat = alterlist(reply->qual_phase,1)
  SET reply->qual_phase[1].pathway_catalog_id = internal->pathway_catalog_id
  SET reply->qual_phase[1].description = internal->description
  SET reply->qual_phase[1].duration_qty = internal->duration_qty
  SET reply->qual_phase[1].duration_unit_cd = internal->duration_unit_cd
  SET reply->qual_phase[1].phase_updt_cnt = internal->updt_cnt
  SET reply->qual_phase[1].time_zero_ind = 0
  SET reply->qual_phase[1].display_description = internal->display_description
  SET reply->qual_phase[1].start_offset_ind = 0
  SET reply->qual_phase[1].type_mean = internal->type_mean
  SET reply->qual_phase[1].display_method_cd = internal->display_method_cd
  SET reply->qual_phase[1].sub_phase_ind = 0
  SET reply->qual_phase[1].hide_flexed_comp_ind = internal->hide_flexed_comp_ind
  SET reply->qual_phase[1].auto_initiate_ind = internal->auto_initiate_ind
  SET reply->qual_phase[1].alerts_on_plan_ind = internal->alerts_on_plan_ind
  SET reply->qual_phase[1].alerts_on_plan_upd_ind = internal->alerts_on_plan_upd_ind
  SET reply->qual_phase[1].default_action_inpt_future_cd = internal->default_action_inpt_future_cd
  SET reply->qual_phase[1].default_action_inpt_now_cd = internal->default_action_inpt_now_cd
  SET reply->qual_phase[1].default_action_outpt_future_cd = internal->default_action_outpt_future_cd
  SET reply->qual_phase[1].default_action_outpt_now_cd = internal->default_action_outpt_now_cd
  SET reply->qual_phase[1].optional_ind = internal->optional_ind
  SET reply->qual_phase[1].future_ind = internal->future_ind
  SET reply->qual_phase[1].period_custom_label = internal->period_custom_label
  SET reply->qual_phase[1].route_for_review_ind = internal->route_for_review_ind
  SET reply->qual_phase[1].pathway_class_cd = internal->pathway_class_cd
  SET reply->qual_phase[1].default_start_time_txt = trim(internal->default_start_time_txt)
  SET reply->qual_phase[1].primary_ind = internal->primary_ind
  SET reply->qual_phase[1].uuid = trim(internal->uuid)
  SET reply->qual_phase[1].reschedule_reason_accept_flag = internal->reschedule_reason_accept_flag
  SET reply->qual_phase[1].open_by_default_ind = internal->open_by_default_ind
  SET reply->qual_phase[1].allow_activate_all_ind = internal->allow_activate_all_ind
  SET reply->qual_phase[1].review_required_sig_count = internal->review_required_sig_count
  SET reply->qual_phase[1].linked_phase_ind = internal->linked_phase_ind
 ELSEIF ((internal->type_mean="PATHWAY"))
  SELECT INTO "nl:"
   pcr1.pw_cat_t_id, pwc.pathway_catalog_id, pcr2.pw_cat_t_id
   FROM pathway_catalog pwc,
    pw_cat_reltn pcr1,
    pw_cat_reltn pcr2
   PLAN (pcr1
    WHERE (pcr1.pw_cat_s_id=internal->pathway_catalog_id)
     AND pcr1.type_mean="GROUP")
    JOIN (pwc
    WHERE pwc.pathway_catalog_id=pcr1.pw_cat_t_id)
    JOIN (pcr2
    WHERE (pcr2.pw_cat_s_id= Outerjoin(pwc.pathway_catalog_id)) )
   ORDER BY pcr1.pw_cat_t_id, pcr2.pw_cat_t_id
   HEAD REPORT
    phasecnt = 0
   HEAD pcr1.pw_cat_t_id
    phasecnt += 1
    IF (phasecnt > size(reply->qual_phase,5))
     stat = alterlist(reply->qual_phase,(phasecnt+ 10))
    ENDIF
    reply->qual_phase[phasecnt].pathway_catalog_id = pwc.pathway_catalog_id, reply->qual_phase[
    phasecnt].description = pwc.description, reply->qual_phase[phasecnt].duration_qty = pwc
    .duration_qty,
    reply->qual_phase[phasecnt].duration_unit_cd = pwc.duration_unit_cd, reply->qual_phase[phasecnt].
    phase_updt_cnt = pwc.updt_cnt, reply->qual_phase[phasecnt].time_zero_ind = 0,
    reply->qual_phase[phasecnt].display_description = pwc.display_description, reply->qual_phase[
    phasecnt].start_offset_ind = 0, reply->qual_phase[phasecnt].type_mean = "PHASE",
    reply->qual_phase[phasecnt].display_method_cd = pwc.display_method_cd, reply->qual_phase[phasecnt
    ].sub_phase_ind = 0, reply->qual_phase[phasecnt].hide_flexed_comp_ind = reply->
    hide_flexed_comp_ind,
    reply->qual_phase[phasecnt].auto_initiate_ind = pwc.auto_initiate_ind, reply->qual_phase[phasecnt
    ].alerts_on_plan_ind = pwc.alerts_on_plan_ind, reply->qual_phase[phasecnt].alerts_on_plan_upd_ind
     = pwc.alerts_on_plan_upd_ind,
    reply->qual_phase[phasecnt].default_action_inpt_future_cd = pwc.default_action_inpt_future_cd,
    reply->qual_phase[phasecnt].default_action_inpt_now_cd = pwc.default_action_inpt_now_cd, reply->
    qual_phase[phasecnt].default_action_outpt_future_cd = pwc.default_action_outpt_future_cd,
    reply->qual_phase[phasecnt].default_action_outpt_now_cd = pwc.default_action_outpt_now_cd, reply
    ->qual_phase[phasecnt].optional_ind = pwc.optional_ind, reply->qual_phase[phasecnt].future_ind =
    pwc.future_ind,
    reply->qual_phase[phasecnt].period_custom_label = pwc.period_custom_label, reply->qual_phase[
    phasecnt].route_for_review_ind = pwc.route_for_review_ind, reply->qual_phase[phasecnt].
    pathway_class_cd = pwc.pathway_class_cd,
    reply->qual_phase[phasecnt].default_start_time_txt = trim(pwc.default_start_time_txt), reply->
    qual_phase[phasecnt].primary_ind = pwc.primary_ind, reply->qual_phase[phasecnt].uuid = trim(pwc
     .pathway_uuid),
    reply->qual_phase[phasecnt].reschedule_reason_accept_flag = pwc.reschedule_reason_accept_flag,
    reply->qual_phase[phasecnt].open_by_default_ind = pwc.open_by_default_ind, reply->qual_phase[
    phasecnt].allow_activate_all_ind = evaluate(pwc.disable_activate_all_ind,1,0,0,1),
    reply->qual_phase[phasecnt].review_required_sig_count = pwc.review_required_sig_count, reply->
    qual_phase[phasecnt].linked_phase_ind = validate(pwc.linked_phase_ind,0), reltncnt = 0
   DETAIL
    IF (pcr2.pw_cat_s_id > 0
     AND pcr2.type_mean IN ("SUCCEED", "PHASEOFFSET"))
     reltncnt += 1
     IF (reltncnt > size(reply->qual_phase[phasecnt].qual_phase_reltn,5))
      stat = alterlist(reply->qual_phase[phasecnt].qual_phase_reltn,(reltncnt+ 10))
     ENDIF
     reply->qual_phase[phasecnt].qual_phase_reltn[reltncnt].pw_cat_s_id = pcr2.pw_cat_s_id, reply->
     qual_phase[phasecnt].qual_phase_reltn[reltncnt].pw_cat_t_id = pcr2.pw_cat_t_id, reply->
     qual_phase[phasecnt].qual_phase_reltn[reltncnt].type_mean = pcr2.type_mean,
     reply->qual_phase[phasecnt].qual_phase_reltn[reltncnt].offset_qty = pcr2.offset_qty, reply->
     qual_phase[phasecnt].qual_phase_reltn[reltncnt].offset_unit_cd = pcr2.offset_unit_cd
    ENDIF
   FOOT  pcr1.pw_cat_t_id
    stat = alterlist(reply->qual_phase[phasecnt].qual_phase_reltn,reltncnt)
   FOOT REPORT
    stat = alterlist(reply->qual_phase,phasecnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL report_failure("SELECT","F","DCP_GET_PLAN_CAT_DETAIL","Unable to retrieve plan's phases")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->ref_owner_person_id=0))
  IF ((reply->qual_phase[1].type_mean="PATHWAY"))
   SET lstart = 2
  ELSE
   SET lstart = 1
  ENDIF
  SET high = value(size(reply->qual_phase,5))
  SELECT INTO "nl:"
   pcr1.pw_cat_t_id, pwc.pathway_catalog_id, pcr2.pw_cat_t_id
   FROM pathway_catalog pwc,
    pw_cat_reltn pcr1,
    pw_cat_reltn pcr2
   PLAN (pcr1
    WHERE expand(num,lstart,high,pcr1.pw_cat_s_id,reply->qual_phase[num].pathway_catalog_id)
     AND pcr1.type_mean="GROUP")
    JOIN (pwc
    WHERE pwc.pathway_catalog_id=pcr1.pw_cat_t_id)
    JOIN (pcr2
    WHERE (pcr2.pw_cat_s_id= Outerjoin(pwc.pathway_catalog_id)) )
   ORDER BY pcr1.pw_cat_s_id, pcr1.pw_cat_t_id, pcr2.pw_cat_t_id
   HEAD REPORT
    phasecnt = high
   HEAD pcr1.pw_cat_s_id
    idx = locateval(idx,lstart,high,pcr1.pw_cat_s_id,reply->qual_phase[idx].pathway_catalog_id),
    parentreltncnt = size(reply->qual_phase[idx].qual_phase_reltn,5)
   HEAD pcr1.pw_cat_t_id
    IF (idx != 0)
     parentreltncnt += 1
     IF (parentreltncnt > size(reply->qual_phase[idx].qual_phase_reltn,5))
      stat = alterlist(reply->qual_phase[idx].qual_phase_reltn,(parentreltncnt+ 10))
     ENDIF
     reply->qual_phase[idx].qual_phase_reltn[parentreltncnt].pw_cat_s_id = pcr1.pw_cat_s_id, reply->
     qual_phase[idx].qual_phase_reltn[parentreltncnt].pw_cat_t_id = pcr1.pw_cat_t_id, reply->
     qual_phase[idx].qual_phase_reltn[parentreltncnt].type_mean = pcr1.type_mean,
     reply->qual_phase[idx].qual_phase_reltn[parentreltncnt].offset_qty = pcr1.offset_qty, reply->
     qual_phase[idx].qual_phase_reltn[parentreltncnt].offset_unit_cd = pcr1.offset_unit_cd
    ENDIF
    phasecnt += 1
    IF (phasecnt > size(reply->qual_phase,5))
     stat = alterlist(reply->qual_phase,(phasecnt+ 10))
    ENDIF
    reply->qual_phase[phasecnt].pathway_catalog_id = pwc.pathway_catalog_id, reply->qual_phase[
    phasecnt].description = pwc.description, reply->qual_phase[phasecnt].duration_qty = pwc
    .duration_qty,
    reply->qual_phase[phasecnt].duration_unit_cd = pwc.duration_unit_cd, reply->qual_phase[phasecnt].
    type_mean = pwc.type_mean, reply->qual_phase[phasecnt].period_nbr = pwc.period_nbr,
    reply->qual_phase[phasecnt].primary_ind = pwc.primary_ind, reply->qual_phase[phasecnt].uuid =
    trim(pwc.pathway_uuid), reply->qual_phase[phasecnt].reschedule_reason_accept_flag = pwc
    .reschedule_reason_accept_flag,
    reply->qual_phase[phasecnt].open_by_default_ind = pwc.open_by_default_ind, reply->qual_phase[
    phasecnt].allow_activate_all_ind = evaluate(pwc.disable_activate_all_ind,1,0,0,1), reltncnt =
    size(reply->qual_phase[phasecnt].qual_phase_reltn,5)
   DETAIL
    IF (pcr2.pw_cat_s_id > 0
     AND pcr2.type_mean IN ("SUCCEED", "PHASEOFFSET"))
     reltncnt += 1
     IF (reltncnt > size(reply->qual_phase[phasecnt].qual_phase_reltn,5))
      stat = alterlist(reply->qual_phase[phasecnt].qual_phase_reltn,(reltncnt+ 10))
     ENDIF
     reply->qual_phase[phasecnt].qual_phase_reltn[reltncnt].pw_cat_s_id = pcr2.pw_cat_s_id, reply->
     qual_phase[phasecnt].qual_phase_reltn[reltncnt].pw_cat_t_id = pcr2.pw_cat_t_id, reply->
     qual_phase[phasecnt].qual_phase_reltn[reltncnt].type_mean = pcr2.type_mean,
     reply->qual_phase[phasecnt].qual_phase_reltn[reltncnt].offset_qty = pcr2.offset_qty, reply->
     qual_phase[phasecnt].qual_phase_reltn[reltncnt].offset_unit_cd = pcr2.offset_unit_cd
    ENDIF
   FOOT  pcr1.pw_cat_t_id
    stat = alterlist(reply->qual_phase[phasecnt].qual_phase_reltn,reltncnt)
   FOOT  pcr1.pw_cat_s_id
    stat = alterlist(reply->qual_phase[idx].qual_phase_reltn,parentreltncnt)
   FOOT REPORT
    stat = alterlist(reply->qual_phase,phasecnt)
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 FREE RECORD internal
 IF (((validate(request->skip_sub_phase_ind,999)=999) OR (validate(request->skip_sub_phase_ind,999)=0
 )) )
  SET getsubphasecompflag = "Y"
 ENDIF
 IF (getsubphasecompflag="Y")
  SET high = value(size(reply->qual_phase,5))
  SELECT INTO "nl:"
   pcr.pw_cat_t_id, pwc1.pathway_catalog_id, pwc2.pathway_catalog_id
   FROM pw_cat_reltn pcr,
    pathway_catalog pwc1,
    pathway_catalog pwc2,
    (dummyt d  WITH seq = 1)
   PLAN (pcr
    WHERE expand(num,1,high,pcr.pw_cat_s_id,reply->qual_phase[num].pathway_catalog_id)
     AND pcr.pw_cat_t_id > 0
     AND pcr.type_mean="SUBPHASE")
    JOIN (pwc1
    WHERE pcr.pw_cat_t_id=pwc1.pathway_catalog_id)
    JOIN (d)
    JOIN (pwc2
    WHERE pwc1.version_pw_cat_id=pwc2.version_pw_cat_id
     AND pwc2.version_pw_cat_id != 0
     AND pwc2.active_ind=1)
   HEAD REPORT
    phasecnt = 0
   DETAIL
    IF (cnvtdatetime(pwc2.beg_effective_dt_tm) <= cnvtdatetime(sysdate))
     phasecnt += 1
     IF (phasecnt > size(subphases->list,5))
      stat = alterlist(subphases->list,(phasecnt+ 10))
     ENDIF
     IF (pwc2.pathway_catalog_id > 0)
      subphases->list[phasecnt].orig_pathway_catalog_id = pwc1.pathway_catalog_id, subphases->list[
      phasecnt].new_pathway_catalog_id = pwc2.pathway_catalog_id, subphases->list[phasecnt].
      description = pwc2.description,
      subphases->list[phasecnt].duration_qty = pwc2.duration_qty, subphases->list[phasecnt].
      duration_unit_cd = pwc2.duration_unit_cd, subphases->list[phasecnt].phase_updt_cnt = pwc2
      .updt_cnt,
      subphases->list[phasecnt].display_description = pwc2.display_description, subphases->list[
      phasecnt].display_method_cd = pwc2.display_method_cd, subphases->list[phasecnt].
      hide_flexed_comp_ind = pwc2.hide_flexed_comp_ind,
      subphases->list[phasecnt].cat_sub_phase_ind = pwc2.sub_phase_ind, subphases->list[phasecnt].
      active_ind = pwc2.active_ind, subphases->list[phasecnt].uuid = trim(pwc2.pathway_uuid)
     ELSE
      subphases->list[phasecnt].orig_pathway_catalog_id = pwc1.pathway_catalog_id, subphases->list[
      phasecnt].new_pathway_catalog_id = pwc1.pathway_catalog_id, subphases->list[phasecnt].
      description = pwc1.description,
      subphases->list[phasecnt].duration_qty = pwc1.duration_qty, subphases->list[phasecnt].
      duration_unit_cd = pwc1.duration_unit_cd, subphases->list[phasecnt].phase_updt_cnt = pwc1
      .updt_cnt,
      subphases->list[phasecnt].display_description = pwc1.display_description, subphases->list[
      phasecnt].display_method_cd = pwc1.display_method_cd, subphases->list[phasecnt].
      hide_flexed_comp_ind = pwc1.hide_flexed_comp_ind,
      subphases->list[phasecnt].cat_sub_phase_ind = pwc1.sub_phase_ind, subphases->list[phasecnt].
      active_ind = pwc1.active_ind, subphases->list[phasecnt].uuid = trim(pwc1.pathway_uuid)
     ENDIF
    ENDIF
   FOOT REPORT
    IF (phasecnt > 0)
     stat = alterlist(subphases->list,phasecnt)
    ENDIF
   WITH nocounter, outerjoin = d, expand = 1
  ;end select
  IF (value(size(subphases->list,5)) > 0)
   IF (((filterorc=1) OR (filterorc=0)) )
    SET high = value(size(subphases->list,5))
    SET num = 0
    SELECT INTO "nl:"
     FROM pw_cat_flex pcf
     PLAN (pcf
      WHERE expand(num,1,high,pcf.pathway_catalog_id,subphases->list[num].new_pathway_catalog_id)
       AND pcf.parent_entity_name="CODE_VALUE")
     ORDER BY pcf.pathway_catalog_id
     HEAD REPORT
      idx = 0
     HEAD pcf.pathway_catalog_id
      facilitycnt = 0, facilityind = 0, allfacilityind = 0,
      idx = locateval(idx,1,high,pcf.pathway_catalog_id,subphases->list[idx].new_pathway_catalog_id)
     DETAIL
      IF (pcf.parent_entity_id=0)
       facilityind = 1, allfacilityind = 1
      ELSEIF (pcf.parent_entity_id > 0
       AND pcf.parent_entity_id=facilitycd)
       facilityind = 1
      ENDIF
      IF (pcf.parent_entity_id > 0)
       facilitycnt += 1, stat = alterlist(subphases->list[idx].facilitylist,facilitycnt), subphases->
       list[idx].facilitylist[facilitycnt].facility_cd = pcf.parent_entity_id
      ENDIF
     FOOT  pcf.pathway_catalog_id
      subphases->list[idx].facility_ind = facilityind, subphases->list[idx].all_facility_access_ind
       = allfacilityind, facidx = idx,
      idx2 = idx
      WHILE (idx != 0)
       idx2 = locateval(idx2,(idx+ 1),high,pcf.pathway_catalog_id,subphases->list[idx2].
        new_pathway_catalog_id),
       IF (idx2 != 0)
        idx = idx2, subphases->list[idx].all_facility_access_ind = allfacilityind, subphases->list[
        idx].facility_ind = facilityind
        IF (facilitycnt > 0)
         stat = alterlist(subphases->list[idx].facilitylist,facilitycnt)
         FOR (i = 1 TO facilitycnt)
           subphases->list[idx].facilitylist[i].facility_cd = subphases->list[facidx].facilitylist[i]
           .facility_cd
         ENDFOR
        ENDIF
       ELSE
        idx = idx2
       ENDIF
      ENDWHILE
     FOOT REPORT
      idx = 0
     WITH nocounter, expand = 1
    ;end select
   ENDIF
   SET phasecnt = value(size(reply->qual_phase,5))
   FOR (i = 1 TO value(size(subphases->list,5)))
     IF (((filterorc <= 0) OR (((planhideflexedcomps=0) OR (filterorc=1
      AND (subphases->list[i].facility_ind=1))) )) )
      SET phasecnt += 1
      SET stat = alterlist(reply->qual_phase,phasecnt)
      SET reply->qual_phase[phasecnt].uuid = trim(subphases->list[i].uuid)
      SET reply->qual_phase[phasecnt].pathway_catalog_id = subphases->list[i].new_pathway_catalog_id
      SET reply->qual_phase[phasecnt].description = subphases->list[i].description
      SET reply->qual_phase[phasecnt].duration_qty = subphases->list[i].duration_qty
      SET reply->qual_phase[phasecnt].duration_unit_cd = subphases->list[i].duration_unit_cd
      SET reply->qual_phase[phasecnt].phase_updt_cnt = subphases->list[i].phase_updt_cnt
      SET reply->qual_phase[phasecnt].time_zero_ind = 0
      SET reply->qual_phase[phasecnt].display_description = subphases->list[i].display_description
      SET reply->qual_phase[phasecnt].start_offset_ind = 0
      SET reply->qual_phase[phasecnt].type_mean = "SUBPHASE"
      SET reply->qual_phase[phasecnt].display_method_cd = subphases->list[i].display_method_cd
      SET reply->qual_phase[phasecnt].sub_phase_ind = 0
      SET reply->qual_phase[phasecnt].hide_flexed_comp_ind = subphases->list[i].hide_flexed_comp_ind
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 FREE RECORD subphases
 SET high = value(size(reply->qual_phase,5))
 SELECT INTO "nl:"
  FROM pathway_comp pc
  PLAN (pc
   WHERE expand(num,1,high,pc.pathway_catalog_id,reply->qual_phase[num].pathway_catalog_id)
    AND pc.active_ind=1)
  ORDER BY pc.pathway_catalog_id, pc.parent_entity_id
  HEAD REPORT
   occnt = 0, ocsize = 0, ltcnt = 0,
   outcomecnt = 0, spcnt = 0, idx = 0,
   displaymethodcd = 0, baddtocompphasereltn = 0, comp_phase_reltn->count = 0,
   comp_phase_reltn->size = 0, comp_phase_reltn->batch_size = 20, comp_phase_reltn->loop_count = 0
  HEAD pc.pathway_catalog_id
   idx = locateval(idx,1,high,pc.pathway_catalog_id,reply->qual_phase[idx].pathway_catalog_id),
   displaymethodcd = reply->qual_phase[idx].display_method_cd
  DETAIL
   baddtocompphasereltn = 0
   IF (pc.comp_type_cd IN (order_comp_cd, prescription_comp_cd))
    baddtocompphasereltn = 1, occnt += 1
    IF (occnt > ocsize)
     ocsize += 20, stat = alterlist(temp->oclist,ocsize)
    ENDIF
    temp->oclist[occnt].pathway_catalog_id = pc.pathway_catalog_id, temp->oclist[occnt].
    pathway_comp_id = pc.pathway_comp_id, temp->oclist[occnt].dcp_clin_cat_cd = pc.dcp_clin_cat_cd,
    temp->oclist[occnt].dcp_clin_sub_cat_cd = pc.dcp_clin_sub_cat_cd, temp->oclist[occnt].sequence =
    pc.sequence, temp->oclist[occnt].comp_type_cd = pc.comp_type_cd,
    temp->oclist[occnt].parent_entity_name = pc.parent_entity_name, temp->oclist[occnt].
    parent_entity_id = pc.parent_entity_id, temp->oclist[occnt].required_ind = pc.required_ind,
    temp->oclist[occnt].included_ind = pc.include_ind, temp->oclist[occnt].linked_to_tf_ind = pc
    .linked_to_tf_ind, temp->oclist[occnt].comp_updt_cnt = pc.updt_cnt,
    temp->oclist[occnt].comp_label = pc.comp_label, temp->oclist[occnt].offset_quantity = pc
    .offset_quantity, temp->oclist[occnt].offset_unit_cd = pc.offset_unit_cd,
    temp->oclist[occnt].cross_phase_group_desc = pc.cross_phase_group_desc, temp->oclist[occnt].
    cross_phase_group_nbr = pc.cross_phase_group_nbr, temp->oclist[occnt].chemo_ind = pc.chemo_ind,
    temp->oclist[occnt].chemo_related_ind = pc.chemo_related_ind, temp->oclist[occnt].default_os_ind
     = pc.default_os_ind, temp->oclist[occnt].min_tolerance_interval = pc.min_tolerance_interval,
    temp->oclist[occnt].min_tolerance_interval_unit_cd = pc.min_tolerance_interval_unit_cd, temp->
    oclist[occnt].uuid = trim(pc.pathway_uuid), temp->oclist[occnt].display_format_xml = trim(pc
     .display_format_xml),
    temp->oclist[occnt].lock_target_dose_flag = pc.lock_target_dose_flag
    IF (displaymethodcd IN (clin_cat_display_method_cd, 0))
     temp->oclist[occnt].sort_cd = pc.dcp_clin_cat_cd
    ENDIF
   ELSEIF (pc.comp_type_cd=note_comp_cd)
    baddtocompphasereltn = 1, ltcnt += 1
    IF (ltcnt > size(temp->ltlist,5))
     stat = alterlist(temp->ltlist,(ltcnt+ 10))
    ENDIF
    temp->ltlist[ltcnt].pathway_catalog_id = pc.pathway_catalog_id, temp->ltlist[ltcnt].
    pathway_comp_id = pc.pathway_comp_id, temp->ltlist[ltcnt].dcp_clin_cat_cd = pc.dcp_clin_cat_cd,
    temp->ltlist[ltcnt].dcp_clin_sub_cat_cd = pc.dcp_clin_sub_cat_cd, temp->ltlist[ltcnt].sequence =
    pc.sequence, temp->ltlist[ltcnt].comp_type_cd = pc.comp_type_cd,
    temp->ltlist[ltcnt].parent_entity_name = pc.parent_entity_name, temp->ltlist[ltcnt].
    parent_entity_id = pc.parent_entity_id, temp->ltlist[ltcnt].persistent_ind = pc.persistent_ind,
    temp->ltlist[ltcnt].comp_updt_cnt = pc.updt_cnt, temp->ltlist[ltcnt].comp_label = pc.comp_label,
    temp->ltlist[ltcnt].chemo_related_ind = pc.chemo_related_ind,
    temp->ltlist[ltcnt].uuid = trim(pc.pathway_uuid), temp->ltlist[ltcnt].display_format_xml = trim(
     pc.display_format_xml)
    IF (displaymethodcd IN (clin_cat_display_method_cd, 0))
     temp->ltlist[ltcnt].sort_cd = pc.dcp_clin_cat_cd
    ENDIF
   ELSEIF (pc.comp_type_cd=outcome_comp_cd)
    baddtocompphasereltn = 1, outcomecnt += 1
    IF (outcomecnt > size(temp->outcomelist,5))
     stat = alterlist(temp->outcomelist,(outcomecnt+ 10))
    ENDIF
    temp->outcomelist[outcomecnt].pathway_catalog_id = pc.pathway_catalog_id, temp->outcomelist[
    outcomecnt].pathway_comp_id = pc.pathway_comp_id, temp->outcomelist[outcomecnt].dcp_clin_cat_cd
     = pc.dcp_clin_cat_cd,
    temp->outcomelist[outcomecnt].dcp_clin_sub_cat_cd = pc.dcp_clin_sub_cat_cd, temp->outcomelist[
    outcomecnt].sequence = pc.sequence, temp->outcomelist[outcomecnt].comp_type_cd = pc.comp_type_cd,
    temp->outcomelist[outcomecnt].parent_entity_name = pc.parent_entity_name, temp->outcomelist[
    outcomecnt].parent_entity_id = pc.parent_entity_id, temp->outcomelist[outcomecnt].required_ind =
    pc.required_ind,
    temp->outcomelist[outcomecnt].included_ind = pc.include_ind, temp->outcomelist[outcomecnt].
    linked_to_tf_ind = pc.linked_to_tf_ind, temp->outcomelist[outcomecnt].comp_updt_cnt = pc.updt_cnt,
    temp->outcomelist[outcomecnt].target_type_cd = pc.target_type_cd, temp->outcomelist[outcomecnt].
    duration_qty = pc.duration_qty, temp->outcomelist[outcomecnt].duration_unit_cd = pc
    .duration_unit_cd,
    temp->outcomelist[outcomecnt].expand_qty = pc.expand_qty, temp->outcomelist[outcomecnt].
    expand_unit_cd = pc.expand_unit_cd, temp->outcomelist[outcomecnt].comp_label = pc.comp_label,
    temp->outcomelist[outcomecnt].offset_quantity = pc.offset_quantity, temp->outcomelist[outcomecnt]
    .offset_unit_cd = pc.offset_unit_cd, temp->outcomelist[outcomecnt].chemo_related_ind = pc
    .chemo_related_ind,
    temp->outcomelist[outcomecnt].uuid = trim(pc.pathway_uuid), temp->outcomelist[outcomecnt].
    display_format_xml = trim(pc.display_format_xml)
    IF (displaymethodcd IN (clin_cat_display_method_cd, 0))
     temp->outcomelist[outcomecnt].sort_cd = pc.dcp_clin_cat_cd
    ENDIF
   ELSEIF (pc.comp_type_cd=subphase_comp_cd)
    baddtocompphasereltn = 1, spcnt += 1
    IF (spcnt > size(temp->splist,5))
     stat = alterlist(temp->splist,(spcnt+ 10))
    ENDIF
    temp->splist[spcnt].pathway_catalog_id = pc.pathway_catalog_id, temp->splist[spcnt].
    pathway_comp_id = pc.pathway_comp_id, temp->splist[spcnt].dcp_clin_cat_cd = pc.dcp_clin_cat_cd,
    temp->splist[spcnt].dcp_clin_sub_cat_cd = pc.dcp_clin_sub_cat_cd, temp->splist[spcnt].sequence =
    pc.sequence, temp->splist[spcnt].comp_type_cd = pc.comp_type_cd,
    temp->splist[spcnt].comp_label = pc.comp_label, temp->splist[spcnt].parent_entity_name = pc
    .parent_entity_name, temp->splist[spcnt].parent_entity_id = pc.parent_entity_id,
    temp->splist[spcnt].included_ind = pc.include_ind, temp->splist[spcnt].comp_updt_cnt = pc
    .updt_cnt, temp->splist[spcnt].offset_quantity = pc.offset_quantity,
    temp->splist[spcnt].offset_unit_cd = pc.offset_unit_cd, temp->splist[spcnt].
    cross_phase_group_desc = pc.cross_phase_group_desc, temp->splist[spcnt].cross_phase_group_nbr =
    pc.cross_phase_group_nbr,
    temp->splist[spcnt].chemo_related_ind = pc.chemo_related_ind, temp->splist[spcnt].
    min_tolerance_interval = pc.min_tolerance_interval, temp->splist[spcnt].
    min_tolerance_interval_unit_cd = pc.min_tolerance_interval_unit_cd,
    temp->splist[spcnt].uuid = trim(pc.pathway_uuid), temp->splist[spcnt].display_format_xml = trim(
     pc.display_format_xml)
    IF (displaymethodcd IN (clin_cat_display_method_cd, 0))
     temp->splist[spcnt].sort_cd = pc.dcp_clin_cat_cd
    ENDIF
   ENDIF
   IF (baddtocompphasereltn=1)
    comp_phase_reltn->count += 1
    IF ((comp_phase_reltn->count > comp_phase_reltn->size))
     comp_phase_reltn->size += comp_phase_reltn->batch_size, comp_phase_reltn->loop_count += 1, stat
      = alterlist(comp_phase_reltn->components,comp_phase_reltn->size)
    ENDIF
    comp_phase_reltn->components[comp_phase_reltn->count].pathway_comp_id = pc.pathway_comp_id
   ENDIF
  FOOT REPORT
   FOR (idx = (comp_phase_reltn->count+ 1) TO comp_phase_reltn->size)
     comp_phase_reltn->components[idx].pathway_comp_id = comp_phase_reltn->components[
     comp_phase_reltn->count].pathway_comp_id
   ENDFOR
   IF (occnt > 0
    AND occnt < ocsize)
    stat = alterlist(temp->oclist,occnt)
   ENDIF
   IF (ltcnt > 0)
    stat = alterlist(temp->ltlist,ltcnt)
   ENDIF
   IF (outcomecnt > 0)
    stat = alterlist(temp->outcomelist,outcomecnt)
   ENDIF
   IF (spcnt > 0)
    stat = alterlist(temp->splist,spcnt)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF ((comp_phase_reltn->count > 0))
  SET lstart = 1
  SELECT INTO "nl:"
   pccr.pathway_comp_id, pccr.pathway_catalog_id, pccr.type_mean
   FROM (dummyt d  WITH seq = value(comp_phase_reltn->loop_count)),
    pw_comp_cat_reltn pccr
   PLAN (d
    WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ comp_phase_reltn->batch_size))))
    JOIN (pccr
    WHERE expand(idx,lstart,(lstart+ (comp_phase_reltn->batch_size - 1)),pccr.pathway_comp_id,
     comp_phase_reltn->components[idx].pathway_comp_id))
   ORDER BY pccr.pathway_catalog_id, pccr.pathway_comp_id, pccr.type_mean
   HEAD REPORT
    lcompphasereltncount = 0, lcompphasereltnsize = 0
   HEAD pccr.pathway_catalog_id
    ltreatmentlinkedcompcount = 0, ltreatmentlinkedcompsize = 0, idx = locateval(idx,1,high,pccr
     .pathway_catalog_id,reply->qual_phase[idx].pathway_catalog_id)
   DETAIL
    IF (pccr.type_mean="DOT")
     ltreatmentlinkedcompcount += 1
     IF (ltreatmentlinkedcompcount > ltreatmentlinkedcompsize)
      ltreatmentlinkedcompsize += 10, stat = alterlist(reply->qual_phase[idx].
       treatment_linked_comp_list,ltreatmentlinkedcompsize)
     ENDIF
     reply->qual_phase[idx].treatment_linked_comp_list[ltreatmentlinkedcompcount].pathway_comp_id =
     pccr.pathway_comp_id
    ENDIF
    lcompphasereltncount += 1
    IF (lcompphasereltncount > lcompphasereltnsize)
     lcompphasereltnsize += 10, stat = alterlist(reply->compphasereltnlist,lcompphasereltnsize)
    ENDIF
    reply->compphasereltnlist[lcompphasereltncount].pw_comp_cat_reltn_id = pccr.pw_comp_cat_reltn_id,
    reply->compphasereltnlist[lcompphasereltncount].pathway_comp_id = pccr.pathway_comp_id, reply->
    compphasereltnlist[lcompphasereltncount].pathway_catalog_id = pccr.pathway_catalog_id,
    reply->compphasereltnlist[lcompphasereltncount].type_mean = pccr.type_mean
   FOOT  pccr.pathway_catalog_id
    IF (ltreatmentlinkedcompcount > 0)
     stat = alterlist(reply->qual_phase[idx].treatment_linked_comp_list,ltreatmentlinkedcompcount)
    ENDIF
   FOOT REPORT
    IF (lcompphasereltncount > 0
     AND lcompphasereltncount < lcompphasereltnsize)
     lcompphasereltnsize = lcompphasereltncount, stat = alterlist(reply->compphasereltnlist,
      lcompphasereltncount)
    ENDIF
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (value(size(temp->ltlist,5)) > 0)
  SET high = value(size(temp->ltlist,5))
  SELECT INTO "nl:"
   FROM long_text lt
   PLAN (lt
    WHERE expand(num,1,high,lt.long_text_id,temp->ltlist[num].parent_entity_id))
   HEAD REPORT
    idx = 0
   DETAIL
    idx = locateval(idx,1,high,lt.long_text_id,temp->ltlist[idx].parent_entity_id)
    IF (idx > 0)
     temp->ltlist[idx].comp_text_id = lt.long_text_id, temp->ltlist[idx].comp_text = trim(lt
      .long_text), temp->ltlist[idx].comp_text_updt_cnt = lt.updt_cnt
    ENDIF
   FOOT REPORT
    idx = 0
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (value(size(temp->oclist,5)) > 0)
  SET high = value(size(temp->oclist,5))
  SET phasecnt = value(size(reply->qual_phase,5))
  SELECT INTO "nl:"
   pc.pathway_catalog_id, pc.pathway_comp_id, pcr.pathway_comp_s_id,
   pcr.pathway_comp_t_id, pcr.type_mean
   FROM pw_comp_reltn pcr,
    pathway_comp pc
   PLAN (pcr
    WHERE expand(num,1,high,pcr.pathway_comp_s_id,temp->oclist[num].pathway_comp_id))
    JOIN (pc
    WHERE pc.pathway_comp_id=pcr.pathway_comp_s_id)
   ORDER BY pc.pathway_catalog_id, pcr.pathway_catalog_id
   HEAD REPORT
    idx = 0
   HEAD pc.pathway_catalog_id
    comp_r_cnt = 0
   HEAD pcr.pathway_catalog_id
    IF (pc.pathway_catalog_id != pcr.pathway_catalog_id)
     tzexceptidx = locateval(tzexceptidx,1,phasecnt,pcr.pathway_catalog_id,reply->qual_phase[
      tzexceptidx].pathway_catalog_id)
    ENDIF
    tzexceptcnt = 0
   DETAIL
    IF (pcr.pathway_comp_s_id > 0
     AND trim(pcr.type_mean)="TIMEZERO")
     comp_r_cnt += 1
     IF (comp_r_cnt=1)
      idx = (size(temp2->phaselist,5)+ 1), stat = alterlist(temp2->phaselist,idx), temp2->phaselist[
      idx].pathway_catalog_id = pc.pathway_catalog_id
     ENDIF
     IF (comp_r_cnt > size(temp2->phaselist[idx].comprlist,5))
      stat = alterlist(temp2->phaselist[idx].comprlist,(comp_r_cnt+ 10))
     ENDIF
     temp2->phaselist[idx].comprlist[comp_r_cnt].source_id = pcr.pathway_comp_s_id, temp2->phaselist[
     idx].comprlist[comp_r_cnt].target_id = pcr.pathway_comp_t_id, temp2->phaselist[idx].comprlist[
     comp_r_cnt].type_mean = pcr.type_mean,
     temp2->phaselist[idx].comprlist[comp_r_cnt].offset_quantity = pcr.offset_quantity, temp2->
     phaselist[idx].comprlist[comp_r_cnt].offset_unit_cd = pcr.offset_unit_cd
    ELSEIF (pcr.pathway_comp_s_id > 0
     AND trim(pcr.type_mean)="TIMEZERODOT")
     tzexceptcnt += 1
     IF (tzexceptcnt > size(reply->qual_phase[tzexceptidx].time_zero_exceptions,5))
      stat = alterlist(reply->qual_phase[tzexceptidx].time_zero_exceptions,(tzexceptcnt+ 10))
     ENDIF
     reply->qual_phase[tzexceptidx].time_zero_exceptions[tzexceptcnt].pw_cat_s_id = pcr
     .pathway_comp_s_id, reply->qual_phase[tzexceptidx].time_zero_exceptions[tzexceptcnt].pw_cat_t_id
      = pcr.pathway_comp_t_id, reply->qual_phase[tzexceptidx].time_zero_exceptions[tzexceptcnt].
     type_mean = trim(pcr.type_mean),
     reply->qual_phase[tzexceptidx].time_zero_exceptions[tzexceptcnt].offset_qty = pcr
     .offset_quantity, reply->qual_phase[tzexceptidx].time_zero_exceptions[tzexceptcnt].
     offset_unit_cd = pcr.offset_unit_cd, reply->qual_phase[tzexceptidx].time_zero_exceptions[
     tzexceptcnt].offset_quantity = pcr.offset_quantity
    ENDIF
   FOOT  pc.pathway_catalog_id
    IF (idx > 0
     AND comp_r_cnt > 0)
     stat = alterlist(temp2->phaselist[idx].comprlist,comp_r_cnt)
    ENDIF
   FOOT  pcr.pathway_catalog_id
    IF (tzexceptcnt > 0)
     stat = alterlist(reply->qual_phase[tzexceptidx].time_zero_exceptions,tzexceptcnt)
    ENDIF
   FOOT REPORT
    dummy = 0
   WITH nocounter, expand = 1
  ;end select
  SELECT INTO "nl:"
   ocs.mnemonic, ocs.mnemonic_type_cd, ocs.synonym_id,
   ofr.synonym_id, ofr.facility_cd
   FROM order_catalog_synonym ocs,
    ocs_facility_r ofr,
    order_catalog oc
   PLAN (ocs
    WHERE expand(num,1,high,ocs.synonym_id,temp->oclist[num].parent_entity_id))
    JOIN (ofr
    WHERE ofr.synonym_id IN (ocs.synonym_id, 0))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
   ORDER BY ocs.synonym_id, ofr.synonym_id DESC, ofr.facility_cd DESC
   HEAD REPORT
    idx = 0, ivcnt = 0
   HEAD ocs.synonym_id
    facilityind = 0, allfacilityind = 0, faccnt = 0,
    ofrcnt = 0, idx = locateval(idx,1,high,ocs.synonym_id,temp->oclist[idx].parent_entity_id), temp->
    oclist[idx].synonym_id = ocs.synonym_id,
    temp->oclist[idx].catalog_cd = ocs.catalog_cd, temp->oclist[idx].catalog_type_cd = ocs
    .catalog_type_cd, temp->oclist[idx].activity_type_cd = ocs.activity_type_cd,
    temp->oclist[idx].mnemonic = trim(ocs.mnemonic), temp->oclist[idx].mnemonic_type_cd = ocs
    .mnemonic_type_cd, temp->oclist[idx].oe_format_id = ocs.oe_format_id,
    temp->oclist[idx].ocs_clin_cat_cd = ocs.dcp_clin_cat_cd, temp->oclist[idx].rx_mask = ocs.rx_mask,
    temp->oclist[idx].orderable_type_flag = ocs.orderable_type_flag,
    temp->oclist[idx].parent_active_ind = ocs.active_ind, temp->oclist[idx].hna_order_mnemonic = oc
    .primary_mnemonic, temp->oclist[idx].cki = oc.cki,
    temp->oclist[idx].ref_text_mask = ocs.ref_text_mask, temp->oclist[idx].high_alert_ind = ocs
    .high_alert_ind, temp->oclist[idx].high_alert_long_text_id = ocs.high_alert_long_text_id,
    temp->oclist[idx].high_alert_required_ntfy_ind = ocs.high_alert_required_ntfy_ind, temp->oclist[
    idx].schedule_ind = oc.schedule_ind, temp->oclist[idx].intermittent_ind = ocs.intermittent_ind
    IF ((temp->oclist[idx].high_alert_ind=1))
     loadhighalerttextflag = "Y"
    ENDIF
    IF ((((temp->oclist[idx].orderable_type_flag=8)) OR ((temp->oclist[idx].orderable_type_flag=11)
    )) )
     ivcnt += 1, stat = alterlist(temp3->ivlist,ivcnt), temp3->ivlist[ivcnt].pathway_comp_id = temp->
     oclist[idx].pathway_comp_id,
     temp3->ivlist[ivcnt].synonym_id = temp->oclist[idx].synonym_id, temp3->ivlist[ivcnt].catalog_cd
      = temp->oclist[idx].catalog_cd
    ENDIF
   DETAIL
    ofrcnt += 1
    IF (filterorc=1
     AND facilityind=0)
     IF (facilitycd=0)
      facilityind = 1, allfacilityind = 1
     ELSEIF (ofr.facility_cd=0
      AND ofr.synonym_id > 0)
      facilityind = 1, allfacilityind = 1
     ELSEIF (ofr.facility_cd=0
      AND ofr.synonym_id=0
      AND ofrcnt=1)
      facilityind = 0, allfacilityind = 0
     ELSEIF (ofr.facility_cd > 0
      AND ofr.facility_cd=facilitycd)
      facilityind = 1, allfacilityind = 0
     ENDIF
    ELSEIF (filterorc=0)
     IF (ofr.facility_cd=0
      AND ofr.synonym_id > 0)
      facilityind = 1, allfacilityind = 1
     ELSEIF (ofr.facility_cd=0
      AND ofr.synonym_id=0
      AND ofrcnt=1)
      facilityind = 0, allfacilityind = 0
     ELSEIF (ofr.facility_cd > 0)
      faccnt += 1, stat = alterlist(temp->oclist[idx].facilitylist,faccnt), temp->oclist[idx].
      facilitylist[faccnt].facility_cd = ofr.facility_cd
     ENDIF
    ELSEIF ((filterorc=- (1)))
     facilityind = 1
    ENDIF
   FOOT  ocs.synonym_id
    temp->oclist[idx].facility_ind = facilityind, temp->oclist[idx].all_facility_access_ind =
    allfacilityind, facidx = idx,
    idx2 = idx
    WHILE (idx != 0)
     idx2 = locateval(idx2,(idx+ 1),high,ocs.synonym_id,temp->oclist[idx2].parent_entity_id),
     IF (idx2 != 0)
      idx = idx2, temp->oclist[idx].synonym_id = ocs.synonym_id, temp->oclist[idx].catalog_cd = ocs
      .catalog_cd,
      temp->oclist[idx].catalog_type_cd = ocs.catalog_type_cd, temp->oclist[idx].activity_type_cd =
      ocs.activity_type_cd, temp->oclist[idx].mnemonic = trim(ocs.mnemonic),
      temp->oclist[idx].mnemonic_type_cd = ocs.mnemonic_type_cd, temp->oclist[idx].oe_format_id = ocs
      .oe_format_id, temp->oclist[idx].ocs_clin_cat_cd = ocs.dcp_clin_cat_cd,
      temp->oclist[idx].rx_mask = ocs.rx_mask, temp->oclist[idx].orderable_type_flag = ocs
      .orderable_type_flag, temp->oclist[idx].parent_active_ind = ocs.active_ind,
      temp->oclist[idx].facility_ind = facilityind, temp->oclist[idx].all_facility_access_ind =
      allfacilityind, temp->oclist[idx].hna_order_mnemonic = oc.primary_mnemonic,
      temp->oclist[idx].cki = oc.cki, temp->oclist[idx].ref_text_mask = ocs.ref_text_mask, temp->
      oclist[idx].high_alert_ind = ocs.high_alert_ind,
      temp->oclist[idx].high_alert_long_text_id = ocs.high_alert_long_text_id, temp->oclist[idx].
      high_alert_required_ntfy_ind = ocs.high_alert_required_ntfy_ind, temp->oclist[idx].schedule_ind
       = oc.schedule_ind,
      temp->oclist[idx].intermittent_ind = ocs.intermittent_ind
      IF (faccnt > 0)
       stat = alterlist(temp->oclist[idx].facilitylist,faccnt)
       FOR (i = 1 TO faccnt)
         temp->oclist[idx].facilitylist[i].facility_cd = temp->oclist[facidx].facilitylist[i].
         facility_cd
       ENDFOR
      ENDIF
      IF ((((temp->oclist[idx].orderable_type_flag=8)) OR ((temp->oclist[idx].orderable_type_flag=11)
      )) )
       ivcnt += 1, stat = alterlist(temp3->ivlist,ivcnt), temp3->ivlist[ivcnt].pathway_comp_id = temp
       ->oclist[idx].pathway_comp_id,
       temp3->ivlist[ivcnt].synonym_id = temp->oclist[idx].synonym_id, temp3->ivlist[ivcnt].
       catalog_cd = temp->oclist[idx].catalog_cd
      ENDIF
     ELSE
      idx = idx2
     ENDIF
    ENDWHILE
   FOOT REPORT
    idx = 0
   WITH nocounter, expand = 1
  ;end select
  SELECT INTO "nl:"
   FROM ref_text_facility_r rtfr,
    ref_text_version rtv
   PLAN (rtfr
    WHERE expand(num,1,high,rtfr.parent_entity_id,temp->oclist[num].catalog_cd)
     AND rtfr.parent_entity_name="ORDER_CATALOG"
     AND (((rtfr.facility_cd=request->facility_cd)) OR (rtfr.facility_cd=0.0)) )
    JOIN (rtv
    WHERE rtv.ref_text_variation_id=rtfr.ref_text_variation_id)
   HEAD REPORT
    idx = 0
   DETAIL
    idx = locateval(idx,1,high,rtfr.parent_entity_id,temp->oclist[idx].catalog_cd), temp->oclist[idx]
    .ref_text_ind = rtv.active_ind, temp->oclist[idx].reference_text_version_id = rtv
    .ref_text_version_id,
    idx2 = idx
    WHILE (idx != 0)
     idx2 = locateval(idx2,(idx+ 1),high,rtfr.parent_entity_id,temp->oclist[idx2].catalog_cd),
     IF (idx2 != 0)
      idx = idx2, temp->oclist[idx].ref_text_ind = rtv.active_ind, temp->oclist[idx].
      reference_text_version_id = rtv.ref_text_version_id
     ELSE
      idx = idx2
     ENDIF
    ENDWHILE
   FOOT REPORT
    idx = 0
   WITH nocounter, expand = 1
  ;end select
  IF (loadhighalerttextflag="Y")
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(num,1,high,lt.long_text_id,temp->oclist[num].high_alert_long_text_id)
      AND lt.active_ind=1)
    HEAD REPORT
     idx = 0
    DETAIL
     idx = locateval(idx,1,high,lt.long_text_id,temp->oclist[idx].high_alert_long_text_id), temp->
     oclist[idx].high_alert_text = trim(lt.long_text), idx2 = idx
     WHILE (idx != 0)
      idx2 = locateval(idx2,(idx+ 1),high,lt.long_text_id,temp->oclist[idx2].high_alert_long_text_id),
      IF (idx2 != 0)
       idx = idx2, temp->oclist[idx].high_alert_text = trim(lt.long_text)
      ELSE
       idx = idx2
      ENDIF
     ENDWHILE
    FOOT REPORT
     idx = 0
    WITH nocounter, expand = 1
   ;end select
  ENDIF
  IF (value(size(temp3->ivlist,5)) > 0)
   SET high = value(size(temp3->ivlist,5))
   SELECT INTO "nl:"
    FROM cs_component cc,
     order_catalog_synonym ocs
    PLAN (cc
     WHERE expand(num,1,high,cc.catalog_cd,temp3->ivlist[num].catalog_cd))
     JOIN (ocs
     WHERE ocs.synonym_id=cc.comp_id
      AND ocs.active_ind=1)
    ORDER BY cc.catalog_cd, cc.comp_seq
    HEAD REPORT
     idx = 0
    HEAD cc.catalog_cd
     ingredcnt = 0
    HEAD cc.comp_seq
     dummy = 0
    DETAIL
     ingredcnt += 1, idx = locateval(idx,1,high,cc.catalog_cd,temp3->ivlist[idx].catalog_cd), stat =
     alterlist(temp3->ivlist[idx].ingrdlist,ingredcnt),
     temp3->ivlist[idx].ingrdlist[ingredcnt].synonym_id = ocs.synonym_id, temp3->ivlist[idx].
     ingrdlist[ingredcnt].catalog_cd = ocs.catalog_cd, temp3->ivlist[idx].ingrdlist[ingredcnt].
     mnemonic = trim(ocs.mnemonic),
     temp3->ivlist[idx].ingrdlist[ingredcnt].oe_format_id = ocs.oe_format_id, temp3->ivlist[idx].
     ingrdlist[ingredcnt].catalog_cd = ocs.catalog_cd, temp3->ivlist[idx].ingrdlist[ingredcnt].
     comp_seq = cc.comp_seq,
     idx2 = idx
     WHILE (idx != 0)
      idx2 = locateval(idx2,(idx+ 1),high,cc.catalog_cd,temp3->ivlist[idx2].catalog_cd),
      IF (idx2 != 0)
       idx = idx2, stat = alterlist(temp3->ivlist[idx].ingrdlist,ingredcnt), temp3->ivlist[idx].
       ingrdlist[ingredcnt].synonym_id = ocs.synonym_id,
       temp3->ivlist[idx].ingrdlist[ingredcnt].catalog_cd = ocs.catalog_cd, temp3->ivlist[idx].
       ingrdlist[ingredcnt].mnemonic = trim(ocs.mnemonic), temp3->ivlist[idx].ingrdlist[ingredcnt].
       oe_format_id = ocs.oe_format_id,
       temp3->ivlist[idx].ingrdlist[ingredcnt].catalog_cd = ocs.catalog_cd, temp3->ivlist[idx].
       ingrdlist[ingredcnt].comp_seq = cc.comp_seq
      ELSE
       idx = idx2
      ENDIF
     ENDWHILE
    FOOT  cc.catalog_cd
     ingredcnt = ingredcnt
    FOOT REPORT
     idx = 0
    WITH nocounter, expand = 1
   ;end select
   SET ivcnt = value(size(temp3->ivlist,5))
   SET high = value(size(temp->oclist,5))
   FOR (i = 1 TO ivcnt)
     SET num = 0
     SET idx = 0
     SET ingredcnt = value(size(temp3->ivlist[i].ingrdlist,5))
     SET idx = locateval(num,1,high,temp3->ivlist[i].pathway_comp_id,temp->oclist[num].
      pathway_comp_id)
     SET stat = alterlist(temp->oclist[idx].ingredientlist,ingredcnt)
     FOR (j = 1 TO ingredcnt)
       SET temp->oclist[idx].ingredientlist[j].synonym_id = temp3->ivlist[i].ingrdlist[j].synonym_id
       SET temp->oclist[idx].ingredientlist[j].mnemonic = trim(temp3->ivlist[i].ingrdlist[j].mnemonic
        )
       SET temp->oclist[idx].ingredientlist[j].oe_format_id = temp3->ivlist[i].ingrdlist[j].
       oe_format_id
       SET temp->oclist[idx].ingredientlist[j].catalog_cd = temp3->ivlist[i].ingrdlist[j].catalog_cd
       SET temp->oclist[idx].ingredientlist[j].comp_seq = temp3->ivlist[i].ingrdlist[j].comp_seq
     ENDFOR
   ENDFOR
   FREE RECORD temp3
  ENDIF
  SELECT INTO "nl:"
   FROM pw_comp_os_reltn pcor,
    order_sentence os,
    long_text lt,
    (dummyt d  WITH seq = 1)
   PLAN (pcor
    WHERE expand(num,1,high,pcor.pathway_comp_id,temp->oclist[num].pathway_comp_id))
    JOIN (os
    WHERE os.order_sentence_id=pcor.order_sentence_id)
    JOIN (d)
    JOIN (lt
    WHERE lt.long_text_id=os.ord_comment_long_text_id
     AND lt.active_ind=1)
   ORDER BY pcor.pathway_comp_id, pcor.order_sentence_seq
   HEAD REPORT
    idx = 0
   HEAD pcor.pathway_comp_id
    osrcnt = 0, idx = locateval(idx,1,high,pcor.pathway_comp_id,temp->oclist[idx].pathway_comp_id)
   DETAIL
    osrcnt += 1
    IF (osrcnt > size(temp->oclist[idx].ordsentlist,5))
     stat = alterlist(temp->oclist[idx].ordsentlist,(osrcnt+ 5))
    ENDIF
    temp->oclist[idx].ordsentlist[osrcnt].order_sentence_id = pcor.order_sentence_id, temp->oclist[
    idx].ordsentlist[osrcnt].order_sentence_seq = pcor.order_sentence_seq, temp->oclist[idx].
    ordsentlist[osrcnt].iv_comp_syn_id = pcor.iv_comp_syn_id,
    temp->oclist[idx].ordsentlist[osrcnt].normalized_dose_unit_ind = pcor.normalized_dose_unit_ind,
    temp->oclist[idx].ordsentlist[osrcnt].missing_required_ind = pcor.missing_required_ind
    IF (pcor.os_display_line != null
     AND pcor.os_display_line != "")
     temp->oclist[idx].ordsentlist[osrcnt].order_sentence_display_line = trim(pcor.os_display_line)
    ELSE
     temp->oclist[idx].ordsentlist[osrcnt].order_sentence_display_line = trim(os
      .order_sentence_display_line)
    ENDIF
    IF (os.ord_comment_long_text_id > 0)
     temp->oclist[idx].ordsentlist[osrcnt].ord_comment_long_text_id = os.ord_comment_long_text_id,
     temp->oclist[idx].ordsentlist[osrcnt].ord_comment_long_text = trim(lt.long_text)
    ENDIF
    temp->oclist[idx].ordsentlist[osrcnt].rx_type_mean = os.rx_type_mean
   FOOT  pcor.pathway_comp_id
    IF (osrcnt > 0)
     stat = alterlist(temp->oclist[idx].ordsentlist,osrcnt)
    ENDIF
   FOOT REPORT
    idx = 0
   WITH nocounter, outerjoin = d, expand = 1
  ;end select
 ENDIF
 IF (value(size(temp->outcomelist,5)) > 0)
  SET high = value(size(temp->outcomelist,5))
  SELECT INTO "nl:"
   FROM outcome_catalog oc,
    outcome_cat_loc_reltn oclr
   PLAN (oc
    WHERE expand(num,1,high,oc.outcome_catalog_id,temp->outcomelist[num].parent_entity_id))
    JOIN (oclr
    WHERE oclr.outcome_catalog_id IN (oc.outcome_catalog_id, 0))
   ORDER BY oc.outcome_catalog_id, oclr.outcome_catalog_id DESC, oclr.location_cd DESC
   HEAD REPORT
    idx = 0
   HEAD oc.outcome_catalog_id
    facilityind = 0, allfacilityind = 0, oclrcnt = 0,
    faccnt = 0, idx = locateval(idx,1,high,oc.outcome_catalog_id,temp->outcomelist[idx].
     parent_entity_id), temp->outcomelist[idx].outcome_description = oc.description,
    temp->outcomelist[idx].outcome_expectation = oc.expectation, temp->outcomelist[idx].
    outcome_type_cd = oc.outcome_type_cd, temp->outcomelist[idx].parent_active_ind = oc.active_ind,
    temp->outcomelist[idx].single_select_ind = oc.single_select_ind, temp->outcomelist[idx].
    hide_expectation_ind = oc.hide_expectation_ind, temp->outcomelist[idx].ref_text_reltn_id = oc
    .ref_text_reltn_id
   DETAIL
    oclrcnt += 1
    IF (filterorc=1
     AND facilityind=0)
     IF (facilitycd=0)
      facilityind = 1, allfacilityind = 1
     ELSEIF (oclr.location_cd=0
      AND oclr.outcome_catalog_id > 0)
      facilityind = 0, allfacilityind = 0
     ELSEIF (oclr.location_cd=0
      AND oclr.outcome_catalog_id=0
      AND oclrcnt=1)
      facilityind = 1, allfacilityind = 1
     ELSEIF (oclr.location_cd > 0
      AND oclr.location_cd=facilitycd)
      facilityind = 1, allfacilityind = 0
     ENDIF
    ELSEIF (filterorc=0)
     IF (oclr.location_cd=0
      AND oclr.outcome_catalog_id > 0)
      facilityind = 0, allfacilityind = 0
     ELSEIF (oclr.location_cd=0
      AND oclr.outcome_catalog_id=0
      AND oclrcnt=1)
      facilityind = 1, allfacilityind = 1
     ELSEIF (oclr.location_cd > 0)
      faccnt += 1, stat = alterlist(temp->outcomelist[idx].facilitylist,faccnt), temp->outcomelist[
      idx].facilitylist[faccnt].facility_cd = oclr.location_cd
     ENDIF
    ELSEIF ((filterorc=- (1)))
     facilityind = 1
    ENDIF
   FOOT  oc.outcome_catalog_id
    temp->outcomelist[idx].facility_ind = facilityind, temp->outcomelist[idx].all_facility_access_ind
     = allfacilityind, facidx = idx,
    idx2 = idx
    WHILE (idx != 0)
     idx2 = locateval(idx2,(idx+ 1),high,oc.outcome_catalog_id,temp->outcomelist[idx2].
      parent_entity_id),
     IF (idx2 != 0)
      idx = idx2, temp->outcomelist[idx].outcome_description = oc.description, temp->outcomelist[idx]
      .outcome_expectation = oc.expectation,
      temp->outcomelist[idx].outcome_type_cd = oc.outcome_type_cd, temp->outcomelist[idx].
      parent_active_ind = oc.active_ind, temp->outcomelist[idx].single_select_ind = oc
      .single_select_ind,
      temp->outcomelist[idx].hide_expectation_ind = oc.hide_expectation_ind, temp->outcomelist[idx].
      ref_text_reltn_id = oc.ref_text_reltn_id, temp->outcomelist[idx].facility_ind = facilityind,
      temp->outcomelist[idx].all_facility_access_ind = allfacilityind
      IF (faccnt > 0)
       stat = alterlist(temp->outcomelist[idx].facilitylist,faccnt)
       FOR (i = 1 TO faccnt)
         temp->outcomelist[idx].facilitylist[i].facility_cd = temp->outcomelist[facidx].facilitylist[
         i].facility_cd
       ENDFOR
      ENDIF
     ELSE
      idx = idx2
     ENDIF
    ENDWHILE
   FOOT REPORT
    idx = 0
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (value(size(temp->splist,5)) > 0)
  SET high = value(size(temp->splist,5))
  SELECT INTO "nl:"
   pwc.display_description, pwc.description
   FROM pathway_catalog pwc,
    pw_cat_flex pcf
   PLAN (pwc
    WHERE expand(num,1,high,pwc.pathway_catalog_id,temp->splist[num].parent_entity_id))
    JOIN (pcf
    WHERE (pcf.pathway_catalog_id= Outerjoin(pwc.pathway_catalog_id))
     AND (pcf.parent_entity_name= Outerjoin("CODE_VALUE"))
     AND (pcf.parent_entity_id!= Outerjoin(0)) )
   ORDER BY pwc.pathway_catalog_id
   HEAD REPORT
    idx = 0
   HEAD pwc.pathway_catalog_id
    facilitycnt = 0, facilityind = 0, allfacilityind = 0,
    idx = locateval(idx,1,high,pwc.pathway_catalog_id,temp->splist[idx].parent_entity_id), temp->
    splist[idx].parent_phase_desc = pwc.description, temp->splist[idx].parent_phase_display_desc =
    pwc.display_description
    IF (pwc.active_ind=1
     AND pwc.sub_phase_ind=1)
     temp->splist[idx].parent_active_ind = 1
    ENDIF
   DETAIL
    IF (pcf.parent_entity_id=0)
     facilityind = 1, allfacilityind = 1
    ELSEIF (((pcf.parent_entity_id > 0
     AND pcf.parent_entity_id=facilitycd) OR (filterorc < 1)) )
     facilityind = 1
    ENDIF
    IF (pcf.parent_entity_id > 0)
     facilitycnt += 1, stat = alterlist(temp->splist[idx].facilitylist,facilitycnt), temp->splist[idx
     ].facilitylist[facilitycnt].facility_cd = pcf.parent_entity_id
    ENDIF
   FOOT  pwc.pathway_catalog_id
    temp->splist[idx].all_facility_access_ind = allfacilityind, temp->splist[idx].facility_ind =
    facilityind, facidx = idx,
    idx2 = idx
    WHILE (idx != 0)
     idx2 = locateval(idx2,(idx+ 1),high,pwc.pathway_catalog_id,temp->splist[idx2].parent_entity_id),
     IF (idx2 != 0)
      idx = idx2, temp->splist[idx].parent_phase_desc = pwc.description, temp->splist[idx].
      parent_phase_display_desc = pwc.display_description
      IF (pwc.active_ind=1
       AND pwc.sub_phase_ind=1)
       temp->splist[idx].parent_active_ind = 1
      ENDIF
      temp->splist[idx].all_facility_access_ind = allfacilityind, temp->splist[idx].facility_ind =
      facilityind
      IF (facilitycnt > 0)
       stat = alterlist(temp->splist[idx].facilitylist,facilitycnt)
       FOR (i = 1 TO facilitycnt)
         temp->splist[idx].facilitylist[i].facility_cd = temp->splist[facidx].facilitylist[i].
         facility_cd
       ENDFOR
      ENDIF
     ELSE
      idx = idx2
     ENDIF
    ENDWHILE
   FOOT REPORT
    idx = 0
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 SET high = value(size(reply->qual_phase,5))
 SELECT INTO "nl:"
  FROM pw_comp_group pcg
  PLAN (pcg
   WHERE expand(num,1,high,pcg.pathway_catalog_id,reply->qual_phase[num].pathway_catalog_id))
  ORDER BY pcg.pathway_catalog_id, pcg.pw_comp_group_id, pcg.comp_seq
  HEAD REPORT
   pcnt = 0
  HEAD pcg.pathway_catalog_id
   pcnt += 1
   IF (pcnt > size(temp4->phaselist,5))
    stat = alterlist(temp4->phaselist,(pcnt+ 10))
   ENDIF
   temp4->phaselist[pcnt].pathway_catalog_id = pcg.pathway_catalog_id, gcnt = 0
  HEAD pcg.pw_comp_group_id
   gcnt += 1
   IF (gcnt > size(temp4->phaselist[pcnt].compglist,5))
    stat = alterlist(temp4->phaselist[pcnt].compglist,(gcnt+ 10))
   ENDIF
   temp4->phaselist[pcnt].compglist[gcnt].pw_comp_group_id = pcg.pw_comp_group_id, temp4->phaselist[
   pcnt].compglist[gcnt].type_mean = pcg.type_mean, temp4->phaselist[pcnt].compglist[gcnt].
   description = trim(pcg.description),
   temp4->phaselist[pcnt].compglist[gcnt].linking_rule_flag = pcg.linking_rule_flag, temp4->
   phaselist[pcnt].compglist[gcnt].linking_rule_quantity = pcg.linking_rule_quantity, temp4->
   phaselist[pcnt].compglist[gcnt].override_reason_flag = pcg.override_reason_flag,
   ccnt = 0
  DETAIL
   ccnt += 1
   IF (ccnt > size(temp4->phaselist[pcnt].compglist[gcnt].memberlist,5))
    stat = alterlist(temp4->phaselist[pcnt].compglist[gcnt].memberlist,(ccnt+ 10))
   ENDIF
   temp4->phaselist[pcnt].compglist[gcnt].memberlist[ccnt].pathway_comp_id = pcg.pathway_comp_id,
   temp4->phaselist[pcnt].compglist[gcnt].memberlist[ccnt].comp_seq = pcg.comp_seq, temp4->phaselist[
   pcnt].compglist[gcnt].memberlist[ccnt].anchor_component_ind = pcg.anchor_component_ind
  FOOT  pcg.pw_comp_group_id
   IF (ccnt > 0)
    stat = alterlist(temp4->phaselist[pcnt].compglist[gcnt].memberlist,ccnt)
   ENDIF
  FOOT  pcg.pathway_catalog_id
   IF (gcnt > 0)
    stat = alterlist(temp4->phaselist[pcnt].compglist,gcnt)
   ENDIF
  FOOT REPORT
   IF (pcnt > 0)
    stat = alterlist(temp4->phaselist,pcnt)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SET occnt = value(size(temp->oclist,5))
 SET ltcnt = value(size(temp->ltlist,5))
 SET otcnt = value(size(temp->outcomelist,5))
 SET spcnt = value(size(temp->splist,5))
 IF (((occnt > 0) OR (((ltcnt > 0) OR (((otcnt > 0) OR (spcnt > 0)) )) )) )
  FREE RECORD subphaseparents
  RECORD subphaseparents(
    1 sub_phases[*]
      2 sub_phase_catalog_id = f8
      2 used_count = i4
  )
  DECLARE subphaseindex = i4 WITH protect, noconstant(0)
  DECLARE subphaseusedcount = i4 WITH protect, noconstant(0)
  DECLARE subphasesearchindex = i4 WITH protect, noconstant(0)
  DECLARE subphaseparentindex = i4 WITH protect, noconstant(0)
  DECLARE subphasereplyindex = i4 WITH protect, noconstant(0)
  DECLARE subphaseparentssize = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   phase_idx = d1.seq, sort_cd = decode(d2.seq,temp->oclist[d2.seq].sort_cd,d3.seq,temp->ltlist[d3
    .seq].sort_cd,d4.seq,
    temp->outcomelist[d4.seq].sort_cd,d5.seq,temp->splist[d5.seq].sort_cd,0.0), comp_seq = decode(d2
    .seq,temp->oclist[d2.seq].sequence,d3.seq,temp->ltlist[d3.seq].sequence,d4.seq,
    temp->outcomelist[d4.seq].sequence,d5.seq,temp->splist[d5.seq].sequence,0),
   check = decode(d2.seq,"oc",d3.seq,"lt",d4.seq,
    "ot",d5.seq,"sp","zz")
   FROM (dummyt d1  WITH seq = value(size(reply->qual_phase,5))),
    (dummyt d2  WITH seq = value(size(temp->oclist,5))),
    (dummyt d3  WITH seq = value(size(temp->ltlist,5))),
    (dummyt d4  WITH seq = value(size(temp->outcomelist,5))),
    (dummyt d5  WITH seq = value(size(temp->splist,5)))
   PLAN (d1)
    JOIN (((d2
    WHERE (temp->oclist[d2.seq].pathway_catalog_id=reply->qual_phase[d1.seq].pathway_catalog_id))
    ) ORJOIN ((((d3
    WHERE (temp->ltlist[d3.seq].pathway_catalog_id=reply->qual_phase[d1.seq].pathway_catalog_id))
    ) ORJOIN ((((d4
    WHERE (temp->outcomelist[d4.seq].pathway_catalog_id=reply->qual_phase[d1.seq].pathway_catalog_id)
    )
    ) ORJOIN ((d5
    WHERE (temp->splist[d5.seq].pathway_catalog_id=reply->qual_phase[d1.seq].pathway_catalog_id))
    )) )) ))
   ORDER BY phase_idx, sort_cd, comp_seq
   HEAD REPORT
    compcnt = 0, subphaseindex = 0, subphaseusedcount = 0,
    subphasesearchindex = 0, subphaseparentindex = 0, subphasereplyindex = 0,
    subphaseparentssize = 0, orders_size = 0
   HEAD phase_idx
    compcnt = 0, subphaseindex = 0, subphaseusedcount = 0,
    subphasesearchindex = 0, subphaseparentindex = 0, subphasereplyindex = 0
   HEAD sort_cd
    compcnt = compcnt, subphaseindex = 0, subphaseusedcount = 0,
    subphasesearchindex = 0, subphaseparentindex = 0, subphasereplyindex = 0
   HEAD comp_seq
    subphaseindex = 0, subphaseusedcount = 0, subphasesearchindex = 0,
    subphaseparentindex = 0, subphasereplyindex = 0
    IF (check != "zz")
     IF (check="oc")
      IF (((filterorc <= 0) OR ((((reply->qual_phase[d1.seq].hide_flexed_comp_ind=0)) OR (filterorc=1
       AND (temp->oclist[d2.seq].facility_ind=1))) )) )
       compcnt += 1
       IF (compcnt > size(reply->qual_phase[d1.seq].qual_component,5))
        stat = alterlist(reply->qual_phase[d1.seq].qual_component,(compcnt+ 10))
       ENDIF
       reply->qual_phase[d1.seq].qual_component[compcnt].uuid = trim(temp->oclist[d2.seq].uuid),
       reply->qual_phase[d1.seq].qual_component[compcnt].pathway_comp_id = temp->oclist[d2.seq].
       pathway_comp_id, reply->qual_phase[d1.seq].qual_component[compcnt].dcp_clin_cat_cd = temp->
       oclist[d2.seq].dcp_clin_cat_cd,
       reply->qual_phase[d1.seq].qual_component[compcnt].dcp_clin_sub_cat_cd = temp->oclist[d2.seq].
       dcp_clin_sub_cat_cd, reply->qual_phase[d1.seq].qual_component[compcnt].sequence = temp->
       oclist[d2.seq].sequence, reply->qual_phase[d1.seq].qual_component[compcnt].comp_type_cd = temp
       ->oclist[d2.seq].comp_type_cd,
       reply->qual_phase[d1.seq].qual_component[compcnt].parent_entity_name = temp->oclist[d2.seq].
       parent_entity_name, reply->qual_phase[d1.seq].qual_component[compcnt].parent_entity_id = temp
       ->oclist[d2.seq].parent_entity_id, reply->qual_phase[d1.seq].qual_component[compcnt].
       required_ind = temp->oclist[d2.seq].required_ind,
       reply->qual_phase[d1.seq].qual_component[compcnt].included_ind = temp->oclist[d2.seq].
       included_ind, reply->qual_phase[d1.seq].qual_component[compcnt].linked_to_tf_ind = temp->
       oclist[d2.seq].linked_to_tf_ind, reply->qual_phase[d1.seq].qual_component[compcnt].
       comp_updt_cnt = temp->oclist[d2.seq].comp_updt_cnt,
       reply->qual_phase[d1.seq].qual_component[compcnt].synonym_id = temp->oclist[d2.seq].synonym_id,
       reply->qual_phase[d1.seq].qual_component[compcnt].catalog_cd = temp->oclist[d2.seq].catalog_cd,
       reply->qual_phase[d1.seq].qual_component[compcnt].catalog_type_cd = temp->oclist[d2.seq].
       catalog_type_cd,
       reply->qual_phase[d1.seq].qual_component[compcnt].activity_type_cd = temp->oclist[d2.seq].
       activity_type_cd, reply->qual_phase[d1.seq].qual_component[compcnt].mnemonic = temp->oclist[d2
       .seq].mnemonic, reply->qual_phase[d1.seq].qual_component[compcnt].mnemonic_type_cd = temp->
       oclist[d2.seq].mnemonic_type_cd,
       reply->qual_phase[d1.seq].qual_component[compcnt].oe_format_id = temp->oclist[d2.seq].
       oe_format_id, reply->qual_phase[d1.seq].qual_component[compcnt].ocs_clin_cat_cd = temp->
       oclist[d2.seq].ocs_clin_cat_cd, reply->qual_phase[d1.seq].qual_component[compcnt].rx_mask =
       temp->oclist[d2.seq].rx_mask,
       reply->qual_phase[d1.seq].qual_component[compcnt].orderable_type_flag = temp->oclist[d2.seq].
       orderable_type_flag, reply->qual_phase[d1.seq].qual_component[compcnt].comp_label = temp->
       oclist[d2.seq].comp_label, reply->qual_phase[d1.seq].qual_component[compcnt].offset_quantity
        = temp->oclist[d2.seq].offset_quantity,
       reply->qual_phase[d1.seq].qual_component[compcnt].hna_order_mnemonic = temp->oclist[d2.seq].
       hna_order_mnemonic, reply->qual_phase[d1.seq].qual_component[compcnt].cki = temp->oclist[d2
       .seq].cki, reply->qual_phase[d1.seq].qual_component[compcnt].ref_text_ind = temp->oclist[d2
       .seq].ref_text_ind
       IF (validate(reply->qual_phase[1].qual_component[1].reference_text_version_id)=1)
        reply->qual_phase[d1.seq].qual_component[compcnt].reference_text_version_id = temp->oclist[d2
        .seq].reference_text_version_id
       ENDIF
       reply->qual_phase[d1.seq].qual_component[compcnt].ref_text_mask = temp->oclist[d2.seq].
       ref_text_mask, reply->qual_phase[d1.seq].qual_component[compcnt].offset_unit_cd = temp->
       oclist[d2.seq].offset_unit_cd, reply->qual_phase[d1.seq].qual_component[compcnt].
       parent_active_ind = temp->oclist[d2.seq].parent_active_ind,
       reply->qual_phase[d1.seq].qual_component[compcnt].facility_ind = temp->oclist[d2.seq].
       facility_ind, reply->qual_phase[d1.seq].qual_component[compcnt].all_facility_access_ind = temp
       ->oclist[d2.seq].all_facility_access_ind, reply->qual_phase[d1.seq].qual_component[compcnt].
       cross_phase_group_desc = temp->oclist[d2.seq].cross_phase_group_desc,
       reply->qual_phase[d1.seq].qual_component[compcnt].cross_phase_group_nbr = temp->oclist[d2.seq]
       .cross_phase_group_nbr, reply->qual_phase[d1.seq].qual_component[compcnt].chemo_ind = temp->
       oclist[d2.seq].chemo_ind, reply->qual_phase[d1.seq].qual_component[compcnt].chemo_related_ind
        = temp->oclist[d2.seq].chemo_related_ind,
       reply->qual_phase[d1.seq].qual_component[compcnt].high_alert_ind = temp->oclist[d2.seq].
       high_alert_ind, reply->qual_phase[d1.seq].qual_component[compcnt].high_alert_required_ntfy_ind
        = temp->oclist[d2.seq].high_alert_required_ntfy_ind, reply->qual_phase[d1.seq].
       qual_component[compcnt].high_alert_text = trim(temp->oclist[d2.seq].high_alert_text),
       reply->qual_phase[d1.seq].qual_component[compcnt].default_os_ind = temp->oclist[d2.seq].
       default_os_ind, reply->qual_phase[d1.seq].qual_component[compcnt].schedule_ind = temp->oclist[
       d2.seq].schedule_ind, reply->qual_phase[d1.seq].qual_component[compcnt].intermittent_ind =
       temp->oclist[d2.seq].intermittent_ind,
       reply->qual_phase[d1.seq].qual_component[compcnt].min_tolerance_interval = temp->oclist[d2.seq
       ].min_tolerance_interval, reply->qual_phase[d1.seq].qual_component[compcnt].
       min_tolerance_interval_unit_cd = temp->oclist[d2.seq].min_tolerance_interval_unit_cd, reply->
       qual_phase[d1.seq].qual_component[compcnt].display_format_xml = temp->oclist[d2.seq].
       display_format_xml,
       reply->qual_phase[d1.seq].qual_component[compcnt].lock_target_dose_flag = temp->oclist[d2.seq]
       .lock_target_dose_flag
       IF ((reply->qual_phase[d1.seq].start_offset_ind=0)
        AND (reply->qual_phase[d1.seq].qual_component[compcnt].offset_quantity > 0))
        reply->qual_phase[d1.seq].start_offset_ind = 1
       ENDIF
       IF ((reply->qual_phase[d1.seq].chemo_ind=0)
        AND (reply->qual_phase[d1.seq].qual_component[compcnt].chemo_ind > 0))
        reply->qual_phase[d1.seq].chemo_ind = 1
       ENDIF
       IF ((reply->chemo_ind=0)
        AND (reply->qual_phase[d1.seq].qual_component[compcnt].chemo_ind > 0))
        reply->chemo_ind = 1
       ENDIF
       IF ((reply->qual_phase[d1.seq].chemo_related_ind=0)
        AND (reply->qual_phase[d1.seq].qual_component[compcnt].chemo_related_ind > 0))
        reply->qual_phase[d1.seq].chemo_related_ind = 1
       ENDIF
       IF ((reply->chemo_related_ind=0)
        AND (reply->qual_phase[d1.seq].qual_component[compcnt].chemo_related_ind > 0))
        reply->chemo_related_ind = 1
       ENDIF
       IF ((reply->qual_phase[d1.seq].high_alert_ind=0)
        AND (reply->qual_phase[d1.seq].qual_component[compcnt].high_alert_ind > 0))
        reply->qual_phase[d1.seq].high_alert_ind = 1
       ENDIF
       IF ((reply->qual_phase[d1.seq].high_alert_required_ntfy_ind=0)
        AND (reply->qual_phase[d1.seq].qual_component[compcnt].high_alert_required_ntfy_ind > 0))
        reply->qual_phase[d1.seq].high_alert_required_ntfy_ind = 1
       ENDIF
       count = size(temp->oclist[d2.seq].facilitylist,5)
       IF (count > 0)
        stat = alterlist(reply->qual_phase[d1.seq].qual_component[compcnt].facilitylist,count)
        FOR (j = 1 TO count)
          reply->qual_phase[d1.seq].qual_component[compcnt].facilitylist[j].facility_cd = temp->
          oclist[d2.seq].facilitylist[j].facility_cd
        ENDFOR
       ENDIF
       count = size(temp->oclist[d2.seq].ordsentlist,5)
       IF (count > 0)
        stat = alterlist(reply->qual_phase[d1.seq].qual_component[compcnt].qual_order_sentence,count),
        orders_size = size(filter_order_sentences->orders,5), orders_size += 1,
        stat = alterlist(filter_order_sentences->orders,orders_size), stat = alterlist(
         filter_order_sentences->orders[orders_size].order_sentences,count), filter_order_sentences->
        orders[orders_size].unique_identifier = reply->qual_phase[d1.seq].qual_component[compcnt].
        pathway_comp_id,
        filter_order_sentences->orders[orders_size].component_index = compcnt, filter_order_sentences
        ->orders[orders_size].reply_phase_index = d1.seq
        FOR (ordersentenceindex = 1 TO count)
          reply->qual_phase[d1.seq].qual_component[compcnt].qual_order_sentence[ordersentenceindex].
          sequence = temp->oclist[d2.seq].ordsentlist[ordersentenceindex].order_sentence_seq, reply->
          qual_phase[d1.seq].qual_component[compcnt].qual_order_sentence[ordersentenceindex].
          order_sentence_id = temp->oclist[d2.seq].ordsentlist[ordersentenceindex].order_sentence_id,
          reply->qual_phase[d1.seq].qual_component[compcnt].qual_order_sentence[ordersentenceindex].
          order_sentence_display_line = trim(temp->oclist[d2.seq].ordsentlist[ordersentenceindex].
           order_sentence_display_line),
          reply->qual_phase[d1.seq].qual_component[compcnt].qual_order_sentence[ordersentenceindex].
          iv_comp_syn_id = temp->oclist[d2.seq].ordsentlist[ordersentenceindex].iv_comp_syn_id, reply
          ->qual_phase[d1.seq].qual_component[compcnt].qual_order_sentence[ordersentenceindex].
          ord_comment_long_text_id = temp->oclist[d2.seq].ordsentlist[ordersentenceindex].
          ord_comment_long_text_id, reply->qual_phase[d1.seq].qual_component[compcnt].
          qual_order_sentence[ordersentenceindex].ord_comment_long_text = temp->oclist[d2.seq].
          ordsentlist[ordersentenceindex].ord_comment_long_text,
          reply->qual_phase[d1.seq].qual_component[compcnt].qual_order_sentence[ordersentenceindex].
          rx_type_mean = temp->oclist[d2.seq].ordsentlist[ordersentenceindex].rx_type_mean, reply->
          qual_phase[d1.seq].qual_component[compcnt].qual_order_sentence[ordersentenceindex].
          normalized_dose_unit_ind = temp->oclist[d2.seq].ordsentlist[ordersentenceindex].
          normalized_dose_unit_ind, reply->qual_phase[d1.seq].qual_component[compcnt].
          qual_order_sentence[ordersentenceindex].missing_required_ind = temp->oclist[d2.seq].
          ordsentlist[ordersentenceindex].missing_required_ind,
          reply->qual_phase[d1.seq].qual_component[compcnt].qual_order_sentence[ordersentenceindex].
          applicable_to_patient_ind = 1, filter_order_sentences->orders[orders_size].order_sentences[
          ordersentenceindex].order_sentence_id = reply->qual_phase[d1.seq].qual_component[compcnt].
          qual_order_sentence[ordersentenceindex].order_sentence_id, filter_order_sentences->orders[
          orders_size].order_sentences[ordersentenceindex].applicable_to_patient_ind = 1
        ENDFOR
       ENDIF
       count = size(temp->oclist[d2.seq].ingredientlist,5)
       IF (count > 0)
        stat = alterlist(reply->qual_phase[d1.seq].qual_component[compcnt].iv_ingredient,count)
        FOR (j = 1 TO count)
          reply->qual_phase[d1.seq].qual_component[compcnt].iv_ingredient[j].synonym_id = temp->
          oclist[d2.seq].ingredientlist[j].synonym_id, reply->qual_phase[d1.seq].qual_component[
          compcnt].iv_ingredient[j].mnemonic = trim(temp->oclist[d2.seq].ingredientlist[j].mnemonic),
          reply->qual_phase[d1.seq].qual_component[compcnt].iv_ingredient[j].oe_format_id = temp->
          oclist[d2.seq].ingredientlist[j].oe_format_id,
          reply->qual_phase[d1.seq].qual_component[compcnt].iv_ingredient[j].catalog_cd = temp->
          oclist[d2.seq].ingredientlist[j].catalog_cd, reply->qual_phase[d1.seq].qual_component[
          compcnt].iv_ingredient[j].comp_seq = temp->oclist[d2.seq].ingredientlist[j].comp_seq
        ENDFOR
       ENDIF
       reply->qual_phase[d1.seq].qual_component[compcnt].time_zero_mean = "NONE"
      ENDIF
     ELSEIF (check="lt")
      compcnt += 1
      IF (compcnt > size(reply->qual_phase[d1.seq].qual_component,5))
       stat = alterlist(reply->qual_phase[d1.seq].qual_component,(compcnt+ 10))
      ENDIF
      reply->qual_phase[d1.seq].qual_component[compcnt].uuid = trim(temp->ltlist[d3.seq].uuid), reply
      ->qual_phase[d1.seq].qual_component[compcnt].pathway_comp_id = temp->ltlist[d3.seq].
      pathway_comp_id, reply->qual_phase[d1.seq].qual_component[compcnt].dcp_clin_cat_cd = temp->
      ltlist[d3.seq].dcp_clin_cat_cd,
      reply->qual_phase[d1.seq].qual_component[compcnt].dcp_clin_sub_cat_cd = temp->ltlist[d3.seq].
      dcp_clin_sub_cat_cd, reply->qual_phase[d1.seq].qual_component[compcnt].sequence = temp->ltlist[
      d3.seq].sequence, reply->qual_phase[d1.seq].qual_component[compcnt].comp_type_cd = temp->
      ltlist[d3.seq].comp_type_cd,
      reply->qual_phase[d1.seq].qual_component[compcnt].parent_entity_name = temp->ltlist[d3.seq].
      parent_entity_name, reply->qual_phase[d1.seq].qual_component[compcnt].parent_entity_id = temp->
      ltlist[d3.seq].parent_entity_id, reply->qual_phase[d1.seq].qual_component[compcnt].
      persistent_ind = temp->ltlist[d3.seq].persistent_ind,
      reply->qual_phase[d1.seq].qual_component[compcnt].comp_updt_cnt = temp->ltlist[d3.seq].
      comp_updt_cnt, reply->qual_phase[d1.seq].qual_component[compcnt].comp_text_id = temp->ltlist[d3
      .seq].comp_text_id, reply->qual_phase[d1.seq].qual_component[compcnt].comp_text = temp->ltlist[
      d3.seq].comp_text,
      reply->qual_phase[d1.seq].qual_component[compcnt].comp_text_updt_cnt = temp->ltlist[d3.seq].
      comp_text_updt_cnt, reply->qual_phase[d1.seq].qual_component[compcnt].comp_label = temp->
      ltlist[d3.seq].comp_label, reply->qual_phase[d1.seq].qual_component[compcnt].parent_active_ind
       = 1,
      reply->qual_phase[d1.seq].qual_component[compcnt].facility_ind = 1, reply->qual_phase[d1.seq].
      qual_component[compcnt].all_facility_access_ind = 1, reply->qual_phase[d1.seq].qual_component[
      compcnt].time_zero_mean = "NONE",
      reply->qual_phase[d1.seq].qual_component[compcnt].chemo_related_ind = temp->ltlist[d3.seq].
      chemo_related_ind, reply->qual_phase[d1.seq].qual_component[compcnt].display_format_xml = temp
      ->ltlist[d3.seq].display_format_xml
      IF ((reply->qual_phase[d1.seq].chemo_related_ind=0)
       AND (reply->qual_phase[d1.seq].qual_component[compcnt].chemo_related_ind > 0))
       reply->qual_phase[d1.seq].chemo_related_ind = 1
      ENDIF
      IF ((reply->chemo_related_ind=0)
       AND (reply->qual_phase[d1.seq].qual_component[compcnt].chemo_related_ind > 0))
       reply->chemo_related_ind = 1
      ENDIF
     ELSEIF (check="ot")
      compcnt += 1
      IF (compcnt > size(reply->qual_phase[d1.seq].qual_component,5))
       stat = alterlist(reply->qual_phase[d1.seq].qual_component,(compcnt+ 10))
      ENDIF
      reply->qual_phase[d1.seq].qual_component[compcnt].uuid = trim(temp->outcomelist[d4.seq].uuid),
      reply->qual_phase[d1.seq].qual_component[compcnt].pathway_comp_id = temp->outcomelist[d4.seq].
      pathway_comp_id, reply->qual_phase[d1.seq].qual_component[compcnt].dcp_clin_cat_cd = temp->
      outcomelist[d4.seq].dcp_clin_cat_cd,
      reply->qual_phase[d1.seq].qual_component[compcnt].dcp_clin_sub_cat_cd = temp->outcomelist[d4
      .seq].dcp_clin_sub_cat_cd, reply->qual_phase[d1.seq].qual_component[compcnt].sequence = temp->
      outcomelist[d4.seq].sequence, reply->qual_phase[d1.seq].qual_component[compcnt].comp_type_cd =
      temp->outcomelist[d4.seq].comp_type_cd,
      reply->qual_phase[d1.seq].qual_component[compcnt].parent_entity_name = temp->outcomelist[d4.seq
      ].parent_entity_name, reply->qual_phase[d1.seq].qual_component[compcnt].parent_entity_id = temp
      ->outcomelist[d4.seq].parent_entity_id, reply->qual_phase[d1.seq].qual_component[compcnt].
      required_ind = temp->outcomelist[d4.seq].required_ind,
      reply->qual_phase[d1.seq].qual_component[compcnt].included_ind = temp->outcomelist[d4.seq].
      included_ind, reply->qual_phase[d1.seq].qual_component[compcnt].linked_to_tf_ind = temp->
      outcomelist[d4.seq].linked_to_tf_ind, reply->qual_phase[d1.seq].qual_component[compcnt].
      comp_updt_cnt = temp->outcomelist[d4.seq].comp_updt_cnt,
      reply->qual_phase[d1.seq].qual_component[compcnt].target_type_cd = temp->outcomelist[d4.seq].
      target_type_cd, reply->qual_phase[d1.seq].qual_component[compcnt].duration_qty = temp->
      outcomelist[d4.seq].duration_qty, reply->qual_phase[d1.seq].qual_component[compcnt].
      duration_unit_cd = temp->outcomelist[d4.seq].duration_unit_cd,
      reply->qual_phase[d1.seq].qual_component[compcnt].expand_qty = temp->outcomelist[d4.seq].
      expand_qty, reply->qual_phase[d1.seq].qual_component[compcnt].expand_unit_cd = temp->
      outcomelist[d4.seq].expand_unit_cd, reply->qual_phase[d1.seq].qual_component[compcnt].
      outcome_description = temp->outcomelist[d4.seq].outcome_description,
      reply->qual_phase[d1.seq].qual_component[compcnt].outcome_expectation = temp->outcomelist[d4
      .seq].outcome_expectation, reply->qual_phase[d1.seq].qual_component[compcnt].outcome_type_cd =
      temp->outcomelist[d4.seq].outcome_type_cd, reply->qual_phase[d1.seq].qual_component[compcnt].
      single_select_ind = temp->outcomelist[d4.seq].single_select_ind,
      reply->qual_phase[d1.seq].qual_component[compcnt].hide_expectation_ind = temp->outcomelist[d4
      .seq].hide_expectation_ind, reply->qual_phase[d1.seq].qual_component[compcnt].comp_label = temp
      ->outcomelist[d4.seq].comp_label, reply->qual_phase[d1.seq].qual_component[compcnt].
      parent_active_ind = temp->outcomelist[d4.seq].parent_active_ind,
      reply->qual_phase[d1.seq].qual_component[compcnt].offset_quantity = temp->outcomelist[d4.seq].
      offset_quantity
      IF ((reply->qual_phase[d1.seq].start_offset_ind=0)
       AND (reply->qual_phase[d1.seq].qual_component[compcnt].offset_quantity != 0))
       reply->qual_phase[d1.seq].start_offset_ind = 1
      ENDIF
      reply->qual_phase[d1.seq].qual_component[compcnt].offset_unit_cd = temp->outcomelist[d4.seq].
      offset_unit_cd, reply->qual_phase[d1.seq].qual_component[compcnt].facility_ind = temp->
      outcomelist[d4.seq].facility_ind, reply->qual_phase[d1.seq].qual_component[compcnt].
      all_facility_access_ind = temp->outcomelist[d4.seq].all_facility_access_ind,
      reply->qual_phase[d1.seq].qual_component[compcnt].time_zero_mean = "NONE", reply->qual_phase[d1
      .seq].qual_component[compcnt].chemo_related_ind = temp->outcomelist[d4.seq].chemo_related_ind,
      reply->qual_phase[d1.seq].qual_component[compcnt].display_format_xml = temp->outcomelist[d4.seq
      ].display_format_xml
      IF ((reply->qual_phase[d1.seq].chemo_related_ind=0)
       AND (reply->qual_phase[d1.seq].qual_component[compcnt].chemo_related_ind > 0))
       reply->qual_phase[d1.seq].chemo_related_ind = 1
      ENDIF
      IF ((reply->chemo_related_ind=0)
       AND (reply->qual_phase[d1.seq].qual_component[compcnt].chemo_related_ind > 0))
       reply->chemo_related_ind = 1
      ENDIF
      reply->qual_phase[d1.seq].qual_component[compcnt].ref_text_reltn_id = temp->outcomelist[d4.seq]
      .ref_text_reltn_id, count = size(temp->outcomelist[d4.seq].facilitylist,5)
      IF (count > 0)
       stat = alterlist(reply->qual_phase[d1.seq].qual_component[compcnt].facilitylist,count)
       FOR (j = 1 TO count)
         reply->qual_phase[d1.seq].qual_component[compcnt].facilitylist[j].facility_cd = temp->
         outcomelist[d4.seq].facilitylist[j].facility_cd
       ENDFOR
      ENDIF
     ELSEIF (check="sp")
      IF (((filterorc <= 0) OR ((((reply->qual_phase[d1.seq].hide_flexed_comp_ind=0)) OR (filterorc=1
       AND (temp->splist[d5.seq].facility_ind=1))) )) )
       compcnt += 1
       IF (compcnt > size(reply->qual_phase[d1.seq].qual_component,5))
        stat = alterlist(reply->qual_phase[d1.seq].qual_component,(compcnt+ 10))
       ENDIF
       reply->qual_phase[d1.seq].qual_component[compcnt].uuid = trim(temp->splist[d5.seq].uuid),
       reply->qual_phase[d1.seq].qual_component[compcnt].pathway_comp_id = temp->splist[d5.seq].
       pathway_comp_id, reply->qual_phase[d1.seq].qual_component[compcnt].dcp_clin_cat_cd = temp->
       splist[d5.seq].dcp_clin_cat_cd,
       reply->qual_phase[d1.seq].qual_component[compcnt].dcp_clin_sub_cat_cd = temp->splist[d5.seq].
       dcp_clin_sub_cat_cd, reply->qual_phase[d1.seq].qual_component[compcnt].sequence = temp->
       splist[d5.seq].sequence, reply->qual_phase[d1.seq].qual_component[compcnt].comp_type_cd = temp
       ->splist[d5.seq].comp_type_cd,
       reply->qual_phase[d1.seq].qual_component[compcnt].parent_entity_name = temp->splist[d5.seq].
       parent_entity_name, reply->qual_phase[d1.seq].qual_component[compcnt].parent_entity_id = temp
       ->splist[d5.seq].parent_entity_id, reply->qual_phase[d1.seq].qual_component[compcnt].
       included_ind = temp->splist[d5.seq].included_ind,
       reply->qual_phase[d1.seq].qual_component[compcnt].comp_updt_cnt = temp->splist[d5.seq].
       comp_updt_cnt, reply->qual_phase[d1.seq].qual_component[compcnt].offset_quantity = temp->
       splist[d5.seq].offset_quantity
       IF ((reply->qual_phase[d1.seq].start_offset_ind=0)
        AND (reply->qual_phase[d1.seq].qual_component[compcnt].offset_quantity > 0))
        reply->qual_phase[d1.seq].start_offset_ind = 1
       ENDIF
       IF ((reply->qual_phase[d1.seq].sub_phase_ind=0))
        reply->qual_phase[d1.seq].sub_phase_ind = 1
       ENDIF
       reply->qual_phase[d1.seq].qual_component[compcnt].offset_unit_cd = temp->splist[d5.seq].
       offset_unit_cd, reply->qual_phase[d1.seq].qual_component[compcnt].parent_active_ind = temp->
       splist[d5.seq].parent_active_ind, reply->qual_phase[d1.seq].qual_component[compcnt].
       facility_ind = temp->splist[d5.seq].facility_ind,
       reply->qual_phase[d1.seq].qual_component[compcnt].all_facility_access_ind = temp->splist[d5
       .seq].all_facility_access_ind, reply->qual_phase[d1.seq].qual_component[compcnt].
       parent_phase_desc = temp->splist[d5.seq].parent_phase_desc, reply->qual_phase[d1.seq].
       qual_component[compcnt].parent_phase_display_desc = temp->splist[d5.seq].
       parent_phase_display_desc,
       reply->qual_phase[d1.seq].qual_component[compcnt].comp_label = temp->splist[d5.seq].comp_label,
       reply->qual_phase[d1.seq].qual_component[compcnt].cross_phase_group_desc = temp->splist[d5.seq
       ].cross_phase_group_desc, reply->qual_phase[d1.seq].qual_component[compcnt].
       cross_phase_group_nbr = temp->splist[d5.seq].cross_phase_group_nbr,
       reply->qual_phase[d1.seq].qual_component[compcnt].min_tolerance_interval = temp->splist[d5.seq
       ].min_tolerance_interval, reply->qual_phase[d1.seq].qual_component[compcnt].
       min_tolerance_interval_unit_cd = temp->splist[d5.seq].min_tolerance_interval_unit_cd, reply->
       qual_phase[d1.seq].qual_component[compcnt].display_format_xml = temp->splist[d5.seq].
       display_format_xml,
       reply->qual_phase[d1.seq].qual_component[compcnt].chemo_related_ind = temp->splist[d5.seq].
       chemo_related_ind
       IF ((reply->qual_phase[d1.seq].chemo_related_ind=0)
        AND (reply->qual_phase[d1.seq].qual_component[compcnt].chemo_related_ind > 0))
        reply->qual_phase[d1.seq].chemo_related_ind = 1
       ENDIF
       IF ((reply->chemo_related_ind=0)
        AND (reply->qual_phase[d1.seq].qual_component[compcnt].chemo_related_ind > 0))
        reply->chemo_related_ind = 1
       ENDIF
       count = size(temp->splist[d5.seq].facilitylist,5)
       IF (count > 0)
        stat = alterlist(reply->qual_phase[d1.seq].qual_component[compcnt].facilitylist,count)
        FOR (j = 1 TO count)
          reply->qual_phase[d1.seq].qual_component[compcnt].facilitylist[j].facility_cd = temp->
          splist[d5.seq].facilitylist[j].facility_cd
        ENDFOR
       ENDIF
       reply->qual_phase[d1.seq].qual_component[compcnt].time_zero_mean = "NONE", reltncnt = size(
        reply->qual_phase[d1.seq].qual_phase_reltn,5), reltncnt += 1,
       stat = alterlist(reply->qual_phase[d1.seq].qual_phase_reltn,reltncnt), reply->qual_phase[d1
       .seq].qual_phase_reltn[reltncnt].pw_cat_s_id = reply->qual_phase[d1.seq].pathway_catalog_id,
       reply->qual_phase[d1.seq].qual_phase_reltn[reltncnt].pw_cat_t_id = temp->splist[d5.seq].
       parent_entity_id,
       reply->qual_phase[d1.seq].qual_phase_reltn[reltncnt].type_mean = "SUBPHASE"
       IF (getsubphasecompflag="Y")
        subphaseindex = 0, subphaseusedcount = 0
        IF (subphaseparentssize > 0)
         subphaseindex = locateval(subphasesearchindex,1,subphaseparentssize,temp->splist[d5.seq].
          parent_entity_id,subphaseparents->sub_phases[subphasesearchindex].sub_phase_catalog_id)
         IF (subphaseindex > 0)
          subphaseusedcount = subphaseparents->sub_phases[subphaseindex].used_count
         ENDIF
        ENDIF
        IF (subphaseindex <= 0)
         subphaseparentssize += 1, stat = alterlist(subphaseparents->sub_phases,subphaseparentssize),
         subphaseindex = subphaseparentssize,
         subphaseparents->sub_phases[subphaseindex].sub_phase_catalog_id = temp->splist[d5.seq].
         parent_entity_id, subphaseparents->sub_phases[subphaseindex].used_count = 0
        ENDIF
        subphaseusedcount += 1, subphaseparents->sub_phases[subphaseindex].used_count =
        subphaseusedcount, subphaseindex = 1,
        subphasereplyindex = 0
        FOR (idx = 1 TO subphaseusedcount)
         subphasereplyindex = locateval(subphasesearchindex,subphaseindex,high,temp->splist[d5.seq].
          parent_entity_id,reply->qual_phase[subphasesearchindex].pathway_catalog_id),subphaseindex
          = (subphasereplyindex+ 1)
        ENDFOR
        IF (subphasereplyindex > 0)
         reply->qual_phase[subphasereplyindex].parent_component_uuid = trim(reply->qual_phase[d1.seq]
          .qual_component[compcnt].uuid)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    dummy = 0
   FOOT  comp_seq
    dummy = 0
   FOOT  sort_cd
    dummy = 0
   FOOT  phase_idx
    stat = alterlist(reply->qual_phase[d1.seq].qual_component,compcnt)
   FOOT REPORT
    dummy = 0
   WITH nocounter, outerjoin = d1
  ;end select
  FREE RECORD subphaseparents
 ENDIF
 FREE RECORD temp
 IF ((reply->pathway_catalog_id > 0))
  DECLARE evidencecnt = i4 WITH noconstant(0), private
  DECLARE phstotal = i4 WITH constant(value(size(reply->qual_phase,5))), private
  RECORD temp5(
    1 size = i4
    1 new_size = i4
    1 loop_count = i4
    1 batch_size = i4
    1 list[*]
      2 pathway_catalog_id = f8
  )
  SET stat = alterlist(temp5->list,1)
  SET temp5->list[1].pathway_catalog_id = reply->pathway_catalog_id
  SET temp5->batch_size = 20
  IF (((phstotal > 1) OR ((reply->type_mean="PATHWAY"))) )
   SET stat = alterlist(temp5->list,(phstotal+ 1))
   FOR (i = 1 TO phstotal)
     SET temp5->list[(i+ 1)].pathway_catalog_id = reply->qual_phase[i].pathway_catalog_id
   ENDFOR
  ENDIF
  SET high = value(size(temp5->list,5))
  SELECT INTO "nl:"
   per.pathway_catalog_id, per.type_mean
   FROM pw_evidence_reltn per
   PLAN (per
    WHERE expand(num,1,high,per.pathway_catalog_id,temp5->list[num].pathway_catalog_id))
   ORDER BY per.pathway_catalog_id, per.type_mean, per.evidence_sequence
   HEAD REPORT
    evidencecnt = 0
   DETAIL
    evidencecnt += 1
    IF (evidencecnt > size(reply->planevidencelist,5))
     stat = alterlist(reply->planevidencelist,(evidencecnt+ 10))
    ENDIF
    reply->planevidencelist[evidencecnt].dcp_clin_cat_cd = per.dcp_clin_cat_cd, reply->
    planevidencelist[evidencecnt].dcp_clin_sub_cat_cd = per.dcp_clin_sub_cat_cd, reply->
    planevidencelist[evidencecnt].pathway_comp_id = per.pathway_comp_id,
    reply->planevidencelist[evidencecnt].evidence_type_mean = per.type_mean, reply->planevidencelist[
    evidencecnt].pw_evidence_reltn_id = per.pw_evidence_reltn_id, reply->planevidencelist[evidencecnt
    ].evidence_locator = per.evidence_locator,
    reply->planevidencelist[evidencecnt].pathway_catalog_id = per.pathway_catalog_id, reply->
    planevidencelist[evidencecnt].evidence_sequence = per.evidence_sequence
   FOOT REPORT
    stat = alterlist(reply->planevidencelist,evidencecnt)
   WITH nocounter, expand = 1
  ;end select
  SET phasetotal = value(size(reply->qual_phase,5))
  SET num = 0
  SET lstart = 1
  SET temp5->size = size(temp5->list,5)
  SET temp5->loop_count = ceil((cnvtreal(temp5->size)/ temp5->batch_size))
  SET temp5->new_size = (temp5->loop_count * temp5->batch_size)
  SET stat = alterlist(temp5->list,temp5->new_size)
  FOR (i = (temp5->size+ 1) TO temp5->new_size)
    SET temp5->list[i].pathway_catalog_id = temp5->list[temp5->size].pathway_catalog_id
  ENDFOR
  SELECT INTO "nl:"
   rtr.parent_entity_name, rtr.parent_entity_id
   FROM (dummyt d1  WITH seq = value(temp5->loop_count)),
    ref_text_reltn rtr
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ temp5->batch_size))))
    JOIN (rtr
    WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
     AND expand(num,lstart,(lstart+ (temp5->batch_size - 1)),rtr.parent_entity_id,temp5->list[num].
     pathway_catalog_id)
     AND rtr.active_ind=1)
   ORDER BY rtr.parent_entity_name, rtr.parent_entity_id
   HEAD rtr.parent_entity_id
    careplanrefrtextid = 0.0, patientedrefrtextid = 0.0
   DETAIL
    IF (rtr.text_type_cd=care_plan_cd)
     careplanrefrtextid = rtr.ref_text_reltn_id
    ENDIF
    IF (rtr.text_type_cd=patient_ed_cd)
     patientedrefrtextid = rtr.ref_text_reltn_id
    ENDIF
   FOOT  rtr.parent_entity_id
    IF (((phasetotal > 1) OR ((reply->type_mean="PATHWAY"))) )
     FOR (i = 1 TO phasetotal)
       IF ((reply->qual_phase[i].pathway_catalog_id=rtr.parent_entity_id))
        reply->qual_phase[i].ref_text_ind = 1, reply->qual_phase[i].care_plan_ref_text_id =
        careplanrefrtextid, reply->qual_phase[i].pat_ed_ref_text_id = patientedrefrtextid
       ENDIF
     ENDFOR
    ENDIF
    IF ((reply->pathway_catalog_id=rtr.parent_entity_id))
     reply->ref_text_ind = 1, reply->care_plan_ref_text_id = careplanrefrtextid, reply->
     pat_ed_ref_text_id = patientedrefrtextid
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  SET high = value(size(reply->planevidencelist,5))
  SET idx = 0
  SET num = 0
  IF (high > 0)
   SELECT INTO "nl:"
    FROM ref_text_reltn rtr
    PLAN (rtr
     WHERE expand(num,1,high,rtr.parent_entity_id,reply->planevidencelist[num].pw_evidence_reltn_id)
      AND rtr.parent_entity_name="PW_EVIDENCE_RELTN"
      AND rtr.active_ind=1)
    HEAD REPORT
     idx = 0
    DETAIL
     idx = locateval(idx,1,high,rtr.parent_entity_id,reply->planevidencelist[idx].
      pw_evidence_reltn_id)
     IF (idx > 0)
      IF ((reply->planevidencelist[idx].text_type_cd=0))
       reply->planevidencelist[idx].text_type_cd = rtr.text_type_cd, reply->planevidencelist[idx].
       ref_text_reltn_id = rtr.ref_text_reltn_id
      ELSE
       evidencecnt = size(reply->planevidencelist,5), evidencecnt += 1, stat = alterlist(reply->
        planevidencelist,evidencecnt),
       reply->planevidencelist[evidencecnt].dcp_clin_cat_cd = reply->planevidencelist[idx].
       dcp_clin_cat_cd, reply->planevidencelist[evidencecnt].dcp_clin_sub_cat_cd = reply->
       planevidencelist[idx].dcp_clin_sub_cat_cd, reply->planevidencelist[evidencecnt].
       pathway_comp_id = reply->planevidencelist[idx].pathway_comp_id,
       reply->planevidencelist[evidencecnt].evidence_type_mean = reply->planevidencelist[idx].
       evidence_type_mean, reply->planevidencelist[evidencecnt].pw_evidence_reltn_id = reply->
       planevidencelist[idx].pw_evidence_reltn_id, reply->planevidencelist[evidencecnt].
       evidence_locator = reply->planevidencelist[idx].evidence_locator,
       reply->planevidencelist[evidencecnt].pathway_catalog_id = reply->planevidencelist[idx].
       pathway_catalog_id, reply->planevidencelist[evidencecnt].evidence_sequence = reply->
       planevidencelist[idx].evidence_sequence, reply->planevidencelist[evidencecnt].text_type_cd =
       rtr.text_type_cd,
       reply->planevidencelist[evidencecnt].ref_text_reltn_id = rtr.ref_text_reltn_id
      ENDIF
     ENDIF
    FOOT REPORT
     idx = 0
    WITH nocounter, expand = 1
   ;end select
  ENDIF
  FREE RECORD temp5
  DECLARE facilitycnt = i4 WITH noconstant(0), private
  SELECT INTO "nl:"
   FROM pw_cat_flex pcf
   PLAN (pcf
    WHERE (pcf.pathway_catalog_id=reply->pathway_catalog_id)
     AND pcf.parent_entity_name="CODE_VALUE"
     AND pcf.parent_entity_id != 0)
   HEAD REPORT
    facilitycnt = 0
   DETAIL
    facilitycnt += 1
    IF (facilitycnt > size(reply->facilityflexlist,5))
     stat = alterlist(reply->facilityflexlist,(facilitycnt+ 5))
    ENDIF
    reply->facilityflexlist[facilitycnt].facility_cd = pcf.parent_entity_id
   FOOT REPORT
    stat = alterlist(reply->facilityflexlist,facilitycnt)
   WITH nocounter
  ;end select
  DECLARE problemcnt = i4 WITH noconstant(0), private
  SELECT INTO "nl:"
   FROM concept_cki_entity_r ccer,
    nomenclature nc
   PLAN (ccer
    WHERE (ccer.entity_id=reply->pathway_catalog_id)
     AND ccer.entity_name="PATHWAY_CATALOG")
    JOIN (nc
    WHERE nc.concept_cki=ccer.concept_cki
     AND nc.primary_vterm_ind=1
     AND nc.active_ind=1
     AND nc.end_effective_dt_tm > cnvtdatetime(sysdate))
   HEAD REPORT
    problemcnt = 0
   DETAIL
    problemcnt += 1
    IF (problemcnt > size(reply->problemdiaglist,5))
     stat = alterlist(reply->problemdiaglist,(problemcnt+ 5))
    ENDIF
    reply->problemdiaglist[problemcnt].concept_cki = ccer.concept_cki, reply->problemdiaglist[
    problemcnt].nomenclature_id = nc.nomenclature_id, reply->problemdiaglist[problemcnt].
    source_string = nc.source_string
   FOOT REPORT
    stat = alterlist(reply->problemdiaglist,problemcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (value(size(temp2->phaselist,5)) > 0)
  SELECT INTO "nl:"
   pathway_catalog_id = temp2->phaselist[d1.seq].pathway_catalog_id, source_id = temp2->phaselist[d1
   .seq].comprlist[d2.seq].source_id, target_id = temp2->phaselist[d1.seq].comprlist[d2.seq].
   target_id
   FROM (dummyt d1  WITH seq = value(size(temp2->phaselist,5))),
    (dummyt d2  WITH seq = 5)
   PLAN (d1
    WHERE maxrec(d2,size(temp2->phaselist[d1.seq].comprlist,5)) > 0)
    JOIN (d2)
   ORDER BY pathway_catalog_id, source_id, target_id
   HEAD REPORT
    idx = 0, high = 0, idx2 = 0,
    high2 = 0, high = size(reply->qual_phase,5)
   HEAD pathway_catalog_id
    idx = locateval(idx,1,high,pathway_catalog_id,reply->qual_phase[idx].pathway_catalog_id), reply->
    qual_phase[idx].time_zero_ind = 1, high2 = size(reply->qual_phase[idx].qual_component,5)
   HEAD source_id
    idx2 = locateval(idx2,1,high2,source_id,reply->qual_phase[idx].qual_component[idx2].
     pathway_comp_id)
    IF (idx > 0)
     reply->qual_phase[idx].qual_component[idx2].time_zero_mean = "TIMEZERO"
    ENDIF
   HEAD target_id
    idx2 = locateval(idx2,1,high2,target_id,reply->qual_phase[idx].qual_component[idx2].
     pathway_comp_id)
    IF (idx > 0)
     reply->qual_phase[idx].qual_component[idx2].time_zero_mean = "TIMEZEROLINK", reply->qual_phase[
     idx].qual_component[idx2].time_zero_offset_quantity = temp2->phaselist[d1.seq].comprlist[d2.seq]
     .offset_quantity, reply->qual_phase[idx].qual_component[idx2].time_zero_offset_unit_cd = temp2->
     phaselist[d1.seq].comprlist[d2.seq].offset_unit_cd
    ENDIF
   DETAIL
    dummy = 0
   FOOT  target_id
    dummy = 0
   FOOT  source_id
    dummy = 0
   FOOT  pathway_catalog_id
    dummy = 0
   FOOT REPORT
    dummy = 0
   WITH nocounter, outerjoin = d1
  ;end select
 ENDIF
 FREE RECORD temp2
 IF (value(size(temp4->phaselist,5)) > 0)
  SELECT INTO "nl:"
   pathway_catalog_id = temp4->phaselist[d.seq].pathway_catalog_id
   FROM (dummyt d  WITH seq = value(size(temp4->phaselist,5)))
   PLAN (d)
   ORDER BY pathway_catalog_id
   HEAD REPORT
    idx = 0, high = size(reply->qual_phase,5)
   DETAIL
    idx = locateval(idx,1,high,pathway_catalog_id,reply->qual_phase[idx].pathway_catalog_id)
    WHILE (idx > 0)
      gcnt = size(temp4->phaselist[d.seq].compglist,5), stat = alterlist(reply->qual_phase[idx].
       compgrouplist,gcnt)
      FOR (i = 1 TO gcnt)
        reply->qual_phase[idx].compgrouplist[i].pw_comp_group_id = temp4->phaselist[d.seq].compglist[
        i].pw_comp_group_id, reply->qual_phase[idx].compgrouplist[i].type_mean = temp4->phaselist[d
        .seq].compglist[i].type_mean, reply->qual_phase[idx].compgrouplist[i].description = trim(
         temp4->phaselist[d.seq].compglist[i].description),
        reply->qual_phase[idx].compgrouplist[i].linking_rule_flag = temp4->phaselist[d.seq].
        compglist[i].linking_rule_flag, reply->qual_phase[idx].compgrouplist[i].linking_rule_quantity
         = temp4->phaselist[d.seq].compglist[i].linking_rule_quantity, reply->qual_phase[idx].
        compgrouplist[i].override_reason_flag = temp4->phaselist[d.seq].compglist[i].
        override_reason_flag,
        ccnt = size(temp4->phaselist[d.seq].compglist[i].memberlist,5), stat = alterlist(reply->
         qual_phase[idx].compgrouplist[i].memberlist,ccnt)
        FOR (j = 1 TO ccnt)
          reply->qual_phase[idx].compgrouplist[i].memberlist[j].pathway_comp_id = temp4->phaselist[d
          .seq].compglist[i].memberlist[j].pathway_comp_id, reply->qual_phase[idx].compgrouplist[i].
          memberlist[j].comp_seq = temp4->phaselist[d.seq].compglist[i].memberlist[j].comp_seq, reply
          ->qual_phase[idx].compgrouplist[i].memberlist[j].anchor_component_ind = temp4->phaselist[d
          .seq].compglist[i].memberlist[j].anchor_component_ind
        ENDFOR
      ENDFOR
      idx = locateval(idx,(idx+ 1),high,pathway_catalog_id,reply->qual_phase[idx].pathway_catalog_id)
    ENDWHILE
   FOOT REPORT
    dummy = 0
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(request->patient_criteria) > 0)
  IF (validate(request->patient_criteria.birth_dt_tm) > 0)
   SET filter_order_sentences->patient_criteria.birth_dt_tm = request->patient_criteria.birth_dt_tm
  ENDIF
  SET filter_order_sentences->patient_criteria.birth_tz = validate(request->patient_criteria.birth_tz,
   0)
  SET filter_order_sentences->patient_criteria.postmenstrual_age_in_days = validate(request->
   patient_criteria.postmenstrual_age_in_days,0)
  SET filter_order_sentences->patient_criteria.weight = validate(request->patient_criteria.weight,0.0
   )
  SET filter_order_sentences->patient_criteria.weight_unit_cd = validate(request->patient_criteria.
   weight_unit_cd,0.0)
  EXECUTE crmrtl
  EXECUTE srvrtl
  DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
  DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
  SUBROUTINE (filterordersentences(orm_filter_order_sentences_record=vc(ref)) =null)
   IF (size(orm_filter_order_sentences_record->orders,5) > 0)
    SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationname =
    "FilterOrderSentences"
    DECLARE hmessage = i4 WITH private, constant(uar_srvselect("FilterOrderSentences"))
    IF (hmessage=0)
     SET orm_filter_order_sentences_record->status_data.status = "F"
     SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
     "Error creating Transaction Message"
    ELSE
     DECLARE hrequest = i4 WITH private, constant(uar_srvcreaterequest(hmessage))
     IF (hrequest=0)
      SET orm_filter_order_sentences_record->status_data.status = "F"
      SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
      "Error creating the Request for the transaction"
     ELSE
      DECLARE hreply = i4 WITH private, constant(uar_srvcreatereply(hmessage))
      IF (hreply=0)
       SET orm_filter_order_sentences_record->status_data.status = "F"
       SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
       "Error creating the Reply for the transaction"
      ELSE
       CALL populatepatientcriteria(orm_filter_order_sentences_record,hrequest)
       CALL populaterequest(orm_filter_order_sentences_record,hrequest)
       CALL executefilterordersentences(orm_filter_order_sentences_record,hmessage,hrequest,hreply)
       IF ((orm_filter_order_sentences_record->status_data.status="S"))
        CALL unpackreply(orm_filter_order_sentences_record,hreply)
       ELSE
        SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationstatus = "F"
        SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
        uar_srvgetstringptr(uar_srvgetstruct(hreply,"transaction_status"),"debug_error_message")
       ENDIF
       CALL uar_srvdestroyinstance(hreply)
      ENDIF
      CALL uar_srvdestroyinstance(hrequest)
     ENDIF
     CALL uar_srvdestroyinstance(hmessage)
    ENDIF
   ELSE
    SET orm_filter_order_sentences_record->status_data.status = "S"
   ENDIF
   RETURN
  END ;Subroutine
  SUBROUTINE (populatepatientcriteria(orm_filter_order_sentences_record=vc(ref),hrequest=i4) =null)
    DECLARE hpatientcriteria = i4 WITH private, constant(uar_srvgetstruct(hrequest,"patient_criteria"
      ))
    IF (hpatientcriteria != 0)
     CALL uar_srvsetdate(hpatientcriteria,"birth_dt_tm",cnvtdatetime(
       orm_filter_order_sentences_record->patient_criteria.birth_dt_tm))
     CALL uar_srvsetlong(hpatientcriteria,"birth_tz",orm_filter_order_sentences_record->
      patient_criteria.birth_tz)
     CALL uar_srvsetlong(hpatientcriteria,"postmenstrual_age_in_days",
      orm_filter_order_sentences_record->patient_criteria.postmenstrual_age_in_days)
     CALL uar_srvsetdouble(hpatientcriteria,"weight",orm_filter_order_sentences_record->
      patient_criteria.weight)
     CALL uar_srvsetdouble(hpatientcriteria,"weight_unit_cd",orm_filter_order_sentences_record->
      patient_criteria.weight_unit_cd)
    ENDIF
    RETURN
  END ;Subroutine
  SUBROUTINE (populaterequest(orm_filter_order_sentences_record=vc(ref),hrequest=i4) =null)
    DECLARE iordersindex = i4 WITH private, noconstant(0)
    DECLARE irequestorderssize = i4 WITH private, constant(size(orm_filter_order_sentences_record->
      orders,5))
    DECLARE horders = i4 WITH private, noconstant(0)
    DECLARE iordersentenceindex = i4 WITH private, noconstant(0)
    DECLARE iordersentencessize = i4 WITH private, noconstant(0)
    DECLARE hordersentences = i4 WITH private, noconstant(0)
    FOR (iordersindex = 1 TO irequestorderssize)
     SET horders = uar_srvadditem(hrequest,"orders")
     IF (horders != 0)
      CALL uar_srvsetdouble(horders,"unique_identifier",orm_filter_order_sentences_record->orders[
       iordersindex].unique_identifier)
      SET iordersentencessize = size(orm_filter_order_sentences_record->orders[iordersindex].
       order_sentences,5)
      IF (iordersentencessize > 0)
       FOR (iordersentenceindex = 1 TO iordersentencessize)
        SET hordersentences = uar_srvadditem(horders,"order_sentences")
        IF (hordersentences != 0)
         CALL uar_srvsetdouble(hordersentences,"order_sentence_id",orm_filter_order_sentences_record
          ->orders[iordersindex].order_sentences[iordersentenceindex].order_sentence_id)
        ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDFOR
    RETURN
  END ;Subroutine
  SUBROUTINE (executefilterordersentences(orm_filter_order_sentences_record=vc(ref),hmessage=i4,
   hrequest=i4,hreply=i4) =null)
    IF (uar_srvexecute(hmessage,hrequest,hreply)=0)
     DECLARE htransactionstatus = i4 WITH private, constant(uar_srvgetstruct(hreply,
       "transaction_status"))
     IF (htransactionstatus != 0)
      IF (uar_srvgetshort(htransactionstatus,"success_ind")=1)
       SET orm_filter_order_sentences_record->status_data.status = "S"
       SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationstatus = "S"
      ELSE
       SET orm_filter_order_sentences_record->status_data.status = "F"
       SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationstatus = "S"
      ENDIF
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE (unpackreply(orm_filter_order_sentences_record=vc(ref),hreply=i4) =null)
    DECLARE lfindindex = i4 WITH private, noconstant(0)
    DECLARE iordersindex = i4 WITH private, noconstant(0)
    DECLARE iorderssize = i4 WITH private, constant(size(orm_filter_order_sentences_record->orders,5)
     )
    DECLARE horders = i4 WITH private, noconstant(0)
    DECLARE iordersentenceindex = i4 WITH private, noconstant(0)
    DECLARE hordersentences = i4 WITH private, noconstant(0)
    DECLARE ireplyordersindex = i4 WITH private, noconstant(0)
    DECLARE ireplyordersentencesize = i4 WITH private, noconstant(0)
    DECLARE ireplyordersentenceindex = i4 WITH private, noconstant(0)
    DECLARE iordersentfilterindex = i4 WITH private, noconstant(0)
    DECLARE iordersentfiltersize = i4 WITH private, noconstant(0)
    DECLARE hordersentencefilters = i4 WITH private, noconstant(0)
    DECLARE hordersentencefiltertype = i4 WITH private, noconstant(0)
    FOR (ireplyordersindex = 1 TO iorderssize)
     SET horders = uar_srvgetitem(hreply,"orders",(ireplyordersindex - 1))
     IF (horders != 0)
      SET iordersindex = locateval(lfindindex,1,iorderssize,uar_srvgetdouble(horders,
        "unique_identifier"),orm_filter_order_sentences_record->orders[lfindindex].unique_identifier)
      WHILE (iordersindex > 0)
        SET ireplyordersentencesize = uar_srvgetitemcount(horders,"order_sentences")
        FOR (ireplyordersentenceindex = 1 TO ireplyordersentencesize)
         SET hordersentences = uar_srvgetitem(horders,"order_sentences",(ireplyordersentenceindex - 1
          ))
         IF (hordersentences != 0)
          SET iordersentenceindex = locateval(lfindindex,1,size(orm_filter_order_sentences_record->
            orders[iordersindex].order_sentences,5),uar_srvgetdouble(hordersentences,
            "order_sentence_id"),orm_filter_order_sentences_record->orders[iordersindex].
           order_sentences[lfindindex].order_sentence_id)
          IF (iordersentenceindex > 0)
           SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
           iordersentenceindex].applicable_to_patient_ind = uar_srvgetshort(hordersentences,
            "applicable_to_patient_ind")
           SET iordersentfiltersize = uar_srvgetitemcount(hordersentences,"order_sentence_filters")
           IF (iordersentfiltersize > 0)
            SET stat = alterlist(orm_filter_order_sentences_record->orders[iordersindex].
             order_sentences[iordersentenceindex].order_sentence_filters,iordersentfiltersize)
            FOR (iordersentfilterindex = 1 TO iordersentfiltersize)
             SET hordersentencefilters = uar_srvgetitem(hordersentences,"order_sentence_filters",0)
             IF (hordersentencefilters != 0)
              SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
              iordersentenceindex].order_sentence_filters[iordersentfilterindex].
              order_sentence_filter_display = uar_srvgetstringptr(hordersentencefilters,
               "order_sentence_filter_display")
              SET hordersentencefiltertype = uar_srvgetstruct(hordersentencefilters,
               "order_sentence_filter_type")
              IF (hordersentencefiltertype != 0)
               IF (validate(orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                order_sentence_filter_type) > 0)
                SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                order_sentence_filter_type.age_filter_ind = uar_srvgetshort(hordersentencefiltertype,
                 "age_filter_ind")
                SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                order_sentence_filter_type.pma_filter_ind = uar_srvgetshort(hordersentencefiltertype,
                 "pma_filter_ind")
                SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                order_sentence_filter_type.weight_filter_ind = uar_srvgetshort(
                 hordersentencefiltertype,"weight_filter_ind")
               ENDIF
              ENDIF
             ENDIF
            ENDFOR
           ENDIF
          ENDIF
         ENDIF
        ENDFOR
        SET iordersindex = locateval(lfindindex,(iordersindex+ 1),iorderssize,uar_srvgetdouble(
          horders,"unique_identifier"),orm_filter_order_sentences_record->orders[lfindindex].
         unique_identifier)
      ENDWHILE
     ENDIF
    ENDFOR
    SET last_mod = "003"
    SET mod_date = "May 05, 2022"
  END ;Subroutine
  CALL filterordersentences(filter_order_sentences)
  IF ((filter_order_sentences->status_data.status="S"))
   DECLARE reply_phase_index = i4 WITH noconstant(0), protect
   DECLARE reply_component_index = i4 WITH noconstant(0), protect
   DECLARE lordersentenceapplicabletopatientindex = i4 WITH noconstant(1), protect
   DECLARE lorderssize = i4 WITH noconstant(0), protect
   DECLARE lordersindex = i4 WITH noconstant(0), protect
   DECLARE lordersentencessize = i4 WITH noconstant(0), protect
   DECLARE lordersentencesindex = i4 WITH noconstant(0), protect
   DECLARE lordersentenceapplicabletopatientindicator = i4 WITH constant(1), protect
   DECLARE lordersentencecounter = i4 WITH noconstant(0), protect
   DECLARE lordersentenceapplicabletopatientstartindex = i4 WITH noconstant(1), protect
   DECLARE default_os_is_reset = i1 WITH noconstant(0), protect
   DECLARE replyapplicabletopatient = i2 WITH noconstant(0), protect
   SET lorderssize = size(filter_order_sentences->orders,5)
   FOR (lordersindex = 1 TO lorderssize)
    SET reply_phase_index = filter_order_sentences->orders[lordersindex].reply_phase_index
    IF (reply_phase_index > 0)
     SET reply_component_index = filter_order_sentences->orders[lordersindex].component_index
     IF (reply_component_index > 0)
      SET lordersentencessize = size(filter_order_sentences->orders[lordersindex].order_sentences,5)
      SET default_os_is_reset = 0
      FOR (lordersentencesindex = 1 TO lordersentencessize)
        SET replyapplicabletopatient = 0
        IF (validate(reply->qual_phase[reply_phase_index].qual_component[reply_component_index].
         qual_order_sentence[lordersentencesindex].applicable_to_patient_ind) > 0)
         SET replyapplicabletopatient = filter_order_sentences->orders[lordersindex].order_sentences[
         lordersentencesindex].applicable_to_patient_ind
         SET reply->qual_phase[reply_phase_index].qual_component[reply_component_index].
         qual_order_sentence[lordersentencesindex].applicable_to_patient_ind =
         replyapplicabletopatient
         IF ((((request->person_id > 0.00)) OR ((request->encntr_id > 0.00)))
          AND replyapplicabletopatient=1
          AND default_os_is_reset=0
          AND (reply->qual_phase[reply_phase_index].qual_component[reply_component_index].
         default_os_ind=1))
          IF (size(filter_order_sentences->orders[lordersindex].order_sentences[lordersentencesindex]
           .order_sentence_filters,5) >= 1)
           IF (resetdefaultosindicator(filter_order_sentences->orders[lordersindex].order_sentences[
            lordersentencesindex].order_sentence_filters[1].order_sentence_filter_type.age_filter_ind,
            filter_order_sentences->orders[lordersindex].order_sentences[lordersentencesindex].
            order_sentence_filters[1].order_sentence_filter_type.weight_filter_ind)=1)
            SET reply->qual_phase[reply_phase_index].qual_component[reply_component_index].
            default_os_ind = 0
           ENDIF
          ENDIF
          SET default_os_is_reset = 1
         ENDIF
         SET lordersentencecounter += 1
         IF (lordersentencecounter=lordersentencessize)
          SET lordersentenceapplicabletopatientindex = locateval(
           lordersentenceapplicabletopatientstartindex,1,lordersentencessize,
           lordersentenceapplicabletopatientindicator,reply->qual_phase[reply_phase_index].
           qual_component[reply_component_index].qual_order_sentence[
           lordersentenceapplicabletopatientstartindex].applicable_to_patient_ind)
          SET lordersentencecounter = 0
         ENDIF
         IF (lordersentenceapplicabletopatientindex=0
          AND (((request->person_id > 0.00)) OR ((request->encntr_id > 0.00))) )
          SET reply->qual_phase[reply_phase_index].qual_component[reply_component_index].
          default_os_ind = 0
          SET lordersentenceapplicabletopatientindex = 1
         ENDIF
        ENDIF
        IF (validate(filter_order_sentences->orders[lordersindex].order_sentences[
         lordersentencesindex].order_sentence_filters) > 0)
         IF (size(filter_order_sentences->orders[lordersindex].order_sentences[lordersentencesindex].
          order_sentence_filters,5) >= 1)
          SET reply->qual_phase[reply_phase_index].qual_component[reply_component_index].
          qual_order_sentence[lordersentencesindex].order_sentence_filter_display = trim(
           filter_order_sentences->orders[lordersindex].order_sentences[lordersentencesindex].
           order_sentence_filters[1].order_sentence_filter_display)
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDFOR
  ELSE
   DECLARE lorderssize = i4 WITH noconstant(0), protect
   DECLARE reply_phase_index = i4 WITH noconstant(0), protect
   DECLARE reply_component_index = i4 WITH noconstant(0), protect
   SET lorderssize = size(filter_order_sentences->orders,5)
   FOR (lordersindex = 1 TO lorderssize)
    SET reply_phase_index = filter_order_sentences->orders[lordersindex].reply_phase_index
    IF (reply_phase_index > 0)
     SET reply_component_index = filter_order_sentences->orders[lordersindex].component_index
     IF (reply_component_index > 0)
      SET reply->qual_phase[reply_phase_index].qual_component[reply_component_index].default_os_ind
       = 0
     ENDIF
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 FREE RECORD temp4
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   DECLARE cnt = i4 WITH private, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
 SUBROUTINE resetdefaultosindicator(iagefilterind,iweightfilterind)
   IF (iagefilterind > 0)
    IF (validate(request->patient_criteria) > 0
     AND (request->patient_criteria.birth_dt_tm=null))
     RETURN(1)
    ENDIF
   ENDIF
   IF (iweightfilterind > 0)
    IF (validate(request->patient_criteria) > 0
     AND (((request->patient_criteria.weight=0.0)) OR ((request->patient_criteria.weight_unit_cd=0.0)
    )) )
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
#exit_script
 FREE RECORD comp_phase_reltn
 FREE RECORD filter_order_sentences
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  IF (validate(request->person_id,0.0) > 0.0)
   EXECUTE eks_flex_pp_reply
  ENDIF
  SET reply->status_data.status = "S"
 ENDIF
 DECLARE last_mod = c3 WITH public, constant("087")
END GO
