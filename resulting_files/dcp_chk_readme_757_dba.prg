CREATE PROGRAM dcp_chk_readme_757:dba
 SET nbr_records = 0
 SET nbr_records1 = 0
 SET code_value = 0
 SELECT INTO "nl:"
  FROM dcp_forms_activity df
  WITH nocounter
 ;end select
 SET request->setup_proc[1].process_id = 757
 SET request->setup_proc[1].success_ind = 1
 SET request->setup_proc[1].error_msg = "Description field successfully updated."
 EXECUTE dm_add_upt_setup_proc_log
END GO
