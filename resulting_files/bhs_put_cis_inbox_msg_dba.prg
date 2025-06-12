CREATE PROGRAM bhs_put_cis_inbox_msg:dba
 PROMPT
  "patient CMRN" = "",
  "Inbox Id" = 0,
  "Sender ID" = "",
  "msg id" = "",
  "message type" = "",
  "msg date" = "",
  "time" = "",
  "Priority" = 0,
  "msg subject" = "",
  "msg body" = "",
  "pvix link" = ""
  WITH s_pat_cmrn, s_inbox_id, s_sender_id,
  s_msg_id, s_msg_type, s_msg_dt,
  s_msg_time, s_msg_priority, s_subject,
  s_msg_body, s_pvix_link
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_status = vc
 ) WITH protect
 DECLARE ms_sender_id = vc WITH protect, constant( $S_SENDER_ID)
 DECLARE mf_sender_id = f8 WITH protect, constant(cnvtreal( $S_SENDER_ID))
 DECLARE ms_recipient_id = vc WITH protect, constant( $S_INBOX_ID)
 DECLARE mf_recipient_id = f8 WITH protect, constant(cnvtreal( $S_INBOX_ID))
 DECLARE ms_msg_id = vc WITH protect, constant(trim( $S_MSG_ID))
 DECLARE ms_msg_type = vc WITH protect, constant(trim( $S_MSG_TYPE))
 DECLARE ms_msg_dt = vc WITH protect, constant(trim( $S_MSG_DT))
 DECLARE ms_msg_time = vc WITH protect, constant(trim( $S_MSG_TIME))
 DECLARE ms_msg_priority = vc WITH protect, constant(trim( $S_MSG_PRIORITY))
 DECLARE ms_pvix_link = vc WITH protect, constant(trim( $S_PVIX_LINK))
 DECLARE mf_phonemsg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6026,"PHONEMSG"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_routine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",1304,"ROUTINE"))
 DECLARE mf_prov_nbr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BHSEXTERNALID")
  )
 DECLARE ms_pat_cmrn = vc WITH protect, noconstant(trim( $S_PAT_CMRN))
 DECLARE mn_inbox_type = i2 WITH protect, noconstant(0)
 DECLARE mf_inbox_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_msg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mn_month = i2 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE mf_portal_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_patient_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_subject = vc WITH protect, noconstant(trim( $S_SUBJECT))
 DECLARE ms_body = vc WITH protect, noconstant(trim( $S_MSG_BODY))
 DECLARE mf_task_id = f8 WITH protect, noconstant(0.0)
 SET ms_msg_dt_tm = substring(9,2,ms_msg_dt)
 SET mn_month = cnvtint(substring(6,2,ms_msg_dt))
 CASE (mn_month)
  OF 1:
   SET ms_tmp = "JAN"
  OF 2:
   SET ms_tmp = "FEB"
  OF 3:
   SET ms_tmp = "MAR"
  OF 4:
   SET ms_tmp = "APR"
  OF 5:
   SET ms_tmp = "MAY"
  OF 6:
   SET ms_tmp = "JUN"
  OF 7:
   SET ms_tmp = "JUL"
  OF 8:
   SET ms_tmp = "AUG"
  OF 9:
   SET ms_tmp = "SEP"
  OF 10:
   SET ms_tmp = "OCT"
  OF 11:
   SET ms_tmp = "NOV"
  OF 12:
   SET ms_tmp = "DEC"
 ENDCASE
 SET ms_msg_dt_tm = concat(ms_msg_dt_tm,"-",ms_tmp)
 SET ms_msg_dt_tm = concat(ms_msg_dt_tm,"-",substring(1,4,ms_msg_dt)," ",ms_msg_time)
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
     2 notify_info[1]
       3 notify_pool_ind = f8
       3 notify_prsnl_id = f8
       3 notify_priority_cd = f8
       3 notify_status_list[*]
         4 notify_status_cd = f8
         4 delay[1]
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
 )
 RECORD inboxreply(
   1 task_id = f8
   1 status_data[1]
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 invalid_receivers[*]
     2 entity_id = f8
     2 entity_type = vc
 )
 EXECUTE bhs_hlp_ccl
 SET m_rec->s_status = "ERROR"
 CALL echo("check prsnl id")
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.person_id=mf_recipient_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
  HEAD p.person_id
   mn_inbox_type = 1, mf_inbox_id = p.person_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "not prsnl"
  CALL echo("check org id")
  SET ms_tmp = ms_recipient_id
  WHILE (substring(1,1,ms_tmp)="0")
   SET ms_tmp = substring(2,(textlen(ms_recipient_id) - 1),ms_recipient_id)
   CALL echo(ms_tmp)
  ENDWHILE
  SELECT INTO "nl:"
   FROM prsnl_alias pa
   PLAN (pa
    WHERE pa.alias=ms_tmp
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > sysdate
     AND pa.alias_pool_cd=mf_prov_nbr_cd)
   HEAD pa.person_id
    mn_inbox_type = 1, mf_inbox_id = pa.person_id
   WITH nocounter
  ;end select
 ENDIF
 IF (mf_inbox_id=0.0)
  SET ms_log = concat(ms_log," not org")
  CALL echo("check pool id")
  SELECT INTO "nl:"
   FROM prsnl_group pg
   PLAN (pg
    WHERE pg.prsnl_group_id=mf_recipient_id
     AND pg.active_ind=1
     AND pg.end_effective_dt_tm > sysdate)
   HEAD pg.prsnl_group_id
    mn_inbox_type = 2, mf_inbox_id = mf_recipient_id
   WITH nocounter
  ;end select
 ENDIF
 IF (mn_inbox_type=0)
  SET ms_log = concat(ms_log," No individual or pool inbox id matches that ID")
  CALL echo(ms_log)
  GO TO exit_script
 ENDIF
 WHILE (substring(1,1,ms_pat_cmrn)="0")
   SET ms_pat_cmrn = trim(substring(2,textlen(ms_pat_cmrn),ms_pat_cmrn))
 ENDWHILE
 SELECT INTO "nl:"
  FROM person_alias pa
  PLAN (pa
   WHERE pa.person_alias_type_cd=mf_cmrn_cd
    AND pa.alias=ms_pat_cmrn
    AND pa.active_ind=1)
  DETAIL
   mf_patient_id = pa.person_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = concat(ms_log,"Patient ID not found")
  CALL echo("ms_log")
  GO TO exit_script
 ENDIF
 SET ms_subject = concat(ms_subject," [",ms_msg_id,"]")
 SET ms_subject = replace(ms_subject,"%3F","?",0)
 SET ms_body = replace(ms_body,"%3F","?",0)
 SET ms_subject = replace(ms_subject,"%27","'",0)
 SET ms_body = replace(ms_body,"%27","'",0)
 SET ms_subject = replace(ms_subject,"^",'"',0)
 SET ms_body = replace(ms_body,"^",'"',0)
 SET stat = alterlist(inboxrequest->message_list,1)
 SET inboxrequest->message_list[1].msg_sender_prsnl_id = mf_sender_id
 SET inboxrequest->message_list[1].person_id = mf_patient_id
 SET inboxrequest->message_list[1].encntr_id = 0
 SET inboxrequest->message_list[1].task_type_cd = 2678
 SET inboxrequest->message_list[1].msg_text = ms_body
 SET inboxrequest->message_list[1].msg_subject = ms_subject
 SET inboxrequest->message_list[1].event_id = 0
 SET inboxrequest->message_list[1].priority_cd = mf_routine_cd
 IF (mn_inbox_type=1)
  CALL echo("send to individual inbox")
  SET stat = alterlist(inboxrequest->message_list[1].assign_prsnl_list,1)
  SET inboxrequest->message_list[1].assign_prsnl_list[1].assign_prsnl_id = mf_inbox_id
 ELSEIF (mn_inbox_type=2)
  SET ms_log = concat(ms_log,"send to pool")
  CALL echo("send to pool inbox")
  SET stat = alterlist(inboxrequest->message_list[1].assign_pool_list,1)
  SET inboxrequest->message_list[1].assign_pool_list[1].assign_pool_id = mf_inbox_id
 ENDIF
 SET stat = tdbexecute(0,967100,967503,"REC",inboxrequest,
  "REC",inboxreply)
 IF (cnvtupper(inboxreply->status_data[1].status)="S")
  SET ms_log = "Success"
  SET m_rec->s_status = "Success"
  SELECT INTO "nl:"
   FROM task_activity ta
   WHERE (ta.msg_sender_id=inboxrequest->message_list[1].msg_sender_prsnl_id)
    AND ta.updt_dt_tm > cnvtlookbehind("5,S",sysdate)
    AND ta.msg_subject=ms_subject
   HEAD REPORT
    mf_task_id = ta.task_id
   WITH nocounter
  ;end select
  IF (curqual < 1)
   CALL echo("task id not found")
   GO TO exit_script
  ENDIF
  CALL echo(concat("task id: ",trim(cnvtstring(mf_task_id))))
  UPDATE  FROM task_activity ta
   SET ta.external_reference_number = ms_msg_id, ta.updt_dt_tm = sysdate
   WHERE ta.task_id=mf_task_id
   WITH nocounter
  ;end update
  COMMIT
 ELSE
  SET m_rec->s_status = "Error"
  SET ms_log = concat(ms_log," Message failed to send to CIS inbox")
 ENDIF
#exit_script
 SET ms_subject = substring(1,100,ms_subject)
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Begin Script","")
 CALL bhs_sbr_log("log","",0,"SenderID",mf_sender_id,
  ms_msg_dt_tm,ms_msg_id,"S")
 CALL bhs_sbr_log("log","",0,"TaskID",mf_task_id,
  "",ms_subject,"S")
 CALL bhs_sbr_log("log","",0,"PatientID",mf_patient_id,
  ms_pat_cmrn,"","S")
 CALL bhs_sbr_log("log","",0,"InboxID",mf_inbox_id,
  ms_recipient_id,trim(cnvtstring(mn_inbox_type),3),"S")
 CALL bhs_sbr_log("log","",0,"StatusDetail",0.00,
  ms_log,m_rec->s_status,"S")
 CALL bhs_sbr_log("stop","",0,"",0.0,
  m_rec->s_status,"000","S")
 SET ms_tmp = concat('[{"Status":"',m_rec->s_status,'","StatusDetail":"',ms_log,'"}]')
 SET _memory_reply_string = ms_tmp
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
