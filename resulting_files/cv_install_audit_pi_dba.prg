CREATE PROGRAM cv_install_audit_pi:dba
 PROMPT
  "Output:" = mine,
  "Debug(Y/N):" = "N"
 RECORD internal_cv(
   1 participant[*]
     2 cdf_display = vc
     2 part_nbr = vc
     2 part_displ = vc
     2 num_cases = i4
 )
 SET alias = fillstring(10," ")
 SELECT INTO "NL:"
  alias = substring(1,10,oa.alias), name = substring(1,40,o.org_name)
  FROM code_value cv,
   common_data_foundation cdf,
   organization_alias oa,
   organization o
  PLAN (cdf
   WHERE cdf.cdf_meaning IN ("CVNET_ACC_FA", "CVNET_STS_PA")
    AND cdf.code_set=263)
   JOIN (cv
   WHERE cv.code_set=263
    AND cv.cdf_meaning=cdf.cdf_meaning)
   JOIN (oa
   WHERE oa.alias_pool_cd=cv.code_value)
   JOIN (o
   WHERE o.organization_id=oa.organization_id)
  ORDER BY cv.cdf_meaning, o.org_name
  HEAD REPORT
   part_cnt = 0
  HEAD cv.cdf_meaning
   "Participants for ", cdf.display, row + 1
  DETAIL
   part_cnt = (part_cnt+ 1)
   IF (mod(part_cnt,10)=1)
    stat = alterlist(internal_cv->participant,(part_cnt+ 9))
   ENDIF
   internal_cv->participant[part_cnt].cdf_display = cdf.display, internal_cv->participant[part_cnt].
   part_nbr = oa.alias, internal_cv->participant[part_cnt].part_displ = o.org_name
   IF (cnvtupper( $2)="Y")
    col + 2, o.organization_id, col + 2,
    cv.code_value, col + 2, oa.organization_alias_id,
    col + 2, cdf.cdf_meaning
   ENDIF
   row + 1
  FOOT REPORT
   stat = alterlist(internal_cv->participant,part_cnt)
  WITH nocounter, maxcol = 200
 ;end select
 CALL echorecord(internal_cv)
 SELECT INTO "NL"
  FROM cv_case_dataset_r cdr,
   (dummyt d  WITH seq = value(size(internal_cv->participant,5)))
  PLAN (d)
   JOIN (cdr
   WHERE cdr.participant_nbr=trim(internal_cv->participant[d.seq].part_nbr))
  ORDER BY d.seq
  HEAD REPORT
   case_cnt = 0
  HEAD d.seq
   case_cnt = 0
  DETAIL
   case_cnt = (case_cnt+ 1)
  FOOT  d.seq
   internal_cv->participant[d.seq].num_cases = case_cnt
  WITH nocounter
 ;end select
 SELECT INTO  $1
  participant_type = internal_cv->participant[d.seq].cdf_display
  FROM (dummyt d  WITH seq = value(size(internal_cv->participant,5)))
  PLAN (d)
  ORDER BY participant_type
  HEAD REPORT
   CALL center("CVNet Usage Report",0,132), row + 1, col 0,
   "Dataset", col 30, "Facility Nbr",
   col 50, "Facility Name", col 100,
   "# of Cases", row + 1
  HEAD participant_type
   col 0, internal_cv->participant[d.seq].cdf_display, case_cnt = 0
  DETAIL
   col 30, internal_cv->participant[d.seq].part_nbr, col 50,
   internal_cv->participant[d.seq].part_displ, col 100, internal_cv->participant[d.seq].num_cases,
   row + 1, case_cnt = (case_cnt+ internal_cv->participant[d.seq].num_cases)
  FOOT  participant_type
   col 50, "Total Cases for this dataset", case_cnt,
   row + 1
  WITH nocounter
 ;end select
END GO
