CREATE PROGRAM atr_del_req:dba
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
 SET i = size(reply->status_data.subeventstatus,5)
 SUBROUTINE result_status(opname,opstat,targetname,targetvalue)
   SET stat = alter(reply->status_data.subeventstatus,i)
   SET reply->status_data.subeventstatus[i].operationname = opname
   SET reply->status_data.subeventstatus[i].operationstatus = opstat
   SET reply->status_data.subeventstatus[i].targetobjectname = targetname
   SET reply->status_data.subeventstatus[i].targetobjectvalue = targetvalue
   SET i += 1
 END ;Subroutine
 IF ((request->feature_number=0))
  DELETE  FROM task_request_r t
   WHERE (t.request_number=request->request_number)
   WITH nocounter
  ;end delete
  DELETE  FROM request r
   WHERE (r.request_number=request->request_number)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL result_status("Delete","F","request","Delete failed")
   SET reqinfo->commit_ind = 0
  ENDIF
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
   FROM task_request_r t
   WHERE (t.request_number=request->request_number)
   HEAD REPORT
    task->cnt = 0, cnt = 0
   DETAIL
    task->cnt += 1, cnt = task->cnt, stat = alterlist(task->t,cnt),
    task->t[cnt].task_number = t.task_number, task->t[cnt].status = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM dm_task_request_r t,
    (dummyt d  WITH seq = value(task->cnt))
   PLAN (d)
    JOIN (t
    WHERE (t.request_number=request->request_number)
     AND (t.task_number=task->t[d.seq].task_number)
     AND (t.feature_number=request->feature_number))
   DETAIL
    task->t[d.seq].status = 1
   WITH nocounter
  ;end select
  UPDATE  FROM dm_task_request_r t,
    (dummyt d  WITH seq = value(task->cnt))
   SET t.seq = 1, t.deleted_ind = 1, t.schema_date = cnvtdatetimeutc(request->schema_date,2),
    t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->
    updt_id,
    t.updt_cnt = 0, t.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (task->t[d.seq].status=1))
    JOIN (t
    WHERE (t.request_number=request->request_number)
     AND (t.feature_number=request->feature_number)
     AND (t.task_number=task->t[d.seq].task_number))
   WITH nocounter
  ;end update
  INSERT  FROM dm_task_request_r r,
    (dummyt d  WITH seq = value(task->cnt))
   SET r.seq = 1, r.request_number = request->request_number, r.task_number = task->t[d.seq].
    task_number,
    r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->
    updt_task,
    r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx, r.feature_number = request->
    feature_number,
    r.schema_date = cnvtdatetimeutc(request->schema_date,2), r.deleted_ind = 1
   PLAN (d
    WHERE (task->t[d.seq].status=0))
    JOIN (r)
   WITH nocounter
  ;end insert
  SELECT INTO "nl:"
   r.request_number
   FROM dm_request r
   WHERE (r.request_number=request->request_number)
    AND (r.feature_number=request->feature_number)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM dm_request a
    SET a.deleted_ind = 1, a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_task = reqinfo->updt_task,
     a.updt_id = reqinfo->updt_id, a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx,
     a.schema_date = cnvtdatetimeutc(request->schema_date,2)
    WHERE (a.request_number=request->request_number)
     AND (a.feature_number=request->feature_number)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL result_status("Update","F","dm_request","Update failed.")
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
  ELSE
   INSERT  FROM dm_request r
    SET r.request_number = request->request_number, r.description = "", r.deleted_ind = 1,
     r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_task = reqinfo->updt_task, r.updt_id = reqinfo->
     updt_id,
     r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx, r.feature_number = request->
     feature_number,
     r.schema_date = cnvtdatetimeutc(request->schema_date,2)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL result_status("Insert","F","dm_request","Insert failed.")
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
