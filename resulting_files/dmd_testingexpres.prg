CREATE PROGRAM dmd_testingexpres
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
  c.verified_dt_tm, p.name_first, expr2 = concat(trim(p.name_last_key),",  ",p.name_first_key),
  expr3 = cnvtage(p.birth_dt_tm), expr5 = cnvtupper(p.name_first)
  FROM person p,
   clinical_event c
  PLAN (p
   WHERE p.person_id != null
    AND p.birth_dt_tm >= cnvtdatetime(cnvtdate(123196),0))
   JOIN (c
   WHERE c.person_id=p.person_id)
  ORDER BY p.name_last_key
  HEAD REPORT
   expr1 = format(curdate,"DD MMM, YYYY;;D"), expr4 = format(curdate,";;d"), row 3,
   col 47, "PATIENT CLINICAL EVENTS", row + 1
  HEAD PAGE
   row + 1, col 7, "DATE:",
   col 15, expr4, col 88,
   "PAGE:", col 94, curpage,
   row + 1
  HEAD p.name_last_key
   row + 2, name_last_key1 = substring(1,25,p.name_last_key), name_first_key1 = substring(1,25,p
    .name_first_key),
   col 7, "NAME:", col 13,
   name_last_key1, col 50, name_first_key1,
   row + 1
  DETAIL
   IF (((row+ 3) >= maxrow))
    BREAK
   ENDIF
   row + 1, col 7, "CLINICAL",
   col 7, "EVENT:", col 7,
   "EVENT:", col 16, c.clinical_event_id,
   col 60, event_reltn_disp, row + 2,
   col 50, "RESULT:", col 60,
   result_status_disp, row + 1
  WITH maxrec = 50, maxcol = 500, time = value(maxsecs),
   noheading, format = variable
 ;end select
END GO
