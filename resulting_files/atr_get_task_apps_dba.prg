CREATE PROGRAM atr_get_task_apps:dba
 RECORD reply(
   1 qual[*]
     2 application_number = i4
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
  atr.application_number, a.description
  FROM application_task_r atr,
   application a
  PLAN (atr
   WHERE (atr.task_number=request->task_number))
   JOIN (a
   WHERE a.application_number=atr.application_number)
  ORDER BY atr.application_number
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].application_number = atr.application_number, reply->qual[count1].description
    = a.description
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
