CREATE PROGRAM dcp_add_audit_info_req
 RECORD request(
   1 admin_events[*]
     2 source_application_flag = i2
     2 event_type_cd = f8
     2 event_id = f8
     2 order_id = f8
     2 template_order_id = f8
     2 documented_action_seq = i4
     2 positive_pt_identification = i2
     2 positive_med_identification = i2
     2 order_result_variance = i2
     2 clinical_warning_cnt = i4
     2 prsnl_id = f8
     2 position_cd = f8
     2 nurse_unit_cd = f8
     2 event_dt_tm = dq8
     2 verification_dt_tm = dq8
     2 verification_tz = i4
     2 verified_prsnl_id = f8
     2 needs_verify_flag = i2
     2 scheduled_dt_tm = dq8
     2 scheduled_tz = i4
     2 careaware_used_ind = i2
     2 med_admin_alerts[*]
       3 source_application_flag = i2
       3 alert_type_cd = f8
       3 alert_severity_cd = f8
       3 prsnl_id = f8
       3 position_cd = f8
       3 nurse_unit_cd = f8
       3 event_dt_tm = dq8
       3 careaware_used_ind = i2
       3 med_admin_pt_error[*]
         4 expected_pt_id = f8
         4 identifier = vc
         4 identified_pt_id = f8
         4 reason_cd = f8
         4 freetext_reason = vc
       3 med_admin_med_error[*]
         4 person_id = f8
         4 encounter_id = f8
         4 order_id = f8
         4 template_order_id = f8
         4 action_sequence = i4
         4 admin_route_cd = f8
         4 event_id = f8
         4 verification_dt_tm = dq8
         4 verification_tz = i4
         4 verified_prsnl_id = f8
         4 needs_verify_flag = i2
         4 med_event_ingreds[*]
           5 catalog_cd = f8
           5 synonym_id = f8
           5 strength = f8
           5 strength_unit_cd = f8
           5 volume = f8
           5 volume_unit_cd = f8
           5 drug_form_cd = f8
           5 identification_process_cd = f8
         4 scheduled_dt_tm = dq8
         4 scheduled_tz = i4
         4 admin_dt_tm = dq8
         4 admin_tz = i4
         4 reason_cd = f8
         4 freetext_reason = vc
         4 critical_ind = i2
       3 next_calc_dt_tm = dq8
       3 next_calc_tz = i4
     2 critical_ind = i2
   1 identification_errors[*]
     2 source_application_flag = i2
     2 alert_type_cd = f8
     2 identifier = vc
     2 event_dt_tm = dq8
     2 prsnl_id = f8
     2 nurse_unit_cd = f8
     2 careaware_used_ind = i2
     2 med_event_ingreds[*]
       3 catalog_cd = f8
       3 synonym_id = f8
       3 strength = f8
       3 strength_unit_cd = f8
       3 volume = f8
       3 volume_unit_cd = f8
       3 drug_form_cd = f8
       3 identification_process_cd = f8
     2 encntr_id = f8
   1 med_admin_alerts[*]
     2 source_application_flag = i2
     2 alert_type_cd = f8
     2 alert_severity_cd = f8
     2 prsnl_id = f8
     2 position_cd = f8
     2 nurse_unit_cd = f8
     2 event_dt_tm = dq8
     2 careaware_used_ind = i2
     2 med_admin_pt_error[*]
       3 expected_pt_id = f8
       3 identifier = vc
       3 identified_pt_id = f8
       3 reason_cd = f8
       3 freetext_reason = vc
     2 med_admin_med_error[*]
       3 person_id = f8
       3 encounter_id = f8
       3 order_id = f8
       3 template_order_id = f8
       3 action_sequence = i4
       3 admin_route_cd = f8
       3 event_id = f8
       3 verification_dt_tm = dq8
       3 verification_tz = i4
       3 verified_prsnl_id = f8
       3 needs_verify_flag = i2
       3 med_event_ingreds[*]
         4 catalog_cd = f8
         4 synonym_id = f8
         4 strength = f8
         4 strength_unit_cd = f8
         4 volume = f8
         4 volume_unit_cd = f8
         4 drug_form_cd = f8
         4 identification_process_cd = f8
       3 scheduled_dt_tm = dq8
       3 scheduled_tz = i4
       3 admin_dt_tm = dq8
       3 admin_tz = i4
       3 reason_cd = f8
       3 freetext_reason = vc
       3 critical_ind = i2
     2 next_calc_dt_tm = dq8
     2 next_calc_tz = i4
 ) WITH persistscript
END GO
