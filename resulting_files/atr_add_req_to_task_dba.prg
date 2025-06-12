CREATE PROGRAM atr_add_req_to_task:dba
 RECORD status(
   1 qual[*]
     2 status = i1
 )
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
 SET number_to_add = size(request->qual,5)
 SET stat = alterlist(status->qual,number_to_add)
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
  SELECT INTO "nl:"
   tr.request_number
   FROM task_request_r tr,
    (dummyt d  WITH seq = value(number_to_add))
   PLAN (d)
    JOIN (tr
    WHERE (tr.task_number=request->task_number)
     AND (tr.request_number=request->qual[d.seq].request_number))
   DETAIL
    status->qual[d.seq].status = 1
   WITH nocounter
  ;end select
  INSERT  FROM task_request_r r,
    (dummyt d  WITH seq = value(number_to_add))
   SET r.seq = 1, r.task_number = request->task_number, r.request_number = request->qual[d.seq].
    request_number,
    r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->
    updt_task,
    r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (status->qual[d.seq].status=0))
    JOIN (r)
   WITH nocounter, status(status->qual)
  ;end insert
  IF (curqual=number_to_add)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ELSE
   SET reqinfo->commit_ind = 0
  ENDIF
 ELSE
  SELECT INTO "nl:"
   tr.request_number
   FROM dm_task_request_r tr,
    (dummyt d  WITH seq = value(number_to_add))
   PLAN (d)
    JOIN (tr
    WHERE (tr.task_number=request->task_number)
     AND (tr.request_number=request->qual[d.seq].request_number)
     AND (tr.feature_number=request->feature_number))
   DETAIL
    status->qual[d.seq].status = 1
   WITH nocounter
  ;end select
  INSERT  FROM dm_task_request_r r,
    (dummyt d  WITH seq = value(number_to_add))
   SET r.seq = 1, r.task_number = request->task_number, r.request_number = request->qual[d.seq].
    request_number,
    r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->
    updt_task,
    r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx, r.feature_number = request->
    feature_number,
    r.schema_date = cnvtdatetimeutc(request->schema_date,2), r.deleted_ind = 0
   PLAN (d
    WHERE (status->qual[d.seq].status=0))
    JOIN (r)
   WITH nocounter
  ;end insert
  IF (curqual=number_to_add)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
   GO TO exit_script
  ENDIF
  SET insert_count = curqual
  UPDATE  FROM dm_task_request_r r,
    (dummyt d  WITH seq = value(number_to_add))
   SET r.seq = 1, r.task_number = request->task_number, r.request_number = request->qual[d.seq].
    request_number,
    r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->
    updt_task,
    r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx, r.feature_number = request->
    feature_number,
    r.schema_date = cnvtdatetimeutc(request->schema_date,2), r.deleted_ind = 0
   PLAN (d
    WHERE (status->qual[d.seq].status=1))
    JOIN (r
    WHERE (r.task_number=request->task_number)
     AND (r.request_number=request->qual[d.seq].request_number)
     AND (r.feature_number=request->feature_number))
   WITH nocounter
  ;end update
  SET update_count = curqual
  IF ((number_to_add=(insert_count+ update_count)))
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ELSE
   CALL result_status("Update","F","dm_task_request_r","Failure updating.")
   SET reqinfo->commit_ind = 0
  ENDIF
 ENDIF
#exit_script
END GO
