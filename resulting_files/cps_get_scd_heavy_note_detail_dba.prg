CREATE PROGRAM cps_get_scd_heavy_note_detail:dba
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
     2 author_name = vc
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
       3 pattern_type_mean = vc
       3 pattern_display = vc
       3 pattern_definition = vc
     2 paragraphs[*]
       3 scd_paragraph_id = f8
       3 scr_paragraph_type_id = f8
       3 scr_paragraph_display = vc
       3 sequence_number = i4
       3 paragraph_class_cd = f8
       3 paragraph_class_mean = vc
       3 scr_cki_source = vc
       3 scr_cki_id = vc
       3 scr_text_format_rule_cd = f8
       3 scr_canonical_pattern_id = f8
       3 scr_description = vc
       3 scd_term_data_id = f8
       3 truth_state_cd = f8
       3 truth_state_mean = vc
       3 para_term_data[*]
         4 scd_term_data_type_cd = f8
         4 scd_term_data_type_mean = vc
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
       3 scr_text_format_rule_mean = vc
       3 action_type = c3
     2 sentences[*]
       3 scd_sentence_id = f8
       3 scd_paragraph_id = f8
       3 scr_term_hier_id = f8
       3 canonical_sentence_pattern_id = f8
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
       3 scd_paragraph_type_idx = i4
       3 action_type = c3
     2 terms[*]
       3 scd_term_id = f8
       3 scr_term_id = f8
       3 scd_sentence_id = f8
       3 scr_term_hier_id = f8
       3 sequence_number = i4
       3 truth_state_cd = f8
       3 truth_state_mean = vc
       3 parent_scd_term_id = f8
       3 scd_phrase_type_id = f8
       3 parent_term_hier_id = f8
       3 recommended_cd = f8
       3 recommended_mean = vc
       3 dependency_group = i4
       3 dependency_cd = f8
       3 dependency_mean = vc
       3 default_cd = f8
       3 default_mean = vc
       3 source_term_hier_id = f8
       3 cki_source = vc
       3 cki_identifier = vc
       3 concept_identifier = vc
       3 concept_source_cd = f8
       3 concept_source_mean = vc
       3 concept_cki = vc
       3 eligibility_check_cd = f8
       3 eligibility_check_mean = vc
       3 visible_cd = f8
       3 visible_mean = vc
       3 oldest_age = f8
       3 repeat_cd = f8
       3 repeat_mean = vc
       3 restrict_to_sex = c12
       3 state_logic_cd = f8
       3 state_logic_mean = vc
       3 store_cd = f8
       3 store_mean = vc
       3 term_type_cd = f8
       3 term_type_mean = vc
       3 youngest_age = f8
       3 definition = vc
       3 display = vc
       3 external_reference_info = vc
       3 text_format_rule_cd = f8
       3 text_format_rule_mean = vc
       3 text_negation_rule_cd = f8
       3 text_negation_rule_mean = vc
       3 text_representation = vc
       3 term_data[*]
         4 scd_term_data_type_cd = f8
         4 scd_term_data_type_mean = vc
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
       3 term_def_data[*]
         4 scr_term_def_type_cd = f8
         4 scr_term_def_type_mean = vc
         4 scr_term_def_key = vc
         4 fkey_id = f8
         4 fkey_entity_name = vc
         4 def_text = vc
       3 successor_term_id = f8
       3 active_ind = i2
       3 modify_prsnl_id = f8
       3 modify_prsnl_name = vc
       3 beg_effective_dt_tm = dq8
       3 beg_effective_tz = i4
       3 end_effective_dt_tm = dq8
       3 scd_term_data_id = f8
       3 scr_term_def_id = f8
       3 event_id = f8
       3 parent_scd_term_idx = i4
       3 scd_sentence_idx = i4
       3 successor_term_idx = i4
     2 using_idx_values = i2
     2 note_term_data[*]
       3 scd_term_data_type_cd = f8
       3 scd_term_data_type_mean = vc
       3 scd_term_data_key = vc
       3 fkey_id = f8
       3 fkey_entity_name = vc
       3 value_number = f8
       3 value_dt_tm = dq8
       3 value_tz = i4
       3 value_dt_tm_os = f8
       3 value_text = vc
       3 units_cd = f8
       3 units_mean = vc
       3 value_binary = vgc
       3 format_cd = f8
       3 format_mean = vc
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
 SET modify = predeclare
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
 DECLARE query_id = f8 WITH public, noconstant(0.0)
 DECLARE notes_to_get = i4 WITH protect, noconstant(size(request->notes,5))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH public, noconstant(0)
 DECLARE expand_size = i4 WITH protect, constant(100)
 DECLARE precompleted_flag = i2 WITH public, noconstant(0)
 DECLARE checklockpattern(index=i4) = null
 DECLARE setlock(index=i4) = null
 DECLARE getstorydata(index=i4) = null
 DECLARE fillparagraphs(index=i4) = null
 DECLARE fillscr_pattern_ids(index=i4) = null
 DECLARE fillsentences(index=i4) = null
 DECLARE filltermsandtermdata(index=i4) = null
 DECLARE fillconceptstruct(index=i4) = null
 SET reply->status_data.status = "F"
 IF (notes_to_get=0)
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No Notes In Request",cps_insuf_data_msg,
   note_index,
   0,0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->notes,value(notes_to_get))
 FOR (note_index = 1 TO notes_to_get)
   IF ((((request->notes[note_index].update_lock_flag < scd_db_update_lock_lock)) OR ((request->
   notes[note_index].update_lock_flag > scd_db_update_lock_read_only))) )
    SET failed = 1
    CALL cps_add_error(cps_insuf_data,cps_script_fail,"No Locking Parameter Defined",
     cps_insuf_data_msg,note_index,
     0,0)
    GO TO exit_script
   ENDIF
   IF ((request->notes[note_index].id=0.0)
    AND (request->notes[note_index].event_id=0.0))
    CALL cps_add_error(cps_select,cps_script_fail,"Invalid Note ID Found",cps_select_msg,note_index,
     0,0)
    GO TO exit_script
   ENDIF
   IF ((request->notes[note_index].id=0.0))
    SELECT INTO "NL:"
     FROM scd_story s
     WHERE (s.event_id=request->notes[note_index].event_id)
     DETAIL
      query_id = s.scd_story_id
    ;end select
   ELSE
    SET query_id = request->notes[note_index].id
   ENDIF
   IF ((((request->notes[note_index].update_lock_flag=scd_db_update_lock_lock)) OR ((request->notes[
   note_index].update_lock_flag=scd_db_update_lock_override))) )
    SET locked_user_id = 0.0
    CALL checklockpattern(note_index)
    IF (failed=1)
     CALL cps_add_error(cps_lock,cps_script_fail,"Couldn't Lock the Note(s)",cps_lock_msg,note_index,
      query_id,0)
     GO TO exit_script
    ENDIF
    IF (((locked_user_id=0.0) OR ((((locked_user_id=reqinfo->updt_id)) OR ((request->notes[note_index
    ].update_lock_flag=scd_db_update_lock_override))) )) )
     CALL setlock(note_index)
     IF (failed=1)
      CALL cps_add_error(cps_update,cps_script_fail,"Couldn't Update Lock Info ",cps_update_msg,
       note_index,
       0,0)
      GO TO exit_script
     ENDIF
    ELSE
     SET failed = 1
     CALL cps_add_error(cps_lock,cps_script_fail,"Note already locked",cps_lock_msg,note_index,
      locked_user_id,0)
     GO TO exit_script
    ENDIF
   ENDIF
   CALL getstorydata(note_index)
   CALL fillparagraphs(note_index)
   CALL fillscr_pattern_ids(note_index)
   CALL fillsentences(note_index)
   CALL filltermsandtermdata(note_index)
   CALL fillconceptstruct(note_index)
 ENDFOR
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SUBROUTINE checklockpattern(index)
  SELECT INTO "NL:"
   FROM scd_story s
   WHERE s.scd_story_id=query_id
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
   WHERE s.scd_story_id=query_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE getstorydata(index)
   DECLARE note_type_mean = vc WITH private, constant(uar_get_code_meaning(reply->notes[index].
     story_type_cd))
   DECLARE note_td_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM scd_story note,
     prsnl pl,
     scd_term_data data
    PLAN (note
     WHERE note.scd_story_id=query_id)
     JOIN (pl
     WHERE pl.person_id=note.author_id)
     JOIN (data
     WHERE data.scd_term_data_id=note.scd_term_data_id)
    HEAD note.scd_story_id
     reply->notes[index].scd_story_id = note.scd_story_id, reply->notes[index].person_id = note
     .person_id, reply->notes[index].encounter_id = note.encounter_id,
     reply->notes[index].story_type_cd = note.story_type_cd, reply->notes[index].title = note.title,
     reply->notes[index].story_completion_status_cd = note.story_completion_status_cd,
     reply->notes[index].author_id = note.author_id, reply->notes[index].author_name = pl
     .name_full_formatted, reply->notes[index].event_id = note.event_id,
     reply->notes[index].update_lock_user_id = note.update_lock_user_id, reply->notes[index].
     update_lock_dt_tm = cnvtdatetime(note.update_lock_dt_tm), reply->notes[index].updt_dt_tm =
     cnvtdatetime(note.updt_dt_tm),
     reply->notes[index].updt_cnt = note.updt_cnt, reply->notes[index].active_status_cd = note
     .active_status_cd, reply->notes[index].active_ind = note.active_ind,
     reply->notes[index].entry_mode_cd = note.entry_mode_cd
     IF (note.entry_mode_cd)
      reply->notes[index].entry_mode_mean = uar_get_code_meaning(note.entry_mode_cd)
     ENDIF
    DETAIL
     IF (data.scd_term_data_id != 0)
      note_td_idx = (note_td_idx+ 1)
      IF (mod(note_td_idx,10)=1)
       stat = alterlist(reply->notes[index].note_term_data,(note_td_idx+ 9))
      ENDIF
      reply->notes[index].note_term_data[note_td_idx].scd_term_data_type_cd = data
      .scd_term_data_type_cd, reply->notes[index].note_term_data[note_td_idx].scd_term_data_key =
      data.scd_term_data_key, reply->notes[index].note_term_data[note_td_idx].fkey_id = data.fkey_id,
      reply->notes[index].note_term_data[note_td_idx].fkey_entity_name = data.fkey_entity_name, reply
      ->notes[index].note_term_data[note_td_idx].value_number = data.value_number, reply->notes[index
      ].note_term_data[note_td_idx].value_dt_tm = data.value_dt_tm,
      reply->notes[index].note_term_data[note_td_idx].value_tz = data.value_tz, reply->notes[index].
      note_term_data[note_td_idx].value_dt_tm_os = data.value_dt_tm_os, reply->notes[index].
      note_term_data[note_td_idx].value_text = data.value_text,
      reply->notes[index].note_term_data[note_td_idx].units_cd = data.units_cd
     ENDIF
    FOOT REPORT
     IF (note_td_idx > 0)
      stat = alterlist(reply->notes[index].note_term_data,note_td_idx)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_select,cps_script_fail,"No Notes for specified detail",cps_select_msg,
     note_index,
     0,0)
    GO TO exit_script
   ENDIF
   IF (((note_type_mean="PRE") OR (((note_type_mean="PRE PART") OR (((note_type_mean="PREPARA") OR (
   ((note_type_mean="PRESENT") OR (note_type_mean="PRETERM")) )) )) )) )
    SET reply->notes[index].person_id = 0.0
    SET reply->notes[index].encounter_id = 0.0
    SET reply->notes[index].event_id = 0.0
    SET precompleted_flag = 1
   ELSE
    SET precompleted_flag = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE fillparagraphs(index)
   SELECT INTO "NL:"
    FROM scd_paragraph par,
     scr_paragraph_type partype,
     scd_term_data ptd
    PLAN (par
     WHERE par.scd_story_id=query_id)
     JOIN (partype
     WHERE partype.scr_paragraph_type_id=par.scr_paragraph_type_id)
     JOIN (ptd
     WHERE ptd.scd_term_data_id=par.scd_term_data_id)
    ORDER BY par.scd_paragraph_id
    HEAD REPORT
     par_idx = 0
    HEAD par.scd_paragraph_id
     par_idx = (par_idx+ 1)
     IF (mod(par_idx,10)=1)
      stat = alterlist(reply->notes[index].paragraphs,(par_idx+ 9))
     ENDIF
     reply->notes[index].paragraphs[par_idx].scd_paragraph_id = par.scd_paragraph_id, reply->notes[
     index].paragraphs[par_idx].scr_paragraph_type_id = par.scr_paragraph_type_id, reply->notes[index
     ].paragraphs[par_idx].sequence_number = par.sequence_number,
     reply->notes[index].paragraphs[par_idx].paragraph_class_cd = par.paragraph_class_cd, reply->
     notes[index].paragraphs[par_idx].scr_paragraph_display = partype.display, reply->notes[index].
     paragraphs[par_idx].scr_cki_source = partype.cki_source,
     reply->notes[index].paragraphs[par_idx].scr_cki_id = partype.cki_identifier, reply->notes[index]
     .paragraphs[par_idx].scr_text_format_rule_cd = partype.text_format_rule_cd, reply->notes[index].
     paragraphs[par_idx].scr_canonical_pattern_id = partype.canonical_pattern_id,
     reply->notes[index].paragraphs[par_idx].scr_description = partype.description, reply->notes[
     index].paragraphs[par_idx].truth_state_cd = par.truth_state_cd, reply->notes[index].paragraphs[
     par_idx].scd_term_data_id = par.scd_term_data_id
    DETAIL
     par_td_idx = 0
     IF (ptd.scd_term_data_id > 0.0)
      par_td_idx = (par_td_idx+ 1)
      IF (mod(par_td_idx,10)=1)
       stat = alterlist(reply->notes[index].paragraphs[par_idx].para_term_data,(par_idx+ 9))
      ENDIF
      reply->notes[index].paragraphs[par_idx].para_term_data[par_td_idx].scd_term_data_type_cd = ptd
      .scd_term_data_type_cd, reply->notes[index].paragraphs[par_idx].para_term_data[par_td_idx].
      scd_term_data_key = ptd.scd_term_data_key, reply->notes[index].paragraphs[par_idx].
      para_term_data[par_td_idx].fkey_id = ptd.fkey_id,
      reply->notes[index].paragraphs[par_idx].para_term_data[par_td_idx].fkey_entity_name = ptd
      .fkey_entity_name, reply->notes[index].paragraphs[par_idx].para_term_data[par_td_idx].
      value_number = ptd.value_number, reply->notes[index].paragraphs[par_idx].para_term_data[
      par_td_idx].value_dt_tm = ptd.value_dt_tm,
      reply->notes[index].paragraphs[par_idx].para_term_data[par_td_idx].value_tz = ptd.value_tz,
      reply->notes[index].paragraphs[par_idx].para_term_data[par_td_idx].value_dt_tm_os = ptd
      .value_dt_tm_os, reply->notes[index].paragraphs[par_idx].para_term_data[par_td_idx].value_text
       = ptd.value_text,
      reply->notes[index].paragraphs[par_idx].para_term_data[par_td_idx].units_cd = ptd.units_cd
     ENDIF
    FOOT  par.scd_paragraph_id
     IF (par_td_idx > 0)
      stat = alterlist(reply->notes[index].paragraphs[par_idx].para_term_data,par_td_idx)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->notes[index].paragraphs,par_idx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE fillscr_pattern_ids(index)
   SELECT INTO "NL:"
    FROM scd_story_pattern scdpat,
     scr_pattern scrpat
    WHERE scdpat.scd_story_id=query_id
     AND ((scdpat.scr_pattern_id=scrpat.scr_pattern_id) OR (scrpat.scr_pattern_id=0.0))
    ORDER BY scdpat.scr_pattern_id, scrpat.scr_pattern_id DESC
    HEAD REPORT
     pat_idx = 0
    HEAD scdpat.scr_pattern_id
     pat_idx = (pat_idx+ 1)
     IF (mod(pat_idx,10)=1)
      stat = alterlist(reply->notes[index].scr_pattern_ids,(pat_idx+ 9))
     ENDIF
     reply->notes[index].scr_pattern_ids[pat_idx].scr_pattern_id = scdpat.scr_pattern_id, reply->
     notes[index].scr_pattern_ids[pat_idx].scr_paragraph_type_id = scdpat.scr_paragraph_type_id,
     reply->notes[index].scr_pattern_ids[pat_idx].pattern_type_cd = scdpat.pattern_type_cd,
     reply->notes[index].scr_pattern_ids[pat_idx].pattern_display = scrpat.display, reply->notes[
     index].scr_pattern_ids[pat_idx].pattern_definition = scrpat.definition
    FOOT REPORT
     stat = alterlist(reply->notes[index].scr_pattern_ids,pat_idx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE fillsentences(index)
   SELECT INTO "NL:"
    FROM scd_sentence sent
    WHERE sent.scd_story_id=query_id
    HEAD REPORT
     sent_idx = 0
    DETAIL
     sent_idx = (sent_idx+ 1)
     IF (mod(sent_idx,10)=1)
      stat = alterlist(reply->notes[index].sentences,(sent_idx+ 9))
     ENDIF
     reply->notes[index].sentences[sent_idx].scd_sentence_id = sent.scd_sentence_id, reply->notes[
     index].sentences[sent_idx].scd_paragraph_id = sent.scd_paragraph_id, reply->notes[index].
     sentences[sent_idx].scr_term_hier_id = sent.scr_term_hier_id,
     reply->notes[index].sentences[sent_idx].sequence_number = sent.sequence_number, reply->notes[
     index].sentences[sent_idx].canonical_sentence_pattern_id = sent.canonical_sentence_pattern_id,
     reply->notes[index].sentences[sent_idx].can_sent_pat_cki_source = sent.can_sent_pat_cki_source,
     reply->notes[index].sentences[sent_idx].can_sent_pat_cki_identifier = sent
     .can_sent_pat_cki_identifier, reply->notes[index].sentences[sent_idx].sentence_class_cd = sent
     .sentence_class_cd, reply->notes[index].sentences[sent_idx].sentence_topic_cd = sent
     .sentence_topic_cd,
     reply->notes[index].sentences[sent_idx].text_format_rule_cd = sent.text_format_rule_cd, reply->
     notes[index].sentences[sent_idx].author_persnl_id = sent.author_persnl_id, reply->notes[index].
     sentences[sent_idx].updt_dt_tm = sent.updt_dt_tm,
     reply->notes[index].sentences[sent_idx].updt_cnt = sent.updt_cnt, reply->notes[index].sentences[
     sent_idx].active_ind = sent.active_ind, reply->notes[index].sentences[sent_idx].active_status_cd
      = sent.active_status_cd
    FOOT REPORT
     stat = alterlist(reply->notes[index].sentences,sent_idx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE filltermsandtermdata(index)
   DECLARE qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE term_data_idx = i4 WITH protect, noconstant(0)
   DECLARE term_def_idx = i4 WITH protect, noconstant(0)
   DECLARE term_idx = i4 WITH protect, noconstant(0)
   FREE RECORD expand_record
   RECORD expand_record(
     1 qual[*]
       2 scd_term_id = f8
   )
   SELECT INTO "NL:"
    FROM scd_term term,
     scd_term_data data
    PLAN (term
     WHERE term.scd_story_id=query_id)
     JOIN (data
     WHERE data.scd_term_data_id=term.scd_term_data_id)
    ORDER BY term.scd_term_id
    HEAD term.scd_term_id
     IF (term_data_idx != 0)
      stat = alterlist(reply->notes[index].terms[term_idx].term_data,term_data_idx)
     ENDIF
     term_data_idx = 0, term_idx = (term_idx+ 1)
     IF (mod(term_idx,100)=1)
      stat = alterlist(reply->notes[index].terms,(term_idx+ 99))
     ENDIF
     reply->notes[index].terms[term_idx].scd_term_id = term.scd_term_id, reply->notes[index].terms[
     term_idx].scr_term_id = term.scr_term_id, reply->notes[index].terms[term_idx].scd_sentence_id =
     term.scd_sentence_id,
     reply->notes[index].terms[term_idx].scr_term_hier_id = term.scr_term_hier_id, reply->notes[index
     ].terms[term_idx].sequence_number = term.sequence_number, reply->notes[index].terms[term_idx].
     concept_source_cd = term.concept_source_cd,
     reply->notes[index].terms[term_idx].concept_identifier = term.concept_identifier, reply->notes[
     index].terms[term_idx].concept_cki = term.concept_cki, reply->notes[index].terms[term_idx].
     truth_state_cd = term.truth_state_cd,
     reply->notes[index].terms[term_idx].parent_scd_term_id = term.parent_scd_term_id, reply->notes[
     index].terms[term_idx].scd_phrase_type_id = term.scd_phrase_type_id, reply->notes[index].terms[
     term_idx].successor_term_id = term.successor_term_id,
     reply->notes[index].terms[term_idx].active_ind = term.active_ind, reply->notes[index].terms[
     term_idx].modify_prsnl_id = term.modify_prsnl_id, reply->notes[index].terms[term_idx].
     beg_effective_dt_tm = term.beg_effective_dt_tm,
     reply->notes[index].terms[term_idx].beg_effective_tz = term.beg_effective_tz, reply->notes[index
     ].terms[term_idx].end_effective_dt_tm = term.end_effective_dt_tm, reply->notes[index].terms[
     term_idx].scd_term_data_id = term.scd_term_data_id
     IF (precompleted_flag=1)
      reply->notes[index].terms[term_idx].event_id = 0.0
     ELSE
      reply->notes[index].terms[term_idx].event_id = term.event_id
     ENDIF
     qual_cnt = (qual_cnt+ 1)
     IF (mod(qual_cnt,10)=1)
      stat = alterlist(expand_record->qual,(qual_cnt+ 9))
     ENDIF
     expand_record->qual[qual_cnt].scd_term_id = term.scd_term_id
    DETAIL
     IF (data.scd_term_data_id != 0)
      term_data_idx = (term_data_idx+ 1)
      IF (mod(term_data_idx,10)=1)
       stat = alterlist(reply->notes[index].terms[term_idx].term_data,(term_data_idx+ 9))
      ENDIF
      reply->notes[index].terms[term_idx].term_data[term_data_idx].scd_term_data_type_cd = data
      .scd_term_data_type_cd, reply->notes[index].terms[term_idx].term_data[term_data_idx].
      scd_term_data_key = data.scd_term_data_key, reply->notes[index].terms[term_idx].term_data[
      term_data_idx].fkey_id = data.fkey_id,
      reply->notes[index].terms[term_idx].term_data[term_data_idx].fkey_entity_name = data
      .fkey_entity_name, reply->notes[index].terms[term_idx].term_data[term_data_idx].value_number =
      data.value_number, reply->notes[index].terms[term_idx].term_data[term_data_idx].value_dt_tm =
      data.value_dt_tm,
      reply->notes[index].terms[term_idx].term_data[term_data_idx].value_tz = data.value_tz, reply->
      notes[index].terms[term_idx].term_data[term_data_idx].value_dt_tm_os = data.value_dt_tm_os,
      reply->notes[index].terms[term_idx].term_data[term_data_idx].value_text = data.value_text,
      reply->notes[index].terms[term_idx].term_data[term_data_idx].units_cd = data.units_cd
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->notes[index].terms,term_idx)
     IF (qual_cnt > 0)
      stat = alterlist(expand_record->qual,qual_cnt)
     ENDIF
     IF (term_data_idx != 0)
      stat = alterlist(reply->notes[index].terms[term_idx].term_data,term_data_idx)
     ENDIF
    WITH nocounter
   ;end select
   IF (qual_cnt=0)
    FREE RECORD expand_record
    RETURN
   ENDIF
   DECLARE lang_cd = f8 WITH constant(uar_get_code_by("MEANING",36,"ENG"))
   DECLARE expand_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(100)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE loop_cnt = i4 WITH protect, constant(ceil((qual_cnt/ (1.0 * expand_size))))
   DECLARE total_items = i4 WITH protect, constant((loop_cnt * expand_size))
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (idx = (qual_cnt+ 1) TO total_items)
     SET expand_record->qual[idx].scd_term_id = 0.0
   ENDFOR
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     scd_term scdterm,
     scr_term term,
     scr_term_text text,
     scr_term_definition def
    PLAN (d
     WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
     JOIN (scdterm
     WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),scdterm.scd_term_id,
      expand_record->qual[expand_idx].scd_term_id))
     JOIN (term
     WHERE term.scr_term_id=scdterm.scr_term_id)
     JOIN (text
     WHERE text.scr_term_id=term.scr_term_id
      AND text.language_cd=lang_cd)
     JOIN (def
     WHERE def.scr_term_def_id=term.scr_term_def_id)
    ORDER BY scdterm.scd_term_id
    HEAD REPORT
     idx = 0
    HEAD scdterm.scd_term_id
     IF (scdterm.scd_term_id != 0.0)
      IF (term_def_idx != 0)
       stat = alterlist(reply->notes[index].terms[idx].term_def_data,term_def_idx)
      ENDIF
      term_def_idx = 0, idx = (idx+ 1)
      IF (idx > qual_cnt)
       failed = 1
      ENDIF
      reply->notes[index].terms[idx].concept_identifier = term.concept_identifier, reply->notes[index
      ].terms[idx].concept_source_cd = term.concept_source_cd, reply->notes[index].terms[idx].
      eligibility_check_cd = term.eligibility_check_cd,
      reply->notes[index].terms[idx].visible_cd = term.visible_cd, reply->notes[index].terms[idx].
      oldest_age = term.oldest_age, reply->notes[index].terms[idx].repeat_cd = term.repeat_cd,
      reply->notes[index].terms[idx].restrict_to_sex = term.restrict_to_sex, reply->notes[index].
      terms[idx].state_logic_cd = term.state_logic_cd, reply->notes[index].terms[idx].store_cd = term
      .store_cd,
      reply->notes[index].terms[idx].term_type_cd = term.term_type_cd, reply->notes[index].terms[idx]
      .youngest_age = term.youngest_age, reply->notes[index].terms[idx].scr_term_def_id = term
      .scr_term_def_id,
      reply->notes[index].terms[idx].definition = text.definition, reply->notes[index].terms[idx].
      display = text.display, reply->notes[index].terms[idx].external_reference_info = text
      .external_reference_info,
      reply->notes[index].terms[idx].text_format_rule_cd = text.text_format_rule_cd, reply->notes[
      index].terms[idx].text_negation_rule_cd = text.text_negation_rule_cd, reply->notes[index].
      terms[idx].text_representation = text.text_representation
     ENDIF
    DETAIL
     IF (def.scr_term_def_id != 0)
      term_def_idx = (term_def_idx+ 1)
      IF (mod(term_def_idx,10)=1)
       stat = alterlist(reply->notes[index].terms[idx].term_def_data,(term_def_idx+ 9))
      ENDIF
      reply->notes[index].terms[idx].term_def_data[term_def_idx].scr_term_def_type_cd = def
      .scr_term_def_type_cd, reply->notes[index].terms[idx].term_def_data[term_def_idx].
      scr_term_def_key = def.scr_term_def_key, reply->notes[index].terms[idx].term_def_data[
      term_def_idx].fkey_id = def.fkey_id,
      reply->notes[index].terms[idx].term_def_data[term_def_idx].fkey_entity_name = def
      .fkey_entity_name, reply->notes[index].terms[idx].term_def_data[term_def_idx].def_text = def
      .def_text
     ENDIF
    FOOT REPORT
     IF (term_def_idx != 0)
      stat = alterlist(reply->notes[index].terms[idx].term_def_data,term_def_idx)
     ENDIF
    WITH nocounter
   ;end select
   SET expand_idx = 0
   SET expand_start = 1
   SET idx = 0
   DECLARE locateval_idx = i4 WITH protect, noconstant(0)
   FOR (idx = 1 TO qual_cnt)
     SET expand_record->qual[idx].scd_term_id = reply->notes[index].terms[idx].scr_term_hier_id
   ENDFOR
   FOR (idx = (qual_cnt+ 1) TO total_items)
     SET expand_record->qual[idx].scd_term_id = 0.0
   ENDFOR
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     scr_term_hier hier
    PLAN (d
     WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
     JOIN (hier
     WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),hier.scr_term_hier_id,
      expand_record->qual[expand_idx].scd_term_id))
    DETAIL
     IF (hier.scr_term_hier_id != 0.0)
      locateval_idx = locateval(expand_idx,1,qual_cnt,hier.scr_term_hier_id,reply->notes[index].
       terms[expand_idx].scr_term_hier_id)
      WHILE (locateval_idx != 0)
       IF (locateval_idx >= 0)
        reply->notes[index].terms[locateval_idx].parent_term_hier_id = hier.parent_term_hier_id,
        reply->notes[index].terms[locateval_idx].recommended_cd = hier.recommended_cd, reply->notes[
        index].terms[locateval_idx].dependency_group = hier.dependency_group,
        reply->notes[index].terms[locateval_idx].dependency_cd = hier.dependency_cd, reply->notes[
        index].terms[locateval_idx].default_cd = hier.default_cd, reply->notes[index].terms[
        locateval_idx].source_term_hier_id = hier.source_term_hier_id,
        reply->notes[index].terms[locateval_idx].cki_source = hier.cki_source, reply->notes[index].
        terms[locateval_idx].cki_identifier = hier.cki_identifier
       ENDIF
       ,locateval_idx = locateval(expand_idx,(locateval_idx+ 1),qual_cnt,hier.scr_term_hier_id,reply
        ->notes[index].terms[expand_idx].scr_term_hier_id)
      ENDWHILE
     ENDIF
    WITH nocounter
   ;end select
   FREE RECORD expand_record
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
