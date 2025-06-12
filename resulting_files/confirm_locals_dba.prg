CREATE PROGRAM confirm_locals:dba
 SELECT INTO "NL:"
  dt.table_name
  FROM dm_tables_doc_local dt,
   dm_columns_doc_local dc
  WHERE dt.table_name="CODE_VALUE"
   AND dt.table_name=dc.table_name
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("DM_TABLES_DOC_LOCAL AND DM_COLUMNS_DOC_LOCAL CREATED SUCCESSFULLY.")
 ELSE
  CALL echo("ERROR! TABLES NOT POPULATED CORRECTLY!")
 ENDIF
END GO
