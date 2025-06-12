CREATE PROGRAM cps_get_scd_patrn_export:dba
 SET num_pars = size(reply->patterns[inx0].paragraphs,5)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(num_pars)),
   scr_pattern cki_pat
  PLAN (d)
   JOIN (cki_pat
   WHERE (reply->patterns[inx0].paragraphs[d.seq].canonical_pattern_id=cki_pat.scr_pattern_id))
  DETAIL
   reply->patterns[inx0].paragraphs[d.seq].canonical_pat_cki_source = cki_pat.cki_source, reply->
   patterns[inx0].paragraphs[d.seq].canonical_pat_cki_identifier = cki_pat.cki_identifier
  WITH nocounter
 ;end select
 SET num_sentences = size(reply->patterns[inx0].sentences,5)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(num_sentences)),
   scr_paragraph_type cki_par,
   scr_pattern cki_pat
  PLAN (d)
   JOIN (((cki_pat
   WHERE (reply->patterns[inx0].sentences[d.seq].canonical_sentence_pattern_id=cki_pat.scr_pattern_id
   ))
   ) ORJOIN ((cki_par
   WHERE (reply->patterns[inx0].sentences[d.seq].scr_paragraph_type_id=cki_par.scr_paragraph_type_id)
   )
   ))
  DETAIL
   reply->patterns[inx0].sentences[d.seq].scr_ptype_cki_source = cki_par.cki_source, reply->patterns[
   inx0].sentences[d.seq].scr_ptype_cki_identifier = cki_par.cki_identifier, reply->patterns[inx0].
   sentences[d.seq].can_sent_pat_cki_source = cki_pat.cki_source,
   reply->patterns[inx0].sentences[d.seq].can_sent_pat_cki_identifier = cki_pat.cki_identifier
  WITH nocounter
 ;end select
 SET num_terms = size(reply->patterns[inx0].term_hier,5)
 SELECT INTO "NL:"
  d.seq
  FROM (dummyt d  WITH seq = value(num_terms)),
   scr_term_hier tid,
   scr_term_hier ptid,
   scr_term_hier stid,
   scr_term_text tt
  PLAN (d)
   JOIN (tid
   WHERE (tid.scr_term_hier_id=reply->patterns[inx0].term_hier[d.seq].scr_term_id))
   JOIN (ptid
   WHERE (ptid.scr_term_hier_id=reply->patterns[inx0].term_hier[d.seq].parent_term_hier_id))
   JOIN (stid
   WHERE (stid.scr_term_hier_id=reply->patterns[inx0].term_hier[d.seq].source_term_hier_id))
   JOIN (tt
   WHERE (tt.scr_term_id=reply->patterns[inx0].term_hier[d.seq].scr_term_id)
    AND (tt.language_cd != request->language_cd))
  HEAD d.seq
   reply->patterns[inx0].term_hier[d.seq].scr_term_cki_source = tid.cki_source, reply->patterns[inx0]
   .term_hier[d.seq].scr_term_cki_identifier = tid.cki_identifier
   IF ((reply->patterns[inx0].term_hier[d.seq].parent_term_hier_id != 0.0))
    reply->patterns[inx0].term_hier[d.seq].parent_term_hier_cki_source = ptid.cki_source, reply->
    patterns[inx0].term_hier[d.seq].parent_term_hier_cki_identifier = ptid.cki_identifier
   ENDIF
   IF ((reply->patterns[inx0].term_hier[d.seq].source_term_hier_id != 0.0))
    reply->patterns[inx0].term_hier[d.seq].source_term_hier_cki_source = stid.cki_source, reply->
    patterns[inx0].term_hier[d.seq].source_term_hier_cki_identifier = stid.cki_identifier
   ENDIF
   tt_idx = 0, stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_language,5)
  DETAIL
   tt_idx = (tt_idx+ 1)
   IF (mod(tt_idx,5)=0)
    stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_language,(tt_idx+ 5))
   ENDIF
   IF (tt_idx=1)
    reply->patterns[inx0].term_hier[d.seq].term_language[tt_idx].definition = tt.definition, reply->
    patterns[inx0].term_hier[d.seq].term_language[tt_idx].display = tt.display, reply->patterns[inx0]
    .term_hier[d.seq].term_language[tt_idx].external_reference_info = tt.external_reference_info,
    reply->patterns[inx0].term_hier[d.seq].term_language[tt_idx].text_format_rule_cd = tt
    .text_format_rule_cd, reply->patterns[inx0].term_hier[d.seq].term_language[tt_idx].
    text_negation_rule_cd = tt.text_negation_rule_cd, reply->patterns[inx0].term_hier[d.seq].
    term_language[tt_idx].text_representation = tt.text_representation
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->patterns[inx0].term_hier[d.seq].term_language,tt_idx)
  WITH nocounter
 ;end select
END GO
