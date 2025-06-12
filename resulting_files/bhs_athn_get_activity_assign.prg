CREATE PROGRAM bhs_athn_get_activity_assign
 RECORD orequest(
   1 assign_prsnl_list[*]
     2 assign_prsnl_id = f8
   1 task_type_list[*]
     2 task_type = i2
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 get_all_active_status_ind = i2
   1 get_completed_endorsements_ind = i2
   1 get_onhold_endorsements_ind = i2
   1 apply_group_proxy_ind = i2
   1 suppress_unauth_doc_reviews_ind = i2
 )
 RECORD t_record(
   1 task_type_qual[8]
     2 task = vc
     2 task_type = i2
     2 get_ind = i2
 )
 RECORD out_rec(
   1 assignments[*]
     2 person = vc
     2 person_id = vc
     2 encounter_id = vc
     2 activity_assignment_flag = vc
     2 activity_date_time = vc
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
 )
 DECLARE date_line = vc
 DECLARE time_line = vc
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET cnt = 0
 SET t_record->task_type_qual[1].task_type = 1
 SET t_record->task_type_qual[1].task = "ForwardedResultToSign"
 SET t_record->task_type_qual[2].task_type = 2
 SET t_record->task_type_qual[2].task = "ForwardDocumentToReview"
 SET t_record->task_type_qual[3].task_type = 3
 SET t_record->task_type_qual[3].task = "ForwardResultToReview"
 SET t_record->task_type_qual[4].task_type = 4
 SET t_record->task_type_qual[4].task = "ForwardDocumentToSign"
 SET t_record->task_type_qual[5].task_type = 5
 SET t_record->task_type_qual[5].task = "DocumentsToDictate"
 SET t_record->task_type_qual[6].task_type = 6
 SET t_record->task_type_qual[6].task = "DocumentToReview"
 SET t_record->task_type_qual[7].task_type = 7
 SET t_record->task_type_qual[7].task = "DocumentToSign"
 SET t_record->task_type_qual[8].task_type = 8
 SET t_record->task_type_qual[8].task = "SavedDocument"
 SET stat = alterlist(orequest->assign_prsnl_list,1)
 SET orequest->assign_prsnl_list[cnt].assign_prsnl_id =  $2
 IF (( $3 > " "))
  SET t_line =  $3
  WHILE (done=0)
    IF (findstring(",",t_line)=0)
     SET cnt = (cnt+ 1)
     SET done = 1
     FOR (i = 1 TO 8)
       IF ((t_line=t_record->task_type_qual[i].task))
        SET t_record->task_type_qual[i].get_ind = 1
       ENDIF
     ENDFOR
    ELSE
     SET cnt = (cnt+ 1)
     SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
     SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
     FOR (i = 1 TO 8)
       IF ((t_line2=t_record->task_type_qual[i].task))
        SET t_record->task_type_qual[i].get_ind = 1
       ENDIF
     ENDFOR
    ENDIF
  ENDWHILE
 ENDIF
 SET cnt = 0
 FOR (i = 1 TO 8)
   IF ((t_record->task_type_qual[i].get_ind=1))
    SET cnt = (cnt+ 1)
    SET stat = alterlist(orequest->task_type_list,cnt)
    SET orequest->task_type_list[cnt].task_type = t_record->task_type_qual[i].task_type
   ENDIF
 ENDFOR
 SET date_line = substring(1,10, $4)
 SET time_line = substring(12,8, $4)
 SET orequest->beg_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",4)
 SET date_line = substring(1,10, $5)
 SET time_line = substring(12,8, $5)
 SET orequest->end_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",4)
 SET stat = tdbexecute(3200000,3200015,967140,"REC",orequest,
  "REC",oreply)
 SET stat = alterlist(out_rec->assignments,size(oreply->endorsement_list,5))
 FOR (i = 1 TO size(oreply->endorsement_list,5))
   SET out_rec->assignments[i].person = oreply->endorsement_list[i].person_name
   SET out_rec->assignments[i].person_id = trim(cnvtstring(oreply->endorsement_list[i].person_id))
   SET out_rec->assignments[i].encounter_id = trim(cnvtstring(oreply->endorsement_list[i].encntr_id))
   SET out_rec->assignments[i].activity_date_time = datetimezoneformat(oreply->endorsement_list[i].
    task_dt_tm,datetimezonebyname(curtimezone),"MM/dd/yyyy HH:mm:ss",curtimezonedef)
   SET out_rec->assignments[i].task_id = trim(cnvtstring(oreply->endorsement_list[i].task_id))
   SET out_rec->assignments[i].task_status_display = oreply->endorsement_list[i].task_status_display
   SET out_rec->assignments[i].task_status_meaning = oreply->endorsement_list[i].task_status_meaning
   SET out_rec->assignments[i].task_status_value = trim(cnvtstring(oreply->endorsement_list[i].
     task_status_cd))
   SET out_rec->assignments[i].task_type_display = oreply->endorsement_list[i].task_type_display
   SET out_rec->assignments[i].task_type_meaning = oreply->endorsement_list[i].task_type_meaning
   SET out_rec->assignments[i].task_type_value = trim(cnvtstring(oreply->endorsement_list[i].
     task_type_cd))
   SET out_rec->assignments[i].task_activity_display = uar_get_code_display(oreply->endorsement_list[
    i].task_activity_cd)
   SET out_rec->assignments[i].task_activity_meaning = oreply->endorsement_list[i].
   task_activity_meaning
   SET out_rec->assignments[i].task_activity_value = trim(cnvtstring(oreply->endorsement_list[i].
     task_activity_cd))
   SET out_rec->assignments[i].event_id = trim(cnvtstring(oreply->endorsement_list[i].event_id))
   SET out_rec->assignments[i].event_tag = oreply->endorsement_list[i].event_tag
   SET out_rec->assignments[i].event_class_display = oreply->endorsement_list[i].event_class_display
   SET out_rec->assignments[i].event_class_meaning = oreply->endorsement_list[i].event_class_meaning
   SET out_rec->assignments[i].event_class_value = trim(cnvtstring(oreply->endorsement_list[i].
     event_class_cd))
   SET out_rec->assignments[i].result_status_display = oreply->endorsement_list[i].
   result_status_display
   SET out_rec->assignments[i].result_status_meaning = oreply->endorsement_list[i].
   result_status_meaning
   SET out_rec->assignments[i].result_status_value = trim(cnvtstring(oreply->endorsement_list[i].
     result_status_cd))
   SET out_rec->assignments[i].assign_prsnl = oreply->endorsement_list[i].assign_prsnl_name
   SET out_rec->assignments[i].assign_prsnl_id = trim(cnvtstring(oreply->endorsement_list[i].
     assign_prsnl_id))
   SET out_rec->assignments[i].performed_prsnl = oreply->endorsement_list[i].performed_prsnl_name
   SET out_rec->assignments[i].performed_prsnl_id = trim(cnvtstring(oreply->endorsement_list[i].
     performed_prsnl_id))
   SET out_rec->assignments[i].message_text_id = trim(cnvtstring(oreply->endorsement_list[i].
     msg_text_id))
   SET out_rec->assignments[i].message_subject = oreply->endorsement_list[i].msg_subject
   SET out_rec->assignments[i].message_sender = oreply->endorsement_list[i].msg_sender_name
   SET out_rec->assignments[i].message_sender_prsnl_id = trim(cnvtstring(oreply->endorsement_list[i].
     msg_sender_id))
   SET out_rec->assignments[i].normalicy = uar_get_code_display(oreply->endorsement_list[i].
    normalcy_cd)
   FOR (j = 1 TO 8)
     IF ((oreply->endorsement_list[i].task_type=t_record->task_type_qual[j].task_type))
      SET out_rec->assignments[i].activity_assignment_flag = t_record->task_type_qual[j].task
     ENDIF
   ENDFOR
 ENDFOR
 CALL echojson(out_rec, $1)
END GO
