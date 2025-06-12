CREATE PROGRAM dm_find_bad_seq:dba
 RECORD columns(
   1 qual[*]
     2 table_name = c30
     2 column_name = c30
     2 sequence_name = c30
     2 max_table_nbr = i4
     2 last_seq_nbr = i4
     2 seq_in_error_ind = i2
   1 qual_cnt = i4
 )
 SET cnt = 0
 SELECT INTO "NL:"
  a.column_name, a.sequence_name
  FROM dm_columns_doc a,
   dm_user_tab_cols b,
   dm_user_constraints c,
   dm_user_cons_columns d
  WHERE a.table_name=b.table_name
   AND a.column_name=b.column_name
   AND a.column_name="*_ID"
   AND trim(a.sequence_name) != null
   AND a.table_name=c.table_name
   AND c.constraint_type="P"
   AND c.constraint_name=d.constraint_name
   AND a.column_name=d.column_name
   AND a.table_name=d.table_name
   AND d.position=1
  ORDER BY a.table_name
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(columns->qual,cnt), columns->qual[cnt].column_name = a
   .column_name,
   columns->qual[cnt].table_name = a.table_name, columns->qual[cnt].sequence_name = a.sequence_name
  WITH nocounter
 ;end select
 SET columns->qual_cnt = cnt
 CALL echo(cnvtstring(cnt))
 SET tempstr = fillstring(255," ")
 SET tempstr2 = fillstring(255," ")
 SET tempstr3 = fillstring(255," ")
 SET tempstr4 = fillstring(255," ")
 SET x = 0
 SET trace symbol mark
 FOR (x = 1 TO columns->qual_cnt)
   SET max_seq = 0
   SET tempstr = build("SELECT INTO 'NL:' Y = MAX(",columns->qual[x].column_name,") ")
   SET tempstr2 = concat(" FROM ",columns->qual[x].table_name)
   SET tempstr3 = " DETAIL MAX_SEQ= Y"
   SET tempstr4 = " WITH NOCOUNTER GO"
   CALL parser(tempstr)
   CALL parser(tempstr2)
   CALL parser(tempstr3)
   CALL parser(tempstr4)
   SET columns->qual[x].max_table_nbr = max_seq
   SET last_nbr = 0
   SET tempstr = "SELECT INTO 'NL:' A.LAST_NUMBER FROM USER_SEQUENCES A WHERE "
   SET tempstr2 = concat(" A.SEQUENCE_NAME = '",columns->qual[x].sequence_name,"'")
   SET tempstr3 = " DETAIL LAST_NBR = A.LAST_NUMBER"
   SET tempstr4 = " WITH NOCOUNTER GO"
   CALL parser(tempstr)
   CALL parser(tempstr2)
   CALL parser(tempstr3)
   CALL parser(tempstr4)
   SET columns->qual[x].last_seq_nbr = last_nbr
   IF ((columns->qual[x].max_table_nbr > columns->qual[x].last_seq_nbr))
    SET columns->qual[x].seq_in_error_ind = 1
   ELSE
    SET columns->qual[x].seq_in_error_ind = 0
   ENDIF
   SET trace = symbol
 ENDFOR
 CALL echo("THE FOLLOWING SEQUENCES ARE IN ERROR")
 FOR (x = 1 TO columns->qual_cnt)
   IF ((columns->qual[x].seq_in_error_ind=1))
    CALL echo(columns->qual[x].sequence_name)
   ENDIF
 ENDFOR
END GO
