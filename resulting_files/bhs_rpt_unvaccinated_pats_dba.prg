CREATE PROGRAM bhs_rpt_unvaccinated_pats:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients" = ""
  WITH outdev, s_begin_date, s_end_date,
  s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 s_patient_name = vc
     2 s_mrn = vc
     2 s_dob = vc
     2 s_sex = vc
     2 s_dtap = vc
     2 s_hep_b = vc
     2 s_mmr = vc
 ) WITH protect
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_immunization_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,
   "IMMUNIZATION"))
 DECLARE mf_hepb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEPATITISBPEDIATRICVACCINE"))
 DECLARE mf_mmr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEASLESMUMPSRUBELLAVIRUSVACCINE"))
 DECLARE mf_dtap_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIPHTHERIATETANUSPERTUSSISACELDTAP"))
 DECLARE mf_pss_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"PSS"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_begin_dt_tm = cnvtlookbehind("18, Y",sysdate)
  SET mf_end_dt_tm = cnvtdatetime(curdate,curtime)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_UNVACCINATED_PATS"
    AND di.info_char="EMAIL"
   ORDER BY di.info_name
   DETAIL
    IF (textlen(trim(ms_recipients,3)) < 1)
     ms_recipients = trim(di.info_name,3)
    ELSE
     ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cnvtdatetime(mf_begin_dt_tm) > cnvtdatetime(mf_end_dt_tm))
  SET ms_error = "Start date must be less than end date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 6577)
  SET ms_error = "Date range exceeds 18 years."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   clinical_event ce,
   encntr_alias ea
  PLAN (e
   WHERE e.loc_facility_cd=mf_pss_cd
    AND e.reg_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.birth_dt_tm BETWEEN cnvtlookbehind("18, Y",sysdate) AND sysdate)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.event_cd IN (mf_hepb_cd, mf_mmr_cd, mf_dtap_cd)
    AND ce.event_class_cd=mf_immunization_cd
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.view_level=1
    AND ce.publish_flag=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_mrn_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY p.name_full_formatted, p.person_id
  HEAD REPORT
   ml_cnt = 0
  HEAD p.person_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].s_patient_name = trim(p.name_full_formatted,3), m_rec->qual[ml_cnt].s_dob =
   trim(format(p.birth_dt_tm,"mm/dd/yyyy ;;d"),3), m_rec->qual[ml_cnt].s_sex = trim(
    uar_get_code_display(p.sex_cd),3),
   m_rec->qual[ml_cnt].s_mrn = trim(ea.alias,3), m_rec->qual[ml_cnt].s_dtap = "Missing", m_rec->qual[
   ml_cnt].s_hep_b = "Missing",
   m_rec->qual[ml_cnt].s_mmr = "Missing"
  HEAD ce.event_id
   CASE (ce.event_cd)
    OF mf_hepb_cd:
     m_rec->qual[ml_cnt].s_hep_b = build2("Administered ",trim(format(ce.clinsig_updt_dt_tm,
        "mm/dd/yyyy ;;d"),3))
    OF mf_mmr_cd:
     m_rec->qual[ml_cnt].s_mmr = build2("Administered ",trim(format(ce.clinsig_updt_dt_tm,
        "mm/dd/yyyy ;;d"),3))
    OF mf_dtap_cd:
     m_rec->qual[ml_cnt].s_dtap = build2("Administered ",trim(format(ce.clinsig_updt_dt_tm,
        "mm/dd/yyyy ;;d"),3))
   ENDCASE
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_cnt = ml_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
   "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy;;d"),3),
   ".csv")
  SET ms_subject = build2("Unvaccinated Patients Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"SEX",','"DATE OF BIRTH",','"MRN#",','"DTAP",',
   '"HEPATITIS B",','"MMR",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_cnt)
    IF ((m_rec->qual[ml_cnt].s_dtap="Missing")
     AND (m_rec->qual[ml_cnt].s_hep_b="Missing")
     AND (m_rec->qual[ml_cnt].s_mmr="Missing"))
     SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_patient_name,3),'","',trim(m_rec->
       qual[ml_cnt].s_sex,3),'","',
      trim(m_rec->qual[ml_cnt].s_dob,3),'","',trim(m_rec->qual[ml_cnt].s_mrn,3),'","',trim(m_rec->
       qual[ml_cnt].s_dtap,3),
      '","',trim(m_rec->qual[ml_cnt].s_hep_b,3),'","',trim(m_rec->qual[ml_cnt].s_mmr,3),'"',
      char(13))
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,100,m_rec->qual[d.seq].s_patient_name), sex = substring(1,100,m_rec->
    qual[d.seq].s_sex), date_of_birth = substring(1,100,m_rec->qual[d.seq].s_dob),
   mrn# = substring(1,100,m_rec->qual[d.seq].s_mrn), dtap = substring(1,100,m_rec->qual[d.seq].s_dtap
    ), hepatitis_b = substring(1,100,m_rec->qual[d.seq].s_hep_b),
   mmr = substring(1,100,m_rec->qual[d.seq].s_mmr)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   WHERE (m_rec->qual[d.seq].s_dtap="Missing")
    AND (m_rec->qual[d.seq].s_hep_b="Missing")
    AND (m_rec->qual[d.seq].s_mmr="Missing")
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
 FREE RECORD frec
 IF (((mn_ops=1) OR (textlen(trim( $OUTDEV,3))=0)) )
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
 ENDIF
END GO
