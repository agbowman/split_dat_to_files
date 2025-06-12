CREATE PROGRAM bhs_eks_narc_find_exist_ord
 PROMPT
  "Enter ORDER_ID:" = "0.00"
  WITH ordid
 CALL echo("JOSH2")
 CALL echorecord(eksdata)
 CALL echorecord(request)
 DECLARE log_message = vc
 SET log_message = concat(
  "this rule will ceck to see if a narcotics task order exists for the incoming order.",
  " it returns true if it does. it will also return information on the incoming order to be placed",
  " inside the log_misc1 to be used by the rule")
 IF (validate(eksevent,"A")="A"
  AND validate(eksevent,"Z")="Z")
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
  SET trigger_orderid = request->qual[1].order_id
 ENDIF
 SET retval = 0
 IF (trigger_orderid <= 0.00)
  SET log_message = build2(log_message,"No valid ORDER_ID given. Exitting Script (1)","log_orderid",
   log_orderid,"link_orderid:",
   link_orderid,"trigger_orderid",trigger_orderid)
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
 DECLARE narcoticpatchshiftdocumentation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICPATCHSHIFTDOCUMENTATION"))
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
   narcoticshiftdocumentation, narcoticpatchshiftdocumentation))
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
    ,")"), log_message = concat(log_message,"Order Found")
  DETAIL
   IF (findstring("(ORDER_ID:",lt.long_text) <= 0)
    CALL echo(build2("No ORDER_ID found in order comment for Narcotic "," order (ORDER_ID ",trim(
      cnvtstring(o2.order_id),3),"."))
   ELSEIF (findstring(trim(cnvtstring(o1.order_id),3),lt.long_text) > 0)
    log_message = build2(log_message," Narcotic  order found (ORDER_ID of found order ",trim(
      cnvtstring(o2.order_id),3),")."), retval = 100
   ELSEIF (o1.template_order_id > 0
    AND findstring(trim(cnvtstring(o1.template_order_id),3),lt.long_text) > 0)
    log_message = build2(log_message," Narcotic order found parent order(ORDER_ID of found order ",
     trim(cnvtstring(o2.order_id),3),")."), retval = 100
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (retval=0)
  SET log_message = build2(log_message,"No valid Narcotic order found for ORDER_ID ",trim(cnvtstring(
     log_orderid),3),". Exitting Script")
 ENDIF
 SET log_message = build2(log_message,"_log_misc1_",log_misc1)
#exit_script
 CALL echo(log_message)
 CALL echo(build2("RETVAL = ",retval))
END GO
