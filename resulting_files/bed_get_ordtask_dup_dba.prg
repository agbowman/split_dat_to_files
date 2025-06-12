CREATE PROGRAM bed_get_ordtask_dup:dba
 FREE SET reply
 RECORD reply(
   1 tasks[*]
     2 description = vc
     2 duplicate_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->tasks,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->tasks,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->tasks[x].description = request->tasks[x].description
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   order_task o
  PLAN (d)
   JOIN (o
   WHERE o.task_description_key=cnvtupper(reply->tasks[d.seq].description)
    AND o.cernertask_flag=0)
  ORDER BY d.seq
  DETAIL
   reply->tasks[d.seq].duplicate_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
