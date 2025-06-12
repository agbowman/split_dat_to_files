CREATE PROGRAM atr_get_req_for_task:dba
 RECORD reply(
   1 qual[*]
     2 request_number = i4
     2 description = vc
     2 active_ind = i2
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
  r.request_number
  FROM task_request_r t,
   request r
  PLAN (t
   WHERE (request->task_number=t.task_number)
    AND 0 < t.task_number)
   JOIN (r
   WHERE t.request_number=r.request_number
    AND 0 < r.request_number)
  ORDER BY r.request_number
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].request_number = r.request_number, reply->qual[count1].description = r
   .description, reply->qual[count1].active_ind = r.active_ind
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
