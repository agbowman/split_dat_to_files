CREATE PROGRAM bhs_rpt_interpreter_detail:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Ops Frequency (Hidden from user)" = "MANUAL",
  "Facility" = value(999999),
  "Nurse Unit" = value(999999),
  "Interpretation Method" = "",
  "Language" = value("*"),
  "Successful Interpretations" = "*",
  "Form Result Status" = value(auth(verified),modified),
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients" = ""
  WITH outdev, s_ops_freq, f_facility_cd,
  f_nurse_unit_cd, s_interpretation_method, s_language,
  s_success, f_result_status_cd, s_begin_date,
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
   1 l_qual_cnt = i4
   1 l_filtered_cnt = i4
   1 qual[*]
     2 s_interpreter_name = vc
     2 s_language_spoken = vc
     2 s_encounter_type = vc
     2 s_staff_utilizing = vc
     2 s_successful_inter = vc
     2 s_reason = vc
     2 s_inter_method = vc
     2 s_pat_fin = vc
     2 s_number_of_staff = vc
     2 s_inter_start_dt_tm = vc
     2 s_filing_dt_tm = vc
     2 f_inter_duration = f8
     2 f_filing_time_diff = f8
     2 f_interpreter_id = f8
     2 f_person_id = f8
     2 s_cmrn = vc
   1 filtered[*]
     2 s_interpreter_name = vc
     2 s_pat_fin = vc
     2 s_language_spoken = vc
     2 s_encounter_type = vc
     2 s_staff_utilizing = vc
     2 s_successful_inter = vc
     2 s_reason = vc
     2 s_inter_method = vc
     2 s_number_of_staff = vc
     2 s_inter_start_dt_tm = vc
     2 s_filing_dt_tm = vc
     2 s_inter_duration = vc
     2 s_filing_time_diff = vc
     2 f_person_id = f8
     2 s_cmrn = vc
 ) WITH protect
 DECLARE mf_cs4_cmrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_inter_serv_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERPRETERSERVICEENCOUNTERFORM"))
 DECLARE mf_dcp_generic_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DCPGENERICCODE"))
 DECLARE mf_encounter_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ENCOUNTERTYPE"))
 DECLARE mf_staff_utilizing_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "STAFFUTILIZINGINTERPRETER"))
 DECLARE mf_inter_start_dt_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERPRETATIONSTARTDATETIME"))
 DECLARE mf_inter_end_dt_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERPRETATATIONENDDATETIME"))
 DECLARE mf_successful_inter_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SUCCESSFULINTERPRETATION"))
 DECLARE mf_num_of_staff_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFSTAFFINTERPRETEDFOR"))
 DECLARE mf_language_spoken_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "LANGUAGESPOKENV001"))
 DECLARE mf_inter_method_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERPRETATIONMETHOD"))
 DECLARE mf_reason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REASONINTERPRETERDIDNOTINTERPRET"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE mf_inter_beg_dt_tm = f8 WITH protect, noconstant(0)
 DECLARE mf_inter_end_dt_tm = f8 WITH protect, noconstant(0)
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit_p = vc WITH protect, noconstant("")
 DECLARE ms_inter_method_p = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  IF (( $S_OPS_FREQ="DAILY"))
   SET mf_begin_dt_tm = cnvtdatetime((curdate - 1),000000)
   SET mf_end_dt_tm = cnvtdatetime((curdate - 1),235959)
   SET ms_subject = build2("Interpreter Sessions Detail Daily Report ",trim(format(mf_begin_dt_tm,
      "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  ELSEIF (( $S_OPS_FREQ="MONTHLY"))
   SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(((curdate - day(curdate))+ 1),000000))
   SET mf_end_dt_tm = cnvtdatetime((curdate - day(curdate)),235959)
   SET ms_subject = build2("Interpreter Sessions Detail Monthly Report ",trim(format(mf_begin_dt_tm,
      "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_INTERPRETER_DETAIL"
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
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1)
  SET ms_subject = build2("Interpreter Sessions Detail Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
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
 SET ms_item_list = reflect(parameter(3,0))
 IF (( $F_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (ml_loop = 1 TO ml_cnt)
    IF (ml_loop=1)
     SET ms_facility_p = build2("e.loc_facility_cd in (",parameter(3,ml_loop))
    ELSE
     SET ms_facility_p = build2(ms_facility_p,",",parameter(3,ml_loop))
    ENDIF
  ENDFOR
  SET ms_facility_p = concat(ms_facility_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_facility_p = build2("e.loc_facility_cd = ",parameter(3,0))
 ENDIF
 SET ms_item_list = reflect(parameter(4,0))
 IF (( $F_NURSE_UNIT_CD=999999))
  SET ms_nurse_unit_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (ml_loop = 1 TO ml_cnt)
    IF (ml_loop=1)
     SET ms_nurse_unit_p = build2("e.loc_nurse_unit_cd in (",parameter(4,ml_loop))
    ELSE
     SET ms_nurse_unit_p = build2(ms_nurse_unit_p,",",parameter(4,ml_loop))
    ENDIF
  ENDFOR
  SET ms_nurse_unit_p = concat(ms_nurse_unit_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_nurse_unit_p = build2("e.loc_nurse_unit_cd = ",parameter(4,0))
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce1,
   encounter e,
   clinical_event ce2,
   clinical_event ce3,
   prsnl pr,
   encntr_alias ea,
   ce_date_result cedr
  PLAN (ce1
   WHERE ce1.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce1.event_cd=mf_inter_serv_form_cd
    AND (ce1.result_status_cd= $F_RESULT_STATUS_CD)
    AND ce1.view_level=1
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce1.publish_flag=1)
   JOIN (e
   WHERE e.encntr_id=ce1.encntr_id
    AND parser(ms_facility_p)
    AND parser(ms_nurse_unit_p)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.event_cd=mf_dcp_generic_cd
    AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ce3
   WHERE ce3.parent_event_id=ce2.event_id
    AND ce3.event_cd IN (mf_inter_start_dt_tm_cd, mf_inter_end_dt_tm_cd, mf_successful_inter_cd,
   mf_num_of_staff_cd, mf_language_spoken_cd,
   mf_reason_cd, mf_inter_method_cd, mf_encounter_type_cd, mf_staff_utilizing_cd)
    AND ce3.view_level=1
    AND ce3.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce3.publish_flag=1
    AND ce3.event_tag != "In Error")
   JOIN (pr
   WHERE pr.person_id=ce1.performed_prsnl_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (cedr
   WHERE (cedr.event_id= Outerjoin(ce3.event_id)) )
  ORDER BY pr.name_full_formatted, pr.person_id, ea.alias,
   ce1.event_id
  HEAD REPORT
   ml_cnt = 0
  HEAD ce1.event_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].f_interpreter_id = pr.person_id, m_rec->qual[ml_cnt].s_interpreter_name = pr
   .name_full_formatted, m_rec->qual[ml_cnt].s_pat_fin = ea.alias,
   m_rec->qual[ml_cnt].s_filing_dt_tm = format(ce1.performed_dt_tm,"mm/dd/yyyy HH:mm;;d"), m_rec->
   qual[ml_cnt].f_person_id = e.person_id
  HEAD ce3.event_id
   CASE (ce3.event_cd)
    OF mf_inter_start_dt_tm_cd:
     mf_inter_beg_dt_tm = cedr.result_dt_tm,m_rec->qual[ml_cnt].s_inter_start_dt_tm = format(cedr
      .result_dt_tm,"mm/dd/yyyy HH:mm;;d"),m_rec->qual[ml_cnt].f_filing_time_diff = datetimediff(ce1
      .performed_dt_tm,cedr.result_dt_tm,3)
    OF mf_inter_end_dt_tm_cd:
     mf_inter_end_dt_tm = cedr.result_dt_tm
    OF mf_successful_inter_cd:
     m_rec->qual[ml_cnt].s_successful_inter = trim(cnvtupper(ce3.result_val),3)
    OF mf_num_of_staff_cd:
     m_rec->qual[ml_cnt].s_number_of_staff = trim(ce3.result_val,3)
    OF mf_language_spoken_cd:
     m_rec->qual[ml_cnt].s_language_spoken = cnvtupper(replace(trim(ce3.result_val,8),"/",""))
    OF mf_inter_method_cd:
     m_rec->qual[ml_cnt].s_inter_method = trim(ce3.result_val,3)
    OF mf_reason_cd:
     m_rec->qual[ml_cnt].s_reason = trim(ce3.result_val,3)
    OF mf_encounter_type_cd:
     m_rec->qual[ml_cnt].s_encounter_type = trim(ce3.result_val,3)
    OF mf_staff_utilizing_cd:
     m_rec->qual[ml_cnt].s_staff_utilizing = trim(ce3.result_val,3)
   ENDCASE
  FOOT  ce1.event_id
   m_rec->qual[ml_cnt].f_inter_duration = datetimediff(mf_inter_end_dt_tm,mf_inter_beg_dt_tm,3)
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_qual_cnt = ml_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->qual,5))),
   person_alias pa
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_id=m_rec->qual[d.seq].f_person_id)
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cs4_cmrn)
  ORDER BY d.seq
  HEAD d.seq
   m_rec->qual[d.seq].s_cmrn = trim(pa.alias,3)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SET ms_item_list = reflect(parameter(5,0))
 IF (((( $S_INTERPRETATION_METHOD="ANY")) OR (ms_item_list="L4")) )
  SET ms_inter_method_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (ml_loop = 1 TO ml_cnt)
    IF (ml_loop=1)
     SET ms_inter_method_p = build2('m_rec->qual[d.seq].s_inter_method in ("*',parameter(5,ml_loop),
      '*"')
    ELSE
     SET ms_inter_method_p = build2(ms_inter_method_p,",",'"*',parameter(5,ml_loop),'*"')
    ENDIF
  ENDFOR
  SET ms_inter_method_p = concat(ms_inter_method_p,")")
 ELSEIF (substring(1,1,ms_item_list)="C")
  SET ms_inter_method_p = build2('m_rec->qual[d.seq].s_inter_method = "*',parameter(5,0),'*"')
 ENDIF
 SELECT INTO "nl:"
  interpreter_id = m_rec->qual[d.seq].f_interpreter_id, interpreter_name = m_rec->qual[d.seq].
  s_interpreter_name
  FROM (dummyt d  WITH seq = m_rec->l_qual_cnt)
  WHERE (m_rec->qual[d.seq].s_language_spoken= $S_LANGUAGE)
   AND (m_rec->qual[d.seq].s_successful_inter= $S_SUCCESS)
   AND parser(ms_inter_method_p)
  ORDER BY interpreter_name, interpreter_id
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->filtered,5))
    CALL alterlist(m_rec->filtered,(ml_cnt+ 99))
   ENDIF
   m_rec->filtered[ml_cnt].s_interpreter_name = m_rec->qual[d.seq].s_interpreter_name, m_rec->
   filtered[ml_cnt].s_pat_fin = m_rec->qual[d.seq].s_pat_fin, m_rec->filtered[ml_cnt].
   s_encounter_type = m_rec->qual[d.seq].s_encounter_type,
   m_rec->filtered[ml_cnt].s_staff_utilizing = m_rec->qual[d.seq].s_staff_utilizing, m_rec->filtered[
   ml_cnt].s_language_spoken = m_rec->qual[d.seq].s_language_spoken, m_rec->filtered[ml_cnt].
   s_inter_start_dt_tm = m_rec->qual[d.seq].s_inter_start_dt_tm,
   m_rec->filtered[ml_cnt].s_filing_dt_tm = m_rec->qual[d.seq].s_filing_dt_tm, m_rec->filtered[ml_cnt
   ].s_successful_inter = m_rec->qual[d.seq].s_successful_inter, m_rec->filtered[ml_cnt].s_reason =
   m_rec->qual[d.seq].s_reason,
   m_rec->filtered[ml_cnt].s_inter_method = m_rec->qual[d.seq].s_inter_method, m_rec->filtered[ml_cnt
   ].s_number_of_staff = m_rec->qual[d.seq].s_number_of_staff, m_rec->filtered[ml_cnt].
   s_inter_duration = trim(format(m_rec->qual[d.seq].f_inter_duration,"####.##;R"),3),
   m_rec->filtered[ml_cnt].s_filing_time_diff = trim(format(m_rec->qual[d.seq].f_filing_time_diff,
     "####.##;R"),3), m_rec->filtered[ml_cnt].f_person_id = m_rec->qual[d.seq].f_person_id, m_rec->
   filtered[ml_cnt].s_cmrn = m_rec->qual[d.seq].s_cmrn
  FOOT REPORT
   CALL alterlist(m_rec->filtered,ml_cnt), m_rec->l_filtered_cnt = ml_cnt
  WITH nocounter
 ;end select
 IF ((m_rec->l_filtered_cnt=0))
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
   "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy;;d"),3),
   ".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"INTERPRETER NAME",','"PATIENT ACC#",','"ENCOUNTER TYPE",',
   '"STAFF UTILIZING INTERPRETER",','"LANGUAGE SPOKEN",',
   '"SUCCESSFUL INTERPRETATION",','"REASON NOT COMPLETED",','"INTERPRETATION METHOD",',
   '"NUMBER OF STAFF INTERPRETED FOR",','"INTERPRETATION DATE TIME",',
   '"TIME INTERPRETED (HRS)",','"FILING DATE TIME",','"TIME TO FILE (HRS)",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_filtered_cnt)
   SET frec->file_buf = build('"',trim(m_rec->filtered[ml_cnt].s_interpreter_name,3),'","',m_rec->
    filtered[ml_cnt].s_pat_fin,'","',
    m_rec->filtered[ml_cnt].s_encounter_type,'","',m_rec->filtered[ml_cnt].s_staff_utilizing,'","',
    m_rec->filtered[ml_cnt].s_language_spoken,
    '","',m_rec->filtered[ml_cnt].s_successful_inter,'","',m_rec->filtered[ml_cnt].s_reason,'","',
    m_rec->filtered[ml_cnt].s_inter_method,'","',m_rec->filtered[ml_cnt].s_number_of_staff,'","',
    m_rec->filtered[ml_cnt].s_inter_start_dt_tm,
    '","',m_rec->filtered[ml_cnt].s_inter_duration,'","',m_rec->filtered[ml_cnt].s_filing_dt_tm,'","',
    m_rec->filtered[ml_cnt].s_filing_time_diff,'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   interpreter_name = substring(1,50,m_rec->filtered[d.seq].s_interpreter_name), patient_acc# = m_rec
   ->filtered[d.seq].s_pat_fin, encounter_type = m_rec->filtered[d.seq].s_encounter_type,
   staff_utilizing_interpreter = m_rec->filtered[d.seq].s_staff_utilizing, language_spoken = m_rec->
   filtered[d.seq].s_language_spoken, successful_interpretation = m_rec->filtered[d.seq].
   s_successful_inter,
   reason_not_completed = m_rec->filtered[d.seq].s_reason, interpretation_method = m_rec->filtered[d
   .seq].s_inter_method, number_of_staff_interpreted_for = m_rec->filtered[d.seq].s_number_of_staff,
   interpretation_dt_tm = m_rec->filtered[d.seq].s_inter_start_dt_tm, time_interpreted_hrs = m_rec->
   filtered[d.seq].s_inter_duration, filing_dt_tm = m_rec->filtered[d.seq].s_filing_dt_tm,
   time_to_file_hrs = m_rec->filtered[d.seq].s_filing_time_diff
   FROM (dummyt d  WITH seq = m_rec->l_filtered_cnt)
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
