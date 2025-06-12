CREATE PROGRAM ags_person_prompt_load:dba
 PROMPT
  "TASK_ID        (0.0) = " = 0.0,
  "REQUIRE_SSN (1-Yes) = " = 1,
  "CONSENT_CDF ('YES') = " = "YES"
  WITH dtask_id, lrequire_ssn, sconsent_cdf
 CALL echo("***")
 CALL echo("***   BEGIN AGS_PERSON_PROMPT_LOAD")
 CALL echo("***")
 EXECUTE cclseclogin2
 FREE RECORD request
 RECORD request(
   1 debug_logging = i4
   1 ags_task_id = f8
   1 require_ssn = i4
   1 consent_cdf = vc
 )
 SET request->ags_task_id = cnvtint( $DTASK_ID)
 SET request->require_ssn = cnvtint( $LREQUIRE_SSN)
 SET request->consent_cdf =  $SCONSENT_CDF
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE (t.ags_task_id=request->ags_task_id)
  DETAIL
   request->debug_logging = t.timers_flag
  WITH nocounter
 ;end select
 EXECUTE ags_person_load
 CALL echo("***")
 CALL echo("***   END AGS_PERSON_PROMPT_LOAD")
 CALL echo("***")
 SET script_ver = "000 11/28/06"
END GO
