CREATE PROGRAM bhs_shields_orders_with_images
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO value("med_reports_test.csv")
  full_name = trim(p.name_full_formatted,3), o.order_id, o.person_id,
  person_mrn = trim(ea.alias,3), order_code = uar_get_code_display(o.contributor_system_cd),
  order_date_time = format(o.orig_order_dt_tm,"MMM-DD-YYYY HH:MM:SS;;D"),
  o.last_update_provider_id
  FROM orders o,
   person p,
   encntr_alias ea
  WHERE o.person_id=p.person_id
   AND ea.encntr_id=o.encntr_id
   AND o.contributor_system_cd=196965398.00
   AND ((o.last_update_provider_id+ 0)=0)
   AND ea.encntr_alias_type_cd=1079
   AND o.orig_order_dt_tm >= cnvtdatetime("10-AUG-2010")
   AND o.orig_order_dt_tm <= cnvtdatetime("27-JAN-2011")
   AND ea.active_ind=1
   AND ea.beg_effective_dt_tm < sysdate
   AND ea.end_effective_dt_tm > sysdate
  WITH nocounter, format, pcformat(value('"'),value(",")),
   time = 30000
 ;end select
 SET var_output = "med_reports_test.csv"
 EXECUTE bhs_ma_email_file
 CALL emailfile("med_reports_test.csv","med_reports_test.csv","upendra.aemul@bhs.org",
  "Med Orders for Shields",0)
END GO
