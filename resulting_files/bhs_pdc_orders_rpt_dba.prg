CREATE PROGRAM bhs_pdc_orders_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "bDate" = "CURDATE",
  "eDate" = "CURDATE",
  "Activity_Type" = 0
  WITH outdev, bdate, edate,
  activity_type
 SELECT INTO value("pdc_orderables_report.csv")
  per.person_id, patient_name = per.name_full_formatted, order_id = o.order_id,
  order_dt_tm = format(o.orig_order_dt_tm,"MM-DD-YYYY HH:MM:SS;;D"), activity_type =
  uar_get_code_display(o.activity_type_cd)
  FROM person per,
   orders o
  WHERE per.person_id=o.person_id
   AND (o.activity_type_cd= $ACTIVITY_TYPE)
   AND per.active_ind=1
   AND per.end_effective_dt_tm > sysdate
   AND o.orig_order_dt_tm BETWEEN cnvtdatetime( $BDATE) AND cnvtdatetime( $EDATE)
  WITH nocounter, format, pcformat(value('"'),value(",")),
   time = 30000
 ;end select
 SET var_output = "pdc_orderables_report.csv"
 EXECUTE bhs_ma_email_file
 CALL emailfile("pdc_orderables_report.csv","pdc_orderables_report.csv","upendra.aemul@bhs.org",
  "PDC Orderables for Patients",0)
END GO
