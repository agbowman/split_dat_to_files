CREATE PROGRAM bhs_rad_order_audit
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "email" = "Report_view"
  WITH outdev, email
 SELECT INTO  $1
  rad.order_id, rad_exam = uar_get_code_display(rad.exam_status_cd), rad_report =
  uar_get_code_display(rad.report_status_cd)
  FROM order_radiology rad,
   orders o
  PLAN (rad
   WHERE rad.report_status_cd=4263.00
    AND rad.complete_dt_tm > cnvtdatetime((curdate - 7),curtime3))
   JOIN (o
   WHERE rad.order_id=o.order_id
    AND o.order_status_cd IN (2550.00, 2548.00))
  WITH time = 60, maxrec = 10
 ;end select
END GO
