CREATE PROGRAM dm_add_upt_setup_proc_log:dba
 UPDATE  FROM dm_pkt_setup_proc_log spl
  SET spl.success_ind = request->setup_proc[1].success_ind, spl.error_msg = request->setup_proc[1].
   error_msg, spl.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE (spl.process_id=request->setup_proc[1].process_id)
   AND (spl.environment_id=request->setup_proc[1].env_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_pkt_setup_proc_log spl
   SET spl.process_id = request->setup_proc[1].process_id, spl.environment_id = request->setup_proc[1
    ].env_id, spl.success_ind = request->setup_proc[1].success_ind,
    spl.error_msg = request->setup_proc[1].error_msg, spl.create_dt_tm = cnvtdatetime(curdate,
     curtime3), spl.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
 ENDIF
 UPDATE  FROM dm_pkt_setup_proc_hist sph
  SET sph.success_ind = request->setup_proc[1].success_ind, sph.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), sph.updt_cnt = (sph.updt_cnt+ 1)
  WHERE (sph.process_id=request->setup_proc[1].process_id)
   AND (sph.environment_id=request->setup_proc[1].env_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_pkt_setup_proc_hist sph
   SET sph.process_id = request->setup_proc[1].process_id, sph.environment_id = request->setup_proc[1
    ].env_id, sph.success_ind = request->setup_proc[1].success_ind,
    sph.create_dt_tm = cnvtdatetime(curdate,curtime3), sph.updt_dt_tm = cnvtdatetime(curdate,curtime3
     ), sph.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
