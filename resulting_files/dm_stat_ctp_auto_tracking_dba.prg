CREATE PROGRAM dm_stat_ctp_auto_tracking:dba
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
 DECLARE dsvm_error(msg=vc) = null WITH protect
 RECORD ctp_stats(
   1 cnt = i4
   1 qual[*]
     2 ctp_auto_tracking_id = f8
 ) WITH protect
 DECLARE ctp_info_domain = vc WITH protect, constant(curprog)
 DECLARE ctp_snapshot_type = vc WITH protect, constant("CTP_AUTO_TRACKING")
 DECLARE ctp_stat_name = vc WITH protect, constant("CTP_AUTO_TRACKING")
 DECLARE no_new_data = vc WITH protect, constant("NO_NEW_DATA")
 DECLARE table_not_found = vc WITH protect, constant("TABLE_NOT_FOUND")
 DECLARE delim = vc WITH protect, constant("||")
 DECLARE ds_end_snapshot = dq8 WITH protect, constant(cnvtdatetime(curdate,0))
 DECLARE ds_begin_snapshot = dq8 WITH protect, noconstant(0)
 DECLARE dm_insert_ind = i2 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 IF (checkdic("CTP_AUTO_TRACKING","T",0)=false)
  SET stat = alterlist(dsr->qual,1)
  SET dsr->qual[1].snapshot_type = ctp_snapshot_type
  SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime((curdate - 1),0)
  SET stat = alterlist(dsr->qual[1].qual,1)
  SET dsr->qual[1].qual[1].stat_name = table_not_found
  GO TO snaps_load
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=ctp_info_domain
   AND di.info_name="DS_END_SNAPSHOT"
  DETAIL
   ds_begin_snapshot = di.info_date
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ds_begin_snapshot = cnvtdatetime("01-JAN-1800 00:00:00")
  INSERT  FROM dm_info di
   SET di.info_domain = ctp_info_domain, di.info_name = "DS_END_SNAPSHOT", di.info_date =
    cnvtdatetime(ds_begin_snapshot),
    di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(sysdate),
    di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  CALL dsvm_error("CTP_AUTO_TRACKING - DM_INFO INSERT")
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM ctp_auto_tracking cat
  PLAN (cat
   WHERE cat.updt_dt_tm >= cnvtdatetime(ds_begin_snapshot)
    AND cat.updt_dt_tm < cnvtdatetime(ds_end_snapshot))
  ORDER BY cat.ctp_auto_tracking_id
  HEAD REPORT
   stat = alterlist(dsr->qual,1), dsr->qual[1].snapshot_type = ctp_snapshot_type, dsr->qual[1].
   stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=1)
    stat = alterlist(dsr->qual[1].qual,(cnt+ 99)), stat = alterlist(ctp_stats->qual,(cnt+ 99))
   ENDIF
   dsr->qual[1].qual[cnt].stat_name = ctp_stat_name, dsr->qual[1].qual[cnt].stat_seq = (cnt - 1), dsr
   ->qual[1].qual[cnt].stat_clob_val = build(cnvtstring(cat.ctp_auto_tracking_id,17,1),delim,cat
    .automationid,delim,cat.run_script,
    delim,cat.import_script,delim,format(cat.start_dt_tm,"YYYYMMDDHHMMSS;;q"),delim,
    format(cat.end_dt_tm,"YYYYMMDDHHMMSS;;q"),delim,cat.rows_processed,delim,cat.rows_built,
    delim,cat.rows_with_errors,delim,cat.batch_size,delim,
    cat.import_file,delim,cat.log_file,delim,cat.client_mnemonic,
    delim,cat.logical_domain_mnemonic,delim,cnvtstring(cat.logical_domain_id,17,1),delim,
    cat.domain,delim,cat.node,delim,cat.production_ind,
    delim,cat.server,delim,cat.active_ind,delim,
    cat.username,delim,cnvtstring(cat.user_id,17,1),delim,cat.last_ccl_revisor,
    delim,format(cat.last_ccl_revision_dt_tm,"YYYYMMDDHHMMSS;;q")),
   ctp_stats->qual[cnt].ctp_auto_tracking_id = cat.ctp_auto_tracking_id
  FOOT REPORT
   IF (cnt=0)
    stat = alterlist(dsr->qual[1].qual,1), dsr->qual[1].qual[1].stat_name = no_new_data
   ELSE
    stat = alterlist(dsr->qual[1].qual,cnt), ctp_stats->cnt = cnt, stat = alterlist(ctp_stats->qual,
     cnt)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("CTP_AUTO_TRACKING - GATHER STATS")
 IF ((dsr->qual[1].qual[1].stat_name != no_new_data))
  IF (checkdic("CTP_AUTO_TRACKING.ASSOCIATEID","A",0)=2)
   SELECT
    IF ((ctp_stats->cnt > 200))
     WITH nocounter, expand = 2
    ELSE
    ENDIF
    INTO "nl:"
    FROM ctp_auto_tracking cat
    PLAN (cat
     WHERE expand(index,1,ctp_stats->cnt,cat.ctp_auto_tracking_id,ctp_stats->qual[index].
      ctp_auto_tracking_id))
    DETAIL
     pos = locatevalsort(index,1,ctp_stats->cnt,cat.ctp_auto_tracking_id,ctp_stats->qual[index].
      ctp_auto_tracking_id)
     IF (pos > 0)
      dsr->qual[1].qual[pos].stat_clob_val = build(dsr->qual[1].qual[pos].stat_clob_val,delim,cat
       .associateid,delim,cat.last_macro_revisor,
       delim,format(cat.last_macro_revision_dt_tm,"YYYYMMDDHHMMSS;;q"),delim,cat.note)
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   FOR (index = 1 TO size(dsr->qual[1].qual,5))
     SET dsr->qual[1].qual[index].stat_clob_val = build(dsr->qual[1].qual[index].stat_clob_val,
      fillstring(4,delim))
   ENDFOR
  ENDIF
 ENDIF
 CALL dsvm_error("CTP_AUTO_TRACKING - GATHER STATS MOD 1")
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(ds_end_snapshot), di.updt_applctx = reqinfo->updt_applctx, di
   .updt_cnt = (di.updt_cnt+ 1),
   di.updt_dt_tm = cnvtdatetime(sysdate), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
   updt_task
  WHERE di.info_domain=ctp_info_domain
   AND di.info_name="DS_END_SNAPSHOT"
  WITH nocounter
 ;end update
 CALL dsvm_error("CTP_AUTO_TRACKING - DM_INFO UPDATE")
 IF (curqual=0)
  ROLLBACK
  SET stat = alterlist(dsr->qual,1)
  SET dsr->qual[1].snapshot_type = ctp_snapshot_type
  SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime((curdate - 1),0)
  SET stat = alterlist(dsr->qual[1].qual,1)
  SET dsr->qual[1].qual[1].stat_name = "DM_INFO_UPDATE_ERROR"
 ELSE
  COMMIT
 ENDIF
#snaps_load
 EXECUTE dm_stat_snaps_load
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132 WITH protect, noconstant(" ")
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
   GO TO exit_program
  ENDIF
 END ;Subroutine
#exit_program
 SET last_mod = "000 05/28/15 CJ012163 Initial Release"
END GO
