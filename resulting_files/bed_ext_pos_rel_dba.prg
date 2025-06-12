CREATE PROGRAM bed_ext_pos_rel:dba
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
 SELECT INTO "CER_INSTALL:ps_position_rel.csv"
  FROM br_position_cat_comp b,
   code_value cv,
   br_position_category b2
  PLAN (b)
   JOIN (b2
   WHERE b2.category_id=b.category_id)
   JOIN (cv
   WHERE cv.active_ind=1
    AND cv.code_value=b.position_cd
    AND cv.start_version_nbr=latest_start_version)
  ORDER BY b.category_id, b.sequence
  HEAD REPORT
   "action_flag,position,category,physician_ind"
  DETAIL
   position = concat('"',trim(cv.display),'"'), category = concat('"',trim(b2.description),'"'), row
    + 1,
   line = concat("1,",trim(position),",",trim(category),",",
    trim(cnvtstring(b.physician_ind))), line
  WITH noformfeed, format = variable, nocounter
 ;end select
END GO
