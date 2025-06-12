CREATE PROGRAM dm_stat_lighthouse_measures:dba
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
 DECLARE ms_snapshot_type = vc WITH protect, constant("LIGHTHOUSE_MEASURES")
 DECLARE ms_info_domain = vc WITH constant("dm_stat_lighthouse_measures")
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE ds_cnt = i4
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
 CALL sbr_debug_timer("START_TOTAL","dm_stat_lighthouse_measures")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 CALL sbr_debug_timer("START","INSERTING LIGHTHOUSE DATA")
 SET stat = alterlist(dsr->qual,1)
 SET dsr->qual[1].snapshot_type = ms_snapshot_type
 SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime((curdate - 1),0)
 IF (checkprg("LH_LOAD_LIGHTSON_METRICS"))
  SELECT INTO "nl:"
   condition = trim(llm.condition), condition_meaning = trim(llm.condition_meaning), metric_name =
   trim(llm.metric_name),
   metric_name_meaning = trim(llm.metric_name_meaning), llm.lighthouse_goal, llm.client_target,
   llm.numerator, llm.denominator, nurse_unit = trim(llm.nurse_unit),
   building = trim(llm.building), facility = trim(llm.facility), llm.discharge_month,
   llm.discharge_year, llm.logical_domain_id, version = llm.version
   FROM lh_lightson_metrics llm
   HEAD REPORT
    ds_cnt = 0
   DETAIL
    ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[1].qual[ds_cnt].stat_name = "LIGHTHOUSE_MEASURES", dsr->qual[1].qual[ds_cnt].stat_type
     = 2, dsr->qual[1].qual[ds_cnt].stat_seq = (ds_cnt - 1),
    dsr->qual[1].qual[ds_cnt].stat_clob_val = build(condition,"||",condition_meaning,"||",metric_name,
     "||",metric_name_meaning,"||",llm.lighthouse_goal,"||",
     llm.client_target,"||",llm.numerator,"||",llm.denominator,
     "||",nurse_unit,"||",building,"||",
     facility,"||",llm.discharge_month,"||",llm.discharge_year,
     "||",llm.logical_domain_id,"||",version,"||",
     format(llm.updt_dt_tm,"YYYYMMDDHHMMSS;;D"))
   FOOT REPORT
    IF (ds_cnt=0)
     stat = alterlist(dsr->qual[1].qual,1), dsr->qual[1].qual[1].stat_name = "NO_NEW_DATA"
    ELSE
     stat = alterlist(dsr->qual[1].qual,ds_cnt)
    ENDIF
   WITH nullreport, nocounter
  ;end select
 ELSE
  SET stat = alterlist(dsr->qual[1].qual,1)
  SET dsr->qual[1].qual[1].stat_name = "NO_NEW_DATA"
 ENDIF
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
  GO TO exit_program
 ENDIF
 CALL sbr_debug_timer("END","INSERTING LIGHTHOUSE DATA")
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
    WHERE di.info_domain="DM_STAT_LIGHTHOUSE_METRICS"
     AND di.info_name="DEBUG_IND"
    DETAIL
     mn_debug_ind = di.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = 0, di.info_domain = "DM_STAT_LIGHTHOUSE_METRICS", di.info_name =
      "DEBUG_IND"
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
   ENDIF
 END ;Subroutine
#exit_program
 CALL sbr_debug_timer("END_TOTAL","dm_stat_lighthouse_measures")
END GO
