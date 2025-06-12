CREATE PROGRAM dm_codeset_chk
 FREE SET list
 RECORD list(
   1 qual[*]
     2 code_set = f8
     2 cdf_meaning_dup_ind = i4
     2 display_dup_ind = i4
     2 display_key_dup_ind = i4
     2 active_ind_dup_ind = i4
     2 alias_dup_ind = i4
     2 alias_type_meaning = vc
   1 table_count = i4
 )
 SET stat = alterlist(list->qual,10)
 SET list->table_count = 0
 SET counter = 0
 SELECT INTO "nl:"
  cvs.display_key_dup_ind, cvs.display_dup_ind, cvs.cdf_meaning_dup_ind,
  cvs.active_ind_dup_ind, cvs.code_set, cvs.alias_dup_ind
  FROM code_value_set cvs,
   dm_env_mrg_codeset_list dm
  WHERE cvs.code_set=dm.code_set
  ORDER BY cvs.code_set
  DETAIL
   list->table_count = (list->table_count+ 1), stat = alterlist(list->qual,(list->table_count+ 9)),
   list->qual[list->table_count].code_set = cvs.code_set,
   list->qual[list->table_count].display_key_dup_ind = cvs.display_key_dup_ind, list->qual[list->
   table_count].display_dup_ind = cvs.display_dup_ind, list->qual[list->table_count].
   cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind,
   list->qual[list->table_count].active_ind_dup_ind = cvs.active_ind_dup_ind, list->qual[list->
   table_count].alias_dup_ind = cvs.alias_dup_ind
  WITH nocounter
 ;end select
 SET continue = 1
 FOR (counter = 1 TO list->table_count)
   SET continue = 1
   IF (continue=1)
    IF ((((list->qual[counter].display_dup_ind=0)
     AND (list->qual[counter].display_key_dup_ind=0)
     AND (list->qual[counter].cdf_meaning_dup_ind=0)
     AND (list->qual[counter].alias_dup_ind=0)) OR ((list->qual[counter].alias_dup_ind=1)
     AND (((list->qual[counter].display_dup_ind=1)) OR ((((list->qual[counter].display_key_dup_ind=1)
    ) OR ((((list->qual[counter].cdf_meaning_dup_ind=1)) OR ((list->qual[counter].active_ind_dup_ind=
    1))) )) )) )) )
     UPDATE  FROM dm_env_mrg_codeset_list
      SET invalid_dup_check_ind = 1
      WHERE (code_set=list->qual[counter].code_set)
      WITH nocounter
     ;end update
     COMMIT
     SET continue = 0
    ELSE
     SET continue = 1
    ENDIF
   ENDIF
   IF (continue=1)
    SET par_buffer[10] = fillstring(132," ")
    IF ((list->qual[counter].alias_dup_ind=1))
     SET par_buffer[1] = 'select into "nl:"'
     SET par_buffer[2] = "cva.code_set,cva.contributor_source_cd,cva.alias,count(*)"
     SET par_buffer[3] = "from  code_value_alias cva,code_value_set cvs "
     SET par_buffer[4] =
     "where cvs.code_set = list->qual[counter]->code_set and cva.code_set = cvs.code_set"
     SET par_buffer[5] = "and cva.alias_type_meaning = NULL"
     SET par_buffer[6] = "group by cva.code_set,cva.contributor_source_cd,cva.alias"
     SET par_buffer[7] = "having count (*) > 1"
     SET par_buffer[8] = "go"
     SET count = 0
     FOR (count = 1 TO 8)
       CALL parser(parser_buffer[count],1)
     ENDFOR
     IF (curqual > 0)
      SET abc = curqual
      UPDATE  FROM dm_env_mrg_codeset_list
       SET invalid_data_rows = abc
       WHERE (code_set=list->qual[counter].code_set)
       WITH nocounter
      ;end update
      COMMIT
     ENDIF
     SET continue = 1
    ENDIF
    IF ((((list->qual[counter].cdf_meaning_dup_ind=1)) OR ((((list->qual[counter].display_dup_ind=1))
     OR ((list->qual[counter].display_key_dup_ind=1))) )) )
     SET parser_buff[50] = fillstring(132," ")
     SET parser_num = 0
     SET parser_buff[1] = 'select into "nl:"'
     SET parser_num = 1
     SET var = 0
     IF ((list->qual[counter].display_dup_ind=1))
      SET parser_num = (parser_num+ 1)
      SET parser_buff[parser_num] = " c.display  "
      SET var = 1
     ENDIF
     IF ((list->qual[counter].display_key_dup_ind=1))
      SET parser_num = (parser_num+ 1)
      IF (var=1)
       SET parser_buff[parser_num] = " , c.display_key  "
      ENDIF
      IF (var=0)
       SET parser_buff[parser_num] = " c.display_key  "
       SET var = 1
      ENDIF
     ENDIF
     IF ((list->qual[counter].cdf_meaning_dup_ind=1))
      SET parser_num = (parser_num+ 1)
      IF (var=0)
       SET parser_buff[parser_num] = "c.cdf_meaning  "
      ENDIF
      IF (var=1)
       SET parser_buff[parser_num] = ", c.cdf_meaning  "
      ENDIF
     ENDIF
     SET parser_num = (parser_num+ 1)
     SET parser_buff[parser_num] = "from code_value c "
     SET varcount = 0
     SET parser_num = (parser_num+ 1)
     SET parser_buff[parser_num] = "where c.code_set =list->qual[counter]->code_set and ("
     IF ((list->qual[counter].cdf_meaning_dup_ind=1))
      SET parser_num = (parser_num+ 1)
      SET parser_buff[parser_num] = '(c.cdf_meaning = " " or nullind(c.cdf_meaning) = 1)'
      SET varcount = 1
     ENDIF
     IF ((list->qual[counter].display_dup_ind=1))
      SET parser_num = (parser_num+ 1)
      IF (varcount=1)
       SET parser_buff[parser_num] = 'or (c.display = " " or nullind(c.display)= 1)'
       SET varcount = 1
      ENDIF
      IF (varcount=0)
       SET parser_buff[parser_num] = '(c.display = " " or nullind(c.display) = 1)'
       SET varcount = 1
      ENDIF
     ENDIF
     IF ((list->qual[counter].display_key_dup_ind=1))
      SET parser_num = (parser_num+ 1)
      IF (varcount=0)
       SET parser_buff[parser_num] = '(c.display_key = " " or nullind(c.display_key) = 1)'
      ENDIF
      IF (varcount=1)
       SET parser_buff[parser_num] = 'or (c.display_key = " " or nullind(c.display_key) = 1)'
      ENDIF
     ENDIF
     SET parser_num = (parser_num+ 1)
     SET parser_buff[parser_num] = ")"
     SET parser_num = (parser_num+ 1)
     SET parser_buff[parser_num] = "go"
     SET cntr = 0
     FOR (cntr = 1 TO parser_num)
       CALL parser(parser_buff[cntr],1)
     ENDFOR
     IF (curqual > 0)
      SET xyz = curqual
      UPDATE  FROM dm_env_mrg_codeset_list
       SET invalid_data_rows = xyz
       WHERE (code_set=list->qual[counter].code_set)
       WITH nocounter
      ;end update
      COMMIT
     ENDIF
     SET continue = 1
    ENDIF
    IF ((((list->qual[counter].cdf_meaning_dup_ind=1)) OR ((((list->qual[counter].display_dup_ind=1))
     OR ((list->qual[counter].display_key_dup_ind=1))) )) )
     SET parser_buffer[50] = fillstring(132," ")
     SET parser_number = 0
     SET parser_buffer[1] = 'select into "nl:" count(*)'
     SET parser_number = 1
     IF ((list->qual[counter].display_dup_ind=1))
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = " ,c.display  "
     ENDIF
     IF ((list->qual[counter].display_key_dup_ind=1))
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = " , c.display_key  "
     ENDIF
     IF ((list->qual[counter].cdf_meaning_dup_ind=1))
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = ", c.cdf_meaning  "
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
     SET num = 0
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "group by "
     IF ((list->qual[counter].display_dup_ind=1))
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = " c.display "
      SET num = 1
     ENDIF
     IF ((list->qual[counter].display_key_dup_ind=1))
      SET parser_number = (parser_number+ 1)
      IF (num=1)
       SET parser_buffer[parser_number] = " , c.display_key "
      ENDIF
      IF (num=0)
       SET parser_buffer[parser_number] = " c.display_key  "
       SET num = 1
      ENDIF
     ENDIF
     IF ((list->qual[counter].cdf_meaning_dup_ind=1))
      SET parser_number = (parser_number+ 1)
      IF (num=1)
       SET parser_buffer[parser_number] = ", c.cdf_meaning "
      ENDIF
      IF (num=0)
       SET parser_buffer[parser_number] = "c.cdf_meaning  "
       SET num = 1
      ENDIF
     ENDIF
     IF ((list->qual[counter].active_ind_dup_ind=1))
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = " , c.active_ind "
     ENDIF
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = " having count (*) > 1 "
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = "go "
     SET cnt = 0
     FOR (cnt = 1 TO parser_number)
       CALL parser(parser_buffer[cnt],1)
     ENDFOR
     IF (curqual > 0)
      SET efg = curqual
      UPDATE  FROM dm_env_mrg_codeset_list
       SET duplicate_rows = efg
       WHERE (code_set=list->qual[counter].code_set)
       WITH nocounter
      ;end update
      COMMIT
     ENDIF
     SET continue = 1
    ENDIF
   ENDIF
 ENDFOR
END GO
