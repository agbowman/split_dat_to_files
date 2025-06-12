CREATE PROGRAM bhs_rad_audit_tech_cmt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Activity Sub Type:" = 0
  WITH outdev, prompt2
 SELECT DISTINCT INTO value( $OUTDEV)
  r_catalog_disp = uar_get_code_display(o.catalog_cd), o_activity_type_disp = uar_get_code_display(o
   .activity_type_cd), o_activity_subtype_disp = uar_get_code_display(o.activity_subtype_cd),
  rtfo.format_desc, rtf.active_ind
  FROM order_catalog o,
   rad_tech_fmt_erprc_r r,
   rad_tech_fld_fmt_r rt,
   rad_tech_field rtf,
   rad_tech_format rtfo
  PLAN (o
   WHERE (o.activity_subtype_cd= $2)
    AND o.active_ind=1)
   JOIN (r
   WHERE r.catalog_cd=o.catalog_cd)
   JOIN (rt
   WHERE rt.format_id=r.format_id)
   JOIN (rtfo
   WHERE rtfo.format_id=rt.format_id)
   JOIN (rtf
   WHERE rtf.field_id=rt.field_id
    AND rtf.active_ind=1)
  ORDER BY r_catalog_disp
  WITH nocounter, separator = " ", format
 ;end select
END GO
