CREATE PROGRAM bhs_rpt_sbar:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 0,
  "Nurse Unit:" = 0,
  "Begin dt/tm:" = "CURDATE",
  "End dt/tm:" = "CURDATE"
  WITH outdev, mf_facility, mf_nurseunit,
  ms_begin_date, ms_end_date
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE ms_fac_parser = vc WITH protect, noconstant(" 1 = 1 ")
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_anticipated_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!7981"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_transcribedcorrected_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!421865"))
 DECLARE mf_cs8_dictated_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!28281"))
 DECLARE mf_cs8_inlab_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2629"))
 DECLARE mf_cs8_inprogress_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2637"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs8_started_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4110193403"
   ))
 DECLARE mf_cs8_transcribed_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2632"))
 DECLARE mf_cs8_preliminary_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2634"))
 DECLARE mf_cs71_inpatient_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3958"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs220_edhld_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_ednh_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_erhd_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_eshp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_eshld_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_dfap_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD m_nu
 RECORD m_nu(
   1 l_cnt = i4
   1 qual[*]
     2 f_loc_cd = f8
     2 s_loc_desc = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_dcp_forms_activity_id = f8
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_1st_sbar_dt = vc
     2 s_1st_sbar_contrib = vc
     2 s_2nd_sbar_dt = vc
     2 s_2nd_sbar_contrib = vc
     2 s_last_sbar_dt = vc
     2 s_last_sbar_contrib = vc
     2 s_ed_depart_dt = vc
     2 s_nu_arrive_dt = vc
 ) WITH protect
 IF (cnvtupper(trim( $4,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $4,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $4,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $4,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $4,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $5,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $5,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $5,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $5,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $5,3)," 23:59:59"))
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE (cv.code_value= $MF_FACILITY)
    AND cv.code_set=220
    AND cv.active_ind=1)
  HEAD REPORT
   ms_fac_parser = concat(" e.loc_facility_cd in ( ",trim(cnvtstring(cv.code_value,20,2),3))
  DETAIL
   ms_fac_parser = concat(ms_fac_parser,", ",trim(cnvtstring(cv.code_value,20,2),3))
  FOOT REPORT
   ms_fac_parser = concat(ms_fac_parser," ) ")
  WITH nocounter
 ;end select
 IF (( $MF_FACILITY=- (1))
  AND ( $MF_NURSEUNIT=- (1)))
  SELECT INTO "nl:"
   FROM nurse_unit n,
    code_value cv
   PLAN (n
    WHERE n.loc_facility_cd IN (673936, 679549, 673937, 679586, 673938,
    580062482, 580061823, 2159646, 780848199, 780611679)
     AND n.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=n.location_cd
     AND cv.code_set=220
     AND cv.active_ind=1
     AND  NOT (cv.display_key IN ("EDHLD", "EDNH", "ERHD", "ESHP", "ESHLD"))
     AND cv.data_status_cd=25
     AND  NOT (cv.display_key IN (
    (SELECT
     nu.info_name
     FROM dm_info nu
     WHERE nu.info_domain="BHS_INACTIVE_NURSE_UNIT")))
     AND ((((cv.cdf_meaning="NURSEUNIT") OR (cv.cdf_meaning="AMBULATORY"
     AND ((cv.display_key IN (
    (SELECT
     au.info_name
     FROM dm_info au
     WHERE au.info_domain="BHS_AMBULATORY_UNIT"))) OR (n.loc_facility_cd=2159646)) )) ) OR (((cv
    .cdf_meaning="AMBULATORY"
     AND cv.display_key="BFMCONCOLOGY"
     AND n.loc_facility_cd=673937) OR (((cv.cdf_meaning="AMBULATORY"
     AND cv.display_key="S15MED"
     AND n.loc_facility_cd=673936) OR (cv.cdf_meaning="AMBULATORY"
     AND cv.display_key="NOBLEMEDDAYSTAY")) )) )) )
   ORDER BY n.location_cd
   HEAD n.location_cd
    m_nu->l_cnt += 1, stat = alterlist(m_nu->qual,m_nu->l_cnt), m_nu->qual[m_nu->l_cnt].f_loc_cd = cv
    .code_value,
    m_nu->qual[m_nu->l_cnt].s_loc_desc = trim(cv.display,3)
   WITH nocounter
  ;end select
 ELSEIF (( $MF_FACILITY != - (1))
  AND ( $MF_NURSEUNIT=- (1)))
  SELECT INTO "nl:"
   FROM nurse_unit n,
    code_value cv
   PLAN (n
    WHERE (n.loc_facility_cd= $MF_FACILITY)
     AND n.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=n.location_cd
     AND cv.code_set=220
     AND cv.active_ind=1
     AND  NOT (cv.display_key IN ("EDHLD", "EDNH", "ERHD", "ESHP", "ESHLD"))
     AND cv.data_status_cd=25
     AND  NOT (cv.display_key IN (
    (SELECT
     nu.info_name
     FROM dm_info nu
     WHERE nu.info_domain="BHS_INACTIVE_NURSE_UNIT")))
     AND ((((cv.cdf_meaning="NURSEUNIT") OR (cv.cdf_meaning="AMBULATORY"
     AND ((cv.display_key IN (
    (SELECT
     au.info_name
     FROM dm_info au
     WHERE au.info_domain="BHS_AMBULATORY_UNIT"))) OR (n.loc_facility_cd=2159646)) )) ) OR (((cv
    .cdf_meaning="AMBULATORY"
     AND cv.display_key="BFMCONCOLOGY"
     AND n.loc_facility_cd=673937) OR (((cv.cdf_meaning="AMBULATORY"
     AND cv.display_key="S15MED"
     AND n.loc_facility_cd=673936) OR (cv.cdf_meaning="AMBULATORY"
     AND cv.display_key="NOBLEMEDDAYSTAY")) )) )) )
   ORDER BY n.location_cd
   HEAD n.location_cd
    m_nu->l_cnt += 1, stat = alterlist(m_nu->qual,m_nu->l_cnt), m_nu->qual[m_nu->l_cnt].f_loc_cd = cv
    .code_value,
    m_nu->qual[m_nu->l_cnt].s_loc_desc = trim(cv.display,3)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE (cv.code_value= $MF_NURSEUNIT)
     AND cv.code_set=220
     AND cv.active_ind=1
     AND  NOT (cv.display_key IN ("EDHLD", "EDNH", "ERHD", "ESHP", "ESHLD")))
   HEAD REPORT
    m_nu->l_cnt = 0
   DETAIL
    m_nu->l_cnt += 1, stat = alterlist(m_nu->qual,m_nu->l_cnt), m_nu->qual[m_nu->l_cnt].f_loc_cd = cv
    .code_value,
    m_nu->qual[m_nu->l_cnt].s_loc_desc = trim(cv.display,3)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.active_ind=1
    AND cv.display_key IN ("EDHLD", "EDNH", "ERHD", "ESHP", "ESHLD")
    AND cv.cdf_meaning="NURSEUNIT")
  ORDER BY cv.code_value
  DETAIL
   IF (cv.display_key="EDHLD")
    mf_cs220_edhld_cd = cv.code_value
   ELSEIF (cv.display_key="EDNH")
    mf_cs220_ednh_cd = cv.code_value
   ELSEIF (cv.display_key="ERHD")
    mf_cs220_erhd_cd = cv.code_value
   ELSEIF (cv.display_key="ESHP")
    mf_cs220_eshp_cd = cv.code_value
   ELSEIF (cv.display_key="ESHLD")
    mf_cs220_eshld_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   encounter e,
   person p,
   encntr_loc_hist elh,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (dfr
   WHERE dfr.description="ED SBAR (Nursing) - BHS v.2"
    AND dfr.active_ind=1)
   JOIN (dfa
   WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.form_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND dfa.active_ind=1
    AND dfa.form_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_anticipated_cd,
   mf_cs8_auth_cd, mf_cs8_transcribedcorrected_cd,
   mf_cs8_dictated_cd, mf_cs8_inlab_cd, mf_cs8_inprogress_cd, mf_cs8_modified_cd, mf_cs8_started_cd,
   mf_cs8_transcribed_cd, mf_cs8_preliminary_cd))
   JOIN (e
   WHERE e.encntr_id=dfa.encntr_id
    AND e.active_ind=1
    AND parser(ms_fac_parser))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.active_ind=1
    AND elh.encntr_type_cd=mf_cs71_inpatient_cd
    AND  NOT (elh.loc_nurse_unit_cd IN (mf_cs220_edhld_cd, mf_cs220_ednh_cd, mf_cs220_erhd_cd,
   mf_cs220_eshp_cd, mf_cs220_eshld_cd)))
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea1.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn_cd)
  ORDER BY e.encntr_id, elh.beg_effective_dt_tm, dfa.form_dt_tm DESC
  HEAD e.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_nu->l_cnt,elh.loc_nurse_unit_cd,m_nu->qual[ml_idx1].f_loc_cd)
   IF (ml_idx2 > 0)
    m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
    f_encntr_id = e.encntr_id,
    m_rec->qual[m_rec->l_cnt].f_person_id = p.person_id, m_rec->qual[m_rec->l_cnt].
    f_dcp_forms_activity_id = dfa.dcp_forms_activity_id, m_rec->qual[m_rec->l_cnt].s_pat_name = trim(
     p.name_full_formatted,3),
    m_rec->qual[m_rec->l_cnt].s_mrn = trim(ea2.alias,3), m_rec->qual[m_rec->l_cnt].s_fin = trim(ea1
     .alias,3), m_rec->qual[m_rec->l_cnt].s_nu_arrive_dt = format(elh.beg_effective_dt_tm,
     "MM/DD/YYYY HH:mm;;q")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_activity_prsnl dfap,
   prsnl p
  PLAN (dfap
   WHERE expand(ml_idx1,1,m_rec->l_cnt,dfap.dcp_forms_activity_id,m_rec->qual[ml_idx1].
    f_dcp_forms_activity_id))
   JOIN (p
   WHERE p.person_id=dfap.prsnl_id)
  ORDER BY dfap.dcp_forms_activity_id, dfap.activity_dt_tm
  HEAD dfap.dcp_forms_activity_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,dfap.dcp_forms_activity_id,m_rec->qual[ml_idx1].
    f_dcp_forms_activity_id), ml_dfap_cnt = 0
  DETAIL
   IF (ml_idx2 > 0)
    ml_dfap_cnt += 1
    IF (ml_dfap_cnt=1)
     m_rec->qual[ml_idx2].s_1st_sbar_dt = format(dfap.activity_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->
     qual[ml_idx2].s_1st_sbar_contrib = trim(p.name_full_formatted,3)
    ELSEIF (ml_dfap_cnt=2)
     m_rec->qual[ml_idx2].s_2nd_sbar_dt = format(dfap.activity_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->
     qual[ml_idx2].s_2nd_sbar_contrib = trim(p.name_full_formatted,3)
    ENDIF
   ENDIF
  FOOT  dfap.dcp_forms_activity_id
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_last_sbar_dt = format(dfap.activity_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->
    qual[ml_idx2].s_last_sbar_contrib = trim(p.name_full_formatted,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM tracking_item ti,
   tracking_checkin tc,
   code_value cv
  PLAN (ti
   WHERE expand(ml_idx1,1,m_rec->l_cnt,ti.encntr_id,m_rec->qual[ml_idx1].f_encntr_id))
   JOIN (tc
   WHERE tc.tracking_id=ti.tracking_id
    AND tc.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=tc.tracking_group_cd
    AND cv.code_set=16370
    AND cv.cdf_meaning="ER")
  ORDER BY ti.encntr_id, ti.tracking_id DESC
  HEAD ti.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,ti.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_ed_depart_dt = format(tc.checkout_dt_tm,"MM/DD/YYYY HH:mm;;q")
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF ((m_rec->l_cnt > 0))
  SELECT INTO  $OUTDEV
   patient_name = trim(substring(1,120,m_rec->qual[d.seq].s_pat_name),3), mrn = trim(substring(1,30,
     m_rec->qual[d.seq].s_mrn),3), fin = trim(substring(1,30,m_rec->qual[d.seq].s_fin),3),
   sbar_1st_contributor_dt = trim(substring(1,30,m_rec->qual[d.seq].s_1st_sbar_dt),3),
   sbar_1st_contributor = trim(substring(1,120,m_rec->qual[d.seq].s_1st_sbar_contrib),3),
   sbar_2nd_contributor_dt = trim(substring(1,30,m_rec->qual[d.seq].s_2nd_sbar_dt),3),
   sbar_2nd_contributor = trim(substring(1,120,m_rec->qual[d.seq].s_2nd_sbar_contrib),3),
   sbar_last_contributor_dt = trim(substring(1,30,m_rec->qual[d.seq].s_last_sbar_dt),3),
   sbar_last_contributor = trim(substring(1,120,m_rec->qual[d.seq].s_last_sbar_contrib),3),
   ed_depart_dt = trim(substring(1,30,m_rec->qual[d.seq].s_ed_depart_dt),3), inpat_admit_to_unit_dt
    = trim(substring(1,30,m_rec->qual[d.seq].s_nu_arrive_dt),3)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   PLAN (d)
   ORDER BY patient_name, fin
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    "{CPI/9}{FONT/4}", row 0, col 0,
    CALL print(build2("PROGRAM:  ",cnvtlower(curprog),"       NODE:  ",curnode)), row + 1, row 3,
    col 0,
    CALL print("Report completed. No qualifying data found."), row + 1,
    row 6, col 0,
    CALL print(build2("Execution Date/Time:",format(cnvtdatetime(curdate,curtime),
      "mm/dd/yyyy hh:mm:ss;;q")))
   WITH nocounter, nullreport, maxcol = 300,
    dio = 08
  ;end select
 ENDIF
#exit_script
END GO
