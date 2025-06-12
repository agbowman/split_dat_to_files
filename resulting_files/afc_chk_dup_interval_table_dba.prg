CREATE PROGRAM afc_chk_dup_interval_table:dba
 SET request->setup_proc[1].success_ind = 0
 SET count = 0
 SET total_dups = 0
 SELECT INTO "nl:"
  i.interval_id, i.interval_template_cd, i.beg_value,
  i.end_value, i.active_ind
  FROM interval_table i
  ORDER BY i.interval_template_cd, i.beg_value, i.end_value,
   i.active_ind
  HEAD i.interval_template_cd
   dummy_var = 0
  HEAD i.beg_value
   dummy_var = 0
  HEAD i.end_value
   dummy_var = 0
  HEAD i.active_ind
   dummy_var = 0, count = 0
  DETAIL
   count = (count+ 1)
   IF (count > 1)
    total_dups = (total_dups+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (total_dups > 0)
  SET request->setup_proc[1].error_msg =
  "Error - afc_del_dup_price_sched_items didn't work. Duplicates found."
  SET request->setup_proc[1].success_ind = 0
 ELSE
  SET request->setup_proc[1].error_msg = "Afc_del_dup_price_sched_items was successful."
  SET request->setup_proc[1].success_ind = 1
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
