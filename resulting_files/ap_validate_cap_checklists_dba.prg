CREATE PROGRAM ap_validate_cap_checklists:dba
 RECORD reply(
   1 checklists[*]
     2 cap_concept_cki = vc
     2 question_answer_pair_cnt = i4
     2 answers_without_questions_cnt = i4
     2 negated_terms_cnt = i4
     2 patterns[*]
       3 scr_pattern_id = f8
   1 patterns[*]
     2 scr_pattern_id = f8
     2 pattern_cki_source = c12
     2 pattern_cki_identifier = vc
     2 pattern_display = c40
     2 pattern_description = vc
     2 question_answer_pair[*]
       3 scr_term_id = f8
       3 term_display = vc
       3 term_defintion = vc
       3 answer_concept_cki = vc
       3 question_concept_cki = vc
       3 is_data_term = i2
     2 answer_without_question[*]
       3 scr_term_id = f8
       3 term_display = vc
       3 term_defintion = vc
       3 answer_concept_cki = vc
       3 is_data_term = i2
     2 negatable_terms[*]
       3 scr_term_id = f8
       3 term_display = vc
       3 term_defintion = vc
       3 negation_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD terms(
   1 qual[*]
     2 scr_pattern_id = f8
     2 terms[*]
       3 scr_term_hier_id = f8
       3 parent_term_hier_id = f8
       3 scr_term_id = f8
       3 concept_cki = vc
       3 scr_term_def_id = f8
       3 question_concept = vc
       3 term_display = vc
       3 term_defintion = vc
       3 text_negation_cd = f8
       3 is_data_term = i2
 )
 RECORD temp_patterns(
   1 patterns[*]
     2 scr_pattern_id = f8
     2 question_answer_pair_cnt = i4
     2 answers_without_questions_cnt = i4
     2 negated_terms_cnt = i4
 )
 DECLARE fillreplypatterninfo(pattern_idx=i4) = null WITH protect
 DECLARE retrievepatternterminfo(pattern_idx=i4) = null WITH protect
 DECLARE determinewhetherquestiontermisleaf(term_id=f8,pattern_idx=i4) = i2 WITH protect
 DECLARE num_patterns = i4 WITH protect, noconstant(0)
 DECLARE pattern_idx = i4 WITH protect, noconstant(0)
 DECLARE num_checklists = i4 WITH protect, noconstant(0)
 DECLARE checklists_idx = i4 WITH protect, noconstant(0)
 DECLARE pattern_counter = i4 WITH protect, noconstant(0)
 DECLARE pattern_loc = i4 WITH protect, noconstant(0)
 DECLARE patt_cnt = i4 WITH protect, noconstant(0)
 DECLARE term_idx = i4 WITH protect, noconstant(0)
 DECLARE deppatterntypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dscddatatermtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE ques_ans_pair_counter = i4 WITH protect, noconstant(0)
 DECLARE answer_counter = i4 WITH protect, noconstant(0)
 DECLARE negatable_counter = i4 WITH protect, noconstant(0)
 DECLARE failed = i4 WITH protect, noconstant(0)
 DECLARE dcapecc_cd = f8 WITH protect, noconstant(0.0)
 SET dcapecc_cd = uar_get_code_by("MEANING",12100,"CAP_ECC")
 SET stat = uar_get_meaning_by_codeset(14409,"EP",1,deppatterntypecd)
 SET stat = uar_get_meaning_by_codeset(14413,"DATA",1,dscddatatermtypecd)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  sp.scr_pattern_id
  FROM scr_pattern_concept sp,
   cmt_concept c
  PLAN (sp
   WHERE sp.concept_source_cd=dcapecc_cd)
   JOIN (c
   WHERE c.concept_cki=sp.concept_cki)
  ORDER BY sp.scr_pattern_id, sp.concept_cki
  HEAD REPORT
   cnt = 0
  HEAD sp.scr_pattern_id
   cnt = (cnt+ 1), stat = alterlist(temp_patterns->patterns,cnt), temp_patterns->patterns[cnt].
   scr_pattern_id = sp.scr_pattern_id
  WITH nocounter
 ;end select
 SET num_patterns = size(temp_patterns->patterns,5)
 SET stat = alterlist(terms->qual,num_patterns)
 SET stat = alterlist(reply->patterns,num_patterns)
 FOR (pattern_idx = 1 TO num_patterns)
  CALL fillreplypatterninfo(pattern_idx)
  CALL retrievepatternterminfo(pattern_idx)
 ENDFOR
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "AP_VALIDATE_CAP_CHECKLISTS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No patterns found."
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 SELECT INTO "nl:"
  sp.scr_pattern_id
  FROM scr_pattern_concept sp,
   cmt_concept c
  PLAN (sp
   WHERE sp.concept_source_cd=dcapecc_cd)
   JOIN (c
   WHERE c.concept_cki=sp.concept_cki)
  ORDER BY sp.concept_cki, sp.scr_pattern_id
  HEAD REPORT
   cnt1 = 0
  HEAD sp.concept_cki
   cnt1 = (cnt1+ 1), stat = alterlist(reply->checklists,cnt1), reply->checklists[cnt1].
   cap_concept_cki = sp.concept_cki,
   cnt2 = 0
  DETAIL
   cnt2 = (cnt2+ 1), stat = alterlist(reply->checklists[cnt1].patterns,cnt2), reply->checklists[cnt1]
   .patterns[cnt2].scr_pattern_id = sp.scr_pattern_id
  WITH nocounter
 ;end select
 FOR (pattern_idx = 1 TO num_patterns)
   SET ques_ans_pair_counter = 0
   SET answer_counter = 0
   SET negatable_counter = 0
   SET num_terms = size(terms->qual[pattern_idx].terms,5)
   FOR (term_idx = 1 TO num_terms)
     IF ((terms->qual[pattern_idx].terms[term_idx].text_negation_cd != 0.0))
      SET negatable_counter = (negatable_counter+ 1)
      SET stat = alterlist(reply->patterns[pattern_idx].negatable_terms,negatable_counter)
      SET reply->patterns[pattern_idx].negatable_terms[negatable_counter].scr_term_id = terms->qual[
      pattern_idx].terms[term_idx].scr_term_id
      SET reply->patterns[pattern_idx].negatable_terms[negatable_counter].term_display = terms->qual[
      pattern_idx].terms[term_idx].term_display
      SET reply->patterns[pattern_idx].negatable_terms[negatable_counter].term_defintion = terms->
      qual[pattern_idx].terms[term_idx].term_defintion
      SET reply->patterns[pattern_idx].negatable_terms[negatable_counter].negation_text =
      uar_get_code_display(terms->qual[pattern_idx].terms[term_idx].text_negation_cd)
     ELSE
      IF ((terms->qual[pattern_idx].terms[term_idx].concept_cki != ""))
       IF ((terms->qual[pattern_idx].terms[term_idx].question_concept != ""))
        SET ques_ans_pair_counter = (ques_ans_pair_counter+ 1)
        SET stat = alterlist(reply->patterns[pattern_idx].question_answer_pair,ques_ans_pair_counter)
        SET reply->patterns[pattern_idx].question_answer_pair[ques_ans_pair_counter].scr_term_id =
        terms->qual[pattern_idx].terms[term_idx].scr_term_id
        SET reply->patterns[pattern_idx].question_answer_pair[ques_ans_pair_counter].term_display =
        terms->qual[pattern_idx].terms[term_idx].term_display
        SET reply->patterns[pattern_idx].question_answer_pair[ques_ans_pair_counter].term_defintion
         = terms->qual[pattern_idx].terms[term_idx].term_defintion
        SET reply->patterns[pattern_idx].question_answer_pair[ques_ans_pair_counter].
        answer_concept_cki = terms->qual[pattern_idx].terms[term_idx].concept_cki
        SET reply->patterns[pattern_idx].question_answer_pair[ques_ans_pair_counter].
        question_concept_cki = terms->qual[pattern_idx].terms[term_idx].question_concept
        SET reply->patterns[pattern_idx].question_answer_pair[ques_ans_pair_counter].is_data_term =
        terms->qual[pattern_idx].terms[term_idx].is_data_term
       ELSE
        SET answer_counter = (answer_counter+ 1)
        SET stat = alterlist(reply->patterns[pattern_idx].answer_without_question,answer_counter)
        SET reply->patterns[pattern_idx].answer_without_question[answer_counter].scr_term_id = terms
        ->qual[pattern_idx].terms[term_idx].scr_term_id
        SET reply->patterns[pattern_idx].answer_without_question[answer_counter].term_display = terms
        ->qual[pattern_idx].terms[term_idx].term_display
        SET reply->patterns[pattern_idx].answer_without_question[answer_counter].term_defintion =
        terms->qual[pattern_idx].terms[term_idx].term_defintion
        SET reply->patterns[pattern_idx].answer_without_question[answer_counter].answer_concept_cki
         = terms->qual[pattern_idx].terms[term_idx].concept_cki
        SET reply->patterns[pattern_idx].answer_without_question[answer_counter].is_data_term = terms
        ->qual[pattern_idx].terms[term_idx].is_data_term
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF ((reply->patterns[pattern_idx].scr_pattern_id=temp_patterns->patterns[pattern_idx].
   scr_pattern_id))
    SET temp_patterns->patterns[pattern_idx].answers_without_questions_cnt = answer_counter
    SET temp_patterns->patterns[pattern_idx].question_answer_pair_cnt = ques_ans_pair_counter
    SET temp_patterns->patterns[pattern_idx].negated_terms_cnt = negatable_counter
   ENDIF
 ENDFOR
 SET num_checklists = size(reply->checklists,5)
 FOR (checklists_idx = 1 TO num_checklists)
   SET ques_ans_pair_counter = 0
   SET answer_counter = 0
   SET negatable_counter = 0
   SET patt_cnt = size(reply->checklists[checklists_idx].patterns,5)
   FOR (pattern_counter = 1 TO patt_cnt)
    SET pattern_loc = locateval(pattern_idx,1,num_patterns,reply->checklists[checklists_idx].
     patterns[pattern_counter].scr_pattern_id,temp_patterns->patterns[pattern_idx].scr_pattern_id)
    IF (pattern_loc > 0)
     SET ques_ans_pair_counter = (ques_ans_pair_counter+ temp_patterns->patterns[pattern_loc].
     question_answer_pair_cnt)
     SET answer_counter = (answer_counter+ temp_patterns->patterns[pattern_loc].
     answers_without_questions_cnt)
     SET negatable_counter = (negatable_counter+ temp_patterns->patterns[pattern_loc].
     negated_terms_cnt)
    ENDIF
   ENDFOR
   SET reply->checklists[checklists_idx].answers_without_questions_cnt = answer_counter
   SET reply->checklists[checklists_idx].question_answer_pair_cnt = ques_ans_pair_counter
   SET reply->checklists[checklists_idx].negated_terms_cnt = negatable_counter
 ENDFOR
 SUBROUTINE fillreplypatterninfo(pattern_idx)
   SET reply->patterns[pattern_idx].scr_pattern_id = temp_patterns->patterns[pattern_idx].
   scr_pattern_id
   SELECT INTO "NL:"
    FROM scr_pattern scrp
    WHERE (scrp.scr_pattern_id=temp_patterns->patterns[pattern_idx].scr_pattern_id)
     AND scrp.pattern_type_cd=deppatterntypecd
    DETAIL
     reply->patterns[pattern_idx].pattern_cki_source = scrp.cki_source, reply->patterns[pattern_idx].
     pattern_cki_identifier = scrp.cki_identifier, reply->patterns[pattern_idx].pattern_display =
     scrp.display,
     reply->patterns[pattern_idx].pattern_description = scrp.definition
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE retrievepatternterminfo(pattern_idx)
  DECLARE term_idx = i4 WITH protect, noconstant(0)
  SELECT INTO "NL:"
   FROM scr_term_hier scrth,
    scr_term scrt,
    scr_term_text scrtt,
    cmt_concept_reltn ccr
   PLAN (scrth
    WHERE (scrth.scr_pattern_id=temp_patterns->patterns[pattern_idx].scr_pattern_id))
    JOIN (scrt
    WHERE scrt.scr_term_id=scrth.scr_term_id
     AND scrt.concept_cki="CAP_ECC*")
    JOIN (scrtt
    WHERE scrtt.scr_term_id=scrt.scr_term_id)
    JOIN (ccr
    WHERE ccr.concept_cki1=outerjoin(scrt.concept_cki)
     AND ccr.relation_cki=outerjoin("CAP_ECC!ABE1269E-363C-47D0-B50D-C59D72CA3BC4"))
   ORDER BY scrt.scr_term_id, scrth.parent_term_hier_id, scrth.scr_term_hier_id
   HEAD REPORT
    term_idx = 0, terms->qual[pattern_idx].scr_pattern_id = temp_patterns->patterns[pattern_idx].
    scr_pattern_id
   DETAIL
    term_idx = (term_idx+ 1)
    IF (mod(term_idx,10)=1)
     stat = alterlist(terms->qual[pattern_idx].terms,(term_idx+ 9))
    ENDIF
    terms->qual[pattern_idx].terms[term_idx].scr_term_hier_id = scrth.scr_term_hier_id, terms->qual[
    pattern_idx].terms[term_idx].parent_term_hier_id = scrth.parent_term_hier_id, terms->qual[
    pattern_idx].terms[term_idx].scr_term_id = scrt.scr_term_id,
    terms->qual[pattern_idx].terms[term_idx].concept_cki = scrt.concept_cki, terms->qual[pattern_idx]
    .terms[term_idx].scr_term_def_id = scrt.scr_term_def_id, terms->qual[pattern_idx].terms[term_idx]
    .question_concept = ccr.concept_cki2,
    terms->qual[pattern_idx].terms[term_idx].term_display = scrtt.display, terms->qual[pattern_idx].
    terms[term_idx].term_defintion = scrtt.definition, terms->qual[pattern_idx].terms[term_idx].
    text_negation_cd = scrtt.text_negation_rule_cd
    IF (scrt.term_type_cd=dscddatatermtypecd)
     terms->qual[pattern_idx].terms[term_idx].is_data_term = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(terms->qual[pattern_idx].terms,term_idx)
   WITH nocounter
  ;end select
 END ;Subroutine
#exit_script
 CALL echorecord(reply)
END GO
