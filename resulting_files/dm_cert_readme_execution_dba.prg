CREATE PROGRAM dm_cert_readme_execution:dba
 SET env_name = cnvtupper( $1)
 SET fname = cnvtlower( $2)
 RECORD rprocess(
   1 proc[*]
     2 proc_id = f8
     2 success_ind = i2
     2 last_execution_dt_tm = dq8
 )
 SET proc_cnt = 0
 SET env_id = 0
 SELECT INTO "nl:"
  e.environment_id
  FROM dm_environment e
  WHERE e.environment_name=env_name
  DETAIL
   env_id = e.environment_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.process_id
  FROM dm_pkt_setup_process p
  WHERE p.active_ind=1
   AND p.from_rev=0
  DETAIL
   proc_cnt = (proc_cnt+ 1), stat = alterlist(rprocess->proc,proc_cnt), rprocess->proc[proc_cnt].
   proc_id = p.process_id,
   rprocess->proc[proc_cnt].success_ind = 2
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(proc_cnt)),
   dm_pkt_setup_proc_log l
  PLAN (d)
   JOIN (l
   WHERE (rprocess->proc[d.seq].proc_id=l.process_id)
    AND l.environment_id=env_id)
  DETAIL
   rprocess->proc[d.seq].success_ind = l.success_ind, rprocess->proc[d.seq].last_execution_dt_tm = l
   .updt_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO value(fname)
  d.seq
  FROM (dummyt d  WITH seq = value(proc_cnt)),
   dm_pkt_setup_process p
  PLAN (d)
   JOIN (p
   WHERE (rprocess->proc[d.seq].proc_id=p.process_id))
  ORDER BY p.owner_email
  HEAD REPORT
   col 1, "owner_id,process_id,feature,environment,success,last_execution_dt_tm"
  DETAIL
   txt = build(p.owner_email,",",p.process_id,",",p.effective_feature,
    ",",env_name,",",rprocess->proc[d.seq].success_ind,",",
    format(rprocess->proc[d.seq].last_execution_dt_tm,"dd-mmm hh:mm;;d")), row + 1, col 1,
   txt
  WITH nocounter, separator = ",", maxcol = 250
 ;end select
END GO
