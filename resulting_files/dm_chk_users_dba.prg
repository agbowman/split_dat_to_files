CREATE PROGRAM dm_chk_users:dba
 SET user_count = 0
 SELECT INTO "nl:"
  b.user_name, b.temporary_tablespace, b.default_tablespace,
  c.priviledge
  FROM dm_env_user b,
   dm_env_user_privledges e,
   dm_env_priviledges c
  WHERE b.user_name=e.user_name
   AND e.priviledge_id=c.priviledge_id
  ORDER BY b.user_name
  DETAIL
   user_count = (user_count+ 1)
  WITH nocounter
 ;end select
 IF (user_count > 0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "User Priviledges updated successfully"
  SET request->setup_proc[1].process_id = 199
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "User Priviledges not updated"
  SET request->setup_proc[1].process_id = 199
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
