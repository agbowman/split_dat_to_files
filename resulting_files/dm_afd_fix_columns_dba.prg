CREATE PROGRAM dm_afd_fix_columns:dba
 SET filename1 = "dm_afd_fix_schema1"
 SET filename2 = "dm_afd_fix_schema2"
 SET filename3 = "dm_afd_fix_schema3"
 SET filename4 = "dm_afd_fix_schema4.dat"
 SET default_value = fillstring(40," ")
 SET tempstr = fillstring(110," ")
 SET errstr = fillstring(110," ")
 SET tbl_name =  $1
 SELECT INTO value(filename2)
  dc.table_name, dc.data_type, utc.data_type,
  dc.column_name, dc.nullable, utc.nullable,
  dc.data_default, utc.data_default, utc.data_length,
  dc.data_length
  FROM dm_user_tab_cols utc,
   dm_afd_columns dc
  PLAN (dc
   WHERE dc.table_name=tbl_name)
   JOIN (utc
   WHERE utc.table_name=dc.table_name
    AND utc.column_name=dc.column_name
    AND ((utc.data_type=dc.data_type) OR (((utc.data_type="NUMBER"
    AND dc.data_type="FLOAT") OR (((utc.data_type="VARCHAR2"
    AND dc.data_type="CHAR") OR (utc.data_type="CHAR"
    AND dc.data_type="VARCHAR2")) )) )) )
  DETAIL
   IF (dc.data_type != utc.data_type)
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
    row + 1, "rdb ALTER TABLE ", dc.table_name,
    row + 1
    IF (utc.data_type="NUMBER"
     AND dc.data_type="FLOAT")
     " modify (", dc.column_name, " FLOAT) go ",
     row + 1
    ELSE
     " modify (", dc.column_name, " ",
     dc.data_type, "(", dc.data_length,
     ") ) go ", row + 1
    ENDIF
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, errstr = concat(
     '"alter table ',trim(dc.table_name)," modify column ",trim(dc.column_name),'" go'),
    "set error_msg= ", errstr, row + 1,
    'set rstring = "" go', row + 1, 'set rstring1 = "" go',
    row + 1, "execute dm_check_errors go", row + 2,
    reset_error = 1
   ENDIF
   IF (dc.nullable != utc.nullable)
    IF (dc.nullable="N")
     IF (((dc.data_type="FLOAT") OR (dc.data_type="NUMBER")) )
      default_value = "0"
     ELSEIF (dc.data_type="DATE")
      default_value = "to_date('1/1/1900','MM/DD/YYYY')"
     ELSE
      default_value = '" "'
     ENDIF
     'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
     row + 1, "rdb UPDATE  ", dc.table_name,
     row + 1, tempstr = build(dc.column_name," = ",default_value), " set ",
     tempstr, row + 1, tempstr = build(dc.column_name," is NULL go"),
     " where ", tempstr, row + 1,
     "commit go", row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go',
     row + 1, errstr = concat('"update table ',trim(dc.table_name)," set column ",trim(dc.column_name
       ),'" go'), "set error_msg= ",
     errstr, row + 1, 'set rstring = "" go',
     row + 1, 'set rstring1 = "" go', row + 1,
     "execute dm_check_errors go", row + 2, reset_error = 1
    ENDIF
    tempstr = build(dc.table_name," modify (",dc.column_name),
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
    "set error_reported = 0 go", row + 1, "rdb ALTER TABLE ",
    tempstr, row + 1
    IF (dc.nullable="N")
     " NOT "
    ENDIF
    " NULL) go", row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go',
    row + 1, errstr = concat('"alter table ',trim(dc.table_name)," modify column ",trim(dc
      .column_name),' [NOT]NULL" go'), "set error_msg= ",
    errstr, row + 1, 'set rstring = "" go',
    row + 1, 'set rstring1 = "" go', row + 1,
    "execute dm_check_errors go", row + 2, reset_error = 1
   ENDIF
   IF (dc.data_default != utc.data_default)
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
    row + 1, "rdb ALTER TABLE ", dc.table_name,
    row + 1, " modify (", dc.column_name,
    row + 1
    IF (dc.data_default=" ")
     tempstr = " NULL) go"
    ELSE
     tempstr = build(dc.data_default,") go")
    ENDIF
    "default ", tempstr, row + 1,
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, errstr = concat(
     '"alter table ',trim(dc.table_name)," modify column ",trim(dc.column_name),'" go'),
    "set error_msg= ", errstr, row + 1,
    'set rstring = "" go', row + 1, 'set rstring1 = "" go',
    row + 1, "execute dm_check_errors go", row + 2,
    reset_error = 1
   ENDIF
   IF (dc.data_length != utc.data_length
    AND dc.data_length > utc.data_length
    AND ((dc.data_type="VARCHAR2") OR (((dc.data_type="VARCHAR") OR (dc.data_type="CHAR")) )) )
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
    row + 1, "rdb ALTER TABLE ", dc.table_name,
    row + 1, " modify (", dc.column_name,
    " ", row + 1, tempstr = build(dc.data_type,"(",dc.data_length,")) go"),
    tempstr, row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go',
    row + 1, errstr = concat('"alter table ',trim(dc.table_name)," modify column ",trim(dc
      .column_name),' (data type/length)" go'), "set error_msg= ",
    errstr, row + 1, 'set rstring = "" go',
    row + 1, 'set rstring1 = "" go', row + 1,
    "execute dm_check_errors go", row + 2, reset_error = 1
   ENDIF
  WITH nocounter, format = stream, noheading,
   formfeed = none, maxcol = 512, maxrow = 1,
   append
 ;end select
 SELECT INTO value(filename2)
  dc.seq, dc.table_name, dc.column_name,
  dc.data_type, dc.data_length, dc.data_default,
  dc.nullable
  FROM dm_afd_columns dc
  WHERE dc.table_name=tbl_name
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM dm_user_tab_cols utc
   WHERE utc.table_name=dc.table_name
    AND utc.column_name=dc.column_name)))
  HEAD REPORT
   'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
   row + 1, "rdb ALTER TABLE ", dc.table_name,
   row + 1, "add (", cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 1)
    ",", row + 1
   ELSE
    row + 1
   ENDIF
   dc.column_name
   IF (((dc.data_type="VARCHAR2") OR (((dc.data_type="VARCHAR") OR (dc.data_type="CHAR")) )) )
    tempstr = build(dc.data_type,"(",dc.data_length,")"), "  ", tempstr
   ELSE
    "  ", dc.data_type
   ENDIF
   IF (dc.data_default != " ")
    row + 1, " default ", dc.data_default,
    row + 1
   ENDIF
   IF (dc.nullable="N")
    " not null"
   ENDIF
  FOOT REPORT
   ") go", row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go',
   row + 1, errstr = concat('"alter table ',trim(dc.table_name)," add column ",trim(dc.column_name),
    '" go'), "set error_msg= ",
   errstr, row + 1, 'set rstring = "" go',
   row + 1, 'set rstring1 = "" go', row + 1,
   "execute dm_check_errors go", row + 2, reset_error = 1,
   'execute oragen3 "', dc.table_name, '" go',
   row + 1
  WITH nocounter, format = stream, noheading,
   formfeed = none, maxcol = 512, maxrow = 1,
   append
 ;end select
END GO
