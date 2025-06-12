CREATE PROGRAM bed_get_content_version:dba
 FREE SET reply
 RECORD reply(
   1 version = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  c.version_ft
  FROM cmt_content_version c
  WHERE (c.source_vocabulary_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=400
    AND (cv.cdf_meaning=request->meaning)))
  ORDER BY c.version_number DESC
  DETAIL
   reply->version = c.version_ft
  WITH maxqual(c,1)
 ;end select
#exit_script
 IF ((reply->version > " "))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
