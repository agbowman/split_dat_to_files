CREATE PROGRAM bed_get_ocrec_contrib_source:dba
 FREE SET reply
 RECORD reply(
   1 contributor_source[*]
     2 code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM code_value_alias a,
   code_value c
  PLAN (a
   WHERE a.code_set=200)
   JOIN (c
   WHERE c.code_value=a.contributor_source_cd)
  ORDER BY c.display
  HEAD c.display
   cnt = (cnt+ 1), stat = alterlist(reply->contributor_source,cnt), reply->contributor_source[cnt].
   code_value = a.contributor_source_cd,
   reply->contributor_source[cnt].display = c.display
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
