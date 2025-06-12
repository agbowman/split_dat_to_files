CREATE PROGRAM ams_adha_chart_request:dba
 DECLARE file_name = vc
 DECLARE email = vc
 SET file_name = "chart_request_status_report.csv"
 SET email = "DL_BLR_PROD_SUPPORT_PS@cerner.com"
 DECLARE unprocessed_var = f8 WITH constant(uar_get_code_by("MEANING",18609,"UNPROCESSED")), protect
 DECLARE pending_var = f8 WITH constant(uar_get_code_by("MEANING",18609,"PENDING")), protect
 DECLARE inprocessed_var = f8 WITH constant(uar_get_code_by("MEANING",18609,"INPROCESS")), protect
 DECLARE nodata_var = f8 WITH constant(uar_get_code_by("MEANING",18609,"NODATA")), protect
 DECLARE mrpnodata_var = f8 WITH constant(uar_get_code_by("MEANING",18609,"MRPNODATA")), protect
 DECLARE successful_var = f8 WITH constant(uar_get_code_by("MEANING",18609,"SUCCESSFUL")), protect
 DECLARE printernotinstalled_var = f8 WITH constant(uar_get_code_by("MEANING",18609,"PRINTNOTINST")),
 protect
 SELECT INTO value(file_name)
  chart_request_id = cr.chart_request_id, chart_stat = uar_get_code_display(cr.chart_status_cd),
  chart_date = cr.request_dt_tm"@SHORTDATETIME",
  chart_type_cd = cr.request_type
  FROM chart_request cr
  WHERE ((cr.request_dt_tm < cnvtlookbehind("10,MIN",sysdate)
   AND cr.request_dt_tm > cnvtlookbehind("60,MIN",sysdate)
   AND cr.chart_status_cd=unprocessed_var) OR (((cr.request_dt_tm < cnvtlookbehind("10,MIN",sysdate)
   AND cr.request_dt_tm > cnvtlookbehind("60,MIN",sysdate)
   AND cr.chart_status_cd=pending_var) OR (((cr.request_dt_tm < cnvtlookbehind("30,MIN",sysdate)
   AND cr.request_dt_tm > cnvtlookbehind("60,MIN",sysdate)
   AND cr.chart_status_cd=inprocessed_var) OR ( NOT (cr.chart_status_cd IN (nodata_var, mrpnodata_var,
  successful_var, printernotinstalled_var, unprocessed_var,
  pending_var, inprocessed_var))
   AND cr.request_dt_tm > cnvtlookbehind("1,hr",sysdate))) )) ))
  HEAD REPORT
   line_d = fillstring(90,"*"), line_e = fillstring(110,"-"), blank_line = fillstring(130," "),
   col 0, blank_line, row + 1,
   CALL center("*** Chart requests status Report ***",0,120), row + 1, col 0,
   "Report Date: ", curdate"MM/DD/YY;;D", row + 1
  HEAD PAGE
   row + 1, col 0, line_d,
   row + 1, col 0, "Chart_Request_ID",
   col 25, "Chart_Status", col 60,
   "Chart_Date", col 90, "Chart_Type",
   row + 1, col 0, line_d,
   row + 1
  DETAIL
   chart_request_id, col 0, chart_request_id,
   chart_status = trim(substring(1,30,chart_stat)), col 30, chart_status,
   chart_date, col 60, chart_date,
   chart_type_cd, col 80, chart_type_cd,
   row + 1
  FOOT PAGE
   row + 1, col 0, line_e,
   row + 1, col 0,
   "Note: Request Type:    1- Adhoc;     2- Expedite;    4- Distribution;     8- MRP "
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_program
 ENDIF
 DECLARE subject_line = vc
 SET subject_line = "ADHA_AE Chart request status Report"
 SET dclcom = concat('sed "s/$/`echo \\\r`/" ',file_name," | uuencode ",file_name,' | mail -s "',
  subject_line,'" ',email)
 CALL echo(dclcom)
 SET len = size(trim(dclcom))
 SET status = 0
 CALL dcl(dclcom,len,status)
 SET dclcom = concat("rm ",trim(file_name),"*")
 SET len = size(trim(dclcom))
 SET status = 0
 CALL dcl(dclcom,len,status)
#exit_program
 SET last_mod = "09/10/15 ak032157 000"
END GO
