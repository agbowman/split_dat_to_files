CREATE PROGRAM cp_chk_chg_order_to_acc_scope:dba
 SELECT INTO "nl:"
  co.param
  FROM charting_operations co
  WHERE co.param_type_flag=1
   AND co.param="3"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "update process of param context to '4' from '3' in charting_operations failed for param_type_flag = 1"
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "param context was successfully updated to '4' from '3' in charting_operations for param_type_flag = 1"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
