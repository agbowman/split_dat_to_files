CREATE PROGRAM afc_chk_dup_price_sched_items:dba
 SET request->setup_proc[1].success_ind = 0
 SET count = 0
 SET total_dups = 0
 SELECT INTO "nl:"
  p.price_sched_items_id, p.price_sched_id, p.bill_item_id,
  p.beg_effective_dt_tm, p.end_effective_dt_tm, p.active_ind
  FROM price_sched_items p
  ORDER BY p.price_sched_id, p.bill_item_id, p.beg_effective_dt_tm,
   p.end_effective_dt_tm, p.active_ind
  HEAD p.price_sched_id
   dummy_var = 0
  HEAD p.bill_item_id
   dummy_var = 0
  HEAD p.beg_effective_dt_tm
   dummy_var = 0
  HEAD p.end_effective_dt_tm
   dummy_var = 0
  HEAD p.active_ind
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
 CALL echo(build(" error_msg is : ",request->setup_proc[1].error_msg))
 CALL echo(build(" success_ind is : ",request->setup_proc[1].success_ind))
 EXECUTE dm_add_upt_setup_proc_log
END GO
