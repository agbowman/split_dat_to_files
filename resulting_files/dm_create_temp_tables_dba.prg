CREATE PROGRAM dm_create_temp_tables:dba
 CALL parser("rdb drop table dm_user_tab_columns go",1)
 CALL parser("rdb create table dm_user_tab_columns ",1)
 CALL parser(" (TABLE_NAME      VARCHAR2(30) NOT NULL,",1)
 CALL parser("  TABLESPACE_NAME VARCHAR2(30) NOT NULL,",1)
 CALL parser("  COLUMN_NAME     VARCHAR2(30) NOT NULL,",1)
 CALL parser("  DATA_TYPE       VARCHAR2(9),",1)
 CALL parser("  DATA_LENGTH     NUMBER NOT NULL,",1)
 CALL parser("  NULLABLE        VARCHAR2(1),",1)
 CALL parser("  COLUMN_ID       NUMBER NOT NULL,",1)
 CALL parser("  DATA_DEFAULT    VARCHAR2(255)) go",1)
 EXECUTE oragen3 "DM_user_tab_columns"
 CALL parser("insert into dm_user_tab_columns",1)
 CALL parser(" (table_name, tablespace_name, column_name, data_type,",1)
 CALL parser("  data_length, nullable, column_id)",1)
 CALL parser(" (select t.table_name, t.tablespace_name, tc.column_name,",1)
 CALL parser("  tc.data_type, tc.data_length, tc.nullable, ",1)
 CALL parser("  tc.column_id from user_tab_columns tc, user_tables t ",1)
 CALL parser("  where tc.table_name = t.table_name) ",1)
 CALL parser("  with nocounter go  commit go ",1)
 CALL parser("rdb create index xie1dm_user_tab_columns on ",1)
 CALL parser(" dm_user_tab_columns(table_name, column_name) go",1)
 RECORD list(
   1 col[*]
     2 table_name = c30
     2 column_name = c30
     2 data_default = c255
   1 col_count = i4
 )
 SET stat = alterlist(list->col,100)
 SET list->col_count = 0
 SELECT INTO "nl:"
  utc.table_name, utc.column_name, utc.data_default
  FROM user_tab_columns utc
  DETAIL
   list->col_count = (list->col_count+ 1)
   IF (mod(list->col_count,100)=1
    AND (list->col_count != 1))
    stat = alterlist(list->col,(list->col_count+ 99))
   ENDIF
   list->col[list->col_count].table_name = utc.table_name, list->col[list->col_count].column_name =
   utc.column_name, list->col[list->col_count].data_default = substring(1,255,utc.data_default)
  WITH nocounter
 ;end select
 UPDATE  FROM dm_user_tab_columns dutc,
   (dummyt d  WITH seq = value(list->col_count))
  SET dutc.data_default =
   IF ((list->col[d.seq].data_default > " ")) list->col[d.seq].data_default
   ELSE null
   ENDIF
  PLAN (d)
   JOIN (dutc
   WHERE (dutc.table_name=list->col[d.seq].table_name)
    AND (dutc.column_name=list->col[d.seq].column_name))
  WITH nocounter
 ;end update
 COMMIT
END GO
