CREATE PROGRAM ags_mrg_load:dba
 PROMPT
  "TASK_ID     (0.0) = " = 0.0
  WITH dtid
 CALL echo("<===== AGS_MRG_LOAD Begin =====>")
 SET script_ver = "003 06/12/06"
 CALL echo(concat("MOD:",script_ver))
 EXECUTE srvrtl
 EXECUTE crmrtl
 DECLARE uar_sisrvdump(p1=i4(ref)) = null WITH uar = "SiSrvDump", image_aix =
 "libsirtl.a(libsirtl.o)", image_axp = "sirtl"
 DECLARE create_crmhandles(dummyt1) = i2
 DECLARE destroy_crmhandles(dummy1) = i2
 DECLARE define_logging_sub = i2 WITH public, noconstant(false)
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
  DECLARE sstatus_file_name = vc WITH public, constant(concat("ags_mrg_load_",format(cnvtdatetime(
      curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
 ENDIF
 FREE RECORD crmrec
 RECORD crmrec(
   1 app = i4
   1 task = i4
   1 req = i4
   1 happ = i4
   1 htask = i4
   1 hreq = i4
   1 hrep = i4
   1 hstep = i4
   1 status = i4
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
 )
 FREE RECORD holdrec
 RECORD holdrec(
   1 qual_cnt = i4
   1 qual[*]
     2 error = i2
     2 ags_mrg_data_id = f8
     2 contrib_sys_idx = i4
     2 contributor_system_cd = f8
     2 sending_facility = vc
     2 action = vc
     2 action_performed = vc
     2 end_effective_dt_tm = dq8
     2 person_id = f8
     2 ext_alias = vc
     2 ssn_alias = vc
     2 name_last = vc
     2 name_first = vc
     2 name_middle = vc
     2 birth_dt_tm = dq8
     2 sex_cd = f8
     2 match
       3 ext_qual_cnt = i4
       3 ext_qual[*]
         4 person_id = f8
         4 person_alias_id = f8
         4 beg_effective_dt_tm = dq8
         4 birth_dt_tm = dq8
         4 name_first = vc
         4 name_last = vc
         4 name_middle = vc
         4 sex_cd = f8
         4 active_status_cd = f8
       3 ssn_match_cnt = i4
       3 ssn_match_idx = i4
       3 ssn_qual_cnt = i4
       3 ssn_qual[*]
         4 person_id = f8
         4 person_alias_id = f8
         4 beg_effective_dt_tm = dq8
         4 birth_dt_tm = dq8
         4 name_first = vc
         4 name_last = vc
         4 name_middle = vc
         4 sex_cd = f8
         4 active_status_cd = f8
         4 abs_birth_dt_tm = dq8
         4 score = i4
     2 hist_person_id = f8
     2 hist_ext_alias = vc
     2 hist_ssn_alias = vc
     2 hist_name_last = vc
     2 hist_name_first = vc
     2 hist_name_middle = vc
     2 hist_birth_dt_tm = dq8
     2 hist_sex_cd = f8
     2 hist_match
       3 ext_qual_cnt = i4
       3 ext_qual[*]
         4 person_id = f8
         4 person_alias_id = f8
         4 beg_effective_dt_tm = dq8
         4 birth_dt_tm = dq8
         4 name_first = vc
         4 name_last = vc
         4 name_middle = vc
         4 sex_cd = f8
         4 active_status_cd = f8
       3 ssn_match_cnt = i4
       3 ssn_match_idx = i4
       3 ssn_qual_cnt = i4
       3 ssn_qual[*]
         4 person_id = f8
         4 person_alias_id = f8
         4 beg_effective_dt_tm = dq8
         4 birth_dt_tm = dq8
         4 name_first = vc
         4 name_last = vc
         4 name_middle = vc
         4 sex_cd = f8
         4 active_status_cd = f8
         4 abs_birth_dt_tm = dq8
         4 score = i4
     2 status = c10
     2 stat_msg = c40
 )
 FREE RECORD toaliasrec
 RECORD toaliasrec(
   1 qual_cnt = i4
   1 qual[*]
     2 person_alias_id = f8
     2 alias_type_cd = f8
     2 alias_pool_cd = f8
 )
 FREE RECORD fromaliasrec
 RECORD fromaliasrec(
   1 qual_cnt = i4
   1 qual[*]
     2 person_alias_id = f8
     2 alias_type_cd = f8
     2 alias_pool_cd = f8
 )
 SET crmrec->app = 70000
 SET crmrec->task = 70000
 SET crmrec->req = 100102
 DECLARE dtaskid = f8 WITH public, constant(cnvtreal( $DTID))
 DECLARE staskid = vc WITH public, constant(trim(cnvtstring(dtaskid)))
 DECLARE dagsjobid = f8 WITH public, noconstant(0.0)
 DECLARE lthreshold = i4 WITH public, noconstant(4)
 DECLARE berror = i2 WITH public, noconstant(0)
 DECLARE bendeffectaliases = i2 WITH public, noconstant(0)
 DECLARE hitem = i4 WITH public, noconstant(0)
 DECLARE hstruct = i4 WITH public, noconstant(0)
 DECLARE lbatchsize = i4 WITH public, noconstant(0)
 DECLARE ldefaultbatchsize = i4 WITH public, constant(1000)
 DECLARE lkillind = i2 WITH public, noconstant(0)
 DECLARE lmodeflag = i2 WITH public, noconstant(0)
 DECLARE lavgsec = i4 WITH public, noconstant(0)
 DECLARE litcount = i4 WITH public, noconstant(0)
 DECLARE lnum = i4 WITH public, noconstant(0)
 DECLARE lpos = i4 WITH public, noconstant(0)
 DECLARE lloglevel = i2 WITH public, noconstant(0)
 DECLARE ljobidx = i4 WITH public, noconstant(0)
 DECLARE lcontribsysidx = i4 WITH public, noconstant(0)
 DECLARE lidx = i4 WITH public, noconstant(0)
 DECLARE lidx2 = i4 WITH public, noconstant(0)
 DECLARE lidx3 = i4 WITH public, noconstant(0)
 DECLARE lmatchidx = i4 WITH public, noconstant(0)
 DECLARE lhistmatchidx = i4 WITH public, noconstant(0)
 DECLARE dbatchstartid = f8 WITH public, noconstant(0.0)
 DECLARE dbatchendid = f8 WITH public, noconstant(0.0)
 DECLARE dstartid = f8 WITH public, noconstant(0.0)
 DECLARE dendid = f8 WITH public, noconstant(0.0)
 DECLARE dcontribsyscd = f8 WITH public, noconstant(0.0)
 DECLARE dpersonid = f8 WITH public, noconstant(0.0)
 DECLARE dhistpersonid = f8 WITH public, noconstant(0.0)
 DECLARE dpersonaliasid = f8 WITH public, noconstant(0.0)
 DECLARE sactionperformed = vc WITH public, noconstant(" ")
 DECLARE ssendingfacility = vc WITH public, noconstant(" ")
 DECLARE sstatusmsg = vc WITH public, noconstant(" ")
 DECLARE sbirthdate = vc WITH public, noconstant("")
 DECLARE sbirthdatetime = vc WITH public, noconstant("")
 DECLARE sgender = vc WITH public, noconstant("")
 DECLARE dtmax = dq8 WITH public, constant(cnvtdatetime("31-DEC-2100 00:00:00.00"))
 DECLARE dtblank = dq8 WITH public, constant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
 DECLARE dtcurrent = dq8 WITH public, constant(cnvtdatetime(curdate,curtime2))
 DECLARE dtestcompletion = dq8 WITH public, noconstant
 DECLARE dtitend = dq8 WITH public, noconstant
 DECLARE dtitstart = dq8 WITH public, noconstant
 DECLARE dtbegeffective = dq8 WITH public, noconstant
 DECLARE ddefaultsrccd = f8 WITH public, constant(uar_get_code_by("MEANING",73,"DEFAULT"))
 DECLARE dssnaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PRSNSSN"))
 DECLARE dextaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PRSNEXTALIAS"
   ))
 DECLARE dcmrnpersonaliastypecd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE dauthdatastatuscd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE dactiveactivestatuscd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dmalesexcd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"MALE"))
 DECLARE dfemalesexcd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"FEMALE"))
 DECLARE dunknownsexcd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"UNKNOWN"))
 DECLARE dmatchsourcecd = f8 WITH public, constant(uar_get_code_by("MEANING",372,"AGSMATCH"))
 IF (dauthdatastatuscd <= 0)
  SET failed = select_error
  SET table_name = "dAuthDataStatusCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING:AUTH invalid from CODE_SET 8"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dactiveactivestatuscd <= 0)
  SET failed = select_error
  SET table_name = "dActiveActiveStatusCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING:ACTIVE invalid from CODE_SET 48"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (ddefaultsrccd <= 0)
  SET failed = select_error
  SET table_name = "dDefaultSrcCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING:DEFAULT invalid from CODE_SET 48"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dcmrnpersonaliastypecd <= 0)
  SET failed = select_error
  SET table_name = "dCMRNPersonAliasTypeCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING:CMRN invalid from CODE_SET 4"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dmatchsourcecd <= 0)
  SET failed = select_error
  SET table_name = "dMatchSourceCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UAR Error :: CODE_VALUE for CDF_MEANING:AGSMATCH invalid from CODE_SET 372"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SET lstat = create_crmhandles(0)
 IF ( NOT (lstat))
  CALL echo(build("FAILURE!! Create_CRMHandles() status: ",crmrec->status))
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   AGS_TASK & AGS_JOB Lookup")
 CALL echo("***")
 CALL echo(build("ags_task_id:",dtaskid))
 SELECT INTO "nl:"
  FROM ags_task t,
   ags_job j
  PLAN (t
   WHERE t.ags_task_id=dtaskid)
   JOIN (j
   WHERE j.ags_job_id=t.ags_job_id)
  ORDER BY t.ags_task_id, j.ags_job_id
  HEAD t.ags_task_id
   dbatchendid = t.batch_end_id, dbatchstartid = t.batch_start_id
   IF (t.batch_size > 0)
    lbatchsize = t.batch_size
   ELSE
    lbatchsize = ldefaultbatchsize
   ENDIF
   lmodeflag = t.mode_flag, lkillind = t.kill_ind, lloglevel = t.timers_flag
  HEAD j.ags_job_id
   dagsjobid = j.ags_job_id, ljobidx = (contribrec->qual_cnt+ 1), contribrec->qual_cnt = ljobidx,
   stat = alterlist(contribrec->qual,ljobidx), contribrec->qual[ljobidx].sending_facility = trim(j
    .sending_system)
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
  SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"INVALID TASK_ID :: ",staskid
   )
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (lloglevel >= 1)
  SET trace = callecho
  SET trace = cost
 ELSE
  SET trace = nocallecho
  SET trace = nocost
 ENDIF
 IF (dtaskid > 0)
  UPDATE  FROM ags_task t
   SET t.status = "PROCESSING", t.status_dt_tm = cnvtdatetime(dtcurrent), t.batch_start_dt_tm =
    cnvtdatetime(dtcurrent),
    t.batch_end_dt_tm = cnvtdatetime(dtblank)
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
 CALL echo(build("Mode: ",lmodeflag))
 WHILE (dstartid <= dendid
  AND lkillind <= 0)
   CALL echo(build("dStartId: ",dstartid))
   CALL echo(build("dEndId  : ",dendid))
   SET stat = initrec(holdrec)
   SET dtitstart = cnvtdatetime(curdate,curtime2)
   SELECT
    IF (lmodeflag=0)
     PLAN (r
      WHERE r.ags_mrg_data_id >= dstartid
       AND r.ags_mrg_data_id <= dendid
       AND ((r.person_id+ 0)=0)
       AND trim(r.action)="LINK"
       AND trim(r.status)="WAITING")
    ELSEIF (lmodeflag=3)
     PLAN (r
      WHERE r.ags_mrg_data_id >= dstartid
       AND r.ags_mrg_data_id <= dendid
       AND ((r.person_id+ 0)=0)
       AND ((r.hist_person_id+ 0)=0)
       AND trim(r.action)="LINK"
       AND trim(r.status) IN ("IN ERROR", "HOLD", "BACK OUT"))
    ELSE
    ENDIF
    INTO "nl:"
    FROM ags_mrg_data r
    ORDER BY r.ags_mrg_data_id
    HEAD REPORT
     lidx = 0
    HEAD r.ags_mrg_data_id
     berror = false, sstatusmsg = " ", lidx = (lidx+ 1),
     holdrec->qual_cnt = lidx, stat = alterlist(holdrec->qual,lidx), ssendingfacility = trim(r
      .sending_facility,3)
     IF (size(ssendingfacility) > 0)
      lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual_cnt,ssendingfacility,contribrec->
       qual[lnum].sending_facility)
      IF (lpos <= 0)
       contribrec->qual_cnt = (contribrec->qual_cnt+ 1), stat = alterlist(contribrec->qual,contribrec
        ->qual_cnt), contribrec->qual[contribrec->qual_cnt].sending_facility = ssendingfacility,
       holdrec->qual[lidx].contrib_sys_idx = contribrec->qual_cnt
      ELSE
       holdrec->qual[lidx].contrib_sys_idx = lpos
      ENDIF
     ELSE
      holdrec->qual[lidx].contrib_sys_idx = ljobidx
     ENDIF
     holdrec->qual[lidx].ags_mrg_data_id = r.ags_mrg_data_id, holdrec->qual[lidx].action = r.action,
     holdrec->qual[lidx].action_performed = r.action_performed,
     sendeffdate = trim(r.end_date_txt,3)
     IF (size(sendeffdate) > 13)
      sendeffdatetime = concat(format(cnvtdate2(sendeffdate,"YYYYMMDD"),"DD-MMM-YYYY;;D")," ",
       substring(9,2,sendeffdate),":",substring(11,2,sendeffdate),
       ":",substring(13,2,sendeffdate)), holdrec->qual[lidx].end_effective_dt_tm = cnvtdatetime(
       sendeffdatetime)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[ef]m")
     ENDIF
     holdrec->qual[lidx].person_id = r.person_id
     IF (size(trim(r.ext_alias,3)) > 0)
      holdrec->qual[lidx].ext_alias = trim(r.ext_alias,3)
     ELSE
      sstatusmsg = concat(sstatusmsg,"[x]am")
     ENDIF
     IF (size(trim(r.ssn_alias,3)) > 0)
      holdrec->qual[lidx].ssn_alias = cnvtstring(cnvtint(trim(r.ssn_alias,3)))
     ELSE
      sstatusmsg = concat(sstatusmsg,"[s]am")
      IF (size(trim(holdrec->qual[lidx].ext_alias,3)) <= 0)
       berror = true
      ENDIF
     ENDIF
     IF (size(trim(r.name_last,3)) > 0)
      holdrec->qual[lidx].name_last = trim(r.name_last,3)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[l]am")
     ENDIF
     IF (size(trim(r.name_first,3)) > 0)
      holdrec->qual[lidx].name_first = trim(r.name_first,3)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[f]am")
     ENDIF
     IF (size(trim(r.name_middle,3)) > 0)
      holdrec->qual[lidx].name_middle = trim(r.name_middle,3)
     ELSE
      sstatusmsg = concat(sstatusmsg,"[m]am")
     ENDIF
     IF (size(trim(r.birth_date,3)) > 0)
      holdrec->qual[lidx].birth_dt_tm = cnvtdate2(trim(r.birth_date,3),"YYYYMMDD")
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[d]am")
     ENDIF
     sgender = cnvtupper(trim(r.gender,3))
     IF (size(sgender))
      IF (sgender="M")
       holdrec->qual[lidx].sex_cd = dmalesexcd
      ELSEIF (sgender="F")
       holdrec->qual[lidx].sex_cd = dfemalesexcd
      ELSE
       holdrec->qual[lidx].sex_cd = dunknownsexcd
      ENDIF
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[g]am")
     ENDIF
     holdrec->qual[lidx].hist_person_id = r.hist_person_id
     IF (size(trim(r.hist_ext_alias,3)) > 0)
      holdrec->qual[lidx].hist_ext_alias = trim(r.hist_ext_alias,3)
     ELSE
      sstatusmsg = concat(sstatusmsg,"[hx]am")
     ENDIF
     IF (size(trim(r.hist_ssn_alias,3)) > 0)
      holdrec->qual[lidx].hist_ssn_alias = cnvtstring(cnvtint(trim(r.hist_ssn_alias,3)))
     ELSE
      sstatusmsg = concat(sstatusmsg,"[hs]am")
      IF (size(trim(holdrec->qual[lidx].hist_ext_alias,3)) <= 0)
       berror = true
      ENDIF
     ENDIF
     IF (size(trim(r.hist_name_last,3)) > 0)
      holdrec->qual[lidx].hist_name_last = trim(r.hist_name_last,3)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[hl]am")
     ENDIF
     IF (size(trim(r.hist_name_first,3)) > 0)
      holdrec->qual[lidx].hist_name_first = trim(r.hist_name_first,3)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[hf]am")
     ENDIF
     IF (size(trim(r.hist_name_middle,3)) > 0)
      holdrec->qual[lidx].hist_name_middle = trim(r.hist_name_middle,3)
     ELSE
      sstatusmsg = concat(sstatusmsg,"[hm]am")
     ENDIF
     IF (size(trim(r.hist_birth_date,3)) > 0)
      holdrec->qual[lidx].hist_birth_dt_tm = cnvtdate2(trim(r.hist_birth_date,3),"YYYYMMDD")
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[hd]am")
     ENDIF
     sgender = cnvtupper(trim(r.hist_gender,3))
     IF (size(sgender))
      IF (sgender="M")
       holdrec->qual[lidx].hist_sex_cd = dmalesexcd
      ELSEIF (sgender="F")
       holdrec->qual[lidx].hist_sex_cd = dfemalesexcd
      ELSE
       holdrec->qual[lidx].hist_sex_cd = dunknownsexcd
      ENDIF
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[hg]am")
     ENDIF
     IF (berror)
      holdrec->qual[lidx].error = true, holdrec->qual[lidx].stat_msg = sstatusmsg
     ENDIF
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "AGS_MRG_DATA"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"dStartId :: ",trim(
      cnvtstring(dstartid)),"dEndId :: ",
     trim(cnvtstring(dendid)),"lMode :: ",trim(cnvtstring(lmodeflag)))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   IF (curqual > 0)
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
     HEAD cs.contributor_system_cd
      contribrec->qual[d.seq].contributor_system_cd = cs.contributor_system_cd, contribrec->qual[d
      .seq].contributor_source_cd = cs.contributor_source_cd, contribrec->qual[d.seq].prsnl_person_id
       = cs.prsnl_person_id,
      contribrec->qual[d.seq].time_zone = cs.time_zone, contribrec->qual[d.seq].time_zone_idx =
      datetimezonebyname(contribrec->qual[d.seq].time_zone)
     HEAD eat.esi_alias_field_cd
      IF (eat.esi_alias_field_cd=dssnaliasfieldcd)
       contribrec->qual[d.seq].ssn_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       ssn_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (eat.esi_alias_field_cd=dextaliasfieldcd)
       contribrec->qual[d.seq].ext_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       ext_alias_type_cd = eat.alias_entity_alias_type_cd
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
    FOR (lidx = 1 TO holdrec->qual_cnt)
      SET sstatusmsg = " "
      SET sactionperformed = " "
      SET dpersonid = 0.0
      SET lmatchidx = 0
      SET dhistpersonid = 0.0
      SET lhistmatchidx = 0
      IF ((holdrec->qual[lidx].error=0))
       SET lcontribsysidx = holdrec->qual[lidx].contrib_sys_idx
       CALL echo("***")
       CALL echo("***   EXT_ALIAS Lookup")
       CALL echo("***")
       SELECT INTO "nl:"
        FROM person_alias pa,
         person p
        PLAN (pa
         WHERE pa.alias=trim(holdrec->qual[lidx].ext_alias)
          AND ((pa.person_alias_type_cd+ 0)=contribrec->qual[lcontribsysidx].ext_alias_type_cd)
          AND ((pa.active_ind+ 0) != 0))
         JOIN (p
         WHERE p.person_id=pa.person_id)
        HEAD REPORT
         lidx2 = 0
        DETAIL
         lidx2 = (lidx2+ 1), holdrec->qual[lidx].match.ext_qual_cnt = lidx2, stat = alterlist(holdrec
          ->qual[lidx].match.ext_qual,lidx2),
         holdrec->qual[lidx].match.ext_qual[lidx2].person_id = pa.person_id, holdrec->qual[lidx].
         match.ext_qual[lidx2].person_alias_id = pa.person_alias_id, holdrec->qual[lidx].match.
         ext_qual[lidx2].beg_effective_dt_tm = pa.beg_effective_dt_tm,
         holdrec->qual[lidx].match.ext_qual[lidx2].birth_dt_tm = p.birth_dt_tm, holdrec->qual[lidx].
         match.ext_qual[lidx2].name_first = trim(p.name_first), holdrec->qual[lidx].match.ext_qual[
         lidx2].name_last = trim(p.name_last),
         holdrec->qual[lidx].match.ext_qual[lidx2].name_middle = trim(p.name_middle), holdrec->qual[
         lidx].match.ext_qual[lidx2].sex_cd = p.sex_cd, holdrec->qual[lidx].match.ext_qual[lidx2].
         active_status_cd = p.active_status_cd
        WITH nocounter
       ;end select
       IF ((holdrec->qual[lidx].match.ext_qual_cnt < 1))
        SET sstatusmsg = concat(sstatusmsg,"[x]lf")
       ELSEIF ((holdrec->qual[lidx].match.ext_qual_cnt > 1))
        SET sstatusmsg = concat(sstatusmsg,"[x]mf")
       ENDIF
       CALL echo("***")
       CALL echo("***   HIST_EXT_ALIAS Lookup")
       CALL echo("***")
       SELECT INTO "nl:"
        FROM person_alias pa,
         person p
        PLAN (pa
         WHERE pa.alias=trim(holdrec->qual[lidx].hist_ext_alias)
          AND ((pa.person_alias_type_cd+ 0)=contribrec->qual[lcontribsysidx].ext_alias_type_cd)
          AND ((pa.active_ind+ 0) != 0))
         JOIN (p
         WHERE p.person_id=pa.person_id)
        HEAD REPORT
         lidx2 = 0
        DETAIL
         lidx2 = (lidx2+ 1), holdrec->qual[lidx].hist_match.ext_qual_cnt = lidx2, stat = alterlist(
          holdrec->qual[lidx].hist_match.ext_qual,lidx2),
         holdrec->qual[lidx].hist_match.ext_qual[lidx2].person_id = pa.person_id, holdrec->qual[lidx]
         .hist_match.ext_qual[lidx2].person_alias_id = pa.person_alias_id, holdrec->qual[lidx].
         hist_match.ext_qual[lidx2].beg_effective_dt_tm = pa.beg_effective_dt_tm,
         holdrec->qual[lidx].hist_match.ext_qual[lidx2].birth_dt_tm = p.birth_dt_tm, holdrec->qual[
         lidx].hist_match.ext_qual[lidx2].name_first = trim(p.name_first), holdrec->qual[lidx].
         hist_match.ext_qual[lidx2].name_last = trim(p.name_last),
         holdrec->qual[lidx].hist_match.ext_qual[lidx2].name_middle = trim(p.name_middle), holdrec->
         qual[lidx].hist_match.ext_qual[lidx2].sex_cd = p.sex_cd, holdrec->qual[lidx].hist_match.
         ext_qual[lidx2].active_status_cd = p.active_status_cd
        WITH nocounter
       ;end select
       IF ((holdrec->qual[lidx].hist_match.ext_qual_cnt < 1))
        SET sstatusmsg = concat(sstatusmsg,"[hx]lf")
       ELSEIF ((holdrec->qual[lidx].hist_match.ext_qual_cnt > 1))
        SET sstatusmsg = concat(sstatusmsg,"[hx]mf")
       ENDIF
       CALL echo("***")
       CALL echo("***   SSN_ALIAS Lookup")
       CALL echo("***")
       SELECT INTO "nl:"
        FROM person_alias pa,
         person p
        PLAN (pa
         WHERE pa.alias=trim(holdrec->qual[lidx].ssn_alias)
          AND ((pa.alias_pool_cd+ 0)=contribrec->qual[lcontribsysidx].ssn_alias_pool_cd)
          AND ((pa.person_alias_type_cd+ 0)=contribrec->qual[lcontribsysidx].ssn_alias_type_cd)
          AND ((pa.active_ind+ 0) != 0))
         JOIN (p
         WHERE p.person_id=pa.person_id)
        HEAD REPORT
         lidx2 = 0
        DETAIL
         lidx2 = (lidx2+ 1), holdrec->qual[lidx].match.ssn_qual_cnt = lidx2, stat = alterlist(holdrec
          ->qual[lidx].match.ssn_qual,lidx2),
         holdrec->qual[lidx].match.ssn_qual[lidx2].person_id = pa.person_id, holdrec->qual[lidx].
         match.ssn_qual[lidx2].person_alias_id = pa.person_alias_id, holdrec->qual[lidx].match.
         ssn_qual[lidx2].beg_effective_dt_tm = pa.beg_effective_dt_tm,
         holdrec->qual[lidx].match.ssn_qual[lidx2].birth_dt_tm = p.birth_dt_tm, holdrec->qual[lidx].
         match.ssn_qual[lidx2].name_first = trim(p.name_first), holdrec->qual[lidx].match.ssn_qual[
         lidx2].name_last = trim(p.name_last),
         holdrec->qual[lidx].match.ssn_qual[lidx2].name_middle = trim(p.name_middle), holdrec->qual[
         lidx].match.ssn_qual[lidx2].sex_cd = p.sex_cd, holdrec->qual[lidx].match.ssn_qual[lidx2].
         active_status_cd = p.active_status_cd,
         holdrec->qual[lidx].match.ssn_qual[lidx2].abs_birth_dt_tm = p.abs_birth_dt_tm
        WITH nocounter
       ;end select
       IF (curqual < 1)
        SET sstatusmsg = concat(sstatusmsg,"[s]lf")
       ELSE
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = value(holdrec->qual[lidx].match.ssn_qual_cnt))
         DETAIL
          IF ((holdrec->qual[lidx].match.ssn_qual[d.seq].abs_birth_dt_tm=datetimezone(holdrec->qual[
           lidx].birth_dt_tm,contribrec->qual[lcontribsysidx].time_zone_idx,1)))
           holdrec->qual[lidx].match.ssn_qual[d.seq].score = (holdrec->qual[lidx].match.ssn_qual[d
           .seq].score+ 1)
          ENDIF
          IF (cnvtupper(cnvtalphanum(holdrec->qual[lidx].match.ssn_qual[d.seq].name_first))=cnvtupper
          (cnvtalphanum(holdrec->qual[lidx].name_first)))
           holdrec->qual[lidx].match.ssn_qual[d.seq].score = (holdrec->qual[lidx].match.ssn_qual[d
           .seq].score+ 1)
          ENDIF
          IF (cnvtupper(cnvtalphanum(holdrec->qual[lidx].match.ssn_qual[d.seq].name_last))=cnvtupper(
           cnvtalphanum(holdrec->qual[lidx].name_last)))
           holdrec->qual[lidx].match.ssn_qual[d.seq].score = (holdrec->qual[lidx].match.ssn_qual[d
           .seq].score+ 1)
          ENDIF
          IF ((holdrec->qual[lidx].match.ssn_qual[d.seq].sex_cd=holdrec->qual[lidx].sex_cd))
           holdrec->qual[lidx].match.ssn_qual[d.seq].score = (holdrec->qual[lidx].match.ssn_qual[d
           .seq].score+ 1)
          ENDIF
          IF ((holdrec->qual[lidx].match.ssn_qual[d.seq].score >= lthreshold))
           holdrec->qual[lidx].match.ssn_match_cnt = (holdrec->qual[lidx].match.ssn_match_cnt+ 1),
           holdrec->qual[lidx].match.ssn_match_idx = d.seq
          ENDIF
         WITH nocounter
        ;end select
        IF ((holdrec->qual[lidx].match.ssn_match_cnt > 1))
         SET sstatusmsg = concat(sstatusmsg,"[s]mf")
        ENDIF
       ENDIF
       CALL echo("***")
       CALL echo("***   HIST_SSN_ALIAS Lookup")
       CALL echo("***")
       SELECT INTO "nl:"
        FROM person_alias pa,
         person p
        PLAN (pa
         WHERE pa.alias=trim(holdrec->qual[lidx].hist_ssn_alias)
          AND ((pa.alias_pool_cd+ 0)=contribrec->qual[lcontribsysidx].ssn_alias_pool_cd)
          AND ((pa.person_alias_type_cd+ 0)=contribrec->qual[lcontribsysidx].ssn_alias_type_cd)
          AND ((pa.active_ind+ 0) != 0))
         JOIN (p
         WHERE p.person_id=pa.person_id)
        HEAD REPORT
         lidx2 = 0
        DETAIL
         lidx2 = (lidx2+ 1), holdrec->qual[lidx].hist_match.ssn_qual_cnt = lidx2, stat = alterlist(
          holdrec->qual[lidx].hist_match.ssn_qual,lidx2),
         holdrec->qual[lidx].hist_match.ssn_qual[lidx2].person_id = pa.person_id, holdrec->qual[lidx]
         .hist_match.ssn_qual[lidx2].person_alias_id = pa.person_alias_id, holdrec->qual[lidx].
         hist_match.ssn_qual[lidx2].beg_effective_dt_tm = pa.beg_effective_dt_tm,
         holdrec->qual[lidx].hist_match.ssn_qual[lidx2].birth_dt_tm = p.birth_dt_tm, holdrec->qual[
         lidx].hist_match.ssn_qual[lidx2].name_first = trim(p.name_first), holdrec->qual[lidx].
         hist_match.ssn_qual[lidx2].name_last = trim(p.name_last),
         holdrec->qual[lidx].hist_match.ssn_qual[lidx2].name_middle = trim(p.name_middle), holdrec->
         qual[lidx].hist_match.ssn_qual[lidx2].sex_cd = p.sex_cd, holdrec->qual[lidx].hist_match.
         ssn_qual[lidx2].active_status_cd = p.active_status_cd,
         holdrec->qual[lidx].hist_match.ssn_qual[lidx2].abs_birth_dt_tm = p.abs_birth_dt_tm
        WITH nocounter
       ;end select
       IF (curqual < 1)
        SET sstatusmsg = concat(sstatusmsg,"[hs]lf")
       ELSE
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = value(holdrec->qual[lidx].hist_match.ssn_qual_cnt))
         DETAIL
          IF ((holdrec->qual[lidx].hist_match.ssn_qual[d.seq].abs_birth_dt_tm=datetimezone(holdrec->
           qual[lidx].hist_birth_dt_tm,contribrec->qual[lcontribsysidx].time_zone_idx,1)))
           holdrec->qual[lidx].hist_match.ssn_qual[d.seq].score = (holdrec->qual[lidx].hist_match.
           ssn_qual[d.seq].score+ 1)
          ENDIF
          IF (cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_match.ssn_qual[d.seq].name_first))=
          cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_name_first)))
           holdrec->qual[lidx].hist_match.ssn_qual[d.seq].score = (holdrec->qual[lidx].hist_match.
           ssn_qual[d.seq].score+ 1)
          ENDIF
          IF (cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_match.ssn_qual[d.seq].name_last))=
          cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_name_last)))
           holdrec->qual[lidx].hist_match.ssn_qual[d.seq].score = (holdrec->qual[lidx].hist_match.
           ssn_qual[d.seq].score+ 1)
          ENDIF
          IF ((holdrec->qual[lidx].hist_match.ssn_qual[d.seq].sex_cd=holdrec->qual[lidx].hist_sex_cd)
          )
           holdrec->qual[lidx].hist_match.ssn_qual[d.seq].score = (holdrec->qual[lidx].hist_match.
           ssn_qual[d.seq].score+ 1)
          ENDIF
          IF ((holdrec->qual[lidx].hist_match.ssn_qual[d.seq].score >= lthreshold))
           holdrec->qual[lidx].hist_match.ssn_match_cnt = (holdrec->qual[lidx].hist_match.
           ssn_match_cnt+ 1), holdrec->qual[lidx].hist_match.ssn_match_idx = d.seq
          ENDIF
         WITH nocounter
        ;end select
        IF ((holdrec->qual[lidx].hist_match.ssn_match_cnt > 1))
         SET sstatusmsg = concat(sstatusmsg,"[hs]mf")
        ENDIF
       ENDIF
       IF ((((((holdrec->qual[lidx].match.ext_qual_cnt > 1)) OR ((holdrec->qual[lidx].match.
       ssn_match_cnt > 1))) ) OR ((((holdrec->qual[lidx].hist_match.ext_qual_cnt > 1)) OR ((holdrec->
       qual[lidx].hist_match.ssn_match_cnt > 1))) )) )
        CALL echo("***")
        CALL echo("***   Multiple Matchs on TO and/or FROM persons")
        CALL echo("***")
        SET holdrec->qual[lidx].error = true
        SET holdrec->qual[lidx].stat_msg = concat(trim(holdrec->qual[lidx].stat_msg),sstatusmsg)
       ELSEIF ((holdrec->qual[lidx].match.ext_qual_cnt=0)
        AND (holdrec->qual[lidx].match.ssn_match_cnt=0)
        AND (holdrec->qual[lidx].hist_match.ext_qual_cnt=0)
        AND (holdrec->qual[lidx].hist_match.ssn_match_cnt=0))
        CALL echo("***")
        CALL echo("***   #1 - No Match on either the TO or FROM persons")
        CALL echo("***")
        SET holdrec->qual[lidx].error = true
        SET holdrec->qual[lidx].stat_msg = concat(trim(holdrec->qual[lidx].stat_msg),sstatusmsg)
       ELSEIF ((((holdrec->qual[lidx].match.ext_qual_cnt=1)) OR ((holdrec->qual[lidx].match.
       ssn_match_cnt=1)))
        AND (holdrec->qual[lidx].hist_match.ext_qual_cnt=0)
        AND (holdrec->qual[lidx].hist_match.ssn_match_cnt=0))
        CALL echo("***")
        CALL echo("***   #2 - Add History Alias")
        CALL echo("***")
        SET bssn = false
        IF ((holdrec->qual[lidx].match.ext_qual_cnt=1))
         SET dpersonid = holdrec->qual[lidx].match.ext_qual[1].person_id
        ENDIF
        IF ((holdrec->qual[lidx].match.ssn_match_cnt=1))
         SET bssn = true
         SET lmatchidx = holdrec->qual[lidx].match.ssn_match_idx
         SET dpersonid = holdrec->qual[lidx].match.ssn_qual[lmatchidx].person_id
        ENDIF
        UPDATE  FROM ags_mrg_data r
         SET r.person_id = dpersonid, r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm = cnvtdatetime(
           dtcurrent)
         WHERE (r.ags_mrg_data_id=holdrec->qual[lidx].ags_mrg_data_id)
         WITH nocounter
        ;end update
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = update_error
         SET table_name = "AGS_MRG_DATA"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("Add History Alias - AgsMrgDataId :: ",trim(
           cnvtstring(holdrec->qual[lidx].ags_mrg_data_id)),"ErrMsg :: ",trim(serrmsg))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        IF ((holdrec->qual[lidx].hist_match.ssn_qual_cnt > 1))
         CALL echo("***")
         CALL echo("***   Manual Review")
         CALL echo("***")
         SET sactionperformed = concat(trim(sactionperformed),"[pm]ha")
         FOR (lidx2 = 1 TO holdrec->qual[lidx].hist_match.ssn_qual_cnt)
          SELECT INTO "nl:"
           FROM person_matches p
           WHERE ((p.a_person_id=dpersonid
            AND (p.b_person_id=holdrec->qual[lidx].hist_match.ssn_qual[lidx2].person_id)) OR ((p
           .a_person_id=holdrec->qual[lidx].hist_match.ssn_qual[lidx2].person_id)
            AND p.b_person_id=dpersonid))
           WITH nocounter
          ;end select
          IF (curqual <= 0)
           CALL echo("***")
           CALL echo("***   Insert PERSON_MATCHES")
           CALL echo("***")
           INSERT  FROM person_matches p
            SET p.person_matches_id = seq(person_seq,nextval), p.a_ssn_alias =
             IF (bssn) holdrec->qual[lidx].ssn_alias
             ELSE ""
             ENDIF
             , p.a_alias =
             IF (bssn) ""
             ELSE holdrec->qual[lidx].ext_alias
             ENDIF
             ,
             p.a_alias_pool_cd =
             IF (bssn) 0.0
             ELSE contribrec->qual[lcontribsysidx].ext_alias_pool_cd
             ENDIF
             , p.a_alias_type_cd =
             IF (bssn) 0.0
             ELSE contribrec->qual[lcontribsysidx].ext_alias_type_cd
             ENDIF
             , p.a_birth_dt_tm =
             IF (bssn) cnvtdatetime(holdrec->qual[lidx].match.ssn_qual[lmatchidx].birth_dt_tm)
             ELSE cnvtdatetime(holdrec->qual[lidx].match.ext_qual[1].birth_dt_tm)
             ENDIF
             ,
             p.a_birth_tz = contribrec->qual[lcontribsysidx].time_zone_idx, p.a_create_prsnl_id =
             contribrec->qual[lcontribsysidx].prsnl_person_id, p.a_person_id = dpersonid,
             p.a_name_first_key =
             IF (bssn) cnvtupper(cnvtalphanum(holdrec->qual[lidx].match.ssn_qual[lmatchidx].
                name_first))
             ELSE cnvtupper(cnvtalphanum(holdrec->qual[lidx].match.ext_qual[1].name_first))
             ENDIF
             , p.a_name_last_key =
             IF (bssn) cnvtupper(cnvtalphanum(holdrec->qual[lidx].match.ssn_qual[lmatchidx].name_last
                ))
             ELSE cnvtupper(cnvtalphanum(holdrec->qual[lidx].match.ext_qual[1].name_last))
             ENDIF
             , p.a_name_middle =
             IF (bssn) cnvtupper(cnvtalphanum(holdrec->qual[lidx].match.ssn_qual[lmatchidx].
                name_middle))
             ELSE cnvtupper(cnvtalphanum(holdrec->qual[lidx].match.ext_qual[1].name_middle))
             ENDIF
             ,
             p.a_sex_cd =
             IF (bssn) holdrec->qual[lidx].match.ssn_qual[lmatchidx].sex_cd
             ELSE holdrec->qual[lidx].match.ext_qual[1].sex_cd
             ENDIF
             , p.a_active_status_cd =
             IF (bssn) holdrec->qual[lidx].match.ssn_qual[lmatchidx].active_status_cd
             ELSE holdrec->qual[lidx].match.ext_qual[1].active_status_cd
             ENDIF
             , p.b_ssn_alias = holdrec->qual[lidx].hist_ssn_alias,
             p.b_birth_dt_tm = cnvtdatetime(holdrec->qual[lidx].hist_match.ssn_qual[lidx2].
              birth_dt_tm), p.b_birth_tz = contribrec->qual[lcontribsysidx].time_zone_idx, p
             .b_create_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
             p.b_person_id = holdrec->qual[lidx].hist_match.ssn_qual[lidx2].person_id, p
             .b_name_first_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_match.ssn_qual[lidx2
               ].name_first)), p.b_name_last_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].
               hist_match.ssn_qual[lidx2].name_last)),
             p.b_name_middle = cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_match.ssn_qual[lidx2].
               name_middle)), p.b_sex_cd = holdrec->qual[lidx].hist_match.ssn_qual[lidx2].sex_cd, p
             .b_active_status_cd = holdrec->qual[lidx].hist_match.ssn_qual[lidx2].active_status_cd,
             p.match_dt_tm = cnvtdatetime(dtcurrent), p.match_source_cd = dmatchsourcecd, p
             .beg_effective_dt_tm = cnvtdatetime(dtcurrent),
             p.end_effective_dt_tm = cnvtdatetime(dtmax), p.active_ind = 1, p.active_status_cd =
             dactiveactivestatuscd,
             p.active_status_dt_tm = cnvtdatetime(dtcurrent), p.active_status_prsnl_id = contribrec->
             qual[lcontribsysidx].prsnl_person_id, p.updt_applctx = 4249900,
             p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(dtcurrent), p.updt_id = contribrec->qual[
             lcontribsysidx].prsnl_person_id,
             p.updt_task = 4249900
            WITH nocounter
           ;end insert
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = insert_error
            SET table_name = "PERSON_MATCHES"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
          ENDIF
         ENDFOR
        ELSE
         IF (size(holdrec->qual[lidx].hist_ext_alias) > 0)
          SELECT INTO "nl:"
           FROM person_alias pa
           WHERE pa.person_id=dpersonid
            AND ((pa.alias_pool_cd+ 0)=contribrec->qual[lcontribsysidx].ext_alias_pool_cd)
            AND ((pa.person_alias_type_cd+ 0)=contribrec->qual[lcontribsysidx].ext_alias_type_cd)
            AND ((pa.active_ind+ 0) != 0)
            AND ((pa.active_status_cd+ 0)=dactiveactivestatuscd)
            AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime2)
           DETAIL
            dpersonaliasid = pa.person_alias_id, dtbegeffective = pa.beg_effective_dt_tm
           WITH nocounter
          ;end select
          IF (curqual > 0)
           IF (datetimediff(dtbegeffective,holdrec->qual[lidx].end_effective_dt_tm,1) != 0.0)
            CALL echo("***   Update Existing Alias")
            UPDATE  FROM person_alias pa
             SET pa.beg_effective_dt_tm = cnvtdatetime(holdrec->qual[lidx].end_effective_dt_tm), pa
              .updt_dt_tm = cnvtdatetime(dtcurrent), pa.updt_cnt = (pa.updt_cnt+ 1)
             WHERE pa.person_alias_id=dpersonaliasid
             WITH nocounter
            ;end update
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = update_error
             SET table_name = "PERSON_ALIAS"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
           ENDIF
          ENDIF
          CALL echo("***")
          CALL echo("***   Add HIST_EXT_ALIAS")
          CALL echo("***")
          SET sactionperformed = concat(trim(sactionperformed),"[x]ha")
          INSERT  FROM person_alias pa
           SET pa.person_alias_id = seq(person_seq,nextval), pa.alias = holdrec->qual[lidx].
            hist_ext_alias, pa.alias_pool_cd = contribrec->qual[lcontribsysidx].ext_alias_pool_cd,
            pa.person_alias_type_cd = contribrec->qual[lcontribsysidx].ext_alias_type_cd, pa
            .person_alias_sub_type_cd = 0, pa.person_id = dpersonid,
            pa.contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, pa
            .beg_effective_dt_tm = cnvtdatetime(dtblank), pa.end_effective_dt_tm = cnvtdatetime(
             holdrec->qual[lidx].end_effective_dt_tm),
            pa.data_status_cd = dauthdatastatuscd, pa.data_status_dt_tm = cnvtdatetime(dtcurrent), pa
            .data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
            pa.active_ind = 1, pa.active_status_cd = dactiveactivestatuscd, pa.active_status_prsnl_id
             = contribrec->qual[lcontribsysidx].prsnl_person_id,
            pa.active_status_dt_tm = cnvtdatetime(dtcurrent), pa.updt_dt_tm = cnvtdatetime(dtcurrent),
            pa.updt_cnt = 0,
            pa.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, pa.updt_task = 424990, pa
            .updt_applctx = 424990,
            pa.check_digit = 0, pa.check_digit_method_cd = 0
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = insert_error
           SET table_name = "PERSON_ALIAS"
           SET ilog_status = 1
           SET log->qual_knt = (log->qual_knt+ 1)
           SET stat = alterlist(log->qual,log->qual_knt)
           SET log->qual[log->qual_knt].smsgtype = "ERROR"
           SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
           SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
           SET serrmsg = log->qual[log->qual_knt].smsg
           GO TO exit_script
          ENDIF
         ENDIF
         IF (size(holdrec->qual[lidx].hist_ssn_alias) > 0)
          SELECT INTO "nl:"
           FROM person_alias pa
           WHERE pa.person_id=dpersonid
            AND ((pa.alias_pool_cd+ 0)=contribrec->qual[lcontribsysidx].ssn_alias_pool_cd)
            AND ((pa.person_alias_type_cd+ 0)=contribrec->qual[lcontribsysidx].ssn_alias_type_cd)
            AND ((pa.active_ind+ 0) != 0)
            AND ((pa.active_status_cd+ 0)=dactiveactivestatuscd)
            AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime2)
           DETAIL
            dpersonaliasid = pa.person_alias_id, dtbegeffective = pa.beg_effective_dt_tm
           WITH nocounter
          ;end select
          IF (curqual > 0)
           IF (datetimediff(dtbegeffective,holdrec->qual[lidx].end_effective_dt_tm,1) != 0.0)
            CALL echo("***   Update Existing Alias")
            UPDATE  FROM person_alias pa
             SET pa.beg_effective_dt_tm = cnvtdatetime(holdrec->qual[lidx].end_effective_dt_tm), pa
              .updt_dt_tm = cnvtdatetime(dtcurrent), pa.updt_cnt = (pa.updt_cnt+ 1)
             WHERE pa.person_alias_id=dpersonaliasid
             WITH nocounter
            ;end update
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = update_error
             SET table_name = "PERSON_ALIAS"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
           ENDIF
          ENDIF
          CALL echo("***")
          CALL echo("***   Add HIST_SSN_ALIAS")
          CALL echo("***")
          SET sactionperformed = concat(trim(sactionperformed),"[s]ha")
          INSERT  FROM person_alias pa
           SET pa.person_alias_id = seq(person_seq,nextval), pa.alias = holdrec->qual[lidx].
            hist_ssn_alias, pa.alias_pool_cd = contribrec->qual[lcontribsysidx].ssn_alias_pool_cd,
            pa.person_alias_type_cd = contribrec->qual[lcontribsysidx].ssn_alias_type_cd, pa
            .person_alias_sub_type_cd = 0, pa.person_id = dpersonid,
            pa.contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, pa
            .beg_effective_dt_tm = cnvtdatetime(dtblank), pa.end_effective_dt_tm = cnvtdatetime(
             holdrec->qual[lidx].end_effective_dt_tm),
            pa.data_status_cd = dauthdatastatuscd, pa.data_status_dt_tm = cnvtdatetime(dtcurrent), pa
            .data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
            pa.active_ind = 1, pa.active_status_cd = dactiveactivestatuscd, pa.active_status_prsnl_id
             = contribrec->qual[lcontribsysidx].prsnl_person_id,
            pa.active_status_dt_tm = cnvtdatetime(dtcurrent), pa.updt_dt_tm = cnvtdatetime(dtcurrent),
            pa.updt_cnt = 0,
            pa.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, pa.updt_task = 424990, pa
            .updt_applctx = 424990,
            pa.check_digit = 0, pa.check_digit_method_cd = 0
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = insert_error
           SET table_name = "PERSON_ALIAS"
           SET ilog_status = 1
           SET log->qual_knt = (log->qual_knt+ 1)
           SET stat = alterlist(log->qual,log->qual_knt)
           SET log->qual[log->qual_knt].smsgtype = "ERROR"
           SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
           SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
           SET serrmsg = log->qual[log->qual_knt].smsg
           GO TO exit_script
          ENDIF
         ENDIF
        ENDIF
       ELSEIF ((holdrec->qual[lidx].match.ext_qual_cnt=0)
        AND (holdrec->qual[lidx].match.ssn_match_cnt=0)
        AND (((holdrec->qual[lidx].hist_match.ext_qual_cnt=1)) OR ((holdrec->qual[lidx].hist_match.
       ssn_match_cnt=1))) )
        CALL echo("***")
        CALL echo("***   #3 - Add New Alias")
        CALL echo("***")
        SET bssn = false
        IF ((holdrec->qual[lidx].hist_match.ext_qual_cnt=1))
         SET dhistpersonid = holdrec->qual[lidx].hist_match.ext_qual[1].person_id
        ENDIF
        IF ((holdrec->qual[lidx].hist_match.ssn_match_cnt=1))
         SET bssn = true
         SET lhistmatchidx = holdrec->qual[lidx].hist_match.ssn_match_idx
         SET dhistpersonid = holdrec->qual[lidx].hist_match.ssn_qual[lhistmatchidx].person_id
        ENDIF
        UPDATE  FROM ags_mrg_data r
         SET r.hist_person_id = dhistpersonid, r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm =
          cnvtdatetime(dtcurrent)
         WHERE (r.ags_mrg_data_id=holdrec->qual[lidx].ags_mrg_data_id)
         WITH nocounter
        ;end update
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = update_error
         SET table_name = "AGS_MRG_DATA"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("Add New Alias - AgsMrgDataId :: ",trim(
           cnvtstring(holdrec->qual[lidx].ags_mrg_data_id)),"ErrMsg :: ",trim(serrmsg))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        IF ((holdrec->qual[lidx].match.ssn_qual_cnt > 1))
         CALL echo("***")
         CALL echo("***   Manual Review")
         CALL echo("***")
         SET sactionperformed = concat(trim(sactionperformed),"[pm]na")
         FOR (lidx2 = 1 TO holdrec->qual[lidx].match.ssn_qual_cnt)
          SELECT INTO "nl:"
           FROM person_matches p
           WHERE ((p.a_person_id=dhistpersonid
            AND (p.b_person_id=holdrec->qual[lidx].match.ssn_qual[lidx2].person_id)) OR ((p
           .a_person_id=holdrec->qual[lidx].match.ssn_qual[lidx2].person_id)
            AND p.b_person_id=dhistpersonid))
           WITH nocounter
          ;end select
          IF (curqual <= 0)
           CALL echo("***")
           CALL echo("***   Insert PERSON_MATCHES")
           CALL echo("***")
           INSERT  FROM person_matches p
            SET p.person_matches_id = seq(person_seq,nextval), p.a_ssn_alias = holdrec->qual[lidx].
             ssn_alias, p.a_birth_dt_tm = cnvtdatetime(holdrec->qual[lidx].match.ssn_qual[lidx2].
              birth_dt_tm),
             p.a_birth_tz = contribrec->qual[lcontribsysidx].time_zone_idx, p.a_create_prsnl_id =
             contribrec->qual[lcontribsysidx].prsnl_person_id, p.a_person_id = holdrec->qual[lidx].
             match.ssn_qual[lidx2].person_id,
             p.a_name_first_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].match.ssn_qual[lidx2].
               name_first)), p.a_name_last_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].match.
               ssn_qual[lidx2].name_last)), p.a_name_middle = cnvtupper(cnvtalphanum(holdrec->qual[
               lidx].match.ssn_qual[lidx2].name_middle)),
             p.a_sex_cd = holdrec->qual[lidx].match.ssn_qual[lidx2].sex_cd, p.a_active_status_cd =
             holdrec->qual[lidx].match.ssn_qual[lidx2].active_status_cd, p.b_ssn_alias =
             IF (bssn) holdrec->qual[lidx].hist_ssn_alias
             ELSE ""
             ENDIF
             ,
             p.b_alias =
             IF (bssn) ""
             ELSE holdrec->qual[lidx].hist_ext_alias
             ENDIF
             , p.b_alias_pool_cd =
             IF (bssn) 0.0
             ELSE contribrec->qual[lcontribsysidx].ext_alias_pool_cd
             ENDIF
             , p.b_alias_type_cd =
             IF (bssn) 0.0
             ELSE contribrec->qual[lcontribsysidx].ext_alias_type_cd
             ENDIF
             ,
             p.b_birth_dt_tm =
             IF (bssn) cnvtdatetime(holdrec->qual[lidx].hist_match.ssn_qual[lhistmatchidx].
               birth_dt_tm)
             ELSE cnvtdatetime(holdrec->qual[lidx].hist_match.ext_qual[1].birth_dt_tm)
             ENDIF
             , p.b_birth_tz = contribrec->qual[lcontribsysidx].time_zone_idx, p.b_create_prsnl_id =
             contribrec->qual[lcontribsysidx].prsnl_person_id,
             p.b_person_id = dhistpersonid, p.b_name_first_key =
             IF (bssn) cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_match.ssn_qual[lhistmatchidx].
                name_first))
             ELSE cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_match.ext_qual[1].name_first))
             ENDIF
             , p.b_name_last_key =
             IF (bssn) cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_match.ssn_qual[lhistmatchidx].
                name_last))
             ELSE cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_match.ext_qual[1].name_last))
             ENDIF
             ,
             p.b_name_middle =
             IF (bssn) cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_match.ssn_qual[lhistmatchidx].
                name_middle))
             ELSE cnvtupper(cnvtalphanum(holdrec->qual[lidx].hist_match.ext_qual[1].name_middle))
             ENDIF
             , p.b_sex_cd =
             IF (bssn) holdrec->qual[lidx].hist_match.ssn_qual[lhistmatchidx].sex_cd
             ELSE holdrec->qual[lidx].hist_match.ext_qual[1].sex_cd
             ENDIF
             , p.b_active_status_cd =
             IF (bssn) holdrec->qual[lidx].hist_match.ssn_qual[lhistmatchidx].active_status_cd
             ELSE holdrec->qual[lidx].hist_match.ext_qual[1].active_status_cd
             ENDIF
             ,
             p.match_dt_tm = cnvtdatetime(dtcurrent), p.match_source_cd = dmatchsourcecd, p
             .beg_effective_dt_tm = cnvtdatetime(dtcurrent),
             p.end_effective_dt_tm = cnvtdatetime(dtmax), p.active_ind = 1, p.active_status_cd =
             dactiveactivestatuscd,
             p.active_status_dt_tm = cnvtdatetime(dtcurrent), p.active_status_prsnl_id = contribrec->
             qual[lcontribsysidx].prsnl_person_id, p.updt_applctx = 424990,
             p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(dtcurrent), p.updt_id = contribrec->qual[
             lcontribsysidx].prsnl_person_id,
             p.updt_task = 424990
            WITH nocounter
           ;end insert
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = insert_error
            SET table_name = "PERSON_MATCHES"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
          ENDIF
         ENDFOR
        ELSE
         IF (size(holdrec->qual[lidx].ext_alias) > 0)
          SELECT INTO "nl:"
           FROM person_alias pa
           WHERE pa.person_id=dhistpersonid
            AND ((pa.alias_pool_cd+ 0)=contribrec->qual[lcontribsysidx].ext_alias_pool_cd)
            AND ((pa.person_alias_type_cd+ 0)=contribrec->qual[lcontribsysidx].ext_alias_type_cd)
            AND ((pa.active_ind+ 0) != 0)
            AND ((pa.active_status_cd+ 0)=dactiveactivestatuscd)
            AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime2)
           DETAIL
            dpersonaliasid = pa.person_alias_id
           WITH nocounter
          ;end select
          IF (curqual > 0)
           CALL echo("***   Update Existing Alias")
           UPDATE  FROM person_alias pa
            SET pa.end_effective_dt_tm = cnvtdatetime(holdrec->qual[lidx].end_effective_dt_tm), pa
             .updt_dt_tm = cnvtdatetime(dtcurrent), pa.updt_cnt = (pa.updt_cnt+ 1)
            WHERE pa.person_alias_id=dpersonaliasid
            WITH nocounter
           ;end update
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = update_error
            SET table_name = "PERSON_ALIAS"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
          ENDIF
          CALL echo("***")
          CALL echo("***   Add EXT_ALIAS")
          CALL echo("***")
          SET sactionperformed = concat(trim(sactionperformed),"[x]na")
          INSERT  FROM person_alias pa
           SET pa.person_alias_id = seq(person_seq,nextval), pa.alias = holdrec->qual[lidx].ext_alias,
            pa.alias_pool_cd = contribrec->qual[lcontribsysidx].ext_alias_pool_cd,
            pa.person_alias_type_cd = contribrec->qual[lcontribsysidx].ext_alias_type_cd, pa
            .person_alias_sub_type_cd = 0, pa.person_id = dhistpersonid,
            pa.contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, pa
            .beg_effective_dt_tm = cnvtdatetime(holdrec->qual[lidx].end_effective_dt_tm), pa
            .end_effective_dt_tm = cnvtdatetime(dtmax),
            pa.data_status_cd = dauthdatastatuscd, pa.data_status_dt_tm = cnvtdatetime(dtcurrent), pa
            .data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
            pa.active_ind = 1, pa.active_status_cd = dactiveactivestatuscd, pa.active_status_prsnl_id
             = contribrec->qual[lcontribsysidx].prsnl_person_id,
            pa.active_status_dt_tm = cnvtdatetime(dtcurrent), pa.updt_dt_tm = cnvtdatetime(dtcurrent),
            pa.updt_cnt = 0,
            pa.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, pa.updt_task = 424990, pa
            .updt_applctx = 424990,
            pa.check_digit = 0, pa.check_digit_method_cd = 0
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = insert_error
           SET table_name = "PERSON_ALIAS"
           SET ilog_status = 1
           SET log->qual_knt = (log->qual_knt+ 1)
           SET stat = alterlist(log->qual,log->qual_knt)
           SET log->qual[log->qual_knt].smsgtype = "ERROR"
           SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
           SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
           SET serrmsg = log->qual[log->qual_knt].smsg
           GO TO exit_script
          ENDIF
         ENDIF
         IF (size(holdrec->qual[lidx].ssn_alias) > 0)
          SELECT INTO "nl:"
           FROM person_alias pa
           WHERE pa.person_id=dhistpersonid
            AND ((pa.alias_pool_cd+ 0)=contribrec->qual[lcontribsysidx].ssn_alias_pool_cd)
            AND ((pa.person_alias_type_cd+ 0)=contribrec->qual[lcontribsysidx].ssn_alias_type_cd)
            AND ((pa.active_ind+ 0) != 0)
            AND ((pa.active_status_cd+ 0)=dactiveactivestatuscd)
            AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime2)
           DETAIL
            dpersonaliasid = pa.person_alias_id
           WITH nocounter
          ;end select
          IF (curqual > 0)
           CALL echo("***   Update Existing Alias")
           UPDATE  FROM person_alias pa
            SET pa.end_effective_dt_tm = cnvtdatetime(holdrec->qual[lidx].end_effective_dt_tm), pa
             .updt_dt_tm = cnvtdatetime(dtcurrent), pa.updt_cnt = (pa.updt_cnt+ 1)
            WHERE pa.person_alias_id=dpersonaliasid
            WITH nocounter
           ;end update
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = update_error
            SET table_name = "PERSON_ALIAS"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
          ENDIF
          CALL echo("***")
          CALL echo("***   Add SSN_ALIAS")
          CALL echo("***")
          SET sactionperformed = concat(trim(sactionperformed),"[s]na")
          INSERT  FROM person_alias pa
           SET pa.person_alias_id = seq(person_seq,nextval), pa.alias = holdrec->qual[lidx].ssn_alias,
            pa.alias_pool_cd = contribrec->qual[lcontribsysidx].ssn_alias_pool_cd,
            pa.person_alias_type_cd = contribrec->qual[lcontribsysidx].ssn_alias_type_cd, pa
            .person_alias_sub_type_cd = 0, pa.person_id = dhistpersonid,
            pa.contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, pa
            .beg_effective_dt_tm = cnvtdatetime(holdrec->qual[lidx].end_effective_dt_tm), pa
            .end_effective_dt_tm = cnvtdatetime(dtmax),
            pa.data_status_cd = dauthdatastatuscd, pa.data_status_dt_tm = cnvtdatetime(dtcurrent), pa
            .data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
            pa.active_ind = 1, pa.active_status_cd = dactiveactivestatuscd, pa.active_status_prsnl_id
             = contribrec->qual[lcontribsysidx].prsnl_person_id,
            pa.active_status_dt_tm = cnvtdatetime(dtcurrent), pa.updt_dt_tm = cnvtdatetime(dtcurrent),
            pa.updt_cnt = 0,
            pa.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, pa.updt_task = 424990, pa
            .updt_applctx = 424990,
            pa.check_digit = 0, pa.check_digit_method_cd = 0
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = insert_error
           SET table_name = "PERSON_ALIAS"
           SET ilog_status = 1
           SET log->qual_knt = (log->qual_knt+ 1)
           SET stat = alterlist(log->qual,log->qual_knt)
           SET log->qual[log->qual_knt].smsgtype = "ERROR"
           SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
           SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
           SET serrmsg = log->qual[log->qual_knt].smsg
           GO TO exit_script
          ENDIF
         ENDIF
        ENDIF
       ELSEIF ((((holdrec->qual[lidx].match.ext_qual_cnt=1)) OR ((holdrec->qual[lidx].match.
       ssn_match_cnt=1)))
        AND (((holdrec->qual[lidx].hist_match.ext_qual_cnt=1)) OR ((holdrec->qual[lidx].hist_match.
       ssn_match_cnt=1))) )
        CALL echo("***")
        CALL echo("***   #4 - Combine")
        CALL echo("***")
        IF ((holdrec->qual[lidx].match.ext_qual_cnt=1))
         SET dpersonid = holdrec->qual[lidx].match.ext_qual[1].person_id
        ENDIF
        IF ((holdrec->qual[lidx].match.ssn_match_cnt=1))
         SET lmatchidx = holdrec->qual[lidx].match.ssn_match_idx
         SET dpersonid = holdrec->qual[lidx].match.ssn_qual[lmatchidx].person_id
        ENDIF
        IF ((holdrec->qual[lidx].hist_match.ext_qual_cnt=1))
         SET dhistpersonid = holdrec->qual[lidx].hist_match.ext_qual[1].person_id
        ENDIF
        IF ((holdrec->qual[lidx].hist_match.ssn_match_cnt=1))
         SET lhistmatchidx = holdrec->qual[lidx].hist_match.ssn_match_idx
         SET dhistpersonid = holdrec->qual[lidx].hist_match.ssn_qual[lhistmatchidx].person_id
        ENDIF
        UPDATE  FROM ags_mrg_data r
         SET r.person_id = dpersonid, r.hist_person_id = dhistpersonid, r.updt_cnt = (r.updt_cnt+ 1),
          r.updt_dt_tm = cnvtdatetime(dtcurrent)
         WHERE (r.ags_mrg_data_id=holdrec->qual[lidx].ags_mrg_data_id)
         WITH nocounter
        ;end update
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = update_error
         SET table_name = "AGS_MRG_DATA"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("Combine AgsMrgDataId :: ",trim(cnvtstring(
            holdrec->qual[lidx].ags_mrg_data_id)),"ErrMsg :: ",trim(serrmsg))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        IF (dpersonid=dhistpersonid)
         SET holdrec->qual[lidx].stat_msg = concat(trim(holdrec->qual[lidx].stat_msg),"[p]s")
        ELSE
         SET stat = initrec(toaliasrec)
         SET stat = initrec(fromaliasrec)
         SET sactionperformed = "[COMBINE]"
         SELECT INTO "nl:"
          FROM person_alias p
          WHERE p.person_id IN (dpersonid, dhistpersonid)
           AND p.end_effective_dt_tm > cnvtdatetime(dtcurrent)
           AND p.active_ind != 0
          HEAD REPORT
           lidx2 = 0, lidx3 = 0
          DETAIL
           IF (p.person_id=dpersonid)
            lidx2 = (lidx2+ 1), toaliasrec->qual_cnt = lidx2, stat = alterlist(toaliasrec->qual,lidx2
             ),
            toaliasrec->qual[lidx2].person_alias_id = p.person_alias_id, toaliasrec->qual[lidx2].
            alias_type_cd = p.person_alias_type_cd, toaliasrec->qual[lidx2].alias_pool_cd = p
            .alias_pool_cd
           ELSE
            lidx3 = (lidx3+ 1), fromaliasrec->qual_cnt = lidx3, stat = alterlist(fromaliasrec->qual,
             lidx3),
            fromaliasrec->qual[lidx3].person_alias_id = p.person_alias_id, fromaliasrec->qual[lidx3].
            alias_type_cd = p.person_alias_type_cd, fromaliasrec->qual[lidx3].alias_pool_cd = p
            .alias_pool_cd
           ENDIF
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
          SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ENDIF
         IF (lloglevel > 1)
          CALL echorecord(toaliasrec)
          CALL echorecord(fromaliasrec)
         ENDIF
         CALL echo("***")
         CALL echo("***   Call Combine")
         CALL echo("***")
         CALL uar_srvreset(crmrec->hreq,0)
         CALL uar_srvreset(crmrec->hrep,0)
         CALL uar_srvsetstring(crmrec->hreq,"parent_table",nullterm("PERSON"))
         CALL uar_srvsetstring(crmrec->hreq,"transaction_type",nullterm("RHIOCMB"))
         SET hitem = uar_srvadditem(crmrec->hreq,"xxx_combine")
         CALL uar_srvsetdouble(hitem,"to_xxx_id",dpersonid)
         CALL uar_srvsetdouble(hitem,"from_xxx_id",dhistpersonid)
         CALL uar_srvsetshort(hitem,"application_flag",100)
         IF (lloglevel > 1)
          CALL echo(
           "/------------------------ CRMReq Begin ----------------------------------------/")
          CALL uar_sisrvdump(crmrec->hreq)
          CALL echo(
           "/------------------------- CRMReq End -----------------------------------------/")
         ENDIF
         SET lstat = uar_crmperform(crmrec->hstep)
         SET crmrec->hrep = uar_crmgetreply(crmrec->hstep)
         IF (((lloglevel > 1) OR (lstat > 0)) )
          CALL echo("/------------------------ REP Begin ----------------------------------------/")
          CALL uar_sisrvdump(crmrec->hrep)
          CALL echo("/------------------------- REP End -----------------------------------------/")
         ENDIF
         IF (lstat)
          SET hsbstruct = uar_srvgetstruct(crmrec->hrep,"sb")
          SET sstatusmsg = uar_srvgetstringptr(hsbstruct,"statusText")
          CALL echo(build("statusText:",sstatusmsg))
          CALL echo(build("FAILURE!! uar_CrmPerform() status = ",lstat))
          SET failed = exe_error
          SET table_name = "uar_CrmPerform()"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = build("uar_CrmPerform() :: Stat :: ",lstat)
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ELSE
          CALL echo("uar_CrmPerform() was successful.")
         ENDIF
         SET hstruct = uar_srvgetstruct(crmrec->hrep,"status_data")
         IF (cnvtupper(uar_srvgetstringptr(hstruct,"status"))="F")
          SET sstatusmsg = " "
          FOR (lidx2 = 0 TO (uar_srvgetitemcount(crmrec->hrep,"error") - 1))
           SET hitem = uar_srvgetitem(crmrec->hrep,"error")
           SET sstatusmsg = concat(sstatusmsg,uar_srvgetstringptr(hitem,"error_msg"))
          ENDFOR
          SET holdrec->qual[lidx].error = true
          SET holdrec->qual[lidx].stat_msg = concat(trim(holdrec->qual[lidx].stat_msg),"[r]",trim(
            sstatusmsg))
          SET failed = exe_error
          SET table_name = "CE Reply"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = concat("clinical_event_id :: ErrMsg :: ",trim(
            sstatusmsg))
          SET serrmsg = log->qual[log->qual_knt].smsg
         ELSE
          CALL echo("***")
          CALL echo("***   END_EFFECTIVE Aliases")
          CALL echo("***")
          SET bendeffectaliases = false
          FOR (lidx2 = 1 TO fromaliasrec->qual_cnt)
            FOR (lidx3 = 1 TO toaliasrec->qual_cnt)
              IF ((fromaliasrec->qual[lidx2].alias_type_cd=toaliasrec->qual[lidx3].alias_type_cd)
               AND (fromaliasrec->qual[lidx2].alias_pool_cd=toaliasrec->qual[lidx3].alias_pool_cd))
               SET bendeffectaliases = true
               UPDATE  FROM person_alias p
                SET p.end_effective_dt_tm = cnvtdatetime(dtcurrent), p.updt_cnt = (p.updt_cnt+ 1), p
                 .updt_dt_tm = cnvtdatetime(dtcurrent)
                WHERE (p.person_alias_id=fromaliasrec->qual[lidx2].person_alias_id)
                WITH nocounter
               ;end update
               SET ierrcode = error(serrmsg,1)
               IF (ierrcode > 0)
                SET failed = update_error
                SET table_name = "PERSON_ALIAS"
                SET ilog_status = 1
                SET log->qual_knt = (log->qual_knt+ 1)
                SET stat = alterlist(log->qual,log->qual_knt)
                SET log->qual[log->qual_knt].smsgtype = "ERROR"
                SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
                SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
                SET serrmsg = log->qual[log->qual_knt].smsg
                GO TO exit_script
               ENDIF
              ENDIF
            ENDFOR
          ENDFOR
          IF (bendeffectaliases)
           UPDATE  FROM person p
            SET p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(dtcurrent)
            WHERE p.person_id=dpersonid
            WITH nocounter
           ;end update
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = update_error
            SET table_name = "PERSON"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->squal_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      UPDATE  FROM ags_mrg_data r
       SET r.contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, r
        .action_performed = trim(sactionperformed), r.status =
        IF ((holdrec->qual[lidx].error != 0)) "IN ERROR"
        ELSE "COMPLETE"
        ENDIF
        ,
        r.stat_msg = trim(holdrec->qual[lidx].stat_msg), r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm
         = cnvtdatetime(dtcurrent)
       WHERE (r.ags_mrg_data_id=holdrec->qual[lidx].ags_mrg_data_id)
        AND (holdrec->qual[lidx].ags_mrg_data_id > 0)
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = update_error
       SET table_name = "AGS_MRG_DATA"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("AgsMrgDataId :: ",trim(cnvtstring(holdrec->qual[
          lidx].ags_mrg_data_id)),"ErrMsg :: ",trim(serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
      COMMIT
    ENDFOR
    IF (lloglevel > 1)
     CALL echorecord(holdrec)
    ENDIF
    SET lavgsec = 0
    SET litcount = (litcount+ 1)
    SET dtitend = cnvtdatetime(curdate,curtime2)
    IF ((holdrec->qual_cnt > 0))
     SET lavgsec = (cnvtreal(holdrec->qual_cnt)/ datetimediff(dtitend,dtitstart,5))
    ENDIF
    IF (lavgsec > 0)
     SET dtestcompletion = cnvtlookahead(concat(cnvtstring(ceil((cnvtreal(((dbatchendid - dendid)+ 1)
          )/ lavgsec))),",S"),dtitend)
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_task t
     SET t.iteration_start_id = dstartid, t.iteration_end_id = dendid, t.iteration_count = litcount,
      t.iteration_start_dt_tm = cnvtdatetime(dtitstart), t.iteration_end_dt_tm = cnvtdatetime(dtitend
       ), t.iteration_average = lavgsec,
      t.est_completion_dt_tm = cnvtdatetime(dtestcompletion), t.updt_cnt = (t.updt_cnt+ 1), t
      .updt_dt_tm = cnvtdatetime(dtcurrent)
     PLAN (t
      WHERE t.ags_task_id=dtaskid)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "UPDATE ITERATION"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("UPDATE ITERATION :: Update Error :: ",trim(serrmsg))
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
    t.updt_cnt = (t.updt_cnt+ 1), t.updt_dt_tm = cnvtdatetime(dtcurrent)
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
   SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"CurQual :: ",cnvtint(
     curqual))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  IF (lkillind != 0)
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
     SET j.status = "COMPLETE", j.status_dt_tm = cnvtdatetime(dtcurrent)
     WHERE j.ags_job_id=dagsjobid
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE create_crmhandles(dummy1)
   CALL echo("Begin Create_CRMHandles()")
   CALL destroy_crmhandles(0)
   SET crmrec->status = uar_crmbeginapp(crmrec->app,crmrec->happ)
   IF (crmrec->status)
    CALL echo(concat("Begin app failed with status: ",cnvtstring(crmrec->status)))
    RETURN(0)
   ENDIF
   CALL echo(concat("Begin app handle: ",cnvtstring(crmrec->happ)))
   SET crmrec->status = uar_crmbegintask(crmrec->happ,crmrec->task,crmrec->htask)
   IF (crmrec->status)
    CALL echo(concat("Begin task failed with status: ",cnvtstring(crmrec->status)))
    RETURN(0)
   ENDIF
   CALL echo(concat("Begin task handle: ",cnvtstring(crmrec->htask)))
   IF (crmrec->req)
    SET status = uar_crmbeginreq(crmrec->htask,"",crmrec->req,crmrec->hstep)
    IF (crmrec->status)
     CALL echo(concat("Begin Req failed with status: ",cnvtstring(crmrec->status)))
     RETURN(0)
    ENDIF
    CALL echo(concat("Begin Req handle CRMRec->hStep=",cnvtstring(crmrec->hstep)))
    SET crmrec->hreq = uar_crmgetrequest(crmrec->hstep)
    IF ( NOT (crmrec->hreq))
     CALL echo(concat("Get Reqest failed CRMRec->hReq=",cnvtstring(crmrec->hreq)))
     RETURN(0)
    ENDIF
    CALL echo(concat("Get Req handle CRMRec->hReq=",cnvtstring(crmrec->hreq)))
   ENDIF
   CALL echo("End Create_CRMHandles()")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE destroy_crmhandles(dummy1)
   CALL echo("Begin Destroy_CRMHandles()")
   IF (crmrec->hstep)
    CALL uar_crmendreq(crmrec->hstep)
   ENDIF
   IF (crmrec->htask)
    CALL uar_crmendtask(crmrec->htask)
   ENDIF
   IF (crmrec->happ)
    CALL uar_crmendapp(crmrec->happ)
   ENDIF
   CALL echo("End Destroy_CRMHandles()")
   RETURN(1)
 END ;Subroutine
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
 SET log->qual[log->qual_knt].smsg = "END >> AGS_MRG_LOAD"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 CALL echo("<===== AGS_MRG_LOAD End =====>")
END GO
