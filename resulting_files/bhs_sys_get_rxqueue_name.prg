CREATE PROGRAM bhs_sys_get_rxqueue_name
 SET orderid =  $1
 SET orderloc = 0
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa
  PLAN (o
   WHERE (o.order_id= $1))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND o.last_action_sequence=oa.action_sequence)
  DETAIL
   orderloc = oa.order_locn_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  loc_code = dfr.value1_cd, printer = dfp.printer_name
  FROM dcp_output_route dor,
   dcp_flex_rtg dfr,
   dcp_flex_printer dfp
  PLAN (dor
   WHERE dor.route_description="EZ Script")
   JOIN (dfr
   WHERE outerjoin(dor.dcp_output_route_id)=dfr.dcp_output_route_id
    AND dfr.value1_cd=orderloc)
   JOIN (dfp
   WHERE outerjoin(dfr.dcp_flex_rtg_id)=dfp.dcp_flex_rtg_id)
  DETAIL
   queuename = trim(dfp.printer_name)
  WITH nocounter
 ;end select
 CALL echo(build("queue name:",queuename))
END GO
