CREATE PROGRAM dm_purge_invalid_cd_keys:dba
 FREE SET tbl_col
 RECORD tbl_col(
   1 num = i4
   1 list[*]
     2 table_name = c30
     2 column_name = c30
 )
 SET tbl_col->num = 0
 FREE SET data
 RECORD data(
   1 num = i4
   1 list[*]
     2 row_id = c18
 )
 SET data->num = 0
 SELECT
  IF (cnvtupper( $1)="ALL")
   WHERE d.table_name="*"
  ELSE
   WHERE d.table_name=patstring(cnvtupper( $1))
  ENDIF
  DISTINCT INTO "nl:"
  d.table_name, d.column_name
  FROM dm_invalid_code_value d
  ORDER BY d.table_name, d.column_name
  DETAIL
   tbl_col->num = (tbl_col->num+ 1)
   IF (mod(tbl_col->num,10)=1)
    stat = alterlist(tbl_col->list,(tbl_col->num+ 9))
   ENDIF
   tbl_col->list[tbl_col->num].table_name = d.table_name, tbl_col->list[tbl_col->num].column_name = d
   .column_name
  WITH nocounter
 ;end select
 FOR (cnt = 1 TO tbl_col->num)
   FREE SET parser_buffer
   SET parser_buffer[100] = fillstring(132," ")
   SET cv_count = 0
   SELECT INTO "nl:"
    "x"
    FROM user_indexes ui,
     user_ind_columns uic
    WHERE ui.table_owner="V500"
     AND (ui.table_name=tbl_col->list[cnt].table_name)
     AND ui.uniqueness="UNIQUE"
     AND (uic.table_name=tbl_col->list[cnt].table_name)
     AND (uic.column_name=tbl_col->list[cnt].column_name)
    WITH nocounter
   ;end select
   IF (curqual=1)
    SELECT INTO "nl:"
     d.column_name
     FROM dm_invalid_code_value d
     WHERE (d.table_name=tbl_col->list[cnt].table_name)
      AND (d.column_name=tbl_col->list[cnt].column_name)
     DETAIL
      data->num = (data->num+ 1)
      IF (mod(data->num,10)=1)
       stat = alterlist(data->list,(data->num+ 9))
      ENDIF
      data->list[data->num].row_id = d.row_id
     WITH nocounter
    ;end select
    FREE SET parser_buffer
    SET parser_buffer[10] = fillstring(132," ")
    FOR (kount = 1 TO data->num)
      SET parser_buf[1] = 'RDB ASIS(" begin DM_PURGE_TABLE_ROWID(")'
      SET parser_buf[2] = concat('ASIS("',"'",trim(tbl_col->list[cnt].table_name),"',",'")')
      SET parser_buf[3] = concat('ASIS("',"'",trim(data->list[kount].row_id),"',0",'")')
      SET parser_buf[4] = 'ASIS("); end ; ")'
      SET parser_buf[5] = " go"
      FOR (cnt2 = 1 TO 5)
        CALL parser(parser_buf[cnt2],1)
      ENDFOR
      COMMIT
    ENDFOR
   ENDIF
 ENDFOR
END GO
