CREATE PROGRAM bhs_rpt_pcm_induction_report:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Facility:" = 999999,
  "Email" = ""
  WITH outdev, ms_start_date, ms_end_date,
  mf_facility_cd, s_email
 DECLARE mf_cs72_deliverytype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Delivery Type:"))
 DECLARE mf_cs72_laboronsetmethods_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "LABORONSETMETHODS"))
 DECLARE mf_cs72_inductionmethods_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INDUCTIONMETHODS"))
 DECLARE mf_cs72_transferredto1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Transferred To:"))
 DECLARE mf_cs72_transferredto2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Transferred To"))
 DECLARE mf_cs72_electiveinduction_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ELECTIVEINDUCTION"))
 DECLARE mf_cs72_maternalconditions_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MATERNALCONDITIONS"))
 DECLARE mf_cs72_reasonforinduction_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REASONFORINDUCTION"))
 DECLARE mf_cs72_egaatdocumenteddatetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",
   72,"EGAATDOCUMENTEDDATETIME"))
 DECLARE mf_cs72methodofinduction = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "METHODOFINDUCTION")), protect
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs16769_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "COMPLETED"))
 DECLARE mf_cs16769_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"ORDERED")
  )
 DECLARE mf_cs16769_started_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"STARTED")
  )
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE mf_beg_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE ms_outdev = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ml_ops_ind = i4 WITH protect, noconstant(0)
 FREE RECORD frec
 RECORD frec(
   1 file_desc = w8
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
   1 l_tot_induced_all = i4
   1 l_tot_induced_cfi = i4
   1 l_tot_induced_cfo = i4
   1 l_tot_induced_miso = i4
   1 l_tot_induced_pito = i4
   1 l_tot_induced_cerv = i4
   1 l_tot_induced_amniot = i4
   1 l_tot_matcond_lateterm = i4
   1 l_tot_matcond_oligohy = i4
   1 l_tot_matcond_polyhy = i4
   1 l_tot_matcond_gestdiab_a1 = i4
   1 l_tot_matcond_gestdiab_a2 = i4
   1 l_tot_matcond_prediab = i4
   1 l_tot_matcond_twingest = i4
   1 l_tot_matcond_intrgrowrest = i4
   1 l_tot_in_vitro_fertilization = i4
   1 l_tot_matcond_gesthyper = i4
   1 l_tot_matcond_chronichyper = i4
   1 l_tot_matcond_preeclamp = i4
   1 l_tot_matcond_preeclampsevfeat = i4
   1 l_tot_matcond_prom = i4
   1 l_tot_matcond_prom34week = i4
   1 l_tot_matcond_cholestasis = i4
   1 l_tot_matcond_other = i4
   1 l_tot_matcond_elective = i4
   1 l_tot_matcond_nonreas = i4
   1 l_tot_dtype_all = i4
   1 l_tot_dtype_vag = i4
   1 l_tot_dtype_csec = i4
   1 l_tot_neodisp_wellnewnurs = i4
   1 l_tot_neodisp_nicu = i4
   1 l_tot_neodisp_specialnurs = i4
   1 l_tot_neodisp_withmother = i4
   1 l_tot_neodisp_other = i4
   1 l_tot_abruption = i4
   1 l_tot_advanced_maternal_age40 = i4
   1 l_tot_anticoagulation = i4
   1 l_tot_antiphospholipid_syn = i4
   1 l_tot_chorioamnionitis = i4
   1 l_tot_elective = i4
   1 l_tot_fetal_demise_iufd = i4
   1 l_tot_isoimmunization_alloimmunization = i4
   1 l_tot_late_term = i4
   1 l_tot_maternal_cardiac_disease = i4
   1 l_tot_maternal_fetal_medicine_recommendation = i4
   1 l_tot_maternal_pulmonary_disease = i4
   1 l_tot_maternal_renal_disease = i4
   1 l_tot_postpart_care_wfamily = i4
   1 l_tot_ccn = i4
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_delivery_type = vc
     2 s_method_of_induction = vc
     2 s_gestational_age = vc
     2 s_indication_for_induction = vc
     2 s_neonate_disposition = vc
     2 s_pat_name = vc
     2 s_pat_mrn = vc
     2 s_fin = vc
     2 l_induced_all = i4
     2 l_induced_cfi = i4
     2 l_induced_cfo = i4
     2 l_induced_miso = i4
     2 l_induced_pito = i4
     2 l_induced_cerv = i4
     2 l_induced_amnio = i4
     2 l_matcond_lateterm = i4
     2 l_matcond_oligohy = i4
     2 l_matcond_polyhy = i4
     2 l_matcond_gestdiab_a1 = i4
     2 l_matcond_gestdiab_a2 = i4
     2 l_matcond_prediab = i4
     2 l_matcond_twingest = i4
     2 l_matcond_intrgrowrest = i4
     2 l_in_vitro_fertilization = i4
     2 l_matcond_gesthyper = i4
     2 l_matcond_chronichyper = i4
     2 l_matcond_preeclamp = i4
     2 l_matcond_preeclampsevfeat = i4
     2 l_matcond_prom = i4
     2 l_matcond_prom34week = i4
     2 l_matcond_cholestasis = i4
     2 l_matcond_other = i4
     2 l_matcond_elective = i4
     2 l_matcond_elective39 = i4
     2 l_matcond_nonreas = i4
     2 l_dtype_all = i4
     2 l_dtype_vag = i4
     2 l_dtype_csec = i4
     2 l_neodisp_wellnewnurs = i4
     2 l_neodisp_nicu = i4
     2 l_neodisp_specialnurs = i4
     2 l_neodisp_withmother = i4
     2 l_neodisp_other = i4
     2 l_abruption = i4
     2 l_advanced_maternal_age40 = i4
     2 l_anticoagulation = i4
     2 l_antiphospholipid_syn = i4
     2 l_chorioamnionitis = i4
     2 l_elective = i4
     2 l_fetal_demise_iufd = i4
     2 l_isoimmunization_alloimmunization = i4
     2 l_late_term = i4
     2 l_maternal_cardiac_disease = i4
     2 l_maternal_fetal_medicine_recommendation = i4
     2 l_maternal_pulmonary_disease = i4
     2 l_maternal_renal_disease = i4
     2 l_postpart_care_area_family = i4
     2 l_ccn = i4
     2 l_output_ind = i4
 ) WITH protect
 IF (( $MF_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
 ELSE
  SET ms_facility_p = build("nu.loc_facility_cd = ", $MF_FACILITY_CD)
 ENDIF
 IF (ms_outdev="OPS")
  SET ml_ops_ind = 1
  SET mf_end_dt_tm = datetimefind(cnvtdatetime(curdate,0),"M","B","B")
  SET mf_beg_dt_tm = cnvtlookbehind("1 M",cnvtdatetime(mf_end_dt_tm))
 ELSE
  SET mf_beg_dt_tm = cnvtdatetime(cnvtdate2( $MS_START_DATE,"DD-MMM-YYYY"),0)
  SET mf_end_dt_tm = cnvtdatetime(cnvtdate2( $MS_END_DATE,"DD-MMM-YYYY"),235959)
 ENDIF
 CALL echo(format(cnvtdatetime(mf_beg_dt_tm),";;q"))
 CALL echo(format(cnvtdatetime(mf_end_dt_tm),";;q"))
 SELECT INTO "nl:"
  FROM code_value cv,
   nurse_unit nu
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key IN ("WIN2", "WETU1", "OBGN", "LDRPA", "LDRPB",
   "LDRPC")
    AND cv.active_ind=1)
   JOIN (nu
   WHERE nu.location_cd=cv.code_value
    AND parser(ms_facility_p))
  HEAD REPORT
   nurs_loc->l_mom_cnt = 0
  DETAIL
   nurs_loc->l_mom_cnt += 1, stat = alterlist(nurs_loc->mom_unit,nurs_loc->l_mom_cnt), nurs_loc->
   mom_unit[nurs_loc->l_mom_cnt].f_code_value = cv.code_value,
   nurs_loc->mom_unit[nurs_loc->l_mom_cnt].s_display = cv.display
  WITH nocounter
 ;end select
 CALL echorecord(nurs_loc)
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_loc_hist elh,
   person p
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND e.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND expand(ml_idx1,1,nurs_loc->l_mom_cnt,elh.loc_nurse_unit_cd,nurs_loc->mom_unit[ml_idx1].
    f_code_value))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
   f_encntr_id = e.encntr_id,
   m_enc->qual[m_enc->l_cnt].f_person_id = e.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_coded_result ccr,
   nomenclature n,
   ce_string_result csr
  PLAN (ce
   WHERE expand(ml_idx1,1,m_enc->l_cnt,ce.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_auth_cd, mf_cs8_altered_cd,
   mf_cs8_modified_cd)
    AND ce.event_cd IN (mf_cs72_deliverytype_cd, mf_cs72_laboronsetmethods_cd,
   mf_cs72_inductionmethods_cd, mf_cs72_transferredto1_cd, mf_cs72_transferredto2_cd,
   mf_cs72_electiveinduction_cd, mf_cs72_maternalconditions_cd, mf_cs72_egaatdocumenteddatetime_cd,
   mf_cs72_reasonforinduction_cd, mf_cs72methodofinduction))
   JOIN (ccr
   WHERE (ccr.event_id= Outerjoin(ce.event_id))
    AND (ccr.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(ccr.nomenclature_id)) )
   JOIN (csr
   WHERE (csr.event_id= Outerjoin(ce.event_id))
    AND (csr.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY ce.encntr_id, ce.event_cd, ce.performed_dt_tm DESC
  HEAD ce.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,ce.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
  HEAD ce.event_cd
   IF (ce.event_cd=mf_cs72_deliverytype_cd)
    m_enc->qual[ml_idx2].s_delivery_type = trim(ce.result_val,3)
   ENDIF
   IF (ce.event_cd=mf_cs72_inductionmethods_cd)
    m_enc->qual[ml_idx2].s_method_of_induction = trim(ce.result_val,3)
   ENDIF
   IF (ce.event_cd IN (mf_cs72_transferredto1_cd, mf_cs72_transferredto2_cd))
    m_enc->qual[ml_idx2].s_neonate_disposition = trim(ce.result_val,3)
   ENDIF
   IF (ce.event_cd=mf_cs72_egaatdocumenteddatetime_cd)
    m_enc->qual[ml_idx2].s_gestational_age = trim(ce.result_val,3)
   ENDIF
  DETAIL
   IF (ce.event_cd=mf_cs72_deliverytype_cd)
    IF (trim(n.source_string,3) IN ("Vaginal", "Vaginal, forcep and vacuum", "Vaginal, forcep assist",
    "Vaginal, vacuum assist", "VBAC",
    "C-section, indicated", "C-Section, classical", "C-Section, low transverse",
    "C-Section, forcep and vacuum", "C-Section, forcep assist",
    "C-Section, J incision", "C-Section, low vertical", "C-Section, other", "C-Section, T incision",
    "C-Section, vacuum assist",
    "Placenta only"))
     IF ((m_enc->qual[ml_idx2].l_dtype_all=0))
      m_enc->qual[ml_idx2].l_dtype_all = 1, m_enc->l_tot_dtype_all += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3) IN ("Vaginal", "Vaginal, forcep and vacuum", "Vaginal, forcep assist",
    "Vaginal, vacuum assist", "VBAC"))
     IF ((m_enc->qual[ml_idx2].l_dtype_vag=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_dtype_vag = 1, m_enc->
      l_tot_dtype_vag += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3) IN ("C-section, indicated", "C-Section, classical",
    "C-Section, low transverse", "C-Section, forcep and vacuum", "C-Section, forcep assist",
    "C-Section, J incision", "C-Section, low vertical", "C-Section, other", "C-Section, T incision",
    "C-Section, vacuum assist"))
     IF ((m_enc->qual[ml_idx2].l_dtype_csec=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_dtype_csec = 1, m_enc->
      l_tot_dtype_csec += 1
     ENDIF
    ENDIF
   ENDIF
   IF (ce.event_cd=mf_cs72_laboronsetmethods_cd)
    IF (trim(n.source_string,3)="Induced")
     IF ((m_enc->qual[ml_idx2].l_induced_all=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_induced_all = 1, m_enc->
      l_tot_induced_all += 1
     ENDIF
    ENDIF
   ENDIF
   IF (ce.event_cd=mf_cs72_inductionmethods_cd)
    IF (trim(n.source_string,3)="Cervical Foley Inpatient")
     IF ((m_enc->qual[ml_idx2].l_induced_cfi=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_induced_cfi = 1, m_enc->
      l_tot_induced_cfi += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Cervical Foley Outpatient")
     IF ((m_enc->qual[ml_idx2].l_induced_cfo=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_induced_cfo = 1, m_enc->
      l_tot_induced_cfo += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Cervidil")
     IF ((m_enc->qual[ml_idx2].l_induced_cerv=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_induced_cerv = 1, m_enc->
      l_tot_induced_cerv += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Misoprostol")
     IF ((m_enc->qual[ml_idx2].l_induced_miso=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_induced_miso = 1, m_enc->
      l_tot_induced_miso += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Pitocin")
     IF ((m_enc->qual[ml_idx2].l_induced_pito=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_induced_pito = 1, m_enc->
      l_tot_induced_pito += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Amniotomy")
     IF ((m_enc->qual[ml_idx2].l_induced_amnio=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_induced_amnio = 1, m_enc->
      l_tot_induced_amniot += 1
     ENDIF
    ENDIF
   ENDIF
   IF (ce.event_cd IN (mf_cs72_transferredto1_cd, mf_cs72_transferredto2_cd))
    IF (trim(n.source_string,3)="NICU")
     IF ((m_enc->qual[ml_idx2].l_neodisp_nicu=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_neodisp_nicu = 1, m_enc->
      l_tot_neodisp_nicu += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Postpartum Care area with Family")
     IF ((m_enc->qual[ml_idx2].l_postpart_care_area_family=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_postpart_care_area_family = 1,
      m_enc->l_tot_postpart_care_wfamily += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="CCN")
     IF ((m_enc->qual[ml_idx2].l_ccn=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_ccn = 1, m_enc->l_tot_ccn += 1
     ENDIF
    ENDIF
    IF (size(trim(csr.string_result_text,3)) > 0)
     IF ((m_enc->qual[ml_idx2].l_neodisp_other=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_neodisp_other = 1, m_enc->
      l_tot_neodisp_other += 1
     ENDIF
    ENDIF
   ENDIF
   IF (ce.event_cd IN (mf_cs72_reasonforinduction_cd))
    m_enc->qual[ml_idx2].s_indication_for_induction = trim(ce.result_val,3)
    IF (trim(n.source_string,3) IN ("Late term >40'6", "Late term"))
     IF ((m_enc->qual[ml_idx2].l_matcond_lateterm=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_lateterm = 1, m_enc->
      l_tot_matcond_lateterm += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Elective >39wks with favorable cervix")
     IF ((m_enc->qual[ml_idx2].l_matcond_elective39=0))
      m_enc->qual[ml_idx2].l_matcond_elective39 = 1, m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->
      l_tot_matcond_elective += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Oligohydramnios")
     IF ((m_enc->qual[ml_idx2].l_matcond_oligohy=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_oligohy = 1, m_enc->
      l_tot_matcond_oligohy += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Polyhydramnios")
     IF ((m_enc->qual[ml_idx2].l_matcond_polyhy=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_polyhy = 1, m_enc->
      l_tot_matcond_polyhy += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Gestational diabetes A1")
     IF ((m_enc->qual[ml_idx2].l_matcond_gestdiab_a1=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_gestdiab_a1 = 1, m_enc->
      l_tot_matcond_gestdiab_a1 += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Gestational diabetes A2")
     IF ((m_enc->qual[ml_idx2].l_matcond_gestdiab_a2=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_gestdiab_a2 = 1, m_enc->
      l_tot_matcond_gestdiab_a2 += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Pre-exsisting Diabetes")
     IF ((m_enc->qual[ml_idx2].l_matcond_prediab=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_prediab = 1, m_enc->
      l_tot_matcond_prediab += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Twin gestation")
     IF ((m_enc->qual[ml_idx2].l_matcond_twingest=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_twingest = 1, m_enc->
      l_tot_matcond_twingest += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3) IN ("Intrauterine growth restriction", "IUGR"))
     IF ((m_enc->qual[ml_idx2].l_matcond_intrgrowrest=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_intrgrowrest = 1, m_enc->
      l_tot_matcond_intrgrowrest += 1
     ENDIF
    ENDIF
    IF (trim(cnvtupper(n.source_string),3) IN ("IN VITRO FERTILIZATION"))
     IF ((m_enc->qual[ml_idx2].l_in_vitro_fertilization=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_in_vitro_fertilization = 1, m_enc
      ->l_tot_in_vitro_fertilization += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Nonreassuring fetal status")
     IF ((m_enc->qual[ml_idx2].l_matcond_nonreas=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_nonreas = 1, m_enc->
      l_tot_matcond_nonreas += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Gestational hypertension")
     IF ((m_enc->qual[ml_idx2].l_matcond_gesthyper=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_gesthyper = 1, m_enc->
      l_tot_matcond_gesthyper += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Chronic hypertension")
     IF ((m_enc->qual[ml_idx2].l_matcond_chronichyper=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_chronichyper = 1, m_enc->
      l_tot_matcond_chronichyper += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Pre-eclampsia")
     IF ((m_enc->qual[ml_idx2].l_matcond_preeclamp=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_preeclamp = 1, m_enc->
      l_tot_matcond_preeclamp += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Pre-eclampsia with severe features")
     IF ((m_enc->qual[ml_idx2].l_matcond_preeclampsevfeat=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_preeclampsevfeat = 1,
      m_enc->l_tot_matcond_preeclampsevfeat += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="PROM")
     IF ((m_enc->qual[ml_idx2].l_matcond_prom=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_prom = 1, m_enc->
      l_tot_matcond_prom += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="PPROM>34 Weeks")
     IF ((m_enc->qual[ml_idx2].l_matcond_prom34week=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_prom34week = 1, m_enc->
      l_tot_matcond_prom34week += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Cholestasis")
     IF ((m_enc->qual[ml_idx2].l_matcond_cholestasis=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_cholestasis = 1, m_enc->
      l_tot_matcond_cholestasis += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Abruption")
     IF ((m_enc->qual[ml_idx2].l_abruption=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_abruption = 1, m_enc->
      l_tot_abruption += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Advanced Maternal Age (age =>35)")
     IF ((m_enc->qual[ml_idx2].l_advanced_maternal_age40=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_advanced_maternal_age40 = 1,
      m_enc->l_tot_advanced_maternal_age40 += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Anticoagulation")
     IF ((m_enc->qual[ml_idx2].l_anticoagulation=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_anticoagulation = 1, m_enc->
      l_tot_anticoagulation += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Antiphospholipid Syndrome")
     IF ((m_enc->qual[ml_idx2].l_antiphospholipid_syn=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_antiphospholipid_syn = 1, m_enc->
      l_tot_antiphospholipid_syn += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Chorioamnionitis")
     IF ((m_enc->qual[ml_idx2].l_chorioamnionitis=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_chorioamnionitis = 1, m_enc->
      l_tot_chorioamnionitis += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Elective")
     IF ((m_enc->qual[ml_idx2].l_elective=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_elective = 1, m_enc->
      l_tot_elective += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Fetal Demise in current pregnancy or history of IUFD")
     IF ((m_enc->qual[ml_idx2].l_fetal_demise_iufd=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_fetal_demise_iufd = 1, m_enc->
      l_tot_fetal_demise_iufd += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Isoimmunization/Alloimmunization")
     IF ((m_enc->qual[ml_idx2].l_isoimmunization_alloimmunization=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_isoimmunization_alloimmunization
       = 1, m_enc->l_tot_isoimmunization_alloimmunization += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Late term")
     IF ((m_enc->qual[ml_idx2].l_late_term=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_late_term = 1, m_enc->
      l_tot_late_term += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Maternal cardiac disease")
     IF ((m_enc->qual[ml_idx2].l_maternal_cardiac_disease=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_maternal_cardiac_disease = 1,
      m_enc->l_tot_maternal_cardiac_disease += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Maternal Fetal Medicine recommendation")
     IF ((m_enc->qual[ml_idx2].l_maternal_fetal_medicine_recommendation=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].
      l_maternal_fetal_medicine_recommendation = 1, m_enc->
      l_tot_maternal_fetal_medicine_recommendation += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Maternal Pulmonary Disease")
     IF ((m_enc->qual[ml_idx2].l_maternal_pulmonary_disease=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_maternal_pulmonary_disease = 1,
      m_enc->l_tot_maternal_pulmonary_disease += 1
     ENDIF
    ENDIF
    IF (trim(n.source_string,3)="Maternal Renal Disease")
     IF ((m_enc->qual[ml_idx2].l_maternal_renal_disease=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_maternal_renal_disease = 1, m_enc
      ->l_tot_maternal_renal_disease += 1
     ENDIF
    ENDIF
    IF (size(trim(csr.string_result_text,3)) > 0)
     IF ((m_enc->qual[ml_idx2].l_matcond_other=0))
      m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->qual[ml_idx2].l_matcond_other = 1, m_enc->
      l_tot_matcond_other += 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 CALL echorecord(m_enc)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = m_enc->l_cnt),
   encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea2
  PLAN (d1)
   JOIN (e
   WHERE (e.encntr_id=m_enc->qual[d1.seq].f_encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_cs319_mrn_cd)) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_cs319_fin_cd)) )
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_enc->qual[d1.seq].s_pat_name = trim(p.name_full_formatted), m_enc->qual[d1.seq].s_pat_mrn = trim
   (ea.alias,3), m_enc->qual[d1.seq].s_fin = trim(ea2.alias,3)
  WITH nocounter
 ;end select
 CALL echorecord(m_enc)
 SET frec->file_name = concat("bhs_rpt_pcm_induction_",format(sysdate,"MMDDYYYY;;q"),".csv")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build('"SUMMARY:"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = concat(char(13),'"% of all deliveries that are inductions",')
 IF ((m_enc->l_tot_dtype_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_induced_all)
     / cnvtreal(m_enc->l_tot_dtype_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = build(char(13),'"Induction Method:"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Cervical Foley Inpatient",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_induced_cfi)
     / cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Cervical Foley Outpatient",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_induced_cfo)
     / cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Misoprostol",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_induced_miso
      )/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Pitocin",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_induced_pito
      )/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Cervidil",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_induced_cerv
      )/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '" Amniotomy",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_induced_amniot)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = build(char(13),'"Reason for Induction:"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Abruption",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_abruption)/
     cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Advanced Maternal Age (age =>35)",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_advanced_maternal_age40)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',
   char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Anticoagulation",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_anticoagulation)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Antiphospholipid Syndrome",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_antiphospholipid_syn)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(
    13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Cholestasis",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_cholestasis)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(
    13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Chorioamnionitis",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_chorioamnionitis)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Chronic hypertension",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_chronichyper)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(
    13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Elective",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_elective)/
     cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Elective >39wks with favorable cervix",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_elective)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Fetal Demise in current pregnancy or history of IUFD",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_fetal_demise_iufd)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13)
   )
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Gestational diabetes A1",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_gestdiab_a1)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(
    13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Gestational diabetes A2",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_gestdiab_a2)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(
    13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Gestational hypertension",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_gesthyper)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13)
   )
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Isoimmunization/Alloimmunization",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_isoimmunization_alloimmunization)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),
   '%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  IUGR",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_intrgrowrest)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(
    13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  In Vitro Fertilization",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
  CALL echo("  In Vitro Fertilization 1")
  CALL echo(frec->file_buf)
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_in_vitro_fertilization)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',
   char(13))
  CALL echo(frec->file_buf)
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Late term",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_lateterm)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Maternal cardiac disease",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_maternal_cardiac_disease)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',
   char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Maternal Fetal Medicine recommendation",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_maternal_fetal_medicine_recommendation)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,
     2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Maternal Pulmonary Disease",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_maternal_pulmonary_disease)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',
   char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Maternal Renal Disease",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_maternal_renal_disease)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',
   char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Nonreassuring fetal status",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_nonreas)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Oligohydramnios",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_oligohy)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Polyhydramnios",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_polyhy)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  PPROM >34 weeks",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_prom34week)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13
    ))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Pre-eclampsia",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_preeclamp)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13)
   )
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Pre-eclampsia with severe features",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_preeclampsevfeat)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',
   char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Pre-existing diabetes",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_prediab)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  PROM",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_matcond_prom
      )/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Twin gestation",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_twingest)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Other",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_matcond_other)/ cnvtreal(m_enc->l_tot_induced_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = build(char(13),'"Mode of Delivery:"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Vaginal Delivery",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_dtype_vag)/
     cnvtreal(m_enc->l_tot_dtype_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  C-section",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_dtype_csec)
     / cnvtreal(m_enc->l_tot_dtype_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = build(char(13),'"Transferred To:"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"   Postpartum Care area with Family",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_postpart_care_wfamily)/ cnvtreal(m_enc->l_tot_dtype_all)) * 100.00),20,2),3),'%"',char(
    13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  CCN",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_ccn)/
     cnvtreal(m_enc->l_tot_dtype_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  NICU",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_neodisp_nicu
      )/ cnvtreal(m_enc->l_tot_dtype_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = '"  Other",'
 IF ((m_enc->l_tot_induced_all=0))
  SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
 ELSE
  SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_neodisp_other)/ cnvtreal(m_enc->l_tot_dtype_all)) * 100.00),20,2),3),'%"',char(13))
 ENDIF
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = build(char(13),'"DETAILS:"',char(13),char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = build('"Patient Name",','"MRN",','"FIN",','"Indication for Induction",',
  '"Gestational Age",',
  '"Method of Induction",','"Delivery Type",','"Neonate Disposition"',char(13))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_enc->l_cnt)
   IF ((m_enc->qual[ml_idx1].l_output_ind > 0))
    SET frec->file_buf = build('"',m_enc->qual[ml_idx1].s_pat_name,'","',m_enc->qual[ml_idx1].
     s_pat_mrn,'","',
     m_enc->qual[ml_idx1].s_fin,'","',m_enc->qual[ml_idx1].s_indication_for_induction,'","',m_enc->
     qual[ml_idx1].s_gestational_age,
     '","',m_enc->qual[ml_idx1].s_method_of_induction,'","',m_enc->qual[ml_idx1].s_delivery_type,
     '","',
     m_enc->qual[ml_idx1].s_neonate_disposition,'"',char(13))
    SET stat = cclio("WRITE",frec)
   ENDIF
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 DECLARE ms_tmp = vc WITH protect, noconstant("")
 DECLARE ms_email = vc WITH protect, constant(trim( $S_EMAIL,3))
 IF (findstring("@",ms_email) > 0)
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("PCM Induction Report: ",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;q"))
  CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
  IF (ms_outdev != "OPS")
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     col 0, "{PS/792 0 translate 90 rotate/}", row + 1,
     "{F/1}{CPI/7}", "Report finished and file was sent to provided e-mail.", row + 2,
     ms_email, row + 2, "Filename:",
     frec->file_name
    WITH dio = 08, mine, time = 5
   ;end select
  ENDIF
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1,
    "{F/1}{CPI/7}", "Invalid e-mail.", row + 2,
    "File saved to backend.", row + 2, frec->file_name
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
 CALL echorecord(m_enc)
#exit_script
END GO
