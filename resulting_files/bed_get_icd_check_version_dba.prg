CREATE PROGRAM bed_get_icd_check_version:dba
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
 SET icd_code = uar_get_code_by("MEANING",400,"ICD9")
 SELECT INTO "nl:"
  c.version_ft
  FROM cmt_content_version c
  WHERE c.source_vocabulary_cd=icd_code
  ORDER BY c.version_number DESC
  DETAIL
   reply->version = c.version_ft
  WITH maxqual(c,1)
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
