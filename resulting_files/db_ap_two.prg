CREATE PROGRAM db_ap_two
 SELECT
  f.active_ind, f.display, f.description
  FROM code_value f
  WHERE code_set=1302
  ORDER BY f.display
  HEAD REPORT
   pg = 0
  HEAD PAGE
   pg += 1, col 1, "Anatomic Pathology",
   col 90, "Page", pg,
   row + 1, col 1, "Fixatives",
   col 90, "Printed ", curdate,
   " ", curtime, row + 1,
   col 1, "Cerner", row + 2,
   col 10, "Status", col 25,
   "Code", col 60, "Description",
   row + 1, col 10, "------",
   col 25, "----", col 60,
   "-----------", row + 1
  DETAIL
   IF (f.active_ind=1)
    col 10, "Active"
   ELSE
    col 10, "Inactive"
   ENDIF
   col 25, f.display, col 60,
   f.description, row + 1
  FOOT REPORT
   row + 1, col 25, "** end of report **"
 ;end select
END GO
