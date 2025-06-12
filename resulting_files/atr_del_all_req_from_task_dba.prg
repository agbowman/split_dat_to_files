CREATE PROGRAM atr_del_all_req_from_task:dba
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
  DELETE  FROM task_request_r r
   WHERE (r.task_number=request->task_number)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL result_status("delete","F","task_request_r","delete failed")
   ROLLBACK
  ELSE
   COMMIT
   SET reply->status_data.status = "S"
  ENDIF
  GO TO exit_script
 ELSE
  RECORD req(
    1 r[*]
      2 request_number = f8
      2 status = i2
    1 cnt = i4
  )
  SET stat = alterlist(req->r,0)
  SET req->cnt = 0
  SELECT INTO "nl:"
   FROM task_request_r r
   WHERE (r.task_number=request->task_number)
   HEAD REPORT
    req->cnt = 0, cnt = 0
   DETAIL
    req->cnt += 1, cnt = req->cnt, stat = alterlist(req->r,cnt),
    req->r[cnt].request_number = r.request_number, req->r[cnt].status = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM dm_task_request_r r,
    (dummyt d  WITH seq = value(req->cnt))
   PLAN (d)
    JOIN (r
    WHERE (r.task_number=request->task_number)
     AND (r.request_number=req->r[d.seq].request_number)
     AND (r.feature_number=request->feature_number))
   DETAIL
    req->r[d.seq].status = 1
   WITH nocounter
  ;end select
  UPDATE  FROM dm_task_request_r r,
    (dummyt d  WITH seq = value(req->cnt))
   SET r.seq = 1, r.deleted_ind = 1, r.schema_date = cnvtdatetimeutc(request->schema_date,2),
    r.updt_cnt = (r.updt_cnt+ 1), r.updt_id = reqinfo->updt_id, r.updt_dt_tm = cnvtdatetime(sysdate),
    r.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (req->r[d.seq].status=1))
    JOIN (r
    WHERE (r.task_number=request->task_number)
     AND (r.feature_number=request->feature_number)
     AND (r.request_number=req->r[d.seq].request_number))
   WITH nocounter
  ;end update
  SET update_count = curqual
  IF ((update_count=req->cnt))
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
   COMMIT
   GO TO exit_script
  ELSE
   INSERT  FROM dm_task_request_r r,
     (dummyt d  WITH seq = value(req->cnt))
    SET r.seq = 1, r.task_number = request->task_number, r.request_number = request->qual[d.seq].
     request_number,
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
  IF (((update_count+ insert_count)=req->cnt))
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
   COMMIT
  ELSE
   CALL result_status("Update","F","dm_task_request_r","Failure updating.")
   SET reqinfo->commit_ind = 0
   ROLLBACK
  ENDIF
 ENDIF
#exit_script
END GO
