CREATE PROGRAM atr_del_task:dba
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
  DELETE  FROM application_task_r a
   WHERE (a.task_number=request->task_number)
   WITH nocounter
  ;end delete
  DELETE  FROM task_request_r r
   WHERE (r.task_number=request->task_number)
   WITH nocounter
  ;end delete
  DELETE  FROM task_access ta
   WHERE (ta.task_number=request->task_number)
   WITH nocounter
  ;end delete
  DELETE  FROM application_task t
   WHERE (t.task_number=request->task_number)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL result_status("Delete","F","application_task","Delete failed.")
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
 ELSE
  RECORD app(
    1 a[*]
      2 application_number = f8
      2 status = i2
    1 cnt = i4
  )
  SET stat = alterlist(app->a,0)
  SET app->cnt = 0
  SELECT INTO "nl:"
   FROM application_task_r t
   WHERE (t.task_number=request->task_number)
   HEAD REPORT
    app->cnt = 0, cnt = 0
   DETAIL
    app->cnt += 1, cnt = app->cnt, stat = alterlist(app->a,cnt),
    app->a[cnt].application_number = t.application_number, app->a[cnt].status = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM dm_application_task_r t,
    (dummyt d  WITH seq = value(app->cnt))
   PLAN (d)
    JOIN (t
    WHERE (t.task_number=request->task_number)
     AND (t.application_number=app->a[d.seq].application_number)
     AND (t.feature_number=request->feature_number))
   DETAIL
    app->a[d.seq].status = 1
   WITH nocounter
  ;end select
  UPDATE  FROM dm_application_task_r t,
    (dummyt d  WITH seq = value(app->cnt))
   SET t.seq = 1, t.deleted_ind = 1, t.schema_date = cnvtdatetimeutc(request->schema_date,2),
    t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->
    updt_id,
    t.updt_cnt = 0, t.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (app->a[d.seq].status=1))
    JOIN (t
    WHERE (t.task_number=request->task_number)
     AND (t.feature_number=request->feature_number)
     AND (t.application_number=app->a[d.seq].application_number))
   WITH nocounter
  ;end update
  INSERT  FROM dm_application_task_r r,
    (dummyt d  WITH seq = value(app->cnt))
   SET r.seq = 1, r.application_number = app->a[d.seq].application_number, r.task_number = request->
    task_number,
    r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->
    updt_task,
    r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx, r.feature_number = request->
    feature_number,
    r.schema_date = cnvtdatetimeutc(request->schema_date,2), r.deleted_ind = 1
   PLAN (d
    WHERE (app->a[d.seq].status=0))
    JOIN (r)
   WITH nocounter
  ;end insert
  RECORD req(
    1 r[*]
      2 request_number = f8
      2 status = i2
    1 cnt = i4
  )
  SET stat = alterlist(req->r,0)
  SET req->cnt = 0
  SELECT INTO "nl:"
   FROM task_request_r t
   WHERE (t.task_number=request->task_number)
   HEAD REPORT
    req->cnt = 0, cnt = 0
   DETAIL
    req->cnt += 1, cnt = req->cnt, stat = alterlist(req->r,cnt),
    req->r[cnt].request_number = t.request_number, req->r[cnt].status = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM dm_task_request_r t,
    (dummyt d  WITH seq = value(req->cnt))
   PLAN (d)
    JOIN (t
    WHERE (t.task_number=request->task_number)
     AND (t.request_number=req->r[d.seq].request_number)
     AND (t.feature_number=request->feature_number))
   DETAIL
    req->r[d.seq].status = 1
   WITH nocounter
  ;end select
  UPDATE  FROM dm_task_request_r t,
    (dummyt d  WITH seq = value(req->cnt))
   SET t.seq = 1, t.deleted_ind = 1, t.schema_date = cnvtdatetimeutc(request->schema_date,2),
    t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->
    updt_id,
    t.updt_cnt = 0, t.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (req->r[d.seq].status=1))
    JOIN (t
    WHERE (t.task_number=request->task_number)
     AND (t.feature_number=request->feature_number)
     AND (t.request_number=req->r[d.seq].request_number))
   WITH nocounter
  ;end update
  INSERT  FROM dm_task_request_r r,
    (dummyt d  WITH seq = value(req->cnt))
   SET r.seq = 1, r.request_number = req->r[d.seq].request_number, r.task_number = request->
    task_number,
    r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->
    updt_task,
    r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx, r.feature_number = request->
    feature_number,
    r.schema_date = cnvtdatetimeutc(request->schema_date,2), r.deleted_ind = 1
   PLAN (d
    WHERE (req->r[d.seq].status=0))
    JOIN (r)
   WITH nocounter
  ;end insert
  SELECT INTO "nl:"
   t.task_number
   FROM dm_application_task t
   WHERE (t.task_number=request->task_number)
    AND (t.feature_number=request->feature_number)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   DELETE  FROM task_access t
    WHERE (t.task_number=request->task_number)
    WITH nocounter
   ;end delete
   UPDATE  FROM dm_application_task a
    SET a.deleted_ind = 1, a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_task = reqinfo->updt_task,
     a.updt_id = reqinfo->updt_id, a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx,
     a.schema_date = cnvtdatetimeutc(request->schema_date,2)
    WHERE (a.task_number=request->task_number)
     AND (a.feature_number=request->feature_number)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL result_status("Update","F","dm_application_task","Update failed.")
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
  ELSE
   INSERT  FROM dm_application_task t
    SET t.task_number = request->task_number, t.description = "", t.deleted_ind = 1,
     t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->
     updt_id,
     t.updt_cnt = 0, t.updt_applctx = reqinfo->updt_applctx, t.feature_number = request->
     feature_number,
     t.schema_date = cnvtdatetimeutc(request->schema_date,2)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL result_status("Insert","F","dm_application_task","Insert failed.")
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
