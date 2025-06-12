CREATE PROGRAM bed_ext_app_group_rel:dba
 SET latest_start_version = 0
 SELECT DISTINCT INTO "NL:"
  b.start_version_nbr
  FROM br_client b
  ORDER BY b.start_version_nbr
  DETAIL
   latest_start_version = b.start_version_nbr
  WITH skipbedrock = 1, nocounter
 ;end select
 CALL echo(build("start version nbr = ",cnvtstring(latest_start_version)))
 SELECT INTO "cer_install:ps_app_group_rel.csv"
  FROM br_app_cat_comp b,
   code_value cv,
   br_app_category b2
  PLAN (b)
   JOIN (b2
   WHERE b2.category_id=b.category_id)
   JOIN (cv
   WHERE cv.active_ind=1
    AND cv.code_value=b.application_group_cd
    AND cv.start_version_nbr=latest_start_version)
  ORDER BY b.category_id, b.sequence
  HEAD REPORT
   "application_group, application_group_category"
  DETAIL
   group = concat('"',trim(cv.display),'"'), category = concat('"',trim(b2.description),'"'), row + 1,
   line = concat(trim(group),",",trim(category)), line
  WITH noformfeed, format = variable, nocounter
 ;end select
END GO
