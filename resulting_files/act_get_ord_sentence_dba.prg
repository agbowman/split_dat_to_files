CREATE PROGRAM act_get_ord_sentence:dba
 RECORD reply(
   1 qual_sent[*]
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 sent_detail[*]
       3 sequence = i4
       3 oe_field_value = f8
       3 oe_field_id = f8
       3 oe_field_display_value = vc
       3 oe_field_meaning_id = f8
       3 oe_field_mean = vc
       3 field_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE d_cnt = i4 WITH public, noconstant(0)
 DECLARE ord_sent_id = f8 WITH public, noconstant(0.0)
 DECLARE multi_ord_sent_ind = i2 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE (ocs.synonym_id=request->synonym_id)
    AND ocs.active_ind=1)
  DETAIL
   ord_sent_id = ocs.order_sentence_id, multi_ord_sent_ind = ocs.multiple_ord_sent_ind
  WITH nocounter, maxrec = 1
 ;end select
 IF (multi_ord_sent_ind=0
  AND ord_sent_id != 0.0)
  SELECT INTO "nl:"
   FROM order_sentence os
   PLAN (os
    WHERE os.order_sentence_id=ord_sent_id)
   DETAIL
    IF ((((request->usage_flag=0)) OR (((os.usage_flag=0) OR ((os.usage_flag=request->usage_flag)))
    )) )
     IF ((((request->order_encntr_group_cd=0)) OR (((os.order_encntr_group_cd=0) OR ((os
     .order_encntr_group_cd=request->order_encntr_group_cd))) )) )
      cnt = (cnt+ 1), stat = alterlist(reply->qual_sent,cnt), reply->qual_sent[cnt].order_sentence_id
       = os.order_sentence_id,
      reply->qual_sent[cnt].order_sentence_display_line = os.order_sentence_display_line
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  IF (multi_ord_sent_ind=1)
   SELECT INTO "nl:"
    FROM ord_cat_sent_r ocsr,
     order_sentence os
    PLAN (ocsr
     WHERE (ocsr.synonym_id=request->synonym_id)
      AND ocsr.active_ind=1)
     JOIN (os
     WHERE os.order_sentence_id=ocsr.order_sentence_id)
    ORDER BY ocsr.display_seq
    DETAIL
     IF ((((request->usage_flag=0)) OR (((os.usage_flag=0) OR ((os.usage_flag=request->usage_flag)))
     )) )
      IF ((((request->order_encntr_group_cd=0)) OR (((os.order_encntr_group_cd=0) OR ((os
      .order_encntr_group_cd=request->order_encntr_group_cd))) )) )
       cnt = (cnt+ 1), stat = alterlist(reply->qual_sent,cnt), reply->qual_sent[cnt].
       order_sentence_id = os.order_sentence_id,
       reply->qual_sent[cnt].order_sentence_display_line = os.order_sentence_display_line
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    order_sentence_detail osd,
    oe_field_meaning ofm
   PLAN (d)
    JOIN (osd
    WHERE (osd.order_sentence_id=reply->qual_sent[d.seq].order_sentence_id))
    JOIN (ofm
    WHERE ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
   ORDER BY d.seq, osd.sequence
   HEAD d.seq
    d_cnt = 0
   DETAIL
    d_cnt = (d_cnt+ 1), stat = alterlist(reply->qual_sent[d.seq].sent_detail,d_cnt), reply->
    qual_sent[d.seq].sent_detail[d_cnt].sequence = osd.sequence,
    reply->qual_sent[d.seq].sent_detail[d_cnt].oe_field_value = osd.oe_field_value, reply->qual_sent[
    d.seq].sent_detail[d_cnt].oe_field_id = osd.oe_field_id, reply->qual_sent[d.seq].sent_detail[
    d_cnt].oe_field_display_value = osd.oe_field_display_value,
    reply->qual_sent[d.seq].sent_detail[d_cnt].oe_field_meaning_id = osd.oe_field_meaning_id, reply->
    qual_sent[d.seq].sent_detail[d_cnt].oe_field_mean = ofm.oe_field_meaning, reply->qual_sent[d.seq]
    .sent_detail[d_cnt].field_type_flag = osd.field_type_flag
   WITH nocounter
  ;end select
 ENDIF
END GO
