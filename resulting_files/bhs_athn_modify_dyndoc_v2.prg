CREATE PROGRAM bhs_athn_modify_dyndoc_v2
 FREE RECORD result
 RECORD result(
   1 subject = vc
   1 message = vc
   1 html_text = vc
   1 dd_contribution_id = f8
   1 dd_session_id = f8
   1 performed_dt_tm = dq8
   1 message_seq = i4
   1 message_total = i4
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
   1 segment_file_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req3011001
 RECORD req3011001(
   1 module_dir = vc
   1 module_name = vc
   1 basblob = i2
 ) WITH protect
 FREE RECORD rep3011001
 RECORD rep3011001(
   1 info_line[*]
     2 new_line = vc
   1 data_blob = gvc
   1 data_blob_size = i4
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
 DECLARE getunmodifieddetails(null) = i4
 DECLARE formatparameters(null) = i4
 DECLARE concatenatemessagesegments(null) = i4
 DECLARE simulatelogin(null) = i4
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
 SET result->message_seq =  $6
 SET result->message_total =  $7
 SET result->performed_dt_tm = cnvtdatetime( $4)
 CALL echo(build("PERFORMED_DT_TM: ",format(result->performed_dt_tm,";;Q")))
 IF (( $2 <= 0.0))
  CALL echo("INVALID EVENT ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $11 <= 0.0))
  CALL echo("INVALID CONTRIBUTION ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $12 <= 0.0))
  CALL echo("INVALID SESSION ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = checksessionlock(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = formatparameters(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = getunmodifieddetails(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = concatenatemessagesegments(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF (size(trim(result->html_text,3)) > 0)
  SET stat = simulatelogin(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
  SET stat = callopendocument(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
  SET stat = callsavedocument(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
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
    v1, row + 1, v2 = build("<SegmentFileName>",trim(replace(replace(replace(replace(replace(result->
           segment_file_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
       0),3),"</SegmentFileName>"),
    col + 1, v2, row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req3011001
 FREE RECORD rep3011001
 FREE RECORD req969502
 FREE RECORD rep969502
 FREE RECORD req969503
 FREE RECORD rep969503
 FREE RECORD i_request
 FREE RECORD i_reply
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 FREE RECORD req_decode_str
 FREE RECORD rep_decode_str
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
   SET req969502->action_tz = app_tz
   SET req969502->author_id = rep969503->document.attribute.author_id
   SET req969502->encounter_id = result->encntr_id
   SET req969502->event_cd = result->event_cd
   SET req969502->patient_id = result->person_id
   SET req969502->mdoc_event_id =  $2
   SET req969502->current_doc_status_cd = result->doc_status_cd
   SET req969502->service_dt_tm = rep969503->document.attribute.service_dt_tm
   SET req969502->service_tz = rep969503->document.attribute.service_tz
   SET req969502->title_text = result->subject
   SET req969502->unlock_flag = 1
   SET req969502->pat_prsnl_reltn_cd = result->encntr_prsnl_r_cd
   SET itemcnt = size(rep969503->document.contributions,5)
   SET stat = alterlist(req969502->contributions,itemcnt)
   FOR (idx = 1 TO itemcnt)
     SET req969502->contributions[idx].doc_event_id = rep969503->document.contributions[idx].
     attribute.doc_event_id
     SET req969502->contributions[idx].event_cd = rep969503->document.contributions[idx].attribute.
     event_cd
     SET req969502->contributions[idx].dd_contribution_id = result->contributions[idx].
     dd_contribution_id
     SET req969502->contributions[idx].dd_session_id = result->contributions[idx].dd_session_id
     IF ((req969502->contributions[idx].dd_contribution_id= $11))
      SET req969502->contributions[1].author_id =  $3
      SET req969502->contributions[1].html_text = result->html_text
      SET req969502->contributions[1].title_text = result->subject
      SET req969502->contributions[1].ensure_type = evaluate( $10,1,1,2)
     ELSE
      SET req969502->contributions[idx].author_id = rep969503->document.contributions[idx].attribute.
      author_id
      SET req969502->contributions[idx].title_text = rep969503->document.contributions[idx].attribute
      .title_text
     ENDIF
   ENDFOR
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
 SUBROUTINE getunmodifieddetails(null)
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
     result->doc_status_cd = ce.result_status_cd
    WITH nocounter, time = 30
   ;end select
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
 SUBROUTINE formatparameters(null)
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
    SET result->subject = rep_format_str->param
   ENDIF
   FREE RECORD req_decode_str
   RECORD req_decode_str(
     1 blob = vc
     1 url_source_ind = i2
   ) WITH protect
   FREE RECORD rep_decode_str
   RECORD rep_decode_str(
     1 blob = vc
   ) WITH protect
   IF (textlen(trim( $9,3)))
    SET req_decode_str->blob =  $9
    SET req_decode_str->url_source_ind = 1
    EXECUTE bhs_athn_base64_decode  WITH replace("REQUEST","REQ_DECODE_STR"), replace("REPLY",
     "REP_DECODE_STR")
    SET result->message = rep_decode_str->blob
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE concatenatemessagesegments(null)
   DECLARE temp_file = vc WITH protect, noconstant("")
   IF ((result->message_total=1))
    SET result->html_text = result->message
   ELSEIF ((result->message_seq=result->message_total))
    FOR (idx = 1 TO (result->message_total - 1))
      SET temp_file = concat("CER_TEMP:", $8,"_",trim(cnvtstring(idx),3),".TMP")
      CALL echo(concat("READING SEGMENT #",trim(cnvtstring(idx),3)," OF ",trim(cnvtstring(result->
          message_total),3)," FROM ",
        temp_file))
      SET req3011001->module_dir = trim(temp_file,3)
      EXECUTE eks_get_source  WITH replace(request,req3011001), replace(reply,rep3011001)
      IF ((rep3011001->status_data.status="S"))
       FOR (jdx = 1 TO size(rep3011001->info_line,5))
         SET result->html_text = concat(result->html_text,rep3011001->info_line[jdx].new_line)
       ENDFOR
      ELSE
       CALL echorecord(rep3011001)
       RETURN(fail)
      ENDIF
    ENDFOR
    SET result->html_text = concat(result->html_text,result->message)
   ELSE
    SET temp_file = concat("CER_TEMP:", $8,"_",trim(cnvtstring(result->message_seq),3),".TMP")
    SELECT INTO value(temp_file)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      col 0, result->message
     WITH nocounter, maxcol = 15250
    ;end select
    CALL echo(concat("SEGMENT #",trim(cnvtstring(result->message_seq),3)," OF ",trim(cnvtstring(
        result->message_total),3)," WRITTEN TO ",
      temp_file))
    SET result->segment_file_name = temp_file
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE simulatelogin(null)
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
   RETURN(success)
 END ;Subroutine
END GO
