CREATE PROGRAM bbd_get_valid_task_req:dba
 RECORD reply(
   1 valid_nbr = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET failed = "F"
 SELECT INTO "nl:"
  r.request_number
  FROM request r,
   task_request_r t
  PLAN (r
   WHERE (r.request_number=request->req_nbr))
   JOIN (t
   WHERE t.request_number=r.request_number
    AND (t.task_number=request->task_nbr))
  DETAIL
   reply->valid_nbr = 1
  WITH counter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->valid_nbr = 0
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_get_valid_task_req"
  SET reply->status_data.subeventstatus[1].operationname = "get"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_REQUEST_R"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "get from task_request_r"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
 ENDIF
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "Z"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
