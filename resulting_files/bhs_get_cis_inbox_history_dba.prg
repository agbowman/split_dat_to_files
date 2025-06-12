CREATE PROGRAM bhs_get_cis_inbox_history:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, s_begin_date, s_end_date
 RECORD data(
   1 batches[*]
     2 f_log_id = f8
     2 s_msg_cnt = vc
     2 s_params = vc
     2 s_log_time = vc
     2 msgs[*]
       3 l_detail_group = i4
       3 s_cmrn = vc
       3 s_reference_id = vc
       3 s_sender_name = vc
       3 s_subject = vc
       3 s_msg_dt_tm = vc
       3 s_task_type = vc
       3 s_provider_nbr = vc
       3 s_pat_id = vc
       3 s_sender_id = vc
       3 s_cis_task_id = vc
       3 s_event_id = vc
       3 s_pool_id = vc
 ) WITH protect
 DECLARE ml_batch_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_msg_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_num1 = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_error = vc WITH protect, noconstant(" ")
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
   WHERE b.object_name="BHS_GET_CIS_INBOX_MSG"
    AND b.updt_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND b.msg="test4")
   JOIN (bd
   WHERE bd.bhs_log_id=b.bhs_log_id)
  ORDER BY b.bhs_log_id, bd.detail_group, bd.detail_seq
  HEAD b.bhs_log_id
   ml_msg_cnt = 0, ml_batch_cnt = (ml_batch_cnt+ 1)
   IF (ml_batch_cnt > size(data->batches,5))
    CALL alterlist(data->batches,(ml_batch_cnt+ 10))
   ENDIF
   data->batches[ml_batch_cnt].f_log_id = b.bhs_log_id, data->batches[ml_batch_cnt].s_log_time =
   format(bd.updt_dt_tm,"mm/dd/yyyy hh:mm:ss")
  DETAIL
   ml_num1 = 0, ml_idx1 = locateval(ml_num1,1,size(data->batches,5),b.bhs_log_id,data->batches[
    ml_num1].f_log_id), ml_num1 = 0,
   ml_idx2 = locateval(ml_num1,1,size(data->batches[ml_idx1].msgs,5),bd.detail_group,data->batches[
    ml_idx1].msgs[ml_num1].l_detail_group)
   IF (ml_idx2=0)
    ml_msg_cnt = (ml_msg_cnt+ 1),
    CALL alterlist(data->batches[ml_idx1].msgs,ml_msg_cnt), data->batches[ml_idx1].msgs[ml_msg_cnt].
    l_detail_group = bd.detail_group,
    ml_idx2 = ml_msg_cnt
   ENDIF
   CASE (bd.parent_entity_name)
    OF "OriginalMessageID":
     data->batches[ml_idx1].s_msg_cnt = trim(cnvtstring(bd.parent_entity_id),3),data->batches[ml_idx1
     ].msgs[ml_idx2].s_reference_id = bd.description,data->batches[ml_idx1].msgs[ml_idx2].s_msg_dt_tm
      = bd.msg
    OF "SenderID":
     data->batches[ml_idx1].msgs[ml_idx2].s_sender_name = bd.msg,data->batches[ml_idx1].msgs[ml_idx2]
     .s_sender_id = trim(cnvtstring(bd.parent_entity_id),3)
    OF "PatientID":
     data->batches[ml_idx1].msgs[ml_idx2].s_pat_id = trim(cnvtstring(bd.parent_entity_id),3),data->
     batches[ml_idx1].msgs[ml_idx2].s_cmrn = bd.msg
    OF "EventID":
     data->batches[ml_idx1].msgs[ml_idx2].s_event_id = trim(cnvtstring(bd.parent_entity_id),3),data->
     batches[ml_idx1].msgs[ml_idx2].s_task_type = bd.msg,data->batches[ml_idx1].msgs[ml_idx2].
     s_subject = bd.description
    OF "CisTaskID":
     data->batches[ml_idx1].s_params = bd.description,data->batches[ml_idx1].msgs[ml_idx2].
     s_cis_task_id = trim(cnvtstring(bd.parent_entity_id),3)
    OF "PoolID":
     data->batches[ml_idx1].msgs[ml_idx2].s_pool_id = trim(cnvtstring(bd.parent_entity_id),3),data->
     batches[ml_idx1].msgs[ml_idx2].s_provider_nbr = bd.description
   ENDCASE
  FOOT REPORT
   CALL alterlist(data->batches,ml_batch_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO value( $OUTDEV)
  executiontime = substring(0,40,data->batches[d1.seq].s_log_time), msgcnt = data->batches[d1.seq].
  s_msg_cnt, parameters = data->batches[d1.seq].s_params,
  originalmessageid = substring(0,40,data->batches[d1.seq].msgs[d2.seq].s_reference_id), senderid =
  substring(0,40,data->batches[d1.seq].msgs[d2.seq].s_sender_id), sendername = substring(0,28,data->
   batches[d1.seq].msgs[d2.seq].s_sender_name),
  msgtype = substring(0,40,data->batches[d1.seq].msgs[d2.seq].s_task_type), patientid = substring(0,
   20,data->batches[d1.seq].msgs[d2.seq].s_pat_id), patientcmrn = substring(0,20,data->batches[d1.seq
   ].msgs[d2.seq].s_cmrn),
  sendtime = substring(0,20,data->batches[d1.seq].msgs[d2.seq].s_msg_dt_tm), subject = substring(0,
   107,data->batches[d1.seq].msgs[d2.seq].s_subject), eventid = substring(0,40,data->batches[d1.seq].
   msgs[d2.seq].s_event_id),
  cistaskid = substring(0,40,data->batches[d1.seq].msgs[d2.seq].s_cis_task_id), poolid = substring(0,
   40,data->batches[d1.seq].msgs[d2.seq].s_pool_id), providernumber = substring(0,40,data->batches[d1
   .seq].msgs[d2.seq].s_provider_nbr)
  FROM (dummyt d1  WITH seq = size(data->batches,5)),
   dummyt d2
  PLAN (d1
   WHERE maxrec(d2,size(data->batches[d1.seq].msgs,5)))
   JOIN (d2)
  ORDER BY executiontime
  HEAD REPORT
   line_d = fillstring(131,"="), line_s = fillstring(131,"-"), col 0,
   curprog,
   CALL center("*** CIS to PVIX Message History ***",0,131), col 104,
   "Report Date: ", curdate"MM/DD/YY;;D", " ",
   curtime"HH:MM;;M", row + 1, line_d,
   row + 1
  HEAD d1.seq
   IF (row >= 48)
    BREAK
   ENDIF
   row + 1, line_s, row + 1,
   col 0,
   CALL print(concat("BATCH: ",substring(0,3,trim(cnvtstring(d1.seq))))), col 11,
   CALL print(concat("TOTAL MESSAGES: ",msgcnt)), col 31,
   CALL print(concat("TIME EXECUTED: ",executiontime)),
   col 66,
   CALL print(concat("PARAMS: ",parameters)), row + 1,
   line_s
  HEAD d2.seq
   IF (row >= 53)
    BREAK
   ENDIF
   row + 2, col 5,
   CALL print(concat("MSG: ",trim(cnvtstring(d2.seq),3))),
   col 15,
   CALL print(concat("Subject: ",subject)), row + 1,
   col 15,
   CALL print(concat("OriginalMessageID : ",originalmessageid)), col 56,
   CALL print(concat("Sender    : ",sendername)), col 97,
   CALL print(concat("SendTime    : ",sendtime)),
   row + 1, col 15,
   CALL print(concat("MsgType           : ",msgtype)),
   col 56,
   CALL print(concat("SenderID  : ",senderid)), col 97,
   CALL print(concat("PatientID   : ",patientid)), row + 1, col 15,
   CALL print(concat("EventID           : ",eventid)), col 56,
   CALL print(concat("CisTaskID : ",cistaskid)),
   col 97,
   CALL print(concat("PatientCMRN : ",patientcmrn)), row + 1,
   col 15,
   CALL print(concat("ProviderNumber    : ",providernumber)), col 56,
   CALL print(concat("PoolID    : ",poolid)), row + 1
   IF (d1.seq=size(data->batches,5)
    AND d2.seq=size(data->batches[d1.seq].msgs,5))
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
 CALL echorecord(data)
END GO
