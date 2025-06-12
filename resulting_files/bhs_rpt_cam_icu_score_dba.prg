CREATE PROGRAM bhs_rpt_cam_icu_score:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Nurse Unit" = 0,
  "Beg Dt Tm:" = "CURDATE",
  "End Dt Tm:" = "CURDATE",
  "Email:" = "",
  "Print Unit Totals?:" = "NO"
  WITH outdev, f_nurse_unit_cd, s_beg_dt_tm,
  s_end_dt_tm, s_email, s_print_unit_totals
 FREE RECORD m_rec
 RECORD m_rec(
   1 units[*]
     2 f_cd = f8
     2 s_disp = vc
   1 pat[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_facility = vc
     2 s_nurse_unit = vc
     2 s_name = vc
     2 s_dob = vc
     2 s_fin = vc
     2 s_admit_loc = vc
     2 s_admit_dt_tm = vc
     2 s_attending = vc
     2 s_score = vc
     2 s_score_dt_tm = vc
     2 s_score_gt_3 = vc
     2 s_score_gt_3_dt_tm = vc
     2 s_rass = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT_TM)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT_TM)," 23:59:59"))
 DECLARE ms_email = vc WITH protect, constant(trim( $S_EMAIL))
 DECLARE ms_print_totals = vc WITH protect, constant(trim(cnvtupper( $S_PRINT_UNIT_TOTALS)))
 DECLARE mn_unit_param = i2 WITH protect, constant(2)
 DECLARE ms_email_file = vc WITH protect, constant(concat("bhs_rpt_camicu",trim(format(sysdate,
     "mmddyyhhmm;;d")),".csv"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_inpat_typ_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT")
  )
 DECLARE mf_cam_score_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CAMICUSCORE"))
 DECLARE mf_rass_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RICHMONDAGITATIONSEDATIONSCALERASS"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_attending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE mf_cur_name_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",213,"CURRENT"))
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mf_tmp = f8 WITH protect, noconstant(0.0)
 DECLARE ms_param_type = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 IF (((textlen(ms_beg_dt_tm)=0) OR (textlen(ms_end_dt_tm)=0)) )
  SET ms_log = "Begin date and End date must have values"
  GO TO exit_script
 ELSEIF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  SET ms_log = "Begin date must be greater than End date"
  GO TO exit_script
 ENDIF
 SET ms_param_type = reflect(parameter(mn_unit_param,0))
 IF (substring(1,1,ms_param_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(textlen(ms_param_type) - 1),ms_param_type)))
    SET mf_tmp = cnvtreal(parameter(mn_unit_param,ml_cnt))
    CALL alterlist(m_rec->units,ml_cnt)
    SET m_rec->units[ml_cnt].f_cd = mf_tmp
    SET m_rec->units[ml_cnt].s_disp = trim(uar_get_code_display(mf_tmp),3)
  ENDFOR
 ELSE
  IF (cnvtreal( $F_NURSE_UNIT_CD)=0.0)
   SET ms_log = "Nurse unit(s) must be selected"
   GO TO exit_script
  ENDIF
  CALL alterlist(m_rec->units,1)
  SET m_rec->units[1].f_cd = cnvtreal( $F_NURSE_UNIT_CD)
  SET m_rec->units[1].s_disp = trim(uar_get_code_display(cnvtreal( $F_NURSE_UNIT_CD)),3)
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encntr_loc_hist elh,
   encounter e,
   person p,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   person_name pn
  PLAN (ce
   WHERE ce.event_cd IN (mf_rass_cd, mf_cam_score_cd)
    AND ce.valid_until_dt_tm >= sysdate
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
    AND ce.performed_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (elh
   WHERE elh.encntr_id=ce.encntr_id
    AND elh.active_ind=1
    AND elh.beg_effective_dt_tm <= ce.performed_dt_tm
    AND elh.end_effective_dt_tm >= ce.performed_dt_tm
    AND (elh.loc_nurse_unit_cd= $F_NURSE_UNIT_CD))
   JOIN (e
   WHERE e.encntr_id=elh.encntr_id
    AND e.active_ind=1
    AND e.encntr_type_class_cd=mf_inpat_typ_cls_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(e.encntr_id)
    AND epr.active_ind=outerjoin(1)
    AND epr.end_effective_dt_tm > outerjoin(e.reg_dt_tm)
    AND epr.encntr_prsnl_r_cd=mf_attending_cd)
   JOIN (pn
   WHERE pn.person_id=outerjoin(epr.prsnl_person_id)
    AND pn.active_ind=outerjoin(1)
    AND pn.end_effective_dt_tm > outerjoin(sysdate)
    AND pn.name_type_cd=outerjoin(mf_cur_name_cd))
  ORDER BY e.encntr_id, ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD e.encntr_id
   pl_cnt = (pl_cnt+ 1),
   CALL alterlist(m_rec->pat,pl_cnt), m_rec->pat[pl_cnt].f_encntr_id = e.encntr_id,
   m_rec->pat[pl_cnt].f_person_id = e.person_id, m_rec->pat[pl_cnt].s_name = trim(p
    .name_full_formatted,3), m_rec->pat[pl_cnt].s_dob = trim(format(p.birth_dt_tm,"mm/dd/yy;;d")),
   m_rec->pat[pl_cnt].s_fin = trim(ea.alias,3), m_rec->pat[pl_cnt].s_facility = trim(
    uar_get_code_display(e.loc_facility_cd),3), m_rec->pat[pl_cnt].s_nurse_unit = trim(
    uar_get_code_display(e.loc_nurse_unit_cd),3),
   m_rec->pat[pl_cnt].s_attending = concat(trim(pn.name_last,3)," ",trim(pn.name_suffix,3),", ",trim(
     pn.name_first,3))
  HEAD ce.event_cd
   IF (ce.event_cd=mf_rass_cd)
    m_rec->pat[pl_cnt].s_rass = trim(ce.result_val)
   ELSEIF (ce.event_cd=mf_cam_score_cd)
    m_rec->pat[pl_cnt].s_score = trim(ce.result_val), m_rec->pat[pl_cnt].s_score_dt_tm = trim(format(
      ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE expand(ml_exp,1,size(m_rec->pat,5),ce.encntr_id,m_rec->pat[ml_exp].f_encntr_id,
    ce.person_id,m_rec->pat[ml_exp].f_person_id)
    AND ce.event_cd IN (mf_cam_score_cd)
    AND ce.valid_until_dt_tm >= sysdate
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
    AND cnvtint(ce.result_val) >= 3)
  ORDER BY ce.encntr_id, ce.event_end_dt_tm DESC
  HEAD ce.encntr_id
   ml_idx = locateval(ml_loc,1,size(m_rec->pat,5),ce.encntr_id,m_rec->pat[ml_loc].f_encntr_id), m_rec
   ->pat[ml_idx].s_score_gt_3 = trim(ce.result_val,3), m_rec->pat[ml_idx].s_score_gt_3_dt_tm = trim(
    format(ce.performed_dt_tm,"mm/dd/yy hh:mm;;d"))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh,
   code_value cv
  PLAN (elh
   WHERE expand(ml_exp,1,size(m_rec->pat,5),elh.encntr_id,m_rec->pat[ml_exp].f_encntr_id))
   JOIN (cv
   WHERE cv.code_value=elh.loc_nurse_unit_cd
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.data_status_cd=mf_auth_cd
    AND cv.cdf_meaning="NURSEUNIT")
  ORDER BY elh.encntr_id, elh.beg_effective_dt_tm
  HEAD elh.encntr_id
   ml_idx = locateval(ml_loc,1,size(m_rec->pat,5),elh.encntr_id,m_rec->pat[ml_loc].f_encntr_id),
   m_rec->pat[ml_idx].s_admit_dt_tm = trim(format(elh.beg_effective_dt_tm,"mm/dd/yy hh:mm;;dd")),
   m_rec->pat[ml_idx].s_admit_loc = trim(uar_get_code_display(elh.loc_nurse_unit_cd),3)
  WITH nocounter
 ;end select
 IF (size(m_rec->pat,5) > 0)
  IF (textlen(trim(ms_email)) > 0
   AND findstring("@",ms_email) > 0)
   SELECT INTO value(ms_email_file)
    nurse_unit = m_rec->pat[d.seq].s_nurse_unit
    FROM (dummyt d  WITH seq = value(size(m_rec->pat,5)))
    PLAN (d)
    ORDER BY nurse_unit
    HEAD REPORT
     col 0, "CAM ICU SCORES, , , , , , , , , , , ,", row + 1,
     ms_tmp = ""
     FOR (ml_cnt = 1 TO size(m_rec->units,5))
      IF (ml_cnt > 1)
       ms_tmp = concat(ms_tmp,", ")
      ENDIF
      ,ms_tmp = concat(ms_tmp,m_rec->units[ml_cnt].s_disp)
     ENDFOR
     col 0,
     CALL print(concat("Nursing Unit(s):,",'"',ms_tmp,'", , , , , , , , , , ,')), row + 1,
     col 0,
     CALL print(concat("Date Range:,",ms_beg_dt_tm," to ",ms_end_dt_tm,", , , , , , , , , , ,")), row
      + 1,
     col 0, ", , , , , , , , , , , ,", row + 1,
     col 0,
     CALL print(concat(
      '"FACILITY","NURSE UNIT","PATIENT NAME","DATE OF BIRTH","FIN NUMBER","IP ADMIT LOC",',
      '"UNIT ADMIT TIME","ATTENDING MD","CAM-ICU SCORE","CAM-ICU SCORE PERFORMED ON",',
      '"CAM-ICU SCORE >= 3","CAM-ICU SCORE >= 3 PERFORMED ON","RASS"')), row + 1
    DETAIL
     ms_tmp = concat('"',m_rec->pat[d.seq].s_facility,'",','"',m_rec->pat[d.seq].s_nurse_unit,
      '",','"',m_rec->pat[d.seq].s_name,'",','"',
      m_rec->pat[d.seq].s_dob,'",','"',m_rec->pat[d.seq].s_fin,'",',
      '"',m_rec->pat[d.seq].s_admit_loc,'",','"',m_rec->pat[d.seq].s_admit_dt_tm,
      '",','"',m_rec->pat[d.seq].s_attending,'",','"',
      m_rec->pat[d.seq].s_score,'",','"',m_rec->pat[d.seq].s_score_dt_tm,'",',
      '"',m_rec->pat[d.seq].s_score_gt_3,'",','"',m_rec->pat[d.seq].s_score_gt_3_dt_tm,
      '",','"',m_rec->pat[d.seq].s_rass,'"'), col 0, ms_tmp,
     row + 1
    FOOT REPORT
     col 0, ", , , , , , , , , , , ,", row + 1
     IF (ms_print_totals="YES")
      col 0,
      CALL print(concat("Total # of forms:,",trim(cnvtstring(size(m_rec->pat,5))),
       ", , , , , , , , , , ,")), row + 1
     ENDIF
     col 0, ", , , , , , , , , , , ,", row + 1,
     col 0,
     CALL print(concat("Input Source Powerform: ,",
      '"Confusion Assessment Method for the ICU (CAM-ICU)",',", , , , , , , , , , "))
    WITH nocounter, maxcol = 500
   ;end select
   EXECUTE bhs_ma_email_file
   CALL emailfile(ms_email_file,ms_email_file,ms_email,concat("CAM-ICU Score Report ",trim(format(
       sysdate,"mm/dd/yy hh:mm;;d"))),1)
  ENDIF
  SELECT INTO value( $OUTDEV)
   facility = m_rec->pat[d.seq].s_facility, nurse_unit = m_rec->pat[d.seq].s_nurse_unit, patient_name
    = m_rec->pat[d.seq].s_name,
   date_of_birth = m_rec->pat[d.seq].s_dob, fin_number = m_rec->pat[d.seq].s_fin, ip_admit_time =
   m_rec->pat[d.seq].s_admit_dt_tm,
   unit_admit_time = m_rec->pat[d.seq].s_admit_loc, attending_md = m_rec->pat[d.seq].s_attending,
   cam_icu_score = m_rec->pat[d.seq].s_score,
   cam_icu_score_performed_on = m_rec->pat[d.seq].s_score_dt_tm, cam_icu_score_gt_3 = m_rec->pat[d
   .seq].s_score_gt_3, cam_icu_score_gt_3_performed_on = m_rec->pat[d.seq].s_score_gt_3_dt_tm,
   rass = m_rec->pat[d.seq].s_rass
   FROM (dummyt d  WITH seq = value(size(m_rec->pat,5)))
   PLAN (d)
   ORDER BY nurse_unit
   WITH nocounter, maxrow = 1, maxcol = 500,
    format, separator = " "
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, "No data found", row + 1
    IF (textlen(trim(ms_email)) > 0
     AND findstring("@",ms_email) > 0)
     col 0,
     CALL print(concat("No email will be sent to ",ms_email))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (textlen(ms_log) > 0)
  CALL echo(ms_log)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, ms_log, row + 1,
    col 0, "no email will be sent"
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
