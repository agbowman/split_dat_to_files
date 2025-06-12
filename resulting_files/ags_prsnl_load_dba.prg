CREATE PROGRAM ags_prsnl_load:dba
 PROMPT
  "TASK_ID (0.0) = " = 0
  WITH dtask_id
 CALL echo("***")
 CALL echo("***   BEG AGS_PRSNL_LOAD")
 CALL echo("***")
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
  DECLARE sstatus_file_name = vc WITH public, noconstant(concat("ags_prsnl_load_",format(cnvtdatetime
     (curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_PRSNL_LOAD"
  SET define_logging_sub = true
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_PRSNL_LOAD"
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
     2 dea_alias_pool_cd = f8
     2 dea_alias_type_cd = f8
     2 upin_alias_pool_cd = f8
     2 upin_alias_type_cd = f8
     2 link_alias_pool_cd = f8
     2 link_alias_type_cd = f8
     2 med_alias_pool_cd = f8
     2 med_alias_type_cd = f8
 )
 FREE RECORD alt_rec
 RECORD alt_rec(
   1 qual_knt = i4
   1 qual[*]
     2 contrib_idx = i4
     2 esi_alias_type = vc
     2 alt_alias_pool_cd = f8
     2 alt_alias_type_cd = f8
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
 SET dates->batch_start_dt_tm = cnvtdatetime(dates->now_dt_tm)
 SET dates->end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 DECLARE found_default_contrib_system = i2 WITH public, noconstant(false)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE pos = i4 WITH public, noconstant(0)
 DECLARE esi_default_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",73,"Default"))
 DECLARE org_class_cd = f8 WITH public, constant(uar_get_code_by("MEANING",396,"ORG"))
 DECLARE auth_data_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE active_active_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE client_alias_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",334,"CLIENT"))
 DECLARE work_phone_type_cd = f8 WITH publlic, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE fax_phone_type_cd = f8 WITH publlic, constant(uar_get_code_by("MEANING",43,"FAX BUS"))
 DECLARE us_phone_format_cd = f8 WITH publlic, constant(uar_get_code_by("MEANING",281,"US"))
 DECLARE work_addr_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE client_org_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",278,"CLIENT"))
 DECLARE facility_org_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",278,"FACILITY"))
 DECLARE facility_loc_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE prsnl_name_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",213,"PRSNL"))
 DECLARE current_name_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",213,"CURRENT"))
 DECLARE person_person_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",302,"PERSON"))
 DECLARE prsnl_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",309,"USER"))
 DECLARE male_sex_cd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"MALE"))
 DECLARE female_sex_cd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"FEMALE"))
 DECLARE unknown_sex_cd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"UNKNOWN"))
 DECLARE ext_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "PSNLEXTALIAS"))
 DECLARE alt_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "PSNLALTALIAS"))
 DECLARE ssn_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PRSNSSN"))
 DECLARE dea_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PSNLDEA"))
 DECLARE upin_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PSNLUPIN")
  )
 DECLARE link_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "PSNLLNKALIAS"))
 DECLARE med_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "PSNLMEDICAID"))
 DECLARE ssn_mult_ind = i2 WITH public, noconstant(true)
 DECLARE found_phone_business_delete = i2 WITH public, noconstant(false)
 DECLARE found_phone_fax_delete = i2 WITH public, noconstant(false)
 DECLARE found_address_delete = i2 WITH public, noconstant(false)
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
 IF (unknown_sex_cd < 1)
  SET failed = select_error
  SET table_name = "GET UNKNOWN_SEX_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UNKNOWN_SEX_CD :: Select Error :: CODE_VALUE for CDF_MEANING UNKNOWN invalid from CODE_SET 57"
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
  "EXT_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning PRSNLEXTALIAS invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (alt_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET ALT_ALIAS_FIELD_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "ALT_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning PSNLALTALIAS invalid from CODE_SET 4001891"
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
 IF (dea_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET DEA_ALIAS_FIELD_CDE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "DEA_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning PSNLDEA invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (upin_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET UPIN_ALIAS_FIELD_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "UPIN_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning PSNLUPIN invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (link_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET LINK_ALIAS_FIELD_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "LINK_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning PSNLLNKALIAS invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (med_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET MED_ALIAS_FIELD_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "MED_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning PSNLMEDICAID invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (work_phone_type_cd < 1)
  SET failed = select_error
  SET table_name = "GET WORK_PHONE_TYPE_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "WORK_PHONE_TYPE_CD :: Select Error :: CODE_VALUE for CDF_MEANING BUSINESS invalid from CODE_SET 43"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (fax_phone_type_cd < 1)
  SET failed = select_error
  SET table_name = "GET FAX_PHONE_TYPE_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "FAX_PHONE_TYPE_CD :: Select Error :: CODE_VALUE for CDF_MEANING FAX BUS invalid from CODE_SET 43"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (work_addr_type_cd < 1)
  SET failed = select_error
  SET table_name = "GET WORK_ADDR_TYPE_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "WORK_ADDR_TYPE_CD :: Select Error :: CODE_VALUE for CDF_MEANING BUSINESS invalid from CODE_SET 212"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (prsnl_name_type_cd < 1)
  SET failed = select_error
  SET table_name = "GET PRSNL_NAME_TYPE_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "PRSNL_NAME_TYPE_CD :: Select Error :: CODE_VALUE for CDF_MEANING PRSNL invalid from CODE_SET 213"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (us_phone_format_cd < 1)
  SET failed = select_error
  SET table_name = "GET US_PHONE_FORMAT_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "US_PHONE_FORMAT_CD :: Select Error :: CODE_VALUE for CDF_MEANING US invalid from CODE_SET 281"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (current_name_type_cd < 1)
  SET failed = select_error
  SET table_name = "GET CURRENT_NAME_TYPE_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "CURRENT_NAME_TYPE_CD :: Select Error :: CODE_VALUE for CDF_MEANING CURRENT invalid from CODE_SET 213"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM code_cdf_ext cce
  PLAN (cce
   WHERE cce.code_set=4
    AND cce.cdf_meaning="SSN"
    AND cce.field_name="MULTIPLE_IND")
  DETAIL
   ssn_mult_ind = cnvtint(cce.field_value)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "CODE_CDF_EXT"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET SSN_MULT_IND :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Task Data")
 CALL echo("***")
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
   max_id = max(p.ags_prsnl_data_id), dknt = count(p.ags_prsnl_data_id)
   FROM ags_prsnl_data p
   PLAN (p
    WHERE p.ags_prsnl_data_id >= beg_data_id
     AND p.status IN ("IN ERROR", "BACK OUT"))
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
       2 ags_prsnl_data_id = f8
       2 contrib_idx = i4
       2 alt1_idx = i4
       2 alt2_idx = i4
       2 run_nbr = f8
       2 run_dt_tm = dq8
       2 file_row_nbr = i4
       2 organization_id = f8
       2 person_id = f8
       2 ext_alias = vc
       2 ssn_alias = vc
       2 found_ssn_ind = i2
       2 ssn_person_alias_id = f8
       2 s_int_ssn_alias = vc
       2 dea_alias = vc
       2 upin_alias = vc
       2 med_alias = vc
       2 ext_link_alias = vc
       2 name_last = vc
       2 name_first = vc
       2 name_middle = vc
       2 name_full = vc
       2 name_degree = vc
       2 name_title = vc
       2 birth_date = vc
       2 birth_dt_tm = dq8
       2 abs_birth_dt_tm = dq8
       2 sex_string = vc
       2 sex_cd = f8
       2 street_addr = vc
       2 street_addr2 = vc
       2 city = vc
       2 county = vc
       2 county_cd = f8
       2 state = vc
       2 state_cd = f8
       2 country = vc
       2 country_cd = f8
       2 zip = vc
       2 phone_business = vc
       2 phone_fax = vc
       2 alt_alias1 = vc
       2 alt_alias1_type = vc
       2 alt_alias2 = vc
       2 alt_alias2_type = vc
       2 ext_org_alias = vc
       2 specialty = vc
       2 specialty_desc = vc
       2 person_exists_ind = i4
       2 ssn_alias_exists_ind = i4
       2 ext_alias_exists_ind = i4
       2 dea_alias_exists_ind = i4
       2 upin_alias_exists_ind = i4
       2 link_alias_exists_ind = i4
       2 med_alias_exists_ind = i4
       2 alt_alias1_exists_ind = i4
       2 alt_alias2_exists_ind = i4
       2 phone_fax_id = f8
       2 phone_fax_exists_ind = i4
       2 phone_business_id = f8
       2 phone_business_exists_ind = i4
       2 address_id = f8
       2 address_exists_ind = i4
       2 phone_business_action_flag = i2
       2 phone_fax_action_flag = i2
       2 address_action_flag = i2
       2 prsnl_person_name_id = f8
       2 prsnl_name_exists_ind = i2
       2 current_person_name_id = f8
       2 current_name_exists_ind = i2
       2 status = vc
       2 stat_msg = vc
   )
   CALL echo("***")
   CALL echo(build("***   beg_data_id    :",beg_data_id))
   CALL echo(build("***   end_data_id    :",end_data_id))
   CALL echo(build("***   working_job_id :",working_job_id))
   CALL echo("***")
   SET dates->now_dt_tm = cnvtdatetime(curdate,curtime3)
   SET found_phone_business_delete = false
   SET found_phone_fax_delete = false
   SET found_address_delete = false
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT
    IF (working_mode=0)
     PLAN (p
      WHERE p.ags_prsnl_data_id >= beg_data_id
       AND p.ags_prsnl_data_id <= end_data_id
       AND ((p.person_id+ 0) < 1)
       AND trim(p.status)="WAITING")
      JOIN (j
      WHERE j.ags_job_id=p.ags_job_id)
    ELSEIF (working_mode=1)
     PLAN (p
      WHERE p.ags_prsnl_data_id >= beg_data_id
       AND p.ags_prsnl_data_id <= end_data_id)
      JOIN (j
      WHERE j.ags_job_id=p.ags_job_id)
    ELSEIF (working_mode=2)
     PLAN (o
      WHERE p.ags_prsnl_data_id >= beg_data_id
       AND p.ags_prsnl_data_id <= end_data_id
       AND ((p.person_id+ 0) < 1))
      JOIN (j
      WHERE j.ags_job_id=p.ags_job_id)
    ELSE
     PLAN (p
      WHERE p.ags_prsnl_data_id >= beg_data_id
       AND p.ags_prsnl_data_id <= end_data_id
       AND trim(p.status) IN ("IN ERROR", "BACK OUT"))
      JOIN (j
      WHERE j.ags_job_id=p.ags_job_id)
    ENDIF
    INTO "nl:"
    FROM ags_prsnl_data p,
     ags_job j
    HEAD REPORT
     stat = alterlist(hold->qual,data_size), idx = 0
    HEAD p.ags_prsnl_data_id
     idx = (idx+ 1)
     IF (idx > size(hold->qual,5))
      stat = alterlist(hold->qual,(idx+ data_size))
     ENDIF
     hold->qual[idx].ags_prsnl_data_id = p.ags_prsnl_data_id
     IF ((contrib_rec->qual_knt > 0))
      IF (size(trim(p.sending_facility,3)) > 0)
       pos = 0, pos = locateval(num,1,contrib_rec->qual_knt,p.sending_facility,contrib_rec->qual[num]
        .sending_facility)
       IF (pos > 0)
        hold->qual[idx].contrib_idx = pos
       ELSE
        contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
         contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(p
         .sending_facility,3),
        hold->qual[idx].contrib_idx = contrib_rec->qual_knt
       ENDIF
      ELSEIF (size(trim(j.sending_system,3)) > 0)
       pos = 0, pos = locateval(num,1,contrib_rec->qual_knt,j.sending_system,contrib_rec->qual[num].
        sending_facility)
       IF (pos > 0)
        hold->qual[idx].contrib_idx = pos
       ELSE
        contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
         contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(j
         .sending_system,3),
        hold->qual[idx].contrib_idx = contrib_rec->qual_knt
       ENDIF
      ELSE
       hold->qual[idx].contrib_idx = - (1), hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].
         stat_msg),"[contrib]")
      ENDIF
     ELSE
      IF (size(trim(p.sending_facility,3)) > 0)
       contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
        contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(p
        .sending_facility,3),
       hold->qual[idx].contrib_idx = contrib_rec->qual_knt
      ELSEIF (size(trim(j.sending_system,3)) > 0)
       contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
        contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(j
        .sending_system,3),
       hold->qual[idx].contrib_idx = contrib_rec->qual_knt
      ELSE
       hold->qual[idx].contrib_idx = - (1), hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].
         stat_msg),"[contrib]")
      ENDIF
     ENDIF
     hold->qual[idx].person_id = p.person_id, hold->qual[idx].organization_id = p.organization_id,
     hold->qual[idx].ext_alias = trim(p.ext_alias,3),
     hold->qual[idx].dea_alias = trim(p.dea_alias,3), hold->qual[idx].upin_alias = trim(p.upin_alias,
      3), hold->qual[idx].med_alias = trim(p.med_alias,3),
     hold->qual[idx].ext_link_alias = trim(p.ext_link_alias,3), hold->qual[idx].ssn_alias = trim(p
      .ssn_alias,3)
     IF (((cnvtint(hold->qual[idx].ssn_alias)=0) OR (cnvtint(hold->qual[idx].ssn_alias)=999999999)) )
      hold->qual[idx].ssn_alias = "", hold->qual[idx].s_int_ssn_alias = ""
     ELSE
      hold->qual[idx].s_int_ssn_alias = trim(cnvtstring(cnvtint(hold->qual[idx].ssn_alias)))
     ENDIF
     hold->qual[idx].name_first = trim(p.name_first,3), hold->qual[idx].name_middle = trim(p
      .name_middle,3), hold->qual[idx].name_last = trim(p.name_last,3),
     hold->qual[idx].name_full = trim(p.name_full,3), hold->qual[idx].name_degree = trim(p
      .name_degree,3), hold->qual[idx].name_title = trim(p.name_title,3),
     hold->qual[idx].sex_string = trim(p.gender,3), hold->qual[idx].birth_date = trim(p.birth_date,3),
     hold->qual[idx].street_addr = trim(p.street_addr,3),
     hold->qual[idx].street_addr2 = trim(p.street_addr2,3), hold->qual[idx].city = trim(p.city,3),
     hold->qual[idx].county = trim(p.county,3),
     hold->qual[idx].state = trim(p.state,3), hold->qual[idx].country = trim(p.country,3), hold->
     qual[idx].zip = trim(p.zipcode,3),
     hold->qual[idx].phone_business = trim(p.phone_business,3), hold->qual[idx].phone_fax = trim(p
      .phone_fax,3)
     IF (cnvtupper(hold->qual[idx].street_addr)="<DEL>")
      hold->qual[idx].address_action_flag = 1, found_address_delete = true
     ELSEIF ( NOT ((hold->qual[idx].street_addr > " "))
      AND  NOT ((hold->qual[idx].street_addr2 > " "))
      AND  NOT ((hold->qual[idx].city > " "))
      AND  NOT ((hold->qual[idx].county > " "))
      AND  NOT ((hold->qual[idx].state > " "))
      AND  NOT ((hold->qual[idx].country > " "))
      AND  NOT ((hold->qual[idx].zip > " ")))
      hold->qual[idx].address_action_flag = 2
     ELSE
      hold->qual[idx].address_action_flag = 0
     ENDIF
     IF (cnvtupper(hold->qual[idx].phone_business)="<DEL>")
      hold->qual[idx].phone_business_action_flag = 1, found_phone_business_delete = true
     ELSEIF ( NOT ((hold->qual[idx].phone_business > " ")))
      hold->qual[idx].phone_business_action_flag = 2
     ELSE
      hold->qual[idx].phone_business_action_flag = 0
     ENDIF
     IF (cnvtupper(hold->qual[idx].phone_fax)="<DEL>")
      hold->qual[idx].phone_fax_action_flag = 1, found_phone_fax_delete = true
     ELSEIF ( NOT ((hold->qual[idx].phone_fax > " ")))
      hold->qual[idx].phone_fax_action_flag = 2
     ELSE
      hold->qual[idx].phone_fax_action_flag = 0
     ENDIF
     hold->qual[idx].ext_org_alias = trim(p.ext_org_alias,3), hold->qual[idx].specialty = trim(p
      .specialty_code,3), hold->qual[idx].specialty_desc = trim(p.specialty_desc,3),
     hold->qual[idx].birth_dt_tm = cnvtdate2(trim(p.birth_date,3),"YYYYMMDD"), hold->qual[idx].sex_cd
      =
     IF ((hold->qual[idx].sex_string="M")) male_sex_cd
     ELSEIF ((hold->qual[idx].sex_string="F")) female_sex_cd
     ELSE unknown_sex_cd
     ENDIF
     IF ((hold->qual[idx].person_id=0))
      hold->qual[idx].person_exists_ind = 0
     ELSE
      hold->qual[idx].person_exists_ind = 1
     ENDIF
     hold->qual[idx].ext_alias_exists_ind = 0, hold->qual[idx].ssn_alias_exists_ind = 0, hold->qual[
     idx].dea_alias_exists_ind = 0,
     hold->qual[idx].upin_alias_exists_ind = 0, hold->qual[idx].link_alias_exists_ind = 0, hold->
     qual[idx].address_id = 0,
     hold->qual[idx].address_exists_ind = 0, hold->qual[idx].prsnl_person_name_id = 0, hold->qual[idx
     ].prsnl_name_exists_ind = 0,
     hold->qual[idx].current_person_name_id = 0, hold->qual[idx].current_name_exists_ind = 0, hold->
     qual[idx].phone_business_id = 0,
     hold->qual[idx].phone_business_exists_ind = 0, hold->qual[idx].phone_fax_id = 0, hold->qual[idx]
     .phone_fax_exists_ind = 0,
     hold->qual[idx].alt_alias1 = trim(p.alt_alias1,3), hold->qual[idx].alt_alias1_type = trim(p
      .alt_alias1_type,3)
     IF ((hold->qual[idx].alt_alias1 > " "))
      pos = 0, pos = locateval(num,1,alt_rec->qual_knt,p.alt_alias1_type,alt_rec->qual[num].
       esi_alias_type)
      IF (pos > 0)
       hold->qual[idx].alt1_idx = pos
      ELSE
       alt_rec->qual_knt = (alt_rec->qual_knt+ 1), stat = alterlist(alt_rec->qual,alt_rec->qual_knt),
       alt_rec->qual[alt_rec->qual_knt].esi_alias_type = trim(p.alt_alias1_type,3),
       alt_rec->qual[alt_rec->qual_knt].contrib_idx = hold->qual[idx].contrib_idx, hold->qual[idx].
       alt1_idx = alt_rec->qual_knt
      ENDIF
     ELSE
      hold->qual[idx].alt1_idx = - (1)
     ENDIF
     hold->qual[idx].alt_alias2 = trim(p.alt_alias2,3), hold->qual[idx].alt_alias2_type = trim(p
      .alt_alias2_type,3)
     IF ((hold->qual[idx].alt_alias2 > " "))
      pos = 0, pos = locateval(num,1,alt_rec->qual_knt,p.alt_alias2_type,alt_rec->qual[num].
       esi_alias_type)
      IF (pos > 0)
       hold->qual[idx].alt2_idx = pos
      ELSE
       alt_rec->qual_knt = (alt_rec->qual_knt+ 1), stat = alterlist(alt_rec->qual,alt_rec->qual_knt),
       alt_rec->qual[alt_rec->qual_knt].esi_alias_type = trim(p.alt_alias2_type,3),
       alt_rec->qual[alt_rec->qual_knt].contrib_idx = hold->qual[idx].contrib_idx, hold->qual[idx].
       alt2_idx = alt_rec->qual_knt
      ENDIF
     ELSE
      hold->qual[idx].alt2_idx = - (1)
     ENDIF
    FOOT REPORT
     hold->qual_knt = idx, stat = alterlist(hold->qual,idx)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "AGS_PRSNL_DATA LOADING"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_PRSNL_DATA LOADING :: Select Error :: ",trim(
      serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   IF ((hold->qual_knt > 0))
    IF ((contrib_rec->qual_knt > 0))
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
      HEAD cva.alias
       contrib_rec->qual[d.seq].sending_facility = cva.alias, contrib_rec->qual[d.seq].
       contributor_system_cd = cs.contributor_system_cd, contrib_rec->qual[d.seq].
       contributor_source_cd = cs.contributor_source_cd,
       contrib_rec->qual[d.seq].time_zone_flag = cs.time_zone_flag, contrib_rec->qual[d.seq].
       time_zone = cs.time_zone, contrib_rec->qual[d.seq].time_zone_idx = datetimezonebyname(
        contrib_rec->qual[d.seq].time_zone),
       contrib_rec->qual[d.seq].prsnl_person_id = cs.prsnl_person_id, contrib_rec->qual[d.seq].
       organization_id = cs.organization_id, found_ext_alias = false,
       found_ssn_alias = false, found_dea_alias = false, found_upin_alias = false,
       found_link_alias = false, found_med_alias = false
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
       IF (found_dea_alias=false
        AND eat.esi_alias_field_cd=dea_alias_field_cd)
        found_dea_alias = true, contrib_rec->qual[d.seq].dea_alias_pool_cd = eat.alias_pool_cd,
        contrib_rec->qual[d.seq].dea_alias_type_cd = eat.alias_entity_alias_type_cd
       ENDIF
       IF (found_upin_alias=false
        AND eat.esi_alias_field_cd=upin_alias_field_cd)
        found_upin_alias = true, contrib_rec->qual[d.seq].upin_alias_pool_cd = eat.alias_pool_cd,
        contrib_rec->qual[d.seq].upin_alias_type_cd = eat.alias_entity_alias_type_cd
       ENDIF
       IF (found_link_alias=false
        AND eat.esi_alias_field_cd=link_alias_field_cd)
        found_link_alias = true, contrib_rec->qual[d.seq].link_alias_pool_cd = eat.alias_pool_cd,
        contrib_rec->qual[d.seq].link_alias_type_cd = eat.alias_entity_alias_type_cd
       ENDIF
       IF (found_med_alias=false
        AND eat.esi_alias_field_cd=med_alias_field_cd)
        found_med_alias = true, contrib_rec->qual[d.seq].med_alias_pool_cd = eat.alias_pool_cd,
        contrib_rec->qual[d.seq].med_alias_type_cd = eat.alias_entity_alias_type_cd
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
    ELSE
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
    FOR (fidx = 1 TO hold->qual_knt)
      IF ((hold->qual[fidx].contrib_idx > 0))
       IF ((contrib_rec->qual[hold->qual[fidx].contrib_idx].contributor_system_cd < 1))
        SET hold->qual[fidx].contrib_idx = - (1)
        SET hold->qual[fidx].stat_msg = concat(trim(hold->qual[fidx].stat_msg),"[contrib]")
       ENDIF
      ENDIF
      IF ( NOT ((hold->qual[fidx].ext_alias > " ")))
       SET hold->qual[fidx].contrib_idx = - (1)
       SET hold->qual[fidx].stat_msg = concat(trim(hold->qual[fidx].stat_msg),"[ext]")
      ENDIF
      IF ( NOT ((hold->qual[fidx].name_last > " ")))
       SET hold->qual[fidx].contrib_idx = - (1)
       SET hold->qual[fidx].stat_msg = concat(trim(hold->qual[fidx].stat_msg),"[name]")
      ENDIF
    ENDFOR
    IF ((alt_rec->qual_knt > 0))
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM esi_alias_trans eat,
       (dummyt d  WITH seq = value(alt_rec->qual_knt))
      PLAN (d
       WHERE (alt_rec->qual[d.seq].contrib_idx > 0))
       JOIN (eat
       WHERE (eat.contributor_system_cd=contrib_rec->qual[alt_rec->qual[d.seq].contrib_idx].
       contributor_system_cd)
        AND (eat.esi_alias_type=alt_rec->qual[d.seq].esi_alias_type)
        AND eat.alias_entity_name="PERSONNEL"
        AND eat.esi_alias_field_cd=alt_alias_field_cd
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
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("GET ALT VALUES :: Select Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echorecord(contrib_rec)
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat(trim(cnvtstring(hold->qual_knt)),
     " Rows Found For Processing")
    CALL echo("***")
    CALL echo("***   Determine External Alias Handling")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      prsnl_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 1)
       AND (hold->qual[d.seq].ext_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id)
       AND p.alias=trim(hold->qual[d.seq].ext_alias)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_pool_cd)
       AND (p.prsnl_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_type_cd)
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].person_exists_ind = 1, hold->qual[d.seq].ext_alias_exists_ind = 1
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "EXT_ALIAS_ID CHK1"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("EXT_ALIAS_ID CHK1 :: Select Error :: ",trim(serrmsg)
      )
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      prsnl_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id < 1)
       AND (hold->qual[d.seq].ext_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE p.alias=trim(hold->qual[d.seq].ext_alias)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_pool_cd)
       AND (p.prsnl_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_type_cd)
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].person_exists_ind = 1, hold->qual[d.seq].person_id = p.person_id, hold->qual[
      d.seq].ext_alias_exists_ind = 1
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "EXT_ALIAS_ID CHK2"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("EXT_ALIAS_ID CHK2 :: Select Error :: ",trim(serrmsg)
      )
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Get STATE_CD, COUNTY_CD, COUNTRY_CD Values")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      code_value cv
     PLAN (d
      WHERE (hold->qual[d.seq].state > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (cv
      WHERE cv.code_set=62
       AND cv.display_key=cnvtalphanum(cnvtupper(hold->qual[d.seq].state))
       AND cv.active_ind=1)
     DETAIL
      hold->qual[d.seq].state_cd = cv.code_value
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "GET STATE_CD"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("GET STATE_CD :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      code_value cv
     PLAN (d
      WHERE (hold->qual[d.seq].county > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (cv
      WHERE cv.code_set=74
       AND cv.display_key=cnvtalphanum(cnvtupper(hold->qual[d.seq].county))
       AND cv.active_ind=1)
     DETAIL
      hold->qual[d.seq].county_cd = cv.code_value
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "GET COUNTY_CD"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("GET COUNTY_CD :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      code_value cv
     PLAN (d
      WHERE (hold->qual[d.seq].country > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (cv
      WHERE cv.code_set=15
       AND cv.display_key=cnvtalphanum(cnvtupper(hold->qual[d.seq].country))
       AND cv.active_ind=1)
     DETAIL
      hold->qual[d.seq].country_cd = cv.code_value
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "GET COUNTRY_CD"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("GET COUNTRY_CD :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Check for Existence SSN, DEA, UPIN, LINK, PHONE, FAX, ADDRESS, NAME")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].ssn_alias > " "))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ssn_alias_pool_cd)
       AND (p.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ssn_alias_type_cd
      ))
     DETAIL
      IF ((p.alias=hold->qual[d.seq].s_int_ssn_alias))
       hold->qual[d.seq].ssn_alias_exists_ind = 1, hold->qual[d.seq].ssn_person_alias_id = p
       .person_alias_id
       IF (((p.active_ind < 1) OR (datetimediff(p.end_effective_dt_tm,cnvtdatetime(curdate,curtime3))
        < 0)) )
        hold->qual[d.seq].found_ssn_ind = true
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CHECK SSN"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("CHECK SSN :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      prsnl_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].dea_alias_pool_cd)
       AND (p.prsnl_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].dea_alias_type_cd)
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].dea_alias_exists_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CHECK DEA"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("CHECK DEA :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      prsnl_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].upin_alias_pool_cd)
       AND (p.prsnl_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].upin_alias_type_cd
      )
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].upin_alias_exists_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CHECK UPIN"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("CHECK UPIN :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      prsnl_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].link_alias_pool_cd)
       AND (p.prsnl_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].link_alias_type_cd
      )
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].link_alias_exists_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CHECK LINK"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("CHECK LINK :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      prsnl_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].med_alias_pool_cd)
       AND (p.prsnl_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].med_alias_type_cd)
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].med_alias_exists_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CHECK MED"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("CHECK MED :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF ((alt_rec->qual_knt > 0))
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(hold->qual_knt)),
       prsnl_alias p
      PLAN (d
       WHERE (hold->qual[d.seq].person_id > 0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].alt_alias1 > " ")
        AND (hold->qual[d.seq].alt1_idx > 0))
       JOIN (p
       WHERE (p.person_id=hold->qual[d.seq].person_id)
        AND (p.alias_pool_cd=alt_rec->qual[hold->qual[d.seq].alt1_idx].alt_alias_pool_cd)
        AND (p.prsnl_alias_type_cd=alt_rec->qual[hold->qual[d.seq].alt1_idx].alt_alias_type_cd)
        AND p.active_ind=1)
      DETAIL
       hold->qual[d.seq].alt_alias1_exists_ind = 1
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "CHECK ALT_ALIAS1"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("CHECK ALT_ALIAS1 :: Select Error :: ",trim(serrmsg)
       )
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(hold->qual_knt)),
       prsnl_alias p
      PLAN (d
       WHERE (hold->qual[d.seq].person_id > 0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].alt_alias2 > " ")
        AND (hold->qual[d.seq].alt2_idx > 0))
       JOIN (p
       WHERE (p.person_id=hold->qual[d.seq].person_id)
        AND (p.alias_pool_cd=alt_rec->qual[hold->qual[d.seq].alt2_idx].alt_alias_pool_cd)
        AND (p.prsnl_alias_type_cd=alt_rec->qual[hold->qual[d.seq].alt2_idx].alt_alias_type_cd)
        AND p.active_ind=1)
      DETAIL
       hold->qual[d.seq].alt_alias2_exists_ind = 1
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "CHECK ALT_ALIAS2"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("CHECK ALT_ALIAS2 :: Select Error :: ",trim(serrmsg)
       )
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      phone p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.parent_entity_id=hold->qual[d.seq].person_id)
       AND p.parent_entity_name="PERSON"
       AND p.phone_type_cd=work_phone_type_cd
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].phone_business_id = p.phone_id, hold->qual[d.seq].phone_business_exists_ind
       = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CHECK PHONE"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("CHECK PHONE :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      phone p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.parent_entity_id=hold->qual[d.seq].person_id)
       AND p.parent_entity_name="PERSON"
       AND p.phone_type_cd=fax_phone_type_cd
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].phone_fax_id = p.phone_id, hold->qual[d.seq].phone_fax_exists_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CHECK FAX"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("CHECK FAX :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      address a
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0.0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (a
      WHERE (a.parent_entity_id=hold->qual[d.seq].person_id)
       AND a.parent_entity_name="PERSON"
       AND a.address_type_cd=work_addr_type_cd
       AND a.active_ind=1)
     DETAIL
      hold->qual[d.seq].address_id = a.address_id, hold->qual[d.seq].address_exists_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CHECK ADDRESS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("CHECK ADDRESS :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_name pn
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0.0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pn
      WHERE (pn.person_id=hold->qual[d.seq].person_id)
       AND pn.name_type_cd=prsnl_name_type_cd
       AND pn.active_ind=1)
     DETAIL
      hold->qual[d.seq].prsnl_person_name_id = pn.person_name_id, hold->qual[d.seq].
      prsnl_name_exists_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CHECK PRSNL NAME"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("CHECK PRSNL NAME :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_name pn
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0.0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pn
      WHERE (pn.person_id=hold->qual[d.seq].person_id)
       AND pn.name_type_cd=current_name_type_cd
       AND pn.active_ind=1)
     DETAIL
      hold->qual[d.seq].current_person_name_id = pn.person_name_id, hold->qual[d.seq].
      current_name_exists_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CHECK CURRENT NAME"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("CHECK CURRENT NAME :: Select Error :: ",trim(serrmsg
       ))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    FOR (temp_i = 1 TO hold->qual_knt)
      IF ((hold->qual[temp_i].person_id < 1)
       AND (hold->qual[temp_i].contrib_idx > 0))
       SET ierrcode = error(serrmsg,1)
       SET ierrcode = 0
       SELECT INTO "nl:"
        y = seq(person_only_seq,nextval)
        FROM dual
        DETAIL
         hold->qual[temp_i].person_id = cnvtreal(y)
        WITH format, nocounter
       ;end select
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = gen_nbr_error
        SET table_name = "GENERATE PERSON_ID"
        SET ilog_status = 1
        SET log->qual_knt = (log->qual_knt+ 1)
        SET stat = alterlist(log->qual,log->qual_knt)
        SET log->qual[log->qual_knt].smsgtype = "ERROR"
        SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
        SET log->qual[log->qual_knt].smsg = concat("GENERATE PERSON_ID :: Generate Error :: ",trim(
          serrmsg))
        SET serrmsg = log->qual[log->qual_knt].smsg
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
    CALL echorecord(hold)
    CALL echo("***")
    CALL echo("***   Insert Person")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM person p,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET p.person_id = hold->qual[d.seq].person_id, p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p
      .updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      p.updt_task = 4249900, p.updt_cnt = 0, p.updt_applctx = 4249900,
      p.create_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, p
      .create_dt_tm = cnvtdatetime(dates->now_dt_tm), p.data_status_cd = auth_data_status_cd,
      p.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.data_status_prsnl_id = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, p.contributor_system_cd = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      p.active_ind = 1, p.active_status_cd = active_active_status_cd, p.active_status_prsnl_id =
      contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      p.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.beg_effective_dt_tm = cnvtdatetime(
       dates->now_dt_tm), p.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm),
      p.person_type_cd = person_person_type_cd, p.name_last = hold->qual[d.seq].name_last, p
      .name_first = hold->qual[d.seq].name_first,
      p.name_middle = hold->qual[d.seq].name_middle, p.name_last_key = cnvtupper(cnvtalphanum(hold->
        qual[d.seq].name_last)), p.name_first_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].
        name_first)),
      p.name_middle_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].name_middle)), p
      .name_full_formatted = concat(hold->qual[d.seq].name_last,", ",hold->qual[d.seq].name_first," ",
       hold->qual[d.seq].name_middle), p.birth_dt_tm = cnvtdatetime(hold->qual[d.seq].birth_dt_tm),
      p.abs_birth_dt_tm = datetimezone(hold->qual[d.seq].birth_dt_tm,contrib_rec->qual[hold->qual[d
       .seq].contrib_idx].time_zone_idx,1), p.sex_cd = hold->qual[d.seq].sex_cd, p.autopsy_cd = 0,
      p.birth_dt_cd = 0, p.cause_of_death = "", p.deceased_cd = 0,
      p.ethnic_grp_cd = 0, p.language_cd = 0, p.marital_type_cd = 0,
      p.purge_option_cd = 0, p.race_cd = 0, p.religion_cd = 0,
      p.sex_age_change_ind = 0, p.language_dialect_cd = 0, p.name_phonetic = "",
      p.species_cd = 0, p.confid_level_cd = 0, p.vip_cd = 0,
      p.name_first_synonym_id = 0, p.citizenship_cd = 0, p.vet_military_status_cd = 0,
      p.mother_maiden_name = "", p.nationality_cd = 0, p.ft_entity_name = "",
      p.ft_entity_id = 0, p.name_first_phonetic = "", p.name_last_phonetic = "",
      p.name_last_key_nls = "", p.name_first_key_nls = "", p.name_middle_key_nls = "",
      p.military_rank_cd = 0, p.military_base_location = "", p.military_service_cd = 0,
      p.deceased_source_cd = 0, p.cause_of_death_cd = 0, p.birth_tz = contrib_rec->qual[hold->qual[d
      .seq].contrib_idx].time_zone_idx,
      p.birth_prec_flag = 0
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].person_exists_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT PERSON"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT PERSON :: Insert Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM person p,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p.updt_id = contrib_rec->qual[hold->qual[d
      .seq].contrib_idx].prsnl_person_id, p.updt_task = 4249900,
      p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = 4249900
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].person_exists_ind=1)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "UPDATE PERSON"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("BLIND UPDATE PERSON :: Update Error :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF (working_mode != 2)
     CALL echo("***")
     CALL echo("***   Update Person")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM person p,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p.updt_id = contrib_rec->qual[hold->qual[d
       .seq].contrib_idx].prsnl_person_id, p.updt_task = 4249900,
       p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = 4249900, p.beg_effective_dt_tm = cnvtdatetime(
        dates->now_dt_tm),
       p.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm), p.active_status_dt_tm = cnvtdatetime(
        dates->now_dt_tm), p.name_last = hold->qual[d.seq].name_last,
       p.name_first = hold->qual[d.seq].name_first, p.name_middle = hold->qual[d.seq].name_middle, p
       .name_last_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].name_last)),
       p.name_first_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].name_first)), p.name_middle_key =
       cnvtupper(cnvtalphanum(hold->qual[d.seq].name_middle)), p.name_full_formatted = concat(hold->
        qual[d.seq].name_last,", ",hold->qual[d.seq].name_first," ",hold->qual[d.seq].name_middle),
       p.birth_dt_tm = cnvtdatetime(hold->qual[d.seq].birth_dt_tm), p.abs_birth_dt_tm = datetimezone(
        hold->qual[d.seq].birth_dt_tm,contrib_rec->qual[hold->qual[d.seq].contrib_idx].time_zone_idx,
        1), p.birth_tz = contrib_rec->qual[hold->qual[d.seq].contrib_idx].time_zone_idx,
       p.language_cd = 0, p.sex_cd = hold->qual[d.seq].sex_cd
      PLAN (d
       WHERE (hold->qual[d.seq].person_id > 0)
        AND (hold->qual[d.seq].status != "F")
        AND (hold->qual[d.seq].person_exists_ind=1)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (p
       WHERE (p.person_id=hold->qual[d.seq].person_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = update_error
      SET table_name = "UPDATE PERSON"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE PERSON :: Update Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echo("***")
    CALL echo("***   Insert PRSNL")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM prsnl p,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET p.person_id = hold->qual[d.seq].person_id, p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p
      .updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      p.updt_task = 4249900, p.updt_cnt = 0, p.updt_applctx = 4249900,
      p.create_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, p
      .create_dt_tm = cnvtdatetime(dates->now_dt_tm), p.data_status_cd = auth_data_status_cd,
      p.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.data_status_prsnl_id = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, p.contributor_system_cd = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      p.active_ind = 1, p.active_status_cd = active_active_status_cd, p.active_status_prsnl_id =
      contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      p.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.beg_effective_dt_tm = cnvtdatetime(
       dates->now_dt_tm), p.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm),
      p.prsnl_type_cd = prsnl_type_cd, p.name_last = hold->qual[d.seq].name_last, p.name_first = hold
      ->qual[d.seq].name_first,
      p.name_last_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].name_last)), p.name_first_key =
      cnvtupper(cnvtalphanum(hold->qual[d.seq].name_first)), p.name_full_formatted = concat(hold->
       qual[d.seq].name_last,", ",hold->qual[d.seq].name_first," ",hold->qual[d.seq].name_middle),
      p.physician_ind = 0, p.position_cd = 0, p.department_cd = 0,
      p.free_text_ind = 0, p.section_cd = 0, p.ft_entity_id = 0,
      p.prim_assign_loc_cd = 0, p.log_access_ind = 0, p.log_level = 0,
      p.physician_status_cd = 0
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].person_exists_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT PRSNL"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT PRSNL :: Insert Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF (working_mode != 2)
     CALL echo("***")
     CALL echo("***   Update PRSNL")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM prsnl p,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p.updt_id = contrib_rec->qual[hold->qual[d
       .seq].contrib_idx].prsnl_person_id, p.updt_task = 4249900,
       p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = 4249900, p.beg_effective_dt_tm = cnvtdatetime(
        dates->now_dt_tm),
       p.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm), p.active_status_dt_tm = cnvtdatetime(
        dates->now_dt_tm), p.name_last = hold->qual[d.seq].name_last,
       p.name_first = hold->qual[d.seq].name_first, p.name_last_key = cnvtupper(cnvtalphanum(hold->
         qual[d.seq].name_last)), p.name_first_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].
         name_first)),
       p.name_full_formatted = concat(hold->qual[d.seq].name_last,", ",hold->qual[d.seq].name_first,
        " ",hold->qual[d.seq].name_middle), p.contributor_system_cd = contrib_rec->qual[hold->qual[d
       .seq].contrib_idx].contributor_system_cd, p.prsnl_type_cd = prsnl_type_cd,
       p.physician_ind = 0, p.position_cd = 0
      PLAN (d
       WHERE (hold->qual[d.seq].person_id > 0)
        AND (hold->qual[d.seq].status != "F")
        AND (hold->qual[d.seq].person_exists_ind=1)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (p
       WHERE (p.person_id=hold->qual[d.seq].person_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = update_error
      SET table_name = "UPDATE PRSNL"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE PRSNL :: Update Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM person_alias pa,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET pa.person_alias_id = seq(person_seq,nextval), pa.person_id = hold->qual[d.seq].person_id, pa
      .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
      pa.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.updt_task =
      4249900, pa.updt_cnt = 0,
      pa.updt_applctx = 4249900, pa.data_status_cd = auth_data_status_cd, pa.data_status_dt_tm =
      cnvtdatetime(dates->now_dt_tm),
      pa.data_status_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa
      .contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      pa.active_ind = 1,
      pa.active_status_cd = active_active_status_cd, pa.active_status_prsnl_id = contrib_rec->qual[
      hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.active_status_dt_tm = cnvtdatetime(dates->
       now_dt_tm),
      pa.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), pa.end_effective_dt_tm = cnvtdatetime(
       dates->end_dt_tm), pa.alias_pool_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      ssn_alias_pool_cd,
      pa.person_alias_type_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].ssn_alias_type_cd,
      pa.alias = trim(hold->qual[d.seq].s_int_ssn_alias), pa.person_alias_sub_type_cd = 0,
      pa.check_digit = 0, pa.check_digit_method_cd = 0
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].ssn_alias_exists_ind=0)
       AND (hold->qual[d.seq].ssn_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pa)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT SSN"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT SSN :: Insert Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo(build("***   ssn_mult_ind :",ssn_mult_ind))
    CALL echo("***")
    IF (ssn_mult_ind=0)
     CALL echo("***")
     CALL echo("***   Inactivate and Ineffective previous SSN")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM person_alias pa,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET pa.active_ind = 0, pa.end_effective_dt_tm =
       IF (datetimediff(pa.end_effective_dt_tm,cnvtdatetime(dates->now_dt_tm)) < 0) pa
        .end_effective_dt_tm
       ELSE cnvtdatetime(dates->now_dt_tm)
       ENDIF
      PLAN (d
       WHERE (hold->qual[d.seq].person_id > 0)
        AND (hold->qual[d.seq].status != "F")
        AND (hold->qual[d.seq].ssn_alias_exists_ind=0)
        AND (hold->qual[d.seq].ssn_alias > " ")
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (pa
       WHERE (pa.person_id=hold->qual[d.seq].person_id)
        AND (pa.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       ssn_alias_type_cd)
        AND pa.alias != trim(hold->qual[d.seq].s_int_ssn_alias)
        AND pa.active_ind=1)
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = update_error
      SET table_name = "UPDATE SSN"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE SSN (EXISTS_IND = 0) 1:: Update Error :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ELSE
     CALL echo("***")
     CALL echo("***   Ineffective previous SSN")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM person_alias pa,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET pa.end_effective_dt_tm =
       IF (datetimediff(pa.end_effective_dt_tm,cnvtdatetime(dates->now_dt_tm)) < 0) pa
        .end_effective_dt_tm
       ELSE cnvtdatetime(dates->now_dt_tm)
       ENDIF
      PLAN (d
       WHERE (hold->qual[d.seq].person_id > 0)
        AND (hold->qual[d.seq].status != "F")
        AND (hold->qual[d.seq].ssn_alias_exists_ind=0)
        AND (hold->qual[d.seq].ssn_alias > " ")
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (pa
       WHERE (pa.person_id=hold->qual[d.seq].person_id)
        AND (pa.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       ssn_alias_type_cd)
        AND pa.alias != trim(hold->qual[d.seq].s_int_ssn_alias)
        AND pa.end_effective_dt_tm >= cnvtdatetime(dates->now_dt_tm))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = update_error
      SET table_name = "UPDATE SSN"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE SSN (EXISTS_IND = 0) 2:: Update Error :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echo("***")
    CALL echo("***   Handle FOUND_SSN_IND = TRUE")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM person_alias pa,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET pa.active_ind = 1, pa.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm)
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].ssn_alias_exists_ind=1)
       AND (hold->qual[d.seq].ssn_person_alias_id > 0)
       AND (hold->qual[d.seq].ssn_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].found_ssn_ind=true))
      JOIN (pa
      WHERE (pa.person_alias_id=hold->qual[d.seq].ssn_person_alias_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "UPDATE SSN"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat(
      "UPDATE SSN (FOUND_SSN_IND = TRUE) :: Update Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF (ssn_mult_ind=0)
     CALL echo("***")
     CALL echo("***   Inactive and Ineffective previous SSN")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM person_alias pa,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET pa.active_ind = 0, pa.end_effective_dt_tm =
       IF (datetimediff(pa.end_effective_dt_tm,cnvtdatetime(dates->now_dt_tm)) < 0) pa
        .end_effective_dt_tm
       ELSE cnvtdatetime(dates->now_dt_tm)
       ENDIF
      PLAN (d
       WHERE (hold->qual[d.seq].person_id > 0)
        AND (hold->qual[d.seq].status != "F")
        AND (hold->qual[d.seq].ssn_alias_exists_ind=1)
        AND (hold->qual[d.seq].ssn_person_alias_id > 0)
        AND (hold->qual[d.seq].ssn_alias > " ")
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].found_ssn_ind=true))
       JOIN (pa
       WHERE (pa.person_id=hold->qual[d.seq].person_id)
        AND (pa.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       ssn_alias_type_cd)
        AND pa.alias != trim(hold->qual[d.seq].s_int_ssn_alias)
        AND pa.active_ind=1)
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = update_error
      SET table_name = "UPDATE SSN"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE SSN (Inactivate) :: Update Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ELSE
     CALL echo("***")
     CALL echo("***   Ineffective previous SSN")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM person_alias pa,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET pa.end_effective_dt_tm =
       IF (datetimediff(pa.end_effective_dt_tm,cnvtdatetime(dates->now_dt_tm)) < 0) pa
        .end_effective_dt_tm
       ELSE cnvtdatetime(dates->now_dt_tm)
       ENDIF
      PLAN (d
       WHERE (hold->qual[d.seq].person_id > 0)
        AND (hold->qual[d.seq].status != "F")
        AND (hold->qual[d.seq].ssn_alias_exists_ind=1)
        AND (hold->qual[d.seq].ssn_person_alias_id > 0)
        AND (hold->qual[d.seq].ssn_alias > " ")
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].found_ssn_ind=true))
       JOIN (pa
       WHERE (pa.person_id=hold->qual[d.seq].person_id)
        AND (pa.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       ssn_alias_type_cd)
        AND pa.alias != trim(hold->qual[d.seq].s_int_ssn_alias)
        AND pa.end_effective_dt_tm >= cnvtdatetime(dates->now_dt_tm))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = update_error
      SET table_name = "UPDATE SSN"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE SSN (Ineffective:: Insert Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM prsnl_alias pa,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET pa.prsnl_alias_id = seq(prsnl_seq,nextval), pa.person_id = hold->qual[d.seq].person_id, pa
      .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
      pa.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.updt_task =
      4249900, pa.updt_cnt = 0,
      pa.updt_applctx = 4249900, pa.data_status_cd = auth_data_status_cd, pa.data_status_dt_tm =
      cnvtdatetime(dates->now_dt_tm),
      pa.data_status_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa
      .contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      pa.active_ind = 1,
      pa.active_status_cd = active_active_status_cd, pa.active_status_prsnl_id = contrib_rec->qual[
      hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.active_status_dt_tm = cnvtdatetime(dates->
       now_dt_tm),
      pa.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), pa.end_effective_dt_tm = cnvtdatetime(
       dates->end_dt_tm), pa.alias_pool_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      ext_alias_pool_cd,
      pa.prsnl_alias_type_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_type_cd, pa
      .alias = hold->qual[d.seq].ext_alias, pa.prsnl_alias_sub_type_cd = 0,
      pa.check_digit = 0, pa.check_digit_method_cd = 0
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].ext_alias_exists_ind=0)
       AND (hold->qual[d.seq].ext_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pa)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT EXT_ALIAS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT EXT_ALIAS :: Insert Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM prsnl_alias pa,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET pa.prsnl_alias_id = seq(prsnl_seq,nextval), pa.person_id = hold->qual[d.seq].person_id, pa
      .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
      pa.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.updt_task =
      4249900, pa.updt_cnt = 0,
      pa.updt_applctx = 4249900, pa.data_status_cd = auth_data_status_cd, pa.data_status_dt_tm =
      cnvtdatetime(dates->now_dt_tm),
      pa.data_status_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa
      .contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      pa.active_ind = 1,
      pa.active_status_cd = active_active_status_cd, pa.active_status_prsnl_id = contrib_rec->qual[
      hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.active_status_dt_tm = cnvtdatetime(dates->
       now_dt_tm),
      pa.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), pa.end_effective_dt_tm = cnvtdatetime(
       dates->end_dt_tm), pa.alias_pool_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      dea_alias_pool_cd,
      pa.prsnl_alias_type_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].dea_alias_type_cd, pa
      .alias = hold->qual[d.seq].dea_alias, pa.prsnl_alias_sub_type_cd = 0,
      pa.check_digit = 0, pa.check_digit_method_cd = 0
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].dea_alias_exists_ind=0)
       AND (hold->qual[d.seq].dea_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pa)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT DEA"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT DEA :: Insert Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM prsnl_alias pa,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET pa.prsnl_alias_id = seq(prsnl_seq,nextval), pa.person_id = hold->qual[d.seq].person_id, pa
      .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
      pa.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.updt_task =
      4249900, pa.updt_cnt = 0,
      pa.updt_applctx = 4249900, pa.data_status_cd = auth_data_status_cd, pa.data_status_dt_tm =
      cnvtdatetime(dates->now_dt_tm),
      pa.data_status_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa
      .contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      pa.active_ind = 1,
      pa.active_status_cd = active_active_status_cd, pa.active_status_prsnl_id = contrib_rec->qual[
      hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.active_status_dt_tm = cnvtdatetime(dates->
       now_dt_tm),
      pa.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), pa.end_effective_dt_tm = cnvtdatetime(
       dates->end_dt_tm), pa.alias_pool_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      upin_alias_pool_cd,
      pa.prsnl_alias_type_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].upin_alias_type_cd,
      pa.alias = hold->qual[d.seq].upin_alias, pa.prsnl_alias_sub_type_cd = 0,
      pa.check_digit = 0, pa.check_digit_method_cd = 0
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].upin_alias_exists_ind=0)
       AND (hold->qual[d.seq].upin_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pa)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT UPIN"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT UPIN :: Insert Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM prsnl_alias pa,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET pa.prsnl_alias_id = seq(prsnl_seq,nextval), pa.person_id = hold->qual[d.seq].person_id, pa
      .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
      pa.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.updt_task =
      4249900, pa.updt_cnt = 0,
      pa.updt_applctx = 4249900, pa.data_status_cd = auth_data_status_cd, pa.data_status_dt_tm =
      cnvtdatetime(dates->now_dt_tm),
      pa.data_status_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa
      .contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      pa.active_ind = 1,
      pa.active_status_cd = active_active_status_cd, pa.active_status_prsnl_id = contrib_rec->qual[
      hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.active_status_dt_tm = cnvtdatetime(dates->
       now_dt_tm),
      pa.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), pa.end_effective_dt_tm = cnvtdatetime(
       dates->end_dt_tm), pa.alias_pool_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      link_alias_pool_cd,
      pa.prsnl_alias_type_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].link_alias_type_cd,
      pa.alias = hold->qual[d.seq].ext_link_alias, pa.prsnl_alias_sub_type_cd = 0,
      pa.check_digit = 0, pa.check_digit_method_cd = 0
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].link_alias_exists_ind=0)
       AND (hold->qual[d.seq].ext_link_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pa)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT LINK"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT LINK :: Insert Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM prsnl_alias pa,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET pa.prsnl_alias_id = seq(prsnl_seq,nextval), pa.person_id = hold->qual[d.seq].person_id, pa
      .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
      pa.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.updt_task =
      4249900, pa.updt_cnt = 0,
      pa.updt_applctx = 4249900, pa.data_status_cd = auth_data_status_cd, pa.data_status_dt_tm =
      cnvtdatetime(dates->now_dt_tm),
      pa.data_status_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa
      .contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      pa.active_ind = 1,
      pa.active_status_cd = active_active_status_cd, pa.active_status_prsnl_id = contrib_rec->qual[
      hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.active_status_dt_tm = cnvtdatetime(dates->
       now_dt_tm),
      pa.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), pa.end_effective_dt_tm = cnvtdatetime(
       dates->end_dt_tm), pa.alias_pool_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      med_alias_pool_cd,
      pa.prsnl_alias_type_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].med_alias_type_cd, pa
      .alias = hold->qual[d.seq].med_alias, pa.prsnl_alias_sub_type_cd = 0,
      pa.check_digit = 0, pa.check_digit_method_cd = 0
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].med_alias_exists_ind=0)
       AND (hold->qual[d.seq].med_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pa)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT MED"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT MED :: Insert Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF ((alt_rec->qual_knt > 0))
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM prsnl_alias pa,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET pa.prsnl_alias_id = seq(prsnl_seq,nextval), pa.person_id = hold->qual[d.seq].person_id, pa
       .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
       pa.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.updt_task =
       4249900, pa.updt_cnt = 0,
       pa.updt_applctx = 4249900, pa.data_status_cd = auth_data_status_cd, pa.data_status_dt_tm =
       cnvtdatetime(dates->now_dt_tm),
       pa.data_status_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa
       .contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       contributor_system_cd, pa.active_ind = 1,
       pa.active_status_cd = active_active_status_cd, pa.active_status_prsnl_id = contrib_rec->qual[
       hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.active_status_dt_tm = cnvtdatetime(dates->
        now_dt_tm),
       pa.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), pa.end_effective_dt_tm = cnvtdatetime
       (dates->end_dt_tm), pa.alias_pool_cd = alt_rec->qual[hold->qual[d.seq].alt1_idx].
       alt_alias_pool_cd,
       pa.prsnl_alias_type_cd = alt_rec->qual[hold->qual[d.seq].alt1_idx].alt_alias_type_cd, pa.alias
        = hold->qual[d.seq].alt_alias1, pa.prsnl_alias_sub_type_cd = 0,
       pa.check_digit = 0, pa.check_digit_method_cd = 0
      PLAN (d
       WHERE (hold->qual[d.seq].person_id > 0)
        AND (hold->qual[d.seq].status != "F")
        AND (hold->qual[d.seq].alt_alias1_exists_ind=0)
        AND (hold->qual[d.seq].alt_alias1 > " ")
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].alt1_idx > 0))
       JOIN (pa)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = insert_error
      SET table_name = "INSERT ALT_ALIAS1"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("INSERT ALT_ALIAS1 :: Insert Error :: ",trim(serrmsg
        ))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM prsnl_alias pa,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET pa.prsnl_alias_id = seq(prsnl_seq,nextval), pa.person_id = hold->qual[d.seq].person_id, pa
       .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
       pa.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.updt_task =
       4249900, pa.updt_cnt = 0,
       pa.updt_applctx = 4249900, pa.data_status_cd = auth_data_status_cd, pa.data_status_dt_tm =
       cnvtdatetime(dates->now_dt_tm),
       pa.data_status_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, pa
       .contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       contributor_system_cd, pa.active_ind = 1,
       pa.active_status_cd = active_active_status_cd, pa.active_status_prsnl_id = contrib_rec->qual[
       hold->qual[d.seq].contrib_idx].prsnl_person_id, pa.active_status_dt_tm = cnvtdatetime(dates->
        now_dt_tm),
       pa.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), pa.end_effective_dt_tm = cnvtdatetime
       (dates->end_dt_tm), pa.alias_pool_cd = alt_rec->qual[hold->qual[d.seq].alt2_idx].
       alt_alias_pool_cd,
       pa.prsnl_alias_type_cd = alt_rec->qual[hold->qual[d.seq].alt2_idx].alt_alias_type_cd, pa.alias
        = hold->qual[d.seq].alt_alias2, pa.prsnl_alias_sub_type_cd = 0,
       pa.check_digit = 0, pa.check_digit_method_cd = 0
      PLAN (d
       WHERE (hold->qual[d.seq].person_id > 0)
        AND (hold->qual[d.seq].status != "F")
        AND (hold->qual[d.seq].alt_alias2_exists_ind=0)
        AND (hold->qual[d.seq].alt_alias2 > " ")
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].alt2_idx > 0))
       JOIN (pa)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = insert_error
      SET table_name = "INSERT ALT_ALIAS2"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("INSERT ALT_ALIAS2 :: Insert Error :: ",trim(serrmsg
        ))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echo("***")
    CALL echo("***   Handle Phones")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM phone p,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "PERSON", p.parent_entity_id =
      hold->qual[d.seq].person_id,
      p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p.updt_id = contrib_rec->qual[hold->qual[d.seq].
      contrib_idx].prsnl_person_id, p.updt_task = 4249900,
      p.updt_cnt = 0, p.updt_applctx = 4249900, p.data_status_cd = auth_data_status_cd,
      p.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.data_status_prsnl_id = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, p.contributor_system_cd = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      p.active_ind = 1, p.active_status_cd = active_active_status_cd, p.active_status_prsnl_id =
      contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      p.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.beg_effective_dt_tm = cnvtdatetime(
       dates->now_dt_tm), p.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm),
      p.phone_type_cd = work_phone_type_cd, p.phone_format_cd = us_phone_format_cd, p.phone_num =
      hold->qual[d.seq].phone_business,
      p.phone_type_seq = 0, p.description = "Subscriber Business Phone"
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].phone_business_exists_ind=0)
       AND (hold->qual[d.seq].phone_business > " ")
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].phone_business_action_flag=0))
      JOIN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT PHONE"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT PHONE :: Insert Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF (working_mode != 2)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM phone p,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET p.phone_num = hold->qual[d.seq].phone_business, p.updt_dt_tm = cnvtdatetime(dates->
        now_dt_tm), p.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
       p.updt_task = 4249900, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = 4249900
      PLAN (d
       WHERE (hold->qual[d.seq].phone_business_exists_ind=1)
        AND (hold->qual[d.seq].phone_business_id > 0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].phone_business_action_flag=0))
       JOIN (p
       WHERE (p.phone_id=hold->qual[d.seq].phone_business_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = update_error
      SET table_name = "UPDATE PHONE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE PHONE :: Update Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    IF (found_phone_business_delete=true)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM phone p,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET p.seq = 1
      PLAN (d
       WHERE (hold->qual[d.seq].phone_business_exists_ind=1)
        AND (hold->qual[d.seq].phone_business_id > 0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].phone_business_action_flag=1))
       JOIN (p
       WHERE (p.phone_id=hold->qual[d.seq].phone_business_id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = delete_error
      SET table_name = "DELETE PHONE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("DELETE PHONE :: Delete Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM phone p,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "PERSON", p.parent_entity_id =
      hold->qual[d.seq].person_id,
      p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p.updt_id = contrib_rec->qual[hold->qual[d.seq].
      contrib_idx].prsnl_person_id, p.updt_task = 4249900,
      p.updt_cnt = 0, p.updt_applctx = 4249900, p.data_status_cd = auth_data_status_cd,
      p.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.data_status_prsnl_id = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, p.contributor_system_cd = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      p.active_ind = 1, p.active_status_cd = active_active_status_cd, p.active_status_prsnl_id =
      contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      p.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.beg_effective_dt_tm = cnvtdatetime(
       dates->now_dt_tm), p.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm),
      p.phone_type_cd = fax_phone_type_cd, p.phone_format_cd = us_phone_format_cd, p.phone_num = hold
      ->qual[d.seq].phone_fax,
      p.phone_type_seq = 0, p.description = "Subscriber Business Phone"
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].phone_fax_exists_ind=0)
       AND (hold->qual[d.seq].phone_fax > " ")
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].phone_fax_action_flag=0))
      JOIN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT FAX"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT FAX :: Insert Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF (working_mode != 2)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM phone p,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET p.phone_num = hold->qual[d.seq].phone_fax, p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p
       .updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
       p.updt_task = 4249900, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = 4249900
      PLAN (d
       WHERE (hold->qual[d.seq].phone_fax_exists_ind=1)
        AND (hold->qual[d.seq].phone_fax_id > 0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].phone_fax_action_flag=0))
       JOIN (p
       WHERE (p.phone_id=hold->qual[d.seq].phone_fax_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = update_error
      SET table_name = "UPDATE FAX"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE FAX :: Update Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    IF (found_phone_fax_delete=true)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM phone p,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET p.seq = 1
      PLAN (d
       WHERE (hold->qual[d.seq].phone_fax_exists_ind=1)
        AND (hold->qual[d.seq].phone_fax_id > 0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].phone_fax_action_flag=1))
       JOIN (p
       WHERE (p.phone_id=hold->qual[d.seq].phone_fax_id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = delete_error
      SET table_name = "DELETE FAX"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("DELETE FAX :: Delete Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM address a,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "PERSON", a.parent_entity_id
       = hold->qual[d.seq].person_id,
      a.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), a.updt_id = contrib_rec->qual[hold->qual[d.seq].
      contrib_idx].prsnl_person_id, a.updt_task = 4249900,
      a.updt_cnt = 0, a.updt_applctx = 4249900, a.data_status_cd = auth_data_status_cd,
      a.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), a.data_status_prsnl_id = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, a.contributor_system_cd = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      a.active_ind = 1, a.active_status_cd = active_active_status_cd, a.active_status_prsnl_id =
      contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      a.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), a.beg_effective_dt_tm = cnvtdatetime(
       dates->now_dt_tm), a.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm),
      a.address_type_cd = work_addr_type_cd, a.comment_txt = "Subscriber Address", a.street_addr =
      hold->qual[d.seq].street_addr,
      a.street_addr2 = hold->qual[d.seq].street_addr2, a.city = hold->qual[d.seq].city, a.state =
      hold->qual[d.seq].state,
      a.state_cd = hold->qual[d.seq].state_cd, a.county = hold->qual[d.seq].county, a.county_cd =
      hold->qual[d.seq].county_cd,
      a.country = hold->qual[d.seq].country, a.country_cd = hold->qual[d.seq].country_cd, a.zipcode
       = hold->qual[d.seq].zip,
      a.zipcode_key = hold->qual[d.seq].zip
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].address_exists_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].address_action_flag=0))
      JOIN (a)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT ADDRESS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT ADDRESS :: Insert Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF (working_mode != 2)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM address a,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET a.address_type_cd = work_addr_type_cd, a.comment_txt = "Subscriber Address", a.street_addr
        = hold->qual[d.seq].street_addr,
       a.street_addr2 = hold->qual[d.seq].street_addr2, a.city = hold->qual[d.seq].city, a.state =
       hold->qual[d.seq].state,
       a.state_cd = hold->qual[d.seq].state_cd, a.zipcode = hold->qual[d.seq].zip, a.updt_dt_tm =
       cnvtdatetime(dates->now_dt_tm),
       a.updt_id = 4249900, a.updt_task = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       prsnl_person_id, a.updt_cnt = (a.updt_cnt+ 1),
       a.updt_applctx = 4249900
      PLAN (d
       WHERE (hold->qual[d.seq].address_exists_ind=1)
        AND (hold->qual[d.seq].address_id > 0.0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].address_action_flag=0))
       JOIN (a
       WHERE (a.address_id=hold->qual[d.seq].address_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = update_error
      SET table_name = "UPDATE ADDRESS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE ADDRESS :: Update Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    IF (found_address_delete=true)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM address a,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET a.seq = 1
      PLAN (d
       WHERE (hold->qual[d.seq].address_exists_ind=1)
        AND (hold->qual[d.seq].address_id > 0.0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].address_action_flag=1))
       JOIN (a
       WHERE (a.address_id=hold->qual[d.seq].address_id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = delete_error
      SET table_name = "DELETE ADDRESS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("DELETE ADDRESS :: Delete Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM person_name a,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET a.person_name_id = seq(person_seq,nextval), a.person_id = hold->qual[d.seq].person_id, a
      .name_type_cd = prsnl_name_type_cd,
      a.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), a.updt_id = contrib_rec->qual[hold->qual[d.seq].
      contrib_idx].prsnl_person_id, a.updt_task = 4249900,
      a.updt_cnt = 0, a.updt_applctx = 4249900, a.data_status_cd = auth_data_status_cd,
      a.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), a.data_status_prsnl_id = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, a.contributor_system_cd = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      a.active_ind = 1, a.active_status_cd = active_active_status_cd, a.active_status_prsnl_id =
      contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      a.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), a.beg_effective_dt_tm = cnvtdatetime(
       dates->now_dt_tm), a.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm),
      a.name_full = concat(hold->qual[d.seq].name_last,", ",hold->qual[d.seq].name_first," ",hold->
       qual[d.seq].name_middle), a.name_first = hold->qual[d.seq].name_first, a.name_last = hold->
      qual[d.seq].name_last,
      a.name_middle = hold->qual[d.seq].name_middle, a.name_degree = hold->qual[d.seq].name_degree, a
      .name_title = hold->qual[d.seq].name_title,
      a.name_last_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].name_last)), a.name_first_key =
      cnvtupper(cnvtalphanum(hold->qual[d.seq].name_first)), a.name_middle_key = cnvtupper(
       cnvtalphanum(hold->qual[d.seq].name_middle))
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].prsnl_name_exists_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (a)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT PERSON_NAME PRSNL"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT PERSON_NAME PRSNL :: Insert Error :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF (working_mode != 2)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM person_name a,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET a.name_type_cd = prsnl_name_type_cd, a.name_full = concat(hold->qual[d.seq].name_last,", ",
        hold->qual[d.seq].name_first," ",hold->qual[d.seq].name_middle), a.name_first = hold->qual[d
       .seq].name_first,
       a.name_last = hold->qual[d.seq].name_last, a.name_middle = hold->qual[d.seq].name_middle, a
       .name_degree = hold->qual[d.seq].name_degree,
       a.name_title = hold->qual[d.seq].name_title, a.name_last_key = cnvtupper(cnvtalphanum(hold->
         qual[d.seq].name_last)), a.name_first_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].
         name_first)),
       a.name_middle_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].name_middle)), a.updt_dt_tm =
       cnvtdatetime(dates->now_dt_tm), a.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       prsnl_person_id,
       a.updt_task = 4249900, a.updt_cnt = (a.updt_cnt+ 1), a.updt_applctx = 4249900
      PLAN (d
       WHERE (hold->qual[d.seq].prsnl_name_exists_ind=1)
        AND (hold->qual[d.seq].prsnl_person_name_id > 0.0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (a
       WHERE (a.person_name_id=hold->qual[d.seq].prsnl_person_name_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = update_error
      SET table_name = "UPDATE PERSON_NAME PRSNL"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE PERSON_NAME PRSNL :: Update Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM person_name a,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET a.person_name_id = seq(person_seq,nextval), a.person_id = hold->qual[d.seq].person_id, a
      .name_type_cd = current_name_type_cd,
      a.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), a.updt_id = contrib_rec->qual[hold->qual[d.seq].
      contrib_idx].prsnl_person_id, a.updt_task = 4249900,
      a.updt_cnt = 0, a.updt_applctx = 4249900, a.data_status_cd = auth_data_status_cd,
      a.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), a.data_status_prsnl_id = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, a.contributor_system_cd = contrib_rec->
      qual[hold->qual[d.seq].contrib_idx].contributor_system_cd,
      a.active_ind = 1, a.active_status_cd = active_active_status_cd, a.active_status_prsnl_id =
      contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      a.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), a.beg_effective_dt_tm = cnvtdatetime(
       dates->now_dt_tm), a.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm),
      a.name_full = concat(hold->qual[d.seq].name_last,", ",hold->qual[d.seq].name_first," ",hold->
       qual[d.seq].name_middle), a.name_first = hold->qual[d.seq].name_first, a.name_last = hold->
      qual[d.seq].name_last,
      a.name_middle = hold->qual[d.seq].name_middle, a.name_degree = hold->qual[d.seq].name_degree, a
      .name_title = hold->qual[d.seq].name_title,
      a.name_last_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].name_last)), a.name_first_key =
      cnvtupper(cnvtalphanum(hold->qual[d.seq].name_first)), a.name_middle_key = cnvtupper(
       cnvtalphanum(hold->qual[d.seq].name_middle))
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].current_name_exists_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (a)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "INSERT PERSON_NAME CURRENT"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT PERSON_NAME CURRENT :: Insert Error :: ",trim
      (serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF (working_mode != 2)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM person_name a,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET a.name_type_cd = current_name_type_cd, a.name_full = concat(hold->qual[d.seq].name_last,
        ", ",hold->qual[d.seq].name_first," ",hold->qual[d.seq].name_middle), a.name_first = hold->
       qual[d.seq].name_first,
       a.name_last = hold->qual[d.seq].name_last, a.name_middle = hold->qual[d.seq].name_middle, a
       .name_degree = hold->qual[d.seq].name_degree,
       a.name_title = hold->qual[d.seq].name_title, a.name_last_key = cnvtupper(cnvtalphanum(hold->
         qual[d.seq].name_last)), a.name_first_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].
         name_first)),
       a.name_middle_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].name_middle)), a.updt_dt_tm =
       cnvtdatetime(dates->now_dt_tm), a.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       prsnl_person_id,
       a.updt_task = 4249900, a.updt_cnt = (a.updt_cnt+ 1), a.updt_applctx = 4249900
      PLAN (d
       WHERE (hold->qual[d.seq].current_name_exists_ind=1)
        AND (hold->qual[d.seq].current_person_name_id > 0.0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (a
       WHERE (a.person_name_id=hold->qual[d.seq].current_person_name_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = update_error
      SET table_name = "UPDATE PERSON_NAME CURRENT"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("UPDATE PERSON_NAME CURRENT :: Update Error :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echo("***")
    CALL echo("***   Update Data to Complete")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_prsnl_data o,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET o.status = "COMPLETE", o.stat_msg = "", o.status_dt_tm = cnvtdatetime(dates->now_dt_tm),
      o.person_id = hold->qual[d.seq].person_id, o.contributor_system_cd = contrib_rec->qual[hold->
      qual[d.seq].contrib_idx].contributor_system_cd
     PLAN (d
      WHERE (hold->qual[d.seq].ags_prsnl_data_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (o
      WHERE (o.ags_prsnl_data_id=hold->qual[d.seq].ags_prsnl_data_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = update_error
     SET table_name = "UPDATE PRSNL_DATA COMPLETE"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("UPDATE PRSNL_DATA COMPLETE :: Update Error :: ",trim
      (serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    COMMIT
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_prsnl_data o,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET o.status = "IN ERROR", o.status_dt_tm = cnvtdatetime(dates->now_dt_tm), o.stat_msg = trim(
       substring(1,40,hold->qual[d.seq].stat_msg)),
      o.person_id = 0.0, o.contributor_system_cd = 0.0
     PLAN (d
      WHERE (hold->qual[d.seq].ags_prsnl_data_id > 0)
       AND (hold->qual[d.seq].contrib_idx < 1))
      JOIN (o
      WHERE (o.ags_prsnl_data_id=hold->qual[d.seq].ags_prsnl_data_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = update_error
     SET table_name = "UPDATE PRSNL_DATA IN ERROR"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("UPDATE PRSNL_DATA IN ERROR :: Update Error :: ",trim
      (serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    COMMIT
   ELSE
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = "No Rows Found For Processing"
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
 SET log->qual[log->qual_knt].smsg = "END >> AGS_PRSNL_LOAD"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL echo("***")
  CALL echo("***   END LOGGING")
  CALL echo("***")
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 CALL echo("***")
 CALL echo("***   END AGS_PRSNL_LOAD")
 CALL echo("***")
 SET script_ver = "011 09/08/06"
END GO
