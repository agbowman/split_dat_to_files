CREATE PROGRAM bhs_athn_dyndoc_lock
 FREE RECORD result
 RECORD result(
   1 break_lock_ind = i2
   1 unlock_data[*]
     2 dd_session_id = f8
   1 lock_user_id = f8
   1 lock_user = vc
   1 lock_dt_tm = dq8
   1 dd_contribution_id = f8
   1 dd_session_id = f8
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
 DECLARE checksessionlock(null) = i4
 DECLARE callopendocument(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE contribsize = i4 WITH protect, noconstant(0)
 SET result->status_data.status = "F"
 SET result->break_lock_ind =  $4
 IF (( $2 <= 0.0))
  CALL echo("INVALID EVENT ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = checksessionlock(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = callopendocument(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF (size(result->unlock_data,5) > 0)
  SET stat = callopendocument(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
 DECLARE v3 = vc WITH protect, noconstant("")
 DECLARE v4 = vc WITH protect, noconstant("")
 DECLARE v5 = vc WITH protect, noconstant("")
 DECLARE v6 = vc WITH protect, noconstant("")
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
    v1, row + 1, v2 = build("<LockUserId>",cnvtint(result->lock_user_id),"</LockUserId>"),
    col + 1, v2, row + 1,
    v3 = build("<LockUser>",trim(replace(replace(replace(replace(replace(result->lock_user,"&",
           "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</LockUser>"),
    col + 1, v3,
    row + 1, v4 = build("<LockDate>",format(result->lock_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
     "</LockDate>"), col + 1,
    v4, row + 1, v5 = build("<ContributionId>",cnvtint(result->dd_contribution_id),
     "</ContributionId>"),
    col + 1, v5, row + 1,
    v6 = build("<SessionId>",cnvtint(result->dd_session_id),"</SessionId>"), col + 1, v6,
    row + 1, col + 1, "</ReplyMessage>",
    row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req969503
 FREE RECORD rep969503
 SUBROUTINE callopendocument(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(3202004)
   DECLARE requestid = i4 WITH constant(969503)
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
   SET stat = initrec(req969503)
   SET stat = initrec(rep969503)
   SET req969503->mdoc_event_id =  $2
   IF (size(result->unlock_data,5) > 0)
    SET stat = alterlist(req969503->sessions,size(result->unlock_data,5))
    FOR (idx = 1 TO size(req969503->sessions,5))
      SET req969503->sessions[idx].dd_session_id = result->unlock_data[idx].dd_session_id
    ENDFOR
   ENDIF
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
   SET contribsize = size(rep969503->document.contributions,5)
   IF ((rep969503->status_data.status="S"))
    IF (contribsize > 0)
     IF (( $5=1))
      SET result->dd_contribution_id = rep969503->document.contributions[1].contribution_id
      SET result->dd_session_id = rep969503->document.contributions[1].dd_session_id
     ELSE
      SET result->dd_contribution_id = rep969503->document.contributions[contribsize].contribution_id
      SET result->dd_session_id = rep969503->document.contributions[contribsize].dd_session_id
     ENDIF
    ENDIF
    RETURN(success)
   ELSEIF ((rep969503->status_data.status="F")
    AND (result->break_lock_ind=1))
    SET stat = alterlist(result->unlock_data,contribsize)
    FOR (idx = 1 TO contribsize)
      SET result->unlock_data[idx].dd_session_id = rep969503->document.contributions[idx].
      dd_session_id
    ENDFOR
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE checksessionlock(null)
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
    HEAD dc.mdoc_event_id
     result->lock_user_id = p.person_id, result->lock_user = p.name_full_formatted, result->
     lock_dt_tm = ds.session_dt_tm
    WITH nocounter
   ;end select
   IF ((result->lock_user_id > 0))
    IF ((result->break_lock_ind=0))
     RETURN(fail)
    ELSEIF ((result->lock_user_id !=  $3)
     AND (result->break_lock_ind=1))
     CALL echo("BREAK LOCK UNSUCCESSFUL...PERSONNEL_ID DOES NOT MATCH LOCK_USER_ID")
     RETURN(fail)
    ENDIF
   ENDIF
   RETURN(success)
 END ;Subroutine
END GO
