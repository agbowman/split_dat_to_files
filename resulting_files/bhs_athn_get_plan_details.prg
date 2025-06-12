CREATE PROGRAM bhs_athn_get_plan_details
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE ordidx = i4 WITH protect, noconstant(0)
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD orequest
 RECORD orequest(
   1 pw_group_nbr = f8
   1 pathway_id = f8
   1 facility_cd = f8
   1 patient_criteria
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 postmenstrual_age_in_days = i4
     2 weight = f8
     2 weight_unit_cd = f8
     2 person_id = f8
 )
 FREE RECORD oreply
 RECORD oreply(
   1 pw_group_nbr = f8
   1 type_mean = vc
   1 pw_group_desc = vc
   1 cross_encntr_ind = i2
   1 version = i4
   1 pathway_catalog_id = f8
   1 pathway_type_cd = f8
   1 pathway_type_disp = vc
   1 pathway_type_mean = vc
   1 pathway_class_cd = f8
   1 pathway_class_disp = vc
   1 pathway_class_mean = vc
   1 display_method_cd = f8
   1 display_method_disp = vc
   1 display_method_mean = vc
   1 cycle_nbr = i4
   1 default_view_mean = vc
   1 diagnosis_capture_ind = i2
   1 chemo_ind = i2
   1 chemo_related_ind = i2
   1 phaselist[*]
     2 pathway_id = f8
     2 encntr_id = f8
     2 pw_status_cd = f8
     2 pw_status_disp = vc
     2 pw_status_mean = vc
     2 description = vc
     2 type_mean = vc
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 duration_unit_disp = vc
     2 duration_unit_mean = vc
     2 started_ind = i2
     2 processing_ind = i2
     2 updt_cnt = i4
     2 start_dt_tm = dq8
     2 calc_end_dt_tm = dq8
     2 pathway_catalog_id = f8
     2 order_dt_tm = dq8
     2 time_zero_ind = i2
     2 start_offset_ind = i2
     2 sub_phase_ind = i2
     2 last_updt_dt_tm = dq8
     2 last_updt_prsnl_name = vc
     2 display_method_cd = f8
     2 display_method_disp = vc
     2 display_method_mean = vc
     2 parent_phase_desc = vc
     2 chemo_ind = i2
     2 chemo_related_ind = i2
     2 facility_access_ind = i2
     2 start_tz = i4
     2 calc_end_tz = i4
     2 order_tz = i4
     2 last_updt_tz = i4
     2 high_alert_ind = i2
     2 high_alert_required_ntfy_ind = i2
     2 complist[*]
       3 act_pw_comp_id = f8
       3 dcp_clin_cat_cd = f8
       3 dcp_clin_cat_disp = vc
       3 dcp_clin_cat_mean = vc
       3 dcp_clin_sub_cat_cd = f8
       3 dcp_clin_sub_cat_disp = vc
       3 dcp_clin_sub_cat_mean = vc
       3 comp_status_cd = f8
       3 comp_status_disp = vc
       3 comp_status_mean = vc
       3 comp_type_cd = f8
       3 comp_type_disp = vc
       3 comp_type_mean = vc
       3 sequence = i4
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 order_status_cd = f8
       3 order_status_disp = vc
       3 order_status_mean = vc
       3 synonym_id = f8
       3 catalog_cd = f8
       3 catalog_disp = vc
       3 catalog_mean = vc
       3 catalog_type_cd = f8
       3 catalog_type_disp = vc
       3 catalog_type_mean = vc
       3 activity_type_cd = f8
       3 activity_type_disp = vc
       3 activity_type_mean = vc
       3 mnemonic = vc
       3 oe_format_id = f8
       3 rx_mask = i4
       3 linked_to_tf_ind = i2
       3 required_ind = i2
       3 included_ind = i2
       3 activated_ind = i2
       3 persistent_ind = i2
       3 comp_text_id = f8
       3 comp_text = vc
       3 order_sentence_id = f8
       3 processing_ind = i2
       3 updt_cnt = i4
       3 pathway_comp_id = f8
       3 offset_quantity = f8
       3 offset_unit_cd = f8
       3 offset_unit_disp = vc
       3 offset_unit_mean = vc
       3 ordsentlist[*]
         4 order_sentence_id = f8
         4 order_sentence_seq = i4
         4 order_sentence_display_line = vc
         4 iv_comp_syn_id = f8
         4 ord_comment_long_text_id = f8
         4 ord_comment_long_text = vc
         4 rx_type_mean = vc
         4 normalized_dose_unit_ind = i2
         4 missing_required_ind = i2
         4 applicable_to_patient_ind = i2
         4 order_sentence_filter_display = vc
         4 plan_order_sentence_type_flag = i2
       3 duration_qty = i4
       3 duration_unit_cd = f8
       3 duration_unit_disp = vc
       3 duration_unit_mean = vc
       3 outcome_catalog_id = f8
       3 outcome_description = vc
       3 outcome_expectation = vc
       3 outcome_type_cd = f8
       3 outcome_type_disp = vc
       3 outcome_type_mean = vc
       3 outcome_status_cd = f8
       3 outcome_status_disp = vc
       3 outcome_status_mean = vc
       3 target_type_cd = f8
       3 target_type_disp = vc
       3 target_type_mean = vc
       3 expand_qty = i4
       3 expand_unit_cd = f8
       3 expand_unit_disp = vc
       3 expand_unit_mean = vc
       3 outcome_start_dt_tm = dq8
       3 outcome_end_dt_tm = dq8
       3 outcome_updt_cnt = i4
       3 outcome_event_cd = f8
       3 time_zero_offset_qty = f8
       3 time_zero_mean = vc
       3 time_zero_offset_unit_cd = f8
       3 time_zero_offset_unit_disp = vc
       3 time_zero_offset_unit_mean = vc
       3 time_zero_active_ind = i2
       3 task_assay_cd = f8
       3 reference_task_id = f8
       3 orderable_type_flag = i2
       3 comp_label = vc
       3 result_type_cd = f8
       3 result_type_disp = vc
       3 result_type_mean = vc
       3 xml_order_detail = vc
       3 long_blob_id = f8
       3 subphase_display = vc
       3 ref_active_ind = i2
       3 ref_prnt_ent_name = vc
       3 ref_prnt_ent_id = f8
       3 cross_phase_group_nbr = f8
       3 cross_phase_group_ind = i2
       3 chemo_ind = i2
       3 chemo_related_ind = i2
       3 ocs_clin_cat_cd = f8
       3 ocs_clin_cat_disp = vc
       3 ocs_clin_cat_mean = vc
       3 single_select_ind = i2
       3 hide_expectation_ind = i2
       3 ref_text_reltn_id = f8
       3 hna_order_mnemonic = vc
       3 cki = vc
       3 ref_text_ind = i2
       3 ref_text_mask = i4
       3 reftext_mask = vc
       3 outcome_start_tz = i4
       3 outcome_end_tz = i4
       3 high_alert_ind = i2
       3 high_alert_required_ntfy_ind = i2
       3 high_alert_text = vc
       3 facility_access_ind = i2
       3 dose_info_hist_blob_id = f8
       3 dose_info_hist_blob = vc
       3 xml_order_detail_blob = gvc
       3 dose_info_hist_blob_text = gvc
       3 missing_required_ind = i2
       3 default_os_ind = i2
       3 intermittent_ind = i2
       3 min_tolerance_interval = i4
       3 min_tolerance_interval_unit_cd = f8
       3 display_format_xml = vc
       3 unlink_start_dt_tm_ind = i2
       3 lock_target_dose_flag = i2
       3 pathway_uuid = vc
       3 copy_forward_exclude_ind = i2
       3 discontinue_type_flag = i2
     2 phasereltnlist[*]
       3 pathway_s_id = f8
       3 pathway_t_id = f8
       3 type_mean = vc
       3 offset_qty = i4
       3 offset_unit_cd = f8
     2 compgrouplist[*]
       3 act_pw_comp_g_id = f8
       3 type_mean = vc
       3 description = vc
       3 memberlist[*]
         4 act_pw_comp_id = f8
         4 pw_comp_seq = i4
         4 included_ind = i2
         4 updt_cnt = i4
         4 anchor_component_ind = i2
       3 linking_rule_flag = i2
       3 linking_rule_quantity = i4
       3 override_reason_flag = i2
     2 included_ind = i2
     2 auto_initiate_ind = i2
     2 alerts_on_plan_ind = i2
     2 alerts_on_plan_upd_ind = i2
     2 ref_text_ind = i2
     2 default_action_inpt_future_cd = f8
     2 default_action_inpt_now_cd = f8
     2 default_action_outpt_future_cd = f8
     2 default_action_outpt_now_cd = f8
     2 optional_ind = i2
     2 future_ind = i2
     2 route_for_review_ind = i2
     2 period_nbr = i4
     2 period_custom_label = vc
     2 treatmentlinkedcomponentlist[*]
       3 act_pw_comp_id = f8
     2 hide_grouped_phases_ind = i2
     2 default_start_time_txt = vc
     2 primary_ind = i2
     2 warning_level_bit = i4
     2 reschedule_reason_accept_flag = i2
     2 componentmodificationlist[*]
       3 act_pw_comp_id = f8
       3 timezerooffsetlist[*]
         4 time_zero_offset_qty = f8
         4 time_zero_mean = vc
         4 time_zero_offset_unit_cd = f8
     2 open_by_default_ind = i2
     2 allow_activate_all_ind = i2
     2 copy_source_pathway_id = f8
     2 total_number_of_components = i4
     2 review_required_sig_count = i4
     2 linked_phase_ind = i2
   1 planevidencelist[*]
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 pathway_comp_id = f8
     2 evidence_type_mean = vc
     2 pw_evidence_reltn_id = f8
     2 evidence_locator = vc
     2 pathway_catalog_id = f8
     2 evidence_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = c100
   1 ref_text_ind = i2
   1 ref_owner_person_id = f8
   1 cycle_label_cd = f8
   1 compphasereltnlist[*]
     2 act_pw_comp_id = f8
     2 pathway_id = f8
     2 type_mean = vc
   1 default_visit_type_flag = i2
   1 prompt_on_selection_ind = i2
   1 pathway_customized_plan_id = f8
   1 pathway_customized_plan_name = vc
   1 pathway_reference_plan_name = vc
   1 open_by_default_ind = i2
   1 restricted_actions_bitmask = i4
   1 override_mrd_on_plan_ind = i2
 )
 FREE RECORD req3200138
 RECORD req3200138(
   1 orders[*]
     2 order_id = f8
   1 person_id = f8
   1 encntr_qual[*]
     2 encntr_id = f8
   1 catalog[*]
     2 catalog_type_cd = f8
   1 orig_ord_as_flag = i2
   1 comment_flag = i2
   1 details_flag = i2
   1 entity_flag = i2
   1 summary_flag = i2
   1 encntr_ind = i2
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 activity[*]
     2 activity_type_cd = f8
   1 status[*]
     2 order_status_cd = f8
   1 mode_flag = i2
   1 dept[*]
     2 dept_status_cd = f8
   1 activity_sub[*]
     2 activity_subtype_cd = f8
   1 event_cd_ind = i2
   1 accession_id = f8
   1 accession = vc
   1 inactive_ind = i2
   1 orig_ord_as_flag_filter[*]
     2 orig_ord_as_flag = i2
 )
 FREE RECORD rep3200138
 RECORD rep3200138(
   1 qual[*]
     2 order_id = f8
     2 order_status_cd = f8
     2 order_status_disp = vc
     2 order_status_mean = vc
 )
 IF (( $2 > 0))
  SET orequest->pathway_id =  $2
 ELSE
  SET orequest->pw_group_nbr =  $3
 ENDIF
 SET orequest->patient_criteria.person_id =  $4
 SET orequest->facility_cd =  $5
 IF (textlen( $6) > 0)
  SET orequest->patient_criteria.birth_dt_tm = cnvtdatetime( $6)
 ENDIF
 IF (( $7 > 0))
  SET orequest->patient_criteria.weight =  $7
  SET orequest->patient_criteria.weight_unit_cd =  $8
 ENDIF
 SET stat = tdbexecute(600005,601540,601544,"REC",orequest,
  "REC",oreply)
 SET order_cnt = 0
 IF ((oreply->status_data.status="S"))
  FOR (j = 1 TO size(oreply->phaselist,5))
    FOR (k = 1 TO size(oreply->phaselist[j].complist,5))
     IF ((oreply->phaselist[j].complist[k].ref_text_mask > 0)
      AND (oreply->phaselist[j].complist[k].ref_text_mask != 16)
      AND (oreply->phaselist[j].complist[k].ref_text_mask != 18)
      AND (oreply->phaselist[j].complist[k].ref_text_mask != 64))
      SET oreply->phaselist[j].complist[k].reftext_mask = "RefTextAvailable"
     ELSE
      SET oreply->phaselist[j].complist[k].reftext_mask = "RefTextNotAvailable"
     ENDIF
     IF ((oreply->phaselist[j].complist[k].parent_entity_name="ORDERS")
      AND (oreply->phaselist[j].complist[k].parent_entity_id > 0))
      SET order_cnt += 1
      SET stat = alterlist(req3200138->orders,order_cnt)
      SET req3200138->orders[order_cnt].order_id = oreply->phaselist[j].complist[k].parent_entity_id
     ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 IF (order_cnt > 0)
  SET req3200138->summary_flag = 1
  SET stat = tdbexecute(3200000,3200081,3200138,"REC",req3200138,
   "REC",rep3200138)
  IF (size(rep3200138->qual,5) > 0)
   FOR (j = 1 TO size(oreply->phaselist,5))
     FOR (k = 1 TO size(oreply->phaselist[j].complist,5))
       IF ((oreply->phaselist[j].complist[k].parent_entity_name="ORDERS")
        AND (oreply->phaselist[j].complist[k].parent_entity_id > 0))
        SET pos = locateval(ordidx,1,size(rep3200138->qual,5),oreply->phaselist[j].complist[k].
         parent_entity_id,rep3200138->qual[ordidx].order_id)
        IF (pos > 0)
         SET oreply->phaselist[j].complist[k].order_status_cd = rep3200138->qual[pos].order_status_cd
         SET oreply->phaselist[j].complist[k].order_status_disp = rep3200138->qual[pos].
         order_status_disp
         SET oreply->phaselist[j].complist[k].order_status_mean = rep3200138->qual[pos].
         order_status_mean
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
  ENDIF
 ENDIF
 SET _memory_reply_string = replace(replace(cnvtrectojson(oreply,0,1),'\"',"'",0),
  '"0000-00-00T00:00:00.000+00:00"',"null",0)
END GO
