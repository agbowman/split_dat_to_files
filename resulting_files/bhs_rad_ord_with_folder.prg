CREATE PROGRAM bhs_rad_ord_with_folder
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  o_activity_type_cdf = uar_get_code_meaning(o.activity_type_cd), o.activity_type_cd,
  o_activity_type_disp = uar_get_code_display(o.activity_type_cd),
  o_catalog_cdf = uar_get_code_meaning(o.catalog_cd), o.catalog_cd, o_catalog_disp =
  uar_get_code_display(o.catalog_cd),
  e_catalog_cdf = uar_get_code_meaning(e.catalog_cd), e.catalog_cd, e_catalog_disp =
  uar_get_code_display(e.catalog_cd),
  e_image_class_type_cdf = uar_get_code_meaning(e.image_class_type_cd), e.image_class_type_cd,
  e_image_class_type_disp = uar_get_code_display(e.image_class_type_cd),
  e_lib_group_cdf = uar_get_code_meaning(e.lib_group_cd), e.lib_group_cd, e_lib_group_disp =
  uar_get_code_display(e.lib_group_cd),
  l.service_resource_cd, l_service_resource_disp = uar_get_code_display(l.service_resource_cd),
  l_service_resource_cdf = uar_get_code_meaning(l.service_resource_cd),
  lg.lib_group_cd, lg_lib_group_disp = uar_get_code_display(lg.lib_group_cd), lg_lib_group_cdf =
  uar_get_code_meaning(lg.lib_group_cd),
  lg.service_resource_cd, lg_service_resource_disp = uar_get_code_display(lg.service_resource_cd),
  lg_service_resource_cdf = uar_get_code_meaning(lg.service_resource_cd)
  FROM order_catalog o,
   exam_folder e,
   library_group l,
   lib_grp_reltn lg
  PLAN (o
   WHERE o.catalog_type_cd=2517)
   JOIN (e
   WHERE e.catalog_cd=o.catalog_cd)
   JOIN (lg
   WHERE lg.lib_group_cd=e.lib_group_cd)
   JOIN (l
   WHERE l.service_resource_cd=lg.service_resource_cd)
  WITH nocounter, separator = " ", format
 ;end select
END GO
