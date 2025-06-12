CREATE PROGRAM dm_codevalue_valid:dba
 DELETE  FROM dm_invalid_table_value
  WHERE 1=1
 ;end delete
 FREE SET data
 RECORD data(
   1 list[*]
     2 table_name = c30
     2 column_name = c30
   1 num = i4
 )
 SET data->num = 0
 SET stat = alterlist(data->list,10)
 SELECT INTO "nl:"
  utc.table_name, utc.column_name
  FROM dm_env_mrg_table_list d,
   user_tab_columns utc
  WHERE utc.table_name=d.table_name
   AND utc.column_name IN ("CODE_VALUE", "*_CD")
  ORDER BY utc.table_name, utc.column_name
  DETAIL
   data->num = (data->num+ 1)
   IF (mod(data->num,10)=1)
    stat = alterlist(data->list,(data->num+ 9))
   ENDIF
   data->list[data->num].table_name = utc.table_name, data->list[data->num].column_name = utc
   .column_name
  WITH nocounter
 ;end select
 SET code_values[1] = 0.0
 SET row_ids[1] = fillstring(18," ")
 SET kount = 0
 FOR (kount = 1 TO data->num)
   FREE SET parser_buffer
   SET parser_buffer[20] = fillstring(132," ")
   SET cv_count = 0
   SET parser_buffer[1] = 'select into "nl:"'
   SET parser_buffer[2] = concat("t1.rowid, t1.",trim(data->list[kount].column_name))
   SET parser_buffer[3] = concat("from ",trim(data->list[kount].table_name)," t1 ")
   SET parser_buffer[4] = concat("where not exists(select cv.code_value from code_value cv ",
    "where t1.",trim(data->list[kount].column_name)," = cv.code_value)")
   SET parser_buffer[5] = "detail"
   SET parser_buffer[6] = "cv_count=cv_count+1"
   SET parser_buffer[7] = "if(mod(cv_count,10)=1) "
   SET parser_buffer[8] = 'stat=memrealloc(code_values,cv_count+9,"f8") '
   SET parser_buffer[9] = 'stat=memrealloc(row_ids,cv_count+9,"c18") endif'
   SET parser_buffer[10] = concat("code_values[cv_count] = t1.",trim(data->list[kount].column_name))
   SET parser_buffer[11] = "row_ids[cv_count]=t1.rowid"
   SET parser_buffer[12] = "with nocounter go"
   SET count = 0
   FOR (count = 1 TO 12)
     CALL parser(parser_buffer[count])
   ENDFOR
   FOR (cnt = 1 TO cv_count)
    INSERT  FROM dm_invalid_table_value
     (table_name, column_name, row_id,
     invalid_value)
     VALUES(trim(data->list[kount].table_name), trim(data->list[kount].column_name), row_ids[cnt],
     code_values[cnt])
    ;end insert
    COMMIT
   ENDFOR
 ENDFOR
END GO
