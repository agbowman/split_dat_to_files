CREATE PROGRAM dm_ref_table_check:dba
 SELECT INTO "nl:"
  a.*
  FROM user_tables a
  WHERE table_name="DM_REF_DOMAIN*"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 1
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "DM Reference Domain Tables not dropped"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
