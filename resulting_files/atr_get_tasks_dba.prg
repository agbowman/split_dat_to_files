CREATE PROGRAM atr_get_tasks:dba
 RECORD reply(
   1 qual[10]
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
 SET stat = alter(reply->qual,request->number_to_get)
 SET last_number = (request->start_number - 1)
 SELECT INTO "nl:"
  t.task_number, t.description
  FROM application_task t
  WHERE t.task_number > last_number
  ORDER BY t.task_number
  DETAIL
   count1 += 1, reply->qual[count1].task_number = t.task_number, reply->qual[count1].description = t
   .description
  WITH nocounter, maxqual(t,value(request->number_to_get))
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((count1 != request->number_to_get))
  SET stat = alter(reply->qual,count1)
 ENDIF
END GO
