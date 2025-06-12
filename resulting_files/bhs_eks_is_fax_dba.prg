CREATE PROGRAM bhs_eks_is_fax:dba
 SET oid = trigger_orderid
 SET eid = trigger_encntrid
 SET retval = 0
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE o.order_id=oid)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.action_sequence=o.last_action_sequence
    AND od.oe_field_meaning="ORDEROUTPUTDEST"
    AND od.oe_field_value > 0)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
 ENDIF
 SET log_message = build("order_id:",oid)
END GO
