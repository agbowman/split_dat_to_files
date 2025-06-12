CREATE PROGRAM bhs_pedi_response_team_record:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Nurse Unit" = 0.0,
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Email Address" = ""
  WITH outdev, f_nurse_unit_cd, s_beg_dt,
  s_end_dt, s_email
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 s_patient_name = vc
     2 s_nurse_unit = vc
     2 f_person_id = f8
     2 s_birth_dt_tm = vc
     2 f_ews_lookback_date = dq8
     2 s_pews_last_3_scores = vc
     2 enc[*]
       3 s_admit_dt_tm = vc
       3 f_encntr_id = f8
       3 s_fin = vc
       3 form[*]
         4 s_date = vc
         4 s_time_pedi_rrt_called = vc
         4 s_did_team_arrive_in_5_minutes = vc
         4 s_if_no_please_explain = vc
         4 s_early_warning_score_pedi = vc
         4 s_reason_pedi_rrt_called = vc
         4 s_disposition_pedi_rrt = vc
         4 s_time_of_transfer = vc
         4 s_follow_up = vc
         4 s_disposition_follow_up_pedi_rrt = vc
         4 s_hospitalist_provider = vc
         4 s_bedside_nurse = vc
         4 s_senior_resident_provider = vc
         4 s_intern_provider = vc
         4 s_charge_nurse = vc
         4 s_pedi_rrt_nurse = vc
         4 s_pedi_rrt_resp_ther = vc
         4 s_pedi_rrt_provider = vc
         4 s_other_provider = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = w8
   1 file_offset = w8
   1 file_dir = w8
   1 file_name = vc
   1 file_buf = vc
 )
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE mf_nurse_unit_cd = f8 WITH protect, constant(cnvtreal( $F_NURSE_UNIT_CD))
 DECLARE ms_email = vc WITH protect, constant(trim( $S_EMAIL,3))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs72_pedi_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PEDIRAPIDRESPONSETEAMRECORDFORM"))
 DECLARE mf_datetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DATETIME"))
 DECLARE mf_team_arr_5min_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIDTEAMARRIVEWIN5MINUTES"))
 DECLARE mf_disp_fu_pedi_rrt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISPOSITIONFOLLOWUPPEDIRRT62018"))
 DECLARE mf_disp_pedi_rrt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Disposition Pedi RRT"))
 DECLARE mf_ews_pedi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EARLYWARNINGSCOREPEDI"))
 DECLARE mf_fu_pedi_resp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FOLLOWUPRAPIDRESPONSE"))
 DECLARE mf_if_no_expl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "IFNOPLEASEEXPLAIN"))
 DECLARE mf_pedi_tm_xfer_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FOLLOWUPRAPIDRESPONSE1"))
 DECLARE mf_rsn_rrt_call_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REASONPEDIRRTCALLED"))
 DECLARE mf_tm_rrt_call_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TIMEPEDIRRTCALLED"))
 DECLARE mf_hospitalistprovider_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HOSPITALISTPROVIDER"))
 DECLARE mf_bedsidenurse_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BEDSIDENURSE"))
 DECLARE mf_seniorresidentprovider_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SENIORRESIDENTPROVIDER"))
 DECLARE mf_internprovider_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERNPROVIDER"))
 DECLARE mf_chargenurse_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CHARGENURSE")
  )
 DECLARE mf_pedirrtnurse_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PEDIRRTNURSE"))
 DECLARE mf_pedirrtrespther_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PEDIRRTRESPTHER"))
 DECLARE mf_pedirrtprovider_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PEDIRRTPROVIDER"))
 DECLARE mf_otherprovider_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "OTHERPROVIDER"))
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 DECLARE ml_ewscnt = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 IF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, "Begin Date is greater than End Date"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (textlen(ms_email) > 0
  AND findstring("@",ms_email)=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, "Invalid email address"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT
  IF (mf_nurse_unit_cd=0.0)
   PLAN (ce
    WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
     AND ce.event_cd=mf_cs72_pedi_form_cd
     AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd)
     AND ce.valid_until_dt_tm > sysdate)
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND e.active_ind=1)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=mf_fin_cd)
    JOIN (ce1
    WHERE ce1.parent_event_id=ce.event_id)
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.event_cd IN (mf_datetime_cd, mf_team_arr_5min_cd, mf_disp_fu_pedi_rrt_cd,
    mf_disp_pedi_rrt_cd, mf_ews_pedi_cd,
    mf_fu_pedi_resp_cd, mf_if_no_expl_cd, mf_pedi_tm_xfer_cd, mf_rsn_rrt_call_cd, mf_tm_rrt_call_cd,
    mf_hospitalistprovider_cd, mf_bedsidenurse_cd, mf_seniorresidentprovider_cd, mf_internprovider_cd,
    mf_chargenurse_cd,
    mf_pedirrtnurse_cd, mf_pedirrtrespther_cd, mf_pedirrtprovider_cd, mf_otherprovider_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.active_ind=1)
    JOIN (cdr
    WHERE (cdr.event_id= Outerjoin(ce2.event_id)) )
  ELSE
   PLAN (ce
    WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
     AND ce.event_cd=mf_cs72_pedi_form_cd
     AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd)
     AND ce.valid_until_dt_tm > sysdate)
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND e.location_cd=mf_nurse_unit_cd
     AND e.active_ind=1)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=mf_fin_cd)
    JOIN (ce1
    WHERE ce1.parent_event_id=ce.event_id)
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.event_cd IN (mf_datetime_cd, mf_team_arr_5min_cd, mf_disp_fu_pedi_rrt_cd,
    mf_disp_pedi_rrt_cd, mf_ews_pedi_cd,
    mf_fu_pedi_resp_cd, mf_if_no_expl_cd, mf_pedi_tm_xfer_cd, mf_rsn_rrt_call_cd, mf_tm_rrt_call_cd,
    mf_hospitalistprovider_cd, mf_bedsidenurse_cd, mf_seniorresidentprovider_cd, mf_internprovider_cd,
    mf_chargenurse_cd,
    mf_pedirrtnurse_cd, mf_pedirrtrespther_cd, mf_pedirrtprovider_cd, mf_otherprovider_cd))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.active_ind=1)
    JOIN (cdr
    WHERE (cdr.event_id= Outerjoin(ce2.event_id)) )
  ENDIF
  INTO "nl:"
  ps_nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
  FROM clinical_event ce,
   encounter e,
   encntr_alias ea,
   clinical_event ce1,
   clinical_event ce2,
   person p,
   ce_date_result cdr
  ORDER BY ps_nurse_unit, p.person_id, e.encntr_id,
   ce.event_cd, ce.event_end_dt_tm DESC, ce.event_id,
   ce1.event_id, ce2.event_cd, ce2.event_end_dt_tm DESC
  HEAD REPORT
   pat_cnt = 0, enc_cnt = 0, form_cnt = 0
  HEAD ps_nurse_unit
   enc_cnt = 0, form_cnt = 0
  HEAD p.person_id
   enc_cnt = 0, form_cnt = 0, pat_cnt += 1,
   CALL alterlist(m_rec->pat,pat_cnt), m_rec->pat[pat_cnt].f_person_id = p.person_id, m_rec->pat[
   pat_cnt].s_patient_name = substring(1,25,trim(p.name_full_formatted)),
   m_rec->pat[pat_cnt].s_birth_dt_tm = trim(format(p.birth_dt_tm,"MM/DD/YY;;D"),3), m_rec->pat[
   pat_cnt].s_nurse_unit = ps_nurse_unit
  HEAD e.encntr_id
   form_cnt = 0, enc_cnt += 1,
   CALL alterlist(m_rec->pat[pat_cnt].enc,enc_cnt),
   m_rec->pat[pat_cnt].enc[enc_cnt].f_encntr_id = e.encntr_id, m_rec->pat[pat_cnt].enc[enc_cnt].s_fin
    = ea.alias, m_rec->pat[pat_cnt].enc[enc_cnt].s_admit_dt_tm = trim(format(e.arrive_dt_tm,
     "MM/DD/YY hh:mm;;D"))
  HEAD ce.event_cd
   null
  HEAD ce.event_end_dt_tm
   null
  HEAD ce.event_id
   form_cnt += 1,
   CALL alterlist(m_rec->pat[pat_cnt].enc[enc_cnt].form,form_cnt)
  HEAD ce1.event_id
   null
  HEAD ce2.event_cd
   null
  HEAD ce2.event_end_dt_tm
   null
  DETAIL
   CASE (ce2.event_cd)
    OF mf_datetime_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_date = trim(format(cdr.result_dt_tm,
       "mm/dd/yy;;d"),3)
    OF mf_tm_rrt_call_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_time_pedi_rrt_called = trim(format(cdr
       .result_dt_tm,"hh:mm;;d"),3)
    OF mf_team_arr_5min_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_did_team_arrive_in_5_minutes = trim(ce2
      .result_val,3)
    OF mf_if_no_expl_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_if_no_please_explain = trim(ce2.result_val,3)
    OF mf_ews_pedi_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_early_warning_score_pedi = trim(ce2.result_val,
      3)
    OF mf_rsn_rrt_call_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_reason_pedi_rrt_called = trim(ce2.result_val,3
      )
    OF mf_disp_pedi_rrt_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_disposition_pedi_rrt = trim(ce2.result_val,3)
    OF mf_pedi_tm_xfer_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_time_of_transfer = trim(format(cdr
       .result_dt_tm,"mm/dd/yy hh:mm;;d"),3)
    OF mf_fu_pedi_resp_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_follow_up = trim(format(cdr.result_dt_tm,
       "mm/dd/yy hh:mm;;d"),3)
    OF mf_disp_fu_pedi_rrt_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_disposition_follow_up_pedi_rrt = trim(ce2
      .result_val,3)
    OF mf_hospitalistprovider_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_hospitalist_provider = trim(ce2.result_val,3)
    OF mf_bedsidenurse_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_bedside_nurse = trim(ce2.result_val,3)
    OF mf_seniorresidentprovider_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_senior_resident_provider = trim(ce2.result_val,
      3)
    OF mf_internprovider_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_intern_provider = trim(ce2.result_val,3)
    OF mf_chargenurse_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_charge_nurse = trim(ce2.result_val,3)
    OF mf_pedirrtnurse_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_pedi_rrt_nurse = trim(ce2.result_val,3)
    OF mf_pedirrtrespther_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_pedi_rrt_resp_ther = trim(ce2.result_val,3)
    OF mf_pedirrtprovider_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_pedi_rrt_provider = trim(ce2.result_val,3)
    OF mf_otherprovider_cd:
     m_rec->pat[pat_cnt].enc[enc_cnt].form[form_cnt].s_other_provider = trim(ce2.result_val,3)
   ENDCASE
  FOOT  ce2.event_end_dt_tm
   null
  FOOT  ce2.event_cd
   null
  FOOT  ce1.event_id
   null
  FOOT  ce.event_id
   null
  FOOT  ce.event_end_dt_tm
   null
  FOOT  ce.event_cd
   null
  FOOT  e.encntr_id
   null
  FOOT  p.person_id
   m_rec->pat[pat_cnt].f_ews_lookback_date = cnvtlookbehind("12 H",ce.event_end_dt_tm)
  FOOT  ps_nurse_unit
   null
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, "No Qualifying Records"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = size(m_rec->pat,5)),
   clinical_event ce
  PLAN (d1)
   JOIN (ce
   WHERE (ce.person_id=m_rec->pat[d1.seq].f_person_id)
    AND ce.event_cd=mf_ews_pedi_cd
    AND ce.event_end_dt_tm >= cnvtdatetime(m_rec->pat[d1.seq].f_ews_lookback_date)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY d1.seq, ce.event_end_dt_tm DESC
  HEAD d1.seq
   ml_ewscnt = 0, m_rec->pat[d1.seq].s_pews_last_3_scores = " "
  HEAD ce.event_end_dt_tm
   ml_ewscnt += 1
   IF (ml_ewscnt < 4)
    IF ((m_rec->pat[d1.seq].s_pews_last_3_scores=" "))
     m_rec->pat[d1.seq].s_pews_last_3_scores = concat(trim(ce.result_val,3)," (",format(ce
       .event_end_dt_tm,"mm/dd/yy HH:mm;;D"),")")
    ELSE
     m_rec->pat[d1.seq].s_pews_last_3_scores = concat(m_rec->pat[d1.seq].s_pews_last_3_scores,"; ",
      trim(ce.result_val,3)," (",format(ce.event_end_dt_tm,"mm/dd/yy HH:mm;;D"),
      ")")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (textlen(ms_email) > 0)
  SET frec->file_name = concat("pedi_rapid_response_team_record_",format(sysdate,"MMDDYYYY;;q"),
   ".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"NURSE UNIT",','"PATIENT NAME",','"FIN NUMBER",','"ADMIT DATE/TIME",',
   '"DATE OF BIRTH",',
   '"DATE",','"TIME PEDI RRT CALLED",','"DID TEAM ARRIVE W/IN 5 MINUTES ",',
   '"IF NO, PLEASE EXPLAIN",','"EARLY WARNING SCORE (PEDI)",',
   '"PEWS_Last_3_SCORES",','"REASON PEDI RRT CALLED",','"DISPOSITION PEDI RRT",',
   '"TIME OF TRANSFER",','"FOLLOW UP @",',
   '"DISPOSITION FOLLOW UP Pedi RRT",','"HOSPITALIST_PROVIDER",','"BEDSIDE_NURSE",',
   '"SENIOR_RESIDENT_PROVIDER",','"INTERN_PROVIDER",',
   '"CHARGE_NURSE",','"PEDI_RRT_NURSE",','"PEDI_RRT_RESP_THER",','"PEDI_RRT_PROVIDER",',
   '"OTHER_PROVIDER",',
   char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO size(m_rec->pat,5))
    FOR (ml_idx2 = 1 TO size(m_rec->pat[ml_idx1].enc,5))
      FOR (ml_idx3 = 1 TO size(m_rec->pat[ml_idx1].enc[ml_idx2].form,5))
       SET frec->file_buf = build2('"',m_rec->pat[ml_idx1].s_nurse_unit,'","',m_rec->pat[ml_idx1].
        s_patient_name,'","',
        m_rec->pat[ml_idx1].enc[ml_idx2].s_fin,'","',m_rec->pat[ml_idx1].enc[ml_idx2].s_admit_dt_tm,
        '","',m_rec->pat[ml_idx1].s_birth_dt_tm,
        '","',m_rec->pat[ml_idx1].enc[ml_idx2].form[ml_idx3].s_date,'","',m_rec->pat[ml_idx1].enc[
        ml_idx2].form[ml_idx3].s_time_pedi_rrt_called,'","',
        m_rec->pat[ml_idx1].enc[ml_idx2].form[ml_idx3].s_did_team_arrive_in_5_minutes,'","',m_rec->
        pat[ml_idx1].enc[ml_idx2].form[ml_idx3].s_if_no_please_explain,'","',m_rec->pat[ml_idx1].enc[
        ml_idx2].form[ml_idx3].s_early_warning_score_pedi,
        '","',m_rec->pat[ml_idx1].s_pews_last_3_scores,'","',m_rec->pat[ml_idx1].enc[ml_idx2].form[
        ml_idx3].s_reason_pedi_rrt_called,'","',
        m_rec->pat[ml_idx1].enc[ml_idx2].form[ml_idx3].s_disposition_pedi_rrt,'","',m_rec->pat[
        ml_idx1].enc[ml_idx2].form[ml_idx3].s_time_of_transfer,'","',m_rec->pat[ml_idx1].enc[ml_idx2]
        .form[ml_idx3].s_follow_up,
        '","',m_rec->pat[ml_idx1].enc[ml_idx2].form[ml_idx3].s_disposition_follow_up_pedi_rrt,'","',
        m_rec->pat[ml_idx1].enc[ml_idx2].form[ml_idx3].s_hospitalist_provider,'","',
        m_rec->pat[ml_idx1].enc[ml_idx2].form[ml_idx3].s_bedside_nurse,'","',m_rec->pat[ml_idx1].enc[
        ml_idx2].form[ml_idx3].s_senior_resident_provider,'","',m_rec->pat[ml_idx1].enc[ml_idx2].
        form[ml_idx3].s_intern_provider,
        '","',m_rec->pat[ml_idx1].enc[ml_idx2].form[ml_idx3].s_charge_nurse,'","',m_rec->pat[ml_idx1]
        .enc[ml_idx2].form[ml_idx3].s_pedi_rrt_nurse,'","',
        m_rec->pat[ml_idx1].enc[ml_idx2].form[ml_idx3].s_pedi_rrt_resp_ther,'","',m_rec->pat[ml_idx1]
        .enc[ml_idx2].form[ml_idx3].s_pedi_rrt_provider,'","',m_rec->pat[ml_idx1].enc[ml_idx2].form[
        ml_idx3].s_other_provider,
        '"',char(13))
       SET stat = cclio("WRITE",frec)
      ENDFOR
    ENDFOR
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  SET ms_subject = "Pedi Rapid Response Team Record"
  EXECUTE bhs_ma_email_file
  CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_subject,0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    ms_tmp = concat("Pedi Rapid Response Team Record has been mailed to ",ms_email), col 0, ms_tmp
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   nurse_unit = m_rec->pat[d1.seq].s_nurse_unit, patient_name = m_rec->pat[d1.seq].s_patient_name,
   fin_number = m_rec->pat[d1.seq].enc[d2.seq].s_fin,
   admit_dt_tm = m_rec->pat[d1.seq].enc[d2.seq].s_admit_dt_tm, dob = m_rec->pat[d1.seq].s_birth_dt_tm,
   form_date = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_date,
   time_pedi_rrt_called = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_time_pedi_rrt_called,
   did_team_arrive_in_5_mins = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].
   s_did_team_arrive_in_5_minutes, if_no_pleas_explain = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].
   s_if_no_please_explain,
   early_warning_score_pedi = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_early_warning_score_pedi,
   pews_last_3_scores = m_rec->pat[d1.seq].s_pews_last_3_scores, reason_pedi_rrt_called = m_rec->pat[
   d1.seq].enc[d2.seq].form[d3.seq].s_reason_pedi_rrt_called,
   disposition_pedi_rrt = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_disposition_pedi_rrt,
   time_of_transfer = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_time_of_transfer, follow_up_at =
   m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_follow_up,
   disposition_follow_up_pedi_rrt = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].
   s_disposition_follow_up_pedi_rrt, hospitalist_provider = m_rec->pat[d1.seq].enc[d2.seq].form[d3
   .seq].s_hospitalist_provider, bedside_nurse = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].
   s_bedside_nurse,
   senior_resident_provider = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_senior_resident_provider,
   intern_provider = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_intern_provider, charge_nurse =
   m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_charge_nurse,
   pedi_rrt_nurse = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_pedi_rrt_nurse, pedi_rrt_resp_ther
    = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_pedi_rrt_resp_ther, pedi_rrt_provider = m_rec->
   pat[d1.seq].enc[d2.seq].form[d3.seq].s_pedi_rrt_provider,
   other_provider = m_rec->pat[d1.seq].enc[d2.seq].form[d3.seq].s_other_provider
   FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
    dummyt d2,
    dummyt d3
   PLAN (d1
    WHERE maxrec(d2,size(m_rec->pat[d1.seq].enc,5)))
    JOIN (d2
    WHERE maxrec(d3,size(m_rec->pat[d1.seq].enc[d2.seq].form,5)))
    JOIN (d3)
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ENDIF
#exit_script
END GO
