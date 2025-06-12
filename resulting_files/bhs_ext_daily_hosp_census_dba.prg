CREATE PROGRAM bhs_ext_daily_hosp_census:dba
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs71_inpatient_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3958"))
 DECLARE mf_cs71_observation_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17613"
   ))
 DECLARE mf_cs71_emergency_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3957"))
 DECLARE mf_cs220_mock_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"MOCK"))
 DECLARE ms_tmp_dt = vc WITH protect, noconstant("")
 DECLARE ms_loc_dt = vc WITH protect, noconstant("")
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
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx4 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx_exit = i4 WITH protect, noconstant(0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_fin = vc
     2 s_cmrn = vc
     2 s_admit_dt = vc
     2 f_admit_dt = f8
     2 s_disch_dt = vc
     2 f_disch_dt = f8
     2 s_encntr_type = vc
     2 f_deceased_dt = f8
     2 s_deceased_dt = vc
     2 s_facility = vc
     2 s_unit_at_disch = vc
     2 s_last_unit_enc_hist = vc
     2 s_last_unit_beg_dt = vc
     2 s_last_unit_end_dt = vc
   1 l_dcnt = i4
   1 dqual[*]
     2 s_dt = vc
     2 l_ecnt = i4
     2 equal[*]
       3 f_encntr_id = f8
       3 s_encntr_type = vc
       3 s_beg_effective_dt = vc
       3 l_cencus_ind = i4
       3 l_use_disch = i4
       3 l_use_decease = i4
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 SET ml_idx1 = 0
 WHILE (datetimeadd(mf_start_dt,ml_idx1) <= cnvtdatetime(mf_stop_dt))
   SET m_rec->l_dcnt += 1
   SET stat = alterlist(m_rec->dqual,m_rec->l_dcnt)
   SET m_rec->dqual[m_rec->l_dcnt].s_dt = trim(format(datetimeadd(mf_start_dt,ml_idx1),
     "MM/DD/YYYY;;q"),3)
   SET ml_idx1 += 1
   IF (ml_idx1 > 400)
    GO TO exit_script
   ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_loc_hist elh,
   person p,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND e.active_ind=1
    AND e.loc_facility_cd != mf_cs220_mock_cd)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.encntr_type_cd IN (mf_cs71_inpatient_cd, mf_cs71_observation_cd, mf_cs71_emergency_cd)
    AND elh.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].f_disch_dt = e
   .disch_dt_tm, m_rec->qual[m_rec->l_cnt].s_disch_dt = trim(format(e.disch_dt_tm,"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].f_admit_dt = e.reg_dt_tm, m_rec->qual[m_rec->l_cnt].s_admit_dt = trim(
    format(e.reg_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec->l_cnt].s_encntr_type = trim(
    uar_get_code_display(e.encntr_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_fin = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_cmrn = trim(pa
    .alias,3), m_rec->qual[m_rec->l_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3),
   m_rec->qual[m_rec->l_cnt].s_unit_at_disch = trim(uar_get_code_display(e.loc_nurse_unit_cd),3),
   m_rec->qual[m_rec->l_cnt].f_deceased_dt = p.deceased_dt_tm, m_rec->qual[m_rec->l_cnt].
   s_deceased_dt = trim(format(p.deceased_dt_tm,"MM/DD/YYYY;;q"),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_loc_hist elh,
   person p,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND e.active_ind=1
    AND e.loc_facility_cd != mf_cs220_mock_cd
    AND  NOT (expand(ml_idx1,1,m_rec->l_cnt,e.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.encntr_type_cd IN (mf_cs71_inpatient_cd, mf_cs71_observation_cd, mf_cs71_emergency_cd)
    AND elh.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].f_disch_dt = e
   .disch_dt_tm, m_rec->qual[m_rec->l_cnt].s_disch_dt = trim(format(e.disch_dt_tm,"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].f_admit_dt = e.reg_dt_tm, m_rec->qual[m_rec->l_cnt].s_admit_dt = trim(
    format(e.reg_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec->l_cnt].s_encntr_type = trim(
    uar_get_code_display(e.encntr_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_fin = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_cmrn = trim(pa
    .alias,3), m_rec->qual[m_rec->l_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3),
   m_rec->qual[m_rec->l_cnt].s_unit_at_disch = trim(uar_get_code_display(e.loc_nurse_unit_cd),3),
   m_rec->qual[m_rec->l_cnt].f_deceased_dt = p.deceased_dt_tm, m_rec->qual[m_rec->l_cnt].
   s_deceased_dt = trim(format(p.deceased_dt_tm,"MM/DD/YYYY;;q"),3)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_loc_hist elh,
   person p,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE cnvtdatetime(mf_start_dt) BETWEEN e.reg_dt_tm AND e.disch_dt_tm
    AND e.active_ind=1
    AND e.loc_facility_cd != mf_cs220_mock_cd
    AND  NOT (expand(ml_idx1,1,m_rec->l_cnt,e.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.encntr_type_cd IN (mf_cs71_inpatient_cd, mf_cs71_observation_cd, mf_cs71_emergency_cd)
    AND elh.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].f_disch_dt = e
   .disch_dt_tm, m_rec->qual[m_rec->l_cnt].s_disch_dt = trim(format(e.disch_dt_tm,"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].f_admit_dt = e.reg_dt_tm, m_rec->qual[m_rec->l_cnt].s_admit_dt = trim(
    format(e.reg_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec->l_cnt].s_encntr_type = trim(
    uar_get_code_display(e.encntr_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_fin = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_cmrn = trim(pa
    .alias,3), m_rec->qual[m_rec->l_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3),
   m_rec->qual[m_rec->l_cnt].s_unit_at_disch = trim(uar_get_code_display(e.loc_nurse_unit_cd),3),
   m_rec->qual[m_rec->l_cnt].f_deceased_dt = p.deceased_dt_tm, m_rec->qual[m_rec->l_cnt].
   s_deceased_dt = trim(format(p.deceased_dt_tm,"MM/DD/YYYY;;q"),3)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_loc_hist elh,
   person p,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE cnvtdatetime(mf_stop_dt) BETWEEN e.reg_dt_tm AND e.disch_dt_tm
    AND e.active_ind=1
    AND e.loc_facility_cd != mf_cs220_mock_cd
    AND  NOT (expand(ml_idx1,1,m_rec->l_cnt,e.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.encntr_type_cd IN (mf_cs71_inpatient_cd, mf_cs71_observation_cd, mf_cs71_emergency_cd)
    AND elh.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].f_disch_dt = e
   .disch_dt_tm, m_rec->qual[m_rec->l_cnt].s_disch_dt = trim(format(e.disch_dt_tm,"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].f_admit_dt = e.reg_dt_tm, m_rec->qual[m_rec->l_cnt].s_admit_dt = trim(
    format(e.reg_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec->l_cnt].s_encntr_type = trim(
    uar_get_code_display(e.encntr_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_fin = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_cmrn = trim(pa
    .alias,3), m_rec->qual[m_rec->l_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3),
   m_rec->qual[m_rec->l_cnt].s_unit_at_disch = trim(uar_get_code_display(e.loc_nurse_unit_cd),3),
   m_rec->qual[m_rec->l_cnt].f_deceased_dt = p.deceased_dt_tm, m_rec->qual[m_rec->l_cnt].
   s_deceased_dt = trim(format(p.deceased_dt_tm,"MM/DD/YYYY;;q"),3)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_loc_hist elh,
   person p,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE e.disch_dt_tm = null
    AND e.reg_dt_tm IS NOT null
    AND e.active_ind=1
    AND e.loc_facility_cd != mf_cs220_mock_cd
    AND e.encntr_type_cd IN (mf_cs71_inpatient_cd, mf_cs71_observation_cd, mf_cs71_emergency_cd)
    AND  NOT (expand(ml_idx1,1,m_rec->l_cnt,e.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.encntr_type_cd IN (mf_cs71_inpatient_cd, mf_cs71_observation_cd, mf_cs71_emergency_cd)
    AND elh.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].f_disch_dt = e
   .disch_dt_tm, m_rec->qual[m_rec->l_cnt].s_disch_dt = trim(format(e.disch_dt_tm,"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].f_admit_dt = e.reg_dt_tm, m_rec->qual[m_rec->l_cnt].s_admit_dt = trim(
    format(e.reg_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec->l_cnt].s_encntr_type = trim(
    uar_get_code_display(e.encntr_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_fin = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_cmrn = trim(pa
    .alias,3), m_rec->qual[m_rec->l_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3),
   m_rec->qual[m_rec->l_cnt].s_unit_at_disch = trim(uar_get_code_display(e.loc_nurse_unit_cd),3),
   m_rec->qual[m_rec->l_cnt].f_deceased_dt = p.deceased_dt_tm, m_rec->qual[m_rec->l_cnt].
   s_deceased_dt = trim(format(p.deceased_dt_tm,"MM/DD/YYYY;;q"),3)
  WITH nocounter, expand = 1
 ;end select
 SET ml_idx_exit = 0
 WHILE (datetimeadd(mf_start_dt,ml_idx_exit) <= cnvtdatetime(mf_stop_dt))
   SET ms_loc_dt = format(datetimeadd(mf_start_dt,ml_idx_exit),"MM/DD/YYYY;;q")
   SET ms_tmp_dt = format(datetimeadd(mf_start_dt,ml_idx_exit),"DD-MMM-YYYY 23:59:59;;q")
   SET ml_idx3 = locateval(ml_idx2,1,m_rec->l_dcnt,ms_loc_dt,m_rec->dqual[ml_idx2].s_dt)
   SELECT INTO "nl:"
    FROM encntr_loc_hist elh
    PLAN (elh
     WHERE expand(ml_idx2,1,m_rec->l_cnt,elh.encntr_id,m_rec->qual[ml_idx2].f_encntr_id)
      AND elh.active_ind=1
      AND cnvtdatetime(ms_tmp_dt) BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
    ORDER BY elh.encntr_id, elh.beg_effective_dt_tm, elh.encntr_loc_hist_id
    DETAIL
     IF (ml_idx3 > 0
      AND elh.encntr_type_cd IN (mf_cs71_inpatient_cd, mf_cs71_observation_cd, mf_cs71_emergency_cd))
      ml_idx1 = locateval(ml_idx2,1,m_rec->dqual[ml_idx3].l_ecnt,elh.encntr_id,m_rec->dqual[ml_idx3].
       equal[ml_idx2].f_encntr_id)
      IF (ml_idx1=0)
       m_rec->dqual[ml_idx3].l_ecnt += 1, stat = alterlist(m_rec->dqual[ml_idx3].equal,m_rec->dqual[
        ml_idx3].l_ecnt), m_rec->dqual[ml_idx3].equal[m_rec->dqual[ml_idx3].l_ecnt].f_encntr_id = elh
       .encntr_id,
       m_rec->dqual[ml_idx3].equal[m_rec->dqual[ml_idx3].l_ecnt].l_cencus_ind = 1, m_rec->dqual[
       ml_idx3].equal[m_rec->dqual[ml_idx3].l_ecnt].s_beg_effective_dt = format(elh
        .beg_effective_dt_tm,"MM/DD/YYYY;;q"), m_rec->dqual[ml_idx3].equal[m_rec->dqual[ml_idx3].
       l_ecnt].s_encntr_type = trim(uar_get_code_display(elh.encntr_type_cd),3)
      ENDIF
     ENDIF
     ml_idx1 = locateval(ml_idx2,1,m_rec->l_cnt,elh.encntr_id,m_rec->qual[ml_idx2].f_encntr_id)
     IF (ml_idx1 > 0)
      m_rec->qual[ml_idx1].s_last_unit_beg_dt = format(elh.beg_effective_dt_tm,";;q"), m_rec->qual[
      ml_idx1].s_last_unit_end_dt = format(elh.end_effective_dt_tm,";;q"), m_rec->qual[ml_idx1].
      s_last_unit_enc_hist = trim(uar_get_code_display(elh.loc_nurse_unit_cd),3)
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   SET ml_idx_exit += 1
   IF (ml_idx_exit > 500)
    GO TO exit_script
   ENDIF
 ENDWHILE
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF ((m_rec->qual[ml_idx1].f_disch_dt > 0))
    SET ml_idx2 = locateval(ml_idx3,1,m_rec->l_dcnt,m_rec->qual[ml_idx1].s_disch_dt,m_rec->dqual[
     ml_idx3].s_dt)
    IF (ml_idx2 > 0)
     SET ml_idx4 = locateval(ml_idx3,1,m_rec->dqual[ml_idx2].l_ecnt,m_rec->qual[ml_idx1].f_encntr_id,
      m_rec->dqual[ml_idx2].equal[ml_idx3].f_encntr_id)
     IF (ml_idx4 > 0)
      SET m_rec->dqual[ml_idx2].equal[ml_idx4].l_use_disch = 1
     ELSE
      SET m_rec->dqual[ml_idx2].l_ecnt += 1
      SET stat = alterlist(m_rec->dqual[ml_idx2].equal,m_rec->dqual[ml_idx2].l_ecnt)
      SET m_rec->dqual[ml_idx2].equal[m_rec->dqual[ml_idx2].l_ecnt].f_encntr_id = m_rec->qual[ml_idx1
      ].f_encntr_id
      SET m_rec->dqual[ml_idx2].equal[m_rec->dqual[ml_idx2].l_ecnt].l_use_disch = 1
      SET m_rec->dqual[ml_idx2].equal[m_rec->dqual[ml_idx2].l_ecnt].s_encntr_type = m_rec->qual[
      ml_idx1].s_encntr_type
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF ((m_rec->qual[ml_idx1].f_deceased_dt > 0))
    SET ml_idx2 = locateval(ml_idx3,1,m_rec->l_dcnt,m_rec->qual[ml_idx1].s_deceased_dt,m_rec->dqual[
     ml_idx3].s_dt)
    IF (ml_idx2 > 0)
     SET ml_idx4 = locateval(ml_idx3,1,m_rec->dqual[ml_idx2].l_ecnt,m_rec->qual[ml_idx1].f_encntr_id,
      m_rec->dqual[ml_idx2].equal[ml_idx3].f_encntr_id)
     IF (ml_idx4 > 0)
      SET m_rec->dqual[ml_idx2].equal[ml_idx4].l_use_decease = 1
     ELSE
      SET m_rec->dqual[ml_idx2].l_ecnt += 1
      SET stat = alterlist(m_rec->dqual[ml_idx2].equal,m_rec->dqual[ml_idx2].l_ecnt)
      SET m_rec->dqual[ml_idx2].equal[m_rec->dqual[ml_idx2].l_ecnt].f_encntr_id = m_rec->qual[ml_idx1
      ].f_encntr_id
      SET m_rec->dqual[ml_idx2].equal[m_rec->dqual[ml_idx2].l_ecnt].l_use_decease = 1
      SET m_rec->dqual[ml_idx2].equal[m_rec->dqual[ml_idx2].l_ecnt].s_encntr_type = m_rec->qual[
      ml_idx1].s_encntr_type
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET frec->file_name = concat("bhs_ext_daily_hosp_census_",trim(format(cnvtdatetime(mf_start_dt),
    "MMDDYYYY;;q"),3),"_",trim(format(cnvtdatetime(mf_stop_dt),"MMDDYYYY;;q"),3),".csv")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build("Date,","FIN#,","Encounter ID,","Encounter Flag,","Daily Census,",
  "Discharge Date,","Deceased Date,","Arrival Date,","Current Name,","Current Unit,",
  "Unit start dt/tm,","Unit end dt/tm,","Person ID,","CMRN",char(13),
  char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_dcnt)
   IF ((m_rec->dqual[ml_idx1].l_ecnt > 0))
    FOR (ml_idx2 = 1 TO m_rec->dqual[ml_idx1].l_ecnt)
     SET ml_idx4 = locateval(ml_idx3,1,m_rec->l_cnt,m_rec->dqual[ml_idx1].equal[ml_idx2].f_encntr_id,
      m_rec->qual[ml_idx3].f_encntr_id)
     IF (ml_idx4 > 0)
      SET frec->file_buf = concat(m_rec->dqual[ml_idx1].s_dt,",",m_rec->qual[ml_idx4].s_fin,",",trim(
        cnvtstring(m_rec->qual[ml_idx4].f_encntr_id,20,2),3),
       ",",m_rec->dqual[ml_idx1].equal[ml_idx2].s_encntr_type,",",trim(cnvtstring(m_rec->dqual[
         ml_idx1].equal[ml_idx2].l_cencus_ind),3),",",
       evaluate(m_rec->dqual[ml_idx1].equal[ml_idx2].l_use_disch,1,m_rec->qual[ml_idx4].s_disch_dt,
        trim("")),",",evaluate(m_rec->dqual[ml_idx1].equal[ml_idx2].l_use_decease,1,m_rec->qual[
        ml_idx4].s_deceased_dt,trim("")),",",m_rec->qual[ml_idx4].s_admit_dt,
       ",",m_rec->qual[ml_idx4].s_facility,",",m_rec->qual[ml_idx4].s_last_unit_enc_hist,",",
       m_rec->qual[ml_idx4].s_last_unit_beg_dt,",",m_rec->qual[ml_idx4].s_last_unit_end_dt,",",trim(
        cnvtstring(m_rec->qual[ml_idx4].f_person_id,20,2),3),
       ",",m_rec->qual[ml_idx4].s_cmrn,char(13),char(10))
      SET stat = cclio("WRITE",frec)
     ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET stat = cclio("CLOSE",frec)
#exit_script
END GO
