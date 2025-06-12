CREATE PROGRAM bhs_rpt_contact_by_prsnl:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Physician last name:" = "ferrick",
  "Prsnl Person ID:" = 0,
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "File type:" = "patient"
  WITH outdev, s_phys_name_last, f_prsnl_id,
  s_beg_dt, s_end_dt, s_file_type
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_person_id = f8
     2 s_cmrn = vc
     2 s_pat_name = vc
     2 s_pat_dob = vc
     2 s_pat_age = vc
     2 s_pat_ph_cell = vc
     2 s_pat_ph_home = vc
     2 s_pat_address1 = vc
     2 s_pat_address2 = vc
     2 s_pat_city = vc
     2 s_pat_state = vc
     2 s_pat_zip = vc
     2 s_chart_access = vc
     2 s_encntr_reltn = vc
     2 s_person_reltn = vc
     2 s_doc = vc
     2 s_ord = vc
     2 s_clin_event = vc
     2 s_surg_attend = vc
     2 access[*]
       3 f_ppa_id = f8
       3 s_access_type = vc
       3 s_access_dt_tm = vc
       3 s_computer = vc
       3 s_caption = vc
     2 p_reltn[*]
       3 s_reltn_type = vc
       3 s_beg_dt_tm = vc
       3 s_end_dt_tm = vc
       3 s_reltn_manual = vc
       3 n_active = i2
     2 e_reltn[*]
       3 s_reltn_type = vc
       3 s_beg_dt_tm = vc
       3 s_end_dt_tm = vc
       3 s_reltn_manual = vc
       3 n_active = i2
       3 f_encntr_id = f8
       3 s_fin = vc
       3 s_enc_type_cls = vc
       3 s_enc_type = vc
       3 s_reg_dt_tm = vc
       3 s_disch_dt_tm = vc
     2 enc[*]
       3 f_encntr_id = f8
       3 f_fac = f8
       3 s_fac = vc
       3 f_nu = f8
       3 s_nu = vc
       3 f_room = f8
       3 s_room = vc
       3 s_fin = vc
       3 s_reltn_to_enc = vc
       3 s_reltn_manual = vc
       3 s_guarantor = vc
       3 s_guardian = vc
       3 s_next_of_kin = vc
       3 s_emergency_contact = vc
       3 s_enc_type_cls = vc
       3 s_enc_type = vc
       3 f_create_dt_tm = f8
       3 f_reg_dt_tm = f8
       3 s_reg_dt_tm = vc
       3 s_disch_dt_tm = vc
       3 doc[*]
         4 f_event_id = f8
         4 f_event_cd = f8
         4 f_event_cls = f8
         4 s_event_cls = vc
         4 s_doc_type = vc
         4 s_doc_name = vc
         4 s_action_type = vc
         4 s_action_dt_tm = vc
         4 s_folder = vc
       3 ord[*]
         4 f_order_id = f8
         4 f_cat_cd = f8
         4 s_mnemonic = vc
         4 s_ord_dt_tm = vc
         4 s_ord_action = vc
         4 s_act_dt_tm = vc
         4 n_fut_ord = i2
       3 ce[*]
         4 f_event_id = f8
         4 f_event_cd = f8
         4 s_event = vc
         4 s_event_dt_tm = vc
         4 s_result_val = vc
       3 surg[*]
         4 f_surg_case_id = f8
         4 s_case_nbr = vc
         4 s_surg_start_dt_tm = vc
         4 s_role_perf = vc
   1 pat_out[*]
     2 f_person_id = f8
     2 s_cmrn = vc
     2 s_pat_name = vc
     2 s_pat_dob = vc
     2 s_pat_age = vc
     2 s_pat_ph_cell = vc
     2 s_pat_ph_home = vc
     2 s_pat_address1 = vc
     2 s_pat_address2 = vc
     2 s_pat_city = vc
     2 s_pat_state = vc
     2 s_pat_zip = vc
     2 s_chart_access = vc
     2 s_encntr_reltn = vc
     2 s_person_reltn = vc
     2 s_doc = vc
     2 s_ord = vc
     2 s_clin_event = vc
     2 s_surg_attend = vc
     2 f_ppa_id = f8
     2 s_access_type = vc
     2 s_access_dt_tm = vc
     2 s_computer = vc
     2 s_caption = vc
     2 s_preltn_type = vc
     2 s_preltn_beg_dt_tm = vc
     2 s_preltn_end_dt_tm = vc
     2 s_preltn_manual = vc
     2 n_preltn_active = i2
     2 s_ereltn_type = vc
     2 s_ereltn_beg_dt_tm = vc
     2 s_ereltn_end_dt_tm = vc
     2 s_ereltn_manual = vc
     2 n_ereltn_active = i2
     2 f_encntr_id = f8
     2 s_fin = vc
     2 s_enc_type_cls = vc
     2 s_enc_type = vc
     2 s_reg_dt_tm = vc
     2 s_disch_dt_tm = vc
   1 enc_out[*]
     2 f_person_id = f8
     2 s_cmrn = vc
     2 s_pat_name = vc
     2 s_pat_dob = vc
     2 s_pat_age = vc
     2 f_encntr_id = f8
     2 f_fac = f8
     2 s_fac = vc
     2 f_nu = f8
     2 s_nu = vc
     2 f_room = f8
     2 s_room = vc
     2 s_fin = vc
     2 s_reltn_to_enc = vc
     2 s_reltn_manual = vc
     2 s_guarantor = vc
     2 s_guardian = vc
     2 s_next_of_kin = vc
     2 s_emergency_contact = vc
     2 s_enc_type_cls = vc
     2 s_enc_type = vc
     2 f_create_dt_tm = f8
     2 f_reg_dt_tm = f8
     2 s_reg_dt_tm = vc
     2 s_disch_dt_tm = vc
     2 f_doc_event_id = f8
     2 f_doc_event_cd = f8
     2 f_doc_event_cls = f8
     2 s_doc_event_cls = vc
     2 s_doc_type = vc
     2 s_doc_name = vc
     2 s_doc_action_type = vc
     2 s_doc_action_dt_tm = vc
     2 s_doc_folder = vc
     2 f_order_id = f8
     2 f_cat_cd = f8
     2 s_mnemonic = vc
     2 s_ord_dt_tm = vc
     2 s_ord_action = vc
     2 s_ord_act_dt_tm = vc
     2 n_fut_ord = i2
     2 f_ce_event_id = f8
     2 f_ce_event_cd = f8
     2 s_ce_event = vc
     2 s_ce_event_dt_tm = vc
     2 s_ce_result_val = vc
     2 f_surg_case_id = f8
     2 s_case_nbr = vc
     2 s_surg_start_dt_tm = vc
     2 s_role_perf = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE mf_prsnl_id = f8 WITH protect, constant(cnvtreal( $F_PRSNL_ID))
 DECLARE ms_file_type = vc WITH protect, constant(trim(cnvtlower( $S_FILE_TYPE),3))
 DECLARE mf_cs4_cmrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs43_ph_cell = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2510010055"))
 DECLARE mf_cs43_ph_home = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4017"))
 DECLARE mf_cs212_addr_home = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4018"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs351_guarantor = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!9519"))
 DECLARE mf_cs351_nxt_kin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!9522"))
 DECLARE mf_cs351_guardian = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17057"))
 DECLARE mf_cs351_emergency = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!6328"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loop1 = i4 WITH protect, noconstant(0)
 DECLARE ml_loop2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loop3 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_acc_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_preltn_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ereltn_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_rows = i4 WITH protect, noconstant(0)
 DECLARE ml_doc_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ce_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_surg_cnt = i4 WITH protect, noconstant(0)
 IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
  SET ms_log = "Both dates must be filled out"
  GO TO exit_script
 ENDIF
 IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
  SET ms_log = "End date must be greater than Beg date"
  GO TO exit_script
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 CALL echo("chart access")
 SELECT INTO "nl:"
  FROM person_prsnl_activity ppa,
   prsnl pr,
   person p
  PLAN (ppa
   WHERE ppa.prsnl_id=mf_prsnl_id
    AND ppa.ppa_first_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (pr
   WHERE pr.person_id=ppa.prsnl_id)
   JOIN (p
   WHERE p.person_id=ppa.person_id)
  ORDER BY ppa.person_id, ppa.ppa_first_dt_tm
  HEAD REPORT
   pl_cnt = 0, pl_acc_cnt = 0
  HEAD ppa.person_id
   pl_acc_cnt = 0, pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat,5))
    CALL alterlist(m_rec->pat,(pl_cnt+ 50))
   ENDIF
   m_rec->pat[pl_cnt].f_person_id = ppa.person_id, m_rec->pat[pl_cnt].s_pat_name = trim(p
    .name_full_formatted,3), m_rec->pat[pl_cnt].s_pat_dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d"
     ),3),
   m_rec->pat[pl_cnt].s_pat_age = trim(cnvtage(p.birth_dt_tm),3), m_rec->pat[pl_cnt].s_chart_access
    = "Yes"
  DETAIL
   pl_acc_cnt += 1,
   CALL alterlist(m_rec->pat[pl_cnt].access,pl_acc_cnt), m_rec->pat[pl_cnt].access[pl_acc_cnt].
   f_ppa_id = ppa.ppa_id,
   m_rec->pat[pl_cnt].access[pl_acc_cnt].s_access_type = trim(uar_get_code_display(ppa.ppa_type_cd),3
    ), m_rec->pat[pl_cnt].access[pl_acc_cnt].s_access_dt_tm = trim(format(ppa.ppa_first_dt_tm,
     "mm/dd/yy hh:mm;;d"),3), m_rec->pat[pl_cnt].access[pl_acc_cnt].s_computer = trim(ppa
    .computer_name,3),
   m_rec->pat[pl_cnt].access[pl_acc_cnt].s_caption = trim(ppa.comp_caption,3)
  FOOT REPORT
   CALL alterlist(m_rec->pat,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("person reltn")
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr,
   person p
  PLAN (ppr
   WHERE ppr.prsnl_person_id=mf_prsnl_id)
   JOIN (p
   WHERE p.person_id=ppr.person_id)
  ORDER BY p.person_id
  HEAD REPORT
   pl_cnt = 0
  HEAD p.person_id
   pl_cnt = 0, ml_idx = locateval(ml_loc,1,size(m_rec->pat,5),p.person_id,m_rec->pat[ml_loc].
    f_person_id)
   IF (ml_idx=0)
    ml_idx = (size(m_rec->pat,5)+ 1),
    CALL alterlist(m_rec->pat,ml_idx), m_rec->pat[ml_idx].f_person_id = p.person_id,
    m_rec->pat[ml_idx].s_pat_name = trim(p.name_full_formatted,3), m_rec->pat[ml_idx].s_pat_dob =
    trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),3), m_rec->pat[ml_idx].s_pat_age = trim(cnvtage(p
      .birth_dt_tm),3)
   ENDIF
   m_rec->pat[ml_idx].s_person_reltn = "Yes"
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->pat[ml_idx].p_reltn,pl_cnt), m_rec->pat[ml_idx].p_reltn[pl_cnt].s_reltn_type
    = trim(uar_get_code_display(ppr.person_prsnl_r_cd),3),
   m_rec->pat[ml_idx].p_reltn[pl_cnt].s_beg_dt_tm = trim(format(ppr.beg_effective_dt_tm,
     "mm/dd/yy hh:mm;;d"),3), m_rec->pat[ml_idx].p_reltn[pl_cnt].s_end_dt_tm = trim(format(ppr
     .end_effective_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec->pat[ml_idx].p_reltn[pl_cnt].n_active = ppr
   .active_ind
   IF (ppr.manual_create_ind=1)
    m_rec->pat[ml_idx].p_reltn[pl_cnt].s_reltn_manual = "Yes"
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("encntr reltn")
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   encounter e,
   person p,
   encntr_alias ea
  PLAN (epr
   WHERE epr.prsnl_person_id=mf_prsnl_id)
   JOIN (e
   WHERE e.encntr_id=epr.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(sysdate))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_cs319_fin)) )
  ORDER BY p.person_id, epr.encntr_id, epr.beg_effective_dt_tm
  HEAD REPORT
   pl_cnt = 0, pl_enc_cnt = 0
  HEAD p.person_id
   pl_cnt = 0, pl_enc_cnt = 0, ml_idx = locateval(ml_loc,1,size(m_rec->pat,5),p.person_id,m_rec->pat[
    ml_loc].f_person_id)
   IF (ml_idx=0)
    ml_idx = (size(m_rec->pat,5)+ 1),
    CALL alterlist(m_rec->pat,ml_idx), m_rec->pat[ml_idx].f_person_id = p.person_id,
    m_rec->pat[ml_idx].s_pat_name = trim(p.name_full_formatted,3), m_rec->pat[ml_idx].s_pat_dob =
    trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),3), m_rec->pat[ml_idx].s_pat_age = trim(cnvtage(p
      .birth_dt_tm),3)
   ENDIF
   m_rec->pat[ml_idx].s_encntr_reltn = "Yes"
  HEAD epr.encntr_id
   pl_enc_cnt += 1
   IF (pl_enc_cnt > size(m_rec->pat[ml_idx].enc,5))
    CALL alterlist(m_rec->pat[ml_idx].enc,(pl_enc_cnt+ 50))
   ENDIF
   m_rec->pat[ml_idx].enc[pl_enc_cnt].f_encntr_id = e.encntr_id, m_rec->pat[ml_idx].enc[pl_enc_cnt].
   f_fac = e.loc_facility_cd, m_rec->pat[ml_idx].enc[pl_enc_cnt].s_fac = trim(uar_get_code_display(e
     .loc_facility_cd),3),
   m_rec->pat[ml_idx].enc[pl_enc_cnt].f_nu = e.loc_nurse_unit_cd, m_rec->pat[ml_idx].enc[pl_enc_cnt].
   s_nu = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), m_rec->pat[ml_idx].enc[pl_enc_cnt].
   f_room = e.loc_room_cd,
   m_rec->pat[ml_idx].enc[pl_enc_cnt].s_room = trim(uar_get_code_display(e.loc_room_cd),3), m_rec->
   pat[ml_idx].enc[pl_enc_cnt].s_fin = trim(ea.alias,3), m_rec->pat[ml_idx].enc[pl_enc_cnt].
   s_reltn_to_enc = trim(uar_get_code_display(epr.encntr_prsnl_r_cd),3)
   IF (epr.manual_create_ind=1)
    m_rec->pat[ml_idx].enc[pl_enc_cnt].s_reltn_manual = "Yes"
   ENDIF
   m_rec->pat[ml_idx].enc[pl_enc_cnt].s_enc_type_cls = trim(uar_get_code_display(e
     .encntr_type_class_cd),3), m_rec->pat[ml_idx].enc[pl_enc_cnt].s_enc_type = trim(
    uar_get_code_display(e.encntr_type_cd),3), m_rec->pat[ml_idx].enc[pl_enc_cnt].f_create_dt_tm = e
   .create_dt_tm,
   m_rec->pat[ml_idx].enc[pl_enc_cnt].f_reg_dt_tm = e.reg_dt_tm, m_rec->pat[ml_idx].enc[pl_enc_cnt].
   s_reg_dt_tm = trim(format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"),3)
   IF (e.disch_dt_tm != null)
    m_rec->pat[ml_idx].enc[pl_enc_cnt].s_disch_dt_tm = trim(format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"),3
     )
   ENDIF
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->pat[ml_idx].e_reltn,pl_cnt), m_rec->pat[ml_idx].e_reltn[pl_cnt].f_encntr_id
    = e.encntr_id,
   m_rec->pat[ml_idx].e_reltn[pl_cnt].s_fin = trim(ea.alias,3), m_rec->pat[ml_idx].e_reltn[pl_cnt].
   s_enc_type_cls = trim(uar_get_code_display(e.encntr_type_class_cd),3), m_rec->pat[ml_idx].e_reltn[
   pl_cnt].s_enc_type = trim(uar_get_code_display(e.encntr_type_cd),3),
   m_rec->pat[ml_idx].e_reltn[pl_cnt].s_reg_dt_tm = trim(format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"),3)
   IF (e.disch_dt_tm != null)
    m_rec->pat[ml_idx].e_reltn[pl_cnt].s_disch_dt_tm = trim(format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"),3
     )
   ENDIF
   m_rec->pat[ml_idx].e_reltn[pl_cnt].s_reltn_type = trim(uar_get_code_display(epr.encntr_prsnl_r_cd),
    3), m_rec->pat[ml_idx].e_reltn[pl_cnt].s_beg_dt_tm = trim(format(epr.beg_effective_dt_tm,
     "mm/dd/yy hh:mm;;d"),3), m_rec->pat[ml_idx].e_reltn[pl_cnt].s_end_dt_tm = trim(format(epr
     .end_effective_dt_tm,"mm/dd/yy hh:mm;;d"),3),
   m_rec->pat[ml_idx].e_reltn[pl_cnt].n_active = epr.active_ind
   IF (epr.manual_create_ind=1)
    m_rec->pat[ml_idx].e_reltn[pl_cnt].s_reltn_manual = "Yes"
   ENDIF
  FOOT  p.person_id
   CALL alterlist(m_rec->pat[ml_idx].enc,pl_enc_cnt)
  WITH nocounter
 ;end select
 CALL echo("doc")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
   dummyt d2,
   ce_event_prsnl cep,
   clinical_event ce
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pat[d1.seq].enc,5)))
   JOIN (d2)
   JOIN (cep
   WHERE (cep.person_id=m_rec->pat[d1.seq].f_person_id)
    AND cep.action_prsnl_id=mf_prsnl_id
    AND cep.action_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND (ce.encntr_id=m_rec->pat[d1.seq].enc[d2.seq].f_encntr_id)
    AND ce.view_level=1)
  ORDER BY d1.seq, d2.seq, cep.event_id,
   cep.action_dt_tm DESC, ce.event_id
  HEAD REPORT
   pl_cnt = 0
  HEAD d1.seq
   null
  HEAD d2.seq
   pl_cnt = 0
  HEAD ce.event_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat[d1.seq].enc[d2.seq].doc,5))
    CALL alterlist(m_rec->pat[d1.seq].enc[d2.seq].doc,(pl_cnt+ 50))
   ENDIF
   m_rec->pat[d1.seq].enc[d2.seq].doc[pl_cnt].f_event_id = cep.event_id, m_rec->pat[d1.seq].enc[d2
   .seq].doc[pl_cnt].f_event_cd = ce.event_cd, m_rec->pat[d1.seq].enc[d2.seq].doc[pl_cnt].f_event_cls
    = ce.event_class_cd,
   m_rec->pat[d1.seq].enc[d2.seq].doc[pl_cnt].s_event_cls = trim(uar_get_code_display(ce
     .event_class_cd),3), m_rec->pat[d1.seq].enc[d2.seq].doc[pl_cnt].s_doc_type = trim(
    uar_get_code_display(ce.event_cd),3), m_rec->pat[d1.seq].enc[d2.seq].doc[pl_cnt].s_doc_name =
   trim(ce.event_title_text,3),
   m_rec->pat[d1.seq].enc[d2.seq].doc[pl_cnt].s_action_type = trim(uar_get_code_display(cep
     .action_type_cd),3), m_rec->pat[d1.seq].enc[d2.seq].doc[pl_cnt].s_action_dt_tm = trim(format(cep
     .action_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec->pat[d1.seq].s_doc = "Yes"
  FOOT  d2.seq
   CALL alterlist(m_rec->pat[d1.seq].enc[d2.seq].doc,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("doc folders")
 FOR (ml_loop1 = 1 TO size(m_rec->pat,5))
   FOR (ml_loop2 = 1 TO size(m_rec->pat[ml_loop1].enc,5))
     IF (size(m_rec->pat[ml_loop1].enc[ml_loop2].doc,5) > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(size(m_rec->pat[ml_loop1].enc[ml_loop2].doc,5))),
        v500_event_set_explode vese
       PLAN (d
        WHERE (m_rec->pat[ml_loop1].enc[ml_loop2].doc[d.seq].f_event_cd > 0.0))
        JOIN (vese
        WHERE (vese.event_cd=m_rec->pat[ml_loop1].enc[ml_loop2].doc[d.seq].f_event_cd)
         AND vese.event_set_level=1)
       ORDER BY d.seq
       HEAD d.seq
        null
       DETAIL
        m_rec->pat[ml_loop1].enc[ml_loop2].doc[d.seq].s_folder = trim(uar_get_code_display(vese
          .event_set_cd),3)
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
 ENDFOR
 CALL echo("orders/actions")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
   dummyt d2,
   orders o,
   order_action oa
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pat[d1.seq].enc,5)))
   JOIN (d2)
   JOIN (o
   WHERE (o.person_id=m_rec->pat[d1.seq].f_person_id)
    AND (o.encntr_id=m_rec->pat[d1.seq].enc[d2.seq].f_encntr_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND oa.action_personnel_id=mf_prsnl_id)
  ORDER BY d1.seq, d2.seq, o.order_id,
   oa.action_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD d1.seq
   pl_cnt = 0
  HEAD d2.seq
   pl_cnt = 0
  HEAD o.order_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat[d1.seq].enc[d2.seq].ord,5))
    CALL alterlist(m_rec->pat[d1.seq].enc[d2.seq].ord,(pl_cnt+ 25))
   ENDIF
   m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].f_order_id = o.order_id, m_rec->pat[d1.seq].enc[d2.seq]
   .ord[pl_cnt].f_cat_cd = o.catalog_cd, m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_mnemonic = trim
   (uar_get_code_display(o.catalog_cd),3),
   m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_ord_dt_tm = trim(format(o.orig_order_dt_tm,
     "mm/dd/yy hh:mm;;d"),3), m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_ord_action = trim(
    uar_get_code_display(oa.action_type_cd),3), m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].
   s_act_dt_tm = trim(format(oa.action_dt_tm,"mm/dd/yy hh:mm;;d"),3),
   m_rec->pat[d1.seq].s_ord = "Yes"
  FOOT  d2.seq
   CALL alterlist(m_rec->pat[d1.seq].enc[d2.seq].ord,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("future orders")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
   dummyt d2,
   orders o,
   order_action oa
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pat[d1.seq].enc,5)))
   JOIN (d2)
   JOIN (o
   WHERE (o.person_id=m_rec->pat[d1.seq].f_person_id)
    AND o.encntr_id=0.0
    AND (o.originating_encntr_id=m_rec->pat[d1.seq].enc[d2.seq].f_encntr_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND oa.action_personnel_id=mf_prsnl_id)
  ORDER BY d1.seq, d2.seq, o.order_id,
   oa.action_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD d1.seq
   pl_cnt = 0
  HEAD d2.seq
   pl_cnt = 0
  HEAD o.order_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat[d1.seq].enc[d2.seq].ord,5))
    CALL alterlist(m_rec->pat[d1.seq].enc[d2.seq].ord,(pl_cnt+ 25))
   ENDIF
   m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].f_order_id = o.order_id, m_rec->pat[d1.seq].enc[d2.seq]
   .ord[pl_cnt].f_cat_cd = o.catalog_cd, m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_mnemonic = trim
   (uar_get_code_display(o.catalog_cd),3),
   m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_ord_dt_tm = trim(format(o.orig_order_dt_tm,
     "mm/dd/yy hh:mm;;d"),3), m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_ord_action = trim(
    uar_get_code_display(oa.action_type_cd),3), m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].
   s_act_dt_tm = trim(format(oa.action_dt_tm,"mm/dd/yy hh:mm;;d"),3),
   m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].n_fut_ord = 1, m_rec->pat[d1.seq].s_ord = "Yes"
  FOOT  d2.seq
   CALL alterlist(m_rec->pat[d1.seq].enc[d2.seq].ord,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("clin events")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
   dummyt d2,
   clinical_event ce
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pat[d1.seq].enc,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.person_id=m_rec->pat[d1.seq].f_person_id)
    AND (ce.encntr_id=m_rec->pat[d1.seq].enc[d2.seq].f_encntr_id)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ((ce.performed_prsnl_id=mf_prsnl_id) OR (ce.updt_id=mf_prsnl_id)) )
  ORDER BY d1.seq, d2.seq, ce.event_id
  HEAD REPORT
   pl_cnt = 0
  HEAD d1.seq
   pl_cnt = 0
  HEAD d2.seq
   pl_cnt = 0
  HEAD ce.event_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat[d1.seq].enc[d2.seq].ce,5))
    CALL alterlist(m_rec->pat[d1.seq].enc[d2.seq].ce,(pl_cnt+ 25))
   ENDIF
   m_rec->pat[d1.seq].enc[d2.seq].ce[pl_cnt].f_event_id = ce.event_id, m_rec->pat[d1.seq].enc[d2.seq]
   .ce[pl_cnt].f_event_cd = ce.event_cd, m_rec->pat[d1.seq].enc[d2.seq].ce[pl_cnt].s_event = trim(
    uar_get_code_display(ce.event_cd),3),
   m_rec->pat[d1.seq].enc[d2.seq].ce[pl_cnt].s_event_dt_tm = trim(format(ce.event_end_dt_tm,
     "mm/dd/yy hh:mm;;d"),3), m_rec->pat[d1.seq].enc[d2.seq].ce[pl_cnt].s_result_val = trim(ce
    .result_val,3), m_rec->pat[d1.seq].s_clin_event = "Yes"
  FOOT  d2.seq
   CALL alterlist(m_rec->pat[d1.seq].enc[d2.seq].ce,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("surg")
 SELECT INTO "nl:"
  FROM case_attendance ca,
   surgical_case sc,
   person p,
   encounter e,
   encntr_prsnl_reltn epr,
   encntr_alias ea
  PLAN (ca
   WHERE ca.case_attendee_id=mf_prsnl_id)
   JOIN (sc
   WHERE sc.surg_case_id=ca.surg_case_id)
   JOIN (p
   WHERE p.person_id=sc.person_id)
   JOIN (e
   WHERE e.encntr_id=sc.encntr_id)
   JOIN (epr
   WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
    AND (epr.prsnl_person_id= Outerjoin(mf_prsnl_id)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(sysdate))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_cs319_fin)) )
  ORDER BY sc.person_id, sc.encntr_id, sc.surg_case_id
  HEAD REPORT
   pl_cnt = 0
  HEAD sc.person_id
   pl_cnt = 0, ml_idx = locateval(ml_loc,1,size(m_rec->pat,5),p.person_id,m_rec->pat[ml_loc].
    f_person_id)
   IF (ml_idx=0)
    ml_idx = (size(m_rec->pat,5)+ 1),
    CALL alterlist(m_rec->pat,ml_idx), m_rec->pat[ml_idx].f_person_id = p.person_id,
    m_rec->pat[ml_idx].s_pat_name = trim(p.name_full_formatted,3), m_rec->pat[ml_idx].s_pat_dob =
    trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),3), m_rec->pat[ml_idx].s_pat_age = trim(cnvtage(p
      .birth_dt_tm),3)
   ENDIF
  HEAD sc.encntr_id
   pl_cnt = 0, ml_idx2 = locateval(ml_loc,1,size(m_rec->pat[ml_idx].enc,5),sc.encntr_id,m_rec->pat[
    ml_idx].enc[ml_loc].f_encntr_id)
   IF (ml_idx2=0)
    ml_idx2 = (size(m_rec->pat[ml_idx].enc,5)+ 1),
    CALL alterlist(m_rec->pat[ml_idx].enc,ml_idx2), m_rec->pat[ml_idx].enc[ml_idx2].f_encntr_id = e
    .encntr_id,
    m_rec->pat[ml_idx].enc[ml_idx2].f_fac = e.loc_facility_cd, m_rec->pat[ml_idx].enc[ml_idx2].s_fac
     = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->pat[ml_idx].enc[ml_idx2].f_nu = e
    .loc_nurse_unit_cd,
    m_rec->pat[ml_idx].enc[ml_idx2].s_nu = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), m_rec->
    pat[ml_idx].enc[ml_idx2].f_room = e.loc_room_cd, m_rec->pat[ml_idx].enc[ml_idx2].s_room = trim(
     uar_get_code_display(e.loc_room_cd),3),
    m_rec->pat[ml_idx].enc[ml_idx2].s_fin = trim(ea.alias,3), m_rec->pat[ml_idx].enc[ml_idx2].
    s_reltn_to_enc = trim(uar_get_code_display(epr.encntr_prsnl_r_cd),3)
   ENDIF
  HEAD sc.surg_case_id
   pl_cnt += 1,
   CALL alterlist(m_rec->pat[ml_idx].enc[ml_idx2].surg,pl_cnt), m_rec->pat[ml_idx].enc[ml_idx2].surg[
   pl_cnt].f_surg_case_id = sc.surg_case_id,
   m_rec->pat[ml_idx].enc[ml_idx2].surg[pl_cnt].s_case_nbr = trim(sc.surg_case_nbr_formatted,3),
   m_rec->pat[ml_idx].enc[ml_idx2].surg[pl_cnt].s_surg_start_dt_tm = trim(format(sc.surg_start_dt_tm,
     "mm/dd/yy hh:mm;;d"),3), m_rec->pat[ml_idx].enc[ml_idx2].surg[pl_cnt].s_role_perf = trim(
    uar_get_code_display(ca.role_perf_cd),3),
   m_rec->pat[ml_idx].s_surg_attend = "Yes"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   person_alias pa
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_id=m_rec->pat[d.seq].f_person_id)
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cs4_cmrn)
  ORDER BY d.seq
  HEAD d.seq
   m_rec->pat[d.seq].s_cmrn = trim(pa.alias,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   phone ph
  PLAN (d)
   JOIN (ph
   WHERE (ph.parent_entity_id=m_rec->pat[d.seq].f_person_id)
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1
    AND ph.phone_type_cd IN (mf_cs43_ph_home, mf_cs43_ph_cell))
  ORDER BY d.seq, ph.phone_type_cd, ph.phone_type_seq
  HEAD d.seq
   null
  HEAD ph.phone_type_cd
   IF (ph.phone_type_cd=mf_cs43_ph_home)
    m_rec->pat[d.seq].s_pat_ph_home = trim(cnvtphone(ph.phone_num_key,ph.phone_format_cd),3)
   ELSEIF (ph.phone_type_cd=mf_cs43_ph_cell)
    m_rec->pat[d.seq].s_pat_ph_cell = trim(cnvtphone(ph.phone_num_key,ph.phone_format_cd),3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   address a
  PLAN (d)
   JOIN (a
   WHERE (a.parent_entity_id=m_rec->pat[d.seq].f_person_id)
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.address_type_cd=mf_cs212_addr_home)
  ORDER BY d.seq, a.address_type_seq
  HEAD d.seq
   m_rec->pat[d.seq].s_pat_address1 = trim(a.street_addr,3), m_rec->pat[d.seq].s_pat_address2 = trim(
    a.street_addr2,3), m_rec->pat[d.seq].s_pat_city = trim(a.city,3),
   m_rec->pat[d.seq].s_pat_state = trim(a.state,3), m_rec->pat[d.seq].s_pat_zip = trim(a.zipcode,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
   dummyt d2,
   encntr_person_reltn epr,
   person p
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pat[d1.seq].enc,5)))
   JOIN (d2)
   JOIN (epr
   WHERE (epr.encntr_id=m_rec->pat[d1.seq].enc[d2.seq].f_encntr_id)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm >= cnvtdatetime(m_rec->pat[d1.seq].enc[d2.seq].f_create_dt_tm)
    AND epr.person_reltn_type_cd IN (mf_cs351_guarantor, mf_cs351_nxt_kin, mf_cs351_guardian,
   mf_cs351_emergency))
   JOIN (p
   WHERE p.person_id=epr.related_person_id)
  ORDER BY d1.seq, d2.seq, epr.person_reltn_type_cd,
   epr.beg_effective_dt_tm DESC
  HEAD d1.seq
   null
  HEAD d2.seq
   null
  HEAD epr.person_reltn_type_cd
   IF (epr.person_reltn_type_cd=mf_cs351_guarantor)
    m_rec->pat[d1.seq].enc[d2.seq].s_guarantor = trim(p.name_full_formatted,3)
   ELSEIF (epr.person_reltn_type_cd=mf_cs351_nxt_kin)
    m_rec->pat[d1.seq].enc[d2.seq].s_next_of_kin = trim(p.name_full_formatted,3)
   ELSEIF (epr.person_reltn_type_cd=mf_cs351_guardian)
    m_rec->pat[d1.seq].enc[d2.seq].s_guardian = trim(p.name_full_formatted,3)
   ELSEIF (epr.person_reltn_type_cd=mf_cs351_emergency)
    m_rec->pat[d1.seq].enc[d2.seq].s_emergency_contact = trim(p.name_full_formatted,3)
   ENDIF
  WITH nocounter
 ;end select
 IF (ms_file_type="patient")
  FOR (ml_loop1 = 1 TO size(m_rec->pat,5))
    SET ml_rows = 0
    SET ml_acc_cnt = size(m_rec->pat[ml_loop1].access,5)
    SET ml_preltn_cnt = size(m_rec->pat[ml_loop1].p_reltn,5)
    SET ml_ereltn_cnt = size(m_rec->pat[ml_loop1].e_reltn,5)
    IF (ml_acc_cnt > ml_preltn_cnt)
     SET ml_rows = ml_acc_cnt
    ELSE
     SET ml_rows = ml_preltn_cnt
    ENDIF
    IF (ml_ereltn_cnt > ml_rows)
     SET ml_rows = ml_ereltn_cnt
    ENDIF
    FOR (ml_loop2 = 1 TO ml_rows)
      SET ml_idx = (size(m_rec->pat_out,5)+ 1)
      CALL alterlist(m_rec->pat_out,ml_idx)
      SET m_rec->pat_out[ml_idx].f_person_id = m_rec->pat[ml_loop1].f_person_id
      SET m_rec->pat_out[ml_idx].s_cmrn = m_rec->pat[ml_loop1].s_cmrn
      SET m_rec->pat_out[ml_idx].s_pat_name = m_rec->pat[ml_loop1].s_pat_name
      SET m_rec->pat_out[ml_idx].s_pat_dob = m_rec->pat[ml_loop1].s_pat_dob
      SET m_rec->pat_out[ml_idx].s_pat_age = m_rec->pat[ml_loop1].s_pat_age
      SET m_rec->pat_out[ml_idx].s_pat_ph_cell = m_rec->pat[ml_loop1].s_pat_ph_cell
      SET m_rec->pat_out[ml_idx].s_pat_ph_home = m_rec->pat[ml_loop1].s_pat_ph_home
      SET m_rec->pat_out[ml_idx].s_pat_address1 = m_rec->pat[ml_loop1].s_pat_address1
      SET m_rec->pat_out[ml_idx].s_pat_address2 = m_rec->pat[ml_loop1].s_pat_address2
      SET m_rec->pat_out[ml_idx].s_pat_city = m_rec->pat[ml_loop1].s_pat_city
      SET m_rec->pat_out[ml_idx].s_pat_state = m_rec->pat[ml_loop1].s_pat_state
      SET m_rec->pat_out[ml_idx].s_pat_zip = m_rec->pat[ml_loop1].s_pat_zip
      SET m_rec->pat_out[ml_idx].s_chart_access = m_rec->pat[ml_loop1].s_chart_access
      SET m_rec->pat_out[ml_idx].s_encntr_reltn = m_rec->pat[ml_loop1].s_encntr_reltn
      SET m_rec->pat_out[ml_idx].s_person_reltn = m_rec->pat[ml_loop1].s_person_reltn
      SET m_rec->pat_out[ml_idx].s_doc = m_rec->pat[ml_loop1].s_doc
      SET m_rec->pat_out[ml_idx].s_ord = m_rec->pat[ml_loop1].s_ord
      SET m_rec->pat_out[ml_idx].s_clin_event = m_rec->pat[ml_loop1].s_clin_event
      SET m_rec->pat_out[ml_idx].s_surg_attend = m_rec->pat[ml_loop1].s_surg_attend
      IF (ml_loop2 <= ml_preltn_cnt)
       SET m_rec->pat_out[ml_idx].s_preltn_type = m_rec->pat[ml_loop1].p_reltn[ml_loop2].s_reltn_type
       SET m_rec->pat_out[ml_idx].s_preltn_beg_dt_tm = m_rec->pat[ml_loop1].p_reltn[ml_loop2].
       s_beg_dt_tm
       SET m_rec->pat_out[ml_idx].s_preltn_end_dt_tm = m_rec->pat[ml_loop1].p_reltn[ml_loop2].
       s_end_dt_tm
       SET m_rec->pat_out[ml_idx].n_preltn_active = m_rec->pat[ml_loop1].p_reltn[ml_loop2].n_active
       SET m_rec->pat_out[ml_idx].s_preltn_manual = m_rec->pat[ml_loop1].p_reltn[ml_loop2].
       s_reltn_manual
      ENDIF
      IF (ml_loop2 <= ml_ereltn_cnt)
       SET m_rec->pat_out[ml_idx].s_ereltn_type = m_rec->pat[ml_loop1].e_reltn[ml_loop2].s_reltn_type
       SET m_rec->pat_out[ml_idx].s_ereltn_beg_dt_tm = m_rec->pat[ml_loop1].e_reltn[ml_loop2].
       s_beg_dt_tm
       SET m_rec->pat_out[ml_idx].s_ereltn_end_dt_tm = m_rec->pat[ml_loop1].e_reltn[ml_loop2].
       s_end_dt_tm
       SET m_rec->pat_out[ml_idx].n_ereltn_active = m_rec->pat[ml_loop1].e_reltn[ml_loop2].n_active
       SET m_rec->pat_out[ml_idx].s_ereltn_manual = m_rec->pat[ml_loop1].e_reltn[ml_loop2].
       s_reltn_manual
       SET m_rec->pat_out[ml_idx].f_encntr_id = m_rec->pat[ml_loop1].e_reltn[ml_loop2].f_encntr_id
       SET m_rec->pat_out[ml_idx].s_fin = m_rec->pat[ml_loop1].e_reltn[ml_loop2].s_fin
       SET m_rec->pat_out[ml_idx].s_enc_type_cls = m_rec->pat[ml_loop1].e_reltn[ml_loop2].
       s_enc_type_cls
       SET m_rec->pat_out[ml_idx].s_enc_type = m_rec->pat[ml_loop1].e_reltn[ml_loop2].s_enc_type
       SET m_rec->pat_out[ml_idx].s_reg_dt_tm = m_rec->pat[ml_loop1].e_reltn[ml_loop2].s_reg_dt_tm
       SET m_rec->pat_out[ml_idx].s_disch_dt_tm = m_rec->pat[ml_loop1].e_reltn[ml_loop2].
       s_disch_dt_tm
      ENDIF
      IF (ml_loop2 <= ml_acc_cnt)
       SET m_rec->pat_out[ml_idx].f_ppa_id = m_rec->pat[ml_loop1].access[ml_loop2].f_ppa_id
       SET m_rec->pat_out[ml_idx].s_access_type = m_rec->pat[ml_loop1].access[ml_loop2].s_access_type
       SET m_rec->pat_out[ml_idx].s_access_dt_tm = m_rec->pat[ml_loop1].access[ml_loop2].
       s_access_dt_tm
       SET m_rec->pat_out[ml_idx].s_computer = m_rec->pat[ml_loop1].access[ml_loop2].s_computer
       SET m_rec->pat_out[ml_idx].s_caption = m_rec->pat[ml_loop1].access[ml_loop2].s_caption
      ENDIF
    ENDFOR
  ENDFOR
  CALL echo("create person level file")
  SELECT INTO value( $OUTDEV)
   cerner_pid = m_rec->pat_out[d.seq].f_person_id, cmrn = substring(1,25,m_rec->pat_out[d.seq].s_cmrn
    ), pat_name = substring(1,75,m_rec->pat_out[d.seq].s_pat_name),
   pat_dob = m_rec->pat_out[d.seq].s_pat_dob, pat_age = substring(1,10,m_rec->pat_out[d.seq].
    s_pat_age), pat_phone_cell = substring(1,15,m_rec->pat_out[d.seq].s_pat_ph_cell),
   pat_phone_home = substring(1,15,m_rec->pat_out[d.seq].s_pat_ph_home), pat_addr1 = substring(1,50,
    m_rec->pat_out[d.seq].s_pat_address1), pat_addr2 = substring(1,50,m_rec->pat_out[d.seq].
    s_pat_address2),
   pat_city = substring(1,20,m_rec->pat_out[d.seq].s_pat_city), pat_state = substring(1,10,m_rec->
    pat_out[d.seq].s_pat_state), pat_zip = substring(1,8,m_rec->pat_out[d.seq].s_pat_zip),
   accessed_pat_chart = substring(1,3,m_rec->pat_out[d.seq].s_chart_access), has_encounter_reltn =
   substring(1,3,m_rec->pat_out[d.seq].s_encntr_reltn), has_person_reltn = substring(1,3,m_rec->
    pat_out[d.seq].s_person_reltn),
   documented_on_chart = substring(1,3,m_rec->pat_out[d.seq].s_doc), has_order_actions = substring(1,
    3,m_rec->pat_out[d.seq].s_ord), has_clinical_events = substring(1,3,m_rec->pat_out[d.seq].
    s_clin_event),
   attended_surgery = substring(1,3,m_rec->pat_out[d.seq].s_surg_attend), emr_accessed_id = m_rec->
   pat_out[d.seq].f_ppa_id, emr_access_type = substring(1,10,m_rec->pat_out[d.seq].s_access_type),
   emr_access_dt_tm = m_rec->pat_out[d.seq].s_access_dt_tm, emr_access_computer = substring(1,20,
    m_rec->pat_out[d.seq].s_computer), emr_access_caption = substring(1,75,m_rec->pat_out[d.seq].
    s_caption),
   person_reltn_type = substring(1,50,m_rec->pat_out[d.seq].s_preltn_type), person_reltn_beg_dt_tm =
   m_rec->pat_out[d.seq].s_preltn_beg_dt_tm, person_reltn_end_dt_tm = m_rec->pat_out[d.seq].
   s_preltn_end_dt_tm,
   person_reltn_active = m_rec->pat_out[d.seq].n_preltn_active, person_reltn_manual_create =
   substring(1,3,m_rec->pat_out[d.seq].s_preltn_manual), encntr_reltn_type = substring(1,50,m_rec->
    pat_out[d.seq].s_ereltn_type),
   encntr_reltn_beg_dt_tm = m_rec->pat_out[d.seq].s_ereltn_beg_dt_tm, encntr_reltn_end_dt_tm = m_rec
   ->pat_out[d.seq].s_ereltn_end_dt_tm, encntr_reltn_active = m_rec->pat_out[d.seq].n_ereltn_active,
   encntr_reltn_manual_create = substring(1,3,m_rec->pat_out[d.seq].s_ereltn_manual),
   cerner_encounter_id = m_rec->pat_out[d.seq].f_encntr_id, encntr_fin = substring(1,20,m_rec->
    pat_out[d.seq].s_fin),
   encntr_type_class = substring(1,20,m_rec->pat_out[d.seq].s_enc_type_cls), encntr_type = substring(
    1,20,m_rec->pat_out[d.seq].s_enc_type), encntr_reg_dt_tm = m_rec->pat_out[d.seq].s_reg_dt_tm,
   encntr_disch_dt_tm = m_rec->pat_out[d.seq].s_disch_dt_tm
   FROM (dummyt d  WITH seq = value(size(m_rec->pat_out,5)))
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ENDIF
 IF (ms_file_type="encounter")
  FOR (ml_loop1 = 1 TO size(m_rec->pat,5))
    FOR (ml_loop2 = 1 TO size(m_rec->pat[ml_loop1].enc,5))
      SET ml_rows = 0
      SET ml_doc_cnt = size(m_rec->pat[ml_loop1].enc[ml_loop2].doc,5)
      SET ml_ord_cnt = size(m_rec->pat[ml_loop1].enc[ml_loop2].ord,5)
      SET ml_ce_cnt = size(m_rec->pat[ml_loop1].enc[ml_loop2].ce,5)
      SET ml_surg_cnt = size(m_rec->pat[ml_loop1].enc[ml_loop2].surg,5)
      IF (ml_doc_cnt > ml_ord_cnt)
       SET ml_rows = ml_doc_cnt
      ELSE
       SET ml_rows = ml_ord_cnt
      ENDIF
      IF (ml_ce_cnt > ml_rows)
       SET ml_rows = ml_ce_cnt
      ENDIF
      IF (ml_surg_cnt > ml_rows)
       SET ml_rows = ml_surg_cnt
      ENDIF
      IF (ml_rows=0)
       SET ml_rows = 1
      ENDIF
      FOR (ml_loop3 = 1 TO ml_rows)
        SET ml_idx = (size(m_rec->enc_out,5)+ 1)
        CALL alterlist(m_rec->enc_out,ml_idx)
        SET m_rec->enc_out[ml_idx].f_person_id = m_rec->pat[ml_loop1].f_person_id
        SET m_rec->enc_out[ml_idx].s_cmrn = m_rec->pat[ml_loop1].s_cmrn
        SET m_rec->enc_out[ml_idx].s_pat_name = m_rec->pat[ml_loop1].s_pat_name
        SET m_rec->enc_out[ml_idx].s_pat_dob = m_rec->pat[ml_loop1].s_pat_dob
        SET m_rec->enc_out[ml_idx].s_pat_age = m_rec->pat[ml_loop1].s_pat_age
        SET m_rec->enc_out[ml_idx].f_encntr_id = m_rec->pat[ml_loop1].enc[ml_loop2].f_encntr_id
        SET m_rec->enc_out[ml_idx].f_fac = m_rec->pat[ml_loop1].enc[ml_loop2].f_fac
        SET m_rec->enc_out[ml_idx].s_fac = m_rec->pat[ml_loop1].enc[ml_loop2].s_fac
        SET m_rec->enc_out[ml_idx].f_nu = m_rec->pat[ml_loop1].enc[ml_loop2].f_nu
        SET m_rec->enc_out[ml_idx].s_nu = m_rec->pat[ml_loop1].enc[ml_loop2].s_nu
        SET m_rec->enc_out[ml_idx].f_room = m_rec->pat[ml_loop1].enc[ml_loop2].f_room
        SET m_rec->enc_out[ml_idx].s_room = m_rec->pat[ml_loop1].enc[ml_loop2].s_room
        SET m_rec->enc_out[ml_idx].s_fin = m_rec->pat[ml_loop1].enc[ml_loop2].s_fin
        SET m_rec->enc_out[ml_idx].s_reltn_to_enc = m_rec->pat[ml_loop1].enc[ml_loop2].s_reltn_to_enc
        SET m_rec->enc_out[ml_idx].s_reltn_manual = m_rec->pat[ml_loop1].enc[ml_loop2].s_reltn_manual
        SET m_rec->enc_out[ml_idx].s_guarantor = m_rec->pat[ml_loop1].enc[ml_loop2].s_guarantor
        SET m_rec->enc_out[ml_idx].s_guardian = m_rec->pat[ml_loop1].enc[ml_loop2].s_guardian
        SET m_rec->enc_out[ml_idx].s_next_of_kin = m_rec->pat[ml_loop1].enc[ml_loop2].s_next_of_kin
        SET m_rec->enc_out[ml_idx].s_emergency_contact = m_rec->pat[ml_loop1].enc[ml_loop2].
        s_emergency_contact
        SET m_rec->enc_out[ml_idx].s_enc_type_cls = m_rec->pat[ml_loop1].enc[ml_loop2].s_enc_type_cls
        SET m_rec->enc_out[ml_idx].s_enc_type = m_rec->pat[ml_loop1].enc[ml_loop2].s_enc_type
        SET m_rec->enc_out[ml_idx].f_create_dt_tm = m_rec->pat[ml_loop1].enc[ml_loop2].f_create_dt_tm
        SET m_rec->enc_out[ml_idx].f_reg_dt_tm = m_rec->pat[ml_loop1].enc[ml_loop2].f_reg_dt_tm
        SET m_rec->enc_out[ml_idx].s_reg_dt_tm = m_rec->pat[ml_loop1].enc[ml_loop2].s_reg_dt_tm
        SET m_rec->enc_out[ml_idx].s_disch_dt_tm = m_rec->pat[ml_loop1].enc[ml_loop2].s_disch_dt_tm
        IF (ml_loop3 <= ml_doc_cnt)
         SET m_rec->enc_out[ml_idx].f_doc_event_id = m_rec->pat[ml_loop1].enc[ml_loop2].doc[ml_loop3]
         .f_event_id
         SET m_rec->enc_out[ml_idx].f_doc_event_cd = m_rec->pat[ml_loop1].enc[ml_loop2].doc[ml_loop3]
         .f_event_cd
         SET m_rec->enc_out[ml_idx].f_doc_event_cls = m_rec->pat[ml_loop1].enc[ml_loop2].doc[ml_loop3
         ].f_event_cls
         SET m_rec->enc_out[ml_idx].s_doc_event_cls = m_rec->pat[ml_loop1].enc[ml_loop2].doc[ml_loop3
         ].s_event_cls
         SET m_rec->enc_out[ml_idx].s_doc_type = m_rec->pat[ml_loop1].enc[ml_loop2].doc[ml_loop3].
         s_doc_type
         SET m_rec->enc_out[ml_idx].s_doc_name = m_rec->pat[ml_loop1].enc[ml_loop2].doc[ml_loop3].
         s_doc_name
         SET m_rec->enc_out[ml_idx].s_doc_action_type = m_rec->pat[ml_loop1].enc[ml_loop2].doc[
         ml_loop3].s_action_type
         SET m_rec->enc_out[ml_idx].s_doc_action_dt_tm = m_rec->pat[ml_loop1].enc[ml_loop2].doc[
         ml_loop3].s_action_dt_tm
         SET m_rec->enc_out[ml_idx].s_doc_folder = m_rec->pat[ml_loop1].enc[ml_loop2].doc[ml_loop3].
         s_folder
        ENDIF
        IF (ml_loop3 <= ml_ord_cnt)
         SET m_rec->enc_out[ml_idx].f_order_id = m_rec->pat[ml_loop1].enc[ml_loop2].ord[ml_loop3].
         f_order_id
         SET m_rec->enc_out[ml_idx].f_cat_cd = m_rec->pat[ml_loop1].enc[ml_loop2].ord[ml_loop3].
         f_cat_cd
         SET m_rec->enc_out[ml_idx].s_mnemonic = m_rec->pat[ml_loop1].enc[ml_loop2].ord[ml_loop3].
         s_mnemonic
         SET m_rec->enc_out[ml_idx].s_ord_dt_tm = m_rec->pat[ml_loop1].enc[ml_loop2].ord[ml_loop3].
         s_ord_dt_tm
         SET m_rec->enc_out[ml_idx].s_ord_action = m_rec->pat[ml_loop1].enc[ml_loop2].ord[ml_loop3].
         s_ord_action
         SET m_rec->enc_out[ml_idx].s_ord_act_dt_tm = m_rec->pat[ml_loop1].enc[ml_loop2].ord[ml_loop3
         ].s_act_dt_tm
         SET m_rec->enc_out[ml_idx].n_fut_ord = m_rec->pat[ml_loop1].enc[ml_loop2].ord[ml_loop3].
         n_fut_ord
        ENDIF
        IF (ml_loop3 <= ml_ce_cnt)
         SET m_rec->enc_out[ml_idx].f_ce_event_id = m_rec->pat[ml_loop1].enc[ml_loop2].ce[ml_loop3].
         f_event_id
         SET m_rec->enc_out[ml_idx].f_ce_event_cd = m_rec->pat[ml_loop1].enc[ml_loop2].ce[ml_loop3].
         f_event_cd
         SET m_rec->enc_out[ml_idx].s_ce_event = m_rec->pat[ml_loop1].enc[ml_loop2].ce[ml_loop3].
         s_event
         SET m_rec->enc_out[ml_idx].s_ce_event_dt_tm = m_rec->pat[ml_loop1].enc[ml_loop2].ce[ml_loop3
         ].s_event_dt_tm
         SET m_rec->enc_out[ml_idx].s_ce_result_val = m_rec->pat[ml_loop1].enc[ml_loop2].ce[ml_loop3]
         .s_result_val
        ENDIF
        IF (ml_loop3 <= ml_surg_cnt)
         SET m_rec->enc_out[ml_idx].f_surg_case_id = m_rec->pat[ml_loop1].enc[ml_loop2].surg[ml_loop3
         ].f_surg_case_id
         SET m_rec->enc_out[ml_idx].s_case_nbr = m_rec->pat[ml_loop1].enc[ml_loop2].surg[ml_loop3].
         s_case_nbr
         SET m_rec->enc_out[ml_idx].s_surg_start_dt_tm = m_rec->pat[ml_loop1].enc[ml_loop2].surg[
         ml_loop3].s_surg_start_dt_tm
         SET m_rec->enc_out[ml_idx].s_role_perf = m_rec->pat[ml_loop1].enc[ml_loop2].surg[ml_loop3].
         s_role_perf
        ENDIF
      ENDFOR
    ENDFOR
  ENDFOR
  CALL echo("create encntr level file")
  SELECT INTO value( $OUTDEV)
   cerner_pid = m_rec->enc_out[d.seq].f_person_id, cmrn = substring(1,25,m_rec->enc_out[d.seq].s_cmrn
    ), pat_name = substring(1,75,m_rec->enc_out[d.seq].s_pat_name),
   pat_dob = m_rec->enc_out[d.seq].s_pat_dob, pat_age = substring(1,10,m_rec->enc_out[d.seq].
    s_pat_age), cerner_encntr_id = m_rec->enc_out[d.seq].f_encntr_id,
   facility = substring(1,20,m_rec->enc_out[d.seq].s_fac), nurse_unit = substring(1,20,m_rec->
    enc_out[d.seq].s_nu), room = substring(1,10,m_rec->enc_out[d.seq].s_room),
   fin = substring(1,20,m_rec->enc_out[d.seq].s_fin), provider_reltn_to_encounter = substring(1,25,
    m_rec->enc_out[d.seq].s_reltn_to_enc), reltn_manual_create = substring(1,30,m_rec->enc_out[d.seq]
    .s_reltn_manual),
   encntr_guarantor = substring(1,75,m_rec->enc_out[d.seq].s_guarantor), pat_guardian = substring(1,
    75,m_rec->enc_out[d.seq].s_guardian), pat_next_of_kin = substring(1,75,m_rec->enc_out[d.seq].
    s_next_of_kin),
   pat_emergency_contact = substring(1,75,m_rec->enc_out[d.seq].s_emergency_contact),
   encntr_type_class = substring(1,25,m_rec->enc_out[d.seq].s_enc_type_cls), encntr_type = substring(
    1,25,m_rec->enc_out[d.seq].s_enc_type),
   reg_dt_tm = m_rec->enc_out[d.seq].s_reg_dt_tm, disch_dt_tm = m_rec->enc_out[d.seq].s_disch_dt_tm,
   document_event_id = m_rec->enc_out[d.seq].f_doc_event_id,
   document_event_cd = m_rec->enc_out[d.seq].f_doc_event_cd, document_event_class = substring(1,20,
    m_rec->enc_out[d.seq].s_doc_event_cls), document_type = substring(1,25,m_rec->enc_out[d.seq].
    s_doc_type),
   document_name = substring(1,50,m_rec->enc_out[d.seq].s_doc_name), document_action = substring(1,20,
    m_rec->enc_out[d.seq].s_doc_action_type), document_action_dt_tm = m_rec->enc_out[d.seq].
   s_doc_action_dt_tm,
   document_folder = substring(1,75,m_rec->enc_out[d.seq].s_doc_folder), cerner_order_id = m_rec->
   enc_out[d.seq].f_order_id, order_mnemnonic = substring(1,50,m_rec->enc_out[d.seq].s_mnemonic),
   order_dt_tm = m_rec->enc_out[d.seq].s_ord_dt_tm, order_action = substring(1,20,m_rec->enc_out[d
    .seq].s_ord_action), order_action_dt_tm = m_rec->enc_out[d.seq].s_ord_act_dt_tm,
   future_order = m_rec->enc_out[d.seq].n_fut_ord, clin_event_id = m_rec->enc_out[d.seq].
   f_ce_event_id, clin_event_cd = m_rec->enc_out[d.seq].f_ce_event_cd,
   clin_event = substring(1,75,m_rec->enc_out[d.seq].s_ce_event), clin_event_dt_tm = m_rec->enc_out[d
   .seq].s_ce_event_dt_tm, clin_event_result = substring(1,75,m_rec->enc_out[d.seq].s_ce_result_val),
   surg_case_id = m_rec->enc_out[d.seq].f_surg_case_id, surg_case_number = substring(1,30,m_rec->
    enc_out[d.seq].s_case_nbr), surg_start_dt_tm = m_rec->enc_out[d.seq].s_surg_start_dt_tm,
   surg_role_performed = substring(1,30,m_rec->enc_out[d.seq].s_role_perf)
   FROM (dummyt d  WITH seq = value(size(m_rec->enc_out,5)))
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
