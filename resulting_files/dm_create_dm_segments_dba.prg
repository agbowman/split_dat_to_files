CREATE PROGRAM dm_create_dm_segments:dba
 CALL parser("rdb drop table dm_segments go",1)
 CALL parser("rdb create table dm_segments as select * from user_segments go",1)
 CALL parser(
  "rdb alter table dm_segments add constraint xpkdm_segments primary key (segment_name, segment_type) go",
  1)
 EXECUTE oragen3 "DM_SEGMENTS"
 CALL parser("rdb drop table dm_user_constraints go",1)
 CALL parser("rdb create table dm_user_constraints as select",1)
 CALL parser(
  " owner,constraint_name,constraint_type,table_name,r_owner,r_constraint_name,delete_rule,status",1)
 CALL parser(" from user_constraints go",1)
 CALL parser("rdb create index xie1dm_user_constraints on dm_user_constraints(table_name) go",1)
 CALL parser("rdb create index xie2dm_user_constraints on dm_user_constraints(r_constraint_name) go",
  1)
 EXECUTE oragen3 "DM_user_constraints"
 CALL parser("rdb drop table dm_user_tab_cols go",1)
 CALL parser("rdb create table dm_user_tab_cols as select ",1)
 CALL parser(" TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_PRECISION,",1)
 CALL parser(" DATA_SCALE, NULLABLE, COLUMN_ID, DEFAULT_LENGTH, NUM_DISTINCT,",1)
 CALL parser(" DENSITY from user_tab_columns go",1)
 CALL parser("rdb create index xie1dm_user_tab_cols on dm_user_tab_cols(table_name, column_name) go",
  1)
 EXECUTE oragen3 "DM_user_tab_cols"
END GO
