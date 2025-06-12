CREATE PROGRAM dcp_get_timescales_names:dba
 RECORD reply(
   1 qual[*]
     2 time_scale_name = vc
     2 time_scale_id = f8
     2 time_scale_name_key = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET qualcnt = 0
 SELECT INTO "nl:"
  ts.time_scale_id, ts.time_scale_name, ts.time_scale_name_key
  FROM time_scale ts
  WHERE trim(ts.time_scale_name) > ""
   AND ts.time_scale_id > 0
  DETAIL
   qualcnt = (qualcnt+ 1)
   IF (qualcnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(qualcnt+ 10))
   ENDIF
   reply->qual[qualcnt].time_scale_name = ts.time_scale_name, reply->qual[qualcnt].
   time_scale_name_key = ts.time_scale_name_key, reply->qual[qualcnt].time_scale_id = ts
   .time_scale_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,qualcnt)
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
