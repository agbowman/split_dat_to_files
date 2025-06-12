CREATE PROGRAM dm_env_import_main:dba
 SELECT INTO "nl:"
  dm.environment_id
  FROM dm_environment dm
  WHERE (dm.environment_name=dm_env_import_request->target_environment_name)
  DETAIL
   dm_env_import_request->target_environment_id = dm.environment_id, dm_env_import_request->
   target_environment_exists = 1
  WITH nocounter
 ;end select
 IF ((dm_env_import_request->target_environment_exists=1))
  EXECUTE FROM delete_old_environment TO delete_old_environment_end
 ELSE
  SELECT INTO "nl:"
   y = seq(dm_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    dm_env_import_request->target_environment_id = y
   WITH format, counter
  ;end select
 ENDIF
 SET target_os = fillstring(3," ")
 SELECT INTO "nl:"
  FROM dm_environment_ship dmt
  WHERE trim(dmt.environment_name)=trim(dm_env_import_request->master_environment_name)
  DETAIL
   target_os = dmt.target_operating_system
  WITH nocounter
 ;end select
 EXECUTE FROM insert_environment TO insert_environment_end
 COMMIT
 GO TO end_script
#insert_environment
 INSERT  FROM dm_environment de
  (de.environment_id, de.description, de.environment_name,
  de.database_name, de.total_database_size, de.target_operating_system,
  de.database_disk, de.database_archive_disk, de.data_file_partition_size,
  de.admin_dbase_link_name, de.schema_version, de.from_schema_version,
  de.control_file_count, de.redo_log_groups, de.redo_log_members,
  de.db_version, de.version_id, de.temporary_tspace_disk,
  de.system_tspace_disk, de.root_dir_name, de.volume_group,
  de.v500_connect_string, de.v500ref_connect_string, de.updt_applctx,
  de.updt_dt_tm, de.updt_cnt, de.updt_id,
  de.updt_task, de.month_cnt, de.cerner_fs_mtpt,
  de.ora_pri_fs_mtpt, de.ora_sec_fs_mtpt, de.oracle_version,
  de.max_file_size, de.envset_string)(SELECT
   dm_env_import_request->target_environment_id, dm_env_import_request->
   target_environment_description, dm_env_import_request->target_environment_name,
   dm_env_import_request->target_database_name, dmt.total_database_size, dmt.target_operating_system,
   dm_env_import_request->vms_database_disk, dm_env_import_request->vms_archive_disk, dmt
   .data_file_partition_size,
   dmt.admin_dbase_link_name, dmt.schema_version, dmt.from_schema_version,
   dmt.control_file_count, dmt.redo_log_groups, dmt.redo_log_members,
   dm_env_import_request->target_database_version, dmt.version_id, dmt.temporary_tspace_disk,
   dmt.system_tspace_disk, dmt.root_dir_name, dmt.volume_group,
   concat(dmt.v500_connect_string,"@",dm_env_import_request->target_database_name,"1"), concat(dmt
    .v500ref_connect_string,"@",dm_env_import_request->target_database_name,"1"), dmt.updt_applctx,
   dmt.updt_dt_tm, dmt.updt_cnt, dmt.updt_id,
   dmt.updt_task, dmt.month_cnt, dm_env_import_request->cerner_mtpt,
   dm_env_import_request->ora_sft_mtpt, dm_env_import_request->ora_link_mtpt, dm_env_import_request->
   target_oracle_version,
   dmt.max_file_size, cnvtlower(dm_env_import_request->target_environment_name)
   FROM dm_environment_ship dmt
   WHERE trim(dmt.environment_name)=trim(dm_env_import_request->master_environment_name))
 ;end insert
 INSERT  FROM dm_env_control_files dec
  (dec.environment_id, dec.cntl_file_num, dec.file_name,
  dec.disk_name, dec.updt_applctx, dec.updt_dt_tm,
  dec.updt_cnt, dec.updt_id, dec.updt_task,
  dec.file_size)(SELECT
   dm_env_import_request->target_environment_id, dmt.cntl_file_num, dmt.file_name,
   dmt.disk_name, dmt.updt_applctx, dmt.updt_dt_tm,
   dmt.updt_cnt, dmt.updt_id, dmt.updt_task,
   dmt.file_size
   FROM dm_env_con_files_ship dmt
   WHERE trim(dmt.environment_name)=trim(dm_env_import_request->master_environment_name))
 ;end insert
 INSERT  FROM dm_env_files def
  (def.environment_id, def.file_name, def.disk_name,
  def.file_type, def.file_size, def.size_sequence,
  def.tablespace_name, def.updt_applctx, def.updt_dt_tm,
  def.updt_cnt, def.updt_id, def.updt_task,
  def.tablespace_exist_ind)(SELECT
   dm_env_import_request->target_environment_id, dmt.file_name, dmt.disk_name,
   dmt.file_type, dmt.file_size, dmt.size_sequence,
   dmt.tablespace_name, dmt.updt_applctx, dmt.updt_dt_tm,
   dmt.updt_cnt, dmt.updt_id, dmt.updt_task,
   dmt.tablespace_exist_ind
   FROM dm_env_files_ship dmt
   WHERE trim(dmt.environment_name)=trim(dm_env_import_request->master_environment_name))
 ;end insert
 IF (target_os="AIX")
  FREE SET env_files
  RECORD env_files(
    1 count = i4
    1 qual[*]
      2 file_name = c80
      2 old_file_name = c80
  )
  SET env_files->count = 0
  SET stat = alterlist(env_files->qual,0)
  SELECT INTO "nl:"
   FROM dm_env_files def
   WHERE (def.environment_id=dm_env_import_request->target_environment_id)
   DETAIL
    env_files->count = (env_files->count+ 1), stat = alterlist(env_files->qual,env_files->count),
    env_files->qual[env_files->count].old_file_name = def.file_name
   WITH nocounter
  ;end select
  FOR (i = 1 TO env_files->count)
    SET len = size(env_files->qual[i].old_file_name)
    SET x = findstring("_",env_files->qual[i].old_file_name)
    SET env_files->qual[i].file_name = concat(trim(dm_env_import_request->target_database_name),
     substring(x,((len - x)+ 1),env_files->qual[i].old_file_name))
    UPDATE  FROM dm_env_files def
     SET def.file_name = env_files->qual[i].file_name
     WHERE (def.environment_id=dm_env_import_request->target_environment_id)
      AND (def.file_name=env_files->qual[i].old_file_name)
    ;end update
  ENDFOR
 ENDIF
 INSERT  FROM dm_env_functions def
  (def.environment_id, def.function_id, def.dependency_ind,
  def.updt_applctx, def.updt_dt_tm, def.updt_cnt,
  def.updt_id, def.updt_task)(SELECT
   dm_env_import_request->target_environment_id, dmt.function_id, dmt.dependency_ind,
   dmt.updt_applctx, dmt.updt_dt_tm, dmt.updt_cnt,
   dmt.updt_id, dmt.updt_task
   FROM dm_env_functions_ship dmt
   WHERE trim(dmt.environment_name)=trim(dm_env_import_request->master_environment_name))
 ;end insert
 INSERT  FROM dm_env_index dei
  (dei.environment_id, dei.index_name, dei.initial_extent,
  dei.next_extent, dei.updt_applctx, dei.updt_dt_tm,
  dei.updt_cnt, dei.updt_id, dei.updt_task,
  dei.static_rows, dei.rows_per_month)(SELECT
   dm_env_import_request->target_environment_id, dmt.index_name, dmt.initial_extent,
   dmt.next_extent, dmt.updt_applctx, dmt.updt_dt_tm,
   dmt.updt_cnt, dmt.updt_id, dmt.updt_task,
   dmt.static_rows, dmt.rows_per_month
   FROM dm_env_index_ship dmt
   WHERE trim(dmt.environment_name)=trim(dm_env_import_request->master_environment_name))
 ;end insert
 INSERT  FROM dm_env_redo_logs derl
  (derl.environment_id, derl.group_number, derl.member_number,
  derl.file_name, derl.disk_name, derl.log_size,
  derl.updt_applctx, derl.updt_dt_tm, derl.updt_cnt,
  derl.updt_id, derl.updt_task)(SELECT
   dm_env_import_request->target_environment_id, dmt.group_number, dmt.member_number,
   dmt.file_name, dmt.disk_name, dmt.log_size,
   dmt.updt_applctx, dmt.updt_dt_tm, dmt.updt_cnt,
   dmt.updt_id, dmt.updt_task
   FROM dm_env_redo_logs_ship dmt
   WHERE trim(dmt.environment_name)=trim(dm_env_import_request->master_environment_name))
 ;end insert
 INSERT  FROM dm_env_rollback_segments ders
  (ders.environment_id, ders.rollback_seg_name, ders.tablespace_name,
  ders.disk_name, ders.initial_extent, ders.next_extent,
  ders.min_extents, ders.max_extents, ders.optimal,
  ders.updt_applctx, ders.updt_dt_tm, ders.updt_cnt,
  ders.updt_id, ders.updt_task)(SELECT
   dm_env_import_request->target_environment_id, dmt.rollback_seg_name, dmt.tablespace_name,
   dmt.disk_name, dmt.initial_extent, dmt.next_extent,
   dmt.min_extents, dmt.max_extents, dmt.optimal,
   dmt.updt_applctx, dmt.updt_dt_tm, dmt.updt_cnt,
   dmt.updt_id, dmt.updt_task
   FROM dm_env_roll_segs_ship dmt
   WHERE trim(dmt.environment_name)=trim(dm_env_import_request->master_environment_name))
 ;end insert
 INSERT  FROM dm_env_table det
  (det.environment_id, det.table_name, det.initial_extent,
  det.next_extent, det.updt_applctx, det.updt_dt_tm,
  det.updt_cnt, det.updt_id, det.updt_task,
  det.static_rows, det.rows_per_month)(SELECT
   dm_env_import_request->target_environment_id, dmt.table_name, dmt.initial_extent,
   dmt.next_extent, dmt.updt_applctx, dmt.updt_dt_tm,
   dmt.updt_cnt, dmt.updt_id, dmt.updt_task,
   dmt.static_rows, dmt.rows_per_month
   FROM dm_env_table_ship dmt
   WHERE trim(dmt.environment_name)=trim(dm_env_import_request->master_environment_name))
 ;end insert
 IF (validate(dm2_force_pkg_hist,0) > 0)
  INSERT  FROM dm_pkt_setup_proc_hist dp
   (dp.process_id, dp.environment_id, dp.success_ind,
   dp.create_dt_tm, dp.updt_dt_tm, dp.updt_cnt)(SELECT
    dmt.process_id, dm_env_import_request->target_environment_id, dmt.success_ind,
    dmt.create_dt_tm, dmt.updt_dt_tm, dmt.updt_cnt
    FROM dm_readme_hist_ship dmt
    WHERE trim(dmt.environment_name)=trim(dm_env_import_request->master_environment_name))
  ;end insert
  INSERT  FROM dm_alpha_features_env d
   (d.alpha_feature_nbr, d.environment_id, d.start_dt_tm,
   d.end_dt_tm, d.status)(SELECT
    das.alpha_feature_nbr, dm_env_import_request->target_environment_id, cnvtdatetime(curdate,
     curtime3),
    cnvtdatetime(curdate,curtime3), "Successful"
    FROM dm_afe_ship das
    WHERE trim(das.environment_name)=trim(dm_env_import_request->master_environment_name))
  ;end insert
  INSERT  FROM dm_ocd_log do
   (do.environment_id, do.project_type, do.project_name,
   do.project_instance, do.ocd, do.batch_dt_tm,
   do.status, do.start_dt_tm, do.end_dt_tm,
   do.driver_count, do.estimated_time, do.message,
   do.active_ind, do.updt_dt_tm)(SELECT
    dm_env_import_request->target_environment_id, dol.project_type, dol.project_name,
    dol.project_instance, dol.ocd, cnvtdatetime(curdate,curtime3),
    dol.status, cnvtdatetime(curdate,curtime3), cnvtdatetime(curdate,curtime3),
    dol.driver_count, dol.estimated_time, dol.message,
    dol.active_ind, cnvtdatetime(curdate,curtime3)
    FROM dm_ocd_log_ship dol
    WHERE trim(dol.environment_name)=trim(dm_env_import_request->master_environment_name))
  ;end insert
 ENDIF
#insert_environment_end
#delete_old_environment
 DELETE  FROM dm_environment dm
  WHERE (dm.environment_id=dm_env_import_request->target_environment_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_env_control_files dm
  WHERE (dm.environment_id=dm_env_import_request->target_environment_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_env_files dm
  WHERE (dm.environment_id=dm_env_import_request->target_environment_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_env_functions dm
  WHERE (dm.environment_id=dm_env_import_request->target_environment_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_env_index dm
  WHERE (dm.environment_id=dm_env_import_request->target_environment_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_env_redo_logs dm
  WHERE (dm.environment_id=dm_env_import_request->target_environment_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_env_rollback_segments dm
  WHERE (dm.environment_id=dm_env_import_request->target_environment_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_env_table dm
  WHERE (dm.environment_id=dm_env_import_request->target_environment_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_pkt_setup_proc_hist dm
  WHERE (dm.environment_id=dm_env_import_request->target_environment_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_alpha_features_env dm
  WHERE (dm.environment_id=dm_env_import_request->target_environment_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_ocd_log do
  WHERE (do.environment_id=dm_env_import_request->target_environment_id)
  WITH nocounter
 ;end delete
#delete_old_environment_end
#end_script
END GO
