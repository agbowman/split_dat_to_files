CREATE PROGRAM dcp_add_timescale:dba
 RECORD reply(
   1 time_scale_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 DECLARE time_scale_id = f8 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  y = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   time_scale_id = y
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 INSERT  FROM time_scale ts
  SET ts.time_scale_id = time_scale_id, ts.time_scale_name = request->time_scale_name, ts
   .time_scale_name_key = trim(cnvtupper(cnvtalphanum(request->time_scale_name))),
   ts.time_scale_type_flag = request->time_scale_type_flag, ts.interval_units_cd = request->
   interval_units_cd, ts.interval_length = request->interval_length,
   ts.interval_label_flag = request->interval_label_flag, ts.nbr_of_intervals = request->
   nbr_of_intervals, ts.time_scale_start_tm = cnvtdatetime(request->time_scale_start_tm),
   ts.time_scale_start_tm_long = request->time_scale_start_tm_long, ts.updt_dt_tm = cnvtdatetime(
    curdate,curtime), ts.updt_id = reqinfo->updt_id,
   ts.updt_task = reqinfo->updt_task, ts.updt_applctx = reqinfo->updt_applctx, ts.updt_cnt = 0
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
  SET reply->time_scale_id = time_scale_id
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
