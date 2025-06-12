CREATE PROGRAM dm_find_code_sets:dba
 FREE SET table_lst
 RECORD table_lst(
   1 num = i4
   1 list[*]
     2 table_name = c30
 )
 SET table_lst->num = 0
 SELECT INTO "nl:"
  ut.table_name
  FROM user_tables ut
  WHERE ut.table_name=cnvtupper( $2)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   dtl.table_name
   FROM dm_env_mrg_table_list dtl
   ORDER BY dtl.table_name
   DETAIL
    table_lst->num = (table_lst->num+ 1)
    IF (mod(table_lst->num,10)=1)
     stat = alterlist(table_lst->list,(table_lst->num+ 9))
    ENDIF
    table_lst->list[table_lst->num].table_name = dtl.table_name
   WITH nocounter
  ;end select
 ELSE
  SET table_lst->num = 1
  IF (mod(table_lst->num,10)=1)
   SET stat = alterlist(table_lst->list,1)
  ENDIF
  SET table_lst->list[table_lst->num].table_name = cnvtupper( $2) WITH nocounter
 ENDIF
 SELECT INTO  $1
  "c"
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   col 45, "CODE SET USAGE BY TABLE", row + 1,
   col 47, "Date: ", curdate"dd-mmm-yyyy;;d",
   row + 1
  DETAIL
   col 0, " ", row + 1
  WITH nocounter, format = stream, noheading,
   maxcol = 128, maxrow = 1, noformfeed
 ;end select
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
    PLAN (utc
     WHERE (utc.table_name=table_lst->list[kount].table_name)
      AND utc.column_name IN ("CODE_VALUE", "*_CD"))
    DETAIL
     table_data->num = (table_data->num+ 1)
     IF (mod(table_data->num,10)=1)
      stat = alterlist(table_data->list,(table_data->num+ 9))
     ENDIF
     table_data->list[table_data->num].column_name = utc.column_name
    WITH nocounter
   ;end select
   FREE SET keys
   RECORD keys(
     1 num = i4
     1 index_name = c30
     1 list[*]
       2 column_name = c30
   )
   SET keys->num = 0
   SELECT INTO "nl:"
    ucc.constraint_name, ucc.position, ucc.column_name
    FROM user_constraints uc,
     user_cons_columns ucc
    PLAN (uc
     WHERE (uc.table_name=table_lst->list[1].table_name)
      AND uc.constraint_type="P")
     JOIN (ucc
     WHERE ucc.constraint_name=uc.constraint_name)
    ORDER BY ucc.constraint_name, ucc.position, ucc.column_name
    HEAD ucc.constraint_name
     keys->index_name = ucc.constraint_name, col 0, keys->index_name,
     row + 1
    DETAIL
     keys->num = (keys->num+ 1)
     IF (mod(keys->num,5)=1)
      stat = alterlist(keys->list,(keys->num+ 4))
     ENDIF
     keys->list[keys->num].column_name = ucc.column_name, col + 1, keys->list[keys->num].column_name
    FOOT  ucc.constraint_name
     row + 1
    WITH nocounter
   ;end select
   SELECT INTO  $1
    "c"
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     row + 1, col 0, "TABLE NAME",
     col 32, "PRIMARY KEY", col 64,
     "COLUMN NAME", col 96, "CODE SET(S)",
     row + 1, col 0, "==============================",
     col 32, "==============================", col 64,
     "==============================", col 96, "==========="
    DETAIL
     row + 1, col 0, table_lst->list[kount].table_name,
     col 32, keys->index_name
    WITH nocounter, format = stream, noheading,
     maxcol = 128, maxrow = 1, formfeed = none,
     append
   ;end select
   SET code_sets[1] = 0.0
   SET kount2 = 0
   SET count = 0
   SET append = 0
   FOR (kount2 = 1 TO table_data->num)
     FREE SET parser_buffer
     SET parser_buffer[100] = fillstring(132," ")
     SET cs_count = 0
     SET parser_buffer[1] = 'select distinct into "nl:"'
     SET parser_buffer[2] = " cv.code_set "
     SET parser_buffer[3] = concat("from ",trim(table_lst->list[kount].table_name),
      " t1, code_value cv")
     SET parser_buffer[4] = concat(" where t1.",trim(table_data->list[kount2].column_name)," > 0")
     SET parser_buffer[5] = concat("   and t1.",trim(table_data->list[kount2].column_name),
      " = cv.code_value")
     SET parser_buffer[6] = "detail"
     SET parser_buffer[7] = " cs_count=cs_count+1"
     SET parser_buffer[8] =
     ' if(mod(cs_count,10)=1) stat=memrealloc(code_sets,cs_count+9,"f8") endif'
     SET parser_buffer[9] = " code_sets[cs_count]=cv.code_set"
     SET parser_buffer[10] = "with nocounter go"
     FOR (count = 1 TO 10)
       CALL parser(parser_buffer[count])
     ENDFOR
     SELECT INTO  $1
      "c"
      FROM (dummyt d  WITH seq = value(cs_count))
      PLAN (d
       WHERE (code_sets[d.seq] != 0))
      HEAD REPORT
       col 64, table_data->list[kount2].column_name
      DETAIL
       col 101, code_sets[d.seq]"######", row + 1
      WITH nocounter, format = stream, noheading,
       maxcol = 128, maxrow = 1, formfeed = none,
       append
     ;end select
   ENDFOR
 ENDFOR
END GO
