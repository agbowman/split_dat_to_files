CREATE PROGRAM bbt_get_originating_supplier:dba
 RECORD reply(
   1 organization_id = f8
   1 org_name = c40
   1 bb_supplier_id = f8
   1 receipt_updt_cnt = i4
   1 product_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET new_product_id = 0.0
 SELECT INTO "nl:"
  pr.modified_product_id, pr.pooled_product_id
  FROM product pr
  PLAN (pr
   WHERE (pr.product_id=request->product_id)
    AND pr.active_ind=1)
  DETAIL
   IF (pr.modified_product_id > 0.0)
    new_product_id = pr.modified_product_id
   ELSEIF (pr.pooled_product_id > 0.0)
    new_product_id = pr.pooled_product_id
   ENDIF
  WITH nocounter
 ;end select
 IF (new_product_id > 0)
  SET request->product_id = new_product_id
 ENDIF
 SELECT INTO "nl:"
  o.organization_id, o.org_name, bbs.bb_supplier_id,
  r.product_event_id
  FROM (dummyt d_r  WITH seq = 1),
   receipt r,
   bb_supplier bbs,
   organization o
  PLAN (d_r)
   JOIN (r
   WHERE (r.product_id=request->product_id))
   JOIN (bbs
   WHERE bbs.bb_supplier_id=r.bb_supplier_id
    AND r.bb_supplier_id > 0.0)
   JOIN (o
   WHERE o.organization_id=bbs.organization_id
    AND o.organization_id > 0.0)
  ORDER BY r.product_event_id
  DETAIL
   reply->organization_id = o.organization_id, reply->org_name = o.org_name, reply->bb_supplier_id =
   r.bb_supplier_id,
   reply->product_event_id = r.product_event_id, reply->receipt_updt_cnt = r.updt_cnt
  FOOT REPORT
   select_ok_ind = 1
  WITH nocounter, nullreport, outerjoin(d_r)
 ;end select
 SET reply->status_data.subeventstatus[count1].operationname = "Get Originating Supplier"
 SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_originating_supplier"
 IF (select_ok_ind=1)
  IF ((reply->organization_id > 0))
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "ZERO"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "Select on bb_supplier/organization failed"
 ENDIF
END GO
