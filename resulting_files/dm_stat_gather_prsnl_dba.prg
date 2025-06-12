CREATE PROGRAM dm_stat_gather_prsnl:dba
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
 DECLARE ms_snapshot_type = vc WITH protect, constant("PRSNL_TABLE.4")
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE ds_cnt = i4
 FREE DEFINE active_str
 DECLARE active_str = vc
 DECLARE isfullrun = i2
 DECLARE dm_stat_snap_id = f8 WITH noconstant(0.0)
 DECLARE prsnl_type_cd = f8
 SET prsnl_type_cd = uar_get_code_by("MEANING",213,"PRSNL")
 DECLARE manage_acct = c1
 DECLARE chg_pwd = c1
 DECLARE pwd_exp = c1
 DECLARE manage_servers = c1
 DECLARE no_dis_user = c1
 DECLARE disabled = c1
 DECLARE imperson = c1
 DECLARE locked_pwd = c1
 DECLARE log_admin = c1
 DECLARE manage_reg = c1
 DECLARE manage_rel = c1
 DECLARE manage_res = c1
 DECLARE mod_servers = c1
 DECLARE query_sec = c1
 DECLARE reset_pwd = c1
 DECLARE system_acct = c1
 DECLARE trust_acct = c1
 DECLARE ms_last_run_time = dq8
 DECLARE ms_this_run_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE ms_snapshot_time = dq8 WITH constant(cnvtdatetime((curdate - 1),0))
 DECLARE ms_info_domain_old = vc WITH constant("DM_STAT_PRSNL")
 DECLARE ms_info_domain = vc WITH constant("DM_STAT_PRSNL.2")
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
 CALL sbr_debug_timer("START_TOTAL","DM_STAT_GATHER_PRSNL")
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
      curdate,curtime3))=2)) )
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
  SELECT INTO "nl:"
   FROM dm_stat_snaps di
   WHERE di.stat_snap_dt_tm >= cnvtdatetime((curdate - 1),0)
    AND (domain_name=reqdata->domain)
   DETAIL
    dm_stat_snap_id = di.dm_stat_snap_id
   WITH nocounter
  ;end select
  DELETE  FROM dm_stat_snaps_values d
   WHERE d.dm_stat_snap_id=dm_stat_snap_id
   WITH nocounter
  ;end delete
  DELETE  FROM dm_stat_snaps d
   WHERE d.dm_stat_snap_id=dm_stat_snap_id
   WITH nocounter
  ;end delete
  COMMIT
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
 CALL sbr_debug_timer("START","INSERTING PRSNL DATA")
 IF (gatherlogical=1)
  SELECT INTO "nl:"
   p.person_id, username = trim(p.username), lastname = trim(p.name_last),
   firstname = trim(p.name_first), formattedname = trim(p.name_full_formatted), email = trim(p.email),
   p.physician_ind, p.end_effective_dt_tm, p.position_cd,
   p.prsnl_type_cd, p.logical_domain_id, p.logical_domain_grp_id,
   p.active_ind
   FROM prsnl p
   WHERE sqlpassthru(build2("p.Active_ind +0 in ",active_str))
    AND trim(p.username) > ""
    AND trim(p.username) > " "
    AND ((p.person_id+ 0) > 0)
    AND p.updt_dt_tm BETWEEN cnvtdatetime(ms_last_run_time) AND cnvtdatetime(ms_this_run_time)
   HEAD REPORT
    stat = alterlist(dsr->qual,1), dsr->qual[1].snapshot_type = ms_snapshot_type, dsr->qual[1].
    stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
    ds_cnt = 0
   DETAIL
    ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[1].qual[ds_cnt].stat_name = "USER_INFO", dsr->qual[1].qual[ds_cnt].stat_type = 2, dsr->
    qual[1].qual[ds_cnt].stat_seq = (ds_cnt - 1),
    dsr->qual[1].qual[ds_cnt].stat_number_val = p.person_id, dsr->qual[1].qual[ds_cnt].stat_clob_val
     = build(username,"||",lastname,"||",firstname,
     "||",formattedname,"||",email,"||",
     p.physician_ind,"||",format(p.end_effective_dt_tm,"YYYYMMDDHHMMSS;;D"),"||",uar_get_code_display
     (p.position_cd),
     "||",uar_get_code_meaning(p.position_cd),"||",uar_get_code_display(p.prsnl_type_cd),"||",
     uar_get_code_meaning(p.prsnl_type_cd),"||",p.logical_domain_id,"||",p.logical_domain_grp_id,
     "||",p.active_ind)
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
   p.person_id, username = trim(p.username), lastname = trim(p.name_last),
   firstname = trim(p.name_first), formattedname = trim(p.name_full_formatted), email = trim(p.email),
   p.physician_ind, p.end_effective_dt_tm, p.position_cd,
   p.prsnl_type_cd, p.active_ind
   FROM prsnl p
   WHERE sqlpassthru(build2("p.Active_ind +0 in ",active_str))
    AND trim(p.username) > ""
    AND trim(p.username) > " "
    AND ((p.person_id+ 0) > 0)
    AND p.updt_dt_tm BETWEEN cnvtdatetime(ms_last_run_time) AND cnvtdatetime(ms_this_run_time)
   HEAD REPORT
    stat = alterlist(dsr->qual,1), dsr->qual[1].snapshot_type = ms_snapshot_type, dsr->qual[1].
    stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
    ds_cnt = 0
   DETAIL
    ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[1].qual[ds_cnt].stat_name = "USER_INFO", dsr->qual[1].qual[ds_cnt].stat_type = 2, dsr->
    qual[1].qual[ds_cnt].stat_seq = (ds_cnt - 1),
    dsr->qual[1].qual[ds_cnt].stat_number_val = p.person_id, dsr->qual[1].qual[ds_cnt].stat_clob_val
     = build(username,"||",lastname,"||",firstname,
     "||",formattedname,"||",email,"||",
     p.physician_ind,"||",format(p.end_effective_dt_tm,"YYYYMMDDHHMMSS;;D"),"||",uar_get_code_display
     (p.position_cd),
     "||",uar_get_code_meaning(p.position_cd),"||",uar_get_code_display(p.prsnl_type_cd),"||",
     uar_get_code_meaning(p.prsnl_type_cd),"||-1||-1||",p.active_ind)
   FOOT REPORT
    IF (ds_cnt=0)
     stat = alterlist(dsr->qual[1].qual,1), dsr->qual[1].qual[1].stat_name = "NO_NEW_DATA"
    ELSE
     stat = alterlist(dsr->qual[1].qual,ds_cnt)
    ENDIF
   WITH nullreport, nocounter
  ;end select
 ENDIF
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  pn.name_title
  FROM person_name pn,
   prsnl p,
   (dummyt d  WITH seq = size(dsr->qual[1].qual,5))
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=dsr->qual[1].qual[d.seq].stat_number_val))
   JOIN (pn
   WHERE pn.person_id=outerjoin(p.person_id)
    AND pn.name_type_cd=outerjoin(prsnl_type_cd)
    AND pn.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pn.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pn.active_ind=outerjoin(1))
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0
  HEAD d.seq
   dsr->qual[1].qual[d.seq].stat_clob_val = build2(dsr->qual[1].qual[d.seq].stat_clob_val,"||",trim(
     pn.name_title),"||")
  WITH nocounter
 ;end select
 IF (checkdic("EA_USER","T",0)=2)
  SELECT INTO "nl:"
   p.person_id, ea.attribute_name
   FROM prsnl p,
    ea_user e,
    ea_user_attribute_reltn eu,
    ea_attribute ea,
    (dummyt d  WITH seq = size(dsr->qual[1].qual,5))
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=dsr->qual[1].qual[d.seq].stat_number_val))
    JOIN (e
    WHERE outerjoin(p.username)=e.username)
    JOIN (eu
    WHERE eu.ea_user_id=outerjoin(e.ea_user_id))
    JOIN (ea
    WHERE ea.ea_attribute_id=outerjoin(eu.ea_attribute_id))
   HEAD REPORT
    cnt = 0
   HEAD d.seq
    cnt = 0, manage_acct = "0", chg_pwd = "0",
    pwd_exp = "0", manage_servers = "0", no_dis_user = "0",
    disabled = "0", imperson = "0", locked_pwd = "0",
    log_admin = "0", manage_reg = "0", manage_rel = "0",
    manage_res = "0", mod_servers = "0", query_sec = "0",
    reset_pwd = "0", system_acct = "0", trust_acct = "0"
   DETAIL
    cnt = (cnt+ 1)
    IF (ea.attribute_name="MANAGEACCOUNTS")
     manage_acct = "1"
    ELSEIF (ea.attribute_name="CHANGEPASSWORD")
     chg_pwd = "1"
    ELSEIF (ea.attribute_name="NOPASSWORDEXPIRE")
     pwd_exp = "1"
    ELSEIF (ea.attribute_name="MANAGESERVERS")
     manage_servers = "1"
    ELSEIF (ea.attribute_name="NOLOGFAILDISUSER")
     no_dis_user = "1"
    ELSEIF (ea.attribute_name="DISABLED")
     disabled = "1"
    ELSEIF (ea.attribute_name="IMPERSONATE")
     imperson = "1"
    ELSEIF (ea.attribute_name="LOCKEDPASSWORD")
     locked_pwd = "1"
    ELSEIF (ea.attribute_name="LOGICALDOMAINADMIN")
     log_admin = "1"
    ELSEIF (ea.attribute_name="MANAGEREGISTRY")
     manage_reg = "1"
    ELSEIF (ea.attribute_name="MANAGERELATIONS")
     manage_rel = "1"
    ELSEIF (ea.attribute_name="MANAGERESOURCES")
     manage_res = "1"
    ELSEIF (ea.attribute_name="MODIFYSERVERS")
     mod_servers = "1"
    ELSEIF (ea.attribute_name="QUERYSECURITY")
     query_sec = "1"
    ELSEIF (ea.attribute_name="RESETPASSWORD")
     reset_pwd = "1"
    ELSEIF (ea.attribute_name="SYSTEMACCOUNT")
     system_acct = "1"
    ELSEIF (ea.attribute_name="TRUSTACCOUNT")
     trust_acct = "1"
    ENDIF
   FOOT  d.seq
    dsr->qual[1].qual[d.seq].stat_clob_val = build2(dsr->qual[1].qual[d.seq].stat_clob_val,
     manage_acct,"||",chg_pwd,"||",
     pwd_exp,"||",manage_servers,"||",no_dis_user,
     "||",disabled,"||",imperson,"||",
     locked_pwd,"||",log_admin,"||",manage_reg,
     "||",manage_rel,"||",manage_res,"||",
     mod_servers,"||",query_sec,"||",reset_pwd,
     "||",system_acct,"||",trust_acct,"||")
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM prsnl p,
    (dummyt d  WITH seq = size(dsr->qual[1].qual,5))
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=dsr->qual[1].qual[d.seq].stat_number_val))
   ORDER BY d.seq
   DETAIL
    dsr->qual[1].qual[d.seq].stat_clob_val = build2(dsr->qual[1].qual[d.seq].stat_clob_val,"-1","||",
     "-1","||",
     "-1","||","-1","||","-1",
     "||","-1","||","-1","||",
     "-1","||","-1","||","-1",
     "||","-1","||","-1","||",
     "-1","||","-1","||","-1",
     "||","-1","||","-1","||")
   WITH nocounter
  ;end select
 ENDIF
 CALL sbr_debug_timer("END","INSERTING PRSNL DATA")
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
    WHERE di.info_domain="DM_STAT_GATHER_PRSNL.2"
     AND di.info_name="DEBUG_IND"
    DETAIL
     mn_debug_ind = di.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = 0, di.info_domain = "DM_STAT_GATHER_PRSNL.2", di.info_name = "DEBUG_IND"
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmreturn)
   ENDIF
 END ;Subroutine
#exit_program
 CALL sbr_debug_timer("END_TOTAL","dm_stat_gather_prsnl")
END GO
