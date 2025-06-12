CREATE PROGRAM bed_get_ordsent_sentences:dba
 FREE SET reply
 RECORD reply(
   1 sentences[*]
     2 id = f8
     2 order_sentence = vc
     2 sequence = i4
     2 encntr_group
       3 code_value = f8
       3 display = vc
     2 facilities[*]
       3 code_value = f8
       3 display = vc
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
 SET fcnt = 0
 SELECT INTO "nl:"
  FROM ord_cat_sent_r r,
   order_sentence s,
   code_value c
  PLAN (r
   WHERE (r.synonym_id=request->synonym_id)
    AND r.active_ind=1)
   JOIN (s
   WHERE s.order_sentence_id=r.order_sentence_id)
   JOIN (c
   WHERE c.code_value=s.order_encntr_group_cd)
  ORDER BY r.order_sentence_disp_line
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->sentences,cnt), reply->sentences[cnt].id = s
   .order_sentence_id,
   reply->sentences[cnt].order_sentence = s.order_sentence_display_line, reply->sentences[cnt].
   sequence = r.display_seq, reply->sentences[cnt].encntr_group.code_value = s.order_encntr_group_cd,
   reply->sentences[cnt].encntr_group.display = c.display
  WITH nocounter
 ;end select
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
    fcnt = (fcnt+ 1), stat = alterlist(reply->sentences[d.seq].facilities,fcnt), reply->sentences[d
    .seq].facilities[fcnt].code_value = f.filter_entity1_id,
    reply->sentences[d.seq].facilities[fcnt].display = c.display
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
