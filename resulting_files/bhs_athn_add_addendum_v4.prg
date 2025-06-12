CREATE PROGRAM bhs_athn_add_addendum_v4
 FREE RECORD result
 RECORD result(
   1 addendum = vc
   1 new_blob = vc
   1 performed_dt_tm = dq8
   1 performed_prsnl_name_first = vc
   1 performed_prsnl_name_last = vc
   1 new_event_title_text = vc
   1 new_child_collating_seq = vc
   1 new_parent_collating_seq = vc
   1 entry_mode_cd = f8
   1 signature_line = vc
   1 view_level = i4
   1 person_id = f8
   1 encntr_id = f8
   1 parent_event_id = f8
   1 event_class_cd = f8
   1 event_cd = f8
   1 event_end_dt_tm = dq8
   1 prev_event_title_text = vc
   1 prev_event_note = vc
   1 event_note_checksum = i4
   1 event_note_type_cd = f8
   1 event_note_format_cd = f8
   1 event_note_entry_method_cd = f8
   1 event_note_compression_cd = f8
   1 event_note_id = f8
   1 updt_cnt = i4
   1 event_prsnl[*]
     2 event_prsnl_id = f8
     2 action_dt_tm = dq8
     2 action_type_cd = f8
     2 action_prsnl_id = f8
     2 action_comment = vc
     2 request_comment = vc
     2 action_status_cd = f8
   1 new_event_id = f8
   1 new_clinical_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
       3 script_param[*]
         4 person_id = f8
         4 organization_id = f8
         4 vaccinations_to_chart[*]
           5 vaccine
             6 event_cd = f8
           5 clinical_event_id = f8
           5 vfc_status_cd = f8
           5 information_statements_given[*]
             6 vis_cd = f8
             6 given_on_dt_tm = dq8
             6 published_dt_tm = dq8
           5 funding_source_cd = f8
           5 default_event_ind = i2
         4 modify_ind = i2
         4 notgiven_ind = i2
         4 reference_nbr = vc
         4 vaccinations_not_given[*]
           5 charted_dt_tm = dq8
           5 charted_personnel_id = f8
           5 reason_cd = f8
           5 comment = vc
       3 script_reply[*]
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
 DECLARE calleventensureserver(null) = i4
 DECLARE callgetsignatureserver(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE c_modify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"MODIFY"))
 DECLARE c_perform_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
 DECLARE c_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE c_verify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"VERIFY"))
 DECLARE c_review_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"REVIEW"))
 DECLARE c_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE c_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE c_requested_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"REQUESTED"))
 DECLARE c_forward_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",254550,"FORWARD"))
 DECLARE c_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE c_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 SET result->status_data.status = "F"
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 IF (( $2 <= 0.0))
  CALL echo("INVALID EVENT ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE t_blob = vc
 FREE RECORD out_rec
 RECORD out_rec(
   1 status = c1
   1 event_id = vc
 )
 IF (( $9=1))
  SET t_blob =  $5
 ELSE
  IF (( $8 !=  $9))
   EXECUTE bhs_athn_add_doc_segment "mine",  $7,  $8,
    $5, "", ""
   SET result->status_data.status = "S"
   GO TO exit_script
  ENDIF
  IF (( $8= $9))
   SELECT INTO "nl:"
    FROM bhs_athn_doc_segment ds
    PLAN (ds
     WHERE (ds.uuid= $7))
    ORDER BY ds.segment_seq
    HEAD ds.segment_seq
     t_blob = concat(t_blob,trim(ds.segment_text,3))
    WITH nocounter, separator = " ", format,
     time = 10
   ;end select
   SET t_blob = concat(t_blob,trim( $5,3))
  ENDIF
 ENDIF
 FREE RECORD req_decode_str
 RECORD req_decode_str(
   1 blob = vc
   1 url_source_ind = i2
 ) WITH protect
 FREE RECORD rep_decode_str
 RECORD rep_decode_str(
   1 blob = vc
 ) WITH protect
 IF (textlen(trim(t_blob,3)))
  SET req_decode_str->blob = t_blob
  SET req_decode_str->url_source_ind = 1
  EXECUTE bhs_athn_base64_decode  WITH replace("REQUEST","REQ_DECODE_STR"), replace("REPLY",
   "REP_DECODE_STR")
  SET t_blob = rep_decode_str->blob
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
  SET req_format_str->param = t_blob
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->addendum = rep_format_str->param
 ENDIF
 DECLARE month_str = vc WITH protect, noconstant("")
 DECLARE day_str = vc WITH protect, noconstant("")
 DECLARE year_str = vc WITH protect, noconstant("")
 DECLARE time_str = vc WITH protect, noconstant("")
 DECLARE tz_str = vc WITH protect, noconstant("")
 DECLARE performed_date_str = vc WITH protect, noconstant("")
 SELECT INTO "NL:"
  FROM person p
  PLAN (p
   WHERE (p.person_id= $3)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id
  HEAD p.person_id
   result->performed_prsnl_name_first = p.name_first, result->performed_prsnl_name_last = p.name_last
  WITH nocounter, time = 30
 ;end select
 SET result->performed_dt_tm = cnvtdatetime( $4)
 CALL echo(build("PERFORMED_DT_TM: ",format(result->performed_dt_tm,";;Q")))
 SET month_str = format(result->performed_dt_tm,"MMMMMMMMM;;D")
 CALL echo(build("MONTH_STR:",month_str))
 SET day_str = format(result->performed_dt_tm,"DD;;D")
 CALL echo(build("DAY_STR:",day_str))
 SET year_str = format(result->performed_dt_tm,"YYYY;;D")
 CALL echo(build("YEAR_STR:",year_str))
 SET time_str = format(result->performed_dt_tm,"HH:MM;;M")
 CALL echo(build("TIME_STR:",time_str))
 IF (( $6=1))
  DECLARE offset_var = i4 WITH protect, noconstant(0)
  DECLARE daylight_var = i4 WITH protect, noconstant(0)
  SET tz_str = datetimezonebyindex(curtimezoneapp,offset_var,daylight_var,7,result->performed_dt_tm)
  CALL echo(build("TZ_STR:",tz_str))
  SET performed_date_str = trim(concat(month_str," ",day_str," ",year_str,
    " ",time_str," ",tz_str),3)
 ELSE
  SET performed_date_str = trim(concat(month_str," ",day_str," ",year_str,
    " ",time_str),3)
 ENDIF
 CALL echo(build("PERFORMED_DATE_STR:",performed_date_str))
 SET result->new_event_title_text = concat("Addendum by ",result->performed_prsnl_name_last,"  , ",
  result->performed_prsnl_name_first," on ",
  performed_date_str)
 CALL echo(build("NEW_EVENT_TITLE_TEXT:",result->new_event_title_text))
 SELECT INTO "NL:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.event_id= $2)
    AND ce.valid_until_dt_tm >= cnvtdatetime(now)
    AND ce.valid_from_dt_tm <= cnvtdatetime(now))
  ORDER BY ce.valid_from_dt_tm DESC
  HEAD ce.event_id
   result->view_level = ce.view_level, result->parent_event_id = ce.parent_event_id, result->event_cd
    = ce.event_cd,
   result->updt_cnt = ce.updt_cnt, result->person_id = ce.person_id, result->encntr_id = ce.encntr_id,
   result->event_class_cd = ce.event_class_cd, result->prev_event_title_text = ce.event_title_text,
   result->event_end_dt_tm = ce.event_end_dt_tm
   IF (size(ce.collating_seq,5) > 0)
    result->new_parent_collating_seq = cnvtstring((cnvtint(ce.collating_seq)+ 1))
   ELSE
    result->new_parent_collating_seq = ""
   ENDIF
   result->entry_mode_cd = ce.entry_mode_cd
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "NL:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.parent_event_id=result->parent_event_id)
    AND ((ce.valid_until_dt_tm+ 0) > cnvtdatetime(sysdate)))
  ORDER BY ce.collating_seq DESC
  HEAD ce.parent_event_id
   CALL echo(build("CE.COLLATING_SEQ:",ce.collating_seq)), result->new_child_collating_seq =
   cnvtstring((cnvtint(ce.collating_seq)+ 1)),
   CALL echo(build("RESULT->NEW_CHILD_COLLATING_SEQ:",result->new_child_collating_seq))
  WITH nocounter, time = 30
 ;end select
 SET result->new_blob = nullterm(result->addendum)
 DECLARE event_prsnl_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "NL:"
  FROM ce_event_prsnl cep
  PLAN (cep
   WHERE (cep.event_id= $2))
  ORDER BY cep.action_dt_tm, cep.event_prsnl_id, cep.valid_from_dt_tm DESC
  HEAD cep.event_prsnl_id
   event_prsnl_cnt += 1, stat = alterlist(result->event_prsnl,event_prsnl_cnt), result->event_prsnl[
   event_prsnl_cnt].event_prsnl_id = cep.event_prsnl_id,
   result->event_prsnl[event_prsnl_cnt].action_dt_tm = cep.action_dt_tm, result->event_prsnl[
   event_prsnl_cnt].action_type_cd = cep.action_type_cd, result->event_prsnl[event_prsnl_cnt].
   action_prsnl_id = cep.action_prsnl_id,
   result->event_prsnl[event_prsnl_cnt].action_comment = cep.action_comment, result->event_prsnl[
   event_prsnl_cnt].request_comment = cep.request_comment, result->event_prsnl[event_prsnl_cnt].
   action_status_cd = cep.action_status_cd
  WITH nocounter, time = 30
 ;end select
 SET stat = callgetsignatureserver(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = calleventensureserver(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 SET out_rec->status = result->status_data.status
 SET out_rec->event_id = cnvtstring(result->new_event_id)
 EXECUTE bhs_athn_write_json_output
 FREE RECORD result
 FREE RECORD req1000012
 FREE RECORD rep1000012
 FREE RECORD req3200246
 FREE RECORD rep3200246
 FREE RECORD i_request
 FREE RECORD i_reply
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 SUBROUTINE callgetsignatureserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(3202004)
   DECLARE requestid = i4 WITH constant(3200246)
   DECLARE c_clindoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"CLINDOC"))
   DECLARE c_transcript_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"TRANSCRIPT"))
   FREE RECORD req3200246
   RECORD req3200246(
     1 signature_line_criteria[*]
       2 result_status_cd = f8
       2 type_cd = f8
       2 activity_type_cd = f8
       2 activity_subtype_cd = f8
       2 event_title_text = vc
       2 personnel_actions[*]
         3 action_type_cd = f8
         3 action_status_cd = f8
         3 action_personnel_id = f8
         3 action_date = dq8
         3 action_tz = i4
         3 action_comment = vc
         3 request_comment = vc
   ) WITH protect
   FREE RECORD rep3200246
   RECORD rep3200246(
     1 transaction_status
       2 success_ind = i2
       2 debug_error_message = vc
     1 signature_lines[*]
       2 text = vc
       2 isbuilt = i2
   ) WITH protect
   SET stat = alterlist(req3200246->signature_line_criteria,1)
   SET req3200246->signature_line_criteria[1].result_status_cd = c_modified_cd
   SET req3200246->signature_line_criteria[1].type_cd = result->event_cd
   SET req3200246->signature_line_criteria[1].activity_type_cd = c_clindoc_cd
   SET req3200246->signature_line_criteria[1].activity_subtype_cd = c_transcript_cd
   SET req3200246->signature_line_criteria[1].event_title_text = result->prev_event_title_text
   SET stat = alterlist(req3200246->signature_line_criteria[1].personnel_actions,3)
   SET req3200246->signature_line_criteria[1].personnel_actions[1].action_type_cd = c_sign_cd
   SET req3200246->signature_line_criteria[1].personnel_actions[1].action_status_cd = c_completed_cd
   SET req3200246->signature_line_criteria[1].personnel_actions[1].action_personnel_id =  $3
   SET req3200246->signature_line_criteria[1].personnel_actions[1].action_date = cnvtdatetime( $4)
   SET req3200246->signature_line_criteria[1].personnel_actions[1].action_tz = app_tz
   SET req3200246->signature_line_criteria[1].personnel_actions[2].action_type_cd = c_perform_cd
   SET req3200246->signature_line_criteria[1].personnel_actions[2].action_status_cd = c_completed_cd
   SET req3200246->signature_line_criteria[1].personnel_actions[2].action_personnel_id =  $3
   SET req3200246->signature_line_criteria[1].personnel_actions[2].action_date = cnvtdatetime( $4)
   SET req3200246->signature_line_criteria[1].personnel_actions[2].action_tz = app_tz
   SET req3200246->signature_line_criteria[1].personnel_actions[3].action_type_cd = c_modify_cd
   SET req3200246->signature_line_criteria[1].personnel_actions[3].action_status_cd = c_completed_cd
   SET req3200246->signature_line_criteria[1].personnel_actions[3].action_personnel_id =  $3
   SET req3200246->signature_line_criteria[1].personnel_actions[3].action_date = cnvtdatetime( $4)
   SET req3200246->signature_line_criteria[1].personnel_actions[3].action_tz = app_tz
   CALL echorecord(req3200246)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req3200246,
    "REC",rep3200246,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep3200246)
   IF ((rep3200246->transaction_status.success_ind=1)
    AND size(rep3200246->signature_lines,5) > 0
    AND textlen(trim(rep3200246->signature_lines[1].text,3)) > 0)
    SET result->signature_line = rep3200246->signature_lines[1].text
    CALL echo(build("RESULT->SIGNATURE_LINE=",result->signature_line))
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE calleventensureserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(600108)
   DECLARE requestid = i4 WITH constant(1000012)
   DECLARE happ = i4 WITH protect, noconstant(0)
   DECLARE htask = i4 WITH protect, noconstant(0)
   DECLARE hstep = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hitem = i4 WITH protect, noconstant(0)
   DECLARE hreply = i4 WITH protect, noconstant(0)
   DECLARE hstatus = i4 WITH protect, noconstant(0)
   DECLARE status = c1 WITH protect, noconstant("")
   DECLARE status_value = i4 WITH protect, noconstant(0)
   DECLARE hcetype = i4 WITH protect, noconstant(0)
   DECLARE hcestruct = i4 WITH protect, noconstant(0)
   DECLARE hchildlistitem = i4 WITH protect, noconstant(0)
   DECLARE hblobresultitem = i4 WITH protect, noconstant(0)
   DECLARE hblobitem = i4 WITH protect, noconstant(0)
   DECLARE heventnoteitem = i4 WITH protect, noconstant(0)
   DECLARE hprsnllistitem = i4 WITH protect, noconstant(0)
   DECLARE hreviewprsnllistitem = i4 WITH protect, noconstant(0)
   DECLARE heventactionmodlistitem = i4 WITH protect, noconstant(0)
   DECLARE review_event_prsnl_id = f8 WITH protect, noconstant(0.0)
   DECLARE rb_cnt = i4 WITH protect, noconstant(0)
   DECLARE hrblistitem = i4 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE errcode = i4 WITH protect, noconstant(0)
   DECLARE ensure_type_add = i2 WITH protect, constant(1)
   DECLARE ensure_type_upd = i2 WITH protect, constant(2)
   DECLARE c_powerchart_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"POWERCHART"))
   DECLARE c_child_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",24,"CHILD"))
   DECLARE c_root_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",24,"ROOT"))
   DECLARE c_interim_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",63,"INTERIM"))
   DECLARE c_final_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",63,"FINAL"))
   DECLARE c_long_blob_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",25,"LONG_BLOB"))
   DECLARE c_blob_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",25,"BLOB"))
   DECLARE c_rtf_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"RTF"))
   DECLARE c_ah_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"AH"))
   DECLARE c_paper_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"PAPER"))
   DECLARE c_clin_notes_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"CLIN_NOTES"))
   DECLARE c_undefined_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"UNDEFINED"))
   DECLARE c_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
   DECLARE c_sign_line_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"SIGN LINE"))
   DECLARE c_cerner_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13,"CERNER"))
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
   EXECUTE srvrtl
   EXECUTE crmrtl
   SET iret = uar_crmbeginapp(applicationid,happ)
   IF (iret != 0)
    CALL echo(build("CRMBEGINAPP: CRM STATUS =",iret))
    RETURN(fail)
   ENDIF
   SET iret = uar_crmbegintask(happ,taskid,htask)
   IF (iret != 0)
    CALL echo(build("CRMBEGINTASK: CRM STATUS =",iret))
    CALL uar_crmendapp(happ)
    RETURN(fail)
   ENDIF
   SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
   IF (iret != 0)
    CALL echo(build("CRMBEGINREQ: CRM STATUS =",iret))
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(fail)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF ( NOT (hreq))
    CALL echo(build("CRMGETREQUEST: NO HANDLE CREATED"))
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(fail)
   ENDIF
   IF (textlen(trim(result->signature_line,3)) > 0)
    SELECT INTO "NL:"
     FROM ce_event_note cen,
      long_blob lb
     PLAN (cen
      WHERE (cen.event_id= $2)
       AND ((cen.valid_until_dt_tm+ 0) > cnvtdatetime(sysdate)))
      JOIN (lb
      WHERE lb.parent_entity_id=cen.ce_event_note_id
       AND lb.parent_entity_name="CE_EVENT_NOTE")
     ORDER BY cen.valid_from_dt_tm DESC
     HEAD cen.event_id
      CALL echo(build("BLOB_LENGTH:",lb.blob_length)), blob_in = lb.long_blob, blob_out = fillstring(
       32000," "),
      blob_ret_len = 0,
      CALL uar_ocf_uncompress(blob_in,30000,blob_out,30000,blob_ret_len), result->prev_event_note =
      blob_out,
      CALL echo(build("RESULT->PREV_EVENT_NOTE:",result->prev_event_note)), result->
      event_note_checksum = cen.checksum, result->event_note_type_cd = cen.note_type_cd,
      result->event_note_format_cd = cen.note_format_cd, result->event_note_entry_method_cd = cen
      .entry_method_cd, result->event_note_compression_cd = cen.compression_cd,
      result->event_note_id = cen.event_note_id
     WITH nocounter, time = 30
    ;end select
   ENDIF
   SET iret = uar_srvsetshort(hreq,"ENSURE_TYPE",ensure_type_upd)
   SET iret = uar_srvsetshort(hreq,"ENSURE_TYPE2",ensure_type_upd)
   SET hcetype = uar_srvcreatetypefrom(hreq,"CLIN_EVENT")
   SET hcestruct = uar_srvgetstruct(hreq,"CLIN_EVENT")
   SET iret = uar_srvsetdouble(hcestruct,"EVENT_ID",cnvtreal( $2))
   SET iret = uar_srvsetlong(hcestruct,"VIEW_LEVEL",result->view_level)
   SET iret = uar_srvsetdouble(hcestruct,"ENCNTR_ID",result->encntr_id)
   SET iret = uar_srvsetdouble(hcestruct,"PERSON_ID",result->person_id)
   SET iret = uar_srvsetdouble(hcestruct,"CONTRIBUTOR_SYSTEM_CD",c_powerchart_cd)
   SET iret = uar_srvsetdouble(hcestruct,"PARENT_EVENT_ID",result->parent_event_id)
   SET iret = uar_srvsetdouble(hcestruct,"EVENT_CLASS_CD",result->event_class_cd)
   SET iret = uar_srvsetdouble(hcestruct,"EVENT_CD",result->event_cd)
   SET iret = uar_srvsetdouble(hcestruct,"EVENT_RELTN_CD",c_root_cd)
   SET iret = uar_srvsetdate(hcestruct,"EVENT_END_DT_TM",result->event_end_dt_tm)
   SET iret = uar_srvsetdouble(hcestruct,"RECORD_STATUS_CD",c_active_cd)
   SET iret = uar_srvsetdouble(hcestruct,"RESULT_STATUS_CD",c_modified_cd)
   SET iret = uar_srvsetshort(hcestruct,"AUTHENTIC_FLAG",1)
   SET iret = uar_srvsetshort(hcestruct,"PUBLISH_FLAG",1)
   SET iret = uar_srvsetstring(hcestruct,"EVENT_TITLE_TEXT",result->prev_event_title_text)
   SET iret = uar_srvsetstring(hcestruct,"COLLATING_SEQ",result->new_parent_collating_seq)
   SET iret = uar_srvsetlong(hcestruct,"UPDT_CNT",result->updt_cnt)
   SET iret = uar_srvsetdouble(hcestruct,"ENTRY_MODE_CD",result->entry_mode_cd)
   SET iret = uar_srvsetstring(hcestruct,"CLINICAL_SEQ",nullterm(""))
   SET iret = uar_srvsetlong(hcestruct,"EVENT_END_TZ",app_tz)
   SET iret = uar_srvsetdate(hcestruct,"VERIFIED_DT_TM",cnvtdatetime( $4))
   SET iret = uar_srvsetdouble(hcestruct,"VERIFIED_PRSNL_ID",cnvtreal( $3))
   SET iret = uar_srvsetdate(hcestruct,"PERFORMED_DT_TM",cnvtdatetime( $4))
   SET iret = uar_srvsetdouble(hcestruct,"PERFORMED_PRSNL_ID",cnvtreal( $3))
   IF (size(result->prev_event_note,1) > 0
    AND (result->event_class_cd != c_mdoc_cd))
    SET heventnoteitem = uar_srvadditem(hcestruct,"EVENT_NOTE_LIST")
    SET iret = uar_srvsetdouble(heventnoteitem,"NOTE_TYPE_CD",result->event_note_type_cd)
    SET iret = uar_srvsetdouble(heventnoteitem,"NOTE_FORMAT_CD",result->event_note_format_cd)
    SET iret = uar_srvsetdouble(heventnoteitem,"ENTRY_METHOD_CD",result->event_note_entry_method_cd)
    SET iret = uar_srvsetdouble(heventnoteitem,"NOTE_PRSNL_ID",cnvtreal( $3))
    SET iret = uar_srvsetdate(heventnoteitem,"NOTE_DT_TM",cnvtdatetime( $4))
    SET iret = uar_srvsetdouble(heventnoteitem,"RECORD_STATUS_CD",c_modified_cd)
    SET iret = uar_srvsetdouble(heventnoteitem,"COMPRESSION_CD",result->event_note_compression_cd)
    SET iret = uar_srvsetlong(heventnoteitem,"CHECKSUM",result->event_note_checksum)
    SET iret = uar_srvsetasis(heventnoteitem,"LONG_BLOB",result->prev_event_note,size(result->
      prev_event_note,1))
    SET iret = uar_srvsetdouble(heventnoteitem,"EVENT_NOTE_ID",result->event_note_id)
    SET iret = uar_srvsetdouble(heventnoteitem,"EVENT_ID",cnvtreal( $2))
   ENDIF
   FOR (idx = 1 TO event_prsnl_cnt)
     IF ((((result->event_prsnl[idx].action_type_cd=c_review_cd)) OR ((result->event_prsnl[idx].
     action_type_cd=c_sign_cd)))
      AND (result->event_prsnl[idx].action_prsnl_id= $3)
      AND (result->event_prsnl[idx].action_status_cd=c_requested_cd))
      SET review_event_prsnl_id = result->event_prsnl[idx].event_prsnl_id
      SET hprsnllistitem = uar_srvadditem(hcestruct,"EVENT_PRSNL_LIST")
      SET iret = uar_srvsetdouble(hprsnllistitem,"EVENT_PRSNL_ID",result->event_prsnl[idx].
       event_prsnl_id)
      SET iret = uar_srvsetdouble(hprsnllistitem,"PERSON_ID",result->person_id)
      SET iret = uar_srvsetdouble(hprsnllistitem,"EVENT_ID",cnvtreal( $2))
      SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_TYPE_CD",result->event_prsnl[idx].
       action_type_cd)
      SET iret = uar_srvsetdate(hprsnllistitem,"ACTION_DT_TM",cnvtdatetime( $4))
      SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_PRSNL_ID",result->event_prsnl[idx].
       action_prsnl_id)
      SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_STATUS_CD",c_completed_cd)
      SET iret = uar_srvsetlong(hprsnllistitem,"ACTION_TZ",app_tz)
      SET iret = uar_srvsetstring(hprsnllistitem,"ACTION_COMMENT",result->event_prsnl[idx].
       action_comment)
      SET iret = uar_srvsetstring(hprsnllistitem,"REQUEST_COMMENT",result->event_prsnl[idx].
       request_comment)
      SET iret = uar_srvsetdate(hreviewprsnllistitem,"ACTION_DT_TM",cnvtdatetime( $4))
      SET iret = uar_srvsetdouble(hreviewprsnllistitem,"ACTION_PRSNL_ID",cnvtreal( $3))
      SET iret = uar_srvsetdouble(hreviewprsnllistitem,"ACTION_STATUS_CD",c_completed_cd)
      SET iret = uar_srvsetlong(hreviewprsnllistitem,"ACTION_TZ",app_tz)
      SET heventactionmodlistitem = uar_srvadditem(hreviewprsnllistitem,"EVENT_ACTION_MODIFIER_LIST")
      SET iret = uar_srvsetdouble(heventactionmodlistitem,"EVENT_ID",cnvtreal( $2))
      SET iret = uar_srvsetdouble(heventactionmodlistitem,"EVENT_PRSNL_ID",review_event_prsnl_id)
      SET iret = uar_srvsetdouble(heventactionmodlistitem,"ACTION_TYPE_MODIFIER_CD",c_forward_cd)
     ENDIF
   ENDFOR
   SET hprsnllistitem = uar_srvadditem(hcestruct,"EVENT_PRSNL_LIST")
   SET iret = uar_srvsetdouble(hprsnllistitem,"PERSON_ID",result->person_id)
   SET iret = uar_srvsetdouble(hprsnllistitem,"EVENT_ID",cnvtreal( $2))
   SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_TYPE_CD",c_sign_cd)
   SET iret = uar_srvsetdate(hprsnllistitem,"ACTION_DT_TM",cnvtdatetime( $4))
   SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_PRSNL_ID",cnvtreal( $3))
   SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_STATUS_CD",c_completed_cd)
   SET iret = uar_srvsetlong(hprsnllistitem,"ACTION_TZ",app_tz)
   SET hprsnllistitem = uar_srvadditem(hcestruct,"EVENT_PRSNL_LIST")
   SET iret = uar_srvsetdouble(hprsnllistitem,"PERSON_ID",result->person_id)
   SET iret = uar_srvsetdouble(hprsnllistitem,"EVENT_ID",cnvtreal( $2))
   SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_TYPE_CD",c_modify_cd)
   SET iret = uar_srvsetdate(hprsnllistitem,"ACTION_DT_TM",cnvtdatetime( $4))
   SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_PRSNL_ID",cnvtreal( $3))
   SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_STATUS_CD",c_completed_cd)
   SET iret = uar_srvsetlong(hprsnllistitem,"ACTION_TZ",app_tz)
   SET iret = uar_srvbinditemtype(hcestruct,"CHILD_EVENT_LIST",hcetype)
   SET hchildlistitem = uar_srvadditem(hcestruct,"CHILD_EVENT_LIST")
   SET iret = uar_srvsetdouble(hchildlistitem,"PERSON_ID",result->person_id)
   SET iret = uar_srvsetdouble(hchildlistitem,"ENCNTR_ID",result->encntr_id)
   SET iret = uar_srvsetdouble(hchildlistitem,"CONTRIBUTOR_SYSTEM_CD",c_powerchart_cd)
   SET iret = uar_srvsetdouble(hchildlistitem,"EVENT_CLASS_CD",c_doc_cd)
   SET iret = uar_srvsetdouble(hchildlistitem,"EVENT_CD",result->event_cd)
   SET iret = uar_srvsetdouble(hchildlistitem,"EVENT_RELTN_CD",c_child_cd)
   SET iret = uar_srvsetdate(hchildlistitem,"EVENT_END_DT_TM",cnvtdatetime( $4))
   SET iret = uar_srvsetdouble(hchildlistitem,"RECORD_STATUS_CD",c_active_cd)
   SET iret = uar_srvsetdouble(hchildlistitem,"RESULT_STATUS_CD",c_modified_cd)
   SET iret = uar_srvsetshort(hchildlistitem,"AUTHENTIC_FLAG",1)
   SET iret = uar_srvsetshort(hchildlistitem,"PUBLISH_FLAG",1)
   SET iret = uar_srvsetstring(hchildlistitem,"EVENT_TITLE_TEXT",result->new_event_title_text)
   SET iret = uar_srvsetstring(hchildlistitem,"COLLATING_SEQ",result->new_child_collating_seq)
   SET iret = uar_srvsetdate(hchildlistitem,"PERFORMED_DT_TM",cnvtdatetime( $4))
   SET iret = uar_srvsetdouble(hchildlistitem,"PERFORMED_PRSNL_ID",cnvtreal( $3))
   SET hblobresultitem = uar_srvadditem(hchildlistitem,"BLOB_RESULT")
   SET iret = uar_srvsetdouble(hblobresultitem,"SUCCESSION_TYPE_CD",c_interim_cd)
   SET iret = uar_srvsetdouble(hblobresultitem,"STORAGE_CD",c_blob_cd)
   SET iret = uar_srvsetdouble(hblobresultitem,"FORMAT_CD",c_rtf_cd)
   SET iret = uar_srvsetshort(hblobresultitem,"VALID_FROM_DT_TM_IND",1)
   SET iret = uar_srvsetshort(hblobresultitem,"VALID_UNTIL_DT_TM_IND",1)
   SET iret = uar_srvsetlong(hblobresultitem,"MAX_SEQUENCE_NBR",1)
   SET hblobitem = uar_srvadditem(hblobresultitem,"BLOB")
   SET iret = uar_srvsetdouble(hblobitem,"COMPRESSION_CD",c_paper_cd)
   SET iret = uar_srvsetasis(hblobitem,"BLOB_CONTENTS",result->new_blob,size(result->new_blob,1))
   SET iret = uar_srvsetshort(hblobitem,"VALID_FROM_DT_TM_IND",1)
   SET iret = uar_srvsetshort(hblobitem,"VALID_UNTIL_DT_TM_IND",1)
   SET iret = uar_srvsetlong(hblobitem,"BLOB_LENGTH",size(result->new_blob,1))
   IF (textlen(trim(result->signature_line,3)) > 0)
    SET heventnoteitem = uar_srvadditem(hchildlistitem,"EVENT_NOTE_LIST")
    SET iret = uar_srvsetdouble(heventnoteitem,"NOTE_TYPE_CD",c_sign_line_cd)
    SET iret = uar_srvsetdouble(heventnoteitem,"NOTE_FORMAT_CD",c_ah_cd)
    SET iret = uar_srvsetdouble(heventnoteitem,"ENTRY_METHOD_CD",c_cerner_cd)
    SET iret = uar_srvsetdouble(heventnoteitem,"NOTE_PRSNL_ID",cnvtreal( $3))
    SET iret = uar_srvsetdate(heventnoteitem,"NOTE_DT_TM",cnvtdatetime( $4))
    SET iret = uar_srvsetdouble(heventnoteitem,"RECORD_STATUS_CD",c_modified_cd)
    SET iret = uar_srvsetasis(heventnoteitem,"LONG_BLOB",result->signature_line,size(result->
      signature_line,1))
   ENDIF
   SET hprsnllistitem = uar_srvadditem(hchildlistitem,"EVENT_PRSNL_LIST")
   SET iret = uar_srvsetdouble(hprsnllistitem,"PERSON_ID",result->person_id)
   SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_TYPE_CD",c_perform_cd)
   SET iret = uar_srvsetdate(hprsnllistitem,"ACTION_DT_TM",cnvtdatetime( $4))
   SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_PRSNL_ID",cnvtreal( $3))
   SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_STATUS_CD",c_completed_cd)
   SET iret = uar_srvsetlong(hprsnllistitem,"ACTION_TZ",app_tz)
   CALL echo(build("EXECUTING UAR_CRMPERFORM ON REQID: ",requestid))
   SET iret = uar_crmperform(hstep)
   CALL echo(build("CRM PERFORM STATUS:",iret))
   IF (iret)
    CALL uar_srvdestroytype(hcetype)
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(fail)
   ENDIF
   SET hreply = uar_crmgetreply(hstep)
   IF ( NOT (hreply))
    CALL echo(build("CRMGETREPLY: NO HANDLE CREATED"))
    CALL uar_srvdestroytype(hcetype)
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(fail)
   ENDIF
   SET hstatus = uar_srvgetstruct(hreply,"STATUS_DATA")
   SET status = uar_srvgetstringptr(hstatus,"STATUS")
   SET status_value = uar_srvgetlong(hstatus,"STATUS_VALUE")
   IF (((status="F") OR (status_value != 0)) )
    CALL echo(build("FAILED STATUS VALUE FOR REQUEST: ",requestid))
    CALL uar_srvdestroytype(hcetype)
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(fail)
   ENDIF
   SET rb_cnt = uar_srvgetitemcount(hreply,"RB_LIST")
   CALL echo(build("RB_CNT:",rb_cnt))
   FOR (idx = 1 TO rb_cnt)
     SET hrblistitem = uar_srvgetitem(hreply,"RB_LIST",(idx - 1))
     CALL echo(build("EVENT_CD:",uar_srvgetdouble(hrblistitem,"EVENT_CD")))
     IF ((uar_srvgetdouble(hrblistitem,"EVENT_CD")=result->event_cd))
      SET result->new_event_id = uar_srvgetdouble(hrblistitem,"EVENT_ID")
      SET result->new_clinical_event_id = uar_srvgetdouble(hrblistitem,"CLINICAL_EVENT_ID")
      SET idx = (rb_cnt+ 1)
     ENDIF
   ENDFOR
   CALL uar_srvdestroytype(hcetype)
   CALL uar_crmendreq(hstep)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
   RETURN(success)
 END ;Subroutine
END GO
