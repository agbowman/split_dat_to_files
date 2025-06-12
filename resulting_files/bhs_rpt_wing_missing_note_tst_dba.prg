CREATE PROGRAM bhs_rpt_wing_missing_note_tst:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date :" = "CURDATE",
  "Provider Person ID:" = 0,
  "Facility:" = 0.0,
  "Encounter Types:" = value(0.0)
  WITH outdev, s_beg_dt, s_end_dt,
  f_prov_person_id, f_facility_cd, f_enc_type_cd
 FREE RECORD m_rec
 RECORD m_rec(
   1 pos[*]
     2 s_disp = vc
     2 f_cd = f8
   1 fac[*]
     2 s_disp = vc
     2 f_cd = f8
   1 enc[*]
     2 ml_ind = i4
     2 mf_enc_cd = f8
     2 ms_beg_dt_tm = vc
     2 ms_end_dt_tm = vc
     2 prsnl[*]
       3 mf_prsnl_id = f8
   1 prsnl[*]
     2 mf_prsnl_id = f8
   1 pat[*]
     2 s_encntr_id = vc
     2 s_enc_beg_dt = vc
     2 s_enc_end_dt = vc
     2 s_encntr_type = vc
     2 s_fac = vc
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_med_svc = vc
     2 prsnl[*]
       3 mf_prsnl_id = f8
       3 ms_provider_name = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT)," 23:59:59"))
 DECLARE mf_prov_id = f8 WITH protect, constant(cnvtreal( $F_PROV_PERSON_ID))
 DECLARE mf_facility_cd = f8 WITH protect, constant(cnvtreal( $F_FACILITY_CD))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"MDOC"))
 DECLARE mf_doc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE ms_fac_p = vc WITH protect, noconstant(" ")
 DECLARE ms_prsnl_id_p = vc WITH protect, noconstant(" ")
 DECLARE ms_enc_type_p = vc WITH protect, noconstant(" ")
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_exp2 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt3 = i4 WITH protect, noconstant(0)
 IF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  SET ms_log = "Begin Date must be less than End Date."
  GO TO exit_script
 ENDIF
 IF (mf_prov_id=0.0)
  SET ms_prsnl_id_p = "1=1"
 ELSE
  SET ms_prsnl_id_p = "pr.person_id = mf_PROV_ID"
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_event_cd_list b
  WHERE b.grouper IN ("MD", "PA", "NP")
   AND b.listkey="WING_RPT_MISS_NOTES_POS"
   AND b.active_ind=1
  DETAIL
   ml_cnt = (ml_cnt+ 1)
   IF (ml_cnt > size(m_rec->pos,5))
    CALL alterlist(m_rec->pos,(ml_cnt+ 50))
   ENDIF
   m_rec->pos[ml_cnt].f_cd = b.event_cd, m_rec->pos[ml_cnt].s_disp = trim(uar_get_code_display(b
     .event_cd),3)
  FOOT REPORT
   CALL alterlist(m_rec->pos,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = 'No position codes found under "bhs_event_cd_list" table.'
  GO TO exit_script
 ENDIF
 IF (mf_facility_cd=0.0)
  SET ms_fac_p = "1=1"
 ELSE
  SET ms_fac_p = "cv.code_value = mf_FACILITY_CD"
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="FACILITY"
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND parser(ms_fac_p)
   AND cv.display_key IN ("BWH", "BWHINPTPSYCH", "GRISWOLDBEHAVHLTH", "BLCHMEDCTR", "LUDLOWMEDCTR",
  "MONSONMEDCTR", "PALMERMEDCTR", "WILBRAHAMMEDCTR")
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt = (ml_cnt+ 1)
   IF (ml_cnt > size(m_rec->fac,5))
    CALL alterlist(m_rec->fac,(ml_cnt+ 50))
   ENDIF
   m_rec->fac[ml_cnt].f_cd = cv.code_value, m_rec->fac[ml_cnt].s_disp = trim(cv.display,3)
  FOOT REPORT
   CALL alterlist(m_rec->fac,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "No WING facilities found."
  GO TO exit_script
 ENDIF
 SET ms_data_type = reflect(parameter(6,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(6,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_enc_type_p = concat("e.encntr_type_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_enc_type_p = concat(ms_enc_type_p,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_enc_type_p = concat(ms_enc_type_p,")")
 ELSEIF (parameter(6,1)=0.0)
  SET ms_enc_type_p = " 1=1"
 ELSE
  SET ms_enc_type_p = cnvtstring(parameter(6,1),20)
  SET ms_enc_type_p = concat(" e.encntr_type_cd = ",trim(ms_enc_type_p))
 ENDIF
 SELECT DISTINCT INTO "nl:"
  e.encntr_id, pr.person_id
  FROM prsnl pr,
   sch_appt sa,
   sch_event_patient sep,
   encounter e
  PLAN (pr
   WHERE pr.active_ind=1
    AND pr.active_status_cd=mf_active_cd
    AND parser(ms_prsnl_id_p)
    AND expand(ml_exp,1,size(m_rec->pos,5),pr.position_cd,m_rec->pos[ml_exp].f_cd))
   JOIN (sa
   WHERE sa.person_id=pr.person_id
    AND sa.active_ind=1
    AND sa.active_status_cd=mf_active_cd
    AND sa.beg_dt_tm > cnvtdatetime(ms_beg_dt_tm)
    AND sa.end_dt_tm < cnvtdatetime(ms_end_dt_tm))
   JOIN (sep
   WHERE sa.sch_event_id=sep.sch_event_id)
   JOIN (e
   WHERE sep.encntr_id=e.encntr_id
    AND e.active_ind=1
    AND expand(ml_exp2,1,size(m_rec->fac,5),e.loc_facility_cd,m_rec->fac[ml_exp2].f_cd)
    AND parser(ms_enc_type_p))
  ORDER BY e.encntr_id, pr.person_id
  HEAD REPORT
   ml_cnt = 0, ml_cnt2 = 0, ml_cnt3 = 0
  HEAD e.encntr_id
   ml_cnt = (ml_cnt+ 1)
   IF (ml_cnt > size(m_rec->enc,5))
    CALL alterlist(m_rec->enc,(ml_cnt+ 100))
   ENDIF
   m_rec->enc[ml_cnt].ms_beg_dt_tm = trim(format(sa.beg_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")), m_rec->enc[
   ml_cnt].ms_end_dt_tm = trim(format(sa.end_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")), m_rec->enc[ml_cnt].
   mf_enc_cd = e.encntr_id,
   m_rec->enc[ml_cnt].ml_ind = 0, ml_cnt2 = 0
  HEAD pr.person_id
   ml_cnt2 = (ml_cnt2+ 1),
   CALL alterlist(m_rec->enc[ml_cnt].prsnl,ml_cnt2), m_rec->enc[ml_cnt].prsnl[ml_cnt2].mf_prsnl_id =
   pr.person_id,
   ml_cnt3 = (ml_cnt3+ 1),
   CALL alterlist(m_rec->prsnl,ml_cnt3), m_rec->prsnl[ml_cnt3].mf_prsnl_id = pr.person_id
  FOOT REPORT
   CALL alterlist(m_rec->enc,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "No Encounters found this date range."
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  ce.encntr_id, cep.action_prsnl_id
  FROM clinical_event ce,
   ce_event_prsnl cep
  PLAN (ce
   WHERE expand(ml_exp,1,size(m_rec->enc,5),ce.encntr_id,m_rec->enc[ml_exp].mf_enc_cd)
    AND ce.event_class_cd IN (mf_doc_cd, mf_mdoc_cd))
   JOIN (cep
   WHERE cep.event_id=ce.event_id
    AND expand(ml_exp2,1,size(m_rec->prsnl,5),cep.action_prsnl_id,m_rec->prsnl[ml_exp2].mf_prsnl_id))
  ORDER BY ce.encntr_id, cep.action_prsnl_id
  HEAD REPORT
   ml_cnt = 0, ml_cnt1 = 0
  HEAD ce.encntr_id
   ml_enc_pos = locateval(ml_cnt,1,size(m_rec->enc,5),ce.encntr_id,m_rec->enc[ml_cnt].mf_enc_cd)
  HEAD cep.action_prsnl_id
   ml_found = locateval(ml_cnt1,1,size(m_rec->enc[ml_enc_pos].prsnl,5),cep.action_prsnl_id,m_rec->
    enc[ml_enc_pos].prsnl[ml_cnt1].mf_prsnl_id)
   IF (ml_found > 0)
    m_rec->enc[ml_enc_pos].ml_ind = 1
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_rec->enc,5))),
   (dummyt d2  WITH seq = 1),
   encounter e,
   encntr_alias ea1,
   encntr_alias ea2,
   person p,
   prsnl pr
  PLAN (d1
   WHERE (m_rec->enc[d1.seq].ml_ind=0)
    AND maxrec(d2,size(m_rec->enc[d1.seq].prsnl,5)))
   JOIN (e
   WHERE (e.encntr_id=m_rec->enc[d1.seq].mf_enc_cd))
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_fin_cd
    AND ea1.alias != "ATR*")
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_alias_type_cd=mf_mrn_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
   JOIN (d2)
   JOIN (pr
   WHERE (pr.person_id=m_rec->enc[d1.seq].prsnl[d2.seq].mf_prsnl_id)
    AND pr.active_ind=1)
  ORDER BY e.encntr_id, pr.person_id
  HEAD REPORT
   ml_cnt = 0, ml_cnt2 = 0
  HEAD e.encntr_id
   ml_cnt = (ml_cnt+ 1)
   IF (ml_cnt > size(m_rec->pat,5))
    CALL alterlist(m_rec->pat,(ml_cnt+ 100))
   ENDIF
   m_rec->pat[ml_cnt].s_encntr_id = trim(cnvtstring(e.encntr_id),3), m_rec->pat[ml_cnt].s_enc_beg_dt
    = m_rec->enc[d1.seq].ms_beg_dt_tm, m_rec->pat[ml_cnt].s_enc_end_dt = m_rec->enc[d1.seq].
   ms_end_dt_tm,
   m_rec->pat[ml_cnt].s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd),3), m_rec->pat[
   ml_cnt].s_fac = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->pat[ml_cnt].s_pat_name =
   trim(p.name_full_formatted,3),
   m_rec->pat[ml_cnt].s_mrn = trim(ea2.alias,3), m_rec->pat[ml_cnt].s_fin = trim(ea1.alias,3),
   ml_cnt2 = 0
  HEAD pr.person_id
   ml_cnt2 = (ml_cnt2+ 1),
   CALL alterlist(m_rec->pat[ml_cnt].prsnl,ml_cnt2), m_rec->pat[ml_cnt].prsnl[ml_cnt2].mf_prsnl_id =
   pr.person_id,
   m_rec->pat[ml_cnt].prsnl[ml_cnt2].ms_provider_name = trim(pr.name_full_formatted,3)
  FOOT REPORT
   CALL alterlist(m_rec->pat,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "No patients found with missing notes for this date range."
  GO TO exit_script
 ENDIF
 SELECT INTO value( $OUTDEV)
  encounter_id = trim(substring(1,50,m_rec->pat[d1.seq].s_encntr_id)), schedule_begin_date = trim(
   substring(1,200,m_rec->pat[d1.seq].s_enc_beg_dt)), schedule_end_date = trim(substring(1,200,m_rec
    ->pat[d1.seq].s_enc_end_dt)),
  encounter_type = trim(substring(1,200,m_rec->pat[d1.seq].s_encntr_type)), facility = trim(substring
   (1,200,m_rec->pat[d1.seq].s_fac)), patient_name = trim(substring(1,200,m_rec->pat[d1.seq].
    s_pat_name)),
  mrn = trim(substring(1,200,m_rec->pat[d1.seq].s_mrn)), fin = trim(substring(1,200,m_rec->pat[d1.seq
    ].s_fin)), booked_provider = trim(substring(1,200,m_rec->pat[d1.seq].prsnl[d2.seq].
    ms_provider_name))
  FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pat[d1.seq].prsnl,5)))
   JOIN (d2)
  WITH nocounter, format, separator = " ",
   maxrow = 1, maxcol = 2000
 ;end select
#exit_script
 IF (size(trim(ms_log),3) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, ms_log, col 0,
    row + 1,
    CALL print(concat("Beg Date: ",ms_beg_dt_tm)), col 0,
    row + 1,
    CALL print(concat("End Date: ",ms_end_dt_tm)), col 0,
    row + 1,
    CALL print(build2("mf_PROV_ID: ",mf_prov_id)), col 0,
    row + 1,
    CALL print(build2("mf_FACILITY_CD: ",mf_facility_cd))
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_rec
END GO
