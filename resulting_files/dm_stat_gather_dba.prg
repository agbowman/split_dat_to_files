CREATE PROGRAM dm_stat_gather:dba
 DECLARE initializescriptlog(parent_script=vc) = null
 DECLARE startscriptlog(script_name=vc,script_type=vc) = null
 DECLARE stopscriptlog("X") = null
 DECLARE parent_script_name = vc WITH noconstant("NOT_INITIALIZED")
 DECLARE current_script_type = vc WITH noconstant("NOT_INITIALIZED")
 DECLARE current_script_name = vc WITH noconstant("NOT_INITIALIZED")
 DECLARE current_script_start_time = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800"))
 DECLARE current_script_stop_time = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800"))
 DECLARE execution_duration = f8 WITH noconstant(0)
 DECLARE filename = vc WITH noconstant("")
 SUBROUTINE initializescriptlog(parent_script)
   SET parent_script_name = parent_script
 END ;Subroutine
 SUBROUTINE startscriptlog(script_name,script_type)
   SET current_script_name = script_name
   SET current_script_type = script_type
   SET current_script_start_time = cnvtdatetime(curdate,curtime3)
 END ;Subroutine
 SUBROUTINE stopscriptlog("X")
   SET current_script_stop_time = cnvtdatetime(curdate,curtime3)
   SET execution_duration = datetimediff(current_script_stop_time,current_script_start_time,5)
   SET filename = concat("dm_script_log_",format(cnvtdatetime(curdate,0),"mmddyy;;D"),".csv")
   SELECT INTO value(filename)
    build2(format(current_script_stop_time,"hh:mm:ss;;m"),",",current_script_name,",",
     execution_duration,
     ",",current_script_type,",",parent_script_name)
    FROM dummyt
    WITH nocounter, append, noheading
   ;end select
 END ;Subroutine
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
 FREE RECORD d_exec
 RECORD d_exec(
   1 r_list[*]
     2 routine_name = vc
   1 eod_list[*]
     2 eod_name = vc
     2 eod_all_name = vc
   1 eom_list[*]
     2 eom_name = vc
     2 eom_all_name = vc
 )
 FREE RECORD d_error
 RECORD d_error(
   1 d_error_ind = i2
 ) WITH persistscript
 FREE RECORD d_dates
 RECORD d_dates(
   1 d_eod_date = dq8
   1 d_eom_date = dq8
   1 d_date = dq8
 )
 DECLARE setsendtime(x) = null
 DECLARE checkexportrows(x) = null
 DECLARE d_loop = i4
 DECLARE d_err_msg = c132
 DECLARE same_day = i2
 DECLARE d_exec_name = c30
 DECLARE tmp_time1 = i4
 DECLARE tmp_time2 = i4
 DECLARE d_stat = i4
 DECLARE d_exec_cnt = i4
 DECLARE d_exec_eod = i2
 DECLARE d_node = c50
 DECLARE forcedlymnthly = i2
 DECLARE eod_all_flag = i2 WITH noconstant(0)
 DECLARE eod_one_flag = i2 WITH noconstant(0)
 DECLARE eom_all_flag = i2 WITH noconstant(0)
 DECLARE eom_one_flag = i2 WITH noconstant(0)
 DECLARE script_type = vc WITH noconstant("")
 DECLARE mystat = i4 WITH noconstant(0)
 DECLARE version_detail_flag = i2 WITH noconstant(0)
 DECLARE version_load_flag = i2 WITH noconstant(0)
 DECLARE dmt_sendtime = c4 WITH noconstant("NONE")
 DECLARE dmt_lastexport = dq8 WITH noconstant(0.0)
 DECLARE dm_stat_gather_dt = dq8
 SET dm_stat_gather_dt = cnvtdatetime(curdate,curtime3)
 DECLARE logfile = c100
 DECLARE debug_msg_ind = i2
 SET logfile = build("DM_STAT_GATHER_LOGFILE_",curnode,"_",day(curdate),".txt")
 SET d_exec_eod = 0
 SET d_exec_cnt = 0
 SET d_exec_name = " "
 SET d_err_msg = fillstring(132," ")
 SET forcedlymnthly = 0
 SET d_dates->d_date = cnvtdatetime(curdate,curtime3)
 SET d_node = curnode
 CALL checkexportrows("x")
 CALL getdebugrow("x")
 CALL log_msg("BeginSession",logfile)
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain="DATA MANAGEMENT"
   AND dm.info_name="DM_STAT_GATHER_OFF"
   AND dm.info_char="Y"
  WITH nocounter
 ;end select
 IF (error(d_err_msg,0) != 0)
  CALL echo("ERROR --- ERROR --- ERROR")
  CALL esmerror(d_err_msg,esmexit)
 ENDIF
 IF (curqual > 0)
  CALL echo("DM_STAT_GATHER is off, no statistic will be gathered.")
  GO TO exit_program
 ENDIF
 CALL initializescriptlog("DM_STAT_GATHER")
 SELECT INTO "nl:"
  dm.info_number
  FROM dm_info dm
  WHERE dm.info_domain="DM_STATS_FORCE"
  DETAIL
   forcedlymnthly = dm.info_number
  WITH nocounter
 ;end select
 IF (error(d_err_msg,0) != 0)
  CALL esmerror(d_err_msg,esmreturn)
 ENDIF
 IF (curqual > 0)
  UPDATE  FROM dm_info
   SET info_number = 0
   WHERE info_domain="DM_STATS_FORCE"
   WITH nocounter
  ;end update
  IF (error(d_err_msg,0) != 0)
   CALL esmerror(d_err_msg,esmreturn)
  ENDIF
  COMMIT
 ENDIF
 CALL log_msg("Begin Routine select",logfile)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM_STAT_GATHER"
   AND di.info_char="ROUTINE"
   AND di.info_name > " "
  ORDER BY di.info_number
  HEAD REPORT
   d_exec_cnt = 0
  HEAD di.info_name
   tmp_time1 = (cnvtmin(cnvtdatetime(curdate,curtime3)) - cnvtmin(di.info_date)), tmp_time2 = di
   .info_number,
   CALL echo("-"),
   CALL echo("--------------------------------------------------------"),
   CALL echo(build("Time until Routine -- ",di.info_name," runs again....",(tmp_time2 - tmp_time1),
    " minutes")),
   CALL echo("--------------------------------------------------------")
  DETAIL
   IF (tmp_time2 <= tmp_time1)
    d_exec_cnt = (d_exec_cnt+ 1)
    IF (mod(d_exec_cnt,10)=1)
     d_stat = alterlist(d_exec->r_list,(d_exec_cnt+ 9))
    ENDIF
    d_exec->r_list[d_exec_cnt].routine_name = di.info_name
   ENDIF
  FOOT REPORT
   d_stat = alterlist(d_exec->r_list,d_exec_cnt)
  WITH forupdatewait(di)
 ;end select
 IF (error(d_err_msg,0) != 0)
  CALL esmerror(d_err_msg,esmreturn)
 ENDIF
 IF (d_exec_cnt > 0)
  UPDATE  FROM dm_info di,
    (dummyt d  WITH seq = value(d_exec_cnt))
   SET di.info_date = cnvtdatetime(d_dates->d_date)
   PLAN (d)
    JOIN (di
    WHERE di.info_domain="DM_STAT_GATHER"
     AND di.info_char="ROUTINE"
     AND (di.info_name=d_exec->r_list[d.seq].routine_name))
   WITH nocounter
  ;end update
  IF (((error(d_err_msg,0) != 0) OR (curqual != d_exec_cnt)) )
   ROLLBACK
   CALL echo("ERROR --- ERROR --- ERROR")
   CALL esmerror(concat("ERROR: ROUTINE - could not update dm_info rows with date ",format(
      cnvtdatetime(d_dates->d_date),";;q")),esmexit)
  ELSE
   COMMIT
  ENDIF
  FOR (d_loop = 1 TO d_exec_cnt)
    CALL log_msg(build("Executing: ",value(d_exec->r_list[d_loop].routine_name)),logfile)
    CALL echo("***********************")
    CALL echo(concat("Executing ",value(d_exec->r_list[d_loop].routine_name),"...  Begin date/time: ",
      format(cnvtdatetime(curdate,curtime3),";;q")))
    CALL echo("***********************")
    SET script_type = "ROUTINE"
    CALL startscriptlog(d_exec->r_list[d_loop].routine_name,script_type)
    EXECUTE value(d_exec->r_list[d_loop].routine_name)
    CALL stopscriptlog("x")
    CALL echo("***********************")
    CALL echo(concat("Executing ",value(d_exec->r_list[d_loop].routine_name),"...  End date/time: ",
      format(cnvtdatetime(curdate,curtime3),";;q")))
    CALL echo("***********************")
    CALL log_msg(build("Done Executing: ",value(d_exec->r_list[d_loop].routine_name)),logfile)
  ENDFOR
 ENDIF
 ROLLBACK
 CALL log_msg(build("Done Executing Routine Scripts"),logfile)
 SET d_exec_cnt = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM_STAT_GATHER_EOD"
   AND di.info_char="EOD ALL NODES"
   AND di.info_name=d_node
  DETAIL
   d_dates->d_eod_date = cnvtdatetime(di.info_date)
  WITH forupdatewait(di)
 ;end select
 IF (error(d_err_msg,0) != 0)
  CALL esmerror(d_err_msg,esmreturn)
 ENDIF
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_date = cnvtdatetime(d_dates->d_date), di.info_domain = "DM_STAT_GATHER_EOD", di
    .info_char = "EOD ALL NODES",
    di.info_name = d_node
   WITH nocounter
  ;end insert
  IF (error(d_err_msg,0) != 0)
   CALL esmerror(d_err_msg,esmreturn)
   SET eod_all_flag = 1
  ENDIF
  COMMIT
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DM_STAT_GATHER_EOD"
    AND di.info_char="EOD ALL NODES"
    AND di.info_name=d_node
   DETAIL
    d_dates->d_eod_date = cnvtdatetime(di.info_date)
   WITH forupdatewait(di)
  ;end select
  IF (error(d_err_msg,0) != 0)
   CALL esmerror(d_err_msg,esmreturn)
   SET eod_all_flag = 1
  ENDIF
 ENDIF
 IF (eod_all_flag=0)
  IF (dmt_sendtime="NONE")
   CALL setsendtime("x")
  ENDIF
  IF (((julian(d_dates->d_eod_date) < julian(curdate)) OR (year(d_dates->d_eod_date) < year(curdate)
  ))
   AND format(curtime,"hhmm;;m") >= dmt_sendtime)
   SELECT INTO "nl:"
    di.info_name
    FROM dm_info di
    WHERE di.info_domain="DM_STAT_GATHER"
     AND di.info_char="EOD ALL NODES"
     AND di.info_name > " "
    ORDER BY di.info_number
    HEAD REPORT
     d_exec_cnt = 0
    DETAIL
     d_exec_cnt = (d_exec_cnt+ 1)
     IF (mod(d_exec_cnt,10)=1)
      d_stat = alterlist(d_exec->eod_list,(d_exec_cnt+ 9))
     ENDIF
     d_exec->eod_list[d_exec_cnt].eod_all_name = di.info_name
    FOOT REPORT
     d_stat = alterlist(d_exec->eod_list,d_exec_cnt)
    WITH nocounter
   ;end select
   IF (error(d_err_msg,0) != 0)
    CALL esmerror(d_err_msg,esmreturn)
    SET eod_all_flag = 1
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_date = cnvtdatetime(d_dates->d_date)
     WHERE di.info_domain="DM_STAT_GATHER_EOD"
      AND di.info_char="EOD ALL NODES"
      AND di.info_name=d_node
     WITH nocounter
    ;end update
    IF (error(d_err_msg,0) != 0)
     SET eod_all_flag = 1
     ROLLBACK
     CALL echo("ERROR -- ERROR -- ERROR")
     CALL esmerror(concat("ERROR: EOD ALL NODES- could not update dm_info row with date ",format(
        cnvtdatetime(d_dates->d_date),";;q")),esmreturn)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   IF (eod_all_flag=0)
    CALL log_msg(build("Running EOD ALL NODES scripts"),logfile)
    FOR (d_loop = 1 TO d_exec_cnt)
      CALL echo("***********************")
      CALL echo(concat("Executing ",value(d_exec->eod_list[d_loop].eod_all_name),
        "...  Begin date/time: ",format(cnvtdatetime(curdate,curtime3),";;q")))
      CALL echo("***********************")
      CALL log_msg(build("Executing",value(d_exec->eod_list[d_loop].eod_all_name)),logfile)
      SET script_type = build("eod.all")
      CALL startscriptlog(d_exec->eod_list[d_loop].eod_all_name,script_type)
      EXECUTE value(d_exec->eod_list[d_loop].eod_all_name)
      CALL stopscriptlog("x")
      CALL echo("***********************")
      CALL echo(concat("Executing ",value(d_exec->eod_list[d_loop].eod_all_name),
        "...  End date/time: ",format(cnvtdatetime(curdate,curtime3),";;q")))
      CALL echo("***********************")
      CALL log_msg(build("Done Executing",value(d_exec->eod_list[d_loop].eod_all_name)),logfile)
      SET d_exec_eod = 1
    ENDFOR
    CALL log_msg(build("Finished Executing EOD ALL NODE scripts"),logfile)
   ENDIF
  ENDIF
 ENDIF
 ROLLBACK
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
 SET d_exec_cnt = 0
 IF (dmt_sendtime="NONE")
  CALL setsendtime("x")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM_STAT_GATHER"
   AND di.info_char="EOD 1 NODE"
   AND di.info_name > " "
  ORDER BY di.info_number
  HEAD REPORT
   version_detail_flag = 1, version_load_flag = 0, d_exec_cnt = 0
  DETAIL
   IF (((julian(di.info_date) < julian(curdate)) OR (year(di.info_date) < year(curdate)))
    AND format(curtime,"hhmm;;m") >= dmt_sendtime)
    d_exec_cnt = (d_exec_cnt+ 1)
    IF (mod(d_exec_cnt,10)=1)
     d_stat = alterlist(d_exec->eod_list,(d_exec_cnt+ 9))
    ENDIF
    d_exec->eod_list[d_exec_cnt].eod_name = di.info_name
   ENDIF
  FOOT REPORT
   d_stat = alterlist(d_exec->eod_list,d_exec_cnt)
  WITH forupdatewait(di)
 ;end select
 IF (version_load_flag=1)
  EXECUTE dm_stat_snaps_load
  SET version_load_flag = 0
 ENDIF
 IF (eod_one_flag=0)
  IF (d_exec_cnt > 0)
   UPDATE  FROM dm_info di,
     (dummyt d  WITH seq = value(d_exec_cnt))
    SET di.info_date = cnvtdatetime(d_dates->d_date)
    PLAN (d)
     JOIN (di
     WHERE di.info_domain="DM_STAT_GATHER"
      AND di.info_char="EOD 1 NODE"
      AND (di.info_name=d_exec->eod_list[d.seq].eod_name))
    WITH nocounter
   ;end update
   IF (((error(d_err_msg,0) != 0) OR (curqual != d_exec_cnt)) )
    SET eod_one_flag = 1
    ROLLBACK
    CALL echo("ERROR -- ERROR -- ERROR")
    CALL esmerror(concat("ERROR: EOD - could not update dm_info with date - ",format(cnvtdatetime(
        d_dates->d_date),";;q")),esmreturn)
   ELSE
    COMMIT
   ENDIF
   IF (eod_one_flag=0)
    CALL log_msg(build("Beginning EOD ALL NODES Scripts."),logfile)
    FOR (d_loop = 1 TO d_exec_cnt)
      CALL echo("***********************")
      CALL echo(concat("Executing ",value(d_exec->eod_list[d_loop].eod_name),"...  Begin date/time: ",
        format(cnvtdatetime(curdate,curtime3),";;q")))
      CALL echo("***********************")
      CALL log_msg(build("Executing ",value(d_exec->eod_list[d_loop].eod_name)),logfile)
      SET script_type = build("eod.one")
      CALL startscriptlog(d_exec->eod_list[d_loop].eod_name,script_type)
      EXECUTE value(d_exec->eod_list[d_loop].eod_name)
      CALL stopscriptlog("x")
      CALL log_msg(build("Done Executing ",value(d_exec->eod_list[d_loop].eod_name)),logfile)
      CALL echo("***********************")
      CALL echo(concat("Executing ",value(d_exec->eod_list[d_loop].eod_name),"...  End date/time: ",
        format(cnvtdatetime(curdate,curtime3),";;q")))
      CALL echo("***********************")
      SET d_exec_eod = 1
    ENDFOR
    CALL log_msg(build("Done Executing EOD All nodes scripts."),logfile)
   ENDIF
  ENDIF
 ENDIF
 ROLLBACK
 SET d_exec_cnt = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM_STAT_GATHER_EOM"
   AND di.info_char="EOM ALL NODES"
   AND di.info_name=d_node
  DETAIL
   d_dates->d_eom_date = di.info_date
  WITH forupdatewait(di)
 ;end select
 IF (error(d_err_msg,0) != 0)
  CALL esmerror(d_err_msg,esmreturn)
 ENDIF
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_date = cnvtdatetime(d_dates->d_date), di.info_domain = "DM_STAT_GATHER_EOM", di
    .info_char = "EOM ALL NODES",
    di.info_name = d_node
   WITH nocounter
  ;end insert
  IF (error(d_err_msg,0) != 0)
   CALL esmerror(d_err_msg,esmreturn)
   SET eom_all_flag = 1
  ENDIF
  COMMIT
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DM_STAT_GATHER_EOM"
    AND di.info_char="EOM ALL NODES"
    AND di.info_name=d_node
   DETAIL
    d_dates->d_eom_date = di.info_date
   WITH forupdatewait(di)
  ;end select
  IF (error(d_err_msg,0) != 0)
   CALL esmerror(d_err_msg,esmreturn)
   SET eom_all_flag = 1
  ENDIF
 ENDIF
 IF (eom_all_flag=0)
  IF (dmt_sendtime="NONE")
   CALL setsendtime("x")
  ENDIF
  IF (((day(cnvtdatetime(curdate,curtime3))=1
   AND month(cnvtdatetime(curdate,curtime3)) != month(cnvtdatetime(d_dates->d_eom_date))
   AND format(curtime,"hhmm;;m") >= dmt_sendtime) OR (forcedlymnthly > 0)) )
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_STAT_GATHER"
     AND di.info_char="EOM ALL NODES"
     AND di.info_name > " "
    ORDER BY di.info_number
    HEAD REPORT
     d_exec_cnt = 0
    DETAIL
     d_exec_cnt = (d_exec_cnt+ 1)
     IF (mod(d_exec_cnt,10)=1)
      d_stat = alterlist(d_exec->eom_list,(d_exec_cnt+ 9))
     ENDIF
     d_exec->eom_list[d_exec_cnt].eom_all_name = di.info_name
    FOOT REPORT
     d_stat = alterlist(d_exec->eom_list,d_exec_cnt)
    WITH nocounter
   ;end select
   IF (error(d_err_msg,0) != 0)
    CALL esmerror(d_err_msg,esmreturn)
    SET eom_all_flag = 1
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_date = cnvtdatetime(d_dates->d_date)
     WHERE di.info_domain="DM_STAT_GATHER_EOM"
      AND di.info_char="EOM ALL NODES"
      AND di.info_name=d_node
     WITH nocounter
    ;end update
    IF (error(d_err_msg,0) != 0)
     SET eom_all_flag = 1
     ROLLBACK
     CALL echo("ERROR -- ERROR -- ERROR")
     CALL esmerror(concat("ERROR: EOM ALL NODES- could not update dm_info with date - ",format(
        cnvtdatetime(d_dates->d_date),";;q")),esmreturn)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   IF (eom_all_flag=0)
    FOR (d_loop = 1 TO d_exec_cnt)
      CALL echo("***********************")
      CALL echo(concat("Executing ",value(d_exec->eom_list[d_loop].eom_all_name),
        "...  Begin date/time: ",format(cnvtdatetime(curdate,curtime3),";;q")))
      CALL echo("***********************")
      SET script_type = build("eom.all")
      CALL startscriptlog(d_exec->eom_list[d_loop].eom_all_name,script_type)
      EXECUTE value(d_exec->eom_list[d_loop].eom_all_name)
      CALL stopscriptlog("x")
      CALL echo("***********************")
      CALL echo(concat("Executing ",value(d_exec->eom_list[d_loop].eom_all_name),
        "...  End date/time: ",format(cnvtdatetime(curdate,curtime3),";;q")))
      CALL echo("***********************")
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
 ROLLBACK
 SET d_exec_cnt = 0
 IF (dmt_sendtime="NONE")
  CALL setsendtime("x")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM_STAT_GATHER"
   AND di.info_char="EOM 1 NODE"
   AND di.info_name > " "
  ORDER BY di.info_number
  HEAD REPORT
   d_exec_cnt = 0
  DETAIL
   IF (((day(cnvtdatetime(curdate,curtime3))=1
    AND month(cnvtdatetime(curdate,curtime3)) != month(cnvtdatetime(di.info_date))
    AND format(curtime,"hhmm;;m") >= dmt_sendtime) OR (forcedlymnthly > 0)) )
    d_exec_cnt = (d_exec_cnt+ 1)
    IF (mod(d_exec_cnt,10)=1)
     d_stat = alterlist(d_exec->eom_list,(d_exec_cnt+ 9))
    ENDIF
    d_exec->eom_list[d_exec_cnt].eom_name = di.info_name
   ENDIF
  FOOT REPORT
   d_stat = alterlist(d_exec->eom_list,d_exec_cnt)
  WITH forupdatewait(di)
 ;end select
 IF (error(d_err_msg,0) != 0)
  CALL esmerror(d_err_msg,esmreturn)
  SET eom_one_flag = 1
 ENDIF
 IF (eom_one_flag=0)
  IF (d_exec_cnt > 0)
   UPDATE  FROM dm_info di,
     (dummyt d  WITH seq = value(d_exec_cnt))
    SET di.info_date = cnvtdatetime(d_dates->d_date)
    PLAN (d)
     JOIN (di
     WHERE di.info_domain="DM_STAT_GATHER"
      AND di.info_char="EOM 1 NODE"
      AND (di.info_name=d_exec->eom_list[d.seq].eom_name))
    WITH nocounter
   ;end update
   IF (((error(d_err_msg,0) != 0) OR (curqual != d_exec_cnt)) )
    SET eom_one_flag = 1
    ROLLBACK
    CALL echo("ERROR -- ERROR -- ERROR")
    CALL esmerror(concat("ERROR: EOM - could not update dm_info with date - ",format(cnvtdatetime(
        d_dates->d_date),";;q")),esmreturn)
   ELSE
    COMMIT
   ENDIF
   IF (eom_one_flag=0)
    FOR (d_loop = 1 TO d_exec_cnt)
      CALL echo("***********************")
      CALL echo(concat("Executing ",value(d_exec->eom_list[d_loop].eom_name),"...  Begin date/time: ",
        format(cnvtdatetime(curdate,curtime3),";;q")))
      CALL echo("***********************")
      SET script_type = build("eom.one")
      CALL startscriptlog(d_exec->eom_list[d_loop].eom_name,script_type)
      EXECUTE value(d_exec->eom_list[d_loop].eom_name)
      CALL stopscriptlog("x")
      CALL echo("***********************")
      CALL echo(concat("Executing ",value(d_exec->eom_list[d_loop].eom_name),"...  End date/time: ",
        format(cnvtdatetime(curdate,curtime3),";;q")))
      CALL echo("***********************")
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
 ROLLBACK
 IF (dmt_sendtime="NONE")
  CALL setsendtime("x")
 ENDIF
 IF (((julian(dmt_lastexport) < julian(curdate)) OR (year(dmt_lastexport) < year(curdate)))
  AND format(curtime,"hhmm;;m") >= dmt_sendtime)
  UPDATE  FROM dm_info di
   SET info_date = cnvtdatetime(curdate,curtime3)
   WHERE info_domain="DM_STAT_NODE_EXPORT"
    AND info_name=curnode
   WITH nocounter
  ;end update
  COMMIT
  CALL echo("Executing.....DM_STAT_EXPORT")
  EXECUTE dm_stat_export
  CALL echo("Executing.....DM_STAT_RESEND")
  EXECUTE dm_stat_resend
  CALL echo("Executing.....DM_STAT_PURGE")
  EXECUTE dm_stat_purge
 ENDIF
 SUBROUTINE getdebugrow(x)
  SELECT INTO "nl:"
   di.info_number
   FROM dm_info di
   WHERE info_domain="DM_STAT_GATHER_DEBUG"
    AND info_name="DEBUG_IND"
   DETAIL
    debug_msg_ind = di.info_number
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_info
    SET info_domain = "DM_STAT_GATHER_DEBUG", info_name = "DEBUG_IND", info_number = 0
    WITH nocounter
   ;end insert
   COMMIT
   SET debug_msg_ind = 0
   CALL log_msg("Creating DM_INFO row",logfile)
  ENDIF
 END ;Subroutine
 SUBROUTINE setsendtime(x)
   SELECT INTO "nl:"
    di.info_char
    FROM dm_info di
    WHERE di.info_domain="DM_STAT_SENDTIME"
     AND info_name="SEND_TIME"
    HEAD REPORT
     dmt_sendtime = "0045"
    DETAIL
     IF (size(di.info_char,1)=4)
      IF (cnvtint(substring(1,2,di.info_char)) >= 0
       AND cnvtint(substring(1,2,di.info_char)) <= 23
       AND cnvtint(substring(3,2,di.info_char)) >= 0
       AND cnvtint(substring(3,2,di.info_char)) <= 59)
       dmt_sendtime = di.info_char
      ELSE
       dmt_sendtime = "0045"
      ENDIF
     ELSE
      dmt_sendtime = "0045"
     ENDIF
    WITH nocounter, nullreport
   ;end select
 END ;Subroutine
 SUBROUTINE checkexportrows(x)
  SELECT INTO "nl:"
   di.info_date
   FROM dm_info di
   WHERE info_domain="DM_STAT_NODE_EXPORT"
    AND info_name=curnode
   DETAIL
    dmt_lastexport = di.info_date
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_STAT_NODE_EXPORT", di.info_name = curnode, di.info_date = cnvtdatetime((
      curdate - 1),0)
    WITH nocounter
   ;end insert
   COMMIT
   SET dmt_lastexport = cnvtdatetime((curdate - 1),0)
  ENDIF
 END ;Subroutine
 SUBROUTINE log_msg(logmsg,sbr_dlogfile)
   IF (debug_msg_ind=1)
    SELECT INTO value(sbr_dlogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      beg_pos = 1, end_pos = 132, not_done = 1,
      dm_eproc_length = textlen(logmsg)
     DETAIL
      IF (logmsg="BeginSession")
       row + 1, "DM_STAT_GATHER Begins:", row + 1,
       curdate"mm/dd/yyyy;;d", " ", curtime3"hh:mm:ss;3;m"
      ELSEIF (logmsg="EndSession")
       row + 1, "DM_STAT_GATHER Ends:", row + 1,
       curdate"mm/dd/yyyy;;d", " ", curtime3"hh:mm:ss;3;m"
      ELSE
       dm_txt = substring(beg_pos,end_pos,logmsg)
       WHILE (not_done=1)
         row + 1, col 0, dm_txt,
         row + 1, curdate"mm/dd/yyyy;;d", " ",
         curtime3"hh:mm:ss;3;m"
         IF (end_pos > dm_eproc_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,logmsg)
         ENDIF
       ENDWHILE
      ENDIF
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
   ENDIF
 END ;Subroutine
#exit_program
 CALL log_msg("EndSession",logfile)
END GO
