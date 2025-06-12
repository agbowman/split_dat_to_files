CREATE PROGRAM bhs_sleep_med_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 0,
  "Nurse Unit" = 0,
  "Begin dt/tm" = "CURDATE",
  "End dt/tm" = "CURDATE",
  "Recipients" = ""
  WITH outdev, f_facility_cd, f_nurse_unit_cd,
  s_beg_dt_tm, s_end_dt_tm, s_recipients
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 name_full = vc
     2 performed_dt_tm = vc
     2 facility_disp = vc
     2 nurse_unit_disp = vc
     2 diagnosis_disp = vc
     2 orders = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_diag_sleep_apnea_task_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "DIAGNOSISOFSLEEPAPNEA"))
 DECLARE mf_diag_sleep_apnea_event_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIAGNOSISOFSLEEPAPNEA"))
 DECLARE mf_use_cpap_bipap_task_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "CURRENTLYUSECPAPBIPAPETCATHOME"))
 DECLARE mf_use_cpap_bipap_event_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CURRENTLYUSECPAPBIPAPETCATHOME"))
 DECLARE mf_asv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ASVADAPTIVESERVOVENTILATION"))
 DECLARE mf_autoasv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"AUTOASV"))
 DECLARE mf_autobipap_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"AUTOBIPAP"))
 DECLARE mf_autocpap_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"AUTOCPAP"))
 DECLARE mf_avaps_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"AVAPS"))
 DECLARE mf_bipap_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BIPAP"))
 DECLARE mf_bipap_autosv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "BIPAPAUTOSV"))
 DECLARE mf_cpap_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CPAP"))
 DECLARE mf_ivaps_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "IVAPSINTELVOLASSUREDPRESSURESUPPORT"))
 DECLARE mf_pap_home_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "PAPHOMEPROTOCOL"))
 DECLARE mf_resp_therapy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RESPTHERAPISTTOEVALUATE"))
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEG_DT_TM))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DT_TM))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit_p = vc WITH protect, noconstant("")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_diag_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_subject = vc WITH protect, noconstant("")
 IF (cnvtdatetime(mf_begin_dt_tm) > cnvtdatetime(mf_end_dt_tm))
  SET ms_error = "Start date must be less than end date."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 SET ms_item_list = reflect(parameter(2,0))
 IF (( $F_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (i = 1 TO ml_cnt)
    IF (i=1)
     SET ms_facility_p = build2("e.loc_facility_cd in (",parameter(2,i))
    ELSE
     SET ms_facility_p = build2(ms_facility_p,",",parameter(2,i))
    ENDIF
  ENDFOR
  SET ms_facility_p = concat(ms_facility_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_facility_p = build2("e.loc_facility_cd = ",parameter(2,0))
 ENDIF
 SET ms_item_list = reflect(parameter(3,0))
 IF (( $F_NURSE_UNIT_CD=999999))
  SET ms_nurse_unit_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (i = 1 TO ml_cnt)
    IF (i=1)
     SET ms_nurse_unit_p = build2("e.loc_nurse_unit_cd in (",parameter(3,i))
    ELSE
     SET ms_nurse_unit_p = build2(ms_nurse_unit_p,",",parameter(3,i))
    ENDIF
  ENDFOR
  SET ms_nurse_unit_p = concat(ms_nurse_unit_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_nurse_unit_p = build2("e.loc_nurse_unit_cd = ",parameter(3,0))
 ENDIF
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   encntr_alias ea,
   clinical_event ce,
   clinical_event ce2,
   diagnosis d,
   orders o
  PLAN (p)
   JOIN (e
   WHERE e.person_id=p.person_id
    AND parser(ms_facility_p)
    AND parser(ms_nurse_unit_p)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.task_assay_cd=mf_diag_sleep_apnea_task_cd
    AND ce.event_cd=mf_diag_sleep_apnea_event_cd
    AND ce.event_tag="Yes"
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ce2
   WHERE ce2.encntr_id=e.encntr_id
    AND ce2.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce2.task_assay_cd=mf_use_cpap_bipap_task_cd
    AND ce2.event_cd=mf_use_cpap_bipap_event_cd
    AND ce2.event_tag="Yes"
    AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (d
   WHERE d.encntr_id=e.encntr_id)
   JOIN (o
   WHERE o.encntr_id=e.encntr_id)
  ORDER BY p.name_full_formatted, ce.performed_dt_tm, d.diagnosis_display,
   o.order_mnemonic
  HEAD REPORT
   ml_cnt = 0
  HEAD d.diagnosis_display
   ml_diag_cnt = 0, ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 9))
   ENDIF
   m_rec->qual[ml_cnt].name_full = p.name_full_formatted, m_rec->qual[ml_cnt].performed_dt_tm =
   format(ce.performed_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"), m_rec->qual[ml_cnt].facility_disp =
   uar_get_code_display(e.loc_facility_cd),
   m_rec->qual[ml_cnt].nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd), m_rec->qual[
   ml_cnt].diagnosis_disp = d.diagnosis_display
  HEAD o.order_mnemonic
   IF (o.catalog_cd IN (mf_asv_cd, mf_autoasv_cd, mf_autobipap_cd, mf_autocpap_cd, mf_avaps_cd,
   mf_bipap_cd, mf_bipap_autosv_cd, mf_cpap_cd, mf_ivaps_cd, mf_pap_home_cd,
   mf_resp_therapy_cd))
    IF (ml_diag_cnt=0)
     ml_diag_cnt += 1, m_rec->qual[ml_cnt].orders = o.order_mnemonic
    ELSE
     IF (findstring(o.order_mnemonic,m_rec->qual[ml_cnt].orders)=0)
      m_rec->qual[ml_cnt].orders = build(m_rec->qual[ml_cnt].orders,", ",o.order_mnemonic)
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_cnt = ml_cnt
  WITH nocounter, format, separator = " "
 ;end select
 IF (size(m_rec->qual,5)=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO value( $OUTDEV)
  patient_name = substring(1,50,m_rec->qual[d.seq].name_full), performed_dt_tm = substring(1,50,m_rec
   ->qual[d.seq].performed_dt_tm), facility = substring(1,50,m_rec->qual[d.seq].facility_disp),
  nurse_unit = substring(1,50,m_rec->qual[d.seq].nurse_unit_disp), diagnosis = substring(1,100,m_rec
   ->qual[d.seq].diagnosis_disp), orders = substring(1,200,m_rec->qual[d.seq].orders)
  FROM (dummyt d  WITH seq = m_rec->l_cnt)
  WITH nocounter, format, separator = " "
 ;end select
 IF (textlen(trim( $S_RECIPIENTS,3)) > 1)
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yyyy;;d"),3),
   "_to_",trim(format(mf_end_dt_tm,"mm_dd_yyyy;;d"),3),
   ".csv")
  SET ms_subject = build2("Sleep Medication Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"PERFORMED_DT_TM",','"FACILITY",','"NURSE_UNIT",',
   '"DIAGNOSIS",',
   '"ORDERS",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].name_full,3),'","',trim(m_rec->qual[ml_cnt
     ].performed_dt_tm,3),'","',
    trim(m_rec->qual[ml_cnt].facility_disp,3),'","',trim(m_rec->qual[ml_cnt].nurse_unit_disp,3),'","',
    trim(m_rec->qual[ml_cnt].diagnosis_disp,3),
    '","',trim(m_rec->qual[ml_cnt].orders,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ENDIF
#exit_script
 FREE RECORD m_rec
 FREE RECORD frec
 IF (textlen(trim(ms_error,3)) > 0)
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
