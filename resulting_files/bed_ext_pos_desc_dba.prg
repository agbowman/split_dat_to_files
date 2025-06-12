CREATE PROGRAM bed_ext_pos_desc:dba
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
 SELECT INTO "CER_INSTALL:ps_pos_desc.csv"
  FROM br_long_text b,
   code_value cv
  PLAN (b
   WHERE b.parent_entity_name="CODE_VALUE")
   JOIN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1
    AND cv.code_value=b.parent_entity_id
    AND cv.start_version_nbr=latest_start_version)
  HEAD REPORT
   "position,description"
  DETAIL
   position = concat('"',trim(cv.display),'"'), description = concat('"',trim(b.long_text),'"'), row
    + 1,
   line = concat(trim(position),",",trim(description)), line
  WITH maxcol = 50000, noformfeed, format = variable,
   nocounter
 ;end select
END GO
