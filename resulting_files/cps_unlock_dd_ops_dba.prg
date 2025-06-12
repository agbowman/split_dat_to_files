CREATE PROGRAM cps_unlock_dd_ops:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD sav(
   1 req[*]
     2 author_id = f8
     2 patient_id = f8
     2 encounter_id = f8
     2 unlock_flag = i4
     2 contributions[*]
       3 dd_contribution_id = f8
       3 dd_session_id = f8
       3 ensure_type = i4
 )
 RECORD aud_request(
   1 session[*]
     2 dd_session_id = f8
     2 dd_contribution_id = f8
     2 unlock_ind = i2
     2 event_type = c12
     2 event_name = c12
     2 event_message = c255
     2 session_dt_tm = dq8
     2 mdoc_event_id = f8
     2 doc_event_id = f8
     2 event_entity_name = c30
     2 session_user_id = i4
     2 person_id = f8
     2 encntr_id = f8
 )
 DECLARE debug_state = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind,0))
  CALL echo("Debug Enabled")
  SET debug_state = 1
 ENDIF
 DECLARE errorout(opname=vc,opstatus=vc,tobjname=vc,tobjval=vc) = null WITH protect
 DECLARE debugmsg(msg=vc) = null WITH protect
 DECLARE debugmsgstr(msg=vc,str=vc) = null WITH protect
 DECLARE validateinput(null) = null WITH protect
 DECLARE selectops(null) = null WITH protect
 DECLARE unlockops(null) = null WITH protect
 DECLARE hr_look_back = i4 WITH protect, noconstant(72)
 DECLARE hr_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat_cnt = i2 WITH protect, noconstant(0)
 DECLARE dd_cnt = i4 WITH protect, noconstant(0)
 DECLARE lock_compare_time = dq8 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 CALL validateinput(0)
 CALL selectops(0)
 CALL unlockops(0)
 SUBROUTINE errorout(opname,opstatus,tobjname,tobjval)
   SET reply->status_data.status = "F"
   SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
   SET reply->status_data[stat_cnt].subeventstatus.operationname = opname
   SET reply->status_data[stat_cnt].subeventstatus.operationstatus = opstatus
   SET reply->status_data[stat_cnt].subeventstatus.targetobjectname = tobjname
   SET reply->status_data[stat_cnt].subeventstatus.targetobjectvalue = tobjval
   IF (debug_state=1)
    CALL echo(tobjval)
   ENDIF
   GO TO general_failure
 END ;Subroutine
 SUBROUTINE debugmsg(msg)
   IF (debug_state=1)
    CALL echo(msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE debugmsgstr(msg,str)
   IF (debug_state=1)
    CALL echo(build(msg,str))
   ENDIF
 END ;Subroutine
 SUBROUTINE validateinput(null)
   DECLARE pipe_pos = i2 WITH protect, noconstant(0)
   DECLARE hr_len = i4 WITH protect, noconstant(0)
   IF ( NOT (validate(request->batch_selection)))
    CALL errorout("VALIDATE","F","REQUEST","batch_selection has not been defined")
   ENDIF
   SET total_len = size(trim(request->batch_selection))
   IF (total_len=0)
    CALL errorout("PARSE","F","REQUEST","Missing the batch_selection")
   ENDIF
   SET pipe_pos = findstring("|",request->batch_selection)
   IF (pipe_pos=0)
    CALL errorout("PARSE","F","REQUEST","Could not find pipe")
   ENDIF
   CALL debugmsgstr("Pipe position= ",pipe_pos)
   SET hr_len = (total_len - pipe_pos)
   CALL debugmsgstr("Number of chars in hours pos= ",hr_len)
   FOR (x = 1 TO hr_len)
     IF ( NOT (substring((x+ pipe_pos),1,request->batch_selection) IN ("1", "2", "3", "4", "5",
     "6", "7", "8", "9", "0")))
      CALL errorout("PARSE","F","REQUEST","Invalid data in batch_selection")
     ELSE
      SET hr_cnt = (hr_cnt+ 1)
     ENDIF
   ENDFOR
   CALL debugmsgstr("hr_cnt= ",hr_cnt)
   SET hr_look_back = cnvtint(substring((pipe_pos+ 1),hr_cnt,request->batch_selection))
   CALL debugmsgstr("hr_look_back= ",hr_look_back)
   IF (hr_look_back=0)
    CALL errorout("PARSE","F","REQUEST","Missing hr_look_back")
   ELSEIF (hr_look_back < 3)
    SET hr_look_back = 3
    CALL debugmsgstr("hr_look_back < 3, setting to minimum of:",hr_look_back)
   ENDIF
   DECLARE str_hr_look_back = vc WITH noconstant(trim(cnvtstring(hr_look_back)))
   DECLARE c_hour = vc WITH constant(",H")
   SET lock_compare_time = cnvtlookbehind(build(str_hr_look_back,c_hour))
   CALL echo(concat("Look back time being used: ",format(lock_compare_time,";;q")))
 END ;Subroutine
 SUBROUTINE selectops(null)
   DECLARE last_mdoc_event_id = f8
   DECLARE contrib_cnt = i4
   SELECT INTO "NL:"
    FROM dd_session dds,
     dd_contribution ddc
    PLAN (dds
     WHERE dds.session_dt_tm < cnvtdatetime(lock_compare_time)
      AND dds.parent_entity_name="DD_CONTRIBUTION")
     JOIN (ddc
     WHERE ddc.dd_contribution_id=dds.parent_entity_id)
    ORDER BY ddc.mdoc_event_id
    HEAD dds.dd_session_id
     IF (last_mdoc_event_id != ddc.mdoc_event_id)
      CALL debugmsg("New mdoc_event_id, creating new request in list"), dd_cnt = (dd_cnt+ 1),
      last_mdoc_event_id = ddc.mdoc_event_id,
      contrib_cnt = 0
     ELSE
      CALL debugmsg("Same mdoc_event_id, adding dd_contribution")
     ENDIF
     contrib_cnt = (contrib_cnt+ 1),
     CALL debugmsgstr("DD_cnt:",dd_cnt),
     CALL debugmsgstr("contrib_cnt	:",contrib_cnt),
     CALL debugmsgstr("author_id= ",ddc.author_id),
     CALL debugmsgstr("patient_id= ",ddc.person_id),
     CALL debugmsgstr("encounter_id= ",ddc.encntr_id),
     CALL debugmsgstr("dd_mdoc_event_id= ",ddc.mdoc_event_id),
     CALL debugmsgstr("dd_session_id= ",dds.dd_session_id)
     IF (contrib_cnt=1)
      stat = alterlist(sav->req,dd_cnt), sav->req[dd_cnt].patient_id = ddc.person_id, sav->req[dd_cnt
      ].author_id = ddc.author_id,
      sav->req[dd_cnt].encounter_id = ddc.encntr_id, sav->req[dd_cnt].unlock_flag = 1
     ENDIF
     stat = alterlist(sav->req[dd_cnt].contributions,contrib_cnt), sav->req[dd_cnt].contributions[
     contrib_cnt].dd_contribution_id = ddc.dd_contribution_id, sav->req[dd_cnt].contributions[
     contrib_cnt].dd_session_id = dds.dd_session_id,
     sav->req[dd_cnt].contributions[contrib_cnt].ensure_type = 0, stat = alterlist(aud_request->
      session,dd_cnt), aud_request->session[dd_cnt].dd_session_id = dds.dd_session_id,
     aud_request->session[dd_cnt].unlock_ind = 1, aud_request->session[dd_cnt].event_type = "CLINDOC",
     aud_request->session[dd_cnt].event_name = "DDUNLNOTE",
     unlockmsg = concat("This DD was unlocked by ops via cps_unlock_dd_ops. ",", mdoc_event_id = ",
      cnvtstring(ddc.mdoc_event_id),", session dt/tm: ",format(dds.session_dt_tm,";;q"),
      " ,session user id = ",cnvtstring(dds.session_user_id)," , session_id = ",cnvtstring(dds
       .dd_session_id),", contribution_id = ",
      cnvtstring(ddc.dd_contribution_id),", Removed: ",format(sysdate,";;q")), aud_request->session[
     dd_cnt].event_message = unlockmsg, aud_request->session[dd_cnt].session_dt_tm = dds
     .session_dt_tm,
     aud_request->session[dd_cnt].mdoc_event_id = ddc.mdoc_event_id, aud_request->session[dd_cnt].
     doc_event_id = ddc.doc_event_id, aud_request->session[dd_cnt].dd_contribution_id = ddc
     .dd_contribution_id,
     aud_request->session[dd_cnt].event_entity_name = "MDOC_EVENT_ID", aud_request->session[dd_cnt].
     session_user_id = dds.session_user_id, aud_request->session[dd_cnt].person_id = ddc.person_id,
     aud_request->session[dd_cnt].encntr_id = ddc.encntr_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE unlockops(null)
   DECLARE note_cnt = i4 WITH noconstant(size(sav->req,5))
   CALL debugmsgstr("Number of Dynamic Documentation Notes to Unlock: ",note_cnt)
   IF (note_cnt > 0)
    DECLARE contrib_cnt = i4 WITH protect, noconstant(0)
    DECLARE happ = i4 WITH protect, noconstant(0)
    DECLARE htask = i4 WITH protect, noconstant(0)
    DECLARE hstep = i4 WITH protect, noconstant(0)
    DECLARE hrequest = i4 WITH protect, noconstant(0)
    DECLARE hreply = i4 WITH protect, noconstant(0)
    DECLARE hstatus = i4 WITH protect, noconstant(0)
    DECLARE hsubeventstatus = i4 WITH protect, noconstant(0)
    DECLARE stagstatus = vc WITH protect, noconstant("")
    SET ncrmstat = uar_crmbeginapp(3202004,happ)
    SET ncrmstat = uar_crmbegintask(happ,3202004,htask)
    FOR (i = 1 TO note_cnt)
      SET ncrmstat = uar_crmbeginreq(htask,0,969502,hstep)
      SET hrequest = uar_crmgetrequest(hstep)
      CALL debugmsgstr("hRequest=",hrequest)
      SET stat = uar_srvsetdouble(hrequest,"patient_id",sav->req[i].patient_id)
      SET stat = uar_srvsetdouble(hrequest,"author_id",sav->req[i].author_id)
      SET stat = uar_srvsetdouble(hrequest,"encounter_id",sav->req[i].encounter_id)
      SET stat = uar_srvsetlong(hrequest,"unlock_flag",sav->req[i].unlock_flag)
      SET contrib_cnt = size(sav->req[i].contributions,5)
      FOR (c = 1 TO contrib_cnt)
        SET hcont = uar_srvadditem(hrequest,"contributions")
        SET stat = uar_srvsetdouble(hcont,"dd_contribution_id",sav->req[i].contributions[c].
         dd_contribution_id)
        SET stat = uar_srvsetdouble(hcont,"dd_session_id",sav->req[i].contributions[c].dd_session_id)
        SET stat = uar_srvsetlong(hcont,"ensure_type",sav->req[i].contributions[c].ensure_type)
      ENDFOR
      SET ncrmstat = uar_crmperform(hstep)
      SET hreply = uar_crmgetreply(hstep)
      SET hstatus = uar_srvgetstruct(hreply,"status_data")
      SET reply->status_data.status = uar_srvgetstringptr(hstatus,"status")
      SET hsubeventstatus = uar_srvgetitem(hstatus,"subeventstatus",0)
      IF ((reply->status_data.status="S"))
       INSERT  FROM pp_audit_event pae
        SET pae.pp_audit_event_id = seq(carenet_seq,nextval), pae.event_type = aud_request->session[i
         ].event_type, pae.event_name = aud_request->session[i].event_name,
         pae.event_message = aud_request->session[i].event_message, pae.event_dt_tm = cnvtdatetime(
          aud_request->session[i].session_dt_tm), pae.event_entity_id = aud_request->session[i].
         mdoc_event_id,
         pae.event_entity_name = aud_request->session[i].event_entity_name, pae.event_enum =
         aud_request->session[i].session_user_id, pae.person_id = aud_request->session[i].person_id,
         pae.encntr_id = aud_request->session[i].encntr_id, pae.user_id = reqinfo->updt_id, pae
         .app_nbr = reqinfo->updt_app,
         pae.updt_dt_tm = sysdate, pae.updt_task = reqinfo->updt_task, pae.updt_applctx = reqinfo->
         updt_applctx,
         pae.updt_id = reqinfo->updt_id
        WITH nocounter
       ;end insert
       SET stat_cnt = (stat_cnt+ 1)
       SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
       SET reply->status_data.subeventstatus[stat_cnt].operationname = uar_srvgetstringptr(
        hsubeventstatus,"OperationName")
       SET reply->status_data.subeventstatus[stat_cnt].operationstatus = uar_srvgetstringptr(
        hsubeventstatus,"OperationStatus")
       SET reply->status_data.subeventstatus[stat_cnt].targetobjectname = uar_srvgetstringptr(
        hsubeventstatus,"TargetObjectName")
       SET reply->status_data.subeventstatus[stat_cnt].targetobjectvalue = uar_srvgetstringptr(
        hsubeventstatus,"TargetObjectValue")
      ELSE
       CALL errorout(uar_srvgetstringptr(hsubeventstatus,"OperationName"),uar_srvgetstringptr(
         hsubeventstatus,"OperationStatus"),uar_srvgetstringptr(hsubeventstatus,"TargetObjectName"),
        uar_srvgetstringptr(hsubeventstatus,"TargetObjectValue"))
      ENDIF
      CALL uar_srvdestroyhandle(hrequest)
      CALL uar_srvdestroyhandle(hreply)
    ENDFOR
    GO TO success
   ELSE
    SET reply->status_data.status = "S"
    SET stat_cnt = (stat_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
    SET reply->status_data.subeventstatus[stat_cnt].operationname = "UPDATED"
    SET reply->status_data.subeventstatus[stat_cnt].operationstatus = "S"
    SET reply->status_data.subeventstatus[stat_cnt].targetobjectname = "No update needed"
    SET reply->status_data.subeventstatus[stat_cnt].targetobjectvalue =
    "No locked notes within given parameters"
    GO TO exit_script
   ENDIF
 END ;Subroutine
#general_failure
 SET reply->status_data.status = "F"
 CALL echo("General Failure")
 GO TO exit_script
#success
 COMMIT
 SET reply->status_data.status = "S"
 SET stat_cnt = (stat_cnt+ 1)
 SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
 SET reply->status_data.subeventstatus[stat_cnt].operationname = "UPDATED"
 SET reply->status_data.subeventstatus[stat_cnt].operationstatus = "S"
 SET reply->status_data.subeventstatus[stat_cnt].targetobjectname = "Locked Notes"
 SET reply->status_data.subeventstatus[stat_cnt].targetobjectvalue = "test"
 CALL echo("Success")
 GO TO exit_script
#exit_script
 CALL echorecord(sav)
 CALL echorecord(reply)
 CALL echo("The script is complete")
END GO
