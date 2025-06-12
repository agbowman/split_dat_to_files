CREATE PROGRAM app_import_error_check:dba
 SELECT INTO "nl:"
  a.application_number
  FROM application a
  WHERE a.updt_dt_tm >= cnvtdatetime(curdate,0)
  WITH nocounter, maxqual(a,1)
 ;end select
 IF (curqual > 0)
  CALL echo("success!")
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Success - Application exist on the table: application"
 ELSE
  CALL echo("no rows found on the application table")
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "no applications on the application table where updated!"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
