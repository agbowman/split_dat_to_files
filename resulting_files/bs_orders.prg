CREATE PROGRAM bs_orders
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  o_activity_type_disp = uar_get_code_display(o.activity_type_cd), o_catalog_type_disp =
  uar_get_code_display(o.catalog_type_cd), o_catalog_disp = uar_get_code_display(o.catalog_cd),
  o.order_id, o.encntr_id, o.orig_order_dt_tm,
  p.name_full_formatted, p.person_id, o.person_id,
  e.encntr_id, e_loc_facility_disp = uar_get_code_display(e.loc_facility_cd)
  FROM orders o,
   person p,
   encounter e
  PLAN (o)
   JOIN (p
   WHERE o.person_id=p.person_id
    AND o.catalog_type_cd=2513
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime("19-MAY-2007 00:00:00") AND cnvtdatetime(
    "19-MAY-2007 05:08:00"))
   JOIN (e
   WHERE o.encntr_id=e.encntr_id
    AND e.loc_facility_cd IN (673936, 673937, 673938))
  WITH nocounter, separator = " ", format
 ;end select
END GO
