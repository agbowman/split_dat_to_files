CREATE PROGRAM bhs_rpt_sickle_cell_diag:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Facility" = 673936.00,
  "Nurse Unit" = 28300870.00,
  "Recipients" = ""
  WITH outdev, s_begin_date, s_end_date,
  f_facility_cd, f_nurse_unit_cd, s_recipients
 FREE RECORD data
 RECORD data(
   1 pats[*]
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_provider = vc
     2 s_diagnosis = vc
     2 s_hydrox_order = vc
     2 s_order_status = vc
     2 f_enc_id = f8
     2 f_pat_dob = f8
     2 f_last_seen_dt = f8
 ) WITH protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_os_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"
   ))
 DECLARE mf_os_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_os_inprocess_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"
   ))
 DECLARE mf_icd_10_cm_vocab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"ICD10CM"
   ))
 DECLARE mf_hydroxyurea_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROXYUREA"))
 DECLARE mf_attendingphysician_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN"))
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime( $S_END_DATE))
 DECLARE mf_facility_cd = f8 WITH protect, constant( $F_FACILITY_CD)
 DECLARE mf_nurse_unit_cd = f8 WITH protect, constant( $F_NURSE_UNIT_CD)
 DECLARE ms_recipients = vc WITH protect, constant(trim( $S_RECIPIENTS))
 DECLARE ml_num1 = i4 WITH protect, noconstant(0)
 DECLARE ml_num2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 IF (mf_begin_dt_tm > mf_end_dt_tm)
  SET ms_error = "Start Date must be less than End Date."
  GO TO exit_program
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   diagnosis d,
   nomenclature n,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl ps,
   person p
  PLAN (e
   WHERE e.loc_facility_cd=mf_facility_cd
    AND e.loc_nurse_unit_cd=mf_nurse_unit_cd
    AND e.reg_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d
   WHERE d.encntr_id=e.encntr_id
    AND d.active_ind=1
    AND d.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.source_vocabulary_cd=mf_icd_10_cm_vocab_cd
    AND n.source_identifier="D57*")
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_mrn_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=mf_attendingphysician_cd
    AND epr.prsnl_person_id != 0
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ps
   WHERE ps.person_id=epr.prsnl_person_id
    AND  NOT (ps.name_last_key IN ("NOTONSTAFF", "ADMTR"))
    AND ps.physician_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   ml_idx = 0
  DETAIL
   ml_idx += 1
   IF (ml_idx > size(data->pats,5))
    CALL alterlist(data->pats,(ml_idx+ 100))
   ENDIF
   data->pats[ml_idx].s_pat_name = p.name_full_formatted, data->pats[ml_idx].f_pat_dob =
   cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1), data->pats[ml_idx].f_enc_id = e
   .encntr_id,
   data->pats[ml_idx].s_mrn = ea.alias, data->pats[ml_idx].f_last_seen_dt = e.reg_dt_tm, data->pats[
   ml_idx].s_diagnosis = n.source_string,
   data->pats[ml_idx].s_provider = ps.name_full_formatted
  FOOT REPORT
   stat = alterlist(data->pats,ml_idx)
  WITH nocounter
 ;end select
 IF (size(data->pats,5)=0)
  SET ms_error = "No data was found."
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE expand(ml_num1,1,size(data->pats,5),o.encntr_id,data->pats[ml_num1].f_enc_id)
    AND o.catalog_cd=mf_hydroxyurea_order_cd
    AND o.order_status_cd IN (mf_os_ordered_cd, mf_os_completed_cd, mf_os_inprocess_cd))
  DETAIL
   ml_idx = locateval(ml_num2,1,size(data->pats,5),o.encntr_id,data->pats[ml_num2].f_enc_id), data->
   pats[ml_idx].s_hydrox_order = o.order_mnemonic, data->pats[ml_idx].s_order_status =
   uar_get_code_display(o.order_status_cd)
  WITH nocounter
 ;end select
 IF (textlen(ms_recipients) > 1)
  SET ms_file_name = build("sickle_cell_diagnosis_data",format(mf_begin_dt_tm,"mm/dd/yy ;;d"),"_to",
   format(mf_end_dt_tm,"mm/dd/yy ;;d"),".csv")
  SET ms_file_name = replace(ms_file_name,"/","_",0)
  SET ms_file_name = replace(ms_file_name," ","_",0)
  SET ms_subject = build2("Sickle Cell Diagnosis Data ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  SELECT INTO value(ms_file_name)
   patient_full_name_formatted = data->pats[d.seq].s_pat_name
   FROM (dummyt d  WITH seq = value(size(data->pats,5)))
   PLAN (d)
   ORDER BY patient_full_name_formatted
   HEAD REPORT
    ms_temp = concat(
     "PATIENT_NAME,PATIENT_DOB,PATIENT_MRN,PROVIDER_NAME,DIAGNOSIS,LAST_SEEN,HYDROXYUREA_ORDER,ORDER_STATUS"
     ), col 0, ms_temp
   DETAIL
    row + 1
    IF (textlen(data->pats[d.seq].s_hydrox_order)=0)
     data->pats[d.seq].s_hydrox_order = "Not Ordered"
    ENDIF
    ms_temp = build('"',trim(data->pats[d.seq].s_pat_name),'",','"',trim(format(data->pats[d.seq].
       f_pat_dob,"mm/dd/yyyy ;;d")),
     '",','"',trim(data->pats[d.seq].s_mrn),'",','"',
     trim(data->pats[d.seq].s_provider),'",','"',trim(data->pats[d.seq].s_diagnosis),'",',
     '"',trim(format(data->pats[d.seq].f_last_seen_dt,"mm/dd/yyyy;;d")),'",','"',trim(data->pats[d
      .seq].s_hydrox_order),
     '",','"',trim(data->pats[d.seq].s_order_status),'"'), col 0, ms_temp
   WITH nocounter, format = variable, formfeed = none,
    maxcol = 50000
  ;end select
  EXECUTE bhs_ma_email_file
  CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,200,data->pats[d.seq].s_pat_name), patient_dob = substring(1,200,format
    (data->pats[d.seq].f_pat_dob,"mm/dd/yyyy ;;d")), patient_mrn = substring(1,200,data->pats[d.seq].
    s_mrn),
   provider_name = substring(1,200,data->pats[d.seq].s_provider), diagnosis = substring(1,200,data->
    pats[d.seq].s_diagnosis), last_seen = substring(1,200,format(data->pats[d.seq].f_last_seen_dt,
     "mm/dd/yyyy;;d")),
   hydroxyurea_order =
   IF (textlen(data->pats[d.seq].s_hydrox_order)=0) "Not Ordered"
   ELSE substring(1,200,data->pats[d.seq].s_hydrox_order)
   ENDIF
   , order_status = substring(1,200,data->pats[d.seq].s_order_status)
   FROM (dummyt d  WITH seq = size(data->pats,5))
   PLAN (d)
   ORDER BY patient_name
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_program
 IF (textlen(ms_recipients) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "An email of the detailed report has been sent to:", msg2 = build2("     ",ms_recipients),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) != 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = ms_error, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
