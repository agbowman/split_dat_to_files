CREATE PROGRAM aps_chk_diag_query_param_pop:dba
 SET itemcount = 0
 SELECT INTO "nl:"
  itmcntr = count(*)
  FROM ap_diag_query_param adqp
  DETAIL
   itemcount = itmcntr
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  adqp.sequence
  FROM ap_diag_query_param adqp
  PLAN (adqp
   WHERE adqp.query_param_id > 0
    AND adqp.sequence < 1)
  WITH nocounter
 ;end select
 IF (itemcount > 0)
  IF (curqual=0)
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "ap_diag_query_param populate successful"
   CALL echo("******************************************")
   CALL echo("* Successful, curqual > 0, itemcount > 0 *")
   CALL echo("******************************************")
  ELSE
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "ap_diag_query_param populate failed"
   CALL echo("******************************************")
   CALL echo("* Failed, curqual > 0, itemcount > 0     *")
   CALL echo("******************************************")
  ENDIF
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "ap_diag_query_param populate successful"
  CALL echo("******************************************")
  CALL echo("* Successful, NO CURQUAL, itemcount = 0  *")
  CALL echo("******************************************")
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
