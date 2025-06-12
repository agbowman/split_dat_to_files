CREATE PROGRAM dm_unique_iden_chk:dba
 DELETE  FROM dm_invalid_table_rows_except
  WHERE 1=1
 ;end delete
 COMMIT
 FREE SET list
 RECORD list(
   1 qual[*]
     2 table_name = vc
   1 table_count = i4
 )
 SET stat = alterlist(list->qual,10)
 SET list->table_count = 0
 SET counter = 0
 SELECT INTO "nl:"
  dm.table_name
  FROM dm_env_mrg_table_list dm
  ORDER BY dm.table_name
  DETAIL
   list->table_count = (list->table_count+ 1)
   IF (mod(list->table_count,10)=1
    AND (list->table_count != 1))
    stat = alterlist(list->qual,(list->table_count+ 9))
   ENDIF
   list->qual[list->table_count].table_name = cnvtupper(dm.table_name)
  WITH nocounter
 ;end select
 FOR (counter = 1 TO list->table_count)
   FREE SET col_list
   RECORD col_list(
     1 var[*]
       2 column_name = vc
       2 unique_ident_ind = i4
     1 var_count = i4
   )
   SET col_list->var_count = 0
   SET stat2 = alterlist(col_list->var,10)
   FREE SET parser_buffer
   SET parser_buffer[15] = fillstring(132," ")
   SET tab_name = fillstring(132," ")
   SET parser_buffer[1] = 'select into "nl:"'
   SET parser_buffer[2] = "dc.column_name"
   SET parser_buffer[3] = " from dm_columns_doc dc"
   SET parser_buffer[4] = concat(" where dc.table_name = ","'",list->qual[counter].table_name,"'",
    " and dc.unique_ident_ind = 1")
   SET parser_buffer[5] = "detail"
   SET parser_buffer[6] = "col_list->var_count = col_list->var_count+1"
   SET parser_buffer[7] = "if (mod(col_list->var_count,10) = 1 and col_list->var_count != 1)"
   SET parser_buffer[8] = "stat2 = alterlist(col_list->var, col_list->var_count+9)"
   SET parser_buffer[9] = "endif"
   SET parser_buffer[10] = "col_list->var[col_list->var_count]->column_name = dc.column_name"
   SET parser_buffer[11] = "with nocounter go"
   SET count = 0
   FOR (count = 1 TO 11)
     CALL parser(parser_buffer[count],1)
   ENDFOR
   IF (curqual=0)
    UPDATE  FROM dm_env_mrg_table_list
     SET invalid_unique_ind = 1
     WHERE (table_name=list->qual[counter].table_name)
    ;end update
    COMMIT
   ELSE
    SET cnt = 0
    SET cnt2 = 0
    SET xyz = fillstring(132," ")
    SET abc = fillstring(132," ")
    FOR (cnt = 1 TO col_list->var_count)
      IF (cnt2=0)
       SET xyz = concat("t.",trim(col_list->var[cnt].column_name))
       SET abc = concat(trim(col_list->var[cnt].column_name))
       SET cnt2 = 1
      ELSE
       SET xyz = concat(xyz,","," t.",trim(col_list->var[cnt].column_name))
       SET abc = concat(abc,",",trim(col_list->var[cnt].column_name))
      ENDIF
    ENDFOR
    FREE SET par_buffer
    SET par_buffer[20] = fillstring(132," ")
    SET tab_name = concat(list->qual[counter].table_name," ","t")
    SET par_buffer[1] = 'select into "nl:" count(*),'
    SET par_buffer[2] = xyz
    SET par_buffer[3] = concat(" from ",tab_name)
    SET par_buffer[4] = " group by "
    SET par_buffer[5] = xyz
    SET par_buffer[6] = " having count(*)>1 "
    SET par_buffer[7] = " with nocounter go "
    SET count2 = 0
    FOR (count2 = 1 TO 7)
      CALL parser(par_buffer[count2],1)
    ENDFOR
    IF (curqual > 0)
     UPDATE  FROM dm_env_mrg_table_list
      SET dup_rows = 1
      WHERE (table_name=list->qual[counter].table_name)
     ;end update
     COMMIT
     FREE SET index_list
     RECORD index_list(
       1 qual2[*]
         2 index_name = vc
       1 ind_count = i4
     )
     SET index_list->ind_count = 0
     SET stat3 = alterlist(index_list->qual2,10)
     FREE SET par_buff
     SET par_buff[20] = fillstring(132," ")
     SET par_buff[1] = ' select into "nl:" ux.index_name'
     SET par_buff[2] = " from user_indexes ux"
     SET par_buff[3] = concat(" where ux.table_name = ","'",list->qual[counter].table_name,"'")
     SET par_buff[4] = " and ux.uniqueness = 'UNIQUE' "
     SET par_buff[5] = " detail"
     SET par_buff[6] = "index_list->ind_count = index_list->ind_count+1"
     SET par_buff[7] = "if (mod(index_list->ind_count,10) = 1 and index_list->ind_count !=1)"
     SET par_buff[8] = "stat3 = alterlist(index_list->qual2, index_list->ind_count+9)"
     SET par_buff[9] = "endif"
     SET par_buff[10] = "index_list->qual2[index_list->ind_count]->index_name=ux.index_name"
     SET par_buff[11] = " with nocounter go"
     SET count3 = 0
     FOR (count3 = 1 TO 11)
       CALL parser(par_buff[count3],1)
     ENDFOR
     SET continue = 0
     IF (continue=0)
      FOR (kount = 1 TO index_list->ind_count)
        FREE SET index_cols
        RECORD index_cols(
          1 qual3[*]
            2 index_column = vc
          1 col_count = i4
        )
        SET index_cols->col_count = 0
        SET stat4 = alterlist(index_cols->qual3,10)
        FREE SET par_buff2
        SET par_buff2[20] = fillstring(132," ")
        SET par_buff2[1] = ' select into "nl:" uc.column_name'
        SET par_buff2[2] = " from user_ind_columns uc"
        SET par_buff2[3] = concat(" where uc.table_name = ","'",list->qual[counter].table_name,"'")
        SET par_buff2[4] = concat(" and uc.index_name = ","'",index_list->qual2[kount].index_name,"'"
         )
        SET par_buff2[5] = " detail"
        SET par_buff2[6] = "index_cols->col_count = index_cols->col_count+1"
        SET par_buff2[7] = "if (mod(index_cols->col_count,10) = 1 and index_cols->col_count !=1) "
        SET par_buff2[8] = "stat4 = alterlist(index_cols->qual3, index_cols->col_count+9)"
        SET par_buff2[9] = "endif"
        SET par_buff2[10] = "index_cols->qual3[index_cols->col_count]->index_column= uc.column_name"
        SET par_buff2[11] = " with nocounter go"
        SET count4 = 0
        FOR (count4 = 1 TO 11)
          CALL parser(par_buff2[count4],1)
        ENDFOR
        SET ndx_count = 0
        FOR (cntt = 1 TO col_list->var_count)
          FOR (kount2 = 1 TO index_cols->col_count)
            IF ((index_cols->qual3[kount2]=col_list->var[cntt]))
             SET ndx_count = (ndx_count+ 1)
            ENDIF
          ENDFOR
        ENDFOR
        IF ((col_list->var_count=ndx_count))
         SET continue = 1
        ENDIF
      ENDFOR
     ENDIF
     IF (continue=0)
      FREE SET buff
      SET buff[10] = fillstring(132," ")
      SET buff[1] = "rdb alter table "
      SET buff[2] = trim(list->qual[counter].table_name)
      SET buff[3] = " drop constraint XIE_TEMP "
      SET buff[4] = " go"
      SET buff[5] = " commit go"
      SET knt3 = 0
      FOR (knt3 = 1 TO 5)
        CALL parser(buff[knt3],1)
      ENDFOR
      FREE SET p_buff
      SET p_buff[10] = fillstring(132," ")
      SET p_buff[1] = "rdb alter table "
      SET p_buff[2] = trim(list->qual[counter].table_name)
      SET p_buff[3] = " add constraint XIE_TEMP unique ( "
      SET p_buff[4] = abc
      SET p_buff[5] = " ) using index "
      SET p_buff[6] = " exceptions into dm_invalid_table_rows_except go"
      SET knt = 0
      FOR (knt = 1 TO 6)
        CALL parser(p_buff[knt],1)
      ENDFOR
      FREE SET buff_pars
      SET buff_pars[10] = fillstring(132," ")
      SET buff_pars[1] = "rdb alter table "
      SET buff_pars[2] = trim(list->qual[counter].table_name)
      SET buff_pars[3] = " drop constraint XIE_TEMP "
      SET buff_pars[4] = " go"
      SET buff_pars[5] = " commit go"
      SET knt2 = 0
      FOR (knt2 = 1 TO 5)
        CALL parser(buff_pars[knt2],1)
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
END GO
