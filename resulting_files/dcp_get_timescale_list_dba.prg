CREATE PROGRAM dcp_get_timescale_list:dba
 RECORD reply(
   1 qual[*]
     2 time_scale_id = f8
     2 time_scale_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET stat = alterlist(reply->qual,10)
 SELECT INTO "nl:"
  ts.time_scale_id, ts.time_scale_name
  FROM time_scale ts
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].time_scale_id = ts.time_scale_id, reply->qual[count1].time_scale_name = trim(
    ts.time_scale_name)
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH counter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
