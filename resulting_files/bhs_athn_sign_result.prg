CREATE PROGRAM bhs_athn_sign_result
 FREE RECORD result
 RECORD result(
   1 action_comment = vc
   1 person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req1000056
 RECORD req1000056(
   1 req[*]
     2 ensure_type = i2
     2 version_dt_tm = dq8
     2 version_dt_tm_ind = i2
     2 event_prsnl
       3 event_prsnl_id = f8
       3 person_id = f8
       3 event_id = f8
       3 action_type_cd = f8
       3 request_dt_tm = dq8
       3 request_dt_tm_ind = i2
       3 request_prsnl_id = f8
       3 request_prsnl_ft = vc
       3 request_comment = vc
       3 action_dt_tm = dq8
       3 action_dt_tm_ind = i2
       3 action_prsnl_id = f8
       3 action_prsnl_ft = vc
       3 proxy_prsnl_id = f8
       3 proxy_prsnl_ft = vc
       3 action_status_cd = f8
       3 action_comment = vc
       3 change_since_action_flag = i2
       3 change_since_action_flag_ind = i2
       3 action_prsnl_pin = vc
       3 defeat_succn_ind = i2
       3 ce_event_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 long_text_id = f8
       3 linked_event_id = f8
       3 request_tz = i4
       3 action_tz = i4
       3 system_comment = vc
       3 event_action_modifier_list[*]
         4 ce_event_action_modifier_id = f8
         4 event_action_modifier_id = f8
         4 event_id = f8
         4 event_prsnl_id = f8
         4 action_type_modifier_cd = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 ensure_type = i2
       3 digital_signature_ident = vc
       3 action_prsnl_group_id = f8
       3 request_prsnl_group_id = f8
       3 receiving_person_id = f8
       3 receiving_person_ft = vc
     2 ensure_type2 = i2
     2 clinsig_updt_dt_tm_flag = i2
     2 clinsig_updt_dt_tm = dq8
     2 clinsig_updt_dt_tm_ind = i2
   1 message_item
     2 message_text = vc
     2 subject = vc
     2 confidentiality = i2
     2 priority = i2
     2 due_date = dq8
     2 sender_id = f8
   1 user_id = f8
   1 result_set_links[*]
     2 ensure_type = i2
     2 event_id = f8
     2 result_set_id = f8
     2 entry_type_cd = f8
     2 relation_type_cd = f8
 ) WITH protect
 FREE RECORD rep1000056
 RECORD rep1000056(
   1 rep[*]
     2 event_prsnl_id = f8
     2 event_id = f8
     2 action_prsnl_id = f8
     2 action_type_cd = f8
     2 sb
       3 severitycd = i4
       3 statuscd = i4
       3 statustext = vc
       3 substatuslist[*]
         4 substatuscd = i4
   1 sb
     2 severitycd = i4
     2 statuscd = i4
     2 statustext = vc
     2 substatuslist[*]
       3 substatuscd = i4
 ) WITH protect
 DECLARE geteventdetails(null) = i4
 DECLARE callsignresult(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE now = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 SET result->status_data.status = "F"
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 IF (( $2 <= 0.0))
  CALL echo("INVALID EVENT ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 IF (textlen(trim( $5,3)))
  SET req_format_str->param =  $5
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->action_comment = rep_format_str->param
 ENDIF
 SET stat = geteventdetails(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = callsignresult(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
 DECLARE v3 = vc WITH protect, noconstant("")
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
 FREE RECORD i_request
 FREE RECORD i_reply
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 FREE RECORD req1000056
 FREE RECORD rep1000056
 SUBROUTINE geteventdetails(null)
  SELECT INTO "NL:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.event_id= $2)
     AND ce.valid_until_dt_tm >= cnvtdatetime(now)
     AND ce.valid_from_dt_tm <= cnvtdatetime(now))
   ORDER BY ce.valid_from_dt_tm DESC
   HEAD ce.event_id
    result->person_id = ce.person_id
   WITH nocounter, time = 30
  ;end select
  RETURN(success)
 END ;Subroutine
 SUBROUTINE callsignresult(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(600108)
   DECLARE requestid = i4 WITH constant(1000056)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE errcode = i4 WITH protect, noconstant(0)
   DECLARE c_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
   DECLARE c_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
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
   SET stat = alterlist(req1000056->req,1)
   SET req1000056->req[1].ensure_type = 2
   SET req1000056->req[1].event_prsnl.person_id = result->person_id
   SET req1000056->req[1].event_prsnl.event_id =  $2
   SET req1000056->req[1].event_prsnl.action_type_cd = c_sign_cd
   SET req1000056->req[1].event_prsnl.request_dt_tm_ind = 1
   SET req1000056->req[1].event_prsnl.action_dt_tm = cnvtdatetime( $4)
   SET req1000056->req[1].event_prsnl.action_tz = app_tz
   SET req1000056->req[1].event_prsnl.action_prsnl_id =  $3
   SET req1000056->req[1].event_prsnl.action_status_cd = c_completed_cd
   SET req1000056->req[1].event_prsnl.action_comment = result->action_comment
   SET req1000056->req[1].event_prsnl.defeat_succn_ind = 1
   SET req1000056->req[1].event_prsnl.valid_from_dt_tm_ind = 1
   SET req1000056->req[1].event_prsnl.valid_until_dt_tm_ind = 1
   CALL echorecord(req1000056)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req1000056,
    "REC",rep1000056,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep1000056)
   IF (size(rep1000056->rep,5)=1
    AND (rep1000056->rep[1].statuscd=0.0))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
