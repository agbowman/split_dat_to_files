CREATE PROGRAM bhs_athn_get_notifications
 FREE RECORD out_rec
 RECORD out_rec(
   1 assignments[*]
     2 person = vc
     2 person_id = vc
     2 encounter_id = vc
     2 activity_assignment_flag = vc
     2 activity_date_time = vc
     2 update_date_time = vc
     2 task_id = vc
     2 task_status_display = vc
     2 task_status_meaning = vc
     2 task_status_value = vc
     2 task_type_display = vc
     2 task_type_meaning = vc
     2 task_type_value = vc
     2 task_activity_display = vc
     2 task_activity_meaning = vc
     2 task_activity_value = vc
     2 event_id = vc
     2 event_tag = vc
     2 event_class_display = vc
     2 event_class_meaning = vc
     2 event_class_value = vc
     2 result_status_display = vc
     2 result_status_meaning = vc
     2 result_status_value = vc
     2 assign_prsnl = vc
     2 assign_prsnl_id = vc
     2 performed_prsnl = vc
     2 performed_prsnl_id = vc
     2 message_text_id = vc
     2 message_subject = vc
     2 message_sender = vc
     2 message_sender_prsnl_id = vc
     2 normalicy = vc
   1 status = vc
 ) WITH protect
 FREE RECORD req967705
 RECORD req967705(
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
     2 msg_category_config_id = f8
     2 msg_subcategory_config_id = f8
     2 application_number = i4
   1 load
     2 only_unassigned_pool_items_ind = i2
     2 suppress_unauth_docs_ind = i2
     2 all_docs_ind = i2
     2 names_ind = i2
   1 action_prsnl_id = f8
 ) WITH protect
 FREE RECORD rep967705
 RECORD rep967705(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 transaction_uid = vc
   1 documents[*]
     2 notification_uid = vc
     2 person_id = f8
     2 person_name = vc
     2 encounter_id = f8
     2 event_id = f8
     2 result_status_cd = f8
     2 event_class_cd = f8
     2 task_status_cd = f8
     2 notification_type_cd = f8
     2 task_type_cd = f8
     2 task_activity_cd = f8
     2 msg_subject = vc
     2 comments = vc
     2 event_tag = vc
     2 ward_disp = vc
     2 msg_sender_id = f8
     2 msg_sender_name = vc
     2 msg_sender_pool_id = f8
     2 msg_sender_pool_name = vc
     2 performed_prsnl_id = f8
     2 performed_prsnl_name = vc
     2 transcribed_prsnl_id = f8
     2 transcribed_prsnl_name = vc
     2 creation_dt_tm = dq8
     2 updated_dt_tm = dq8
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 version = i4
     2 owner_version = i4
     2 assign_prsnl_id = f8
     2 assign_prsnl_name = vc
     2 assign_pool_id = f8
     2 assign_pool_name = vc
     2 fwd_docs[*]
       3 notification_uid = vc
       3 comments = vc
       3 msg_sender_id = f8
       3 msg_sender_name = vc
       3 msg_sender_pool_id = f8
       3 msg_sender_pool_name = vc
       3 creation_dt_tm = dq8
       3 version = i4
       3 owner_version = i4
     2 document_type
       3 paper_document_ind = i2
       3 block_signature_ind = i2
       3 anticipated_document_ind = i2
       3 powernote_ind = i2
     2 transcribers[*]
       3 transcriber_prsnl_id = f8
       3 transcriber_prsnl_name = vc
   1 document_limit_exceeded_ind = i2
 ) WITH protect
 DECLARE callgetnotifications(null) = i4
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 SET out_rec->status = "F"
 IF (( $2 <= 0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $5 <= 0)
  AND ( $6 < 0))
  CALL echo("INVALID CATEGORY ID/SUBCATEGORY ID PARAMETERS...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callgetnotifications(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET out_rec->status = "S"
#exit_script
 CALL echorecord(out_rec)
 SET _memory_reply_string = cnvtrectojson(out_rec)
 FREE RECORD out_rec
 FREE RECORD req967705
 FREE RECORD rep967705
 SUBROUTINE callgetnotifications(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(967100)
   DECLARE requestid = i4 WITH protect, constant(967705)
   DECLARE c_onhold_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"ONHOLD"))
   DECLARE c_opened_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OPENED"))
   DECLARE c_pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   IF (( $7 > 0))
    SET req967705->receiver.pool_id =  $7
   ELSE
    SET req967705->receiver.provider_id =  $2
   ENDIF
   SET req967705->date_range.begin_dt_tm = cnvtdatetime( $3)
   SET req967705->date_range.end_dt_tm = cnvtdatetime( $4)
   SET stat = alterlist(req967705->status_codes,3)
   SET req967705->status_codes[1].status_cd = c_onhold_cd
   SET req967705->status_codes[2].status_cd = c_opened_cd
   SET req967705->status_codes[3].status_cd = c_pending_cd
   SET req967705->configuration.msg_category_config_id =  $5
   SET req967705->configuration.msg_subcategory_config_id =  $6
   SET req967705->configuration.application_number = 600005
   SET req967705->load.suppress_unauth_docs_ind = 1
   SET req967705->load.names_ind = 1
   IF (( $7 > 0))
    SET req967705->action_prsnl_id = 0
   ELSE
    SET req967705->action_prsnl_id =  $2
   ENDIF
   CALL echorecord(req967705)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967705,
    "REC",rep967705,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967705)
   IF ((rep967705->transaction_status.success_ind=1))
    SET stat = alterlist(out_rec->assignments,size(rep967705->documents,5))
    FOR (idx = 1 TO size(rep967705->documents,5))
      SET out_rec->assignments[idx].task_id = substring((findstring("taskIds=",rep967705->documents[
        idx].notification_uid,1,0)+ 8),((findstring(",eventIds=",rep967705->documents[idx].
        notification_uid,1,0) - 10) - (findstring("taskIds=",rep967705->documents[idx].
        notification_uid,1,0) - 2)),rep967705->documents[idx].notification_uid)
      SET out_rec->assignments[idx].person_id = cnvtstring(rep967705->documents[idx].person_id)
      SET out_rec->assignments[idx].person = rep967705->documents[idx].person_name
      SET out_rec->assignments[idx].encounter_id = cnvtstring(rep967705->documents[idx].encounter_id)
      SET out_rec->assignments[idx].event_id = cnvtstring(rep967705->documents[idx].event_id)
      SET out_rec->assignments[idx].event_tag = rep967705->documents[idx].event_tag
      SET out_rec->assignments[idx].result_status_value = cnvtstring(rep967705->documents[idx].
       result_status_cd)
      SET out_rec->assignments[idx].result_status_display = uar_get_code_display(rep967705->
       documents[idx].result_status_cd)
      SET out_rec->assignments[idx].result_status_meaning = uar_get_code_meaning(rep967705->
       documents[idx].result_status_cd)
      SET out_rec->assignments[idx].task_status_value = cnvtstring(rep967705->documents[idx].
       task_status_cd)
      SET out_rec->assignments[idx].task_status_display = uar_get_code_display(rep967705->documents[
       idx].task_status_cd)
      SET out_rec->assignments[idx].task_status_meaning = uar_get_code_meaning(rep967705->documents[
       idx].task_status_cd)
      SET out_rec->assignments[idx].task_type_value = cnvtstring(rep967705->documents[idx].
       task_type_cd)
      SET out_rec->assignments[idx].task_type_display = uar_get_code_display(rep967705->documents[idx
       ].task_type_cd)
      SET out_rec->assignments[idx].task_type_meaning = uar_get_code_meaning(rep967705->documents[idx
       ].task_type_cd)
      SET out_rec->assignments[idx].task_activity_value = cnvtstring(rep967705->documents[idx].
       task_activity_cd)
      SET out_rec->assignments[idx].task_activity_display = uar_get_code_display(rep967705->
       documents[idx].task_activity_cd)
      SET out_rec->assignments[idx].task_activity_meaning = uar_get_code_meaning(rep967705->
       documents[idx].task_activity_cd)
      SET out_rec->assignments[idx].event_class_value = cnvtstring(rep967705->documents[idx].
       event_class_cd)
      SET out_rec->assignments[idx].event_class_display = uar_get_code_display(rep967705->documents[
       idx].event_class_cd)
      SET out_rec->assignments[idx].event_class_meaning = uar_get_code_meaning(rep967705->documents[
       idx].event_class_cd)
      SET out_rec->assignments[idx].message_subject = rep967705->documents[idx].msg_subject
      SET out_rec->assignments[idx].message_sender_prsnl_id = cnvtstring(rep967705->documents[idx].
       msg_sender_id)
      SET out_rec->assignments[idx].message_sender = rep967705->documents[idx].msg_sender_name
      SET out_rec->assignments[idx].assign_prsnl_id = cnvtstring(rep967705->documents[idx].
       assign_prsnl_id)
      SET out_rec->assignments[idx].assign_prsnl = rep967705->documents[idx].assign_prsnl_name
      SET out_rec->assignments[idx].performed_prsnl_id = cnvtstring(rep967705->documents[idx].
       performed_prsnl_id)
      SET out_rec->assignments[idx].performed_prsnl = rep967705->documents[idx].performed_prsnl_name
      SET out_rec->assignments[idx].activity_date_time = datetimezoneformat(rep967705->documents[idx]
       .creation_dt_tm,datetimezonebyname(curtimezone),"MM/dd/yyyy HH:mm:ss",curtimezonedef)
      SET out_rec->assignments[idx].update_date_time = datetimezoneformat(rep967705->documents[idx].
       updated_dt_tm,datetimezonebyname(curtimezone),"MM/dd/yyyy HH:mm:ss",curtimezonedef)
      IF (uar_get_code_meaning(rep967705->documents[idx].notification_type_cd)="DICTATE_DOC")
       SET out_rec->assignments[idx].activity_assignment_flag = "DocumentsToDictate"
      ELSEIF (uar_get_code_meaning(rep967705->documents[idx].notification_type_cd)="FD_RVIEW_DOC")
       SET out_rec->assignments[idx].activity_assignment_flag = "ForwardDocumentToReview"
      ELSEIF (uar_get_code_meaning(rep967705->documents[idx].notification_type_cd)="FD_SIGN_DOC")
       SET out_rec->assignments[idx].activity_assignment_flag = "ForwardDocumentToSign"
      ELSEIF (uar_get_code_meaning(rep967705->documents[idx].notification_type_cd)="REVIEW_DOC")
       SET out_rec->assignments[idx].activity_assignment_flag = "DocumentToReview"
      ELSEIF (uar_get_code_meaning(rep967705->documents[idx].notification_type_cd)="SIGN_DOC")
       SET out_rec->assignments[idx].activity_assignment_flag = "DocumentToSign"
      ELSEIF (uar_get_code_meaning(rep967705->documents[idx].notification_type_cd)="SAVED_DOC")
       SET out_rec->assignments[idx].activity_assignment_flag = "SavedDocument"
      ELSE
       SET out_rec->assignments[idx].activity_assignment_flag = uar_get_code_display(rep967705->
        documents[idx].notification_type_cd)
      ENDIF
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
