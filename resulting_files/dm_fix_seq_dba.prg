CREATE PROGRAM dm_fix_seq:dba
 SET tbl_name = table_list->table_name[ $1].tname
 SET process_flg = table_list->table_name[ $1].process_flg
 SET file2 = table_list->table_name[ $1].output2_filename
 SET file3 = table_list->table_name[ $1].output3_filename
 SET file4 = table_list->table_name[ $1].output4_filename
 SET file_sql = table_list->table_name[ $1].output2sql_filename
 SET file2d = table_list->table_name[ $1].output2d_filename
 SET file3d = table_list->table_name[ $1].output3d_filename
 SET file4d = table_list->table_name[ $1].output4d_filename
 SELECT INTO value(file2)
  FROM dm_sequences ds,
   user_sequences us,
   dummyt d
  PLAN (ds
   WHERE ds.sequence_name > " ")
   JOIN (d)
   JOIN (us
   WHERE ds.sequence_name=us.sequence_name)
  ORDER BY ds.sequence_name
  DETAIL
   "dm_clear_errors go", row + 1, min_value = cnvtstring(ds.min_value),
   max_value = cnvtstring(ds.max_value), cache_value = cnvtstring(ds.cache), row + 1,
   "; Creating sequence ", ds.sequence_name, row + 1,
   "rdb CREATE SEQUENCE ", ds.sequence_name, row + 1,
   "  INCREMENT BY ", ds.increment_by, row + 1
   IF (ds.increment_by > 0)
    IF (ds.max_value < 10000000000.0)
     "  MAXVALUE ", max_value, row + 1
    ENDIF
    IF (ds.min_value != 1.0)
     "  MINVALUE ", min_value, row + 1
    ENDIF
   ENDIF
   IF (ds.increment_by < 0)
    IF ((ds.min_value > - (1000000000.0)))
     "  MINVALUE ", min_value, row + 1
    ENDIF
    IF ((ds.max_value != - (1.0)))
     "  MAXVALUE ", max_value, row + 1
    ENDIF
   ENDIF
   IF (ds.cycle="Y")
    "  CYCLE", row + 1
   ENDIF
   IF (ds.cache > 0.0)
    "  CACHE ", cache_value, row + 1
   ENDIF
   "go", row + 1, row + 1,
   "set msgnum=error(msg,1) go", row + 1, errstr = concat("create sequence ",trim(ds.sequence_name),
    " go"),
   "execute dm_log_errors ", row + 1, ' "',
   file3, '", ', row + 1,
   ' "", ', row + 1, ' "", ',
   row + 1, ' "', errstr,
   '",', row + 1, " msg, msgnum go",
   row + 2, reset_error = 1
  WITH outerjoin = d, dontexist, format = variable,
   noheading, append, maxrow = 1,
   formfeed = none, maxcol = 512
 ;end select
#end_program
END GO
