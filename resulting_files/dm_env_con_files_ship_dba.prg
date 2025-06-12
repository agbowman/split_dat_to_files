CREATE PROGRAM dm_env_con_files_ship:dba
 SET decfs_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   decfs_inhouse = 1
  WITH nocounter
 ;end select
 IF (decfs_inhouse)
  GO TO exit_script
 ENDIF
 SET decfs_cnt = 0
 SET decfs_cnt = size(requestin->list_0,5)
 SET decfs_u_id = 222
 SET decfs_u_task = 333
 IF (decfs_cnt > 0)
  INSERT  FROM dm_env_con_files_ship d,
    (dummyt t  WITH seq = value(decfs_cnt))
   SET d.environment_name = requestin->list_0[t.seq].environment_name, d.cntl_file_num = cnvtint(
     requestin->list_0[t.seq].cntl_file_num), d.file_name = requestin->list_0[t.seq].file_name,
    d.disk_name = requestin->list_0[t.seq].disk_name, d.updt_applctx = cnvtint(requestin->list_0[t
     .seq].updt_applctx), d.updt_dt_tm = cnvtdatetime(curdate,0),
    d.updt_cnt = cnvtint(requestin->list_0[t.seq].updt_cnt), d.updt_id = cnvtreal(decfs_u_id), d
    .updt_task = cnvtint(decfs_u_task),
    d.file_size = cnvtreal(requestin->list_0[t.seq].file_size)
   PLAN (t
    WHERE t.seq > 0)
    JOIN (d)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
#exit_script
END GO
