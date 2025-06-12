CREATE PROGRAM dm_check_nls_triggers:dba
 SET table_count = 0
 SET trigger_count = 0
 SELECT INTO "nl:"
  FROM v$nls_parameters
  WHERE ((parameter="NLS_LANGUAGE"
   AND value != "AMERICAN") OR (parameter="NLS_SORT"
   AND value != "AMERICAN"
   AND value != "BINARY"))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   dc.table_name
   FROM user_tab_columns dc,
    user_tab_columns ut
   WHERE ut.table_name=dc.table_name
    AND ut.column_name=concat(dc.column_name,"_NLS")
   GROUP BY dc.table_name
   DETAIL
    table_count = (table_count+ 1)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   x = count(*)
   FROM user_triggers ut
   WHERE ut.trigger_name="TRG*_NLS"
   DETAIL
    trigger_count = x
   WITH nocounter
  ;end select
  IF (table_count=trigger_count)
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "NLS triggers created successfully"
  ELSE
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "ERROR: NLS triggers NOT created"
  ENDIF
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "Readme step successfull, triggers NOT created ('English' language site)"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
