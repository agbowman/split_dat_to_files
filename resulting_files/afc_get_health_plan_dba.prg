CREATE PROGRAM afc_get_health_plan:dba
 RECORD reply(
   1 health_plan_qual = i4
   1 health_plan[*]
     2 plan_name = vc
     2 health_plan_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET stat = alterlist(reply->health_plan,(count1+ 10))
 SELECT INTO "nl:"
  FROM health_plan h
  WHERE h.active_ind=1
  ORDER BY h.plan_name
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->health_plan,(count1+ 10))
   ENDIF
   reply->health_plan[count1].plan_name = h.plan_name, reply->health_plan[count1].health_plan_id = h
   .health_plan_id
  WITH nocounter
 ;end select
 SET reply->health_plan_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "HEALTH_PLAN"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
