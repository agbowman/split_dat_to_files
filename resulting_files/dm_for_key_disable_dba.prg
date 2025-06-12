CREATE PROGRAM dm_for_key_disable:dba
 SELECT
  table_name = table_name, constraint_name = constraint_name
  FROM user_constraints
  WHERE constraint_type="R"
   AND status="ENABLED"
  DETAIL
   row + 1, col 0, "RDB ALTER TABLE ",
   row + 1, table_name, row + 1,
   " DISABLE CONSTRAINT ", row + 1, constraint_name,
   " GO"
  WITH noheading, noformfeed, maxcol = 140
 ;end select
END GO
