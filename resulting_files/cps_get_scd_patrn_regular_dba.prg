CREATE PROGRAM cps_get_scd_patrn_regular:dba
 SET par_idx = 0
 SELECT INTO "NL:"
  pattern_id = pat.scr_pattern_id"###########################"
  FROM scr_paragraph_type part,
   scr_paragraph par,
   scr_pattern pat
  WHERE (pat.scr_pattern_id=request->patterns[inx0].id)
   AND par.scr_pattern_id=pat.scr_pattern_id
   AND part.scr_paragraph_type_id=par.scr_paragraph_type_id
  HEAD pattern_id
   stat = alterlist(reply->patterns[inx0].paragraphs,10), reply->patterns[inx0].scr_pattern_id = pat
   .scr_pattern_id, reply->patterns[inx0].pattern_type_cd = pat.pattern_type_cd,
   reply->patterns[inx0].display = pat.display, reply->patterns[inx0].definition = pat.definition
  DETAIL
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
    reply->patterns[inx0].paragraphs[par_idx].canonical_pattern_id = part.canonical_pattern_id, reply
    ->patterns[inx0].paragraphs[par_idx].sequence_number = part.sequence_number, reply->patterns[inx0
    ].paragraphs[par_idx].default_cd = part.default_cd,
    reply->patterns[inx0].paragraphs[par_idx].master_sequence_number = par.sequence_number
   ENDIF
  WITH nocounter
 ;end select
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
   reply->patterns[inx0].sentences[sent_idx].scr_sentence_id = sent.scr_sentence_id, reply->patterns[
   inx0].sentences[sent_idx].scr_paragraph_type_id = sent.scr_paragraph_type_id, reply->patterns[inx0
   ].sentences[sent_idx].canonical_sentence_pattern_id = sent.canonical_sentence_pattern_id,
   reply->patterns[inx0].sentences[sent_idx].sequence_number = sent.sequence_number, reply->patterns[
   inx0].sentences[sent_idx].sentence_topic_cd = sent.sentence_topic_cd, reply->patterns[inx0].
   sentences[sent_idx].text_format_rule_cd = sent.text_format_rule_cd,
   reply->patterns[inx0].sentences[sent_idx].recommended_cd = sent.recommended_cd, reply->patterns[
   inx0].sentences[sent_idx].default_cd = sent.default_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->patterns[inx0].sentences,sent_idx)
 SET stat = alterlist(reply->patterns[inx0].term_hier,1000)
 SET term_idx = 0
 SELECT INTO "NL:"
  term_id = term.scr_term_id"###########################"
  FROM scr_term_definition def,
   scr_term_text text,
   scr_term term,
   scr_term_hier hier
  WHERE (hier.scr_pattern_id=request->patterns[inx0].id)
   AND term.scr_term_id=hier.scr_term_id
   AND text.scr_term_id=term.scr_term_id
   AND (text.language_cd=request->language_cd)
   AND def.scr_term_def_id=term.scr_term_def_id
  HEAD term_id
   term_idx = (term_idx+ 1)
   IF (mod(term_idx,1000)=0)
    stat = alterlist(reply->patterns[inx0].term_hier,(term_idx+ 1000))
   ENDIF
   term_def_idx = 0, stat = alterlist(reply->patterns[inx0].term_hier[term_idx].term_data,5), reply->
   patterns[inx0].term_hier[term_idx].scr_term_hier_id = hier.scr_term_hier_id,
   reply->patterns[inx0].term_hier[term_idx].parent_term_hier_id = hier.parent_term_hier_id, reply->
   patterns[inx0].term_hier[term_idx].scr_sentence_id = hier.scr_sentence_id, reply->patterns[inx0].
   term_hier[term_idx].sequence_number = hier.sequence_number,
   reply->patterns[inx0].term_hier[term_idx].recommended_cd = hier.recommended_cd, reply->patterns[
   inx0].term_hier[term_idx].dependency_group = hier.dependency_group, reply->patterns[inx0].
   term_hier[term_idx].dependency_cd = hier.dependency_cd,
   reply->patterns[inx0].term_hier[term_idx].default_cd = hier.default_cd, reply->patterns[inx0].
   term_hier[term_idx].source_term_hier_id = hier.source_term_hier_id, reply->patterns[inx0].
   term_hier[term_idx].concept_identifier = term.concept_identifier,
   reply->patterns[inx0].term_hier[term_idx].concept_source_cd = term.concept_source_cd, reply->
   patterns[inx0].term_hier[term_idx].eligibility_check_cd = term.eligibility_check_cd, reply->
   patterns[inx0].term_hier[term_idx].visible_cd = term.visible_cd,
   reply->patterns[inx0].term_hier[term_idx].oldest_age = term.oldest_age, reply->patterns[inx0].
   term_hier[term_idx].repeat_cd = term.repeat_cd, reply->patterns[inx0].term_hier[term_idx].
   restrict_to_sex = term.restrict_to_sex,
   reply->patterns[inx0].term_hier[term_idx].state_logic_cd = term.state_logic_cd, reply->patterns[
   inx0].term_hier[term_idx].store_cd = term.store_cd, reply->patterns[inx0].term_hier[term_idx].
   term_type_cd = term.term_type_cd,
   reply->patterns[inx0].term_hier[term_idx].youngest_age = term.youngest_age, reply->patterns[inx0].
   term_hier[term_idx].scr_term_id = term.scr_term_id
   IF ((request->export_ind=0))
    reply->patterns[inx0].term_hier[term_idx].definition = text.definition, reply->patterns[inx0].
    term_hier[term_idx].display = text.display, reply->patterns[inx0].term_hier[term_idx].
    external_reference_info = text.external_reference_info,
    reply->patterns[inx0].term_hier[term_idx].text_format_rule_cd = text.text_format_rule_cd, reply->
    patterns[inx0].term_hier[term_idx].text_negation_rule_cd = text.text_negation_rule_cd, reply->
    patterns[inx0].term_hier[term_idx].text_representation = text.text_representation
   ENDIF
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
    .fkey_entity_name, reply->patterns[inx0].term_hier[term_idx].term_data[term_def_idx].def_text =
    def.def_text
   ENDIF
  FOOT  term_id
   stat = alterlist(reply->patterns[inx0].term_hier[term_idx].term_data,term_def_idx)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->patterns[inx0].term_hier,term_idx)
END GO
