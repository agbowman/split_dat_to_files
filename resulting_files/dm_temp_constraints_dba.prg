CREATE PROGRAM dm_temp_constraints:dba
 RDB drop table dm_temp_constraints
 END ;Rdb
 RDB create table dm_temp_constraints tablespace d_sys_mgmt as select ucc . table_name , ucc .
 column_name , ucc . position , ucc . constraint_name from user_cons_columns ucc , user_constraints
 uc where uc . table_name = ucc . table_name and uc . owner = user and uc . constraint_name = ucc .
 constraint_name and uc . constraint_type = "P"
 END ;Rdb
 RDB create unique index xie1dm_temp_constraints on dm_temp_constraints ( table_name , column_name )
 tablespace i_sys_mgmt
 END ;Rdb
 RDB create index xie2dm_temp_constraints on dm_temp_constraints ( constraint_name ) tablespace
 i_sys_mgmt
 END ;Rdb
 EXECUTE oragen3 "dm_temp_constraints"
 DELETE  FROM dm_temp_constraints
  WHERE table_name IN ("INTERP_COMPONENT", "INTERP_RANGE", "RESULT_HASH")
  WITH nocounter
 ;end delete
 INSERT  FROM dm_temp_constraints
  (table_name, column_name, position,
  constraint_name)
  VALUES("INTERP_COMPONENT", "INTERP_DETAIL_ID", 1,
  "XPKINTERP_COMPONENT")
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_constraints
  (table_name, column_name, position,
  constraint_name)
  VALUES("INTERP_RANGE", "INTERP_RANGE_ID", 1,
  "XPKINTERP_RANGE")
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_constraints
  (table_name, column_name, position,
  constraint_name)
  VALUES("RESULT_HASH", "RESULT_HASH_ID", 1,
  "XPKINTERP_HASH")
  WITH nocounter
 ;end insert
 INSERT  FROM dm_temp_constraints
  (table_name, column_name, position,
  constraint_name)
  VALUES("REF_TEXT", "REFR_TEXT_ID", 1,
  "XPKREF_TEXT")
  WITH nocounter
 ;end insert
 COMMIT
END GO
