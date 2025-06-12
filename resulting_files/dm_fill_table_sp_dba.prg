CREATE PROGRAM dm_fill_table_sp:dba
 SET dm_table_name = cnvtupper( $1)
 SET dm_schema_date =  $2
 SET parser_buf = build('RDB ASIS(" begin DM_FILL_TABLE_SP(',"'",dm_table_name,"', '",dm_schema_date,
  "',",reqinfo->updt_id,",",reqinfo->updt_task,",",
  reqinfo->updt_applctx,'); end;") go')
 CALL parser(parser_buf,1)
END GO
