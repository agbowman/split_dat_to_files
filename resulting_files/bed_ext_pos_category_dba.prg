CREATE PROGRAM bed_ext_pos_category:dba
 SELECT INTO "CER_INSTALL:ps_pos_category.csv"
  FROM br_position_category b
  ORDER BY b.description
  HEAD REPORT
   "action_flag,category,step_cat_mean"
  DETAIL
   category = concat('"',trim(b.description),'"'), step_cat_mean = concat('"',trim(b.step_cat_mean),
    '"'), row + 1,
   line = concat("1,",trim(category),",",trim(step_cat_mean)), line
  WITH maxcol = 500, noformfeed, format = variable,
   nocounter
 ;end select
END GO
