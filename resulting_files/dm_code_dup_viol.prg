CREATE PROGRAM dm_code_dup_viol
 FREE SET list
 RECORD list(
   1 qual[*]
     2 code_set = f8
     2 cdf_meaning_dup_ind = i4
     2 display_dup_ind = i4
     2 display_key_dup_ind = i4
     2 active_ind_dup_ind = i4
   1 table_count = i4
 )
 SET stat = alterlist(list->qual,10)
 SET list->table_count = 0
 SET counter = 0
 SELECT INTO "nl:"
  cvs.display_key_dup_ind, cvs.display_dup_ind, cvs.cdf_meaning_dup_ind,
  cvs.active_ind_dup_ind, cvs.code_set
  FROM code_value_set cvs
  WHERE cvs.code_set > 0
  DETAIL
   list->table_count = (list->table_count+ 1), stat = alterlist(list->qual,(list->table_count+ 9)),
   list->qual[list->table_count].code_set = cvs.code_set,
   list->qual[list->table_count].display_key_dup_ind = cvs.display_key_dup_ind, list->qual[list->
   table_count].display_dup_ind = cvs.display_dup_ind, list->qual[list->table_count].
   cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind,
   list->qual[list->table_count].active_ind_dup_ind = cvs.active_ind_dup_ind
  WITH nocounter
 ;end select
 DELETE  FROM dm_code_dup_lst
  WHERE 1=1
 ;end delete
 SET parser_buffer[50] = fillstring(132," ")
 SET parser_number = 0
 FOR (counter = 1 TO list->table_count)
   FREE SET code_list
   RECORD code_list(
     1 arr[*]
       2 code_set = f8
       2 cdf_meaning = vc
       2 display = vc
       2 display_key = vc
       2 active_ind = i4
     1 list_count = i4
   )
   SET var = alterlist(code_list->arr,10)
   SET code_list->list_count = 0
   SET parser_buffer[1] = 'select into "nl:" count(*),c.code_set'
   SET parser_number = 1
   IF ((list->qual[counter].display_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = " ,c.display "
   ENDIF
   IF ((list->qual[counter].display_key_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = " , c.display_key "
   ENDIF
   IF ((list->qual[counter].cdf_meaning_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = ", c.cdf_meaning "
   ENDIF
   IF ((list->qual[counter].active_ind_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = " , c.active_ind "
   ENDIF
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "from code_value c "
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "where c.code_set =list->qual[counter]->code_set"
   IF ((list->qual[counter].cdf_meaning_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "and nullind(c.cdf_meaning)= 0"
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = 'and c.cdf_meaning > " "  '
   ENDIF
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "group by c.code_set"
   IF ((list->qual[counter].display_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = " ,c.display "
   ENDIF
   IF ((list->qual[counter].display_key_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = " , c.display_key "
   ENDIF
   IF ((list->qual[counter].cdf_meaning_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = ", c.cdf_meaning "
   ENDIF
   IF ((list->qual[counter].active_ind_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = " , c.active_ind "
   ENDIF
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = " having count (*) > 1 "
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "detail"
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "code_list->list_count = code_list->list_count + 1"
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "var = alterlist(code_list->arr,code_list->list_count + 9)"
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "code_list->arr[code_list->list_count]->code_set = c.code_set"
   IF ((list->qual[counter].display_key_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] =
    "code_list->arr[code_list->list_count]->display_key=c.display_key"
   ENDIF
   IF ((list->qual[counter].display_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "code_list->arr[code_list->list_count]->display=c.display"
   ENDIF
   IF ((list->qual[counter].cdf_meaning_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] =
    "code_list->arr[code_list->list_count]->cdf_meaning=c.cdf_meaning"
   ENDIF
   IF ((list->qual[counter].active_ind_dup_ind=1))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] =
    "code_list->arr[code_list->list_count]->active_ind =c.active_ind"
   ENDIF
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = " with append,format go"
   SET cnt = 0
   FOR (cnt = 1 TO parser_number)
     CALL parser(parser_buffer[cnt],1)
   ENDFOR
   SET cntr = 0
   FOR (cntr = 1 TO code_list->list_count)
     INSERT  FROM dm_code_dup_lst
      (code_set, display, display_key,
      cdf_meaning, active_ind)
      VALUES(code_list->arr[cntr].code_set, code_list->arr[cntr].display, code_list->arr[cntr].
      display_key,
      code_list->arr[cntr].cdf_meaning, code_list->arr[cntr].active_ind)
     ;end insert
   ENDFOR
 ENDFOR
END GO
