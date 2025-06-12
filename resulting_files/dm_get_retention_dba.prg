CREATE PROGRAM dm_get_retention:dba
 RECORD reply(
   1 qual[*]
     2 criteria_type_cd = f8
     2 retention_days = i4
     2 encntr_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET index = 0
 SET reply->status_data.status = "F"
 SET x = size(request->list,5)
 SELECT INTO "nl:"
  dr.criteria_type_cd, dr.retention_days, dr.encntr_type_cd
  FROM dm_retention_criteria dr,
   (dummyt d  WITH seq = value(x))
  PLAN (d)
   JOIN (dr
   WHERE (dr.organization_id=request->org_id)
    AND (dr.encntr_type_cd=request->list[d.seq].encntr_type_cd))
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].criteria_type_cd = dr
   .criteria_type,
   reply->qual[index].retention_days = dr.retention_days, reply->qual[index].encntr_type_cd = dr
   .encntr_type_cd
  WITH nocounter
 ;end select
 IF (index > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
