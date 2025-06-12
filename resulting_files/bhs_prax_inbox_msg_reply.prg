CREATE PROGRAM bhs_prax_inbox_msg_reply
 FREE RECORD result
 RECORD result(
   1 addendum = vc
   1 subject = vc
   1 from_line = vc
   1 to_line = vc
   1 cc_line = vc
   1 subject_line = vc
   1 sent_line = vc
   1 action_line = vc
   1 due_line = vc
   1 addendum_blob = gvc
   1 performed_dt_tm = dq8
   1 performed_prsnl_name = vc
   1 performed_prsnl_name_first = vc
   1 performed_prsnl_name_last = vc
   1 new_event_title_text = vc
   1 to_prsnl[*]
     2 prsnl_id = f8
     2 name = vc
   1 cc_prsnl[*]
     2 prsnl_id = f8
     2 name = vc
   1 actions[*]
     2 action_cd = f8
     2 action_disp = vc
   1 notify
     2 opened_ind = i2
     2 not_opened_within_ind = i2
     2 not_opened_within_days = i4
     2 completed_ind = i2
     2 not_opened_overdue_ind = i2
   1 save_to_chart_ind = i2
   1 task_uid = vc
   1 event_cd = f8
   1 task_type_cd = f8
   1 task_type_disp = vc
   1 person_id = f8
   1 encntr_id = f8
   1 order_id = f8
   1 orig_msg_body = vc
   1 parent_event
     2 event_id = f8
     2 series_ref_nbr = vc
     2 event_class_cd = f8
     2 event_cd = f8
     2 event_end_dt_tm = dq8
     2 record_status_cd = f8
     2 result_status_cd = f8
     2 authentic_flag = i2
     2 publish_flag = i2
     2 event_title_text = vc
     2 collating_seq = vc
     2 updt_cnt = i4
     2 entry_mode_cd = f8
     2 contributor_system_cd = f8
     2 event_prsnl[*]
       3 event_prsnl_id = f8
       3 action_dt_tm = dq8
       3 action_type_cd = f8
       3 action_prsnl_id = f8
       3 action_status_cd = f8
       3 action_tz = i4
       3 action_comment = vc
       3 request_comment = vc
   1 child_events[*]
     2 event_id = f8
     2 view_level = i4
     2 series_ref_nbr = vc
     2 contributor_system_cd = f8
     2 reference_nbr = vc
     2 event_class_cd = f8
     2 event_cd = f8
     2 event_end_dt_tm = dq8
     2 record_status_cd = f8
     2 result_status_cd = f8
     2 authentic_flag = i2
     2 publish_flag = i2
     2 updt_cnt = i4
     2 entry_mode_cd = f8
     2 collating_seq = vc
     2 blob
       3 compression_cd = f8
       3 contents = gvc
       3 length = i4
     2 event_prsnl[*]
       3 event_prsnl_id = f8
       3 action_dt_tm = dq8
       3 action_type_cd = f8
       3 action_prsnl_id = f8
       3 action_status_cd = f8
       3 action_tz = i4
       3 action_comment = vc
       3 request_comment = vc
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
 FREE RECORD req967503
 RECORD req967503(
   1 message_list[*]
     2 draft_msg_uid = vc
     2 person_id = f8
     2 encntr_id = f8
     2 event_cd = f8
     2 task_type_cd = f8
     2 priority_cd = f8
     2 save_to_chart_ind = i2
     2 msg_sender_pool_id = f8
     2 msg_sender_person_id = f8
     2 msg_sender_prsnl_id = f8
     2 msg_subject = vc
     2 refill_request_ind = i2
     2 msg_text = gvc
     2 reminder_dt_tm = dq8
     2 due_dt_tm = dq8
     2 callername = vc
     2 callerphone = vc
     2 notify_info
       3 notify_pool_id = f8
       3 notify_prsnl_id = f8
       3 notify_priority_cd = f8
       3 notify_status_list[*]
         4 notify_status_cd = f8
         4 delay
           5 value = i4
           5 unit_flag = i2
     2 action_request_list[*]
       3 action_request_cd = f8
     2 assign_prsnl_list[*]
       3 assign_prsnl_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
     2 assign_person_list[*]
       3 assign_person_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
       3 reply_allowed_ind = i2
     2 assign_pool_list[*]
       3 assign_pool_id = f8
       3 assign_prsnl_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
     2 encounter_class_cd = f8
     2 encounter_type_cd = f8
     2 org_id = f8
     2 get_best_encounter = i2
     2 create_encounter = i2
     2 proposed_order_list[*]
       3 proposed_order_id = f8
     2 event_id = f8
     2 order_id = f8
     2 encntr_prsnl_reltn_cd = f8
     2 facility_cd = f8
     2 send_to_chart_ind = i2
     2 original_task_uid = vc
     2 rx_renewal_list[*]
       3 rx_renewal_uid = vc
     2 task_status_flag = i2
     2 task_activity_flag = i2
     2 event_class_flag = i2
     2 attachments[*]
       3 name = c255
       3 location_handle = c255
       3 media_identifier = c255
       3 media_version = i4
     2 sender_email = c320
     2 assign_emails[*]
       3 email = c320
       3 cc_ind = i2
       3 selection_nbr = i4
       3 first_name = c100
       3 last_name = c100
       3 display_name = c100
     2 sender_email_display_name = c100
   1 action_dt_tm = dq8
   1 action_tz = i4
   1 skip_validation_ind = i2
 ) WITH protect
 FREE RECORD rep967503
 RECORD rep967503(
   1 invalid_receivers[*]
     2 entity_id = f8
     2 entity_type = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req967731
 RECORD req967731(
   1 action_pool_id = f8
   1 action_personnel_id = f8
   1 action_dt_tm = dq8
   1 action_tz = i4
   1 reminders[*]
     2 action
       3 send_to_recipient_ind = i2
       3 send_to_chart_ind = i2
       3 save_to_chart_ind = i2
     2 subject = c255
     2 text = gvc
     2 person_id = f8
     2 encounter_id = f8
     2 remind_dt_tm = dq8
     2 due_dt_tm = dq8
     2 event_id = f8
     2 event_cd = f8
     2 priority_flag = i2
     2 notify
       3 to_pool_id = f8
       3 to_personnel_id = f8
       3 priority_flag = i2
       3 statuses[*]
         4 status_flag = i2
         4 delay
           5 value = i4
           5 unit_flag = i2
     2 recipients[*]
       3 pool_id = f8
       3 personnel_id = f8
       3 person_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
     2 action_requests[*]
       3 action_request_cd = f8
     2 attachments[*]
       3 name = c255
       3 location_handle = c255
       3 media_identifier = c255
       3 media_version = i4
     2 original_task_uid = vc
     2 result_set_id = f8
     2 task_subtype_cd = f8
   1 skip_validation_ind = i2
 ) WITH protect
 FREE RECORD rep967731
 RECORD rep967731(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 transaction_uid = vc
   1 reminders[*]
     2 task_id = f8
     2 event_id = f8
 ) WITH protect
 FREE RECORD req967511
 RECORD req967511(
   1 notification_list[*]
     2 notification_uid = vc
     2 available_actions_input
       3 prsnl_id = f8
     2 sent_notification_id = f8
     2 task_info
       3 task_id = f8
       3 owner_personnel_id = f8
   1 load_person_name = i2
   1 load_sender_name = i2
   1 load_assign_name = i2
   1 load_available_actions = i2
   1 load_can_change_pt_context = i2
   1 load_result_set_details = i2
 ) WITH protect
 FREE RECORD rep967511
 RECORD rep967511(
   1 get_list_item[*]
     2 notification_uid = vc
     2 person_id = f8
     2 encntr_id = f8
     2 priority_cd = f8
     2 priority_cd_disp = c40
     2 priority_cd_mean = c12
     2 status_cd = f8
     2 status_cd_disp = c40
     2 status_cd_mean = c12
     2 comments = vc
     2 subject_cd = f8
     2 subject_cd_disp = c40
     2 subject_cd_mean = c12
     2 subject = vc
     2 sender_prsnl_id = f8
     2 sender_person_id = f8
     2 sender_pool_id = f8
     2 create_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 notification_type_cd = f8
     2 notification_type_cd_disp = c40
     2 notification_type_cd_mean = c12
     2 order_id = f8
     2 event_id = f8
     2 event_class_cd = f8
     2 event_class_cd_disp = c40
     2 event_class_cd_mean = c12
     2 message_id = f8
     2 assign_prsnl_list[*]
       3 assign_prsnl_id = f8
       3 assign_prsnl_name = vc
       3 cc_ind = i2
     2 assign_pool_list[*]
       3 assign_pool_id = f8
       3 assign_prsnl_id = f8
       3 assign_pool_name = vc
       3 assign_prsnl_name = vc
       3 cc_ind = i2
     2 assign_person_list[*]
       3 person_id = f8
       3 person_name = vc
       3 cc_ind = i2
     2 text = gvc
     2 reminder_dt_tm = dq8
     2 due_dt_tm = dq8
     2 caller_name = vc
     2 caller_phone_number = vc
     2 notify_info[*]
       3 notify_prsnl_id = f8
       3 notify_priority_cd = f8
       3 notify_status_list[*]
         4 notify_status_cd = f8
         4 delay[*]
           5 value = i4
           5 unit_flag = i2
       3 notify_pool_id = f8
     2 person_name = vc
     2 sender_prsnl_name = vc
     2 sender_person_name = vc
     2 sender_pool_name = vc
     2 proposed_order_list[*]
       3 proposed_order_id = f8
       3 available_actions
         4 can_accept = i2
         4 can_reject = i2
         4 can_withdraw = i2
     2 available_actions[*]
       3 can_accept = i2
       3 can_reject = i2
       3 can_withdraw = i2
       3 can_reject_and_replace = i2
       3 can_change_patient = i2
       3 can_verify_patient = i2
     2 event_cd = f8
     2 action_request_list[*]
       3 action_request_cd = f8
     2 assign_text_ind = i2
     2 owner_updt_cnt = i4
     2 pharmacy_identifier = vc
     2 rx_renewal_list[*]
       3 rx_renewal_uid = vc
     2 attachments[*]
       3 name = c255
       3 media_identifier = c255
       3 media_version = i4
     2 assign_email_list[*]
       3 email = vc
       3 cc_ind = i2
       3 display_name = vc
     2 sender_email = vc
     2 sender_email_display_name = vc
     2 previous_task_uid = vc
     2 patient_demog_id = f8
     2 can_change_pt_context = i2
     2 attachment_errors[*]
       3 attachment_description = vc
     2 result_set_id = f8
     2 result_set_details[*]
       3 event_id = f8
       3 event_cd = f8
       3 event_class_cd = f8
       3 event_title_text = vc
       3 publish_flag = i2
       3 result_status_cd = f8
       3 parent_event_id = f8
       3 parent_event_class_cd = f8
       3 relation_type_cd = f8
       3 event_set_cd = f8
       3 event_set_name = vc
     2 task_subtype_cd = f8
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
 DECLARE calladdnotification(null) = i4
 DECLARE calladdreminder(null) = i4
 DECLARE callgetmessagetext(null) = i4
 DECLARE calleventensureserver(null) = i4
 DECLARE formatnotedate(note_dt_tm=f8,time_ind=i2) = vc
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE startpos = i4 WITH protect, noconstant(0)
 DECLARE endpos = i4 WITH protect, noconstant(0)
 DECLARE param = vc WITH protect, noconstant("")
 DECLARE now = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE c_modify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"MODIFY"))
 DECLARE c_perform_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
 DECLARE c_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE c_verify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"VERIFY"))
 DECLARE c_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE c_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE c_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE c_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE c_stat_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1304,"STAT"))
 DECLARE c_routine_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1304,"ROUTINE"))
 DECLARE c_consult_msg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"CONSULT"))
 DECLARE c_reminder_msg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"REMINDER"))
 DECLARE c_phone_msg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"PHONE MSG"))
 SET result->status_data.status = "F"
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 IF (( $2 <= 0.0))
  CALL echo("INVALID TASK ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET result->notify.opened_ind = cnvtint( $17)
 SET result->notify.not_opened_within_days = cnvtint( $18)
 IF ((result->notify.not_opened_within_days > 0))
  SET result->notify.not_opened_within_ind = 1
 ENDIF
 SET result->notify.not_opened_overdue_ind = cnvtint( $19)
 SET result->notify.completed_ind = cnvtint( $24)
 SELECT INTO "NL:"
  FROM task_activity ta
  PLAN (ta
   WHERE (ta.task_id= $2)
    AND ta.active_ind=1)
  HEAD ta.task_id
   result->event_cd = ta.event_cd, result->task_type_cd = ta.task_type_cd
  WITH nocounter, time = 30
 ;end select
 SET result->task_type_disp = uar_get_code_display(result->task_type_cd)
 SET result->task_uid = concat("urn:cerner:mid:object.task:",trim(cnvtlower(curdomain),3),":taskId=",
  trim(replace(cnvtstring( $2),".00","",0),3),",ownerId=",
  trim(replace(cnvtstring( $3),".00","",0),3),",enum=",evaluate(result->task_type_cd,
   c_reminder_msg_cd,"-11",c_consult_msg_cd,"-10",
   "5"),",poolInd=0")
 CALL echo(build("RESULT->TASK_UID:",result->task_uid))
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
  EXECUTE bhs_prax_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->addendum = rep_format_str->param
 ENDIF
 IF (textlen(trim( $9,3)))
  SET req_format_str->param =  $9
  EXECUTE bhs_prax_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->subject = rep_format_str->param
 ENDIF
 DECLARE toprsnlidparam = vc WITH protect, noconstant("")
 DECLARE toprsnlcnt = i4 WITH protect, noconstant(0)
 SET startpos = 1
 SET toprsnlidparam = trim( $7,3)
 CALL echo(build2("TOPRSNLIDPARAM IS: ",toprsnlidparam))
 WHILE (size(toprsnlidparam) > 0)
   SET endpos = (findstring(";",toprsnlidparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(toprsnlidparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,toprsnlidparam)
    CALL echo(build("PARAM:",param))
    SET toprsnlcnt = (toprsnlcnt+ 1)
    SET stat = alterlist(result->to_prsnl,toprsnlcnt)
    SET result->to_prsnl[toprsnlcnt].prsnl_id = cnvtreal(param)
   ENDIF
   SET toprsnlidparam = substring((endpos+ 2),(size(toprsnlidparam) - endpos),toprsnlidparam)
   CALL echo(build("TOPRSNLIDPARAM:",toprsnlidparam))
   CALL echo(build("SIZE(TOPRSNLIDPARAM):",size(toprsnlidparam)))
 ENDWHILE
 DECLARE ccprsnlidparam = vc WITH protect, noconstant("")
 DECLARE ccprsnlcnt = i4 WITH protect, noconstant(0)
 SET startpos = 1
 SET ccprsnlidparam = trim( $8,3)
 CALL echo(build2("CCPRSNLIDPARAM IS: ",ccprsnlidparam))
 WHILE (size(ccprsnlidparam) > 0)
   SET endpos = (findstring(";",ccprsnlidparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(ccprsnlidparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,ccprsnlidparam)
    CALL echo(build("PARAM:",param))
    SET ccprsnlcnt = (ccprsnlcnt+ 1)
    SET stat = alterlist(result->cc_prsnl,ccprsnlcnt)
    SET result->cc_prsnl[ccprsnlcnt].prsnl_id = cnvtreal(param)
   ENDIF
   SET ccprsnlidparam = substring((endpos+ 2),(size(ccprsnlidparam) - endpos),ccprsnlidparam)
   CALL echo(build("CCPRSNLIDPARAM:",ccprsnlidparam))
   CALL echo(build("SIZE(CCPRSNLIDPARAM):",size(ccprsnlidparam)))
 ENDWHILE
 DECLARE actionparam = vc WITH protect, noconstant("")
 DECLARE actioncnt = i4 WITH protect, noconstant(0)
 SET startpos = 1
 SET actionparam = trim( $10,3)
 CALL echo(build2("ACTIONPARAM IS: ",actionparam))
 WHILE (size(actionparam) > 0)
   SET endpos = (findstring(";",actionparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(actionparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,actionparam)
    CALL echo(build("PARAM:",param))
    SET actioncnt = (actioncnt+ 1)
    SET stat = alterlist(result->actions,actioncnt)
    SET result->actions[actioncnt].action_cd = cnvtreal(param)
    SET result->actions[actioncnt].action_disp = uar_get_code_display(result->actions[actioncnt].
     action_cd)
   ENDIF
   SET actionparam = substring((endpos+ 2),(size(actionparam) - endpos),actionparam)
   CALL echo(build("ACTIONPARAM:",actionparam))
   CALL echo(build("SIZE(ACTIONPARAM):",size(actionparam)))
 ENDWHILE
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
   result->performed_prsnl_name = p.name_full_formatted, result->performed_prsnl_name_first = p
   .name_first, result->performed_prsnl_name_last = p.name_last
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
 SET time_str = format(result->performed_dt_tm,"HH:MM:SS;;M")
 CALL echo(build("TIME_STR:",time_str))
 IF (( $16=1))
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
 SET result->from_line = concat("From: ",trim(result->performed_prsnl_name,3)," \par")
 SELECT INTO "NL:"
  FROM person p
  PLAN (p
   WHERE expand(idx,1,size(result->to_prsnl,5),p.person_id,result->to_prsnl[idx].prsnl_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id
  HEAD p.person_id
   pos = locateval(locidx,1,size(result->to_prsnl,5),p.person_id,result->to_prsnl[locidx].prsnl_id)
   IF (pos > 0)
    result->to_prsnl[pos].name = p.name_full_formatted
   ENDIF
  WITH nocounter, expand = 1, time = 30
 ;end select
 IF (size(result->to_prsnl,5) > 0)
  SET result->to_line = " To:"
  FOR (idx = 1 TO size(result->to_prsnl,5))
    SET result->to_line = concat(result->to_line," ",trim(result->to_prsnl[idx].name,3),";")
  ENDFOR
  SET result->to_line = concat(result->to_line,"   \par")
 ENDIF
 SELECT INTO "NL:"
  FROM person p
  PLAN (p
   WHERE expand(idx,1,size(result->cc_prsnl,5),p.person_id,result->cc_prsnl[idx].prsnl_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id
  HEAD p.person_id
   pos = locateval(locidx,1,size(result->cc_prsnl,5),p.person_id,result->cc_prsnl[locidx].prsnl_id)
   IF (pos > 0)
    result->cc_prsnl[pos].name = p.name_full_formatted
   ENDIF
  WITH nocounter, expand = 1, time = 30
 ;end select
 IF (size(result->cc_prsnl,5) > 0)
  SET result->cc_line = " Cc:"
  FOR (idx = 1 TO size(result->cc_prsnl,5))
    SET result->cc_line = concat(result->cc_line," ",trim(result->cc_prsnl[idx].name,3),";")
  ENDFOR
  SET result->cc_line = concat(result->cc_line,"   \par")
 ENDIF
 IF (textlen(trim(result->subject,3)) > 0)
  SET result->subject_line = concat(" Subject: ",result->subject," \par")
 ENDIF
 SET result->sent_line = concat(" Sent: ",trim(formatnotedate(result->performed_dt_tm,1),3),evaluate(
    $6,c_stat_cd," !\par","\par"))
 IF (size(result->actions,5) > 0)
  SET result->action_line = " \b Actions:"
  FOR (idx = 1 TO size(result->actions,5))
    SET result->action_line = concat(result->action_line,evaluate(idx,1," ",", "),result->actions[idx
     ].action_disp)
  ENDFOR
  SET result->action_line = concat(result->action_line," \b0 \par")
 ENDIF
 IF (textlen(trim( $12,3)) > 0
  AND cnvtdatetime( $12) > 0)
  SET result->due_line = concat(" Due Date/Time: ",formatnotedate(cnvtdatetime( $12),1)," \par")
 ENDIF
 SET result->addendum_blob = nullterm(concat(
   "{\rtf1\ansi\ansicpg1252\uc1\deff0{\fonttbl  {\f0\fnil\fcharset0\fprq2 Arial;}  {\",
   "f1\fswiss\fcharset0\fprq2 Arial;}  {\f2\froman\fcharset2\fprq2 Symbol;}}  {\colo",
   "rtbl;\red0\green0\blue0;}  {\stylesheet{\s0\itap0\nowidctlpar\f0\fs24 [Normal];}",
   "{\*\cs10\additive Default Paragraph Font;}}  {\*\generator TX_RTF32 18.0.541.501",
   ";}  \paperw15000\paperh15840\margl1440\margt1440\margr1440\margb1440\deftab1134\",
   "widowctrl\lytexcttp\formshade  {\*\background{\shp{\*\shpinst\shpleft0\shptop0\s",
   "hpright0\shpbottom0\shpfhdr0\shpbxmargin\shpbxignore\shpbymargin\shpbyignore\shp",
   "wr0\shpwrk0\shpfblwtxt1\shplid1025{\sp{\sn shapeType}{\sv 1}}{\sp{\sn fFlipH}{\s",
   "v 0}}{\sp{\sn fFlipV}{\sv 0}}{\sp{\sn fillColor}{\sv 16777215}}{\sp{\sn fFilled}",
   "{\sv 1}}{\sp{\sn lineWidth}{\sv 0}}{\sp{\sn fLine}{\sv 0}}{\sp{\sn fBackground}{",
   "\sv 1}}{\sp{\sn fLayoutInCell}{\sv 1}}}}}\sectd  \headery720\footery720\pgwsxn15",
   "000\pghsxn15840\marglsxn1440\margtsxn1440\margrsxn1440\margbsxn1440\pgbrdropt32\",
   "pard\itap0\nowidctlpar\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx",
   "6480\tx7200\tx7920\tx8640\tx9360\tx10080\plain\f1\fs20 \par---------------------\par ",result->
   from_line,
   result->to_line,result->cc_line,result->sent_line,result->subject_line,result->action_line,
   result->due_line,"\pard\itap0\nowidctlpar\plain\f1\fs20\cf1\par ",result->addendum,"\par \par}"))
 CALL echo(build("RESULT->ADDENDUM_BLOB:",result->addendum_blob))
 SET stat = callgetmessagetext(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF ((result->task_type_cd=c_reminder_msg_cd))
  SET stat = calladdreminder(null)
 ELSE
  SET stat = calladdnotification(null)
 ENDIF
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF ((result->parent_event.event_id > 0))
  SET stat = calleventensureserver(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
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
    v1, row + 1, v2 = build("<EventID>",trim(replace(cnvtstring(result->new_event_id),".000000","",0),
      3),"</EventID>"),
    col + 1, v2, row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req967503
 FREE RECORD rep967503
 FREE RECORD req967731
 FREE RECORD rep967731
 FREE RECORD req967511
 FREE RECORD rep967511
 FREE RECORD req1000012
 FREE RECORD rep1000012
 FREE RECORD i_request
 FREE RECORD i_reply
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 SUBROUTINE calladdnotification(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(967100)
   DECLARE requestid = i4 WITH constant(967503)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE apcnt = i4 WITH protect, noconstant(0)
   DECLARE ncnt = i4 WITH protect, noconstant(0)
   DECLARE c_opened_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OPENED"))
   DECLARE c_overdue_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OVERDUE"))
   DECLARE c_complete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"COMPLETE"))
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
   EXECUTE bhs_prax_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET stat = alterlist(req967503->message_list,1)
   SET req967503->message_list[1].person_id = result->person_id
   SET req967503->message_list[1].encntr_id = result->encntr_id
   SET req967503->message_list[1].task_type_cd = result->task_type_cd
   SET req967503->message_list[1].priority_cd =  $6
   IF ((result->task_type_cd=c_phone_msg_cd))
    SET req967503->message_list[1].callername =  $13
    SET req967503->message_list[1].callerphone =  $14
   ENDIF
   SET stat = alterlist(req967503->message_list[1].assign_prsnl_list,(size(result->to_prsnl,5)+ size(
     result->cc_prsnl,5)))
   FOR (idx = 1 TO size(result->to_prsnl,5))
     SET apcnt = (apcnt+ 1)
     SET req967503->message_list[1].assign_prsnl_list[apcnt].assign_prsnl_id = result->to_prsnl[idx].
     prsnl_id
     SET req967503->message_list[1].assign_prsnl_list[apcnt].cc_ind = 0
     SET req967503->message_list[1].assign_prsnl_list[apcnt].selection_nbr = apcnt
   ENDFOR
   FOR (idx = 1 TO size(result->cc_prsnl,5))
     SET apcnt = (apcnt+ 1)
     SET req967503->message_list[1].assign_prsnl_list[apcnt].assign_prsnl_id = result->cc_prsnl[idx].
     prsnl_id
     SET req967503->message_list[1].assign_prsnl_list[apcnt].cc_ind = 1
     SET req967503->message_list[1].assign_prsnl_list[apcnt].selection_nbr = apcnt
   ENDFOR
   SET stat = alterlist(req967503->message_list[1].action_request_list,size(result->actions,5))
   FOR (idx = 1 TO size(result->actions,5))
     SET req967503->message_list[1].action_request_list[idx].action_request_cd = result->actions[idx]
     .action_cd
   ENDFOR
   SET req967503->message_list[1].reminder_dt_tm = cnvtdatetime( $11)
   SET req967503->message_list[1].due_dt_tm = cnvtdatetime( $12)
   SET req967503->message_list[1].save_to_chart_ind = result->save_to_chart_ind
   SET req967503->message_list[1].msg_sender_prsnl_id =  $3
   SET req967503->message_list[1].msg_subject = result->subject
   IF ((result->parent_event.event_id > 0))
    SET req967503->message_list[1].event_id = result->parent_event.event_id
   ELSE
    SET req967503->message_list[1].msg_text = result->addendum_blob
   ENDIF
   SET req967503->message_list[1].order_id = result->order_id
   SET req967503->message_list[1].event_cd = result->event_cd
   SET req967503->message_list[1].original_task_uid = result->task_uid
   SET req967503->action_dt_tm = result->performed_dt_tm
   SET req967503->action_tz = app_tz
   SET req967503->skip_validation_ind = 1
   SET req967503->message_list[1].notify_info.notify_prsnl_id =  $20
   SET req967503->message_list[1].notify_info.notify_priority_cd =  $21
   IF ((result->notify.opened_ind=1))
    SET ncnt = (ncnt+ 1)
    SET stat = alterlist(req967503->message_list[1].notify_info.notify_status_list,ncnt)
    SET req967503->message_list[1].notify_info.notify_status_list[ncnt].notify_status_cd =
    c_opened_cd
   ENDIF
   IF ((result->notify.not_opened_within_ind=1))
    SET ncnt = (ncnt+ 1)
    SET stat = alterlist(req967503->message_list[1].notify_info.notify_status_list,ncnt)
    SET req967503->message_list[1].notify_info.notify_status_list[ncnt].notify_status_cd =
    c_opened_cd
    SET req967503->message_list[1].notify_info.notify_status_list[ncnt].delay.value = result->notify.
    not_opened_within_days
    SET req967503->message_list[1].notify_info.notify_status_list[ncnt].delay.unit_flag = 1
   ENDIF
   IF ((result->notify.completed_ind=1))
    SET ncnt = (ncnt+ 1)
    SET stat = alterlist(req967503->message_list[1].notify_info.notify_status_list,ncnt)
    SET req967503->message_list[1].notify_info.notify_status_list[ncnt].notify_status_cd =
    c_complete_cd
   ENDIF
   IF ((result->notify.not_opened_overdue_ind=1))
    SET ncnt = (ncnt+ 1)
    SET stat = alterlist(req967503->message_list[1].notify_info.notify_status_list,ncnt)
    SET req967503->message_list[1].notify_info.notify_status_list[ncnt].notify_status_cd =
    c_overdue_cd
   ENDIF
   CALL echorecord(req967503)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967503,
    "REC",rep967503,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967503)
   IF ((rep967503->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE callgetmessagetext(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(967100)
   DECLARE requestid = i4 WITH constant(967511)
   DECLARE errmsg = vc WITH protect, noconstant("")
   SET stat = alterlist(req967511->notification_list,1)
   SET req967511->notification_list[1].notification_uid = result->task_uid
   SET req967511->notification_list[1].available_actions_input.prsnl_id =  $3
   SET req967511->load_person_name = 1
   SET req967511->load_sender_name = 1
   SET req967511->load_assign_name = 1
   SET req967511->load_available_actions = 1
   SET req967511->load_can_change_pt_context = 1
   SET req967511->load_result_set_details = 1
   CALL echorecord(req967511)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967511,
    "REC",rep967511,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967511)
   IF ((rep967511->status_data.status="S"))
    IF (size(rep967511->get_list_item,5) > 0)
     SET result->encntr_id = rep967511->get_list_item[1].encntr_id
     SET result->person_id = rep967511->get_list_item[1].person_id
     SET result->order_id = rep967511->get_list_item[1].order_id
     SET result->parent_event.event_id = rep967511->get_list_item[1].event_id
     IF ((result->parent_event.event_id=0))
      SET result->save_to_chart_ind =  $22
      SET startpos = findstring("---------------------",rep967511->get_list_item[1].text,1)
      SET endpos = findstring("\par\pard\itap0\nowidctlpar\par",rep967511->get_list_item[1].text,
       startpos)
      IF (startpos > 0
       AND endpos > 0)
       SET result->orig_msg_body = substring(startpos,endpos,rep967511->get_list_item[1].text)
       CALL echo(build("RESULT->ORIG_MSG_BODY:",result->orig_msg_body))
       SET result->addendum_blob = nullterm(concat(substring(1,(size(result->addendum_blob) - 1),
          result->addendum_blob),result->orig_msg_body))
       CALL echo(build("RESULT->ADDENDUM_BLOB:",result->addendum_blob))
      ENDIF
     ENDIF
    ENDIF
    RETURN(success)
   ENDIF
   RETURN(fail)
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
   DECLARE childcnt = i4 WITH protect, noconstant(0)
   DECLARE outbuf = c32768 WITH protect, noconstant("")
   DECLARE retlen = i4 WITH protect, noconstant(0)
   DECLARE fill_loops = i4 WITH protect, noconstant(0)
   DECLARE offset = i4 WITH protect, noconstant(0)
   DECLARE newsize = i4 WITH protect, noconstant(0)
   DECLARE finlen = i4 WITH protect, noconstant(0)
   DECLARE xlen = i4 WITH protect, noconstant(0)
   DECLARE segmentlen = i4 WITH protect, constant(32768)
   FREE RECORD blobrec
   RECORD blobrec(
     1 good_blob = gvc
   ) WITH protect
   SELECT INTO "NL:"
    FROM clinical_event ce
    PLAN (ce
     WHERE (ce.event_id=result->parent_event.event_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime(now)
      AND ce.valid_from_dt_tm <= cnvtdatetime(now))
    HEAD ce.event_id
     result->parent_event.series_ref_nbr = ce.series_ref_nbr, result->parent_event.event_class_cd =
     ce.event_class_cd, result->parent_event.event_cd = ce.event_cd,
     result->parent_event.event_end_dt_tm = ce.event_end_dt_tm, result->parent_event.record_status_cd
      = ce.record_status_cd, result->parent_event.result_status_cd = ce.result_status_cd,
     result->parent_event.authentic_flag = ce.authentic_flag, result->parent_event.publish_flag = ce
     .publish_flag, result->parent_event.event_title_text = ce.event_title_text,
     result->parent_event.collating_seq = ce.collating_seq, result->parent_event.updt_cnt = ce
     .updt_cnt, result->parent_event.entry_mode_cd = ce.entry_mode_cd,
     result->parent_event.contributor_system_cd = ce.contributor_system_cd
    WITH nocounter, time = 30
   ;end select
   DECLARE event_prsnl_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM ce_event_prsnl cep
    PLAN (cep
     WHERE (cep.event_id=result->parent_event.event_id))
    ORDER BY cep.action_dt_tm, cep.event_prsnl_id, cep.valid_from_dt_tm DESC
    HEAD cep.event_prsnl_id
     event_prsnl_cnt = (event_prsnl_cnt+ 1), stat = alterlist(result->parent_event.event_prsnl,
      event_prsnl_cnt), result->parent_event.event_prsnl[event_prsnl_cnt].event_prsnl_id = cep
     .event_prsnl_id,
     result->parent_event.event_prsnl[event_prsnl_cnt].action_dt_tm = cep.action_dt_tm, result->
     parent_event.event_prsnl[event_prsnl_cnt].action_type_cd = cep.action_type_cd, result->
     parent_event.event_prsnl[event_prsnl_cnt].action_prsnl_id = cep.action_prsnl_id,
     result->parent_event.event_prsnl[event_prsnl_cnt].action_status_cd = cep.action_status_cd,
     result->parent_event.event_prsnl[event_prsnl_cnt].action_tz = cep.action_tz, result->
     parent_event.event_prsnl[event_prsnl_cnt].action_comment = cep.action_comment,
     result->parent_event.event_prsnl[event_prsnl_cnt].request_comment = cep.request_comment
    WITH nocounter, time = 30
   ;end select
   SELECT INTO "NL:"
    FROM clinical_event ce,
     ce_blob cb
    PLAN (ce
     WHERE (ce.parent_event_id=result->parent_event.event_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime(now)
      AND ce.valid_from_dt_tm <= cnvtdatetime(now)
      AND ce.event_reltn_cd=c_child_cd)
     JOIN (cb
     WHERE cb.event_id=ce.event_id
      AND ((cb.valid_until_dt_tm+ 0) > cnvtdatetime(now)))
    ORDER BY ce.collating_seq, cb.event_id, cb.blob_seq_num
    HEAD ce.clinical_event_id
     childcnt = (childcnt+ 1), stat = alterlist(result->child_events,childcnt), result->child_events[
     childcnt].event_id = ce.event_id,
     result->child_events[childcnt].view_level = ce.view_level, result->child_events[childcnt].
     series_ref_nbr = ce.series_ref_nbr, result->child_events[childcnt].contributor_system_cd = ce
     .contributor_system_cd,
     result->child_events[childcnt].reference_nbr = ce.reference_nbr, result->child_events[childcnt].
     event_class_cd = ce.event_class_cd, result->child_events[childcnt].event_cd = ce.event_cd,
     result->child_events[childcnt].event_end_dt_tm = ce.event_end_dt_tm, result->child_events[
     childcnt].record_status_cd = ce.record_status_cd, result->child_events[childcnt].
     result_status_cd = ce.result_status_cd,
     result->child_events[childcnt].authentic_flag = ce.authentic_flag, result->child_events[childcnt
     ].publish_flag = ce.publish_flag, result->child_events[childcnt].updt_cnt = ce.updt_cnt,
     result->child_events[childcnt].entry_mode_cd = ce.entry_mode_cd, result->child_events[childcnt].
     collating_seq = ce.collating_seq
    HEAD cb.event_id
     result->child_events[childcnt].blob.compression_cd = cb.compression_cd, result->child_events[
     childcnt].blob.length = cb.blob_length, stat = initrec(blobrec),
     fill_loops = (cb.blob_length/ segmentlen),
     CALL echo(build("FILL_LOOPS:",fill_loops))
     FOR (idx = 1 TO fill_loops)
       result->child_events[childcnt].blob.contents = notrim(concat(notrim(result->child_events[
          childcnt].blob.contents),notrim(fillstring(32768," "))))
     ENDFOR
     finlen = mod(cb.blob_length,segmentlen), result->child_events[childcnt].blob.contents = notrim(
      concat(notrim(result->child_events[childcnt].blob.contents),notrim(substring(1,finlen,
         fillstring(32768," ")))))
    DETAIL
     retlen = 1, offset = 0
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,cb.blob_contents), offset = (offset+ retlen)
       IF (retlen != 0)
        xlen = (findstring("ocf_blob",outbuf,1) - 1)
        IF (xlen < 1)
         xlen = retlen
        ENDIF
        blobrec->good_blob = notrim(concat(notrim(blobrec->good_blob),notrim(substring(1,xlen,outbuf)
           )))
       ENDIF
     ENDWHILE
    FOOT  cb.event_id
     newsize = 0, blobrec->good_blob = concat(notrim(blobrec->good_blob),"ocf_blob"), blob_un =
     uar_ocf_uncompress(blobrec->good_blob,size(blobrec->good_blob),result->child_events[childcnt].
      blob.contents,size(result->child_events[childcnt].blob.contents),newsize),
     CALL echo(build("RESULT->CHILD_EVENTS[",childcnt,"]->BLOB->CONTENTS SIZE: ",size(result->
       child_events[childcnt].blob.contents)))
    FOOT  ce.clinical_event_id
     row + 0
    WITH nocounter, rdbarrayfetch = 1, time = 30
   ;end select
   FREE RECORD blobrec
   SELECT INTO "NL:"
    FROM ce_event_prsnl cep
    PLAN (cep
     WHERE expand(idx,1,size(result->child_events,5),cep.event_id,result->child_events[idx].event_id)
     )
    ORDER BY cep.event_id, cep.action_dt_tm, cep.event_prsnl_id,
     cep.valid_from_dt_tm DESC
    HEAD cep.event_id
     pos = locateval(locidx,1,size(result->child_events,5),cep.event_id,result->child_events[locidx].
      event_id), event_prsnl_cnt = 0
    HEAD cep.event_prsnl_id
     IF (pos > 0)
      event_prsnl_cnt = (event_prsnl_cnt+ 1), stat = alterlist(result->child_events[pos].event_prsnl,
       event_prsnl_cnt), result->child_events[pos].event_prsnl[event_prsnl_cnt].event_prsnl_id = cep
      .event_prsnl_id,
      result->child_events[pos].event_prsnl[event_prsnl_cnt].action_dt_tm = cep.action_dt_tm, result
      ->child_events[pos].event_prsnl[event_prsnl_cnt].action_type_cd = cep.action_type_cd, result->
      child_events[pos].event_prsnl[event_prsnl_cnt].action_prsnl_id = cep.action_prsnl_id,
      result->child_events[pos].event_prsnl[event_prsnl_cnt].action_status_cd = cep.action_status_cd,
      result->child_events[pos].event_prsnl[event_prsnl_cnt].action_tz = cep.action_tz, result->
      child_events[pos].event_prsnl[event_prsnl_cnt].action_comment = cep.action_comment,
      result->child_events[pos].event_prsnl[event_prsnl_cnt].request_comment = cep.request_comment
     ENDIF
    WITH nocounter, expand = 1, time = 30
   ;end select
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
   SET iret = uar_srvsetshort(hreq,"ENSURE_TYPE",ensure_type_upd)
   SET hcetype = uar_srvcreatetypefrom(hreq,"CLIN_EVENT")
   SET hcestruct = uar_srvgetstruct(hreq,"CLIN_EVENT")
   SET iret = uar_srvsetdouble(hcestruct,"EVENT_ID",result->parent_event.event_id)
   SET iret = uar_srvsetlong(hcestruct,"VIEW_LEVEL",1)
   SET iret = uar_srvsetstring(hcestruct,"SERIES_REF_NBR",result->parent_event.series_ref_nbr)
   SET iret = uar_srvsetdouble(hcestruct,"ENCNTR_ID",result->encntr_id)
   SET iret = uar_srvsetdouble(hcestruct,"PERSON_ID",result->person_id)
   SET iret = uar_srvsetdouble(hcestruct,"CONTRIBUTOR_SYSTEM_CD",result->parent_event.
    contributor_system_cd)
   SET iret = uar_srvsetdouble(hcestruct,"PARENT_EVENT_ID",result->parent_event.event_id)
   SET iret = uar_srvsetdouble(hcestruct,"EVENT_CLASS_CD",result->parent_event.event_class_cd)
   SET iret = uar_srvsetdouble(hcestruct,"EVENT_CD",result->parent_event.event_cd)
   SET iret = uar_srvsetdouble(hcestruct,"EVENT_RELTN_CD",c_root_cd)
   SET iret = uar_srvsetdate(hcestruct,"EVENT_END_DT_TM",cnvtdatetime(result->parent_event.
     event_end_dt_tm))
   SET iret = uar_srvsetdouble(hcestruct,"RECORD_STATUS_CD",c_active_cd)
   SET iret = uar_srvsetdouble(hcestruct,"RESULT_STATUS_CD",c_modified_cd)
   SET iret = uar_srvsetshort(hcestruct,"AUTHENTIC_FLAG",result->parent_event.authentic_flag)
   SET iret = uar_srvsetshort(hcestruct,"PUBLISH_FLAG",result->parent_event.publish_flag)
   SET iret = uar_srvsetstring(hcestruct,"EVENT_TITLE_TEXT",result->parent_event.event_title_text)
   SET iret = uar_srvsetstring(hcestruct,"COLLATING_SEQ",result->parent_event.collating_seq)
   SET iret = uar_srvsetlong(hcestruct,"UPDT_CNT",result->parent_event.updt_cnt)
   SET iret = uar_srvsetdouble(hcestruct,"ENTRY_MODE_CD",result->parent_event.entry_mode_cd)
   FOR (idx = 1 TO size(result->parent_event.event_prsnl,5))
     SET hprsnllistitem = uar_srvadditem(hcestruct,"EVENT_PRSNL_LIST")
     SET iret = uar_srvsetdouble(hprsnllistitem,"EVENT_PRSNL_ID",result->parent_event.event_prsnl[idx
      ].event_prsnl_id)
     SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_TYPE_CD",result->parent_event.event_prsnl[idx
      ].action_type_cd)
     SET iret = uar_srvsetdate(hprsnllistitem,"ACTION_DT_TM",cnvtdatetime(result->parent_event.
       event_prsnl[idx].action_dt_tm))
     SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_PRSNL_ID",result->parent_event.event_prsnl[
      idx].action_prsnl_id)
     SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_STATUS_CD",result->parent_event.event_prsnl[
      idx].action_status_cd)
     SET iret = uar_srvsetlong(hprsnllistitem,"ACTION_TZ",result->parent_event.event_prsnl[idx].
      action_tz)
     SET iret = uar_srvsetstring(hprsnllistitem,"ACTION_COMMENT",result->parent_event.event_prsnl[idx
      ].action_comment)
     SET iret = uar_srvsetstring(hprsnllistitem,"REQUEST_COMMENT",result->parent_event.event_prsnl[
      idx].request_comment)
   ENDFOR
   SET iret = uar_srvbinditemtype(hcestruct,"CHILD_EVENT_LIST",hcetype)
   FOR (idx = 1 TO size(result->child_events,5))
     SET hchildlistitem = uar_srvadditem(hcestruct,"CHILD_EVENT_LIST")
     SET iret = uar_srvsetdouble(hchildlistitem,"EVENT_ID",result->child_events[idx].event_id)
     SET iret = uar_srvsetstring(hchildlistitem,"SERIES_REF_NBR",result->child_events[idx].
      series_ref_nbr)
     SET iret = uar_srvsetdouble(hchildlistitem,"PERSON_ID",result->person_id)
     SET iret = uar_srvsetdouble(hchildlistitem,"ENCNTR_ID",result->encntr_id)
     SET iret = uar_srvsetdouble(hchildlistitem,"CONTRIBUTOR_SYSTEM_CD",result->child_events[idx].
      contributor_system_cd)
     SET iret = uar_srvsetstring(hchildlistitem,"REFERENCE_NBR",result->child_events[idx].
      reference_nbr)
     SET iret = uar_srvsetdouble(hchildlistitem,"PARENT_EVENT_ID",result->parent_event.event_id)
     SET iret = uar_srvsetdouble(hchildlistitem,"EVENT_CLASS_CD",result->child_events[idx].
      event_class_cd)
     SET iret = uar_srvsetdouble(hchildlistitem,"EVENT_CD",result->child_events[idx].event_cd)
     SET iret = uar_srvsetdouble(hchildlistitem,"EVENT_RELTN_CD",c_child_cd)
     SET iret = uar_srvsetdate(hchildlistitem,"EVENT_END_DT_TM",cnvtdatetime(result->child_events[idx
       ].event_end_dt_tm))
     SET iret = uar_srvsetdouble(hchildlistitem,"RECORD_STATUS_CD",result->child_events[idx].
      record_status_cd)
     SET iret = uar_srvsetdouble(hchildlistitem,"RESULT_STATUS_CD",result->child_events[idx].
      result_status_cd)
     SET iret = uar_srvsetshort(hchildlistitem,"AUTHENTIC_FLAG",result->child_events[idx].
      authentic_flag)
     SET iret = uar_srvsetshort(hchildlistitem,"PUBLISH_FLAG",result->child_events[idx].publish_flag)
     SET iret = uar_srvsetstring(hchildlistitem,"COLLATING_SEQ",result->child_events[idx].
      collating_seq)
     SET iret = uar_srvsetshort(hchildlistitem,"UPDT_CNT",result->child_events[idx].updt_cnt)
     SET iret = uar_srvsetdouble(hchildlistitem,"ENTRY_MODE_CD",result->child_events[idx].
      entry_mode_cd)
     SET hblobresultitem = uar_srvadditem(hchildlistitem,"BLOB_RESULT")
     SET iret = uar_srvsetdouble(hblobresultitem,"SUCCESSION_TYPE_CD",evaluate(idx,1,c_final_cd,
       c_interim_cd))
     SET iret = uar_srvsetdouble(hblobresultitem,"STORAGE_CD",c_blob_cd)
     SET iret = uar_srvsetdouble(hblobresultitem,"FORMAT_CD",c_rtf_cd)
     SET hblobitem = uar_srvadditem(hblobresultitem,"BLOB")
     SET iret = uar_srvsetdouble(hblobitem,"COMPRESSION_CD",result->child_events[idx].blob.
      compression_cd)
     SET iret = uar_srvsetasis(hblobitem,"BLOB_CONTENTS",result->child_events[idx].blob.contents,size
      (result->child_events[idx].blob.contents,1))
     SET iret = uar_srvsetlong(hblobitem,"BLOB_LENGTH",size(result->child_events[idx].blob.contents,1
       ))
     FOR (jdx = 1 TO size(result->child_events[idx].event_prsnl,5))
       SET hprsnllistitem = uar_srvadditem(hchildlistitem,"EVENT_PRSNL_LIST")
       SET iret = uar_srvsetdouble(hprsnllistitem,"EVENT_PRSNL_ID",result->child_events[idx].
        event_prsnl[jdx].event_prsnl_id)
       SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_TYPE_CD",result->child_events[idx].
        event_prsnl[jdx].action_type_cd)
       SET iret = uar_srvsetdate(hprsnllistitem,"ACTION_DT_TM",cnvtdatetime(result->child_events[idx]
         .event_prsnl[jdx].action_dt_tm))
       SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_PRSNL_ID",result->child_events[idx].
        event_prsnl[jdx].action_prsnl_id)
       SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_STATUS_CD",result->child_events[idx].
        event_prsnl[jdx].action_status_cd)
       SET iret = uar_srvsetlong(hprsnllistitem,"ACTION_TZ",result->child_events[idx].event_prsnl[jdx
        ].action_tz)
       SET iret = uar_srvsetstring(hprsnllistitem,"ACTION_COMMENT",result->child_events[idx].
        event_prsnl[jdx].action_comment)
       SET iret = uar_srvsetstring(hprsnllistitem,"REQUEST_COMMENT",result->child_events[idx].
        event_prsnl[jdx].request_comment)
     ENDFOR
   ENDFOR
   DECLARE col_seq = vc WITH protect, constant(cnvtstring((size(result->child_events,5)+ 1)))
   CALL echo(build("COL_SEQ:",col_seq))
   DECLARE ref_nbr = vc WITH protect, constant( $15)
   CALL echo(build("REF_NBR:",ref_nbr))
   SET hchildlistitem = uar_srvadditem(hcestruct,"CHILD_EVENT_LIST")
   SET iret = uar_srvsetdouble(hchildlistitem,"PERSON_ID",result->person_id)
   SET iret = uar_srvsetdouble(hchildlistitem,"ENCNTR_ID",result->encntr_id)
   SET iret = uar_srvsetdouble(hchildlistitem,"CONTRIBUTOR_SYSTEM_CD",c_powerchart_cd)
   SET iret = uar_srvsetstring(hchildlistitem,"REFERENCE_NBR",ref_nbr)
   SET iret = uar_srvsetdouble(hchildlistitem,"PARENT_EVENT_ID",result->parent_event.event_id)
   SET iret = uar_srvsetdouble(hchildlistitem,"EVENT_CLASS_CD",c_doc_cd)
   SET iret = uar_srvsetdouble(hchildlistitem,"EVENT_CD",result->event_cd)
   SET iret = uar_srvsetdouble(hchildlistitem,"EVENT_RELTN_CD",c_child_cd)
   SET iret = uar_srvsetdate(hchildlistitem,"EVENT_END_DT_TM",cnvtdatetime(result->parent_event.
     event_end_dt_tm))
   SET iret = uar_srvsetdouble(hchildlistitem,"RECORD_STATUS_CD",c_active_cd)
   SET iret = uar_srvsetdouble(hchildlistitem,"RESULT_STATUS_CD",c_modified_cd)
   SET iret = uar_srvsetshort(hchildlistitem,"AUTHENTIC_FLAG",1)
   SET iret = uar_srvsetshort(hchildlistitem,"PUBLISH_FLAG",1)
   SET iret = uar_srvsetstring(hchildlistitem,"EVENT_TITLE_TEXT",result->new_event_title_text)
   SET iret = uar_srvsetstring(hchildlistitem,"COLLATING_SEQ",col_seq)
   SET hblobresultitem = uar_srvadditem(hchildlistitem,"BLOB_RESULT")
   SET iret = uar_srvsetdouble(hblobresultitem,"SUCCESSION_TYPE_CD",c_interim_cd)
   SET iret = uar_srvsetdouble(hblobresultitem,"STORAGE_CD",c_blob_cd)
   SET iret = uar_srvsetdouble(hblobresultitem,"FORMAT_CD",c_rtf_cd)
   SET hblobitem = uar_srvadditem(hblobresultitem,"BLOB")
   SET iret = uar_srvsetasis(hblobitem,"BLOB_CONTENTS",result->addendum_blob,size(result->
     addendum_blob,1))
   SET iret = uar_srvsetlong(hblobitem,"BLOB_LENGTH",size(result->addendum_blob,1))
   SET hprsnllistitem = uar_srvadditem(hchildlistitem,"EVENT_PRSNL_LIST")
   SET iret = uar_srvsetdouble(hprsnllistitem,"ACTION_TYPE_CD",c_perform_cd)
   SET iret = uar_srvsetdate(hprsnllistitem,"ACTION_DT_TM",cnvtdatetime(result->performed_dt_tm))
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
 SUBROUTINE formatnotedate(note_dt_tm,time_ind)
   DECLARE month_str = vc WITH protect, noconstant("")
   DECLARE day_str = vc WITH protect, noconstant("")
   DECLARE year_str = vc WITH protect, noconstant("")
   DECLARE time_str = vc WITH protect, noconstant("")
   DECLARE note_date_str = vc WITH protect, noconstant("")
   CALL echo(build("NOTE_DT_TM: ",format(note_dt_tm,";;Q")))
   SET month_str = format(note_dt_tm,"MM;;D")
   IF (substring(1,1,month_str)="0")
    SET month_str = substring(2,1,month_str)
   ENDIF
   CALL echo(build("MONTH_STR:",month_str))
   SET day_str = format(note_dt_tm,"DD;;D")
   IF (substring(1,1,day_str)="0")
    SET day_str = substring(2,1,day_str)
   ENDIF
   CALL echo(build("DAY_STR:",day_str))
   SET year_str = format(note_dt_tm,"YYYY;;D")
   CALL echo(build("YEAR_STR:",year_str))
   SET note_date_str = concat(month_str,"/",day_str,"/",year_str)
   IF (time_ind=1)
    SET time_str = format(note_dt_tm,"HH:MM:SS;;M")
    CALL echo(build("TIME_STR:",time_str))
    SET note_date_str = concat(note_date_str," ",time_str)
   ENDIF
   CALL echo(build("NOTE_DATE_STR:",note_date_str))
   RETURN(note_date_str)
 END ;Subroutine
 SUBROUTINE calladdreminder(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(967100)
   DECLARE requestid = i4 WITH constant(967731)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE apcnt = i4 WITH protect, noconstant(0)
   DECLARE ncnt = i4 WITH protect, noconstant(0)
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
   EXECUTE bhs_prax_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET req967731->action_personnel_id =  $3
   SET req967731->action_dt_tm = result->performed_dt_tm
   SET req967731->action_tz = curtimezoneapp
   SET req967731->skip_validation_ind = 0
   SET stat = alterlist(req967731->reminders,1)
   IF (( $23=1))
    SET req967731->reminders[1].action.send_to_recipient_ind = 1
   ELSEIF (( $23=2))
    SET req967731->reminders[1].action.send_to_chart_ind = 1
   ENDIF
   SET req967731->reminders[1].action.save_to_chart_ind = result->save_to_chart_ind
   SET req967731->reminders[1].subject = result->subject
   IF ((result->parent_event.event_id > 0))
    SET req967731->reminders[1].event_id = result->parent_event.event_id
   ELSE
    SET req967731->reminders[1].text = result->addendum_blob
   ENDIF
   SET req967731->reminders[1].person_id = result->person_id
   SET req967731->reminders[1].encounter_id = result->encntr_id
   SET req967731->reminders[1].remind_dt_tm = cnvtdatetime( $11)
   SET req967731->reminders[1].due_dt_tm = cnvtdatetime( $12)
   IF ((((result->parent_event.event_id > 0)) OR ((result->save_to_chart_ind=1))) )
    SET req967731->reminders[1].event_cd = result->event_cd
   ENDIF
   SET req967731->reminders[1].priority_flag = evaluate( $6,c_stat_cd,1,c_routine_cd,2,
    2)
   SET req967731->reminders[1].notify.to_personnel_id =  $20
   SET req967731->reminders[1].notify.priority_flag = evaluate( $21,c_stat_cd,1,c_routine_cd,0,
    0)
   IF ((result->notify.opened_ind=1))
    SET ncnt = (ncnt+ 1)
    SET stat = alterlist(req967731->reminders[1].notify.statuses,ncnt)
    SET req967731->reminders[1].notify.statuses[ncnt].status_flag = 2
   ENDIF
   IF ((result->notify.not_opened_within_ind=1))
    SET ncnt = (ncnt+ 1)
    SET stat = alterlist(req967731->reminders[1].notify.statuses,ncnt)
    SET req967731->reminders[1].notify.statuses[ncnt].status_flag = 2
    SET req967731->reminders[1].notify.statuses[ncnt].delay.value = result->notify.
    not_opened_within_days
    SET req967731->reminders[1].notify.statuses[ncnt].delay.unit_flag = 1
   ENDIF
   IF ((result->notify.completed_ind=1))
    SET ncnt = (ncnt+ 1)
    SET stat = alterlist(req967731->reminders[1].notify.statuses,ncnt)
    SET req967731->reminders[1].notify.statuses[ncnt].status_flag = 4
   ENDIF
   IF ((result->notify.not_opened_overdue_ind=1))
    SET ncnt = (ncnt+ 1)
    SET stat = alterlist(req967731->reminders[1].notify.statuses,ncnt)
    SET req967731->reminders[1].notify.statuses[ncnt].status_flag = 5
   ENDIF
   SET stat = alterlist(req967731->reminders[1].recipients,(size(result->to_prsnl,5)+ size(result->
     cc_prsnl,5)))
   FOR (idx = 1 TO size(result->to_prsnl,5))
     SET apcnt = (apcnt+ 1)
     SET req967731->reminders[1].recipients[apcnt].personnel_id = result->to_prsnl[idx].prsnl_id
     SET req967731->reminders[1].recipients[apcnt].cc_ind = 0
     SET req967731->reminders[1].recipients[apcnt].selection_nbr = apcnt
   ENDFOR
   FOR (idx = 1 TO size(result->cc_prsnl,5))
     SET apcnt = (apcnt+ 1)
     SET req967731->reminders[1].recipients[apcnt].personnel_id = result->cc_prsnl[idx].prsnl_id
     SET req967731->reminders[1].recipients[apcnt].cc_ind = 1
     SET req967731->reminders[1].recipients[apcnt].selection_nbr = apcnt
   ENDFOR
   SET stat = alterlist(req967731->reminders[1].action_requests,size(result->actions,5))
   FOR (idx = 1 TO size(result->actions,5))
     SET req967731->reminders[1].action_requests[idx].action_request_cd = result->actions[idx].
     action_cd
   ENDFOR
   SET req967731->reminders[1].original_task_uid = result->task_uid
   CALL echorecord(req967731)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967731,
    "REC",rep967731,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967731)
   IF ((rep967731->transaction_status.success_ind=1))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
