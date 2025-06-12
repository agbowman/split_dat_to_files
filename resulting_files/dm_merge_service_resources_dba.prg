CREATE PROGRAM dm_merge_service_resources:dba
 DECLARE dmsr_src_id = f8
 DECLARE dmsr_tgt_id = f8
 SET dmsr_src_id = 0.0
 SET dmsr_tgt_id = 0.0
 SELECT INTO "nl:"
  FROM v$database@loc_mrg_link
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("*")
  CALL echo("************************************************************")
  CALL echo("*")
  CALL echo("Source database not found, please verify database link LOC_MRG_LINK is valid")
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
   dmsr_src_id = l.info_number
  WITH nocounter
 ;end select
 IF (dmsr_src_id=0.0)
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
   dmsr_tgt_id = i.info_number
  WITH nocounter
 ;end select
 IF (dmsr_tgt_id=0.0)
  CALL echo("*")
  CALL echo("************************************************************")
  CALL echo("*")
  CALL echo("Fatal Error: target environment id not found")
  CALL echo("Plase use DM_SET_ENV_ID in TARGET to set environment ID")
  CALL echo("*")
  CALL echo("************************************************************")
  GO TO exit_program
 ENDIF
 RECORD target_res(
   1 qual[*]
     2 ui = vc
     2 from_rowid = vc
     2 to_rowid = vc
     2 from_value = f8
     2 to_value = f8
 )
 SET target_cnt = 0
 RECORD ins_res(
   1 qual[*]
     2 description = vc
     2 display = vc
     2 from_rowid = vc
     2 to_rowid = vc
     2 from_value = f8
     2 to_value = f8
 )
 SET ins_cnt = 0
 SET matching_ins_cnt = 0
 SET source_res_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="INSTITUTION"
  DETAIL
   source_res_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET target_res_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="INSTITUTION"
  DETAIL
   target_res_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link ins_cv,
   service_resource@loc_mrg_link ins
  WHERE ins.service_resource_type_cd=source_res_type_cd
   AND ins.service_resource_cd=ins_cv.code_value
   AND ins_cv.active_ind=1
   AND ins_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND ins_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_merge_translate dmt1
   WHERE dmt1.from_value=ins.service_resource_cd
    AND dmt1.table_name="CODE_VALUE"
    AND dmt1.env_source_id=dmsr_src_id
    AND dmt1.env_target_id=dmsr_tgt_id)))
  DETAIL
   ins_cnt = (ins_cnt+ 1), stat = alterlist(ins_res->qual,ins_cnt), ins_res->qual[ins_cnt].display =
   ins_cv.display,
   ins_res->qual[ins_cnt].description = ins_cv.description, ins_res->qual[ins_cnt].from_rowid = ins
   .rowid, ins_res->qual[ins_cnt].from_value = ins.service_resource_cd
  WITH nocounter
 ;end select
 IF (ins_cnt > 0)
  SELECT INTO dm_merge_matching_institutions
   FROM (dummyt d  WITH seq = value(ins_cnt)),
    code_value ins_cv,
    service_resource ins
   PLAN (d)
    JOIN (ins_cv
    WHERE (ins_cv.display=ins_res->qual[d.seq].display)
     AND (ins_cv.description=ins_res->qual[d.seq].description)
     AND ins_cv.active_ind=1
     AND ins_cv.code_set=221
     AND ins_cv.display_key=cnvtupper(cnvtalphanum(ins_res->qual[d.seq].display))
     AND ins_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ins_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (ins
    WHERE ins.service_resource_cd=ins_cv.code_value
     AND ins.service_resource_type_cd=target_res_type_cd)
   DETAIL
    ins_res->qual[d.seq].to_rowid = ins.rowid, ins_res->qual[d.seq].to_value = ins
    .service_resource_cd, matching_ins_cnt = (matching_ins_cnt+ 1),
    "dm_merge_batch '", ins_res->qual[d.seq].from_rowid, "', ;from rowid",
    row + 1, "               '", ins_res->qual[d.seq].to_rowid,
    "', ;to rowid", row + 1, "               'SERVICE_RESOURCE', ;table name",
    row + 1, "               'DM_MERGE_SERVICE_RESOURCES', ;ref domain name", row + 1,
    "               1 go ;master ind, 1 = source is master", row + 4
   WITH nocounter, formfeed = none, format = stream
  ;end select
  IF (matching_ins_cnt > 0)
   SELECT
    FROM (dummyt d  WITH seq = value(ins_cnt))
    PLAN (d
     WHERE (ins_res->qual[d.seq].to_value > 0))
    HEAD REPORT
     row + 3, "The following details the matching institutions found. ", row + 1,
     matching_ins_cnt, " matching institutions were found. ", row + 1,
     ins_cnt, " institutions do not have a translation.", row + 3,
     "Including the file", row + 2, "          dm_merge_matching_institutions.dat",
     row + 2, "which can be found in CCLUSERDIR will merge these service resources.", row + 3
    DETAIL
     "institution display ", ins_res->qual[d.seq].display, row + 1,
     "institution description ", ins_res->qual[d.seq].description, row + 1,
     "to_rowid ", ins_res->qual[d.seq].to_rowid, row + 1,
     "from_rowid ", ins_res->qual[d.seq].from_rowid, row + 1,
     "to_value ", ins_res->qual[d.seq].to_value, row + 1,
     "from_value ", ins_res->qual[d.seq].from_value, row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
  IF (matching_ins_cnt != ins_cnt)
   SET no_matches = (ins_cnt - matching_ins_cnt)
   SELECT
    FROM (dummyt d  WITH seq = value(ins_cnt))
    PLAN (d
     WHERE (ins_res->qual[d.seq].to_value=0))
    HEAD REPORT
     "The following details those institutions that could not be matched.", row + 3, no_matches,
     " institutions do not have a match.", row + 3
    DETAIL
     row + 3, "institution display ", ins_res->qual[d.seq].display,
     row + 1, "institution description ", ins_res->qual[d.seq].description,
     row + 1, "from_rowid ", ins_res->qual[d.seq].from_rowid,
     row + 1, "from_value ", ins_res->qual[d.seq].from_value,
     row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
 ENDIF
 RECORD dept_res(
   1 qual[*]
     2 description = vc
     2 display = vc
     2 from_rowid = vc
     2 to_rowid = vc
     2 from_value = f8
     2 to_value = f8
     2 ins_cd = f8
     2 ins_display = vc
     2 ins_description = vc
 )
 SET dept_cnt = 0
 SET matching_dept_cnt = 0
 SET source_res_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="DEPARTMENT"
  DETAIL
   source_res_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET target_res_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="DEPARTMENT"
  DETAIL
   target_res_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_merge_translate dmt1,
   code_value@loc_mrg_link dept_cv,
   code_value@loc_mrg_link ins_cv,
   service_resource@loc_mrg_link dept,
   resource_group@loc_mrg_link ins_dept
  WHERE dept.service_resource_type_cd=source_res_type_cd
   AND ins_dept.child_service_resource_cd=dept_cv.code_value
   AND dept_cv.active_ind=1
   AND dept_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND dept_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND dmt1.from_value=ins_dept.parent_service_resource_cd
   AND dmt1.table_name="CODE_VALUE"
   AND dmt1.env_source_id=dmsr_src_id
   AND dmt1.env_target_id=dmsr_tgt_id
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_merge_translate dmt2
   WHERE dmt2.from_value=ins_dept.child_service_resource_cd
    AND dmt2.table_name="CODE_VALUE"
    AND dmt2.env_source_id=dmsr_src_id
    AND dmt2.env_target_id=dmsr_tgt_id)))
   AND dept.service_resource_cd=ins_dept.child_service_resource_cd
   AND ins_cv.code_value=ins_dept.parent_service_resource_cd
   AND ins_dept.active_ind=1
   AND ins_dept.child_service_resource_cd=dept_cv.code_value
  DETAIL
   dept_cnt = (dept_cnt+ 1), stat = alterlist(dept_res->qual,dept_cnt), dept_res->qual[dept_cnt].
   display = dept_cv.display,
   dept_res->qual[dept_cnt].description = dept_cv.description, dept_res->qual[dept_cnt].ins_cd = dmt1
   .to_value, dept_res->qual[dept_cnt].ins_display = ins_cv.display,
   dept_res->qual[dept_cnt].ins_description = ins_cv.description, dept_res->qual[dept_cnt].from_rowid
    = dept.rowid, dept_res->qual[dept_cnt].from_value = dept.service_resource_cd
  WITH nocounter
 ;end select
 IF (dept_cnt > 0)
  SELECT INTO dm_merge_matching_departments
   FROM (dummyt d  WITH seq = value(dept_cnt)),
    code_value dept_cv,
    service_resource dept,
    resource_group ins_dept
   PLAN (d)
    JOIN (ins_dept
    WHERE (ins_dept.parent_service_resource_cd=dept_res->qual[d.seq].ins_cd))
    JOIN (dept_cv
    WHERE dept_cv.code_value=ins_dept.child_service_resource_cd
     AND (dept_cv.display=dept_res->qual[d.seq].display)
     AND (dept_cv.description=dept_res->qual[d.seq].description)
     AND dept_cv.active_ind=1
     AND dept_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND dept_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (dept
    WHERE dept.service_resource_cd=dept_cv.code_value)
   DETAIL
    dept_res->qual[d.seq].to_rowid = dept.rowid, dept_res->qual[d.seq].to_value = dept
    .service_resource_cd, matching_dept_cnt = (matching_dept_cnt+ 1),
    "dm_merge_batch '", dept_res->qual[d.seq].from_rowid, "', ;from rowid",
    row + 1, "               '", dept_res->qual[d.seq].to_rowid,
    "', ;to rowid", row + 1, "               'SERVICE_RESOURCE', ;table name",
    row + 1, "               'DM_MERGE_SERVICE_RESOURCES', ;ref domain name", row + 1,
    "               1 go ;master ind, 1 = source is master", row + 4
   WITH nocounter, formfeed = none, format = stream
  ;end select
  IF (matching_dept_cnt > 0)
   SELECT
    FROM (dummyt d  WITH seq = value(dept_cnt))
    PLAN (d
     WHERE (dept_res->qual[d.seq].to_value > 0))
    HEAD REPORT
     row + 3, "The following details the matching departments found. ", row + 1,
     "Only departments within merged institutions were considered. ", row + 1, matching_dept_cnt,
     " matching departments were found. ", row + 1, dept_cnt,
     " departments do not have a translation.", row + 3, "Including the file",
     row + 2, "          dm_merge_matching_departments.dat", row + 2,
     "which can be found in CCLUSERDIR will merge these service resources.", row + 3
    DETAIL
     "department display ", dept_res->qual[d.seq].display, row + 1,
     "department description ", dept_res->qual[d.seq].description, row + 1,
     "to_rowid ", dept_res->qual[d.seq].to_rowid, row + 1,
     "from_rowid ", dept_res->qual[d.seq].from_rowid, row + 1,
     "to_value ", dept_res->qual[d.seq].to_value, row + 1,
     "from_value ", dept_res->qual[d.seq].from_value, row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
  IF (matching_dept_cnt != dept_cnt)
   SET no_matches = (dept_cnt - matching_dept_cnt)
   SELECT
    FROM (dummyt d  WITH seq = value(dept_cnt))
    PLAN (d
     WHERE (dept_res->qual[d.seq].to_value=0))
    HEAD REPORT
     "The following details those departments that could not be matched.", row + 3,
     "Only departments within merged institutions were considered. ",
     row + 1, no_matches, " departments do not have a match.",
     row + 3
    DETAIL
     row + 3, "institution display ", dept_res->qual[d.seq].ins_display,
     row + 1, "institution description ", dept_res->qual[d.seq].ins_description,
     row + 1, "department display ", dept_res->qual[d.seq].display,
     row + 1, "department description ", dept_res->qual[d.seq].description,
     row + 1, "from_rowid ", dept_res->qual[d.seq].from_rowid,
     row + 1, "from_value ", dept_res->qual[d.seq].from_value,
     row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
 ENDIF
 RECORD sec_res(
   1 qual[*]
     2 description = vc
     2 display = vc
     2 from_rowid = vc
     2 to_rowid = vc
     2 from_value = f8
     2 to_value = f8
     2 dept_cd = f8
     2 dept_display = vc
     2 dept_description = vc
     2 ins_cd = f8
     2 ins_display = vc
     2 ins_description = vc
 )
 SET sec_cnt = 0
 SET matching_sec_cnt = 0
 SET source_res_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="SECTION"
  DETAIL
   source_res_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET target_res_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="SECTION"
  DETAIL
   target_res_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sec_cv.display, sec_cv.description, dept_cv.code_value,
  dept_cv.display, dept_cv.description, ins_cv.code_value,
  ins_cv.display, ins_cv.description, sec.rowid,
  sec.service_resource_cd
  FROM dm_merge_translate dmt1,
   resource_group@loc_mrg_link ins_dept,
   resource_group@loc_mrg_link dept_sec,
   code_value@loc_mrg_link ins_cv,
   code_value@loc_mrg_link dept_cv,
   code_value@loc_mrg_link sec_cv,
   service_resource@loc_mrg_link sec
  WHERE sec.service_resource_type_cd=source_res_type_cd
   AND sec.service_resource_cd=dept_sec.child_service_resource_cd
   AND sec.service_resource_cd=sec_cv.code_value
   AND dept_sec.active_ind=1
   AND dmt1.from_value=dept_sec.parent_service_resource_cd
   AND dmt1.table_name="CODE_VALUE"
   AND dmt1.env_source_id=dmsr_src_id
   AND dmt1.env_target_id=dmsr_tgt_id
   AND sec_cv.active_ind=1
   AND sec_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND sec_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM dm_merge_translate dmt2
   WHERE dmt2.from_value=sec.service_resource_cd
    AND dmt2.table_name="CODE_VALUE"
    AND dmt2.env_source_id=dmsr_src_id
    AND dmt2.env_target_id=dmsr_tgt_id)))
   AND dept_cv.code_value=dept_sec.parent_service_resource_cd
   AND dept_sec.parent_service_resource_cd=ins_dept.child_service_resource_cd
   AND ins_dept.active_ind=1
   AND ins_cv.code_value=ins_dept.parent_service_resource_cd
  ORDER BY sec.service_resource_cd
  HEAD sec.service_resource_cd
   sec_cnt = (sec_cnt+ 1), stat = alterlist(sec_res->qual,sec_cnt), sec_res->qual[sec_cnt].display =
   sec_cv.display,
   sec_res->qual[sec_cnt].description = sec_cv.description, sec_res->qual[sec_cnt].from_rowid = sec
   .rowid, sec_res->qual[sec_cnt].from_value = sec.service_resource_cd,
   sec_res->qual[sec_cnt].dept_cd = dmt1.to_value, sec_res->qual[sec_cnt].dept_display = dept_cv
   .display, sec_res->qual[sec_cnt].dept_description = dept_cv.description,
   sec_res->qual[sec_cnt].ins_cd = ins_cv.code_value, sec_res->qual[sec_cnt].ins_display = ins_cv
   .display, sec_res->qual[sec_cnt].ins_description = ins_cv.description
  DETAIL
   y = 1
  WITH nocounter
 ;end select
 IF (sec_cnt > 0)
  SELECT INTO dm_merge_matching_sections
   FROM (dummyt d  WITH seq = value(sec_cnt)),
    code_value sec_cv,
    service_resource sec,
    resource_group dept_sec
   PLAN (d)
    JOIN (sec_cv
    WHERE (sec_cv.display=sec_res->qual[d.seq].display)
     AND (sec_cv.description=sec_res->qual[d.seq].description)
     AND sec_cv.active_ind=1
     AND sec_cv.code_set=221
     AND sec_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND sec_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND sec_cv.display_key=cnvtupper(cnvtalphanum(sec_res->qual[d.seq].display)))
    JOIN (dept_sec
    WHERE sec_cv.code_value=dept_sec.child_service_resource_cd
     AND (dept_sec.parent_service_resource_cd=sec_res->qual[d.seq].dept_cd)
     AND dept_sec.active_ind=1)
    JOIN (sec
    WHERE sec.service_resource_cd=sec_cv.code_value)
   ORDER BY d.seq
   HEAD d.seq
    sec_res->qual[d.seq].to_rowid = sec.rowid, sec_res->qual[d.seq].to_value = sec
    .service_resource_cd, matching_sec_cnt = (matching_sec_cnt+ 1),
    "dm_merge_batch '", sec_res->qual[d.seq].from_rowid, "', ;from rowid",
    row + 1, "               '", sec_res->qual[d.seq].to_rowid,
    "', ;to rowid", row + 1, "               'SERVICE_RESOURCE', ;table name",
    row + 1, "               'DM_MERGE_SERVICE_RESOURCES', ;ref domain name", row + 1,
    "               1 go ;master ind, 1 = source is master", row + 4
   DETAIL
    y = 1
   WITH nocounter, formfeed = none, format = stream
  ;end select
  IF (matching_sec_cnt > 0)
   SELECT
    FROM (dummyt d  WITH seq = value(sec_cnt))
    PLAN (d
     WHERE (sec_res->qual[d.seq].to_value > 0))
    HEAD REPORT
     row + 3, "The following details the matching sections found. ", row + 1,
     "Only sections within merged departments were considered. ", row + 1, matching_sec_cnt,
     " matching sections were found. ", row + 1, sec_cnt,
     " sections do not have a translation.", row + 3, "Including the file",
     row + 2, "          dm_merge_matching_sections.dat", row + 2,
     "which can be found in CCLUSERDIR will merge these service resources.", row + 3
    DETAIL
     "institution display ", sec_res->qual[d.seq].ins_display, row + 1,
     "institution description ", sec_res->qual[d.seq].ins_description, row + 1,
     "department display ", sec_res->qual[d.seq].dept_display, row + 1,
     "department description ", sec_res->qual[d.seq].dept_description, row + 1,
     "section display ", sec_res->qual[d.seq].display, row + 1,
     "section description ", sec_res->qual[d.seq].description, row + 1,
     "from_rowid ", sec_res->qual[d.seq].from_rowid, row + 1,
     "to_rowid ", sec_res->qual[d.seq].to_rowid, row + 1,
     "from_value ", sec_res->qual[d.seq].from_value, row + 3,
     "to_value ", sec_res->qual[d.seq].to_value, row + 1
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
  IF (matching_sec_cnt != sec_cnt)
   SET no_matches = (sec_cnt - matching_sec_cnt)
   SELECT
    FROM (dummyt d  WITH seq = value(sec_cnt))
    PLAN (d
     WHERE (sec_res->qual[d.seq].to_value=0))
    HEAD REPORT
     "The following details those sections that could not be matched.", row + 3,
     "Only sections within merged departments were considered. ",
     row + 1, no_matches, " sections do not have a match.",
     row + 3
    DETAIL
     row + 3, "institution display ", sec_res->qual[d.seq].ins_display,
     row + 1, "institution description ", sec_res->qual[d.seq].ins_description,
     row + 1, "department display ", sec_res->qual[d.seq].dept_display,
     row + 1, "department description ", sec_res->qual[d.seq].dept_description,
     row + 1, "section display ", sec_res->qual[d.seq].display,
     row + 1, "section description ", sec_res->qual[d.seq].description,
     row + 1, "from_rowid ", sec_res->qual[d.seq].from_rowid,
     row + 1, "from_value ", sec_res->qual[d.seq].from_value,
     row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
 ENDIF
 RECORD subsec_res(
   1 qual[*]
     2 description = vc
     2 display = vc
     2 from_rowid = vc
     2 to_rowid = vc
     2 from_value = f8
     2 to_value = f8
     2 sec_cd = f8
     2 sec_display = vc
     2 sec_description = vc
     2 dept_cd = f8
     2 dept_display = vc
     2 dept_description = vc
     2 ins_cd = f8
     2 ins_display = vc
     2 ins_description = vc
 )
 SET subsec_cnt = 0
 SET matching_subsec_cnt = 0
 SET source_res_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="SUBSECTION"
  DETAIL
   source_res_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET target_res_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="SUBSECTION"
  DETAIL
   target_res_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_merge_translate dmt1,
   resource_group@loc_mrg_link ins_dept,
   resource_group@loc_mrg_link dept_sec,
   resource_group@loc_mrg_link sec_subsec,
   code_value@loc_mrg_link ins_cv,
   code_value@loc_mrg_link dept_cv,
   code_value@loc_mrg_link sec_cv,
   code_value@loc_mrg_link subsec_cv,
   service_resource@loc_mrg_link subsec
  WHERE subsec.service_resource_type_cd=source_res_type_cd
   AND sec_subsec.child_service_resource_cd=subsec_cv.code_value
   AND sec_subsec.active_ind=1
   AND dmt1.from_value=sec_subsec.parent_service_resource_cd
   AND dmt1.table_name="CODE_VALUE"
   AND dmt1.env_source_id=dmsr_src_id
   AND dmt1.env_target_id=dmsr_tgt_id
   AND subsec_cv.active_ind=1
   AND subsec_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND subsec_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_merge_translate dmt2
   WHERE dmt2.from_value=subsec_cv.code_value
    AND dmt2.table_name="CODE_VALUE"
    AND dmt2.env_source_id=dmsr_src_id
    AND dmt2.env_target_id=dmsr_tgt_id)))
   AND subsec.service_resource_cd=subsec_cv.code_value
   AND sec_subsec.parent_service_resource_cd=dept_sec.child_service_resource_cd
   AND dept_sec.parent_service_resource_cd=ins_dept.child_service_resource_cd
   AND sec_subsec.parent_service_resource_cd=sec_cv.code_value
   AND dept_sec.parent_service_resource_cd=dept_cv.code_value
   AND ins_dept.parent_service_resource_cd=ins_cv.code_value
  ORDER BY subsec.service_resource_cd
  HEAD subsec.service_resource_cd
   subsec_cnt = (subsec_cnt+ 1), stat = alterlist(subsec_res->qual,subsec_cnt), subsec_res->qual[
   subsec_cnt].display = subsec_cv.display,
   subsec_res->qual[subsec_cnt].description = subsec_cv.description, subsec_res->qual[subsec_cnt].
   from_rowid = subsec.rowid, subsec_res->qual[subsec_cnt].from_value = subsec.service_resource_cd,
   subsec_res->qual[subsec_cnt].sec_cd = dmt1.to_value, subsec_res->qual[subsec_cnt].sec_display =
   sec_cv.display, subsec_res->qual[subsec_cnt].sec_description = sec_cv.description,
   subsec_res->qual[subsec_cnt].dept_cd = dept_cv.code_value, subsec_res->qual[subsec_cnt].
   dept_display = dept_cv.display, subsec_res->qual[subsec_cnt].dept_description = dept_cv
   .description,
   subsec_res->qual[subsec_cnt].ins_cd = ins_cv.code_value, subsec_res->qual[subsec_cnt].ins_display
    = ins_cv.display, subsec_res->qual[subsec_cnt].ins_description = ins_cv.description
  DETAIL
   y = 1
  WITH nocounter
 ;end select
 IF (subsec_cnt > 0)
  SELECT INTO dm_merge_matching_subsections
   FROM (dummyt d  WITH seq = value(subsec_cnt)),
    code_value subsec_cv,
    service_resource subsec,
    resource_group sec_subsec
   PLAN (d)
    JOIN (subsec_cv
    WHERE (subsec_cv.display=subsec_res->qual[d.seq].display)
     AND (subsec_cv.description=subsec_res->qual[d.seq].description)
     AND subsec_cv.active_ind=1
     AND subsec_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND subsec_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND subsec_cv.code_set=221
     AND subsec_cv.display_key=cnvtupper(cnvtalphanum(subsec_res->qual[d.seq].display)))
    JOIN (sec_subsec
    WHERE subsec_cv.code_value=sec_subsec.child_service_resource_cd
     AND (sec_subsec.parent_service_resource_cd=subsec_res->qual[d.seq].sec_cd)
     AND sec_subsec.active_ind=1)
    JOIN (subsec
    WHERE subsec.service_resource_cd=subsec_cv.code_value)
   ORDER BY d.seq
   HEAD d.seq
    subsec_res->qual[d.seq].to_rowid = subsec.rowid, subsec_res->qual[d.seq].to_value = subsec
    .service_resource_cd, matching_subsec_cnt = (matching_subsec_cnt+ 1),
    "dm_merge_batch '", subsec_res->qual[d.seq].from_rowid, "', ;from rowid",
    row + 1, "               '", subsec_res->qual[d.seq].to_rowid,
    "', ;to rowid", row + 1, "               'SERVICE_RESOURCE', ;table name",
    row + 1, "               'DM_MERGE_SERVICE_RESOURCES', ;ref domain name", row + 1,
    "               1 go ;master ind, 1 = source is master", row + 4
   DETAIL
    y = 1
   WITH nocounter, formfeed = none, format = stream
  ;end select
  IF (matching_subsec_cnt > 0)
   SELECT
    FROM (dummyt d  WITH seq = value(subsec_cnt))
    PLAN (d
     WHERE (subsec_res->qual[d.seq].to_value > 0))
    HEAD REPORT
     row + 3, "The following details the matching subsections found. ", row + 1,
     "Only subsections within merged sections were considered. ", row + 1, matching_subsec_cnt,
     " matching subsections were found. ", row + 1, subsec_cnt,
     " subsections do not have a translation.", row + 3, "Including the file",
     row + 2, "          dm_merge_matching_subsections.dat", row + 2,
     "which can be found in CCLUSERDIR will merge these service resources.", row + 3
    DETAIL
     "institution display ", subsec_res->qual[d.seq].ins_display, row + 1,
     "institution description ", subsec_res->qual[d.seq].ins_description, row + 1,
     "department display ", subsec_res->qual[d.seq].dept_display, row + 1,
     "department description ", subsec_res->qual[d.seq].dept_description, row + 1,
     "section display ", subsec_res->qual[d.seq].sec_display, row + 1,
     "section description ", subsec_res->qual[d.seq].sec_description, row + 1,
     "subsection display ", subsec_res->qual[d.seq].display, row + 1,
     "subsection description ", subsec_res->qual[d.seq].description, row + 1,
     "from_rowid ", subsec_res->qual[d.seq].from_rowid, row + 1,
     "to_rowid ", subsec_res->qual[d.seq].to_rowid, row + 1,
     "from_value ", subsec_res->qual[d.seq].from_value, row + 3,
     "to_value ", subsec_res->qual[d.seq].to_value, row + 1
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
  IF (matching_subsec_cnt != subsec_cnt)
   SET no_matches = (subsec_cnt - matching_subsec_cnt)
   SELECT
    FROM (dummyt d  WITH seq = value(subsec_cnt))
    PLAN (d
     WHERE (subsec_res->qual[d.seq].to_value=0))
    HEAD REPORT
     "The following details those subsections that could not be matched.", row + 3,
     "Only subsections within merged sections were considered. ",
     row + 1, no_matches, " subsections do not have a match.",
     row + 3
    DETAIL
     row + 3, "institution display ", subsec_res->qual[d.seq].ins_display,
     row + 1, "institution description ", subsec_res->qual[d.seq].ins_description,
     row + 1, "department display ", subsec_res->qual[d.seq].dept_display,
     row + 1, "department description ", subsec_res->qual[d.seq].dept_description,
     row + 1, "section display ", subsec_res->qual[d.seq].sec_display,
     row + 1, "section description ", subsec_res->qual[d.seq].sec_description,
     row + 1, "subsection display ", subsec_res->qual[d.seq].display,
     row + 1, "subsection description ", subsec_res->qual[d.seq].description,
     row + 1, "from_rowid ", subsec_res->qual[d.seq].from_rowid,
     row + 1, "from_value ", subsec_res->qual[d.seq].from_value,
     row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
 ENDIF
 RECORD bench_res(
   1 qual[*]
     2 description = vc
     2 display = vc
     2 service_resource_type_cd = f8
     2 from_rowid = vc
     2 from_value = f8
     2 to_rowid = vc
     2 to_value = f8
     2 subsec_cd = f8
     2 subsec_display = vc
     2 subsec_description = vc
     2 sec_cd = f8
     2 sec_display = vc
     2 sec_description = vc
     2 dept_cd = f8
     2 dept_display = vc
     2 dept_description = vc
     2 ins_cd = f8
     2 ins_display = vc
     2 ins_description = vc
 )
 SET bench_cnt = 0
 SET matching_bench_cnt = 0
 SET source_res_type_cd1 = 0.0
 SET source_res_type_cd2 = 0.0
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="BENCH"
  DETAIL
   source_res_type_cd1 = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value@loc_mrg_link cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="INSTRUMENT"
  DETAIL
   source_res_type_cd2 = cv.code_value
  WITH nocounter
 ;end select
 SET target_res_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="BENCH"
  DETAIL
   target_res_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_merge_translate dmt1,
   code_value@loc_mrg_link ins_cv,
   code_value@loc_mrg_link dept_cv,
   code_value@loc_mrg_link sec_cv,
   code_value@loc_mrg_link subsec_cv,
   code_value@loc_mrg_link bench_cv,
   service_resource@loc_mrg_link bench,
   resource_group@loc_mrg_link ins_dept,
   resource_group@loc_mrg_link dept_sec,
   resource_group@loc_mrg_link sec_subsec,
   resource_group@loc_mrg_link subsec_bench
  WHERE ((bench.service_resource_type_cd=source_res_type_cd1) OR (bench.service_resource_type_cd=
  source_res_type_cd2))
   AND subsec_bench.child_service_resource_cd=bench_cv.code_value
   AND subsec_bench.active_ind=1
   AND dmt1.from_value=subsec_bench.parent_service_resource_cd
   AND dmt1.table_name="CODE_VALUE"
   AND dmt1.env_source_id=dmsr_src_id
   AND dmt1.env_target_id=dmsr_tgt_id
   AND bench_cv.active_ind=1
   AND bench_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND bench_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_merge_translate dmt2
   WHERE dmt2.from_value=bench_cv.code_value
    AND dmt2.table_name="CODE_VALUE"
    AND dmt2.env_source_id=dmsr_src_id
    AND dmt2.env_target_id=dmsr_tgt_id)))
   AND bench.service_resource_cd=bench_cv.code_value
   AND subsec_bench.parent_service_resource_cd=sec_subsec.child_service_resource_cd
   AND sec_subsec.parent_service_resource_cd=dept_sec.child_service_resource_cd
   AND dept_sec.parent_service_resource_cd=ins_dept.child_service_resource_cd
   AND subsec_cv.code_value=subsec_bench.parent_service_resource_cd
   AND sec_cv.code_value=sec_subsec.parent_service_resource_cd
   AND dept_cv.code_value=dept_sec.parent_service_resource_cd
   AND ins_cv.code_value=ins_dept.parent_service_resource_cd
  ORDER BY bench.service_resource_cd
  HEAD bench.service_resource_cd
   bench_cnt = (bench_cnt+ 1), stat = alterlist(bench_res->qual,bench_cnt), bench_res->qual[bench_cnt
   ].display = bench_cv.display,
   bench_res->qual[bench_cnt].description = bench_cv.description, bench_res->qual[bench_cnt].
   from_rowid = bench.rowid, bench_res->qual[bench_cnt].from_value = bench.service_resource_cd,
   bench_res->qual[bench_cnt].subsec_display = subsec_cv.display, bench_res->qual[bench_cnt].
   subsec_description = subsec_cv.description, bench_res->qual[bench_cnt].subsec_cd = dmt1.to_value,
   bench_res->qual[bench_cnt].sec_display = sec_cv.display, bench_res->qual[bench_cnt].
   sec_description = sec_cv.description, bench_res->qual[bench_cnt].sec_cd = sec_cv.code_value,
   bench_res->qual[bench_cnt].dept_cd = dept_cv.code_value, bench_res->qual[bench_cnt].dept_display
    = dept_cv.display, bench_res->qual[bench_cnt].dept_description = dept_cv.description,
   bench_res->qual[bench_cnt].ins_cd = ins_cv.code_value, bench_res->qual[bench_cnt].ins_display =
   ins_cv.display, bench_res->qual[bench_cnt].ins_description = ins_cv.description,
   bench_res->qual[bench_cnt].service_resource_type_cd = bench.service_resource_type_cd
  DETAIL
   y = 1
  WITH nocounter
 ;end select
 IF (bench_cnt > 0)
  SELECT INTO dm_merge_matching_benches
   FROM (dummyt d  WITH seq = value(bench_cnt)),
    resource_group subsec_bench,
    service_resource bench,
    code_value bench_cv
   PLAN (d)
    JOIN (bench_cv
    WHERE (bench_cv.display=bench_res->qual[d.seq].display)
     AND (bench_cv.description=bench_res->qual[d.seq].description)
     AND bench_cv.active_ind=1
     AND bench_cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bench_cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND bench_cv.code_set=221
     AND bench_cv.display_key=cnvtupper(cnvtalphanum(bench_res->qual[d.seq].display)))
    JOIN (subsec_bench
    WHERE bench_cv.code_value=subsec_bench.child_service_resource_cd
     AND (subsec_bench.parent_service_resource_cd=bench_res->qual[d.seq].subsec_cd)
     AND subsec_bench.active_ind=1)
    JOIN (bench
    WHERE bench.service_resource_cd=bench_cv.code_value
     AND (bench.service_resource_type_cd=bench_res->qual[bench_cnt].service_resource_type_cd))
   ORDER BY d.seq
   HEAD d.seq
    bench_res->qual[d.seq].to_rowid = bench.rowid, bench_res->qual[d.seq].to_value = bench
    .service_resource_cd, matching_bench_cnt = (matching_bench_cnt+ 1),
    "dm_merge_batch '", bench_res->qual[d.seq].from_rowid, "', ;from rowid",
    row + 1, "               '", bench_res->qual[d.seq].to_rowid,
    "', ;to rowid", row + 1, "               'SERVICE_RESOURCE', ;table name",
    row + 1, "               'DM_MERGE_SERVICE_RESOURCES', ;ref domain name", row + 1,
    "               1 go ;master ind, 1 = source is master", row + 4
   DETAIL
    y = 1
   WITH nocounter, formfeed = none, format = stream
  ;end select
  IF (matching_bench_cnt > 0)
   SELECT
    FROM (dummyt d  WITH seq = value(bench_cnt))
    PLAN (d
     WHERE (bench_res->qual[d.seq].to_value > 0))
    HEAD REPORT
     row + 3, "The following details the matching benches/instruments found. ", row + 1,
     "Only benches/instruments within merged subsections were considered. ", row + 1,
     matching_bench_cnt,
     " matching benchs/instruments were found. ", row + 1, bench_cnt,
     " benches/instruments do not have a translation.", row + 3, "Including the file",
     row + 2, "          dm_merge_matching_benches.dat", row + 2,
     "which can be found in CCLUSERDIR will merge these service resources.", row + 3
    DETAIL
     "institution display ", bench_res->qual[d.seq].ins_display, row + 1,
     "institution description ", bench_res->qual[d.seq].ins_description, row + 1,
     "department display ", bench_res->qual[d.seq].dept_display, row + 1,
     "department description ", bench_res->qual[d.seq].dept_description, row + 1,
     "section display ", bench_res->qual[d.seq].sec_display, row + 1,
     "section description ", bench_res->qual[d.seq].sec_description, row + 1,
     "subsection display ", bench_res->qual[d.seq].subsec_display, row + 1,
     "subsection description ", bench_res->qual[d.seq].subsec_description, row + 1,
     "bench display ", bench_res->qual[d.seq].display, row + 1,
     "bench description ", bench_res->qual[d.seq].description, row + 1,
     "to_rowid ", bench_res->qual[d.seq].to_rowid, row + 1,
     "to_value ", bench_res->qual[d.seq].to_value, row + 1,
     "from_rowid ", bench_res->qual[d.seq].from_rowid, row + 1,
     "from_value ", bench_res->qual[d.seq].from_value, row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
  IF (matching_bench_cnt != bench_cnt)
   SET no_matches = (bench_cnt - matching_bench_cnt)
   SELECT
    FROM (dummyt d  WITH seq = value(bench_cnt))
    PLAN (d
     WHERE (bench_res->qual[d.seq].to_value=0))
    HEAD REPORT
     "The following details those benches/instruments that could not be matched.", row + 3,
     "Only benches/instruments within merged subsections were considered. ",
     row + 1, no_matches, " benches/instruments do not have a match.",
     row + 3
    DETAIL
     row + 3, "institution display ", bench_res->qual[d.seq].ins_display,
     row + 1, "institution description ", bench_res->qual[d.seq].ins_description,
     row + 1, "department display ", bench_res->qual[d.seq].dept_display,
     row + 1, "department description ", bench_res->qual[d.seq].dept_description,
     row + 1, "section display ", bench_res->qual[d.seq].sec_display,
     row + 1, "section description ", bench_res->qual[d.seq].sec_description,
     row + 1, "subsection display ", bench_res->qual[d.seq].subsec_display,
     row + 1, "subsection description ", bench_res->qual[d.seq].subsec_description,
     row + 1, "bench display ", bench_res->qual[d.seq].display,
     row + 1, "bench description ", bench_res->qual[d.seq].description,
     row + 1, "from_rowid ", bench_res->qual[d.seq].from_rowid,
     row + 1, "from_value ", bench_res->qual[d.seq].from_value,
     row + 3
    WITH nocounter, formfeed = none, format = stream
   ;end select
  ENDIF
 ENDIF
#exit_program
END GO
