CREATE PROGRAM dm_for_key_enable:dba
 SELECT
  table_name = table_name, constraint_name = constraint_name
  FROM user_constraints
  WHERE constraint_type="R"
   AND status="DISABLED"
  HEAD REPORT
   row + 1, col 0, "DELETE FROM dm_for_key_except WHERE 1=1 GO"
  DETAIL
   row + 1, col 0, "RDB ALTER TABLE ",
   row + 1, table_name, row + 1,
   " ENABLE CONSTRAINT ", row + 1, constraint_name,
   row + 1, " EXCEPTIONS INTO dm_for_key_except GO"
  WITH noheading, noformfeed, maxcol = 140
 ;end select
END GO
