CREATE PROGRAM cps_get_scd_note_detail:dba
 RECORD reply(
   1 notes[*]
     2 scd_story_id = f8
     2 person_id = f8
     2 encounter_id = f8
     2 story_type_cd = f8
     2 story_type_mean = vc
     2 title = vc
     2 story_completion_status_cd = f8
     2 story_completion_status_mean = vc
     2 author_id = f8
     2 event_id = f8
     2 update_lock_user_id = f8
     2 update_lock_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_mean = vc
     2 entry_mode_cd = f8
     2 entry_mode_mean = vc
     2 concepts[*]
       3 concept_cki = vc
       3 concept_display = vc
       3 concept_type_flag = i2
       3 diagnosis_group_id = f8
     2 scr_pattern_ids[*]
       3 scr_pattern_id = f8
       3 scr_paragraph_type_id = f8
       3 pattern_type_cd = f8
     2 paragraphs[*]
       3 scd_paragraph_id = f8
       3 scr_paragraph_type_id = f8
       3 sequence_number = f8
       3 paragraph_class_cd = f8
       3 paragraph_class_mean = vc
     2 sentences[*]
       3 scd_sentence_id = f8
       3 scd_paragraph_id = f8
       3 scr_term_hier_id = f8
       3 sequence_number = i4
       3 can_sent_pat_cki_source = vc
       3 can_sent_pat_cki_identifier = vc
       3 sentence_class_cd = f8
       3 sentence_class_mean = vc
       3 sentence_topic_cd = f8
       3 text_format_rule_cd = f8
       3 text_format_rule_mean = vc
       3 sentence_topic_mean = vc
       3 author_persnl_id = f8
       3 updt_dt_tm = dq8
       3 updt_cnt = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_mean = vc
     2 terms[*]
       3 scd_term_id = f8
       3 scr_term_id = f8
       3 scd_sentence_id = f8
       3 scr_term_hier_id = f8
       3 sequence_number = i4
       3 concept_source_cd = f8
       3 concept_identifier = vc
       3 truth_state_cd = f8
       3 truth_state_mean = vc
       3 parent_scd_term_id = f8
       3 scd_phrase_type_id = f8
       3 term_data[*]
         4 scd_term_data_type_cd = f8
         4 scr_term_data_type_mean = vc
         4 scd_term_data_key = vc
         4 fkey_id = f8
         4 fkey_entity_name = vc
         4 value_number = f8
         4 value_dt_tm = dq8
         4 value_tz = i4
         4 value_dt_tm_os = f8
         4 value_text = vc
         4 units_cd = f8
         4 units_mean = vc
         4 value_binary = vgc
         4 format_cd = f8
         4 format_mean = vc
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
 DECLARE locked_user_id = f8 WITH public, noconstant(0.0)
 DECLARE failed = i2 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET failed = 0
 SET number_to_get = size(request->notes,5)
 IF (number_to_get=0)
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No Notes In Request",cps_insuf_data_msg,inx0,
   0,0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->notes,value(number_to_get))
 FOR (inx0 = 1 TO number_to_get)
   IF ((((request->notes[inx0].update_lock_flag < scd_db_update_lock_lock)) OR ((request->notes[inx0]
   .update_lock_flag > scd_db_update_lock_read_only))) )
    SET failed = 1
    CALL cps_add_error(cps_insuf_data,cps_script_fail,"No Locking Parameter Defined",
     cps_insuf_data_msg,inx0,
     0,0)
    GO TO exit_script
   ENDIF
   IF ((request->notes[inx0].id=0.0))
    CALL cps_add_error(cps_select,cps_script_fail,"Invalid Note ID Found",cps_select_msg,inx0,
     0,0)
    GO TO exit_script
   ENDIF
   IF ((((request->notes[inx0].update_lock_flag=scd_db_update_lock_lock)) OR ((request->notes[inx0].
   update_lock_flag=scd_db_update_lock_override))) )
    SET locked_user_id = 0.0
    CALL checklockpattern(inx0)
    IF (failed=1)
     CALL cps_add_error(cps_lock,cps_script_fail,"Couldn't Lock the Note(s)",cps_lock_msg,inx0,
      0,0)
     GO TO exit_script
    ENDIF
    IF (((locked_user_id=0.0) OR ((((locked_user_id=reqinfo->updt_id)) OR ((request->notes[inx0].
    update_lock_flag=scd_db_update_lock_override))) )) )
     CALL setlock(inx0)
     IF (failed=1)
      CALL cps_add_error(cps_update,cps_script_fail,"Couldn't Update Lock Info ",cps_update_msg,inx0,
       0,0)
      GO TO exit_script
     ENDIF
    ELSE
     SET failed = 1
     CALL cps_add_error(cps_lock,cps_script_fail,"Note already locked",cps_lock_msg,inx0,
      locked_user_id,0)
     GO TO exit_script
    ENDIF
   ENDIF
   CALL fillnoteandparagraphstruct(inx0)
   CALL fillscr_pattern_idsstruct(inx0)
   CALL fillsentencestruct(inx0)
   CALL filltermstruct(inx0)
   CALL fillconceptstruct(inx0)
 ENDFOR
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SUBROUTINE checklockpattern(index)
  SELECT INTO "NL:"
   FROM scd_story s
   WHERE (s.scd_story_id=request->notes[index].id)
   DETAIL
    locked_user_id = s.update_lock_user_id
   WITH nocounter, forupdatewait(s)
  ;end select
  IF (curqual=0)
   SET failed = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE setlock(index)
  UPDATE  FROM scd_story s
   SET s.update_lock_user_id = reqinfo->updt_id, s.update_lock_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (s.scd_story_id=request->notes[index].id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE fillnoteandparagraphstruct(index)
   SELECT INTO "NL:"
    note_id = note.scd_story_id"###########################"
    FROM scd_paragraph par,
     scd_story note
    WHERE (note.scd_story_id=request->notes[index].id)
     AND par.scd_story_id=note.scd_story_id
    HEAD REPORT
     par_idx = 0
    HEAD note_id
     reply->notes[index].scd_story_id = note.scd_story_id, reply->notes[index].person_id = note
     .person_id, reply->notes[index].encounter_id = note.encounter_id,
     reply->notes[index].story_type_cd = note.story_type_cd, reply->notes[index].title = note.title,
     reply->notes[index].story_completion_status_cd = note.story_completion_status_cd,
     reply->notes[index].author_id = note.author_id, reply->notes[index].event_id = note.event_id,
     reply->notes[index].update_lock_user_id = note.update_lock_user_id,
     reply->notes[index].update_lock_dt_tm = cnvtdatetime(note.update_lock_dt_tm), reply->notes[index
     ].updt_dt_tm = cnvtdatetime(note.updt_dt_tm), reply->notes[index].updt_cnt = note.updt_cnt,
     reply->notes[index].active_status_cd = note.active_status_cd, reply->notes[index].active_ind =
     note.active_ind, reply->notes[index].entry_mode_cd = note.entry_mode_cd
    DETAIL
     par_idx = (par_idx+ 1)
     IF (mod(par_idx,10)=1)
      stat = alterlist(reply->notes[index].paragraphs,(par_idx+ 10))
     ENDIF
     reply->notes[index].paragraphs[par_idx].scd_paragraph_id = par.scd_paragraph_id, reply->notes[
     index].paragraphs[par_idx].scr_paragraph_type_id = par.scr_paragraph_type_id, reply->notes[index
     ].paragraphs[par_idx].sequence_number = par.sequence_number,
     reply->notes[index].paragraphs[par_idx].paragraph_class_cd = par.paragraph_class_cd
    FOOT REPORT
     stat = alterlist(reply->notes[index].paragraphs,par_idx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE fillscr_pattern_idsstruct(index)
   SELECT INTO "NL:"
    FROM scd_story_pattern pat,
     scd_story note
    WHERE (note.scd_story_id=request->notes[index].id)
     AND pat.scd_story_id=note.scd_story_id
    HEAD REPORT
     pat_idx = 0
    DETAIL
     pat_idx = (pat_idx+ 1)
     IF (mod(pat_idx,10)=1)
      stat = alterlist(reply->notes[index].scr_pattern_ids,(pat_idx+ 10))
     ENDIF
     reply->notes[index].scr_pattern_ids[pat_idx].scr_pattern_id = pat.scr_pattern_id, reply->notes[
     index].scr_pattern_ids[pat_idx].scr_paragraph_type_id = pat.scr_paragraph_type_id, reply->notes[
     index].scr_pattern_ids[pat_idx].pattern_type_cd = pat.pattern_type_cd
    FOOT REPORT
     stat = alterlist(reply->notes[index].scr_pattern_ids,pat_idx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE fillsentencestruct(index)
   SELECT INTO "NL:"
    FROM scd_sentence sent
    WHERE (sent.scd_story_id=request->notes[index].id)
    HEAD REPORT
     sent_idx = 0
    DETAIL
     sent_idx = (sent_idx+ 1)
     IF (mod(sent_idx,10)=1)
      stat = alterlist(reply->notes[index].sentences,(sent_idx+ 10))
     ENDIF
     reply->notes[index].sentences[sent_idx].scd_sentence_id = sent.scd_sentence_id, reply->notes[
     index].sentences[sent_idx].scd_paragraph_id = sent.scd_paragraph_id, reply->notes[index].
     sentences[sent_idx].scr_term_hier_id = sent.scr_term_hier_id,
     reply->notes[index].sentences[sent_idx].sequence_number = sent.sequence_number, reply->notes[
     index].sentences[sent_idx].can_sent_pat_cki_source = sent.can_sent_pat_cki_source, reply->notes[
     index].sentences[sent_idx].can_sent_pat_cki_identifier = sent.can_sent_pat_cki_identifier,
     reply->notes[index].sentences[sent_idx].sentence_class_cd = sent.sentence_class_cd, reply->
     notes[index].sentences[sent_idx].sentence_topic_cd = sent.sentence_topic_cd, reply->notes[index]
     .sentences[sent_idx].text_format_rule_cd = sent.text_format_rule_cd,
     reply->notes[index].sentences[sent_idx].author_persnl_id = sent.author_persnl_id, reply->notes[
     index].sentences[sent_idx].updt_dt_tm = sent.updt_dt_tm, reply->notes[index].sentences[sent_idx]
     .updt_cnt = sent.updt_cnt,
     reply->notes[index].sentences[sent_idx].active_ind = sent.active_ind, reply->notes[index].
     sentences[sent_idx].active_status_cd = sent.active_status_cd
    FOOT REPORT
     stat = alterlist(reply->notes[index].sentences,sent_idx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE filltermstruct(index)
   SELECT INTO "NL:"
    term_id = term.scd_term_id"###########################"
    FROM scd_term_data td,
     scd_term term
    WHERE (term.scd_story_id=request->notes[index].id)
     AND td.scd_term_data_id=term.scd_term_data_id
    HEAD REPORT
     term_idx = 0
    HEAD term_id
     term_idx = (term_idx+ 1)
     IF (mod(term_idx,100)=1)
      stat = alterlist(reply->notes[index].terms,(term_idx+ 100))
     ENDIF
     term_dat_idx = 0, reply->notes[index].terms[term_idx].scd_term_id = term.scd_term_id, reply->
     notes[index].terms[term_idx].scr_term_id = term.scr_term_id,
     reply->notes[index].terms[term_idx].scd_sentence_id = term.scd_sentence_id, reply->notes[index].
     terms[term_idx].scr_term_hier_id = term.scr_term_hier_id, reply->notes[index].terms[term_idx].
     sequence_number = term.sequence_number,
     reply->notes[index].terms[term_idx].concept_source_cd = term.concept_source_cd, reply->notes[
     index].terms[term_idx].concept_identifier = term.concept_identifier, reply->notes[index].terms[
     term_idx].truth_state_cd = term.truth_state_cd,
     reply->notes[index].terms[term_idx].parent_scd_term_id = term.parent_scd_term_id, reply->notes[
     index].terms[term_idx].scd_phrase_type_id = term.scd_phrase_type_id
    DETAIL
     IF (td.scd_term_data_id != 0)
      term_dat_idx = (term_dat_idx+ 1)
      IF (mod(term_dat_idx,5)=1)
       stat = alterlist(reply->notes[index].terms[term_idx].term_data,(term_dat_idx+ 5))
      ENDIF
      reply->notes[index].terms[term_idx].term_data[term_dat_idx].scd_term_data_type_cd = td
      .scd_term_data_type_cd, reply->notes[index].terms[term_idx].term_data[term_dat_idx].
      scd_term_data_key = td.scd_term_data_key, reply->notes[index].terms[term_idx].term_data[
      term_dat_idx].fkey_id = td.fkey_id,
      reply->notes[index].terms[term_idx].term_data[term_dat_idx].fkey_entity_name = td
      .fkey_entity_name, reply->notes[index].terms[term_idx].term_data[term_dat_idx].value_number =
      td.value_number, reply->notes[index].terms[term_idx].term_data[term_dat_idx].value_dt_tm = td
      .value_dt_tm,
      reply->notes[index].terms[term_idx].term_data[term_dat_idx].value_tz = td.value_tz, reply->
      notes[index].terms[term_idx].term_data[term_dat_idx].value_dt_tm_os = td.value_dt_tm_os, reply
      ->notes[index].terms[term_idx].term_data[term_dat_idx].value_text = td.value_text,
      reply->notes[index].terms[term_idx].term_data[term_dat_idx].units_cd = td.units_cd
     ENDIF
    FOOT  term_id
     stat = alterlist(reply->notes[index].terms[term_idx].term_data,term_dat_idx)
    FOOT REPORT
     stat = alterlist(reply->notes[index].terms,term_idx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE fillconceptstruct(index)
   SELECT INTO "nl:"
    FROM scd_story_concept ssc
    WHERE (ssc.scd_story_id=reply->notes[index].scd_story_id)
    HEAD REPORT
     concept_idx = 0
    DETAIL
     concept_idx = (concept_idx+ 1)
     IF (mod(concept_idx,5)=1)
      stat = alterlist(reply->notes[index].concepts,(concept_idx+ 5))
     ENDIF
     reply->notes[index].concepts[concept_idx].concept_cki = ssc.concept_cki, reply->notes[index].
     concepts[concept_idx].concept_display = ssc.concept_display, reply->notes[index].concepts[
     concept_idx].concept_type_flag = ssc.concept_type_flag,
     reply->notes[index].concepts[concept_idx].diagnosis_group_id = ssc.diagnosis_group_id
    FOOT REPORT
     stat = alterlist(reply->notes[index].concepts,concept_idx)
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
