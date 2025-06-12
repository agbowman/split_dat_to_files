CREATE PROGRAM bhs_rpt_pcm_ob_bundle:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Email" = ""
  WITH outdev, ms_start_date, ms_end_date,
  s_email
 DECLARE mf_cs72_deliverytype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Delivery Type:"))
 DECLARE mf_cs72_apgarscore5minute_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "APGARSCORE5MINUTE"))
 DECLARE mf_cs72_primarycsection_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PRIMARYCSECTION"))
 DECLARE mf_cs72_bloodproducttransfused_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"BLOODPRODUCTTRANSFUSED"))
 DECLARE mf_cs72_egaatdocumenteddatetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",
   72,"EGAATDOCUMENTEDDATETIME"))
 DECLARE mf_cs72_transferredto1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Transferred To:"))
 DECLARE mf_cs72_transferredto2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Transferred To"))
 DECLARE mf_cs72_groupbstreptrans_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GROUPBSTREPTRANSCRIBEDRESULT"))
 DECLARE mf_cs72_groupbstrepculture_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GROUPBSTREPCULTURE"))
 DECLARE mf_cs72_excbreastgatdis_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EXCLUSIVEBREASTFEEDINGATDISCHARGE"))
 DECLARE mf_cs72_glucosetolerance1hour_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GLUCOSETOLERANCE1HOUR"))
 DECLARE mf_cs72_glucose50gm60minutes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GLUCOSE50GM60MINUTES"))
 DECLARE mf_cs72_deliveryphysician_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,
   "DELIVERYPHYSICIAN"))
 DECLARE mf_cs72_deliverycnm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,
   "DELIVERYCNM"))
 DECLARE mf_cs72_attendingprovider_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,
   "ATTENDINGPROVIDER"))
 DECLARE mf_cs72_neonateoutcome_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEONATEOUTCOME"))
 DECLARE mf_cs72_datetimeofbirth_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Date, Time of Birth:"))
 DECLARE mf_cs4002015_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",4002015,
   "ACTIVE"))
 DECLARE mf_cs4002015_inactive_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",4002015,
   "INACTIVE"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cs319_finnbr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ms_tmp = vc WITH protect, noconstant("")
 DECLARE ms_email = vc WITH protect, constant(trim( $S_EMAIL,3))
 DECLARE mf_beg_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE ms_outdev = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE ml_ops_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ms_temp1 = vc WITH protect, noconstant("")
 DECLARE ms_temp2 = vc WITH protect, noconstant("")
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
   1 l_tot_dtype = i4
   1 l_tot_del_csec = i4
   1 l_tot_del_vag = i4
   1 f_low_los_vag = f8
   1 f_high_los_vag = f8
   1 f_tot_los_vag = f8
   1 f_median_los_vag = f8
   1 f_low_los_csec = f8
   1 f_high_los_csec = f8
   1 f_tot_los_csec = f8
   1 f_median_los_csec = f8
   1 l_tot_nicu_xfer = i4
   1 l_tot_strep_res = i4
   1 1_tot_disch_breastfeed = i4
   1 l_tot_gluc_tol = i4
   1 l_tot_prim_csec = i4
   1 l_tot_apgar = i4
   1 l_tot_blood_transf = i4
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_delivery_type = vc
     2 n_dtype_ind = i2
     2 n_dtype_vag = i2
     2 n_dtype_csec = i2
     2 n_dtype_prim_csec = i2
     2 n_term_apgar_ind = i2
     2 n_transfusion_4_unit_ind = i2
     2 n_nicu_xfer = i2
     2 n_strep_res = i2
     2 n_disch_breastfeed = i2
     2 n_gluc_tol = i2
     2 s_delivery_ega = vc
     2 s_delivery_ega_full = vc
     2 s_prim_surgeon = vc
     2 n_diab_ind = i2
     2 f_los = f8
     2 s_pat_name = vc
     2 s_pat_mrn = vc
     2 s_fin = vc
     2 l_output_ind = i4
     2 s_qual_event = vc
     2 l_dyn_cnt = i4
     2 dyn_grp[*]
       3 f_dyn_grp_id = f8
       3 s_dyn_grp_label = vc
       3 s_del_provider = vc
       3 s_attend_provider = vc
       3 s_del_cnm = vc
       3 s_birth_dt = vc
       3 s_neonate_outcome = vc
 ) WITH protect
 IF (ms_outdev="OPS")
  SET ml_ops_ind = 1
  SET mf_end_dt_tm = datetimefind(cnvtdatetime(curdate,0),"M","B","B")
  SET mf_beg_dt_tm = cnvtlookbehind("3 M",cnvtdatetime(mf_end_dt_tm))
 ELSE
  SET mf_beg_dt_tm = cnvtdatetime(cnvtdate2( $MS_START_DATE,"DD-MMM-YYYY"),0)
  SET mf_end_dt_tm = cnvtdatetime(cnvtdate2( $MS_END_DATE,"DD-MMM-YYYY"),235959)
 ENDIF
 CALL echo(format(cnvtdatetime(mf_beg_dt_tm),";;q"))
 CALL echo(format(cnvtdatetime(mf_end_dt_tm),";;q"))
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
   m_enc->l_cnt = (m_enc->l_cnt+ 1), stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->
   l_cnt].f_encntr_id = e.encntr_id,
   m_enc->qual[m_enc->l_cnt].f_person_id = e.person_id, m_enc->qual[m_enc->l_cnt].f_los =
   datetimediff(e.disch_dt_tm,e.reg_dt_tm,4), m_enc->f_high_los_csec = - (1.0),
   m_enc->f_high_los_vag = - (1.0), m_enc->f_low_los_csec = - (1.0), m_enc->f_low_los_vag = - (1.0),
   m_enc->f_tot_los_csec = 0.0, m_enc->f_tot_los_vag = 0.0
  WITH nocounter
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
    AND n.source_identifier IN ("502372015", "121589010", "1220321013", "306108017", "306110015",
   "306106018", "306117017", "197985011", "197763012", "474213016",
   "200951011", "77728011", "73465010", "264680017", "1220319015",
   "20191016", "124602011", "78158011", "2618091015", "118865018",
   "2618092010", "2618093017", "2618094011", "2618097016", "2618095012",
   "2618096013", "494562011", "356113012", "292547010", "77727018",
   "38709010", "46924017", "1223147012", "494563018", "457327017",
   "356076010", "493773010", "292587017", "73466011", "493771012",
   "356130014", "356133011", "197984010", "197761014", "494564012",
   "493774016"))
  ORDER BY p.person_id
  HEAD p.person_id
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,p.person_id,m_enc->qual[ml_idx1].f_person_id)
   WHILE (ml_idx2 > 0)
    m_enc->qual[ml_idx2].n_diab_ind = 1,ml_idx2 = locateval(ml_idx1,(ml_idx2+ 1),m_enc->l_cnt,p
     .person_id,m_enc->qual[ml_idx1].f_person_id)
   ENDWHILE
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
    AND ce.event_cd IN (mf_cs72_deliverytype_cd, mf_cs72_apgarscore5minute_cd,
   mf_cs72_primarycsection_cd, mf_cs72_bloodproducttransfused_cd, mf_cs72_egaatdocumenteddatetime_cd,
   mf_cs72_transferredto1_cd, mf_cs72_transferredto2_cd, mf_cs72_groupbstreptrans_cd,
   mf_cs72_groupbstrepculture_cd, mf_cs72_glucosetolerance1hour_cd,
   mf_cs72_glucose50gm60minutes_cd))
   JOIN (ccr
   WHERE ccr.event_id=outerjoin(ce.event_id)
    AND ccr.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(ccr.nomenclature_id))
  ORDER BY ce.encntr_id, ce.event_cd, ce.performed_dt_tm DESC
  HEAD ce.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,ce.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
  HEAD ce.event_cd
   IF (ce.event_cd=mf_cs72_deliverytype_cd)
    m_enc->qual[ml_idx2].s_delivery_type = ce.result_val
   ENDIF
   IF (ce.event_cd=mf_cs72_egaatdocumenteddatetime_cd)
    m_enc->qual[ml_idx2].s_delivery_ega = substring(1,2,trim(ce.result_val,3)), m_enc->qual[ml_idx2].
    s_delivery_ega_full = trim(ce.result_val,3)
   ENDIF
   IF (ce.event_cd IN (mf_cs72_groupbstreptrans_cd, mf_cs72_groupbstrepculture_cd))
    m_enc->qual[ml_idx2].n_strep_res = 1
   ENDIF
   IF (ce.event_cd IN (mf_cs72_glucosetolerance1hour_cd, mf_cs72_glucose50gm60minutes_cd)
    AND (m_enc->qual[ml_idx2].n_diab_ind=0))
    m_enc->qual[ml_idx2].n_gluc_tol = 1
   ENDIF
  DETAIL
   IF (ce.event_cd=mf_cs72_deliverytype_cd)
    m_enc->qual[ml_idx2].n_dtype_ind = 1
    IF (trim(n.source_string,3) IN ("Vaginal", "Vaginal, forcep and vacuum", "Vaginal, forcep assist",
    "Vaginal, vacuum assist"))
     m_enc->qual[ml_idx2].n_dtype_vag = 1
    ENDIF
    IF (trim(n.source_string,3) IN ("C-section, indicated", "C-Section, classical",
    "C-Section, low transverse", "C-Section, forcep and vacuum", "C-Section, forcep assist",
    "C-Section, J incision", "C-Section, low vertical", "C-Section, other", "C-Section, T incision",
    "C-Section, vacuum assist"))
     m_enc->qual[ml_idx2].n_dtype_csec = 1
    ENDIF
   ELSEIF (ce.event_cd=mf_cs72_apgarscore5minute_cd)
    IF (isnumeric(ce.result_val) > 0)
     IF (cnvtreal(ce.result_val) < 7.0)
      IF ((m_enc->qual[ml_idx2].n_term_apgar_ind=0))
       m_enc->qual[ml_idx2].n_term_apgar_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=mf_cs72_bloodproducttransfused_cd)
    IF (trim(n.source_string,3) IN ("Red Blood Cells", "Red Blood Cells (Autologous)"))
     IF ((m_enc->qual[ml_idx2].n_transfusion_4_unit_ind=0))
      m_enc->qual[ml_idx2].n_transfusion_4_unit_ind = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=mf_cs72_primarycsection_cd)
    IF (trim(n.source_string,3)="Yes")
     IF ((m_enc->qual[ml_idx2].n_dtype_prim_csec=0))
      m_enc->qual[ml_idx2].n_dtype_prim_csec = 1
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd IN (mf_cs72_transferredto1_cd, mf_cs72_transferredto2_cd))
    IF (trim(n.source_string,3)="NICU")
     IF ((m_enc->qual[ml_idx2].n_nicu_xfer=0))
      m_enc->qual[ml_idx2].n_nicu_xfer = 1
     ENDIF
    ENDIF
   ENDIF
  FOOT  ce.encntr_id
   IF ((m_enc->qual[ml_idx2].n_dtype_ind=1))
    m_enc->l_tot_dtype = (m_enc->l_tot_dtype+ 1)
    IF ((m_enc->qual[ml_idx2].n_gluc_tol=1))
     m_enc->l_tot_gluc_tol = (m_enc->l_tot_gluc_tol+ 1), m_enc->qual[ml_idx2].l_output_ind = 1, m_enc
     ->qual[ml_idx2].s_qual_event = concat(m_enc->qual[ml_idx2].s_qual_event,evaluate(size(m_enc->
        qual[ml_idx2].s_qual_event),0,"Group Tolerance",", Group Tolerance"))
    ENDIF
    IF ((m_enc->qual[ml_idx2].n_strep_res=1))
     m_enc->l_tot_strep_res = (m_enc->l_tot_strep_res+ 1), m_enc->qual[ml_idx2].l_output_ind = 1,
     m_enc->qual[ml_idx2].s_qual_event = concat(m_enc->qual[ml_idx2].s_qual_event,evaluate(size(m_enc
        ->qual[ml_idx2].s_qual_event),0,"Group B Strep",", Group B Strep"))
    ENDIF
    IF ((m_enc->qual[ml_idx2].n_dtype_csec=1))
     m_enc->l_tot_del_csec = (m_enc->l_tot_del_csec+ 1), m_enc->f_tot_los_csec = (m_enc->
     f_tot_los_csec+ m_enc->qual[ml_idx2].f_los)
     IF ((m_enc->f_high_los_csec=- (1.0)))
      m_enc->f_high_los_csec = m_enc->qual[ml_idx2].f_los
     ELSE
      IF ((m_enc->f_high_los_csec < m_enc->qual[ml_idx2].f_los))
       m_enc->f_high_los_csec = m_enc->qual[ml_idx2].f_los
      ENDIF
     ENDIF
     IF ((m_enc->f_low_los_csec=- (1.0)))
      m_enc->f_low_los_csec = m_enc->qual[ml_idx2].f_los
     ELSE
      IF ((m_enc->f_low_los_csec > m_enc->qual[ml_idx2].f_los))
       m_enc->f_low_los_csec = m_enc->qual[ml_idx2].f_los
      ENDIF
     ENDIF
     IF ((m_enc->qual[ml_idx2].n_dtype_prim_csec=1))
      m_enc->l_tot_prim_csec = (m_enc->l_tot_prim_csec+ 1), m_enc->qual[ml_idx2].l_output_ind = 1,
      m_enc->qual[ml_idx2].s_qual_event = concat(m_enc->qual[ml_idx2].s_qual_event,evaluate(size(
         m_enc->qual[ml_idx2].s_qual_event),0,"Primary C-section",", Primary C-section"))
     ENDIF
    ENDIF
    IF ((m_enc->qual[ml_idx2].n_dtype_vag=1))
     m_enc->l_tot_del_vag = (m_enc->l_tot_del_vag+ 1), m_enc->f_tot_los_vag = (m_enc->f_tot_los_vag+
     m_enc->qual[ml_idx2].f_los)
     IF ((m_enc->f_high_los_vag=- (1.0)))
      m_enc->f_high_los_vag = m_enc->qual[ml_idx2].f_los
     ELSE
      IF ((m_enc->f_high_los_vag < m_enc->qual[ml_idx2].f_los))
       m_enc->f_high_los_vag = m_enc->qual[ml_idx2].f_los
      ENDIF
     ENDIF
     IF ((m_enc->f_low_los_vag=- (1.0)))
      m_enc->f_low_los_vag = m_enc->qual[ml_idx2].f_los
     ELSE
      IF ((m_enc->f_low_los_vag > m_enc->qual[ml_idx2].f_los))
       m_enc->f_low_los_vag = m_enc->qual[ml_idx2].f_los
      ENDIF
     ENDIF
    ENDIF
    IF ((m_enc->qual[ml_idx2].n_term_apgar_ind=1))
     m_enc->l_tot_apgar = (m_enc->l_tot_apgar+ 1), m_enc->qual[ml_idx2].l_output_ind = 1, m_enc->
     qual[ml_idx2].s_qual_event = concat(m_enc->qual[ml_idx2].s_qual_event,evaluate(size(m_enc->qual[
        ml_idx2].s_qual_event),0,"Apgar <7",", Apgar <7"))
    ENDIF
    IF ((m_enc->qual[ml_idx2].n_nicu_xfer=1))
     IF (isnumeric(m_enc->qual[ml_idx2].s_delivery_ega) > 0)
      IF (cnvtint(m_enc->qual[ml_idx2].s_delivery_ega) > 37)
       m_enc->l_tot_nicu_xfer = (m_enc->l_tot_nicu_xfer+ 1), m_enc->qual[ml_idx2].l_output_ind = 1,
       m_enc->qual[ml_idx2].s_qual_event = concat(m_enc->qual[ml_idx2].s_qual_event,evaluate(size(
          m_enc->qual[ml_idx2].s_qual_event),0,"NICU Admit",", NICU Admit"))
      ELSE
       m_enc->qual[ml_idx2].n_nicu_xfer = 0
      ENDIF
     ENDIF
    ENDIF
    IF ((m_enc->qual[ml_idx2].n_transfusion_4_unit_ind=1))
     m_enc->l_tot_blood_transf = (m_enc->l_tot_blood_transf+ 1), m_enc->qual[ml_idx2].l_output_ind =
     1, m_enc->qual[ml_idx2].s_qual_event = concat(m_enc->qual[ml_idx2].s_qual_event,evaluate(size(
        m_enc->qual[ml_idx2].s_qual_event),0,"Blood Transfusion",", Blood Transfusion"))
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
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
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea.encntr_alias_type_cd=outerjoin(mf_cs319_mrn_cd))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(e.encntr_id)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea2.encntr_alias_type_cd=outerjoin(mf_cs319_finnbr_cd))
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_enc->qual[d1.seq].s_pat_name = trim(p.name_full_formatted), m_enc->qual[d1.seq].s_pat_mrn = trim
   (ea.alias,3), m_enc->qual[d1.seq].s_fin = trim(ea2.alias,3)
  WITH nocounter
 ;end select
 FREE RECORD m_median
 RECORD m_median(
   1 l_cnt = i4
   1 qual[*]
     2 f_los = f8
 )
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = m_enc->l_cnt)
  PLAN (d1
   WHERE (m_enc->qual[d1.seq].n_dtype_csec=1))
  ORDER BY m_enc->qual[d1.seq].f_los
  DETAIL
   m_median->l_cnt = (m_median->l_cnt+ 1), stat = alterlist(m_median->qual,m_median->l_cnt), m_median
   ->qual[m_median->l_cnt].f_los = m_enc->qual[d1.seq].f_los
  WITH nocounter
 ;end select
 IF ((m_median->l_cnt > 0))
  IF (even(m_median->l_cnt)=1)
   SET ml_idx1 = (m_median->l_cnt/ 2)
   SET ml_idx2 = (ml_idx1+ 1)
   SET m_enc->f_median_los_csec = ((m_median->qual[ml_idx1].f_los+ m_median->qual[ml_idx2].f_los)/
   2.0)
  ELSE
   SET ml_idx1 = (floor((m_median->l_cnt/ 2))+ 1)
   SET m_enc->f_median_los_csec = m_median->qual[ml_idx1].f_los
  ENDIF
 ENDIF
 SET m_median->l_cnt = 0
 SET stat = alterlist(m_median->qual,0)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = m_enc->l_cnt)
  PLAN (d1
   WHERE (m_enc->qual[d1.seq].n_dtype_vag=1))
  ORDER BY m_enc->qual[d1.seq].f_los
  DETAIL
   m_median->l_cnt = (m_median->l_cnt+ 1), stat = alterlist(m_median->qual,m_median->l_cnt), m_median
   ->qual[m_median->l_cnt].f_los = m_enc->qual[d1.seq].f_los
  WITH nocounter
 ;end select
 IF ((m_median->l_cnt > 0))
  IF (even(m_median->l_cnt)=1)
   SET ml_idx1 = (m_median->l_cnt/ 2)
   SET ml_idx2 = (ml_idx1+ 1)
   SET m_enc->f_median_los_vag = ((m_median->qual[ml_idx1].f_los+ m_median->qual[ml_idx2].f_los)/ 2.0
   )
  ELSE
   SET ml_idx1 = (floor((m_median->l_cnt/ 2))+ 1)
   SET m_enc->f_median_los_vag = m_median->qual[ml_idx1].f_los
  ENDIF
 ENDIF
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
    AND ce.event_cd IN (mf_cs72_neonateoutcome_cd, mf_cs72_deliveryphysician_cd,
   mf_cs72_deliverycnm_cd, mf_cs72_datetimeofbirth_cd, mf_cs72_attendingprovider_cd))
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
   IF (ce.event_cd=mf_cs72_neonateoutcome_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_neonate_outcome = trim(ce.result_val,
     3)
   ELSEIF (ce.event_cd=mf_cs72_deliveryphysician_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_del_provider = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_cs72_deliverycnm_cd)
    m_enc->qual[d1.seq].dyn_grp[m_enc->qual[d1.seq].l_dyn_cnt].s_del_cnm = trim(ce.result_val,3)
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
 CALL echorecord(m_enc)
 SET frec->file_name = concat("bhs_rpt_pcm_ob_bundle_",format(sysdate,"MMDDYYYY;;q"),".csv")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build('"OB Bundle","Number","Rate"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = concat('"Total number of deliveries: ','","',trim(cnvtstring(m_enc->l_tot_dtype
    ),3),'"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = concat('"No glucose tolerance testing for non-diabetic mothers: ','","',trim(
   cnvtstring(m_enc->l_tot_gluc_tol),3),'","',evaluate(m_enc->l_tot_gluc_tol,0,"",trim(cnvtstring(((
     cnvtreal(m_enc->l_tot_gluc_tol)/ cnvtreal(m_enc->l_tot_dtype)) * 100.00),20,2),3)),
  '"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = concat('"Group B Strep Status Documented: ','","',trim(cnvtstring(m_enc->
    l_tot_strep_res),3),'","',evaluate(m_enc->l_tot_strep_res,0,"",trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_strep_res)/ cnvtreal(m_enc->l_tot_dtype)) * 100.00),20,2),3)),
  '"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = concat('"Primary C-section : ','","',trim(cnvtstring(m_enc->l_tot_prim_csec),3),
  '","',evaluate(m_enc->l_tot_prim_csec,0,"",trim(cnvtstring(((cnvtreal(m_enc->l_tot_prim_csec)/
     cnvtreal(100)) * 100.00),20,2),3)),
  '"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = concat('"Apgar <7 at 5 min: ','","',trim(cnvtstring(m_enc->l_tot_apgar),3),
  '","',evaluate(m_enc->l_tot_apgar,0,"",trim(cnvtstring(((cnvtreal(m_enc->l_tot_apgar)/ cnvtreal(
      m_enc->l_tot_dtype)) * 100.00),20,2),3)),
  '"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = concat('"NICU Admit > 24 hours in term infants: ','","',trim(cnvtstring(m_enc->
    l_tot_nicu_xfer),3),'","',evaluate(m_enc->l_tot_nicu_xfer,0,"",trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_nicu_xfer)/ cnvtreal(m_enc->l_tot_dtype)) * 100.00),20,2),3)),
  '"',char(13))
 SET stat = cclio("WRITE",frec)
 IF ((m_enc->l_tot_del_vag=0))
  SET frec->file_buf = '"LOS for Vaginal Delivery:"," N/A"'
  SET stat = cclio("WRITE",frec)
 ELSE
  SET frec->file_buf = concat('"LOS for Vaginal Delivery: ",','"(',trim(cnvtstring(((m_enc->
     f_low_los_vag/ 60)/ 24),20,2),3)," days -",trim(cnvtstring(((m_enc->f_high_los_vag/ 60)/ 24),20,
     2),3),
   'days)"," avg = ',trim(cnvtstring((((m_enc->f_tot_los_vag/ 60)/ 24)/ m_enc->l_tot_del_vag),20,2),3
    )," days; median = ",trim(cnvtstring(((m_enc->f_median_los_vag/ 60)/ 24),20,2),3),' days "',
   char(13))
  SET stat = cclio("WRITE",frec)
 ENDIF
 IF ((m_enc->l_tot_del_csec=0))
  SET frec->file_buf = '"LOS for Cesarean Delivery:"," N/A"'
  SET stat = cclio("WRITE",frec)
 ELSE
  SET frec->file_buf = concat('"LOS for Cesarean Delivery: ",','"(',trim(cnvtstring(((m_enc->
     f_low_los_csec/ 60)/ 24),20,2),3)," days -",trim(cnvtstring(((m_enc->f_high_los_csec/ 60)/ 24),
     20,2),3),
   'days)"," avg = ',trim(cnvtstring((((m_enc->f_tot_los_csec/ 60)/ 24)/ m_enc->l_tot_del_csec),20,2),
    3)," days; median = ",trim(cnvtstring(((m_enc->f_median_los_csec/ 60)/ 24),20,2),3),' days"',
   char(13))
  SET stat = cclio("WRITE",frec)
 ENDIF
 SET frec->file_buf = concat('"Blood Transfusion: ','","',trim(cnvtstring(m_enc->l_tot_blood_transf),
   3),'","',evaluate(m_enc->l_tot_blood_transf,0,"",trim(cnvtstring(((cnvtreal(m_enc->
      l_tot_blood_transf)/ cnvtreal(m_enc->l_tot_dtype)) * 100.00),20,2),3)),
  '"',char(13))
 SET stat = cclio("WRITE",frec)
 SET frec->file_buf = concat(char(13),
  '"Patient Name","MRN","Qualifying event","FIN","Delivery provider","Attending Provider"',
  ',"DOB","GA at time of delivery","Infant disposition"',char(13))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_enc->l_cnt)
   IF ((m_enc->qual[ml_idx1].l_output_ind=1))
    SET ms_temp1 = concat('"',m_enc->qual[ml_idx1].s_pat_name,'","',m_enc->qual[ml_idx1].s_pat_mrn,
     '","',
     m_enc->qual[ml_idx1].s_qual_event,'","',m_enc->qual[ml_idx1].s_fin)
    IF ((m_enc->qual[ml_idx1].l_dyn_cnt > 0))
     FOR (ml_idx2 = 1 TO m_enc->qual[ml_idx1].l_dyn_cnt)
       IF (size(m_enc->qual[ml_idx1].dyn_grp[ml_idx2].s_del_provider) > 0)
        SET ms_temp2 = build(ms_temp1,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].s_del_provider)
       ELSEIF (size(m_enc->qual[ml_idx1].dyn_grp[ml_idx2].s_del_cnm) > 0)
        SET ms_temp2 = build(ms_temp1,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].s_del_cnm)
       ELSE
        SET ms_temp2 = build(ms_temp1,'","',m_enc->qual[ml_idx1].s_prim_surgeon)
       ENDIF
       SET frec->file_buf = concat(ms_temp2,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].
        s_attend_provider,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].s_birth_dt,
        '","',m_enc->qual[ml_idx1].s_delivery_ega_full,'","',m_enc->qual[ml_idx1].dyn_grp[ml_idx2].
        s_neonate_outcome,'"',
        char(13))
       SET stat = cclio("WRITE",frec)
     ENDFOR
    ELSE
     SET frec->file_buf = concat(ms_temp1,'","','","','","','","',
      '","','"',char(13))
     SET stat = cclio("WRITE",frec)
    ENDIF
   ENDIF
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 IF (findstring("@",ms_email) > 0)
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("PCM OB Bundle Report: ",format(cnvtdatetime(curdate,curtime3),
    "YYYYMMDDHHMMSS;;q"))
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
#exit_script
END GO
