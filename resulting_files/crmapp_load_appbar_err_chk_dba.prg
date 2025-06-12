CREATE PROGRAM crmapp_load_appbar_err_chk:dba
 SELECT INTO "nl:"
  a.position_cd
  FROM appbar_security a
  WITH nocounter, maxqual(a,1)
 ;end select
 IF (curqual > 0)
  CALL echo("success!")
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Success - rows exist on the table: appbar_security"
 ELSE
  CALL echo("no rows found on the appbar_security table")
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "no rows found on the appbar_security table!"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
