CREATE PROGRAM cps_cancel_ord_task:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET failures = 0
 SELECT INTO "nl:"
  ta.*
  FROM task_activity ta,
   (dummyt d  WITH seq = 1)
  PLAN (d)
   JOIN (ta
   WHERE (ta.order_id=request->order_id)
    AND ta.active_ind=1
    AND (ta.task_type_cd=request->task_type_cd)
    AND (ta.task_activity_cd=request->task_activity_cd))
  WITH nocounter, forupdate(ta)
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = lock_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   SET failures = 1
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
  GO TO exit_script
 ENDIF
 UPDATE  FROM task_activity ta,
   (dummyt d  WITH seq = 1)
  SET ta.task_status_cd = request->task_status_cd, ta.updt_dt_tm = cnvtdatetime(curdate,curtime3), ta
   .updt_id = reqinfo->updt_id,
   ta.updt_task = reqinfo->updt_task, ta.updt_cnt = (ta.updt_cnt+ 1), ta.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (ta
   WHERE (ta.order_id=request->order_id)
    AND ta.active_ind=1
    AND (ta.task_type_cd=request->task_type_cd)
    AND (ta.task_activity_cd=request->task_activity_cd))
  WITH nocounter
 ;end update
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTION"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   SET failures = 1
  ENDIF
  GO TO exit_script
 ENDIF
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
