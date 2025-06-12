CREATE PROGRAM bbt_get_quar_release:dba
 RECORD reply(
   1 qual[*]
     2 product_event_id = f8
     2 product_id = f8
     2 quar_release_id = f8
     2 release_dt_tm = dq8
     2 release_prsnl_id = f8
     2 release_reason_cd = f8
     2 release_reason_cd_disp = vc
     2 release_qty = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  q.*
  FROM quarantine_release q,
   (dummyt d1  WITH seq = value(request->product_count))
  PLAN (d1)
   JOIN (q
   WHERE (q.product_event_id=request->qual[d1.seq].product_event_id)
    AND (q.product_id=request->qual[d1.seq].product_id))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].product_event_id = q
   .product_event_id,
   reply->qual[count1].product_id = request->qual[d1.seq].product_id, reply->qual[count1].
   quar_release_id = q.quar_release_id, reply->qual[count1].release_dt_tm = q.release_dt_tm,
   reply->qual[count1].release_prsnl_id = q.release_prsnl_id, reply->qual[count1].release_reason_cd
    = q.release_reason_cd, reply->qual[count1].release_qty = q.release_qty,
   reply->qual[count1].updt_cnt = q.updt_cnt, reply->qual[count1].updt_dt_tm = q.updt_dt_tm, reply->
   qual[count1].updt_id = q.updt_id,
   reply->qual[count1].updt_task = q.updt_task, reply->qual[count1].updt_applctx = q.updt_applctx,
   reply->qual[count1].active_ind = q.active_ind
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
