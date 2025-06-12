CREATE PROGRAM dcp_chk_for_prn:dba
 SET counter1 = 0
 SELECT INTO "nl:"
  FROM frequency_schedule fs
  WHERE frequency_type=6
  WITH nocounter
 ;end select
 CALL echo(build("cnt1: ",counter1))
 IF (counter1 != 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Failure updating PRN frequency types"
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Success updating PRN frequency types"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
