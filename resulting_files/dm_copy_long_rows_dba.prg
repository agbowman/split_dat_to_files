CREATE PROGRAM dm_copy_long_rows:dba
 SET source_table_name = cnvtupper( $1)
 SET target_table_name = cnvtupper( $2)
 SET from_column[100] = fillstring(200," ")
 SET to_column[100] = fillstring(200," ")
 SET to_new_column[100] = fillstring(200," ")
 SET from_column_type[100] = fillstring(9," ")
 SET to_column_type[100] = fillstring(9," ")
 SET base_data_type = fillstring(1," ")
 SET column_count = 0
 SET msg = fillstring(256," ")
 SET rowid[100000] = fillstring(18," ")
 SET last_rowid = fillstring(18,"0")
 SET select_parser_buffer[200] = fillstring(255," ")
 SET insert_parser_buffer[200] = fillstring(255," ")
 SET parser_buffer = fillstring(255," ")
 SET select_parser_count = 0
 SET insert_parser_count = 0
 RECORD temp_data(
   1 data[100]
     2 date_column = dq8
     2 num_column = f8
     2 char_column = c255
   1 long_column = c32000
   1 long_raw_column = c32768
 )
 SELECT INTO "nl:"
  uic.column_name, uic.table_name, uic.column_id,
  uic.data_type, uic.nullable, uic.data_length
  FROM user_tab_columns uic
  WHERE uic.table_name=target_table_name
  ORDER BY uic.column_id
  DETAIL
   IF (uic.data_type="LONG")
    base_data_type = "L"
   ELSEIF (uic.data_type="LONG RAW ")
    base_data_type = "R"
   ELSEIF (((uic.data_type="NUMBER   ") OR (uic.data_type="FLOAT    ")) )
    base_data_type = "N"
   ELSEIF (((uic.data_type="CHAR     ") OR (((uic.data_type="VARCHAR2 ") OR (uic.data_type=
   "VARCHAR  ")) )) )
    base_data_type = "C"
   ELSE
    base_data_type = "D"
   ENDIF
   column_count = (column_count+ 1), to_column[column_count] = uic.column_name, to_new_column[
   column_count] = uic.column_name,
   to_column_type[column_count] = uic.data_type
   IF (uic.nullable != "Y")
    IF (base_data_type="N"
     AND ((uic.data_type="FLOAT    ") OR (uic.column_name IN ("*_COMPL", "*_VALUE", "*_CD", "*_ID")
    )) )
     from_column[column_count] = concat(uic.column_name," = if (nullind(s.",uic.column_name,
      ") = 1) 0.0 else s.",uic.column_name,
      " endif ")
    ELSEIF (base_data_type="N")
     from_column[column_count] = concat(uic.column_name," = if (nullind(s.",uic.column_name,
      ") = 1) 0 else s.",uic.column_name,
      " endif ")
    ELSEIF (base_data_type="D")
     from_column[column_count] = concat(uic.column_name," = if (nullind(s.",uic.column_name,
      ") = 1) cnvtdatetime(curdate, curtime3) else s.",uic.column_name,
      " endif ")
    ELSEIF (base_data_type="C")
     from_column[column_count] = concat(uic.column_name," = if (nullind(s.",uic.column_name,
      ") = 1) ' ' else substring(1,",cnvtstring(uic.data_length),
      ",",uic.column_name,") endif ")
    ELSEIF (base_data_type="L")
     from_column[column_count] = concat(uic.column_name," = if (nullind(s.",uic.column_name,
      ") = 1) ' ' else s.",uic.column_name,
      " endif ")
    ELSE
     from_column[column_count] = build(uic.column_name," = s.",uic.column_name)
    ENDIF
   ELSE
    IF (base_data_type="C")
     from_column[column_count] = build(uic.column_name," = substring(1,",cnvtstring(uic.data_length),
      ", s.",uic.column_name,
      ")")
    ELSE
     from_column[column_count] = build(uic.column_name," = s.",uic.column_name)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET select_parser_buffer[1] = 'select into "nl:"'
 SET select_parser_count = 1
 SET insert_parser_buffer[1] = concat("insert into ",target_table_name," a set ")
 SET insert_parser_count = 1
 FOR (i = 1 TO column_count)
  SET select_parser_count = (select_parser_count+ 1)
  IF (i > 1)
   SET select_parser_buffer[select_parser_count] = build(", ",from_column[i])
  ELSE
   SET select_parser_buffer[select_parser_count] = build(from_column[i])
  ENDIF
 ENDFOR
 SET select_parser_count = (select_parser_count+ 1)
 SET select_parser_buffer[select_parser_count] = concat(" from ",source_table_name)
 SET select_parser_buffer[select_parser_count] = build(select_parser_buffer[select_parser_count]," s"
  )
 SET select_parser_count = (select_parser_count+ 1)
 SET select_parser_buffer[select_parser_count] = build(" where s.rowid = rowid[cnt]")
 SET select_parser_count = (select_parser_count+ 1)
 SET select_parser_buffer[select_parser_count] = build("detail")
 FOR (i = 1 TO column_count)
   SET select_parser_count = (select_parser_count+ 1)
   SET insert_parser_count = (insert_parser_count+ 1)
   IF (i > 1)
    SET insert_parser_buffer[insert_parser_count] = build(" , a.",to_new_column[i]," = ")
   ELSE
    SET insert_parser_buffer[insert_parser_count] = build(" a.",to_new_column[i]," = ")
   ENDIF
   IF ((((to_column_type[i]="NUMBER")) OR ((to_column_type[i]="FLOAT"))) )
    SET select_parser_buffer[select_parser_count] = build("temp_data->data[",cnvtstring(i),
     "]->num_column=",to_column[i])
    SET insert_parser_buffer[insert_parser_count] = build(insert_parser_buffer[insert_parser_count],
     " temp_data->data[",cnvtstring(i),"]->num_column")
   ELSEIF ((((to_column_type[i]="CHAR")) OR ((((to_column_type[i]="VARCHAR")) OR ((to_column_type[i]=
   "VARCHAR2"))) )) )
    SET select_parser_buffer[select_parser_count] = build("temp_data->data[",cnvtstring(i),
     "]->char_column=",to_column[i])
    SET insert_parser_buffer[insert_parser_count] = build(insert_parser_buffer[insert_parser_count],
     " temp_data->data[",cnvtstring(i),"]->char_column")
   ELSEIF ((to_column_type[i]="DATE"))
    SET select_parser_buffer[select_parser_count] = build("temp_data->data[",cnvtstring(i),
     "]->date_column=",to_column[i])
    SET insert_parser_buffer[insert_parser_count] = build(insert_parser_buffer[insert_parser_count],
     " cnvtdatetime(temp_data->data[",cnvtstring(i),"]->date_column)")
   ELSEIF ((to_column_type[i]="LONG"))
    SET select_parser_buffer[select_parser_count] = build("temp_data->long_column= ",to_column[i])
    SET insert_parser_buffer[insert_parser_count] = build(insert_parser_buffer[insert_parser_count],
     " temp_data->long_column")
   ELSEIF ((to_column_type[i]="LONG RAW"))
    SET select_parser_buffer[select_parser_count] = build("temp_data->long_raw_column= s.",to_column[
     i])
    SET insert_parser_buffer[insert_parser_count] = build(insert_parser_buffer[insert_parser_count],
     " temp_data->long_raw_column")
   ENDIF
 ENDFOR
 SET select_parser_count = (select_parser_count+ 1)
 SET select_parser_buffer[select_parser_count] = build(" with nocounter go ")
 SET insert_parser_count = (insert_parser_count+ 1)
 SET insert_parser_buffer[insert_parser_count] = build(" with nocounter go ")
 SET batch_size = 10000
 SET finish = 0
 WHILE (finish=0)
   SET rowid_count = 0
   CALL parser('select into "nl:" s.rowid ',1)
   CALL parser("from ",1)
   SET parser_buffer = build(source_table_name," s")
   CALL parser(parser_buffer,1)
   SET parser_buffer = build(" where s.rowid > last_rowid")
   CALL parser(parser_buffer,1)
   CALL parser(" order by s.rowid",1)
   CALL parser("detail",1)
   CALL parser("if (rowid_count<batch_size)",1)
   CALL parser("rowid_count=rowid_count+1",1)
   CALL parser("rowid[rowid_count]=s.rowid",1)
   CALL parser("endif",1)
   SET parser_buffer = build("with nocounter go")
   CALL parser(parser_buffer,1)
   IF (rowid_count < batch_size)
    SET finish = 1
   ENDIF
   IF (rowid_count > 0)
    SET last_rowid = rowid[rowid_count]
   ENDIF
   SET cnt = 0
   SET done = 0
   SELECT INTO "nl:"
    msgnum = error(msg,1)
    WITH nocounter
   ;end select
   WHILE (done=0
    AND rowid_count > 0)
     SET cnt = (cnt+ 1)
     EXECUTE dm_move_the_row
     SELECT INTO "nl:"
      msgnum = error(msg,1)
      WITH nocounter
     ;end select
     IF (msg != fillstring(255," "))
      SET done = 1
      SET finish = 1
     ENDIF
     IF (cnt=rowid_count)
      SET done = 1
     ENDIF
   ENDWHILE
   COMMIT
 ENDWHILE
END GO
