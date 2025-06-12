CREATE PROGRAM dm_get_contrib_display:dba
 RECORD reply(
   1 contributor_display = c100
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
  cv.display
  FROM code_value cv
  WHERE (cv.code_value=request->contributor_source_cd)
  DETAIL
   reply->contributor_display = cv.display
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
