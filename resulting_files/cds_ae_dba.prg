CREATE PROGRAM cds_ae:dba
 SET last_mod = "162346"
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
 DECLARE pm_get_cvo_alias() = c40
 RECORD local(
   1 specialty_code = f8
 )
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
 SET last_mod = "162346"
 FREE RECORD cds
 RECORD cds(
   1 finished_file = c400
   1 activity[*]
     2 new_comm_ind = i4
     2 admin_category_cd = f8
     2 overseas_status = c1
     2 comm_org_id = f8
     2 age_activity = i4
     2 med_service_cd = f8
     2 service_category_cd = f8
     2 nhs_svc_agr_line_nbr = c15
     2 local_subspecialty = c5
     2 hrg_code = c3
     2 primary_icd = c6
     2 opcs4_cd1 = c7
     2 encntr_type = f8
     2 gp_ind = i4
     2 copy_ind = i4
     2 rulecopy1 = c5
     2 rulecopy2 = c5
     2 rulecopy3 = c5
     2 calc_comm = c5
     2 pt_class = c1
     2 encntr_id = f8
     2 cds_batch_content_id = f8
     2 point_dt_tm = dq8
     2 person_id = f8
     2 org_id = f8
     2 trust_org_id = f8
     2 version_number = c6
     2 cds_type = c3
     2 protocol_id = c3
     2 unique_cds_id = c35
     2 nhs_org_code_type = c1
     2 update_type = c1
     2 bulk_repl_cds_gp = c3
     2 test_ind = c1
     2 extract_dt_time = dq8
     2 period_start_dt = dq8
     2 period_end_dt = dq8
     2 census_dt = dq8
     2 provider_cd = c5
     2 primary_recip = c5
     2 copy_1 = c5
     2 copy_2 = c5
     2 copy_3 = c5
     2 copy_4 = c5
     2 copy_5 = c5
     2 copy_6 = c5
     2 copy_7 = c5
     2 main_comm = c5
     2 anon = i2
     2 anonymous = i2
     2 sender_identity = c5
     2 local_patient_id = c10
     2 patient_id_org = c5
     2 patient
       3 org_cd_prv = c5
       3 nhs_number = c10
       3 nhs_num_old = c17
       3 dob = dq8
       3 carer_support_ind = c2
       3 alias_status = c2
       3 sex = c1
     2 name_format_ind = c1
     2 patient_forename = c35
     2 patient_surname = c35
     2 patient_fullname = c70
     2 pt_address_format_cd = c1
     2 pt_address_1 = c35
     2 pt_address_2 = c35
     2 pt_address_3 = c35
     2 pt_address_4 = c35
     2 pt_address_5 = c35
     2 pt_post_code = c8
     2 pt_sha = vc
     2 ethnic_group = c2
     2 marital_status = c1
     2 admin_category = c3
     2 gp_code = c8
     2 gp_practice = c6
     2 gp_pct = c5
     2 referrer_cd = c8
     2 referrer_org_cd = c6
     2 consultant_code = c8
     2 attend
       3 attend_num = c12
       3 attend_cat_cd = f8
       3 attend_cat = c1
       3 arrival_date_time = dq8
       3 arrival_mode_cd = f8
       3 arrival_mode = c1
       3 arrival_mode_meaning = vc
       3 ref_source_cd = f8
       3 ref_source = c2
       3 patient_group_cd = f8
       3 patient_group = c2
       3 incident_location_type_cd = f8
       3 incident_location_type = c2
       3 initial_assessment_time = dq8
       3 time_seen_for_treatment = dq8
       3 staff_member_code = c3
       3 attend_conclusion_time = dq8
       3 depart_time = dq8
       3 attend_disposal = c2
       3 attend_disposal_cd = f8
     2 treatment_function_code = c3
     2 main_specialty_code = c3
     2 comm_ser_nbr = c6
     2 prov_ref_nbr = c17
     2 comm_ref_nbr = c17
     2 org_cd_prov = c5
     2 org_cd_comm = c5
     2 investigation
       3 invest_code_1 = c6
       3 invest_cost1 = c2
       3 invest_code_2 = c6
       3 invest_cost2 = c2
     2 diag
       3 diag_code_1 = c6
       3 diag_code_1_id = i4
       3 diag_code_2 = c6
       3 diag_code_2_id = i4
     2 treatment
       3 treat_code_1 = c6
       3 treat_code_2 = c6
       3 sub_treat_code_1 = c1
       3 sub_treat_code_2 = c1
     2 hrg
       3 healthcare_res_group_code = c3
       3 hrg_code_version_num = c3
       3 hrg_dgvp_opcs = c3
       3 hrg_dgvp_read = c3
       3 read_code_version = c1
     2 residence_pct = c5
     2 stream = c40
     2 stream_cd = f8
     2 neonatal_care_lvl = c1
     2 adm_method = c2
     2 spell_number = c27
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
     2 consultant_person_id = f8
     2 encntr_active_ind = i2
     2 encntr_create_dt_tm = dq8
     2 encntr_create_prsnl_id = f8
     2 encntr_updt_dt_tm = dq8
     2 encntr_updt_id = f8
     2 reason_for_visit = vc
     2 disch_disposition_cd = f8
     2 reg_dt_tm = dq8
     2 reg_prsnl_id = f8
     2 depart_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 admit_mode_cd = f8
     2 admit_src_cd = f8
     2 readmit_cd = f8
     2 disch_to_loctn_cd = f8
     2 accident_dt_tm = dq8
     2 accident_cd = f8
     2 ambulance_arrive_cd = f8
     2 ambulance_serv_nbr = vc
     2 place_cd = f8
     2 stream_cd = f8
     2 edobs_cd = f8
     2 school_name = vc
     2 school_org_id = f8
     2 tracking_checkin
       3 checkin_dt_tm = dq8
       3 checkout_dt_tm = dq8
     2 tracking_event
       3 requested_dt_tm = dq8
       3 tracking_group_cd = f8
     2 tetanus_result_val = vc
     2 contributor_system_cd = f8
     2 disch_prsnl = f8
 )
 SET last_mod = "163752"
 DECLARE admission = vc WITH public, constant("ADMISSION")
 DECLARE assessment = vc WITH public, constant("ASSESSMENT")
 DECLARE treatmentstart = vc WITH public, constant("TREATMENTSTART")
 DECLARE treatment_code_set = f8 WITH public, constant(100718.00)
 DECLARE ae_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"AE"))
 DECLARE gp_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE referdoc = f8 WITH public, noconstant(uar_get_code_by("MEANING",333,"REFERDOC"))
 DECLARE active_status_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE consultant_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE org_alias_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",334,"NHSORGALIAS"))
 DECLARE nhs_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE home_addr_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE cnn_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE fin_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE passsite_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",356,"PASSITECODE"))
 DECLARE commissioner_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",352,"COMMISSIONER"))
 DECLARE nhs_report_code = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",73,"NHSREPORT"))
 DECLARE nhs_serial_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",334,"NHSSERIALNUM"))
 DECLARE doccnbr = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"DOCCNBR"))
 DECLARE nongp = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"NONGP"))
 DECLARE external_id = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"EXTERNALID"))
 DECLARE visitid_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"VISITID"))
 DECLARE staff_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",333,"DISCHARGEDOC"))
 DECLARE prsnl_name_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",213,"PRSNL"))
 DECLARE diag_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",401,"DIAG"))
 DECLARE icd10_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",400,"ICD10"))
 DECLARE icd10_cdwho = f8 WITH public, noconstant(uar_get_code_by("MEANING",400,"ICD10WHO"))
 DECLARE ae_treatment_2_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "AETREATMENT2"))
 DECLARE ae_treatment_1_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "AETREATMENT1"))
 DECLARE ae_subtreatment_1_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "TREATMENT1SUBANALYSIS"))
 DECLARE ae_subtreatment_2_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "TREATMENT2SUBANALYSIS"))
 DECLARE proc_principle_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",401,
   "PROCEDURE"))
 DECLARE opcs4_source_voc_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",400,"OPCS4"))
 DECLARE carriercd = f8 WITH public, noconstant(uar_get_code_by("MEANING",370,"CARRIER"))
 DECLARE sponsorcd = f8 WITH public, noconstant(uar_get_code_by("MEANING",370,"SPONSOR"))
 DECLARE overseascd = f8 WITH public, noconstant(uar_get_code_by("MEANING",356,"PASOVERSEAS"))
 DECLARE maincommis = f8 WITH public, noconstant(uar_get_code_by("MEANING",369,"MAINCOMMISS"))
 DECLARE sla_type = f8 WITH public, noconstant(uar_get_code_by("MEANING",26307,"SLA"))
 DECLARE ae_treatment_1_dscn_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "AETREATMENT1DSCN052006"))
 DECLARE ae_treatment_2_dscn_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "AETREATMENT2DSCN052006"))
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
 DECLARE nhs_org_alias_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",334,"NHSORGALIAS"))
 DECLARE nhs_trust_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",278,"NHSTRUST"))
 DECLARE stream_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",356,"STREAM"))
 DECLARE edobs_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",356,"EDOBS"))
 DECLARE school_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",338,"SCHOOL"))
 CALL echo("Now in cds_ae")
 SET stat = alterlist(cds->activity,size(cdsbatch->batch[rcnt].content,5))
 SELECT INTO "nl:"
  sex = pm_get_cvo_alias(p.sex_cd,nhs_report_code), admin_category = evaluate(e.accommodation_cd,0.0,
   pm_get_cvo_alias(pwl.admit_category_cd,nhs_report_code),pm_get_cvo_alias(e.accommodation_cd,
    nhs_report_code)), admin_category_cd = evaluate(e.accommodation_cd,0.0,pwl.admit_category_cd,e
   .accommodation_cd),
  living_dependency = pm_get_cvo_alias(pp.living_dependency_cd,nhs_report_code), arrival_mode =
  pm_get_cvo_alias(eacc.ambulance_arrive_cd,nhs_report_code), patient_group = pm_get_cvo_alias(eacc
   .accident_cd,nhs_report_code),
  incident_location_type = pm_get_cvo_alias(eacc.place_cd,nhs_report_code), ref_source =
  pm_get_cvo_alias(e.admit_mode_cd,nhs_report_code), alias_status = pm_get_cvo_alias(pa
   .person_alias_status_cd,nhs_report_code),
  attend_disposal = pm_get_cvo_alias(e.disch_disposition_cd,nhs_report_code), attend_cat =
  pm_get_cvo_alias(e.readmit_cd,nhs_report_code), main_specialty_code = pm_get_cvo_alias(e
   .service_category_cd,nhs_report_code),
  treatment_function_code = pm_get_cvo_alias(e.med_service_cd,nhs_report_code), ethnic_group =
  pm_get_cvo_alias(p.ethnic_grp_cd,nhs_report_code), marital_type = pm_get_cvo_alias(p
   .marital_type_cd,nhs_report_code),
  local_subspecialty = pm_get_cvo_alias(e.med_service_cd,local->specialty_code), refer_fac =
  pm_get_cvo_alias(e.refer_facility_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cdsbatch->batch[rcnt].content,5))),
   encounter e,
   encntr_alias ea,
   encntr_accident eacc,
   person p,
   pm_wait_list pwl,
   person_patient pp,
   person_alias pa,
   encntr_alias ea,
   eem_benefit_alloc eba,
   encntr_org_reltn eor,
   organization_alias oa2,
   person_org_reltn por,
   dummyt d1
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=cdsbatch->batch[rcnt].content[d.seq].parent_entity_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pp
   WHERE (pp.person_id= Outerjoin(p.person_id)) )
   JOIN (eacc
   WHERE (eacc.encntr_id= Outerjoin(e.encntr_id)) )
   JOIN (eba
   WHERE (eba.encntr_id= Outerjoin(e.encntr_id)) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(nhs_cd))
    AND (pa.active_ind= Outerjoin(1))
    AND (pa.active_status_cd= Outerjoin(active_status_cd)) )
   JOIN (eor
   WHERE (eor.encntr_id= Outerjoin(e.encntr_id))
    AND (eor.encntr_org_reltn_cd= Outerjoin(commissioner_cd))
    AND (eor.active_ind= Outerjoin(1)) )
   JOIN (oa2
   WHERE (oa2.organization_id= Outerjoin(eor.organization_id))
    AND (oa2.org_alias_type_cd= Outerjoin(org_alias_cd)) )
   JOIN (pwl
   WHERE (pwl.encntr_id= Outerjoin(e.encntr_id)) )
   JOIN (por
   WHERE (por.person_id= Outerjoin(e.person_id))
    AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (por.person_org_reltn_cd= Outerjoin(school_cd)) )
   JOIN (d1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (fin_cd, cnn_cd)
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   IF (e.depart_dt_tm > 0)
    cds->activity[d.seq].point_dt_tm = e.depart_dt_tm
   ELSEIF (e.disch_dt_tm > 0)
    cds->activity[d.seq].point_dt_tm = e.disch_dt_tm
   ELSE
    cds->activity[d.seq].point_dt_tm = cnvtdatetime(sysdate)
   ENDIF
   cds->activity[d.seq].encntr_id = e.encntr_id, cds->activity[d.seq].person_id = e.person_id, cds->
   activity[d.seq].org_id = e.organization_id,
   cds->activity[d.seq].deceased_dt_tm = p.deceased_dt_tm, cds->activity[d.seq].rtt.pathway_org =
   refer_fac, cds->activity[d.seq].encntr_type = e.encntr_type_cd,
   cds->activity[d.seq].patient.dob = p.birth_dt_tm, cds->activity[d.seq].age_activity = (
   datetimediff(cds->activity[d.seq].point_dt_tm,cds->activity[d.seq].dob)/ 365)
   IF (e.med_service_cd > 0)
    cds->activity[d.seq].treatment_function_code = treatment_function_code, cds->activity[d.seq].
    med_service_cd = e.med_service_cd, cds->activity[d.seq].local_subspecialty = local_subspecialty
   ENDIF
   IF (e.service_category_cd > 0)
    cds->activity[d.seq].main_specialty_code = main_specialty_code, cds->activity[d.seq].
    service_category_cd = e.service_category_cd
   ENDIF
   cds->activity[d.seq].attend.arrival_date_time = e.arrive_dt_tm
   IF (e.depart_dt_tm > 0)
    cds->activity[d.seq].attend.depart_time = e.depart_dt_tm
   ELSE
    cds->activity[d.seq].attend.depart_time = e.disch_dt_tm
   ENDIF
   IF (e.disch_disposition_cd > 0)
    cds->activity[d.seq].attend.attend_disposal = attend_disposal
   ENDIF
   cds->activity[d.seq].anon = 0
   IF (e.readmit_cd > 0)
    cds->activity[d.seq].attend.attend_cat = attend_cat
   ENDIF
   cds->activity[d.seq].cds_batch_content_id = cdsbatch->batch[rcnt].content[d.seq].
   cds_batch_content_id, cds->activity[d.seq].version_number = "NHS003", cds->activity[d.seq].
   protocol_id = "010",
   cds->activity[d.seq].period_start_dt = cdsbatch->batch[rcnt].cds_batch_start_dt, cds->activity[d
   .seq].period_end_dt = cdsbatch->batch[rcnt].cds_batch_end_dt, cds->activity[d.seq].extract_dt_time
    = cnvtdatetime(sysdate),
   cds->activity[d.seq].update_type = cnvtstring(cdsbatch->batch[rcnt].content[d.seq].update_del_flag
    ), cds->activity[d.seq].cds_type = uar_get_code_meaning(cdsbatch->batch[rcnt].content[d.seq].
    cds_type_cd), cds->activity[d.seq].sender_identity = build(cnvtupper(cdsbatch->org_code),"00"),
   cds->activity[d.seq].org_cd_prov = build(cnvtupper(cdsbatch->org_code),"00"), cds->activity[d.seq]
   .patient_id_org = build(cnvtupper(cdsbatch->org_code),"00"), cds->activity[d.seq].unique_cds_id =
   build("B",cnvtupper(cdsbatch->org_code),"00",cnvtstring(cdsbatch->batch[rcnt].content[d.seq].
     cds_batch_content_id)),
   cds->activity[d.seq].patient_forename = p.name_first, cds->activity[d.seq].patient_surname = p
   .name_last, cds->activity[d.seq].name_format_ind = "1",
   cds->activity[d.seq].patient_fullname = p.name_full_formatted
   IF (trim(pa.alias) != " ")
    cds->activity[d.seq].nhs_number = pa.alias
    IF ((cdsbatch->anonymous=1))
     cds->activity[d.seq].anonymous = 1
    ENDIF
   ENDIF
   cds->activity[d.seq].patient.alias_status = alias_status, cds->activity[d.seq].comm_ref_nbr = "8"
   IF (ea.encntr_alias_type_cd=cnn_cd)
    cds->activity[d.seq].local_patient_id = cnvtalias(ea.alias,ea.alias_pool_cd)
   ELSEIF (ea.encntr_alias_type_cd=fin_cd)
    cds->activity[d.seq].attend.attend_num = ea.alias, cds->activity[d.seq].fin_nbr = ea.alias
   ENDIF
   IF (trim(oa2.alias,3) != " ")
    cds->activity[d.seq].org_cd_comm = build(oa2.alias,"00")
   ENDIF
   cds->activity[d.seq].marital_status = marital_type, cds->activity[d.seq].ethnic_group =
   ethnic_group, cds->activity[d.seq].admin_category = admin_category,
   cds->activity[d.seq].admin_category_cd = admin_category_cd
   IF (p.sex_cd > 0)
    cds->activity[d.seq].sex = sex
   ENDIF
   IF (pp.living_dependency_cd > 0)
    cds->activity[d.seq].carer_support_ind = living_dependency
   ENDIF
   IF (eacc.ambulance_arrive_cd > 0)
    cds->activity[d.seq].attend.arrival_mode = arrival_mode, cds->activity[d.seq].attend.
    arrival_mode_meaning = uar_get_code_meaning(eacc.ambulance_arrive_cd), cds->activity[d.seq].
    attend.arrival_mode_cd = eacc.ambulance_arrive_cd
   ENDIF
   IF (eacc.accident_cd > 0)
    cds->activity[d.seq].attend.patient_group = patient_group
   ENDIF
   IF (eacc.place_cd > 0)
    cds->activity[d.seq].attend.incident_location_type = incident_location_type
   ENDIF
   IF (e.admit_mode_cd > 0)
    cds->activity[d.seq].attend.ref_source = ref_source
   ENDIF
   cds->activity[d.seq].encntr_active_ind = e.active_ind, cds->activity[d.seq].encntr_create_dt_tm =
   e.create_dt_tm, cds->activity[d.seq].encntr_create_prsnl_id = e.create_prsnl_id,
   cds->activity[d.seq].encntr_updt_dt_tm = e.updt_dt_tm, cds->activity[d.seq].encntr_updt_id = e
   .updt_id, cds->activity[d.seq].reason_for_visit = e.reason_for_visit,
   cds->activity[d.seq].disch_disposition_cd = e.disch_disposition_cd, cds->activity[d.seq].reg_dt_tm
    = e.reg_dt_tm, cds->activity[d.seq].reg_prsnl_id = e.reg_prsnl_id,
   cds->activity[d.seq].depart_dt_tm = e.depart_dt_tm, cds->activity[d.seq].disch_dt_tm = e
   .disch_dt_tm, cds->activity[d.seq].loc_facility_cd = e.loc_facility_cd,
   cds->activity[d.seq].loc_building_cd = e.loc_building_cd, cds->activity[d.seq].loc_nurse_unit_cd
    = e.loc_nurse_unit_cd, cds->activity[d.seq].loc_room_cd = e.loc_room_cd,
   cds->activity[d.seq].loc_bed_cd = e.loc_bed_cd, cds->activity[d.seq].admit_mode_cd = e
   .admit_mode_cd, cds->activity[d.seq].admit_src_cd = e.admit_src_cd,
   cds->activity[d.seq].readmit_cd = e.readmit_cd, cds->activity[d.seq].disch_to_loctn_cd = e
   .disch_to_loctn_cd, cds->activity[d.seq].accident_dt_tm = eacc.accident_dt_tm,
   cds->activity[d.seq].accident_cd = eacc.accident_cd, cds->activity[d.seq].ambulance_arrive_cd =
   eacc.ambulance_arrive_cd, cds->activity[d.seq].ambulance_serv_nbr = eacc.ambulance_serv_nbr,
   cds->activity[d.seq].place_cd = eacc.place_cd, cds->activity[d.seq].school_name = por.ft_org_name,
   cds->activity[d.seq].school_org_id = por.organization_id,
   cds->activity[d.seq].contributor_system_cd = e.contributor_system_cd
  WITH counter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  cvo_value = pm_get_cvo_alias(ei.value_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cdsbatch->batch[rcnt].content,5))),
   encntr_info ei
  PLAN (d)
   JOIN (ei
   WHERE (ei.encntr_id=cdsbatch->batch[rcnt].content[d.seq].parent_entity_id)
    AND ei.info_sub_type_cd IN (overseascd, stream_cd, edobs_cd)
    AND ei.active_ind=1)
  DETAIL
   IF (ei.info_sub_type_cd=overseascd)
    cds->activity[d.seq].overseas_status = cvo_value
   ELSEIF (ei.info_sub_type_cd=stream_cd)
    cds->activity[d.seq].stream_cd = ei.value_cd
   ELSEIF (ei.info_sub_type_cd=edobs_cd)
    cds->activity[d.seq].edobs_cd = ei.value_cd
   ENDIF
  WITH counter
 ;end select
 IF (size(cds->activity,5)=0)
  GO TO exit_cds_ae
 ENDIF
 SET last_mod = "162346"
 CALL echo("Getting Staff Member Info")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encntr_prsnl_reltn epr,
   person_name pn
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=cds->activity[d.seq].encntr_id)
    AND epr.encntr_prsnl_r_cd=staff_cd
    AND epr.manual_create_ind=0)
   JOIN (pn
   WHERE pn.person_id=epr.prsnl_person_id
    AND pn.name_type_cd=prsnl_name_cd)
  DETAIL
   cds->activity[d.seq].attend.staff_member_code = pn.name_initials, cds->activity[d.seq].
   attend_doc_prsnl_id = epr.prsnl_person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   encntr_prsnl_reltn epr
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=cds->activity[d.seq].encntr_id)
    AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND epr.active_ind=1)
  DETAIL
   cds->activity[d.seq].disch_prsnl = epr.prsnl_person_id
  WITH nocounter
 ;end select
 CALL echo("Getting Diagnosis codes")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   diagnosis diag,
   nomenclature n
  PLAN (d)
   JOIN (diag
   WHERE (diag.encntr_id=cds->activity[d.seq].encntr_id))
   JOIN (n
   WHERE n.nomenclature_id=diag.nomenclature_id
    AND n.principle_type_cd=diag_cd
    AND n.source_vocabulary_cd IN (icd10_cd, icd10_cdwho))
  ORDER BY d.seq, diag.diag_priority, 0
  DETAIL
   source_id = replace(n.source_identifier,".","",0)
   IF (trim(source_id,3) IN ("Z311", "Z312", "Z313", "Z318")
    AND (cdsbatch->anonymous=1))
    cds->activity[d.seq].anonymous = 1
   ENDIF
   IF (size(trim(source_id))=3)
    source_id = build(trim(source_id),"X")
   ENDIF
   IF (trim(cds->activity[d.seq].diag.diag_code_1,3)=" ")
    cds->activity[d.seq].diag.diag_code_1 = source_id
   ELSEIF (trim(cds->activity[d.seq].diag.diag_code_2,3)=" ")
    cds->activity[d.seq].diag.diag_code_2 = source_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Gathering investigation/order information")
 SELECT INTO "nl:"
  invest = cvo.alias, invest_num =
  IF (cvo.alias IN ("09", "11", "12", "13")) 3
  ELSEIF (cvo.alias IN ("01", "04", "08", "10")) 2
  ELSEIF (cvo.alias IN ("02", "03", "05", "06", "07",
  "14", "15", "16", "17", "18",
  "19", "20", "21", "22", "23",
  "99")) 1
  ELSE 0
  ENDIF
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   orders o,
   code_value_outbound cvo
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=cds->activity[d.seq].encntr_id))
   JOIN (cvo
   WHERE cvo.code_value=o.catalog_cd
    AND ((cvo.contributor_source_cd+ 0)=nhs_report_code))
  ORDER BY d.seq, invest_num DESC, 0
  DETAIL
   IF (invest_num > 0)
    IF (trim(cds->activity[d.seq].investigation.invest_code_1,3)=" ")
     cds->activity[d.seq].investigation.invest_code_1 = invest
    ELSEIF (trim(cds->activity[d.seq].investigation.invest_code_2,3)=" "
     AND trim(cds->activity[d.seq].investigation.invest_code_1,3) != " ")
     cds->activity[d.seq].investigation.invest_code_2 = invest
    ENDIF
   ENDIF
  WITH counter
 ;end select
 CALL echo("Gathering Tracking event information")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   tracking_item ti,
   tracking_checkin tc,
   track_event te,
   tracking_event te2
  PLAN (d)
   JOIN (ti
   WHERE (ti.encntr_id=cds->activity[d.seq].encntr_id))
   JOIN (tc
   WHERE tc.tracking_id=ti.tracking_id)
   JOIN (te2
   WHERE (te2.tracking_id= Outerjoin(ti.tracking_id)) )
   JOIN (te
   WHERE (te.track_event_id= Outerjoin(te2.track_event_id)) )
  ORDER BY d.seq
  HEAD d.seq
   tmp_checkout_dt_tm = 0.0, tmp_request_dt_tm = 0.0
  DETAIL
   tmp_checkout_dt_tm = tc.checkout_dt_tm
   IF (te.display_key=admission)
    tmp_request_dt_tm = te2.requested_dt_tm
   ENDIF
   IF (te.display_key=assessment)
    cds->activity[d.seq].attend.initial_assessment_time = cnvtdatetime(te2.complete_dt_tm)
   ELSEIF (te.display_key=treatmentstart)
    cds->activity[d.seq].attend.time_seen_for_treatment = cnvtdatetime(te2.onset_dt_tm)
   ENDIF
   cds->activity[d.seq].tracking_checkin.checkin_dt_tm = tc.checkin_dt_tm, cds->activity[d.seq].
   tracking_checkin.checkout_dt_tm = tc.checkout_dt_tm, cds->activity[d.seq].tracking_event.
   tracking_group_cd = te2.tracking_group_cd,
   cds->activity[d.seq].tracking_event.requested_dt_tm = te2.requested_dt_tm
  FOOT  d.seq
   IF (tmp_request_dt_tm != 0.0
    AND tmp_checkout_dt_tm > tmp_request_dt_tm)
    cds->activity[d.seq].attend.attend_conclusion_time = tmp_request_dt_tm
   ELSE
    cds->activity[d.seq].attend.attend_conclusion_time = tmp_checkout_dt_tm
   ENDIF
  WITH counter
 ;end select
 CALL echo("Gathering Treatment Details")
 DECLARE tetanus_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"TETANUS"))
 SELECT INTO "nl:"
  dscntreatment = pm_get_cvo_alias(cv.code_value,nhs_report_code), treatment_dscnsubtreatment =
  pm_get_cvo_alias(ccr.result_cd,nhs_report_code)
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   code_value cv,
   clinical_event ce,
   ce_coded_result ccr
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=cds->activity[d.seq].encntr_id)
    AND ((ce.event_cd+ 0) IN (ae_treatment_1_cd, ae_treatment_2_cd, ae_treatment_1_dscn_cd,
   ae_treatment_2_dscn_cd, ae_subtreatment_1_cd,
   ae_subtreatment_2_cd, tetanus_cd)))
   JOIN (ccr
   WHERE (ccr.event_id= Outerjoin(ce.event_id)) )
   JOIN (cv
   WHERE (cv.code_set= Outerjoin(treatment_code_set))
    AND (cv.display= Outerjoin(ce.result_val))
    AND (cv.active_ind= Outerjoin(1)) )
  DETAIL
   IF (ce.event_cd=ae_treatment_1_dscn_cd)
    cds->activity[d.seq].treatment.treat_code_1 = dscntreatment
   ELSEIF (ce.event_cd=ae_treatment_2_dscn_cd)
    cds->activity[d.seq].treatment.treat_code_2 = dscntreatment
   ELSEIF (ce.event_cd=ae_subtreatment_1_cd)
    cds->activity[d.seq].treatment.sub_treat_code_1 = treatment_dscnsubtreatment
   ELSEIF (ce.event_cd=ae_subtreatment_2_cd)
    cds->activity[d.seq].treatment.sub_treat_code_2 = treatment_dscnsubtreatment
   ELSEIF (ce.event_cd=ae_treatment_1_cd)
    cds->activity[d.seq].treatment.treat_code_1 = treatment_dscnsubtreatment
   ELSEIF (ce.event_cd=ae_treatment_2_cd)
    cds->activity[d.seq].treatment.treat_code_2 = treatment_dscnsubtreatment
   ELSEIF (ce.event_cd=tetanus_cd)
    cds->activity[d.seq].tetanus_result_val = ce.result_val
   ENDIF
  WITH counter, orahint(" INDEX (CE FK10CLINICAL_EVENT)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5)))
  DETAIL
   IF (((trim(cds->activity[d.seq].attend.attend_disposal,3)=" ") OR (trim(cds->activity[d.seq].
    attend.attend_disposal,3)="14")) )
    cds->activity[d.seq].hrg.healthcare_res_group_code = "U06"
   ELSEIF ((((cds->activity[d.seq].investigation.invest_code_1 IN ("09", "11", "12", "13"))) OR ((cds
   ->activity[d.seq].investigation.invest_code_2 IN ("09", "11", "12", "13")))) )
    IF ((cds->activity[d.seq].attend.attend_disposal IN ("01", "07", "10")))
     cds->activity[d.seq].hrg.healthcare_res_group_code = "V01"
    ELSE
     cds->activity[d.seq].hrg.healthcare_res_group_code = "V02"
    ENDIF
   ELSEIF ((cds->activity[d.seq].investigation.invest_code_1 IN ("01", "04", "08", "10")))
    IF ((cds->activity[d.seq].attend.attend_disposal IN ("01", "07", "10")))
     cds->activity[d.seq].hrg.healthcare_res_group_code = "V03"
    ELSE
     cds->activity[d.seq].hrg.healthcare_res_group_code = "V04"
    ENDIF
   ELSEIF ((cds->activity[d.seq].investigation.invest_code_1 IN ("02", "03", "05", "06", "07",
   "14", "15", "16", "17", "18",
   "19", "20", "21", "22", "23",
   "99")))
    IF ((cds->activity[d.seq].attend.attend_disposal IN ("01", "07", "10")))
     cds->activity[d.seq].hrg.healthcare_res_group_code = "V05"
    ELSE
     cds->activity[d.seq].hrg.healthcare_res_group_code = "V06"
    ENDIF
   ELSEIF (trim(cds->activity[d.seq].investigation.invest_code_1,3)=" "
    AND trim(cds->activity[d.seq].investigation.invest_code_2,3)=" ")
    IF ((cds->activity[d.seq].attend.attend_disposal IN ("01", "07", "10")))
     cds->activity[d.seq].hrg.healthcare_res_group_code = "V07"
    ELSE
     cds->activity[d.seq].hrg.healthcare_res_group_code = "V08"
    ENDIF
   ENDIF
   cds->activity[d.seq].hrg.hrg_code_version_num = "3.2", cds->activity[d.seq].hrg.read_code_version
    = "1"
  WITH nocounter
 ;end select
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
 CALL echo("Getting OPCS4 info")
 DECLARE opcs4_source_voc_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",400,"OPCS4"))
 DECLARE proc_principle_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",401,
   "PROCEDURE"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   procedure proc,
   dummyt dnm,
   nomenclature nm
  PLAN (d)
   JOIN (proc
   WHERE (proc.encntr_id=cds->activity[d.seq].encntr_id)
    AND proc.active_ind=1)
   JOIN (dnm)
   JOIN (nm
   WHERE nm.nomenclature_id=proc.nomenclature_id
    AND nm.principle_type_cd=proc_principle_type_cd
    AND nm.source_vocabulary_cd=opcs4_source_voc_cd
    AND nm.active_ind=1)
  DETAIL
   source_id = replace(nm.source_identifier,".","",0)
   IF (proc.dgvp_ind=1)
    cds->activity[d.seq].hrg.hrg_dgvp_opcs = source_id
   ENDIF
  WITH nocounter, outerjoin = dnm
 ;end select
 SET last_mod = "157097"
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
    SET cdsoutdir = "$CCLUSERDIR:"
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
 SELECT INTO "nl:"
  nextseqnum = seq(aar_report_seq,nextval)
  FROM dual
  DETAIL
   cds->finished_file = concat(trim(cdsoutdir,3),"CDS_AE","_",trim(cdsbatch->org_code,3),"_",
    trim(format(nextseqnum,"######################"),3),"_","F","_",trim(cnvtstring(cdsbatch->batch[
      rcnt].cds_batch_id),3),
    "_",trim(format(cnvtdatetime(sysdate),"YYMMDD;;d"),3),".tmp")
  WITH nocounter
 ;end select
 IF (cdsoutdir_dcl != "$CCLUSERDIR/")
  SET cdsoutdir_dcl = trim(cdsoutdir)
 ENDIF
 CALL echo(cds->finished_file)
 SET ztotal = size(cds->activity,5)
 IF ((cdsbatch->file_format="5"))
  SET last_mod = "159212"
  DECLARE orgtypecodedef = c1 WITH protect, constant("B")
  DECLARE procscheme = c2 WITH protect, constant("02")
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
  FOR (fsize = 1 TO size(cds->activity,5))
    SET sfile = cds->finished_file
    SET outstring = " "
    IF ((cds->activity[fsize].patient.alias_status=" "))
     SET cds->activity[fsize].patient.alias_status = "03"
    ENDIF
    IF (trim(cds->activity[fsize].pt_post_code,3)=" ")
     SET cds->activity[fsize].pt_post_code = d_not_known_postcode
    ENDIF
    IF (trim(cds->activity[fsize].residence_pct,3)=" ")
     SET cds->activity[fsize].residence_pct = "Q9900"
    ENDIF
    IF (trim(cds->activity[fsize].gp_code,3)=" ")
     SET cds->activity[fsize].gp_code = "G9999981"
    ENDIF
    IF (trim(cds->activity[fsize].gp_practice,3)=" ")
     SET cds->activity[fsize].gp_practice = "V81999"
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
    SET orgtypecode1 = ""
    SET orgtypecode2 = ""
    SET orgtypecode3 = ""
    SET orgtypecode4 = ""
    SET orgtypecode5 = ""
    SET orgtypecode6 = ""
    SET orgtypecode7 = ""
    SET orgtypecode8 = ""
    SET orgtypecode9 = ""
    SET orgtypecode10 = ""
    SET orgtypecode11 = ""
    SET orgtypecode12 = ""
    SET orgtypecode13 = ""
    SET orgtypecode14 = ""
    IF (trim(cds->activity[fsize].org_cd_prov,3) != " ")
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
    IF (trim(cds->activity[fsize].gp_practice,3) != " ")
     SET orgtypecode12 = orgtypecodedef
    ENDIF
    IF (trim(cds->activity[fsize].org_cd_prov,3) != " ")
     SET orgtypecode13 = orgtypecodedef
    ENDIF
    IF (trim(cds->activity[fsize].org_cd_comm,3) != " ")
     SET orgtypecode14 = orgtypecodedef
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
      col 98,
      CALL print(trim(cds->activity[fsize].org_cd_prov,3)), col 103,
      CALL print(trim(orgtypecode1,3)), col 104,
      CALL print(trim(cds->activity[fsize].primary_recip,3)),
      col 109,
      CALL print(trim(orgtypecode2,3)), col 110,
      CALL print(trim(cds->activity[fsize].copy_1,3)), col 115,
      CALL print(trim(orgtypecode3,3)),
      col 116,
      CALL print(trim(cds->activity[fsize].copy_2,3)), col 121,
      CALL print(trim(orgtypecode4,3)), col 122,
      CALL print(trim(cds->activity[fsize].copy_3,3)),
      col 127,
      CALL print(trim(orgtypecode5,3)), col 128,
      CALL print(trim(cds->activity[fsize].copy_4,3)), col 133,
      CALL print(trim(orgtypecode6,3)),
      col 134,
      CALL print(trim(cds->activity[fsize].copy_5,3)), col 139,
      CALL print(trim(orgtypecode7,3)), col 140,
      CALL print(trim(cds->activity[fsize].copy_6,3)),
      col 145,
      CALL print(trim(orgtypecode8,3)), col 146,
      CALL print(trim(cds->activity[fsize].copy_7,3)), col 151,
      CALL print(trim(orgtypecode9,3)),
      col 152,
      CALL print(trim(cds->activity[fsize].local_patient_id,3)), col 162,
      CALL print(trim(cds->activity[fsize].patient_id_org,3)), col 167,
      CALL print(trim(orgtypecode10,3)),
      col 168,
      CALL print(trim(cds->activity[fsize].patient.nhs_number,3)), col 178,
      CALL print(format(cds->activity[fsize].patient.dob,"YYYYMMDD;;D")), col 186,
      CALL print(trim(cds->activity[fsize].patient.carer_support_ind,3)),
      col 188,
      CALL print(trim(cds->activity[fsize].patient.alias_status,3)), col 190,
      CALL print(trim(cds->activity[fsize].patient.sex,3)), col 191,
      CALL print(trim(cds->activity[fsize].name_format_ind,3)),
      col 192,
      CALL print(trim(cds->activity[fsize].patient_forename,3)), col 227,
      CALL print(trim(cds->activity[fsize].patient_surname,3)), col 262,
      CALL print(trim(cds->activity[fsize].pt_address_format_cd,3)),
      col 263,
      CALL print(trim(cds->activity[fsize].pt_address_1,3)), col 298,
      CALL print(trim(cds->activity[fsize].pt_address_2,3)), col 333,
      CALL print(trim(cds->activity[fsize].pt_address_3,3)),
      col 368,
      CALL print(trim(cds->activity[fsize].pt_address_4,3)), col 403,
      CALL print(trim(cds->activity[fsize].pt_address_5,3)), col 438,
      CALL print(trim(cds->activity[fsize].pt_post_code,3)),
      col 446,
      CALL print(trim(cds->activity[fsize].residence_pct,3)), col 451,
      CALL print(trim(orgtypecode11,3)), col 452,
      CALL print(trim(cds->activity[fsize].gp_code,3)),
      col 460,
      CALL print(trim(cds->activity[fsize].gp_practice,3)), col 466,
      CALL print(trim(orgtypecode12,3)), col 467,
      CALL print(trim(cds->activity[fsize].attend.attend_num,3)),
      col 479,
      CALL print(trim(cds->activity[fsize].attend.attend_cat,3)), col 480,
      CALL print(format(cds->activity[fsize].attend.arrival_date_time,"YYYYMMDD;;D")), col 488,
      CALL print(format(cds->activity[fsize].attend.arrival_date_time,"HHMMSS;;M")),
      col 494,
      CALL print(trim(cds->activity[fsize].attend.arrival_mode,3)), col 495,
      CALL print(trim(cds->activity[fsize].attend.ref_source,3)), col 497,
      CALL print(trim(cds->activity[fsize].attend.patient_group,3)),
      col 499,
      CALL print(trim(cds->activity[fsize].attend.incident_location_type,3)), col 501,
      CALL print(format(cds->activity[fsize].attend.initial_assessment_time,"HHMMSS;;M")), col 507,
      CALL print(format(cds->activity[fsize].attend.time_seen_for_treatment,"HHMMSS;;M")),
      col 513,
      CALL print(trim(cds->activity[fsize].attend.staff_member_code,3)), col 516,
      CALL print(format(cds->activity[fsize].attend.attend_conclusion_time,"HHMMSS;;M")), col 522,
      CALL print(format(cds->activity[fsize].attend.depart_time,"HHMMSS;;M")),
      col 528,
      CALL print(trim(cds->activity[fsize].attend.attend_disposal,3)), col 530,
      CALL print(trim(cds->activity[fsize].comm_ser_nbr,3)), col 536,
      CALL print(trim(cds->activity[fsize].nhs_svc_agr_line_nbr,3)),
      col 546,
      CALL print(trim(cds->activity[fsize].prov_ref_nbr,3)), col 563,
      CALL print(trim(cds->activity[fsize].comm_ref_nbr,3)), col 580,
      CALL print(trim(cds->activity[fsize].org_cd_prov,3)),
      col 585,
      CALL print(trim(orgtypecode13,3)), col 586,
      CALL print(trim(cds->activity[fsize].org_cd_comm,3)), col 591,
      CALL print(trim(orgtypecode14,3)),
      col 592,
      CALL print(trim(cds->activity[fsize].investigation.invest_code_1,3)), col 598,
      CALL print(trim(cds->activity[fsize].investigation.invest_code_2,3)), col 604,
      CALL print(trim(cds->activity[fsize].diag.diag_code_1,3)),
      col 610,
      CALL print(trim(cds->activity[fsize].diag.diag_code_2,3)), col 616,
      CALL print(trim(cds->activity[fsize].treatment.treat_code_1,3)), col 618,
      CALL print(trim(cds->activity[fsize].treatment.sub_treat_code_1,3)),
      col 622,
      CALL print(trim(cds->activity[fsize].treatment.treat_code_2,3)), col 624,
      CALL print(trim(cds->activity[fsize].treatment.sub_treat_code_2,3)), col 628,
      CALL print(trim(cds->activity[fsize].hrg.healthcare_res_group_code,3)),
      col 631,
      CALL print(trim(cds->activity[fsize].hrg.hrg_code_version_num,3)), col 634,
      CALL print(trim(procscheme,3)), col 636,
      CALL print(trim(cds->activity[fsize].hrg.hrg_dgvp_opcs,3))
      IF (trim(cds->activity[fsize].local_subspecialty,3) != "")
       col 640,
       CALL print(trim(cds->activity[fsize].local_subspecialty,3))
      ENDIF
     WITH nocounter, append, format = lfstream,
      format = fixed, maxcol = 646, maxrow = 1,
      formfeed = none
    ;end select
  ENDFOR
 ELSE
  FOR (fsize = 1 TO size(cds->activity,5))
    SET sfile = cds->finished_file
    SELECT INTO value(sfile)
     FROM dummyt d
     PLAN (d)
     DETAIL
      col 0,
      CALL print(trim(cds->activity[fsize].version_number,3)), col 6,
      CALL print(trim(cds->activity[fsize].cds_type,3)), col 9,
      CALL print(trim(cds->activity[fsize].protocol_id,3)),
      col 12,
      CALL print(trim(cds->activity[fsize].unique_cds_id,3)), col 47,
      CALL print(trim(cds->activity[fsize].update_type,3)), col 48,
      CALL print(trim(cds->activity[fsize].bulk_repl_cds_gp,3)),
      col 51,
      CALL print(trim(cds->activity[fsize].test_ind,3)), col 52,
      cds->activity[fsize].extract_dt_time"YYYYMMDDHHMM;;d", col 64, cds->activity[fsize].
      extract_dt_time"YYYYMMDDHHMM;;d",
      col 76, cds->activity[fsize].period_start_dt"YYYYMMDD;;d", col 84,
      cds->activity[fsize].period_end_dt"YYYYMMDD;;d", col 100,
      CALL print(trim(cds->activity[fsize].org_cd_prov,3)),
      col 105,
      CALL print(trim(cds->activity[fsize].primary_recip,3)), col 110,
      CALL print(trim(cds->activity[fsize].copy_1,3)), col 115,
      CALL print(trim(cds->activity[fsize].copy_2,3)),
      col 120,
      CALL print(trim(cds->activity[fsize].copy_3,3)), col 125,
      CALL print(trim(cds->activity[fsize].copy_4,3)), col 130,
      CALL print(trim(cds->activity[fsize].copy_5,3)),
      col 135,
      CALL print(trim(cds->activity[fsize].copy_6,3)), col 140,
      CALL print(trim(cds->activity[fsize].copy_7,3)), col 145,
      CALL print(trim(cds->activity[fsize].local_patient_id,3)),
      col 155,
      CALL print(trim(cds->activity[fsize].patient_id_org,3)), col 160,
      CALL print(trim(cds->activity[fsize].patient.nhs_number,3)), col 170,
      CALL print(trim(cds->activity[fsize].patient.nhs_num_old,3)),
      col 187, cds->activity[fsize].patient.dob"YYYYMMDD;;D", col 195,
      CALL print(trim(cds->activity[fsize].patient.carer_support_ind,3))
      IF ((cds->activity[fsize].patient.alias_status=" "))
       cds->activity[fsize].patient.alias_status = "03"
      ENDIF
      col 197,
      CALL print(trim(cds->activity[fsize].patient.alias_status,3)), col 199,
      CALL print(trim(cds->activity[fsize].patient.sex,3))
      IF ((cds->activity[fsize].anonymous != 1))
       col 200,
       CALL print(trim(cds->activity[fsize].name_format_ind,3)), col 201,
       CALL print(trim(cds->activity[fsize].patient_forename,3)), col 236,
       CALL print(trim(cds->activity[fsize].patient_surname,3)),
       col 341,
       CALL print(trim(cds->activity[fsize].pt_address_format_cd,3)), col 342,
       CALL print(trim(cds->activity[fsize].pt_address_1,3)), col 377,
       CALL print(trim(cds->activity[fsize].pt_address_2,3)),
       col 412,
       CALL print(trim(cds->activity[fsize].pt_address_3,3)), col 447,
       CALL print(trim(cds->activity[fsize].pt_address_4,3)), col 482,
       CALL print(trim(cds->activity[fsize].pt_address_5,3))
      ENDIF
      col 517,
      CALL print(trim(cds->activity[fsize].pt_post_code,3)), col 525,
      CALL print(trim(cds->activity[fsize].pt_sha,3))
      IF (trim(cds->activity[fsize].gp_code,3)=" ")
       cds->activity[fsize].gp_code = "G9999981"
      ENDIF
      col 528,
      CALL print(trim(cds->activity[fsize].gp_code,3))
      IF (trim(cds->activity[fsize].gp_practice,3)=" ")
       cds->activity[fsize].gp_practice = "V81999"
      ENDIF
      col 536,
      CALL print(trim(cds->activity[fsize].gp_practice,3)), col 542,
      CALL print(trim(cds->activity[fsize].attend.attend_num,3)), col 554,
      CALL print(trim(cds->activity[fsize].attend.attend_cat,3)),
      col 555, cds->activity[fsize].attend.arrival_date_time"YYYYMMDDHHMM;;d", col 569,
      CALL print(trim(cds->activity[fsize].attend.arrival_mode,3)), col 570,
      CALL print(trim(cds->activity[fsize].attend.ref_source,3)),
      col 572,
      CALL print(trim(cds->activity[fsize].attend.patient_group,3)), col 574,
      CALL print(trim(cds->activity[fsize].attend.incident_location_type,3)), col 576, cds->activity[
      fsize].attend.initial_assessment_time"HHMM;;m",
      col 582, cds->activity[fsize].attend.time_seen_for_treatment"hhmm;;m", col 588,
      CALL print(trim(cds->activity[fsize].attend.staff_member_code,3)), col 591, cds->activity[fsize
      ].attend.attend_conclusion_time"hhmm;;m",
      col 597, cds->activity[fsize].attend.depart_time"hhmm;;m", col 603,
      CALL print(trim(cds->activity[fsize].attend.attend_disposal,3)), col 605,
      CALL print(trim(cds->activity[fsize].comm_ser_nbr,3)),
      col 611,
      CALL print(trim(cds->activity[fsize].nhs_svc_agr_line_nbr,3)), col 621,
      CALL print(trim(cds->activity[fsize].prov_ref_nbr,3)), col 638,
      CALL print(trim(cds->activity[fsize].comm_ref_nbr,3)),
      col 655,
      CALL print(trim(cds->activity[fsize].org_cd_prov,3)), col 660,
      CALL print(trim(cds->activity[fsize].org_cd_comm,3)), col 665,
      CALL print(trim(cds->activity[fsize].investigation.invest_code_1,3)),
      col 671,
      CALL print(trim(cds->activity[fsize].investigation.invest_code_2,3)), col 677,
      CALL print(trim(cds->activity[fsize].diag.diag_code_1,3)), col 683,
      CALL print(trim(cds->activity[fsize].diag.diag_code_2,3)),
      col 689,
      CALL print(trim(cds->activity[fsize].treatment.treat_code_1,3)), col 691,
      CALL print(trim(cds->activity[fsize].treatment.sub_treat_code_1,3)), col 695,
      CALL print(trim(cds->activity[fsize].treatment.treat_code_2,3)),
      col 697,
      CALL print(trim(cds->activity[fsize].treatment.sub_treat_code_2,3)), col 701,
      CALL print(trim(cds->activity[fsize].hrg.healthcare_res_group_code,3)), col 704,
      CALL print(trim(cds->activity[fsize].hrg.hrg_code_version_num,3)),
      col 707,
      CALL print(trim(cds->activity[fsize].hrg.hrg_dgvp_opcs,3)), col 711,
      CALL print(trim(cds->activity[fsize].hrg.hrg_dgvp_read,3)), col 718,
      CALL print(trim(cds->activity[fsize].hrg.read_code_version,3))
      IF (trim(cds->activity[fsize].residence_pct,3)=" ")
       cds->activity[fsize].residence_pct = "Q9900"
      ENDIF
      col 719,
      CALL print(trim(cds->activity[fsize].residence_pct,3))
     WITH nocounter, append, format = lfstream,
      maxcol = 900, maxrow = 1, formfeed = none
    ;end select
    CALL echo(build2("Record->",trim(cnvtstring(fsize),3)," of ",trim(cnvtstring(size(cds->activity,5
         )),3)))
  ENDFOR
 ENDIF
 SET cds->finished_file = replace(cds->finished_file,cdsoutdir,cdsoutdir_dcl,1)
 SET dcl_rename_cmd = cnvtlower(build2(rename_cmd," ",trim(cds->finished_file)," ",substring(1,(
    textlen(trim(cds->finished_file)) - 3),cds->finished_file),
   "txt"))
 SET dcl_size = textlen(dcl_rename_cmd)
 CALL dcl(dcl_rename_cmd,dcl_size,write_status)
 SET cds->finished_file = build(substring(1,(textlen(trim(cds->finished_file)) - 3),cds->
   finished_file),"txt")
 IF (trim(cdsbatch->batch[rcnt].filename,3)=" ")
  SET cdsbatch->batch[rcnt].filename = replace(cds->finished_file,cdsoutdir,"",1)
 ENDIF
 IF (cursys="AIX")
  SET dclcom1 = build2("chmod 777 ",cdsoutdir_dcl,"cds*.txt")
  SET len = size(trim(dclcom1))
  SET status = 0
  CALL dcl(dclcom1,len,status)
 ELSE
  SET dclcom1 = build2("SET FILE/PROTECTION=(S:RWED,O=RWED,G:RWED,W:RWED) ",cdsoutdir_dcl,"cds*.txt")
  SET len = size(trim(dclcom1))
  SET status = 0
  CALL dcl(dclcom1,len,status)
 ENDIF
 CALL echo(dclcom1)
 CALL echo(build("Filename from create->",cdsbatch->batch[rcnt].filename))
 CALL echo(build2("updating: ",cds->activity[(fsize - 1)].cds_batch_content_id))
 IF ((cdsbatch->testmode=0))
  CALL echo("Table Updates")
  UPDATE  FROM cds_batch_content cbc,
    (dummyt d  WITH seq = value(size(cds->activity,5)))
   SET cbc.cds_batch_id = cdsbatch->batch[rcnt].cds_batch_id, cbc.activity_dt_tm = cnvtdatetime(cds->
     activity[d.seq].point_dt_tm), cbc.updt_dt_tm = cnvtdatetime(sysdate)
   PLAN (d)
    JOIN (cbc
    WHERE (cbc.cds_batch_content_id=cds->activity[d.seq].cds_batch_content_id))
   WITH nocounter, maxcommit = 100
  ;end update
  COMMIT
  UPDATE  FROM cds_batch_content_hist cbch,
    (dummyt d  WITH seq = value(size(cds->activity,5)))
   SET cbch.cds_batch_id = cdsbatch->batch[rcnt].cds_batch_id, cbch.updt_dt_tm = cnvtdatetime(sysdate
     ), cbch.activity_dt_tm = cnvtdatetime(cds->activity[d.seq].point_dt_tm)
   PLAN (d)
    JOIN (cbch
    WHERE (cbch.cds_batch_content_id=cds->activity[d.seq].cds_batch_content_id)
     AND cbch.cds_batch_id=0)
   WITH nocounter, maxcommit = 100
  ;end update
  COMMIT
 ENDIF
 CALL echo(build("Filename from create->",cdsbatch->batch[rcnt].filename))
 IF (pref_18ww="ON")
  EXECUTE ukr_rtt_extract
 ENDIF
 EXECUTE ukr_cdst_ae_attend_extract
#exit_cds_ae
 FREE RECORD cds
END GO
