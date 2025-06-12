CREATE PROGRAM db_ap_seven
 SELECT
  a.active_ind, a.display
  FROM code_value a
  WHERE code_set=1318
  ORDER BY a.display
  HEAD REPORT
   pg = 0
  HEAD PAGE
   pg += 1, col 1, "Anatomic Pathology",
   col 90, "Page", pg,
   row + 1, col 1, "Specimen Adequacy",
   col 90, "Printed ", curdate,
   " ", curtime, row + 1,
   col 1, "Cerner", row + 2,
   col 10, "Status", col 25,
   "Description", row + 1, col 10,
   "------", col 25, "-----------",
   row + 1
  DETAIL
   IF (a.active_ind=1)
    col 10, "Active"
   ELSE
    col 10, "Inactive"
   ENDIF
   col 25, a.display, row + 1
  FOOT REPORT
   row + 1, col 20, "** end of report **"
 ;end select
END GO
