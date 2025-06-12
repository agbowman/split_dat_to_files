CREATE PROGRAM dcp_get_ino_time_scale_list:dba
 RECORD reply(
   1 time_scale_list[*]
     2 time_scale_name = c60
     2 time_scale_name_key = c60
     2 time_scale_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  FROM time_scale ts,
   time_scale_op tso
  PLAN (ts
   WHERE ts.time_scale_id > 0.0)
   JOIN (tso
   WHERE ts.time_scale_id=tso.time_scale_id)
  ORDER BY ts.time_scale_id
  HEAD REPORT
   count = 0
  HEAD ts.time_scale_id
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->time_scale_list,(count+ 9))
   ENDIF
   reply->time_scale_list[count].time_scale_name = ts.time_scale_name, reply->time_scale_list[count].
   time_scale_name_key = ts.time_scale_name_key, reply->time_scale_list[count].time_scale_id = ts
   .time_scale_id
  FOOT REPORT
   stat = alterlist(reply->time_scale_list,count)
  WITH nocounter
 ;end select
 IF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
