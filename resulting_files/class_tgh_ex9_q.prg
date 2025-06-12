CREATE PROGRAM class_tgh_ex9_q
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SELECT INTO  $1
  p.name_first, p.name_last, p.person_id,
  p.birth_dt_tm, p.birth_dt_cd, age = cnvtage(cnvtdate(p.birth_dt_tm),cnvttime(p.birth_dt_tm)),
  name = concat(trim(p.name_first)," ",p.name_last)
  FROM person p
  WITH format, maxrec = 100, maxcol = 250,
   time = value(maxsecs)
 ;end select
END GO
