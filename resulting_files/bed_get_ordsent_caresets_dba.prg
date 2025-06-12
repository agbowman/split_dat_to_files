CREATE PROGRAM bed_get_ordsent_caresets:dba
 FREE SET reply
 RECORD reply(
   1 caresets[*]
     2 code_value = f8
     2 display = vc
     2 synonym
       3 id = f8
       3 mnemonic = vc
       3 baseline_ind = i2
     2 sentences[*]
       3 id = f8
       3 display_line = vc
       3 comp_seq = i4
     2 interval_order_set_ind = i2
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
 DECLARE lab_cat_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"GENERAL LAB")), protect
 SET cs_ord_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6030
    AND c.cdf_meaning="ORDERABLE")
  DETAIL
   cs_ord_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cs_component cs,
   code_value c
  PLAN (cs
   WHERE (cs.comp_id=request->synonym_id))
   JOIN (c
   WHERE c.code_value=cs.catalog_cd)
  ORDER BY c.display
  HEAD cs.catalog_cd
   IF ((cs.catalog_cd != request->careset_catalog_code_value))
    cnt = (cnt+ 1), stat = alterlist(reply->caresets,cnt), reply->caresets[cnt].code_value = cs
    .catalog_cd,
    reply->caresets[cnt].display = c.display
   ENDIF
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   cs_component c,
   order_catalog_synonym o,
   order_sentence s
  PLAN (d)
   JOIN (c
   WHERE (c.catalog_cd=reply->caresets[d.seq].code_value)
    AND (c.comp_id=request->synonym_id)
    AND c.comp_type_cd=cs_ord_cd)
   JOIN (o
   WHERE o.synonym_id=c.comp_id)
   JOIN (s
   WHERE s.order_sentence_id=outerjoin(c.order_sentence_id))
  ORDER BY d.seq, c.comp_seq
  HEAD d.seq
   scnt = 0, reply->caresets[d.seq].synonym.id = o.synonym_id, reply->caresets[d.seq].synonym.
   mnemonic = o.mnemonic
   IF ((c.linked_date_comp_seq=- (1))
    AND o.catalog_type_cd=lab_cat_type_cd)
    reply->caresets[d.seq].synonym.baseline_ind = 1, reply->caresets[d.seq].interval_order_set_ind =
    1
   ENDIF
  HEAD c.comp_seq
   scnt = (scnt+ 1), stat = alterlist(reply->caresets[d.seq].sentences,scnt), reply->caresets[d.seq].
   sentences[scnt].id = s.order_sentence_id,
   reply->caresets[d.seq].sentences[scnt].display_line = s.order_sentence_display_line, reply->
   caresets[d.seq].sentences[scnt].comp_seq = c.comp_seq
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
