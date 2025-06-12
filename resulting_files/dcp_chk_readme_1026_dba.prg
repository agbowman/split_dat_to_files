CREATE PROGRAM dcp_chk_readme_1026:dba
 SET cnt = 0
 SELECT INTO "nl:"
  FROM request_processing
  WHERE request_number=3091000
   AND format_script="PFMT_DCP_MED_CHG"
  DETAIL
   cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 SET request->setup_proc[1].process_id = 1026
 SET request->setup_proc[1].success_ind = 1
 SET request->setup_proc[1].error_msg = ""
 IF (cnt=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Request was not setup"
 ELSEIF (cnt > 1)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Request was setup multiple times"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
