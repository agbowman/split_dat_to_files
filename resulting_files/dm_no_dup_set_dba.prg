CREATE PROGRAM dm_no_dup_set:dba
 SELECT
  cvs.display_key_dup_ind, cvs.display_dup_ind, cvs.cdf_meaning_dup_ind,
  cvs.active_ind_dup_ind, cvs.alias_dup_ind, cvs.code_set
  FROM code_value_set cvs
  WHERE cvs.code_set > 0
   AND cvs.display_dup_ind=0
   AND cvs.display_key_dup_ind=0
   AND cvs.cdf_meaning_dup_ind=0
   AND cvs.alias_dup_ind=0
   AND cvs.active_ind_dup_ind=0
  HEAD REPORT
   line = fillstring(125,"="), page_nbr = 0
  HEAD PAGE
   col 0, "Page :", page_nbr = (page_nbr+ 1),
   page_nbr"####", col 30, "DUP INDICATORS SET VIOLATION",
   col 90, "Date: ", curdate"dd-mmm-yyyy;;d",
   row + 1, col 20, "None of the dup indicators are set for the following code sets",
   row + 1, col 0, line,
   row + 1, col 45, "CODE SET #",
   row + 1, col 0, line,
   row + 1
  DETAIL
   col 40, cvs.code_set, row + 1
  WITH format, nocounter
 ;end select
END GO
