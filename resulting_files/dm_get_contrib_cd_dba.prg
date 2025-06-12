CREATE PROGRAM dm_get_contrib_cd:dba
 RECORD reply(
   1 contributor_sour_cd = f8
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
  cv.code_value
  FROM code_value cv
  WHERE (cv.code_set=request->code_set)
   AND (cv.display=request->contributor_sour_disp)
  DETAIL
   reply->contributor_sour_cd = cv.code_value
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
