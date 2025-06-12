CREATE PROGRAM bhs_rad_orders_with_oef:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $1
  ordcat = uar_get_code_display(oc.catalog_cd)
  FROM order_catalog oc
  WHERE oc.activity_type_cd=711
   AND oc.active_ind=1
   AND oc.oe_format_id=1
  WITH nocounter, separator = " ", format
 ;end select
END GO
