CREATE PROGRAM dcp_chk_alt_sel_cat:dba
 SET failures = 0
 SELECT INTO "nl:"
  a.alt_sel_cat_id
  FROM alt_sel_cat a
  WHERE security_flag=2
  DETAIL
   IF (a.owner_id > 0)
    failures = (failures+ 1)
   ENDIF
  WITH check
 ;end select
 SET request->setup_proc[1].process_id = 803
 IF (failures=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Update of owner_id for ALT_SEL_CAT SUCCEEDED"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Update of owner_id for ALT_SEL_CAT FAILED"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
