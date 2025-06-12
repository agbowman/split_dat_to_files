CREATE PROGRAM atr_get_task_for_app:dba
 RECORD reply(
   1 qual[*]
     2 task_number = i4
     2 description = vc
     2 subordinate_task_ind = i2
     2 active_ind = i2
     2 text = vc
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
  t.task_number
  FROM application_task_r a,
   application_task t
  PLAN (a
   WHERE (a.application_number=request->application_number))
   JOIN (t
   WHERE t.task_number=a.task_number)
  ORDER BY t.task_number
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   CALL echo(t.task_number), reply->qual[count1].task_number = t.task_number, reply->qual[count1].
   description = t.description,
   reply->qual[count1].subordinate_task_ind = t.subordinate_task_ind, reply->qual[count1].active_ind
    = t.active_ind, reply->qual[count1].text = t.text
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
