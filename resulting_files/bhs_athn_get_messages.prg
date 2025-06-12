CREATE PROGRAM bhs_athn_get_messages
 FREE RECORD result
 RECORD result(
   1 message_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req3200128
 RECORD req3200128(
   1 task_id = f8
   1 prsnl_id = f8
 ) WITH protect
 FREE RECORD rep3200128
 RECORD rep3200128(
   1 person_id = f8
   1 person_name = vc
   1 encntr_id = f8
   1 prsnl[*]
     2 prsnl_id = f8
     2 prsnl_name = vc
   1 msg_sender_id = f8
   1 msg_sender_name = vc
   1 msg_status = f8
   1 msg_status_mean = vc
   1 msg_status_disp = vc
   1 msg_dt_tm = dq8
   1 msg_updt_dt_tm = dq8
   1 msg_subject = vc
   1 msg_priority = i2
   1 msg_confidential = i2
   1 event_id = f8
   1 caller_name = vc
   1 caller_phone_nbr = vc
   1 task_id = f8
   1 updt_cnt = i4
   1 text = vc
   1 owner_id = f8
   1 owner_name = vc
   1 owner_updt_cnt = i4
   1 delivery_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetmessages(null) = i4
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 SET result->status_data.status = "F"
 IF (( $3 <= 0))
  CALL echo("INVALID TASK ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callgetmessages(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v0 = vc WITH protect, noconstant("")
  DECLARE v1 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM (dummyt d  WITH seq = value(1))
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v0 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v0, row + 1
   DETAIL
    v1 = build("<MessageText>",trim(replace(replace(replace(replace(replace(result->message_text,"&",
           "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</MessageText>"
     ), col + 1, v1,
    row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req3200128
 FREE RECORD rep3200128
 SUBROUTINE callgetmessages(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(967100)
   DECLARE requestid = i4 WITH protect, constant(3200128)
   SET req3200128->prsnl_id =  $2
   SET req3200128->task_id =  $3
   CALL echorecord(req3200128)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req3200128,
    "REC",rep3200128,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep3200128)
   IF ((rep3200128->status_data.status="S"))
    SET result->message_text = rep3200128->text
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
