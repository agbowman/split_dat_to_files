CREATE PROGRAM dcp_readme_error_check:dba
 SELECT INTO "nl:"
  y = count(*)
  FROM dm_cmb_exception
  WHERE script_name="PERSON_CMB_PPA"
  DETAIL
   IF (y=0)
    request->setup_proc[1].success_ind = 0, request->setup_proc[1].error_msg =
    "Unsuccessful import of PowerChart csv data."
   ELSE
    request->setup_proc[1].success_ind = 1, request->setup_proc[1].error_msg =
    "Successful import of PowerChart csv data."
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE dm_add_upt_setup_proc_log
END GO
