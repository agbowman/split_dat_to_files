CREATE PROGRAM ags_claimdet_prompt_load:dba
 PROMPT
  "TASK_ID        (0.0) = " = 0.0
  WITH dtask_id
 CALL echo("***")
 CALL echo("***   BEGIN AGS_CLAIMDET_PROMPT_LOAD")
 CALL echo("***")
 EXECUTE cclseclogin2
 FREE RECORD request
 RECORD request(
   1 debug_logging = i4
   1 ags_task_id = f8
 )
 SET request->ags_task_id = cnvtint( $DTASK_ID)
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE (t.ags_task_id=request->ags_task_id)
  DETAIL
   request->debug_logging = t.timers_flag
  WITH nocounter
 ;end select
 EXECUTE ags_claimdet_load
 CALL echo("***")
 CALL echo("***   END AGS_CLAIMDET_PROMPT_LOAD")
 CALL echo("***")
 SET script_ver = "000 01/03/07"
END GO
