CREATE PROGRAM ags_result_prompt_load:dba
 PROMPT
  "TASK_ID                (0.0) = " = 0,
  "Check For Duplicates (1-Yes) = " = 1
  WITH dtid, bhold
 CALL echo("***")
 CALL echo("***   BEGIN AGS_RESULT_PROMPT_LOAD")
 CALL echo("***")
 EXECUTE cclseclogin2
 FREE RECORD request
 RECORD request(
   1 debug_logging = i4
   1 ags_task_id = f8
   1 check_for_dups = i2
 )
 SET request->ags_task_id = cnvtint( $DTID)
 SET request->check_for_dups = cnvtint( $BHOLD)
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE (t.ags_task_id=request->ags_task_id)
  DETAIL
   request->debug_logging = t.timers_flag
  WITH nocounter
 ;end select
 EXECUTE ags_result_load
 CALL echo("***")
 CALL echo("***   END AGS_RESULT_PROMPT_LOAD")
 CALL echo("***")
 SET script_ver = "000 12/07/06"
END GO
