CREATE PROGRAM bhs_rad_audit_ord_with_folder:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $1
  orderable = uar_get_code_display(o.catalog_cd), folder = c.definition, e.required_ind
  FROM order_catalog o,
   exam_folder e,
   code_value c,
   dummyt d
  PLAN (o
   WHERE o.activity_type_cd=711
    AND o.active_ind=1)
   JOIN (d)
   JOIN (e
   WHERE e.catalog_cd=o.catalog_cd)
   JOIN (c
   WHERE c.code_value=e.image_class_type_cd)
  ORDER BY orderable
  WITH nocounter, format, outerjoin = d
 ;end select
END GO
