CREATE PROGRAM bhs_athn_get_plan_list
 FREE RECORD orequest
 RECORD orequest(
   1 person_id = f8
   1 stale_in_min = i2
   1 phase_look_back_days = i4
   1 comp_look_back_days = i4
   1 querylist[*]
     2 encntr_id = f8
   1 accesslist[*]
     2 encntr_id = f8
   1 facility_cd = f8
   1 load_tapers_only_ind = i2
   1 load_suggested_plans_ind = i2
   1 plantypeincludelist[*]
     2 pathway_type_cd = f8
   1 plantypeexcludelist[*]
     2 pathway_type_cd = f8
   1 skip_component_load_ind = i2
   1 planidincludelist[*]
     2 plan_id = f8
   1 patient_criteria
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 postmenstrual_age_in_days = i4
     2 weight = f8
     2 weight_unit_cd = f8
 )
 FREE RECORD oreply
 RECORD oreply(
   1 pwlist[*]
     2 pw_group_nbr = f8
     2 type_mean = vc
     2 pw_group_desc = vc
     2 cross_encntr_ind = i2
     2 version = i4
     2 newest_version = i4
     2 newest_version_active_ind = i2
     2 newest_version_pw_cat_id = f8
     2 pathway_catalog_id = f8
     2 pathway_type_cd = f8
     2 pathway_type_disp = vc
     2 pathway_type_mean = vc
     2 pathway_class_cd = f8
     2 pathway_class_disp = vc
     2 pathway_class_mean = vc
     2 display_method_cd = f8
     2 display_method_disp = vc
     2 display_method_mean = vc
     2 cycle_nbr = i4
     2 default_view_mean = vc
     2 diagnosis_capture_ind = i2
     2 chemo_ind = i2
     2 chemo_related_ind = i2
     2 allow_copy_forward_ind = i2
     2 ref_owner_person_id = f8
     2 phaselist[*]
       3 pathway_id = f8
       3 encntr_id = f8
       3 pw_status_cd = f8
       3 pw_status_disp = vc
       3 pw_status_mean = vc
       3 description = vc
       3 type_mean = vc
       3 duration_qty = i4
       3 duration_unit_cd = f8
       3 duration_unit_disp = vc
       3 duration_unit_mean = vc
       3 started_ind = i2
       3 processing_ind = i2
       3 updt_cnt = i4
       3 start_dt_tm = dq8
       3 calc_end_dt_tm = dq8
       3 pathway_catalog_id = f8
       3 order_dt_tm = dq8
       3 time_zero_ind = i2
       3 start_offset_ind = i2
       3 sub_phase_ind = i2
       3 last_updt_dt_tm = dq8
       3 last_updt_prsnl_name = vc
       3 display_method_cd = f8
       3 display_method_disp = vc
       3 display_method_mean = vc
       3 parent_phase_desc = vc
       3 chemo_ind = i2
       3 chemo_related_ind = i2
       3 facility_access_ind = i2
       3 start_tz = i4
       3 calc_end_tz = i4
       3 order_tz = i4
       3 last_updt_tz = i4
       3 high_alert_ind = i2
       3 high_alert_required_ntfy_ind = i2
       3 complist[*]
         4 act_pw_comp_id = f8
         4 dcp_clin_cat_cd = f8
         4 dcp_clin_cat_disp = vc
         4 dcp_clin_cat_mean = vc
         4 dcp_clin_sub_cat_cd = f8
         4 dcp_clin_sub_cat_disp = vc
         4 dcp_clin_sub_cat_mean = vc
         4 comp_status_cd = f8
         4 comp_status_disp = vc
         4 comp_status_mean = vc
         4 comp_type_cd = f8
         4 comp_type_disp = vc
         4 comp_type_mean = vc
         4 sequence = i4
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 synonym_id = f8
         4 catalog_cd = f8
         4 catalog_disp = vc
         4 catalog_mean = vc
         4 catalog_type_cd = f8
         4 catalog_type_disp = vc
         4 catalog_type_mean = vc
         4 activity_type_cd = f8
         4 activity_type_disp = vc
         4 activity_type_mean = vc
         4 mnemonic = vc
         4 oe_format_id = f8
         4 rx_mask = i4
         4 linked_to_tf_ind = i2
         4 required_ind = i2
         4 included_ind = i2
         4 activated_ind = i2
         4 persistent_ind = i2
         4 comp_text_id = f8
         4 comp_text = vc
         4 order_sentence_id = f8
         4 processing_ind = i2
         4 updt_cnt = i4
         4 pathway_comp_id = f8
         4 offset_quantity = f8
         4 offset_unit_cd = f8
         4 offset_unit_disp = vc
         4 offset_unit_mean = vc
         4 ordsentlist[*]
           5 order_sentence_id = f8
           5 order_sentence_seq = i4
           5 order_sentence_display_line = vc
           5 iv_comp_syn_id = f8
           5 ord_comment_long_text_id = f8
           5 ord_comment_long_text = vc
           5 rx_type_mean = vc
           5 normalized_dose_unit_ind = i2
           5 missing_required_ind = i2
           5 applicable_to_patient_ind = i2
           5 order_sentence_filter_display = vc
         4 duration_qty = i4
         4 duration_unit_cd = f8
         4 duration_unit_disp = vc
         4 duration_unit_mean = vc
         4 outcome_catalog_id = f8
         4 outcome_description = vc
         4 outcome_expectation = vc
         4 outcome_type_cd = f8
         4 outcome_type_disp = vc
         4 outcome_type_mean = vc
         4 outcome_status_cd = f8
         4 outcome_status_disp = vc
         4 outcome_status_mean = vc
         4 target_type_cd = f8
         4 target_type_disp = vc
         4 target_type_mean = vc
         4 expand_qty = i4
         4 expand_unit_cd = f8
         4 expand_unit_disp = vc
         4 expand_unit_mean = vc
         4 outcome_start_dt_tm = dq8
         4 outcome_end_dt_tm = dq8
         4 outcome_updt_cnt = i4
         4 outcome_event_cd = f8
         4 time_zero_offset_qty = f8
         4 time_zero_mean = vc
         4 time_zero_offset_unit_cd = f8
         4 time_zero_offset_unit_disp = vc
         4 time_zero_offset_unit_mean = vc
         4 time_zero_active_ind = i2
         4 task_assay_cd = f8
         4 reference_task_id = f8
         4 orderable_type_flag = i2
         4 comp_label = vc
         4 result_type_cd = f8
         4 result_type_disp = vc
         4 result_type_mean = vc
         4 xml_order_detail = vc
         4 long_blob_id = f8
         4 subphase_display = vc
         4 ref_prnt_ent_name = vc
         4 ref_prnt_ent_id = f8
         4 cross_phase_group_nbr = f8
         4 cross_phase_group_ind = i2
         4 chemo_ind = i2
         4 chemo_related_ind = i2
         4 ocs_clin_cat_cd = f8
         4 ocs_clin_cat_disp = vc
         4 ocs_clin_cat_mean = vc
         4 single_select_ind = i2
         4 hide_expectation_ind = i2
         4 ref_text_reltn_id = f8
         4 hna_order_mnemonic = vc
         4 cki = vc
         4 ref_text_ind = i2
         4 ref_text_mask = i4
         4 outcome_start_tz = i4
         4 outcome_end_tz = i4
         4 high_alert_ind = i2
         4 high_alert_required_ntfy_ind = i2
         4 high_alert_text = vc
         4 dose_info_hist_blob_id = f8
         4 xml_order_detail_blob = gvc
         4 missing_required_ind = i2
         4 default_os_ind = i2
         4 updt_dt_tm = dq8
         4 intermittent_ind = i2
         4 start_estimated_ind = i2
         4 end_estimated_ind = i2
         4 reject_protocol_review_ind = i2
         4 min_tolerance_interval = i4
         4 min_tolerance_interval_unit_cd = f8
         4 act_pw_comp_group_nbr = f8
         4 display_format_xml = vc
         4 unlink_start_dt_tm_ind = i2
         4 lock_target_dose_flag = i2
         4 discontinue_type_flag = i2
       3 phasereltnlist[*]
         4 pathway_s_id = f8
         4 pathway_t_id = f8
         4 type_mean = vc
         4 offset_qty = i4
         4 offset_unit_cd = f8
       3 compgrouplist[*]
         4 act_pw_comp_g_id = f8
         4 type_mean = vc
         4 description = vc
         4 memberlist[*]
           5 act_pw_comp_id = f8
           5 pw_comp_seq = i4
           5 included_ind = i2
           5 updt_cnt = i4
       3 nomenreltnlist[*]
         4 nomen_entity_reltn_id = f8
         4 nomenclature_id = f8
         4 priority = i4
         4 display = vc
         4 concept_cki = vc
         4 diagnosis_id = f8
         4 diag_type_cd = f8
         4 diag_type_disp = vc
         4 diag_type_mean = vc
         4 active_ind = i2
         4 source_vocab_cd = f8
         4 diagnosis_group = f8
         4 encntr_id = f8
       3 included_ind = i2
       3 alerts_on_plan_ind = i2
       3 alerts_on_plan_upd_ind = i2
       3 actions[*]
         4 action_type_cd = f8
         4 action_type_mean = vc
         4 action_type_disp = vc
         4 action_dt_tm = dq8
         4 action_prsnl_id = f8
         4 action_prsnl_disp = vc
         4 pw_action_seq = i4
         4 pw_status_cd = f8
         4 pw_status_mean = vc
         4 pw_status_disp = vc
         4 action_tz = i4
         4 action_prsnl_credentials[*]
           5 credential_cd = f8
         4 action_prsnl_name_first = vc
         4 action_prsnl_name_last = vc
         4 provider_id = f8
       3 ref_text_ind = i2
       3 scheduled_facility_cd = f8
       3 scheduled_nursing_unit_cd = f8
       3 start_estimated_ind = i2
       3 calc_end_estimated_ind = i2
       3 future_ind = i2
       3 review_status_flag = i2
       3 protocolreviewinfolist[*]
         4 from_prsnl_id = f8
         4 from_prsnl_name_first = vc
         4 from_prsnl_name_last = vc
         4 from_prsnl_credentials[*]
           5 credential_cd = f8
         4 to_prsnl_id = f8
         4 to_prsnl_name_first = vc
         4 to_prsnl_name_last = vc
         4 to_prsnl_credentials[*]
           5 credential_cd = f8
         4 to_prsnl_group_id = f8
         4 review_dt_tm = dq8
         4 review_tz = i4
         4 to_prsnl_group_name = vc
       3 period_nbr = i4
       3 period_custom_label = vc
       3 treatmentlinkedcomponentlist[*]
         4 act_pw_comp_id = f8
       3 hide_grouped_phases_ind = i2
       3 route_for_review_ind = i2
       3 pathway_group_id = f8
       3 processing_status_flag = i2
       3 pathway_missing_reason_flag = i4
       3 warning_level_bit = i4
       3 reschedule_reason_accept_flag = i2
       3 reviewinformationlist[*]
         4 review_type_flag = i2
         4 review_status_flag = i2
         4 review_status_reason_cd = f8
         4 review_status_comment = vc
         4 from_prsnl_id = f8
         4 from_prsnl_name = vc
         4 to_prsnl_id = f8
         4 to_prsnl_name = vc
         4 to_prsnl_group_id = f8
         4 to_prsnl_group_name = vc
         4 notification_dt_tm = dq8
         4 notification_tz = i4
         4 action_prsnl_id = f8
         4 action_prsnl_name = vc
       3 allow_activate_all_ind = i2
       3 copy_source_pathway_id = f8
       3 review_required_sig_count = i4
       3 linked_phase_ind = i2
     2 planevidencelist[*]
       3 dcp_clin_cat_cd = f8
       3 dcp_clin_sub_cat_cd = f8
       3 pathway_comp_id = f8
       3 evidence_type_mean = vc
       3 pw_evidence_reltn_id = f8
       3 evidence_locator = vc
       3 pathway_catalog_id = f8
       3 evidence_sequence = i4
     2 ref_text_ind = i2
     2 cycle_label_cd = f8
     2 compphasereltnlist[*]
       3 act_pw_comp_id = f8
       3 pathway_id = f8
       3 type_mean = vc
     2 cycle_end_nbr = i4
     2 synonym_name = vc
     2 pathway_customized_plan_id = f8
     2 reference_plan_name = vc
     2 reviewinformationlist[*]
       3 review_type_flag = i2
       3 review_status_flag = i2
       3 review_status_reason_cd = f8
       3 review_status_comment = vc
       3 from_prsnl_id = f8
       3 from_prsnl_name = vc
       3 to_prsnl_id = f8
       3 to_prsnl_name = vc
       3 to_prsnl_group_id = f8
       3 to_prsnl_group_name = vc
       3 notification_dt_tm = dq8
       3 notification_tz = i4
       3 action_prsnl_id = f8
       3 action_prsnl_name = vc
     2 restricted_actions_bitmask = i4
     2 override_mrd_on_plan_ind = i2
   1 defaultnomenlist[*]
     2 pathway_catalog_id = f8
     2 nomenclature_id = f8
     2 display = vc
     2 concept_cki = vc
     2 priority = i4
   1 suggestedplanlist[*]
     2 task_id = f8
     2 task_status_cd = f8
     2 task_updt_cnt = i4
     2 pathway_catalog_id = f8
     2 display_description = vc
     2 pathway_type_cd = f8
     2 plan_suggested_dt_tm = dq8
     2 plan_suggested_tz = i4
     2 plan_suggested_reason = vc
     2 pw_evidence_reltn_id = f8
     2 evidence_locator = vc
     2 evidence_type_mean = vc
     2 ref_text_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = c100
 )
 SET orequest->person_id =  $2
 SET stat = alterlist(orequest->querylist,1)
 SET orequest->querylist[1].encntr_id =  $3
 SET stat = alterlist(orequest->accesslist,1)
 SET orequest->accesslist[1].encntr_id =  $3
 SET orequest->facility_cd =  $4
 IF (textlen( $5) > 0)
  SET orequest->patient_criteria.birth_dt_tm = cnvtdatetime( $5)
 ENDIF
 IF (( $6 > 0))
  SET orequest->patient_criteria.weight =  $6
  SET orequest->patient_criteria.weight_unit_cd =  $7
 ENDIF
 IF (( $8=1))
  SET orequest->skip_component_load_ind = 0
 ELSE
  SET orequest->skip_component_load_ind = 1
 ENDIF
 SET stat = tdbexecute(600005,601100,601541,"REC",orequest,
  "REC",oreply)
 IF ((oreply->status_data.status="S"))
  FOR (i = 1 TO size(oreply->pwlist,5))
    FOR (j = 1 TO size(oreply->pwlist[i].phaselist,5))
      FOR (k = 1 TO size(oreply->pwlist[i].phaselist[j].actions,5))
        SET oreply->pwlist[i].phaselist[j].actions[k].action_type_disp = uar_get_code_display(oreply
         ->pwlist[i].phaselist[j].actions[k].action_type_cd)
        SET oreply->pwlist[i].phaselist[j].actions[k].action_type_mean = uar_get_code_meaning(oreply
         ->pwlist[i].phaselist[j].actions[k].action_type_cd)
        SET oreply->pwlist[i].phaselist[j].actions[k].pw_status_disp = uar_get_code_display(oreply->
         pwlist[i].phaselist[j].actions[k].pw_status_cd)
        SET oreply->pwlist[i].phaselist[j].actions[k].pw_status_mean = uar_get_code_meaning(oreply->
         pwlist[i].phaselist[j].actions[k].pw_status_cd)
      ENDFOR
    ENDFOR
  ENDFOR
 ENDIF
 SET _memory_reply_string = replace(replace(cnvtrectojson(oreply,0,1),'\"',"'",0),
  '"0000-00-00T00:00:00.000+00:00"',"null",0)
END GO
