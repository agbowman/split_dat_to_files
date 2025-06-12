CREATE PROGRAM afc_get_price_history:dba
 RECORD reply(
   1 price_sched_item_qual = i2
   1 price_sched_item[*]
     2 price_sched_id = f8
     2 price_sched_desc = vc
     2 price = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET stat = alterlist(reply->price_sched_item,count1)
 SELECT INTO "nl:"
  FROM price_sched_items p
  WHERE (p.bill_item_id=request->bill_item_id)
   AND p.active_ind=1
  ORDER BY p.price_sched_id, p.beg_effective_dt_tm
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->price_sched_item,count1), reply->price_sched_item[
   count1].price_sched_id = p.price_sched_id,
   reply->price_sched_item[count1].price = p.price, reply->price_sched_item[count1].
   beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm), reply->price_sched_item[count1].
   end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
  WITH nocounter
 ;end select
 SET reply->price_sched_item_qual = count1
 SELECT INTO "nl:"
  FROM price_sched p,
   (dummyt d1  WITH seq = value(reply->price_sched_item_qual))
  PLAN (d1)
   JOIN (p
   WHERE (p.price_sched_id=reply->price_sched_item[d1.seq].price_sched_id))
  DETAIL
   reply->price_sched_item[d1.seq].price_sched_desc = p.price_sched_desc
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRICE_SCHED_ITEM"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
