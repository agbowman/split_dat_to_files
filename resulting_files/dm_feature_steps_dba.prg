CREATE PROGRAM dm_feature_steps:dba
 SET env_name = cnvtupper( $1)
 SET feature_nbr =  $2
 SET proc_cnt = 0
 SET env_id = 0
 SELECT INTO "nl:"
  e.schema_version
  FROM dm_environment e
  WHERE e.environment_name=env_name
  DETAIL
   env_id = e.environment_id
  WITH nocounter
 ;end select
 RECORD rproclist(
   1 qual[*]
     2 process_id = f8
     2 max_instance = i4
 )
 SET plist_cnt = 0
 SELECT INTO "nl:"
  p.process_id
  FROM dm_pkt_setup_process p
  WHERE sqlpassthru(concat("(p.process_id,p.instance_nbr) in ",
    "(select p2.process_id, max(p2.instance_nbr) from dm_pkt_setup_process p2 group by p2.process_id)"
    ))
  DETAIL
   plist_cnt = (plist_cnt+ 1), stat = alterlist(rproclist->qual,plist_cnt), rproclist->qual[plist_cnt
   ].process_id = p.process_id,
   rproclist->qual[plist_cnt].max_instance = p.instance_nbr
  WITH nocounter
 ;end select
 SELECT
  feature = d.effective_feature, environment = env_name, d.process_id,
  d.description, d.run_after_process_id, l.success_ind,
  l.error_msg
  FROM dm_pkt_setup_process d,
   dm_pkt_setup_proc_log l,
   dm_environment e,
   (dummyt dt  WITH seq = 1),
   (dummyt dt2  WITH seq = value(plist_cnt))
  PLAN (dt2)
   JOIN (d
   WHERE (d.process_id=rproclist->qual[dt2.seq].process_id)
    AND (d.instance_nbr=rproclist->qual[dt2.seq].max_instance)
    AND d.effective_feature=feature_nbr
    AND d.active_ind=1
    AND d.from_rev=0)
   JOIN (dt)
   JOIN (l
   WHERE d.process_id=l.process_id)
   JOIN (e
   WHERE e.environment_name=env_name
    AND l.environment_id=e.environment_id)
  ORDER BY d.process_id
  WITH outerjoin = dt
 ;end select
END GO
