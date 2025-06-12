CREATE PROGRAM dcp_get_defaulting_scripts:dba
 RECORD reply(
   1 qual[5]
     2 request_name = vc
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
 SET stat = 0
 SELECT INTO "nl:"
  r.request_number, r.description, r.request_name
  FROM task_request_r t,
   request r
  PLAN (t
   WHERE t.task_number=600532)
   JOIN (r
   WHERE  NOT (t.request_number=600532)
    AND t.request_number=r.request_number)
  DETAIL
   count1 = (count1+ 1), reply->qual[count1].request_name = r.request_name, reply->qual[count1].
   description = r.description
  WITH nocounter
 ;end select
 SET stat = alter(reply->qual,count1)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "task_request_r"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "none qualified"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(count1)
END GO
