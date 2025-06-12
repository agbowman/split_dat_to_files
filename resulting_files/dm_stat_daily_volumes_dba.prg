CREATE PROGRAM dm_stat_daily_volumes:dba
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
 DECLARE qualcnt = i4
 DECLARE ds_cnt = i4
 DECLARE ds_current_snapshot = f8
 DECLARE ds_last_snapshot = f8
 DECLARE mn_lower_stat = i4
 DECLARE mn_upper_stat = i4
 DECLARE ml_idx = i4
 DECLARE mn_debug_ind = i2
 DECLARE md_start_timer = dq8
 DECLARE md_end_timer = dq8
 DECLARE md_start_total_timer = dq8
 DECLARE md_end_total_timer = dq8
 DECLARE mn_open_chart_code_val = f8
 DECLARE sbr_check_debug(null) = null
 DECLARE write_dm_info(z=vc) = null
 DECLARE dsvm_error(msg=vc) = null
 DECLARE sbr_debug_timer(ms_input_mode=vc,ms_input_str=vc) = null
 SET ds_cnt = 0
 SET ds_cnt2 = 0
 SET ds_cnt3 = 0
 SET ds_cnt4 = 0
 SET ml_idx = 0
 SET ml_pos = 0
 SET mn_child_size = 0
 SET qualcnt = 0
 SET ds_current_snapshot = 0
 SET ds_last_snapshot = 0
 SET mn_open_chart_code_val = uar_get_code_by("MEANING",104,"CHARTACCESS")
 SET ds_current_snapshot = cnvtdatetime(curdate,curtime3)
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
  ENDIF
 END ;Subroutine
 CALL sbr_check_debug(null)
 CALL dsvm_error("DEBUG INDICATOR")
 CALL sbr_debug_timer("START_TOTAL","DM_STAT_DAILY_VOLUMES")
 CALL echo("Getting LAST SNAPSHOT DATE TIME.")
 SELECT INTO "nl:"
  dm.info_date
  FROM dm_info dm
  WHERE dm.info_domain="DM_STAT_DAILY_VOLUMES"
   AND dm.info_name="LAST SNAPSHOT DATE TIME"
  DETAIL
   ds_last_snapshot = cnvtdatetime(dm.info_date)
  WITH nocounter
 ;end select
 CALL dsvm_error("LAST SNAPSHOT DATE TIME")
 IF (ds_last_snapshot=0)
  CALL esmerror("Last snapshot date/time was not obtained",esmreturn)
  CALL write_dm_info("x")
  GO TO exit_program
 ENDIF
 CALL echo("Getting prsnl volumes.")
 CALL sbr_debug_timer("START","PRSNL VOLUMES")
 SELECT INTO "nl:"
  p.physician_ind, dvsm_ret = count(1)
  FROM prsnl p
  WHERE p.person_id != 0
   AND p.active_ind=1
   AND p.username IS NOT null
   AND p.username > " "
   AND p.end_effective_dt_tm > cnvtdatetime((curdate - 1),0)
   AND p.physician_ind IN (0, 1)
  GROUP BY p.physician_ind
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetime((curdate - 1),0),
   dsr->qual[qualcnt].snapshot_type = "PERSONNEL-ACTIVE USERS WITH SIGNON", stat = alterlist(dsr->
    qual[qualcnt].qual,2), dsr->qual[qualcnt].qual[1].stat_name = "OTHER",
   dsr->qual[qualcnt].qual[1].stat_number_val = 0, dsr->qual[qualcnt].qual[2].stat_name = "PHYSICIAN",
   dsr->qual[qualcnt].qual[2].stat_number_val = 0
  DETAIL
   IF (p.physician_ind=0)
    dsr->qual[qualcnt].qual[1].stat_number_val = dvsm_ret
   ELSE
    dsr->qual[qualcnt].qual[2].stat_number_val = dvsm_ret
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("PERSONNEL")
 CALL sbr_debug_timer("END","PRSNL VOLUMES")
 CALL echo("Getting chart volumes.")
 CALL sbr_debug_timer("START","CHART VOLUMES")
 SELECT INTO "nl:"
  hr = hour(ppa.ppa_first_dt_tm), p.physician_ind, dsvm_ret = count(*)
  FROM person_prsnl_activity ppa,
   prsnl p
  PLAN (ppa
   WHERE ppa.ppa_type_cd=mn_open_chart_code_val
    AND ppa.ppa_first_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),
    235959))
   JOIN (p
   WHERE ((ppa.prsnl_id+ 0)=p.person_id))
  GROUP BY hour(ppa.ppa_first_dt_tm), p.physician_ind
  ORDER BY hour(ppa.ppa_first_dt_tm), p.physician_ind
  HEAD hr
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetimeutc(datetimeadd(cnvtdatetime((curdate - 1),0),(hr/ 24.00),0),2),
   dsr->qual[qualcnt].snapshot_type = "OPENED_CHART_VOLUMES.3", ds_cnt = 2, stat = alterlist(dsr->
    qual[qualcnt].qual,ds_cnt)
  DETAIL
   IF (p.physician_ind=1)
    dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_name = "PHYSICIAN", dsr->qual[qualcnt].qual[(ds_cnt -
    1)].stat_type = 1, dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_number_val = dsvm_ret
   ELSEIF (p.physician_ind=0)
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "OTHER", dsr->qual[qualcnt].qual[ds_cnt].stat_type =
    1, dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = dsvm_ret
   ENDIF
  WITH nocounter
 ;end select
 CALL sbr_debug_timer("END","CHART VOLUMES")
 CALL write_dm_info("x")
 CALL sbr_debug_timer("START","LOAD TIMER")
 EXECUTE dm_stat_snaps_load
 CALL sbr_debug_timer("END","LOAD TIMER")
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
   WHERE di.info_domain="DM_STAT_DAILY_VOLUMES"
    AND di.info_name="DEBUG_IND"
   DETAIL
    mn_debug_ind = di.info_number
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_info di
    SET di.info_number = 0, di.info_domain = "DM_STAT_DAILY_VOLUMES", di.info_name = "DEBUG_IND"
    WITH nocounter
   ;end insert
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE write_dm_info(z)
   CALL echo("Updating DM_INFO with snapshot dt/tm")
   UPDATE  FROM dm_info
    SET info_date = cnvtdatetime(ds_current_snapshot)
    WHERE info_domain="DM_STAT_DAILY_VOLUMES"
     AND info_name="LAST SNAPSHOT DATE TIME"
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info
     SET info_domain = "DM_STAT_DAILY_VOLUMES", info_name = "LAST SNAPSHOT DATE TIME", info_date =
      cnvtdatetime(ds_current_snapshot)
     WITH nocounter
    ;end insert
   ENDIF
   CALL dsvm_error("DM_INFO UPDATES")
   COMMIT
 END ;Subroutine
#exit_program
 FREE SET ds_cnt
 CALL sbr_debug_timer("END_TOTAL","DM_STAT_DAILY_VOLUMES")
END GO
