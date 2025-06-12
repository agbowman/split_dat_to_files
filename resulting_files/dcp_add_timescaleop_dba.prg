CREATE PROGRAM dcp_add_timescaleop:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 INSERT  FROM time_scale_op ts
  SET ts.time_scale_id = request->time_scale_id, ts.time_scale_op_idx = request->time_scale_op_idx,
   ts.operation_flag = request->operation_flag,
   ts.operation_disp_name = request->operation_disp_name, ts.operation_start_interval = request->
   operation_start_interval, ts.operation_end_interval = request->operation_end_interval,
   ts.operation_placement_flag = request->operation_placement_flag, ts.updt_dt_tm = cnvtdatetime(
    curdate,curtime), ts.updt_id = reqinfo->updt_id,
   ts.updt_task = 600006, ts.updt_applctx = 600002, ts.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "timescale table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
