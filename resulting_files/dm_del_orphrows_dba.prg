CREATE PROGRAM dm_del_orphrows:dba
 SET parser_buf[6] = fillstring(132," ")
 SET cntr = 0
 RECORD list(
   1 qual[*]
     2 rid = vc
     2 owner = vc
     2 tablename = vc
     2 constraint = vc
   1 table_count = i4
 )
 SET stat = alterlist(list->qual,10)
 SET list->table_count = 0
 SELECT
  IF (( $1="ALL"))
   WHERE table_name="*"
  ELSE
   WHERE table_name=patstring(cnvtupper( $1))
  ENDIF
  INTO "nl:"
  d.*
  FROM dm_for_key_except d
  DETAIL
   list->table_count = (list->table_count+ 1), stat = alterlist(list->qual,(list->table_count+ 9)),
   list->qual[list->table_count].rid = d.row_id,
   list->qual[list->table_count].owner = d.owner, list->qual[list->table_count].tablename = d
   .table_name, list->qual[list->table_count].constraint = d.constraint
  WITH nocounter
 ;end select
 FOR (cntr = 1 TO list->table_count)
   SET parser_buf[1] = 'RDB ASIS(" begin DM_PURGE_TABLE_ROWID(")'
   SET parser_buf[2] = concat('ASIS("',"'",trim(list->qual[cntr].tablename),"',",'")')
   SET parser_buf[3] = concat('ASIS("',"'",trim(list->qual[cntr].rid),"',0",'")')
   SET parser_buf[4] = 'ASIS("); end ; ")'
   SET parser_buf[5] = " go"
   FOR (cnt = 1 TO 5)
     CALL parser(parser_buf[cnt],1)
   ENDFOR
 ENDFOR
END GO
