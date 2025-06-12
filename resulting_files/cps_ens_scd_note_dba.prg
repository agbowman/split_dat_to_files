CREATE PROGRAM cps_ens_scd_note:dba
 IF (validate(reply,"0")="0")
  RECORD reply(
    1 notes[*]
      2 scd_story_id = f8
      2 update_lock_dt_tm = dq8
      2 event_id = f8
      2 paragraphs[*]
        3 scd_paragraph_id = f8
        3 event_id = f8
      2 sentences[*]
        3 scd_sentence_id = f8
      2 terms[*]
        3 scd_term_id = f8
        3 event_id = f8
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
 ENDIF
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
 IF (size(request->notes,5)=0)
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No NOTES specified",cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 FREE RECORD temp_term_ids
 RECORD temp_term_ids(
   1 term_ids[*]
     2 scd_term_id = f8
 )
 FREE RECORD terms_batch_for_insert
 RECORD terms_batch_for_insert(
   1 cur_term_count = i4
   1 terms[*]
     2 scd_term_id = f8
     2 scr_term_id = f8
     2 scd_sentence_id = f8
     2 scr_term_hier_id = f8
     2 scd_term_data_id = f8
     2 sequence_number = i4
     2 concept_source_cd = f8
     2 concept_identifier = vc
     2 concept_cki = vc
     2 truth_state_cd = f8
     2 scr_phrase_id = f8
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 parent_scd_term_id = f8
     2 active_ind = i2
     2 event_id = f8
     2 modify_prsnl_id = f8
 )
 FREE RECORD term_data_batch_for_insert
 RECORD term_data_batch_for_insert(
   1 cur_data_cnt = i4
   1 term_data[*]
     2 scd_term_data_type_cd = f8
     2 scd_term_data_key = vc
     2 fkey_id = f8
     2 fkey_entity_name = vc
     2 value_number = f8
     2 value_dt_tm = dq8
     2 value_dt_tm_os = f8
     2 value_tz = i4
     2 value_text = vc
     2 units_cd = f8
     2 scd_term_id = f8
 )
 FREE RECORD temp_sentence
 RECORD temp_sentence(
   1 sentences[*]
     2 scd_sentence_id = f8
     2 canonical_sentence_pattern_id = f8
     2 scr_term_hier_id = f8
     2 author_persnl_id = f8
     2 scd_paragraph_id = f8
     2 scd_story_id = f8
     2 sequence_number = i4
     2 can_sent_pat_cki_source = c12
     2 can_sent_pat_cki_identifier = vc
     2 sentence_class_cd = f8
     2 sentence_topic_cd = f8
     2 text_format_rule_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 updt_cnt = i4
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 updt_task = i4
     2 updt_applctx = f8
 )
 FREE RECORD para_batch_for_insert
 RECORD para_batch_for_insert(
   1 number_para_cnt = i4
   1 paras[*]
     2 scd_paragraph_id = f8
     2 scd_story_id = f8
     2 scr_paragraph_type_id = f8
     2 sequence_number = i4
     2 paragraph_class_cd = f8
     2 truth_state_cd = f8
     2 event_id = f8
     2 scd_term_data_id = f8
     2 action_type = c3
 )
 FREE RECORD temp_new_sentences
 RECORD temp_new_sentences(
   1 sentences[*]
     2 sent_index = f8
 )
 FREE RECORD temp_upd_sentences
 RECORD temp_upd_sentences(
   1 sentences[*]
     2 sent_idx = f8
     2 updateterms = i4
 )
 FREE RECORD paragraphstoupdate
 RECORD paragraphstoupdate(
   1 paras[*]
     2 note_index = i4
     2 par_index = i4
 )
 DECLARE addnonstoryitems(note_type=i2,scdnotedataid=f8) = null WITH protect
 DECLARE addnote(null) = null WITH protect
 DECLARE addsentence(sent_idx=i4) = null WITH protect
 DECLARE checklocked(null) = i2 WITH protect
 DECLARE checkoneventrepstatus(null) = i2 WITH protect
 DECLARE deletenote(null) = null WITH protect
 DECLARE ensureblobstructure(null) = null WITH protect
 DECLARE addsentencetobatch(sent_idx=i4) = null WITH protect
 DECLARE inserttermdatabatch(null) = null WITH protect
 DECLARE insertterms(null) = i2 WITH protect
 DECLARE populaterequestcodevalues(null) = null WITH protect
 DECLARE scdgetuniqueactivityid(null) = f8 WITH protect
 DECLARE unlocknote(null) = null WITH protect
 DECLARE updateparagraphs(null) = null WITH protect
 DECLARE updateprenote(null) = null WITH protect
 DECLARE updateterms(null) = null WITH protect
 DECLARE storecrossrefmmfdata(index=i4,smmfid=vc,iversion=i4) = null WITH protect
 DECLARE insertparagraphbatch(null) = null WITH protect
 EXECUTE dmsmanagementrtl
 DECLARE uar_srv_createproplist() = i4 WITH image_axp = "srvcore", image_aix =
 "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreatePropList"
 DECLARE uar_srv_setpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref)) = i4 WITH image_axp = "srvcore",
 image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropString"
 DECLARE uar_srv_setpropint(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp = "srvcore",
 image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropInt"
 DECLARE uar_srv_setpropreal(p1=i4(value),p2=vc(ref),p3=f8(value)) = i4 WITH image_axp = "srvcore",
 image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropReal"
 DECLARE uar_srv_setprophandle(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH image_axp
  = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropHandle"
 DECLARE uar_srv_closehandle(p1=i4(value)) = i4 WITH image_axp = "srvcore", image_aix =
 "libsrvcore.a(libsrvcore.o)", uar = "SRV_CloseHandle"
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE retval = i2 WITH protect, noconstant(0)
 DECLARE update_cnt = i4 WITH protect, noconstant(0)
 DECLARE unique_id = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE number_para_data = i4 WITH protect, noconstant(0)
 DECLARE scd_paragraph_idx = i4 WITH protect, noconstant(0)
 DECLARE parent_scd_term_idx = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH public, noconstant(fillstring(150," "))
 DECLARE table_name = vc WITH public, noconstant(fillstring(50," "))
 DECLARE errcnt = i4 WITH public, noconstant(0)
 DECLARE batch_term_data_cnt = i4 WITH public, noconstant(0)
 DECLARE numparastoupdate = i4 WITH public, noconstant(0)
 DECLARE delete_term_baggage = i2 WITH protect, constant(0)
 DECLARE keep_term_baggage = i2 WITH protect, constant(1)
 DECLARE inactive = i2 WITH protect, constant(0)
 DECLARE active = i2 WITH protect, constant(1)
 DECLARE note_type_pre = i2 WITH protect, constant(0)
 DECLARE note_type_other = i2 WITH protect, constant(1)
 DECLARE term_type_para = i2 WITH protect, constant(0)
 DECLARE term_type_term = i2 WITH protect, constant(1)
 DECLARE term_type_note = i2 WITH protect, constant(2)
 DECLARE number_notes = i4 WITH protect, constant(size(request->notes,5))
 DECLARE prev_doc_state_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",15751,"PREVDOC"))
 DECLARE event_rep_status = i2 WITH protect, constant(checkoneventrepstatus(null))
 DECLARE eadd = i2 WITH protect, constant(1)
 DECLARE epurgedictation = i2 WITH protect, constant(3)
 DECLARE edel = i2 WITH protect, constant(4)
 DECLARE etimestamp = i2 WITH protect, constant(5)
 DECLARE term_data_type_dictatedfile = f8 WITH constant(uar_get_code_by("MEANING",15752,
   "DICTATEDFILE"))
 DECLARE term_data_type_data = f8 WITH constant(uar_get_code_by("MEANING",15752,"DATA"))
 DECLARE term_data_type_infogen = f8 WITH constant(uar_get_code_by("MEANING",15752,"INFOGEN"))
 DECLARE term_data_key_dictate = c7 WITH constant("DICTATE")
 DECLARE xref_transaction = c29 WITH constant("transaction")
 DECLARE xref_entity_name = c29 WITH constant("entityName")
 DECLARE xref_entity_id = c26 WITH constant("entityId")
 DECLARE sotry_completion_status_singed = f8 WITH protect, constant(uar_get_code_by("MEANING",15750,
   "SIGNED"))
 IF (failed=1)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF (((prev_doc_state_cd=0.0) OR ((prev_doc_state_cd=- (1.0)))) )
  SET failed = 1
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning PRESENT from code_set 15749"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->notes,number_notes)
 SET term_data_batch_for_insert->cur_data_cnt = 0
 FOR (note_index = 1 TO number_notes)
   CASE (request->notes[note_index].action_type)
    OF "ADD":
     IF ((request->notes[note_index].event_id=0))
      SET request->notes[note_index].event_id = geteventids(request->notes[note_index].reference_nbr)
      IF (failed=1)
       GO TO exit_script
      ENDIF
     ENDIF
     CALL ensureblobstructure(null)
     IF (failed=0)
      CALL addnote(null)
      IF (failed=0)
       CALL ensuredictationdata(eadd,note_index)
      ENDIF
     ENDIF
    OF "UPD":
     IF ((request->notes[note_index].event_id=0))
      SET request->notes[note_index].event_id = geteventids(request->notes[note_index].reference_nbr)
      IF (failed=1)
       GO TO exit_script
      ENDIF
     ENDIF
     CALL ensureblobstructure(null)
     IF (failed=0)
      CALL updatenote(delete_term_baggage)
      IF (failed=0)
       CALL ensuredictationdata(eadd,note_index)
      ENDIF
     ENDIF
    OF "REP":
     CALL deletenote(null)
     IF (failed=0)
      CALL ensureblobstructure(null)
      IF (failed=0)
       CALL addnote(null)
       IF (failed=0)
        CALL ensuredictationdata(eadd,note_index)
       ENDIF
      ENDIF
     ENDIF
    OF "DEL":
     CALL deletenote(null)
     IF (failed=0)
      CALL ensuredictationdata(epurgedictation,note_index)
     ENDIF
    OF "UNL":
     CALL unlocknote(null)
     IF (failed=0)
      CALL ensuredictationdata(etimestamp,note_index)
     ENDIF
    OF "IAV":
     CALL setnotestatus(reqdata->deleted_cd,inactive)
    OF "ATV":
     CALL setnotestatus(reqdata->active_status_cd,active)
    OF "MOD":
     CALL ensureblobstructure(null)
     IF (failed=0)
      CALL updatenote(keep_term_baggage)
      IF (failed=0)
       CALL ensuredictationdata(eadd,note_index)
      ENDIF
     ENDIF
    ELSE
     SET failed = 1
     CALL cps_add_error(cps_inval_data,cps_script_fail,"Unrecognized note action type",
      cps_inval_data_msg,note_index,
      0,0)
     GO TO exit_script
   ENDCASE
   SET reply->notes[note_index].event_id = request->notes[note_index].event_id
   IF (failed=1)
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 FREE RECORD temp_term_ids
 FREE RECORD terms_batch_for_insert
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  IF (textlen(trim(serrmsg)) > 0)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ENDIF
  CALL echorecord(request)
 ENDIF
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
 SUBROUTINE (findcodevaluebymeaning(codeset=i4,meaning=vc) =f8 WITH protect)
   DECLARE codevalue = f8 WITH noconstant(0.0)
   IF (textlen(trim(meaning)) > 0)
    SET codevalue = uar_get_code_by("MEANING",codeset,nullterm(meaning))
    IF ((((codevalue=- (1.0))) OR (codevalue=0.0)) )
     SET table_name = "CODE_VALUE"
     SET serrmsg = build("Failed to find (or found duplicates of) the code_value for cdf_meaning '",
      meaning,"'from code_set: ",codeset)
     SET failed = 1
    ENDIF
   ELSE
    SET codevalue = 0.0
   ENDIF
   RETURN(codevalue)
 END ;Subroutine
 SUBROUTINE ensureblobstructure(null)
   DECLARE blobs_cnt = i4 WITH private, constant(size(request->notes[note_index].blobs,5))
   DECLARE blob_para_idx = i4 WITH protect, noconstant(0)
   DECLARE blob_term_idx = i4 WITH protect, noconstant(0)
   DECLARE blob_term_data_idx = i4 WITH protect, noconstant(0)
   DECLARE blob_format_mean = vc WITH protect, noconstant("")
   DECLARE chunk_cnt = i4 WITH private, noconstant(0)
   IF (failed=1)
    RETURN
   ENDIF
   IF (blobs_cnt=0)
    RETURN
   ENDIF
   FOR (blob_index = 1 TO blobs_cnt)
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
     SET blob_term_data_idx = request->notes[note_index].blobs[blob_index].term_data_idx
     SET blob_para_idx = request->notes[note_index].blobs[blob_index].para_idx
     SET blob_term_idx = request->notes[note_index].blobs[blob_index].term_idx
     IF (blob_para_idx > 0)
      SET blob_format_mean = request->notes[note_index].paragraphs[blob_para_idx].para_term_data[
      blob_term_data_idx].format_mean
     ELSEIF (blob_term_idx > 0)
      SET blob_format_mean = request->notes[note_index].terms[blob_term_idx].term_data[
      blob_term_data_idx].format_mean
     ELSE
      SET blob_format_mean = request->notes[note_index].note_term_data[blob_term_data_idx].
      format_mean
     ENDIF
     SET ensure_req->format_cd = findcodevaluebymeaning(23,nullterm(blob_format_mean))
     SET chunk_cnt = size(request->notes[note_index].blobs[blob_index].qual,5)
     SET stat = alterlist(ensure_req->long_blobs,chunk_cnt)
     FOR (chunk_index = 1 TO chunk_cnt)
       SET ensure_req->long_blobs[chunk_index].long_blob = notrim(request->notes[note_index].blobs[
        blob_index].qual[chunk_index].chunk)
     ENDFOR
     EXECUTE cps_ens_scd_blob  WITH replace("REQUEST","ENSURE_REQ"), replace("REPLY","ENSURE_REPLY")
     IF ((ensure_reply->status_data.status="F"))
      SET failed = 1
      CALL echo("CPS_ENS_SCD_BLOB FAILED")
      CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING BLOB",cps_insert_msg,blob_index,
       0,0)
      RETURN
     ENDIF
     IF (blob_para_idx > 0)
      SET request->notes[note_index].paragraphs[blob_para_idx].para_term_data[blob_term_data_idx].
      fkey_entity_name = "SCD_BLOB"
      SET request->notes[note_index].paragraphs[blob_para_idx].para_term_data[blob_term_data_idx].
      fkey_id = ensure_reply->scd_blob_id
     ELSEIF (blob_term_idx > 0)
      SET request->notes[note_index].terms[blob_term_idx].term_data[blob_term_data_idx].
      fkey_entity_name = "SCD_BLOB"
      SET request->notes[note_index].terms[blob_term_idx].term_data[blob_term_data_idx].fkey_id =
      ensure_reply->scd_blob_id
     ELSE
      SET request->notes[note_index].note_term_data[blob_term_data_idx].fkey_entity_name = "SCD_BLOB"
      SET request->notes[note_index].note_term_data[blob_term_data_idx].fkey_id = ensure_reply->
      scd_blob_id
     ENDIF
     FREE RECORD ensure_req
     FREE RECORD ensure_reply
   ENDFOR
 END ;Subroutine
 SUBROUTINE addnote(null)
   IF (failed=1)
    RETURN
   ENDIF
   DECLARE note_term_data_cnt = i4 WITH private, constant(size(request->notes[note_index].
     note_term_data,5))
   DECLARE note_type = i2 WITH private, constant(getnotetype(note_index))
   DECLARE new_story_id = f8 WITH protect, noconstant(scdgetuniqueactivityid(null))
   DECLARE update_lock_dt_tm = f8
   DECLARE scd_note_term_data_id = f8 WITH protect, noconstant(0.0)
   IF (note_term_data_cnt > 0)
    SET scd_note_term_data_id = scdgetuniqueactivityid(null)
    CALL addtermdatatobatch(note_index,- (1),note_term_data_cnt,term_type_note,scd_note_term_data_id)
    IF (failed=1)
     RETURN
    ENDIF
   ENDIF
   SET reply->notes[note_index].scd_story_id = new_story_id
   SET update_lock_dt_tm = cnvtdatetime(sysdate)
   IF ((request->notes[note_index].keep_lock_ind=1))
    SET reply->notes[note_index].update_lock_dt_tm = update_lock_dt_tm
   ELSE
    SET reply->notes[note_index].update_lock_dt_tm = null
   ENDIF
   CALL populaterequestcodevalues(null)
   IF (failed=1)
    RETURN
   ENDIF
   IF (note_type=note_type_pre)
    SET request->notes[note_index].event_id = 0
    SET request->notes[note_index].encounter_id = 0
    SET request->notes[note_index].person_id = 0
   ENDIF
   INSERT  FROM scd_story n
    SET n.scd_story_id = new_story_id, n.story_type_cd = request->notes[note_index].story_type_cd, n
     .title = request->notes[note_index].title,
     n.author_id = request->notes[note_index].author_id, n.event_id = request->notes[note_index].
     event_id, n.encounter_id = request->notes[note_index].encounter_id,
     n.person_id = request->notes[note_index].person_id, n.story_completion_status_cd = request->
     notes[note_index].story_completion_status_cd, n.update_lock_user_id =
     IF ((request->notes[note_index].keep_lock_ind=1)) reqinfo->updt_id
     ELSE 0.0
     ENDIF
     ,
     n.update_lock_dt_tm = cnvtdatetime(reply->notes[note_index].update_lock_dt_tm), n.active_ind = 1,
     n.active_status_cd = reqdata->active_status_cd,
     n.active_status_dt_tm = cnvtdatetime(sysdate), n.active_status_prsnl_id = reqinfo->updt_id, n
     .updt_cnt = 0,
     n.updt_id = reqinfo->updt_id, n.updt_dt_tm = cnvtdatetime(sysdate), n.updt_task = reqinfo->
     updt_task,
     n.updt_applctx = reqinfo->updt_applctx, n.entry_mode_cd = request->notes[note_index].
     entry_mode_cd, n.scd_term_data_id = scd_note_term_data_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING STORY",cps_insert_msg,note_index,
     0,0)
    RETURN
   ENDIF
   CALL addnonstoryitems(note_type)
   IF ((term_data_batch_for_insert->cur_data_cnt > 0))
    CALL inserttermdatabatch(null)
    IF (failed=1)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE populaterequestcodevalues(null)
   IF ((request->notes[note_index].story_type_cd=0.0))
    SET request->notes[note_index].story_type_cd = findcodevaluebymeaning(15749,nullterm(request->
      notes[note_index].story_type_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"STORY TYPE",cps_inval_data_msg,note_index,
      0,0)
     RETURN
    ENDIF
   ENDIF
   IF ((request->notes[note_index].story_completion_status_cd=0.0))
    SET request->notes[note_index].story_completion_status_cd = findcodevaluebymeaning(15750,nullterm
     (request->notes[note_index].story_completion_status_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"STORY COMPLETION STATUS",cps_inval_data_msg,
      note_index,
      0,0)
     RETURN
    ENDIF
   ENDIF
   IF ((request->notes[note_index].entry_mode_cd=0))
    SET request->notes[note_index].entry_mode_cd = findcodevaluebymeaning(29520,nullterm(request->
      notes[note_index].entry_mode_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"ENTRY MODE",cps_inval_data_msg,note_index,
      0,0)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addnonstoryitems(note_type)
   DECLARE pattern_id_cnt = i4 WITH private, constant(size(request->notes[note_index].scr_pattern_id,
     5))
   DECLARE paragraph_id_cnt = i4 WITH private, constant(size(request->notes[note_index].paragraphs,5)
    )
   DECLARE sentence_cnt = i4 WITH protect, constant(size(request->notes[note_index].sentences,5))
   IF (pattern_id_cnt=0
    AND (request->notes[note_index].story_type_mean != "PREPARA")
    AND (request->notes[note_index].story_type_mean != "PRESENT")
    AND (request->notes[note_index].story_type_mean != "PRETERM"))
    SET failed = 1
    CALL cps_add_error(cps_insuf_data,cps_script_fail,"No PATTERNS specified",cps_insuf_data_msg,0,
     0,0)
    RETURN
   ENDIF
   IF (pattern_id_cnt != 0)
    CALL insertstorypattern(pattern_id_cnt,reply->notes[note_index].scd_story_id)
    IF (failed=1)
     RETURN
    ENDIF
   ENDIF
   IF (paragraph_id_cnt > 0)
    SET stat = alterlist(reply->notes[note_index].paragraphs,paragraph_id_cnt)
    CALL insertallparagraphs(note_index)
    IF (failed=1)
     RETURN
    ENDIF
   ENDIF
   SET stat = alterlist(reply->notes[note_index].sentences,sentence_cnt)
   SET stat = initrec(temp_new_sentences)
   SET stat = alterlist(temp_new_sentences->sentences,sentence_cnt)
   FOR (sent_cur = 1 TO sentence_cnt)
     SET temp_new_sentences->sentences[sent_cur].sent_index = sent_cur
   ENDFOR
   IF (sentence_cnt > 0)
    CALL insertsentencebatch(sentence_cnt)
   ENDIF
   CALL insertterms(null)
   IF (failed=1)
    RETURN
   ENDIF
   CALL insertconcepts(note_index)
   IF (note_type=note_type_pre)
    CALL updatestoryorg(reply->notes[note_index].scd_story_id,request->notes[note_index].author_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatenote(updateterms=i2) =null WITH protect)
   DECLARE note_term_data_cnt = i4 WITH private, constant(size(request->notes[note_index].
     note_term_data,5))
   DECLARE pattern_id_cnt = i4 WITH private, constant(size(request->notes[note_index].scr_pattern_id,
     5))
   DECLARE paragraph_id_cnt = i4 WITH private, constant(size(request->notes[note_index].paragraphs,5)
    )
   DECLARE sentence_cnt = i4 WITH private, constant(size(request->notes[note_index].sentences,5))
   DECLARE para_action_type = c3 WITH private, noconstant("NUL")
   DECLARE del_para_term_data_id = f8 WITH protect, noconstant(0.0)
   DECLARE note_type = i2 WITH private, constant(getnotetype(note_index))
   DECLARE scd_note_term_data_id = f8 WITH protect, noconstant(0.0)
   IF (note_type=note_type_pre)
    CALL updateprenote(null)
    RETURN
   ENDIF
   CALL deletenotebaggage(request->notes[note_index].scd_story_id)
   IF (note_term_data_cnt > 0)
    SET scd_note_term_data_id = scdgetuniqueactivityid(null)
    CALL addtermdatatobatch(note_index,- (1),note_term_data_cnt,term_type_note,scd_note_term_data_id)
    IF (failed=1)
     RETURN
    ENDIF
   ENDIF
   SET reply->notes[note_index].scd_story_id = request->notes[note_index].scd_story_id
   IF ((request->notes[note_index].keep_lock_ind=1))
    SET reply->notes[note_index].update_lock_dt_tm = cnvtdatetime(sysdate)
   ELSE
    SET reply->notes[note_index].update_lock_dt_tm = null
   ENDIF
   SET update_cnt = 0
   FREE RECORD lock_data
   RECORD lock_data(
     1 story_id = f8
     1 actn_type = c3
     1 update_lock_dt_tm = dq8
     1 note_index = i4
   )
   SET lock_data->story_id = request->notes[note_index].scd_story_id
   SET lock_data->actn_type = request->notes[note_index].action_type
   SET lock_data->update_lock_dt_tm = request->notes[note_index].update_lock_dt_tm
   SET lock_data->note_index = note_index
   DECLARE irtn = i2 WITH noconstant(0)
   SET irtn = checklocked(null)
   FREE RECORD lock_data
   IF (irtn > 0)
    SET failed = 1
    SET reply->status_data.status = "F"
    CALL cps_add_error(cps_update,cps_script_fail,"Failed to ensure as the document is locked",
     cps_update_msg,0,
     0,0)
    RETURN
   ENDIF
   SET update_cnt += 1
   CALL populaterequestcodevalues(null)
   IF (failed=1)
    RETURN
   ENDIF
   UPDATE  FROM scd_story n
    SET n.story_type_cd = request->notes[note_index].story_type_cd, n.title = request->notes[
     note_index].title, n.author_id = request->notes[note_index].author_id,
     n.event_id = request->notes[note_index].event_id, n.encounter_id = request->notes[note_index].
     encounter_id, n.person_id = request->notes[note_index].person_id,
     n.story_completion_status_cd = request->notes[note_index].story_completion_status_cd, n
     .update_lock_user_id =
     IF ((request->notes[note_index].keep_lock_ind=0)) 0.0
     ELSE reqinfo->updt_id
     ENDIF
     , n.update_lock_dt_tm = cnvtdatetime(reply->notes[note_index].update_lock_dt_tm),
     n.updt_cnt = update_cnt, n.updt_id = reqinfo->updt_id, n.updt_dt_tm = cnvtdatetime(sysdate),
     n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->updt_applctx, n.entry_mode_cd =
     request->notes[note_index].entry_mode_cd,
     n.scd_term_data_id = scd_note_term_data_id
    WHERE (n.scd_story_id=request->notes[note_index].scd_story_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_update,cps_script_fail,"UPDATING STORY",cps_update_msg,note_index,
     0,0)
    RETURN
   ENDIF
   IF (pattern_id_cnt=0
    AND (request->notes[note_index].story_type_mean != "PREPARA")
    AND (request->notes[note_index].story_type_mean != "PRESENT")
    AND (request->notes[note_index].story_type_mean != "PRETERM"))
    SET failed = 1
    CALL cps_add_error(cps_insuf_data,cps_script_fail,"No PATTERNS specified",cps_insuf_data_msg,0,
     0,0)
    RETURN
   ENDIF
   IF (pattern_id_cnt != 0)
    DELETE  FROM scd_story_pattern s
     WHERE (s.scd_story_id=request->notes[note_index].scd_story_id)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET failed = 1
     CALL cps_add_error(cps_delete,cps_script_fail,"DELETING OLD STORY_PATTERNS",cps_delete_msg,
      note_index,
      0,0)
     RETURN
    ENDIF
    CALL insertstorypattern(pattern_id_cnt,request->notes[note_index].scd_story_id)
    IF (failed=1)
     RETURN
    ENDIF
   ENDIF
   SET stat = alterlist(reply->notes[note_index].paragraphs,paragraph_id_cnt)
   SET stat = initrec(para_batch_for_insert)
   SET para_batch_for_insert->number_para_cnt = 0
   SET stat = alterlist(para_batch_for_insert->paras,paragraph_id_cnt)
   SET stat = alterlist(paragraphstoupdate->paras,paragraph_id_cnt)
   FOR (par_index = 1 TO paragraph_id_cnt)
     SET unique_id = request->notes[note_index].paragraphs[par_index].scd_paragraph_id
     SET number_para_data = 0
     IF (unique_id != 0.0)
      SET numparastoupdate += 1
      SET paragraphstoupdate->paras[numparastoupdate].note_index = note_index
      SET paragraphstoupdate->paras[numparastoupdate].par_index = par_index
     ELSE
      CALL prepparabatchforinsert(note_index,par_index)
      IF (failed=1)
       RETURN
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(paragraphstoupdate->paras,numparastoupdate)
   SET stat = alterlist(para_batch_for_insert->paras,(paragraph_id_cnt - numparastoupdate))
   CALL updateparagraphs(null)
   CALL insertparagraphbatch(null)
   SET stat = alterlist(reply->notes[note_index].sentences,sentence_cnt)
   SET stat = initrec(temp_new_sentences)
   SET stat = initrec(temp_upd_sentences)
   DECLARE sent_indx = i4 WITH private, noconstant(0)
   DECLARE num_sentences_to_add = i4 WITH protect, noconstant(0)
   DECLARE num_sentences_to_update = i4 WITH protect, noconstant(0)
   SET stat = alterlist(temp_new_sentences->sentences,sentence_cnt)
   SET stat = alterlist(temp_upd_sentences->sentences,sentence_cnt)
   FOR (sent_indx = 1 TO sentence_cnt)
     CASE (request->notes[note_index].sentences[sent_indx].action_type)
      OF "ADD":
       SET num_sentences_to_add += 1
       SET temp_new_sentences->sentences[num_sentences_to_add].sent_index = sent_indx
      OF "UPD":
       SET num_sentences_to_update += 1
       SET temp_upd_sentences->sentences[num_sentences_to_update].sent_idx = sent_indx
       SET temp_upd_sentences->sentences[num_sentences_to_update].updateterms = updateterms
      OF "DEL":
       CALL deletesentence(sent_indx)
      ELSE
       SET failed = 1
       CALL cps_add_error(cps_inval_data,cps_script_fail,"Unrecognized Sentence action type",
        cps_inval_data_msg,note_index,
        sent_indx,0)
       RETURN
     ENDCASE
   ENDFOR
   IF (num_sentences_to_add > 0)
    CALL insertsentencebatch(num_sentences_to_add)
   ENDIF
   IF (num_sentences_to_update > 0)
    CALL updatebatchedsentences(num_sentences_to_update)
   ENDIF
   IF (failed=1)
    RETURN
   ENDIF
   IF (updateterms=keep_term_baggage)
    CALL updateterms(null)
   ELSE
    CALL insertterms(null)
   ENDIF
   IF (failed=1)
    RETURN
   ENDIF
   FOR (par_index = 1 TO paragraph_id_cnt)
    SET para_action_type = request->notes[note_index].paragraphs[par_index].action_type
    IF (para_action_type != "ADD"
     AND para_action_type != "DEL"
     AND para_action_type != "UPD")
     SET num_sent = 0
     SELECT INTO "NL:"
      cnt = count(*)
      FROM scd_sentence s
      WHERE (s.scd_paragraph_id=reply->notes[note_index].paragraphs[par_index].scd_paragraph_id)
       AND (s.scd_story_id=request->notes[note_index].scd_story_id)
      DETAIL
       num_sent = cnt
      WITH nocounter
     ;end select
     IF (num_sent=0
      AND (reply->notes[note_index].paragraphs[par_index].scd_paragraph_id != 0.0))
      DELETE  FROM scd_paragraph p
       WHERE (p.scd_paragraph_id=reply->notes[note_index].paragraphs[par_index].scd_paragraph_id)
       WITH nocounter
      ;end delete
      SET reply->notes[note_index].paragraphs[par_index].scd_paragraph_id = 0.0
     ENDIF
    ELSE
     IF (para_action_type="DEL")
      SET del_para_term_data_id = 0.0
      SELECT INTO "NL:"
       FROM scd_paragraph para
       WHERE (para.scd_paragraph_id=reply->notes[note_index].paragraphs[par_index].scd_paragraph_id)
       DETAIL
        del_para_term_data_id = para.scd_term_data_id
       WITH nocounter
      ;end select
      IF (del_para_term_data_id != 0.0)
       DELETE  FROM scd_term_data
        WHERE scd_term_data_id=del_para_term_data_id
        WITH nocounter
       ;end delete
      ENDIF
      IF ((reply->notes[note_index].paragraphs[par_index].scd_paragraph_id != 0.0))
       DELETE  FROM scd_paragraph p
        WHERE (p.scd_paragraph_id=reply->notes[note_index].paragraphs[par_index].scd_paragraph_id)
        WITH nocounter
       ;end delete
      ENDIF
      SET reply->notes[note_index].paragraphs[par_index].scd_paragraph_id = 0.0
     ENDIF
    ENDIF
   ENDFOR
   IF ((term_data_batch_for_insert->cur_data_cnt > 0))
    CALL inserttermdatabatch(null)
   ENDIF
   CALL updateconcepts(note_index)
   CALL deleteautosavednoteblob(note_index)
 END ;Subroutine
 SUBROUTINE updateprenote(null)
   SET request->notes[note_index].event_id = 0.0
   SET request->notes[note_index].encounter_id = 0.0
   SET request->notes[note_index].person_id = 0.0
   SET reply->notes[note_index].scd_story_id = request->notes[note_index].scd_story_id
   CALL populaterequestcodevalues(null)
   CALL deletenonstoryitems(1)
   UPDATE  FROM scd_story n
    SET n.story_type_cd = request->notes[note_index].story_type_cd, n.title = request->notes[
     note_index].title, n.author_id = request->notes[note_index].author_id,
     n.event_id = request->notes[note_index].event_id, n.encounter_id = request->notes[note_index].
     encounter_id, n.person_id = request->notes[note_index].person_id,
     n.story_completion_status_cd = request->notes[note_index].story_completion_status_cd, n
     .update_lock_user_id = 0.0, n.update_lock_dt_tm = null,
     n.updt_cnt = (n.updt_cnt+ 1), n.updt_id = reqinfo->updt_id, n.updt_dt_tm = cnvtdatetime(sysdate),
     n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->updt_applctx, n.entry_mode_cd =
     request->notes[note_index].entry_mode_cd
    WHERE (n.scd_story_id=request->notes[note_index].scd_story_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_update,cps_script_fail,"UPDATING STORY (PRE)",cps_update_msg,note_index,
     0,0)
    RETURN
   ENDIF
   CALL addnonstoryitems(note_type_pre)
   IF (failed=1)
    RETURN
   ENDIF
   IF ((term_data_batch_for_insert->cur_data_cnt > 0))
    CALL inserttermdatabatch(null)
    IF (failed=1)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (insertsentencebatch(sentence_count=i4) =null WITH protect)
   DECLARE sentence_cur = i4 WITH protect, noconstant(0.0)
   DECLARE sent_id = f8 WITH protect, noconstant(0.0)
   DECLARE sent_idx = i4 WITH protect, noconstant(0)
   SET stat = initrec(temp_sentence)
   SET stat = alterlist(temp_sentence->sentences,sentence_count)
   FOR (sentence_cur = 1 TO sentence_count)
     SET sent_id = scdgetuniqueactivityid(null)
     IF (failed=1)
      RETURN
     ENDIF
     SET sent_idx = temp_new_sentences->sentences[sentence_cur].sent_index
     SET reply->notes[note_index].sentences[sent_idx].scd_sentence_id = sent_id
     SET scd_paragraph_idx = request->notes[note_index].sentences[sent_idx].scd_paragraph_type_idx
     CALL fillsentencecodevalues(note_index,sent_idx)
     SET temp_sentence->sentences[sentence_cur].scd_sentence_id = sent_id
     SET temp_sentence->sentences[sentence_cur].canonical_sentence_pattern_id = request->notes[
     note_index].sentences[sent_idx].canonical_sentence_pattern_id
     SET temp_sentence->sentences[sentence_cur].scr_term_hier_id = request->notes[note_index].
     sentences[sent_idx].scr_term_hier_id
     SET temp_sentence->sentences[sentence_cur].author_persnl_id = request->notes[note_index].
     sentences[sent_idx].author_persnl_id
     SET temp_sentence->sentences[sentence_cur].scd_paragraph_id = reply->notes[note_index].
     paragraphs[scd_paragraph_idx].scd_paragraph_id
     SET temp_sentence->sentences[sentence_cur].scd_story_id = reply->notes[note_index].scd_story_id
     SET temp_sentence->sentences[sentence_cur].sequence_number = request->notes[note_index].
     sentences[sent_idx].sequence_number
     SET temp_sentence->sentences[sentence_cur].can_sent_pat_cki_source = request->notes[note_index].
     sentences[sent_idx].can_sent_pat_cki_source
     SET temp_sentence->sentences[sentence_cur].can_sent_pat_cki_identifier = request->notes[
     note_index].sentences[sent_idx].can_sent_pat_cki_identifier
     SET temp_sentence->sentences[sentence_cur].sentence_class_cd = request->notes[note_index].
     sentences[sent_idx].sentence_class_cd
     SET temp_sentence->sentences[sentence_cur].sentence_topic_cd = request->notes[note_index].
     sentences[sent_idx].sentence_topic_cd
     SET temp_sentence->sentences[sentence_cur].text_format_rule_cd = request->notes[note_index].
     sentences[sent_idx].text_format_rule_cd
     SET temp_sentence->sentences[sentence_cur].active_ind = 1
     SET temp_sentence->sentences[sentence_cur].active_status_cd = reqdata->active_status_cd
     SET temp_sentence->sentences[sentence_cur].active_status_dt_tm = cnvtdatetime(sysdate)
     SET temp_sentence->sentences[sentence_cur].active_status_prsnl_id = reqinfo->updt_id
     SET temp_sentence->sentences[sentence_cur].updt_cnt = 0
     SET temp_sentence->sentences[sentence_cur].updt_id = reqinfo->updt_id
     SET temp_sentence->sentences[sentence_cur].updt_dt_tm = cnvtdatetime(sysdate)
     SET temp_sentence->sentences[sentence_cur].updt_task = reqinfo->updt_task
     SET temp_sentence->sentences[sentence_cur].updt_applctx = reqinfo->updt_applctx
   ENDFOR
   INSERT  FROM scd_sentence s,
     (dummyt d  WITH seq = value(sentence_count))
    SET s.scd_sentence_id = temp_sentence->sentences[d.seq].scd_sentence_id, s
     .canonical_sentence_pattern_id = temp_sentence->sentences[d.seq].canonical_sentence_pattern_id,
     s.scr_term_hier_id = temp_sentence->sentences[d.seq].scr_term_hier_id,
     s.author_persnl_id = temp_sentence->sentences[d.seq].author_persnl_id, s.scd_paragraph_id =
     temp_sentence->sentences[d.seq].scd_paragraph_id, s.scd_story_id = temp_sentence->sentences[d
     .seq].scd_story_id,
     s.sequence_number = temp_sentence->sentences[d.seq].sequence_number, s.can_sent_pat_cki_source
      = temp_sentence->sentences[d.seq].can_sent_pat_cki_source, s.can_sent_pat_cki_identifier =
     temp_sentence->sentences[d.seq].can_sent_pat_cki_identifier,
     s.sentence_class_cd = temp_sentence->sentences[d.seq].sentence_class_cd, s.sentence_topic_cd =
     temp_sentence->sentences[d.seq].sentence_topic_cd, s.text_format_rule_cd = temp_sentence->
     sentences[d.seq].text_format_rule_cd,
     s.active_ind = temp_sentence->sentences[d.seq].active_ind, s.active_status_cd = temp_sentence->
     sentences[d.seq].active_status_cd, s.active_status_dt_tm = cnvtdatetime(sysdate),
     s.active_status_prsnl_id = temp_sentence->sentences[d.seq].updt_id, s.updt_cnt = temp_sentence->
     sentences[d.seq].updt_cnt, s.updt_id = temp_sentence->sentences[d.seq].updt_id,
     s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_task = temp_sentence->sentences[d.seq].updt_task, s
     .updt_applctx = temp_sentence->sentences[d.seq].updt_applctx
    PLAN (d)
     JOIN (s)
    WITH nocounter, rdbarrayinsert = 1
   ;end insert
   IF (curqual != sentence_count)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING SENTENCES ADD",cps_insert_msg,note_index,
     sent_idx,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatebatchedsentences(sentence_count=i4) =null WITH protect)
   DECLARE sent_id = f8 WITH protect, noconstant(0.0)
   DECLARE sent_updt_cnt = i4 WITH protect, noconstant(0)
   DECLARE sentence_cur = i4 WITH protect, noconstant(0)
   DECLARE sent_indx = i4 WITH private, noconstant(0)
   SET stat = initrec(temp_sentence)
   SET stat = alterlist(temp_sentence->sentences,sentence_count)
   FOR (sentence_cur = 1 TO sentence_count)
     SET sent_indx = temp_upd_sentences->sentences[sentence_cur].sent_idx
     SET sent_id = request->notes[note_index].sentences[sent_indx].scd_sentence_id
     SET sent_updt_cnt = 0
     IF (sent_id=0.0)
      SET failed = 1
      CALL cps_add_error(cps_insuf_data,cps_script_fail,"Update, No SENT_ID specified",
       cps_insuf_data_msg,note_index,
       sent_indx,0)
      RETURN
     ENDIF
     SET reply->notes[note_index].sentences[sent_indx].scd_sentence_id = sent_id
     SET scd_paragraph_idx = request->notes[note_index].sentences[sent_indx].scd_paragraph_type_idx
     CALL fillsentencecodevalues(note_index,sent_indx)
     IF (failed=1)
      RETURN
     ENDIF
     SELECT INTO "NL:"
      FROM scd_sentence s
      WHERE s.scd_sentence_id=sent_id
      DETAIL
       sent_updt_cnt = s.updt_cnt
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = 1
      CALL cps_add_error(cps_select,cps_script_fail,"Getting Sentence update count",cps_select_msg,
       note_index,
       sent_indx,0)
      RETURN
     ENDIF
     SET sent_updt_cnt += 1
     SET temp_sentence->sentences[sentence_cur].scd_sentence_id = sent_id
     SET temp_sentence->sentences[sentence_cur].canonical_sentence_pattern_id = request->notes[
     note_index].sentences[sent_indx].canonical_sentence_pattern_id
     SET temp_sentence->sentences[sentence_cur].scr_term_hier_id = request->notes[note_index].
     sentences[sent_indx].scr_term_hier_id
     SET temp_sentence->sentences[sentence_cur].author_persnl_id = request->notes[note_index].
     sentences[sent_indx].author_persnl_id
     SET temp_sentence->sentences[sentence_cur].scd_paragraph_id = reply->notes[note_index].
     paragraphs[scd_paragraph_idx].scd_paragraph_id
     SET temp_sentence->sentences[sentence_cur].scd_story_id = reply->notes[note_index].scd_story_id
     SET temp_sentence->sentences[sentence_cur].sequence_number = request->notes[note_index].
     sentences[sent_indx].sequence_number
     SET temp_sentence->sentences[sentence_cur].can_sent_pat_cki_source = request->notes[note_index].
     sentences[sent_indx].can_sent_pat_cki_source
     SET temp_sentence->sentences[sentence_cur].can_sent_pat_cki_identifier = request->notes[
     note_index].sentences[sent_indx].can_sent_pat_cki_identifier
     SET temp_sentence->sentences[sentence_cur].sentence_class_cd = request->notes[note_index].
     sentences[sent_indx].sentence_class_cd
     SET temp_sentence->sentences[sentence_cur].sentence_topic_cd = request->notes[note_index].
     sentences[sent_indx].sentence_topic_cd
     SET temp_sentence->sentences[sentence_cur].text_format_rule_cd = request->notes[note_index].
     sentences[sent_indx].text_format_rule_cd
     SET temp_sentence->sentences[sentence_cur].updt_cnt = sent_updt_cnt
     SET temp_sentence->sentences[sentence_cur].updt_id = reqinfo->updt_id
     SET temp_sentence->sentences[sentence_cur].updt_dt_tm = cnvtdatetime(sysdate)
     SET temp_sentence->sentences[sentence_cur].updt_task = reqinfo->updt_task
     SET temp_sentence->sentences[sentence_cur].updt_applctx = reqinfo->updt_applctx
     IF ((temp_upd_sentences->sentences[sentence_cur].updateterms=delete_term_baggage))
      CALL deletetermbaggage(sent_id)
      DELETE  FROM scd_term t
       WHERE t.scd_sentence_id=sent_id
        AND (t.scd_story_id=request->notes[note_index].scd_story_id)
       WITH nocounter
      ;end delete
      IF (curqual=0)
       SET failed = 1
       CALL cps_add_error(cps_delete,cps_script_fail,"Deleting Terms",cps_delete_msg,note_index,
        cnvtint(sent_id),0)
       RETURN
      ENDIF
     ENDIF
   ENDFOR
   UPDATE  FROM (dummyt d  WITH seq = sentence_count),
     scd_sentence s
    SET s.canonical_sentence_pattern_id = temp_sentence->sentences[d.seq].
     canonical_sentence_pattern_id, s.scr_term_hier_id = temp_sentence->sentences[d.seq].
     scr_term_hier_id, s.author_persnl_id = temp_sentence->sentences[d.seq].author_persnl_id,
     s.scd_paragraph_id = temp_sentence->sentences[d.seq].scd_paragraph_id, s.scd_story_id =
     temp_sentence->sentences[d.seq].scd_story_id, s.sequence_number = temp_sentence->sentences[d.seq
     ].sequence_number,
     s.can_sent_pat_cki_source = temp_sentence->sentences[d.seq].can_sent_pat_cki_source, s
     .can_sent_pat_cki_identifier = temp_sentence->sentences[d.seq].can_sent_pat_cki_identifier, s
     .sentence_class_cd = temp_sentence->sentences[d.seq].sentence_class_cd,
     s.sentence_topic_cd = temp_sentence->sentences[d.seq].sentence_topic_cd, s.text_format_rule_cd
      = temp_sentence->sentences[d.seq].text_format_rule_cd, s.updt_cnt = temp_sentence->sentences[d
     .seq].updt_cnt,
     s.updt_id = temp_sentence->sentences[d.seq].updt_id, s.updt_dt_tm = cnvtdatetime(sysdate), s
     .updt_task = temp_sentence->sentences[d.seq].updt_task,
     s.updt_applctx = temp_sentence->sentences[d.seq].updt_applctx
    PLAN (d)
     JOIN (s
     WHERE (s.scd_sentence_id=temp_sentence->sentences[d.seq].scd_sentence_id))
    WITH nocounter, rdbarrayinsert = 1
   ;end update
   IF (curqual != sentence_count)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"FAILED UPDATING SENTENCES ",cps_insert_msg,
     note_index,
     0,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (deletesentence(del_index=i4) =null WITH protect)
   DECLARE sent_id = f8 WITH protect, noconstant(request->notes[note_index].sentences[del_index].
    scd_sentence_id)
   IF (sent_id=0.0)
    SET failed = 1
    CALL cps_add_error(cps_insuf_data,cps_script_fail,"Delete, No SENT_ID specified",
     cps_insuf_data_msg,note_index,
     del_index,0)
    RETURN
   ENDIF
   SET reply->notes[note_index].sentences[del_index].scd_sentence_id = 0.0
   CALL deletetermbaggage(sent_id)
   DELETE  FROM scd_term t
    WHERE t.scd_sentence_id=sent_id
     AND (t.scd_story_id=request->notes[note_index].scd_story_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_delete,cps_script_fail,"DELETING SENTENCE TERMS",cps_delete_msg,note_index,
     del_index,cnvtint(sent_id))
    RETURN
   ENDIF
   DELETE  FROM scd_sentence s
    WHERE s.scd_sentence_id=sent_id
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_delete,cps_script_fail,"DELETING SENTENCES",cps_delete_msg,note_index,
     del_index,cnvtint(sent_id))
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (deletetermbaggage(scd_sentence_id=f8) =null WITH protect)
   DELETE  FROM long_blob lb
    WHERE lb.parent_entity_name="SCD_BLOB"
     AND lb.parent_entity_id IN (
    (SELECT INTO "NL:"
     td.fkey_id
     FROM scd_term_data td,
      scd_term t
     WHERE (t.scd_story_id=request->notes[note_index].scd_story_id)
      AND td.fkey_entity_name="SCD_BLOB"
      AND td.scd_term_data_id=t.scd_term_data_id
      AND t.scd_sentence_id=scd_sentence_id
     WITH nocounter))
    WITH nocounter
   ;end delete
   DELETE  FROM scd_blob blob
    WHERE blob.scd_blob_id IN (
    (SELECT INTO "NL:"
     td.fkey_id
     FROM scd_term_data td,
      scd_term t
     WHERE (t.scd_story_id=request->notes[note_index].scd_story_id)
      AND td.fkey_entity_name="SCD_BLOB"
      AND td.scd_term_data_id=t.scd_term_data_id
      AND t.scd_sentence_id=scd_sentence_id
     WITH nocounter))
    WITH nocounter
   ;end delete
   DELETE  FROM scd_term_data td
    WHERE td.scd_term_data_id IN (
    (SELECT INTO "NL:"
     t.scd_term_data_id
     FROM scd_term t
     WHERE (t.scd_story_id=request->notes[note_index].scd_story_id)
      AND t.scd_sentence_id=scd_sentence_id
      AND t.scd_term_data_id != 0.0
     WITH nocounter))
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE (deletetermbaggagebynote(storyid=f8) =null WITH protect)
   DELETE  FROM long_blob lb
    WHERE lb.parent_entity_name="SCD_BLOB"
     AND lb.parent_entity_id IN (
    (SELECT INTO "NL:"
     td.fkey_id
     FROM scd_term_data td,
      scd_term t
     WHERE td.fkey_entity_name="SCD_BLOB"
      AND td.scd_term_data_id=t.scd_term_data_id
      AND t.scd_story_id=storyid
     WITH nocounter))
    WITH nocounter
   ;end delete
   DELETE  FROM scd_blob blob
    WHERE blob.scd_blob_id IN (
    (SELECT INTO "NL:"
     td.fkey_id
     FROM scd_term_data td,
      scd_term t
     WHERE td.fkey_entity_name="SCD_BLOB"
      AND td.scd_term_data_id=t.scd_term_data_id
      AND t.scd_story_id=storyid
     WITH nocounter))
    WITH nocounter
   ;end delete
   DELETE  FROM scd_term_data td
    WHERE td.scd_term_data_id IN (
    (SELECT INTO "NL:"
     t.scd_term_data_id
     FROM scd_term t
     WHERE t.scd_story_id=storyid
      AND t.scd_term_data_id != 0.0
     WITH nocounter))
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE (deletenotebaggage(storyid=f8) =null WITH protect)
   DELETE  FROM long_blob lb
    WHERE lb.parent_entity_name="SCD_BLOB"
     AND lb.parent_entity_id IN (
    (SELECT INTO "NL:"
     td.fkey_id
     FROM scd_term_data td,
      scd_story s
     WHERE td.fkey_entity_name="SCD_BLOB"
      AND td.scd_term_data_id=s.scd_term_data_id
      AND s.scd_story_id=storyid
     WITH nocounter))
    WITH nocounter
   ;end delete
   DELETE  FROM scd_blob blob
    WHERE blob.scd_blob_id IN (
    (SELECT INTO "NL:"
     td.fkey_id
     FROM scd_term_data td,
      scd_story s
     WHERE td.fkey_entity_name="SCD_BLOB"
      AND td.scd_term_data_id=s.scd_term_data_id
      AND s.scd_story_id=storyid
     WITH nocounter))
    WITH nocounter
   ;end delete
   DELETE  FROM scd_term_data td
    WHERE td.scd_term_data_id IN (
    (SELECT INTO "NL:"
     s.scd_term_data_id
     FROM scd_story s
     WHERE s.scd_story_id=storyid
      AND s.scd_term_data_id != 0.0
     WITH nocounter))
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE (insertstorypattern(patidsize=i4,storyid=f8) =null WITH protect)
   FOR (patidx = 1 TO patidsize)
     IF ((request->notes[note_index].scr_pattern_id[patidx].pattern_type_cd=0))
      SET request->notes[note_index].scr_pattern_id[patidx].pattern_type_cd = findcodevaluebymeaning(
       14409,nullterm(request->notes[note_index].scr_pattern_id[patidx].pattern_type_mean))
      IF (failed=1)
       CALL cps_add_error(cps_inval_data,cps_script_fail,"PATTERN TYPE",cps_inval_data_msg,note_index,
        patidx,0)
       RETURN
      ENDIF
     ENDIF
   ENDFOR
   INSERT  FROM scd_story_pattern sp,
     (dummyt d  WITH seq = value(patidsize))
    SET sp.scd_story_id = storyid, sp.scr_pattern_id = request->notes[note_index].scr_pattern_id[d
     .seq].patid, sp.scr_paragraph_type_id = request->notes[note_index].scr_pattern_id[d.seq].
     para_type_id,
     sp.pattern_type_cd = request->notes[note_index].scr_pattern_id[d.seq].pattern_type_cd
    PLAN (d)
     JOIN (sp)
    WITH nocounter, rdbarrayinsert = 1
   ;end insert
   IF (curqual != patidsize)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING STORY_PATTERN RELTN",cps_insert_msg,
     note_index,
     curqual,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE unlocknote(null)
   SET reply->notes[note_index].scd_story_id = request->notes[note_index].scd_story_id
   FREE RECORD lock_data
   RECORD lock_data(
     1 story_id = f8
     1 actn_type = c3
     1 update_lock_dt_tm = dq8
     1 note_index = i4
   )
   SET lock_data->story_id = request->notes[note_index].scd_story_id
   SET lock_data->actn_type = "UNL"
   SET lock_data->update_lock_dt_tm = request->notes[note_index].update_lock_dt_tm
   SET lock_data->note_index = note_index
   DECLARE irtn = i2 WITH noconstant(0)
   SET irtn = checklocked(null)
   FREE RECORD lock_data
   IF (irtn > 0)
    RETURN
   ENDIF
   DECLARE story_completion_status_cd = f8 WITH protect, noconstant(0.0)
   DECLARE story_completion_status_mean = vc WITH protect, noconstant("")
   SELECT INTO "NL:"
    FROM scd_story n
    WHERE (n.scd_story_id=request->notes[note_index].scd_story_id)
    DETAIL
     story_completion_status_cd = n.story_completion_status_cd
    WITH nocounter
   ;end select
   IF (story_completion_status_cd > 0.0)
    SET story_completion_status_mean = uar_get_code_meaning(story_completion_status_cd)
   ENDIF
   IF (story_completion_status_mean="AUTOSAVED")
    CALL deletenote(null)
    RETURN
   ENDIF
   SET irtn = unlocknoteinternal(request->notes[note_index].scd_story_id)
   IF (irtn > 0)
    SET failed = 1
    CALL cps_add_error(cps_update,cps_script_fail,"UNLOCKING STORY",cps_update_msg,note_index,
     0,0)
    RETURN
   ENDIF
   CALL deleteautosavednoteblob(note_index)
 END ;Subroutine
 SUBROUTINE deletenote(null)
   SET reply->notes[note_index].scd_story_id = 0.0
   CALL deletenonstoryitems(0)
   DELETE  FROM scd_story s
    WHERE (s.scd_story_id=request->notes[note_index].scd_story_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_delete,cps_script_fail,"DELETING STORY",cps_delete_msg,note_index,
     cnvtint(request->notes[note_index].scd_story_id),0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (deletenonstoryitems(bpreserveorgreltns=i2) =null WITH protect)
   CALL deletetermbaggagebynote(request->notes[note_index].scd_story_id)
   CALL deleteautosavednoteblob(note_index)
   DELETE  FROM scd_term t
    WHERE (t.scd_story_id=request->notes[note_index].scd_story_id)
    WITH nocounter
   ;end delete
   DELETE  FROM scd_sentence s
    WHERE (s.scd_story_id=request->notes[note_index].scd_story_id)
    WITH nocounter
   ;end delete
   DELETE  FROM scd_paragraph p
    WHERE (p.scd_story_id=request->notes[note_index].scd_story_id)
    WITH nocounter
   ;end delete
   DELETE  FROM scd_story_pattern ss
    WHERE (ss.scd_story_id=request->notes[note_index].scd_story_id)
    WITH nocounter
   ;end delete
   CALL deleteconcepts(note_index)
   IF (bpreserveorgreltns=0)
    DELETE  FROM scd_story_org_reltn sso
     WHERE (sso.scd_story_id=request->notes[note_index].scd_story_id)
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE (setnotestatus(statuscd=f8,activeind=i2) =null WITH protect)
   SET reply->notes[note_index].scd_story_id = request->notes[note_index].scd_story_id
   UPDATE  FROM scd_story n
    SET n.active_status_cd = statuscd, n.active_status_dt_tm = cnvtdatetime(sysdate), n
     .active_status_prsnl_id = reqinfo->updt_id,
     n.active_ind = activeind, n.updt_id = reqinfo->updt_id, n.updt_dt_tm = cnvtdatetime(sysdate),
     n.updt_cnt = (n.updt_cnt+ 1), n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
     updt_applctx
    WHERE (n.scd_story_id=request->notes[note_index].scd_story_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_update,cps_script_fail,"(In)Activate Note failed",cps_update_msg,cnvtint(
      request->notes[note_index].scd_story_id),
     cnvtint(statuscd),activeind)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getphraseids(termsize=i4) =null WITH protect)
   RECORD phr_fnd(
     1 pf_arr[*]
       2 phrase_id = f8
       2 phrase_string = vc
   )
   RECORD phr_set(
     1 ps_arr[*]
       2 phrase_id = f8
       2 phrase_string = vc
       2 phrase_string_index = vc
   )
   DECLARE term_set = i4 WITH protect, constant(10)
   DECLARE numsets = i4 WITH private, noconstant(ceil(((termsize * 1.0)/ term_set)))
   DECLARE phrase_list_cnt = i4 WITH private, noconstant(0)
   DECLARE base = i4 WITH private, noconstant(0)
   DECLARE terms = i4 WITH private, noconstant(0)
   DECLARE phrase_cnt = i4 WITH protect, noconstant(0)
   IF (termsize > 0)
    FOR (x = 1 TO termsize)
      IF (textlen(trim(request->notes[note_index].terms[x].phrase_string)) > 0)
       SET phrase_list_cnt += 1
      ENDIF
    ENDFOR
   ENDIF
   IF (phrase_list_cnt=0)
    SET numsets = 0
   ENDIF
   SET stat = alterlist(phr_set->ps_arr,term_set)
   SET stat = alterlist(phr_fnd->pf_arr,term_set)
   FOR (set_index = 1 TO numsets)
     SET base = ((set_index - 1) * term_set)
     FOR (i = 1 TO term_set)
       SET phr_fnd->pf_arr[i].phrase_id = 0
       SET phr_fnd->pf_arr[i].phrase_string = ""
       IF (((base+ i) > termsize))
        SET phr_set->ps_arr[i].phrase_string = ""
        SET phr_set->ps_arr[i].phrase_string_index = ""
       ELSE
        SET phr_set->ps_arr[i].phrase_string = request->notes[note_index].terms[(base+ i)].
        phrase_string
        SET phr_set->ps_arr[i].phrase_string_index = substring(1,255,request->notes[note_index].
         terms[(base+ i)].phrase_string)
       ENDIF
     ENDFOR
     SET phrase_cnt = 0
     SELECT INTO "nl:"
      p.scr_phrase_id
      FROM scr_phrase p
      WHERE p.phrase_string IS NOT null
       AND p.phrase_string != " "
       AND p.phrase_string IN (phr_set->ps_arr[1].phrase_string, phr_set->ps_arr[2].phrase_string,
      phr_set->ps_arr[3].phrase_string, phr_set->ps_arr[4].phrase_string, phr_set->ps_arr[5].
      phrase_string,
      phr_set->ps_arr[6].phrase_string, phr_set->ps_arr[7].phrase_string, phr_set->ps_arr[8].
      phrase_string, phr_set->ps_arr[9].phrase_string, phr_set->ps_arr[10].phrase_string)
      DETAIL
       phrase_cnt += 1, phr_fnd->pf_arr[phrase_cnt].phrase_id = p.scr_phrase_id, phr_fnd->pf_arr[
       phrase_cnt].phrase_string = p.phrase_string
      WITH nocounter
     ;end select
     IF (phrase_cnt > 0)
      FOR (i = 1 TO term_set)
        FOR (m = 1 TO phrase_cnt)
          IF ((phr_set->ps_arr[i].phrase_string=phr_fnd->pf_arr[m].phrase_string))
           SET phr_set->ps_arr[i].phrase_string = ""
           SET phr_set->ps_arr[i].phrase_string_index = ""
           SET request->notes[note_index].terms[(base+ i)].scr_phrase_id = phr_fnd->pf_arr[m].
           phrase_id
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
     IF (phrase_cnt != term_set)
      FOR (i = 1 TO term_set)
        IF ((phr_set->ps_arr[i].phrase_string != ""))
         FOR (m = (i+ 1) TO term_set)
           IF ((phr_set->ps_arr[i].phrase_string=phr_set->ps_arr[m].phrase_string))
            SET phr_set->ps_arr[m].phrase_string = ""
            SET phr_set->ps_arr[m].phrase_string_index = ""
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
      IF (set_index=numsets)
       SET terms = (termsize - base)
      ELSE
       SET terms = term_set
      ENDIF
      FOR (i = 1 TO terms)
        IF ((phr_set->ps_arr[i].phrase_string != ""))
         SET unique_id = scdgetuniqueactivityid(null)
         IF (failed=1)
          RETURN
         ENDIF
         INSERT  FROM scr_phrase pt
          SET pt.scr_phrase_id = unique_id, pt.phrase_string = phr_set->ps_arr[i].phrase_string, pt
           .phrase_string_index = phr_set->ps_arr[i].phrase_string_index
          WITH nocounter
         ;end insert
         SET phr_set->ps_arr[i].phrase_id = unique_id
         FOR (m = i TO terms)
           IF ((phr_set->ps_arr[i].phrase_string=request->notes[note_index].terms[(base+ m)].
           phrase_string))
            SET request->notes[note_index].terms[(base+ m)].scr_phrase_id = phr_set->ps_arr[i].
            phrase_id
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   FREE RECORD phr_set
   FREE RECORD phr_fnd
 END ;Subroutine
 SUBROUTINE (insertconcepts(index=i4) =null WITH protect)
  DECLARE numberofconcepts = i4 WITH protect, noconstant(size(request->notes[index].concepts,5))
  IF (numberofconcepts != 0)
   INSERT  FROM scd_story_concept ssc,
     (dummyt d1  WITH seq = value(numberofconcepts))
    SET ssc.scd_story_concept_id = cnvtreal(seq(scd_seq,nextval)), ssc.scd_story_id = reply->notes[
     index].scd_story_id, ssc.concept_cki = request->notes[index].concepts[d1.seq].concept_cki,
     ssc.concept_display = request->notes[index].concepts[d1.seq].concept_display, ssc.updt_id =
     reqinfo->updt_id, ssc.updt_dt_tm = cnvtdatetime(sysdate),
     ssc.updt_task = reqinfo->updt_task, ssc.updt_applctx = reqinfo->updt_applctx, ssc.updt_cnt = 0,
     ssc.diagnosis_group_id = request->notes[index].concepts[d1.seq].diagnosis_group_id, ssc
     .concept_type_flag = request->notes[index].concepts[d1.seq].concept_type_flag
    PLAN (d1)
     JOIN (ssc)
    WITH nocounter, rdbarrayinsert = 1
   ;end insert
   IF (curqual != numberofconcepts)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING CONCEPTS INTO SCD_STORY_CONCEPT",
     cps_insert_msg,index,
     curqual,numberofconcepts)
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (deleteconcepts(index=i4) =null WITH protect)
   DELETE  FROM scd_story_concept ssc
    WHERE (ssc.scd_story_id=request->notes[index].scd_story_id)
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE (updateconcepts(index=i4) =null WITH protect)
  CALL deleteconcepts(index)
  CALL insertconcepts(index)
 END ;Subroutine
 SUBROUTINE (geteventids(reference_nbr=vc) =f8 WITH protect)
   DECLARE event_id = f8 WITH protect, noconstant(0.0)
   IF (textlen(trim(reference_nbr))=0)
    RETURN(event_id)
   ENDIF
   IF (event_rep_status=1)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(event_rep->rb_list,5)))
     PLAN (d1
      WHERE (event_rep->rb_list[d1.seq].reference_nbr=reference_nbr))
     DETAIL
      event_id = event_rep->rb_list[d1.seq].event_id
     WITH nocounter
    ;end select
   ENDIF
   RETURN(event_id)
 END ;Subroutine
 SUBROUTINE updateparagraphs(null)
   FREE RECORD temp_para_term_data
   RECORD temp_para_term_data(
     1 ids[*]
       2 para_term_data_id = f8
   )
   FREE RECORD temp_scd_paragraph
   RECORD temp_scd_paragraph(
     1 fields[*]
       2 scd_story_id = f8
       2 scr_paragraph_type_id = f8
       2 sequence_number = i4
       2 paragraph_class_cd = f8
       2 truth_state_cd = f8
       2 event_id = f8
       2 scd_term_data_id = f8
       2 scd_paragraph_id = f8
   )
   DECLARE num_paras_to_delete = i4 WITH protect, noconstant(0)
   DECLARE para_iterator = i4 WITH protect, noconstant(0.0)
   DECLARE nnoteidx = i4 WITH protect, noconstant(0.0)
   DECLARE nparaindex = i4 WITH protect, noconstant(0.0)
   DECLARE para_term_data_id = f8 WITH private, noconstant(0.0)
   DECLARE temp_event_id = f8 WITH private, noconstant(0.0)
   SET stat = alterlist(temp_scd_paragraph->fields,numparastoupdate)
   FOR (para_iterator = 1 TO numparastoupdate)
     SET nnoteidx = paragraphstoupdate->paras[para_iterator].note_index
     SET nparaindex = paragraphstoupdate->paras[para_iterator].par_index
     SET reply->notes[nnoteidx].paragraphs[nparaindex].scd_paragraph_id = request->notes[nnoteidx].
     paragraphs[nparaindex].scd_paragraph_id
     IF ((request->notes[nnoteidx].paragraphs[nparaindex].event_id=0))
      SET temp_event_id = geteventids(request->notes[nnoteidx].paragraphs[nparaindex].reference_nbr)
      IF (failed=1)
       RETURN
      ENDIF
      SET request->notes[nnoteidx].paragraphs[nparaindex].event_id = temp_event_id
     ENDIF
     SET reply->notes[nnoteidx].paragraphs[nparaindex].event_id = request->notes[nnoteidx].
     paragraphs[nparaindex].event_id
     SELECT INTO "NL:"
      FROM scd_paragraph para
      WHERE para.scd_paragraph_id=unique_id
      DETAIL
       para_term_data_id = para.scd_term_data_id
      WITH nocounter
     ;end select
     IF (para_term_data_id > 0.0)
      SET num_paras_to_delete += 1
      SET stat = alterlist(temp_para_term_data->ids,num_paras_to_delete)
      SET temp_para_term_data->ids[num_paras_to_delete].para_term_data_id = para_term_data_id
     ENDIF
     SET number_para_data = size(request->notes[nnoteidx].paragraphs[nparaindex].para_term_data,5)
     IF (number_para_data > 0)
      SET unique_id = scdgetuniqueactivityid(null)
      IF (failed=1)
       RETURN
      ENDIF
      CALL addtermdatatobatch(nnoteidx,nparaindex,number_para_data,term_type_para,unique_id)
     ENDIF
     IF ((request->notes[nnoteidx].paragraphs[nparaindex].paragraph_class_cd=0))
      SET request->notes[nnoteidx].paragraphs[nparaindex].paragraph_class_cd = findcodevaluebymeaning
      (14410,nullterm(request->notes[nnoteidx].paragraphs[nparaindex].paragraph_class_mean))
      IF (failed=1)
       CALL cps_add_error(cps_inval_data,cps_script_fail,"PARAGRAPH",cps_inval_data_msg,nnoteidx,
        nparaindex,0)
       RETURN
      ENDIF
     ENDIF
     IF ((request->notes[nnoteidx].paragraphs[nparaindex].truth_state_cd=0))
      SET request->notes[nnoteidx].paragraphs[nparaindex].truth_state_cd = findcodevaluebymeaning(
       15751,nullterm(request->notes[nnoteidx].paragraphs[nparaindex].truth_state_mean))
      IF (failed=1)
       CALL cps_add_error(cps_inval_data,cps_script_fail,"TRUTH STATE",cps_inval_data_msg,nnoteidx,
        nparaindex,0)
       RETURN
      ENDIF
     ENDIF
     SET temp_scd_paragraph->fields[para_iterator].scd_story_id = reply->notes[nnoteidx].scd_story_id
     SET temp_scd_paragraph->fields[para_iterator].scr_paragraph_type_id = request->notes[nnoteidx].
     paragraphs[nparaindex].scr_paragraph_type_id
     SET temp_scd_paragraph->fields[para_iterator].sequence_number = request->notes[nnoteidx].
     paragraphs[nparaindex].sequence_number
     SET temp_scd_paragraph->fields[para_iterator].paragraph_class_cd = request->notes[nnoteidx].
     paragraphs[nparaindex].paragraph_class_cd
     SET temp_scd_paragraph->fields[para_iterator].truth_state_cd = request->notes[nnoteidx].
     paragraphs[nparaindex].truth_state_cd
     SET temp_scd_paragraph->fields[para_iterator].event_id = request->notes[nnoteidx].paragraphs[
     nparaindex].event_id
     SET temp_scd_paragraph->fields[para_iterator].scd_paragraph_id = request->notes[nnoteidx].
     paragraphs[nparaindex].scd_paragraph_id
     IF (number_para_data != 0)
      SET temp_scd_paragraph->fields[para_iterator].scd_term_data_id = unique_id
     ELSE
      SET temp_scd_paragraph->fields[para_iterator].scd_term_data_id = 0.0
     ENDIF
   ENDFOR
   IF (numparastoupdate > 0)
    UPDATE  FROM (dummyt d  WITH seq = numparastoupdate),
      scd_paragraph p
     SET p.scd_story_id = temp_scd_paragraph->fields[d.seq].scd_story_id, p.scr_paragraph_type_id =
      temp_scd_paragraph->fields[d.seq].scr_paragraph_type_id, p.sequence_number = temp_scd_paragraph
      ->fields[d.seq].sequence_number,
      p.paragraph_class_cd = temp_scd_paragraph->fields[d.seq].paragraph_class_cd, p.truth_state_cd
       = temp_scd_paragraph->fields[d.seq].truth_state_cd, p.event_id = request->notes[nnoteidx].
      paragraphs[nparaindex].event_id,
      p.scd_term_data_id = temp_scd_paragraph->fields[d.seq].scd_term_data_id
     PLAN (d)
      JOIN (p
      WHERE (p.scd_paragraph_id=temp_scd_paragraph->fields[d.seq].scd_paragraph_id))
     WITH nocounter, rdbarrayinsert = 1
    ;end update
    IF (curqual != numparastoupdate)
     SET failed = 1
     CALL cps_add_error(cps_update,cps_script_fail,"UPDATING PARAGRAPHS",cps_update_msg,note_index,
      numparastoupdate,0)
     RETURN
    ENDIF
   ENDIF
   DELETE  FROM (dummyt d  WITH seq = num_paras_to_delete),
     scd_term_data td
    SET td.seq = 1
    PLAN (d)
     JOIN (td
     WHERE (td.scd_term_data_id=temp_para_term_data->ids[d.seq].para_term_data_id)
      AND td.scd_term_data_id != 0.0)
    WITH rdbarrayinsert = 1
   ;end delete
 END ;Subroutine
 SUBROUTINE updateterms(null)
   DECLARE updt_term_cnt = i4 WITH private, constant(size(request->notes[note_index].terms,5))
   DECLARE successor_term_idx = i4 WITH protect, noconstant(0)
   DECLARE num_terms_to_insert = i4 WITH protect, noconstant(0)
   DECLARE num_rows_to_replace = i4 WITH protect, noconstant(0)
   DECLARE num_rows_to_update = i4 WITH protect, noconstant(0)
   FREE RECORD replaced_rows
   RECORD replaced_rows(
     1 fields[*]
       2 end_effective_dt_tm = dq8
       2 successor_term_id = f8
       2 scd_term_id = f8
   )
   FREE RECORD parent_updated
   RECORD parent_updated(
     1 fields[*]
       2 parent_scd_term_id = f8
       2 scd_term_id = f8
   )
   SET stat = alterlist(terms_batch_for_insert->terms,updt_term_cnt)
   SET stat = alterlist(temp_term_ids->term_ids,updt_term_cnt)
   SET stat = alterlist(reply->notes[note_index].terms,updt_term_cnt)
   CALL getphraseids(updt_term_cnt)
   IF (failed=1)
    RETURN
   ENDIF
   SET stat = initrec(terms_batch_for_insert)
   SET stat = alterlist(terms_batch_for_insert->terms,0)
   SET stat = alterlist(terms_batch_for_insert->terms,updt_term_cnt)
   SET terms_batch_for_insert->cur_term_count = 0
   FOR (term_index = 1 TO updt_term_cnt)
     IF ((request->notes[note_index].terms[term_index].scd_term_id=0)
      AND (request->notes[note_index].terms[term_index].successor_term_idx=0)
      AND (request->notes[note_index].terms[term_index].succeeded_term_id=0))
      CALL prepbatchforterminserts(note_index,term_index,1,request->notes[note_index].terms[
       term_index].modify_prsnl_id)
      SET num_terms_to_insert += 1
     ELSEIF ((request->notes[note_index].terms[term_index].scd_term_id=0)
      AND (request->notes[note_index].terms[term_index].succeeded_term_id != 0))
      CALL prepbatchforterminserts(note_index,term_index,0,request->notes[note_index].terms[
       term_index].modify_prsnl_id)
      SET num_terms_to_insert += 1
     ELSEIF ((request->notes[note_index].terms[term_index].scd_term_id != 0)
      AND (request->notes[note_index].terms[term_index].successor_term_idx != 0))
      SET successor_term_idx = request->notes[note_index].terms[term_index].successor_term_idx
      SET num_rows_to_replace += 1
      SET stat = alterlist(replaced_rows->fields,num_rows_to_replace)
      SET replaced_rows->fields[num_rows_to_replace].successor_term_id = temp_term_ids->term_ids[
      successor_term_idx].scd_term_id
      SET replaced_rows->fields[num_rows_to_replace].scd_term_id = request->notes[note_index].terms[
      term_index].scd_term_id
      SET replaced_rows->fields[num_rows_to_replace].end_effective_dt_tm = request->notes[note_index]
      .terms[term_index].end_effective_dt_tm
      SET temp_term_ids->term_ids[term_index].scd_term_id = request->notes[note_index].terms[
      term_index].scd_term_id
      SET reply->notes[note_index].terms[term_index].scd_term_id = request->notes[note_index].terms[
      term_index].scd_term_id
     ELSE
      SET parent_scd_term_idx = request->notes[note_index].terms[term_index].parent_scd_term_idx
      IF (parent_scd_term_idx != 0
       AND (request->notes[note_index].terms[parent_scd_term_idx].scd_term_id=0))
       SET num_rows_to_update += 1
       SET stat = alterlist(parent_updated->fields,num_rows_to_update)
       SET parent_updated->fields[num_rows_to_update].parent_scd_term_id = temp_term_ids->term_ids[
       parent_scd_term_idx].scd_term_id
       SET parent_updated->fields[num_rows_to_update].scd_term_id = request->notes[note_index].terms[
       term_index].scd_term_id
      ENDIF
      SET temp_term_ids->term_ids[term_index].scd_term_id = request->notes[note_index].terms[
      term_index].scd_term_id
      SET reply->notes[note_index].terms[term_index].scd_term_id = request->notes[note_index].terms[
      term_index].scd_term_id
     ENDIF
   ENDFOR
   SET stat = alterlist(terms_batch_for_insert->terms,num_terms_to_insert)
   CALL inserttermbatch(note_index,num_terms_to_insert)
   IF (failed=1)
    RETURN
   ENDIF
   IF (num_rows_to_replace > 0)
    UPDATE  FROM (dummyt d  WITH seq = num_rows_to_replace),
      scd_term t
     SET t.parent_scd_term_id = 0, t.end_effective_dt_tm = cnvtdatetime(replaced_rows->fields[d.seq].
       end_effective_dt_tm), t.active_ind = 0,
      t.successor_term_id = replaced_rows->fields[d.seq].successor_term_id
     PLAN (d)
      JOIN (t
      WHERE (t.scd_term_id=replaced_rows->fields[d.seq].scd_term_id))
     WITH nocounter, rdbarrayinsert = 1
    ;end update
    IF (curqual != num_rows_to_replace)
     SET failed = 1
     CALL cps_add_error(cps_update,cps_script_fail,"UPDATING TERM REPLACED ROWS",cps_update_msg,
      note_index,
      num_rows_to_replace,0)
     RETURN
    ENDIF
   ENDIF
   IF (num_rows_to_update > 0)
    UPDATE  FROM (dummyt d  WITH seq = value(num_rows_to_update)),
      scd_term t
     SET t.parent_scd_term_id = parent_updated->fields[d.seq].parent_scd_term_id
     PLAN (d)
      JOIN (t
      WHERE (t.scd_term_id=parent_updated->fields[d.seq].scd_term_id))
     WITH nocounter, rdbarrayinsert = 1
    ;end update
    IF (curqual != num_rows_to_update)
     SET failed = 1
     CALL cps_add_error(cps_update,cps_script_fail,"UPDATING TERM UPDATED ROWS",cps_update_msg,
      note_index,
      num_rows_to_update,0)
     RETURN
    ENDIF
    IF (failed=1)
     RETURN
    ENDIF
   ENDIF
   FREE RECORD parent_updated
   FREE RECORD replaced_rows
 END ;Subroutine
 SUBROUTINE insertterms(null)
   DECLARE term_cnt = i4 WITH private, constant(size(request->notes[note_index].terms,5))
   SET stat = alterlist(reply->notes[note_index].terms,term_cnt)
   SET stat = alterlist(temp_term_ids->term_ids,term_cnt)
   CALL getphraseids(term_cnt)
   IF (failed=1)
    RETURN
   ENDIF
   SET stat = initrec(terms_batch_for_insert)
   SET stat = alterlist(terms_batch_for_insert->terms,term_cnt)
   SET terms_batch_for_insert->cur_term_count = 0
   FOR (term_index = 1 TO term_cnt)
     CALL prepbatchforterminserts(note_index,term_index,1,0.0)
   ENDFOR
   CALL inserttermbatch(note_index,term_cnt)
 END ;Subroutine
 SUBROUTINE (prepbatchforterminserts(nnoteidx=i4,ntermindex=i4,newterm=i2,modify_prsnl_id=f8) =null
  WITH protect)
   DECLARE iter = i4 WITH private, noconstant(0)
   SET terms_batch_for_insert->cur_term_count += 1
   SET iter = terms_batch_for_insert->cur_term_count
   DECLARE number_term_data = i4 WITH protect, noconstant(0)
   DECLARE scd_sentence_idx = i4 WITH protect, noconstant(request->notes[nnoteidx].terms[ntermindex].
    scd_sentence_idx)
   DECLARE temp_event_id = f8 WITH private, noconstant(0.0)
   SET number_term_data = size(request->notes[nnoteidx].terms[ntermindex].term_data,5)
   DECLARE unique_id = f8 WITH private, noconstant(0.0)
   SET unique_id = scdgetuniqueactivityid(null)
   IF (failed=1)
    RETURN
   ENDIF
   SET reply->notes[nnoteidx].terms[ntermindex].scd_term_id = unique_id
   SET terms_batch_for_insert->terms[iter].scd_term_id = unique_id
   SET temp_term_ids->term_ids[ntermindex].scd_term_id = unique_id
   IF ((request->notes[nnoteidx].terms[ntermindex].event_id=0))
    SET temp_event_id = geteventids(request->notes[nnoteidx].terms[ntermindex].reference_nbr)
    IF (failed=1)
     RETURN
    ENDIF
    SET request->notes[nnoteidx].terms[ntermindex].event_id = temp_event_id
   ENDIF
   SET reply->notes[nnoteidx].terms[ntermindex].event_id = request->notes[nnoteidx].terms[ntermindex]
   .event_id
   SET terms_batch_for_insert->terms[iter].event_id = request->notes[nnoteidx].terms[ntermindex].
   event_id
   SET parent_scd_term_idx = request->notes[nnoteidx].terms[ntermindex].parent_scd_term_idx
   CALL filltermcodevalues(nnoteidx,ntermindex)
   IF (failed=1)
    RETURN
   ENDIF
   SET terms_batch_for_insert->terms[iter].scd_term_id = unique_id
   SET terms_batch_for_insert->terms[iter].scr_term_id = request->notes[nnoteidx].terms[ntermindex].
   scr_term_id
   SET terms_batch_for_insert->terms[iter].scd_sentence_id = reply->notes[nnoteidx].sentences[
   scd_sentence_idx].scd_sentence_id
   SET terms_batch_for_insert->terms[iter].scr_term_hier_id = request->notes[nnoteidx].terms[
   ntermindex].scr_term_hier_id
   IF (number_term_data != 0)
    SET terms_batch_for_insert->terms[iter].scd_term_data_id = unique_id
   ELSE
    SET terms_batch_for_insert->terms[iter].scd_term_data_id = 0.0
   ENDIF
   SET terms_batch_for_insert->terms[iter].sequence_number = request->notes[nnoteidx].terms[
   ntermindex].sequence_number
   SET terms_batch_for_insert->terms[iter].concept_source_cd = request->notes[nnoteidx].terms[
   ntermindex].concept_source_cd
   SET terms_batch_for_insert->terms[iter].concept_identifier = request->notes[nnoteidx].terms[
   ntermindex].concept_identifier
   SET terms_batch_for_insert->terms[iter].concept_cki = request->notes[nnoteidx].terms[ntermindex].
   concept_cki
   SET terms_batch_for_insert->terms[iter].truth_state_cd = request->notes[nnoteidx].terms[ntermindex
   ].truth_state_cd
   SET terms_batch_for_insert->terms[iter].scr_phrase_id = request->notes[nnoteidx].terms[ntermindex]
   .scr_phrase_id
   SET terms_batch_for_insert->terms[iter].modify_prsnl_id = modify_prsnl_id
   IF ((request->notes[nnoteidx].terms[ntermindex].beg_effective_dt_tm=0))
    IF ((((request->notes[note_index].action_type="ADD")) OR ((request->notes[note_index].action_type
    ="UPD"))) )
     SET terms_batch_for_insert->terms[iter].beg_effective_dt_tm = cnvtdatetime(sysdate)
    ELSE
     SET terms_batch_for_insert->terms[iter].beg_effective_dt_tm = cnvtdatetime(request->notes[
      nnoteidx].terms[ntermindex].beg_effective_dt_tm)
    ENDIF
   ELSE
    SET terms_batch_for_insert->terms[iter].beg_effective_dt_tm = cnvtdatetime(request->notes[
     nnoteidx].terms[ntermindex].beg_effective_dt_tm)
   ENDIF
   IF ((request->notes[nnoteidx].terms[ntermindex].beg_effective_tz=0))
    IF ((((request->notes[note_index].action_type="ADD")) OR ((request->notes[note_index].action_type
    ="UPD"))) )
     SET terms_batch_for_insert->terms[iter].beg_effective_tz = curtimezonesys
    ELSE
     SET terms_batch_for_insert->terms[iter].beg_effective_tz = request->notes[nnoteidx].terms[iter].
     beg_effective_tz
    ENDIF
   ELSE
    SET terms_batch_for_insert->terms[iter].beg_effective_tz = request->notes[nnoteidx].terms[
    ntermindex].beg_effective_tz
   ENDIF
   IF (parent_scd_term_idx=0)
    SET terms_batch_for_insert->terms[iter].parent_scd_term_id = 0.0
   ELSE
    SET terms_batch_for_insert->terms[iter].parent_scd_term_id = temp_term_ids->term_ids[
    parent_scd_term_idx].scd_term_id
   ENDIF
   IF (newterm=0
    AND (request->notes[nnoteidx].terms[ntermindex].truth_state_cd=prev_doc_state_cd))
    SET terms_batch_for_insert->terms[iter].active_ind = 0
   ELSE
    SET terms_batch_for_insert->terms[iter].active_ind = 1
   ENDIF
   SET terms_batch_for_insert->terms[iter].event_id = request->notes[nnoteidx].terms[ntermindex].
   event_id
   IF (number_term_data > 0)
    CALL addtermdatatobatch(nnoteidx,ntermindex,number_term_data,term_type_term,unique_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE (inserttermbatch(nnoteidx=i4,term_size=i4) =null WITH protect)
   IF (term_size > 0)
    INSERT  FROM scd_term t,
      (dummyt d  WITH seq = value(term_size))
     SET t.scd_term_id = terms_batch_for_insert->terms[d.seq].scd_term_id, t.scd_story_id = reply->
      notes[nnoteidx].scd_story_id, t.scr_term_id = terms_batch_for_insert->terms[d.seq].scr_term_id,
      t.scd_sentence_id = terms_batch_for_insert->terms[d.seq].scd_sentence_id, t.scr_term_hier_id =
      terms_batch_for_insert->terms[d.seq].scr_term_hier_id, t.scd_term_data_id =
      terms_batch_for_insert->terms[d.seq].scd_term_data_id,
      t.sequence_number = terms_batch_for_insert->terms[d.seq].sequence_number, t.concept_source_cd
       = terms_batch_for_insert->terms[d.seq].concept_source_cd, t.concept_identifier =
      terms_batch_for_insert->terms[d.seq].concept_identifier,
      t.concept_cki = terms_batch_for_insert->terms[d.seq].concept_cki, t.truth_state_cd =
      terms_batch_for_insert->terms[d.seq].truth_state_cd, t.scr_phrase_id = terms_batch_for_insert->
      terms[d.seq].scr_phrase_id,
      t.beg_effective_dt_tm = cnvtdatetime(terms_batch_for_insert->terms[d.seq].beg_effective_dt_tm),
      t.beg_effective_tz = terms_batch_for_insert->terms[d.seq].beg_effective_tz, t
      .parent_scd_term_id = terms_batch_for_insert->terms[d.seq].parent_scd_term_id,
      t.active_ind = terms_batch_for_insert->terms[d.seq].active_ind, t.end_effective_dt_tm =
      cnvtdatetime("31-Dec-2100"), t.modify_prsnl_id = terms_batch_for_insert->terms[d.seq].
      modify_prsnl_id,
      t.event_id = terms_batch_for_insert->terms[d.seq].event_id
     PLAN (d)
      JOIN (t)
     WITH nocounter, rdbarrayinsert = 1
    ;end insert
    IF (curqual != term_size)
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING TERMS",cps_insert_msg,nnoteidx,
      term_size,0)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE inserttermdatabatch(null)
  IF ((term_data_batch_for_insert->cur_data_cnt > 0))
   INSERT  FROM scd_term_data td,
     (dummyt d1  WITH seq = term_data_batch_for_insert->cur_data_cnt)
    SET td.scd_term_data_id = term_data_batch_for_insert->term_data[d1.seq].scd_term_id, td
     .scd_term_data_type_cd = term_data_batch_for_insert->term_data[d1.seq].scd_term_data_type_cd, td
     .scd_term_data_key = term_data_batch_for_insert->term_data[d1.seq].scd_term_data_key,
     td.fkey_id = term_data_batch_for_insert->term_data[d1.seq].fkey_id, td.fkey_entity_name =
     term_data_batch_for_insert->term_data[d1.seq].fkey_entity_name, td.value_number =
     term_data_batch_for_insert->term_data[d1.seq].value_number,
     td.value_dt_tm = cnvtdatetime(term_data_batch_for_insert->term_data[d1.seq].value_dt_tm), td
     .value_tz = term_data_batch_for_insert->term_data[d1.seq].value_tz, td.value_dt_tm_os =
     term_data_batch_for_insert->term_data[d1.seq].value_dt_tm_os,
     td.value_text = term_data_batch_for_insert->term_data[d1.seq].value_text, td.units_cd =
     term_data_batch_for_insert->term_data[d1.seq].units_cd
    PLAN (d1)
     JOIN (td)
    WITH nocounter, rdbarrayinsert = 1
   ;end insert
   IF ((curqual != term_data_batch_for_insert->cur_data_cnt))
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING TERM_DATA",cps_insert_msg,0,
     0,0)
    RETURN
   ENDIF
  ENDIF
  FREE RECORD term_data_batch_for_insert
 END ;Subroutine
 SUBROUTINE (insertallparagraphs(nnoteidx=i4) =null WITH protect)
   DECLARE paragraph_id_cnt = i4 WITH private, constant(size(request->notes[note_index].paragraphs,5)
    )
   SET stat = initrec(para_batch_for_insert)
   SET para_batch_for_insert->number_para_cnt = 0
   SET stat = alterlist(para_batch_for_insert->paras,paragraph_id_cnt)
   FOR (par_index = 1 TO paragraph_id_cnt)
     CALL prepparabatchforinsert(nnoteidx,par_index)
   ENDFOR
   IF (paragraph_id_cnt > 0)
    CALL insertparagraphbatch(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE prepparabatchforinsert(nnoteidx,nparaindex)
   IF ((request->notes[nnoteidx].paragraphs[nparaindex].action_type="DEL"))
    RETURN
   ENDIF
   SET para_batch_for_insert->number_para_cnt += 1
   DECLARE curparapos = f8 WITH protect, noconstant(para_batch_for_insert->number_para_cnt)
   DECLARE temp_event_id = f8 WITH private, noconstant(0.0)
   DECLARE unique_id = f8 WITH private, noconstant(0.0)
   SET unique_id = scdgetuniqueactivityid(null)
   IF (failed=1)
    RETURN
   ENDIF
   SET reply->notes[nnoteidx].paragraphs[nparaindex].scd_paragraph_id = unique_id
   IF ((request->notes[nnoteidx].paragraphs[nparaindex].event_id=0))
    SET temp_event_id = geteventids(request->notes[nnoteidx].paragraphs[nparaindex].reference_nbr)
   ENDIF
   IF (failed=1)
    RETURN
   ENDIF
   SET request->notes[nnoteidx].paragraphs[nparaindex].event_id = temp_event_id
   SET reply->notes[nnoteidx].paragraphs[nparaindex].event_id = temp_event_id
   IF ((request->notes[nnoteidx].paragraphs[nparaindex].paragraph_class_cd=0.0))
    SET request->notes[nnoteidx].paragraphs[nparaindex].paragraph_class_cd = findcodevaluebymeaning(
     14410,nullterm(request->notes[nnoteidx].paragraphs[nparaindex].paragraph_class_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"PARAGRAPH",cps_inval_data_msg,nnoteidx,
      nparaindex,0)
     RETURN
    ENDIF
   ENDIF
   IF ((request->notes[nnoteidx].paragraphs[nparaindex].truth_state_cd=0))
    SET request->notes[nnoteidx].paragraphs[nparaindex].truth_state_cd = findcodevaluebymeaning(15751,
     nullterm(request->notes[nnoteidx].paragraphs[nparaindex].truth_state_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"TRUTH STATE",cps_inval_data_msg,nnoteidx,
      nparaindex,0)
     RETURN
    ENDIF
   ENDIF
   SET para_batch_for_insert->paras[curparapos].scd_paragraph_id = unique_id
   SET para_batch_for_insert->paras[curparapos].scd_story_id = reply->notes[nnoteidx].scd_story_id
   SET para_batch_for_insert->paras[curparapos].scr_paragraph_type_id = request->notes[nnoteidx].
   paragraphs[nparaindex].scr_paragraph_type_id
   SET para_batch_for_insert->paras[curparapos].sequence_number = request->notes[nnoteidx].
   paragraphs[nparaindex].sequence_number
   SET para_batch_for_insert->paras[curparapos].paragraph_class_cd = request->notes[nnoteidx].
   paragraphs[nparaindex].paragraph_class_cd
   SET para_batch_for_insert->paras[curparapos].truth_state_cd = request->notes[nnoteidx].paragraphs[
   nparaindex].truth_state_cd
   SET para_batch_for_insert->paras[curparapos].event_id = request->notes[nnoteidx].paragraphs[
   nparaindex].event_id
   SET number_para_data = size(request->notes[nnoteidx].paragraphs[nparaindex].para_term_data,5)
   IF (number_para_data > 0)
    SET para_batch_for_insert->paras[curparapos].scd_term_data_id = unique_id
   ELSE
    SET para_batch_for_insert->paras[curparapos].scd_term_data_id = 0.0
   ENDIF
   IF (number_para_data > 0)
    CALL addtermdatatobatch(nnoteidx,nparaindex,number_para_data,term_type_para,unique_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE insertparagraphbatch(null)
   IF ((para_batch_for_insert->number_para_cnt > 0))
    INSERT  FROM scd_paragraph p,
      (dummyt d  WITH seq = value(para_batch_for_insert->number_para_cnt))
     SET p.scd_paragraph_id = para_batch_for_insert->paras[d.seq].scd_paragraph_id, p.scd_story_id =
      para_batch_for_insert->paras[d.seq].scd_story_id, p.scr_paragraph_type_id =
      para_batch_for_insert->paras[d.seq].scr_paragraph_type_id,
      p.sequence_number = para_batch_for_insert->paras[d.seq].sequence_number, p.paragraph_class_cd
       = para_batch_for_insert->paras[d.seq].paragraph_class_cd, p.truth_state_cd =
      para_batch_for_insert->paras[d.seq].truth_state_cd,
      p.event_id = para_batch_for_insert->paras[d.seq].event_id, p.scd_term_data_id =
      para_batch_for_insert->paras[d.seq].scd_term_data_id
     PLAN (d)
      JOIN (p)
     WITH nocounter, rdbarrayinsert = 1
    ;end insert
    IF ((curqual != para_batch_for_insert->number_para_cnt))
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING PARAGRAPHS",cps_insert_msg,nnoteidx,
      0,0)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE checkoneventrepstatus(null)
   DECLARE event_cnt = i4 WITH private, noconstant(0)
   IF (validate(event_rep))
    IF ((event_rep->sb.severitycd > 2))
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"Event Server Failed on ensure",cps_insert_msg,0,
      0,0)
     RETURN(0)
    ENDIF
    SET event_cnt = size(event_rep->rb_list,5)
    IF (event_cnt=0)
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"Not events on the reply",cps_insert_msg,0,
      0,0)
     RETURN(0)
    ENDIF
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (fillsentencecodevalues(noteidx=i4,nsentidx=i4) =null WITH protect)
   IF ((request->notes[noteidx].sentences[nsentidx].sentence_class_cd=0))
    SET request->notes[noteidx].sentences[nsentidx].sentence_class_cd = findcodevaluebymeaning(14411,
     nullterm(request->notes[noteidx].sentences[nsentidx].sentence_class_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"SENTENCE CLASS",cps_inval_data_msg,noteidx,
      nsentidx,0)
     RETURN
    ENDIF
   ENDIF
   IF ((request->notes[noteidx].sentences[nsentidx].sentence_topic_cd=0))
    SET request->notes[noteidx].sentences[nsentidx].sentence_topic_cd = findcodevaluebymeaning(14412,
     nullterm(request->notes[noteidx].sentences[nsentidx].sentence_topic_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"SENTENCE TOPIC",cps_inval_data_msg,noteidx,
      nsentidx,0)
     RETURN
    ENDIF
   ENDIF
   IF ((request->notes[noteidx].sentences[nsentidx].text_format_rule_cd=0))
    SET request->notes[noteidx].sentences[nsentidx].text_format_rule_cd = findcodevaluebymeaning(
     14419,nullterm(request->notes[noteidx].sentences[nsentidx].text_format_rule_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"TEXT FORMAT",cps_inval_data_msg,noteidx,
      nsentidx,0)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (filltermcodevalues(noteidx=i4,ntermidx=i4) =null WITH protect)
   IF ((request->notes[noteidx].terms[ntermidx].truth_state_cd=0))
    SET request->notes[noteidx].terms[ntermidx].truth_state_cd = findcodevaluebymeaning(15751,
     nullterm(request->notes[noteidx].terms[ntermidx].truth_state_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"TRUTH STATE",cps_inval_data_msg,noteidx,
      ntermidx,0)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (filltermdatacodevalues(noteidx=i4,ntermidx=i4,ntermdatacnt=i4) =null WITH protect)
   FOR (ntermdataidx = 1 TO ntermdatacnt)
    IF ((request->notes[noteidx].terms[ntermidx].term_data[ntermdataidx].scd_term_data_type_cd=0))
     SET request->notes[noteidx].terms[ntermidx].term_data[ntermdataidx].scd_term_data_type_cd =
     findcodevaluebymeaning(15752,nullterm(request->notes[noteidx].terms[ntermidx].term_data[
       ntermdataidx].scd_term_data_type_mean))
     IF (failed=1)
      CALL cps_add_error(cps_inval_data,cps_script_fail,"TERM DATA TYPE",cps_inval_data_msg,noteidx,
       ntermidx,ntermdataidx)
      RETURN
     ENDIF
    ENDIF
    IF ((request->notes[noteidx].terms[ntermidx].term_data[ntermdataidx].units_cd=0))
     SET request->notes[noteidx].terms[ntermidx].term_data[ntermdataidx].units_cd =
     findcodevaluebymeaning(54,nullterm(request->notes[noteidx].terms[ntermidx].term_data[
       ntermdataidx].units_mean))
     IF (failed=1)
      CALL cps_add_error(cps_inval_data,cps_script_fail,"TERM UNITS",cps_inval_data_msg,noteidx,
       ntermidx,ntermdataidx)
      RETURN
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (fillnotetermdatacodevalues(noteidx=i4,ntermdatacnt=i4) =null WITH protect)
  DECLARE ntermdataidx = i4 WITH protect, noconstant(0)
  FOR (ntermdataidx = 1 TO ntermdatacnt)
   IF ((request->notes[noteidx].note_term_data[ntermdataidx].scd_term_data_type_cd=0))
    SET request->notes[noteidx].note_term_data[ntermdataidx].scd_term_data_type_cd =
    findcodevaluebymeaning(15752,nullterm(request->notes[noteidx].note_term_data[ntermdataidx].
      scd_term_data_type_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"NOTE TERM DATA TYPE",cps_inval_data_msg,
      noteidx,
      ntermdataidx)
     RETURN
    ENDIF
   ENDIF
   IF ((request->notes[noteidx].note_term_data[ntermdataidx].units_cd=0))
    SET request->notes[noteidx].note_term_data[ntermdataidx].units_cd = findcodevaluebymeaning(54,
     nullterm(request->notes[noteidx].note_term_data[ntermdataidx].units_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"NOTE TERM UNITS",cps_inval_data_msg,noteidx,
      ntermdataidx)
     RETURN
    ENDIF
   ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE (getnotetype(index=i4) =i2 WITH protect)
   DECLARE return_value = i2 WITH private, noconstant(note_type_pre)
   CASE (request->notes[index].story_type_mean)
    OF "DEMOG":
     SET return_value = note_type_other
    OF "DOC":
     SET return_value = note_type_other
    OF "EXTENSION":
     SET return_value = note_type_other
    OF "PRE":
     SET return_value = note_type_pre
    OF "PRE PART":
     SET return_value = note_type_pre
    OF "PREPARA":
     SET return_value = note_type_pre
    OF "PRESENT":
     SET return_value = note_type_pre
    OF "PRETERM":
     SET return_value = note_type_pre
    OF "SECT":
     SET return_value = note_type_other
    ELSE
     SET return_value = note_type_other
   ENDCASE
   RETURN(return_value)
 END ;Subroutine
 SUBROUTINE (deleteautosavednoteblob(index=i4) =null WITH protect)
   IF ((request->notes[index].scd_story_id > 0))
    DELETE  FROM long_blob lb
     WHERE (lb.parent_entity_id=request->notes[note_index].scd_story_id)
      AND lb.parent_entity_name="SCD_STORY"
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatestoryorg(scd_story_id=f8,author_id=f8) =null WITH protect)
   DECLARE pref_val = i2 WITH protect, noconstant(0)
   IF (author_id=0.0
    AND validate(ccldminfo->mode,0)
    AND (ccldminfo->sec_org_reltn=1))
    SET pref_val = request->notes[note_index].filter_by_user_org_ind
   ENDIF
   IF (pref_val=1)
    CALL updatestoryorgwithorgids(scd_story_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatestoryorgwithorgids(scd_story_id=f8) =null WITH protect)
   FREE RECORD existing_org_rows
   RECORD existing_org_rows(
     1 rows[*]
       2 org_id = f8
   )
   DECLARE blocks = i4 WITH protect, constant(10)
   DECLARE row_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM scd_story_org_reltn sso
    WHERE sso.scd_story_id=scd_story_id
    HEAD REPORT
     stat = alterlist(existing_org_rows->rows,blocks)
    DETAIL
     row_idx += 1
     IF (mod(row_idx,blocks)=0)
      stat = alterlist(existing_org_rows->rows,(row_idx+ blocks))
     ENDIF
     existing_org_rows->rows[row_idx].org_id = sso.organization_id
    FOOT REPORT
     stat = alterlist(existing_org_rows->rows,row_idx)
    WITH nocounter
   ;end select
   FREE RECORD sac_org
   IF (validate(_sacrtl_org_inc_,99999)=99999)
    DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
    RECORD sac_org(
      1 organizations[*]
        2 organization_id = f8
        2 confid_cd = f8
        2 confid_level = i4
    )
    EXECUTE secrtl
    EXECUTE sacrtl
    DECLARE orgcnt = i4 WITH protected, noconstant(0)
    DECLARE secstat = i2
    DECLARE logontype = i4 WITH protect, noconstant(- (1))
    DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
    DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
    DECLARE dynorg_enabled = i4 WITH constant(1)
    DECLARE dynorg_disabled = i4 WITH constant(0)
    DECLARE logontype_nhs = i4 WITH constant(1)
    DECLARE logontype_legacy = i4 WITH constant(0)
    DECLARE confid_cnt = i4 WITH protected, noconstant(0)
    RECORD confid_codes(
      1 list[*]
        2 code_value = f8
        2 coll_seq = f8
    )
    CALL uar_secgetclientlogontype(logontype)
    CALL echo(build("logontype:",logontype))
    IF (logontype != logontype_nhs)
     SET dynamic_org_ind = dynorg_disabled
    ENDIF
    IF (logontype=logontype_nhs)
     SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
       DECLARE scur_trust = vc
       DECLARE pref_val = vc
       DECLARE is_enabled = i4 WITH constant(1)
       DECLARE is_disabled = i4 WITH constant(0)
       SET scur_trust = cnvtstring(dtrustid)
       SET scur_trust = concat(scur_trust,".00")
       IF ( NOT (validate(pref_req,0)))
        RECORD pref_req(
          1 write_ind = i2
          1 delete_ind = i2
          1 pref[*]
            2 contexts[*]
              3 context = vc
              3 context_id = vc
            2 section = vc
            2 section_id = vc
            2 subgroup = vc
            2 entries[*]
              3 entry = vc
              3 values[*]
                4 value = vc
        )
       ENDIF
       IF ( NOT (validate(pref_rep,0)))
        RECORD pref_rep(
          1 pref[*]
            2 section = vc
            2 section_id = vc
            2 subgroup = vc
            2 entries[*]
              3 pref_exists_ind = i2
              3 entry = vc
              3 values[*]
                4 value = vc
          1 status_data
            2 status = c1
            2 subeventstatus[1]
              3 operationname = c25
              3 operationstatus = c1
              3 targetobjectname = c25
              3 targetobjectvalue = vc
        )
       ENDIF
       SET stat = alterlist(pref_req->pref,1)
       SET stat = alterlist(pref_req->pref[1].contexts,2)
       SET stat = alterlist(pref_req->pref[1].entries,1)
       SET pref_req->pref[1].contexts[1].context = "organization"
       SET pref_req->pref[1].contexts[1].context_id = scur_trust
       SET pref_req->pref[1].contexts[2].context = "default"
       SET pref_req->pref[1].contexts[2].context_id = "system"
       SET pref_req->pref[1].section = "workflow"
       SET pref_req->pref[1].section_id = "UK Trust Security"
       SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
       EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
       IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
        RETURN(is_enabled)
       ELSE
        RETURN(is_disabled)
       ENDIF
     END ;Subroutine
     DECLARE hprop = i4 WITH protect, noconstant(0)
     DECLARE tmpstat = i2
     DECLARE spropname = vc
     DECLARE sroleprofile = vc
     SET hprop = uar_srvcreateproperty()
     SET tmpstat = uar_secgetclientattributesext(5,hprop)
     SET spropname = uar_srvfirstproperty(hprop)
     SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
     SELECT INTO "nl:"
      FROM prsnl_org_reltn_type prt,
       prsnl_org_reltn por
      PLAN (prt
       WHERE prt.role_profile=sroleprofile
        AND prt.active_ind=1
        AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (por
       WHERE (por.organization_id= Outerjoin(prt.organization_id))
        AND (por.person_id= Outerjoin(prt.prsnl_id))
        AND (por.active_ind= Outerjoin(1))
        AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
        AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
      ORDER BY por.prsnl_org_reltn_id
      DETAIL
       orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
       sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
       confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
       sac_org->organizations[1].confid_level =
       IF (confid_cd > 0) confid_cd
       ELSE 0
       ENDIF
      WITH maxrec = 1
     ;end select
     SET dcur_trustid = sac_org->organizations[1].organization_id
     SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
     CALL uar_srvdestroyhandle(hprop)
    ENDIF
    IF (dynamic_org_ind=dynorg_disabled)
     SET confid_cnt = 0
     SELECT INTO "NL:"
      c.code_value, c.collation_seq
      FROM code_value c
      WHERE c.code_set=87
      DETAIL
       confid_cnt += 1
       IF (mod(confid_cnt,10)=1)
        secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
       ENDIF
       confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
       coll_seq = c.collation_seq
      WITH nocounter
     ;end select
     SET secstat = alterlist(confid_codes->list,confid_cnt)
     SELECT DISTINCT INTO "nl:"
      FROM prsnl_org_reltn por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.active_ind=1
       AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,100)
       ENDIF
      DETAIL
       orgcnt += 1
       IF (mod(orgcnt,100)=1)
        secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
       ENDIF
       sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
       orgcnt].confid_cd = por.confid_level_cd
      FOOT REPORT
       secstat = alterlist(sac_org->organizations,orgcnt)
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM (dummyt d1  WITH seq = value(orgcnt)),
       (dummyt d2  WITH seq = value(confid_cnt))
      PLAN (d1)
       JOIN (d2
       WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
      DETAIL
       sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
      WITH nocounter
     ;end select
    ELSEIF (dynamic_org_ind=dynorg_enabled)
     DECLARE nhstrustchild_org_org_reltn_cd = f8
     SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
     SELECT INTO "nl:"
      FROM org_org_reltn oor
      PLAN (oor
       WHERE oor.organization_id=dcur_trustid
        AND oor.active_ind=1
        AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
        AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,10)
       ENDIF
      DETAIL
       IF (oor.related_org_id > 0)
        orgcnt += 1
        IF (mod(orgcnt,10)=1)
         secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
        ENDIF
        sac_org->organizations[orgcnt].organization_id = oor.related_org_id
       ENDIF
      FOOT REPORT
       secstat = alterlist(sac_org->organizations,orgcnt)
      WITH nocounter
     ;end select
    ELSE
     CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
    ENDIF
   ENDIF
   DECLARE existing_row_count = i4 WITH protect, constant(size(existing_org_rows->rows,5))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE locate_idx = i4 WITH protect, noconstant(0)
   DECLARE new_story_org_id = f8 WITH protect, noconstant(0.0)
   DECLARE org_count = i4 WITH protect, constant(size(sac_org->organizations,5))
   IF (org_count=0)
    CALL updatestoryorgwithzero(scd_story_id)
   ELSE
    DECLARE org_idx = i4 WITH protect, noconstant(0)
    FREE RECORD temp_story_org
    RECORD story_org(
      1 fields[*]
        2 scd_story_org_id = f8
        2 scd_story_id = f8
        2 organization_id = f8
        2 updt_applctx = f8
        2 updt_dt_tm = dq8
        2 updt_id = f8
        2 updt_task = i4
    )
    DECLARE new_org_count = i4 WITH protect, noconstant(0)
    FOR (org_idx = 1 TO org_count)
      SET locate_idx = 0
      SET idx = 0
      SET locate_idx = locateval(idx,1,existing_row_count,sac_org->organizations[org_idx].
       organization_id,existing_org_rows->rows[idx].org_id)
      IF (locate_idx=0)
       SET new_org_count += 1
       SET stat = alterlist(story_org->fields,new_org_count)
       SET new_story_org_id = scdgetuniqueactivityid(null)
       SET story_org->fields[new_org_count].scd_story_org_id = new_story_org_id
       SET story_org->fields[new_org_count].scd_story_id = scd_story_id
       SET story_org->fields[new_org_count].organization_id = sac_org->organizations[org_idx].
       organization_id
       SET story_org->fields[new_org_count].updt_applctx = reqinfo->updt_applctx
       SET story_org->fields[new_org_count].updt_dt_tm = cnvtdatetime(sysdate)
       SET story_org->fields[new_org_count].updt_id = reqinfo->updt_id
       SET story_org->fields[new_org_count].updt_task = reqinfo->updt_task
      ENDIF
    ENDFOR
    IF (new_org_count > 0)
     INSERT  FROM scd_story_org_reltn sso,
       (dummyt d  WITH seq = value(new_org_count))
      SET sso.scd_story_org_id = story_org->fields[d.seq].scd_story_org_id, sso.scd_story_id =
       story_org->fields[d.seq].scd_story_id, sso.organization_id = story_org->fields[d.seq].
       organization_id,
       sso.updt_applctx = story_org->fields[d.seq].updt_applctx, sso.updt_dt_tm = cnvtdatetime(
        story_org->fields[d.seq].updt_dt_tm), sso.updt_id = story_org->fields[d.seq].updt_id,
       sso.updt_task = story_org->fields[d.seq].updt_task
      PLAN (d)
       JOIN (sso)
      WITH nocounter, rdbarrayinsert = 1
     ;end insert
     IF (curqual != new_org_count)
      SET failed = 1
      CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING STORY ORGS",cps_insert_msg,0,
       0,0)
      RETURN
     ENDIF
    ENDIF
   ENDIF
   FREE RECORD sac_org
   FREE RECORD existing_org_rows
 END ;Subroutine
 SUBROUTINE (updatestoryorgwithzero(scd_story_id=f8) =null WITH protect)
  SELECT INTO "nl:"
   FROM scd_story_org_reltn sso
   WHERE sso.scd_story_id=scd_story_id
    AND sso.organization_id=0.0
   WITH nocounter
  ;end select
  IF (curqual=0)
   DECLARE new_story_org_id = f8 WITH protect, noconstant(scdgetuniqueactivityid(null))
   INSERT  FROM scd_story_org_reltn sso
    SET sso.scd_story_org_id = new_story_org_id, sso.scd_story_id = scd_story_id, sso.organization_id
      = 0.0,
     sso.updt_applctx = reqinfo->updt_applctx, sso.updt_dt_tm = cnvtdatetime(sysdate), sso.updt_id =
     reqinfo->updt_id,
     sso.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
  ENDIF
 END ;Subroutine
 SUBROUTINE (ensuredictationdata(ensure_type=i2,index=i4) =null WITH protect)
   IF ((request->notes[index].ensure_dict=1))
    FREE RECORD dictdata_req
    FREE RECORD dictdata_rep
    RECORD dictdata_req(
      1 emode = i2
      1 patient_id = f8
      1 encntr_id = f8
      1 event_id = f8
      1 facility_cd = f8
      1 note_type_cd = f8
      1 author_id = f8
      1 priority_ind = i2
      1 total_dict_minutes = f8
    )
    RECORD dictdata_rep(
      1 doc_transcription_queue_id = f8
      1 status_data
        2 status = c1
        2 subeventstatus[*]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    DECLARE devent_id = f8 WITH noconstant(0.0)
    IF ((request->notes[index].total_dict_minutes > 0.0))
     SET dictdata_req->emode = ensure_type
    ELSE
     SET dictdata_req->emode = edel
    ENDIF
    SET dictdata_req->patient_id = request->notes[index].person_id
    SET dictdata_req->encntr_id = request->notes[index].encounter_id
    SET devent_id = request->notes[index].event_id
    IF (devent_id=0.0)
     SET devent_id = geteventids(request->notes[note_index].reference_nbr)
    ENDIF
    SET dictdata_req->event_id = devent_id
    SET dictdata_req->facility_cd = request->notes[index].facility_cd
    SET dictdata_req->note_type_cd = request->notes[index].note_type_cd
    SET dictdata_req->author_id = request->notes[index].author_id
    SET dictdata_req->priority_ind = request->notes[index].priority_ind
    SET dictdata_req->total_dict_minutes = request->notes[index].total_dict_minutes
    CALL echorecord(dictdata_req)
    EXECUTE msvc_ens_trans_queue  WITH replace("REQUEST","DICTDATA_REQ"), replace("REPLY",
     "DICTDATA_REP")
    IF ((dictdata_rep->status_data.status="F"))
     CALL cps_add_error(cps_insert,cps_script_fail,"msvc_ens_trans_queue fail on ensure",
      cps_insert_msg,0,
      0,0)
     SET failed = 1
    ENDIF
    FREE RECORD dictdata_req
    FREE RECORD dictdata_rep
   ENDIF
 END ;Subroutine
 SUBROUTINE storecrossrefmmfdata(index,smmfid,iversion,btextexists)
   DECLARE sentityname = vc WITH protect, noconstant("")
   DECLARE dentityid = f8 WITH protect, noconstant(0.0)
   IF ((request->notes[index].story_completion_status_cd=sotry_completion_status_singed)
    AND btextexists=1)
    SET sentityname = "READYTOPURGE"
   ELSE
    SET sentityname = "SCD_STORY"
    SET dentityid = reply->notes[index].scd_story_id
   ENDIF
   DECLARE hmhandle = i4 WITH noconstant(0)
   SET hmhandle = uar_dmsm_getclassifiedmedia(nullterm(smmfid),iversion)
   IF (hmhandle=0)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,
     "Unable to obtain Handle to MMF Media for XRef Data Update",cps_insert_msg,0,
     0,0)
    RETURN
   ENDIF
   DECLARE hchildproplist = i4 WITH noconstant(0)
   DECLARE hparentproplist = i4 WITH noconstant(0)
   DECLARE rtn = i4 WITH noconstant(0)
   SET hchildproplist = uar_srv_createproplist()
   IF (hchildproplist=0)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"Unable to Create Child PropertlyList",
     cps_insert_msg,0,
     0,0)
    RETURN
   ENDIF
   SET rtn = uar_srv_setpropint(hchildproplist,nullterm(xref_transaction),1)
   IF (rtn != 1)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,
     "Unable to set Transaction Type for MMF XRef Update",cps_insert_msg,0,
     0,0)
    RETURN
   ENDIF
   SET rtn = uar_srv_setpropstring(hchildproplist,nullterm(xref_entity_name),nullterm(sentityname))
   IF (rtn != 1)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,
     "Unable to set Paraent Entity Name for MMF XRef Update",cps_insert_msg,0,
     0,0)
    RETURN
   ENDIF
   SET rtn = uar_srv_setpropreal(hchildproplist,nullterm(xref_entity_id),dentityid)
   IF (rtn != 1)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,
     "Unable to set Parent Entity Id for MMF XRef Update",cps_insert_msg,0,
     0,0)
    RETURN
   ENDIF
   SET hparentproplist = uar_srv_createproplist()
   IF (hparentproplist=0)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,
     "Unable to Create Parent Property LIst for MMF XRef Update",cps_insert_msg,0,
     0,0)
    RETURN
   ENDIF
   SET rtn = uar_srv_setprophandle(hparentproplist,nullterm("0"),hchildproplist,1)
   IF (rtn != 1)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,
     "Unable to Associate Child Property List to Parent Property list for MMF XRef Update",
     cps_insert_msg,0,
     0,0)
    RETURN
   ENDIF
   SET rtn = uar_dmsm_setmediaxref(hmhandle,hparentproplist)
   IF (rtn != 1)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"Unable to Update MMF XRef Data",cps_insert_msg,0,
     0,0)
    RETURN
   ENDIF
   SET rtn = uar_srv_closehandle(hparentproplist)
   RETURN
 END ;Subroutine
 SUBROUTINE (addtermdatatobatch(index=i4,term_index=i4,data_cnt=i4,term_type=i2,term_data_id=f8) =
  null WITH protect)
   DECLARE bdicatedterm = i2 WITH noconstant(0)
   DECLARE smmfid = vc
   DECLARE iversionnum = i4 WITH noconstant(0)
   DECLARE btextexists = i2 WITH noconstant(0)
   DECLARE tempcount = i4 WITH noconstant(0)
   DECLARE curpos = i4 WITH noconstant(0)
   DECLARE termidx = i4 WITH noconstant(0)
   SET tempcount = (term_data_batch_for_insert->cur_data_cnt+ data_cnt)
   SET stat = alterlist(term_data_batch_for_insert->term_data,tempcount)
   SET batch_term_data_cnt += data_cnt
   IF (term_type=term_type_para)
    FOR (termidx = 1 TO data_cnt)
      SET curpos = (term_data_batch_for_insert->cur_data_cnt+ termidx)
      IF ((request->notes[index].paragraphs[term_index].para_term_data[termidx].scd_term_data_type_cd
      =0))
       SET request->notes[index].paragraphs[term_index].para_term_data[termidx].scd_term_data_type_cd
        = findcodevaluebymeaning(15752,nullterm(request->notes[index].paragraphs[term_index].
         para_term_data[termidx].scd_term_data_type_mean))
       IF (failed=1)
        CALL cps_add_error(cps_inval_data,cps_script_fail,"TERM DATA TYPE",cps_inval_data_msg,index,
         term_index,termidx)
        RETURN
       ENDIF
      ENDIF
      IF ((request->notes[index].paragraphs[term_index].para_term_data[termidx].units_cd=0))
       SET request->notes[index].paragraphs[term_index].para_term_data[termidx].units_cd =
       findcodevaluebymeaning(54,nullterm(request->notes[index].paragraphs[term_index].
         para_term_data[termidx].units_mean))
       IF (failed=1)
        CALL cps_add_error(cps_inval_data,cps_script_fail,"UNITS",cps_inval_data_msg,nnoteidx,
         term_index,termidx)
        RETURN
       ENDIF
      ENDIF
      SET term_data_batch_for_insert->term_data[curpos].scd_term_id = term_data_id
      SET term_data_batch_for_insert->term_data[curpos].scd_term_data_type_cd = request->notes[index]
      .paragraphs[term_index].para_term_data[termidx].scd_term_data_type_cd
      SET term_data_batch_for_insert->term_data[curpos].scd_term_data_key = request->notes[index].
      paragraphs[term_index].para_term_data[termidx].scd_term_data_key
      SET term_data_batch_for_insert->term_data[curpos].fkey_id = request->notes[index].paragraphs[
      term_index].para_term_data[termidx].fkey_id
      SET term_data_batch_for_insert->term_data[curpos].fkey_entity_name = request->notes[index].
      paragraphs[term_index].para_term_data[termidx].fkey_entity_name
      SET term_data_batch_for_insert->term_data[curpos].value_number = request->notes[index].
      paragraphs[term_index].para_term_data[termidx].value_number
      SET term_data_batch_for_insert->term_data[curpos].value_dt_tm = request->notes[index].
      paragraphs[term_index].para_term_data[termidx].value_dt_tm
      SET term_data_batch_for_insert->term_data[curpos].value_tz = request->notes[index].paragraphs[
      term_index].para_term_data[termidx].value_tz
      SET term_data_batch_for_insert->term_data[curpos].value_dt_tm_os = request->notes[index].
      paragraphs[term_index].para_term_data[termidx].value_dt_tm_os
      SET term_data_batch_for_insert->term_data[curpos].value_text = request->notes[index].
      paragraphs[term_index].para_term_data[termidx].value_text
      SET term_data_batch_for_insert->term_data[curpos].units_cd = request->notes[index].paragraphs[
      term_index].para_term_data[termidx].units_cd
    ENDFOR
   ELSEIF (term_type=term_type_term)
    CALL filltermdatacodevalues(index,term_index,data_cnt)
    IF (failed=1)
     RETURN
    ENDIF
    FOR (termidx = 1 TO data_cnt)
      IF ((request->notes[index].terms[term_index].term_data[termidx].fkey_id=0)
       AND (request->notes[index].terms[term_index].term_data[termidx].fkey_entity_name=
      "CLINICAL EVENT"))
       SET request->notes[index].terms[term_index].term_data[termidx].fkey_id = geteventids(request->
        notes[index].terms[term_index].term_data[termidx].value_text)
      ENDIF
      SET curpos = (term_data_batch_for_insert->cur_data_cnt+ termidx)
      SET term_data_batch_for_insert->term_data[curpos].scd_term_id = term_data_id
      SET term_data_batch_for_insert->term_data[curpos].scd_term_data_type_cd = request->notes[index]
      .terms[term_index].term_data[termidx].scd_term_data_type_cd
      SET term_data_batch_for_insert->term_data[curpos].scd_term_data_key = request->notes[index].
      terms[term_index].term_data[termidx].scd_term_data_key
      SET term_data_batch_for_insert->term_data[curpos].fkey_id = request->notes[index].terms[
      term_index].term_data[termidx].fkey_id
      SET term_data_batch_for_insert->term_data[curpos].fkey_entity_name = request->notes[index].
      terms[term_index].term_data[termidx].fkey_entity_name
      SET term_data_batch_for_insert->term_data[curpos].value_number = request->notes[index].terms[
      term_index].term_data[termidx].value_number
      SET term_data_batch_for_insert->term_data[curpos].value_dt_tm = request->notes[index].terms[
      term_index].term_data[termidx].value_dt_tm
      SET term_data_batch_for_insert->term_data[curpos].value_tz = request->notes[index].terms[
      term_index].term_data[termidx].value_tz
      SET term_data_batch_for_insert->term_data[curpos].value_dt_tm_os = request->notes[index].terms[
      term_index].term_data[termidx].value_dt_tm_os
      SET term_data_batch_for_insert->term_data[curpos].value_text = request->notes[index].terms[
      term_index].term_data[termidx].value_text
      SET term_data_batch_for_insert->term_data[curpos].units_cd = request->notes[index].terms[
      term_index].term_data[termidx].units_cd
      IF ((term_data_batch_for_insert->term_data[curpos].scd_term_data_key=term_data_key_dictate)
       AND (term_data_batch_for_insert->term_data[curpos].scd_term_data_type_cd=
      term_data_type_dictatedfile))
       SET bdicatedterm = 1
       SET smmfid = term_data_batch_for_insert->term_data[curpos].value_text
      ENDIF
      IF ((term_data_batch_for_insert->term_data[curpos].scd_term_data_key=term_data_key_dictate)
       AND (term_data_batch_for_insert->term_data[curpos].scd_term_data_type_cd=term_data_type_data))
       SET iversionnum = cnvtint(term_data_batch_for_insert->term_data[curpos].value_text)
       IF ((term_data_batch_for_insert->term_data[curpos].value_number=1))
        SET btextexists = 1
       ENDIF
      ENDIF
    ENDFOR
   ELSEIF (term_type=term_type_note)
    CALL fillnotetermdatacodevalues(index,data_cnt)
    IF (failed=1)
     RETURN
    ENDIF
    FOR (termidx = 1 TO data_cnt)
      SET curpos = (term_data_batch_for_insert->cur_data_cnt+ termidx)
      SET term_data_batch_for_insert->term_data[curpos].scd_term_id = term_data_id
      SET term_data_batch_for_insert->term_data[curpos].scd_term_data_type_cd = request->notes[index]
      .note_term_data[termidx].scd_term_data_type_cd
      SET term_data_batch_for_insert->term_data[curpos].scd_term_data_key = request->notes[index].
      note_term_data[termidx].scd_term_data_key
      SET term_data_batch_for_insert->term_data[curpos].fkey_id = request->notes[index].
      note_term_data[termidx].fkey_id
      SET term_data_batch_for_insert->term_data[curpos].fkey_entity_name = request->notes[index].
      note_term_data[termidx].fkey_entity_name
      SET term_data_batch_for_insert->term_data[curpos].value_number = request->notes[index].
      note_term_data[termidx].value_number
      SET term_data_batch_for_insert->term_data[curpos].value_dt_tm = request->notes[index].
      note_term_data[termidx].value_dt_tm
      SET term_data_batch_for_insert->term_data[curpos].value_tz = request->notes[index].
      note_term_data[termidx].value_tz
      SET term_data_batch_for_insert->term_data[curpos].value_dt_tm_os = request->notes[index].
      note_term_data[termidx].value_dt_tm_os
      SET term_data_batch_for_insert->term_data[curpos].value_text = request->notes[index].
      note_term_data[termidx].value_text
      SET term_data_batch_for_insert->term_data[curpos].units_cd = request->notes[index].
      note_term_data[termidx].units_cd
    ENDFOR
   ENDIF
   IF (bdicatedterm=1)
    CALL storecrossrefmmfdata(index,smmfid,iversionnum,btextexists)
   ENDIF
   SET term_data_batch_for_insert->cur_data_cnt += data_cnt
 END ;Subroutine
END GO
