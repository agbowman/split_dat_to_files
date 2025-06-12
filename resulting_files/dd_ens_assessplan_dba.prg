CREATE PROGRAM dd_ens_assessplan:dba
 SUBROUTINE scdgetuniqueid(null)
   DECLARE unique_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_seq = seq(scd_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     unique_id = cnvtreal(next_seq)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_select,cps_script_fail,"Getting INSERT IDS",cps_select_msg,0,
     0,0)
   ENDIF
   RETURN(unique_id)
 END ;Subroutine
 SUBROUTINE scdgetuniqueactivityid(null)
   DECLARE unique_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_seq = seq(scd_act_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     unique_id = cnvtreal(next_seq)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_select,cps_script_fail,"Getting INSERT IDS",cps_select_msg,0,
     0,0)
   ENDIF
   RETURN(unique_id)
 END ;Subroutine
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
 DECLARE processcontribution(icontributionidx) = null WITH protect
 DECLARE insertassessplancontent(icontributionidx,nomenclatureid) = null WITH protect
 DECLARE g_failure = c1 WITH public, noconstant("F")
 DECLARE today_dt_tm = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 FREE RECORD temp_document_nomenclature
 RECORD temp_document_nomenclature(
   1 nomenclature[*]
     2 nomenclature_id = f8
 )
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
 IF (checkdic("PDOC_ASSESSPLAN_CONTENT","T",0)=1)
  CALL echo(
   "PDOC_ASSESSPLAN_CONTENT table exists but I can't access it. Succeed transaction but do nothing")
  GO TO exit_script
 ELSEIF (checkdic("PDOC_ASSESSPLAN_CONTENT","T",0)=0)
  CALL echo("PDOC_ASSESSPLAN_CONTENT table doesn't exist.  Succeed transaction but do nothing")
  GO TO exit_script
 ENDIF
 DECLARE request_contribution_count = i4 WITH protect, constant(size(request->ap_contribution,5))
 DECLARE icontributionidx = i4 WITH private, noconstant(0)
 FOR (icontributionidx = 1 TO request_contribution_count)
  CALL processcontribution(icontributionidx)
  IF (g_failure="T")
   GO TO exit_script
  ENDIF
 ENDFOR
 SUBROUTINE processcontribution(icontributionidx)
   CALL checkforeventid(icontributionidx)
   IF (g_failure="T")
    GO TO exit_script
   ENDIF
   CALL checkfornomenclatureid(icontributionidx)
   IF (g_failure="T")
    GO TO exit_script
   ENDIF
   DELETE  FROM pdoc_assessplan_content pac
    WHERE (pac.event_id=request->ap_contribution[icontributionidx].doc_event_id)
    WITH nocounter
   ;end delete
   DECLARE nomenclaturecount = i4 WITH private, noconstant(0)
   SET nomenclaturecount = cnvtint(size(temp_document_nomenclature->nomenclature,5))
   IF (nomenclaturecount > 0)
    DECLARE inomenclatureidx = i4 WITH private, noconstant(0)
    FOR (inomenclatureidx = 1 TO nomenclaturecount)
     CALL insertassessplancontent(icontributionidx,temp_document_nomenclature->nomenclature[
      inomenclatureidx].nomenclature_id)
     IF (g_failure="T")
      GO TO exit_script
     ENDIF
    ENDFOR
   ENDIF
   IF ((request->ap_contribution[icontributionidx].has_comment="Y"))
    CALL insertassessplancontent(icontributionidx,0)
    IF (g_failure="T")
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insertassessplancontent(icontributionidx,nomenclatureid)
   SET assessplancontentid = scdgetuniqueactivityid(null)
   INSERT  FROM pdoc_assessplan_content pac
    SET pac.pdoc_assessplan_content_id = assessplancontentid, pac.event_id = request->
     ap_contribution[icontributionidx].doc_event_id, pac.nomenclature_id = nomenclatureid,
     pac.updt_applctx = reqinfo->updt_applctx, pac.updt_cnt = 0, pac.updt_dt_tm = cnvtdatetime(
      today_dt_tm),
     pac.updt_id = reqinfo->updt_id, pac.updt_task = reqinfo->updt_task, pac.service_dt_tm =
     cnvtdatetime(request->service_dt_tm)
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET g_failure = "T"
    CALL cps_add_error(cps_update,cps_script_fail,"INSERT PDOC_ASSESSPLAN_CONTENT",cps_insert_msg,
     nomenclatureid,
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
 SUBROUTINE (checkforeventid(icontributionidx=i4) =null WITH protect)
   DECLARE ddocid = f8 WITH private, noconstant(request->ap_contribution[icontributionidx].
    doc_event_id)
   IF (ddocid=0
    AND textlen(trim(request->ap_contribution[icontributionidx].doc_row_reference_nbr))=0)
    SET g_failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,"CheckForEventId, invalid DOC id/refnbr",
     cps_inval_data_msg,isectionidx,
     0,0)
   ENDIF
   IF (ddocid=0)
    SET request->ap_contribution[icontributionidx].doc_event_id = geteventid(request->
     ap_contribution[icontributionidx].doc_row_reference_nbr)
   ENDIF
 END ;Subroutine
 SUBROUTINE (checkfornomenclatureid(idx=i4) =null WITH protect)
   DECLARE diagnosiscount = i4 WITH noconstant(0)
   SET diagnosiscount = cnvtint(size(request->ap_contribution[idx].diagnosis,5))
   IF (diagnosiscount > 0)
    DECLARE expidx = i4 WITH noconstant(0)
    DECLARE locateidx = i4 WITH noconstant(0)
    DECLARE locatevalpos = i4 WITH noconstant(0)
    DECLARE nomenclatureid = f8 WITH noconstant(0)
    DECLARE cnt = i4 WITH noconstant(0)
    SET stat = alterlist(temp_document_nomenclature->nomenclature,diagnosiscount)
    SET cnt = 0
    SELECT DISTINCT INTO "nl:"
     FROM diagnosis d
     WHERE expand(expidx,1,diagnosiscount,d.diagnosis_id,request->ap_contribution[idx].diagnosis[
      expidx].diagnosis_id)
     DETAIL
      IF (d.originating_nomenclature_id > 0)
       nomenclatureid = d.originating_nomenclature_id
      ELSE
       nomenclatureid = d.nomenclature_id
      ENDIF
      IF (cnt=0)
       cnt += 1, temp_document_nomenclature->nomenclature[cnt].nomenclature_id = nomenclatureid
      ELSEIF (locateval(locateidx,1,cnt,nomenclatureid,temp_document_nomenclature->nomenclature[
       locateidx].nomenclature_id)=0)
       cnt += 1, temp_document_nomenclature->nomenclature[cnt].nomenclature_id = nomenclatureid
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET g_failure = "T"
     CALL cps_add_error(cps_inval_data,cps_script_fail,"Nomenclature ID lookup failed",
      cps_inval_data_msg,0,
      0,0)
     RETURN
    ENDIF
    SET stat = alterlist(temp_document_nomenclature->nomenclature,cnt)
   ENDIF
 END ;Subroutine
#exit_script
 IF (g_failure="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL echorecord(request,"doc_ens_assessplan_failure_log",1)
  IF (validate(event_rep) != 0)
   CALL echorecord(event_rep,"doc_ens_assessplan_failure_log",1)
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
