CREATE PROGRAM dm_stat_pref_build:dba
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
 DECLARE isfullrun = i4 WITH protect, noconstant(0)
 DECLARE ms_detail_snapshot_type = vc WITH protect, constant("DETAIL_PREF_BUILD")
 DECLARE ms_view_snapshot_type = vc WITH protect, constant("VIEW_PREF_BUILD")
 DECLARE ms_view_comp_snapshot_type = vc WITH protect, constant("VIEW_COMP_PREF_BUILD")
 DECLARE ms_info_domain = vc WITH constant("DM_STAT_PREF_BUILD")
 DECLARE ms_last_run_time = dq8
 DECLARE ms_this_run_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE ms_snapshot_time = dq8 WITH constant(cnvtdatetime((curdate - 1),0))
 DECLARE qualcnt = i4 WITH noconstant(0)
 DECLARE ds_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=ms_info_domain
   AND di.info_name IN ("LAST_RUN_TIME", "LAST_FULL_RUN_TIME")
  HEAD REPORT
   isfullrun = 0
  DETAIL
   IF (di.info_name="LAST_FULL_RUN_TIME")
    IF (((datetimediff(cnvtdatetime(curdate,curtime3),di.info_date) >= 32) OR (day(cnvtdatetime(
      curdate,curtime3))=10)) )
     isfullrun = 1
    ENDIF
   ELSEIF (di.info_name="LAST_RUN_TIME")
    ms_last_run_time = di.info_date
   ENDIF
  FOOT REPORT
   IF (isfullrun=1)
    ms_last_run_time = cnvtdatetime("01-JAN-1800 00:00:00")
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = ms_info_domain, di.info_name = "LAST_RUN_TIME", di.info_date = cnvtdatetime(
     "01-JAN-1800 00:00:00")
   WITH nocounter
  ;end insert
  INSERT  FROM dm_info di
   SET di.info_domain = ms_info_domain, di.info_name = "LAST_FULL_RUN_TIME", di.info_date =
    cnvtdatetime("01-JAN-1800 00:00:00")
   WITH nocounter
  ;end insert
  SET ms_last_run_time = cnvtdatetime("01-JAN-1800 00:00:00")
  SET isfullrun = 1
 ENDIF
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE dsvm_error(msg=vc) = null
 SELECT INTO "nl:"
  dp.detail_prefs_id, dp.application_number, dp.position_cd,
  dp.view_name, dp.view_seq, dp.comp_name,
  dp.comp_seq
  FROM detail_prefs dp
  WHERE dp.active_ind=1
   AND dp.prsnl_id=0
   AND dp.updt_dt_tm BETWEEN cnvtdatetime(ms_last_run_time) AND cnvtdatetime(ms_this_run_time)
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].snapshot_type =
   ms_detail_snapshot_type,
   dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ms_snapshot_time), ds_cnt = 0
  DETAIL
   ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = ms_detail_snapshot_type, dsr->qual[qualcnt].qual[
   ds_cnt].stat_seq = ds_cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(dp
    .detail_prefs_id,"||",dp.application_number,"||",dp.position_cd,
    "||",dp.view_name,"||",dp.view_seq,"||",
    dp.comp_name,"||",dp.comp_seq)
  FOOT REPORT
   ds_cnt = (ds_cnt+ 1), stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt), dsr->qual[qualcnt].qual[
   ds_cnt].stat_name = "FULL_RUN_IND",
   dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = isfullrun
  WITH nullreport, nocounter
 ;end select
 CALL dsvm_error("DETAIL_PREFS - DETAIL_PREFS")
 SELECT INTO "nl:"
  dp.view_comp_prefs_id, dp.application_number, dp.position_cd,
  dp.view_name, dp.view_seq, dp.comp_name,
  dp.comp_seq
  FROM view_comp_prefs dp
  WHERE dp.active_ind=1
   AND dp.prsnl_id=0
   AND dp.updt_dt_tm BETWEEN cnvtdatetime(ms_last_run_time) AND cnvtdatetime(ms_this_run_time)
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].snapshot_type =
   ms_view_comp_snapshot_type,
   dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ms_snapshot_time), ds_cnt = 0
  DETAIL
   ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = ms_view_comp_snapshot_type, dsr->qual[qualcnt].qual[
   ds_cnt].stat_seq = ds_cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(dp
    .view_comp_prefs_id,"||",dp.application_number,"||",dp.position_cd,
    "||",dp.view_name,"||",dp.view_seq,"||",
    dp.comp_name,"||",dp.comp_seq)
  FOOT REPORT
   ds_cnt = (ds_cnt+ 1), stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt), dsr->qual[qualcnt].qual[
   ds_cnt].stat_name = "FULL_RUN_IND",
   dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = isfullrun
  WITH nullreport, nocounter
 ;end select
 CALL dsvm_error("VIEW_COMP_PREFS - VIEW_COMP_PREFS")
 SELECT INTO "nl:"
  dp.view_prefs_id, dp.application_number, dp.position_cd,
  dp.view_name, dp.view_seq
  FROM view_prefs dp
  WHERE dp.active_ind=1
   AND dp.prsnl_id=0
   AND dp.updt_dt_tm BETWEEN cnvtdatetime(ms_last_run_time) AND cnvtdatetime(ms_this_run_time)
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].snapshot_type =
   ms_view_snapshot_type,
   dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ms_snapshot_time), ds_cnt = 0
  DETAIL
   ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = ms_view_snapshot_type, dsr->qual[qualcnt].qual[ds_cnt]
   .stat_seq = ds_cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(dp.view_prefs_id,"||",dp
    .application_number,"||",dp.position_cd,
    "||",dp.view_name,"||",dp.view_seq)
  FOOT REPORT
   ds_cnt = (ds_cnt+ 1), stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt), dsr->qual[qualcnt].qual[
   ds_cnt].stat_name = "FULL_RUN_IND",
   dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = isfullrun
  WITH nullreport, nocounter
 ;end select
 CALL dsvm_error("VIEW_PREFS - VIEW_PREFS")
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(ms_this_run_time)
  WHERE di.info_domain=ms_info_domain
   AND di.info_name="LAST_RUN_TIME"
  WITH nocounter
 ;end update
 IF (isfullrun=1)
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(ms_this_run_time)
   WHERE di.info_domain=ms_info_domain
    AND di.info_name="LAST_FULL_RUN_TIME"
   WITH nocounter
  ;end update
 ENDIF
 EXECUTE dm_stat_snaps_load
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
   GO TO exitscript
  ENDIF
 END ;Subroutine
#exitscript
END GO
