CREATE PROGRAM dm_ocd_fix_tables_doc_local:dba
 SELECT INTO "nl:"
  FROM user_tab_columns u
  WHERE u.table_name="DM_TABLES_DOC_LOCAL"
   AND u.column_name="FREELIST_CNT"
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL parser("rdb alter table DM_TABLES_DOC_LOCAL")
  CALL parser(" add (FREELIST_CNT NUMBER DEFAULT 1)")
  CALL parser(" go")
  EXECUTE oragen3 "DM_TABLES_DOC_LOCAL"
 ENDIF
END GO
