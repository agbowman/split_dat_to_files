CREATE PROGRAM bhs_req_printer_list2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Printer" = ""
  WITH outdev, route
 SELECT DISTINCT INTO  $1
  d.dcp_output_route_id, d.route_description, dfr_value1_disp = uar_get_code_display(dfr.value1_cd),
  df.printer_name
  FROM dcp_output_route d,
   dcp_flex_printer df,
   dcp_flex_rtg dfr
  PLAN (d
   WHERE d.dcp_output_route_id > 0)
   JOIN (df
   WHERE df.dcp_output_route_id=d.dcp_output_route_id
    AND df.printer_name=patstring( $2))
   JOIN (dfr
   WHERE dfr.dcp_flex_rtg_id=df.dcp_flex_rtg_id)
  ORDER BY d.dcp_output_route_id, d.route_description, df.printer_name,
   0
  WITH format, variable, separator = " "
 ;end select
END GO
