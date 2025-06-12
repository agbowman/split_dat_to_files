CREATE PROGRAM bhs_rpt_sofa_score_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE mf_cs8_auth = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_mod = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs8_alter = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs72_sofa_calc = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SOFACALCULATED"))
 DECLARE mf_cs89_mill_obj = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,
   "MILLENNIUMOBJECTS"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO value( $OUTDEV)
  begin_dt_tm = ms_beg_dt_tm, end_dt_tm = ms_end_dt_tm, sofa_scores_calculated = count(*)
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.event_cd=mf_cs72_sofa_calc
    AND ce.contributor_system_cd=mf_cs89_mill_obj
    AND ce.result_status_cd IN (mf_cs8_auth, mf_cs8_mod, mf_cs8_alter)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ce.valid_until_dt_tm > sysdate)
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
