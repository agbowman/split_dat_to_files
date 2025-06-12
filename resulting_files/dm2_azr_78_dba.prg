CREATE PROGRAM dm2_azr_78:dba
 SET tbl_name = cnvtupper( $1)
#0100_start
 EXECUTE FROM 1000_init TO 1099_init_exit
 EXECUTE FROM 2000_load_table_list TO 2099_load_table_list_exit
 IF (nbr_rows > 0)
  EXECUTE FROM 3000_add_zero_rows TO 3099_add_zero_rows_exit
 ENDIF
 GO TO 9999_end
#1000_init
 SET modify = system
 SET parser_buffer[1000] = fillstring(120," ")
 SET save_table_name = fillstring(32," ")
 SET table_name[15000] = fillstring(32," ")
 SET column_name[15000] = fillstring(32," ")
 SET data_type[15000] = fillstring(32," ")
 SET null_option[15000] = " "
 SET nbr_rows = 0
 SET x = 0
 SET y = 0
 SET z = 0
#1099_init_exit
#2000_load_table_list
 SELECT INTO "NL:"
  utc.table_name, utc.column_name, utc.data_type,
  utc.nullable
  FROM user_tab_columns utc
  PLAN (utc
   WHERE utc.table_name=patstring(tbl_name))
  DETAIL
   nbr_rows = (nbr_rows+ 1), table_name[nbr_rows] = utc.table_name, column_name[nbr_rows] = utc
   .column_name,
   data_type[nbr_rows] = utc.data_type, null_option[nbr_rows] = "Y"
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  nc.table_name, nc.column_name
  FROM (dummyt d  WITH seq = nbr_rows),
   dm2_user_notnull_cols nc
  PLAN (d)
   JOIN (nc
   WHERE (nc.table_name=table_name[d.seq])
    AND (nc.column_name=column_name[d.seq]))
  DETAIL
   CALL echo(concat(nc.table_name,":",nc.column_name)), null_option[d.seq] = "N"
  WITH nocounter
 ;end select
#2099_load_table_list_exit
#3000_add_zero_rows
 SET save_table_name = fillstring(32," ")
 FOR (x = 1 TO nbr_rows)
   IF ( NOT ((table_name[x]=save_table_name)))
    IF (x > 1)
     SET y = (y+ 1)
     SET parser_buffer[y] = "with nocounter"
     SET y = (y+ 1)
     SET parser_buffer[y] = "go "
     SET y = (y+ 1)
     SET parser_buffer[y] = "commit go"
     FOR (z = 1 TO y)
       CALL parser(parser_buffer[z])
     ENDFOR
     SET dummy = initarray(parser_buffer,fillstring(132," "))
    ENDIF
    SET save_table_name = table_name[x]
    SET parser_buffer[1] = concat("insert from ",trim(save_table_name)," x  set ")
    SET y = 1
   ENDIF
   IF (y > 1)
    SET parser_buffer[y] = concat(trim(parser_buffer[y]),", ")
   ENDIF
   SET y = (y+ 1)
   IF ((((data_type[x]="NUMBER")) OR ((data_type[x]="FLOAT"))) )
    SET parser_buffer[y] = concat(" x.",trim(column_name[x])," = 0 ")
   ELSE
    IF ((((data_type[x]="VARCHAR2")) OR ((((data_type[x]="VARCHAR")) OR ((((data_type[x]="LONG")) OR
    ((data_type[x]="CHAR"))) )) )) )
     SET parser_buffer[y] = concat(" x.",trim(column_name[x]),' = " " ')
    ELSE
     IF ((data_type[x]="LONG RAW"))
      SET parser_buffer[y] = concat(" x.",trim(column_name[x])," = sqlpassthru(^rawtohex('0')^,1) ")
     ELSE
      IF ((data_type[x]="DATE"))
       IF ((null_option[x]="N"))
        SET parser_buffer[y] = concat(" x.",trim(column_name[x]),
         " = cnvtdatetime(curdate, curtime3) ")
       ELSE
        SET parser_buffer[y] = concat(" x.",trim(column_name[x])," = NULL ")
       ENDIF
      ELSE
       SET parser_buffer[y] = concat(" x.",trim(column_name[x])," = NULL ")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET y = (y+ 1)
 SET parser_buffer[y] = " with nocounter "
 SET y = (y+ 1)
 SET parser_buffer[y] = " go "
 SET y = (y+ 1)
 SET parser_buffer[y] = "commit go"
 FOR (z = 1 TO y)
   CALL parser(parser_buffer[z])
 ENDFOR
#3099_add_zero_rows_exit
#9999_end
END GO
