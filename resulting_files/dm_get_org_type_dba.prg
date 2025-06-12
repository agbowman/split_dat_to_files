CREATE PROGRAM dm_get_org_type:dba
 RECORD reply(
   1 client_cd = f8
   1 facility_cd = f8
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
  WHERE cv.code_set=278
   AND ((cv.cdf_meaning="FACILITY") OR (cv.cdf_meaning="CLIENT"
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND cv.active_ind=1))
  DETAIL
   IF (cv.cdf_meaning="CLIENT")
    reply->client_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="FACILITY")
    reply->facility_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
