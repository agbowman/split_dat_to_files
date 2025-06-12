CREATE PROGRAM cps_get_order_sent_detail:dba
 RECORD reply(
   1 order_sentence_id = f8
   1 sent_detail_qual = i4
   1 sent_detail[*]
     2 sequence = i4
     2 oe_field_value = f8
     2 oe_field_id = f8
     2 oe_field_display_value = vc
     2 oe_field_meaning_id = f8
     2 oe_field_mean = vc
     2 field_type_flag = i2
   1 ord_comment_long_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET reply->status_data.status = "S"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = false
 SET table_name = "ORDER_SENTENCE_DETAIL"
 SET knt = 0
 SELECT INTO "nl:"
  osd.order_sentence_id
  FROM order_sentence_detail osd,
   oe_field_meaning ofm
  PLAN (osd
   WHERE (osd.order_sentence_id=request->order_sentence_id))
   JOIN (ofm
   WHERE ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
  HEAD REPORT
   reply->order_sentence_id = osd.order_sentence_id, knt = 0, stat = alterlist(reply->sent_detail,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->sent_detail,(knt+ 9))
   ENDIF
   reply->sent_detail[knt].sequence = osd.sequence
   IF (osd.field_type_flag IN (6, 8, 9, 10, 12,
   13))
    reply->sent_detail[knt].oe_field_value = validate(osd.default_parent_entity_id,osd.oe_field_value
     )
   ELSE
    reply->sent_detail[knt].oe_field_value = osd.oe_field_value
   ENDIF
   reply->sent_detail[knt].oe_field_id = osd.oe_field_id, reply->sent_detail[knt].
   oe_field_display_value = osd.oe_field_display_value, reply->sent_detail[knt].oe_field_meaning_id
    = osd.oe_field_meaning_id,
   reply->sent_detail[knt].oe_field_mean = ofm.oe_field_meaning, reply->sent_detail[knt].
   field_type_flag = osd.field_type_flag
  FOOT REPORT
   stat = alterlist(reply->sent_detail,knt), reply->sent_detail_qual = knt
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET reply->status_data.status = "Z"
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  lt.long_text
  FROM long_text lt,
   order_sentence os
  PLAN (os
   WHERE (os.order_sentence_id=request->order_sentence_id))
   JOIN (lt
   WHERE lt.long_text_id=os.ord_comment_long_text_id)
  DETAIL
   reply->ord_comment_long_text = lt.long_text
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
 ELSE
  CASE (failed)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "order_sent_det"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ENDIF
 SET script_version = "003 03/07/03 SB8972"
END GO
