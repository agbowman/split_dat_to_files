CREATE PROGRAM dm_fix_columns_null:dba
 SET tbl_name = table_list->table_name[ $1].tname
 SET process_flg = table_list->table_name[ $1].process_flg
 SET file2 = table_list->table_name[ $1].output2_filename
 SET file3 = table_list->table_name[ $1].output3_filename
 SET file4 = table_list->table_name[ $1].output4_filename
 SET file_sql = table_list->table_name[ $1].output2sql_filename
 SET file2d = table_list->table_name[ $1].output2d_filename
 SET file3d = table_list->table_name[ $1].output3d_filename
 SET file4d = table_list->table_name[ $1].output4d_filename
 IF (process_flg=3)
  SET filename = file2d
  SET err_filename = file3d
 ELSE
  SET filename = file2
  SET err_filename = file3
 ENDIF
 SELECT INTO value(filename)
  dc.table_name, dc.data_type, utc.data_type,
  dc.column_name, dc.nullable, utc.nullable,
  dc.data_default, utc.data_default, utc.data_length,
  dc.data_length, dc.column_seq
  FROM dm_user_tab_cols utc,
   dm_columns dc
  PLAN (dc
   WHERE dc.table_name=tbl_name
    AND dc.schema_date=cnvtdatetime( $2))
   JOIN (utc
   WHERE utc.table_name=dc.table_name
    AND utc.column_name=dc.column_name
    AND utc.nullable != dc.nullable
    AND dc.nullable="Y")
  ORDER BY dc.column_seq, dc.column_name
  HEAD REPORT
   "dm_clear_errors go", row + 2, "rdb ALTER TABLE ",
   dc.table_name, row + 1, "modify (",
   cnum = 0
  DETAIL
   cnum = (cnum+ 1)
   IF (cnum > 1)
    ","
   ENDIF
   row + 1, dc.column_name, " NULL"
  FOOT REPORT
   row + 1, ") go", row + 2,
   "set msgnum=error(msg,1) go", row + 1, errstr = build("alter table:",dc.table_name,
    " modify columns (null)"),
   "execute dm_log_errors ", row + 1, ' "',
   err_filename, '", ', row + 1,
   ' "", ', row + 1, ' "", ',
   row + 1, ' "', errstr,
   '",', row + 1, " msg, msgnum go",
   row + 2, reset_error = 1
  WITH nocounter, format = variable, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
#end_program
END GO
