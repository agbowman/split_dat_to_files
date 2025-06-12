CREATE PROGRAM dale_test
 PAINT
#draw_box
 CALL box(2,2,20,78)
 CALL line(6,2,77,xhor)
 CALL text(4,10,"Sequence Check program")
 CALL text(8,10,"Check for sequences that the next value is too low")
 CALL text(10,10,"and give the option to increase the sequence value")
 CALL text(12,10,"Initial check takes around 2 hours depending on db size.")
 CALL text(24,1,"Start check for sequences that are to low? (Y/N)")
 CALL accept(24,60,"P;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  GO TO end_program
 ENDIF
 CALL video(rb)
 CALL clear(24,1)
 CALL text(24,1,"Processing....")
 CALL video(n)
 SET time_var = curtime
 SET time_var2 = cnvtstring(time_var)
 SET one_seq_missing = "F"
 SET one_seq_out_of_seq = "F"
 SET row_count = 0
 SET table_exists = "F"
 SET call_parser_string = fillstring(132," ")
 FREE RECORD requestin
 RECORD requestin(
   1 list[*]
     2 table_name = c100
     2 column_name = c100
     2 max_table_value = f8
     2 sequence_name = c100
     2 cycle_flag = c1
     2 next_sequence_value = f8
     2 sequence_missing = c1
 )
 SELECT INTO "NL:"
  dcd.root_entity_name, dcd.column_name, dcd.sequence_name,
  dcd.table_name
  FROM dm_columns_doc dcd
  WHERE dcd.table_name=dcd.root_entity_name
   AND substring(1,1,dcd.sequence_name) != " "
   AND dcd.sequence_name != ""
   AND dcd.sequence_name IS NOT null
   AND ((dcd.table_name="A*") OR (dcd.table_name="B*"))
  DETAIL
   row_count = (row_count+ 1), stat = alterlist(requestin->list,row_count), requestin->list[row_count
   ].table_name = dcd.table_name,
   requestin->list[row_count].column_name = dcd.column_name, requestin->list[row_count].sequence_name
    = dcd.sequence_name, requestin->list[row_count].max_table_value = 0,
   requestin->list[row_count].next_sequence_value = 0, requestin->list[row_count].cycle_flag = "N",
   requestin->list[row_count].sequence_missing = "T"
  WITH nocounter
 ;end select
 FOR (x = 1 TO row_count)
   SET table_name = requestin->list[x].table_name
   SET column_name = requestin->list[x].column_name
   SET table_exists = "F"
   CALL parser("select into 'NL:'")
   CALL parser("from user_tab_columns utc")
   CALL parser("where utc.table_name = ")
   CALL parser(concat('"',table_name,'"'))
   CALL parser("and utc.column_name = ")
   CALL parser(concat('"',column_name,'"'))
   CALL parser(" detail")
   CALL parser("table_exists = 'T'")
   CALL parser("with nocounter go")
   IF (table_exists="T")
    SET st_sname = cnvtupper(trim(requestin->list[x].sequence_name))
    SELECT
     IF (currdb="ORACLE")
      FROM user_sequences u
     ELSE
      FROM dm2_user_sequences u
     ENDIF
     INTO "nl:"
     u.sequence_name, u.cycle_flag
     WHERE u.sequence_name=st_sname
     DETAIL
      requestin->list[x].cycle_flag = u.cycle_flag
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET one_seq_missing = "T"
    ELSE
     IF ((requestin->list[x].cycle_flag="N"))
      CALL parser("select into 'NL:'")
      CALL parser(concat("t = max(",column_name,")"))
      CALL parser(" from ")
      CALL parser(table_name)
      CALL parser("detail")
      CALL parser("requestin->list[x]->max_table_value = t")
      CALL parser(" with nocounter go")
      SET seq_name = requestin->list[x].sequence_name
      CALL parser("select into 'NL:'")
      CALL parser(concat("nextseq = seq(",seq_name,",nextval)"))
      CALL parser("from dual detail")
      CALL parser("requestin->list[x]->next_sequence_value = nextseq ")
      CALL parser(" with nocounter go")
     ENDIF
    ENDIF
    IF ((requestin->list[x].max_table_value > requestin->list[x].next_sequence_value))
     SET one_seq_out_of_seq = "T"
    ENDIF
   ENDIF
 ENDFOR
 SELECT
  s_test = "test"
  FROM dummyt
  DETAIL
   row_count
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  *
  FROM working_view_person_item
 ;end select
 SELECT INTO "NL:"
  *
  FROM working_view_person_sect
 ;end select
#end_program
END GO
