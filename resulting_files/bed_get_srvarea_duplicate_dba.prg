CREATE PROGRAM bed_get_srvarea_duplicate:dba
 FREE SET reply
 RECORD reply(
   1 srvarea_code_value = f8
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
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.cdf_meaning="SRVAREA"
    AND cnvtupper(cv.display)=cnvtupper(request->srvarea_disp)
    AND cv.active_ind=1)
  DETAIL
   reply->srvarea_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
