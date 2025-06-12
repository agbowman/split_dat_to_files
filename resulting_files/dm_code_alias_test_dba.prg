CREATE PROGRAM dm_code_alias_test:dba
 SELECT
  cva.code_set, cva.contributor_source_cd, cva.alias,
  count(*)
  FROM code_value_alias cva,
   code_value_set cvs
  WHERE cva.code_set > 0
   AND cva.alias_type_meaning=null
   AND cva.code_set=cvs.code_set
   AND cvs.alias_dup_ind=1
  GROUP BY cva.code_set, cva.contributor_source_cd, cva.alias
  HAVING count(*) > 1
  HEAD REPORT
   page_nbr = 0, line = fillstring(100,"=")
  HEAD PAGE
   col 0, "Page:", page_nbr = (page_nbr+ 1),
   page_nbr"####", col 80, "Date: ",
   curdate"dd-mmm-yyyy;;d", row + 1, col 0,
   line, row + 1, col 25,
   "ALIAS VALUE VIOLATION", row + 1, col 0,
   line, row + 1, col 0,
   CALL print(build("CODE SET # ",cva.code_set)), row + 1, col 0,
   line, row + 1, col 5,
   "CONTRIBUTOR SOURCE CODE", col 30, "ALIAS",
   row + 1, col 0, line,
   row + 1
  HEAD cva.code_set
   row + 1
  DETAIL
   col 15, cva.contributor_source_cd, col 30,
   CALL print(trim(cva.alias)), row + 1
  WITH nocounter, format
 ;end select
END GO
