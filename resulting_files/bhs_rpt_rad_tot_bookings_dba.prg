CREATE PROGRAM bhs_rpt_rad_tot_bookings:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 mod[*]
     2 s_modality = vc
     2 l_mod_cnt = i4
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE mf_cs14232_book_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!6153"))
 DECLARE mf_cs14250_pat_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8846"))
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  se.appt_type_cd, type = uar_get_code_display(se.appt_type_cd)
  FROM sch_appt sa,
   sch_event se,
   sch_event_action sea
  PLAN (sea
   WHERE sea.action_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND sea.version_dt_tm > sysdate
    AND sea.sch_action_cd=mf_cs14232_book_cd)
   JOIN (se
   WHERE se.sch_event_id=sea.sch_event_id
    AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (sa
   WHERE sa.sch_event_id=se.sch_event_id
    AND sa.sch_role_cd=mf_cs14250_pat_cd
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY se.sch_event_id
  HEAD REPORT
   pl_cnt = 0, pl_tot_cnt = 0, pl_cnt = 1,
   CALL alterlist(m_rec->mod,1), m_rec->mod[1].s_modality = "Total Bookings"
  HEAD se.sch_event_id
   m_rec->mod[1].l_mod_cnt = (m_rec->mod[1].l_mod_cnt+ 1), ml_pos = findstring(" ",trim(
     uar_get_code_display(se.appt_type_cd),3),1)
   IF (ml_pos > 0)
    ms_tmp = substring(1,(ml_pos - 1),trim(uar_get_code_display(se.appt_type_cd),3))
    IF (ms_tmp IN ("MM", "CT", "US", "MRI", "XR",
    "NM"))
     ml_idx = locateval(ml_loc,1,size(m_rec->mod,5),ms_tmp,m_rec->mod[ml_loc].s_modality)
     IF (ml_idx=0)
      pl_cnt = (pl_cnt+ 1),
      CALL alterlist(m_rec->mod,pl_cnt), m_rec->mod[pl_cnt].s_modality = ms_tmp,
      ml_idx = pl_cnt
     ENDIF
     m_rec->mod[ml_idx].l_mod_cnt = (m_rec->mod[ml_idx].l_mod_cnt+ 1)
    ENDIF
   ENDIF
  FOOT REPORT
   CALL echo(build2("total count: ",m_rec->mod[1].l_mod_cnt))
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  modality = m_rec->mod[d.seq].s_modality, count = m_rec->mod[d.seq].l_mod_cnt
  FROM (dummyt d  WITH seq = value(size(m_rec->mod,5)))
  ORDER BY d.seq
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
