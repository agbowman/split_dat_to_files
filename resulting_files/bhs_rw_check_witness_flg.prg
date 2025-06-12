CREATE PROGRAM bhs_rw_check_witness_flg
 PROMPT
  "Enter ORDER_ID: " = 0.00
 IF (validate(eksevent,"A")="A"
  AND validate(eksevent,"Z")="Z")
  DECLARE log_message = vc
  DECLARE retval = i4
  DECLARE trigger_orderid = f8
  DECLARE log_orderid = f8
  IF (reflect(parameter(1,0)) <= " ")
   CALL echo("No ORDER_ID given. Exitting Script")
   GO TO exit_script
  ELSE
   SET trigger_orderid = cnvtreal(parameter(1,0))
  ENDIF
 ENDIF
 SET retval = 0
 IF (trigger_orderid <= 0.00)
  SET log_message = build2("No valid ORDER_ID given. Exitting Script (1)")
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 SET log_orderid = trigger_orderid
 SELECT INTO "NL:"
  FROM orders o,
   order_catalog_synonym ocs
  PLAN (o
   WHERE log_orderid=o.order_id)
   JOIN (ocs
   WHERE o.synonym_id=ocs.synonym_id
    AND ocs.witness_flag=1)
  DETAIL
   retval = 100
  WITH nocounter
 ;end select
 IF (retval=0)
  SELECT INTO "NL:"
   FROM order_ingredient oi,
    order_catalog_synonym ocs
   PLAN (oi
    WHERE log_orderid=oi.order_id)
    JOIN (ocs
    WHERE oi.synonym_id=ocs.synonym_id
     AND ocs.witness_flag=1)
   DETAIL
    retval = 100
   WITH nocounter
  ;end select
 ENDIF
 IF (retval=100)
  SET log_message = build2("WITNESS_FLAG = 1 for ORDER_ID ",trim(cnvtstring(log_orderid),3))
 ELSE
  SET log_message = build2("WITNESS_FLAG = 0 for ORDER_ID ",trim(cnvtstring(log_orderid),3))
 ENDIF
#exit_script
 CALL echo(log_message)
 CALL echo(build2("RETVAL = ",retval))
END GO
