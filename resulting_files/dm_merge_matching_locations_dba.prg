CREATE PROGRAM dm_merge_matching_locations:dba
 DECLARE dmml_src_id = f8
 DECLARE dmml_tgt_id = f8
 SET dmml_src_id = 0.0
 SET dmml_tgt_id = 0.0
 SELECT INTO "nl:"
  FROM v$database@loc_mrg_link
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("*")
  CALL echo("************************************************************")
  CALL echo("*")
  CALL echo("ERROR: Source database not found, please verify database link LOC_MRG_LINK is valid")
  CALL echo("*")
  CALL echo("************************************************************")
  CALL echo("*")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  l.info_number
  FROM dm_info@loc_mrg_link l
  WHERE l.info_domain="DATA MANAGEMENT"
   AND l.info_name="DM_ENV_ID"
  DETAIL
   dmml_src_id = l.info_number
  WITH nocounter
 ;end select
 IF (dmml_src_id=0.0)
  CALL echo("*")
  CALL echo("************************************************************")
  CALL echo("*")
  CALL echo("Fatal Error: source environment id not found")
  CALL echo("Plase use DM_SET_ENV_ID in SOURCE to set environment ID")
  CALL echo("*")
  CALL echo("************************************************************")
  CALL echo("*")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  i.info_number
  FROM dm_info i
  WHERE i.info_domain="DATA MANAGEMENT"
   AND i.info_name="DM_ENV_ID"
  DETAIL
   dmml_tgt_id = i.info_number
  WITH nocounter
 ;end select
 IF (dmml_tgt_id=0.0)
  CALL echo("*")
  CALL echo("************************************************************")
  CALL echo("*")
  CALL echo("Fatal Error: target environment id not found")
  CALL echo("Plase use DM_SET_ENV_ID in TARGET to set environment ID")
  CALL echo("*")
  CALL echo("************************************************************")
  CALL echo("*")
  GO TO exit_program
 ENDIF
 RECORD target_loc(
   1 qual[*]
     2 ui = vc
     2 from_rowid = vc
     2 from_value = f8
     2 to_rowid = vc
     2 to_value = f8
 )
 SET target_cnt = 0
 RECORD fac_loc(
   1 qual[*]
     2 description = vc
     2 display = vc
     2 from_rowid = vc
     2 from_value = f8
     2 to_rowid = vc
     2 to_value = f8
 )
 SET fac_cnt = 0
 SET matching_fac_cnt = 0
 SET source_loc_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="FACILITY"
  DETAIL
   source_loc_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET target_loc_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="FACILITY"
  DETAIL
   target_loc_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv2,
   location@loc_mrg_link l2
  WHERE l2.location_type_cd=source_loc_type_cd
   AND l2.location_cd=cv2.code_value
   AND cv2.active_ind=1
   AND cv2.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_merge_translate dmt1
   WHERE dmt1.from_value=l2.location_cd
    AND dmt1.table_name="CODE_VALUE"
    AND dmt1.env_source_id=dmml_src_id
    AND dmt1.env_target_id=dmml_tgt_id)))
  DETAIL
   fac_cnt = (fac_cnt+ 1), stat = alterlist(fac_loc->qual,fac_cnt), fac_loc->qual[fac_cnt].display =
   cv2.display,
   fac_loc->qual[fac_cnt].description = cv2.description, fac_loc->qual[fac_cnt].from_rowid = l2.rowid,
   fac_loc->qual[fac_cnt].from_value = l2.location_cd
  WITH nocounter
 ;end select
 IF (fac_cnt > 0)
  SELECT INTO dm_merge_matching_facilities
   FROM (dummyt d  WITH seq = value(fac_cnt)),
    code_value cv,
    location l
   PLAN (d)
    JOIN (cv
    WHERE (cv.display=fac_loc->qual[d.seq].display)
     AND (cv.description=fac_loc->qual[d.seq].description)
     AND cv.active_ind=1
     AND cv.code_set=220
     AND cv.display_key=cnvtupper(cnvtalphanum(fac_loc->qual[d.seq].display))
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.location_cd=cv.code_value
     AND l.location_type_cd=target_loc_type_cd)
   DETAIL
    fac_loc->qual[d.seq].to_rowid = l.rowid, fac_loc->qual[d.seq].to_value = l.location_cd,
    matching_fac_cnt = (matching_fac_cnt+ 1),
    "dm_merge_batch '", fac_loc->qual[d.seq].from_rowid, "', ;from rowid",
    row + 1, "               '", fac_loc->qual[d.seq].to_rowid,
    "', ;to rowid", row + 1, "               'LOCATION', ;table name",
    row + 1, "               'DM_MERGE_MATCHING_LOCATIONS', ;ref domain name", row + 1,
    "               1 go ;master ind, 1=source is master", row + 4
   WITH nocounter, formfeed = none, format = stream
  ;end select
  IF (matching_fac_cnt > 0)
   SELECT
    FROM (dummyt d  WITH seq = value(fac_cnt))
    PLAN (d
     WHERE (fac_loc->qual[d.seq].to_value > 0))
    HEAD REPORT
     row + 3, "The following details the matching facilties found. ", row + 1,
     matching_fac_cnt, " matching facilities were found. ", row + 1,
     fac_cnt, " facilities do not have a translation.", row + 3,
     "Including the file", row + 2, "          dm_merge_matching_facilities.dat",
     row + 2, "which can be found in CCLUSERDIR will merge these locations.", row + 3
    DETAIL
     "facility display ", fac_loc->qual[d.seq].display, row + 1,
     "facility description ", fac_loc->qual[d.seq].description, row + 1,
     "to_rowid ", fac_loc->qual[d.seq].to_rowid, row + 1,
     "to_value ", fac_loc->qual[d.seq].to_value, row + 1,
     "from_rowid ", fac_loc->qual[d.seq].from_rowid, row + 1,
     "from_value ", fac_loc->qual[d.seq].from_value, row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
  IF (matching_fac_cnt != fac_cnt)
   SET no_matches = (fac_cnt - matching_fac_cnt)
   SELECT
    FROM (dummyt d  WITH seq = value(fac_cnt))
    PLAN (d
     WHERE (fac_loc->qual[d.seq].to_value=0))
    HEAD REPORT
     "The following details those facilities that could not be matched.", row + 3, no_matches,
     " facilities do not have a match.", row + 3
    DETAIL
     row + 3, "facility display ", fac_loc->qual[d.seq].display,
     row + 1, "facility description ", fac_loc->qual[d.seq].description,
     row + 1, "from_rowid ", fac_loc->qual[d.seq].from_rowid,
     row + 1, "from_value ", fac_loc->qual[d.seq].from_value,
     row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
 ENDIF
 RECORD bdlg_loc(
   1 qual[*]
     2 description = vc
     2 display = vc
     2 from_rowid = vc
     2 from_value = f8
     2 to_rowid = vc
     2 to_value = f8
     2 parent_cd = f8
     2 parent_display = vc
     2 parent_description = vc
 )
 SET bdlg_cnt = 0
 SET matching_bdlg_cnt = 0
 SET source_loc_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="BUILDING"
  DETAIL
   source_loc_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET target_loc_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="BUILDING"
  DETAIL
   target_loc_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_merge_translate dmt,
   code_value@loc_mrg_link cv2,
   code_value@loc_mrg_link cv,
   location@loc_mrg_link l2,
   location_group@loc_mrg_link lg2
  WHERE l2.location_type_cd=source_loc_type_cd
   AND lg2.child_loc_cd=cv2.code_value
   AND cv2.active_ind=1
   AND cv2.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND dmt.from_value=lg2.parent_loc_cd
   AND dmt.table_name="CODE_VALUE"
   AND dmt.env_source_id=dmml_src_id
   AND dmt.env_target_id=dmml_tgt_id
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_merge_translate dmt1
   WHERE dmt1.from_value=lg2.child_loc_cd
    AND dmt1.table_name="CODE_VALUE"
    AND dmt1.env_source_id=dmml_src_id
    AND dmt1.env_target_id=dmml_tgt_id)))
   AND l2.location_cd=lg2.child_loc_cd
   AND cv.code_value=lg2.parent_loc_cd
  DETAIL
   bdlg_cnt = (bdlg_cnt+ 1), stat = alterlist(bdlg_loc->qual,bdlg_cnt), bdlg_loc->qual[bdlg_cnt].
   display = cv2.display,
   bdlg_loc->qual[bdlg_cnt].description = cv2.description, bdlg_loc->qual[bdlg_cnt].parent_cd = dmt
   .to_value, bdlg_loc->qual[bdlg_cnt].parent_display = cv.display,
   bdlg_loc->qual[bdlg_cnt].parent_description = cv.description, bdlg_loc->qual[bdlg_cnt].from_rowid
    = l2.rowid, bdlg_loc->qual[bdlg_cnt].from_value = l2.location_cd
  WITH nocounter
 ;end select
 IF (bdlg_cnt > 0)
  SELECT INTO dm_merge_matching_buildings
   FROM (dummyt d  WITH seq = value(bdlg_cnt)),
    code_value cv,
    location l,
    location_group lg
   PLAN (d)
    JOIN (lg
    WHERE (lg.parent_loc_cd=bdlg_loc->qual[d.seq].parent_cd))
    JOIN (cv
    WHERE cv.code_value=lg.child_loc_cd
     AND (cv.display=bdlg_loc->qual[d.seq].display)
     AND (cv.description=bdlg_loc->qual[d.seq].description)
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.location_cd=cv.code_value)
   DETAIL
    bdlg_loc->qual[d.seq].to_rowid = l.rowid, bdlg_loc->qual[d.seq].to_value = l.location_cd,
    matching_bdlg_cnt = (matching_bdlg_cnt+ 1),
    "dm_merge_batch '", bdlg_loc->qual[d.seq].from_rowid, "', ;from rowid",
    row + 1, "               '", bdlg_loc->qual[d.seq].to_rowid,
    "', ;to rowid", row + 1, "               'LOCATION', ;table name",
    row + 1, "               'DM_MERGE_MATCHING_LOCATIONS', ;ref domain name", row + 1,
    "               1 go ;master ind, 1=source is master", row + 4
   WITH nocounter, formfeed = none, format = stream
  ;end select
  IF (matching_bdlg_cnt > 0)
   SELECT
    FROM (dummyt d  WITH seq = value(bdlg_cnt))
    PLAN (d
     WHERE (bdlg_loc->qual[d.seq].to_value > 0))
    HEAD REPORT
     row + 3, "The following details the matching buildings found. ", row + 1,
     "Only buildings within merged facilities were considered. ", row + 1, matching_bdlg_cnt,
     " matching buildings were found. ", row + 1, bdlg_cnt,
     " buildings do not have a translation.", row + 3, "Including the file",
     row + 2, "          dm_merge_matching_buildings.dat", row + 2,
     "which can be found in CCLUSERDIR will merge these locations.", row + 3
    DETAIL
     "building display ", bdlg_loc->qual[d.seq].display, row + 1,
     "building description ", bdlg_loc->qual[d.seq].description, row + 1,
     "to_rowid ", bdlg_loc->qual[d.seq].to_rowid, row + 1,
     "to_value ", bdlg_loc->qual[d.seq].to_value, row + 1,
     "from_rowid ", bdlg_loc->qual[d.seq].from_rowid, row + 1,
     "from_value ", bdlg_loc->qual[d.seq].from_value, row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
  IF (matching_bdlg_cnt != bdlg_cnt)
   SET no_matches = (bdlg_cnt - matching_bdlg_cnt)
   SELECT
    FROM (dummyt d  WITH seq = value(bdlg_cnt))
    PLAN (d
     WHERE (bdlg_loc->qual[d.seq].to_value=0))
    HEAD REPORT
     "The following details those buildings that could not be matched.", row + 3,
     "Only buildings within merged facilities were considered. ",
     row + 1, no_matches, " buildings do not have a match.",
     row + 3
    DETAIL
     row + 3, "facility display ", bdlg_loc->qual[d.seq].parent_display,
     row + 1, "facility description ", bdlg_loc->qual[d.seq].parent_description,
     row + 1, "building display ", bdlg_loc->qual[d.seq].display,
     row + 1, "building description ", bdlg_loc->qual[d.seq].description,
     row + 1, "from_rowid ", bdlg_loc->qual[d.seq].from_rowid,
     row + 1, "from_value ", bdlg_loc->qual[d.seq].from_value,
     row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
 ENDIF
 RECORD nu_loc(
   1 qual[*]
     2 description = vc
     2 display = vc
     2 location_type_cd = f8
     2 from_rowid = vc
     2 from_value = f8
     2 to_rowid = vc
     2 to_value = f8
     2 bdlg_cd = f8
     2 bdlg_display = vc
     2 bdlg_description = vc
     2 fac_cd = f8
     2 fac_display = vc
     2 fac_description = vc
 )
 SET nu_cnt = 0
 SET matching_nu_cnt = 0
 SET source_loc_type_cd1 = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="NURSEUNIT"
  DETAIL
   source_loc_type_cd1 = cv.code_value
  WITH nocounter
 ;end select
 SET source_loc_type_cd2 = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="AMBULATORY"
  DETAIL
   source_loc_type_cd2 = cv.code_value
  WITH nocounter
 ;end select
 SET target_loc_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="NURSEUNIT"
  DETAIL
   target_loc_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  nu_cv.display, nu_cv.description, nu.rowid,
  nu.location_cd, bdlg.code_value, bdlg.display,
  bdlg.description, fac.code_value, fac.display,
  fac.description
  FROM dm_merge_translate dmt,
   location_group@loc_mrg_link bdlg_fac,
   code_value@loc_mrg_link fac,
   code_value@loc_mrg_link nu_cv,
   code_value@loc_mrg_link bdlg,
   location_group@loc_mrg_link nu_bdlg,
   location@loc_mrg_link nu
  WHERE ((nu.location_type_cd=source_loc_type_cd1) OR (nu.location_type_cd=source_loc_type_cd2))
   AND nu.location_cd=nu_bdlg.child_loc_cd
   AND nu.location_cd=nu_cv.code_value
   AND nu_bdlg.active_ind=1
   AND dmt.from_value=nu_bdlg.parent_loc_cd
   AND dmt.table_name="CODE_VALUE"
   AND dmt.env_source_id=dmml_src_id
   AND dmt.env_target_id=dmml_tgt_id
   AND nu_cv.active_ind=1
   AND nu_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND nu_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_merge_translate dmt1
   WHERE dmt1.from_value=nu.location_cd
    AND dmt1.table_name="CODE_VALUE"
    AND dmt1.env_source_id=dmml_src_id
    AND dmt1.env_target_id=dmml_tgt_id)))
   AND bdlg.code_value=nu_bdlg.parent_loc_cd
   AND nu_bdlg.parent_loc_cd=bdlg_fac.child_loc_cd
   AND bdlg_fac.active_ind=1
   AND fac.code_value=bdlg_fac.parent_loc_cd
  ORDER BY nu.location_cd
  HEAD nu.location_cd
   nu_cnt = (nu_cnt+ 1), stat = alterlist(nu_loc->qual,nu_cnt), nu_loc->qual[nu_cnt].display = nu_cv
   .display,
   nu_loc->qual[nu_cnt].description = nu_cv.description, nu_loc->qual[nu_cnt].location_type_cd = nu
   .location_type_cd, nu_loc->qual[nu_cnt].from_rowid = nu.rowid,
   nu_loc->qual[nu_cnt].from_value = nu.location_cd, nu_loc->qual[nu_cnt].bdlg_cd = dmt.to_value,
   nu_loc->qual[nu_cnt].bdlg_display = bdlg.display,
   nu_loc->qual[nu_cnt].bdlg_description = bdlg.description, nu_loc->qual[nu_cnt].fac_cd = fac
   .code_value, nu_loc->qual[nu_cnt].fac_display = fac.display,
   nu_loc->qual[nu_cnt].fac_description = fac.description
  DETAIL
   y = 1
  WITH nocounter
 ;end select
 IF (nu_cnt > 0)
  SELECT INTO dm_merge_matching_nurseunits
   FROM (dummyt d  WITH seq = value(nu_cnt)),
    location_group bdlg_nu,
    location nu,
    code_value nu_cv
   PLAN (d)
    JOIN (nu_cv
    WHERE (nu_cv.display=nu_loc->qual[d.seq].display)
     AND (nu_cv.description=nu_loc->qual[d.seq].description)
     AND nu_cv.active_ind=1
     AND nu_cv.code_set=220
     AND nu_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND nu_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND nu_cv.display_key=cnvtupper(cnvtalphanum(nu_loc->qual[d.seq].display)))
    JOIN (bdlg_nu
    WHERE nu_cv.code_value=bdlg_nu.child_loc_cd
     AND (bdlg_nu.parent_loc_cd=nu_loc->qual[d.seq].bdlg_cd)
     AND bdlg_nu.active_ind=1)
    JOIN (nu
    WHERE nu.location_cd=nu_cv.code_value
     AND (nu.location_type_cd=nu_loc->qual[d.seq].location_type_cd))
   ORDER BY d.seq
   HEAD d.seq
    nu_loc->qual[d.seq].to_rowid = nu.rowid, nu_loc->qual[d.seq].to_value = nu.location_cd,
    matching_nu_cnt = (matching_nu_cnt+ 1),
    "dm_merge_batch '", nu_loc->qual[d.seq].from_rowid, "', ;from rowid",
    row + 1, "               '", nu_loc->qual[d.seq].to_rowid,
    "', ;to rowid", row + 1, "               'LOCATION', ;table name",
    row + 1, "               'DM_MERGE_MATCHING_LOCATIONS', ;ref domain name", row + 1,
    "               1 go ;master ind, 1=source is master", row + 4
   DETAIL
    y = 1
   WITH nocounter, formfeed = none, format = stream
  ;end select
  IF (matching_nu_cnt > 0)
   SELECT
    FROM (dummyt d  WITH seq = value(nu_cnt))
    PLAN (d
     WHERE (nu_loc->qual[d.seq].to_value > 0))
    HEAD REPORT
     row + 3, "The following details the matching nurse units found. ", row + 1,
     "Only nurse units within merged buildings were considered. ", row + 1, matching_nu_cnt,
     " matching nurse units were found. ", row + 1, nu_cnt,
     " nurse units do not have a translation.", row + 3, "Including the file",
     row + 2, "          dm_merge_matching_nurseunits.dat", row + 2,
     "which can be found in CCLUSERDIR will merge these locations.", row + 3
    DETAIL
     "facility display ", nu_loc->qual[d.seq].fac_display, row + 1,
     "facility description ", nu_loc->qual[d.seq].fac_description, row + 1,
     "building display ", nu_loc->qual[d.seq].bdlg_display, row + 1,
     "building description ", nu_loc->qual[d.seq].bdlg_description, row + 1,
     "nurse unit display ", nu_loc->qual[d.seq].display, row + 1,
     "nurse unit description ", nu_loc->qual[d.seq].description, row + 1,
     "to_rowid ", nu_loc->qual[d.seq].to_rowid, row + 1,
     "to_value ", nu_loc->qual[d.seq].to_value, row + 1,
     "from_rowid ", nu_loc->qual[d.seq].from_rowid, row + 1,
     "from_value ", nu_loc->qual[d.seq].from_value, row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
  IF (matching_nu_cnt != nu_cnt)
   SET no_matches = (nu_cnt - matching_nu_cnt)
   SELECT
    FROM (dummyt d  WITH seq = value(nu_cnt))
    PLAN (d
     WHERE (nu_loc->qual[d.seq].to_value=0))
    HEAD REPORT
     "The following details those nurse units that could not be matched.", row + 3,
     "Only nurse units within merged buildings were considered. ",
     row + 1, no_matches, " nurse units do not have a match.",
     row + 3
    DETAIL
     row + 3, "facility display ", nu_loc->qual[d.seq].fac_display,
     row + 1, "facility description ", nu_loc->qual[d.seq].fac_description,
     row + 1, "building display ", nu_loc->qual[d.seq].bdlg_display,
     row + 1, "building description ", nu_loc->qual[d.seq].bdlg_description,
     row + 1, "nurse unit display ", nu_loc->qual[d.seq].display,
     row + 1, "nurse unit description ", nu_loc->qual[d.seq].description,
     row + 1, "from_rowid ", nu_loc->qual[d.seq].from_rowid,
     row + 1, "from_value ", nu_loc->qual[d.seq].from_value,
     row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
 ENDIF
 RECORD room_loc(
   1 qual[*]
     2 description = vc
     2 display = vc
     2 from_rowid = vc
     2 from_value = f8
     2 to_rowid = vc
     2 to_value = f8
     2 nu_cd = f8
     2 nu_display = vc
     2 nu_description = vc
     2 bdlg_cd = f8
     2 bdlg_display = vc
     2 bdlg_description = vc
     2 fac_cd = f8
     2 fac_display = vc
     2 fac_description = vc
 )
 SET room_cnt = 0
 SET matching_room_cnt = 0
 SET source_loc_type_cd1 = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="ROOM"
  DETAIL
   source_loc_type_cd1 = cv.code_value
  WITH nocounter
 ;end select
 SET source_loc_type_cd2 = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="AMBULATORY"
  DETAIL
   source_loc_type_cd2 = cv.code_value
  WITH nocounter
 ;end select
 SET target_loc_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="ROOM"
  DETAIL
   target_loc_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_merge_translate dmt,
   location_group@loc_mrg_link bdlg_fac,
   code_value@loc_mrg_link fac,
   code_value@loc_mrg_link nu_cv,
   code_value@loc_mrg_link bdlg,
   code_value@loc_mrg_link room_cv,
   location@loc_mrg_link room,
   location_group@loc_mrg_link nu_bdlg,
   location_group@loc_mrg_link room_nu
  WHERE ((room.location_type_cd=source_loc_type_cd1) OR (room.location_type_cd=source_loc_type_cd2))
   AND room_nu.child_loc_cd=room_cv.code_value
   AND room_nu.active_ind=1
   AND dmt.from_value=room_nu.parent_loc_cd
   AND dmt.table_name="CODE_VALUE"
   AND dmt.env_source_id=dmml_src_id
   AND dmt.env_target_id=dmml_tgt_id
   AND room_cv.active_ind=1
   AND room_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND room_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_merge_translate dmt1
   WHERE dmt1.from_value=room_cv.code_value
    AND dmt1.table_name="CODE_VALUE"
    AND dmt1.env_source_id=dmml_src_id
    AND dmt1.env_target_id=dmml_tgt_id)))
   AND room.location_cd=room_cv.code_value
   AND room_nu.parent_loc_cd=nu_bdlg.child_loc_cd
   AND nu_bdlg.parent_loc_cd=bdlg_fac.child_loc_cd
   AND nu_cv.code_value=room_nu.parent_loc_cd
   AND bdlg.code_value=nu_bdlg.parent_loc_cd
   AND fac.code_value=bdlg_fac.parent_loc_cd
  ORDER BY room.location_cd
  HEAD room.location_cd
   room_cnt = (room_cnt+ 1), stat = alterlist(room_loc->qual,room_cnt), room_loc->qual[room_cnt].
   display = room_cv.display,
   room_loc->qual[room_cnt].description = room_cv.description, room_loc->qual[room_cnt].from_rowid =
   room.rowid, room_loc->qual[room_cnt].from_value = room.location_cd,
   room_loc->qual[room_cnt].nu_display = nu_cv.display, room_loc->qual[room_cnt].nu_description =
   nu_cv.description, room_loc->qual[room_cnt].nu_cd = dmt.to_value,
   room_loc->qual[room_cnt].bdlg_cd = bdlg.code_value, room_loc->qual[room_cnt].bdlg_display = bdlg
   .display, room_loc->qual[room_cnt].bdlg_description = bdlg.description,
   room_loc->qual[room_cnt].fac_cd = fac.code_value, room_loc->qual[room_cnt].fac_display = fac
   .display, room_loc->qual[room_cnt].fac_description = fac.description
  DETAIL
   y = 1
  WITH nocounter
 ;end select
 IF (room_cnt > 0)
  SELECT INTO dm_merge_matching_rooms
   FROM (dummyt d  WITH seq = value(room_cnt)),
    location_group room_nu,
    location room,
    code_value room_cv
   PLAN (d)
    JOIN (room_cv
    WHERE (room_cv.display=room_loc->qual[d.seq].display)
     AND (room_cv.description=room_loc->qual[d.seq].description)
     AND room_cv.active_ind=1
     AND room_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND room_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND room_cv.code_set=220
     AND room_cv.display_key=cnvtupper(cnvtalphanum(room_loc->qual[d.seq].display)))
    JOIN (room_nu
    WHERE room_cv.code_value=room_nu.child_loc_cd
     AND (room_nu.parent_loc_cd=room_loc->qual[d.seq].nu_cd)
     AND room_nu.active_ind=1)
    JOIN (room
    WHERE room.location_cd=room_cv.code_value)
   ORDER BY d.seq
   HEAD d.seq
    room_loc->qual[d.seq].to_rowid = room.rowid, room_loc->qual[d.seq].to_value = room.location_cd,
    matching_room_cnt = (matching_room_cnt+ 1),
    "dm_merge_batch '", room_loc->qual[d.seq].from_rowid, "', ;from rowid",
    row + 1, "               '", room_loc->qual[d.seq].to_rowid,
    "', ;to rowid", row + 1, "               'LOCATION', ;table name",
    row + 1, "               'DM_MERGE_MATCHING_LOCATIONS', ;ref domain name", row + 1,
    "               1 go ;master ind, 1=source is master", row + 4
   DETAIL
    y = 1
   WITH nocounter, formfeed = none, format = stream
  ;end select
 ENDIF
 IF (matching_room_cnt > 0)
  SELECT
   FROM (dummyt d  WITH seq = value(room_cnt))
   PLAN (d
    WHERE (room_loc->qual[d.seq].to_value > 0))
   HEAD REPORT
    row + 3, "The following details the matching rooms found. ", row + 1,
    "Only rooms within merged nurse units were considered. ", row + 1, matching_room_cnt,
    " matching rooms were found. ", row + 1, room_cnt,
    " rooms do not have a translation.", row + 3, "Including the file",
    row + 2, "          dm_merge_matching_rooms.dat", row + 2,
    "which can be found in CCLUSERDIR will merge these locations.", row + 3
   DETAIL
    "facility display ", room_loc->qual[d.seq].fac_display, row + 1,
    "facility description ", room_loc->qual[d.seq].fac_description, row + 1,
    "building display ", room_loc->qual[d.seq].bdlg_display, row + 1,
    "building description ", room_loc->qual[d.seq].bdlg_description, row + 1,
    "nurse unit display ", room_loc->qual[d.seq].nu_display, row + 1,
    "nurse unit description ", room_loc->qual[d.seq].nu_description, row + 1,
    "room display ", room_loc->qual[d.seq].display, row + 1,
    "room description ", room_loc->qual[d.seq].description, row + 1,
    "to_rowid ", room_loc->qual[d.seq].to_rowid, row + 1,
    "to_value ", room_loc->qual[d.seq].to_value, row + 1,
    "from_rowid ", room_loc->qual[d.seq].from_rowid, row + 1,
    "from_value ", room_loc->qual[d.seq].from_value, row + 3
   WITH nocounter, formfeed = none, format = stream
  ;end select
 ENDIF
 IF (matching_room_cnt != room_cnt)
  SET no_matches = (room_cnt - matching_room_cnt)
  SELECT
   FROM (dummyt d  WITH seq = value(room_cnt))
   PLAN (d
    WHERE (room_loc->qual[d.seq].to_value=0))
   HEAD REPORT
    "The following details those rooms that could not be matched.", row + 3,
    "Only rooms within merged nurse units were considered. ",
    row + 1, no_matches, " rooms do not have a match.",
    row + 3
   DETAIL
    row + 3, "facility display ", room_loc->qual[d.seq].fac_display,
    row + 1, "facility description ", room_loc->qual[d.seq].fac_description,
    row + 1, "building display ", room_loc->qual[d.seq].bdlg_display,
    row + 1, "building description ", room_loc->qual[d.seq].bdlg_description,
    row + 1, "nurse unit display ", room_loc->qual[d.seq].nu_display,
    row + 1, "nurse unit description ", room_loc->qual[d.seq].nu_description,
    row + 1, "room display ", room_loc->qual[d.seq].display,
    row + 1, "room description ", room_loc->qual[d.seq].description,
    row + 1, "from_rowid ", room_loc->qual[d.seq].from_rowid,
    row + 1, "from_value ", room_loc->qual[d.seq].from_value,
    row + 3
   WITH nocounter, formfeed = none, format = stream
  ;end select
 ENDIF
 RECORD bed_loc(
   1 qual[*]
     2 description = vc
     2 display = vc
     2 from_rowid = vc
     2 from_value = f8
     2 to_rowid = vc
     2 to_value = f8
     2 room_cd = f8
     2 room_display = vc
     2 room_description = vc
     2 nu_cd = f8
     2 nu_display = vc
     2 nu_description = vc
     2 bdlg_cd = f8
     2 bdlg_display = vc
     2 bdlg_description = vc
     2 fac_cd = f8
     2 fac_display = vc
     2 fac_description = vc
 )
 SET bed_cnt = 0
 SET matching_bed_cnt = 0
 SET source_loc_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="BED"
  DETAIL
   source_loc_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET target_loc_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="BED"
  DETAIL
   target_loc_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_merge_translate dmt,
   location_group@loc_mrg_link bdlg_fac,
   code_value@loc_mrg_link fac,
   code_value@loc_mrg_link nu_cv,
   code_value@loc_mrg_link bdlg,
   code_value@loc_mrg_link room_cv,
   code_value@loc_mrg_link bed_cv,
   location@loc_mrg_link bed,
   location_group@loc_mrg_link nu_bdlg,
   location_group@loc_mrg_link room_nu,
   location_group@loc_mrg_link bed_room
  WHERE bed.location_type_cd=source_loc_type_cd
   AND bed_room.child_loc_cd=bed_cv.code_value
   AND bed_room.active_ind=1
   AND dmt.from_value=bed_room.parent_loc_cd
   AND dmt.table_name="CODE_VALUE"
   AND dmt.env_source_id=dmml_src_id
   AND dmt.env_target_id=dmml_tgt_id
   AND bed_cv.active_ind=1
   AND bed_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND bed_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_merge_translate dmt1
   WHERE dmt1.from_value=bed_cv.code_value
    AND dmt1.table_name="CODE_VALUE"
    AND dmt1.env_source_id=dmml_src_id
    AND dmt1.env_target_id=dmml_tgt_id)))
   AND bed.location_cd=bed_cv.code_value
   AND bed_room.parent_loc_cd=room_nu.child_loc_cd
   AND room_nu.parent_loc_cd=nu_bdlg.child_loc_cd
   AND nu_bdlg.parent_loc_cd=bdlg_fac.child_loc_cd
   AND room_cv.code_value=bed_room.parent_loc_cd
   AND nu_cv.code_value=room_nu.parent_loc_cd
   AND bdlg.code_value=nu_bdlg.parent_loc_cd
   AND fac.code_value=bdlg_fac.parent_loc_cd
  ORDER BY bed.location_cd
  HEAD bed.location_cd
   bed_cnt = (bed_cnt+ 1), stat = alterlist(bed_loc->qual,bed_cnt), bed_loc->qual[bed_cnt].display =
   bed_cv.display,
   bed_loc->qual[bed_cnt].description = bed_cv.description, bed_loc->qual[bed_cnt].from_rowid = bed
   .rowid, bed_loc->qual[bed_cnt].from_value = bed.location_cd,
   bed_loc->qual[bed_cnt].room_display = room_cv.display, bed_loc->qual[bed_cnt].room_description =
   room_cv.description, bed_loc->qual[bed_cnt].room_cd = dmt.to_value,
   bed_loc->qual[bed_cnt].nu_display = nu_cv.display, bed_loc->qual[bed_cnt].nu_description = nu_cv
   .description, bed_loc->qual[bed_cnt].nu_cd = nu_cv.code_value,
   bed_loc->qual[bed_cnt].bdlg_cd = bdlg.code_value, bed_loc->qual[bed_cnt].bdlg_display = bdlg
   .display, bed_loc->qual[bed_cnt].bdlg_description = bdlg.description,
   bed_loc->qual[bed_cnt].fac_cd = fac.code_value, bed_loc->qual[bed_cnt].fac_display = fac.display,
   bed_loc->qual[bed_cnt].fac_description = fac.description
  DETAIL
   y = 1
  WITH nocounter
 ;end select
 IF (bed_cnt > 0)
  SELECT INTO dm_merge_matching_beds
   FROM (dummyt d  WITH seq = value(bed_cnt)),
    location_group bed_room,
    location bed,
    code_value bed_cv
   PLAN (d)
    JOIN (bed_cv
    WHERE (bed_cv.display=bed_loc->qual[d.seq].display)
     AND (bed_cv.description=bed_loc->qual[d.seq].description)
     AND bed_cv.active_ind=1
     AND bed_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bed_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND bed_cv.code_set=220
     AND bed_cv.display_key=cnvtupper(cnvtalphanum(bed_loc->qual[d.seq].display)))
    JOIN (bed_room
    WHERE bed_cv.code_value=bed_room.child_loc_cd
     AND (bed_room.parent_loc_cd=bed_loc->qual[d.seq].room_cd)
     AND bed_room.active_ind=1)
    JOIN (bed
    WHERE bed.location_cd=bed_cv.code_value)
   ORDER BY d.seq
   HEAD d.seq
    bed_loc->qual[d.seq].to_rowid = bed.rowid, bed_loc->qual[d.seq].to_value = bed.location_cd,
    matching_bed_cnt = (matching_bed_cnt+ 1),
    "dm_merge_batch '", bed_loc->qual[d.seq].from_rowid, "', ;from rowid",
    row + 1, "               '", bed_loc->qual[d.seq].to_rowid,
    "', ;to rowid", row + 1, "               'LOCATION', ;table name",
    row + 1, "               'DM_MERGE_MATCHING_LOCATIONS', ;ref domain name", row + 1,
    "               1 go ;master ind, 1=source is master", row + 4
   DETAIL
    y = 1
   WITH nocounter, formfeed = none, format = stream
  ;end select
 ENDIF
 IF (matching_bed_cnt > 0)
  SELECT
   FROM (dummyt d  WITH seq = value(bed_cnt))
   PLAN (d
    WHERE (bed_loc->qual[d.seq].to_value > 0))
   HEAD REPORT
    row + 3, "The following details the matching beds found. ", row + 1,
    "Only beds within merged nurse units were considered. ", row + 1, matching_bed_cnt,
    " matching beds were found. ", row + 1, bed_cnt,
    " beds do not have a translation.", row + 3, "Including the file",
    row + 2, "          dm_merge_matching_beds.dat", row + 2,
    "which can be found in CCLUSERDIR will merge these locations.", row + 3
   DETAIL
    "facility display ", bed_loc->qual[d.seq].fac_display, row + 1,
    "facility description ", bed_loc->qual[d.seq].fac_description, row + 1,
    "building display ", bed_loc->qual[d.seq].bdlg_display, row + 1,
    "building description ", bed_loc->qual[d.seq].bdlg_description, row + 1,
    "nurse unit display ", bed_loc->qual[d.seq].nu_display, row + 1,
    "nurse unit description ", bed_loc->qual[d.seq].nu_description, row + 1,
    "room display ", bed_loc->qual[d.seq].room_display, row + 1,
    "room description ", bed_loc->qual[d.seq].room_description, row + 1,
    "bed display ", bed_loc->qual[d.seq].display, row + 1,
    "bed description ", bed_loc->qual[d.seq].description, row + 1,
    "to_rowid ", bed_loc->qual[d.seq].to_rowid, row + 1,
    "to_value ", bed_loc->qual[d.seq].to_value, row + 1,
    "from_rowid ", bed_loc->qual[d.seq].from_rowid, row + 1,
    "from_value ", bed_loc->qual[d.seq].from_value, row + 3
   WITH nocounter, formfeed = none, format = stream
  ;end select
 ENDIF
 IF (matching_bed_cnt != bed_cnt)
  SET no_matches = (bed_cnt - matching_bed_cnt)
  SELECT
   FROM (dummyt d  WITH seq = value(bed_cnt))
   PLAN (d
    WHERE (bed_loc->qual[d.seq].to_value=0))
   HEAD REPORT
    "The following details those beds that could not be matched.", row + 3,
    "Only beds within merged nurse units were considered. ",
    row + 1, no_matches, " beds do not have a match.",
    row + 3
   DETAIL
    row + 3, "facility display ", bed_loc->qual[d.seq].fac_display,
    row + 1, "facility description ", bed_loc->qual[d.seq].fac_description,
    row + 1, "building display ", bed_loc->qual[d.seq].bdlg_display,
    row + 1, "building description ", bed_loc->qual[d.seq].bdlg_description,
    row + 1, "nurse unit display ", bed_loc->qual[d.seq].nu_display,
    row + 1, "nurse unit description ", bed_loc->qual[d.seq].nu_description,
    row + 1, "room display ", bed_loc->qual[d.seq].room_display,
    row + 1, "room description ", bed_loc->qual[d.seq].room_description,
    row + 1, "bed display ", bed_loc->qual[d.seq].display,
    row + 1, "bed description ", bed_loc->qual[d.seq].description,
    row + 1, "from_rowid ", bed_loc->qual[d.seq].from_rowid,
    row + 1, "from_value ", bed_loc->qual[d.seq].from_value,
    row + 3
   WITH nocounter, formfeed = none, format = stream
  ;end select
 ENDIF
#exit_program
END GO
