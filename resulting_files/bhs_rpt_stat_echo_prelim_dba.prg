CREATE PROGRAM bhs_rpt_stat_echo_prelim:dba
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
     2 s_pat_name = vc
     2 s_fin = vc
     2 s_location = vc
     2 s_indications = vc
     2 s_lv_findings = vc
     2 s_rv_findings = vc
     2 s_valves = vc
     2 s_pericardium = vc
     2 s_ivc = vc
     2 s_order_provider = vc
     2 s_res_communicated = vc
     2 s_performing_fellow = vc
     2 s_form_completed_by = vc
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_statechoform_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "STATECHOPRELIMREPORTFELLOWFORM"))
 DECLARE mf_dcpgeneric_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DCPGENERICCODE"))
 DECLARE mf_echoindications_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOINDICATIONS"))
 DECLARE mf_echolvfindings_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOLVFINDINGS"))
 DECLARE mf_echorvfindings_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHORVFINDINGS"))
 DECLARE mf_echovalves_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHOVALVES"))
 DECLARE mf_echopericardium_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOPERICARDIUM"))
 DECLARE mf_echoivc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHOIVC"))
 DECLARE mf_echoorderprovider_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOORDERPROVIDER"))
 DECLARE mf_echorescommunicated_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHORESULTSCOMMUNICATED"))
 DECLARE mf_echoperformingfellow_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOPERFORMINGFELLOW"))
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
  SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(((curdate - day(curdate))+ 1),000000))
  SET mf_end_dt_tm = cnvtdatetime((curdate - day(curdate)),235959)
  SET ms_subject = build2("STAT Echo Prelim Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_STAT_ECHO_PRELIM"
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
  SET ms_subject = build2("STAT Echo Prelim Report ",trim(format(mf_begin_dt_tm,
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
 SELECT INTO "nl:"
  FROM clinical_event ce1,
   clinical_event ce2,
   clinical_event ce3,
   person p,
   prsnl pr,
   encounter e,
   encntr_alias ea
  PLAN (ce1
   WHERE ce1.event_cd=mf_statechoform_cd
    AND ce1.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce1.publish_flag=1)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.event_cd=mf_dcpgeneric_cd
    AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ce3
   WHERE ce3.parent_event_id=ce2.event_id
    AND ce3.event_cd IN (mf_echoindications_cd, mf_echolvfindings_cd, mf_echorvfindings_cd,
   mf_echovalves_cd, mf_echopericardium_cd,
   mf_echoivc_cd, mf_echoorderprovider_cd, mf_echorescommunicated_cd, mf_echoperformingfellow_cd)
    AND ce3.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce3.publish_flag=1)
   JOIN (p
   WHERE p.person_id=ce1.person_id)
   JOIN (pr
   WHERE pr.person_id=ce1.performed_prsnl_id)
   JOIN (e
   WHERE e.encntr_id=ce1.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY p.name_full_formatted, p.person_id, ce1.performed_dt_tm DESC,
   ce1.event_id, ce3.performed_dt_tm DESC
  HEAD REPORT
   ml_cnt = 0
  HEAD ce1.event_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].s_pat_name = substring(1,100,trim(p.name_full_formatted,3)), m_rec->qual[
   ml_cnt].s_fin = substring(1,100,trim(ea.alias,3)), m_rec->qual[ml_cnt].s_form_completed_by =
   substring(1,100,trim(pr.name_full_formatted,3)),
   m_rec->qual[ml_cnt].s_location = substring(1,100,build2(trim(uar_get_code_display(e
       .loc_facility_cd),3),"/",trim(uar_get_code_display(e.loc_nurse_unit_cd),3)))
  HEAD ce3.event_id
   CASE (ce3.event_cd)
    OF mf_echoindications_cd:
     m_rec->qual[ml_cnt].s_indications = substring(1,100,trim(ce3.result_val,3))
    OF mf_echolvfindings_cd:
     m_rec->qual[ml_cnt].s_lv_findings = substring(1,100,trim(ce3.result_val,3))
    OF mf_echorvfindings_cd:
     m_rec->qual[ml_cnt].s_rv_findings = substring(1,100,trim(ce3.result_val,3))
    OF mf_echovalves_cd:
     m_rec->qual[ml_cnt].s_valves = substring(1,100,trim(ce3.result_val,3))
    OF mf_echopericardium_cd:
     m_rec->qual[ml_cnt].s_pericardium = substring(1,100,trim(ce3.result_val,3))
    OF mf_echoivc_cd:
     m_rec->qual[ml_cnt].s_ivc = substring(1,100,trim(ce3.result_val,3))
    OF mf_echoorderprovider_cd:
     m_rec->qual[ml_cnt].s_order_provider = substring(1,100,trim(ce3.result_val,3))
    OF mf_echorescommunicated_cd:
     m_rec->qual[ml_cnt].s_res_communicated = substring(1,100,trim(ce3.result_val,3))
    OF mf_echoperformingfellow_cd:
     m_rec->qual[ml_cnt].s_performing_fellow = substring(1,100,trim(ce3.result_val,3))
   ENDCASE
  FOOT REPORT
   m_rec->l_cnt = ml_cnt,
   CALL alterlist(m_rec->qual,ml_cnt)
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
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"FIN#",','"LOCATION",','"FORM COMPLETED BY",',
   '"ECHO INDICATIONS",',
   '"ECHO LV FINDINGS",','"ECHO RV FINDINGS",','"ECHO VALVES",','"ECHO PERICARDIUM",','"ECHO IVC",',
   '"ECHO ORDER PROVIDER",','"ECHO RESULTS COMMUNICATED",','"ECHO PERFORMING FELLOW",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_pat_name,3),'","',trim(m_rec->qual[
     ml_cnt].s_fin,3),'","',
    trim(m_rec->qual[ml_cnt].s_location,3),'","',trim(m_rec->qual[ml_cnt].s_form_completed_by,3),
    '","',trim(m_rec->qual[ml_cnt].s_indications,3),
    '","',trim(m_rec->qual[ml_cnt].s_lv_findings,3),'","',trim(m_rec->qual[ml_cnt].s_rv_findings,3),
    '","',
    trim(m_rec->qual[ml_cnt].s_valves,3),'","',trim(m_rec->qual[ml_cnt].s_pericardium,3),'","',trim(
     m_rec->qual[ml_cnt].s_ivc,3),
    '","',trim(m_rec->qual[ml_cnt].s_order_provider,3),'","',trim(m_rec->qual[ml_cnt].
     s_res_communicated,3),'","',
    trim(m_rec->qual[ml_cnt].s_performing_fellow,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,20,m_rec->qual[d.seq].s_pat_name), fin# = substring(1,20,m_rec->qual[d
    .seq].s_fin), location = substring(1,20,m_rec->qual[d.seq].s_location),
   form_completed_by = substring(1,20,m_rec->qual[d.seq].s_form_completed_by), echo_indications =
   substring(1,15,m_rec->qual[d.seq].s_indications), echo_lv_findings = substring(1,15,m_rec->qual[d
    .seq].s_lv_findings),
   echo_rv_findings = substring(1,15,m_rec->qual[d.seq].s_rv_findings), echo_valves = substring(1,15,
    m_rec->qual[d.seq].s_valves), echo_pericardium = substring(1,15,m_rec->qual[d.seq].s_pericardium),
   echo_ivc = substring(1,15,m_rec->qual[d.seq].s_ivc), echo_order_provider = substring(1,20,m_rec->
    qual[d.seq].s_order_provider), echo_results_communicated = substring(1,20,m_rec->qual[d.seq].
    s_res_communicated),
   echo_performing_fellow = substring(1,20,m_rec->qual[d.seq].s_performing_fellow)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
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
