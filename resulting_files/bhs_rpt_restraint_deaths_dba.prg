CREATE PROGRAM bhs_rpt_restraint_deaths:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Lookback Days" = "7"
  WITH outdev, lookback_days
 DECLARE mf_cs72_restrain_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BEHAVIORALLYRESTRAINED7DAYSPRIOR"))
 DECLARE mf_cs72_death_dt_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEOFPRONOUNCEMENTOFDEATH"))
 DECLARE mf_cs72_restraintsremoved_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RESTRAINTSREMOVED"))
 DECLARE mf_cs4_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE mf_dcp_forms_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_rpt_line = vc WITH protect, noconstant(" ")
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_subject_line = vc WITH protect, noconstant(curprog)
 DECLARE ml_lookback_days = i4 WITH protect, noconstant(cnvtint( $LOOKBACK_DAYS))
 FREE RECORD m_info
 RECORD m_info(
   1 l_ecnt = i4
   1 pat_list[*]
     2 l_pat_id = f8
     2 l_enc_id = f8
     2 s_pat_dob = vc
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_restrained_val = vc
     2 n_rm_rst_7d_b4_dth_ind = i2
     2 s_display_death_dt_tm = vc
     2 s_facility = vc
     2 s_admit_diagnosis = vc
     2 d_admission_dt_tm = dq8
     2 d_restraints_removed_dt_tm = dq8
     2 d_restraints_applied_dt_tm = dq8
     2 d_actual_death_dt_tm = dq8
 ) WITH protect
 FREE RECORD death_forms
 RECORD death_forms(
   1 l_death_form_ref_nbr_cnt = i4
   1 death_form_nbr_list[*]
     2 s_dfa_form_ref_nbr = vc
 ) WITH protect
 IF ( NOT (validate(reply->status_data.status,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF (findstring("@", $OUTDEV) > 0)
  SET ms_email_lower = cnvtlower( $OUTDEV)
  IF (((findstring("@bhs.org",ms_email_lower) > 0) OR (findstring("@baystatehealth.org",
   ms_email_lower) > 0)) )
   SET mn_email_ind = 1
   SET ms_address_list =  $OUTDEV
   SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtdatetime(sysdate),
      "MMDDYYYYHHMMSS;;D"),".csv"))
  ENDIF
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE dfr.active_ind=1
   AND dfr.description="Death Form - BHS"
   AND dfr.active_ind=1
  DETAIL
   mf_dcp_forms_ref_id = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, row + 1, "No form id found."
   WITH nocounter
  ;end select
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa,
   dcp_forms_ref dfr,
   code_value cv
  PLAN (dfa
   WHERE dfa.dcp_forms_ref_id=mf_dcp_forms_ref_id
    AND dfa.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dfa.form_status_cd
    AND  NOT (cv.display_key IN ("INERROR", "NOTDONE", "CANCELED")))
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=mf_dcp_forms_ref_id
    AND dfr.beg_effective_dt_tm <= dfa.version_dt_tm
    AND dfr.end_effective_dt_tm > dfa.version_dt_tm)
  ORDER BY dfa.dcp_forms_activity_id DESC
  HEAD REPORT
   death_forms->l_death_form_ref_nbr_cnt = 0
  HEAD dfa.dcp_forms_activity_id
   death_forms->l_death_form_ref_nbr_cnt += 1
   IF ((death_forms->l_death_form_ref_nbr_cnt > size(death_forms->death_form_nbr_list,5)))
    stat = alterlist(death_forms->death_form_nbr_list,(death_forms->l_death_form_ref_nbr_cnt+ 9))
   ENDIF
   death_forms->death_form_nbr_list[death_forms->l_death_form_ref_nbr_cnt].s_dfa_form_ref_nbr =
   concat(trim(cnvtstring(dfa.dcp_forms_activity_id)),"*")
  FOOT REPORT
   stat = alterlist(death_forms->death_form_nbr_list,death_forms->l_death_form_ref_nbr_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, row + 1, "No activity documented for this form."
   WITH nocounter
  ;end select
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_date_result cdr,
   (dummyt d1  WITH seq = death_forms->l_death_form_ref_nbr_cnt),
   person p,
   encounter e,
   person_alias pa
  PLAN (d1)
   JOIN (ce
   WHERE operator(ce.reference_nbr,"LIKE",patstring(death_forms->death_form_nbr_list[d1.seq].
     s_dfa_form_ref_nbr,1))
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd,
   mf_cs8_active_cd)
    AND ce.event_cd IN (mf_cs72_restrain_cd, mf_cs72_death_dt_tm_cd)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime((curdate - ml_lookback_days),0000) AND cnvtdatetime(
    curdate,235959))
   JOIN (cdr
   WHERE (cdr.event_id= Outerjoin(ce.event_id)) )
   JOIN (p
   WHERE p.person_id=ce.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(mf_cs4_mrn_cd)) )
   JOIN (e
   WHERE e.person_id=ce.person_id
    AND e.encntr_id=ce.encntr_id
    AND e.reg_dt_tm < sysdate
    AND ((e.disch_dt_tm <= sysdate) OR (e.disch_dt_tm=null)) )
  ORDER BY ce.encntr_id, ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.encntr_id
   m_info->l_ecnt += 1
   IF ((m_info->l_ecnt > size(m_info->pat_list,5)))
    CALL alterlist(m_info->pat_list,(m_info->l_ecnt+ 9))
   ENDIF
   m_info->pat_list[m_info->l_ecnt].s_pat_name = p.name_full_formatted, m_info->pat_list[m_info->
   l_ecnt].l_pat_id = p.person_id, m_info->pat_list[m_info->l_ecnt].l_enc_id = e.encntr_id,
   m_info->pat_list[m_info->l_ecnt].s_mrn = pa.alias, m_info->pat_list[m_info->l_ecnt].s_facility =
   uar_get_code_display(e.loc_facility_cd), m_info->pat_list[m_info->l_ecnt].s_pat_dob = format(
    cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"mm/dd/yy;;d"),
   m_info->pat_list[m_info->l_ecnt].d_admission_dt_tm = e.reg_dt_tm, m_info->pat_list[m_info->l_ecnt]
   .s_admit_diagnosis = e.reason_for_visit
  HEAD ce.event_cd
   CASE (ce.event_cd)
    OF mf_cs72_death_dt_tm_cd:
     m_info->pat_list[m_info->l_ecnt].d_actual_death_dt_tm = cdr.result_dt_tm
    OF mf_cs72_restrain_cd:
     m_info->pat_list[m_info->l_ecnt].s_restrained_val = trim(ce.result_val,3),m_info->pat_list[
     m_info->l_ecnt].d_restraints_applied_dt_tm = ce.performed_dt_tm
   ENDCASE
  FOOT REPORT
   stat = alterlist(m_info->pat_list,m_info->l_ecnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SELECT INTO value(ms_output_dest)
   FROM dummyt
   HEAD REPORT
    col 0, row + 1, "No data for this time frame."
   WITH nocounter, format, separator = " ",
    maxcol = 200
  ;end select
  IF (mn_email_ind=1)
   SET ms_subject_line = concat(ms_subject_line," NO RESULTS IN LAST 7 DAYS")
   GO TO exit_script
  ENDIF
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE expand(ml_idx,1,m_info->l_ecnt,ce.person_id,m_info->pat_list[ml_idx].l_pat_id,
   ce.encntr_id,m_info->pat_list[ml_idx].l_enc_id)
   AND ce.valid_until_dt_tm > sysdate
   AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd,
  mf_cs8_active_cd)
   AND ce.event_cd=mf_cs72_restraintsremoved_cd
  ORDER BY ce.encntr_id, ce.event_end_dt_tm DESC
  HEAD REPORT
   pos = 0
  HEAD ce.encntr_id
   pos = locateval(ml_idx,1,m_info->l_ecnt,ce.encntr_id,m_info->pat_list[ml_idx].l_enc_id)
  HEAD ce.event_cd
   IF (pos > 0)
    m_info->pat_list[pos].d_restraints_removed_dt_tm = ce.performed_dt_tm
   ENDIF
  WITH nocounter, expand = 0
 ;end select
 SELECT INTO value(ms_output_dest)
  FROM (dummyt d1  WITH seq = m_info->l_ecnt)
  HEAD REPORT
   pl_diff = 0, ms_rpt_line = build2("Hospital Name",",","Patient Name",",","Date of Birth",
    ",","MRN",",","Admitting Diagnosis",",",
    "Date of Admission",",","Date and Time of Death",",","Restraints removed 7 days prior to death",
    ",","Restraints applied 7 days prior to death",","), col 0,
   ms_rpt_line, row + 1
  HEAD d1.seq
   IF ( NOT ((m_info->pat_list[d1.seq].d_restraints_removed_dt_tm IN (0, null))))
    pl_diff = abs(datetimediff(m_info->pat_list[d1.seq].d_restraints_removed_dt_tm,m_info->pat_list[
      d1.seq].d_actual_death_dt_tm))
    IF (pl_diff <= 7)
     m_info->pat_list[d1.seq].n_rm_rst_7d_b4_dth_ind = 1
    ENDIF
   ENDIF
   IF (((cnvtupper(m_info->pat_list[d1.seq].s_restrained_val)="YES") OR ((m_info->pat_list[d1.seq].
   n_rm_rst_7d_b4_dth_ind=1))) )
    display_mrn = trim(m_info->pat_list[d1.seq].s_mrn,3), display_pat_name = trim(replace(m_info->
      pat_list[d1.seq].s_pat_name,",","-",0),3), display_facility = trim(m_info->pat_list[d1.seq].
     s_facility,3),
    display_death_tm = trim(format(cnvtdatetime(m_info->pat_list[d1.seq].d_actual_death_dt_tm),
      "mm/dd/yyyy hh:mm;;d"),3), display_dob = trim(m_info->pat_list[d1.seq].s_pat_dob,3),
    display_admit_diag = trim(replace(m_info->pat_list[d1.seq].s_admit_diagnosis,",","-",0),3),
    display_date_admit = trim(format(cnvtdatetime(m_info->pat_list[d1.seq].d_admission_dt_tm),
      "mm/dd/yyyy hh:mm;;d"),3)
    IF ((m_info->pat_list[d1.seq].n_rm_rst_7d_b4_dth_ind=1))
     display_restraints_removed = "Yes"
    ELSE
     display_restraints_removed = "No"
    ENDIF
    IF (cnvtupper(m_info->pat_list[d1.seq].s_restrained_val)="YES")
     display_restraints_applied = "Yes"
    ELSE
     display_restraints_applied = "No"
    ENDIF
    ms_rpt_line = build2(display_facility,",",display_pat_name,",",display_dob,
     ",",display_mrn,",",display_admit_diag,",",
     display_date_admit,",",display_death_tm,",",display_restraints_removed,
     ",",display_restraints_applied,","), col 0, ms_rpt_line,
    row + 1
   ENDIF
  WITH nocounter, maxcol = 3000, format,
   maxrow = 1
 ;end select
#exit_script
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(ms_output_dest,3)
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_in,ms_address_list,ms_subject_line,1)
  SET reply->status_data.status = "S"
  SET reply->ops_event = "Ops Job completed successfully"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
 ENDIF
#end_program
 FREE RECORD death_forms
 FREE RECORD m_info
END GO
