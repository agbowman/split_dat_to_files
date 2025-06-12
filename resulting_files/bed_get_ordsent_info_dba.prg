CREATE PROGRAM bed_get_ordsent_info:dba
 FREE SET reply
 RECORD reply(
   1 sentences[*]
     2 id = f8
     2 order_sentence = vc
     2 oe_format_id = f8
     2 oe_format_name = vc
     2 usage_flag = i2
     2 details[*]
       3 oe_field_id = f8
       3 oe_field_display_value = vc
       3 code_value = f8
       3 label = vc
       3 oe_field_value = f8
       3 field_type_flag = i2
       3 decimal_places = i4
       3 label_text = vc
       3 clin_line_ind = i2
       3 accept_flag = i2
       3 field_seq = i4
     2 comment
       3 id = f8
       3 text = vc
     2 encntr_group
       3 code_value = f8
       3 display = vc
     2 all_facility_ind = i2
     2 facilities[*]
       3 code_value = f8
       3 display = vc
     2 comp_seq = i4
     2 filters
       3 order_sentence_filter_id = f8
       3 age_min_value = f8
       3 age_max_value = f8
       3 age_unit_cd
         4 code_value = f8
         4 display = vc
         4 mean = vc
         4 description = vc
       3 pma_min_value = f8
       3 pma_max_value = f8
       3 pma_unit_cd
         4 code_value = f8
         4 display = vc
         4 mean = vc
         4 description = vc
       3 weight_min_value = f8
       3 weight_max_value = f8
       3 weight_unit_cd
         4 code_value = f8
         4 display = vc
         4 mean = vc
         4 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET dcnt = 0
 SET fcnt = 0
 SET dnd = 0
 SET order_cd = 0.0
 SET disorder_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6003
    AND c.cdf_meaning IN ("ORDER", "DISORDER")
    AND c.active_ind=1)
  DETAIL
   IF (c.cdf_meaning="ORDER")
    order_cd = c.code_value
   ELSE
    disorder_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->standalone_ind=1))
  SELECT INTO "nl:"
   FROM ord_cat_sent_r r,
    order_sentence s,
    order_entry_format o,
    long_text l,
    code_value c
   PLAN (r
    WHERE (r.synonym_id=request->synonym_id)
     AND r.active_ind=1)
    JOIN (s
    WHERE s.order_sentence_id=r.order_sentence_id)
    JOIN (o
    WHERE o.oe_format_id=s.oe_format_id
     AND ((s.usage_flag IN (0, 1)
     AND o.action_type_cd=order_cd) OR (s.usage_flag=2
     AND o.action_type_cd=disorder_cd)) )
    JOIN (l
    WHERE l.long_text_id=s.ord_comment_long_text_id)
    JOIN (c
    WHERE c.code_value=s.order_encntr_group_cd)
   ORDER BY s.order_sentence_display_line
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->sentences,cnt), reply->sentences[cnt].id = s
    .order_sentence_id,
    reply->sentences[cnt].order_sentence = s.order_sentence_display_line, reply->sentences[cnt].
    oe_format_id = s.oe_format_id, reply->sentences[cnt].oe_format_name = o.oe_format_name,
    reply->sentences[cnt].usage_flag = s.usage_flag, reply->sentences[cnt].comment.id = s
    .ord_comment_long_text_id, reply->sentences[cnt].comment.text = l.long_text,
    reply->sentences[cnt].encntr_group.code_value = s.order_encntr_group_cd, reply->sentences[cnt].
    encntr_group.display = c.display
   WITH nocounter
  ;end select
  IF (cnt=0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    order_sentence_detail s,
    order_entry_fields oef,
    dummyt d1,
    oe_format_fields f
   PLAN (d)
    JOIN (s
    WHERE (s.order_sentence_id=reply->sentences[d.seq].id))
    JOIN (oef
    WHERE oef.oe_field_id=outerjoin(s.oe_field_id))
    JOIN (d1)
    JOIN (f
    WHERE (f.oe_format_id=reply->sentences[d.seq].oe_format_id)
     AND (((reply->sentences[d.seq].usage_flag IN (0, 1))
     AND f.action_type_cd=order_cd) OR ((reply->sentences[d.seq].usage_flag=2)
     AND f.action_type_cd=disorder_cd))
     AND f.oe_field_id=s.oe_field_id)
   ORDER BY d.seq, s.sequence
   HEAD d.seq
    dcnt = 0
   HEAD s.sequence
    IF ((request->get_no_display_ind=0)
     AND f.accept_flag=2)
     dnd = 1
    ELSE
     dcnt = (dcnt+ 1), stat = alterlist(reply->sentences[d.seq].details,dcnt), reply->sentences[d.seq
     ].details[dcnt].oe_field_id = s.oe_field_id,
     reply->sentences[d.seq].details[dcnt].oe_field_display_value = s.oe_field_display_value
     IF (s.default_parent_entity_name IN ("CODE_VALUE", "PERSON", "NOMENCLATURE", "RESEARCH_ACCOUNT",
     "SCH_BOOK_INSTR"))
      reply->sentences[d.seq].details[dcnt].code_value = s.default_parent_entity_id
     ENDIF
     reply->sentences[d.seq].details[dcnt].label = oef.description, reply->sentences[d.seq].details[
     dcnt].oe_field_value = s.oe_field_value, reply->sentences[d.seq].details[dcnt].field_type_flag
      = oef.field_type_flag
     IF (f.input_mask > " ")
      reply->sentences[d.seq].details[dcnt].decimal_places = cnvtint(f.input_mask)
     ENDIF
     reply->sentences[d.seq].details[dcnt].label_text = f.label_text, reply->sentences[d.seq].
     details[dcnt].clin_line_ind = f.clin_line_ind, reply->sentences[d.seq].details[dcnt].accept_flag
      = f.accept_flag,
     reply->sentences[d.seq].details[dcnt].field_seq = s.sequence
    ENDIF
   WITH nocounter, outerjoin = d1
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM cs_component cs,
    order_sentence s,
    order_entry_format o,
    long_text l,
    code_value c
   PLAN (cs
    WHERE (cs.catalog_cd=request->careset_catalog_code_value)
     AND (cs.comp_id=request->synonym_id)
     AND (cs.comp_seq=request->comp_seq)
     AND cs.order_sentence_id > 0)
    JOIN (s
    WHERE s.order_sentence_id=cs.order_sentence_id)
    JOIN (o
    WHERE o.oe_format_id=s.oe_format_id
     AND ((s.usage_flag IN (0, 1)
     AND o.action_type_cd=order_cd) OR (s.usage_flag=2
     AND o.action_type_cd=disorder_cd)) )
    JOIN (l
    WHERE l.long_text_id=s.ord_comment_long_text_id)
    JOIN (c
    WHERE c.code_value=s.order_encntr_group_cd)
   ORDER BY s.order_sentence_display_line
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->sentences,cnt), reply->sentences[cnt].id = s
    .order_sentence_id,
    reply->sentences[cnt].order_sentence = s.order_sentence_display_line, reply->sentences[cnt].
    oe_format_id = s.oe_format_id, reply->sentences[cnt].oe_format_name = o.oe_format_name,
    reply->sentences[cnt].usage_flag = s.usage_flag, reply->sentences[cnt].comment.id = s
    .ord_comment_long_text_id, reply->sentences[cnt].comment.text = l.long_text,
    reply->sentences[cnt].encntr_group.code_value = s.order_encntr_group_cd, reply->sentences[cnt].
    encntr_group.display = c.display, reply->sentences[cnt].comp_seq = cs.comp_seq
   WITH nocounter
  ;end select
  IF (cnt=0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    order_sentence_detail s,
    dummyt d1,
    oe_format_fields f,
    order_entry_fields oef
   PLAN (d)
    JOIN (s
    WHERE (s.order_sentence_id=reply->sentences[d.seq].id))
    JOIN (oef
    WHERE oef.oe_field_id=outerjoin(s.oe_field_id))
    JOIN (d1)
    JOIN (f
    WHERE (f.oe_format_id=reply->sentences[d.seq].oe_format_id)
     AND (((reply->sentences[d.seq].usage_flag IN (0, 1))
     AND f.action_type_cd=order_cd) OR ((reply->sentences[d.seq].usage_flag=2)
     AND f.action_type_cd=disorder_cd))
     AND f.oe_field_id=s.oe_field_id)
   ORDER BY d.seq, s.sequence
   HEAD d.seq
    dcnt = 0
   HEAD s.sequence
    IF ((request->get_no_display_ind=0)
     AND f.accept_flag=2)
     dnd = 1
    ELSE
     dcnt = (dcnt+ 1), stat = alterlist(reply->sentences[d.seq].details,dcnt), reply->sentences[d.seq
     ].details[dcnt].oe_field_id = s.oe_field_id,
     reply->sentences[d.seq].details[dcnt].oe_field_display_value = s.oe_field_display_value
     IF (s.default_parent_entity_name IN ("CODE_VALUE", "PERSON", "NOMENCLATURE", "RESEARCH_ACCOUNT",
     "SCH_BOOK_INSTR"))
      reply->sentences[d.seq].details[dcnt].code_value = s.default_parent_entity_id
     ENDIF
     reply->sentences[d.seq].details[dcnt].label = oef.description, reply->sentences[d.seq].details[
     dcnt].oe_field_value = s.oe_field_value, reply->sentences[d.seq].details[dcnt].field_type_flag
      = oef.field_type_flag
     IF (f.input_mask > " ")
      reply->sentences[d.seq].details[dcnt].decimal_places = cnvtint(f.input_mask)
     ENDIF
     reply->sentences[d.seq].details[dcnt].label_text = f.label_text, reply->sentences[d.seq].
     details[dcnt].clin_line_ind = f.clin_line_ind, reply->sentences[d.seq].details[dcnt].accept_flag
      = f.accept_flag,
     reply->sentences[d.seq].details[dcnt].field_seq = s.sequence
    ENDIF
   WITH nocounter, outerjoin = d1
  ;end select
 ENDIF
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    filter_entity_reltn f,
    code_value c
   PLAN (d)
    JOIN (f
    WHERE f.parent_entity_name="ORDER_SENTENCE"
     AND (f.parent_entity_id=reply->sentences[d.seq].id)
     AND f.filter_entity1_name="LOCATION")
    JOIN (c
    WHERE c.code_value=f.filter_entity1_id)
   ORDER BY d.seq, c.display
   HEAD d.seq
    fcnt = 0
   DETAIL
    IF (f.filter_entity1_id=0)
     reply->sentences[d.seq].all_facility_ind = 1
    ELSE
     fcnt = (fcnt+ 1), stat = alterlist(reply->sentences[d.seq].facilities,fcnt), reply->sentences[d
     .seq].facilities[fcnt].code_value = f.filter_entity1_id,
     reply->sentences[d.seq].facilities[fcnt].display = c.display
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    order_sentence_filter osf,
    code_value cv_age,
    code_value cv_pma,
    code_value cv_weight
   PLAN (d)
    JOIN (osf
    WHERE (osf.order_sentence_id=reply->sentences[d.seq].id))
    JOIN (cv_age
    WHERE outerjoin(osf.age_unit_cd)=cv_age.code_value)
    JOIN (cv_pma
    WHERE outerjoin(osf.pma_unit_cd)=cv_pma.code_value)
    JOIN (cv_weight
    WHERE outerjoin(osf.weight_unit_cd)=cv_weight.code_value)
   ORDER BY d.seq, osf.order_sentence_id
   DETAIL
    reply->sentences[d.seq].filters.order_sentence_filter_id = osf.order_sentence_filter_id, reply->
    sentences[d.seq].filters.age_min_value = osf.age_min_value, reply->sentences[d.seq].filters.
    age_max_value = osf.age_max_value,
    reply->sentences[d.seq].filters.age_unit_cd.code_value = osf.age_unit_cd, reply->sentences[d.seq]
    .filters.age_unit_cd.display = cv_age.display, reply->sentences[d.seq].filters.age_unit_cd.
    description = cv_age.description,
    reply->sentences[d.seq].filters.age_unit_cd.mean = cv_age.cdf_meaning, reply->sentences[d.seq].
    filters.pma_min_value = osf.pma_min_value, reply->sentences[d.seq].filters.pma_max_value = osf
    .pma_max_value,
    reply->sentences[d.seq].filters.pma_unit_cd.code_value = osf.pma_unit_cd, reply->sentences[d.seq]
    .filters.pma_unit_cd.display = cv_pma.display, reply->sentences[d.seq].filters.pma_unit_cd.
    description = cv_pma.description,
    reply->sentences[d.seq].filters.pma_unit_cd.mean = cv_pma.cdf_meaning, reply->sentences[d.seq].
    filters.weight_min_value = osf.weight_min_value, reply->sentences[d.seq].filters.weight_max_value
     = osf.weight_max_value,
    reply->sentences[d.seq].filters.weight_unit_cd.code_value = osf.weight_unit_cd, reply->sentences[
    d.seq].filters.weight_unit_cd.display = cv_weight.display, reply->sentences[d.seq].filters.
    weight_unit_cd.description = cv_weight.description,
    reply->sentences[d.seq].filters.weight_unit_cd.mean = cv_weight.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
