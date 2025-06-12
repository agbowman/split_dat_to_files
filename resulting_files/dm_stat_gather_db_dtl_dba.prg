CREATE PROGRAM dm_stat_gather_db_dtl:dba
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 IF (validate(gs_client_mneumonic)=0)
  DECLARE gs_client_mneumonic = vc WITH public, noconstant("")
 ENDIF
 IF (validate(gs_node_name)=0)
  DECLARE gs_node_name = vc WITH public, noconstant("")
 ENDIF
 IF (validate(err_msg)=0)
  DECLARE err_msg = vc WITH protect, noconstant("")
 ENDIF
 IF (gs_client_mneumonic <= "")
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="CLIENT MNEMONIC"
   DETAIL
    gs_client_mneumonic = di.info_char
   WITH nocounter
  ;end select
  IF (error(err_msg,0) != 0)
   CALL esmerror(err_msg,esmexit)
  ENDIF
  IF (gs_client_mneumonic <= "")
   SET err_msg = "No client information available"
   CALL esmerror(err_msg,esmexit)
  ENDIF
 ENDIF
 IF (gs_node_name <= "")
  SET gs_node_name = curnode
  IF (gs_node_name <= "")
   SET err_msg = "No node information available"
   CALL esmerror(err_msg,esmexit)
  ENDIF
 ENDIF
 FREE RECORD seq_vals
 RECORD seq_vals(
   1 cnt = i4
   1 qual[*]
     2 id = f8
 ) WITH protect
 FREE RECORD m_dm2_seq_stat
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE ms_snap_shot_type = vc WITH protect, constant("DB_STATS.2")
 DECLARE ds_stat_snap_dt_tm = dq8 WITH protect
 DECLARE dm_stat_cnt = i4
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE mn_debug_ind = i2
 DECLARE md_start_timer = dq8
 DECLARE md_end_timer = dq8
 DECLARE md_start_total_timer = dq8
 DECLARE md_end_total_timer = dq8
 DECLARE sbr_check_debug(null) = null
 DECLARE sbr_debug_timer(ms_input_mode=vc,ms_input_str=vc) = null
 CALL sbr_check_debug(null)
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 CALL sbr_debug_timer("START_TOTAL","DM_STAT_GATHER_DB_DTL")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 IF (validate(dm_stat_gather_dt,999)=999)
  SET ds_stat_snap_dt_tm = cnvtdatetime(curdate,curtime3)
 ELSE
  SET ds_stat_snap_dt_tm = cnvtdatetime(dm_stat_gather_dt)
 ENDIF
 IF (currdb="ORACLE")
  CALL sbr_debug_timer("START","OBTAIN SEQUENCES")
  SET seq_vals->cnt = 1
  EXECUTE dm2_dar_get_bulk_seq "seq_vals->qual", seq_vals->cnt, "ID",
  1, "DM_CLINICAL_SEQ"
  CALL sbr_debug_timer("END","OBTAIN SEQUENCES")
  IF (error(error_msg,0) != 0)
   CALL esmerror(error_msg,esmexit)
  ELSE
   IF ((m_dm2_seq_stat->n_status != 1))
    SET error_msg = concat("Error encountered in DM2_DAR_GET_BULK_SEQ. ",m_dm2_seq_stat->s_error_msg)
    CALL esmerror(error_msg,esmexit)
   ENDIF
  ENDIF
  IF (trim(reqdata->domain)="")
   SET reqdata->domain = " "
  ENDIF
  CALL sbr_debug_timer("START","INSERTING SYSTEM STATISTICS")
  IF ((seq_vals->qual[1].id > 0))
   INSERT  FROM dm_stat_snaps ds
    SET ds.dm_stat_snap_id = seq_vals->qual[1].id, ds.stat_snap_dt_tm = cnvtdatetimeutc(cnvtdatetime(
       ds_stat_snap_dt_tm)), ds.client_mnemonic = gs_client_mneumonic,
     ds.domain_name = reqdata->domain, ds.node_name = gs_node_name, ds.snapshot_type =
     ms_snap_shot_type,
     ds.updt_dt_tm = cnvtdatetime(curdate,curtime3), ds.updt_id = reqinfo->updt_id, ds.updt_task =
     reqinfo->updt_task,
     ds.updt_applctx = reqinfo->updt_applctx, ds.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
    ROLLBACK
    GO TO exit_program
   ENDIF
   IF (curqual > 0)
    INSERT  FROM dm_stat_snaps_values ssv
     (ssv.dm_stat_snap_id, ssv.stat_name, ssv.stat_seq,
     ssv.stat_str_val, ssv.stat_type, ssv.stat_number_val,
     ssv.stat_clob_val, ssv.stat_date_dt_tm, ssv.updt_dt_tm,
     ssv.updt_id, ssv.updt_task, ssv.updt_applctx,
     ssv.updt_cnt)(SELECT
      seq_vals->qual[1].id, vs.name, vs.inst_id,
      vs.inst_id, 1, vs.value,
      "", null, cnvtdatetime(curdate,curtime3),
      reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
      0
      FROM gv$sysstat vs)
     WITH nocounter
    ;end insert
    IF (error(error_msg,0) != 0)
     CALL esmerror(error_msg,esmreturn)
     ROLLBACK
     GO TO exit_program
    ENDIF
    COMMIT
   ENDIF
  ENDIF
  CALL sbr_debug_timer("END","INSERTING SYSTEM STATISTICS")
 ELSE
  CALL sbr_debug_timer("START","POPULATING SYSTEM STATISTICS")
  SELECT INTO "nl:"
   vs.*
   FROM snapshot_database vs
   HEAD REPORT
    dm_stat_cnt = 0, stat = alterlist(dsr->qual,1), stat = alterlist(dsr->qual[1].qual,99),
    dsr->qual[1].snapshot_type = "DB_STATS", dsr->qual[1].stat_snap_dt_tm = cnvtdatetime(
     ds_stat_snap_dt_tm)
   DETAIL
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "SEC_LOG_USED_TOP",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.sec_log_used_top, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "TOT_LOG_USED_TOP",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .tot_log_used_top, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "TOTAL_LOG_USED", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.total_log_used,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "TOTAL_LOG_AVAILABLE",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.total_log_available, dm_stat_cnt = (
    dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "ROWS_READ",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .rows_read, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_DATA_L_READS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_data_l_reads,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_DATA_P_READS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_data_p_reads, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_DATA_WRITES",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .pool_data_writes, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_INDEX_L_READS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_index_l_reads,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_INDEX_P_READS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_index_p_reads, dm_stat_cnt = (
    dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_INDEX_WRITES",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .pool_index_writes, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_READ_TIME", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_read_time,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_WRITE_TIME", dsr
    ->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_write_time, dm_stat_cnt = (dm_stat_cnt+
    1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_ASYNC_INDEX_READS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .pool_async_index_reads, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_DATA_TO_ESTORE", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_data_to_estore,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_INDEX_TO_ESTORE",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_index_to_estore, dm_stat_cnt = (
    dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_INDEX_FROM_ESTORE",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .pool_index_from_estore, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_DATA_FROM_ESTORE", dsr->qual[1].qual[dm_stat_cnt
    ].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_data_from_estore,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name =
    "POOL_ASYNC_DATA_READS", dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_async_data_reads, dm_stat_cnt = (
    dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_ASYNC_DATA_WRITES",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .pool_async_data_writes, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_ASYNC_INDEX_WRITES", dsr->qual[1].qual[
    dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .pool_async_index_writes,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_ASYNC_READ_TIME",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_async_read_time, dm_stat_cnt = (
    dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_ASYNC_WRITE_TIME",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .pool_async_write_time, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_ASYNC_DATA_READ_REQS", dsr->qual[1].qual[
    dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .pool_async_data_read_reqs,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "DIRECT_READS", dsr->
    qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.direct_reads, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "DIRECT_WRITES",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .direct_writes, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "DIRECT_READ_REQS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.direct_read_reqs,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "DIRECT_WRITE_REQS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.direct_write_reqs, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "DIRECT_READ_TIME",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .direct_read_time, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "DIRECT_WRITE_TIME", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.direct_write_time,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name =
    "UNREAD_PREFETCH_PAGES", dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.unread_prefetch_pages, dm_stat_cnt = (
    dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "FILES_CLOSED",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .files_closed, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_LSN_GAP_CLNS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_lsn_gap_clns,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name =
    "POOL_DRTY_PG_STEAL_CLNS", dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pool_drty_pg_steal_clns, dm_stat_cnt = (
    dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "POOL_DRTY_PG_THRSH_CLNS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .pool_drty_pg_thrsh_clns, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "LOCKS_HELD", dsr->qual[1].qual[dm_stat_cnt].stat_type
     = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.locks_held,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "LOCK_WAITS", dsr->
    qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.lock_waits, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "LOCK_WAIT_TIME",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .lock_wait_time, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "LOCK_LIST_IN_USE", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.lock_list_in_use,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "DEADLOCKS", dsr->
    qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.deadlocks, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "LOCK_ESCALS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .lock_escals, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "X_LOCK_ESCALS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.x_lock_escals,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "LOCKS_WAITING", dsr->
    qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.locks_waiting, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "SORT_HEAP_ALLOCATED",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .sort_heap_allocated, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "TOTAL_SORTS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.total_sorts,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "TOTAL_SORT_TIME", dsr
    ->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.total_sort_time, dm_stat_cnt = (dm_stat_cnt+
    1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "SORT_OVERFLOWS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .sort_overflows, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "ACTIVE_SORTS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.active_sorts,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "COMMIT_SQL_STMTS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.commit_sql_stmts, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "ROLLBACK_SQL_STMTS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .rollback_sql_stmts, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "DYNAMIC_SQL_STMTS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.dynamic_sql_stmts,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "STATIC_SQL_STMTS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.static_sql_stmts, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "FAILED_SQL_STMTS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .failed_sql_stmts, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "SELECT_SQL_STMTS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.select_sql_stmts,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "DDL_SQL_STMTS", dsr->
    qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.ddl_sql_stmts, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "UID_SQL_STMTS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .uid_sql_stmts, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "INT_AUTO_REBINDS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.int_auto_rebinds,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "INT_ROWS_DELETED",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.int_rows_deleted, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "INT_ROWS_UPDATED",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .int_rows_updated, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "INT_COMMITS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.int_commits,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "INT_ROLLBACKS", dsr->
    qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.int_rollbacks, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "INT_DEADLOCK_ROLLBACKS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .int_deadlock_rollbacks, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "ROWS_DELETED", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.rows_deleted,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "ROWS_INSERTED", dsr->
    qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.rows_inserted, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "ROWS_UPDATED",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .rows_updated, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "ROWS_SELECTED", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.rows_selected,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "BINDS_PRECOMPILES",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.binds_precompiles, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "TOTAL_CONS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .total_cons, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "APPLS_CUR_CONS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.appls_cur_cons,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "APPLS_IN_DB2", dsr->
    qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.appls_in_db2, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "SEC_LOGS_ALLOCATED",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .sec_logs_allocated, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "DB_STATUS", dsr->qual[1].qual[dm_stat_cnt].stat_type
     = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.db_status,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "LOCK_TIMEOUTS", dsr->
    qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.lock_timeouts, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "CONNECTIONS_TOP",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .connections_top, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "DB_HEAP_TOP", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.db_heap_top,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "INT_ROWS_INSERTED",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.int_rows_inserted, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "LOG_READS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .log_reads, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "LOG_WRITES", dsr->qual[1].qual[dm_stat_cnt].stat_type
     = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.log_writes,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "PKG_CACHE_LOOKUPS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pkg_cache_lookups, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "PKG_CACHE_INSERTS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .pkg_cache_inserts, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "CAT_CACHE_LOOKUPS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.cat_cache_lookups,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "CAT_CACHE_INSERTS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.cat_cache_inserts, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "CAT_CACHE_OVERFLOWS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .cat_cache_overflows, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "CAT_CACHE_HEAP_FULL", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.cat_cache_heap_full,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "CATALOG_PARTITION",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.catalog_partition, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "TOTAL_SEC_CONS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .total_sec_cons, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "NUM_ASSOC_AGENTS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.num_assoc_agents,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "AGENTS_TOP", dsr->
    qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.agents_top, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "COORD_AGENTS_TOP",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .coord_agents_top, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "PREFETCH_WAIT_TIME", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.prefetch_wait_time,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "APPL_SECTION_LOOKUPS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.appl_section_lookups, dm_stat_cnt = (
    dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "APPL_SECTION_INSERTS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .appl_section_inserts, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "TOTAL_HASH_JOINS", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.total_hash_joins,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "TOTAL_HASH_LOOPS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.total_hash_loops, dm_stat_cnt = (dm_stat_cnt
    + 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "HASH_JOIN_OVERFLOWS",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .hash_join_overflows, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "HASH_JOIN_SMALL_OVERFLOWS", dsr->qual[1].qual[
    dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .hash_join_small_overflows,
    dm_stat_cnt = (dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name =
    "PKG_CACHE_NUM_OVERFLOWS", dsr->qual[1].qual[dm_stat_cnt].stat_type = 1,
    dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.pkg_cache_num_overflows, dm_stat_cnt = (
    dm_stat_cnt+ 1), dsr->qual[1].qual[dm_stat_cnt].stat_name = "PKG_CACHE_SIZE_TOP",
    dsr->qual[1].qual[dm_stat_cnt].stat_type = 1, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs
    .pkg_cache_size_top, dm_stat_cnt = (dm_stat_cnt+ 1),
    dsr->qual[1].qual[dm_stat_cnt].stat_name = "DB_CONN_TIME", dsr->qual[1].qual[dm_stat_cnt].
    stat_type = 3, dsr->qual[1].qual[dm_stat_cnt].stat_number_val = vs.db_conn_time
   WITH nocounter
  ;end select
  CALL sbr_debug_timer("END","POPULATING SYSTEM STATISTICS")
  IF (error(error_msg,0) != 0)
   CALL esmerror(error_msg,esmreturn)
  ENDIF
  CALL sbr_debug_timer("START","LOAD SYSTEM STATISTICS")
  EXECUTE dm_stat_snaps_load
  CALL sbr_debug_timer("END","LOAD SYSTEM STATISTICS")
 ENDIF
 CALL esmcheckccl("x")
 SUBROUTINE sbr_debug_timer(ms_input_mode,ms_input_str)
   IF (mn_debug_ind=1)
    CASE (ms_input_mode)
     OF "START":
      SET md_start_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" Starting timer for: ",ms_input_str))
      CALL echo(" Initial memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
     OF "END":
      SET md_end_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" Ending timer for: ",ms_input_str))
      CALL echo(build(" Elapsed time: ",datetimediff(md_end_timer,md_start_timer,5)))
      CALL echo(" Ending memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
      SET md_start_timer = 0
      SET md_end_timer = 0
     OF "START_TOTAL":
      SET md_start_total_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" Starting total timer for: ",ms_input_str))
      CALL echo(" Initial memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
     OF "END_TOTAL":
      SET md_end_total_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" TOTAL execution time for: ",ms_input_str))
      CALL echo(build(" Elapsed time: ",datetimediff(md_end_total_timer,md_start_total_timer,5)))
      CALL echo(" Ending memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
      SET md_start_total_timer = 0
      SET md_end_total_timer = 0
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_check_debug(null)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_STAT_GATHER_DB_DTL"
     AND di.info_name="DEBUG_IND"
    DETAIL
     mn_debug_ind = di.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = 0, di.info_domain = "DM_STAT_GATHER_DB_DTL", di.info_name = "DEBUG_IND"
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
   ENDIF
 END ;Subroutine
#exit_program
 CALL sbr_debug_timer("END_TOTAL","DM_STAT_GATHER_DB_DTL")
END GO
