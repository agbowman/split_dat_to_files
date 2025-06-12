CREATE PROGRAM dm_afd_create_tables:dba
 SET filename2 = "dm_afd_fix_schema2"
 SET filename3 = "dm_afd_fix_schema3"
 SET filename4 = "dm_afd_fix_schema4.dat"
 SET errstr = fillstring(110," ")
 SET tempstr = fillstring(110," ")
 SET tbl_name = fillstring(32," ")
 SET source_table = fillstring(30," ")
 SET target_table = fillstring(30," ")
 SET from_column[100] = fillstring(80," ")
 SET to_column[100] = fillstring(80," ")
 SET old_base_data_type = fillstring(1," ")
 SET new_base_data_type = fillstring(1," ")
 SET tbl_name =  $1
 SET initial_extent = 0
 SET next_extent = 0
 SET bytes = 0
 SELECT INTO value(filename2)
  uic.column_name, uic.data_type, uic.data_length,
  uic.nullable, uic.column_seq, uc.tablespace_name,
  uc.table_name, default_value = substring(1,40,uic.data_default)
  FROM dm_afd_columns uic,
   dm_afd_tables uc
  WHERE uc.table_name=tbl_name
   AND uc.table_name=uic.table_name
  ORDER BY uc.table_name, uic.column_seq
  HEAD uc.table_name
   'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
   row + 1, "rdb CREATE TABLE ", uc.table_name,
   row + 1, col 10, "("
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
    " DEFAULT ", default_value
   ENDIF
   IF (uic.nullable="N")
    " NOT NULL"
   ENDIF
  FOOT  uc.table_name
   row + 1, col 10, ")",
   row + 1, col 10, " TABLESPACE ",
   uc.tablespace_name, row + 1, "go",
   row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
   errstr = concat('"create table ',trim(uc.table_name),'" go'), "set error_msg = ", errstr,
   row + 1, 'set rstring = "rdb create ', tname,
   ' go" go', row + 1, 'set rstring1 = "" go',
   row + 1, "execute dm_check_errors go", row + 2,
   reset_error = 1
  WITH format = stream, noheading, append,
   formfeed = none, maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(filename2)
  dic.column_name, dic.column_position, di.table_name,
  di.index_name, di.tablespace_name, di.unique_ind
  FROM dm_afd_index_columns dic,
   dm_afd_indexes di
  PLAN (di
   WHERE di.table_name=tname)
   JOIN (dic
   WHERE di.index_name=dic.index_name)
  ORDER BY di.index_name, dic.column_position
  HEAD di.index_name
   "rdb DROP INDEX ", di.index_name, " go",
   row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
   "set error_reported = 0 go", row + 1, "rdb CREATE "
   IF (di.unique_ind=1)
    "UNIQUE"
   ENDIF
   " INDEX ", di.index_name, row + 1,
   col 20, "ON ", di.table_name,
   row + 1, col 30, "("
  DETAIL
   IF (dic.column_position > 1)
    ","
   ENDIF
   row + 1, col 30, dic.column_name
  FOOT  di.index_name
   row + 1, col 30, ")",
   row + 1, col 20, " TABLESPACE ",
   di.tablespace_name, row + 1, "go",
   row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
   errstr = concat('"create index ',trim(di.index_name)," on table ",trim(di.table_name),'" go'),
   "set error_msg = ", errstr,
   row + 1, 'set rstring = "" go', row + 1,
   'set rstring1 = "" go', row + 1, "execute dm_check_errors go",
   row + 1, reset_error = 1
  WITH format = stream, noheading, append,
   formfeed = none, maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(filename2)
  uc.constraint_name, uc.table_name, ucc.column_name,
  ucc.position, uc.status_ind
  FROM dm_afd_cons_columns ucc,
   dm_afd_constraints uc
  WHERE ucc.constraint_name=uc.constraint_name
   AND ucc.table_name=uc.table_name
   AND uc.table_name=tname
   AND uc.constraint_type="P"
  ORDER BY uc.constraint_name, ucc.position
  HEAD uc.table_name
   'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
   row + 1, "rdb ALTER TABLE ", col 20,
   uc.table_name, row + 1, col 20,
   " ADD CONSTRAINT ", uc.constraint_name, row + 1,
   col 30, " PRIMARY KEY ("
  DETAIL
   IF (ucc.position > 1)
    ","
   ENDIF
   row + 1, col 10, ucc.column_name
  FOOT  uc.table_name
   row + 1, col 10, ")",
   row + 1
   IF (uc.status_ind=0)
    "DISABLE"
   ENDIF
   row + 1, "go", row + 1,
   'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, errstr = concat(
    '"alter table ',trim(uc.table_name)," add primary key constraint ",trim(uc.constraint_name),
    '" go'),
   "set error_msg = ", errstr, row + 1,
   'set rstring = "" go', row + 1, 'set rstring1 = "" go',
   row + 1, "execute dm_check_errors go", row + 1,
   reset_error = 1
  WITH format = stream, noheading, append,
   formfeed = none, maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(filename2)
  uc.constraint_name, uc.table_name, ucc.column_name,
  ucc.position, uc.status_ind
  FROM dm_afd_cons_columns ucc,
   dm_afd_constraints uc
  WHERE ucc.constraint_name=uc.constraint_name
   AND ucc.table_name=uc.table_name
   AND uc.table_name=tname
   AND uc.constraint_type="U"
  ORDER BY uc.constraint_name, ucc.position
  HEAD uc.table_name
   'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
   row + 1, "rdb ALTER TABLE ", col 20,
   uc.table_name, row + 1, col 20,
   " ADD CONSTRAINT ", uc.constraint_name, row + 1,
   col 30, " UNIQUE ("
  DETAIL
   IF (ucc.position > 1)
    ","
   ENDIF
   row + 1, col 10, ucc.column_name
  FOOT  uc.table_name
   row + 1, col 10, ")",
   row + 1
   IF (uc.status_ind=0)
    "DISABLE"
   ENDIF
   row + 1, "go", row + 1,
   'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, errstr = concat(
    '"alter table ',trim(uc.table_name)," add unique key constraint ",trim(uc.constraint_name),'" go'
    ),
   "set error_msg = ", errstr, row + 1,
   'set rstring = "" go', row + 1, 'set rstring1 = "" go',
   row + 1, "execute dm_check_errors go", row + 1,
   reset_error = 1
  WITH format = stream, noheading, append,
   formfeed = none, maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(filename2)
  count(*)
  FROM dual
  DETAIL
   'execute oragen3 "', tname, '" go',
   row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, append, maxrow = 1
 ;end select
 SELECT INTO value(filename2)
  *
  FROM dual
  DETAIL
   "set trace symbol go", row + 2
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
END GO
