CREATE PROGRAM dm_expected_readme_steps:dba
 SET env_name = cnvtupper( $1)
 SET before_after_flag =  $2
 SET proc_cnt = 0
 SET install_ind = 0
 SET env_id = 0
 SET env_from_rev = 0
 SET env_to_rev = 0
 SELECT INTO "nl:"
  e.environment_id
  FROM dm_environment e
  WHERE e.environment_name=env_name
  DETAIL
   IF (e.from_schema_version=0)
    install_ind = 1
   ELSE
    install_ind = 0
   ENDIF
   env_id = e.environment_id, env_from_rev = e.from_schema_version, env_to_rev = e.schema_version
  WITH nocounter
 ;end select
 SELECT
  IF (before_after_flag=1
   AND install_ind=1)
   PLAN (p
    WHERE p.before_install_ind=1)
    JOIN (f
    WHERE f.environment_id=env_id
     AND f.function_id=p.function_id)
  ELSEIF (before_after_flag=1
   AND install_ind=0)
   PLAN (p
    WHERE p.before_refresh_ind=1)
    JOIN (f
    WHERE f.environment_id=env_id
     AND f.function_id=p.function_id)
  ELSEIF (before_after_flag=2
   AND install_ind=1)
   PLAN (p
    WHERE p.after_install_ind=1)
    JOIN (f
    WHERE f.environment_id=env_id
     AND f.function_id=p.function_id)
  ELSEIF (before_after_flag=2
   AND install_ind=0)
   PLAN (p
    WHERE p.after_refresh_ind=1)
    JOIN (f
    WHERE f.environment_id=env_id
     AND f.function_id=p.function_id)
  ELSE
  ENDIF
  INTO "nl:"
  p.process_id
  FROM dm_setup_process p,
   dm_env_functions f
  ORDER BY p.com_file_name, p.run_after_process_id
  DETAIL
   run_ind = 0
   IF (p.from_rev=env_from_rev)
    IF (p.to_rev=env_to_rev)
     run_ind = 1
    ELSEIF (p.to_rev=0
     AND p.effective_rev <= env_to_rev)
     run_ind = 1
    ENDIF
   ELSEIF (p.to_rev=env_to_rev
    AND p.from_rev=0)
    run_ind = 1
   ELSEIF (p.effective_rev <= env_to_rev
    AND p.from_rev=0
    AND p.to_rev=0)
    run_ind = 1
   ELSEIF (p.from_rev=0
    AND p.to_rev=0
    AND p.effective_rev=0)
    run_ind = 1
   ENDIF
   IF (run_ind=1)
    proc_cnt = (proc_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(" ")
 CALL echo(" ")
 CALL echo(" ")
 CALL echo(" ")
 CALL echo(concat("The expected number of steps is: ",cnvtstring(proc_cnt)))
 CALL echo(" ")
 CALL echo(" ")
 CALL echo(" ")
 CALL echo(" ")
END GO
