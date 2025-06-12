CREATE PROGRAM dmd_enctrs
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Enter Arrival Date " = 121497
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $1
  e.encntr_id, e.encntr_type_cd, encntr_type_disp = uar_get_code_display(e.encntr_type_cd),
  e.arrive_dt_tm"MM-DD-YY  HH:MM:SS;;D", e.disch_dt_tm"DD-MMM-YYYY  HH:MM:SS;;D", e.loc_nurse_unit_cd,
  loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd), p.birth_dt_tm, p.sex_cd,
  sex_disp = uar_get_code_display(p.sex_cd), p.race_cd, race_disp = uar_get_code_display(p.race_cd),
  p.religion_cd, religion_disp = uar_get_code_display(p.religion_cd), p.name_first_key,
  p.name_last_key, expr1 = substring(1,35,p.name_first_key), expr2 = substring(1,35,p.name_last_key)
  FROM encounter e,
   person p
  PLAN (e
   WHERE e.arrive_dt_tm >= cnvtdatetime(cnvtdate( $2),0))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.name_last_key != " ")
  ORDER BY cnvtdatetime(e.arrive_dt_tm) DESC
  HEAD REPORT
   expr3 = format(curdate,"mm/dd/yy;;d")
  HEAD PAGE
   row + 2, col 16, expr2,
   col 67, expr1, row + 1
  DETAIL
   IF (((row+ 3) >= maxrow))
    BREAK
   ENDIF
   row + 1, col 7, "ARRIVAL:",
   col 18, e.arrive_dt_tm, row + 1,
   col 10, "ENCOUNTER TYPE:", col 28,
   encntr_type_disp, row + 2, col 18,
   "NURSING UNIT:", col 32, loc_nurse_unit_disp,
   row + 1
  WITH maxrec = 100, maxcol = 500, time = value(maxsecs),
   noheading, format = variable
 ;end select
END GO
