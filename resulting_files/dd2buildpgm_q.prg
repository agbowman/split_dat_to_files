CREATE PROGRAM dd2buildpgm_q
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Last Name UPPERCASE " = "S*"
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SELECT INTO  $1
  p.name_first, p.name_last, p.birth_dt_tm"DD-MMM-YYYY  HH:MM:SS;;D",
  p.active_ind, p.person_id, e.encntr_id,
  e.disch_dt_tm, e.loc_nurse_unit_cd, loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd),
  e.loc_room_cd, loc_room_disp = uar_get_code_display(e.loc_room_cd), e.loc_bed_cd,
  loc_bed_disp = uar_get_code_display(e.loc_bed_cd), expr1 = cnvtage(p.birth_dt_tm), expr2 = concat(
   trim(p.name_first)," ",p.name_last),
  expr3 = format(p.person_id,";L")
  FROM person p,
   encounter e
  PLAN (p
   WHERE p.person_id=e.person_id)
   JOIN (e
   WHERE e.disch_dt_tm > cnvtdatetime(cnvtdate(123189),0))
  ORDER BY p.name_last, e.loc_nurse_unit_cd
  WITH format, maxrec = 100, maxcol = 250,
   time = value(maxsecs)
 ;end select
END GO
