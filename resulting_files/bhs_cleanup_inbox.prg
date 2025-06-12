CREATE PROGRAM bhs_cleanup_inbox
 PROMPT
  "Person ID" = 0
  WITH prompt2
 SET doctor_cosign = 2
 SET not_reviewed = 0
 SET reviewed = 1
 FREE RECORD orders
 RECORD orders(
   1 qual[*]
     2 orderid = f8
     2 providerid = f8
 )
 SELECT INTO "nl:"
  o.action_sequence, o.order_id, o.provider_id,
  o.review_type_flag, o.reviewed_status_flag, o.review_dt_tm
  FROM order_review o
  PLAN (o
   WHERE o.reviewed_status_flag=0
    AND o.review_type_flag=2
    AND (o.provider_id= $PROMPT2))
  ORDER BY o.order_id
  HEAD REPORT
   x = 0, stat = alterlist(orders->qual,10)
  DETAIL
   x = (x+ 1)
   IF (mod(x,10)=1)
    stat = alterlist(orders->qual,(x+ 10))
   ENDIF
   orders->qual[x].orderid = o.order_id, orders->qual[x].providerid = o.provider_id
  FOOT REPORT
   stat = alterlist(orders->qual,x)
  WITH nocounter, separator = " ", format
 ;end select
 FOR (x = 1 TO size(orders->qual,5))
   UPDATE  FROM order_review o
    SET o.reviewed_status_flag = 1, o.review_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (o.order_id=orders->qual[x].orderid)
     AND (o.provider_id=orders->qual[x].providerid)
    WITH nocounter
   ;end update
   UPDATE  FROM orders orde
    SET orde.need_doctor_cosign_ind = 0
    WHERE (orde.order_id=orders->qual[x].orderid)
    WITH nocounter
   ;end update
   UPDATE  FROM order_notification ot
    SET ot.notification_status_flag = 2
    WHERE (ot.order_id=orders->qual[x].orderid)
     AND (ot.to_prsnl_id=orders->qual[x].providerid)
     AND ot.notification_status_flag=1
    WITH nocounter
   ;end update
   COMMIT
 ENDFOR
END GO
