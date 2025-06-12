CREATE PROGRAM dm_env_redo_logs_ship:dba
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
 DECLARE der_cnt = i4
 SET der_cnt = size(requestin->list_0,5)
 SET der_u_id = 222
 SET der_u_task = 333
 IF (der_cnt > 0)
  INSERT  FROM dm_env_redo_logs_ship d,
    (dummyt t  WITH seq = value(der_cnt))
   SET d.environment_name = requestin->list_0[t.seq].environment_name, d.group_number = cnvtint(
     requestin->list_0[t.seq].group_number), d.member_number = cnvtint(requestin->list_0[t.seq].
     member_number),
    d.file_name = requestin->list_0[t.seq].file_name, d.disk_name = requestin->list_0[t.seq].
    disk_name, d.log_size = cnvtreal(requestin->list_0[t.seq].log_size),
    d.updt_applctx = cnvtint(requestin->list_0[t.seq].updt_applctx), d.updt_dt_tm = cnvtdatetime(
     curdate,0), d.updt_cnt = cnvtint(requestin->list_0[t.seq].updt_cnt),
    d.updt_id = der_u_id, d.updt_task = der_u_task
   PLAN (t
    WHERE t.seq > 0)
    JOIN (d)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
#exit_script
END GO
