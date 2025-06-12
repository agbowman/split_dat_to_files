CREATE PROGRAM dm_alias_other_dup:dba
 SELECT
  c.code_set
  FROM code_value_set c
  WHERE c.code_set > 0
   AND c.alias_dup_ind=1
   AND ((c.display_dup_ind=1) OR (((c.display_key_dup_ind=1) OR (((c.cdf_meaning_dup_ind=1) OR (c
  .active_ind_dup_ind=1)) )) ))
  HEAD REPORT
   line = fillstring(110,"="), page_nbr = 0
  HEAD PAGE
   col 0, "Page :", page_nbr = (page_nbr+ 1),
   page_nbr"####", col 80, "Date: ",
   curdate"dd-mmm-yyyy;;d", row + 1, col 0,
   line, row + 1, col 15,
   "ALIAS DUP IND SETTING VIOLATION", row + 1, col 0,
   line, row + 1, col 0,
   "Alias dup ind + any other dup ind are set for the following code sets", row + 2
  DETAIL
   col 0, c.code_set, row + 1
  WITH format, nocounter
 ;end select
END GO
