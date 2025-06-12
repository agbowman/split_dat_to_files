CREATE PROGRAM dm_data_for_cert_refresh:dba
 SET trace backdoor p30ins
 CALL parser("rdb asis ('set role dba identified by workishard') go")
 SET parser_buffer = fillstring(300," ")
 SELECT INTO "nl:"
  d.*
  FROM dba_db_links d
  WHERE d.db_link="TEST1*"
  WITH nocounter
 ;end select
 IF (curqual != 1)
  CALL echo(" ")
  CALL echo(" ")
  CALL echo("Error - database link for TEST1 does not exist!")
  CALL echo(" ")
  CALL echo(" ")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.*
  FROM dba_db_links d
  WHERE d.db_link="ADMIN1*"
  WITH nocounter
 ;end select
 IF (curqual != 1)
  CALL echo(" ")
  CALL echo(" ")
  CALL echo("Error - database link for ADMIN1 does not exist!")
  CALL echo(" ")
  CALL echo(" ")
  GO TO exit_script
 ENDIF
 DELETE  FROM dm_table_list
  WHERE 1=1
 ;end delete
 COMMIT
 DELETE  FROM dm_renamed_cols
  WHERE 1=1
 ;end delete
 COMMIT
 DELETE  FROM dm_renamed_tbls
  WHERE 1=1
 ;end delete
 COMMIT
 SET parser_buffer = concat("rdb insert into dm_table_list ","(table_name) ","(select table_name ",
  "from dm_table_list@test1) go")
 CALL parser(parser_buffer)
 IF (curqual < 1)
  CALL echo(" ")
  CALL echo(" ")
  CALL echo("Warning - no rows inserted into dm_table_list!")
  CALL echo(" ")
  CALL echo(" ")
 ENDIF
 COMMIT
 SET parser_buffer = fillstring(300," ")
 SET parser_buffer = concat("rdb insert into dm_renamed_cols ","(table_name,","old_col_name,",
  "new_col_name) ","(select table_name,",
  "old_col_name,","new_col_name ","from dm_renamed_cols@admin1) go")
 CALL parser(parser_buffer)
 IF (curqual < 1)
  CALL echo(" ")
  CALL echo(" ")
  CALL echo("Warning - no rows inserted into dm_renamed_cols!")
  CALL echo(" ")
  CALL echo(" ")
 ENDIF
 COMMIT
 SET parser_buffer = fillstring(300," ")
 SET parser_buffer = concat("rdb insert into dm_renamed_tbls ","(old_table_name,","new_table_name) ",
  "(select old_table_name,","new_table_name ",
  "from dm_renamed_tbls@admin1) go")
 CALL parser(parser_buffer)
 IF (curqual < 1)
  CALL echo(" ")
  CALL echo(" ")
  CALL echo("Warning - no rows inserted into dm_renamed_tbls!")
  CALL echo(" ")
  CALL echo(" ")
 ENDIF
 COMMIT
#exit_script
END GO
