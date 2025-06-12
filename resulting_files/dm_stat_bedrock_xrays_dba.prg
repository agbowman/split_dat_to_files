CREATE PROGRAM dm_stat_bedrock_xrays:dba
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
 DECLARE ms_last_run_time = dq8
 DECLARE ms_this_run_time = dq8 WITH constant(cnvtdatetime((curdate - 1),235959))
 DECLARE ms_info_domain = vc WITH constant("DM_STAT_BEDROCK_XRAYS.2")
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE ds_cnt = i4
 DECLARE mn_debug_ind = i2
 DECLARE md_start_timer = dq8
 DECLARE md_end_timer = dq8
 DECLARE md_start_total_timer = dq8
 DECLARE md_end_total_timer = dq8
 DECLARE gatheroverride = i2 WITH noconstant(0)
 RANGE OF b IS br_rec
 IF (validate(b.curr_override_note)=1)
  IF (validate(b.override_mean)=1)
   SET gatheroverride = 1
  ENDIF
 ENDIF
 FREE RANGE b
 DECLARE sbr_check_debug(null) = null
 DECLARE sbr_debug_timer(ms_input_mode=vc,ms_input_str=vc) = null
 CALL sbr_check_debug(null)
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 CALL sbr_debug_timer("START_TOTAL","DM_STAT_BEDROCK_XRAY")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=ms_info_domain
   AND di.info_name="LAST_RUN_TIME"
  DETAIL
   ms_last_run_time = di.info_date
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = ms_info_domain, di.info_name = "LAST_RUN_TIME", di.info_date = cnvtdatetime(
     "01-JAN-1800 00:00:00")
   WITH nocounter
  ;end insert
  DELETE  FROM dm_info di
   WHERE di.info_domain="DM_STAT_BEDROCK_XRAYS"
  ;end delete
  COMMIT
  SET ms_last_run_time = cnvtdatetime("01-JAN-1800 00:00:00")
 ENDIF
 CALL sbr_debug_timer("START","INSERTING BEDROCK DATA")
 IF (gatheroverride=0)
  SELECT INTO "nl:"
   b_rec_meaning = trim(b.rec_mean), b_program_name = trim(b.program_name), b.override_ind,
   bh.run_status_flag, bh.run_dt_tm
   FROM br_rec b,
    br_rec_history bh
   PLAN (b
    WHERE b.active_ind=1)
    JOIN (bh
    WHERE bh.rec_id=b.rec_id
     AND bh.run_dt_tm >= cnvtdatetime(ms_last_run_time)
     AND bh.run_dt_tm < cnvtdatetime(ms_this_run_time))
   HEAD REPORT
    stat = alterlist(dsr->qual,1), dsr->qual[1].snapshot_type = "BEDROCK_COMPLIANCE", dsr->qual[1].
    stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
    ds_cnt = 0
   DETAIL
    ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[1].qual[ds_cnt].stat_name = build(b_rec_meaning,"-",b_program_name), dsr->qual[1].qual[
    ds_cnt].stat_type = 2, dsr->qual[1].qual[ds_cnt].stat_clob_val = build("override_ind||",b
     .override_ind,"||run_status_flag||",bh.run_status_flag,"||run_date||",
     format(bh.run_dt_tm,"YYYYMMDDHHMMSS;;D"))
   FOOT REPORT
    IF (ds_cnt=0)
     stat = alterlist(dsr->qual[1].qual,1), dsr->qual[1].qual[1].stat_name = "NO_NEW_DATA"
    ELSE
     stat = alterlist(dsr->qual[1].qual,ds_cnt)
    ENDIF
   WITH nullreport, nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   b_rec_meaning = trim(b.rec_mean), b_program_name = trim(b.program_name), b.override_ind,
   bh.run_status_flag, bh.run_dt_tm, blt_long_text = substring(0,3000,trim(blt.long_text)),
   br_override_mean = trim(b.override_mean)
   FROM br_rec b,
    br_rec_history bh,
    br_name_value bnv,
    br_long_text blt
   PLAN (b
    WHERE b.active_ind=1)
    JOIN (bh
    WHERE bh.rec_id=b.rec_id
     AND bh.run_dt_tm >= cnvtdatetime(ms_last_run_time)
     AND bh.run_dt_tm < cnvtdatetime(ms_this_run_time))
    JOIN (bnv
    WHERE bnv.br_name_value_id=outerjoin(b.curr_override_note))
    JOIN (blt
    WHERE blt.long_text_id=outerjoin(cnvtint(bnv.br_value)))
   HEAD REPORT
    stat = alterlist(dsr->qual,1), dsr->qual[1].snapshot_type = "BEDROCK_COMPLIANCE.2", dsr->qual[1].
    stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
    ds_cnt = 0
   DETAIL
    ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[1].qual[ds_cnt].stat_name = build(b_rec_meaning,"-",b_program_name), dsr->qual[1].qual[
    ds_cnt].stat_type = 2, dsr->qual[1].qual[ds_cnt].stat_clob_val = build("override_ind||",b
     .override_ind,"||run_status_flag||",bh.run_status_flag,"||run_date||",
     format(bh.run_dt_tm,"YYYYMMDDHHMMSS;;D"),"||override_mean||",br_override_mean,"||long_text||",
     blt_long_text)
   FOOT REPORT
    IF (ds_cnt=0)
     stat = alterlist(dsr->qual[1].qual,1), dsr->qual[1].qual[1].stat_name = "NO_NEW_DATA"
    ELSE
     stat = alterlist(dsr->qual[1].qual,ds_cnt)
    ENDIF
   WITH nullreport, nocounter
  ;end select
  IF (error(error_msg,0) != 0)
   CALL esmerror(error_msg,esmreturn)
   GO TO exit_program
  ENDIF
 ENDIF
 CALL sbr_debug_timer("END","INSERTING BEDROCK DATA")
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(ms_this_run_time)
  WHERE di.info_domain=ms_info_domain
   AND di.info_name="LAST_RUN_TIME"
  WITH nocounter
 ;end update
 CALL sbr_debug_timer("START","INSERTING DATA TO DB")
 EXECUTE dm_stat_snaps_load
 CALL sbr_debug_timer("END","INSERTING DATA TO DB")
 COMMIT
 GO TO exit_program
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
 CALL sbr_debug_timer("END_TOTAL","DM_STAT_BEDROCK_XRAY")
END GO
