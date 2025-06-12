CREATE PROGRAM dm_fix_dm_db_size_tables:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 EXECUTE FROM 1000_initialize TO 1999_exit_initialize
 EXECUTE FROM 2000_validate_tables TO 2999_exit_validate_tables
 EXECUTE FROM 3000_fix_dm_size_db_config TO 3999_exit_fix_dm_size_db_config
 EXECUTE FROM 4000_fix_dm_size_db_cntl_files TO 4999_exit_fix_dm_size_db_cntl_files
 EXECUTE FROM 5000_fix_dm_size_db_redo_logs TO 5999_exit_fix_dm_size_db_redo_logs
 EXECUTE FROM 6000_fix_dm_size_db_rb_segs TO 6999_exit_fix_dm_size_db_rb_segs
 EXECUTE FROM 7000_fix_dm_size_db_ts TO 7999_exit_fix_dm_size_db_ts
 GO TO end_program
 SUBROUTINE fi_kick_out(v_err_msg)
   SET g_error_flag = 1
   SET readme_data->message = v_err_msg
   CALL echo(readme_data->message)
   EXECUTE dm_readme_status
   GO TO end_program
 END ;Subroutine
 SUBROUTINE fi_chk_tbl_synonym(s_table)
  SELECT INTO "nl:"
   FROM dba_synonyms da
   WHERE da.synonym_name=cnvtupper(s_table)
    AND da.owner="PUBLIC"
   DETAIL
    g_adm_link = cnvtupper(trim(substring(1,(findstring(".",da.db_link) - 1),da.db_link)))
   WITH nocounter
  ;end select
  IF (curqual)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE fi_chk_ccl_def(def_table)
  SELECT INTO "nl:"
   l.attr_name
   FROM dtableattr d,
    dtableattrl l
   WHERE l.structtype="F"
    AND btest(l.stat,11)=0
    AND d.table_name=cnvtupper(def_table)
    AND l.attr_name="*"
   WITH nocounter
  ;end select
  IF (curqual)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE fi_fix_initora(a_version,a_config_parm,a_parm_type,a_value)
   SELECT INTO "nl:"
    FROM dm_size_db_config ds
    WHERE ds.db_version=a_version
     AND ds.config_parm=a_config_parm
    WITH nocounter
   ;end select
   IF (curqual)
    UPDATE  FROM dm_size_db_config ds
     SET ds.parm_type = a_parm_type, ds.value = a_value, ds.updt_applctx = 1,
      ds.updt_dt_tm = cnvtdatetime(curdate,curtime3), ds.updt_cnt = (ds.updt_cnt+ 1), ds.updt_id = 1,
      ds.updt_task = 1
     WHERE ds.db_version=a_version
      AND ds.config_parm=a_config_parm
     WITH nocounter
    ;end update
   ELSE
    INSERT  FROM dm_size_db_config ds
     SET ds.db_version = a_version, ds.config_parm = a_config_parm, ds.parm_type = a_parm_type,
      ds.value = a_value, ds.updt_applctx = 1, ds.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ds.updt_cnt = 1, ds.updt_id = 1, ds.updt_task = 1
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM dm_size_db_config ds
    WHERE ds.db_version=a_version
     AND ds.config_parm=a_config_parm
     AND ds.parm_type=a_parm_type
     AND ds.value=a_value
    WITH nocounter
   ;end select
   SET temp_str = concat("Modify DM_SIZE_DB_CONFIG Parameters (DB Ver: ",trim(cnvtstring(a_version)),
    ", ","Parameter: ",a_config_parm,
    ")")
   IF (curqual)
    SET g_error_flag = 0
    SET readme_data->status = "Z"
    SET readme_data->message = concat(trim(temp_str),"... Successful.")
    CALL echo(readme_data->message)
    EXECUTE dm_readme_status
   ELSE
    CALL fi_kick_out(concat(trim(temp_str),"... Failed.  Readme Failed."))
   ENDIF
 END ;Subroutine
 SUBROUTINE fi_fix_cntl_files(e_version,e_cntl_file_num,e_file_name,e_file_size)
   SELECT INTO "nl:"
    FROM dm_size_db_cntl_files dsd
    WHERE dsd.db_version=e_version
     AND dsd.file_name=e_file_name
    WITH nocounter
   ;end select
   IF (curqual)
    UPDATE  FROM dm_size_db_cntl_files dsd
     SET dsd.cntl_file_num = e_cntl_file_num, dsd.file_size = e_file_size, dsd.updt_applctx = 1,
      dsd.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsd.updt_cnt = (dsd.updt_cnt+ 1), dsd.updt_id
       = 1,
      dsd.updt_task = 1
     WHERE dsd.db_version=e_version
      AND dsd.file_name=e_file_name
     WITH nocounter
    ;end update
   ELSE
    INSERT  FROM dm_size_db_cntl_files dsd
     SET dsd.db_version = e_version, dsd.cntl_file_num = e_cntl_file_num, dsd.file_name = e_file_name,
      dsd.file_size = e_file_size, dsd.updt_applctx = 1, dsd.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      dsd.updt_cnt = 1, dsd.updt_id = 1, dsd.updt_task = 1
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM dm_size_db_cntl_files dsd
    WHERE dsd.db_version=e_version
     AND dsd.cntl_file_num=e_cntl_file_num
     AND dsd.file_name=e_file_name
     AND dsd.file_size=e_file_size
    WITH nocounter
   ;end select
   SET temp_str = concat("Modify DM_SIZE_DB_CNTL_FILES Parameters (DB Ver: ",trim(cnvtstring(
      e_version)),", ","File Name: ",e_file_name,
    ")")
   IF (curqual)
    SET g_error_flag = 0
    SET readme_data->status = "Z"
    SET readme_data->message = concat(trim(temp_str),"... Successful.")
    CALL echo(readme_data->message)
    EXECUTE dm_readme_status
   ELSE
    CALL fi_kick_out(concat(trim(temp_str),"... Failed.  Readme Failed."))
   ENDIF
 END ;Subroutine
 SUBROUTINE fi_fix_redo_logs(f_version,f_groups_num,f_members_num,f_file_name,f_log_size)
   SELECT INTO "nl:"
    FROM dm_size_db_redo_logs dsr
    WHERE dsr.db_version=f_version
     AND dsr.file_name=f_file_name
    WITH nocounter
   ;end select
   IF (curqual)
    UPDATE  FROM dm_size_db_redo_logs dsr
     SET dsr.groups_num = f_groups_num, dsr.members_num = f_members_num, dsr.log_size = f_log_size,
      dsr.updt_applctx = 1, dsr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsr.updt_cnt = (dsr
      .updt_cnt+ 1),
      dsr.updt_id = 1, dsr.updt_task = 1
     WHERE dsr.db_version=f_version
      AND dsr.file_name=f_file_name
     WITH nocounter
    ;end update
   ELSE
    INSERT  FROM dm_size_db_redo_logs dsr
     SET dsr.db_version = f_version, dsr.groups_num = f_groups_num, dsr.members_num = f_members_num,
      dsr.file_name = f_file_name, dsr.log_size = f_log_size, dsr.updt_applctx = 1,
      dsr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsr.updt_cnt = 1, dsr.updt_id = 1,
      dsr.updt_task = 1
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM dm_size_db_redo_logs dsr
    WHERE dsr.db_version=f_version
     AND dsr.groups_num=f_groups_num
     AND dsr.members_num=f_members_num
     AND dsr.file_name=f_file_name
     AND dsr.log_size=f_log_size
    WITH nocounter
   ;end select
   SET temp_str = concat("Modify DM_SIZE_DB_REDO_LOGS Parameters (DB Ver: ",trim(cnvtstring(f_version
      )),", ","File Name: ",f_file_name,
    ")")
   IF (curqual)
    SET g_error_flag = 0
    SET readme_data->status = "Z"
    SET readme_data->message = concat(trim(temp_str),"... Successful.")
    CALL echo(readme_data->message)
    EXECUTE dm_readme_status
   ELSE
    CALL fi_kick_out(concat(trim(temp_str),"... Failed.  Readme Failed."))
   ENDIF
 END ;Subroutine
 SUBROUTINE fi_fix_rb_segs(g_version,g_rb_seg_name,g_ts_name,g_init_ext,g_next_ext,g_min_ext,
  g_max_ext,g_opt)
   SELECT INTO "nl:"
    FROM dm_size_db_rollback_segs dsrs
    WHERE dsrs.db_version=g_version
     AND dsrs.rollback_seg_name=g_rb_seg_name
    WITH nocounter
   ;end select
   IF (curqual)
    UPDATE  FROM dm_size_db_rollback_segs dsrs
     SET dsrs.tablespace_name = g_ts_name, dsrs.initial_extent = g_init_ext, dsrs.next_extent =
      g_next_ext,
      dsrs.min_extents = g_min_ext, dsrs.max_extents = g_max_ext, dsrs.optimal = g_opt,
      dsrs.updt_applctx = 1, dsrs.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsrs.updt_cnt = (dsrs
      .updt_cnt+ 1),
      dsrs.updt_id = 1, dsrs.updt_task = 1
     WHERE dsrs.db_version=g_version
      AND dsrs.rollback_seg_name=g_rb_seg_name
     WITH nocounter
    ;end update
   ELSE
    INSERT  FROM dm_size_db_rollback_segs dsrs
     SET dsrs.db_version = g_version, dsrs.rollback_seg_name = g_rb_seg_name, dsrs.tablespace_name =
      g_ts_name,
      dsrs.initial_extent = g_init_ext, dsrs.next_extent = g_next_ext, dsrs.min_extents = g_min_ext,
      dsrs.max_extents = g_max_ext, dsrs.optimal = g_opt, dsrs.updt_applctx = 1,
      dsrs.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsrs.updt_cnt = 1, dsrs.updt_id = 1,
      dsrs.updt_task = 1
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM dm_size_db_rollback_segs dsrs
    WHERE dsrs.db_version=g_version
     AND dsrs.rollback_seg_name=g_rb_seg_name
     AND dsrs.tablespace_name=g_ts_name
     AND dsrs.initial_extent=g_init_ext
     AND dsrs.next_extent=g_next_ext
     AND dsrs.min_extents=g_min_ext
     AND dsrs.max_extents=g_max_ext
     AND dsrs.optimal=g_opt
    WITH nocounter
   ;end select
   SET temp_str = concat("Modify DM_SIZE_DB_ROLLBACK_SEGS Parameters (DB Ver: ",trim(cnvtstring(
      g_version)),", ","RB Name: ",g_rb_seg_name,
    ")")
   IF (curqual)
    SET g_error_flag = 0
    SET readme_data->status = "Z"
    SET readme_data->message = concat(trim(temp_str),"... Successful.")
    CALL echo(readme_data->message)
    EXECUTE dm_readme_status
   ELSE
    CALL fi_kick_out(concat(trim(temp_str),"... Failed.  Readme Failed."))
   ENDIF
 END ;Subroutine
 SUBROUTINE fi_fix_ts(h_version,h_ts_name,h_file_name,h_file_size,h_ts_type)
   SELECT INTO "nl:"
    FROM dm_size_db_ts dst
    WHERE dst.db_version=h_version
     AND dst.tablespace_name=h_ts_name
     AND dst.file_name=h_file_name
    WITH nocounter
   ;end select
   IF (curqual)
    UPDATE  FROM dm_size_db_ts dst
     SET dst.file_size = h_file_size, dst.ts_type = h_ts_type, dst.updt_applctx = 1,
      dst.updt_dt_tm = cnvtdatetime(curdate,curtime3), dst.updt_cnt = (dst.updt_cnt+ 1), dst.updt_id
       = 1,
      dst.updt_task = 1
     WHERE dst.db_version=h_version
      AND dst.tablespace_name=h_ts_name
      AND dst.file_name=h_file_name
     WITH nocounter
    ;end update
   ELSE
    INSERT  FROM dm_size_db_ts dst
     SET dst.db_version = h_version, dst.tablespace_name = h_ts_name, dst.file_name = h_file_name,
      dst.file_size = h_file_size, dst.ts_type = h_ts_type, dst.updt_applctx = 1,
      dst.updt_dt_tm = cnvtdatetime(curdate,curtime3), dst.updt_cnt = 1, dst.updt_id = 1,
      dst.updt_task = 1
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM dm_size_db_ts dst
    WHERE dst.db_version=h_version
     AND dst.tablespace_name=h_ts_name
     AND dst.file_name=h_file_name
     AND dst.file_size=h_file_size
     AND dst.ts_type=h_ts_type
    WITH nocounter
   ;end select
   SET temp_str = concat("Modify DM_SIZE_DB_TS Parameters (DB Ver: ",trim(cnvtstring(h_version)),", ",
    "TS Name: ",h_ts_name,
    ")")
   IF (curqual)
    SET g_error_flag = 0
    SET readme_data->status = "Z"
    SET readme_data->message = concat(trim(temp_str),"... Successful.")
    CALL echo(readme_data->message)
    EXECUTE dm_readme_status
   ELSE
    CALL fi_kick_out(concat(trim(temp_str),"... Failed.  Readme Failed."))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET g_adm_link = fillstring(20,"")
 SET g_error_flag = 0
 SET fi_config_tbl = 0
 SET fi_cntl_tbl = 0
 SET fi_redo_tbl = 0
 SET fi_rbsegs_tbl = 0
 SET fi_ts_tbl = 0
 FREE RECORD fi_env
 RECORD fi_env(
   1 e_cnt = i4
   1 qual[*]
     2 env_id = i4
 )
 SET fi_env->e_cnt = 8
 SET stat = alterlist(fi_env->qual,fi_env->e_cnt)
 SET fi_env->qual[1].env_id = 801
 SET fi_env->qual[2].env_id = 804
 SET fi_env->qual[3].env_id = 811
 SET fi_env->qual[4].env_id = 813
 SET fi_env->qual[5].env_id = 815
 SET fi_env->qual[6].env_id = 817
 SET fi_env->qual[7].env_id = 819
 SET fi_env->qual[8].env_id = 821
#1999_exit_initialize
#2000_validate_tables
 SET stat = fi_chk_tbl_synonym("DM_ENVIRONMENT")
 SET fi_config_tbl = fi_chk_tbl_synonym("DM_SIZE_DB_CONFIG")
 SET fi_cntl_tbl = fi_chk_tbl_synonym("DM_SIZE_DB_CNTL_FILES")
 SET fi_redo_tbl = fi_chk_tbl_synonym("DM_SIZE_DB_REDO_LOGS")
 SET fi_rbsegs_tbl = fi_chk_tbl_synonym("DM_SIZE_DB_ROLLBACK_SEGS")
 SET fi_ts_tbl = fi_chk_tbl_synonym("DM_SIZE_DB_TS")
 IF ( NOT (fi_config_tbl))
  CALL parser("rdb create public synonym DM_SIZE_DB_CONFIG",1)
  CALL parser(concat(" for DM_SIZE_DB_CONFIG@",g_adm_link," go"),1)
 ELSEIF ( NOT (fi_cntl_tbl))
  CALL parser("rdb create public synonym DM_SIZE_DB_CNTL_FILES",1)
  CALL parser(concat("for DM_SIZE_DB_CNTL_FILES@",g_adm_link," go"),1)
 ELSEIF ( NOT (fi_redo_tbl))
  CALL parser("rdb create public synonym DM_SIZE_DB_REDO_LOGS",1)
  CALL parser(concat("for DM_SIZE_DB_REDO_LOGS@",g_adm_link," go"),1)
 ELSEIF ( NOT (fi_rbsegs_tbl))
  CALL parser("rdb create public synonym DM_SIZE_DB_ROLLBACK_SEGS",1)
  CALL parser(concat("for DM_SIZE_DB_ROLLBACK_SEGS@",g_adm_link," go"),1)
 ELSEIF ( NOT (fi_ts_tbl))
  CALL parser("rdb create public synonym DM_SIZE_DB_TS",1)
  CALL parser(concat("for DM_SIZE_DB_TS@",g_adm_link," go"),1)
 ENDIF
 SET fi_config_tbl = fi_chk_tbl_synonym("DM_SIZE_DB_CONFIG")
 SET fi_cntl_tbl = fi_chk_tbl_synonym("DM_SIZE_DB_CNTL_FILES")
 SET fi_redo_tbl = fi_chk_tbl_synonym("DM_SIZE_DB_REDO_LOGS")
 SET fi_rbsegs_tbl = fi_chk_tbl_synonym("DM_SIZE_DB_ROLLBACK_SEGS")
 SET fi_ts_tbl = fi_chk_tbl_synonym("DM_SIZE_DB_TS")
 IF ( NOT (fi_config_tbl))
  CALL fi_kick_out("Access DM_SIZE_DB_CONFIG table via synonym... Failed. Readme Failed.")
 ELSEIF ( NOT (fi_cntl_tbl))
  CALL fi_kick_out("Access DM_SIZE_DB_CNTL_FILES table via synonym... Failed. Readme Failed.")
 ELSEIF ( NOT (fi_redo_tbl))
  CALL fi_kick_out("Access DM_SIZE_DB_REDO_LOGS table via synonym... Failed. Readme Failed.")
 ELSEIF ( NOT (fi_rbsegs_tbl))
  CALL fi_kick_out("Access DM_SIZE_DB_ROLLBACK_SEGS table via synonym... Failed. Readme Failed.")
 ELSEIF ( NOT (fi_ts_tbl))
  CALL fi_kick_out("Access DM_SIZE_DB_TS table via synonym... Failed. Readme Failed.")
 ENDIF
 SET fi_config_tbl = 0
 SET fi_cntl_tbl = 0
 SET fi_redo_tbl = 0
 SET fi_rbsegs_tbl = 0
 SET fi_ts_tbl = 0
 SET fi_config_tbl = fi_chk_ccl_def("DM_SIZE_DB_CONFIG")
 SET fi_cntl_tbl = fi_chk_ccl_def("DM_SIZE_DB_CNTL_FILES")
 SET fi_redo_tbl = fi_chk_ccl_def("DM_SIZE_DB_REDO_LOGS")
 SET fi_rbsegs_tbl = fi_chk_ccl_def("DM_SIZE_DB_ROLLBACK_SEGS")
 SET fi_ts_tbl = fi_chk_ccl_def("DM_SIZE_DB_TS")
 IF ( NOT (fi_config_tbl))
  CALL parser(concat("execute oragen3 'DM_SIZE_DB_CONFIG@",g_adm_link,"' go"),1)
 ELSEIF ( NOT (fi_cntl_tbl))
  CALL parser(concat("execute oragen3 'DM_SIZE_DB_CNTL_FILES@",g_adm_link,"' go"),1)
 ELSEIF ( NOT (fi_redo_tbl))
  CALL parser(concat("execute oragen3 'DM_SIZE_DB_REDO_LOGS@",g_adm_link,"' go"),1)
 ELSEIF ( NOT (fi_rbsegs_tbl))
  CALL parser(concat("execute oragen3 'DM_SIZE_DB_ROLLBACK_SEGS@",g_adm_link,"' go"),1)
 ELSEIF ( NOT (fi_ts_tbl))
  CALL parser(concat("execute oragen3 'DM_SIZE_DB_TS@",g_adm_link,"' go"),1)
 ENDIF
 SET fi_config_tbl = fi_chk_ccl_def("DM_SIZE_DB_CONFIG")
 SET fi_cntl_tbl = fi_chk_ccl_def("DM_SIZE_DB_CNTL_FILES")
 SET fi_redo_tbl = fi_chk_ccl_def("DM_SIZE_DB_REDO_LOGS")
 SET fi_rbsegs_tbl = fi_chk_ccl_def("DM_SIZE_DB_ROLLBACK_SEGS")
 SET fi_ts_tbl = fi_chk_ccl_def("DM_SIZE_DB_TS")
 IF ( NOT (fi_config_tbl))
  CALL fi_kick_out("CCL definition for table DM_SIZE_DB_CONFIG does not exist. Readme Failed.")
 ELSEIF ( NOT (fi_cntl_tbl))
  CALL fi_kick_out("CCL definition for table DM_SIZE_DB_CNTL_FILES does not exist. Readme Failed.")
 ELSEIF ( NOT (fi_redo_tbl))
  CALL fi_kick_out("CCL definition for table DM_SIZE_DB_REDO_LOGS does not exist. Readme Failed.")
 ELSEIF ( NOT (fi_rbsegs_tbl))
  CALL fi_kick_out("CCL definition for table DM_SIZE_DB_ROLLBACK_SEGS does not exist. Readme Failed."
   )
 ELSEIF ( NOT (fi_ts_tbl))
  CALL fi_kick_out("CCL definition for table DM_SIZE_DB_TS does not exist. Readme Failed.")
 ENDIF
#2999_exit_validate_tables
#3000_fix_dm_size_db_config
 FOR (fi_i = 1 TO value(fi_env->e_cnt))
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"sequence_cache_entries","3","350")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"shared_pool_size","3","100000000")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"global_names","1","false")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"optimizer_mode","2","rule")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"log_small_entry_max_size","3","0")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"log_checkpoint_interval","3","999999999999")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"log_buffer","3","1638400")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"timed_statistics","1","false")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"sort_direct_writes","1","true")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"db_block_lru_statistics","1","false")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"job_queue_processes","3","5")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"job_queue_interval","3","10")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"sort_write_buffers","3","8")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"sort_area_size","3","5242880")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"sort_area_retained_size","3","5242880")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"enqueue_resources","3","5000")
   CALL fi_fix_initora(fi_env->qual[fi_i].env_id,"control_files","2",
    "(ora_control1,ora_control2,ora_control3,ora_control4)")
 ENDFOR
#3999_exit_fix_dm_size_db_config
#4000_fix_dm_size_db_cntl_files
 FOR (fi_i2 = 1 TO value(fi_env->e_cnt))
   IF ((((fi_env->qual[fi_i2].env_id=801)) OR ((fi_env->qual[fi_i2].env_id=804))) )
    CALL fi_fix_cntl_files(fi_env->qual[fi_i2].env_id,4,"ORA_CONTROL.CON",167772160.00)
   ELSE
    CALL fi_fix_cntl_files(fi_env->qual[fi_i2].env_id,4,"CONTROL",167772160.00)
   ENDIF
 ENDFOR
#4999_exit_fix_dm_size_db_cntl_files
#5000_fix_dm_size_db_redo_logs
 FOR (fi_i3 = 1 TO value(fi_env->e_cnt))
   IF ((((fi_env->qual[fi_i3].env_id=801)) OR ((fi_env->qual[fi_i3].env_id=804))) )
    CALL fi_fix_redo_logs(fi_env->qual[fi_i3].env_id,4,2,"ORA_LOG.RDO",41943040)
   ELSE
    CALL fi_fix_redo_logs(fi_env->qual[fi_i3].env_id,4,2,"oralog",134217728)
   ENDIF
 ENDFOR
#5999_fix_dm_size_db_redo_logs
#6000_fix_dm_size_db_rb_segs
 FOR (fi_i4 = 1 TO value(fi_env->e_cnt))
   CALL fi_fix_rb_segs(fi_env->qual[fi_i4].env_id,"RB01","RB1",5242880,5242880,
    8,249,41943040)
   CALL fi_fix_rb_segs(fi_env->qual[fi_i4].env_id,"RB02","RB2",5242880,5242880,
    8,249,41943040)
   CALL fi_fix_rb_segs(fi_env->qual[fi_i4].env_id,"RB03","RB1",5242880,5242880,
    8,249,41943040)
   CALL fi_fix_rb_segs(fi_env->qual[fi_i4].env_id,"RB04","RB2",5242880,5242880,
    8,249,41943040)
   CALL fi_fix_rb_segs(fi_env->qual[fi_i4].env_id,"RB05","RB1",5242880,5242880,
    8,249,41943040)
   CALL fi_fix_rb_segs(fi_env->qual[fi_i4].env_id,"RB06","RB2",5242880,5242880,
    8,249,41943040)
   CALL fi_fix_rb_segs(fi_env->qual[fi_i4].env_id,"RB07","RB1",5242880,5242880,
    8,249,41943040)
   CALL fi_fix_rb_segs(fi_env->qual[fi_i4].env_id,"RB08","RB2",5242880,5242880,
    8,249,41943040)
 ENDFOR
#6999_exit_fix_dm_size_db_rb_segs
#7000_fix_dm_size_db_ts
 FOR (fi_i5 = 1 TO value(fi_env->e_cnt))
   IF ((((fi_env->qual[fi_i5].env_id=801)) OR ((fi_env->qual[fi_i5].env_id=804))) )
    CALL fi_fix_ts(fi_env->qual[fi_i5].env_id,"TEMP","TEMP_01.DBS",536870912,"TEMP")
   ELSE
    CALL fi_fix_ts(fi_env->qual[fi_i5].env_id,"TEMP","TEMP",536870912,"TEMP")
   ENDIF
 ENDFOR
#7999_exit_fix_dm_size_db_ts
#end_program
 IF (g_error_flag)
  SET readme_data->status = "F"
  CALL echo(readme_data->message)
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Successfully modified parameters in DM_SIZE_* tables. Readme Success."
  CALL echo(readme_data->message)
 ENDIF
 EXECUTE dm_readme_status
END GO
