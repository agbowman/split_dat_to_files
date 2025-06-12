CREATE PROGRAM atr_get_req_for_task_n:dba
 RECORD reply(
   1 qual[1]
     2 request_number = i4
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
 SET stat = alter(reply->qual,request->number_to_get)
 SET x = 1
 SET last_number = (request->start_number - 1)
 SELECT INTO "nl:"
  r.request_number, r.description
  FROM task_request_r t,
   request r
  PLAN (t
   WHERE (request->task_number=t.task_number))
   JOIN (r
   WHERE t.request_number=r.request_number
    AND last_number < r.request_number)
  ORDER BY r.request_number
  DETAIL
   count1 += 1, reply->qual[count1].request_number = r.request_number, reply->qual[count1].
   description = r.description,
   last_number = r.request_number
  WITH nocounter, maxqual(t,value(request->number_to_get))
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "task_request_r"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "none qualified"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((count1 != request->number_to_get))
  SET stat = alter(reply->qual,count1)
 ENDIF
END GO
