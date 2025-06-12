CREATE PROGRAM bhs_rpt_erx_errors:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg date time" = "SYSDATE",
  "End date time" = "SYSDATE",
  "Email:" = ""
  WITH outdev, s_beg_dt_tm, s_end_dt_tm,
  s_recipients
 FREE RECORD m_rec
 RECORD m_rec(
   1 msg[*]
     2 s_relate_msgid = vc
     2 s_msg_dt_tm = vc
     2 s_err_code = vc
     2 s_err_msg = vc
     2 s_drug_descr = vc
     2 s_prescriber = vc
     2 s_pat_name = vc
     2 s_pat_dob = vc
 ) WITH protect
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
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS,3))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_msg_id = vc WITH protect, noconstant("")
 DECLARE ms_temp = vc WITH protect, noconstant("")
 DECLARE ms_temp_str = vc WITH protect, noconstant("")
 DECLARE ms_end = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE mf_beg_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEG_DT_TM))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DT_TM))
 DECLARE ml_start = i4 WITH protect, noconstant(0)
 DECLARE ml_end = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE mn_cont = i2 WITH protect, noconstant(0)
 SUBROUTINE (parse_msg(s_tag=vc,s_msg_text=vc) =vc)
   SET ml_start = findstring(s_tag,s_msg_text)
   SET ms_temp = replace(s_tag,"<","</")
   SET ms_end = ""
   SET mn_cont = 1
   SET ml_loop = 0
   WHILE (mn_cont=1)
     SET ml_loop += 1
     SET ml_end = findstring("</",ms_temp,1,1)
     SET ms_end = trim(concat(ms_end,substring(ml_end,((textlen(ms_temp) - ml_end)+ 1),ms_temp)),3)
     SET ms_temp = substring(1,(textlen(ms_temp) - size(ms_end)),ms_temp)
     IF (((findstring("</",ms_temp,1,1)=0) OR (ml_loop > 10)) )
      SET mn_cont = 0
     ENDIF
   ENDWHILE
   SET ml_end = findstring(ms_end,s_msg_text,ml_start)
   SET ms_msg = substring((ml_start+ size(s_tag)),((ml_end - ml_start) - size(s_tag)),s_msg_text)
   RETURN(trim(ms_msg,3))
 END ;Subroutine
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_beg_dt_tm = cnvtdatetime((curdate - 1),000000)
  SET mf_end_dt_tm = cnvtdatetime((curdate - 1),235959)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_ERX_ERRORS"
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
 ELSE
  IF (findstring("@",ms_recipients)=0
   AND textlen(ms_recipients) > 0)
   SET ms_error = "Recipient email is invalid."
   GO TO exit_script
  ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_beg_dt_tm)) > 1)
   SET ms_error = "Your time range is larger than 24 hours. Please retry."
   GO TO exit_script
  ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_beg_dt_tm)) < 0)
   SET ms_error = "Your start date is after your end date. Please retry."
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM oen_txlog o,
   dummyt d
  PLAN (o
   WHERE o.create_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND o.interfaceid IN (" 1010", " 1012", " 1023", " 1025", " 1026",
   " 1028", " 1029", " 1137", " 1138", " 1144",
   " 1145", " 1146", " 1147")
    AND o.eventid="1001")
   JOIN (d
   WHERE o.msg_text="*<Error>*")
  ORDER BY o.msg_date, o.msg_time
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   IF (parse_msg("<Description>",o.msg_text) !=
   "Controlled substance must have a DEASchedule populated in Medication P")
    ml_cnt += 1
    IF (ml_cnt > size(m_rec->msg,5))
     CALL alterlist(m_rec->msg,(ml_cnt+ 99))
    ENDIF
    m_rec->msg[ml_cnt].s_msg_dt_tm = concat(trim(o.msg_date,3)," ",trim(o.msg_time,3)), m_rec->msg[
    ml_cnt].s_relate_msgid = parse_msg("<RelatesToMessageID>",o.msg_text), m_rec->msg[ml_cnt].
    s_err_code = parse_msg("<Code>",o.msg_text),
    m_rec->msg[ml_cnt].s_err_msg = substring(1,400,parse_msg("<Description>",o.msg_text))
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->msg,(ml_cnt+ 3)), m_rec->msg[(ml_cnt+ 2)].s_msg_dt_tm =
   "Total number of errors:", m_rec->msg[(ml_cnt+ 2)].s_relate_msgid = cnvtstring(ml_cnt),
   m_rec->msg[(ml_cnt+ 3)].s_msg_dt_tm = "Date range:", m_rec->msg[(ml_cnt+ 3)].s_relate_msgid =
   concat(trim(format(mf_beg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),3)," to ",trim(format(mf_end_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d"),3))
  WITH nocounter
 ;end select
 IF (curqual=0
  AND mn_ops=0)
  SET ms_error = concat("No errors found for ",trim(format(mf_beg_dt_tm,"mm/dd/yy hh:mm;;d"),3),
   " to ",trim(format(mf_end_dt_tm,"mm/dd/yy hh:mm;;d"),3))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM oen_txlog o,
   dummyt d
  PLAN (o
   WHERE o.create_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND o.interfaceid IN (" 1010", " 1012", " 1023", " 1025", " 1026",
   " 1028", " 1029", " 1137", " 1138", " 1144",
   " 1145", " 1146", " 1147")
    AND o.eventid="2001")
   JOIN (d
   WHERE o.msg_text="*<Name>*")
  HEAD REPORT
   ml_idx = 0, ml_cnt = 0
  DETAIL
   ms_msg_id = parse_msg("<MessageID>",o.msg_text), ml_idx = locateval(ml_cnt,1,size(m_rec->msg,5),
    ms_msg_id,m_rec->msg[ml_cnt].s_relate_msgid)
   IF (ml_idx > 0)
    m_rec->msg[ml_idx].s_pat_dob = parse_msg("<DateOfBirth><Date>",o.msg_text), m_rec->msg[ml_idx].
    s_drug_descr = parse_msg("<DrugDescription>",o.msg_text), ms_temp_str = parse_msg("<Prescriber>",
     o.msg_text),
    m_rec->msg[ml_idx].s_prescriber = build2(parse_msg("<LastName>",ms_temp_str),", ",parse_msg(
      "<FirstName>",ms_temp_str)), ms_temp_str = parse_msg("<Patient>",o.msg_text), m_rec->msg[ml_idx
    ].s_pat_name = build2(parse_msg("<LastName>",ms_temp_str),", ",parse_msg("<FirstName>",
      ms_temp_str))
   ENDIF
  WITH nocounter
 ;end select
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 0)) )
  SET frec->file_name = build("bhs_rpt_erx_errors_",trim(format(cnvtdatetime(mf_beg_dt_tm),
     "mm_dd_yy ;;d"),3),".csv")
  SET ms_subject = build2("ePrescribing Error Report ",trim(format(mf_beg_dt_tm,"dd-mmm-yyyy ;;d"),3),
   " to ",trim(format(mf_end_dt_tm,"dd-mmm-yyyy ;;d"),3))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"MSG_DT_TM",','"RELATES_TO_MSGID",','"ERR_CODE",','"ERR_MSG",',
   '"PRESCRIBER",',
   '"DRUG_DESCRIPTION",','"PATIENT_NAME",','"PATIENT_DOB",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO size(m_rec->msg,5))
   SET frec->file_buf = build('"',trim(m_rec->msg[ml_cnt].s_msg_dt_tm,3),'","',trim(m_rec->msg[ml_cnt
     ].s_relate_msgid,3),'","',
    trim(m_rec->msg[ml_cnt].s_err_code,3),'","',trim(m_rec->msg[ml_cnt].s_err_msg,3),'","',trim(m_rec
     ->msg[ml_cnt].s_prescriber,3),
    '","',trim(m_rec->msg[ml_cnt].s_drug_descr,3),'","',trim(m_rec->msg[ml_cnt].s_pat_name,3),'","',
    trim(m_rec->msg[ml_cnt].s_pat_dob,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   msg_dt_tm = substring(1,50,m_rec->msg[d.seq].s_msg_dt_tm), relates_to_msgid = substring(1,50,m_rec
    ->msg[d.seq].s_relate_msgid), err_code = substring(1,50,m_rec->msg[d.seq].s_err_code),
   err_msg = substring(1,400,m_rec->msg[d.seq].s_err_msg), prescriber = substring(1,50,m_rec->msg[d
    .seq].s_prescriber), drug_description = substring(1,50,m_rec->msg[d.seq].s_drug_descr),
   patient_name = substring(1,50,m_rec->msg[d.seq].s_pat_name), patient_dob = substring(1,50,m_rec->
    msg[d.seq].s_pat_dob)
   FROM (dummyt d  WITH seq = size(m_rec->msg,5))
   PLAN (d)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
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
