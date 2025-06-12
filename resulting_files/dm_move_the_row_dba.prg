CREATE PROGRAM dm_move_the_row:dba
 FOR (i = 1 TO select_parser_count)
   CALL parser(select_parser_buffer[i],1)
 ENDFOR
 FOR (i = 1 TO insert_parser_count)
   CALL parser(insert_parser_buffer[i],1)
 ENDFOR
END GO
