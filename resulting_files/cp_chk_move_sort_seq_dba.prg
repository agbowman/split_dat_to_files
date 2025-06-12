CREATE PROGRAM cp_chk_move_sort_seq:dba
 SET nbr_records1 = 0
 SET nbr_records2 = 0
 SELECT DISTINCT INTO "nl:"
  c.charting_operations_id
  FROM charting_operations c
  ORDER BY c.charting_operations_id
  WITH nocounter
 ;end select
 SET nbr_records1 = curqual
 SELECT INTO "nl:"
  c.param
  FROM charting_operations c
  WHERE c.param_type_flag=15
  WITH nocounter
 ;end select
 SET nbr_records2 = curqual
 IF (nbr_records1=nbr_records2)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "sort_seq from chart_distribution table successfully moved to charting_operations table"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "sort_seq move from chart_distribution table to charting_operations table failed"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
