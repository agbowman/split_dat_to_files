CREATE PROGRAM dcp_chk_task_disc:dba
 SET nbr_records = 0
 SELECT INTO "nl:"
  t.reference_task_id
  FROM task_discrete_r t
  DETAIL
   nbr_records = (nbr_records+ 1)
  WITH nocounter
 ;end select
 SET request->setup_proc[1].process_id = 185
 IF (nbr_records < 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "task_discrete_r not created correctly."
 ELSE
  SET request->setup_proc[1].success_ind = 1
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
