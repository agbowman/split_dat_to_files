CREATE PROGRAM ags_result_load:dba
 PROMPT
  "TASK_ID                (0.0) = " = 0,
  "Check For Duplicates (1-Yes) = " = 1
  WITH dtid, bhold
 CALL echo("<===== AGS_RESULT_LOAD Begin =====>")
 SET script_ver = "008 10/18/06"
 CALL echo(concat("MOD:",script_ver))
 EXECUTE srvrtl
 EXECUTE crmrtl
 DECLARE uar_sisrvdump(p1=i4(ref)) = null WITH uar = "SiSrvDump", image_aix =
 "libsirtl.a(libsirtl.o)", image_axp = "sirtl"
 DECLARE define_logging_sub = i2 WITH public, noconstant(false)
 FREE RECORD exceptionrec
 RECORD exceptionrec(
   1 remove = i2
   1 qual_cnt = i4
   1 qual[*]
     2 idx = i4
     2 ags_result_data_id = f8
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
     2 performing_alias_pool_cd = f8
     2 performing_alias_type_cd = f8
     2 qual0_cnt = i4
     2 qual0[*]
       3 performing_ext_alias = vc
       3 performing_person_id = f8
     2 ext_alias_pool_cd = f8
     2 ext_alias_type_cd = f8
     2 qual1_cnt = i4
     2 qual1[*]
       3 ext_alias = vc
       3 name_first = vc
       3 name_last = vc
       3 birth_dt_tm = dq8
       3 sex_cd = f8
       3 person_id = f8
     2 ssn_alias_pool_cd = f8
     2 ssn_alias_type_cd = f8
     2 qual2_cnt = i4
     2 qual2[*]
       3 ssn_alias = vc
       3 name_first = vc
       3 name_last = vc
       3 birth_dt_tm = dq8
       3 sex_cd = f8
       3 person_id = f8
     2 providernum_alias_pool_cd = f8
     2 ext_prsnl_alias_type_cd = f8
     2 qual3_cnt = i4
     2 qual3[*]
       3 ordering_ext_alias = vc
       3 ordering_person_id = f8
     2 qual4_cnt = i4
     2 qual4[*]
       3 event_code = vc
       3 event_cd = f8
     2 qual5_cnt = i4
     2 qual5[*]
       3 unit_of_measure = vc
       3 unit_of_measure_cd = f8
     2 qual6_cnt = i4
     2 qual6[*]
       3 normalcy = vc
       3 normalcy_cd = f8
     2 qual7_cnt = i4
     2 qual7[*]
       3 service_resource = vc
       3 service_resource_cd = f8
 )
 FREE RECORD holdrec
 RECORD holdrec(
   1 qual_cnt = i4
   1 qual[*]
     2 error = i2
     2 duplicate = i2
     2 ags_result_data_id = f8
     2 contrib_sys_idx = i4
     2 contributor_system_cd = f8
     2 person_id = f8
     2 ordering_prsnl_id = f8
     2 verified_prsnl_id = f8
     2 performed_prsnl_id = f8
     2 note_prsnl_id = f8
     2 result_identifier = vc
     2 event_title_text = vc
     2 clinical_event_id = f8
     2 event_id = f8
     2 event_dt_tm = dq8
     2 event_title_text = vc
     2 result_val = vc
     2 is_numeric = i2
     2 ce_event_note_id = f8
     2 event_note = vc
     2 normal_high = vc
     2 normal_low = vc
     2 ext_alias_idx = i4
     2 ssn_alias_idx = i4
     2 perf_ext_alias_idx = i4
     2 ord_ext_alias_idx = i4
     2 chr_event_code_idx = i4
     2 event_code_idx = i4
     2 event_cd = f8
     2 chr_unit_of_meas_idx = i4
     2 unit_of_meas_idx = i4
     2 unit_of_measure_cd = f8
     2 chr_normalcy_idx = i4
     2 normalcy_idx = i4
     2 normalcy_cd = f8
     2 service_resource_idx = i4
     2 chr_service_resource_idx = i4
     2 service_resource_cd = f8
     2 status = c10
     2 stat_msg = c40
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
  DECLARE sstatus_file_name = vc WITH public, constant(concat("ags_result_load_",format(cnvtdatetime(
      curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
 ENDIF
 DECLARE hitem = i4 WITH public, noconstant(0)
 DECLARE hitem2 = i4 WITH public, noconstant(0)
 DECLARE hclinevent = i4 WITH public, noconstant(0)
 DECLARE hstrresult = i4 WITH public, noconstant(0)
 DECLARE heventnote = i4 WITH public, noconstant(0)
 DECLARE heventprsnl_order = i4 WITH public, noconstant(0)
 DECLARE heventprsnl_perform = i4 WITH public, noconstant(0)
 DECLARE heventprsnl_verify = i4 WITH public, noconstant(0)
 DECLARE hrblistitem = i4 WITH public, noconstant(0)
 DECLARE hsbstruct = i4 WITH public, noconstant(0)
 DECLARE lchunksize = i4 WITH public, constant(500)
 DECLARE dtaskid = f8 WITH public, constant(cnvtreal( $DTID))
 DECLARE staskid = vc WITH public, constant(trim(cnvtstring(dtaskid)))
 DECLARE bcheckfordups = i2 WITH public, noconstant(1)
 IF (( $BHOLD > 0))
  SET bcheckfordups = true
 ELSE
  SET bcheckfordups = false
 ENDIF
 DECLARE dagsjobid = f8 WITH public, noconstant(0.0)
 DECLARE lbatchsize = i4 WITH public, noconstant(0)
 DECLARE ldefaultbatchsize = i4 WITH public, constant(1000)
 DECLARE lkillind = i2 WITH public, noconstant(0)
 DECLARE lmodeflag = i2 WITH public, noconstant(0)
 DECLARE dbatchstartid = f8 WITH public, noconstant(0.0)
 DECLARE dbatchendid = f8 WITH public, noconstant(0.0)
 DECLARE dstartid = f8 WITH public, noconstant(0.0)
 DECLARE dendid = f8 WITH public, noconstant(0.0)
 DECLARE dcontribsyscd = f8 WITH public, noconstant(0.0)
 DECLARE dpersonid = f8 WITH public, noconstant(0.0)
 DECLARE deventcd = f8 WITH public, noconstant(0.0)
 DECLARE dclineventid = f8 WITH public, noconstant(0.0)
 DECLARE deventid = f8 WITH public, noconstant(0.0)
 DECLARE dceeventnoteid = f8 WITH public, noconstant(0.0)
 DECLARE berror = i2 WITH public, noconstant(false)
 DECLARE bperson = i2 WITH public, noconstant(false)
 DECLARE bdup = i2 WITH public, noconstant(false)
 DECLARE bcopy = i2 WITH public, noconstant(false)
 DECLARE bstop = i2 WITH public, noconstant(false)
 DECLARE lloglevel = i2 WITH public, noconstant(0)
 DECLARE lnum = i4 WITH public, noconstant(0)
 DECLARE lfirstdash = i4 WITH public, noconstant(0)
 DECLARE lseconddash = i4 WITH public, noconstant(0)
 DECLARE lavgsec = i4 WITH public, noconstant(0)
 DECLARE litcount = i4 WITH public, noconstant(0)
 DECLARE lidx = i4 WITH public, noconstant(0)
 DECLARE lidx2 = i4 WITH public, noconstant(0)
 DECLARE lidx3 = i4 WITH public, noconstant(0)
 DECLARE lidx4 = i4 WITH public, noconstant(0)
 DECLARE lchrcontribsrcidx = i4 WITH public, noconstant(0)
 DECLARE ljobcontribsysidx = i4 WITH public, noconstant(0)
 DECLARE lcontribsysidx = i4 WITH public, noconstant(0)
 DECLARE lchreventidx = i4 WITH public, noconstant(0)
 DECLARE lchruofmidx = i4 WITH public, noconstant(0)
 DECLARE lchrnormidx = i4 WITH public, noconstant(0)
 DECLARE lchrservidx = i4 WITH public, noconstant(0)
 DECLARE lextidx = i4 WITH public, noconstant(0)
 DECLARE lssnidx = i4 WITH public, noconstant(0)
 DECLARE lperfprsnlidx = i4 WITH public, noconstant(0)
 DECLARE lordprsnlidx = i4 WITH public, noconstant(0)
 DECLARE leventidx = i4 WITH public, noconstant(0)
 DECLARE luofmidx = i4 WITH public, noconstant(0)
 DECLARE lnormidx = i4 WITH public, noconstant(0)
 DECLARE lservidx = i4 WITH public, noconstant(0)
 DECLARE seventnote = vc WITH public, noconstant("")
 DECLARE sssnalias = vc WITH public, noconstant("")
 DECLARE sresultidentifier = vc WITH public, noconstant("")
 DECLARE sresultval = vc WITH public, noconstant("")
 DECLARE seventdate = vc WITH public, noconstant("")
 DECLARE seventdatetime = vc WITH public, noconstant("")
 DECLARE ssendingfacility = vc WITH public, noconstant("")
 DECLARE srefrange = vc WITH public, noconstant("")
 DECLARE sextalias = vc WITH public, noconstant("")
 DECLARE sperfextalias = vc WITH public, noconstant("")
 DECLARE sordextalias = vc WITH public, noconstant("")
 DECLARE seventcode = vc WITH public, noconstant("")
 DECLARE sunitofmeas = vc WITH public, noconstant("")
 DECLARE snormalcy = vc WITH public, noconstant("")
 DECLARE slongblob = vc WITH public, noconstant("")
 DECLARE sstatusmsg = vc WITH public, noconstant(" ")
 DECLARE dtmax = dq8 WITH public, constant(cnvtdatetime("31-DEC-2100 00:00:00.00"))
 DECLARE dtcurrent = dq8 WITH public, constant(cnvtdatetime(curdate,curtime2))
 DECLARE dtestcompletion = dq8 WITH public, noconstant
 DECLARE dchrcontribsrccd = f8 WITH public, constant(uar_get_code_by("MEANING",73,"CERNERCHR"))
 DECLARE ddefaultsrccd = f8 WITH public, constant(uar_get_code_by("MEANING",73,"DEFAULT"))
 DECLARE dtxteventclasscd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"TXT"))
 DECLARE dnumeventclasscd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"NUM"))
 DECLARE dnumresultformatcd = f8 WITH public, constant(uar_get_code_by("MEANING",14113,"NUMERIC"))
 DECLARE dalpharesultformatcd = f8 WITH public, constant(uar_get_code_by("MEANING",14113,"ALPHA"))
 DECLARE dssnaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PRSNSSN"))
 DECLARE dextaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PRSNEXTALIAS"
   ))
 DECLARE dperfaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "RESPERFPRSNL"))
 DECLARE dresordprovideraliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "RESORDER"))
 DECLARE dorderactiontypecd = f8 WITH public, constant(uar_get_code_by("MEANING",21,"ORDER"))
 DECLARE dperformactiontypecd = f8 WITH public, constant(uar_get_code_by("MEANING",21,"PERFORM"))
 DECLARE dverifyactiontypecd = f8 WITH public, constant(uar_get_code_by("MEANING",21,"VERIFY"))
 DECLARE dentrymethodcd = f8 WITH public, constant(uar_get_code_by("MEANING",13,"UNKNOWN"))
 DECLARE dnotetypecd = f8 WITH public, constant(uar_get_code_by("MEANING",14,"RES COMMENT"))
 DECLARE dnoteformatcd = f8 WITH public, constant(uar_get_code_by("MEANING",23,"AH"))
 DECLARE dcompleteactionstatuscd = f8 WITH public, constant(uar_get_code_by("MEANING",103,"COMPLETED"
   ))
 DECLARE drooteventreltncd = f8 WITH public, constant(uar_get_code_by("MEANING",24,"ROOT"))
 DECLARE dactiverecstatuscd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dauthresultstatuscd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE droutineclininquiresecuritycd = f8 WITH public, constant(uar_get_code_by("MEANING",87,
   "ROUTCLINICAL"))
 DECLARE dundefentrymodecd = f8 WITH public, constant(uar_get_code_by("MEANING",29520,"UNDEFINED"))
 DECLARE dpremedrecsourcecd = f8 WITH public, constant(uar_get_code_by("MEANING",30200,"PREVMEDREC"))
 DECLARE dcompressiontycd = f8 WITH public, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE dmalesexcd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"MALE"))
 DECLARE dfemalesexcd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"FEMALE"))
 IF (dssnaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dSSNAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "SSN DataUploadEATFields :: Select Error :: CODE_VALUE for CDF_MEANING PRSNSSN invalid from CODE_SET 4001891"
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
  "EXT Alias DataUploadEATFields :: Select Error :: CODE_VALUE for CDF_MEANING PRSNSSN invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dperfaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dPERFAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "EXT Alias DataUploadEATFields :: Select Error :: CODE_VALUE for CDF_MEANING RESPERFORG invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dresordprovideraliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dResOrdProviderAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "ResOrdProvider DataUploadEATFields :: Select Error :: CODE_VALUE for CDF_MEANING RESORDER invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dchrcontribsrccd < 1)
  SET failed = select_error
  SET table_name = "dCHRContribSrcCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "CHR ContributorSrcCd :: Select Error :: CODE_VALUE for CDF_MEANING CERNERCHR invalid from CODE_SET 73"
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
  "Default ContributorSrcCd :: Select Error :: CODE_VALUE for CDF_MEANING DEFAULT invalid from CODE_SET 73"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SET lchrcontribsrcidx = (contribrec->qual_cnt+ 1)
 SET contribrec->qual_cnt = lchrcontribsrcidx
 SET stat = alterlist(contribrec->qual,contribrec->qual_cnt)
 SET contribrec->qual[lchrcontribsrcidx].contributor_source_cd = dchrcontribsrccd
 CALL echo(build("lCHRContribSrcIdx: ",lchrcontribsrcidx))
 SELECT INTO "nl:"
  FROM ags_task t,
   ags_job j
  PLAN (t
   WHERE t.ags_task_id=dtaskid)
   JOIN (j
   WHERE j.ags_job_id=t.ags_job_id)
  HEAD t.ags_task_id
   dbatchendid = t.batch_end_id, dbatchstartid = t.batch_start_id
   IF (t.batch_size > 0)
    lbatchsize = t.batch_size
   ELSE
    lbatchsize = ldefaultbatchsize
   ENDIF
   lmodeflag = t.mode_flag, lkillind = t.kill_ind, lloglevel = t.timers_flag
  HEAD j.ags_job_id
   dagsjobid = j.ags_job_id, ljobcontribsysidx = (contribrec->qual_cnt+ 1), contribrec->qual_cnt =
   ljobcontribsysidx,
   stat = alterlist(contribrec->qual,contribrec->qual_cnt), contribrec->qual[ljobcontribsysidx].
   sending_facility = trim(j.sending_system)
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
 CALL echo(build("lJobContribSysIdx: ",ljobcontribsysidx))
 SET stat = memalloc(arynotes,lbatchsize,"c255")
 IF (lmodeflag=3)
  IF (dbatchendid <= 0)
   SELECT INTO "nl:"
    max_id = max(r.ags_result_data_id), dknt = count(r.ags_result_data_id)
    FROM ags_result_data r
    WHERE r.ags_result_data_id >= dbatchstartid
     AND ((r.event_id+ 0)=0)
     AND trim(r.status) IN ("IN ERROR", "HOLD", "BACK OUT")
    HEAD REPORT
     junk = 0
    FOOT REPORT
     dbatchendid = max_id, data_knt = dknt
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "MODE CHK"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("MODE CHK :: Select Error :: ",trim(serrmsg))
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
   IF (data_knt <= lbatchsize)
    SET dendid = dbatchendid
   ELSE
    SET dendid = ((dbatchstartid+ lbatchsize) - 1)
   ENDIF
   CALL echo(build("New BATCH_END_ID: ",dbatchendid))
   UPDATE  FROM ags_task t
    SET t.batch_end_id = dbatchendid
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
  ENDIF
 ENDIF
 IF (dtaskid > 0)
  UPDATE  FROM ags_task t
   SET t.status = "PROCESSING", t.status_dt_tm = cnvtdatetime(dtcurrent), t.batch_start_dt_tm = t
    .status_dt_tm,
    t.batch_end_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00.00")
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
   SET lidx3 = 0
   SET dtitstart = cnvtdatetime(curdate,curtime2)
   SET holdrec->qual_cnt = 0
   SET stat = initrec(holdrec)
   SET exceptionrec->remove = false
   SET exceptionrec->qual_cnt = 0
   SET stat = initrec(exceptionrec)
   SELECT
    IF (lmodeflag=0)
     PLAN (r
      WHERE r.ags_result_data_id >= dstartid
       AND r.ags_result_data_id <= dendid
       AND ((r.event_id+ 0)=0)
       AND trim(r.status)="WAITING")
    ELSEIF (lmodeflag=1)
     PLAN (r
      WHERE r.ags_result_data_id >= dstartid
       AND r.ags_result_data_id <= dendid)
    ELSEIF (lmodeflag=2)
     PLAN (r
      WHERE r.ags_result_data_id >= dstartid
       AND r.ags_result_data_id <= dendid
       AND ((r.event_id+ 0)=0))
    ELSEIF (lmodeflag=3)
     PLAN (r
      WHERE r.ags_result_data_id >= dstartid
       AND r.ags_result_data_id <= dendid
       AND ((r.event_id+ 0)=0)
       AND trim(r.status) IN ("IN ERROR", "HOLD", "BACK OUT"))
    ELSE
    ENDIF
    INTO "nl:"
    FROM ags_result_data r
    ORDER BY r.ags_result_data_id
    HEAD REPORT
     lidx = 0
    HEAD r.ags_result_data_id
     lnum = 0, lpos = 0, sresultidentifier = trim(r.result_identifier,3)
     IF (size(sresultidentifier) > 0)
      lcontribsysidx = 0, lextidx = 0, lssnidx = 0,
      lperfprsnlidx = 0, lordprsnlidx = 0, lchreventidx = 0,
      leventidx = 0, lchruofmidx = 0, luofmidx = 0,
      lchrnormidx = 0, lnormidx = 0, lchrservidx = 0,
      lservidx = 0, sstatusmsg = " ", berror = false,
      lidx = (lidx+ 1)
      IF ((lidx > holdrec->qual_cnt))
       holdrec->qual_cnt = (holdrec->qual_cnt+ lchunksize), stat = alterlist(holdrec->qual,holdrec->
        qual_cnt)
      ENDIF
      lpos = locateval(lnum,1,holdrec->qual_cnt,sresultidentifier,holdrec->qual[lnum].
       result_identifier)
      IF (lpos > 0)
       holdrec->qual[lidx].duplicate = true
      ENDIF
      holdrec->qual[lidx].ags_result_data_id = r.ags_result_data_id, holdrec->qual[lidx].event_id = r
      .event_id, holdrec->qual[lidx].clinical_event_id = r.clinical_event_id,
      holdrec->qual[lidx].result_identifier = sresultidentifier, holdrec->qual[lidx].event_title_text
       = trim(r.event_title_text,3), seventdate = trim(r.event_date,3)
      IF (size(seventdate) > 13)
       seventdatetime = concat(format(cnvtdate2(seventdate,"YYYYMMDD"),"DD-MMM-YYYY;;D")," ",
        substring(9,2,seventdate),":",substring(11,2,seventdate),
        ":",substring(13,2,seventdate)), holdrec->qual[lidx].event_dt_tm = cnvtdatetime(
        seventdatetime)
      ELSE
       berror = true, sstatusmsg = concat(sstatusmsg,"[d]m")
      ENDIF
      holdrec->qual[lidx].event_title_text = trim(r.event_title_text,3), sresultval = trim(r
       .result_val,3)
      IF (size(sresultval) > 0)
       holdrec->qual[lidx].result_val = sresultval
       IF (isnumeric(sresultval))
        holdrec->qual[lidx].is_numeric = true
       ENDIF
      ELSE
       sstatusmsg = concat(sstatusmsg,"[v]m")
      ENDIF
      holdrec->qual[lidx].event_note = trim(r.result_remark_desc,3), srefrange = trim(r.ref_range,3)
      IF (size(srefrange) > 0)
       IF (findstring("<",srefrange) > 0)
        holdrec->qual[lidx].normal_high = srefrange
       ELSEIF (findstring(">",srefrange) > 0)
        holdrec->qual[lidx].normal_low = srefrange
       ELSE
        lfirstdash = 0, lseconddash = 0, lfirstdash = findstring("-",srefrange)
        IF (lfirstdash)
         lseconddash = findstring("-",srefrange,(lfirstdash+ 1))
        ENDIF
        IF (lseconddash)
         holdrec->qual[lidx].normal_low = trim(substring(1,(lseconddash - 1),srefrange),3), holdrec->
         qual[lidx].normal_high = trim(substring((lseconddash+ 1),(size(srefrange,1) - lseconddash),
           srefrange),3)
        ELSEIF (lfirstdash)
         holdrec->qual[lidx].normal_low = trim(substring(1,(lfirstdash - 1),srefrange),3), holdrec->
         qual[lidx].normal_high = trim(substring((lfirstdash+ 1),(size(srefrange,1) - lfirstdash),
           srefrange),3)
        ENDIF
       ENDIF
      ELSE
       srefrange = trim(r.normal_high,3)
       IF (size(srefrange) > 0)
        holdrec->qual[lidx].normal_high = srefrange
       ENDIF
       srefrange = trim(r.normal_low,3)
       IF (size(srefrange) > 0)
        holdrec->qual[lidx].normal_low = srefrange
       ENDIF
      ENDIF
      ssendingfacility = trim(r.sending_facility,3)
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
      holdrec->qual[lidx].contrib_sys_idx = lcontribsysidx, sextalias = trim(r.ext_alias,3)
      IF (size(sextalias) > 0)
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lcontribsysidx].qual1_cnt,
        sextalias,contribrec->qual[lcontribsysidx].qual1[lnum].ext_alias)
       IF (lpos <= 0)
        lextidx = (contribrec->qual[lcontribsysidx].qual1_cnt+ 1), contribrec->qual[lcontribsysidx].
        qual1_cnt = lextidx, stat = alterlist(contribrec->qual[lcontribsysidx].qual1,lextidx),
        contribrec->qual[lcontribsysidx].qual1[lextidx].ext_alias = sextalias, contribrec->qual[
        lcontribsysidx].qual1[lextidx].birth_dt_tm = cnvtdate2(trim(r.birth_date,3),"YYYYMMDD")
       ELSE
        lextidx = lpos
       ENDIF
       holdrec->qual[lidx].ext_alias_idx = lextidx
      ELSE
       sstatusmsg = concat(sstatusmsg,"[x]am")
      ENDIF
      sssnalias = cnvtstring(cnvtint(trim(r.ssn_alias,3)))
      IF (size(sssnalias) > 0)
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lcontribsysidx].qual2_cnt,
        sssnalias,contribrec->qual[lcontribsysidx].qual2[lnum].ssn_alias)
       IF (lpos <= 0)
        lssnidx = (contribrec->qual[lcontribsysidx].qual2_cnt+ 1), contribrec->qual[lcontribsysidx].
        qual2_cnt = lssnidx, stat = alterlist(contribrec->qual[lcontribsysidx].qual2,lssnidx),
        contribrec->qual[lcontribsysidx].qual2[lssnidx].ssn_alias = sssnalias, contribrec->qual[
        lcontribsysidx].qual2[lssnidx].name_first = trim(r.name_first,3), contribrec->qual[
        lcontribsysidx].qual2[lssnidx].name_last = trim(r.name_last,3),
        contribrec->qual[lcontribsysidx].qual2[lssnidx].birth_dt_tm = cnvtdate2(trim(r.birth_date,3),
         "YYYYMMDD")
        IF (trim(r.gender,3)="M")
         contribrec->qual[lcontribsysidx].qual2[lssnidx].sex_cd = dmalesexcd
        ELSEIF (trim(r.gender,3)="F")
         contribrec->qual[lcontribsysidx].qual2[lssnidx].sex_cd = dfemalesexcd
        ENDIF
       ELSE
        lssnidx = lpos
       ENDIF
       holdrec->qual[lidx].ssn_alias_idx = lssnidx
      ELSE
       IF (lextidx=0)
        berror = true
       ENDIF
       sstatusmsg = concat(sstatusmsg,"[s]am")
      ENDIF
      sperfextalias = trim(r.performing_ext_alias,3)
      IF (size(sperfextalias) > 0)
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lcontribsysidx].qual0_cnt,
        sperfextalias,contribrec->qual[lcontribsysidx].qual0[lnum].performing_ext_alias)
       IF (lpos <= 0)
        lperfprsnlidx = (contribrec->qual[lcontribsysidx].qual0_cnt+ 1), contribrec->qual[
        lcontribsysidx].qual0_cnt = lperfprsnlidx, stat = alterlist(contribrec->qual[lcontribsysidx].
         qual0,lperfprsnlidx),
        contribrec->qual[lcontribsysidx].qual0[lperfprsnlidx].performing_ext_alias = sperfextalias
       ELSE
        lperfprsnlidx = lpos
       ENDIF
       holdrec->qual[lidx].perf_ext_alias_idx = lperfprsnlidx
      ELSE
       sstatusmsg = concat(sstatusmsg,"[p]am")
      ENDIF
      sordextalias = trim(r.ordering_ext_alias,3)
      IF (size(sordextalias) > 0)
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lcontribsysidx].qual3_cnt,
        sordextalias,contribrec->qual[lcontribsysidx].qual3[lnum].ordering_ext_alias)
       IF (lpos <= 0)
        lordprsnlidx = (contribrec->qual[lcontribsysidx].qual3_cnt+ 1), contribrec->qual[
        lcontribsysidx].qual3_cnt = lordprsnlidx, stat = alterlist(contribrec->qual[lcontribsysidx].
         qual3,lordprsnlidx),
        contribrec->qual[lcontribsysidx].qual3[lordprsnlidx].ordering_ext_alias = sordextalias
       ELSE
        lordprsnlidx = lpos
       ENDIF
       holdrec->qual[lidx].ord_ext_alias_idx = lordprsnlidx
      ELSE
       sstatusmsg = concat(sstatusmsg,"[o]am")
      ENDIF
      seventcode = trim(r.event_code,3)
      IF (size(seventcode) > 0)
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lchrcontribsrcidx].qual4_cnt,
        seventcode,contribrec->qual[lchrcontribsrcidx].qual4[lnum].event_code)
       IF (lpos <= 0)
        lchreventidx = (contribrec->qual[lchrcontribsrcidx].qual4_cnt+ 1), contribrec->qual[
        lchrcontribsrcidx].qual4_cnt = lchreventidx, stat = alterlist(contribrec->qual[
         lchrcontribsrcidx].qual4,lchreventidx),
        contribrec->qual[lchrcontribsrcidx].qual4[lchreventidx].event_code = seventcode
       ELSE
        lchreventidx = lpos
       ENDIF
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lcontribsysidx].qual4_cnt,
        seventcode,contribrec->qual[lcontribsysidx].qual4[lnum].event_code)
       IF (lpos <= 0)
        leventidx = (contribrec->qual[lcontribsysidx].qual4_cnt+ 1), contribrec->qual[lcontribsysidx]
        .qual4_cnt = leventidx, stat = alterlist(contribrec->qual[lcontribsysidx].qual4,leventidx),
        contribrec->qual[lcontribsysidx].qual4[leventidx].event_code = seventcode
       ELSE
        leventidx = lpos
       ENDIF
       holdrec->qual[lidx].chr_event_code_idx = lchreventidx, holdrec->qual[lidx].event_code_idx =
       leventidx
      ELSE
       berror = true, sstatusmsg = concat(sstatusmsg,"[e]am")
      ENDIF
      sunitofmeas = trim(r.unit_of_meas,3)
      IF (size(sunitofmeas) > 0)
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lchrcontribsrcidx].qual5_cnt,
        sunitofmeas,contribrec->qual[lchrcontribsrcidx].qual5[lnum].unit_of_measure)
       IF (lpos <= 0)
        lchruofmidx = (contribrec->qual[lchrcontribsrcidx].qual5_cnt+ 1), contribrec->qual[
        lchrcontribsrcidx].qual5_cnt = lchruofmidx, stat = alterlist(contribrec->qual[
         lchrcontribsrcidx].qual5,lchruofmidx),
        contribrec->qual[lchrcontribsrcidx].qual5[lchruofmidx].unit_of_measure = sunitofmeas
       ELSE
        lchruofmidx = lpos
       ENDIF
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lcontribsysidx].qual5_cnt,
        sunitofmeas,contribrec->qual[lcontribsysidx].qual5[lnum].unit_of_measure)
       IF (lpos <= 0)
        luofmidx = (contribrec->qual[lcontribsysidx].qual5_cnt+ 1), contribrec->qual[lcontribsysidx].
        qual5_cnt = luofmidx, stat = alterlist(contribrec->qual[lcontribsysidx].qual5,luofmidx),
        contribrec->qual[lcontribsysidx].qual5[luofmidx].unit_of_measure = sunitofmeas
       ELSE
        luofmidx = lpos
       ENDIF
       holdrec->qual[lidx].chr_unit_of_meas_idx = lchruofmidx, holdrec->qual[lidx].unit_of_meas_idx
        = luofmidx
      ELSE
       IF (holdrec->qual[lidx].is_numeric)
        sstatusmsg = concat(sstatusmsg,"[u]am")
       ENDIF
      ENDIF
      snormalcy = trim(r.normalcy,3)
      IF (size(snormalcy) > 0)
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lchrcontribsrcidx].qual6_cnt,
        snormalcy,contribrec->qual[lchrcontribsrcidx].qual6[lnum].normalcy)
       IF (lpos <= 0)
        lchrnormidx = (contribrec->qual[lchrcontribsrcidx].qual6_cnt+ 1), contribrec->qual[
        lchrcontribsrcidx].qual6_cnt = lchrnormidx, stat = alterlist(contribrec->qual[
         lchrcontribsrcidx].qual6,lchrnormidx),
        contribrec->qual[lchrcontribsrcidx].qual6[lchrnormidx].normalcy = snormalcy
       ELSE
        lchrnormidx = lpos
       ENDIF
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lcontribsysidx].qual6_cnt,
        snormalcy,contribrec->qual[lcontribsysidx].qual6[lnum].normalcy)
       IF (lpos <= 0)
        lnormidx = (contribrec->qual[lcontribsysidx].qual6_cnt+ 1), contribrec->qual[lcontribsysidx].
        qual6_cnt = lnormidx, stat = alterlist(contribrec->qual[lcontribsysidx].qual6,lnormidx),
        contribrec->qual[lcontribsysidx].qual6[lnormidx].normalcy = snormalcy
       ELSE
        lnormidx = lpos
       ENDIF
       holdrec->qual[lidx].chr_normalcy_idx = lchrnormidx, holdrec->qual[lidx].normalcy_idx =
       lnormidx
      ENDIF
      sserviceresource = trim(r.performing_entity_alias,3),
      CALL echo(sserviceresource)
      IF (size(sserviceresource) > 0)
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lchrcontribsrcidx].qual7_cnt,
        sserviceresource,contribrec->qual[lchrcontribsrcidx].qual7[lnum].service_resource)
       IF (lpos <= 0)
        lchrservidx = (contribrec->qual[lchrcontribsrcidx].qual7_cnt+ 1), contribrec->qual[
        lchrcontribsrcidx].qual7_cnt = lchrservidx, stat = alterlist(contribrec->qual[
         lchrcontribsrcidx].qual7,lchrservidx),
        contribrec->qual[lchrcontribsrcidx].qual7[lchrservidx].service_resource = sserviceresource
       ELSE
        lchrservidx = lpos
       ENDIF
       lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual[lcontribsysidx].qual7_cnt,
        sserviceresource,contribrec->qual[lcontribsysidx].qual7[lnum].service_resource)
       IF (lpos <= 0)
        lservidx = (contribrec->qual[lcontribsysidx].qual7_cnt+ 1), contribrec->qual[lcontribsysidx].
        qual7_cnt = lservidx, stat = alterlist(contribrec->qual[lcontribsysidx].qual7,lservidx),
        contribrec->qual[lcontribsysidx].qual7[lservidx].service_resource = sserviceresource
       ELSE
        lservidx = lpos
       ENDIF
       holdrec->qual[lidx].chr_service_resource_idx = lchrservidx, holdrec->qual[lidx].
       service_resource_idx = lservidx
      ELSE
       sstatusmsg = concat(sstatusmsg,"[pl]m")
      ENDIF
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[i]m")
     ENDIF
     IF (berror)
      holdrec->qual[lidx].error = true, holdrec->qual[lidx].status = "IN ERROR", holdrec->qual[lidx].
      stat_msg = trim(sstatusmsg,3)
     ENDIF
    FOOT REPORT
     holdrec->qual_cnt = lidx, stat = alterlist(holdrec->qual,lidx)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "AGS_RESULT_DATA"
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
      IF (eat.esi_alias_field_cd=dresordprovideraliasfieldcd)
       contribrec->qual[d.seq].providernum_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq]
       .ext_prsnl_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (eat.esi_alias_field_cd=dperfaliasfieldcd)
       contribrec->qual[d.seq].performing_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       performing_alias_type_cd = eat.alias_entity_alias_type_cd
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
    FOR (lidx = 1 TO contribrec->qual_cnt)
      CALL echo("***")
      CALL echo("***   EXT_ALIAS Lookup")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(contribrec->qual[lidx].qual1_cnt)),
        person_alias pa
       PLAN (d
        WHERE (contribrec->qual[lidx].qual1[d.seq].person_id <= 0.0)
         AND size(trim(contribrec->qual[lidx].qual1[d.seq].ext_alias)) > 0
         AND (contribrec->qual[lidx].ext_alias_pool_cd > 0.0)
         AND (contribrec->qual[lidx].ext_alias_type_cd > 0.0))
        JOIN (pa
        WHERE pa.alias=trim(contribrec->qual[lidx].qual1[d.seq].ext_alias)
         AND (pa.alias_pool_cd=contribrec->qual[lidx].ext_alias_pool_cd)
         AND (pa.person_alias_type_cd=contribrec->qual[lidx].ext_alias_type_cd)
         AND pa.active_ind != 0)
       DETAIL
        contribrec->qual[lidx].qual1[d.seq].person_id = pa.person_id
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
       SET log->qual[log->qual_knt].smsg = concat("PERSON_ALIAS :: Select Error :: EXT_ALIAS :: ",
        trim(serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
      CALL echo("***")
      CALL echo("***   SSN Lookup")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(contribrec->qual[lidx].qual2_cnt)),
        person_alias pa,
        person p
       PLAN (d
        WHERE (contribrec->qual[lidx].qual2[d.seq].person_id <= 0.0)
         AND size(trim(contribrec->qual[lidx].qual2[d.seq].ssn_alias)) > 0
         AND (contribrec->qual[lidx].ssn_alias_pool_cd > 0.0)
         AND (contribrec->qual[lidx].ssn_alias_type_cd > 0.0))
        JOIN (pa
        WHERE pa.alias=trim(contribrec->qual[lidx].qual2[d.seq].ssn_alias)
         AND (pa.alias_pool_cd=contribrec->qual[lidx].ssn_alias_pool_cd)
         AND (pa.person_alias_type_cd=contribrec->qual[lidx].ssn_alias_type_cd)
         AND pa.active_ind != 0)
        JOIN (p
        WHERE p.person_id=pa.person_id
         AND p.abs_birth_dt_tm=datetimezone(contribrec->qual[lidx].qual2[d.seq].birth_dt_tm,
         contribrec->qual[lidx].time_zone_idx,1)
         AND p.name_first_key=cnvtupper(cnvtalphanum(contribrec->qual[lidx].qual2[d.seq].name_first))
         AND p.name_last_key=cnvtupper(cnvtalphanum(contribrec->qual[lidx].qual2[d.seq].name_last))
         AND (p.sex_cd=contribrec->qual[lidx].qual2[d.seq].sex_cd)
         AND p.active_ind != 0)
       DETAIL
        contribrec->qual[lidx].qual2[d.seq].person_id = pa.person_id
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
       SET log->qual[log->qual_knt].smsg = concat("PERSON_ALIAS :: Select Error :: SSN_ALIAS :: ",
        trim(serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
      CALL echo("***")
      CALL echo("***   PERFORMING_EXT_ALIAS Lookup")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(contribrec->qual[lidx].qual0_cnt)),
        prsnl_alias pa
       PLAN (d
        WHERE (contribrec->qual[lidx].qual0[d.seq].performing_person_id <= 0.0)
         AND size(trim(contribrec->qual[lidx].qual0[d.seq].performing_ext_alias)) > 0
         AND (contribrec->qual[lidx].performing_alias_pool_cd > 0.0)
         AND (contribrec->qual[lidx].performing_alias_type_cd > 0.0))
        JOIN (pa
        WHERE pa.alias=trim(contribrec->qual[lidx].qual0[d.seq].performing_ext_alias)
         AND (pa.alias_pool_cd=contribrec->qual[lidx].performing_alias_pool_cd)
         AND (pa.prsnl_alias_type_cd=contribrec->qual[lidx].performing_alias_type_cd)
         AND pa.active_ind != 0)
       DETAIL
        contribrec->qual[lidx].qual0[d.seq].performing_person_id = pa.person_id
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "CONTRIBUTOR_SYSTEM"
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
      CALL echo("***   ORDERING_EXT_ALIAS Lookup")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(contribrec->qual[lidx].qual3_cnt)),
        prsnl_alias pa
       PLAN (d
        WHERE (contribrec->qual[lidx].qual3[d.seq].ordering_person_id <= 0.0)
         AND size(trim(contribrec->qual[lidx].qual3[d.seq].ordering_ext_alias)) > 0
         AND (contribrec->qual[lidx].providernum_alias_pool_cd > 0.0)
         AND (contribrec->qual[lidx].ext_prsnl_alias_type_cd > 0.0))
        JOIN (pa
        WHERE pa.alias=trim(contribrec->qual[lidx].qual3[d.seq].ordering_ext_alias)
         AND (pa.alias_pool_cd=contribrec->qual[lidx].providernum_alias_pool_cd)
         AND (pa.prsnl_alias_type_cd=contribrec->qual[lidx].ext_prsnl_alias_type_cd)
         AND pa.active_ind != 0)
       DETAIL
        contribrec->qual[lidx].qual3[d.seq].ordering_person_id = pa.person_id
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "PRSNL_ALIAS"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: Select Error :: ORDERING_EXT_ALIAS :: ",
        trim(serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
      CALL echo("***")
      CALL echo("***   EVENT_CODE Lookup")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(contribrec->qual[lidx].qual4_cnt)),
        code_value_alias cva
       PLAN (d
        WHERE (contribrec->qual[lidx].qual4[d.seq].event_cd <= 0.0)
         AND size(trim(contribrec->qual[lidx].qual4[d.seq].event_code)) > 0
         AND (contribrec->qual[lidx].contributor_source_cd > 0.0))
        JOIN (cva
        WHERE cva.alias=trim(contribrec->qual[lidx].qual4[d.seq].event_code)
         AND cva.code_set=72
         AND (cva.contributor_source_cd=contribrec->qual[lidx].contributor_source_cd))
       DETAIL
        contribrec->qual[lidx].qual4[d.seq].event_cd = cva.code_value
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "CODE_VALUE_ALIAS EVENT_CD"
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
      CALL echo("***   UNIT_OF_MEASURE Lookup")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(contribrec->qual[lidx].qual5_cnt)),
        code_value_alias cva
       PLAN (d
        WHERE (contribrec->qual[lidx].qual5[d.seq].unit_of_measure_cd <= 0.0)
         AND size(trim(contribrec->qual[lidx].qual5[d.seq].unit_of_measure)) > 0
         AND (contribrec->qual[lidx].contributor_source_cd > 0.0))
        JOIN (cva
        WHERE cva.alias=trim(contribrec->qual[lidx].qual5[d.seq].unit_of_measure)
         AND cva.code_set=54
         AND (cva.contributor_source_cd=contribrec->qual[lidx].contributor_source_cd))
       DETAIL
        contribrec->qual[lidx].qual5[d.seq].unit_of_measure_cd = cva.code_value
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "CODE_VALUE_ALIAS UNIT_OF_MEASURE_CD"
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
      CALL echo("***   NORMALCY Lookup")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(contribrec->qual[lidx].qual6_cnt)),
        code_value_alias cva
       PLAN (d
        WHERE (contribrec->qual[lidx].qual6[d.seq].normalcy_cd <= 0.0)
         AND size(trim(contribrec->qual[lidx].qual6[d.seq].normalcy)) > 0
         AND (contribrec->qual[lidx].contributor_source_cd > 0.0))
        JOIN (cva
        WHERE cva.alias=trim(contribrec->qual[lidx].qual6[d.seq].normalcy)
         AND cva.code_set=52
         AND (cva.contributor_source_cd=contribrec->qual[lidx].contributor_source_cd))
       DETAIL
        contribrec->qual[lidx].qual6[d.seq].normalcy_cd = cva.code_value
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "CODE_VALUE_ALIAS NORMALCY"
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
      CALL echo("***   SERVICE_RESOURCE Lookup")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(contribrec->qual[lidx].qual7_cnt)),
        code_value_alias cva
       PLAN (d
        WHERE (contribrec->qual[lidx].qual7[d.seq].service_resource_cd <= 0.0)
         AND size(trim(contribrec->qual[lidx].qual7[d.seq].service_resource)) > 0
         AND (contribrec->qual[lidx].contributor_source_cd > 0.0))
        JOIN (cva
        WHERE cva.alias=trim(contribrec->qual[lidx].qual7[d.seq].service_resource)
         AND cva.code_set=221
         AND (cva.contributor_source_cd=contribrec->qual[lidx].contributor_source_cd))
       DETAIL
        contribrec->qual[lidx].qual7[d.seq].service_resource_cd = cva.code_value
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "CODE_VALUE_ALIAS SERVICE_RESOURCE"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
    ENDFOR
    IF (lloglevel > 1)
     CALL echo("/---------------------- ContribRec Begin ----------------------------------/")
     CALL echorecord(contribrec)
     CALL echo("/----------------------- ContribRec End -----------------------------------/")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(holdrec->qual_cnt))
     PLAN (d
      WHERE d.seq > 0
       AND (holdrec->qual[d.seq].error <= 0))
     DETAIL
      berror = false, bperson = false, sstatusmsg = " ",
      lcontribsysidx = holdrec->qual[d.seq].contrib_sys_idx, lextidx = holdrec->qual[d.seq].
      ext_alias_idx, lssnidx = holdrec->qual[d.seq].ssn_alias_idx,
      lperfprsnlidx = holdrec->qual[d.seq].perf_ext_alias_idx, lordprsnlidx = holdrec->qual[d.seq].
      ord_ext_alias_idx, lchreventidx = holdrec->qual[d.seq].chr_event_code_idx,
      leventidx = holdrec->qual[d.seq].event_code_idx, lchruofmidx = holdrec->qual[d.seq].
      chr_unit_of_meas_idx, luofmidx = holdrec->qual[d.seq].unit_of_meas_idx,
      lchrnormidx = holdrec->qual[d.seq].chr_normalcy_idx, lnormidx = holdrec->qual[d.seq].
      normalcy_idx, lchrservidx = holdrec->qual[d.seq].chr_service_resource_idx,
      lservidx = holdrec->qual[d.seq].service_resource_idx
      IF (lcontribsysidx > 0)
       IF ((contribrec->qual[lcontribsysidx].contributor_system_cd > 0.0))
        holdrec->qual[d.seq].contributor_system_cd = contribrec->qual[lcontribsysidx].
        contributor_system_cd
        IF (size(holdrec->qual[d.seq].event_note) > 0)
         holdrec->qual[d.seq].note_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id
        ENDIF
       ELSE
        berror = true, sstatusmsg = concat(sstatusmsg,"[c]lf")
       ENDIF
       IF (lextidx > 0)
        IF ((contribrec->qual[lcontribsysidx].qual1[lextidx].person_id > 0.0))
         bperson = true, holdrec->qual[d.seq].person_id = contribrec->qual[lcontribsysidx].qual1[
         lextidx].person_id
        ELSE
         sstatusmsg = concat(sstatusmsg,"[x]lf")
        ENDIF
       ENDIF
       IF (lssnidx > 0
        AND  NOT (bperson))
        IF ((contribrec->qual[lcontribsysidx].qual2[lssnidx].person_id > 0.0))
         bperson = true, holdrec->qual[d.seq].person_id = contribrec->qual[lcontribsysidx].qual2[
         lssnidx].person_id
        ELSE
         sstatusmsg = concat(sstatusmsg,"[s]lf")
        ENDIF
       ENDIF
       IF ( NOT (bperson))
        berror = true
       ENDIF
       IF (lperfprsnlidx > 0)
        IF ((contribrec->qual[lcontribsysidx].qual0[lperfprsnlidx].performing_person_id > 0.0))
         holdrec->qual[d.seq].performed_prsnl_id = contribrec->qual[lcontribsysidx].qual0[
         lperfprsnlidx].performing_person_id, holdrec->qual[d.seq].verified_prsnl_id = contribrec->
         qual[lcontribsysidx].qual0[lperfprsnlidx].performing_person_id
        ELSE
         berror = true, sstatusmsg = concat(sstatusmsg,"[p]lf")
        ENDIF
       ELSE
        IF ((contribrec->qual[lcontribsysidx].prsnl_person_id > 0.0))
         holdrec->qual[d.seq].performed_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
         holdrec->qual[d.seq].verified_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id
        ELSE
         berror = true, sstatusmsg = concat(sstatusmsg,"[p2]lf")
        ENDIF
       ENDIF
       IF (lordprsnlidx > 0)
        IF ((contribrec->qual[lcontribsysidx].qual3[lordprsnlidx].ordering_person_id > 0.0))
         holdrec->qual[d.seq].ordering_prsnl_id = contribrec->qual[lcontribsysidx].qual3[lordprsnlidx
         ].ordering_person_id
        ELSE
         sstatusmsg = concat(sstatusmsg,"[o]lf")
        ENDIF
       ENDIF
       lidx = 0, lidx2 = 0
       IF (lchreventidx > 0)
        IF ((contribrec->qual[lchrcontribsrcidx].qual4[lchreventidx].event_cd > 0.0))
         lidx = lchrcontribsrcidx, lidx2 = lchreventidx
        ENDIF
       ENDIF
       IF (lidx <= 0)
        IF (leventidx > 0)
         IF ((contribrec->qual[lcontribsysidx].qual4[leventidx].event_cd > 0.0))
          lidx = lcontribsysidx, lidx2 = leventidx
         ENDIF
        ENDIF
       ENDIF
       IF (lidx > 0)
        holdrec->qual[d.seq].event_cd = contribrec->qual[lidx].qual4[lidx2].event_cd
       ELSE
        berror = true, sstatusmsg = concat(sstatusmsg,"[e]lf")
       ENDIF
       lidx = 0, lidx2 = 0
       IF (lchruofmidx > 0)
        IF ((contribrec->qual[lchrcontribsrcidx].qual5[lchruofmidx].unit_of_measure_cd > 0.0))
         lidx = lchrcontribsrcidx, lidx2 = lchruofmidx
        ENDIF
       ENDIF
       IF (lidx <= 0)
        IF (luofmidx > 0)
         IF ((contribrec->qual[lcontribsysidx].qual5[luofmidx].unit_of_measure_cd > 0.0))
          lidx = lcontribsysidx, lidx2 = luofmidx
         ENDIF
        ENDIF
       ENDIF
       IF (lidx > 0)
        holdrec->qual[d.seq].unit_of_measure_cd = contribrec->qual[lidx].qual5[lidx2].
        unit_of_measure_cd
       ELSEIF (((lchruofmidx > 0) OR (luofmidx > 0)) )
        berror = true, sstatusmsg = concat(sstatusmsg,"[u]lf")
       ENDIF
       lidx = 0, lidx2 = 0
       IF (lchrnormidx > 0)
        IF ((contribrec->qual[lchrcontribsrcidx].qual6[lchrnormidx].normalcy_cd > 0.0))
         lidx = lchrcontribsrcidx, lidx2 = lchrnormidx
        ENDIF
       ENDIF
       IF (lidx <= 0)
        IF (lnormidx > 0)
         IF ((contribrec->qual[lcontribsysidx].qual6[lnormidx].normalcy_cd > 0.0))
          lidx = lcontribsysidx, lidx2 = lnormidx
         ENDIF
        ENDIF
       ENDIF
       IF (lidx > 0)
        holdrec->qual[d.seq].normalcy_cd = contribrec->qual[lidx].qual6[lidx2].normalcy_cd
       ELSEIF (((lchrnormidx > 0) OR (lnormidx > 0)) )
        berror = true, sstatusmsg = concat(sstatusmsg,"[n]lf")
       ENDIF
       lidx = 0, lidx2 = 0
       IF (lchrservidx > 0)
        IF ((contribrec->qual[lchrcontribsrcidx].qual7[lchrservidx].service_resource_cd > 0.0))
         lidx = lchrcontribsrcidx, lidx2 = lchrservidx
        ENDIF
       ENDIF
       IF (lidx <= 0)
        IF (lservidx > 0)
         IF ((contribrec->qual[lcontribsysidx].qual7[lservidx].service_resource_cd > 0.0))
          lidx = lcontribsysidx, lidx2 = lservidx
         ENDIF
        ENDIF
       ENDIF
       IF (lidx > 0)
        holdrec->qual[d.seq].service_resource_cd = contribrec->qual[lidx].qual7[lidx2].
        service_resource_cd
       ELSEIF (((lchrservidx > 0) OR (lservidx > 0)) )
        berror = true, sstatusmsg = concat(sstatusmsg,"[pl]lf")
       ENDIF
      ENDIF
      IF (berror)
       holdrec->qual[d.seq].error = true, holdrec->qual[d.seq].status = "IN ERROR", holdrec->qual[d
       .seq].stat_msg = trim(sstatusmsg,3)
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "LOAD CE REQUEST"
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
     CALL echo("/------------------------ HoldRec Begin ------------------------------------/")
     CALL echorecord(holdrec)
     CALL echo("/------------------------- HoldRec End -------------------------------------/")
    ENDIF
    IF ((holdrec->qual_cnt > 0))
     FOR (lidx = 1 TO holdrec->qual_cnt)
       IF ((holdrec->qual[lidx].error > 0))
        UPDATE  FROM ags_result_data r
         SET r.status = holdrec->qual[lidx].status, r.stat_msg = trim(substring(1,40,holdrec->qual[
            lidx].stat_msg)), r.updt_dt_tm = cnvtdatetime(dtcurrent),
          r.updt_cnt = (r.updt_cnt+ 1)
         WHERE (r.ags_result_data_id=holdrec->qual[lidx].ags_result_data_id)
         WITH nocounter
        ;end update
       ELSE
        SET bhold = false
        IF (bcheckfordups)
         IF ((holdrec->qual[lidx].clinical_event_id <= 0))
          SELECT INTO "nl:"
           FROM ags_result_data r
           WHERE (r.result_identifier=holdrec->qual[lidx].result_identifier)
            AND (r.ags_result_data_id < holdrec->qual[lidx].ags_result_data_id)
           DETAIL
            IF (((r.status="IN ERROR") OR (((r.status="HOLD") OR (r.status="BACK OUT")) )) )
             bhold = true
            ELSEIF (r.status="COMPLETE")
             holdrec->qual[lidx].clinical_event_id = r.clinical_event_id, holdrec->qual[lidx].
             event_id = r.event_id
            ENDIF
           WITH nocounter
          ;end select
         ENDIF
        ENDIF
        IF (bhold)
         CALL echo("Hold")
         UPDATE  FROM ags_result_data r
          SET r.status = "HOLD", r.updt_dt_tm = cnvtdatetime(dtcurrent), r.updt_cnt = (r.updt_cnt+ 1)
          WHERE (r.ags_result_data_id=holdrec->qual[lidx].ags_result_data_id)
          WITH nocounter
         ;end update
        ELSE
         IF (holdrec->qual[lidx].clinical_event_id)
          SET lcontribsysidx = holdrec->qual[lidx].contrib_sys_idx
          UPDATE  FROM clinical_event ce
           SET ce.person_id = holdrec->qual[lidx].person_id, ce.event_title_text = holdrec->qual[lidx
            ].event_title_text, ce.contributor_system_cd = holdrec->qual[lidx].contributor_system_cd,
            ce.event_reltn_cd = drooteventreltncd, ce.event_class_cd =
            IF (holdrec->qual[lidx].is_numeric) dnumeventclasscd
            ELSE dtxteventclasscd
            ENDIF
            , ce.event_cd = holdrec->qual[lidx].event_cd,
            ce.event_tag = holdrec->qual[lidx].result_val, ce.event_end_dt_tm = cnvtdatetime(holdrec
             ->qual[lidx].event_dt_tm), ce.event_end_tz = contribrec->qual[lcontribsysidx].
            time_zone_idx,
            ce.result_val = holdrec->qual[lidx].result_val, ce.result_units_cd = holdrec->qual[lidx].
            unit_of_measure_cd, ce.authentic_flag = 1,
            ce.publish_flag = 1, ce.normalcy_cd = holdrec->qual[lidx].normalcy_cd, ce.resource_cd =
            holdrec->qual[lidx].service_resource_cd,
            ce.subtable_bit_map =
            IF (size(trim(holdrec->qual[lidx].event_note)) > 0) 8195
            ELSE 8193
            ENDIF
            , ce.verified_dt_tm = cnvtdatetime(holdrec->qual[lidx].event_dt_tm), ce.verified_tz =
            contribrec->qual[lcontribsysidx].time_zone_idx,
            ce.verified_prsnl_id = holdrec->qual[lidx].verified_prsnl_id, ce.performed_dt_tm =
            cnvtdatetime(holdrec->qual[lidx].event_dt_tm), ce.performed_tz = contribrec->qual[
            lcontribsysidx].time_zone_idx,
            ce.performed_prsnl_id = holdrec->qual[lidx].performed_prsnl_id, ce
            .note_importance_bit_map =
            IF (size(trim(holdrec->qual[lidx].event_note)) > 0) 2
            ELSE 0
            ENDIF
            , ce.event_tag_set_flag = 1,
            ce.normal_low = holdrec->qual[lidx].normal_low, ce.normal_high = holdrec->qual[lidx].
            normal_high, ce.updt_dt_tm = cnvtdatetime(dtcurrent),
            ce.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, ce.updt_task = 424990, ce
            .updt_cnt = (ce.updt_cnt+ 1),
            ce.updt_applctx = 424990
           WHERE (ce.clinical_event_id=holdrec->qual[lidx].clinical_event_id)
           WITH nocounter
          ;end update
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = update_error
           SET table_name = "CLINICAL_EVENT"
           SET ilog_status = 1
           SET log->qual_knt = (log->qual_knt+ 1)
           SET stat = alterlist(log->qual,log->qual_knt)
           SET log->qual[log->qual_knt].smsgtype = "ERROR"
           SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
           SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
           SET serrmsg = log->qual[log->qual_knt].smsg
           GO TO exit_script
          ENDIF
          FOR (lidx2 = 1 TO 3)
            CASE (lidx2)
             OF 1:
              SET dactionprsnlid = holdrec->qual[lidx].performed_prsnl_id
              SET dactiontypecd = dperformactiontypecd
              SET dactionstatuscd = dcompleteactionstatuscd
              SET sactioncomment = "PERFORM/COMPLETE"
             OF 2:
              SET dactionprsnlid = holdrec->qual[lidx].verified_prsnl_id
              SET dactiontypecd = dverifyactiontypecd
              SET dactionstatuscd = dcompleteactionstatuscd
              SET sactioncomment = "VERIFY/COMPLETE"
             OF 3:
              SET dactionprsnlid = holdrec->qual[lidx].ordering_prsnl_id
              SET dactiontypecd = dorderactiontypecd
              SET dactionstatuscd = dcompleteactionstatuscd
              SET sactioncomment = "ORDER/COMPLETE"
            ENDCASE
            UPDATE  FROM ce_event_prsnl c
             SET c.person_id = holdrec->qual[lidx].person_id, c.action_dt_tm = cnvtdatetime(holdrec->
               qual[lidx].event_dt_tm), c.action_prsnl_id = dactionprsnlid,
              c.action_tz = contribrec->qual[lcontribsysidx].time_zone_idx, c.updt_dt_tm =
              cnvtdatetime(dtcurrent), c.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
              c.updt_task = 424990, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = 424990
             WHERE (c.event_id=holdrec->qual[lidx].event_id)
              AND c.action_type_cd=dactiontypecd
             WITH nocounter
            ;end update
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = update_error
             SET table_name = "CE_EVENT_PRSNL"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
          ENDFOR
          UPDATE  FROM ce_string_result c
           SET c.string_result_format_cd =
            IF (holdrec->qual[lidx].is_numeric) dnumresultformatcd
            ELSE dalpharesultformatcd
            ENDIF
            , c.string_result_text = holdrec->qual[lidx].result_val, c.unit_of_measure_cd = holdrec->
            qual[lidx].unit_of_measure_cd,
            c.normal_low = holdrec->qual[lidx].normal_low, c.normal_high = holdrec->qual[lidx].
            normal_high, c.updt_dt_tm = cnvtdatetime(dtcurrent),
            c.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, c.updt_task = 424990, c
            .updt_cnt = (c.updt_cnt+ 1),
            c.updt_applctx = 424990
           WHERE (c.event_id=holdrec->qual[lidx].event_id)
           WITH nocounter
          ;end update
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = update_error
           SET table_name = "CE_STRING_RESULT"
           SET ilog_status = 1
           SET log->qual_knt = (log->qual_knt+ 1)
           SET stat = alterlist(log->qual,log->qual_knt)
           SET log->qual[log->qual_knt].smsgtype = "ERROR"
           SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
           SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
           SET serrmsg = log->qual[log->qual_knt].smsg
           GO TO exit_script
          ENDIF
          IF (size(trim(holdrec->qual[lidx].event_note)) > 0)
           SET dceeventnoteid = 0.0
           SELECT INTO "nl:"
            FROM ce_event_note c
            WHERE (c.event_id=holdrec->qual[lidx].event_id)
             AND c.note_type_cd=dnotetypecd
            DETAIL
             dceeventnoteid = c.ce_event_note_id
            WITH nocounter
           ;end select
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = select_error
            SET table_name = "CE_EVENT_NOTE"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
           IF (dceeventnoteid)
            UPDATE  FROM ce_event_note c
             SET c.note_prsnl_id = holdrec->qual[lidx].note_prsnl_id, c.note_dt_tm = cnvtdatetime(
               holdrec->qual[lidx].event_dt_tm), c.note_tz = contribrec->qual[lcontribsysidx].
              time_zone_idx,
              c.updt_dt_tm = cnvtdatetime(dtcurrent), c.updt_id = contribrec->qual[lcontribsysidx].
              prsnl_person_id, c.updt_task = 424990,
              c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = 424990
             WHERE c.ce_event_note_id=dceeventnoteid
             WITH nocounter
            ;end update
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = update_error
             SET table_name = "CE_EVENT_NOTE"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
            SET slongblob = nullterm(concat(trim(holdrec->qual[lidx].event_note),"ocf_blob"),1)
            UPDATE  FROM long_blob l
             SET l.long_blob = slongblob, l.updt_dt_tm = cnvtdatetime(dtcurrent), l.updt_id =
              contribrec->qual[lcontribsysidx].prsnl_person_id,
              l.updt_task = 424990, l.updt_cnt = (l.updt_cnt+ 1), l.updt_applctx = 424990
             WHERE l.parent_entity_name="CE_EVENT_NOTE"
              AND l.parent_entity_id=dceeventnoteid
             WITH notrim, nocounter
            ;end update
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = update_error
             SET table_name = "LONG_BLOB"
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
          UPDATE  FROM ags_result_data r
           SET r.contributor_system_cd = holdrec->qual[lidx].contributor_system_cd, r.person_id =
            holdrec->qual[lidx].person_id, r.event_cd = holdrec->qual[lidx].event_cd,
            r.ordering_person_id = holdrec->qual[lidx].ordering_prsnl_id, r.status = "COMPLETE", r
            .stat_msg = trim(substring(1,40,holdrec->qual[lidx].stat_msg)),
            r.updt_dt_tm = cnvtdatetime(dtcurrent), r.updt_cnt = (r.updt_cnt+ 1)
           WHERE (r.ags_result_data_id=holdrec->qual[lidx].ags_result_data_id)
           WITH nocounter
          ;end update
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = update_error
           SET table_name = "AGS_RESULT_DATA"
           SET ilog_status = 1
           SET log->qual_knt = (log->qual_knt+ 1)
           SET stat = alterlist(log->qual,log->qual_knt)
           SET log->qual[log->qual_knt].smsgtype = "ERROR"
           SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
           SET log->qual[log->qual_knt].smsg = concat("AgsResltDataId :: ",trim(cnvtstring(holdrec->
              qual[lidx].ags_result_data_id)),"ErrMsg :: ",trim(serrmsg))
           SET serrmsg = log->qual[log->qual_knt].smsg
          ENDIF
         ELSE
          SET lcontribsysidx = holdrec->qual[lidx].contrib_sys_idx
          SELECT INTO "nl:"
           y = seq(clinical_event_seq,nextval)"##################;rp0"
           FROM dual
           DETAIL
            holdrec->qual[lidx].clinical_event_id = cnvtreal(y)
           WITH format, nocounter
          ;end select
          SELECT INTO "nl:"
           y = seq(clinical_event_seq,nextval)"##################;rp0"
           FROM dual
           DETAIL
            holdrec->qual[lidx].event_id = cnvtreal(y)
           WITH format, nocounter
          ;end select
          INSERT  FROM clinical_event ce
           SET ce.clinical_event_id = holdrec->qual[lidx].clinical_event_id, ce.event_id = holdrec->
            qual[lidx].event_id, ce.encntr_id = 0.0,
            ce.person_id = holdrec->qual[lidx].person_id, ce.event_start_dt_tm = null, ce
            .event_start_tz = 0.0,
            ce.encntr_financial_id = 0.0, ce.valid_from_dt_tm = cnvtdatetime(dtcurrent), ce
            .valid_until_dt_tm = cnvtdatetime(dtmax),
            ce.event_title_text = holdrec->qual[lidx].event_title_text, ce.view_level = 1, ce
            .order_id = 0.0,
            ce.catalog_cd = 0.0, ce.series_ref_nbr = " ", ce.accession_nbr = " ",
            ce.contributor_system_cd = holdrec->qual[lidx].contributor_system_cd, ce.reference_nbr =
            holdrec->qual[lidx].result_identifier, ce.parent_event_id = holdrec->qual[lidx].event_id,
            ce.event_reltn_cd = drooteventreltncd, ce.event_class_cd =
            IF (holdrec->qual[lidx].is_numeric) dnumeventclasscd
            ELSE dtxteventclasscd
            ENDIF
            , ce.event_cd = holdrec->qual[lidx].event_cd,
            ce.event_tag = holdrec->qual[lidx].result_val, ce.event_end_dt_tm = cnvtdatetime(holdrec
             ->qual[lidx].event_dt_tm), ce.event_end_dt_tm_os = 0,
            ce.event_end_tz = contribrec->qual[lcontribsysidx].time_zone_idx, ce.result_val = holdrec
            ->qual[lidx].result_val, ce.result_units_cd = holdrec->qual[lidx].unit_of_measure_cd,
            ce.result_time_units_cd = 0.0, ce.task_assay_cd = 0.0, ce.record_status_cd =
            dactiverecstatuscd,
            ce.result_status_cd = dauthresultstatuscd, ce.authentic_flag = 1, ce.publish_flag = 1,
            ce.qc_review_cd = 0.0, ce.normalcy_cd = holdrec->qual[lidx].normalcy_cd, ce.resource_cd
             = holdrec->qual[lidx].service_resource_cd,
            ce.normalcy_method_cd = 0.0, ce.inquire_security_cd = droutineclininquiresecuritycd, ce
            .resource_group_cd = 0,
            ce.subtable_bit_map =
            IF (size(trim(holdrec->qual[lidx].event_note)) > 0) 8195
            ELSE 8193
            ENDIF
            , ce.collating_seq = " ", ce.verified_dt_tm = cnvtdatetime(holdrec->qual[lidx].
             event_dt_tm),
            ce.verified_tz = contribrec->qual[lcontribsysidx].time_zone_idx, ce.verified_prsnl_id =
            holdrec->qual[lidx].verified_prsnl_id, ce.performed_dt_tm = cnvtdatetime(holdrec->qual[
             lidx].event_dt_tm),
            ce.performed_tz = contribrec->qual[lcontribsysidx].time_zone_idx, ce.performed_prsnl_id
             = holdrec->qual[lidx].performed_prsnl_id, ce.note_importance_bit_map =
            IF (size(trim(holdrec->qual[lidx].event_note)) > 0) 2
            ELSE 0
            ENDIF
            ,
            ce.event_tag_set_flag = 1, ce.normal_low = holdrec->qual[lidx].normal_low, ce.normal_high
             = holdrec->qual[lidx].normal_high,
            ce.critical_low = " ", ce.critical_high = " ", ce.expiration_dt_tm = null,
            ce.updt_dt_tm = cnvtdatetime(dtcurrent), ce.clinsig_updt_dt_tm = cnvtdatetime(dtcurrent),
            ce.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
            ce.updt_task = 424990, ce.updt_cnt = 0, ce.updt_applctx = 424990,
            ce.order_action_sequence = 0, ce.entry_mode_cd = dundefentrymodecd, ce.source_cd =
            dpremedrecsourcecd,
            ce.clinical_seq = " ", ce.task_assay_version_nbr = 0, ce.modifier_long_text_id = 0
           WHERE (holdrec->qual[lidx].event_id > 0.0)
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = insert_error
           SET table_name = "CLINICAL_EVENT"
           SET ilog_status = 1
           SET log->qual_knt = (log->qual_knt+ 1)
           SET stat = alterlist(log->qual,log->qual_knt)
           SET log->qual[log->qual_knt].smsgtype = "ERROR"
           SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
           SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
           SET serrmsg = log->qual[log->qual_knt].smsg
           GO TO exit_script
          ENDIF
          FOR (lidx2 = 1 TO 3)
            CASE (lidx2)
             OF 1:
              SET dactionprsnlid = holdrec->qual[lidx].performed_prsnl_id
              SET dactiontypecd = dperformactiontypecd
              SET dactionstatuscd = dcompleteactionstatuscd
              SET sactioncomment = "PERFORM/COMPLETE"
             OF 2:
              SET dactionprsnlid = holdrec->qual[lidx].verified_prsnl_id
              SET dactiontypecd = dverifyactiontypecd
              SET dactionstatuscd = dcompleteactionstatuscd
              SET sactioncomment = "VERIFY/COMPLETE"
             OF 3:
              SET dactionprsnlid = holdrec->qual[lidx].ordering_prsnl_id
              SET dactiontypecd = dorderactiontypecd
              SET dactionstatuscd = dcompleteactionstatuscd
              SET sactioncomment = "ORDER/COMPLETE"
            ENDCASE
            INSERT  FROM ce_event_prsnl c
             SET c.ce_event_prsnl_id = seq(ocf_seq,nextval), c.event_prsnl_id = seq(ocf_seq,nextval),
              c.event_id = holdrec->qual[lidx].event_id,
              c.person_id = holdrec->qual[lidx].person_id, c.valid_from_dt_tm = cnvtdatetime(
               dtcurrent), c.valid_until_dt_tm = cnvtdatetime(dtmax),
              c.action_comment = sactioncomment, c.action_dt_tm = cnvtdatetime(holdrec->qual[lidx].
               event_dt_tm), c.action_prsnl_ft = " ",
              c.action_prsnl_id = dactionprsnlid, c.action_status_cd = dactionstatuscd, c
              .action_type_cd = dactiontypecd,
              c.action_tz = contribrec->qual[lcontribsysidx].time_zone_idx, c
              .change_since_action_flag = 0, c.linked_event_id = 0.0,
              c.long_text_id = 0.0, c.proxy_prsnl_ft = " ", c.proxy_prsnl_id = 0.0,
              c.request_comment = " ", c.request_dt_tm = null, c.request_prsnl_ft = " ",
              c.request_prsnl_id = 0.0, c.request_tz = 0, c.system_comment = " ",
              c.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, c.updt_task = 424990, c
              .updt_cnt = 0,
              c.updt_applctx = 424990, c.digital_signature_ident = " "
             WHERE dactionprsnlid > 0.0
             WITH nocounter
            ;end insert
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = insert_error
             SET table_name = "CE_EVENT_PRSNL"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
          ENDFOR
          INSERT  FROM ce_string_result c
           SET c.event_id = holdrec->qual[lidx].event_id, c.valid_until_dt_tm = cnvtdatetime(dtmax),
            c.valid_from_dt_tm = cnvtdatetime(dtcurrent),
            c.string_result_format_cd =
            IF (holdrec->qual[lidx].is_numeric) dnumresultformatcd
            ELSE dalpharesultformatcd
            ENDIF
            , c.string_result_text = holdrec->qual[lidx].result_val, c.unit_of_measure_cd = holdrec->
            qual[lidx].unit_of_measure_cd,
            c.normal_low = holdrec->qual[lidx].normal_low, c.normal_high = holdrec->qual[lidx].
            normal_high, c.feasible_ind = 0.0,
            c.inaccurate_ind = 0.0, c.calculation_equation = " ", c.updt_dt_tm = cnvtdatetime(
             dtcurrent),
            c.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, c.updt_task = 424990, c
            .updt_cnt = 0,
            c.updt_applctx = 424990
           WHERE (holdrec->qual[lidx].event_id > 0)
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = insert_error
           SET table_name = "CE_STRING_RESULT"
           SET ilog_status = 1
           SET log->qual_knt = (log->qual_knt+ 1)
           SET stat = alterlist(log->qual,log->qual_knt)
           SET log->qual[log->qual_knt].smsgtype = "ERROR"
           SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
           SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
           SET serrmsg = log->qual[log->qual_knt].smsg
           GO TO exit_script
          ENDIF
          IF (size(trim(holdrec->qual[lidx].event_note)) > 0)
           SELECT INTO "nl:"
            y = seq(ocf_seq,nextval)"##################;rp0"
            FROM dual
            DETAIL
             holdrec->qual[lidx].ce_event_note_id = cnvtreal(y)
            WITH format, nocounter
           ;end select
           INSERT  FROM ce_event_note c
            SET c.ce_event_note_id = holdrec->qual[lidx].ce_event_note_id, c.event_note_id = seq(
              ocf_seq,nextval), c.event_id = holdrec->qual[lidx].event_id,
             c.valid_from_dt_tm = cnvtdatetime(dtcurrent), c.valid_until_dt_tm = cnvtdatetime(dtmax),
             c.note_type_cd = dnotetypecd,
             c.note_format_cd = dnoteformatcd, c.entry_method_cd = dentrymethodcd, c.note_prsnl_id =
             holdrec->qual[lidx].note_prsnl_id,
             c.note_dt_tm = cnvtdatetime(holdrec->qual[lidx].event_dt_tm), c.record_status_cd =
             dactiverecstatuscd, c.compression_cd = dcompressiontycd,
             c.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, c.updt_task = 424990, c
             .updt_cnt = 0,
             c.updt_applctx = 424990, c.long_text_id = 0.0, c.non_chartable_flag = 0,
             c.importance_flag = 2, c.note_tz = contribrec->qual[lcontribsysidx].time_zone_idx
            WHERE (holdrec->qual[lidx].event_id > 0)
            WITH nocounter
           ;end insert
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = insert_error
            SET table_name = "CE_EVENT_NOTE"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
           SET slongblob = nullterm(concat(trim(holdrec->qual[lidx].event_note),"ocf_blob"),1)
           INSERT  FROM long_blob l
            SET l.long_blob_id = seq(long_data_seq,nextval), l.active_ind = 1, l.active_status_cd =
             dactiverecstatuscd,
             l.active_status_dt_tm = cnvtdatetime(dtcurrent), l.active_status_prsnl_id = 1.0, l
             .parent_entity_name = "CE_EVENT_NOTE",
             l.parent_entity_id = holdrec->qual[lidx].ce_event_note_id, l.long_blob = slongblob, l
             .updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
             l.updt_task = 424990, l.updt_cnt = 0, l.updt_applctx = 424990
            WHERE (holdrec->qual[lidx].event_id > 0)
            WITH notrim, nocounter
           ;end insert
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = insert_error
            SET table_name = "LONG_BLOB"
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
          UPDATE  FROM ags_result_data r
           SET r.clinical_event_id = holdrec->qual[lidx].clinical_event_id, r.event_id = holdrec->
            qual[lidx].event_id, r.contributor_system_cd = holdrec->qual[lidx].contributor_system_cd,
            r.person_id = holdrec->qual[lidx].person_id, r.event_cd = holdrec->qual[lidx].event_cd, r
            .ordering_person_id = holdrec->qual[lidx].ordering_prsnl_id,
            r.status = "COMPLETE", r.stat_msg = trim(substring(1,40,holdrec->qual[lidx].stat_msg)), r
            .updt_dt_tm = cnvtdatetime(dtcurrent),
            r.updt_cnt = (r.updt_cnt+ 1)
           WHERE (r.ags_result_data_id=holdrec->qual[lidx].ags_result_data_id)
           WITH nocounter
          ;end update
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET failed = update_error
           SET table_name = "AGS_RESULT_DATA"
           SET ilog_status = 1
           SET log->qual_knt = (log->qual_knt+ 1)
           SET stat = alterlist(log->qual,log->qual_knt)
           SET log->qual[log->qual_knt].smsgtype = "ERROR"
           SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
           SET log->qual[log->qual_knt].smsg = concat("AgsResltDataId :: ",trim(cnvtstring(holdrec->
              qual[lidx].ags_result_data_id)),"ErrMsg :: ",trim(serrmsg))
           SET serrmsg = log->qual[log->qual_knt].smsg
          ENDIF
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ELSE
     IF (exceptionrec->qual_cnt)
      SET failed = true
      SET table_name = "UPDATE CE REQUEST"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("TASK_ID :: ",staskid,
       "  All rows in this task were exceptions!")
      SET serrmsg = log->qual[log->qual_knt].smsg
     ENDIF
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
      t.est_completion_dt_tm = cnvtdatetime(dtestcompletion)
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
    , t.status_dt_tm = cnvtdatetime(dtcurrent), t.batch_end_dt_tm = cnvtdatetime(dtcurrent)
   WHERE t.ags_task_id=dtaskid
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "LOAD CE REQUEST"
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
     SET j.status = "COMPLETE", j.status_dt_tm = cnvtdatetime(dtcurrent)
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
#exit_script
 SET stat = memfree(arynotes)
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
 SET log->qual[log->qual_knt].smsg = "END >> AGS_RESULT_LOAD"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 SET script_ver = "008 10/18/06"
 CALL echo(concat("MOD:",script_ver))
 CALL echo("<===== AGS_RESULT_LOAD End =====>")
END GO
