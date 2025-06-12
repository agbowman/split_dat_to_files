CREATE PROGRAM cps_del_ord_sentence_id:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DELETE  FROM order_sentence_detail osd,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET osd.seq = osd.seq
  PLAN (d
   WHERE d.seq > 0)
   JOIN (osd
   WHERE (osd.order_sentence_id=request->qual[d.seq].order_sentence_id)
    AND osd.order_sentence_id > 0)
  WITH nocounter
 ;end delete
 DELETE  FROM order_sentence os,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET os.seq = os.seq
  PLAN (d
   WHERE d.seq > 0)
   JOIN (os
   WHERE (os.order_sentence_id=request->qual[d.seq].order_sentence_id)
    AND os.order_sentence_id > 0)
  WITH nocounter
 ;end delete
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ORDer_SENTENCE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   SET failed = true
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "Z"
   SET failed = true
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
