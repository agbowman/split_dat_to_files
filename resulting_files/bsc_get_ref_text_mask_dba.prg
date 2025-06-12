CREATE PROGRAM bsc_get_ref_text_mask:dba
 SET modify = predeclare
 RECORD reply(
   1 ref_text_mask = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE istat = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET reply->ref_text_mask = - (1)
 SELECT INTO "nl:"
  FROM orders o
  WHERE (o.order_id=request->order_id)
   AND o.template_order_id=0
  DETAIL
   reply->ref_text_mask = o.ref_text_mask
  WITH nocounter
 ;end select
 IF ((reply->ref_text_mask=- (1)))
  SELECT INTO "nl:"
   FROM orders o1,
    orders o2
   PLAN (o1
    WHERE (o1.order_id=request->order_id)
     AND o1.template_order_id > 0)
    JOIN (o2
    WHERE o2.order_id=o1.template_order_id
     AND o2.template_order_id=0)
   DETAIL
    reply->ref_text_mask = o2.ref_text_mask
   WITH nocounter
  ;end select
 ENDIF
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF ((reply->ref_text_mask >= 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "Order id not found."
 ENDIF
 SET last_mod = "0"
 SET mod_date = "10/13/2012"
 SET modify = nopredeclare
END GO
