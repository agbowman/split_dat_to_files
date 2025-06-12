CREATE PROGRAM dcp_get_timescales_info:dba
 RECORD reply(
   1 qual[*]
     2 time_scale_type_flag = i2
     2 interval_units_cd = f8
     2 interval_length = f8
     2 time_scale_id = f8
     2 nbr_of_intervals = i4
     2 time_scale_start_tm = dq8
     2 time_scale_start_tm_long = i4
     2 interval_label_flag = i2
     2 oper[*]
       3 time_scale_op_idx = i4
       3 operation_flag = i2
       3 operation_disp_name = vc
       3 operation_start_interval = i4
       3 operation_end_interval = i4
       3 operation_placement_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET qualcnt = 0
 SET opercnt = 0
 SELECT INTO "nl:"
  ts.time_scale_type_flag, ts.interval_units_cd, ts.interval_length,
  ts.time_scale_id, ts.nbr_of_intervals, ts.time_scale_start_tm,
  ts.time_scale_start_tm_long, tso.time_scale_op_idx, tso.operation_flag,
  tso.operation_disp_name, tso.operation_start_interval, tso.operation_end_interval,
  tso.operation_placement_flag
  FROM time_scale ts,
   (dummyt d1  WITH seq = 1),
   time_scale_op tso
  PLAN (ts
   WHERE ts.time_scale_name_key=cnvtalphanum(cnvtupper(request->time_scale_name)))
   JOIN (d1)
   JOIN (tso
   WHERE ts.time_scale_id=tso.time_scale_id)
  ORDER BY tso.time_scale_op_idx
  HEAD REPORT
   qualcnt = (qualcnt+ 1)
   IF (qualcnt > size(reply->qual,5))
    stat = alterlist(reply->qual,qualcnt)
   ENDIF
   reply->qual[qualcnt].time_scale_type_flag = ts.time_scale_type_flag, reply->qual[qualcnt].
   interval_units_cd = ts.interval_units_cd, reply->qual[qualcnt].interval_length = ts
   .interval_length,
   reply->qual[qualcnt].time_scale_id = ts.time_scale_id, reply->qual[qualcnt].nbr_of_intervals = ts
   .nbr_of_intervals, reply->qual[qualcnt].time_scale_start_tm = cnvtdatetime(ts.time_scale_start_tm),
   reply->qual[qualcnt].time_scale_start_tm_long = ts.time_scale_start_tm_long, reply->qual[qualcnt].
   interval_label_flag = ts.interval_label_flag
  DETAIL
   IF (tso.time_scale_id > 0)
    opercnt = (opercnt+ 1)
    IF (opercnt > size(reply->qual[qualcnt].oper,5))
     stat = alterlist(reply->qual[qualcnt].oper,opercnt)
    ENDIF
    reply->qual[qualcnt].oper[opercnt].time_scale_op_idx = tso.time_scale_op_idx, reply->qual[qualcnt
    ].oper[opercnt].operation_flag = tso.operation_flag, reply->qual[qualcnt].oper[opercnt].
    operation_disp_name = tso.operation_disp_name,
    reply->qual[qualcnt].oper[opercnt].operation_start_interval = tso.operation_start_interval, reply
    ->qual[qualcnt].oper[opercnt].operation_end_interval = tso.operation_end_interval, reply->qual[
    qualcnt].oper[opercnt].operation_placement_flag = tso.operation_placement_flag
   ENDIF
  WITH counter, outerjoin = d1
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP TimeScale Tool"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO RETRIEVE"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
