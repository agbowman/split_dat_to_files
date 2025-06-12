CREATE PROGRAM bhs_rpt_pss_vax_13yr:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 loc[*]
     2 f_cd = f8
     2 s_disp = vc
   1 vax[*]
     2 f_cd = f8
     2 s_disp = vc
   1 enc[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 s_dob = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_vax = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE mf_cs8_auth = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_mod = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs8_alter = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_active = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs93_imm = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"IMMUNIZATIONS"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs6004_ordered = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
  SET ms_log = "Both dates must be filled out"
  GO TO exit_script
 ENDIF
 IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
  SET ms_log = "End date must be greater than Beg date"
  GO TO exit_scriptyeah
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display IN ("*Ped Svc Sp/Wilb", "*Pedi Svcs Spfld")
  HEAD REPORT
   pl_cnt = 0
  HEAD cv.code_value
   pl_cnt += 1,
   CALL alterlist(m_rec->loc,pl_cnt), m_rec->loc[pl_cnt].f_cd = cv.code_value,
   m_rec->loc[pl_cnt].s_disp = trim(cv.display,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM v500_event_set_explode vese,
   code_value cv
  PLAN (vese
   WHERE vese.event_set_cd=mf_cs93_imm)
   JOIN (cv
   WHERE cv.code_value=vese.event_cd
    AND cv.active_ind=1
    AND cv.display_key IN ("GARDASILOLDTERM", "HUMANPAPILLOMAVIRUSVACCINE", "MENACTRAOLDTERM",
   "MENINGOCOCCALCONJUGATEVACCINE"))
  ORDER BY cv.code_value
  HEAD REPORT
   pl_cnt = 0
  HEAD cv.code_value
   pl_cnt += 1,
   CALL alterlist(m_rec->vax,pl_cnt), m_rec->vax[pl_cnt].f_cd = cv.code_value,
   m_rec->vax[pl_cnt].s_disp = trim(cv.display,3)
  WITH uar_code(d)
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   clinical_event ce,
   encntr_alias ea1,
   encntr_alias ea2,
   dummyt d
  PLAN (e
   WHERE expand(ml_exp,1,size(m_rec->loc,5),e.loc_nurse_unit_cd,m_rec->loc[ml_exp].f_cd)
    AND e.reg_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND ce.encntr_id=e.encntr_id
    AND expand(ml_exp,1,size(m_rec->vax,5),ce.event_cd,m_rec->vax[ml_exp].f_cd)
    AND ce.result_status_cd IN (mf_cs8_active, mf_cs8_alter, mf_cs8_auth, mf_cs8_mod)
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn)
   JOIN (d
   WHERE p.birth_dt_tm BETWEEN cnvtlookbehind("5109,D",e.reg_dt_tm) AND cnvtlookbehind("4745,D",e
    .reg_dt_tm))
  ORDER BY p.person_id, ce.event_cd, ce.event_end_dt_tm,
   ce.event_id
  HEAD REPORT
   pl_cnt = 0, pl_vax_cnt = 0
  HEAD e.person_id
   pl_vax_cnt = 0, pl_cnt += 1
   IF (pl_cnt > size(m_rec->enc,5))
    CALL alterlist(m_rec->enc,(pl_cnt+ 50))
   ENDIF
   m_rec->enc[pl_cnt].f_person_id = e.person_id, m_rec->enc[pl_cnt].f_encntr_id = e.encntr_id, m_rec
   ->enc[pl_cnt].s_pat_name = trim(p.name_full_formatted,3),
   m_rec->enc[pl_cnt].s_dob = trim(format(p.birth_dt_tm,"mm/dd/yy;;d"),3), m_rec->enc[pl_cnt].s_mrn
    = trim(ea2.alias,3), m_rec->enc[pl_cnt].s_fin = trim(ea1.alias,3)
  HEAD ce.event_cd
   pl_vax_cnt = 0
  HEAD ce.event_id
   pl_vax_cnt += 1,
   CALL echo(pl_vax_cnt),
   CALL echo(uar_get_code_display(ce.event_cd)),
   CALL echo(ce.event_id)
   IF (pl_vax_cnt > 1)
    ms_tmp = concat(trim(uar_get_code_display(ce.event_cd),3)," dose ",trim(cnvtstring(pl_vax_cnt),3)
     )
   ELSE
    ms_tmp = trim(uar_get_code_display(ce.event_cd),3)
   ENDIF
   IF (textlen(trim(m_rec->enc[pl_cnt].s_vax,3))=0)
    m_rec->enc[pl_cnt].s_vax = ms_tmp
   ELSE
    m_rec->enc[pl_cnt].s_vax = concat(m_rec->enc[pl_cnt].s_vax,"; ",ms_tmp)
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->enc,pl_cnt)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO value( $OUTDEV)
  patient_name = substring(1,100,m_rec->enc[d.seq].s_pat_name), dob = m_rec->enc[d.seq].s_dob, mrn =
  substring(1,40,m_rec->enc[d.seq].s_mrn),
  fin = substring(1,40,m_rec->enc[d.seq].s_fin), vaccines = substring(1,1000,m_rec->enc[d.seq].s_vax)
  FROM (dummyt d  WITH seq = value(size(m_rec->enc,5)))
  PLAN (d)
  ORDER BY d.seq
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
