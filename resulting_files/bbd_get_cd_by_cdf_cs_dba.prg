CREATE PROGRAM bbd_get_cd_by_cdf_cs:dba
 RECORD reply(
   1 code_value = f8
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
  c.*
  FROM code_value c
  PLAN (c
   WHERE (c.code_set=request->code_set)
    AND cnvtdatetime(curdate,curtime3) >= c.begin_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= c.end_effective_dt_tm
    AND c.active_ind=1
    AND (c.cdf_meaning=request->cdf_meaning))
  DETAIL
   reply->code_value = c.code_value
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
