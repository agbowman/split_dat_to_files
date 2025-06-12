CREATE PROGRAM dm_fix_column_constraints:dba
 SET filename1 = concat( $1,"1")
 SET filename2 = concat( $1,"2")
 SET filename3 = concat( $1,"3")
 SET filename4 = concat( $1,"4.dat")
 SET loopcount = 0
 SELECT INTO value(filename2)
  *
  FROM dual
  DETAIL
   "%o  ", filename4, row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, nocounter
 ;end select
 SET default_value = fillstring(40," ")
 SET tempstr = fillstring(255," ")
 SELECT INTO value(filename2)
  dc.table_name, dc.data_type, dc.column_name,
  dc.nullable, utc.nullable, dc.data_default,
  utc.data_default
  FROM user_tab_columns utc,
   dm_columns dc
  WHERE dc.schema_date=cnvtdatetime( $2)
   AND utc.table_name=dc.table_name
   AND utc.column_name=dc.column_name
   AND dc.data_type=utc.data_type
  DETAIL
   IF (dc.nullable != utc.nullable)
    IF (dc.nullable="N")
     IF (((dc.data_type="FLOAT") OR (dc.data_type="NUMBER")) )
      default_value = "0"
     ELSEIF (dc.data_type="DATE")
      default_value = 'cnvtdatetime("1-jan-1900")'
     ELSE
      default_value = '" "'
     ENDIF
     "update into ", dc.table_name, row + 1,
     tempstr = build(dc.column_name," = ",default_value), " set ", tempstr,
     row + 1, tempstr = build(dc.column_name," = NULL go"), " where ",
     tempstr, row + 1, "commit go",
     row + 1
    ENDIF
    tempstr = build(dc.table_name," modify (",dc.column_name), "rdb alter table ", tempstr,
    row + 1
    IF (dc.nullable="N")
     " NOT "
    ENDIF
    " NULL) go", row + 1
   ENDIF
   IF (dc.data_default != utc.data_default)
    "rdb alter table ", dc.table_name, row + 1,
    " modify (", dc.column_name, row + 1
    IF (dc.data_default != " ")
     tempstr = build(dc.data_default,") go")
    ELSE
     tempstr = "null) go"
    ENDIF
    "default ", tempstr, row + 1
   ENDIF
  FOOT REPORT
   "%o", row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append,
   nocounter
 ;end select
END GO
