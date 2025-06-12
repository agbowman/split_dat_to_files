CREATE PROGRAM dm_stat_readme_data:dba
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
 DECLARE ms_snapshot_type = vc WITH protect, constant("README_DATA.2")
 DECLARE ms_info_domain = vc WITH constant("DM_STAT_README_DATA.2")
 DECLARE ms_last_run_time = dq8
 DECLARE ms_this_run_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE ms_snapshot_time = dq8 WITH constant(cnvtdatetime((curdate - 1),0))
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=ms_info_domain
   AND di.info_name IN ("LAST_RUN_TIME", "LAST_FULL_RUN_TIME")
  HEAD REPORT
   isfullrun = 0
  DETAIL
   IF (di.info_name="LAST_FULL_RUN_TIME")
    IF (((datetimediff(cnvtdatetime(curdate,curtime3),di.info_date) >= 32) OR (day(cnvtdatetime(
      curdate,curtime3))=1)) )
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
 DECLARE ds_cnt = i4
 DECLARE dsvm_error(msg=vc) = null
 SELECT INTO "nl:"
  environment_id = dolh.environment_id, project_type = trim(dolh.project_type), project_name = trim(
   dolh.project_name),
  project_instance = dolh.project_instance, ocd = dolh.ocd, status = trim(dolh.status),
  driver_count = dolh.driver_count, estimated_time = dolh.estimated_time
  FROM dm_ocd_log_hist dolh
  WHERE dolh.updt_dt_tm > cnvtdatetime(ms_last_run_time)
   AND dolh.updt_dt_tm <= cnvtdatetime(ms_this_run_time)
  HEAD REPORT
   stat = alterlist(dsr->qual,1), dsr->qual[1].snapshot_type = ms_snapshot_type, dsr->qual[1].
   stat_snap_dt_tm = ms_snapshot_time,
   ds_cnt = 0
  DETAIL
   ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[1].qual[ds_cnt].stat_name = "README DATA", dsr->qual[1].qual[ds_cnt].stat_type = 2, dsr
   ->qual[1].qual[ds_cnt].stat_seq = ds_cnt,
   dsr->qual[1].qual[ds_cnt].stat_clob_val = build(environment_id,"||",project_type,"||",project_name,
    "||",project_instance,"||",ocd,"||",
    status,"||",driver_count,"||",estimated_time,
    "||",format(dolh.batch_dt_tm,"YYYYMMDDHHMMSS;;D"),"||",format(dolh.start_dt_tm,
     "YYYYMMDDHHMMSS;;D"),"||",
    format(dolh.end_dt_tm,"YYYYMMDDHHMMSS;;D"))
  FOOT REPORT
   IF (ds_cnt=0)
    stat = alterlist(dsr->qual[1].qual,1), dsr->qual[1].qual[1].stat_name = "NO_NEW_DATA"
   ELSE
    stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 1)), ds_cnt = (ds_cnt+ 1), dsr->qual[1].qual[ds_cnt].
    stat_name = "FULL_RUN_IND"
    IF (isfullrun=1)
     dsr->qual[1].qual[ds_cnt].stat_number_val = 1
    ELSE
     dsr->qual[1].qual[ds_cnt].stat_number_val = 0
    ENDIF
   ENDIF
  WITH nullreport, nocounter
 ;end select
 CALL dsvm_error("README DATA - README DATA")
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
   GO TO exit_program
  ENDIF
 END ;Subroutine
#exit_program
END GO
