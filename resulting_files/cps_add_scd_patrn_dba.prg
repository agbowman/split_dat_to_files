CREATE PROGRAM cps_add_scd_patrn:dba
 RECORD reply(
   1 patterns[*]
     2 scr_pattern_id = f8
     2 sentences[*]
       3 scr_sentence_id = f8
     2 term_hier[*]
       3 scr_term_hier_id = f8
       3 scr_term_id = f8
       3 term_actions[*]
         4 scr_action_id = f8
         4 expr_id = f8
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
 FREE SET temp_term_info
 RECORD temp_term_info(
   1 ids[*]
     2 scr_term_hier_id = f8
     2 sentence_id = f8
     2 scr_term_id = f8
     2 parent_id = f8
 )
 DECLARE scdgetuniqueid(null) = null
 DECLARE addterm(null) = null
 DECLARE addtermaction(null) = null
 DECLARE addparagraphaction(null) = null
 DECLARE addexpression(null) = null
 DECLARE updateexpression(null) = null
 DECLARE addtermtextdefinition(null) = null
 DECLARE addexpressioncomponents(null) = null
 CALL echo("Message added for diagnostic purpose")
 CALL echorecord(request)
 CALL echo("Message added for diagnostic purpose")
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
 DECLARE unique_id = f8 WITH public, noconstant(0.0)
 DECLARE pattern_type_mean = c20
 DECLARE g_scr_term_id = f8 WITH public, noconstant(0.0)
 SET failed = 0
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET number_patterns = size(request->patterns,5)
 IF (number_patterns=0)
  SET failed = 1
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No patterns specified",cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->patterns,number_patterns)
 FOR (x = 1 TO number_patterns)
   SET unique_id = request->patterns[x].scr_pattern_id
   IF (unique_id=0.0)
    CALL scdgetuniqueid(null)
    IF (failed=1)
     GO TO exit_script
    ENDIF
   ENDIF
   SET reply->patterns[x].scr_pattern_id = unique_id
   IF ((request->patterns[x].action_type != "REP"))
    INSERT  FROM scr_pattern p
     SET p.scr_pattern_id = unique_id, p.cki_source = request->patterns[x].cki_source, p
      .cki_identifier = request->patterns[x].cki_identifier,
      p.pattern_type_cd = request->patterns[x].pattern_type_cd, p.display = request->patterns[x].
      display, p.display_key = cnvtupper(cnvtalphanum(trim(request->patterns[x].display))),
      p.definition = request->patterns[x].definition, p.updt_cnt = request->patterns[x].updt_cnt, p
      .active_ind =
      IF ((reqdata->active_status_cd != request->patterns[x].active_status_cd)) 0
      ELSE 1
      ENDIF
      ,
      p.active_status_cd = request->patterns[x].active_status_cd, p.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->updt_id,
      p.required_field_enforcement_cd = request->patterns[x].required_field_enforcement_cd, p
      .updt_cnt = request->patterns[x].updt_cnt, p.updt_id = reqinfo->updt_id,
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_task = reqinfo->updt_task, p.updt_applctx
       = reqinfo->updt_applctx,
      p.entry_mode_cd = request->entry_mode_cd
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING PATTERN",cps_insert_msg,x,
      0,0)
     GO TO exit_script
    ENDIF
   ELSE
    UPDATE  FROM scr_pattern p
     SET p.cki_source = request->patterns[x].cki_source, p.cki_identifier = request->patterns[x].
      cki_identifier, p.pattern_type_cd = request->patterns[x].pattern_type_cd,
      p.display = request->patterns[x].display, p.display_key = cnvtupper(cnvtalphanum(trim(request->
         patterns[x].display))), p.definition = request->patterns[x].definition,
      p.updt_cnt = request->patterns[x].updt_cnt, p.active_ind =
      IF ((reqdata->active_status_cd != request->patterns[x].active_status_cd)) 0
      ELSE 1
      ENDIF
      , p.active_status_cd = request->patterns[x].active_status_cd,
      p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
      updt_id, p.required_field_enforcement_cd = request->patterns[x].required_field_enforcement_cd,
      p.updt_cnt = request->patterns[x].updt_cnt, p.updt_id = reqinfo->updt_id, p.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.entry_mode_cd =
      request->entry_mode_cd
     WHERE (p.scr_pattern_id=request->patterns[x].scr_pattern_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"UPDATING PATTERN",cps_insert_msg,x,
      0,0)
     GO TO exit_script
    ENDIF
   ENDIF
   SET number_pars = size(request->patterns[x].paragraphs,5)
   IF (number_pars != 0)
    FOR (y = 1 TO value(number_pars))
      CALL scdgetuniqueid(null)
      IF (failed=1)
       GO TO exit_script
      ENDIF
      SET g_scr_paragraph_id = unique_id
      INSERT  FROM scr_paragraph pr
       SET pr.scr_paragraph_id = g_scr_paragraph_id, pr.scr_pattern_id = reply->patterns[x].
        scr_pattern_id, pr.scr_paragraph_type_id = request->patterns[x].paragraphs[y].
        scr_paragraph_type_id,
        pr.sequence_number = request->patterns[x].paragraphs[y].sequence_number
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = 1
       CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING PARAGRAPH",cps_insert_msg,x,
        y,0)
       GO TO exit_script
      ENDIF
      CALL addparagraphaction(null)
    ENDFOR
   ENDIF
   SET number_sentences = size(request->patterns[x].sentences,5)
   SET stat = alterlist(reply->patterns[x].sentences,value(number_sentences))
   FOR (y = 1 TO value(number_sentences))
     CALL scdgetuniqueid(null)
     IF (failed=1)
      GO TO exit_script
     ENDIF
     SET reply->patterns[x].sentences[y].scr_sentence_id = unique_id
   ENDFOR
   IF (number_sentences != 0)
    INSERT  FROM scr_sentence st,
      (dummyt d  WITH seq = value(number_sentences))
     SET st.scr_sentence_id = reply->patterns[x].sentences[d.seq].scr_sentence_id, st.scr_pattern_id
       = reply->patterns[x].scr_pattern_id, st.scr_paragraph_type_id = request->patterns[x].
      sentences[d.seq].scr_paragraph_type_id,
      st.sequence_number = request->patterns[x].sentences[d.seq].sequence_number, st
      .canonical_sentence_pattern_id =
      IF ((request->patterns[x].pattern_type_mean="SENT")
       AND (request->patterns[x].sentences[d.seq].canonical_sentence_pattern_id=0.0)) reply->
       patterns[x].scr_pattern_id
      ELSE request->patterns[x].sentences[d.seq].canonical_sentence_pattern_id
      ENDIF
      , st.sentence_topic_cd = request->patterns[x].sentences[d.seq].sentence_topic_cd,
      st.recommended_cd = request->patterns[x].sentences[d.seq].recommended_cd, st.default_cd =
      request->patterns[x].sentences[d.seq].default_cd, st.text_format_rule_cd = request->patterns[x]
      .sentences[d.seq].text_format_rule_cd,
      st.updt_id = reqinfo->updt_id, st.updt_dt_tm = cnvtdatetime(curdate,curtime3), st.updt_task =
      reqinfo->updt_task,
      st.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (st)
     WITH nocounter
    ;end insert
    IF (curqual != number_sentences)
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING SENTENCE",cps_insert_msg,x,
      0,0)
     GO TO exit_script
    ENDIF
   ENDIF
   SET number_terms = size(request->patterns[x].term_hier,5)
   SET stat = alterlist(reply->patterns[x].term_hier,number_terms)
   SET stat = alterlist(temp_term_info->ids,number_terms)
   FOR (z = 1 TO number_terms)
     SET g_scr_term_id = request->patterns[x].term_hier[z].scr_term_id
     SET temp_term_info->ids[z].scr_term_id = request->patterns[x].term_hier[z].scr_term_id
     SET temp_term_info->ids[z].scr_term_hier_id = request->patterns[x].term_hier[z].scr_term_hier_id
     IF (g_scr_term_id != 0.0)
      IF ((temp_term_info->ids[z].scr_term_hier_id=g_scr_term_id))
       CALL addterm(null)
      ENDIF
     ELSE
      CALL addterm(null)
      SET temp_term_info->ids[z].scr_term_hier_id = g_scr_term_id
     ENDIF
     IF (failed=1)
      GO TO exit_script
     ENDIF
     IF ((temp_term_info->ids[z].scr_term_hier_id=0.0))
      CALL scdgetuniqueid(null)
      IF (failed=1)
       GO TO exit_script
      ENDIF
      SET temp_term_info->ids[z].scr_term_hier_id = unique_id
     ENDIF
     SET reply->patterns[x].term_hier[z].scr_term_hier_id = temp_term_info->ids[z].scr_term_hier_id
     SET reply->patterns[x].term_hier[z].scr_term_id = g_scr_term_id
     SET idx = request->patterns[x].term_hier[z].parent_term_hier_idx
     IF (idx > number_terms)
      SET failed = 1
      CALL cps_add_error(cps_inval_data,cps_script_fail,"Request had an invalid parent index.",
       cps_inval_data_msg,x,
       z,idx)
      GO TO exit_script
     ENDIF
     IF (idx != 0)
      SET temp_term_info->ids[z].parent_id = reply->patterns[x].term_hier[idx].scr_term_hier_id
     ELSE
      SET temp_term_info->ids[z].parent_id = 0.0
     ENDIF
     SET idx = request->patterns[x].term_hier[z].scr_sentence_idx
     IF (idx > number_sentences)
      SET failed = 1
      CALL cps_add_error(cps_inval_data,cps_script_fail,"Invalid sentence index.",cps_inval_data_msg,
       x,
       z,idx)
      GO TO exit_script
     ENDIF
     IF (idx=0)
      SET failed = 1
      CALL cps_add_error(cps_insuf_data,cps_script_fail,"No sentence for term",cps_insuf_data_msg,x,
       z,0)
      GO TO exit_script
     ENDIF
     SET temp_term_info->ids[z].sentence_id = reply->patterns[x].sentences[idx].scr_sentence_id
   ENDFOR
   IF (number_terms != 0)
    INSERT  FROM scr_term_hier th,
      (dummyt d  WITH seq = value(number_terms))
     SET th.scr_term_hier_id = temp_term_info->ids[d.seq].scr_term_hier_id, th.scr_pattern_id = reply
      ->patterns[x].scr_pattern_id, th.scr_sentence_id = temp_term_info->ids[d.seq].sentence_id,
      th.scr_term_id = temp_term_info->ids[d.seq].scr_term_id, th.parent_term_hier_id =
      temp_term_info->ids[d.seq].parent_id, th.source_term_hier_id = request->patterns[x].term_hier[d
      .seq].source_term_hier_id,
      th.cki_source = request->patterns[x].term_hier[d.seq].cki_source, th.cki_identifier = request->
      patterns[x].term_hier[d.seq].cki_identifier, th.sequence_number = request->patterns[x].
      term_hier[d.seq].sequence_number,
      th.recommended_cd = request->patterns[x].term_hier[d.seq].recommended_cd, th.dependency_group
       = request->patterns[x].term_hier[d.seq].dependency_group, th.dependency_cd = request->
      patterns[x].term_hier[d.seq].dependency_cd,
      th.default_cd = request->patterns[x].term_hier[d.seq].default_cd, th.updt_id = reqinfo->updt_id,
      th.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      th.updt_task = reqinfo->updt_task, th.updt_applctx = reqinfo->updt_applctx, th.concept_cki =
      request->patterns[x].term_hier[d.seq].hier_concept_cki
     PLAN (d)
      JOIN (th)
     WITH nocounter
    ;end insert
    IF (curqual != number_terms)
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING TERM_HIER",cps_insert_msg,x,
      0,0)
     GO TO exit_script
    ENDIF
   ENDIF
   CALL addtermaction(null)
   FREE SET temp_term_info
 ENDFOR
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SUBROUTINE scdgetuniqueid(null)
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
 END ;Subroutine
 SUBROUTINE addtermtextdefinition(null)
   SET number_to_add = size(request->patterns[x].term_hier[z].term_language,5)
   IF (number_to_add != 0)
    INSERT  FROM scr_term_text tt,
      (dummyt d  WITH seq = value(number_to_add))
     SET tt.scr_term_id = g_scr_term_id, tt.language_cd = request->patterns[x].term_hier[z].
      term_language[d.seq].language_cd, tt.display = request->patterns[x].term_hier[z].term_language[
      d.seq].display,
      tt.definition = request->patterns[x].term_hier[z].term_language[d.seq].definition, tt
      .text_representation = request->patterns[x].term_hier[z].term_language[d.seq].
      text_representation, tt.text_negation_rule_cd = request->patterns[x].term_hier[z].
      term_language[d.seq].text_negation_rule_cd,
      tt.text_format_rule_cd = request->patterns[x].term_hier[z].term_language[d.seq].
      text_format_rule_cd, tt.external_reference_info = request->patterns[x].term_hier[z].
      term_language[d.seq].external_reference_info
     PLAN (d)
      JOIN (tt)
     WITH nocounter
    ;end insert
    IF (curqual != number_to_add)
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING TERM TEXT",cps_insert_msg,x,
      z,0)
     RETURN
    ENDIF
   ENDIF
   SET number_to_add = size(request->patterns[x].term_hier[z].term_def,5)
   IF (number_to_add != 0)
    INSERT  FROM scr_term_definition td,
      (dummyt d  WITH seq = value(number_to_add))
     SET td.scr_term_def_id = g_scr_term_id, td.scr_term_def_type_cd = request->patterns[x].
      term_hier[z].term_def[d.seq].scr_term_def_type_cd, td.scr_term_def_key = request->patterns[x].
      term_hier[z].term_def[d.seq].scr_term_def_key,
      td.fkey_id = request->patterns[x].term_hier[z].term_def[d.seq].fkey_id, td.fkey_entity_name =
      request->patterns[x].term_hier[z].term_def[d.seq].fkey_entity_name, td.def_text = request->
      patterns[x].term_hier[z].term_def[d.seq].def_text
     PLAN (d)
      JOIN (td)
     WITH nocounter
    ;end insert
    IF (curqual != number_to_add)
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING TERM DEFINITION",cps_insert_msg,x,
      z,0)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addterm(null)
  SET number_term_def = size(request->patterns[x].term_hier[z].term_def,5)
  IF (g_scr_term_id=0.0)
   CALL scdgetuniqueid(null)
   IF (failed=1)
    RETURN
   ENDIF
   SET g_scr_term_id = unique_id
   SET temp_term_info->ids[z].scr_term_id = unique_id
   SET reply->patterns[x].term_hier[z].scr_term_id = g_scr_term_id
   INSERT  FROM scr_term te
    SET te.scr_term_id = g_scr_term_id, te.scr_term_def_id =
     IF (number_term_def=0) 0.0
     ELSE g_scr_term_id
     ENDIF
     , te.term_type_cd = request->patterns[x].term_hier[z].term_type_cd,
     te.state_logic_cd = request->patterns[x].term_hier[z].state_logic_cd, te.repeat_cd = request->
     patterns[x].term_hier[z].repeat_cd, te.concept_source_cd = request->patterns[x].term_hier[z].
     concept_source_cd,
     te.concept_identifier = request->patterns[x].term_hier[z].concept_identifier, te.concept_cki =
     request->patterns[x].term_hier[z].concept_cki, te.store_cd = request->patterns[x].term_hier[z].
     store_cd,
     te.visible_cd = request->patterns[x].term_hier[z].visible_cd, te.restrict_to_sex = request->
     patterns[x].term_hier[z].restrict_to_sex, te.youngest_age = request->patterns[x].term_hier[z].
     youngest_age,
     te.oldest_age = request->patterns[x].term_hier[z].oldest_age, te.eligibility_check_cd = request
     ->patterns[x].term_hier[z].eligibility_check_cd, te.active_ind = 1,
     te.active_status_cd = reqdata->active_status_cd, te.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), te.active_status_prsnl_id = reqinfo->updt_id,
     te.updt_id = reqinfo->updt_id, te.updt_dt_tm = cnvtdatetime(curdate,curtime3), te.updt_task =
     reqinfo->updt_task,
     te.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING TERM",cps_insert_msg,x,
     z,0)
    RETURN
   ENDIF
   CALL addtermtextdefinition(null)
  ELSE
   UPDATE  FROM scr_term te
    SET te.scr_term_def_id =
     IF (number_term_def=0) 0.0
     ELSE g_scr_term_id
     ENDIF
     , te.term_type_cd = request->patterns[x].term_hier[z].term_type_cd, te.state_logic_cd = request
     ->patterns[x].term_hier[z].state_logic_cd,
     te.repeat_cd = request->patterns[x].term_hier[z].repeat_cd, te.concept_source_cd = request->
     patterns[x].term_hier[z].concept_source_cd, te.concept_identifier = request->patterns[x].
     term_hier[z].concept_identifier,
     te.concept_cki = request->patterns[x].term_hier[z].concept_cki, te.store_cd = request->patterns[
     x].term_hier[z].store_cd, te.visible_cd = request->patterns[x].term_hier[z].visible_cd,
     te.restrict_to_sex = request->patterns[x].term_hier[z].restrict_to_sex, te.youngest_age =
     request->patterns[x].term_hier[z].youngest_age, te.oldest_age = request->patterns[x].term_hier[z
     ].oldest_age,
     te.eligibility_check_cd = request->patterns[x].term_hier[z].eligibility_check_cd, te.active_ind
      =
     IF ((reqdata->active_status_cd != request->patterns[x].term_hier[z].active_status_cd)) 0
     ELSE 1
     ENDIF
     , te.active_status_cd = request->patterns[x].term_hier[z].active_status_cd,
     te.active_status_dt_tm = cnvtdatetime(curdate,curtime3), te.active_status_prsnl_id = reqinfo->
     updt_id, te.updt_id = reqinfo->updt_id,
     te.updt_dt_tm = cnvtdatetime(curdate,curtime3), te.updt_task = reqinfo->updt_task, te
     .updt_applctx = reqinfo->updt_applctx
    WHERE te.scr_term_id=g_scr_term_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    DECLARE exists_id = f8
    SELECT
     exists_id = count(*)
     FROM scr_term t
     WHERE t.scr_term_id=g_scr_term_id
     WITH nocounter
    ;end select
    IF (exists_id != 0.0)
     SET failed = 1
     CALL cps_add_error(cps_update,cps_script_fail,"UPDATING TERM",cps_insert_msg,x,
      z,0)
     RETURN
    ENDIF
    CALL cps_add_error(cps_update,cps_success_warn,"TERM DIDN'T EXIST, RE-ADDING.",cps_insert_msg,x,
     z,0)
    INSERT  FROM scr_term te
     SET te.scr_term_id = g_scr_term_id, te.scr_term_def_id =
      IF (number_term_def=0) 0.0
      ELSE g_scr_term_id
      ENDIF
      , te.term_type_cd = request->patterns[x].term_hier[z].term_type_cd,
      te.state_logic_cd = request->patterns[x].term_hier[z].state_logic_cd, te.repeat_cd = request->
      patterns[x].term_hier[z].repeat_cd, te.concept_source_cd = request->patterns[x].term_hier[z].
      concept_source_cd,
      te.concept_identifier = request->patterns[x].term_hier[z].concept_identifier, te.store_cd =
      request->patterns[x].term_hier[z].store_cd, te.visible_cd = request->patterns[x].term_hier[z].
      visible_cd,
      te.restrict_to_sex = request->patterns[x].term_hier[z].restrict_to_sex, te.youngest_age =
      request->patterns[x].term_hier[z].youngest_age, te.oldest_age = request->patterns[x].term_hier[
      z].oldest_age,
      te.eligibility_check_cd = request->patterns[x].term_hier[z].eligibility_check_cd, te.active_ind
       = 1, te.active_status_cd = reqdata->active_status_cd,
      te.active_status_dt_tm = cnvtdatetime(curdate,curtime3), te.active_status_prsnl_id = reqinfo->
      updt_id, te.updt_id = reqinfo->updt_id,
      te.updt_dt_tm = cnvtdatetime(curdate,curtime3), te.updt_task = reqinfo->updt_task, te
      .updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"RE-INSERTING TERM",cps_insert_msg,x,
      z,0)
     RETURN
    ENDIF
   ELSE
    DELETE  FROM scr_term_text tt
     WHERE tt.scr_term_id=g_scr_term_id
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET failed = 1
     CALL cps_add_error(cps_delete,cps_script_fail,"DELETING TERM TEXT",cps_delete_msg,x,
      z,0)
     RETURN
    ENDIF
    DELETE  FROM scr_term_definition td
     WHERE td.scr_term_def_id=g_scr_term_id
     WITH nocounter
    ;end delete
   ENDIF
   CALL addtermtextdefinition(null)
  ENDIF
 END ;Subroutine
 SUBROUTINE addtermaction(null)
   DECLARE actions_to_add = i4
   DECLARE action_cd = f8
   DECLARE a = i4
   DECLARE cur_blob_idx = i4
   DECLARE cur_blob_id = f8
   DECLARE cur_target_id = f8
   DECLARE cur_target_name = vc
   DECLARE g_unique_expr_id = f8
   SET number_terms = size(request->patterns[x].term_hier,5)
   FOR (z = 1 TO number_terms)
     SET actions_to_add = size(request->patterns[x].term_hier[z].term_actions,5)
     SET stat = alterlist(reply->patterns[x].term_hier[z].term_actions,value(actions_to_add))
     FOR (a = 1 TO actions_to_add)
       SET g_unique_expr_id = request->patterns[x].term_hier[z].term_actions[a].expr_id
       IF ((request->patterns[x].term_hier[z].term_actions[a].expr_cki != ""))
        SET g_unique_expr_id = 0.0
        SELECT INTO "nl:"
         e.expression_id
         FROM expression e
         WHERE (e.expression_cki=request->patterns[x].term_hier[z].term_actions[a].expr_cki)
         DETAIL
          g_unique_expr_id = e.expression_id
         WITH nocounter
        ;end select
        IF (g_unique_expr_id=0.0)
         CALL scdgetuniqueid(null)
         IF (failed=1)
          RETURN
         ENDIF
         SET g_unique_expr_id = unique_id
         CALL addexpression(null)
        ELSE
         CALL updateexpression(null)
        ENDIF
       ENDIF
       SET cur_target_id = request->patterns[x].term_hier[z].term_actions[a].target_entity_id
       SET cur_target_name = request->patterns[x].term_hier[z].term_actions[a].target_entity_name
       IF ((request->patterns[x].term_hier[z].term_actions[a].scr_action_cd=0))
        SET stat = uar_get_meaning_by_codeset(31337,nullterm(request->patterns[x].term_hier[z].
          term_actions[a].scr_action_mean),1,action_cd)
       ELSE
        SET action_cd = request->patterns[x].term_hier[z].term_actions[a].scr_action_cd
       ENDIF
       IF (cur_target_id=0.0
        AND cur_target_name != "")
        SET cur_blob_idx = request->patterns[x].term_hier[z].term_actions[a].target_entity_blob_idx
        IF (cur_blob_idx > 0
         AND cur_blob_idx <= number_terms)
         SET cur_target_id = reply->patterns[x].term_hier[cur_blob_idx].scr_term_hier_id
        ELSE
         SET cur_target_id = 0
        ENDIF
       ENDIF
       IF ((request->patterns[x].term_hier[z].term_actions[a].target_cki_identifier != ""))
        DECLARE pattern_type_mean = vc
        SELECT INTO "nl:"
         FROM scr_term_hier hier
         WHERE (hier.scr_pattern_id=reply->patterns[x].scr_pattern_id)
          AND (hier.cki_source=request->patterns[x].term_hier[z].term_actions[a].target_cki_source)
          AND (hier.cki_identifier=request->patterns[x].term_hier[z].term_actions[a].
         target_cki_identifier)
         DETAIL
          cur_target_id = hier.scr_term_hier_id
          IF (hier.source_term_hier_id > 0)
           pattern_type_mean = uar_get_code_meaning(request->patterns[x].pattern_type_cd)
           IF (pattern_type_mean="EP")
            cur_target_id = hier.source_term_hier_id
           ENDIF
          ENDIF
        ;end select
        SET cur_target_name = "SCR_TERM_HIER" WITH nocounter
       ENDIF
       CALL scdgetuniqueid(null)
       IF (failed=1)
        RETURN
       ENDIF
       INSERT  FROM scr_action sa
        SET sa.scr_action_id = unique_id, sa.scr_action_cd = action_cd, sa.parent_entity_name =
         "SCR_TERM_HIER",
         sa.parent_entity_id = reply->patterns[x].term_hier[z].scr_term_hier_id, sa.target_entity_id
          = cur_target_id, sa.target_entity_name = cur_target_name,
         sa.expression_owner_ind = request->patterns[x].term_hier[z].term_actions[a].expr_owner_ind,
         sa.expression_id = g_unique_expr_id
        WITH nocounter
       ;end insert
       SET reply->patterns[x].term_hier[z].term_actions[a].scr_action_id = unique_id
       SET reply->patterns[x].term_hier[z].term_actions[a].expr_id = g_unique_expr_id
       IF (curqual != 1)
        SET failed = 1
        CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING TERM ACTIONS",cps_insert_msg,x,
         z,0)
        RETURN
       ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE addparagraphaction(null)
  SET para_actions_to_add = size(request->patterns[x].paragraphs[y].paragraph_actions,5)
  FOR (b = 1 TO para_actions_to_add)
    CALL scdgetuniqueid(null)
    IF (failed=1)
     RETURN
    ENDIF
    INSERT  FROM scr_action sa
     SET sa.scr_action_id = unique_id, sa.scr_action_cd = request->patterns[x].paragraphs[y].
      paragraph_actions[b].scr_action_cd, sa.parent_entity_name = "SCR_PARAGRAPH",
      sa.parent_entity_id = g_scr_paragraph_id
     WITH nocounter
    ;end insert
    IF (curqual != 1)
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING PARAGRAPH ACTIONS",cps_insert_msg,x,
      b,0)
     RETURN
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE addexpression(null)
   INSERT  FROM expression expr
    SET expr.expression_id = g_unique_expr_id, expr.expression_display = request->patterns[x].
     term_hier[z].term_actions[a].expr_display, expr.expression_cki = request->patterns[x].term_hier[
     z].term_actions[a].expr_cki
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING EXPRESSION",cps_insert_msg,x,
     a,0)
    RETURN
   ENDIF
   CALL addexpressioncomponents(null)
 END ;Subroutine
 SUBROUTINE updateexpression(null)
   SELECT INTO "nl:"
    FROM expression expr
    WHERE expr.expression_id=g_unique_expr_id
    WITH forupdatewait(expr)
   ;end select
   UPDATE  FROM expression expr
    SET expr.expression_display = request->patterns[x].term_hier[z].term_actions[a].expr_display,
     expr.expression_cki = request->patterns[x].term_hier[z].term_actions[a].expr_cki
    WHERE expr.expression_id=g_unique_expr_id
    WITH nocounter
   ;end update
   IF (curqual != 1)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"UPDATING EXPRESSION",cps_insert_msg,x,
     a,0)
    RETURN
   ENDIF
   DELETE  FROM expression_comp ec
    WHERE ec.expression_id=g_unique_expr_id
    WITH nocounter
   ;end delete
   CALL addexpressioncomponents(null)
 END ;Subroutine
 SUBROUTINE addexpressioncomponents(null)
   FREE RECORD compids
   RECORD compids(
     1 comp_idx[*]
       2 comp_id = f8
   )
   DECLARE cur_parent_id = f8 WITH protect, noconstant(0.0)
   DECLARE c = i4
   DECLARE comps_to_add = i4
   DECLARE cur_idx = i4
   DECLARE cur_parent_idx = i4
   DECLARE cur_expr_blob_idx = i4
   DECLARE cur_fkey_id = f8
   DECLARE cur_fkey_name = vc
   DECLARE cur_units_cd = f8
   DECLARE cur_expr_comp_cd = f8
   SET comps_to_add = size(request->patterns[x].term_hier[z].term_actions[a].expr_comps,5)
   SET stat = alterlist(compids->comp_idx,comps_to_add)
   FOR (c = 1 TO comps_to_add)
    SET cur_idx = request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].expr_comp_id
    IF (cur_idx > 0
     AND cur_idx <= comps_to_add)
     CALL scdgetuniqueid(null)
     IF (failed=1)
      RETURN
     ENDIF
     SET compids->comp_idx[cur_idx].comp_id = unique_id
    ENDIF
   ENDFOR
   FOR (c = 1 TO comps_to_add)
     SET cur_idx = request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].expr_comp_id
     SET cur_parent_idx = request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].
     parent_expr_comp_id
     IF (cur_parent_idx != 0)
      SET cur_parent_id = compids->comp_idx[cur_parent_idx].comp_id
     ELSE
      SET cur_parent_id = 0.0
     ENDIF
     SET cur_fkey_id = request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].value_fkey_id
     SET cur_fkey_name = request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].
     value_fkey_entity_name
     SET cur_expr_blob_idx = request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].
     value_fkey_blob_idx
     IF (cur_expr_blob_idx > 0
      AND cur_expr_blob_idx <= number_terms)
      SET cur_fkey_id = reply->patterns[x].term_hier[cur_expr_blob_idx].scr_term_hier_id
      SET cur_fkey_name = "SCR_TERM_HIER"
     ENDIF
     IF ((request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].value_fkey_cki_identifier
      != ""))
      DECLARE pattern_type_mean = vc
      SELECT INTO "nl:"
       FROM scr_term_hier hier
       WHERE (hier.scr_pattern_id=reply->patterns[x].scr_pattern_id)
        AND (hier.cki_source=request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].
       value_fkey_cki_source)
        AND (hier.cki_identifier=request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].
       value_fkey_cki_identifier)
       DETAIL
        cur_fkey_id = hier.scr_term_hier_id
        IF (hier.source_term_hier_id > 0)
         pattern_type_mean = uar_get_code_meaning(request->patterns[x].pattern_type_cd)
         IF (pattern_type_mean="EP")
          cur_fkey_id = hier.source_term_hier_id
         ENDIF
        ENDIF
      ;end select
      SET cur_fkey_name = "SCR_TERM_HIER" WITH nocounter
     ENDIF
     SET cur_units_cd = request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].units_cd
     IF ((request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].units_mean != ""))
      SET cur_units_cd = 0.0
      SET stat = uar_get_meaning_by_codeset(15751,nullterm(request->patterns[x].term_hier[z].
        term_actions[a].expr_comps[c].units_mean),1,cur_units_cd)
      IF (cur_units_cd=0.0)
       SET stat = uar_get_meaning_by_codeset(31340,nullterm(request->patterns[x].term_hier[z].
         term_actions[a].expr_comps[c].units_mean),1,cur_units_cd)
      ENDIF
     ENDIF
     SET cur_expr_comp_cd = request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].
     expr_comp_cd
     IF ((request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].expr_comp_mean != ""))
      SET cur_expr_comp_cd = 0.0
      SET stat = uar_get_meaning_by_codeset(31338,nullterm(request->patterns[x].term_hier[z].
        term_actions[a].expr_comps[c].expr_comp_mean),1,cur_expr_comp_cd)
     ENDIF
     INSERT  FROM expression_comp ec
      SET ec.expression_comp_id = compids->comp_idx[cur_idx].comp_id, ec.expression_comp_role_cd =
       cur_expr_comp_cd, ec.expression_id = g_unique_expr_id,
       ec.parent_expression_comp_id = cur_parent_id, ec.sequence_number = request->patterns[x].
       term_hier[z].term_actions[a].expr_comps[c].sequence_number, ec.units_cd = cur_units_cd,
       ec.value_dt_tm = cnvtdate(request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].
        value_dt_tm), ec.value_fkey_entity_name = request->patterns[x].term_hier[z].term_actions[a].
       expr_comps[c].value_fkey_entity_name, ec.value_fkey_id = cur_fkey_id,
       ec.value_number = request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].value_number,
       ec.value_text = request->patterns[x].term_hier[z].term_actions[a].expr_comps[c].value_text
      WITH nocounter
     ;end insert
     IF (curqual != 1)
      SET failed = 1
      CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING EXPRESSION COMPONENTS",cps_insert_msg,
       x,
       a,0)
      RETURN
     ENDIF
   ENDFOR
 END ;Subroutine
END GO
