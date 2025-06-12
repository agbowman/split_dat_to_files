CREATE PROGRAM bhs_athn_get_endorsements_v3
 FREE RECORD result
 RECORD result(
   1 grouped_results[*]
     2 person_id = f8
     2 person_name = vc
     2 normalcy_group_cd = f8
     2 normalcy_group_disp = vc
     2 task_activity_cd = f8
     2 task_activity_meaning = vc
     2 type = vc
     2 folder_name = vc
     2 creation_dt_tm = dq8
     2 updated_dt_tm = dq8
     2 status_cd = f8
     2 status_disp = vc
     2 subject = vc
     2 msg_from = vc
     2 comment = vc
     2 discrete_ind = i2
     2 tasks[*]
       3 task_id = f8
       3 task_status_cd = f8
       3 task_status_meaning = vc
       3 task_status_disp = vc
       3 task_dt_tm = dq8
       3 task_create_dt_tm = dq8
       3 reference_task_id = f8
       3 event_id = f8
       3 event_tag = vc
       3 event_class_cd = f8
       3 event_class_meaning = vc
       3 event_end_dt_tm = dq8
       3 performed_prsnl_id = f8
       3 performed_prsnl_name = vc
       3 result_status_cd = f8
       3 result_status_disp = vc
       3 event_set_cd = f8
       3 event_set_display = vc
       3 parent_event_id = f8
       3 normalcy_cd = f8
       3 normalcy_disp = vc
       3 comment = vc
       3 msg_sender_id = f8
       3 msg_sender_name = vc
       3 updt_dt_tm = dq8
       3 encntr_id = f8
       3 msg_subject = vc
   1 events_to_endorse[*]
     2 person_id = f8
     2 person_name = vc
     2 nonqual_ind = i2
     2 type = vc
     2 folder_name = vc
     2 creation_dt_tm = dq8
     2 updated_dt_tm = dq8
     2 status_cd = f8
     2 status_disp = vc
     2 subject = vc
     2 child_events[*]
       3 event_id = f8
       3 event_tag = vc
       3 updt_dt_tm = dq8
       3 clinsig_updt_dt_tm = dq8
       3 normalcy_cd = f8
       3 normalcy_disp = vc
       3 parent_event_id = f8
       3 event_set_cd = f8
       3 event_set_display = vc
       3 encntr_id = f8
       3 event_class_cd = f8
       3 event_class_meaning = vc
       3 event_end_dt_tm = dq8
       3 performed_prsnl_id = f8
       3 performed_prsnl_name = vc
       3 result_status_cd = f8
       3 result_status_disp = vc
       3 parent_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD normalcy
 RECORD normalcy(
   1 list[*]
     2 normalcy_cd = f8
     2 normalcy_disp = vc
     2 folder_name = vc
     2 folder_weight = i4
 ) WITH protect
 FREE RECORD tasks
 RECORD tasks(
   1 list[*]
     2 task_id = f8
     2 group_idx = i4
     2 task_idx = i4
 ) WITH protect
 FREE RECORD req967703
 RECORD req967703(
   1 receiver
     2 pool_id = f8
     2 provider_id = f8
   1 patient_id = f8
   1 status_codes[*]
     2 status_cd = f8
   1 date_range
     2 begin_dt_tm = dq8
     2 end_dt_tm = dq8
   1 configuration
     2 application_number = i4
   1 load
     2 suppress_assigned_ind = i2
     2 suppress_unauth_reviews_ind = i2
     2 all_result_tasks_ind = i2
     2 names_ind = i2
     2 group_results_ind = i2
 ) WITH protect
 FREE RECORD rep967703
 RECORD rep967703(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 transaction_uid = vc
   1 result_tasks[*]
     2 notification_uid = vc
     2 person_id = f8
     2 person_name = vc
     2 encounter_id = f8
     2 event_id = f8
     2 parent_event_id = f8
     2 result_status_cd = f8
     2 event_class_cd = f8
     2 task_status_cd = f8
     2 task_type_cd = f8
     2 task_activity_cd = f8
     2 task_activity_class_cd = f8
     2 normalcy_cd = f8
     2 msg_subject_cd = f8
     2 msg_subject = vc
     2 comments = vc
     2 event_tag = vc
     2 msg_sender_id = f8
     2 msg_sender_pool_id = f8
     2 msg_sender_pool_name = vc
     2 performed_prsnl_id = f8
     2 performed_prsnl_name = vc
     2 task_dt_tm = dq8
     2 event_end_dt_tm = dq8
     2 updated_dt_tm = dq8
     2 update_id = f8
     2 version = i4
     2 owner_version = i4
     2 assign_prsnl_id = f8
     2 assign_prsnl_name = vc
     2 assign_pool_id = f8
     2 assign_pool_name = vc
     2 event_set_cd = f8
     2 event_set_name = vc
     2 event_set_display = vc
     2 encntr_type_cd = f8
   1 grouped_results[*]
     2 patient_id = f8
     2 discrete_ind = i2
     2 task_activity_cd = f8
     2 pending_ind = i2
     2 normalcy_group_cd = f8
     2 cc_ind = i2
     2 result_tasks[*]
       3 notification_uid = vc
       3 person_id = f8
       3 person_name = vc
       3 encounter_id = f8
       3 event_id = f8
       3 parent_event_id = f8
       3 result_status_cd = f8
       3 event_class_cd = f8
       3 task_status_cd = f8
       3 task_type_cd = f8
       3 task_activity_cd = f8
       3 task_activity_class_cd = f8
       3 normalcy_cd = f8
       3 msg_subject_cd = f8
       3 msg_subject = vc
       3 comments = vc
       3 event_tag = vc
       3 msg_sender_id = f8
       3 msg_sender_name = vc
       3 msg_sender_pool_id = f8
       3 msg_sender_pool_name = vc
       3 performed_prsnl_id = f8
       3 performed_prsnl_name = vc
       3 task_dt_tm = dq8
       3 event_end_dt_tm = dq8
       3 updated_dt_tm = dq8
       3 update_id = f8
       3 version = i4
       3 owner_version = i4
       3 assign_prsnl_id = f8
       3 assign_prsnl_name = vc
       3 assign_pool_id = f8
       3 assign_pool_name = vc
       3 event_set_cd = f8
       3 event_set_name = vc
       3 event_set_display = vc
       3 encntr_type_cd = f8
 ) WITH protect
 FREE RECORD req1000078
 RECORD req1000078(
   1 decode_flag = i2
   1 search_anchor_dt_tm = dq8
   1 search_anchor_dt_tm_ind = i2
   1 seconds_duration = f8
   1 direction_flag = i2
   1 events_to_fetch = i4
   1 action_prsnl_list[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 pool_routed_ind = i2
   1 event_set_list[*]
     2 event_set_name = vc
   1 encntr_type_class_list[*]
     2 encntr_type_class_cd = f8
     2 encntr_type_class_meaning = vc
   1 event_class_list[*]
     2 event_class_cd = f8
     2 event_class_meaning = vc
   1 event_list[*]
     2 event_id = f8
   1 encntr_type_list[*]
     2 encntr_type_cd = f8
   1 inclusive_event_set_filter_ind = i2
   1 action_prsnl_group_list[*]
     2 action_prsnl_group_id = f8
     2 assign_prsnl_id = f8
   1 person_id = f8
   1 endorse_status_list[*]
     2 endorse_status_cd = f8
 ) WITH protect
 FREE RECORD rep1000078
 RECORD rep1000078(
   1 sb
     2 severitycd = i4
     2 statuscd = f8
     2 statustext = vc
     2 substatuslist[*]
       3 substatuscd = i4
   1 prsnl_list[*]
     2 prsnl_id = f8
     2 event_list[*]
       3 event_id = f8
       3 event_class_cd = f8
       3 event_tag = vc
       3 result_status_cd = f8
       3 person_id = f8
       3 clinsig_updt_dt_tm = dq8
       3 updt_dt_tm = dq8
       3 event_cd = f8
       3 normalcy_cd = f8
       3 event_title_text = vc
       3 encntr_type_class_cd = f8
       3 encntr_type_cd = f8
       3 encntr_type_mean = vc
       3 event_set_cd = f8
       3 event_set_name = vc
       3 parent_event_id = f8
       3 parent_event_class_cd = f8
       3 prsnl_id = f8
       3 prsnl_name = vc
       3 action_prsnl_group_id = f8
       3 action_prsnl_group_name = vc
       3 assign_prsnl_id = f8
       3 assign_prsnl_name = vc
       3 encntr_id = f8
       3 endorse_status_cd = f8
       3 last_comment_txt = vc
       3 multiple_comment_ind = i2
       3 multiple_comment_prsnl_ind = i2
       3 last_saved_prsnl_id = f8
       3 originating_provider_id = f8
       3 rte_prsnl_reltns_list[*]
         4 action_prsnl_id = f8
         4 reltn_type_cd = f8
     2 qual_person_list[*]
       3 person_id = f8
       3 name_full_formatted = vc
       3 pool_routed_ind = i2
     2 nonqual_person_list[*]
       3 person_id = f8
       3 name_full_formatted = vc
       3 pool_routed_ind = i2
     2 nonqual_event_list[*]
       3 event_id = f8
       3 person_id = f8
       3 normalcy_cd = f8
       3 encntr_type_class_cd = f8
       3 event_cd = f8
       3 result_status_cd = f8
       3 encntr_type_cd = f8
       3 encntr_type_disp = vc
       3 encntr_type_mean = vc
       3 event_set_cd = f8
       3 event_set_name = vc
       3 prsnl_id = f8
       3 prsnl_name = vc
       3 action_prsnl_group_id = f8
       3 action_prsnl_group_name = vc
       3 assign_prsnl_id = f8
       3 assign_prsnl_name = vc
       3 encntr_id = f8
       3 clinsig_updt_dt_tm = dq8
       3 updt_dt_tm = dq8
       3 endorse_status_cd = f8
       3 last_comment_txt = vc
       3 multiple_comment_ind = i2
       3 multiple_comment_prsnl_ind = i2
       3 last_saved_prsnl_id = f8
       3 originating_provider_id = f8
       3 rte_prsnl_reltns_list[*]
         4 action_prsnl_id = f8
         4 reltn_type_cd = f8
     2 action_prsnl_group_id = f8
   1 code_value_list[*]
     2 code_value_cd = f8
     2 code_value_cd_disp = vc
     2 code_value_cd_mean = vc
 ) WITH protect
 FREE RECORD req967678
 RECORD req967678(
   1 msg_category_knt = i4
   1 msg_category_list[*]
     2 msg_category_id = f8
   1 query_all_public_ind = i2
   1 msg_category_type_cd = f8
   1 load_column_dtl = i2
   1 load_event_set_dtl = i2
   1 load_encntr_dtl = i2
   1 load_item_grp_dtl = i2
   1 load_item_type_dtl = i2
 ) WITH protect
 FREE RECORD rep967678
 RECORD rep967678(
   1 msg_category_knt = i4
   1 msg_category_list[*]
     2 msg_category_id = f8
     2 msg_category_public_ind = i2
     2 msg_category_name = vc
     2 msg_category_desc = vc
     2 msg_category_prsnl_id = f8
     2 msg_category_position_cd = f8
     2 msg_category_prsnl_grp_id = f8
     2 msg_category_app_num = i4
     2 msg_notify_category_cd = f8
     2 msg_notify_item_cd = f8
     2 msg_category_type_cd = f8
     2 msg_column_grp_id = f8
     2 msg_column_grp_public_ind = i2
     2 msg_column_grp_name = vc
     2 msg_column_grp_desc = vc
     2 msg_column_grp_prsnl_id = f8
     2 msg_column_grp_position_cd = f8
     2 msg_column_grp_prsnl_grp_id = f8
     2 msg_column_grp_app_num = i4
     2 msg_column_grp_dtl_knt = i4
     2 msg_column_grp_dtl_list[*]
       3 msg_column_type_cd = f8
     2 msg_column_grp_def_column_type = f8
     2 msg_column_grp_descend_ind = i2
     2 msg_item_grp_knt = i4
     2 msg_item_grp_list[*]
       3 msg_item_grp_id = f8
       3 msg_item_grp_public_ind = i2
       3 msg_item_grp_name = vc
       3 msg_item_grp_desc = vc
       3 msg_item_grp_prsnl_id = f8
       3 msg_item_grp_position_cd = f8
       3 msg_item_grp_prsnl_grp_id = f8
       3 msg_item_grp_app_num = i4
       3 msg_notify_category_cd = f8
       3 msg_notify_item_cd = f8
       3 msg_item_grp_type_cd = f8
       3 msg_item_grp_dtl_knt = i4
       3 msg_item_grp_dtl_list[*]
         4 msg_item_type_cd = f8
     2 msg_event_set_grp_id = f8
     2 msg_event_filter_inc_ind = i2
     2 msg_event_set_grp_public_ind = i2
     2 msg_event_set_grp_name = vc
     2 msg_event_set_grp_desc = vc
     2 msg_event_set_grp_prsnl_id = f8
     2 msg_event_set_grp_position_cd = f8
     2 msg_event_set_grp_prsnl_grp_id = f8
     2 msg_event_set_grp_app_num = i4
     2 msg_event_set_grp_dtl_knt = i4
     2 msg_event_set_grp_dtl_list[*]
       3 event_set_name = vc
     2 msg_encntr_grp_id = f8
     2 msg_encntr_grp_public_ind = i2
     2 msg_encntr_grp_name = vc
     2 msg_encntr_grp_desc = vc
     2 msg_encntr_grp_prsnl_id = f8
     2 msg_encntr_grp_position_cd = f8
     2 msg_encntr_grp_prsnl_grp_id = f8
     2 msg_encntr_grp_app_num = i4
     2 msg_encntr_grp_dtl_knt = i4
     2 msg_encntr_grp_dtl_list[*]
       3 encntr_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetresulttasks(null) = i4
 DECLARE callendorsequery(null) = i4
 DECLARE callcategoryquery(null) = i4
 DECLARE getchildeventdetails(null) = i4
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE kdx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE tpos = i4 WITH protect, noconstant(0)
 DECLARE grcnt = i4 WITH protect, noconstant(0)
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 DECLARE treccnt = i4 WITH protect, noconstant(0)
 DECLARE group_idx = i4 WITH protect, noconstant(0)
 DECLARE task_idx = i4 WITH protect, noconstant(0)
 DECLARE creation_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE updated_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE status_disp = vc WITH protect, noconstant("")
 DECLARE msg_sender_id = f8 WITH protect, noconstant(0.0)
 DECLARE msg_from = vc WITH protect, noconstant("")
 DECLARE discrete_ind = i2 WITH protect, noconstant(0)
 DECLARE latest_task_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE folder_name = vc WITH protect, noconstant("")
 DECLARE folder_weight = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE c_result_fyi = vc WITH protect, constant("Result FYI")
 DECLARE c_cc_result_review = vc WITH protect, constant("Copy To Results")
 DECLARE c_result_to_endorse = vc WITH protect, constant("Results to Endorse")
 DECLARE c_fwd_type_to_sign = vc WITH protect, constant("Forwarded Results to Sign")
 DECLARE c_fwd_type_to_review = vc WITH protect, constant("Forwarded Results to Review")
 DECLARE c_task_review_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6027,"REVIEW RESUL"))
 DECLARE c_task_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6027,"SIGN RESULT"))
 DECLARE c_onhold_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002700,"ONHOLD"))
 DECLARE c_opened_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002700,"OPENED"))
 DECLARE c_pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002700,"PENDING"))
 DECLARE c_hlatyping_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"HLATYPING"))
 DECLARE c_rad_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"RAD"))
 DECLARE c_ap_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"AP"))
 DECLARE c_mbo_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MBO"))
 DECLARE c_procedure_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PROCEDURE"))
 DECLARE c_helix_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"HELIX"))
 DECLARE c_resultdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"RESULTDOC"))
 SET result->status_data.status = "F"
 IF (( $2 <= 0)
  AND ( $5 <= 0))
  CALL echo("EITHER PERSONNEL ID OR POOL ID PARAMETER MUST BE SET...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE c_grp_abnormal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3410,"ABNORMAL"))
 DECLARE c_grp_critical_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3410,"CRITICAL"))
 DECLARE c_grp_normal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3410,"NORMAL"))
 DECLARE c_abnormal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"ABNORMAL"))
 DECLARE c_critical_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"CRITICAL"))
 DECLARE c_normal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"NORMAL"))
 DECLARE c_vabnormal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"VABNORMAL"))
 DECLARE c_high_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"HIGH"))
 DECLARE c_low_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"LOW"))
 DECLARE c_positive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"POSITIVE"))
 DECLARE c_extremehigh_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"EXTREMEHIGH"))
 DECLARE c_extremelow_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"EXTREMELOW"))
 DECLARE c_panichigh_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"PANICHIGH"))
 DECLARE c_paniclow_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"PANICLOW"))
 DECLARE c_negative_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"NEGATIVE"))
 DECLARE c_folder_abnormal = vc WITH protect, constant("Abnormal")
 DECLARE c_folder_critical = vc WITH protect, constant("Critical")
 DECLARE c_folder_normal = vc WITH protect, constant("Normal")
 DECLARE c_folder_other = vc WITH protect, constant("Other")
 SET stat = alterlist(normalcy->list,12)
 SET normalcy->list[1].normalcy_cd = c_abnormal_cd
 SET normalcy->list[1].normalcy_disp = uar_get_code_description(c_abnormal_cd)
 SET normalcy->list[1].folder_name = c_folder_abnormal
 SET normalcy->list[1].folder_weight = 100
 SET normalcy->list[2].normalcy_cd = c_high_cd
 SET normalcy->list[2].normalcy_disp = uar_get_code_description(c_high_cd)
 SET normalcy->list[2].folder_name = c_folder_abnormal
 SET normalcy->list[2].folder_weight = 100
 SET normalcy->list[3].normalcy_cd = c_low_cd
 SET normalcy->list[3].normalcy_disp = uar_get_code_description(c_low_cd)
 SET normalcy->list[3].folder_name = c_folder_abnormal
 SET normalcy->list[3].folder_weight = 100
 SET normalcy->list[4].normalcy_cd = c_positive_cd
 SET normalcy->list[4].normalcy_disp = uar_get_code_description(c_positive_cd)
 SET normalcy->list[4].folder_name = c_folder_abnormal
 SET normalcy->list[4].folder_weight = 100
 SET normalcy->list[5].normalcy_cd = c_critical_cd
 SET normalcy->list[5].normalcy_disp = uar_get_code_description(c_critical_cd)
 SET normalcy->list[5].folder_name = c_folder_critical
 SET normalcy->list[5].folder_weight = 1000
 SET normalcy->list[6].normalcy_cd = c_extremehigh_cd
 SET normalcy->list[6].normalcy_disp = uar_get_code_description(c_extremehigh_cd)
 SET normalcy->list[6].folder_name = c_folder_critical
 SET normalcy->list[6].folder_weight = 1000
 SET normalcy->list[7].normalcy_cd = c_extremelow_cd
 SET normalcy->list[7].normalcy_disp = uar_get_code_description(c_extremelow_cd)
 SET normalcy->list[7].folder_name = c_folder_critical
 SET normalcy->list[7].folder_weight = 1000
 SET normalcy->list[8].normalcy_cd = c_panichigh_cd
 SET normalcy->list[8].normalcy_disp = uar_get_code_description(c_panichigh_cd)
 SET normalcy->list[8].folder_name = c_folder_critical
 SET normalcy->list[8].folder_weight = 1000
 SET normalcy->list[9].normalcy_cd = c_paniclow_cd
 SET normalcy->list[9].normalcy_disp = uar_get_code_description(c_paniclow_cd)
 SET normalcy->list[9].folder_name = c_folder_critical
 SET normalcy->list[9].folder_weight = 1000
 SET normalcy->list[10].normalcy_cd = c_vabnormal_cd
 SET normalcy->list[10].normalcy_disp = uar_get_code_description(c_vabnormal_cd)
 SET normalcy->list[10].folder_name = c_folder_critical
 SET normalcy->list[10].folder_weight = 1000
 SET normalcy->list[11].normalcy_cd = c_negative_cd
 SET normalcy->list[11].normalcy_disp = uar_get_code_description(c_negative_cd)
 SET normalcy->list[11].folder_name = c_folder_normal
 SET normalcy->list[11].folder_weight = 1
 SET normalcy->list[12].normalcy_cd = c_normal_cd
 SET normalcy->list[12].normalcy_disp = uar_get_code_description(c_normal_cd)
 SET normalcy->list[12].folder_name = c_folder_normal
 SET normalcy->list[12].folder_weight = 1
 SET stat = callgetresulttasks(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = callcategoryquery(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = callendorsequery(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = getchildeventdetails(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v0 = vc WITH protect, noconstant("")
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  DECLARE v10 = vc WITH protect, noconstant("")
  DECLARE v11 = vc WITH protect, noconstant("")
  DECLARE v12 = vc WITH protect, noconstant("")
  DECLARE v13 = vc WITH protect, noconstant("")
  DECLARE v14 = vc WITH protect, noconstant("")
  DECLARE v15 = vc WITH protect, noconstant("")
  DECLARE v16 = vc WITH protect, noconstant("")
  DECLARE v17 = vc WITH protect, noconstant("")
  DECLARE v18 = vc WITH protect, noconstant("")
  DECLARE v19 = vc WITH protect, noconstant("")
  DECLARE v20 = vc WITH protect, noconstant("")
  DECLARE v21 = vc WITH protect, noconstant("")
  DECLARE v22 = vc WITH protect, noconstant("")
  DECLARE v23 = vc WITH protect, noconstant("")
  DECLARE v24 = vc WITH protect, noconstant("")
  DECLARE v25 = vc WITH protect, noconstant("")
  DECLARE v26 = vc WITH protect, noconstant("")
  DECLARE v27 = vc WITH protect, noconstant("")
  DECLARE v28 = vc WITH protect, noconstant("")
  DECLARE v29 = vc WITH protect, noconstant("")
  DECLARE v30 = vc WITH protect, noconstant("")
  DECLARE v31 = vc WITH protect, noconstant("")
  DECLARE v32 = vc WITH protect, noconstant("")
  DECLARE v33 = vc WITH protect, noconstant("")
  DECLARE v34 = vc WITH protect, noconstant("")
  DECLARE v35 = vc WITH protect, noconstant("")
  DECLARE v36 = vc WITH protect, noconstant("")
  DECLARE v37 = vc WITH protect, noconstant("")
  DECLARE v38 = vc WITH protect, noconstant("")
  DECLARE v39 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v0 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v0, row + 1, col + 1,
    "<Endorsements>", row + 1
    FOR (idx = 1 TO size(result->grouped_results,5))
      col + 1, "<Endorsement>", row + 1,
      v1 = build("<PersonId>",cnvtint(result->grouped_results[idx].person_id),"</PersonId>"), col + 1,
      v1,
      row + 1, v2 = build("<PersonName>",trim(replace(replace(replace(replace(replace(result->
             grouped_results[idx].person_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
          0),'"',"&quot;",0),3),"</PersonName>"), col + 1,
      v2, row + 1, v4 = build("<TaskActivityCd>",cnvtint(result->grouped_results[idx].
        task_activity_cd),"</TaskActivityCd>"),
      col + 1, v4, row + 1,
      v5 = build("<TaskActivityMeaning>",trim(replace(replace(replace(replace(replace(result->
             grouped_results[idx].task_activity_meaning,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
          "'","&apos;",0),'"',"&quot;",0),3),"</TaskActivityMeaning>"), col + 1, v5,
      row + 1, v6 = build("<Type>",trim(replace(replace(replace(replace(replace(result->
             grouped_results[idx].type,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
         "&quot;",0),3),"</Type>"), col + 1,
      v6, row + 1, v7 = build("<FolderName>",trim(replace(replace(replace(replace(replace(result->
             grouped_results[idx].folder_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
          0),'"',"&quot;",0),3),"</FolderName>"),
      col + 1, v7, row + 1,
      v8 = build("<CreationDate>",format(result->grouped_results[idx].creation_dt_tm,
        "MM/DD/YYYY HH:MM:SS;;D"),"</CreationDate>"), col + 1, v8,
      row + 1, v9 = build("<UpdatedDate>",format(result->grouped_results[idx].updated_dt_tm,
        "MM/DD/YYYY HH:MM:SS;;D"),"</UpdatedDate>"), col + 1,
      v9, row + 1, v10 = build("<TaskStatusCd>",cnvtint(result->grouped_results[idx].status_cd),
       "</TaskStatusCd>"),
      col + 1, v10, row + 1,
      v11 = build("<TaskStatusDisp>",trim(replace(replace(replace(replace(replace(result->
             grouped_results[idx].status_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
          0),'"',"&quot;",0),3),"</TaskStatusDisp>"), col + 1, v11,
      row + 1, v12 = build("<Subject>",trim(replace(replace(replace(replace(replace(result->
             grouped_results[idx].subject,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
         '"',"&quot;",0),3),"</Subject>"), col + 1,
      v12, row + 1, v13 = build("<MsgFrom>",trim(replace(replace(replace(replace(replace(result->
             grouped_results[idx].msg_from,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
         '"',"&quot;",0),3),"</MsgFrom>"),
      col + 1, v13, row + 1,
      v14 = build("<Comment>",trim(replace(replace(replace(replace(replace(result->grouped_results[
             idx].comment,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
        3),"</Comment>"), col + 1, v14,
      row + 1, col + 1, "<Tasks>",
      row + 1
      FOR (jdx = 1 TO size(result->grouped_results[idx].tasks,5))
        col + 1, "<Task>", row + 1,
        v15 = build("<TaskId>",cnvtint(result->grouped_results[idx].tasks[jdx].task_id),"</TaskId>"),
        col + 1, v15,
        row + 1, v16 = build("<TaskStatusCd>",cnvtint(result->grouped_results[idx].tasks[jdx].
          task_status_cd),"</TaskStatusCd>"), col + 1,
        v16, row + 1, v17 = build("<TaskStatusMeaning>",trim(replace(replace(replace(replace(replace(
               result->grouped_results[idx].tasks[jdx].task_status_meaning,"&","&amp;",0),"<","&lt;",
              0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</TaskStatusMeaning>"),
        col + 1, v17, row + 1,
        v18 = build("<TaskStatusDisp>",trim(replace(replace(replace(replace(replace(result->
               grouped_results[idx].tasks[jdx].task_status_disp,"&","&amp;",0),"<","&lt;",0),">",
             "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</TaskStatusDisp>"), col + 1, v18,
        row + 1, v19 = build("<TaskDate>",format(result->grouped_results[idx].tasks[jdx].task_dt_tm,
          "MM/DD/YYYY HH:MM:SS;;D"),"</TaskDate>"), col + 1,
        v19, row + 1, v20 = build("<TaskCreateDate>",format(result->grouped_results[idx].tasks[jdx].
          task_create_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),"</TaskCreateDate>"),
        col + 1, v20, row + 1,
        v21 = build("<ReferenceTaskId>",cnvtint(result->grouped_results[idx].tasks[jdx].
          reference_task_id),"</ReferenceTaskId>"), col + 1, v21,
        row + 1, v22 = build("<EventId>",cnvtint(result->grouped_results[idx].tasks[jdx].event_id),
         "</EventId>"), col + 1,
        v22, row + 1, v23 = build("<EventTag>",trim(replace(replace(replace(replace(replace(result->
               grouped_results[idx].tasks[jdx].event_tag,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
            "'","&apos;",0),'"',"&quot;",0),3),"</EventTag>"),
        col + 1, v23, row + 1,
        v24 = build("<EventClassCd>",cnvtint(result->grouped_results[idx].tasks[jdx].event_class_cd),
         "</EventClassCd>"), col + 1, v24,
        row + 1, v25 = build("<EventClassMeaning>",trim(replace(replace(replace(replace(replace(
               result->grouped_results[idx].tasks[jdx].event_class_meaning,"&","&amp;",0),"<","&lt;",
              0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</EventClassMeaning>"), col + 1,
        v25, row + 1, v26 = build("<EventEndDate>",format(result->grouped_results[idx].tasks[jdx].
          event_end_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),"</EventEndDate>"),
        col + 1, v26, row + 1,
        v27 = build("<PerformedPrsnlId>",cnvtint(result->grouped_results[idx].tasks[jdx].
          performed_prsnl_id),"</PerformedPrsnlId>"), col + 1, v27,
        row + 1, v28 = build("<PerformedPrsnlName>",trim(replace(replace(replace(replace(replace(
               result->grouped_results[idx].tasks[jdx].performed_prsnl_name,"&","&amp;",0),"<","&lt;",
              0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</PerformedPrsnlName>"), col + 1,
        v28, row + 1, v29 = build("<ResultStatusCd>",cnvtint(result->grouped_results[idx].tasks[jdx].
          result_status_cd),"</ResultStatusCd>"),
        col + 1, v29, row + 1,
        v30 = build("<ResultStatusDisp>",trim(replace(replace(replace(replace(replace(result->
               grouped_results[idx].tasks[jdx].result_status_disp,"&","&amp;",0),"<","&lt;",0),">",
             "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</ResultStatusDisp>"), col + 1, v30,
        row + 1, v31 = build("<EventSetCd>",cnvtint(result->grouped_results[idx].tasks[jdx].
          event_set_cd),"</EventSetCd>"), col + 1,
        v31, row + 1, v32 = build("<EventSetDisp>",trim(replace(replace(replace(replace(replace(
               result->grouped_results[idx].tasks[jdx].event_set_display,"&","&amp;",0),"<","&lt;",0),
             ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</EventSetDisp>"),
        col + 1, v32, row + 1,
        v33 = build("<ParentEventId>",cnvtint(result->grouped_results[idx].tasks[jdx].parent_event_id
          ),"</ParentEventId>"), col + 1, v33,
        row + 1, v34 = build("<NormalcyCd>",cnvtint(result->grouped_results[idx].tasks[jdx].
          normalcy_cd),"</NormalcyCd>"), col + 1,
        v34, row + 1, v35 = build("<NormalcyDisp>",trim(replace(replace(replace(replace(replace(
               result->grouped_results[idx].tasks[jdx].normalcy_disp,"&","&amp;",0),"<","&lt;",0),">",
             "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</NormalcyDisp>"),
        col + 1, v35, row + 1,
        v36 = build("<Comment>",trim(replace(replace(replace(replace(replace(result->grouped_results[
               idx].tasks[jdx].comment,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
           "&quot;",0),3),"</Comment>"), col + 1, v36,
        row + 1, v37 = build("<MsgSenderId>",cnvtint(result->grouped_results[idx].tasks[jdx].
          msg_sender_id),"</MsgSenderId>"), col + 1,
        v37, row + 1, v38 = build("<MsgSenderName>",trim(replace(replace(replace(replace(replace(
               result->grouped_results[idx].tasks[jdx].msg_sender_name,"&","&amp;",0),"<","&lt;",0),
             ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</MsgSenderName>"),
        col + 1, v38, row + 1,
        v39 = build("<UpdatedDate>",format(result->grouped_results[idx].tasks[jdx].updt_dt_tm,
          "MM/DD/YYYY HH:MM:SS;;D"),"</UpdatedDate>"), col + 1, v39,
        row + 1, v3 = build("<EncounterID>",cnvtint(result->grouped_results[idx].tasks[jdx].encntr_id
          ),"</EncounterID>"), col + 1,
        v3, row + 1, col + 1,
        "</Task>", row + 1
      ENDFOR
      col + 1, "</Tasks>", row + 1,
      col + 1, "</Endorsement>", row + 1
    ENDFOR
    FOR (idx = 1 TO size(result->events_to_endorse,5))
      col + 1, "<Endorsement>", row + 1,
      v1 = build("<PersonId>",cnvtint(result->events_to_endorse[idx].person_id),"</PersonId>"), col
       + 1, v1,
      row + 1, v2 = build("<PersonName>",trim(replace(replace(replace(replace(replace(result->
             events_to_endorse[idx].person_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
          "&apos;",0),'"',"&quot;",0),3),"</PersonName>"), col + 1,
      v2, row + 1, v4 = build("<TaskActivityCd></TaskActivityCd>"),
      col + 1, v4, row + 1,
      v5 = build("<TaskActivityMeaning></TaskActivityMeaning>"), col + 1, v5,
      row + 1, v6 = build("<Type>",trim(replace(replace(replace(replace(replace(result->
             events_to_endorse[idx].type,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
         '"',"&quot;",0),3),"</Type>"), col + 1,
      v6, row + 1, v7 = build("<FolderName>",trim(replace(replace(replace(replace(replace(result->
             events_to_endorse[idx].folder_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
          "&apos;",0),'"',"&quot;",0),3),"</FolderName>"),
      col + 1, v7, row + 1,
      v8 = build("<CreationDate>",format(result->events_to_endorse[idx].creation_dt_tm,
        "MM/DD/YYYY HH:MM:SS;;D"),"</CreationDate>"), col + 1, v8,
      row + 1, v9 = build("<UpdatedDate>",format(result->events_to_endorse[idx].updated_dt_tm,
        "MM/DD/YYYY HH:MM:SS;;D"),"</UpdatedDate>"), col + 1,
      v9, row + 1, v10 = build("<TaskStatusCd>",cnvtint(result->events_to_endorse[idx].status_cd),
       "</TaskStatusCd>"),
      col + 1, v10, row + 1,
      v11 = build("<TaskStatusDisp>",trim(replace(replace(replace(replace(replace(result->
             events_to_endorse[idx].status_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
          "&apos;",0),'"',"&quot;",0),3),"</TaskStatusDisp>"), col + 1, v11,
      row + 1, v12 = build("<Subject>",trim(replace(replace(replace(replace(replace(result->
             events_to_endorse[idx].subject,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0
          ),'"',"&quot;",0),3),"</Subject>"), col + 1,
      v12, row + 1, v13 = build("<MsgFrom></MsgFrom>"),
      col + 1, v13, row + 1,
      v14 = build("<Comment></Comment>"), col + 1, v14,
      row + 1, col + 1, "<Tasks>",
      row + 1
      FOR (jdx = 1 TO size(result->events_to_endorse[idx].child_events,5))
        col + 1, "<Task>", row + 1,
        v15 = build("<TaskId>0</TaskId>"), col + 1, v15,
        row + 1, v16 = build("<TaskStatusCd></TaskStatusCd>"), col + 1,
        v16, row + 1, v17 = build("<TaskStatusMeaning></TaskStatusMeaning>"),
        col + 1, v17, row + 1,
        v18 = build("<TaskStatusDisp></TaskStatusDisp>"), col + 1, v18,
        row + 1, v19 = build("<TaskDate></TaskDate>"), col + 1,
        v19, row + 1, v20 = build("<TaskCreateDate></TaskCreateDate>"),
        col + 1, v20, row + 1,
        v21 = build("<ReferenceTaskId></ReferenceTaskId>"), col + 1, v21,
        row + 1, v22 = build("<EventId>",cnvtint(result->events_to_endorse[idx].child_events[jdx].
          event_id),"</EventId>"), col + 1,
        v22, row + 1, v23 = build("<EventTag>",trim(replace(replace(replace(replace(replace(result->
               events_to_endorse[idx].child_events[jdx].event_tag,"&","&amp;",0),"<","&lt;",0),">",
             "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</EventTag>"),
        col + 1, v23, row + 1,
        v24 = build("<EventClassCd>",cnvtint(result->events_to_endorse[idx].child_events[jdx].
          event_class_cd),"</EventClassCd>"), col + 1, v24,
        row + 1, v25 = build("<EventClassMeaning>",trim(replace(replace(replace(replace(replace(
               result->events_to_endorse[idx].child_events[jdx].event_class_meaning,"&","&amp;",0),
              "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</EventClassMeaning>"),
        col + 1,
        v25, row + 1, v26 = build("<EventEndDate>",format(result->events_to_endorse[idx].
          child_events[jdx].event_end_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),"</EventEndDate>"),
        col + 1, v26, row + 1,
        v27 = build("<PerformedPrsnlId>",cnvtint(result->events_to_endorse[idx].child_events[jdx].
          performed_prsnl_id),"</PerformedPrsnlId>"), col + 1, v27,
        row + 1, v28 = build("<PerformedPrsnlName>",trim(replace(replace(replace(replace(replace(
               result->events_to_endorse[idx].child_events[jdx].performed_prsnl_name,"&","&amp;",0),
              "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</PerformedPrsnlName>"),
        col + 1,
        v28, row + 1, v29 = build("<ResultStatusCd>",cnvtint(result->events_to_endorse[idx].
          child_events[jdx].result_status_cd),"</ResultStatusCd>"),
        col + 1, v29, row + 1,
        v30 = build("<ResultStatusDisp>",trim(replace(replace(replace(replace(replace(result->
               events_to_endorse[idx].child_events[jdx].result_status_disp,"&","&amp;",0),"<","&lt;",
              0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</ResultStatusDisp>"), col + 1,
        v30,
        row + 1, v31 = build("<EventSetCd>",cnvtint(result->events_to_endorse[idx].child_events[jdx].
          event_set_cd),"</EventSetCd>"), col + 1,
        v31, row + 1, v32 = build("<EventSetDisp>",trim(replace(replace(replace(replace(replace(
               result->events_to_endorse[idx].child_events[jdx].event_set_display,"&","&amp;",0),"<",
              "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</EventSetDisp>"),
        col + 1, v32, row + 1,
        v33 = build("<ParentEventId>",cnvtint(result->events_to_endorse[idx].child_events[jdx].
          parent_event_id),"</ParentEventId>"), col + 1, v33,
        row + 1, v34 = build("<NormalcyCd>",cnvtint(result->events_to_endorse[idx].child_events[jdx].
          normalcy_cd),"</NormalcyCd>"), col + 1,
        v34, row + 1, v35 = build("<NormalcyDisp>",trim(replace(replace(replace(replace(replace(
               result->events_to_endorse[idx].child_events[jdx].normalcy_disp,"&","&amp;",0),"<",
              "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</NormalcyDisp>"),
        col + 1, v35, row + 1,
        v36 = build("<Comment></Comment>"), col + 1, v36,
        row + 1, v37 = build("<MsgSenderId></MsgSenderId>"), col + 1,
        v37, row + 1, v38 = build("<MsgSenderName></MsgSenderName>"),
        col + 1, v38, row + 1,
        v39 = build("<UpdatedDate>",format(result->events_to_endorse[idx].child_events[jdx].
          updt_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),"</UpdatedDate>"), col + 1, v39,
        row + 1, v3 = build("<EncounterID>",cnvtint(result->events_to_endorse[idx].child_events[jdx].
          encntr_id),"</EncounterID>"), col + 1,
        v3, row + 1, col + 1,
        "</Task>", row + 1
      ENDFOR
      col + 1, "</Tasks>", row + 1,
      col + 1, "</Endorsement>", row + 1
    ENDFOR
    col + 1, "</Endorsements>", row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req967703
 FREE RECORD rep967703
 FREE RECORD req1000078
 FREE RECORD rep1000078
 FREE RECORD req967678
 FREE RECORD rep967678
 FREE RECORD tasks
 SUBROUTINE callgetresulttasks(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(967100)
   DECLARE requestid = i4 WITH protect, constant(967703)
   DECLARE onhold_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"ONHOLD"))
   DECLARE opened_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OPENED"))
   DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE taskidspos = i4 WITH protect, noconstant(0)
   DECLARE eventidspos = i4 WITH protect, noconstant(0)
   DECLARE startpos = i4 WITH protect, noconstant(0)
   DECLARE separatorpos = i4 WITH protect, noconstant(0)
   DECLARE taskidsstr = vc WITH protect, noconstant("")
   DECLARE currenttaskid = vc WITH protect, noconstant("")
   DECLARE taskcnt = i4 WITH protect, noconstant(0)
   IF (( $5 > 0.0))
    SET req967703->receiver.pool_id =  $5
   ELSE
    SET req967703->receiver.provider_id =  $2
   ENDIF
   SET stat = alterlist(req967703->status_codes,3)
   SET req967703->status_codes[1].status_cd = onhold_cd
   SET req967703->status_codes[2].status_cd = opened_cd
   SET req967703->status_codes[3].status_cd = pending_cd
   SET req967703->date_range.begin_dt_tm = cnvtdatetime( $3)
   SET req967703->date_range.end_dt_tm = cnvtdatetime( $4)
   SET req967703->configuration.application_number = applicationid
   SET req967703->load.names_ind = 1
   SET req967703->load.group_results_ind = 1
   CALL echorecord(req967703)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967703,
    "REC",rep967703,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967703)
   IF ((rep967703->transaction_status.success_ind=1))
    FOR (idx = 1 TO size(rep967703->grouped_results,5))
      SET grcnt += 1
      SET stat = alterlist(result->grouped_results,grcnt)
      SET result->grouped_results[grcnt].person_id = rep967703->grouped_results[idx].patient_id
      SET result->grouped_results[grcnt].normalcy_group_cd = rep967703->grouped_results[idx].
      normalcy_group_cd
      SET result->grouped_results[grcnt].normalcy_group_disp = uar_get_code_display(result->
       grouped_results[grcnt].normalcy_group_cd)
      SET result->grouped_results[grcnt].folder_name = evaluate(result->grouped_results[grcnt].
       normalcy_group_cd,c_grp_critical_cd,c_folder_critical,c_grp_abnormal_cd,c_folder_abnormal,
       c_grp_normal_cd,c_folder_normal,c_folder_other)
      SET result->grouped_results[grcnt].task_activity_cd = rep967703->grouped_results[idx].
      task_activity_cd
      SET result->grouped_results[grcnt].task_activity_meaning = uar_get_code_meaning(result->
       grouped_results[grcnt].task_activity_cd)
      SET result->grouped_results[grcnt].person_name = rep967703->grouped_results[idx].result_tasks[1
      ].person_name
      IF ((result->grouped_results[grcnt].task_activity_cd=c_task_sign_cd))
       SET result->grouped_results[grcnt].type = c_fwd_type_to_sign
      ELSEIF ((rep967703->grouped_results[idx].cc_ind=1))
       SET result->grouped_results[grcnt].type = c_cc_result_review
      ELSE
       SET result->grouped_results[grcnt].type = c_fwd_type_to_review
      ENDIF
      SET result->grouped_results[grcnt].discrete_ind = rep967703->grouped_results[idx].discrete_ind
      SET tcnt = 0
      FOR (jdx = 1 TO size(rep967703->grouped_results[idx].result_tasks,5))
        SET taskidspos = findstring("taskIds=",rep967703->grouped_results[idx].result_tasks[jdx].
         notification_uid,1)
        SET eventidspos = findstring("eventIds=",rep967703->grouped_results[idx].result_tasks[jdx].
         notification_uid,1)
        IF (taskidspos > 0
         AND eventidspos > 0)
         SET startpos = (taskidspos+ 8)
         SET taskidsstr = substring(startpos,((eventidspos - startpos) - 1),rep967703->
          grouped_results[idx].result_tasks[jdx].notification_uid)
         WHILE (size(trim(taskidsstr,3)) > 0)
           CALL echo(build("TASKIDSSTR:",taskidsstr))
           SET separatorpos = findstring(":",taskidsstr,1)
           IF (separatorpos > 0)
            SET currenttaskid = substring(1,(separatorpos - 1),taskidsstr)
           ELSE
            SET currenttaskid = taskidsstr
           ENDIF
           CALL echo(build("CURRENTTASKID:",currenttaskid))
           SET tcnt += 1
           SET stat = alterlist(result->grouped_results[grcnt].tasks,tcnt)
           SET result->grouped_results[grcnt].tasks[tcnt].task_id = cnvtreal(currenttaskid)
           SET result->grouped_results[grcnt].tasks[tcnt].task_status_cd = rep967703->
           grouped_results[idx].result_tasks[jdx].task_status_cd
           SET result->grouped_results[grcnt].tasks[tcnt].task_status_disp = uar_get_code_display(
            result->grouped_results[grcnt].tasks[tcnt].task_status_cd)
           SET result->grouped_results[grcnt].tasks[tcnt].task_status_meaning = uar_get_code_meaning(
            result->grouped_results[grcnt].tasks[tcnt].task_status_cd)
           SET result->grouped_results[grcnt].tasks[tcnt].task_dt_tm = rep967703->grouped_results[idx
           ].result_tasks[jdx].task_dt_tm
           SET result->grouped_results[grcnt].tasks[tcnt].event_id = rep967703->grouped_results[idx].
           result_tasks[jdx].event_id
           SET result->grouped_results[grcnt].tasks[tcnt].event_tag = rep967703->grouped_results[idx]
           .result_tasks[jdx].event_tag
           SET result->grouped_results[grcnt].tasks[tcnt].event_class_cd = rep967703->
           grouped_results[idx].result_tasks[jdx].event_class_cd
           SET result->grouped_results[grcnt].tasks[tcnt].event_class_meaning = uar_get_code_meaning(
            result->grouped_results[grcnt].tasks[tcnt].event_class_cd)
           SET result->grouped_results[grcnt].tasks[tcnt].event_end_dt_tm = rep967703->
           grouped_results[idx].result_tasks[jdx].event_end_dt_tm
           SET result->grouped_results[grcnt].tasks[tcnt].performed_prsnl_id = rep967703->
           grouped_results[idx].result_tasks[jdx].performed_prsnl_id
           SET result->grouped_results[grcnt].tasks[tcnt].performed_prsnl_name = rep967703->
           grouped_results[idx].result_tasks[jdx].performed_prsnl_name
           SET result->grouped_results[grcnt].tasks[tcnt].result_status_cd = rep967703->
           grouped_results[idx].result_tasks[jdx].result_status_cd
           SET result->grouped_results[grcnt].tasks[tcnt].result_status_disp = uar_get_code_display(
            result->grouped_results[grcnt].tasks[tcnt].result_status_cd)
           SET result->grouped_results[grcnt].tasks[tcnt].event_set_cd = rep967703->grouped_results[
           idx].result_tasks[jdx].event_set_cd
           SET result->grouped_results[grcnt].tasks[tcnt].event_set_display = rep967703->
           grouped_results[idx].result_tasks[jdx].event_set_display
           SET result->grouped_results[grcnt].tasks[tcnt].parent_event_id = rep967703->
           grouped_results[idx].result_tasks[jdx].parent_event_id
           SET result->grouped_results[grcnt].tasks[tcnt].normalcy_cd = rep967703->grouped_results[
           idx].result_tasks[jdx].normalcy_cd
           SET result->grouped_results[grcnt].tasks[tcnt].normalcy_disp = uar_get_code_description(
            result->grouped_results[grcnt].tasks[tcnt].normalcy_cd)
           SET result->grouped_results[grcnt].tasks[tcnt].comment = rep967703->grouped_results[idx].
           result_tasks[jdx].comments
           SET result->grouped_results[grcnt].tasks[tcnt].msg_sender_id = rep967703->grouped_results[
           idx].result_tasks[jdx].msg_sender_id
           SET result->grouped_results[grcnt].tasks[tcnt].msg_sender_name = rep967703->
           grouped_results[idx].result_tasks[jdx].msg_sender_name
           SET result->grouped_results[grcnt].tasks[tcnt].updt_dt_tm = rep967703->grouped_results[idx
           ].result_tasks[jdx].updated_dt_tm
           SET result->grouped_results[grcnt].tasks[tcnt].encntr_id = rep967703->grouped_results[idx]
           .result_tasks[jdx].encounter_id
           SET result->grouped_results[grcnt].tasks[tcnt].msg_subject = rep967703->grouped_results[
           idx].result_tasks[jdx].msg_subject
           SET treccnt += 1
           SET stat = alterlist(tasks->list,treccnt)
           SET tasks->list[treccnt].task_id = result->grouped_results[grcnt].tasks[tcnt].task_id
           SET tasks->list[treccnt].group_idx = grcnt
           SET tasks->list[treccnt].task_idx = tcnt
           IF (separatorpos > 0)
            SET taskidsstr = substring((separatorpos+ 1),(size(taskidsstr) - separatorpos),taskidsstr
             )
           ELSE
            SET taskidsstr = ""
           ENDIF
         ENDWHILE
        ENDIF
      ENDFOR
    ENDFOR
    IF (treccnt > 0)
     CALL echorecord(tasks)
     SELECT INTO "NL:"
      FROM task_activity ta
      PLAN (ta
       WHERE expand(idx,1,treccnt,ta.task_id,tasks->list[idx].task_id))
      HEAD ta.task_id
       pos = locateval(locidx,1,treccnt,ta.task_id,tasks->list[locidx].task_id)
       WHILE (pos > 0)
         group_idx = tasks->list[pos].group_idx, task_idx = tasks->list[pos].task_idx
         IF (group_idx > 0
          AND task_idx > 0)
          result->grouped_results[group_idx].tasks[task_idx].reference_task_id = ta.reference_task_id,
          result->grouped_results[group_idx].tasks[task_idx].task_create_dt_tm = ta.task_create_dt_tm
         ENDIF
         pos = locateval(locidx,(pos+ 1),treccnt,ta.task_id,tasks->list[locidx].task_id)
       ENDWHILE
      WITH nocounter, time = 30
     ;end select
    ENDIF
    FOR (idx = 1 TO grcnt)
      SET tcnt = size(result->grouped_results[idx].tasks,5)
      IF (tcnt=1)
       SET result->grouped_results[idx].comment = result->grouped_results[idx].tasks[1].comment
      ELSE
       FOR (kdx = 1 TO tcnt)
         IF (size(trim(result->grouped_results[idx].tasks[kdx].comment,3)) > 0)
          SET result->grouped_results[idx].comment = "Multiple"
          SET kdx = (tcnt+ 1)
         ENDIF
       ENDFOR
      ENDIF
      SET tpos = 1
      SET latest_task_dt_tm = result->grouped_results[idx].tasks[tpos].task_dt_tm
      FOR (kdx = 2 TO tcnt)
        IF ((result->grouped_results[idx].tasks[kdx].task_dt_tm > latest_task_dt_tm))
         SET tpos = kdx
         SET latest_task_dt_tm = result->grouped_results[idx].tasks[kdx].task_dt_tm
        ENDIF
      ENDFOR
      SET result->grouped_results[idx].subject = result->grouped_results[idx].tasks[tpos].msg_subject
      SET status_cd = result->grouped_results[idx].tasks[tpos].task_status_cd
      SET status_disp = result->grouped_results[idx].tasks[tpos].task_status_disp
      SET creation_dt_tm = 0.0
      SET updated_dt_tm = 0.0
      SET msg_sender_id = 0.0
      SET msg_from = ""
      FOR (jdx = 1 TO tcnt)
        IF (((creation_dt_tm=0.0) OR ((result->grouped_results[idx].tasks[jdx].task_create_dt_tm <
        creation_dt_tm))) )
         SET creation_dt_tm = result->grouped_results[idx].tasks[jdx].task_create_dt_tm
        ENDIF
        IF (((updated_dt_tm=0.0) OR ((result->grouped_results[idx].tasks[jdx].updt_dt_tm >
        updated_dt_tm))) )
         SET updated_dt_tm = result->grouped_results[idx].tasks[jdx].updt_dt_tm
        ENDIF
        IF (msg_sender_id <= 0.0)
         SET msg_sender_id = result->grouped_results[idx].tasks[jdx].msg_sender_id
         SET msg_from = result->grouped_results[idx].tasks[jdx].msg_sender_name
        ELSEIF ((msg_sender_id != result->grouped_results[idx].tasks[jdx].msg_sender_id))
         SET msg_from = "Multiple"
        ENDIF
      ENDFOR
      SET result->grouped_results[idx].creation_dt_tm = creation_dt_tm
      SET result->grouped_results[idx].updated_dt_tm = updated_dt_tm
      SET result->grouped_results[idx].status_cd = status_cd
      SET result->grouped_results[idx].status_disp = status_disp
      SET result->grouped_results[idx].msg_from = msg_from
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE callcategoryquery(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(967100)
   DECLARE requestid = i4 WITH protect, constant(967678)
   SET req967678->msg_category_knt = 1
   SET stat = alterlist(req967678->msg_category_list,1)
   SET req967678->msg_category_list[1].msg_category_id = cnvtreal( $6)
   SET req967678->load_column_dtl = 0
   SET req967678->load_event_set_dtl = 1
   SET req967678->load_encntr_dtl = 1
   CALL echorecord(req967678)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967678,
    "REC",rep967678,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967678)
   IF ((rep967678->status_data.status != "F"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE callendorsequery(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(1000078)
   DECLARE requestid = i4 WITH protect, constant(1000078)
   DECLARE ecnt = i4 WITH protect, noconstant(0)
   DECLARE qppos = i4 WITH protect, noconstant(0)
   DECLARE cecnt = i4 WITH protect, noconstant(0)
   SET req1000078->search_anchor_dt_tm = cnvtdatetime( $4)
   SET req1000078->seconds_duration = datetimediff(cnvtdatetime( $4),cnvtdatetime( $3),5)
   SET stat = alterlist(req1000078->action_prsnl_list,1)
   SET req1000078->action_prsnl_list[1].person_id =  $2
   IF (size(rep967678->msg_category_list,5) > 0)
    IF (size(rep967678->msg_category_list[1].msg_event_set_grp_dtl_list,5) > 0
     AND size(trim(rep967678->msg_category_list[1].msg_event_set_grp_dtl_list[1].event_set_name,3))
     > 0)
     SET stat = alterlist(req1000078->event_set_list,size(rep967678->msg_category_list[1].
       msg_event_set_grp_dtl_list,5))
     FOR (idx = 1 TO size(rep967678->msg_category_list[1].msg_event_set_grp_dtl_list,5))
       SET req1000078->event_set_list[idx].event_set_name = rep967678->msg_category_list[1].
       msg_event_set_grp_dtl_list[idx].event_set_name
     ENDFOR
    ENDIF
    IF (size(rep967678->msg_category_list[1].msg_encntr_grp_dtl_list,5) > 0
     AND (rep967678->msg_category_list[1].msg_encntr_grp_dtl_list[1].encntr_type_cd > 0))
     SET stat = alterlist(req1000078->encntr_type_list,size(rep967678->msg_category_list[1].
       msg_encntr_grp_dtl_list,5))
     FOR (idx = 1 TO size(rep967678->msg_category_list[1].msg_encntr_grp_dtl_list,5))
       SET req1000078->encntr_type_list[idx].encntr_type_cd = rep967678->msg_category_list[1].
       msg_encntr_grp_dtl_list[idx].encntr_type_cd
     ENDFOR
    ENDIF
   ENDIF
   SET stat = alterlist(req1000078->event_class_list,6)
   SET req1000078->event_class_list[1].event_class_meaning = "DOC"
   SET req1000078->event_class_list[2].event_class_meaning = "MDOC"
   SET req1000078->event_class_list[3].event_class_meaning = "RAD"
   SET req1000078->event_class_list[4].event_class_meaning = "HLATYPING"
   SET req1000078->event_class_list[5].event_class_meaning = "MBO"
   SET req1000078->event_class_list[6].event_class_meaning = "PROCEDURE"
   SET stat = alterlist(req1000078->endorse_status_list,3)
   SET req1000078->endorse_status_list[1].endorse_status_cd = c_onhold_cd
   SET req1000078->endorse_status_list[2].endorse_status_cd = c_opened_cd
   SET req1000078->endorse_status_list[3].endorse_status_cd = c_pending_cd
   SET req1000078->inclusive_event_set_filter_ind = rep967678->msg_category_list[1].
   msg_event_filter_inc_ind
   CALL echorecord(req1000078)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req1000078,
    "REC",rep1000078,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep1000078)
   IF ((rep1000078->sb.statuscd=0.0)
    AND size(rep1000078->prsnl_list,5) > 0)
    FOR (idx = 1 TO size(rep1000078->prsnl_list[1].event_list,5))
      SET ecnt += 1
      SET stat = alterlist(result->events_to_endorse,ecnt)
      SET result->events_to_endorse[ecnt].person_id = rep1000078->prsnl_list[1].event_list[idx].
      person_id
      SET qppos = locateval(locidx,1,size(rep1000078->prsnl_list[1].qual_person_list,5),result->
       events_to_endorse[ecnt].person_id,rep1000078->prsnl_list[1].qual_person_list[locidx].person_id
       )
      IF (qppos > 0)
       SET result->events_to_endorse[ecnt].person_name = rep1000078->prsnl_list[1].qual_person_list[
       qppos].name_full_formatted
      ENDIF
      SET result->events_to_endorse[ecnt].type = c_result_to_endorse
      SET result->events_to_endorse[ecnt].status_cd = rep1000078->prsnl_list[1].event_list[idx].
      endorse_status_cd
      SET result->events_to_endorse[ecnt].status_disp = uar_get_code_display(result->
       events_to_endorse[ecnt].status_cd)
      SET stat = alterlist(result->events_to_endorse[ecnt].child_events,1)
      SET result->events_to_endorse[ecnt].child_events[1].event_id = rep1000078->prsnl_list[1].
      event_list[idx].event_id
      SET result->events_to_endorse[ecnt].child_events[1].event_tag = rep1000078->prsnl_list[1].
      event_list[idx].event_tag
      SET result->events_to_endorse[ecnt].child_events[1].updt_dt_tm = rep1000078->prsnl_list[1].
      event_list[idx].updt_dt_tm
      SET result->events_to_endorse[ecnt].child_events[1].clinsig_updt_dt_tm = rep1000078->
      prsnl_list[1].event_list[idx].clinsig_updt_dt_tm
      SET result->events_to_endorse[ecnt].child_events[1].normalcy_cd = rep1000078->prsnl_list[1].
      event_list[idx].normalcy_cd
      SET result->events_to_endorse[ecnt].child_events[1].normalcy_disp = uar_get_code_display(result
       ->events_to_endorse[ecnt].child_events[1].normalcy_cd)
      SET result->events_to_endorse[ecnt].child_events[1].parent_event_id = rep1000078->prsnl_list[1]
      .event_list[idx].parent_event_id
      SET result->events_to_endorse[ecnt].child_events[1].event_set_cd = rep1000078->prsnl_list[1].
      event_list[idx].event_set_cd
      SET result->events_to_endorse[ecnt].child_events[1].event_set_display = uar_get_code_display(
       result->events_to_endorse[ecnt].child_events[1].event_set_cd)
      SET result->events_to_endorse[ecnt].child_events[1].encntr_id = rep1000078->prsnl_list[1].
      event_list[idx].encntr_id
      SET result->events_to_endorse[ecnt].subject = result->events_to_endorse[ecnt].child_events[1].
      event_tag
    ENDFOR
    FOR (idx = 1 TO size(rep1000078->prsnl_list[1].nonqual_event_list,5))
      SET pos = locateval(locidx,1,ecnt,rep1000078->prsnl_list[1].nonqual_event_list[idx].person_id,
       result->events_to_endorse[locidx].person_id,
       1,result->events_to_endorse[locidx].nonqual_ind)
      IF (pos=0)
       SET ecnt += 1
       SET stat = alterlist(result->events_to_endorse,ecnt)
       SET result->events_to_endorse[ecnt].person_id = rep1000078->prsnl_list[1].nonqual_event_list[
       idx].person_id
       SET result->events_to_endorse[ecnt].nonqual_ind = 1
       SET qppos = locateval(locidx,1,size(rep1000078->prsnl_list[1].nonqual_person_list,5),result->
        events_to_endorse[ecnt].person_id,rep1000078->prsnl_list[1].nonqual_person_list[locidx].
        person_id)
       IF (qppos > 0)
        SET result->events_to_endorse[ecnt].person_name = rep1000078->prsnl_list[1].
        nonqual_person_list[qppos].name_full_formatted
       ENDIF
       SET result->events_to_endorse[ecnt].type = c_result_to_endorse
       SET result->events_to_endorse[ecnt].status_cd = rep1000078->prsnl_list[1].nonqual_event_list[
       idx].endorse_status_cd
       SET result->events_to_endorse[ecnt].status_disp = uar_get_code_display(result->
        events_to_endorse[ecnt].status_cd)
       SET pos = ecnt
      ENDIF
      SET cecnt = (size(result->events_to_endorse[pos].child_events,5)+ 1)
      SET stat = alterlist(result->events_to_endorse[pos].child_events,cecnt)
      SET result->events_to_endorse[pos].child_events[cecnt].event_id = rep1000078->prsnl_list[1].
      nonqual_event_list[idx].event_id
      SET result->events_to_endorse[pos].child_events[cecnt].event_tag = uar_get_code_display(
       rep1000078->prsnl_list[1].nonqual_event_list[idx].event_cd)
      SET result->events_to_endorse[pos].child_events[cecnt].updt_dt_tm = rep1000078->prsnl_list[1].
      nonqual_event_list[idx].updt_dt_tm
      SET result->events_to_endorse[pos].child_events[cecnt].clinsig_updt_dt_tm = rep1000078->
      prsnl_list[1].nonqual_event_list[idx].clinsig_updt_dt_tm
      SET result->events_to_endorse[pos].child_events[cecnt].normalcy_cd = rep1000078->prsnl_list[1].
      nonqual_event_list[idx].normalcy_cd
      SET result->events_to_endorse[pos].child_events[cecnt].normalcy_disp = uar_get_code_display(
       result->events_to_endorse[pos].child_events[cecnt].normalcy_cd)
      SET result->events_to_endorse[pos].child_events[cecnt].event_set_cd = rep1000078->prsnl_list[1]
      .nonqual_event_list[idx].event_set_cd
      SET result->events_to_endorse[pos].child_events[cecnt].event_set_display = uar_get_code_display
      (result->events_to_endorse[pos].child_events[cecnt].event_set_cd)
      SET result->events_to_endorse[pos].child_events[cecnt].encntr_id = rep1000078->prsnl_list[1].
      nonqual_event_list[idx].encntr_id
    ENDFOR
    FOR (idx = 1 TO ecnt)
      SET creation_dt_tm = 0.0
      SET updated_dt_tm = 0.0
      SET folder_name = ""
      SET folder_weight = 0
      FOR (jdx = 1 TO size(result->events_to_endorse[idx].child_events,5))
        IF (((creation_dt_tm=0.0) OR ((result->events_to_endorse[idx].child_events[jdx].
        clinsig_updt_dt_tm < creation_dt_tm))) )
         SET creation_dt_tm = result->events_to_endorse[idx].child_events[jdx].clinsig_updt_dt_tm
        ENDIF
        IF (((updated_dt_tm=0.0) OR ((result->events_to_endorse[idx].child_events[jdx].updt_dt_tm >
        updated_dt_tm))) )
         SET updated_dt_tm = result->events_to_endorse[idx].child_events[jdx].updt_dt_tm
        ENDIF
        SET pos = locateval(locidx,1,size(normalcy->list,5),result->events_to_endorse[idx].
         child_events[jdx].normalcy_cd,normalcy->list[locidx].normalcy_cd)
        IF (pos > 0)
         IF ((normalcy->list[pos].folder_weight > folder_weight))
          SET folder_name = normalcy->list[pos].folder_name
          SET folder_weight = normalcy->list[pos].folder_weight
         ENDIF
        ELSE
         IF (10 > folder_weight)
          SET folder_name = c_folder_other
          SET folder_weight = 10
         ENDIF
        ENDIF
        IF ((result->events_to_endorse[idx].child_events[jdx].normalcy_cd=c_critical_cd))
         SET folder_name = "Critical"
        ELSEIF ((((result->events_to_endorse[idx].child_events[jdx].normalcy_cd=c_abnormal_cd)) OR ((
        result->events_to_endorse[idx].child_events[jdx].normalcy_cd=c_vabnormal_cd)))
         AND folder_name != "Critical")
         SET folder_name = "Abnormal"
        ELSEIF (size(trim(folder_name,3))=0
         AND (result->events_to_endorse[idx].child_events[jdx].normalcy_cd=c_normal_cd))
         SET folder_name = "Normal"
        ELSEIF (folder_name != "Critical"
         AND folder_name != "Abnormal"
         AND (result->events_to_endorse[idx].child_events[jdx].normalcy_cd != c_normal_cd)
         AND (result->events_to_endorse[idx].child_events[jdx].normalcy_cd != c_abnormal_cd)
         AND (result->events_to_endorse[idx].child_events[jdx].normalcy_cd != c_vabnormal_cd)
         AND (result->events_to_endorse[idx].child_events[jdx].normalcy_cd != c_critical_cd))
         SET folder_name = "Other"
        ENDIF
      ENDFOR
      SET result->events_to_endorse[idx].creation_dt_tm = creation_dt_tm
      SET result->events_to_endorse[idx].updated_dt_tm = updated_dt_tm
      SET result->events_to_endorse[idx].folder_name = folder_name
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE getchildeventdetails(null)
   DECLARE events_to_endorse_size = i4 WITH protect, constant(size(result->events_to_endorse,5))
   DECLARE cecnt = i4 WITH protect, noconstant(0)
   DECLARE iref = i4 WITH protect, noconstant(0)
   DECLARE jref = i4 WITH protect, noconstant(0)
   IF (events_to_endorse_size > 0)
    FREE RECORD child_events
    RECORD child_events(
      1 list[*]
        2 event_id = f8
        2 endorse_idx = i4
        2 event_idx = i4
    ) WITH protect
    FOR (idx = 1 TO events_to_endorse_size)
      FOR (jdx = 1 TO size(result->events_to_endorse[idx].child_events,5))
        SET cecnt += 1
        SET stat = alterlist(child_events->list,cecnt)
        SET child_events->list[cecnt].event_id = result->events_to_endorse[idx].child_events[jdx].
        event_id
        SET child_events->list[cecnt].endorse_idx = idx
        SET child_events->list[cecnt].event_idx = jdx
      ENDFOR
    ENDFOR
    SELECT INTO "NL:"
     FROM clinical_event ce,
      person p
     PLAN (ce
      WHERE expand(idx,1,cecnt,ce.event_id,child_events->list[idx].event_id)
       AND ce.valid_until_dt_tm > sysdate)
      JOIN (p
      WHERE p.person_id=ce.performed_prsnl_id)
     HEAD ce.event_id
      pos = locateval(locidx,1,cecnt,ce.event_id,child_events->list[locidx].event_id)
      WHILE (pos > 0)
        iref = child_events->list[pos].endorse_idx, jref = child_events->list[pos].event_idx
        IF (ce.event_class_cd > 0)
         result->events_to_endorse[iref].child_events[jref].event_class_cd = ce.event_class_cd,
         result->events_to_endorse[iref].child_events[jref].event_class_meaning =
         uar_get_code_meaning(ce.event_class_cd)
        ENDIF
        result->events_to_endorse[iref].child_events[jref].event_end_dt_tm = ce.event_end_dt_tm
        IF (ce.performed_prsnl_id > 0)
         result->events_to_endorse[iref].child_events[jref].performed_prsnl_id = ce
         .performed_prsnl_id, result->events_to_endorse[iref].child_events[jref].performed_prsnl_name
          = p.name_full_formatted
        ENDIF
        IF (ce.result_status_cd > 0)
         result->events_to_endorse[iref].child_events[jref].result_status_cd = ce.result_status_cd,
         result->events_to_endorse[iref].child_events[jref].result_status_disp = uar_get_code_display
         (ce.result_status_cd)
        ENDIF
        IF ((result->events_to_endorse[iref].child_events[jref].parent_event_id=0))
         result->events_to_endorse[iref].child_events[jref].parent_event_id = ce.parent_event_id
        ENDIF
        pos = locateval(locidx,(pos+ 1),cecnt,ce.event_id,child_events->list[locidx].event_id)
      ENDWHILE
     WITH nocounter, time = 30
    ;end select
    FREE RECORD child_events
   ENDIF
   RETURN(success)
 END ;Subroutine
END GO
