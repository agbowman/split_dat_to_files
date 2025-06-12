CREATE PROGRAM dm_stat_gather_db_info:dba
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
 DECLARE ds_cnt = i4 WITH protect, noconstant(0)
 DECLARE ds_cnt2 = i4 WITH protect, noconstant(0)
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
 DECLARE ms_table = vc WITH protect, constant("TABLE_INFO.2")
 DECLARE ms_index = vc WITH protect, constant("INDEX_INFO.2")
 DECLARE ms_db_config = vc WITH protect, constant("DB_CONFIG.2")
 DECLARE ms_seq_check = vc WITH protect, constant("SEQUENCE_VALUE_CHECK.2")
 DECLARE ms_column_info = vc WITH protect, constant("COLUMN_INFO.2")
 DECLARE ms_table_mod = vc WITH protect, constant("TABLE_MOD_INFO.2")
 DECLARE ms_db_ident = vc WITH protect, constant("DB_NODE_IDENT")
 FREE DEFINE tmp_str
 DECLARE tmp_str = vc
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE mn_debug_ind = i2
 DECLARE md_start_timer = q8
 DECLARE md_end_timer = q8
 DECLARE md_start_total_timer = q8
 DECLARE md_end_total_timer = q8
 DECLARE sbr_check_debug(null) = null
 DECLARE sbr_debug_timer(ms_input_mode=vc,ms_input_str=vc) = null
 CALL sbr_check_debug(null)
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 CALL sbr_debug_timer("START_TOTAL","DM_STAT_GATHER_DB_INFO")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 CALL sbr_debug_timer("START","OBTAINING SEQUENCES")
 SET seq_vals->cnt = 6
 EXECUTE dm2_dar_get_bulk_seq "seq_vals->qual", seq_vals->cnt, "ID",
 1, "DM_CLINICAL_SEQ"
 CALL sbr_debug_timer("END","OBTAINING SEQUENCES")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmexit)
 ELSE
  IF ((m_dm2_seq_stat->n_status != 1))
   SET error_msg = concat("Error encountered in DM2_DAR_GET_BULK_SEQ. ",m_dm2_seq_stat->s_error_msg)
   CALL esmerror(error_msg,esmexit)
  ENDIF
 ENDIF
 CALL sbr_debug_timer("START","INSERTING TABLE SIZE DATA")
 IF ((seq_vals->qual[1].id > 0))
  INSERT  FROM dm_stat_snaps ds
   SET ds.dm_stat_snap_id = seq_vals->qual[1].id, ds.stat_snap_dt_tm = cnvtdatetimeutc(cnvtdatetime(
      curdate,curtime3)), ds.client_mnemonic = gs_client_mneumonic,
    ds.domain_name = reqdata->domain, ds.node_name = gs_node_name, ds.snapshot_type = ms_table,
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
   SET tmp_str = concat("decode(ut.num_rows, -1, null,ut.blocks)||','||",
    "decode(ut.num_rows, -1, null, ut.num_rows)||','||",
    "decode(ut.num_rows, -1, null,ut.avg_row_len)||','||")
   SET tmp_str = concat(tmp_str,"to_char(ut.last_analyzed,'YYYYMMDDHH24MISS')||','||")
   SET tmp_str = concat(tmp_str,"ut.tablespace_name||','||ut.owner")
   INSERT  FROM dm_stat_snaps_values ssv
    (ssv.dm_stat_snap_id, ssv.stat_name, ssv.stat_seq,
    ssv.stat_str_val, ssv.stat_type, ssv.stat_number_val,
    ssv.stat_clob_val, ssv.stat_date_dt_tm, ssv.updt_dt_tm,
    ssv.updt_id, ssv.updt_task, ssv.updt_applctx,
    ssv.updt_cnt)(SELECT
     seq_vals->qual[1].id, trim(cnvtupper(ut.table_name),3), mod(dm_clinical_seq.nextval,1000000000),
     sqlpassthru(tmp_str), 2, 0,
     "", null, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
     0
     FROM dba_tables ut
     WHERE  NOT (ut.owner IN ("SYS", "SYSTEM", "OUTLN", "DBSNMP", "CSMIG",
     "XDB"))
     WITH nocounter)
   ;end insert
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
    ROLLBACK
    GO TO exit_program
   ENDIF
   COMMIT
  ENDIF
 ENDIF
 CALL sbr_debug_timer("END","INSERTING TABLE SIZE DATA")
 CALL sbr_debug_timer("START","INSERTING DB CONFIG DATA")
 IF ((seq_vals->qual[2].id > 0))
  INSERT  FROM dm_stat_snaps ds
   SET ds.dm_stat_snap_id = seq_vals->qual[2].id, ds.stat_snap_dt_tm = cnvtdatetimeutc(cnvtdatetime(
      curdate,curtime3)), ds.client_mnemonic = gs_client_mneumonic,
    ds.domain_name = reqdata->domain, ds.node_name = gs_node_name, ds.snapshot_type = ms_db_config,
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
     seq_vals->qual[2].id, p.name, 0,
     "", 2, 0,
     p.value, null, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
     0
     FROM v$parameter p)
    WITH nocounter
   ;end insert
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
    ROLLBACK
    GO TO exit_program
   ENDIF
   INSERT  FROM dm_stat_snaps_values ssv
    (ssv.dm_stat_snap_id, ssv.stat_name, ssv.stat_seq,
    ssv.stat_str_val, ssv.stat_type, ssv.stat_number_val,
    ssv.stat_clob_val, ssv.stat_date_dt_tm, ssv.updt_dt_tm,
    ssv.updt_id, ssv.updt_task, ssv.updt_applctx,
    ssv.updt_cnt)(SELECT
     seq_vals->qual[2].id, "ORACLE VERSION", 0,
     "", 2, 0,
     vi.version, null, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
     0
     FROM v$instance vi)
    WITH nocounter
   ;end insert
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
    ROLLBACK
    GO TO exit_program
   ENDIF
   INSERT  FROM dm_stat_snaps_values ssv
    (ssv.dm_stat_snap_id, ssv.stat_name, ssv.stat_seq,
    ssv.stat_str_val, ssv.stat_type, ssv.stat_number_val,
    ssv.stat_clob_val, ssv.stat_date_dt_tm, ssv.updt_dt_tm,
    ssv.updt_id, ssv.updt_task, ssv.updt_applctx,
    ssv.updt_cnt)(SELECT
     seq_vals->qual[2].id, concat("[NLS_PARAM] ",np.parameter), 0,
     "", 2, 0,
     np.value, null, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
     0
     FROM v$nls_parameters np)
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
 CALL sbr_debug_timer("END","INSERTING DB CONFIG DATA")
 CALL sbr_debug_timer("START","INSERTING SEQUENCE VALUE CHECK DATA TO DM_STAT_SNAPS")
 IF ((seq_vals->qual[3].id > 0))
  INSERT  FROM dm_stat_snaps ds
   SET ds.dm_stat_snap_id = seq_vals->qual[3].id, ds.stat_snap_dt_tm = cnvtdatetimeutc(cnvtdatetime(
      curdate,curtime3)), ds.client_mnemonic = gs_client_mneumonic,
    ds.domain_name = reqdata->domain, ds.node_name = gs_node_name, ds.snapshot_type = ms_seq_check,
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
     seq_vals->qual[3].id, s.sequence_name, 0,
     "", 1, (s.last_number - s.cache_size),
     "", null, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
     0
     FROM user_sequences s
     WHERE s.last_number > 1
      AND ((s.last_number - s.cache_size) > 0))
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
 CALL sbr_debug_timer("END","INSERTING SEQUENCE VALUE CHECK DATA TO DM_STAT_SNAPS")
 CALL sbr_debug_timer("START","INSERTING DB Table Mod DATA")
 IF ((seq_vals->qual[4].id > 0))
  INSERT  FROM dm_stat_snaps ds
   SET ds.dm_stat_snap_id = seq_vals->qual[4].id, ds.stat_snap_dt_tm = cnvtdatetimeutc(cnvtdatetime(
      curdate,curtime3)), ds.client_mnemonic = gs_client_mneumonic,
    ds.domain_name = reqdata->domain, ds.node_name = gs_node_name, ds.snapshot_type = ms_table_mod,
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
   SET tmp_str = "utm.inserts||','||utm.updates||','||utm.deletes||','||utm.truncated||','||"
   SET tmp_str = concat(tmp_str,"to_char(utm.timestamp,'YYYYMMDDHH24MISS')||','||")
   SET tmp_str = concat(tmp_str,"utm.table_owner")
   INSERT  FROM dm_stat_snaps_values ssv
    (ssv.dm_stat_snap_id, ssv.stat_name, ssv.stat_seq,
    ssv.stat_str_val, ssv.stat_type, ssv.stat_number_val,
    ssv.stat_clob_val, ssv.stat_date_dt_tm, ssv.updt_dt_tm,
    ssv.updt_id, ssv.updt_task, ssv.updt_applctx,
    ssv.updt_cnt)(SELECT
     seq_vals->qual[4].id, trim(cnvtupper(utm.table_name),3), mod(dm_clinical_seq.nextval,1000000000),
     sqlpassthru(tmp_str), 2, 0,
     "", null, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
     0
     FROM all_tab_modifications utm
     WHERE  NOT (utm.table_owner IN ("SYS", "SYSTEM", "OUTLN", "DBSNMP", "CSMIG",
     "XDB")))
    WITH nocounter
   ;end insert
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
    ROLLBACK
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 COMMIT
 CALL sbr_debug_timer("END","INSERTING DB Table Mod DATA")
 CALL sbr_debug_timer("START","INSERTING INDEX SIZE DATA")
 IF ((seq_vals->qual[5].id > 0))
  INSERT  FROM dm_stat_snaps ds
   SET ds.dm_stat_snap_id = seq_vals->qual[5].id, ds.stat_snap_dt_tm = cnvtdatetimeutc(cnvtdatetime(
      curdate,curtime3)), ds.client_mnemonic = gs_client_mneumonic,
    ds.domain_name = reqdata->domain, ds.node_name = gs_node_name, ds.snapshot_type = ms_index,
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
   SET tmp_str = concat("decode(ui.num_rows, -1, null,ui.leaf_blocks)||','||",
    "decode(ui.num_rows, -1, null, ui.num_rows)||','||",
    "decode(ui.num_rows, -1, null, ui.distinct_keys)||','||",
    "decode(ui.num_rows, -1, null, ui.blevel)||','||",
    "decode(ui.num_rows, -1, null, ui.avg_leaf_blocks_per_key)||','||",
    "decode(ui.num_rows, -1, null, ui.avg_data_blocks_per_key)||','||",
    "decode(ui.num_rows, -1, null, ui.clustering_factor)||','||",
    "decode(ui.num_rows, -1, null, ui.sample_size)||','||")
   SET tmp_str = concat(tmp_str,"to_char(ui.last_analyzed,'YYYYMMDDHH24MISS')||','||")
   SET tmp_str = concat(tmp_str,"ui.tablespace_name||','||ui.owner")
   INSERT  FROM dm_stat_snaps_values ssv
    (ssv.dm_stat_snap_id, ssv.stat_name, ssv.stat_seq,
    ssv.stat_str_val, ssv.stat_type, ssv.stat_number_val,
    ssv.stat_clob_val, ssv.stat_date_dt_tm, ssv.updt_dt_tm,
    ssv.updt_id, ssv.updt_task, ssv.updt_applctx,
    ssv.updt_cnt)(SELECT
     seq_vals->qual[5].id, concat(trim(cnvtupper(ui.index_name),3),":",trim(cnvtupper(ui.table_name),
       3)), mod(dm_clinical_seq.nextval,1000000000),
     "", 2, 0,
     sqlpassthru(tmp_str), null, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
     0
     FROM dba_indexes ui
     WHERE ui.last_analyzed IS NOT null
      AND  NOT (ui.owner IN ("SYS", "SYSTEM", "OUTLN", "DBSNMP", "CSMIG",
     "XDB")))
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
 CALL sbr_debug_timer("END","INSERTING INDEX SIZE DATA")
 CALL sbr_debug_timer("START","INSERTING DB COLUMN DATA")
 IF ((seq_vals->qual[6].id > 0))
  INSERT  FROM dm_stat_snaps ds
   SET ds.dm_stat_snap_id = seq_vals->qual[6].id, ds.stat_snap_dt_tm = cnvtdatetimeutc(cnvtdatetime(
      curdate,curtime3)), ds.client_mnemonic = gs_client_mneumonic,
    ds.domain_name = reqdata->domain, ds.node_name = gs_node_name, ds.snapshot_type = ms_column_info,
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
   SET tmp_str = concat("decode(ut.num_rows, -1, null, utc.num_distinct)||','||",
    "decode(ut.num_rows, -1, null, utc.density)||','||",
    "decode(ut.num_rows, -1, null, utc.num_nulls)||','||",
    "decode(ut.num_rows, -1, null, utc.num_buckets)||','||",
    "decode(ut.num_rows, -1, null, utc.sample_size)||','||",
    "decode(ut.num_rows, -1, null, utc.avg_col_len)||','||")
   SET tmp_str = concat(tmp_str,"to_char(utc.last_analyzed,'YYYYMMDDHH24MISS')")
   INSERT  FROM dm_stat_snaps_values ssv
    (ssv.dm_stat_snap_id, ssv.stat_name, ssv.stat_seq,
    ssv.stat_str_val, ssv.stat_type, ssv.stat_number_val,
    ssv.stat_clob_val, ssv.stat_date_dt_tm, ssv.updt_dt_tm,
    ssv.updt_id, ssv.updt_task, ssv.updt_applctx,
    ssv.updt_cnt)(SELECT
     seq_vals->qual[6].id, concat(trim(cnvtupper(utc.column_name),3),":",trim(cnvtupper(utc
        .table_name),3)), mod(dm_clinical_seq.nextval,1000000000),
     sqlpassthru(tmp_str), 2, 0,
     "", null, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
     0
     FROM dba_tab_cols utc,
      dba_tables ut
     WHERE ut.table_name=utc.table_name
      AND  NOT (ut.owner IN ("SYS", "SYSTEM", "OUTLN", "DBSNMP", "CSMIG",
     "XDB")))
    WITH nocounter
   ;end insert
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
    ROLLBACK
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 COMMIT
 CALL sbr_debug_timer("END","INSERTING DB COLUMN DATA")
 CALL sbr_debug_timer("START","INSERTING DB_NODE_IDENT DATA")
 SET ds_cnt2 = 0
 SELECT INTO "nl:"
  stat_seq = a.instance_number, hostname = build(cnvtupper(a.host_name)), hosttype = currdbsys,
  parallel = a.parallel
  FROM gv$instance a
  ORDER BY a.instance_number
  HEAD REPORT
   ds_cnt = (ds_cnt+ 1), stat = alterlist(dsr->qual,ds_cnt), dsr->qual[ds_cnt].snapshot_type =
   ms_db_ident,
   dsr->qual[ds_cnt].stat_snap_dt_tm = cnvtdatetime((curdate - 1),0)
  DETAIL
   ds_cnt2 = (ds_cnt2+ 1)
   IF (mod(ds_cnt2,10)=1)
    stat = alterlist(dsr->qual[ds_cnt].qual,(ds_cnt2+ 9))
   ENDIF
   dsr->qual[ds_cnt].qual[ds_cnt2].stat_name = "DB_NODE_INFO", dsr->qual[ds_cnt].qual[ds_cnt2].
   stat_str_val = build(hosttype,"||",hostname,"||",parallel), dsr->qual[ds_cnt].qual[ds_cnt2].
   stat_seq = stat_seq
  FOOT REPORT
   ds_cnt2 = (ds_cnt2+ 1)
   IF (mod(ds_cnt2,10)=1)
    stat = alterlist(dsr->qual[ds_cnt].qual,ds_cnt2)
   ENDIF
   dsr->qual[ds_cnt].qual[ds_cnt2].stat_name = "CCLVERSION", dsr->qual[ds_cnt].qual[ds_cnt2].
   stat_str_val = build(currev,"||",currevminor,"||",currevminor2), dsr->qual[ds_cnt].qual[ds_cnt2].
   stat_seq = 1,
   stat = alterlist(dsr->qual[ds_cnt].qual,ds_cnt2)
  WITH nocounter
 ;end select
 CALL sbr_debug_timer("END","INSERTING DB_NODE_IDENT DATA")
 EXECUTE dm_stat_snaps_load
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
    WHERE di.info_domain="DM_STAT_GATHER_DB_INFO"
     AND di.info_name="DEBUG_IND"
    DETAIL
     mn_debug_ind = di.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = 0, di.info_domain = "DM_STAT_GATHER_DB_INFO", di.info_name = "DEBUG_IND"
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
   ENDIF
 END ;Subroutine
#exit_program
 CALL sbr_debug_timer("END_TOTAL","DM_STAT_GATHER_DB_INFO")
END GO
