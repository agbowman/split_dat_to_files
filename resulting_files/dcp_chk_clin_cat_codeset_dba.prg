CREATE PROGRAM dcp_chk_clin_cat_codeset:dba
 SET failures = 0
 SELECT INTO "nl:"
  cvs.display_key_dup_ind
  FROM code_value_set cvs
  WHERE code_set=16389
  DETAIL
   IF (cvs.display_key_dup_ind != 0)
    failures = (failures+ 1)
   ENDIF
  WITH check
 ;end select
 SET request->setup_proc[1].process_id = 795
 IF (failures=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "Update of display_key_dup_ind for clinical category codeset (16389) SUCCEEDED"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "Update of display_key_dup_ind for clinical category codeset (16389) FAILED"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
