CREATE PROGRAM db_ap_three
 SELECT
  f.active_ind, f.display, f.description
  FROM code_value f
  WHERE code_set=1313
  ORDER BY f.display
  HEAD REPORT
   pg = 0
  HEAD PAGE
   pg += 1, col 1, "Anatomic Pathology",
   col 90, "Page", pg,
   row + 1, col 1, "Cytology Follow-up Termination Reasons",
   col 90, "Printed ", curdate,
   " ", curtime, row + 1,
   col 1, "Cerner", row + 2,
   col 10, "Status", col 25,
   "Code", col 50, "Description",
   row + 1, col 10, "------",
   col 25, "----", col 50,
   "-----------", row + 1
  DETAIL
   IF (f.active_ind=1)
    col 10, "Active"
   ELSE
    col 10, "Inactive"
   ENDIF
   col 25, f.display, col 50,
   f.description, row + 1
  FOOT REPORT
   row + 1, col 25, "** end of report **"
 ;end select
END GO
