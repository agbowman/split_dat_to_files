CREATE PROGRAM dm_create_constraint:dba
 SET tbl_name = table_list->table_name[ $2].tname
 SET process_flg = table_list->table_name[ $2].process_flg
 SET file2 = table_list->table_name[ $2].output2_filename
 SET file3 = table_list->table_name[ $2].output3_filename
 SET file4 = table_list->table_name[ $2].output4_filename
 SET file_sql = table_list->table_name[ $2].output2sql_filename
 SET file2d = table_list->table_name[ $2].output2d_filename
 SET file3d = table_list->table_name[ $2].output3d_filename
 SET file4d = table_list->table_name[ $2].output4d_filename
 SET created_flg = table_list->table_name[ $2].created_flg
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
 SET tempstr = fillstring(110," ")
 SET errstr = fillstring(110," ")
 SELECT
  IF (( $4=1))
   WHERE (dc.constraint_name= $1)
    AND dc.schema_date=cnvtdatetime( $3)
    AND dc.schema_date=dcc.schema_date
    AND dc.constraint_name=dcc.constraint_name
    AND dc.table_name=dcc.table_name
  ELSE
   WHERE (dc.r_constraint_name= $1)
    AND dc.schema_date=cnvtdatetime( $3)
    AND dc.schema_date=dcc.schema_date
    AND dc.constraint_name=dcc.constraint_name
    AND dc.table_name=dcc.table_name
  ENDIF
  INTO value(filename)
  dc.table_name, dc.constraint_name, dc.constraint_type,
  dcc.column_name, dc.status_ind, dcc.position,
  dc.parent_table_name, dc.parent_table_columns
  FROM dm_cons_columns dcc,
   dm_constraints dc
  ORDER BY dc.constraint_name, dcc.position
  HEAD dc.constraint_name
   tempstr = "", "dm_clear_errors go", row + 2,
   "rdb ALTER TABLE ", dc.table_name, row + 1,
   "  add constraint ", dc.constraint_name
   IF (dc.constraint_type="R")
    " FOREIGN KEY", row + 1, errstr = concat("add foreign key constraint ",trim(dc.constraint_name))
   ELSEIF (dc.constraint_type="P")
    " PRIMARY KEY", row + 1, errstr = concat("add primary key constraint ",trim(dc.constraint_name))
   ELSE
    " UNIQUE", row + 1, errstr = concat("add unique constraint ",trim(dc.constraint_name))
   ENDIF
  DETAIL
   IF (dcc.position=1)
    "  (", dcc.column_name, row + 1
   ELSE
    "  ,", dcc.column_name, row + 1
   ENDIF
  FOOT  dc.constraint_name
   IF (dc.constraint_type="R")
    "  ) references ", dc.parent_table_name, row + 1,
    len = size(trim(dc.parent_table_columns)), i = 1, found = findstring(",",dc.parent_table_columns,
     i)
    IF (found > 0)
     WHILE (found > 0)
       col_name = substring(i,(found - i),dc.parent_table_columns)
       IF (i=1)
        tempstr = concat("(",trim(col_name))
       ELSE
        tempstr = concat(",",trim(col_name))
       ENDIF
       "    ", tempstr, row + 1,
       i = (found+ 1), found = findstring(",",dc.parent_table_columns,i)
     ENDWHILE
     col_name = substring(i,len,dc.parent_table_columns), tempstr = concat(",",trim(col_name),")"),
     "    ",
     tempstr, row + 1
    ELSE
     tempstr = concat("(",trim(dc.parent_table_columns),")"), "    ", tempstr,
     row + 1
    ENDIF
   ELSE
    "  )", row + 1
   ENDIF
   IF (((dc.status_ind=0) OR (dc.constraint_type="R")) )
    "  disable "
   ENDIF
   " go", row + 2, "set msgnum=error(msg,1) go",
   row + 1, tempstr = concat("alter table ",trim(dc.table_name)," ",trim(errstr)," go"),
   "execute dm_log_errors ",
   row + 1, ' "', err_filename,
   '", ', row + 1, ' "", ',
   row + 1, ' "", ', row + 1,
   ' "', tempstr, '",',
   row + 1, " msg, msgnum go", row + 2,
   reset_error = 1
  WITH format = variable, noheading, append,
   formfeed = none, maxcol = 512, outerjoin = di,
   maxrow = 1
 ;end select
#end_program
END GO
