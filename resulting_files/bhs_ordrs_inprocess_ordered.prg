CREATE PROGRAM bhs_ordrs_inprocess_ordered
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT DISTINCT INTO value("bhs_ordrs_inprocess_ordered.csv")
  patient_name = p.name_full_formatted, mrn = ea.alias, rad.accession,
  o.order_id, order_description = o.order_mnemonic, order_dt_tm = format(o.orig_order_dt_tm,
   "MMM-DD-YYYY HH:MM:SS;;D"),
  order_status = uar_get_code_display(o.order_status_cd), o.order_status_cd, report_status =
  uar_get_code_display(rad.report_status_cd),
  rad.report_status_cd, exam_status = uar_get_code_display(rad.exam_status_cd), rad.exam_status_cd,
  o.contributor_system_cd
  FROM orders o,
   person p,
   order_radiology rad,
   encntr_alias ea
  WHERE rad.order_id=o.order_id
   AND ea.encntr_id=o.encntr_id
   AND p.person_id=o.person_id
   AND p.active_ind=1
   AND o.active_ind=1
   AND o.contributor_system_cd=196965398
   AND p.end_effective_dt_tm > sysdate
   AND rad.exam_status_cd=4226
   AND o.order_status_cd=2548
   AND ea.encntr_alias_type_cd=1079
   AND o.orig_order_dt_tm >= cnvtdatetime("01-JUN-2007")
   AND o.orig_order_dt_tm <= cnvtdatetime("30-MAR-2012")
  ORDER BY o.orig_order_dt_tm
  WITH nocounter, format, pcformat(value('"'),value(",")),
   time = 30000
 ;end select
 SET var_output = "shields_order_with_images.csv"
 EXECUTE bhs_ma_email_file
 CALL emailfile("bhs_ordrs_inprocess_ordered.csv","bhs_ordrs_inprocess_ordered.csv",
  "upendra.aemul@bhs.org, Victoria.Michalczyk@bhs.org","Shields Orders with No Final Report",0)
END GO
