CREATE PROGRAM bed_get_rx_price_sched:dba
 FREE SET reply
 RECORD reply(
   1 price_schedules[*]
     2 id = f8
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM price_sched p
  PLAN (p
   WHERE p.pharm_ind=1
    AND p.active_ind=1)
  ORDER BY p.price_sched_short_desc
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->price_schedules,cnt), reply->price_schedules[cnt].id = p
   .price_sched_id,
   reply->price_schedules[cnt].description = p.price_sched_short_desc
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
