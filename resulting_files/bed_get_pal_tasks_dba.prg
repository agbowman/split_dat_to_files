CREATE PROGRAM bed_get_pal_tasks:dba
 FREE SET reply
 RECORD reply(
   1 tasks[*]
     2 id = f8
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
 SET cnt = 0
 SELECT INTO "nl:"
  FROM order_task o
  PLAN (o
   WHERE (o.task_type_cd=request->task_type_code_value)
    AND o.active_ind=1)
  ORDER BY o.task_description
  HEAD o.task_description
   cnt = (cnt+ 1), stat = alterlist(reply->tasks,cnt), reply->tasks[cnt].id = o.reference_task_id,
   reply->tasks[cnt].description = o.task_description
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
