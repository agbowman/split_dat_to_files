CREATE PROGRAM bed_get_pharm_price_sched:dba
 FREE SET reply
 RECORD reply(
   1 price_scheds[*]
     2 price_sched_id = f8
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
 SET list_count = 0
 SELECT INTO "nl:"
  FROM price_sched p
  WHERE p.pharm_ind=1
   AND p.price_sched_id > 0
   AND p.active_ind=1
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(reply->price_scheds,100)
  DETAIL
   list_count = (list_count+ 1), cnt = (cnt+ 1)
   IF (list_count > 100)
    stat = alterlist(reply->price_scheds,(cnt+ 100)), list_count = 1
   ENDIF
   reply->price_scheds[cnt].price_sched_id = p.price_sched_id, reply->price_scheds[cnt].description
    = p.price_sched_desc
  FOOT REPORT
   stat = alterlist(reply->price_scheds,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
