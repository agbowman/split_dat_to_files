CREATE PROGRAM dm_cert_readmes_not_done:dba
 SET env_name = cnvtupper( $1)
 SET fname = cnvtlower( $2)
 RECORD rprocess(
   1 proc[*]
     2 proc_id = f8
     2 success_ind = i2
     2 instance_nbr = i4
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
  FROM dm_pkt_setup_process p
  WHERE p.active_ind=1
   AND p.from_rev=0
   AND sqlpassthru(concat("(p.process_id, p.instance_nbr) in ",
    "(select p2.process_id, max(p2.instance_nbr) ","from dm_pkt_setup_process p2 ",
    "group by p2.process_id)"))
  DETAIL
   proc_cnt = (proc_cnt+ 1), stat = alterlist(rprocess->proc,proc_cnt), rprocess->proc[proc_cnt].
   proc_id = p.process_id,
   rprocess->proc[proc_cnt].success_ind = 2, rprocess->proc[proc_cnt].instance_nbr = p.instance_nbr
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(proc_cnt)),
   dm_pkt_setup_proc_log l
  PLAN (d)
   JOIN (l
   WHERE (rprocess->proc[d.seq].proc_id=l.process_id)
    AND l.environment_id=env_id
    AND l.success_ind=1)
  DETAIL
   rprocess->proc[d.seq].success_ind = l.success_ind
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(proc_cnt)),
   dm_pkt_setup_proc_log l
  PLAN (d)
   JOIN (l
   WHERE (rprocess->proc[d.seq].proc_id=l.process_id)
    AND l.environment_id=env_id
    AND l.success_ind=0)
  DETAIL
   rprocess->proc[d.seq].success_ind = l.success_ind
  WITH nocounter
 ;end select
 SELECT INTO value(fname)
  owner_id = p.owner_email, process_id = p.process_id, feature = p.effective_feature,
  environment = env_name, success_ind = rprocess->proc[d.seq].success_ind, description = p
  .description
  FROM (dummyt d  WITH seq = value(proc_cnt)),
   dm_pkt_setup_process p
  PLAN (d
   WHERE (rprocess->proc[d.seq].success_ind IN (0, 2)))
   JOIN (p
   WHERE (rprocess->proc[d.seq].proc_id=p.process_id)
    AND (rprocess->proc[d.seq].instance_nbr=p.instance_nbr))
  ORDER BY p.owner_email, success_ind
  WITH nocounter, separator = ","
 ;end select
END GO
