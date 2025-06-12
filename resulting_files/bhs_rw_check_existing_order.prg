CREATE PROGRAM bhs_rw_check_existing_order
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
 ELSE
  SET trigger_orderid = eksdata->tqual[1].qual[1].order_id
 ENDIF
 SET retval = 0
 IF (trigger_orderid <= 0.00)
  SET log_message = build2("No valid ORDER_ID given. Exitting Script (1)")
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 SET log_orderid = trigger_orderid
 DECLARE cs200_narcotic_infusion_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICINFUSIONACCOUNTABILITY"))
 DECLARE narcoticpatchaccountability = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICPATCHACCOUNTABILITY"))
 DECLARE narcoticshiftdocumentation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICSHIFTDOCUMENTATION"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 SELECT INTO "NL:"
  FROM orders o1,
   orders o2,
   order_comment oc,
   long_text lt,
   dummyt d
  PLAN (o1
   WHERE log_orderid=o1.order_id)
   JOIN (d)
   JOIN (o2
   WHERE o1.encntr_id=o2.encntr_id
    AND ((o2.catalog_cd+ 0) IN (cs200_narcotic_infusion_cd, narcoticpatchaccountability,
   narcoticshiftdocumentation))
    AND o2.order_status_cd=cs6004_ordered_cd)
   JOIN (oc
   WHERE outerjoin(o2.order_id)=oc.order_id)
   JOIN (lt
   WHERE outerjoin(oc.long_text_id)=lt.long_text_id)
  HEAD o1.order_id
   log_misc1 = concat("This task is for ",trim(o1.ordered_as_mnemonic,3)," ordered at ",format(o1
     .orig_order_dt_tm,";;q")," (ORDER_ID:",
    IF (o1.template_order_id > 0) trim(cnvtstring(o1.template_order_id),3)
    ELSE trim(cnvtstring(o1.order_id),3)
    ENDIF
    ,")")
  DETAIL
   IF (findstring("(ORDER_ID:",lt.long_text) <= 0)
    CALL echo(build2("No ORDER_ID found in order comment for Narcotic "," order (ORDER_ID ",trim(
      cnvtstring(o2.order_id),3),".")), log_message = "Order Founfd but: "
   ELSEIF (findstring(trim(cnvtstring(o1.order_id),3),lt.long_text) > 0)
    log_message = build2("Narcotic  order found (ORDER_ID of found order ",trim(cnvtstring(o2
       .order_id),3),")."), retval = 100
   ELSEIF (o1.template_order_id > 0
    AND findstring(trim(cnvtstring(o1.template_order_id),3),lt.long_text) > 0)
    log_message = build2("Narcotic order found parent order(ORDER_ID of found order ",trim(cnvtstring
      (o2.order_id),3),")."), retval = 100
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (retval=0)
  SET log_message = build2(log_message,"No valid Narcotic order found for ORDER_ID ",trim(cnvtstring(
     log_orderid),3),". Exitting Script")
 ENDIF
#exit_script
 CALL echo(log_message)
 CALL echo(build2("RETVAL = ",retval))
END GO
