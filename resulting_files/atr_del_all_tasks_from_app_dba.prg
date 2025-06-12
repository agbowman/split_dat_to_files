CREATE PROGRAM atr_del_all_tasks_from_app:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET insert_count = 0
 SET update_count = 0
 SET i = size(reply->status_data.subeventstatus,5)
 SUBROUTINE result_status(opname,opstat,targetname,targetvalue)
   SET stat = alter(reply->status_data.subeventstatus[i],i)
   SET reply->status_data.subeventstatus[i].operationname = opname
   SET reply->status_data.subeventstatus[i].operationstatus = opstat
   SET reply->status_data.subeventstatus[i].targetobjectname = targetname
   SET reply->status_data.subeventstatus[i].targetobjectvalue = targetvalue
   SET i += 1
 END ;Subroutine
 IF ((request->feature_number=0))
  DELETE  FROM application_task_r t
   WHERE (t.application_number=request->application_number)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL result_status("delete","F","application_task_r","delete failed")
   ROLLBACK
  ELSE
   COMMIT
   SET reply->status_data.status = "S"
  ENDIF
  GO TO exit_script
 ELSE
  RECORD task(
    1 t[*]
      2 task_number = f8
      2 status = i2
    1 cnt = i4
  )
  SET stat = alterlist(task->t,0)
  SET task->cnt = 0
  SELECT INTO "nl:"
   FROM application_task_r t
   WHERE (t.application_number=request->application_number)
   HEAD REPORT
    task->cnt = 0, cnt = 0
   DETAIL
    task->cnt += 1, cnt = task->cnt, stat = alterlist(task->t,cnt),
    task->t[cnt].task_number = t.task_number, task->t[cnt].status = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM dm_application_task_r t,
    (dummyt d  WITH seq = value(task->cnt))
   PLAN (d)
    JOIN (t
    WHERE (t.application_number=request->application_number)
     AND (t.task_number=task->t[d.seq].task_number)
     AND (t.feature_number=request->feature_number))
   DETAIL
    task->t[d.seq].status = 1
   WITH nocounter
  ;end select
  UPDATE  FROM dm_application_task_r t,
    (dummyt d  WITH seq = value(task->cnt))
   SET t.seq = 1, t.deleted_ind = 1, t.schema_date = cnvtdatetimeutc(request->schema_date,2),
    t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->
    updt_id,
    t.updt_cnt = 0, t.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (task->t[d.seq].status=1))
    JOIN (t
    WHERE (t.application_number=request->application_number)
     AND (t.feature_number=request->feature_number)
     AND (t.task_number=task->t[d.seq].task_number))
   WITH nocounter
  ;end update
  SET update_count = curqual
  IF ((update_count=task->cnt))
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
   COMMIT
   GO TO exit_script
  ELSE
   INSERT  FROM dm_application_task_r r,
     (dummyt d  WITH seq = value(task->cnt))
    SET r.seq = 1, r.application_number = request->application_number, r.task_number = request->qual[
     d.seq].task_number,
     r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->
     updt_task,
     r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx, r.feature_number = request->
     feature_number,
     r.schema_date = cnvtdatetimeutc(request->schema_date,2), r.deleted_ind = 1
    PLAN (d
     WHERE (status->qual[d.seq].status=0))
     JOIN (r)
    WITH nocounter
   ;end insert
   SET insert_count = curqual
  ENDIF
  IF (((update_count+ insert_count)=task->cnt))
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
   COMMIT
  ELSE
   CALL result_status("Update","F","dm_application_task_r","Failure updating.")
   SET reqinfo->commit_ind = 0
   ROLLBACK
  ENDIF
 ENDIF
#exit_script
END GO
