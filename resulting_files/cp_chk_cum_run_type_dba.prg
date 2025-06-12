CREATE PROGRAM cp_chk_cum_run_type:dba
 SELECT INTO "nl:"
  c.cdf_meaning
  FROM code_value c
  WHERE c.code_set=14119
   AND c.cdf_meaning="CUMULATIVE"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "cdf_meaning was successfully updated to CUMULATIVE in code_set 14119"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "update prodess of cdf_meaning to CUMULATIVE in code_set 14119 failed"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 SELECT INTO "nl:"
  c.param
  FROM charting_operations c
  WHERE c.param_type_flag=5
   AND c.param="CUM"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "update prodess of param context to CUMULATIVE in charting_operations failed"
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "param context was successfully updated to CUMULATIVE in charting_operations"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
