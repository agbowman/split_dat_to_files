CREATE PROGRAM afc_get_price_sched_dates:dba
 RECORD reply(
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 price_sched_items_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  FROM price_sched_items p
  WHERE (p.price_sched_id=request->price_sched_id)
   AND (p.bill_item_id=request->bill_item_id)
   AND p.active_ind=1
  DETAIL
   reply->beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm), reply->end_effective_dt_tm =
   cnvtdatetime(p.end_effective_dt_tm), reply->price_sched_items_id = p.price_sched_items_id,
   CALL echo("Found dates..."),
   CALL echo(build("price_sched_items_id ",p.price_sched_items_id))
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
