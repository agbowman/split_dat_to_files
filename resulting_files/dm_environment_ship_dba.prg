CREATE PROGRAM dm_environment_ship:dba
 SET des_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   des_inhouse = 1
  WITH nocounter
 ;end select
 IF (des_inhouse)
  GO TO exit_script
 ENDIF
 DECLARE des_cnt = i4
 SET des_cnt = size(requestin->list_0,5)
 SET des_u_id = 222
 SET des_u_task = 333
 IF (des_cnt > 0)
  DELETE  FROM dm_environment_ship a,
    (dummyt d  WITH seq = value(des_cnt))
   SET a.seq = 1
   PLAN (d)
    JOIN (a
    WHERE (a.environment_name=requestin->list_0[d.seq].environment_name))
   WITH nocounter
  ;end delete
  COMMIT
  DELETE  FROM dm_afe_ship a,
    (dummyt d  WITH seq = value(des_cnt))
   SET a.seq = 1
   PLAN (d)
    JOIN (a
    WHERE (a.environment_name=requestin->list_0[d.seq].environment_name))
   WITH nocounter
  ;end delete
  COMMIT
  DELETE  FROM dm_env_con_files_ship a,
    (dummyt d  WITH seq = value(des_cnt))
   SET a.seq = 1
   PLAN (d)
    JOIN (a
    WHERE (a.environment_name=requestin->list_0[d.seq].environment_name))
   WITH nocounter
  ;end delete
  COMMIT
  DELETE  FROM dm_env_files_ship a,
    (dummyt d  WITH seq = value(des_cnt))
   SET a.seq = 1
   PLAN (d)
    JOIN (a
    WHERE (a.environment_name=requestin->list_0[d.seq].environment_name))
   WITH nocounter
  ;end delete
  COMMIT
  DELETE  FROM dm_env_functions_ship a,
    (dummyt d  WITH seq = value(des_cnt))
   SET a.seq = 1
   PLAN (d)
    JOIN (a
    WHERE (a.environment_name=requestin->list_0[d.seq].environment_name))
   WITH nocounter
  ;end delete
  COMMIT
  DELETE  FROM dm_env_redo_logs_ship a,
    (dummyt d  WITH seq = value(des_cnt))
   SET a.seq = 1
   PLAN (d)
    JOIN (a
    WHERE (a.environment_name=requestin->list_0[d.seq].environment_name))
   WITH nocounter
  ;end delete
  COMMIT
  DELETE  FROM dm_env_roll_segs_ship a,
    (dummyt d  WITH seq = value(des_cnt))
   SET a.seq = 1
   PLAN (d)
    JOIN (a
    WHERE (a.environment_name=requestin->list_0[d.seq].environment_name))
   WITH nocounter
  ;end delete
  COMMIT
  INSERT  FROM dm_environment_ship d,
    (dummyt t  WITH seq = value(des_cnt))
   SET d.environment_name = requestin->list_0[t.seq].environment_name, d.description = requestin->
    list_0[t.seq].description, d.database_name = requestin->list_0[t.seq].database_name,
    d.total_database_size = cnvtreal(requestin->list_0[t.seq].total_database_size), d
    .target_operating_system = requestin->list_0[t.seq].target_operating_system, d.database_disk =
    requestin->list_0[t.seq].database_disk,
    d.database_archive_disk = requestin->list_0[t.seq].database_archive_disk, d
    .data_file_partition_size = cnvtreal(requestin->list_0[t.seq].data_file_partition_size), d
    .admin_dbase_link_name = requestin->list_0[t.seq].admin_dbase_link_name,
    d.schema_version = cnvtreal(requestin->list_0[t.seq].schema_version), d.from_schema_version =
    cnvtreal(requestin->list_0[t.seq].from_schema_version), d.control_file_count = cnvtint(requestin
     ->list_0[t.seq].control_file_count),
    d.redo_log_groups = cnvtint(requestin->list_0[t.seq].redo_log_groups), d.redo_log_members =
    cnvtint(requestin->list_0[t.seq].redo_log_members), d.db_version = cnvtint(requestin->list_0[t
     .seq].db_version),
    d.version_id = cnvtreal(requestin->list_0[t.seq].version_id), d.temporary_tspace_disk = requestin
    ->list_0[t.seq].temporary_tspace_disk, d.system_tspace_disk = requestin->list_0[t.seq].
    system_tspace_disk,
    d.root_dir_name = requestin->list_0[t.seq].root_dir_name, d.volume_group = requestin->list_0[t
    .seq].volume_group, d.v500_connect_string = requestin->list_0[t.seq].v500_connect_string,
    d.v500ref_connect_string = requestin->list_0[t.seq].v500ref_connect_string, d.updt_applctx =
    cnvtint(requestin->list_0[t.seq].updt_applctx), d.updt_dt_tm = cnvtdatetime(curdate,0),
    d.updt_cnt = cnvtint(requestin->list_0[t.seq].updt_cnt), d.updt_id = des_u_id, d.updt_task =
    des_u_task,
    d.month_cnt = cnvtreal(requestin->list_0[t.seq].month_cnt), d.cerner_fs_mtpt = requestin->list_0[
    t.seq].cerner_fs_mtpt, d.ora_pri_fs_mtpt = requestin->list_0[t.seq].ora_pri_fs_mtpt,
    d.ora_sec_fs_mtpt = requestin->list_0[t.seq].ora_sec_fs_mtpt, d.oracle_version = requestin->
    list_0[t.seq].oracle_version, d.max_file_size = cnvtreal(requestin->list_0[t.seq].max_file_size),
    d.envset_string = requestin->list_0[t.seq].envset_string
   PLAN (t
    WHERE t.seq > 0)
    JOIN (d)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
#exit_script
END GO
