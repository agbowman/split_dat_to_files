CREATE PROGRAM dmd_reporttestg
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $1
  p.birth_dt_tm"DD-MMM-YYYY  HH:MM:SS;;D", p.name_first_key, p.name_last_key,
  p.person_id, p.sex_cd, sex_disp = uar_get_code_display(p.sex_cd),
  c.clinical_event_id, c.event_reltn_cd, event_reltn_disp = uar_get_code_display(c.event_reltn_cd),
  c.result_status_cd, result_status_disp = uar_get_code_display(c.result_status_cd), c
  .performed_dt_tm,
  c.verified_dt_tm, expr2 = concat(trim(p.name_last_key),",  ",p.name_first_key), expr3 = cnvtage(p
   .birth_dt_tm)
  FROM person p,
   clinical_event c
  PLAN (p
   WHERE p.person_id != null
    AND p.birth_dt_tm >= cnvtdatetime(cnvtdate(123196),0))
   JOIN (c
   WHERE c.person_id=p.person_id)
  ORDER BY p.name_last_key
  HEAD REPORT
   expr1 = format(curdate,"DD MMM, YYYY;;D"), expr4 = curdate, printpsheader = 0,
   col 0, "{PS/0 0 translate 90 rotate/}", row + 1
  HEAD PAGE
   IF (printpsheader)
    col 0, "{PS/0 0 translate 90 rotate/}", row + 1
   ENDIF
   printpsheader = 1, row + 2, col 7,
   "DATE:", col 13, expr1,
   row + 2, col 88, "PAGE:",
   col 94, curpage, row + 1
  HEAD p.name_last_key
   row + 2, name_first_key1 = substring(1,90,p.name_first_key), name_last_key1 = substring(1,25,p
    .name_last_key),
   col 7, "NAME:", col 13,
   name_last_key1, col 643, name_first_key1,
   row + 1
  DETAIL
   IF (((row+ 4) >= maxrow))
    BREAK
   ENDIF
   row + 1, col 7, "CLINICAL",
   col 7, "EVENT:", col 220,
   c.clinical_event_id, col 630, result_status_disp,
   row + 2, col 470, "RESULT:",
   col 600, event_reltn_disp, row + 1
  FOOT  p.name_last_key
   row + 2, BREAK
  WITH maxrec = 50, maxcol = 800, time = value(maxsecs),
   noheading, format = variable, dio = "POSTSCRIPT"
 ;end select
END GO
