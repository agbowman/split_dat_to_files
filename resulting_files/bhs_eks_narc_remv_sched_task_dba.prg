CREATE PROGRAM bhs_eks_narc_remv_sched_task:dba
 PROMPT
  "orderid" = 0,
  "encntrid" = 0,
  "Output to File/Printer/MINE" = "MINE"
  WITH orderid, encntrid, outdev
 DECLARE log_message = vc WITH noconstant(" "), public
 DECLARE log_misc = vc WITH noconstant(" "), public
 DECLARE encntrid = f8 WITH noconstant(0.0), protect
 DECLARE tcurindex = i4 WITH proect
 DECLARE itemtoremovefound = i4 WITH noconstant(0), protect
 DECLARE parentorderidfound = i4 WITH noconstant(0), protect
 DECLARE removeordcnt = i4 WITH noconstant(0), protect
 SET retval = 0
 DECLARE narcoticpatchaccountability = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICPATCHACCOUNTABILITY")), protect
 DECLARE narcoticpatchshiftdocumentation = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICPATCHSHIFTDOCUMENTATION")), protect
 DECLARE narcoticshiftdocumentation = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICSHIFTDOCUMENTATION")), protect
 DECLARE narcoticinfusionaccountability = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICINFUSIONACCOUNTABILITY")), protect
 DECLARE ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 IF (( $ENCNTRID <= 0))
  SET encntrid = trigger_encntrid
 ELSE
  SET encntrid = value( $ENCNTRID)
 ENDIF
 CALL echo("bhs_eks_narc_remv_sched_task records")
 CALL echorecord(request)
 FREE RECORD temprequest
 RECORD temprequest(
   1 orderlist[*]
     2 orderid = f8
 )
 FREE RECORD removeorders
 RECORD removeorders(
   1 orderlist[*]
     2 orderid = f8
 )
 SET stat = alterlist(temprequest->orderlist,size(request->orderlist,5))
 FOR (x = 1 TO size(request->orderlist,5))
   SET temprequest->orderlist[x].orderid = request->orderlist[x].orderid
 ENDFOR
 CALL echorecord(temprequest)
 SET log_message = concat(log_message,"TempListSize: ",build(size(temprequest,5)))
 SET log_message = concat(log_message,"--locating task/order on patient")
 CALL echo(log_message)
 SET tcurindex = 3
 SET log_message = build(log_message,"Curindex: ",curindex)
 SET eksdata->tqual[tcurindex].qual[tcurindex].cnt = 2
 SELECT INTO  $OUTDEV
  o.order_id
  FROM orders o,
   order_comment oc,
   long_text lt
  PLAN (o
   WHERE o.encntr_id=encntrid
    AND o.catalog_cd IN (narcoticpatchshiftdocumentation, narcoticshiftdocumentation)
    AND o.order_status_cd IN (ordered)
    AND o.template_order_id <= 0)
   JOIN (oc
   WHERE oc.order_id=o.order_id
    AND oc.action_sequence=1)
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id
    AND lt.active_ind=1)
  ORDER BY o.order_id
  HEAD o.order_id
   parentorderidfound = 0, log_message = concat(log_message,"[[[--located order on patient:",build(o
     .order_id),"Now looking for passed order_ID in comment")
   FOR (x = 1 TO size(temprequest->orderlist,5))
     IF (findstring(trim(cnvtstring(temprequest->orderlist[x].orderid),3),lt.long_text))
      removeordcnt = (removeordcnt+ 1), stat = alterlist(removeorders->orderlist,removeordcnt),
      removeorders->orderlist[removeordcnt].orderid = o.order_id,
      log_message = build(log_message,"task/order - orderid found: ",build(o.order_id),"]]]"),
      itemtoremovefound = 1, parentorderidfound = 1
     ENDIF
   ENDFOR
  FOOT  o.order_id
   IF (parentorderidfound=0)
    log_message = concat(log_message,"-order_id not found in comments...","]]]")
   ENDIF
  WITH nocounter
 ;end select
 SET log_message = concat(log_message,"-Remove order count =",removeordcnt)
 IF (itemtoremovefound=1)
  FOR (x = 1 TO removeordcnt)
   SET log_message = concat(log_message,
    "--Calling Rule/script bhs_asy_cancel_order to remove order: ",build(removeorders->orderlist[x].
     orderid))
   EXECUTE bhs_sys_cancel_order removeorders->orderlist[x].orderid
  ENDFOR
  SET retval = 100
 ENDIF
#exit_program
 CALL echo(log_message)
 CALL echo(log_misc)
 CALL echorecord(request)
 CALL echorecord(eksdata)
END GO
