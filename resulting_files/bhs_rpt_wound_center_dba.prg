CREATE PROGRAM bhs_rpt_wound_center:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 999999,
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients" = ""
  WITH outdev, f_facility_cd, s_begin_date,
  s_end_date, s_recipients
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
   1 pats[*]
     2 s_name = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_dob = vc
     2 s_disch_dt_tm = vc
     2 s_facility = vc
     2 s_wound_center = vc
     2 s_encntr_type = vc
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_disches_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES"))
 DECLARE mf_dischobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE mf_dischip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_dischdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHDAYSTAY"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_begin_dt_tm = cnvtdatetime((curdate - 1),000000)
  SET mf_end_dt_tm = cnvtdatetime((curdate - 1),235959)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_WOUND_CENTER"
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
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 93)
  SET ms_error = "Date range exceeds 3 months."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 IF (( $F_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
 ELSE
  SET ms_facility_p = concat("e.loc_facility_cd = ",trim(cnvtstring( $F_FACILITY_CD)))
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea2,
   pat_ed_document pd,
   pat_ed_doc_followup pf,
   organization o
  PLAN (e
   WHERE parser(ms_facility_p)
    AND e.disch_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND e.encntr_type_cd IN (mf_disches_cd, mf_dischobv_cd, mf_dischip_cd, mf_dischdaystay_cd)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mf_mrn_cd
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate)
   JOIN (pd
   WHERE pd.encntr_id=e.encntr_id)
   JOIN (pf
   WHERE pf.pat_ed_doc_id=pd.pat_ed_document_id
    AND pf.active_ind=1)
   JOIN (o
   WHERE o.organization_id=pf.organization_id
    AND o.org_name_key IN ("BAYSTATEWOUNDCAREWARE", "BAYSTATEWOUNDCAREANDHYPERBARICTREATMENT",
   "BFMCWOUNDCARE")
    AND o.active_ind=1
    AND o.end_effective_dt_tm > sysdate)
  ORDER BY e.loc_facility_cd, p.name_last, pf.updt_dt_tm DESC
  HEAD REPORT
   ml_cnt = 0
  HEAD e.encntr_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->pats,5))
    CALL alterlist(m_rec->pats,(ml_cnt+ 100))
   ENDIF
   m_rec->pats[ml_cnt].s_name = p.name_full_formatted, m_rec->pats[ml_cnt].s_fin = ea.alias, m_rec->
   pats[ml_cnt].s_mrn = ea2.alias,
   m_rec->pats[ml_cnt].s_dob = format(p.birth_dt_tm,"mm/dd/yyyy;;d"), m_rec->pats[ml_cnt].
   s_disch_dt_tm = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm;;d"), m_rec->pats[ml_cnt].s_facility =
   uar_get_code_display(e.loc_facility_cd),
   m_rec->pats[ml_cnt].s_wound_center = pf.provider_name, m_rec->pats[ml_cnt].s_encntr_type =
   uar_get_code_display(e.encntr_class_cd)
  FOOT REPORT
   CALL alterlist(m_rec->pats,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  SET frec->file_name = build("bhs_rpt_wound_center_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
   "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy ;;d"),3),".csv")
  SET ms_subject = build2("Wound Center Follow Up Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm ;;d")))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"ACC #",','"MRN",','"DOB",','"ENCNTR_TYPE",',
   '"DISCHARGE DT TM",','"FACILITY",','"WOUND CENTER",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO size(m_rec->pats,5))
   SET frec->file_buf = build('"',trim(m_rec->pats[ml_cnt].s_name,3),'","',trim(m_rec->pats[ml_cnt].
     s_fin,3),'","',
    trim(m_rec->pats[ml_cnt].s_mrn,3),'","',trim(m_rec->pats[ml_cnt].s_dob,3),'","',trim(m_rec->pats[
     ml_cnt].s_encntr_type,3),
    '","',trim(m_rec->pats[ml_cnt].s_disch_dt_tm,3),'","',trim(m_rec->pats[ml_cnt].s_facility,3),
    '","',
    trim(m_rec->pats[ml_cnt].s_wound_center,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,50,m_rec->pats[d.seq].s_name), acc# = substring(1,50,m_rec->pats[d.seq]
    .s_fin), mrn = substring(1,50,m_rec->pats[d.seq].s_mrn),
   dob = substring(1,50,m_rec->pats[d.seq].s_dob), encntr_type = substring(1,50,m_rec->pats[d.seq].
    s_encntr_type), discharge_dt_tm = substring(1,50,m_rec->pats[d.seq].s_disch_dt_tm),
   facility = substring(1,50,m_rec->pats[d.seq].s_facility), wound_center = substring(1,50,m_rec->
    pats[d.seq].s_wound_center)
   FROM (dummyt d  WITH seq = size(m_rec->pats,5))
   PLAN (d)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 IF (mn_ops=1)
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
    msg1 = ms_error, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
