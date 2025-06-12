CREATE PROGRAM dcp_get_long_blob:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 long_blob = gvc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE req_long_blob_id = f8 WITH protect, constant(validate(request->long_blob_id,0.0))
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE retlen = i4 WITH protect, noconstant(0)
 IF (req_long_blob_id <= 0.0)
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM long_blob lb
  PLAN (lb
   WHERE lb.long_blob_id=req_long_blob_id)
  DETAIL
   cstatus = "S", msg_buf = fillstring(32000," "), offset = 0,
   retlen = 1
   WHILE (retlen > 0)
     retlen = blobget(msg_buf,offset,lb.long_blob)
     IF (retlen > 0)
      IF (retlen=size(msg_buf))
       reply->long_blob = concat(reply->long_blob,msg_buf)
      ELSE
       reply->long_blob = concat(reply->long_blob,substring(1,retlen,msg_buf))
      ENDIF
     ENDIF
     offset = (offset+ retlen)
   ENDWHILE
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = cstatus
END GO
