CREATE PROGRAM dcp_get_pregnancy_problemid:dba
 RECORD reply(
   1 problem_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->problem_id = 0.0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM pregnancy_instance p
  WHERE (p.pregnancy_id=request->pregnancy_id)
   AND p.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
  DETAIL
   reply->problem_id = p.problem_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
