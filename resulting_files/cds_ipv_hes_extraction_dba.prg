CREATE PROGRAM cds_ipv_hes_extraction:dba
 SET last_mod = "161102"
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
       3 parent_entity_id = f8
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
 DECLARE abs_period_end_date = q8 WITH public, noconstant
 DECLARE birth_date_only = q8 WITH public, noconstant
 DECLARE long_text_len = i4 WITH public, constant(255)
 SET daily = 1
 SET last_mod = "161102"
 DECLARE trust_rel_code = f8 WITH public, noconstant(uar_get_code_by("MEANING",369,"NHSTRUSTCHLD"))
 DECLARE medservice_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",19189,"SERVICE"))
 DECLARE nhs_report_code = f8 WITH public, noconstant(uar_get_code_by("MEANING",73,"NHS_REPORT"))
 DECLARE ni4_report_code = f8 WITH public, noconstant(uar_get_code_by("DISPLAY",73,"Newham Indigo4"))
 DECLARE hi4_report_code = f8 WITH public, noconstant(uar_get_code_by("DISPLAY",73,"Homerton Indigo4"
   ))
 DECLARE org_alias_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",334,"NHSORGALIAS"))
 DECLARE nhs_serial_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",334,"NHSSERIALNUM"))
 DECLARE unknown_svc = f8 WITH public, noconstant(uar_get_code_by("DISPLAY",3394,"Unknown"))
 DECLARE cnn_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE visit_nbr = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"VISITID"))
 DECLARE fin_nbr = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE nhs_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE augmentedcare = f8 WITH public, noconstant(uar_get_code_by("MEANING",17649,"AUGMENTCARE"))
 DECLARE pla_loc_class_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",17649,
   "LOCATIONCLASS"))
 DECLARE pla_loc_type_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",17649,
   "LOCATIONTYPE"))
 DECLARE encntr_alt_care_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",17649,
   "ENCNTRALTERNATELEVELOFCARE"))
 DECLARE ce_slice_type = f8 WITH public, noconstant(uar_get_code_by("MEANING",401571,"CONSULT_EP"))
 DECLARE referdoc = f8 WITH public, noconstant(uar_get_code_by("MEANING",333,"REFERDOC"))
 DECLARE consultant_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE gp_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE pcp_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE antenatal_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",331,"ANTENATALDOC"))
 DECLARE doccnbr = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"DOCCNBR"))
 DECLARE nongp = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"NONGP"))
 DECLARE external_id = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"EXTERNALID"))
 DECLARE gdp = f8 WITH public, constant(uar_get_code_by("MEANING",320,"GDP"))
 DECLARE inpt_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAY",69,"Inpatient"))
 DECLARE mother_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",40,"MOTHER"))
 DECLARE primary_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAY",12034,"Primary"))
 DECLARE home_addr_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE commissioner_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",352,"COMMISSIONER"))
 DECLARE active_status_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",48,"ACTIVE"))
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
 DECLARE mhinpatient_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MHINPATIENT")
  )
 DECLARE psych_op_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "PSYCHIATRICOUTPATIENT"))
 DECLARE appt_confirmed = f8 WITH public, noconstant(uar_get_code_by("MEANING",14233,"CONFIRMED"))
 DECLARE appt_hold = f8 WITH public, noconstant(uar_get_code_by("MEANING",14233,"HOLD"))
 DECLARE appt_resched = f8 WITH public, noconstant(uar_get_code_by("MEANING",14233,"RESCHEDULED"))
 DECLARE nhs_trace = f8 WITH public, noconstant(uar_get_code_by("MEANING",30700,"NHS_TRACE"))
 DECLARE patient = f8 WITH public, noconstant(uar_get_code_by("MEANING",12450,"PATIENT"))
 DECLARE first_ant_asst_dt_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "1STANTENATALASSESSMENTDATE"))
 DECLARE anes_during_labour_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "ANAESTHESIADURINGLABOUR"))
 DECLARE anes_post_labour_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "ANAESTHESIAPOSTLABOUR"))
 DECLARE baby_delivered_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "BABYDELIVERED"))
 DECLARE del_dt_tm_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,"DELIVERYDATETIME")
  )
 DECLARE delivery_person_status_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "DELIVERYPERSONSTATUS"))
 DECLARE del_place_chg_reas_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "DELIVERYPLACECHANGEREASON"))
 DECLARE gest_at_birth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "GESTATIONATBIRTH"))
 DECLARE gest_at_birth_weeks_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "GESTATIONATBIRTHWEEKS"))
 DECLARE int_del_loc_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "INTENDEDDELIVERYLOCATION"))
 DECLARE method_of_delivery_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "METHODOFDELIVERY"))
 DECLARE num_babies_at_birth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "NUMBEROFBABIESATBIRTH"))
 DECLARE num_prev_pregnancy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "NUMBEROFPREVIOUSPREGNANCIES"))
 DECLARE onset_of_labour_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "ONSETOFLABOUR"))
 DECLARE resus_details_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",72,
   "RESUSCITATIONDETAILS"))
 DECLARE gest_days_newb_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",72,
   "Gestation Days Newborn Calculation"))
 DECLARE ei_subtype_pas_lsb_cd = f8 WITH public, constant(uar_get_code_by("MEANING",356,"PASLSB"))
 DECLARE ei_subtype_pas_adlt_cd = f8 WITH public, constant(uar_get_code_by("MEANING",356,"PASADLT"))
 DECLARE ei_subtype_pas_bn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",356,"PASBN"))
 DECLARE ei_subtype_pas_gllo_cd = f8 WITH public, constant(uar_get_code_by("MEANING",356,"PASGLLO"))
 DECLARE ei_subtype_pas_sca_cd = f8 WITH public, constant(uar_get_code_by("MEANING",356,"PASSCA"))
 DECLARE ei_subtype_perukres_cd = f8 WITH public, constant(uar_get_code_by("MEANING",356,
   "PERSONUKRES"))
 DECLARE ei_subtype_fittoleave_cd = f8 WITH public, constant(uar_get_code_by("MEANING",356,
   "FITTOLEAVE"))
 DECLARE ei_subtype_comment_cd = f8 WITH public, constant(uar_get_code_by("MEANING",355,"COMMENT"))
 DECLARE ppr_family_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",351,"FAMILY"))
 DECLARE eer_newborn_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",385571,"NEWBORN"))
 DECLARE ce_in_error_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE ce_in_error_noview_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE ce_in_error_nomut_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE ce_cancelled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"CANCELLED"))
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
 SET last_mod = "161102"
 FREE RECORD cds
 RECORD cds(
   1 finished_file = c400
   1 unfinished_file = c400
   1 exception_file = c400
   1 main_comm = c5
   1 activity[*]
     2 new_comm_ind = i4
     2 admin_category_cd = f8
     2 overseas_status = c1
     2 comm_org_id = f8
     2 age_activity = i4
     2 gp_ind = i4
     2 copy_ind = i4
     2 rulecopy1 = c5
     2 rulecopy2 = c5
     2 rulecopy3 = c5
     2 calc_comm = c5
     2 newh_mum_baby = i4
     2 outfile = c50
     2 active_ind = i4
     2 encntr_id = f8
     2 encntr_slice_id = f8
     2 pm_wait_list_id = f8
     2 nhs_consultant_episode_id = f8
     2 point_dt_tm = dq8
     2 cds_batch_content_id = f8
     2 person_id = f8
     2 prev_error = i4
     2 con_epi_num = i4
     2 epis_in_spell = i4
     2 svc_id = f8
     2 epr_id = f8
     2 consultant_id = f8
     2 organization_id = f8
     2 epr_dt = dq8
     2 elh_id = f8
     2 elh_dt = dq8
     2 encntr_type = f8
     2 gp_sha = c3
     2 pt_sha = c3
     2 anonymous = i4
     2 main_comm = c5
     2 cost_comm = c5
     2 acc_cd = f8
     2 deceased_dt_tm = dq8
     2 organ_donor_cd = f8
     2 episode_id = vc
     2 service_category_cd = f8
     2 med_service_cd = f8
     2 maternity_delivery_flag = i2
     2 birth_flag = i2
     2 birth_spell_flag = i2
     2 error_flag = i4
     2 error_string = c100
     2 cds_type_cd = f8
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
     2 birth_dt = dq8
     2 carer_support_ind = c2
     2 legal_classification = c2
     2 ethnic_group = c2
     2 marital_status = c1
     2 alias_status = c2
     2 sex = c1
     2 legal_class_on_cen_dt = c2
     2 legal_class_on_adm = c2
     2 date_detention_commenced = dq8
     2 age_census = c3
     2 dur_of_care_psych_cen_dt = c4
     2 dur_detention = c4
     2 mental_category = c2
     2 psych_cen_pat_status = c1
     2 det_long_term_psych_cen_dt = dq8
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
     2 previous_pregs_nbr = c2
     2 birth_weight = c4
     2 live_still_birth_ind = c1
     2 spell_number = c27
     2 admin_category = c2
     2 adm_method = c2
     2 disch_dest = c2
     2 disch_method = c1
     2 pt_class = c1
     2 adm_source = c2
     2 adm_date = dq8
     2 disch_date = dq8
     2 disch_prsnl_id = f8
     2 episode_ct = c2
     2 first_adm_ind = c1
     2 last_episode_ind = c1
     2 neonatal_care_lvl = c1
     2 operation_status_ind = c1
     2 psych_status_ind = c1
     2 care_periods_ct = c2
     2 episode_start_dt = dq8
     2 episode_end_dt = dq8
     2 comm_ser_nbr = c6
     2 nhs_svc_agr_line_nbr = c10
     2 prov_ref_nbr = c17
     2 comm_ref_nbr = c17
     2 org_cd_prov = c5
     2 org_cd_comm = c5
     2 consultant_code = c8
     2 main_specialty_code = c3
     2 treatment_function_code = c3
     2 attend
       3 arrival_mode_cd = f8
       3 arrival_mode = c1
       3 arrival_mode_meaning = vc
     2 primary_icd = c6
     2 subsidiary_icd = c6
     2 icd_cd1 = c6
     2 icd_cd2 = c6
     2 icd_cd3 = c6
     2 icd_cd4 = c6
     2 icd_cd5 = c6
     2 icd_cd6 = c6
     2 icd_cd7 = c6
     2 icd_cd8 = c6
     2 icd_cd9 = c6
     2 icd_cd10 = c6
     2 icd_cd11 = c6
     2 icd_cd12 = c6
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
     2 opcs4_date1 = dq8
     2 opcs4_date2 = dq8
     2 opcs4_date3 = dq8
     2 opcs4_date4 = dq8
     2 opcs4_date5 = dq8
     2 opcs4_date6 = dq8
     2 opcs4_date7 = dq8
     2 opcs4_date8 = dq8
     2 opcs4_date9 = dq8
     2 opcs4_date10 = dq8
     2 opcs4_date11 = dq8
     2 opcs4_date12 = dq8
     2 start_site_cd = c5
     2 start_age_group_intend = c1
     2 start_intensity_intend = c2
     2 start_sex_of_patients = c1
     2 start_ward_night_avail = c1
     2 start_ward_day_avail = c1
     2 start_loc_nurse_unit = vc
     2 ward_stay_details[*]
       3 treatment_site_cd = c5
       3 age_group_intend = c1
       3 intensity_intend = c2
       3 sex_of_patients = c1
       3 ward_night_avail = c1
       3 ward_day_avail = c1
       3 ward_start_date = dq8
       3 ward_end_date = dq8
       3 loc_bed_cd = f8
       3 loc_nurse_unit = vc
       3 loc_nurse_unit_cd = f8
       3 ward_stay_seq = i4
     2 end_site_cd = c5
     2 end_age_group_intend = c1
     2 end_intensity_intend = c2
     2 end_sex_of_patients = c1
     2 end_ward_night_avail = c1
     2 end_ward_day_avail = c1
     2 end_loc_nurse_unit = vc
     2 gp_code = c8
     2 gp_practice = c6
     2 gp_pct = c5
     2 referrer_cd = c8
     2 referrer_org_cd = c6
     2 referral_src = c2
     2 intend_management = c1
     2 decision_admit_date = dq8
     2 hrg_code = c3
     2 hrg_version = c3
     2 hrg_dgvp_opcs = c4
     2 hrg_dgvp_read = c7
     2 read_code_ver = c1
     2 augmented_care_details[*]
       3 local_id = c17
       3 care_period_disp = c2
       3 care_period_num = c2
       3 care_period_source = c2
       3 planned_ind = c1
       3 outcome_ind = c2
       3 intensive_care_days = c4
       3 high_dep_level_days = c4
       3 num_organs_supp = c2
       3 aug_start_date = dq8
       3 aug_end_date = dq8
       3 aug_spec_fun_cd = c3
       3 aug_care_loc = c2
       3 aug_care_loc_class = c2
     2 number_of_babies = c1
     2 first_antenatal_dt = dq8
     2 antenatal_gp_cd = c8
     2 antenatal_gp_prac_cd = c6
     2 del_place_type = c1
     2 del_place_chg_reas = c1
     2 anes_during_del = c1
     2 anes_post_del = c1
     2 gest_len = c2
     2 labor_onset_meth = c1
     2 delivery_date = dq8
     2 baby_details[*]
       3 baby_birth_order = c1
       3 baby_del_method = c1
       3 baby_gest_length = c2
       3 baby_resus_meth = c1
       3 baby_pers_cond_stat = c1
       3 baby_del_place_type = c1
       3 baby_loc_pat_id = c10
       3 baby_org_cd = c6
       3 baby_nhs_num = c17
       3 baby_nhs_stat = c2
       3 baby_birth_date = dq8
       3 baby_birth_wt = c4
       3 baby_live_still = c1
       3 baby_sex = c1
     2 mom_local_pat_id = c10
     2 mom_org_cd = c6
     2 mom_nhs_new = c10
     2 mom_nhs_status = c2
     2 mom_birth_date = dq8
     2 mom_address_cd = c1
     2 mom_address_1 = c35
     2 mom_address_2 = c35
     2 mom_address_3 = c35
     2 mom_address_4 = c35
     2 mom_address_5 = c35
     2 mom_post_cd = c8
     2 mom_pct = c6
     2 local_subspecialty = c5
     2 wait_duration = c4
     2 rtt
       3 episode_id = f8
       3 pathway_id = c20
       3 pathway_org = c5
       3 status = c2
       3 form_event_id = f8
     2 deceased_dt_tm = dq8
     2 suspension_reason = c100
     2 activity_dt_tm = dq8
     2 fin_nbr = c12
     2 orig_request_rcvd_dt_tm = dq8
     2 schedule_id = f8
     2 contributor_system_cd = f8
     2 consultant_person_id = f8
     2 reg_prsnl_id = f8
     2 est_depart_dt_tm = dq8
     2 encntr_active_ind = i2
     2 encntr_create_dt_tm = dq8
     2 encntr_create_prsnl_id = f8
     2 encntr_updt_dt_tm = dq8
     2 encntr_updt_id = f8
     2 pre_reg_dt_tm = dq8
     2 pre_reg_prsnl_id = f8
     2 admit_type_cd = f8
     2 admit_src_cd = f8
     2 loc_facility_cd = f8
     2 fin_nbr_format = vc
     2 fin_nbr_alias_pool_cd = f8
     2 disch_disposition_cd = f8
     2 disch_loc_cd = f8
     2 est_complete_dt_tm = dq8
     2 uk_resident_cd = f8
     2 fit_to_leave_dt_tm = dq8
     2 encntr_comments = vc
 )
 DECLARE formattolength(c1,p2) = c258
 DECLARE formataccession(c2) = c11
 DECLARE str_find = c255 WITH public
 DECLARE str_replace = c40 WITH public
 DECLARE str_printable_flag = i2 WITH public, noconstant(0)
 SUBROUTINE (makestringprintable(string=vc) =vc)
  IF (str_printable_flag=0)
   FOR (i = 1 TO 255)
    SET str_find = notrim(concat(str_find,char(i)))
    IF (((i < 32) OR (i IN (124, 127, 129, 141, 143,
    144, 157, 160))) )
     SET str_replace = notrim(concat(str_replace," "))
    ELSE
     SET str_replace = notrim(concat(str_replace,char(i)))
    ENDIF
   ENDFOR
  ENDIF
  RETURN(replace(string,str_find,str_replace,3))
 END ;Subroutine
 SUBROUTINE formattolength(m_string,m_length)
   SET return_string = fillstring(value(m_length)," ")
   IF (size(m_string,1) > m_length)
    SET return_string = concat(substring(1,(m_length - 3),m_string),"...")
   ELSE
    SET return_string = m_string
   ENDIF
   RETURN(return_string)
 END ;Subroutine
 SUBROUTINE formataccession(acc_string)
   SET return_string = fillstring(25," ")
   SET return_string = uar_fmt_accession(acc_string,size(acc_string,1))
   RETURN(return_string)
 END ;Subroutine
 SUBROUTINE (word_wrap(comment_text=vc,num=i4) =c32000)
   SET mysize = 0
   SET startpos = 0
   SET endpos = 0
   SET curpos = 0
   SET numchars = 0
   SET crchar = concat(char(13),char(10))
   SET comments = fillstring(32000," ")
   SET comments = replace(comment_text,crchar," ",0)
   SET comments = replace(comments,char(10)," ",0)
   SET mysize = size(trim(comments))
   SET text_line = fillstring(500," ")
   SET startpos = 1
   SET endpos = num
   SET done = "F"
   SET j = 0
   SET new_pos = 0
   WHILE (done="F")
     SET endpos = minval(mysize,(startpos+ num))
     SET numchars = minval(num,((mysize - startpos)+ 1))
     SET j += 1
     SET stat = alterlist(wrap->ww_comment,j)
     SET wrap->ww_comment[j].text_line = substring(startpos,numchars,comments)
     SET doneit = "F"
     SET curpos = numchars
     SET new_pos = findstring(char(10),wrap->ww_comment[j].text_line)
     WHILE (doneit="F"
      AND endpos <= mysize)
      IF (endpos=mysize)
       SET curpos += 1
      ENDIF
      IF (((substring(curpos,1,wrap->ww_comment[j].text_line) IN (" ", ",", ":", ".", ";",
      "/", " '*' ", "-", "!", "@",
      "#", "$", "%", "^", "&",
      "(", ")", "_", "+", "=",
      "<", ">", "[", "{", "]",
      "}", "|", "\", " '?' ", "/")) OR (curpos=0)) )
       SET doneit = "T"
       IF (curpos=0)
        SET numchars = num
       ELSE
        SET numchars = curpos
       ENDIF
       SET wrap->ww_comment[j].text_line = substring(startpos,numchars,comments)
      ELSE
       SET curpos -= 1
      ENDIF
     ENDWHILE
     SET startpos += numchars
     IF (startpos > mysize)
      SET done = "T"
     ENDIF
   ENDWHILE
 END ;Subroutine
 SET stat = alterlist(cds->activity,size(cdsbatch->batch[rcnt].content,5))
 IF (size(cds->activity,5) > 0)
  SELECT INTO "nl:"
   sex = pm_get_cvo_alias(p.sex_cd,nhs_report_code), admin_category = evaluate(e.accommodation_cd,0.0,
    pm_get_cvo_alias(pwl.admit_category_cd,nhs_report_code),pm_get_cvo_alias(e.accommodation_cd,
     nhs_report_code)), admin_category_cd = evaluate(e.accommodation_cd,0.0,pwl.admit_category_cd,e
    .accommodation_cd),
   carer_support_ind = pm_get_cvo_alias(pp.living_dependency_cd,nhs_report_code), alias_status =
   pm_get_cvo_alias(pa.person_alias_status_cd,nhs_report_code), ethnic_group = pm_get_cvo_alias(p
    .ethnic_grp_cd,nhs_report_code),
   marital_type = pm_get_cvo_alias(p.marital_type_cd,nhs_report_code), legal_status =
   pm_get_cvo_alias(e.mental_health_cd,nhs_report_code), admit_type = evaluate(e.admit_type_cd,0.0,
    pm_get_cvo_alias(pwl.admit_type_cd,nhs_report_code),pm_get_cvo_alias(e.admit_type_cd,
     nhs_report_code)),
   disch_dispo = pm_get_cvo_alias(e.disch_disposition_cd,nhs_report_code), patient_class =
   pm_get_cvo_alias(e.patient_classification_cd,nhs_report_code), admit_source = pm_get_cvo_alias(e
    .admit_src_cd,nhs_report_code),
   disch_location = pm_get_cvo_alias(e.disch_to_loctn_cd,nhs_report_code), management_code =
   pm_get_cvo_alias(pwl.management_cd,nhs_report_code), referral_src = pm_get_cvo_alias(pwl
    .referral_source_cd,nhs_report_code),
   refer_fac = pm_get_cvo_alias(e.refer_facility_cd,nhs_report_code), arrival_mode = pm_get_cvo_alias
   (eacc.ambulance_arrive_cd,nhs_report_code), arrival_mode_meaning = uar_get_code_meaning(eacc
    .ambulance_arrive_cd)
   FROM (dummyt d  WITH seq = value(size(cdsbatch->batch[rcnt].content,5))),
    encntr_slice es,
    encounter e,
    person p,
    person_patient pp,
    organization_alias oa,
    person_alias pa,
    encntr_alias ea,
    pm_wait_list pwl,
    encntr_org_reltn eor,
    encntr_accident eacc,
    eem_benefit_alloc eba,
    dummyt d2
   PLAN (d)
    JOIN (es
    WHERE (es.encntr_slice_id=cdsbatch->batch[rcnt].content[d.seq].parent_entity_id))
    JOIN (e
    WHERE e.encntr_id=es.encntr_id)
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (pp
    WHERE (pp.person_id= Outerjoin(p.person_id)) )
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(p.person_id))
     AND (pa.person_alias_type_cd= Outerjoin(nhs_cd))
     AND (pa.active_ind= Outerjoin(1))
     AND (pa.active_status_cd= Outerjoin(active_status_cd)) )
    JOIN (pwl
    WHERE (pwl.encntr_id= Outerjoin(e.encntr_id)) )
    JOIN (eor
    WHERE (eor.encntr_id= Outerjoin(e.encntr_id))
     AND (eor.encntr_org_reltn_cd= Outerjoin(commissioner_cd))
     AND (eor.active_ind= Outerjoin(1)) )
    JOIN (oa
    WHERE (oa.organization_id= Outerjoin(eor.organization_id))
     AND (oa.org_alias_type_cd= Outerjoin(org_alias_cd)) )
    JOIN (eba
    WHERE (eba.encntr_id= Outerjoin(es.encntr_id))
     AND (eba.encntr_slice_id= Outerjoin(es.encntr_slice_id)) )
    JOIN (eacc
    WHERE (eacc.encntr_id= Outerjoin(e.encntr_id)) )
    JOIN (d2)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ((ea.encntr_alias_type_cd+ 0) IN (cnn_cd, fin_nbr))
     AND ea.active_ind=1)
   HEAD d.seq
    row + 0
   DETAIL
    IF (datetimecmp(es.end_effective_dt_tm,cnvtdatetime("31-DEC-2100")) != 0)
     cds->activity[d.seq].point_dt_tm = es.end_effective_dt_tm
    ELSE
     cds->activity[d.seq].point_dt_tm = cnvtdatetime(sysdate)
    ENDIF
    cds->activity[d.seq].version_number = "NHS003", cds->activity[d.seq].comm_ref_nbr = "8", cds->
    activity[d.seq].extract_dt_time = cnvtdatetime(sysdate),
    cds->activity[d.seq].update_type = cnvtstring(cdsbatch->batch[rcnt].content[d.seq].
     update_del_flag), cds->activity[d.seq].sender_identity = build(cnvtupper(cdsbatch->org_code),
     "00"), cds->activity[d.seq].org_cd_prov = build(cnvtupper(cdsbatch->org_code),"00"),
    cds->activity[d.seq].patient_id_org = build(cnvtupper(cdsbatch->org_code),"00"), cds->activity[d
    .seq].unique_cds_id = build("B",substring(1,3,cnvtupper(cdsbatch->org_code)),"00",cnvtstring(
      cdsbatch->batch[rcnt].content[d.seq].cds_batch_content_id)), cds->activity[d.seq].encntr_id =
    es.encntr_id,
    cds->activity[d.seq].person_id = e.person_id, cds->activity[d.seq].pm_wait_list_id = pwl
    .pm_wait_list_id, cds->activity[d.seq].nhs_consultant_episode_id = es.encntr_slice_id,
    cds->activity[d.seq].cds_batch_content_id = cdsbatch->batch[rcnt].content[d.seq].
    cds_batch_content_id, cds->activity[d.seq].episode_id = cnvtstring(es.encntr_slice_id), cds->
    activity[d.seq].encntr_type = e.encntr_type_cd,
    cds->activity[d.seq].rtt.pathway_org = refer_fac, cds->activity[d.seq].period_start_dt = cdsbatch
    ->batch[rcnt].cds_batch_start_dt, cds->activity[d.seq].period_end_dt = cdsbatch->batch[rcnt].
    cds_batch_end_dt
    IF (validate(psycds->census,0)=1)
     cds->activity[d.seq].cds_type_cd = cds_170, cds->activity[d.seq].census_dt = cnvtdatetime(
      curdate,curtime), cds->activity[d.seq].bulk_repl_cds_gp = "050",
     cds->activity[d.seq].protocol_id = "020"
    ELSE
     IF (datetimecmp(es.end_effective_dt_tm,cnvtdatetime("31-DEC-2100")) != 0)
      cds->activity[d.seq].cds_type_cd = cds_130
     ELSE
      cds->activity[d.seq].cds_type_cd = cds_190
     ENDIF
     cds->activity[d.seq].protocol_id = "010"
    ENDIF
    IF (datetimecmp(es.end_effective_dt_tm,cnvtdatetime("31-DEC-2100"))=0)
     cds->activity[d.seq].episode_end_dt = 0
    ELSE
     cds->activity[d.seq].episode_end_dt = es.end_effective_dt_tm
    ENDIF
    cds->activity[d.seq].cds_type = uar_get_code_meaning(cds->activity[d.seq].cds_type_cd), cds->
    activity[d.seq].episode_start_dt = es.beg_effective_dt_tm, cds->activity[d.seq].adm_date = e
    .reg_dt_tm,
    cds->activity[d.seq].disch_date = e.disch_dt_tm, cds->activity[d.seq].deceased_dt_tm = p
    .deceased_dt_tm
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].operation_status_ind = "8"
    ELSE
     cds->activity[d.seq].operation_status_ind = "9"
    ENDIF
    IF (e.disch_dt_tm=es.end_effective_dt_tm)
     cds->activity[d.seq].last_episode_ind = "1"
    ELSE
     cds->activity[d.seq].last_episode_ind = "2"
    ENDIF
    cds->activity[d.seq].organ_donor_cd = pp.organ_donor_cd, cds->activity[d.seq].birth_dt = p
    .birth_dt_tm, cds->activity[d.seq].age_activity = (datetimediff(cds->activity[d.seq].point_dt_tm,
     cds->activity[d.seq].birth_dt)/ 365)
    IF (e.admit_src_cd=0
     AND (cds->activity[d.seq].encntr_type=newborn_type))
     cds->activity[d.seq].adm_source = "79"
    ENDIF
    IF ((cds->activity[d.seq].encntr_type != newborn_type))
     cds->activity[d.seq].neonatal_care_lvl = "8"
    ENDIF
    cds->activity[d.seq].acc_cd = e.accommodation_cd
    IF (p.ethnic_grp_cd > 0)
     cds->activity[d.seq].ethnic_group = ethnic_group
    ELSE
     cds->activity[d.seq].ethnic_group = "99"
    ENDIF
    IF (p.marital_type_cd > 0
     AND (cds->activity[d.seq].encntr_type IN (psych_ip_type, mentalhealth_type, mhinpatient_type)))
     cds->activity[d.seq].marital_status = marital_type
    ELSE
     cds->activity[d.seq].marital_status = "8"
    ENDIF
    IF (p.sex_cd > 0)
     cds->activity[d.seq].sex = sex
    ENDIF
    cds->activity[d.seq].admin_category = admin_category, cds->activity[d.seq].admin_category_cd =
    admin_category_cd
    IF (e.admit_type_cd > 0)
     cds->activity[d.seq].adm_method = admit_type, cds->activity[d.seq].admit_type_cd = e
     .admit_type_cd
    ENDIF
    IF (e.disch_to_loctn_cd > 0)
     cds->activity[d.seq].disch_dest = disch_location
    ENDIF
    IF (e.disch_disposition_cd > 0)
     cds->activity[d.seq].disch_method = disch_dispo
    ENDIF
    IF (e.patient_classification_cd > 0)
     cds->activity[d.seq].pt_class = patient_class
    ENDIF
    IF (pp.living_dependency_cd > 0)
     cds->activity[d.seq].carer_support_ind = carer_support_ind
    ENDIF
    IF (pwl.referral_source_cd > 0)
     cds->activity[d.seq].referral_src = referral_src
    ENDIF
    IF (e.admit_src_cd > 0)
     cds->activity[d.seq].adm_source = admit_source, cds->activity[d.seq].admit_src_cd = e
     .admit_src_cd
    ENDIF
    IF (trim(pa.alias) != " ")
     cds->activity[d.seq].nhs_number = pa.alias
     IF ((cdsbatch->anonymous=1))
      cds->activity[d.seq].anonymous = 1
     ENDIF
    ENDIF
    IF (trim(alias_status,3) != " ")
     cds->activity[d.seq].alias_status = alias_status
    ELSE
     cds->activity[d.seq].alias_status = "03"
    ENDIF
    IF (ea.encntr_alias_type_cd=cnn_cd)
     cds->activity[d.seq].local_patient_id = cnvtalias(ea.alias,ea.alias_pool_cd)
    ENDIF
    IF (ea.encntr_alias_type_cd=fin_nbr)
     cds->activity[d.seq].spell_number = ea.alias, cds->activity[d.seq].fin_nbr = ea.alias, cds->
     activity[d.seq].fin_nbr_format = cnvtalias(ea.alias,ea.alias_pool_cd),
     cds->activity[d.seq].fin_nbr_alias_pool_cd = ea.alias_pool_cd
    ENDIF
    IF (pwl.admit_decision_dt_tm > 0)
     cds->activity[d.seq].decision_admit_date = pwl.admit_decision_dt_tm
    ELSE
     cds->activity[d.seq].decision_admit_date = pwl.waiting_start_dt_tm
    ENDIF
    IF (trim(pwl.commissioner_reference,3) != " ")
     cds->activity[d.seq].comm_ref_nbr = pwl.commissioner_reference
    ELSE
     cds->activity[d.seq].comm_ref_nbr = "8"
    ENDIF
    IF (trim(oa.alias,3) != " ")
     cds->activity[d.seq].org_cd_comm = build(oa.alias,"00")
    ENDIF
    IF (eba.eem_benefit_id > 0)
     cds->activity[d.seq].nhs_svc_agr_line_nbr = cnvtstring(eba.eem_benefit_id)
    ENDIF
    cds->activity[d.seq].patient_forename = cnvtupper(p.name_first), cds->activity[d.seq].
    patient_surname = cnvtupper(p.name_last), cds->activity[d.seq].name_format_ind = "1"
    IF ((cds->activity[d.seq].encntr_type IN (psych_ip_type, mentalhealth_type, mhinpatient_type)))
     abs_period_end_date = cnvtdatetime(cnvtdate(cds->activity[d.seq].period_end_dt),0),
     birth_date_only = cnvtdatetime(cnvtdate(cds->activity[d.seq].birth_dt),0), reg_date =
     cnvtdatetime(cnvtdate(e.reg_dt_tm),0),
     cds->activity[d.seq].age_census = cnvtstring((datetimecmp(abs_period_end_date,birth_date_only)/
      365)), cds->activity[d.seq].dur_of_care_psych_cen_dt = cnvtstring(datetimecmp(
       abs_period_end_date,reg_date))
     IF (cnvtint(cds->activity[d.seq].dur_of_care_psych_cen_dt) < 0)
      cds->activity[d.seq].dur_of_care_psych_cen_dt = "0"
     ENDIF
     cds->activity[d.seq].det_long_term_psych_cen_dt = cnvtdatetime(curdate,0)
    ENDIF
    IF (trim(cds->activity[d.seq].admin_category,3)=" ")
     cds->activity[d.seq].admin_category = "99"
    ENDIF
    IF (trim(cds->activity[d.seq].adm_method,3)=" ")
     cds->activity[d.seq].adm_method = "99"
    ENDIF
    IF ((cds->activity[d.seq].adm_method IN ("11", "12", "13")))
     cds->activity[d.seq].wait_duration = format(cnvtstring(ceil((datetimediff(pwl.waiting_end_dt_tm,
         pwl.adj_waiting_start_dt_tm) - pwl.suspended_days))),"####;P0")
     IF (ceil((datetimediff(pwl.waiting_end_dt_tm,pwl.adj_waiting_start_dt_tm) - pwl.suspended_days))
      < 0)
      cds->activity[d.seq].wait_duration = "0000"
     ENDIF
    ELSE
     cds->activity[d.seq].wait_duration = "9998"
    ENDIF
    IF (pwl.management_cd > 0
     AND (cds->activity[d.seq].adm_method IN ("11", "12", "13")))
     cds->activity[d.seq].intend_management = management_code
    ELSE
     cds->activity[d.seq].intend_management = "8"
    ENDIF
    IF (findstring("-",cds->activity[d.seq].wait_duration,1,1) > 0)
     cds->activity[d.seq].wait_duration = "0000"
    ENDIF
    IF (eacc.ambulance_arrive_cd > 0)
     cds->activity[d.seq].attend.arrival_mode = arrival_mode, cds->activity[d.seq].attend.
     arrival_mode_cd = eacc.ambulance_arrive_cd, cds->activity[d.seq].attend.arrival_mode_meaning =
     arrival_mode_meaning
    ENDIF
    cds->activity[d.seq].organization_id = e.organization_id, cds->activity[d.seq].encntr_slice_id =
    es.encntr_slice_id, cds->activity[d.seq].contributor_system_cd = e.contributor_system_cd
    IF (e.reg_prsnl_id > 0.0)
     cds->activity[d.seq].reg_prsnl_id = e.reg_prsnl_id
    ENDIF
    IF (cnvtdatetime(e.est_depart_dt_tm) > 0)
     cds->activity[d.seq].est_depart_dt_tm = e.est_depart_dt_tm
    ENDIF
    cds->activity[d.seq].active_ind = e.active_ind, cds->activity[d.seq].encntr_active_ind = e
    .active_ind
    IF (cnvtdatetime(e.create_dt_tm) > 0)
     cds->activity[d.seq].encntr_create_dt_tm = e.create_dt_tm
    ENDIF
    IF (e.create_prsnl_id > 0.0)
     cds->activity[d.seq].encntr_create_prsnl_id = e.create_prsnl_id
    ENDIF
    IF (cnvtdatetime(e.updt_dt_tm) > 0)
     cds->activity[d.seq].encntr_updt_dt_tm = e.updt_dt_tm
    ENDIF
    cds->activity[d.seq].encntr_updt_id = e.updt_id
    IF (cnvtdatetime(e.pre_reg_dt_tm) > 0)
     cds->activity[d.seq].pre_reg_dt_tm = e.pre_reg_dt_tm
    ENDIF
    cds->activity[d.seq].pre_reg_prsnl_id = e.pre_reg_prsnl_id
    IF (e.loc_facility_cd > 0.0)
     cds->activity[d.seq].loc_facility_cd = e.loc_facility_cd
    ENDIF
   WITH counter, outerjoin = d2
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
    encntr_prsnl_reltn epr
   PLAN (d)
    JOIN (epr
    WHERE (epr.encntr_id=cds->activity[d.seq].encntr_id)
     AND ((epr.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
     AND ((epr.end_effective_dt_tm+ 0) > cnvtdatetime(sysdate))
     AND epr.active_ind=1)
   DETAIL
    IF (cnvtdatetime(cds->activity[d.seq].disch_date) > 0)
     cds->activity[d.seq].disch_prsnl_id = epr.prsnl_person_id
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   overseas_status = pm_get_cvo_alias(ei.info_sub_type_cd,nhs_report_code)
   FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
    encntr_info ei
   PLAN (d)
    JOIN (ei
    WHERE (ei.encntr_id=cds->activity[d.seq].encntr_id)
     AND ei.info_sub_type_cd IN (overseascd, ei_subtype_fittoleave_cd)
     AND ((ei.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
     AND ((ei.end_effective_dt_tm+ 0) > cnvtdatetime(sysdate))
     AND ei.active_ind=1)
   DETAIL
    CASE (ei.info_sub_type_cd)
     OF overseascd:
      cds->activity[d.seq].overseas_status = overseas_status
     OF ei_subtype_fittoleave_cd:
      cds->activity[d.seq].fit_to_leave_dt_tm = ei.value_dt_tm
    ENDCASE
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
    person_info pi
   PLAN (d)
    JOIN (pi
    WHERE (pi.person_id=cds->activity[d.seq].person_id)
     AND pi.info_sub_type_cd=ei_subtype_perukres_cd
     AND ((pi.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
     AND ((pi.end_effective_dt_tm+ 0) > cnvtdatetime(sysdate))
     AND pi.active_ind=1)
   DETAIL
    cds->activity[d.seq].uk_resident_cd = pi.value_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
    encntr_info ei,
    long_text lt
   PLAN (d)
    JOIN (ei
    WHERE (ei.encntr_id=cds->activity[d.seq].encntr_id)
     AND ei.info_type_cd=ei_subtype_comment_cd
     AND ((ei.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
     AND ((ei.end_effective_dt_tm+ 0) > cnvtdatetime(sysdate))
     AND ei.active_ind=1)
    JOIN (lt
    WHERE lt.parent_entity_id=ei.encntr_info_id
     AND lt.parent_entity_name="ENCNTR_INFO")
   DETAIL
    IF (trim(lt.long_text,3) != " ")
     cds->activity[d.seq].encntr_comments = formattolength(lt.long_text,long_text_len)
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
    encntr_pending ep
   PLAN (d)
    JOIN (ep
    WHERE (ep.encntr_id=cds->activity[d.seq].encntr_id)
     AND ep.active_ind=1)
   DETAIL
    IF (ep.disch_disposition_cd > 0.0)
     cds->activity[d.seq].disch_disposition_cd = ep.disch_disposition_cd
    ENDIF
    IF (ep.disch_to_loctn_cd > 0.0)
     cds->activity[d.seq].disch_loc_cd = ep.disch_to_loctn_cd
    ENDIF
    IF (cnvtdatetime(ep.est_complete_dt_tm) > 0)
     cds->activity[d.seq].est_complete_dt_tm = ep.est_complete_dt_tm
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   main_specialty_code = pm_get_cvo_alias(elh.service_category_cd,nhs_report_code),
   treatment_function_code = pm_get_cvo_alias(elh.med_service_cd,nhs_report_code), local_subspecialty
    = pm_get_cvo_alias(elh.med_service_cd,local->specialty_code)
   FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
    encntr_slice es,
    encntr_loc_hist elh
   PLAN (d)
    JOIN (es
    WHERE (es.encntr_slice_id=cds->activity[d.seq].nhs_consultant_episode_id))
    JOIN (elh
    WHERE elh.encntr_id=es.encntr_id
     AND elh.beg_effective_dt_tm < es.end_effective_dt_tm
     AND elh.end_effective_dt_tm >= es.end_effective_dt_tm
     AND elh.med_service_cd > 0
     AND (((cds->activity[d.seq].update_type="1")) OR ((cds->activity[d.seq].update_type="9")
     AND elh.active_ind=1)) )
   DETAIL
    index = d.seq, cds->activity[index].service_category_cd = elh.service_category_cd, cds->activity[
    index].med_service_cd = elh.med_service_cd
    IF (elh.med_service_cd > 0)
     cds->activity[index].treatment_function_code = treatment_function_code, cds->activity[index].
     local_subspecialty = local_subspecialty
    ENDIF
    IF (elh.service_category_cd > 0)
     cds->activity[index].main_specialty_code = main_specialty_code
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (checkdic("T2754_CONSULTANT_EPISODE","T",0) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
    t2754_consultant_episode t
   PLAN (d)
    JOIN (t
    WHERE (t.encntr_id=cds->activity[d.seq].encntr_id)
     AND ((t.encntr_slice_id+ 0)=cds->activity[d.seq].nhs_consultant_episode_id))
   DETAIL
    cds->activity[d.seq].episode_id = cnvtstring(t.nhs_consultant_episode_id)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cdsbatch->batch[rcnt].content,5))),
   encntr_slice es
  PLAN (d)
   JOIN (es
   WHERE (es.encntr_id=cds->activity[d.seq].encntr_id)
    AND es.encntr_slice_type_cd=ce_slice_type
    AND es.active_ind=1)
  ORDER BY d.seq, es.beg_effective_dt_tm
  HEAD d.seq
   cnt = 0
  HEAD es.beg_effective_dt_tm
   cnt += 1
   IF ((es.encntr_slice_id=cds->activity[d.seq].nhs_consultant_episode_id))
    cds->activity[d.seq].con_epi_num = cnt, cds->activity[d.seq].episode_ct = format(cnt,"##;P0")
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Getting day and night attender status")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cdsbatch->batch[rcnt].content,5))),
   encntr_alias ea,
   encounter e
  PLAN (d
   WHERE (cds->activity[d.seq].encntr_type IN (reg_day_type, reg_night_type)))
   JOIN (ea
   WHERE (ea.alias=cds->activity[d.seq].spell_number)
    AND ea.encntr_alias_type_cd=fin_nbr
    AND ea.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id
    AND e.encntr_type_cd IN (reg_day_type, reg_night_type))
  ORDER BY d.seq, e.reg_dt_tm, 0
  HEAD e.reg_dt_tm
   IF ((e.encntr_id=cds->activity[d.seq].encntr_id))
    cds->activity[d.seq].first_adm_ind = "0"
   ELSE
    cds->activity[d.seq].first_adm_ind = "1"
   ENDIF
  WITH nocounter
 ;end select
 IF (size(cds->activity,5)=0)
  GO TO exit_script
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
 DECLARE legal_admsn_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",356,"LS_ON_ADMSN"))
 DECLARE legal_stat1_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",356,"LEGAL_STAT1"))
 DECLARE legal_stat2_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",356,"LEGAL_STAT2"))
 DECLARE legal_stat1_dt_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",356,"LS_START_1"))
 DECLARE legal_stat2_dt_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",356,"LS_START2"))
 DECLARE legal_exp1_dt_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",356,"LS_EXPIRY_1"))
 DECLARE legal_exp2_dt_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",356,"LS_EXPIRY_2"))
 DECLARE legal_stat_dt_1 = q8 WITH protect
 DECLARE legal_stat_dt_2 = q8 WITH protect
 DECLARE legal_exp_dt_1 = q8 WITH protect
 DECLARE legal_exp_dt_2 = q8 WITH protect
 DECLARE ment_cat1_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",356,"MENTCAT_1"))
 DECLARE ment_cat2_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",356,"MENTCAT_2"))
 DECLARE det_commence_abs_date = q8 WITH public, noconstant
 DECLARE period_end_date = q8 WITH public, noconstant
 CALL echo("Getting Patient's Current Psych Information")
 SELECT INTO "nl:"
  person_id = cds->activity[d.seq].person_id, value_alias = pm_get_cvo_alias(pud.value_cd,
   nhs_report_code), value_dt = pud.value_dt_tm
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   pm_user_defined pud
  PLAN (d
   WHERE (cds->activity[d.seq].encntr_type IN (psych_ip_type, mentalhealth_type, mhinpatient_type)))
   JOIN (pud
   WHERE (pud.parent_entity_id=cds->activity[d.seq].person_id)
    AND pud.parent_entity_name="PERSON"
    AND pud.udf_type_cd IN (legal_stat1_cd, legal_stat1_dt_cd, legal_exp1_dt_cd, legal_stat2_cd,
   legal_stat2_dt_cd,
   legal_exp2_dt_cd, ment_cat1_cd, ment_cat2_cd)
    AND pud.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND pud.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    AND pud.active_ind=1)
  ORDER BY d.seq, pud.udf_type_cd, pud.beg_effective_dt_tm DESC
  HEAD d.seq
   row + 0, legal_status_1 = fillstring(2," "), legal_status_2 = fillstring(2," "),
   ment_cat_1 = fillstring(2," "), ment_cat_2 = fillstring(2," ")
  DETAIL
   CALL echo("in detail"),
   CALL echo(uar_get_code_display(pud.udf_type_cd))
   CASE (pud.udf_type_cd)
    OF legal_stat1_cd:
     legal_status_1 = value_alias
    OF legal_stat2_cd:
     legal_status_2 = value_alias
    OF legal_stat1_dt_cd:
     legal_stat_dt_1 = pud.value_dt_tm
    OF legal_stat2_dt_cd:
     legal_stat_dt_2 = pud.value_dt_tm
    OF legal_exp1_dt_cd:
     legal_exp_dt_1 = pud.value_dt_tm
    OF legal_exp2_dt_cd:
     legal_exp_dt_2 = pud.value_dt_tm
    OF ment_cat1_cd:
     ment_cat_1 = value_alias
    OF ment_cat2_cd:
     ment_cat_2 = value_alias
   ENDCASE
   CALL echo(value_alias),
   CALL echo(pud.value_dt_tm)
  FOOT  d.seq
   IF (textlen(trim(legal_status_1,3)) > 0
    AND legal_exp_dt_1 >= cnvtdatetime(cds->activity[d.seq].period_end_dt))
    cds->activity[d.seq].legal_class_on_cen_dt = legal_status_1, cds->activity[d.seq].
    date_detention_commenced = legal_stat_dt_1
   ELSEIF (textlen(trim(legal_status_2,3)) > 0
    AND legal_exp_dt_2 >= cnvtdatetime(cds->activity[d.seq].period_end_dt))
    cds->activity[d.seq].legal_class_on_cen_dt = legal_status_2, cds->activity[d.seq].
    date_detention_commenced = legal_stat_dt_2
   ENDIF
   IF ((cds->activity[d.seq].date_detention_commenced > 0))
    det_commence_abs_date = cnvtdatetime(cnvtdate(cds->activity[d.seq].date_detention_commenced),0),
    period_end_date = cnvtdatetime(cnvtdate(cds->activity[d.seq].period_end_dt),0), cds->activity[d
    .seq].dur_detention = cnvtstring(datetimecmp(period_end_date,det_commence_abs_date))
   ENDIF
   IF (textlen(trim(ment_cat_1,3)) > 0)
    cds->activity[d.seq].mental_category = ment_cat_1
   ELSE
    cds->activity[d.seq].mental_category = ment_cat_2
   ENDIF
   CALL echo("test category"),
   CALL echo(ment_cat_1),
   CALL echo(ment_cat_2)
   IF ((cds->activity[d.seq].legal_class_on_cen_dt IN ("01", "33", "35", "36")))
    cds->activity[d.seq].psych_cen_pat_status = "2"
   ELSE
    IF (cnvtint(cds->activity[d.seq].dur_of_care_psych_cen_dt) > 365)
     cds->activity[d.seq].psych_cen_pat_status = "3"
    ELSE
     cds->activity[d.seq].psych_cen_pat_status = "1"
    ENDIF
   ENDIF
   IF (textlen(trim(cds->activity[d.seq].legal_class_on_cen_dt,3)) > 0)
    cds->activity[d.seq].legal_classification = cds->activity[d.seq].legal_class_on_cen_dt
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Getting Patient's Psych Information on admission")
 SELECT INTO "nl:"
  encntr_id = cds->activity[d.seq].encntr_id, value_alias = pm_get_cvo_alias(pud.value_cd,
   nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   pm_user_defined pud
  PLAN (d
   WHERE (cds->activity[d.seq].encntr_type IN (psych_ip_type, mentalhealth_type, mhinpatient_type)))
   JOIN (pud
   WHERE (pud.parent_entity_id=cds->activity[d.seq].encntr_id)
    AND pud.parent_entity_name="ENCOUNTER"
    AND pud.udf_type_cd=legal_admsn_cd
    AND pud.active_ind=1)
  ORDER BY d.seq
  DETAIL
   cds->activity[d.seq].legal_class_on_adm = value_alias
  WITH nocounter
 ;end select
 SET last_mod = "161102"
 CALL echo("Getting Ward Stay Info")
 DECLARE ws_slice_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",401571,"WARDSTAYS"))
 DECLARE age_group_int_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",17649,
   "AGEGROUPINTENDED"))
 DECLARE clin_care_int_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",17649,
   "CLINICALCAREINTENSITY"))
 DECLARE sex_of_pats_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",17649,"SEXOFPATIENTS"
   ))
 DECLARE treatment_site_cd = f8 WITH public, constant(uar_get_code_by("MEANING",17649,"TREATSITECD"))
 DECLARE augmented_care_cd = f8 WITH public, constant(uar_get_code_by("MEANING",17649,"AUGMENTCARE"))
 DECLARE location_class_cd = f8 WITH public, constant(uar_get_code_by("MEANING",17649,"LOCCLAS"))
 DECLARE night_avail_cd = f8 WITH public, constant(uar_get_code_by("MEANING",17649,"NIGHTAVAIL"))
 DECLARE day_avail_cd = f8 WITH public, constant(uar_get_code_by("MEANING",17649,"DAYAVAIL"))
 SELECT INTO "nl:"
  pla_value = pm_get_cvo_alias(pla.value_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encntr_loc_hist elh,
   encntr_slice es,
   pm_loc_attrib pla
  PLAN (d)
   JOIN (es
   WHERE (es.encntr_id=cds->activity[d.seq].encntr_id)
    AND es.encntr_slice_type_cd=ws_slice_type
    AND es.end_effective_dt_tm > cnvtdatetime(cds->activity[d.seq].episode_start_dt)
    AND ((es.end_effective_dt_tm <= cnvtdatetime(cds->activity[d.seq].episode_end_dt)) OR ((cds->
   activity[d.seq].episode_end_dt=0)))
    AND es.active_ind=1)
   JOIN (elh
   WHERE (elh.encntr_id=cds->activity[d.seq].encntr_id)
    AND elh.loc_nurse_unit_cd > 0
    AND elh.beg_effective_dt_tm < elh.end_effective_dt_tm
    AND es.end_effective_dt_tm > elh.beg_effective_dt_tm
    AND es.end_effective_dt_tm <= elh.end_effective_dt_tm
    AND elh.active_ind=1)
   JOIN (pla
   WHERE (pla.location_cd= Outerjoin(elh.loc_nurse_unit_cd)) )
  ORDER BY d.seq, es.beg_effective_dt_tm, 0
  HEAD d.seq
   cnt = 0, stopper = 0, ward_stay = 0,
   last_bed = 0.0, last_room = 0.0, last_nurse = 0.0,
   all_after_disch = 1.0
  HEAD es.beg_effective_dt_tm
   cnt += 1, stat = alterlist(cds->activity[d.seq].ward_stay_details,cnt)
  DETAIL
   IF (cnt=1)
    IF (pla.attrib_type_cd=treatment_site_cd)
     cds->activity[d.seq].start_site_cd = pla.value_string
    ENDIF
    IF (pla.attrib_type_cd=age_group_int_cd)
     cds->activity[d.seq].start_age_group_intend = pla_value
    ENDIF
    IF (pla.attrib_type_cd=clin_care_int_cd)
     cds->activity[d.seq].start_intensity_intend = pla_value
    ENDIF
    IF (pla.attrib_type_cd=sex_of_pats_cd)
     cds->activity[d.seq].start_sex_of_patients = pla_value
    ENDIF
    IF (pla.attrib_type_cd=night_avail_cd)
     cds->activity[d.seq].start_ward_night_avail = pla_value
    ENDIF
    IF (pla.attrib_type_cd=day_avail_cd)
     cds->activity[d.seq].start_ward_day_avail = pla_value
    ENDIF
    cds->activity[d.seq].start_loc_nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd)
   ENDIF
   IF (cnt > 0)
    IF (pla.attrib_type_cd=treatment_site_cd)
     cds->activity[d.seq].ward_stay_details[cnt].treatment_site_cd = pla.value_string
    ENDIF
    IF (pla.attrib_type_cd=age_group_int_cd)
     cds->activity[d.seq].ward_stay_details[cnt].age_group_intend = pla_value
    ENDIF
    IF (pla.attrib_type_cd=clin_care_int_cd)
     cds->activity[d.seq].ward_stay_details[cnt].intensity_intend = pla_value
    ENDIF
    IF (pla.attrib_type_cd=sex_of_pats_cd)
     cds->activity[d.seq].ward_stay_details[cnt].sex_of_patients = pla_value
    ENDIF
    IF (pla.attrib_type_cd=night_avail_cd)
     cds->activity[d.seq].ward_stay_details[cnt].ward_night_avail = pla_value
    ENDIF
    IF (pla.attrib_type_cd=day_avail_cd)
     cds->activity[d.seq].ward_stay_details[cnt].ward_day_avail = pla_value
    ENDIF
    cds->activity[d.seq].ward_stay_details[cnt].ward_start_date = es.beg_effective_dt_tm
    IF (datetimecmp(es.end_effective_dt_tm,cnvtdatetime("31-DEC-2100")) != 0)
     cds->activity[d.seq].ward_stay_details[cnt].ward_end_date = es.end_effective_dt_tm
    ENDIF
    cds->activity[d.seq].ward_stay_details[cnt].loc_nurse_unit = uar_get_code_display(elh
     .loc_nurse_unit_cd), cds->activity[d.seq].ward_stay_details[cnt].loc_nurse_unit_cd = elh
    .loc_nurse_unit_cd, cds->activity[d.seq].ward_stay_details[cnt].loc_bed_cd = elh.loc_bed_cd,
    cds->activity[d.seq].ward_stay_details[cnt].ward_stay_seq = cnt
   ENDIF
  FOOT  d.seq
   IF ((cds->activity[d.seq].episode_end_dt > 0))
    cds->activity[d.seq].ward_stay_details[cnt].ward_end_date = cds->activity[d.seq].episode_end_dt,
    cds->activity[d.seq].end_site_cd = cds->activity[d.seq].ward_stay_details[cnt].treatment_site_cd,
    cds->activity[d.seq].end_age_group_intend = cds->activity[d.seq].ward_stay_details[cnt].
    age_group_intend,
    cds->activity[d.seq].end_intensity_intend = cds->activity[d.seq].ward_stay_details[cnt].
    intensity_intend, cds->activity[d.seq].end_sex_of_patients = cds->activity[d.seq].
    ward_stay_details[cnt].sex_of_patients, cds->activity[d.seq].end_ward_night_avail = cds->
    activity[d.seq].ward_stay_details[cnt].ward_night_avail,
    cds->activity[d.seq].end_ward_day_avail = cds->activity[d.seq].ward_stay_details[cnt].
    ward_day_avail, cds->activity[d.seq].end_loc_nurse_unit = uar_get_code_display(elh
     .loc_nurse_unit_cd)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("getting mental status info")
 SELECT INTO "nl:"
  legal_status = pm_get_cvo_alias(efh.mental_health_cd,nhs_report_code), mental_category =
  pm_get_cvo_alias(efh.mental_category_cd,nhs_report_code), psych_status = pm_get_cvo_alias(efh
   .psychiatric_status_cd,nhs_report_code),
  admin_category_efh = pm_get_cvo_alias(efh.accommodation_cd,nhs_report_code), admin_category_elh =
  pm_get_cvo_alias(elh.accommodation_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encntr_flex_hist efh,
   encntr_loc_hist elh
  PLAN (d)
   JOIN (efh
   WHERE (efh.encntr_id= Outerjoin(cds->activity[d.seq].encntr_id))
    AND (efh.transaction_dt_tm<= Outerjoin(cnvtdatetime(cds->activity[d.seq].point_dt_tm)))
    AND (efh.active_ind= Outerjoin(1)) )
   JOIN (elh
   WHERE (elh.encntr_id= Outerjoin(cds->activity[d.seq].encntr_id))
    AND (elh.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(cds->activity[d.seq].point_dt_tm)))
    AND (elh.end_effective_dt_tm>= Outerjoin(cnvtdatetime(cds->activity[d.seq].point_dt_tm)))
    AND (elh.active_ind= Outerjoin(1)) )
  ORDER BY d.seq, efh.activity_dt_tm DESC
  HEAD d.seq
   IF (textlen(trim(cds->activity[d.seq].mental_category,3))=0)
    IF (efh.mental_category_cd > 0.00
     AND (cds->activity[d.seq].encntr_type IN (psych_ip_type, mentalhealth_type, mhinpatient_type)))
     cds->activity[d.seq].mental_category = mental_category
    ENDIF
   ENDIF
   IF (textlen(trim(cds->activity[d.seq].psych_status_ind,3))=0)
    IF (efh.psychiatric_status_cd > 0.00
     AND (cds->activity[d.seq].encntr_type IN (psych_ip_type, mentalhealth_type, mhinpatient_type)))
     cds->activity[d.seq].psych_status_ind = psych_status
    ENDIF
   ENDIF
   IF (elh.accommodation_cd > 0)
    cds->activity[d.seq].admin_category = admin_category_elh, cds->activity[d.seq].admin_category_cd
     = elh.accommodation_cd
   ELSEIF (efh.accommodation_cd > 0)
    cds->activity[d.seq].admin_category = admin_category_efh, cds->activity[d.seq].admin_category_cd
     = efh.accommodation_cd
   ENDIF
  FOOT  d.seq
   IF (textlen(trim(cds->activity[d.seq].legal_classification,3))=0)
    IF (efh.mental_health_cd > 0
     AND (cds->activity[d.seq].encntr_type IN (psych_ip_type, mentalhealth_type, mhinpatient_type)))
     cds->activity[d.seq].legal_classification = legal_status
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Getting OPCS4 info")
 DECLARE opcs4_source_voc_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",400,"OPCS4"))
 DECLARE proc_principle_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",401,
   "PROCEDURE"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   procedure proc,
   nomenclature nm
  PLAN (d)
   JOIN (proc
   WHERE (proc.encntr_id=cds->activity[d.seq].encntr_id)
    AND ((proc.encntr_slice_id+ 0)=cds->activity[d.seq].nhs_consultant_episode_id)
    AND proc.active_ind=1)
   JOIN (nm
   WHERE nm.nomenclature_id=proc.nomenclature_id
    AND nm.principle_type_cd=proc_principle_type_cd
    AND nm.source_vocabulary_cd=opcs4_source_voc_cd
    AND nm.active_ind=1)
  DETAIL
   source_id = replace(nm.source_identifier,".","",0)
   IF (trim(source_id,3) IN ("Q13", "Q383")
    AND (cdsbatch->anonymous=1))
    cds->activity[d.seq].anonymous = 1
   ENDIF
   IF (proc.dgvp_ind=1)
    cds->activity[d.seq].hrg_dgvp_opcs = source_id
   ENDIF
   IF (proc.proc_priority=1)
    cds->activity[d.seq].opcs4_cd1 = source_id, cds->activity[d.seq].opcs4_date1 = proc.proc_dt_tm,
    cds->activity[d.seq].operation_status_ind = "1"
   ENDIF
   IF (proc.proc_priority=2)
    cds->activity[d.seq].opcs4_cd2 = source_id, cds->activity[d.seq].opcs4_date2 = proc.proc_dt_tm
   ENDIF
   IF (proc.proc_priority=3)
    cds->activity[d.seq].opcs4_cd3 = source_id, cds->activity[d.seq].opcs4_date3 = proc.proc_dt_tm
   ENDIF
   IF (proc.proc_priority=4)
    cds->activity[d.seq].opcs4_cd4 = source_id, cds->activity[d.seq].opcs4_date4 = proc.proc_dt_tm
   ENDIF
   IF (proc.proc_priority=5)
    cds->activity[d.seq].opcs4_cd5 = source_id, cds->activity[d.seq].opcs4_date5 = proc.proc_dt_tm
   ENDIF
   IF (proc.proc_priority=6)
    cds->activity[d.seq].opcs4_cd6 = source_id, cds->activity[d.seq].opcs4_date6 = proc.proc_dt_tm
   ENDIF
   IF (proc.proc_priority=7)
    cds->activity[d.seq].opcs4_cd7 = source_id, cds->activity[d.seq].opcs4_date7 = proc.proc_dt_tm
   ENDIF
   IF (proc.proc_priority=8)
    cds->activity[d.seq].opcs4_cd8 = source_id, cds->activity[d.seq].opcs4_date8 = proc.proc_dt_tm
   ENDIF
   IF (proc.proc_priority=9)
    cds->activity[d.seq].opcs4_cd9 = source_id, cds->activity[d.seq].opcs4_date9 = proc.proc_dt_tm
   ENDIF
   IF (proc.proc_priority=10)
    cds->activity[d.seq].opcs4_cd10 = source_id, cds->activity[d.seq].opcs4_date10 = proc.proc_dt_tm
   ENDIF
   IF (proc.proc_priority=11)
    cds->activity[d.seq].opcs4_cd11 = source_id, cds->activity[d.seq].opcs4_date11 = proc.proc_dt_tm
   ENDIF
   IF (proc.proc_priority=12)
    cds->activity[d.seq].opcs4_cd12 = source_id, cds->activity[d.seq].opcs4_date12 = proc.proc_dt_tm
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
    AND ((diag.encntr_slice_id+ 0)=cds->activity[d.seq].nhs_consultant_episode_id)
    AND diag.diag_priority > 0
    AND diag.active_ind=1)
   JOIN (nm
   WHERE nm.nomenclature_id=diag.nomenclature_id
    AND nm.principle_type_cd=diag_principle_type_cd
    AND nm.source_vocabulary_cd IN (diag_source_voc_cd, diag_source_voc_cd1)
    AND nm.active_ind=1)
  ORDER BY d.seq, diag.diag_priority, diag.beg_effective_dt_tm,
   0
  HEAD d.seq
   diagcnt = 0
  DETAIL
   diagcnt += 1, source_id = replace(nm.source_identifier,".","",0)
   IF (size(trim(nm.source_identifier))=3)
    source_id = build(trim(source_id),"X")
   ENDIF
   IF (trim(source_id,3) IN ("Z311", "Z312", "Z313", "Z318")
    AND (cdsbatch->anonymous=1))
    cds->activity[d.seq].anonymous = 1
   ENDIF
   IF (diag.diag_priority=1)
    cds->activity[d.seq].primary_icd = source_id
   ELSEIF (diag.diag_priority=2)
    cds->activity[d.seq].icd_cd1 = source_id
   ELSEIF (diag.diag_priority=3)
    cds->activity[d.seq].icd_cd2 = source_id
   ELSEIF (diag.diag_priority=4)
    cds->activity[d.seq].icd_cd3 = source_id
   ELSEIF (diag.diag_priority=5)
    cds->activity[d.seq].icd_cd4 = source_id
   ELSEIF (diag.diag_priority=6)
    cds->activity[d.seq].icd_cd5 = source_id
   ELSEIF (diag.diag_priority=7)
    cds->activity[d.seq].icd_cd6 = source_id
   ELSEIF (diag.diag_priority=8)
    cds->activity[d.seq].icd_cd7 = source_id
   ELSEIF (diag.diag_priority=9)
    cds->activity[d.seq].icd_cd8 = source_id
   ELSEIF (diag.diag_priority=10)
    cds->activity[d.seq].icd_cd9 = source_id
   ELSEIF (diag.diag_priority=11)
    cds->activity[d.seq].icd_cd10 = source_id
   ELSEIF (diag.diag_priority=12)
    cds->activity[d.seq].icd_cd11 = source_id
   ELSEIF (diag.diag_priority=13)
    cds->activity[d.seq].icd_cd12 = source_id
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
   WHERE (hrg.encntr_id=cds->activity[d.seq].encntr_id)
    AND ((hrg.encntr_slice_id+ 0)=cds->activity[d.seq].nhs_consultant_episode_id)
    AND hrg.active_ind=1)
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
 CALL echo("Getting Augmented Care Details")
 SELECT INTO "nl:"
  acp_value_cd = pm_get_cvo_alias(pla.value_cd,nhs_report_code), acp_plan_cd = pm_get_cvo_alias(eacp
   .augm_care_period_plan_cd,nhs_report_code), acp_source_cd = pm_get_cvo_alias(eacp
   .augm_care_period_source_cd,nhs_report_code),
  acp_disp_cd = pm_get_cvo_alias(eacp.augm_care_period_disposal_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encntr_augm_care_period eacp,
   encntr_loc_hist elh,
   pm_loc_attrib pla
  PLAN (d)
   JOIN (eacp
   WHERE (eacp.encntr_slice_id=cds->activity[d.seq].nhs_consultant_episode_id))
   JOIN (elh
   WHERE elh.encntr_id=eacp.encntr_id
    AND eacp.end_effective_dt_tm > elh.beg_effective_dt_tm
    AND eacp.end_effective_dt_tm <= elh.end_effective_dt_tm
    AND elh.active_ind=1)
   JOIN (pla
   WHERE (pla.location_cd= Outerjoin(elh.loc_nurse_unit_cd))
    AND (pla.attrib_type_cd= Outerjoin(augmentedcare)) )
  ORDER BY d.seq, eacp.encntr_augm_care_period_id, 0
  HEAD d.seq
   aug = 0
  HEAD eacp.encntr_augm_care_period_id
   aug += 1, stat = alterlist(cds->activity[d.seq].augmented_care_details,aug), cds->activity[d.seq].
   augmented_care_details[aug].local_id = cnvtstring(eacp.encntr_augm_care_period_id),
   cds->activity[d.seq].augmented_care_details[aug].care_period_num = format(aug,"##;P0"), cds->
   activity[d.seq].augmented_care_details[aug].care_period_source = acp_source_cd, cds->activity[d
   .seq].augmented_care_details[aug].planned_ind = acp_plan_cd,
   cds->activity[d.seq].augmented_care_details[aug].aug_start_date = eacp.beg_effective_dt_tm, cds->
   activity[d.seq].augmented_care_details[aug].aug_end_date = eacp.end_effective_dt_tm, cds->
   activity[d.seq].augmented_care_details[aug].care_period_disp = acp_disp_cd
   IF ((cds->activity[d.seq].augmented_care_details[aug].aug_end_date > 0))
    IF ((cds->activity[d.seq].augmented_care_details[aug].care_period_disp != "07"))
     cds->activity[d.seq].augmented_care_details[aug].outcome_ind = "01"
    ELSEIF ((cds->activity[d.seq].augmented_care_details[aug].care_period_disp="07"))
     IF (uar_get_code_display(cds->activity[d.seq].organ_donor_cd)="Yes")
      cds->activity[d.seq].augmented_care_details[aug].outcome_ind = "02"
     ELSEIF (uar_get_code_display(cds->activity[d.seq].organ_donor_cd)="No")
      cds->activity[d.seq].augmented_care_details[aug].outcome_ind = "03"
     ENDIF
    ENDIF
   ELSE
    cds->activity[d.seq].augmented_care_details[aug].outcome_ind = "98", cds->activity[d.seq].
    augmented_care_details[aug].care_period_disp = "98"
   ENDIF
   cds->activity[d.seq].augmented_care_details[aug].intensive_care_days = format(eacp
    .intensive_care_lvl_days,"####;P0"), cds->activity[d.seq].augmented_care_details[aug].
   high_dep_level_days = format(eacp.high_depend_care_lvl_days,"####;P0")
   IF ((cds->activity[d.seq].augmented_care_details[aug].aug_end_date > 0))
    cds->activity[d.seq].augmented_care_details[aug].num_organs_supp = format(eacp
     .num_organ_sys_support_nbr,"##;P0")
   ELSEIF ((cds->activity[d.seq].augmented_care_details[aug].aug_end_date=0))
    cds->activity[d.seq].augmented_care_details[aug].num_organs_supp = "99"
   ENDIF
   cds->activity[d.seq].augmented_care_details[aug].aug_spec_fun_cd = cds->activity[d.seq].
   main_specialty_code, cds->activity[d.seq].augmented_care_details[aug].aug_care_loc = acp_value_cd
  FOOT  d.seq
   IF (aug > 0)
    cds->activity[d.seq].care_periods_ct = format(aug,"##;P0")
   ENDIF
  WITH nocounter
 ;end select
 IF ( NOT ((cdsbatch->org_code IN ("RQX", "RNH", "5C5"))))
  GO TO exit_newh_maternity
 ENDIF
 CALL echo("NEWH Birth Details")
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
 CALL echo("Getting details about the baby's delivery")
 CALL echo("------------------------------------------")
 SELECT INTO "nl:"
  ei_result = pm_get_cvo_alias(ei.value_cd,nhs_report_code), ccr_result = pm_get_cvo_alias(ccr
   .result_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encounter e,
   encntr_info ei,
   person_patient pp,
   clinical_event ce3,
   ce_coded_result ccr,
   dummyt d1
  PLAN (d
   WHERE (cds->activity[d.seq].maternity_delivery_flag=0)
    AND  NOT ((cds->activity[d.seq].patient_surname IN ("ZZZ*", "ZZ*TEST*"))))
   JOIN (e
   WHERE (e.encntr_id=cds->activity[d.seq].encntr_id)
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM person p
    WHERE p.person_id=e.person_id
     AND p.name_last_key IN ("ZZ*TEST*", "ZZZ*")))))
   JOIN (pp
   WHERE (pp.person_id= Outerjoin(e.person_id)) )
   JOIN (ei
   WHERE ei.encntr_id=e.encntr_id
    AND ei.info_sub_type_cd IN (188371, 188379, 216869.00, 216870.00, 188357.00))
   JOIN (d1)
   JOIN (ce3
   WHERE ce3.encntr_id=ei.encntr_id
    AND ((ce3.result_status_cd+ 0)=25.00)
    AND ce3.valid_until_dt_tm=cnvtdatetime("31-dec-2100")
    AND ((ce3.event_cd+ 0) IN (method_of_delivery_cd, resus_details_cd, delivery_person_status_cd,
   gest_at_birth_cd)))
   JOIN (ccr
   WHERE (ccr.event_id= Outerjoin(ce3.event_id)) )
  ORDER BY d.seq, 0
  HEAD d.seq
   stat = alterlist(cds->activity[d.seq].baby_details,1), cds->activity[d.seq].birth_spell_flag = 1,
   cds->activity[d.seq].neonatal_care_lvl = "0"
  DETAIL
   IF ((cds->activity[d.seq].con_epi_num=1))
    IF (pp.birth_weight > 0.0)
     cds->activity[d.seq].birth_weight = format(cnvtstring(pp.birth_weight),"####;P0")
    ELSE
     cds->activity[d.seq].birth_weight = "9999"
    ENDIF
    cds->activity[d.seq].birth_flag = 1
    IF (ei.info_sub_type_cd=188371)
     cds->activity[d.seq].live_still_birth_ind = ei_result
    ENDIF
    IF (datetimediff(cnvtdatetime(cds->activity[d.seq].disch_date),cnvtdatetime(cds->activity[d.seq].
      adm_date),3) < 24)
     cds->activity[d.seq].pt_class = "5"
    ELSE
     cds->activity[d.seq].pt_class = "1"
    ENDIF
    cds->activity[d.seq].adm_method = "82"
    IF (ei.info_sub_type_cd=188379.00)
     cds->activity[d.seq].baby_details[1].baby_del_place_type = ei_result
    ENDIF
    IF ((cds->activity[d.seq].baby_details[1].baby_del_place_type != "1"))
     IF ((cds->activity[d.seq].episode_end_dt > 0))
      cds->activity[d.seq].cds_type = "120", cds->activity[d.seq].cds_type_cd = cds_120
     ELSE
      cds->activity[d.seq].cds_type = "180", cds->activity[d.seq].cds_type_cd = cds_180
     ENDIF
    ELSEIF ((cds->activity[d.seq].baby_details[1].baby_del_place_type="1"))
     cds->activity[d.seq].cds_type = "150", cds->activity[d.seq].cds_type_cd = cds_150
    ENDIF
    IF (ce3.event_cd=method_of_delivery_cd)
     cds->activity[d.seq].baby_details[1].baby_del_method = ccr_result
    ENDIF
    IF (ce3.event_cd=resus_details_cd)
     cds->activity[d.seq].baby_details[1].baby_resus_meth = ccr_result
    ENDIF
    IF (ce3.event_cd=delivery_person_status_cd)
     cds->activity[d.seq].baby_details[1].baby_pers_cond_stat = ccr_result
    ENDIF
    IF (ce3.event_cd=gest_at_birth_cd)
     cds->activity[d.seq].baby_details[1].baby_gest_length = ce3.result_val
    ENDIF
    cds->activity[d.seq].baby_details[1].baby_birth_order = cnvtstring(pp.birth_order)
   ENDIF
  WITH counter, outerjoin = d1, orahint(" INDEX (CE FK10CLINICAL_EVENT)")
 ;end select
 CALL echo("Getting details about Mum")
 CALL echo("------------------------------------------")
 SELECT INTO "nl:"
  ccr_result = pm_get_cvo_alias(ccr.result_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   person_person_reltn prr,
   person p,
   address a,
   encounter e,
   dummyt d1,
   encntr_alias ea,
   person_alias pa,
   clinical_event ce3,
   ce_coded_result ccr,
   person_prsnl_reltn ppr,
   prsnl_alias pna,
   prsnl_org_reltn por,
   organization_alias oa,
   prsnl_reltn_activity pra,
   prsnl_reltn_child prc
  PLAN (d
   WHERE (cds->activity[d.seq].birth_flag=1)
    AND (cds->activity[d.seq].maternity_delivery_flag=0)
    AND  NOT ((cds->activity[d.seq].patient_surname IN ("ZZZ*", "ZZ*TEST*"))))
   JOIN (prr
   WHERE (prr.person_id=cds->activity[d.seq].person_id)
    AND (cds->activity[d.seq].person_id != 3714533)
    AND prr.person_reltn_cd=mother_cd
    AND prr.person_reltn_type_cd=1153.00
    AND prr.active_ind=1)
   JOIN (p
   WHERE p.person_id=prr.related_person_id
    AND  NOT (p.name_last_key IN ("ZZ*TEST*", "ZZZ*"))
    AND p.active_ind=1)
   JOIN (e
   WHERE e.person_id=p.person_id
    AND e.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=cnn_cd
    AND ea.active_ind=1)
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.parent_entity_name= Outerjoin("PERSON"))
    AND (a.address_type_cd= Outerjoin(home_addr_cd))
    AND (a.active_ind= Outerjoin(1)) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(nhs_cd))
    AND (pa.active_ind= Outerjoin(1)) )
   JOIN (ppr
   WHERE (ppr.person_id= Outerjoin(p.person_id))
    AND (ppr.person_prsnl_r_cd= Outerjoin(gp_cd))
    AND (ppr.active_ind= Outerjoin(1)) )
   JOIN (pna
   WHERE (pna.person_id= Outerjoin(ppr.prsnl_person_id))
    AND (pna.prsnl_alias_type_cd= Outerjoin(doccnbr)) )
   JOIN (por
   WHERE (por.person_id= Outerjoin(ppr.prsnl_person_id)) )
   JOIN (oa
   WHERE (oa.organization_id= Outerjoin(por.organization_id))
    AND (oa.org_alias_type_cd= Outerjoin(org_alias_cd)) )
   JOIN (pra
   WHERE (pra.parent_entity_id= Outerjoin(ppr.person_prsnl_reltn_id))
    AND (pra.parent_entity_name= Outerjoin("PERSON_PRSNL_RELTN")) )
   JOIN (prc
   WHERE (prc.prsnl_reltn_id= Outerjoin(pra.prsnl_reltn_id))
    AND (prc.parent_entity_name= Outerjoin("ADDRESS")) )
   JOIN (d1
   WHERE ((cnvtdatetime(cds->activity[d.seq].birth_dt) BETWEEN cnvtdatetime(cnvtdate(e.reg_dt_tm),0)
    AND cnvtdatetime(cnvtdate(e.disch_dt_tm),235959)) OR (cnvtdatetime(cds->activity[d.seq].birth_dt)
    >= cnvtdatetime(cnvtdate(e.reg_dt_tm),0)
    AND e.disch_dt_tm = null)) )
   JOIN (ce3
   WHERE ce3.encntr_id=e.encntr_id
    AND ((ce3.result_status_cd+ 0)=25.00)
    AND ce3.valid_until_dt_tm=cnvtdatetime("31-dec-2100")
    AND ce3.event_cd IN (first_ant_asst_dt_cd, 107492, 2706529, del_dt_tm_cd, 2706552,
   del_place_chg_reas_cd, anes_during_labour_cd, anes_post_labour_cd, onset_of_labour_cd))
   JOIN (ccr
   WHERE (ccr.event_id= Outerjoin(ce3.event_id)) )
  ORDER BY d.seq, 0
  HEAD d.seq
   baby_count = 0
  DETAIL
   stat = alterlist(cds->activity[d.seq].baby_details,1), cds->activity[d.seq].mom_birth_date = p
   .birth_dt_tm, cds->activity[d.seq].mom_nhs_new = pa.alias,
   cds->activity[d.seq].mom_nhs_status = uar_get_code_meaning(pa.person_alias_status_cd), cds->
   activity[d.seq].mom_address_cd = "1", cds->activity[d.seq].mom_address_1 = a.street_addr,
   cds->activity[d.seq].mom_address_2 = a.street_addr2, cds->activity[d.seq].mom_address_3 = a
   .street_addr3, cds->activity[d.seq].mom_address_4 = a.street_addr3,
   cds->activity[d.seq].mom_address_5 = a.state,
   CALL format_postcode_nhs(trim(a.zipcode_key,3),temp_postcode), cds->activity[d.seq].mom_post_cd =
   temp_postcode,
   cds->activity[d.seq].mom_pct = uar_get_code_display(a.primary_care_cd)
   IF (ce3.event_cd=2706552)
    cds->activity[d.seq].number_of_babies = ce3.result_val
   ENDIF
   IF (ce3.event_cd=first_ant_asst_dt_cd
    AND trim(ce3.result_val,3) != " ")
    cds->activity[d.seq].first_antenatal_dt = cnvtdate2(substring(3,8,ce3.result_val),"YYYYMMDD")
   ENDIF
   IF (ce3.event_cd=del_dt_tm_cd
    AND trim(ce3.result_val,3) != "")
    del_date = cnvtdate2(substring(3,8,ce3.result_val),"YYYYMMDD"), del_time = cnvtint(substring(11,4,
      ce3.result_val)), cds->activity[d.seq].delivery_date = cnvtdatetime(del_date,del_time)
   ENDIF
   IF (ce3.event_cd=int_del_loc_cd)
    cds->activity[d.seq].del_place_type = ccr_result
   ENDIF
   IF (ce3.event_cd=del_place_chg_reas_cd)
    cds->activity[d.seq].del_place_chg_reas = ccr_result
   ENDIF
   IF (ce3.event_cd=anes_during_labour_cd)
    cds->activity[d.seq].anes_during_del = ccr_result
   ENDIF
   IF (ce3.event_cd=anes_post_labour_cd)
    cds->activity[d.seq].anes_post_del = ccr_result
   ENDIF
   IF (ce3.event_cd=onset_of_labour_cd)
    cds->activity[d.seq].gest_len = ccr_result
   ENDIF
   cds->activity[d.seq].antenatal_gp_cd = pna.alias, cds->activity[d.seq].antenatal_gp_prac_cd = oa
   .alias
  FOOT  d.seq
   cds->activity[d.seq].mom_local_pat_id = cnvtalias(ea.alias,ea.alias_pool_cd)
   IF (trim(cds->activity[d.seq].anes_during_del,3)=" ")
    cds->activity[d.seq].anes_during_del = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].anes_post_del,3)=" ")
    cds->activity[d.seq].anes_during_del = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].gest_len,3)=" ")
    cds->activity[d.seq].gest_len = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].baby_details[1].baby_birth_order,3)=" ")
    cds->activity[d.seq].baby_details[1].baby_birth_order = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].baby_details[1].baby_resus_meth,3)=" ")
    cds->activity[d.seq].baby_details[1].baby_resus_meth = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].baby_details[1].baby_pers_cond_stat,3)=" ")
    cds->activity[d.seq].baby_details[1].baby_pers_cond_stat = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].baby_details[1].baby_del_place_type,3)=" ")
    cds->activity[d.seq].baby_details[1].baby_del_place_type = "9"
   ENDIF
   cds->activity[d.seq].mom_org_cd = cds->activity[d.seq].patient_id_org
   IF ((cds->activity[d.seq].delivery_date=0))
    cds->activity[d.seq].delivery_date = cds->activity[d.seq].birth_dt
   ENDIF
   IF ((cds->activity[d.seq].baby_details[1].baby_del_place_type != cds->activity[d.seq].
   del_place_type)
    AND trim(cds->activity[d.seq].del_place_chg_reas,3)=" ")
    cds->activity[d.seq].del_place_chg_reas = "9"
   ELSEIF ((cds->activity[d.seq].baby_details[1].baby_del_place_type=cds->activity[d.seq].
   del_place_type)
    AND trim(cds->activity[d.seq].del_place_chg_reas,3)=" ")
    cds->activity[d.seq].del_place_chg_reas = "9"
   ENDIF
  WITH counter
 ;end select
 CALL echo("Getting Neonatal Level Of Care Info")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5)))
  PLAN (d)
  DETAIL
   ward_size = size(cds->activity[d.seq].ward_stay_details,5)
   FOR (nlc = 1 TO ward_size)
     IF (cnvtupper(cds->activity[d.seq].ward_stay_details[nlc].loc_nurse_unit) IN ("SCBU", "NEO*"))
      cds->activity[d.seq].neonatal_care_lvl = "1"
     ENDIF
   ENDFOR
   IF ((cds->activity[d.seq].local_subspecialty IN ("28", "38")))
    cds->activity[d.seq].neonatal_care_lvl = "1"
   ENDIF
   IF ((cds->activity[d.seq].local_subspecialty="48")
    AND (cds->activity[d.seq].neonatal_care_lvl="1"))
    cds->activity[d.seq].neonatal_care_lvl = "2"
   ENDIF
   IF ((cds->activity[d.seq].local_subspecialty="113")
    AND (cds->activity[d.seq].neonatal_care_lvl="1"))
    cds->activity[d.seq].neonatal_care_lvl = "3"
   ENDIF
   IF ((cds->activity[d.seq].live_still_birth_ind IN ("2", "3", "4")))
    cds->activity[d.seq].neonatal_care_lvl = "8"
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("NEWH Getting Maternity/Delivery Details")
 CALL echo("Getting details about the delivery")
 CALL echo("----------------------------------")
 SELECT INTO "nl:"
  ccr4_result = pm_get_cvo_alias(ccr4.result_cd,nhs_report_code), ccr_result = pm_get_cvo_alias(ccr
   .result_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encounter e,
   clinical_event ce3,
   ce_coded_result ccr,
   dummyt d1,
   clinical_event ce4,
   ce_coded_result ccr4
  PLAN (d
   WHERE (cds->activity[d.seq].birth_flag=0)
    AND  NOT ((cds->activity[d.seq].patient_surname IN ("ZZZ*", "ZZ*TEST*"))))
   JOIN (e
   WHERE (e.encntr_id=cds->activity[d.seq].encntr_id)
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM person p
    WHERE p.person_id=e.person_id
     AND p.name_last_key IN ("ZZ*TEST*", "ZZZ*")))))
   JOIN (ce3
   WHERE ce3.encntr_id=e.encntr_id
    AND ce3.event_cd IN (first_ant_asst_dt_cd, 107492, 2706529, 72573, 2706552,
   del_place_chg_reas_cd, anes_during_labour_cd, anes_post_labour_cd, onset_of_labour_cd)
    AND ((ce3.result_status_cd+ 0)=25.00)
    AND ce3.valid_until_dt_tm=cnvtdatetime("31-dec-2100"))
   JOIN (ccr
   WHERE (ccr.event_id= Outerjoin(ce3.event_id)) )
   JOIN (d1)
   JOIN (ce4
   WHERE ce4.person_id=ce3.person_id
    AND ce4.event_cd=int_del_loc_cd
    AND ((ce4.result_status_cd+ 0)=25.00)
    AND ce4.valid_until_dt_tm=cnvtdatetime("31-dec-2100")
    AND ((ce4.performed_dt_tm BETWEEN cnvtlookbehind("9,M",cnvtdatetime(cds->activity[d.seq].
     episode_start_dt)) AND cnvtdatetime(cds->activity[d.seq].episode_end_dt)) OR (ce4
   .performed_dt_tm > cnvtlookbehind("9,M",cnvtdatetime(cds->activity[d.seq].episode_start_dt))
    AND (cds->activity[d.seq].episode_end_dt=0))) )
   JOIN (ccr4
   WHERE (ccr4.event_id= Outerjoin(ce4.event_id)) )
  ORDER BY d.seq
  HEAD d.seq
   cds->activity[d.seq].previous_pregs_nbr = "99"
  DETAIL
   cds->activity[d.seq].antenatal_gp_cd = cds->activity[d.seq].gp_code, cds->activity[d.seq].
   antenatal_gp_prac_cd = cds->activity[d.seq].gp_practice
   IF (ce3.event_cd=first_ant_asst_dt_cd
    AND trim(ce3.result_val,3) != " ")
    cds->activity[d.seq].first_antenatal_dt = cnvtdate2(substring(3,8,ce3.result_val),"YYYYMMDD")
   ENDIF
   IF (ce3.event_cd=107492)
    IF (textlen(trim(ce3.result_val,3)) > 0)
     cds->activity[d.seq].previous_pregs_nbr = format(ce3.result_val,"##;P0")
    ENDIF
   ENDIF
   IF (ce3.event_cd=2706529.00)
    cds->activity[d.seq].gest_len = ce3.result_val
   ENDIF
   IF (ce3.event_cd=72573
    AND trim(ce3.result_val,3) != "")
    del_date = cnvtdate2(substring(3,8,ce3.result_val),"YYYYMMDD"), del_time = cnvtint(substring(11,4,
      ce3.result_val)), cds->activity[d.seq].delivery_date = cnvtdatetime(del_date,del_time)
   ENDIF
   IF (ce3.event_cd=2706552)
    cds->activity[d.seq].number_of_babies = ce3.result_val
   ENDIF
   IF (ce3.event_cd=del_place_chg_reas_cd)
    cds->activity[d.seq].del_place_chg_reas = ccr_result
   ENDIF
   IF (ce3.event_cd=anes_during_labour_cd)
    cds->activity[d.seq].anes_during_del = ccr_result
   ENDIF
   IF (ce3.event_cd=anes_post_labour_cd)
    cds->activity[d.seq].anes_post_del = ccr_result
   ENDIF
   IF (ce3.event_cd=onset_of_labour_cd)
    cds->activity[d.seq].labor_onset_meth = ccr_result
   ENDIF
   IF (ce4.event_cd=int_del_loc_cd)
    cds->activity[d.seq].del_place_type = ccr4_result
   ENDIF
   IF (datetimediff(cnvtdatetime(cds->activity[d.seq].disch_date),cnvtdatetime(cds->activity[d.seq].
     adm_date),3) < 24)
    cds->activity[d.seq].pt_class = "5"
   ELSE
    cds->activity[d.seq].pt_class = "1"
   ENDIF
  FOOT  d.seq
   IF ((((cds->activity[d.seq].delivery_date BETWEEN cds->activity[d.seq].episode_start_dt AND cds->
   activity[d.seq].episode_end_dt)
    AND (cds->activity[d.seq].delivery_date > 0)) OR ((cds->activity[d.seq].delivery_date >= cds->
   activity[d.seq].episode_start_dt)
    AND (cds->activity[d.seq].episode_end_dt=0)
    AND (cds->activity[d.seq].delivery_date > 0))) )
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ELSEIF ((cds->activity[d.seq].delivery_date <= cds->activity[d.seq].episode_start_dt)
    AND (cds->activity[d.seq].con_epi_num=1)
    AND (cds->activity[d.seq].delivery_date > 0)
    AND datetimediff(cds->activity[d.seq].episode_start_dt,cds->activity[d.seq].delivery_date,1) <= 3
   )
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ELSEIF ((cds->activity[d.seq].delivery_date >= cds->activity[d.seq].episode_end_dt)
    AND (cds->activity[d.seq].last_episode_ind="1")
    AND (cds->activity[d.seq].delivery_date > 0)
    AND datetimediff(cds->activity[d.seq].delivery_date,cds->activity[d.seq].episode_end_dt,1) <= 3)
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ENDIF
  WITH counter, outerjoin = d1, orahint(" INDEX (CE FK10CLINICAL_EVENT)")
 ;end select
 CALL echo("Getting details about the babies")
 CALL echo("----------------------------------")
 SELECT INTO "nl:"
  sex = pm_get_cvo_alias(p.sex_cd,nhs_report_code), ei_result = pm_get_cvo_alias(ei.value_cd,
   nhs_report_code), ccr_result = pm_get_cvo_alias(ccr.result_cd,nhs_report_code),
  nullind_p_birth_dt_tm = nullind(p.birth_dt_tm), nullind_p_birth_dt_tm = nullind(p.birth_dt_tm),
  nullind_p_birth_dt_tm = nullind(p.birth_dt_tm),
  nullind_p_birth_dt_tm = nullind(p.birth_dt_tm), nullind_p_birth_dt_tm = nullind(p.birth_dt_tm)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   person_person_reltn prr,
   person p,
   encounter e,
   encntr_info ei,
   encntr_alias ea,
   person_alias pa,
   person_patient pp,
   clinical_event ce3,
   ce_coded_result ccr,
   dummyt d1
  PLAN (d
   WHERE (cds->activity[d.seq].birth_flag=0)
    AND  NOT ((cds->activity[d.seq].patient_surname IN ("ZZZ*", "ZZ*TEST*"))))
   JOIN (prr
   WHERE (prr.related_person_id=cds->activity[d.seq].person_id)
    AND ((prr.person_reltn_cd+ 0)=mother_cd)
    AND ((prr.person_reltn_type_cd+ 0)=1153.00))
   JOIN (p
   WHERE p.person_id=prr.person_id
    AND ((datetimecmp(p.birth_dt_tm,cnvtdatetime(cds->activity[d.seq].delivery_date))=0) OR (((p
   .birth_dt_tm BETWEEN cnvtdatetime(cds->activity[d.seq].adm_date,0) AND cnvtdatetime(cds->activity[
    d.seq].disch_date,235959)) OR (p.birth_dt_tm >= cnvtdatetime(cds->activity[d.seq].adm_date,0)
    AND (cds->activity[d.seq].disch_date=0))) ))
    AND  NOT (p.name_last_key IN ("ZZ*TEST*", "ZZZ*")))
   JOIN (e
   WHERE e.person_id=p.person_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(cnn_cd))
    AND (ea.active_ind= Outerjoin(1)) )
   JOIN (pp
   WHERE (pp.person_id= Outerjoin(p.person_id)) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(nhs_cd)) )
   JOIN (ei
   WHERE ei.encntr_id=e.encntr_id
    AND ei.info_sub_type_cd IN (188371, 188379, 216869.00, 216870.00, 188357.00))
   JOIN (d1)
   JOIN (ce3
   WHERE ce3.encntr_id=ei.encntr_id
    AND ce3.event_cd IN (method_of_delivery_cd, resus_details_cd, delivery_person_status_cd,
   gest_at_birth_cd)
    AND ((ce3.result_status_cd+ 0)=25.00)
    AND ce3.valid_until_dt_tm=cnvtdatetime("31-dec-2100"))
   JOIN (ccr
   WHERE (ccr.event_id= Outerjoin(ce3.event_id)) )
  ORDER BY d.seq, p.person_id, pp.birth_order
  HEAD d.seq
   baby_count = 0
  HEAD p.person_id
   baby_count += 1, stat = alterlist(cds->activity[d.seq].baby_details,baby_count)
  DETAIL
   cds->activity[d.seq].baby_details[baby_count].baby_loc_pat_id = cnvtalias(ea.alias,ea
    .alias_pool_cd), cds->activity[d.seq].baby_details[baby_count].baby_org_cd = cds->activity[d.seq]
   .patient_id_org, cds->activity[d.seq].baby_details[baby_count].baby_birth_date = p.birth_dt_tm
   IF (pp.birth_weight > 0.0)
    cds->activity[d.seq].baby_details[baby_count].baby_birth_wt = format(cnvtstring(pp.birth_weight),
     "####;P0")
   ELSE
    cds->activity[d.seq].baby_details[baby_count].baby_birth_wt = "9999"
   ENDIF
   cds->activity[d.seq].baby_details[baby_count].baby_birth_order = cnvtstring(pp.birth_order), cds->
   activity[d.seq].baby_details[baby_count].baby_sex = sex
   IF (ei.info_sub_type_cd=188379)
    cds->activity[d.seq].baby_details[baby_count].baby_del_place_type = ei_result
   ENDIF
   IF (ei.info_sub_type_cd=188371)
    cds->activity[d.seq].baby_details[baby_count].baby_live_still = ei_result
   ENDIF
   IF (ce3.event_cd=method_of_delivery_cd)
    cds->activity[d.seq].baby_details[baby_count].baby_del_method = ccr_result
   ENDIF
   IF (ce3.event_cd=resus_details_cd)
    cds->activity[d.seq].baby_details[baby_count].baby_resus_meth = ccr_result
   ENDIF
   IF (ce3.event_cd=delivery_person_status_cd)
    cds->activity[d.seq].baby_details[baby_count].baby_pers_cond_stat = ccr_result
   ENDIF
   IF (ce3.event_cd=gest_at_birth_cd)
    cds->activity[d.seq].baby_details[baby_count].baby_gest_length = ce3.result_val
   ENDIF
   cds->activity[d.seq].baby_details[baby_count].baby_nhs_num = pa.alias, cds->activity[d.seq].
   baby_details[baby_count].baby_nhs_stat = uar_get_code_meaning(pa.person_alias_status_cd)
   IF (((p.birth_dt_tm BETWEEN cnvtdatetime(cds->activity[d.seq].episode_start_dt) AND cnvtdatetime(
    cds->activity[d.seq].episode_end_dt)
    AND nullind_p_birth_dt_tm=0) OR (p.birth_dt_tm >= cnvtdatetime(cds->activity[d.seq].
    episode_start_dt)
    AND cnvtdatetime(cds->activity[d.seq].episode_end_dt)=0
    AND nullind_p_birth_dt_tm=0)) )
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ELSEIF (p.birth_dt_tm <= cnvtdatetime(cds->activity[d.seq].episode_start_dt)
    AND (cds->activity[d.seq].con_epi_num=1)
    AND nullind_p_birth_dt_tm=0
    AND datetimediff(cds->activity[d.seq].episode_start_dt,cds->activity[d.seq].delivery_date,1) <= 3
   )
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ELSEIF (p.birth_dt_tm >= cnvtdatetime(cds->activity[d.seq].episode_end_dt)
    AND (cds->activity[d.seq].last_episode_ind="1")
    AND nullind_p_birth_dt_tm=0
    AND datetimediff(cds->activity[d.seq].delivery_date,cds->activity[d.seq].episode_end_dt,1) <= 3)
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ENDIF
   IF ((cds->activity[d.seq].baby_details[1].baby_del_place_type="1"))
    cds->activity[d.seq].cds_type = "160", cds->activity[d.seq].cds_type_cd = cds_160, cds->activity[
    d.seq].maternity_delivery_flag = 1
   ENDIF
   IF ((cds->activity[d.seq].delivery_date=0)
    AND nullind_p_birth_dt_tm=1)
    cds->activity[d.seq].maternity_delivery_flag = 9
   ENDIF
  WITH counter, outerjoin = d1
 ;end select
#exit_newh_maternity
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
 SELECT INTO "nl:"
  ei_result = pm_get_cvo_alias(ei.value_cd,nhs_report_code), ccr_result = pm_get_cvo_alias(ccr
   .result_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encounter e,
   encntr_info ei,
   person_patient pp,
   clinical_event ce3,
   ce_coded_result ccr,
   dummyt d1
  PLAN (d
   WHERE (cds->activity[d.seq].maternity_delivery_flag=0)
    AND (cds->activity[d.seq].newh_mum_baby=0)
    AND (cds->activity[d.seq].update_type="9"))
   JOIN (e
   WHERE (e.encntr_id=cds->activity[d.seq].encntr_id))
   JOIN (pp
   WHERE (pp.person_id= Outerjoin(e.person_id)) )
   JOIN (ei
   WHERE ei.encntr_id=e.encntr_id
    AND ei.info_sub_type_cd IN (ei_subtype_pas_lsb_cd, ei_subtype_pas_adlt_cd, ei_subtype_pas_bn_cd,
   ei_subtype_pas_gllo_cd, ei_subtype_pas_sca_cd))
   JOIN (d1)
   JOIN (ce3
   WHERE ce3.encntr_id=ei.encntr_id
    AND  NOT (((ce3.result_status_cd+ 0) IN (ce_in_error_cd, ce_in_error_noview_cd,
   ce_in_error_nomut_cd, ce_cancelled_cd)))
    AND ((ce3.event_cd+ 0) IN (method_of_delivery_cd, resus_details_cd, delivery_person_status_cd,
   gest_at_birth_cd))
    AND ce3.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (ccr
   WHERE (ccr.event_id= Outerjoin(ce3.event_id)) )
  ORDER BY d.seq, 0
  HEAD d.seq
   stat = alterlist(cds->activity[d.seq].baby_details,1), cds->activity[d.seq].birth_spell_flag = 1
  DETAIL
   IF ((cds->activity[d.seq].con_epi_num=1))
    IF (pp.birth_weight > 0.0)
     cds->activity[d.seq].birth_weight = format(cnvtstring(pp.birth_weight),"####;P0")
    ELSE
     cds->activity[d.seq].birth_weight = "9999"
    ENDIF
    cds->activity[d.seq].birth_flag = 1, cds->activity[d.seq].neonatal_care_lvl = "0"
    IF (ei.info_sub_type_cd=ei_subtype_pas_lsb_cd)
     cds->activity[d.seq].live_still_birth_ind = ei_result
    ENDIF
    IF ((cds->activity[d.seq].live_still_birth_ind IN ("2", "3", "4")))
     cds->activity[d.seq].neonatal_care_lvl = "8"
    ENDIF
    IF (datetimediff(cnvtdatetime(cds->activity[d.seq].disch_date),cnvtdatetime(cds->activity[d.seq].
      adm_date),3) < 24)
     cds->activity[d.seq].pt_class = "5"
    ELSE
     cds->activity[d.seq].pt_class = "1"
    ENDIF
    IF (ei.info_sub_type_cd=ei_subtype_pas_adlt_cd)
     cds->activity[d.seq].baby_details[1].baby_del_place_type = ei_result
    ENDIF
    IF ((cds->activity[d.seq].baby_details[1].baby_del_place_type != "1"))
     IF ((cds->activity[d.seq].episode_end_dt > 0))
      cds->activity[d.seq].cds_type = "120", cds->activity[d.seq].cds_type_cd = cds_120
     ELSE
      cds->activity[d.seq].cds_type = "180", cds->activity[d.seq].cds_type_cd = cds_180
     ENDIF
     cds->activity[d.seq].adm_method = "82"
    ELSEIF ((cds->activity[d.seq].baby_details[1].baby_del_place_type="1"))
     cds->activity[d.seq].cds_type = "150", cds->activity[d.seq].cds_type_cd = cds_150, cds->
     activity[d.seq].adm_method = "28"
    ENDIF
    IF (ce3.event_cd=method_of_delivery_cd)
     cds->activity[d.seq].baby_details[1].baby_del_method = ccr_result
    ENDIF
    IF (ce3.event_cd=resus_details_cd)
     cds->activity[d.seq].baby_details[1].baby_resus_meth = ccr_result
    ENDIF
    IF (ce3.event_cd=delivery_person_status_cd)
     cds->activity[d.seq].baby_details[1].baby_pers_cond_stat = ccr_result
    ENDIF
    IF (ce3.event_cd=gest_at_birth_cd)
     cds->activity[d.seq].baby_details[1].baby_gest_length = ce3.result_val
    ENDIF
    cds->activity[d.seq].baby_details[1].baby_birth_order = cnvtstring(pp.birth_order)
   ENDIF
  WITH nocounter, outerjoin = d1, orahint(" INDEX (CE FK10CLINICAL_EVENT)")
 ;end select
 CALL echo("Getting details about Mum")
 CALL echo("------------------------------------------")
 SELECT INTO "nl:"
  ccr_result = pm_get_cvo_alias(ccr.result_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encntr_alias ea2,
   person_person_reltn prr,
   person p,
   address a,
   encounter e,
   dummyt d1,
   encntr_alias ea,
   person_alias pa,
   clinical_event ce3,
   ce_coded_result ccr,
   person_prsnl_reltn ppr,
   prsnl_alias pna,
   prsnl_org_reltn por,
   organization_alias oa,
   prsnl_reltn_activity pra,
   prsnl_reltn_child prc
  PLAN (d
   WHERE (cds->activity[d.seq].birth_flag=1)
    AND (cds->activity[d.seq].maternity_delivery_flag=0)
    AND (cds->activity[d.seq].update_type="9")
    AND (cds->activity[d.seq].newh_mum_baby=0))
   JOIN (ea2
   WHERE (ea2.alias=cds->activity[d.seq].spell_number)
    AND (ea2.encntr_id != cds->activity[d.seq].encntr_id)
    AND ea2.encntr_alias_type_cd=fin_nbr
    AND ea2.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ea2.encntr_id
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM code_value cv
    WHERE cv.code_value=e.admit_type_cd
     AND cv.cdf_meaning IN ("URGENT", "NEWBORN")))))
   JOIN (prr
   WHERE prr.related_person_id=e.person_id
    AND prr.person_reltn_cd=mother_cd
    AND prr.person_reltn_type_cd=ppr_family_type_cd
    AND prr.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.name_last_key != "ZZZ*")
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(cnn_cd))
    AND (ea.active_ind= Outerjoin(1)) )
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.parent_entity_name= Outerjoin("PERSON"))
    AND (a.address_type_cd= Outerjoin(home_addr_cd)) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(nhs_cd)) )
   JOIN (ppr
   WHERE (ppr.person_id= Outerjoin(p.person_id))
    AND (ppr.person_prsnl_r_cd= Outerjoin(gp_cd))
    AND ppr.manual_create_ind=0)
   JOIN (pna
   WHERE (pna.person_id= Outerjoin(ppr.prsnl_person_id))
    AND (pna.prsnl_alias_type_cd= Outerjoin(doccnbr)) )
   JOIN (por
   WHERE (por.person_id= Outerjoin(ppr.prsnl_person_id)) )
   JOIN (oa
   WHERE (oa.organization_id= Outerjoin(por.organization_id))
    AND (oa.org_alias_type_cd= Outerjoin(org_alias_cd)) )
   JOIN (pra
   WHERE (pra.parent_entity_id= Outerjoin(ppr.person_prsnl_reltn_id))
    AND (pra.parent_entity_name= Outerjoin("PERSON_PRSNL_RELTN")) )
   JOIN (prc
   WHERE (prc.prsnl_reltn_id= Outerjoin(pra.prsnl_reltn_id))
    AND (prc.parent_entity_name= Outerjoin("ADDRESS")) )
   JOIN (d1)
   JOIN (ce3
   WHERE ce3.encntr_id=e.encntr_id
    AND  NOT (((ce3.result_status_cd+ 0) IN (ce_in_error_cd, ce_in_error_noview_cd,
   ce_in_error_nomut_cd, ce_cancelled_cd)))
    AND ce3.event_cd IN (first_ant_asst_dt_cd, num_prev_pregnancy_cd, gest_at_birth_weeks_cd,
   del_dt_tm_cd, num_babies_at_birth_cd,
   del_place_chg_reas_cd, anes_during_labour_cd, anes_post_labour_cd, onset_of_labour_cd)
    AND ce3.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (ccr
   WHERE (ccr.event_id= Outerjoin(ce3.event_id)) )
  ORDER BY d.seq, 0
  HEAD d.seq
   baby_count = 0
  DETAIL
   stat = alterlist(cds->activity[d.seq].baby_details,1), cds->activity[d.seq].mom_birth_date = p
   .birth_dt_tm, cds->activity[d.seq].mom_nhs_new = pa.alias,
   cds->activity[d.seq].mom_nhs_status = uar_get_code_meaning(pa.person_alias_status_cd), cds->
   activity[d.seq].mom_address_cd = "1", cds->activity[d.seq].mom_address_1 = a.street_addr,
   cds->activity[d.seq].mom_address_2 = a.street_addr2, cds->activity[d.seq].mom_address_3 = a
   .street_addr3, cds->activity[d.seq].mom_address_4 = a.street_addr3,
   cds->activity[d.seq].mom_address_5 = a.state,
   CALL format_postcode_nhs(trim(a.zipcode_key,3),temp_postcode), cds->activity[d.seq].mom_post_cd =
   temp_postcode,
   cds->activity[d.seq].mom_pct = uar_get_code_display(a.primary_care_cd)
   IF (ce3.event_cd=num_babies_at_birth_cd)
    cds->activity[d.seq].number_of_babies = ce3.result_val
   ENDIF
   IF (ce3.event_cd=first_ant_asst_dt_cd
    AND trim(ce3.result_val,3) != " ")
    cds->activity[d.seq].first_antenatal_dt = cnvtdate2(substring(3,8,ce3.result_val),"YYYYMMDD")
   ENDIF
   IF (ce3.event_cd=del_dt_tm_cd
    AND trim(ce3.result_val,3) != "")
    del_date = cnvtdate2(substring(3,8,ce3.result_val),"YYYYMMDD"), del_time = cnvtint(substring(11,4,
      ce3.result_val)), cds->activity[d.seq].delivery_date = cnvtdatetime(del_date,del_time)
   ENDIF
   IF (ce3.event_cd=int_del_loc_cd)
    cds->activity[d.seq].del_place_type = ccr_result
   ENDIF
   IF (ce3.event_cd=del_place_chg_reas_cd)
    cds->activity[d.seq].del_place_chg_reas = ccr_result
   ENDIF
   IF (ce3.event_cd=anes_during_labour_cd)
    cds->activity[d.seq].anes_during_del = ccr_result
   ENDIF
   IF (ce3.event_cd=anes_post_labour_cd)
    cds->activity[d.seq].anes_post_del = ccr_result
   ENDIF
   IF (ce3.event_cd=gest_at_birth_weeks_cd)
    cds->activity[d.seq].gest_len = ce3.result_val
   ENDIF
   IF (ce3.event_cd=onset_of_labour_cd)
    cds->activity[d.seq].labor_onset_meth = ccr_result
   ENDIF
   cds->activity[d.seq].antenatal_gp_cd = pna.alias, cds->activity[d.seq].antenatal_gp_prac_cd = oa
   .alias
  FOOT  d.seq
   cds->activity[d.seq].mom_local_pat_id = cnvtalias(ea.alias,ea.alias_pool_cd)
   IF (trim(cds->activity[d.seq].anes_during_del,3)=" ")
    cds->activity[d.seq].anes_during_del = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].anes_post_del,3)=" ")
    cds->activity[d.seq].anes_during_del = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].gest_len,3)=" ")
    cds->activity[d.seq].gest_len = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].baby_details[1].baby_birth_order,3)=" ")
    cds->activity[d.seq].baby_details[1].baby_birth_order = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].baby_details[1].baby_resus_meth,3)=" ")
    cds->activity[d.seq].baby_details[1].baby_resus_meth = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].baby_details[1].baby_pers_cond_stat,3)=" ")
    cds->activity[d.seq].baby_details[1].baby_pers_cond_stat = "9"
   ENDIF
   IF (trim(cds->activity[d.seq].baby_details[1].baby_del_place_type,3)=" ")
    cds->activity[d.seq].baby_details[1].baby_del_place_type = "9"
   ENDIF
   cds->activity[d.seq].mom_org_cd = cds->activity[d.seq].patient_id_org
   IF ((cds->activity[d.seq].delivery_date=0))
    cds->activity[d.seq].delivery_date = cds->activity[d.seq].birth_dt
   ENDIF
   IF ((cds->activity[d.seq].baby_details[1].baby_del_place_type != cds->activity[d.seq].
   del_place_type)
    AND trim(cds->activity[d.seq].del_place_chg_reas,3)=" ")
    cds->activity[d.seq].del_place_chg_reas = "9"
   ELSEIF ((cds->activity[d.seq].baby_details[1].baby_del_place_type=cds->activity[d.seq].
   del_place_type)
    AND trim(cds->activity[d.seq].del_place_chg_reas,3)=" ")
    cds->activity[d.seq].del_place_chg_reas = "9"
   ENDIF
  WITH nocounter, outerjoin = d1, orahint(" INDEX (CE FK10CLINICAL_EVENT)")
 ;end select
 CALL echo("Getting Neonatal Level Of Care Info")
 SELECT INTO "nl:"
  nhs_neonatal_care_lvl = cnvtint(cvo.alias)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encntr_loc_hist elh,
   pm_loc_attrib pla,
   code_value_outbound cvo
  PLAN (d
   WHERE (cds->activity[d.seq].birth_flag=1)
    AND  NOT ((cds->activity[d.seq].live_still_birth_ind IN ("2", "3", "4"))))
   JOIN (elh
   WHERE (elh.encntr_id=cds->activity[d.seq].encntr_id))
   JOIN (pla
   WHERE pla.location_cd=elh.location_cd
    AND ((pla.attrib_type_cd+ 0)=encntr_alt_care_cd))
   JOIN (cvo
   WHERE cvo.code_value=pla.value_cd
    AND cvo.contributor_source_cd=nhs_report_code)
  ORDER BY elh.encntr_id, nhs_neonatal_care_lvl DESC
  HEAD elh.encntr_id
   IF (((elh.beg_effective_dt_tm >= cnvtdatetime(cds->activity[d.seq].episode_start_dt)
    AND ((elh.beg_effective_dt_tm <= cnvtdatetime(cds->activity[d.seq].episode_end_dt)) OR (
   cnvtdatetime(cds->activity[d.seq].episode_end_dt)=0)) ) OR (((elh.end_effective_dt_tm >=
   cnvtdatetime(cds->activity[d.seq].episode_start_dt)
    AND elh.end_effective_dt_tm <= cnvtdatetime(cds->activity[d.seq].episode_end_dt)) OR (elh
   .beg_effective_dt_tm <= cnvtdatetime(cds->activity[d.seq].episode_start_dt)
    AND elh.end_effective_dt_tm >= cnvtdatetime(cds->activity[d.seq].episode_end_dt))) )) )
    cds->activity[d.seq].neonatal_care_lvl = substring(1,1,build(nhs_neonatal_care_lvl))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Getting Maternity/Delivery Details")
 CALL echo("Getting details about the delivery")
 CALL echo("----------------------------------")
 SELECT INTO "nl:"
  ccr4_result = pm_get_cvo_alias(ccr4.result_cd,nhs_report_code), ccr_result = pm_get_cvo_alias(ccr
   .result_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encounter e,
   clinical_event ce3,
   ce_coded_result ccr,
   dummyt d1,
   clinical_event ce4,
   ce_coded_result ccr4
  PLAN (d
   WHERE (cds->activity[d.seq].birth_flag=0)
    AND (cds->activity[d.seq].update_type="9")
    AND (cds->activity[d.seq].newh_mum_baby=0))
   JOIN (e
   WHERE (e.encntr_id=cds->activity[d.seq].encntr_id))
   JOIN (ce3
   WHERE ce3.encntr_id=e.encntr_id
    AND ce3.event_cd IN (first_ant_asst_dt_cd, num_prev_pregnancy_cd, gest_at_birth_weeks_cd,
   baby_delivered_cd, num_babies_at_birth_cd,
   del_place_chg_reas_cd, anes_during_labour_cd, anes_post_labour_cd, onset_of_labour_cd)
    AND  NOT (((ce3.result_status_cd+ 0) IN (ce_in_error_cd, ce_in_error_noview_cd,
   ce_in_error_nomut_cd, ce_cancelled_cd))))
   JOIN (ccr
   WHERE (ccr.event_id= Outerjoin(ce3.event_id)) )
   JOIN (d1)
   JOIN (ce4
   WHERE ce4.person_id=ce3.person_id
    AND ce4.event_cd=int_del_loc_cd
    AND ce4.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND  NOT (((ce4.result_status_cd+ 0) IN (ce_in_error_cd, ce_in_error_noview_cd,
   ce_in_error_nomut_cd, ce_cancelled_cd)))
    AND ((ce4.performed_dt_tm BETWEEN cnvtlookbehind("9,M",cnvtdatetime(cds->activity[d.seq].
     episode_start_dt)) AND cnvtdatetime(cds->activity[d.seq].episode_end_dt)) OR (ce4
   .performed_dt_tm > cnvtlookbehind("9,M",cnvtdatetime(cds->activity[d.seq].episode_start_dt))
    AND (cds->activity[d.seq].episode_end_dt=0))) )
   JOIN (ccr4
   WHERE ccr4.event_id=ce4.event_id)
  ORDER BY d.seq
  HEAD d.seq
   cds->activity[d.seq].previous_pregs_nbr = "99"
  DETAIL
   cds->activity[d.seq].antenatal_gp_cd = cds->activity[d.seq].gp_code, cds->activity[d.seq].
   antenatal_gp_prac_cd = cds->activity[d.seq].gp_practice
   IF (ce3.event_cd=first_ant_asst_dt_cd
    AND trim(ce3.result_val,3) != " ")
    cds->activity[d.seq].first_antenatal_dt = cnvtdate2(substring(3,8,ce3.result_val),"YYYYMMDD")
   ENDIF
   IF (ce3.event_cd=num_prev_pregnancy_cd)
    IF (textlen(trim(ce3.result_val,3)) > 0)
     cds->activity[d.seq].previous_pregs_nbr = format(ce3.result_val,"##;P0")
    ENDIF
   ENDIF
   IF (ce3.event_cd=gest_at_birth_weeks_cd)
    cds->activity[d.seq].gest_len = ce3.result_val
   ENDIF
   IF (ce3.event_cd=baby_delivered_cd
    AND trim(ce3.result_val,3) != "")
    del_date = cnvtdate2(substring(3,8,ce3.result_val),"YYYYMMDD"), del_time = cnvtint(substring(11,4,
      ce3.result_val)), cds->activity[d.seq].delivery_date = cnvtdatetime(del_date,del_time)
   ENDIF
   IF (ce3.event_cd=num_babies_at_birth_cd)
    cds->activity[d.seq].number_of_babies = ce3.result_val
   ENDIF
   IF (ce3.event_cd=del_place_chg_reas_cd)
    cds->activity[d.seq].del_place_chg_reas = ccr_result
   ENDIF
   IF (ce3.event_cd=anes_during_labour_cd)
    cds->activity[d.seq].anes_during_del = ccr_result
   ENDIF
   IF (ce3.event_cd=anes_post_labour_cd)
    cds->activity[d.seq].anes_post_del = ccr_result
   ENDIF
   IF (ce3.event_cd=onset_of_labour_cd)
    cds->activity[d.seq].labor_onset_meth = ccr_result
   ENDIF
   IF (ce4.event_cd=int_del_loc_cd)
    cds->activity[d.seq].del_place_type = ccr4_result
   ENDIF
   IF (datetimediff(cnvtdatetime(cds->activity[d.seq].disch_date),cnvtdatetime(cds->activity[d.seq].
     adm_date),3) < 24)
    cds->activity[d.seq].pt_class = "5"
   ELSE
    cds->activity[d.seq].pt_class = "1"
   ENDIF
  FOOT  d.seq
   IF ((((cds->activity[d.seq].delivery_date BETWEEN cds->activity[d.seq].episode_start_dt AND cds->
   activity[d.seq].episode_end_dt)
    AND (cds->activity[d.seq].delivery_date > 0)) OR ((cds->activity[d.seq].delivery_date >= cds->
   activity[d.seq].episode_start_dt)
    AND (cds->activity[d.seq].episode_end_dt=0)
    AND (cds->activity[d.seq].delivery_date > 0))) )
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ELSEIF ((cds->activity[d.seq].delivery_date <= cds->activity[d.seq].episode_start_dt)
    AND (cds->activity[d.seq].con_epi_num=1)
    AND (cds->activity[d.seq].delivery_date > 0)
    AND datetimediff(cds->activity[d.seq].episode_start_dt,cds->activity[d.seq].delivery_date,1) <= 3
   )
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ELSEIF ((cds->activity[d.seq].delivery_date >= cds->activity[d.seq].episode_end_dt)
    AND (cds->activity[d.seq].last_episode_ind="1")
    AND (cds->activity[d.seq].delivery_date > 0)
    AND datetimediff(cds->activity[d.seq].delivery_date,cds->activity[d.seq].episode_end_dt,1) <= 3)
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ENDIF
  WITH nocounter, outerjoin = d1, orahint(" INDEX (CE FK10CLINICAL_EVENT)")
 ;end select
 CALL echo("Getting details about the babies")
 CALL echo("----------------------------------")
 SELECT INTO "nl:"
  sex = pm_get_cvo_alias(p.sex_cd,nhs_report_code), ei_result = pm_get_cvo_alias(ei.value_cd,
   nhs_report_code), ccr_result = pm_get_cvo_alias(ccr.result_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   person_person_reltn prr,
   encntr_alias ea2,
   person p,
   encounter e,
   encntr_info ei,
   encntr_alias ea,
   person_alias pa,
   person_patient pp,
   clinical_event ce3,
   ce_coded_result ccr,
   dummyt d1
  PLAN (d
   WHERE (cds->activity[d.seq].birth_flag=0)
    AND (cds->activity[d.seq].update_type="9")
    AND (cds->activity[d.seq].newh_mum_baby=0))
   JOIN (prr
   WHERE (prr.related_person_id=cds->activity[d.seq].person_id)
    AND prr.person_reltn_cd=mother_cd
    AND prr.person_reltn_type_cd=ppr_family_type_cd
    AND prr.active_ind=1)
   JOIN (ea2
   WHERE (ea2.alias=cds->activity[d.seq].spell_number)
    AND (ea2.encntr_id != cds->activity[d.seq].encntr_id)
    AND ea2.encntr_alias_type_cd=fin_nbr
    AND ea2.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ea2.encntr_id
    AND  EXISTS (
   (SELECT
    1
    FROM code_value cv
    WHERE cv.code_value=e.admit_type_cd
     AND cv.cdf_meaning IN ("URGENT", "NEWBORN"))))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.name_last_key != "ZZZ*")
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(cnn_cd))
    AND (ea.active_ind= Outerjoin(1)) )
   JOIN (pp
   WHERE (pp.person_id= Outerjoin(p.person_id)) )
   JOIN (ei
   WHERE ei.encntr_id=e.encntr_id
    AND ei.info_sub_type_cd IN (ei_subtype_pas_lsb_cd, ei_subtype_pas_adlt_cd, ei_subtype_pas_bn_cd,
   ei_subtype_pas_gllo_cd, ei_subtype_pas_sca_cd))
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(nhs_cd)) )
   JOIN (d1)
   JOIN (ce3
   WHERE ce3.encntr_id=ei.encntr_id
    AND ce3.event_cd IN (method_of_delivery_cd, resus_details_cd, delivery_person_status_cd,
   gest_at_birth_cd)
    AND  NOT (((ce3.result_status_cd+ 0) IN (ce_in_error_cd, ce_in_error_noview_cd,
   ce_in_error_nomut_cd, ce_cancelled_cd)))
    AND ce3.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (ccr
   WHERE (ccr.event_id= Outerjoin(ce3.event_id)) )
  ORDER BY d.seq, p.person_id, pp.birth_order
  HEAD d.seq
   baby_count = 0
  HEAD p.person_id
   baby_count += 1, stat = alterlist(cds->activity[d.seq].baby_details,baby_count)
  DETAIL
   cds->activity[d.seq].baby_details[baby_count].baby_loc_pat_id = cnvtalias(ea.alias,ea
    .alias_pool_cd), cds->activity[d.seq].baby_details[baby_count].baby_org_cd = cds->activity[d.seq]
   .patient_id_org, cds->activity[d.seq].baby_details[baby_count].baby_birth_date = p.birth_dt_tm
   IF (pp.birth_weight > 0.0)
    cds->activity[d.seq].baby_details[baby_count].baby_birth_wt = format(cnvtstring(pp.birth_weight),
     "####;P0")
   ELSE
    cds->activity[d.seq].baby_details[baby_count].baby_birth_wt = "9999"
   ENDIF
   cds->activity[d.seq].baby_details[baby_count].baby_birth_order = cnvtstring(pp.birth_order), cds->
   activity[d.seq].baby_details[baby_count].baby_sex = sex
   IF (ei.info_sub_type_cd=ei_subtype_pas_adlt_cd)
    cds->activity[d.seq].baby_details[baby_count].baby_del_place_type = ei_result
   ENDIF
   IF (ei.info_sub_type_cd=ei_subtype_pas_lsb_cd)
    cds->activity[d.seq].baby_details[baby_count].baby_live_still = ei_result
   ENDIF
   IF (ce3.event_cd=method_of_delivery_cd)
    cds->activity[d.seq].baby_details[baby_count].baby_del_method = ccr_result
   ENDIF
   IF (ce3.event_cd=resus_details_cd)
    cds->activity[d.seq].baby_details[baby_count].baby_resus_meth = ccr_result
   ENDIF
   IF (ce3.event_cd=delivery_person_status_cd)
    cds->activity[d.seq].baby_details[baby_count].baby_pers_cond_stat = ccr_result
   ENDIF
   IF (ce3.event_cd=gest_at_birth_cd)
    cds->activity[d.seq].baby_details[baby_count].baby_gest_length = ce3.result_val
   ENDIF
   cds->activity[d.seq].baby_details[baby_count].baby_nhs_num = pa.alias, cds->activity[d.seq].
   baby_details[baby_count].baby_nhs_stat = uar_get_code_meaning(pa.person_alias_status_cd)
   IF (((p.birth_dt_tm BETWEEN cnvtdatetime(cds->activity[d.seq].episode_start_dt) AND cnvtdatetime(
    cds->activity[d.seq].episode_end_dt)
    AND p.birth_dt_tm > 0) OR (p.birth_dt_tm >= cnvtdatetime(cds->activity[d.seq].episode_start_dt)
    AND cnvtdatetime(cds->activity[d.seq].episode_end_dt)=0
    AND p.birth_dt_tm > 0)) )
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ELSEIF (p.birth_dt_tm <= cnvtdatetime(cds->activity[d.seq].episode_start_dt)
    AND (cds->activity[d.seq].con_epi_num=1)
    AND p.birth_dt_tm > 0
    AND datetimediff(cds->activity[d.seq].episode_start_dt,cds->activity[d.seq].delivery_date,1) <= 3
   )
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ELSEIF (p.birth_dt_tm >= cnvtdatetime(cds->activity[d.seq].episode_end_dt)
    AND (cds->activity[d.seq].last_episode_ind="1")
    AND p.birth_dt_tm > 0
    AND datetimediff(cds->activity[d.seq].delivery_date,cds->activity[d.seq].episode_end_dt,1) <= 3)
    IF ((cds->activity[d.seq].episode_end_dt > 0))
     cds->activity[d.seq].cds_type = "140", cds->activity[d.seq].cds_type_cd = cds_140
    ELSE
     cds->activity[d.seq].cds_type = "200", cds->activity[d.seq].cds_type_cd = cds_200
    ENDIF
    cds->activity[d.seq].maternity_delivery_flag = 1
   ENDIF
   IF ((cds->activity[d.seq].baby_details[1].baby_del_place_type="1"))
    cds->activity[d.seq].cds_type = "160", cds->activity[d.seq].cds_type_cd = cds_160, cds->activity[
    d.seq].maternity_delivery_flag = 1
   ENDIF
   IF ((cds->activity[d.seq].delivery_date=0)
    AND p.birth_dt_tm = null)
    cds->activity[d.seq].maternity_delivery_flag = 9
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 CALL echo("Determining Patient Class and Record Errors")
 DECLARE abs_disch_date = q8 WITH public, noconstant
 DECLARE abs_adm_date = q8 WITH public, noconstant
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5)))
  PLAN (d)
  DETAIL
   IF ((cds->activity[d.seq].service_category_cd=0))
    cds->activity[d.seq].error_flag = 2, cds->activity[d.seq].error_string = build2(cds->activity[d
     .seq].error_string,",","Null Main Specialty")
   ENDIF
   IF ((cds->activity[d.seq].med_service_cd=0))
    cds->activity[d.seq].error_flag = 3, cds->activity[d.seq].error_string = build2(cds->activity[d
     .seq].error_string,",","Null Treatment Function")
   ENDIF
   IF ((((cds->activity[d.seq].adm_date > cds->activity[d.seq].disch_date)
    AND (cds->activity[d.seq].disch_date > 0)) OR ((cds->activity[d.seq].adm_date=0))) )
    cds->activity[d.seq].error_flag = 5, cds->activity[d.seq].error_string = build2(cds->activity[d
     .seq].error_string,",","Adm > Disch")
   ENDIF
   IF (trim(cds->activity[d.seq].cds_type,3)=" ")
    cds->activity[d.seq].error_flag = 9, cds->activity[d.seq].error_string = build2(cds->activity[d
     .seq].error_string,",","Null CDS Type")
   ENDIF
   IF ((cds->activity[d.seq].disch_date=0))
    cds->activity[d.seq].pt_class = "1"
   ELSEIF ( NOT ((cds->activity[d.seq].encntr_type IN (reg_night_type, reg_day_type))))
    abs_disch_date = cnvtdatetime(cnvtdate(cds->activity[d.seq].disch_date),0), abs_adm_date =
    cnvtdatetime(cnvtdate(cds->activity[d.seq].adm_date),0)
    IF (datetimecmp(abs_disch_date,abs_adm_date)=0)
     IF ((cds->activity[d.seq].adm_method IN ("11", "12", "13")))
      IF ((cds->activity[d.seq].intend_management IN (" ", "2")))
       cds->activity[d.seq].pt_class = "2"
      ELSEIF ((cds->activity[d.seq].intend_management="4"))
       cds->activity[d.seq].pt_class = "3"
      ELSE
       cds->activity[d.seq].pt_class = "1"
      ENDIF
     ELSEIF ((cds->activity[d.seq].adm_method IN ("31", "32", "82", "83"))
      AND (((cds->activity[d.seq].maternity_delivery_flag=1)) OR ((cds->activity[d.seq].birth_flag=1)
     )) )
      IF (trim(cds->activity[d.seq].start_loc_nurse_unit,3)="Delivery Suite"
       AND trim(cds->activity[d.seq].end_loc_nurse_unit,3)="Delivery Suite")
       cds->activity[d.seq].pt_class = "5"
      ELSE
       cds->activity[d.seq].pt_class = "1"
      ENDIF
     ELSE
      cds->activity[d.seq].pt_class = "1"
     ENDIF
    ELSE
     IF ((cds->activity[d.seq].intend_management="5"))
      cds->activity[d.seq].pt_class = "4"
     ELSE
      cds->activity[d.seq].pt_class = "1"
     ENDIF
    ENDIF
   ELSEIF ((cds->activity[d.seq].encntr_type IN (reg_night_type, reg_day_type)))
    abs_disch_date = cnvtdatetime(cnvtdate(cds->activity[d.seq].disch_date),0), abs_adm_date =
    cnvtdatetime(cnvtdate(cds->activity[d.seq].adm_date),0)
    IF (datetimecmp(abs_disch_date,abs_adm_date)=0)
     IF ((cds->activity[d.seq].adm_method="13"))
      cds->activity[d.seq].pt_class = "3"
     ELSEIF ((cds->activity[d.seq].adm_method IN ("11", "12")))
      cds->activity[d.seq].pt_class = "2"
     ELSE
      cds->activity[d.seq].pt_class = "1"
     ENDIF
    ELSEIF (datetimecmp(abs_disch_date,abs_adm_date)=1)
     IF ((cds->activity[d.seq].adm_method="13"))
      cds->activity[d.seq].pt_class = "4"
     ELSE
      cds->activity[d.seq].pt_class = "1"
     ENDIF
    ELSE
     cds->activity[d.seq].pt_class = "1"
    ENDIF
   ENDIF
  WITH nocounter
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
 IF (validate(psycds->census,0)=1)
  SET last_mod = "159212"
  DECLARE dcl_rename_cmd = vc WITH protect
  DECLARE rename_cmd = vc WITH protect
  DECLARE dcl_size = i4 WITH protect
  DECLARE write_status = i4 WITH protect, noconstant(0)
  DECLARE cdsoutdir_dcl = vc WITH public
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
   SET cdsoutdir = concat("user01:[cdsfiles.",trim(currdbname,3),".sus]")
   SET rename_cmd = "rename"
   IF (findfile(cdsoutdir)=0)
    SET cdsoutdir = "ccluserdir:"
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   nextseqnum = seq(aar_report_seq,nextval)
   FROM dual
   DETAIL
    cds->unfinished_file = concat(trim(cdsoutdir,3),"CDS_MHC","_",trim(cdsbatch->org_code,3),"_",
     trim(format(nextseqnum,"######################"),3),"_","U","_",trim(cnvtstring(cdsbatch->batch[
       rcnt].cds_batch_id),3),
     "_",trim(format(cnvtdatetime(sysdate),"YYMMDD;;d"),3),".tmp")
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   nextseqnum = seq(aar_report_seq,nextval)
   FROM dual
   DETAIL
    cds->exception_file = concat(trim(cdsoutdir,3),"CDS_MHC_",trim(cdsbatch->org_code,3),"_",trim(
      format(nextseqnum,"######################"),3),
     "_","E","_",trim(cnvtstring(cdsbatch->batch[rcnt].cds_batch_id),3),"_",
     trim(format(cnvtdatetime(sysdate),"YYMMDD;;d"),3),".tmp")
   WITH nocounter
  ;end select
  IF (cdsoutdir_dcl != "$CCLUSERDIR/")
   SET cdsoutdir_dcl = trim(cdsoutdir)
  ENDIF
  SET ztotal = size(cds->activity,5)
  FOR (fsize = 1 TO size(cds->activity,5))
    IF ((cds->activity[fsize].error_flag=0))
     SET sfile = cds->unfinished_file
    ELSE
     SET sfile = cds->exception_file
    ENDIF
    SELECT INTO value(sfile)
     fsize
     FROM (dummyt d  WITH seq = value(1))
     PLAN (d)
     DETAIL
      col 0,
      CALL print(trim(cds->activity[fsize].cds_type,3)),
      CALL echo(build("cds type->",cds->activity[fsize].cds_type)),
      col 03,
      CALL print(trim(cds->activity[fsize].bulk_repl_cds_gp,3)), col 06,
      CALL print(trim(cds->activity[fsize].test_ind,3)), col 07,
      CALL print(trim(cds->activity[fsize].protocol_id,3)),
      col 10,
      CALL print(trim(cds->activity[fsize].unique_cds_id,3)), col 45,
      CALL print(trim(cds->activity[fsize].update_type,3)), col 46, cds->activity[fsize].
      extract_dt_time"YYYYMMDD;;d",
      col 54, cds->activity[fsize].extract_dt_time"HHMMSS;3;M", col 60,
      cds->activity[fsize].extract_dt_time"YYYYMMDD;;d", col 68, cds->activity[fsize].extract_dt_time
      "HHMMSS;3;M",
      col 74, cds->activity[fsize].period_start_dt"YYYYMMDD;;d", col 82,
      cds->activity[fsize].period_end_dt"YYYYMMDD;;d", col 90, cds->activity[fsize].census_dt
      "YYYYMMDD;;d",
      col 98,
      CALL print(trim(cds->activity[fsize].sender_identity,3)), col 103,
      "B", col 104,
      CALL print(trim(cds->activity[fsize].primary_recip,3)),
      col 109, "B", col 110,
      CALL print(trim(cds->activity[fsize].copy_1,3)), col 115, "B",
      col 116,
      CALL print(trim(cds->activity[fsize].copy_2,3)), col 121,
      "B", col 122,
      CALL print(trim(cds->activity[fsize].copy_3,3)),
      col 127, "B", col 128,
      CALL print(trim(cds->activity[fsize].copy_4,3)), col 133, "B",
      col 134,
      CALL print(trim(cds->activity[fsize].copy_5,3)), col 139,
      "B", col 140,
      CALL print(trim(cds->activity[fsize].copy_6,3)),
      col 145, "B", col 146,
      CALL print(trim(cds->activity[fsize].copy_7,3)), col 151, "B",
      col 152,
      CALL print(trim(cds->activity[fsize].local_patient_id,3)), col 162,
      CALL print(trim(cds->activity[fsize].patient_id_org,3)), col 167, "B",
      col 168,
      CALL print(trim(cds->activity[fsize].nhs_number,3)), col 178,
      cds->activity[fsize].birth_dt"YYYYMMDD;;d", col 186,
      CALL print(trim(cds->activity[fsize].carer_support_ind,3)),
      col 188,
      CALL print(trim(cds->activity[fsize].ethnic_group,3)), col 190,
      CALL print(trim(cds->activity[fsize].marital_status,3))
      IF (trim(cds->activity[fsize].alias_status,3)=" ")
       cds->activity[fsize].alias_status = "03"
      ENDIF
      col 191,
      CALL print(trim(cds->activity[fsize].alias_status,3)), col 193,
      CALL print(trim(cds->activity[fsize].sex,3)), col 194,
      CALL print(trim(cds->activity[fsize].legal_class_on_adm,3)),
      col 196,
      CALL print(trim(cds->activity[fsize].legal_class_on_cen_dt,3)), col 198,
      cds->activity[fsize].date_detention_commenced"YYYYMMDD;;d", col 206,
      CALL print(trim(cds->activity[fsize].age_census,3)),
      col 209,
      CALL print(trim(cds->activity[fsize].dur_of_care_psych_cen_dt,3)), col 214,
      CALL print(trim(cds->activity[fsize].dur_detention,3))
      IF (trim(cds->activity[fsize].mental_category,3)=" ")
       cds->activity[fsize].mental_category = "8"
      ENDIF
      col 219,
      CALL print(trim(cds->activity[fsize].mental_category,3)), col 220,
      CALL print(trim(cds->activity[fsize].psych_cen_pat_status,3))
      IF ((cds->activity[fsize].anonymous != 1))
       col 221,
       CALL print(trim(cds->activity[fsize].name_format_ind,3)), col 222,
       CALL print(trim(cds->activity[fsize].patient_forename,3)), col 257,
       CALL print(trim(cds->activity[fsize].patient_surname,3)),
       col 292,
       CALL print(trim(cds->activity[fsize].pt_address_format_cd,3)), col 293,
       CALL print(trim(cds->activity[fsize].pt_address_1,3)), col 328,
       CALL print(trim(cds->activity[fsize].pt_address_2,3)),
       col 363,
       CALL print(trim(cds->activity[fsize].pt_address_3,3)), col 398,
       CALL print(trim(cds->activity[fsize].pt_address_4,3)), col 433,
       CALL print(trim(cds->activity[fsize].pt_address_5,3))
      ENDIF
      IF (trim(cds->activity[fsize].pt_post_code,3)=" ")
       cds->activity[fsize].pt_post_code = d_not_known_postcode
      ENDIF
      col 468,
      CALL print(trim(cds->activity[fsize].pt_post_code,3)), col 476,
      CALL print(trim(cds->activity[fsize].residence_pct,3)), col 481, "B",
      col 482,
      CALL print(trim(cds->activity[fsize].spell_number,3))
      IF (trim(cds->activity[fsize].admin_category,3)=" ")
       cds->activity[fsize].admin_category = "99"
      ENDIF
      col 494,
      CALL print(trim(cds->activity[fsize].admin_category,3)), col 496,
      CALL print(trim(cds->activity[fsize].adm_method,3)), col 498,
      CALL print(trim(cds->activity[fsize].pt_class,3))
      IF (trim(cds->activity[fsize].adm_method,3)=" ")
       cds->activity[fsize].adm_method = "99"
      ENDIF
      col 499,
      CALL print(trim(cds->activity[fsize].adm_source,3)), col 501,
      cds->activity[fsize].adm_date"YYYYMMDD;;d", col 509,
      CALL print(trim(cds->activity[fsize].episode_ct,3))
      IF (trim(cds->activity[fsize].psych_status_ind,3)=" ")
       cds->activity[fsize].psych_status_ind = "8"
      ENDIF
      col 511,
      CALL print(trim(cds->activity[fsize].psych_status_ind,3)), col 512,
      cds->activity[fsize].episode_start_dt"YYYYMMDD;;d", col 520,
      CALL print(trim(cds->activity[fsize].comm_ser_nbr,3)),
      col 526,
      CALL print(trim(cds->activity[fsize].nhs_svc_agr_line_nbr,3)), col 536,
      CALL print(trim(cds->activity[fsize].prov_ref_nbr,3)), col 553,
      CALL print(trim(cds->activity[fsize].comm_ref_nbr,3)),
      col 570,
      CALL print(trim(cds->activity[fsize].org_cd_prov,3)), col 575,
      "B", col 576,
      CALL print(trim(cds->activity[fsize].org_cd_comm,3)),
      col 581, "B"
      IF (trim(cds->activity[fsize].consultant_code,3)=" ")
       cds->activity[fsize].consultant_code = "C9999998"
      ENDIF
      col 582,
      CALL print(trim(cds->activity[fsize].consultant_code,3)), col 590,
      CALL print(trim(cds->activity[fsize].main_specialty_code,3)), col 593,
      CALL print(trim(cds->activity[fsize].treatment_function_code,3)),
      col 596, "02", col 598,
      CALL print(trim(cds->activity[fsize].primary_icd,3)), col 604,
      CALL print(trim(cds->activity[fsize].icd_cd1,3)),
      col 609,
      CALL print(trim(cds->activity[fsize].icd_cd2,3)), col 616,
      CALL print(trim(cds->activity[fsize].icd_cd3,3)), col 622,
      CALL print(trim(cds->activity[fsize].icd_cd4,3)),
      col 628,
      CALL print(trim(cds->activity[fsize].icd_cd5,3)), col 634,
      CALL print(trim(cds->activity[fsize].icd_cd6,3)), col 640,
      CALL print(trim(cds->activity[fsize].icd_cd7,3)),
      col 646,
      CALL print(trim(cds->activity[fsize].icd_cd8,3)), col 652,
      CALL print(trim(cds->activity[fsize].icd_cd9,3)), col 658,
      CALL print(trim(cds->activity[fsize].icd_cd10,3)),
      col 664,
      CALL print(trim(cds->activity[fsize].icd_cd11,3)), col 670,
      CALL print(trim(cds->activity[fsize].icd_cd12,3)), col 769,
      CALL print(trim(cds->activity[fsize].start_site_cd,3)),
      col 774, "B", col 775,
      CALL print(trim(cds->activity[fsize].start_age_group_intend,3)), col 776,
      CALL print(trim(cds->activity[fsize].start_intensity_intend,3)),
      col 778,
      CALL print(trim(cds->activity[fsize].start_sex_of_patients,3)), col 779,
      CALL print(trim(cds->activity[fsize].start_ward_night_avail,3)), col 780,
      CALL print(trim(cds->activity[fsize].start_ward_day_avail,3)),
      fsize2 = size(cds->activity[fsize].ward_stay_details,5)
      IF (fsize2 > 0)
       col 781,
       CALL print(trim(cds->activity[fsize].ward_stay_details[fsize2].treatment_site_cd,3)), col 786,
       "B", col 787,
       CALL print(trim(cds->activity[fsize].ward_stay_details[fsize2].age_group_intend,3)),
       col 788,
       CALL print(trim(cds->activity[fsize].ward_stay_details[fsize2].intensity_intend,3)), col 790,
       CALL print(trim(cds->activity[fsize].ward_stay_details[fsize2].sex_of_patients,3)), col 791,
       CALL print(trim(cds->activity[fsize].ward_stay_details[fsize2].ward_night_avail,3)),
       col 792,
       CALL print(trim(cds->activity[fsize].ward_stay_details[fsize2].ward_day_avail,3)), col 793,
       cds->activity[fsize].det_long_term_psych_cen_dt"YYYYMMDD;;d"
      ENDIF
      IF (trim(cds->activity[fsize].gp_code,3)=" ")
       cds->activity[fsize].gp_code = "G9999981"
      ENDIF
      col 801,
      CALL print(trim(cds->activity[fsize].gp_code,3))
      IF (trim(cds->activity[fsize].gp_practice,3)=" ")
       cds->activity[fsize].gp_practice = "V81999"
      ENDIF
      col 809,
      CALL print(trim(cds->activity[fsize].gp_practice,3)), col 815,
      "B"
      IF (trim(cds->activity[fsize].referrer_cd,3)=" ")
       cds->activity[fsize].referrer_cd = "X9999998"
      ENDIF
      col 816,
      CALL print(trim(cds->activity[fsize].referrer_cd,3))
      IF (trim(cds->activity[fsize].referrer_org_cd,3)=" ")
       cds->activity[fsize].referrer_org_cd = "X99998"
      ENDIF
      col 824,
      CALL print(trim(cds->activity[fsize].referrer_org_cd,3)), col 830,
      "B", col 831,
      CALL print(trim(cds->activity[fsize].wait_duration,3)),
      col 835,
      CALL print(trim(cds->activity[fsize].intend_management,3)), col 836,
      cds->activity[fsize].decision_admit_date"YYYYMMDD;;d", col 844,
      CALL print(trim(cds->activity[fsize].hrg_code,3)),
      col 847,
      CALL print(trim(cds->activity[fsize].hrg_version,3)), col 850,
      "02", col 852,
      CALL print(trim(cds->activity[fsize].hrg_dgvp_opcs,3))
      IF (trim(cds->activity[fsize].local_subspecialty,3) != "")
       col 856,
       CALL print(trim(cds->activity[fsize].local_subspecialty,3))
      ENDIF
     WITH nocounter, format = stream, maxcol = 3600,
      append, maxrow = 1, formfeed = none
    ;end select
    CALL echo(build2("Record->",trim(cnvtstring(fsize),3)," of ",trim(cnvtstring(ztotal),3)))
    SET cdsbatch->batch[rcnt].content[fsize].cds_type_cd = cds->activity[fsize].cds_type_cd
  ENDFOR
  IF (findfile(cds->unfinished_file)=1)
   SET cds->unfinished_file = replace(cds->unfinished_file,cdsoutdir,cdsoutdir_dcl,1)
   SET dcl_rename_cmd = cnvtlower(build2(rename_cmd," ",trim(cds->unfinished_file)," ",substring(1,(
      textlen(trim(cds->unfinished_file)) - 3),cds->unfinished_file),
     "txt"))
   SET dcl_size = textlen(dcl_rename_cmd)
   CALL dcl(dcl_rename_cmd,dcl_size,write_status)
  ENDIF
  IF (findfile(cds->exception_file)=1)
   SET cds->exception_file = replace(cds->exception_file,cdsoutdir,cdsoutdir_dcl,1)
   SET dcl_rename_cmd = cnvtlower(build2(rename_cmd," ",trim(cds->exception_file)," ",substring(1,(
      textlen(trim(cds->exception_file)) - 3),cds->exception_file),
     "txt"))
   SET dcl_size = textlen(dcl_rename_cmd)
   CALL dcl(dcl_rename_cmd,dcl_size,write_status)
  ENDIF
  SET cds->unfinished_file = build(substring(1,(textlen(trim(cds->unfinished_file)) - 3),cds->
    unfinished_file),"txt")
  IF (trim(cdsbatch->batch[rcnt].filename,3)=" ")
   SET cdsbatch->batch[rcnt].filename = replace(cds->unfinished_file,cdsoutdir,"",1)
  ENDIF
  CALL echo(build("Filename from create->",cdsbatch->batch[rcnt].filename))
  CALL echo(build2("updating: ",cds->activity[(fsize - 1)].cds_batch_content_id))
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
  CALL echo("Table Updates")
  IF ((cdsbatch->testmode=0))
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
  CALL echo(build("Filename from create->",cdsbatch->batch[rcnt].filename))
  CALL echo(cdsoutdir)
  CALL echo(cds->unfinished_file)
 ELSE
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
   SET cdsoutdir = concat("user01:[cdsfiles.",trim(currdbname,3),".sus]")
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
    cds->finished_file = concat(trim(cdsoutdir,3),"CDS_APC","_",trim(cdsbatch->org_code,3),"_",
     trim(format(nextseqnum,"######################"),3),"_","F","_",trim(cnvtstring(cdsbatch->batch[
       rcnt].cds_batch_id),3),
     "_",trim(format(cnvtdatetime(sysdate),"YYMMDD;;d"),3),".tmp")
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   nextseqnum = seq(aar_report_seq,nextval)
   FROM dual
   DETAIL
    cds->unfinished_file = concat(trim(cdsoutdir,3),"CDS_APC","_",trim(cdsbatch->org_code,3),"_",
     trim(format(nextseqnum,"######################"),3),"_","U","_",trim(cnvtstring(cdsbatch->batch[
       rcnt].cds_batch_id),3),
     "_",trim(format(cnvtdatetime(sysdate),"YYMMDD;;d"),3),".tmp")
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   nextseqnum = seq(aar_report_seq,nextval)
   FROM dual
   DETAIL
    cds->exception_file = concat(trim(cdsoutdir,3),"CDS_APC","_",trim(cdsbatch->org_code,3),"_",
     trim(format(nextseqnum,"######################"),3),"_","E","_",trim(cnvtstring(cdsbatch->batch[
       rcnt].cds_batch_id),3),
     "_",trim(format(cnvtdatetime(sysdate),"YYMMDD;;d"),3),".tmp")
   WITH nocounter
  ;end select
  SET ztotal = size(cds->activity,5)
  IF ((cdsbatch->file_format="5"))
   SET last_mod = "159212"
   DECLARE emptystring = c1 WITH protect, constant(" ")
   DECLARE orgtypecodedef = c1 WITH protect, constant("B")
   DECLARE orgtypecodeout = c1 WITH protect
   DECLARE diagscheme = c2 WITH protect, constant("02")
   DECLARE procscheme = c2 WITH protect, constant("02")
   DECLARE locationclassdef = c2 WITH protect, constant("01")
   DECLARE augcaresize = i4 WITH protect
   DECLARE otherdiagicd = c72 WITH protect
   DECLARE otherprocopcs = c132 WITH protect
   DECLARE locdetailsone = c28 WITH protect
   DECLARE locdetailst2 = c28 WITH protect
   DECLARE locdetailst3 = c28 WITH protect
   DECLARE locdetailst4 = c28 WITH protect
   DECLARE locdetailst5 = c28 WITH protect
   DECLARE locdetailst6 = c28 WITH protect
   DECLARE locdetailst7 = c28 WITH protect
   DECLARE locdetailst8 = c28 WITH protect
   DECLARE locdetailst9 = c28 WITH protect
   DECLARE templocdetails = c28 WITH protect
   DECLARE locdetailsother = c224 WITH protect
   DECLARE criticalcareone = c101 WITH protect
   DECLARE criticalcareother = c808 WITH protect
   DECLARE birthdetailsone = c51 WITH protect
   DECLARE tempbirthdetails = c19 WITH protect
   DECLARE tempdeliverydetails = c32 WITH protect
   DECLARE birthdetailst2 = c51 WITH protect
   DECLARE birthdetailst3 = c51 WITH protect
   DECLARE birthdetailst4 = c51 WITH protect
   DECLARE birthdetailst5 = c51 WITH protect
   DECLARE birthdetailst6 = c51 WITH protect
   DECLARE birthdetailst7 = c51 WITH protect
   DECLARE birthdetailst8 = c51 WITH protect
   DECLARE birthdetailst9 = c51 WITH protect
   DECLARE birthdetailsother = c408 WITH protect
   DECLARE augcare1 = c57 WITH protect
   DECLARE augcare2 = c57 WITH protect
   DECLARE augcare3 = c57 WITH protect
   DECLARE augcare4 = c57 WITH protect
   DECLARE augcare5 = c57 WITH protect
   DECLARE augcare6 = c57 WITH protect
   DECLARE augcare7 = c57 WITH protect
   DECLARE augcare8 = c57 WITH protect
   DECLARE augcare9 = c57 WITH protect
   DECLARE tempaugcare = c57 WITH protect
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
   DECLARE orgtypecode17 = c1 WITH protect
   DECLARE orgtypecode18 = c1 WITH protect
   DECLARE orgtypecode19 = c1 WITH protect
   DECLARE orgtypecode20 = c1 WITH protect
   DECLARE locationclass = c2 WITH protect
   FOR (fsize = 1 TO size(cds->activity,5))
     IF (trim(cds->activity[fsize].alias_status,3)=" ")
      SET cds->activity[fsize].alias_status = "03"
     ENDIF
     IF (trim(cds->activity[fsize].legal_classification,3)=" ")
      SET cds->activity[fsize].legal_classification = "98"
     ENDIF
     IF (trim(cds->activity[fsize].pt_post_code,3)=" ")
      SET cds->activity[fsize].pt_post_code = d_not_known_postcode
     ENDIF
     IF (trim(cds->activity[fsize].consultant_code,3)=" ")
      SET cds->activity[fsize].consultant_code = "C9999998"
     ENDIF
     IF (trim(cds->activity[fsize].residence_pct,3)=" ")
      SET cds->activity[fsize].residence_pct = "Q9900"
     ENDIF
     IF (trim(cds->activity[fsize].admin_category,3)=" ")
      SET cds->activity[fsize].admin_category = "99"
     ENDIF
     IF (trim(cds->activity[fsize].adm_method,3)=" ")
      SET cds->activity[fsize].adm_method = "99"
     ENDIF
     IF (trim(cds->activity[fsize].disch_dest,3)=" ")
      SET cds->activity[fsize].disch_dest = "98"
     ENDIF
     IF (trim(cds->activity[fsize].disch_method,3)=" ")
      SET cds->activity[fsize].disch_method = "8"
     ENDIF
     IF ((cds->activity[fsize].encntr_type=newborn_type)
      AND trim(cds->activity[fsize].neonatal_care_lvl,3)=" ")
      SET cds->activity[fsize].neonatal_care_lvl = "9"
     ELSEIF ((cds->activity[fsize].encntr_type != newborn_type))
      SET cds->activity[fsize].neonatal_care_lvl = "8"
     ENDIF
     IF (trim(cds->activity[fsize].operation_status_ind,3)=" ")
      SET cds->activity[fsize].operation_status_ind = "9"
     ENDIF
     IF (trim(cds->activity[fsize].psych_status_ind,3)=" ")
      SET cds->activity[fsize].psych_status_ind = "8"
     ENDIF
     IF (trim(cds->activity[fsize].consultant_code,3)=" ")
      SET cds->activity[fsize].consultant_code = "C9999998"
     ENDIF
     IF (trim(cds->activity[fsize].gp_code,3)=" ")
      SET cds->activity[fsize].gp_code = "G9999981"
     ENDIF
     IF (trim(cds->activity[fsize].gp_practice,3)=" ")
      SET cds->activity[fsize].gp_practice = "V81999"
     ENDIF
     IF (trim(cds->activity[fsize].referrer_cd,3)=" ")
      SET cds->activity[fsize].referrer_cd = "X9999998"
     ENDIF
     IF (trim(cds->activity[fsize].referrer_org_cd,3)=" ")
      SET cds->activity[fsize].referrer_org_cd = "X99998"
     ENDIF
     IF (trim(cds->activity[fsize].mom_post_cd,3)=" "
      AND trim(cds->activity[fsize].mom_address_1,3) != " ")
      SET cds->activity[fsize].mom_post_cd = d_not_known_postcode
     ENDIF
     IF (trim(cds->activity[fsize].mom_pct,3)=" "
      AND trim(cds->activity[fsize].mom_address_1,3) != " ")
      SET cds->activity[fsize].mom_pct = "Q9900"
     ENDIF
     IF ((cds->activity[fsize].anonymous=1))
      SET cds->activity[fsize].name_format_ind = ""
      SET cds->activity[fsize].patient_forename = ""
      SET cds->activity[fsize].patient_surname = ""
      SET cds->activity[fsize].pt_address_format_cd = ""
      SET cds->activity[fsize].pt_address_1 = ""
      SET cds->activity[fsize].pt_address_2 = ""
      SET cds->activity[fsize].pt_address_3 = ""
      SET cds->activity[fsize].pt_address_4 = ""
      SET cds->activity[fsize].pt_address_5 = ""
     ENDIF
     SET otherdiagicd = concat(cds->activity[fsize].icd_cd1,cds->activity[fsize].icd_cd2,cds->
      activity[fsize].icd_cd3,cds->activity[fsize].icd_cd4,cds->activity[fsize].icd_cd5,
      cds->activity[fsize].icd_cd6,cds->activity[fsize].icd_cd7,cds->activity[fsize].icd_cd8,cds->
      activity[fsize].icd_cd9,cds->activity[fsize].icd_cd10,
      cds->activity[fsize].icd_cd11,cds->activity[fsize].icd_cd12)
     SET otherprocopcs = concat(substring(1,4,cds->activity[fsize].opcs4_cd2),format(cds->activity[
       fsize].opcs4_date2,"YYYYMMDD;;D"),substring(1,4,cds->activity[fsize].opcs4_cd3),format(cds->
       activity[fsize].opcs4_date3,"YYYYMMDD;;D"),substring(1,4,cds->activity[fsize].opcs4_cd4),
      format(cds->activity[fsize].opcs4_date4,"YYYYMMDD;;D"),substring(1,4,cds->activity[fsize].
       opcs4_cd5),format(cds->activity[fsize].opcs4_date5,"YYYYMMDD;;D"),substring(1,4,cds->activity[
       fsize].opcs4_cd6),format(cds->activity[fsize].opcs4_date6,"YYYYMMDD;;D"),
      substring(1,4,cds->activity[fsize].opcs4_cd7),format(cds->activity[fsize].opcs4_date7,
       "YYYYMMDD;;D"),substring(1,4,cds->activity[fsize].opcs4_cd8),format(cds->activity[fsize].
       opcs4_date8,"YYYYMMDD;;D"),substring(1,4,cds->activity[fsize].opcs4_cd9),
      format(cds->activity[fsize].opcs4_date9,"YYYYMMDD;;D"),substring(1,4,cds->activity[fsize].
       opcs4_cd10),format(cds->activity[fsize].opcs4_date10,"YYYYMMDD;;D"),substring(1,4,cds->
       activity[fsize].opcs4_cd11),format(cds->activity[fsize].opcs4_date11,"YYYYMMDD;;D"),
      substring(1,4,cds->activity[fsize].opcs4_cd12),format(cds->activity[fsize].opcs4_date12,
       "YYYYMMDD;;D"))
     SET locdetailsone = " "
     SET locdetailst2 = " "
     SET locdetailst3 = " "
     SET locdetailst4 = " "
     SET locdetailst5 = " "
     SET locdetailst6 = " "
     SET locdetailst7 = " "
     SET locdetailst8 = " "
     SET locdetailst9 = " "
     SET locdetailsother = " "
     SET templocdetails = " "
     SET locdetailscnt = size(cds->activity[fsize].ward_stay_details,5)
     IF (locdetailscnt > 0)
      IF (locdetailscnt > 9)
       SET locdetailscnt = 9
      ENDIF
      FOR (cnt = 1 TO locdetailscnt)
        IF (trim(cds->activity[fsize].ward_stay_details[cnt].treatment_site_cd,3) != " ")
         SET orgtypecodeout = orgtypecodedef
        ELSE
         SET orgtypecodeout = " "
        ENDIF
        SET templocdetails = concat(format(cds->activity[fsize].ward_stay_details[cnt].
          treatment_site_cd,"#####"),format(orgtypecodeout,"#"),format(cds->activity[fsize].
          ward_stay_details[cnt].age_group_intend,"#"),format(cds->activity[fsize].ward_stay_details[
          cnt].intensity_intend,"##"),format(cds->activity[fsize].ward_stay_details[cnt].
          sex_of_patients,"#"),
         format(cds->activity[fsize].ward_stay_details[cnt].ward_night_avail,"#"),format(cds->
          activity[fsize].ward_stay_details[cnt].ward_day_avail,"#"),format(cds->activity[fsize].
          ward_stay_details[cnt].ward_start_date,"YYYYMMDD;;D"),format(cds->activity[fsize].
          ward_stay_details[cnt].ward_end_date,"YYYYMMDD;;D"))
        CASE (cnt)
         OF 1:
          SET locdetailsone = templocdetails
         OF 2:
          SET locdetailst2 = templocdetails
         OF 3:
          SET locdetailst3 = templocdetails
         OF 4:
          SET locdetailst4 = templocdetails
         OF 5:
          SET locdetailst5 = templocdetails
         OF 6:
          SET locdetailst6 = templocdetails
         OF 7:
          SET locdetailst7 = templocdetails
         OF 8:
          SET locdetailst8 = templocdetails
         OF 9:
          SET locdetailst9 = templocdetails
        ENDCASE
      ENDFOR
     ENDIF
     SET locdetailsother = concat(locdetailst2,locdetailst3,locdetailst4,locdetailst5,locdetailst6,
      locdetailst7,locdetailst8,locdetailst9)
     SET birthdetailsone = " "
     SET birthdetailsother = " "
     SET birthdetailst2 = " "
     SET birthdetailst3 = " "
     SET birthdetailst4 = " "
     SET birthdetailst5 = " "
     SET birthdetailst6 = " "
     SET birthdetailst7 = " "
     SET birthdetailst8 = " "
     SET birthdetailst9 = " "
     SET birthdetailscnt = size(cds->activity[fsize].baby_details,5)
     IF (birthdetailscnt > 0)
      IF (birthdetailscnt > 9)
       SET birthdetailscnt = 9
      ENDIF
      FOR (cnt = 1 TO birthdetailscnt)
        SET tempbirthdetails = emptystring
        SET tempdeliverydetails = emptystring
        SET tempbirthdetails = concat(format(cds->activity[fsize].baby_details[cnt].baby_birth_order,
          "#"),format(cds->activity[fsize].baby_details[cnt].baby_del_method,"#"),format(cds->
          activity[fsize].baby_details[cnt].baby_gest_length,"##"),format(cds->activity[fsize].
          baby_details[cnt].baby_resus_meth,"#"),format(cds->activity[fsize].baby_details[cnt].
          baby_pers_cond_stat,"#"),
         format("03","##"),format(cds->activity[fsize].baby_details[cnt].baby_del_place_type,"#"),
         format(cds->activity[fsize].baby_details[cnt].baby_loc_pat_id,"##########"))
        IF ((cds->activity[fsize].cds_type_cd IN (cds_140, cds_160, cds_200)))
         IF (trim(cds->activity[fsize].baby_details[cnt].baby_org_cd,3) != " ")
          SET orgtypecodeout = orgtypecodedef
         ELSE
          SET orgtypecodeout = " "
         ENDIF
         SET tempdeliverydetails = concat(format(cds->activity[fsize].baby_details[cnt].baby_org_cd,
           "#####"),format(orgtypecodeout,"#"),format(cds->activity[fsize].baby_details[cnt].
           baby_nhs_num,"##########"),format(cds->activity[fsize].baby_details[cnt].baby_nhs_stat,
           "##"),format(cds->activity[fsize].baby_details[cnt].baby_birth_date,"YYYYMMDD;;D"),
          format(cds->activity[fsize].baby_details[cnt].baby_birth_wt,"####"),format(cds->activity[
           fsize].baby_details[cnt].baby_live_still,"#"),format(cds->activity[fsize].baby_details[cnt
           ].baby_sex,"#"))
        ELSE
         SET tempdeliverydetails = format(emptystring,"################################")
        ENDIF
        CASE (cnt)
         OF 1:
          SET birthdetailsone = concat(tempbirthdetails,tempdeliverydetails)
         OF 2:
          SET birthdetailst2 = concat(tempbirthdetails,tempdeliverydetails)
         OF 3:
          SET birthdetailst3 = concat(tempbirthdetails,tempdeliverydetails)
         OF 4:
          SET birthdetailst4 = concat(tempbirthdetails,tempdeliverydetails)
         OF 5:
          SET birthdetailst5 = concat(tempbirthdetails,tempdeliverydetails)
         OF 6:
          SET birthdetailst6 = concat(tempbirthdetails,tempdeliverydetails)
         OF 7:
          SET birthdetailst7 = concat(tempbirthdetails,tempdeliverydetails)
         OF 8:
          SET birthdetailst8 = concat(tempbirthdetails,tempdeliverydetails)
         OF 9:
          SET birthdetailst9 = concat(tempbirthdetails,tempdeliverydetails)
        ENDCASE
      ENDFOR
     ENDIF
     SET birthdetailsother = concat(birthdetailst2,birthdetailst3,birthdetailst4,birthdetailst5,
      birthdetailst6,
      birthdetailst7,birthdetailst8,birthdetailst9)
     SET augcare1 = " "
     SET augcare2 = " "
     SET augcare3 = " "
     SET augcare4 = " "
     SET augcare5 = " "
     SET augcare6 = " "
     SET augcare7 = " "
     SET augcare8 = " "
     SET augcare9 = " "
     SET tempaugcare = " "
     SET augcaresize = size(cds->activity[fsize].augmented_care_details,5)
     IF (augcaresize > 0)
      IF (augcaresize > 9)
       SET augcaresize = 9
      ENDIF
      FOR (cnt = 1 TO augcaresize)
       SET tempaugcare = concat(format(cds->activity[fsize].augmented_care_details[cnt].local_id,
         "#################"),format(cds->activity[fsize].augmented_care_details[cnt].
         care_period_disp,"##"),format(cds->activity[fsize].augmented_care_details[cnt].
         care_period_num,"##"),format(cds->activity[fsize].augmented_care_details[cnt].
         care_period_source,"##"),format(cds->activity[fsize].augmented_care_details[cnt].planned_ind,
         "#"),
        format(cds->activity[fsize].augmented_care_details[cnt].outcome_ind,"##"),format(cds->
         activity[fsize].augmented_care_details[cnt].intensive_care_days,"####"),format(cds->
         activity[fsize].augmented_care_details[cnt].high_dep_level_days,"####"),format(cds->
         activity[fsize].augmented_care_details[cnt].num_organs_supp,"##"),format(cds->activity[fsize
         ].augmented_care_details[cnt].aug_start_date,"YYYYMMDD;;D"),
        format(cds->activity[fsize].augmented_care_details[cnt].aug_end_date,"YYYYMMDD;;D"),format(
         cds->activity[fsize].augmented_care_details[cnt].aug_spec_fun_cd,"###"),format(cds->
         activity[fsize].augmented_care_details[cnt].aug_care_loc,"##"))
       CASE (cnt)
        OF 1:
         SET augcare1 = tempaugcare
        OF 2:
         SET augcare2 = tempaugcare
        OF 3:
         SET augcare3 = tempaugcare
        OF 4:
         SET augcare4 = tempaugcare
        OF 5:
         SET augcare5 = tempaugcare
        OF 6:
         SET augcare6 = tempaugcare
        OF 7:
         SET augcare7 = tempaugcare
        OF 8:
         SET augcare8 = tempaugcare
        OF 9:
         SET augcare9 = tempaugcare
       ENDCASE
      ENDFOR
     ENDIF
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
     SET orgtypecode17 = emptystring
     SET orgtypecode18 = emptystring
     SET orgtypecode19 = emptystring
     SET orgtypecode20 = emptystring
     SET locationclass = emptystring
     IF (trim(cds->activity[fsize].sender_identity,3) != " ")
      SET orgtypecode1 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].primary_recip,3) != " ")
      SET orgtypecode2 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].copy_1,3) != " ")
      SET orgtypecode3 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].copy_2,3) != " ")
      SET orgtypecode4 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].copy_3,3) != " ")
      SET orgtypecode5 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].copy_4,3) != " ")
      SET orgtypecode6 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].copy_5,3) != " ")
      SET orgtypecode7 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].copy_6,3) != " ")
      SET orgtypecode8 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].copy_7,3) != " ")
      SET orgtypecode9 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].patient_id_org,3) != " ")
      SET orgtypecode10 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].residence_pct,3) != " ")
      SET orgtypecode11 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].org_cd_prov,3) != " ")
      SET orgtypecode12 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].org_cd_comm,3) != " ")
      SET orgtypecode13 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].start_site_cd,3) != " ")
      SET orgtypecode14 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].end_site_cd,3) != " ")
      SET orgtypecode15 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].gp_practice,3) != " ")
      SET orgtypecode16 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].referrer_org_cd,3) != " ")
      SET orgtypecode17 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].antenatal_gp_prac_cd,3) != " ")
      SET orgtypecode18 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].mom_org_cd,3) != " ")
      SET orgtypecode19 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].mom_pct,3) != " ")
      SET orgtypecode20 = orgtypecodedef
     ENDIF
     IF (trim(cds->activity[fsize].del_place_type,3) != " ")
      SET locationclass = locationclassdef
     ENDIF
     IF ((cds->activity[fsize].episode_end_dt > 0)
      AND (cds->activity[fsize].error_flag=0))
      SET sfile = cds->finished_file
     ELSEIF ((cds->activity[fsize].episode_end_dt=0)
      AND (cds->activity[fsize].error_flag=0))
      SET sfile = cds->unfinished_file
     ELSE
      SET sfile = cds->exception_file
     ENDIF
     SELECT INTO value(sfile)
      FROM dummyt d
      PLAN (d)
      DETAIL
       col 0,
       CALL print(trim(cds->activity[fsize].cds_type,3)), col 3,
       CALL print(trim(cds->activity[fsize].bulk_repl_cds_gp,3)), col 6,
       CALL print(trim(cds->activity[fsize].test_ind,3)),
       col 7,
       CALL print(trim(cds->activity[fsize].protocol_id,3)), col 10,
       CALL print(trim(cds->activity[fsize].unique_cds_id,3)), col 45,
       CALL print(trim(cds->activity[fsize].update_type,3)),
       col 46,
       CALL print(format(cds->activity[fsize].extract_dt_time,"YYYYMMDD;;D")), col 54,
       CALL print(format(cds->activity[fsize].extract_dt_time,"HHMMSS;;M")), col 60,
       CALL print(format(cds->activity[fsize].extract_dt_time,"YYYYMMDD;;D")),
       col 68,
       CALL print(format(cds->activity[fsize].extract_dt_time,"HHMMSS;;M")), col 74,
       CALL print(format(cds->activity[fsize].period_start_dt,"YYYYMMDD;;D")), col 82,
       CALL print(format(cds->activity[fsize].period_end_dt,"YYYYMMDD;;D")),
       col 90,
       CALL print(format(cds->activity[fsize].census_dt,"YYYYMMDD;;D")), col 98,
       CALL print(trim(cds->activity[fsize].sender_identity,3)), col 103,
       CALL print(trim(orgtypecode1,3)),
       col 104,
       CALL print(trim(cds->activity[fsize].primary_recip,3)), col 109,
       CALL print(trim(orgtypecode2,3)), col 110,
       CALL print(trim(cds->activity[fsize].copy_1,3)),
       col 115,
       CALL print(trim(orgtypecode3,3)), col 116,
       CALL print(trim(cds->activity[fsize].copy_2,3)), col 121,
       CALL print(trim(orgtypecode4,3)),
       col 122,
       CALL print(trim(cds->activity[fsize].copy_3,3)), col 127,
       CALL print(trim(orgtypecode5,3)), col 128,
       CALL print(trim(cds->activity[fsize].copy_4,3)),
       col 133,
       CALL print(trim(orgtypecode6,3)), col 134,
       CALL print(trim(cds->activity[fsize].copy_5,3)), col 139,
       CALL print(trim(orgtypecode7,3)),
       col 140,
       CALL print(trim(cds->activity[fsize].copy_6,3)), col 145,
       CALL print(trim(orgtypecode8,3)), col 146,
       CALL print(trim(cds->activity[fsize].copy_7,3)),
       col 151,
       CALL print(trim(orgtypecode9,3)), col 152,
       CALL print(trim(cds->activity[fsize].local_patient_id,3)), col 162,
       CALL print(trim(cds->activity[fsize].patient_id_org,3)),
       col 167,
       CALL print(trim(orgtypecode10,3)), col 168,
       CALL print(trim(cds->activity[fsize].nhs_number,3)), col 178,
       CALL print(format(cds->activity[fsize].birth_dt,"YYYYMMDD;;D")),
       col 186,
       CALL print(trim(cds->activity[fsize].carer_support_ind,3)), col 188,
       CALL print(trim(cds->activity[fsize].ethnic_group,3)), col 190,
       CALL print(trim(cds->activity[fsize].marital_status,3)),
       col 191,
       CALL print(trim(cds->activity[fsize].alias_status,3)), col 193,
       CALL print(trim(cds->activity[fsize].sex,3)), col 194,
       CALL print(trim(cds->activity[fsize].legal_classification,3)),
       col 196,
       CALL print(trim(cds->activity[fsize].previous_pregs_nbr,3)), col 198,
       CALL print(trim(cds->activity[fsize].birth_weight,3)), col 202,
       CALL print(trim(cds->activity[fsize].live_still_birth_ind,3)),
       col 203,
       CALL print(trim(cds->activity[fsize].name_format_ind,3)), col 204,
       CALL print(trim(cds->activity[fsize].patient_forename,3)), col 239,
       CALL print(trim(cds->activity[fsize].patient_surname,3)),
       col 274,
       CALL print(trim(cds->activity[fsize].pt_address_format_cd,3)), col 275,
       CALL print(trim(cds->activity[fsize].pt_address_1,3)), col 310,
       CALL print(trim(cds->activity[fsize].pt_address_2,3)),
       col 345,
       CALL print(trim(cds->activity[fsize].pt_address_3,3)), col 380,
       CALL print(trim(cds->activity[fsize].pt_address_4,3)), col 415,
       CALL print(trim(cds->activity[fsize].pt_address_5,3)),
       col 450,
       CALL print(trim(cds->activity[fsize].pt_post_code,3)), col 458,
       CALL print(trim(cds->activity[fsize].residence_pct,3)), col 463,
       CALL print(trim(orgtypecode11,3))
       IF ((cds->activity[fsize].del_place_type != "1"))
        col 464,
        CALL print(trim(cds->activity[fsize].spell_number,3)), col 476,
        CALL print(trim(cds->activity[fsize].admin_category,3)), col 478,
        CALL print(trim(cds->activity[fsize].adm_method,3)),
        col 480,
        CALL print(trim(cds->activity[fsize].disch_dest,3)), col 482,
        CALL print(trim(cds->activity[fsize].disch_method,3)), col 483,
        CALL print(trim(cds->activity[fsize].pt_class,3)),
        col 484,
        CALL print(trim(cds->activity[fsize].adm_source,3)), col 486,
        CALL print(format(cds->activity[fsize].adm_date,"YYYYMMDD;;D")), col 494,
        CALL print(format(cds->activity[fsize].disch_date,"YYYYMMDD;;D")),
        col 502,
        CALL print(trim(cds->activity[fsize].episode_ct,3)), col 504,
        CALL print(trim(cds->activity[fsize].first_adm_ind,3)), col 505,
        CALL print(trim(cds->activity[fsize].last_episode_ind,3)),
        col 506,
        CALL print(trim(cds->activity[fsize].neonatal_care_lvl,3)), col 507,
        CALL print(trim(cds->activity[fsize].operation_status_ind,3)), col 508,
        CALL print(trim(cds->activity[fsize].psych_status_ind,3)),
        col 509,
        CALL print(format(cds->activity[fsize].episode_start_dt,"YYYYMMDD;;D")), col 517,
        CALL print(format(cds->activity[fsize].episode_end_dt,"YYYYMMDD;;D")), col 525,
        CALL print(trim(cds->activity[fsize].comm_ser_nbr,3)),
        col 531,
        CALL print(trim(cds->activity[fsize].nhs_svc_agr_line_nbr,3)), col 541,
        CALL print(trim(cds->activity[fsize].prov_ref_nbr,3)), col 558,
        CALL print(trim(cds->activity[fsize].comm_ref_nbr,3)),
        col 575,
        CALL print(trim(cds->activity[fsize].org_cd_prov,3)), col 580,
        CALL print(trim(orgtypecode12,3)), col 581,
        CALL print(trim(cds->activity[fsize].org_cd_comm,3)),
        col 586,
        CALL print(trim(orgtypecode13,3)), col 587,
        CALL print(trim(cds->activity[fsize].consultant_code,3)), col 595,
        CALL print(trim(cds->activity[fsize].main_specialty_code,3)),
        col 598,
        CALL print(trim(cds->activity[fsize].treatment_function_code,3)), col 601,
        CALL print(trim(diagscheme,3)), col 603,
        CALL print(trim(cds->activity[fsize].primary_icd,3)),
        col 609,
        CALL print(trim(otherdiagicd,3)), col 774,
        CALL print(trim(procscheme,3)), col 776,
        CALL print(trim(cds->activity[fsize].opcs4_cd1,3)),
        col 780,
        CALL print(format(cds->activity[fsize].opcs4_date1,"YYYYMMDD;;D")), col 788,
        CALL print(trim(otherprocopcs,3)), col 1102,
        CALL print(trim(cds->activity[fsize].start_site_cd,3)),
        col 1107,
        CALL print(trim(orgtypecode14,3)), col 1108,
        CALL print(trim(cds->activity[fsize].start_age_group_intend,3)), col 1109,
        CALL print(trim(cds->activity[fsize].start_intensity_intend,3)),
        col 1111,
        CALL print(trim(cds->activity[fsize].start_sex_of_patients,3)), col 1112,
        CALL print(trim(cds->activity[fsize].start_ward_night_avail,3)), col 1113,
        CALL print(trim(cds->activity[fsize].start_ward_day_avail,3)),
        col 1114,
        CALL print(locdetailsone), col 1142,
        CALL print(locdetailsother), col 1366,
        CALL print(trim(cds->activity[fsize].end_site_cd,3)),
        col 1371,
        CALL print(trim(orgtypecode15,3)), col 1372,
        CALL print(trim(cds->activity[fsize].end_age_group_intend,3)), col 1373,
        CALL print(trim(cds->activity[fsize].end_intensity_intend,3)),
        col 1375,
        CALL print(trim(cds->activity[fsize].end_sex_of_patients,3)), col 1376,
        CALL print(trim(cds->activity[fsize].end_ward_night_avail,3)), col 1377,
        CALL print(trim(cds->activity[fsize].end_ward_day_avail,3))
       ENDIF
       col 1378,
       CALL print(trim(cds->activity[fsize].gp_code,3)), col 1386,
       CALL print(trim(cds->activity[fsize].gp_practice,3)), col 1392,
       CALL print(trim(orgtypecode16,3))
       IF ((cds->activity[fsize].del_place_type != "1"))
        col 1393,
        CALL print(trim(cds->activity[fsize].referrer_cd,3)), col 1401,
        CALL print(trim(cds->activity[fsize].referrer_org_cd,3)), col 1407,
        CALL print(trim(orgtypecode17,3)),
        col 1408,
        CALL print(trim(cds->activity[fsize].wait_duration,3)), col 1412,
        CALL print(trim(cds->activity[fsize].intend_management,3)), col 1413,
        CALL print(format(cds->activity[fsize].decision_admit_date,"YYYYMMDD;;D"))
       ENDIF
       col 1421,
       CALL print(trim(cds->activity[fsize].hrg_code,3)), col 1424,
       CALL print(trim(cds->activity[fsize].hrg_version,3)), col 1427,
       CALL print(trim(procscheme,3)),
       col 1429,
       CALL print(trim(cds->activity[fsize].hrg_dgvp_opcs,3))
       IF ((cds->activity[fsize].del_place_type != "1"))
        col 1433,
        CALL print(trim(criticalcareone,3)), col 1534,
        CALL print(trim(criticalcareother,3))
       ENDIF
       IF ((cds->activity[fsize].cds_type_cd IN (cds_120, cds_150, cds_180, cds_140, cds_160,
       cds_200)))
        col 2342,
        CALL print(trim(cds->activity[fsize].number_of_babies,3)), col 2343,
        CALL print(format(cds->activity[fsize].first_antenatal_dt,"YYYYMMDD;;D")), col 2351,
        CALL print(trim(cds->activity[fsize].antenatal_gp_cd,3)),
        col 2359,
        CALL print(trim(cds->activity[fsize].antenatal_gp_prac_cd,3)), col 2365,
        CALL print(trim(orgtypecode18,3)), col 2366,
        CALL print(trim(locationclass,3)),
        col 2368,
        CALL print(trim(cds->activity[fsize].del_place_type,3)), col 2369,
        CALL print(trim(cds->activity[fsize].del_place_chg_reas,3)), col 2370,
        CALL print(trim(cds->activity[fsize].anes_during_del,3)),
        col 2371,
        CALL print(trim(cds->activity[fsize].anes_post_del,3)), col 2372,
        CALL print(trim(cds->activity[fsize].gest_len,3)), col 2374,
        CALL print(trim(cds->activity[fsize].labor_onset_meth,3)),
        col 2375,
        CALL print(format(cds->activity[fsize].delivery_date,"YYYYMMDD;;D")), col 2383,
        CALL print(birthdetailsone), col 2434,
        CALL print(birthdetailsother)
       ENDIF
       IF ((cds->activity[fsize].cds_type_cd IN (cds_120, cds_150, cds_180)))
        col 2842,
        CALL print(trim(cds->activity[fsize].mom_local_pat_id,3)), col 2852,
        CALL print(trim(cds->activity[fsize].mom_org_cd,3)), col 2857,
        CALL print(trim(orgtypecode19,3)),
        col 2858,
        CALL print(trim(cds->activity[fsize].mom_nhs_new,3)), col 2868,
        CALL print(trim(cds->activity[fsize].mom_nhs_status,3)), col 2870,
        CALL print(format(cds->activity[fsize].mom_birth_date,"YYYYMMDD;;D")),
        col 2878,
        CALL print(trim(cds->activity[fsize].mom_address_cd,3)), col 2879,
        CALL print(trim(cds->activity[fsize].mom_address_1,3)), col 2914,
        CALL print(trim(cds->activity[fsize].mom_address_2,3)),
        col 2949,
        CALL print(trim(cds->activity[fsize].mom_address_3,3)), col 2984,
        CALL print(trim(cds->activity[fsize].mom_address_4,3)), col 3019,
        CALL print(trim(cds->activity[fsize].mom_address_5,3)),
        col 3054,
        CALL print(trim(cds->activity[fsize].mom_post_cd,3)), col 3062,
        CALL print(trim(cds->activity[fsize].mom_pct,3)), col 3067,
        CALL print(trim(orgtypecode20,3))
       ENDIF
       IF ((cds->activity[fsize].del_place_type != "1"))
        col 3068,
        CALL print(trim(cnvtstring(augcaresize),3)), col 3070,
        CALL print(augcare1), col 3127,
        CALL print(augcare2),
        col 3184,
        CALL print(augcare3), col 3241,
        CALL print(augcare4), col 3298,
        CALL print(augcare5),
        col 3355,
        CALL print(augcare6), col 3412,
        CALL print(augcare7), col 3469,
        CALL print(augcare8),
        col 3526,
        CALL print(augcare9)
       ENDIF
       IF (trim(cds->activity[fsize].local_subspecialty,3) != "")
        col 3583,
        CALL print(trim(cds->activity[fsize].local_subspecialty,3))
       ENDIF
      WITH nocounter, append, format = lfstream,
       format = fixed, maxcol = 3590, maxrow = 1,
       formfeed = none
     ;end select
   ENDFOR
  ELSE
   FOR (fsize = 1 TO size(cds->activity,5))
     IF ((cds->activity[fsize].episode_end_dt > 0)
      AND (cds->activity[fsize].error_flag=0))
      SET sfile = cds->finished_file
     ELSEIF ((cds->activity[fsize].episode_end_dt=0)
      AND (cds->activity[fsize].error_flag=0))
      SET sfile = cds->unfinished_file
     ELSE
      SET sfile = cds->exception_file
     ENDIF
     SELECT INTO value(sfile)
      fsize
      FROM (dummyt d  WITH seq = value(1))
      PLAN (d)
      DETAIL
       col 0,
       CALL print(trim(cds->activity[fsize].version_number,3)), col 6,
       CALL print(trim(cds->activity[fsize].cds_type,3)),
       CALL echo(build("cds type->",cds->activity[fsize].cds_type)), col 09,
       CALL print(trim(cds->activity[fsize].protocol_id,3)), col 12,
       CALL print(trim(cds->activity[fsize].unique_cds_id,3)),
       col 47,
       CALL print(trim(cds->activity[fsize].update_type,3)), col 51,
       CALL print(trim(cds->activity[fsize].test_ind,3)), col 52, cds->activity[fsize].
       extract_dt_time"YYYYMMDDHHMM;;q",
       col 64, cds->activity[fsize].extract_dt_time"YYYYMMDDHHMM;;q", col 76,
       cds->activity[fsize].period_start_dt"YYYYMMDD;;d", col 84, cds->activity[fsize].period_end_dt
       "YYYYMMDD;;d",
       col 92, cds->activity[fsize].census_dt"YYYYMMDD;;d", col 100,
       CALL print(trim(cds->activity[fsize].sender_identity,3)), col 105,
       CALL print(trim(cds->activity[fsize].primary_recip,3)),
       col 110,
       CALL print(trim(cds->activity[fsize].copy_1,3)), col 115,
       CALL print(trim(cds->activity[fsize].copy_2,3)), col 120,
       CALL print(trim(cds->activity[fsize].copy_3,3)),
       col 125,
       CALL print(trim(cds->activity[fsize].copy_4,3)), col 130,
       CALL print(trim(cds->activity[fsize].copy_5,3)), col 135,
       CALL print(trim(cds->activity[fsize].copy_6,3)),
       col 140,
       CALL print(trim(cds->activity[fsize].copy_7,3)), col 145,
       CALL print(trim(cds->activity[fsize].local_patient_id,3)), col 155,
       CALL print(trim(cds->activity[fsize].patient_id_org,3)),
       col 160,
       CALL print(trim(cds->activity[fsize].nhs_number,3)), col 187,
       cds->activity[fsize].birth_dt"YYYYMMDD;;d", col 195,
       CALL print(trim(cds->activity[fsize].carer_support_ind,3)),
       col 197,
       CALL print(trim(cds->activity[fsize].ethnic_group,3)), col 199,
       CALL print(trim(cds->activity[fsize].marital_status,3))
       IF (trim(cds->activity[fsize].alias_status,3)=" ")
        cds->activity[fsize].alias_status = "03"
       ENDIF
       col 200,
       CALL print(trim(cds->activity[fsize].alias_status,3)), col 202,
       CALL print(trim(cds->activity[fsize].sex,3))
       IF (trim(cds->activity[fsize].legal_classification,3)=" ")
        cds->activity[fsize].legal_classification = "98"
       ENDIF
       col 203,
       CALL print(trim(cds->activity[fsize].legal_classification,3))
       IF ((cds->activity[fsize].previous_pregs_nbr != ""))
        col 205,
        CALL print(substring(2,1,cds->activity[fsize].previous_pregs_nbr))
       ENDIF
       col 206,
       CALL print(trim(cds->activity[fsize].birth_weight,3)), col 210,
       CALL print(trim(cds->activity[fsize].live_still_birth_ind,3))
       IF ((cds->activity[fsize].anonymous != 1))
        col 211,
        CALL print(trim(cds->activity[fsize].name_format_ind,3)), col 212,
        CALL print(trim(cds->activity[fsize].patient_forename,3)), col 247,
        CALL print(trim(cds->activity[fsize].patient_surname,3)),
        col 352,
        CALL print(trim(cds->activity[fsize].pt_address_format_cd,3)), col 353,
        CALL print(trim(cds->activity[fsize].pt_address_1,3)), col 388,
        CALL print(trim(cds->activity[fsize].pt_address_2,3)),
        col 423,
        CALL print(trim(cds->activity[fsize].pt_address_3,3)), col 458,
        CALL print(trim(cds->activity[fsize].pt_address_4,3)), col 493,
        CALL print(trim(cds->activity[fsize].pt_address_5,3))
       ENDIF
       IF (trim(cds->activity[fsize].pt_post_code,3)=" ")
        cds->activity[fsize].pt_post_code = d_not_known_postcode
       ENDIF
       col 528,
       CALL print(trim(cds->activity[fsize].pt_post_code,3)), col 536,
       CALL print(trim(cds->activity[fsize].pt_sha,3))
       IF ((cds->activity[fsize].del_place_type != "1"))
        col 539,
        CALL print(trim(cds->activity[fsize].spell_number,3))
        IF (trim(cds->activity[fsize].admin_category,3)=" ")
         cds->activity[fsize].admin_category = "99"
        ENDIF
        col 556,
        CALL print(trim(cds->activity[fsize].admin_category,3))
        IF (trim(cds->activity[fsize].adm_method,3)=" ")
         cds->activity[fsize].adm_method = "99"
        ENDIF
        col 558,
        CALL print(trim(cds->activity[fsize].adm_method,3))
        IF (trim(cds->activity[fsize].disch_dest,3)=" ")
         cds->activity[fsize].disch_dest = "98"
        ENDIF
        col 560,
        CALL print(trim(cds->activity[fsize].disch_dest,3))
        IF (trim(cds->activity[fsize].disch_method,3)=" ")
         cds->activity[fsize].disch_method = "8"
        ENDIF
        col 562,
        CALL print(trim(cds->activity[fsize].disch_method,3)), col 563,
        CALL print(trim(cds->activity[fsize].pt_class,3)), col 564,
        CALL print(trim(cds->activity[fsize].adm_source,3)),
        col 566, cds->activity[fsize].adm_date"YYYYMMDD;;d", col 574,
        cds->activity[fsize].disch_date"YYYYMMDD;;d", col 582,
        CALL print(trim(cds->activity[fsize].episode_ct,3)),
        col 584,
        CALL print(trim(cds->activity[fsize].first_adm_ind,3)), col 585,
        CALL print(trim(cds->activity[fsize].last_episode_ind,3))
        IF ((cds->activity[fsize].encntr_type=newborn_type)
         AND trim(cds->activity[fsize].neonatal_care_lvl,3)=" ")
         cds->activity[fsize].neonatal_care_lvl = "9"
        ELSEIF ((cds->activity[fsize].encntr_type != newborn_type))
         cds->activity[fsize].neonatal_care_lvl = "8"
        ENDIF
        col 586,
        CALL print(trim(cds->activity[fsize].neonatal_care_lvl,3))
        IF (trim(cds->activity[fsize].operation_status_ind,3)=" ")
         cds->activity[fsize].operation_status_ind = "9"
        ENDIF
        col 587,
        CALL print(trim(cds->activity[fsize].operation_status_ind,3))
        IF (trim(cds->activity[fsize].psych_status_ind,3)=" ")
         cds->activity[fsize].psych_status_ind = "8"
        ENDIF
        col 588,
        CALL print(trim(cds->activity[fsize].psych_status_ind,3))
        IF (trim(cds->activity[fsize].care_periods_ct,3) != " ")
         col 589,
         CALL print(trim(cds->activity[fsize].care_periods_ct,3))
        ELSE
         cds->activity[fsize].care_periods_ct = "0", col 589,
         CALL print(trim(cds->activity[fsize].care_periods_ct,3))
        ENDIF
        col 591, cds->activity[fsize].episode_start_dt"YYYYMMDD;;d", col 599,
        cds->activity[fsize].episode_end_dt"YYYYMMDD;;d", col 607,
        CALL print(trim(cds->activity[fsize].comm_ser_nbr,3)),
        col 613,
        CALL print(trim(cds->activity[fsize].nhs_svc_agr_line_nbr,3)), col 623,
        CALL print(trim(cds->activity[fsize].prov_ref_nbr,3)), col 640,
        CALL print(trim(cds->activity[fsize].comm_ref_nbr,3)),
        col 657,
        CALL print(trim(cds->activity[fsize].org_cd_prov,3)), col 662,
        CALL print(trim(cds->activity[fsize].org_cd_comm,3))
        IF (trim(cds->activity[fsize].consultant_code,3)=" ")
         cds->activity[fsize].consultant_code = "C9999998"
        ENDIF
        col 667,
        CALL print(trim(cds->activity[fsize].consultant_code,3)), col 675,
        CALL print(trim(cds->activity[fsize].main_specialty_code,3)), col 678,
        CALL print(trim(cds->activity[fsize].treatment_function_code,3))
        IF (trim(cds->activity[fsize].local_subspecialty,3) != "")
         col 681,
         CALL print(trim(cds->activity[fsize].local_subspecialty,3))
        ENDIF
        col 686,
        CALL print(trim(cds->activity[fsize].primary_icd,3)), col 692,
        CALL print(trim(cds->activity[fsize].subsidiary_icd,3)), col 698,
        CALL print(trim(cds->activity[fsize].icd_cd1,3)),
        col 704,
        CALL print(trim(cds->activity[fsize].icd_cd2,3)), col 710,
        CALL print(trim(cds->activity[fsize].icd_cd3,3)), col 716,
        CALL print(trim(cds->activity[fsize].icd_cd4,3)),
        col 722,
        CALL print(trim(cds->activity[fsize].icd_cd5,3)), col 728,
        CALL print(trim(cds->activity[fsize].icd_cd6,3)), col 734,
        CALL print(trim(cds->activity[fsize].icd_cd7,3)),
        col 740,
        CALL print(trim(cds->activity[fsize].icd_cd8,3)), col 746,
        CALL print(trim(cds->activity[fsize].icd_cd9,3)), col 752,
        CALL print(trim(cds->activity[fsize].icd_cd10,3)),
        col 758,
        CALL print(trim(cds->activity[fsize].icd_cd11,3)), col 764,
        CALL print(trim(cds->activity[fsize].icd_cd12,3)), col 869,
        CALL print(trim(cds->activity[fsize].opcs4_cd1,3)),
        col 876, cds->activity[fsize].opcs4_date1"YYYYMMDD;;d", col 884,
        CALL print(trim(cds->activity[fsize].opcs4_cd2,3)), col 891, cds->activity[fsize].opcs4_date2
        "YYYYMMDD;;d",
        col 899,
        CALL print(trim(cds->activity[fsize].opcs4_cd3,3)), col 906,
        cds->activity[fsize].opcs4_date3"YYYYMMDD;;d", col 914,
        CALL print(trim(cds->activity[fsize].opcs4_cd4,3)),
        col 921, cds->activity[fsize].opcs4_date4"YYYYMMDD;;d", col 929,
        CALL print(trim(cds->activity[fsize].opcs4_cd5,3)), col 936, cds->activity[fsize].opcs4_date5
        "YYYYMMDD;;d",
        col 944,
        CALL print(trim(cds->activity[fsize].opcs4_cd6,3)), col 951,
        cds->activity[fsize].opcs4_date6"YYYYMMDD;;d", col 959,
        CALL print(trim(cds->activity[fsize].opcs4_cd7,3)),
        col 966, cds->activity[fsize].opcs4_date7"YYYYMMDD;;d", col 974,
        CALL print(trim(cds->activity[fsize].opcs4_cd8,3)), col 981, cds->activity[fsize].opcs4_date8
        "YYYYMMDD;;d",
        col 989,
        CALL print(trim(cds->activity[fsize].opcs4_cd9,3)), col 996,
        cds->activity[fsize].opcs4_date9"YYYYMMDD;;d", col 1004,
        CALL print(trim(cds->activity[fsize].opcs4_cd10,3)),
        col 1011, cds->activity[fsize].opcs4_date10"YYYYMMDD;;d", col 1019,
        CALL print(trim(cds->activity[fsize].opcs4_cd11,3)), col 1026, cds->activity[fsize].
        opcs4_date11"YYYYMMDD;;d",
        col 1034,
        CALL print(trim(cds->activity[fsize].opcs4_cd12,3)), col 1041,
        cds->activity[fsize].opcs4_date12"YYYYMMDD;;d", col 1230,
        CALL print(trim(cds->activity[fsize].start_site_cd,3)),
        col 1235,
        CALL print(trim(cds->activity[fsize].start_age_group_intend,3)), col 1236,
        CALL print(trim(cds->activity[fsize].start_intensity_intend,3)), col 1238,
        CALL print(trim(cds->activity[fsize].start_sex_of_patients,3)),
        col 1239,
        CALL print(trim(cds->activity[fsize].start_ward_night_avail,3)), col 1240,
        CALL print(trim(cds->activity[fsize].start_ward_day_avail,3)), fsize2 = size(cds->activity[
         fsize].ward_stay_details,5)
        IF (fsize2 > 0)
         col 1241,
         CALL print(trim(cds->activity[fsize].ward_stay_details[1].treatment_site_cd,3)), col 1246,
         CALL print(trim(cds->activity[fsize].ward_stay_details[1].age_group_intend,3)), col 1247,
         CALL print(trim(cds->activity[fsize].ward_stay_details[1].intensity_intend,3)),
         col 1249,
         CALL print(trim(cds->activity[fsize].ward_stay_details[1].sex_of_patients,3)), col 1250,
         CALL print(trim(cds->activity[fsize].ward_stay_details[1].ward_night_avail,3)), col 1251,
         CALL print(trim(cds->activity[fsize].ward_stay_details[1].ward_day_avail,3)),
         col 1252, cds->activity[fsize].ward_stay_details[1].ward_start_date"YYYYMMDD;;d", col 1260,
         cds->activity[fsize].ward_stay_details[1].ward_end_date"YYYYMMDD;;d"
        ENDIF
        IF (fsize2 > 1)
         col 1268,
         CALL print(trim(cds->activity[fsize].ward_stay_details[2].treatment_site_cd,2)), col 1273,
         CALL print(trim(cds->activity[fsize].ward_stay_details[2].age_group_intend,2)), col 1274,
         CALL print(trim(cds->activity[fsize].ward_stay_details[2].intensity_intend,2)),
         col 1276,
         CALL print(trim(cds->activity[fsize].ward_stay_details[2].sex_of_patients,2)), col 1277,
         CALL print(trim(cds->activity[fsize].ward_stay_details[2].ward_night_avail,2)), col 1278,
         CALL print(trim(cds->activity[fsize].ward_stay_details[2].ward_day_avail,2)),
         col 1279, cds->activity[fsize].ward_stay_details[2].ward_start_date"YYYYMMDD;;d", col 1287,
         cds->activity[fsize].ward_stay_details[2].ward_end_date"YYYYMMDD;;d"
        ENDIF
        IF (fsize2 > 2)
         col 1295,
         CALL print(trim(cds->activity[fsize].ward_stay_details[3].treatment_site_cd,3)), col 1300,
         CALL print(trim(cds->activity[fsize].ward_stay_details[3].age_group_intend,3)), col 1301,
         CALL print(trim(cds->activity[fsize].ward_stay_details[3].intensity_intend,3)),
         col 1303,
         CALL print(trim(cds->activity[fsize].ward_stay_details[3].sex_of_patients,3)), col 1304,
         CALL print(trim(cds->activity[fsize].ward_stay_details[3].ward_night_avail,3)), col 1305,
         CALL print(trim(cds->activity[fsize].ward_stay_details[3].ward_day_avail,3)),
         col 1306, cds->activity[fsize].ward_stay_details[3].ward_start_date"YYYYMMDD;;d", col 1314,
         cds->activity[fsize].ward_stay_details[3].ward_end_date"YYYYMMDD;;d"
        ENDIF
        IF (fsize2 > 3)
         col 1322,
         CALL print(trim(cds->activity[fsize].ward_stay_details[4].treatment_site_cd,3)), col 1327,
         CALL print(trim(cds->activity[fsize].ward_stay_details[4].age_group_intend,3)), col 1328,
         CALL print(trim(cds->activity[fsize].ward_stay_details[4].intensity_intend,3)),
         col 1330,
         CALL print(trim(cds->activity[fsize].ward_stay_details[4].sex_of_patients,3)), col 1331,
         CALL print(trim(cds->activity[fsize].ward_stay_details[4].ward_night_avail,3)), col 1332,
         CALL print(trim(cds->activity[fsize].ward_stay_details[4].ward_day_avail,3)),
         col 1333, cds->activity[fsize].ward_stay_details[4].ward_start_date"YYYYMMDD;;d", col 1341,
         cds->activity[fsize].ward_stay_details[4].ward_end_date"YYYYMMDD;;d"
        ENDIF
        IF (fsize2 > 4)
         col 1349,
         CALL print(trim(cds->activity[fsize].ward_stay_details[5].treatment_site_cd,3)), col 1354,
         CALL print(trim(cds->activity[fsize].ward_stay_details[5].age_group_intend,3)), col 1355,
         CALL print(trim(cds->activity[fsize].ward_stay_details[5].intensity_intend,3)),
         col 1357,
         CALL print(trim(cds->activity[fsize].ward_stay_details[5].sex_of_patients,3)), col 1358,
         CALL print(trim(cds->activity[fsize].ward_stay_details[5].ward_night_avail,3)), col 1359,
         CALL print(trim(cds->activity[fsize].ward_stay_details[5].ward_day_avail,3)),
         col 1360, cds->activity[fsize].ward_stay_details[5].ward_start_date"YYYYMMDD;;d", col 1368,
         cds->activity[fsize].ward_stay_details[5].ward_end_date"YYYYMMDD;;d"
        ENDIF
        IF (fsize2 > 5)
         col 1376,
         CALL print(trim(cds->activity[fsize].ward_stay_details[6].treatment_site_cd,3)), col 1381,
         CALL print(trim(cds->activity[fsize].ward_stay_details[6].age_group_intend,3)), col 1382,
         CALL print(trim(cds->activity[fsize].ward_stay_details[6].intensity_intend,3)),
         col 1384,
         CALL print(trim(cds->activity[fsize].ward_stay_details[6].sex_of_patients,3)), col 1385,
         CALL print(trim(cds->activity[fsize].ward_stay_details[6].ward_night_avail,3)), col 1386,
         CALL print(trim(cds->activity[fsize].ward_stay_details[6].ward_day_avail,3)),
         col 1387, cds->activity[fsize].ward_stay_details[6].ward_start_date"YYYYMMDD;;d", col 1395,
         cds->activity[fsize].ward_stay_details[6].ward_end_date"YYYYMMDD;;d"
        ENDIF
        IF (fsize2 > 6)
         col 1403,
         CALL print(trim(cds->activity[fsize].ward_stay_details[7].treatment_site_cd,3)), col 1408,
         CALL print(trim(cds->activity[fsize].ward_stay_details[7].age_group_intend,3)), col 1409,
         CALL print(trim(cds->activity[fsize].ward_stay_details[7].intensity_intend,3)),
         col 1411,
         CALL print(trim(cds->activity[fsize].ward_stay_details[7].sex_of_patients,3)), col 1412,
         CALL print(trim(cds->activity[fsize].ward_stay_details[7].ward_night_avail,3)), col 1413,
         CALL print(trim(cds->activity[fsize].ward_stay_details[7].ward_day_avail,3)),
         col 1414, cds->activity[fsize].ward_stay_details[7].ward_start_date"YYYYMMDD;;d", col 1422,
         cds->activity[fsize].ward_stay_details[7].ward_end_date"YYYYMMDD;;d"
        ENDIF
        IF (fsize2 > 7)
         col 1430,
         CALL print(trim(cds->activity[fsize].ward_stay_details[8].treatment_site_cd,3)), col 1435,
         CALL print(trim(cds->activity[fsize].ward_stay_details[8].age_group_intend,3)), col 1436,
         CALL print(trim(cds->activity[fsize].ward_stay_details[8].intensity_intend,3)),
         col 1438,
         CALL print(trim(cds->activity[fsize].ward_stay_details[8].sex_of_patients,3)), col 1439,
         CALL print(trim(cds->activity[fsize].ward_stay_details[8].ward_night_avail,3)), col 1440,
         CALL print(trim(cds->activity[fsize].ward_stay_details[8].ward_day_avail,3)),
         col 1441, cds->activity[fsize].ward_stay_details[8].ward_start_date"YYYYMMDD;;d", col 1449,
         cds->activity[fsize].ward_stay_details[8].ward_end_date"YYYYMMDD;;d"
        ENDIF
        IF (fsize2 > 8)
         col 1457,
         CALL print(trim(cds->activity[fsize].ward_stay_details[9].treatment_site_cd,3)), col 1462,
         CALL print(trim(cds->activity[fsize].ward_stay_details[9].age_group_intend,3)), col 1463,
         CALL print(trim(cds->activity[fsize].ward_stay_details[9].intensity_intend,3)),
         col 1465,
         CALL print(trim(cds->activity[fsize].ward_stay_details[9].sex_of_patients,3)), col 1466,
         CALL print(trim(cds->activity[fsize].ward_stay_details[9].ward_night_avail,3)), col 1467,
         CALL print(trim(cds->activity[fsize].ward_stay_details[9].ward_day_avail,3)),
         col 1468, cds->activity[fsize].ward_stay_details[9].ward_start_date"YYYYMMDD;;d", col 1476,
         cds->activity[fsize].ward_stay_details[9].ward_end_date"YYYYMMDD;;d"
        ENDIF
        col 1484,
        CALL print(trim(cds->activity[fsize].end_site_cd,3)), col 1489,
        CALL print(trim(cds->activity[fsize].end_age_group_intend,3)), col 1490,
        CALL print(trim(cds->activity[fsize].end_intensity_intend,3)),
        col 1492,
        CALL print(trim(cds->activity[fsize].end_sex_of_patients,3)), col 1493,
        CALL print(trim(cds->activity[fsize].end_ward_night_avail,3)), col 1494,
        CALL print(trim(cds->activity[fsize].end_ward_day_avail,3))
       ENDIF
       IF (trim(cds->activity[fsize].gp_code,3)=" ")
        cds->activity[fsize].gp_code = "G9999981"
       ENDIF
       col 1495,
       CALL print(trim(cds->activity[fsize].gp_code,3))
       IF (trim(cds->activity[fsize].gp_practice,3)=" ")
        cds->activity[fsize].gp_practice = "V81999"
       ENDIF
       col 1503,
       CALL print(trim(cds->activity[fsize].gp_practice,3))
       IF ((cds->activity[fsize].del_place_type != "1"))
        IF (trim(cds->activity[fsize].referrer_cd,3)=" ")
         cds->activity[fsize].referrer_cd = "X9999998"
        ENDIF
        col 1509,
        CALL print(trim(cds->activity[fsize].referrer_cd,3))
        IF (trim(cds->activity[fsize].referrer_org_cd,3)=" ")
         cds->activity[fsize].referrer_org_cd = "X99998"
        ENDIF
        col 1517,
        CALL print(trim(cds->activity[fsize].referrer_org_cd,3)), col 1523,
        CALL print(trim(cds->activity[fsize].wait_duration,3)), col 1527,
        CALL print(trim(cds->activity[fsize].intend_management,3)),
        col 1528, cds->activity[fsize].decision_admit_date"YYYYMMDD;;d"
       ENDIF
       col 1536,
       CALL print(trim(cds->activity[fsize].hrg_code,3)), col 1539,
       CALL print(trim(cds->activity[fsize].hrg_version,3)), col 1542,
       CALL print(trim(cds->activity[fsize].hrg_dgvp_opcs,3)),
       col 1546,
       CALL print(trim(cds->activity[fsize].hrg_dgvp_read,3)), col 1553,
       CALL print(trim(cds->activity[fsize].read_code_ver,3))
       IF ((cds->activity[fsize].del_place_type != "1"))
        fsize2 = size(cds->activity[fsize].augmented_care_details,5)
        IF (fsize2 > 0)
         col 1554,
         CALL print(trim(cds->activity[fsize].augmented_care_details[1].local_id,3)), col 1571,
         CALL print(trim(cds->activity[fsize].augmented_care_details[1].care_period_disp,3)), col
         1573,
         CALL print(trim(cds->activity[fsize].augmented_care_details[1].care_period_num,3)),
         col 1575,
         CALL print(trim(cds->activity[fsize].augmented_care_details[1].care_period_source,3)), col
         1577,
         CALL print(trim(cds->activity[fsize].augmented_care_details[1].planned_ind,3)), col 1578,
         CALL print(trim(cds->activity[fsize].augmented_care_details[1].outcome_ind,3)),
         col 1580,
         CALL print(trim(cds->activity[fsize].augmented_care_details[1].intensive_care_days,3)), col
         1584,
         CALL print(trim(cds->activity[fsize].augmented_care_details[1].high_dep_level_days,3)), col
         1588,
         CALL print(trim(cds->activity[fsize].augmented_care_details[1].num_organs_supp,3)),
         col 1590, cds->activity[fsize].augmented_care_details[1].aug_start_date"YYYYMMDD;;d", col
         1598,
         cds->activity[fsize].augmented_care_details[1].aug_end_date"YYYYMMDD;;d", col 1606,
         CALL print(trim(cds->activity[fsize].augmented_care_details[1].aug_spec_fun_cd,3)),
         col 1609,
         CALL print(trim(cds->activity[fsize].augmented_care_details[1].aug_care_loc,3))
        ENDIF
        IF (fsize2 > 1)
         col 1611,
         CALL print(trim(cds->activity[fsize].augmented_care_details[2].local_id,3)), col 1628,
         CALL print(trim(cds->activity[fsize].augmented_care_details[2].care_period_disp,3)), col
         1630,
         CALL print(trim(cds->activity[fsize].augmented_care_details[2].care_period_num,3)),
         col 1632,
         CALL print(trim(cds->activity[fsize].augmented_care_details[2].care_period_source,3)), col
         1634,
         CALL print(trim(cds->activity[fsize].augmented_care_details[2].planned_ind,3)), col 1635,
         CALL print(trim(cds->activity[fsize].augmented_care_details[2].outcome_ind,3)),
         col 1637,
         CALL print(trim(cds->activity[fsize].augmented_care_details[2].intensive_care_days,3)), col
         1641,
         CALL print(trim(cds->activity[fsize].augmented_care_details[2].high_dep_level_days,3)), col
         1645,
         CALL print(trim(cds->activity[fsize].augmented_care_details[2].num_organs_supp,3)),
         col 1647, cds->activity[fsize].augmented_care_details[2].aug_start_date"YYYYMMDD;;d", col
         1655,
         cds->activity[fsize].augmented_care_details[2].aug_end_date"YYYYMMDD;;d", col 1663,
         CALL print(trim(cds->activity[fsize].augmented_care_details[2].aug_spec_fun_cd,3)),
         col 1666,
         CALL print(trim(cds->activity[fsize].augmented_care_details[2].aug_care_loc,3))
        ENDIF
        IF (fsize2 > 2)
         col 1668,
         CALL print(trim(cds->activity[fsize].augmented_care_details[3].local_id,3)), col 1685,
         CALL print(trim(cds->activity[fsize].augmented_care_details[3].care_period_disp,3)), col
         1687,
         CALL print(trim(cds->activity[fsize].augmented_care_details[3].care_period_num,3)),
         col 1689,
         CALL print(trim(cds->activity[fsize].augmented_care_details[3].care_period_source,3)), col
         1691,
         CALL print(trim(cds->activity[fsize].augmented_care_details[3].planned_ind,3)), col 1692,
         CALL print(trim(cds->activity[fsize].augmented_care_details[3].outcome_ind,3)),
         col 1694,
         CALL print(trim(cds->activity[fsize].augmented_care_details[3].intensive_care_days,3)), col
         1698,
         CALL print(trim(cds->activity[fsize].augmented_care_details[3].high_dep_level_days,3)), col
         1702,
         CALL print(trim(cds->activity[fsize].augmented_care_details[3].num_organs_supp,3)),
         col 1704, cds->activity[fsize].augmented_care_details[3].aug_start_date"YYYYMMDD;;d", col
         1712,
         cds->activity[fsize].augmented_care_details[3].aug_end_date"YYYYMMDD;;d", col 1720,
         CALL print(trim(cds->activity[fsize].augmented_care_details[3].aug_spec_fun_cd,3)),
         col 1723,
         CALL print(trim(cds->activity[fsize].augmented_care_details[3].aug_care_loc,3))
        ENDIF
        IF (fsize2 > 3)
         col 1725,
         CALL print(trim(cds->activity[fsize].augmented_care_details[4].local_id,3)), col 1742,
         CALL print(trim(cds->activity[fsize].augmented_care_details[4].care_period_disp,3)), col
         1744,
         CALL print(trim(cds->activity[fsize].augmented_care_details[4].care_period_num,3)),
         col 1746,
         CALL print(trim(cds->activity[fsize].augmented_care_details[4].care_period_source,3)), col
         1748,
         CALL print(trim(cds->activity[fsize].augmented_care_details[4].planned_ind,3)), col 1749,
         CALL print(trim(cds->activity[fsize].augmented_care_details[4].outcome_ind,3)),
         col 1751,
         CALL print(trim(cds->activity[fsize].augmented_care_details[4].intensive_care_days,3)), col
         1755,
         CALL print(trim(cds->activity[fsize].augmented_care_details[4].high_dep_level_days,3)), col
         1759,
         CALL print(trim(cds->activity[fsize].augmented_care_details[4].num_organs_supp,3)),
         col 1761, cds->activity[fsize].augmented_care_details[4].aug_start_date"YYYYMMDD;;d", col
         1769,
         cds->activity[fsize].augmented_care_details[4].aug_end_date"YYYYMMDD;;d", col 1777,
         CALL print(trim(cds->activity[fsize].augmented_care_details[4].aug_spec_fun_cd,3)),
         col 1780,
         CALL print(trim(cds->activity[fsize].augmented_care_details[4].aug_care_loc,3))
        ENDIF
        IF (fsize2 > 4)
         col 1782,
         CALL print(trim(cds->activity[fsize].augmented_care_details[5].local_id,3)), col 1799,
         CALL print(trim(cds->activity[fsize].augmented_care_details[5].care_period_disp,3)), col
         1801,
         CALL print(trim(cds->activity[fsize].augmented_care_details[5].care_period_num,3)),
         col 1803,
         CALL print(trim(cds->activity[fsize].augmented_care_details[5].care_period_source,3)), col
         1805,
         CALL print(trim(cds->activity[fsize].augmented_care_details[5].planned_ind,3)), col 1806,
         CALL print(trim(cds->activity[fsize].augmented_care_details[5].outcome_ind,3)),
         col 1808,
         CALL print(trim(cds->activity[fsize].augmented_care_details[5].intensive_care_days,3)), col
         1812,
         CALL print(trim(cds->activity[fsize].augmented_care_details[5].high_dep_level_days,3)), col
         1816,
         CALL print(trim(cds->activity[fsize].augmented_care_details[5].num_organs_supp,3)),
         col 1818, cds->activity[fsize].augmented_care_details[5].aug_start_date"YYYYMMDD;;d", col
         1826,
         cds->activity[fsize].augmented_care_details[5].aug_end_date"YYYYMMDD;;d", col 1834,
         CALL print(trim(cds->activity[fsize].augmented_care_details[5].aug_spec_fun_cd,3)),
         col 1837,
         CALL print(trim(cds->activity[fsize].augmented_care_details[5].aug_care_loc,3))
        ENDIF
        IF (fsize2 > 5)
         col 1839,
         CALL print(trim(cds->activity[fsize].augmented_care_details[6].local_id,3)), col 1856,
         CALL print(trim(cds->activity[fsize].augmented_care_details[6].care_period_disp,3)), col
         1858,
         CALL print(trim(cds->activity[fsize].augmented_care_details[6].care_period_num,3)),
         col 1860,
         CALL print(trim(cds->activity[fsize].augmented_care_details[6].care_period_source,3)), col
         1862,
         CALL print(trim(cds->activity[fsize].augmented_care_details[6].planned_ind,3)), col 1863,
         CALL print(trim(cds->activity[fsize].augmented_care_details[6].outcome_ind,3)),
         col 1865,
         CALL print(trim(cds->activity[fsize].augmented_care_details[6].intensive_care_days,3)), col
         1869,
         CALL print(trim(cds->activity[fsize].augmented_care_details[6].high_dep_level_days,3)), col
         1873,
         CALL print(trim(cds->activity[fsize].augmented_care_details[6].num_organs_supp,3)),
         col 1875, cds->activity[fsize].augmented_care_details[6].aug_start_date"YYYYMMDD;;d", col
         1883,
         cds->activity[fsize].augmented_care_details[6].aug_end_date"YYYYMMDD;;d", col 1891,
         CALL print(trim(cds->activity[fsize].augmented_care_details[6].aug_spec_fun_cd,3)),
         col 1894,
         CALL print(trim(cds->activity[fsize].augmented_care_details[6].aug_care_loc,3))
        ENDIF
        IF (fsize2 > 5)
         col 1896,
         CALL print(trim(cds->activity[fsize].augmented_care_details[7].local_id,3)), col 1913,
         CALL print(trim(cds->activity[fsize].augmented_care_details[7].care_period_disp,3)), col
         1915,
         CALL print(trim(cds->activity[fsize].augmented_care_details[7].care_period_num,3)),
         col 1917,
         CALL print(trim(cds->activity[fsize].augmented_care_details[7].care_period_source,3)), col
         1919,
         CALL print(trim(cds->activity[fsize].augmented_care_details[7].planned_ind,3)), col 1920,
         CALL print(trim(cds->activity[fsize].augmented_care_details[7].outcome_ind,3)),
         col 1922,
         CALL print(trim(cds->activity[fsize].augmented_care_details[7].intensive_care_days,3)), col
         1926,
         CALL print(trim(cds->activity[fsize].augmented_care_details[7].high_dep_level_days,3)), col
         1930,
         CALL print(trim(cds->activity[fsize].augmented_care_details[7].num_organs_supp,3)),
         col 1932, cds->activity[fsize].augmented_care_details[7].aug_start_date"YYYYMMDD;;d", col
         1940,
         cds->activity[fsize].augmented_care_details[7].aug_end_date"YYYYMMDD;;d", col 1948,
         CALL print(trim(cds->activity[fsize].augmented_care_details[7].aug_spec_fun_cd,3)),
         col 1951,
         CALL print(trim(cds->activity[fsize].augmented_care_details[7].aug_care_loc,3))
        ENDIF
        IF (fsize2 > 7)
         col 1953,
         CALL print(trim(cds->activity[fsize].augmented_care_details[8].local_id,3)), col 1970,
         CALL print(trim(cds->activity[fsize].augmented_care_details[8].care_period_disp,3)), col
         1972,
         CALL print(trim(cds->activity[fsize].augmented_care_details[8].care_period_num,3)),
         col 1974,
         CALL print(trim(cds->activity[fsize].augmented_care_details[8].care_period_source,3)), col
         1976,
         CALL print(trim(cds->activity[fsize].augmented_care_details[8].planned_ind,3)), col 1977,
         CALL print(trim(cds->activity[fsize].augmented_care_details[8].outcome_ind,3)),
         col 1979,
         CALL print(trim(cds->activity[fsize].augmented_care_details[8].intensive_care_days,3)), col
         1983,
         CALL print(trim(cds->activity[fsize].augmented_care_details[8].high_dep_level_days,3)), col
         1987,
         CALL print(trim(cds->activity[fsize].augmented_care_details[8].num_organs_supp,3)),
         col 1989, cds->activity[fsize].augmented_care_details[8].aug_start_date"YYYYMMDD;;d", col
         1997,
         cds->activity[fsize].augmented_care_details[8].aug_end_date"YYYYMMDD;;d", col 2005,
         CALL print(trim(cds->activity[fsize].augmented_care_details[8].aug_spec_fun_cd,3)),
         col 2008,
         CALL print(trim(cds->activity[fsize].augmented_care_details[8].aug_care_loc,3))
        ENDIF
        IF (fsize2 > 8)
         col 2010,
         CALL print(trim(cds->activity[fsize].augmented_care_details[9].local_id,3)), col 2027,
         CALL print(trim(cds->activity[fsize].augmented_care_details[9].care_period_disp,3)), col
         2029,
         CALL print(trim(cds->activity[fsize].augmented_care_details[9].care_period_num,3)),
         col 2031,
         CALL print(trim(cds->activity[fsize].augmented_care_details[9].care_period_source,3)), col
         2033,
         CALL print(trim(cds->activity[fsize].augmented_care_details[9].planned_ind,3)), col 2034,
         CALL print(trim(cds->activity[fsize].augmented_care_details[9].outcome_ind,3)),
         col 2036,
         CALL print(trim(cds->activity[fsize].augmented_care_details[9].intensive_care_days,3)), col
         2040,
         CALL print(trim(cds->activity[fsize].augmented_care_details[9].high_dep_level_days,3)), col
         2044,
         CALL print(trim(cds->activity[fsize].augmented_care_details[9].num_organs_supp,3)),
         col 2046, cds->activity[fsize].augmented_care_details[9].aug_start_date"YYYYMMDD;;d", col
         2054,
         cds->activity[fsize].augmented_care_details[9].aug_end_date"YYYYMMDD;;d", col 2062,
         CALL print(trim(cds->activity[fsize].augmented_care_details[9].aug_spec_fun_cd,3)),
         col 2065,
         CALL print(trim(cds->activity[fsize].augmented_care_details[9].aug_care_loc,3))
        ENDIF
       ENDIF
       IF ((((cds->activity[fsize].maternity_delivery_flag=1)) OR ((cds->activity[fsize].birth_flag=1
       ))) )
        CALL echo("Printing Maternity/Birth Details"), col 2067,
        CALL print(trim(cds->activity[fsize].number_of_babies,3)),
        col 2068, cds->activity[fsize].first_antenatal_dt"YYYYMMDD;;d", col 2076,
        CALL print(trim(cds->activity[fsize].antenatal_gp_cd,3)), col 2084,
        CALL print(trim(cds->activity[fsize].antenatal_gp_prac_cd,3)),
        col 2090,
        CALL print(trim(cds->activity[fsize].del_place_type,3)), col 2091,
        CALL print(trim(cds->activity[fsize].del_place_chg_reas,3)), col 2092,
        CALL print(trim(cds->activity[fsize].anes_during_del,3)),
        col 2093,
        CALL print(trim(cds->activity[fsize].anes_post_del,3)), col 2094,
        CALL print(trim(cds->activity[fsize].gest_len,3)), col 2096,
        CALL print(trim(cds->activity[fsize].labor_onset_meth,3)),
        col 2097, cds->activity[fsize].delivery_date"YYYYMMDD;;d", fsize2 = size(cds->activity[fsize]
         .baby_details,5)
        IF (fsize2 > 0)
         col 2105,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_birth_order,3)), col 2106,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_del_method,3)), col 2107,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_gest_length,3)),
         col 2109,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_resus_meth,3)), col 2110,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_pers_cond_stat,3)), col 2111,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_del_place_type,3)),
         col 2112,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_loc_pat_id,3)), col 2122,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_org_cd,3)), col 2128,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_nhs_num,3)),
         col 2145,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_nhs_stat,3)), col 2147,
         cds->activity[fsize].baby_details[1].baby_birth_date"YYYYMMDD;;d", col 2155,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_birth_wt,3)),
         col 2159,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_live_still,3)), col 2160,
         CALL print(trim(cds->activity[fsize].baby_details[1].baby_sex,3))
        ENDIF
        IF (fsize2 > 1)
         col 2161,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_birth_order,3)), col 2162,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_del_method,3)), col 2163,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_gest_length,3)),
         col 2165,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_resus_meth,3)), col 2166,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_pers_cond_stat,3)), col 2167,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_del_place_type,3)),
         col 2168,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_loc_pat_id,3)), col 2178,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_org_cd,3)), col 2184,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_nhs_num,3)),
         col 2201,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_nhs_stat,3)), col 2203,
         cds->activity[fsize].baby_details[2].baby_birth_date"YYYYMMDD;;d", col 2211,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_birth_wt,3)),
         col 2215,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_live_still,3)), col 2216,
         CALL print(trim(cds->activity[fsize].baby_details[2].baby_sex,3))
        ENDIF
        IF (fsize2 > 2)
         col 2217,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_birth_order,3)), col 2218,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_del_method,3)), col 2219,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_gest_length,3)),
         col 2221,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_resus_meth,3)), col 2222,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_pers_cond_stat,3)), col 2223,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_del_place_type,3)),
         col 2224,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_loc_pat_id,3)), col 2234,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_org_cd,3)), col 2240,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_nhs_num,3)),
         col 2257,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_nhs_stat,3)), col 2259,
         cds->activity[fsize].baby_details[3].baby_birth_date"YYYYMMDD;;d", col 2267,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_birth_wt,3)),
         col 2271,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_live_still,3)), col 2272,
         CALL print(trim(cds->activity[fsize].baby_details[3].baby_sex,3))
        ENDIF
        IF (fsize2 > 3)
         col 2273,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_birth_order,3)), col 2274,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_del_method,3)), col 2275,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_gest_length,3)),
         col 2277,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_resus_meth,3)), col 2278,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_pers_cond_stat,3)), col 2279,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_del_place_type,3)),
         col 2280,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_loc_pat_id,3)), col 2290,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_org_cd,3)), col 2296,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_nhs_num,3)),
         col 2313,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_nhs_stat,3)), col 2315,
         cds->activity[fsize].baby_details[4].baby_birth_date"YYYYMMDD;;d", col 2323,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_birth_wt,3)),
         col 2327,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_live_still,3)), col 2328,
         CALL print(trim(cds->activity[fsize].baby_details[4].baby_sex,3))
        ENDIF
        IF (fsize2 > 4)
         col 2329,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_birth_order,3)), col 2330,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_del_method,3)), col 2331,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_gest_length,3)),
         col 2333,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_resus_meth,3)), col 2334,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_pers_cond_stat,3)), col 2335,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_del_place_type,3)),
         col 2336,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_loc_pat_id,3)), col 2346,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_org_cd,3)), col 2352,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_nhs_num,3)),
         col 2369,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_nhs_stat,3)), col 2371,
         cds->activity[fsize].baby_details[5].baby_birth_date"YYYYMMDD;;d", col 2379,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_birth_wt,3)),
         col 2383,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_live_still,3)), col 2384,
         CALL print(trim(cds->activity[fsize].baby_details[5].baby_sex,3))
        ENDIF
        IF (fsize2 > 5)
         col 2385,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_birth_order,3)), col 2386,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_del_method,3)), col 2387,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_gest_length,3)),
         col 2389,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_resus_meth,3)), col 2390,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_pers_cond_stat,3)), col 2391,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_del_place_type,3)),
         col 2392,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_loc_pat_id,3)), col 2402,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_org_cd,3)), col 2408,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_nhs_num,3)),
         col 2425,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_nhs_stat,3)), col 2427,
         cds->activity[fsize].baby_details[6].baby_birth_date"YYYYMMDD;;d", col 2435,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_birth_wt,3)),
         col 2439,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_live_still,3)), col 2440,
         CALL print(trim(cds->activity[fsize].baby_details[6].baby_sex,3))
        ENDIF
        IF (fsize2 > 6)
         col 2441,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_birth_order,3)), col 2442,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_del_method,3)), col 2443,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_gest_length,3)),
         col 2445,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_resus_meth,3)), col 2446,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_pers_cond_stat,3)), col 2447,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_del_place_type,3)),
         col 2448,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_loc_pat_id,3)), col 2458,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_org_cd,3)), col 2464,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_nhs_num,3)),
         col 2481,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_nhs_stat,3)), col 2483,
         cds->activity[fsize].baby_details[7].baby_birth_date"YYYYMMDD;;d", col 2491,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_birth_wt,3)),
         col 2495,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_live_still,3)), col 2496,
         CALL print(trim(cds->activity[fsize].baby_details[7].baby_sex,3))
        ENDIF
        IF (fsize2 > 7)
         col 2497,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_birth_order,3)), col 2498,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_del_method,3)), col 2549,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_gest_length,3)),
         col 2501,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_resus_meth,3)), col 2502,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_pers_cond_stat,3)), col 2503,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_del_place_type,3)),
         col 2504,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_loc_pat_id,3)), col 2514,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_org_cd,3)), col 2520,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_nhs_num,3)),
         col 2537,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_nhs_stat,3)), col 2539,
         cds->activity[fsize].baby_details[8].baby_birth_date"YYYYMMDD;;d", col 2547,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_birth_wt,3)),
         col 2551,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_live_still,3)), col 2552,
         CALL print(trim(cds->activity[fsize].baby_details[8].baby_sex,3))
        ENDIF
        IF (fsize2 > 8)
         col 2553,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_birth_order,3)), col 2554,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_del_method,3)), col 2555,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_gest_length,3)),
         col 2557,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_resus_meth,3)), col 2558,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_pers_cond_stat,3)), col 2559,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_del_place_type,3)),
         col 2560,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_loc_pat_id,3)), col 2570,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_org_cd,3)), col 2576,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_nhs_num,3)),
         col 2593,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_nhs_stat,3)), col 2595,
         cds->activity[fsize].baby_details[9].baby_birth_date"YYYYMMDD;;d", col 2603,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_birth_wt,3)),
         col 2607,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_live_still,3)), col 2608,
         CALL print(trim(cds->activity[fsize].baby_details[9].baby_sex,3))
        ENDIF
        col 2609,
        CALL print(trim(cds->activity[fsize].mom_local_pat_id,3)), col 2619,
        CALL print(trim(cds->activity[fsize].mom_org_cd,3)), col 2625,
        CALL print(trim(cds->activity[fsize].mom_nhs_new,3)),
        col 2652,
        CALL print(trim(cds->activity[fsize].mom_nhs_status,3)), col 2654,
        cds->activity[fsize].mom_birth_date"YYYYMMDD;;d", col 2662,
        CALL print(trim(cds->activity[fsize].mom_address_cd,3)),
        col 2663,
        CALL print(trim(cds->activity[fsize].mom_address_1,3)), col 2698,
        CALL print(trim(cds->activity[fsize].mom_address_2,3)), col 2733,
        CALL print(trim(cds->activity[fsize].mom_address_3,3)),
        col 2768,
        CALL print(trim(cds->activity[fsize].mom_address_4,3)), col 2803,
        CALL print(trim(cds->activity[fsize].mom_address_5,3))
        IF (trim(cds->activity[fsize].mom_post_cd,3)=" ")
         cds->activity[fsize].mom_post_cd = d_not_known_postcode
        ENDIF
        col 2838,
        CALL print(trim(cds->activity[fsize].mom_post_cd,3)), col 2846,
        CALL print(trim(cds->activity[fsize].mom_pct,3))
       ENDIF
       IF (trim(cds->activity[fsize].residence_pct,3) != " ")
        col 2852,
        CALL print(trim(cds->activity[fsize].residence_pct,3))
       ELSE
        col 2852, "Q9900"
       ENDIF
       IF ((cdsbatch->org_code IN ("RQX", "RNH", "5C5")))
        col 2857,
        CALL print(trim(cds->activity[fsize].local_subspecialty,3)), col 2862,
        CALL print(trim(cds->activity[fsize].wait_duration,3)), fsize2 = size(cds->activity[fsize].
         ward_stay_details,5), ward = cnvtstring(fsize2),
        col 2867, ward, col 2870,
        CALL print(trim(cds->activity[fsize].start_loc_nurse_unit,3))
        IF (fsize2 > 0)
         col 2910,
         CALL print(trim(cds->activity[fsize].ward_stay_details[1].loc_nurse_unit,3))
        ENDIF
        IF (fsize2 > 1)
         col 2950,
         CALL print(trim(cds->activity[fsize].ward_stay_details[2].loc_nurse_unit,3))
        ENDIF
        IF (fsize2 > 2)
         col 2990,
         CALL print(trim(cds->activity[fsize].ward_stay_details[3].loc_nurse_unit,3))
        ENDIF
        IF (fsize2 > 3)
         col 3030,
         CALL print(trim(cds->activity[fsize].ward_stay_details[4].loc_nurse_unit,3))
        ENDIF
        IF (fsize2 > 4)
         col 3070,
         CALL print(trim(cds->activity[fsize].ward_stay_details[5].loc_nurse_unit,3))
        ENDIF
        IF (fsize2 > 5)
         col 3110,
         CALL print(trim(cds->activity[fsize].ward_stay_details[6].loc_nurse_unit,3))
        ENDIF
        IF (fsize2 > 6)
         col 3150,
         CALL print(trim(cds->activity[fsize].ward_stay_details[7].loc_nurse_unit,3))
        ENDIF
        IF (fsize2 > 7)
         col 3190,
         CALL print(trim(cds->activity[fsize].ward_stay_details[8].loc_nurse_unit,3))
        ENDIF
        IF (fsize2 > 8)
         col 3230,
         CALL print(trim(cds->activity[fsize].ward_stay_details[9].loc_nurse_unit,3))
        ENDIF
        col 3270,
        CALL print(trim(cds->activity[fsize].end_loc_nurse_unit,3)), col 3310,
        CALL print(cnvtstring(cds->activity[fsize].error_flag)), col 3312, cds->activity[fsize].
        adm_date"YYYYMMDDHHMM;;q",
        col 3324, cds->activity[fsize].disch_date"YYYYMMDDHHMM;;q", col 3336,
        cds->activity[fsize].episode_start_dt"YYYYMMDDHHMM;;q", col 3348, cds->activity[fsize].
        episode_end_dt"YYYYMMDDHHMM;;q",
        col 3360, cds->activity[fsize].birth_dt"YYYYMMDDHHMM;;q", col 3372,
        cds->activity[fsize].delivery_date"YYYYMMDDHHMM;;q", col 3384,
        CALL print(cnvtstring(cds->activity[fsize].person_id)),
        col 3404,
        CALL print(cnvtstring(cds->activity[fsize].encntr_id)), col 3424,
        CALL print(cnvtstring(cds->activity[fsize].svc_id)), col 3444,
        CALL print(cnvtstring(cds->activity[fsize].pm_wait_list_id)),
        col 3464,
        CALL print(cnvtstring(cds->activity[fsize].episode_id)), col 3484,
        CALL print(trim(cds->activity[fsize].error_string,3))
       ENDIF
      WITH nocounter, format = stream, maxcol = 3600,
       append, maxrow = 1, formfeed = none
     ;end select
     CALL echo(build2("Record->",trim(cnvtstring(fsize),3)," of ",trim(cnvtstring(ztotal),3)))
     SET cdsbatch->batch[rcnt].content[fsize].cds_type_cd = cds->activity[fsize].cds_type_cd
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
  IF (trim(cdsbatch->batch[rcnt].filename,3)=" ")
   SET cdsbatch->batch[rcnt].filename = cnvtlower(replace(cds->finished_file,cdsoutdir,"",1))
  ENDIF
  CALL echo(build("Filename from create->",cdsbatch->batch[rcnt].filename))
  CALL echo(build2("updating: ",cds->activity[(fsize - 1)].cds_batch_content_id))
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
  CALL echo("Table Updates")
  IF ((cdsbatch->testmode=0))
   UPDATE  FROM cds_batch_content cbc,
     (dummyt d  WITH seq = value(size(cds->activity,5)))
    SET cbc.cds_batch_id = cdsbatch->batch[rcnt].cds_batch_id, cbc.cds_type_cd = cds->activity[d.seq]
     .cds_type_cd, cbc.updt_dt_tm = cnvtdatetime(sysdate),
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
      sysdate), cbch.cds_type_cd = cds->activity[d.seq].cds_type_cd,
     cbch.activity_dt_tm = cnvtdatetime(cds->activity[d.seq].point_dt_tm)
    PLAN (d)
     JOIN (cbch
     WHERE (cbch.cds_batch_content_id=cds->activity[d.seq].cds_batch_content_id)
      AND cbch.cds_batch_id=0)
    WITH nocounter, maxcommit = 100
   ;end update
   COMMIT
  ENDIF
  CALL echo(build("Filename from create->",cdsbatch->batch[rcnt].filename))
  CALL echo(cdsoutdir)
  CALL echo(cds->finished_file)
 ENDIF
 IF (pref_18ww="ON")
  EXECUTE ukr_rtt_extract
 ENDIF
 EXECUTE ukr_cdst_ip_admit_extract
 EXECUTE ukr_cdst_ip_wardstay_extract
#exit_script
 FREE RECORD cds
 FREE RECORD exception
 FREE RECORD ce_id
END GO
