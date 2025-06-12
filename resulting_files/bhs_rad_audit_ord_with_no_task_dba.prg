CREATE PROGRAM bhs_rad_audit_ord_with_no_task:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  activity_type = uar_get_code_display(o.activity_type_cd), activity_sub_type = uar_get_code_display(
   o.activity_subtype_cd), procedure = uar_get_code_display(o.catalog_cd),
  catalog_code = o.catalog_cd
  FROM order_catalog o
  PLAN (o
   WHERE o.activity_type_cd=711
    AND o.active_ind=1
    AND  NOT (o.catalog_cd IN (
   (SELECT
    p.catalog_cd
    FROM profile_task_r p
    WHERE p.catalog_cd=o.catalog_cd))))
  ORDER BY activity_sub_type
  WITH nocounter, separator = " ", format
 ;end select
END GO
