CREATE PROGRAM dm_atr_task_req_import:dba
 FREE SET status
 RECORD status(
   1 qual[*]
     2 exist = i1
 )
 SET stat = alterlist(status->qual,request->atr_count)
 CALL echo("Importing Task-Request relations into clinical tables...")
 SELECT INTO "nl:"
  tr.request_number
  FROM task_request_r tr,
   (dummyt d  WITH seq = value(request->atr_count))
  PLAN (d)
   JOIN (tr
   WHERE (tr.task_number=request->atr_list[d.seq].task_number)
    AND (tr.request_number=request->atr_list[d.seq].request_number))
  DETAIL
   status->qual[d.seq].exist = 1
  WITH nocounter
 ;end select
 CALL echo("  Inserting new Task-Request relations into clinical tables...")
 INSERT  FROM task_request_r tr,
   (dummyt d  WITH seq = value(request->atr_count))
  SET tr.seq = 1, tr.task_number = request->atr_list[d.seq].task_number, tr.request_number = request
   ->atr_list[d.seq].request_number,
   tr.updt_dt_tm = cnvtdatetime(curdate,curtime3), tr.updt_id = 0.0, tr.updt_task = 0,
   tr.updt_cnt = 0, tr.updt_applctx = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=0)
    AND (request->atr_list[d.seq].deleted_ind != 1))
   JOIN (tr)
  WITH nocounter, status(status->qual)
 ;end insert
 CALL echo("  Deleting unwanted Task-Request relations from clinical tables...")
 DELETE  FROM task_request_r tr,
   (dummyt d  WITH seq = value(request->atr_count))
  SET tr.seq = 1
  PLAN (d
   WHERE (request->atr_list[d.seq].deleted_ind=1)
    AND (status->qual[d.seq].exist=1))
   JOIN (tr
   WHERE (tr.task_number=request->atr_list[d.seq].task_number)
    AND (tr.request_number=request->atr_list[d.seq].request_number))
 ;end delete
 COMMIT
END GO
