CREATE PROGRAM bhs_rpt_phq9_form:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin dt/tm:" = "SYSDATE",
  "End dt/tm:" = "SYSDATE",
  "Recipients (Separate emails with a comma)" = ""
  WITH outdev, s_begin_date, s_end_date,
  s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 RECORD data(
   1 patients[*]
     2 s_patient_name = vc
     2 s_patient_dob = vc
     2 s_mrn = vc
     2 s_form_completed = vc
     2 s_severity_score = vc
     2 s_patient_location = vc
     2 s_author_name = vc
 ) WITH protect
 EXECUTE bhs_check_domain:dba
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_severity_score_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHQ9SEVERITYSCORE"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ms_date_range = vc WITH protect, noconstant(" ")
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  IF (day(curdate)=1)
   SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(curdate,000000),0)
   SET mf_end_dt_tm = cnvtdatetime((curdate - 1),235959)
  ELSE
   SET mf_begin_dt_tm = cnvtlookbehind(build2('"',day((curdate - 1)),', D"'),cnvtdatetime(curdate,
     000000),0)
   SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(mf_begin_dt_tm),0)
   SET mf_end_dt_tm = cnvtlookbehind(build2('"',day(curdate),', D"'),cnvtdatetime(curdate,000000),0)
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_PHQ9_FORM"
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
  SET ms_error = "Start Date must be less than End Date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 366)
  SET ms_error = "Date Range exceeds 1 year."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   encntr_alias ea,
   person p,
   prsnl ps
  PLAN (ce
   WHERE ce.event_cd=mf_severity_score_cd
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100")
    AND ce.view_level=1)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_mrn_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ps
   WHERE ps.person_id=ce.performed_prsnl_id)
  ORDER BY ce.event_end_dt_tm, e.reg_dt_tm, p.name_last
  HEAD REPORT
   ml_idx = 0
  DETAIL
   ml_idx = (ml_idx+ 1)
   IF (ml_idx > size(data->patients,5))
    CALL alterlist(data->patients,(ml_idx+ 100))
   ENDIF
   data->patients[ml_idx].s_patient_name = trim(p.name_full_formatted,3), data->patients[ml_idx].
   s_patient_dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy"),3), data->patients[ml_idx].s_mrn = trim(ea
    .alias,3),
   data->patients[ml_idx].s_form_completed = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"),3),
   data->patients[ml_idx].s_severity_score = trim(ce.event_tag), data->patients[ml_idx].s_author_name
    = trim(ps.name_full_formatted),
   data->patients[ml_idx].s_patient_location = concat(trim(uar_get_code_display(e.loc_facility_cd),3),
    "/",trim(uar_get_code_display(e.loc_nurse_unit_cd),3))
  FOOT REPORT
   CALL alterlist(data->patients,ml_idx)
  WITH nocounter, format, separator = " "
 ;end select
 SET ms_date_range = build2(format(mf_begin_dt_tm,"mm/dd/yy ;;d")," - ",format(mf_end_dt_tm,
   "mm/dd/yy ;;d"))
 IF (curqual=0)
  SET ms_error = "No data found."
  IF (mn_ops=1
   AND gl_bhs_prod_flag=1)
   CALL uar_send_mail("CIScore@bhs.org","OPS Job Fail",build2("bhs_rpt_phq9_form ops job executed in",
     curdomain," - no data was found for the date range: ",ms_date_range),"OPS JOB",1,
    "")
  ENDIF
  GO TO exit_script
 ENDIF
 IF (((textlen( $S_RECIPIENTS) > 1) OR (mn_ops=1)) )
  SET ms_file_name = build("bhs_rpt_phq9_form_",trim(format(mf_begin_dt_tm,"mm/dd/yy ;;d"),3),"_to_",
   trim(format(mf_end_dt_tm,"mm/dd/yy ;;d"),3),".csv")
  SET ms_file_name = replace(ms_file_name,"/","_",0)
  SET ms_file_name = replace(ms_file_name," ","_",0)
  SET ms_subject = build2("PHQ-9 Powerform Report ",trim(format(mf_begin_dt_tm,"mmm-dd-yyyy;;d"),3),
   " to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy;;d"),3))
  SELECT INTO value(ms_file_name)
   FROM (dummyt d  WITH seq = size(data->patients,5))
   PLAN (d)
   HEAD REPORT
    ms_temp = concat("PATIENT FULL NAME,PATIENT DOB,MRN,PHQ-9 FORM COMPLETED",
     ",SEVERITY SCORE,LOCATION,AUTHOR OF DOCUMENT"), col 0, ms_temp
   DETAIL
    row + 1, ms_temp = build('"',data->patients[d.seq].s_patient_name,'",','"',data->patients[d.seq].
     s_patient_dob,
     '",','"',data->patients[d.seq].s_mrn,'",','"',
     data->patients[d.seq].s_form_completed,'",','"',data->patients[d.seq].s_severity_score,'",',
     '"',data->patients[d.seq].s_patient_location,'",','"',data->patients[d.seq].s_author_name,
     '"'), col 0,
    ms_temp
   WITH nocounter, format = variable, formfeed = none,
    maxcol = 5000
  ;end select
  EXECUTE bhs_ma_email_file
  CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name_full_formatted = data->patients[d.seq].s_patient_name, patient_dob = data->patients[d
   .seq].s_patient_dob, mrn = data->patients[d.seq].s_mrn,
   phq9_form_completed = data->patients[d.seq].s_form_completed, severity_score = data->patients[d
   .seq].s_severity_score, location = data->patients[d.seq].s_patient_location,
   author_of_document = data->patients[d.seq].s_author_name
   FROM (dummyt d  WITH seq = size(data->patients,5))
   PLAN (d)
   ORDER BY phq9_form_completed
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen( $S_RECIPIENTS) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "An email of the detailed report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
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
