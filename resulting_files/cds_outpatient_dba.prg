CREATE PROGRAM cds_outpatient:dba
 SET last_mod = "157097"
 RECORD cdsbatch(
   1 batch[*]
     2 cds_batch_id = f8
     2 cds_batch_hist_id = f8
     2 cds_batch_type_cd = f8
     2 opwl_batch_ind = i2
     2 cds_batch_size = i4
     2 program_name = c30
     2 cds_batch_start_dt = dq8
     2 cds_batch_end_dt = dq8
     2 filename = c50
     2 content[*]
       3 cds_batch_content_id = f8
       3 cds_type_cd = f8
       3 parent_entity_id = f
       3 parent_entity_name = c30
       3 update_del_flag = i2
   1 request_dt_tm = dq8
   1 organization_id = f8
   1 org_code = c3
   1 rerun_flag = i2
   1 batch_type_request = f8
   1 testmode = i2
   1 anonymous = i2
 )
 FREE RECORD local
 RECORD local(
   1 specialty_code = f8
 )
 DECLARE pm_get_cvo_alias() = c40
 SET last_mod = "202775"
 IF (validate(cdsderiveddataind)=1)
  GO TO exit_cds_derived_data
 ENDIF
 DECLARE aaa_years_sub = i4 WITH public
 DECLARE aaa_temp_ahead = q8 WITH public
 DECLARE aaa_return = i4 WITH public
 DECLARE cdsderiveddataind = i2 WITH public, constant(1)
 SET last_mod = "ukr_get_cds_versions.inc:762426"
 FREE RECORD cdsver
 RECORD cdsver(
   1 version_cnt = i2
   1 list[*]
     2 version
       3 major = i2
       3 minor = i2
       3 display = vc
 )
 DECLARE populatecdsversions(null) = null
 SUBROUTINE populatecdsversions(null)
   SET cdsver->version_cnt = 3
   SET stat = alterlist(cdsver->list,cdsver->version_cnt)
   SET cdsver->list[1].version.major = 6
   SET cdsver->list[1].version.minor = 1
   SET cdsver->list[1].version.display = "6.1"
   SET cdsver->list[2].version.major = 6
   SET cdsver->list[2].version.minor = 2
   SET cdsver->list[2].version.display = "6.2"
   SET cdsver->list[3].version.major = 6
   SET cdsver->list[3].version.minor = 3
   SET cdsver->list[3].version.display = "6.3"
 END ;Subroutine
 SUBROUTINE calcsuspenddays(beg_susp_dt,end_susp_dt,end_prompt_dt,last_dna_dt)
   DECLARE csd_begin_date = q8 WITH private, noconstant(0.0)
   DECLARE csd_end_date = q8 WITH private, noconstant(0.0)
   DECLARE csd_result = i4 WITH private, noconstant(0)
   IF (end_susp_dt >= last_dna_dt
    AND last_dna_dt > beg_susp_dt)
    SET csd_begin_date = last_dna_dt
   ELSE
    SET csd_begin_date = beg_susp_dt
   ENDIF
   IF (end_susp_dt > end_prompt_dt)
    SET csd_end_date = end_prompt_dt
   ELSE
    SET csd_end_date = end_susp_dt
   ENDIF
   IF (csd_begin_date > csd_end_date)
    SET csd_result = 0
   ELSE
    SET csd_result = (datetimecmp(cnvtdatetimeutc(csd_end_date,2),cnvtdatetimeutc(csd_begin_date,2))
    + 1)
   ENDIF
   RETURN(csd_result)
 END ;Subroutine
 SUBROUTINE (valuelocalcontributor(org_id=f8,org_code=vc) =f8)
   DECLARE local_contributor = f8 WITH public, noconstant(0)
   SET local_contributor = uar_get_code_by("DISPLAYKEY",73,"LOCALSUBSPEC")
   IF (local_contributor <= 0)
    SET local_contributor = uar_get_code_by("DISPLAYKEY",73,"NHSLOCALSUBSPEC")
   ENDIF
   IF (substring(1,3,cnvtupper(org_code)) IN ("RQX", "RNH", "5C5"))
    IF (org_id=2589)
     SELECT INTO "nl:"
      FROM contributor_system cs
      WHERE cs.organization_id=org_id
       AND cs.display="*LOCAL"
      DETAIL
       local_contributor = cs.contributor_source_cd
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM contributor_system cs
      WHERE cs.organization_id=2
       AND cs.display="*LOCAL"
      DETAIL
       local_contributor = cs.contributor_source_cd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(local_contributor)
 END ;Subroutine
 SUBROUTINE (adm_offer_flag(eal_cve_build_flag=i2(ref),eal_offer_parser=vc(ref)) =null)
   SET eal_cve_build_flag = 0
   SET eal_offer_parser = "sed2.oe_field_meaning = 'SCHADMITOFFEROUTCOME'"
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_set IN (14774, 14229)
     AND cve.field_name="AOO"
    HEAD REPORT
     eal_cve_build_flag = 1, eal_offer_parser = "cve.code_value > 0"
    FOOT REPORT
     null
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (age_at_activity(aaa_activity_dt_tm=q8,aaa_birth_dt_tm=q8) =i4)
   SET aaa_years_sub = (cnvtint(format(aaa_activity_dt_tm,"YYYY;;d")) - cnvtint(format(
     aaa_birth_dt_tm,"YYYY;;d")))
   SET aaa_temp_ahead = cnvtlookahead(concat(cnvtstring(aaa_years_sub),",Y"),aaa_birth_dt_tm)
   SET aaa_return = aaa_years_sub
   IF (aaa_temp_ahead > aaa_activity_dt_tm)
    SET aaa_return = (aaa_years_sub - 1)
   ENDIF
   IF (((aaa_return > 999) OR (((datetimecmp(cnvtdatetime("31-DEC-2999 00:00:00"),cnvtdatetime(
     cnvtdate(aaa_activity_dt_tm),0))=0) OR (aaa_return < 0)) )) )
    SET aaa_return = 999
   ENDIF
   RETURN(aaa_return)
 END ;Subroutine
#exit_cds_derived_data
 SET local->specialty_code = valuelocalcontributor(cdsbatch->organization_id,cdsbatch->org_code)
 DECLARE trust_rel_code = f8 WITH public, noconstant(uar_get_code_by("MEANING",369,"NHSTRUSTCHLD"))
 DECLARE medservice_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",19189,"SERVICE"))
 DECLARE nhs_report_code = f8 WITH public, noconstant(uar_get_code_by("MEANING",73,"NHS_REPORT"))
 DECLARE patient = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",14250,"PATIENT"))
 DECLARE org_alias_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",334,"NHSORGALIAS"))
 DECLARE nhs_serial_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",334,"NHSSERIALNUM"))
 DECLARE unknown_svc = f8 WITH public, noconstant(uar_get_code_by("DISPLAY",3394,"Unknown"))
 DECLARE confirm_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",14232,"CONFIRM"))
 DECLARE cnn_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE nhs_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE augmentedcare = f8 WITH public, noconstant(uar_get_code_by("MEANING",17649,"AUGMENTCARE"))
 DECLARE commissioner_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",352,"COMMISSIONER"))
 DECLARE active_status_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE referdoc = f8 WITH public, noconstant(uar_get_code_by("MEANING",333,"REFERDOC"))
 DECLARE gp_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE consultant_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE doccnbr = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"DOCCNBR"))
 DECLARE nongp = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"NONGP"))
 DECLARE external_id = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"EXTERNALID"))
 DECLARE gdp = f8 WITH public, constant(uar_get_code_by("MEANING",320,"GDP"))
 DECLARE inpt_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAY",69,"Inpatient"))
 DECLARE visit_nbr = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"VISITID"))
 DECLARE fin_nbr = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mother_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",40,"MOTHER"))
 DECLARE pcp_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE primary_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAY",12034,"Primary"))
 DECLARE antenatal_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",331,"ANTENATALDOC"))
 DECLARE home_addr_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE maternity_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MATERNITY"))
 DECLARE newborn_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"NEWBORN"))
 DECLARE psych_ip_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "PSYCHIATRICINPATIENT"))
 DECLARE reg_day_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "REGULARDAYADMISSION"))
 DECLARE reg_night_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "REGULARNIGHTADMISSION"))
 DECLARE mortuary_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MORTUARY"))
 DECLARE daycare_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"DAYCARE"))
 DECLARE direct_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"DIRECTREFERRAL"))
 DECLARE ed_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCYDEPARTMENT"))
 DECLARE ip_preadmit_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "INPATIENTPREADMISSION"))
 DECLARE op_prereg_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTPREREGISTRATION"))
 DECLARE daycase_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"DAYCASE"))
 DECLARE daycase_wl_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "DAYCASEWAITINGLIST"))
 DECLARE ip_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE ip_wl_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "INPATIENTWAITINGLIST"))
 DECLARE op_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE op_referral_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTREFERRAL"))
 DECLARE community_ahp_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "COMMUNITYAHP"))
 DECLARE mentalhealth_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "MENTALHEALTH"))
 DECLARE psych_op_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "PSYCHIATRICOUTPATIENT"))
 DECLARE age_group_int_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",17649,
   "AGEGROUPINTENDED"))
 DECLARE clin_care_int_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",17649,
   "CLINICALCAREINTENSITY"))
 DECLARE sex_of_pats_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",17649,"SEXOFPATIENTS"
   ))
 DECLARE treatment_site_cd = f8 WITH public, constant(uar_get_code_by("MEANING",17649,"TREATSITECD"))
 DECLARE augmented_care_cd = f8 WITH public, constant(uar_get_code_by("MEANING",17649,"AUGMENTCARE"))
 DECLARE location_class_cd = f8 WITH public, constant(uar_get_code_by("MEANING",17649,"LOCCLAS"))
 SET last_mod = "ukr_cds_output_vars.inc:539853"
 IF (validate(cdsoutputvarsrun) != 0)
  GO TO exit_ukr_cds_output_vars
 ENDIF
 DECLARE cdsoutputvarsrun = i2 WITH public, constant(1)
 DECLARE cds_010 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"010"))
 DECLARE cds_011 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"011"))
 DECLARE cds_020 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"020"))
 DECLARE cds_021 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"021"))
 DECLARE cds_030 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"030"))
 DECLARE cds_040 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"040"))
 DECLARE cds_050 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"050"))
 DECLARE cds_060 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"060"))
 DECLARE cds_070 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"070"))
 DECLARE cds_080 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"080"))
 DECLARE cds_090 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"090"))
 DECLARE cds_100 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"100"))
 DECLARE cds_110 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"110"))
 DECLARE cds_120 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"120"))
 DECLARE cds_130 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"130"))
 DECLARE cds_140 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"140"))
 DECLARE cds_150 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"150"))
 DECLARE cds_160 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"160"))
 DECLARE cds_170 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"170"))
 DECLARE cds_180 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"180"))
 DECLARE cds_190 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"190"))
 DECLARE cds_200 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"200"))
 DECLARE cds_210 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"210"))
 DECLARE cds_0201 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"0201"))
 DECLARE cds_310 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"310"))
 DECLARE cds_311 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"311"))
 DECLARE cds_312 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"312"))
 DECLARE cds_313 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"313"))
 DECLARE cds_314 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"314"))
 DECLARE cdspaediatricint_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC02A"))
 DECLARE cdspaediatricext_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC02B"))
 DECLARE cdsadultint_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC03A"))
 DECLARE cdsadultext_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC03B"))
 DECLARE cdsneonatalint_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC01A"))
 DECLARE cdsneonatalext_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC01B"))
 DECLARE cbc_cc_alias_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001894,"CCMDS")
  )
 DECLARE cbc_cui_alias_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001894,"CUI"))
 DECLARE apc = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"APC"))
 DECLARE opa = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"OPA"))
 DECLARE opf = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"OPF"))
 DECLARE eal = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"EAL"))
 DECLARE ae = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"AE"))
 DECLARE ecds = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"ECDS"))
 DECLARE adc = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"ADC"))
 DECLARE csr = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"CSR"))
 DECLARE ccc = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"CCC"))
 DECLARE cac = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"CAC"))
 DECLARE cgs = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"CGS"))
 DECLARE cip = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",4001896,"CIP"))
 DECLARE batch_complete = f8 WITH public, constant(uar_get_code_by("MEANING",254591,"COMPLETE"))
 DECLARE batch_inerror = f8 WITH public, constant(uar_get_code_by("MEANING",254591,"INERROR"))
 DECLARE batch_inprocess = f8 WITH public, constant(uar_get_code_by("MEANING",254591,"INPROCESS"))
 DECLARE batch_pending = f8 WITH public, constant(uar_get_code_by("MEANING",254591,"PENDING"))
 DECLARE encntr_slice = c12 WITH public, constant("ENCNTR_SLICE")
 DECLARE pm_wait_list = c12 WITH public, constant("PM_WAIT_LIST")
 DECLARE sch_schedule = c12 WITH public, constant("SCH_SCHEDULE")
 DECLARE encntr_psy_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "PSYCHIATRICINPATIENT"))
 DECLARE mentalhealth_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "MENTALHEALTH"))
 DECLARE mhinpatient_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MHINPATIENT")
  )
 DECLARE d_not_known_postcode = c8 WITH noconstant("ZZ99 3WZ"), protect
 DECLARE sensitive_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",87,"SENSITIVE"))
#exit_ukr_cds_output_vars
 DECLARE carriercd = f8 WITH public, noconstant(uar_get_code_by("MEANING",370,"CARRIER"))
 DECLARE sponsorcd = f8 WITH public, noconstant(uar_get_code_by("MEANING",370,"SPONSOR"))
 DECLARE overseascd = f8 WITH public, noconstant(uar_get_code_by("MEANING",356,"PASOVERSEAS"))
 DECLARE maincommis = f8 WITH public, noconstant(uar_get_code_by("MEANING",369,"MAINCOMMISS"))
 DECLARE sla_type = f8 WITH public, noconstant(uar_get_code_by("MEANING",26307,"SLA"))
 SET last_mod = "162346"
 FREE SET cds
 RECORD cds(
   1 finished_file = c400
   1 unfinished_file = c400
   1 exception_file = c400
   1 activity[*]
     2 new_comm_ind = i4
     2 admin_category_cd = f8
     2 overseas_status = c1
     2 comm_org_id = f8
     2 age_activity = i4
     2 adm_method = c2
     2 med_service_cd = f8
     2 gp_ind = i4
     2 copy_ind = i4
     2 rulecopy1 = c5
     2 rulecopy2 = c5
     2 rulecopy3 = c5
     2 calc_comm = c5
     2 pt_class = c1
     2 point_dt_tm = dq8
     2 cds_batch_content_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 fin = vc
     2 pm_wait_list_id = f8
     2 referral_encntr_id = f8
     2 referral_pwl_id = f8
     2 trust_org_id = f8
     2 appt_location_cd = f8
     2 appt_set_number = i4
     2 appt_state = f8
     2 appt_status = c20
     2 organization_id = f8
     2 sch_event_id = f8
     2 schedule_id = f8
     2 sch_action_id = f8
     2 checkin_action_id = f8
     2 checkout_action_id = f8
     2 checkin_dt_tm = dq8
     2 error_flag = i2
     2 svc_cat_hx_id = f8
     2 referral_dt = dq8
     2 epr_id = f8
     2 epr_dt = dq8
     2 elh_id = f8
     2 elh_dt = dq8
     2 encntr_type = f8
     2 pt_sha = c3
     2 anonymous = i4
     2 main_comm = c5
     2 cost_comm = c5
     2 acc_cd = f8
     2 episode_id = vc
     2 service_category_cd = f8
     2 booking_code = c20
     2 neonatal_care_lvl = c1
     2 spell_number = c27
     2 version_number = c6
     2 cds_type = c3
     2 protocol_id = c3
     2 unique_cds_id = c35
     2 update_type = c2
     2 test_ind = c1
     2 census_dt = dq8
     2 bulk_repl_cds_gp = c3
     2 extract_dt_time = dq8
     2 period_start_dt = dq8
     2 period_end_dt = dq8
     2 primary_recip = c5
     2 copy_1 = c5
     2 copy_2 = c5
     2 copy_3 = c5
     2 copy_4 = c5
     2 copy_5 = c5
     2 copy_6 = c5
     2 copy_7 = c5
     2 sender_identity = c5
     2 local_patient_id = c10
     2 patient_id_org = c5
     2 nhs_number = c10
     2 old_nhs_number = c17
     2 birth_dt = dq8
     2 carer_support_ind = c2
     2 legal_classification = c2
     2 ethnic_group = c2
     2 marital_status = c1
     2 alias_status = c2
     2 sex = c1
     2 name_format_ind = c1
     2 patient_forename = c35
     2 patient_surname = c35
     2 pt_address_format_cd = c1
     2 pt_address_1 = c35
     2 pt_address_2 = c35
     2 pt_address_3 = c35
     2 pt_address_4 = c35
     2 pt_address_5 = c35
     2 pt_post_code = c8
     2 residence_pct = c5
     2 consultant_code = c8
     2 main_specialty_code = c3
     2 treatment_function_code = c3
     2 local_subspecialty = c5
     2 attend
       3 arrival_mode_cd = f8
       3 arrival_mode = c1
       3 arrival_mode_meaning = vc
     2 primary_icd = c6
     2 subsidiary_icd = c6
     2 secondary_1 = c6
     2 attendance_id = c12
     2 admin_category = c2
     2 attended_ind = c1
     2 first_attend = c1
     2 staff_type = c2
     2 operation_status_ind = c1
     2 attendance_outcome = c1
     2 attendance_date = dq8
     2 comm_ser_nbr = c6
     2 nhs_svc_agr_line_nbr = c10
     2 prov_ref_nbr = c17
     2 comm_ref_nbr = c17
     2 org_cd_prov = c5
     2 org_cd_comm = c5
     2 opcs4_cd1 = c7
     2 opcs4_cd2 = c7
     2 opcs4_cd3 = c7
     2 opcs4_cd4 = c7
     2 opcs4_cd5 = c7
     2 opcs4_cd6 = c7
     2 opcs4_cd7 = c7
     2 opcs4_cd8 = c7
     2 opcs4_cd9 = c7
     2 opcs4_cd10 = c7
     2 opcs4_cd11 = c7
     2 opcs4_cd12 = c7
     2 treatment_site_cd = c5
     2 intensity_intend = c2
     2 age_group_intend = c1
     2 sex_of_patients = c1
     2 gp_code = c8
     2 gp_practice = c6
     2 gp_pct = c5
     2 priority_type = c1
     2 service_type = c1
     2 referral_source = c2
     2 referral_source_cd = f8
     2 referral_req_rec_dt_tm = dq8
     2 referrer_cd = c8
     2 referrer_org_cd = c6
     2 last_dna_date = dq8
     2 hrg_code = c3
     2 hrg_version = c3
     2 hrg_dgvp_opcs = c4
     2 hrg_dgvp_read = c7
     2 read_code_ver = c1
     2 residence_pct = c5
     2 waiting_end_dt_tm = dq8
     2 removal_dt_tm = dq8
     2 appt_type = c40
     2 appt_location = c40
     2 removal_reason = c40
     2 reason_for_change = c40
     2 clinic_name = c40
     2 consultant_person_id = f8
 )
 SET stat = alterlist(cds->activity,size(cdsbatch->batch[rcnt].content,5))
 SET ward = 0
 SET waitlist = 0
 CALL echo(build2("Waitlist ind-",cdsbatch->batch[rcnt].opwl_batch_ind))
 IF ((cdsbatch->batch[rcnt].opwl_batch_ind=0))
  CALL echo(size(cdsbatch->batch[rcnt].content,5))
  CALL echo("Getting pm_wait_list_hist rows")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(cdsbatch->batch[rcnt].content,5))),
    cds_batch_content cbc,
    pm_wait_list_hist pwlh
   PLAN (d)
    JOIN (cbc
    WHERE (cbc.cds_batch_content_id=cdsbatch->batch[rcnt].content[d.seq].cds_batch_content_id))
    JOIN (pwlh
    WHERE pwlh.encntr_id=cbc.encntr_id
     AND ((pwlh.pm_wait_list_hist_id+ 0)=
    (SELECT
     max(pwlh1.pm_wait_list_hist_id)
     FROM pm_wait_list_hist pwlh1
     WHERE pwlh1.pm_wait_list_id=pwlh.pm_wait_list_id)))
   ORDER BY pwlh.beg_effective_dt_tm
   DETAIL
    cds->activity[d.seq].pm_wait_list_id = pwlh.pm_wait_list_id
   WITH counter
  ;end select
  CALL echo("Getting Attendances")
  SELECT INTO "nl:"
   priority_type = pm_get_cvo_alias(pwl.urgency_cd,nhs_report_code), service_type = pm_get_cvo_alias(
    pwl.service_type_requested_cd,nhs_report_code), referral_source = pm_get_cvo_alias(pwl
    .referral_source_cd,nhs_report_code),
   sex = pm_get_cvo_alias(p.sex_cd,nhs_report_code), admin_category = evaluate(e.accommodation_cd,0.0,
    pm_get_cvo_alias(pwl.admit_category_cd,nhs_report_code),pm_get_cvo_alias(e.accommodation_cd,
     nhs_report_code)), admin_category_cd = evaluate(e.accommodation_cd,0.0,pwl.admit_category_cd,e
    .accommodation_cd),
   carer_support_ind = pm_get_cvo_alias(pp.living_dependency_cd,nhs_report_code), main_specialty_code
    = pm_get_cvo_alias(e.service_category_cd,nhs_report_code), treatment_function_code =
   pm_get_cvo_alias(e.med_service_cd,nhs_report_code),
   alias_status = pm_get_cvo_alias(pa.person_alias_status_cd,nhs_report_code), local_subspecialty =
   pm_get_cvo_alias(e.med_service_cd,local->specialty_code), ethnic_group = pm_get_cvo_alias(p
    .ethnic_grp_cd,nhs_report_code),
   overseas_status = pm_get_cvo_alias(pud.value_cd,nhs_report_code)
   FROM (dummyt d  WITH seq = value(size(cdsbatch->batch[rcnt].content,5))),
    person p,
    encounter e,
    encntr_alias ea,
    sch_appt sa,
    sch_event se,
    pm_wait_list pwl,
    person_patient pp,
    person_alias pa,
    encntr_procedure ep,
    eem_benefit_alloc eba,
    encntr_org_reltn eor,
    organization_alias oa,
    pm_user_defined pud,
    dummyt d1
   PLAN (d)
    JOIN (sa
    WHERE (sa.schedule_id=cdsbatch->batch[rcnt].content[d.seq].parent_entity_id)
     AND (cdsbatch->batch[rcnt].content[d.seq].parent_entity_name="SCH_SCHEDULE")
     AND sa.sch_role_cd=patient
     AND sa.role_meaning="PATIENT"
     AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (se
    WHERE se.sch_event_id=sa.sch_event_id)
    JOIN (e
    WHERE e.encntr_id=sa.encntr_id)
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (pwl
    WHERE (pwl.pm_wait_list_id=cds->activity[d.seq].pm_wait_list_id))
    JOIN (pp
    WHERE (pp.person_id= Outerjoin(p.person_id)) )
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(p.person_id))
     AND (pa.person_alias_type_cd= Outerjoin(nhs_cd))
     AND (pa.active_ind= Outerjoin(1))
     AND (pa.active_status_cd= Outerjoin(active_status_cd)) )
    JOIN (ep
    WHERE (ep.encntr_id= Outerjoin(e.encntr_id)) )
    JOIN (eor
    WHERE (eor.encntr_id= Outerjoin(e.encntr_id))
     AND (eor.encntr_org_reltn_cd= Outerjoin(commissioner_cd))
     AND (eor.active_ind= Outerjoin(1)) )
    JOIN (oa
    WHERE (oa.organization_id= Outerjoin(eor.organization_id))
     AND (oa.org_alias_type_cd= Outerjoin(org_alias_cd)) )
    JOIN (eba
    WHERE (eba.encntr_id= Outerjoin(e.encntr_id)) )
    JOIN (pud
    WHERE (pud.parent_entity_id= Outerjoin(e.encntr_id))
     AND (pud.parent_entity_name= Outerjoin("ENCOUNTER"))
     AND (pud.udf_type_cd= Outerjoin(overseascd))
     AND (pud.active_ind= Outerjoin(1)) )
    JOIN (d1)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd IN (cnn_cd, fin_nbr))
   DETAIL
    cds->activity[d.seq].cds_batch_content_id = cdsbatch->batch[rcnt].content[d.seq].
    cds_batch_content_id, cds->activity[d.seq].version_number = "NHS003", cds->activity[d.seq].
    protocol_id = "010",
    cds->activity[d.seq].comm_ref_nbr = "8", cds->activity[d.seq].period_start_dt = cdsbatch->batch[
    rcnt].cds_batch_start_dt, cds->activity[d.seq].period_end_dt = cdsbatch->batch[rcnt].
    cds_batch_end_dt,
    cds->activity[d.seq].extract_dt_time = cnvtdatetime(sysdate), cds->activity[d.seq].update_type =
    cnvtstring(cdsbatch->batch[rcnt].content[d.seq].update_del_flag), cds->activity[d.seq].cds_type
     = uar_get_code_meaning(cdsbatch->batch[rcnt].content[d.seq].cds_type_cd),
    cds->activity[d.seq].sender_identity = build(cnvtupper(cdsbatch->org_code),"00"), cds->activity[d
    .seq].org_cd_prov = build(cnvtupper(cdsbatch->org_code),"00"), cds->activity[d.seq].
    patient_id_org = build(cnvtupper(cdsbatch->org_code),"00"),
    cds->activity[d.seq].unique_cds_id = build("B",substring(1,3,cnvtupper(cdsbatch->org_code)),"00",
     cnvtstring(cdsbatch->batch[rcnt].content[d.seq].cds_batch_content_id))
    IF (ea.encntr_alias_type_cd=cnn_cd)
     cds->activity[d.seq].local_patient_id = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSEIF (ea.encntr_alias_type_cd=fin_nbr)
     cds->activity[d.seq].fin = ea.alias
    ENDIF
    cds->activity[d.seq].attendance_id = cnvtstring(sa.schedule_id), sch_date = cnvtdatetime(cnvtdate
     (sa.beg_dt_tm),235959), cds->activity[d.seq].point_dt_tm = sch_date,
    cds->activity[d.seq].appt_state = sa.sch_state_cd, cds->activity[d.seq].appt_status = substring(1,
     20,uar_get_code_display(sa.sch_state_cd)), cds->activity[d.seq].person_id = sa.person_id,
    cds->activity[d.seq].encntr_id = sa.encntr_id, cds->activity[d.seq].pm_wait_list_id = pwl
    .pm_wait_list_id, cds->activity[d.seq].sch_event_id = se.sch_event_id,
    cds->activity[d.seq].schedule_id = sa.schedule_id, cds->activity[d.seq].attendance_date = sa
    .beg_dt_tm, cds->activity[d.seq].organization_id = e.organization_id,
    cds->activity[d.seq].clinic_name = uar_get_code_display(pwl.planned_procedure_cd), cds->activity[
    d.seq].appt_type = uar_get_code_display(se.appt_type_cd), cds->activity[d.seq].appt_location =
    uar_get_code_display(sa.appt_location_cd),
    cds->activity[d.seq].removal_dt_tm = pwl.removal_dt_tm, cds->activity[d.seq].waiting_end_dt_tm =
    pwl.waiting_end_dt_tm, cds->activity[d.seq].reason_for_change = uar_get_code_display(pwl
     .reason_for_change_cd),
    cds->activity[d.seq].removal_reason = uar_get_code_display(pwl.reason_for_removal_cd), cds->
    activity[d.seq].booking_code = uar_get_code_display(pwl.admit_booking_cd)
    IF (uar_get_code_meaning(pwl.urgency_cd) != "CANCER")
     cds->activity[d.seq].referral_dt = e.referral_rcvd_dt_tm
    ELSEIF (uar_get_code_meaning(pwl.urgency_cd)="CANCER")
     cds->activity[d.seq].referral_dt = pwl.referral_dt_tm
    ELSEIF (pwl.urgency_cd=0)
     cds->activity[d.seq].referral_dt = e.referral_rcvd_dt_tm
    ENDIF
    cds->activity[d.seq].encntr_type = e.encntr_type_cd, cds->activity[d.seq].nhs_svc_agr_line_nbr =
    cnvtstring(eba.eem_benefit_id), cds->activity[d.seq].overseas_status = overseas_status
    IF (pwl.urgency_cd > 0)
     cds->activity[d.seq].priority_type = priority_type
    ENDIF
    IF (pwl.service_type_requested_cd > 0)
     cds->activity[d.seq].service_type = service_type
    ENDIF
    IF (pwl.referral_source_cd > 0)
     cds->activity[d.seq].referral_source = referral_source
    ENDIF
    IF (p.sex_cd > 0)
     cds->activity[d.seq].sex = sex
    ENDIF
    cds->activity[d.seq].admin_category = admin_category, cds->activity[d.seq].admin_category_cd =
    admin_category_cd
    IF (e.accommodation_cd > 0)
     cds->activity[d.seq].acc_cd = e.accommodation_cd
    ELSE
     cds->activity[d.seq].acc_cd = pwl.admit_category_cd
    ENDIF
    IF (pp.living_dependency_cd > 0)
     cds->activity[d.seq].carer_support_ind = carer_support_ind
    ENDIF
    IF (e.service_category_cd > 0)
     cds->activity[d.seq].main_specialty_code = main_specialty_code
    ENDIF
    IF (e.med_service_cd > 0)
     cds->activity[d.seq].treatment_function_code = treatment_function_code, cds->activity[d.seq].
     local_subspecialty = local_subspecialty, cds->activity[d.seq].med_service_cd = e.med_service_cd
    ENDIF
    IF (p.ethnic_grp_cd > 0)
     cds->activity[d.seq].ethnic_group = ethnic_group
    ENDIF
    cds->activity[d.seq].encntr_type = e.encntr_type_cd, cds->activity[d.seq].birth_dt = p
    .birth_dt_tm, cds->activity[d.seq].age_activity = (datetimediff(cds->activity[d.seq].point_dt_tm,
     cds->activity[d.seq].birth_dt)/ 365),
    cds->activity[d.seq].operation_status_ind = "8"
    IF (trim(oa.alias,3) != " ")
     cds->activity[d.seq].org_cd_comm = build(oa.alias,"00")
    ENDIF
    cds->activity[d.seq].patient_forename = p.name_first, cds->activity[d.seq].patient_surname = p
    .name_last, cds->activity[d.seq].name_format_ind = "1"
    IF (trim(pa.alias) != " ")
     cds->activity[d.seq].nhs_number = pa.alias
     IF ((cdsbatch->anonymous=1))
      cds->activity[d.seq].anonymous = 1
     ENDIF
    ENDIF
    cds->activity[d.seq].alias_status = alias_status, cds->activity[d.seq].appt_location_cd = sa
    .appt_location_cd, cds->activity[d.seq].last_dna_date = pwl.last_dna_dt_tm
    IF (e.referral_rcvd_dt_tm IS NOT null)
     cds->activity[d.seq].referral_req_rec_dt_tm = e.referral_rcvd_dt_tm
    ENDIF
    IF (trim(pwl.commissioner_reference) != " ")
     cds->activity[d.seq].comm_ref_nbr = pwl.commissioner_reference
    ELSE
     cds->activity[d.seq].comm_ref_nbr = "9"
    ENDIF
   WITH counter, outerjoin = d1
  ;end select
 ELSEIF ((cdsbatch->batch[rcnt].opwl_batch_ind=1))
  SET waitlist = cdsbatch->batch[rcnt].opwl_batch_ind
  CALL echo(build2("Getting Waitlist for Batch ",cnvtstring(rcnt)))
  CALL echo("---------------------------------------------")
  SELECT INTO "nl:"
   priority_type = pm_get_cvo_alias(pwl.urgency_cd,nhs_report_code), service_type = pm_get_cvo_alias(
    pwl.service_type_requested_cd,nhs_report_code), referral_source = pm_get_cvo_alias(pwl
    .referral_source_cd,nhs_report_code),
   sex = pm_get_cvo_alias(p.sex_cd,nhs_report_code), admin_category = evaluate(e.accommodation_cd,0.0,
    pm_get_cvo_alias(pwl.admit_category_cd,nhs_report_code),pm_get_cvo_alias(e.accommodation_cd,
     nhs_report_code)), admin_category_cd = evaluate(e.accommodation_cd,0.0,pwl.admit_category_cd,e
    .accommodation_cd),
   carer_support_ind = pm_get_cvo_alias(pp.living_dependency_cd,nhs_report_code), main_specialty_code
    = pm_get_cvo_alias(e.service_category_cd,nhs_report_code), treatment_function_code =
   pm_get_cvo_alias(e.med_service_cd,nhs_report_code),
   alias_status = pm_get_cvo_alias(pa.person_alias_status_cd,nhs_report_code), local_subspecialty =
   pm_get_cvo_alias(e.med_service_cd,local->specialty_code), ethnic_group = pm_get_cvo_alias(p
    .ethnic_grp_cd,nhs_report_code),
   overseas_status = pm_get_cvo_alias(pud.value_cd,nhs_report_code)
   FROM (dummyt d  WITH seq = value(size(cdsbatch->batch[rcnt].content,5))),
    person p,
    encounter e,
    encntr_alias ea,
    pm_wait_list pwl,
    sch_appt sa,
    person_patient pp,
    person_alias pa,
    encntr_procedure ep,
    eem_benefit_alloc eba,
    encntr_org_reltn eor,
    organization_alias oa,
    pm_user_defined pud,
    dummyt d1
   PLAN (d)
    JOIN (pwl
    WHERE (pwl.pm_wait_list_id=cdsbatch->batch[rcnt].content[d.seq].parent_entity_id)
     AND (cdsbatch->batch[rcnt].content[d.seq].parent_entity_name="PM_WAIT_LIST"))
    JOIN (e
    WHERE e.encntr_id=pwl.encntr_id)
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (pp
    WHERE (pp.person_id= Outerjoin(p.person_id)) )
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(p.person_id))
     AND (pa.person_alias_type_cd= Outerjoin(nhs_cd))
     AND (pa.active_status_cd= Outerjoin(active_status_cd))
     AND (pa.active_ind= Outerjoin(1)) )
    JOIN (sa
    WHERE (sa.encntr_id= Outerjoin(pwl.encntr_id))
     AND (sa.sch_event_id= Outerjoin(pwl.sch_event_id))
     AND (sa.sch_role_cd= Outerjoin(patient))
     AND (sa.role_meaning= Outerjoin("PATIENT"))
     AND (sa.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100"))) )
    JOIN (ep
    WHERE (ep.encntr_id= Outerjoin(e.encntr_id)) )
    JOIN (eor
    WHERE (eor.encntr_id= Outerjoin(e.encntr_id))
     AND (eor.encntr_org_reltn_cd= Outerjoin(commissioner_cd)) )
    JOIN (oa
    WHERE (oa.organization_id= Outerjoin(eor.organization_id))
     AND (oa.org_alias_type_cd= Outerjoin(org_alias_cd)) )
    JOIN (eba
    WHERE (eba.encntr_id= Outerjoin(e.encntr_id)) )
    JOIN (pud
    WHERE (pud.parent_entity_id= Outerjoin(e.encntr_id))
     AND (pud.parent_entity_name= Outerjoin("ENCOUNTER"))
     AND (pud.udf_type_cd= Outerjoin(overseascd))
     AND (pud.active_ind= Outerjoin(1)) )
    JOIN (d1)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd IN (cnn_cd, visit_nbr, fin_nbr))
   DETAIL
    cds->activity[d.seq].cds_batch_content_id = cdsbatch->batch[rcnt].content[d.seq].
    cds_batch_content_id, cds->activity[d.seq].version_number = "NHS003", cds->activity[d.seq].
    protocol_id = "010",
    cds->activity[d.seq].comm_ref_nbr = "8", cds->activity[d.seq].period_start_dt = cdsbatch->batch[
    rcnt].cds_batch_start_dt, cds->activity[d.seq].period_end_dt = cdsbatch->batch[rcnt].
    cds_batch_end_dt,
    cds->activity[d.seq].extract_dt_time = cnvtdatetime(sysdate), cds->activity[d.seq].update_type =
    cnvtstring(cdsbatch->batch[rcnt].content[d.seq].update_del_flag), cds->activity[d.seq].cds_type
     = uar_get_code_meaning(cdsbatch->batch[rcnt].content[d.seq].cds_type_cd),
    cds->activity[d.seq].sender_identity = build(cnvtupper(cdsbatch->org_code),"00"), cds->activity[d
    .seq].org_cd_prov = build(cnvtupper(cdsbatch->org_code),"00"), cds->activity[d.seq].
    patient_id_org = build(cnvtupper(cdsbatch->org_code),"00"),
    cds->activity[d.seq].unique_cds_id = build("B",cnvtupper(cdsbatch->org_code),"00",cnvtstring(
      cdsbatch->batch[rcnt].content[d.seq].cds_batch_content_id))
    IF (ea.encntr_alias_type_cd=cnn_cd)
     cds->activity[d.seq].local_patient_id = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSEIF (ea.encntr_alias_type_cd=visit_nbr)
     cds->activity[d.seq].attendance_id = ea.alias
    ELSEIF (ea.encntr_alias_type_cd=fin_nbr)
     cds->activity[d.seq].fin = ea.alias
    ENDIF
    cds->activity[d.seq].clinic_name = uar_get_code_display(pwl.planned_procedure_cd)
    IF (uar_get_code_meaning(pwl.urgency_cd) != "CANCER")
     cds->activity[d.seq].referral_dt = e.referral_rcvd_dt_tm
    ELSEIF (uar_get_code_meaning(pwl.urgency_cd)="CANCER")
     cds->activity[d.seq].referral_dt = pwl.referral_dt_tm
    ELSEIF (pwl.urgency_cd=0)
     cds->activity[d.seq].referral_dt = e.referral_rcvd_dt_tm
    ENDIF
    cds->activity[d.seq].point_dt_tm = cnvtdatetime(sysdate), cds->activity[d.seq].overseas_status =
    overseas_status, cds->activity[d.seq].person_id = e.person_id,
    cds->activity[d.seq].encntr_id = e.encntr_id, cds->activity[d.seq].sch_event_id = pwl
    .sch_event_id, cds->activity[d.seq].pm_wait_list_id = pwl.pm_wait_list_id,
    cds->activity[d.seq].organization_id = e.organization_id, cds->activity[d.seq].appt_type =
    uar_get_code_display(pwl.appt_type_cd), cds->activity[d.seq].appt_location = uar_get_code_display
    (sa.appt_location_cd),
    cds->activity[d.seq].removal_dt_tm = pwl.removal_dt_tm, cds->activity[d.seq].waiting_end_dt_tm =
    pwl.waiting_end_dt_tm, cds->activity[d.seq].reason_for_change = uar_get_code_display(pwl
     .reason_for_change_cd),
    cds->activity[d.seq].removal_reason = uar_get_code_display(pwl.reason_for_removal_cd), cds->
    activity[d.seq].booking_code = uar_get_code_display(pwl.admit_booking_cd), cds->activity[d.seq].
    encntr_type = e.encntr_type_cd,
    cds->activity[d.seq].nhs_svc_agr_line_nbr = cnvtstring(eba.eem_benefit_id)
    IF (pwl.urgency_cd > 0)
     cds->activity[d.seq].priority_type = priority_type
    ENDIF
    IF (pwl.service_type_requested_cd > 0)
     cds->activity[d.seq].service_type = service_type
    ENDIF
    IF (pwl.referral_source_cd > 0)
     cds->activity[d.seq].referral_source = referral_source
    ENDIF
    IF (p.sex_cd > 0)
     cds->activity[d.seq].sex = sex
    ENDIF
    cds->activity[d.seq].admin_category = admin_category, cds->activity[d.seq].admin_category_cd =
    admin_category_cd
    IF (e.accommodation_cd > 0)
     cds->activity[d.seq].acc_cd = e.accommodation_cd
    ELSE
     cds->activity[d.seq].acc_cd = pwl.admit_category_cd
    ENDIF
    IF (pp.living_dependency_cd > 0)
     cds->activity[d.seq].carer_support_ind = carer_support_ind
    ENDIF
    IF (e.service_category_cd > 0)
     cds->activity[d.seq].main_specialty_code = main_specialty_code
    ENDIF
    IF (e.med_service_cd > 0)
     cds->activity[d.seq].treatment_function_code = treatment_function_code, cds->activity[d.seq].
     local_subspecialty = local_subspecialty, cds->activity[d.seq].med_service_cd = e.med_service_cd
    ENDIF
    IF (p.ethnic_grp_cd > 0)
     cds->activity[d.seq].ethnic_group = ethnic_group
    ENDIF
    cds->activity[d.seq].encntr_type = e.encntr_type_cd, cds->activity[d.seq].birth_dt = p
    .birth_dt_tm, cds->activity[d.seq].age_activity = (datetimediff(cds->activity[d.seq].point_dt_tm,
     cds->activity[d.seq].birth_dt)/ 365),
    cds->activity[d.seq].operation_status_ind = "9"
    IF (trim(oa.alias,3) != " ")
     cds->activity[d.seq].org_cd_comm = build(oa.alias,"00")
    ENDIF
    cds->activity[d.seq].patient_forename = p.name_first, cds->activity[d.seq].patient_surname = p
    .name_last, cds->activity[d.seq].name_format_ind = "1",
    cds->activity[d.seq].nhs_number = pa.alias
    IF ((cdsbatch->anonymous=1)
     AND trim(cds->activity[d.seq].nhs_number,3) != " ")
     cds->activity[d.seq].anonymous = 1
    ENDIF
    cds->activity[d.seq].alias_status = alias_status, cds->activity[d.seq].last_dna_date = pwl
    .last_dna_dt_tm
    IF (e.referral_rcvd_dt_tm IS NOT null)
     cds->activity[d.seq].referral_req_rec_dt_tm = e.referral_rcvd_dt_tm
    ENDIF
    IF (trim(pwl.commissioner_reference) != " ")
     cds->activity[d.seq].comm_ref_nbr = pwl.commissioner_reference
    ELSE
     cds->activity[d.seq].comm_ref_nbr = "9"
    ENDIF
    cds->activity[d.seq].first_attend = "1", cds->activity[d.seq].schedule_id = sa.schedule_id, cds->
    activity[d.seq].appt_location_cd = sa.appt_location_cd,
    cds->activity[d.seq].appt_state = sa.sch_state_cd, cds->activity[d.seq].appt_status = substring(1,
     20,uar_get_code_display(sa.sch_state_cd)), cds->activity[d.seq].schedule_id = sa.schedule_id,
    cds->activity[d.seq].attendance_date = sa.beg_dt_tm
    IF ((cds->activity[d.seq].attendance_date=0))
     cds->activity[d.seq].attendance_date = cnvtdatetime("31-DEC-2100")
    ENDIF
   WITH counter, outerjoin = d1
  ;end select
 ELSEIF ((cdsbatch->batch[rcnt].opwl_batch_ind=2))
  CALL echo(build2("Getting Ward Attenders for Batch ",cnvtstring(rcnt)))
  CALL echo("---------------------------------------------")
  SET ward = 1
  SELECT INTO "nl:"
   sex = pm_get_cvo_alias(p.sex_cd,nhs_report_code), admin_category = evaluate(e.accommodation_cd,0.0,
    pm_get_cvo_alias(pwl.admit_category_cd,nhs_report_code),pm_get_cvo_alias(e.accommodation_cd,
     nhs_report_code)), admin_category_cd = evaluate(e.accommodation_cd,0.0,pwl.admit_category_cd,e
    .accommodation_cd),
   carer_support_ind = pm_get_cvo_alias(pp.living_dependency_cd,nhs_report_code), main_specialty_code
    = pm_get_cvo_alias(e.service_category_cd,nhs_report_code), treatment_function_code =
   pm_get_cvo_alias(e.med_service_cd,nhs_report_code),
   alias_status = pm_get_cvo_alias(pa.person_alias_status_cd,nhs_report_code), local_subspecialty =
   pm_get_cvo_alias(e.med_service_cd,local->specialty_code), ethnic_group = pm_get_cvo_alias(p
    .ethnic_grp_cd,nhs_report_code),
   overseas_status = pm_get_cvo_alias(pud.value_cd,nhs_report_code)
   FROM (dummyt d  WITH seq = value(size(cdsbatch->batch[rcnt].content,5))),
    person p,
    encounter e,
    encntr_alias ea,
    pm_wait_list pwl,
    sch_appt sa,
    person_patient pp,
    person_alias pa,
    encntr_procedure ep,
    eem_benefit_alloc eba,
    encntr_org_reltn eor,
    organization_alias oa,
    pm_user_defined pud,
    dummyt d1
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=cdsbatch->batch[rcnt].content[d.seq].parent_entity_id)
     AND (cdsbatch->batch[rcnt].content[d.seq].parent_entity_name="ENCOUNTER"))
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (pwl
    WHERE (pwl.encntr_id= Outerjoin(e.encntr_id)) )
    JOIN (pp
    WHERE (pp.person_id= Outerjoin(p.person_id)) )
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(p.person_id))
     AND (pa.person_alias_type_cd= Outerjoin(nhs_cd))
     AND (pa.active_ind= Outerjoin(1))
     AND (pa.active_status_cd= Outerjoin(active_status_cd)) )
    JOIN (sa
    WHERE (sa.encntr_id= Outerjoin(pwl.encntr_id))
     AND (sa.sch_event_id= Outerjoin(pwl.sch_event_id))
     AND (sa.sch_role_cd= Outerjoin(patient))
     AND (sa.role_meaning= Outerjoin("PATIENT"))
     AND (sa.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100"))) )
    JOIN (ep
    WHERE (ep.encntr_id= Outerjoin(e.encntr_id)) )
    JOIN (eor
    WHERE (eor.encntr_id= Outerjoin(e.encntr_id))
     AND (eor.encntr_org_reltn_cd= Outerjoin(commissioner_cd))
     AND (eor.active_ind= Outerjoin(1)) )
    JOIN (oa
    WHERE (oa.organization_id= Outerjoin(eor.organization_id))
     AND (oa.org_alias_type_cd= Outerjoin(org_alias_cd)) )
    JOIN (eba
    WHERE (eba.encntr_id= Outerjoin(e.encntr_id)) )
    JOIN (pud
    WHERE (pud.parent_entity_id= Outerjoin(e.encntr_id))
     AND (pud.parent_entity_name= Outerjoin("ENCOUNTER"))
     AND (pud.udf_type_cd= Outerjoin(overseascd))
     AND (pud.active_ind= Outerjoin(1)) )
    JOIN (d1)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd IN (cnn_cd, visit_nbr, fin_nbr))
   DETAIL
    cds->activity[d.seq].cds_batch_content_id = cdsbatch->batch[rcnt].content[d.seq].
    cds_batch_content_id, cds->activity[d.seq].version_number = "NHS003", cds->activity[d.seq].
    protocol_id = "010",
    cds->activity[d.seq].comm_ref_nbr = "8", cds->activity[d.seq].period_start_dt = cdsbatch->batch[
    rcnt].cds_batch_start_dt, cds->activity[d.seq].period_end_dt = cdsbatch->batch[rcnt].
    cds_batch_end_dt,
    cds->activity[d.seq].extract_dt_time = cnvtdatetime(sysdate), cds->activity[d.seq].update_type =
    cnvtstring(cdsbatch->batch[rcnt].content[d.seq].update_del_flag), cds->activity[d.seq].cds_type
     = uar_get_code_meaning(cdsbatch->batch[rcnt].content[d.seq].cds_type_cd),
    cds->activity[d.seq].sender_identity = build(cnvtupper(cdsbatch->org_code),"00"), cds->activity[d
    .seq].org_cd_prov = build(cnvtupper(cdsbatch->org_code),"00"), cds->activity[d.seq].
    patient_id_org = build(cnvtupper(cdsbatch->org_code),"00"),
    cds->activity[d.seq].unique_cds_id = build("B",cnvtupper(cdsbatch->org_code),"00",cnvtstring(
      cdsbatch->batch[rcnt].content[d.seq].cds_batch_content_id))
    IF (ea.encntr_alias_type_cd=cnn_cd)
     cds->activity[d.seq].local_patient_id = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSEIF (ea.encntr_alias_type_cd=visit_nbr)
     cds->activity[d.seq].attendance_id = ea.alias
    ELSEIF (ea.encntr_alias_type_cd=fin_nbr)
     cds->activity[d.seq].fin = ea.alias
    ENDIF
    CALL echo("in ward attender code"), cds->activity[d.seq].point_dt_tm = e.reg_dt_tm, cds->
    activity[d.seq].person_id = e.person_id,
    cds->activity[d.seq].encntr_id = e.encntr_id, cds->activity[d.seq].sch_event_id = pwl
    .sch_event_id, cds->activity[d.seq].organization_id = e.organization_id,
    cds->activity[d.seq].overseas_status = overseas_status, cds->activity[d.seq].encntr_type = e
    .encntr_type_cd, cds->activity[d.seq].nhs_svc_agr_line_nbr = cnvtstring(eba.eem_benefit_id)
    IF (p.sex_cd > 0)
     cds->activity[d.seq].sex = sex
    ENDIF
    cds->activity[d.seq].admin_category = admin_category, cds->activity[d.seq].admin_category_cd =
    admin_category_cd
    IF (e.accommodation_cd > 0)
     cds->activity[d.seq].acc_cd = e.accommodation_cd
    ELSE
     cds->activity[d.seq].acc_cd = pwl.admit_category_cd
    ENDIF
    IF (pp.living_dependency_cd > 0)
     cds->activity[d.seq].carer_support_ind = carer_support_ind
    ENDIF
    IF (e.service_category_cd > 0)
     cds->activity[d.seq].main_specialty_code = main_specialty_code
    ENDIF
    IF (e.med_service_cd > 0)
     cds->activity[d.seq].treatment_function_code = treatment_function_code, cds->activity[d.seq].
     local_subspecialty = local_subspecialty, cds->activity[d.seq].med_service_cd = e.med_service_cd
    ENDIF
    IF (p.ethnic_grp_cd > 0)
     cds->activity[d.seq].ethnic_group = ethnic_group
    ENDIF
    cds->activity[d.seq].encntr_type = e.encntr_type_cd, cds->activity[d.seq].birth_dt = p
    .birth_dt_tm, cds->activity[d.seq].age_activity = (datetimediff(cds->activity[d.seq].point_dt_tm,
     cds->activity[d.seq].birth_dt)/ 365),
    cds->activity[d.seq].clinic_name = uar_get_code_display(e.loc_nurse_unit_cd)
    IF (trim(oa.alias,3) != " ")
     cds->activity[d.seq].org_cd_comm = build(oa.alias,"00")
    ENDIF
    cds->activity[d.seq].patient_forename = p.name_first, cds->activity[d.seq].patient_surname = p
    .name_last, cds->activity[d.seq].name_format_ind = "1",
    cds->activity[d.seq].nhs_number = pa.alias, cds->activity[d.seq].alias_status = alias_status, cds
    ->activity[d.seq].last_dna_date = pwl.last_dna_dt_tm
    IF (trim(pwl.commissioner_reference) != " ")
     cds->activity[d.seq].comm_ref_nbr = pwl.commissioner_reference
    ELSE
     cds->activity[d.seq].comm_ref_nbr = "9"
    ENDIF
    cds->activity[d.seq].first_attend = "1", cds->activity[d.seq].schedule_id = sa.schedule_id, cds->
    activity[d.seq].appt_location_cd = sa.appt_location_cd,
    cds->activity[d.seq].appt_state = sa.sch_state_cd, cds->activity[d.seq].appt_status = substring(1,
     20,uar_get_code_display(sa.sch_state_cd)), cds->activity[d.seq].schedule_id = sa.schedule_id,
    cds->activity[d.seq].attendance_date = e.reg_dt_tm
   WITH counter, outerjoin = d1
  ;end select
 ENDIF
 CALL echo("Getting scheduling event detail info")
 SELECT INTO "nl:"
  detail_field_value = pm_get_cvo_alias(sed.oe_field_value,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   sch_event_action sea,
   sch_event_detail sed,
   order_entry_fields oef
  PLAN (d)
   JOIN (sea
   WHERE (sea.sch_event_id=cds->activity[d.seq].sch_event_id)
    AND ((sea.schedule_id+ 0)=cds->activity[d.seq].schedule_id))
   JOIN (sed
   WHERE sed.sch_event_id=sea.sch_event_id
    AND sed.sch_action_id=sea.sch_action_id
    AND sed.oe_field_meaning IN ("SCHMEDSTAFFTYPE", "SCHOUTCOMEATTEND", "SCHATTENDANCE", "SURG-CPT",
   "OTHER"))
   JOIN (oef
   WHERE (oef.oe_field_id= Outerjoin(sed.oe_field_id)) )
  ORDER BY d.seq, sea.action_dt_tm, 0
  DETAIL
   IF (sed.oe_field_value > 0)
    IF (oef.description="1st Attendance")
     cds->activity[d.seq].first_attend = detail_field_value
    ENDIF
    IF (sea.action_meaning="RESCHEDULE")
     IF (sea.reason_meaning="PATDEFER")
      cds->activity[d.seq].attended_ind = "2"
     ELSEIF (sea.reason_meaning="HOSPDEFER")
      cds->activity[d.seq].attended_ind = "4"
     ENDIF
     cds->activity[d.seq].staff_type = "08", cds->activity[d.seq].attendance_outcome = "2", cds->
     activity[d.seq].operation_status_ind = "8"
    ELSEIF (sea.action_meaning IN ("CANCEL", "NOSHOW"))
     IF (sed.oe_field_meaning="SCHATTENDANCE")
      cds->activity[d.seq].attended_ind = detail_field_value
     ELSEIF (sed.oe_field_meaning="SCHOUTCOMEATTEND")
      cds->activity[d.seq].attendance_outcome = detail_field_value
     ELSEIF (oef.description="1st Attendance")
      cds->activity[d.seq].first_attend = detail_field_value
     ENDIF
     cds->activity[d.seq].operation_status_ind = "8", cds->activity[d.seq].staff_type = "08"
    ELSEIF (sea.action_meaning="CHECKIN")
     IF (sed.oe_field_meaning="SCHATTENDANCE")
      cds->activity[d.seq].attended_ind = detail_field_value
     ENDIF
    ELSEIF (sea.action_meaning="CHECKOUT")
     IF (sed.oe_field_meaning="SCHOUTCOMEATTEND")
      cds->activity[d.seq].attendance_outcome = detail_field_value
     ELSEIF (sed.oe_field_meaning="SCHMEDSTAFFTYPE")
      cds->activity[d.seq].staff_type = detail_field_value
     ELSEIF (oef.description="1st Attendance")
      cds->activity[d.seq].first_attend = detail_field_value
     ENDIF
    ENDIF
   ENDIF
  WITH counter
 ;end select
 IF ((cdsbatch->org_code IN ("RQX", "RNH", "5C5")))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
    encntr_loc_hist elh
   PLAN (d)
    JOIN (elh
    WHERE (elh.encntr_id=cds->activity[d.seq].encntr_id)
     AND ((elh.encntr_type_cd+ 0)=op_referral_type)
     AND elh.active_ind=1)
   DETAIL
    cds->activity[d.seq].first_attend = "1"
   WITH counter
  ;end select
 ENDIF
 SET last_mod = "162346"
 CALL echo("Getting Physician Info")
 DECLARE qualopa_ae_opw = vc WITH protect, noconstant("")
 DECLARE qualealrdate = vc WITH protect, noconstant("")
 DECLARE qualapc = vc WITH protect, noconstant("")
 IF ((cdsbatch->batch[rcnt].cds_batch_type_cd != ae))
  CALL echo("Getting Referrer")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
    encntr_prsnl_reltn epr,
    prsnl_alias pa,
    prsnl_reltn pr,
    organization_alias oa,
    prsnl_reltn_activity pra
   PLAN (d)
    JOIN (epr
    WHERE (epr.encntr_id=cds->activity[d.seq].encntr_id)
     AND epr.encntr_prsnl_r_cd=referdoc
     AND epr.manual_create_ind=0
     AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
     AND epr.active_ind=1)
    JOIN (pa
    WHERE pa.person_id=epr.prsnl_person_id
     AND pa.prsnl_alias_type_cd IN (doccnbr, external_id, nongp, gdp)
     AND pa.active_ind=1)
    JOIN (pr
    WHERE (pr.person_id= Outerjoin(epr.prsnl_person_id))
     AND (pr.parent_entity_name= Outerjoin("ORGANIZATION"))
     AND (pr.active_ind= Outerjoin(1)) )
    JOIN (oa
    WHERE (oa.organization_id= Outerjoin(pr.parent_entity_id))
     AND (oa.org_alias_type_cd= Outerjoin(org_alias_cd)) )
    JOIN (pra
    WHERE (pra.parent_entity_name= Outerjoin("ENCNTR_PRSNL_RELTN"))
     AND (pra.parent_entity_id= Outerjoin(epr.encntr_prsnl_reltn_id)) )
   ORDER BY d.seq, pa.prsnl_alias_id
   HEAD d.seq
    ref_cd_cnt = 0, ref_org_cnt = 0, tmp_ref_alias = fillstring(20," ")
   HEAD pa.prsnl_alias_id
    IF (pa.prsnl_alias_type_cd != doccnbr)
     ref_cd_cnt += 1, tmp_ref_alias = pa.alias
    ENDIF
   DETAIL
    ref_org_cnt += 1
    IF (pra.prsnl_reltn_activity_id > 0
     AND pra.prsnl_reltn_id=pr.prsnl_reltn_id)
     cds->activity[d.seq].referrer_org_cd = oa.alias
    ENDIF
   FOOT  pa.prsnl_alias_id
    null
   FOOT  d.seq
    IF (ref_cd_cnt=1)
     cds->activity[d.seq].referrer_cd = tmp_ref_alias
    ELSEIF (ref_cd_cnt=0
     AND pa.prsnl_alias_type_cd=doccnbr)
     cds->activity[d.seq].referrer_cd = pa.alias
    ENDIF
    IF (trim(cds->activity[d.seq].referrer_org_cd,3)=" "
     AND ref_org_cnt=1)
     cds->activity[d.seq].referrer_org_cd = oa.alias
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("Getting GP Info")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   person_prsnl_reltn ppr,
   prsnl_alias pna,
   organization_alias oa,
   prsnl_reltn_activity pra,
   prsnl_reltn_child prc,
   address a,
   prsnl_reltn pr
  PLAN (d)
   JOIN (ppr
   WHERE (ppr.person_id=cds->activity[d.seq].person_id)
    AND ppr.person_prsnl_r_cd=gp_cd
    AND cnvtdatetime(cds->activity[d.seq].point_dt_tm) BETWEEN ppr.beg_effective_dt_tm AND ppr
   .end_effective_dt_tm
    AND ppr.manual_create_ind=0
    AND ppr.active_ind=1)
   JOIN (pna
   WHERE pna.person_id=ppr.prsnl_person_id
    AND pna.prsnl_alias_type_cd=external_id
    AND pna.active_ind=1)
   JOIN (pra
   WHERE (pra.parent_entity_id= Outerjoin(ppr.person_prsnl_reltn_id))
    AND (pra.parent_entity_name= Outerjoin("PERSON_PRSNL_RELTN")) )
   JOIN (prc
   WHERE (prc.prsnl_reltn_id= Outerjoin(pra.prsnl_reltn_id))
    AND (prc.parent_entity_name= Outerjoin("ADDRESS"))
    AND (prc.parent_entity_id> Outerjoin(0)) )
   JOIN (a
   WHERE (a.address_id= Outerjoin(prc.parent_entity_id))
    AND (a.active_ind= Outerjoin(1)) )
   JOIN (pr
   WHERE (pr.prsnl_reltn_id= Outerjoin(prc.prsnl_reltn_id))
    AND (pr.parent_entity_name= Outerjoin("ORGANIZATION")) )
   JOIN (oa
   WHERE (oa.organization_id= Outerjoin(pr.parent_entity_id))
    AND (oa.org_alias_type_cd= Outerjoin(org_alias_cd)) )
  DETAIL
   cds->activity[d.seq].gp_code = pna.alias, cds->activity[d.seq].gp_practice = oa.alias, cds->
   activity[d.seq].gp_pct = build(uar_get_code_display(a.primary_care_cd),"00")
   IF ((cds->activity[d.seq].gp_code != "G99999*"))
    cds->activity[d.seq].gp_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Getting Consultant")
 SET qualopa_ae_opw = " (cnvtdatetime(curdate,curtime3) >= epr.beg_effective_dt_tm  "
 SET qualopa_ae_opw = concat(qualopa_ae_opw,
  " and cnvtdatetime(curdate,curtime3) < epr.end_effective_dt_tm ) ")
 SET qualealrdate = "( (cds->activity[d.seq].waiting_end_dt_tm != 0 "
 SET qualealrdate = concat(qualealrdate,
  " and cnvtdatetime(cds->activity[d.seq].waiting_end_dt_tm) > epr.beg_effective_dt_tm ")
 SET qualealrdate = concat(qualealrdate,
  " and cnvtdatetime(cds->activity[d.seq].waiting_end_dt_tm) <= epr.end_effective_dt_tm) ")
 SET qualealrdate = concat(qualealrdate," or  ",qualopa_ae_opw,")")
 SET qualapc = " (cnvtdatetime(cds->activity[d.seq].point_dt_tm) > epr.beg_effective_dt_tm  "
 SET qualapc = concat(qualapc,
  " and cnvtdatetime(cds->activity[d.seq].point_dt_tm) <= epr.end_effective_dt_tm ) ")
 SELECT
  IF ((cdsbatch->batch[rcnt].cds_batch_type_cd=apc))
   PLAN (d)
    JOIN (epr
    WHERE (epr.encntr_id=cds->activity[d.seq].encntr_id)
     AND epr.encntr_prsnl_r_cd=consultant_cd
     AND epr.active_ind=1
     AND parser(qualapc)
     AND epr.updt_task != 600600
     AND epr.prsnl_person_id > 0
     AND epr.manual_create_ind=0)
    JOIN (pra
    WHERE (pra.person_id= Outerjoin(epr.prsnl_person_id))
     AND (pra.prsnl_alias_type_cd= Outerjoin(nongp))
     AND (pra.active_ind= Outerjoin(1)) )
  ELSEIF ((cdsbatch->batch[rcnt].cds_batch_type_cd=eal))
   PLAN (d)
    JOIN (epr
    WHERE (epr.encntr_id=cds->activity[d.seq].encntr_id)
     AND epr.encntr_prsnl_r_cd=consultant_cd
     AND epr.active_ind=1
     AND parser(qualealrdate)
     AND epr.updt_task != 600600
     AND epr.prsnl_person_id > 0
     AND epr.manual_create_ind=0)
    JOIN (pra
    WHERE (pra.person_id= Outerjoin(epr.prsnl_person_id))
     AND (pra.prsnl_alias_type_cd= Outerjoin(nongp))
     AND (pra.active_ind= Outerjoin(1)) )
  ELSE
   PLAN (d)
    JOIN (epr
    WHERE (epr.encntr_id=cds->activity[d.seq].encntr_id)
     AND epr.encntr_prsnl_r_cd=consultant_cd
     AND epr.active_ind=1
     AND parser(qualopa_ae_opw)
     AND epr.updt_task != 600600
     AND epr.prsnl_person_id > 0
     AND epr.manual_create_ind=0)
    JOIN (pra
    WHERE (pra.person_id= Outerjoin(epr.prsnl_person_id))
     AND (pra.prsnl_alias_type_cd= Outerjoin(nongp))
     AND (pra.active_ind= Outerjoin(1)) )
  ENDIF
  INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encntr_prsnl_reltn epr,
   prsnl_alias pra
  DETAIL
   cds->activity[d.seq].consultant_person_id = epr.prsnl_person_id, cds->activity[d.seq].
   consultant_code = pra.alias
   IF ((cds->activity[d.seq].main_specialty_code="560"))
    cds->activity[d.seq].consultant_code = "M9999998"
   ELSEIF ((cds->activity[d.seq].main_specialty_code="950"))
    cds->activity[d.seq].consultant_code = "N9999998"
   ELSEIF ((cds->activity[d.seq].main_specialty_code="960"))
    cds->activity[d.seq].consultant_code = "H9999998"
   ENDIF
  WITH nocounter
 ;end select
 IF (checkdic("T2754_CONSULTANT_EPISODE","T",0) > 0
  AND (cdsbatch->batch[rcnt].cds_batch_type_cd=apc))
  CALL echo("Checking consultant episode table")
  SELECT INTO "nl:"
   main_specialty_code = pm_get_cvo_alias(t.service_category_cd,nhs_report_code),
   treatment_function_code = pm_get_cvo_alias(t.med_service_cd,nhs_report_code), local_subspecialty
    = pm_get_cvo_alias(t.med_service_cd,local->specialty_code)
   FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
    t2754_consultant_episode t,
    prsnl_alias pra
   PLAN (d)
    JOIN (t
    WHERE (t.encntr_id=cds->activity[d.seq].encntr_id)
     AND ((t.encntr_slice_id+ 0)=cds->activity[d.seq].nhs_consultant_episode_id))
    JOIN (pra
    WHERE (pra.person_id= Outerjoin(t.attend_prsnl_id))
     AND (pra.prsnl_alias_type_cd= Outerjoin(nongp))
     AND (pra.active_ind= Outerjoin(1)) )
   DETAIL
    cds->activity[d.seq].consultant_code = pra.alias
    IF ((cds->activity[d.seq].main_specialty_code="560"))
     cds->activity[d.seq].consultant_code = "M9999998"
    ELSEIF ((cds->activity[d.seq].main_specialty_code="950"))
     cds->activity[d.seq].consultant_code = "N9999998"
    ELSEIF ((cds->activity[d.seq].main_specialty_code="960"))
     cds->activity[d.seq].consultant_code = "H9999998"
    ENDIF
    IF (pra.prsnl_alias_id=0)
     cds->activity[d.seq].consultant_code = "C9999998"
    ENDIF
    cds->activity[d.seq].treatment_function_code = treatment_function_code, cds->activity[d.seq].
    local_subspecialty = local_subspecialty, cds->activity[d.seq].main_specialty_code =
    main_specialty_code
   WITH nocounter
  ;end select
 ENDIF
 SET last_mod = "202601"
 CALL echo("Getting Patient's Address Information")
 IF (validate(ukrformatpostcodenhsvarsrun)=0)
  DECLARE ukrformatpostcodenhsvarsrun = i2 WITH public, constant(1)
  DECLARE temp_postcode = c8 WITH protect, noconstant("")
  DECLARE postcode_key_len = i2 WITH noconstant(0), protect
  DECLARE postcode_start = c5 WITH noconstant(""), protect
  DECLARE postcode_end = c3 WITH noconstant(""), protect
  SUBROUTINE (format_postcode_nhs(postcode_key=vc,out_postcode=c8(ref)) =null)
    SET temp_postcode = ""
    SET postcode_key_len = textlen(trim(postcode_key))
    SET postcode_start = substring(1,(postcode_key_len - 3),trim(postcode_key))
    SET postcode_end = concat(substring((postcode_key_len - 2),3,trim(postcode_key)))
    SET out_postcode = concat(postcode_start,postcode_end)
  END ;Subroutine
 ENDIF
 SUBROUTINE (check_20790_option(s_cve_cdf_meaning=c12) =vc)
   DECLARE i_cve_option = vc WITH noconstant(" ")
   DECLARE s_cve_trimmed_cdf = vc WITH noconstant(" ")
   SET s_cve_trimmed_cdf = trim(cnvtupper(s_cve_cdf_meaning),3)
   SELECT INTO "nl:"
    ce.field_value
    FROM code_value c,
     code_value_extension ce
    PLAN (c
     WHERE c.code_set=20790
      AND c.cdf_meaning=s_cve_trimmed_cdf
      AND ((c.active_ind+ 0)=1)
      AND ((c.begin_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
      AND ((c.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate)))
     JOIN (ce
     WHERE ce.code_value=c.code_value
      AND ce.field_name="OPTION"
      AND ce.code_set=20790)
    DETAIL
     i_cve_option = trim(ce.field_value,3)
    WITH nocounter
   ;end select
   RETURN(i_cve_option)
 END ;Subroutine
 DECLARE getaddr_ind = i2 WITH public, noconstant(0)
 DECLARE check1_ind = i2 WITH public, noconstant(0)
 DECLARE nhscityopt_str = c12 WITH public, noconstant("NHSCITYOPT")
 DECLARE nhscityopt_value = i2 WITH public, noconstant(0)
 IF (check_20790_option(nhscityopt_str) != " ")
  SET nhscityopt_value = cnvtint(check_20790_option(nhscityopt_str))
 ENDIF
 SELECT INTO "nl:"
  country_postcode = pm_get_cvo_alias(a.country_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   address a,
   pct_sha_data psd
  PLAN (d)
   JOIN (a
   WHERE (a.parent_entity_id=cds->activity[d.seq].person_id)
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=home_addr_cd
    AND a.end_effective_dt_tm >= cnvtdatetime(cds->activity[d.seq].point_dt_tm))
   JOIN (psd
   WHERE (psd.postcode_key= Outerjoin(a.zipcode_key))
    AND (psd.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(cds->activity[d.seq].point_dt_tm)))
    AND (psd.end_effective_dt_tm>= Outerjoin(cnvtdatetime(cds->activity[d.seq].point_dt_tm))) )
  ORDER BY d.seq, a.beg_effective_dt_tm, 0
  HEAD d.seq
   getaddr_ind = 0
  HEAD a.beg_effective_dt_tm
   cds->activity[d.seq].residence_pct = " ", cds->activity[d.seq].pt_address_format_cd = " "
  DETAIL
   IF (a.beg_effective_dt_tm <= cnvtdatetime(cds->activity[d.seq].point_dt_tm))
    getaddr_ind = 1, check1_ind = 1
   ENDIF
   IF (getaddr_ind != 1)
    IF (a.beg_effective_dt_tm > cnvtdatetime(cds->activity[d.seq].point_dt_tm))
     getaddr_ind = 1, check1_ind = 1
    ENDIF
   ENDIF
   IF (getaddr_ind=1
    AND check1_ind=1)
    IF (trim(psd.pct_residence,3) != " ")
     cds->activity[d.seq].residence_pct = build(psd.pct_residence,"00")
    ENDIF
    cds->activity[d.seq].pt_post_code = a.zipcode
    IF ((cds->activity[d.seq].overseas_status IN ("", "8")))
     cds->activity[d.seq].pt_sha = psd.sha_residence
     IF (trim(psd.sha_residence,3)="")
      cds->activity[d.seq].pt_sha = "U"
     ENDIF
    ELSE
     IF (a.country_cd > 0)
      cds->activity[d.seq].pt_sha = "X"
     ELSE
      cds->activity[d.seq].pt_sha = "Y"
     ENDIF
    ENDIF
    IF (trim(country_postcode) != " ")
     cds->activity[d.seq].pt_post_code = country_postcode
    ENDIF
    IF (size(trim(a.street_addr)) > 0)
     cds->activity[d.seq].pt_address_format_cd = "1"
    ENDIF
    cds->activity[d.seq].pt_address_1 = a.street_addr, cds->activity[d.seq].pt_address_2 = a
    .street_addr2, cds->activity[d.seq].pt_address_3 = a.street_addr3
    IF (nhscityopt_value=1)
     cds->activity[d.seq].pt_address_4 = a.city
    ELSE
     cds->activity[d.seq].pt_address_4 = a.street_addr4
    ENDIF
    cds->activity[d.seq].pt_address_5 = a.county, check1_ind = 0
   ENDIF
  FOOT  a.beg_effective_dt_tm
   null
  FOOT  d.seq
   IF (trim(cds->activity[d.seq].pt_post_code,3)=" ")
    cds->activity[d.seq].pt_post_code = d_not_known_postcode
   ENDIF
   CALL format_postcode_nhs(cnvtupper(trim(cds->activity[d.seq].pt_post_code,4)),temp_postcode), cds
   ->activity[d.seq].pt_post_code = temp_postcode
  WITH counter
 ;end select
 CALL echo("Getting Location Info")
 SELECT INTO "nl:"
  value_code_alias = pm_get_cvo_alias(pla.value_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   pm_loc_attrib pla
  PLAN (d)
   JOIN (pla
   WHERE (pla.location_cd=cds->activity[d.seq].appt_location_cd))
  DETAIL
   IF (pla.attrib_type_cd=treatment_site_cd)
    cds->activity[d.seq].treatment_site_cd = pla.value_string
   ENDIF
   IF (pla.attrib_type_cd=age_group_int_cd)
    cds->activity[d.seq].age_group_intend = value_code_alias
   ENDIF
   IF (pla.attrib_type_cd=clin_care_int_cd)
    cds->activity[d.seq].intensity_intend = value_code_alias
   ENDIF
   IF (pla.attrib_type_cd=sex_of_pats_cd)
    cds->activity[d.seq].sex_of_patients = value_code_alias
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Getting OPCS4 info")
 DECLARE opcs4_source_voc_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",400,"OPCS4"))
 DECLARE proc_principle_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",401,
   "PROCEDURE"))
 DECLARE source_id = vc WITH public, noconstant
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   procedure proc,
   nomenclature nm
  PLAN (d)
   JOIN (proc
   WHERE (proc.encntr_id=cds->activity[d.seq].encntr_id)
    AND proc.active_ind=1
    AND proc.proc_priority > 0)
   JOIN (nm
   WHERE nm.nomenclature_id=proc.nomenclature_id
    AND nm.principle_type_cd=proc_principle_type_cd
    AND nm.source_vocabulary_cd=opcs4_source_voc_cd
    AND nm.active_ind=1)
  ORDER BY d.seq, proc.proc_priority
  HEAD d.seq
   cnt = 0, cds->activity[d.seq].operation_status_ind = "1"
  DETAIL
   source_id = "", source_id = replace(nm.source_identifier,".","",0)
   IF (trim(source_id,3) IN ("Q13", "Q383")
    AND (cdsbatch->anonymous=1))
    cds->activity[d.seq].anonymous = 1
   ENDIF
   IF (proc.dgvp_ind=1)
    cds->activity[d.seq].hrg_dgvp_opcs = source_id
   ENDIF
   IF (proc.proc_priority=1)
    cds->activity[d.seq].opcs4_cd1 = source_id, cds->activity[d.seq].operation_status_ind = "1"
   ENDIF
   IF (proc.proc_priority=2)
    cds->activity[d.seq].opcs4_cd2 = source_id
   ENDIF
   IF (proc.proc_priority=3)
    cds->activity[d.seq].opcs4_cd3 = source_id
   ENDIF
   IF (proc.proc_priority=4)
    cds->activity[d.seq].opcs4_cd4 = source_id
   ENDIF
   IF (proc.proc_priority=5)
    cds->activity[d.seq].opcs4_cd5 = source_id
   ENDIF
   IF (proc.proc_priority=6)
    cds->activity[d.seq].opcs4_cd6 = source_id
   ENDIF
   IF (proc.proc_priority=7)
    cds->activity[d.seq].opcs4_cd7 = source_id
   ENDIF
   IF (proc.proc_priority=8)
    cds->activity[d.seq].opcs4_cd8 = source_id
   ENDIF
   IF (proc.proc_priority=9)
    cds->activity[d.seq].opcs4_cd9 = source_id
   ENDIF
   IF (proc.proc_priority=10)
    cds->activity[d.seq].opcs4_cd10 = source_id
   ENDIF
   IF (proc.proc_priority=11)
    cds->activity[d.seq].opcs4_cd11 = source_id
   ENDIF
   IF (proc.proc_priority=12)
    cds->activity[d.seq].opcs4_cd12 = source_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   procedure proc,
   nomenclature nm
  PLAN (d
   WHERE trim(cds->activity[d.seq].opcs4_cd1,3)=" ")
   JOIN (proc
   WHERE (proc.encntr_id=cds->activity[d.seq].encntr_id)
    AND proc.active_ind=1)
   JOIN (nm
   WHERE nm.nomenclature_id=proc.nomenclature_id
    AND nm.principle_type_cd=proc_principle_type_cd
    AND nm.source_vocabulary_cd=opcs4_source_voc_cd
    AND nm.active_ind=1)
  ORDER BY d.seq, proc.proc_dt_tm
  HEAD d.seq
   proc_cnt = 0, cds->activity[d.seq].operation_status_ind = "1"
  DETAIL
   source_id = "", source_id = replace(nm.source_identifier,".","",0), proc_cnt += 1
   IF (trim(nm.source_identifier,3) IN ("Q13", "Q383")
    AND (cdsbatch->anonymous=1))
    cds->activity[d.seq].anonymous = 1
   ENDIF
   IF (proc.dgvp_ind=1)
    cds->activity[d.seq].hrg_dgvp_opcs = source_id
   ENDIF
   IF (proc_cnt=1)
    cds->activity[d.seq].opcs4_cd1 = source_id, cds->activity[d.seq].operation_status_ind = "1"
   ENDIF
   IF (proc_cnt=2)
    cds->activity[d.seq].opcs4_cd2 = source_id
   ENDIF
   IF (proc_cnt=3)
    cds->activity[d.seq].opcs4_cd3 = source_id
   ENDIF
   IF (proc_cnt=4)
    cds->activity[d.seq].opcs4_cd4 = source_id
   ENDIF
   IF (proc_cnt=5)
    cds->activity[d.seq].opcs4_cd5 = source_id
   ENDIF
   IF (proc_cnt=6)
    cds->activity[d.seq].opcs4_cd6 = source_id
   ENDIF
   IF (proc_cnt=7)
    cds->activity[d.seq].opcs4_cd7 = source_id
   ENDIF
   IF (proc_cnt=8)
    cds->activity[d.seq].opcs4_cd8 = source_id
   ENDIF
   IF (proc_cnt=9)
    cds->activity[d.seq].opcs4_cd9 = source_id
   ENDIF
   IF (proc_cnt=10)
    cds->activity[d.seq].opcs4_cd10 = source_id
   ENDIF
   IF (proc_cnt=11)
    cds->activity[d.seq].opcs4_cd11 = source_id
   ENDIF
   IF (proc_cnt=12)
    cds->activity[d.seq].opcs4_cd12 = source_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Getting Diagnosis info")
 DECLARE diag_source_voc_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",400,"ICD10"))
 DECLARE diag_source_voc_cd1 = f8 WITH public, noconstant(uar_get_code_by("MEANING",400,"ICD10WHO"))
 DECLARE diag_principle_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",401,"DIAG"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   diagnosis diag,
   nomenclature nm
  PLAN (d)
   JOIN (diag
   WHERE (diag.encntr_id=cds->activity[d.seq].encntr_id)
    AND diag.diag_priority > 0
    AND diag.active_ind=1)
   JOIN (nm
   WHERE nm.nomenclature_id=diag.nomenclature_id
    AND nm.principle_type_cd=diag_principle_type_cd
    AND nm.source_vocabulary_cd IN (diag_source_voc_cd, diag_source_voc_cd1)
    AND nm.active_ind=1)
  ORDER BY d.seq, diag.diag_priority, diag.beg_effective_dt_tm,
   0
  DETAIL
   source_id = replace(nm.source_identifier,".","",0)
   IF (trim(source_id,3) IN ("Z311", "Z312", "Z313", "Z318")
    AND (cdsbatch->anonymous=1))
    cds->activity[d.seq].anonymous = 1
   ENDIF
   IF (size(trim(nm.source_identifier))=3)
    source_id = build(trim(source_id),"X")
   ENDIF
   IF (diag.diag_priority=1)
    cds->activity[d.seq].primary_icd = source_id
   ELSEIF (diag.diag_priority=2)
    cds->activity[d.seq].secondary_1 = source_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Getting HRG info")
 DECLARE hrg_source_voc_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",400,"HRG"))
 DECLARE grouper_principle_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",401,
   "GROUPER"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   drg hrg,
   dummyt dnm,
   nomenclature nm,
   cmt_content_version ccv
  PLAN (d)
   JOIN (hrg
   WHERE (hrg.encntr_id=cds->activity[d.seq].encntr_id))
   JOIN (dnm)
   JOIN (nm
   WHERE nm.nomenclature_id=hrg.nomenclature_id
    AND nm.principle_type_cd=grouper_principle_type_cd
    AND nm.source_vocabulary_cd=hrg_source_voc_cd
    AND nm.active_ind=1)
   JOIN (ccv
   WHERE (ccv.source_vocabulary_cd= Outerjoin(nm.source_vocabulary_cd)) )
  DETAIL
   cds->activity[d.seq].hrg_code = nm.source_identifier, stringsize = size(trim(ccv.version_ft,3)),
   cds->activity[d.seq].hrg_version = substring((stringsize - 2),3,ccv.version_ft)
  WITH nocounter, outerjoin = dnm
 ;end select
 SET last_mod = "161211"
 RECORD reply(
   1 batch
     2 id = f8
     2 type_cd = f8
     2 start_dt_tm = dq8
     2 end_dt_tm = dq8
     2 finished_file = c400
     2 unfinished_file = c400
     2 error_cnt = i4
     2 error_file = c400
     2 raw_file = c400
     2 exception_file = c400
     2 flat_file = c400
     2 rtt_file_cnt = i4
     2 rtt_file[*]
       3 value = c400
     2 program_name = c30
     2 trust_org_id = f8
     2 trust_nhs_alias = c3
     2 main_commissioner = c5
     2 anonymous_ind = i2
     2 sensitive_ind = i2
     2 local_subspec_contrib_cd = f8
     2 version
       3 major = i2
       3 minor = i2
       3 display = vc
     2 census_ind = i2
     2 trust_specific_flag = i2
   1 prg_mode_flag = f8
   1 current_dt_tm = dq8
   1 entity_cnt = i4
   1 entity[*]
     2 entity_id = f8
     2 entity_name = c30
     2 status_flag = i2
     2 status_details = vc
     2 xml_fail_ind = i2
     2 person_id = f8
     2 encntr_id = f8
     2 encntr_slice_id = f8
     2 pm_wait_list_id = f8
     2 organization_id = f8
     2 sch_schedule_id = f8
     2 point_dt_tm = f8
     2 ae_apc_ind = i2
     2 ae_apc_admit_dt_tm = dq8
     2 cloud_referral_encntr_id = f8
     2 pm_offer_id = f8
     2 anonymous_ind = i2
     2 parent_entity_name = c30
     2 parent_entity_id = f8
     2 cds_type_cd = f8
     2 cds_type = c3
     2 update_del_flag = i2
     2 activity_dt_tm = dq8
     2 cds_row_error_ind = f8
     2 cds_batch_cnt_hist_id = f8
     2 cds_unique_id = c35
     2 alias_cnt = i4
     2 alias[*]
       3 cbc_alias_type_cd = f8
       3 cbc_alias = vc
     2 suppress_ind = i2
     2 fs_parent_entity_ident = vc
     2 fs_parent_entity_name = vc
     2 transaction_type_cd = f8
     2 comm
       3 org_calculated = c5
       3 org_commissioner = c5
       3 comm_ser_nbr = c6
       3 nhs_svc_agr_line_nbr = c10
       3 new_comm_ind = i2
       3 start_date = dq8
       3 end_date = dq8
       3 copy1 = c5
       3 copy2 = c5
       3 copy3 = c5
     2 address
       3 street1 = c35
       3 street2 = c35
       3 street3 = c35
       3 street4 = c35
       3 street5 = c35
       3 postcode = c8
       3 zipcode = c8
       3 res_pct = c5
       3 res_sha = c3
       3 address_id = f8
       3 country_cd = f8
       3 freetext_ind = i2
     2 person
       3 name_first = c35
       3 name_last = c35
       3 name_full_formatted = c100
       3 birth_dt_tm = dq8
       3 age_activity = i4
       3 deceased_dt_tm = dq8
       3 gender = c1
       3 stated_gender = c1
       3 carer_support = c2
       3 nhs = c10
       3 nhs_pool_cd = f8
       3 nhs_status = c2
       3 person_id = f8
       3 nhs_status_cd = f8
       3 confid_level_cd = f8
       3 withheld_identity_reason = c2
       3 name_last_key = vc
       3 name_first_key = vc
       3 name_middle = vc
       3 name_prefix = vc
       3 maritial_status_cd = f8
       3 marital_status = c1
       3 birth_dt_cd = f8
       3 ethnic_grp_cd = f8
       3 ethnic_category = c2
       3 organ_donor_cd = f8
       3 religion_cd = f8
       3 deceased_cd = f8
       3 deceased_source_cd = f8
       3 gender_cd = f8
       3 uk_resident_cd = f8
       3 active_ind = i2
       3 create_dt_tm = dq8
       3 create_prsnl_id = f8
       3 updt_cnt = i4
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 name_maiden
         4 person_name_id = f8
         4 full_formatted = vc
       3 name_previous
         4 person_name_id = f8
         4 full_formatted = vc
       3 phone_mobile
         4 phone_id = f8
         4 value = vc
       3 phone_home
         4 phone_id = f8
         4 value = vc
       3 phone_business
         4 phone_id = f8
         4 value = vc
       3 mrn_cnt = i4
       3 mrn[*]
         4 person_alias_id = f8
         4 value = c10
         4 pool_cd = f8
         4 pool_org_reltn_cnt = i4
         4 pool_org_reltn[*]
           5 person_org_reltn_org_idx = i4
           5 org_id = f8
       3 email_cnt = i4
       3 email[*]
         4 value = vc
         4 seq = i2
       3 org_reltn_school
         4 name = vc
         4 org_id = f8
       3 first_language_smd = vc
       3 interpreter_required_smd = vc
       3 interpreter_type_smd = vc
       3 clinical_history
         4 com_cnt = i4
         4 com_list[*]
           5 comorbidity_smd = vc
       3 safeguarding_concern
         4 sgc_cnt = i4
         4 sgc_list[*]
           5 safeguarding_concern_smd = vc
     2 gp
       3 nhs_alias = c8
       3 name_title = c25
       3 name_last = c25
       3 name_first = c25
       3 name_full_formatted = c45
       3 practice
         4 nhs_alias = c6
         4 name = c45
         4 org_id = f8
         4 address
           5 street1 = c35
           5 street2 = c35
           5 street3 = c35
           5 street4 = c35
           5 city = c35
           5 county = c35
           5 country = c35
           5 postcode = c8
         4 phone = vc
       3 pct
         4 nhs_alias = c5
         4 name = c45
         4 org_id = f8
       3 person_id = f8
     2 encntr
       3 fin_nbr = c27
       3 fin_nbr_pool_cd = f8
       3 mrn = c10
       3 mrn_pool_cd = f8
       3 main_specialty = c3
       3 treatment_function = c3
       3 local_subspecialty = c5
       3 admin_category = c2
       3 referral_rcvd_dt_tm = dq8
       3 referring_org_code = vc
       3 overseas_status = c1
       3 admission_method = c2
       3 ae_attendance_category = c1
       3 ec_attendance_category = c1
       3 ae_referral_src = c2
       3 ae_referral_src_smd = vc
       3 disch_destination = c2
       3 disch_dt_tm = dq8
       3 disch_prsnl_id = f8
       3 disch_disposition = c2
       3 intendsite_location_cd = f8
       3 loc_facility_cd = f8
       3 patient_class = c1
       3 org_code_patient_pathway = c5
       3 reg_dt_tm = dq8
       3 source_of_admission = c2
       3 consultant_episode_num = i4
       3 intendsite_location = c5
       3 intendsite_loctype = c3
       3 fit_to_leave_dt_tm = dq8
     2 encntr_ext
       3 accomodation_cd = f8
       3 active_ind = i2
       3 admit_mode_cd = f8
       3 admit_mode_smd = vc
       3 admit_src_cd = f8
       3 admit_type_cd = f8
       3 arrive_dt_tm = dq8
       3 contributor_system_cd = f8
       3 create_dt_tm = dq8
       3 create_prsnl_id = f8
       3 depart_dt_tm = dq8
       3 disch_disposition_cd = f8
       3 disch_to_loctn_cd = f8
       3 disch_hah_ind = c1
       3 est_complete_dt_tm = dq8
       3 encntr_type_cd = f8
       3 est_depart_dt_tm = dq8
       3 med_service_cd = f8
       3 mental_health_cd = f8
       3 overseas_status_cd = f8
       3 pre_reg_dt_tm = dq8
       3 pre_reg_prsnl_id = f8
       3 readmit_cd = f8
       3 reason_for_visit = vc
       3 reg_prsnl_id = f8
       3 service_category_cd = f8
       3 updt_cnt = i4
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 loc_nurse_unit_cd = f8
       3 loc_building_cd = f8
       3 loc_room_cd = f8
       3 loc_bed_cd = f8
       3 stream_cd = f8
       3 edobs_cd = f8
       3 encntr_comments = vc
       3 first_offer_dt_tm = dq8
       3 second_offer_dt_tm = dq8
       3 offer_made_dt_tm = dq8
       3 both_dates_refused_cd = f8
       3 encntr_loc_hist_id = f8
       3 pending_disch_disposition_cd = f8
       3 pending_disch_to_loctn_cd = f8
       3 accomodation_status_smd = vc
       3 overseas_visitor_status = c1
       3 ovs_vis_stat_date = dq8
     2 mental_health_act
       3 latest_legal_status_pos = i4
       3 mha_cnt = i4
       3 mha_list[*]
         4 start_dt_tm = dq8
         4 expiry_dt_tm = dq8
         4 classification_code = c2
     2 discharge
       3 admit_treat_code = c3
       3 safeguarding_concern_smd = vc
       3 discharge_status_smd = vc
       3 discharge_destination_smd = vc
       3 org_site_code = vc
       3 discharge_followup_smd = vc
     2 hrg
       3 code = c5
       3 version = c3
     2 diagnosis
       3 diagnosis_cnt = i2
       3 diagnosis_list[*]
         4 source_id = c6
       3 diagnosis_smd_cnt = i2
       3 diagnosis_smd_list[*]
         4 diag_smd = vc
         4 diag_seq_num = i4
         4 diag_qualifier_smd = vc
         4 diag_date = dq8
     2 procedure
       3 dgvp = c4
       3 min_guaranteed_admit_days = i4
       3 value_cnt = i2
       3 value[*]
         4 source_id = c4
         4 proc_dt_tm = dq8
         4 guaranteed_admit_days = i4
         4 procedure_id = f8
         4 main_op_hcp_reg_alias = c12
         4 resp_anaesth_pro_reg_alias = c12
       3 smd_value_cnt = i2
       3 smd_value[*]
         4 source_id = vc
         4 proc_dt_tm = dq8
         4 seq_num = i4
         4 procedure_id = f8
         4 main_op_hcp_reg_alias = c12
         4 resp_anaesth_pro_reg_alias = c12
     2 recipient
       3 primary = c5
       3 copy1 = c5
       3 copy2 = c5
       3 copy3 = c5
       3 copy4 = c5
       3 copy5 = c5
       3 copy6 = c5
       3 copy7 = c5
     2 attend
       3 arrival_mode = c1
       3 arrival_mode_cd = f8
       3 arrival_mode_smd = vc
       3 arrival_mode_meaning = vc
       3 incident_location_type = c2
       3 patient_group = c2
       3 dept_type = c2
       3 site_code_of_treatment = c12
       3 initial_assessment_dt_tm = dq8
       3 treatment_dt_tm = dq8
       3 doc_nurse_treatment_dt_tm = dq8
       3 seen_for_treatment_dt_tm = dq8
       3 attend_conclusion_dt_tm = dq8
       3 clin_ready_proceed_dt_tm = dq8
       3 staff_member_code = c3
       3 accident_dt_tm = dq8
       3 accident_cd = f8
       3 accident_cd_disp = vc
       3 ambulance_arrive_cd_disp = vc
       3 ambulance_serv_nbr = vc
       3 ambulance_org_code = vc
       3 place_cd = f8
       3 place_cd_disp = vc
       3 checkin_dt_tm = dq8
       3 checkout_dt_tm = dq8
       3 requested_dt_tm = dq8
       3 tracking_group_cd = f8
       3 tetantus_result_val = vc
       3 expected_treatment
         4 expected_treat_time = dq8
         4 ed_slot_alloc_dttm = dq8
       3 care_cont_id = vc
       3 acuity_smd = vc
       3 chief_complaint_smd = vc
       3 patient_info_given_smd = vc
       3 dta_treatment_function_code = vc
     2 csa_cnt = i4
     2 coded_scored_assessment[*]
       3 coded_assessment_smd = vc
       3 person_score = vc
       3 coded_assessment_timestamp = dq8
     2 cco_cnt = i4
     2 coded_clinical_obs[*]
       3 obs_smd = vc
       3 obs_val = vc
       3 obs_unit = vc
       3 obs_timestamp = dq8
     2 ccf_cnt = i4
     2 coded_clinical_finding[*]
       3 finding_smd = vc
       3 finding_timestamp = dq8
     2 investigation
       3 invest_cnt = i2
       3 invest_list[*]
         4 invest_code = c6
         4 invest_smd = vc
         4 proc_dt_tm = dq8
     2 treatment
       3 treat_cnt = i2
       3 treat_list[*]
         4 treat_code = c2
         4 sub_treat_code = c1
         4 treat_proc_dt_tm = dq8
         4 treat_smd = vc
     2 ae_diagnosis
       3 ae_diag_cnt = i2
       3 ae_diag_list[*]
         4 source_id = c6
         4 diag_smd = vc
         4 diag_seq_num = i4
         4 diag_qualifier_smd = vc
     2 referrals
       3 ref_cnt = i4
       3 ref_list[*]
         4 order_id = f8
         4 referred_to_service_smd = vc
         4 referral_request_dt_tm = dq8
         4 referral_completed_dt_tm = dq8
     2 injury
       3 injury_dt_tm = dq8
       3 place_of_injury_smd = vc
       3 place_of_injury_lat = vc
       3 place_of_injury_lon = vc
       3 injury_intent_smd = vc
       3 injury_activity_status_smd = vc
       3 injury_activity_type_smd = vc
       3 injury_mechanism_smd = vc
       3 drug_involv_cnt = i4
       3 drug_involv_list[*]
         4 alcohol_drug_involv_smd = vc
       3 assault_loc_desc = vc
     2 safeguarding_concern
       3 sgc_cnt = i4
       3 sgc_list[*]
         4 safeguarding_concern_smd = vc
     2 research_and_outbreak
       3 clinical_trial_id = vc
       3 disease_outbreak_notifcn_sct = vc
       3 disease_outbreak_notifcn_desc = vc
     2 maternity
       3 flag = i2
       3 babies_cnt = i4
       3 babies[*]
         4 birth_order = c1
         4 delivery_method = c1
         4 gest_len_asses = c2
         4 resus_meth = c1
         4 delivery_person_status = c1
         4 mrn = c10
         4 mrn_pool_cd = f8
         4 nhs = c10
         4 nhs_pool_cd = f8
         4 nhs_status = c2
         4 confid_level_cd = f8
         4 withheld_identity_reason = c2
         4 live_still_birth_ind = c1
         4 birth_weight = c4
         4 birth_dt_tm = dq8
         4 gender_cd = f8
         4 gender = c1
         4 delivery_place_type_act = c1
         4 dpta_location_class = c2
         4 dpta_location_type = c3
         4 overseas_visitor_status = c1
         4 overseas_vis_chg_cat = c1
       3 num_of_babies = c1
       3 first_ante_asses_dt_tm = dq8
       3 ante_gmp_cd = c8
       3 ante_gmp_prac_cd = c6
       3 delivery_place_type_int = c1
       3 dpti_location_class = c2
       3 dpti_location_type = c3
       3 delivery_place_chg_reason = c1
       3 ana_during_labour = c1
       3 ana_post_labour = c1
       3 gest_len_labour_onset = c2
       3 delivery_onset_meth = c1
       3 delivery_dt_tm = dq8
       3 num_prev_pregs = c2
       3 mother
         4 mrn = c10
         4 mrn_pool_cd = f8
         4 nhs = c10
         4 nhs_pool_cd = f8
         4 nhs_status = c2
         4 confid_level_cd = f8
         4 withheld_identity_reason = c2
         4 freetext_ind = i2
         4 street1 = c35
         4 street2 = c35
         4 street3 = c35
         4 street4 = c35
         4 street5 = c35
         4 postcode = c8
         4 res_pct = c5
         4 birth_dt_tm = dq8
         4 overseas_visitor_status = c1
         4 overseas_vis_chg_cat = c1
       3 neonatal_care_lvl = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->current_dt_tm = cnvtdatetime(sysdate)
 SELECT INTO "nl:"
  FROM org_org_reltn oor,
   organization_alias oa
  WHERE oor.org_org_reltn_cd=maincommis
   AND (oor.organization_id=cdsbatch->organization_id)
   AND oor.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND oor.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND oor.active_ind=1
   AND oa.organization_id=oor.related_org_id
   AND oa.org_alias_type_cd=org_alias_cd
   AND oa.active_ind=1
  DETAIL
   cds->activity.main_comm = build(substring(1,3,trim(oa.alias,3)),"00")
  WITH nocounter
 ;end select
 IF (trim(cds->activity.main_comm,3) IN (" ", "00"))
  SET cds->activity.main_comm = cdsbatch->org_code
 ENDIF
 CALL echo("Getting Commissioner")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5)))
  DETAIL
   cds->activity[d.seq].org_cd_comm = " ", cds->activity[d.seq].nhs_svc_agr_line_nbr = " ", cds->
   activity[d.seq].comm_ser_nbr = " "
   IF (substring(1,1,cds->activity[d.seq].gp_pct)="0")
    cds->activity[d.seq].gp_pct = " "
   ENDIF
   IF (substring(1,1,cds->activity[d.seq].residence_pct)="0")
    cds->activity[d.seq].residence_pct = " "
   ENDIF
   IF (trim(cds->activity[d.seq].overseas_status,3)=" ")
    cds->activity[d.seq].overseas_status = "8"
   ENDIF
   IF ((cds->activity[d.seq].overseas_status != "8"))
    IF ((((cds->activity[d.seq].overseas_status="1")) OR (((substring(1,2,cnvtupper(cds->activity[d
      .seq].pt_post_code))="IM") OR (((substring(1,2,cnvtupper(cds->activity[d.seq].pt_post_code))=
    "GI") OR (substring(1,2,cnvtupper(cds->activity[d.seq].pt_post_code)) IN ("JE", "GY"))) )) )) )
     cds->activity[d.seq].org_cd_comm = "TDH00", cds->activity[d.seq].calc_comm = "TDH00", cds->
     activity[d.seq].new_comm_ind = 1
    ELSEIF ((cds->activity[d.seq].overseas_status="2"))
     cds->activity[d.seq].org_cd_comm = build(substring(1,3,cds->activity.main_comm),"00"), cds->
     activity[d.seq].calc_comm = build(substring(1,3,cds->activity.main_comm),"00"), cds->activity[d
     .seq].new_comm_ind = 1
    ELSEIF ((((cds->activity[d.seq].overseas_status IN ("3", "4", "9"))) OR ((cds->activity[d.seq].
    admin_category="02"))) )
     cds->activity[d.seq].org_cd_comm = "VPP00", cds->activity[d.seq].calc_comm = "VPP00", cds->
     activity[d.seq].new_comm_ind = 1
    ENDIF
   ELSE
    IF ((cds->activity[d.seq].admin_category="02"))
     cds->activity[d.seq].org_cd_comm = "VPP00", cds->activity[d.seq].calc_comm = "VPP00", cds->
     activity[d.seq].new_comm_ind = 1
    ELSEIF ((cds->activity[d.seq].admin_category IN ("01", "03", "04")))
     IF (trim(cds->activity[d.seq].gp_pct,3) != " "
      AND (cds->activity[d.seq].gp_practice != "V81999"))
      IF (trim(cds->activity[d.seq].residence_pct,3) != " "
       AND substring(1,3,cds->activity[d.seq].residence_pct) != "X98")
       IF (((substring(1,1,cds->activity[d.seq].gp_pct)="5") OR (substring(1,1,cds->activity[d.seq].
        gp_pct)="T"))
        AND ((substring(1,1,cds->activity[d.seq].residence_pct)="5") OR (substring(1,1,cds->activity[
        d.seq].residence_pct)="T")) )
        cds->activity[d.seq].org_cd_comm = build(substring(1,3,cds->activity[d.seq].gp_pct),"00"),
        cds->activity[d.seq].calc_comm = build(substring(1,3,cds->activity[d.seq].gp_pct),"00")
       ELSE
        IF (substring(1,1,cds->activity[d.seq].gp_pct) IN ("6", "Z", "S")
         AND substring(1,1,cds->activity[d.seq].residence_pct) IN ("5", "T"))
         cds->activity[d.seq].org_cd_comm = build(substring(1,3,cds->activity[d.seq].residence_pct),
          "00"), cds->activity[d.seq].calc_comm = build(substring(1,3,cds->activity[d.seq].
           residence_pct),"00")
        ELSEIF (substring(1,1,cds->activity[d.seq].gp_pct) IN ("5", "T")
         AND substring(1,1,cds->activity[d.seq].residence_pct) IN ("6", "Z", "S"))
         cds->activity[d.seq].org_cd_comm = build(substring(1,3,cds->activity[d.seq].residence_pct),
          "00"), cds->activity[d.seq].calc_comm = build(substring(1,3,cds->activity[d.seq].
           residence_pct),"00")
        ENDIF
       ENDIF
      ELSE
       cds->activity[d.seq].org_cd_comm = build(substring(1,3,cds->activity[d.seq].gp_pct),"00"), cds
       ->activity[d.seq].calc_comm = build(substring(1,3,cds->activity[d.seq].gp_pct),"00")
      ENDIF
      cds->activity[d.seq].new_comm_ind = 1
     ELSE
      IF (trim(cds->activity[d.seq].residence_pct,3) != " "
       AND substring(1,3,cds->activity[d.seq].residence_pct) != "X98")
       cds->activity[d.seq].org_cd_comm = build(substring(1,3,cds->activity[d.seq].residence_pct),
        "00"), cds->activity[d.seq].calc_comm = build(substring(1,3,cds->activity[d.seq].
         residence_pct),"00"), cds->activity[d.seq].new_comm_ind = 1
      ELSE
       cds->activity[d.seq].org_cd_comm = build(substring(1,3,cds->activity.main_comm),"00"), cds->
       activity[d.seq].calc_comm = build(substring(1,3,cds->activity.main_comm),"00"), cds->activity[
       d.seq].new_comm_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET reply->entity_cnt = size(cds->activity,5)
 SET stat = alterlist(reply->entity,reply->entity_cnt)
 SET reply->batch.type_cd = cdsbatch->batch[rcnt].cds_batch_type_cd
 SET reply->batch.main_commissioner = cds->activity.main_comm
 FOR (icount = 1 TO value(size(cds->activity,5)))
   SET stat = alterlist(reply->entity[icount].procedure.value,1)
   SET reply->entity[icount].procedure.value_cnt = 1
   SET stat = alterlist(reply->entity[icount].diagnosis.diagnosis_list,1)
   SET reply->entity[icount].diagnosis.diagnosis_cnt = 1
   SET reply->entity[icount].encntr.patient_class = cds->activity[icount].pt_class
   SET reply->entity[icount].encntr.admission_method = cds->activity[icount].adm_method
   SET reply->entity[icount].maternity.neonatal_care_lvl = cds->activity[icount].neonatal_care_lvl
   SET reply->entity[icount].procedure.value[1].source_id = cds->activity[icount].opcs4_cd1
   SET reply->entity[icount].cds_type = cds->activity[icount].cds_type
   SET reply->entity[icount].comm.org_commissioner = cds->activity[icount].org_cd_comm
   SET reply->entity[icount].comm.nhs_svc_agr_line_nbr = cds->activity[icount].nhs_svc_agr_line_nbr
   SET reply->entity[icount].comm.comm_ser_nbr = cds->activity[icount].comm_ser_nbr
   SET reply->entity[icount].gp.practice = cds->activity[icount].gp_practice
   SET reply->entity[icount].address.res_pct = cds->activity[icount].residence_pct
   SET reply->entity[icount].encntr.overseas_status = cds->activity[icount].overseas_status
   SET reply->entity[icount].address.postcode = cds->activity[icount].pt_post_code
   SET reply->entity[icount].comm.org_calculated = cds->activity[icount].calc_comm
   SET reply->entity[icount].comm.new_comm_ind = cds->activity[icount].new_comm_ind
   SET reply->entity[icount].encntr.admin_category = cds->activity[icount].admin_category
   SET reply->entity[icount].hrg.code = cds->activity[icount].hrg_code
   SET reply->entity[icount].point_dt_tm = cds->activity[icount].point_dt_tm
   SET reply->entity[icount].diagnosis.diagnosis_list[1].source_id = cds->activity[icount].
   primary_icd
   SET reply->entity[icount].gp.pct.nhs_alias = cds->activity[icount].gp_pct
   SET reply->entity[icount].encntr.treatment_function = cds->activity[icount].
   treatment_function_code
   SET reply->entity[icount].encntr.main_specialty = cds->activity[icount].main_specialty_code
   SET reply->entity[icount].encntr.local_subspecialty = cds->activity[icount].local_subspecialty
   SET reply->entity[icount].encntr.mrn = cds->activity[icount].local_patient_id
   SET reply->entity[icount].person.nhs = cds->activity[icount].nhs_number
   SET reply->entity[icount].person.age_activity = cds->activity[icount].age_activity
   SET reply->entity[icount].cds_type_cd = cds->activity[icount].cds_type_cd
   SET reply->entity[icount].encntr.fin_nbr = cds->activity[icount].spell_number
   SET reply->entity[icount].person.nhs_status = cds->activity[icount].alias_status
   SET reply->entity[icount].attend.arrival_mode_cd = cds->activity[icount].attend.arrival_mode_cd
   SET reply->entity[icount].attend.arrival_mode_meaning = cds->activity[icount].attend.
   arrival_mode_meaning
 ENDFOR
 CALL echo("Commissioning Rules")
 RECORD special(
   1 benefit[*]
     2 string = vc
     2 varline = c132
     2 lines[*]
       3 stringline = c132
 )
 SELECT INTO "nl:"
  deriv_rule_num = cnvtint(replace(substring(1,10,lt.long_text),"@",""))
  FROM long_text lt
  WHERE (lt.parent_entity_id=cdsbatch->organization_id)
   AND lt.parent_entity_name="ORGANIZATION"
  ORDER BY deriv_rule_num
  HEAD REPORT
   cnt = 0
  HEAD deriv_rule_num
   cnt += 1, lstart = 1, stat = alterlist(special->benefit,cnt),
   string_len = size(trim(lt.long_text,3),1), stringline = substring(11,(string_len - 10),lt
    .long_text), lend = 1,
   lcnt = 2, stat = alterlist(special->benefit[cnt].lines,2), special->benefit[cnt].lines[1].
   stringline = 'select into "nl:" ',
   special->benefit[cnt].lines[2].stringline =
   "from (dummyt d with seq = value(size(reply->entity,5)))"
   WHILE (lend > 0)
    lend = findstring("~",stringline,lstart,0),
    IF (lend > 0)
     lcnt += 1, stat = alterlist(special->benefit[cnt].lines,lcnt), workline = substring(lstart,(lend
       - lstart),stringline),
     special->benefit[cnt].lines[lcnt].stringline = replace(workline,"~","",0), lstart = (lend+ 1)
    ELSE
     lend = 0
    ENDIF
   ENDWHILE
   lcnt += 1, stat = alterlist(special->benefit[cnt].lines,lcnt), special->benefit[cnt].lines[lcnt].
   stringline = " reply->entity[d.seq].comm.new_comm_ind = 2",
   lcnt += 1, stat = alterlist(special->benefit[cnt].lines,lcnt), special->benefit[cnt].lines[lcnt].
   stringline = "with nocounter go"
  WITH nocounter
 ;end select
 FOR (zrule = 1 TO size(special->benefit,5))
   SET rlines = size(special->benefit[zrule].lines,5)
   SET zprs = 1
   WHILE (zprs <= rlines)
     CALL parser(special->benefit[zrule].lines[zprs].stringline)
     CALL log_message(special->benefit[zrule].lines[zprs].stringline,log_level_debug)
     SET zprs += 1
   ENDWHILE
 ENDFOR
 FREE RECORD special
 FOR (icount = 1 TO value(size(cds->activity,5)))
   SET cds->activity[icount].org_cd_comm = reply->entity[icount].comm.org_commissioner
   SET cds->activity[icount].nhs_svc_agr_line_nbr = reply->entity[icount].comm.nhs_svc_agr_line_nbr
   SET cds->activity[icount].comm_ser_nbr = reply->entity[icount].comm.comm_ser_nbr
   SET cds->activity[icount].gp_practice = reply->entity[icount].gp.practice
   SET cds->activity[icount].residence_pct = reply->entity[icount].address.res_pct
   SET cds->activity[icount].overseas_status = reply->entity[icount].encntr.overseas_status
   SET cds->activity[icount].pt_post_code = reply->entity[icount].address.postcode
   SET cds->activity[icount].calc_comm = reply->entity[icount].comm.org_calculated
   SET cds->activity[icount].new_comm_ind = reply->entity[icount].comm.new_comm_ind
   SET cds->activity[icount].admin_category = reply->entity[icount].encntr.admin_category
   SET cds->activity[icount].hrg_code = reply->entity[icount].hrg.code
   SET cds->activity[icount].point_dt_tm = reply->entity[icount].point_dt_tm
   SET cds->activity[icount].primary_icd = reply->entity[icount].diagnosis.diagnosis_list[1].
   source_id
   SET cds->activity[icount].gp_pct = reply->entity[icount].gp.pct
   SET cds->activity[icount].treatment_function_code = reply->entity[icount].encntr.
   treatment_function
   SET cds->activity[icount].main_specialty_code = reply->entity[icount].encntr.main_specialty
   SET cds->activity[icount].local_subspecialty = reply->entity[icount].encntr.local_subspecialty
   SET cds->activity[icount].local_patient_id = reply->entity[icount].encntr.mrn
   SET cds->activity[icount].nhs_number = reply->entity[icount].person.nhs
   SET cds->activity[icount].age_activity = reply->entity[icount].person.age_activity
   SET cds->activity[icount].cds_type_cd = reply->entity[icount].cds_type_cd
   SET cds->activity[icount].spell_number = reply->entity[icount].encntr.fin_nbr
   SET cds->activity[icount].alias_status = reply->entity[icount].person.nhs_status
   SET cds->activity[icount].rulecopy1 = reply->entity[icount].comm.copy1
   SET cds->activity[icount].rulecopy2 = reply->entity[icount].comm.copy2
   SET cds->activity[icount].rulecopy3 = reply->entity[icount].comm.copy3
 ENDFOR
 FREE RECORD reply
 CALL echo("Setting Commissioner/Serial")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5)))
  DETAIL
   IF (substring(1,3,cds->activity[d.seq].org_cd_comm) IN ("VPP", "TDH")
    AND size(trim(cds->activity[d.seq].comm_ser_nbr,3)) <= 1)
    cds->activity[d.seq].comm_ser_nbr = build(cds->activity[d.seq].org_cd_comm,cds->activity[d.seq].
     comm_ser_nbr)
   ELSEIF (trim(cds->activity[d.seq].nhs_svc_agr_line_nbr,3)=" "
    AND size(trim(cds->activity[d.seq].comm_ser_nbr,3)) <= 1)
    cds->activity[d.seq].comm_ser_nbr = build("OAT",cds->activity[d.seq].comm_ser_nbr)
   ELSEIF (size(trim(cds->activity[d.seq].comm_ser_nbr,3)) <= 1)
    cds->activity[d.seq].comm_ser_nbr = build(cds->activity[d.seq].org_cd_comm,cds->activity[d.seq].
     comm_ser_nbr)
   ENDIF
   IF (size(trim(cds->activity[d.seq].org_cd_comm,3))=3)
    cds->activity[d.seq].org_cd_comm = build(substring(1,3,cds->activity[d.seq].org_cd_comm),"00")
   ENDIF
   IF (size(trim(cds->activity[d.seq].gp_pct,3))=3)
    cds->activity[d.seq].gp_pct = build(substring(1,3,cds->activity[d.seq].gp_pct),"00")
   ENDIF
   IF (size(trim(cds->activity[d.seq].residence_pct,3))=3)
    cds->activity[d.seq].residence_pct = build(substring(1,3,cds->activity[d.seq].residence_pct),"00"
     )
   ENDIF
   CALL log_message(build(cds->activity[d.seq].encntr_id),log_level_debug),
   CALL log_message(build("comm->",cds->activity[d.seq].org_cd_comm),log_level_debug),
   CALL log_message(build("seri->",cds->activity[d.seq].comm_ser_nbr),log_level_debug),
   CALL log_message(build("main->",cds->activity.main_comm),log_level_debug),
   CALL log_message(build("gppct->",cds->activity[d.seq].gp_pct),log_level_debug),
   CALL log_message(build("rspct->",cds->activity[d.seq].residence_pct),log_level_debug)
  WITH nocounter
 ;end select
 DECLARE ser_num_nscag = c5 WITH constant("YDD82"), protect
 CALL echo("Determining recipients")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5)))
  DETAIL
   IF (trim(cds->activity[d.seq].org_cd_comm,3)="00")
    cds->activity[d.seq].org_cd_comm = " "
   ENDIF
   IF (trim(cds->activity[d.seq].gp_practice,3) IN ("00", " "))
    IF (trim(cds->activity[d.seq].comm_ser_nbr,3) IN ("OAT*", "NCA*"))
     cds->activity[d.seq].gp_practice = "V81998"
    ELSE
     cds->activity[d.seq].gp_practice = "V81999"
    ENDIF
   ENDIF
   IF ((cds->activity[d.seq].copy_ind=0)
    AND (cds->activity[d.seq].gp_ind=1)
    AND (cds->activity[d.seq].org_cd_comm=cds->activity[d.seq].gp_pct)
    AND  NOT (substring(1,3,cds->activity[d.seq].comm_ser_nbr) IN ("NCA", "OAT"))
    AND (cds->activity[d.seq].admin_category != "02")
    AND  NOT ((cds->activity[d.seq].overseas_status IN ("1", "2", "3", "4"))))
    IF (size(trim(cds->activity[d.seq].residence_pct,3)) > 0)
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].residence_pct
    ELSE
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].org_cd_comm
    ENDIF
    IF (substring(1,3,cds->activity[d.seq].gp_pct) != substring(1,3,cds->activity[d.seq].
     primary_recip))
     cds->activity[d.seq].copy_1 = cds->activity[d.seq].gp_pct
    ENDIF
    cds->activity[d.seq].copy_ind = 1
   ENDIF
   IF ((cds->activity[d.seq].copy_ind=0)
    AND (cds->activity[d.seq].gp_ind=0)
    AND (cds->activity[d.seq].org_cd_comm=cds->activity[d.seq].residence_pct)
    AND  NOT (substring(1,3,cds->activity[d.seq].comm_ser_nbr) IN ("NCA", "OAT"))
    AND (cds->activity[d.seq].admin_category != "02")
    AND  NOT ((cds->activity[d.seq].overseas_status IN ("1", "2", "3", "4"))))
    cds->activity[d.seq].primary_recip = cds->activity[d.seq].residence_pct
    IF (substring(1,3,cds->activity.main_comm) != substring(1,3,cds->activity[d.seq].primary_recip))
     cds->activity[d.seq].copy_1 = cds->activity.main_comm
    ENDIF
    cds->activity[d.seq].copy_ind = 1
   ENDIF
   IF ((cds->activity[d.seq].copy_ind=0)
    AND (cds->activity[d.seq].gp_ind=1)
    AND substring(1,3,cds->activity[d.seq].comm_ser_nbr) IN ("OAT", "NCA")
    AND (cds->activity[d.seq].admin_category != "02")
    AND  NOT ((cds->activity[d.seq].overseas_status IN ("1", "2", "3", "4"))))
    IF (size(trim(cds->activity[d.seq].residence_pct,3)) > 0)
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].residence_pct
    ELSE
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].gp_pct
    ENDIF
    IF (substring(1,3,cds->activity[d.seq].gp_pct) != substring(1,3,cds->activity[d.seq].
     primary_recip))
     cds->activity[d.seq].copy_1 = cds->activity[d.seq].gp_pct
    ELSEIF (substring(1,3,cds->activity[d.seq].main_comm) != substring(1,3,cds->activity[d.seq].
     primary_recip))
     cds->activity[d.seq].copy_1 = cds->activity.main_comm
    ENDIF
    IF (substring(1,3,cds->activity.main_comm) != substring(1,3,cds->activity[d.seq].primary_recip)
     AND substring(1,3,cds->activity.main_comm) != substring(1,3,cds->activity[d.seq].copy_1)
     AND size(trim(cds->activity[d.seq].copy_1,3)) > 0)
     cds->activity[d.seq].copy_2 = cds->activity.main_comm
    ENDIF
    cds->activity[d.seq].copy_ind = 1
   ENDIF
   IF ((cds->activity[d.seq].copy_ind=0)
    AND (cds->activity[d.seq].gp_ind=0)
    AND substring(1,3,cds->activity[d.seq].comm_ser_nbr) IN ("OAT", "NCA")
    AND (cds->activity[d.seq].admin_category != "02")
    AND  NOT ((cds->activity[d.seq].overseas_status IN ("1", "2", "3", "4"))))
    IF (size(trim(cds->activity[d.seq].residence_pct,3)) > 0)
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].residence_pct
    ELSE
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].gp_pct
    ENDIF
    IF (substring(1,3,cds->activity[d.seq].gp_pct) != substring(1,3,cds->activity[d.seq].
     primary_recip))
     cds->activity[d.seq].copy_1 = cds->activity[d.seq].gp_pct
    ELSEIF (substring(1,3,cds->activity[d.seq].main_comm) != substring(1,3,cds->activity[d.seq].
     primary_recip))
     cds->activity[d.seq].copy_1 = cds->activity.main_comm
    ENDIF
    IF (substring(1,3,cds->activity.main_comm) != substring(1,3,cds->activity[d.seq].primary_recip)
     AND substring(1,3,cds->activity.main_comm) != substring(1,3,cds->activity[d.seq].copy_1)
     AND size(trim(cds->activity[d.seq].copy_1,3)) > 0)
     cds->activity[d.seq].copy_2 = cds->activity.main_comm
    ENDIF
    cds->activity[d.seq].copy_ind = 1
   ENDIF
   IF ((cds->activity[d.seq].copy_ind=0)
    AND (cds->activity[d.seq].gp_ind=0)
    AND (cds->activity[d.seq].overseas_status IN ("1", "2")))
    cds->activity[d.seq].primary_recip = "TDH00", cds->activity[d.seq].copy_1 = cds->activity.
    main_comm, cds->activity[d.seq].copy_ind = 1
   ENDIF
   IF ((cds->activity[d.seq].copy_ind=0)
    AND (cds->activity[d.seq].gp_ind=1)
    AND (cds->activity[d.seq].overseas_status IN ("1", "2")))
    cds->activity[d.seq].primary_recip = "TDH00"
    IF (substring(1,3,cds->activity[d.seq].gp_pct) != substring(1,3,cds->activity[d.seq].
     primary_recip))
     cds->activity[d.seq].copy_1 = cds->activity[d.seq].gp_pct
    ELSE
     cds->activity[d.seq].copy_1 = cds->activity.main_comm
    ENDIF
    IF (substring(1,3,cds->activity.main_comm) != substring(1,3,cds->activity[d.seq].primary_recip)
     AND substring(1,3,cds->activity.main_comm) != substring(1,3,cds->activity[d.seq].copy_1))
     cds->activity[d.seq].copy_2 = cds->activity.main_comm
    ENDIF
    cds->activity[d.seq].copy_ind = 1
   ENDIF
   IF ((cds->activity[d.seq].gp_ind=0)
    AND (cds->activity[d.seq].overseas_status IN ("3", "4")))
    cds->activity[d.seq].primary_recip = "VPP00"
   ENDIF
   IF ((cds->activity[d.seq].copy_ind=0)
    AND (cds->activity[d.seq].gp_ind=1)
    AND (cds->activity[d.seq].overseas_status IN ("3", "4")))
    cds->activity[d.seq].primary_recip = "VPP00"
    IF (substring(1,3,cds->activity[d.seq].gp_pct) != substring(1,3,cds->activity[d.seq].
     primary_recip))
     cds->activity[d.seq].copy_1 = cds->activity[d.seq].gp_pct
    ENDIF
    cds->activity[d.seq].copy_ind = 1
   ENDIF
   IF ((cds->activity[d.seq].copy_ind=0)
    AND (cds->activity[d.seq].gp_ind=1)
    AND (cds->activity[d.seq].comm_ser_nbr != "YDD82")
    AND  NOT (substring(1,3,cds->activity[d.seq].comm_ser_nbr) IN ("NCA", "OAT"))
    AND substring(1,3,cds->activity[d.seq].org_cd_comm) != substring(1,3,cds->activity[d.seq].gp_pct)
    AND  NOT ((cds->activity[d.seq].org_cd_comm IN ("VPP00", "TDH00"))))
    IF (size(trim(cds->activity[d.seq].residence_pct,3)) > 0)
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].residence_pct
    ELSE
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].gp_pct
    ENDIF
    IF (substring(1,3,cds->activity[d.seq].gp_pct) != substring(1,3,cds->activity[d.seq].
     primary_recip))
     cds->activity[d.seq].copy_1 = cds->activity[d.seq].gp_pct
    ELSE
     cds->activity[d.seq].copy_2 = cds->activity[d.seq].org_cd_comm
    ENDIF
    IF (substring(1,3,cds->activity[d.seq].org_cd_comm) != substring(1,3,cds->activity[d.seq].copy_1)
    )
     cds->activity[d.seq].copy_2 = cds->activity[d.seq].org_cd_comm
    ENDIF
    cds->activity[d.seq].copy_ind = 1
   ENDIF
   IF ((cds->activity[d.seq].copy_ind=0)
    AND (cds->activity[d.seq].gp_ind=0)
    AND (cds->activity[d.seq].comm_ser_nbr != "YDD82")
    AND  NOT (substring(1,3,cds->activity[d.seq].comm_ser_nbr) IN ("NCA", "OAT"))
    AND substring(1,3,cds->activity[d.seq].org_cd_comm) != substring(1,3,cds->activity[d.seq].
    residence_pct)
    AND  NOT ((cds->activity[d.seq].org_cd_comm IN ("VPP00", "TDH00"))))
    IF (size(trim(cds->activity[d.seq].residence_pct,3)) > 0)
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].residence_pct
    ENDIF
    IF (substring(1,3,cds->activity.main_comm) != substring(1,3,cds->activity[d.seq].primary_recip))
     cds->activity[d.seq].copy_1 = cds->activity.main_comm
    ELSE
     cds->activity[d.seq].copy_2 = cds->activity[d.seq].org_cd_comm
    ENDIF
    IF (substring(1,3,cds->activity[d.seq].org_cd_comm) != substring(1,3,cds->activity[d.seq].copy_1)
    )
     cds->activity[d.seq].copy_2 = cds->activity[d.seq].org_cd_comm
    ENDIF
    cds->activity[d.seq].copy_ind = 1
   ENDIF
   IF ((cds->activity[d.seq].copy_ind=0)
    AND (cds->activity[d.seq].admin_category="02")
    AND  NOT ((cds->activity[d.seq].overseas_status IN ("1", "2", "3", "4"))))
    IF (size(trim(cds->activity[d.seq].residence_pct,3)) > 0)
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].residence_pct
     IF (size(trim(cds->activity[d.seq].gp_pct,3)) > 0
      AND trim(cds->activity[d.seq].gp_pct,3) != trim(cds->activity[d.seq].residence_pct,3))
      cds->activity[d.seq].copy_1 = cds->activity[d.seq].gp_pct
     ELSE
      cds->activity[d.seq].copy_1 = ""
     ENDIF
    ELSEIF (size(trim(cds->activity[d.seq].gp_pct,3)) > 0)
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].gp_pct, cds->activity[d.seq].copy_1 =
     ""
    ELSEIF (size(trim(cds->activity.main_comm,3)) > 0)
     cds->activity[d.seq].primary_recip = cds->activity.main_comm, cds->activity[d.seq].copy_1 = ""
    ENDIF
    cds->activity[d.seq].copy_ind = 1
   ENDIF
   IF ((cds->activity[d.seq].copy_ind=0)
    AND (cds->activity[d.seq].org_cd_comm=ser_num_nscag))
    IF (size(trim(cds->activity[d.seq].residence_pct,3)) > 0
     AND size(trim(cds->activity[d.seq].gp_pct,3)) > 0)
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].residence_pct, cds->activity[d.seq].
     copy_1 = cds->activity[d.seq].gp_pct, cds->activity[d.seq].copy_2 = cds->activity[d.seq].
     org_cd_comm
    ELSEIF (size(trim(cds->activity[d.seq].residence_pct,3)) > 0)
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].residence_pct, cds->activity[d.seq].
     copy_1 = cds->activity[d.seq].org_cd_comm, cds->activity[d.seq].copy_2 = " "
    ELSEIF (size(trim(cds->activity[d.seq].gp_pct,3)) > 0)
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].gp_pct, cds->activity[d.seq].copy_1 =
     cds->activity[d.seq].org_cd_comm, cds->activity[d.seq].copy_2 = " "
    ELSE
     cds->activity[d.seq].primary_recip = cds->activity[d.seq].org_cd_comm, cds->activity[d.seq].
     copy_1 = " ", cds->activity[d.seq].copy_2 = " "
    ENDIF
    cds->activity[d.seq].copy_ind = 1
   ENDIF
   IF ((((cds->activity[d.seq].copy_ind=0)) OR (trim(cds->activity[d.seq].primary_recip,3)=" ")) )
    cds->activity[d.seq].primary_recip = cds->activity.main_comm
   ENDIF
   IF ((cds->activity[d.seq].primary_recip=cds->activity[d.seq].copy_1))
    cds->activity[d.seq].copy_1 = " "
   ENDIF
   IF (trim(cds->activity[d.seq].copy_1,3)=" "
    AND  NOT ((cds->activity[d.seq].copy_2 IN ("VPP00", "TDH00"))))
    cds->activity[d.seq].copy_1 = cds->activity[d.seq].copy_2, cds->activity[d.seq].copy_2 = " "
   ENDIF
   IF (size(trim(cds->activity[d.seq].rulecopy1,3)) > 0)
    IF (substring(1,3,cds->activity[d.seq].rulecopy1) != substring(1,3,cds->activity[d.seq].
     primary_recip)
     AND substring(1,3,cds->activity[d.seq].rulecopy1) != substring(1,3,cds->activity[d.seq].copy_1)
     AND substring(1,3,cds->activity[d.seq].rulecopy1) != substring(1,3,cds->activity[d.seq].copy_2)
     AND substring(1,3,cds->activity[d.seq].rulecopy1) != substring(1,3,cds->activity[d.seq].copy_3)
     AND substring(1,3,cds->activity[d.seq].rulecopy1) != substring(1,3,cds->activity[d.seq].copy_4))
     IF (size(trim(cds->activity[d.seq].copy_1))=0)
      cds->activity[d.seq].copy_1 = build(substring(1,3,cds->activity[d.seq].rulecopy1),"00")
     ELSEIF (size(trim(cds->activity[d.seq].copy_2))=0)
      cds->activity[d.seq].copy_2 = build(substring(1,3,cds->activity[d.seq].rulecopy1),"00")
     ELSEIF (size(trim(cds->activity[d.seq].copy_3))=0)
      cds->activity[d.seq].copy_3 = build(substring(1,3,cds->activity[d.seq].rulecopy1),"00")
     ELSEIF (size(trim(cds->activity[d.seq].copy_4))=0)
      cds->activity[d.seq].copy_4 = build(substring(1,3,cds->activity[d.seq].rulecopy1),"00")
     ENDIF
    ENDIF
   ENDIF
   IF (size(trim(cds->activity[d.seq].rulecopy2,3)) > 0)
    IF (substring(1,3,cds->activity[d.seq].rulecopy2) != substring(1,3,cds->activity[d.seq].
     primary_recip)
     AND substring(1,3,cds->activity[d.seq].rulecopy2) != substring(1,3,cds->activity[d.seq].copy_1)
     AND substring(1,3,cds->activity[d.seq].rulecopy2) != substring(1,3,cds->activity[d.seq].copy_2)
     AND substring(1,3,cds->activity[d.seq].rulecopy2) != substring(1,3,cds->activity[d.seq].copy_3)
     AND substring(1,3,cds->activity[d.seq].rulecopy2) != substring(1,3,cds->activity[d.seq].copy_4))
     IF (size(trim(cds->activity[d.seq].copy_1))=0)
      cds->activity[d.seq].copy_1 = build(substring(1,3,cds->activity[d.seq].rulecopy2),"00")
     ELSEIF (size(trim(cds->activity[d.seq].copy_2))=0)
      cds->activity[d.seq].copy_2 = build(substring(1,3,cds->activity[d.seq].rulecopy2),"00")
     ELSEIF (size(trim(cds->activity[d.seq].copy_3))=0)
      cds->activity[d.seq].copy_3 = build(substring(1,3,cds->activity[d.seq].rulecopy2),"00")
     ELSEIF (size(trim(cds->activity[d.seq].copy_4))=0)
      cds->activity[d.seq].copy_4 = build(substring(1,3,cds->activity[d.seq].rulecopy2),"00")
     ENDIF
    ENDIF
   ENDIF
   IF (size(trim(cds->activity[d.seq].rulecopy3,3)) > 0)
    IF (substring(1,3,cds->activity[d.seq].rulecopy3) != substring(1,3,cds->activity[d.seq].
     primary_recip)
     AND substring(1,3,cds->activity[d.seq].rulecopy3) != substring(1,3,cds->activity[d.seq].copy_1)
     AND substring(1,3,cds->activity[d.seq].rulecopy3) != substring(1,3,cds->activity[d.seq].copy_2)
     AND substring(1,3,cds->activity[d.seq].rulecopy3) != substring(1,3,cds->activity[d.seq].copy_3)
     AND substring(1,3,cds->activity[d.seq].rulecopy3) != substring(1,3,cds->activity[d.seq].copy_4))
     IF (size(trim(cds->activity[d.seq].copy_1))=0)
      cds->activity[d.seq].copy_1 = build(substring(1,3,cds->activity[d.seq].rulecopy3),"00")
     ELSEIF (size(trim(cds->activity[d.seq].copy_2))=0)
      cds->activity[d.seq].copy_2 = build(substring(1,3,cds->activity[d.seq].rulecopy3),"00")
     ELSEIF (size(trim(cds->activity[d.seq].copy_3))=0)
      cds->activity[d.seq].copy_3 = build(substring(1,3,cds->activity[d.seq].rulecopy3),"00")
     ELSEIF (size(trim(cds->activity[d.seq].copy_4))=0)
      cds->activity[d.seq].copy_4 = build(substring(1,3,cds->activity[d.seq].rulecopy3),"00")
     ENDIF
    ENDIF
   ENDIF
   IF (trim(cds->activity[d.seq].unique_cds_id,3)=" ")
    CALL echo("no id"),
    CALL echo("parent"),
    CALL echo(cdsbatch->batch[rcnt].content[d.seq].parent_entity_id),
    CALL echo("unique"),
    CALL echo(cds->activity[d.seq].unique_cds_id)
   ENDIF
  WITH nocounter
 ;end select
 SET last_mod = "159212"
 DECLARE dcl_rename_cmd = vc WITH protect
 DECLARE rename_cmd = vc WITH protect
 DECLARE dcl_size = i4 WITH protect
 DECLARE write_status = i4 WITH protect, noconstant(0)
 SET cdsoutdir_dcl = fillstring(300," ")
 IF (cursys="AIX")
  SET cdsoutdir = fillstring(300," ")
  SET cdsoutdir = concat("/",trim(curnode,3),"/",cnvtlower(trim(cdsbatch->org_code,3)),
   "/nwcs/sending/")
  SET rename_cmd = "mv"
  IF (findfile(cdsoutdir)=0)
   IF (cnvtupper(curnode)="PICK")
    SET cdsoutdir = concat("/cerner/d_svc0502_uk/ccluserdir/",trim(curnode,3),"/",cnvtlower(trim(
       cdsbatch->org_code,3)),"/nwcs/sending/")
   ELSE
    SET cdsoutdir = "CCLUSERDIR:"
    SET cdsoutdir_dcl = "$CCLUSERDIR/"
   ENDIF
  ENDIF
 ELSE
  IF ((cdsbatch->org_code IN ("RQX", "RNH", "5C5")))
   SET cdsoutdir = concat("user01:[cdsfiles.",trim(currdbname,3),".sus]")
  ELSE
   SET cdsoutdir = "user01:[cdsfiles.sus]"
  ENDIF
  SET rename_cmd = "rename"
  IF (findfile(cdsoutdir)=0)
   SET cdsoutdir = "ccluserdir:"
  ENDIF
 ENDIF
 IF (cdsoutdir_dcl != "$CCLUSERDIR/")
  SET cdsoutdir_dcl = trim(cdsoutdir)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(aar_report_seq,nextval)
  FROM dual
  DETAIL
   cds->finished_file = concat(trim(cdsoutdir,3),"CDS_OPA","_",trim(cdsbatch->org_code,3),"_",
    trim(format(nextseqnum,"######################"),3),"_","F","_",trim(cnvtstring(cdsbatch->batch[
      rcnt].cds_batch_id),3),
    "_",trim(format(cnvtdatetime(sysdate),"YYMMDD;;d"),3),".tmp")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  nextseqnum = seq(aar_report_seq,nextval)
  FROM dual
  DETAIL
   cds->unfinished_file = concat(trim(cdsoutdir,3),"CDS_OPW","_",trim(cdsbatch->org_code,3),"_",
    trim(format(nextseqnum,"######################"),3),"_","U","_",trim(cnvtstring(cdsbatch->batch[
      rcnt].cds_batch_id),3),
    "_",trim(format(cnvtdatetime(sysdate),"YYMMDD;;d"),3),".tmp")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  nextseqnum = seq(aar_report_seq,nextval)
  FROM dual
  DETAIL
   cds->exception_file = concat(trim(cdsoutdir,3),"CDS_OPA","_",trim(cdsbatch->org_code,3),"_",
    trim(format(nextseqnum,"######################"),3),"_","E","_",trim(cnvtstring(cdsbatch->batch[
      rcnt].cds_batch_id),3),
    "_",trim(format(cnvtdatetime(sysdate),"YYMMDD;;d"),3),".tmp")
  WITH nocounter
 ;end select
 SET ztotal = size(cds->activity,5)
 IF (size(cds->activity,5) > 0)
  IF ((cdsbatch->batch[rcnt].opwl_batch_ind=0))
   SET sfile = cds->finished_file
  ELSE
   SET sfile = cds->unfinished_file
  ENDIF
  IF ((cdsbatch->file_format="5"))
   SET last_mod = "159212"
   DECLARE emptystring = c1 WITH protect, constant(" ")
   DECLARE orgtypecodedef = c1 WITH protect, constant("B")
   DECLARE diagscheme = c2 WITH protect, constant("02")
   DECLARE procscheme = c2 WITH protect, constant("02")
   DECLARE locationclassdef = c2 WITH protect, constant("01")
   DECLARE otherprocopcs = vc WITH protect
   DECLARE vc1 = vc WITH protect
   DECLARE fillstring = c80 WITH protect, constant(fillstring(80," "))
   DECLARE orgtypecode1 = c1 WITH protect
   DECLARE orgtypecode2 = c1 WITH protect
   DECLARE orgtypecode3 = c1 WITH protect
   DECLARE orgtypecode4 = c1 WITH protect
   DECLARE orgtypecode5 = c1 WITH protect
   DECLARE orgtypecode6 = c1 WITH protect
   DECLARE orgtypecode7 = c1 WITH protect
   DECLARE orgtypecode8 = c1 WITH protect
   DECLARE orgtypecode9 = c1 WITH protect
   DECLARE orgtypecode10 = c1 WITH protect
   DECLARE orgtypecode11 = c1 WITH protect
   DECLARE orgtypecode12 = c1 WITH protect
   DECLARE orgtypecode13 = c1 WITH protect
   DECLARE orgtypecode14 = c1 WITH protect
   DECLARE orgtypecode15 = c1 WITH protect
   DECLARE orgtypecode16 = c1 WITH protect
   DECLARE locationclass = c2 WITH protect
   IF ((cdsbatch->batch[rcnt].opwl_batch_ind=0))
    SET sfile = cds->finished_file
   ELSE
    SET sfile = cds->unfinished_file
   ENDIF
   FOR (ltotal = 1 TO size(cds->activity,5))
     IF (trim(cds->activity[ltotal].alias_status,3)=" ")
      SET cds->activity[ltotal].alias_status = "03"
     ENDIF
     IF (trim(cds->activity[ltotal].pt_post_code,3)=" ")
      SET cds->activity[ltotal].pt_post_code = d_not_known_postcode
     ENDIF
     IF (trim(cds->activity[ltotal].residence_pct,3)=" ")
      SET cds->activity[ltotal].residence_pct = "Q9900"
     ENDIF
     IF (trim(cds->activity[ltotal].consultant_code,3)=" ")
      SET cds->activity[ltotal].consultant_code = "C9999998"
     ENDIF
     IF (trim(cds->activity[ltotal].first_attend,3)=" ")
      SET cds->activity[ltotal].first_attend = "2"
     ENDIF
     IF (trim(cds->activity[ltotal].gp_code,3)=" ")
      SET cds->activity[ltotal].gp_code = "G9999981"
     ENDIF
     IF (trim(cds->activity[ltotal].gp_practice,3)=" ")
      SET cds->activity[ltotal].gp_practice = "V81999"
     ENDIF
     IF (ward=1)
      SET cds->activity[ltotal].priority_type = ""
      SET cds->activity[ltotal].service_type = ""
      SET cds->activity[ltotal].referral_source = ""
      SET cds->activity[ltotal].referral_req_rec_dt_tm = ""
      SET cds->activity[ltotal].referrer_cd = ""
      SET cds->activity[ltotal].referrer_org_cd = ""
      SET cds->activity[ltotal].last_dna_date = ""
     ELSE
      IF (trim(cds->activity[ltotal].referrer_cd,3)=" ")
       SET cds->activity[ltotal].referrer_cd = "X9999998"
      ENDIF
      IF (trim(cds->activity[ltotal].referrer_org_cd,3)=" ")
       SET cds->activity[ltotal].referrer_org_cd = "X99998"
      ENDIF
     ENDIF
     IF ((cds->activity[ltotal].anonymous=1))
      SET cds->activity[ltotal].name_format_ind = ""
      SET cds->activity[ltotal].patient_forename = ""
      SET cds->activity[ltotal].patient_surname = ""
      SET cds->activity[ltotal].pt_address_format_cd = ""
      SET cds->activity[ltotal].pt_address_1 = ""
      SET cds->activity[ltotal].pt_address_2 = ""
      SET cds->activity[ltotal].pt_address_3 = ""
      SET cds->activity[ltotal].pt_address_4 = ""
      SET cds->activity[ltotal].pt_address_5 = ""
     ENDIF
     SET otherprocopcs = concat(substring(1,4,cds->activity[ltotal].opcs4_cd2),substring(1,4,cds->
       activity[ltotal].opcs4_cd3),substring(1,4,cds->activity[ltotal].opcs4_cd4),substring(1,4,cds->
       activity[ltotal].opcs4_cd5),substring(1,4,cds->activity[ltotal].opcs4_cd6),
      substring(1,4,cds->activity[ltotal].opcs4_cd7),substring(1,4,cds->activity[ltotal].opcs4_cd8),
      substring(1,4,cds->activity[ltotal].opcs4_cd9),substring(1,4,cds->activity[ltotal].opcs4_cd10),
      substring(1,4,cds->activity[ltotal].opcs4_cd11),
      substring(1,4,cds->activity[ltotal].opcs4_cd12))
     SET orgtypecode1 = emptystring
     SET orgtypecode2 = emptystring
     SET orgtypecode3 = emptystring
     SET orgtypecode4 = emptystring
     SET orgtypecode5 = emptystring
     SET orgtypecode6 = emptystring
     SET orgtypecode7 = emptystring
     SET orgtypecode8 = emptystring
     SET orgtypecode9 = emptystring
     SET orgtypecode10 = emptystring
     SET orgtypecode11 = emptystring
     SET orgtypecode12 = emptystring
     SET orgtypecode13 = emptystring
     SET orgtypecode14 = emptystring
     SET orgtypecode15 = emptystring
     SET orgtypecode16 = emptystring
     IF (trim(cds->activity[ltotal].sender_identity,3) != " ")
      SET orgtypecode1 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].primary_recip,3) != " ")
      SET orgtypecode2 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].copy_1,3) != " ")
      SET orgtypecode3 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].copy_2,3) != " ")
      SET orgtypecode4 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].copy_3,3) != " ")
      SET orgtypecode5 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].copy_4,3) != " ")
      SET orgtypecode6 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].copy_5,3) != " ")
      SET orgtypecode7 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].copy_6,3) != " ")
      SET orgtypecode8 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].copy_7,3) != " ")
      SET orgtypecode9 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].patient_id_org,3) != " ")
      SET orgtypecode10 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].residence_pct,3) != " ")
      SET orgtypecode11 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].org_cd_prov,3) != " ")
      SET orgtypecode12 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].org_cd_comm,3) != " ")
      SET orgtypecode13 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].treatment_site_cd,3) != " ")
      SET orgtypecode14 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].gp_practice,3) != " ")
      SET orgtypecode15 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].referrer_org_cd,3) != " ")
      SET orgtypecode16 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[ltotal].treatment_site_cd,3) != " ")
      SET locationclass = locationclassdef
     ENDIF
     SELECT INTO value(sfile)
      FROM dummyt d
      PLAN (d)
      DETAIL
       col 0,
       CALL print(trim(cds->activity[ltotal].cds_type,3)), col 3,
       CALL print(trim(cds->activity[ltotal].bulk_repl_cds_gp,3)), col 6,
       CALL print(trim(cds->activity[ltotal].test_ind,3)),
       col 7,
       CALL print(trim(cds->activity[ltotal].protocol_id,3)), col 10,
       CALL print(trim(cds->activity[ltotal].unique_cds_id,3)), col 45,
       CALL print(trim(cds->activity[ltotal].update_type,3)),
       col 46,
       CALL print(format(cds->activity[ltotal].extract_dt_time,"YYYYMMDD;;D")), col 54,
       CALL print(format(cds->activity[ltotal].extract_dt_time,"HHMMSS;;M")), col 60,
       CALL print(format(cds->activity[ltotal].extract_dt_time,"YYYYMMDD;;D")),
       col 68,
       CALL print(format(cds->activity[ltotal].extract_dt_time,"HHMMSS;;M")), col 74,
       CALL print(format(cds->activity[ltotal].period_start_dt,"YYYYMMDD;;D")), col 82,
       CALL print(format(cds->activity[ltotal].period_end_dt,"YYYYMMDD;;D")),
       col 90,
       CALL print(format(cds->activity[ltotal].census_dt,"YYYYMMDD;;D")), col 98,
       CALL print(trim(cds->activity[ltotal].sender_identity,3)), col 103,
       CALL print(trim(orgtypecode1,3)),
       col 104,
       CALL print(trim(cds->activity[ltotal].primary_recip,3)), col 109,
       CALL print(trim(orgtypecode2,3)), col 110,
       CALL print(trim(cds->activity[ltotal].copy_1,3)),
       col 115,
       CALL print(trim(orgtypecode3,3)), col 116,
       CALL print(trim(cds->activity[ltotal].copy_2,3)), col 121,
       CALL print(trim(orgtypecode4,3)),
       col 122,
       CALL print(trim(cds->activity[ltotal].copy_3,3)), col 127,
       CALL print(trim(orgtypecode5,3)), col 128,
       CALL print(trim(cds->activity[ltotal].copy_4,3)),
       col 133,
       CALL print(trim(orgtypecode6,3)), col 134,
       CALL print(trim(cds->activity[ltotal].copy_5,3)), col 139,
       CALL print(trim(orgtypecode7,3)),
       col 140,
       CALL print(trim(cds->activity[ltotal].copy_6,3)), col 145,
       CALL print(trim(orgtypecode8,3)), col 146,
       CALL print(trim(cds->activity[ltotal].copy_7,3)),
       col 151,
       CALL print(trim(orgtypecode9,3)), col 152,
       CALL print(trim(cds->activity[ltotal].local_patient_id,3)), col 162,
       CALL print(trim(cds->activity[ltotal].patient_id_org,3)),
       col 167,
       CALL print(trim(orgtypecode10,3)), col 168,
       CALL print(trim(cds->activity[ltotal].nhs_number,3)), col 178,
       CALL print(format(cds->activity[ltotal].birth_dt,"YYYYMMDD;;D")),
       col 186,
       CALL print(trim(cds->activity[ltotal].carer_support_ind,3)), col 188,
       CALL print(trim(cds->activity[ltotal].alias_status,3)), col 190,
       CALL print(trim(cds->activity[ltotal].sex,3)),
       col 191,
       CALL print(trim(cds->activity[ltotal].name_format_ind,3)), col 192,
       CALL print(trim(cds->activity[ltotal].patient_forename,3)), col 227,
       CALL print(trim(cds->activity[ltotal].patient_surname,3)),
       col 262,
       CALL print(trim(cds->activity[ltotal].pt_address_format_cd,3)), col 263,
       CALL print(trim(cds->activity[ltotal].pt_address_1,3)), col 298,
       CALL print(trim(cds->activity[ltotal].pt_address_2,3)),
       col 333,
       CALL print(trim(cds->activity[ltotal].pt_address_3,3)), col 368,
       CALL print(trim(cds->activity[ltotal].pt_address_4,3)), col 403,
       CALL print(trim(cds->activity[ltotal].pt_address_5,3)),
       col 438,
       CALL print(trim(cds->activity[ltotal].pt_post_code,3)), col 446,
       CALL print(trim(cds->activity[ltotal].residence_pct,3)), col 451,
       CALL print(trim(orgtypecode11,3)),
       col 452,
       CALL print(trim(cds->activity[ltotal].consultant_code,3)), col 460,
       CALL print(trim(cds->activity[ltotal].main_specialty_code,3)), col 463,
       CALL print(trim(cds->activity[ltotal].treatment_function_code,3)),
       col 466,
       CALL print(trim(diagscheme,3)), col 468,
       CALL print(trim(cds->activity[ltotal].primary_icd,3)), col 474,
       CALL print(trim(cds->activity[ltotal].subsidiary_icd,3)),
       col 496,
       CALL print(trim(cds->activity[ltotal].attendance_id,3)), col 508,
       CALL print(trim(cds->activity[ltotal].admin_category,3)), col 510,
       CALL print(trim(cds->activity[ltotal].attended_ind,3)),
       col 511,
       CALL print(trim(cds->activity[ltotal].first_attend,3)), col 512,
       CALL print(trim(cds->activity[ltotal].staff_type,3)), col 514,
       CALL print(trim(cds->activity[ltotal].operation_status_ind,3)),
       col 515,
       CALL print(trim(cds->activity[ltotal].attendance_outcome,3)), col 516,
       CALL print(format(cds->activity[ltotal].attendance_date,"YYYYMMDD;;D")), col 524,
       CALL print(trim(cds->activity[ltotal].comm_ser_nbr,3)),
       col 530,
       CALL print(trim(cds->activity[ltotal].nhs_svc_agr_line_nbr,3)), col 540,
       CALL print(trim(cds->activity[ltotal].prov_ref_nbr,3)), col 557,
       CALL print(trim(cds->activity[ltotal].comm_ref_nbr,3)),
       col 574,
       CALL print(trim(cds->activity[ltotal].org_cd_prov,3)), col 579,
       CALL print(trim(orgtypecode12,3)), col 580,
       CALL print(trim(cds->activity[ltotal].org_cd_comm,3)),
       col 585,
       CALL print(trim(orgtypecode13,3)), col 586,
       CALL print(trim(procscheme,3))
       IF (trim(cds->activity[ltotal].opcs4_cd1,3) != " ")
        col 588,
        CALL print(substring(1,4,cds->activity[ltotal].opcs4_cd1))
       ENDIF
       col 592,
       CALL print(trim(otherprocopcs,3)), col 722,
       CALL print(trim(locationclass,3)), col 724,
       CALL print(trim(cds->activity[ltotal].treatment_site_cd,3)),
       col 729,
       CALL print(trim(orgtypecode14,3)), col 730,
       CALL print(trim(cds->activity[ltotal].gp_code,3)), col 738,
       CALL print(trim(cds->activity[ltotal].gp_practice,3)),
       col 744,
       CALL print(trim(orgtypecode15,3)), col 745,
       CALL print(trim(cds->activity[ltotal].priority_type,3)), col 746,
       CALL print(trim(cds->activity[ltotal].service_type,3)),
       col 747,
       CALL print(trim(cds->activity[ltotal].referral_source,3)), col 749,
       CALL print(format(cds->activity[ltotal].referral_req_rec_dt_tm,"YYYYMMDD;;D")), col 757,
       CALL print(trim(cds->activity[ltotal].referrer_cd,3)),
       col 765,
       CALL print(trim(cds->activity[ltotal].referrer_org_cd,3)), col 771,
       CALL print(trim(orgtypecode16,3)), col 772,
       CALL print(format(cds->activity[ltotal].last_dna_date,"YYYYMMDD;;D")),
       col 780,
       CALL print(trim(cds->activity[ltotal].hrg_code,3)), col 783,
       CALL print(trim(cds->activity[ltotal].hrg_version,3))
       IF (trim(cds->activity[ltotal].local_subspecialty,3) != "")
        col 786,
        CALL print(trim(cds->activity[ltotal].local_subspecialty,3))
       ENDIF
      WITH nocounter, append, format = lfstream,
       format = fixed, maxcol = 792, maxrow = 1,
       formfeed = none
     ;end select
   ENDFOR
  ELSE
   FOR (ltotal = 1 TO size(cds->activity,5))
    SELECT INTO value(sfile)
     ltotal
     FROM (dummyt d  WITH seq = value(1))
     PLAN (d)
     DETAIL
      col 0,
      CALL print(trim(cds->activity[ltotal].version_number,3)), col 6,
      CALL print(trim(cds->activity[ltotal].cds_type,3)), col 09,
      CALL print(trim(cds->activity[ltotal].protocol_id,3)),
      col 12,
      CALL print(trim(cds->activity[ltotal].unique_cds_id,3)), col 47,
      CALL print(trim(cds->activity[ltotal].update_type,3)), col 48,
      CALL print(trim(cds->activity[ltotal].bulk_repl_cds_gp,3)),
      col 51,
      CALL print(trim(cds->activity[ltotal].test_ind,3)), col 52,
      cds->activity[ltotal].extract_dt_time"YYYYMMDDHHMM;;q", col 64, cds->activity[ltotal].
      extract_dt_time"YYYYMMDDHHMM;;q",
      col 76, cds->activity[ltotal].period_start_dt"YYYYMMDD;;d", col 84,
      cds->activity[ltotal].period_end_dt"YYYYMMDD;;d", col 92, cds->activity[ltotal].census_dt
      "YYYYMMDD;;d",
      col 100,
      CALL print(trim(cds->activity[ltotal].sender_identity,3)), col 105,
      CALL print(trim(cds->activity[ltotal].primary_recip,3)), col 110,
      CALL print(trim(cds->activity[ltotal].copy_1,3)),
      col 115,
      CALL print(trim(cds->activity[ltotal].copy_2,3)), col 120,
      CALL print(trim(cds->activity[ltotal].copy_3,3)), col 125,
      CALL print(trim(cds->activity[ltotal].copy_4,3)),
      col 130,
      CALL print(trim(cds->activity[ltotal].copy_5,3)), col 135,
      CALL print(trim(cds->activity[ltotal].copy_6,3)), col 140,
      CALL print(trim(cds->activity[ltotal].copy_7,3)),
      col 145,
      CALL print(trim(cds->activity[ltotal].local_patient_id,3)), col 155,
      CALL print(trim(cds->activity[ltotal].patient_id_org,3)), col 160,
      CALL print(trim(cds->activity[ltotal].nhs_number,3)),
      col 170,
      CALL print(trim(cds->activity[ltotal].old_nhs_number,3)), col 187,
      cds->activity[ltotal].birth_dt"YYYYMMDD;;d", col 195,
      CALL print(trim(cds->activity[ltotal].carer_support_ind,3))
      IF (trim(cds->activity[ltotal].alias_status,3)=" ")
       cds->activity[ltotal].alias_status = "03"
      ENDIF
      col 197,
      CALL print(trim(cds->activity[ltotal].alias_status,3)), col 199,
      CALL print(trim(cds->activity[ltotal].sex,3))
      IF ((cds->activity[ltotal].anonymous != 1))
       col 200,
       CALL print(trim(cds->activity[ltotal].name_format_ind,3)), col 201,
       CALL print(trim(cds->activity[ltotal].patient_forename,3)), col 236,
       CALL print(trim(cds->activity[ltotal].patient_surname,3)),
       col 341,
       CALL print(trim(cds->activity[ltotal].pt_address_format_cd,3)), col 342,
       CALL print(trim(cds->activity[ltotal].pt_address_1,3)), col 377,
       CALL print(trim(cds->activity[ltotal].pt_address_2,3)),
       col 412,
       CALL print(trim(cds->activity[ltotal].pt_address_3,3)), col 447,
       CALL print(trim(cds->activity[ltotal].pt_address_4,3)), col 482,
       CALL print(trim(cds->activity[ltotal].pt_address_5,3))
      ENDIF
      IF (trim(cds->activity[ltotal].pt_post_code,3)=" ")
       cds->activity[ltotal].pt_post_code = d_not_known_postcode
      ENDIF
      col 517,
      CALL print(trim(cds->activity[ltotal].pt_post_code,3)), col 525,
      CALL print(trim(cds->activity[ltotal].pt_sha,3))
      IF (trim(cds->activity[ltotal].consultant_code,3)=" ")
       cds->activity[ltotal].consultant_code = "C9999998"
      ENDIF
      col 528,
      CALL print(trim(cds->activity[ltotal].consultant_code,3)), col 536,
      CALL print(trim(cds->activity[ltotal].main_specialty_code,3)), col 539,
      CALL print(trim(cds->activity[ltotal].treatment_function_code,3))
      IF (trim(cds->activity[ltotal].local_subspecialty,3) != "")
       col 542,
       CALL print(trim(cds->activity[ltotal].local_subspecialty,3))
      ENDIF
      col 547,
      CALL print(trim(cds->activity[ltotal].primary_icd,3)), col 553,
      CALL print(trim(cds->activity[ltotal].subsidiary_icd,3)), col 559,
      CALL print(trim(cds->activity[ltotal].secondary_1,3)),
      col 587,
      CALL print(trim(cds->activity[ltotal].attendance_id,3)), col 599,
      CALL print(trim(cds->activity[ltotal].admin_category,3)), col 601,
      CALL print(trim(cds->activity[ltotal].attended_ind,3))
      IF (trim(cds->activity[ltotal].first_attend,3)=" ")
       cds->activity[ltotal].first_attend = "2"
      ENDIF
      col 602,
      CALL print(trim(cds->activity[ltotal].first_attend,3)), col 603,
      CALL print(trim(cds->activity[ltotal].staff_type,3)), col 605,
      CALL print(trim(cds->activity[ltotal].operation_status_ind,3)),
      col 606,
      CALL print(trim(cds->activity[ltotal].attendance_outcome,3)), col 607,
      cds->activity[ltotal].attendance_date"YYYYMMDD;;d", col 615,
      CALL print(trim(cds->activity[ltotal].comm_ser_nbr,3)),
      col 621,
      CALL print(trim(cds->activity[ltotal].nhs_svc_agr_line_nbr,3)), col 631,
      CALL print(trim(cds->activity[ltotal].prov_ref_nbr,3)), col 648,
      CALL print(trim(cds->activity[ltotal].comm_ref_nbr,3)),
      col 665,
      CALL print(trim(cds->activity[ltotal].org_cd_prov,3)), col 670,
      CALL print(trim(cds->activity[ltotal].org_cd_comm,3)), col 675,
      CALL print(trim(cds->activity[ltotal].opcs4_cd1,3)),
      col 682,
      CALL print(trim(cds->activity[ltotal].opcs4_cd2,3)), col 689,
      CALL print(trim(cds->activity[ltotal].opcs4_cd3,3)), col 696,
      CALL print(trim(cds->activity[ltotal].opcs4_cd4,3)),
      col 703,
      CALL print(trim(cds->activity[ltotal].opcs4_cd5,3)), col 710,
      CALL print(trim(cds->activity[ltotal].opcs4_cd6,3)), col 717,
      CALL print(trim(cds->activity[ltotal].opcs4_cd7,3)),
      col 724,
      CALL print(trim(cds->activity[ltotal].opcs4_cd8,3)), col 731,
      CALL print(trim(cds->activity[ltotal].opcs4_cd9,3)), col 738,
      CALL print(trim(cds->activity[ltotal].opcs4_cd10,3)),
      col 745,
      CALL print(trim(cds->activity[ltotal].opcs4_cd11,3)), col 752,
      CALL print(trim(cds->activity[ltotal].opcs4_cd12,3)), col 844,
      CALL print(trim(cds->activity[ltotal].treatment_site_cd,3))
      IF (ward=1)
       col 849,
       CALL print(trim(cds->activity[ltotal].intensity_intend,3)), col 851,
       CALL print(trim(cds->activity[ltotal].age_group_intend,3)), col 852,
       CALL print(trim(cds->activity[ltotal].sex_of_patients,3))
      ENDIF
      IF (trim(cds->activity[ltotal].gp_code,3)=" ")
       cds->activity[ltotal].gp_code = "G9999981"
      ENDIF
      col 853,
      CALL print(trim(cds->activity[ltotal].gp_code,3)), col 861,
      CALL print(trim(cds->activity[ltotal].gp_practice,3))
      IF (ward != 1)
       col 867,
       CALL print(trim(cds->activity[ltotal].priority_type,3)), col 868,
       CALL print(trim(cds->activity[ltotal].service_type,3)), col 869,
       CALL print(trim(cds->activity[ltotal].referral_source,3)),
       col 871, cds->activity[ltotal].referral_req_rec_dt_tm"YYYYMMDD;;d"
       IF (trim(cds->activity[ltotal].referrer_cd,3)=" ")
        cds->activity[ltotal].referrer_cd = "X9999998"
       ENDIF
       col 879,
       CALL print(trim(cds->activity[ltotal].referrer_cd,3))
       IF (trim(cds->activity[ltotal].referrer_org_cd,3)=" ")
        cds->activity[ltotal].referrer_org_cd = "X99998"
       ENDIF
       col 887,
       CALL print(trim(cds->activity[ltotal].referrer_org_cd,3)), col 893,
       cds->activity[ltotal].last_dna_date"YYYYMMDD;;d"
      ENDIF
      col 901,
      CALL print(trim(cds->activity[ltotal].hrg_code,3)), col 904,
      CALL print(trim(cds->activity[ltotal].hrg_version,3)), col 907,
      CALL print(trim(cds->activity[ltotal].hrg_dgvp_opcs,3)),
      col 911,
      CALL print(trim(cds->activity[ltotal].hrg_dgvp_read,3)), col 918,
      CALL print(trim(cds->activity[ltotal].read_code_ver,3))
      IF (trim(cds->activity[ltotal].residence_pct,3) != " ")
       col 919,
       CALL print(trim(cds->activity[ltotal].residence_pct,3))
      ELSE
       col 919, "Q9900"
      ENDIF
      IF ((cdsbatch->org_code IN ("RQX", "RNH", "5C5")))
       col 924,
       CALL print(trim(cds->activity[ltotal].local_subspecialty,3)), col 930,
       CALL print(cnvtstring(cds->activity[ltotal].person_id)), col 945,
       CALL print(cnvtstring(cds->activity[ltotal].encntr_id)),
       col 960,
       CALL print(cnvtstring(cds->activity[ltotal].pm_wait_list_id)), col 975,
       CALL print(cnvtstring(cds->activity[ltotal].sch_event_id)), col 990,
       CALL print(cnvtstring(cds->activity[ltotal].schedule_id)),
       col 1005, cds->activity[ltotal].removal_dt_tm"YYYYDDMMHHMM;;Q", col 1017,
       cds->activity[ltotal].waiting_end_dt_tm"YYYYDDMMHHMM;;Q", col 1029,
       CALL print(trim(cds->activity[ltotal].appt_type,3)),
       col 1069,
       CALL print(trim(cds->activity[ltotal].appt_location,3)), col 1109,
       CALL print(trim(cds->activity[ltotal].reason_for_change,3)), col 1149,
       CALL print(trim(cds->activity[ltotal].removal_reason,3)),
       col 1189,
       CALL print(trim(cds->activity[ltotal].clinic_name,3)), col 1229,
       CALL print(trim(cds->activity[ltotal].ethnic_group,3)), col 1231,
       CALL print(trim(cds->activity[ltotal].booking_code,3))
       IF (trim(cds->activity[ltotal].booking_code,3)=" ")
        col 1231,
        CALL print("Null booking cd")
       ENDIF
       col 1251,
       CALL print(trim(cds->activity[ltotal].appt_status,3))
       IF (trim(cds->activity[ltotal].appt_status,3)=" ")
        col 1251,
        CALL print("Null appt status")
       ENDIF
       col 1271,
       CALL print(trim(cds->activity[ltotal].fin,3))
      ENDIF
     WITH nocounter, append, format = stream,
      maxcol = 3000, maxrow = 1, formfeed = none
    ;end select
    CALL echo(build2("Record->",trim(cnvtstring(ltotal),3)," of ",trim(cnvtstring(size(cds->activity,
         5)),3)))
   ENDFOR
  ENDIF
  SET stat = findfile(cds->finished_file)
  IF (stat=1)
   SET cds->finished_file = replace(cds->finished_file,cdsoutdir,cdsoutdir_dcl,1)
   SET dcl_rename_cmd = cnvtlower(build2(rename_cmd," ",trim(cds->finished_file)," ",substring(1,(
      textlen(trim(cds->finished_file)) - 3),cds->finished_file),
     "txt"))
   SET dcl_size = textlen(dcl_rename_cmd)
   CALL dcl(dcl_rename_cmd,dcl_size,write_status)
  ENDIF
  SET stat = findfile(cds->unfinished_file)
  IF (stat=1)
   SET cds->unfinished_file = replace(cds->unfinished_file,cdsoutdir,cdsoutdir_dcl,1)
   SET dcl_rename_cmd = cnvtlower(build2(rename_cmd," ",trim(cds->unfinished_file)," ",substring(1,(
      textlen(trim(cds->unfinished_file)) - 3),cds->unfinished_file),
     "txt"))
   SET dcl_size = textlen(dcl_rename_cmd)
   CALL dcl(dcl_rename_cmd,dcl_size,write_status)
  ENDIF
  SET stat = findfile(cds->exception_file)
  IF (stat=1)
   SET cds->exception_file = replace(cds->exception_file,cdsoutdir,cdsoutdir_dcl,1)
   SET dcl_rename_cmd = cnvtlower(build2(rename_cmd," ",trim(cds->exception_file)," ",substring(1,(
      textlen(trim(cds->exception_file)) - 3),cds->exception_file),
     "txt"))
   SET dcl_size = textlen(dcl_rename_cmd)
   CALL dcl(dcl_rename_cmd,dcl_size,write_status)
  ENDIF
  SET cds->finished_file = build(substring(1,(textlen(trim(cds->finished_file)) - 3),cds->
    finished_file),"txt")
  SET cds->unfinished_file = build(substring(1,(textlen(trim(cds->unfinished_file)) - 3),cds->
    unfinished_file),"txt")
  IF ((cdsbatch->batch[rcnt].opwl_batch_ind=0))
   SET cdsbatch->batch[rcnt].filename = replace(cds->finished_file,cdsoutdir,"",1)
  ELSE
   SET cdsbatch->batch[rcnt].filename = replace(cds->unfinished_file,cdsoutdir,"",1)
  ENDIF
  IF (cursys="AIX")
   SET dclcom1 = build2("chmod 777 ",cdsoutdir_dcl,"cds*.txt")
   SET len = size(trim(dclcom1))
   SET status = 0
   CALL dcl(dclcom1,len,status)
  ELSE
   SET dclcom1 = build2("SET FILE/PROTECTION=(S:RWED,O=RWED,G:RWED,W:RWED) ",cdsoutdir_dcl,"cds*.txt"
    )
   SET len = size(trim(dclcom1))
   SET status = 0
   CALL dcl(dclcom1,len,status)
  ENDIF
  CALL echo(dclcom1)
  CALL echo(build("Filename from create->",cdsbatch->batch[rcnt].filename))
  IF ((cdsbatch->testmode=0))
   CALL echo("Batch Table Updates")
   UPDATE  FROM cds_batch_content cbc,
     (dummyt d  WITH seq = value(size(cds->activity,5)))
    SET cbc.cds_batch_id = cdsbatch->batch[rcnt].cds_batch_id, cbc.updt_dt_tm = cnvtdatetime(sysdate),
     cbc.activity_dt_tm = cnvtdatetime(cds->activity[d.seq].point_dt_tm)
    PLAN (d)
     JOIN (cbc
     WHERE (cbc.cds_batch_content_id=cds->activity[d.seq].cds_batch_content_id))
    WITH nocounter, maxcommit = 100
   ;end update
   COMMIT
   UPDATE  FROM cds_batch_content_hist cbch,
     (dummyt d  WITH seq = value(size(cds->activity,5)))
    SET cbch.cds_batch_id = cdsbatch->batch[rcnt].cds_batch_id, cbch.updt_dt_tm = cnvtdatetime(
      sysdate), cbch.activity_dt_tm = cnvtdatetime(cds->activity[d.seq].point_dt_tm)
    PLAN (d)
     JOIN (cbch
     WHERE (cbch.cds_batch_content_id=cds->activity[d.seq].cds_batch_content_id)
      AND cbch.cds_batch_id=0)
    WITH nocounter, maxcommit = 100
   ;end update
   COMMIT
  ENDIF
 ENDIF
 FREE RECORD cds
END GO
