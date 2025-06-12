CREATE PROGRAM class_tgh_ex9
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SELECT INTO  $1
  p.name_full_formatted, p.person_id, p.birth_dt_tm,
  p.birth_dt_cd
  FROM person p
  HEAD REPORT
   line = fillstring(80,"*"), row 3, col 60,
   "Example Report", row + 1
  HEAD PAGE
   row + 2, name_full_formatted1 = substring(1,75,p.name_full_formatted), col 40,
   name_full_formatted1, row + 1
  WITH maxrec = 100, maxcol = 250, time = value(maxsecs),
   noheading, format = variable
 ;end select
END GO
