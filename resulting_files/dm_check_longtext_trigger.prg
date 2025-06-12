CREATE PROGRAM dm_check_longtext_trigger
 SELECT INTO "nl:"
  FROM user_triggers
  WHERE trigger_name="TRG_LONG_TEXT_DELETE"
   AND status="ENABLED"
  WITH counter
 ;end select
 IF (curqual=1)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "LONG_TEXT delete trigger created successfuly!"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Error: LONG_TEXT delete trigger NOT created!"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
