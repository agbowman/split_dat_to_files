CREATE PROGRAM ags_meds_load:dba
 PROMPT
  "TASK_ID (0.0) = " = 0
  WITH dtask_id
 CALL echo("***")
 CALL echo("***   BEG AGS_MEDS_LOAD")
 CALL echo("***")
 EXECUTE si_srvrtl
 EXECUTE srvldaprtl
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
  DECLARE sstatus_file_name = vc WITH public, noconstant(concat("ags_meds_load_",format(cnvtdatetime(
      curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_MEDS_LOAD"
  SET define_logging_sub = true
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_MEDS_LOAD"
  CALL echo("***")
  CALL echo("***   Common Variables/Records Declared in calling program")
  CALL echo("***")
 ENDIF
 SET working_task_id =  $DTASK_ID
 DECLARE working_sending_system = vc WITH public, noconstant(" ")
 DECLARE working_mode = i2 WITH public, noconstant(0)
 DECLARE working_job_id = f8 WITH public, noconstant(0.0)
 DECLARE working_kill_ind = i2 WITH public, noconstant(0)
 DECLARE beg_data_id = f8 WITH public, noconstant(0.0)
 DECLARE end_data_id = f8 WITH public, noconstant(0.0)
 DECLARE max_data_id = f8 WITH public, noconstant(0.0)
 DECLARE data_size = i4 WITH public, noconstant(1000)
 DECLARE default_data_size = i4 WITH public, noconstant(1000)
 DECLARE data_knt = i4 WITH public, noconstant(0)
 DECLARE it_avg = i4 WITH public, noconstant(0)
 DECLARE working_timers = i4 WITH public, noconstant(0)
 FREE RECORD contrib_rec
 RECORD contrib_rec(
   1 qual_knt = i4
   1 qual[*]
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
     2 ssn_alias_pool_cd = f8
     2 ssn_alias_type_cd = f8
     2 prescriber_alias_pool_cd = f8
     2 prescriber_alias_type_cd = f8
     2 pharmacy_alias_pool_cd = f8
     2 pharmacy_alias_type_cd = f8
     2 pharmacy_alias_stamp = vc
     2 claim_alias_pool_cd = f8
     2 claim_alias_type_cd = f8
     2 payer_alias_pool_cd = f8
     2 payer_alias_type_cd = f8
     2 health_plan_alias_pool_cd = f8
     2 health_plan_alias_type_cd = f8
 )
 FREE RECORD dates
 RECORD dates(
   1 now_dt_tm = dq8
   1 end_dt_tm = dq8
   1 batch_start_dt_tm = dq8
   1 it_end_dt_tm = dq8
   1 it_est_end_dt_tm = dq8
 )
 FREE RECORD srvrec
 RECORD srvrec(
   1 hmessage = i4
   1 hreq = i4
   1 hreqstruct = i4
   1 hrep = i4
   1 hrepstruct = i4
   1 hldap = i4
   1 hattrs1 = i4
   1 hattrs2 = i4
 )
 FREE RECORD ldaprec
 RECORD ldaprec(
   1 enabled = i4
   1 name = vc
   1 password = vc
   1 ip = vc
   1 port = i4
   1 base = vc
   1 timeout = i4
 )
 RECORD ncpdprec(
   1 qual_cnt = i4
   1 qual[*]
     2 ncpdpid = vc
     2 pharmacy_identifier = vc
     2 pharmacy_name = vc
 )
 SET dates->now_dt_tm = cnvtdatetime(curdate,curtime3)
 SET dates->batch_start_dt_tm = cnvtdatetime(dates->now_dt_tm)
 SET dates->end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 DECLARE found_default_contrib_system = i2 WITH public, noconstant(false)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE pos = i4 WITH public, noconstant(0)
 DECLARE borg = i2 WITH public, noconstant(false)
 DECLARE lidx = i4 WITH public, noconstant(0)
 DECLARE lidx2 = i4 WITH public, noconstant(0)
 DECLARE lpos = i4 WITH public, noconstant(0)
 DECLARE lnum = i4 WITH public, noconstant(0)
 DECLARE lretval = i4 WITH public, noconstant(0)
 DECLARE esi_default_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",73,"Default"))
 DECLARE auth_data_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE active_active_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE inactive_active_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"INACTIVE"
   ))
 DECLARE male_sex_cd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"MALE"))
 DECLARE female_sex_cd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"FEMALE"))
 DECLARE cerner_chr_contributor_source_cd = f8 WITH public, constant(uar_get_code_by("MEANING",73,
   "CERNERCHR"))
 DECLARE ext_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "PRSNEXTALIAS"))
 DECLARE ssn_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PRSNSSN"))
 DECLARE prescriber_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "MEDPRESCIBER"))
 DECLARE claim_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "MEDCLMALIAS"))
 DECLARE pharmacy_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "MEDPHARMACY"))
 DECLARE payer_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "MEDPAYERORG"))
 DECLARE health_plan_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "MEDPLANALIAS"))
 DECLARE didentifiertypecd = f8 WITH public, constant(uar_get_code_by("MEANING",11000,"NDC"))
 DECLARE unknown_catalog_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "GENERICMEDICATION"))
 DECLARE ncpdp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",3576,"NCPDP"))
 DECLARE unknown_synonym_id = f8 WITH public, noconstant(0.0)
 DECLARE unknown_mnemonic_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE unknown_mnemonic = vc WITH public, noconstant(" ")
 DECLARE unknown_catalog_cki = vc WITH public, noconstant(" ")
 DECLARE unknown_synonym_cki = vc WITH public, noconstant(" ")
 DECLARE ngeneric = i2 WITH protect, constant(16)
 DECLARE nbrand = i2 WITH protect, constant(17)
 DECLARE nprod_level_generic = i2 WITH protect, constant(59)
 DECLARE nprod_level_brand = i2 WITH protect, constant(60)
 CALL echo("***")
 CALL echo("***   Log Starting Conditions")
 CALL echo("***")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("WORKING_TASK_ID :: ",trim(cnvtstring(working_task_id)))
 CALL echo("***")
 CALL echo(build("***   $dTASK_ID        :",working_task_id))
 CALL echo("***")
 IF (male_sex_cd < 1)
  SET failed = select_error
  SET table_name = "GET MALE_SEX_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "MALE_SEX_CD :: Select Error :: CODE_VALUE for CDF_MEANING MALE invalid from CODE_SET 57"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (female_sex_cd < 1)
  SET failed = select_error
  SET table_name = "GET FEMALE_SEX_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "FEMALE_SEX_CD :: Select Error :: CODE_VALUE for CDF_MEANING FEMALE invalid from CODE_SET 57"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (esi_default_cd < 1)
  SET failed = select_error
  SET table_name = "GET ESI_DEFAULT_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "ESI_DEFAULT_CD :: Select Error :: CODE_VALUE for display Default invalid from CODE_SET 73"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (ext_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET EXT_ALIAS_FIELD_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "EXT_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning PRSNEXTALIAS invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (ssn_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET SSN_ALIAS_FIELD_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "SSN_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning PRSNSSN invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (prescriber_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET PRESCRIBER_ALIAS_FIELD_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "PRESCRIBER_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning MEDPRESCIBER invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (pharmacy_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET PHARMACY_ALIAS_FIELD_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "PHARMACY_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning MEDPHARMACY invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (payer_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET PAYER_ALIAS_FIELD_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "PAYER_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning MEDPAYERORG invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (health_plan_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET HEALTH_PLAN_ALIAS_FIELD_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "HEALTH_PLAN_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning MEDPLANALIAS invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (cerner_chr_contributor_source_cd < 1)
  SET failed = select_error
  SET table_name = "GET CERNER_CHR_CONTRIBUTOR_SOURCE_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "CERNER_CHR_CONTRIBUTOR_SOURCE_CD :: Select Error :: CODE_VALUE for meaning CERNERCHR invalid from CODE_SET 73"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (didentifiertypecd < 1)
  SET failed = select_error
  SET table_name = "GET dIdentifierTypeCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dIdentifierTypeCd :: Select Error :: CODE_VALUE for meaning NDC invalid from CODE_SET 11000"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog c,
   order_catalog_synonym s
  PLAN (c
   WHERE c.catalog_cd=unknown_catalog_cd
    AND c.catalog_cd > 0)
   JOIN (s
   WHERE s.catalog_cd=unknown_catalog_cd)
  DETAIL
   unknown_synonym_id = s.synonym_id, unknown_mnemonic = s.mnemonic, unknown_mnemonic_type_cd = s
   .mnemonic_type_cd,
   unknown_catalog_cki = c.cki, unknown_synonym_cki = s.concept_cki
  WITH nocounter
 ;end select
 IF (unknown_synonym_id=0)
  SET failed = select_error
  SET table_name = "ORDER_CATALOG"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UNKNOWN_CATALOG_CD :: Select Error :: ORDER_CATALOG catalog_cd invalid for GENERICMEDICATION"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***   $unknown_catalog_cd        :",unknown_catalog_cd))
 CALL echo(build("***   $unknown_synonym_id        :",unknown_synonym_id))
 CALL echo("***")
 IF (working_task_id > 0)
  CALL echo("***")
  CALL echo("***   Update Task to Processing")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.status = "PROCESSING", t.status_dt_tm = cnvtdatetime(curdate,curtime3), t.batch_start_dt_tm
     = cnvtdatetime(dates->batch_start_dt_tm),
    t.batch_end_dt_tm = cnvtdatetime(dates->end_dt_tm)
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK PROCESSING"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("AGS_TASK PROCESSING :: Select Error :: ",trim(serrmsg)
    )
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  COMMIT
 ELSE
  SET failed = input_error
  SET table_name = "PARAMETER VALIDATION"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID TASK_ID :: Input Error :: ",trim(cnvtstring(
     working_task_id)))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Task Data")
 CALL echo("***")
 CALL echo(build("ags_task_id : ",working_task_id))
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ags_task t
  PLAN (t
   WHERE t.ags_task_id=working_task_id)
  HEAD REPORT
   beg_data_id = t.batch_start_id
   IF (t.iteration_start_id > 0)
    beg_data_id = t.iteration_start_id
   ENDIF
   max_data_id = t.batch_end_id, data_size = t.batch_size
   IF (data_size < 1)
    data_size = default_data_size
   ENDIF
   working_job_id = t.ags_job_id, working_mode = t.mode_flag, working_kill_ind = t.kill_ind,
   working_timers = t.timers_flag
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET TASK DATA"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET TASK DATA :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (curqual < 1)
  SET failed = input_error
  SET table_name = "GET TASK DATA"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET TASK DATA :: Input Error :: Invalid TASK_ID ",trim(
    cnvtstring(working_task_id)))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (working_kill_ind > 0)
  SET ilog_status = 2
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "GET TASK DATA :: KILL_IND Set to Kill"
  GO TO exit_script
 ENDIF
 IF (working_timers < 1)
  SET trace = nocallecho
 ELSE
  SET trace = callecho
 ENDIF
 SELECT INTO "nl:"
  d.*
  FROM dm_info d
  WHERE d.info_domain="RX_LDAP_CCL_CONFIG"
  DETAIL
   ldaprec->enabled = true
   CASE (d.info_name)
    OF "ldap_name":
     ldaprec->name = d.info_char
    OF "ldap_password":
     ldaprec->password = d.info_char
    OF "ldap_ip":
     ldaprec->ip = d.info_char
    OF "ldap_port":
     ldaprec->port = cnvtint(d.info_char)
    OF "ldap_base":
     ldaprec->base = d.info_char
    OF "ldap_timeout":
     ldaprec->timeout = cnvtint(d.info_char)
   ENDCASE
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DM_INFO"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (ldaprec->enabled)
  IF (working_timers > 1)
   CALL echorecord(ldaprec)
  ENDIF
  IF (create_srvhandles(0))
   CALL echo("Create_SrvHandles() was Successful.")
  ELSE
   SET failed = exe_error
   SET table_name = "Create_SrvHandles()"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "ErrMsg :: Create_SrvHandles() Failed!!"
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  SET srvrec->hldap = uar_ldapsecurebind(nullterm(ldaprec->name),nullterm(ldaprec->password),nullterm
   (ldaprec->ip),ldaprec->port)
  IF ((srvrec->hldap=0))
   CALL echo("uar_LDAPSecureBind() failed!")
   SET failed = exe_error
   SET table_name = "uar_LDAPSecureBind()"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "ErrMsg :: uar_LDAPSecureBind() Failed!!"
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  CALL uar_srvsetstring(srvrec->hreqstruct,"base",nullterm(ldaprec->base))
  CALL uar_srvsetshort(srvrec->hreqstruct,"scope",2)
  CALL uar_srvsetlong(srvrec->hreqstruct,"timeout",ldaprec->timeout)
  SET stat = uar_srvsetshort(srvrec->hreqstruct,"sizelimit",1)
  SET srvrec->hattrs1 = uar_srvadditem(srvrec->hreqstruct,"attrs")
  IF (srvrec->hattrs1)
   CALL uar_srvsetstring(srvrec->hattrs1,"str_value",nullterm("cernerOrganizationId"))
  ENDIF
  SET srvrec->hattrs2 = uar_srvadditem(srvrec->hreqstruct,"attrs")
  IF (srvrec->hattrs2)
   CALL uar_srvsetstring(srvrec->hattrs2,"str_value",nullterm("cernerOrganizationName"))
  ENDIF
  IF (working_timers > 1)
   CALL uar_sisrvdump(srvrec->hreq)
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_name="AGS_CREATE_ORGS")
   DETAIL
    IF (di.info_number > 0)
     borg = true
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(build("bOrg: ",borg))
 ENDIF
 CALL echo("***")
 CALL echo(build("***   beg_data_id    :",beg_data_id))
 CALL echo(build("***   max_data_id    :",max_data_id))
 CALL echo(build("***   data_size      :",data_size))
 CALL echo(build("***   working_job_id :",working_job_id))
 CALL echo(build("***   working_mode   :",working_mode))
 CALL echo("***")
 IF (beg_data_id < 1)
  SET failed = input_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG_DATA_ID :: Invalid Value :: Less Than 1"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Process Data")
 CALL echo("***")
 IF (((beg_data_id+ data_size) > max_data_id))
  SET end_data_id = max_data_id
 ELSE
  SET end_data_id = ((beg_data_id+ data_size) - 1)
 ENDIF
 IF (end_data_id < 1
  AND working_mode=3)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   max_id = max(p.ags_meds_data_id), dknt = count(p.ags_meds_data_id)
   FROM ags_meds_data p
   PLAN (p
    WHERE p.ags_meds_data_id >= beg_data_id
     AND p.status IN ("IN ERROR", "BACK OUT")
     AND p.gs_med_claim_id < 1)
   HEAD REPORT
    x = 1
   DETAIL
    x = 1
   FOOT REPORT
    max_data_id = max_id, data_knt = dknt
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "MODE 3 CHK"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("MODE 3 CHK :: Select Error :: ",trim(serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  IF (data_knt <= data_size)
   SET end_data_id = max_data_id
  ELSE
   SET end_data_id = ((beg_data_id+ data_size) - 1)
  ENDIF
  CALL echo("***")
  CALL echo("***   Update Task Batch End")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.batch_end_id = max_data_id
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK BATCH_END_ID"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("AGS_TASK BATCH_END_ID :: Select Error :: ",trim(
     serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 CALL echo("***")
 CALL echo(build("***   beg_data_id    :",beg_data_id))
 CALL echo(build("***   end_data_id    :",end_data_id))
 CALL echo(build("***   max_data_id    :",max_data_id))
 CALL echo(build("***   data_size      :",data_size))
 CALL echo(build("***   working_job_id :",working_job_id))
 CALL echo(build("***   working_mode   :",working_mode))
 CALL echo("***")
 WHILE (beg_data_id <= end_data_id
  AND working_kill_ind < 1)
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("BEG PROCESSING :: BEG_DATA_ID :: ",trim(cnvtstring(
      beg_data_id))," :: END_DATA_ID :: ",trim(cnvtstring(end_data_id))," :: MAX_DATA_ID :: ",
    trim(cnvtstring(max_data_id)))
   FREE RECORD hold
   RECORD hold(
     1 qual_knt = i4
     1 qual[*]
       2 contrib_idx = i4
       2 unable_to_do_ssn_check = i2
       2 ags_meds_data_id = f8
       2 run_nbr = f8
       2 run_dt_tm = dq8
       2 file_row_nbr = i4
       2 sex_cd = f8
       2 birth_dt_tm = dq8
       2 abs_birth_dt_tm = dq8
       2 gs_med_claim_id = f8
       2 gs_med_claim_alias_id = f8
       2 claim_identifier = vc
       2 prev_claim_identifier = vc
       2 person_id = f8
       2 catalog_cd = f8
       2 catalog_cki = vc
       2 product_synonym_id = f8
       2 product_synonym_cki = vc
       2 mnemonic = vc
       2 prescriber_id = f8
       2 prescriber_name = vc
       2 pharmacy_name = vc
       2 pharmacy_identifier = vc
       2 payer_id = f8
       2 health_plan_id = f8
       2 service_dt_tm = dq8
       2 action = vc
       2 ext_alias = vc
       2 ssn_alias = vc
       2 name_last = vc
       2 name_first = vc
       2 birth_date = vc
       2 gender = vc
       2 drug_code = vc
       2 product_description = vc
       2 service_date = vc
       2 dispense_qty = vc
       2 strength_qty = vc
       2 prescriber_ext_alias = vc
       2 pharmacy_ext_alias = vc
       2 payer_alias = vc
       2 health_plan_alias = vc
       2 refill_nbr = vc
       2 status = vc
       2 stat_msg = vc
   )
   CALL echo("***")
   CALL echo(build("***   beg_data_id    :",beg_data_id))
   CALL echo(build("***   end_data_id    :",end_data_id))
   CALL echo(build("***   working_job_id :",working_job_id))
   CALL echo("***")
   SET dates->now_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT
    IF (working_mode=0)
     PLAN (m
      WHERE m.ags_meds_data_id >= beg_data_id
       AND m.ags_meds_data_id <= end_data_id
       AND ((m.gs_med_claim_id+ 0) < 1)
       AND trim(m.status)="WAITING")
      JOIN (j
      WHERE j.ags_job_id=m.ags_job_id)
    ELSEIF (working_mode=1)
     PLAN (m
      WHERE m.ags_meds_data_id >= beg_data_id
       AND m.ags_meds_data_id <= end_data_id)
      JOIN (j
      WHERE j.ags_job_id=m.ags_job_id)
    ELSEIF (working_mode=2)
     PLAN (m
      WHERE m.ags_meds_data_id >= beg_data_id
       AND m.ags_meds_data_id <= end_data_id
       AND ((m.gs_med_claim_id+ 0) < 1))
      JOIN (j
      WHERE j.ags_job_id=m.ags_job_id)
    ELSE
     PLAN (m
      WHERE m.ags_meds_data_id >= beg_data_id
       AND m.ags_meds_data_id <= end_data_id
       AND ((m.gs_med_claim_id+ 0) < 1)
       AND trim(m.status) IN ("IN ERROR", "BACK OUT"))
      JOIN (j
      WHERE j.ags_job_id=m.ags_job_id)
    ENDIF
    INTO "nl:"
    FROM ags_meds_data m,
     ags_job j
    ORDER BY m.ags_meds_data_id
    HEAD REPORT
     idx = 0
    HEAD m.ags_meds_data_id
     num = 0, pos = 0, pos = locateval(num,1,hold->qual_knt,m.claim_identifier,hold->qual[num].
      claim_identifier)
     IF (pos <= 0)
      hold->qual_knt = (hold->qual_knt+ 1), stat = alterlist(hold->qual,hold->qual_knt), idx = hold->
      qual_knt
      IF ((contrib_rec->qual_knt > 0))
       IF (size(trim(m.sending_facility,2)) > 0)
        pos = 0, pos = locateval(num,1,contrib_rec->qual_knt,trim(m.sending_facility,3),contrib_rec->
         qual[num].sending_facility)
        IF (pos > 0)
         hold->qual[idx].contrib_idx = pos
        ELSE
         contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
          contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = m
         .sending_facility,
         hold->qual[idx].contrib_idx = contrib_rec->qual_knt
        ENDIF
       ELSEIF (size(trim(j.sending_system,3)) > 0)
        pos = 0, pos = locateval(num,1,contrib_rec->qual_knt,trim(j.sending_system,3),contrib_rec->
         qual[num].sending_facility)
        IF (pos > 0)
         hold->qual[idx].contrib_idx = pos
        ELSE
         contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
          contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(j
          .sending_system,3),
         hold->qual[idx].contrib_idx = contrib_rec->qual_knt
        ENDIF
       ELSE
        hold->qual[idx].contrib_idx = - (1), hold->qual[idx].status = "F", hold->qual[idx].stat_msg
         = concat(trim(hold->qual[idx].stat_msg),"[contrib]")
       ENDIF
      ELSE
       IF (size(trim(m.sending_facility,3)) > 0)
        contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
         contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(m
         .sending_facility,3),
        hold->qual[idx].contrib_idx = contrib_rec->qual_knt
       ELSEIF (size(trim(j.sending_system,3)) > 0)
        contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
         contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(j
         .sending_system,3),
        hold->qual[idx].contrib_idx = contrib_rec->qual_knt
       ELSE
        hold->qual[idx].contrib_idx = - (1), hold->qual[idx].status = "F", hold->qual[idx].stat_msg
         = concat(trim(hold->qual[idx].stat_msg),"[contrib]")
       ENDIF
      ENDIF
     ELSE
      idx = pos
     ENDIF
     hold->qual[idx].ags_meds_data_id = m.ags_meds_data_id, hold->qual[idx].person_id = m.person_id,
     hold->qual[idx].ext_alias = trim(m.ext_alias,3),
     hold->qual[idx].ssn_alias = trim(m.ssn_alias,3), hold->qual[idx].name_first = trim(m.name_first,
      3), hold->qual[idx].name_last = trim(m.name_last,3),
     hold->qual[idx].gender = trim(m.gender,3), hold->qual[idx].birth_date = trim(m.birth_date,3),
     hold->qual[idx].birth_dt_tm = cnvtdate2(trim(m.birth_date,3),"YYYYMMDD"),
     hold->qual[idx].action = trim(m.action,3), hold->qual[idx].gs_med_claim_id = m.gs_med_claim_id,
     hold->qual[idx].claim_identifier = trim(m.claim_identifier,3),
     hold->qual[idx].prev_claim_identifier = trim(m.prev_claim_identifier,3), hold->qual[idx].
     prescriber_id = m.prescriber_id, hold->qual[idx].prescriber_name = "",
     hold->qual[idx].pharmacy_name = "", hold->qual[idx].catalog_cd = 0, hold->qual[idx].catalog_cki
      = "",
     hold->qual[idx].product_synonym_id = 0, hold->qual[idx].product_synonym_cki = "", hold->qual[idx
     ].payer_id = 0,
     hold->qual[idx].health_plan_id = 0, hold->qual[idx].drug_code = trim(m.drug_code,3), hold->qual[
     idx].product_description = trim(m.product_description,3),
     hold->qual[idx].service_date = trim(m.service_date,3), hold->qual[idx].service_dt_tm = cnvtdate2
     (substring(1,8,m.service_date),"YYYYMMDD"), hold->qual[idx].dispense_qty = trim(m
      .dispense_qty_txt,3),
     hold->qual[idx].strength_qty = trim(m.strength_qty_txt,3), hold->qual[idx].prescriber_ext_alias
      = trim(m.prescriber_ext_alias,3), hold->qual[idx].pharmacy_ext_alias = trim(m
      .pharmacy_ext_alias,3),
     hold->qual[idx].payer_alias = trim(m.payer_alias,3), hold->qual[idx].health_plan_alias = trim(m
      .health_plan_alias,3), hold->qual[idx].refill_nbr = trim(m.refill_nbr_txt,3),
     hold->qual[idx].sex_cd =
     IF ((hold->qual[idx].gender="M")) male_sex_cd
     ELSEIF ((hold->qual[idx].gender="F")) female_sex_cd
     ELSE 0
     ENDIF
     IF ((hold->qual[idx].ssn_alias > " "))
      IF ((hold->qual[idx].name_first > " "))
       IF ((hold->qual[idx].name_last > " "))
        IF (size(trim(m.birth_date)) > 0)
         IF ((hold->qual[idx].sex_cd > 0))
          hold->qual[idx].contrib_idx = hold->qual[idx].contrib_idx
         ELSE
          hold->qual[idx].unable_to_do_ssn_check = true
         ENDIF
        ELSE
         hold->qual[idx].unable_to_do_ssn_check = true
        ENDIF
       ELSE
        hold->qual[idx].unable_to_do_ssn_check = true
       ENDIF
      ELSE
       hold->qual[idx].unable_to_do_ssn_check = true
      ENDIF
     ELSE
      hold->qual[idx].unable_to_do_ssn_check = true
     ENDIF
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "AGS_MEDS_DATA LOADING"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_MEDS_DATA LOADING :: Select Error :: ",trim(
      serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   IF ((hold->qual_knt > 0))
    IF ((contrib_rec->qual_knt < 1))
     SET failed = input_error
     SET table_name = "GET CONTRIBUTOR SYSTEMS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg =
     "GET CONTRIBUTOR SYSTEMS :: Input Error :: contrib_rec->qual_knt < 1"
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM code_value_alias cva,
      contributor_system cs,
      esi_alias_trans eat,
      (dummyt d  WITH seq = value(contrib_rec->qual_knt))
     PLAN (d
      WHERE (contrib_rec->qual[d.seq].contributor_system_cd < 1))
      JOIN (cva
      WHERE cva.code_set=89
       AND (cva.alias=contrib_rec->qual[d.seq].sending_facility)
       AND cva.contributor_source_cd=esi_default_cd)
      JOIN (cs
      WHERE cs.contributor_system_cd=cva.code_value
       AND cs.active_ind=1)
      JOIN (eat
      WHERE eat.contributor_system_cd=cs.contributor_system_cd
       AND eat.active_ind=1)
     HEAD cs.contributor_system_cd
      contrib_rec->qual[d.seq].sending_facility = cva.alias, contrib_rec->qual[d.seq].
      contributor_system_cd = cs.contributor_system_cd, contrib_rec->qual[d.seq].
      contributor_source_cd = cs.contributor_source_cd,
      contrib_rec->qual[d.seq].time_zone_flag = cs.time_zone_flag, contrib_rec->qual[d.seq].time_zone
       = cs.time_zone, contrib_rec->qual[d.seq].time_zone_idx = datetimezonebyname(contrib_rec->qual[
       d.seq].time_zone),
      contrib_rec->qual[d.seq].prsnl_person_id = cs.prsnl_person_id, contrib_rec->qual[d.seq].
      organization_id = cs.organization_id, found_ext_alias = false,
      found_ssn_alias = false, found_prescriber_alias = false, found_pharmacy_alias = false,
      found_claim_alias = false, found_payer_alias = false, found_health_plan_alias = false
     DETAIL
      IF (found_ext_alias=false
       AND eat.esi_alias_field_cd=ext_alias_field_cd)
       found_ext_alias = true, contrib_rec->qual[d.seq].ext_alias_pool_cd = eat.alias_pool_cd,
       contrib_rec->qual[d.seq].ext_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (found_ssn_alias=false
       AND eat.esi_alias_field_cd=ssn_alias_field_cd)
       found_ssn_alias = true, contrib_rec->qual[d.seq].ssn_alias_pool_cd = eat.alias_pool_cd,
       contrib_rec->qual[d.seq].ssn_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (found_prescriber_alias=false
       AND eat.esi_alias_field_cd=prescriber_alias_field_cd)
       found_prescriber_alias = true, contrib_rec->qual[d.seq].prescriber_alias_pool_cd = eat
       .alias_pool_cd, contrib_rec->qual[d.seq].prescriber_alias_type_cd = eat
       .alias_entity_alias_type_cd
      ENDIF
      IF (found_pharmacy_alias=false
       AND eat.esi_alias_field_cd=pharmacy_alias_field_cd)
       found_pharmacy_alias = true, contrib_rec->qual[d.seq].pharmacy_alias_pool_cd = eat
       .alias_pool_cd, contrib_rec->qual[d.seq].pharmacy_alias_type_cd = eat
       .alias_entity_alias_type_cd,
       contrib_rec->qual[d.seq].pharmacy_alias_stamp = concat("~",trim(cnvtupper(cnvtalphanum(
           uar_get_code_display(eat.alias_pool_cd)))),"~",trim(cnvtupper(cnvtalphanum(
           uar_get_code_display(eat.alias_entity_alias_type_cd)))))
      ENDIF
      IF (found_payer_alias=false
       AND eat.esi_alias_field_cd=payer_alias_field_cd)
       found_payer_alias = true, contrib_rec->qual[d.seq].payer_alias_pool_cd = eat.alias_pool_cd,
       contrib_rec->qual[d.seq].payer_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (found_health_plan_alias=false
       AND eat.esi_alias_field_cd=health_plan_alias_field_cd)
       found_health_plan_alias = true, contrib_rec->qual[d.seq].health_plan_alias_pool_cd = eat
       .alias_pool_cd, contrib_rec->qual[d.seq].health_plan_alias_type_cd = eat
       .alias_entity_alias_type_cd
      ENDIF
      IF (found_claim_alias=false
       AND eat.esi_alias_field_cd=claim_alias_field_cd)
       found_claim_alias = true, contrib_rec->qual[d.seq].claim_alias_pool_cd = eat.alias_pool_cd,
       contrib_rec->qual[d.seq].claim_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "GET CONTRIBUTOR SYSTEMS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("GET CONTRIBUTOR SYSTEMS :: Select Error :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    FOR (fidx = 1 TO hold->qual_knt)
      IF ((hold->qual[fidx].contrib_idx > 0))
       IF ((contrib_rec->qual[hold->qual[fidx].contrib_idx].contributor_system_cd < 1))
        SET hold->qual[fidx].contrib_idx = - (1)
        SET hold->qual[fidx].stat_msg = concat(trim(hold->qual[fidx].stat_msg),"[contrib]")
       ENDIF
      ENDIF
    ENDFOR
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat(trim(cnvtstring(hold->qual_knt)),
     " Rows Found For Processing")
    CALL echo("***")
    CALL echo("***   EXT_ALIAS MATCH")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].ext_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE p.alias=trim(hold->qual[d.seq].ext_alias)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_pool_cd)
       AND (p.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_type_cd
      )
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].person_id = p.person_id
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "EXT_ALIAS MATCH"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("EXT_ALIAS MATCH :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   SSN MATCH")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_alias p,
      person per
     PLAN (d
      WHERE (hold->qual[d.seq].person_id < 1)
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].unable_to_do_ssn_check=false))
      JOIN (p
      WHERE p.alias=trim(cnvtstring(cnvtint(hold->qual[d.seq].ssn_alias)))
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ssn_alias_pool_cd)
       AND (p.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ssn_alias_type_cd
      )
       AND p.active_ind=1)
      JOIN (per
      WHERE per.person_id=p.person_id
       AND per.abs_birth_dt_tm=datetimezone(hold->qual[d.seq].birth_dt_tm,contrib_rec->qual[hold->
       qual[d.seq].contrib_idx].time_zone_idx,1)
       AND per.name_first_key=cnvtupper(cnvtalphanum(hold->qual[d.seq].name_first))
       AND per.name_last_key=cnvtupper(cnvtalphanum(hold->qual[d.seq].name_last))
       AND (per.sex_cd=hold->qual[d.seq].sex_cd))
     DETAIL
      hold->qual[d.seq].person_id = p.person_id
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "SSN MATCH"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("SSN MATCH :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Get catalog_cd and synonym id values")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      mltm_ndc_core_description ndc,
      mltm_ndc_main_drug_code mmdc,
      mltm_mmdc_name_map form_nm,
      order_catalog_synonym form_syn,
      order_catalog oc,
      mltm_drug_name_derivation deriv,
      mltm_mmdc_name_map prod_nm,
      order_catalog_synonym prod_syn,
      dummyt d1
     PLAN (d
      WHERE (hold->qual[d.seq].catalog_cd=0))
      JOIN (ndc
      WHERE (ndc.ndc_code=hold->qual[d.seq].drug_code))
      JOIN (mmdc
      WHERE mmdc.main_multum_drug_code=ndc.main_multum_drug_code)
      JOIN (form_nm
      WHERE form_nm.main_multum_drug_code=ndc.main_multum_drug_code
       AND form_nm.function_id=nprod_level_generic)
      JOIN (form_syn
      WHERE form_syn.cki=concat("MUL.ORD-SYN!",cnvtstring(form_nm.drug_synonym_id)))
      JOIN (oc
      WHERE oc.catalog_cd=form_syn.catalog_cd)
      JOIN (d1)
      JOIN (deriv
      WHERE deriv.base_drug_synonym_id=ndc.brand_code)
      JOIN (prod_nm
      WHERE prod_nm.main_multum_drug_code=ndc.main_multum_drug_code
       AND prod_nm.drug_synonym_id=deriv.derived_drug_synonym_id)
      JOIN (prod_syn
      WHERE prod_syn.cki=concat("MUL.ORD-SYN!",cnvtstring(prod_nm.drug_synonym_id)))
     DETAIL
      hold->qual[d.seq].catalog_cd = oc.catalog_cd, hold->qual[d.seq].catalog_cki = trim(substring(1,
        60,oc.cki),3)
      IF (ndc.gbo="G")
       hold->qual[d.seq].product_synonym_id = form_syn.synonym_id, hold->qual[d.seq].
       product_synonym_cki = trim(form_syn.cki,3), hold->qual[d.seq].mnemonic = trim(substring(1,60,
         form_syn.mnemonic),3)
      ELSE
       hold->qual[d.seq].product_synonym_id = prod_syn.synonym_id, hold->qual[d.seq].
       product_synonym_cki = trim(prod_syn.cki,3), hold->qual[d.seq].mnemonic = trim(substring(1,60,
         prod_syn.mnemonic),3)
      ENDIF
     WITH outerjoin = d1
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "GET CATALOG_CD PROD_LEVEL_GENERIC"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat(
      "GET CATALOG_CD PROD_LEVEL_GENERIC:: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      mltm_ndc_core_description ndc,
      mltm_ndc_main_drug_code mmdc,
      mltm_drug_name_derivation deriv,
      mltm_mmdc_name_map product_name,
      mltm_drug_name_map drug_name,
      order_catalog oc,
      dummyt d1
     PLAN (d
      WHERE (hold->qual[d.seq].catalog_cd=0))
      JOIN (ndc
      WHERE (ndc.ndc_code=hold->qual[d.seq].drug_code))
      JOIN (mmdc
      WHERE mmdc.main_multum_drug_code=ndc.main_multum_drug_code)
      JOIN (deriv
      WHERE deriv.base_drug_synonym_id=ndc.brand_code)
      JOIN (product_name
      WHERE product_name.main_multum_drug_code=ndc.main_multum_drug_code
       AND product_name.drug_synonym_id=deriv.derived_drug_synonym_id)
      JOIN (drug_name
      WHERE drug_name.drug_identifier=mmdc.drug_identifier
       AND drug_name.function_id=ngeneric)
      JOIN (d1)
      JOIN (oc
      WHERE oc.cki=concat("MUL.ORD!",mmdc.drug_identifier))
     DETAIL
      hold->qual[d.seq].catalog_cd = oc.catalog_cd, hold->qual[d.seq].catalog_cki = concat("MUL.ORD!",
       mmdc.drug_identifier), hold->qual[d.seq].product_synonym_id = 0,
      hold->qual[d.seq].product_synonym_cki = concat("MUL.ORD-SYN!",cnvtstring(product_name
        .drug_synonym_id))
     WITH outerjoin = d1
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt))
     PLAN (d
      WHERE  NOT ((hold->qual[d.seq].product_synonym_cki > " ")))
     DETAIL
      hold->qual[d.seq].stat_msg = concat(hold->qual[d.seq].stat_msg,"[unknown ndc]"), hold->qual[d
      .seq].status = "W", hold->qual[d.seq].catalog_cd = unknown_catalog_cd,
      hold->qual[d.seq].product_synonym_id = unknown_synonym_id, hold->qual[d.seq].
      product_synonym_cki = unknown_synonym_cki, hold->qual[d.seq].catalog_cki = trim(substring(1,255,
        unknown_catalog_cki),3),
      hold->qual[d.seq].mnemonic = trim(substring(1,100,unknown_mnemonic),3)
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "GET CATALOG_CD nGENERIC"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("GET CATALOG_CD nGENERIC:: Select Error :: ",trim(
       serrmsg),3)
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Handle PRESCRIBER_EXT_ALIAS")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      prsnl_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].prescriber_id=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.alias=hold->qual[d.seq].prescriber_ext_alias)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].prescriber_alias_pool_cd
      )
       AND (p.prsnl_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      prescriber_alias_type_cd)
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].prescriber_id = p.person_id
     WITH format, nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      prsnl p
     PLAN (d
      WHERE (hold->qual[d.seq].prescriber_id > 0))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].prescriber_id))
     DETAIL
      hold->qual[d.seq].prescriber_name = trim(p.name_full_formatted,3)
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "FIND PRESCRIBER"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("FIND PRESCRIBER :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF (ldaprec->enabled)
     CALL echo("***")
     CALL echo("***   LookUp PHARMACY_EXT_ALIAS - LDAP")
     CALL echo("***")
     FOR (lidx = 1 TO hold->qual_knt)
       SET lidx2 = 0
       SET lpos = 0
       SET lnum = 0
       SET lpos = locateval(lnum,1,ncpdprec->qual_cnt,trim(hold->qual[lidx].pharmacy_ext_alias),
        ncpdprec->qual[lnum].ncpdpid)
       IF (lpos > 0)
        SET lidx2 = lpos
       ELSE
        SET lidx2 = (ncpdprec->qual_cnt+ 1)
        SET ncpdprec->qual_cnt = lidx2
        SET stat = alterlist(ncpdprec->qual,lidx2)
        SET ncpdprec->qual[lidx2].ncpdpid = trim(hold->qual[lidx].pharmacy_ext_alias)
        CALL uar_srvsetstring(srvrec->hreqstruct,"filter",nullterm(concat("(ssncpdpid=",trim(ncpdprec
            ->qual[lidx2].ncpdpid),")")))
        SET srvrec->hrep = uar_ldapsearch(srvrec->hldap,srvrec->hreq,lretval)
        IF ((srvrec->hrep=0))
         CALL echo("uar_LDAPSearch() Failed!!")
         SET failed = exe_error
         SET table_name = "uar_LDAPSearch()"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = "ErrMsg :: uar_LDAPSearch() Failed!!"
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        IF (working_timers > 1)
         CALL uar_sisrvdump(srvrec->hrep)
        ENDIF
        SET srvrec->hrepstruct = uar_srvgetstruct(srvrec->hrep,"reply")
        FOR (li = 0 TO (uar_srvgetitemcount(srvrec->hrepstruct,"entry") - 1))
          CALL echo(build("lI:",li))
          SET hentry = uar_srvgetitem(srvrec->hrepstruct,"entry",li)
          FOR (lj = 0 TO (uar_srvgetitemcount(hentry,"attribute") - 1))
            CALL echo(build("lJ:",lj))
            SET hattrib = uar_srvgetitem(hentry,"attribute",lj)
            SET sattrib = cnvtupper(uar_srvgetstringptr(hattrib,"name"))
            IF (((sattrib="CERNERORGANIZATIONID") OR (sattrib="CERNERORGANIZATIONNAME")) )
             FOR (lk = 0 TO (uar_srvgetitemcount(hattrib,"value") - 1))
               CALL echo(build("lK:",lk))
               SET hvalue = uar_srvgetitem(hattrib,"value",lk)
               CASE (sattrib)
                OF "CERNERORGANIZATIONID":
                 SET ncpdprec->qual[lidx2].pharmacy_identifier = substring(1,uar_srvgetlong(hvalue,
                   "bv_len"),uar_srvgetasisptr(hvalue,"bv_val"))
                OF "CERNERORGANIZATIONNAME":
                 SET ncpdprec->qual[lidx2].pharmacy_name = substring(1,uar_srvgetlong(hvalue,"bv_len"
                   ),uar_srvgetasisptr(hvalue,"bv_val"))
               ENDCASE
             ENDFOR
            ENDIF
          ENDFOR
        ENDFOR
        CALL uar_srvdestroyinstance(srvrec->hrep)
       ENDIF
       SET hold->qual[lidx].pharmacy_identifier = ncpdprec->qual[lidx2].pharmacy_identifier
       SET hold->qual[lidx].pharmacy_name = ncpdprec->qual[lidx2].pharmacy_name
     ENDFOR
    ELSEIF (borg)
     CALL echo("***")
     CALL echo("***   LookUp PHARMACY_EXT_ALIAS - OA")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(hold->qual_knt)),
       organization_alias oa,
       organization o
      PLAN (d
       WHERE (hold->qual[d.seq].pharmacy_ext_alias > " ")
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (oa
       WHERE (oa.alias=hold->qual[d.seq].pharmacy_ext_alias)
        AND (oa.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].pharmacy_alias_pool_cd
       )
        AND (oa.org_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       pharmacy_alias_type_cd)
        AND oa.active_ind=1)
       JOIN (o
       WHERE o.organization_id=oa.organization_id)
      DETAIL
       hold->qual[d.seq].pharmacy_name = trim(o.org_name,3)
      WITH format, nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "ORGANIZATION_ALIAS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ORGANIZATION_ALIAS :: Select Error :: Alias :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ELSE
     CALL echo("***")
     CALL echo("***   LookUp PHARMACY_EXT_ALIAS - CVA")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(hold->qual_knt)),
       code_value_alias cva
      PLAN (d
       WHERE size(trim(hold->qual[d.seq].pharmacy_ext_alias)) > 0
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (cva
       WHERE operator(cva.alias,"LIKE",patstring(concat(trim(hold->qual[d.seq].pharmacy_ext_alias),
          trim(contrib_rec->qual[hold->qual[d.seq].contrib_idx].pharmacy_alias_stamp),"*"),1))
        AND ((cva.code_set+ 0)=220)
        AND ((cva.contributor_source_cd+ 0)=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       contributor_source_cd)
        AND cva.alias_type_meaning="ORGALTALIAS")
      DETAIL
       hold->qual[d.seq].pharmacy_name = trim(uar_get_code_display(cva.code_value),3)
      WITH format, nocounter
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
      SET log->qual[log->qual_knt].smsg = concat("CODE_VALUE_ALIAS :: Select Error :: Alias :: ",trim
       (serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echo("***")
    CALL echo("***   LookUp PAYER_ALIAS - OA")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      organization_alias oa
     PLAN (d
      WHERE (hold->qual[d.seq].payer_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (oa
      WHERE (oa.alias=hold->qual[d.seq].payer_alias)
       AND (oa.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].payer_alias_pool_cd)
       AND (oa.org_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].payer_alias_type_cd
      )
       AND oa.active_ind=1)
     DETAIL
      hold->qual[d.seq].payer_id = oa.organization_id
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "ORGANIZATION_ALIAS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat(
      "ORGANIZATION_ALIAS :: Select Error :: Payer Alias :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   LookUp HEALTH_PLAN_ALIAS")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      health_plan_alias h
     PLAN (d
      WHERE (hold->qual[d.seq].health_plan_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (h
      WHERE (h.alias=hold->qual[d.seq].health_plan_alias)
       AND (h.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      health_plan_alias_pool_cd)
       AND (h.plan_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      health_plan_alias_type_cd)
       AND h.active_ind=1)
     DETAIL
      hold->qual[d.seq].health_plan_id = h.health_plan_id
     WITH format, nocounter
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
     SET log->qual[log->qual_knt].smsg = concat("HEALTH_PLAN_ALIAS :: Select Error :: ",trim(serrmsg)
      )
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Handle CLAIM_IDENTIFIER")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      gs_med_claim_alias a
     PLAN (d
      WHERE size(trim(hold->qual[d.seq].claim_identifier)) > 0
       AND (hold->qual[d.seq].gs_med_claim_id <= 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (a
      WHERE (a.alias=hold->qual[d.seq].claim_identifier)
       AND (a.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].claim_alias_pool_cd)
       AND (a.gs_med_claim_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      claim_alias_type_cd)
       AND a.active_ind != 0)
     DETAIL
      hold->qual[d.seq].gs_med_claim_id = a.gs_med_claim_id, hold->qual[d.seq].gs_med_claim_alias_id
       = a.gs_med_claim_alias_id
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "GS_MED_CLAIM_ALIAS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("GS_MED_CLAIM_ALIAS :: Select Error :: ",trim(serrmsg
       ))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    FOR (temp_i = 1 TO hold->qual_knt)
      IF ((hold->qual[temp_i].person_id <= 0))
       SET hold->qual[temp_i].contrib_idx = - (1)
       SET hold->qual[temp_i].status = "F"
       SET hold->qual[temp_i].stat_msg = concat(trim(hold->qual[temp_i].stat_msg),"[mrn]")
      ENDIF
      IF (size(hold->qual[temp_i].product_synonym_cki) <= 0
       AND (hold->qual[temp_i].catalog_cd != unknown_catalog_cd))
       SET hold->qual[temp_i].contrib_idx = - (1)
       SET hold->qual[temp_i].status = "F"
       SET hold->qual[temp_i].stat_msg = concat(trim(hold->qual[temp_i].stat_msg),"[ndc]")
      ENDIF
      IF ((hold->qual[temp_i].payer_alias > " ")
       AND (hold->qual[temp_i].payer_id < 1))
       SET hold->qual[temp_i].stat_msg = concat(trim(hold->qual[temp_i].stat_msg),"[payer]")
      ENDIF
      IF ((hold->qual[temp_i].health_plan_alias > " ")
       AND (hold->qual[temp_i].health_plan_id < 1))
       SET hold->qual[temp_i].stat_msg = concat(trim(hold->qual[temp_i].stat_msg),"[plan]")
      ENDIF
      IF ((hold->qual[temp_i].contrib_idx > 0))
       IF ((hold->qual[temp_i].gs_med_claim_id <= 0))
        CALL echo("***")
        CALL echo("***   Insert GS_MED_CLAIM")
        CALL echo("***")
        SELECT INTO "nl:"
         y = seq(gs_seq,nextval)
         FROM dual
         DETAIL
          hold->qual[temp_i].gs_med_claim_id = cnvtreal(y)
         WITH nocounter
        ;end select
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        INSERT  FROM gs_med_claim g
         SET g.gs_med_claim_id = hold->qual[temp_i].gs_med_claim_id, g.person_id = hold->qual[temp_i]
          .person_id, g.service_dt_tm = cnvtdatetime(hold->qual[temp_i].service_dt_tm),
          g.ext_product_ident = hold->qual[temp_i].drug_code, g.ext_product_ident_type_cd =
          IF (size(trim(hold->qual[temp_i].drug_code)) > 0) didentifiertypecd
          ELSE 0.0
          ENDIF
          , g.product_description =
          IF ((hold->qual[temp_i].product_description > " ")) trim(substring(1,100,hold->qual[temp_i]
             .product_description))
          ELSE " "
          ENDIF
          ,
          g.catalog_cki =
          IF ((hold->qual[temp_i].catalog_cki > " ")) trim(substring(1,255,hold->qual[temp_i].
             catalog_cki))
          ELSE " "
          ENDIF
          , g.catalog_cd =
          IF ((hold->qual[temp_i].catalog_cd > 0)) hold->qual[temp_i].catalog_cd
          ELSE 0
          ENDIF
          , g.product_synonym_cki =
          IF ((hold->qual[temp_i].product_synonym_cki > " ")) trim(substring(1,255,hold->qual[temp_i]
             .product_synonym_cki))
          ELSE " "
          ENDIF
          ,
          g.product_synonym_id = hold->qual[temp_i].product_synonym_id, g.dispense_qty =
          IF (isnumeric(hold->qual[temp_i].dispense_qty) > 0) cnvtreal(hold->qual[temp_i].
            dispense_qty)
          ELSE 0.0
          ENDIF
          , g.refill_nbr =
          IF (isnumeric(hold->qual[temp_i].refill_nbr) > 0) cnvtint(hold->qual[temp_i].refill_nbr)
          ELSE 0
          ENDIF
          ,
          g.ext_prescriber_ident = hold->qual[temp_i].prescriber_ext_alias, g
          .ext_prescriber_ident_type_cd = contrib_rec->qual[hold->qual[temp_i].contrib_idx].
          prescriber_alias_type_cd, g.prescriber_name =
          IF ((hold->qual[temp_i].prescriber_name > " ")) hold->qual[temp_i].prescriber_name
          ELSE " "
          ENDIF
          ,
          g.prescriber_id = hold->qual[temp_i].prescriber_id, g.ext_pharmacy_ident = hold->qual[
          temp_i].pharmacy_ext_alias, g.ext_pharmacy_ident_type_cd = ncpdp_cd,
          g.pharmacy_name =
          IF ((hold->qual[temp_i].pharmacy_name > " ")) hold->qual[temp_i].pharmacy_name
          ELSE " "
          ENDIF
          , g.pharmacy_identifier =
          IF ((hold->qual[temp_i].pharmacy_identifier > " ")) hold->qual[temp_i].pharmacy_identifier
          ELSE " "
          ENDIF
          , g.payer_org_id = hold->qual[temp_i].payer_id,
          g.prescription_health_plan_id = hold->qual[temp_i].health_plan_id, g.contributor_system_cd
           = contrib_rec->qual[hold->qual[temp_i].contrib_idx].contributor_system_cd, g.create_dt_tm
           = cnvtdatetime(dates->now_dt_tm),
          g.received_qty_txt = trim(hold->qual[temp_i].dispense_qty), g.obtained_dt_tm = cnvtdatetime
          (dates->now_dt_tm), g.active_ind =
          IF (size(trim(hold->qual[temp_i].action)) > 0
           AND cnvtint(hold->qual[temp_i].action) < 1) 0
          ELSE 1
          ENDIF
          ,
          g.active_status_cd =
          IF (size(trim(hold->qual[temp_i].action)) > 0
           AND cnvtint(hold->qual[temp_i].action) < 1) inactive_active_status_cd
          ELSE active_active_status_cd
          ENDIF
          , g.active_status_prsnl_id = contrib_rec->qual[hold->qual[temp_i].contrib_idx].
          prsnl_person_id, g.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm),
          g.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), g.updt_id = contrib_rec->qual[hold->qual[
          temp_i].contrib_idx].prsnl_person_id, g.updt_task = 4249900,
          g.updt_cnt = 0, g.updt_applctx = 4249900
         WHERE (hold->qual[temp_i].gs_med_claim_id > 0)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = insert_error
         SET table_name = "GS_MED_CLAIM"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("GS_MED_CLAIM :: Insert Error :: ",trim(serrmsg))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        IF ((hold->qual[temp_i].gs_med_claim_alias_id <= 0))
         CALL echo("***")
         CALL echo("***   Insert GS_MED_CLAIM_ALIAS")
         CALL echo("***")
         SELECT INTO "nl:"
          y = seq(gs_seq,nextval)
          FROM dual
          DETAIL
           hold->qual[temp_i].gs_med_claim_alias_id = cnvtreal(y)
          WITH nocounter
         ;end select
         SET ierrcode = error(serrmsg,1)
         SET ierrcode = 0
         INSERT  FROM gs_med_claim_alias a
          SET a.gs_med_claim_alias_id = hold->qual[temp_i].gs_med_claim_alias_id, a.gs_med_claim_id
            = hold->qual[temp_i].gs_med_claim_id, a.alias = hold->qual[temp_i].claim_identifier,
           a.alias_pool_cd = contrib_rec->qual[hold->qual[temp_i].contrib_idx].claim_alias_pool_cd, a
           .gs_med_claim_alias_type_cd = contrib_rec->qual[hold->qual[temp_i].contrib_idx].
           claim_alias_type_cd, a.contributor_system_cd = contrib_rec->qual[hold->qual[temp_i].
           contrib_idx].contributor_system_cd,
           a.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), a.end_effective_dt_tm =
           cnvtdatetime(dates->end_dt_tm), a.active_ind = 1,
           a.active_status_cd = active_active_status_cd, a.active_status_dt_tm = cnvtdatetime(dates->
            now_dt_tm), a.active_status_prsnl_id = contrib_rec->qual[hold->qual[temp_i].contrib_idx].
           prsnl_person_id,
           a.updt_applctx = 4249900, a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
           a.updt_id = contrib_rec->qual[hold->qual[temp_i].contrib_idx].prsnl_person_id, a.updt_task
            = 4249900
          WHERE (hold->qual[temp_i].gs_med_claim_id > 0)
           AND (hold->qual[temp_i].contrib_idx > 0)
          WITH nocounter
         ;end insert
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          ROLLBACK
          SET failed = insert_error
          SET table_name = "GS_MED_CLAIM_ALIAS"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = concat("AGS_MEDS_DATA :: Update Error :: ",trim(serrmsg
            ))
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ENDIF
        ENDIF
       ELSE
        IF (cnvtint(hold->qual[temp_i].action) > 0)
         CALL echo("***")
         CALL echo("***   Update GS_MED_CLAIM  ACTION > 0")
         CALL echo("***")
         UPDATE  FROM gs_med_claim g
          SET g.gs_med_claim_id = hold->qual[temp_i].gs_med_claim_id, g.service_dt_tm = cnvtdatetime(
            hold->qual[temp_i].service_dt_tm), g.ext_product_ident = hold->qual[temp_i].drug_code,
           g.ext_product_ident_type_cd =
           IF (size(trim(hold->qual[temp_i].drug_code)) > 0) didentifiertypecd
           ELSE 0.0
           ENDIF
           , g.product_description =
           IF ((hold->qual[temp_i].product_description > " ")) trim(substring(1,100,hold->qual[temp_i
              ].product_description))
           ELSE " "
           ENDIF
           , g.catalog_cki =
           IF ((hold->qual[temp_i].catalog_cki > " ")) trim(substring(1,255,hold->qual[temp_i].
              catalog_cki))
           ELSE " "
           ENDIF
           ,
           g.catalog_cd =
           IF ((hold->qual[temp_i].catalog_cd > 0)) hold->qual[temp_i].catalog_cd
           ELSE 0
           ENDIF
           , g.product_synonym_cki =
           IF ((hold->qual[temp_i].product_synonym_cki > " ")) trim(substring(1,255,hold->qual[temp_i
              ].product_synonym_cki))
           ELSE " "
           ENDIF
           , g.product_synonym_id = hold->qual[temp_i].product_synonym_id,
           g.dispense_qty =
           IF (isnumeric(hold->qual[temp_i].dispense_qty) > 0) cnvtreal(hold->qual[temp_i].
             dispense_qty)
           ELSE 0.0
           ENDIF
           , g.refill_nbr =
           IF (isnumeric(hold->qual[temp_i].refill_nbr) > 0) cnvtint(hold->qual[temp_i].refill_nbr)
           ELSE 0
           ENDIF
           , g.ext_prescriber_ident = hold->qual[temp_i].prescriber_ext_alias,
           g.ext_prescriber_ident_type_cd = contrib_rec->qual[hold->qual[temp_i].contrib_idx].
           prescriber_alias_type_cd, g.prescriber_name =
           IF ((hold->qual[temp_i].prescriber_name > " ")) hold->qual[temp_i].prescriber_name
           ELSE " "
           ENDIF
           , g.prescriber_id = hold->qual[temp_i].prescriber_id,
           g.ext_pharmacy_ident = hold->qual[temp_i].pharmacy_ext_alias, g.ext_pharmacy_ident_type_cd
            = ncpdp_cd, g.pharmacy_name =
           IF ((hold->qual[temp_i].pharmacy_name > " ")) hold->qual[temp_i].pharmacy_name
           ELSE " "
           ENDIF
           ,
           g.pharmacy_identifier =
           IF ((hold->qual[temp_i].pharmacy_identifier > " ")) hold->qual[temp_i].pharmacy_identifier
           ELSE " "
           ENDIF
           , g.payer_org_id = hold->qual[temp_i].payer_id, g.prescription_health_plan_id = hold->
           qual[temp_i].health_plan_id,
           g.received_qty_txt = trim(hold->qual[temp_i].dispense_qty), g.active_ind = 1, g
           .active_status_cd = active_active_status_cd,
           g.active_status_prsnl_id = contrib_rec->qual[hold->qual[temp_i].contrib_idx].
           prsnl_person_id, g.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), g.updt_dt_tm =
           cnvtdatetime(dates->now_dt_tm),
           g.updt_id = contrib_rec->qual[hold->qual[temp_i].contrib_idx].prsnl_person_id, g.updt_task
            = 4249900, g.updt_cnt = (g.updt_cnt+ 1),
           g.updt_applctx = 4249900
          WHERE (g.gs_med_claim_id=hold->qual[temp_i].gs_med_claim_id)
          WITH nocounter
         ;end update
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET failed = update_error
          SET table_name = "GS_MED_CLAIM"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = concat("GS_MED_CLAIM :: Update Error :: ",trim(serrmsg)
           )
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ENDIF
        ELSEIF (cnvtint(hold->qual[temp_i].action) < 1)
         CALL echo("***")
         CALL echo("***   Update GS_MED_CLAIM  ACTION < 0")
         CALL echo("***")
         UPDATE  FROM gs_med_claim g
          SET g.active_ind = 0, g.active_status_cd = inactive_active_status_cd, g
           .active_status_prsnl_id = contrib_rec->qual[hold->qual[temp_i].contrib_idx].
           prsnl_person_id,
           g.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), g.updt_dt_tm = cnvtdatetime(dates
            ->now_dt_tm), g.updt_id = contrib_rec->qual[hold->qual[temp_i].contrib_idx].
           prsnl_person_id,
           g.updt_task = 4249900, g.updt_cnt = (g.updt_cnt+ 1), g.updt_applctx = 4249900
          WHERE (g.gs_med_claim_id=hold->qual[temp_i].gs_med_claim_id)
          WITH nocounter
         ;end update
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET failed = update_error
          SET table_name = "GS_MED_CLAIM"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = concat("GS_MED_CLAIM :: Inactivate Update Error :: ",
           trim(serrmsg))
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      CALL echo("***")
      CALL echo("***   Update AGS_MEDS_DATA to COMPLETE")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      UPDATE  FROM ags_meds_data m
       SET m.gs_med_claim_id = hold->qual[temp_i].gs_med_claim_id, m.status = "COMPLETE", m.stat_msg
         = "",
        m.status_dt_tm = cnvtdatetime(dates->now_dt_tm), m.person_id = hold->qual[temp_i].person_id,
        m.catalog_cd =
        IF ((hold->qual[temp_i].catalog_cd > 0)) hold->qual[temp_i].catalog_cd
        ELSE 0
        ENDIF
        ,
        m.product_synonym_cki =
        IF ((hold->qual[temp_i].product_synonym_cki > " ")) trim(substring(1,255,hold->qual[temp_i].
           product_synonym_cki))
        ELSE m.product_synonym_cki
        ENDIF
        , m.prescriber_id = hold->qual[temp_i].prescriber_id, m.contributor_system_cd = contrib_rec->
        qual[hold->qual[temp_i].contrib_idx].contributor_system_cd,
        m.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), m.updt_id = contrib_rec->qual[hold->qual[
        temp_i].contrib_idx].prsnl_person_id, m.updt_task = 4249900,
        m.updt_cnt = (m.updt_cnt+ 1), m.updt_applctx = 4249900
       WHERE (hold->qual[temp_i].ags_meds_data_id > 0)
        AND (hold->qual[temp_i].contrib_idx > 0)
        AND (m.ags_meds_data_id=hold->qual[temp_i].ags_meds_data_id)
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       ROLLBACK
       SET failed = update_error
       SET table_name = "AGS_MEDS_DATA COMPLETE"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("AGS_MEDS_DATA COMPLETE :: Update Error :: ",trim(
         serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
      CALL echo("***")
      CALL echo("***   Update AGS_MEDS_DATA to IN ERROR")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      UPDATE  FROM ags_meds_data m
       SET m.gs_med_claim_id = 0.0, m.status = "IN ERROR", m.stat_msg = trim(substring(1,40,hold->
          qual[temp_i].stat_msg)),
        m.status_dt_tm = cnvtdatetime(dates->now_dt_tm), m.person_id = 0.0, m.catalog_cd = 0.0,
        m.prescriber_id = 0.0
       WHERE (hold->qual[temp_i].ags_meds_data_id > 0)
        AND (hold->qual[temp_i].contrib_idx < 1)
        AND (m.ags_meds_data_id=hold->qual[temp_i].ags_meds_data_id)
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       ROLLBACK
       SET failed = update_error
       SET table_name = "AGS_MEDS_DATA IN ERROR"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("AGS_MEDS_DATA IN ERROR :: Update Error :: ",trim(
         serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
      IF ((hold->qual[temp_i].gs_med_claim_id > 0))
       CALL echo("***")
       CALL echo("***   Update Duplicate AGS_MEDS_DATA")
       CALL echo("***")
       SET ierrcode = error(serrmsg,1)
       SET ierrcode = 0
       UPDATE  FROM ags_meds_data m
        SET m.gs_med_claim_id = hold->qual[temp_i].gs_med_claim_id, m.status = "REPLACED"
        WHERE (m.claim_identifier=hold->qual[temp_i].claim_identifier)
         AND (m.ags_meds_data_id < hold->qual[temp_i].ags_meds_data_id)
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        ROLLBACK
        SET failed = update_error
        SET table_name = "AGS_MEDS_DATA"
        SET ilog_status = 1
        SET log->qual_knt = (log->qual_knt+ 1)
        SET stat = alterlist(log->qual,log->qual_knt)
        SET log->qual[log->qual_knt].smsgtype = "ERROR"
        SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
        SET log->qual[log->qual_knt].smsg = concat("AGS_MEDS_DATA :: Update Duplicate Error :: ",trim
         (serrmsg))
        SET serrmsg = log->qual[log->qual_knt].smsg
        GO TO exit_script
       ENDIF
      ENDIF
      IF (size(trim(hold->qual[temp_i].prev_claim_identifier)) > 0)
       CALL echo("***")
       CALL echo("***   Handle prev_claim_identifier")
       CALL echo("***")
       SET ierrcode = error(serrmsg,1)
       SET ierrcode = 0
       UPDATE  FROM gs_med_claim g
        SET g.active_ind = 0, g.active_status_cd = inactive_active_status_cd, g
         .active_status_prsnl_id = contrib_rec->qual[hold->qual[temp_i].contrib_idx].prsnl_person_id,
         g.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), g.updt_dt_tm = cnvtdatetime(dates->
          now_dt_tm), g.updt_id = contrib_rec->qual[hold->qual[temp_i].contrib_idx].prsnl_person_id,
         g.updt_task = 4249900, g.updt_cnt = (g.updt_cnt+ 1), g.updt_applctx = 4249900
        WHERE (g.gs_med_claim_id=
        (SELECT
         a.gs_med_claim_id
         FROM gs_med_claim_alias a
         WHERE a.alias=trim(hold->qual[temp_i].prev_claim_identifier)
          AND ((a.alias_pool_cd+ 0)=contrib_rec->qual[hold->qual[temp_i].contrib_idx].
         claim_alias_pool_cd)
          AND ((a.gs_med_claim_alias_type_cd+ 0)=contrib_rec->qual[hold->qual[temp_i].contrib_idx].
         claim_alias_type_cd)))
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = update_error
        SET table_name = "GS_MED_CLAIM"
        SET ilog_status = 1
        SET log->qual_knt = (log->qual_knt+ 1)
        SET stat = alterlist(log->qual,log->qual_knt)
        SET log->qual[log->qual_knt].smsgtype = "ERROR"
        SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
        SET log->qual[log->qual_knt].smsg = concat(
         "GS_MED_CLAIM :: Update Error :: Previous Claim :: ",trim(serrmsg))
        SET serrmsg = log->qual[log->qual_knt].smsg
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = "No Rows Found For Processing"
   ENDIF
   IF (working_timers > 1)
    CALL echorecord(contrib_rec)
    CALL echorecord(hold)
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM ags_task t
    PLAN (t
     WHERE t.ags_task_id=working_task_id)
    DETAIL
     working_kill_ind = t.kill_ind
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
   SET dates->it_end_dt_tm = cnvtdatetime(curdate,curtime3)
   SET it_avg = 0
   IF ((hold->qual_knt > 0))
    SET it_avg = (cnvtreal(hold->qual_knt)/ datetimediff(dates->it_end_dt_tm,dates->now_dt_tm,5))
   ENDIF
   IF (it_avg > 0)
    SET dates->it_est_end_dt_tm = cnvtlookahead(concat(cnvtstring(ceil((cnvtreal(((max_data_id -
         end_data_id)+ 1))/ it_avg))),",S"),dates->it_end_dt_tm)
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.iteration_start_id = beg_data_id, t.iteration_end_id = end_data_id, t.iteration_count =
     hold->qual_knt,
     t.iteration_start_dt_tm = cnvtdatetime(dates->now_dt_tm), t.iteration_end_dt_tm = cnvtdatetime(
      dates->it_end_dt_tm), t.iteration_average = it_avg,
     t.est_completion_dt_tm = cnvtdatetime(dates->it_est_end_dt_tm)
    PLAN (t
     WHERE t.ags_task_id=working_task_id)
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
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("END PROCESSING :: BEG_DATA_ID :: ",trim(cnvtstring(
      beg_data_id))," :: END_DATA_ID :: ",trim(cnvtstring(end_data_id))," :: MAX_DATA_ID :: ",
    trim(cnvtstring(max_data_id)))
   SET beg_data_id = (end_data_id+ 1)
   IF (((beg_data_id+ data_size) > max_data_id))
    SET end_data_id = max_data_id
   ELSE
    SET end_data_id = ((beg_data_id+ data_size) - 1)
   ENDIF
 ENDWHILE
 IF (working_task_id > 0
  AND working_kill_ind < 1)
  CALL echo("***")
  CALL echo("***   Update Task to Complete")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.status = "COMPLETE", t.status_dt_tm = cnvtdatetime(curdate,curtime3), t.batch_end_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK COMPLETE"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("AGS_TASK COMPLETE :: Select Error :: ",trim(serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  SET job_complete = true
  SELECT INTO "nl:"
   FROM ags_task t
   WHERE t.ags_job_id=working_job_id
    AND t.status != "COMPLETE"
   DETAIL
    job_complete = false
   WITH nocounter
  ;end select
  IF (job_complete)
   UPDATE  FROM ags_job j
    SET j.status = "COMPLETE", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE j.ags_job_id=working_job_id
    WITH nocounter
   ;end update
  ENDIF
 ELSEIF (working_task_id > 0
  AND working_kill_ind > 0)
  CALL echo("***")
  CALL echo("***   Update Task to Waiting Kill_ind = 1")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.status = "WAITING", t.status_dt_tm = cnvtdatetime(curdate,curtime3), t.batch_end_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK COMPLETE"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("AGS_TASK KILL_IND WAITING :: Select Error :: ",trim(
     serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
 SUBROUTINE create_srvhandles(dummy)
   CALL echo("Begin Create_SrvHandles()")
   SET srvrec->hmessage = uar_srvselectmessage(4299510)
   IF ((srvrec->hmessage=0))
    CALL echo("uar_SrvSelectMessage() Failed!!")
    RETURN(0)
   ENDIF
   SET srvrec->hreq = uar_srvcreaterequest(srvrec->hmessage)
   IF ((srvrec->hreq=0))
    CALL echo("uar_SrvCreateRequest() Failed!!")
    RETURN(0)
   ENDIF
   SET srvrec->hreqstruct = uar_srvgetstruct(srvrec->hreq,"request")
   IF ((srvrec->hreqstruct=0))
    CALL echo("uar_SrvGetStruct() Failed!!")
    RETURN(0)
   ENDIF
   CALL echo("End Create_SrvHandles()")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE destroy_srvhandles(dummy1)
   CALL echo("Begin Destroy_SrvHandles()")
   IF (srvrec->hreq)
    CALL uar_srvdestroyinstance(srvrec->hreq)
   ENDIF
   IF (srvrec->hrep)
    CALL uar_srvdestroyinstance(srvrec->hrep)
   ENDIF
   CALL echo("End Destroy_SrvHandles()")
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
     DECLARE sender = vc WITH public, noconstant("sb2348")
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
 CALL destroy_srvhandles(0)
 IF (srvrec->hldap)
  CALL uar_ldapunbind(srvrec->hldap)
 ENDIF
 IF (failed != false)
  ROLLBACK
  CALL echo("***")
  CALL echo("***   failed != FALSE")
  CALL echo("***")
  IF (working_task_id > 0)
   CALL echo("***")
   CALL echo("***   Update Task to Error")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.status = "IN ERROR", t.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (t
     WHERE t.ags_task_id=working_task_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_TASK ERROR"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_TASK ERROR :: Select Error :: ",trim(serrmsg))
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
 SET log->qual[log->qual_knt].smsg = "END >> AGS_MEDS_LOAD"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL echo("***")
  CALL echo("***   END LOGGING")
  CALL echo("***")
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 CALL echo("***")
 CALL echo("***   END AGS_MEDS_LOAD")
 CALL echo("***")
 SET script_ver = "010 12/11/06"
END GO
