CREATE PROGRAM dm_readmes_not_done:dba
 SET env_name = cnvtupper( $1)
 SET fname = cnvtlower( $2)
 SET before_after_flag =  $3
 RECORD rprocess(
   1 proc[*]
     2 proc_id = f8
     2 success_ind = i4
   1 not_done[*]
     2 proc_id = f8
 )
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
    proc_cnt = (proc_cnt+ 1), stat = alterlist(rprocess->proc,proc_cnt), rprocess->proc[proc_cnt].
    proc_id = p.process_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(proc_cnt)),
   dm_setup_proc_log l,
   (dummyt d2  WITH seq = 1)
  PLAN (d)
   JOIN (d2)
   JOIN (l
   WHERE (rprocess->proc[d.seq].proc_id=l.process_id)
    AND l.environment_id=env_id)
  DETAIL
   rprocess->proc[d.seq].success_ind = l.success_ind
  WITH outerjoin = d2, nocounter
 ;end select
 SELECT INTO value(fname)
  owner_name = p.owner_name, process_id = p.process_id, description = p.description
  FROM (dummyt d  WITH seq = value(proc_cnt)),
   dm_setup_process p
  PLAN (d
   WHERE (rprocess->proc[d.seq].success_ind=0))
   JOIN (p
   WHERE (rprocess->proc[d.seq].proc_id=p.process_id))
  ORDER BY p.owner_name
  WITH nocounter, separator = ","
 ;end select
END GO
