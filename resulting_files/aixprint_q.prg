CREATE PROGRAM aixprint_q
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SELECT INTO  $1
  p.name_full_formatted, sex_disp = uar_get_code_display(p.sex_cd), p.sex_cd
  FROM person p
  WITH format, maxrec = 100, maxcol = 250,
   time = value(maxsecs)
 ;end select
END GO
