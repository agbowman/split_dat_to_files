CREATE PROGRAM bhs_rad_audit_ord_with_oef:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT DISTINCT INTO  $1
  orderable = oc.description, order_entry_format = oe.oe_format_name, order_active_ind = oc
  .active_ind
  FROM order_catalog oc,
   order_entry_format oe
  PLAN (oc
   WHERE oc.activity_type_cd=711)
   JOIN (oe
   WHERE oe.oe_format_id=oc.oe_format_id)
  ORDER BY orderable
  WITH nocounter, format
 ;end select
END GO
