CREATE PROGRAM dm_env_files_ship:dba
 SET defs_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   defs_inhouse = 1
  WITH nocounter
 ;end select
 IF (defs_inhouse)
  GO TO exit_script
 ENDIF
 SET defs_cnt = 0
 SET defs_cnt = size(requestin->list_0,5)
 SET defs_u_id = 222
 SET defs_u_task = 333
 IF (defs_cnt > 0)
  INSERT  FROM dm_env_files_ship d,
    (dummyt t  WITH seq = value(defs_cnt))
   SET d.environment_name = requestin->list_0[t.seq].environment_name, d.file_name = requestin->
    list_0[t.seq].file_name, d.disk_name = requestin->list_0[t.seq].disk_name,
    d.file_type = requestin->list_0[t.seq].file_type, d.file_size = cnvtreal(requestin->list_0[t.seq]
     .file_size), d.size_sequence = cnvtint(requestin->list_0[t.seq].size_sequence),
    d.tablespace_name = requestin->list_0[t.seq].tablespace_name, d.updt_applctx = cnvtint(requestin
     ->list_0[t.seq].updt_applctx), d.updt_dt_tm = cnvtdatetime(curdate,0),
    d.updt_cnt = cnvtint(requestin->list_0[t.seq].updt_cnt), d.updt_id = defs_u_id, d.updt_task =
    defs_u_task,
    d.tablespace_exist_ind = cnvtint(requestin->list_0[t.seq].tablespace_exist_ind)
   PLAN (t
    WHERE t.seq > 0)
    JOIN (d)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
#exit_script
END GO
