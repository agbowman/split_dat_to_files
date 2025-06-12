CREATE PROGRAM bhs_rpt_pat_relig_church:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 0,
  "Religion:" = 0,
  "Place of Worship (optional):" = 0,
  "Email (only baystate accounts):" = ""
  WITH outdev, f_fac_cd, f_relig_cd,
  f_church, s_email
 DECLARE mf_cs71_emergency_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3957"))
 DECLARE mf_cs71_inpatient_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3958"))
 DECLARE mf_cs71_observation_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17613"
   ))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE ms_church_parser = vc WITH protect, noconstant(" 1 = 1 ")
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_religion = vc
     2 s_church = vc
     2 s_facility = vc
     2 s_unit = vc
     2 s_room = vc
     2 s_bed = vc
     2 s_reg_dt = vc
     2 s_fin = vc
     2 s_enc_type = vc
     2 s_age = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=267
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND (cv.code_value= $F_CHURCH)
  HEAD REPORT
   ms_church_parser = concat(" pp.church_cd in ( ",trim(cnvtstring(cv.code_value,20,2),3))
  DETAIL
   ms_church_parser = concat(ms_church_parser,", ",trim(cnvtstring(cv.code_value,20,2),3))
  FOOT REPORT
   ms_church_parser = concat(ms_church_parser,") ")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   person_patient pp,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (e
   WHERE e.reg_dt_tm IS NOT null
    AND e.disch_dt_tm = null
    AND e.active_ind=1
    AND e.encntr_type_cd IN (mf_cs71_emergency_cd, mf_cs71_inpatient_cd, mf_cs71_observation_cd)
    AND (e.loc_facility_cd= $F_FAC_CD))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.name_last_key != "ACISADULT*"
    AND (p.religion_cd= $F_RELIG_CD))
   JOIN (pp
   WHERE pp.person_id=p.person_id
    AND pp.active_ind=1
    AND parser(ms_church_parser))
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
  ORDER BY e.person_id, e.reg_dt_tm DESC
  HEAD e.person_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].s_pat_name = trim(p
    .name_full_formatted,3), m_rec->qual[m_rec->l_cnt].s_religion = trim(uar_get_code_display(p
     .religion_cd),3),
   m_rec->qual[m_rec->l_cnt].s_church = trim(uar_get_code_display(pp.church_cd),3), m_rec->qual[m_rec
   ->l_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->qual[m_rec->l_cnt].
   s_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3),
   m_rec->qual[m_rec->l_cnt].s_room = trim(uar_get_code_display(e.loc_room_cd),3), m_rec->qual[m_rec
   ->l_cnt].s_bed = trim(uar_get_code_display(e.loc_bed_cd),3), m_rec->qual[m_rec->l_cnt].s_fin =
   trim(ea1.alias,3),
   m_rec->qual[m_rec->l_cnt].s_mrn = trim(ea2.alias,3), m_rec->qual[m_rec->l_cnt].s_enc_type = trim(
    uar_get_code_display(e.encntr_type_cd),3), m_rec->qual[m_rec->l_cnt].s_reg_dt = trim(format(e
     .reg_dt_tm,"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_age = trim(cnvtage(p.birth_dt_tm),3)
  WITH nocounter
 ;end select
 IF ((m_rec->l_cnt=0))
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Report finished successfully.", col 0, "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, msg1,
    msg2 = "No patients qualified. ", row + 1, msg2
   WITH dio = 08
  ;end select
 ELSE
  IF (findstring("@",trim( $S_EMAIL,3)) > 0)
   FREE RECORD frec
   RECORD frec(
     1 file_desc = i4
     1 file_offset = i4
     1 file_dir = i4
     1 file_name = vc
     1 file_buf = vc
   ) WITH protect
   SET frec->file_name = concat("bhs_rpt_pat_relig_",format(cnvtdatetime(cnvtdatetime(sysdate)),
     "MMDDYYYY;;q"),".csv")
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = concat(
    '"Patient Name","Age","MRN","FIN","Encounter Type","Facility","Unit","Room","Bed",',
    '"Registration Date","Religion","Place of Worship"',char(13),char(10))
   SET stat = cclio("WRITE",frec)
   FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    SET frec->file_buf = concat('"',trim(m_rec->qual[ml_idx1].s_pat_name,3),'","',trim(m_rec->qual[
      ml_idx1].s_age,3),'","',
     trim(m_rec->qual[ml_idx1].s_mrn,3),'","',trim(m_rec->qual[ml_idx1].s_fin,3),'","',trim(m_rec->
      qual[ml_idx1].s_enc_type,3),
     '","',trim(m_rec->qual[ml_idx1].s_facility,3),'","',trim(m_rec->qual[ml_idx1].s_unit,3),'","',
     trim(m_rec->qual[ml_idx1].s_room,3),'","',trim(m_rec->qual[ml_idx1].s_bed,3),'","',trim(m_rec->
      qual[ml_idx1].s_reg_dt,3),
     '","',trim(m_rec->qual[ml_idx1].s_religion,3),'","',trim(m_rec->qual[ml_idx1].s_church,3),'"',
     char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   EXECUTE bhs_ma_email_file
   DECLARE ms_rec = vc WITH protect, noconstant("")
   SET ms_rec = trim( $S_EMAIL,3)
   CALL emailfile(frec->file_name,frec->file_name,ms_rec,"Patient Religion Report",1)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Report finished successfully.", col 0, "{PS/792 0 translate 90 rotate/}",
     y_pos = 18, row + 1, msg1,
     msg2 = concat("Email sent to: ",trim( $S_EMAIL,3)), row + 1, msg2,
     msg3 =
     "Email will be blocked by the exchange server, unless being sent to @bhs.org or @baystatehealth.org",
     row + 1, msg3
    WITH dio = 08
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    patient_name = trim(substring(1,150,m_rec->qual[d1.seq].s_pat_name),3), age = trim(substring(1,50,
      m_rec->qual[d1.seq].s_age),3), mrn = trim(substring(1,50,m_rec->qual[d1.seq].s_mrn),3),
    fin = trim(substring(1,50,m_rec->qual[d1.seq].s_fin),3), encntr_type = trim(substring(1,50,m_rec
      ->qual[d1.seq].s_enc_type),3), faciility = trim(substring(1,100,m_rec->qual[d1.seq].s_facility),
     3),
    unit = trim(substring(1,100,m_rec->qual[d1.seq].s_unit),3), room = trim(substring(1,100,m_rec->
      qual[d1.seq].s_room),3), bed = trim(substring(1,100,m_rec->qual[d1.seq].s_bed),3),
    reg_dt = trim(substring(1,50,m_rec->qual[d1.seq].s_reg_dt),3), religion = trim(substring(1,150,
      m_rec->qual[d1.seq].s_religion),3), place_of_worship = trim(substring(1,150,m_rec->qual[d1.seq]
      .s_church),3)
    FROM (dummyt d1  WITH seq = value(m_rec->l_cnt))
    PLAN (d1)
    ORDER BY faciility, patient_name
    WITH nocounter, heading, maxrow = 1,
     formfeed = none, format, separator = " "
   ;end select
  ENDIF
 ENDIF
#exit_script
END GO
