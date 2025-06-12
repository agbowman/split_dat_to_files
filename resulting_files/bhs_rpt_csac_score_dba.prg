CREATE PROGRAM bhs_rpt_csac_score:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Score Create Date Start:" = "CURDATE",
  "Score Create Date End:" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_cs72_csac_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COLUMBIASUICIDEASSESSMENTCALC"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs71_disches_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES"))
 DECLARE mf_cs71_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"
   ))
 DECLARE mf_cs71_expiredes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES"
   ))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 s_pat_disch_fac = vc
     2 s_pat_disch_enc_type = vc
     2 s_mrn = vc
     2 l_include_ind = i4
     2 f_reg_dt = dq8
     2 f_disch_dt = dq8
     2 l_rcnt = i4
     2 rqual[*]
       3 f_clin_event_id = f8
       3 s_result = vc
       3 s_clinsig_updt_dt = vc
       3 s_result_stats = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   code_value cv,
   person p,
   encntr_alias ea
  PLAN (ce
   WHERE ce.event_cd=mf_cs72_csac_cd
    AND ce.view_level=1
    AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
   mf_cs8_modified_cd)
    AND trim(ce.event_tag,3) != "Date\Time Correction")
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=e.loc_facility_cd
    AND cv.code_set=220
    AND cv.display_key IN ("BWH", "BWHINPTPSYCH")
    AND cv.cdf_meaning="FACILITY"
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_mrn_cd)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].
   s_mrn = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_pat_disch_enc_type = trim(
    uar_get_code_display(e.encntr_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_pat_disch_fac = trim(uar_get_code_display(e.loc_facility_cd),3)
   IF (e.encntr_type_cd IN (mf_cs71_disches_cd, mf_cs71_emergency_cd, mf_cs71_expiredes_cd))
    m_rec->qual[m_rec->l_cnt].f_disch_dt = e.disch_dt_tm, m_rec->qual[m_rec->l_cnt].f_reg_dt = e
    .reg_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_loc_hist elh,
   code_value cv
  PLAN (e
   WHERE expand(ml_idx1,1,m_rec->l_cnt,e.encntr_id,m_rec->qual[ml_idx1].f_encntr_id))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.active_ind=1
    AND elh.encntr_type_cd IN (mf_cs71_disches_cd, mf_cs71_emergency_cd, mf_cs71_expiredes_cd))
   JOIN (cv
   WHERE cv.code_value=elh.loc_nurse_unit_cd
    AND cv.code_set=220
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND cv.display_key IN ("EMERDEPTBWING", "EMERTRIAGEWING", "EMERGTRIAGEBMLH", "EMERGENCYROOM",
   "EDHOLD"))
  ORDER BY e.encntr_id, elh.beg_effective_dt_tm
  HEAD e.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,e.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].l_include_ind = 1, m_rec->qual[ml_idx2].f_reg_dt = e.reg_dt_tm
    IF (e.encntr_type_cd IN (mf_cs71_disches_cd, mf_cs71_emergency_cd, mf_cs71_expiredes_cd))
     m_rec->qual[ml_idx2].f_disch_dt = e.disch_dt_tm
    ENDIF
    IF ( NOT (e.encntr_type_cd IN (mf_cs71_disches_cd, mf_cs71_emergency_cd, mf_cs71_expiredes_cd)))
     m_rec->qual[ml_idx2].f_reg_dt = elh.beg_effective_dt_tm
    ENDIF
   ENDIF
  DETAIL
   IF (ml_idx2 > 0)
    IF ( NOT (e.encntr_type_cd IN (mf_cs71_disches_cd, mf_cs71_emergency_cd, mf_cs71_expiredes_cd)))
     m_rec->qual[ml_idx2].f_disch_dt = elh.end_effective_dt_tm
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e
  PLAN (ce
   WHERE expand(ml_idx1,1,m_rec->l_cnt,ce.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
    AND ce.event_cd=mf_cs72_csac_cd
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
   mf_cs8_modified_cd)
    AND trim(ce.event_tag,3) != "Date\Time Correction")
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id)
  ORDER BY ce.encntr_id, ce.clinsig_updt_dt_tm
  HEAD ce.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,ce.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
  DETAIL
   IF (ml_idx2 > 0)
    IF ((m_rec->qual[ml_idx2].l_include_ind=1))
     IF (((e.encntr_type_cd IN (mf_cs71_disches_cd, mf_cs71_emergency_cd, mf_cs71_expiredes_cd)) OR (
     (m_rec->qual[ml_idx2].f_disch_dt=0))) )
      m_rec->qual[ml_idx2].l_rcnt += 1, stat = alterlist(m_rec->qual[ml_idx2].rqual,m_rec->qual[
       ml_idx2].l_rcnt), m_rec->qual[ml_idx2].rqual[m_rec->qual[ml_idx2].l_rcnt].f_clin_event_id = ce
      .clinical_event_id,
      m_rec->qual[ml_idx2].rqual[m_rec->qual[ml_idx2].l_rcnt].s_clinsig_updt_dt = format(ce
       .clinsig_updt_dt_tm,";;q"), m_rec->qual[ml_idx2].rqual[m_rec->qual[ml_idx2].l_rcnt].s_result
       = trim(ce.result_val,3), m_rec->qual[ml_idx2].rqual[m_rec->qual[ml_idx2].l_rcnt].
      s_result_stats = trim(uar_get_code_display(ce.result_status_cd),3)
     ELSE
      IF (ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(m_rec->qual[ml_idx2].f_reg_dt) AND cnvtdatetime(
       m_rec->qual[ml_idx2].f_disch_dt))
       m_rec->qual[ml_idx2].l_rcnt += 1, stat = alterlist(m_rec->qual[ml_idx2].rqual,m_rec->qual[
        ml_idx2].l_rcnt), m_rec->qual[ml_idx2].rqual[m_rec->qual[ml_idx2].l_rcnt].f_clin_event_id =
       ce.clinical_event_id,
       m_rec->qual[ml_idx2].rqual[m_rec->qual[ml_idx2].l_rcnt].s_clinsig_updt_dt = format(ce
        .clinsig_updt_dt_tm,";;q"), m_rec->qual[ml_idx2].rqual[m_rec->qual[ml_idx2].l_rcnt].s_result
        = trim(ce.result_val,3), m_rec->qual[ml_idx2].rqual[m_rec->qual[ml_idx2].l_rcnt].
       s_result_stats = trim(uar_get_code_display(ce.result_status_cd),3)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO  $OUTDEV
  patient_name = trim(substring(1,125,m_rec->qual[d.seq].s_pat_name),3), mrn = trim(substring(1,30,
    m_rec->qual[d.seq].s_mrn),3), encntr_facility = trim(substring(1,80,m_rec->qual[d.seq].
    s_pat_disch_fac),3),
  current_encntr_type = trim(substring(1,80,m_rec->qual[d.seq].s_pat_disch_enc_type),3), ed_reg_dt =
  trim(format(cnvtdatetime(m_rec->qual[d.seq].f_reg_dt),";;q"),3), ed_disch_dt = trim(format(
    cnvtdatetime(m_rec->qual[d.seq].f_disch_dt),";;q"),3),
  columbia_suicide_assessment_score = trim(substring(1,30,m_rec->qual[d.seq].rqual[d2.seq].s_result),
   3), columbia_suicide_assessment_score_status = trim(substring(1,30,m_rec->qual[d.seq].rqual[d2.seq
    ].s_result_stats),3), columbia_suicide_assessment_score_clinsig_dt = trim(substring(1,30,m_rec->
    qual[d.seq].rqual[d2.seq].s_clinsig_updt_dt),3)
  FROM (dummyt d  WITH seq = m_rec->l_cnt),
   dummyt d2
  PLAN (d
   WHERE maxrec(d2,m_rec->qual[d.seq].l_rcnt)
    AND (m_rec->qual[d.seq].l_include_ind=1))
   JOIN (d2)
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
