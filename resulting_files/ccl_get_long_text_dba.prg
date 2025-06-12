CREATE PROGRAM ccl_get_long_text:dba
 PROMPT
  "search pattern " = ""
  WITH srctbl
 RECORD long_reply(
   1 long_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "NL:"
  lt.long_text, lt.long_text_id
  FROM long_text lt
  WHERE lt.long_text_id=cnvtreal( $SRCTBL)
  DETAIL
   long_reply->long_text = lt.long_text
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET long_text->status_data.status = "F"
  SET long_text->status_data.subeventstatus[1].operationname = "select statement"
  SET long_text->status_data.subeventstatus[1].operationstatus = "F"
  SET long_text->status_data.subeventstatus[1].targetobjectvalue = "No matching row was found"
  GO TO exitscript
 ENDIF
 DECLARE err_msg = vc
 IF (error(err_msg,0) > 0)
  SET long_reply->status_data.status = "F"
  SET long_reply->status_data.subeventstatus[1].operationname = "select statement"
  SET long_reply->status_data.subeventstatus[1].operationstatus = "F"
  SET long_reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
  GO TO exitscript
 ENDIF
#exitscript
 SET _memory_reply_string = cnvtrectojson(long_reply,2,1)
END GO
