CREATE PROGRAM barb_0728a_q
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $1
  p.person_id, pid = format(p.person_id,"#####;p0")
  FROM person p
  WITH format, maxrec = 100, maxcol = 500,
   time = value(maxsecs)
 ;end select
END GO
