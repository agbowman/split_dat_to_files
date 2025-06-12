CREATE PROGRAM dm_readme_cki_check:dba
 SELECT INTO "nl:"
  c.*
  FROM user_tab_columns c
  WHERE c.table_name="CODE_VALUE"
   AND c.column_name="CKI"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "CKI column not added to code_value table"
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "CKI column added"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
