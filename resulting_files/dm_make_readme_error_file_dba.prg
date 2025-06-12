CREATE PROGRAM dm_make_readme_error_file:dba
 IF ((request->setup_proc[1].process_id > 0))
  SET ro_ind = 0
  SELECT INTO "nl:"
   p.run_once_ind
   FROM dm_pkt_setup_process p
   WHERE (p.process_id=request->setup_proc[1].process_id)
   DETAIL
    ro_ind = p.run_once_ind
   WITH nocounter
  ;end select
  SET request->setup_proc[1].success_ind = 0
  SELECT
   IF (ro_ind=0)
    FROM dm_pkt_setup_proc_log l
    WHERE (l.process_id=request->setup_proc[1].process_id)
     AND (l.environment_id=request->setup_proc[1].env_id)
   ELSEIF (ro_ind=1)
    FROM dm_pkt_setup_proc_hist l
    WHERE (l.process_id=request->setup_proc[1].process_id)
     AND (l.environment_id=request->setup_proc[1].env_id)
   ELSE
   ENDIF
   INTO "nl:"
   l.success_ind
   DETAIL
    request->setup_proc[1].success_ind = l.success_ind
   WITH nocounter
  ;end select
  IF ((request->setup_proc[1].success_ind=0))
   SELECT INTO value(request->setup_proc[1].error_file_name)
    d.seq
    FROM dummyt d
    DETAIL
     row + 1, "'Run after' process either in error or has not been run.", row + 1,
     "Process_id = ", request->setup_proc[1].process_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
END GO
