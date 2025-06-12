CREATE PROGRAM bhs_rad_ord_with_dta
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $1
  o_activity_type_disp = uar_get_code_display(o.activity_type_cd), o_activity_subtype_disp =
  uar_get_code_display(o.activity_subtype_cd), dta.code_set,
  dta.event_cd, r_catalog_disp = uar_get_code_display(r.catalog_cd), r_classification_disp =
  uar_get_code_display(r.classification_cd),
  r.group_desc, rt_task_assay_disp = uar_get_code_display(rt.task_assay_cd), rt.template_group_id,
  rt.template_id, dta_task_assay_disp = uar_get_code_display(dta.task_assay_cd)
  FROM order_catalog o,
   discrete_task_assay dta,
   rad_template_group r,
   rad_template_assoc rt
  PLAN (o)
   JOIN (r
   WHERE r.catalog_cd=o.catalog_cd)
   JOIN (rt
   WHERE rt.template_group_id=r.template_group_id)
   JOIN (dta
   WHERE dta.task_assay_cd=rt.task_assay_cd)
  WITH nocounter, separator = " ", format
 ;end select
END GO
