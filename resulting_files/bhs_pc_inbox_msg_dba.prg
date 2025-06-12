CREATE PROGRAM bhs_pc_inbox_msg:dba
 FREE RECORD inboxrequest
 RECORD inboxrequest(
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
     2 result_set_id = f8
   1 action_dt_tm = dq8
   1 action_tz = i4
   1 skip_validation_ind = i2
 )
 FREE RECORD inboxreply
 RECORD inboxreply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 invalid_receivers[*]
     2 entity_id = f8
     2 entity_type = vc
   1 notifications[*]
     2 task_id = f8
     2 event_id = f8
 )
 DECLARE mf_stat_high_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1304,"STAT"))
 DECLARE mf_routine_low_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1304,"ROUTINE"))
 DECLARE mf_phone_msg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"PHONE MSG"))
 CALL echo(build2("*** Send a MSG_TYPE related to PATIENT to the In-Box",
   " of RECIPIENT with subject SUBJECT and message MSG with priority MSG_PRIORITY."))
 IF ( NOT ((m_content->f_person_id > 0)))
  CALL echo(build2("Error in validating parameters. No messages sent."," - ",build(m_content->
     f_person_id)))
  GO TO exit_script
 ENDIF
 SET stat = alterlist(inboxrequest->message_list,1)
 SET inboxrequest->message_list[1].person_id = m_content->f_person_id
 SET inboxrequest->message_list[1].encntr_id = m_content->f_encntr_id
 SET inboxrequest->message_list[1].order_id = m_content->f_order_id
 SET inboxrequest->message_list[1].task_type_cd = m_content->f_task_type_cd
 SET inboxrequest->message_list[1].event_cd = m_content->f_event_cd
 SET inboxrequest->message_list[1].msg_sender_prsnl_id = m_content->f_msg_sender_prsnl_id
 SET inboxrequest->message_list[1].msg_subject = m_content->s_subject
 SET inboxrequest->message_list[1].msg_text = m_content->s_message
 SET inboxrequest->message_list[1].event_id = m_content->f_event_id
 SET inboxrequest->message_list[1].save_to_chart_ind = m_content->n_save_to_chart_ind
 SET inboxrequest->action_dt_tm = cnvtdatetime(sysdate)
 SET inboxrequest->skip_validation_ind = 1
 IF (size(m_content->assign_pool_list,5) > 0)
  SET stat = alterlist(inboxrequest->message_list[1].assign_pool_list,size(m_content->
    assign_pool_list,5))
  FOR (apx = 1 TO size(m_content->assign_pool_list,5))
   SET inboxrequest->message_list[1].assign_pool_list[apx].assign_pool_id = m_content->
   assign_pool_list[apx].f_assign_pool_id
   SET inboxrequest->message_list[1].assign_pool_list[apx].assign_prsnl_id = m_content->
   assign_pool_list[apx].f_assign_prsnl_id
  ENDFOR
 ELSEIF (size(m_content->assign_prsnl_list,5) > 0)
  SET stat = alterlist(inboxrequest->message_list[1].assign_prsnl_list,size(m_content->
    assign_prsnl_list,5))
  FOR (apx = 1 TO size(m_content->assign_prsnl_list,5))
    SET inboxrequest->message_list[1].assign_prsnl_list[apx].assign_prsnl_id = m_content->
    assign_prsnl_list[apx].f_assign_prsnl_id
  ENDFOR
 ENDIF
 IF ((m_content->l_priority=3))
  SET inboxrequest->message_list[1].priority_cd = mf_stat_high_cd
 ELSE
  SET inboxrequest->message_list[1].priority_cd = mf_routine_low_cd
 ENDIF
 CALL echorecord(inboxrequest)
 SET stat = tdbexecute(967100,967100,967503,"REC",inboxrequest,
  "REC",inboxreply)
#exit_script
END GO
