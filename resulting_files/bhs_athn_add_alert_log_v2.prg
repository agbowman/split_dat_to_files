CREATE PROGRAM bhs_athn_add_alert_log_v2
 FREE RECORD result
 RECORD result(
   1 freetext = vc
   1 alert_text_flag = i2
   1 alert_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE calladdlogevent(null) = i2
 DECLARE getmoduledetails(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE alert_text_flag_every_time = i2 WITH protect, constant(1)
 DECLARE alert_text_flag_only_overrides = i2 WITH protect, constant(2)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $4 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (size(trim( $5,3)) <= 0)
  CALL echo("INVALID MODULE NAME PARAMETER...EXITING")
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
 IF (size(trim( $7,3)) > 0)
  SET req_format_str->param =  $7
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->freetext = rep_format_str->param
 ENDIF
 IF (size(trim( $11,3)) > 0)
  SET req_format_str->param =  $11
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->alert_text = rep_format_str->param
 ENDIF
 SET stat = getmoduledetails(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = calladdlogevent(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
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
 FREE RECORD req3072005
 FREE RECORD rep3072005
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 SUBROUTINE getmoduledetails(null)
   DECLARE stor_data = vc WITH protect, noconstant("")
   DECLARE module_name = vc WITH protect, noconstant("")
   FREE RECORD ekmrep
   RECORD ekmrep(
     1 module_name = c30
     1 version = c10
     1 num_storage = i4
     1 eks_release = c10
     1 active_flag = c1
     1 updt_dt_tm = vc
     1 maint_title = vc
     1 maint_filename = c30
     1 maint_version = c10
     1 maint_institution = vc
     1 maint_author = vc
     1 maint_specialist = vc
     1 maint_dt_tm = dq8
     1 maint_dur_begin_dt_tm = dq8
     1 maint_dur_end_dt_tm = dq8
     1 maint_validation = c12
     1 know_type = c20
     1 know_priority = i4
     1 know_urgency = i4
     1 current_version = c10
     1 current_maint_version = c10
     1 update_user = vc
     1 update_str = vc
     1 stor[*]
       2 data_type = i4
       2 data_seq = i4
       2 ekm_info = vc
       2 ekm_info_blob = gvc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
     1 last_modified = dq8
     1 optimize_flag = i2
     1 optimized_ind = i2
     1 reconcile_flag = i2
     1 reconcile_dt_tm = dq8
   ) WITH persistscript
   SET pos = findstring("!", $5)
   IF (pos > 0
    AND pos < size( $5))
    SET module_name = substring((pos+ 1),(size( $5) - pos), $5)
   ELSE
    SET module_name =  $5
   ENDIF
   CALL echo(build("MODULE_NAME:",module_name))
   EXECUTE eks_module_search "MINE", module_name, "*" WITH replace("EKMREPLY","EKMREP")
   FOR (idx = 1 TO size(ekmrep->stor,5))
     SET stor_data = concat(stor_data,ekmrep->stor[idx].ekm_info)
   ENDFOR
   SET stor_data = cnvtupper(stor_data)
   CALL echo(build("STOR_DATA:",stor_data))
   IF (findstring("SAVE ALERT TEXT EVERY TIME",stor_data) > 0)
    SET result->alert_text_flag = alert_text_flag_every_time
   ELSEIF (findstring("ONLY SAVE ALERT TEXT IF OVERRIDE IS USED",stor_data) > 0)
    SET result->alert_text_flag = alert_text_flag_only_overrides
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE calladdlogevent(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(3072000)
   DECLARE requestid = i4 WITH protect, constant(3072005)
   DECLARE override_ind = i4 WITH protect, noconstant(0)
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
   SET i_request->prsnl_id =  $4
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   FREE RECORD req3072005
   RECORD req3072005(
     1 req[*]
       2 dlg_name = vc
       2 dlg_prsnl_id = f8
       2 encntr_id = f8
       2 person_id = f8
       2 alert_text = vc
       2 override_default_ind = i2
       2 override_reason_text = vc
       2 override_reason_cd = f8
       2 trigger_catalog_id = f8
       2 trigger_entity_name = vc
       2 trigger_order_id = f8
       2 answers[*]
         3 answer_name = vc
       2 actions[*]
         3 action_name = vc
         3 parent_entity_name = vc
         3 parent_entity_id = f8
       2 event_attr[*]
         3 attr_name = vc
         3 attr_value = vc
         3 attr_id = f8
       2 modify_dlg_name = vc
       2 action_flag = i2
   ) WITH protect
   FREE RECORD rep3072005
   RECORD rep3072005(
     1 status_data
       2 status = c1
       2 status_value = i4
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET stat = alterlist(req3072005->req,1)
   SET req3072005->req[1].dlg_name =  $5
   SET req3072005->req[1].dlg_prsnl_id =  $4
   SET req3072005->req[1].encntr_id =  $3
   SET req3072005->req[1].person_id =  $2
   SET req3072005->req[1].trigger_catalog_id =  $8
   SET req3072005->req[1].trigger_entity_name = "ORDER_CATALOG"
   SET req3072005->req[1].trigger_order_id =  $9
   IF (( $6 > 0.0))
    SET req3072005->req[1].override_reason_cd =  $6
    SET req3072005->req[1].override_default_ind = 1
    SET override_ind = 1
   ENDIF
   IF (size(trim(result->freetext,3)) > 0)
    SET req3072005->req[1].override_reason_text = result->freetext
    SET override_ind = 1
   ENDIF
   IF (size(trim(result->alert_text,3)) > 0
    AND (((result->alert_text_flag=alert_text_flag_every_time)) OR ((result->alert_text_flag=
   alert_text_flag_only_overrides)
    AND override_ind=1)) )
    SET req3072005->req[1].alert_text = result->alert_text
   ENDIF
   SET stat = alterlist(req3072005->req[1].actions,1)
   SET req3072005->req[1].modify_dlg_name =  $5
   SET req3072005->req[1].action_flag =  $10
   CALL echorecord(req3072005)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req3072005,
    "REC",rep3072005,1)
   CALL echorecord(rep3072005)
   IF ((rep3072005->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
