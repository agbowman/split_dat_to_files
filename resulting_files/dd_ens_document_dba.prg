CREATE PROGRAM dd_ens_document:dba
 DECLARE cps_lock = i4 WITH public, constant(100)
 DECLARE cps_no_seq = i4 WITH public, constant(101)
 DECLARE cps_updt_cnt = i4 WITH public, constant(102)
 DECLARE cps_insuf_data = i4 WITH public, constant(103)
 DECLARE cps_update = i4 WITH public, constant(104)
 DECLARE cps_insert = i4 WITH public, constant(105)
 DECLARE cps_delete = i4 WITH public, constant(106)
 DECLARE cps_select = i4 WITH public, constant(107)
 DECLARE cps_auth = i4 WITH public, constant(108)
 DECLARE cps_inval_data = i4 WITH public, constant(109)
 DECLARE cps_ens_note_story_not_locked = i4 WITH public, constant(110)
 DECLARE cps_lock_msg = c33 WITH public, constant("Failed to lock all requested rows")
 DECLARE cps_no_seq_msg = c34 WITH public, constant("Failed to get next sequence number")
 DECLARE cps_updt_cnt_msg = c28 WITH public, constant("Failed to match update count")
 DECLARE cps_insuf_data_msg = c38 WITH public, constant("Request did not supply sufficient data")
 DECLARE cps_update_msg = c24 WITH public, constant("Failed on update request")
 DECLARE cps_insert_msg = c24 WITH public, constant("Failed on insert request")
 DECLARE cps_delete_msg = c24 WITH public, constant("Failed on delete request")
 DECLARE cps_select_msg = c24 WITH public, constant("Failed on select request")
 DECLARE cps_auth_msg = c34 WITH public, constant("Failed on authorization of request")
 DECLARE cps_inval_data_msg = c35 WITH public, constant("Request contained some invalid data")
 DECLARE cps_success = i4 WITH public, constant(0)
 DECLARE cps_success_info = i4 WITH public, constant(1)
 DECLARE cps_success_warn = i4 WITH public, constant(2)
 DECLARE cps_deadlock = i4 WITH public, constant(3)
 DECLARE cps_script_fail = i4 WITH public, constant(4)
 DECLARE cps_sys_fail = i4 WITH public, constant(5)
 SUBROUTINE cps_add_error(cps_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   SET reply->cps_error.cnt += 1
   SET errcnt = reply->cps_error.cnt
   SET stat = alterlist(reply->cps_error.data,errcnt)
   SET reply->cps_error.data[errcnt].code = cps_errcode
   SET reply->cps_error.data[errcnt].severity_level = severity_level
   SET reply->cps_error.data[errcnt].supp_err_txt = supp_err_txt
   SET reply->cps_error.data[errcnt].def_msg = def_msg
   SET reply->cps_error.data[errcnt].row_data.lvl_1_idx = idx1
   SET reply->cps_error.data[errcnt].row_data.lvl_2_idx = idx2
   SET reply->cps_error.data[errcnt].row_data.lvl_3_idx = idx3
 END ;Subroutine
 DECLARE validaterequest(null) = null WITH protect
 DECLARE checkoneventrepstatus(null) = null WITH protect
 DECLARE g_failure = c1 WITH public, noconstant("F")
 DECLARE today_dt_tm = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE eno_change = i4 WITH protect, constant(1)
 DECLARE eskip = i4 WITH protect, constant(2)
 DECLARE ce_version = vc WITH protect, constant("CE_VERSION")
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 cps_error
      2 cnt = i4
      2 data[*]
        3 code = i4
        3 severity_level = i4
        3 supp_err_txt = c32
        3 def_msg = vc
        3 row_data
          4 lvl_1_idx = i4
          4 lvl_2_idx = i4
          4 lvl_3_idx = i4
  )
 ENDIF
 IF (validate(reply->status_data.status)=0)
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"reply doesn't contain status block",
   cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 CALL validaterequest(null)
 IF (g_failure="T")
  GO TO exit_script
 ENDIF
 CALL checkoneventrepstatus(null)
 IF (((g_failure="T") OR (g_failure="Z")) )
  GO TO exit_script
 ENDIF
 DECLARE request_session_count = i4 WITH protect, constant(size(request->session,5))
 IF (request_session_count=0)
  SET g_failure = "T"
  CALL cps_add_error(cps_inval_data,cps_script_fail,"REQUEST_SESSION_COUNT 0",cps_inval_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 DECLARE iversion = i4 WITH public, noconstant(0)
 DECLARE isessionidx = i4 WITH private, noconstant(0)
 FOR (isessionidx = 1 TO request_session_count)
   CALL validatesession(isessionidx)
   IF (g_failure="T")
    GO TO exit_script
   ENDIF
   CALL checkforeventid(isessionidx)
   IF (g_failure="T")
    GO TO exit_script
   ENDIF
   SET iversion = getversion(request->session[isessionidx].dd_contribution[1].mdoc_event_id)
   IF (g_failure="T")
    GO TO exit_script
   ENDIF
   CALL processcontribution(isessionidx)
   IF (g_failure="T")
    GO TO exit_script
   ENDIF
   CALL populateemrextract(isessionidx)
   IF (g_failure="T")
    GO TO exit_script
   ENDIF
   CALL processsession(isessionidx,iversion)
   IF (g_failure="T")
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE processcontribution(isessionidx)
   CASE (request->session[isessionidx].dd_contribution[1].action_type)
    OF "ADD":
     CALL insertcontribution(isessionidx)
     IF (g_failure="T")
      RETURN
     ENDIF
    OF "UPD":
     CALL updatecontribution(isessionidx)
     IF (g_failure="T")
      RETURN
     ENDIF
    ELSE
     SET g_failure = "T"
     CALL cps_add_error(cps_inval_data,cps_script_fail,concat("Invalid dd_contr action type: ",
       request->session[isessionidx].dd_contribution[1].action_type),cps_inval_data_msg,isessionidx,
      0,0)
     RETURN
   ENDCASE
 END ;Subroutine
 SUBROUTINE processsession(isessionidx,iversion)
   IF ((request->session[isessionidx].unlock_ind=1))
    CALL deletesession(isessionidx)
    RETURN
   ENDIF
   DECLARE request_data_count = i4 WITH private, constant(size(request->session[isessionidx].
     dd_session_data,5))
   DECLARE idataidx = i4 WITH private, noconstant(0)
   FOR (idataidx = 1 TO request_data_count)
     CASE (request->session[isessionidx].dd_session_data[idataidx].action_type)
      OF "UPD":
       CALL updatesessiondata(isessionidx,idataidx,iversion)
       IF (g_failure="T")
        RETURN
       ENDIF
      ELSE
       SET g_failure = "T"
       CALL cps_add_error(cps_inval_data,cps_script_fail,concat(
         "Invalid dd_session_data action type: ",request->session[isessionidx].dd_session_data[
         idataidx].action_type),cps_inval_data_msg,isessionidx,
        idataidx,0)
       RETURN
     ENDCASE
   ENDFOR
 END ;Subroutine
 SUBROUTINE validaterequest(null)
   IF (validate(request->session)=0)
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,"request->session doesn't exist",
     cps_inval_data_msg,0,
     0,0)
    RETURN
   ENDIF
   IF (validate(request->sessions[1].dd_session_id,"k") != "k")
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,
     "request->sessions[1].dd_session_id doesn't exist",cps_inval_data_msg,0,
     0,0)
    RETURN
   ENDIF
   IF (validate(request->sessions[1].dd_contribution[1].dd_contribution_id,"k") != "k")
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,
     "validate(request->...dd_contribution_id doesn't exist",cps_inval_data_msg,0,
     0,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE checkoneventrepstatus(null)
   IF (validate(event_rep) != 0)
    DECLARE reply_ce_count = i4 WITH protect, constant(size(event_rep->rb_list,5))
    IF (reply_ce_count=0)
     SET g_failure = "T"
     CALL cps_add_error(cps_inval_data,cps_script_fail,"No events on the reply",cps_inval_data_msg,0,
      0,0)
     RETURN
    ENDIF
    IF ((event_rep->sb[1].statuscd != 0.0))
     SET g_failure = "T"
     CALL cps_add_error(cps_inval_data,cps_script_fail,"sb.statusCd != 0.0",cps_inval_data_msg,0,
      0,0)
     RETURN
    ELSE
     DECLARE reply_substatus_count = i4 WITH protect, constant(size(event_rep->sb.substatuslist,5))
     DECLARE idx = i2 WITH protect, noconstant(0)
     DECLARE substatuscdidx = i4 WITH protect, noconstant(0)
     SET substatuscdidx = locateval(idx,1,reply_substatus_count,eno_change,event_rep->sb[1].
      substatuslist[idx].substatuscd)
     IF (0 != substatuscdidx)
      SET g_failure = "Z"
      RETURN
     ENDIF
     SET idx = 0
     SET substatuscdidx = locateval(idx,1,reply_substatus_count,eskip,event_rep->sb[1].substatuslist[
      idx].substatuscd)
     IF (0 != substatuscdidx)
      SET g_failure = "T"
      CALL cps_add_error(cps_inval_data,cps_script_fail,"Subevent status of SKIP(2)",
       cps_inval_data_msg,0,
       0,0)
      RETURN
     ENDIF
    ENDIF
    IF ((event_rep->sb[1].severitycd > 2))
     SET g_failure = "T"
     CALL cps_add_error(cps_inval_data,cps_script_fail,"sb.severityCd > 2",cps_inval_data_msg,0,
      0,0)
     RETURN
    ENDIF
   ELSE
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,"Failed to VALIDATE(event_rep)",
     cps_inval_data_msg,0,
     0,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (geteventid(reference_nbr=vc) =f8 WITH protect)
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE eventididx = i4 WITH private, noconstant(0)
   DECLARE reply_ce_count = i4 WITH protect, constant(size(event_rep->rb_list,5))
   SET eventididx = locateval(idx,1,reply_ce_count,reference_nbr,event_rep->rb_list[idx].
    reference_nbr)
   IF (eventididx=0)
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,concat("GetEventId failed for ",reference_nbr),
     cps_inval_data_msg,0,
     0,0)
   ENDIF
   RETURN(event_rep->rb_list[eventididx].event_id)
 END ;Subroutine
 SUBROUTINE (checkforeventid(isessionidx=i4) =null WITH protect)
   DECLARE ddocid = f8 WITH private, noconstant(request->session[isessionidx].dd_contribution[1].
    doc_event_id)
   DECLARE dmdocid = f8 WITH private, noconstant(request->session[isessionidx].dd_contribution[1].
    mdoc_event_id)
   IF (ddocid=0
    AND textlen(trim(request->session[isessionidx].dd_contribution[1].doc_row_reference_nbr))=0)
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,"CheckForEventId, invalid DOC id/refnbr",
     cps_inval_data_msg,isessionidx,
     0,0)
   ENDIF
   IF (dmdocid=0
    AND textlen(trim(request->session[isessionidx].dd_contribution[1].mdoc_row_reference_nbr))=0)
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,"CheckForEventId, invalid MDOC id/refnbr",
     cps_inval_data_msg,isessionidx,
     0,0)
   ENDIF
   IF (ddocid=0)
    SET request->session[isessionidx].dd_contribution[1].doc_event_id = geteventid(request->session[
     isessionidx].dd_contribution[1].doc_row_reference_nbr)
   ENDIF
   IF (dmdocid=0)
    SET request->session[isessionidx].dd_contribution[1].mdoc_event_id = geteventid(request->session[
     isessionidx].dd_contribution[1].mdoc_row_reference_nbr)
   ENDIF
 END ;Subroutine
 SUBROUTINE (insertcontribution(isessionidx=i4) =null WITH protect)
  INSERT  FROM dd_contribution d
   SET d.author_id = request->session[isessionidx].dd_contribution[1].author_id, d.dd_contribution_id
     = request->session[isessionidx].dd_contribution[1].dd_contribution_id, d.doc_event_id = request
    ->session[isessionidx].dd_contribution[1].doc_event_id,
    d.encntr_id = request->session[isessionidx].dd_contribution[1].encntr_id, d.mdoc_event_id =
    request->session[isessionidx].dd_contribution[1].mdoc_event_id, d.person_id = request->session[
    isessionidx].dd_contribution[1].person_id,
    d.updt_applctx = 0, d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(today_dt_tm),
    d.updt_id = request->session[isessionidx].session_user_id, d.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual != 1)
   SET g_failure = "T"
   CALL cps_add_error(cps_update,cps_script_fail,"INSERT DD_CONTRIBUTION",cps_insert_msg,isessionidx,
    0,0)
   RETURN
  ENDIF
 END ;Subroutine
 SUBROUTINE (updatecontribution(isessionidx=i4) =null WITH protect)
  UPDATE  FROM dd_contribution d
   SET d.author_id = request->session[isessionidx].dd_contribution[1].author_id, d.encntr_id =
    request->session[isessionidx].dd_contribution[1].encntr_id, d.updt_cnt = (d.updt_cnt+ 1),
    d.updt_dt_tm = cnvtdatetime(today_dt_tm), d.updt_id = request->session[isessionidx].
    session_user_id, d.updt_task = 0,
    d.updt_applctx = 0
   WHERE (d.dd_contribution_id=request->session[isessionidx].dd_contribution[1].dd_contribution_id)
   WITH nocounter
  ;end update
  IF (curqual != 1)
   SET g_failure = "T"
   CALL cps_add_error(cps_update,cps_script_fail,"UPDATE DD_CONTRIBUTION",cps_update_msg,isessionidx,
    0,0)
   RETURN
  ENDIF
 END ;Subroutine
 SUBROUTINE (getcodevalue(dcodeset=f8,smeaning=vc) =f8 WITH protect)
   DECLARE dcd = f8 WITH private, noconstant(uar_get_code_by("MEANING",dcodeset,smeaning))
   IF (dcd=0.0)
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,concat("code value lookup failed: ",smeaning),
     cps_inval_data_msg,1,
     0,0)
   ENDIF
   RETURN(dcd)
 END ;Subroutine
 SUBROUTINE (updatesessiondata(isessionidx=i4,idataidx=i4,iversion=i4) =null WITH protect)
   DECLARE sdatakey = vc WITH protect, noconstant(request->session[isessionidx].dd_session_data[
    idataidx].session_data_key)
   DECLARE sshorttxt = vc WITH protect, noconstant(request->session[isessionidx].dd_session_data[
    idataidx].short_txt)
   IF (sdatakey=ce_version)
    SET sshorttxt = nullterm(cnvtstring(iversion))
   ENDIF
   UPDATE  FROM dd_session_data d
    SET d.session_data_key = sdatakey, d.short_txt = sshorttxt, d.updt_cnt = (d.updt_cnt+ 1),
     d.updt_dt_tm = cnvtdatetime(today_dt_tm), d.updt_id = request->session[isessionidx].
     session_user_id, d.updt_task = 0,
     d.updt_applctx = 0
    WHERE (d.dd_session_data_id=request->session[isessionidx].dd_session_data[idataidx].
    dd_session_data_id)
    WITH nocounter
   ;end update
   IF (curqual != 1)
    SET g_failure = "T"
    CALL cps_add_error(cps_update,cps_script_fail,"UPDATE DD_SESSION_DATA",cps_update_msg,isessionidx,
     idataidx,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (deletesession(isessionidx=i4) =null WITH protect)
   DELETE  FROM long_blob lb
    WHERE lb.long_blob_id IN (
    (SELECT
     sd.long_blob_id
     FROM dd_session_data sd
     WHERE (sd.dd_session_id=request->session[isessionidx].dd_session_id)
      AND sd.long_blob_id != 0.0))
     AND  NOT (lb.long_blob_id IN (
    (SELECT
     e.extract_xml_blob_id
     FROM dd_emr_extract e
     WHERE (e.dd_contribution_id=request->session[isessionidx].dd_contribution[1].dd_contribution_id)
    )))
    WITH nocounter
   ;end delete
   DELETE  FROM dd_session_data d
    WHERE (d.dd_session_id=request->session[isessionidx].dd_session_id)
    WITH nocounter
   ;end delete
   DELETE  FROM dd_session d
    WHERE (d.dd_session_id=request->session[isessionidx].dd_session_id)
    WITH nocounter
   ;end delete
   IF (curqual != 1)
    SET g_failure = "T"
    CALL cps_add_error(cps_delete,cps_script_fail,"DELETE DD_SESSION",cps_delete_msg,isessionidx,
     0,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatesession(isessionidx=i4) =null WITH protect)
  SELECT INTO "NL:"
   FROM dd_session d
   WHERE (d.dd_session_id=request->session[isessionidx].dd_session_id)
    AND (d.session_user_id=request->session[isessionidx].session_user_id)
    AND (d.parent_entity_id=request->session[isessionidx].dd_contribution[1].dd_contribution_id)
    AND d.parent_entity_name="DD_CONTRIBUTION"
   WITH nocounter
  ;end select
  IF (curqual != 1)
   SET g_failure = "T"
   CALL cps_add_error(cps_inval_data,cps_script_fail,"Invalid session",cps_inval_data_msg,isessionidx,
    0,0)
   RETURN
  ENDIF
 END ;Subroutine
 SUBROUTINE (getversion(eventid=f8) =i4 WITH protect)
   DECLARE reply_ce_count = i4 WITH protect, constant(size(event_rep->rb_list,5))
   DECLARE idx = i2 WITH protect, noconstant(0)
   DECLARE ieventididx = i4 WITH protect, noconstant(0)
   SET ieventididx = locateval(idx,1,reply_ce_count,eventid,event_rep->rb_list[idx].event_id)
   RETURN(event_rep->rb_list[ieventididx].updt_cnt)
 END ;Subroutine
 SUBROUTINE (insertemrextract(isessionidx=i4,idataidx=i4) =null WITH protect)
   DECLARE fextractid = f8 WITH protect, noconstant(request->session[isessionidx].dd_contribution.
    data_extract_xml[idataidx].dd_emr_extract_id)
   DECLARE flongblobid = f8 WITH protect, noconstant(request->session[isessionidx].dd_contribution.
    data_extract_xml[idataidx].long_blob_id)
   DECLARE sextractkey = vc WITH protect, noconstant(request->session[isessionidx].dd_contribution.
    data_extract_xml[idataidx].extract_key)
   INSERT  FROM dd_emr_extract d
    SET d.dd_emr_extract_id = fextractid, d.dd_contribution_id = request->session[isessionidx].
     dd_contribution.dd_contribution_id, d.extract_xml_blob_id = flongblobid,
     d.extract_uuid = sextractkey, d.updt_applctx = 0, d.updt_cnt = 0,
     d.updt_dt_tm = cnvtdatetime(today_dt_tm), d.updt_id = request->session[isessionidx].
     session_user_id, d.updt_task = 0
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE (populateemrextract(isessionidx=i4) =null WITH protect)
   DELETE  FROM dd_emr_extract de
    WHERE de.extract_uuid IN (
    (SELECT
     content_instance_ident
     FROM dd_session_data d
     WHERE (d.dd_session_id=request->session[isessionidx].dd_session_id)))
    WITH nocounter
   ;end delete
   DECLARE request_data_count = i4 WITH private, constant(size(request->session[isessionidx].
     dd_contribution.data_extract_xml,5))
   IF (request_data_count > 0)
    DECLARE idataidx = i4 WITH private, noconstant(0)
    FOR (idataidx = 1 TO request_data_count)
      CALL insertemrextract(isessionidx,idataidx)
    ENDFOR
    IF (curqual != 1)
     SET g_failure = "T"
     CALL cps_add_error(cps_update,cps_script_fail,"INSERT DD_EMR_EXTRACT",cps_insert_msg,isessionidx,
      0,0)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (g_failure="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL echorecord(request,"dd_ens_document_failure_log",1)
  IF (validate(event_rep) != 0)
   CALL echorecord(event_rep,"dd_ens_document_failure_log",1)
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
