CREATE PROGRAM db_ap_one
 SELECT
  d.active_ind, d.display
  FROM code_value d
  WHERE code_set=1314
  ORDER BY d.display
  HEAD REPORT
   pg = 0
  HEAD PAGE
   pg += 1, col 1, "Anatomic Pathology",
   col 90, "Page", pg,
   row + 1, col 1, "Cytology Diagnostic Categories",
   col 90, "Printed ", curdate,
   " ", curtime, row + 1,
   col 1, "Cerner", row + 2,
   col 10, "Status", col 25,
   "Description", row + 1, col 10,
   "------", col 25, "-----------",
   row + 1
  DETAIL
   IF (d.active_ind=1)
    col 10, "Active"
   ELSE
    col 10, "Inactive"
   ENDIF
   col 25, d.display, row + 1
  FOOT REPORT
   row + 1, col 20, "** end of report **"
 ;end select
END GO
