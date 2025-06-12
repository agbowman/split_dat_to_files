CREATE PROGRAM bhs_rpt_adverse_events_test:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, ms_start_date, ms_end_date
 DECLARE mf_cs400_snomedct_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"SNOMEDCT"
   ))
 DECLARE mf_cs200_cefazolin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CEFAZOLIN"))
 DECLARE mf_cs200_clindamycin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CLINDAMYCIN"))
 DECLARE mf_cs200_vancomycin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VANCOMYCIN"))
 DECLARE mf_cs200_penicillingpotassium_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"PENICILLINGPOTASSIUM"))
 DECLARE mf_cs6004_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "COMPLETED"))
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"
   ))
 DECLARE mf_cs6004_inprocess_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "INPROCESS"))
 DECLARE mf_cs72_deliverycomplications_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DELIVERYCOMPLICATIONS"))
 DECLARE mf_cs72_bloodproducttransfused_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"BLOODPRODUCTTRANSFUSED"))
 DECLARE mf_cs72_bloodloss_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BLOODLOSS"
   ))
 DECLARE mf_cs72_groupbstreptrans_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GROUPBSTREPTRANSCRIBEDRESULT"))
 DECLARE mf_cs72_csectionpriority_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CSECTIONPRIORITY"))
 DECLARE mf_cs72_fetalcomplications1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Fetal Complications:"))
 DECLARE mf_cs72_fetalcomplications2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Fetal Complications"))
 DECLARE mf_cs72_birthcomplications1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Birth Complications"))
 DECLARE mf_cs72_birthcomplications2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Birth Complications:"))
 DECLARE mf_cs72_operativedelivery_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "OPERATIVEDELIVERY"))
 DECLARE mf_cs72_reasonforcsection_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REASONFORCSECTION"))
 DECLARE mf_cs72_fetalposition1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Fetal Position:"))
 DECLARE mf_cs72_fetalposition2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Fetal Position"))
 DECLARE mf_cs72_neonateoutcome_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEONATEOUTCOME"))
 DECLARE mf_cs72_neonatecomplications1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Neonate Complications:"))
 DECLARE mf_cs72_neonatecomplications2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Neonate Complications"))
 DECLARE mf_cs72_transferredto1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Transferred To:"))
 DECLARE mf_cs72_transferredto2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Transferred To"))
 DECLARE mf_cs72_apgarscore5minute_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "APGARSCORE5MINUTE"))
 DECLARE mf_cs72_pharterial_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHARTERIAL"))
 DECLARE mf_cs72_ph_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PH"))
 DECLARE mf_cs72_nicuteamcalled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "NICU team called"))
 DECLARE mf_cs72_nicuteamcalled2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "NICU team called:"))
 DECLARE mf_cs72_maternitycomplications_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"MATERNITYCOMPLICATIONS"))
 DECLARE mf_cs72_datetimeofbirth_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Date, Time of Birth:"))
 DECLARE mf_cs72_birthweight_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Birth Weight:"))
 DECLARE mf_cs72_apgarscore1minute_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,
   "APGARSCORE1MINUTE"))
 DECLARE mf_cs72_deliveryphysician_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,
   "DELIVERYPHYSICIAN"))
 DECLARE mf_cs72_deliverycnm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,
   "DELIVERYCNM"))
 DECLARE mf_cs72_deliverytype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Delivery Type:"))
 DECLARE mf_cs72_egaatdocumenteddatetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",
   72,"EGAATDOCUMENTEDDATETIME"))
 DECLARE mf_cs4002015_inerror_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",4002015,
   "INERROR"))
 DECLARE mf_cs72_attendingprovider_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,
   "ATTENDINGPROVIDER"))
 DECLARE mf_cs4002015_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",4002015,
   "ACTIVE"))
 DECLARE mf_cs4002015_inactive_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",4002015,
   "INACTIVE"))
 DECLARE mf_cs72_magnesium_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MAGNESIUM"
   ))
 DECLARE mf_cs72_magnesiumplasma_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MAGNESIUMPLASMA"))
 DECLARE mf_cs72_magnesiumrbc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MAGNESIUMRBC"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs6000_surgery_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"SURGERY"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cs220_mock_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"MOCK"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 DECLARE ml_transfuse_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_beg_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE ms_outdev = vc WITH protect, noconstant(value( $OUTDEV))
 IF (ms_outdev="OPS")
  SET mf_end_dt_tm = cnvtdatetime((curdate - 1),070000)
  SET mf_beg_dt_tm = cnvtdatetime((curdate - 15),070000)
 ELSE
  SET mf_beg_dt_tm = cnvtdatetime(cnvtdate2( $MS_START_DATE,"DD-MMM-YYYY"),0)
  SET mf_end_dt_tm = cnvtdatetime(cnvtdate2( $MS_END_DATE,"DD-MMM-YYYY"),235959)
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 FREE RECORD nurs_loc
 RECORD nurs_loc(
   1 l_mom_cnt = i4
   1 mom_unit[*]
     2 f_code_value = f8
     2 s_display = vc
   1 l_icu_cnt = i4
   1 icu_unit[*]
     2 f_code_value = f8
     2 s_display = vc
 ) WITH protect
 FREE RECORD m_enc
 RECORD m_enc(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_decease_date = f8
     2 n_eclampsia_ind = i2
     2 n_pulmedema_ind = i2
     2 n_dvtpe_ind = i2
     2 n_icu_ind = i2
     2 n_surg_proc_ind = i2
     2 n_hysterectomy_ind = i2
     2 n_antibiotic_order = i2
     2 n_uterine_rupture_ind = i2
     2 n_transfusion_4_unit_ind = i2
     2 n_postpartum_hemorrhage_ind = i2
     2 n_antibiotic_prophylaxis_ind = i2
     2 n_code_blue_ind = i2
     2 n_inraamniotic_infection_ind = i2
     2 n_csec_code_white_ind = i2
     2 n_shoulder_dystocia_ind = i2
     2 n_forcep_delivery_ind = i2
     2 n_vacuum_deliver_ind = i2
     2 n_failed_tolac_ind = i2
     2 n_singleton_ind = i2
     2 n_neonatal_death_ind = i2
     2 n_traumatic_birth_ind = i2
     2 n_unexpected_nicu_ind = i2
     2 n_term_apgar_ind = i2
     2 n_cord_ph_ind = i2
     2 n_nicu_code_c_ind = i2
     2 n_magnesium_tox_ind = i2
     2 l_qual_cnt = i4
     2 s_qual_str = vc
     2 s_pat_name = vc
     2 s_pat_mrn = vc
     2 s_gest_age = vc
     2 s_prim_surgeon = vc
     2 s_delivery_ega = vc
     2 n_vag_del = i2
     2 l_dyn_cnt = i4
     2 dyn_grp[*]
       3 f_dyn_grp_id = f8
       3 s_dyn_grp_label = vc
       3 s_del_provider = vc
       3 s_attend_provider = vc
       3 s_del_cnm = vc
       3 s_birth_weight = vc
       3 s_birth_dt = vc
       3 s_apgar_1min = vc
       3 s_apgar_5min = vc
       3 s_neonate_outcome = vc
       3 s_del_type = vc
     2 l_evcnt = i4
     2 event_qual[*]
       3 f_event_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key IN ("WIN2", "WETU1", "OBGN", "LDRPA", "LDRPB",
   "LDRPC")
    AND cv.active_ind=1)
  HEAD REPORT
   nurs_loc->l_mom_cnt = 0
  DETAIL
   nurs_loc->l_mom_cnt = (nurs_loc->l_mom_cnt+ 1), stat = alterlist(nurs_loc->mom_unit,nurs_loc->
    l_mom_cnt), nurs_loc->mom_unit[nurs_loc->l_mom_cnt].f_code_value = cv.code_value,
   nurs_loc->mom_unit[nurs_loc->l_mom_cnt].s_display = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key="*ICU*"
    AND cv.cdf_meaning="NURSEUNIT"
    AND cv.active_ind=1)
  HEAD REPORT
   nurs_loc->l_icu_cnt = 0
  DETAIL
   nurs_loc->l_icu_cnt = (nurs_loc->l_icu_cnt+ 1), stat = alterlist(nurs_loc->icu_unit,nurs_loc->
    l_icu_cnt), nurs_loc->icu_unit[nurs_loc->l_icu_cnt].f_code_value = cv.code_value,
   nurs_loc->icu_unit[nurs_loc->l_icu_cnt].s_display = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   encntr_loc_hist elh,
   person p
  PLAN (ce
   WHERE ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_auth_cd, mf_cs8_altered_cd,
   mf_cs8_modified_cd)
    AND ce.event_cd IN (mf_cs72_deliverycomplications_cd, mf_cs72_bloodproducttransfused_cd,
   mf_cs72_bloodloss_cd, mf_cs72_groupbstreptrans_cd, mf_cs72_csectionpriority_cd,
   mf_cs72_fetalcomplications1_cd, mf_cs72_fetalcomplications2_cd, mf_cs72_operativedelivery_cd,
   mf_cs72_reasonforcsection_cd, mf_cs72_fetalposition1_cd,
   mf_cs72_fetalposition2_cd, mf_cs72_neonateoutcome_cd, mf_cs72_neonatecomplications1_cd,
   mf_cs72_neonatecomplications2_cd, mf_cs72_transferredto1_cd,
   mf_cs72_apgarscore5minute_cd, mf_cs72_pharterial_cd, mf_cs72_nicuteamcalled_cd,
   mf_cs72_nicuteamcalled2_cd, mf_cs72_maternitycomplications_cd,
   mf_cs72_magnesium_cd, mf_cs72_magnesiumplasma_cd, mf_cs72_magnesiumrbc_cd,
   mf_cs72_egaatdocumenteddatetime_cd, mf_cs72_transferredto2_cd,
   mf_cs72_ph_cd, mf_cs72_deliverytype_cd, mf_cs72_birthcomplications1_cd,
   mf_cs72_birthcomplications2_cd))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.active_ind=1
    AND e.loc_facility_cd != mf_cs220_mock_cd)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND expand(ml_idx1,1,nurs_loc->l_mom_cnt,elh.loc_nurse_unit_cd,nurs_loc->mom_unit[ml_idx1].
    f_code_value))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.encntr_id, ce.event_cd
  HEAD e.encntr_id
   m_enc->l_cnt = (m_enc->l_cnt+ 1), stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->
   l_cnt].f_encntr_id = e.encntr_id,
   m_enc->qual[m_enc->l_cnt].f_person_id = e.person_id, m_enc->qual[m_enc->l_cnt].f_decease_date =
   cnvtdatetime(p.deceased_dt_tm)
   IF ((m_enc->qual[m_enc->l_cnt].f_decease_date > 0.0))
    m_enc->qual[m_enc->l_cnt].l_qual_cnt = (m_enc->qual[m_enc->l_cnt].l_qual_cnt+ 1)
   ENDIF
  HEAD ce.event_cd
   m_enc->qual[m_enc->l_cnt].l_evcnt = (m_enc->qual[m_enc->l_cnt].l_evcnt+ 1), stat = alterlist(m_enc
    ->qual[m_enc->l_cnt].event_qual,m_enc->qual[m_enc->l_cnt].l_evcnt), m_enc->qual[m_enc->l_cnt].
   event_qual[m_enc->qual[m_enc->l_cnt].l_evcnt].f_event_cd = ce.event_cd
  WITH nocounter
 ;end select
 CALL echorecord(m_enc)
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_loc_hist elh,
   encntr_loc_hist elh2,
   person p
  PLAN (elh
   WHERE elh.updt_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND expand(ml_idx2,1,nurs_loc->l_icu_cnt,elh.loc_nurse_unit_cd,nurs_loc->icu_unit[ml_idx2].
    f_code_value))
   JOIN (e
   WHERE e.encntr_id=elh.encntr_id
    AND  NOT (expand(ml_idx1,1,m_enc->l_cnt,e.encntr_id,m_enc->qual[ml_idx1].f_encntr_id))
    AND e.active_ind=1
    AND e.loc_facility_cd != mf_cs220_mock_cd)
   JOIN (elh2
   WHERE elh2.encntr_id=e.encntr_id
    AND expand(ml_idx3,1,nurs_loc->l_mom_cnt,elh2.loc_nurse_unit_cd,nurs_loc->mom_unit[ml_idx3].
    f_code_value))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_enc->l_cnt = (m_enc->l_cnt+ 1), stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->
   l_cnt].f_encntr_id = e.encntr_id,
   m_enc->qual[m_enc->l_cnt].f_person_id = e.person_id, m_enc->qual[m_enc->l_cnt].f_decease_date =
   cnvtdatetime(p.deceased_dt_tm)
   IF ((m_enc->qual[m_enc->l_cnt].f_decease_date > 0.0))
    m_enc->qual[m_enc->l_cnt].l_qual_cnt = (m_enc->qual[m_enc->l_cnt].l_qual_cnt+ 1)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_catalog oc,
   encounter e,
   person p,
   encntr_loc_hist elh
  PLAN (o
   WHERE o.updt_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND  NOT (expand(ml_idx1,1,m_enc->l_cnt,o.encntr_id,m_enc->qual[ml_idx1].f_encntr_id))
    AND o.order_status_cd IN (mf_cs6004_completed_cd, mf_cs6004_ordered_cd, mf_cs6004_inprocess_cd)
    AND o.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd
    AND oc.catalog_type_cd=mf_cs6000_surgery_cd
    AND  NOT (oc.primary_mnemonic IN ("Cesarean Section", "Cesarean with Tubal Ligation"))
    AND oc.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND e.loc_facility_cd != mf_cs220_mock_cd)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND expand(ml_idx3,1,nurs_loc->l_mom_cnt,elh.loc_nurse_unit_cd,nurs_loc->mom_unit[ml_idx3].
    f_code_value))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_enc->l_cnt = (m_enc->l_cnt+ 1), stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->
   l_cnt].f_encntr_id = e.encntr_id,
   m_enc->qual[m_enc->l_cnt].f_person_id = e.person_id, m_enc->qual[m_enc->l_cnt].f_decease_date =
   cnvtdatetime(p.deceased_dt_tm)
   IF ((m_enc->qual[m_enc->l_cnt].f_decease_date > 0.0))
    m_enc->qual[m_enc->l_cnt].l_qual_cnt = (m_enc->qual[m_enc->l_cnt].l_qual_cnt+ 1)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM problem pr,
   nomenclature n,
   encounter e,
   person p,
   encntr_loc_hist elh
  PLAN (pr
   WHERE pr.updt_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND pr.active_ind=1
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE n.nomenclature_id=pr.nomenclature_id
    AND n.source_vocabulary_cd=mf_cs400_snomedct_cd
    AND n.source_identifier IN ("26988014", "32441014", "83208016", "307815016"))
   JOIN (e
   WHERE e.person_id=pr.person_id
    AND e.active_ind=1
    AND  NOT (expand(ml_idx1,1,m_enc->l_cnt,e.encntr_id,m_enc->qual[ml_idx1].f_encntr_id))
    AND e.reg_dt_tm IS NOT null
    AND e.disch_dt_tm = null
    AND e.loc_facility_cd != mf_cs220_mock_cd)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND expand(ml_idx3,1,nurs_loc->l_mom_cnt,elh.loc_nurse_unit_cd,nurs_loc->mom_unit[ml_idx3].
    f_code_value))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_enc->l_cnt = (m_enc->l_cnt+ 1), stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->
   l_cnt].f_encntr_id = e.encntr_id,
   m_enc->qual[m_enc->l_cnt].f_person_id = e.person_id, m_enc->qual[m_enc->l_cnt].f_decease_date =
   cnvtdatetime(p.deceased_dt_tm)
   IF ((m_enc->qual[m_enc->l_cnt].f_decease_date > 0.0))
    m_enc->qual[m_enc->l_cnt].l_qual_cnt = (m_enc->qual[m_enc->l_cnt].l_qual_cnt+ 1)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_loc_hist elh
  PLAN (e
   WHERE expand(ml_idx1,1,m_enc->l_cnt,e.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
    AND e.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND expand(ml_idx2,1,nurs_loc->l_icu_cnt,elh.loc_nurse_unit_cd,nurs_loc->icu_unit[ml_idx2].
    f_code_value))
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,e.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
   IF (ml_idx2 > 0)
    IF ((m_enc->qual[ml_idx2].n_icu_ind=0))
     m_enc->qual[ml_idx2].n_icu_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[ml_idx2].
     l_qual_cnt+ 1)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM problem p,
   nomenclature n
  PLAN (p
   WHERE expand(ml_idx1,1,m_enc->l_cnt,p.person_id,m_enc->qual[ml_idx1].f_person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id
    AND n.source_vocabulary_cd=mf_cs400_snomedct_cd
    AND n.source_identifier IN ("26988014", "32441014", "83208016", "307815016"))
  ORDER BY p.person_id, p.problem_id
  HEAD p.person_id
   null
  HEAD p.problem_id
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,p.person_id,m_enc->qual[ml_idx1].f_person_id)
   WHILE (ml_idx2 > 0)
    IF (n.source_identifier="26988014")
     IF ((m_enc->qual[ml_idx2].n_eclampsia_ind=0))
      m_enc->qual[ml_idx2].n_eclampsia_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
      ml_idx2].l_qual_cnt+ 1)
     ENDIF
    ELSEIF (n.source_identifier="32441014")
     IF ((m_enc->qual[ml_idx2].n_pulmedema_ind=0))
      m_enc->qual[ml_idx2].n_pulmedema_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
      ml_idx2].l_qual_cnt+ 1)
     ENDIF
    ELSEIF (n.source_identifier IN ("83208016", "307815016"))
     IF ((m_enc->qual[ml_idx2].n_dvtpe_ind=0))
      m_enc->qual[ml_idx2].n_dvtpe_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[ml_idx2].
      l_qual_cnt+ 1)
     ENDIF
    ENDIF
    ,ml_idx2 = locateval(ml_idx1,(ml_idx2+ 1),m_enc->l_cnt,p.person_id,m_enc->qual[ml_idx1].
     f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE expand(ml_idx1,1,m_enc->l_cnt,o.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
    AND o.catalog_cd IN (mf_cs200_cefazolin_cd, mf_cs200_clindamycin_cd, mf_cs200_vancomycin_cd,
   mf_cs200_penicillingpotassium_cd)
    AND o.order_status_cd IN (mf_cs6004_completed_cd, mf_cs6004_ordered_cd, mf_cs6004_inprocess_cd)
    AND o.active_ind=1)
  ORDER BY o.encntr_id
  HEAD o.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,o.encntr_id,m_enc->qual[ml_idx1].f_encntr_id), m_enc->
   qual[ml_idx2].n_antibiotic_order = 1
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_catalog oc
  PLAN (o
   WHERE expand(ml_idx1,1,m_enc->l_cnt,o.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
    AND o.order_status_cd IN (mf_cs6004_completed_cd, mf_cs6004_ordered_cd, mf_cs6004_inprocess_cd)
    AND o.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd
    AND oc.catalog_type_cd=mf_cs6000_surgery_cd
    AND  NOT (oc.primary_mnemonic IN ("Cesarean Section", "Cesarean with Tubal Ligation"))
    AND oc.active_ind=1)
  ORDER BY o.encntr_id, o.catalog_cd
  HEAD o.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,o.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
  HEAD o.catalog_cd
   IF (oc.primary_mnemonic="Hysterectomy Total Abdominal")
    IF ((m_enc->qual[ml_idx2].n_hysterectomy_ind=0))
     m_enc->qual[ml_idx2].n_hysterectomy_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
     ml_idx2].l_qual_cnt+ 1)
    ENDIF
   ENDIF
   IF ((m_enc->qual[ml_idx2].n_surg_proc_ind=0))
    m_enc->qual[ml_idx2].n_surg_proc_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[ml_idx2]
    .l_qual_cnt+ 1)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_coded_result ccr,
   nomenclature n
  PLAN (ce
   WHERE expand(ml_idx1,1,m_enc->l_cnt,ce.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_auth_cd, mf_cs8_altered_cd,
   mf_cs8_modified_cd)
    AND ce.event_cd IN (mf_cs72_deliverycomplications_cd, mf_cs72_bloodproducttransfused_cd,
   mf_cs72_bloodloss_cd, mf_cs72_groupbstreptrans_cd, mf_cs72_csectionpriority_cd,
   mf_cs72_fetalcomplications1_cd, mf_cs72_fetalcomplications2_cd, mf_cs72_operativedelivery_cd,
   mf_cs72_reasonforcsection_cd, mf_cs72_fetalposition1_cd,
   mf_cs72_fetalposition2_cd, mf_cs72_neonateoutcome_cd, mf_cs72_neonatecomplications1_cd,
   mf_cs72_neonatecomplications2_cd, mf_cs72_transferredto1_cd,
   mf_cs72_apgarscore5minute_cd, mf_cs72_pharterial_cd, mf_cs72_nicuteamcalled_cd,
   mf_cs72_nicuteamcalled2_cd, mf_cs72_maternitycomplications_cd,
   mf_cs72_magnesium_cd, mf_cs72_magnesiumplasma_cd, mf_cs72_magnesiumrbc_cd,
   mf_cs72_egaatdocumenteddatetime_cd, mf_cs72_transferredto2_cd,
   mf_cs72_ph_cd, mf_cs72_deliverytype_cd, mf_cs72_birthcomplications1_cd,
   mf_cs72_birthcomplications2_cd))
   JOIN (ccr
   WHERE ccr.event_id=outerjoin(ce.event_id)
    AND ccr.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(ccr.nomenclature_id))
  ORDER BY ce.encntr_id, ce.event_cd, ce.performed_dt_tm DESC
  HEAD ce.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,ce.encntr_id,m_enc->qual[ml_idx1].f_encntr_id),
   ml_transfuse_cnt = 0
  HEAD ce.event_cd
   ml_idx3 = locateval(ml_idx1,1,m_enc->qual[ml_idx2].l_evcnt,ce.event_cd,m_enc->qual[ml_idx2].
    event_qual[ml_idx1].f_event_cd)
   IF (ce.event_cd=mf_cs72_deliverytype_cd)
    IF (trim(n.source_string,3) IN ("Vaginal", "Vaginal, forcep and vacuum", "Vaginal, forcep assist",
    "Vaginal, vacuum assist"))
     m_enc->qual[ml_idx2].n_vag_del = 1
    ENDIF
   ENDIF
  DETAIL
   IF (ml_idx3 > 0)
    IF (ce.event_cd=mf_cs72_deliverycomplications_cd)
     IF (trim(n.source_string,3)="Uterine rupture")
      IF ((m_enc->qual[ml_idx2].n_uterine_rupture_ind=0))
       m_enc->qual[ml_idx2].n_uterine_rupture_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->
       qual[ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
     IF (trim(n.source_string,3)="Suspected Intraamniotic infection")
      IF ((m_enc->qual[ml_idx2].n_inraamniotic_infection_ind=0))
       m_enc->qual[ml_idx2].n_inraamniotic_infection_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (
       m_enc->qual[ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
     IF (trim(n.source_string,3)="Cardiac arrest")
      IF ((m_enc->qual[ml_idx2].n_code_blue_ind=0))
       m_enc->qual[ml_idx2].n_code_blue_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
       ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd=mf_cs72_bloodproducttransfused_cd)
     IF (trim(n.source_string,3)="Red Blood Cells")
      ml_transfuse_cnt = (ml_transfuse_cnt+ 1)
      IF ((m_enc->qual[ml_idx2].n_transfusion_4_unit_ind=0)
       AND ml_transfuse_cnt > 3)
       m_enc->qual[ml_idx2].n_transfusion_4_unit_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->
       qual[ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd=mf_cs72_bloodloss_cd)
     IF (isnumeric(ce.result_val) > 0)
      IF (cnvtreal(ce.result_val) > 1000.0)
       IF ((m_enc->qual[ml_idx2].n_postpartum_hemorrhage_ind=0))
        m_enc->qual[ml_idx2].n_postpartum_hemorrhage_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (
        m_enc->qual[ml_idx2].l_qual_cnt+ 1)
       ENDIF
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd=mf_cs72_groupbstreptrans_cd)
     IF (trim(cnvtupper(ce.result_val),3)="POSITIVE")
      IF ((m_enc->qual[ml_idx2].n_antibiotic_prophylaxis_ind=0)
       AND (m_enc->qual[ml_idx2].n_antibiotic_order=0))
       m_enc->qual[ml_idx2].n_antibiotic_prophylaxis_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (
       m_enc->qual[ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd=mf_cs72_csectionpriority_cd)
     IF (trim(n.source_string,3)="Code White")
      IF ((m_enc->qual[ml_idx2].n_csec_code_white_ind=0))
       m_enc->qual[ml_idx2].n_csec_code_white_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->
       qual[ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd IN (mf_cs72_fetalcomplications2_cd, mf_cs72_fetalcomplications1_cd,
    mf_cs72_birthcomplications1_cd, mf_cs72_birthcomplications2_cd))
     IF (trim(n.source_string,3)="Shoulder Dystocia")
      IF ((m_enc->qual[ml_idx2].n_shoulder_dystocia_ind=0))
       m_enc->qual[ml_idx2].n_shoulder_dystocia_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->
       qual[ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd=mf_cs72_operativedelivery_cd)
     IF (trim(n.source_string,3)="Forceps")
      IF ((m_enc->qual[ml_idx2].n_forcep_delivery_ind=0))
       m_enc->qual[ml_idx2].n_forcep_delivery_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->
       qual[ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
     IF (trim(n.source_string,3)="Vacuum")
      IF ((m_enc->qual[ml_idx2].n_vacuum_deliver_ind=0))
       m_enc->qual[ml_idx2].n_vacuum_deliver_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
       ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd=mf_cs72_reasonforcsection_cd)
     IF (trim(n.source_string,3)="Failed TOLAC")
      IF ((m_enc->qual[ml_idx2].n_failed_tolac_ind=0))
       m_enc->qual[ml_idx2].n_failed_tolac_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
       ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd IN (mf_cs72_fetalposition1_cd, mf_cs72_fetalposition2_cd))
     IF (trim(n.source_string,3) IN ("Sacrum anterior", "Left sacrum anterior",
     "Right sacrum anterior", "Sacrum posterior", "Left sacrum posterior",
     "Right sacrum posterior", "Left sacrum transverse", "Right sacrum transverse"))
      IF ((m_enc->qual[ml_idx2].n_singleton_ind=0))
       m_enc->qual[ml_idx2].n_singleton_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
       ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd=mf_cs72_neonateoutcome_cd)
     IF (trim(n.source_string,3)="Neonatal death")
      IF ((m_enc->qual[ml_idx2].n_neonatal_death_ind=0))
       m_enc->qual[ml_idx2].n_neonatal_death_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
       ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd IN (mf_cs72_neonatecomplications1_cd, mf_cs72_neonatecomplications2_cd))
     IF (trim(n.source_string,3) IN ("Abrasion", "Bruising", "Cephalohematoma",
     "Deformity, suspected"))
      IF ((m_enc->qual[ml_idx2].n_traumatic_birth_ind=0))
       m_enc->qual[ml_idx2].n_traumatic_birth_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->
       qual[ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd IN (mf_cs72_transferredto1_cd, mf_cs72_transferredto2_cd))
     IF (trim(n.source_string,3)="NICU")
      IF ((m_enc->qual[ml_idx2].n_unexpected_nicu_ind=0))
       m_enc->qual[ml_idx2].n_unexpected_nicu_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->
       qual[ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd=mf_cs72_apgarscore5minute_cd)
     IF (isnumeric(ce.result_val) > 0)
      IF (cnvtreal(ce.result_val) < 7.0)
       IF ((m_enc->qual[ml_idx2].n_term_apgar_ind=0))
        m_enc->qual[ml_idx2].n_term_apgar_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
        ml_idx2].l_qual_cnt+ 1)
       ENDIF
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd IN (mf_cs72_pharterial_cd, mf_cs72_ph_cd))
     IF (isnumeric(ce.result_val) > 0)
      IF (cnvtreal(ce.result_val) < 7.0)
       IF ((m_enc->qual[ml_idx2].n_cord_ph_ind=0))
        m_enc->qual[ml_idx2].n_cord_ph_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
        ml_idx2].l_qual_cnt+ 1)
       ENDIF
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd IN (mf_cs72_nicuteamcalled2_cd, mf_cs72_nicuteamcalled_cd))
     IF (trim(n.source_string,3)="Code C")
      IF ((m_enc->qual[ml_idx2].n_nicu_code_c_ind=0))
       m_enc->qual[ml_idx2].n_nicu_code_c_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
       ml_idx2].l_qual_cnt+ 1)
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd IN (mf_cs72_magnesium_cd, mf_cs72_magnesiumplasma_cd, mf_cs72_magnesiumrbc_cd
    ))
     IF (isnumeric(ce.result_val) > 0)
      IF (cnvtreal(ce.result_val) > 10.1)
       IF ((m_enc->qual[ml_idx2].n_magnesium_tox_ind=0))
        m_enc->qual[ml_idx2].n_magnesium_tox_ind = 1, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
        ml_idx2].l_qual_cnt+ 1)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (ce.event_cd=mf_cs72_egaatdocumenteddatetime_cd)
    IF (size(m_enc->qual[ml_idx2].s_gest_age)=0)
     m_enc->qual[ml_idx2].s_gest_age = trim(ce.result_val,3), m_enc->qual[ml_idx2].s_delivery_ega =
     substring(1,2,trim(ce.result_val,3))
    ENDIF
   ENDIF
  FOOT  ce.encntr_id
   IF ((m_enc->qual[ml_idx2].n_unexpected_nicu_ind=1))
    IF (isnumeric(m_enc->qual[ml_idx2].s_delivery_ega) > 0)
     IF (cnvtint(m_enc->qual[ml_idx2].s_delivery_ega) < 37)
      m_enc->qual[ml_idx2].n_unexpected_nicu_ind = 0, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
      ml_idx2].l_qual_cnt - 1)
     ENDIF
    ENDIF
   ENDIF
   IF ((m_enc->qual[ml_idx2].n_term_apgar_ind=1))
    IF (isnumeric(m_enc->qual[ml_idx2].s_delivery_ega) > 0)
     IF (cnvtint(m_enc->qual[ml_idx2].s_delivery_ega) < 37)
      m_enc->qual[ml_idx2].n_term_apgar_ind = 0, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[
      ml_idx2].l_qual_cnt - 1)
     ENDIF
    ENDIF
   ENDIF
   IF ((m_enc->qual[ml_idx2].n_antibiotic_prophylaxis_ind=1)
    AND (m_enc->qual[ml_idx2].n_vag_del != 1))
    m_enc->qual[ml_idx2].n_antibiotic_prophylaxis_ind = 0, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->
    qual[ml_idx2].l_qual_cnt - 1)
   ENDIF
   IF ((m_enc->qual[ml_idx2].n_singleton_ind=1)
    AND (m_enc->qual[ml_idx2].n_vag_del != 1))
    m_enc->qual[ml_idx2].n_singleton_ind = 0, m_enc->qual[ml_idx2].l_qual_cnt = (m_enc->qual[ml_idx2]
    .l_qual_cnt - 1)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = m_enc->l_cnt),
   encounter e,
   person p,
   encntr_alias ea
  PLAN (d1)
   JOIN (e
   WHERE (e.encntr_id=m_enc->qual[d1.seq].f_encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea.encntr_alias_type_cd=outerjoin(mf_cs319_mrn_cd))
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_enc->qual[d1.seq].s_pat_name = trim(p.name_full_formatted), m_enc->qual[d1.seq].s_pat_mrn = trim
   (ea.alias,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = m_enc->l_cnt),
   clinical_event ce,
   ce_dynamic_label cd1,
   ce_date_result cdr
  PLAN (d1)
   JOIN (ce
   WHERE (ce.encntr_id=m_enc->qual[d1.seq].f_encntr_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_auth_cd, mf_cs8_altered_cd,
   mf_cs8_modified_cd)
    AND ce.event_cd IN (mf_cs72_birthweight_cd, mf_cs72_apgarscore1minute_cd,
   mf_cs72_apgarscore5minute_cd, mf_cs72_neonateoutcome_cd, mf_cs72_deliveryphysician_cd,
   mf_cs72_deliverycnm_cd, mf_cs72_deliverytype_cd, mf_cs72_datetimeofbirth_cd,
   mf_cs72_attendingprovider_cd))
   JOIN (cd1
   WHERE cd1.ce_dynamic_label_id=ce.ce_dynamic_label_id
    AND cd1.label_status_cd IN (mf_cs4002015_inactive_cd, mf_cs4002015_active_cd))
   JOIN (cdr
   WHERE cdr.event_id=outerjoin(ce.event_id)
    AND cdr.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY ce.encntr_id, cd1.ce_dynamic_label_id, ce.event_cd,
   ce.clinical_event_id DESC
  HEAD ce.encntr_id
   m_enc->qual[d1.seq].l_dyn_cnt = 0
  HEAD cd1.ce_dynamic_label_id
   m_enc->qual[d1.seq].l_dyn_cnt = (m_enc->qual[d1.seq].l_dyn_cnt+ 1), stat = alterlist(m_enc->qual[
    d1.seq].dyn_grp,m_enc->qual[d1.seq].l_dyn_cnt), m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].
   l_dyn_cnt].f_dyn_grp_id = cd1.ce_dynamic_label_id,
   m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_dyn_grp_label = trim(cd1.label_name,3
    )
  HEAD ce.event_cd
   IF (ce.event_cd=mf_cs72_birthweight_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_birth_weight = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_cs72_apgarscore1minute_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_apgar_1min = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_cs72_apgarscore5minute_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_apgar_5min = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_cs72_neonateoutcome_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_neonate_outcome = trim(ce.result_val,
     3)
   ELSEIF (ce.event_cd=mf_cs72_deliveryphysician_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_del_provider = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_cs72_deliverycnm_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_del_cnm = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_cs72_deliverytype_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_del_type = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_cs72_datetimeofbirth_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_birth_dt = trim(format(cdr
      .result_dt_tm,";;q"),3)
   ELSEIF (ce.event_cd=mf_cs72_attendingprovider_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_attend_provider = trim(ce.result_val,
     3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case sc,
   surg_case_procedure scp,
   prsnl p
  PLAN (sc
   WHERE expand(ml_idx1,1,m_enc->l_cnt,sc.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
    AND sc.active_ind=1)
   JOIN (scp
   WHERE scp.surg_case_id=sc.surg_case_id
    AND scp.active_ind=1
    AND scp.primary_surgeon_id != 0.0)
   JOIN (p
   WHERE p.person_id=scp.primary_surgeon_id)
  ORDER BY sc.encntr_id, scp.primary_proc_ind
  HEAD sc.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,sc.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
  DETAIL
   IF (ml_idx2 > 0)
    IF (size(trim(m_enc->qual[ml_idx2].s_prim_surgeon,3))=0)
     m_enc->qual[ml_idx2].s_prim_surgeon = trim(p.name_full_formatted,3)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx1 = 1 TO m_enc->l_cnt)
   IF ((m_enc->qual[ml_idx1].f_decease_date > 0.0))
    SET m_enc->qual[ml_idx1].s_qual_str = "Maternal Death"
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_uterine_rupture_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"Uterine Rupture")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_icu_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"ICU admission")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_surg_proc_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"Return to OR")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_transfusion_4_unit_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,
     "Transfusion of >4 units")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_hysterectomy_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"Hysterectomy")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_postpartum_hemorrhage_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,
     "Postpartum Hemorrhage >1000")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_eclampsia_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"Eclampsia")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_pulmedema_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"Pulmonary Edema")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_dvtpe_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"DVT/PE")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_magnesium_tox_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"Magnesium Toxicity"
     )
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_antibiotic_prophylaxis_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,
     "Failure to give antibiotic prophylaxis")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_code_blue_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"Code Blue")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_inraamniotic_infection_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,
     "Intraamniotic infection")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_csec_code_white_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,
     "Code White with c-section delivery")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_shoulder_dystocia_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"Shoulder Dystocia")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_forcep_delivery_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"Forcep Delivery")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_vacuum_deliver_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"Vacuum Delivery")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_failed_tolac_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"Failed TOLAC")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_singleton_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,
     "Breech vaginal singleton delivery")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_neonatal_death_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,
     "Intrapartum or neonatal death ")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_traumatic_birth_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,
     "Traumatic birth injury")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_unexpected_nicu_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,
     "Unexpected NICU admission >24 hours")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_term_apgar_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,
     "Term apgar <7 at 5 minutes")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_cord_ph_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str," pH <7.0")
   ENDIF
   IF ((m_enc->qual[ml_idx1].n_nicu_code_c_ind=1))
    IF (size(m_enc->qual[ml_idx1].s_qual_str) > 0)
     SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,", ")
    ENDIF
    SET m_enc->qual[ml_idx1].s_qual_str = concat(m_enc->qual[ml_idx1].s_qual_str,"NICU code C")
   ENDIF
 ENDFOR
 IF (ms_outdev="OPS")
  SET frec->file_name = concat("bhs_rpt_adverse_events_",format(sysdate,"MMDDYYYY;;q"),".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"Qual Condition",','"Patient Name",','"MRN",','"Delivering Provider",',
   '"Attending Provider",',
   '"Date,Time of Birth",','"Gestational Age",','"Birth Weight",','"1 min apgar",','"5 min apgar",',
   '"Infant Disposition",','"Type of Delivery"',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO m_enc->l_cnt)
    IF ((m_enc->qual[ml_idx1].l_dyn_cnt > 0)
     AND (m_enc->qual[ml_idx1].l_qual_cnt > 0))
     FOR (ml_idx2 = 1 TO m_enc->qual[ml_idx1].l_dyn_cnt)
       SET frec->file_buf = build('"',trim(m_enc->qual[ml_idx1].s_qual_str,3),'","',m_enc->qual[
        ml_idx1].s_pat_name,'","',
        m_enc->qual[ml_idx1].s_pat_mrn)
       IF (size(m_enc->qual[ml_idx1].dyn_grp[ml_idx2].s_del_provider) > 0)
        SET frec->file_buf = build(frec->file_buf,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].
         s_del_provider)
       ELSEIF (size(m_enc->qual[ml_idx1].dyn_grp[ml_idx2].s_del_cnm) > 0)
        SET frec->file_buf = build(frec->file_buf,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].
         s_del_cnm)
       ELSE
        SET frec->file_buf = build(frec->file_buf,'","',m_enc->qual[ml_idx1].s_prim_surgeon)
       ENDIF
       SET frec->file_buf = build(frec->file_buf,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].
        s_attend_provider,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].s_birth_dt,
        '","',m_enc->qual[ml_idx1].s_gest_age,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].
        s_birth_weight,'","',
        m_enc->qual[ml_idx1].dyn_grp[ml_idx2].s_apgar_1min,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2
        ].s_apgar_5min,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].s_neonate_outcome,
        '","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].s_del_type,'"',char(13))
       SET stat = cclio("WRITE",frec)
     ENDFOR
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  DECLARE ms_tmp = vc WITH protect, noconstant("")
  DECLARE ms_email = vc WITH protect, constant("angelce.lazovski@bhs.org")
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("Adverse Events Report: ",format(cnvtdatetime(curdate,curtime3),
    "YYYYMMDDHHMMSS;;q"))
  CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
 ELSE
  SELECT INTO  $OUTDEV
   encntr_id = m_enc->qual[d1.seq].f_encntr_id, qualifying_condition = trim(substring(1,1000,m_enc->
     qual[d1.seq].s_qual_str)), patient_name = trim(substring(1,50,m_enc->qual[d1.seq].s_pat_name)),
   mrn = trim(substring(1,15,m_enc->qual[d1.seq].s_pat_mrn)), delivering_provider =
   IF (size(m_enc->qual[d1.seq].dyn_grp[d2.seq].s_del_provider) > 0) trim(substring(1,50,m_enc->qual[
      d1.seq].dyn_grp[d2.seq].s_del_provider))
   ELSEIF (size(m_enc->qual[d1.seq].dyn_grp[d2.seq].s_del_cnm) > 0) trim(substring(1,50,m_enc->qual[
      d1.seq].dyn_grp[d2.seq].s_del_cnm))
   ELSE trim(substring(1,50,m_enc->qual[d1.seq].s_prim_surgeon))
   ENDIF
   , attending_provider = trim(substring(1,50,m_enc->qual[d1.seq].dyn_grp[d2.seq].s_attend_provider)),
   birth_date = trim(substring(1,20,m_enc->qual[d1.seq].dyn_grp[d2.seq].s_birth_dt)), gestational_age
    = trim(substring(1,15,m_enc->qual[d1.seq].s_gest_age)), birth_weigth = trim(substring(1,10,m_enc
     ->qual[d1.seq].dyn_grp[d2.seq].s_birth_weight)),
   1_min_apgar = trim(substring(1,10,m_enc->qual[d1.seq].dyn_grp[d2.seq].s_apgar_1min)), 5_min_apgar
    = trim(substring(1,10,m_enc->qual[d1.seq].dyn_grp[d2.seq].s_apgar_5min)), infant_disposition =
   trim(substring(1,50,m_enc->qual[d1.seq].dyn_grp[d2.seq].s_neonate_outcome)),
   type_of_delivery = trim(substring(1,50,m_enc->qual[d1.seq].dyn_grp[d2.seq].s_del_type))
   FROM (dummyt d1  WITH seq = m_enc->l_cnt),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,m_enc->qual[d1.seq].l_dyn_cnt)
     AND (m_enc->qual[d1.seq].l_qual_cnt > 0)
     AND (m_enc->qual[d1.seq].l_dyn_cnt > 0))
    JOIN (d2)
   ORDER BY patient_name
   WITH nocounter, maxcol = 20000, format,
    separator = " "
  ;end select
 ENDIF
 CALL echorecord(m_enc)
#exit_script
END GO
