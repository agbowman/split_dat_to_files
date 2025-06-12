CREATE PROGRAM dm_stat_ue_bedrock:dba
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
 DECLARE ds_begin_snapshot = dq8 WITH noconstant(cnvtdatetime((curdate - 1),0))
 DECLARE ds_end_snapshot = dq8 WITH constant(cnvtdatetime((curdate - 1),235959))
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE ds_cnt = i4 WITH noconstant(0)
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
 CALL sbr_debug_timer("START_TOTAL","DM_STAT_UE_BEDROCK")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 CALL sbr_debug_timer("START","INSERTING BEDROCK DATA")
 SELECT INTO "nl:"
  p.person_id, p.username, p.name_last,
  p.name_first, p.name_full_formatted, p.email,
  p.physician_ind, p.position_cd, wizard = cir2.item_display,
  solution = cir1.item_display, b.solution_mean, b.wizard_mean,
  dvsm_ret = count(*)
  FROM br_wizard_hist b,
   prsnl p,
   br_client_item_reltn cir1,
   br_client_item_reltn cir2
  PLAN (b
   WHERE b.log_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (p
   WHERE p.person_id=b.prsnl_id)
   JOIN (cir1
   WHERE cir1.item_type="STEP"
    AND cir1.item_mean=b.wizard_mean)
   JOIN (cir2
   WHERE cir2.item_type="SOLUTION"
    AND cir2.item_mean=b.solution_mean)
  GROUP BY p.person_id, p.username, p.name_last,
   p.name_first, p.name_full_formatted, p.email,
   p.physician_ind, p.position_cd, cir2.item_display,
   cir1.item_display, b.solution_mean, b.wizard_mean
  ORDER BY b.solution_mean, b.wizard_mean, p.person_id
  HEAD REPORT
   stat = alterlist(dsr->qual,1), dsr->qual[1].stat_snap_dt_tm = cnvtdatetime((curdate - 1),0), dsr->
   qual[1].snapshot_type = "BEDROCK_USAGE",
   ds_cnt = 0
  DETAIL
   ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[1].qual[ds_cnt].stat_name = "BEDROCK_USAGE", dsr->qual[1].qual[ds_cnt].stat_number_val
    = dvsm_ret, dsr->qual[1].qual[ds_cnt].stat_seq = ds_cnt,
   dsr->qual[1].qual[ds_cnt].stat_clob_val = build(trim(p.username),"||",trim(p.name_last),"||",trim(
     p.name_first),
    "||",trim(p.name_full_formatted),"||",trim(p.email),"||",
    p.physician_ind,"||",uar_get_code_display(p.position_cd),"||",uar_get_code_meaning(p.position_cd),
    "||",cnvtstring(p.person_id,11,2),"||",trim(b.solution_mean),"||",
    trim(b.wizard_mean),"||",trim(wizard),"||",trim(solution))
  FOOT REPORT
   IF (ds_cnt=0)
    stat = alterlist(dsr->qual[1].qual,1), dsr->qual[1].qual[ds_cnt].stat_name = "NO_NEW_DATA"
   ELSE
    stat = alterlist(dsr->qual[1].qual,ds_cnt)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL sbr_debug_timer("END","INSERTING BEDROCK DATA")
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
    WHERE di.info_domain="DM_STAT_UE_BEDROCK"
     AND di.info_name="DEBUG_IND"
    DETAIL
     mn_debug_ind = di.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = 0, di.info_domain = "DM_STAT_UE_BEDROCK", di.info_name = "DEBUG_IND"
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
   ENDIF
 END ;Subroutine
#exit_program
 CALL sbr_debug_timer("END_TOTAL","DM_STAT_UE_BEDROCK")
END GO
