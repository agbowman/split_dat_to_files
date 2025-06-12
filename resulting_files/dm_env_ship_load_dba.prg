CREATE PROGRAM dm_env_ship_load:dba
 SET env_name = fillstring(20," ")
 SELECT INTO "nl:"
  dm.environment_name
  FROM dm_environment dm
  WHERE (dm.environment_id= $1)
  DETAIL
   env_name = dm.environment_name
  WITH nocounter
 ;end select
 DELETE  FROM dm_environment_ship de
  WHERE trim(de.environment_name)=trim(env_name)
  WITH nocounter
 ;end delete
 INSERT  FROM dm_environment_ship
  (environment_name, description, database_name,
  total_database_size, target_operating_system, database_disk,
  database_archive_disk, data_file_partition_size, admin_dbase_link_name,
  schema_version, from_schema_version, control_file_count,
  redo_log_groups, redo_log_members, db_version,
  version_id, temporary_tspace_disk, system_tspace_disk,
  root_dir_name, volume_group, v500_connect_string,
  v500ref_connect_string, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task,
  month_cnt, cerner_fs_mtpt, ora_pri_fs_mtpt,
  ora_sec_fs_mtpt, oracle_version, max_file_size,
  envset_string)(SELECT
   env_name, dm.description, dm.database_name,
   dm.total_database_size, dm.target_operating_system, dm.database_disk,
   dm.database_archive_disk, dm.data_file_partition_size, dm.admin_dbase_link_name,
   dm.schema_version, dm.from_schema_version, dm.control_file_count,
   dm.redo_log_groups, dm.redo_log_members, dm.db_version,
   dm.version_id, dm.temporary_tspace_disk, dm.system_tspace_disk,
   dm.root_dir_name, dm.volume_group, dm.v500_connect_string,
   dm.v500ref_connect_string, dm.updt_applctx, dm.updt_dt_tm,
   dm.updt_cnt, dm.updt_id, dm.updt_task,
   dm.month_cnt, dm.cerner_fs_mtpt, dm.ora_pri_fs_mtpt,
   dm.ora_sec_fs_mtpt, dm.oracle_version, dm.max_file_size,
   dm.envset_string
   FROM dm_environment dm
   WHERE (dm.environment_id= $1))
 ;end insert
 COMMIT
 DELETE  FROM dm_env_con_files_ship de
  WHERE trim(de.environment_name)=trim(env_name)
  WITH nocounter
 ;end delete
 INSERT  FROM dm_env_con_files_ship
  (environment_name, cntl_file_num, file_name,
  disk_name, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task,
  file_size)(SELECT
   env_name, dm.cntl_file_num, dm.file_name,
   dm.disk_name, dm.updt_applctx, dm.updt_dt_tm,
   dm.updt_cnt, dm.updt_id, dm.updt_task,
   dm.file_size
   FROM dm_env_control_files dm
   WHERE (dm.environment_id= $1))
 ;end insert
 COMMIT
 DELETE  FROM dm_env_files_ship de
  WHERE trim(de.environment_name)=trim(env_name)
  WITH nocounter
 ;end delete
 INSERT  FROM dm_env_files_ship
  (environment_name, file_name, disk_name,
  file_type, file_size, size_sequence,
  tablespace_name, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task,
  tablespace_exist_ind)(SELECT
   env_name, dm.file_name, dm.disk_name,
   dm.file_type, dm.file_size, dm.size_sequence,
   dm.tablespace_name, dm.updt_applctx, dm.updt_dt_tm,
   dm.updt_cnt, dm.updt_id, dm.updt_task,
   dm.tablespace_exist_ind
   FROM dm_env_files dm
   WHERE (dm.environment_id= $1))
 ;end insert
 COMMIT
 DELETE  FROM dm_env_functions_ship de
  WHERE trim(de.environment_name)=trim(env_name)
  WITH nocounter
 ;end delete
 INSERT  FROM dm_env_functions_ship
  (environment_name, function_id, dependency_ind,
  updt_applctx, updt_dt_tm, updt_cnt,
  updt_id, updt_task)(SELECT
   env_name, dm.function_id, dm.dependency_ind,
   dm.updt_applctx, dm.updt_dt_tm, dm.updt_cnt,
   dm.updt_id, dm.updt_task
   FROM dm_env_functions dm
   WHERE (dm.environment_id= $1))
 ;end insert
 COMMIT
 DELETE  FROM dm_env_index_ship de
  WHERE trim(de.environment_name)=trim(env_name)
  WITH nocounter
 ;end delete
 INSERT  FROM dm_env_index_ship
  (environment_name, index_name, initial_extent,
  next_extent, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task,
  static_rows, rows_per_month)(SELECT
   env_name, dm.index_name, dm.initial_extent,
   dm.next_extent, dm.updt_applctx, dm.updt_dt_tm,
   dm.updt_cnt, dm.updt_id, dm.updt_task,
   dm.static_rows, dm.rows_per_month
   FROM dm_env_index dm
   WHERE (dm.environment_id= $1))
 ;end insert
 COMMIT
 DELETE  FROM dm_env_redo_logs_ship de
  WHERE trim(de.environment_name)=trim(env_name)
  WITH nocounter
 ;end delete
 INSERT  FROM dm_env_redo_logs_ship
  (environment_name, group_number, member_number,
  file_name, disk_name, log_size,
  updt_applctx, updt_dt_tm, updt_cnt,
  updt_id, updt_task)(SELECT
   env_name, dm.group_number, dm.member_number,
   dm.file_name, dm.disk_name, dm.log_size,
   dm.updt_applctx, dm.updt_dt_tm, dm.updt_cnt,
   dm.updt_id, dm.updt_task
   FROM dm_env_redo_logs dm
   WHERE (dm.environment_id= $1))
 ;end insert
 COMMIT
 DELETE  FROM dm_env_roll_segs_ship de
  WHERE trim(de.environment_name)=trim(env_name)
  WITH nocounter
 ;end delete
 INSERT  FROM dm_env_roll_segs_ship
  (environment_name, rollback_seg_name, tablespace_name,
  disk_name, initial_extent, next_extent,
  min_extents, max_extents, optimal,
  updt_applctx, updt_dt_tm, updt_cnt,
  updt_id, updt_task)(SELECT
   env_name, dm.rollback_seg_name, dm.tablespace_name,
   dm.disk_name, dm.initial_extent, dm.next_extent,
   dm.min_extents, dm.max_extents, dm.optimal,
   dm.updt_applctx, dm.updt_dt_tm, dm.updt_cnt,
   dm.updt_id, dm.updt_task
   FROM dm_env_rollback_segments dm
   WHERE (dm.environment_id= $1))
 ;end insert
 COMMIT
 DELETE  FROM dm_env_table_ship de
  WHERE trim(de.environment_name)=trim(env_name)
  WITH nocounter
 ;end delete
 INSERT  FROM dm_env_table_ship
  (environment_name, table_name, initial_extent,
  next_extent, updt_applctx, updt_dt_tm,
  updt_cnt, updt_id, updt_task,
  static_rows, rows_per_month)(SELECT
   env_name, dm.table_name, dm.initial_extent,
   dm.next_extent, dm.updt_applctx, dm.updt_dt_tm,
   dm.updt_cnt, dm.updt_id, dm.updt_task,
   dm.static_rows, dm.rows_per_month
   FROM dm_env_table dm
   WHERE (dm.environment_id= $1))
 ;end insert
 COMMIT
 DELETE  FROM dm_readme_hist_ship de
  WHERE trim(de.environment_name)=trim(env_name)
  WITH nocounter
 ;end delete
 INSERT  FROM dm_readme_hist_ship
  (process_id, environment_name, success_ind,
  create_dt_tm, updt_dt_tm, updt_cnt)(SELECT
   dm.process_id, env_name, dm.success_ind,
   dm.create_dt_tm, dm.updt_dt_tm, dm.updt_cnt
   FROM dm_pkt_setup_proc_hist dm
   WHERE (dm.environment_id= $1))
 ;end insert
 COMMIT
 DELETE  FROM dm_afe_ship de
  WHERE trim(de.environment_name)=trim(env_name)
  WITH nocounter
 ;end delete
 INSERT  FROM dm_afe_ship
  (alpha_feature_nbr, environment_name, start_dt_tm,
  end_dt_tm, status, inst_mode,
  calling_script, curr_migration_ind)(SELECT
   dm.alpha_feature_nbr, env_name, dm.start_dt_tm,
   dm.end_dt_tm, dm.status, dm.inst_mode,
   dm.calling_script, dm.curr_migration_ind
   FROM dm_alpha_features_env dm
   WHERE (dm.environment_id= $1))
 ;end insert
 COMMIT
 DELETE  FROM dm_ocd_log_ship de
  WHERE trim(de.environment_name)=trim(env_name)
  WITH nocounter
 ;end delete
 INSERT  FROM dm_ocd_log_ship
  (environment_name, project_type, project_name,
  project_instance, ocd, batch_dt_tm,
  status, start_dt_tm, end_dt_tm,
  driver_count, estimated_time, message,
  active_ind, updt_dt_tm)(SELECT
   env_name, project_type, project_name,
   project_instance, ocd, batch_dt_tm,
   status, start_dt_tm, end_dt_tm,
   driver_count, estimated_time, message,
   active_ind, updt_dt_tm
   FROM dm_ocd_log dm
   WHERE (dm.environment_id= $1))
 ;end insert
 COMMIT
END GO
