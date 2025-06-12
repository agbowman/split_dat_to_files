CREATE PROGRAM bhs_eks_default_loc:dba
 SET oid = trigger_orderid
 SET eid = trigger_encntrid
 SET retval = 0
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa
  PLAN (o
   WHERE o.order_id=oid)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_locn_cd > 0)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
 ENDIF
 SET log_message = build("order_id:",oid)
END GO
