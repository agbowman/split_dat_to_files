CREATE PROGRAM dcp_get_timescale:dba
 RECORD reply(
   1 time_scale_id = f8
   1 time_scale_name_key = vc
   1 time_scale_type_flag = i2
   1 interval_units_cd = f8
   1 interval_units_disp = c40
   1 interval_units_desc = vc
   1 interval_units_mean = c12
   1 interval_length = i4
   1 interval_label_flag = i2
   1 nbr_of_intervals = i4
   1 time_scale_start_tm = dq8
   1 time_scale_start_tm_long = i4
   1 oper[*]
     2 time_scale_op_idx = i4
     2 operation_flag = i2
     2 operation_disp_name = vc
     2 operation_start_interval = i4
     2 operation_end_interval = i4
     2 operation_placement_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  FROM time_scale ts,
   time_scale_op tso
  PLAN (ts
   WHERE (((ts.time_scale_id=request->time_scale_id)
    AND ts.time_scale_id != 0) OR (ts.time_scale_name_key=cnvtupper(patstring(request->
     time_scale_name)))) )
   JOIN (tso
   WHERE outerjoin(ts.time_scale_id)=tso.time_scale_id)
  ORDER BY tso.time_scale_op_idx
  HEAD REPORT
   reply->time_scale_id = ts.time_scale_id, reply->time_scale_name_key = ts.time_scale_name_key,
   reply->time_scale_type_flag = ts.time_scale_type_flag,
   reply->interval_units_cd = ts.interval_units_cd, reply->interval_length = ts.interval_length,
   reply->interval_label_flag = ts.interval_label_flag,
   reply->nbr_of_intervals = ts.nbr_of_intervals, reply->time_scale_start_tm = cnvtdatetime(ts
    .time_scale_start_tm), reply->time_scale_start_tm_long = ts.time_scale_start_tm_long
  DETAIL
   IF (tso.time_scale_id > 0)
    count1 = (count1+ 1)
    IF (mod(count1,5)=1)
     stat = alterlist(reply->oper,(count1+ 4))
    ENDIF
    reply->oper[count1].time_scale_op_idx = tso.time_scale_op_idx, reply->oper[count1].operation_flag
     = tso.operation_flag, reply->oper[count1].operation_disp_name = trim(tso.operation_disp_name),
    reply->oper[count1].operation_start_interval = tso.operation_start_interval, reply->oper[count1].
    operation_end_interval = tso.operation_end_interval, reply->oper[count1].operation_placement_flag
     = tso.operation_placement_flag
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->oper,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
