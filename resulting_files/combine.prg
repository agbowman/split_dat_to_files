CREATE PROGRAM combine
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Person ID " = 0
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SELECT INTO  $1
  p.from_person_id, p.to_person_id, p.active_ind,
  p.person_combine_id, expr1 = p.from_person_id, expr2 = p.to_person_id,
  expr3 = p.active_ind, expr5 = p.person_combine_id
  FROM person_combine p
  WHERE (((p.from_person_id= $2)) OR ((p.to_person_id= $2)))
  HEAD REPORT
   expr4 = curdate, row 1, col 40,
   "Person_Combine Table", row + 1
  DETAIL
   IF (((row+ 4) >= maxrow))
    BREAK
   ENDIF
   row + 1, col 13, "From person ID",
   col 38, "To person ID", col 64,
   "Active Indicator", col 89, "Combine ID",
   row + 2, col 13, p.from_person_id,
   col 38, p.to_person_id, col 64,
   p.active_ind, col 88, p.person_combine_id,
   row + 1
  FOOT PAGE
   col 17, expr5, col 88,
   p.person_combine_id, call reportmove('ROW',(maxrow - 1),0), col 2,
   expr4, col 14,
   "This is report of any rows created on person_combine table due to ESI reconcile combine."
  WITH maxrec = 100, maxcol = 250, time = value(maxsecs),
   noheading, format = variable
 ;end select
END GO
