CREATE PROGRAM bhs_rad_order_charge:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO value( $OUTDEV)
  o.order_id, o.person_id, o.order_status_cd,
  o_order_status_disp = uar_get_code_display(o.order_status_cd), ora.order_id, ora.parent_order_id,
  ora.encntr_id, ora.accession, ora.exam_status_cd,
  ora_exam_status_disp = uar_get_code_display(ora.exam_status_cd), o_catalog_disp =
  uar_get_code_display(o.catalog_cd), ora.report_status_cd,
  ora_report_status_disp = uar_get_code_display(ora.report_status_cd)
  FROM orders o,
   order_radiology ora
  PLAN (o
   WHERE o.activity_type_cd=711
    AND o.order_status_cd=2550)
   JOIN (ora
   WHERE o.order_id=ora.order_id
    AND ((ora.report_status_cd+ 0)=615282.00))
  WITH nocounter, separator = " ", format
 ;end select
END GO
