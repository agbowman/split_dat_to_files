CREATE PROGRAM bhs_rpt_put_cis_inbox_history:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, s_begin_date, s_end_date
 RECORD data(
   1 msgs[*]
     2 f_log_id = f8
     2 f_sender_id = f8
     2 s_log = vc
     2 s_status = vc
     2 s_log_time = vc
     2 s_recipient_id = vc
     2 s_inbox_id = vc
     2 s_inbox_type = vc
     2 s_task_id = vc
     2 s_cmrn = vc
     2 s_reference_id = vc
     2 s_sender_name = vc
     2 s_subject = vc
     2 s_msg_dt_tm = vc
     2 s_pat_id = vc
     2 s_sender_id = vc
 ) WITH protect
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime( $S_END_DATE))
 DECLARE ml_msg_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ms_error = vc WITH protect, noconstant("")
 IF (cnvtdatetime(mf_begin_dt_tm) > cnvtdatetime(mf_end_dt_tm))
  SET ms_error = "Start date must be less than end date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 366)
  SET ms_error = "Date range exceeds 1 year."
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_log b,
   bhs_log_detail bd
  PLAN (b
   WHERE b.object_name="BHS_PUT_CIS_INBOX_MSG"
    AND b.updt_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND b.msg="000")
   JOIN (bd
   WHERE bd.bhs_log_id=b.bhs_log_id)
  ORDER BY b.bhs_log_id DESC, bd.detail_group, bd.detail_seq
  HEAD b.bhs_log_id
   ml_msg_cnt = (ml_msg_cnt+ 1)
   IF (ml_msg_cnt > size(data->msgs,5))
    CALL alterlist(data->msgs,(ml_msg_cnt+ 10))
   ENDIF
   data->msgs[ml_msg_cnt].f_log_id = b.bhs_log_id, data->msgs[ml_msg_cnt].s_log_time = format(bd
    .updt_dt_tm,"mm/dd/yyyy hh:mm:ss")
  DETAIL
   ml_num = 0, ml_idx = locateval(ml_num,1,size(data->msgs,5),b.bhs_log_id,data->msgs[ml_num].
    f_log_id)
   CASE (bd.parent_entity_name)
    OF "SenderID":
     data->msgs[ml_idx].s_sender_id = trim(cnvtstring(bd.parent_entity_id),3),data->msgs[ml_idx].
     f_sender_id = bd.parent_entity_id,data->msgs[ml_idx].s_msg_dt_tm = bd.description,
     data->msgs[ml_idx].s_reference_id = bd.msg
    OF "PatientID":
     data->msgs[ml_idx].s_pat_id = trim(cnvtstring(bd.parent_entity_id),3),data->msgs[ml_idx].s_cmrn
      = bd.description
    OF "TaskID":
     data->msgs[ml_idx].s_task_id = trim(cnvtstring(bd.parent_entity_id),3),data->msgs[ml_idx].
     s_subject = bd.msg
    OF "InboxID":
     data->msgs[ml_idx].s_inbox_id = trim(cnvtstring(bd.parent_entity_id),3),data->msgs[ml_idx].
     s_recipient_id = trim(cnvtstring(bd.description),3),data->msgs[ml_idx].s_inbox_type = evaluate(
      bd.msg,"1","Individual","2","Pool",
      "")
    OF "StatusDetail":
     data->msgs[ml_idx].s_log = bd.description,data->msgs[ml_idx].s_status = bd.msg
   ENDCASE
  FOOT REPORT
   CALL alterlist(data->msgs,ml_msg_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No messages found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(data->msgs,5)),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=data->msgs[d.seq].f_sender_id))
  DETAIL
   data->msgs[d.seq].s_sender_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  executiontime = substring(0,40,data->msgs[d.seq].s_log_time), status = substring(0,40,data->msgs[d
   .seq].s_status), log = substring(0,40,data->msgs[d.seq].s_log),
  originalmessageid = substring(0,40,data->msgs[d.seq].s_reference_id), recipientid = substring(0,14,
   data->msgs[d.seq].s_recipient_id), inboxid = substring(0,14,data->msgs[d.seq].s_inbox_id),
  inboxtype = substring(0,20,data->msgs[d.seq].s_inbox_type), senderid = substring(0,40,data->msgs[d
   .seq].s_sender_id), sendername = substring(0,28,data->msgs[d.seq].s_sender_name),
  taskid = substring(0,14,data->msgs[d.seq].s_task_id), patientid = substring(0,14,data->msgs[d.seq].
   s_pat_id), patientcmrn = substring(0,14,data->msgs[d.seq].s_cmrn),
  sendtime = substring(0,20,data->msgs[d.seq].s_msg_dt_tm), subject = substring(0,107,data->msgs[d
   .seq].s_subject)
  FROM (dummyt d  WITH seq = size(data->msgs,5))
  PLAN (d)
  ORDER BY executiontime DESC
  HEAD REPORT
   line_d = fillstring(131,"="), line_s = fillstring(131,"-"), col 0,
   curprog,
   CALL center("*** Patient Portal to CIS Message History ***",0,131), col 104,
   "Report Date: ", curdate"MM/DD/YY;;D", " ",
   curtime"HH:MM;;M", row + 1, line_d,
   row + 1
  HEAD d.seq
   IF (row >= 52)
    BREAK
   ENDIF
   row + 1, line_s, row + 1,
   col 0,
   CALL print(concat("MSG: ",trim(cnvtstring(d.seq),3)," OF ",cnvtstring(size(data->msgs,5)))), col
   26,
   CALL print(concat("TIME EXECUTED: ",executiontime)), col 74,
   CALL print(concat("STATUS: ",cnvtupper(status))),
   col 105,
   CALL print(concat("SENT: ",sendtime)), row + 1,
   line_s
   IF (cnvtupper(status)="ERROR")
    row + 1,
    CALL center("-- MESSAGE FAILED TO SEND --",0,131), row + 1,
    CALL center(concat("LOG: ",cnvtupper(log)),0,131)
   ENDIF
   row + 1, col 2,
   CALL print(concat("Subject: ",subject)),
   row + 1, col 2,
   CALL print(concat("InboxID     : ",inboxid)),
   col 52,
   CALL print(concat("OriginalMessageID : ",originalmessageid)), col 102,
   CALL print(concat("TaskID      : ",taskid)), row + 1, col 2,
   CALL print(concat("RecipientID : ",recipientid)), col 52,
   CALL print(concat("Sender            : ",sendername)),
   col 102,
   CALL print(concat("PatientID   : ",patientid)), row + 1,
   col 2,
   CALL print(concat("InboxType   : ",inboxtype)), col 52,
   CALL print(concat("SenderID          : ",senderid)), col 102,
   CALL print(concat("PatientCMRN : ",patientcmrn)),
   row + 1
   IF (d.seq=size(data->msgs,5))
    row + 1, col 0, line_d,
    row + 1,
    CALL center("End of Report",0,131)
   ENDIF
  FOOT PAGE
   row 59,
   CALL center(concat("Page: ",trim(cnvtstring(curpage),3)),0,131)
  WITH nocounter, format, separator = " "
 ;end select
#exit_script
 IF (textlen(trim(ms_error,3)) != 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = ms_error, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
