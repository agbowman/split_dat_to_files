CREATE PROGRAM ags_plan_load:dba
 PROMPT
  "TASK_ID (0.0) = " = 0.0
  WITH dtid
 SET ags_plan_load_mod = "002 11/30/06"
 CALL echo("<===== AGS_PLAN_LOAD Begin =====>")
 CALL echo(concat("MOD:",ags_plan_load_mod))
 DECLARE define_logging_sub = i2 WITH public, noconstant(false)
 FREE RECORD holdrec
 RECORD holdrec(
   1 qual_cnt = i4
   1 qual[*]
     2 insert_ind = i4
     2 error_ind = i4
     2 ags_plan_data_id = f8
     2 contrib_sys_idx = i4
     2 ext_alias = vc
     2 ssn_alias = vc
     2 person_id = f8
     2 plan_alias = vc
     2 health_plan_id = f8
     2 name_first = vc
     2 name_last = vc
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 person_rx_plan_reltn_id = f8
     2 plan_type = vc
     2 elig_start_dt_tm = dq8
     2 elig_end_dt_tm = dq8
     2 status = c10
     2 stat_msg = c40
 )
 FREE RECORD contribrec
 RECORD contribrec(
   1 qual_cnt = i4
   1 qual[*]
     2 sending_facility = vc
     2 contributor_system_cd = f8
     2 contributor_source_cd = f8
     2 prsnl_person_id = f8
     2 time_zone = vc
     2 time_zone_idx = i4
     2 ext_alias_pool_cd = f8
     2 ext_alias_type_cd = f8
     2 ssn_alias_pool_cd = f8
     2 ssn_alias_type_cd = f8
     2 plan_alias_pool_cd = f8
     2 plan_alias_type_cd = f8
 )
 IF (validate(log,"!")="!")
  EXECUTE cclseclogin2
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  FREE RECORD email
  RECORD email(
    1 qual_knt = i4
    1 qual[*]
      2 address = vc
      2 send_flag = i2
  )
  FREE RECORD log
  RECORD log(
    1 qual_knt = i4
    1 qual[*]
      2 smsgtype = c12
      2 dmsg_dt_tm = dq8
      2 smsg = vc
  )
  SET define_logging_sub = true
  DECLARE gen_nbr_error = i2 WITH public, noconstant(3)
  DECLARE insert_error = i2 WITH public, noconstant(4)
  DECLARE update_error = i2 WITH public, noconstant(5)
  DECLARE delete_error = i2 WITH public, noconstant(6)
  DECLARE select_error = i2 WITH public, noconstant(7)
  DECLARE lock_error = i2 WITH public, noconstant(8)
  DECLARE input_error = i2 WITH public, noconstant(9)
  DECLARE exe_error = i2 WITH public, noconstant(10)
  DECLARE failed = i2 WITH public, noconstant(false)
  DECLARE table_name = c50 WITH public, noconstant(" ")
  DECLARE serrmsg = vc WITH public, noconstant(" ")
  DECLARE ierrcode = i2 WITH public, noconstant(0)
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
  DECLARE sstatus_file_name = vc WITH public, constant(concat("ags_plan_load_",format(cnvtdatetime(
      curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
 ENDIF
 DECLARE dtaskid = f8 WITH public, constant(cnvtreal( $DTID))
 DECLARE staskid = vc WITH public, constant(trim(cnvtstring(dtaskid)))
 DECLARE lidx = i4 WITH public, noconstant(0)
 DECLARE lidx2 = i4 WITH public, noconstant(0)
 DECLARE lnum = i4 WITH public, noconstant(0)
 DECLARE lpos = i4 WITH public, noconstant(0)
 DECLARE lbatchsize = i4 WITH public, noconstant(0)
 DECLARE ldefaultbatchsize = i4 WITH public, constant(1000)
 DECLARE lkillind = i4 WITH public, noconstant(0)
 DECLARE lmodeflag = i4 WITH public, noconstant(0)
 DECLARE lloglevel = i4 WITH public, noconstant(0)
 DECLARE litcount = i4 WITH public, noconstant(0)
 DECLARE lcontribsysidx = i4 WITH public, noconstant(0)
 DECLARE ljobcontribsysidx = i4 WITH public, noconstant(0)
 DECLARE lavgsec = i4 WITH public, noconstant(0)
 DECLARE lcurmin = i4 WITH public, constant(cnvtmin2(curdate,curtime))
 DECLARE ltotal = i4 WITH public, noconstant(0)
 DECLARE dagsjobid = f8 WITH public, noconstant(0.0)
 DECLARE dbatchstartid = f8 WITH public, noconstant(0.0)
 DECLARE dbatchendid = f8 WITH public, noconstant(0.0)
 DECLARE dstartid = f8 WITH public, noconstant(0.0)
 DECLARE dendid = f8 WITH public, noconstant(0.0)
 DECLARE ssendingfacility = vc WITH public, noconstant(" ")
 DECLARE sextalias = vc WITH public, noconstant(" ")
 DECLARE sssnalias = vc WITH public, noconstant(" ")
 DECLARE sgender = vc WITH public, noconstant(" ")
 DECLARE sstatusmsg = vc WITH public, noconstant(" ")
 DECLARE dtmax = dq8 WITH public, constant(cnvtdatetime("31-DEC-2100 00:00:00.00"))
 DECLARE dtcurrent = dq8 WITH public, constant(cnvtdatetime(curdate,curtime2))
 DECLARE dtitstart = dq8 WITH public, noconstant
 DECLARE dtitend = dq8 WITH public, noconstant
 DECLARE dtestcompletion = dq8 WITH public, noconstant
 DECLARE dmalesexcd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"MALE"))
 DECLARE dfemalesexcd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"FEMALE"))
 DECLARE dunknownsexcd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"UNKNOWN"))
 DECLARE dextaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PRSNEXTALIAS"
   ))
 DECLARE dssnaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PRSNSSN"))
 DECLARE dplanaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "PLANEXTALIAS"))
 DECLARE dactiveactivestatuscd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE ddefaultsrccd = f8 WITH public, constant(uar_get_code_by("MEANING",73,"DEFAULT"))
 IF (dmalesexcd < 1)
  SET failed = select_error
  SET table_name = "dMaleSexCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING MALE Default from CODE_SET 57"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dfemalesexcd < 1)
  SET failed = select_error
  SET table_name = "dFemaleSexCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING FEMALE Default from CODE_SET 57"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dunknownsexcd < 1)
  SET failed = select_error
  SET table_name = "dUnknownSexCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING UNKNOWN Default from CODE_SET 57"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dextaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dEXTAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING PSNLEXTALIAS Default from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dssnaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dSSNAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING PRSNSSN Default from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dplanaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dPlanAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING PLANEXTALIAS Default from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dactiveactivestatuscd < 1)
  SET failed = select_error
  SET table_name = "dActiveActiveStatusCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING ACTIVE Default from CODE_SET 48"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (ddefaultsrccd < 1)
  SET failed = select_error
  SET table_name = "dDefaultSrcCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING DEFAULT Default from CODE_SET 73"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get AGS_TASK & AGS_JOB Info")
 CALL echo("***")
 CALL echo(build("dTaskId  :",dtaskid))
 SELECT INTO "nl:"
  FROM ags_task t,
   ags_job j
  PLAN (t
   WHERE t.ags_task_id=dtaskid)
   JOIN (j
   WHERE j.ags_job_id=t.ags_job_id)
  ORDER BY j.ags_job_id, t.ags_task_id
  HEAD j.ags_job_id
   dagsjobid = j.ags_job_id, ljobcontribsysidx = (contribrec->qual_cnt+ 1), contribrec->qual_cnt =
   ljobcontribsysidx,
   stat = alterlist(contribrec->qual,ljobcontribsysidx), contribrec->qual[ljobcontribsysidx].
   sending_facility = trim(j.sending_system)
  HEAD t.ags_task_id
   IF (t.iteration_start_id > 0.0)
    dbatchstartid = t.iteration_start_id
   ELSE
    dbatchstartid = t.batch_start_id
   ENDIF
   dbatchendid = t.batch_end_id
   IF (t.batch_size > 0)
    lbatchsize = t.batch_size
   ELSE
    lbatchsize = ldefaultbatchsize
   ENDIF
   lmodeflag = t.mode_flag, lkillind = t.kill_ind, lloglevel = t.timers_flag
  FOOT REPORT
   dstartid = dbatchstartid
   IF (((dbatchstartid+ lbatchsize) >= dbatchendid))
    dendid = dbatchendid
   ELSE
    dendid = ((dbatchstartid+ lbatchsize) - 1)
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"INVALID TASK_ID :: ",staskid
   )
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (curqual < 1)
  SET failed = select_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID TASK_ID :: ",staskid)
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo(build("dAgsJobId:",dagsjobid))
 IF (lloglevel > 0)
  CALL turn_on_tracing(null)
 ELSE
  CALL turn_off_tracing(null)
 ENDIF
 IF (((lmodeflag=2) OR (lmodeflag=3)) )
  IF (dbatchstartid <= 0)
   SELECT INTO "nl:"
    min_id = min(r.ags_plan_data_id)
    FROM ags_plan_data r
    WHERE r.ags_plan_data_id > 0.0
    HEAD REPORT
     junk = 0
    FOOT REPORT
     dbatchstartid = min_id
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "AGS_PLAN_DATA"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("MIN :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
  ENDIF
  IF (dbatchendid <= 0)
   CASE (lmodeflag)
    OF 2:
     SELECT INTO "nl:"
      max_id = max(r.ags_plan_data_id), total = count(r.ags_plan_data_id)
      FROM ags_plan_data r
      WHERE r.ags_plan_data_id >= 0.0
       AND ((r.person_rx_plan_reltn_id+ 0)=0.0)
      HEAD REPORT
       junk = 0
      FOOT REPORT
       dbatchendid = max_id, ltotal = total
      WITH nocounter
     ;end select
    OF 3:
     SELECT INTO "nl:"
      max_id = max(r.ags_plan_data_id), total = count(r.ags_plan_data_id)
      FROM ags_plan_data r
      WHERE r.ags_plan_data_id >= dbatchstartid
       AND ((r.person_rx_plan_reltn_id+ 0)=0)
       AND trim(r.status) IN ("IN ERROR", "BACK OUT")
      HEAD REPORT
       junk = 0
      FOOT REPORT
       dbatchendid = max_id, ltotal = total
      WITH nocounter
     ;end select
   ENDCASE
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "MAX"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("MAX :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   IF (curqual < 1)
    SET failed = select_error
    SET table_name = "MODE CHK"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("MODE CHK :: Select Error :: Curqual < 1 ")
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   IF (ltotal <= lbatchsize)
    SET dendid = dbatchendid
   ELSE
    SET dendid = ((dbatchstartid+ lbatchsize) - 1)
   ENDIF
   CALL echo(build("New BATCH_END_ID: ",dbatchendid))
   UPDATE  FROM ags_task t
    SET t.batch_start_id = dbatchstartid, t.batch_end_id = dbatchendid, t.updt_dt_tm = cnvtdatetime(
      dtcurrent),
     t.updt_cnt = (t.updt_cnt+ 1), t.updt_task = 424990, t.updt_applctx = 424990
    WHERE t.ags_task_id=dtaskid
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_TASK"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_TASK :: BATCH_END_ID update Error :: ",trim(
      serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   COMMIT
  ENDIF
 ENDIF
 CALL echo(build("dBatchStartId : ",dbatchstartid))
 CALL echo(build("dBatchEndId   : ",dbatchendid))
 CALL echo(build("dStartId      : ",dstartid))
 CALL echo(build("dEndId        : ",dendid))
 CALL echo(build("lModeFlag     : ",lmodeflag))
 CALL echo(build("lKillInd      : ",lkillind))
 CALL echo(build("lLogLevel     : ",lloglevel))
 IF (dtaskid > 0)
  UPDATE  FROM ags_task t
   SET t.status = "PROCESSING", t.status_dt_tm = cnvtdatetime(dtcurrent), t.batch_start_dt_tm = t
    .status_dt_tm,
    t.batch_end_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00.00"), t.updt_dt_tm = cnvtdatetime(
     dtcurrent), t.updt_cnt = (t.updt_cnt+ 1),
    t.updt_task = 424990, t.updt_applctx = 424990
   WHERE t.ags_task_id=dtaskid
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg)," TASK_ID :: ",staskid)
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 WHILE (dstartid <= dendid
  AND lkillind <= 0)
   SET lidx = 0
   SET ditstartid = 0.0
   SET ditendid = 0.0
   SET lrowcnt = 0
   SET dtitstart = cnvtdatetime(curdate,curtime2)
   SET stat = initrec(holdrec)
   SELECT
    IF (lmodeflag=0)
     PLAN (a
      WHERE a.ags_plan_data_id >= dstartid
       AND a.ags_plan_data_id <= dendid
       AND ((a.ags_job_id+ 0)=dagsjobid)
       AND ((a.person_rx_plan_reltn_id+ 0)=0)
       AND trim(a.status)="WAITING")
    ELSEIF (lmodeflag=1)
     PLAN (a
      WHERE a.ags_plan_data_id >= dstartid
       AND a.ags_plan_data_id <= dendid
       AND ((a.ags_job_id+ 0)=dagsjobid))
    ELSEIF (lmodeflag=2)
     PLAN (a
      WHERE a.ags_plan_data_id >= dstartid
       AND a.ags_plan_data_id <= dendid
       AND ((a.person_rx_plan_reltn_id+ 0)=0))
    ELSEIF (lmodeflag=3)
     PLAN (a
      WHERE a.ags_plan_data_id >= dstartid
       AND a.ags_plan_data_id <= dendid
       AND ((a.person_rx_plan_reltn_id+ 0)=0)
       AND trim(a.status) IN ("IN ERROR", "HOLD", "BACK OUT"))
    ELSE
    ENDIF
    INTO "nl:"
    FROM ags_plan_data a
    ORDER BY a.ags_plan_data_id
    HEAD a.ags_plan_data_id
     berror = false, lrowcnt = (lrowcnt+ 1), ditendid = a.ags_plan_data_id,
     sstatusmsg = " "
     IF (ditstartid <= 0.0)
      ditstartid = a.ags_plan_data_id
     ENDIF
     lidx = (lidx+ 1), holdrec->qual_cnt = lidx, stat = alterlist(holdrec->qual,lidx),
     holdrec->qual[lidx].ags_plan_data_id = a.ags_plan_data_id, holdrec->qual[lidx].person_id = a
     .person_id, holdrec->qual[lidx].health_plan_id = a.health_plan_id,
     holdrec->qual[lidx].person_rx_plan_reltn_id = a.person_rx_plan_reltn_id, ssendingfacility = trim
     (a.sending_facility,3)
     IF (size(ssendingfacility) > 0)
      lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual_cnt,ssendingfacility,contribrec->
       qual[lnum].sending_facility)
      IF (lpos <= 0)
       lcontribsysidx = (contribrec->qual_cnt+ 1), contribrec->qual_cnt = lcontribsysidx, stat =
       alterlist(contribrec->qual,lcontribsysidx),
       contribrec->qual[lcontribsysidx].sending_facility = ssendingfacility
      ELSE
       lcontribsysidx = lpos
      ENDIF
     ELSE
      lcontribsysidx = ljobcontribsysidx
     ENDIF
     holdrec->qual[lidx].contrib_sys_idx = lcontribsysidx
     IF ((holdrec->qual[lidx].contrib_sys_idx <= 0))
      berror = true, sstatusmsg = concat(sstatusmsg,"[c]m")
     ENDIF
     sextalias = trim(a.ext_alias)
     IF (size(sextalias) > 0)
      holdrec->qual[lidx].ext_alias = trim(sextalias)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[x]am")
     ENDIF
     sssnalias = trim(a.ssn_alias)
     IF (size(sssnalias) > 0)
      holdrec->qual[lidx].ssn_alias = trim(sssnalias)
     ELSE
      sstatusmsg = concat(sstatusmsg,"[s]am")
     ENDIF
     splanalias = trim(a.plan_alias)
     IF (size(splanalias) > 0)
      holdrec->qual[lidx].plan_alias = trim(splanalias)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[pal]am")
     ENDIF
     holdrec->qual[lidx].plan_type = a.plan_type
     IF (size(trim(a.name_first)) > 0)
      holdrec->qual[lidx].name_first = trim(a.name_first)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[f]m")
     ENDIF
     IF (size(trim(a.name_last)) > 0)
      holdrec->qual[lidx].name_last = trim(a.name_last)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[l]m")
     ENDIF
     holdrec->qual[lidx].birth_dt_tm = cnvtdate2(trim(a.birth_date,3),"YYYYMMDD"), sgender = trim(a
      .gender,3)
     IF (sgender="M")
      holdrec->qual[lidx].sex_cd = dmalesexcd
     ELSEIF (sgender="F")
      holdrec->qual[lidx].sex_cd = dfemalesexcd
     ELSE
      holdrec->qual[lidx].sex_cd = dunknownsexcd
     ENDIF
     IF (size(trim(a.elig_start_date,3)) > 0)
      IF (cnvtmin2(cnvtdate2(trim(a.elig_start_date,3),"YYYYMMDD"),curtime) < lcurmin)
       holdrec->qual[lidx].elig_start_dt_tm = cnvtdate2(trim(a.elig_start_date,3),"YYYYMMDD")
      ELSE
       holdrec->qual[lidx].elig_start_dt_tm = cnvtdate(dtcurrent)
      ENDIF
     ENDIF
     IF (size(trim(a.elig_end_date,3)) > 0)
      holdrec->qual[lidx].elig_end_dt_tm = cnvtdate2(trim(a.elig_end_date,3),"YYYYMMDD")
     ENDIF
     IF (berror)
      holdrec->qual[lidx].error_ind = true, holdrec->qual[lidx].status = "IN ERROR", holdrec->qual[
      lidx].stat_msg = trim(sstatusmsg,3)
     ENDIF
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "AGS_PLAN_DATA"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
    GO TO exit_script
   ENDIF
   IF ((holdrec->qual_cnt > 0))
    CALL echo("***")
    CALL echo("***   CONTRIBUTOR_SYSTEM_CD Lookup")
    CALL echo("***")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(contribrec->qual_cnt)),
      code_value_alias cva,
      contributor_system cs,
      esi_alias_trans eat
     PLAN (d
      WHERE (contribrec->qual[d.seq].contributor_source_cd <= 0.0))
      JOIN (cva
      WHERE cva.code_set=89
       AND cva.contributor_source_cd=ddefaultsrccd
       AND cva.alias=trim(contribrec->qual[d.seq].sending_facility))
      JOIN (cs
      WHERE cs.contributor_system_cd=cva.code_value
       AND cs.active_ind=1)
      JOIN (eat
      WHERE eat.contributor_system_cd=cs.contributor_system_cd
       AND eat.active_ind=1)
     ORDER BY cs.contributor_system_cd, eat.esi_alias_field_cd
     HEAD cs.contributor_system_cd
      contribrec->qual[d.seq].contributor_system_cd = cs.contributor_system_cd, contribrec->qual[d
      .seq].contributor_source_cd = cs.contributor_source_cd, contribrec->qual[d.seq].prsnl_person_id
       = cs.prsnl_person_id,
      contribrec->qual[d.seq].time_zone = cs.time_zone, contribrec->qual[d.seq].time_zone_idx =
      datetimezonebyname(contribrec->qual[d.seq].time_zone)
     HEAD eat.esi_alias_field_cd
      IF (eat.esi_alias_field_cd=dextaliasfieldcd)
       contribrec->qual[d.seq].ext_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       ext_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (eat.esi_alias_field_cd=dssnaliasfieldcd)
       contribrec->qual[d.seq].ssn_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       ssn_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (eat.esi_alias_field_cd=dplanaliasfieldcd)
       contribrec->qual[d.seq].plan_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       plan_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CODE_VALUE_ALIAS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
     GO TO exit_script
    ENDIF
    IF (lloglevel > 1)
     CALL echorecord(contribrec)
    ENDIF
    CALL echo(curtime3)
    CALL echo("***")
    CALL echo("***   EXT_ALIAS Look Up")
    CALL echo("***")
    SELECT INTO "nl:"
     FROM person_alias pa,
      (dummyt d  WITH seq = value(holdrec->qual_cnt))
     PLAN (d
      WHERE (holdrec->qual[d.seq].error_ind=0)
       AND (holdrec->qual[d.seq].person_id <= 0.0)
       AND trim(holdrec->qual[d.seq].ext_alias) > " "
       AND (contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].contributor_system_cd > 0.0))
      JOIN (pa
      WHERE pa.alias=trim(holdrec->qual[d.seq].ext_alias)
       AND (pa.alias_pool_cd=contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].ext_alias_pool_cd
      )
       AND (pa.person_alias_type_cd=contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].
      ext_alias_type_cd)
       AND pa.active_ind != 0)
     DETAIL
      holdrec->qual[d.seq].person_id = pa.person_id
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "PERSON_ALIAS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("EXT_ALIAS :: ",trim(holdrec->qual[lidx].ext_alias),
      " :: ErrMsg :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   SSN Look Up")
    CALL echo("***")
    SELECT INTO "nl:"
     FROM person_alias pa,
      person p,
      (dummyt d  WITH seq = value(holdrec->qual_cnt))
     PLAN (d
      WHERE (holdrec->qual[d.seq].error_ind=0)
       AND (holdrec->qual[d.seq].person_id <= 0.0)
       AND trim(holdrec->qual[d.seq].ssn_alias) > " "
       AND (contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].contributor_system_cd > 0.0))
      JOIN (pa
      WHERE pa.alias=trim(holdrec->qual[d.seq].ssn_alias)
       AND (pa.alias_pool_cd=contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].ssn_alias_pool_cd
      )
       AND (pa.person_alias_type_cd=contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].
      ssn_alias_type_cd)
       AND pa.active_ind != 0)
      JOIN (p
      WHERE p.person_id=pa.person_id
       AND p.abs_birth_dt_tm=datetimezone(holdrec->qual[d.seq].birth_dt_tm,contribrec->qual[holdrec->
       qual[d.seq].contrib_sys_idx].time_zone_idx,1)
       AND p.name_first_key=cnvtupper(cnvtalphanum(holdrec->qual[d.seq].name_first))
       AND p.name_last_key=cnvtupper(cnvtalphanum(holdrec->qual[d.seq].name_last))
       AND (p.sex_cd=holdrec->qual[d.seq].sex_cd)
       AND p.active_ind != 0)
     DETAIL
      holdrec->qual[d.seq].person_id = p.person_id
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "PERSON_ALIAS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("SSN_ALIAS :: ",trim(holdrec->qual[lidx].ssn_alias),
      " :: ErrMsg :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   PLAN_ALIAS Look Up")
    CALL echo("***")
    SELECT INTO "nl:"
     FROM health_plan_alias ha,
      (dummyt d  WITH seq = value(holdrec->qual_cnt))
     PLAN (d
      WHERE (holdrec->qual[d.seq].error_ind=0)
       AND (holdrec->qual[d.seq].health_plan_id <= 0.0)
       AND trim(holdrec->qual[d.seq].plan_alias) > " "
       AND (contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].contributor_system_cd > 0.0))
      JOIN (ha
      WHERE ha.alias=trim(holdrec->qual[d.seq].plan_alias)
       AND (ha.alias_pool_cd=contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].
      plan_alias_pool_cd)
       AND (ha.plan_alias_type_cd=contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].
      plan_alias_type_cd)
       AND ha.active_ind != 0)
     DETAIL
      holdrec->qual[d.seq].health_plan_id = ha.health_plan_id
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "HEALTH_PLAN_ALIAS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("PLAN_ALIAS :: ",trim(holdrec->qual[lidx].plan_alias),
      " :: ErrMsg :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Check for look up errors")
    CALL echo("***")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(holdrec->qual_cnt))
     WHERE d.seq > 0
      AND (holdrec->qual[d.seq].error_ind=0)
     DETAIL
      sstatusmsg = " "
      IF ((holdrec->qual[d.seq].person_id=0.0))
       holdrec->qual[d.seq].error_ind = 1, sstatusmsg = concat(sstatusmsg,"[x]lf"), sstatusmsg =
       concat(sstatusmsg,"[s]lf")
      ENDIF
      IF ((holdrec->qual[d.seq].health_plan_id=0.0))
       holdrec->qual[d.seq].error_ind = 1, sstatusmsg = concat(sstatusmsg,"[hp]lf")
      ENDIF
      IF ((contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].contributor_system_cd=0.0))
       holdrec->qual[d.seq].error_ind = 1, sstatusmsg = concat(sstatusmsg,"[c]lf")
      ENDIF
      IF ((holdrec->qual[d.seq].error_ind != 0))
       holdrec->qual[d.seq].stat_msg = concat(trim(holdrec->qual[d.seq].stat_msg,3),trim(sstatusmsg,3
         ))
      ENDIF
     WITH nocounter
    ;end select
    CALL echo("***")
    CALL echo("***   Select existing PERSON_RX_PLAN_RELTN row")
    CALL echo("***")
    SELECT INTO "nl:"
     FROM person_rx_plan_reltn r,
      (dummyt d  WITH seq = value(holdrec->qual_cnt))
     PLAN (d
      WHERE (holdrec->qual[d.seq].error_ind=0)
       AND (holdrec->qual[d.seq].health_plan_id > 0.0)
       AND (holdrec->qual[d.seq].person_id > 0.0))
      JOIN (r
      WHERE (r.health_plan_id=holdrec->qual[d.seq].health_plan_id)
       AND (r.person_id=holdrec->qual[d.seq].person_id)
       AND r.active_ind != 0)
     ORDER BY r.rx_plan_end_dt_tm
     DETAIL
      holdrec->qual[d.seq].person_rx_plan_reltn_id = r.person_rx_plan_reltn_id
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "PERSON_RX_PLAN_RELTN"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF (lloglevel > 1)
     CALL echorecord(holdrec)
    ENDIF
    CALL echo("***")
    CALL echo("***   Update PERSON_RX_PLAN_RELTN")
    CALL echo("***")
    UPDATE  FROM person_rx_plan_reltn r,
      (dummyt d  WITH seq = value(holdrec->qual_cnt))
     SET r.rx_plan_beg_dt_tm =
      IF ((holdrec->qual[d.seq].elig_start_dt_tm > 0)) cnvtdate(holdrec->qual[d.seq].elig_start_dt_tm
        )
      ELSE r.rx_plan_beg_dt_tm
      ENDIF
      , r.rx_plan_end_dt_tm =
      IF ((holdrec->qual[d.seq].elig_end_dt_tm > 0)) cnvtdate(holdrec->qual[d.seq].elig_end_dt_tm)
      ELSE r.rx_plan_end_dt_tm
      ENDIF
      , r.updt_applctx = 424990,
      r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm = cnvtdatetime(dtcurrent), r.updt_id = contribrec->
      qual[holdrec->qual[d.seq].contrib_sys_idx].prsnl_person_id,
      r.updt_task = 424990
     PLAN (d
      WHERE (holdrec->qual[d.seq].error_ind=0)
       AND (holdrec->qual[d.seq].person_rx_plan_reltn_id > 0.0))
      JOIN (r
      WHERE (r.person_rx_plan_reltn_id=holdrec->qual[d.seq].person_rx_plan_reltn_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "PERSON_RX_PLAN_RELTN"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Get PERSON_RX_PLAN_RELTN_IDs")
    CALL echo("***")
    FOR (lidx = 1 TO holdrec->qual_cnt)
      IF ((holdrec->qual[lidx].error_ind=0)
       AND (holdrec->qual[lidx].person_rx_plan_reltn_id=0.0))
       SELECT INTO "nl:"
        y = seq(person_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         holdrec->qual[lidx].insert_ind = 1, holdrec->qual[lidx].person_rx_plan_reltn_id = cnvtreal(y
          )
        WITH format, nocounter
       ;end select
      ENDIF
    ENDFOR
    CALL echo("***")
    CALL echo("***   Insert PERSON_RX_PLAN_RELTN")
    CALL echo("***")
    INSERT  FROM person_rx_plan_reltn r,
      (dummyt d  WITH seq = value(holdrec->qual_cnt))
     SET r.person_rx_plan_reltn_id = holdrec->qual[d.seq].person_rx_plan_reltn_id, r
      .contributor_system_cd = contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].
      contributor_system_cd, r.data_build_flag = 1,
      r.health_plan_id = holdrec->qual[d.seq].health_plan_id, r.person_id = holdrec->qual[d.seq].
      person_id, r.interchange_id = 0.0,
      r.interchange_seq = 0, r.priority_seq = 0, r.rx_plan_beg_dt_tm =
      IF ((holdrec->qual[d.seq].elig_start_dt_tm > 0)) cnvtdate(holdrec->qual[d.seq].elig_start_dt_tm
        )
      ELSE cnvtdatetime(dtcurrent)
      ENDIF
      ,
      r.rx_plan_end_dt_tm =
      IF ((holdrec->qual[d.seq].elig_end_dt_tm > 0)) cnvtdate(holdrec->qual[d.seq].elig_end_dt_tm)
      ELSE cnvtdatetime(dtmax)
      ENDIF
      , r.beg_effective_dt_tm = cnvtdatetime(dtcurrent), r.end_effective_dt_tm = cnvtdatetime(dtmax),
      r.active_ind = 1, r.active_status_cd = dactiveactivestatuscd, r.active_status_dt_tm =
      cnvtdatetime(dtcurrent),
      r.active_status_prsnl_id = contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].
      prsnl_person_id, r.updt_applctx = 424990, r.updt_cnt = 0,
      r.updt_dt_tm = cnvtdatetime(dtcurrent), r.updt_id = contribrec->qual[holdrec->qual[d.seq].
      contrib_sys_idx].prsnl_person_id, r.updt_task = 424990
     PLAN (d
      WHERE (holdrec->qual[d.seq].error_ind=0)
       AND (holdrec->qual[d.seq].insert_ind=1))
      JOIN (r
      WHERE (holdrec->qual[d.seq].person_rx_plan_reltn_id > 0.0)
       AND (holdrec->qual[d.seq].health_plan_id > 0.0)
       AND (holdrec->qual[d.seq].person_id > 0.0))
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "PERSON_RX_PLAN_RELTN"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Update AGS_PLAN_DATA")
    CALL echo("***")
    UPDATE  FROM ags_plan_data r,
      (dummyt d  WITH seq = value(holdrec->qual_cnt))
     SET r.person_rx_plan_reltn_id =
      IF ((holdrec->qual[d.seq].error_ind=0)) holdrec->qual[d.seq].person_rx_plan_reltn_id
      ELSE 0.0
      ENDIF
      , r.contributor_system_cd =
      IF ((holdrec->qual[d.seq].error_ind=0)) contribrec->qual[holdrec->qual[d.seq].contrib_sys_idx].
       contributor_system_cd
      ELSE 0.0
      ENDIF
      , r.person_id =
      IF ((holdrec->qual[d.seq].error_ind=0)) holdrec->qual[d.seq].person_id
      ELSE 0.0
      ENDIF
      ,
      r.health_plan_id =
      IF ((holdrec->qual[d.seq].error_ind=0)) holdrec->qual[d.seq].health_plan_id
      ELSE 0.0
      ENDIF
      , r.status =
      IF ((holdrec->qual[d.seq].error_ind=0)) "COMPLETE"
      ELSE "IN ERROR"
      ENDIF
      , r.stat_msg = trim(substring(1,40,holdrec->qual[d.seq].stat_msg)),
      r.updt_dt_tm = cnvtdatetime(dtcurrent), r.updt_cnt = (r.updt_cnt+ 1), r.updt_task = 424990,
      r.updt_applctx = 424990
     PLAN (d
      WHERE (holdrec->qual[d.seq].ags_plan_data_id > 0.0))
      JOIN (r
      WHERE (r.ags_plan_data_id=holdrec->qual[d.seq].ags_plan_data_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "AGS_PLAN_DATA"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("AGS_PLAN_DATA_ID :: ",trim(cnvtstring(holdrec->qual[
        d.seq].ags_plan_data_id))," ErrMsg :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
    ENDIF
   ENDIF
   CALL echo(curtime3)
   SET lavgsec = 0
   SET litcount = (litcount+ 1)
   SET dtitend = cnvtdatetime(curdate,curtime2)
   IF (lrowcnt > 0)
    SET lavgsec = (cnvtreal(lrowcnt)/ datetimediff(dtitend,dtitstart,5))
   ENDIF
   IF (lavgsec > 0)
    SET dtestcompletion = cnvtlookahead(concat(cnvtstring(ceil((cnvtreal(((dbatchendid - ditendid)+ 1
         ))/ lavgsec))),",S"),dtitend)
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.iteration_start_id = ditstartid, t.iteration_end_id = ditendid, t.iteration_count =
     litcount,
     t.iteration_start_dt_tm = cnvtdatetime(dtitstart), t.iteration_end_dt_tm = cnvtdatetime(dtitend),
     t.iteration_average = lavgsec,
     t.est_completion_dt_tm = cnvtdatetime(dtestcompletion), t.updt_dt_tm = cnvtdatetime(dtcurrent),
     t.updt_cnt = (t.updt_cnt+ 1),
     t.updt_task = 424990, t.updt_applctx = 424990
    WHERE t.ags_task_id=dtaskid
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_TASK"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_TASK UPDATE ITERATION :: Update Error :: ",trim(
      serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM ags_task t
    WHERE t.ags_task_id=dtaskid
    DETAIL
     lkillind = t.kill_ind
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "GET KILL_IND"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("GET KILL_IND :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   SET dstartid = (dendid+ 1)
   IF (((dstartid+ lbatchsize) > dbatchendid))
    SET dendid = dbatchendid
   ELSE
    SET dendid = ((dstartid+ lbatchsize) - 1)
   ENDIF
 ENDWHILE
 IF (dtaskid > 0)
  CALL echo("Update Task Status")
  UPDATE  FROM ags_task t
   SET t.status =
    IF (lkillind > 0) "WAITING"
    ELSE "COMPLETE"
    ENDIF
    , t.status_dt_tm = cnvtdatetime(dtcurrent), t.batch_end_dt_tm = cnvtdatetime(dtcurrent),
    t.updt_dt_tm = cnvtdatetime(dtcurrent), t.updt_cnt = (t.updt_cnt+ 1), t.updt_task = 424990,
    t.updt_applctx = 424990
   WHERE t.ags_task_id=dtaskid
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  IF (lkillind=0)
   SET bjobcomplete = true
   SELECT INTO "nl:"
    FROM ags_task t
    WHERE t.ags_job_id=dagsjobid
     AND t.status != "COMPLETE"
    DETAIL
     bjobcomplete = false
    WITH nocounter
   ;end select
   IF (bjobcomplete)
    UPDATE  FROM ags_job j
     SET j.status = "COMPLETE", j.status_dt_tm = cnvtdatetime(dtcurrent), j.updt_dt_tm = cnvtdatetime
      (dtcurrent),
      j.updt_cnt = (j.updt_cnt+ 1), j.updt_task = 424990, j.updt_applctx = 424990
     WHERE j.ags_job_id=dagsjobid
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
 ENDIF
 IF (define_logging_sub=true)
  SUBROUTINE handle_logging(slog_file,semail,istatus)
    CALL echo("***")
    CALL echo(build("***   sLog_file :",slog_file))
    CALL echo(build("***   sEmail    :",semail))
    CALL echo(build("***   iStatus   :",istatus))
    CALL echo("***")
    FREE SET output_log
    SET logical output_log value(nullterm(concat("cer_log:",trim(cnvtlower(slog_file)))))
    SELECT INTO output_log
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      out_line = fillstring(254," "), sstatus = fillstring(25," ")
     DETAIL
      FOR (exe_idx = 1 TO log->qual_knt)
        out_line = trim(substring(1,254,concat(format(log->qual[exe_idx].smsgtype,"#######")," :: ",
           format(log->qual[exe_idx].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[
            exe_idx].smsg))))
        IF ((exe_idx=log->qual_knt))
         IF (istatus=0)
          sstatus = "SUCCESS"
         ELSEIF (istatus=1)
          sstatus = "FAILURE"
         ELSE
          sstatus = "SUCCESS - With Warnings"
         ENDIF
         out_line = trim(substring(1,254,concat(trim(out_line),"  *** ",trim(sstatus)," ***")))
        ENDIF
        col 0, out_line
        IF ((exe_idx != log->qual_knt))
         row + 1
        ENDIF
      ENDFOR
     WITH nocounter, nullreport, formfeed = none,
      format = crstream, append, maxcol = 255,
      maxrow = 1
    ;end select
    IF ((email->qual_knt > 0))
     DECLARE msgpriority = i4 WITH public, noconstant(5)
     DECLARE sendto = vc WITH public, noconstant(trim(semail))
     DECLARE sender = vc WITH public, noconstant("sf3151")
     DECLARE subject = vc WITH public, noconstant("")
     DECLARE msgclass = vc WITH public, noconstant("IPM.NOTE")
     DECLARE msgtext = vc WITH public, noconstant("")
     IF (istatus=0)
      SET subject = concat("SUCCESS - ",trim(slog_file))
      SET msgtext = concat("SUCCESS - ",trim(slog_file))
     ELSEIF (istatus=1)
      SET subject = concat("FAILURE - ",trim(slog_file))
      SET msgtext = concat("FAILURE - ",trim(slog_file))
     ELSE
      SET subject = concat("SUCCESS (with Warnings) - ",trim(slog_file))
      SET msgtext = concat("SUCCESS (with Warnings) - ",trim(slog_file))
     ENDIF
     FOR (eidx = 1 TO email->qual_knt)
       IF ((email->qual[eidx].send_flag=0))
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=1)
        AND istatus != 1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=2)
        AND istatus=1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 SUBROUTINE turn_on_tracing(null)
   SET trace = echorecord
   SET trace = rdbprogram
   SET trace = srvuint
   SET trace = cost
   SET trace = callecho
   SET message = information
   SET tracing_on = true
 END ;Subroutine
 SUBROUTINE turn_off_tracing(null)
   SET trace = noechorecord
   SET trace = nordbprogram
   SET trace = nosrvuint
   SET trace = nocost
   SET trace = nocallecho
   SET message = noinformation
   SET tracing_on = false
 END ;Subroutine
#exit_script
 IF (failed != false)
  ROLLBACK
  CALL echorecord(log)
  IF (dtaskid > 0)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.status = "IN ERROR", t.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (t
     WHERE t.ags_task_id=dtaskid)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_TASK"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_TASK :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
   ENDIF
   COMMIT
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "INPUT ERROR"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_PLAN_LOAD"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 SET script_ver = "002 11/30/06"
 CALL echo(concat("MOD:",ags_plan_load_mod))
 CALL echo("<===== AGS_PLAN_LOAD End =====>")
END GO
