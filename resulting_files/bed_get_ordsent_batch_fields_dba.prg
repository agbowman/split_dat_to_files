CREATE PROGRAM bed_get_ordsent_batch_fields:dba
 FREE SET reply
 RECORD reply(
   1 fields[*]
     2 oe_field_id = f8
     2 label = vc
     2 value = vc
     2 field_type_flag = i2
     2 codeset = i4
     2 decimal_places = i4
   1 synonyms[*]
     2 id = f8
     2 careset_catalog_code_value = f8
     2 sentences[*]
       3 id = f8
       3 display = vc
       3 details[*]
         4 oe_field_id = f8
         4 oe_field_display_value = vc
         4 code_value = f8
         4 oe_field_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = 0
 DECLARE value = vc
 SET scnt = size(request->synonyms,5)
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 SET order_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6003
    AND c.cdf_meaning="ORDER"
    AND c.active_ind=1)
  DETAIL
   order_cd = c.code_value
  WITH nocounter
 ;end select
 SET disorder_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6003
    AND c.cdf_meaning="DISORDER"
    AND c.active_ind=1)
  DETAIL
   disorder_cd = c.code_value
  WITH nocounter
 ;end select
 SET cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(scnt)),
   ord_cat_sent_r r,
   order_sentence_detail s,
   order_entry_fields f,
   oe_format_fields o
  PLAN (d)
   JOIN (r
   WHERE (r.synonym_id=request->synonyms[d.seq].id)
    AND (request->synonyms[d.seq].careset_catalog_code_value=0)
    AND r.active_ind=1)
   JOIN (s
   WHERE s.order_sentence_id=r.order_sentence_id)
   JOIN (f
   WHERE f.oe_field_id=s.oe_field_id
    AND f.field_type_flag IN (0, 1, 2, 3, 5,
   6, 7, 12))
   JOIN (o
   WHERE o.oe_field_id=f.oe_field_id
    AND o.action_type_cd IN (order_cd, disorder_cd))
  ORDER BY s.oe_field_id, s.oe_field_display_value
  HEAD s.oe_field_id
   decimal_places = 0, cnt = (cnt+ 1), stat = alterlist(reply->fields,cnt),
   reply->fields[cnt].oe_field_id = s.oe_field_id, reply->fields[cnt].label = f.description, reply->
   fields[cnt].field_type_flag = f.field_type_flag,
   reply->fields[cnt].codeset = f.codeset
  DETAIL
   IF (cnvtint(o.input_mask) > decimal_places)
    reply->fields[cnt].decimal_places = cnvtint(o.input_mask)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(scnt)),
   cs_component c,
   order_sentence_detail s,
   order_entry_fields f,
   oe_format_fields o
  PLAN (d)
   JOIN (c
   WHERE (c.catalog_cd=request->synonyms[d.seq].careset_catalog_code_value)
    AND (c.comp_id=request->synonyms[d.seq].id)
    AND c.order_sentence_id > 0)
   JOIN (s
   WHERE s.order_sentence_id=c.order_sentence_id)
   JOIN (f
   WHERE f.oe_field_id=s.oe_field_id
    AND f.field_type_flag IN (0, 1, 2, 3, 5,
   6, 7, 12))
   JOIN (o
   WHERE o.oe_field_id=f.oe_field_id
    AND o.action_type_cd IN (order_cd, disorder_cd))
  ORDER BY s.oe_field_id, s.oe_field_display_value
  HEAD s.oe_field_id
   decimal_places = 0, found = 0
   FOR (x = 1 TO size(reply->fields,5))
     IF ((s.oe_field_id=reply->fields[x].oe_field_id))
      found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    cnt = (cnt+ 1), stat = alterlist(reply->fields,cnt), reply->fields[cnt].oe_field_id = s
    .oe_field_id,
    reply->fields[cnt].label = f.description, reply->fields[cnt].field_type_flag = f.field_type_flag,
    reply->fields[cnt].codeset = f.codeset
   ENDIF
  DETAIL
   IF (found=0
    AND cnvtint(o.input_mask) > decimal_places)
    reply->fields[cnt].decimal_places = cnvtint(o.input_mask)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SET rcnt = 0
 SET dcnt = 0
 FOR (x = 1 TO scnt)
   IF ((request->synonyms[x].careset_catalog_code_value=0))
    SELECT INTO "nl:"
     FROM ord_cat_sent_r r,
      order_sentence_detail s
     PLAN (r
      WHERE (r.synonym_id=request->synonyms[x].id)
       AND r.active_ind=1)
      JOIN (s
      WHERE s.order_sentence_id=r.order_sentence_id)
     ORDER BY r.synonym_id, r.order_sentence_id, s.sequence
     HEAD r.synonym_id
      dcnt = 0, rcnt = 0, cnt = (cnt+ 1),
      stat = alterlist(reply->synonyms,cnt), reply->synonyms[cnt].id = r.synonym_id
     HEAD r.order_sentence_id
      dcnt = 0, rcnt = (rcnt+ 1), stat = alterlist(reply->synonyms[cnt].sentences,rcnt),
      reply->synonyms[cnt].sentences[rcnt].id = r.order_sentence_id, reply->synonyms[cnt].sentences[
      rcnt].display = r.order_sentence_disp_line
     DETAIL
      dcnt = (dcnt+ 1), stat = alterlist(reply->synonyms[cnt].sentences[rcnt].details,dcnt), reply->
      synonyms[cnt].sentences[rcnt].details[dcnt].oe_field_id = s.oe_field_id,
      reply->synonyms[cnt].sentences[rcnt].details[dcnt].oe_field_display_value = s
      .oe_field_display_value, reply->synonyms[cnt].sentences[rcnt].details[dcnt].oe_field_value = s
      .oe_field_value
      IF (s.default_parent_entity_name IN ("CODE_VALUE", "PERSON", "NOMENCLATURE", "RESEARCH_ACCOUNT",
      "SCH_BOOK_INSTR"))
       reply->synonyms[cnt].sentences[rcnt].details[dcnt].code_value = s.default_parent_entity_id
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM cs_component c,
      order_sentence o,
      order_sentence_detail s
     PLAN (c
      WHERE (c.catalog_cd=request->synonyms[x].careset_catalog_code_value)
       AND (c.comp_id=request->synonyms[x].id)
       AND c.order_sentence_id > 0)
      JOIN (o
      WHERE o.order_sentence_id=c.order_sentence_id)
      JOIN (s
      WHERE s.order_sentence_id=c.order_sentence_id)
     ORDER BY c.comp_id, c.order_sentence_id, s.sequence
     HEAD c.comp_id
      dcnt = 0, rcnt = 0, cnt = (cnt+ 1),
      stat = alterlist(reply->synonyms,cnt), reply->synonyms[cnt].id = c.comp_id, reply->synonyms[cnt
      ].careset_catalog_code_value = c.catalog_cd
     HEAD c.order_sentence_id
      dcnt = 0, rcnt = (rcnt+ 1), stat = alterlist(reply->synonyms[cnt].sentences,rcnt),
      reply->synonyms[cnt].sentences[rcnt].id = c.order_sentence_id, reply->synonyms[cnt].sentences[
      rcnt].display = o.order_sentence_display_line
     DETAIL
      dcnt = (dcnt+ 1), stat = alterlist(reply->synonyms[cnt].sentences[rcnt].details,dcnt), reply->
      synonyms[cnt].sentences[rcnt].details[dcnt].oe_field_id = s.oe_field_id,
      reply->synonyms[cnt].sentences[rcnt].details[dcnt].oe_field_display_value = s
      .oe_field_display_value, reply->synonyms[cnt].sentences[rcnt].details[dcnt].oe_field_value = s
      .oe_field_value
      IF (s.default_parent_entity_name IN ("CODE_VALUE", "PERSON", "NOMENCLATURE", "RESEARCH_ACCOUNT",
      "SCH_BOOK_INSTR"))
       reply->synonyms[cnt].sentences[rcnt].details[dcnt].code_value = s.default_parent_entity_id
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
