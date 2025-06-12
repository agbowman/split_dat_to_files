CREATE PROGRAM dm_cbo_plan_overrides:dba
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
 DECLARE sbr_check_debug(null) = null
 DECLARE sbr_debug_timer(ms_input_mode=vc,ms_input_str=vc) = null
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
 FREE RECORD dcpo_baselines
 RECORD dcpo_baselines(
   1 cnt = i4
   1 qual[*]
     2 sql_handle = vc
     2 sql_text = vc
     2 creator = vc
     2 description = vc
     2 created = vc
     2 last_modified = vc
     2 last_executed = vc
     2 enabled = vc
     2 accepted = vc
     2 seq = i4
     2 s_name = vc
     2 q_pos = vc
 ) WITH protect
 FREE RECORD dcpo_grants
 RECORD dcpo_grants(
   1 cnt = i4
   1 scripts[*]
     2 name = vc
     2 overrides_ind = i1
     2 outstring = vc
 ) WITH protect
 FREE RECORD dcpo_grt
 RECORD dcpo_grt(
   1 cnt = i4
   1 qual[*]
     2 script_name = vc
     2 seq = i2
     2 str = vc
 ) WITH protect
 DECLARE ms_baseline = vc WITH protect, constant("ORACLEBASELINE_INFO")
 DECLARE ms_grant = vc WITH protect, constant("CCLSCRIPTGRANT_INFO")
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE mn_debug_ind = i2
 DECLARE md_start_timer = q8
 DECLARE md_end_timer = q8
 DECLARE md_start_total_timer = q8
 DECLARE md_end_total_timer = q8
 DECLARE dcpo_seq_pos = i4 WITH protect, noconstant(0)
 DECLARE dcpo_view_ind = i2 WITH protect, noconstant(0)
 DECLARE dcpo_pos = i4 WITH protect, noconstant(0)
 DECLARE dcpo_pos2 = i4 WITH protect, noconstant(0)
 DECLARE dcpo_s_str = vc WITH protect, noconstant("")
 DECLARE dcpo_q_str = vc WITH protect, noconstant("")
 DECLARE dcpo_t_str = vc WITH protect, noconstant("")
 DECLARE dcpo_fndx = i4 WITH protect, noconstant(0)
 CALL sbr_check_debug(null)
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 CALL sbr_debug_timer("START_TOTAL","DM_CBO_PLAN_OVERRIDES")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 CALL sbr_debug_timer("START","OBTAINING SEQUENCES")
 SET seq_vals->cnt = 2
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
 SELECT INTO "nl:"
  FROM dba_views dv
  WHERE dv.view_name="DBA_SQL_PLAN_BASELINES"
   AND dv.owner="SYS"
  DETAIL
   dcpo_view_ind = 1
  WITH nocounter
 ;end select
 CALL sbr_debug_timer("START","INSERTING BASELINES")
 IF ((seq_vals->qual[1].id > 0))
  IF (dcpo_view_ind > 0)
   SELECT INTO "nl:"
    FROM dba_sql_plan_baselines dp
    WHERE dp.origin="MANUAL-LOAD"
    ORDER BY dp.sql_handle
    HEAD REPORT
     dcpo_baselines->cnt = 0
    HEAD dp.sql_handle
     dcpo_seq_pos = 0
    DETAIL
     dcpo_baselines->cnt = (dcpo_baselines->cnt+ 1), stat = alterlist(dcpo_baselines->qual,
      dcpo_baselines->cnt), dcpo_baselines->qual[dcpo_baselines->cnt].accepted = trim(dp.accepted),
     dcpo_baselines->qual[dcpo_baselines->cnt].created = format(dp.created,";;q"), dcpo_baselines->
     qual[dcpo_baselines->cnt].creator = trim(dp.creator), dcpo_baselines->qual[dcpo_baselines->cnt].
     description = evaluate(size(trim(dp.description)),0,"NONE",trim(dp.description)),
     dcpo_baselines->qual[dcpo_baselines->cnt].enabled = trim(dp.enabled), dcpo_baselines->qual[
     dcpo_baselines->cnt].last_executed = nullcheck(format(dp.last_executed,";;q"),"NEVER",nullind(dp
       .last_executed)), dcpo_baselines->qual[dcpo_baselines->cnt].last_modified = format(dp
      .last_modified,";;q"),
     dcpo_baselines->qual[dcpo_baselines->cnt].sql_handle = trim(dp.sql_handle), dcpo_baselines->
     qual[dcpo_baselines->cnt].sql_text = trim(substring(1,200,dp.sql_text)), dcpo_baselines->qual[
     dcpo_baselines->cnt].seq = dcpo_seq_pos,
     dcpo_seq_pos = (dcpo_seq_pos+ 1)
    WITH nocounter
   ;end select
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
    ROLLBACK
    GO TO exit_program
   ENDIF
  ENDIF
  IF ((validate(dcpo_debug,- (1)) != - (1)))
   CALL echorecord(dcpo_baselines)
  ENDIF
  INSERT  FROM dm_stat_snaps ds
   SET ds.dm_stat_snap_id = seq_vals->qual[1].id, ds.stat_snap_dt_tm = cnvtdatetimeutc(cnvtdatetime((
      curdate - 1),0)), ds.client_mnemonic = gs_client_mneumonic,
    ds.domain_name = trim(substring(1,20,reqdata->domain)), ds.node_name = gs_node_name, ds
    .snapshot_type = ms_baseline,
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
  IF ((dcpo_baselines->cnt > 0))
   FOR (dcpo_fndx = 1 TO dcpo_baselines->cnt)
     IF ((validate(dcpo_debug,- (1)) != - (1)))
      CALL echo(dcpo_baselines->qual[dcpo_fndx].sql_text)
     ENDIF
     SET dcpo_pos = findstring("CCL<",dcpo_baselines->qual[dcpo_fndx].sql_text,1,0)
     SET dcpo_s_str = "NONE"
     SET dcpo_q_str = "NONE"
     IF (dcpo_pos > 0)
      SET dcpo_t_str = substring((dcpo_pos+ 4),size(dcpo_baselines->qual[dcpo_fndx].sql_text),
       dcpo_baselines->qual[dcpo_fndx].sql_text)
      IF ((validate(dcpo_debug,- (1)) != - (1)))
       CALL echo(dcpo_t_str)
      ENDIF
      SET dcpo_pos = findstring(":",dcpo_t_str,1,0)
      SET dcpo_pos2 = findstring("> ",dcpo_t_str,1,1)
      IF (dcpo_pos > 0
       AND dcpo_pos2 > 0)
       SET dcpo_t_str = substring(1,(dcpo_pos2 - 1),dcpo_t_str)
       IF ((validate(dcpo_debug,- (1)) != - (1)))
        CALL echo(dcpo_t_str)
       ENDIF
       SET dcpo_pos2 = findstring(":q",cnvtlower(dcpo_t_str),1,1)
       IF (dcpo_pos2 > 0)
        SET dcpo_s_str = substring(1,(dcpo_pos - 1),dcpo_t_str)
        SET dcpo_q_str = trim(substring((dcpo_pos2+ 2),size(dcpo_t_str),dcpo_t_str))
        IF ((validate(dcpo_debug,- (1)) != - (1)))
         CALL echo(dcpo_s_str)
         CALL echo(dcpo_q_str)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     SET dcpo_baselines->qual[dcpo_fndx].s_name = dcpo_s_str
     SET dcpo_baselines->qual[dcpo_fndx].q_pos = dcpo_q_str
   ENDFOR
   INSERT  FROM dm_stat_snaps_values ssv,
     (dummyt d  WITH seq = value(dcpo_baselines->cnt))
    SET ssv.dm_stat_snap_id = seq_vals->qual[1].id, ssv.stat_name = dcpo_baselines->qual[d.seq].
     sql_handle, ssv.stat_seq = dcpo_baselines->qual[d.seq].seq,
     ssv.stat_str_val = dcpo_baselines->qual[d.seq].sql_text, ssv.stat_type = 2, ssv.stat_number_val
      = 0,
     ssv.stat_clob_val = concat(dcpo_baselines->qual[d.seq].accepted,"||",dcpo_baselines->qual[d.seq]
      .created,"||",dcpo_baselines->qual[d.seq].creator,
      "||",dcpo_baselines->qual[d.seq].enabled,"||",dcpo_baselines->qual[d.seq].description,"||",
      dcpo_baselines->qual[d.seq].last_executed,"||",dcpo_baselines->qual[d.seq].last_modified,"||",
      dcpo_baselines->qual[d.seq].s_name,
      "||",dcpo_baselines->qual[d.seq].q_pos), ssv.stat_date_dt_tm = null, ssv.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     ssv.updt_id = reqinfo->updt_id, ssv.updt_task = reqinfo->updt_task, ssv.updt_applctx = reqinfo->
     updt_applctx,
     ssv.updt_cnt = 0
    PLAN (d)
     JOIN (ssv)
    WITH nocounter
   ;end insert
  ELSE
   INSERT  FROM dm_stat_snaps_values ssv
    SET ssv.dm_stat_snap_id = seq_vals->qual[1].id, ssv.stat_name = "NO_NEW_DATA", ssv.stat_seq = 0,
     ssv.updt_dt_tm = cnvtdatetime(curdate,curtime3), ssv.updt_id = reqinfo->updt_id, ssv.updt_task
      = reqinfo->updt_task,
     ssv.updt_applctx = reqinfo->updt_applctx, ssv.updt_cnt = 0
   ;end insert
  ENDIF
  IF (error(error_msg,0) != 0)
   CALL esmerror(error_msg,esmreturn)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
 ENDIF
 CALL sbr_debug_timer("END","INSERTING BASELINES")
 CALL sbr_debug_timer("START","INSERTING SCRIPT GRANTS")
 IF ((seq_vals->qual[2].id > 0))
  SELECT INTO "nl:"
   object_name = substring(2,30,g.rest), rdboptval = evaluate(substring(274,6,g.data),"<sec1>",ichar(
     substring(248,1,g.data)),0), rdboptqry = evaluate(substring(274,6,g.data),"<sec1>",substring(249,
     25,g.data),fillstring(25,char(0)))
   FROM (dgeneric g  WITH access_code = "5", user_code = none)
   WHERE g.platform="H0000"
    AND g.rcode="5"
    AND g.rest="P*"
    AND evaluate(substring(274,6,g.data),"<sec1>",band(ichar(substring(248,1,g.data)),15),0) BETWEEN
   0 AND 8
   HEAD REPORT
    dcpo_grants->cnt = 0, dcpo_grt->cnt = 0, dcpo_val1 = 0,
    dcpo_val2 = 0, dcpo_val = 0, dcpo_num = 0,
    dcpo_num1 = 0, dcpo_num2 = 0
   DETAIL
    dcpo_grants->cnt = (dcpo_grants->cnt+ 1)
    IF (mod(dcpo_grants->cnt,1000)=1)
     stat = alterlist(dcpo_grants->scripts,(dcpo_grants->cnt+ 999))
    ENDIF
    dcpo_grants->scripts[dcpo_grants->cnt].name = trim(object_name), dcpo_val1 = (band(rdboptval,240)
    / 16), dcpo_val2 = band(rdboptval,15)
    IF ((( NOT (dcpo_val1 IN (0, 8))) OR ( NOT (dcpo_val2 IN (0, 8)))) )
     dcpo_grants->scripts[dcpo_grants->cnt].overrides_ind = 1
    ENDIF
    dcpo_grants->scripts[dcpo_grants->cnt].outstring = concat(dcpo_grants->scripts[dcpo_grants->cnt].
     name,"||",format(dcpo_val2,"#"),"||",format(dcpo_val1,"#"),
     "||")
    FOR (dcpo_num = 1 TO 25)
      dcpo_val = ichar(substring(dcpo_num,1,rdboptqry)), dcpo_num2 = (dcpo_num * 2), dcpo_num1 = (
      dcpo_num2 - 1),
      dcpo_val1 = (band(dcpo_val,240)/ 16), dcpo_val2 = band(dcpo_val,15), dcpo_grants->scripts[
      dcpo_grants->cnt].outstring = concat(dcpo_grants->scripts[dcpo_grants->cnt].outstring,format(
        dcpo_val1,"#"),"||",format(dcpo_val2,"#"))
      IF ((( NOT (dcpo_val1 IN (0, 8))) OR ( NOT (dcpo_val2 IN (0, 8)))) )
       dcpo_grants->scripts[dcpo_grants->cnt].overrides_ind = 1
      ENDIF
      IF (dcpo_num != 25)
       dcpo_grants->scripts[dcpo_grants->cnt].outstring = concat(dcpo_grants->scripts[dcpo_grants->
        cnt].outstring,"||")
      ENDIF
    ENDFOR
   FOOT REPORT
    stat = alterlist(dcpo_grants->scripts,dcpo_grants->cnt)
    IF ((dcpo_grants->cnt > 0))
     FOR (dcpo_num = 1 TO dcpo_grants->cnt)
       IF ((dcpo_grants->scripts[dcpo_num].overrides_ind=1)
        AND size(trim(dcpo_grants->scripts[dcpo_num].outstring,3)) > 0)
        dcpo_grt->cnt = (dcpo_grt->cnt+ 1), stat = alterlist(dcpo_grt->qual,dcpo_grt->cnt), dcpo_grt
        ->qual[dcpo_grt->cnt].script_name = dcpo_grants->scripts[dcpo_num].name,
        dcpo_grt->qual[dcpo_grt->cnt].str = dcpo_grants->scripts[dcpo_num].outstring
       ENDIF
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
  IF (error(error_msg,0) != 0)
   CALL esmerror(error_msg,esmreturn)
   ROLLBACK
   GO TO exit_program
  ENDIF
  IF ((validate(dcpo_debug,- (1)) != - (1)))
   CALL echorecord(dcpo_grt)
  ENDIF
  INSERT  FROM dm_stat_snaps ds
   SET ds.dm_stat_snap_id = seq_vals->qual[2].id, ds.stat_snap_dt_tm = cnvtdatetimeutc(cnvtdatetime((
      curdate - 1),0)), ds.client_mnemonic = gs_client_mneumonic,
    ds.domain_name = trim(substring(1,20,reqdata->domain)), ds.node_name = gs_node_name, ds
    .snapshot_type = ms_grant,
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
  IF ((dcpo_grt->cnt > 0))
   INSERT  FROM dm_stat_snaps_values ssv,
     (dummyt d  WITH seq = value(dcpo_grt->cnt))
    SET ssv.dm_stat_snap_id = seq_vals->qual[2].id, ssv.stat_name = dcpo_grt->qual[d.seq].script_name,
     ssv.stat_seq = dcpo_grt->qual[d.seq].seq,
     ssv.stat_type = 2, ssv.stat_number_val = 0, ssv.stat_clob_val = dcpo_grt->qual[d.seq].str,
     ssv.stat_date_dt_tm = null, ssv.updt_dt_tm = cnvtdatetime(curdate,curtime3), ssv.updt_id =
     reqinfo->updt_id,
     ssv.updt_task = reqinfo->updt_task, ssv.updt_applctx = reqinfo->updt_applctx, ssv.updt_cnt = 0
    PLAN (d)
     JOIN (ssv)
    WITH nocounter
   ;end insert
  ELSE
   INSERT  FROM dm_stat_snaps_values ssv
    SET ssv.dm_stat_snap_id = seq_vals->qual[2].id, ssv.stat_name = "NO_NEW_DATA", ssv.stat_seq = 0,
     ssv.updt_dt_tm = cnvtdatetime(curdate,curtime3), ssv.updt_id = reqinfo->updt_id, ssv.updt_task
      = reqinfo->updt_task,
     ssv.updt_applctx = reqinfo->updt_applctx, ssv.updt_cnt = 0
   ;end insert
  ENDIF
  IF (error(error_msg,0) != 0)
   CALL esmerror(error_msg,esmreturn)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
 ENDIF
 CALL sbr_debug_timer("END","INSERTING SCRIPT GRANTS")
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
    WHERE di.info_domain="DM_STATS_CBO_INFO"
     AND di.info_name="DEBUG_IND"
    DETAIL
     mn_debug_ind = di.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = 0, di.info_domain = "DM_STATS_CBO_INFO", di.info_name = "DEBUG_IND"
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
   ENDIF
 END ;Subroutine
#exit_program
 CALL sbr_debug_timer("END_TOTAL","DM_CBO_PLAN_OVERRIDES")
END GO
