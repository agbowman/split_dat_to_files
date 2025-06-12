CREATE PROGRAM dm_display_dup_index:dba
 SET dm_table_name = fillstring(30," ")
 SET dm_index_name = cnvtupper( $1)
 SET dm_schema_date = cnvtdatetime( $2)
 SET dm_col_string = fillstring(500," ")
 FREE DEFINE i_cols
 RECORD i_cols(
   1 index[*]
     2 column_name = c30
 )
 SET col_cnt = 0
 SET stat = alterlist(i_cols->index,10)
 SELECT INTO "nl:"
  a.column_name, a.table_name
  FROM dm_index_columns a
  WHERE a.index_name=dm_index_name
   AND a.schema_date=cnvtdatetime(dm_schema_date)
  ORDER BY a.column_position
  DETAIL
   col_cnt = (col_cnt+ 1)
   IF (mod(col_cnt,10)=1
    AND col_cnt != 1)
    stat = alterlist(i_cols->index,(col_cnt+ 9))
   ENDIF
   i_cols->index[col_cnt].column_name = a.column_name, dm_table_name = a.table_name
  WITH nocounter
 ;end select
 IF (col_cnt > 0)
  FOR (x = 1 TO col_cnt)
   IF (x > 1)
    SET dm_col_string = build(dm_col_string,",")
   ENDIF
   SET dm_col_string = build(dm_col_string,"a.",i_cols->index[x].column_name)
  ENDFOR
  CALL parser(concat("select ",dm_col_string,",count(*) from ",dm_table_name," a group by ",
    dm_col_string," having count(*) > 1 go "),1)
 ELSE
  CALL echo(" ")
  CALL echo("**** Index does not exist in DM_INDEX_COLUMNS ****")
  CALL echo(" ")
 ENDIF
END GO
