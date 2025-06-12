CREATE PROGRAM bhs_rpt_erx_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Status" = value(180235236.00,180235237.00,180235240.00),
  "Recipients" = ""
  WITH outdev, s_begin_date, s_end_date,
  f_status_cd, s_recipients
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
     2 s_order_id = vc
     2 s_fin = vc
     2 s_patient_name = vc
     2 s_entering_user = vc
     2 s_ordering_provider = vc
     2 s_supervisor = vc
     2 s_order_date = vc
     2 s_msg_publish_date = vc
     2 s_order_mnemonic = vc
     2 s_order_detail = vc
     2 s_type = vc
     2 s_pharmacy_id = vc
     2 s_rx_id = vc
     2 s_ma_status = vc
     2 s_ma_error = vc
     2 s_message_text = vc
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
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
  SET mf_begin_dt_tm = cnvtdatetime((curdate - 1),000000)
  SET mf_end_dt_tm = cnvtdatetime((curdate - 1),235959)
  SET ms_subject = build2("eRX Error Audit Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_ERX_AUDIT"
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
  SET ms_subject = build2("eRX Audit Report ",trim(format(mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d")),
   " to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
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
  FROM messaging_audit ma,
   si_audit sa,
   orders o,
   order_action oa,
   encntr_alias ea,
   encounter e,
   prsnl p,
   prsnl p2,
   prsnl p3,
   person per,
   long_text lt,
   dummyt d
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND o.orig_ord_as_flag=1
    AND o.active_ind=1)
   JOIN (oa
   WHERE oa.order_id=o.order_id)
   JOIN (ma
   WHERE ma.order_id=o.order_id
    AND (ma.status_cd= $F_STATUS_CD)
    AND ma.publish_ind=1)
   JOIN (sa
   WHERE sa.msg_ident=ma.rx_identifier)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
   JOIN (p2
   WHERE p2.person_id=oa.action_personnel_id)
   JOIN (per
   WHERE per.person_id=e.person_id)
   JOIN (lt
   WHERE lt.long_text_id=ma.msg_text_id)
   JOIN (d
   WHERE lt.long_text="*")
   JOIN (p3
   WHERE p3.person_id=oa.supervising_provider_id)
  ORDER BY ma.updt_dt_tm DESC, ma.rx_identifier
  HEAD REPORT
   ml_cnt = 0
  HEAD o.order_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].s_order_id = trim(cnvtstring(o.order_id),3), m_rec->qual[ml_cnt].s_fin = trim(
    ea.alias,3), m_rec->qual[ml_cnt].s_patient_name = trim(per.name_full_formatted,3),
   m_rec->qual[ml_cnt].s_entering_user = trim(p2.name_full_formatted,3), m_rec->qual[ml_cnt].
   s_ordering_provider = trim(p.name_full_formatted,3), m_rec->qual[ml_cnt].s_supervisor = trim(p3
    .name_full_formatted,3),
   m_rec->qual[ml_cnt].s_order_date = trim(format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), m_rec
   ->qual[ml_cnt].s_msg_publish_date = trim(format(ma.audit_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), m_rec->
   qual[ml_cnt].s_order_mnemonic = trim(o.order_mnemonic,3),
   m_rec->qual[ml_cnt].s_order_detail = trim(o.clinical_display_line,3), m_rec->qual[ml_cnt].s_type
    = trim(sa.msg_trig_action_txt,3), m_rec->qual[ml_cnt].s_pharmacy_id = trim(ma.pharmacy_identifier,
    3),
   m_rec->qual[ml_cnt].s_rx_id = trim(ma.rx_identifier,3), m_rec->qual[ml_cnt].s_ma_status = trim(
    uar_get_code_display(ma.status_cd)), m_rec->qual[ml_cnt].s_ma_error = trim(uar_get_code_display(
     ma.error_cd)),
   m_rec->qual[ml_cnt].s_message_text = trim(lt.long_text,3)
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_cnt = ml_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  IF (mn_ops=1)
   SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
    ".csv")
  ELSE
   SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
    "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy;;d"),3),
    ".csv")
  ENDIF
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"FIN",','"PATIENT NAME",','"ENTERING USER",','"ORDERING PROVIDER",',
   '"SUPERVISOR",',
   '"ORDER DATE",','"MSG PUBLISH DATE",','"ORDER MNEMONIC",','"ORDER DETAIL",','"ORDER ID",',
   '"TYPE",','"PHARMACY ID",','"RX ID",','"MA STATUS",','"MA ERROR",',
   '"MESSAGE TEXT",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_fin,3),'","',trim(m_rec->qual[ml_cnt].
     s_patient_name,3),'","',
    trim(m_rec->qual[ml_cnt].s_entering_user,3),'","',trim(m_rec->qual[ml_cnt].s_ordering_provider,3),
    '","',trim(m_rec->qual[ml_cnt].s_supervisor,3),
    '","',trim(m_rec->qual[ml_cnt].s_order_date,3),'","',trim(m_rec->qual[ml_cnt].s_msg_publish_date,
     3),'","',
    trim(m_rec->qual[ml_cnt].s_order_mnemonic,3),'","',trim(m_rec->qual[ml_cnt].s_order_detail,3),
    '","',trim(m_rec->qual[ml_cnt].s_order_id,3),
    '","',trim(m_rec->qual[ml_cnt].s_type,3),'","',trim(m_rec->qual[ml_cnt].s_pharmacy_id,3),'","',
    trim(m_rec->qual[ml_cnt].s_rx_id,3),'","',trim(m_rec->qual[ml_cnt].s_ma_status,3),'","',trim(
     m_rec->qual[ml_cnt].s_ma_error,3),
    '","',trim(m_rec->qual[ml_cnt].s_message_text,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   fin = substring(1,50,m_rec->qual[d.seq].s_fin), patient_name = substring(1,50,m_rec->qual[d.seq].
    s_patient_name), entering_user = substring(1,50,m_rec->qual[d.seq].s_entering_user),
   ordering_provider = substring(1,50,m_rec->qual[d.seq].s_ordering_provider), supervisor = substring
   (1,50,m_rec->qual[d.seq].s_supervisor), order_date = substring(1,50,m_rec->qual[d.seq].
    s_order_date),
   msg_publish_date = substring(1,50,m_rec->qual[d.seq].s_msg_publish_date), order_mnemonic =
   substring(1,50,m_rec->qual[d.seq].s_order_mnemonic), order_detail = substring(1,50,m_rec->qual[d
    .seq].s_order_detail),
   order_id = substring(1,50,m_rec->qual[d.seq].s_order_id), type = substring(1,50,m_rec->qual[d.seq]
    .s_type), pharmacy_id = substring(1,50,m_rec->qual[d.seq].s_pharmacy_id),
   rx_id = substring(1,50,m_rec->qual[d.seq].s_rx_id), ma_status = substring(1,50,m_rec->qual[d.seq].
    s_ma_status), ma_error = substring(1,50,m_rec->qual[d.seq].s_ma_error),
   message_text = substring(1,50,m_rec->qual[d.seq].s_message_text)
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
