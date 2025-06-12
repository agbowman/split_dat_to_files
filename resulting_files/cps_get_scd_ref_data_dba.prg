CREATE PROGRAM cps_get_scd_ref_data:dba
 IF (validate(reply,"0")="0")
  RECORD reply(
    1 notes[*]
      2 scd_story_id = f8
      2 scr_pattern_ids[*]
        3 scr_pattern_id = f8
        3 pattern_display = vc
        3 pattern_definition = vc
      2 paragraphs[*]
        3 scd_paragraph_id = f8
        3 scr_paragraph_type_id = f8
        3 scr_paragraph_display = vc
        3 scr_cki_source = vc
        3 scr_cki_id = vc
        3 scr_text_format_rule_cd = f8
        3 scr_canonical_pattern_id = f8
        3 scr_description = vc
      2 terms[*]
        3 scd_term_id = f8
        3 scr_term_id = f8
        3 modify_prsnl_id = f8
        3 scr_term_hier_id = f8
        3 parent_term_hier_id = f8
        3 recommended_cd = f8
        3 dependency_group = i4
        3 dependency_cd = f8
        3 default_cd = f8
        3 source_term_hier_id = f8
        3 cki_source = vc
        3 cki_identifier = vc
        3 eligibility_check_cd = f8
        3 visible_cd = f8
        3 oldest_age = f8
        3 repeat_cd = f8
        3 restrict_to_sex = c12
        3 state_logic_cd = f8
        3 store_cd = f8
        3 term_type_cd = f8
        3 youngest_age = f8
        3 definition = vc
        3 display = vc
        3 external_reference_info = vc
        3 text_format_rule_cd = f8
        3 text_negation_rule_cd = f8
        3 text_representation = vc
        3 modify_prsnl_name = vc
        3 scr_term_def_id = f8
        3 term_def_data[*]
          4 scr_term_def_type_cd = f8
          4 scr_term_def_key = vc
          4 fkey_id = f8
          4 fkey_entity_name = vc
          4 def_text = vc
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
 DECLARE fillscr_pattern_ids(index=i4) = null
 DECLARE fillparagraphs(index=i4) = null
 DECLARE fillterms(index=i4) = null
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE lb_idx = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH public, noconstant(0)
 DECLARE number_notes = i4 WITH protect, constant(size(request->notes,5))
 SET failed = 0
 SET reply->status_data.status = "F"
 IF (size(request->notes,5)=0)
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No NOTES specified",cps_insuf_data_msg,0,
   0,0)
  SET failed = 1
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->notes,number_notes)
 FOR (note_index = 1 TO number_notes)
   IF (size(request->notes[note_index].scr_pattern_ids,5) > 0)
    CALL fillscr_pattern_ids(note_index)
   ENDIF
   IF (size(request->notes[note_index].paragraphs,5) > 0)
    CALL fillparagraphs(note_index)
   ENDIF
   IF (size(request->notes[note_index].terms,5) > 0)
    CALL fillterms(note_index)
   ENDIF
 ENDFOR
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE fillscr_pattern_ids(index)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE localvalidx = i4 WITH protect, noconstant(0)
   DECLARE ntotal = i4 WITH protect, noconstant(0)
   DECLARE ntotal2 = i4 WITH protect, noconstant(0)
   DECLARE nsize = i4 WITH constant(10)
   DECLARE nstart = i4 WITH protect, noconstant(0)
   DECLARE num1 = i4 WITH protect, noconstant(0)
   SET ntotal2 = size(request->notes[index].scr_pattern_ids,5)
   SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
   SET stat = alterlist(reply->notes[index].scr_pattern_ids,ntotal)
   SET nstart = 1
   FOR (idx = 1 TO ntotal2)
     SET reply->notes[index].scr_pattern_ids[idx].scr_pattern_id = request->notes[index].
     scr_pattern_ids[idx].scr_pattern_id
   ENDFOR
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->notes[index].scr_pattern_ids[idx].scr_pattern_id = request->notes[index].
     scr_pattern_ids[ntotal2].scr_pattern_id
   ENDFOR
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     scr_pattern scrpat
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (scrpat
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),scrpat.scr_pattern_id,reply->notes[index].
      scr_pattern_ids[idx].scr_pattern_id))
    HEAD REPORT
     num1 = 0
    DETAIL
     locatevalidx = locateval(num1,1,ntotal2,scrpat.scr_pattern_id,reply->notes[index].
      scr_pattern_ids[num1].scr_pattern_id), reply->notes[index].scr_pattern_ids[locatevalidx].
     pattern_display = scrpat.display, reply->notes[index].scr_pattern_ids[locatevalidx].
     pattern_definition = scrpat.definition
    FOOT REPORT
     stat = alterlist(reply->notes[index].scr_pattern_ids,ntotal2)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE fillparagraphs(index)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE localvalidx = i4 WITH protect, noconstant(0)
   DECLARE ntotal = i4 WITH protect, noconstant(0)
   DECLARE ntotal2 = i4 WITH protect, noconstant(0)
   DECLARE nsize = i4 WITH constant(10)
   DECLARE nstart = i4 WITH protect, noconstant(0)
   DECLARE num1 = i4 WITH protect, noconstant(0)
   SET ntotal2 = size(request->notes[index].paragraphs,5)
   SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
   SET stat = alterlist(reply->notes[index].paragraphs,ntotal)
   SET nstart = 1
   FOR (idx = 1 TO ntotal2)
    SET reply->notes[index].paragraphs[idx].scr_paragraph_type_id = request->notes[index].paragraphs[
    idx].scr_paragraph_type_id
    SET reply->notes[index].paragraphs[idx].scd_paragraph_id = request->notes[index].paragraphs[idx].
    scd_paragraph_id
   ENDFOR
   FOR (idx = (ntotal2+ 1) TO ntotal)
    SET reply->notes[index].paragraphs[idx].scr_paragraph_type_id = request->notes[index].paragraphs[
    ntotal2].scr_paragraph_type_id
    SET reply->notes[index].paragraphs[idx].scd_paragraph_id = request->notes[index].paragraphs[
    ntotal2].scd_paragraph_id
   ENDFOR
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     scr_paragraph_type partype
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (partype
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),partype.scr_paragraph_type_id,reply->notes[index].
      paragraphs[idx].scr_paragraph_type_id))
    HEAD REPORT
     num1 = 0
    DETAIL
     locatevalidx = locateval(num1,1,ntotal2,partype.scr_paragraph_type_id,reply->notes[index].
      paragraphs[num1].scr_paragraph_type_id), reply->notes[index].paragraphs[locatevalidx].
     scr_paragraph_display = partype.display, reply->notes[index].paragraphs[locatevalidx].
     scr_cki_source = partype.cki_source,
     reply->notes[index].paragraphs[locatevalidx].scr_cki_id = partype.cki_identifier, reply->notes[
     index].paragraphs[locatevalidx].scr_text_format_rule_cd = partype.text_format_rule_cd, reply->
     notes[index].paragraphs[locatevalidx].scr_canonical_pattern_id = partype.canonical_pattern_id,
     reply->notes[index].paragraphs[locatevalidx].scr_description = partype.description
    FOOT REPORT
     stat = alterlist(reply->notes[index].paragraphs,ntotal2)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE fillterms(index)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE localvalidx = i4 WITH protect, noconstant(0)
   DECLARE ntotal = i4 WITH protect, noconstant(0)
   DECLARE ntotal2 = i4 WITH protect, noconstant(0)
   DECLARE nsize = i4 WITH constant(50)
   DECLARE nstart = i4 WITH constant(1)
   DECLARE num1 = i4 WITH protect, noconstant(0)
   DECLARE expand_cnt = i4 WITH protect, noconstant(0)
   DECLARE term_index = i4 WITH protect, noconstant(0)
   DECLARE def_qual_cnt = i4 WITH protect, noconstant(0)
   SET ntotal2 = size(request->notes[index].terms,5)
   SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
   SET stat = alterlist(reply->notes[index].terms,ntotal)
   FOR (idx = 1 TO ntotal2)
     SET reply->notes[index].terms[idx].scd_term_id = request->notes[index].terms[idx].scd_term_id
     SET reply->notes[index].terms[idx].scr_term_id = request->notes[index].terms[idx].scr_term_id
     SET reply->notes[index].terms[idx].modify_prsnl_id = request->notes[index].terms[idx].
     modify_prsnl_id
     SET reply->notes[index].terms[idx].scr_term_hier_id = request->notes[index].terms[idx].
     scr_term_hier_id
   ENDFOR
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->notes[index].terms[idx].scd_term_id = request->notes[index].terms[ntotal2].
     scd_term_id
     SET reply->notes[index].terms[idx].scr_term_id = request->notes[index].terms[ntotal2].
     scr_term_id
     SET reply->notes[index].terms[idx].modify_prsnl_id = request->notes[index].terms[ntotal2].
     modify_prsnl_id
     SET reply->notes[index].terms[idx].scr_term_hier_id = request->notes[index].terms[ntotal2].
     scr_term_hier_id
   ENDFOR
   RECORD flat_reply(
     1 def_qual[*]
       2 term_index = i4
       2 scr_term_def_id = f8
   )
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     prsnl p
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (p
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),p.person_id,reply->notes[index].terms[idx].
      modify_prsnl_id))
    HEAD REPORT
     num1 = 0
    DETAIL
     locatevalidx = locateval(num1,1,ntotal2,p.person_id,reply->notes[index].terms[num1].
      modify_prsnl_id)
     IF (locatevalidx > 0)
      WHILE (locatevalidx != 0)
       reply->notes[index].terms[locatevalidx].modify_prsnl_name = p.name_full_formatted,locatevalidx
        = locateval(num1,(locatevalidx+ 1),ntotal2,p.person_id,reply->notes[index].terms[num1].
        modify_prsnl_id)
      ENDWHILE
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     scr_term_hier hier
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (hier
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),hier.scr_term_hier_id,reply->notes[index].terms[
      idx].scr_term_hier_id))
    HEAD REPORT
     num1 = 0
    DETAIL
     locatevalidx = locateval(num1,1,ntotal2,hier.scr_term_hier_id,reply->notes[index].terms[num1].
      scr_term_hier_id)
     IF (locatevalidx > 0)
      WHILE (locatevalidx != 0)
        reply->notes[index].terms[locatevalidx].parent_term_hier_id = hier.parent_term_hier_id, reply
        ->notes[index].terms[locatevalidx].recommended_cd = hier.recommended_cd, reply->notes[index].
        terms[locatevalidx].dependency_group = hier.dependency_group,
        reply->notes[index].terms[locatevalidx].dependency_cd = hier.dependency_cd, reply->notes[
        index].terms[locatevalidx].default_cd = hier.default_cd, reply->notes[index].terms[
        locatevalidx].source_term_hier_id = hier.source_term_hier_id,
        reply->notes[index].terms[locatevalidx].cki_source = hier.cki_source, reply->notes[index].
        terms[locatevalidx].cki_identifier = hier.cki_identifier, locatevalidx = locateval(num1,(
         locatevalidx+ 1),ntotal2,hier.scr_term_hier_id,reply->notes[index].terms[num1].
         scr_term_hier_id)
      ENDWHILE
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     scr_term st,
     scr_term_text text
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (st
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),st.scr_term_id,reply->notes[index].terms[idx].
      scr_term_id))
     JOIN (text
     WHERE text.scr_term_id=st.scr_term_id)
    HEAD REPORT
     num1 = 0
    DETAIL
     locatevalidx = locateval(num1,1,ntotal2,st.scr_term_id,reply->notes[index].terms[num1].
      scr_term_id)
     IF (locatevalidx > 0)
      WHILE (locatevalidx != 0)
        reply->notes[index].terms[locatevalidx].eligibility_check_cd = st.eligibility_check_cd, reply
        ->notes[index].terms[locatevalidx].visible_cd = st.visible_cd, reply->notes[index].terms[
        locatevalidx].oldest_age = st.oldest_age,
        reply->notes[index].terms[locatevalidx].repeat_cd = st.repeat_cd, reply->notes[index].terms[
        locatevalidx].restrict_to_sex = st.restrict_to_sex, reply->notes[index].terms[locatevalidx].
        state_logic_cd = st.state_logic_cd,
        reply->notes[index].terms[locatevalidx].store_cd = st.store_cd, reply->notes[index].terms[
        locatevalidx].term_type_cd = st.term_type_cd, reply->notes[index].terms[locatevalidx].
        youngest_age = st.youngest_age,
        reply->notes[index].terms[locatevalidx].definition = text.definition, reply->notes[index].
        terms[locatevalidx].display = text.display, reply->notes[index].terms[locatevalidx].
        external_reference_info = text.external_reference_info,
        reply->notes[index].terms[locatevalidx].text_format_rule_cd = text.text_format_rule_cd, reply
        ->notes[index].terms[locatevalidx].text_negation_rule_cd = text.text_negation_rule_cd, reply
        ->notes[index].terms[locatevalidx].text_representation = text.text_representation,
        reply->notes[index].terms[locatevalidx].scr_term_def_id = st.scr_term_def_id
        IF (st.scr_term_def_id != 0)
         def_qual_cnt = (def_qual_cnt+ 1)
         IF (def_qual_cnt > size(flat_reply->def_qual,5))
          stat = alterlist(flat_reply->def_qual,(def_qual_cnt+ 10))
         ENDIF
         flat_reply->def_qual[def_qual_cnt].term_index = locatevalidx, flat_reply->def_qual[
         def_qual_cnt].scr_term_def_id = st.scr_term_def_id
        ENDIF
        locatevalidx = locateval(num1,(locatevalidx+ 1),ntotal2,st.scr_term_id,reply->notes[index].
         terms[num1].scr_term_id)
      ENDWHILE
     ENDIF
    FOOT REPORT
     IF (def_qual_cnt > 0)
      stat = alterlist(flat_reply->def_qual,def_qual_cnt)
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->notes[index].terms,ntotal2)
   IF (def_qual_cnt > 0)
    SET ntotal2 = size(flat_reply->def_qual,5)
    SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
    SET stat = alterlist(flat_reply->def_qual,ntotal)
    FOR (idx = (ntotal2+ 1) TO ntotal)
     SET flat_reply->def_qual[idx].term_index = flat_reply->def_qual[ntotal2].term_index
     SET flat_reply->def_qual[idx].scr_term_def_id = flat_reply->def_qual[ntotal2].scr_term_def_id
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
      scr_term_definition tf
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (tf
      WHERE expand(idx,nstart,(nstart+ (nsize - 1)),tf.scr_term_def_id,flat_reply->def_qual[idx].
       scr_term_def_id))
     ORDER BY tf.scr_term_def_id
     HEAD REPORT
      def_qual_index = 0
     HEAD tf.scr_term_def_id
      term_def_idx = 0
     DETAIL
      locatevalidx = locateval(def_qual_index,1,ntotal2,tf.scr_term_def_id,flat_reply->def_qual[
       def_qual_index].scr_term_def_id), term_def_idx = (term_def_idx+ 1)
      IF (locatevalidx > 0)
       WHILE (locatevalidx != 0)
         term_index = flat_reply->def_qual[locatevalidx].term_index, stat = alterlist(reply->notes[
          index].terms[term_index].term_def_data,term_def_idx), reply->notes[index].terms[term_index]
         .term_def_data[term_def_idx].scr_term_def_type_cd = tf.scr_term_def_type_cd,
         reply->notes[index].terms[term_index].term_def_data[term_def_idx].scr_term_def_key = tf
         .scr_term_def_key, reply->notes[index].terms[term_index].term_def_data[term_def_idx].fkey_id
          = tf.fkey_id, reply->notes[index].terms[term_index].term_def_data[term_def_idx].
         fkey_entity_name = tf.fkey_entity_name,
         reply->notes[index].terms[term_index].term_def_data[term_def_idx].def_text = tf.def_text,
         locatevalidx = locateval(def_qual_index,(locatevalidx+ 1),ntotal2,tf.scr_term_def_id,
          flat_reply->def_qual[def_qual_index].scr_term_def_id)
       ENDWHILE
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   FREE RECORD flat_reply
 END ;Subroutine
END GO
