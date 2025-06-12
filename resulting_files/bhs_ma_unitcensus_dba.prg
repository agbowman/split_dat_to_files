CREATE PROGRAM bhs_ma_unitcensus:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the desired Nurse Unit" = ""
  WITH outdev, nurseunit
 EXECUTE cclseclogin
 DECLARE nur_sta = f8
 SET nur_sta = cnvtreal( $NURSEUNIT)
 CALL echo(build("prt_loc = ",prt_loc))
 CALL echo(build("$1 = ", $1))
 CALL echo(build("$2 = ", $2))
 CALL echo(build("nur_sta =",nur_sta))
 DECLARE mrn_cd = f8
 SET mrn_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_cd)
 DECLARE fin_cd = f8
 SET fin_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_cd)
 SELECT INTO  $OUTDEV
  o.active_ind, o.organization_id, o.ft_entity_id,
  o.ft_entity_name, o.org_name, l.active_ind,
  l.organization_id, l.location_cd, l.location_type_cd,
  l_location_type_disp = uar_get_code_display(l.location_type_cd), l_location_disp = trim(
   uar_get_code_display(l.location_cd)), r_location_disp = trim(uar_get_code_display(r.location_cd)),
  r.loc_nurse_unit_cd, r_loc_nurse_unit_disp = uar_get_code_display(r.loc_nurse_unit_cd),
  b_loc_room_disp = uar_get_code_display(b.loc_room_cd),
  b.location_cd, b_location_disp = trim(uar_get_code_display(b.location_cd)), b_loc_bed_disp =
  uar_get_code_display(b.loc_room_cd),
  ed.encntr_id, ed.person_id, ed.loc_building_cd,
  e_loc_building_disp = uar_get_code_display(ed.loc_building_cd), ed.loc_facility_cd,
  e_loc_facility_disp = uar_get_code_display(ed.loc_facility_cd),
  ed.loc_nurse_unit_cd, e_loc_nurse_unit_disp = uar_get_code_display(ed.loc_nurse_unit_cd), ed
  .loc_room_cd,
  e_loc_room_disp = uar_get_code_display(ed.loc_room_cd), ed.loc_bed_cd, e_loc_bed_disp =
  uar_get_code_display(ed.loc_bed_cd),
  e_end_effdt = ed.end_effective_dt_tm"dd-mmm-yyyy ;;d", l.location_type_cd, b.loc_room_cd,
  r.location_cd, p_name = substring(1,30,p.name_full_formatted), p_sex_cd = uar_get_code_display(p
   .sex_cd),
  p_birthdt = p.birth_dt_tm"dd-mmm-yyyy ;;d", fac_mrn = ea2.alias, fin_num = ea.alias,
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
   WHERE l.location_cd=cnvtreal( $NURSEUNIT)
    AND l.active_ind=1)
   JOIN (r
   WHERE r.loc_nurse_unit_cd=l.location_cd)
   JOIN (b
   WHERE b.loc_room_cd=r.location_cd)
   JOIN (o
   WHERE o.organization_id=l.organization_id)
   JOIN (ed
   WHERE ed.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
    AND ed.loc_facility_cd > 0
    AND ed.loc_building_cd > 0
    AND ed.loc_nurse_unit_cd=r.loc_nurse_unit_cd
    AND ed.loc_room_cd=r.location_cd
    AND ed.loc_room_cd > 0
    AND ed.loc_bed_cd=b.location_cd
    AND ed.loc_bed_cd > 0)
   JOIN (p
   WHERE p.person_id=ed.person_id)
   JOIN (ea
   WHERE ea.encntr_id=ed.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (ea2
   WHERE ea2.encntr_id=ed.encntr_id
    AND ea2.encntr_alias_type_cd=mrn_cd
    AND ea2.active_ind=1
    AND ea2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (en
   WHERE en.encntr_id=ed.encntr_id
    AND en.active_ind=1
    AND en.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
  ORDER BY o.org_name, r_loc_nurse_unit_disp, b_loc_room_disp,
   b_loc_bed_disp
  HEAD REPORT
   cnt = 0, date_stamp = format(curdate,"mm/dd/yyyy;;d"), time_stamp = format(curtime3,"hh:mm;;m"),
   line = fillstring(28,"="), bigline = fillstring(108,"=")
  HEAD PAGE
   col 0,
   CALL center("BAYSTATE HEALTH SYSTEMS",1,108), row + 1,
   page_stamp = format(curpage,"###;P0"), col 1, date_stamp,
   " ", time_stamp, col 48,
   CALL center(curprog,1,108), col 100, "PAGE ",
   page_stamp, row + 1
  HEAD r_loc_nurse_unit_disp
   line, row + 1, col 1,
   "BED CENSUS REPORT - ", col 21, r_loc_nurse_unit_disp,
   row + 1, line, row + 2,
   col 1, "UNIT", col 8,
   "ROOM", col 15, "BED",
   col 20, "PAT TYPE", col 35,
   "PATIENT NAME", col 66, "SEX",
   col 74, "BIRTH DATE", col 87,
   "MR NUMBER", col 97, "ACCT NUMBER",
   row + 1, bigline, row + 2
  DETAIL
   col 1, l_location_disp, col 8,
   r_location_disp, col 15, b_location_disp,
   col 20, enc_type, col 35,
   p_name, col 66, p_sex_cd,
   col 74, p_birthdt, col 87,
   fac_mrn, col 97, fin_num,
   row + 1
   IF (trim(p_name) != "")
    cnt = (cnt+ 1)
   ENDIF
   IF (row > 56)
    BREAK
   ENDIF
  FOOT  r_loc_nurse_unit_disp
   row + 1, col 1, "TOTAL OCCUPIED BEDS FOR UNIT ",
   col 30, r_loc_nurse_unit_disp, col 35,
   ": ", col 37, cnt"###",
   row + 2, cnt = 0, BREAK
  WITH maxrow = 60, maxcol = 1000
 ;end select
END GO
