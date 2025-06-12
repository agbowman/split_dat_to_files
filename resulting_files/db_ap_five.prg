CREATE PROGRAM db_ap_five
 SELECT
  cv.display, cv.description, dta.mnemonic,
  dta.description
  FROM code_value cv,
   report_history_grouping_r rhgr,
   discrete_task_assay dta
  PLAN (cv
   WHERE cv.code_set=1311)
   JOIN (rhgr
   WHERE cv.code_value=rhgr.grouping_cd)
   JOIN (dta
   WHERE rhgr.task_assay_cd=dta.task_assay_cd)
  HEAD REPORT
   line = fillstring(115,"-"), pg = 0, x = 0,
   text = fillstring(70," ")
  HEAD PAGE
   pg += 1, col 1, "Anatomic Pathology",
   col 90, "Page", pg,
   row + 1, col 1, "History Group Procedures",
   col 90, "Printed ", curdate,
   " ", curtime, row + 1,
   col 1, "Cerner", row + 2
   IF (x=1)
    row + 1, col 1, "TEST: ",
    cv.display, col 45, cv.description,
    row + 2, col 10, "DETAIL",
    col 55, "DESCRIPTION", row + 1,
    col 10, line, row + 1
   ENDIF
  HEAD cv.display
   x = 1, row + 1, col 1,
   "TEST: ", cv.display, col 45,
   cv.description, row + 2, col 10,
   "DETAIL", col 55, "DESCRIPTION",
   row + 1, col 10, line,
   row + 1
  DETAIL
   text = substring(1,70,dta.description), col 10, dta.mnemonic,
   col 55, text, row + 1
  FOOT  cv.display
   x = 0
  FOOT REPORT
   row + 2, col 20, "** end of report **"
 ;end select
END GO
