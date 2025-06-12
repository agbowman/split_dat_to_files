CREATE PROGRAM aps_chk_case_query_details_pop:dba
 SELECT INTO "nl:"
  acqd.sequence
  FROM ap_case_query_details acqd
  PLAN (acqd
   WHERE acqd.query_detail_id IN (0, null)
    AND acqd.param_name > " ")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "ap_case_query_details populate successful"
  CALL echo("******************************************")
  CALL echo("* Successful, curqual > 0, itemcount > 0 *")
  CALL echo("******************************************")
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "ap_case_query_details populate failed"
  CALL echo("******************************************")
  CALL echo("* Failed, curqual > 0, itemcount > 0     *")
  CALL echo("******************************************")
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
