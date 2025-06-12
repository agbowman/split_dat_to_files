CREATE PROGRAM ccl_get_workbench_state:dba
 RECORD reply(
   1 long_blob = gvc
   1 blob_length = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  lb.*
  FROM long_blob_reference lbr
  WHERE (lbr.long_blob_id=request->long_blob_id)
  HEAD REPORT
   outbuf = fillstring(32767," ")
  DETAIL
   offset = 0, retlen = 1
   WHILE (retlen > 0)
     retlen = blobget(outbuf,offset,lbr.long_blob), offset += retlen, reply->long_blob = notrim(
      concat(notrim(reply->long_blob),notrim(substring(1,retlen,outbuf))))
   ENDWHILE
   reply->blob_length = textlen(reply->long_blob)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "NL:"
   lb.*
   FROM long_blob lb
   WHERE (lb.long_blob_id=request->long_blob_id)
   HEAD REPORT
    outbuf = fillstring(32767," ")
   DETAIL
    offset = 0, retlen = 1
    WHILE (retlen > 0)
      retlen = blobget(outbuf,offset,lb.long_blob), offset += retlen, reply->long_blob = notrim(
       concat(notrim(reply->long_blob),notrim(substring(1,retlen,outbuf))))
    ENDWHILE
    reply->blob_length = lb.blob_length
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual < 0)
  SET reply->status_data.status = "F"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
