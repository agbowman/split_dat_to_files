CREATE PROGRAM dm_env_error_check:dba
 SET eid = 0
 SELECT INTO "nl:"
  a.info_number
  FROM dm_info a
  WHERE a.info_domain="DATA MANAGEMENT"
   AND a.info_name="DM_ENV_ID"
  DETAIL
   eid = a.info_number
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "DM_ENV_ID row was not found in the DM_INFO table!"
  GO TO ins_error
 ELSEIF ((eid != request->setup_proc[1].env_id))
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = build("Env_id in dm_info=",eid,". Env_id for the readme=",
   request->setup_proc[1].env_id)
  GO TO ins_error
 ENDIF
 SET di_ename = fillstring(20," ")
 SET de_ename = fillstring(20," ")
 SELECT INTO "nl:"
  a.info_char
  FROM dm_info a
  WHERE a.info_domain="DATA MANAGEMENT"
   AND a.info_name="DM_ENV_NAME"
  DETAIL
   di_ename = trim(a.info_char)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.environment_name
  FROM dm_environment e
  WHERE (e.environment_id=request->setup_proc[1].env_id)
  DETAIL
   de_ename = trim(e.environment_name)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "DM_ENV_NAME row was not found in the DM_INFO table!"
  GO TO ins_error
 ELSEIF (di_ename != de_ename)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat("Env_name in dm_info=",di_ename,
   ". Env_name for the readme=",de_ename)
  GO TO ins_error
 ENDIF
 SET request->setup_proc[1].success_ind = 1
 SET request->setup_proc[1].error_msg =
 "DM_ENV_ID and DM_ENV_NAME rows inserted into DM_INFO successfully!"
#ins_error
 EXECUTE dm_add_upt_setup_proc_log
END GO
