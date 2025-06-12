CREATE PROGRAM dm_cdf_meaning_value:dba
 SET cdfnull = 0
 SELECT
  c.code_set, c.cdf_meaning, cdfnull = nullind(c.cdf_meaning),
  c.code_value, c.display, s.cdf_meaning_dup_ind
  FROM code_value c,
   code_value_set s
  WHERE c.code_set > 0
   AND c.code_set=s.code_set
   AND s.cdf_meaning_dup_ind=1
   AND ((c.cdf_meaning=" ") OR (cdfnull=1))
  ORDER BY c.code_set
  HEAD REPORT
   line = fillstring(120,"="), page_nbr = 0, cnt = 0
  HEAD PAGE
   col 0, "Page :", page_nbr = (page_nbr+ 1),
   page_nbr"####", col 25, "CDF_MEANING VALUE VIOLATION",
   col 80, "Date: ", curdate"dd-mmm-yyyy;;d",
   row + 1, col 0, line,
   row + 1, col 5, "CODE SET",
   col 30, "NUMBER OF CODE VALUES WHICH DO NOT HAVE A VALUE IN CDF_MEANING", row + 1,
   col 0, line, row + 1
  HEAD c.code_set
   cnt = 0, col 0, c.code_set
  DETAIL
   cnt = (cnt+ 1)
  FOOT  c.code_set
   col 55, cnt, row + 1
  WITH format
 ;end select
END GO
