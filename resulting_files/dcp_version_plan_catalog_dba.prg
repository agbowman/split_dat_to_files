CREATE PROGRAM dcp_version_plan_catalog:dba
 RECORD reply(
   1 version_number = i4
   1 pathway_catalog_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD pw_pt_reltn_copy
 RECORD pw_pt_reltn_copy(
   1 active_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 minimum_enrollment_status_flag = i2
   1 ordering_policy_flag = i2
   1 pathway_catalog_id = f8
   1 prev_pw_pt_reltn_id = f8
   1 prot_master_id = f8
   1 pw_pt_reltn_id = f8
   1 require_override_reason_ind = i2
   1 sequence = i4
 )
 DECLARE cfailed = c1 WITH noconstant("F"), protect
 DECLARE cstatus = c1 WITH noconstant("S"), protect
 DECLARE phasecnt = i4 WITH noconstant(0), protect
 DECLARE compcnt = i4 WITH noconstant(0), protect
 DECLARE reltncnt = i4 WITH noconstant(0), protect
 DECLARE phsreltncnt = i4 WITH noconstant(0), protect
 DECLARE evdcnt = i4 WITH noconstant(0), protect
 DECLARE problemdiagcnt = i4 WITH noconstant(0), protect
 DECLARE compphasereltncnt = i4 WITH noconstant(0), protect
 DECLARE idcnt = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE high = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE j = i4 WITH noconstant(0), protect
 DECLARE k = i4 WITH noconstant(0), protect
 DECLARE x = i4 WITH noconstant(0), protect
 DECLARE id = f8 WITH noconstant(0.0), protect
 DECLARE oldid = f8 WITH noconstant(0.0), protect
 DECLARE newid = f8 WITH noconstant(0.0), protect
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE new_version_number = i4 WITH noconstant(0), protect
 DECLARE membercnt = i4 WITH noconstant(0), protect
 DECLARE groupcnt = i4 WITH noconstant(0), protect
 DECLARE subphase = f8 WITH constant(uar_get_code_by("MEANING",16750,"SUBPHASE")), protect
 DECLARE irefidcp = f8 WITH noconstant(0), protect
 DECLARE irefidpe = f8 WITH noconstant(0), protect
 DECLARE indxref = i2 WITH noconstant(0), protect
 DECLARE version_to_testing_ind = i2 WITH protect, constant(validate(request->version_to_testing_ind,
   0))
 DECLARE cerner_end_dt_tm = dq8 WITH protect, constant(cnvtdatetime("31-DEC-2100 00:00:00.00"))
 DECLARE lnewordersentencecount = i4 WITH protect, noconstant(0)
 DECLARE lordersentencecount = i4 WITH protect, noconstant(0)
 DECLARE lordersentenceindex = i4 WITH protect, noconstant(0)
 DECLARE synonymcnt = i4 WITH protect, noconstant(0)
 DECLARE compphasereltncnt = i4 WITH protect, noconstant(0)
 DECLARE compphasereltnidx = i4 WITH protect, noconstant(0)
 DECLARE phsreltnidx = i4 WITH noconstant(0), protect
 DECLARE addphaseidx = i4 WITH noconstant(1), protect
 DECLARE tzexceptcnt = i4 WITH noconstant(0), protect
 DECLARE tzexceptidx = i4 WITH noconstant(0), protect
 DECLARE lpowerchartappid = i4 WITH protect, constant(600005)
 DECLARE lorderquerytaskid = i4 WITH protect, constant(3202004)
 DECLARE lquerydosecalcdefaultmethodsstepid = i4 WITH protect, constant(520150)
 DECLARE defmethodpairreltncount = i4 WITH private, noconstant(0)
 DECLARE defaultmethodpairreltnidx = i4 WITH private, noconstant(0)
 DECLARE add_reference_text(indx,ireftextid,ipwcatalogid) = null
 SET pw_def_dose_calc_method_table_exists = checkdic("PW_DEF_DOSE_CALC_METHOD","T",0)
 RECORD get_cat_request(
   1 pathway_catalog_id = f8
   1 facility_cd = f8
   1 skip_sub_phase_ind = i2
   1 active_version_ind = i2
 )
 RECORD get_cat_reply(
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
 RECORD copy_os_request(
   1 oe_format_id = f8
   1 pathway_comp_id = f8
   1 qual[*]
     2 order_sent_id = f8
     2 order_sent_display = vc
 )
 RECORD copy_os_reply(
   1 qual[*]
     2 new_order_sent_id = f8
     2 orig_order_sent_id = f8
     2 order_sent_display = vc
     2 ord_comment_long_text_id = f8
     2 long_text = vc
     2 rx_type_mean = c12
     2 normalized_dose_unit_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD add_cat_request(
   1 planlist[*]
     2 pathway_catalog_id = f8
     2 type_mean = c12
     2 active_ind = i2
     2 cross_encntr_ind = i2
     2 description = vc
     2 comment_text = vc
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 pathway_type_cd = f8
     2 display_method_cd = f8
     2 version = i4
     2 version_pw_cat_id = f8
     2 flex_parent_entity_id = f8
     2 flex_parent_entity_name = vc
     2 display_description = vc
     2 sub_phase_ind = i2
     2 hide_flexed_comp_ind = i2
     2 complist[*]
       3 pathway_comp_id = f8
       3 sequence = i4
       3 comp_type_cd = f8
       3 comp_type_mean = c12
       3 dcp_clin_cat_cd = f8
       3 dcp_clin_sub_cat_cd = f8
       3 linked_to_tf_ind = i2
       3 persistent_ind = i2
       3 required_ind = i2
       3 include_ind = i2
       3 comp_text = vc
       3 synonym_id = f8
       3 outcome_catalog_id = f8
       3 duration_qty = i4
       3 duration_unit_cd = f8
       3 target_type_cd = f8
       3 expand_qty = i4
       3 expand_unit_cd = f8
       3 comp_label = vc
       3 offset_quantity = f8
       3 offset_unit_cd = f8
       3 ordsentlist[*]
         4 order_sentence_id = f8
         4 order_sentence_seq = i4
         4 iv_comp_syn_id = f8
         4 normalized_dose_unit_ind = i2
         4 missing_required_ind = i2
       3 sub_phase_catalog_id = f8
       3 cross_phase_group_desc = c40
       3 cross_phase_group_nbr = f8
       3 chemo_ind = i2
       3 chemo_related_ind = i2
       3 default_os_ind = i2
       3 min_tolerance_interval = i4
       3 min_tolerance_interval_unit_cd = f8
       3 uuid = vc
       3 display_format_xml = vc
       3 lock_target_dose_flag = i2
       3 qual_defaultmethodpairreltn[*]
         4 facility_cd = f8
         4 qual_methodpair[*]
           5 method_mean = vc
           5 method_cd = f8
     2 compreltnlist[*]
       3 pathway_comp_s_id = f8
       3 pathway_comp_t_id = f8
       3 type_mean = c12
       3 offset_quantity = f8
       3 offset_unit_cd = f8
       3 pathway_catalog_id = f8
     2 compgrouplist[*]
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
     2 cycle_ind = i2
     2 standard_cycle_nbr = i4
     2 default_view_mean = c12
     2 diagnosis_capture_ind = i2
     2 provider_prompt_ind = i2
     2 allow_copy_forward_ind = i2
     2 auto_initiate_ind = i2
     2 alerts_on_plan_ind = i2
     2 alerts_on_plan_upd_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 cycle_begin_nbr = i4
     2 cycle_end_nbr = i4
     2 cycle_label_cd = f8
     2 cycle_display_end_ind = i2
     2 cycle_lock_end_ind = i2
     2 cycle_increment_nbr = i4
     2 default_action_inpt_future_cd = f8
     2 default_action_inpt_now_cd = f8
     2 default_action_outpt_future_cd = f8
     2 default_action_outpt_now_cd = f8
     2 optional_ind = i2
     2 future_ind = i2
     2 default_visit_type_flag = i2
     2 prompt_on_selection_ind = i2
     2 pathway_class_cd = f8
     2 period_nbr = i4
     2 period_custom_label = c40
     2 synonymlist[*]
       3 synonym_name = vc
     2 route_for_review_ind = i2
     2 default_start_time_txt = c10
     2 primary_ind = i2
     2 uuid = vc
     2 reschedule_reason_accept_flag = i2
     2 restricted_actions_bitmask = i4
     2 open_by_default_ind = i2
     2 allow_activate_all_ind = i2
     2 review_required_sig_count = i4
     2 override_mrd_on_plan_ind = i2
     2 linked_phase_ind = i2
   1 planreltnlist[*]
     2 pw_cat_s_id = f8
     2 pw_cat_t_id = f8
     2 type_mean = c12
     2 offset_qty = i4
     2 offset_unit_cd = f8
   1 pwevidencereltnlist[*]
     2 pw_evidence_reltn_id = f8
     2 pathway_catalog_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 pathway_comp_id = f8
     2 type_mean = c12
     2 ref_text_reltn_id = f8
     2 evidence_locator = vc
     2 evidence_sequence = i4
   1 all_facility_ind = i2
   1 facilityflexlist[*]
     2 pathway_catalog_id = f8
     2 facility_cd = f8
     2 display_description = vc
   1 problemdiaglist[*]
     2 pathway_catalog_id = f8
     2 concept_cki = vc
   1 compphasereltnlist[*]
     2 pathway_comp_id = f8
     2 pathway_catalog_id = f8
     2 type_mean = c12
   1 testing_ind = i2
 )
 RECORD add_cat_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD comp_request(
   1 id_count = i2
   1 comp_type_meaning = c12
 )
 RECORD comp_reply(
   1 id_list[*]
     2 id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ids(
   1 list[*]
     2 old = f8
     2 new = f8
 )
 RECORD pathway_cat_id(
   1 list[*]
     2 old = f8
     2 new = f8
 )
 FREE RECORD request_dosecalc
 RECORD request_dosecalc(
   1 orderables[*]
     2 synonym_id = f8
     2 pathway_comp_id = f8
     2 facility_cd = f8
     2 retrieve_all_facility_data = i2
 )
 FREE RECORD reply_dosecalc
 RECORD reply_dosecalc(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 dosecalc_default_methods[*]
     2 synonym_id = f8
     2 pathway_comp_id = f8
     2 dosecalc_default_method_reltn[*]
       3 facility_cd = f8
       3 dosecalc_default_method_pair[*]
         4 method_cd = f8
         4 method_mean = vc
 )
 SET cstatus = load_plan_catalog(request->pathway_catalog_id)
 IF (cstatus="F")
  CALL report_failure("SELECT","F","DCP_VERSION_PLAN_CATALOG",build(
    "Failed to load reference definition for PW_CAT_ID=",request->pathway_catalog_id))
  GO TO exit_script
 ENDIF
 IF (cnvtdatetime(get_cat_reply->beg_effective_dt_tm)=cnvtdatetime(cerner_end_dt_tm))
  CALL report_failure("VERSION","F","DCP_VERSION_PLAN_CATALOG",build(
    "Cannot version a testing version."))
  GO TO exit_script
 ENDIF
 IF ((request->pathway_catalog_id > 0)
  AND (request->copy_ind=0)
  AND version_to_testing_ind=0)
  IF ((get_cat_reply->type_mean != "CAREPLAN"))
   SET cstatus = inactivate_plan_row(request->pathway_catalog_id)
   IF (cstatus="F")
    CALL report_failure("UPDATE","F","DCP_VERSION_PLAN_CATALOG",build(
      "Failed to inactivate plan.  ID = ",request->pathway_catalog_id))
    GO TO exit_script
   ENDIF
  ENDIF
  FOR (i = 1 TO phasecnt)
   SET cstatus = inactivate_plan_row(get_cat_reply->qual_phase[i].pathway_catalog_id)
   IF (cstatus="F")
    CALL report_failure("UPDATE","F","DCP_VERSION_PLAN_CATALOG",build(
      "Failed to inactivate phase.  ID = ",get_cat_reply->qual_phase[i].pathway_catalog_id))
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 IF ((request->create_new_ind=1))
  SET cstatus = fetch_new_ids(1)
  IF (cstatus="F")
   CALL report_failure("UPDATE","F","DCP_VERSION_PLAN_CATALOG","Failed to retrieve new id's")
   GO TO exit_script
  ENDIF
  SET cstatus = write_plan(1)
  IF (cstatus="F")
   CALL report_failure("UPDATE","F","DCP_VERSION_PLAN_CATALOG","Failed to write new plan definition")
   GO TO exit_script
  ENDIF
  IF (version_to_testing_ind=0)
   SET idcnt = value(size(ids->list,5))
   SET idx = locateval(num,1,idcnt,get_cat_reply->pathway_catalog_id,ids->list[num].old)
   UPDATE  FROM pw_cat_flex pcf
    SET pcf.pathway_catalog_id = ids->list[idx].new, pcf.updt_dt_tm = cnvtdatetime(sysdate), pcf
     .updt_id = reqinfo->updt_id,
     pcf.updt_task = reqinfo->updt_task, pcf.updt_applctx = reqinfo->updt_applctx, pcf.updt_cnt = (
     pcf.updt_cnt+ 1)
    WHERE (pcf.pathway_catalog_id=get_cat_reply->pathway_catalog_id)
   ;end update
   UPDATE  FROM alt_sel_list asl
    SET asl.pathway_catalog_id = ids->list[idx].new, asl.updt_dt_tm = cnvtdatetime(sysdate), asl
     .updt_id = reqinfo->updt_id,
     asl.updt_task = reqinfo->updt_task, asl.updt_applctx = reqinfo->updt_applctx, asl.updt_cnt = (
     asl.updt_cnt+ 1)
    WHERE (asl.pathway_catalog_id=get_cat_reply->pathway_catalog_id)
   ;end update
   UPDATE  FROM pw_cat_synonym pcs
    SET pcs.pathway_catalog_id = ids->list[idx].new, pcs.updt_dt_tm = cnvtdatetime(sysdate), pcs
     .updt_id = reqinfo->updt_id,
     pcs.updt_task = reqinfo->updt_task, pcs.updt_applctx = reqinfo->updt_applctx, pcs.updt_cnt = (
     pcs.updt_cnt+ 1)
    WHERE (pcs.pathway_catalog_id=get_cat_reply->pathway_catalog_id)
   ;end update
   SELECT INTO "n1:"
    FROM pw_pt_reltn ppr
    WHERE (ppr.pathway_catalog_id=get_cat_reply->pathway_catalog_id)
     AND ppr.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND ppr.active_ind=1
    DETAIL
     pw_pt_reltn_copy->active_ind = ppr.active_ind, pw_pt_reltn_copy->beg_effective_dt_tm = ppr
     .beg_effective_dt_tm, pw_pt_reltn_copy->end_effective_dt_tm = ppr.end_effective_dt_tm,
     pw_pt_reltn_copy->minimum_enrollment_status_flag = ppr.minimum_enrollment_status_flag,
     pw_pt_reltn_copy->ordering_policy_flag = ppr.ordering_policy_flag, pw_pt_reltn_copy->
     pathway_catalog_id = ppr.pathway_catalog_id,
     pw_pt_reltn_copy->prev_pw_pt_reltn_id = ppr.prev_pw_pt_reltn_id, pw_pt_reltn_copy->
     prot_master_id = ppr.prot_master_id, pw_pt_reltn_copy->pw_pt_reltn_id = ppr.pw_pt_reltn_id,
     pw_pt_reltn_copy->require_override_reason_ind = ppr.require_override_reason_ind,
     pw_pt_reltn_copy->sequence = ppr.sequence
    WITH nocounter
   ;end select
   IF (curqual > 0)
    INSERT  FROM pw_pt_reltn ppr
     SET ppr.pw_pt_reltn_id = seq(reference_seq,nextval), ppr.prev_pw_pt_reltn_id = pw_pt_reltn_copy
      ->pw_pt_reltn_id, ppr.prot_master_id = pw_pt_reltn_copy->prot_master_id,
      ppr.pathway_catalog_id = pw_pt_reltn_copy->pathway_catalog_id, ppr.end_effective_dt_tm =
      cnvtdatetime(sysdate), ppr.active_ind = pw_pt_reltn_copy->active_ind,
      ppr.beg_effective_dt_tm = cnvtdatetime(pw_pt_reltn_copy->beg_effective_dt_tm), ppr
      .minimum_enrollment_status_flag = pw_pt_reltn_copy->minimum_enrollment_status_flag, ppr
      .ordering_policy_flag = pw_pt_reltn_copy->ordering_policy_flag,
      ppr.require_override_reason_ind = pw_pt_reltn_copy->require_override_reason_ind, ppr.sequence
       = pw_pt_reltn_copy->sequence, ppr.updt_applctx = reqinfo->updt_applctx,
      ppr.updt_cnt = 0, ppr.updt_dt_tm = cnvtdatetime(sysdate), ppr.updt_id = reqinfo->updt_id,
      ppr.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    UPDATE  FROM pw_pt_reltn ppr
     SET ppr.pathway_catalog_id = ids->list[idx].new, ppr.beg_effective_dt_tm = cnvtdatetime(sysdate),
      ppr.updt_dt_tm = cnvtdatetime(sysdate),
      ppr.updt_id = reqinfo->updt_id, ppr.updt_task = reqinfo->updt_task, ppr.updt_applctx = reqinfo
      ->updt_applctx,
      ppr.updt_cnt = (ppr.updt_cnt+ 1)
     WHERE (ppr.pw_pt_reltn_id=pw_pt_reltn_copy->pw_pt_reltn_id)
    ;end update
   ENDIF
   IF ((get_cat_reply->sub_phase_ind=1))
    SET cstatus = update_parent_plans(1)
    IF (cstatus="F")
     CALL report_failure("UPDATE","F","DCP_VERSION_PLAN_CATALOG",
      "Failed to update parent plans for sub phase")
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE (load_plan_catalog(id=f8) =c1)
   SET modify = nopredeclare
   SET get_cat_request->pathway_catalog_id = id
   SET get_cat_request->facility_cd = 0
   SET get_cat_request->skip_sub_phase_ind = 1
   SET get_cat_request->active_version_ind = 0
   EXECUTE dcp_get_plan_cat_detail  WITH replace("REQUEST","GET_CAT_REQUEST"), replace("REPLY",
    "GET_CAT_REPLY")
   SET modify = predeclare
   IF ((get_cat_reply->status_data.status="S"))
    SET phasecnt = value(size(get_cat_reply->qual_phase,5))
    SET new_version_number = (get_cat_reply->version+ 1)
    SET reply->version_number = new_version_number
    RETURN("S")
   ELSE
    RETURN("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE (inactivate_plan_row(id=f8) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE pw_updt_cnt = i4 WITH protect, noconstant(0)
   DECLARE version_id = f8 WITH protect, noconstant(0.0)
   DECLARE typemean = vc WITH protect, noconstant
   SET typemean = fillstring(12," ")
   SELECT INTO "nl:"
    pc.*
    FROM pathway_catalog pc
    WHERE pc.pathway_catalog_id=id
    HEAD REPORT
     pw_updt_cnt = pc.updt_cnt, typemean = pc.type_mean, version_id = pc.version_pw_cat_id
    WITH forupdate(pc), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_VERSION_PLAN_CATALOG",build(
      "Failed to get a lock on PATHWAY_CATALOG for PW_CAT_ID=",id))
    RETURN("F")
   ENDIF
   IF ((pw_updt_cnt != request->updt_cnt)
    AND ((typemean="CAREPLAN") OR (typemean="PATHWAY")) )
    CALL report_failure("UPDATE","F","DCP_VERSION_PLAN_CATALOG",build(
      "Unable to version PATHWAY_CATALOG table.  Row was changed by another user. PW_CAT_ID=",id))
    RETURN("F")
   ENDIF
   UPDATE  FROM pathway_catalog pc
    SET pc.active_ind = 0, pc.end_effective_dt_tm = cnvtdatetime(sysdate), pc.version_pw_cat_id =
     IF (version_id=0
      AND ((typemean="CAREPLAN") OR (typemean="PATHWAY")) ) pc.pathway_catalog_id
     ELSE pc.version_pw_cat_id
     ENDIF
     ,
     pc.updt_dt_tm = cnvtdatetime(sysdate), pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->
     updt_task,
     pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc.updt_cnt+ 1)
    WHERE pc.pathway_catalog_id=id
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_VERSION_PLAN_CATALOG",build(
      "Unable to increment version on PATHWAY_CATALOG.  PW_CAT_ID=",id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (fetch_new_ids(dummy=i2) =c1)
   DECLARE newidcnt = i4 WITH noconstant(0), private
   DECLARE ipc = i4 WITH noconstant(0), private
   IF ((get_cat_reply->type_mean="PATHWAY"))
    SET idcnt = 1
    SET stat = alterlist(ids->list,idcnt)
    SET stat = alterlist(pathway_cat_id->list,idcnt)
    SET ids->list[idcnt].old = get_cat_reply->pathway_catalog_id
    SET pathway_cat_id->list[idcnt].old = get_cat_reply->pathway_catalog_id
   ENDIF
   SET idcnt += phasecnt
   SET stat = alterlist(ids->list,idcnt)
   SET stat = alterlist(pathway_cat_id->list,idcnt)
   FOR (i = 1 TO phasecnt)
     IF ((get_cat_reply->type_mean="PATHWAY"))
      SET ids->list[(i+ 1)].old = get_cat_reply->qual_phase[i].pathway_catalog_id
      SET pathway_cat_id->list[(i+ 1)].old = get_cat_reply->qual_phase[i].pathway_catalog_id
     ELSE
      SET ids->list[i].old = get_cat_reply->qual_phase[i].pathway_catalog_id
      SET pathway_cat_id->list[i].old = get_cat_reply->qual_phase[i].pathway_catalog_id
     ENDIF
   ENDFOR
   SET compcnt = 0
   FOR (i = 1 TO phasecnt)
     SET compcnt = value(size(get_cat_reply->qual_phase[i].qual_component,5))
     SET stat = alterlist(ids->list,(idcnt+ compcnt))
     FOR (j = 1 TO compcnt)
       SET ids->list[(idcnt+ j)].old = get_cat_reply->qual_phase[i].qual_component[j].pathway_comp_id
     ENDFOR
     SET idcnt += compcnt
     SET groupcnt = value(size(get_cat_reply->qual_phase[i].compgrouplist,5))
     SET stat = alterlist(ids->list,(idcnt+ groupcnt))
     FOR (k = 1 TO groupcnt)
       SET ids->list[(idcnt+ k)].old = get_cat_reply->qual_phase[i].compgrouplist[k].pw_comp_group_id
     ENDFOR
     SET idcnt += groupcnt
   ENDFOR
   SET evdcnt = value(size(get_cat_reply->planevidencelist,5))
   SET stat = alterlist(ids->list,(idcnt+ evdcnt))
   FOR (i = 1 TO evdcnt)
     SET ids->list[(idcnt+ i)].old = get_cat_reply->planevidencelist[i].pw_evidence_reltn_id
   ENDFOR
   SET idcnt += evdcnt
   SET comp_request->id_count = value(size(ids->list,5))
   SET modify = nopredeclare
   SET comp_request->comp_type_meaning = "PLAN REF"
   EXECUTE dcp_get_pw_comp_id  WITH replace("REQUEST","COMP_REQUEST"), replace("REPLY","COMP_REPLY")
   SET modify = predeclare
   SET newidcnt = value(size(comp_reply->id_list,5))
   IF (((newidcnt=0) OR (newidcnt != idcnt)) )
    RETURN("F")
   ENDIF
   SET ipc = value(size(pathway_cat_id->list,5))
   FOR (num = 1 TO idcnt)
    SET ids->list[num].new = comp_reply->id_list[num].id
    IF (num <= ipc)
     SET pathway_cat_id->list[num].new = comp_reply->id_list[num].id
    ENDIF
   ENDFOR
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (write_plan(dummy=i2) =c1)
   IF ((get_cat_reply->type_mean="CAREPLAN"))
    SET stat = alterlist(add_cat_request->planlist,phasecnt)
   ELSE
    SET stat = alterlist(add_cat_request->planlist,(phasecnt+ 1))
   ENDIF
   SET num = 0
   SET idx = locateval(num,1,idcnt,get_cat_reply->pathway_catalog_id,ids->list[num].old)
   SET add_cat_request->planlist[1].pathway_catalog_id = ids->list[idx].new
   SET reply->pathway_catalog_id = ids->list[idx].new
   SET add_cat_request->planlist[1].type_mean = get_cat_reply->type_mean
   SET add_cat_request->planlist[1].active_ind = get_cat_reply->active_ind
   SET add_cat_request->planlist[1].cross_encntr_ind = get_cat_reply->cross_encntr_ind
   SET add_cat_request->planlist[1].description = get_cat_reply->description
   SET add_cat_request->planlist[1].comment_text = trim(get_cat_reply->long_text)
   SET add_cat_request->planlist[1].duration_qty = 0
   SET add_cat_request->planlist[1].duration_unit_cd = 0
   SET add_cat_request->planlist[1].pathway_type_cd = get_cat_reply->pathway_type_cd
   SET add_cat_request->planlist[1].display_method_cd = get_cat_reply->display_method_cd
   SET add_cat_request->planlist[1].version = new_version_number
   IF ((get_cat_reply->version_pw_cat_id > 0))
    SET add_cat_request->planlist[1].version_pw_cat_id = get_cat_reply->version_pw_cat_id
   ELSE
    SET add_cat_request->planlist[1].version_pw_cat_id = get_cat_reply->pathway_catalog_id
   ENDIF
   SET add_cat_request->planlist[1].display_description = get_cat_reply->display_description
   IF ((get_cat_reply->type_mean="CAREPLAN"))
    SET add_cat_request->planlist[1].duration_qty = get_cat_reply->qual_phase[1].duration_qty
    SET add_cat_request->planlist[1].duration_unit_cd = get_cat_reply->qual_phase[1].duration_unit_cd
    SET add_cat_request->planlist[1].auto_initiate_ind = get_cat_reply->qual_phase[1].
    auto_initiate_ind
    SET add_cat_request->planlist[1].alerts_on_plan_ind = get_cat_reply->qual_phase[1].
    alerts_on_plan_ind
    SET add_cat_request->planlist[1].alerts_on_plan_upd_ind = get_cat_reply->qual_phase[1].
    alerts_on_plan_upd_ind
    SET add_cat_request->planlist[1].default_action_inpt_future_cd = get_cat_reply->qual_phase[1].
    default_action_inpt_future_cd
    SET add_cat_request->planlist[1].default_action_inpt_now_cd = get_cat_reply->qual_phase[1].
    default_action_inpt_now_cd
    SET add_cat_request->planlist[1].default_action_outpt_future_cd = get_cat_reply->qual_phase[1].
    default_action_outpt_future_cd
    SET add_cat_request->planlist[1].default_action_outpt_now_cd = get_cat_reply->qual_phase[1].
    default_action_outpt_now_cd
    SET add_cat_request->planlist[1].optional_ind = get_cat_reply->qual_phase[1].optional_ind
    SET add_cat_request->planlist[1].future_ind = get_cat_reply->qual_phase[1].future_ind
    SET add_cat_request->planlist[1].route_for_review_ind = get_cat_reply->qual_phase[1].
    route_for_review_ind
    SET add_cat_request->planlist[1].pathway_class_cd = get_cat_reply->qual_phase[1].pathway_class_cd
    SET add_cat_request->planlist[1].period_nbr = get_cat_reply->qual_phase[1].period_nbr
    SET add_cat_request->planlist[1].period_custom_label = trim(get_cat_reply->qual_phase[1].
     period_custom_label)
    SET add_cat_request->planlist[1].default_start_time_txt = trim(get_cat_reply->qual_phase[1].
     default_start_time_txt)
    SET add_cat_request->planlist[1].primary_ind = get_cat_reply->qual_phase[1].primary_ind
    SET add_cat_request->planlist[1].uuid = trim(get_cat_reply->qual_phase[1].uuid)
    SET add_cat_request->planlist[1].reschedule_reason_accept_flag = get_cat_reply->qual_phase[1].
    reschedule_reason_accept_flag
    SET add_cat_request->planlist[1].open_by_default_ind = get_cat_reply->qual_phase[1].
    open_by_default_ind
    SET add_cat_request->planlist[1].allow_activate_all_ind = get_cat_reply->qual_phase[1].
    allow_activate_all_ind
    SET add_cat_request->planlist[1].review_required_sig_count = get_cat_reply->qual_phase[1].
    review_required_sig_count
    SET add_cat_request->planlist[1].linked_phase_ind = get_cat_reply->qual_phase[1].linked_phase_ind
    SET phsreltncnt = value(size(get_cat_reply->qual_phase[1].qual_phase_reltn,5))
    IF (phsreltncnt > 0)
     SET stat = alterlist(add_cat_request->planreltnlist,phsreltncnt)
     FOR (j = 1 TO phsreltncnt)
       IF ((get_cat_reply->qual_phase[1].qual_phase_reltn[j].type_mean="SUBPHASE"))
        SET phsreltnidx += 1
        SET add_cat_request->planreltnlist[phsreltnidx].pw_cat_s_id = ids->list[idx].new
        SET add_cat_request->planreltnlist[phsreltnidx].type_mean = get_cat_reply->qual_phase[1].
        qual_phase_reltn[j].type_mean
        SET add_cat_request->planreltnlist[phsreltnidx].pw_cat_t_id = get_cat_reply->qual_phase[1].
        qual_phase_reltn[j].pw_cat_t_id
       ENDIF
     ENDFOR
     SET stat = alterlist(add_cat_request->planreltnlist,phsreltnidx)
    ENDIF
   ENDIF
   SET add_cat_request->planlist[1].sub_phase_ind = get_cat_reply->sub_phase_ind
   SET add_cat_request->planlist[1].hide_flexed_comp_ind = get_cat_reply->hide_flexed_comp_ind
   SET add_cat_request->planlist[1].cycle_ind = get_cat_reply->cycle_ind
   SET add_cat_request->planlist[1].standard_cycle_nbr = get_cat_reply->standard_cycle_nbr
   SET add_cat_request->planlist[1].default_view_mean = get_cat_reply->default_view_mean
   SET add_cat_request->planlist[1].diagnosis_capture_ind = get_cat_reply->diagnosis_capture_ind
   SET add_cat_request->planlist[1].provider_prompt_ind = get_cat_reply->provider_prompt_ind
   SET add_cat_request->planlist[1].allow_copy_forward_ind = get_cat_reply->allow_copy_forward_ind
   SET add_cat_request->planlist[1].cycle_begin_nbr = get_cat_reply->cycle_begin_nbr
   SET add_cat_request->planlist[1].cycle_end_nbr = get_cat_reply->cycle_end_nbr
   SET add_cat_request->planlist[1].cycle_label_cd = get_cat_reply->cycle_label_cd
   SET add_cat_request->planlist[1].cycle_display_end_ind = get_cat_reply->cycle_display_end_ind
   SET add_cat_request->planlist[1].cycle_lock_end_ind = get_cat_reply->cycle_lock_end_ind
   SET add_cat_request->planlist[1].cycle_increment_nbr = get_cat_reply->cycle_increment_nbr
   SET add_cat_request->planlist[1].restricted_actions_bitmask = get_cat_reply->
   restricted_actions_bitmask
   SET add_cat_request->planlist[1].open_by_default_ind = get_cat_reply->open_by_default_ind
   SET add_cat_request->planlist[1].override_mrd_on_plan_ind = get_cat_reply->
   override_mrd_on_plan_ind
   SET add_cat_request->planlist[1].default_visit_type_flag = get_cat_reply->default_visit_type_flag
   SET add_cat_request->planlist[1].prompt_on_selection_ind = get_cat_reply->prompt_on_selection_ind
   SET add_cat_request->planlist[1].pathway_class_cd = get_cat_reply->pathway_class_cd
   SET add_cat_request->planlist[1].uuid = trim(get_cat_reply->uuid)
   SET add_cat_request->testing_ind = version_to_testing_ind
   SET indxref = get_cat_reply->ref_text_ind
   SET irefidcp = get_cat_reply->care_plan_ref_text_id
   SET irefidpe = get_cat_reply->pat_ed_ref_text_id
   IF (indxref > 0.0
    AND irefidcp > 0.0)
    CALL add_reference_text(i,irefidcp,get_cat_reply->pathway_catalog_id)
   ENDIF
   IF (indxref > 0.0
    AND irefidpe > 0.0)
    CALL add_reference_text(i,irefidpe,get_cat_reply->pathway_catalog_id)
   ENDIF
   IF ((get_cat_reply->type_mean="PATHWAY"))
    SET addphaseidx = 2
   ELSE
    SET addphaseidx = 1
   ENDIF
   FOR (i = 1 TO phasecnt)
     SET compcnt = value(size(get_cat_reply->qual_phase[i].qual_component,5))
     IF ((get_cat_reply->qual_phase[i].type_mean != "CAREPLAN"))
      CALL add_phase_data(addphaseidx,i)
      SET indxref = get_cat_reply->qual_phase[i].ref_text_ind
      SET irefidcp = get_cat_reply->qual_phase[i].care_plan_ref_text_id
      SET irefidpe = get_cat_reply->qual_phase[i].pat_ed_ref_text_id
      IF (indxref > 0.0
       AND irefidcp > 0.0)
       CALL add_reference_text(i,irefidcp,get_cat_reply->qual_phase[i].pathway_catalog_id)
      ENDIF
      IF (indxref > 0.0
       AND irefidpe > 0.0)
       CALL add_reference_text(i,irefidpe,get_cat_reply->qual_phase[i].pathway_catalog_id)
      ENDIF
     ENDIF
     IF (compcnt > 0)
      CALL add_phase_component_data(addphaseidx,i)
     ENDIF
     FOR (compphasereltnidx = 1 TO size(get_cat_reply->qual_phase[i].treatment_linked_comp_list,5))
       CALL add_component_phase_reltn(get_cat_reply->qual_phase[i].treatment_linked_comp_list[
        compphasereltnidx].pathway_comp_id,get_cat_reply->qual_phase[i].pathway_catalog_id,"DOT")
     ENDFOR
     SET addphaseidx += 1
   ENDFOR
   SET evdcnt = value(size(get_cat_reply->planevidencelist,5))
   SET stat = alterlist(add_cat_request->pwevidencereltnlist,evdcnt)
   FOR (i = 1 TO evdcnt)
     CALL add_evidence_data(i)
   ENDFOR
   SET problemdiagcnt = value(size(get_cat_reply->problemdiaglist,5))
   SET stat = alterlist(add_cat_request->problemdiaglist,problemdiagcnt)
   FOR (i = 1 TO problemdiagcnt)
     CALL add_problem_diagnosis(i)
   ENDFOR
   SET compphasereltncnt = value(size(get_cat_reply->compphasereltnlist,5))
   FOR (i = 1 TO compphasereltncnt)
     IF ((get_cat_reply->compphasereltnlist[i].type_mean != "DOT"))
      CALL add_component_phase_reltn(get_cat_reply->compphasereltnlist[i].pathway_comp_id,
       get_cat_reply->compphasereltnlist[i].pathway_catalog_id,get_cat_reply->compphasereltnlist[i].
       type_mean)
     ENDIF
   ENDFOR
   IF (version_to_testing_ind=1)
    CALL add_facility_flexing(1)
   ENDIF
   SET modify = nopredeclare
   EXECUTE dcp_add_plan_catalog  WITH replace("REQUEST","ADD_CAT_REQUEST"), replace("REPLY",
    "ADD_CAT_REPLY")
   SET modify = predeclare
   IF ((add_cat_reply->status_data.status="S"))
    RETURN("S")
   ELSE
    RETURN("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_evidence_data(idxc=i4) =null)
   DECLARE new_rtr_id = f8 WITH noconstant(0.0), protect
   IF ((get_cat_reply->planevidencelist[idxc].evidence_type_mean="REFTEXT"))
    SET cstatus = process_ref_text_reltns(get_cat_reply->planevidencelist[idxc].pw_evidence_reltn_id,
     new_rtr_id)
    IF (cstatus="F")
     CALL report_failure("UPDATE","F","DCP_VERSION_PLAN_CATALOG",build(
       "Failed to version ref text reltn.  Evidence Reltn ID = ",get_cat_reply->planevidencelist[idxc
       ].pw_evidence_reltn_id))
     GO TO exit_script
    ENDIF
   ENDIF
   SET num = 0
   SET idx = locateval(num,1,idcnt,get_cat_reply->planevidencelist[idxc].pathway_catalog_id,ids->
    list[num].old)
   SET add_cat_request->pwevidencereltnlist[idxc].pathway_catalog_id = ids->list[idx].new
   SET num = 0
   SET idx = locateval(num,1,idcnt,get_cat_reply->planevidencelist[idxc].pw_evidence_reltn_id,ids->
    list[num].old)
   SET add_cat_request->pwevidencereltnlist[idxc].pw_evidence_reltn_id = ids->list[idx].new
   SET add_cat_request->pwevidencereltnlist[idxc].ref_text_reltn_id = new_rtr_id
   SET add_cat_request->pwevidencereltnlist[idxc].type_mean = get_cat_reply->planevidencelist[idxc].
   evidence_type_mean
   SET add_cat_request->pwevidencereltnlist[idxc].dcp_clin_cat_cd = get_cat_reply->planevidencelist[
   idxc].dcp_clin_cat_cd
   SET add_cat_request->pwevidencereltnlist[idxc].dcp_clin_sub_cat_cd = get_cat_reply->
   planevidencelist[idxc].dcp_clin_sub_cat_cd
   IF ((get_cat_reply->planevidencelist[idxc].pathway_comp_id > 0))
    SET num = 0
    SET idx = locateval(num,1,idcnt,get_cat_reply->planevidencelist[idxc].pathway_comp_id,ids->list[
     num].old)
    SET add_cat_request->pwevidencereltnlist[idxc].pathway_comp_id = ids->list[idx].new
   ENDIF
   SET add_cat_request->pwevidencereltnlist[idxc].evidence_locator = get_cat_reply->planevidencelist[
   idxc].evidence_locator
   SET add_cat_request->pwevidencereltnlist[idxc].evidence_sequence = get_cat_reply->
   planevidencelist[idxc].evidence_sequence
 END ;Subroutine
 SUBROUTINE (process_ref_text_reltns(id=f8,new_ref_text_reltn_id=f8(ref)) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE refr_text_id = f8 WITH protect, noconstant(0.0)
   DECLARE ref_text_reltn_id = f8 WITH protect, noconstant(0.0)
   DECLARE text_type_cd = f8 WITH protect, noconstant(0.0)
   SET num = 0
   SET idx = locateval(num,1,idcnt,id,ids->list[num].old)
   SELECT INTO "nl:"
    new = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     ref_text_reltn_id = new
    WITH nocounter
   ;end select
   INSERT  FROM ref_text_reltn rtr
    SET rtr.ref_text_reltn_id = ref_text_reltn_id, rtr.parent_entity_name = "PW_EVIDENCE_RELTN", rtr
     .parent_entity_id = ids->list[idx].new,
     rtr.refr_text_id = refr_text_id, rtr.text_type_cd = text_type_cd, rtr.updt_dt_tm = cnvtdatetime(
      sysdate),
     rtr.updt_id = reqinfo->updt_id, rtr.updt_task = reqinfo->updt_task, rtr.updt_applctx = reqinfo->
     updt_applctx,
     rtr.updt_cnt = 0, rtr.beg_effective_dt_tm = cnvtdatetime(sysdate), rtr.end_effective_dt_tm =
     cnvtdatetime("31-DEC-2100 00:00:00.00"),
     rtr.active_ind = 1
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN("F")
   ENDIF
   SET new_ref_text_reltn_id = ref_text_reltn_id
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (add_phase_data(idxa=i4,idxb=i4) =null)
   SET num = 0
   SET idx = locateval(num,1,idcnt,get_cat_reply->qual_phase[idxb].pathway_catalog_id,ids->list[num].
    old)
   SET add_cat_request->planlist[idxa].pathway_catalog_id = ids->list[idx].new
   SET add_cat_request->planlist[idxa].type_mean = get_cat_reply->qual_phase[idxb].type_mean
   SET add_cat_request->planlist[idxa].active_ind = 1
   SET add_cat_request->planlist[idxa].description = get_cat_reply->qual_phase[idxb].description
   SET add_cat_request->planlist[idxa].duration_qty = get_cat_reply->qual_phase[idxb].duration_qty
   SET add_cat_request->planlist[idxa].duration_unit_cd = get_cat_reply->qual_phase[idxb].
   duration_unit_cd
   SET add_cat_request->planlist[idxa].display_method_cd = get_cat_reply->qual_phase[idxb].
   display_method_cd
   SET add_cat_request->planlist[idxa].auto_initiate_ind = get_cat_reply->qual_phase[idxb].
   auto_initiate_ind
   SET add_cat_request->planlist[idxa].alerts_on_plan_ind = get_cat_reply->qual_phase[idxb].
   alerts_on_plan_ind
   SET add_cat_request->planlist[idxa].alerts_on_plan_upd_ind = get_cat_reply->qual_phase[idxb].
   alerts_on_plan_upd_ind
   SET add_cat_request->planlist[idxa].default_action_inpt_future_cd = get_cat_reply->qual_phase[idxb
   ].default_action_inpt_future_cd
   SET add_cat_request->planlist[idxa].default_action_inpt_now_cd = get_cat_reply->qual_phase[idxb].
   default_action_inpt_now_cd
   SET add_cat_request->planlist[idxa].default_action_outpt_future_cd = get_cat_reply->qual_phase[
   idxb].default_action_outpt_future_cd
   SET add_cat_request->planlist[idxa].default_action_outpt_now_cd = get_cat_reply->qual_phase[idxb].
   default_action_outpt_now_cd
   SET add_cat_request->planlist[idxa].optional_ind = get_cat_reply->qual_phase[idxb].optional_ind
   SET add_cat_request->planlist[idxa].future_ind = get_cat_reply->qual_phase[idxb].future_ind
   SET add_cat_request->planlist[idxa].route_for_review_ind = get_cat_reply->qual_phase[idxb].
   route_for_review_ind
   SET add_cat_request->planlist[idxa].pathway_class_cd = get_cat_reply->qual_phase[idxb].
   pathway_class_cd
   SET add_cat_request->planlist[idxa].period_nbr = get_cat_reply->qual_phase[idxb].period_nbr
   SET add_cat_request->planlist[idxa].period_custom_label = trim(get_cat_reply->qual_phase[idxb].
    period_custom_label)
   SET add_cat_request->planlist[idxa].default_start_time_txt = trim(get_cat_reply->qual_phase[idxb].
    default_start_time_txt)
   SET add_cat_request->planlist[idxa].primary_ind = get_cat_reply->qual_phase[idxb].primary_ind
   SET add_cat_request->planlist[idxa].uuid = trim(get_cat_reply->qual_phase[idxb].uuid)
   SET add_cat_request->planlist[idxa].reschedule_reason_accept_flag = get_cat_reply->qual_phase[idxb
   ].reschedule_reason_accept_flag
   SET add_cat_request->planlist[idxa].open_by_default_ind = get_cat_reply->qual_phase[idxb].
   open_by_default_ind
   SET add_cat_request->planlist[idxa].allow_activate_all_ind = get_cat_reply->qual_phase[idxb].
   allow_activate_all_ind
   SET add_cat_request->planlist[idxa].review_required_sig_count = get_cat_reply->qual_phase[idxb].
   review_required_sig_count
   SET add_cat_request->planlist[idxa].linked_phase_ind = get_cat_reply->qual_phase[idxb].
   linked_phase_ind
   SET reltncnt = value(size(add_cat_request->planreltnlist,5))
   IF ((((get_cat_reply->type_mean="CAREPLAN")) OR ((get_cat_reply->qual_phase[idxb].type_mean !=
   "DOT"))) )
    SET reltncnt += 1
    SET stat = alterlist(add_cat_request->planreltnlist,reltncnt)
    SET add_cat_request->planreltnlist[reltncnt].pw_cat_s_id = add_cat_request->planlist[1].
    pathway_catalog_id
    SET add_cat_request->planreltnlist[reltncnt].pw_cat_t_id = add_cat_request->planlist[idxa].
    pathway_catalog_id
    SET add_cat_request->planreltnlist[reltncnt].type_mean = "GROUP"
   ENDIF
   SET phsreltncnt = value(size(get_cat_reply->qual_phase[idxb].qual_phase_reltn,5))
   IF (phsreltncnt > 0)
    SET stat = alterlist(add_cat_request->planreltnlist,(reltncnt+ phsreltncnt))
    FOR (j = 1 TO phsreltncnt)
      SET num = 0
      SET idx = locateval(num,1,idcnt,get_cat_reply->qual_phase[idxb].qual_phase_reltn[j].pw_cat_s_id,
       ids->list[num].old)
      SET add_cat_request->planreltnlist[(reltncnt+ j)].pw_cat_s_id = ids->list[idx].new
      IF ((get_cat_reply->qual_phase[idxb].qual_phase_reltn[j].type_mean="SUBPHASE"))
       SET add_cat_request->planreltnlist[(reltncnt+ j)].pw_cat_t_id = get_cat_reply->qual_phase[idxb
       ].qual_phase_reltn[j].pw_cat_t_id
      ELSE
       SET num = 0
       SET idx = locateval(num,1,idcnt,get_cat_reply->qual_phase[idxb].qual_phase_reltn[j].
        pw_cat_t_id,ids->list[num].old)
       SET add_cat_request->planreltnlist[(reltncnt+ j)].pw_cat_t_id = ids->list[idx].new
      ENDIF
      SET add_cat_request->planreltnlist[(reltncnt+ j)].type_mean = get_cat_reply->qual_phase[idxb].
      qual_phase_reltn[j].type_mean
      SET add_cat_request->planreltnlist[(reltncnt+ j)].offset_qty = get_cat_reply->qual_phase[idxb].
      qual_phase_reltn[j].offset_qty
      SET add_cat_request->planreltnlist[(reltncnt+ j)].offset_unit_cd = get_cat_reply->qual_phase[
      idxb].qual_phase_reltn[j].offset_unit_cd
    ENDFOR
   ENDIF
   SET tzexceptcnt = value(size(get_cat_reply->qual_phase[idxb].time_zero_exceptions,5))
   IF (tzexceptcnt > 0)
    SET stat = alterlist(add_cat_request->planlist[idxa].compreltnlist,tzexceptcnt)
    FOR (tzexceptidx = 1 TO tzexceptcnt)
      SET num = 0
      SET idx = locateval(num,1,idcnt,get_cat_reply->qual_phase[idxb].time_zero_exceptions[
       tzexceptidx].pw_cat_s_id,ids->list[num].old)
      SET add_cat_request->planlist[idxa].compreltnlist[tzexceptidx].pathway_comp_s_id = ids->list[
      idx].new
      SET num = 0
      SET idx = locateval(num,1,idcnt,get_cat_reply->qual_phase[idxb].time_zero_exceptions[
       tzexceptidx].pw_cat_t_id,ids->list[num].old)
      SET add_cat_request->planlist[idxa].compreltnlist[tzexceptidx].pathway_comp_t_id = ids->list[
      idx].new
      SET add_cat_request->planlist[idxa].compreltnlist[tzexceptidx].type_mean = get_cat_reply->
      qual_phase[idxb].time_zero_exceptions[tzexceptidx].type_mean
      SET add_cat_request->planlist[idxa].compreltnlist[tzexceptidx].offset_quantity = get_cat_reply
      ->qual_phase[idxb].time_zero_exceptions[tzexceptidx].offset_quantity
      SET add_cat_request->planlist[idxa].compreltnlist[tzexceptidx].offset_unit_cd = get_cat_reply->
      qual_phase[idxb].time_zero_exceptions[tzexceptidx].offset_unit_cd
      SET add_cat_request->planlist[idxa].compreltnlist[tzexceptidx].pathway_catalog_id =
      add_cat_request->planlist[idxa].pathway_catalog_id
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_phase_component_data(idxa=i4,idxb=i4) =null)
   DECLARE timezeroind = i2 WITH protect, constant(value(get_cat_reply->qual_phase[idxb].
     time_zero_ind))
   IF (timezeroind > 0)
    DECLARE timezerocompid = f8 WITH protect, noconstant(0.0)
    DECLARE timezerocompidnew = f8 WITH protect, noconstant(0.0)
    DECLARE timezerorcnt = i4 WITH protect, noconstant(0)
    RECORD tzreltns(
      1 list[*]
        2 pathway_comp_s_id = f8
        2 pathway_comp_t_id = f8
        2 offset_quantity = f8
        2 offset_unit_cd = f8
    )
   ENDIF
   SET compcnt = value(size(get_cat_reply->qual_phase[idxb].qual_component,5))
   SET stat = alterlist(add_cat_request->planlist[idxa].complist,compcnt)
   FOR (k = 1 TO compcnt)
     SET num = 0
     SET idx = locateval(num,1,idcnt,get_cat_reply->qual_phase[idxb].qual_component[k].
      pathway_comp_id,ids->list[num].old)
     SET add_cat_request->planlist[idxa].complist[k].pathway_comp_id = ids->list[idx].new
     SET add_cat_request->planlist[idxa].complist[k].sequence = get_cat_reply->qual_phase[idxb].
     qual_component[k].sequence
     SET add_cat_request->planlist[idxa].complist[k].comp_type_cd = get_cat_reply->qual_phase[idxb].
     qual_component[k].comp_type_cd
     SET add_cat_request->planlist[idxa].complist[k].comp_type_mean = uar_get_code_meaning(
      get_cat_reply->qual_phase[idxb].qual_component[k].comp_type_cd)
     SET add_cat_request->planlist[idxa].complist[k].dcp_clin_cat_cd = get_cat_reply->qual_phase[idxb
     ].qual_component[k].dcp_clin_cat_cd
     SET add_cat_request->planlist[idxa].complist[k].dcp_clin_sub_cat_cd = get_cat_reply->qual_phase[
     idxb].qual_component[k].dcp_clin_sub_cat_cd
     SET add_cat_request->planlist[idxa].complist[k].linked_to_tf_ind = get_cat_reply->qual_phase[
     idxb].qual_component[k].linked_to_tf_ind
     SET add_cat_request->planlist[idxa].complist[k].persistent_ind = get_cat_reply->qual_phase[idxb]
     .qual_component[k].persistent_ind
     SET add_cat_request->planlist[idxa].complist[k].required_ind = get_cat_reply->qual_phase[idxb].
     qual_component[k].required_ind
     SET add_cat_request->planlist[idxa].complist[k].include_ind = get_cat_reply->qual_phase[idxb].
     qual_component[k].included_ind
     SET add_cat_request->planlist[idxa].complist[k].comp_text = get_cat_reply->qual_phase[idxb].
     qual_component[k].comp_text
     SET add_cat_request->planlist[idxa].complist[k].synonym_id = get_cat_reply->qual_phase[idxb].
     qual_component[k].synonym_id
     IF ((add_cat_request->planlist[idxa].complist[k].comp_type_mean="RESULT OUTCO"))
      SET add_cat_request->planlist[idxa].complist[k].outcome_catalog_id = get_cat_reply->qual_phase[
      idxb].qual_component[k].parent_entity_id
     ENDIF
     SET add_cat_request->planlist[idxa].complist[k].duration_qty = get_cat_reply->qual_phase[idxb].
     qual_component[k].duration_qty
     SET add_cat_request->planlist[idxa].complist[k].duration_unit_cd = get_cat_reply->qual_phase[
     idxb].qual_component[k].duration_unit_cd
     SET add_cat_request->planlist[idxa].complist[k].target_type_cd = get_cat_reply->qual_phase[idxb]
     .qual_component[k].target_type_cd
     SET add_cat_request->planlist[idxa].complist[k].expand_qty = get_cat_reply->qual_phase[idxb].
     qual_component[k].expand_qty
     SET add_cat_request->planlist[idxa].complist[k].expand_unit_cd = get_cat_reply->qual_phase[idxb]
     .qual_component[k].expand_unit_cd
     SET add_cat_request->planlist[idxa].complist[k].comp_label = get_cat_reply->qual_phase[idxb].
     qual_component[k].comp_label
     SET add_cat_request->planlist[idxa].complist[k].offset_quantity = get_cat_reply->qual_phase[idxb
     ].qual_component[k].offset_quantity
     SET add_cat_request->planlist[idxa].complist[k].offset_unit_cd = get_cat_reply->qual_phase[idxb]
     .qual_component[k].offset_unit_cd
     IF ((add_cat_request->planlist[idxa].complist[k].comp_type_mean="SUBPHASE"))
      SET add_cat_request->planlist[idxa].complist[k].sub_phase_catalog_id = get_cat_reply->
      qual_phase[idxb].qual_component[k].parent_entity_id
     ENDIF
     SET add_cat_request->planlist[idxa].complist[k].cross_phase_group_desc = get_cat_reply->
     qual_phase[idxb].qual_component[k].cross_phase_group_desc
     SET add_cat_request->planlist[idxa].complist[k].cross_phase_group_nbr = get_cat_reply->
     qual_phase[idxb].qual_component[k].cross_phase_group_nbr
     SET add_cat_request->planlist[idxa].complist[k].chemo_ind = get_cat_reply->qual_phase[idxb].
     qual_component[k].chemo_ind
     SET add_cat_request->planlist[idxa].complist[k].chemo_related_ind = get_cat_reply->qual_phase[
     idxb].qual_component[k].chemo_related_ind
     SET add_cat_request->planlist[idxa].complist[k].default_os_ind = get_cat_reply->qual_phase[idxb]
     .qual_component[k].default_os_ind
     SET add_cat_request->planlist[idxa].complist[k].min_tolerance_interval = get_cat_reply->
     qual_phase[idxb].qual_component[k].min_tolerance_interval
     SET add_cat_request->planlist[idxa].complist[k].min_tolerance_interval_unit_cd = get_cat_reply->
     qual_phase[idxb].qual_component[k].min_tolerance_interval_unit_cd
     SET add_cat_request->planlist[idxa].complist[k].uuid = trim(get_cat_reply->qual_phase[idxb].
      qual_component[k].uuid)
     SET add_cat_request->planlist[idxa].complist[k].display_format_xml = get_cat_reply->qual_phase[
     idxb].qual_component[k].display_format_xml
     SET add_cat_request->planlist[idxa].complist[k].lock_target_dose_flag = get_cat_reply->
     qual_phase[idxb].qual_component[k].lock_target_dose_flag
     IF (pw_def_dose_calc_method_table_exists)
      CALL process_dose_calc_methods(idxb,k,idxa)
     ENDIF
     IF (timezeroind > 0)
      IF ((get_cat_reply->qual_phase[idxb].qual_component[k].time_zero_mean="TIMEZERO"))
       SET timezerocompid = get_cat_reply->qual_phase[idxb].qual_component[k].pathway_comp_id
      ELSEIF ((get_cat_reply->qual_phase[idxb].qual_component[k].time_zero_mean="TIMEZEROLINK"))
       SET timezerorcnt = value(size(tzreltns->list,5))
       SET stat = alterlist(tzreltns->list,(timezerorcnt+ 1))
       SET tzreltns->list[(timezerorcnt+ 1)].pathway_comp_t_id = get_cat_reply->qual_phase[idxb].
       qual_component[k].pathway_comp_id
       SET tzreltns->list[(timezerorcnt+ 1)].offset_quantity = get_cat_reply->qual_phase[idxb].
       qual_component[k].time_zero_offset_quantity
       SET tzreltns->list[(timezerorcnt+ 1)].offset_unit_cd = get_cat_reply->qual_phase[idxb].
       qual_component[k].time_zero_offset_unit_cd
      ENDIF
     ENDIF
     CALL process_os_reltns(idxb,k,idxa)
   ENDFOR
   IF (timezeroind > 0)
    SET timezerorcnt = value(size(tzreltns->list,5))
    SET stat = alterlist(add_cat_request->planlist[idxa].compreltnlist,timezerorcnt)
    SET num = 0
    SET idx = locateval(num,1,idcnt,timezerocompid,ids->list[num].old)
    SET timezerocompidnew = ids->list[idx].new
    FOR (l = 1 TO timezerorcnt)
      SET add_cat_request->planlist[idxa].compreltnlist[l].pathway_comp_s_id = timezerocompidnew
      SET num = 0
      SET idx = locateval(num,1,idcnt,tzreltns->list[l].pathway_comp_t_id,ids->list[num].old)
      SET add_cat_request->planlist[idxa].compreltnlist[l].pathway_comp_t_id = ids->list[idx].new
      SET add_cat_request->planlist[idxa].compreltnlist[l].type_mean = "TIMEZERO"
      SET add_cat_request->planlist[idxa].compreltnlist[l].offset_quantity = tzreltns->list[l].
      offset_quantity
      SET add_cat_request->planlist[idxa].compreltnlist[l].offset_unit_cd = tzreltns->list[l].
      offset_unit_cd
      SET add_cat_request->planlist[idxa].compreltnlist[l].pathway_catalog_id = add_cat_request->
      planlist[idxa].pathway_catalog_id
    ENDFOR
   ENDIF
   SET groupcnt = value(size(get_cat_reply->qual_phase[idxb].compgrouplist,5))
   IF (groupcnt > 0)
    SET stat = alterlist(add_cat_request->planlist[idxa].compgrouplist,groupcnt)
    FOR (j = 1 TO groupcnt)
      SET num = 0
      SET idx = locateval(num,1,idcnt,get_cat_reply->qual_phase[idxb].compgrouplist[j].
       pw_comp_group_id,ids->list[num].old)
      SET add_cat_request->planlist[idxa].compgrouplist[j].pw_comp_group_id = ids->list[idx].new
      SET add_cat_request->planlist[idxa].compgrouplist[j].type_mean = get_cat_reply->qual_phase[idxb
      ].compgrouplist[j].type_mean
      SET add_cat_request->planlist[idxa].compgrouplist[j].description = get_cat_reply->qual_phase[
      idxb].compgrouplist[j].description
      SET add_cat_request->planlist[idxa].compgrouplist[j].linking_rule_flag = get_cat_reply->
      qual_phase[idxb].compgrouplist[j].linking_rule_flag
      SET add_cat_request->planlist[idxa].compgrouplist[j].linking_rule_quantity = get_cat_reply->
      qual_phase[idxb].compgrouplist[j].linking_rule_quantity
      SET add_cat_request->planlist[idxa].compgrouplist[j].override_reason_flag = get_cat_reply->
      qual_phase[idxb].compgrouplist[j].override_reason_flag
      SET membercnt = value(size(get_cat_reply->qual_phase[idxb].compgrouplist[j].memberlist,5))
      IF (membercnt > 0)
       SET stat = alterlist(add_cat_request->planlist[idxa].compgrouplist[j].memberlist,membercnt)
       FOR (k = 1 TO membercnt)
         SET num = 0
         SET idx = locateval(num,1,idcnt,get_cat_reply->qual_phase[idxb].compgrouplist[j].memberlist[
          k].pathway_comp_id,ids->list[num].old)
         SET add_cat_request->planlist[idxa].compgrouplist[j].memberlist[k].pathway_comp_id = ids->
         list[idx].new
         SET add_cat_request->planlist[idxa].compgrouplist[j].memberlist[k].comp_seq = get_cat_reply
         ->qual_phase[idxb].compgrouplist[j].memberlist[k].comp_seq
         SET add_cat_request->planlist[idxa].compgrouplist[j].memberlist[k].anchor_component_ind =
         get_cat_reply->qual_phase[idxb].compgrouplist[j].memberlist[k].anchor_component_ind
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (process_os_reltns(lphasefromidx=i4,lcomponentidx=i4,lphasetoidx=i4) =null)
   SET lordersentencecount = size(get_cat_reply->qual_phase[lphasefromidx].qual_component[
    lcomponentidx].qual_order_sentence,5)
   CALL echo("**************************************")
   CALL echo("* PROCESS_OS_RELTNS - BEGIN SUBROUTINE")
   CALL echo("**************************************")
   CALL echo(concat("From phase idx = ",build(lphasefromidx)))
   CALL echo(concat("Component idx = ",build(lcomponentidx)))
   CALL echo(concat("To phase idx = ",build(lphasetoidx)))
   CALL echo(concat("order sentence count = ",build(lordersentencecount)))
   IF (0 < lordersentencecount)
    SET idx = locateval(idx,1,idcnt,get_cat_reply->qual_phase[lphasefromidx].qual_component[
     lcomponentidx].pathway_comp_id,ids->list[idx].old)
    CALL echo("**************************************")
    CALL echo(concat("found idx = ",build(idx)))
    CALL echo(concat("new pathway_comp_id = ",build(ids->list[idx].new)))
    CALL echo(concat("old pathway_comp_id = ",build(ids->list[idx].old)))
    SET copy_os_request->oe_format_id = 0.0
    SET copy_os_request->pathway_comp_id = ids->list[idx].new
    SET stat = alterlist(copy_os_request->qual,lordersentencecount)
    FOR (lordersentenceindex = 1 TO lordersentencecount)
     SET copy_os_request->qual[lordersentenceindex].order_sent_id = get_cat_reply->qual_phase[
     lphasefromidx].qual_component[lcomponentidx].qual_order_sentence[lordersentenceindex].
     order_sentence_id
     SET copy_os_request->qual[lordersentenceindex].order_sent_display = get_cat_reply->qual_phase[
     lphasefromidx].qual_component[lcomponentidx].qual_order_sentence[lordersentenceindex].
     order_sentence_display_line
    ENDFOR
    EXECUTE dcp_copy_order_sentence  WITH replace("REQUEST","COPY_OS_REQUEST"), replace("REPLY",
     "COPY_OS_REPLY")
    SET stat = alterlist(copy_os_request->qual,0)
    IF (cnvtupper(copy_os_reply->status_data.status)="F")
     CALL report_failure("SCRIPT","F","DCP_VERSION_PLAN_CATALOG",
      "Call to dcp_copy_order_sentence failed.")
     GO TO exit_script
    ENDIF
    SET lnewordersentencecount = size(copy_os_reply->qual,5)
    IF (lnewordersentencecount != lordersentencecount)
     CALL report_failure("SCRIPT","F","DCP_VERSION_PLAN_CATALOG",concat(
       "Failed to copy all order sentences for old pathway_comp_id = ",build(ids->list[idx].old),".")
      )
     GO TO exit_script
    ENDIF
    SET stat = alterlist(add_cat_request->planlist[lphasetoidx].complist[lcomponentidx].ordsentlist,
     lnewordersentencecount)
    CALL echo("**************************************")
    CALL echo(concat("new order sentence count = ",build(lnewordersentencecount)))
    FOR (lordersentenceindex = 1 TO lnewordersentencecount)
      SET idx = locateval(idx,1,lordersentencecount,copy_os_reply->qual[lordersentenceindex].
       orig_order_sent_id,get_cat_reply->qual_phase[lphasefromidx].qual_component[lcomponentidx].
       qual_order_sentence[idx].order_sentence_id)
      CALL echo("**************************************")
      CALL echo(concat("old order sentence id = ",build(copy_os_reply->qual[lordersentenceindex].
         orig_order_sent_id)))
      CALL echo(concat("old order sentence cat reply index  = ",build(idx)))
      IF (0 < idx)
       SET add_cat_request->planlist[lphasetoidx].complist[lcomponentidx].ordsentlist[
       lordersentenceindex].iv_comp_syn_id = get_cat_reply->qual_phase[lphasefromidx].qual_component[
       lcomponentidx].qual_order_sentence[idx].iv_comp_syn_id
       SET add_cat_request->planlist[lphasetoidx].complist[lcomponentidx].ordsentlist[
       lordersentenceindex].missing_required_ind = get_cat_reply->qual_phase[lphasefromidx].
       qual_component[lcomponentidx].qual_order_sentence[idx].missing_required_ind
       SET add_cat_request->planlist[lphasetoidx].complist[lcomponentidx].ordsentlist[
       lordersentenceindex].applicable_to_patient_ind = get_cat_reply->qual_phase[lphasefromidx].
       qual_component[lcomponentidx].qual_order_sentence[idx].applicable_to_patient_ind
       SET add_cat_request->planlist[lphasetoidx].complist[lcomponentidx].ordsentlist[
       lordersentenceindex].order_sentence_filter_display = get_cat_reply->qual_phase[lphasefromidx].
       qual_component[lcomponentidx].qual_order_sentence[idx].order_sentence_filter_display
       SET add_cat_request->planlist[lphasetoidx].complist[lcomponentidx].ordsentlist[
       lordersentenceindex].order_sentence_seq = get_cat_reply->qual_phase[lphasefromidx].
       qual_component[lcomponentidx].qual_order_sentence[idx].sequence
       SET add_cat_request->planlist[lphasetoidx].complist[lcomponentidx].ordsentlist[
       lordersentenceindex].normalized_dose_unit_ind = copy_os_reply->qual[lordersentenceindex].
       normalized_dose_unit_ind
       SET add_cat_request->planlist[lphasetoidx].complist[lcomponentidx].ordsentlist[
       lordersentenceindex].order_sentence_id = copy_os_reply->qual[lordersentenceindex].
       new_order_sent_id
       CALL echo(concat("new iv_comp_syn_id = ",build(add_cat_request->planlist[lphasetoidx].
          complist[lcomponentidx].ordsentlist[lordersentenceindex].iv_comp_syn_id)))
       CALL echo(concat("new missing_required_ind = ",build(add_cat_request->planlist[lphasetoidx].
          complist[lcomponentidx].ordsentlist[lordersentenceindex].missing_required_ind)))
       CALL echo(concat("new order_sentence_seq = ",build(add_cat_request->planlist[lphasetoidx].
          complist[lcomponentidx].ordsentlist[lordersentenceindex].order_sentence_seq)))
       CALL echo(concat("new normalized_dose_unit_ind = ",build(add_cat_request->planlist[lphasetoidx
          ].complist[lcomponentidx].ordsentlist[lordersentenceindex].normalized_dose_unit_ind)))
       CALL echo(concat("new order_sentence_id = ",build(add_cat_request->planlist[lphasetoidx].
          complist[lcomponentidx].ordsentlist[lordersentenceindex].order_sentence_id)))
       CALL echo(concat("old iv_comp_syn_id = ",build(get_cat_reply->qual_phase[lphasefromidx].
          qual_component[lcomponentidx].qual_order_sentence[idx].iv_comp_syn_id)))
       CALL echo(concat("old missing_required_ind = ",build(get_cat_reply->qual_phase[lphasefromidx].
          qual_component[lcomponentidx].qual_order_sentence[idx].missing_required_ind)))
       CALL echo(concat("old applicable_to_patient_ind = ",build(get_cat_reply->qual_phase[
          lphasefromidx].qual_component[lcomponentidx].qual_order_sentence[idx].
          applicable_to_patient_ind)))
       CALL echo(concat("old order_sentence_filter_display = ",build(get_cat_reply->qual_phase[
          lphasefromidx].qual_component[lcomponentidx].qual_order_sentence[idx].
          order_sentence_filter_display)))
       CALL echo(concat("old order_sentence_seq = ",build(get_cat_reply->qual_phase[lphasefromidx].
          qual_component[lcomponentidx].qual_order_sentence[idx].sequence)))
       CALL echo(concat("old normalized_dose_unit_ind = ",build(get_cat_reply->qual_phase[
          lphasefromidx].qual_component[lcomponentidx].qual_order_sentence[idx].
          normalized_dose_unit_ind)))
       CALL echo(concat("old order_sentence_id = ",build(get_cat_reply->qual_phase[lphasefromidx].
          qual_component[lcomponentidx].qual_order_sentence[idx].order_sentence_id)))
      ENDIF
    ENDFOR
    SET stat = alterlist(copy_os_reply->qual,0)
   ENDIF
   CALL echo("**************************************")
   CALL echo("* PROCESS_OS_RELTNS - END SUBROUTINE")
   CALL echo("**************************************")
 END ;Subroutine
 SUBROUTINE (add_problem_diagnosis(idxd=i4) =null)
   SET num = 0
   SET idx = locateval(num,1,idcnt,get_cat_reply->pathway_catalog_id,ids->list[num].old)
   SET add_cat_request->problemdiaglist[idxd].pathway_catalog_id = ids->list[idx].new
   SET add_cat_request->problemdiaglist[idxd].concept_cki = get_cat_reply->problemdiaglist[idxd].
   concept_cki
 END ;Subroutine
 SUBROUTINE (add_component_phase_reltn(old_comp_id=f8,old_phase_id=f8,type_mean=vc) =null)
   DECLARE cnt = i4 WITH protect, noconstant(value(size(add_cat_request->compphasereltnlist,5)))
   SET cnt += 1
   SET stat = alterlist(add_cat_request->compphasereltnlist,cnt)
   SET idx = locateval(num,1,idcnt,old_comp_id,ids->list[num].old)
   SET add_cat_request->compphasereltnlist[cnt].pathway_comp_id = ids->list[idx].new
   SET idx = locateval(num,1,idcnt,old_phase_id,ids->list[num].old)
   SET add_cat_request->compphasereltnlist[cnt].pathway_catalog_id = ids->list[idx].new
   SET add_cat_request->compphasereltnlist[cnt].type_mean = type_mean
 END ;Subroutine
 SUBROUTINE (update_parent_plans(dummy=i2) =c1)
   RECORD phases(
     1 ids[*]
       2 pathway_catalog_id = f8
   )
   SET oldid = get_cat_reply->pathway_catalog_id
   SET num = 0
   SET idx = locateval(num,1,idcnt,get_cat_reply->pathway_catalog_id,ids->list[num].old)
   SET newid = ids->list[idx].new
   SELECT INTO "nl:"
    FROM pw_cat_reltn pcr1,
     pathway_catalog pwc1
    PLAN (pcr1
     WHERE pcr1.pw_cat_t_id=oldid
      AND pcr1.type_mean="SUBPHASE")
     JOIN (pwc1
     WHERE pwc1.pathway_catalog_id=pcr1.pw_cat_s_id
      AND pwc1.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
    ORDER BY pcr1.pw_cat_s_id
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (cnt > size(phases->ids,5))
      stat = alterlist(phases->ids,(cnt+ 10))
     ENDIF
     phases->ids[cnt].pathway_catalog_id = pwc1.pathway_catalog_id
    FOOT REPORT
     stat = alterlist(phases->ids,cnt)
    WITH nocounter
   ;end select
   SET high = value(size(phases->ids,5))
   IF (high > 0)
    UPDATE  FROM pathway_comp pc
     SET pc.parent_entity_id = newid
     WHERE expand(num,1,high,pc.pathway_catalog_id,phases->ids[num].pathway_catalog_id)
      AND pc.comp_type_cd=subphase
      AND pc.parent_entity_id=oldid
      AND pc.active_ind=1
     WITH nocounter
    ;end update
    UPDATE  FROM pw_cat_reltn pcr
     SET pcr.pw_cat_t_id = newid
     WHERE expand(num,1,high,pcr.pw_cat_s_id,phases->ids[num].pathway_catalog_id)
      AND pcr.type_mean="SUBPHASE"
      AND pcr.pw_cat_t_id=oldid
     WITH nocounter
    ;end update
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
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
 SUBROUTINE add_reference_text(indx,ireftextid,ipwcatalogid)
   DECLARE refr_text_id = f8 WITH protect, noconstant(0.0)
   DECLARE ref_text_reltn_id = f8 WITH protect, noconstant(0.0)
   DECLARE text_type_cd = f8 WITH protect, noconstant(0.0)
   DECLARE y = f8 WITH protect, noconstant(0.0)
   SET y = 0.0
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     y = nextseqnum
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    rtr.*
    FROM ref_text_reltn rtr
    WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
     AND rtr.parent_entity_id=ipwcatalogid
     AND rtr.active_ind=1
     AND rtr.ref_text_reltn_id=ireftextid
    HEAD REPORT
     refr_text_id = rtr.refr_text_id, text_type_cd = rtr.text_type_cd, idx = locateval(num,1,idcnt,
      rtr.parent_entity_id,pathway_cat_id->list[num].old)
    WITH nocounter
   ;end select
   INSERT  FROM ref_text_reltn rtr1
    SET rtr1.ref_text_reltn_id = y, rtr1.parent_entity_name = "PATHWAY_CATALOG", rtr1
     .parent_entity_id = pathway_cat_id->list[idx].new,
     rtr1.refr_text_id = refr_text_id, rtr1.text_type_cd = text_type_cd, rtr1.updt_dt_tm =
     cnvtdatetime(sysdate),
     rtr1.updt_id = reqinfo->updt_id, rtr1.updt_task = reqinfo->updt_task, rtr1.updt_applctx =
     reqinfo->updt_applctx,
     rtr1.updt_cnt = 0, rtr1.beg_effective_dt_tm = cnvtdatetime(sysdate), rtr1.end_effective_dt_tm =
     cnvtdatetime("31-DEC-2100 00:00:00.00"),
     rtr1.active_ind = 1
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE (add_facility_flexing(dummy=i2) =null)
   SELECT INTO "nl:"
    FROM pw_cat_flex pcf
    PLAN (pcf
     WHERE (pcf.pathway_catalog_id=get_cat_reply->pathway_catalog_id))
    HEAD REPORT
     facility_flex_count = 0, facility_flex_size = 0
    DETAIL
     facility_flex_count += 1
     IF (facility_flex_count > facility_flex_size)
      facility_flex_size += 20, stat = alterlist(add_cat_request->facilityflexlist,facility_flex_size
       )
     ENDIF
     add_cat_request->facilityflexlist[facility_flex_count].pathway_catalog_id = add_cat_request->
     planlist[1].pathway_catalog_id, add_cat_request->facilityflexlist[facility_flex_count].
     facility_cd = pcf.parent_entity_id, add_cat_request->facilityflexlist[facility_flex_count].
     display_description = pcf.display_description_key
    FOOT REPORT
     IF (facility_flex_count > 0
      AND facility_flex_count < facility_flex_size)
      stat = alterlist(add_cat_request->facilityflexlist,facility_flex_count)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (process_dose_calc_methods(idxb=i4,k=i4,idxa=i4) =null)
   DECLARE firstidx = i4 WITH protect, noconstant(1)
   DECLARE defmethodsidx = i4 WITH protect, noconstant(0)
   DECLARE defmethodssize = i4 WITH protect, noconstant(0)
   DECLARE methodpairidx = i4 WITH protect, noconstant(0)
   DECLARE methodpaircnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(request_dosecalc->orderables,firstidx)
   SET request_dosecalc->orderables[1].pathway_comp_id = get_cat_reply->qual_phase[idxb].
   qual_component[k].pathway_comp_id
   SET request_dosecalc->orderables[1].facility_cd = 0.0
   SET request_dosecalc->orderables[1].retrieve_all_facility_data = 1
   SET stat = tdbexecute(lpowerchartappid,lorderquerytaskid,lquerydosecalcdefaultmethodsstepid,"REC",
    request_dosecalc,
    "REC",reply_dosecalc)
   IF ((reply_dosecalc->transaction_status.success_ind != 1))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Service ERROR"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "QueryDoseCalcDefaultMethods"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = reply_dosecalc->transaction_status.
    debug_error_message
    GO TO exit_script
   ELSE
    SET defmethodssize = size(reply_dosecalc->dosecalc_default_methods,5)
    IF (defmethodssize > 0)
     FOR (defmethodsidx = 1 TO defmethodssize)
      SET defmethodpairreltncount = size(reply_dosecalc->dosecalc_default_methods[defmethodsidx].
       dosecalc_default_method_reltn,5)
      IF (defmethodpairreltncount > 0)
       SET stat = alterlist(add_cat_request->planlist[idxa].complist[k].qual_defaultmethodpairreltn,
        defmethodpairreltncount)
       FOR (defaultmethodpairreltnidx = 1 TO defmethodpairreltncount)
         SET add_cat_request->planlist[idxa].complist[k].qual_defaultmethodpairreltn[
         defaultmethodpairreltnidx].facility_cd = reply_dosecalc->dosecalc_default_methods[
         defmethodsidx].dosecalc_default_method_reltn[defaultmethodpairreltnidx].facility_cd
         SET methodpaircnt = size(reply_dosecalc->dosecalc_default_methods[defmethodsidx].
          dosecalc_default_method_reltn[defaultmethodpairreltnidx].dosecalc_default_method_pair,5)
         IF (methodpaircnt > 0)
          SET stat = alterlist(add_cat_request->planlist[idxa].complist[k].
           qual_defaultmethodpairreltn[defaultmethodpairreltnidx].qual_methodpair,methodpaircnt)
          FOR (methodpairidx = 1 TO methodpaircnt)
           SET add_cat_request->planlist[idxa].complist[k].qual_defaultmethodpairreltn[
           defaultmethodpairreltnidx].qual_methodpair[methodpairidx].method_mean = reply_dosecalc->
           dosecalc_default_methods[defmethodsidx].dosecalc_default_method_reltn[
           defaultmethodpairreltnidx].dosecalc_default_method_pair[methodpairidx].method_mean
           SET add_cat_request->planlist[idxa].complist[k].qual_defaultmethodpairreltn[
           defaultmethodpairreltnidx].qual_methodpair[methodpairidx].method_cd = reply_dosecalc->
           dosecalc_default_methods[defmethodsidx].dosecalc_default_method_reltn[
           defaultmethodpairreltnidx].dosecalc_default_method_pair[methodpairidx].method_cd
          ENDFOR
         ENDIF
       ENDFOR
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
   SET stat = initrec(request_dosecalc)
   SET stat = initrec(reply_dosecalc)
 END ;Subroutine
#exit_script
 FREE RECORD get_cat_request
 FREE RECORD get_cat_reply
 FREE RECORD add_cat_request
 FREE RECORD add_cat_reply
 FREE RECORD comp_request
 FREE RECORD comp_reply
 FREE RECORD ids
 IF (cfailed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
