CREATE PROGRAM cp_chk_chart_temp2:dba
 SET errormsg = fillstring(255," ")
 SET error_check = error(errormsg,1)
 SELECT INTO "nl:"
  *
  FROM user_tables ut
  WHERE ut.table_name="CHART_TEMP2"
 ;end select
 IF (curqual=0)
  CALL echo("failed")
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Failure adding chart_temp2"
 ELSE
  CALL echo("success")
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Successfully added chart_temp2"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
