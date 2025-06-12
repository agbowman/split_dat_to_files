CREATE PROGRAM dd2buildpgm
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Last Name UPPERCASE " = "*"
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
   WHERE (p.name_last_key= $2)
    AND p.birth_dt_tm > cnvtdatetime(cnvtdate(123189),0))
   JOIN (e
   WHERE e.person_id=p.person_id
    AND ((e.disch_dt_tm BETWEEN cnvtdatetime((curdate - 30),0) AND cnvtdatetime(curdate,235959)) OR (
   e.disch_dt_tm=null))
    AND e.loc_nurse_unit_cd >= 10000)
  ORDER BY p.name_last, e.loc_nurse_unit_cd
  HEAD REPORT
   expr4 = format(curdate,"MMM DD, YYYY")
  HEAD PAGE
   row + 2, col 4,
   CALL print(format(curpage,"##")),
   col 41, "EXAMPLE REPORT - REV 7", col 79,
   expr4, row + 2, col 4,
   "PERSON ID", col 35, "LAST NAME",
   col 72, "FIRST NAME", row + 1,
   line1 = fillstring(8,"_"), line2 = fillstring(11,"_"), line3 = fillstring(12,"_"),
   col 4, line1, col 35,
   line2, col 72, line3,
   row + 1
  DETAIL
   IF (((row+ 2) >= maxrow))
    BREAK
   ENDIF
   row + 1, col 4, expr3,
   row + 1, name_last1 = substring(1,40,p.name_last), name_first1 = substring(1,30,p.name_first),
   col 35, name_last1, col 75,
   name_first1, row + 2, col 4,
   "BIRTH DATE:", col 16, p.birth_dt_tm,
   col 54, "AGE:", col 60,
   expr1, row + 1
  FOOT REPORT
   row + 2, row + 2, col 47,
   "TOTAL:", col 54, count(p.seq)
  WITH maxrec = 100, maxcol = 250, time = value(maxsecs),
   noheading, format = variable
 ;end select
END GO
