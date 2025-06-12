CREATE PROGRAM dm_only_active_ind:dba
 SELECT
  c.code_set
  FROM code_value_set c
  WHERE c.code_set > 0
   AND c.display_dup_ind=0
   AND c.display_key_dup_ind=0
   AND c.cdf_meaning_dup_ind=0
   AND c.alias_dup_ind=0
   AND c.active_ind_dup_ind=1
  HEAD REPORT
   line = fillstring(110,"="), page_nbr = 0
  HEAD PAGE
   col 0, "Page :", page_nbr = (page_nbr+ 1),
   page_nbr"####", col 80, "Date: ",
   curdate"dd-mmm-yyyy;;d", row + 1, col 0,
   line, row + 1, col 15,
   "ACTIVE DUP IND SETTING VIOLATION", row + 1, col 0,
   line, row + 1, col 0,
   "Only Active dup ind are set for the following code sets", row + 2
  DETAIL
   col 0, c.code_set, row + 1
  WITH format, nocounter
 ;end select
END GO
