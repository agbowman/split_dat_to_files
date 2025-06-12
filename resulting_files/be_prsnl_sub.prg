CREATE PROGRAM be_prsnl_sub
 SELECT INTO "nl:"
  FROM be_prsnl_reltn bpr
  WHERE  $1
   AND  $2
   AND  $4
  HEAD REPORT
   stat = alterlist(reply->qual,10)
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].prsnl_id = bpr.prsnl_id, reply->qual[count].billing_entity_id = bpr
   .billing_entity_id, reply->qual[count].active_ind = bpr.active_ind,
   reply->qual[count].active_status_cd = bpr.active_status_cd, reply->qual[count].active_status_dt_tm
    = bpr.active_status_dt_tm, reply->qual[count].active_status_prsnl_id = bpr.active_status_prsnl_id,
   reply->qual[count].beg_effective_dt_tm = bpr.beg_effective_dt_tm, reply->qual[count].updt_cnt =
   bpr.updt_cnt, reply->qual[count].updt_dt_tm = bpr.updt_dt_tm,
   reply->qual[count].updt_id = bpr.updt_id, reply->qual[count].updt_task = bpr.updt_task
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count)
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
