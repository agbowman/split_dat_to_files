CREATE PROGRAM dm_fix_columns:dba
 SET tbl_name = table_list->table_name[ $1].tname
 SET process_flg = table_list->table_name[ $1].process_flg
 SET file2 = table_list->table_name[ $1].output2_filename
 SET file3 = table_list->table_name[ $1].output3_filename
 SET file4 = table_list->table_name[ $1].output4_filename
 SET file_sql = table_list->table_name[ $1].output2sql_filename
 SET file3_sql = table_list->table_name[ $1].output3sql_filename
 SET file2d = table_list->table_name[ $1].output2d_filename
 SET file3d = table_list->table_name[ $1].output3d_filename
 SET file4d = table_list->table_name[ $1].output4d_filename
 SET default_value = fillstring(40," ")
 SET tempstr = fillstring(110," ")
 SET errstr = fillstring(110," ")
 RECORD str(
   1 str = vc
 )
 IF (process_flg=3)
  SET filename = file2d
  SET err_filename = file3d
 ELSE
  SET filename = file2
  SET err_filename = file3
 ENDIF
 SELECT INTO value(file2)
  dc.table_name, dc.data_type, utc.data_type,
  dc.column_name, dc.nullable, utc.nullable,
  dc.data_default, utc.data_default, utc.data_length,
  dc.data_length
  FROM dm_user_tab_cols utc,
   dm_columns dc
  PLAN (dc
   WHERE dc.table_name=tbl_name
    AND dc.schema_date=cnvtdatetime( $2))
   JOIN (utc
   WHERE utc.table_name=dc.table_name
    AND utc.column_name=dc.column_name
    AND ((utc.data_type=dc.data_type) OR (((utc.data_type="NUMBER"
    AND dc.data_type="FLOAT") OR (((utc.data_type="VARCHAR2"
    AND dc.data_type="CHAR") OR (utc.data_type="CHAR"
    AND dc.data_type="VARCHAR2")) )) )) )
  DETAIL
   IF (dc.data_type != utc.data_type)
    "dm_clear_errors go", row + 2, "rdb ALTER TABLE ",
    dc.table_name, row + 1, "  modify ( ",
    dc.column_name, " "
    IF (utc.data_type="NUMBER"
     AND dc.data_type="FLOAT")
     "FLOAT)", row + 1
    ELSE
     str->str = build(dc.data_type," (",dc.data_length,"))"), str->str, row + 1
    ENDIF
    "go", row + 2, errstr = build("alter table:",dc.table_name," modify column:",dc.column_name,
     " (type)"),
    "set msgnum=error(msg,1) go", row + 1, "execute dm_log_errors ",
    row + 1, ' "', file3,
    '", ', row + 1, ' "",',
    row + 1, ' "", ', row + 1,
    ' "', errstr, '",',
    row + 1, " msg, msgnum go", row + 2,
    reset_error = 1
   ENDIF
   IF (dc.data_length != utc.data_length
    AND dc.data_length > utc.data_length
    AND ((dc.data_type="VARCHAR2") OR (((dc.data_type="VARCHAR") OR (dc.data_type="CHAR")) )) )
    "dm_clear_errors go", row + 2, "rdb ALTER TABLE ",
    dc.table_name, row + 1, "  modify (",
    dc.column_name, " ", str->str = build(dc.data_type," (",dc.data_length,"))"),
    str->str, " go", row + 1,
    row + 1, "set msgnum=error(msg,1) go", row + 1,
    errstr = build("alter table:",dc.table_name," modify column:",dc.column_name," (length)"),
    "execute dm_log_errors ", row + 1,
    ' "', file3, '", ',
    row + 1, ' "", ', row + 1,
    ' "", ', row + 1, ' "',
    errstr, '",', row + 1,
    " msg, msgnum go", row + 2, reset_error = 1
   ENDIF
  WITH nocounter, format = variable, noheading,
   formfeed = none, maxcol = 512, maxrow = 1,
   append
 ;end select
 SELECT INTO value(file2)
  dc.seq, dc.table_name, dc.column_name,
  dc.data_type, dc.data_length, dc.data_default,
  dc.nullable
  FROM dm_columns dc
  WHERE dc.schema_date=cnvtdatetime( $2)
   AND dc.table_name=tbl_name
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM dm_user_tab_cols utc
   WHERE utc.table_name=dc.table_name
    AND utc.column_name=dc.column_name)))
  HEAD REPORT
   knt = 0, "dm_clear_errors go", row + 2,
   "rdb ALTER TABLE ", dc.table_name, row + 1,
   "add ("
  DETAIL
   knt = (knt+ 1)
   IF (knt > 1)
    ","
   ENDIF
   row + 1, dc.column_name
   IF (((dc.data_type="VARCHAR2") OR (((dc.data_type="VARCHAR") OR (dc.data_type="CHAR")) )) )
    str->str = build(dc.data_type,"(",dc.data_length,")"), "  ", str->str
   ELSE
    "  ", dc.data_type
   ENDIF
  FOOT REPORT
   ") go", row + 2, "set msgnum=error(msg,1) go",
   row + 1, errstr = build("alter table:",dc.table_name," add new columns"), "execute dm_log_errors ",
   row + 1, ' "', file3,
   '", ', row + 1, ' "", ',
   row + 1, ' "", ', row + 1,
   ' "', errstr, '",',
   row + 1, " msg, msgnum go", row + 2,
   reset_error = 1, "execute oragen3 '", dc.table_name,
   "' go", row + 2
  WITH nocounter, format = variable, noheading,
   formfeed = none, maxcol = 512, maxrow = 1,
   append
 ;end select
 SELECT INTO value(file2)
  dc.table_name, dc.data_type, dc.column_name,
  dc.nullable, dc.data_default, dc.data_length,
  default_is_null = nullind(dc.data_default)
  FROM dm_columns dc
  PLAN (dc
   WHERE dc.table_name=tbl_name
    AND dc.schema_date=cnvtdatetime( $2))
  HEAD REPORT
   "dm_clear_errors go", row + 2, "rdb alter table ",
   tbl_name, row + 1, " modify (",
   cnum = 0
  DETAIL
   cnum = (cnum+ 1)
   IF (cnum > 1)
    ","
   ENDIF
   row + 1, dc.column_name, " DEFAULT "
   IF (default_is_null=1)
    str->str = " NULL"
   ELSE
    str->str = build(dc.data_default," ")
   ENDIF
   str->str
  FOOT REPORT
   row + 1, ") go", row + 2,
   "set msgnum=error(msg,1) go", row + 1, errstr = build("alter table:",dc.table_name,
    " modify column:",dc.column_name," null"),
   "execute dm_log_errors ", row + 1, ' "',
   file3, '", ', row + 1,
   ' "", ', row + 1, ' "", ',
   row + 1, ' "', errstr,
   '",', row + 1, " msg, msgnum go",
   row + 2, reset_error = 1
  WITH nocounter, format = variable, noheading,
   formfeed = none, maxcol = 512, maxrow = 1,
   append
 ;end select
#end_program
END GO
