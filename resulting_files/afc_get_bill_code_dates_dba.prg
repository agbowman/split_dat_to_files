CREATE PROGRAM afc_get_bill_code_dates:dba
 RECORD reply(
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  FROM bill_item_modifier b
  WHERE (b.bill_item_id=request->bill_item_id)
   AND (b.key6=request->key6)
   AND (b.key1_id=request->key1_id)
   AND (b.bim1_int=request->bim1_int)
  DETAIL
   reply->beg_effective_dt_tm = cnvtdatetime(b.beg_effective_dt_tm), reply->end_effective_dt_tm =
   cnvtdatetime(b.end_effective_dt_tm),
   CALL echo("Found dates...")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM_MODIFIER"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
