CREATE PROGRAM dm_dispkey_value:dba
 SET ckdisnull = 0
 SELECT
  c.code_set, c.code_value, ckdisnull = nullind(c.display_key),
  c.display_key, s.display_key_dup_ind
  FROM code_value c,
   code_value_set s
  WHERE c.code_set > 0
   AND s.code_set=c.code_set
   AND s.display_key_dup_ind=1
   AND ((c.display=" ") OR (ckdisnull=1))
  HEAD REPORT
   line = fillstring(120,"="), page_nbr = 0
  HEAD PAGE
   col 0, "Page :", page_nbr = (page_nbr+ 1),
   page_nbr"####", col 80, "Date: ",
   curdate"dd-mmm-yyyy;;d", col 45, "DISPLAY KEY VALUE VIOLATION ",
   row + 1, col 25,
   " The display_key_dup_ind is set to 1, but the code values have no display key value",
   row + 1, col 0, line,
   row + 1, col 26, "CODE SET",
   col 46, "CODE VALUE", row + 1,
   col 0, line, row + 1
  HEAD c.code_set
   col 20, c.code_set
  DETAIL
   col 42, c.code_value, row + 1
 ;end select
END GO
