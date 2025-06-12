CREATE PROGRAM atr_get_task_for_app_n:dba
 RECORD reply(
   1 qual[1]
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
 SET x = 1
 SET stat = alter(reply->qual,request->number_to_get)
 SET last_number = (request->start_number - 1)
 SELECT INTO "nl:"
  t.task_number, t.description
  FROM application_task t,
   application_task_r a
  PLAN (a
   WHERE (request->application_number=a.application_number))
   JOIN (t
   WHERE t.task_number=a.task_number
    AND t.task_number > last_number)
  ORDER BY t.task_number
  DETAIL
   count1 += 1, reply->qual[count1].task_number = t.task_number, reply->qual[count1].description = t
   .description,
   last_number = t.task_number
  WITH nocounter, maxqual(a,value(request->number_to_get))
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "application_task_r"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((count1 != request->number_to_get))
  SET stat = alter(reply->qual,count1)
 ENDIF
END GO
