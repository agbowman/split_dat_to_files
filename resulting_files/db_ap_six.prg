CREATE PROGRAM db_ap_six
 SELECT
  s.active_ind, s.display, s.description,
  s.cdf_meaning
  FROM code_value s
  WHERE code_set=1306
  ORDER BY s.display
  HEAD REPORT
   pg = 0
  HEAD PAGE
   pg += 1, col 1, "Anatomic Pathology",
   col 90, "Page", pg,
   row + 1, col 1, "Specimens",
   col 90, "Printed ", curdate,
   " ", curtime, row + 1,
   col 1, "Cerner", row + 2,
   col 1, "Status", col 15,
   "Code", col 35, "Description",
   col 90, "Type", row + 1,
   col 1, "------", col 15,
   "----", col 35, "-----------",
   col 90, "----", row + 1
  DETAIL
   IF (s.active_ind=1)
    col 1, "Active"
   ELSE
    col 1, "Inactive"
   ENDIF
   col 15, s.display, col 35,
   s.description, col 90, s.cdf_meaning,
   row + 1
  FOOT REPORT
   row + 1, col 35, "** end of report **"
 ;end select
END GO
