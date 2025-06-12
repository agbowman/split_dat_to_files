CREATE PROGRAM cps_get_scd_patrn_detail:dba
 RECORD reply(
   1 patterns[*]
     2 scr_pattern_id = f8
     2 cki_source = vc
     2 cki_identifier = vc
     2 pattern_type_cd = f8
     2 pattern_type_mean = vc
     2 display = vc
     2 definition = vc
     2 active_status_cd = f8
     2 active_status_mean = vc
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 entry_mode_cd = f8
     2 entry_mode_mean = vc
     2 paragraphs[*]
       3 scr_paragraph_type_id = f8
       3 cki_source = vc
       3 cki_identifier = vc
       3 sequence_number = i4
       3 display = vc
       3 description = vc
       3 canonical_pattern_id = f8
       3 canonical_pat_cki_source = vc
       3 canonical_pat_cki_identifier = vc
       3 paragraph_class_cd = f8
       3 paragraph_class_mean = vc
       3 default_cd = f8
       3 default_mean = vc
       3 master_sequence_number = i4
       3 text_format_rule_cd = f8
       3 text_format_rule_mean = vc
       3 paragraph_actions[*]
         4 scr_action_id = f8
         4 scr_action_cd = f8
         4 scr_action_mean = vc
     2 sentences[*]
       3 scr_sentence_id = f8
       3 cki_source = vc
       3 cki_identifier = vc
       3 scr_paragraph_type_id = f8
       3 scr_ptype_cki_source = vc
       3 scr_ptype_cki_identifier = vc
       3 sequence_number = i4
       3 canonical_sentence_pattern_id = f8
       3 can_sent_pat_cki_source = vc
       3 can_sent_pat_cki_identifier = vc
       3 sentence_topic_cd = f8
       3 sentence_topic_disp = vc
       3 sentence_topic_desc = vc
       3 sentence_topic_mean = vc
       3 recommended_cd = f8
       3 recommended_mean = vc
       3 default_cd = f8
       3 default_mean = vc
       3 text_format_rule_cd = f8
       3 text_format_rule_mean = vc
       3 updt_dt_tm = dq8
     2 term_hier[*]
       3 scr_term_hier_id = f8
       3 cki_source = vc
       3 cki_identifier = vc
       3 scr_sentence_id = f8
       3 scr_sentence_cki_source = vc
       3 scr_sentence_cki_identifier = vc
       3 parent_term_hier_id = f8
       3 parent_term_hier_cki_source = vc
       3 parent_term_hier_cki_identifier = vc
       3 sequence_number = i4
       3 scr_term_id = f8
       3 scr_term_cki_source = vc
       3 scr_term_cki_identifier = vc
       3 scr_term_pattern_cki_source = vc
       3 scr_term_pattern_cki_identifier = vc
       3 term_type_cd = f8
       3 term_type_mean = vc
       3 display = vc
       3 definition = vc
       3 recommended_cd = f8
       3 recommended_mean = vc
       3 dependency_group = i4
       3 dependency_cd = f8
       3 dependency_mean = vc
       3 default_cd = f8
       3 default_mean = vc
       3 source_term_hier_id = f8
       3 source_term_hier_cki_source = vc
       3 source_term_hier_cki_identifier = vc
       3 source_pattern_cki_source = vc
       3 source_pattern_cki_identifier = vc
       3 state_logic_cd = f8
       3 state_logic_mean = vc
       3 store_cd = f8
       3 store_mean = vc
       3 concept_identifier = vc
       3 concept_source_cd = f8
       3 concept_source_mean = vc
       3 concept_cki = vc
       3 visible_cd = f8
       3 visible_mean = vc
       3 youngest_age = f8
       3 oldest_age = f8
       3 restrict_to_sex = vc
       3 eligibility_check_cd = f8
       3 eligibility_check_mean = vc
       3 repeat_cd = f8
       3 repeat_mean = vc
       3 external_reference_info = vc
       3 text_format_rule_cd = f8
       3 text_format_rule_mean = vc
       3 text_negation_rule_cd = f8
       3 text_negation_rule_mean = vc
       3 text_representation = vc
       3 term_data[*]
         4 scr_term_def_type_cd = f8
         4 scr_term_def_type_mean = vc
         4 scr_term_def_key = vc
         4 fkey_id = f8
         4 fkey_entity_name = vc
         4 def_text = vc
       3 term_language[*]
         4 language_cd = f8
         4 language_mean = vc
         4 external_reference_info = vc
         4 text_format_rule_cd = f8
         4 text_format_rule_mean = vc
         4 text_negation_rule_cd = f8
         4 text_negation_rule_mean = vc
         4 text_representation = vc
         4 display = vc
         4 definition = vc
       3 term_actions[*]
         4 scr_action_id = f8
         4 scr_action_cd = f8
         4 scr_action_mean = vc
         4 target_entity_id = f8
         4 target_entity_name = vc
         4 target_cki_source = vc
         4 target_cki_identifier = vc
         4 expr_id = f8
         4 expr_owner_ind = i2
         4 expr_display = vc
         4 expr_cki = vc
         4 expr_comps[*]
           5 expr_comp_id = f8
           5 expr_id = f8
           5 parent_expr_comp_id = f8
           5 expr_comp_cd = f8
           5 expr_comp_mean = vc
           5 sequence_number = i4
           5 units_cd = f8
           5 units_mean = vc
           5 value_number = i4
           5 value_dt_tm = dq8
           5 value_text = vc
           5 value_fkey_blob_idx = i4
           5 value_fkey_id = f8
           5 value_fkey_entity_name = vc
           5 value_fkey_cki_source = vc
           5 value_fkey_cki_identifier = vc
       3 hier_concept_cki = vc
     2 required_field_enforcement_cd = f8
     2 required_field_enforcement_mean = vc
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
 RECORD actionhelper(
   1 bucket[3]
     2 action_cd = f8
     2 par_action_idx = i4
 )
 DECLARE size_bucket_list = i4 WITH noconstant(size(actionhelper->bucket,5))
 DECLARE i = i4 WITH public
 FOR (i = 1 TO size_bucket_list)
  SET actionhelper->bucket[i].par_action_idx = 0
  SET actionhelper->bucket[i].action_cd = 0.0
 ENDFOR
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
 SET reply->status_data.status = "F"
 SET p1 = 0
 SET failed = 0
 DECLARE action_freetext_cd = f8 WITH constant(uar_get_code_by("MEANING",31337,"DEFFREETEXT"))
 DECLARE action_dictation_cd = f8 WITH constant(uar_get_code_by("MEANING",31337,"DICTATION"))
 DECLARE action_structured_cd = f8 WITH constant(uar_get_code_by("MEANING",31337,"STRUCTURED"))
 DECLARE action_copypara_cd = f8 WITH constant(uar_get_code_by("MEANING",31337,"COPYPARA"))
 DECLARE action_nocopypara_cd = f8 WITH constant(uar_get_code_by("MEANING",31337,"NOCOPYPARA"))
 DECLARE def_mode_entry_bucket_idx = i2 WITH constant(1)
 DECLARE copy_para_bucket_idx = i2 WITH constant(2)
 DECLARE required_bucket_idx = i2 WITH constant(3)
 SET number_to_get = size(request->patterns,5)
 FOR (inx0 = 1 TO number_to_get)
  IF ((request->patterns[inx0].id=0))
   SET failed = 1
   CALL cps_add_error(cps_select,cps_script_fail,"No pattern Found",cps_select_msg,0,
    0,0)
   GO TO exit_script
  ENDIF
  IF ((request->export_ind=1))
   CALL cps_get_scd_patrn_export(p1)
  ELSE
   CALL cps_get_scd_patrn_regular(p1)
  ENDIF
 ENDFOR
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE cps_get_scd_patrn_regular(dp1)
   SET par_idx = 0
   SET par_action_idx = 0
   SELECT INTO "NL:"
    pattern_id = pat.scr_pattern_id"###########################"
    FROM (dummyt d  WITH seq = 1),
     scr_paragraph_type part,
     scr_paragraph par,
     scr_action action,
     scr_pattern pat
    PLAN (pat
     WHERE (pat.scr_pattern_id=request->patterns[inx0].id))
     JOIN (d
     WHERE d.seq=1)
     JOIN (par
     WHERE par.scr_pattern_id=pat.scr_pattern_id)
     JOIN (action
     WHERE ((action.parent_entity_id=par.scr_paragraph_id
      AND action.parent_entity_name="SCR_PARAGRAPH") OR (((action.parent_entity_id=par
     .scr_paragraph_type_id
      AND action.parent_entity_name="SCR_PARAGRAPH_TYPE") OR (action.scr_action_id=0)) )) )
     JOIN (part
     WHERE part.scr_paragraph_type_id=par.scr_paragraph_type_id)
    ORDER BY pat.scr_pattern_id, par.scr_paragraph_id
    HEAD REPORT
     stat = alterlist(reply->patterns,value(number_to_get))
    HEAD pattern_id
     stat = alterlist(reply->patterns[inx0].paragraphs,10), reply->patterns[inx0].scr_pattern_id =
     pat.scr_pattern_id, reply->patterns[inx0].pattern_type_cd = pat.pattern_type_cd,
     reply->patterns[inx0].display = pat.display, reply->patterns[inx0].definition = pat.definition,
     reply->patterns[inx0].cki_source = pat.cki_source,
     reply->patterns[inx0].cki_identifier = pat.cki_identifier, reply->patterns[inx0].
     active_status_cd = pat.active_status_cd, reply->patterns[inx0].active_status_mean =
     uar_get_code_meaning(pat.active_status_cd),
     reply->patterns[inx0].updt_dt_tm = pat.updt_dt_tm, reply->patterns[inx0].updt_cnt = pat.updt_cnt,
     reply->patterns[inx0].entry_mode_cd = pat.entry_mode_cd
     IF (pat.entry_mode_cd)
      reply->patterns[inx0].entry_mode_mean = uar_get_code_meaning(pat.entry_mode_cd)
     ENDIF
     reply->patterns[inx0].required_field_enforcement_cd = pat.required_field_enforcement_cd
     IF (pat.required_field_enforcement_cd)
      reply->patterns[inx0].required_field_enforcement_mean = uar_get_code_meaning(pat
       .required_field_enforcement_cd)
     ENDIF
    HEAD par.scr_paragraph_id
     IF (part.scr_paragraph_type_id != 0.0)
      par_idx = (par_idx+ 1)
      IF (mod(par_idx,10)=0)
       stat = alterlist(reply->patterns[inx0].paragraphs,(par_idx+ 10))
      ENDIF
      reply->patterns[inx0].paragraphs[par_idx].scr_paragraph_type_id = part.scr_paragraph_type_id,
      reply->patterns[inx0].paragraphs[par_idx].cki_source = part.cki_source, reply->patterns[inx0].
      paragraphs[par_idx].cki_identifier = part.cki_identifier,
      reply->patterns[inx0].paragraphs[par_idx].display = part.display, reply->patterns[inx0].
      paragraphs[par_idx].description = part.description, reply->patterns[inx0].paragraphs[par_idx].
      text_format_rule_cd = part.text_format_rule_cd,
      reply->patterns[inx0].paragraphs[par_idx].canonical_pattern_id = part.canonical_pattern_id,
      reply->patterns[inx0].paragraphs[par_idx].sequence_number = par.sequence_number, reply->
      patterns[inx0].paragraphs[par_idx].default_cd = part.default_cd,
      reply->patterns[inx0].paragraphs[par_idx].master_sequence_number = part.sequence_number
     ENDIF
    DETAIL
     IF (action.scr_action_id > 0.0)
      IF (((action.scr_action_cd=action_freetext_cd) OR (((action.scr_action_cd=action_structured_cd)
       OR (action.scr_action_cd=action_dictation_cd)) )) )
       curindex = def_mode_entry_bucket_idx
      ELSEIF (((action.scr_action_cd=action_copypara_cd) OR (action.scr_action_cd=
      action_nocopypara_cd)) )
       curindex = copy_para_bucket_idx
      ELSE
       curindex = required_bucket_idx
      ENDIF
      IF ((actionhelper->bucket[curindex].action_cd > 0.0))
       IF (action.parent_entity_name="SCR_PARAGRAPH")
        action_to_replace = actionhelper->bucket[curindex].par_action_idx, reply->patterns[inx0].
        paragraphs[par_idx].paragraph_actions[action_to_replace].scr_action_cd = action.scr_action_cd,
        reply->patterns[inx0].paragraphs[par_idx].paragraph_actions[action_to_replace].scr_action_id
         = action.scr_action_id,
        reply->patterns[inx0].paragraphs[par_idx].paragraph_actions[action_to_replace].
        scr_action_mean = uar_get_code_meaning(action.scr_action_cd)
       ENDIF
      ELSE
       par_action_idx = (par_action_idx+ 1)
       IF (mod(par_action_idx,3)=1)
        stat = alterlist(reply->patterns[inx0].paragraphs[par_idx].paragraph_actions,(par_action_idx
         + 2))
       ENDIF
       reply->patterns[inx0].paragraphs[par_idx].paragraph_actions[par_action_idx].scr_action_cd =
       action.scr_action_cd, reply->patterns[inx0].paragraphs[par_idx].paragraph_actions[
       par_action_idx].scr_action_id = action.scr_action_id, reply->patterns[inx0].paragraphs[par_idx
       ].paragraph_actions[par_action_idx].scr_action_mean = uar_get_code_meaning(action
        .scr_action_cd),
       actionhelper->bucket[curindex].par_action_idx = par_action_idx, actionhelper->bucket[curindex]
       .action_cd = action.scr_action_cd
      ENDIF
     ENDIF
    FOOT  par.scr_paragraph_id
     FOR (i = 1 TO size_bucket_list)
      actionhelper->bucket[i].par_action_idx = 0,actionhelper->bucket[i].action_cd = 0.0
     ENDFOR
     stat = alterlist(reply->patterns[inx0].paragraphs[par_idx].paragraph_actions,par_action_idx),
     par_action_idx = 0
    WITH nocounter, outerjoin = d
   ;end select
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_select,cps_script_fail,"No pattern Found",cps_select_msg,0,
     0,0)
    RETURN
   ENDIF
   SET stat = alterlist(reply->patterns[inx0].paragraphs,par_idx)
   SET stat = alterlist(reply->patterns[inx0].sentences,50)
   SET sent_idx = 0
   SELECT INTO "NL:"
    FROM scr_sentence sent
    WHERE (sent.scr_pattern_id=request->patterns[inx0].id)
    DETAIL
     sent_idx = (sent_idx+ 1)
     IF (mod(sent_idx,50)=0)
      stat = alterlist(reply->patterns[inx0].sentences,(sent_idx+ 50))
     ENDIF
     reply->patterns[inx0].sentences[sent_idx].scr_sentence_id = sent.scr_sentence_id, reply->
     patterns[inx0].sentences[sent_idx].scr_paragraph_type_id = sent.scr_paragraph_type_id, reply->
     patterns[inx0].sentences[sent_idx].canonical_sentence_pattern_id = sent
     .canonical_sentence_pattern_id,
     reply->patterns[inx0].sentences[sent_idx].sequence_number = sent.sequence_number, reply->
     patterns[inx0].sentences[sent_idx].sentence_topic_cd = sent.sentence_topic_cd, reply->patterns[
     inx0].sentences[sent_idx].text_format_rule_cd = sent.text_format_rule_cd,
     reply->patterns[inx0].sentences[sent_idx].recommended_cd = sent.recommended_cd, reply->patterns[
     inx0].sentences[sent_idx].default_cd = sent.default_cd, reply->patterns[inx0].sentences[sent_idx
     ].updt_dt_tm = sent.updt_dt_tm
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->patterns[inx0].sentences,sent_idx)
   SET stat = alterlist(reply->patterns[inx0].term_hier,5000)
   SET term_idx = 0
   SELECT INTO "NL:"
    FROM scr_term_definition def,
     scr_term_text text,
     scr_term term,
     scr_term_hier hier
    WHERE (hier.scr_pattern_id=request->patterns[inx0].id)
     AND term.scr_term_id=hier.scr_term_id
     AND text.scr_term_id=term.scr_term_id
     AND (text.language_cd=request->language_cd)
     AND def.scr_term_def_id=term.scr_term_def_id
    ORDER BY hier.scr_term_hier_id
    HEAD hier.scr_term_hier_id
     term_idx = (term_idx+ 1)
     IF (mod(term_idx,5000)=0)
      stat = alterlist(reply->patterns[inx0].term_hier,(term_idx+ 5000))
     ENDIF
     term_def_idx = 0, stat = alterlist(reply->patterns[inx0].term_hier[term_idx].term_data,5), reply
     ->patterns[inx0].term_hier[term_idx].scr_term_hier_id = hier.scr_term_hier_id,
     reply->patterns[inx0].term_hier[term_idx].parent_term_hier_id = hier.parent_term_hier_id, reply
     ->patterns[inx0].term_hier[term_idx].scr_sentence_id = hier.scr_sentence_id, reply->patterns[
     inx0].term_hier[term_idx].sequence_number = hier.sequence_number,
     reply->patterns[inx0].term_hier[term_idx].recommended_cd = hier.recommended_cd, reply->patterns[
     inx0].term_hier[term_idx].dependency_group = hier.dependency_group, reply->patterns[inx0].
     term_hier[term_idx].dependency_cd = hier.dependency_cd,
     reply->patterns[inx0].term_hier[term_idx].default_cd = hier.default_cd, reply->patterns[inx0].
     term_hier[term_idx].source_term_hier_id = hier.source_term_hier_id, reply->patterns[inx0].
     term_hier[term_idx].cki_source = hier.cki_source,
     reply->patterns[inx0].term_hier[term_idx].cki_identifier = hier.cki_identifier, reply->patterns[
     inx0].term_hier[term_idx].concept_identifier = term.concept_identifier, reply->patterns[inx0].
     term_hier[term_idx].concept_source_cd = term.concept_source_cd,
     reply->patterns[inx0].term_hier[term_idx].concept_cki = term.concept_cki, reply->patterns[inx0].
     term_hier[term_idx].eligibility_check_cd = term.eligibility_check_cd, reply->patterns[inx0].
     term_hier[term_idx].visible_cd = term.visible_cd,
     reply->patterns[inx0].term_hier[term_idx].oldest_age = term.oldest_age, reply->patterns[inx0].
     term_hier[term_idx].repeat_cd = term.repeat_cd, reply->patterns[inx0].term_hier[term_idx].
     restrict_to_sex = term.restrict_to_sex,
     reply->patterns[inx0].term_hier[term_idx].state_logic_cd = term.state_logic_cd, reply->patterns[
     inx0].term_hier[term_idx].store_cd = term.store_cd, reply->patterns[inx0].term_hier[term_idx].
     term_type_cd = term.term_type_cd,
     reply->patterns[inx0].term_hier[term_idx].youngest_age = term.youngest_age, reply->patterns[inx0
     ].term_hier[term_idx].hier_concept_cki = hier.concept_cki, reply->patterns[inx0].term_hier[
     term_idx].scr_term_id = term.scr_term_id,
     reply->patterns[inx0].term_hier[term_idx].definition = text.definition, reply->patterns[inx0].
     term_hier[term_idx].display = text.display, reply->patterns[inx0].term_hier[term_idx].
     external_reference_info = text.external_reference_info,
     reply->patterns[inx0].term_hier[term_idx].text_format_rule_cd = text.text_format_rule_cd, reply
     ->patterns[inx0].term_hier[term_idx].text_negation_rule_cd = text.text_negation_rule_cd, reply->
     patterns[inx0].term_hier[term_idx].text_representation = text.text_representation
    DETAIL
     IF (def.scr_term_def_id != 0)
      term_def_idx = (term_def_idx+ 1)
      IF (mod(term_def_idx,5)=0)
       stat = alterlist(reply->patterns[inx0].term_hier[term_idx].term_data,(term_def_idx+ 5))
      ENDIF
      reply->patterns[inx0].term_hier[term_idx].term_data[term_def_idx].scr_term_def_type_cd = def
      .scr_term_def_type_cd, reply->patterns[inx0].term_hier[term_idx].term_data[term_def_idx].
      scr_term_def_key = def.scr_term_def_key, reply->patterns[inx0].term_hier[term_idx].term_data[
      term_def_idx].fkey_id = def.fkey_id,
      reply->patterns[inx0].term_hier[term_idx].term_data[term_def_idx].fkey_entity_name = def
      .fkey_entity_name, reply->patterns[inx0].term_hier[term_idx].term_data[term_def_idx].def_text
       = def.def_text
     ENDIF
    FOOT  hier.scr_term_hier_id
     stat = alterlist(reply->patterns[inx0].term_hier[term_idx].term_data,term_def_idx)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->patterns[inx0].term_hier,term_idx)
   IF (term_idx > 0)
    SET term_action_idx = 0
    SELECT INTO "NL:"
     FROM scr_action action,
      expression expr,
      expression_comp comp,
      (dummyt d  WITH seq = value(term_idx))
     PLAN (d)
      JOIN (action
      WHERE action.parent_entity_name="SCR_TERM_HIER"
       AND (action.parent_entity_id=reply->patterns[inx0].term_hier[d.seq].scr_term_hier_id))
      JOIN (expr
      WHERE action.expression_id=expr.expression_id)
      JOIN (comp
      WHERE comp.expression_id=expr.expression_id)
     ORDER BY action.parent_entity_id, action.scr_action_id
     HEAD action.parent_entity_id
      term_action_idx = 0, expr_comp_idx = 0
     DETAIL
      IF (((term_action_idx=0) OR ((reply->patterns[inx0].term_hier[d.seq].term_actions[
      term_action_idx].scr_action_id != action.scr_action_id))) )
       IF (expr_comp_idx > 0)
        stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
         expr_comps,expr_comp_idx)
       ENDIF
       term_action_idx = (term_action_idx+ 1), expr_comp_idx = 0
       IF (mod(term_action_idx,5)=1)
        stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_actions,(term_action_idx+ 5))
       ENDIF
      ENDIF
      reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].scr_action_id = action
      .scr_action_id, reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
      scr_action_cd = action.scr_action_cd, reply->patterns[inx0].term_hier[d.seq].term_actions[
      term_action_idx].scr_action_mean = uar_get_code_meaning(action.scr_action_cd),
      reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].target_entity_id = action
      .target_entity_id, reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
      target_entity_name = action.target_entity_name, reply->patterns[inx0].term_hier[d.seq].
      term_actions[term_action_idx].expr_id = action.expression_id,
      reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_owner_ind = action
      .expression_owner_ind, reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
      expr_cki = expr.expression_cki, reply->patterns[inx0].term_hier[d.seq].term_actions[
      term_action_idx].expr_display = expr.expression_display
      IF (comp.expression_id > 0)
       expr_comp_idx = (expr_comp_idx+ 1)
       IF (mod(expr_comp_idx,5)=1)
        stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
         expr_comps,(expr_comp_idx+ 5))
       ENDIF
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx]
       .expr_comp_id = comp.expression_comp_id, reply->patterns[inx0].term_hier[d.seq].term_actions[
       term_action_idx].expr_comps[expr_comp_idx].expr_comp_cd = comp.expression_comp_role_cd, reply
       ->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx].
       expr_id = comp.expression_id,
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx]
       .parent_expr_comp_id = comp.parent_expression_comp_id, reply->patterns[inx0].term_hier[d.seq].
       term_actions[term_action_idx].expr_comps[expr_comp_idx].sequence_number = comp.sequence_number,
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx]
       .units_cd = comp.units_cd,
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx]
       .value_dt_tm = comp.value_dt_tm, reply->patterns[inx0].term_hier[d.seq].term_actions[
       term_action_idx].expr_comps[expr_comp_idx].value_fkey_entity_name = comp
       .value_fkey_entity_name, reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
       expr_comps[expr_comp_idx].value_fkey_id = comp.value_fkey_id,
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx]
       .value_number = comp.value_number, reply->patterns[inx0].term_hier[d.seq].term_actions[
       term_action_idx].expr_comps[expr_comp_idx].value_text = comp.value_text
      ENDIF
     FOOT  action.parent_entity_id
      stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_actions,term_action_idx)
      IF (expr_comp_idx > 0)
       stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
        expr_comps,expr_comp_idx)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   SET failed = 0
 END ;Subroutine
 SUBROUTINE cps_get_scd_patrn_export(dp1)
   SET par_idx = 0
   SET par_action_idx = 0
   SELECT INTO "NL:"
    FROM scr_pattern can_pat,
     scr_paragraph_type part,
     scr_action action,
     scr_paragraph par,
     scr_pattern pat
    PLAN (pat
     WHERE (pat.scr_pattern_id=request->patterns[inx0].id))
     JOIN (par
     WHERE par.scr_pattern_id=outerjoin(pat.scr_pattern_id))
     JOIN (action
     WHERE action.parent_entity_id=outerjoin(par.scr_paragraph_id)
      AND action.parent_entity_name=outerjoin("SCR_PARAGRAPH"))
     JOIN (part
     WHERE part.scr_paragraph_type_id=outerjoin(par.scr_paragraph_type_id))
     JOIN (can_pat
     WHERE can_pat.scr_pattern_id=outerjoin(part.canonical_pattern_id))
    ORDER BY pat.scr_pattern_id
    HEAD REPORT
     stat = alterlist(reply->patterns,value(number_to_get))
    HEAD pat.scr_pattern_id
     stat = alterlist(reply->patterns[inx0].paragraphs,10), reply->patterns[inx0].scr_pattern_id =
     pat.scr_pattern_id, reply->patterns[inx0].pattern_type_cd = pat.pattern_type_cd,
     reply->patterns[inx0].display = pat.display, reply->patterns[inx0].definition = pat.definition,
     reply->patterns[inx0].cki_source = pat.cki_source,
     reply->patterns[inx0].cki_identifier = pat.cki_identifier, reply->patterns[inx0].
     active_status_cd = pat.active_status_cd, reply->patterns[inx0].active_status_mean =
     uar_get_code_meaning(pat.active_status_cd),
     reply->patterns[inx0].updt_dt_tm = pat.updt_dt_tm, reply->patterns[inx0].updt_cnt = pat.updt_cnt,
     reply->patterns[inx0].entry_mode_cd = pat.entry_mode_cd
     IF (pat.entry_mode_cd)
      reply->patterns[inx0].entry_mode_mean = uar_get_code_meaning(pat.entry_mode_cd)
     ENDIF
     reply->patterns[inx0].required_field_enforcement_cd = pat.required_field_enforcement_cd
     IF (pat.required_field_enforcement_cd)
      reply->patterns[inx0].required_field_enforcement_mean = uar_get_code_meaning(pat
       .required_field_enforcement_cd)
     ENDIF
    HEAD part.scr_paragraph_type_id
     IF (part.scr_paragraph_type_id != 0.0)
      par_idx = (par_idx+ 1)
      IF (mod(par_idx,10)=0)
       stat = alterlist(reply->patterns[inx0].paragraphs,(par_idx+ 10))
      ENDIF
      reply->patterns[inx0].paragraphs[par_idx].scr_paragraph_type_id = part.scr_paragraph_type_id,
      reply->patterns[inx0].paragraphs[par_idx].cki_source = part.cki_source, reply->patterns[inx0].
      paragraphs[par_idx].cki_identifier = part.cki_identifier,
      reply->patterns[inx0].paragraphs[par_idx].display = part.display, reply->patterns[inx0].
      paragraphs[par_idx].description = part.description, reply->patterns[inx0].paragraphs[par_idx].
      text_format_rule_cd = part.text_format_rule_cd,
      reply->patterns[inx0].paragraphs[par_idx].canonical_pattern_id = part.canonical_pattern_id,
      reply->patterns[inx0].paragraphs[par_idx].sequence_number = par.sequence_number, reply->
      patterns[inx0].paragraphs[par_idx].default_cd = part.default_cd,
      reply->patterns[inx0].paragraphs[par_idx].master_sequence_number = part.sequence_number, reply
      ->patterns[inx0].paragraphs[par_idx].canonical_pat_cki_source = can_pat.cki_source, reply->
      patterns[inx0].paragraphs[par_idx].canonical_pat_cki_identifier = can_pat.cki_identifier
     ENDIF
    DETAIL
     IF (action.scr_action_id > 0)
      par_action_idx = (par_action_idx+ 1)
      IF (mod(par_action_idx,5)=1)
       stat = alterlist(reply->patterns[inx0].paragraphs[par_idx].paragraph_actions,(par_action_idx+
        4))
      ENDIF
      reply->patterns[inx0].paragraphs[par_idx].paragraph_actions[par_action_idx].scr_action_id =
      action.scr_action_id, reply->patterns[inx0].paragraphs[par_idx].paragraph_actions[
      par_action_idx].scr_action_cd = action.scr_action_cd, reply->patterns[inx0].paragraphs[par_idx]
      .paragraph_actions[par_action_idx].scr_action_mean = uar_get_code_meaning(action.scr_action_cd)
     ENDIF
    FOOT  par.scr_paragraph_id
     stat = alterlist(reply->patterns[inx0].paragraphs[par_idx].paragraph_actions,par_action_idx),
     par_action_idx = 0
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_select,cps_script_fail,"No pattern Found",cps_select_msg,0,
     0,0)
    RETURN
   ENDIF
   SET stat = alterlist(reply->patterns[inx0].paragraphs,par_idx)
   SET stat = alterlist(reply->patterns[inx0].sentences,50)
   SET sent_idx = 0
   SELECT INTO "NL:"
    FROM scr_paragraph_type par,
     scr_pattern pat,
     scr_sentence sent
    WHERE (sent.scr_pattern_id=request->patterns[inx0].id)
     AND pat.scr_pattern_id=sent.canonical_sentence_pattern_id
     AND par.scr_paragraph_type_id=sent.scr_paragraph_type_id
    DETAIL
     sent_idx = (sent_idx+ 1)
     IF (mod(sent_idx,50)=0)
      stat = alterlist(reply->patterns[inx0].sentences,(sent_idx+ 50))
     ENDIF
     reply->patterns[inx0].sentences[sent_idx].scr_sentence_id = sent.scr_sentence_id, reply->
     patterns[inx0].sentences[sent_idx].scr_paragraph_type_id = sent.scr_paragraph_type_id, reply->
     patterns[inx0].sentences[sent_idx].canonical_sentence_pattern_id = sent
     .canonical_sentence_pattern_id,
     reply->patterns[inx0].sentences[sent_idx].sequence_number = sent.sequence_number, reply->
     patterns[inx0].sentences[sent_idx].sentence_topic_cd = sent.sentence_topic_cd, reply->patterns[
     inx0].sentences[sent_idx].text_format_rule_cd = sent.text_format_rule_cd,
     reply->patterns[inx0].sentences[sent_idx].recommended_cd = sent.recommended_cd, reply->patterns[
     inx0].sentences[sent_idx].default_cd = sent.default_cd, reply->patterns[inx0].sentences[sent_idx
     ].updt_dt_tm = sent.updt_dt_tm,
     reply->patterns[inx0].sentences[sent_idx].scr_ptype_cki_source = par.cki_source, reply->
     patterns[inx0].sentences[sent_idx].scr_ptype_cki_identifier = par.cki_identifier, reply->
     patterns[inx0].sentences[sent_idx].can_sent_pat_cki_source = pat.cki_source,
     reply->patterns[inx0].sentences[sent_idx].can_sent_pat_cki_identifier = pat.cki_identifier
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->patterns[inx0].sentences,sent_idx)
   SET stat = alterlist(reply->patterns[inx0].term_hier,5000)
   SET term_idx = 0
   SELECT INTO "nl:"
    FROM scr_term_definition def,
     scr_term_text text,
     scr_term_hier stid,
     scr_pattern stpat,
     scr_term_hier ptid,
     scr_term_hier ttid,
     scr_pattern tpat,
     scr_term term,
     scr_term_hier hier
    PLAN (hier
     WHERE (hier.scr_pattern_id=request->patterns[inx0].id))
     JOIN (term
     WHERE term.scr_term_id=hier.scr_term_id)
     JOIN (ttid
     WHERE ttid.scr_term_hier_id=outerjoin(term.scr_term_id))
     JOIN (tpat
     WHERE tpat.scr_pattern_id=outerjoin(ttid.scr_pattern_id))
     JOIN (ptid
     WHERE ptid.scr_term_hier_id=hier.parent_term_hier_id)
     JOIN (stid
     WHERE stid.scr_term_hier_id=outerjoin(hier.source_term_hier_id))
     JOIN (stpat
     WHERE stpat.scr_pattern_id=outerjoin(stid.scr_pattern_id))
     JOIN (text
     WHERE text.scr_term_id=hier.scr_term_id
      AND (text.language_cd=request->language_cd))
     JOIN (def
     WHERE def.scr_term_def_id=term.scr_term_def_id)
    ORDER BY hier.scr_term_hier_id
    HEAD hier.scr_term_hier_id
     term_idx = (term_idx+ 1)
     IF (mod(term_idx,5000)=0)
      stat = alterlist(reply->patterns[inx0].term_hier,(term_idx+ 5000))
     ENDIF
     term_def_idx = 0, stat = alterlist(reply->patterns[inx0].term_hier[term_idx].term_data,5), stat
      = alterlist(reply->patterns[inx0].term_hier[term_idx].term_language,1),
     reply->patterns[inx0].term_hier[term_idx].scr_term_hier_id = hier.scr_term_hier_id, reply->
     patterns[inx0].term_hier[term_idx].scr_term_id = term.scr_term_id, reply->patterns[inx0].
     term_hier[term_idx].parent_term_hier_id = hier.parent_term_hier_id,
     reply->patterns[inx0].term_hier[term_idx].scr_sentence_id = hier.scr_sentence_id, reply->
     patterns[inx0].term_hier[term_idx].sequence_number = hier.sequence_number, reply->patterns[inx0]
     .term_hier[term_idx].recommended_cd = hier.recommended_cd,
     reply->patterns[inx0].term_hier[term_idx].dependency_group = hier.dependency_group, reply->
     patterns[inx0].term_hier[term_idx].dependency_cd = hier.dependency_cd, reply->patterns[inx0].
     term_hier[term_idx].default_cd = hier.default_cd,
     reply->patterns[inx0].term_hier[term_idx].source_term_hier_id = hier.source_term_hier_id, reply
     ->patterns[inx0].term_hier[term_idx].cki_source = hier.cki_source, reply->patterns[inx0].
     term_hier[term_idx].cki_identifier = hier.cki_identifier,
     reply->patterns[inx0].term_hier[term_idx].concept_identifier = term.concept_identifier, reply->
     patterns[inx0].term_hier[term_idx].concept_source_cd = term.concept_source_cd, reply->patterns[
     inx0].term_hier[term_idx].concept_cki = term.concept_cki,
     reply->patterns[inx0].term_hier[term_idx].eligibility_check_cd = term.eligibility_check_cd,
     reply->patterns[inx0].term_hier[term_idx].visible_cd = term.visible_cd, reply->patterns[inx0].
     term_hier[term_idx].oldest_age = term.oldest_age,
     reply->patterns[inx0].term_hier[term_idx].repeat_cd = term.repeat_cd, reply->patterns[inx0].
     term_hier[term_idx].restrict_to_sex = term.restrict_to_sex, reply->patterns[inx0].term_hier[
     term_idx].state_logic_cd = term.state_logic_cd,
     reply->patterns[inx0].term_hier[term_idx].store_cd = term.store_cd, reply->patterns[inx0].
     term_hier[term_idx].term_type_cd = term.term_type_cd, reply->patterns[inx0].term_hier[term_idx].
     youngest_age = term.youngest_age,
     reply->patterns[inx0].term_hier[term_idx].hier_concept_cki = hier.concept_cki, reply->patterns[
     inx0].term_hier[term_idx].definition = text.definition, reply->patterns[inx0].term_hier[term_idx
     ].display = text.display,
     reply->patterns[inx0].term_hier[term_idx].external_reference_info = text.external_reference_info,
     reply->patterns[inx0].term_hier[term_idx].text_format_rule_cd = text.text_format_rule_cd, reply
     ->patterns[inx0].term_hier[term_idx].text_negation_rule_cd = text.text_negation_rule_cd,
     reply->patterns[inx0].term_hier[term_idx].text_representation = text.text_representation, reply
     ->patterns[inx0].term_hier[term_idx].term_language[1].language_cd = text.language_cd, reply->
     patterns[inx0].term_hier[term_idx].term_language[1].definition = text.definition,
     reply->patterns[inx0].term_hier[term_idx].term_language[1].display = text.display, reply->
     patterns[inx0].term_hier[term_idx].term_language[1].external_reference_info = text
     .external_reference_info, reply->patterns[inx0].term_hier[term_idx].term_language[1].
     text_format_rule_cd = text.text_format_rule_cd,
     reply->patterns[inx0].term_hier[term_idx].term_language[1].text_negation_rule_cd = text
     .text_negation_rule_cd, reply->patterns[inx0].term_hier[term_idx].term_language[1].
     text_representation = text.text_representation, reply->patterns[inx0].term_hier[term_idx].
     scr_term_cki_source = ttid.cki_source,
     reply->patterns[inx0].term_hier[term_idx].scr_term_cki_identifier = ttid.cki_identifier, reply->
     patterns[inx0].term_hier[term_idx].scr_term_pattern_cki_source = tpat.cki_source, reply->
     patterns[inx0].term_hier[term_idx].scr_term_pattern_cki_identifier = tpat.cki_identifier,
     reply->patterns[inx0].term_hier[term_idx].parent_term_hier_cki_source = ptid.cki_source, reply->
     patterns[inx0].term_hier[term_idx].parent_term_hier_cki_identifier = ptid.cki_identifier, reply
     ->patterns[inx0].term_hier[term_idx].source_term_hier_cki_source = stid.cki_source,
     reply->patterns[inx0].term_hier[term_idx].source_term_hier_cki_identifier = stid.cki_identifier,
     reply->patterns[inx0].term_hier[term_idx].source_pattern_cki_source = stpat.cki_source, reply->
     patterns[inx0].term_hier[term_idx].source_pattern_cki_identifier = stpat.cki_identifier
    DETAIL
     IF (def.scr_term_def_id != 0)
      term_def_idx = (term_def_idx+ 1)
      IF (mod(term_def_idx,5)=0)
       stat = alterlist(reply->patterns[inx0].term_hier[term_idx].term_data,(term_def_idx+ 5))
      ENDIF
      reply->patterns[inx0].term_hier[term_idx].term_data[term_def_idx].scr_term_def_type_cd = def
      .scr_term_def_type_cd, reply->patterns[inx0].term_hier[term_idx].term_data[term_def_idx].
      scr_term_def_key = def.scr_term_def_key, reply->patterns[inx0].term_hier[term_idx].term_data[
      term_def_idx].fkey_id = def.fkey_id,
      reply->patterns[inx0].term_hier[term_idx].term_data[term_def_idx].fkey_entity_name = def
      .fkey_entity_name, reply->patterns[inx0].term_hier[term_idx].term_data[term_def_idx].def_text
       = def.def_text
     ENDIF
    FOOT  hier.scr_term_hier_id
     stat = alterlist(reply->patterns[inx0].term_hier[term_idx].term_data,term_def_idx)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->patterns[inx0].term_hier,term_idx)
   IF (term_idx > 0)
    SET term_action_idx = 0
    SELECT INTO "NL:"
     FROM scr_action action,
      expression expr,
      expression_comp comp,
      scr_term_hier hier_target,
      scr_term_hier hier_comp,
      (dummyt d  WITH seq = value(term_idx))
     PLAN (d)
      JOIN (action
      WHERE action.parent_entity_name="SCR_TERM_HIER"
       AND (action.parent_entity_id=reply->patterns[inx0].term_hier[d.seq].scr_term_hier_id))
      JOIN (hier_target
      WHERE ((hier_target.scr_term_hier_id=0) OR ((hier_target.scr_pattern_id=request->patterns[inx0]
      .id)
       AND ((hier_target.scr_term_hier_id=action.target_entity_id) OR (action.target_entity_id != 0.0
       AND hier_target.source_term_hier_id=action.target_entity_id)) )) )
      JOIN (expr
      WHERE action.expression_id=expr.expression_id)
      JOIN (comp
      WHERE comp.expression_id=expr.expression_id)
      JOIN (hier_comp
      WHERE ((hier_comp.scr_term_hier_id=0) OR ((hier_comp.scr_pattern_id=request->patterns[inx0].id)
       AND ((hier_comp.scr_term_hier_id=comp.value_fkey_id) OR (comp.value_fkey_id != 0.0
       AND hier_comp.source_term_hier_id=comp.value_fkey_id)) )) )
     ORDER BY action.parent_entity_id, action.scr_action_id, expr.expression_id,
      comp.expression_comp_id, hier_comp.source_term_hier_id
     HEAD action.parent_entity_id
      term_action_idx = 0, expr_comp_idx = 0
     DETAIL
      IF (((term_action_idx=0) OR ((reply->patterns[inx0].term_hier[d.seq].term_actions[
      term_action_idx].scr_action_id != action.scr_action_id))) )
       IF (expr_comp_idx > 0)
        stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
         expr_comps,expr_comp_idx)
       ENDIF
       term_action_idx = (term_action_idx+ 1), expr_comp_idx = 0
       IF (mod(term_action_idx,5)=1)
        stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_actions,(term_action_idx+ 5))
       ENDIF
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].target_cki_identifier =
       ""
      ENDIF
      reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].scr_action_id = action
      .scr_action_id, reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
      scr_action_cd = action.scr_action_cd, reply->patterns[inx0].term_hier[d.seq].term_actions[
      term_action_idx].scr_action_mean = uar_get_code_meaning(action.scr_action_cd),
      reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].target_entity_id = action
      .target_entity_id, reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
      target_entity_name = action.target_entity_name
      IF (action.target_entity_id > 0.0
       AND (reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
      target_cki_identifier=""))
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].target_cki_source =
       hier_target.cki_source, reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
       target_cki_identifier = hier_target.cki_identifier
      ENDIF
      reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_id = action
      .expression_id, reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
      expr_owner_ind = action.expression_owner_ind, reply->patterns[inx0].term_hier[d.seq].
      term_actions[term_action_idx].expr_cki = expr.expression_cki,
      reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_display = expr
      .expression_display
      IF (comp.expression_id > 0)
       IF (((expr_comp_idx=0) OR ((reply->patterns[inx0].term_hier[d.seq].term_actions[
       term_action_idx].expr_comps[expr_comp_idx].expr_comp_id != comp.expression_comp_id))) )
        expr_comp_idx = (expr_comp_idx+ 1)
        IF (mod(expr_comp_idx,5)=1)
         stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
          expr_comps,(expr_comp_idx+ 5))
        ENDIF
       ENDIF
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx]
       .expr_comp_id = comp.expression_comp_id, reply->patterns[inx0].term_hier[d.seq].term_actions[
       term_action_idx].expr_comps[expr_comp_idx].expr_comp_cd = comp.expression_comp_role_cd, reply
       ->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx].
       expr_comp_mean = uar_get_code_meaning(comp.expression_comp_role_cd),
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx]
       .expr_id = comp.expression_id, reply->patterns[inx0].term_hier[d.seq].term_actions[
       term_action_idx].expr_comps[expr_comp_idx].parent_expr_comp_id = comp
       .parent_expression_comp_id, reply->patterns[inx0].term_hier[d.seq].term_actions[
       term_action_idx].expr_comps[expr_comp_idx].sequence_number = comp.sequence_number,
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx]
       .units_cd = comp.units_cd, reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx
       ].expr_comps[expr_comp_idx].units_mean = uar_get_code_meaning(comp.units_cd), reply->patterns[
       inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx].value_dt_tm =
       comp.value_dt_tm,
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx]
       .value_fkey_entity_name = comp.value_fkey_entity_name, reply->patterns[inx0].term_hier[d.seq].
       term_actions[term_action_idx].expr_comps[expr_comp_idx].value_fkey_id = comp.value_fkey_id
       IF (comp.value_fkey_id > 0
        AND (reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[
       expr_comp_idx].value_fkey_cki_identifier=""))
        reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx
        ].value_fkey_cki_source = hier_comp.cki_source, reply->patterns[inx0].term_hier[d.seq].
        term_actions[term_action_idx].expr_comps[expr_comp_idx].value_fkey_cki_identifier = hier_comp
        .cki_identifier
       ENDIF
       reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].expr_comps[expr_comp_idx]
       .value_number = comp.value_number, reply->patterns[inx0].term_hier[d.seq].term_actions[
       term_action_idx].expr_comps[expr_comp_idx].value_text = comp.value_text
      ENDIF
     FOOT  action.parent_entity_id
      stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_actions,term_action_idx)
      IF (expr_comp_idx > 0)
       stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_actions[term_action_idx].
        expr_comps,expr_comp_idx)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 CALL echorecord(reply)
END GO
