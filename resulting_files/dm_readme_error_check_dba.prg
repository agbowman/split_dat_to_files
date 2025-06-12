CREATE PROGRAM dm_readme_error_check:dba
 CASE (request->setup_proc[1].process_id)
  OF 1:
   FREE SET r1
   RECORD r1(
     1 rdate = dq8
   )
   SET r1->rdate = 0
   SET y = 0
   SET z = 0
   SELECT INTO "nl:"
    c.schema_date
    FROM dm_environment b,
     dm_schema_version c
    WHERE (b.environment_id=request->setup_proc[1].env_id)
     AND b.schema_version=c.schema_version
    DETAIL
     r1->rdate = c.schema_date
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM code_value_set
    WHERE code_set > 0
    DETAIL
     y = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM dm_code_value_set c
    WHERE c.code_set > 0
     AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
    GROUP BY c.schema_date
    DETAIL
     z = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    *
    FROM dual
    DETAIL
     IF (y >= z)
      request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
      "Code sets successfully loaded."
     ELSE
      request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
      "Error occurred importing code sets."
     ENDIF
    WITH nocounter
   ;end select
  OF 2:
   FREE SET r1
   RECORD r1(
     1 rdate = dq8
   )
   SET r1->rdate = 0
   SET y = 0
   SET z = 0
   SELECT INTO "nl:"
    c.schema_date
    FROM dm_environment b,
     dm_schema_version c
    WHERE (b.environment_id=request->setup_proc[1].env_id)
     AND b.schema_version=c.schema_version
    DETAIL
     r1->rdate = c.schema_date
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM code_set_extension
    WHERE code_set > 0
    DETAIL
     y = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM dm_code_set_extension c
    WHERE c.code_set > 0
     AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
     AND c.field_type != 0
    GROUP BY c.schema_date
    DETAIL
     z = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    *
    FROM dual
    DETAIL
     IF (y >= z)
      request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
      "Code set extensions successfully loaded."
     ELSE
      request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
      "Error occurred importing code set extensions."
     ENDIF
    WITH nocounter
   ;end select
  OF 3:
   FREE SET r1
   RECORD r1(
     1 rdate = dq8
   )
   SET r1->rdate = 0
   SET y = 0
   SET z = 0
   SELECT INTO "nl:"
    c.schema_date
    FROM dm_environment b,
     dm_schema_version c
    WHERE (b.environment_id=request->setup_proc[1].env_id)
     AND b.schema_version=c.schema_version
    DETAIL
     r1->rdate = c.schema_date
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM common_data_foundation
    WHERE code_set > 0
    DETAIL
     y = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM dm_common_data_foundation c
    WHERE c.code_set > 0
     AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
    GROUP BY c.schema_date
    DETAIL
     z = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    *
    FROM dual
    DETAIL
     IF (y >= z)
      request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
      "Common data foundations successfully loaded."
     ELSE
      request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
      "Error occurred importing common data foundations."
     ENDIF
    WITH nocounter
   ;end select
  OF 4:
   FREE SET r1
   RECORD r1(
     1 rdate = dq8
   )
   SET r1->rdate = 0
   SET y = 0
   SET z = 0
   SELECT INTO "nl:"
    c.schema_date
    FROM dm_environment b,
     dm_schema_version c
    WHERE (b.environment_id=request->setup_proc[1].env_id)
     AND b.schema_version=c.schema_version
    DETAIL
     r1->rdate = c.schema_date
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM code_value
    WHERE code_set > 0
    DETAIL
     y = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM dm_code_value c
    WHERE c.code_set > 0
     AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
    GROUP BY c.schema_date
    DETAIL
     z = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    *
    FROM dual
    DETAIL
     IF (y >= z)
      request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
      "Code value successfully loaded."
     ELSE
      request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
      "Error occurred importing code value."
     ENDIF
    WITH nocounter
   ;end select
  OF 5:
   SELECT INTO "nl:"
    y = count(*)
    FROM dm_cmb_exception
    WHERE child_entity="LONG_TEXT"
     AND operation_type="UNCOMBINE"
    DETAIL
     IF (y=0)
      request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
      "Error in loading dm_cmb_exception.  New rows with child_entity starting with 'SCH' not found."
     ELSE
      request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
      "dm_cmb_exception loaded successfully."
     ENDIF
    WITH nocounter
   ;end select
  OF 6:
  OF 9:
  OF 10:
  OF 11:
  OF 12:
  OF 13:
  OF 14:
  OF 15:
  OF 22:
  OF 23:
  OF 24:
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "No error checking performed."
  OF 21:
   SELECT INTO "nl:"
    y = count(*)
    FROM code_cdf_ext
    WHERE code_set=4
    DETAIL
     IF (y > 0)
      request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
      "code_cdf_ext successfully loaded."
     ELSE
      request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
      "Error occurred importing code_cdf_ext. Code set 4 not found."
     ENDIF
    WITH nocounter
   ;end select
  OF 92:
   SELECT INTO "nl:"
    y = count(*)
    FROM user_objects uo
    WHERE uo.object_type="PROCEDURE"
     AND uo.object_name="DM_ENV_MRG_TBL_TREE"
    DETAIL
     IF (y > 0)
      request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
      "SQL stored procedure dm_env_mrg_tbl_tree included."
     ELSE
      request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
      "SQL stored procedure dm_env_mrg_tbl_tree not included."
     ENDIF
    WITH nocounter
   ;end select
  OF 93:
   SELECT INTO "nl:"
    y = count(*)
    FROM user_objects uo
    WHERE uo.object_type="PROCEDURE"
     AND uo.object_name="DM_ENV_MRG_TABLE"
    DETAIL
     IF (y > 0)
      request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
      "SQL stored procedure dm_env_mrg_table included."
     ELSE
      request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
      "SQL stored procedure dm_env_mrg_table not included."
     ENDIF
    WITH nocounter
   ;end select
  OF 94:
   SELECT INTO "nl:"
    y = count(*)
    FROM user_objects uo
    WHERE uo.object_type="PROCEDURE"
     AND uo.object_name="DM_TREE_LIST"
    DETAIL
     IF (y > 0)
      request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
      "SQL stored procedure dm_tree_list included."
     ELSE
      request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
      "SQL stored procedure dm_tree_list not included."
     ENDIF
    WITH nocounter
   ;end select
  OF 95:
   SELECT INTO "nl:"
    y = count(*)
    FROM dm_parent_child
    DETAIL
     IF (y > 0)
      request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
      "DM_PARENT_CHILD successfully loaded."
     ELSE
      request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
      "Error building DM_PARENT_CHILD"
     ENDIF
    WITH nocounter
   ;end select
  OF 111:
   SELECT INTO "nl:"
    d.username
    FROM dba_users d
    WHERE d.username="V500_REF"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "V500_ref user not created."
   ELSE
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "V500_ref user successfully created."
   ENDIF
  OF 194:
   SELECT INTO "nl:"
    p.search_process_id
    FROM pa_search_process p
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "pa_search_process successfully loaded"
   ELSE
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "pa_search_process not successfully loaded"
   ENDIF
  OF 361:
   SELECT INTO "nl:"
    y = count(*)
    FROM user_objects uo
    WHERE uo.object_type="PROCEDURE"
     AND uo.object_name="DM_PURGE_TABLE_ROWID"
    DETAIL
     IF (y > 0)
      request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
      "SQL stored procedure dm_purge_table_rowid included."
     ELSE
      request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
      "SQL stored procedure dm_purge_table_rowid not included."
     ENDIF
    WITH nocounter
   ;end select
  OF 362:
  OF 363:
  OF 364:
  OF 365:
  OF 366:
  OF 367:
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "No error checking performed."
  OF 424:
   SELECT INTO "nl:"
    s.max_value
    FROM user_sequences s
    WHERE s.max_value=10000000000.00
     AND s.cycle_flag="N"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "No error checking performed."
   ELSE
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "DM_FIX_SEQ_MAXVAL.CCL was not successful."
   ENDIF
  OF 430:
   SELECT INTO "nl:"
    u.table_name
    FROM user_tables u
    WHERE u.table_name="DM_TABLE_LIST"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "DM_TABLE_LIST table not created."
   ELSE
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "DM_TABLE_LIST table created."
   ENDIF
  OF 431:
   SELECT INTO "nl:"
    u.table_name
    FROM user_tables u
    WHERE u.table_name="DM_TABLE_LIST"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "DM_TABLE_LIST table not created."
   ELSE
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "DM_TABLE_LIST table created."
   ENDIF
  OF 432:
   SELECT INTO "nl:"
    u.table_name
    FROM user_tables u
    WHERE u.table_name="DM_TABLE_LIST"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "DM_TABLE_LIST table not created."
   ELSE
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "DM_TABLE_LIST table created."
   ENDIF
  OF 433:
   SELECT INTO "nl:"
    u.table_name
    FROM user_tables u
    WHERE u.table_name="DM_TABLE_LIST"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "DM_TABLE_LIST table not created."
   ELSE
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "DM_TABLE_LIST table created."
   ENDIF
  ELSE
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "No error checking performed."
 ENDCASE
 EXECUTE dm_add_upt_setup_proc_log
END GO
