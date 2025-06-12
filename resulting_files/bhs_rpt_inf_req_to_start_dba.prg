CREATE PROGRAM bhs_rpt_inf_req_to_start:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Email Recipient" = "",
  "Test file" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_email_recip, s_test_file
 FREE RECORD m_rec
 RECORD m_rec(
   1 f_tot_req_to_admin_mins = f8
   1 f_avg_mins = f8
   1 inf[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_service_dt = vc
     2 f_order_id = f8
     2 s_order_mnem = vc
     2 s_unit = vc
     2 f_req_dt_tm = dq8
     2 s_req_dt_tm = vc
     2 s_admin_dt_tm = vc
     2 s_verify_dt_tm = vc
     2 s_req_to_admin_mins = vc
     2 s_req_to_verify_mins = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE ms_email_recip = vc WITH protect, constant(trim( $S_EMAIL_RECIP,3))
 DECLARE ms_test_file = vc WITH protect, constant(cnvtlower(trim( $S_TEST_FILE,3)))
 DECLARE mf_cs220_mob = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"MEDSTAYMOBINF"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs4000040_admin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!12110417")
  )
 DECLARE mf_cs4003306_routine = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!4110062019"))
 DECLARE ms_file_name = vc WITH protect, constant(concat("bhs_rpt_inf_req_to_start_",trim(format(
     sysdate,"mmddyyhhmm;;d"),3),".csv"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE mf_tmp = f8 WITH protect, noconstant(0)
 DECLARE ms_recipients = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 EXECUTE bhs_check_domain
 IF (validate(request->batch_selection)=0)
  CALL echo("not ops")
  IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
   SET ms_log = "Both dates must be filled out"
   GO TO exit_script
  ENDIF
  IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
   SET ms_log = "End date must be greater than Beg date"
   GO TO exit_script
  ENDIF
  SET ms_beg_dt_tm = concat(trim( $S_BEG_DT,3)," 00:00:00")
  SET ms_end_dt_tm = concat(trim( $S_END_DT,3)," 23:59:59")
  SET ms_recipients = ms_email_recip
 ELSE
  SET mn_ops = 1
  SET ms_beg_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","B","B"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
  SET ms_end_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","E","E"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_INF_REQ_TO_START"
    AND di.info_char="EMAIL"
   ORDER BY di.info_name
   DETAIL
    IF (textlen(trim(ms_recipients,3)) < 1)
     ms_recipients = trim(di.info_name,3)
    ELSE
     ms_recipients = concat(ms_recipients,", ",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
  IF (findstring("@",ms_recipients)=0
   AND textlen(trim(ms_recipients,3)) > 0)
   SET ms_log = "Recipient email is invalid"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 CALL echo("main select")
 SELECT INTO "nl:"
  FROM rx_med_request rmr,
   med_admin_event mae,
   orders o,
   encounter e,
   encntr_alias ea,
   person p
  PLAN (rmr
   WHERE rmr.request_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND rmr.request_priority_cd=mf_cs4003306_routine)
   JOIN (mae
   WHERE mae.order_id=rmr.order_id
    AND mae.event_type_cd=mf_cs4000040_admin)
   JOIN (o
   WHERE o.order_id=rmr.order_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.loc_nurse_unit_cd=mf_cs220_mob)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_cs319_mrn)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY rmr.request_dt_tm, rmr.order_id
  HEAD REPORT
   pl_cnt = 0
  HEAD rmr.order_id
   pl_cnt += 1,
   CALL alterlist(m_rec->inf,(pl_cnt+ 10)), m_rec->inf[pl_cnt].f_person_id = e.person_id,
   m_rec->inf[pl_cnt].f_encntr_id = o.encntr_id, m_rec->inf[pl_cnt].s_pat_name = trim(p
    .name_full_formatted,3), m_rec->inf[pl_cnt].s_mrn = trim(ea.alias,3),
   m_rec->inf[pl_cnt].f_order_id = o.order_id, m_rec->inf[pl_cnt].s_order_mnem = trim(o
    .order_mnemonic,3), m_rec->inf[pl_cnt].s_service_dt = trim(format(mae.end_dt_tm,
     "mm/dd/yyyy hh:mm;;d"),3),
   m_rec->inf[pl_cnt].s_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), m_rec->inf[pl_cnt].
   f_req_dt_tm = rmr.request_dt_tm, m_rec->inf[pl_cnt].s_req_dt_tm = trim(format(rmr.request_dt_tm,
     "mm/dd/yyyy hh:mm;;d"),3),
   m_rec->inf[pl_cnt].s_admin_dt_tm = trim(format(mae.end_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), mf_tmp =
   datetimediff(mae.end_dt_tm,rmr.request_dt_tm,4), m_rec->inf[pl_cnt].s_req_to_admin_mins = concat(
    trim(cnvtstring(mf_tmp),3)," mins"),
   m_rec->f_tot_req_to_admin_mins += mf_tmp
  FOOT REPORT
   CALL alterlist(m_rec->inf,pl_cnt)
  WITH uar_code(d), format(date,"mm/dd/yy hh:mm;;d")
 ;end select
 IF (size(m_rec->inf,5)=0)
  SET ms_log = "no records found"
  GO TO exit_script
 ENDIF
 SET m_rec->f_avg_mins = (m_rec->f_tot_req_to_admin_mins/ size(m_rec->inf,5))
 CALL echo("get pharm info")
 SELECT INTO "nl:"
  FROM order_action oa
  PLAN (oa
   WHERE expand(ml_exp,1,size(m_rec->inf,5),oa.order_id,m_rec->inf[ml_exp].f_order_id)
    AND oa.needs_verify_ind=3)
  ORDER BY oa.order_id, oa.action_sequence, oa.action_dt_tm DESC
  HEAD oa.order_id
   ml_idx = locateval(ml_loc,1,size(m_rec->inf,5),oa.order_id,m_rec->inf[ml_exp].f_order_id), m_rec->
   inf[ml_idx].s_verify_dt_tm = trim(format(oa.action_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), m_rec->inf[
   ml_idx].s_req_to_verify_mins = concat(trim(cnvtstring(datetimediff(oa.action_dt_tm,m_rec->inf[
       ml_idx].f_req_dt_tm,4)),3)," mins")
  WITH nocounter, expand = 1
 ;end select
 IF (textlen(trim(ms_recipients,3)) > 0)
  CALL echo("CCLIO")
  IF (size(m_rec->inf,5) > 0)
   SET frec->file_name = ms_file_name
   CALL echo(build2("frec file name: ",frec->file_name))
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = concat(
    '"MRN","PATIENT_NAME","DRUG","DATE_OF_SERVICE","UNIT","REQUEST_TO_ADMIN_MINS",',
    '"REQUEST_TO_VERIFY_MINS","AVG_REQUEST_TO_ADMIN_MINS"',char(10))
   SET stat = cclio("WRITE",frec)
   FOR (ml_loop = 1 TO size(m_rec->inf,5))
    SET frec->file_buf = concat('"',m_rec->inf[ml_loop].s_mrn,'",','"',m_rec->inf[ml_loop].s_pat_name,
     '",','"',m_rec->inf[ml_loop].s_order_mnem,'",','"',
     m_rec->inf[ml_loop].s_service_dt,'",','"',m_rec->inf[ml_loop].s_unit,'",',
     '"',m_rec->inf[ml_loop].s_req_to_admin_mins,'",','"',m_rec->inf[ml_loop].s_req_to_verify_mins,
     '",','"',trim(cnvtstring(m_rec->f_avg_mins),3),'"',char(10))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   CALL echo(concat("ms_reciplients"," ",ms_subject))
   SET ms_subject = concat("Request to Infusion Report ",trim(format(sysdate,"mmm-dd-yy;;d"),3))
   EXECUTE bhs_ma_email_file
   CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
   IF (mn_ops=0)
    SELECT INTO value( $OUTDEV)
     FROM dummyt
     HEAD REPORT
      ms_tmp = concat("Report emailed to ",ms_recipients), col 0, ms_tmp
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ELSE
  CALL echo("select to output")
  SELECT INTO value( $OUTDEV)
   mrn = m_rec->inf[d.seq].s_mrn, patient_name = m_rec->inf[d.seq].s_pat_name, drug = m_rec->inf[d
   .seq].s_order_mnem,
   date_of_service = m_rec->inf[d.seq].s_service_dt, unit = m_rec->inf[d.seq].s_unit,
   request_to_admin_mins = m_rec->inf[d.seq].s_req_to_admin_mins,
   request_to_verify_mins = m_rec->inf[d.seq].s_req_to_verify_mins, avg_request_to_admins_mins = trim
   (cnvtstring(m_rec->f_avg_mins),3)
   FROM (dummyt d  WITH seq = value(size(m_rec->inf,5)))
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 IF ((reply->status_data[1].status="F"))
  CALL echo(ms_log)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    ms_log
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_rec
END GO
