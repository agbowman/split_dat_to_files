CREATE PROGRAM bhs_rpt_search_req_routing:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Route Name" = 0
  WITH outdev, routename
 DECLARE mc_any_route = c1 WITH constant(substring(1,1,reflect(parameter(2,0)))), protect
 SELECT
  IF (mc_any_route="C")
   PLAN (do
    WHERE do.dcp_output_route_id > 0)
    JOIN (d
    WHERE d.dcp_output_route_id=do.dcp_output_route_id)
    JOIN (df
    WHERE d.dcp_flex_rtg_id=df.dcp_flex_rtg_id)
  ELSE
   PLAN (do
    WHERE do.dcp_output_route_id=value( $ROUTENAME))
    JOIN (d
    WHERE d.dcp_output_route_id=do.dcp_output_route_id)
    JOIN (df
    WHERE d.dcp_flex_rtg_id=df.dcp_flex_rtg_id)
  ENDIF
  DISTINCT INTO  $OUTDEV
  do.route_description"#########################################", location_name = format(
   uar_get_code_display(d.value1_cd),"#########################"), location_code = d.value1_cd,
  df.printer_name, flex_on_type1 = uar_get_code_display(do.param1_cd), flex_value1 =
  uar_get_code_display(d.value1_cd),
  flex_on_type2 = uar_get_code_display(do.param2_cd), flex_value2 = uar_get_code_display(d.value2_cd),
  flex_on_type3 = uar_get_code_display(do.param3_cd),
  flex_value1 = uar_get_code_display(d.value3_cd), flex_on_type4 = uar_get_code_display(do.param4_cd),
  flex_value4 = uar_get_code_display(d.value4_cd)
  FROM dcp_flex_printer df,
   dcp_flex_rtg d,
   dcp_output_route do
  PLAN (do
   WHERE ((mc_any_route="C"
    AND do.dcp_output_route_id > 0) OR ((do.dcp_output_route_id= $ROUTENAME)
    AND mc_any_route="F")) )
   JOIN (d
   WHERE d.dcp_output_route_id=do.dcp_output_route_id)
   JOIN (df
   WHERE d.dcp_flex_rtg_id=df.dcp_flex_rtg_id)
  ORDER BY do.route_description, df.dcp_flex_rtg_id
  WITH nocounter, separator = " ", format,
   maxrec = 10000
 ;end select
END GO
