CREATE PROGRAM cs_srv_check_requestclass:dba
 SET request->setup_proc[1].success_ind = 0
 SELECT INTO "nl:"
  r.requestclass
  FROM request r
  WHERE r.request_number=951093
  DETAIL
   IF (r.requestclass=0)
    request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg = "No Errors . . ."
   ELSE
    request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
    "Error - request class of 951093 is not 0"
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("success_ind :",request->setup_proc[1].success_ind))
 CALL echo(build("error_msg   :",request->setup_proc[1].error_msg))
 EXECUTE dm_add_upt_setup_proc_log
END GO
