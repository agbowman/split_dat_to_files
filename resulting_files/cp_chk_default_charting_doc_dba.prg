CREATE PROGRAM cp_chk_default_charting_doc:dba
 SELECT INTO "nl:"
  p.username
  FROM prsnl p
  WHERE p.username="CHARTING"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Failure adding default charting provider"
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Default charting provider added successfully"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
