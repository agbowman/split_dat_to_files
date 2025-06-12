CREATE PROGRAM dcp_verify_form_flags:dba
 SET count = 0
 SELECT INTO "nl:"
  dfr.flags
  FROM dcp_forms_ref dfr
  WHERE dfr.enforce_required_ind=1
  DETAIL
   IF (dfr.flags=0)
    count = (count+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET request->setup_proc[1].process_id = 699
 IF (count > 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "flag field is not set to all"
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "flags field is set to all"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
