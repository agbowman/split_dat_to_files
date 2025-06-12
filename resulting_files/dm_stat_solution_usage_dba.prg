CREATE PROGRAM dm_stat_solution_usage:dba
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
 DECLARE ms_snapshot_type = vc WITH protect, constant("SOLUTION_USAGE")
 DECLARE ms_last_run_time = dq8
 DECLARE ms_this_run_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE ms_info_domain = vc WITH constant("DM_STAT_SOLUTION_USAGE")
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
 CALL sbr_debug_timer("START_TOTAL","DM_STAT_SOLUTION_USAGE")
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
  SET ms_last_run_time = cnvtdatetime("01-JAN-1800 00:00:00")
 ENDIF
 CALL sbr_debug_timer("START","INSERTING SOLUTION USAGE DATA")
 SELECT INTO "nl:"
  em.measurement_nbr, epr.capability_in_use_ind, epr.result_dt_tm,
  epr.facility_cd, facility = uar_get_code_display(epr.facility_cd), epr.position_cd,
  position = uar_get_code_display(epr.position_cd), detail_name = trim(eprd.detail_name),
  detail_value_txt = trim(eprd.detail_value_txt)
  FROM ec_profiler_event epe,
   ec_profiler_result epr,
   ec_profiler_result_detail eprd,
   ec_measurement em
  PLAN (epe
   WHERE epe.event_end_dt_tm > cnvtdatetime(ms_last_run_time)
    AND epe.event_end_dt_tm <= cnvtdatetime(ms_this_run_time)
    AND epe.ec_profiler_event_id > 0)
   JOIN (epr
   WHERE epr.ec_profiler_event_id=epe.ec_profiler_event_id
    AND epr.result_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),235959)
   )
   JOIN (em
   WHERE em.ec_measurement_id=epr.ec_measurement_id)
   JOIN (eprd
   WHERE eprd.ec_profiler_result_id=outerjoin(epr.ec_profiler_result_id))
  HEAD REPORT
   stat = alterlist(dsr->qual,1), dsr->qual[1].snapshot_type = ms_snapshot_type, dsr->qual[1].
   stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
   ds_cnt = 0
  DETAIL
   ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[1].qual[ds_cnt].stat_name = "FIRSTNET_USAGE", dsr->qual[1].qual[ds_cnt].stat_type = 2,
   dsr->qual[1].qual[ds_cnt].stat_seq = (ds_cnt - 1),
   dsr->qual[1].qual[ds_cnt].stat_number_val = em.measurement_nbr, dsr->qual[1].qual[ds_cnt].
   stat_clob_val = build(epr.capability_in_use_ind,"||",facility,"||",epr.facility_cd,
    "||",position,"||",epr.position_cd,"||",
    detail_name,"||",detail_value_txt,"||",format(epr.result_dt_tm,"YYYYMMDDHHMMSS;;D"))
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
 CALL sbr_debug_timer("END","INSERTING SOLUTION USAGE DATA")
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(ms_this_run_time)
  WHERE di.info_domain=ms_info_domain
   AND di.info_name="LAST_RUN_TIME"
  WITH nocounter
 ;end update
 CALL sbr_debug_timer("START","INSERTING DATA TO DB")
 EXECUTE dm_stat_snaps_load
 CALL sbr_debug_timer("END","INSERTING DATA TO DB")
 CALL sbr_debug_timer("START","EXPORTING DATA FROM DB")
 DECLARE dm_stat_snapshot_type = vc WITH constant("SOLUTION_USAGE")
 DECLARE dm_stat_snap_number = i4 WITH constant(87)
 EXECUTE dm_stat_export_snapshot dm_stat_snapshot_type, dm_stat_snap_number
 CALL sbr_debug_timer("END","EXPORTING DATA FROM DB")
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
 CALL sbr_debug_timer("END_TOTAL","DM_STAT_SOLUTION_USAGE")
END GO
