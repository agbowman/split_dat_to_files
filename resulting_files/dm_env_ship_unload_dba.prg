CREATE PROGRAM dm_env_ship_unload:dba
 SET env_name = fillstring(20," ")
 RECORD env_list(
   1 env_cnt = i4
   1 env_list[50]
     2 env_name = vc
     2 env_id = i4
 )
 SET env_list->env_cnt = 0
 SELECT INTO "nl:"
  dm.environment_name
  FROM dm_environment_ship dm
  DETAIL
   env_list->env_cnt = (env_list->env_cnt+ 1), env_list->env_list[env_list->env_cnt].env_name = dm
   .environment_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dm.environment_name, dm.environment_id
  FROM dm_environment dm,
   (dummyt d  WITH seq = value(env_list->env_cnt))
  PLAN (d)
   JOIN (dm
   WHERE trim(dm.environment_name)=trim(env_list->env_list[d.seq].env_name))
  DETAIL
   env_list->env_list[d.seq].env_id = dm.environment_id
  WITH nocounter
 ;end select
 FOR (i = 1 TO env_list->env_cnt)
   IF ((env_list->env_list[i].env_id=0))
    SELECT INTO "nl:"
     y = seq(dm_seq,nextval)
     FROM dual
     DETAIL
      env_list->env_list[i].env_id = y
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 FOR (i = 1 TO env_list->env_cnt)
   CALL echo(concat("deleting from DM_ENVIRONMENT                 env = ",env_list->env_list[i].
     env_name))
   DELETE  FROM dm_environment dm
    WHERE (dm.environment_id=env_list->env_list[i].env_id)
    WITH nocounter
   ;end delete
   INSERT  FROM dm_environment
    (environment_id, description, environment_name,
    database_name, total_database_size, target_operating_system,
    database_disk, database_archive_disk, data_file_partition_size,
    admin_dbase_link_name, schema_version, from_schema_version,
    control_file_count, redo_log_groups, redo_log_members,
    db_version, version_id, temporary_tspace_disk,
    system_tspace_disk, root_dir_name, volume_group,
    v500_connect_string, v500ref_connect_string, updt_applctx,
    updt_dt_tm, updt_cnt, updt_id,
    updt_task, month_cnt, cerner_fs_mtpt,
    ora_pri_fs_mtpt, ora_sec_fs_mtpt, oracle_version,
    max_file_size, envset_string)(SELECT
     env_list->env_list[i].env_id, dmt.description, env_list->env_list[i].env_name,
     dmt.database_name, dmt.total_database_size, dmt.target_operating_system,
     dmt.database_disk, dmt.database_archive_disk, dmt.data_file_partition_size,
     dmt.admin_dbase_link_name, dmt.schema_version, dmt.from_schema_version,
     dmt.control_file_count, dmt.redo_log_groups, dmt.redo_log_members,
     dmt.db_version, dmt.version_id, dmt.temporary_tspace_disk,
     dmt.system_tspace_disk, dmt.root_dir_name, dmt.volume_group,
     dmt.v500_connect_string, dmt.v500ref_connect_string, dmt.updt_applctx,
     dmt.updt_dt_tm, dmt.updt_cnt, dmt.updt_id,
     dmt.updt_task, dmt.month_cnt, dmt.cerner_fs_mtpt,
     dmt.ora_pri_fs_mtpt, dmt.ora_sec_fs_mtpt, dmt.oracle_version,
     dmt.max_file_size, dmt.envset_string
     FROM dm_environment_ship dmt
     WHERE trim(dmt.environment_name)=trim(env_list->env_list[i].env_name))
   ;end insert
 ENDFOR
 FOR (i = 1 TO env_list->env_cnt)
   CALL echo(concat("deleting from DM_ENV_CONTROL_FILES           env = ",env_list->env_list[i].
     env_name))
   DELETE  FROM dm_env_control_files dm
    WHERE (dm.environment_id=env_list->env_list[i].env_id)
    WITH nocounter
   ;end delete
   INSERT  FROM dm_env_control_files
    (environment_id, cntl_file_num, file_name,
    disk_name, updt_applctx, updt_dt_tm,
    updt_cnt, updt_id, updt_task,
    file_size)(SELECT
     env_list->env_list[i].env_id, dmt.cntl_file_num, dmt.file_name,
     dmt.disk_name, dmt.updt_applctx, dmt.updt_dt_tm,
     dmt.updt_cnt, dmt.updt_id, dmt.updt_task,
     dmt.file_size
     FROM dm_env_con_files_ship dmt
     WHERE trim(dmt.environment_name)=trim(env_list->env_list[i].env_name))
   ;end insert
 ENDFOR
 FOR (i = 1 TO env_list->env_cnt)
   CALL echo(concat("deleting from DM_ENV_FILES                   env = ",env_list->env_list[i].
     env_name))
   DELETE  FROM dm_env_files dm
    WHERE (dm.environment_id=env_list->env_list[i].env_id)
    WITH nocounter
   ;end delete
   INSERT  FROM dm_env_files
    (environment_id, file_name, disk_name,
    file_type, file_size, size_sequence,
    tablespace_name, updt_applctx, updt_dt_tm,
    updt_cnt, updt_id, updt_task,
    tablespace_exist_ind)(SELECT
     env_list->env_list[i].env_id, dmt.file_name, dmt.disk_name,
     dmt.file_type, dmt.file_size, dmt.size_sequence,
     dmt.tablespace_name, dmt.updt_applctx, dmt.updt_dt_tm,
     dmt.updt_cnt, dmt.updt_id, dmt.updt_task,
     dmt.tablespace_exist_ind
     FROM dm_env_files_ship dmt
     WHERE trim(dmt.environment_name)=trim(env_list->env_list[i].env_name))
   ;end insert
 ENDFOR
 FOR (i = 1 TO env_list->env_cnt)
   CALL echo(concat("deleting from DM_ENV_FUNCTIONS               env = ",env_list->env_list[i].
     env_name))
   DELETE  FROM dm_env_functions dm
    WHERE (dm.environment_id=env_list->env_list[i].env_id)
    WITH nocounter
   ;end delete
   INSERT  FROM dm_env_functions
    (environment_id, function_id, dependency_ind,
    updt_applctx, updt_dt_tm, updt_cnt,
    updt_id, updt_task)(SELECT
     env_list->env_list[i].env_id, dmt.function_id, dmt.dependency_ind,
     dmt.updt_applctx, dmt.updt_dt_tm, dmt.updt_cnt,
     dmt.updt_id, dmt.updt_task
     FROM dm_env_functions_ship dmt
     WHERE trim(dmt.environment_name)=trim(env_list->env_list[i].env_name))
   ;end insert
 ENDFOR
 FOR (i = 1 TO env_list->env_cnt)
   CALL echo(concat("deleting from DM_ENV_INDEX                   env = ",env_list->env_list[i].
     env_name))
   DELETE  FROM dm_env_index dm
    WHERE (dm.environment_id=env_list->env_list[i].env_id)
    WITH nocounter
   ;end delete
   INSERT  FROM dm_env_index
    (environment_id, index_name, initial_extent,
    next_extent, updt_applctx, updt_dt_tm,
    updt_cnt, updt_id, updt_task,
    static_rows, rows_per_month)(SELECT
     env_list->env_list[i].env_id, dmt.index_name, dmt.initial_extent,
     dmt.next_extent, dmt.updt_applctx, dmt.updt_dt_tm,
     dmt.updt_cnt, dmt.updt_id, dmt.updt_task,
     dmt.static_rows, dmt.rows_per_month
     FROM dm_env_index_ship dmt
     WHERE trim(dmt.environment_name)=trim(env_list->env_list[i].env_name))
   ;end insert
 ENDFOR
 FOR (i = 1 TO env_list->env_cnt)
   CALL echo(concat("deleting from DM_ENV_REDO_LOGS               env = ",env_list->env_list[i].
     env_name))
   DELETE  FROM dm_env_redo_logs dm
    WHERE (dm.environment_id=env_list->env_list[i].env_id)
    WITH nocounter
   ;end delete
   INSERT  FROM dm_env_redo_logs
    (environment_id, group_number, member_number,
    file_name, disk_name, log_size,
    updt_applctx, updt_dt_tm, updt_cnt,
    updt_id, updt_task)(SELECT
     env_list->env_list[i].env_id, dmt.group_number, dmt.member_number,
     dmt.file_name, dmt.disk_name, dmt.log_size,
     dmt.updt_applctx, dmt.updt_dt_tm, dmt.updt_cnt,
     dmt.updt_id, dmt.updt_task
     FROM dm_env_redo_logs_ship dmt
     WHERE trim(dmt.environment_name)=trim(env_list->env_list[i].env_name))
   ;end insert
 ENDFOR
 FOR (i = 1 TO env_list->env_cnt)
   CALL echo(concat("deleting from DM_ENV_ROLLBACK_SEGMENTS       env = ",env_list->env_list[i].
     env_name))
   DELETE  FROM dm_env_rollback_segments dm
    WHERE (dm.environment_id=env_list->env_list[i].env_id)
    WITH nocounter
   ;end delete
   INSERT  FROM dm_env_rollback_segments
    (environment_id, rollback_seg_name, tablespace_name,
    disk_name, initial_extent, next_extent,
    min_extents, max_extents, optimal,
    updt_applctx, updt_dt_tm, updt_cnt,
    updt_id, updt_task)(SELECT
     env_list->env_list[i].env_id, dmt.rollback_seg_name, dmt.tablespace_name,
     dmt.disk_name, dmt.initial_extent, dmt.next_extent,
     dmt.min_extents, dmt.max_extents, dmt.optimal,
     dmt.updt_applctx, dmt.updt_dt_tm, dmt.updt_cnt,
     dmt.updt_id, dmt.updt_task
     FROM dm_env_roll_segs_ship dmt
     WHERE trim(dmt.environment_name)=trim(env_list->env_list[i].env_name))
   ;end insert
 ENDFOR
 FOR (i = 1 TO env_list->env_cnt)
   CALL echo(concat("deleting from DM_ENV_TABLE                   env = ",env_list->env_list[i].
     env_name))
   DELETE  FROM dm_env_table dm
    WHERE (dm.environment_id=env_list->env_list[i].env_id)
    WITH nocounter
   ;end delete
   INSERT  FROM dm_env_table
    (environment_id, table_name, initial_extent,
    next_extent, updt_applctx, updt_dt_tm,
    updt_cnt, updt_id, updt_task,
    static_rows, rows_per_month)(SELECT
     env_list->env_list[i].env_id, dmt.table_name, dmt.initial_extent,
     dmt.next_extent, dmt.updt_applctx, dmt.updt_dt_tm,
     dmt.updt_cnt, dmt.updt_id, dmt.updt_task,
     dmt.static_rows, dmt.rows_per_month
     FROM dm_env_table_ship dmt
     WHERE trim(dmt.environment_name)=trim(env_list->env_list[i].env_name))
   ;end insert
 ENDFOR
END GO
