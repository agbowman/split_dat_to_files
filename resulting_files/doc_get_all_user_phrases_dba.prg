CREATE PROGRAM doc_get_all_user_phrases:dba
 FREE RECORD long_blob_ref_ids
 RECORD long_blob_ref_ids(
   1 comps[*]
     2 phrase_idx = f8
     2 comp_idx = f8
     2 comp_id = f8
 )
 FREE RECORD clin_note_temp_ids
 RECORD clin_note_temp_ids(
   1 comps[*]
     2 phrase_idx = f8
     2 comp_idx = f8
     2 clin_note_temp_id = f8
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
 DECLARE big_blocks = i4 WITH public, constant(50)
 DECLARE small_blocks = i4 WITH public, constant(10)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 CALL getnotephrases(null)
 CALL getlongblobrefdata(null)
 CALL getclinicalnotetemplatedata(null)
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SUBROUTINE getnotephrases(null)
   DECLARE clin_note_temp_idx = i4 WITH protect, noconstant(0)
   DECLARE comp_idx = i4 WITH protect, noconstant(0)
   DECLARE long_blob_ref_idx = i4 WITH protect, noconstant(0)
   DECLARE phrase_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM note_phrase p,
     note_phrase_comp c
    PLAN (p
     WHERE p.note_phrase_id > 0
      AND (p.prsnl_id=request->user_id))
     JOIN (c
     WHERE p.note_phrase_id=c.note_phrase_id)
    ORDER BY p.note_phrase_id, c.sequence
    HEAD p.note_phrase_id
     IF (mod(phrase_idx,big_blocks)=0)
      stat = alterlist(reply->note_phrases,(phrase_idx+ big_blocks))
     ENDIF
     IF (comp_idx > 0)
      stat = alterlist(reply->note_phrases[phrase_idx].note_phrase_comps,comp_idx)
     ENDIF
     phrase_idx = (phrase_idx+ 1), comp_idx = 0, reply->note_phrases[phrase_idx].note_phrase_id = p
     .note_phrase_id,
     reply->note_phrases[phrase_idx].user_id = p.prsnl_id, reply->note_phrases[phrase_idx].
     abbreviation = p.abbreviation, reply->note_phrases[phrase_idx].description = p.abb_description,
     reply->note_phrases[phrase_idx].updt_dt_tm = p.updt_dt_tm
    HEAD c.sequence
     IF (mod(comp_idx,small_blocks)=0)
      stat = alterlist(reply->note_phrases[phrase_idx].note_phrase_comps,(comp_idx+ small_blocks))
     ENDIF
     comp_idx = (comp_idx+ 1), reply->note_phrases[phrase_idx].note_phrase_comps[comp_idx].
     note_phrase_comp_id = c.note_phrase_comp_id, reply->note_phrases[phrase_idx].note_phrase_comps[
     comp_idx].fkey_id = c.fkey_id,
     reply->note_phrases[phrase_idx].note_phrase_comps[comp_idx].fkey_name = c.fkey_name, reply->
     note_phrases[phrase_idx].note_phrase_comps[comp_idx].sequence = c.sequence
     IF (c.fkey_name="LONG_BLOB_REFERENCE")
      IF (mod(long_blob_ref_idx,big_blocks)=0)
       stat = alterlist(long_blob_ref_ids->comps,(long_blob_ref_idx+ big_blocks))
      ENDIF
      long_blob_ref_idx = (long_blob_ref_idx+ 1), long_blob_ref_ids->comps[long_blob_ref_idx].
      phrase_idx = phrase_idx, long_blob_ref_ids->comps[long_blob_ref_idx].comp_idx = comp_idx,
      long_blob_ref_ids->comps[long_blob_ref_idx].comp_id = c.note_phrase_comp_id
     ELSEIF (c.fkey_name="CLINICAL_NOTE_TEMPLATE")
      IF (mod(clin_note_temp_idx,big_blocks)=0)
       stat = alterlist(clin_note_temp_ids->comps,(clin_note_temp_idx+ big_blocks))
      ENDIF
      clin_note_temp_idx = (clin_note_temp_idx+ 1), clin_note_temp_ids->comps[clin_note_temp_idx].
      phrase_idx = phrase_idx, clin_note_temp_ids->comps[clin_note_temp_idx].comp_idx = comp_idx,
      clin_note_temp_ids->comps[clin_note_temp_idx].clin_note_temp_id = c.fkey_id
     ELSEIF (c.fkey_name="CODE_VALUE")
      reply->note_phrases[phrase_idx].note_phrase_comps[comp_idx].template_cki = uar_get_code_cki(c
       .fkey_id)
     ENDIF
    FOOT REPORT
     IF (phrase_idx > 0)
      stat = alterlist(reply->note_phrases[phrase_idx].note_phrase_comps,comp_idx), stat = alterlist(
       reply->note_phrases,phrase_idx), stat = alterlist(long_blob_ref_ids->comps,long_blob_ref_idx),
      stat = alterlist(clin_note_temp_ids->comps,clin_note_temp_idx)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getlongblobrefdata(null)
   DECLARE comp_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE find_idx = i4 WITH protect, noconstant(0)
   DECLARE next_chunk = i4 WITH protect, noconstant(0)
   DECLARE phrase_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH public, constant(100)
   DECLARE total_ids = i4 WITH protect, constant(size(long_blob_ref_ids->comps,5))
   IF (total_ids != 0)
    DECLARE expand_blocks = i4 WITH protect, constant(ceil((total_ids/ (1.0 * expand_size))))
    DECLARE total_items = i4 WITH protect, constant((expand_blocks * expand_size))
    SET stat = alterlist(long_blob_ref_ids->comps,total_items)
    FOR (comp_idx = (total_ids+ 1) TO total_items)
      SET long_blob_ref_ids->comps[comp_idx].comp_id = long_blob_ref_ids->comps[total_ids].comp_id
      SET long_blob_ref_ids->comps[comp_idx].comp_idx = 0
      SET long_blob_ref_ids->comps[comp_idx].phrase_idx = 0
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((total_items - 1)/ expand_size)))),
      long_blob_reference b
     PLAN (d
      WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
      JOIN (b
      WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),b.parent_entity_id,
       long_blob_ref_ids->comps[expand_idx].comp_id)
       AND b.parent_entity_name="NOTE_PHRASE_COMP")
     ORDER BY b.parent_entity_id, b.long_blob_id
     HEAD REPORT
      find_idx = 0, idx = 0
     DETAIL
      IF (b.parent_entity_id != 0)
       find_idx = locateval(idx,1,total_items,b.parent_entity_id,long_blob_ref_ids->comps[idx].
        comp_id)
       IF (find_idx != 0)
        comp_idx = long_blob_ref_ids->comps[find_idx].comp_idx, phrase_idx = long_blob_ref_ids->
        comps[find_idx].phrase_idx, next_chunk = size(reply->note_phrases[phrase_idx].
         note_phrase_comps[comp_idx].formatted_text_chunks,5),
        next_chunk = (next_chunk+ 1), stat = alterlist(reply->note_phrases[phrase_idx].
         note_phrase_comps[comp_idx].formatted_text_chunks,next_chunk), reply->note_phrases[
        phrase_idx].note_phrase_comps[comp_idx].formatted_text_chunks[next_chunk].chunk = b.long_blob
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE getclinicalnotetemplatedata(null)
   DECLARE comp_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE find_idx = i4 WITH protect, noconstant(0)
   DECLARE phrase_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH public, constant(100)
   DECLARE total_ids = i4 WITH protect, constant(size(clin_note_temp_ids->comps,5))
   DECLARE expand_blocks = i4 WITH protect, constant(ceil((total_ids/ (1.0 * expand_size))))
   DECLARE total_items = i4 WITH protect, constant((expand_blocks * expand_size))
   IF (total_ids != 0)
    SET stat = alterlist(clin_note_temp_ids->comps,total_items)
    FOR (comp_idx = (total_ids+ 1) TO total_items)
      SET clin_note_temp_ids->comps[comp_idx].clin_note_temp_id = clin_note_temp_ids->comps[total_ids
      ].clin_note_temp_id
      SET clin_note_temp_ids->comps[comp_idx].comp_idx = 0
      SET clin_note_temp_ids->comps[comp_idx].phrase_idx = 0
    ENDFOR
    SET expand_start = 1
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((total_items - 1)/ expand_size)))),
      clinical_note_template t
     PLAN (d
      WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
      JOIN (t
      WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),t.template_id,
       clin_note_temp_ids->comps[expand_idx].clin_note_temp_id))
     HEAD REPORT
      find_idx = 0, idx = 0
     DETAIL
      IF (t.template_id != 0)
       find_idx = locateval(idx,1,total_items,t.template_id,clin_note_temp_ids->comps[idx].
        clin_note_temp_id)
       WHILE (find_idx != 0)
         comp_idx = clin_note_temp_ids->comps[find_idx].comp_idx, phrase_idx = clin_note_temp_ids->
         comps[find_idx].phrase_idx, reply->note_phrases[phrase_idx].note_phrase_comps[comp_idx].
         template_name = t.template_name,
         reply->note_phrases[phrase_idx].note_phrase_comps[comp_idx].template_cki = t.cki, find_idx
          = locateval(find_idx,(find_idx+ 1),total_items,t.template_id,clin_note_temp_ids->comps[
          find_idx].clin_note_temp_id)
       ENDWHILE
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
END GO
