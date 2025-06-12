CREATE PROGRAM dm_add_cki_cv:dba
 SELECT INTO "nl:"
  u.*
  FROM user_tab_columns u
  WHERE u.table_name="CODE_VALUE"
   AND u.column_name="CKI"
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL parser("rdb alter table code_value add (cki varchar(255) ) go",1)
  COMMIT
  EXECUTE oragen3 "CODE_VALUE"
 ENDIF
END GO
