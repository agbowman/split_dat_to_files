CREATE PROGRAM bhs_athn_get_order_sentence
 RECORD out_rec(
   1 sentences[*]
     2 order_sentence_id = vc
     2 order_sentence_detail = vc
 )
 DECLARE o_cnt = i4
 DECLARE order_encntr_group_cd = f8
 SELECT INTO "nl:"
  FROM encounter e,
   code_value_group cvg
  PLAN (e
   WHERE (e.encntr_id= $5))
   JOIN (cvg
   WHERE cvg.child_code_value=e.encntr_type_cd
    AND cvg.code_set=71)
  HEAD REPORT
   order_encntr_group_cd = cvg.parent_code_value
  WITH nocounter, time = 30
 ;end select
 IF (( $4=1))
  SELECT INTO "nl:"
   FROM ord_cat_sent_r ocsr,
    order_sentence os
   PLAN (ocsr
    WHERE (ocsr.synonym_id= $2)
     AND (ocsr.catalog_cd= $3)
     AND ocsr.active_ind=1)
    JOIN (os
    WHERE os.order_sentence_id=ocsr.order_sentence_id
     AND os.order_encntr_group_cd=order_encntr_group_cd)
   ORDER BY ocsr.display_seq
   HEAD os.order_sentence_id
    o_cnt += 1
    IF (mod(o_cnt,100)=1)
     stat = alterlist(out_rec->sentences,(o_cnt+ 99))
    ENDIF
    out_rec->sentences[o_cnt].order_sentence_id = cnvtstring(os.order_sentence_id), out_rec->
    sentences[o_cnt].order_sentence_detail = os.order_sentence_display_line
   FOOT REPORT
    stat = alterlist(out_rec->sentences,o_cnt)
   WITH nocounter, time = 30
  ;end select
  IF (o_cnt=0)
   SELECT INTO "nl:"
    FROM ord_cat_sent_r ocsr,
     order_sentence os
    PLAN (ocsr
     WHERE (ocsr.synonym_id= $2)
      AND (ocsr.catalog_cd= $3)
      AND ocsr.active_ind=1)
     JOIN (os
     WHERE os.order_sentence_id=ocsr.order_sentence_id
      AND os.order_encntr_group_cd=0)
    ORDER BY ocsr.display_seq
    HEAD os.order_sentence_id
     o_cnt += 1
     IF (mod(o_cnt,100)=1)
      stat = alterlist(out_rec->sentences,(o_cnt+ 99))
     ENDIF
     out_rec->sentences[o_cnt].order_sentence_id = cnvtstring(os.order_sentence_id), out_rec->
     sentences[o_cnt].order_sentence_detail = os.order_sentence_display_line
    FOOT REPORT
     stat = alterlist(out_rec->sentences,o_cnt)
    WITH nocounter, time = 30
   ;end select
  ENDIF
 ENDIF
 IF (( $4=2))
  SELECT INTO "nl:"
   FROM order_sentence os
   PLAN (os
    WHERE (os.parent_entity_id= $2)
     AND (((os.parent_entity2_id= $3)) OR (os.parent_entity2_id=0))
     AND ((os.order_encntr_group_cd=order_encntr_group_cd) OR (os.order_encntr_group_cd=0)) )
   ORDER BY os.order_sentence_id
   HEAD os.order_sentence_id
    o_cnt += 1
    IF (mod(o_cnt,100)=1)
     stat = alterlist(out_rec->sentences,(o_cnt+ 99))
    ENDIF
    out_rec->sentences[o_cnt].order_sentence_id = cnvtstring(os.order_sentence_id), out_rec->
    sentences[o_cnt].order_sentence_detail = os.order_sentence_display_line
   FOOT REPORT
    stat = alterlist(out_rec->sentences,o_cnt)
   WITH nocounter, time = 30
  ;end select
 ENDIF
 CALL echojson(out_rec, $1)
END GO
