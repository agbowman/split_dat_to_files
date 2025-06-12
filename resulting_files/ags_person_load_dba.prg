CREATE PROGRAM ags_person_load:dba
 IF (validate(reply,"!")="!")
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
 CALL echo("***")
 CALL echo("***   BEG AGS_PERSON_LOAD")
 CALL echo("***")
 EXECUTE ccluarxrtl
 IF (validate(request,"!")="!")
  RECORD request(
    1 debug_logging = i4
    1 ags_task_id = f8
    1 require_ssn = i4
    1 consent_cdf = vc
  )
  SET request->debug_logging = 4
  SET request->ags_task_id = 0
  SET request->require_ssn = 1
  SET request->consent_cdf = "YES"
 ENDIF
 IF (validate(ags_get_code_defined,0)=0)
  EXECUTE ags_get_code
 ENDIF
 IF (validate(ags_log_header_defined,0)=0)
  EXECUTE ags_log_header
 ENDIF
 CALL set_log_level(request->debug_logging)
 DECLARE sconsentcdf = vc WITH public, noconstant(request->consent_cdf)
 DECLARE working_task_id = f8 WITH public, noconstant(request->ags_task_id)
 DECLARE breqssn = i2 WITH public, noconstant(request->require_ssn)
 IF (get_script_status(0) != esuccessful)
  GO TO exit_script
 ENDIF
 DECLARE working_sending_system = vc WITH public, noconstant("")
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
     2 pcp_alias_pool_cd = f8
     2 pcp_alias_type_cd = f8
     2 cmrn_alias_pool_cd = f8
     2 cmrn_alias_type_cd = f8
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
 DECLARE esi_default_cd = f8 WITH public, constant(ags_get_code_by("DISPLAY",73,"Default"))
 DECLARE org_class_cd = f8 WITH public, constant(ags_get_code_by("MEANING",396,"ORG"))
 DECLARE auth_data_status_cd = f8 WITH public, constant(ags_get_code_by("MEANING",8,"AUTH"))
 DECLARE active_active_status_cd = f8 WITH public, constant(ags_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE client_alias_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",334,"CLIENT"))
 DECLARE home_phone_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",43,"HOME"))
 DECLARE alt_phone_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",43,"ALTERNATE"))
 DECLARE us_phone_format_cd = f8 WITH public, constant(ags_get_code_by("MEANING",281,"US"))
 DECLARE home_addr_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",212,"HOME"))
 DECLARE pcp_person_prnsl_r_cd = f8 WITH public, constant(ags_get_code_by("MEANING",331,"PCP"))
 DECLARE client_org_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",278,"CLIENT"))
 DECLARE facility_org_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",278,"FACILITY"))
 DECLARE facility_loc_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",222,"FACILITY"))
 DECLARE prsnl_name_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",213,"PRSNL"))
 DECLARE current_name_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",213,"CURRENT"))
 DECLARE person_person_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",302,"PERSON"))
 DECLARE prsnl_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",309,"USER"))
 DECLARE male_sex_cd = f8 WITH public, constant(ags_get_code_by("MEANING",57,"MALE"))
 DECLARE female_sex_cd = f8 WITH public, constant(ags_get_code_by("MEANING",57,"FEMALE"))
 DECLARE cerner_chr_contributor_source_cd = f8 WITH public, constant(ags_get_code_by("MEANING",73,
   "CERNERCHR"))
 DECLARE ext_alias_field_cd = f8 WITH public, constant(ags_get_code_by("MEANING",4001891,
   "PRSNEXTALIAS"))
 DECLARE ssn_alias_field_cd = f8 WITH public, constant(ags_get_code_by("MEANING",4001891,"PRSNSSN"))
 DECLARE pcp_alias_field_cd = f8 WITH public, constant(ags_get_code_by("MEANING",4001891,
   "PRSNPCPALIAS"))
 DECLARE cmrn_alias_field_cd = f8 WITH public, constant(ags_get_code_by("MEANING",4001891,"PRSNCMRN")
  )
 DECLARE ddefaultstatuscd = f8 WITH public, constant(ags_get_code_by("MEANING",29465,trim(sconsentcdf
    )))
 DECLARE ddefaultconsenttypecd = f8 WITH public, constant(ags_get_code_by("DISPLAYKEY",29467,
   "PRIVACY"))
 DECLARE ddefaultnamecd = f8 WITH public, constant(ags_get_code_by("DISPLAYKEY",29482,"PRIVACYPOLICY"
   ))
 DECLARE dconsentpolicyid = f8 WITH public, noconstant(0.0)
 DECLARE ssn_mult_ind = i2 WITH public, noconstant(true)
 DECLARE found_phone_home_delete = i2 WITH public, noconstant(false)
 DECLARE found_phone_alt_delete = i2 WITH public, noconstant(false)
 DECLARE found_address_delete = i2 WITH public, noconstant(false)
 DECLARE found_pcp_delete = i2 WITH public, noconstant(false)
 CALL echo("***")
 CALL echo("***   Log Starting Conditions")
 CALL echo("***")
 CALL echo(concat("*** request->ags_task_id   : ",cnvtstring(working_task_id)))
 CALL echo(concat("*** request->require_ssn   : ",cnvtstring(breqssn)))
 CALL echo(concat("*** request->debug_logging : ",cnvtstring(request->debug_logging)))
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
   CALL ags_set_status_block(eupdate,efailure,"Update Task to Processing",trim(serrmsg))
   GO TO exit_script
  ENDIF
  COMMIT
 ELSE
  CALL ags_set_status_block(eattribute,efailure,"AGS_TASK","Invalid Task Id")
  GO TO exit_script
 ENDIF
 IF (male_sex_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"MALE_SEX_CD",
   "CODE_VALUE for CDF_MEANING MALE invalid from CODE_SET 57")
  GO TO exit_script
 ENDIF
 IF (female_sex_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"FEMALE_SEX_CD",
   "CODE_VALUE for CDF_MEANING FEMALE invalid from CODE_SET 57")
  GO TO exit_script
 ENDIF
 IF (esi_default_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"ESI_DEFAULT_CD",
   "CODE_VALUE for display Default invalid from CODE_SET 73")
  GO TO exit_script
 ENDIF
 IF (ext_alias_field_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"EXT_ALIAS_FIELD_CD",
   "CODE_VALUE for meaning PRSNEXTALIAS invalid from CODE_SET 4001891")
  GO TO exit_script
 ENDIF
 IF (ssn_alias_field_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"SSN_ALIAS_FIELD_CD",
   "CODE_VALUE for meaning PRSNSSN invalid from CODE_SET 4001891")
  GO TO exit_script
 ENDIF
 IF (cmrn_alias_field_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"CMRN_ALIAS_FIELD_CD",
   "CODE_VALUE for meaning PRSNCMRN invalid from CODE_SET 4001891")
  GO TO exit_script
 ENDIF
 IF (pcp_alias_field_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"PCP_ALIAS_FIELD_CD",
   "CODE_VALUE for meaning PRSNPCPALIAS invalid from CODE_SET 4001891")
  GO TO exit_script
 ENDIF
 IF (cerner_chr_contributor_source_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"CERNER_CHR_CONTRIBUTOR_SOURCE_CD",
   "CODE_VALUE for meaning CERNERCHR invalid from CODE_SET 73")
  GO TO exit_script
 ENDIF
 IF (home_phone_type_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"HOME_PHONE_TYPE_CD",
   "CODE_VALUE for CDF_MEANING HOME invalid from CODE_SET 43")
  GO TO exit_script
 ENDIF
 IF (alt_phone_type_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"ALT_PHONE_TYPE_CD",
   "CODE_VALUE for CDF_MEANING ALTERNATE invalid from CODE_SET 43")
  GO TO exit_script
 ENDIF
 IF (home_addr_type_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"HOME_ADDR_TYPE_CD",
   "CODE_VALUE for CDF_MEANING HOME invalid from CODE_SET 212")
  GO TO exit_script
 ENDIF
 IF (us_phone_format_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"US_PHONE_FORMAT_CD",
   "CODE_VALUE for CDF_MEANING US invalid from CODE_SET 281")
  GO TO exit_script
 ENDIF
 IF (current_name_type_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"CURRENT_NAME_TYPE_CD",
   "CODE_VALUE for CDF_MEANING CURRENT invalid from CODE_SET 213")
  GO TO exit_script
 ENDIF
 IF (pcp_person_prnsl_r_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"PCP_PERSON_PRNSL_R_CD",
   "CODE_VALUE for CDF_MEANING PCP invalid from CODE_SET 331")
  GO TO exit_script
 ENDIF
 IF (ddefaultstatuscd < 1)
  CALL ags_set_status_block(eattribute,efailure,"dDefaultStatusCD",
   "CODE_VALUE for DISPLAY_KEY CONSENTGRANTED invalid from CODE_SET 29465")
  GO TO exit_script
 ENDIF
 IF (ddefaultconsenttypecd < 1)
  CALL ags_set_status_block(eattribute,efailure,"dDefaultConsentTypeCD",
   "CODE_VALUE for DISPLAY_KEY PRIVACY invalid from CODE_SET 29467")
  GO TO exit_script
 ENDIF
 IF (ddefaultnamecd < 1)
  CALL ags_set_status_block(eattribute,efailure,"dDefaultNameCD",
   "CODE_VALUE for DISPLAY_KEY PRIVACYPOLICY invalid from CODE_SET 29482")
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ppr_consent_policy p
  PLAN (p
   WHERE p.organization_id=0.0
    AND p.consent_type_cd=ddefaultconsenttypecd
    AND p.name_cd=ddefaultnamecd
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY p.beg_effective_dt_tm, p.consent_policy_id
  DETAIL
   dconsentpolicyid = p.consent_policy_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL ags_set_status_block(eselect,efailure,"dConsentPolicyID",trim(serrmsg))
  GO TO exit_script
 ENDIF
 IF (dconsentpolicyid < 1)
  CALL ags_set_status_block(eattribute,efailure,"dConsentPolicyID","dConsentPolicyID < 1")
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
  CALL ags_set_status_block(eselect,efailure,"SSN_MULT_IND",trim(serrmsg))
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
  CALL ags_set_status_block(eselect,efailure,"TASK DATA",trim(serrmsg))
  GO TO exit_script
 ENDIF
 IF (curqual < 1)
  CALL ags_set_status_block(eattribute,efailure,"TASK DATA","Invalid TASK_ID")
  GO TO exit_script
 ENDIF
 IF (working_kill_ind > 0)
  CALL ags_set_status_block(eattribute,efailure,"TASK DATA","KILL_IND Set to Kill")
  GO TO exit_script
 ENDIF
 IF (beg_data_id < 1)
  CALL ags_set_status_block(eattribute,efailure,"TASK DATA","BEG_DATA_ID :: Less Than 1")
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***   beg_data_id    :",beg_data_id))
 CALL echo(build("***   max_data_id    :",max_data_id))
 CALL echo(build("***   data_size      :",data_size))
 CALL echo(build("***   working_job_id :",working_job_id))
 CALL echo(build("***   working_mode   :",working_mode))
 CALL echo("***")
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
   max_id = max(p.ags_person_data_id), dknt = count(p.ags_person_data_id)
   FROM ags_person_data p
   PLAN (p
    WHERE p.ags_person_data_id >= beg_data_id
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
   CALL ags_set_status_block(eselect,efailure,"MODE 3 CHK",trim(serrmsg))
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
   CALL ags_set_status_block(eupdate,efailure,"BATCH_END_ID",trim(serrmsg))
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
   CALL ags_set_status_block(ecustom,einfo,"BEGIN PROCESSING",concat("BEG_DATA_ID :: ",trim(
      cnvtstring(beg_data_id))," :: END_DATA_ID :: ",trim(cnvtstring(end_data_id)),
     " :: MAX_DATA_ID :: ",
     trim(cnvtstring(max_data_id))))
   CALL echo("***")
   CALL echo(build("***   beg_data_id    :",beg_data_id))
   CALL echo(build("***   end_data_id    :",end_data_id))
   CALL echo(build("***   working_job_id :",working_job_id))
   CALL echo("***")
   FREE RECORD hold
   RECORD hold(
     1 qual_knt = i4
     1 qual[*]
       2 ags_person_data_id = f8
       2 contrib_idx = i4
       2 run_nbr = f8
       2 run_dt_tm = dq8
       2 file_row_nbr = i4
       2 person_exists_ind = i4
       2 person_id = f8
       2 ext_alias_exists_ind = i4
       2 ext_alias_person_alias_id = f8
       2 ssn_alias_exists_ind = i4
       2 ssn_alias_person_alias_id = f8
       2 address_exists_ind = i4
       2 address_action_flag = i2
       2 phone_home_action_flag = i2
       2 phone_alt_action_flag = i2
       2 address_id = f8
       2 phone_home_id = f8
       2 phone_home_exists_ind = i4
       2 phone_alt_id = f8
       2 phone_alt_exists_ind = i4
       2 name_exists_ind = i4
       2 person_name_id = f8
       2 dup_ind = i4
       2 pcp_person_id = f8
       2 sex_cd = f8
       2 birth_dt_tm = dq8
       2 abs_birth_dt_tm = dq8
       2 state_cd = f8
       2 county_cd = f8
       2 language_cd = f8
       2 ext_alias = vc
       2 ssn_alias = vc
       2 found_ssn_ind = i2
       2 ssn_action_flag = i2
       2 s_int_ssn_alias = vc
       2 name_last = vc
       2 name_first = vc
       2 name_middle = vc
       2 birth_date = vc
       2 gender = vc
       2 lang_code = vc
       2 street_addr = vc
       2 street_addr2 = vc
       2 city = vc
       2 county = vc
       2 state = vc
       2 country = vc
       2 zipcode = vc
       2 phone_home = vc
       2 phone_alt = vc
       2 pcp_ext_alias = vc
       2 pcp_action_flag = i2
       2 cmrn_alias = vc
       2 cmrn_alias_exists_ind = i2
       2 cmrn_alias_id = f8
       2 consent_id = f8
       2 status = vc
       2 stat_msg = vc
       2 qual2_knt = i4
       2 qual2[*]
         3 elementcd = i2
         3 logcd = i2
   )
   SET dates->now_dt_tm = cnvtdatetime(curdate,curtime3)
   SET found_phone_home_delete = false
   SET found_phone_alt_delete = false
   SET found_address_delete = false
   SET found_pcp_delete = false
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT
    IF (working_mode=0)
     PLAN (p
      WHERE p.ags_person_data_id >= beg_data_id
       AND p.ags_person_data_id <= end_data_id
       AND ((p.person_id+ 0) < 1)
       AND trim(p.status)="WAITING")
      JOIN (j
      WHERE j.ags_job_id=p.ags_job_id)
    ELSEIF (working_mode=1)
     PLAN (p
      WHERE p.ags_person_data_id >= beg_data_id
       AND p.ags_person_data_id <= end_data_id)
      JOIN (j
      WHERE j.ags_job_id=p.ags_job_id)
    ELSEIF (working_mode=2)
     PLAN (p
      WHERE p.ags_person_data_id >= beg_data_id
       AND p.ags_person_data_id <= end_data_id
       AND ((p.person_id+ 0) < 1))
      JOIN (j
      WHERE j.ags_job_id=p.ags_job_id)
    ELSE
     PLAN (p
      WHERE p.ags_person_data_id >= beg_data_id
       AND p.ags_person_data_id <= end_data_id
       AND trim(p.status) IN ("IN ERROR", "BACK OUT"))
      JOIN (j
      WHERE j.ags_job_id=p.ags_job_id)
    ENDIF
    INTO "nl:"
    FROM ags_person_data p,
     ags_job j
    HEAD REPORT
     stat = alterlist(hold->qual,data_size), idx = 0
    HEAD p.ags_person_data_id
     idx = (idx+ 1)
     IF (idx > size(hold->qual,5))
      stat = alterlist(hold->qual,(idx+ data_size))
     ENDIF
     hold->qual[idx].ags_person_data_id = p.ags_person_data_id
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
         stat_msg),"[contrib]"), hold->qual[idx].qual2_knt = (hold->qual[idx].qual2_knt+ 1),
       stat = alterlist(hold->qual[idx].qual2,hold->qual[idx].qual2_knt), hold->qual[idx].qual2[hold
       ->qual[idx].qual2_knt].elementcd = esendfacility, hold->qual[idx].qual2[hold->qual[idx].
       qual2_knt].logcd = emissing
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
         stat_msg),"[contrib]"), hold->qual[idx].qual2_knt = (hold->qual[idx].qual2_knt+ 1),
       stat = alterlist(hold->qual[idx].qual2,hold->qual[idx].qual2_knt), hold->qual[idx].qual2[hold
       ->qual[idx].qual2_knt].elementcd = esendfacility, hold->qual[idx].qual2[hold->qual[idx].
       qual2_knt].logcd = emissing
      ENDIF
     ENDIF
     hold->qual[idx].person_id = p.person_id, sextalias = trim(p.ext_alias,3)
     IF (size(trim(sextalias)) > 0)
      hold->qual[idx].ext_alias = sextalias
     ELSE
      hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].stat_msg),"[x]am"), hold->qual[idx].
      qual2_knt = (hold->qual[idx].qual2_knt+ 1), stat = alterlist(hold->qual[idx].qual2,hold->qual[
       idx].qual2_knt),
      hold->qual[idx].qual2[hold->qual[idx].qual2_knt].elementcd = eextalias, hold->qual[idx].qual2[
      hold->qual[idx].qual2_knt].logcd = emissing
     ENDIF
     sssnalias = trim(p.ssn_alias,3)
     IF (size(trim(sssnalias)) > 0)
      hold->qual[idx].ssn_alias = sssnalias, hold->qual[idx].s_int_ssn_alias = trim(cnvtstring(
        cnvtint(hold->qual[idx].ssn_alias)))
     ELSE
      hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].stat_msg),"[s]am"), hold->qual[idx].
      qual2_knt = (hold->qual[idx].qual2_knt+ 1), stat = alterlist(hold->qual[idx].qual2,hold->qual[
       idx].qual2_knt),
      hold->qual[idx].qual2[hold->qual[idx].qual2_knt].elementcd = essnalias, hold->qual[idx].qual2[
      hold->qual[idx].qual2_knt].logcd = emissing
     ENDIF
     snamefirst = trim(p.name_first,3)
     IF (size(trim(snamefirst)) > 0)
      hold->qual[idx].name_first = snamefirst
     ELSE
      hold->qual[idx].contrib_idx = - (1), hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].
        stat_msg),"[nf]m"), hold->qual[idx].qual2_knt = (hold->qual[idx].qual2_knt+ 1),
      stat = alterlist(hold->qual[idx].qual2,hold->qual[idx].qual2_knt), hold->qual[idx].qual2[hold->
      qual[idx].qual2_knt].elementcd = enamefirst, hold->qual[idx].qual2[hold->qual[idx].qual2_knt].
      logcd = emissing
     ENDIF
     snamemid = trim(p.name_middle,3)
     IF (size(trim(snamemid)) > 0)
      hold->qual[idx].name_middle = snamemid
     ELSE
      hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].stat_msg),"[nm]m"), hold->qual[idx].
      qual2_knt = (hold->qual[idx].qual2_knt+ 1), stat = alterlist(hold->qual[idx].qual2,hold->qual[
       idx].qual2_knt),
      hold->qual[idx].qual2[hold->qual[idx].qual2_knt].elementcd = enamemiddle, hold->qual[idx].
      qual2[hold->qual[idx].qual2_knt].logcd = emissing
     ENDIF
     snamelast = trim(p.name_last,3)
     IF (size(trim(snamelast)) > 0)
      hold->qual[idx].name_last = snamelast
     ELSE
      hold->qual[idx].contrib_idx = - (1), hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].
        stat_msg),"[nl]m"), hold->qual[idx].qual2_knt = (hold->qual[idx].qual2_knt+ 1),
      stat = alterlist(hold->qual[idx].qual2,hold->qual[idx].qual2_knt), hold->qual[idx].qual2[hold->
      qual[idx].qual2_knt].elementcd = enamelast, hold->qual[idx].qual2[hold->qual[idx].qual2_knt].
      logcd = emissing
     ENDIF
     sgender = trim(p.gender,3)
     IF (size(trim(sgender,3)) > 0)
      hold->qual[idx].gender = sgender
     ELSE
      hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].stat_msg),"[g]m"), hold->qual[idx].
      qual2_knt = (hold->qual[idx].qual2_knt+ 1), stat = alterlist(hold->qual[idx].qual2,hold->qual[
       idx].qual2_knt),
      hold->qual[idx].qual2[hold->qual[idx].qual2_knt].elementcd = egender, hold->qual[idx].qual2[
      hold->qual[idx].qual2_knt].logcd = emissing
     ENDIF
     hold->qual[idx].sex_cd =
     IF ((hold->qual[idx].gender="M")) male_sex_cd
     ELSEIF ((hold->qual[idx].gender="F")) female_sex_cd
     ELSE 0
     ENDIF
     IF ((hold->qual[idx].sex_cd=0))
      hold->qual[idx].contrib_idx = - (1)
     ENDIF
     sbirthdate = trim(p.birth_date,3)
     IF (size(trim(sbirthdate)) > 0)
      hold->qual[idx].birth_date = sbirthdate, hold->qual[idx].birth_dt_tm = cnvtdate2(sbirthdate,
       "YYYYMMDD")
     ELSE
      hold->qual[idx].contrib_idx = - (1), hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].
        stat_msg),"[bd]m"), hold->qual[idx].qual2_knt = (hold->qual[idx].qual2_knt+ 1),
      stat = alterlist(hold->qual[idx].qual2,hold->qual[idx].qual2_knt), hold->qual[idx].qual2[hold->
      qual[idx].qual2_knt].elementcd = ebirthdate, hold->qual[idx].qual2[hold->qual[idx].qual2_knt].
      logcd = emissing
     ENDIF
     hold->qual[idx].lang_code = trim(p.lang_code,3), hold->qual[idx].street_addr = trim(p
      .street_addr,3), hold->qual[idx].street_addr2 = trim(p.street_addr2,3),
     hold->qual[idx].city = trim(p.city,3), hold->qual[idx].county = trim(p.county,3), hold->qual[idx
     ].state = trim(p.state,3),
     hold->qual[idx].country = trim(p.country,3), hold->qual[idx].zipcode = trim(p.zipcode,3), hold->
     qual[idx].phone_home = trim(p.phone_home,3),
     hold->qual[idx].phone_alt = trim(p.phone_alt,3)
     IF (cnvtupper(hold->qual[idx].street_addr)="<DEL>")
      hold->qual[idx].address_action_flag = 1, found_address_delete = true
     ELSEIF ( NOT ((hold->qual[idx].street_addr > " "))
      AND  NOT ((hold->qual[idx].street_addr2 > " "))
      AND  NOT ((hold->qual[idx].city > " "))
      AND  NOT ((hold->qual[idx].county > " "))
      AND  NOT ((hold->qual[idx].state > " "))
      AND  NOT ((hold->qual[idx].country > " "))
      AND  NOT ((hold->qual[idx].zipcode > " ")))
      hold->qual[idx].address_action_flag = 2
     ELSE
      hold->qual[idx].address_action_flag = 0
     ENDIF
     IF (cnvtupper(hold->qual[idx].phone_home)="<DEL>")
      hold->qual[idx].phone_home_action_flag = 1, found_phone_home_delete = true
     ELSEIF ( NOT ((hold->qual[idx].phone_home > " ")))
      hold->qual[idx].phone_home_action_flag = 2
     ELSE
      hold->qual[idx].phone_home_action_flag = 0
     ENDIF
     IF (cnvtupper(hold->qual[idx].phone_alt)="<DEL>")
      hold->qual[idx].phone_alt_action_flag = 1, found_phone_alt_delete = true
     ELSEIF ( NOT ((hold->qual[idx].phone_alt > " ")))
      hold->qual[idx].phone_alt_action_flag = 2
     ELSE
      hold->qual[idx].phone_alt_action_flag = 0
     ENDIF
     hold->qual[idx].pcp_person_id = 0.0, hold->qual[idx].pcp_ext_alias = trim(p.pcp_ext_alias,3)
     IF (cnvtupper(hold->qual[idx].pcp_ext_alias)="<DEL>")
      hold->qual[idx].pcp_action_flag = 1, found_pcp_delete = true
     ELSEIF ( NOT ((hold->qual[idx].pcp_ext_alias > " ")))
      hold->qual[idx].pcp_action_flag = 2
     ELSE
      hold->qual[idx].pcp_action_flag = 0
     ENDIF
     IF ((hold->qual[idx].person_id=0))
      hold->qual[idx].person_exists_ind = 0
     ELSE
      hold->qual[idx].person_exists_ind = 1
     ENDIF
     hold->qual[idx].ext_alias_exists_ind = 0, hold->qual[idx].ext_alias_person_alias_id = 0, hold->
     qual[idx].ssn_alias_exists_ind = 0,
     hold->qual[idx].ssn_alias_person_alias_id = 0, hold->qual[idx].address_id = 0, hold->qual[idx].
     address_exists_ind = 0,
     hold->qual[idx].phone_home_id = 0, hold->qual[idx].phone_home_exists_ind = 0, hold->qual[idx].
     phone_alt_id = 0,
     hold->qual[idx].phone_alt_exists_ind = 0, hold->qual[idx].language_cd = 0, hold->qual[idx].
     dup_ind = 0,
     hold->qual[idx].name_exists_ind = 0, hold->qual[idx].person_name_id = 0, hold->qual[idx].
     cmrn_alias = p.cmrn_alias
     IF ( NOT (size(trim(p.cmrn_alias)) > 0))
      hold->qual[idx].cmrn_alias = uar_createuuid(0)
     ENDIF
    FOOT REPORT
     hold->qual_knt = idx, stat = alterlist(hold->qual,idx)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL ags_set_status_block(eselect,efailure,"AGS_PERSON_DATA",trim(serrmsg))
    GO TO exit_script
   ENDIF
   IF ((hold->qual_knt > 0))
    IF ((contrib_rec->qual_knt < 1))
     CALL ags_set_status_block(eattribute,efailure,"CONTRIBUTOR_SYSTEMS","contrib_rec->qual_knt < 1")
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
     HEAD cva.alias
      contrib_rec->qual[d.seq].sending_facility = cva.alias, contrib_rec->qual[d.seq].
      contributor_system_cd = cs.contributor_system_cd, contrib_rec->qual[d.seq].
      contributor_source_cd = cs.contributor_source_cd,
      contrib_rec->qual[d.seq].time_zone_flag = cs.time_zone_flag, contrib_rec->qual[d.seq].time_zone
       = cs.time_zone, contrib_rec->qual[d.seq].time_zone_idx = datetimezonebyname(contrib_rec->qual[
       d.seq].time_zone),
      contrib_rec->qual[d.seq].prsnl_person_id = cs.prsnl_person_id, contrib_rec->qual[d.seq].
      organization_id = cs.organization_id, found_ext_alias = false,
      found_ssn_alias = false, found_pcp_alias = false, found_cmrn_alias = false
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
      IF (found_pcp_alias=false
       AND eat.esi_alias_field_cd=pcp_alias_field_cd)
       found_pcp_alias = true, contrib_rec->qual[d.seq].pcp_alias_pool_cd = eat.alias_pool_cd,
       contrib_rec->qual[d.seq].pcp_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (found_cmrn_alias=false
       AND eat.esi_alias_field_cd=cmrn_alias_field_cd)
       found_cmrn_alias = true, contrib_rec->qual[d.seq].cmrn_alias_pool_cd = eat.alias_pool_cd,
       contrib_rec->qual[d.seq].cmrn_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"CONTRIBUTOR_SYSTEMS",trim(serrmsg))
     GO TO exit_script
    ENDIF
    FOR (fidx = 1 TO hold->qual_knt)
      IF ((hold->qual[fidx].contrib_idx > 0))
       IF ((contrib_rec->qual[hold->qual[fidx].contrib_idx].contributor_system_cd < 1))
        SET hold->qual[fidx].contrib_idx = - (1)
        SET hold->qual[fidx].stat_msg = concat(trim(hold->qual[fidx].stat_msg),"[contrib]")
        SET hold->qual[fidx].qual2_knt = (hold->qual[fidx].qual2_knt+ 1)
        SET stat = alterlist(hold->qual[fidx].qual2,hold->qual[fidx].qual2_knt)
        SET hold->qual[fidx].qual2[hold->qual[fidx].qual2_knt].elementcd = esendfacility
        SET hold->qual[fidx].qual2[hold->qual[fidx].qual2_knt].logcd = elookup
       ENDIF
      ENDIF
    ENDFOR
    CALL echorecord(contrib_rec)
    CALL ags_set_status_block(ecustom,einfo,"DATA ROWS",concat(trim(cnvtstring(hold->qual_knt)),
      " Rows Found For Processing"))
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
     HEAD REPORT
      x = 1
     DETAIL
      hold->qual[d.seq].person_exists_ind = 1, hold->qual[d.seq].person_id = p.person_id, hold->qual[
      d.seq].ext_alias_exists_ind = 1,
      hold->qual[d.seq].ext_alias_person_alias_id = p.person_alias_id
     FOOT REPORT
      IF (curqual < 1)
       hold->qual[d.seq].qual2_knt = (hold->qual[d.seq].qual2_knt+ 1), stat = alterlist(hold->qual[d
        .seq].qual2,hold->qual[d.seq].qual2_knt), hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt
       ].elementcd = eextalias,
       hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt].logcd = elookup
      ENDIF
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"EXT_ALIAS",trim(serrmsg))
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
       AND (hold->qual[d.seq].s_int_ssn_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.alias=hold->qual[d.seq].s_int_ssn_alias)
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
     HEAD REPORT
      x = 1
     DETAIL
      hold->qual[d.seq].person_exists_ind = 1, hold->qual[d.seq].person_id = p.person_id, hold->qual[
      d.seq].ssn_alias_exists_ind = 1,
      hold->qual[d.seq].ssn_alias_person_alias_id = p.person_alias_id
     FOOT REPORT
      IF (curqual < 1)
       hold->qual[d.seq].qual2_knt = (hold->qual[d.seq].qual2_knt+ 1), stat = alterlist(hold->qual[d
        .seq].qual2,hold->qual[d.seq].qual2_knt), hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt
       ].elementcd = essnalias,
       hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt].logcd = elookup
      ENDIF
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"SSN_ALIAS",trim(serrmsg))
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Get Language and State Code Values")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      code_value cv
     PLAN (d
      WHERE (hold->qual[d.seq].state > " ")
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].address_action_flag=0))
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
     CALL ags_set_status_block(eselect,efailure,"STATE_CD",trim(serrmsg))
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      code_value_alias cva
     PLAN (d
      WHERE (hold->qual[d.seq].lang_code > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (cva
      WHERE cva.alias=cnvtlower(hold->qual[d.seq].lang_code)
       AND cva.code_set=36
       AND cva.contributor_source_cd=cerner_chr_contributor_source_cd)
     DETAIL
      hold->qual[d.seq].language_cd = cva.code_value
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"LANGUAGE_CD",trim(serrmsg))
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Check for Existence SSN, etc")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].ssn_alias_exists_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].s_int_ssn_alias > " "))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ssn_alias_pool_cd)
       AND (p.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ssn_alias_type_cd
      ))
     HEAD REPORT
      x = 1
     DETAIL
      IF ((p.alias=hold->qual[d.seq].s_int_ssn_alias))
       found_ssn = true, hold->qual[d.seq].ssn_alias_exists_ind = 1, hold->qual[d.seq].
       ssn_alias_person_alias_id = p.person_alias_id
       IF (((p.active_ind < 1) OR (datetimediff(p.end_effective_dt_tm,cnvtdatetime(curdate,curtime3))
        < 0)) )
        hold->qual[d.seq].found_ssn_ind = true
       ENDIF
      ENDIF
     FOOT REPORT
      IF (curqual > 0)
       hold->qual[d.seq].qual2_knt = (hold->qual[d.seq].qual2_knt+ 1), stat = alterlist(hold->qual[d
        .seq].qual2,hold->qual[d.seq].qual2_knt), hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt
       ].elementcd = essnalias,
       hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt].logcd = emultiple
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"CHECK SSN",trim(serrmsg))
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].cmrn_alias_exists_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].cmrn_alias_pool_cd)
       AND (p.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      cmrn_alias_type_cd)
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].cmrn_alias_exists_ind = 1, hold->qual[d.seq].cmrn_alias_id = p
      .person_alias_id, hold->qual[d.seq].cmrn_alias = p.alias
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"CHECK CMRN",trim(serrmsg))
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
       AND p.phone_type_cd=home_phone_type_cd
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].phone_home_id = p.phone_id, hold->qual[d.seq].phone_home_exists_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"CHECK PHONE",trim(serrmsg))
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
       AND p.phone_type_cd=alt_phone_type_cd
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].phone_alt_id = p.phone_id, hold->qual[d.seq].phone_alt_exists_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"CHECK ALT PHONE",trim(serrmsg))
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
       AND a.address_type_cd=home_addr_type_cd
       AND a.active_ind=1)
     DETAIL
      hold->qual[d.seq].address_id = a.address_id, hold->qual[d.seq].address_exists_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"CHECK ADDRESS",trim(serrmsg))
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_name p
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].name_exists_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id)
       AND p.name_type_cd=current_name_type_cd
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].name_exists_ind = 1, hold->qual[d.seq].person_name_id = p.person_name_id
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"CHECK PERSON_NAME",trim(serrmsg))
     GO TO exit_script
    ENDIF
    FOR (temp_i = 1 TO hold->qual_knt)
      IF (breqssn)
       IF ( NOT ((hold->qual[temp_i].ssn_alias > " "))
        AND (hold->qual[temp_i].person_id < 1))
        SET hold->qual[temp_i].contrib_idx = - (1)
        SET hold->qual[temp_i].stat_msg = concat(trim(hold->qual[temp_i].stat_msg),"[ssn]")
       ENDIF
      ENDIF
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
        CALL ags_set_status_block(egen_nbr,efailure,"GENERATE PERSON_ID",trim(serrmsg))
        GO TO exit_script
       ENDIF
       SET ierrcode = error(serrmsg,1)
       SET ierrcode = 0
       SELECT INTO "nl:"
        y = seq(patient_privacy_seq,nextval)
        FROM dual
        DETAIL
         hold->qual[temp_i].consent_id = cnvtreal(y)
        WITH format, nocounter
       ;end select
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        CALL ags_set_status_block(egen_nbr,efailure,"GENERATE CONSENT_ID",trim(serrmsg))
        GO TO exit_script
       ENDIF
      ENDIF
      SET temp_level = eerrorlevel
      IF ((hold->qual[temp_i].person_id > 0)
       AND (hold->qual[temp_i].contrib_idx > 0))
       SET temp_level = ewarninglevel
      ENDIF
      FOR (temp_j = 1 TO hold->qual[temp_i].qual2_knt)
        CALL ags_log_msg(temp_level,hold->qual[temp_i].ags_person_data_id,epersonload,hold->qual[
         temp_i].qual2[temp_j].logcd,hold->qual[temp_i].qual2[temp_j].elementcd,
         "")
      ENDFOR
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
      p.ethnic_grp_cd = 0, p.language_cd = hold->qual[d.seq].language_cd, p.marital_type_cd = 0,
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
       AND (hold->qual[d.seq].person_exists_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(einsert,efailure,"INSERT PERSON",trim(serrmsg))
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
       p.language_cd = hold->qual[d.seq].language_cd, p.sex_cd = hold->qual[d.seq].sex_cd
      PLAN (d
       WHERE (hold->qual[d.seq].person_id > 0)
        AND (hold->qual[d.seq].person_exists_ind=1)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (p
       WHERE (p.person_id=hold->qual[d.seq].person_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL ags_set_status_block(eupdate,efailure,"UPDATE PERSON",trim(serrmsg))
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echo("***")
    CALL echo("***   Blind Person Update")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM person p,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p.updt_id = contrib_rec->qual[hold->qual[d
      .seq].contrib_idx].prsnl_person_id, p.updt_task = 4249900,
      p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = 4249900
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].person_exists_ind=1)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eupdate,efailure,"BLIND UPDATE PERSON",trim(serrmsg))
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Insert EXT_ALIAS")
    CALL echo("***")
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
      ext_alias_pool_cd,
      pa.person_alias_type_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_type_cd,
      pa.alias = hold->qual[d.seq].ext_alias, pa.person_alias_sub_type_cd = 0,
      pa.check_digit = 0, pa.check_digit_method_cd = 0
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].ext_alias_exists_ind=0)
       AND (hold->qual[d.seq].ext_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pa)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(einsert,efailure,"INSERT EXT_ALIAS",trim(serrmsg))
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Insert SSN")
    CALL echo("***")
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
       AND (hold->qual[d.seq].ssn_alias_exists_ind=0)
       AND (hold->qual[d.seq].ssn_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pa)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(einsert,efailure,"INSERT SSN_ALIAS",trim(serrmsg))
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo(build("***   ssn_mult_ind :",ssn_mult_ind))
    CALL echo("***")
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
      CALL ags_set_status_block(eupdate,efailure,"SSN ( EXISTS_IND = 0 ) 1",trim(serrmsg))
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
      CALL ags_set_status_block(eupdate,efailure,"SSN ( EXISTS_IND = 0 ) 2",trim(serrmsg))
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
       AND (hold->qual[d.seq].ssn_alias_exists_ind=1)
       AND (hold->qual[d.seq].ssn_alias_person_alias_id > 0)
       AND (hold->qual[d.seq].ssn_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].found_ssn_ind=true))
      JOIN (pa
      WHERE (pa.person_alias_id=hold->qual[d.seq].ssn_alias_person_alias_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eupdate,efailure,"SSN ( FOUND_SSN_IND = TRUE )",trim(serrmsg))
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
        AND (hold->qual[d.seq].ssn_alias_exists_ind=1)
        AND (hold->qual[d.seq].ssn_alias_person_alias_id > 0)
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
      CALL ags_set_status_block(eupdate,efailure,"SSN ( EXISTS_IND = 0 ) 1",trim(serrmsg))
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
        AND (hold->qual[d.seq].ssn_alias_exists_ind=1)
        AND (hold->qual[d.seq].ssn_alias_person_alias_id > 0)
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
      CALL ags_set_status_block(eupdate,efailure,"SSN ( EXISTS_IND = 0 ) 2",trim(serrmsg))
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
      cmrn_alias_pool_cd,
      pa.person_alias_type_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].cmrn_alias_type_cd,
      pa.alias = hold->qual[d.seq].cmrn_alias, pa.person_alias_sub_type_cd = 0,
      pa.check_digit = 0, pa.check_digit_method_cd = 0
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].cmrn_alias_exists_ind=0)
       AND (hold->qual[d.seq].cmrn_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pa)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(einsert,efailure,"INSERT CMRN",trim(serrmsg))
     GO TO exit_script
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
      p.phone_type_cd = home_phone_type_cd, p.phone_format_cd = us_phone_format_cd, p.phone_num =
      hold->qual[d.seq].phone_home,
      p.phone_type_seq = 0, p.description = "Subscriber Phone"
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].phone_home_exists_ind=0)
       AND (hold->qual[d.seq].phone_home > " ")
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].phone_home_action_flag=0))
      JOIN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(einsert,efailure,"INSERT PHONE",trim(serrmsg))
     GO TO exit_script
    ENDIF
    IF (working_mode != 2)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM phone p,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET p.phone_num = hold->qual[d.seq].phone_home, p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
       p.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
       p.updt_task = 4249900, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = 4249900
      PLAN (d
       WHERE (hold->qual[d.seq].phone_home_exists_ind=1)
        AND (hold->qual[d.seq].phone_home_id > 0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].phone_home_action_flag=0))
       JOIN (p
       WHERE (p.phone_id=hold->qual[d.seq].phone_home_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL ags_set_status_block(eupdate,efailure,"UPDATE PHONE",trim(serrmsg))
      GO TO exit_script
     ENDIF
    ENDIF
    IF (found_phone_home_delete=true)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM phone p,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET p.seq = 1
      PLAN (d
       WHERE (hold->qual[d.seq].phone_home_exists_ind=1)
        AND (hold->qual[d.seq].phone_home_id > 0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].phone_home_action_flag=1))
       JOIN (p
       WHERE (p.phone_id=hold->qual[d.seq].phone_home_id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL ags_set_status_block(edelete,efailure,"DELETE PHONE",trim(serrmsg))
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
      p.phone_type_cd = alt_phone_type_cd, p.phone_format_cd = us_phone_format_cd, p.phone_num = hold
      ->qual[d.seq].phone_alt,
      p.phone_type_seq = 0, p.description = "Subscriber Alternate Phone"
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].phone_alt_exists_ind=0)
       AND (hold->qual[d.seq].phone_alt > " ")
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].phone_alt_action_flag=0))
      JOIN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(einsert,efailure,"INSERT ALT_PHONE",trim(serrmsg))
     GO TO exit_script
    ENDIF
    IF (working_mode != 2)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM phone p,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET p.phone_num = hold->qual[d.seq].phone_alt, p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p
       .updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
       p.updt_task = 4249900, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = 4249900
      PLAN (d
       WHERE (hold->qual[d.seq].phone_alt_exists_ind=1)
        AND (hold->qual[d.seq].phone_alt_id > 0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].phone_alt_action_flag=0))
       JOIN (p
       WHERE (p.phone_id=hold->qual[d.seq].phone_alt_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL ags_set_status_block(eupdate,efailure,"UPDATE ALT_PHONE",trim(serrmsg))
      GO TO exit_script
     ENDIF
    ENDIF
    IF (found_phone_alt_delete=true)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM phone p,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET p.seq = 1
      PLAN (d
       WHERE (hold->qual[d.seq].phone_alt_exists_ind=1)
        AND (hold->qual[d.seq].phone_alt_id > 0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].phone_alt_action_flag=1))
       JOIN (p
       WHERE (p.phone_id=hold->qual[d.seq].phone_alt_id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL ags_set_status_block(edelete,efailure,"DELETE ALT_PHONE",trim(serrmsg))
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echo("***")
    CALL echo("***   Insert Address")
    CALL echo("***")
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
      a.address_type_cd = home_addr_type_cd, a.comment_txt = "Subscriber Address", a.street_addr =
      hold->qual[d.seq].street_addr,
      a.street_addr2 = hold->qual[d.seq].street_addr2, a.city = hold->qual[d.seq].city, a.state =
      hold->qual[d.seq].state,
      a.state_cd = hold->qual[d.seq].state_cd, a.zipcode = hold->qual[d.seq].zipcode, a.county = hold
      ->qual[d.seq].county,
      a.county_cd = hold->qual[d.seq].county_cd, a.country = hold->qual[d.seq].country
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].address_exists_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].address_action_flag=0))
      JOIN (a)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(einsert,efailure,"INSERT ADDRESS",trim(serrmsg))
     GO TO exit_script
    ENDIF
    IF (working_mode != 2)
     CALL echo("***")
     CALL echo("***   Update Address")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM address a,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET a.address_type_cd = home_addr_type_cd, a.comment_txt = "Subscriber Address", a.street_addr
        = hold->qual[d.seq].street_addr,
       a.street_addr2 = hold->qual[d.seq].street_addr2, a.city = hold->qual[d.seq].city, a.state =
       hold->qual[d.seq].state,
       a.state_cd = hold->qual[d.seq].state_cd, a.zipcode = hold->qual[d.seq].zipcode, a.updt_dt_tm
        = cnvtdatetime(dates->now_dt_tm),
       a.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, a.updt_task =
       4249900, a.updt_cnt = (a.updt_cnt+ 1),
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
      CALL ags_set_status_block(eupdate,efailure,"UPDATE ADDRESS",trim(serrmsg))
      GO TO exit_script
     ENDIF
    ENDIF
    IF (found_address_delete=true)
     CALL echo("***")
     CALL echo("***   Delete Address")
     CALL echo("***")
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
      CALL ags_set_status_block(edelete,efailure,"DELETE ADDRESS",trim(serrmsg))
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
      a.name_middle = hold->qual[d.seq].name_middle, a.name_last_key = cnvtupper(cnvtalphanum(hold->
        qual[d.seq].name_last)), a.name_first_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].
        name_first)),
      a.name_middle_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].name_middle))
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].name_exists_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (a)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(einsert,efailure,"INSERT PERSON_NAME CURRENT",trim(serrmsg))
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
       .name_last_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].name_last)),
       a.name_first_key = cnvtupper(cnvtalphanum(hold->qual[d.seq].name_first)), a.name_middle_key =
       cnvtupper(cnvtalphanum(hold->qual[d.seq].name_middle)), a.updt_dt_tm = cnvtdatetime(dates->
        now_dt_tm),
       a.updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, a.updt_task =
       4249900, a.updt_cnt = (a.updt_cnt+ 1),
       a.updt_applctx = 4249900
      PLAN (d
       WHERE (hold->qual[d.seq].name_exists_ind=1)
        AND (hold->qual[d.seq].person_name_id > 0.0)
        AND (hold->qual[d.seq].person_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (a
       WHERE (a.person_name_id=hold->qual[d.seq].person_name_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL ags_set_status_block(eupdate,efailure,"UPDATE PERSON_NAME PRSNL",trim(serrmsg))
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echo("***")
    CALL echo("***   Handle PCP")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      prsnl_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].pcp_person_id=0)
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].pcp_action_flag=0))
      JOIN (p
      WHERE p.alias=trim(hold->qual[d.seq].pcp_ext_alias)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].pcp_alias_pool_cd)
       AND (p.prsnl_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].pcp_alias_type_cd)
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].pcp_person_id = p.person_id
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"FIND PCP",trim(serrmsg))
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    DELETE  FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_prsnl_reltn p
     SET p.seq = 1
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (((hold->qual[d.seq].pcp_person_id > 0)
       AND (hold->qual[d.seq].pcp_action_flag=0)) OR ((hold->qual[d.seq].pcp_action_flag=1)))
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE (p.person_id=hold->qual[d.seq].person_id)
       AND p.prsnl_person_id > 0
       AND p.active_ind=1
       AND p.person_prsnl_r_cd=pcp_person_prnsl_r_cd)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(edelete,efailure,"DELETE PCP",trim(serrmsg))
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM person_prsnl_reltn p,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET p.person_prsnl_reltn_id = seq(person_seq,nextval), p.person_id = hold->qual[d.seq].person_id,
      p.prsnl_person_id = hold->qual[d.seq].pcp_person_id,
      p.person_prsnl_r_cd = pcp_person_prnsl_r_cd, p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p
      .updt_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      p.updt_task = 4249900, p.updt_cnt = 0, p.updt_applctx = 4249900,
      p.active_ind = 1, p.active_status_cd = active_active_status_cd, p.active_status_prsnl_id =
      contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      p.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.beg_effective_dt_tm = cnvtdatetime(
       dates->now_dt_tm), p.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm),
      p.data_status_cd = auth_data_status_cd, p.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p
      .data_status_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id,
      p.contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      contributor_system_cd, p.free_text_cd = 0, p.ft_prsnl_name = "",
      p.internal_seq = 0, p.manual_create_by_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      prsnl_person_id, p.manual_create_dt_tm = datetimezone(dates->now_dt_tm,contrib_rec->qual[hold->
       qual[d.seq].contrib_idx].time_zone_idx,1),
      p.manual_create_ind = 0, p.manual_inact_by_id = 0, p.manual_inact_dt_tm = null,
      p.manual_inact_ind = 0, p.notification_cd = 0, p.priority_seq = 0
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].pcp_person_id > 0)
       AND (hold->qual[d.seq].dup_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0)
       AND (hold->qual[d.seq].pcp_action_flag=0))
      JOIN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(einsert,efailure,"INSERT PCP",trim(serrmsg))
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Add Consent Status")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM ppr_consent_status p,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET p.consent_status_id = hold->qual[d.seq].consent_id, p.consent_id = hold->qual[d.seq].
      consent_id, p.person_id = hold->qual[d.seq].person_id,
      p.status_cd = ddefaultstatuscd, p.consent_type_cd = ddefaultconsenttypecd, p.consent_policy_id
       = dconsentpolicyid,
      p.contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      contributor_system_cd, p.active_ind = 1, p.active_status_cd = active_active_status_cd,
      p.active_status_prsnl_id = contrib_rec->qual[hold->qual[d.seq].contrib_idx].prsnl_person_id, p
      .active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.beg_effective_dt_tm = cnvtdatetime(
       dates->now_dt_tm),
      p.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm)
     PLAN (d
      WHERE (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].person_exists_ind=0)
       AND (hold->qual[d.seq].consent_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE 0=0)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(einsert,efailure,"CONSENT",trim(serrmsg))
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Update Data to Complete")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_person_data o,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET o.status = "COMPLETE", o.stat_msg = "", o.status_dt_tm = cnvtdatetime(dates->now_dt_tm),
      o.person_id = hold->qual[d.seq].person_id, o.contributor_system_cd = contrib_rec->qual[hold->
      qual[d.seq].contrib_idx].contributor_system_cd, o.pcp_person_id = hold->qual[d.seq].
      pcp_person_id,
      o.cmrn_alias = hold->qual[d.seq].cmrn_alias
     PLAN (d
      WHERE (hold->qual[d.seq].ags_person_data_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (o
      WHERE (o.ags_person_data_id=hold->qual[d.seq].ags_person_data_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eupdate,efailure,"PERSON_DATA COMPLETE",trim(serrmsg))
     GO TO exit_script
    ENDIF
    COMMIT
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_person_data o,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET o.status = "IN ERROR", o.stat_msg = trim(substring(1,40,hold->qual[d.seq].stat_msg)), o
      .status_dt_tm = cnvtdatetime(dates->now_dt_tm),
      o.person_id = 0.0, o.contributor_system_cd = 0.0, o.pcp_person_id = hold->qual[d.seq].
      pcp_person_id,
      o.cmrn_alias = ""
     PLAN (d
      WHERE (hold->qual[d.seq].ags_person_data_id > 0)
       AND (hold->qual[d.seq].contrib_idx < 1))
      JOIN (o
      WHERE (o.ags_person_data_id=hold->qual[d.seq].ags_person_data_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eupdate,efailure,"PERSON_DATA IN ERROR",trim(serrmsg))
     GO TO exit_script
    ENDIF
    COMMIT
   ELSE
    CALL ags_set_status_block(ecustom,einfo,"DATA ROWS","No Rows Found For Processing")
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
    CALL ags_set_status_block(eselect,efailure,"KILL_IND",trim(serrmsg))
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
    CALL ags_set_status_block(eupdate,efailure,"ITERATION",trim(serrmsg))
    GO TO exit_script
   ENDIF
   COMMIT
   CALL ags_set_status_block(ecustom,einfo,"END PROCESSING",concat("BEG_DATA_ID :: ",trim(cnvtstring(
       beg_data_id))," :: END_DATA_ID :: ",trim(cnvtstring(end_data_id))," :: MAX_DATA_ID :: ",
     trim(cnvtstring(max_data_id))))
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
   CALL ags_set_status_block(eselect,efailure,"AGS_TASK COMPLETE",trim(serrmsg))
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
   CALL ags_set_status_block(eselect,efailure,"AGS_TASK KILL_IND WAITING",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (ags_log_status(0)=0)
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
   CALL ags_set_status_block(eselect,efailure,"AGS_TASK ERROR",trim(serrmsg))
  ENDIF
 ENDIF
 COMMIT
 CALL echo("***")
 CALL echo("***   END AGS_PERSON_LOAD")
 CALL echo("***")
 SET script_ver = "023 01/11/07"
END GO
