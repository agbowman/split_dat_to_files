CREATE PROGRAM dm_output_codesets
 FREE SET table_lst
 RECORD table_lst(
   1 num = i4
   1 list[*]
     2 table_name = c30
 )
 SET table_lst->num = 0
 SELECT INTO "nl:"
  dm.table_name
  FROM dm_env_mrg_table_list dm
  WHERE dm.process_flg=2
  DETAIL
   table_lst->num = (table_lst->num+ 1)
   IF (mod(table_lst->num,10)=1)
    stat = alterlist(table_lst->list,(table_lst->num+ 9))
   ENDIF
   table_lst->list[table_lst->num].table_name = dm.table_name
  WITH nocounter
 ;end select
 SET kount = 0
 FOR (kount = 1 TO table_lst->num)
   FREE SET table_data
   RECORD table_data(
     1 num = i4
     1 list[*]
       2 column_name = c30
   )
   SET table_data->num = 0
   SELECT INTO "nl:"
    utc.column_name
    FROM user_tab_columns utc
    WHERE (utc.table_name=table_lst->list[kount].table_name)
     AND utc.column_name IN ("CODE_VALUE", "*_CD")
    DETAIL
     table_data->num = (table_data->num+ 1)
     IF (mod(table_data->num,10)=1)
      stat = alterlist(table_data->list,(table_data->num+ 9))
     ENDIF
     table_data->list[table_data->num].column_name = utc.column_name
    WITH nocounter
   ;end select
   SET code_sets[1] = 0.0
   SET kount2 = 0
   FOR (kount2 = 1 TO table_data->num)
     FREE SET parser_buffer
     SET parser_buffer[100] = fillstring(132," ")
     SET cs_count = 0
     SET parser_buffer[1] = 'select distinct into "nl:"'
     SET parser_buffer[2] = " cv.code_set "
     SET parser_buffer[3] = concat("from"," ",trim(table_lst->list[kount].table_name)," ",
      "t1, code_value cv")
     SET parser_buffer[4] = concat("where t1.",trim(table_data->list[kount2].column_name)," >0")
     SET parser_buffer[5] = concat(" and t1.",trim(table_data->list[kount2].column_name),
      " = cv.code_value")
     SET parser_buffer[6] = "detail"
     SET parser_buffer[7] = " cs_count=cs_count+1"
     SET parser_buffer[8] =
     ' if(mod(cs_count,10)=1) stat=memrealloc(code_sets,cs_count+9,"f8") endif'
     SET parser_buffer[9] = " code_sets[cs_count]=cv.code_set"
     SET parser_buffer[10] = "with nocounter go"
     SET count = 0
     FOR (count = 1 TO 10)
       CALL parser(parser_buffer[count])
     ENDFOR
     SET cnt = 0
     FOR (cnt = 1 TO cs_count)
       INSERT  FROM dm_env_mrg_codeset_list
        (code_set)
        VALUES(code_sets[cnt])
       ;end insert
       UPDATE  FROM dm_env_mrg_codeset_list
        SET mode_flg = 2
        WHERE (code_set=code_sets[cnt])
        WITH nocounter
       ;end update
       COMMIT
     ENDFOR
   ENDFOR
 ENDFOR
END GO
