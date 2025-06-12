CREATE PROGRAM bhs_athn_dyndoc_addendum
 FREE RECORD result
 RECORD result(
   1 addendum = vc
   1 html_text = vc
   1 performed_dt_tm = dq8
   1 performed_prsnl_name_full = vc
   1 new_event_title_text = vc
   1 person_id = f8
   1 encntr_id = f8
   1 event_cd = f8
   1 prev_event_title_text = vc
   1 doc_status_cd = f8
   1 encntr_prsnl_r_cd = f8
   1 contributions[*]
     2 lock_user_id = f8
     2 lock_user = vc
     2 lock_dt_tm = dq8
     2 dd_session_id = f8
     2 dd_contribution_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req969503
 RECORD req969503(
   1 mdoc_event_id = f8
   1 sessions[*]
     2 dd_session_id = f8
   1 read_only_flag = i4
 ) WITH protect
 FREE RECORD rep969503
 RECORD rep969503(
   1 document
     2 attribute
       3 author_id = f8
       3 doc_status_cd = f8
       3 encounter_id = f8
       3 event_cd = f8
       3 mdoc_event_id = f8
       3 person_id = f8
       3 service_dt_tm = dq8
       3 service_tz = i4
       3 title_text = vc
       3 workflow_id = f8
       3 valid_from_dt_tm = dq8
     2 contributions[*]
       3 attribute
         4 author_id = f8
         4 contribution_id = f8
         4 contribution_status_cd = f8
         4 dd_session_id = f8
         4 event_cd = f8
         4 doc_event_id = f8
         4 session_user_id = f8
         4 session_dt_tm = dq8
         4 title_text = vc
         4 updt_id = f8
         4 updt_dt_tm = dq8
         4 sequence_val = vc
       3 html_text = gvc
     2 signers[*]
       3 attribute
         4 id = f8
         4 type_cd = f8
         4 action_dt = dq8
         4 action_tz = i4
         4 provider_id = f8
         4 status_cd = f8
     2 reviewers[*]
       3 attribute
         4 id = f8
         4 type_cd = f8
         4 action_dt = dq8
         4 action_tz = i4
         4 provider_id = f8
         4 status_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c50
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req969502
 RECORD req969502(
   1 action_tz = i4
   1 author_id = f8
   1 encounter_id = f8
   1 event_cd = f8
   1 patient_id = f8
   1 mdoc_event_id = f8
   1 current_doc_status_cd = f8
   1 service_dt_tm = dq8
   1 service_tz = i4
   1 title_text = vc
   1 unlock_flag = i4
   1 ppr_cd = f8
   1 wkf_workflow_id = f8
   1 contributions[*]
     2 author_id = f8
     2 dd_contribution_id = f8
     2 dd_session_id = f8
     2 doc_event_id = f8
     2 event_cd = f8
     2 html_text = gvc
     2 title_text = vc
     2 ensure_type = i4
   1 pat_prsnl_reltn_cd = f8
   1 excluded_extract_ids[*]
     2 extract_uuid = vc
     2 excluded_ids[*]
       3 content_type_mean = vc
       3 ids[*]
         4 id = f8
   1 reference_dqr = vc
   1 signers[*]
     2 provider_id = f8
     2 cancel_ind = i2
     2 comment = vc
   1 reviewers[*]
     2 provider_id = f8
     2 cancel_ind = i2
     2 comment = vc
   1 structure_section_components[*]
     2 entry_mode_mean = c12
     2 activity_json = gvc
   1 user_id = f8
 ) WITH protect
 FREE RECORD rep969502
 RECORD rep969502(
   1 mdoc_event_id = f8
   1 doc_status_cd = f8
   1 contributions[*]
     2 dd_contribution_id = f8
     2 doc_event_id = f8
   1 components[*]
     2 concept = vc
     2 event_id = f8
     2 version = i4
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c50
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callsavedocument(null) = i4
 DECLARE callopendocument(null) = i4
 DECLARE checksessionlock(null) = i4
 DECLARE geteventdetails(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
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
 ELSEIF (( $7 <= 0.0))
  CALL echo("INVALID CONTRIBUTION ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $8 <= 0.0))
  CALL echo("INVALID SESSION ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = checksessionlock(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = geteventdetails(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = callopendocument(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF (size(result->contributions,5) != size(rep969503->document.contributions,5))
  GO TO exit_script
 ENDIF
 SET stat = callsavedocument(null)
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
 FREE RECORD req969502
 FREE RECORD rep969502
 FREE RECORD req969503
 FREE RECORD rep969503
 FREE RECORD i_request
 FREE RECORD i_reply
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 SUBROUTINE callopendocument(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(3202004)
   DECLARE requestid = i4 WITH constant(969503)
   SET req969503->mdoc_event_id =  $2
   SET req969503->read_only_flag = 1
   CALL echorecord(req969503)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req969503,
    "REC",rep969503,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep969503)
   IF ((rep969503->status_data.status="F"))
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE callsavedocument(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(3202004)
   DECLARE requestid = i4 WITH constant(969502)
   DECLARE itemcnt = i4 WITH protect, noconstant(0)
   DECLARE html_text = vc WITH protect, noconstant("")
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
   SET req969502->action_tz = app_tz
   SET req969502->author_id = rep969503->document.attribute.author_id
   SET req969502->encounter_id = result->encntr_id
   SET req969502->event_cd = result->event_cd
   SET req969502->patient_id = result->person_id
   SET req969502->mdoc_event_id =  $2
   SET req969502->current_doc_status_cd = result->doc_status_cd
   SET req969502->service_dt_tm = rep969503->document.attribute.service_dt_tm
   SET req969502->service_tz = rep969503->document.attribute.service_tz
   SET req969502->title_text = result->prev_event_title_text
   SET req969502->unlock_flag = 1
   SET req969502->pat_prsnl_reltn_cd = result->encntr_prsnl_r_cd
   SET itemcnt = size(rep969503->document.contributions,5)
   SET stat = alterlist(req969502->contributions,itemcnt)
   FOR (idx = 1 TO itemcnt)
     SET req969502->contributions[idx].author_id = rep969503->document.contributions[idx].attribute.
     author_id
     SET req969502->contributions[idx].doc_event_id = rep969503->document.contributions[idx].
     attribute.doc_event_id
     SET req969502->contributions[idx].event_cd = rep969503->document.contributions[idx].attribute.
     event_cd
     SET req969502->contributions[idx].title_text = rep969503->document.contributions[idx].attribute.
     title_text
     SET req969502->contributions[idx].dd_contribution_id = result->contributions[idx].
     dd_contribution_id
     SET req969502->contributions[idx].dd_session_id = result->contributions[idx].dd_session_id
   ENDFOR
   IF (textlen(trim(result->html_text,3)))
    SET itemcnt = (itemcnt+ 1)
    SET stat = alterlist(req969502->contributions,itemcnt)
    SET req969502->contributions[itemcnt].author_id =  $3
    SET req969502->contributions[itemcnt].dd_contribution_id =  $7
    SET req969502->contributions[itemcnt].dd_session_id =  $8
    SET req969502->contributions[itemcnt].event_cd = result->event_cd
    SET req969502->contributions[itemcnt].html_text = result->html_text
    SET req969502->contributions[itemcnt].title_text = result->new_event_title_text
    SET req969502->contributions[itemcnt].ensure_type = 2
   ENDIF
   CALL echorecord(req969502)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req969502,
    "REC",rep969502,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep969502)
   IF ((rep969502->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE checksessionlock(null)
   DECLARE contribcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM dd_contribution dc,
     dd_session ds,
     person p
    PLAN (dc
     WHERE (dc.mdoc_event_id= $2))
     JOIN (ds
     WHERE ds.parent_entity_id=dc.dd_contribution_id
      AND ds.parent_entity_name="DD_CONTRIBUTION")
     JOIN (p
     WHERE p.person_id=ds.session_user_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm < sysdate
      AND p.end_effective_dt_tm > sysdate)
    ORDER BY dc.dd_contribution_id
    HEAD dc.dd_contribution_id
     contribcnt = (contribcnt+ 1), stat = alterlist(result->contributions,contribcnt), result->
     contributions[contribcnt].lock_user_id = p.person_id,
     result->contributions[contribcnt].lock_user = p.name_full_formatted, result->contributions[
     contribcnt].lock_dt_tm = ds.session_dt_tm, result->contributions[contribcnt].dd_session_id = ds
     .dd_session_id,
     result->contributions[contribcnt].dd_contribution_id = dc.dd_contribution_id
    WITH nocounter
   ;end select
   FOR (idx = 1 TO contribcnt)
     IF ((result->contributions[idx].lock_user_id !=  $3))
      RETURN(fail)
     ENDIF
   ENDFOR
   RETURN(success)
 END ;Subroutine
 SUBROUTINE geteventdetails(null)
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
    SET result->addendum = rep_format_str->param
   ENDIF
   DECLARE month_str = vc WITH protect, noconstant("")
   DECLARE day_str = vc WITH protect, noconstant("")
   DECLARE year_str = vc WITH protect, noconstant("")
   DECLARE time_str = vc WITH protect, noconstant("")
   DECLARE tz_str = vc WITH protect, noconstant("")
   DECLARE performed_date_str = vc WITH protect, noconstant("")
   SELECT INTO "NL:"
    FROM person p
    PLAN (p
     WHERE (p.person_id= $3)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm < sysdate
      AND p.end_effective_dt_tm > sysdate)
    ORDER BY p.person_id
    HEAD p.person_id
     result->performed_prsnl_name_full = p.name_full_formatted
    WITH nocounter, time = 30
   ;end select
   SET result->performed_dt_tm = cnvtdatetime( $4)
   CALL echo(build("PERFORMED_DT_TM: ",format(result->performed_dt_tm,";;Q")))
   SET month_str = format(result->performed_dt_tm,"MMMMMMMMM;;D")
   CALL echo(build("MONTH_STR:",month_str))
   SET day_str = format(result->performed_dt_tm,"DD;;D")
   CALL echo(build("DAY_STR:",day_str))
   SET year_str = format(result->performed_dt_tm,"YYYY;;D")
   CALL echo(build("YEAR_STR:",year_str))
   SET time_str = format(result->performed_dt_tm,"HH:MM:SS;;M")
   CALL echo(build("TIME_STR:",time_str))
   IF (( $6=1))
    DECLARE offset_var = i4 WITH protect, noconstant(0)
    DECLARE daylight_var = i4 WITH protect, noconstant(0)
    SET tz_str = datetimezonebyindex(curtimezoneapp,offset_var,daylight_var,7,result->performed_dt_tm
     )
    CALL echo(build("TZ_STR:",tz_str))
    SET performed_date_str = trim(concat(month_str," ",day_str,", ",year_str,
      " ",time_str," ",tz_str),3)
   ELSE
    SET performed_date_str = trim(concat(month_str," ",day_str,", ",year_str,
      " ",time_str),3)
   ENDIF
   CALL echo(build("PERFORMED_DATE_STR:",performed_date_str))
   SET result->new_event_title_text = concat("Addendum by ",result->performed_prsnl_name_full," on ",
    performed_date_str)
   CALL echo(build("NEW_EVENT_TITLE_TEXT:",result->new_event_title_text))
   SELECT INTO "NL:"
    FROM clinical_event ce
    PLAN (ce
     WHERE (ce.event_id= $2)
      AND ce.valid_until_dt_tm >= cnvtdatetime(now)
      AND ce.valid_from_dt_tm <= cnvtdatetime(now))
    ORDER BY ce.valid_from_dt_tm DESC
    HEAD ce.event_id
     result->event_cd = ce.event_cd, result->person_id = ce.person_id, result->encntr_id = ce
     .encntr_id,
     result->prev_event_title_text = ce.event_title_text, result->doc_status_cd = ce.result_status_cd
    WITH nocounter, time = 30
   ;end select
   IF (textlen(trim(result->addendum,3)))
    SET result->html_text = concat(
     '<?xml version="1.0" encoding="windows-1252" ?> <!DOCTYPE html PUBLIC "-//W3C//DT',
     'D XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> <ht',
     'ml xmlns="http://www.w3.org/1999/xhtml" xmlns:dd="DynamicDocumentation"> <head><',
     'title></title> <meta http-equiv="X-UA-Compatible" content="IE=10" /> </head> <bo',
     'dy> <div class="ddsection ddrefreshable ddinsertfreetext ddremovable" id="d991e0',
     'fc-172a-4ff1-8ff8-0c753b3374a8"> <div style="font-family: tahoma,arial; font-siz',
     'e: 9pt;"> <div class="ddfreetext ddrefreshable ddremovable" dd:btnfloatingstyle=',
     '"top-right" id="68ff702b-8927-41e8-a5ca-ecc92d1a84b2">',result->addendum,
     "</div> </div> </div>  </body> </html>")
   ENDIF
   SELECT INTO "NL:"
    FROM encntr_prsnl_reltn epr
    PLAN (epr
     WHERE (epr.encntr_id=result->encntr_id)
      AND (epr.prsnl_person_id= $3)
      AND epr.active_ind=1
      AND epr.beg_effective_dt_tm <= cnvtdatetime(now)
      AND epr.end_effective_dt_tm >= cnvtdatetime(now))
    DETAIL
     result->encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd
    WITH nocounter, time = 30
   ;end select
   RETURN(success)
 END ;Subroutine
END GO
