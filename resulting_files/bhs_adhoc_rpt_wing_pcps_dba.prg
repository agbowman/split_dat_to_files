CREATE PROGRAM bhs_adhoc_rpt_wing_pcps:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_person_id = f8
     2 s_name_full = vc
     2 s_cmrn = vc
     2 s_wing_fins = vc
     2 s_mrn = vc
     2 l_wing_encntrs = i4
     2 per_pcp[*]
       3 s_reltn_disp = vc
       3 s_beg_dt_tm = vc
       3 s_end_dt_tm = vc
       3 s_pcp_name = vc
       3 f_pcp_id = f8
       3 f_updt_id = f8
       3 s_updt_by = vc
       3 s_contrib_sys = vc
 ) WITH protect
 DECLARE mf_ppr_pcp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 CALL echo(build2("mf_PPR_PCP_CD: ",mf_ppr_pcp_cd))
 CALL echo(build2("mf_FIN_CD: ",mf_fin_cd))
 CALL echo(build2("mf_MRN_CD: ",mf_mrn_cd))
 CALL echo(build2("mf_CMRN_CD: ",mf_cmrn_cd))
 CALL echo(buidl2("mf_AUTH_CD: ",mf_auth_cd))
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr,
   encounter e,
   person p,
   person_alias pa1,
   person_alias pa2,
   encntr_alias ea
  PLAN (ppr
   WHERE ppr.person_prsnl_r_cd=mf_ppr_pcp_cd
    AND ppr.updt_id=589895.00
    AND ppr.prsnl_person_id=7075993
    AND ppr.beg_effective_dt_tm BETWEEN cnvtdatetime("08-SEP-2015 00:00:00") AND cnvtdatetime(
    "11-SEP-2015 23:59:59"))
   JOIN (p
   WHERE p.person_id=ppr.person_id)
   JOIN (pa1
   WHERE pa1.person_id=p.person_id
    AND pa1.active_ind=1
    AND pa1.person_alias_type_cd=mf_cmrn_cd
    AND pa1.end_effective_dt_tm > sysdate)
   JOIN (e
   WHERE e.person_id=ppr.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.alias="V*")
   JOIN (pa2
   WHERE pa2.person_id=outerjoin(p.person_id)
    AND pa2.active_ind=outerjoin(1)
    AND pa2.person_alias_type_cd=outerjoin(mf_mrn_cd)
    AND pa2.alias="M*"
    AND pa2.end_effective_dt_tm > outerjoin(sysdate))
  ORDER BY ppr.person_id, e.encntr_id, ea.beg_effective_dt_tm
  HEAD REPORT
   pl_pat_cnt = 0, pl_enc_cnt = 0, pl_ea_cnt = 0
  HEAD ppr.person_id
   pl_enc_cnt = 0, pl_ea_cnt = 0, pl_pat_cnt = (pl_pat_cnt+ 1),
   CALL alterlist(m_rec->pat,pl_pat_cnt), m_rec->pat[pl_pat_cnt].f_person_id = p.person_id, m_rec->
   pat[pl_pat_cnt].s_name_full = trim(p.name_full_formatted),
   m_rec->pat[pl_pat_cnt].s_cmrn = trim(pa1.alias), m_rec->pat[pl_pat_cnt].s_mrn = trim(pa2.alias)
  HEAD e.encntr_id
   pl_enc_cnt = (pl_enc_cnt+ 1)
  HEAD ea.encntr_id
   IF (textlen(trim(m_rec->pat[pl_pat_cnt].s_wing_fins,3)) > 0)
    m_rec->pat[pl_pat_cnt].s_wing_fins = concat(m_rec->pat[pl_pat_cnt].s_wing_fins,";")
   ENDIF
   m_rec->pat[pl_pat_cnt].s_wing_fins = concat(m_rec->pat[pl_pat_cnt].s_wing_fins,trim(ea.alias,3))
  FOOT  ea.encntr_id
   null
  FOOT  e.encntr_id
   null
  FOOT  ppr.person_id
   m_rec->pat[pl_pat_cnt].l_wing_encntrs = pl_enc_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   person_prsnl_reltn ppr,
   person_name pn1,
   person_name pn2
  PLAN (d)
   JOIN (ppr
   WHERE (ppr.person_id=m_rec->pat[d.seq].f_person_id)
    AND ppr.person_prsnl_r_cd=mf_ppr_pcp_cd)
   JOIN (pn1
   WHERE pn1.person_id=ppr.prsnl_person_id
    AND pn1.end_effective_dt_tm > sysdate
    AND pn1.active_ind=1
    AND pn1.data_status_cd=mf_auth_cd)
   JOIN (pn2
   WHERE pn2.person_id=ppr.updt_id
    AND pn2.end_effective_dt_tm > sysdate
    AND pn2.active_ind=1
    AND pn2.data_status_cd=mf_auth_cd)
  ORDER BY d.seq, ppr.beg_effective_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD d.seq
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1),
   CALL alterlist(m_rec->pat[d.seq].per_pcp,pl_cnt), m_rec->pat[d.seq].per_pcp[pl_cnt].s_reltn_disp
    = trim(uar_get_code_display(ppr.person_prsnl_r_cd)),
   m_rec->pat[d.seq].per_pcp[pl_cnt].s_beg_dt_tm = trim(format(ppr.beg_effective_dt_tm,
     "mm/dd/yy hh:mm;;d")), m_rec->pat[d.seq].per_pcp[pl_cnt].s_end_dt_tm = trim(format(ppr
     .end_effective_dt_tm,"mm/dd/yy hh:mm;;d")), m_rec->pat[d.seq].per_pcp[pl_cnt].f_pcp_id = ppr
   .prsnl_person_id,
   m_rec->pat[d.seq].per_pcp[pl_cnt].s_pcp_name = concat(trim(pn1.name_last,3)," ",trim(pn1
     .name_suffix,3),", ",trim(pn1.name_first,3)), m_rec->pat[d.seq].per_pcp[pl_cnt].f_updt_id = ppr
   .updt_id, m_rec->pat[d.seq].per_pcp[pl_cnt].s_updt_by = concat(trim(pn2.name_last,3)," ",trim(pn2
     .name_suffix,3),", ",trim(pn2.name_first,3)),
   m_rec->pat[d.seq].per_pcp[pl_cnt].s_contrib_sys = trim(uar_get_code_display(ppr
     .contributor_system_cd))
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  patient_person_id = m_rec->pat[d1.seq].f_person_id, patient_name = substring(1,50,m_rec->pat[d1.seq
   ].s_name_full), cmrn = substring(1,15,m_rec->pat[d1.seq].s_cmrn),
  wing_fins = substring(1,1000,m_rec->pat[d1.seq].s_wing_fins), mrn = substring(1,15,m_rec->pat[d1
   .seq].s_mrn), wing_encntr_count = m_rec->pat[d1.seq].l_wing_encntrs,
  relationship = m_rec->pat[d1.seq].per_pcp[d2.seq].s_reltn_disp, beg_dt_tm = substring(1,20,m_rec->
   pat[d1.seq].per_pcp[d2.seq].s_beg_dt_tm), end_dt_tm = substring(1,20,m_rec->pat[d1.seq].per_pcp[d2
   .seq].s_end_dt_tm),
  pcp_name = substring(1,50,m_rec->pat[d1.seq].per_pcp[d2.seq].s_pcp_name), pcp_id = m_rec->pat[d1
  .seq].per_pcp[d2.seq].f_pcp_id, updt_id = m_rec->pat[d1.seq].per_pcp[d2.seq].f_updt_id,
  updt_prsnl = substring(1,50,m_rec->pat[d1.seq].per_pcp[d2.seq].s_updt_by), contributor_system =
  substring(1,50,m_rec->pat[d1.seq].per_pcp[d2.seq].s_contrib_sys)
  FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
   dummyt d2
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pat[d1.seq].per_pcp,5)))
   JOIN (d2)
  WITH nocounter, format, separator = " ",
   maxcol = 1, format(date,"dd/mm/yy hh:mm;;d")
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
