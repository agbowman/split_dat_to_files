CREATE PROGRAM bhs_rpt_dasa_iv:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, s_start_date, s_end_date
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mf_cs72_dasaivscore_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DASAIVSCORE")),
 protect
 DECLARE mf_cs355_user_def_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",355,
   "USERDEFINED"))
 DECLARE mf_cs356_race1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE mf_cs356_race2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE2"))
 DECLARE mf_cs356_race3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE3"))
 DECLARE mf_cs356_race4 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE4"))
 DECLARE mf_cs356_race5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE5"))
 DECLARE mf_cs220_aptu = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"APTU"))
 DECLARE ml_cntenc = i4 WITH noconstant(0), protect
 DECLARE ml_cntpt = i4 WITH noconstant(0), protect
 DECLARE m_cntpt = i4 WITH noconstant(0), protect
 DECLARE mf_cur_score = f8 WITH noconstant(0.0), protect
 FREE RECORD dasaiv
 RECORD dasaiv(
   1 m_cnt_pat = i4
   1 m_pt_total = i4
   1 f_per_hightot = f8
   1 f_per_medtot = f8
   1 f_per_lowtot = f8
   1 m_cnthightot = i4
   1 m_cntmediumtot = i4
   1 m_cntlowtot = i4
   1 m_cnttot_results = i4
   1 runby = vc
   1 facility = vc
   1 unit = vc
   1 pats[*]
     2 m_cntres = i4
     2 f_pat_tot_score = f8
     2 s_pat = vc
     2 f_avg = f8
     2 m_cnthigh = i4
     2 m_cntmedium = i4
     2 m_cntlow = i4
     2 m_pt_total = i4
     2 f_per_high = f8
     2 f_per_med = f8
     2 f_per_low = f8
     2 det[*]
       3 d_charted = dq8
       3 s_mrn = vc
       3 f_score = f8
 )
 SELECT INTO "NL:"
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
   AND p.person_id > 0
  HEAD p.person_id
   dasaiv->runby = trim(p.name_full_formatted)
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "NL:"
  FROM encounter e,
   person p,
   clinical_event ce,
   encntr_alias mrn,
   dummyt d1
  PLAN (e
   WHERE e.encntr_id > 0
    AND e.loc_nurse_unit_cd=mf_cs220_aptu)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.active_ind=1
    AND sysdate BETWEEN mrn.beg_effective_dt_tm AND mrn.end_effective_dt_tm
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.person_id=p.person_id
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime( $S_START_DATE) AND cnvtdatetime( $S_END_DATE)
    AND ce.event_cd=mf_cs72_dasaivscore_cd
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd)
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (d1
   WHERE cnvtreal(ce.result_val) > 0)
  ORDER BY p.person_id, ce.event_end_dt_tm DESC
  HEAD REPORT
   stat = alterlist(dasaiv->pats,10), dasaiv->unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3
    ), dasaiv->facility = trim(uar_get_code_display(e.loc_facility_cd),3)
  HEAD p.person_id
   dasaiv->m_cnt_pat += 1
   IF (mod(dasaiv->m_cnt_pat,10)=1
    AND (dasaiv->m_cnt_pat > 1))
    stat = alterlist(dasaiv->pats,(dasaiv->m_cnt_pat+ 9))
   ENDIF
   dasaiv->pats[dasaiv->m_cnt_pat].s_pat = trim(p.name_full_formatted,3), stat = alterlist(dasaiv->
    pats[dasaiv->m_cnt_pat].det,10), ml_cntenc = 0
  DETAIL
   ml_cntenc += 1
   IF (mod(ml_cntenc,10)=1
    AND ml_cntenc > 1)
    stat = alterlist(dasaiv->pats[dasaiv->m_cnt_pat].det,(ml_cntenc+ 9))
   ENDIF
   mf_cur_score = cnvtreal(ce.result_val), dasaiv->pats[dasaiv->m_cnt_pat].f_pat_tot_score +=
   mf_cur_score, dasaiv->pats[dasaiv->m_cnt_pat].det[ml_cntenc].d_charted = ce.event_end_dt_tm,
   dasaiv->pats[dasaiv->m_cnt_pat].det[ml_cntenc].s_mrn = trim(mrn.alias,3), dasaiv->pats[dasaiv->
   m_cnt_pat].det[ml_cntenc].f_score = mf_cur_score, dasaiv->pats[dasaiv->m_cnt_pat].m_cntres += 1
   IF (mf_cur_score > 3)
    dasaiv->pats[dasaiv->m_cnt_pat].m_cnthigh += 1, dasaiv->m_cnthightot += 1
   ELSEIF (mf_cur_score >= 2
    AND mf_cur_score <= 3)
    dasaiv->pats[dasaiv->m_cnt_pat].m_cntmedium += 1, dasaiv->m_cntmediumtot += 1
   ELSEIF (mf_cur_score <= 1)
    dasaiv->pats[dasaiv->m_cnt_pat].m_cntlow += 1, dasaiv->m_cntlowtot += 1
   ENDIF
   dasaiv->m_cnttot_results += 1, dasaiv->pats[dasaiv->m_cnt_pat].f_avg = round((dasaiv->pats[dasaiv
    ->m_cnt_pat].f_pat_tot_score/ dasaiv->pats[dasaiv->m_cnt_pat].m_cntres),1)
  FOOT  p.person_id
   stat = alterlist(dasaiv->pats[dasaiv->m_cnt_pat].det,ml_cntenc), ml_cntenc = 0, mf_cur_score = 0.0
  FOOT REPORT
   stat = alterlist(dasaiv->pats,dasaiv->m_cnt_pat), dasaiv->f_per_hightot = round(((cnvtreal(dasaiv
     ->m_cnthightot)/ cnvtreal(dasaiv->m_cnttot_results)) * 100),0), dasaiv->f_per_medtot = round(((
    cnvtreal(dasaiv->m_cntmediumtot)/ cnvtreal(dasaiv->m_cnttot_results)) * 100),0),
   dasaiv->f_per_lowtot = round(((cnvtreal(dasaiv->m_cntlowtot)/ cnvtreal(dasaiv->m_cnttot_results))
     * 100),0)
  WITH nocounter, format, separator = " ",
   time = 60
 ;end select
 EXECUTE bhs_rpt_dasa_iv_lo  $OUTDEV,  $S_START_DATE,  $S_END_DATE
END GO
