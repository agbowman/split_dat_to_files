CREATE PROGRAM bhs_rpt_active_pat_covid
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 0
  WITH outdev, f_facility_id
 DECLARE mf_cs69_emergency_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17005"))
 DECLARE mf_cs69_inpatient_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE mf_cs69_observation_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!73451"
   ))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs72_covid19antigenpocresult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"COVID19ANTIGENPOCRESULT"))
 DECLARE mf_cs72_covid19bypcr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19BYPCR"))
 DECLARE mf_cs72_covid19byrtpcr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19BYRTPCR"))
 DECLARE mf_cs72_covid19naa_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19NAA"))
 DECLARE mf_cs72_covid19overallresult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19OVERALLRESULT"))
 DECLARE mf_cs72_covid19pcr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19PCR"))
 DECLARE mf_cs72_covid19pcroverallresult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"COVID19PCROVERALLRESULT"))
 DECLARE mf_cs72_covid19pcrresult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19PCRRESULT"))
 DECLARE mf_cs72_covid19pcrspecimensource_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"COVID19PCRSPECIMENSOURCE"))
 DECLARE mf_cs72_covid19pocresult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19POCRESULT"))
 DECLARE mf_cs72_covid19rnabypcr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19RNABYPCR"))
 DECLARE mf_cs72_covid19rnabyrtpcr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19RNABYRTPCR"))
 DECLARE mf_cs72_covid19rtpcr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19RTPCR"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs400_icd10cm_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4101498946"))
 DECLARE mf_cs333_attenddoc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4024"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_fin = vc
     2 s_person = vc
     2 s_dob = vc
     2 s_facility = vc
     2 s_unit = vc
     2 s_room = vc
     2 s_bed = vc
     2 s_admit_dt = vc
     2 s_attending = vc
 )
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   clinical_event ce,
   person p,
   encntr_alias ea
  PLAN (ed
   WHERE (ed.loc_facility_cd= $F_FACILITY_ID))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm = null
    AND e.reg_dt_tm IS NOT null
    AND e.encntr_type_class_cd IN (mf_cs69_emergency_cd, mf_cs69_inpatient_cd, mf_cs69_observation_cd
   )
    AND e.active_ind=1)
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND ce.event_cd IN (mf_cs72_covid19antigenpocresult_cd, mf_cs72_covid19bypcr_cd,
   mf_cs72_covid19byrtpcr_cd, mf_cs72_covid19naa_cd, mf_cs72_covid19overallresult_cd,
   mf_cs72_covid19pcr_cd, mf_cs72_covid19pcroverallresult_cd, mf_cs72_covid19pcrresult_cd,
   mf_cs72_covid19pcrspecimensource_cd, mf_cs72_covid19pocresult_cd,
   mf_cs72_covid19rnabypcr_cd, mf_cs72_covid19rnabyrtpcr_cd, mf_cs72_covid19rtpcr_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_auth_cd, mf_cs8_modified_cd)
    AND ce.view_level=1
    AND trim(cnvtupper(ce.result_val),3) IN ("POSITIVE", "DETECTED")
    AND ce.performed_dt_tm >= cnvtdatetime((curdate - 30),curtime3))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].s_fin = trim(ea
    .alias,3), m_rec->qual[m_rec->l_cnt].s_person = trim(p.name_full_formatted,3),
   m_rec->qual[m_rec->l_cnt].s_dob = trim(format(p.birth_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec
   ->l_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->qual[m_rec->l_cnt].
   s_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3),
   m_rec->qual[m_rec->l_cnt].s_room = trim(uar_get_code_display(e.loc_room_cd),3), m_rec->qual[m_rec
   ->l_cnt].s_bed = trim(uar_get_code_display(e.loc_bed_cd),3), m_rec->qual[m_rec->l_cnt].s_admit_dt
    = trim(format(e.reg_dt_tm,"MM/DD/YYYY;;q"),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   diagnosis d,
   nomenclature n,
   person p,
   encntr_alias ea
  PLAN (ed
   WHERE (ed.loc_facility_cd= $F_FACILITY_ID))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm = null
    AND e.reg_dt_tm IS NOT null
    AND e.encntr_type_class_cd IN (mf_cs69_emergency_cd, mf_cs69_inpatient_cd, mf_cs69_observation_cd
   )
    AND e.active_ind=1
    AND  NOT (expand(ml_idx1,1,m_rec->l_cnt,e.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)))
   JOIN (d
   WHERE d.encntr_id=e.encntr_id
    AND d.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.source_vocabulary_cd=mf_cs400_icd10cm_cd
    AND n.source_identifier IN ("U07.1", "B33.8", "B97.29"))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].s_fin = trim(ea
    .alias,3), m_rec->qual[m_rec->l_cnt].s_person = trim(p.name_full_formatted,3),
   m_rec->qual[m_rec->l_cnt].s_dob = trim(format(p.birth_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec
   ->l_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->qual[m_rec->l_cnt].
   s_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3),
   m_rec->qual[m_rec->l_cnt].s_room = trim(uar_get_code_display(e.loc_room_cd),3), m_rec->qual[m_rec
   ->l_cnt].s_bed = trim(uar_get_code_display(e.loc_bed_cd),3), m_rec->qual[m_rec->l_cnt].s_admit_dt
    = trim(format(e.reg_dt_tm,"MM/DD/YYYY;;q"),3)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl p
  PLAN (epr
   WHERE expand(ml_idx1,1,m_rec->l_cnt,epr.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
    AND epr.active_ind=1
    AND epr.encntr_prsnl_r_cd=mf_cs333_attenddoc_cd
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  ORDER BY epr.encntr_id, epr.beg_effective_dt_tm DESC
  HEAD epr.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,epr.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_attending = trim(p.name_full_formatted,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF ((m_rec->l_cnt > 1))
  SELECT INTO  $OUTDEV
   patient_name = trim(substring(1,120,m_rec->qual[d.seq].s_person),3), dob = trim(substring(1,20,
     m_rec->qual[d.seq].s_dob),3), fin = trim(substring(1,30,m_rec->qual[d.seq].s_fin),3),
   facility = trim(substring(1,100,m_rec->qual[d.seq].s_facility),3), unit = trim(substring(1,100,
     m_rec->qual[d.seq].s_unit),3), room = trim(substring(1,100,m_rec->qual[d.seq].s_room),3),
   bed = trim(substring(1,100,m_rec->qual[d.seq].s_bed),3), admit_dt = trim(substring(1,100,m_rec->
     qual[d.seq].s_admit_dt),3), attending_provider = trim(substring(1,120,m_rec->qual[d.seq].
     s_attending),3)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   PLAN (d)
   ORDER BY facility, unit, room,
    patient_name
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
