CREATE PROGRAM drop_tbl:dba
 SELECT INTO "drop_tbl"
  u.table_name
  FROM user_tables u
  DETAIL
   row + 1, "rdb drop table ", u.table_name,
   " go"
  WITH nocounter
 ;end select
END GO
