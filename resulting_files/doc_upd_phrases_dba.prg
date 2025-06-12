CREATE PROGRAM doc_upd_phrases:dba
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
 DECLARE scd_db_query_type_name = i4 WITH public, constant(1)
 DECLARE scd_db_query_type_nomen = i4 WITH public, constant(2)
 DECLARE scd_db_query_type_concept = i4 WITH public, constant(3)
 DECLARE scd_db_active = i4 WITH public, constant(1)
 DECLARE scd_db_inactive = i4 WITH public, constant(0)
 DECLARE scd_db_true = i4 WITH public, constant(1)
 DECLARE scd_db_false = i4 WITH public, constant(0)
 DECLARE scd_db_update_lock_lock = i4 WITH public, constant(1)
 DECLARE scd_db_update_lock_override = i4 WITH public, constant(2)
 DECLARE scd_db_update_lock_read_only = i4 WITH public, constant(3)
 DECLARE scd_db_action_type_add = c3 WITH public, constant("ADD")
 DECLARE scd_db_action_type_delete = c3 WITH public, constant("DEL")
 DECLARE scd_db_action_type_update = c3 WITH public, constant("UPD")
 SUBROUTINE cps_add_error(cps_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   SET reply->cps_error.cnt = (reply->cps_error.cnt+ 1)
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
 DECLARE addblobdatatoreply() = null
 RECORD temp_blobs(
   1 note_phrases[*]
     2 note_phrase_comps[*]
       3 blobs[*]
         4 long_blob = vc
         4 blob_len = i4
 )
 RECORD reply(
   1 note_phrases[*]
     2 note_phrase_id = f8
     2 user_id = f8
     2 abbreviation = vc
     2 description = vc
     2 updt_dt_tm = dq8
     2 note_phrase_comps[*]
       3 note_phrase_comp_id = f8
       3 fkey_id = f8
       3 fkey_name = vc
       3 sequence = i4
       3 template_name = vc
       3 template_cki = vc
       3 formatted_text_chunks[*]
         4 chunk = vgc
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
 SUBROUTINE addblobdatatoreply(null)
   DECLARE note_phrases_size = i4 WITH protect, noconstant(0)
   DECLARE comps_size = i4 WITH protect, noconstant(0)
   DECLARE note_phrase_itr = i4 WITH protect, noconstant(0)
   DECLARE blobs_size = i4 WITH protect, noconstant(0)
   DECLARE comps_itr = i4 WITH protect, noconstant(0)
   DECLARE blob_itr = i4 WITH protect, noconstant(0)
   SET note_phrases_size = size(temp_blobs->note_phrases,5)
   DECLARE sdelimiter = c9 WITH constant("<BLOCKID>")
   DECLARE blobtext = vc WITH protect
   FOR (note_phrase_itr = 1 TO note_phrases_size)
    SET comps_size = size(temp_blobs->note_phrases[note_phrase_itr].note_phrase_comps,5)
    FOR (comps_itr = 1 TO comps_size)
     SET blobs_size = size(temp_blobs->note_phrases[note_phrase_itr].note_phrase_comps[comps_itr].
      blobs,5)
     FOR (blob_itr = 1 TO blobs_size)
       SET blobtext = notrim(temp_blobs->note_phrases[note_phrase_itr].note_phrase_comps[comps_itr].
        blobs[blob_itr].long_blob)
       SET iblockpos = findstring(sdelimiter,blobtext,1,0)
       IF (iblockpos > 0)
        SET ibloblen = temp_blobs->note_phrases[note_phrase_itr].note_phrase_comps[comps_itr].blobs[
        blob_itr].blob_len
        IF (size(blobtext,1) > ibloblen)
         SET blobtext = substring(1,ibloblen,blobtext)
        ENDIF
        SET isegmentnum = cnvtint(substring(1,(iblockpos - 1),blobtext))
        IF (isegmentnum > size(reply->note_phrases[note_phrase_itr].note_phrase_comps[comps_itr].
         formatted_text_chunks,5))
         SET stat = alterlist(reply->note_phrases[note_phrase_itr].note_phrase_comps[comps_itr].
          formatted_text_chunks,isegmentnum)
        ENDIF
        IF (blob_itr=blobs_size)
         SET blobtext = trim(blobtext)
         SET ibloblen = size(blobtext,1)
         SET itextsize = (ibloblen - (iblockpos+ 8))
         SET blobtext = substring((iblockpos+ 9),itextsize,blobtext)
        ELSE
         SET itextsize = (ibloblen - (iblockpos+ 8))
         SET blobtext = notrim(substring((iblockpos+ 9),itextsize,blobtext))
        ENDIF
        SET reply->note_phrases[note_phrase_itr].note_phrase_comps[comps_itr].formatted_text_chunks[
        isegmentnum].chunk = notrim(blobtext)
       ELSE
        IF (blob_itr > size(reply->note_phrases[note_phrase_itr].note_phrase_comps[comps_itr].
         formatted_text_chunks,5))
         SET stat = alterlist(reply->note_phrases[note_phrase_itr].note_phrase_comps[comps_itr].
          formatted_text_chunks,blob_itr)
        ENDIF
        SET reply->note_phrases[note_phrase_itr].note_phrase_comps[comps_itr].formatted_text_chunks[
        blob_itr].chunk = trim(blobtext)
       ENDIF
     ENDFOR
    ENDFOR
   ENDFOR
 END ;Subroutine
 DECLARE failed = i2 WITH public, noconstant(0)
 DECLARE number_phrases = i4 WITH public, constant(size(request->note_phrases,5))
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF ((request->action="ADD"))
  CALL addnotephrases(null)
 ELSEIF ((request->action="UPDATE"))
  CALL updatenotephrases(null)
 ELSEIF ((request->action="DELETE"))
  CALL deletenotephrases(null)
 ELSE
  SET failed = 1
 ENDIF
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SUBROUTINE addnotephrases(null)
   DECLARE cur_phrase = i4 WITH protect, noconstant(0)
   DECLARE cur_phrase_id = f8 WITH protect, noconstant(0.0)
   SET stat = alterlist(reply->note_phrases,number_phrases)
   FOR (cur_phrase = 1 TO number_phrases)
     SET cur_phrase_id = scdgetuniqueid(null)
     IF (failed=1)
      GO TO exit_script
     ENDIF
     SET reply->note_phrases[cur_phrase].note_phrase_id = cur_phrase_id
     SET reply->note_phrases[cur_phrase].updt_dt_tm = cnvtdatetime(curdate,curtime3)
     INSERT  FROM note_phrase n
      SET n.note_phrase_id = cur_phrase_id, n.abbreviation = request->note_phrases[cur_phrase].
       abbreviation, n.abb_description = request->note_phrases[cur_phrase].description,
       n.prsnl_id = request->note_phrases[cur_phrase].user_id, n.updt_id = reqinfo->updt_id, n
       .updt_dt_tm = cnvtdatetime(reply->note_phrases[cur_phrase].updt_dt_tm),
       n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = 1
      CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING NOTE_PHRASE",cps_insert_msg,0,
       0,0)
      GO TO exit_script
     ENDIF
     CALL addnotephrasecomps(cur_phrase,cur_phrase_id)
   ENDFOR
 END ;Subroutine
 SUBROUTINE updatenotephrases(null)
   DECLARE cur_phrase = i4 WITH protect, noconstant(0)
   DECLARE cur_phrase_id = f8 WITH protect, noconstant(0.0)
   DECLARE updt_cnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(reply->note_phrases,number_phrases)
   FOR (cur_phrase = 1 TO number_phrases)
     SET cur_phrase_id = request->note_phrases[cur_phrase].note_phrase_id
     SELECT INTO "nl:"
      FROM note_phrase n
      WHERE n.note_phrase_id=cur_phrase_id
      DETAIL
       updt_cnt = n.updt_cnt
      WITH forupdatewait(n)
     ;end select
     CALL deletenotephrasecomps(cur_phrase_id)
     SET reply->note_phrases[cur_phrase].note_phrase_id = cur_phrase_id
     SET reply->note_phrases[cur_phrase].updt_dt_tm = cnvtdatetime(curdate,curtime3)
     UPDATE  FROM note_phrase n
      SET n.abbreviation = request->note_phrases[cur_phrase].abbreviation, n.abb_description =
       request->note_phrases[cur_phrase].description, n.prsnl_id = request->note_phrases[cur_phrase].
       user_id,
       n.updt_cnt = (updt_cnt+ 1), n.updt_id = reqinfo->updt_id, n.updt_dt_tm = cnvtdatetime(reply->
        note_phrases[cur_phrase].updt_dt_tm),
       n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->updt_applctx
      WHERE n.note_phrase_id=cur_phrase_id
      WITH nocounter
     ;end update
     IF (curqual != 1)
      SET failed = 1
      CALL cps_add_error(cps_update,cps_script_fail,"UPDATING NOTE_PHRASE",cps_update_msg,0,
       0,0)
      RETURN
     ENDIF
     CALL addnotephrasecomps(cur_phrase,cur_phrase_id)
   ENDFOR
 END ;Subroutine
 SUBROUTINE addnotephrasecomps(cur_phrase,cur_phrase_id)
   DECLARE comp_id = f8 WITH protect, noconstant(0.0)
   DECLARE cur_comp = i4 WITH protect, noconstant(0)
   DECLARE number_chunks = i4 WITH protect, noconstant(0)
   DECLARE number_phrase_comps = i4 WITH protect, noconstant(size(request->note_phrases[cur_phrase].
     note_phrase_comps,5))
   SET stat = alterlist(reply->note_phrases[cur_phrase].note_phrase_comps,number_phrase_comps)
   FOR (cur_comp = 1 TO number_phrase_comps)
     SET comp_id = scdgetuniqueid(null)
     IF (failed=1)
      GO TO exit_script
     ENDIF
     SET reply->note_phrases[cur_phrase].note_phrase_comps[cur_comp].note_phrase_comp_id = comp_id
     INSERT  FROM note_phrase_comp nc
      SET nc.note_phrase_comp_id = comp_id, nc.note_phrase_id = cur_phrase_id, nc.fkey_name = request
       ->note_phrases[cur_phrase].note_phrase_comps[cur_comp].fkey_name,
       nc.fkey_id = request->note_phrases[cur_phrase].note_phrase_comps[cur_comp].fkey_id, nc
       .sequence = request->note_phrases[cur_phrase].note_phrase_comps[cur_comp].sequence, nc.updt_id
        = reqinfo->updt_id,
       nc.updt_dt_tm = cnvtdatetime(curdate,curtime3), nc.updt_task = reqinfo->updt_task, nc
       .updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = 1
      CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING NOTE_PHRASE_COMP",cps_insert_msg,0,
       0,0)
      GO TO exit_script
     ENDIF
     SET number_chunks = size(request->note_phrases[cur_phrase].note_phrase_comps[cur_comp].
      formatted_text_chunks,5)
     IF (number_chunks > 0)
      INSERT  FROM long_blob_reference b,
        (dummyt d  WITH seq = value(number_chunks))
       SET b.long_blob_id = cnvtreal(seq(long_data_seq,nextval)), b.parent_entity_name =
        "NOTE_PHRASE_COMP", b.parent_entity_id = comp_id,
        b.long_blob = request->note_phrases[cur_phrase].note_phrase_comps[cur_comp].
        formatted_text_chunks[d.seq].chunk, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
        updt_applctx,
        b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        b.active_status_prsnl_id = reqinfo->updt_id
       PLAN (d)
        JOIN (b)
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = 1
       CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING LONG_BLOB_REFERENCE",cps_insert_msg,0,
        0,0)
       GO TO exit_script
      ENDIF
     ENDIF
     IF ((request->note_phrases[cur_phrase].note_phrase_comps[cur_comp].fkey_name=
     "CLINICAL_NOTE_TEMPLATE"))
      CALL gettemplatetext(cur_phrase,cur_comp)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE deletenotephrases(null)
   DECLARE cur_phrase = i4 WITH protect, noconstant(0)
   DECLARE cur_phrase_id = f8 WITH protect, noconstant(0.0)
   FOR (cur_phrase = 1 TO number_phrases)
     SET cur_phrase_id = request->note_phrases[cur_phrase].note_phrase_id
     CALL deletenotephrasecomps(cur_phrase_id)
     DELETE  FROM note_phrase n
      WHERE n.note_phrase_id=cur_phrase_id
      WITH nocounter
     ;end delete
   ENDFOR
 END ;Subroutine
 SUBROUTINE deletenotephrasecomps(cur_phrase_id)
  DELETE  FROM long_blob_reference b
   WHERE b.parent_entity_id IN (
   (SELECT
    note_phrase_comp_id
    FROM note_phrase_comp nc
    WHERE nc.note_phrase_id=cur_phrase_id
     AND nc.fkey_name="LONG_BLOB_REFERENCE"))
    AND b.parent_entity_name="NOTE_PHRASE_COMP"
   WITH nocounter
  ;end delete
  DELETE  FROM note_phrase_comp nc
   WHERE nc.note_phrase_id=cur_phrase_id
   WITH nocounter
  ;end delete
 END ;Subroutine
 SUBROUTINE gettemplatetext(cur_phrase,cur_comp)
   DECLARE next_chunk = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM long_blob b
    PLAN (b
     WHERE (b.parent_entity_id=request->note_phrases[cur_phrase].note_phrase_comps[cur_comp].fkey_id)
      AND b.parent_entity_name="CLINICAL_NOTE_TEMPLATE")
    ORDER BY b.long_blob_id
    HEAD REPORT
     idx = 0
    DETAIL
     IF (b.parent_entity_id != 0)
      IF (cur_phrase > size(temp_blobs->note_phrases,5))
       stat = alterlist(temp_blobs->note_phrases,cur_phrase)
      ENDIF
      IF (cur_comp > size(temp_blobs->note_phrases[cur_phrase].note_phrase_comps,5))
       stat = alterlist(temp_blobs->note_phrases[cur_phrase].note_phrase_comps,cur_comp)
      ENDIF
      next_chunk = size(temp_blobs->note_phrases[cur_phrase].note_phrase_comps[cur_comp].blobs,5),
      next_chunk = (next_chunk+ 1), stat = alterlist(temp_blobs->note_phrases[cur_phrase].
       note_phrase_comps[cur_comp].blobs,next_chunk),
      temp_blobs->note_phrases[cur_phrase].note_phrase_comps[cur_comp].blobs[next_chunk].long_blob =
      notrim(b.long_blob), temp_blobs->note_phrases[cur_phrase].note_phrase_comps[cur_comp].blobs[
      next_chunk].blob_len = b.blob_length
     ENDIF
    WITH nocounter
   ;end select
   CALL addblobdatatoreply(null)
 END ;Subroutine
END GO
