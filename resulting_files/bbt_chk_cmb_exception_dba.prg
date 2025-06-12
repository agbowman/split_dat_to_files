CREATE PROGRAM bbt_chk_cmb_exception:dba
 SELECT INTO "nl:"
  dce.script_name
  FROM dm_cmb_exception dce
  PLAN (dce
   WHERE dce.script_name="PERSON_UCB_PERSON_ABORH")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Error updating the BBT records on DM_CMB_EXCEPTION."
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "BBT records on DM_CMB_EXCEPTION has been updated successfully."
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
