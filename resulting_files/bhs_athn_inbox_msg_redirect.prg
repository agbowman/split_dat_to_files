CREATE PROGRAM bhs_athn_inbox_msg_redirect
 FREE RECORD result
 RECORD result(
   1 header_text = gvc
   1 to_prsnl[*]
     2 prsnl_id = f8
     2 name = vc
   1 performed_dt_tm = dq8
   1 performed_prsnl_name = vc
   1 performed_prsnl_name_first = vc
   1 performed_prsnl_name_last = vc
   1 task_updt_cnt = i4
   1 taa_updt_cnt = i4
   1 task_type_cd = f8
   1 from_line = vc
   1 to_line = vc
   1 sent_line = vc
   1 due_line = vc
   1 task_uid = vc
   1 reminder_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req967590
 RECORD req967590(
   1 redirect_list[*]
     2 header_text = gvc
     2 notification_uid = vc
     2 msg_text = gvc
     2 reminder_dt_tm = dq8
     2 due_dt_tm = dq8
     2 assign_prsnl_list[*]
       3 assign_prsnl_id = f8
     2 assign_pool_list[*]
       3 assign_pool_id = f8
       3 assign_prsnl_id = f8
     2 version = i4
     2 owner_version = i4
 ) WITH protect
 FREE RECORD rep967590
 RECORD rep967590(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req967511
 RECORD req967511(
   1 notification_list[*]
     2 notification_uid = vc
     2 available_actions_input
       3 prsnl_id = f8
     2 sent_notification_id = f8
     2 task_info
       3 task_id = f8
       3 owner_personnel_id = f8
   1 load_person_name = i2
   1 load_sender_name = i2
   1 load_assign_name = i2
   1 load_available_actions = i2
   1 load_can_change_pt_context = i2
   1 load_result_set_details = i2
 ) WITH protect
 FREE RECORD rep967511
 RECORD rep967511(
   1 get_list_item[*]
     2 notification_uid = vc
     2 person_id = f8
     2 encntr_id = f8
     2 priority_cd = f8
     2 priority_cd_disp = c40
     2 priority_cd_mean = c12
     2 status_cd = f8
     2 status_cd_disp = c40
     2 status_cd_mean = c12
     2 comments = vc
     2 subject_cd = f8
     2 subject_cd_disp = c40
     2 subject_cd_mean = c12
     2 subject = vc
     2 sender_prsnl_id = f8
     2 sender_person_id = f8
     2 sender_pool_id = f8
     2 create_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 notification_type_cd = f8
     2 notification_type_cd_disp = c40
     2 notification_type_cd_mean = c12
     2 order_id = f8
     2 event_id = f8
     2 event_class_cd = f8
     2 event_class_cd_disp = c40
     2 event_class_cd_mean = c12
     2 message_id = f8
     2 assign_prsnl_list[*]
       3 assign_prsnl_id = f8
       3 assign_prsnl_name = vc
       3 cc_ind = i2
     2 assign_pool_list[*]
       3 assign_pool_id = f8
       3 assign_prsnl_id = f8
       3 assign_pool_name = vc
       3 assign_prsnl_name = vc
       3 cc_ind = i2
     2 assign_person_list[*]
       3 person_id = f8
       3 person_name = vc
       3 cc_ind = i2
     2 text = gvc
     2 reminder_dt_tm = dq8
     2 due_dt_tm = dq8
     2 caller_name = vc
     2 caller_phone_number = vc
     2 notify_info[*]
       3 notify_prsnl_id = f8
       3 notify_priority_cd = f8
       3 notify_status_list[*]
         4 notify_status_cd = f8
         4 delay[*]
           5 value = i4
           5 unit_flag = i2
       3 notify_pool_id = f8
     2 person_name = vc
     2 sender_prsnl_name = vc
     2 sender_person_name = vc
     2 sender_pool_name = vc
     2 proposed_order_list[*]
       3 proposed_order_id = f8
       3 available_actions
         4 can_accept = i2
         4 can_reject = i2
         4 can_withdraw = i2
     2 available_actions[*]
       3 can_accept = i2
       3 can_reject = i2
       3 can_withdraw = i2
       3 can_reject_and_replace = i2
       3 can_change_patient = i2
       3 can_verify_patient = i2
     2 event_cd = f8
     2 action_request_list[*]
       3 action_request_cd = f8
     2 assign_text_ind = i2
     2 owner_updt_cnt = i4
     2 pharmacy_identifier = vc
     2 rx_renewal_list[*]
       3 rx_renewal_uid = vc
     2 attachments[*]
       3 name = c255
       3 media_identifier = c255
       3 media_version = i4
     2 assign_email_list[*]
       3 email = vc
       3 cc_ind = i2
       3 display_name = vc
     2 sender_email = vc
     2 sender_email_display_name = vc
     2 previous_task_uid = vc
     2 patient_demog_id = f8
     2 can_change_pt_context = i2
     2 attachment_errors[*]
       3 attachment_description = vc
     2 result_set_id = f8
     2 result_set_details[*]
       3 event_id = f8
       3 event_cd = f8
       3 event_class_cd = f8
       3 event_title_text = vc
       3 publish_flag = i2
       3 result_status_cd = f8
       3 parent_event_id = f8
       3 parent_event_class_cd = f8
       3 relation_type_cd = f8
       3 event_set_cd = f8
       3 event_set_name = vc
     2 task_subtype_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callredirectreminder(null) = i4
 DECLARE callgetmessagedetails(null) = i4
 DECLARE buildheaderblob(null) = i4
 DECLARE formatnotedate(note_dt_tm=f8,time_ind=i2,seconds_ind=i2) = vc
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE startpos = i4 WITH protect, noconstant(0)
 DECLARE endpos = i4 WITH protect, noconstant(0)
 DECLARE param = vc WITH protect, noconstant("")
 DECLARE month_str = vc WITH protect, noconstant("")
 DECLARE day_str = vc WITH protect, noconstant("")
 DECLARE year_str = vc WITH protect, noconstant("")
 DECLARE time_str = vc WITH protect, noconstant("")
 DECLARE now = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 SET result->status_data.status = "F"
 SET result->performed_dt_tm = cnvtdatetime(curdate,curtime3)
 CALL echo(build("PERFORMED_DT_TM: ",format(result->performed_dt_tm,";;Q")))
 IF (( $2 <= 0.0))
  CALL echo("INVALID TASK ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM person p
  PLAN (p
   WHERE (p.person_id= $3)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id
  HEAD p.person_id
   result->performed_prsnl_name = p.name_full_formatted, result->performed_prsnl_name_first = p
   .name_first, result->performed_prsnl_name_last = p.name_last
  WITH nocounter, time = 30
 ;end select
 DECLARE toprsnlidparam = vc WITH protect, noconstant("")
 DECLARE toprsnlcnt = i4 WITH protect, noconstant(0)
 SET startpos = 1
 SET toprsnlidparam = trim( $4,3)
 CALL echo(build2("TOPRSNLIDPARAM IS: ",toprsnlidparam))
 WHILE (size(toprsnlidparam) > 0)
   SET endpos = (findstring(";",toprsnlidparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(toprsnlidparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,toprsnlidparam)
    CALL echo(build("PARAM:",param))
    SET toprsnlcnt = (toprsnlcnt+ 1)
    SET stat = alterlist(result->to_prsnl,toprsnlcnt)
    SET result->to_prsnl[toprsnlcnt].prsnl_id = cnvtreal(param)
   ENDIF
   SET toprsnlidparam = substring((endpos+ 2),(size(toprsnlidparam) - endpos),toprsnlidparam)
   CALL echo(build("TOPRSNLIDPARAM:",toprsnlidparam))
   CALL echo(build("SIZE(TOPRSNLIDPARAM):",size(toprsnlidparam)))
 ENDWHILE
 SELECT INTO "NL:"
  FROM task_activity ta,
   task_activity_assignment taa
  PLAN (ta
   WHERE (ta.task_id= $2))
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND (taa.assign_prsnl_id= $3)
    AND taa.active_ind=1)
  HEAD ta.task_id
   result->task_updt_cnt = ta.updt_cnt, result->taa_updt_cnt = taa.updt_cnt, result->task_type_cd =
   ta.task_type_cd
  WITH nocounter, time = 30
 ;end select
 DECLARE c_consult_msg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"CONSULT"))
 DECLARE c_reminder_msg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"REMINDER"))
 SET result->task_uid = concat("urn:cerner:mid:object.task:",trim(cnvtlower(curdomain),3),":taskId=",
  trim(replace(cnvtstring( $2),".00","",0),3),",ownerId=",
  trim(replace(cnvtstring( $3),".00","",0),3),",enum=",evaluate(result->task_type_cd,
   c_reminder_msg_cd,"-11",c_consult_msg_cd,"-10",
   "5"),",poolInd=0")
 CALL echo(build("RESULT->TASK_UID:",result->task_uid))
 SET stat = callgetmessagedetails(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = buildheaderblob(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = callredirectreminder(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, col + 1,
    "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req967590
 FREE RECORD rep967590
 FREE RECORD req967511
 FREE RECORD rep967511
 FREE RECORD i_request
 FREE RECORD i_reply
 SUBROUTINE callredirectreminder(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(967100)
   DECLARE requestid = i4 WITH constant(967590)
   DECLARE errmsg = vc WITH protect, noconstant("")
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET stat = alterlist(req967590->redirect_list,1)
   SET req967590->redirect_list[1].header_text = result->header_text
   SET req967590->redirect_list[1].notification_uid = result->task_uid
   SET req967590->redirect_list[1].reminder_dt_tm = result->reminder_dt_tm
   SET req967590->redirect_list[1].due_dt_tm = cnvtdatetime( $5)
   SET req967590->redirect_list[1].version = result->task_updt_cnt
   SET req967590->redirect_list[1].owner_version = result->taa_updt_cnt
   SET stat = alterlist(req967590->redirect_list[1].assign_prsnl_list,size(result->to_prsnl,5))
   FOR (idx = 1 TO size(result->to_prsnl,5))
     SET req967590->redirect_list[1].assign_prsnl_list[idx].assign_prsnl_id = result->to_prsnl[idx].
     prsnl_id
   ENDFOR
   CALL echorecord(req967590)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967590,
    "REC",rep967590,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967590)
   IF ((rep967590->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE callgetmessagedetails(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(967100)
   DECLARE requestid = i4 WITH constant(967511)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE c_reminders_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3406,"REMINDERS"))
   SET stat = alterlist(req967511->notification_list,1)
   SET req967511->notification_list[1].notification_uid = result->task_uid
   SET req967511->notification_list[1].available_actions_input.prsnl_id =  $3
   SET req967511->load_person_name = 1
   SET req967511->load_sender_name = 1
   SET req967511->load_assign_name = 1
   SET req967511->load_available_actions = 1
   SET req967511->load_can_change_pt_context = 1
   SET req967511->load_result_set_details = 1
   CALL echorecord(req967511)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967511,
    "REC",rep967511,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967511)
   IF ((rep967511->status_data.status="S"))
    IF (size(rep967511->get_list_item,5) > 0)
     IF ((rep967511->get_list_item[1].notification_type_cd=c_reminders_cd)
      AND size(trim( $6,3)) > 0)
      SET result->reminder_dt_tm = cnvtdatetime( $6)
     ELSE
      SET result->reminder_dt_tm = rep967511->get_list_item[1].reminder_dt_tm
     ENDIF
    ENDIF
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE buildheaderblob(null)
   SET result->from_line = concat("From: ",trim(result->performed_prsnl_name,3)," \par")
   SELECT INTO "NL:"
    FROM person p
    PLAN (p
     WHERE expand(idx,1,size(result->to_prsnl,5),p.person_id,result->to_prsnl[idx].prsnl_id)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm < sysdate
      AND p.end_effective_dt_tm > sysdate)
    ORDER BY p.person_id
    HEAD p.person_id
     pos = locateval(locidx,1,size(result->to_prsnl,5),p.person_id,result->to_prsnl[locidx].prsnl_id)
     IF (pos > 0)
      result->to_prsnl[pos].name = p.name_full_formatted
     ENDIF
    WITH nocounter, expand = 1, time = 30
   ;end select
   IF (size(result->to_prsnl,5) > 0)
    SET result->to_line = " To:"
    FOR (idx = 1 TO size(result->to_prsnl,5))
      SET result->to_line = concat(result->to_line," ",trim(result->to_prsnl[idx].name,3),";")
    ENDFOR
    SET result->to_line = concat(result->to_line,"   \par")
   ENDIF
   SET result->sent_line = concat(" Sent: ",formatnotedate(result->performed_dt_tm,1,1),
    " ! Show up: ",formatnotedate(result->performed_dt_tm,1,0)," \par")
   SET result->due_line = concat(" Due Date/Time: ",formatnotedate(cnvtdatetime( $5),1,1)," \par")
   SET result->header_text = nullterm(concat(
     "{\rtf1\ansi\ansicpg1252\uc1\deff0{\fonttbl  {\f0\fnil\fcharset0\fprq2 Arial;}  {\",
     "f1\fswiss\fcharset0\fprq2 Arial;}  {\f2\froman\fcharset2\fprq2 Symbol;}}  {\colo",
     "rtbl;\red0\green0\blue0;}  {\stylesheet{\s0\itap0\nowidctlpar\f0\fs24 [Normal];}",
     "{\*\cs10\additive Default Paragraph Font;}}  {\*\generator TX_RTF32 18.0.541.501",
     ";}  \paperw15000\paperh15840\margl1440\margt1440\margr1440\margb1440\deftab1134\",
     "widowctrl\lytexcttp\formshade  {\*\background{\shp{\*\shpinst\shpleft0\shptop0\s",
     "hpright0\shpbottom0\shpfhdr0\shpbxmargin\shpbxignore\shpbymargin\shpbyignore\shp",
     "wr0\shpwrk0\shpfblwtxt1\shplid1025{\sp{\sn shapeType}{\sv 1}}{\sp{\sn fFlipH}{\s",
     "v 0}}{\sp{\sn fFlipV}{\sv 0}}{\sp{\sn fillColor}{\sv 16777215}}{\sp{\sn fFilled}",
     "{\sv 1}}{\sp{\sn lineWidth}{\sv 0}}{\sp{\sn fLine}{\sv 0}}{\sp{\sn fBackground}{",
     "\sv 1}}{\sp{\sn fLayoutInCell}{\sv 1}}}}}\sectd  \headery720\footery720\pgwsxn15",
     "000\pghsxn15840\marglsxn1440\margtsxn1440\margrsxn1440\margbsxn1440\pgbrdropt32\",
     "pard\itap0\nowidctlpar\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx",
     "6480\tx7200\tx7920\tx8640\tx9360\tx10080\plain\f1\fs20 \par ---------------------\par ",result
     ->from_line,
     result->to_line,result->sent_line,result->due_line,"\par \par}"))
   CALL echo(build("RESULT->HEADER_TEXT:",result->header_text))
   RETURN(success)
 END ;Subroutine
 SUBROUTINE formatnotedate(note_dt_tm,time_ind,seconds_ind)
   DECLARE note_date_str = vc WITH protect, noconstant("")
   CALL echo(build("NOTE_DT_TM: ",format(note_dt_tm,";;Q")))
   SET month_str = format(note_dt_tm,"MM;;D")
   IF (substring(1,1,month_str)="0")
    SET month_str = substring(2,1,month_str)
   ENDIF
   CALL echo(build("MONTH_STR:",month_str))
   SET day_str = format(note_dt_tm,"DD;;D")
   IF (substring(1,1,day_str)="0")
    SET day_str = substring(2,1,day_str)
   ENDIF
   CALL echo(build("DAY_STR:",day_str))
   SET year_str = format(note_dt_tm,"YYYY;;D")
   CALL echo(build("YEAR_STR:",year_str))
   SET note_date_str = concat(month_str,"/",day_str,"/",year_str)
   IF (time_ind=1)
    IF (seconds_ind=1)
     SET time_str = format(note_dt_tm,"HH:MM:SS;;M")
    ELSE
     SET time_str = concat(format(note_dt_tm,"HH:MM;;M"),":00")
    ENDIF
    CALL echo(build("TIME_STR:",time_str))
    SET note_date_str = concat(note_date_str," ",time_str)
   ENDIF
   CALL echo(build("NOTE_DATE_STR:",note_date_str))
   RETURN(note_date_str)
 END ;Subroutine
END GO
