CREATE PROGRAM cp_chk_chart_temp:dba
 SET errormsg = fillstring(255," ")
 SET error_check = error(errormsg,1)
 SELECT INTO "nl:"
  *
  FROM dprotect
  WHERE object_name="CHART_D1"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Failure adding chart_temp"
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Successfully added chart_temp"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
