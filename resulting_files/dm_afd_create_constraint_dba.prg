CREATE PROGRAM dm_afd_create_constraint:dba
 SET filename2 = "dm_afd_fix_schema2"
 SET filename3 = "dm_afd_fix_schema3"
 SET tempstr = fillstring(110," ")
 SET errstr = fillstring(110," ")
 SELECT
  IF (( $2=1))
   WHERE (dc.constraint_name= $1)
    AND dc.constraint_name=dcc.constraint_name
    AND dc.table_name=dcc.table_name
  ELSE
   WHERE (dc.r_constraint_name= $1)
    AND dc.constraint_name=dcc.constraint_name
    AND dc.table_name=dcc.table_name
  ENDIF
  INTO value(filename2)
  dc.table_name, dc.constraint_name, dc.constraint_type,
  dcc.column_name, dc.status_ind, dcc.position,
  dc.parent_table_name, dc.parent_table_columns
  FROM dm_afd_cons_columns dcc,
   dm_afd_constraints dc
  ORDER BY dc.constraint_name, dcc.position
  HEAD dc.constraint_name
   tempstr = "", 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
   "set error_reported = 0 go", row + 1, "rdb ALTER TABLE ",
   dc.table_name, " add constraint ", dc.constraint_name,
   row + 1
   IF (dc.constraint_type="R")
    "FOREIGN KEY", row + 1, errstr = concat("add foreign key constraint ",trim(dc.constraint_name))
   ELSEIF (dc.constraint_type="P")
    "PRIMARY KEY", row + 1, errstr = concat("add primary key constraint ",trim(dc.constraint_name))
   ELSE
    "UNIQUE", row + 1, errstr = concat("add unique constraint ",trim(dc.constraint_name))
   ENDIF
  DETAIL
   IF (dcc.position=1)
    tempstr = build("(",trim(dcc.column_name))
   ELSE
    tempstr = build(tempstr," ,",trim(dcc.column_name))
   ENDIF
  FOOT  dc.constraint_name
   tempstr, row + 1
   IF (dc.constraint_type="R")
    ") references ", dc.parent_table_name, row + 1,
    tempstr = concat("(",trim(dc.parent_table_columns),")"), tempstr, row + 1
   ELSE
    ")", row + 1
   ENDIF
   IF (((dc.status_ind=0) OR (dc.constraint_type="R")) )
    " disable "
   ENDIF
   " go", row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go',
   row + 1, tempstr = concat('"alter table ',trim(dc.table_name)," ",trim(errstr),'" go'),
   "set error_msg= ",
   tempstr, row + 1, 'set rstring = "" go',
   row + 1, 'set rstring1 = "" go', row + 1,
   "execute dm_check_errors go", row + 2, reset_error = 1
  WITH format = stream, noheading, append,
   formfeed = none, maxcol = 512, outerjoin = di,
   maxrow = 1
 ;end select
END GO
