CREATE PROGRAM cleanup_inerror_patient_tasks
 DECLARE days_back = i4 WITH protect, noconstant(60)
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (curbatch=1)
  IF ((request->searchback_days != null)
   AND (request->searchback_days > 0))
   SET days_back = request->searchback_days
  ELSE
   IF ((request->batch_selection != null))
    SET request->batch_selection = trim(request->batch_selection,3)
    IF (isnumeric(request->batch_selection) != 1)
     CALL echo("Non-numberic values are not valid for days back")
     SET reply->status_data.status = "F"
     GO TO exit_script
    ELSE
     DECLARE temp_days_back = i4 WITH protect, constant(cnvtint(request->batch_selection))
     IF (temp_days_back > 0)
      SET days_back = temp_days_back
     ELSE
      CALL echo("Invalid searchback days entered. Resubmit a new value.")
      SET reply->status_data.status = "F"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 RECORD tasks(
   1 task[*]
     2 task_id = f8
 ) WITH protect
 RECORD messages(
   1 message[*]
     2 task_id = f8
     2 event_id = f8
     2 updt_dt_tm = dq8
     2 assigned_patient_id = f8
     2 patient_name = vc
     2 assigned_prsnl_id = f8
     2 personnel_name = vc
     2 assigned_pool_id = f8
     2 external_email = vc
     2 subject_txt = vc
 ) WITH protect
 DECLARE task_status_in_error_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"INERROR"))
 DECLARE inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE inerror_nomut_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE inerror_noview_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 IF (((inerror_cd <= 0) OR (((inerror_noview_cd <= 0) OR (inerror_nomut_cd <= 0)) )) )
  CALL echo("")
  CALL echo("Error loading codeset 8. Exiting Script.")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF (task_status_in_error_cd <= 0)
  CALL echo("")
  CALL echo("Error loading codeset 79. Exiting Script.")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 DECLARE task_cnt = i4 WITH protect, noconstant(0)
 DECLARE task_assignment_cnt = i4 WITH protect, noconstant(0)
 DECLARE message_cnt = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, constant(200)
 DECLARE task_list_buffer = i4 WITH protect, constant(50)
 DECLARE task_assignment_list_buffer = i4 WITH protect, constant(10)
 DECLARE message_list_buffer = i4 WITH protect, constant(50)
 DECLARE temp_date = c8
 DECLARE temp_time = c6
 DECLARE begin_dt_tm = dq8 WITH protect, noconstant(0)
 DECLARE end_dt_tm = dq8 WITH protect, noconstant(0)
 IF (curbatch=1)
  SET begin_dt_tm = cnvtdatetime((curdate - days_back),0)
  SET end_dt_tm = cnvtdatetime((curdate+ 1),0)
 ENDIF
 DECLARE prsnl_id = f8 WITH protect, noconstant(reqinfo->updt_id)
 SET y = "MM/dd/yyyy hh:mm:ss"
 IF (curbatch=0)
  CALL clear(10,1)
  WHILE (begin_dt_tm <= 0)
    CALL clear(11,1)
    CALL clear(12,1)
    CALL text(11,1,
     "Please enter the earliest date and time for which you want tasks to be inactivated:")
    CALL accept(12,1,"99D99D9999D99D99D99;CU",y)
    SET temp_date = concat(substring(1,2,curaccept),substring(4,2,curaccept),substring(7,4,curaccept)
     )
    SET temp_time = concat(substring(12,2,curaccept),substring(15,2,curaccept),substring(18,2,
      curaccept))
    SET begin_dt_tm = cnvtdatetime(cnvtdate(temp_date),cnvtint(temp_time))
    IF (begin_dt_tm <= 0)
     CALL clear(10,1)
     CALL text(10,1,"A Begin Date must be specified before script may execute. Please retry.")
    ENDIF
  ENDWHILE
  CALL clear(13,1)
  WHILE (end_dt_tm <= 0)
    CALL clear(14,1)
    CALL clear(15,1)
    CALL text(14,1,
     "Please enter the latest date and time for which you want tasks to be inactivated:")
    CALL accept(15,1,"99D99D9999D99D99D99;CU",y)
    SET temp_date = concat(substring(1,2,curaccept),substring(4,2,curaccept),substring(7,4,curaccept)
     )
    SET temp_time = concat(substring(12,2,curaccept),substring(15,2,curaccept),substring(18,2,
      curaccept))
    SET end_dt_tm = cnvtdatetime(cnvtdate(temp_date),cnvtint(temp_time))
    IF (end_dt_tm <= 0)
     CALL clear(13,1)
     CALL text(13,1,"An End Date must be specified before script may execute. Please retry.")
    ENDIF
  ENDWHILE
  IF (end_dt_tm < begin_dt_tm)
   DECLARE temp_dt_tm = dq8 WITH protect, constant(end_dt_tm)
   SET end_dt_tm = begin_dt_tm
   SET begin_dt_tm = temp_dt_tm
  ENDIF
  CALL clear(10,1)
  CALL clear(11,1)
  CALL clear(12,1)
  CALL clear(13,1)
  CALL clear(14,1)
  CALL clear(15,1)
  CALL text(11,1,build2("Using begin date and time of: ",format(begin_dt_tm,";;Q")))
  CALL text(14,1,build2("Using end date and time of: ",format(end_dt_tm,";;Q")))
 ENDIF
 CALL echo("")
 CALL echo("Begin qualifying on Saved to Chart patient messages that have been inerrored...")
 CALL echo("")
 CALL echo("Querying for Saved to Chart patient messages sent from the physician...")
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   task_activity ta,
   clinical_event ce
  PLAN (taa
   WHERE taa.assign_person_id > 0
    AND taa.task_id > 0
    AND taa.active_ind=1)
   JOIN (ta
   WHERE ta.task_id=taa.task_id
    AND ta.msg_sender_person_id=0
    AND ta.event_id > 0
    AND ta.updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
    AND ta.active_ind=1)
   JOIN (ce
   WHERE ce.event_id=ta.event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (inerror_cd, inerror_noview_cd, inerror_nomut_cd))
  ORDER BY ta.task_id
  HEAD ta.task_id
   task_cnt += 1
   IF (task_cnt > size(tasks->task,5))
    stat = alterlist(tasks->task,((task_cnt+ task_list_buffer) - 1))
   ENDIF
   tasks->task[task_cnt].task_id = ta.task_id
  FOOT REPORT
   stat = alterlist(tasks->task,task_cnt)
  WITH nocounter
 ;end select
 CALL echo("Query completed.")
 CALL echo(build2("Total messages found: ",task_cnt))
 CALL echo("")
 CALL echo("Querying for Saved to Chart patient messages sent from the patient...")
 SELECT INTO "nl:"
  FROM task_activity ta,
   task_activity_assignment taa,
   clinical_event ce
  PLAN (ta
   WHERE ta.msg_sender_person_id > 0
    AND ta.task_id > 0
    AND ta.event_id > 0
    AND ta.updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
    AND ta.active_ind=1)
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND taa.assign_person_id=0
    AND taa.active_ind=1)
   JOIN (ce
   WHERE ce.event_id=ta.event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (inerror_cd, inerror_noview_cd, inerror_nomut_cd))
  ORDER BY ta.task_id
  HEAD ta.task_id
   task_cnt += 1
   IF (task_cnt > size(tasks->task,5))
    stat = alterlist(tasks->task,((task_cnt+ task_list_buffer) - 1))
   ENDIF
   tasks->task[task_cnt].task_id = ta.task_id
  FOOT REPORT
   stat = alterlist(tasks->task,task_cnt)
  WITH nocounter
 ;end select
 CALL echo("Query completed.")
 CALL echo(build2("Total messages found: ",task_cnt))
 IF (task_cnt=0)
  CALL echo("")
  CALL echo("No affected messages found.")
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 CALL echo("")
 CALL echo("Exploding message tasks...")
 SELECT INTO "nl:"
  FROM (dummyt dt  WITH seq = value(size(tasks->task,5))),
   task_activity ta,
   task_activity_assignment taa,
   person patient,
   prsnl personnel,
   email_info ei
  PLAN (dt)
   JOIN (ta
   WHERE (ta.task_id=tasks->task[dt.seq].task_id))
   JOIN (taa
   WHERE taa.task_id=ta.task_id)
   JOIN (patient
   WHERE ((taa.assign_person_id > 0
    AND patient.person_id=taa.assign_person_id) OR (ta.msg_sender_person_id > 0
    AND patient.person_id=ta.msg_sender_person_id)) )
   JOIN (personnel
   WHERE ((taa.assign_prsnl_id > 0
    AND personnel.person_id=taa.assign_prsnl_id) OR (ta.msg_sender_id > 0
    AND personnel.person_id=ta.msg_sender_id)) )
   JOIN (ei
   WHERE (taa.assign_email_info_id= Outerjoin(ei.email_info_id)) )
  ORDER BY ta.task_id, ta.updt_dt_tm
  DETAIL
   message_cnt += 1
   IF (message_cnt > size(messages->message,5))
    stat = alterlist(messages->message,((message_cnt+ message_list_buffer) - 1))
   ENDIF
   messages->message[message_cnt].task_id = ta.task_id, messages->message[message_cnt].event_id = ta
   .event_id, messages->message[message_cnt].updt_dt_tm = cnvtdatetime(ta.updt_dt_tm),
   messages->message[message_cnt].assigned_patient_id = patient.person_id, messages->message[
   message_cnt].patient_name = patient.name_full_formatted, messages->message[message_cnt].
   assigned_prsnl_id = personnel.person_id,
   messages->message[message_cnt].personnel_name = personnel.name_full_formatted, messages->message[
   message_cnt].assigned_pool_id = taa.assign_prsnl_group_id, messages->message[message_cnt].
   external_email = ei.email_addr,
   messages->message[message_cnt].subject_txt = ta.msg_subject
  FOOT REPORT
   stat = alterlist(messages->message,message_cnt)
  WITH nocounter
 ;end select
 IF (curbatch=0)
  SELECT
   task_id = ta.task_id, event_id = ta.event_id, updt_dt_tm = ta.updt_dt_tm,
   person_id = messages->message[dt.seq].assigned_patient_id, patient_name = messages->message[dt.seq
   ].patient_name"####################", prsnl_id = messages->message[dt.seq].assigned_prsnl_id,
   prsnl_name = messages->message[dt.seq].personnel_name"####################", pool_id = messages->
   message[dt.seq].assigned_pool_id, external_email = messages->message[dt.seq].external_email
   "##################################",
   subject = messages->message[dt.seq].subject_txt
   "##########################################################################################"
   FROM (dummyt dt  WITH seq = value(size(messages->message,5))),
    task_activity ta,
    task_activity_assignment taa
   PLAN (dt)
    JOIN (ta
    WHERE (ta.task_id=messages->message[dt.seq].task_id))
    JOIN (taa
    WHERE taa.task_id=ta.task_id)
   ORDER BY ta.task_id, ta.updt_dt_tm
   WITH nocounter, separator = "|", format(date,";;Q")
  ;end select
  CALL echo("Explosion completed.")
  CALL echo(build2("Total messages to inactivate: ",message_cnt))
  CALL clear(13,1)
  CALL clear(14,1)
  CALL text(13,1,"If you wish to inactivate the inerrored patient messages, please type YES or Y.")
  CALL accept(14,1,"P(3);CU")
  IF (((curaccept="YES") OR (curaccept="Y")) )
   CALL clear(13,1)
   CALL clear(14,1)
   CALL text(13,1,"Inactivating all inerrored patient messages...")
   WHILE (prsnl_id <= 0)
     CALL clear(15,1)
     CALL clear(16,1)
     CALL text(15,1,"Please enter the PRSNL.USERNAME of the user performing this update.")
     CALL accept(16,1,"P(50);CU")
     SELECT INTO "nl:"
      FROM prsnl u
      WHERE u.username=curaccept
      HEAD REPORT
       prsnl_id = u.person_id
      WITH nocounter
     ;end select
     IF (prsnl_id <= 0)
      CALL clear(14,1)
      CALL text(14,1,build2("Unable to match USERNAME(",curaccept,") not found. Please retry."))
     ENDIF
   ENDWHILE
  ENDIF
 ENDIF
 IF (prsnl_id > 0)
  CALL echo(build2("Performing updates as user: ",prsnl_id))
  DECLARE total_batches = i4 WITH protect, noconstant((message_cnt/ batch_size))
  IF (mod(message_cnt,batch_size) > 0)
   SET total_batches += 1
  ENDIF
  DECLARE start_message_index = i4 WITH protect, noconstant(0)
  DECLARE end_message_index = i4 WITH protect, noconstant(0)
  DECLARE index = i4
  FOR (batch_index = 1 TO total_batches)
    SET start_message_index = (((batch_index - 1) * batch_size)+ 1)
    SET end_message_index = (batch_index * batch_size)
    IF (end_message_index > message_cnt)
     SET end_message_index = message_cnt
    ENDIF
    CALL echo(build2("Inactivating batch <",batch_index,"> of <",total_batches,">"))
    CALL echo(build2("Message index range <",start_message_index,"> to <",end_message_index,">"))
    UPDATE  FROM task_activity_assignment
     SET active_ind = 0, task_status_cd = task_status_in_error_cd, updt_applctx = 0.0,
      updt_id = prsnl_id, updt_task = 0, updt_dt_tm = sysdate,
      updt_cnt = (updt_cnt+ 1)
     WHERE expand(index,start_message_index,end_message_index,task_id,messages->message[index].
      task_id)
     WITH nocounter
    ;end update
    UPDATE  FROM task_activity
     SET active_ind = 0, task_status_cd = task_status_in_error_cd, updt_applctx = 0.0,
      updt_id = prsnl_id, updt_task = 0, updt_dt_tm = sysdate,
      updt_cnt = (updt_cnt+ 1)
     WHERE expand(index,start_message_index,end_message_index,task_id,messages->message[index].
      task_id)
     WITH nocounter
    ;end update
  ENDFOR
  IF (curbatch=0)
   CALL clear(19,1)
   CALL clear(20,1)
   CALL text(19,1,"If you wish to finalize these changes, please type YES or Y.")
   CALL accept(20,1,"P(3);CU")
   IF (((curaccept="YES") OR (curaccept="Y")) )
    COMMIT
    CALL clear(19,1)
    CALL clear(20,1)
    CALL text(20,1,"All inerrored patient messages have been inactivated.")
   ELSE
    ROLLBACK
    CALL clear(19,1)
    CALL clear(20,1)
    CALL text(20,1,"Rolling back changes...")
   ENDIF
  ENDIF
  COMMIT
  SET reply->status_data.status = "S"
  GO TO exit_script
 ELSE
  CALL echo("Ignoring all inerrored patient messages.")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
#exit_script
 CALL echo("")
 FREE RECORD tasks
 FREE RECORD messages
 SET message = information
END GO
