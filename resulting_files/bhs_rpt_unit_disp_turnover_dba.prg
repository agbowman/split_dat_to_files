CREATE PROGRAM bhs_rpt_unit_disp_turnover:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date Time:" = "SYSDATE",
  "End Date Time" = "SYSDATE"
  WITH outdev, s_beg_dt_tm, s_end_dt_tm
 FREE RECORD m_rec
 RECORD m_rec(
   1 unit[*]
     2 f_fac_cd = f8
     2 f_unit_cd = f8
     2 s_unit_disp = vc
     2 l_admit_cnt = i4
     2 l_xfer_in_cnt = i4
     2 l_xfer_out_cnt = i4
     2 l_disch_cnt = i4
     2 enc[*]
       3 f_encntr_id = f8
       3 s_unit_beg = vc
       3 s_unit_end = vc
       3 f_prv_unit_cd = f8
       3 s_prv_unit_disp = vc
       3 s_prv_unit_beg = vc
       3 s_prv_unit_end = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(trim( $S_BEG_DT_TM,3))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(trim( $S_END_DT_TM,3))
 DECLARE mf_cs71_inpat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_cs71_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION"))
 DECLARE mf_cs71_dayst_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 IF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, "Begin Date must be before End Date"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   encntr_loc_hist elh
  PLAN (ed
   WHERE ed.active_ind=1
    AND ed.beg_effective_dt_tm <= cnvtdatetime(ms_end_dt_tm)
    AND ed.end_effective_dt_tm >= cnvtdatetime(ms_beg_dt_tm))
   JOIN (elh
   WHERE elh.encntr_id=ed.encntr_id
    AND elh.active_ind=1
    AND elh.beg_effective_dt_tm <= cnvtdatetime(ms_end_dt_tm)
    AND elh.end_effective_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND elh.encntr_type_cd != 679661.00)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.active_ind=1
    AND e.encntr_type_cd IN (mf_cs71_inpat_cd, mf_cs71_obs_cd, mf_cs71_dayst_cd))
  ORDER BY elh.loc_nurse_unit_cd, elh.beg_effective_dt_tm DESC
  HEAD REPORT
   pl_unit_cnt = 0, pl_elh_cnt = 0
  HEAD elh.loc_nurse_unit_cd
   pl_elh_cnt = 0, pl_unit_cnt += 1
   IF (pl_unit_cnt > size(m_rec->unit,5))
    CALL alterlist(m_rec->unit,pl_unit_cnt)
   ENDIF
   m_rec->unit[pl_unit_cnt].f_fac_cd = elh.loc_facility_cd, m_rec->unit[pl_unit_cnt].f_unit_cd = elh
   .loc_nurse_unit_cd, m_rec->unit[pl_unit_cnt].s_unit_disp = trim(uar_get_code_display(elh
     .loc_nurse_unit_cd),3)
  DETAIL
   IF (elh.beg_effective_dt_tm=e.reg_dt_tm)
    m_rec->unit[pl_unit_cnt].l_admit_cnt += 1
   ELSE
    m_rec->unit[pl_unit_cnt].l_xfer_in_cnt += 1
   ENDIF
   IF (e.disch_dt_tm != null
    AND e.loc_nurse_unit_cd=elh.loc_nurse_unit_cd)
    m_rec->unit[pl_unit_cnt].l_disch_cnt += 1
   ELSEIF (e.disch_dt_tm != null
    AND e.end_effective_dt_tm < e.disch_dt_tm)
    m_rec->unit[pl_unit_cnt].l_xfer_out_cnt += 1
   ELSEIF (e.disch_dt_tm=null
    AND e.loc_nurse_unit_cd != elh.loc_nurse_unit_cd)
    m_rec->unit[pl_unit_cnt].l_xfer_out_cnt += 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  nurse_unit = m_rec->unit[d.seq].s_unit_disp, admit_cnt = m_rec->unit[d.seq].l_admit_cnt,
  xfer_in_cnt = m_rec->unit[d.seq].l_xfer_in_cnt,
  xfer_out_cnt = m_rec->unit[d.seq].l_xfer_out_cnt, disch_cnt = m_rec->unit[d.seq].l_disch_cnt
  FROM (dummyt d  WITH seq = value(size(m_rec->unit,5)))
  ORDER BY nurse_unit
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
