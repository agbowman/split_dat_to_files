CREATE PROGRAM ce_report
 CALL text(4,2,"Enter output device: ")
 CALL accept(4,23,"p(30);cu","FORMS")
 SET odev = curaccept
 SELECT INTO trim(odev)
  c.event_id, c.event_cd, cv.display,
  c.result_val, c.contributor_system_cd, cv1.display,
  c.parent_event_id
  FROM clinical_event c,
   code_value cv,
   code_value cv1
  PLAN (c
   WHERE c.encntr_id=enbr1)
   JOIN (cv
   WHERE c.event_cd=cv.code_value)
   JOIN (cv1
   WHERE c.contributor_system_cd=cv1.code_value)
  ORDER BY c.event_id, cv.display
  HEAD REPORT
   under = fillstring(131,"=")
  HEAD PAGE
   row 1, col 32, "C L I N I C A L   E V E N T   R E P O R T   B Y   E N C O U N T E R",
   row + 1, col 0, "Name: ",
   CALL print(trim(substring(1,100,name_full_formatted))), col 109, " Date: ",
   curdate"dd-mmm-yyyy;;d", row + 1, col 0,
   "Person Id: ", pat_id"#############;r", col 110,
   "Time: ", curtime"hh:mm;;m", row + 1,
   col 0, " Enounter: ", enbr1"#############;r",
   col 110, "Page: ", curpage"###;r",
   row + 2, col 0, "Event Id",
   col 15, "Event Cd", col 30,
   "Display", col 72, "Contrib Sys",
   col 89, "Display", row + 1,
   col 0, under, row + 1
  DETAIL
   col 0, c.event_id"############;r", col 15,
   c.event_cd"############;r", col 30, cv.display,
   col 72, c.contributor_system_cd"############;r", col 89,
   cv1.display, row + 1, col 0,
   "Parent: ", c.parent_event_id"############;r", row + 1,
   col 0, "Result: ", result = substring(1,120,c.result_val),
   result, row + 2
  WITH counter
 ;end select
END GO
