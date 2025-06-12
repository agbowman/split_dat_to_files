CREATE PROGRAM bhs_ma_ext_press_ganey:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Discharge Start Date:" = "CURDATE",
  "Discharge End Date:" = "CURDATE",
  "Survey Designator:" = "",
  "Update File ?" = 0,
  "Email (manual execution only):" = ""
  WITH outdev, s_start_dt, s_stop_dt,
  s_survey, l_updt_ind, s_email
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE ms_client_id = vc WITH protect, noconstant("")
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 DECLARE mf_cs220_bmc_cd = f8 WITH protect, constant(673936.00)
 DECLARE mf_cs220_fmc_cd = f8 WITH protect, constant(673937.00)
 DECLARE mf_cs220_bwh_cd = f8 WITH protect, constant(580062482.00)
 DECLARE mf_cs220_bnh_cd = f8 WITH protect, constant(780848199.00)
 DECLARE mf_cs220_nccn_cd = f8 WITH protect, constant(686914.00)
 DECLARE mf_cs220_nicu_cd = f8 WITH protect, constant(686915.00)
 DECLARE mf_cs34_daystaybnh_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "DAYSTAYBNH"))
 DECLARE mf_cs34_endoscopybnh_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "ENDOSCOPYBNH"))
 DECLARE mf_cs34_wingdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "WINGDAYSTAY"))
 DECLARE mf_cs34_wingendoscopy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "WINGENDOSCOPY"))
 DECLARE mf_cs34_wingminorproc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "WINGMINORPROC"))
 DECLARE mf_cs34_endoscopyminorproc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "ENDOSCOPYMINORPROC"))
 DECLARE mf_cs34_wingdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "WINGDAYSTAY"))
 DECLARE mf_cs34_baystateorthosurg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "BAYSTATEORTHOSURG"))
 DECLARE mf_cs34_chestnut23hr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "CHESTNUT23HR"))
 DECLARE mf_cs34_chstb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,"CHSTB"))
 DECLARE mf_cs34_daly23hr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,"DALY23HR"))
 DECLARE mf_cs34_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,"DAYSTAY"))
 DECLARE mf_cs34_endo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,"ENDO"))
 DECLARE mf_cs34_endoscopys25_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "ENDOSCOPYS25"))
 DECLARE mf_cs34_hvcendovascularor_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "HVCENDOVASCULAROR"))
 DECLARE mf_cs34_emergsvsunit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "EMERGSVSUNIT"))
 DECLARE mf_cs34_emergsvswaiting_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "EMERGSVSWAITING"))
 DECLARE mf_cs34_wetu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,"WETU"))
 DECLARE mf_cs34_emergsvspedi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "EMERGSVSPEDI"))
 DECLARE mf_cs220_s6ado_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"S6ADO"))
 DECLARE mf_cs220_captu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"CAPTU"))
 DECLARE mf_cs220_infch_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"INFCH"))
 DECLARE mf_cs220_picu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"PICU"))
 DECLARE mf_cs220_ldrpa_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"LDRPA"))
 DECLARE mf_cs220_ldrpb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"LDRPB"))
 DECLARE mf_cs220_ldrpc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"LDRPC"))
 DECLARE mf_cs220_win2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"WIN2"))
 DECLARE mf_cs71_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_cs71_dischdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHDAYSTAY"))
 DECLARE mf_cs71_expireddaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "EXPIREDDAYSTAY"))
 DECLARE mf_cs71_dischargedoutpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHARGEDOUTPATIENT"))
 DECLARE mf_cs71_onetimeop_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"ONETIMEOP"
   ))
 DECLARE mf_cs71_outpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENT"))
 DECLARE mf_cs71_outpatientonetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTONETIME"))
 DECLARE mf_cs71_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"
   ))
 DECLARE mf_cs71_expiredes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES"
   ))
 DECLARE mf_cs71_disches_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES"))
 DECLARE mf_cs71_dischip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_cs71_dischobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE mf_cs71_expiredip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"
   ))
 DECLARE mf_cs71_expiredobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "EXPIREDOBV"))
 DECLARE mf_cs71_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"
   ))
 DECLARE mf_cs71_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OBSERVATION"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs212_home_addr_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4018"))
 DECLARE mf_cs212_bus_addr_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8009"))
 DECLARE mf_cs212_email_addr_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8009")
  )
 DECLARE mf_cs43_home_phone_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4017"))
 DECLARE mf_cs43_cell_phone_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!2510010055"))
 DECLARE mf_cs400_msdrg_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2570183840"
   ))
 DECLARE mf_cs57_male_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2773"))
 DECLARE mf_cs57_female_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2774"))
 DECLARE mf_cs320_npi_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2160654021"))
 DECLARE mf_cs333_attenddoc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4024"))
 DECLARE mf_cs213_prsnlname_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!2403228"))
 DECLARE mf_cs400_cpt_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2954"))
 DECLARE mf_cs400_hcpcs_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!42457"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD m_tmp
 RECORD m_tmp(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 l_ed_ind = i4
 ) WITH protect
 FREE RECORD m_enc
 RECORD m_enc(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 s_survey_designator = vc
     2 s_client_cd = vc
 ) WITH protect
 IF (trim(cnvtupper( $S_SURVEY),3)="AS0101")
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bmc_cd
     AND e.med_service_cd IN (mf_cs34_baystateorthosurg_cd, mf_cs34_chestnut23hr_cd, mf_cs34_chstb_cd,
    mf_cs34_daly23hr_cd, mf_cs34_daystay_cd,
    mf_cs34_endo_cd, mf_cs34_endoscopys25_cd, mf_cs34_hvcendovascularor_cd)
     AND e.encntr_type_cd IN (mf_cs71_daystay_cd, mf_cs71_dischdaystay_cd, mf_cs71_expireddaystay_cd,
    mf_cs71_dischargedoutpatient_cd, mf_cs71_onetimeop_cd,
    mf_cs71_outpatient_cd, mf_cs71_outpatientonetime_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    IF (e.med_service_cd=mf_cs34_baystateorthosurg_cd
     AND e.encntr_type_cd IN (mf_cs71_dischargedoutpatient_cd, mf_cs71_onetimeop_cd,
    mf_cs71_outpatient_cd, mf_cs71_outpatientonetime_cd))
     m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
     f_encntr_id = e.encntr_id,
     m_enc->qual[m_enc->l_cnt].s_survey_designator = "AS0101", m_enc->qual[m_enc->l_cnt].s_client_cd
      = "253"
    ELSE
     m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
     f_encntr_id = e.encntr_id,
     m_enc->qual[m_enc->l_cnt].s_survey_designator = "AS0101", m_enc->qual[m_enc->l_cnt].s_client_cd
      = "253"
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bnh_cd
     AND e.med_service_cd IN (mf_cs34_daystaybnh_cd, mf_cs34_endoscopybnh_cd)
     AND e.encntr_type_cd IN (mf_cs71_daystay_cd, mf_cs71_dischdaystay_cd, mf_cs71_expireddaystay_cd)
    )
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
    f_encntr_id = e.encntr_id,
    m_enc->qual[m_enc->l_cnt].s_survey_designator = "AS0101", m_enc->qual[m_enc->l_cnt].s_client_cd
     = "2111"
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bwh_cd
     AND e.med_service_cd IN (mf_cs34_wingdaystay_cd, mf_cs34_wingendoscopy_cd,
    mf_cs34_wingminorproc_cd)
     AND e.encntr_type_cd IN (mf_cs71_daystay_cd, mf_cs71_dischdaystay_cd, mf_cs71_expireddaystay_cd)
    )
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
    f_encntr_id = e.encntr_id,
    m_enc->qual[m_enc->l_cnt].s_survey_designator = "AS0101", m_enc->qual[m_enc->l_cnt].s_client_cd
     = "5577"
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_fmc_cd
     AND e.med_service_cd IN (mf_cs34_endoscopyminorproc_cd, mf_cs34_wingdaystay_cd)
     AND e.encntr_type_cd IN (mf_cs71_daystay_cd, mf_cs71_dischdaystay_cd, mf_cs71_expireddaystay_cd)
    )
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
    f_encntr_id = e.encntr_id,
    m_enc->qual[m_enc->l_cnt].s_survey_designator = "AS0101", m_enc->qual[m_enc->l_cnt].s_client_cd
     = "24259"
   WITH nocounter
  ;end select
 ELSEIF (trim(cnvtupper( $S_SURVEY),3)="NC0101")
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bmc_cd
     AND e.loc_nurse_unit_cd IN (mf_cs220_nccn_cd, mf_cs220_nicu_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
    f_encntr_id = e.encntr_id,
    m_enc->qual[m_enc->l_cnt].s_survey_designator = "NC0101", m_enc->qual[m_enc->l_cnt].s_client_cd
     = "253"
   WITH nocounter
  ;end select
 ELSEIF (trim(cnvtupper( $S_SURVEY),3)="ER0101")
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bmc_cd
     AND e.encntr_type_cd IN (mf_cs71_emergency_cd, mf_cs71_expiredes_cd, mf_cs71_disches_cd)
     AND e.med_service_cd IN (mf_cs34_emergsvsunit_cd, mf_cs34_emergsvswaiting_cd, mf_cs34_wetu_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
    f_encntr_id = e.encntr_id,
    m_enc->qual[m_enc->l_cnt].s_survey_designator = "ER0101", m_enc->qual[m_enc->l_cnt].s_client_cd
     = "253"
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bnh_cd
     AND e.encntr_type_cd IN (mf_cs71_emergency_cd, mf_cs71_expiredes_cd, mf_cs71_disches_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
    f_encntr_id = e.encntr_id,
    m_enc->qual[m_enc->l_cnt].s_survey_designator = "ER0101", m_enc->qual[m_enc->l_cnt].s_client_cd
     = "2111"
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bwh_cd
     AND e.encntr_type_cd IN (mf_cs71_emergency_cd, mf_cs71_expiredes_cd, mf_cs71_disches_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
    f_encntr_id = e.encntr_id,
    m_enc->qual[m_enc->l_cnt].s_survey_designator = "ER0101", m_enc->qual[m_enc->l_cnt].s_client_cd
     = "5577"
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_fmc_cd
     AND e.encntr_type_cd IN (mf_cs71_emergency_cd, mf_cs71_expiredes_cd, mf_cs71_disches_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
    f_encntr_id = e.encntr_id,
    m_enc->qual[m_enc->l_cnt].s_survey_designator = "ER0101", m_enc->qual[m_enc->l_cnt].s_client_cd
     = "24259"
   WITH nocounter
  ;end select
 ELSEIF (trim(cnvtupper( $S_SURVEY),3)="ER0102")
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bmc_cd
     AND e.encntr_type_cd IN (mf_cs71_emergency_cd, mf_cs71_expiredes_cd, mf_cs71_disches_cd)
     AND e.med_service_cd IN (mf_cs34_emergsvspedi_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
    f_encntr_id = e.encntr_id,
    m_enc->qual[m_enc->l_cnt].s_survey_designator = "ER0102", m_enc->qual[m_enc->l_cnt].s_client_cd
     = "253"
   WITH nocounter
  ;end select
 ELSEIF (trim(cnvtupper( $S_SURVEY),3)="PD0101")
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bmc_cd
     AND e.loc_nurse_unit_cd IN (mf_cs220_s6ado_cd, mf_cs220_captu_cd, mf_cs220_infch_cd,
    mf_cs220_picu_cd)
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1
     AND p.birth_dt_tm < cnvtlookbehind("18,Y"))
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=0))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "PD0101"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "253"
    ENDIF
  ENDFOR
 ELSEIF (trim(cnvtupper( $S_SURVEY),3)="PD0102")
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bmc_cd
     AND e.loc_nurse_unit_cd IN (mf_cs220_s6ado_cd, mf_cs220_captu_cd, mf_cs220_infch_cd,
    mf_cs220_picu_cd)
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1
     AND p.birth_dt_tm < cnvtlookbehind("18,Y"))
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=1))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "PD0102"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "253"
    ENDIF
  ENDFOR
 ELSEIF (trim(cnvtupper( $S_SURVEY),3)="IN0101")
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bmc_cd
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1
     AND p.birth_dt_tm >= cnvtlookbehind("18,Y"))
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=0))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "IN0101"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "253"
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bmc_cd
     AND e.loc_nurse_unit_cd IN (mf_cs220_ldrpa_cd, mf_cs220_ldrpb_cd, mf_cs220_ldrpc_cd,
    mf_cs220_win2_cd)
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1
     AND p.birth_dt_tm < cnvtlookbehind("18,Y"))
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=0))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "IN0101"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "253"
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bnh_cd
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=0))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "IN0101"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "2111"
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bwh_cd
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=0))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "IN0101"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "5577"
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_fmc_cd
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=0))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "IN0101"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "24259"
    ENDIF
  ENDFOR
 ELSEIF (trim(cnvtupper( $S_SURVEY),3)="IN0102")
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bmc_cd
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1
     AND p.birth_dt_tm >= cnvtlookbehind("18,Y"))
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=1))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "IN0102"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "253"
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bmc_cd
     AND e.loc_nurse_unit_cd IN (mf_cs220_ldrpa_cd, mf_cs220_ldrpb_cd, mf_cs220_ldrpc_cd,
    mf_cs220_win2_cd)
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1
     AND p.birth_dt_tm < cnvtlookbehind("18,Y"))
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=1))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "IN0102"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "253"
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bnh_cd
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=1))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "IN0102"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "2111"
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_bwh_cd
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=1))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "IN0102"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "5577"
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
     AND e.active_ind=1
     AND e.loc_facility_cd=mf_cs220_fmc_cd
     AND e.encntr_type_cd IN (mf_cs71_dischip_cd, mf_cs71_dischobv_cd, mf_cs71_expiredip_cd,
    mf_cs71_expiredobv_cd, mf_cs71_inpatient_cd,
    mf_cs71_observation_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.deceased_dt_tm = null
     AND p.active_ind=1)
   ORDER BY e.encntr_id
   HEAD REPORT
    m_tmp->l_cnt = 0, stat = alterlist(m_tmp->qual,0)
   HEAD e.encntr_id
    m_tmp->l_cnt += 1, stat = alterlist(m_tmp->qual,m_tmp->l_cnt), m_tmp->qual[m_tmp->l_cnt].
    f_encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh
   PLAN (elh
    WHERE expand(ml_idx1,1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
     AND elh.active_ind=1
     AND elh.encntr_type_cd=mf_cs71_emergency_cd)
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    ml_idx2 = locatevalsort(ml_idx1,m_tmp->l_cnt,elh.encntr_id,m_tmp->qual[ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     m_tmp->qual[ml_idx2].l_ed_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO m_tmp->l_cnt)
    IF ((m_tmp->qual[ml_idx1].l_ed_ind=1))
     SET m_enc->l_cnt += 1
     SET stat = alterlist(m_enc->qual,m_enc->l_cnt)
     SET m_enc->qual[m_enc->l_cnt].f_encntr_id = m_tmp->qual[ml_idx1].f_encntr_id
     SET m_enc->qual[m_enc->l_cnt].s_survey_designator = "IN0102"
     SET m_enc->qual[m_enc->l_cnt].s_client_cd = "24259"
    ENDIF
  ENDFOR
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_enc_id = f8
     2 s_survey_designator = vc
     2 s_client_id = vc
     2 s_lname = vc
     2 s_fname = vc
     2 s_mname = vc
     2 s_addr1 = vc
     2 s_addr2 = vc
     2 s_city = vc
     2 s_state = vc
     2 s_zip = vc
     2 s_phone = vc
     2 s_cell = vc
     2 s_ms_drg = vc
     2 s_gender = vc
     2 s_race = vc
     2 s_ethnicity = vc
     2 s_dob = vc
     2 s_language = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_location_code = vc
     2 s_location_name = vc
     2 s_attending_npi = vc
     2 s_attending_name = vc
     2 s_provider_type = vc
     2 s_provider_specialty = vc
     2 s_loc_addr1 = vc
     2 s_loc_addr2 = vc
     2 s_loc_city = vc
     2 s_loc_state = vc
     2 s_loc_zip = vc
     2 s_admit_source = vc
     2 s_admit_dt = vc
     2 s_admit_time = vc
     2 s_disch_dt = vc
     2 s_disch_time = vc
     2 s_disch_disp = vc
     2 s_unit = vc
     2 s_service = vc
     2 s_specialty = vc
     2 s_payor = vc
     2 s_los = vc
     2 s_room = vc
     2 s_bed = vc
     2 s_attend_hosp_ind = vc
     2 s_fast_track = vc
     2 s_email = vc
     2 s_hospitalist_1_npi = vc
     2 s_hospitalist_2_npi = vc
     2 s_er_admit = vc
     2 s_other_diag = vc
     2 s_proc_code1 = vc
     2 s_proc_code2 = vc
     2 s_proc_code3 = vc
     2 s_proc_code4 = vc
     2 s_proc_code5 = vc
     2 s_proc_code6 = vc
     2 s_deceased_flag = vc
     2 s_no_publicity_flat = vc
     2 s_state_regulation_flag = vc
     2 s_newborn_patient = vc
     2 s_transferred_admit_to_inpat = vc
     2 l_exclude_ind = i4
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2,
   address a,
   phone ph1,
   phone ph2,
   code_value cv
  PLAN (e
   WHERE expand(ml_idx1,1,m_enc->l_cnt,e.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.deceased_dt_tm = null)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea1.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn_cd)
   JOIN (a
   WHERE a.parent_entity_id=p.person_id
    AND a.address_type_cd=mf_cs212_home_addr_cd
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ph1
   WHERE ph1.parent_entity_id=p.person_id
    AND ph1.phone_type_cd=mf_cs43_home_phone_cd
    AND ph1.parent_entity_name="PERSON"
    AND ph1.active_ind=1
    AND ph1.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ph2
   WHERE ph2.parent_entity_id=p.person_id
    AND ph2.phone_type_cd=mf_cs43_cell_phone_cd
    AND ph2.parent_entity_name="PERSON"
    AND ph2.active_ind=1
    AND ph2.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (cv
   WHERE cv.code_value=e.med_service_cd)
  ORDER BY e.encntr_id, a.address_type_seq, ph1.phone_type_seq,
   ph2.phone_type_seq
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].f_enc_id
    = e.encntr_id,
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,e.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
   IF (ml_idx2 > 0)
    m_rec->qual[m_rec->l_cnt].s_client_id = m_enc->qual[ml_idx2].s_client_cd, m_rec->qual[m_rec->
    l_cnt].s_survey_designator = m_enc->qual[ml_idx2].s_survey_designator
   ELSE
    m_rec->qual[m_rec->l_cnt].s_client_id = "9999", m_rec->qual[m_rec->l_cnt].s_survey_designator =
    "9999"
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_lname = trim(p.name_last,3), m_rec->qual[m_rec->l_cnt].s_fname = trim(
    p.name_first,3), m_rec->qual[m_rec->l_cnt].s_mname = trim(p.name_middle,3),
   m_rec->qual[m_rec->l_cnt].s_addr1 = trim(a.street_addr,3), m_rec->qual[m_rec->l_cnt].s_addr2 =
   trim(a.street_addr2,3), m_rec->qual[m_rec->l_cnt].s_city = trim(evaluate(a.city_cd,0.0,a.city,
     uar_get_code_display(a.city_cd)),3),
   m_rec->qual[m_rec->l_cnt].s_state = trim(evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a
      .state_cd)),3), m_rec->qual[m_rec->l_cnt].s_zip = substring(1,5,trim(a.zipcode_key,3)), m_rec->
   qual[m_rec->l_cnt].s_phone = trim(ph1.phone_num_key,3),
   m_rec->qual[m_rec->l_cnt].s_cell = trim(ph2.phone_num_key,3)
   IF (p.sex_cd=mf_cs57_male_cd)
    m_rec->qual[m_rec->l_cnt].s_gender = "1"
   ELSEIF (p.sex_cd=mf_cs57_female_cd)
    m_rec->qual[m_rec->l_cnt].s_gender = "2"
   ELSE
    m_rec->qual[m_rec->l_cnt].s_gender = "M"
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_dob = trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
       .birth_tz),1),"MMDDYYYY;;q"),3), m_rec->qual[m_rec->l_cnt].s_language = "1", m_rec->qual[m_rec
   ->l_cnt].s_fin = trim(ea1.alias,3),
   m_rec->qual[m_rec->l_cnt].s_mrn = trim(ea2.alias,3), m_rec->qual[m_rec->l_cnt].s_location_code =
   trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->qual[m_rec->l_cnt].s_location_name = trim(
    uar_get_code_display(e.loc_facility_cd),3),
   m_rec->qual[m_rec->l_cnt].s_admit_source = uar_get_code_display(e.admit_src_cd), m_rec->qual[m_rec
   ->l_cnt].s_admit_dt = trim(format(e.reg_dt_tm,"MMDDYYYY;;q"),3), m_rec->qual[m_rec->l_cnt].
   s_disch_dt = trim(format(e.disch_dt_tm,"MMDDYYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_disch_disp = uar_get_code_display(e.disch_disposition_cd), m_rec->
   qual[m_rec->l_cnt].s_deceased_flag = "N", m_rec->qual[m_rec->l_cnt].s_no_publicity_flat = "N",
   m_rec->qual[m_rec->l_cnt].s_state_regulation_flag = "N"
   IF (trim(cv.display_key,3) IN ("INPATIENTNEWBORN", "NEWBORN"))
    m_rec->qual[m_rec->l_cnt].s_newborn_patient = "Y"
   ELSE
    m_rec->qual[m_rec->l_cnt].s_newborn_patient = "N"
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM drg d,
   nomenclature n
  PLAN (d
   WHERE expand(ml_idx1,1,m_rec->l_cnt,d.encntr_id,m_rec->qual[ml_idx1].f_enc_id)
    AND d.active_ind=1
    AND d.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.source_vocabulary_cd=mf_cs400_msdrg_cd)
  ORDER BY d.encntr_id, d.drg_priority
  HEAD d.encntr_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,d.encntr_id,m_rec->qual[ml_idx1].f_enc_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_ms_drg = trim(n.source_identifier,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl p,
   prsnl_alias pa,
   person_name pn,
   eem_prov_tax_reltn eptr,
   provider_taxonomy pt
  PLAN (epr
   WHERE expand(ml_idx1,1,m_rec->l_cnt,epr.encntr_id,m_rec->qual[ml_idx1].f_enc_id)
    AND epr.active_ind=1
    AND epr.encntr_prsnl_r_cd=mf_cs333_attenddoc_cd)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.prsnl_alias_type_cd=mf_cs320_npi_cd)
   JOIN (pn
   WHERE pn.person_id=epr.prsnl_person_id
    AND pn.active_ind=1
    AND pn.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pn.name_type_cd=mf_cs213_prsnlname_cd)
   JOIN (eptr
   WHERE (eptr.parent_entity_id= Outerjoin(epr.prsnl_person_id))
    AND (eptr.parent_entity_name= Outerjoin("PRSNL"))
    AND (eptr.active_ind= Outerjoin(1)) )
   JOIN (pt
   WHERE (pt.taxonomy_id= Outerjoin(eptr.taxonomy_id)) )
  ORDER BY epr.encntr_id, epr.beg_effective_dt_tm DESC, pn.beg_effective_dt_tm DESC,
   eptr.beg_effective_dt_tm DESC
  HEAD epr.encntr_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,epr.encntr_id,m_rec->qual[ml_idx1].f_enc_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_attending_name = trim(p.name_full_formatted,3), m_rec->qual[ml_idx2].
    s_attending_npi = trim(pa.alias,3), m_rec->qual[ml_idx2].s_provider_type = trim(pn.name_title,3),
    m_rec->qual[ml_idx2].s_provider_specialty = trim(uar_get_code_display(pt.specialization_cd),3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl;"
  FROM encounter e,
   address a
  PLAN (e
   WHERE expand(ml_idx1,1,m_rec->l_cnt,e.encntr_id,m_rec->qual[ml_idx1].f_enc_id))
   JOIN (a
   WHERE a.parent_entity_id=e.organization_id
    AND a.parent_entity_name="ORGANIZATION"
    AND a.address_type_cd=mf_cs212_bus_addr_cd
    AND a.active_ind=1
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY e.encntr_id, a.address_type_seq
  HEAD e.encntr_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,e.encntr_id,m_rec->qual[ml_idx1].f_enc_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_loc_addr1 = trim(a.street_addr,3), m_rec->qual[ml_idx2].s_loc_addr2 = trim
    (a.street_addr2,3), m_rec->qual[ml_idx2].s_loc_city = trim(evaluate(a.city_cd,0.0,a.city,
      uar_get_code_display(a.city_cd)),3),
    m_rec->qual[ml_idx2].s_loc_state = trim(evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a
       .state_cd)),3), m_rec->qual[ml_idx2].s_loc_zip = substring(1,5,trim(a.zipcode_key,3))
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl;"
  FROM encounter e,
   address a
  PLAN (e
   WHERE expand(ml_idx1,1,m_rec->l_cnt,e.encntr_id,m_rec->qual[ml_idx1].f_enc_id))
   JOIN (a
   WHERE a.parent_entity_id=e.person_id
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=mf_cs212_email_addr_cd
    AND a.active_ind=1
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY e.encntr_id, a.address_type_seq
  HEAD e.encntr_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,e.encntr_id,m_rec->qual[ml_idx1].f_enc_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_email = trim(a.street_addr,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM procedure p,
   coding c,
   nomenclature n
  PLAN (p
   WHERE expand(ml_idx1,1,m_rec->l_cnt,p.encntr_id,m_rec->qual[ml_idx1].f_enc_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (c
   WHERE c.encntr_id=p.encntr_id
    AND c.contributor_system_cd=p.contributor_system_cd
    AND c.active_ind=1
    AND c.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id
    AND n.source_vocabulary_cd IN (mf_cs400_hcpcs_cd, mf_cs400_cpt_cd))
  ORDER BY p.encntr_id, p.proc_priority, p.procedure_id
  HEAD p.encntr_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,p.encntr_id,m_rec->qual[ml_idx1].f_enc_id), ml_cnt
    = 0
  HEAD p.procedure_id
   IF (ml_idx2 > 0)
    IF (n.source_vocabulary_cd=mf_cs400_hcpcs_cd
     AND trim(n.source_identifier,3) IN ("G0104", "G0105", "G0121", "G0260"))
     ml_cnt += 1
     IF (ml_cnt=1)
      m_rec->qual[ml_idx2].s_proc_code1 = trim(n.source_identifier,3)
     ENDIF
     IF (ml_cnt=2)
      m_rec->qual[ml_idx2].s_proc_code2 = trim(n.source_identifier,3)
     ENDIF
     IF (ml_cnt=3)
      m_rec->qual[ml_idx2].s_proc_code3 = trim(n.source_identifier,3)
     ENDIF
     IF (ml_cnt=4)
      m_rec->qual[ml_idx2].s_proc_code4 = trim(n.source_identifier,3)
     ENDIF
     IF (ml_cnt=5)
      m_rec->qual[ml_idx2].s_proc_code5 = trim(n.source_identifier,3)
     ENDIF
     IF (ml_cnt=6)
      m_rec->qual[ml_idx2].s_proc_code6 = trim(n.source_identifier,3)
     ENDIF
    ELSEIF (n.source_vocabulary_cd=mf_cs400_cpt_cd
     AND isnumeric(n.source_identifier) > 0)
     IF (cnvtint(trim(n.source_identifier,3)) BETWEEN 10004 AND 69990)
      ml_cnt += 1
      IF (ml_cnt=1)
       m_rec->qual[ml_idx2].s_proc_code1 = trim(n.source_identifier,3)
      ENDIF
      IF (ml_cnt=2)
       m_rec->qual[ml_idx2].s_proc_code2 = trim(n.source_identifier,3)
      ENDIF
      IF (ml_cnt=3)
       m_rec->qual[ml_idx2].s_proc_code3 = trim(n.source_identifier,3)
      ENDIF
      IF (ml_cnt=4)
       m_rec->qual[ml_idx2].s_proc_code4 = trim(n.source_identifier,3)
      ENDIF
      IF (ml_cnt=5)
       m_rec->qual[ml_idx2].s_proc_code5 = trim(n.source_identifier,3)
      ENDIF
      IF (ml_cnt=6)
       m_rec->qual[ml_idx2].s_proc_code6 = trim(n.source_identifier,3)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF ((m_rec->qual[ml_idx1].s_survey_designator="AS0101"))
    IF (size(trim(m_rec->qual[ml_idx1].s_proc_code1,3))=0)
     SET m_rec->qual[ml_idx1].l_exclude_ind = 1
    ENDIF
   ENDIF
 ENDFOR
 IF (( $L_UPDT_IND=1))
  SET frec->file_name = concat(trim(logical("BHSCUST"),3),"/press_ganey/","bhsupdate",cnvtlower(trim(
      $S_SURVEY,3)),"prod",
   trim(format(cnvtdatetime(sysdate),"YYYYMMDD;;q"),3),".csv")
 ELSE
  SET frec->file_name = concat(trim(logical("BHSCUST"),3),"/press_ganey/","bhs",cnvtlower(trim(
      $S_SURVEY,3)),"prod",
   trim(format(cnvtdatetime(sysdate),"YYYYMMDD;;q"),3),".csv")
 ENDIF
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = concat('"',"Survey Designator",'","',"Client ID",'","',
  "Last Name",'","',"Middle Initial",'","',"First Name",
  '","',"Address 1",'","',"Address 2",'","',
  "City",'","',"State",'","',"ZIP Code",
  '","',"Telephone Number",'","',"Mobile Number",'","',
  "MS-DRG",'","',"Gender",'","',"Race",
  '","',"Ethnicity",'","',"Date of Birth",'","',
  "Language",'","',"Medical Record Number",'","',"Unique ID",
  '","',"Location Code",'","',"Location Name",'","',
  "Attending Physician NPI",'","',"Attending Physician Name",'","',"Provider type",
  '","',"Provider specialty",'","',"Site address 1",'","',
  "Site address 2",'","',"Site city",'","',"Site state",
  '","',"Site zip",'","',"Patient Admission Source",'","',
  "Visit or Admit Date",'","',"Visit or Admit Time",'","',"Discharge Date",
  '","',"Discharge Time",'","',"Patient Discharge Status",'","',
  "Unit",'","',"Service",'","',"Specialty",
  '","',"Payor/Insurance/Financial Class",'","',"Length of Stay",'","',
  "Room",'","',"Bed",'","',"Hospitalist",
  '","',"Fast Track or Acute Flag",'","',"Email",'","',
  "Hospitalist_1",'","',"Hospitalist_2",'","',"ER_ADMIT",
  '","',"Other Diagnosis or Procedure Code",'","',"Procedure Code 1",'","',
  "Procedure Code 2",'","',"Procedure Code 3",'","',"Procedure Code 4",
  '","',"Procedure Code 5",'","',"Procedure Code 6",'","',
  "Deceased Flag",'","',"No Publicity Flag",'","',"State Regulation Flag",
  '","',"Newborn patient",'","',"Transferred/admitted to inpatient",'","',
  "E.O.R Indicator",char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF ((m_rec->qual[ml_idx1].l_exclude_ind=0))
    SET frec->file_buf = concat('"',trim(substring(1,8,m_rec->qual[ml_idx1].s_survey_designator),3),
     '","',trim(substring(1,7,m_rec->qual[ml_idx1].s_client_id),3),'","',
     trim(substring(1,25,m_rec->qual[ml_idx1].s_lname),3),'","',trim(substring(1,1,m_rec->qual[
       ml_idx1].s_mname),3),'","',trim(substring(1,20,m_rec->qual[ml_idx1].s_fname),3),
     '","',trim(substring(1,40,m_rec->qual[ml_idx1].s_addr1),3),'","',trim(substring(1,40,m_rec->
       qual[ml_idx1].s_addr2),3),'","',
     trim(substring(1,25,m_rec->qual[ml_idx1].s_city),3),'","',trim(substring(1,2,m_rec->qual[ml_idx1
       ].s_state),3),'","',trim(substring(1,10,m_rec->qual[ml_idx1].s_zip),3),
     '","',trim(substring(1,12,m_rec->qual[ml_idx1].s_phone),3),'","',trim(substring(1,12,m_rec->
       qual[ml_idx1].s_cell),3),'","',
     trim(substring(1,3,m_rec->qual[ml_idx1].s_ms_drg),3),'","',trim(substring(1,1,m_rec->qual[
       ml_idx1].s_gender),3),'","',trim(substring(1,50,m_rec->qual[ml_idx1].s_race),3),
     '","',trim(substring(1,50,m_rec->qual[ml_idx1].s_ethnicity),3),'","',trim(substring(1,10,m_rec->
       qual[ml_idx1].s_dob),3),'","',
     trim(substring(1,50,m_rec->qual[ml_idx1].s_language),3),'","',trim(substring(1,20,m_rec->qual[
       ml_idx1].s_mrn),3),'","',trim(substring(1,20,m_rec->qual[ml_idx1].s_fin),3),
     '","',trim(substring(1,50,m_rec->qual[ml_idx1].s_location_code),3),'","',trim(substring(1,50,
       m_rec->qual[ml_idx1].s_location_name),3),'","',
     trim(substring(1,50,m_rec->qual[ml_idx1].s_attending_npi),3),'","',trim(substring(1,50,m_rec->
       qual[ml_idx1].s_attending_name),3),'","',trim(substring(1,50,m_rec->qual[ml_idx1].
       s_provider_type),3),
     '","',trim(substring(1,50,m_rec->qual[ml_idx1].s_provider_specialty),3),'","',trim(substring(1,
       40,m_rec->qual[ml_idx1].s_loc_addr1),3),'","',
     trim(substring(1,40,m_rec->qual[ml_idx1].s_loc_addr2),3),'","',trim(substring(1,25m_rec->qual[
       ml_idx1].s_loc_city),3),'","',trim(substring(1,2,m_rec->qual[ml_idx1].s_loc_state),3),
     '","',trim(substring(1,10,m_rec->qual[ml_idx1].s_loc_zip),3),'","',trim(substring(1,1,m_rec->
       qual[ml_idx1].s_admit_source),3),'","',
     trim(substring(1,10,m_rec->qual[ml_idx1].s_admit_dt),3),'","',trim(substring(1,5,m_rec->qual[
       ml_idx1].s_admit_time),3),'","',trim(substring(1,10,m_rec->qual[ml_idx1].s_disch_dt),3),
     '","',trim(substring(1,5,m_rec->qual[ml_idx1].s_disch_time),3),'","',trim(substring(1,2,m_rec->
       qual[ml_idx1].s_disch_disp),3),'","',
     trim(substring(1,50,m_rec->qual[ml_idx1].s_unit),3),'","',trim(substring(1,50,m_rec->qual[
       ml_idx1].s_service),3),'","',trim(substring(1,50,m_rec->qual[ml_idx1].s_specialty),3),
     '","',trim(substring(1,50,m_rec->qual[ml_idx1].s_payor),3),'","',trim(substring(1,50,m_rec->
       qual[ml_idx1].s_los),3),'","',
     trim(substring(1,50,m_rec->qual[ml_idx1].s_room),3),'","',trim(substring(1,50,m_rec->qual[
       ml_idx1].s_bed),3),'","',trim(substring(1,50,m_rec->qual[ml_idx1].s_attend_hosp_ind),3),
     '","',trim(substring(1,1,m_rec->qual[ml_idx1].s_fast_track),3),'","',trim(substring(1,60,m_rec->
       qual[ml_idx1].s_email),3),'","',
     trim(substring(1,50,m_rec->qual[ml_idx1].s_hospitalist_1_npi),3),'","',trim(substring(1,50,m_rec
       ->qual[ml_idx1].s_hospitalist_2_npi),3),'","',trim(substring(1,1,m_rec->qual[ml_idx1].
       s_er_admit),3),
     '","',trim(substring(1,50,m_rec->qual[ml_idx1].s_other_diag),3),'","',trim(substring(1,10,m_rec
       ->qual[ml_idx1].s_proc_code1),3),'","',
     trim(substring(1,10,m_rec->qual[ml_idx1].s_proc_code2),3),'","',trim(substring(1,10,m_rec->qual[
       ml_idx1].s_proc_code3),3),'","',trim(substring(1,10,m_rec->qual[ml_idx1].s_proc_code4),3),
     '","',trim(substring(1,10,m_rec->qual[ml_idx1].s_proc_code5),3),'","',trim(substring(1,10,m_rec
       ->qual[ml_idx1].s_proc_code6),3),'","',
     trim(substring(1,1,m_rec->qual[ml_idx1].s_deceased_flag),3),'","',trim(substring(1,1,m_rec->
       qual[ml_idx1].s_no_publicity_flat),3),'","',trim(substring(1,1,m_rec->qual[ml_idx1].
       s_state_regulation_flag),3),
     '","',trim(substring(1,1,m_rec->qual[ml_idx1].s_newborn_patient),3),'","',trim(substring(1,1,
       m_rec->qual[ml_idx1].s_transferred_admit_to_inpat),3),'","',
     "$",'"',char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ENDIF
 ENDFOR
 SET stat = cclio("CLOSE",frec)
#exit_script
END GO
