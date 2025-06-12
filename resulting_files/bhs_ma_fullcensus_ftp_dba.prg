CREATE PROGRAM bhs_ma_fullcensus_ftp:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev, var_fac_cd
 EXECUTE bhs_check_domain:dba
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_nurse_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",222,"NURSEUNITS"))
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_ma_fullcensus_ftp/"))
 DECLARE mf_bnh_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE HOSPITAL"))
 DECLARE mf_bnh_rehab_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE REHABILITATION"))
 DECLARE mf_bnhinptpsych_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE HOSPITAL INPATIENT PSYCHIATRY"))
 DECLARE mf_bfmc_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE FRANKLIN MEDICAL CENTER"))
 DECLARE mf_bfmcinptpsych_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE FRANKLIN MEDICAL CENTER INPATIENT PSYCHIATRY"))
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value= $VAR_FAC_CD)
   AND cv.code_set=220
  DETAIL
   ms_file_name = cv.display_key
  WITH nocounter
 ;end select
 SET ms_file_name = build(cnvtlower(ms_file_name),"_bed_census_report",format(curdate,"MM/DD/YY ;;D"),
  ".pdf")
 SET ms_file_name = replace(ms_file_name,"/","_",0)
 SET ms_file_name = replace(ms_file_name," ","_",0)
 SET ms_file_name = build(ms_loc_dir,ms_file_name)
 SELECT INTO value(ms_file_name)
  l_location_disp = trim(uar_get_code_display(l.location_cd)), r_location_disp = trim(
   uar_get_code_display(r.location_cd)), r_loc_nurse_unit_disp = uar_get_code_display(r
   .loc_nurse_unit_cd),
  b_location_disp = trim(uar_get_code_display(b.location_cd)), p_name = substring(1,30,p
   .name_full_formatted), p_sex_cd = uar_get_code_display(p.sex_cd),
  p_birthdt = p.birth_dt_tm"DD-MMM-YYYY ;;D", fac_mrn = ea2.alias, fin_num = ea.alias,
  enc_type = uar_get_code_display(en.encntr_type_cd)
  FROM organization o,
   location l,
   room r,
   bed b,
   encntr_domain ed,
   person p,
   encntr_alias ea,
   encntr_alias ea2,
   encounter en
  PLAN (l
   WHERE l.location_type_cd=mf_nurse_unit_cd
    AND l.organization_id != 766418
    AND l.active_ind=1)
   JOIN (r
   WHERE r.loc_nurse_unit_cd=l.location_cd)
   JOIN (b
   WHERE b.loc_room_cd=r.location_cd)
   JOIN (o
   WHERE o.organization_id=l.organization_id)
   JOIN (ed
   WHERE ed.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
    AND (ed.loc_facility_cd= $VAR_FAC_CD)
    AND ed.loc_building_cd > 0
    AND ed.loc_nurse_unit_cd=r.loc_nurse_unit_cd
    AND ed.loc_room_cd=r.location_cd
    AND ed.loc_room_cd > 0
    AND ed.loc_bed_cd=b.location_cd
    AND ed.loc_bed_cd > 0
    AND ed.active_ind=1)
   JOIN (p
   WHERE p.person_id=ed.person_id)
   JOIN (ea
   WHERE ea.encntr_id=ed.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND  NOT (ea.alias IN ("480003558", "142997021", "486581912", "143834876"))
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (ea2
   WHERE ea2.encntr_id=ed.encntr_id
    AND ea2.encntr_alias_type_cd=mf_mrn_cd
    AND ea2.active_ind=1
    AND ea2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea2.end_effective_dt_tm > sysdate)
   JOIN (en
   WHERE en.encntr_id=ed.encntr_id
    AND en.active_ind=1
    AND en.beg_effective_dt_tm <= cnvtdatetime(sysdate))
  ORDER BY o.org_name, l_location_disp, r_location_disp,
   b_location_disp
  HEAD REPORT
   cnt = 0, date_stamp = format(curdate,"MM/DD/YYYY;;D"), time_stamp = format(curtime3,"HH:MM;;M"),
   line = fillstring(28,"="), bigline = fillstring(96,"=")
  HEAD PAGE
   col 0,
   CALL center("BAYSTATE HEALTH SYSTEMS",1,96), row + 1,
   page_stamp = format(curpage,"###;p0"), col 0, date_stamp,
   " ", time_stamp, col 48,
   CALL center(curprog,1,96), col 88, "page ",
   page_stamp, row + 1
  HEAD r_loc_nurse_unit_disp
   line, row + 1, col 0,
   "BED CENSUS REPORT - ", col 21, r_loc_nurse_unit_disp,
   row + 1, line, row + 2,
   col 0, "UNIT", col 7,
   "ROOM", col 14, "BED",
   col 18, "PAT TYPE", col 30,
   "PATIENT NAME", col 56, "SEX",
   col 64, "BIRTH DATE", col 77,
   "MRN #", col 87, "ACCT #",
   row + 1, bigline, row + 2
  DETAIL
   col 0, l_location_disp, col 7,
   r_location_disp, col 14, b_location_disp,
   col 18, enc_type, col 30,
   p_name, col 56, p_sex_cd,
   col 63, p_birthdt, col 77,
   fac_mrn, col 87, fin_num,
   row + 1
   IF (trim(p_name) != "")
    cnt += 1
   ENDIF
   IF (row > 56)
    BREAK
   ENDIF
  FOOT  r_loc_nurse_unit_disp
   row + 1, col 0, "TOTAL OCCUPIED BEDS FOR UNIT ",
   col 30, r_loc_nurse_unit_disp, col 38,
   ": ", col 40, cnt"###",
   row + 2, cnt = 0, BREAK
  WITH dio = pdf, maxrow = 60, maxcol = 1000
 ;end select
END GO
