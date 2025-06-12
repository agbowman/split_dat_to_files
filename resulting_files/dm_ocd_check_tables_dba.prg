CREATE PROGRAM dm_ocd_check_tables:dba
 SET reply->status_data.status = "Z"
 SET other_ind = 0
 SET atr_ind = 0
 SET col_cnt = 0
 SET parser_buffer[3] = fillstring(132," ")
 SET stat = initarray(parser_buffer,fillstring(132," "))
 SET parser_buffer[1] = concat("select into 'nl:' u.* from user_tab_columns@",trim( $2)," u")
 SET parser_buffer[2] = " where u.table_name in ('DM_AFD*','DM_ALPHA*','DM_OCD_FEATURES')"
 SET parser_buffer[3] = " detail col_cnt = col_cnt + 1 with nocounter go"
 FOR (dm_cnt = 1 TO 3)
   CALL parser(parser_buffer[dm_cnt])
 ENDFOR
 IF (col_cnt=193)
  SET col_len = 0
  SET parser_buffer[3] = fillstring(132," ")
  SET stat = initarray(parser_buffer,fillstring(132," "))
  SET parser_buffer[1] = concat("select into 'nl:' u.* from user_tab_columns@",trim( $2)," u")
  SET parser_buffer[2] = " where u.table_name='DM_ALPHA_FEATURES_ENV' and u.column_name='STATUS'"
  SET parser_buffer[3] = " detail col_len = u.data_length with nocounter go"
  FOR (dm_cnt = 1 TO 3)
    CALL parser(parser_buffer[dm_cnt])
  ENDFOR
  IF (col_len >= 100)
   SET other_ind = 1
  ENDIF
 ENDIF
 SET col_cnt = 0
 SET parser_buffer[3] = fillstring(132," ")
 SET parser_buffer[1] = concat("select into 'nl:' u.* from user_tab_columns@",trim( $2)," u")
 SET parser_buffer[2] = " where u.table_name in ('DM_OCD_APP*', 'DM_OCD_TASK*', 'DM_OCD_REQUEST')"
 SET parser_buffer[3] = " detail col_cnt = col_cnt + 1 with nocounter go"
 FOR (dm_cnt = 1 TO 3)
   CALL parser(parser_buffer[dm_cnt])
 ENDFOR
 IF (col_cnt=86)
  SET atr_ind = 1
 ENDIF
 IF (other_ind=1
  AND atr_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
