CREATE PROGRAM bhs_rad_audit_no_tech_cmt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $1
  o_activity_type_disp = uar_get_code_display(o.activity_type_cd), o_activity_subtype_disp =
  uar_get_code_display(o.activity_subtype_cd), o_catalog_disp = uar_get_code_display(o.catalog_cd),
  o.catalog_cd
  FROM order_catalog o
  PLAN (o
   WHERE o.catalog_type_cd=2517
    AND o.active_ind=1
    AND  NOT (o.catalog_cd IN (
   (SELECT
    r.catalog_cd
    FROM rad_tech_fmt_erprc_r r
    WHERE r.catalog_cd=o.catalog_cd))))
  ORDER BY o_activity_type_disp, o_activity_subtype_disp, o_catalog_disp
  WITH nocounter, separator = " ", format
 ;end select
END GO
