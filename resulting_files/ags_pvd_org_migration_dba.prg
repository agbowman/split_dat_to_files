CREATE PROGRAM ags_pvd_org_migration:dba
 PROMPT
  "TASK_ID (0.0) = " = 0.0
  WITH dtask_id
 CALL echo("***")
 CALL echo("***   BEG: AGS_PVD_ORG_MIGRATION")
 CALL echo("***")
 DECLARE dworkingtaskid = f8 WITH public, noconstant(0.0)
 SET dworkingtaskid =  $DTASK_ID
 DECLARE turn_on_tracing(null) = null WITH protect
 DECLARE turn_off_tracing(null) = null WITH protect
 DECLARE define_logging_sub = i2 WITH public, noconstant(false)
 IF ((validate(failed,- (1))=- (1)))
  EXECUTE cclseclogin2
  CALL echo("***")
  CALL echo("***   Declare Common Variables")
  CALL echo("***")
  IF ((validate(false,- (1))=- (1)))
   DECLARE false = i2 WITH public, noconstant(0)
  ENDIF
  IF ((validate(true,- (1))=- (1)))
   DECLARE true = i2 WITH public, noconstant(1)
  ENDIF
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
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  CALL echo("***")
  CALL echo("***   BEG LOGGING")
  CALL echo("***")
  FREE RECORD email
  RECORD email(
    1 qual_knt = i4
    1 qual[*]
      2 address = vc
      2 send_flag = i2
  )
  DECLARE eknt = i4 WITH public, noconstant(0)
  FREE RECORD log
  RECORD log(
    1 qual_knt = i4
    1 qual[*]
      2 smsgtype = c12
      2 dmsg_dt_tm = dq8
      2 smsg = vc
  )
  DECLARE handle_logging(slog_file=vc,semail=vc,istatus_flag=i4) = null WITH protect
  DECLARE sstatus_file_name = vc WITH public, noconstant(concat("ags_pvd_org_migration_",format(
     cnvtdatetime(curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_PVD_ORG_MIGRATION"
  SET define_logging_sub = true
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_PVD_ORG_MIGRATION"
 ENDIF
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE pos = i4 WITH public, noconstant(0)
 DECLARE isuccess = i2 WITH protect, constant(0)
 DECLARE ifailure = i2 WITH protect, constant(1)
 DECLARE iwarning = i2 WITH protect, constant(2)
 DECLARE iappnumber = i4 WITH protect, constant(4249900)
 DECLARE inoaction = i2 WITH protect, constant(0)
 DECLARE iinsert = i2 WITH protect, constant(1)
 DECLARE iupdate = i2 WITH protect, constant(2)
 DECLARE idelete = i2 WITH protect, constant(3)
 DECLARE desidefaultcd = f8 WITH public, constant(uar_get_code_by("DISPLAY",73,"Default"))
 DECLARE dextaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"ORGEXTALIAS")
  )
 DECLARE daltaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"ORGALTALIAS")
  )
 DECLARE dorglnkaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "ORGLNKUUID"))
 DECLARE dorgclasscd = f8 WITH public, constant(uar_get_code_by("MEANING",396,"ORG"))
 DECLARE dauthdatastatuscd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE dactivestatuscd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dclientorgtypecd = f8 WITH public, constant(uar_get_code_by("MEANING",278,"CLIENT"))
 DECLARE dfacilityorgtypecd = f8 WITH public, constant(uar_get_code_by("MEANING",278,"FACILITY"))
 DECLARE dfacilityloctypecd = f8 WITH public, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE dworkaddrtypecd = f8 WITH public, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE dworkphonetypecd = f8 WITH publlic, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE dworkfaxtypecd = f8 WITH publlic, constant(uar_get_code_by("MEANING",43,"FAX BUS"))
 DECLARE icutoverflag = i2 WITH public, noconstant(0)
 DECLARE imodeflag = i2 WITH public, noconstant(0)
 DECLARE ikillind = i2 WITH public, noconstant(0)
 DECLARE iloglevel = i2 WITH public, noconstant(0)
 DECLARE itaskknt = i4 WITH public, noconstant(0)
 DECLARE ibatchsize = i4 WITH public, noconstant(5000)
 DECLARE ibegwlistidx = i4 WITH public, noconstant(1)
 DECLARE iendwlistidx = i4 WITH public, noconstant(0)
 DECLARE itotaluniquelinkknt = i4 WITH public, noconstant(0)
 DECLARE imaincontinue = i2 WITH public, noconstant(true)
 DECLARE irowknterror = i4 WITH public, noconstant(0)
 DECLARE dbatchstartid = f8 WITH public, noconstant(0.0)
 DECLARE dbatchendid = f8 WITH public, noconstant(0.0)
 DECLARE djobid = f8 WITH public, noconstant(0.0)
 DECLARE sbeglinkalias = vc WITH public, noconstant(" ")
 DECLARE sendlinkalias = vc WITH public, noconstant(" ")
 DECLARE sstatus = vc WITH public, noconstant(" ")
 DECLARE staskstatus = vc WITH public, noconstant("PROCESSING")
 DECLARE found_om_flag = i2 WITH public, noconstant(false)
 FREE RECORD wlist
 RECORD wlist(
   1 qual_knt = i4
   1 qual[*]
     2 provdir_link_alias = vc
     2 provdir_alias = vc
     2 ext_alias = vc
     2 ags_org_data_id = f8
     2 run_nbr = i4
     2 name = vc
     2 org_id = f8
     2 location_cd = f8
     2 org_action_flag = i2
     2 location_action_flag = i2
     2 contrib_idx = i4
     2 status = c12
     2 stat_msg = vc
 )
 FREE RECORD contrib_rec
 RECORD contrib_rec(
   1 list_knt = i4
   1 list[*]
     2 sending_facility = vc
     2 contributor_system_cd = f8
     2 contributor_source_cd = f8
     2 time_zone_flag = i2
     2 time_zone = vc
     2 time_zone_idx = i4
     2 prsnl_person_id = f8
     2 organization_id = f8
     2 ext_alias_pool_cd = f8
     2 ext_alias_type_cd = f8
     2 orglnkuuid_pool_cd = f8
     2 orglnkuuid_type_cd = f8
     2 loc_cva_alias_stamp = vc
 )
 FREE RECORD alt_rec
 RECORD alt_rec(
   1 qual_knt = i4
   1 qual[*]
     2 esi_alias_type = vc
     2 contrib_idx = i4
     2 alt_alias_pool_cd = f8
     2 alt_alias_type_cd = f8
 )
 FREE RECORD data_rec
 RECORD data_rec(
   1 qual_knt = i4
   1 qual[*]
     2 ags_org_data_id = f8
     2 run_nbr = i4
     2 provdir_link_alias = vc
     2 provdir_alias = vc
     2 primary_ind = i2
     2 old_org_id = f8
     2 old_location_cd = f8
     2 address_id = f8
     2 bus_phone_id = f8
     2 fax_phone_id = f8
     2 contributor_system_cd = f8
     2 ext_alias = vc
     2 alt_alias1 = vc
     2 alt_alias1_type = vc
     2 alt_alias2 = vc
     2 alt_alias2_type = vc
     2 alt_alias3 = vc
     2 alt_alias3_type = vc
     2 address_action_flag = i2
     2 street_addr = vc
     2 street_addr2 = vc
     2 city = vc
     2 state = vc
     2 zipcode = vc
     2 county = vc
     2 country = vc
     2 phone_action_flag = i2
     2 phone_num = vc
     2 fax_action_flag = i2
     2 fax_num = vc
     2 status = c12
     2 stat_msg = vc
     2 contrib_idx = i4
     2 wlist_idx = i4
     2 alt1_idx = i4
     2 alt2_idx = i4
     2 alt3_idx = i4
 )
 FREE RECORD oa_rec
 RECORD oa_rec(
   1 qual_knt = i4
   1 qual[*]
     2 provdir_link_alias = vc
     2 action_flag = i2
     2 alias = vc
     2 alias_key = vc
     2 alias_type = vc
     2 alias_pool_cd = f8
     2 org_alias_type_cd = f8
     2 data_rec_idx = i4
 )
 FREE RECORD dates
 RECORD dates(
   1 now_dt_tm = dq8
   1 end_dt_tm = dq8
   1 batch_start_dt_tm = dq8
   1 it_end_dt_tm = dq8
   1 it_est_end_dt_tm = dq8
 )
 SET dates->now_dt_tm = cnvtdatetime(curdate,curtime3)
 SET dates->end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("dWorkingTaskId : ",trim(cnvtstring(dworkingtaskid)))
 IF (desidefaultcd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dEsiDefaultCd < 1 :: Select Error :: DISPLAY Default in Code Set 73 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dextaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dExtAliasFieldCd < 1 :: Select Error :: MEANING ORGEXTALIAS in Code Set 4001891 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (daltaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dAltAliasFieldCd < 1 :: Select Error :: MEANING ORGALTALIAS in Code Set 4001891 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dorglnkaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dOrgLnkAliasFieldCd < 1 :: Select Error :: MEANING ORGLNKUUID in Code Set 4001891 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dorgclasscd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dOrgClassCd < 1 :: Select Error :: MEANING ORG in Code Set 396 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dauthdatastatuscd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dAuthDataStatusCd < 1 :: Select Error :: MEANING AUTH in Code Set 8 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dactivestatuscd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dActiveStatusCd < 1 :: Select Error :: MEANING ACTIVE in Code Set 48 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dclientorgtypecd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dClientOrgTypeCd < 1 :: Select Error :: MEANING CLIENT in Code Set 278 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dfacilityorgtypecd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dFacilityOrgTypeCd < 1 :: Select Error :: MEANING FACILITY in Code Set 278 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dfacilityloctypecd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dFacilityLocTypeCd < 1 :: Select Error :: MEANING FACILITY in Code Set 222 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dworkaddrtypecd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dWorkAddrTypeCd < 1 :: Select Error :: MEANING BUSINESS in Code Set 212 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dworkphonetypecd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dWorkPhoneTypeCd < 1 :: Select Error :: MEANING BUSINESS in Code Set 43 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dworkfaxtypecd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dWorkFaxTypeCd < 1 :: Select Error :: MEANING FAX BUS in Code Set 43 not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("Validate Cut-Over")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="AGS"
    AND di.info_name IN ("PROVIDER_DIRECTORY", "ORG_MIGRATION"))
  HEAD REPORT
   pd_flag = - (1), om_flag = - (1)
  DETAIL
   IF (di.info_name="PROVIDER_DIRECTORY")
    pd_flag = 0
    IF (cnvtint(di.info_number) > 0)
     pd_flag = 1
    ENDIF
   ENDIF
   IF (di.info_name="ORG_MIGRATION")
    found_om_flag = true, om_flag = 0
    IF (cnvtint(di.info_number) > 0)
     om_flag = 1
    ENDIF
   ENDIF
  FOOT REPORT
   IF (pd_flag=1
    AND om_flag < 1)
    icutoverflag = 1
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DM_INFO"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("Validate Cut-Over :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (icutoverflag < 1)
  SET failed = input_error
  SET table_name = "VALIDATION"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "Validate Cut-Over :: Input Error :: Problem on Migration Check"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Task Info")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ags_task a,
   ags_job j,
   ags_task t
  PLAN (a
   WHERE a.ags_task_id=dworkingtaskid)
   JOIN (j
   WHERE j.ags_job_id=a.ags_job_id)
   JOIN (t
   WHERE t.ags_job_id=j.ags_job_id)
  DETAIL
   itaskknt = (itaskknt+ 1), djobid = a.ags_job_id
   IF (a.iteration_start_id > 0.0)
    dbatchstartid = a.iteration_start_id
   ELSE
    dbatchstartid = a.batch_start_id
   ENDIF
   dbatchendid = a.batch_end_id
   IF (a.batch_size > 0)
    ibatchsize = a.batch_size
   ENDIF
   imodeflag = a.mode_flag, ikillind = a.kill_ind, iloglevel = a.timers_flag,
   sstatus = trim(a.status,3)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_TASK"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("Get Task Info :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (iloglevel > 0)
  CALL turn_on_tracing(null)
 ELSE
  CALL turn_off_tracing(null)
 ENDIF
 CALL echo("***")
 CALL echo(build("***   dBatchStartId: ",dbatchstartid))
 CALL echo(build("***   dBatchEndId  : ",dbatchendid))
 CALL echo(build("***   iBatchSize   : ",ibatchsize))
 CALL echo(build("***   iModeFlag    : ",imodeflag))
 CALL echo(build("***   iKillInd     : ",ikillind))
 CALL echo(build("***   iLogLevel    : ",iloglevel))
 CALL echo(build("***   sStatus      : ",sstatus))
 CALL echo("***")
 IF (itaskknt > 1)
  SET failed = input_error
  SET table_name = "AGS_TASK"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "Get Task Info :: Input Error :: Multiple AGS_JOB_ID values"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ELSEIF (itaskknt < 1)
  SET failed = input_error
  SET table_name = "AGS_TASK"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("Get Task Info :: Input Error :: Invalid AGS_TASK_ID (",
   trim(cnvtstring(dworkingtaskid)),")")
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (sstatus="COMPLETE")
  SET failed = input_error
  SET table_name = "AGS_TASK"
  SET ilog_status = iwarning
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "WARNING"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "Get Task Info :: Input Error :: Task is in a COMPLETE status"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (ikillind > 0)
  ROLLBACK
  SET failed = input_error
  SET table_name = "AGS_TASK"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "KILL_IND :: Greater Than 0"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Distinct Link Aliases")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT DISTINCT INTO "nl:"
  a.provdir_link_alias
  FROM ags_org_data a
  PLAN (a
   WHERE a.ags_job_id=djobid
    AND a.provdir_link_alias > " "
    AND a.provdir_link_alias != null
    AND a.primary_ind=1
    AND a.status != "COMPLETE")
  ORDER BY a.provdir_link_alias
  HEAD REPORT
   knt = 0
  HEAD a.provdir_link_alias
   knt = (knt+ 1)
  FOOT REPORT
   itotaluniquelinkknt = knt, sendlinkalias = trim(a.provdir_link_alias,3)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_ORG_DATA"
  SET ilog_status = ifailure
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("Get sEndLinkAlias :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (itotaluniquelinkknt < 1)
  SET ilog_status = iwarning
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "No Valid PROVDIR_LINK_ALIAS Values Found"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Main")
 CALL echo("***")
 CALL echo("***")
 CALL echo("***   Update Task to PROCESSING")
 CALL echo("***")
 SET staskstatus = "PROCESSING"
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_task t
  SET t.status = staskstatus, t.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (t
   WHERE t.ags_task_id=dworkingtaskid)
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
  SET log->qual[log->qual_knt].smsg = concat("AGS_TASK PROCESSING :: Update Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***   sBegLinkAlias :",sbeglinkalias))
 CALL echo(build("***   sEndLinkAlias :",sendlinkalias))
 CALL echo("***")
 WHILE (sbeglinkalias < sendlinkalias
  AND imaincontinue=true)
   CALL echo("***")
   CALL echo("***   Get wlist Set")
   CALL echo("***")
   SET dates->now_dt_tm = cnvtdatetime(curdate,curtime3)
   SET stat = initrec(wlist)
   SET stat = initrec(data_rec)
   SET stat = initrec(oa_rec)
   CALL echo("***")
   CALL echo(build("***   sBegLinkAlias :",sbeglinkalias))
   CALL echo(build("***   sEndLinkAlias :",sendlinkalias))
   CALL echo("***")
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("sBegLinkAlias : ",trim(sbeglinkalias))
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("sEndLinkAlias : ",trim(sendlinkalias))
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT DISTINCT INTO "nl:"
    FROM ags_org_data a
    PLAN (a
     WHERE a.ags_job_id=djobid
      AND a.provdir_link_alias > sbeglinkalias
      AND a.primary_ind=1
      AND a.status != "COMPLETE")
    ORDER BY a.provdir_link_alias, a.provdir_alias, a.ags_org_data_id
    HEAD REPORT
     knt = 0, stat = alterlist(wlist->qual,1000)
    HEAD a.provdir_link_alias
     knt = (knt+ 1)
     IF (mod(knt,1000)=1
      AND knt != 1)
      stat = alterlist(wlist->qual,(knt+ 999))
     ENDIF
     wlist->qual[knt].provdir_link_alias = trim(a.provdir_link_alias,3), wlist->qual[knt].
     provdir_alias = trim(a.provdir_alias,3), wlist->qual[knt].ext_alias = trim(a.ext_alias,3),
     wlist->qual[knt].ags_org_data_id = a.ags_org_data_id, wlist->qual[knt].run_nbr = a.run_nbr,
     wlist->qual[knt].org_id = a.organization_id,
     wlist->qual[knt].location_cd = a.location_cd, wlist->qual[knt].name = trim(a.name,3)
     IF (a.organization_id > 0)
      wlist->qual[knt].org_action_flag = inoaction
     ENDIF
     IF (trim(a.sending_facility,3) > " "
      AND trim(a.sending_facility,3) != null)
      IF ((contrib_rec->list_knt > 0))
       pos = 0, pos = locateval(num,1,contrib_rec->list_knt,a.sending_facility,contrib_rec->list[num]
        .sending_facility)
       IF (pos > 0)
        wlist->qual[knt].contrib_idx = pos
       ELSE
        contrib_rec->list_knt = (contrib_rec->list_knt+ 1), stat = alterlist(contrib_rec->list,
         contrib_rec->list_knt), contrib_rec->list[contrib_rec->list_knt].sending_facility = trim(a
         .sending_facility,3),
        wlist->qual[knt].contrib_idx = contrib_rec->list_knt
       ENDIF
      ELSE
       contrib_rec->list_knt = (contrib_rec->list_knt+ 1), stat = alterlist(contrib_rec->list,
        contrib_rec->list_knt), contrib_rec->list[contrib_rec->list_knt].sending_facility = trim(a
        .sending_facility,3),
       wlist->qual[knt].contrib_idx = contrib_rec->list_knt
      ENDIF
     ELSE
      wlist->qual[knt].status = "IN ERROR", wlist->qual[knt].contrib_idx = - (1), wlist->qual[knt].
      stat_msg = concat(trim(wlist->qual[knt].stat_msg),"[contrib]"),
      irowknterror = (irowknterror+ 1)
     ENDIF
     IF ((( NOT (trim(a.name,3) > " ")) OR (trim(a.name,3)=null)) )
      wlist->qual[knt].status = "IN ERROR", wlist->qual[knt].stat_msg = concat(trim(wlist->qual[knt].
        stat_msg),"[name]")
     ENDIF
     IF ((( NOT (trim(a.ext_alias,3) > " ")) OR (trim(a.ext_alias,3)=null)) )
      wlist->qual[knt].status = "IN ERROR", wlist->qual[knt].stat_msg = concat(trim(wlist->qual[knt].
        stat_msg),"[ext_alias]")
     ENDIF
    FOOT REPORT
     wlist->qual_knt = knt, stat = alterlist(wlist->qual,knt), sbeglinkalias = trim(a
      .provdir_link_alias,3)
    WITH nocounter, maxqual(a,value(ibatchsize))
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "AGS_ORG_DATA"
    SET ilog_status = ifailure
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("Get wlist Set :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   IF ((wlist->qual_knt > 0))
    CALL echo("***")
    CALL echo("***   Get Data Set")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM ags_org_data a,
      (dummyt d  WITH seq = value(wlist->qual_knt))
     PLAN (d
      WHERE d.seq > 0)
      JOIN (a
      WHERE a.ags_job_id=djobid
       AND (a.provdir_link_alias=wlist->qual[d.seq].provdir_link_alias)
       AND a.status != "COMPLETE")
     ORDER BY d.seq, a.provdir_alias, a.ags_org_data_id
     HEAD REPORT
      knt = 0, stat = alterlist(data_rec->qual,1000), aknt = 0,
      fknt = 0, oaknt = 0, pknt = 0
     DETAIL
      knt = (knt+ 1)
      IF (mod(knt,1000)=1
       AND knt != 1)
       stat = alterlist(wlist->qual,(knt+ 999))
      ENDIF
      data_rec->qual[knt].wlist_idx = d.seq, data_rec->qual[knt].ags_org_data_id = a.ags_org_data_id,
      data_rec->qual[knt].run_nbr = a.run_nbr,
      data_rec->qual[knt].provdir_link_alias = trim(a.provdir_link_alias,3), data_rec->qual[knt].
      provdir_alias = trim(a.provdir_alias,3), data_rec->qual[knt].primary_ind = a.primary_ind,
      data_rec->qual[knt].address_id = a.address_id, data_rec->qual[knt].bus_phone_id = a
      .bus_phone_id, data_rec->qual[knt].fax_phone_id = a.fax_phone_id,
      data_rec->qual[knt].contributor_system_cd = a.contributor_system_cd, data_rec->qual[knt].
      street_addr = trim(a.street_addr,3), data_rec->qual[knt].street_addr2 = trim(a.street_addr2,3),
      data_rec->qual[knt].city = trim(a.city,3), data_rec->qual[knt].state = trim(a.state,3),
      data_rec->qual[knt].zipcode = trim(a.zipcode,3),
      data_rec->qual[knt].county = trim(a.county,3), data_rec->qual[knt].country = trim(a.country,3),
      data_rec->qual[knt].ext_alias = trim(a.ext_alias,3),
      data_rec->qual[knt].alt_alias1 = trim(a.alt_alias1,3), data_rec->qual[knt].alt_alias1_type =
      trim(a.alt_alias1_type,3), data_rec->qual[knt].alt_alias2 = trim(a.alt_alias2,3),
      data_rec->qual[knt].alt_alias2_type = trim(a.alt_alias2_type,3), data_rec->qual[knt].alt_alias3
       = trim(a.alt_alias3,3), data_rec->qual[knt].alt_alias3_type = trim(a.alt_alias3_type,3),
      data_rec->qual[knt].phone_num = trim(a.phone1,3), data_rec->qual[knt].fax_num = trim(a
       .phone_fax,3)
      IF (a.address_id > 0)
       data_rec->qual[knt].address_action_flag = iupdate
      ENDIF
      IF ((( NOT (trim(a.city,3) > " ")) OR (trim(a.city,3)=null))
       AND (( NOT (trim(a.state,3) > " ")) OR (trim(a.state,3)=null)) )
       data_rec->qual[knt].address_action_flag = idelete
      ENDIF
      IF (a.bus_phone_id > 0)
       data_rec->qual[knt].phone_action_flag = iupdate
      ENDIF
      IF ((( NOT (trim(a.phone1,3) > " ")) OR (trim(a.phone1,3)=null)) )
       data_rec->qual[knt].phone_action_flag = idelete
      ENDIF
      IF (a.fax_phone_id > 0)
       data_rec->qual[knt].fax_action_flag = iupdate
      ENDIF
      IF ((( NOT (trim(a.phone_fax,3) > " ")) OR (trim(a.phone_fax,3)=null)) )
       data_rec->qual[knt].fax_action_flag = idelete
      ENDIF
      IF (trim(a.sending_facility,3) > " "
       AND trim(a.sending_facility,3) != null)
       IF ((contrib_rec->list_knt > 0))
        pos = 0, pos = locateval(num,1,contrib_rec->list_knt,a.sending_facility,contrib_rec->list[num
         ].sending_facility)
        IF (pos > 0)
         data_rec->qual[knt].contrib_idx = pos
        ELSE
         contrib_rec->list_knt = (contrib_rec->list_knt+ 1), stat = alterlist(contrib_rec->list,
          contrib_rec->list_knt), contrib_rec->list[contrib_rec->list_knt].sending_facility = trim(a
          .sending_facility,3),
         data_rec->qual[knt].contrib_idx = contrib_rec->list_knt
        ENDIF
       ELSE
        contrib_rec->list_knt = (contrib_rec->list_knt+ 1), stat = alterlist(contrib_rec->list,
         contrib_rec->list_knt), contrib_rec->list[contrib_rec->list_knt].sending_facility = trim(a
         .sending_facility,3),
        data_rec->qual[knt].contrib_idx = contrib_rec->list_knt
       ENDIF
      ELSE
       data_rec->qual[knt].status = "IN ERROR", data_rec->qual[knt].contrib_idx = - (1), data_rec->
       qual[knt].stat_msg = concat(trim(data_rec->qual[knt].stat_msg),"[contrib]"),
       irowknterror = (irowknterror+ 1)
      ENDIF
      IF (size(trim(a.alt_alias1,3)) > 0)
       pos = 0, pos = locateval(num,1,alt_rec->qual_knt,a.alt_alias1_type,alt_rec->qual[num].
        esi_alias_type)
       IF (pos > 0)
        data_rec->qual[knt].alt1_idx = pos
       ELSE
        alt_rec->qual_knt = (alt_rec->qual_knt+ 1), stat = alterlist(alt_rec->qual,alt_rec->qual_knt),
        alt_rec->qual[alt_rec->qual_knt].esi_alias_type = trim(a.alt_alias1_type,3),
        alt_rec->qual[alt_rec->qual_knt].contrib_idx = data_rec->qual[knt].contrib_idx, data_rec->
        qual[knt].alt1_idx = alt_rec->qual_knt
       ENDIF
      ELSE
       data_rec->qual[knt].alt1_idx = - (1)
      ENDIF
      IF (size(trim(a.alt_alias2,3)) > 0)
       pos = 0, pos = locateval(num,1,alt_rec->qual_knt,a.alt_alias2_type,alt_rec->qual[num].
        esi_alias_type)
       IF (pos > 0)
        data_rec->qual[knt].alt2_idx = pos
       ELSE
        alt_rec->qual_knt = (alt_rec->qual_knt+ 1), stat = alterlist(alt_rec->qual,alt_rec->qual_knt),
        alt_rec->qual[alt_rec->qual_knt].esi_alias_type = trim(a.alt_alias2_type,3),
        alt_rec->qual[alt_rec->qual_knt].contrib_idx = data_rec->qual[knt].contrib_idx, data_rec->
        qual[knt].alt2_idx = alt_rec->qual_knt
       ENDIF
      ELSE
       data_rec->qual[knt].alt2_idx = - (1)
      ENDIF
      IF (size(trim(a.alt_alias3,3)) > 0)
       pos = 0, pos = locateval(num,1,alt_rec->qual_knt,a.alt_alias3_type,alt_rec->qual[num].
        esi_alias_type)
       IF (pos > 0)
        data_rec->qual[knt].alt3_idx = pos
       ELSE
        alt_rec->qual_knt = (alt_rec->qual_knt+ 1), stat = alterlist(alt_rec->qual,alt_rec->qual_knt),
        alt_rec->qual[alt_rec->qual_knt].esi_alias_type = trim(a.alt_alias3_type,3),
        alt_rec->qual[alt_rec->qual_knt].contrib_idx = data_rec->qual[knt].contrib_idx, data_rec->
        qual[knt].alt3_idx = alt_rec->qual_knt
       ENDIF
      ELSE
       data_rec->qual[knt].alt3_idx = - (1)
      ENDIF
     FOOT REPORT
      data_rec->qual_knt = knt, stat = alterlist(data_rec->qual,knt)
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "AGS_ORG_DATA"
     SET ilog_status = ifailure
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("Get Data Set :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF ((contrib_rec->list_knt > 0))
     CALL echo("***      ")
     CALL echo("***      Get Contributor System")
     CALL echo("***      ")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM code_value_alias cva,
       contributor_system cs,
       esi_alias_trans eat,
       (dummyt d  WITH seq = value(contrib_rec->list_knt))
      PLAN (d
       WHERE (contrib_rec->list[d.seq].contributor_system_cd < 1))
       JOIN (cva
       WHERE cva.code_set=89
        AND (cva.alias=contrib_rec->list[d.seq].sending_facility)
        AND cva.contributor_source_cd=desidefaultcd)
       JOIN (cs
       WHERE cs.contributor_system_cd=cva.code_value
        AND cs.active_ind=1)
       JOIN (eat
       WHERE eat.contributor_system_cd=cs.contributor_system_cd
        AND eat.esi_alias_field_cd IN (dorglnkaliasfieldcd, dextaliasfieldcd)
        AND eat.active_ind=1)
      HEAD cva.alias
       contrib_rec->list[d.seq].sending_facility = cva.alias, contrib_rec->list[d.seq].
       contributor_system_cd = cs.contributor_system_cd, contrib_rec->list[d.seq].
       contributor_source_cd = cs.contributor_source_cd,
       contrib_rec->list[d.seq].time_zone_flag = cs.time_zone_flag, contrib_rec->list[d.seq].
       time_zone = cs.time_zone, contrib_rec->list[d.seq].time_zone_idx = datetimezonebyname(
        contrib_rec->list[d.seq].time_zone),
       contrib_rec->list[d.seq].prsnl_person_id = cs.prsnl_person_id, contrib_rec->list[d.seq].
       organization_id = cs.organization_id, found_ext_alias = false,
       found_orglnk = false
      DETAIL
       IF (found_ext_alias=false
        AND eat.esi_alias_field_cd=dextaliasfieldcd)
        found_ext_alias = true, contrib_rec->list[d.seq].ext_alias_pool_cd = eat.alias_pool_cd,
        contrib_rec->list[d.seq].ext_alias_type_cd = eat.alias_entity_alias_type_cd,
        contrib_rec->list[d.seq].loc_cva_alias_stamp = concat("~",trim(cnvtupper(cnvtalphanum(
            uar_get_code_display(eat.alias_pool_cd)))),"~",trim(cnvtupper(cnvtalphanum(
            uar_get_code_display(eat.alias_entity_alias_type_cd)))))
       ENDIF
       IF (found_orglnk=false
        AND eat.esi_alias_field_cd=dorglnkaliasfieldcd)
        found_orglnk = true, contrib_rec->list[d.seq].orglnkuuid_pool_cd = eat.alias_pool_cd,
        contrib_rec->list[d.seq].orglnkuuid_type_cd = eat.alias_entity_alias_type_cd
       ENDIF
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "GET CONTRIBUTOR SYSTEMS"
      SET ilog_status = ifailure
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("GET CONTRIBUTOR SYSTEMS :: Select Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echorecord(contrib_rec)
     IF ((alt_rec->qual_knt > 0))
      CALL echo("***")
      CALL echo("***      Get alt Values")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM esi_alias_trans eat,
        (dummyt d  WITH seq = value(alt_rec->qual_knt))
       PLAN (d
        WHERE (alt_rec->qual[d.seq].contrib_idx > 0))
        JOIN (eat
        WHERE (eat.contributor_system_cd=contrib_rec->list[alt_rec->qual[d.seq].contrib_idx].
        contributor_system_cd)
         AND (eat.esi_alias_type=alt_rec->qual[d.seq].esi_alias_type)
         AND eat.alias_entity_name="ORGANIZATION"
         AND eat.esi_alias_field_cd=daltaliasfieldcd
         AND eat.active_ind=1)
       HEAD eat.esi_alias_type
        IF ((eat.esi_alias_type=alt_rec->qual[d.seq].esi_alias_type)
         AND (alt_rec->qual[d.seq].alt_alias_pool_cd < 1))
         alt_rec->qual[d.seq].alt_alias_pool_cd = eat.alias_pool_cd, alt_rec->qual[d.seq].
         alt_alias_type_cd = eat.alias_entity_alias_type_cd
        ENDIF
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "GET ALT VALUES"
       SET ilog_status = ifailure
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("GET ALT VALUES :: Select Error :: ",trim(serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
     ENDIF
     CALL echorecord(alt_rec)
     FOR (kidx = 1 TO data_rec->qual_knt)
      IF ((wlist->qual[data_rec->qual[kidx].wlist_idx].contrib_idx > 0))
       IF ((contrib_rec->list[wlist->qual[data_rec->qual[kidx].wlist_idx].contrib_idx].
       contributor_system_cd < 1))
        SET wlist->qual[data_rec->qual[kidx].wlist_idx].status = "IN ERROR"
        SET wlist->qual[data_rec->qual[kidx].wlist_idx].stat_msg = concat(trim(wlist->qual[data_rec->
          qual[kidx].wlist_idx].stat_msg),"[contrib]")
       ELSE
        IF ((((contrib_rec->list[wlist->qual[data_rec->qual[kidx].wlist_idx].contrib_idx].
        ext_alias_pool_cd < 1)) OR ((contrib_rec->list[wlist->qual[data_rec->qual[kidx].wlist_idx].
        contrib_idx].ext_alias_type_cd < 1))) )
         SET wlist->qual[data_rec->qual[kidx].wlist_idx].status = "IN ERROR"
         SET wlist->qual[data_rec->qual[kidx].wlist_idx].stat_msg = concat(trim(wlist->qual[data_rec
           ->qual[kidx].wlist_idx].stat_msg),"[ext-pool-type]")
        ENDIF
        IF ((((contrib_rec->list[wlist->qual[data_rec->qual[kidx].wlist_idx].contrib_idx].
        orglnkuuid_pool_cd < 1)) OR ((contrib_rec->list[wlist->qual[data_rec->qual[kidx].wlist_idx].
        contrib_idx].orglnkuuid_type_cd < 1))) )
         SET wlist->qual[data_rec->qual[kidx].wlist_idx].status = "IN ERROR"
         SET wlist->qual[data_rec->qual[kidx].wlist_idx].stat_msg = concat(trim(wlist->qual[data_rec
           ->qual[kidx].wlist_idx].stat_msg),"[lnk-pool-type]")
        ENDIF
       ENDIF
      ENDIF
      IF ((data_rec->qual[kidx].contrib_idx > 0))
       IF ((wlist->qual[data_rec->qual[kidx].wlist_idx].contrib_idx > 0)
        AND (wlist->qual[data_rec->qual[kidx].wlist_idx].contrib_idx != data_rec->qual[kidx].
       contrib_idx))
        IF ((((contrib_rec->list[data_rec->qual[kidx].contrib_idx].orglnkuuid_pool_cd != contrib_rec
        ->list[wlist->qual[data_rec->qual[kidx].wlist_idx].contrib_idx].orglnkuuid_pool_cd)) OR ((
        contrib_rec->list[data_rec->qual[kidx].contrib_idx].orglnkuuid_type_cd != contrib_rec->list[
        wlist->qual[data_rec->qual[kidx].wlist_idx].contrib_idx].orglnkuuid_type_cd))) )
         SET data_rec->qual[kidx].status = "IN ERROR"
         SET data_rec->qual[kidx].stat_msg = concat(trim(data_rec->qual[kidx].stat_msg),
          "[pla-pool-type]")
         SET wlist->qual[data_rec->qual[kidx].wlist_idx].status = "IN ERROR"
         SET wlist->qual[data_rec->qual[kidx].wlist_idx].stat_msg = concat(trim(wlist->qual[data_rec
           ->qual[kidx].wlist_idx].stat_msg),"[np]")
        ENDIF
       ENDIF
       IF ((contrib_rec->list[data_rec->qual[kidx].contrib_idx].contributor_system_cd < 1))
        SET data_rec->qual[kidx].status = "IN ERROR"
        SET data_rec->qual[kidx].stat_msg = concat(trim(data_rec->qual[kidx].stat_msg),"[contrib]")
        SET wlist->qual[data_rec->qual[kidx].wlist_idx].status = "IN ERROR"
        SET wlist->qual[data_rec->qual[kidx].wlist_idx].stat_msg = concat(trim(wlist->qual[data_rec->
          qual[kidx].wlist_idx].stat_msg),"[np]")
       ELSE
        IF ((((contrib_rec->list[data_rec->qual[kidx].contrib_idx].ext_alias_pool_cd < 1)) OR ((
        contrib_rec->list[data_rec->qual[kidx].contrib_idx].ext_alias_type_cd < 1))) )
         SET data_rec->qual[kidx].status = "IN ERROR"
         SET data_rec->qual[kidx].stat_msg = concat(trim(data_rec->qual[kidx].stat_msg),
          "[ext-pool-type]")
         SET wlist->qual[data_rec->qual[kidx].wlist_idx].status = "IN ERROR"
         SET wlist->qual[data_rec->qual[kidx].wlist_idx].stat_msg = concat(trim(wlist->qual[data_rec
           ->qual[kidx].wlist_idx].stat_msg),"[np]")
        ENDIF
        IF ((((contrib_rec->list[data_rec->qual[kidx].contrib_idx].orglnkuuid_pool_cd < 1)) OR ((
        contrib_rec->list[data_rec->qual[kidx].contrib_idx].orglnkuuid_type_cd < 1))) )
         SET data_rec->qual[kidx].status = "IN ERROR"
         SET data_rec->qual[kidx].stat_msg = concat(trim(data_rec->qual[kidx].stat_msg),
          "[lnk-pool-type]")
         SET wlist->qual[data_rec->qual[kidx].wlist_idx].status = "IN ERROR"
         SET wlist->qual[data_rec->qual[kidx].wlist_idx].stat_msg = concat(trim(wlist->qual[data_rec
           ->qual[kidx].wlist_idx].stat_msg),"[np]")
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
     FOR (kidx = 1 TO data_rec->qual_knt)
       IF ((wlist->qual[data_rec->qual[kidx].wlist_idx].status="IN ERROR"))
        SET wlist->qual[data_rec->qual[kidx].wlist_idx].contrib_idx = - (1)
        IF ((data_rec->qual[kidx].primary_ind=1))
         SET data_rec->qual[kidx].status = "IN ERROR"
         SET data_rec->qual[kidx].stat_msg = concat(trim(wlist->qual[data_rec->qual[kidx].wlist_idx].
           stat_msg),trim(data_rec->qual[kidx].stat_msg))
        ELSE
         SET data_rec->qual[kidx].status = "IN ERROR"
         SET data_rec->qual[kidx].stat_msg = concat(trim(data_rec->qual[kidx].stat_msg),"[p]")
        ENDIF
       ENDIF
       IF ((data_rec->qual[kidx].status="IN ERROR"))
        SET data_rec->qual[kidx].contrib_idx = - (1)
        SET irowknterror = (irowknterror+ 1)
       ENDIF
       IF ((data_rec->qual[kidx].contrib_idx > 0))
        IF ((data_rec->qual[kidx].primary_ind=1))
         SET pos = 0
         SET pos = locateval(num,1,oa_rec->qual_knt,data_rec->qual[kidx].provdir_link_alias,oa_rec->
          qual[num].provdir_link_alias,
          data_rec->qual[kidx].provdir_link_alias,oa_rec->qual[num].alias,"ORGLNKUUID",oa_rec->qual[
          num].alias_type)
         IF (pos < 1)
          SET oa_rec->qual_knt = (oa_rec->qual_knt+ 1)
          SET stat = alterlist(oa_rec->qual,oa_rec->qual_knt)
          SET oa_rec->qual[oa_rec->qual_knt].data_rec_idx = kidx
          SET oa_rec->qual[oa_rec->qual_knt].action_flag = iinsert
          SET oa_rec->qual[oa_rec->qual_knt].provdir_link_alias = data_rec->qual[kidx].
          provdir_link_alias
          SET oa_rec->qual[oa_rec->qual_knt].alias = data_rec->qual[kidx].provdir_link_alias
          SET oa_rec->qual[oa_rec->qual_knt].alias_key = cnvtupper(data_rec->qual[kidx].
           provdir_link_alias)
          SET oa_rec->qual[oa_rec->qual_knt].alias_type = "ORGLNKUUID"
          SET oa_rec->qual[oa_rec->qual_knt].alias_pool_cd = contrib_rec->list[data_rec->qual[kidx].
          contrib_idx].orglnkuuid_pool_cd
          SET oa_rec->qual[oa_rec->qual_knt].org_alias_type_cd = contrib_rec->list[data_rec->qual[
          kidx].contrib_idx].orglnkuuid_type_cd
         ENDIF
        ENDIF
        IF ((data_rec->qual[kidx].ext_alias > " "))
         SET pos = 0
         SET pos = locateval(num,1,oa_rec->qual_knt,data_rec->qual[kidx].provdir_link_alias,oa_rec->
          qual[num].provdir_link_alias,
          data_rec->qual[kidx].ext_alias,oa_rec->qual[num].alias,"ORGEXTALIAS",oa_rec->qual[num].
          alias_type)
         IF (pos < 1)
          SET oa_rec->qual_knt = (oa_rec->qual_knt+ 1)
          SET stat = alterlist(oa_rec->qual,oa_rec->qual_knt)
          SET oa_rec->qual[oa_rec->qual_knt].data_rec_idx = kidx
          SET oa_rec->qual[oa_rec->qual_knt].action_flag = iinsert
          SET oa_rec->qual[oa_rec->qual_knt].provdir_link_alias = data_rec->qual[kidx].
          provdir_link_alias
          SET oa_rec->qual[oa_rec->qual_knt].alias = data_rec->qual[kidx].ext_alias
          SET oa_rec->qual[oa_rec->qual_knt].alias_key = cnvtupper(data_rec->qual[kidx].ext_alias)
          SET oa_rec->qual[oa_rec->qual_knt].alias_type = "ORGEXTALIAS"
          SET oa_rec->qual[oa_rec->qual_knt].alias_pool_cd = contrib_rec->list[data_rec->qual[kidx].
          contrib_idx].ext_alias_pool_cd
          SET oa_rec->qual[oa_rec->qual_knt].org_alias_type_cd = contrib_rec->list[data_rec->qual[
          kidx].contrib_idx].ext_alias_type_cd
         ENDIF
        ENDIF
        IF ((data_rec->qual[kidx].alt_alias1 > " ")
         AND (data_rec->qual[kidx].alt1_idx > 0))
         SET pos = 0
         SET pos = locateval(num,1,oa_rec->qual_knt,data_rec->qual[kidx].provdir_link_alias,oa_rec->
          qual[num].provdir_link_alias,
          data_rec->qual[kidx].alt_alias1,oa_rec->qual[num].alias,"ORGALTALIAS",oa_rec->qual[num].
          alias_type)
         IF (pos < 1)
          SET oa_rec->qual_knt = (oa_rec->qual_knt+ 1)
          SET stat = alterlist(oa_rec->qual,oa_rec->qual_knt)
          SET oa_rec->qual[oa_rec->qual_knt].data_rec_idx = kidx
          SET oa_rec->qual[oa_rec->qual_knt].action_flag = iinsert
          SET oa_rec->qual[oa_rec->qual_knt].provdir_link_alias = data_rec->qual[kidx].
          provdir_link_alias
          SET oa_rec->qual[oa_rec->qual_knt].alias = data_rec->qual[kidx].alt_alias1
          SET oa_rec->qual[oa_rec->qual_knt].alias_key = cnvtupper(data_rec->qual[kidx].alt_alias1)
          SET oa_rec->qual[oa_rec->qual_knt].alias_type = "ORGALTALIAS"
          SET oa_rec->qual[oa_rec->qual_knt].alias_pool_cd = alt_rec->qual[data_rec->qual[kidx].
          alt1_idx].alt_alias_pool_cd
          SET oa_rec->qual[oa_rec->qual_knt].org_alias_type_cd = alt_rec->qual[data_rec->qual[kidx].
          alt1_idx].alt_alias_type_cd
         ENDIF
        ENDIF
        IF ((data_rec->qual[kidx].alt_alias2 > " ")
         AND (data_rec->qual[kidx].alt2_idx > 0))
         SET pos = 0
         SET pos = locateval(num,1,oa_rec->qual_knt,data_rec->qual[kidx].provdir_link_alias,oa_rec->
          qual[num].provdir_link_alias,
          data_rec->qual[kidx].alt_alias2,oa_rec->qual[num].alias,"ORGALTALIAS",oa_rec->qual[num].
          alias_type)
         IF (pos < 1)
          SET oa_rec->qual_knt = (oa_rec->qual_knt+ 1)
          SET stat = alterlist(oa_rec->qual,oa_rec->qual_knt)
          SET oa_rec->qual[oa_rec->qual_knt].data_rec_idx = kidx
          SET oa_rec->qual[oa_rec->qual_knt].action_flag = iinsert
          SET oa_rec->qual[oa_rec->qual_knt].provdir_link_alias = data_rec->qual[kidx].
          provdir_link_alias
          SET oa_rec->qual[oa_rec->qual_knt].alias = data_rec->qual[kidx].alt_alias2
          SET oa_rec->qual[oa_rec->qual_knt].alias_key = cnvtupper(data_rec->qual[kidx].alt_alias2)
          SET oa_rec->qual[oa_rec->qual_knt].alias_type = "ORGALTALIAS"
          SET oa_rec->qual[oa_rec->qual_knt].alias_pool_cd = alt_rec->qual[data_rec->qual[kidx].
          alt2_idx].alt_alias_pool_cd
          SET oa_rec->qual[oa_rec->qual_knt].org_alias_type_cd = alt_rec->qual[data_rec->qual[kidx].
          alt2_idx].alt_alias_type_cd
         ENDIF
        ENDIF
        IF ((data_rec->qual[kidx].alt_alias3 > " ")
         AND (data_rec->qual[kidx].alt3_idx > 0))
         SET pos = 0
         SET pos = locateval(num,1,oa_rec->qual_knt,data_rec->qual[kidx].provdir_link_alias,oa_rec->
          qual[num].provdir_link_alias,
          data_rec->qual[kidx].alt_alias3,oa_rec->qual[num].alias,"ORGALTALIAS",oa_rec->qual[num].
          alias_type)
         IF (pos < 1)
          SET oa_rec->qual_knt = (oa_rec->qual_knt+ 1)
          SET stat = alterlist(oa_rec->qual,oa_rec->qual_knt)
          SET oa_rec->qual[oa_rec->qual_knt].data_rec_idx = kidx
          SET oa_rec->qual[oa_rec->qual_knt].provdir_link_alias = data_rec->qual[kidx].
          provdir_link_alias
          SET oa_rec->qual[oa_rec->qual_knt].alias = data_rec->qual[kidx].alt_alias3
          SET oa_rec->qual[oa_rec->qual_knt].alias_key = cnvtupper(data_rec->qual[kidx].alt_alias3)
          SET oa_rec->qual[oa_rec->qual_knt].alias_type = "ORGALTALIAS"
          SET oa_rec->qual[oa_rec->qual_knt].alias_pool_cd = alt_rec->qual[data_rec->qual[kidx].
          alt3_idx].alt_alias_pool_cd
          SET oa_rec->qual[oa_rec->qual_knt].org_alias_type_cd = alt_rec->qual[data_rec->qual[kidx].
          alt3_idx].alt_alias_type_cd
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     CALL echo("***")
     CALL echo("***   Does Org Exist")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM organization_alias a,
       organization o,
       location l,
       (dummyt d  WITH seq = value(wlist->qual_knt))
      PLAN (d
       WHERE (wlist->qual[d.seq].contrib_idx > 0)
        AND (wlist->qual[d.seq].org_id < 1))
       JOIN (a
       WHERE (a.alias=wlist->qual[d.seq].ext_alias)
        AND (a.alias_pool_cd=contrib_rec->list[wlist->qual[d.seq].contrib_idx].ext_alias_pool_cd)
        AND (a.org_alias_type_cd=contrib_rec->list[wlist->qual[d.seq].contrib_idx].ext_alias_type_cd)
        AND a.active_ind=1)
       JOIN (o
       WHERE o.organization_id=a.organization_id)
       JOIN (l
       WHERE l.organization_id=outerjoin(o.organization_id))
      ORDER BY d.seq
      FOOT  d.seq
       IF (a.organization_id > 0)
        wlist->qual[d.seq].org_id = a.organization_id
        IF ((o.org_name != wlist->qual[d.seq].name))
         wlist->qual[d.seq].org_action_flag = iupdate
        ELSE
         wlist->qual[d.seq].org_action_flag = inoaction
        ENDIF
       ENDIF
       IF (l.location_cd > 0)
        wlist->qual[d.seq].location_cd = l.location_cd
        IF ((o.org_name != wlist->qual[d.seq].name))
         wlist->qual[d.seq].location_action_flag = iupdate
        ELSE
         wlist->qual[d.seq].location_action_flag = inoaction
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "ORGANIZATION_ALIAS"
      SET ilog_status = ifailure
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("Check EXT_ALIAS :: Select Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM organization_alias a,
       organization o,
       location l,
       (dummyt d  WITH seq = value(wlist->qual_knt))
      PLAN (d
       WHERE (wlist->qual[d.seq].contrib_idx > 0)
        AND (wlist->qual[d.seq].org_id < 1))
       JOIN (a
       WHERE (a.alias=wlist->qual[d.seq].provdir_link_alias)
        AND (a.alias_pool_cd=contrib_rec->list[wlist->qual[d.seq].contrib_idx].orglnkuuid_pool_cd)
        AND (a.org_alias_type_cd=contrib_rec->list[wlist->qual[d.seq].contrib_idx].orglnkuuid_type_cd
       )
        AND a.active_ind=1)
       JOIN (o
       WHERE o.organization_id=a.organization_id)
       JOIN (l
       WHERE l.organization_id=outerjoin(o.organization_id))
      ORDER BY d.seq
      FOOT  d.seq
       IF (a.organization_id > 0)
        wlist->qual[d.seq].org_id = a.organization_id
        IF ((o.org_name != wlist->qual[d.seq].name))
         wlist->qual[d.seq].org_action_flag = iupdate
        ELSE
         wlist->qual[d.seq].org_action_flag = inoaction
        ENDIF
       ENDIF
       IF (l.location_cd > 0)
        wlist->qual[d.seq].location_cd = l.location_cd
        IF ((o.org_name != wlist->qual[d.seq].name))
         wlist->qual[d.seq].location_action_flag = iupdate
        ELSE
         wlist->qual[d.seq].location_action_flag = inoaction
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "ORGANIZATION_ALIAS"
      SET ilog_status = ifailure
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("Check PLA :: Select Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Does LOCATION_CD Exist")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM code_value_alias c,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      PLAN (d
       WHERE (data_rec->qual[d.seq].old_location_cd < 1)
        AND (data_rec->qual[d.seq].contrib_idx > 0))
       JOIN (c
       WHERE operator(c.alias,"LIKE",patstring(concat(trim(data_rec->qual[d.seq].ext_alias),trim(
           contrib_rec->list[data_rec->qual[d.seq].contrib_idx].loc_cva_alias_stamp),"*"),1))
        AND ((c.code_set+ 0)=220)
        AND ((c.contributor_source_cd+ 0)=contrib_rec->list[data_rec->qual[d.seq].contrib_idx].
       contributor_source_cd)
        AND c.alias_type_meaning="ORGEXTALIAS")
      HEAD d.seq
       data_rec->qual[d.seq].old_location_cd = c.code_value
       IF ((data_rec->qual[d.seq].primary_ind=1)
        AND (wlist->qual[data_rec->qual[d.seq].wlist_idx].location_cd < 1))
        wlist->qual[data_rec->qual[d.seq].wlist_idx].location_cd = c.code_value, wlist->qual[data_rec
        ->qual[d.seq].wlist_idx].location_action_flag = iupdate
       ENDIF
       IF ((wlist->qual[data_rec->qual[d.seq].wlist_idx].location_cd > 0)
        AND (wlist->qual[data_rec->qual[d.seq].wlist_idx].location_cd=data_rec->qual[d.seq].
       old_location_cd))
        data_rec->qual[d.seq].old_location_cd = 0.0
       ENDIF
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "GET LOCATION BY CVA1"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("GET LOCATION BY CVA1 :: Select Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echorecord(wlist)
     CALL echo("***")
     CALL echo("***   Get Old ORG_ID Values")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM organization_alias a,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      PLAN (d
       WHERE (data_rec->qual[d.seq].contrib_idx > 0)
        AND (data_rec->qual[d.seq].old_org_id < 1))
       JOIN (a
       WHERE (a.alias=data_rec->qual[d.seq].ext_alias)
        AND (a.alias_pool_cd=contrib_rec->list[data_rec->qual[d.seq].contrib_idx].ext_alias_pool_cd)
        AND (a.org_alias_type_cd=contrib_rec->list[data_rec->qual[d.seq].contrib_idx].
       ext_alias_type_cd)
        AND a.active_ind=1)
      ORDER BY d.seq
      FOOT  d.seq
       IF (a.organization_id > 0
        AND (wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id != a.organization_id))
        data_rec->qual[d.seq].old_org_id = a.organization_id
       ENDIF
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "ORGANIZATION_ALIAS"
      SET ilog_status = ifailure
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("Check OLD ORG_ID :: Select Error :: ",trim(serrmsg)
       )
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echorecord(data_rec)
     CALL echo("***")
     CALL echo("***   Create ID values for new items")
     CALL echo("***")
     FOR (midx = 1 TO data_rec->qual_knt)
       IF ((wlist->qual[data_rec->qual[midx].wlist_idx].org_id < 1))
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        SELECT INTO "nl:"
         y = seq(organization_seq,nextval)
         FROM dual
         DETAIL
          wlist->qual[data_rec->qual[midx].wlist_idx].org_id = cnvtreal(y)
         WITH nocounter
        ;end select
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = gen_nbr_error
         SET table_name = "GET NEW ORG ID"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("GET NEW ORG ID :: Select Error :: ",trim(serrmsg
           ))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        SET wlist->qual[data_rec->qual[midx].wlist_idx].org_action_flag = iinsert
       ENDIF
       IF ((wlist->qual[data_rec->qual[midx].wlist_idx].location_cd < 1))
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        SELECT INTO "nl:"
         y = seq(reference_seq,nextval)
         FROM dual
         DETAIL
          wlist->qual[data_rec->qual[midx].wlist_idx].location_cd = cnvtreal(y)
         WITH nocounter
        ;end select
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = gen_nbr_error
         SET table_name = "GET NEW LOC_CD"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("GET NEW LOC_CD :: Select Error :: ",trim(serrmsg
           ))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        SET wlist->qual[data_rec->qual[midx].wlist_idx].location_action_flag = iinsert
       ENDIF
       IF ((data_rec->qual[midx].address_id < 1)
        AND (data_rec->qual[midx].address_action_flag != idelete))
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        SELECT INTO "nl:"
         y = seq(address_seq,nextval)
         FROM dual
         DETAIL
          data_rec->qual[midx].address_id = cnvtreal(y)
         WITH nocounter
        ;end select
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = gen_nbr_error
         SET table_name = "GET NEW ADDRESS_ID"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("GET NEW ADDRESS_ID :: Select Error :: ",trim(
           serrmsg))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        SET data_rec->qual[midx].address_action_flag = iinsert
       ENDIF
       IF ((data_rec->qual[midx].bus_phone_id < 1)
        AND (data_rec->qual[midx].phone_action_flag != idelete))
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        SELECT INTO "nl:"
         y = seq(phone_seq,nextval)
         FROM dual
         DETAIL
          data_rec->qual[midx].bus_phone_id = cnvtreal(y)
         WITH nocounter
        ;end select
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = gen_nbr_error
         SET table_name = "GET NEW PHONE1_ID"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("GET NEW PHONE1_ID :: Select Error :: ",trim(
           serrmsg))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        SET data_rec->qual[midx].phone_action_flag = iinsert
       ENDIF
       IF ((data_rec->qual[midx].fax_phone_id < 1)
        AND (data_rec->qual[midx].fax_action_flag != idelete))
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        SELECT INTO "nl:"
         y = seq(phone_seq,nextval)
         FROM dual
         DETAIL
          data_rec->qual[midx].fax_phone_id = cnvtreal(y)
         WITH nocounter
        ;end select
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = gen_nbr_error
         SET table_name = "GET NEW FAX_ID"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("GET NEW FAX_ID :: Select Error :: ",trim(serrmsg
           ))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        SET data_rec->qual[midx].fax_action_flag = iinsert
       ENDIF
     ENDFOR
     CALL echo("***")
     CALL echo("***   Handle ORGANIZATION")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM organization o,
       (dummyt d  WITH seq = value(wlist->qual_knt))
      SET o.organization_id = wlist->qual[d.seq].org_id, o.contributor_system_cd = contrib_rec->list[
       wlist->qual[d.seq].contrib_idx].contributor_system_cd, o.org_name = wlist->qual[d.seq].name,
       o.org_name_key = trim(cnvtupper(cnvtalphanum(wlist->qual[d.seq].name))), o.federal_tax_id_nbr
        = "", o.org_status_cd = 0,
       o.ft_entity_id = 0, o.ft_entity_name = "", o.org_class_cd = dorgclasscd,
       o.data_status_cd = dauthdatastatuscd, o.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), o
       .data_status_prsnl_id = contrib_rec->list[wlist->qual[d.seq].contrib_idx].
       contributor_system_cd,
       o.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), o.end_effective_dt_tm = cnvtdatetime(
        dates->end_dt_tm), o.active_ind = 1,
       o.active_status_cd = dactivestatuscd, o.active_status_prsnl_id = contrib_rec->list[wlist->
       qual[d.seq].contrib_idx].prsnl_person_id, o.active_status_dt_tm = cnvtdatetime(dates->
        now_dt_tm),
       o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id = contrib_rec->list[
       wlist->qual[d.seq].contrib_idx].prsnl_person_id,
       o.updt_applctx = iappnumber, o.updt_task = iappnumber
      PLAN (d
       WHERE (wlist->qual[d.seq].org_action_flag=iinsert)
        AND (wlist->qual[d.seq].org_id > 0)
        AND (wlist->qual[d.seq].contrib_idx > 0))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ORGANIZATION"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW ORG :: Insert Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM organization o,
       (dummyt d  WITH seq = value(wlist->qual_knt))
      SET o.org_name = wlist->qual[d.seq].name, o.org_name_key = trim(cnvtupper(cnvtalphanum(wlist->
          qual[d.seq].name))), o.updt_cnt = (o.updt_cnt+ 1)
      PLAN (d
       WHERE (wlist->qual[d.seq].org_action_flag=iupdate)
        AND (wlist->qual[d.seq].org_id > 0)
        AND (wlist->qual[d.seq].contrib_idx > 0))
       JOIN (o
       WHERE (o.organization_id=wlist->qual[d.seq].org_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "ORGANIZATION"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE ORG :: Update Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Handle ORG_TYPE_RELTN")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM org_type_reltn o,
       (dummyt d  WITH seq = value(wlist->qual_knt))
      SET o.seq = 1
      PLAN (d
       WHERE (wlist->qual[d.seq].org_id > 0)
        AND (wlist->qual[d.seq].contrib_idx > 0))
       JOIN (o
       WHERE (o.organization_id=wlist->qual[d.seq].org_id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = delete_error
      SET table_name = "ORG_TYPE_RELTN"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("DELETE ORG_TYPE_RELTN-1 :: Delete Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM org_type_reltn o,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET o.seq = 1
      PLAN (d
       WHERE (data_rec->qual[d.seq].old_org_id > 0)
        AND (data_rec->qual[d.seq].contrib_idx > 0))
       JOIN (o
       WHERE (o.organization_id=data_rec->qual[d.seq].old_org_id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = delete_error
      SET table_name = "ORG_TYPE_RELTN"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("DELETE ORG_TYPE_RELTN-2 :: Delete Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM org_type_reltn o,
       (dummyt d  WITH seq = value(wlist->qual_knt))
      SET o.organization_id = wlist->qual[d.seq].org_id, o.org_type_cd = dclientorgtypecd, o.updt_cnt
        = 0,
       o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id = contrib_rec->list[wlist->qual[d.seq
       ].contrib_idx].prsnl_person_id, o.updt_task = iappnumber,
       o.updt_applctx = iappnumber, o.active_ind = 1, o.active_status_cd = dactivestatuscd,
       o.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id = contrib_rec
       ->list[wlist->qual[d.seq].contrib_idx].prsnl_person_id, o.beg_effective_dt_tm = cnvtdatetime(
        dates->now_dt_tm),
       o.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm)
      PLAN (d
       WHERE (wlist->qual[d.seq].org_id > 0)
        AND (wlist->qual[d.seq].contrib_idx > 0))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ORG_TYPE_RELTN"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD CLIENT ORG_TYPE_RELTN :: Insert Error :: ",trim
       (serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM org_type_reltn o,
       (dummyt d  WITH seq = value(wlist->qual_knt))
      SET o.organization_id = wlist->qual[d.seq].org_id, o.org_type_cd = dfacilityorgtypecd, o
       .updt_cnt = 0,
       o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id = contrib_rec->list[wlist->qual[d.seq
       ].contrib_idx].prsnl_person_id, o.updt_task = iappnumber,
       o.updt_applctx = iappnumber, o.active_ind = 1, o.active_status_cd = dactivestatuscd,
       o.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id = contrib_rec
       ->list[wlist->qual[d.seq].contrib_idx].prsnl_person_id, o.beg_effective_dt_tm = cnvtdatetime(
        dates->now_dt_tm),
       o.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm)
      PLAN (d
       WHERE (wlist->qual[d.seq].org_id > 0)
        AND (wlist->qual[d.seq].contrib_idx > 0))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ORG_TYPE_RELTN"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD FACILITY ORG_TYPE_RELTN :: Insert Error :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Handle Location")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM code_value c,
       (dummyt d  WITH seq = value(wlist->qual_knt))
      SET c.code_value = wlist->qual[d.seq].location_cd, c.code_set = 220, c.cdf_meaning = "FACILITY",
       c.display = trim(substring(1,40,wlist->qual[d.seq].name)), c.display_key = trim(cnvtupper(
         cnvtalphanum(trim(substring(1,40,wlist->qual[d.seq].name))))), c.description = trim(
        substring(1,60,wlist->qual[d.seq].name)),
       c.definition = "", c.collation_seq = 0, c.active_type_cd = dactivestatuscd,
       c.active_ind = 1, c.active_dt_tm = cnvtdatetime(dates->now_dt_tm), c.inactive_dt_tm = null,
       c.active_status_prsnl_id = contrib_rec->list[wlist->qual[d.seq].contrib_idx].prsnl_person_id,
       c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
       c.updt_id = contrib_rec->list[wlist->qual[d.seq].contrib_idx].prsnl_person_id, c.updt_task =
       iappnumber, c.updt_applctx = iappnumber,
       c.active_ind = 1, c.begin_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), c
       .end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm),
       c.data_status_cd = dauthdatastatuscd, c.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), c
       .data_status_prsnl_id = contrib_rec->list[wlist->qual[d.seq].contrib_idx].prsnl_person_id
      PLAN (d
       WHERE (wlist->qual[d.seq].location_action_flag=iinsert)
        AND (wlist->qual[d.seq].location_cd > 0.0)
        AND (wlist->qual[d.seq].contrib_idx > 0))
       JOIN (c)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "CODE_VALUE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW LOCATION CODE_VALUE:: Insert Error :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM code_value c,
       (dummyt d  WITH seq = value(wlist->qual_knt))
      SET c.display = trim(substring(1,40,wlist->qual[d.seq].name)), c.display_key = trim(cnvtupper(
         cnvtalphanum(trim(substring(1,40,wlist->qual[d.seq].name))))), c.description = trim(
        substring(1,60,wlist->qual[d.seq].name)),
       c.updt_cnt = (c.updt_cnt+ 1)
      PLAN (d
       WHERE (wlist->qual[d.seq].location_action_flag=iupdate)
        AND (wlist->qual[d.seq].location_cd > 0.0)
        AND (wlist->qual[d.seq].contrib_idx > 0))
       JOIN (c
       WHERE (c.code_value=wlist->qual[d.seq].location_cd))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "CODE_VALUE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE LOCATION CODE_VALUE:: Update Error :: ",trim
       (serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM location l,
       (dummyt d  WITH seq = value(wlist->qual_knt))
      SET l.seq = 1
      PLAN (d
       WHERE (wlist->qual[d.seq].location_cd > 0.0)
        AND (wlist->qual[d.seq].contrib_idx > 0))
       JOIN (l
       WHERE (l.location_cd=wlist->qual[d.seq].location_cd))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = delete_error
      SET table_name = "LOCATION"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("DELETE LOCATION-1 :: Delete Error :: ",trim(serrmsg
        ))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM location l,
       (dummyt d  WITH seq = value(wlist->qual_knt))
      SET l.location_cd = wlist->qual[d.seq].location_cd, l.location_type_cd = dfacilityloctypecd, l
       .organization_id = wlist->qual[d.seq].org_id,
       l.resource_ind = 0, l.active_ind = 1, l.active_status_cd = dactivestatuscd,
       l.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), l.active_status_prsnl_id = contrib_rec
       ->list[wlist->qual[d.seq].contrib_idx].prsnl_person_id, l.beg_effective_dt_tm = cnvtdatetime(
        dates->now_dt_tm),
       l.census_ind = 0, l.contributor_system_cd = contrib_rec->list[wlist->qual[d.seq].contrib_idx].
       contributor_system_cd, l.data_status_cd = dauthdatastatuscd,
       l.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), l.data_status_prsnl_id = contrib_rec->
       list[wlist->qual[d.seq].contrib_idx].prsnl_person_id, l.end_effective_dt_tm = cnvtdatetime(
        dates->end_dt_tm),
       l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), l.updt_id = contrib_rec->list[
       wlist->qual[d.seq].contrib_idx].prsnl_person_id,
       l.updt_task = iappnumber, l.updt_applctx = iappnumber, l.facility_accn_prefix_cd = 0,
       l.discipline_type_cd = 0, l.view_type_cd = 0, l.patcare_node_ind = 1,
       l.exp_lvl_cd = 0, l.chart_format_id = 0
      PLAN (d
       WHERE (wlist->qual[d.seq].location_cd > 0.0)
        AND (wlist->qual[d.seq].contrib_idx > 0))
       JOIN (l)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "LOCATION"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW LOCATION :: Insert Error :: ",trim(serrmsg)
       )
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Handle Org Aliases")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM organization_alias a,
       (dummyt d  WITH seq = value(oa_rec->qual_knt))
      PLAN (d
       WHERE (wlist->qual[data_rec->qual[oa_rec->qual[d.seq].data_rec_idx].wlist_idx].org_id > 0)
        AND (data_rec->qual[oa_rec->qual[d.seq].data_rec_idx].contrib_idx > 0))
       JOIN (a
       WHERE a.organization_id=outerjoin(wlist->qual[data_rec->qual[oa_rec->qual[d.seq].data_rec_idx]
        .wlist_idx].org_id)
        AND a.alias=outerjoin(oa_rec->qual[d.seq].alias)
        AND a.alias_pool_cd=outerjoin(oa_rec->qual[d.seq].alias_pool_cd)
        AND a.org_alias_type_cd=outerjoin(oa_rec->qual[d.seq].org_alias_type_cd))
      DETAIL
       IF (a.organization_id > 0)
        oa_rec->qual[d.seq].action_flag = inoaction
       ENDIF
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = select_error
      SET table_name = "ORGANIZATION_ALIAS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("CHECK ORG_ALIAS EXISTANCE :: Select Error :: ",trim
       (serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echorecord(oa_rec)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM organization_alias o,
       (dummyt d  WITH seq = value(oa_rec->qual_knt))
      SET o.organization_alias_id = seq(organization_seq,nextval), o.organization_id = wlist->qual[
       data_rec->qual[oa_rec->qual[d.seq].data_rec_idx].wlist_idx].org_id, o.updt_cnt = 0,
       o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id = contrib_rec->list[data_rec->qual[
       oa_rec->qual[d.seq].data_rec_idx].contrib_idx].prsnl_person_id, o.updt_task = iappnumber,
       o.updt_applctx = iappnumber, o.active_ind = 1, o.active_status_cd = dactivestatuscd,
       o.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id = contrib_rec
       ->list[data_rec->qual[oa_rec->qual[d.seq].data_rec_idx].contrib_idx].prsnl_person_id, o
       .alias_pool_cd = oa_rec->qual[d.seq].alias_pool_cd,
       o.org_alias_type_cd = oa_rec->qual[d.seq].org_alias_type_cd, o.alias = oa_rec->qual[d.seq].
       alias, o.alias_key = oa_rec->qual[d.seq].alias_key,
       o.check_digit = 0, o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(dates->
        now_dt_tm),
       o.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm), o.data_status_cd = dauthdatastatuscd,
       o.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm),
       o.data_status_prsnl_id = contrib_rec->list[data_rec->qual[oa_rec->qual[d.seq].data_rec_idx].
       contrib_idx].prsnl_person_id, o.contributor_system_cd = contrib_rec->list[data_rec->qual[
       oa_rec->qual[d.seq].data_rec_idx].contrib_idx].contributor_system_cd
      PLAN (d
       WHERE (oa_rec->qual[d.seq].action_flag=iinsert)
        AND (wlist->qual[data_rec->qual[oa_rec->qual[d.seq].data_rec_idx].wlist_idx].org_id > 0)
        AND (data_rec->qual[oa_rec->qual[d.seq].data_rec_idx].contrib_idx > 0))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ORGANIZATION_ALIAS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW ORG ALIASES :: Insert Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Handle Address")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM address a,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET a.address_id = data_rec->qual[d.seq].address_id, a.parent_entity_name = "ORGANIZATION", a
       .parent_entity_id = wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id,
       a.address_type_cd = dworkaddrtypecd, a.address_type_seq =
       IF ((data_rec->qual[d.seq].primary_ind=1)) 0
       ELSE 99
       ENDIF
       , a.address_format_cd = 0,
       a.contact_name = "", a.residence_type_cd = 0, a.comment_txt = "",
       a.street_addr = data_rec->qual[d.seq].street_addr, a.street_addr2 = data_rec->qual[d.seq].
       street_addr2, a.city = data_rec->qual[d.seq].city,
       a.state = data_rec->qual[d.seq].state, a.zipcode = data_rec->qual[d.seq].zipcode, a
       .zip_code_group_cd = 0,
       a.postal_barcode_info = "", a.county = data_rec->qual[d.seq].county, a.country = data_rec->
       qual[d.seq].country,
       a.residence_cd = 0, a.mail_stop = "", a.beg_effective_mm_dd = 0,
       a.end_effective_mm_dd = 0, a.contributor_system_cd = contrib_rec->list[data_rec->qual[d.seq].
       contrib_idx].contributor_system_cd, a.data_status_cd = dauthdatastatuscd,
       a.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), a.data_status_prsnl_id = contrib_rec->
       list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id, a.beg_effective_dt_tm = cnvtdatetime(
        dates->now_dt_tm),
       a.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm), a.active_ind = 1, a.active_status_cd
        = dactivestatuscd,
       a.active_status_prsnl_id = contrib_rec->list[data_rec->qual[d.seq].contrib_idx].
       prsnl_person_id, a.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), a.updt_cnt = 0,
       a.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), a.updt_id = contrib_rec->list[data_rec->qual[d
       .seq].contrib_idx].prsnl_person_id, a.updt_applctx = iappnumber,
       a.updt_task = iappnumber
      PLAN (d
       WHERE (data_rec->qual[d.seq].address_id > 0)
        AND (wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id > 0.0)
        AND (data_rec->qual[d.seq].contrib_idx > 0)
        AND (data_rec->qual[d.seq].address_action_flag=iinsert))
       JOIN (a)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ADDRESS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW ADDRESS :: Insert Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM address a,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET a.parent_entity_id = wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id, a
       .parent_entity_name = "ORGANIZATION", a.address_type_seq =
       IF ((data_rec->qual[d.seq].primary_ind=1)) 0
       ELSE 99
       ENDIF
       ,
       a.street_addr = data_rec->qual[d.seq].street_addr, a.street_addr2 = data_rec->qual[d.seq].
       street_addr2, a.city = data_rec->qual[d.seq].city,
       a.state = data_rec->qual[d.seq].state, a.zipcode = data_rec->qual[d.seq].zipcode, a.county =
       data_rec->qual[d.seq].county,
       a.country = data_rec->qual[d.seq].country, a.contributor_system_cd = contrib_rec->list[
       data_rec->qual[d.seq].contrib_idx].contributor_system_cd, a.beg_effective_dt_tm = cnvtdatetime
       (dates->now_dt_tm),
       a.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm), a.updt_cnt = (a.updt_cnt+ 1), a
       .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
       a.updt_id = contrib_rec->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id, a
       .updt_applctx = iappnumber, a.updt_task = iappnumber
      PLAN (d
       WHERE (data_rec->qual[d.seq].address_id > 0)
        AND (data_rec->qual[d.seq].contrib_idx > 0)
        AND (data_rec->qual[d.seq].address_action_flag=iupdate))
       JOIN (a
       WHERE (a.address_id=data_rec->qual[d.seq].address_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "ADDRESS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE ADDRESS :: Update Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM address a,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET a.seq = 1
      PLAN (d
       WHERE (data_rec->qual[d.seq].address_id > 0)
        AND (data_rec->qual[d.seq].contrib_idx > 0)
        AND (data_rec->qual[d.seq].address_action_flag=idelete))
       JOIN (a
       WHERE (a.address_id=data_rec->qual[d.seq].address_id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = delete_error
      SET table_name = "ADDRESS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("DELETE ADDRESS :: Delete Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Handle Phone")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM phone p,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET p.phone_id = data_rec->qual[d.seq].bus_phone_id, p.parent_entity_name = "ORGANIZATION", p
       .parent_entity_id = wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id,
       p.phone_type_cd = dworkphonetypecd, p.phone_type_seq =
       IF ((data_rec->qual[d.seq].primary_ind=1)) 0
       ELSE 99
       ENDIF
       , p.phone_format_cd = 0,
       p.phone_num = data_rec->qual[d.seq].phone_num, p.description = "", p.contact = "",
       p.call_instruction = "", p.modem_capability_cd = 0, p.extension = "",
       p.paging_code = "", p.beg_effective_mm_dd = 0, p.end_effective_mm_dd = 0,
       p.contributor_system_cd = contrib_rec->list[data_rec->qual[d.seq].contrib_idx].
       contributor_system_cd, p.data_status_cd = dauthdatastatuscd, p.data_status_dt_tm =
       cnvtdatetime(dates->now_dt_tm),
       p.data_status_prsnl_id = contrib_rec->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id,
       p.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), p.end_effective_dt_tm = cnvtdatetime(
        dates->end_dt_tm),
       p.active_ind = 1, p.active_status_cd = dactivestatuscd, p.active_status_prsnl_id = contrib_rec
       ->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id,
       p.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.updt_cnt = 0, p.updt_dt_tm =
       cnvtdatetime(dates->now_dt_tm),
       p.updt_id = contrib_rec->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id, p
       .updt_applctx = iappnumber, p.updt_task = iappnumber
      PLAN (d
       WHERE (data_rec->qual[d.seq].bus_phone_id > 0)
        AND (wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id > 0.0)
        AND (data_rec->qual[d.seq].contrib_idx > 0)
        AND (data_rec->qual[d.seq].phone_action_flag=iinsert))
       JOIN (p)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "PHONE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW PHONE1 :: Insert Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM phone p,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET p.parent_entity_id = wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id, p
       .parent_entity_name = "ORGANIZATION", p.phone_type_seq =
       IF ((data_rec->qual[d.seq].primary_ind=1)) 0
       ELSE 99
       ENDIF
       ,
       p.phone_num = data_rec->qual[d.seq].phone_num, p.contributor_system_cd = contrib_rec->list[
       data_rec->qual[d.seq].contrib_idx].contributor_system_cd, p.beg_effective_dt_tm = cnvtdatetime
       (dates->now_dt_tm),
       p.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm), p.updt_cnt = (p.updt_cnt+ 1), p
       .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
       p.updt_id = contrib_rec->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id, p
       .updt_applctx = iappnumber, p.updt_task = iappnumber
      PLAN (d
       WHERE (data_rec->qual[d.seq].bus_phone_id > 0)
        AND (data_rec->qual[d.seq].contrib_idx > 0)
        AND (data_rec->qual[d.seq].phone_action_flag=iupdate))
       JOIN (p
       WHERE (p.phone_id=data_rec->qual[d.seq].bus_phone_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "PHONE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE PHONE1 :: Update Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM phone p,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET p.seq = 1
      PLAN (d
       WHERE (data_rec->qual[d.seq].bus_phone_id > 0)
        AND (data_rec->qual[d.seq].contrib_idx > 0)
        AND (data_rec->qual[d.seq].phone_action_flag=idelete))
       JOIN (p
       WHERE (p.phone_id=data_rec->qual[d.seq].bus_phone_id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = delete_error
      SET table_name = "PHONE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("DELETE PHONE1 :: Delete Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM phone p,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET p.phone_id = data_rec->qual[d.seq].fax_phone_id, p.parent_entity_name = "ORGANIZATION", p
       .parent_entity_id = wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id,
       p.phone_type_cd = dworkfaxtypecd, p.phone_type_seq =
       IF ((data_rec->qual[d.seq].primary_ind=1)) 0
       ELSE 99
       ENDIF
       , p.phone_format_cd = 0,
       p.phone_num = data_rec->qual[d.seq].phone_num, p.description = "", p.contact = "",
       p.call_instruction = "", p.modem_capability_cd = 0, p.extension = "",
       p.paging_code = "", p.beg_effective_mm_dd = 0, p.end_effective_mm_dd = 0,
       p.contributor_system_cd = contrib_rec->list[data_rec->qual[d.seq].contrib_idx].
       contributor_system_cd, p.data_status_cd = dauthdatastatuscd, p.data_status_dt_tm =
       cnvtdatetime(dates->now_dt_tm),
       p.data_status_prsnl_id = contrib_rec->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id,
       p.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), p.end_effective_dt_tm = cnvtdatetime(
        dates->end_dt_tm),
       p.active_ind = 1, p.active_status_cd = dactivestatuscd, p.active_status_prsnl_id = contrib_rec
       ->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id,
       p.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.updt_cnt = 0, p.updt_dt_tm =
       cnvtdatetime(dates->now_dt_tm),
       p.updt_id = contrib_rec->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id, p
       .updt_applctx = iappnumber, p.updt_task = iappnumber
      PLAN (d
       WHERE (data_rec->qual[d.seq].fax_phone_id > 0)
        AND (wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id > 0.0)
        AND (data_rec->qual[d.seq].contrib_idx > 0)
        AND (data_rec->qual[d.seq].fax_action_flag=iinsert))
       JOIN (p)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "PHONE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW FAX :: Insert Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM phone p,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET p.parent_entity_id = wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id, p
       .parent_entity_name = "ORGANIZATION", p.phone_type_seq =
       IF ((data_rec->qual[d.seq].primary_ind=1)) 0
       ELSE 99
       ENDIF
       ,
       p.phone_num = data_rec->qual[d.seq].phone_num, p.contributor_system_cd = contrib_rec->list[
       data_rec->qual[d.seq].contrib_idx].contributor_system_cd, p.beg_effective_dt_tm = cnvtdatetime
       (dates->now_dt_tm),
       p.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm), p.updt_cnt = (p.updt_cnt+ 1), p
       .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
       p.updt_id = contrib_rec->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id, p
       .updt_applctx = iappnumber, p.updt_task = iappnumber
      PLAN (d
       WHERE (data_rec->qual[d.seq].fax_phone_id > 0)
        AND (data_rec->qual[d.seq].contrib_idx > 0)
        AND (data_rec->qual[d.seq].fax_action_flag=iupdate))
       JOIN (p
       WHERE (p.phone_id=data_rec->qual[d.seq].fax_phone_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "PHONE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE FAX :: Update Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM phone p,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET p.seq = 1
      PLAN (d
       WHERE (data_rec->qual[d.seq].fax_phone_id > 0)
        AND (data_rec->qual[d.seq].contrib_idx > 0)
        AND (data_rec->qual[d.seq].fax_action_flag=idelete))
       JOIN (p
       WHERE (p.phone_id=data_rec->qual[d.seq].fax_phone_id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = delete_error
      SET table_name = "PHONE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("DELETE FAX :: Delete Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM organization o,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET o.end_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id =
       contrib_rec->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id, o.updt_cnt = (o.updt_cnt
       + 1)
      PLAN (d
       WHERE (data_rec->qual[d.seq].old_org_id > 0)
        AND (data_rec->qual[d.seq].old_org_id != wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id)
       )
       JOIN (o
       WHERE (o.organization_id=data_rec->qual[d.seq].old_org_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "ORGANIZATION"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("INEFFECTIVE OLD ORGS :: Update Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM location o,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET o.end_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id =
       contrib_rec->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id, o.updt_cnt = (o.updt_cnt
       + 1)
      PLAN (d
       WHERE (data_rec->qual[d.seq].old_location_cd > 0)
        AND (data_rec->qual[d.seq].old_location_cd != wlist->qual[data_rec->qual[d.seq].wlist_idx].
       location_cd))
       JOIN (o
       WHERE (o.location_cd=data_rec->qual[d.seq].old_location_cd))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "LOCATION"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("INEFFECTIVE OLD LOCATION :: Update Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM code_value o,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET o.end_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id =
       contrib_rec->list[data_rec->qual[d.seq].contrib_idx].prsnl_person_id, o.updt_cnt = (o.updt_cnt
       + 1)
      PLAN (d
       WHERE (data_rec->qual[d.seq].old_location_cd > 0)
        AND (data_rec->qual[d.seq].old_location_cd != wlist->qual[data_rec->qual[d.seq].wlist_idx].
       location_cd))
       JOIN (o
       WHERE (o.code_value=data_rec->qual[d.seq].old_location_cd))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "CODE_VALUE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("INEFFECTIVE OLD CODE_VALUE :: Update Error :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Update AGS_ORG_DATA Status")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM ags_org_data o,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET o.status = "COMPLETE", o.stat_msg = "", o.status_dt_tm = cnvtdatetime(dates->now_dt_tm),
       o.organization_id = wlist->qual[data_rec->qual[d.seq].wlist_idx].org_id, o.location_cd = wlist
       ->qual[data_rec->qual[d.seq].wlist_idx].location_cd, o.address_id = data_rec->qual[d.seq].
       address_id,
       o.bus_phone_id = data_rec->qual[d.seq].bus_phone_id, o.fax_phone_id = data_rec->qual[d.seq].
       fax_phone_id, o.contributor_system_cd = contrib_rec->list[data_rec->qual[d.seq].contrib_idx].
       contributor_system_cd
      PLAN (d
       WHERE (data_rec->qual[d.seq].ags_org_data_id > 0)
        AND (data_rec->qual[d.seq].contrib_idx > 0))
       JOIN (o
       WHERE (o.ags_org_data_id=data_rec->qual[d.seq].ags_org_data_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "AGS_ORG_DATA"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE ORG_DATA COMPLETE :: Update Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM ags_org_data o,
       (dummyt d  WITH seq = value(data_rec->qual_knt))
      SET o.status = "IN ERROR", o.stat_msg = trim(substring(1,40,data_rec->qual[d.seq].stat_msg)), o
       .status_dt_tm = cnvtdatetime(dates->now_dt_tm),
       o.organization_id = 0.0, o.location_cd = 0.0, o.address_id = 0.0,
       o.bus_phone_id = 0.0, o.fax_phone_id = 0.0, o.contributor_system_cd = 0.0
      PLAN (d
       WHERE (data_rec->qual[d.seq].ags_org_data_id > 0)
        AND (data_rec->qual[d.seq].contrib_idx < 1))
       JOIN (o
       WHERE (o.ags_org_data_id=data_rec->qual[d.seq].ags_org_data_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "AGS_ORG_DATA"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE ORG_DATA IN ERROR :: Update Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ELSE
     ROLLBACK
     SET failed = input_error
     SET table_name = "GET CONTRIBUTOR SYSTEMS"
     SET ilog_status = ifailure
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg =
     "GET CONTRIBUTOR SYSTEMS :: Input Error :: contrib_rec->list_knt < 1 "
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
   ELSE
    ROLLBACK
    SET ilog_status = iwarning
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "WARNING"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = "No Provider Link Aliases Found"
    SET imaincontinue = false
   ENDIF
   IF ((( NOT (trim(sbeglinkalias,3) > " ")) OR (trim(sbeglinkalias,3)=null)) )
    SET imaincontinue = false
   ENDIF
   IF (sbeglinkalias=sendlinkalias)
    SET imaincontinue = false
   ENDIF
   CALL echo("***")
   CALL echo("***   Check for Kill")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM ags_task a
    PLAN (a
     WHERE a.ags_task_id=dworkingtaskid)
    DETAIL
     ikillind = a.kill_ind
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    ROLLBACK
    SET failed = select_error
    SET table_name = "AGS_TASK"
    SET ilog_status = ifailure
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("Check KILL_IND :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   IF (ikillind > 0)
    ROLLBACK
    SET failed = input_error
    SET table_name = "AGS_TASK"
    SET ilog_status = ifailure
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = "KILL_IND :: Greater Than 0"
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   COMMIT
 ENDWHILE
 CALL echo("***")
 CALL echo("***   Update Task")
 CALL echo("***")
 IF (irowknterror > 0)
  SET ilog_status = iwarning
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "WARNING"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "Some Rows not processed due to errors"
 ENDIF
 IF (ilog_status=iwarning)
  SET staskstatus = "WARNING"
 ELSEIF (ilog_status=ifailure)
  SET staskstatus = "IN ERROR"
 ELSE
  SET staskstatus = "COMPLETE"
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_task t
  SET t.status = staskstatus, t.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (t
   WHERE t.ags_task_id=dworkingtaskid)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = update_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("AGS_TASK :: Update Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (staskstatus="COMPLETE")
  SET job_complete = true
  SELECT INTO "nl:"
   FROM ags_task t
   WHERE t.ags_job_id=djobid
    AND t.status != "COMPLETE"
   DETAIL
    job_complete = false
   WITH nocounter
  ;end select
  IF (job_complete)
   UPDATE  FROM ags_job j
    SET j.status = "COMPLETE", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE j.ags_job_id=djobid
    WITH nocounter
   ;end update
  ENDIF
 ENDIF
 COMMIT
 CALL echo("***")
 CALL echo(build("***   sTaskStatus :",staskstatus))
 CALL echo("***")
 IF (staskstatus="COMPLETE"
  AND found_om_flag=true)
  EXECUTE gm_dm_info2388_def "U"
  DECLARE gm_u_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_dm_info2388_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  SUBROUTINE gm_u_dm_info2388_f8(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_number":
      IF (null_ind=1)
       SET gm_u_dm_info2388_req->info_numberf = 2
      ELSE
       SET gm_u_dm_info2388_req->info_numberf = 1
      ENDIF
      SET gm_u_dm_info2388_req->qual[iqual].info_number = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_numberw = 1
      ENDIF
     OF "info_long_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->info_long_idf = 1
      SET gm_u_dm_info2388_req->qual[iqual].info_long_id = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_long_idw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_dm_info2388_i4(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "updt_cnt":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->updt_cntf = 1
      SET gm_u_dm_info2388_req->qual[iqual].updt_cnt = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->updt_cntw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_dm_info2388_dq8(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_date":
      IF (null_ind=1)
       SET gm_u_dm_info2388_req->info_datef = 2
      ELSE
       SET gm_u_dm_info2388_req->info_datef = 1
      ENDIF
      SET gm_u_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_datew = 1
      ENDIF
     OF "updt_dt_tm":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->updt_dt_tmf = 1
      SET gm_u_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->updt_dt_tmw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_dm_info2388_vc(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_domain":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->info_domainf = 1
      SET gm_u_dm_info2388_req->qual[iqual].info_domain = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_domainw = 1
      ENDIF
     OF "info_name":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_dm_info2388_req->info_namef = 1
      SET gm_u_dm_info2388_req->qual[iqual].info_name = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_namew = 1
      ENDIF
     OF "info_char":
      IF (null_ind=1)
       SET gm_u_dm_info2388_req->info_charf = 2
      ELSE
       SET gm_u_dm_info2388_req->info_charf = 1
      ENDIF
      SET gm_u_dm_info2388_req->qual[iqual].info_char = ival
      IF (wq_ind=1)
       SET gm_u_dm_info2388_req->info_charw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SET gm_u_dm_info2388_req->allow_partial_ind = 1
  SET gm_u_dm_info2388_req->force_updt_ind = 1
  SET gm_u_dm_info2388_req->info_domainw = 1
  SET gm_u_dm_info2388_req->info_namew = 1
  SET gm_u_dm_info2388_req->info_datew = 0
  SET gm_u_dm_info2388_req->info_charw = 0
  SET gm_u_dm_info2388_req->info_numberw = 0
  SET gm_u_dm_info2388_req->info_long_idw = 0
  SET gm_u_dm_info2388_req->updt_applctxw = 0
  SET gm_u_dm_info2388_req->updt_dt_tmw = 0
  SET gm_u_dm_info2388_req->updt_cntw = 0
  SET gm_u_dm_info2388_req->updt_idw = 0
  SET gm_u_dm_info2388_req->updt_taskw = 0
  SET gm_u_dm_info2388_req->info_domainf = 0
  SET gm_u_dm_info2388_req->info_namef = 0
  SET gm_u_dm_info2388_req->info_datef = 0
  SET gm_u_dm_info2388_req->info_charf = 0
  SET gm_u_dm_info2388_req->info_numberf = 1
  SET gm_u_dm_info2388_req->info_long_idf = 0
  SET gm_u_dm_info2388_req->updt_cntf = 0
  SET stat = alterlist(gm_u_dm_info2388_req->qual,1)
  SET gm_u_dm_info2388_req->qual[1].info_domain = "AGS"
  SET gm_u_dm_info2388_req->qual[1].info_name = "ORG_MIGRATION"
  SET gm_u_dm_info2388_req->qual[1].info_number = 1
  EXECUTE gm_u_dm_info2388  WITH replace(request,gm_u_dm_info2388_req), replace(reply,
   gm_u_dm_info2388_rep)
  CALL echorecord(gm_u_dm_info2388_rep)
  IF ((gm_u_dm_info2388_rep->qual[1].error_num > 0))
   ROLLBACK
   SET failed = update_error
   SET table_name = "DM_INFO"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("DM_INFO :: Update Error :: ",trim(gm_u_dm_info2388_rep
     ->qual[1].error_msg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  FREE RECORD gm_u_dm_info2388_req
  FREE RECORD gm_u_dm_info2388_rep
 ELSEIF (staskstatus="COMPLETE"
  AND found_om_flag=false)
  EXECUTE gm_dm_info2388_def "I"
  DECLARE gm_i_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) = i2
  DECLARE gm_i_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
  DECLARE gm_i_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
  SUBROUTINE gm_i_dm_info2388_f8(icol_name,ival,iqual,null_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_number":
      SET gm_i_dm_info2388_req->qual[iqual].info_number = ival
      SET gm_i_dm_info2388_req->info_numberi = 1
     OF "info_long_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_dm_info2388_req->qual[iqual].info_long_id = ival
      SET gm_i_dm_info2388_req->info_long_idi = 1
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_i_dm_info2388_dq8(icol_name,ival,iqual,null_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_date":
      SET gm_i_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
      SET gm_i_dm_info2388_req->info_datei = 1
     OF "updt_dt_tm":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
      SET gm_i_dm_info2388_req->updt_dt_tmi = 1
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_i_dm_info2388_vc(icol_name,ival,iqual,null_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
     SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "info_domain":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_dm_info2388_req->qual[iqual].info_domain = ival
      SET gm_i_dm_info2388_req->info_domaini = 1
     OF "info_name":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_dm_info2388_req->qual[iqual].info_name = ival
      SET gm_i_dm_info2388_req->info_namei = 1
     OF "info_char":
      SET gm_i_dm_info2388_req->qual[iqual].info_char = ival
      SET gm_i_dm_info2388_req->info_chari = 1
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SET gm_i_dm_info2388_req->allow_partial_ind = 0
  SET gm_i_dm_info2388_req->info_domaini = 1
  SET gm_i_dm_info2388_req->info_namei = 1
  SET gm_i_dm_info2388_req->info_datei = 0
  SET gm_i_dm_info2388_req->info_chari = 0
  SET gm_i_dm_info2388_req->info_numberi = 1
  SET gm_i_dm_info2388_req->info_long_idi = 0
  SET gm_i_dm_info2388_req->info_daten = 1
  SET gm_i_dm_info2388_req->info_charn = 1
  SET gm_i_dm_info2388_req->info_numbern = 0
  SET stat = alterlist(gm_i_dm_info2388_req->qual,1)
  SET gm_i_dm_info2388_req->qual[1].info_domain = "AGS"
  SET gm_i_dm_info2388_req->qual[1].info_name = "ORG_MIGRATION"
  SET gm_i_dm_info2388_req->qual[1].info_number = 1
  EXECUTE gm_i_dm_info2388  WITH replace(request,gm_i_dm_info2388_req), replace(reply,
   gm_i_dm_info2388_rep)
  IF ((gm_i_dm_info2388_rep->qual[1].error_num > 0))
   SET failed = insert_error
   SET table_name = "DM_INFO"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("INSERT :: ErrMsg :: ",gm_i_dm_info2388_rep->qual[1].
    error_msg)
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  FREE RECORD gm_i_dm_info2388_req
  FREE RECORD gm_i_dm_info2388_rep
 ENDIF
 COMMIT
 SUBROUTINE turn_on_tracing(null)
   SET trace = echorecord
   SET trace = rdbprogram
   SET trace = srvuint
   SET trace = cost
   SET trace = callecho
   SET message = information
 END ;Subroutine
 SUBROUTINE turn_off_tracing(null)
   SET trace = noechorecord
   SET trace = nordbprogram
   SET trace = nosrvuint
   SET trace = nocost
   SET trace = nocallecho
   SET message = noinformation
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
      FOR (idx = 1 TO log->qual_knt)
        out_line = trim(substring(1,254,concat(format(log->qual[idx].smsgtype,"#######")," :: ",
           format(log->qual[idx].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[idx].
            smsg))))
        IF ((idx=log->qual_knt))
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
        IF ((idx != log->qual_knt))
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
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (failed != false)
  ROLLBACK
  CALL echo("***")
  CALL echo("***   failed != FALSE")
  CALL echo("***")
  IF (dworkingtaskid > 0)
   IF (irowknterror > 0)
    SET ilog_status = iwarning
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "WARNING"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = "Some Rows not processed due to errors"
   ENDIF
   IF (ilog_status=iwarning)
    SET staskstatus = "WARNING"
   ELSEIF (ilog_status=ifailure)
    SET staskstatus = "IN ERROR"
   ELSE
    SET staskstatus = "COMPLETE"
   ENDIF
   SET staskstatus = "IN ERROR"
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.status = staskstatus, t.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (t
     WHERE t.ags_task_id=dworkingtaskid)
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
    SET log->qual[log->qual_knt].smsg = concat("AGS_TASK :: Update Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   COMMIT
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(serrmsg)
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
  CALL echo("***")
  CALL echo("***   else (failed != FALSE)")
  CALL echo("***")
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_PVD_ORG_MIGRATION"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL echo("***")
  CALL echo("***   END LOGGING")
  CALL echo("***")
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 IF (iloglevel < 1)
  CALL turn_on_tracing(null)
 ENDIF
 CALL echo("***")
 CALL echo(concat("***   Processing of AGS_TASK_ID (",trim(cnvtstring(dworkingtaskid)),
   ") ended with a status of ",trim(staskstatus)))
 CALL echo("***")
 CALL echo("***")
 CALL echo("***   END: AGS_PVD_ORG_MIGRATION")
 CALL echo("***")
 SET script_ver = "004 09/08/06"
END GO
