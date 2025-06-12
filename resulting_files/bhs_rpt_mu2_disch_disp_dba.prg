CREATE PROGRAM bhs_rpt_mu2_disch_disp:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Email to:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_email_to
 FREE RECORD m_pat
 RECORD m_pat(
   1 l_e_disp_cnt = i4
   1 l_e_nodisp_cnt = i4
   1 l_e_dta_cnt = i4
   1 l_e_nodta_cnt = i4
   1 l_pcpe_en_cnt = i4
   1 l_pcpe_pn_cnt = i4
   1 l_pcpe_x_cnt = i4
   1 l_pcpp_en_cnt = i4
   1 l_pcpp_pn_cnt = i4
   1 l_pcpp_x_cnt = i4
   1 pat[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_e_disch_disp_cd = f8
     2 s_e_disch_disp = vc
     2 s_reg_dt_tm = vc
     2 s_disch_dt_tm = vc
     2 f_e_type_class_cd = f8
     2 s_e_type_class = vc
     2 f_pcp_id = f8
     2 s_pcp_username = vc
     2 n_pcp_bmp_ind = i4
     2 dta[*]
       3 f_dta_cd = f8
       3 s_dta_disp = vc
       3 s_dta_val = vc
       3 f_event_id = f8
       3 f_par_event_id = f8
       3 s_form = vc
       3 f_form_id = f8
 ) WITH protect
 FREE RECORD m_cd
 RECORD m_cd(
   1 e_ty[*]
     2 f_cd = f8
     2 s_disp = vc
     2 l_cnt = i4
   1 e_dis[*]
     2 f_cd = f8
     2 s_disp = vc
     2 l_cnt = i4
   1 dta[*]
     2 f_cd = f8
     2 s_disp = vc
     2 l_cnt = i4
     2 val[*]
       3 s_disp = vc
       3 l_cnt = i4
 ) WITH protect
 FREE RECORD m_tmp
 RECORD m_tmp(
   1 e_dis[*]
     2 f_cd = f8
     2 s_disp = vc
     2 l_cnt = i4
   1 dta[*]
     2 f_cd = f8
     2 s_disp = vc
     2 l_cnt = i4
     2 val[*]
       3 s_disp = vc
       3 l_cnt = i4
 ) WITH protect
 FREE RECORD m_out
 RECORD m_out(
   1 out[*]
     2 s_line = vc
 )
 DECLARE ms_output = vc WITH protect, constant(trim( $OUTDEV))
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT)," 00:00:00"))
 DECLARE ms_recipient = vc WITH protect, constant(trim( $S_EMAIL_TO))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_outpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OUTPATIENT"))
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_ed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"EMERGENCY"))
 DECLARE mf_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION"))
 DECLARE mf_day_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"DAYSTAY"))
 DECLARE mf_pcp_epr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"PCP"))
 DECLARE mf_pcp_ppr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE ms_csv_filename = vc WITH protect, constant(concat("josh_mu2_rpt_",trim(format(sysdate,
     "mmddyyhhmmss;;d")),".csv"))
 CALL echo(build2("mf_FIN_CD: ",mf_fin_cd))
 CALL echo(build2("mf_MRN_CD: ",mf_mrn_cd))
 CALL echo(build2("mf_AUTH_CD: ",mf_auth_cd))
 CALL echo(build2("mf_OUTPT_CD: ",mf_outpt_cd))
 CALL echo(build2("mf_INPT_CD: ",mf_inpt_cd))
 CALL echo(build2("mf_ED_CD: ",mf_ed_cd))
 CALL echo(build2("mf_OBS_CD: ",mf_obs_cd))
 CALL echo(build2("mf_PCP_EPR_CD: ",mf_pcp_epr_cd))
 CALL echo(build2("mf_PCP_PPR_CD: ",mf_pcp_ppr_cd))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_p_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_d_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_v_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_out = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=72
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display_key IN ("DISCHARGELEVELOFCAREATDISCHARGE", "DISCHARGENURSINGHOMESREHABFACILITIES",
  "ASSISTEDLIVINGFACILITIES", "DISCHARGEVNAHOSPICEHOMECARE", "DISCHARGEELDERSERVICES",
  "DISCHARGEEARLYINTERVENTIONPROGRAMS", "DISCHARGERESTHOMESRESIDENCESSHELTERS")
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_cd->dta,pl_cnt), m_cd->dta[pl_cnt].s_disp = trim(cv
    .display),
   m_cd->dta[pl_cnt].f_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL echo(ms_beg_dt_tm)
 CALL echo(ms_end_dt_tm)
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   dummyt d,
   clinical_event ce,
   encntr_prsnl_reltn epr,
   prsnl pr,
   person_prsnl_reltn ppr,
   prsnl pr2
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate
    AND e.disch_dt_tm != null
    AND e.encntr_type_class_cd IN (mf_outpt_cd, mf_inpt_cd, mf_ed_cd, mf_obs_cd, mf_day_cd))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.alias != "ATR*"
    AND ea.end_effective_dt_tm > e.reg_dt_tm)
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(e.encntr_id)
    AND epr.encntr_prsnl_r_cd=outerjoin(mf_pcp_epr_cd)
    AND epr.active_ind=outerjoin(1)
    AND epr.end_effective_dt_tm > outerjoin(e.reg_dt_tm))
   JOIN (pr
   WHERE pr.person_id=outerjoin(epr.prsnl_person_id)
    AND pr.active_ind=outerjoin(1))
   JOIN (ppr
   WHERE ppr.person_id=outerjoin(e.person_id)
    AND ppr.person_prsnl_r_cd=outerjoin(mf_pcp_ppr_cd)
    AND ppr.active_ind=outerjoin(1)
    AND ppr.beg_effective_dt_tm <= outerjoin(e.disch_dt_tm)
    AND ppr.end_effective_dt_tm >= outerjoin(e.reg_dt_tm))
   JOIN (pr2
   WHERE pr2.person_id=outerjoin(ppr.prsnl_person_id)
    AND pr2.active_ind=outerjoin(1))
   JOIN (d)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.person_id=e.person_id
    AND ce.event_end_dt_tm > e.reg_dt_tm
    AND ce.valid_until_dt_tm > e.reg_dt_tm
    AND ce.result_status_cd=mf_auth_cd
    AND expand(ml_cnt,1,size(m_cd->dta,5),ce.event_cd,m_cd->dta[ml_cnt].f_cd))
  ORDER BY e.encntr_id, ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   pl_e_cnt = 0, pl_ce_cnt = 0, pl_size = 0
  HEAD e.encntr_id
   pl_ce_cnt = 0, pl_size = 0, pl_e_cnt = (pl_e_cnt+ 1)
   IF (pl_e_cnt > size(m_pat->pat,5))
    stat = alterlist(m_pat->pat,(pl_e_cnt+ 10))
   ENDIF
   ml_idx = locateval(ml_loc,1,size(m_cd->e_ty,5),e.encntr_type_class_cd,m_cd->e_ty[ml_loc].f_cd)
   IF (ml_idx=0)
    pl_size = (size(m_cd->e_ty,5)+ 1), stat = alterlist(m_cd->e_ty,pl_size), ml_idx = pl_size,
    m_cd->e_ty[ml_idx].s_disp = trim(uar_get_code_display(e.encntr_type_class_cd)), m_cd->e_ty[ml_idx
    ].f_cd = e.encntr_type_class_cd
   ENDIF
   m_cd->e_ty[ml_idx].l_cnt = (m_cd->e_ty[ml_idx].l_cnt+ 1)
   IF (e.disch_disposition_cd > 0.0)
    m_pat->pat[pl_e_cnt].s_e_disch_disp = trim(uar_get_code_display(e.disch_disposition_cd)), m_pat->
    pat[pl_e_cnt].f_e_disch_disp_cd = e.disch_disposition_cd, m_pat->l_e_disp_cnt = (m_pat->
    l_e_disp_cnt+ 1),
    ml_idx = locateval(ml_loc,1,size(m_cd->e_dis,5),e.disch_disposition_cd,m_cd->e_dis[ml_loc].f_cd)
    IF (ml_idx=0)
     pl_size = (size(m_cd->e_dis,5)+ 1), stat = alterlist(m_cd->e_dis,pl_size), m_cd->e_dis[pl_size].
     f_cd = e.disch_disposition_cd,
     m_cd->e_dis[pl_size].s_disp = uar_get_code_display(e.disch_disposition_cd), m_cd->e_dis[pl_size]
     .l_cnt = (m_cd->e_dis[pl_size].l_cnt+ 1)
    ELSE
     m_cd->e_dis[ml_idx].l_cnt = (m_cd->e_dis[ml_idx].l_cnt+ 1)
    ENDIF
   ELSE
    m_pat->l_e_nodisp_cnt = (m_pat->l_e_nodisp_cnt+ 1)
   ENDIF
   m_pat->pat[pl_e_cnt].f_person_id = e.person_id, m_pat->pat[pl_e_cnt].f_encntr_id = e.encntr_id,
   m_pat->pat[pl_e_cnt].s_reg_dt_tm = trim(format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d")),
   m_pat->pat[pl_e_cnt].s_disch_dt_tm = trim(format(e.disch_dt_tm,"mm/dd/yy hh:mm;;d")), m_pat->pat[
   pl_e_cnt].f_e_type_class_cd = e.encntr_type_class_cd, m_pat->pat[pl_e_cnt].s_e_type_class = trim(
    uar_get_code_display(e.encntr_type_class_cd)),
   m_pat->pat[pl_e_cnt].f_pcp_id = pr.person_id, m_pat->pat[pl_e_cnt].s_pcp_username = trim(pr
    .username)
   IF (pr.username IN ("EN*", "SPNDEN*"))
    m_pat->pat[pl_e_cnt].n_pcp_bmp_ind = 1, m_pat->l_pcpe_en_cnt = (m_pat->l_pcpe_en_cnt+ 1)
   ELSEIF (pr.username IN ("PN*", "SPNDPN*"))
    m_pat->l_pcpe_pn_cnt = (m_pat->l_pcpe_pn_cnt+ 1)
   ELSE
    m_pat->l_pcpe_x_cnt = (m_pat->l_pcpe_x_cnt+ 1)
   ENDIF
   IF (pr2.username IN ("EN*", "SPNDEN*"))
    IF ((m_pat->pat[pl_e_cnt].n_pcp_bmp_ind=0))
     m_pat->pat[pl_e_cnt].n_pcp_bmp_ind = 2
    ELSE
     m_pat->pat[pl_e_cnt].n_pcp_bmp_ind = 3
    ENDIF
    m_pat->l_pcpp_en_cnt = (m_pat->l_pcpp_en_cnt+ 1)
   ELSEIF (pr2.username IN ("PN*", "SPNDPN*"))
    m_pat->l_pcpp_pn_cnt = (m_pat->l_pcpp_pn_cnt+ 1)
   ELSE
    m_pat->l_pcpp_x_cnt = (m_pat->l_pcpp_x_cnt+ 1)
   ENDIF
  HEAD ce.event_cd
   IF (ce.event_cd <= 0.0)
    m_pat->l_e_nodta_cnt = (m_pat->l_e_nodta_cnt+ 1)
   ELSE
    IF (pl_ce_cnt=0)
     m_pat->l_e_dta_cnt = (m_pat->l_e_dta_cnt+ 1)
    ENDIF
    pl_ce_cnt = (pl_ce_cnt+ 1), stat = alterlist(m_pat->pat[pl_e_cnt].dta,pl_ce_cnt), m_pat->pat[
    pl_e_cnt].dta[pl_ce_cnt].f_dta_cd = ce.event_cd,
    m_pat->pat[pl_e_cnt].dta[pl_ce_cnt].f_event_id = ce.event_id, m_pat->pat[pl_e_cnt].dta[pl_ce_cnt]
    .f_par_event_id = ce.parent_event_id, m_pat->pat[pl_e_cnt].dta[pl_ce_cnt].s_dta_disp = trim(
     uar_get_code_display(ce.event_cd)),
    m_pat->pat[pl_e_cnt].dta[pl_ce_cnt].s_dta_val = trim(ce.result_val)
    IF (textlen(trim(ce.result_val)) > 0)
     ml_idx = locateval(ml_loc,1,size(m_cd->dta,5),ce.event_cd,m_cd->dta[ml_loc].f_cd)
     IF (ml_idx > 0)
      m_cd->dta[ml_idx].l_cnt = (m_cd->dta[ml_idx].l_cnt+ 1), ms_tmp = trim(ce.result_val), ml_idx2
       = locateval(ml_loc,1,size(m_cd->dta[ml_idx].val,5),ms_tmp,m_cd->dta[ml_idx].val[ml_loc].s_disp
       )
      IF (ml_idx2=0)
       pl_size = (size(m_cd->dta[ml_idx].val,5)+ 1), stat = alterlist(m_cd->dta[ml_idx].val,pl_size),
       ml_idx2 = pl_size,
       m_cd->dta[ml_idx].val[ml_idx2].s_disp = ms_tmp
      ENDIF
      m_cd->dta[ml_idx].val[ml_idx2].l_cnt = (m_cd->dta[ml_idx].val[ml_idx2].l_cnt+ 1)
     ELSE
      CALL echo(concat("error - ml_idx should never be 0: ,",ce.result_val))
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(m_pat->pat,pl_e_cnt)
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_pat->pat,5))),
   dummyt d2,
   clinical_event ce1,
   clinical_event ce2
  PLAN (d1
   WHERE maxrec(d2,size(m_pat->pat[d1.seq].dta,5)))
   JOIN (d2
   WHERE d2.seq > 0)
   JOIN (ce1
   WHERE (ce1.event_id=m_pat->pat[d1.seq].dta[d2.seq].f_par_event_id))
   JOIN (ce2
   WHERE ce2.event_id=ce1.parent_event_id)
  ORDER BY d1.seq, d2.seq
  DETAIL
   m_pat->pat[d1.seq].dta[d2.seq].f_form_id = ce2.event_cd, m_pat->pat[d1.seq].dta[d2.seq].s_form =
   trim(uar_get_code_display(ce2.event_cd))
  WITH nocounter
 ;end select
 SET stat = alterlist(m_out->out,16)
 SET m_out->out[1].s_line = concat("Total Encounters ",ms_beg_dt_tm," - ",ms_end_dt_tm,": ,",
  trim(cnvtstring(size(m_pat->pat,5))))
 SET m_out->out[2].s_line = concat(",w   e.disch_disp: ,",trim(cnvtstring(m_pat->l_e_disp_cnt)))
 SET m_out->out[3].s_line = concat(",w/o e.disch_disp: ,",trim(cnvtstring(m_pat->l_e_nodisp_cnt)))
 SET m_out->out[4].s_line = concat(",w   disch dta(s): ,",trim(cnvtstring(m_pat->l_e_dta_cnt)))
 SET m_out->out[5].s_line = concat(",w/o disch dta(s): ,",trim(cnvtstring(m_pat->l_e_nodta_cnt)))
 SET m_out->out[6].s_line = "PCP Info"
 SET m_out->out[7].s_line = ",Person_prsnl_reltn level,,,,,"
 SET m_out->out[8].s_line = concat(",,BMP PCPs (EN SPNDEN): ,",trim(cnvtstring(m_pat->l_pcpp_en_cnt))
  )
 SET m_out->out[9].s_line = concat(",,PN: ,",trim(cnvtstring(m_pat->l_pcpp_pn_cnt)))
 SET m_out->out[10].s_line = concat(",,OTHER: ,",trim(cnvtstring(m_pat->l_pcpp_x_cnt)))
 SET m_out->out[11].s_line = ",Encntr_prsnl_reltn level,,,,,"
 SET m_out->out[12].s_line = concat(",,BMP PCPs (EN SPNDEN): ,",trim(cnvtstring(m_pat->l_pcpe_en_cnt)
   ))
 SET m_out->out[13].s_line = concat(",,PN: ,",trim(cnvtstring(m_pat->l_pcpe_pn_cnt)))
 SET m_out->out[14].s_line = concat(",,OTHER: ,",trim(cnvtstring(m_pat->l_pcpe_x_cnt)))
 SET m_out->out[15].s_line = ",,,,,"
 SET m_out->out[16].s_line = "Encounter TypClass"
 SET ml_out = 16
 FOR (ml_cnt = 1 TO size(m_cd->e_ty,5))
   SET stat = initrec(m_tmp)
   SET ml_out = (ml_out+ 1)
   SET stat = alterlist(m_out->out,ml_out)
   SET m_out->out[ml_out].s_line = concat(",",m_cd->e_ty[ml_cnt].s_disp,": ,",trim(cnvtstring(m_cd->
      e_ty[ml_cnt].l_cnt)))
   FOR (ml_p_cnt = 1 TO size(m_pat->pat,5))
     IF ((m_pat->pat[ml_p_cnt].f_e_type_class_cd=m_cd->e_ty[ml_cnt].f_cd))
      SET ml_idx = locateval(ml_loc,1,size(m_tmp->e_dis,5),m_pat->pat[ml_p_cnt].f_e_disch_disp_cd,
       m_tmp->e_dis[ml_loc].f_cd)
      IF (ml_idx=0)
       SET ml_idx = (size(m_tmp->e_dis,5)+ 1)
       SET stat = alterlist(m_tmp->e_dis,ml_idx)
       SET m_tmp->e_dis[ml_idx].f_cd = m_pat->pat[ml_p_cnt].f_e_disch_disp_cd
       IF ((m_pat->pat[ml_p_cnt].f_e_disch_disp_cd=0.0))
        SET m_tmp->e_dis[ml_idx].s_disp = "*empty*"
       ELSE
        SET m_tmp->e_dis[ml_idx].s_disp = m_pat->pat[ml_p_cnt].s_e_disch_disp
       ENDIF
      ENDIF
      SET m_tmp->e_dis[ml_idx].l_cnt = (m_tmp->e_dis[ml_idx].l_cnt+ 1)
      IF (size(m_pat->pat[ml_p_cnt].dta,5)=0)
       SET ml_idx = locateval(ml_loc,1,size(m_tmp->dta,5),0.0,m_tmp->dta[ml_loc].f_cd)
       IF (ml_idx=0)
        SET ml_idx = (size(m_tmp->dta,5)+ 1)
        SET stat = alterlist(m_tmp->dta,ml_idx)
        SET m_tmp->dta[ml_idx].s_disp = "*empty*"
        SET m_tmp->dta[ml_idx].f_cd = 0.0
       ENDIF
       SET m_tmp->dta[ml_idx].l_cnt = (m_tmp->dta[ml_idx].l_cnt+ 1)
      ELSE
       FOR (ml_d_cnt = 1 TO size(m_pat->pat[ml_p_cnt].dta,5))
         SET ml_idx = locateval(ml_loc,1,size(m_tmp->dta,5),m_pat->pat[ml_p_cnt].dta[ml_d_cnt].
          f_dta_cd,m_tmp->dta[ml_loc].f_cd)
         IF (ml_idx=0)
          SET ml_idx = (size(m_tmp->dta,5)+ 1)
          SET stat = alterlist(m_tmp->dta,ml_idx)
          SET m_tmp->dta[ml_idx].s_disp = m_pat->pat[ml_p_cnt].dta[ml_d_cnt].s_dta_disp
          SET m_tmp->dta[ml_idx].f_cd = m_pat->pat[ml_p_cnt].dta[ml_d_cnt].f_dta_cd
         ENDIF
         SET m_tmp->dta[ml_idx].l_cnt = (m_tmp->dta[ml_idx].l_cnt+ 1)
         SET ml_idx2 = locateval(ml_loc,1,size(m_tmp->dta[ml_idx].val,5),m_pat->pat[ml_p_cnt].dta[
          ml_d_cnt].s_dta_val,m_tmp->dta[ml_idx].val[ml_loc].s_disp)
         IF (ml_idx2=0)
          SET ml_idx2 = (size(m_tmp->dta[ml_idx].val,5)+ 1)
          SET stat = alterlist(m_tmp->dta[ml_idx].val,ml_idx2)
          SET m_tmp->dta[ml_idx].val[ml_idx2].s_disp = m_pat->pat[ml_p_cnt].dta[ml_d_cnt].s_dta_val
         ENDIF
         SET m_tmp->dta[ml_idx].val[ml_idx2].l_cnt = (m_tmp->dta[ml_idx].val[ml_idx2].l_cnt+ 1)
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   IF (size(m_tmp->dta,5)=0)
    SET ml_out = (ml_out+ 1)
    SET stat = alterlist(m_out->out,ml_out)
    SET m_out->out[ml_out].s_line = concat(",,,no dtas")
   ELSE
    SET ml_out = (ml_out+ 1)
    SET stat = alterlist(m_out->out,ml_out)
    SET m_out->out[ml_out].s_line = ",,Encntr Disch Disp"
    FOR (ml_v_cnt = 1 TO size(m_tmp->e_dis,5))
      SET ml_out = (ml_out+ 1)
      SET stat = alterlist(m_out->out,ml_out)
      SET m_out->out[ml_out].s_line = concat(',,,"',m_tmp->e_dis[ml_v_cnt].s_disp,':" ,',trim(
        cnvtstring(m_tmp->e_dis[ml_v_cnt].l_cnt)))
    ENDFOR
    SET ml_out = (ml_out+ 1)
    SET stat = alterlist(m_out->out,ml_out)
    SET m_out->out[ml_out].s_line = ",,DTAs"
    FOR (ml_d_cnt = 1 TO size(m_tmp->dta,5))
      SET ml_out = (ml_out+ 1)
      SET stat = alterlist(m_out->out,ml_out)
      SET m_out->out[ml_out].s_line = concat(',,,"',m_tmp->dta[ml_d_cnt].s_disp,':" ,',trim(
        cnvtstring(m_tmp->dta[ml_d_cnt].l_cnt)))
      IF ((m_tmp->dta[ml_d_cnt].f_cd > 0))
       SET ml_out = (ml_out+ 1)
       SET stat = alterlist(m_out->out,ml_out)
       SET m_out->out[ml_out].s_line = ",,,,Values"
      ENDIF
      FOR (ml_v_cnt = 1 TO size(m_tmp->dta[ml_d_cnt].val,5))
        SET ml_out = (ml_out+ 1)
        SET stat = alterlist(m_out->out,ml_out)
        SET m_out->out[ml_out].s_line = concat(',,,,,"',m_tmp->dta[ml_d_cnt].val[ml_v_cnt].s_disp,
         ': ",',trim(cnvtstring(m_tmp->dta[ml_d_cnt].val[ml_v_cnt].l_cnt)))
      ENDFOR
      SET ml_out = (ml_out+ 1)
      SET stat = alterlist(m_out->out,ml_out)
      SET m_out->out[ml_out].s_line = ",,,,,"
    ENDFOR
   ENDIF
 ENDFOR
 SELECT INTO value(ms_csv_filename)
  FROM (dummyt d  WITH seq = value(size(m_out->out,5)))
  PLAN (d)
  DETAIL
   col 0, m_out->out[d.seq].s_line, row + 1
  WITH nocounter
 ;end select
 IF (textlen(ms_recipient) > 0)
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("MU RPT: ",ms_beg_dt_tm," - ",ms_end_dt_tm)
  CALL emailfile(value(ms_csv_filename),ms_csv_filename,ms_recipient,ms_tmp,1)
  SELECT INTO value(ms_output)
   FROM dummyt d
   HEAD REPORT
    col 0, "report mailed"
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_cd)
 CALL echorecord(m_tmp)
 CALL echorecord(m_pat)
 FREE RECORD m_cd
 FREE RECORD m_pat
END GO
