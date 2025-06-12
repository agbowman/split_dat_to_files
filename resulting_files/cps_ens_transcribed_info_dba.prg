CREATE PROGRAM cps_ens_transcribed_info:dba
 RECORD reply(
   1 ensure_failures[*]
     2 status_failure_flag = i2
     2 failure_reason = vc
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
 IF ( NOT (validate(g_idocauditmgrenabled,0)))
  DECLARE g_iet_imp_transcribed_dict = i2 WITH public, constant(0)
  DECLARE g_imode_one_part = i2 WITH public, constant(0)
  DECLARE g_imode_open_multi_part = i2 WITH public, constant(1)
  DECLARE g_imode_continue_multi_part = i2 WITH public, constant(2)
  DECLARE g_imode_close_multi_part = i2 WITH public, constant(3)
  DECLARE g_imode_entry_close_multi_part = i2 WITH public, constant(4)
  DECLARE g_sen_maintainclindoc = vc WITH public, constant("Maintain Clinical Document")
  DECLARE g_set_imp_transcribed_dict = vc WITH public, constant("Import Transcribed Dictation")
  DECLARE g_sparttype_person = vc WITH public, constant("Person")
  DECLARE g_spartrole_patient = vc WITH public, constant("Patient")
  DECLARE g_sdatalifecycle_amendment = vc WITH public, constant("Amendment")
  DECLARE g_idocauditmgrenabled = i2 WITH public, constant(1)
 ENDIF
 SUBROUTINE (docauditevent(iauditevent=i2,imode=i2,dparticipantid=f8,sparticipantname=vc,
  sparticipantidtype=vc) =i2)
  CASE (iauditevent)
   OF g_iet_imp_transcribed_dict:
    EXECUTE cclaudit imode, nullterm(g_sen_maintainclindoc), nullterm(g_set_imp_transcribed_dict),
    nullterm(g_sparttype_person), nullterm(g_spartrole_patient), nullterm(sparticipantidtype),
    nullterm(g_sdatalifecycle_amendment), dparticipantid, nullterm(sparticipantname)
  ENDCASE
  RETURN(validate(cclaud->stat,0))
 END ;Subroutine
 RECORD term_data_req(
   1 qual[*]
     2 event_id = f8
     2 scd_term_data_id = f8
     2 scd_term_id = f8
     2 fkey_entity_name = c32
     2 fkey_id = f8
     2 value_number = f8
     2 scd_term_data_key = c255
     2 scd_term_data_type_cd = f8
 )
 DECLARE updatedatatypetermdata(null) = null
 DECLARE validatedictationcount(null) = null
 DECLARE checklocked(null) = i2 WITH protect
 DECLARE ensureblobs(null) = null
 DECLARE insertscdblobtermdata(null) = null
 DECLARE releaselock(null) = null
 DECLARE updatestorystatus(null) = null
 DECLARE esuccessful = i2 WITH constant(0)
 DECLARE efailcountmismatch = i2 WITH constant(1)
 DECLARE efaildocumentlocked = i2 WITH constant(2)
 DECLARE efailtablefull = i2 WITH constant(3)
 DECLARE efailunknown = i2 WITH constant(4)
 DECLARE efailstorynotfound = i2 WITH constant(5)
 DECLARE term_data_type_infonote = f8 WITH constant(uar_get_code_by("MEANING",15752,"INFONOTE"))
 DECLARE term_data_type_data = f8 WITH constant(uar_get_code_by("MEANING",15752,"DATA"))
 DECLARE term_data_key_dictate = c7 WITH constant("DICTATE")
 DECLARE term_data_key_rtf = c3 WITH constant("RTF")
 DECLARE story_status_trans = f8 WITH constant(uar_get_code_by("MEANING",15750,"TRANSCRIBED"))
 DECLARE dictated_term_cnt = i4 WITH noconstant(0), public
 DECLARE req_qual_size = i4 WITH noconstant(0), public
 DECLARE ensure_fail_cnt = i2 WITH noconstant(0), public
 DECLARE ensure_failure = i2 WITH noconstant(esuccessful), public
 DECLARE lockcheck = i2 WITH noconstant(0)
 DECLARE scdstoryid = f8 WITH noconstant(0.0), public
 DECLARE sstorytitle = vc WITH noconstant(""), public
 DECLARE dpatientid = f8 WITH noconstant(0.0), public
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET req_qual_size = size(request->qual,5)
 IF (req_qual_size=0)
  SET reply->status_data.status = "S"
  CALL releaselock(null)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM scd_story n
  WHERE (n.event_id=request->event_id)
  DETAIL
   scdstoryid = n.scd_story_id, sstorytitle = n.title, dpatientid = n.person_id
  WITH nocounter
 ;end select
 IF (scdstoryid=0.0)
  CALL addfailure(efailstorynotfound,"Unable to Locate SCD Story from Event Id")
  GO TO exit_script
 ENDIF
 FREE RECORD lock_data
 RECORD lock_data(
   1 story_id = f8
   1 actn_type = c3
   1 update_lock_dt_tm = dq8
   1 note_index = i4
 )
 SET lock_data->story_id = scdstoryid
 SET lock_data->actn_type = "UPD"
 SET lock_data->update_lock_dt_tm = request->lock_dt_tm
 SET lock_data->note_index = 1
 DECLARE irtn = i2 WITH noconstant(0)
 SET lockcheck = checklocked(null)
 FREE RECORD lock_data
 IF (lockcheck > 0)
  CALL addfailure(efaildocumentlocked,"SCD Story Not Locked by Current User")
  GO TO exit_script
 ENDIF
 CALL validatedictationcount(null)
 IF (ensure_failure > esuccessful)
  GO TO exit_script
 ENDIF
 CALL ensureblobs(null)
 IF (ensure_failure > esuccessful)
  GO TO exit_script
 ENDIF
 CALL insertscdblobtermdata(null)
 IF (ensure_failure > esuccessful)
  GO TO exit_script
 ENDIF
 CALL updatedatatypetermdata(null)
 IF (ensure_failure > esuccessful)
  GO TO exit_script
 ENDIF
 CALL updatestorystatus(null)
 IF (ensure_failure > esuccessful)
  GO TO exit_script
 ENDIF
 CALL releaselock(null)
 IF (ensure_failure > esuccessful)
  GO TO exit_script
 ENDIF
 CALL docauditevent(g_iet_imp_transcribed_dict,g_imode_open_multi_part,request->event_id,trim(
   sstorytitle),"Clinical_Event")
 CALL docauditevent(g_iet_imp_transcribed_dict,g_imode_close_multi_part,dpatientid,"","Patient")
#exit_script
 IF (ensure_failure > esuccessful)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
 FREE RECORD term_data_req
 SUBROUTINE checklocked(null)
   FREE RECORD current_lock_data
   RECORD current_lock_data(
     1 update_lock_user_id = f8
     1 update_lock_dt_tm = dq8
   )
   SELECT INTO "NL:"
    FROM scd_story n
    WHERE (n.scd_story_id=lock_data->story_id)
     AND (n.update_lock_user_id=reqinfo->updt_id)
    DETAIL
     update_cnt = n.updt_cnt, current_lock_data->update_lock_dt_tm = n.update_lock_dt_tm
     IF (validate(story_completion_status_mean)=1)
      story_completion_status_mean = uar_get_code_meaning(n.story_completion_status_cd)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = 1
    SELECT INTO "NL:"
     FROM scd_story n
     WHERE (n.scd_story_id=lock_data->story_id)
     DETAIL
      current_lock_data->update_lock_user_id = n.update_lock_user_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL cps_add_error(cps_ens_note_story_not_locked,cps_script_fail,build("STORY NOT FOUND: ",
       lock_data->story_id),cps_select_msg,lock_data->note_index,
      0,cnvtint(reqinfo->updt_id))
     RETURN(1)
    ENDIF
    IF ((current_lock_data->update_lock_user_id=0.0))
     IF ((lock_data->actn_type="UNL"))
      CALL cps_add_error(cps_ens_note_story_not_locked,cps_success_warn,build("STORY IS NOT LOCKED: ",
        lock_data->story_id),cps_updt_cnt_msg,lock_data->note_index,
       0,cnvtint(reqinfo->updt_id))
      SET failed = 0
      RETURN(1)
     ELSE
      CALL cps_add_error(cps_ens_note_story_not_locked,cps_script_fail,"STORY IS NOT LOCKED.",
       cps_updt_cnt_msg,lock_data->note_index,
       cnvtint(lock_data->story_id),cnvtint(reqinfo->updt_id))
      RETURN(1)
     ENDIF
    ENDIF
    CALL cps_add_error(cps_ens_note_story_not_locked,cps_script_fail,"STORY NOT LOCKED BY THIS USER.",
     cps_updt_cnt_msg,lock_data->note_index,
     cnvtint(lock_data->story_id),cnvtint(reqinfo->updt_id))
    RETURN(1)
   ELSE
    IF ((lock_data->update_lock_dt_tm != 0))
     IF ((current_lock_data->update_lock_dt_tm != lock_data->update_lock_dt_tm))
      IF ((lock_data->actn_type="UNL"))
       CALL cps_add_error(cps_ens_note_story_not_locked,cps_success_warn,
        "USER HAS TWO SESSIONS,SAME STORY",cps_update_msg,lock_data->note_index,
        cnvtint(lock_data->story_id),cnvtint(reqinfo->updt_id))
       SET failed = 0
       RETURN(1)
      ELSE
       CALL cps_add_error(cps_ens_note_story_not_locked,cps_script_fail,
        "USER HAS TWO SESSIONS,SAME STORY",cps_update_msg,lock_data->note_index,
        cnvtint(lock_data->story_id),cnvtint(reqinfo->updt_id))
       SET failed = 1
       RETURN(1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   FREE RECORD current_lock_data
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (unlocknoteinternal(scdstoryid=f8) =i2 WITH protect)
  UPDATE  FROM scd_story n
   SET n.update_lock_user_id = 0.0, n.update_lock_dt_tm = null, n.updt_cnt = (n.updt_cnt+ 1),
    n.updt_id = reqinfo->updt_id, n.updt_dt_tm = cnvtdatetime(sysdate), n.updt_task = reqinfo->
    updt_task,
    n.updt_applctx = reqinfo->updt_applctx
   WHERE n.scd_story_id=scdstoryid
   WITH nocounter
  ;end update
  IF (curqual=0)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE updatedatatypetermdata(null)
  UPDATE  FROM scd_term_data td,
    (dummyt d  WITH seq = req_qual_size)
   SET td.value_number = 1
   PLAN (d)
    JOIN (td
    WHERE (td.scd_term_data_id=term_data_req->qual[d.seq].scd_term_data_id)
     AND td.scd_term_data_type_cd=term_data_type_data
     AND td.scd_term_data_key=term_data_key_dictate)
   WITH nocounter
  ;end update
  IF (curqual != req_qual_size)
   CALL addfailure(efailunknown,"Unable to Update INFOGEN Term Data")
   CALL updatestatusdata("F","UpdateInfoGenTermData","SCD_TERM_DATA",
    "Unable to Update INFOGEN Term Data")
  ENDIF
 END ;Subroutine
 SUBROUTINE validatedictationcount(null)
  SELECT INTO "nl:"
   FROM scd_term term,
    scd_term_data data
   PLAN (term
    WHERE term.scd_story_id=scdstoryid)
    JOIN (data
    WHERE term.scd_term_data_id=data.scd_term_data_id
     AND data.scd_term_data_type_cd=term_data_type_data
     AND data.scd_term_data_key=term_data_key_dictate
     AND data.value_number=0)
   DETAIL
    dictated_term_cnt += 1
    IF (dictated_term_cnt > size(term_data_req->qual,5))
     stat = alterlist(term_data_req->qual,(dictated_term_cnt+ 10))
    ENDIF
    term_data_req->qual[dictated_term_cnt].scd_term_id = term.scr_term_id, term_data_req->qual[
    dictated_term_cnt].event_id = term.event_id, term_data_req->qual[dictated_term_cnt].
    scd_term_data_id = data.scd_term_data_id,
    term_data_req->qual[dictated_term_cnt].scd_term_data_key = data.scd_term_data_key, term_data_req
    ->qual[dictated_term_cnt].fkey_entity_name = data.fkey_entity_name, term_data_req->qual[
    dictated_term_cnt].fkey_id = data.fkey_id,
    term_data_req->qual[dictated_term_cnt].value_number = data.value_number, term_data_req->qual[
    dictated_term_cnt].scd_term_data_type_cd = data.scd_term_data_type_cd
   FOOT REPORT
    stat = alterlist(term_data_req->qual,dictated_term_cnt)
   WITH nocounter
  ;end select
  IF (dictated_term_cnt != req_qual_size)
   CALL addfailure(efailcountmismatch,
    "Text Segments submitted not equal to number of dications expected for document")
   CALL updatestatusdata("F","ValidateDictationCount","SCD_TERM_DATA",
    "Validate Dictation Count Error.")
  ENDIF
 END ;Subroutine
 SUBROUTINE ensureblobs(null)
   DECLARE blob_index = i4 WITH noconstant(0)
   DECLARE chunck_cnt = i4 WITH noconstant(0)
   DECLARE chunck_index = i4 WITH noconstant(0)
   FREE RECORD ensure_req
   FREE RECORD ensure_reply
   FOR (blob_index = 1 TO req_qual_size)
     SET chunck_cnt = 0
     RECORD ensure_req(
       1 action_type = c3
       1 scd_blob_id = f8
       1 format_cd = f8
       1 long_blobs[*]
         2 long_blob = vgc
         2 sequence_number = i4
         2 blob_length = i4
     )
     RECORD ensure_reply(
       1 scd_blob_id = f8
       1 status_data
         2 status = c1
         2 subeventstatus[1]
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
     SET ensure_req->format_cd = request->qual[blob_index].format_cd
     SET chunck_cnt = size(request->qual[blob_index].blob_qual,5)
     SET stat = alterlist(ensure_req->long_blobs,chunck_cnt)
     FOR (chunck_index = 1 TO chunck_cnt)
       SET ensure_req->long_blobs[chunck_index].long_blob = request->qual[blob_index].blob_qual[
       chunck_index].blob
     ENDFOR
     EXECUTE cps_ens_scd_blob  WITH replace("REQUEST","ENSURE_REQ"), replace("REPLY","ENSURE_REPLY")
     IF ((ensure_reply->status_data.status="F"))
      CALL addfailure(efailunknown,"FAIL IN ENSUREBLOB()")
      CALL updatestatusdata("F","EnsureBlobs","SCD_BLOB","Unable to Ensure Text Blobs")
      RETURN
     ENDIF
     FOR (term_index = 1 TO dictated_term_cnt)
       IF ((((term_data_req->qual[term_index].event_id=request->qual[blob_index].event_id)) OR ((
       term_data_req->qual[term_index].scd_term_id=request->qual[blob_index].scd_term_id))) )
        SET term_data_req->qual[term_index].fkey_entity_name = "SCD_BLOB"
        SET term_data_req->qual[term_index].fkey_id = ensure_reply->scd_blob_id
        SET term_index = dictated_term_cnt
       ENDIF
     ENDFOR
     FREE RECORD ensure_req
     FREE RECORD ensure_reply
   ENDFOR
 END ;Subroutine
 SUBROUTINE insertscdblobtermdata(null)
  INSERT  FROM scd_term_data td,
    (dummyt d  WITH seq = value(req_qual_size))
   SET td.scd_term_data_id = term_data_req->qual[d.seq].scd_term_data_id, td.scd_term_data_type_cd =
    term_data_type_infonote, td.scd_term_data_key = term_data_key_rtf,
    td.fkey_id = term_data_req->qual[d.seq].fkey_id, td.fkey_entity_name = term_data_req->qual[d.seq]
    .fkey_entity_name
   PLAN (d)
    JOIN (td)
   WITH nocounter
  ;end insert
  IF (curqual != req_qual_size)
   CALL addfailure(efailtablefull,"Insert to SCD_Term_Data For new BLOB failed")
   CALL updatestatusdata("F","InsertSCDBlobTermData","SCD_TERM_DATA",
    "Insert to SCD_Term_Data For new BLOB failed")
  ENDIF
 END ;Subroutine
 SUBROUTINE (addfailure(status_failure_flag=i2,failure_reason=vc) =null)
   SET ensure_failure = status_failure_flag
   SET ensure_fail_cnt = (size(reply->ensure_failures,5)+ 1)
   SET stat = alterlist(reply->ensure_failures,ensure_fail_cnt)
   SET reply->ensure_failures[ensure_fail_cnt].status_failure_flag = status_failure_flag
   SET reply->ensure_failures[ensure_fail_cnt].failure_reason = failure_reason
 END ;Subroutine
 SUBROUTINE updatestorystatus(null)
  UPDATE  FROM scd_story
   SET story_completion_status_cd = story_status_trans
   WHERE scd_story_id=scdstoryid
   WITH nocounter
  ;end update
  IF (curqual != 1)
   CALL addfailure(efailunknown,"Unable to Update Story Status")
   CALL updatestatusdata("F","UpdateStoryStatus","SCD_STORY","Unable to Update Story Status")
  ENDIF
 END ;Subroutine
 SUBROUTINE releaselock(null)
   DECLARE irtn = i2 WITH noconstant(0)
   SET irtn = unlocknoteinternal(scdstoryid)
   IF (irtn > 0)
    CALL addfailure(efailunknown,"Unable to Unlock Sct Story")
    CALL updatestatusdata("F","ReleaseLock","SCD_STORY","Unalbe to Release Story Lock")
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatestatusdata(sstatus=c1,soperationname=vc,stargetname=vc,stargetvalue=vc) =null)
   DECLARE error_cnt = i4 WITH noconstant(0)
   SET error_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,error_cnt)
   SET reply->status_data.subeventstatus[error_cnt].operationname = soperationname
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = sstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = stargetname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = stargetvalue
 END ;Subroutine
END GO
