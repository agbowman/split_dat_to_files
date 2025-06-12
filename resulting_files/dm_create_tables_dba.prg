CREATE PROGRAM dm_create_tables:dba
 SET tbl_name = table_list->table_name[ $1].tname
 SET process_flg = table_list->table_name[ $1].process_flg
 SET file2 = table_list->table_name[ $1].output2_filename
 SET file3 = table_list->table_name[ $1].output3_filename
 SET file4 = table_list->table_name[ $1].output4_filename
 SET file_sql = table_list->table_name[ $1].output2sql_filename
 SET file2d = table_list->table_name[ $1].output2d_filename
 SET file3d = table_list->table_name[ $1].output3d_filename
 SET file4d = table_list->table_name[ $1].output4d_filename
 SET errstr = fillstring(110," ")
 SET tempstr = fillstring(110," ")
 SET source_table = fillstring(30," ")
 SET target_table = fillstring(30," ")
 SET from_column[100] = fillstring(80," ")
 SET to_column[100] = fillstring(80," ")
 SET old_base_data_type = fillstring(1," ")
 SET new_base_data_type = fillstring(1," ")
 SET initial_extent = 0
 SET next_extent = 0
 SET bytes = 0
 FREE RECORD str
 RECORD str(
   1 str = vc
 )
 SELECT INTO value(file2)
  uic.column_name, uic.data_type, uic.data_length,
  uic.nullable, uic.column_seq, uc.tablespace_name,
  uc.table_name, default_value = substring(1,50,uic.data_default)
  FROM dm_columns uic,
   dm_tables uc
  WHERE uc.table_name=tbl_name
   AND uc.table_name=uic.table_name
   AND uc.schema_date=uic.schema_date
   AND uc.schema_date=cnvtdatetime( $2)
  ORDER BY uc.table_name, uic.column_seq
  HEAD uc.table_name
   "dm_clear_errors go", row + 2, "rdb CREATE TABLE ",
   uc.table_name, " ("
  DETAIL
   IF (uic.column_seq > 1)
    ","
   ENDIF
   row + 1, col 10, uic.column_name,
   col 50, uic.data_type
   IF (((uic.data_type="VARCHAR2") OR (((uic.data_type="CHAR") OR (uic.data_type="VARCHAR")) )) )
    col 60, "(", col 61,
    uic.data_length"####;;I", col 66, ")"
   ENDIF
   IF (default_value != fillstring(40," "))
    str->str = concat(" DEFAULT ",trim(uic.data_default)), str->str
   ENDIF
   IF (uic.nullable="N")
    " NOT NULL"
   ENDIF
  FOOT  uc.table_name
   row + 1, col 10, ")",
   row + 1, col 10, " TABLESPACE ",
   uc.tablespace_name, row + 1, "go",
   row + 2, errstr = concat("create table ",trim(uc.table_name)), "set msgnum=error(msg,1) go",
   row + 1, "execute dm_log_errors ", row + 1,
   ' "', file3, '", ',
   row + 1, ' "rdb create ', tbl_name,
   ' go", ', row + 1, ' "", ',
   row + 1, ' "', errstr,
   '",', row + 1, " msg, msgnum go",
   row + 2, reset_error = 1
  WITH format = variable, noheading, append,
   formfeed = none, maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(file2)
  dic.column_name, dic.column_position, di.table_name,
  di.index_name, di.tablespace_name, di.unique_ind
  FROM dm_index_columns dic,
   dm_indexes di
  PLAN (di
   WHERE di.table_name=tbl_name
    AND di.schema_date=cnvtdatetime( $2))
   JOIN (dic
   WHERE di.index_name=dic.index_name
    AND di.schema_date=dic.schema_date)
  ORDER BY di.index_name, dic.column_position
  HEAD di.index_name
   "rdb DROP INDEX ", di.index_name, " go",
   row + 2, "dm_clear_errors go", row + 2,
   "rdb CREATE "
   IF (di.unique_ind=1)
    "UNIQUE"
   ENDIF
   " INDEX ", di.index_name, row + 1,
   "  ON ", di.table_name, " (",
   row + 1
  DETAIL
   IF (dic.column_position > 1)
    ","
   ENDIF
   row + 1, col 30, dic.column_name
  FOOT  di.index_name
   row + 1, "  )", row + 1,
   "  STORAGE (INITIAL 16K NEXT 8K)", row + 1, "  UNRECOVERABLE",
   row + 1, "  TABLESPACE ", di.tablespace_name,
   row + 1, "go", row + 2,
   "set msgnum=error(msg,1) go", row + 1, errstr = concat("create index ",trim(di.index_name),
    " on table ",trim(di.table_name)," go"),
   "execute dm_log_errors ", row + 1, ' "',
   file3, '", ', row + 1,
   ' "", ', row + 1, ' "", ',
   row + 1, ' "', errstr,
   '",', row + 1, " msg, msgnum go",
   row + 2, reset_error = 1
  WITH format = variable, noheading, append,
   formfeed = none, maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(file2)
  uc.constraint_name, uc.table_name, ucc.column_name,
  ucc.position, uc.status_ind
  FROM dm_cons_columns ucc,
   dm_constraints uc
  WHERE ucc.constraint_name=uc.constraint_name
   AND ucc.table_name=uc.table_name
   AND uc.table_name=tbl_name
   AND uc.constraint_type="P"
   AND uc.schema_date=ucc.schema_date
   AND uc.schema_date=cnvtdatetime( $2)
  ORDER BY uc.constraint_name, ucc.position
  HEAD uc.table_name
   "dm_clear_errors go", row + 2, "rdb ALTER TABLE ",
   uc.table_name, row + 1, "  ADD CONSTRAINT ",
   uc.constraint_name, row + 1, "  PRIMARY KEY ("
  DETAIL
   IF (ucc.position > 1)
    ","
   ENDIF
   row + 1, col 10, ucc.column_name
  FOOT  uc.table_name
   row + 1, "  )", row + 1
   IF (uc.status_ind=0)
    "  DISABLE"
   ENDIF
   row + 1, "go", row + 2,
   "set msgnum=error(msg,1) go", row + 1, errstr = concat("alter table ",trim(uc.table_name),
    " add primary key constraint ",trim(uc.constraint_name)," go"),
   "execute dm_log_errors ", row + 1, ' "',
   file3, '", ', row + 1,
   ' "", ', row + 1, ' "", ',
   row + 1, ' "', errstr,
   '",', row + 1, " msg, msgnum go",
   row + 2, reset_error = 1
  WITH format = variable, noheading, append,
   formfeed = none, maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(file2)
  uc.constraint_name, uc.table_name, ucc.column_name,
  ucc.position, uc.status_ind
  FROM dm_cons_columns ucc,
   dm_constraints uc
  WHERE ucc.constraint_name=uc.constraint_name
   AND ucc.table_name=uc.table_name
   AND uc.table_name=tbl_name
   AND uc.constraint_type="U"
   AND uc.schema_date=ucc.schema_date
   AND uc.schema_date=cnvtdatetime( $2)
  ORDER BY uc.constraint_name, ucc.position
  HEAD uc.table_name
   "dm_clear_errors go", row + 2, "rdb ALTER TABLE ",
   uc.table_name, row + 1, "  ADD CONSTRAINT ",
   uc.constraint_name, row + 1, "  UNIQUE ("
  DETAIL
   IF (ucc.position > 1)
    ","
   ENDIF
   row + 1, col 10, ucc.column_name
  FOOT  uc.table_name
   row + 1, "  )", row + 1
   IF (uc.status_ind=0)
    "  DISABLE"
   ENDIF
   row + 1, "go", row + 2,
   "set msgnum=error(msg,1) go", row + 1, errstr = concat("alter table ",trim(uc.table_name),
    " add unique key constraint ",trim(uc.constraint_name)," go"),
   "execute dm_log_errors ", row + 1, ' "',
   file3, '", ', row + 1,
   ' "", ', row + 1, ' "", ',
   row + 1, ' "', errstr,
   '",', row + 1, " msg, msgnum go",
   row + 2, reset_error = 1
  WITH format = variable, noheading, append,
   formfeed = none, maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(file2)
  count(*)
  FROM dual
  DETAIL
   'execute oragen3 "', tbl_name, '" go',
   row + 1, "update INTO dm_tables_doc set SCHEMA_REFRESH_DT_TM = cnvtdatetime(curdate,curtime3)",
   row + 1,
   '  where table_name = "', tbl_name, '" go',
   row + 1
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, append, maxrow = 1
 ;end select
 SELECT INTO value(file2)
  FROM dual
  DETAIL
   "set trace symbol go", row + 2
  WITH format = variable, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
#end_program
END GO
