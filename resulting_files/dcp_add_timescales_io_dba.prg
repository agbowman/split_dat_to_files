CREATE PROGRAM dcp_add_timescales_io:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 DECLARE timecounter = i4
 SET timecounter = size(request->qual,5)
 IF (timecounter=0)
  GO TO exit_script
 ENDIF
 INSERT  FROM time_scale_op tsp,
   (dummyt d1  WITH seq = value(timecounter))
  SET tsp.time_scale_id = request->qual[d1.seq].time_scale_id, tsp.time_scale_op_idx = request->qual[
   d1.seq].time_scale_op_idx, tsp.operation_flag = request->qual[d1.seq].operation_flag,
   tsp.operation_disp_name = request->qual[d1.seq].operation_disp_name, tsp.operation_start_interval
    = request->qual[d1.seq].operation_start_interval, tsp.operation_end_interval = request->qual[d1
   .seq].operation_end_interval,
   tsp.operation_placement_flag = request->qual[d1.seq].operation_placement_flag, tsp.updt_dt_tm =
   cnvtdatetime(curdate,curtime), tsp.updt_id = reqinfo->updt_id,
   tsp.updt_task = reqinfo->updt_task, tsp.updt_applctx = reqinfo->updt_applctx
  PLAN (d1)
   JOIN (tsp)
  WITH counter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "time_scale_op  table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO INSERT"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
