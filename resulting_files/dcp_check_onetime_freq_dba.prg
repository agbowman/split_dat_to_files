CREATE PROGRAM dcp_check_onetime_freq:dba
 RECORD reply(
   1 qual[*]
     2 order_sent_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 list[*]
     2 id = f8
     2 cd = f8
 )
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idx2 = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM order_sentence_detail osd,
   (dummyt d  WITH seq = value(size(request->order_sent,5)))
  PLAN (d)
   JOIN (osd
   WHERE (osd.order_sentence_id=request->order_sent[d.seq].order_sent_id)
    AND osd.oe_field_meaning_id=2011)
  HEAD REPORT
   idx2 = 0
  DETAIL
   IF (osd.order_sentence_id > 0)
    IF (osd.field_type_flag IN (6, 8, 9, 10, 12,
    13)
     AND osd.default_parent_entity_id > 0)
     idx2 = (idx2+ 1)
     IF (idx2 > size(temp->list,5))
      stat = alterlist(temp->list,(idx2+ 10))
     ENDIF
     temp->list[idx2].id = osd.order_sentence_id, temp->list[idx2].cd = osd.default_parent_entity_id
    ELSE
     idx2 = (idx2+ 1)
     IF (idx2 > size(temp->list,5))
      stat = alterlist(temp->list,(idx2+ 10))
     ENDIF
     temp->list[idx2].id = osd.order_sentence_id, temp->list[idx2].cd = osd.oe_field_value
    ENDIF
   ENDIF
  FOOT REPORT
   IF (idx2 > 0)
    stat = alterlist(temp->list,idx2)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ord_sent_id = temp->list[d.seq].id, fs.frequency_cd
  FROM frequency_schedule fs,
   (dummyt d  WITH seq = value(size(temp->list,5)))
  PLAN (d)
   JOIN (fs
   WHERE (fs.frequency_cd=temp->list[d.seq].cd)
    AND fs.activity_type_cd=0
    AND fs.frequency_type=4)
  ORDER BY ord_sent_id
  HEAD REPORT
   idx = size(reply->qual,5)
  HEAD ord_sent_id
   IF (fs.frequency_cd=0)
    idx = (idx+ 1)
    IF (idx > size(reply->qual,5))
     stat = alterlist(reply->qual,(idx+ 10))
    ENDIF
    reply->qual[idx].order_sent_id = ord_sent_id
   ENDIF
  FOOT REPORT
   IF (idx > 0)
    stat = alterlist(reply->qual,idx)
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SET reply->status_data.status = "S"
END GO
