CREATE PROGRAM dcp_gen_mar_detail_reqs
 SET modify = predeclare
 IF ( NOT (validate(mar_detail_request)))
  CALL echo("in request")
  RECORD mar_detail_request(
    1 person_id = f8
    1 encntr_id = f8
    1 scope_flag = i2
    1 start_dt_tm = vc
    1 end_dt_tm = vc
    1 encntr_list[*]
      2 encntr_id = f8
    1 return_inactive_orders = i2
    1 return_order_review_data = i2
    1 return_order_ingredient_data = i2
    1 return_order_detail_data = i2
    1 return_future_task_data = i2
    1 task_start_dt_tm = dq8
    1 task_end_dt_tm = dq8
  ) WITH persist
 ENDIF
 FREE SET mar_detail_reply
 RECORD mar_detail_reply(
   1 orders[*]
     2 top_level_order_id = f8
     2 top_level_encntr_id = f8
     2 top_level_core_action_seq = i2
     2 top_level_order_type = f8
     2 top_level_freq_type = i2
     2 top_level_prn_ind = i2
     2 top_level_order_mnemonic = vc
     2 top_level_ordered_as_mnemonic = vc
     2 top_level_hna_order_mnemonic = vc
     2 top_level_verify_ind = i2
     2 top_level_need_rx_clin_review_flag = i2
     2 top_level_cosign_ind = i2
     2 top_level_need_nurse_review_ind = i2
     2 top_level_need_physician_validate_ind = i2
     2 top_level_catalog_cd = f8
     2 top_level_catalog_type_cd = f8
     2 top_level_activity_type_cd = f8
     2 top_level_order_status_cd = f8
     2 order_actions[*]
       3 action_type_cd = f8
       3 action_dt_tm = f8
       3 action_tz = i4
       3 needs_verify_ind = i2
       3 need_rx_clin_review_flag = i2
       3 order_app_nbr = i4
       3 effective_dt_tm = f8
       3 effective_tz = i4
       3 action_sequence = i2
       3 action_personnel_id = f8
       3 action_personnel_name = vc
       3 action_person = vc
       3 clinical_display_line = vc
       3 core_ind = i2
       3 prn_ind = i2
       3 order_id = f8
       3 frequency_id = f8
       3 schedule[*]
         4 time_of_day = i4
       3 order_ingredients[*]
         4 action_sequence = i2
         4 comp_sequence = i2
         4 order_mnemonic = vc
         4 ordered_as_mnemonic = vc
         4 hna_order_mnemonic = vc
         4 strength = f8
         4 strength_unit = f8
         4 volume = f8
         4 volume_unit = f8
         4 volume_flag = f8
         4 total_volume = f8
         4 bag_freq = f8
         4 dose_quantity = f8
         4 dose_quantity_unit_cd = f8
         4 freetext_dose = vc
         4 ingredient_type_flag = i2
         4 normalized_rate = f8
         4 normalized_rate_unit_cd = f8
         4 normalized_rate_unit_cd_disp = vc
         4 normalized_rate_unit_cd_desc = vc
         4 normalized_rate_unit_cd_mean = vc
         4 ingredient_rate_conversion_ind = i2
         4 already_sorted_ind = i2
       3 order_details[*]
         4 action_sequence = i2
         4 oe_field_id = f8
         4 oe_field_meaning = vc
         4 oe_field_value = i2
         4 oe_field_meaning_id = f8
         4 oe_field_display_value = vc
       3 notes[*]
         4 comment_text = vc
         4 comment_type_cd = f8
       3 order_review[*]
         4 review_dt_tm = f8
         4 review_tz = i4
         4 review_personnel_id = f8
         4 review_personnel_name = vc
         4 reviewed_status_flag = i2
         4 action_sequence = i4
         4 review_sequence = i2
         4 reviewed_person_name = vc
         4 review_type_flag = i2
       3 titratable_iv_ind = i2
       3 display_additives_first_ind = i2
     2 administrations[*]
       3 event_end_dt_tm = dq8
       3 event_end_tz = i4
       3 event_start_dt_tm = dq8
       3 event_start_tz = i4
       3 scheduled_admin_dt_tm = dq8
       3 scheduled_admin_tz = i4
       3 performed_dt_tm = dq8
       3 performed_tz = i4
       3 event_id = f8
       3 parent_event_id = f8
       3 event_class_cd = f8
       3 result_status_cd = f8
       3 event_tag = vc
       3 iv_event_cd = f8
       3 order_id = f8
       3 core_action_sequence = i4
       3 initial_dose = f8
       3 admin_dose = f8
       3 dose_unit_cd = f8
       3 initial_volume = f8
       3 admin_volume = f8
       3 volume_unit_cd = f8
       3 admin_route_cd = f8
       3 admin_site_cd = f8
       3 infusion_rate = f8
       3 infusion_rate_unit_cd = f8
       3 substance_lot_number = c20
       3 substance_manufacturer_cd = f8
       3 substance_exp_dt_tm = dq8
       3 performed_prsnl_id = f8
       3 performed_prsnl_name = vc
       3 valid_from_dt_tm = dq8
       3 order_idx = i2
       3 result_idx = i2
       3 valid_until_dt_tm = dq8
       3 result_comments[*]
         4 valid_from_dt_tm = dq8
         4 valid_until_dt_tm = dq8
         4 note_prsnl_id = f8
         4 note_prsnl_name = vc
         4 note_dt_tm = dq8
         4 note_tz = i4
         4 note_type_cd = f8
         4 comment_text = vc
       3 event_prsnl_actions[*]
         4 valid_until_dt_tm = dq8
         4 valid_from_dt_tm = dq8
         4 action_prsnl_id = f8
         4 action_prsnl_name = vc
         4 action_type_cd = f8
         4 action_status_cd = f8
         4 action_dt_tm = dq8
         4 action_tz = i4
         4 action_comment = vc
         4 request_prsnl_id = f8
         4 request_prsnl_name = vc
         4 request_dt_tm = dq8
         4 request_tz = i4
         4 proxy_prsnl_id = f8
         4 proxy_prsnl_name = vc
         4 request_comment = vc
       3 admin_histories[*]
         4 valid_from_dt_tm = dq8
         4 valid_until_dt_tm = dq8
         4 event_end_dt_tm = dq8
         4 event_end_tz = i4
         4 event_start_dt_tm = dq8
         4 event_start_tz = i4
         4 scheduled_admin_dt_tm = dq8
         4 scheduled_admin_tz = i4
         4 performed_dt_tm = dq8
         4 performed_tz = i4
         4 event_id = f8
         4 event_class_cd = f8
         4 result_status_cd = f8
         4 event_tag = vc
         4 iv_event_cd = f8
         4 order_id = f8
         4 core_action_sequence = i2
         4 initial_dose = f8
         4 admin_dose = f8
         4 dose_unit_cd = f8
         4 initial_volume = f8
         4 admin_volume = f8
         4 volume_unit_cd = f8
         4 admin_route_cd = f8
         4 admin_site_cd = f8
         4 infusion_rate = f8
         4 infusion_rate_unit_cd = f8
         4 substance_lot_number = c20
         4 substance_manufacturer_cd = f8
         4 substance_exp_dt_tm = dq8
         4 performed_prsnl_id = f8
         4 performed_prsnl_name = vc
         4 order_idx = i2
         4 result_idx = i2
         4 event_cd = f8
         4 device_free_txt = vc
       3 ingredients[*]
         4 event_id = f8
         4 result_status_cd = f8
         4 event_class_cd = f8
         4 event_tag = vc
         4 event_cd = f8
         4 catalog_cd = f8
         4 synonym_id = f8
         4 initial_dose = f8
         4 admin_dose = f8
         4 dose_unit_cd = f8
         4 initial_volume = f8
         4 admin_volume = f8
         4 volume_unit_cd = f8
         4 admin_route_cd = f8
         4 admin_site_cd = f8
         4 infusion_rate = f8
         4 infusion_rate_unit_cd = f8
         4 order_idx = i2
         4 result_idx = i2
         4 valid_from_dt_tm = dq8
         4 valid_until_dt_tm = dq8
         4 substance_lot_number = c20
         4 substance_manufacturer_cd = f8
         4 substance_exp_dt_tm = dq8
         4 result_comments[*]
           5 valid_from_dt_tm = dq8
           5 valid_to_dt_tm = dq8
           5 note_prsnl_id = f8
           5 note_prsnl_name = vc
           5 note_dt_tm = dq8
           5 note_tz = i4
           5 note_type_cd = f8
           5 comment_text = vc
         4 event_prsnl_actions[*]
           5 valid_until_dt_tm = dq8
           5 valid_from_dt_tm = dq8
           5 action_prsnl_id = f8
           5 action_prsnl_name = vc
           5 action_type_cd = f8
           5 action_status_cd = f8
           5 action_dt_tm = dq8
           5 action_tz = i4
           5 action_comment = vc
           5 request_prsnl_id = f8
           5 request_prsnl_name = vc
           5 request_dt_tm = dq8
           5 request_tz = i4
           5 proxy_prsnl_id = f8
           5 proxy_prsnl_name = vc
           5 request_comment = vc
         4 ingredient_histories[*]
           5 event_id = f8
           5 valid_from_dt_tm = dq8
           5 valid_to_dt_tm = dq8
           5 result_status_cd = f8
           5 event_class_cd = f8
           5 event_tag = vc
           5 event_cd = f8
           5 catalog_cd = f8
           5 synonym_id = f8
           5 iv_event_cd = f8
           5 core_action_sequence = i2
           5 initial_dose = f8
           5 admin_dose = f8
           5 dose_unit_cd = f8
           5 initial_volume = f8
           5 admin_volume = f8
           5 volume_unit_cd = f8
           5 admin_route_cd = f8
           5 admin_site_cd = f8
           5 infusion_rate = f8
           5 infusion_rate_unit_cd = f8
           5 order_idx = i2
           5 result_idx = i2
           5 substance_lot_number = c20
           5 substance_manufacturer_cd = f8
           5 substance_exp_dt_tm = dq8
           5 device_free_txt = vc
         4 device_free_txt = vc
       3 discretes[*]
         4 event_end_dt_tm = dq8
         4 event_end_tz = i4
         4 valid_from_dt_tm = dq8
         4 event_id = f8
         4 parent_event_id = f8
         4 event_cd = f8
         4 event_class_cd = f8
         4 event_tag = vc
         4 result_val = vc
         4 result_unit_cd = f8
         4 task_assay_cd = f8
         4 result_status_cd = f8
         4 normalcy_cd = f8
         4 normal_low = vc
         4 normal_high = vc
         4 critical_low = vc
         4 critical_high = vc
         4 order_id = f8
         4 order_idx = i2
         4 result_idx = i2
         4 result_histories[*]
           5 valid_from_dt_tm = dq8
           5 valid_until_dt_tm = dq8
           5 event_end_dt_tm = dq8
           5 performed_dt_tm = dq8
           5 performed_tz = i4
           5 event_end_tz = i4
           5 event_id = f8
           5 event_tag = vc
           5 event_cd = f8
           5 result_val = vc
           5 result_unit_cd = f8
           5 result_status_cd = f8
           5 normalcy_cd = f8
           5 normal_low = vc
           5 normal_high = vc
           5 critical_low = vc
           5 critical_high = vc
           5 order_idx = i2
           5 result_idx = i2
         4 result_comments[*]
           5 valid_from_dt_tm = dq8
           5 valid_until_dt_tm = dq8
           5 note_prsnl_id = f8
           5 note_prsnl_name = vc
           5 note_dt_tm = dq8
           5 note_tz = i4
           5 note_type_cd = f8
           5 comment_text = vc
         4 event_prsnl_actions[*]
           5 valid_until_dt_tm = dq8
           5 action_prsnl_id = f8
           5 action_prsnl_name = vc
           5 action_type_cd = f8
           5 action_status_cd = f8
           5 action_dt_tm = dq8
           5 action_tz = i4
           5 action_comment = vc
           5 request_prsnl_id = f8
           5 request_prsnl_name = vc
           5 request_dt_tm = dq8
           5 request_tz = i4
           5 proxy_prsnl_id = f8
           5 proxy_prsnl_name = vc
           5 request_comment = vc
         4 valid_until_dt_tm = dq8
       3 acknowledgements[*]
         4 event_id = f8
         4 event_cd = f8
         4 event_end_dt_tm = dq8
         4 event_end_tz = i4
         4 result_val = vc
         4 result_units_cd = f8
         4 result_status_cd = f8
         4 result_comments[*]
           5 note_type_cd = f8
           5 comment_text = vc
           5 valid_from_dt_tm = dq8
           5 valid_until_dt_tm = dq8
           5 note_dt_tm = dq8
           5 note_tz = i4
         4 valid_from_dt_tm = dq8
         4 valid_until_dt_tm = dq8
       3 event_cd = f8
       3 device_free_txt = vc
     2 responseresults[*]
       3 admin_parent_event_id = f8
       3 admin_core_action_seq = i2
       3 response_actions[*]
         4 events[*]
           5 event_end_dt_tm = dq8
           5 event_end_tz = i4
           5 performed_dt_tm = dq8
           5 performed_tz = i4
           5 event_id = f8
           5 parent_event_id = f8
           5 event_class_cd = f8
           5 event_cd = f8
           5 event_tag = vc
           5 result_val = vc
           5 result_unit_cd = f8
           5 task_assay_cd = f8
           5 result_status_cd = f8
           5 normalcy_cd = f8
           5 normal_low = vc
           5 normal_high = vc
           5 critical_low = vc
           5 critical_high = vc
           5 event_title_text = vc
           5 order_idx = i2
           5 result_idx = i2
           5 valid_from_dt_tm = dq8
           5 valid_until_dt_tm = dq8
           5 result_comments[*]
             6 valid_from_dt_tm = dq8
             6 valid_until_dt_tm = dq8
             6 note_prsnl_id = f8
             6 note_prsnl_name = vc
             6 note_dt_tm = dq8
             6 note_tz = i4
             6 note_type_cd = f8
             6 comment_text = vc
             6 event_id = f8
           5 event_prsnl_actions[*]
             6 valid_until_dt_tm = dq8
             6 valid_from_dt_tm = dq8
             6 action_prsnl_id = f8
             6 action_prsnl_name = vc
             6 action_type_cd = f8
             6 action_status_cd = f8
             6 action_dt_tm = dq8
             6 action_tz = i4
             6 action_comment = vc
             6 request_prsnl_id = f8
             6 request_prsnl_name = vc
             6 request_dt_tm = dq8
             6 request_tz = i4
             6 proxy_prsnl_id = f8
             6 proxy_prsnl_name = vc
             6 event_id = f8
             6 request_comment = vc
     2 tasks[*]
       3 task_id = f8
       3 order_id = f8
       3 task_status_cd = f8
       3 task_class_cd = f8
       3 task_activity_cd = f8
       3 careset_id = f8
       3 iv_ind = i2
       3 tpn_ind = i2
       3 task_dt_tm = dq8
       3 updt_cnt = i4
       3 event_id = f8
       3 reference_task_id = f8
       3 task_type_cd = f8
       3 description = vc
       3 chart_not_done_ind = i2
       3 quick_chart_ind = i2
       3 event_cd = f8
       3 reschedule_time = i4
       3 dcp_forms_ref_id = f8
       3 task_priority_cd = f8
       3 task_tz = i4
     2 ingred_event_cd_cnt = i4
     2 event_cd_cnt = i4
     2 related_event_cds[*]
       3 event_cd = f8
   1 errors[*]
     2 error_desc = vc
     2 order_id = f8
     2 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persist
 SET modify = nopredeclare
END GO
