CREATE PROGRAM dm_stat_gather_uk_spec:dba
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
 DECLARE ms_snapshot_type = vc WITH protect, constant("UK_PRSNL_SPEC")
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE ds_cnt = i4
 FREE DEFINE active_str
 DECLARE active_str = vc
 DECLARE isfullrun = i2
 DECLARE ms_last_run_time = dq8
 DECLARE ms_this_run_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE ms_snapshot_time = dq8 WITH constant(cnvtdatetime((curdate - 1),0))
 DECLARE ms_info_domain = vc WITH constant("DM_STAT_UK_SPEC")
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
 CALL sbr_debug_timer("START_TOTAL","DM_STAT_GATHER_UK_SPEC")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
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
 DECLARE gatherlogical = i2 WITH noconstant(0)
 RANGE OF p IS prsnl
 IF (validate(p.logical_domain_id)=1)
  IF (validate(p.logical_domain_grp_id)=1)
   SET gatherlogical = 1
  ENDIF
 ENDIF
 FREE RANGE p
 IF (isfullrun=1)
  SET active_str = "(1)"
 ELSE
  SET active_str = "(1,0)"
 ENDIF
 CALL sbr_debug_timer("START","INSERTING UK_SPEC DATA")
 SELECT INTO "nl:"
  prsnl.person_id, uk_main_specialty_cd = cvg.child_code_value, uk_main_specialty_display =
  uar_get_code_display(cvg.child_code_value)
  FROM prsnl,
   prsnl_group_reltn,
   prsnl_group,
   code_value_group cvg
  WHERE prsnl.person_id=prsnl_group_reltn.person_id
   AND prsnl.active_ind=1
   AND prsnl_group_reltn.active_ind=1
   AND prsnl_group_reltn.prsnl_group_id=prsnl_group.prsnl_group_id
   AND prsnl_group_reltn.updt_dt_tm BETWEEN cnvtdatetime(ms_last_run_time) AND cnvtdatetime(
   ms_this_run_time)
   AND prsnl_group.prsnl_group_type_cd=cvg.parent_code_value
   AND cvg.code_set=3394
   AND prsnl_group.prsnl_group_type_cd IN (
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=357
    AND cv.cdf_meaning="SRVCATEGORY"))
  ORDER BY prsnl.person_id
  HEAD REPORT
   stat = alterlist(dsr->qual,1), dsr->qual[1].snapshot_type = ms_snapshot_type, dsr->qual[1].
   stat_snap_dt_tm = ms_snapshot_time,
   ds_cnt = 0
  DETAIL
   ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[1].qual[ds_cnt].stat_name = "UK_PRSNL_SPEC", dsr->qual[1].qual[ds_cnt].stat_type = 2,
   dsr->qual[1].qual[ds_cnt].stat_seq = (ds_cnt - 1),
   dsr->qual[1].qual[ds_cnt].stat_number_val = prsnl.person_id, dsr->qual[1].qual[ds_cnt].
   stat_clob_val = build(uk_main_specialty_cd,"{]|",uk_main_specialty_display)
  FOOT REPORT
   IF (ds_cnt=0)
    stat = alterlist(dsr->qual[1].qual,1), dsr->qual[1].qual[1].stat_name = "NO_NEW_DATA"
   ELSE
    stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 1)), dsr->qual[1].qual[(ds_cnt+ 1)].stat_name =
    "FULL_RUN_IND", dsr->qual[1].qual[(ds_cnt+ 1)].stat_number_val = isfullrun
   ENDIF
  WITH nullreport, nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
  GO TO exit_program
 ENDIF
 CALL sbr_debug_timer("END","INSERTING UK_SPEC DATA")
 CALL sbr_debug_timer("START","INSERTING DATA TO DB")
 EXECUTE dm_stat_snaps_load
 CALL sbr_debug_timer("END","INSERTING DATA TO DB")
 COMMIT
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(ms_this_run_time)
  WHERE di.info_domain=ms_info_domain
   AND di.info_name="LAST_RUN_TIME"
  WITH nocounter
 ;end update
 IF (cnvtdatetime(ms_last_run_time)=cnvtdatetime("01-JAN-1800 00:00:00"))
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(ms_this_run_time)
   WHERE di.info_domain=ms_info_domain
    AND di.info_name="LAST_FULL_RUN_TIME"
   WITH nocounter
  ;end update
 ENDIF
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
    WHERE di.info_domain=ms_info_domain
     AND di.info_name="DEBUG_IND"
    DETAIL
     mn_debug_ind = di.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = 0, di.info_domain = ms_info_domain, di.info_name = "DEBUG_IND"
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
   ENDIF
 END ;Subroutine
#exit_program
 CALL sbr_debug_timer("END_TOTAL","DM_STAT_GATHER_UK_SPEC")
END GO
