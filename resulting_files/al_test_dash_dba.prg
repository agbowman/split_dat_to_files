CREATE PROGRAM al_test_dash:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 0,
  "Report Type:" = "1",
  "Flag filter (detail report only):" = "0",
  "Include Inpatient:" = 0
  WITH outdev, f_facility_id, s_rpt_type,
  s_flag_filter, f_inp_flag
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE mf_cs6004_completed_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3100")
  )
 DECLARE mf_cs6004_discontinued_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!3101"))
 DECLARE mf_cs400_icd10cm_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4101498946"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs69_inpatient_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs72_creatininelevel_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Creatinine-Blood"))
 DECLARE mf_cs72_creatininelvl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CREATININESERUM"))
 DECLARE mf_cs72_creatinineclearance_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CREATININECLEARANCE"))
 DECLARE mf_cs72_hemoglobin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HGB"))
 DECLARE mf_cs72_platelets_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PLATELETS"
   ))
 DECLARE mf_cs72_pharanticoagindication_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PHARANTICOAGINDICATION"))
 DECLARE mf_cs72_pharanticoagotherindication_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"PHARANTICOAGOTHERINDICATION"))
 DECLARE mf_cs72_pharanticoagfollowupdate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PHARANTICOAGFOLLOWUPDATE"))
 DECLARE mf_cs72_phardoacreassessrefill_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PHARDOACREASSESSREFILL"))
 DECLARE mf_cs72_phardoacreassesslabmonitoring_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"PHARDOACREASSESSLABMONITORING"))
 DECLARE mf_cs72_phardoacreassesscrmonitoring_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"PHARDOACREASSESSCRMONITORING"))
 DECLARE mf_cs72_phardoacreassesslabfinding_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"PHARDOACREASSESSLABFINDING"))
 DECLARE mf_cs72_phardoacreassessnsaid_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHARDOACREASSESSNSAID"))
 DECLARE mf_cs72_phardoacreassessddi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHARDOACREASSESSDDI"))
 DECLARE mf_cs72_phardoacreassessvalvebari_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"PHARDOACREASSESSVALVEBARI"))
 DECLARE mf_cs72_phardoacreassessdosing_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PHARDOACREASSESSDOSING"))
 DECLARE mf_cs72_aspartatecsflc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ASPARTATECSFLC"))
 DECLARE mf_cs72_aspartateurlc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ASPARTATEURLC"))
 DECLARE mf_cs72_aspartatelc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ASPARTATELC"))
 DECLARE mf_cs72_alaninecsflc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ALANINECSFLC"))
 DECLARE mf_cs72_alanineurlc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ALANINEURLC"))
 DECLARE mf_cs72_alaninelc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ALANINELC"
   ))
 DECLARE mf_cs72_anticoagprogressnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ANTICOAGULATIONPROGRESSNOTE"))
 DECLARE mf_cs72_weightdosing_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "WEIGHTDOSING"))
 DECLARE mf_cs200_dabigatran_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DABIGATRAN"))
 DECLARE mf_cs200_rivaroxaban_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RIVAROXABAN"))
 DECLARE mf_cs200_apixaban_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"APIXABAN"
   ))
 DECLARE mf_cs200_edoxaban_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"EDOXABAN"
   ))
 DECLARE mf_cs200_betrixaban_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "BETRIXABAN"))
 DECLARE mf_cs200_ketoconazole_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "KETOCONAZOLE"))
 DECLARE mf_cs200_dronedarone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DRONEDARONE"))
 DECLARE mf_cs200_verapamil_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "VERAPAMIL"))
 DECLARE mf_cs200_quinidine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "QUINIDINE"))
 DECLARE mf_cs200_azithromycin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "AZITHROMYCIN"))
 DECLARE mf_cs200_clarithromycin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CLARITHROMYCIN"))
 DECLARE mf_cs200_erythromycin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ERYTHROMYCIN"))
 DECLARE mf_cs200_itraconazole_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ITRACONAZOLE"))
 DECLARE mf_cs200_concomitant_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONCOMITANT"))
 DECLARE mf_cs200_ritonavir_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RITONAVIR"))
 DECLARE mf_cs400_icd10_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4101498946"
   ))
 DECLARE mf_cs72_pharoutsidealtdate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHAROUTSIDEALTDATE"))
 DECLARE mf_cs72_pharoutsidealt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHAROUTSIDEALT"))
 DECLARE mf_cs72_pharoutsideastdate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHAROUTSIDEASTDATE"))
 DECLARE mf_cs72_pharoutsideast_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHAROUTSIDEAST"))
 DECLARE mf_cs72_pharoutsidecreatininedate_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"PHAROUTSIDECREATININEDATE"))
 DECLARE mf_cs72_pharoutsidecreatinine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHAROUTSIDECREATININE"))
 DECLARE mf_cs72_pharoutsidepltdate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHAROUTSIDEPLTDATE"))
 DECLARE mf_cs72_pharoutsideplt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHAROUTSIDEPLT"))
 DECLARE mf_cs72_pharoutsidehgbdate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHAROUTSIDEHGBDATE"))
 DECLARE mf_cs72_pharoutsidehgb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHAROUTSIDEHGB"))
 DECLARE ms_dt_format = vc WITH protect, constant("MM/DD/YYYY HH:mm;;q")
 DECLARE ms_dt_format2 = vc WITH protect, constant("MM/DD/YYYY;;q")
 DECLARE ml_event_scr_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_event_crcl_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_event_hbg_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_event_plt_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE ml_nidx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_nidx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_parse_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ms_parse_filter = vc WITH protect, noconstant(" 1 = 1 ")
 FREE RECORD m_meds
 RECORD m_meds(
   1 l_crx_cnt = i4
   1 crx_qual[*]
     2 f_catalog_cd = f8
     2 s_prim_mnemonic = vc
     2 s_catalog_type = vc
   1 l_nsaid_cnt = i4
   1 nsaid_qual[*]
     2 f_catalog_cd = f8
     2 s_prim_mnemonic = vc
     2 s_catalog_type = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_order_id = f8
     2 f_catalog_cd = f8
     2 f_orig_order_dt_tm = f8
     2 s_facility = vc
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_anticoag_indication = vc
     2 s_anticoag_indication_other = vc
     2 s_anticoag_indication_dt = vc
     2 s_anticoag_indication_other_dt = vc
     2 s_med_w_str = vc
     2 s_med_sig = vc
     2 s_med_last_fill_dt = vc
     2 s_med_refil_remain = vc
     2 l_pat_age = i4
     2 l_lab_overdue_ind = i4
     2 l_scr_overdue_ind = i4
     2 l_notable_lab_finding_ind = i4
     2 l_active_nsaid_ind = i4
     2 l_major_ddi_ind = i4
     2 l_major_contra_ind = i4
     2 l_bar_surg_valv_rep_ind = i4
     2 l_bariatric_surg_found = i4
     2 l_valve_replacement_found = i4
     2 l_pe_found = i4
     2 l_afib_found = i4
     2 l_aflut_found = i4
     2 l_dvt_found = i4
     2 f_last_anticoag_form = f8
     2 s_last_anticoag_form_dt = vc
     2 f_next_anticoag_appt_dt = f8
     2 l_dosing_flag_ind = i4
     2 s_dosing_flag_comment = vc
     2 f_scr_result1 = f8
     2 f_scr_result1_dt = f8
     2 s_scr_result1_unit = vc
     2 f_scr_result2 = f8
     2 f_scr_result2_dt = f8
     2 s_scr_result2_unit = vc
     2 f_scr_result3 = f8
     2 f_scr_result3_dt = f8
     2 s_scr_result3_unit = vc
     2 f_crcl_result1 = f8
     2 f_crcl_result1_dt = f8
     2 s_crcl_result1_unit = vc
     2 f_crcl_result2 = f8
     2 f_crcl_result2_dt = f8
     2 s_crcl_result2_unit = vc
     2 f_crcl_result3 = f8
     2 f_crcl_result3_dt = f8
     2 s_crcl_result3_unit = vc
     2 f_hgb_result1 = f8
     2 f_hgb_result1_dt = f8
     2 s_hgb_result1_unit = vc
     2 f_hgb_result2 = f8
     2 f_hgb_result2_dt = f8
     2 s_hgb_result2_unit = vc
     2 f_hgb_result3 = f8
     2 f_hgb_result3_dt = f8
     2 s_hgb_result3_unit = vc
     2 f_plt_result1 = f8
     2 f_plt_result1_dt = f8
     2 s_plt_result1_unit = vc
     2 f_plt_result2 = f8
     2 f_plt_result2_dt = f8
     2 s_plt_result2_unit = vc
     2 f_plt_result3 = f8
     2 f_plt_result3_dt = f8
     2 s_plt_result3_unit = vc
     2 f_ast_result1 = f8
     2 f_ast_result1_dt = f8
     2 s_ast_result1_unit = vc
     2 f_alt_result1 = f8
     2 f_alt_result1_dt = f8
     2 s_alt_result1_unit = vc
     2 l_suppress_refill = i4
     2 l_suppress_lab_overdue = i4
     2 l_suppress_scr_overdue = i4
     2 l_suppress_notable_lab_finding = i4
     2 l_suppress_nsaid_med = i4
     2 l_suppress_major_ddi = i4
     2 l_suppress_bar_surg_valv_rep = i4
     2 l_suppress_dosing_flag = i4
     2 s_suppress_refill_dt = vc
     2 s_suppress_lab_overdue_dt = vc
     2 s_suppress_scr_overdue_dt = vc
     2 s_suppress_notable_lab_finding_dt = vc
     2 s_suppress_nsaid_med_dt = vc
     2 s_suppress_major_ddi_dt = vc
     2 s_suppress_bar_surg_valv_rep_dt = vc
     2 s_suppress_dosing_flag_dt = vc
     2 l_ord_freq_max_per_day = i4
     2 f_ord_daily_dose = f8
     2 f_ord_frequency_id = f8
     2 f_ord_strength = f8
     2 s_ord_strength = vc
     2 s_ord_strength_unit = vc
     2 f_ord_volume_dose = f8
     2 s_ord_volume_dose = vc
     2 s_ord_volume_dose_unit = vc
     2 s_ord_freq = vc
     2 f_ord_disp_qty = f8
     2 s_ord_disp_qty = vc
     2 f_ord_tot_refill = f8
     2 s_ord_tot_refill = vc
     2 s_ord_stop_dt = vc
     2 f_ord_stop_dt = f8
     2 s_ord_disp_unit = vc
     2 s_ord_specinx = vc
     2 s_ord_route = vc
     2 l_ketoconazole_found = i4
     2 l_dronedarone_found = i4
     2 l_verapamil_found = i4
     2 l_quinidine_found = i4
     2 l_azithromycin_found = i4
     2 l_clarithromycin_found = i4
     2 l_erythromycin_found = i4
     2 l_itraconazole_found = i4
     2 l_concomitant_found = i4
     2 l_ritonavir_found = i4
     2 f_weight_dosing = f8
     2 s_weight_dosing = vc
     2 f_weight_dosing_dt = f8
     2 l_rivaroxaban_first_fill_ind = i4
     2 l_apixaban_first_fill_ind = i4
     2 l_refill_due_ind = i4
     2 l_inpatient_ind = i4
     2 f_last_fill_dt = f8
     2 f_days_filled = f8
     2 f_presc_expire_date = f8
     2 f_refill_remain = f8
     2 l_icd_cnt = i4
     2 icd[*]
       3 s_icd = vc
       3 s_icd_desc = vc
     2 l_lab_overdue_sort = i4
     2 l_scr_overdue_sort = i4
     2 l_notable_lab_finding_sort = i4
     2 l_active_nsaid_sort = i4
     2 l_major_ddi_sort = i4
     2 l_major_contra_sort = i4
     2 l_bar_surg_valv_rep_sort = i4
     2 l_refill_due_sort = i4
     2 l_dosing_flag_sort = i4
 ) WITH protect
 FREE RECORD m_smry
 RECORD m_smry(
   1 l_cnt = i4
   1 qual[*]
     2 s_facility = vc
     2 l_pat_cnt = i4
     2 l_dosing_flag_cnt = i4
     2 l_contra_ddi_cnt = i4
     2 l_major_ddi_cnt = i4
     2 l_active_nsaid_cnt = i4
     2 l_lab_overdue_cnt = i4
     2 l_valv_repl_cnt = i4
     2 l_notable_lab_cnt = i4
     2 l_refill_due_cnt = i4
 ) WITH protect
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.active_ind=1
    AND cnvtupper(trim(oc.primary_mnemonic,3)) IN ("APIXABAN", "BETRIXABAN", "EDOXABAN", "DABIGATRAN",
   "RIVAROXABAN"))
  DETAIL
   m_meds->l_crx_cnt += 1, stat = alterlist(m_meds->crx_qual,m_meds->l_crx_cnt), m_meds->crx_qual[
   m_meds->l_crx_cnt].f_catalog_cd = oc.catalog_cd,
   m_meds->crx_qual[m_meds->l_crx_cnt].s_prim_mnemonic = trim(oc.primary_mnemonic,3), m_meds->
   crx_qual[m_meds->l_crx_cnt].s_catalog_type = trim(uar_get_code_display(oc.catalog_type_cd),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.active_ind=1
    AND cnvtupper(trim(oc.primary_mnemonic,3)) IN ("CAPSAICIN", "DICLOFENAC", "CELECOXIB",
   "LIDOCAINE", "MENTHOL",
   "DIFLUNISAL", "ESOMEPRAZOLE", "NAPROXEN", "ETODOLAC", "FAMOTIDINE",
   "IBUPROFEN", "FENOPROFEN", "FLURBIPROFEN", "INDOMETHACIN", "KETOPROFEN",
   "KETOROLAC", "KETOROLAC TROMETHAMINE", "MECLOFENAMATE", "MEFENAMIC ACID", "MELOXICAM",
   "NABUMETONE", "OXAPROZIN", "PIROXICAM", "SALSALATE", "SULINDAC",
   "TOLMETIN"))
  DETAIL
   m_meds->l_nsaid_cnt += 1, stat = alterlist(m_meds->nsaid_qual,m_meds->l_nsaid_cnt), m_meds->
   nsaid_qual[m_meds->l_nsaid_cnt].f_catalog_cd = oc.catalog_cd,
   m_meds->nsaid_qual[m_meds->l_nsaid_cnt].s_prim_mnemonic = trim(oc.primary_mnemonic,3), m_meds->
   nsaid_qual[m_meds->l_nsaid_cnt].s_catalog_type = trim(uar_get_code_display(oc.catalog_type_cd),3)
  WITH nocounter
 ;end select
 IF (( $S_FLAG_FILTER="1"))
  SET ms_parse_filter = " m_rec->qual[d.seq].l_refill_due_ind = 1 "
 ELSEIF (( $S_FLAG_FILTER="2"))
  SET ms_parse_filter = " m_rec->qual[d.seq].l_lab_overdue_ind = 1 "
 ELSEIF (( $S_FLAG_FILTER="3"))
  SET ms_parse_filter = " m_rec->qual[d.seq].l_SCr_overdue_ind = 1 "
 ELSEIF (( $S_FLAG_FILTER="4"))
  SET ms_parse_filter = " m_rec->qual[d.seq].l_notable_lab_finding_ind=1 "
 ELSEIF (( $S_FLAG_FILTER="5"))
  SET ms_parse_filter = " m_rec->qual[d.seq].l_active_nsaid_ind = 1 "
 ELSEIF (( $S_FLAG_FILTER="6"))
  SET ms_parse_filter = " m_rec->qual[d.seq].l_major_ddi_ind = 1 "
 ELSEIF (( $S_FLAG_FILTER="7"))
  SET ms_parse_filter = " m_rec->qual[d.seq].l_major_contra_ind = 1 "
 ELSEIF (( $S_FLAG_FILTER="8"))
  SET ms_parse_filter = " m_rec->qual[d.seq].l_bar_surg_valv_rep_ind = 1 "
 ELSEIF (( $S_FLAG_FILTER="9"))
  SET ms_parse_filter = " m_rec->qual[d.seq].l_dosing_flag_ind = 1 "
 ENDIF
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea2,
   frequency_schedule fs
  PLAN (o
   WHERE o.catalog_cd IN (mf_cs200_dabigatran_cd, mf_cs200_rivaroxaban_cd, mf_cs200_apixaban_cd,
   mf_cs200_edoxaban_cd, mf_cs200_betrixaban_cd)
    AND o.active_ind=1
    AND o.prescription_order_id=0
    AND o.orig_ord_as_flag=1
    AND o.order_status_cd=mf_cs6004_ordered_cd
    AND o.orig_order_dt_tm > cnvtdatetime((curdate - 5),0))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_mrn_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea2.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (fs
   WHERE (fs.frequency_id= Outerjoin(o.frequency_id)) )
  ORDER BY e.encntr_id, o.order_id
  HEAD e.encntr_id
   null
  HEAD o.order_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].f_order_id = o
   .order_id, m_rec->qual[m_rec->l_cnt].f_catalog_cd = o.catalog_cd,
   m_rec->qual[m_rec->l_cnt].f_ord_frequency_id = fs.frequency_id, m_rec->qual[m_rec->l_cnt].
   f_orig_order_dt_tm = o.orig_order_dt_tm, m_rec->qual[m_rec->l_cnt].s_mrn = trim(cnvtalias(ea.alias,
     ea.alias_pool_cd),3),
   m_rec->qual[m_rec->l_cnt].s_fin = trim(cnvtalias(ea2.alias,ea2.alias_pool_cd),3), m_rec->qual[
   m_rec->l_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->qual[m_rec->
   l_cnt].s_pat_name = trim(p.name_full_formatted,3),
   m_rec->qual[m_rec->l_cnt].s_med_w_str = trim(o.order_mnemonic,3), m_rec->qual[m_rec->l_cnt].
   l_pat_age = floor((datetimediff(cnvtdatetime(sysdate),p.birth_dt_tm)/ 365.0)), m_rec->qual[m_rec->
   l_cnt].l_rivaroxaban_first_fill_ind = 1,
   m_rec->qual[m_rec->l_cnt].l_apixaban_first_fill_ind = 1
   IF (fs.max_event_per_day=0)
    m_rec->qual[m_rec->l_cnt].l_ord_freq_max_per_day = 1
   ELSE
    m_rec->qual[m_rec->l_cnt].l_ord_freq_max_per_day = fs.max_event_per_day
   ENDIF
   m_rec->qual[m_rec->l_cnt].l_lab_overdue_sort = 99, m_rec->qual[m_rec->l_cnt].l_scr_overdue_sort =
   99, m_rec->qual[m_rec->l_cnt].l_notable_lab_finding_sort = 99,
   m_rec->qual[m_rec->l_cnt].l_active_nsaid_sort = 99, m_rec->qual[m_rec->l_cnt].l_major_ddi_sort =
   99, m_rec->qual[m_rec->l_cnt].l_major_contra_sort = 99,
   m_rec->qual[m_rec->l_cnt].l_bar_surg_valv_rep_sort = 99, m_rec->qual[m_rec->l_cnt].
   l_refill_due_sort = 99, m_rec->qual[m_rec->l_cnt].l_dosing_flag_sort = 99
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e1
  PLAN (e1
   WHERE expand(ml_idx1,1,m_rec->l_cnt,e1.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND e1.active_ind=1
    AND e1.reg_dt_tm IS NOT null
    AND e1.disch_dt_tm = null
    AND e1.encntr_type_class_cd=mf_cs69_inpatient_cd)
  ORDER BY e1.person_id
  HEAD e1.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,e1.person_id,m_rec->qual[ml_idx1].f_person_id)
   WHILE (ml_idx2 > 0)
    m_rec->qual[ml_idx2].l_inpatient_ind = 1,ml_idx2 = locateval(ml_idx1,(ml_idx2+ 1),m_rec->l_cnt,e1
     .person_id,m_rec->qual[ml_idx1].f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  WHERE expand(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id)
   AND o.catalog_cd IN (mf_cs200_ketoconazole_cd, mf_cs200_dronedarone_cd, mf_cs200_verapamil_cd,
  mf_cs200_quinidine_cd, mf_cs200_azithromycin_cd,
  mf_cs200_clarithromycin_cd, mf_cs200_erythromycin_cd, mf_cs200_itraconazole_cd,
  mf_cs200_concomitant_cd, mf_cs200_ritonavir_cd)
   AND o.active_ind=1
   AND o.prescription_order_id=0
   AND o.orig_ord_as_flag=1
   AND o.order_status_cd=mf_cs6004_ordered_cd
  ORDER BY o.person_id, o.catalog_cd, o.orig_order_dt_tm
  HEAD o.person_id
   null
  HEAD o.catalog_cd
   ml_idx3 = locateval(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id)
   WHILE (ml_idx3 > 0)
    IF (o.catalog_cd=mf_cs200_ketoconazole_cd)
     m_rec->qual[ml_idx3].l_ketoconazole_found = 1
    ELSEIF (o.catalog_cd=mf_cs200_dronedarone_cd)
     m_rec->qual[ml_idx3].l_dronedarone_found = 1
    ELSEIF (o.catalog_cd=mf_cs200_verapamil_cd)
     m_rec->qual[ml_idx3].l_verapamil_found = 1
    ELSEIF (o.catalog_cd=mf_cs200_quinidine_cd)
     m_rec->qual[ml_idx3].l_quinidine_found = 1
    ELSEIF (o.catalog_cd=mf_cs200_azithromycin_cd)
     m_rec->qual[ml_idx3].l_azithromycin_found = 1
    ELSEIF (o.catalog_cd=mf_cs200_clarithromycin_cd)
     m_rec->qual[ml_idx3].l_clarithromycin_found = 1
    ELSEIF (o.catalog_cd=mf_cs200_erythromycin_cd)
     m_rec->qual[ml_idx3].l_erythromycin_found = 1
    ELSEIF (o.catalog_cd=mf_cs200_itraconazole_cd)
     m_rec->qual[ml_idx3].l_itraconazole_found = 1
    ELSEIF (o.catalog_cd=mf_cs200_concomitant_cd)
     m_rec->qual[ml_idx3].l_concomitant_found = 1
    ELSEIF (o.catalog_cd=mf_cs200_ritonavir_cd)
     m_rec->qual[ml_idx3].l_ritonavir_found = 1
    ENDIF
    ,ml_idx3 = locateval(ml_idx1,(ml_idx3+ 1),m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].
     f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE expand(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND o.catalog_cd IN (mf_cs200_rivaroxaban_cd, mf_cs200_apixaban_cd)
    AND o.active_ind=1
    AND o.orig_ord_as_flag=1
    AND o.order_status_cd IN (mf_cs6004_ordered_cd, mf_cs6004_completed_cd, mf_cs6004_discontinued_cd
   ))
  ORDER BY o.person_id
  DETAIL
   ml_idx3 = locateval(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id)
   WHILE (ml_idx3 > 0)
    IF ((m_rec->qual[ml_idx3].f_catalog_cd=o.catalog_cd))
     IF ((o.order_id != m_rec->qual[ml_idx3].f_order_id)
      AND ((cnvtdatetime(m_rec->qual[ml_idx3].f_orig_order_dt_tm) > o.orig_order_dt_tm) OR ((o
     .prescription_order_id=m_rec->qual[ml_idx3].f_order_id))) )
      IF (o.catalog_cd=mf_cs200_rivaroxaban_cd)
       m_rec->qual[ml_idx3].l_rivaroxaban_first_fill_ind = 0
      ELSEIF (o.catalog_cd=mf_cs200_apixaban_cd)
       m_rec->qual[ml_idx3].l_apixaban_first_fill_ind = 0
      ENDIF
     ENDIF
    ENDIF
    ,ml_idx3 = locateval(ml_idx1,(ml_idx3+ 1),m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].
     f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_date_result cdr
    PLAN (ce
     WHERE (ce.person_id=m_rec->qual[ml_idx1].f_person_id)
      AND ce.event_cd IN (mf_cs72_creatininelevel_cd, mf_cs72_creatininelvl_cd,
     mf_cs72_creatinineclearance_cd, mf_cs72_hemoglobin_cd, mf_cs72_platelets_cd,
     mf_cs72_pharanticoagotherindication_cd, mf_cs72_phardoacreassessrefill_cd,
     mf_cs72_phardoacreassesslabmonitoring_cd, mf_cs72_phardoacreassesscrmonitoring_cd,
     mf_cs72_phardoacreassesslabfinding_cd,
     mf_cs72_phardoacreassessnsaid_cd, mf_cs72_phardoacreassessddi_cd,
     mf_cs72_phardoacreassessvalvebari_cd, mf_cs72_phardoacreassessdosing_cd,
     mf_cs72_aspartatecsflc_cd,
     mf_cs72_aspartateurlc_cd, mf_cs72_aspartatelc_cd, mf_cs72_alaninecsflc_cd,
     mf_cs72_alanineurlc_cd, mf_cs72_alaninelc_cd,
     mf_cs72_anticoagprogressnote_cd, mf_cs72_weightdosing_cd, mf_cs72_pharanticoagfollowupdate_cd,
     mf_cs72_pharanticoagindication_cd)
      AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
     mf_cs8_modified_cd)
      AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
     JOIN (cdr
     WHERE (cdr.event_id= Outerjoin(ce.event_id))
      AND (cdr.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY ce.clinsig_updt_dt_tm DESC
    HEAD REPORT
     ml_event_scr_cnt = 0, ml_event_crcl_cnt = 0, ml_event_hbg_cnt = 0,
     ml_event_plt_cnt = 0, m_rec->qual[ml_idx1].l_suppress_refill = - (1), m_rec->qual[ml_idx1].
     l_suppress_lab_overdue = - (1),
     m_rec->qual[ml_idx1].l_suppress_scr_overdue = - (1), m_rec->qual[ml_idx1].
     l_suppress_notable_lab_finding = - (1), m_rec->qual[ml_idx1].l_suppress_nsaid_med = - (1),
     m_rec->qual[ml_idx1].l_suppress_major_ddi = - (1), m_rec->qual[ml_idx1].
     l_suppress_bar_surg_valv_rep = - (1), m_rec->qual[ml_idx1].l_suppress_dosing_flag = - (1)
    DETAIL
     IF (ce.event_cd=mf_cs72_anticoagprogressnote_cd
      AND (m_rec->qual[ml_idx1].f_last_anticoag_form=0))
      m_rec->qual[ml_idx1].f_last_anticoag_form = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].
      s_last_anticoag_form_dt = trim(format(ce.verified_dt_tm,"MMDDYYYY HH:mm;;q"),3)
     ENDIF
     IF (ce.view_level=1)
      IF (ce.event_cd=mf_cs72_weightdosing_cd
       AND (m_rec->qual[ml_idx1].f_weight_dosing_dt=0)
       AND isnumeric(ce.result_val) > 0)
       m_rec->qual[ml_idx1].f_weight_dosing_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].
       f_weight_dosing = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].s_weight_dosing = ce
       .result_val
      ENDIF
      IF (ce.event_cd IN (mf_cs72_aspartatecsflc_cd, mf_cs72_aspartateurlc_cd, mf_cs72_aspartatelc_cd
      )
       AND (m_rec->qual[ml_idx1].f_ast_result1_dt=0)
       AND isnumeric(ce.result_val) > 0)
       m_rec->qual[ml_idx1].f_ast_result1 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
       f_ast_result1_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_ast_result1_unit = trim(
        uar_get_code_display(ce.result_units_cd),3)
      ENDIF
      IF (ce.event_cd IN (mf_cs72_alaninecsflc_cd, mf_cs72_alanineurlc_cd, mf_cs72_alaninelc_cd)
       AND (m_rec->qual[ml_idx1].f_alt_result1_dt=0)
       AND isnumeric(ce.result_val) > 0)
       m_rec->qual[ml_idx1].f_alt_result1 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
       f_alt_result1_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_alt_result1_unit = trim(
        uar_get_code_display(ce.result_units_cd),3)
      ENDIF
      IF (ce.event_cd=mf_cs72_pharanticoagindication_cd
       AND size(trim(m_rec->qual[ml_idx1].s_anticoag_indication,3))=0)
       m_rec->qual[ml_idx1].s_anticoag_indication = trim(ce.result_val,3), m_rec->qual[ml_idx1].
       s_anticoag_indication_dt = trim(format(ce.verified_dt_tm,"MMDDYYYY HH:mm;;q"),3)
      ENDIF
      IF (ce.event_cd=mf_cs72_pharanticoagotherindication_cd
       AND size(trim(m_rec->qual[ml_idx1].s_anticoag_indication_other,3))=0)
       m_rec->qual[ml_idx1].s_anticoag_indication_other = trim(ce.result_val,3), m_rec->qual[ml_idx1]
       .s_anticoag_indication_other_dt = trim(format(ce.verified_dt_tm,"MMDDYYYY HH:mm;;q"),3)
      ENDIF
      IF (ce.event_cd=mf_cs72_pharanticoagfollowupdate_cd
       AND (m_rec->qual[ml_idx1].f_next_anticoag_appt_dt=0))
       m_rec->qual[ml_idx1].f_next_anticoag_appt_dt = cdr.result_dt_tm
      ENDIF
      IF (ce.event_cd=mf_cs72_phardoacreassessrefill_cd
       AND (m_rec->qual[ml_idx1].l_suppress_refill=- (1)))
       IF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 1 MONTH")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,30) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_refill = 1, m_rec->qual[ml_idx1].s_suppress_refill_dt =
         format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,30)),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_refill = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 3 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,90) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_refill = 1, m_rec->qual[ml_idx1].s_suppress_refill_dt =
         format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,90)),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_refill = 0
        ENDIF
       ENDIF
      ENDIF
      IF (ce.event_cd=mf_cs72_phardoacreassesslabmonitoring_cd
       AND (m_rec->qual[ml_idx1].l_suppress_lab_overdue=- (1)))
       IF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 2 WEEKS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,14) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_lab_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,14)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 1 MONTH")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,30) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_lab_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,30)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 2 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,60) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_lab_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,60)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 3 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,90) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_lab_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,90)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 6 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,180) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_lab_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,180)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 9 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,270) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_lab_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,270)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 12 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,365) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_lab_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,365)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_lab_overdue = 0
        ENDIF
       ENDIF
      ENDIF
      IF (ce.event_cd=mf_cs72_phardoacreassesscrmonitoring_cd
       AND (m_rec->qual[ml_idx1].l_suppress_scr_overdue=- (1)))
       IF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 2 WEEKS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,14) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_scr_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,14)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 1 MONTH")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,30) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_scr_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,30)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 2 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,60) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_scr_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,60)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 3 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,90) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_scr_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,90)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 6 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,180) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_scr_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,180)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 9 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,270) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_scr_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,270)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 12 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,365) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 1, m_rec->qual[ml_idx1].
         s_suppress_scr_overdue_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,365)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_scr_overdue = 0
        ENDIF
       ENDIF
      ENDIF
      IF (ce.event_cd=mf_cs72_phardoacreassesslabfinding_cd
       AND (m_rec->qual[ml_idx1].l_suppress_notable_lab_finding=- (1)))
       IF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 2 WEEKS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,14) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 1, m_rec->qual[ml_idx1].
         s_suppress_notable_lab_finding_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,14
            )),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 1 MONTH")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,30) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 1, m_rec->qual[ml_idx1].
         s_suppress_notable_lab_finding_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,30
            )),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 2 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,60) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 1, m_rec->qual[ml_idx1].
         s_suppress_notable_lab_finding_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,60
            )),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 3 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,90) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 1, m_rec->qual[ml_idx1].
         s_suppress_notable_lab_finding_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,90
            )),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 6 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,180) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 1, m_rec->qual[ml_idx1].
         s_suppress_notable_lab_finding_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,
            180)),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 9 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,270) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 1, m_rec->qual[ml_idx1].
         s_suppress_notable_lab_finding_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,
            270)),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 12 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,365) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 1, m_rec->qual[ml_idx1].
         s_suppress_notable_lab_finding_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,
            365)),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_notable_lab_finding = 0
        ENDIF
       ENDIF
      ENDIF
      IF (ce.event_cd=mf_cs72_phardoacreassessnsaid_cd
       AND (m_rec->qual[ml_idx1].l_suppress_nsaid_med=- (1)))
       IF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 3 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,90) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_nsaid_med = 1, m_rec->qual[ml_idx1].s_suppress_nsaid_med_dt
          = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,90)),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_nsaid_med = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 6 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,180) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_nsaid_med = 1, m_rec->qual[ml_idx1].s_suppress_nsaid_med_dt
          = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,180)),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_nsaid_med = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 12 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,365) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_nsaid_med = 1, m_rec->qual[ml_idx1].s_suppress_nsaid_med_dt
          = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,365)),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_nsaid_med = 0
        ENDIF
       ENDIF
      ENDIF
      IF (ce.event_cd=mf_cs72_phardoacreassessddi_cd
       AND (m_rec->qual[ml_idx1].l_suppress_major_ddi=- (1)))
       IF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 3 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,90) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_major_ddi = 1, m_rec->qual[ml_idx1].s_suppress_major_ddi_dt
          = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,90)),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_major_ddi = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 6 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,180) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_major_ddi = 1, m_rec->qual[ml_idx1].s_suppress_major_ddi_dt
          = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,180)),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_major_ddi = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 12 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,365) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_major_ddi = 1, m_rec->qual[ml_idx1].s_suppress_major_ddi_dt
          = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,365)),ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_major_ddi = 0
        ENDIF
       ENDIF
      ENDIF
      IF (ce.event_cd=mf_cs72_phardoacreassessvalvebari_cd
       AND (m_rec->qual[ml_idx1].l_suppress_bar_surg_valv_rep=- (1)))
       IF (cnvtupper(trim(ce.result_val,3))="DISMISS INDEFINITELY")
        m_rec->qual[ml_idx1].l_suppress_bar_surg_valv_rep = 1, m_rec->qual[ml_idx1].
        s_suppress_bar_surg_valv_rep_dt = "12/31/2100"
       ELSE
        m_rec->qual[ml_idx1].l_suppress_bar_surg_valv_rep = 0
       ENDIF
      ENDIF
      IF (ce.event_cd=mf_cs72_phardoacreassessdosing_cd
       AND (m_rec->qual[ml_idx1].l_suppress_dosing_flag=- (1)))
       IF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 3 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,90) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_dosing_flag = 1, m_rec->qual[ml_idx1].
         s_suppress_dosing_flag_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,90)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_dosing_flag = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 6 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,180) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_dosing_flag = 1, m_rec->qual[ml_idx1].
         s_suppress_dosing_flag_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,180)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_dosing_flag = 0
        ENDIF
       ELSEIF (cnvtupper(trim(ce.result_val,3))="REASSESS IN 12 MONTHS")
        IF (datetimeadd(ce.clinsig_updt_dt_tm,365) > cnvtdatetime(sysdate))
         m_rec->qual[ml_idx1].l_suppress_dosing_flag = 1, m_rec->qual[ml_idx1].
         s_suppress_dosing_flag_dt = format(cnvtdatetime(datetimeadd(ce.clinsig_updt_dt_tm,365)),
          ms_dt_format2)
        ELSE
         m_rec->qual[ml_idx1].l_suppress_dosing_flag = 0
        ENDIF
       ENDIF
      ENDIF
      IF (ce.event_cd IN (mf_cs72_creatininelevel_cd, mf_cs72_creatininelvl_cd,
      mf_cs72_creatinineclearance_cd, mf_cs72_hemoglobin_cd, mf_cs72_platelets_cd)
       AND isnumeric(ce.result_val) > 0)
       IF (ce.event_cd IN (mf_cs72_creatininelevel_cd, mf_cs72_creatininelvl_cd))
        ml_event_scr_cnt += 1
        IF (ml_event_scr_cnt=1)
         m_rec->qual[ml_idx1].f_scr_result1 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_scr_result1_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_scr_result1_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ELSEIF (ml_event_scr_cnt=2)
         m_rec->qual[ml_idx1].f_scr_result2 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_scr_result2_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_scr_result2_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ELSEIF (ml_event_scr_cnt=3)
         m_rec->qual[ml_idx1].f_scr_result3 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_scr_result3_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_scr_result3_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ENDIF
       ENDIF
       IF (ce.event_cd IN (mf_cs72_creatinineclearance_cd))
        ml_event_crcl_cnt += 1
        IF (ml_event_crcl_cnt=1)
         m_rec->qual[ml_idx1].f_crcl_result1 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_crcl_result1_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_crcl_result1_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ELSEIF (ml_event_crcl_cnt=2)
         m_rec->qual[ml_idx1].f_crcl_result2 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_crcl_result2_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_crcl_result2_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ELSEIF (ml_event_crcl_cnt=3)
         m_rec->qual[ml_idx1].f_crcl_result3 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_crcl_result3_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_crcl_result3_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ENDIF
       ENDIF
       IF (ce.event_cd IN (mf_cs72_hemoglobin_cd))
        ml_event_hbg_cnt += 1
        IF (ml_event_hbg_cnt=1)
         m_rec->qual[ml_idx1].f_hgb_result1 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_hgb_result1_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_hgb_result1_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ELSEIF (ml_event_hbg_cnt=2)
         m_rec->qual[ml_idx1].f_hgb_result2 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_hgb_result2_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_hgb_result2_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ELSEIF (ml_event_hbg_cnt=3)
         m_rec->qual[ml_idx1].f_hgb_result3 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_hgb_result3_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_hgb_result3_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ENDIF
       ENDIF
       IF (ce.event_cd IN (mf_cs72_platelets_cd))
        ml_event_plt_cnt += 1
        IF (ml_event_plt_cnt=1)
         m_rec->qual[ml_idx1].f_plt_result1 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_plt_result1_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_plt_result1_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ELSEIF (ml_event_plt_cnt=2)
         m_rec->qual[ml_idx1].f_plt_result2 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_plt_result2_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_plt_result2_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ELSEIF (ml_event_plt_cnt=3)
         m_rec->qual[ml_idx1].f_plt_result3 = cnvtreal(ce.result_val), m_rec->qual[ml_idx1].
         f_plt_result3_dt = ce.clinsig_updt_dt_tm, m_rec->qual[ml_idx1].s_plt_result3_unit = trim(
          uar_get_code_display(ce.result_units_cd),3)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM clinical_event ce1,
     clinical_event ce2,
     ce_date_result cdr
    PLAN (ce1
     WHERE (ce1.person_id=m_rec->qual[ml_idx1].f_person_id)
      AND ce1.view_level=1
      AND ce1.event_cd IN (mf_cs72_pharoutsidealt_cd, mf_cs72_pharoutsideast_cd,
     mf_cs72_pharoutsidecreatinine_cd, mf_cs72_pharoutsideplt_cd, mf_cs72_pharoutsidehgb_cd)
      AND ce1.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
     mf_cs8_modified_cd)
      AND ce1.valid_until_dt_tm > cnvtdatetime(sysdate))
     JOIN (ce2
     WHERE ce2.person_id=ce1.person_id
      AND ce2.encntr_id=ce1.encntr_id
      AND ce2.parent_event_id=ce1.parent_event_id
      AND ce2.event_cd IN (mf_cs72_pharoutsidealtdate_cd, mf_cs72_pharoutsideastdate_cd,
     mf_cs72_pharoutsidecreatininedate_cd, mf_cs72_pharoutsidepltdate_cd,
     mf_cs72_pharoutsidehgbdate_cd)
      AND ce2.view_level=1
      AND ce2.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
     mf_cs8_modified_cd)
      AND ce2.valid_until_dt_tm > cnvtdatetime(sysdate))
     JOIN (cdr
     WHERE cdr.event_id=ce2.event_id
      AND cdr.valid_until_dt_tm > cnvtdatetime(sysdate))
    ORDER BY cdr.result_dt_tm DESC
    DETAIL
     IF (isnumeric(ce1.result_val) > 0)
      IF (ce1.event_cd=mf_cs72_pharoutsidealt_cd
       AND ce2.event_cd=mf_cs72_pharoutsidealtdate_cd)
       IF (cnvtdatetime(cdr.result_dt_tm) > cnvtdatetime(m_rec->qual[ml_idx1].f_alt_result1_dt))
        m_rec->qual[ml_idx1].f_alt_result1_dt = cdr.result_dt_tm, m_rec->qual[ml_idx1].f_alt_result1
         = cnvtreal(ce1.result_val)
       ENDIF
      ENDIF
      IF (ce1.event_cd=mf_cs72_pharoutsideast_cd
       AND ce2.event_cd=mf_cs72_pharoutsideastdate_cd)
       IF (cnvtdatetime(cdr.result_dt_tm) > cnvtdatetime(m_rec->qual[ml_idx1].f_ast_result1_dt))
        m_rec->qual[ml_idx1].f_ast_result1_dt = cdr.result_dt_tm, m_rec->qual[ml_idx1].f_ast_result1
         = cnvtreal(ce1.result_val)
       ENDIF
      ENDIF
      IF (ce1.event_cd=mf_cs72_pharoutsidecreatinine_cd
       AND ce2.event_cd=mf_cs72_pharoutsidecreatininedate_cd)
       IF (cnvtdatetime(cdr.result_dt_tm) > cnvtdatetime(m_rec->qual[ml_idx1].f_scr_result1_dt))
        m_rec->qual[ml_idx1].f_scr_result1_dt = cdr.result_dt_tm, m_rec->qual[ml_idx1].f_scr_result1
         = cnvtreal(ce1.result_val)
       ENDIF
      ENDIF
      IF (ce1.event_cd=mf_cs72_pharoutsideplt_cd
       AND ce2.event_cd=mf_cs72_pharoutsidepltdate_cd)
       IF (cnvtdatetime(cdr.result_dt_tm) > cnvtdatetime(m_rec->qual[ml_idx1].f_plt_result1_dt))
        m_rec->qual[ml_idx1].f_plt_result1_dt = cdr.result_dt_tm, m_rec->qual[ml_idx1].f_plt_result1
         = cnvtreal(ce1.result_val)
       ENDIF
      ENDIF
      IF (ce1.event_cd=mf_cs72_pharoutsidehgb_cd
       AND ce2.event_cd=mf_cs72_pharoutsidehgbdate_cd)
       IF (cnvtdatetime(cdr.result_dt_tm) > cnvtdatetime(m_rec->qual[ml_idx1].f_hgb_result1_dt))
        m_rec->qual[ml_idx1].f_hgb_result3_dt = m_rec->qual[ml_idx1].f_hgb_result2_dt, m_rec->qual[
        ml_idx1].f_hgb_result3 = m_rec->qual[ml_idx1].f_hgb_result2, m_rec->qual[ml_idx1].
        f_hgb_result2_dt = m_rec->qual[ml_idx1].f_hgb_result1_dt,
        m_rec->qual[ml_idx1].f_hgb_result2 = m_rec->qual[ml_idx1].f_hgb_result1, m_rec->qual[ml_idx1]
        .f_hgb_result1_dt = cdr.result_dt_tm, m_rec->qual[ml_idx1].f_hgb_result1 = cnvtreal(ce1
         .result_val)
       ELSEIF (cnvtdatetime(cdr.result_dt_tm) > cnvtdatetime(m_rec->qual[ml_idx1].f_hgb_result2_dt))
        m_rec->qual[ml_idx1].f_hgb_result3_dt = m_rec->qual[ml_idx1].f_hgb_result2_dt, m_rec->qual[
        ml_idx1].f_hgb_result3 = m_rec->qual[ml_idx1].f_hgb_result2, m_rec->qual[ml_idx1].
        f_hgb_result2_dt = cdr.result_dt_tm,
        m_rec->qual[ml_idx1].f_hgb_result2 = cnvtreal(ce1.result_val)
       ELSEIF (cnvtdatetime(cdr.result_dt_tm) > cnvtdatetime(m_rec->qual[ml_idx1].f_hgb_result3_dt))
        m_rec->qual[ml_idx1].f_hgb_result3_dt = cdr.result_dt_tm, m_rec->qual[ml_idx1].f_hgb_result3
         = cnvtreal(ce1.result_val)
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF ((m_rec->qual[ml_idx1].s_last_anticoag_form_dt != m_rec->qual[ml_idx1].s_anticoag_indication_dt
   ))
    SET m_rec->qual[ml_idx1].s_anticoag_indication = trim("",3)
   ENDIF
   IF ((m_rec->qual[ml_idx1].s_last_anticoag_form_dt != m_rec->qual[ml_idx1].
   s_anticoag_indication_other_dt))
    SET m_rec->qual[ml_idx1].s_anticoag_indication_other = trim("",3)
   ENDIF
   SET ms_tmp_str = trim(m_rec->qual[ml_idx1].s_anticoag_indication,3)
   IF (size(ms_tmp_str) > 0)
    SET ml_parse_idx1 = findstring(",",ms_tmp_str)
    IF (ml_parse_idx1 > 0)
     WHILE (ml_parse_idx1 > 0)
       SET m_rec->qual[ml_idx1].l_icd_cnt += 1
       SET stat = alterlist(m_rec->qual[ml_idx1].icd,m_rec->qual[ml_idx1].l_icd_cnt)
       SET m_rec->qual[ml_idx1].icd[m_rec->qual[ml_idx1].l_icd_cnt].s_icd = trim(substring(1,(
         ml_parse_idx1 - 1),ms_tmp_str),3)
       SET m_rec->qual[ml_idx1].icd[m_rec->qual[ml_idx1].l_icd_cnt].s_icd_desc = trim(substring(1,(
         ml_parse_idx1 - 1),ms_tmp_str),3)
       SET ms_tmp_str = substring((ml_parse_idx1+ 1),size(ms_tmp_str),ms_tmp_str)
       SET ml_parse_idx1 = findstring(",",ms_tmp_str)
     ENDWHILE
     SET m_rec->qual[ml_idx1].l_icd_cnt += 1
     SET stat = alterlist(m_rec->qual[ml_idx1].icd,m_rec->qual[ml_idx1].l_icd_cnt)
     SET m_rec->qual[ml_idx1].icd[m_rec->qual[ml_idx1].l_icd_cnt].s_icd = trim(ms_tmp_str,3)
     SET m_rec->qual[ml_idx1].icd[m_rec->qual[ml_idx1].l_icd_cnt].s_icd_desc = trim(ms_tmp_str,3)
    ELSE
     SET m_rec->qual[ml_idx1].l_icd_cnt += 1
     SET stat = alterlist(m_rec->qual[ml_idx1].icd,m_rec->qual[ml_idx1].l_icd_cnt)
     SET m_rec->qual[ml_idx1].icd[m_rec->qual[ml_idx1].l_icd_cnt].s_icd = trim(ms_tmp_str,3)
     SET m_rec->qual[ml_idx1].icd[m_rec->qual[ml_idx1].l_icd_cnt].s_icd_desc = trim(ms_tmp_str,3)
    ENDIF
    SELECT INTO "nl:"
     FROM nomenclature n
     WHERE expand(ml_nidx1,1,m_rec->qual[ml_idx1].l_icd_cnt,n.source_identifier,m_rec->qual[ml_idx1].
      icd[ml_nidx1].s_icd)
      AND n.source_vocabulary_cd=mf_cs400_icd10_cd
      AND n.active_ind=1
     ORDER BY n.source_identifier
     HEAD n.source_identifier
      ml_nidx2 = locateval(ml_nidx1,1,m_rec->qual[ml_idx1].l_icd_cnt,n.source_identifier,m_rec->qual[
       ml_idx1].icd[ml_nidx1].s_icd)
      IF (ml_nidx2 > 0)
       m_rec->qual[ml_idx1].icd[ml_nidx2].s_icd_desc = trim(n.source_string,3)
      ENDIF
     WITH nocounter
    ;end select
    FOR (ml_nidx1 = 1 TO m_rec->qual[ml_idx1].l_icd_cnt)
      IF (ml_nidx1=1)
       SET m_rec->qual[ml_idx1].s_anticoag_indication = m_rec->qual[ml_idx1].icd[ml_nidx1].s_icd_desc
      ELSE
       SET m_rec->qual[ml_idx1].s_anticoag_indication = concat(m_rec->qual[ml_idx1].
        s_anticoag_indication,", ",m_rec->qual[ml_idx1].icd[ml_nidx1].s_icd_desc)
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM orders o
  WHERE expand(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id)
   AND expand(ml_idx2,1,m_meds->l_nsaid_cnt,o.catalog_cd,m_meds->nsaid_qual[ml_idx2].f_catalog_cd)
   AND o.active_ind=1
   AND o.prescription_order_id=0
   AND o.orig_ord_as_flag IN (1, 2)
   AND o.order_status_cd=mf_cs6004_ordered_cd
  ORDER BY o.person_id
  HEAD o.person_id
   ml_idx3 = locateval(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id)
   WHILE (ml_idx3 > 0)
    m_rec->qual[ml_idx3].l_active_nsaid_ind = 1,ml_idx3 = locateval(ml_idx1,(ml_idx3+ 1),m_rec->l_cnt,
     o.person_id,m_rec->qual[ml_idx1].f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM order_detail od
  PLAN (od
   WHERE expand(ml_idx1,1,m_rec->l_cnt,od.order_id,m_rec->qual[ml_idx1].f_order_id)
    AND od.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT",
   "FREQ",
   "DISPENSEQTY", "TOTALREFILLS", "STOPDTTM", "SPECINX", "DISPENSEQTYUNIT",
   "RXROUTE"))
  ORDER BY od.order_id, od.oe_field_meaning, od.action_sequence DESC
  HEAD od.order_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,od.order_id,m_rec->qual[ml_idx1].f_order_id)
  HEAD od.oe_field_meaning
   IF (ml_idx2 > 0)
    IF (od.oe_field_meaning="STRENGTHDOSE")
     m_rec->qual[ml_idx2].f_ord_strength = cnvtreal(od.oe_field_display_value), m_rec->qual[ml_idx2].
     s_ord_strength = trim(od.oe_field_display_value,3), m_rec->qual[ml_idx2].f_ord_daily_dose = (
     m_rec->qual[ml_idx2].l_ord_freq_max_per_day * m_rec->qual[ml_idx2].f_ord_strength)
    ENDIF
    IF (od.oe_field_meaning="STRENGTHDOSEUNIT")
     m_rec->qual[ml_idx2].s_ord_strength_unit = trim(od.oe_field_display_value,3)
    ENDIF
    IF (od.oe_field_meaning="VOLUMEDOSE")
     m_rec->qual[ml_idx2].f_ord_volume_dose = cnvtreal(od.oe_field_display_value), m_rec->qual[
     ml_idx2].s_ord_volume_dose = trim(od.oe_field_display_value,3)
    ENDIF
    IF (od.oe_field_meaning="VOLUMEDOSEUNIT")
     m_rec->qual[ml_idx2].s_ord_volume_dose_unit = trim(od.oe_field_display_value,3)
    ENDIF
    IF (od.oe_field_meaning="FREQ")
     m_rec->qual[ml_idx2].s_ord_freq = trim(od.oe_field_display_value,3)
    ENDIF
    IF (od.oe_field_meaning="DISPENSEQTY")
     m_rec->qual[ml_idx2].f_ord_disp_qty = cnvtreal(od.oe_field_display_value), m_rec->qual[ml_idx2].
     s_ord_disp_qty = trim(od.oe_field_display_value,3)
    ENDIF
    IF (od.oe_field_meaning="TOTALREFILLS")
     m_rec->qual[ml_idx2].f_ord_tot_refill = cnvtreal(od.oe_field_display_value), m_rec->qual[ml_idx2
     ].s_ord_tot_refill = trim(od.oe_field_display_value,3)
    ENDIF
    IF (od.oe_field_meaning="STOPDTTM")
     m_rec->qual[ml_idx2].f_ord_stop_dt = od.oe_field_dt_tm_value
    ENDIF
    IF (od.oe_field_meaning="SPECINX")
     m_rec->qual[ml_idx2].s_ord_specinx = trim(od.oe_field_display_value,3)
    ENDIF
    IF (od.oe_field_meaning="DISPENSEQTYUNIT")
     m_rec->qual[ml_idx2].s_ord_disp_unit = trim(od.oe_field_display_value,3)
    ENDIF
    IF (od.oe_field_meaning="RXROUTE")
     m_rec->qual[ml_idx2].s_ord_route = trim(od.oe_field_display_value,3)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM eks_dlg_event ede,
   eks_dlg_event_attr eksa1,
   eks_dlg_event_attr eksa2
  PLAN (ede
   WHERE ede.dlg_name="MUL_MED!DRUGDRUG"
    AND expand(ml_idx1,1,m_rec->l_cnt,ede.trigger_order_id,m_rec->qual[ml_idx1].f_order_id))
   JOIN (eksa1
   WHERE (eksa1.dlg_event_id= Outerjoin(ede.dlg_event_id))
    AND (eksa1.attr_name= Outerjoin("SEVERITY_LEVEL")) )
   JOIN (eksa2
   WHERE (eksa2.dlg_event_id= Outerjoin(ede.dlg_event_id))
    AND (eksa2.attr_name= Outerjoin("MAJOR_CONTRAINDICATED_IND")) )
  ORDER BY ede.trigger_order_id
  DETAIL
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,ede.trigger_order_id,m_rec->qual[ml_idx1].f_order_id)
   WHILE (ml_idx2 > 0)
    IF (((trim(eksa1.attr_value,3)="5") OR (trim(eksa2.attr_value,3)="1")) )
     m_rec->qual[ml_idx2].l_major_contra_ind = 1
    ELSE
     IF (trim(eksa1.attr_value,3)="3")
      m_rec->qual[ml_idx2].l_major_ddi_ind = 1
     ENDIF
    ENDIF
    ,ml_idx2 = locateval(ml_idx1,(ml_idx2+ 1),m_rec->l_cnt,ede.trigger_order_id,m_rec->qual[ml_idx1].
     f_order_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE expand(ml_idx1,1,m_rec->l_cnt,d.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND d.active_ind=1
    AND d.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.source_vocabulary_cd=mf_cs400_icd10cm_cd
    AND n.source_identifier IN ("V45.86", "Z98.84", "V42.2", "V43.3", "Z95.2",
   "Z95.3", "Z95.4", "I48.91", "I48.92", "415.19",
   "416.2", "I26.01", "I26.02", "I26.09", "I26.90",
   "I26.92", "I26.99", "I27.82", "Z86.711", "451",
   "451.11", "451.19", "451.2", "451.81", "451.82",
   "451.83", "451.84", "451.89", "451.9", "452",
   "453", "453.1", "453.2", "453.3", "453.4",
   "453.41", "453.42", "453.5", "453.51", "453.52",
   "453.6", "453.71", "453.72", "453.73", "453.74",
   "453.75", "453.76", "453.77", "453.79", "453.8",
   "453.81", "453.82", "453.83", "453.84", "453.85",
   "453.86", "453.87", "453.89", "453.9", "I80.00",
   "I80.01", "I80.02", "I80.03", "I80.10", "I80.11",
   "I80.12", "I80.13", "I80.201", "I80.202", "I80.203",
   "I80.209", "I80.211", "I80.212", "I80.213", "I80.219",
   "I80.221", "I80.222", "I80.223", "I80.229", "I80.231",
   "I80.232", "I80.233", "I80.239", "I80.291", "I80.292",
   "I80.293", "I80.299", "I80.3", "I80.8", "I80.9",
   "I82.0", "I82.1", "I82.210", "I82.211", "I82.220",
   "I82.221", "I82.290", "I82.291", "I82.3", "I82.401",
   "I82.402", "I82.403", "I82.409", "I82.411", "I82.412",
   "I82.413", "I82.419", "I82.421", "I82.422", "I82.423",
   "I82.429", "I82.431", "I82.432", "I82.433", "I82.439",
   "I82.441", "I82.442", "I82.443", "I82.449", "I82.491",
   "I82.492", "I82.493", "I82.499", "I82.4Y1", "I82.4Y2",
   "I82.4Y3", "I82.4Y9", "I82.4Z1", "I82.4Z2", "I82.4Z3",
   "I82.4Z9", "I82.501", "I82.502", "I82.503", "I82.509",
   "I82.511", "I82.512", "I82.513", "I82.519", "I82.521",
   "I82.522", "I82.523", "I82.529", "I82.531", "I82.532",
   "I82.533", "I82.539", "I82.541", "I82.542", "I82.543",
   "I82.549", "I82.591", "I82.592", "I82.593", "I82.599",
   "I82.5Y1", "I82.5Y2", "I82.5Y3", "I82.5Y9", "I82.5Z1",
   "I82.5Z2", "I82.5Z3", "I82.5Z9", "I82.601", "I82.602",
   "I82.603", "I82.609", "I82.611", "I82.612", "I82.613",
   "I82.619", "I82.621", "I82.622", "I82.623", "I82.629",
   "I82.701", "I82.702", "I82.703", "I82.709", "I82.711",
   "I82.712", "I82.713", "I82.719", "I82.721", "I82.722",
   "I82.723", "I82.729", "I82.811", "I82.812", "I82.813",
   "I82.819", "I82.890", "I82.891", "I82.90", "I82.91",
   "I82.A11", "I82.A12", "I82.A13", "I82.A19", "I82.A21",
   "I82.A22", "I82.A23", "I82.A29", "I82.B11", "I82.B12",
   "I82.B13", "I82.B19", "I82.B21", "I82.B22", "I82.B23",
   "I82.B29", "I82.C11", "I82.C12", "I82.C13", "I82.C19",
   "I82.C21", "I82.C22", "I82.C23", "I82.C29", "T82.817A",
   "T82.817A", "T82.817D", "T82.817D", "T82.817S", "T82.817S",
   "T82.818A", "T82.818A", "T82.818D", "T82.818D", "T82.818S",
   "T82.818S", "V12.51", "Z86.718", "Z86.72"))
  ORDER BY d.person_id, d.diagnosis_id
  HEAD d.person_id
   null
  HEAD d.diagnosis_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,d.person_id,m_rec->qual[ml_idx1].f_person_id)
   WHILE (ml_idx2 > 0)
     IF (n.source_identifier IN ("V45.86", "Z98.84"))
      m_rec->qual[ml_idx2].l_bariatric_surg_found = 1, m_rec->qual[ml_idx2].l_bar_surg_valv_rep_ind
       = 1
     ENDIF
     IF (n.source_identifier IN ("V42.2", "V43.3", "Z95.2", "Z95.3", "Z95.4"))
      m_rec->qual[ml_idx2].l_valve_replacement_found = 1, m_rec->qual[ml_idx2].
      l_bar_surg_valv_rep_ind = 1
     ENDIF
     IF (n.source_identifier IN ("I48.91"))
      m_rec->qual[ml_idx2].l_afib_found = 1
     ENDIF
     IF (n.source_identifier IN ("I48.92"))
      m_rec->qual[ml_idx2].l_aflut_found = 1
     ENDIF
     IF (n.source_identifier IN ("415.19", "416.2", "I26.01", "I26.02", "I26.09",
     "I26.90", "I26.92", "I26.99", "I27.82", "Z86.711"))
      m_rec->qual[ml_idx2].l_pe_found = 1
     ENDIF
     IF (n.source_identifier IN ("451", "451.11", "451.19", "451.2", "451.81",
     "451.82", "451.83", "451.84", "451.89", "451.9",
     "452", "453", "453.1", "453.2", "453.3",
     "453.4", "453.41", "453.42", "453.5", "453.51",
     "453.52", "453.6", "453.71", "453.72", "453.73",
     "453.74", "453.75", "453.76", "453.77", "453.79",
     "453.8", "453.81", "453.82", "453.83", "453.84",
     "453.85", "453.86", "453.87", "453.89", "453.9",
     "I80.00", "I80.01", "I80.02", "I80.03", "I80.10",
     "I80.11", "I80.12", "I80.13", "I80.201", "I80.202",
     "I80.203", "I80.209", "I80.211", "I80.212", "I80.213",
     "I80.219", "I80.221", "I80.222", "I80.223", "I80.229",
     "I80.231", "I80.232", "I80.233", "I80.239", "I80.291",
     "I80.292", "I80.293", "I80.299", "I80.3", "I80.8",
     "I80.9", "I82.0", "I82.1", "I82.210", "I82.211",
     "I82.220", "I82.221", "I82.290", "I82.291", "I82.3",
     "I82.401", "I82.402", "I82.403", "I82.409", "I82.411",
     "I82.412", "I82.413", "I82.419", "I82.421", "I82.422",
     "I82.423", "I82.429", "I82.431", "I82.432", "I82.433",
     "I82.439", "I82.441", "I82.442", "I82.443", "I82.449",
     "I82.491", "I82.492", "I82.493", "I82.499", "I82.4Y1",
     "I82.4Y2", "I82.4Y3", "I82.4Y9", "I82.4Z1", "I82.4Z2",
     "I82.4Z3", "I82.4Z9", "I82.501", "I82.502", "I82.503",
     "I82.509", "I82.511", "I82.512", "I82.513", "I82.519",
     "I82.521", "I82.522", "I82.523", "I82.529", "I82.531",
     "I82.532", "I82.533", "I82.539", "I82.541", "I82.542",
     "I82.543", "I82.549", "I82.591", "I82.592", "I82.593",
     "I82.599", "I82.5Y1", "I82.5Y2", "I82.5Y3", "I82.5Y9",
     "I82.5Z1", "I82.5Z2", "I82.5Z3", "I82.5Z9", "I82.601",
     "I82.602", "I82.603", "I82.609", "I82.611", "I82.612",
     "I82.613", "I82.619", "I82.621", "I82.622", "I82.623",
     "I82.629", "I82.701", "I82.702", "I82.703", "I82.709",
     "I82.711", "I82.712", "I82.713", "I82.719", "I82.721",
     "I82.722", "I82.723", "I82.729", "I82.811", "I82.812",
     "I82.813", "I82.819", "I82.890", "I82.891", "I82.90",
     "I82.91", "I82.A11", "I82.A12", "I82.A13", "I82.A19",
     "I82.A21", "I82.A22", "I82.A23", "I82.A29", "I82.B11",
     "I82.B12", "I82.B13", "I82.B19", "I82.B21", "I82.B22",
     "I82.B23", "I82.B29", "I82.C11", "I82.C12", "I82.C13",
     "I82.C19", "I82.C21", "I82.C22", "I82.C23", "I82.C29",
     "T82.817A", "T82.817A", "T82.817D", "T82.817D", "T82.817S",
     "T82.817S", "T82.818A", "T82.818A", "T82.818D", "T82.818D",
     "T82.818S", "T82.818S", "V12.51", "Z86.718", "Z86.72"))
      m_rec->qual[ml_idx2].l_dvt_found = 1
     ENDIF
     ml_idx2 = locateval(ml_idx1,(ml_idx2+ 1),m_rec->l_cnt,d.person_id,m_rec->qual[ml_idx1].
      f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_dispense od,
   order_detail odd
  PLAN (o
   WHERE expand(ml_idx3,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx3].f_person_id)
    AND expand(ml_idx1,1,m_rec->l_cnt,o.prescription_order_id,m_rec->qual[ml_idx1].f_order_id)
    AND o.catalog_cd IN (mf_cs200_dabigatran_cd, mf_cs200_rivaroxaban_cd, mf_cs200_apixaban_cd,
   mf_cs200_edoxaban_cd, mf_cs200_betrixaban_cd)
    AND o.active_ind=1)
   JOIN (od
   WHERE od.order_id=o.order_id)
   JOIN (odd
   WHERE (odd.order_id= Outerjoin(o.order_id))
    AND (odd.oe_field_meaning= Outerjoin("RXLEGALEXPIREDATE")) )
  ORDER BY o.prescription_order_id, o.order_id DESC, odd.action_sequence DESC
  HEAD o.prescription_order_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,o.prescription_order_id,m_rec->qual[ml_idx1].f_order_id
    )
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].f_last_fill_dt = od.last_refill_dt_tm, m_rec->qual[ml_idx2].f_days_filled =
    od.days_supply, m_rec->qual[ml_idx2].f_refill_remain = od.refills_remaining,
    m_rec->qual[ml_idx2].f_presc_expire_date = odd.oe_field_dt_tm_value
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF ((m_rec->qual[ml_idx1].f_plt_result1_dt > 0)
    AND (m_rec->qual[ml_idx1].f_hgb_result1_dt > 0))
    IF (((cnvtdatetime(sysdate) > datetimeadd(cnvtdatetime(m_rec->qual[ml_idx1].f_plt_result1_dt),365
     )) OR (cnvtdatetime(sysdate) > datetimeadd(cnvtdatetime(m_rec->qual[ml_idx1].f_hgb_result1_dt),
     365))) )
     SET m_rec->qual[ml_idx1].l_lab_overdue_ind = 1
    ENDIF
   ELSE
    SET m_rec->qual[ml_idx1].l_lab_overdue_ind = 1
   ENDIF
   IF ((m_rec->qual[ml_idx1].f_scr_result1_dt > 0))
    IF (cnvtdatetime(sysdate) > datetimeadd(cnvtdatetime(m_rec->qual[ml_idx1].f_scr_result1_dt),365))
     SET m_rec->qual[ml_idx1].l_scr_overdue_ind = 1
    ELSE
     IF ((((m_rec->qual[ml_idx1].l_pat_age > 75)) OR ((m_rec->qual[ml_idx1].f_crcl_result1 < 60)
      AND (m_rec->qual[ml_idx1].f_crcl_result1_dt > 0)))
      AND cnvtdatetime(sysdate) > datetimeadd(cnvtdatetime(m_rec->qual[ml_idx1].f_scr_result1_dt),180
      ))
      SET m_rec->qual[ml_idx1].l_scr_overdue_ind = 1
     ENDIF
    ENDIF
   ELSE
    SET m_rec->qual[ml_idx1].l_scr_overdue_ind = 1
   ENDIF
   IF ((m_rec->qual[ml_idx1].f_plt_result1_dt > 0)
    AND (m_rec->qual[ml_idx1].f_plt_result1 < 50))
    SET m_rec->qual[ml_idx1].l_notable_lab_finding_ind = 1
   ENDIF
   IF ((m_rec->qual[ml_idx1].f_plt_result1_dt > 0)
    AND (m_rec->qual[ml_idx1].f_plt_result2_dt > 0)
    AND (m_rec->qual[ml_idx1].f_plt_result1 < 100)
    AND (m_rec->qual[ml_idx1].f_plt_result2 > 100))
    SET m_rec->qual[ml_idx1].l_notable_lab_finding_ind = 1
   ENDIF
   IF ((m_rec->qual[ml_idx1].f_hgb_result1_dt > 0)
    AND (m_rec->qual[ml_idx1].f_hgb_result1 < 10))
    SET m_rec->qual[ml_idx1].l_notable_lab_finding_ind = 1
   ENDIF
   IF ((m_rec->qual[ml_idx1].f_hgb_result1_dt > 0)
    AND (m_rec->qual[ml_idx1].f_hgb_result2_dt > 0)
    AND ((m_rec->qual[ml_idx1].f_hgb_result2 - m_rec->qual[ml_idx1].f_hgb_result1) > 2))
    SET m_rec->qual[ml_idx1].l_notable_lab_finding_ind = 1
   ENDIF
   IF ((m_rec->qual[ml_idx1].f_ast_result1_dt > 0)
    AND (m_rec->qual[ml_idx1].f_ast_result1 > 134))
    SET m_rec->qual[ml_idx1].l_notable_lab_finding_ind = 1
   ENDIF
   IF ((m_rec->qual[ml_idx1].f_alt_result1_dt > 0)
    AND (m_rec->qual[ml_idx1].f_alt_result1 > 120))
    SET m_rec->qual[ml_idx1].l_notable_lab_finding_ind = 1
   ENDIF
   IF ((m_rec->qual[ml_idx1].f_last_fill_dt=0))
    SET m_rec->qual[ml_idx1].l_refill_due_ind = 1
   ELSE
    IF ((m_rec->qual[ml_idx1].f_last_fill_dt > 0))
     IF (cnvtdatetime(sysdate) > datetimeadd(cnvtdatetime(m_rec->qual[ml_idx1].f_last_fill_dt),(m_rec
      ->qual[ml_idx1].f_days_filled+ 35)))
      SET m_rec->qual[ml_idx1].l_refill_due_ind = 1
     ENDIF
    ENDIF
   ENDIF
   IF (size(trim(m_rec->qual[ml_idx1].s_ord_volume_dose,3)) > 0
    AND size(trim(m_rec->qual[ml_idx1].s_ord_volume_dose_unit,3)) > 0)
    SET m_rec->qual[ml_idx1].s_med_sig = concat(trim(m_rec->qual[ml_idx1].s_ord_volume_dose,3)," ",
     trim(m_rec->qual[ml_idx1].s_ord_volume_dose_unit,3))
   ENDIF
   IF (size(trim(m_rec->qual[ml_idx1].s_ord_route,3)) > 0)
    IF (size(trim(m_rec->qual[ml_idx1].s_med_sig,3)) > 0)
     SET m_rec->qual[ml_idx1].s_med_sig = concat(m_rec->qual[ml_idx1].s_med_sig,", ",trim(m_rec->
       qual[ml_idx1].s_ord_route,3))
    ELSE
     SET m_rec->qual[ml_idx1].s_med_sig = trim(m_rec->qual[ml_idx1].s_ord_route,3)
    ENDIF
   ENDIF
   IF (size(trim(m_rec->qual[ml_idx1].s_ord_freq,3)) > 0)
    IF (size(trim(m_rec->qual[ml_idx1].s_med_sig,3)) > 0)
     SET m_rec->qual[ml_idx1].s_med_sig = concat(m_rec->qual[ml_idx1].s_med_sig,", ",trim(m_rec->
       qual[ml_idx1].s_ord_freq,3))
    ELSE
     SET m_rec->qual[ml_idx1].s_med_sig = trim(m_rec->qual[ml_idx1].s_ord_freq,3)
    ENDIF
   ENDIF
   IF (size(trim(m_rec->qual[ml_idx1].s_ord_specinx,3)) > 0)
    IF (size(trim(m_rec->qual[ml_idx1].s_med_sig,3)) > 0)
     SET m_rec->qual[ml_idx1].s_med_sig = concat(m_rec->qual[ml_idx1].s_med_sig,", ",trim(m_rec->
       qual[ml_idx1].s_ord_specinx,3))
    ELSE
     SET m_rec->qual[ml_idx1].s_med_sig = trim(m_rec->qual[ml_idx1].s_ord_specinx,3)
    ENDIF
   ENDIF
   IF (size(trim(m_rec->qual[ml_idx1].s_ord_disp_qty,3)) > 0
    AND size(trim(m_rec->qual[ml_idx1].s_ord_disp_unit,3)) > 0)
    IF (size(trim(m_rec->qual[ml_idx1].s_med_sig,3)) > 0)
     SET m_rec->qual[ml_idx1].s_med_sig = concat(m_rec->qual[ml_idx1].s_med_sig,", # ",trim(m_rec->
       qual[ml_idx1].s_ord_disp_qty,3)," ",trim(m_rec->qual[ml_idx1].s_ord_disp_unit,3))
    ELSE
     SET m_rec->qual[ml_idx1].s_med_sig = concat("# ",trim(m_rec->qual[ml_idx1].s_ord_disp_qty,3)," ",
      trim(m_rec->qual[ml_idx1].s_ord_disp_unit,3))
    ENDIF
   ENDIF
   IF ((m_rec->qual[ml_idx1].f_catalog_cd=mf_cs200_dabigatran_cd))
    IF ((m_rec->qual[ml_idx1].f_crcl_result1_dt > 0)
     AND (m_rec->qual[ml_idx1].f_crcl_result1 < 30))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = "ABW CrCl below minimum for dabigatran"
    ELSEIF ((m_rec->qual[ml_idx1].f_ord_strength > 0)
     AND (((m_rec->qual[ml_idx1].f_ord_daily_dose > 300)) OR ((m_rec->qual[ml_idx1].f_ord_daily_dose
     < 150))) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment =
     "Total daily dose outside of acceptable range for dabigatran"
    ELSEIF ((m_rec->qual[ml_idx1].f_crcl_result1_dt > 0)
     AND (m_rec->qual[ml_idx1].f_crcl_result1 < 50)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 150)
     AND (((m_rec->qual[ml_idx1].l_ketoconazole_found=1)) OR ((m_rec->qual[ml_idx1].
    l_dronedarone_found=1))) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Drug interaction with dabigatran which implies a need for reduced",
      " dose dabigatran or alternative agent")
    ELSEIF ((((m_rec->qual[ml_idx1].l_pe_found=1)) OR ((m_rec->qual[ml_idx1].l_dvt_found=1)))
     AND (m_rec->qual[ml_idx1].l_afib_found=0)
     AND (m_rec->qual[ml_idx1].l_aflut_found=0)
     AND (m_rec->qual[ml_idx1].f_crcl_result1 >= 30)
     AND (m_rec->qual[ml_idx1].f_ord_strength > 0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose < 300))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment =
     "Reduced dose dabigatran for PE/DVT not recommended"
    ELSEIF ((((m_rec->qual[ml_idx1].l_pe_found=1)) OR ((m_rec->qual[ml_idx1].l_dvt_found=1)))
     AND (m_rec->qual[ml_idx1].l_afib_found=0)
     AND (m_rec->qual[ml_idx1].l_aflut_found=0)
     AND (m_rec->qual[ml_idx1].f_crcl_result1_dt > 0)
     AND (m_rec->qual[ml_idx1].f_crcl_result1 < 50)
     AND (m_rec->qual[ml_idx1].l_ketoconazole_found=1))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Given ketoconazole and ABW CrCl, dabigatran is not appropriate at ","any dose for VTE")
    ELSEIF ((((m_rec->qual[ml_idx1].l_afib_found=1)) OR ((m_rec->qual[ml_idx1].l_aflut_found=1)))
     AND (m_rec->qual[ml_idx1].f_crcl_result1 >= 30)
     AND (m_rec->qual[ml_idx1].f_ord_strength > 0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose < 300)
     AND (m_rec->qual[ml_idx1].l_ketoconazole_found=0)
     AND (m_rec->qual[ml_idx1].l_dronedarone_found=0))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Given afib or aflutter, dabigatran dose should not be reduced while",
      " ABW CrCl >=30 and patient not on ketoconazole or dronedarone")
    ENDIF
   ELSEIF ((m_rec->qual[ml_idx1].f_catalog_cd=mf_cs200_edoxaban_cd))
    IF ((m_rec->qual[ml_idx1].f_ord_strength > 0)
     AND (((m_rec->qual[ml_idx1].f_ord_daily_dose > 60)) OR ((m_rec->qual[ml_idx1].f_ord_daily_dose
     < 30))) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Daily doses outside of this range are outside the ","minimum/maximum for edoxaban")
    ELSEIF ((m_rec->qual[ml_idx1].f_crcl_result1_dt > 0)
     AND (m_rec->qual[ml_idx1].f_crcl_result1 < 30))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Edoxaban is not recommended for actual body weight CrCl lower"," than 30 mL/min")
    ELSEIF ((m_rec->qual[ml_idx1].f_crcl_result1 > 95)
     AND (m_rec->qual[ml_idx1].l_pe_found=0)
     AND (m_rec->qual[ml_idx1].l_dvt_found=0))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "For patients without VTE, edoxaban is not recommended for ",
      "actual body weight CrCl lower than 30 mL/min or greater than 95 mL/min")
    ELSEIF ((m_rec->qual[ml_idx1].f_ord_daily_dose > 65))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Daily doses > 60 mg/day of edoxaban are not recommended")
    ELSEIF ((m_rec->qual[ml_idx1].f_crcl_result1 < 50)
     AND (m_rec->qual[ml_idx1].f_crcl_result1_dt > 0)
     AND (m_rec->qual[ml_idx1].l_pe_found=0)
     AND (m_rec->qual[ml_idx1].l_dvt_found=0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 30))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "For non VTE conditions (such as afib or aflutter), the dose of",
      " edoxaban should be reduced to 30 mg / day when ABW CrCl < 50 mL/min")
    ELSEIF ((m_rec->qual[ml_idx1].f_crcl_result1 > 50)
     AND (m_rec->qual[ml_idx1].f_ord_strength > 0)
     AND (m_rec->qual[ml_idx1].l_pe_found=0)
     AND (m_rec->qual[ml_idx1].l_dvt_found=0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose < 60))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "For non-VTE conditions (such as afib or aflutter), the dose of ",
      "edoxaban should be not be reduced to 30 mg / day when ABW CrCl >= 50 mL/min")
    ELSEIF ((((m_rec->qual[ml_idx1].l_pe_found=1)) OR ((m_rec->qual[ml_idx1].l_dvt_found=1)))
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 30)
     AND (m_rec->qual[ml_idx1].l_afib_found=0)
     AND (m_rec->qual[ml_idx1].l_aflut_found=0)
     AND (((m_rec->qual[ml_idx1].l_verapamil_found=1)) OR ((((m_rec->qual[ml_idx1].l_quinidine_found=
    1)) OR ((((m_rec->qual[ml_idx1].l_azithromycin_found=1)) OR ((((m_rec->qual[ml_idx1].
    l_clarithromycin_found=1)) OR ((((m_rec->qual[ml_idx1].l_erythromycin_found=1)) OR ((((m_rec->
    qual[ml_idx1].l_itraconazole_found=1)) OR ((((m_rec->qual[ml_idx1].l_ketoconazole_found=1)) OR (
    (((m_rec->qual[ml_idx1].f_crcl_result1 < 50)
     AND (m_rec->qual[ml_idx1].f_crcl_result1_dt > 0)) OR ((m_rec->qual[ml_idx1].f_weight_dosing < 60
    )
     AND (m_rec->qual[ml_idx1].f_weight_dosing_dt > 0))) )) )) )) )) )) )) )) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "While treated for VTE only, the dose of edoxaban should be",
      " reduced to 30 mg when ABW CrCl < 50 mL/min or weight < 60 kg or also on verapamil, quinidine, azithromycin,",
      " clarithromycin, erythromycin, itraconazole, or ketoconazole")
    ELSEIF ((((m_rec->qual[ml_idx1].l_pe_found=1)) OR ((m_rec->qual[ml_idx1].l_dvt_found=1)))
     AND (m_rec->qual[ml_idx1].l_afib_found=0)
     AND (m_rec->qual[ml_idx1].l_aflut_found=0)
     AND (m_rec->qual[ml_idx1].f_crcl_result1 >= 50)
     AND (m_rec->qual[ml_idx1].f_weight_dosing >= 60)
     AND (m_rec->qual[ml_idx1].f_ord_strength > 0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose < 60))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "When treated for VTE with ABW CrCl >= 50 mL/min and weight >=60",
      " kg, a dose reduction below 60 mg/day for edoxaban is not recommended (in absence of an interacting medication such as",
      " verapamil, quinidine, azithromycin, clarithromycin, erythromycin, itraconazole, or ketoconazole"
      )
    ENDIF
   ELSEIF ((m_rec->qual[ml_idx1].f_catalog_cd=mf_cs200_rivaroxaban_cd))
    IF ((m_rec->qual[ml_idx1].f_crcl_result1_dt > 0)
     AND (m_rec->qual[ml_idx1].f_crcl_result1 < 30))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment =
     "Rivaroxaban is not recommended when ABW CrCl < 30 mL/min"
    ELSEIF ((((m_rec->qual[ml_idx1].f_ord_strength > 0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose < 15)
     AND (m_rec->qual[ml_idx1].f_ord_strength != 10)) OR ((m_rec->qual[ml_idx1].f_ord_daily_dose=10)
     AND (m_rec->qual[ml_idx1].f_ord_strength=10)
     AND (((m_rec->qual[ml_idx1].l_afib_found=1)) OR ((((m_rec->qual[ml_idx1].l_aflut_found=1)) OR (
    (((m_rec->qual[ml_idx1].l_pe_found=1)) OR ((m_rec->qual[ml_idx1].l_dvt_found=1))) )) )) )) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment =
     "Total daily dose lower than recommended for rivaroxaban"
    ELSEIF ((m_rec->qual[ml_idx1].l_pe_found=0)
     AND (m_rec->qual[ml_idx1].l_dvt_found=0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 20))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Daily doses > 20 mg/day are not recommended except for the first",
      " 21 days for treatment of PE/DVT")
    ELSEIF ((m_rec->qual[ml_idx1].l_pe_found=0)
     AND (m_rec->qual[ml_idx1].l_dvt_found=0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 15)
     AND (m_rec->qual[ml_idx1].f_crcl_result1_dt > 0)
     AND (m_rec->qual[ml_idx1].f_crcl_result1 < 50))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Rivaroxaban dose should be reduced for patients without"," PE/DVT with ABW CrCl < 50 mL/min")
    ELSEIF ((((m_rec->qual[ml_idx1].l_pe_found=1)) OR ((m_rec->qual[ml_idx1].l_dvt_found=1)))
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 20)
     AND (m_rec->qual[ml_idx1].l_rivaroxaban_first_fill_ind=0))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Doses > 20 mg/day of rivaroxaban are only appropriate for the",
      " first 21 days of PE/DVT treatment")
    ELSEIF ((m_rec->qual[ml_idx1].l_pe_found=0)
     AND (m_rec->qual[ml_idx1].l_dvt_found=0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 15)
     AND (m_rec->qual[ml_idx1].f_crcl_result1_dt > 0)
     AND (m_rec->qual[ml_idx1].f_crcl_result1 < 50))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "In absence of DVT/PE, rivaroxaban dose should be reduced when"," CrCl < 50 mL/min")
    ELSEIF ((m_rec->qual[ml_idx1].f_crcl_result1 > 50)
     AND (m_rec->qual[ml_idx1].f_ord_strength > 0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose < 20))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Rivaroxaban dose should not be reduced in patients with ","ABW CrCl >= 50 mL/min")
    ENDIF
   ELSEIF ((m_rec->qual[ml_idx1].f_catalog_cd=mf_cs200_apixaban_cd))
    IF ((m_rec->qual[ml_idx1].f_scr_result1 > 2.5)
     AND (m_rec->qual[ml_idx1].f_crcl_result1_dt > 0)
     AND (m_rec->qual[ml_idx1].f_crcl_result1 < 25))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Apixaban is not recommended when serum creatinine > 2.5 or"," ABW CrCl < 25 mL/min")
    ELSEIF ((m_rec->qual[ml_idx1].f_ord_strength > 0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose < 2.5))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment =
     "Apixaban doses < 2.5 mg BID are not recommended"
    ELSEIF ((m_rec->qual[ml_idx1].l_pe_found=0)
     AND (m_rec->qual[ml_idx1].l_dvt_found=0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 5)
     AND (m_rec->qual[ml_idx1].f_scr_result1 > 1.5)
     AND (((m_rec->qual[ml_idx1].f_weight_dosing_dt > 0)
     AND (m_rec->qual[ml_idx1].f_weight_dosing <= 60)) OR ((m_rec->qual[ml_idx1].l_pat_age >= 80))) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "In absence of VTE, apixaban dose should be reduced to 2.5 mg",
      " BID for patients meeting two of the following three criteria: serum creatinine >=1.5, either age >=80, or weight",
      " <=60.0 kg")
    ELSEIF ((m_rec->qual[ml_idx1].l_pe_found=0)
     AND (m_rec->qual[ml_idx1].l_dvt_found=0)
     AND (((m_rec->qual[ml_idx1].f_scr_result1 > 1.5)
     AND (m_rec->qual[ml_idx1].l_pat_age >= 80)) OR ((((m_rec->qual[ml_idx1].f_weight_dosing_dt > 0)
     AND (m_rec->qual[ml_idx1].f_weight_dosing <= 60)
     AND (m_rec->qual[ml_idx1].l_pat_age >= 80)) OR ((m_rec->qual[ml_idx1].f_scr_result1 > 1.5)
     AND (m_rec->qual[ml_idx1].f_weight_dosing_dt > 0)
     AND (m_rec->qual[ml_idx1].f_weight_dosing <= 60))) ))
     AND (((m_rec->qual[ml_idx1].l_concomitant_found=1)) OR ((((m_rec->qual[ml_idx1].
    l_clarithromycin_found=1)) OR ((((m_rec->qual[ml_idx1].l_ritonavir_found=1)) OR ((((m_rec->qual[
    ml_idx1].l_itraconazole_found=1)) OR ((m_rec->qual[ml_idx1].l_ketoconazole_found=1))) )) )) )) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "In absence of VTE, apixaban should be avoided if a patient is",
      " taking concomitant clarithromycin, ritonavir, itraconazole, or ketoconazole, and patient also meets two of the",
      " following three criteria: serum creatinine >=1.5, either age >=80, or weight <=60.0 kg")
    ELSEIF ((m_rec->qual[ml_idx1].l_pe_found=0)
     AND (m_rec->qual[ml_idx1].l_dvt_found=0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 10))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment =
     "In absence of VTE, apixaban doses > 10 mg/day are not recommended"
    ELSEIF ((m_rec->qual[ml_idx1].l_pe_found=0)
     AND (m_rec->qual[ml_idx1].l_dvt_found=0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 5)
     AND (((m_rec->qual[ml_idx1].l_concomitant_found=1)) OR ((((m_rec->qual[ml_idx1].
    l_clarithromycin_found=1)) OR ((((m_rec->qual[ml_idx1].l_ritonavir_found=1)) OR ((((m_rec->qual[
    ml_idx1].l_itraconazole_found=1)) OR ((m_rec->qual[ml_idx1].l_ketoconazole_found=1))) )) )) )) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "In absence of VTE, apixaban doses > 5 mg/day are not ",
      "recommended for patients receiving concomitant clarithromycin, ritonavir, itraconazole, or ketoconazole"
      )
    ELSEIF ((((m_rec->qual[ml_idx1].l_pe_found=1)) OR ((m_rec->qual[ml_idx1].l_dvt_found=1)))
     AND (m_rec->qual[ml_idx1].l_apixaban_first_fill_ind=0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 10))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Total daily dose of apixaban > 10 mg/day except for the first",
      " 7 days of therapy for DVT/PE treatment")
    ELSEIF ((((m_rec->qual[ml_idx1].l_pe_found=1)) OR ((m_rec->qual[ml_idx1].l_dvt_found=1)))
     AND (m_rec->qual[ml_idx1].l_apixaban_first_fill_ind=0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 5)
     AND (((m_rec->qual[ml_idx1].l_concomitant_found=1)) OR ((((m_rec->qual[ml_idx1].
    l_clarithromycin_found=1)) OR ((((m_rec->qual[ml_idx1].l_ritonavir_found=1)) OR ((((m_rec->qual[
    ml_idx1].l_itraconazole_found=1)) OR ((m_rec->qual[ml_idx1].l_ketoconazole_found=1))) )) )) )) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "For patients being treated for PE/DVT, beyond the first seven",
      " days of therapy, while receiving concomitant clarithromycin, ritonavir, itraconazole, or ketoconazole, the dose",
      " of apixaban should be reduced to 2.5 mg BID")
    ELSEIF ((m_rec->qual[ml_idx1].l_apixaban_first_fill_ind=0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 5)
     AND (((m_rec->qual[ml_idx1].l_concomitant_found=1)) OR ((((m_rec->qual[ml_idx1].
    l_clarithromycin_found=1)) OR ((((m_rec->qual[ml_idx1].l_ritonavir_found=1)) OR ((((m_rec->qual[
    ml_idx1].l_itraconazole_found=1)) OR ((m_rec->qual[ml_idx1].l_ketoconazole_found=1))) )) )) )) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "Beyond the first seven days of therapy, while receiving",
      " concomitant clarithromycin, ritonavir, itraconazole, or ketoconazole, the dose of apixaban should be reduced to",
      " 2.5 mg BID")
    ELSEIF ((((m_rec->qual[ml_idx1].l_pe_found=1)) OR ((m_rec->qual[ml_idx1].l_dvt_found=1)))
     AND (m_rec->qual[ml_idx1].l_apixaban_first_fill_ind=1)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose > 10)
     AND (((m_rec->qual[ml_idx1].l_concomitant_found=1)) OR ((((m_rec->qual[ml_idx1].
    l_clarithromycin_found=1)) OR ((((m_rec->qual[ml_idx1].l_ritonavir_found=1)) OR ((((m_rec->qual[
    ml_idx1].l_itraconazole_found=1)) OR ((m_rec->qual[ml_idx1].l_ketoconazole_found=1))) )) )) )) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "In the first seven days of therapy, while receiving concomitant",
      " clarithromycin, ritonavir, itraconazole, or ketoconazole, the dose of apixaban should be no higher than 5 mg BID"
      )
    ELSEIF ((m_rec->qual[ml_idx1].l_pe_found=0)
     AND (m_rec->qual[ml_idx1].l_dvt_found=0)
     AND (m_rec->qual[ml_idx1].f_scr_result1_dt > 0)
     AND (m_rec->qual[ml_idx1].f_scr_result1 < 1.5)
     AND (m_rec->qual[ml_idx1].f_ord_strength > 0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose < 10)
     AND (((m_rec->qual[ml_idx1].f_weight_dosing > 60)) OR ((m_rec->qual[ml_idx1].l_pat_age < 80))) )
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "For patients without PE/DVT, and not meeting the two of three,",
      " weight, serum creatinine, and age criteria for reduced dose, apixaban dose should not be reduced to below 5 mg BID"
      )
    ELSEIF ((((m_rec->qual[ml_idx1].l_afib_found=1)) OR ((m_rec->qual[ml_idx1].l_dvt_found=1)))
     AND (m_rec->qual[ml_idx1].f_scr_result1_dt > 0)
     AND (m_rec->qual[ml_idx1].f_scr_result1 < 1.5)
     AND (m_rec->qual[ml_idx1].f_ord_strength > 0)
     AND (m_rec->qual[ml_idx1].f_ord_daily_dose < 10)
     AND (((m_rec->qual[ml_idx1].f_weight_dosing > 60)) OR ((m_rec->qual[ml_idx1].l_pat_age < 80)))
     AND (m_rec->qual[ml_idx1].l_major_contra_ind=0)
     AND (m_rec->qual[ml_idx1].l_major_ddi_ind=0))
     SET m_rec->qual[ml_idx1].l_dosing_flag_ind = 1
     SET m_rec->qual[ml_idx1].s_dosing_flag_comment = concat(
      "For patients with afib/aflutter, without interacting",
      " medications, and not meeting the two of three, weight, serum creatinine, and age criteria for reduced dose,",
      " apixaban dose should not be reduced to below 5 mg BID")
    ENDIF
   ENDIF
 ENDFOR
 IF (( $S_RPT_TYPE="1"))
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    IF ((m_rec->qual[ml_idx1].l_refill_due_ind=1))
     IF ((m_rec->qual[ml_idx1].l_suppress_refill=1))
      SET m_rec->qual[ml_idx1].l_refill_due_sort = 50
     ELSE
      SET m_rec->qual[ml_idx1].l_refill_due_sort = 1
     ENDIF
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_lab_overdue_ind=1))
     IF ((m_rec->qual[ml_idx1].l_suppress_lab_overdue=1))
      SET m_rec->qual[ml_idx1].l_lab_overdue_sort = 50
     ELSE
      SET m_rec->qual[ml_idx1].l_lab_overdue_sort = 1
     ENDIF
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_scr_overdue_ind=1))
     IF ((m_rec->qual[ml_idx1].l_suppress_scr_overdue=1))
      SET m_rec->qual[ml_idx1].l_scr_overdue_sort = 50
     ELSE
      SET m_rec->qual[ml_idx1].l_scr_overdue_sort = 1
     ENDIF
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_notable_lab_finding_ind=1))
     IF ((m_rec->qual[ml_idx1].l_suppress_notable_lab_finding=1))
      SET m_rec->qual[ml_idx1].l_notable_lab_finding_sort = 50
     ELSE
      SET m_rec->qual[ml_idx1].l_notable_lab_finding_sort = 1
     ENDIF
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_active_nsaid_ind=1))
     IF ((m_rec->qual[ml_idx1].l_suppress_nsaid_med=1))
      SET m_rec->qual[ml_idx1].l_active_nsaid_sort = 50
     ELSE
      SET m_rec->qual[ml_idx1].l_active_nsaid_sort = 1
     ENDIF
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_major_ddi_ind=1))
     IF ((m_rec->qual[ml_idx1].l_suppress_major_ddi=1))
      SET m_rec->qual[ml_idx1].l_major_ddi_sort = 50
     ELSE
      SET m_rec->qual[ml_idx1].l_major_ddi_sort = 1
     ENDIF
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_major_contra_ind=1))
     SET m_rec->qual[ml_idx1].l_major_contra_sort = 1
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_bar_surg_valv_rep_ind=1))
     IF ((m_rec->qual[ml_idx1].l_suppress_bar_surg_valv_rep=1))
      SET m_rec->qual[ml_idx1].l_bar_surg_valv_rep_sort = 50
     ELSE
      SET m_rec->qual[ml_idx1].l_bar_surg_valv_rep_sort = 1
     ENDIF
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_dosing_flag_ind=1))
     IF ((m_rec->qual[ml_idx1].l_suppress_dosing_flag=1))
      SET m_rec->qual[ml_idx1].l_dosing_flag_sort = 50
     ELSE
      SET m_rec->qual[ml_idx1].l_dosing_flag_sort = 1
     ENDIF
    ENDIF
  ENDFOR
  SELECT INTO  $OUTDEV
   facility = trim(substring(1,100,m_rec->qual[d.seq].s_facility),3), patient_name = trim(substring(1,
     100,m_rec->qual[d.seq].s_pat_name),3), mrn = trim(substring(1,20,m_rec->qual[d.seq].s_mrn),3),
   inpatient = trim(substring(1,5,trim(cnvtstring(m_rec->qual[d.seq].l_inpatient_ind),3)),3),
   anticoagulation_indication = trim(substring(1,1500,concat(trim(m_rec->qual[d.seq].
       s_anticoag_indication,3),evaluate(size(trim(m_rec->qual[d.seq].s_anticoag_indication_other,3)),
       0," ",", "),trim(m_rec->qual[d.seq].s_anticoag_indication_other,3))),3), medication = trim(
    substring(1,60,concat(trim(m_rec->qual[d.seq].s_med_w_str,3)," ",trim(m_rec->qual[d.seq].
       s_ord_strength,3),trim(m_rec->qual[d.seq].s_ord_strength_unit,3))),3),
   medication_sig = trim(substring(1,250,replace(replace(m_rec->qual[d.seq].s_med_sig,char(13)," "),
      char(10)," ")),3), last_refill_date = trim(substring(1,20,trim(format(m_rec->qual[d.seq].
       f_last_fill_dt,ms_dt_format2),3)),3), refill_remaining =
   IF ((m_rec->qual[d.seq].f_last_fill_dt > 0)) trim(substring(1,5,trim(cnvtstring(m_rec->qual[d.seq]
        .f_refill_remain),3)),3)
   ELSE trim(substring(1,5," "),3)
   ENDIF
   ,
   last_visit = trim(substring(1,20,format(m_rec->qual[d.seq].f_last_anticoag_form,ms_dt_format2)),3),
   follow_up_date = trim(substring(1,20,format(m_rec->qual[d.seq].f_next_anticoag_appt_dt,
      ms_dt_format2)),3), scr =
   IF ((m_rec->qual[d.seq].f_scr_result1_dt > 0)) trim(substring(1,50,concat(trim(cnvtstring(m_rec->
         qual[d.seq].f_scr_result1,10,2),3),trim(m_rec->qual[d.seq].s_scr_result1_unit,3)," - ",
       format(cnvtdatetime(m_rec->qual[d.seq].f_scr_result1_dt),ms_dt_format2))),3)
   ENDIF
   ,
   crcl =
   IF ((m_rec->qual[d.seq].f_crcl_result1_dt > 0)) trim(substring(1,50,concat(trim(cnvtstring(m_rec->
         qual[d.seq].f_crcl_result1,10,2),3),trim(m_rec->qual[d.seq].s_crcl_result1_unit,3)," - ",
       format(cnvtdatetime(m_rec->qual[d.seq].f_crcl_result1_dt),ms_dt_format2))),3)
   ENDIF
   , hgb_1 =
   IF ((m_rec->qual[d.seq].f_hgb_result1_dt > 0)) trim(substring(1,50,concat(trim(cnvtstring(m_rec->
         qual[d.seq].f_hgb_result1,10,2),3),trim(m_rec->qual[d.seq].s_hgb_result1_unit,3)," - ",
       format(cnvtdatetime(m_rec->qual[d.seq].f_hgb_result1_dt),ms_dt_format2))),3)
   ENDIF
   , hgb_2 =
   IF ((m_rec->qual[d.seq].f_hgb_result2_dt > 0)) trim(substring(1,50,concat(trim(cnvtstring(m_rec->
         qual[d.seq].f_hgb_result2,10,2),3),trim(m_rec->qual[d.seq].s_hgb_result2_unit,3)," - ",
       format(cnvtdatetime(m_rec->qual[d.seq].f_hgb_result2_dt),ms_dt_format2))),3)
   ENDIF
   ,
   hgb_3 =
   IF ((m_rec->qual[d.seq].f_hgb_result3_dt > 0)) trim(substring(1,50,concat(trim(cnvtstring(m_rec->
         qual[d.seq].f_hgb_result3,10,2),3),trim(m_rec->qual[d.seq].s_hgb_result3_unit,3)," - ",
       format(cnvtdatetime(m_rec->qual[d.seq].f_hgb_result3_dt),ms_dt_format2))),3)
   ENDIF
   , plt =
   IF ((m_rec->qual[d.seq].f_plt_result1_dt > 0)) trim(substring(1,50,concat(trim(cnvtstring(m_rec->
         qual[d.seq].f_plt_result1,10,2),3),trim(m_rec->qual[d.seq].s_plt_result1_unit,3)," - ",
       format(cnvtdatetime(m_rec->qual[d.seq].f_plt_result1_dt),ms_dt_format2))),3)
   ENDIF
   , refill_due =
   IF ((m_rec->qual[d.seq].l_refill_due_ind=1)
    AND (m_rec->qual[d.seq].l_suppress_refill=1)) trim(substring(1,15,m_rec->qual[d.seq].
      s_suppress_refill_dt),3)
   ELSE trim(substring(1,15,trim(cnvtstring(m_rec->qual[d.seq].l_refill_due_ind),3)),3)
   ENDIF
   ,
   hgb_plt_overdue =
   IF ((m_rec->qual[d.seq].l_lab_overdue_ind=1)
    AND (m_rec->qual[d.seq].l_suppress_lab_overdue=1)) trim(substring(1,15,m_rec->qual[d.seq].
      s_suppress_lab_overdue_dt),3)
   ELSE trim(substring(1,15,trim(cnvtstring(m_rec->qual[d.seq].l_lab_overdue_ind),3)),3)
   ENDIF
   , scr_overdue =
   IF ((m_rec->qual[d.seq].l_scr_overdue_ind=1)
    AND (m_rec->qual[d.seq].l_suppress_scr_overdue=1)) trim(substring(1,15,m_rec->qual[d.seq].
      s_suppress_scr_overdue_dt),3)
   ELSE trim(substring(1,15,trim(cnvtstring(m_rec->qual[d.seq].l_scr_overdue_ind),3)),3)
   ENDIF
   , notable_lab_finding =
   IF ((m_rec->qual[d.seq].l_notable_lab_finding_ind=1)
    AND (m_rec->qual[d.seq].l_suppress_notable_lab_finding=1)) trim(substring(1,15,m_rec->qual[d.seq]
      .s_suppress_notable_lab_finding_dt),3)
   ELSE trim(substring(1,15,trim(cnvtstring(m_rec->qual[d.seq].l_notable_lab_finding_ind),3)),3)
   ENDIF
   ,
   active_nsaid =
   IF ((m_rec->qual[d.seq].l_active_nsaid_ind=1)
    AND (m_rec->qual[d.seq].l_suppress_nsaid_med=1)) trim(substring(1,15,m_rec->qual[d.seq].
      s_suppress_nsaid_med_dt),3)
   ELSE trim(substring(1,15,trim(cnvtstring(m_rec->qual[d.seq].l_active_nsaid_ind),3)),3)
   ENDIF
   , major_ddi =
   IF ((m_rec->qual[d.seq].l_major_ddi_ind=1)
    AND (m_rec->qual[d.seq].l_suppress_major_ddi=1)) trim(substring(1,15,m_rec->qual[d.seq].
      s_suppress_major_ddi_dt),3)
   ELSE trim(substring(1,15,trim(cnvtstring(m_rec->qual[d.seq].l_major_ddi_ind),3)),3)
   ENDIF
   , major_contraindicated_ddi = trim(substring(1,5,trim(cnvtstring(m_rec->qual[d.seq].
       l_major_contra_ind),3)),3),
   bariatric_surgery_or_valve_replacement =
   IF ((m_rec->qual[d.seq].l_bar_surg_valv_rep_ind=1)
    AND (m_rec->qual[d.seq].l_suppress_bar_surg_valv_rep=1)) trim(substring(1,15,m_rec->qual[d.seq].
      s_suppress_bar_surg_valv_rep_dt),3)
   ELSE trim(substring(1,15,trim(cnvtstring(m_rec->qual[d.seq].l_bar_surg_valv_rep_ind),3)),3)
   ENDIF
   , dosing_flag =
   IF ((m_rec->qual[d.seq].l_dosing_flag_ind=1)
    AND (m_rec->qual[d.seq].l_suppress_dosing_flag=1)) trim(substring(1,15,m_rec->qual[d.seq].
      s_suppress_dosing_flag_dt),3)
   ELSE trim(substring(1,15,trim(cnvtstring(m_rec->qual[d.seq].l_dosing_flag_ind),3)),3)
   ENDIF
   , dosing_detail =
   IF ((m_rec->qual[d.seq].l_dosing_flag_ind=1)
    AND (m_rec->qual[d.seq].l_suppress_dosing_flag != 1)) trim(substring(1,300,m_rec->qual[d.seq].
      s_dosing_flag_comment),3)
   ENDIF
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   PLAN (d
    WHERE parser(ms_parse_filter)
     AND  NOT ((m_rec->qual[d.seq].f_catalog_cd=mf_cs200_rivaroxaban_cd)
     AND (m_rec->qual[d.seq].f_ord_strength=2.5))
     AND (m_rec->qual[d.seq].l_inpatient_ind IN (0,  $F_INP_FLAG)))
   ORDER BY m_rec->qual[d.seq].l_major_contra_sort, m_rec->qual[d.seq].l_major_ddi_sort, m_rec->qual[
    d.seq].l_dosing_flag_sort,
    m_rec->qual[d.seq].l_bar_surg_valv_rep_sort, m_rec->qual[d.seq].l_notable_lab_finding_sort, m_rec
    ->qual[d.seq].l_active_nsaid_sort,
    m_rec->qual[d.seq].l_refill_due_sort, m_rec->qual[d.seq].l_scr_overdue_sort, m_rec->qual[d.seq].
    l_lab_overdue_sort,
    m_rec->qual[d.seq].s_pat_name
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ELSE
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    SET ml_idx2 = locateval(ml_idx3,1,m_smry->l_cnt,m_rec->qual[ml_idx1].s_facility,m_smry->qual[
     ml_idx3].s_facility)
    IF (ml_idx2=0)
     SET m_smry->l_cnt += 1
     SET ml_idx2 = m_smry->l_cnt
     SET stat = alterlist(m_smry->qual,ml_idx2)
     SET m_smry->qual[ml_idx2].s_facility = m_rec->qual[ml_idx1].s_facility
    ENDIF
    SET m_smry->qual[ml_idx2].l_pat_cnt += 1
    IF ((m_rec->qual[ml_idx1].l_dosing_flag_ind=1)
     AND (m_rec->qual[ml_idx1].l_suppress_dosing_flag != 1))
     SET m_smry->qual[ml_idx2].l_dosing_flag_cnt += 1
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_major_contra_ind=1))
     SET m_smry->qual[ml_idx2].l_contra_ddi_cnt += 1
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_major_ddi_ind=1)
     AND (m_rec->qual[ml_idx1].l_suppress_major_ddi != 1))
     SET m_smry->qual[ml_idx2].l_major_ddi_cnt += 1
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_active_nsaid_ind=1)
     AND (m_rec->qual[ml_idx1].l_suppress_nsaid_med != 1))
     SET m_smry->qual[ml_idx2].l_active_nsaid_cnt += 1
    ENDIF
    IF ((((m_rec->qual[ml_idx1].l_lab_overdue_ind=1)
     AND (m_rec->qual[ml_idx1].l_suppress_lab_overdue != 1)) OR ((m_rec->qual[ml_idx1].
    l_scr_overdue_ind=1)
     AND (m_rec->qual[ml_idx1].l_suppress_scr_overdue != 1))) )
     SET m_smry->qual[ml_idx2].l_lab_overdue_cnt += 1
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_bar_surg_valv_rep_ind=1)
     AND (m_rec->qual[ml_idx1].l_suppress_bar_surg_valv_rep != 1))
     SET m_smry->qual[ml_idx2].l_valv_repl_cnt += 1
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_notable_lab_finding_ind=1)
     AND (m_rec->qual[ml_idx1].l_suppress_notable_lab_finding != 1))
     SET m_smry->qual[ml_idx2].l_notable_lab_cnt += 1
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_refill_due_ind=1)
     AND (m_rec->qual[ml_idx1].l_suppress_refill != 1))
     SET m_smry->qual[ml_idx2].l_refill_due_cnt += 1
    ENDIF
  ENDFOR
  SELECT INTO  $OUTDEV
   facility = trim(substring(1,100,m_smry->qual[d.seq].s_facility),3), total_patients = m_smry->qual[
   d.seq].l_pat_cnt, dosing_flag = m_smry->qual[d.seq].l_dosing_flag_cnt,
   major_ddi = m_smry->qual[d.seq].l_major_ddi_cnt, major_contraindicated_ddi = m_smry->qual[d.seq].
   l_contra_ddi_cnt, active_nsaid = m_smry->qual[d.seq].l_active_nsaid_cnt,
   hgb_plt_scr_overdue = m_smry->qual[d.seq].l_lab_overdue_cnt, valve_replacement = m_smry->qual[d
   .seq].l_valv_repl_cnt, notable_labs = m_smry->qual[d.seq].l_notable_lab_cnt,
   refill_overdue = m_smry->qual[d.seq].l_refill_due_cnt
   FROM (dummyt d  WITH seq = m_smry->l_cnt)
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ENDIF
#exit_script
END GO
