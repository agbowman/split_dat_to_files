CREATE PROGRAM bhs_athn_sign_document
 FREE RECORD result
 RECORD result(
   1 forwarded_ind = i2
   1 action_comment = vc
   1 person_id = f8
   1 encntr_id = f8
   1 event_cd = f8
   1 event_class_cd = f8
   1 prev_event_title_text = vc
   1 doc_status_cd = f8
   1 encntr_prsnl_r_cd = f8
   1 view_level = i4
   1 contributor_system_cd = f8
   1 parent_event_id = f8
   1 event_reltn_cd = f8
   1 event_end_dt_tm = dq8
   1 record_status_cd = f8
   1 authentic_flag = i2
   1 publish_flag = i2
   1 valid_until_dt_tm = dq8
   1 valid_from_dt_tm = dq8
   1 performed_dt_tm = dq8
   1 event_end_tz = i4
   1 event_title_text = vc
   1 collating_seq = vc
   1 entry_mode_cd = f8
   1 scd_story_id = f8
   1 facility_cd = f8
   1 update_lock_dt_tm = dq8
   1 ce_updt_cnt = i4
   1 contributions[*]
     2 lock_user_id = f8
     2 lock_user = vc
     2 lock_dt_tm = dq8
     2 dd_session_id = f8
     2 dd_contribution_id = f8
   1 event_prsnl[*]
     2 event_prsnl_id = f8
     2 action_dt_tm = dq8
     2 action_type_cd = f8
     2 action_prsnl_id = f8
     2 action_comment = vc
     2 request_dt_tm = dq8
     2 request_prsnl_id = f8
     2 request_comment = vc
     2 action_status_cd = f8
   1 is_prev_sign_ind = i2
   1 is_locked_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req964536
 RECORD req964536(
   1 notes[*]
     2 scd_story_id = f8
     2 event_id = f8
 ) WITH protect
 FREE RECORD rep964536
 RECORD rep964536(
   1 notes[*]
     2 scd_story_id = f8
     2 event_id = f8
     2 update_lock_user_id = f8
     2 update_lock_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
     2 cnt = i4
     2 data[*]
       3 code = i4
       3 severity_level = i4
       3 supp_err_txt = c32
       3 def_msg = vc
       3 row_data
         4 lvl_1_idx = i4
         4 lvl_2_idx = i4
         4 lvl_3_idx = i4
 ) WITH protect
 FREE RECORD req964535
 RECORD req964535(
   1 notes[*]
     2 action_type = c3
     2 keep_lock_ind = i2
     2 scd_story_id = f8
     2 scr_pattern_id[*]
       3 patid = f8
       3 pattern_type_cd = f8
       3 pattern_type_mean = vc
       3 para_type_id = f8
     2 story_type_cd = f8
     2 story_type_mean = vc
     2 title = vc
     2 story_completion_status_cd = f8
     2 story_completion_status_mean = vc
     2 encounter_id = f8
     2 event_id = f8
     2 author_id = f8
     2 person_id = f8
     2 update_lock_dt_tm = dq8
     2 entry_mode_cd = f8
     2 concepts[*]
       3 concept_cki = vc
       3 concept_display = vc
       3 concept_type_flag = i2
       3 diagnosis_group_id = f8
     2 paragraphs[*]
       3 scd_paragraph_id = f8
       3 scr_paragraph_type_id = f8
       3 sequence_number = i4
       3 paragraph_class_cd = f8
       3 paragraph_class_mean = vc
       3 action_type = c3
       3 truth_state_cd = f8
       3 truth_state_mean = vc
       3 scd_term_data_id = f8
       3 para_term_data[*]
         4 scd_term_data_type_cd = f8
         4 scd_term_data_type_mean = vc
         4 scd_term_data_key = vc
         4 fkey_id = f8
         4 fkey_entity_name = vc
         4 value_number = f8
         4 value_dt_tm = dq8
         4 value_tz = i4
         4 value_dt_tm_os = f8
         4 value_text = vc
         4 units_cd = f8
         4 units_mean = vc
         4 value_binary = gvc
         4 format_cd = f8
         4 format_mean = vc
       3 event_id = f8
       3 reference_nbr = vc
     2 sentences[*]
       3 action_type = c3
       3 scd_sentence_id = f8
       3 scd_paragraph_type_idx = i4
       3 canonical_sentence_pattern_id = f8
       3 can_sent_pat_cki_source = c12
       3 can_sent_pat_cki_identifier = vc
       3 sentence_class_cd = f8
       3 sentence_class_mean = vc
       3 sentence_topic_cd = f8
       3 sentence_topic_mean = vc
       3 sequence_number = i4
       3 scr_term_hier_id = f8
       3 text_format_rule_cd = f8
       3 text_format_rule_mean = vc
       3 author_persnl_id = f8
     2 terms[*]
       3 scd_term_id = f8
       3 parent_scd_term_idx = i4
       3 scd_sentence_idx = i4
       3 data_format_mean = vc
       3 truth_state_cd = f8
       3 truth_state_mean = vc
       3 scr_term_hier_id = f8
       3 scr_term_id = f8
       3 concept_source_cd = f8
       3 concept_identifier = vc
       3 concept_cki = vc
       3 sequence_number = i4
       3 scr_phrase_id = f8
       3 phrase_string = vc
       3 successor_term_idx = i4
       3 succeeded_term_id = f8
       3 active_ind = i2
       3 beg_effective_dt_tm = dq8
       3 beg_effective_tz = i4
       3 modify_prsnl_id = f8
       3 end_effective_dt_tm = dq8
       3 term_data[*]
         4 scd_term_data_type_cd = f8
         4 scd_term_data_type_mean = vc
         4 scd_term_data_key = vc
         4 fkey_id = f8
         4 fkey_entity_name = vc
         4 value_number = f8
         4 value_dt_tm = dq8
         4 value_tz = i4
         4 value_dt_tm_os = f8
         4 value_text = vc
         4 units_cd = f8
         4 units_mean = vc
         4 value_binary = gvc
         4 format_cd = f8
         4 format_mean = vc
       3 event_id = f8
       3 reference_nbr = vc
     2 event_id = f8
     2 blobs[*]
       3 para_idx = i4
       3 term_idx = i4
       3 term_data_idx = i4
       3 qual[*]
         4 chunk = gvc
     2 filter_by_user_org_ind = i2
     2 note_type_cd = f8
     2 priority_ind = i2
     2 total_dict_minutes = f8
     2 facility_cd = f8
     2 ensure_dict = i2
     2 note_term_data[*]
       3 scd_term_data_type_cd = f8
       3 scd_term_data_type_mean = vc
       3 scd_term_data_key = vc
       3 fkey_id = f8
       3 fkey_entity_name = vc
       3 value_number = f8
       3 value_dt_tm = dq8
       3 value_tz = i4
       3 value_dt_tm_os = f8
       3 value_text = vc
       3 units_cd = f8
       3 units_mean = vc
       3 value_binary = gvc
       3 format_cd = f8
       3 format_mean = vc
 ) WITH protect
 FREE RECORD rep964535
 RECORD rep964535(
   1 notes[*]
     2 scd_story_id = f8
     2 update_lock_dt_tm = dq8
     2 event_id = f8
     2 paragraphs[*]
       3 scd_paragraph_id = f8
       3 event_id = f8
     2 sentences[*]
       3 scd_sentence_id = f8
     2 terms[*]
       3 scd_term_id = f8
       3 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
     2 cnt = i4
     2 data[*]
       3 code = i4
       3 severity_level = i4
       3 supp_err_txt = c32
       3 def_msg = vc
       3 row_data
         4 lvl_1_idx = i4
         4 lvl_2_idx = i4
         4 lvl_3_idx = i4
 ) WITH protect
 FREE RECORD req1000012
 RECORD req1000012(
   1 ensure_type = i2
   1 event_subclass_cd = f8
   1 eso_action_meaning = vc
   1 clin_event
     2 ensure_type = i2
     2 event_id = f8
     2 view_level = i4
     2 view_level_ind = i2
     2 order_id = f8
     2 catalog_cd = f8
     2 catalog_cd_cki = vc
     2 series_ref_nbr = vc
     2 person_id = f8
     2 encntr_id = f8
     2 encntr_financial_id = f8
     2 accession_nbr = vc
     2 contributor_system_cd = f8
     2 contributor_system_cd_cki = vc
     2 reference_nbr = vc
     2 parent_event_id = f8
     2 event_class_cd = f8
     2 event_class_cd_cki = vc
     2 event_cd = f8
     2 event_cd_cki = vc
     2 event_tag = vc
     2 event_reltn_cd = f8
     2 event_reltn_cd_cki = vc
     2 event_start_dt_tm = dq8
     2 event_start_dt_tm_ind = i2
     2 event_end_dt_tm = dq8
     2 event_end_dt_tm_ind = i2
     2 event_end_dt_tm_os = f8
     2 event_end_dt_tm_os_ind = i2
     2 task_assay_cd = f8
     2 task_assay_cd_cki = vc
     2 record_status_cd = f8
     2 record_status_cd_cki = vc
     2 result_status_cd = f8
     2 result_status_cd_cki = vc
     2 authentic_flag = i2
     2 authentic_flag_ind = i2
     2 publish_flag = i2
     2 publish_flag_ind = i2
     2 qc_review_cd = f8
     2 qc_review_cd_cki = vc
     2 normalcy_cd = f8
     2 normalcy_cd_cki = vc
     2 normalcy_method_cd = f8
     2 normalcy_method_cd_cki = vc
     2 inquire_security_cd = f8
     2 inquire_security_cd_cki = vc
     2 resource_group_cd = f8
     2 resource_group_cd_cki = vc
     2 resource_cd = f8
     2 resource_cd_cki = vc
     2 subtable_bit_map = i4
     2 subtable_bit_map_ind = i2
     2 event_title_text = vc
     2 collating_seq = vc
     2 normal_low = vc
     2 normal_high = vc
     2 critical_low = vc
     2 critical_high = vc
     2 expiration_dt_tm = dq8
     2 expiration_dt_tm_ind = i2
     2 note_importance_bit_map = i2
     2 event_tag_set_flag = i2
     2 clinsig_updt_dt_tm_flag = i2
     2 clinsig_updt_dt_tm = dq8
     2 clinsig_updt_dt_tm_ind = i2
     2 io_result[*]
       3 person_id = f8
       3 io_dt_tm = dq8
       3 io_dt_tm_ind = i2
       3 type_cd = f8
       3 group_cd = f8
       3 volume = f8
       3 volume_ind = i2
       3 authentic_flag = i2
       3 authentic_flag_ind = i2
       3 record_status_cd = f8
       3 io_comment = vc
       3 system_note = vc
       3 ce_io_result_id = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 specimen_coll[*]
       3 specimen_id = f8
       3 container_id = f8
       3 container_type_cd = f8
       3 specimen_status_cd = f8
       3 collect_dt_tm = dq8
       3 collect_dt_tm_ind = i2
       3 collect_method_cd = f8
       3 collect_loc_cd = f8
       3 collect_prsnl_id = f8
       3 collect_volume = f8
       3 collect_volume_ind = i2
       3 collect_unit_cd = f8
       3 collect_priority_cd = f8
       3 source_type_cd = f8
       3 source_text = vc
       3 body_site_cd = f8
       3 danger_cd = f8
       3 positive_ind = i2
       3 positive_ind_ind = i2
       3 specimen_trans_list[*]
         4 sequence_nbr = i4
         4 sequence_nbr_ind = i2
         4 transfer_dt_tm = dq8
         4 transfer_dt_tm_ind = i2
         4 transfer_prsnl_id = f8
         4 transfer_loc_cd = f8
         4 receive_dt_tm = dq8
         4 receive_dt_tm_ind = i2
         4 receive_prsnl_id = f8
         4 receive_loc_cd = f8
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 blob_result[*]
       3 succession_type_cd = f8
       3 sub_series_ref_nbr = vc
       3 storage_cd = f8
       3 format_cd = f8
       3 device_cd = f8
       3 blob_handle = vc
       3 blob_attributes = vc
       3 blob[*]
         4 blob_seq_num = i4
         4 blob_seq_num_ind = i2
         4 compression_cd = f8
         4 blob_contents = gvc
         4 blob_contents_ind = i2
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 blob_length = i4
         4 blob_length_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 blob_summary[*]
         4 blob_length = i4
         4 blob_length_ind = i2
         4 format_cd = f8
         4 compression_cd = f8
         4 checksum = i4
         4 checksum_ind = i2
         4 long_blob = gvc
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 ce_blob_summary_id = f8
         4 blob_summary_id = f8
         4 event_id = f8
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 max_sequence_nbr = i4
       3 max_sequence_nbr_ind = i2
       3 checksum = i4
       3 checksum_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 string_result[*]
       3 ensure_type = i2
       3 string_result_text = vc
       3 string_result_format_cd = f8
       3 equation_id = f8
       3 last_norm_dt_tm = dq8
       3 last_norm_dt_tm_ind = i2
       3 unit_of_measure_cd = f8
       3 feasible_ind = i2
       3 feasible_ind_ind = i2
       3 inaccurate_ind = i2
       3 inaccurate_ind_ind = i2
       3 interp_comp_list[*]
         4 comp_idx = i4
         4 comp_idx_ind = i2
         4 comp_event_id = f8
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 blood_transfuse[*]
       3 transfuse_start_dt_tm = dq8
       3 transfuse_start_dt_tm_ind = i2
       3 transfuse_end_dt_tm = dq8
       3 transfuse_end_dt_tm_ind = i2
       3 transfuse_note = vc
       3 transfuse_route_cd = f8
       3 transfuse_site_cd = f8
       3 transfuse_pt_loc_cd = f8
       3 initial_volume = f8
       3 total_intake_volume = f8
       3 transfusion_rate = f8
       3 transfusion_unit_cd = f8
       3 transfusion_time_cd = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 apparatus[*]
       3 apparatus_type_cd = f8
       3 apparatus_serial_nbr = vc
       3 apparatus_size_cd = f8
       3 body_site_cd = f8
       3 insertion_pt_loc_cd = f8
       3 insertion_prsnl_id = f8
       3 removal_pt_loc_cd = f8
       3 removal_prsnl_id = f8
       3 assistant_list[*]
         4 assistant_type_cd = f8
         4 sequence_nbr = i4
         4 sequence_nbr_ind = i2
         4 assistant_prsnl_id = f8
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 product[*]
       3 product_id = f8
       3 product_nbr = vc
       3 product_cd = f8
       3 abo_cd = f8
       3 rh_cd = f8
       3 product_status_cd = f8
       3 product_antigen_list[*]
         4 prod_ant_seq_nbr = i4
         4 prod_ant_seq_nbr_ind = i2
         4 antigen_cd = f8
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 date_result[*]
       3 result_dt_tm = dq8
       3 result_dt_tm_ind = i2
       3 result_dt_tm_os = f8
       3 result_dt_tm_os_ind = i2
       3 date_type_flag = i2
       3 date_type_flag_ind = i2
       3 event_id = f8
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 med_result_list[*]
       3 ensure_type = i2
       3 admin_note = vc
       3 admin_prov_id = f8
       3 admin_start_dt_tm = dq8
       3 admin_start_dt_tm_ind = i2
       3 admin_end_dt_tm = dq8
       3 admin_end_dt_tm_ind = i2
       3 admin_route_cd = f8
       3 admin_site_cd = f8
       3 admin_method_cd = f8
       3 admin_pt_loc_cd = f8
       3 initial_dosage = f8
       3 initial_dosage_ind = i2
       3 admin_dosage = f8
       3 admin_dosage_ind = i2
       3 dosage_unit_cd = f8
       3 initial_volume = f8
       3 initial_volume_ind = i2
       3 total_intake_volume = f8
       3 total_intake_volume_ind = i2
       3 diluent_type_cd = f8
       3 ph_dispense_id = f8
       3 infusion_rate = f8
       3 infusion_rate_ind = i2
       3 infusion_unit_cd = f8
       3 infusion_time_cd = f8
       3 medication_form_cd = f8
       3 reason_required_flag = i2
       3 reason_required_flag_ind = i2
       3 response_required_flag = i2
       3 response_required_flag_ind = i2
       3 admin_strength = i4
       3 admin_strength_ind = i2
       3 admin_strength_unit_cd = f8
       3 substance_lot_number = vc
       3 substance_exp_dt_tm = dq8
       3 substance_exp_dt_tm_ind = i2
       3 substance_manufacturer_cd = f8
       3 refusal_cd = f8
       3 system_entry_dt_tm = dq8
       3 system_entry_dt_tm_ind = i2
       3 iv_event_cd = f8
       3 infused_volume = f8
       3 infused_volume_ind = i2
       3 infused_volume_unit_cd = f8
       3 remaining_volume = f8
       3 remaining_volume_ind = i2
       3 remaining_volume_unit_cd = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 synonym_id = f8
       3 immunization_type_cd = f8
       3 admin_start_tz = i4
       3 admin_end_tz = i4
       3 contributor_link_list[*]
       3 weight_value = f8
       3 weight_unit_cd = f8
     2 event_note_list[*]
       3 note_type_cd = f8
       3 note_format_cd = f8
       3 entry_method_cd = f8
       3 note_prsnl_id = f8
       3 note_dt_tm = dq8
       3 note_dt_tm_ind = i2
       3 record_status_cd = f8
       3 compression_cd = f8
       3 checksum = i4
       3 checksum_ind = i2
       3 long_text_id = f8
       3 non_chartable_flag = i2
       3 importance_flag = i2
       3 long_blob = gvc
       3 ce_event_note_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 event_note_id = f8
       3 event_id = f8
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 note_tz = i4
       3 ensure_type = i2
     2 event_prsnl_list[*]
       3 event_prsnl_id = f8
       3 person_id = f8
       3 event_id = f8
       3 action_type_cd = f8
       3 request_dt_tm = dq8
       3 request_dt_tm_ind = i2
       3 request_prsnl_id = f8
       3 request_prsnl_ft = vc
       3 request_comment = vc
       3 action_dt_tm = dq8
       3 action_dt_tm_ind = i2
       3 action_prsnl_id = f8
       3 action_prsnl_ft = vc
       3 proxy_prsnl_id = f8
       3 proxy_prsnl_ft = vc
       3 action_status_cd = f8
       3 action_comment = vc
       3 change_since_action_flag = i2
       3 change_since_action_flag_ind = i2
       3 action_prsnl_pin = vc
       3 defeat_succn_ind = i2
       3 ce_event_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 long_text_id = f8
       3 linked_event_id = f8
       3 request_tz = i4
       3 action_tz = i4
       3 system_comment = vc
       3 event_action_modifier_list[*]
         4 ce_event_action_modifier_id = f8
         4 event_action_modifier_id = f8
         4 event_id = f8
         4 event_prsnl_id = f8
         4 action_type_modifier_cd = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 ensure_type = i2
       3 digital_signature_ident = vc
       3 action_prsnl_group_id = f8
       3 request_prsnl_group_id = f8
       3 receiving_person_id = f8
       3 receiving_person_ft = vc
     2 microbiology_list[*]
       3 ensure_type = i2
       3 micro_seq_nbr = i4
       3 micro_seq_nbr_ind = i2
       3 organism_cd = f8
       3 organism_occurrence_nbr = i4
       3 organism_occurrence_nbr_ind = i2
       3 organism_type_cd = f8
       3 observation_prsnl_id = f8
       3 biotype = vc
       3 probability = f8
       3 positive_ind = i2
       3 positive_ind_ind = i2
       3 susceptibility_list[*]
         4 ensure_type = i2
         4 micro_seq_nbr = i4
         4 micro_seq_nbr_ind = i2
         4 suscep_seq_nbr = i4
         4 suscep_seq_nbr_ind = i2
         4 susceptibility_test_cd = f8
         4 detail_susceptibility_cd = f8
         4 panel_antibiotic_cd = f8
         4 antibiotic_cd = f8
         4 diluent_volume = f8
         4 diluent_volume_ind = i2
         4 result_cd = f8
         4 result_text_value = vc
         4 result_numeric_value = f8
         4 result_numeric_value_ind = i2
         4 result_unit_cd = f8
         4 result_dt_tm = dq8
         4 result_dt_tm_ind = i2
         4 result_prsnl_id = f8
         4 susceptibility_status_cd = f8
         4 abnormal_flag = i2
         4 abnormal_flag_ind = i2
         4 chartable_flag = i2
         4 chartable_flag_ind = i2
         4 nomenclature_id = f8
         4 antibiotic_note = vc
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 coded_result_list[*]
       3 ensure_type = i2
       3 sequence_nbr = i4
       3 sequence_nbr_ind = i2
       3 nomenclature_id = f8
       3 acr_code_str = vc
       3 proc_code_str = vc
       3 pathology_str = vc
       3 result_set = i4
       3 result_set_ind = i2
       3 result_cd = f8
       3 group_nbr = i4
       3 group_nbr_ind = i2
       3 mnemonic = vc
       3 short_string = vc
       3 descriptor = vc
       3 unit_of_measure_cd = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 linked_result_list[*]
       3 ensure_type = i2
       3 linked_event_id = f8
       3 order_id = f8
       3 encntr_id = f8
       3 accession_nbr = vc
       3 contributor_system_cd = f8
       3 reference_nbr = vc
       3 event_class_cd = f8
       3 series_ref_nbr = vc
       3 sub_series_ref_nbr = vc
       3 succession_type_cd = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 event_modifier_list[*]
       3 modifier_cd = f8
       3 modifier_value_cd = f8
       3 modifier_val_ft = vc
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 suscep_footnote_r_list[*]
       3 ensure_type = i2
       3 micro_seq_nbr = i4
       3 micro_seq_nbr_ind = i2
       3 suscep_seq_nbr = i4
       3 suscep_seq_nbr_ind = i2
       3 suscep_footnote_id = f8
       3 suscep_footnote[*]
         4 event_id = f8
         4 ce_suscep_footnote_id = f8
         4 suscep_footnote_id = f8
         4 checksum = i4
         4 checksum_ind = i2
         4 compression_cd = f8
         4 format_cd = f8
         4 contributor_system_cd = f8
         4 blob_length = i4
         4 blob_length_ind = i2
         4 reference_nbr = vc
         4 long_blob = gvc
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 inventory_result_list[*]
       3 ensure_type = i2
       3 item_id = f8
       3 serial_nbr = vc
       3 serial_mnemonic = vc
       3 description = vc
       3 item_nbr = vc
       3 quantity = f8
       3 quantity_ind = i2
       3 body_site = vc
       3 reference_entity_id = f8
       3 reference_entity_name = vc
       3 implant_result[*]
         4 ensure_type = i2
         4 item_id = f8
         4 item_size = vc
         4 harvest_site = vc
         4 culture_ind = i2
         4 culture_ind_ind = i2
         4 tissue_graft_type_cd = f8
         4 explant_reason_cd = f8
         4 explant_disposition_cd = f8
         4 reference_entity_id = f8
         4 reference_entity_name = vc
         4 manufacturer_cd = f8
         4 manufacturer_ft = vc
         4 model_nbr = vc
         4 lot_nbr = vc
         4 other_identifier = vc
         4 expiration_dt_tm = dq8
         4 expiration_dt_tm_ind = i2
         4 ecri_code = vc
         4 batch_nbr = vc
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 inv_time_result_list[*]
         4 ensure_type = i2
         4 item_id = f8
         4 start_dt_tm = dq8
         4 start_dt_tm_ind = i2
         4 end_dt_tm = dq8
         4 end_dt_tm_ind = i2
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 script_list[*]
       3 event_req_flag = i2
       3 event_rep_flag = i2
       3 script_name = vc
       3 location = vc
     2 child_event_list[*]
       3 ensure_type = i2
       3 event_id = f8
       3 view_level = i4
       3 view_level_ind = i2
       3 order_id = f8
       3 catalog_cd = f8
       3 catalog_cd_cki = vc
       3 series_ref_nbr = vc
       3 person_id = f8
       3 encntr_id = f8
       3 encntr_financial_id = f8
       3 accession_nbr = vc
       3 contributor_system_cd = f8
       3 contributor_system_cd_cki = vc
       3 reference_nbr = vc
       3 parent_event_id = f8
       3 event_class_cd = f8
       3 event_class_cd_cki = vc
       3 event_cd = f8
       3 event_cd_cki = vc
       3 event_tag = vc
       3 event_reltn_cd = f8
       3 event_reltn_cd_cki = vc
       3 event_start_dt_tm = dq8
       3 event_start_dt_tm_ind = i2
       3 event_end_dt_tm = dq8
       3 event_end_dt_tm_ind = i2
       3 event_end_dt_tm_os = f8
       3 event_end_dt_tm_os_ind = i2
       3 task_assay_cd = f8
       3 task_assay_cd_cki = vc
       3 record_status_cd = f8
       3 record_status_cd_cki = vc
       3 result_status_cd = f8
       3 result_status_cd_cki = vc
       3 authentic_flag = i2
       3 authentic_flag_ind = i2
       3 publish_flag = i2
       3 publish_flag_ind = i2
       3 qc_review_cd = f8
       3 qc_review_cd_cki = vc
       3 normalcy_cd = f8
       3 normalcy_cd_cki = vc
       3 normalcy_method_cd = f8
       3 normalcy_method_cd_cki = vc
       3 inquire_security_cd = f8
       3 inquire_security_cd_cki = vc
       3 resource_group_cd = f8
       3 resource_group_cd_cki = vc
       3 resource_cd = f8
       3 resource_cd_cki = vc
       3 subtable_bit_map = i4
       3 subtable_bit_map_ind = i2
       3 event_title_text = vc
       3 collating_seq = vc
       3 normal_low = vc
       3 normal_high = vc
       3 critical_low = vc
       3 critical_high = vc
       3 expiration_dt_tm = dq8
       3 expiration_dt_tm_ind = i2
       3 note_importance_bit_map = i2
       3 event_tag_set_flag = i2
       3 clinsig_updt_dt_tm_flag = i2
       3 clinsig_updt_dt_tm = dq8
       3 clinsig_updt_dt_tm_ind = i2
     2 clinical_event_id = f8
     2 valid_until_dt_tm = dq8
     2 valid_until_dt_tm_ind = i2
     2 valid_from_dt_tm = dq8
     2 valid_from_dt_tm_ind = i2
     2 result_val = vc
     2 result_units_cd = f8
     2 result_units_cd_cki = vc
     2 result_time_units_cd = f8
     2 result_time_units_cd_cki = vc
     2 verified_dt_tm = dq8
     2 verified_dt_tm_ind = i2
     2 verified_prsnl_id = f8
     2 performed_dt_tm = dq8
     2 performed_dt_tm_ind = i2
     2 performed_prsnl_id = f8
     2 updt_dt_tm = dq8
     2 updt_dt_tm_ind = i2
     2 updt_id = f8
     2 updt_task = i4
     2 updt_task_ind = i2
     2 updt_cnt = i4
     2 updt_cnt_ind = i2
     2 updt_applctx = i4
     2 updt_applctx_ind = i2
     2 ensure_type2 = i2
     2 order_action_sequence = i4
     2 entry_mode_cd = f8
     2 source_cd = f8
     2 clinical_seq = vc
     2 event_start_tz = i4
     2 event_end_tz = i4
     2 verified_tz = i4
     2 performed_tz = i4
     2 calculation_result_list[*]
     2 replacement_event_id = f8
     2 task_assay_version_nbr = f8
     2 modifier_long_text = vc
     2 modifier_long_text_id = f8
     2 result_set_link_list[*]
     2 event_order_link_list[*]
     2 intake_output_result[*]
     2 io_total_result_list[*]
     2 src_event_id = f8
     2 src_clinsig_updt_dt_tm = dq8
     2 nomen_string_flag = i2
     2 ce_dynamic_label_id = f8
     2 replacement_label_id = f8
     2 assignment_method_list[*]
     2 med_admin_reltn_list[*]
     2 device_free_txt = vc
     2 trait_bit_map = i4
     2 event_uuid = vc
   1 ensure_type2 = i2
   1 override_pat_context_tz = i4
 ) WITH protect
 FREE RECORD rep1000012
 RECORD rep1000012(
   1 sb
     2 severitycd = i4
     2 statuscd = i4
     2 statustext = vc
   1 rb_list[*]
     2 event_id = f8
     2 valid_from_dt_tm = dq8
     2 event_cd = f8
     2 result_status_cd = f8
     2 contributor_system_cd = f8
     2 reference_nbr = vc
     2 collating_seq = vc
     2 parent_event_id = f8
     2 prsnl_list[*]
       3 event_prsnl_id = f8
       3 action_prsnl_id = f8
       3 action_type_cd = f8
       3 action_dt_tm = dq8
       3 action_dt_tm_ind = i2
   1 script_reply_list[*]
 ) WITH protect
 FREE RECORD req964521
 RECORD req964521(
   1 notes[*]
     2 id = f8
     2 event_id = f8
     2 update_lock_flag = i4
     2 export_ind = i2
 ) WITH protect
 FREE RECORD rep964521
 RECORD rep964521(
   1 notes[*]
     2 scd_story_id = f8
     2 person_id = f8
     2 encounter_id = f8
     2 story_type_cd = f8
     2 story_type_mean = vc
     2 title = vc
     2 story_completion_status_cd = f8
     2 story_completion_status_mean = vc
     2 author_id = f8
     2 author_name = vc
     2 event_id = f8
     2 update_lock_user_id = f8
     2 update_lock_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_mean = vc
     2 entry_mode_cd = f8
     2 entry_mode_mean = vc
     2 concepts[*]
       3 concept_cki = vc
       3 concept_display = vc
       3 concept_type_flag = i2
       3 diagnosis_group_id = f8
     2 scr_pattern_ids[*]
       3 scr_pattern_id = f8
       3 scr_paragraph_type_id = f8
       3 pattern_type_cd = f8
       3 pattern_type_mean = vc
       3 pattern_display = vc
       3 pattern_definition = vc
     2 paragraphs[*]
       3 scd_paragraph_id = f8
       3 scr_paragraph_type_id = f8
       3 scr_paragraph_display = vc
       3 sequence_number = i4
       3 paragraph_class_cd = f8
       3 paragraph_class_mean = vc
       3 scr_cki_source = vc
       3 scr_cki_id = vc
       3 scr_text_format_rule_cd = f8
       3 scr_canonical_pattern_id = f8
       3 scr_description = vc
       3 scd_term_data_id = f8
       3 truth_state_cd = f8
       3 truth_state_mean = vc
       3 para_term_data[*]
         4 scd_term_data_type_cd = f8
         4 scd_term_data_type_mean = vc
         4 scd_term_data_key = vc
         4 fkey_id = f8
         4 fkey_entity_name = vc
         4 value_number = f8
         4 value_dt_tm = dq8
         4 value_tz = i4
         4 value_dt_tm_os = f8
         4 value_text = vc
         4 units_cd = f8
         4 units_mean = vc
         4 value_binary = vgc
         4 format_cd = f8
         4 format_mean = vc
       3 scr_text_format_rule_mean = vc
       3 action_type = c3
     2 sentences[*]
       3 scd_sentence_id = f8
       3 scd_paragraph_id = f8
       3 scr_term_hier_id = f8
       3 canonical_sentence_pattern_id = f8
       3 sequence_number = i4
       3 can_sent_pat_cki_source = vc
       3 can_sent_pat_cki_identifier = vc
       3 sentence_class_cd = f8
       3 sentence_class_mean = vc
       3 sentence_topic_cd = f8
       3 text_format_rule_cd = f8
       3 text_format_rule_mean = vc
       3 sentence_topic_mean = vc
       3 author_persnl_id = f8
       3 updt_dt_tm = dq8
       3 updt_cnt = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_mean = vc
       3 scd_paragraph_type_idx = i4
       3 action_type = c3
     2 terms[*]
       3 scd_term_id = f8
       3 scr_term_id = f8
       3 scd_sentence_id = f8
       3 scr_term_hier_id = f8
       3 sequence_number = i4
       3 truth_state_cd = f8
       3 truth_state_mean = vc
       3 parent_scd_term_id = f8
       3 scd_phrase_type_id = f8
       3 parent_term_hier_id = f8
       3 recommended_cd = f8
       3 recommended_mean = vc
       3 dependency_group = i4
       3 dependency_cd = f8
       3 dependency_mean = vc
       3 default_cd = f8
       3 default_mean = vc
       3 source_term_hier_id = f8
       3 cki_source = vc
       3 cki_identifier = vc
       3 concept_identifier = vc
       3 concept_source_cd = f8
       3 concept_source_mean = vc
       3 concept_cki = vc
       3 eligibility_check_cd = f8
       3 eligibility_check_mean = vc
       3 visible_cd = f8
       3 visible_mean = vc
       3 oldest_age = f8
       3 repeat_cd = f8
       3 repeat_mean = vc
       3 restrict_to_sex = c12
       3 state_logic_cd = f8
       3 state_logic_mean = vc
       3 store_cd = f8
       3 store_mean = vc
       3 term_type_cd = f8
       3 term_type_mean = vc
       3 youngest_age = f8
       3 definition = vc
       3 display = vc
       3 external_reference_info = vc
       3 text_format_rule_cd = f8
       3 text_format_rule_mean = vc
       3 text_negation_rule_cd = f8
       3 text_negation_rule_mean = vc
       3 text_representation = vc
       3 term_data[*]
         4 scd_term_data_type_cd = f8
         4 scd_term_data_type_mean = vc
         4 scd_term_data_key = vc
         4 fkey_id = f8
         4 fkey_entity_name = vc
         4 value_number = f8
         4 value_dt_tm = dq8
         4 value_tz = i4
         4 value_dt_tm_os = f8
         4 value_text = vc
         4 units_cd = f8
         4 units_mean = vc
         4 value_binary = vgc
         4 format_cd = f8
         4 format_mean = vc
       3 term_def_data[*]
         4 scr_term_def_type_cd = f8
         4 scr_term_def_type_mean = vc
         4 scr_term_def_key = vc
         4 fkey_id = f8
         4 fkey_entity_name = vc
         4 def_text = vc
       3 successor_term_id = f8
       3 active_ind = i2
       3 modify_prsnl_id = f8
       3 modify_prsnl_name = vc
       3 beg_effective_dt_tm = dq8
       3 beg_effective_tz = i4
       3 end_effective_dt_tm = dq8
       3 scd_term_data_id = f8
       3 scr_term_def_id = f8
       3 event_id = f8
       3 parent_scd_term_idx = i4
       3 scd_sentence_idx = i4
       3 successor_term_idx = i4
     2 using_idx_values = i2
     2 note_term_data[*]
       3 scd_term_data_type_cd = f8
       3 scd_term_data_type_mean = vc
       3 scd_term_data_key = vc
       3 fkey_id = f8
       3 fkey_entity_name = vc
       3 value_number = f8
       3 value_dt_tm = dq8
       3 value_tz = i4
       3 value_dt_tm_os = f8
       3 value_text = vc
       3 units_cd = f8
       3 units_mean = vc
       3 value_binary = vgc
       3 format_cd = f8
       3 format_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
     2 cnt = i4
     2 data[*]
       3 code = i4
       3 severity_level = i4
       3 supp_err_txt = c32
       3 def_msg = vc
       3 row_data
         4 lvl_1_idx = i4
         4 lvl_2_idx = i4
         4 lvl_3_idx = i4
 ) WITH protect
 FREE RECORD req967529
 RECORD req967529(
   1 action_prsnl_id = f8
   1 action
     2 sign_ind = i2
     2 review_ind = i2
   1 documents[*]
     2 event_id = f8
     2 event_version = i4
     2 notification_uid = vc
     2 notification_version = i4
     2 notification_assign_version = i4
     2 receivers[*]
     2 prsnl_id = f8
     2 pool_id = f8
     2 comment = vc
     2 action
       3 sign_ind = i2
       3 review_ind = i2
     2 comment = vc
   1 run_synchronously_ind = i2
   1 on_behalf_of_prsnl_id = f8
   1 pool_id = f8
   1 action_dt_tm = dq8
   1 action_tz = i4
   1 author_id = f8
 ) WITH protect
 FREE RECORD rep967529
 RECORD rep967529(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 transaction_uid = vc
   1 successful_actions[*]
     2 notification_uid = vc
     2 event_id = f8
   1 failed_actions[*]
     2 notification_uid = vc
     2 event_id = f8
     2 reason
       3 comment_too_long_ind = i2
       3 data_access_failure_ind = i2
       3 doc_lookup_failure_ind = i2
       3 dup_request_for_provider_ind = i2
       3 illegal_status_ind = i2
       3 no_forward_privilege_ind = i2
       3 no_sign_identifiers_ind = i2
       3 paper_not_supported_ind = i2
       3 prov_not_assigned_to_req_ind = i2
       3 prov_not_member_of_pool_ind = i2
       3 order_action_not_found_ind = i2
       3 too_many_sign_requests_ind = i2
       3 wrong_doc_version_ind = i2
       3 action_already_canceled_ind = i2
       3 no_review_req_to_comp_pool_ind = i2
       3 no_sign_req_to_complete_ind = i2
       3 no_sign_req_to_comp_pool_ind = i2
       3 failed_not_version_ind = i2
       3 failed_not_assign_version_ind = i2
       3 in_prcs_doc_grace_period_ind = i2
       3 unknown_ind = i2
       3 cannot_fwd_ant_doc_for_sign = i2
       3 cannot_sign_prelim_powernote = i2
       3 otg_doc_not_supported = i2
       3 cannot_sign_letter_ind = i2
       3 cannot_sign_draft_letter_ind = i2
 ) WITH protect
 DECLARE geteventdetails(null) = i4
 DECLARE checkpowernotelock(null) = i4
 DECLARE calleventensureserver(null) = i4
 DECLARE callscdensnote(null) = i4
 DECLARE callgetnotedetails(null) = i4
 DECLARE checksessionlock(null) = i4
 DECLARE callsignreviewdocument(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE now = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE c_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE c_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE c_in_progress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 SET result->status_data.status = "F"
 SET result->forwarded_ind =  $6
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 IF (( $2 <= 0.0))
  CALL echo("INVALID EVENT ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 IF (textlen(trim( $5,3)))
  SET req_format_str->param =  $5
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->action_comment = rep_format_str->param
 ENDIF
 SET stat = geteventdetails(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF ((result->forwarded_ind=0)
  AND (result->doc_status_cd != c_in_progress_cd))
  CALL echo("DOC_STATUS_CD IS INVALID...MUST BE IN PROGRESS")
  SET result->is_prev_sign_ind = 1
 ELSE
  IF ((result->event_class_cd=c_mdoc_cd))
   SET stat = checksessionlock(null)
   IF (stat=fail)
    GO TO exit_script
   ENDIF
   SET stat = callsignreviewdocument(null)
   IF (stat=fail)
    GO TO exit_script
   ENDIF
  ELSEIF ((result->event_class_cd=c_doc_cd))
   SET stat = checkpowernotelock(null)
   IF (stat=fail)
    GO TO exit_script
   ENDIF
   SET stat = calleventensureserver(null)
   IF (stat=fail)
    GO TO exit_script
   ENDIF
   IF ((result->forwarded_ind=0))
    SET stat = callgetnotedetails(null)
    IF (stat=fail)
     GO TO exit_script
    ENDIF
    SET stat = callscdensnote(null)
    IF (stat=fail)
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  SET result->status_data.status = "S"
 ENDIF
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
 DECLARE v3 = vc WITH protect, noconstant("")
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, col + 1,
    "<Errors>", row + 1, v2 = build("<IsSignedInd>",result->is_prev_sign_ind,"</IsSignedInd>"),
    col + 1, v2, row + 1,
    v3 = build("<IsLockedInd>",result->is_locked_ind,"</IsLockedInd>"), col + 1, v3,
    row + 1, col + 1, "</Errors>",
    row + 1, col + 1, "</ReplyMessage>",
    row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD i_request
 FREE RECORD i_reply
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 FREE RECORD req1000012
 FREE RECORD rep1000012
 FREE RECORD req964535
 FREE RECORD rep964535
 FREE RECORD req964536
 FREE RECORD rep964536
 FREE RECORD req967529
 FREE RECORD rep967529
 SUBROUTINE geteventdetails(null)
   SELECT INTO "NL:"
    FROM clinical_event ce,
     encounter e
    PLAN (ce
     WHERE (ce.event_id= $2)
      AND ce.valid_until_dt_tm >= cnvtdatetime(now)
      AND ce.valid_from_dt_tm <= cnvtdatetime(now))
     JOIN (e
     WHERE e.encntr_id=ce.encntr_id)
    ORDER BY ce.valid_from_dt_tm DESC
    HEAD ce.event_id
     result->event_cd = ce.event_cd, result->person_id = ce.person_id, result->encntr_id = ce
     .encntr_id,
     result->prev_event_title_text = ce.event_title_text, result->doc_status_cd = ce.result_status_cd,
     result->event_class_cd = ce.event_class_cd,
     result->view_level = ce.view_level, result->contributor_system_cd = ce.contributor_system_cd,
     result->parent_event_id = ce.parent_event_id,
     result->event_reltn_cd = ce.event_reltn_cd, result->event_end_dt_tm = ce.event_end_dt_tm, result
     ->record_status_cd = ce.record_status_cd,
     result->authentic_flag = ce.authentic_flag, result->publish_flag = ce.publish_flag, result->
     valid_until_dt_tm = ce.valid_until_dt_tm,
     result->valid_from_dt_tm = ce.valid_from_dt_tm, result->performed_dt_tm = ce.performed_dt_tm,
     result->event_end_tz = ce.event_end_tz,
     result->event_title_text = ce.event_title_text, result->collating_seq = ce.collating_seq, result
     ->entry_mode_cd = ce.entry_mode_cd,
     result->facility_cd = e.loc_facility_cd, result->ce_updt_cnt = ce.updt_cnt
    WITH nocounter, time = 30
   ;end select
   SELECT INTO "NL:"
    FROM encntr_prsnl_reltn epr
    PLAN (epr
     WHERE (epr.encntr_id=result->encntr_id)
      AND (epr.prsnl_person_id= $3)
      AND epr.active_ind=1
      AND epr.beg_effective_dt_tm <= cnvtdatetime(now)
      AND epr.end_effective_dt_tm >= cnvtdatetime(now))
    DETAIL
     result->encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd
    WITH nocounter, time = 30
   ;end select
   DECLARE event_prsnl_cnt = i4 WITH protect, noconstant(0)
   IF ((result->event_class_cd=c_doc_cd))
    SELECT INTO "NL:"
     FROM ce_event_prsnl cep
     PLAN (cep
      WHERE (cep.event_id= $2))
     ORDER BY cep.action_dt_tm, cep.event_prsnl_id, cep.valid_from_dt_tm DESC
     HEAD cep.event_prsnl_id
      event_prsnl_cnt = (event_prsnl_cnt+ 1), stat = alterlist(result->event_prsnl,event_prsnl_cnt),
      result->event_prsnl[event_prsnl_cnt].event_prsnl_id = cep.event_prsnl_id,
      result->event_prsnl[event_prsnl_cnt].action_dt_tm = cep.action_dt_tm, result->event_prsnl[
      event_prsnl_cnt].action_type_cd = cep.action_type_cd, result->event_prsnl[event_prsnl_cnt].
      action_prsnl_id = cep.action_prsnl_id,
      result->event_prsnl[event_prsnl_cnt].action_comment = cep.action_comment, result->event_prsnl[
      event_prsnl_cnt].request_dt_tm = cep.request_dt_tm, result->event_prsnl[event_prsnl_cnt].
      request_prsnl_id = cep.request_prsnl_id,
      result->event_prsnl[event_prsnl_cnt].request_comment = cep.request_comment, result->
      event_prsnl[event_prsnl_cnt].action_status_cd = cep.action_status_cd
     WITH nocounter, time = 30
    ;end select
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE checkpowernotelock(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(964500)
   DECLARE requestid = i4 WITH constant(964536)
   SET stat = alterlist(req964536->notes,1)
   SET req964536->notes[1].event_id =  $2
   CALL echorecord(req964536)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req964536,
    "REC",rep964536,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep964536)
   IF ((rep964536->status_data.status="F"))
    RETURN(fail)
   ENDIF
   IF (size(rep964536->notes,5) > 0)
    SET result->scd_story_id = rep964536->notes[1].scd_story_id
    IF ((rep964536->notes[1].update_lock_user_id > 0))
     SET result->is_locked_ind = 1
     RETURN(fail)
    ENDIF
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE calleventensureserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(600108)
   DECLARE requestid = i4 WITH constant(1000012)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE errcode = i4 WITH protect, noconstant(0)
   DECLARE c_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
   DECLARE c_verify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"VERIFY"))
   DECLARE c_perform_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
   DECLARE c_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
   DECLARE c_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
   DECLARE c_forward_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",254550,"FORWARD"))
   DECLARE verify_action_idx = i4 WITH protect, noconstant(0)
   DECLARE perform_action_idx = i4 WITH protect, noconstant(0)
   DECLARE fwd_action_idx = i4 WITH protect, noconstant(0)
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
   SET req1000012->ensure_type = 2
   SET req1000012->clin_event.result_status_cd = c_auth_cd
   SET req1000012->clin_event.event_id =  $2
   SET req1000012->clin_event.view_level = result->view_level
   SET req1000012->clin_event.person_id = result->person_id
   SET req1000012->clin_event.encntr_id = result->encntr_id
   SET req1000012->clin_event.contributor_system_cd = result->contributor_system_cd
   SET req1000012->clin_event.parent_event_id = result->parent_event_id
   SET req1000012->clin_event.event_class_cd = result->event_class_cd
   SET req1000012->clin_event.event_reltn_cd = result->event_reltn_cd
   SET req1000012->clin_event.event_cd = result->event_cd
   SET req1000012->clin_event.event_end_dt_tm = result->event_end_dt_tm
   SET req1000012->clin_event.record_status_cd = result->record_status_cd
   SET req1000012->clin_event.authentic_flag = result->authentic_flag
   SET req1000012->clin_event.publish_flag = result->publish_flag
   SET req1000012->clin_event.valid_until_dt_tm = result->valid_until_dt_tm
   SET req1000012->clin_event.valid_from_dt_tm = result->valid_from_dt_tm
   SET req1000012->clin_event.performed_dt_tm = result->performed_dt_tm
   SET req1000012->clin_event.event_end_tz = result->event_end_tz
   SET req1000012->clin_event.event_title_text = result->event_title_text
   SET req1000012->clin_event.collating_seq = result->collating_seq
   SET stat = alterlist(req1000012->clin_event.event_prsnl_list,size(result->event_prsnl,5))
   FOR (idx = 1 TO size(result->event_prsnl,5))
     SET req1000012->clin_event.event_prsnl_list[idx].event_prsnl_id = result->event_prsnl[idx].
     event_prsnl_id
     SET req1000012->clin_event.event_prsnl_list[idx].person_id = result->person_id
     SET req1000012->clin_event.event_prsnl_list[idx].event_id = req1000012->clin_event.event_id
     SET req1000012->clin_event.event_prsnl_list[idx].action_type_cd = result->event_prsnl[idx].
     action_type_cd
     SET req1000012->clin_event.event_prsnl_list[idx].action_dt_tm = result->event_prsnl[idx].
     action_dt_tm
     SET req1000012->clin_event.event_prsnl_list[idx].action_prsnl_id = result->event_prsnl[idx].
     action_prsnl_id
     SET req1000012->clin_event.event_prsnl_list[idx].action_status_cd = result->event_prsnl[idx].
     action_status_cd
     SET req1000012->clin_event.event_prsnl_list[idx].action_tz = app_tz
     SET req1000012->clin_event.event_prsnl_list[idx].action_comment = result->event_prsnl[idx].
     action_comment
     SET req1000012->clin_event.event_prsnl_list[idx].request_dt_tm = result->event_prsnl[idx].
     request_dt_tm
     SET req1000012->clin_event.event_prsnl_list[idx].request_prsnl_id = result->event_prsnl[idx].
     request_prsnl_id
     SET req1000012->clin_event.event_prsnl_list[idx].request_comment = result->event_prsnl[idx].
     request_comment
     IF ((result->event_prsnl[idx].action_type_cd=c_verify_cd))
      SET verify_action_idx = idx
     ELSEIF ((result->event_prsnl[idx].action_type_cd=c_perform_cd))
      SET perform_action_idx = idx
     ELSEIF ((result->event_prsnl[idx].action_type_cd=c_sign_cd)
      AND (result->event_prsnl[idx].action_prsnl_id= $3)
      AND (result->event_prsnl[idx].request_prsnl_id > 0))
      SET fwd_action_idx = idx
     ENDIF
   ENDFOR
   IF ((result->forwarded_ind=1))
    SET req1000012->clin_event.updt_cnt = result->ce_updt_cnt
    SET req1000012->clin_event.entry_mode_cd = result->entry_mode_cd
    IF (verify_action_idx > 0)
     SET req1000012->clin_event.verified_dt_tm = result->event_prsnl[verify_action_idx].action_dt_tm
     SET req1000012->clin_event.verified_prsnl_id = result->event_prsnl[verify_action_idx].
     action_prsnl_id
    ENDIF
    IF (perform_action_idx > 0)
     SET req1000012->clin_event.performed_dt_tm = result->event_prsnl[perform_action_idx].
     action_dt_tm
     SET req1000012->clin_event.performed_prsnl_id = result->event_prsnl[perform_action_idx].
     action_prsnl_id
    ENDIF
    IF (fwd_action_idx > 0)
     SET req1000012->clin_event.event_prsnl_list[fwd_action_idx].action_comment = result->
     action_comment
     SET req1000012->clin_event.event_prsnl_list[fwd_action_idx].action_status_cd = c_completed_cd
     SET req1000012->clin_event.event_prsnl_list[fwd_action_idx].action_dt_tm = cnvtdatetime( $4)
     SET stat = alterlist(req1000012->clin_event.event_prsnl_list[fwd_action_idx].
      event_action_modifier_list,1)
     SET req1000012->clin_event.event_prsnl_list[fwd_action_idx].event_action_modifier_list[1].
     event_id =  $2
     SET req1000012->clin_event.event_prsnl_list[fwd_action_idx].event_action_modifier_list[1].
     event_prsnl_id = result->event_prsnl[fwd_action_idx].event_prsnl_id
     SET req1000012->clin_event.event_prsnl_list[fwd_action_idx].event_action_modifier_list[1].
     action_type_modifier_cd = c_forward_cd
    ENDIF
   ELSE
    SET stat = alterlist(req1000012->clin_event.event_prsnl_list,(size(result->event_prsnl,5)+ 1))
    SET idx = (size(result->event_prsnl,5)+ 1)
    SET req1000012->clin_event.event_prsnl_list[idx].person_id = result->person_id
    SET req1000012->clin_event.event_prsnl_list[idx].event_id = req1000012->clin_event.event_id
    SET req1000012->clin_event.event_prsnl_list[idx].action_type_cd = c_verify_cd
    SET req1000012->clin_event.event_prsnl_list[idx].action_dt_tm = cnvtdatetime( $4)
    SET req1000012->clin_event.event_prsnl_list[idx].action_prsnl_id =  $3
    SET req1000012->clin_event.event_prsnl_list[idx].action_status_cd = c_completed_cd
    SET req1000012->clin_event.event_prsnl_list[idx].action_tz = app_tz
   ENDIF
   CALL echorecord(req1000012)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req1000012,
    "REC",rep1000012,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep1000012)
   IF ((rep1000012->sb.statustext != "F"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE callscdensnote(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(964500)
   DECLARE requestid = i4 WITH constant(964535)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE errcode = i4 WITH protect, noconstant(0)
   DECLARE c_signed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",15750,"SIGNED"))
   DECLARE blobcnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(req964535->notes,1)
   SET req964535->notes[1].action_type = "UPD"
   SET req964535->notes[1].scd_story_id = result->scd_story_id
   SET req964535->notes[1].story_type_cd = rep964521->notes[1].story_type_cd
   SET req964535->notes[1].story_type_mean = rep964521->notes[1].story_type_mean
   SET req964535->notes[1].title = rep964521->notes[1].title
   SET req964535->notes[1].story_completion_status_cd = c_signed_cd
   SET req964535->notes[1].story_completion_status_mean = "SIGNED"
   SET req964535->notes[1].encounter_id = result->encntr_id
   SET req964535->notes[1].event_id =  $2
   SET req964535->notes[1].author_id =  $3
   SET req964535->notes[1].person_id = result->person_id
   SET req964535->notes[1].update_lock_dt_tm = result->update_lock_dt_tm
   SET req964535->notes[1].entry_mode_cd = rep964521->notes[1].entry_mode_cd
   SET req964535->notes[1].note_type_cd = result->event_cd
   SET req964535->notes[1].facility_cd = result->facility_cd
   SET req964535->notes[1].ensure_dict = 1
   SET stat = alterlist(req964535->notes[1].scr_pattern_id,size(rep964521->notes[1].scr_pattern_ids,5
     ))
   FOR (idx = 1 TO size(rep964521->notes[1].scr_pattern_ids,5))
     SET req964535->notes[1].scr_pattern_id[idx].patid = rep964521->notes[1].scr_pattern_ids[idx].
     scr_pattern_id
     SET req964535->notes[1].scr_pattern_id[idx].pattern_type_cd = rep964521->notes[1].
     scr_pattern_ids[idx].pattern_type_cd
     SET req964535->notes[1].scr_pattern_id[idx].pattern_type_mean = rep964521->notes[1].
     scr_pattern_ids[idx].pattern_type_mean
   ENDFOR
   SET stat = alterlist(req964535->notes[1].paragraphs,size(rep964521->notes[1].paragraphs,5))
   FOR (idx = 1 TO size(rep964521->notes[1].paragraphs,5))
     SET req964535->notes[1].paragraphs[idx].scd_paragraph_id = rep964521->notes[1].paragraphs[idx].
     scd_paragraph_id
     SET req964535->notes[1].paragraphs[idx].scr_paragraph_type_id = rep964521->notes[1].paragraphs[
     idx].scr_paragraph_type_id
     SET req964535->notes[1].paragraphs[idx].sequence_number = rep964521->notes[1].paragraphs[idx].
     sequence_number
     SET req964535->notes[1].paragraphs[idx].action_type = "ADD"
     SET req964535->notes[1].paragraphs[idx].truth_state_cd = rep964521->notes[1].paragraphs[idx].
     truth_state_cd
     SET req964535->notes[1].paragraphs[idx].truth_state_mean = rep964521->notes[1].paragraphs[idx].
     truth_state_mean
     SET stat = alterlist(req964535->notes[1].paragraphs[idx].para_term_data,size(rep964521->notes[1]
       .paragraphs[idx].para_term_data,5))
     FOR (jdx = 1 TO size(rep964521->notes[1].paragraphs[idx].para_term_data,5))
       SET req964535->notes[1].paragraphs[idx].para_term_data[jdx].scd_term_data_type_cd = rep964521
       ->notes[1].paragraphs[idx].para_term_data[jdx].scd_term_data_type_cd
       SET req964535->notes[1].paragraphs[idx].para_term_data[jdx].scd_term_data_type_mean =
       rep964521->notes[1].paragraphs[idx].para_term_data[jdx].scd_term_data_type_mean
       SET req964535->notes[1].paragraphs[idx].para_term_data[jdx].scd_term_data_key = rep964521->
       notes[1].paragraphs[idx].para_term_data[jdx].scd_term_data_key
       SET req964535->notes[1].paragraphs[idx].para_term_data[jdx].fkey_id = rep964521->notes[1].
       paragraphs[idx].para_term_data[jdx].fkey_id
       SET req964535->notes[1].paragraphs[idx].para_term_data[jdx].fkey_entity_name = rep964521->
       notes[1].paragraphs[idx].para_term_data[jdx].fkey_entity_name
       SET req964535->notes[1].paragraphs[idx].para_term_data[jdx].value_binary = rep964521->notes[1]
       .paragraphs[idx].para_term_data[jdx].value_binary
       SET req964535->notes[1].paragraphs[idx].para_term_data[jdx].format_cd = rep964521->notes[1].
       paragraphs[idx].para_term_data[jdx].format_cd
       SET req964535->notes[1].paragraphs[idx].para_term_data[jdx].format_mean = rep964521->notes[1].
       paragraphs[idx].para_term_data[jdx].format_mean
       IF ((rep964521->notes[1].paragraphs[idx].para_term_data[jdx].fkey_entity_name="SCD_BLOB"))
        SET blobcnt = (blobcnt+ 1)
        SET stat = alterlist(req964535->notes[1].blobs,blobcnt)
        SET req964535->notes[1].blobs[blobcnt].para_idx = idx
        SET req964535->notes[1].blobs[blobcnt].term_data_idx = jdx
        SET stat = alterlist(req964535->notes[1].blobs[blobcnt].qual,1)
        SET req964535->notes[1].blobs[blobcnt].qual[1].chunk = rep964521->notes[1].paragraphs[idx].
        para_term_data[jdx].value_binary
       ENDIF
     ENDFOR
   ENDFOR
   CALL echorecord(req964535)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req964535,
    "REC",rep964535,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep964535)
   IF ((rep964535->status_data.status="F"))
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE callgetnotedetails(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(964500)
   DECLARE requestid = i4 WITH constant(964521)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE errcode = i4 WITH protect, noconstant(0)
   SET stat = alterlist(req964521->notes,1)
   SET req964521->notes[1].event_id =  $2
   SET req964521->notes[1].update_lock_flag = 1
   CALL echorecord(req964521)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req964521,
    "REC",rep964521,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep964521)
   IF ((((rep964521->status_data.status="F")) OR (size(rep964521->notes,5)=0)) )
    RETURN(fail)
   ENDIF
   SET result->update_lock_dt_tm = rep964521->notes[1].update_lock_dt_tm
   RETURN(success)
 END ;Subroutine
 SUBROUTINE checksessionlock(null)
   DECLARE lock_user_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL:"
    FROM dd_contribution dc,
     dd_session ds
    PLAN (dc
     WHERE (dc.mdoc_event_id= $2))
     JOIN (ds
     WHERE ds.parent_entity_id=dc.dd_contribution_id
      AND ds.parent_entity_name="DD_CONTRIBUTION")
    DETAIL
     lock_user_id = ds.session_user_id
    WITH nocounter, time = 30
   ;end select
   IF (lock_user_id > 0.0)
    SET result->is_locked_ind = 1
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE callsignreviewdocument(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(3202004)
   DECLARE requestid = i4 WITH constant(967529)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE errcode = i4 WITH protect, noconstant(0)
   SET req967529->action_prsnl_id =  $3
   SET req967529->run_synchronously_ind = 1
   SET req967529->action_dt_tm = cnvtdatetime( $4)
   SET req967529->action_tz = app_tz
   SET req967529->action.sign_ind = 1
   SET stat = alterlist(req967529->documents,1)
   SET req967529->documents[1].event_id =  $2
   SET req967529->documents[1].event_version = result->ce_updt_cnt
   SET req967529->documents[1].comment = result->action_comment
   CALL echorecord(req967529)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967529,
    "REC",rep967529,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967529)
   IF (size(rep967529->successful_actions,5)=0)
    IF (size(rep967529->failed_actions,5)=0)
     SET result->is_prev_sign_ind = 1
    ENDIF
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
END GO
