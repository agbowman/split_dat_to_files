CREATE PROGRAM atr_get_req_tasks:dba
 RECORD reply(
   1 qual[*]
     2 task_number = i4
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  r.task_number, at.description
  FROM task_request_r r,
   application_task at
  PLAN (r
   WHERE (r.request_number=request->request_number))
   JOIN (at
   WHERE at.task_number=r.task_number)
  ORDER BY r.task_number
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].task_number = r.task_number, reply->qual[count1].description = at.description
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
