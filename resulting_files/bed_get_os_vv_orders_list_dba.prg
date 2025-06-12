CREATE PROGRAM bed_get_os_vv_orders_list:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 description = vc
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 mnemonic_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 all_facilities_ind = i2
       3 facilities[*]
         4 code_value = f8
         4 display = vc
         4 description = vc
       3 sentences[*]
         4 id = f8
         4 display = vc
         4 usage_flag = i2
         4 sequence = i4
         4 all_facilities_ind = i2
         4 facilities[*]
           5 code_value = f8
           5 display = vc
           5 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 RECORD ordtemp(
   1 orderables[*]
     2 code_value = f8
     2 description = vc
     2 nbr_of_syns = i4
     2 ord_has_sentences = i2
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 mnemonic_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 all_facilities_ind = i2
       3 facilities[*]
         4 code_value = f8
         4 display = vc
         4 description = vc
       3 nbr_of_sents = i4
       3 sentences[*]
         4 id = f8
         4 display = vc
         4 usage_flag = i2
         4 sequence = i4
         4 all_facilities_ind = i2
         4 facilities[*]
           5 code_value = f8
           5 display = vc
           5 description = vc
         4 fac_exclude_ind = i2
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET max_cnt = 0
 SET max_cnt = request->max_reply
 DECLARE os_parse = vc
 SET os_parse = " os.order_sentence_id = ocsr.order_sentence_id"
 IF ((request->med_admin_only_ind=1)
  AND (request->prescription_only_ind=1))
  SET os_parse = build(os_parse," and os.usage_flag in (1,2)")
 ELSEIF ((request->med_admin_only_ind=1)
  AND (request->prescription_only_ind=0))
  SET os_parse = build(os_parse," and os.usage_flag = 1")
 ELSEIF ((request->med_admin_only_ind=0)
  AND (request->prescription_only_ind=1))
  SET os_parse = build(os_parse," and os.usage_flag = 2")
 ENDIF
 DECLARE ocs_parse = vc
 SET ocs_parse = " ocs.catalog_cd = oc.catalog_cd and ocs.active_ind = 1"
 IF ((request->mnemonic_type_code_value > 0))
  SET ocs_parse = build(ocs_parse," and ocs.mnemonic_type_cd = ",request->mnemonic_type_code_value)
 ENDIF
 IF ((request->oe_format_id > 0))
  SET ocs_parse = build(ocs_parse," and ocs.oe_format_id = ",request->oe_format_id)
 ENDIF
 DECLARE oc_parse = vc
 SET oc_parse =
 "oc.active_ind = 1 and oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2 and oc.catalog_cd > 0"
 IF ((request->catalog_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.catalog_type_cd = ",request->catalog_type_code_value)
 ENDIF
 IF ((request->activity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.activity_type_cd = ",request->activity_type_code_value)
 ENDIF
 IF ((request->subactivity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.activity_subtype_cd = ",request->subactivity_type_code_value
   )
 ENDIF
 IF ((request->search_string > " "))
  DECLARE search_string = vc
  IF ((request->search_type_flag="S"))
   SET search_string = build('"',trim(cnvtupper(request->search_string)),'*"')
  ELSE
   SET search_string = build('"*',trim(cnvtupper(request->search_string)),'*"')
  ENDIF
  IF ((request->search_field_ind=1))
   SET oc_parse = build(oc_parse," and cnvtupper(oc.description) = ",search_string)
  ELSE
   SET ocs_parse = build(ocs_parse," and cnvtupper(ocs.mnemonic) = ",search_string)
  ENDIF
 ENDIF
 SET max_syn_cnt = 0
 SET ocnt = 0
 SELECT INTO "NL:"
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   code_value cv,
   ocs_facility_r ofr,
   code_value cv1
  PLAN (oc
   WHERE parser(oc_parse))
   JOIN (ocs
   WHERE parser(ocs_parse))
   JOIN (cv
   WHERE cv.code_value=ocs.mnemonic_type_cd
    AND cv.active_ind=1)
   JOIN (ofr
   WHERE ofr.synonym_id=outerjoin(ocs.synonym_id))
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(ofr.facility_cd)
    AND cv1.active_ind=outerjoin(1))
  ORDER BY oc.description, ocs.mnemonic, oc.catalog_cd,
   ocs.synonym_id, ofr.facility_cd
  HEAD REPORT
   stat = alterlist(ordtemp->orderables,50), ocnt = 0, alterlist_ocnt = 0
  HEAD oc.catalog_cd
   ocnt = (ocnt+ 1), alterlist_ocnt = (alterlist_ocnt+ 1)
   IF (alterlist_ocnt > 50)
    stat = alterlist(ordtemp->orderables,(ocnt+ 50)), alterlist_ocnt = 1
   ENDIF
   ordtemp->orderables[ocnt].code_value = oc.catalog_cd, ordtemp->orderables[ocnt].description = oc
   .description, ordtemp->orderables[ocnt].nbr_of_syns = 0,
   ordtemp->orderables[ocnt].ord_has_sentences = 0, stat = alterlist(ordtemp->orderables[ocnt].
    synonyms,10), scnt = 0,
   alterlist_scnt = 0
  HEAD ocs.synonym_id
   scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
   IF (alterlist_scnt > 10)
    stat = alterlist(ordtemp->orderables[ocnt].synonyms,(scnt+ 10)), alterlist_scnt = 1
   ENDIF
   ordtemp->orderables[ocnt].synonyms[scnt].id = ocs.synonym_id, ordtemp->orderables[ocnt].synonyms[
   scnt].mnemonic = ocs.mnemonic, ordtemp->orderables[ocnt].synonyms[scnt].mnemonic_type.code_value
    = cv.code_value,
   ordtemp->orderables[ocnt].synonyms[scnt].mnemonic_type.display = cv.display, ordtemp->orderables[
   ocnt].synonyms[scnt].mnemonic_type.mean = cv.cdf_meaning, fcnt = 0
  HEAD ofr.facility_cd
   IF (ofr.facility_cd=0
    AND ofr.synonym_id > 0)
    ordtemp->orderables[ocnt].synonyms[scnt].all_facilities_ind = 1
   ELSEIF (ofr.facility_cd > 0)
    fcnt = (fcnt+ 1), stat = alterlist(ordtemp->orderables[ocnt].synonyms[scnt].facilities,fcnt),
    ordtemp->orderables[ocnt].synonyms[scnt].facilities[fcnt].code_value = cv1.code_value,
    ordtemp->orderables[ocnt].synonyms[scnt].facilities[fcnt].display = cv1.display, ordtemp->
    orderables[ocnt].synonyms[scnt].facilities[fcnt].description = cv1.description
   ENDIF
  FOOT  oc.catalog_cd
   stat = alterlist(ordtemp->orderables[ocnt].synonyms,scnt), ordtemp->orderables[ocnt].nbr_of_syns
    = scnt
   IF (scnt > max_syn_cnt)
    max_syn_cnt = scnt
   ENDIF
  FOOT REPORT
   stat = alterlist(ordtemp->orderables,ocnt)
  WITH nocounter
 ;end select
 SET total_sentences_in_reply = 0
 IF (ocnt > 0)
  IF ((request->facility_show_for=0)
   AND (request->facility_do_not_show_for=0))
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(ocnt)),
     (dummyt d2  WITH seq = value(max_syn_cnt)),
     ord_cat_sent_r ocsr,
     order_sentence os,
     filter_entity_reltn f,
     code_value cv
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(ordtemp->orderables[d1.seq].synonyms,5))
     JOIN (ocsr
     WHERE (ocsr.synonym_id=ordtemp->orderables[d1.seq].synonyms[d2.seq].id)
      AND ocsr.active_ind=1)
     JOIN (os
     WHERE parser(os_parse))
     JOIN (f
     WHERE f.parent_entity_name=outerjoin("ORDER_SENTENCE")
      AND f.parent_entity_id=outerjoin(os.order_sentence_id)
      AND f.filter_entity1_name=outerjoin("LOCATION"))
     JOIN (cv
     WHERE cv.code_value=outerjoin(f.filter_entity1_id)
      AND cv.active_ind=outerjoin(1))
    ORDER BY d1.seq, d2.seq, os.order_sentence_id,
     f.filter_entity_reltn_id
    HEAD d1.seq
     ocnt = ocnt
    HEAD d2.seq
     ordtemp->orderables[d1.seq].synonyms[d2.seq].nbr_of_sents = 0, sencnt = 0
    HEAD os.order_sentence_id
     sencnt = (sencnt+ 1), stat = alterlist(ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences,
      sencnt), ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].id = os
     .order_sentence_id,
     ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].display = os
     .order_sentence_display_line, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
     usage_flag = os.usage_flag, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
     sequence = ocsr.display_seq,
     ordtemp->orderables[d1.seq].ord_has_sentences = 1, ordtemp->orderables[d1.seq].synonyms[d2.seq].
     nbr_of_sents = sencnt, faccnt = 0
    HEAD f.filter_entity_reltn_id
     IF (f.filter_entity_reltn_id > 0)
      IF (f.filter_entity1_id=0)
       ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].all_facilities_ind = 1
      ELSEIF (cv.code_value > 0)
       faccnt = (faccnt+ 1), stat = alterlist(ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[
        sencnt].facilities,faccnt), ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
       facilities[faccnt].code_value = cv.code_value,
       ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].facilities[faccnt].display = cv
       .display, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].facilities[faccnt].
       description = cv.description
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
  ELSEIF ((request->facility_show_for > 0)
   AND (request->facility_do_not_show_for=0))
   IF ((request->facility_exclude_default_rows=1))
    SET fparse = build(" f.filter_entity1_id = ",request->facility_show_for)
   ELSE
    SET fparse = build(" (f.filter_entity1_id = 0 or f.filter_entity1_id = ",request->
     facility_show_for,")")
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(ocnt)),
     (dummyt d2  WITH seq = value(max_syn_cnt)),
     ord_cat_sent_r ocsr,
     order_sentence os,
     filter_entity_reltn f,
     code_value cv
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(ordtemp->orderables[d1.seq].synonyms,5))
     JOIN (ocsr
     WHERE (ocsr.synonym_id=ordtemp->orderables[d1.seq].synonyms[d2.seq].id)
      AND ocsr.active_ind=1)
     JOIN (os
     WHERE parser(os_parse))
     JOIN (f
     WHERE parser(fparse)
      AND f.parent_entity_name="ORDER_SENTENCE"
      AND f.parent_entity_id=os.order_sentence_id
      AND f.filter_entity1_name="LOCATION")
     JOIN (cv
     WHERE cv.code_value=outerjoin(f.filter_entity1_id)
      AND cv.active_ind=outerjoin(1))
    ORDER BY d1.seq, d2.seq, os.order_sentence_id,
     f.filter_entity_reltn_id
    HEAD d1.seq
     ocnt = ocnt
    HEAD d2.seq
     ordtemp->orderables[d1.seq].synonyms[d2.seq].nbr_of_sents = 0, sencnt = 0
    HEAD os.order_sentence_id
     sencnt = (sencnt+ 1), stat = alterlist(ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences,
      sencnt), ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].id = os
     .order_sentence_id,
     ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].display = os
     .order_sentence_display_line, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
     usage_flag = os.usage_flag, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
     sequence = ocsr.display_seq,
     ordtemp->orderables[d1.seq].ord_has_sentences = 1, ordtemp->orderables[d1.seq].synonyms[d2.seq].
     nbr_of_sents = sencnt, faccnt = 0
    HEAD f.filter_entity_reltn_id
     IF (f.filter_entity1_id=0)
      ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].all_facilities_ind = 1
     ELSEIF (cv.code_value > 0)
      faccnt = (faccnt+ 1), stat = alterlist(ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[
       sencnt].facilities,faccnt), ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
      facilities[faccnt].code_value = cv.code_value,
      ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].facilities[faccnt].display = cv
      .display, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].facilities[faccnt].
      description = cv.description
     ENDIF
    WITH nocounter
   ;end select
  ELSEIF ((request->facility_show_for=0)
   AND (request->facility_do_not_show_for > 0))
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(ocnt)),
     (dummyt d2  WITH seq = value(max_syn_cnt)),
     ord_cat_sent_r ocsr,
     order_sentence os,
     filter_entity_reltn f,
     code_value cv
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(ordtemp->orderables[d1.seq].synonyms,5))
     JOIN (ocsr
     WHERE (ocsr.synonym_id=ordtemp->orderables[d1.seq].synonyms[d2.seq].id)
      AND ocsr.active_ind=1)
     JOIN (os
     WHERE parser(os_parse))
     JOIN (f
     WHERE f.parent_entity_name="ORDER_SENTENCE"
      AND f.parent_entity_id=os.order_sentence_id
      AND f.filter_entity1_name="LOCATION"
      AND (f.filter_entity1_id != request->facility_do_not_show_for)
      AND f.filter_entity1_id != 0)
     JOIN (cv
     WHERE cv.code_value=outerjoin(f.filter_entity1_id)
      AND cv.active_ind=outerjoin(1))
    ORDER BY d1.seq, d2.seq, os.order_sentence_id,
     f.filter_entity_reltn_id
    HEAD d1.seq
     ocnt = ocnt
    HEAD d2.seq
     ordtemp->orderables[d1.seq].synonyms[d2.seq].nbr_of_sents = 0, sencnt = 0
    HEAD os.order_sentence_id
     sencnt = (sencnt+ 1), stat = alterlist(ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences,
      sencnt), ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].id = os
     .order_sentence_id,
     ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].display = os
     .order_sentence_display_line, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
     usage_flag = os.usage_flag, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
     sequence = ocsr.display_seq,
     ordtemp->orderables[d1.seq].ord_has_sentences = 1, ordtemp->orderables[d1.seq].synonyms[d2.seq].
     nbr_of_sents = sencnt, faccnt = 0
    HEAD f.filter_entity_reltn_id
     IF (f.filter_entity1_id=0)
      ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].all_facilities_ind = 1
     ELSEIF (cv.code_value > 0)
      faccnt = (faccnt+ 1), stat = alterlist(ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[
       sencnt].facilities,faccnt), ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
      facilities[faccnt].code_value = cv.code_value,
      ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].facilities[faccnt].display = cv
      .display, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].facilities[faccnt].
      description = cv.description
     ENDIF
    WITH nocounter
   ;end select
  ELSEIF ((request->facility_show_for > 0)
   AND (request->facility_do_not_show_for > 0))
   IF ((request->facility_exclude_default_rows=1))
    SET fparse = build(" f.filter_entity1_id = ",request->facility_show_for)
   ELSE
    SET fparse = build(" (f.filter_entity1_id = 0 or f.filter_entity1_id = ",request->
     facility_show_for,")")
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(ocnt)),
     (dummyt d2  WITH seq = value(max_syn_cnt)),
     ord_cat_sent_r ocsr,
     order_sentence os,
     filter_entity_reltn f,
     code_value cv
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(ordtemp->orderables[d1.seq].synonyms,5))
     JOIN (ocsr
     WHERE (ocsr.synonym_id=ordtemp->orderables[d1.seq].synonyms[d2.seq].id)
      AND ocsr.active_ind=1)
     JOIN (os
     WHERE parser(os_parse))
     JOIN (f
     WHERE parser(fparse)
      AND f.parent_entity_name="ORDER_SENTENCE"
      AND f.parent_entity_id=os.order_sentence_id
      AND f.filter_entity1_name="LOCATION")
     JOIN (cv
     WHERE cv.code_value=outerjoin(f.filter_entity1_id)
      AND cv.active_ind=outerjoin(1))
    ORDER BY d1.seq, d2.seq, os.order_sentence_id,
     f.filter_entity_reltn_id
    HEAD d1.seq
     ocnt = ocnt
    HEAD d2.seq
     ordtemp->orderables[d1.seq].synonyms[d2.seq].nbr_of_sents = 0, sencnt = 0
    HEAD os.order_sentence_id
     sencnt = (sencnt+ 1), stat = alterlist(ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences,
      sencnt), ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].id = os
     .order_sentence_id,
     ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].display = os
     .order_sentence_display_line, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
     usage_flag = os.usage_flag, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
     sequence = ocsr.display_seq,
     ordtemp->orderables[d1.seq].ord_has_sentences = 1, ordtemp->orderables[d1.seq].synonyms[d2.seq].
     nbr_of_sents = sencnt, faccnt = 0
    HEAD f.filter_entity_reltn_id
     IF (f.filter_entity1_id=0)
      ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].all_facilities_ind = 1
     ELSEIF (cv.code_value > 0)
      faccnt = (faccnt+ 1), stat = alterlist(ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[
       sencnt].facilities,faccnt), ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].
      facilities[faccnt].code_value = cv.code_value,
      ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].facilities[faccnt].display = cv
      .display, ordtemp->orderables[d1.seq].synonyms[d2.seq].sentences[sencnt].facilities[faccnt].
      description = cv.description
     ENDIF
    WITH nocounter
   ;end select
   FOR (o = 1 TO ocnt)
     FOR (s = 1 TO ordtemp->orderables[o].nbr_of_syns)
       IF ((ordtemp->orderables[o].synonyms[s].nbr_of_sents > 0))
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = ordtemp->orderables[o].synonyms[s].nbr_of_sents),
          filter_entity_reltn f
         PLAN (d)
          JOIN (f
          WHERE f.parent_entity_name="ORDER_SENTENCE"
           AND (f.parent_entity_id=ordtemp->orderables[o].synonyms[s].sentences[d.seq].id)
           AND f.filter_entity1_name="LOCATION"
           AND (((f.filter_entity1_id=request->facility_do_not_show_for)) OR (f.filter_entity1_id=0
          )) )
         DETAIL
          ordtemp->orderables[o].synonyms[s].sentences[d.seq].fac_exclude_ind = 1
         WITH nocounter
        ;end select
       ENDIF
     ENDFOR
   ENDFOR
  ENDIF
  SET rocnt = 0
  FOR (o = 1 TO ocnt)
    IF ((ordtemp->orderables[o].ord_has_sentences=1))
     SET rocnt = (rocnt+ 1)
     SET stat = alterlist(reply->orderables,rocnt)
     SET reply->orderables[rocnt].code_value = ordtemp->orderables[o].code_value
     SET reply->orderables[rocnt].description = ordtemp->orderables[o].description
     SET rsyncnt = 0
     FOR (s = 1 TO ordtemp->orderables[o].nbr_of_syns)
       IF ((ordtemp->orderables[o].synonyms[s].nbr_of_sents > 0))
        SET include_total = 0
        FOR (t = 1 TO ordtemp->orderables[o].synonyms[s].nbr_of_sents)
          IF ((ordtemp->orderables[o].synonyms[s].sentences[t].fac_exclude_ind=0))
           SET include_total = (include_total+ 1)
          ENDIF
        ENDFOR
        IF (include_total > 0)
         SET rsyncnt = (rsyncnt+ 1)
         SET stat = alterlist(reply->orderables[rocnt].synonyms,rsyncnt)
         SET reply->orderables[rocnt].synonyms[rsyncnt].id = ordtemp->orderables[o].synonyms[s].id
         SET reply->orderables[rocnt].synonyms[rsyncnt].mnemonic = ordtemp->orderables[o].synonyms[s]
         .mnemonic
         SET reply->orderables[rocnt].synonyms[rsyncnt].mnemonic_type.code_value = ordtemp->
         orderables[o].synonyms[s].mnemonic_type.code_value
         SET reply->orderables[rocnt].synonyms[rsyncnt].mnemonic_type.display = ordtemp->orderables[o
         ].synonyms[s].mnemonic_type.display
         SET reply->orderables[rocnt].synonyms[rsyncnt].mnemonic_type.mean = ordtemp->orderables[o].
         synonyms[s].mnemonic_type.mean
         SET reply->orderables[rocnt].synonyms[rsyncnt].all_facilities_ind = ordtemp->orderables[o].
         synonyms[s].all_facilities_ind
         SET synfaccnt = size(ordtemp->orderables[o].synonyms[s].facilities,5)
         SET stat = alterlist(reply->orderables[rocnt].synonyms[rsyncnt].facilities,synfaccnt)
         FOR (x = 1 TO synfaccnt)
           SET reply->orderables[rocnt].synonyms[rsyncnt].facilities[x].code_value = ordtemp->
           orderables[o].synonyms[s].facilities[x].code_value
           SET reply->orderables[rocnt].synonyms[rsyncnt].facilities[x].display = ordtemp->
           orderables[o].synonyms[s].facilities[x].display
           SET reply->orderables[rocnt].synonyms[rsyncnt].facilities[x].description = ordtemp->
           orderables[o].synonyms[s].facilities[x].description
         ENDFOR
         SET rsentcnt = 0
         FOR (t = 1 TO ordtemp->orderables[o].synonyms[s].nbr_of_sents)
           IF ((ordtemp->orderables[o].synonyms[s].sentences[t].fac_exclude_ind=0))
            SET total_sentences_in_reply = (total_sentences_in_reply+ 1)
            SET rsentcnt = (rsentcnt+ 1)
            SET stat = alterlist(reply->orderables[rocnt].synonyms[rsyncnt].sentences,rsentcnt)
            SET reply->orderables[rocnt].synonyms[rsyncnt].sentences[rsentcnt].id = ordtemp->
            orderables[o].synonyms[s].sentences[t].id
            SET reply->orderables[rocnt].synonyms[rsyncnt].sentences[rsentcnt].display = ordtemp->
            orderables[o].synonyms[s].sentences[t].display
            SET reply->orderables[rocnt].synonyms[rsyncnt].sentences[rsentcnt].usage_flag = ordtemp->
            orderables[o].synonyms[s].sentences[t].usage_flag
            SET reply->orderables[rocnt].synonyms[rsyncnt].sentences[rsentcnt].sequence = ordtemp->
            orderables[o].synonyms[s].sentences[t].sequence
            SET reply->orderables[rocnt].synonyms[rsyncnt].sentences[rsentcnt].all_facilities_ind =
            ordtemp->orderables[o].synonyms[s].sentences[t].all_facilities_ind
            SET faccnt = size(ordtemp->orderables[o].synonyms[s].sentences[t].facilities,5)
            SET stat = alterlist(reply->orderables[rocnt].synonyms[rsyncnt].sentences[rsentcnt].
             facilities,faccnt)
            FOR (f = 1 TO faccnt)
              SET reply->orderables[rocnt].synonyms[rsyncnt].sentences[rsentcnt].facilities[f].
              code_value = ordtemp->orderables[o].synonyms[s].sentences[t].facilities[f].code_value
              SET reply->orderables[rocnt].synonyms[rsyncnt].sentences[rsentcnt].facilities[f].
              display = ordtemp->orderables[o].synonyms[s].sentences[t].facilities[f].display
              SET reply->orderables[rocnt].synonyms[rsyncnt].sentences[rsentcnt].facilities[f].
              description = ordtemp->orderables[o].synonyms[s].sentences[t].facilities[f].description
            ENDFOR
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (total_sentences_in_reply=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (total_sentences_in_reply > 0)
  SET reply->status_data.status = "S"
 ENDIF
 IF (max_cnt > 0
  AND total_sentences_in_reply > max_cnt)
  SET stat = alterlist(reply->orderables,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
