CREATE PROGRAM dm_env_functions_ship:dba
 SET dfs_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   dfs_inhouse = 1
  WITH nocounter
 ;end select
 IF (dfs_inhouse)
  GO TO exit_script
 ENDIF
 DECLARE dfs_cnt = i4
 SET dfs_cnt = size(requestin->list_0,5)
 SET dfs_u_id = 222
 SET dfs_u_task = 333
 IF (dfs_cnt > 0)
  INSERT  FROM dm_env_functions_ship d,
    (dummyt t  WITH seq = value(dfs_cnt))
   SET d.environment_name = requestin->list_0[t.seq].environment_name, d.function_id = cnvtreal(
     requestin->list_0[t.seq].function_id), d.dependency_ind = cnvtint(requestin->list_0[t.seq].
     dependency_ind),
    d.updt_applctx = cnvtint(requestin->list_0[t.seq].updt_applctx), d.updt_dt_tm = cnvtdatetime(
     curdate,0), d.updt_cnt = cnvtint(requestin->list_0[t.seq].updt_cnt),
    d.updt_id = dfs_u_id, d.updt_task = dfs_u_task
   PLAN (t
    WHERE t.seq > 0)
    JOIN (d)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
#exit_script
END GO
