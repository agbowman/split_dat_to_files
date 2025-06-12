CREATE PROGRAM dcp_get_interps_for_dta:dba
 RECORD reply(
   1 cnt = i4
   1 qual[*]
     2 dcp_interp_id = f8
     2 sex_cd = f8
     2 age_from_minutes = f8
     2 age_to_minutes = f8
     2 service_resource_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM dcp_interp i
  WHERE (i.task_assay_cd=request->task_assay_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].dcp_interp_id = i.dcp_interp_id, reply->qual[cnt].sex_cd = i.sex_cd, reply->qual[
   cnt].age_from_minutes = i.age_from_minutes,
   reply->qual[cnt].age_to_minutes = i.age_to_minutes, reply->qual[cnt].service_resource_cd = i
   .service_resource_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->qual,cnt)
END GO
