CREATE PROGRAM bhs_eprescribing_err_alert:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg date time" = "SYSDATE",
  "End date time" = "SYSDATE",
  "Email:" = ""
  WITH outdev, s_bed_dt_tm, s_end_dt_tm,
  s_recipients
 EXECUTE bhs_hlp_ccl
 FREE RECORD m_msgs_rec
 RECORD m_msgs_rec(
   1 l_err_cntr = i4
   1 s_beg_dt_tm = vc
   1 s_end_dt_tm = vc
   1 msg_list[*]
     2 s_relates_to_msgid = vc
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
 DECLARE mn_page_threshold = i4 WITH protect, constant(20)
 DECLARE mn_email_threshold = i4 WITH protect, noconstant(10)
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_temp_substr = vc WITH protect, noconstant(" ")
 DECLARE ms_msg_text = vc WITH protect, noconstant(" ")
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_search_start = vc WITH protect, noconstant(" ")
 DECLARE ms_search_end = vc WITH protect, noconstant(" ")
 DECLARE ml_start = i4 WITH protect, noconstant(0)
 DECLARE ml_end = i4 WITH protect, noconstant(0)
 DECLARE ml_for_cntr = i4 WITH protect, noconstant(0)
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(trim( $S_BED_DT_TM))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(trim( $S_END_DT_TM))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE mn_page_ind = i2 WITH protect, noconstant(0)
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Begin Script","")
 IF (validate(request->batch_selection)
  AND textlen(ms_recipients)=0)
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET ms_beg_dt_tm = trim(format(cnvtlookbehind("15,MIN",sysdate),"dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_end_dt_tm = trim(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_recipients = "CIScore@baystatehealth.org"
  SELECT INTO "nl:"
   FROM bhs_log_detail b
   PLAN (b
    WHERE b.parent_entity_name="EPRESCRIBE"
     AND b.description="EPRESCRIBE ERR PAGE"
     AND b.updt_dt_tm BETWEEN cnvtlookbehind("60,MIN",cnvtdatetime(ms_end_dt_tm)) AND cnvtdatetime(
     ms_end_dt_tm))
   ORDER BY b.updt_dt_tm DESC
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET mn_page_ind = 1
  ENDIF
 ELSEIF (validate(request->batch_selection)
  AND textlen(ms_recipients) > 0)
  SET mn_ops = 1
  SET mn_page_ind = 1
  SET reply->status_data[1].status = "F"
  IF (((findstring("@",ms_recipients)=0
   AND textlen(ms_recipients) > 0) OR (textlen(ms_recipients) < 10)) )
   SET ms_temp = "Recipient email is invalid"
   GO TO exit_script
  ENDIF
  SET ms_beg_dt_tm = concat(trim(format((curdate - 1),"dd-mmm-yyyy ;;d"),3)," 00:00:00")
  SET ms_end_dt_tm = concat(trim(format((curdate - 1),"dd-mmm-yyyy ;;d"),3)," 23:59:59")
  SET mn_email_threshold = 0
 ELSE
  IF (((findstring("@",ms_recipients)=0
   AND textlen(ms_recipients) > 0) OR (textlen(ms_recipients) < 10)) )
   SET ms_temp = "Recipient email is invalid"
   GO TO exit_script
  ENDIF
  IF (datetimediff(cnvtdatetime(ms_end_dt_tm),cnvtdatetime(ms_beg_dt_tm)) > 7)
   CALL echo("Date range > 7")
   SET ms_temp = "Your date range is larger than 7 days. Please retry."
   GO TO exit_script
  ELSEIF (datetimediff(cnvtdatetime(ms_end_dt_tm),cnvtdatetime(ms_beg_dt_tm)) < 0)
   CALL echo("Date range < 0")
   SET ms_temp = "Your date range is incorrect. Please retry."
   GO TO exit_script
  ENDIF
  SET mn_email_threshold = 0
 ENDIF
 SELECT INTO "nl:"
  FROM oen_txlog o,
   dummyt d
  PLAN (o
   WHERE o.create_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND trim(o.interfaceid,3) IN ("1007", "1008", "1009", "1029", "1144",
   "1145", "1146", "1147", "1023", "1025",
   "1026", "1028", "1194", "1010", "1012",
   "1143", "1157", "1156", "1136", "1137",
   "1138")
    AND o.eventid="*1001*")
   JOIN (d
   WHERE o.msg_text="*<Error>*</Error>*")
  HEAD REPORT
   m_msgs_rec->l_err_cntr = 0, m_msgs_rec->s_beg_dt_tm = ms_beg_dt_tm, m_msgs_rec->s_end_dt_tm =
   ms_end_dt_tm
  DETAIL
   ms_msg_text = o.msg_text, ml_start = (findstring("<Description>",ms_msg_text)+ 13), ml_end =
   findstring("</Description>",ms_msg_text,ml_start,0),
   ms_temp = substring(ml_start,(ml_end - ml_start),ms_msg_text)
   IF (ms_temp != "Controlled substance must have a DEASchedule populated in Medication P")
    m_msgs_rec->l_err_cntr += 1, stat = alterlist(m_msgs_rec->msg_list,m_msgs_rec->l_err_cntr),
    m_msgs_rec->msg_list[m_msgs_rec->l_err_cntr].s_err_msg = trim(ms_temp,3),
    m_msgs_rec->msg_list[m_msgs_rec->l_err_cntr].s_msg_dt_tm = concat(trim(o.msg_date,3)," ",trim(o
      .msg_time,3)), ml_start = (findstring("<RelatesToMessageID>",ms_msg_text)+ 20), ml_end =
    findstring("</RelatesToMessageID>",ms_msg_text,ml_start,0),
    ms_temp = substring(ml_start,(ml_end - ml_start),ms_msg_text)
    IF (ms_temp > " ")
     m_msgs_rec->msg_list[m_msgs_rec->l_err_cntr].s_relates_to_msgid = trim(ms_temp,3)
    ENDIF
    ml_start = (findstring("<Code>",ms_msg_text)+ 6), ml_end = findstring("</Code>",ms_msg_text,
     ml_start,0), ms_temp = substring(ml_start,(ml_end - ml_start),ms_msg_text)
    IF (ms_temp > " ")
     m_msgs_rec->msg_list[m_msgs_rec->l_err_cntr].s_err_code = trim(ms_temp,3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual < 1)
  IF (mn_ops=0)
   SET ms_temp = concat("No errors found for range ",ms_beg_dt_tm," to ",ms_end_dt_tm)
  ENDIF
  GO TO exit_script
 ELSE
  IF ((m_msgs_rec->l_err_cntr >= mn_email_threshold))
   FOR (ml_for_cntr = 1 TO m_msgs_rec->l_err_cntr)
     SELECT INTO "nl:"
      FROM oen_txlog o,
       dummyt d
      PLAN (o
       WHERE o.create_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
        AND trim(o.interfaceid,3) IN ("1007", "1008", "1009", "1029", "1144",
       "1145", "1146", "1147", "1023", "1025",
       "1026", "1028", "1194", "1010", "1012",
       "1143", "1157", "1156", "1136", "1137",
       "1138")
        AND o.eventid="*2001*")
       JOIN (d
       WHERE o.msg_text=build("*",m_msgs_rec->msg_list[ml_for_cntr].s_relates_to_msgid,"*"))
      DETAIL
       ms_msg_text = o.msg_text, ms_search_start = "<Prescriber>", ms_search_end = "</Prescriber>",
       ml_start = (findstring(ms_search_start,ms_msg_text)+ size(ms_search_start)), ml_end =
       findstring(ms_search_end,ms_msg_text,ml_start,0), ms_temp = substring(ml_start,(ml_end -
        ml_start),ms_msg_text),
       ms_search_start = "<LastName>", ms_search_end = "</LastName>", ml_start = (findstring(
        ms_search_start,ms_temp)+ size(ms_search_start)),
       ml_end = findstring(ms_search_end,ms_temp,ml_start,0), ms_temp_substr = substring(ml_start,(
        ml_end - ml_start),ms_temp), ms_temp_substr = build(ms_temp_substr,", "),
       ms_search_start = "<FirstName>", ms_search_end = "</FirstName>", ml_start = (findstring(
        ms_search_start,ms_temp)+ size(ms_search_start)),
       ml_end = findstring(ms_search_end,ms_temp,ml_start,0), ms_temp_substr = build(ms_temp_substr,
        substring(ml_start,(ml_end - ml_start),ms_temp))
       IF (ms_temp_substr > " ")
        m_msgs_rec->msg_list[ml_for_cntr].s_prescriber = trim(ms_temp_substr,3)
       ENDIF
       ms_search_start = "<Patient>", ms_search_end = "</Patient>", ml_start = (findstring(
        ms_search_start,ms_msg_text)+ size(ms_search_start)),
       ml_end = findstring(ms_search_end,ms_msg_text,ml_start,0), ms_temp = substring(ml_start,(
        ml_end - ml_start),ms_msg_text), ms_search_start = "<LastName>",
       ms_search_end = "</LastName>", ml_start = (findstring(ms_search_start,ms_temp)+ size(
        ms_search_start)), ml_end = findstring(ms_search_end,ms_temp,ml_start,0),
       ms_temp_substr = substring(ml_start,(ml_end - ml_start),ms_temp), ms_temp_substr = build(
        ms_temp_substr,", "), ms_search_start = "<FirstName>",
       ms_search_end = "</FirstName>", ml_start = (findstring(ms_search_start,ms_temp)+ size(
        ms_search_start)), ml_end = findstring(ms_search_end,ms_temp,ml_start,0),
       ms_temp_substr = build(ms_temp_substr,substring(ml_start,(ml_end - ml_start),ms_temp))
       IF (ms_temp_substr > " ")
        m_msgs_rec->msg_list[ml_for_cntr].s_pat_name = trim(ms_temp_substr,3)
       ENDIF
       ms_search_start = "<DateOfBirth><Date>", ms_search_end = "</Date></DateOfBirth>", ml_start = (
       findstring(ms_search_start,ms_temp)+ size(ms_search_start)),
       ml_end = findstring(ms_search_end,ms_temp,ml_start,0), ms_temp_substr = substring(ml_start,(
        ml_end - ml_start),ms_temp)
       IF (ms_temp_substr > " ")
        m_msgs_rec->msg_list[ml_for_cntr].s_pat_dob = trim(ms_temp_substr,3)
       ENDIF
       ms_search_start = "<DrugDescription>", ms_search_end = "</DrugDescription>", ml_start = (
       findstring(ms_search_start,ms_msg_text)+ size(ms_search_start)),
       ml_end = findstring(ms_search_end,ms_msg_text,ml_start,0), ms_temp = substring(ml_start,(
        ml_end - ml_start),ms_msg_text)
       IF (ms_temp > " ")
        m_msgs_rec->msg_list[ml_for_cntr].s_drug_descr = trim(ms_temp,3)
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   SET ms_filename = concat("bhs_eprescribing_err_log",".csv")
   SELECT INTO value(ms_filename)
    FROM (dummyt d  WITH seq = value(size(m_msgs_rec->msg_list,5)))
    PLAN (d)
    HEAD REPORT
     ms_temp =
     "msg_dt_tm,relates_to_msgid,err_code,err_msg,prescriber,drug_descr, patient_name, patient_dob",
     col 0, ms_temp
    DETAIL
     row + 1, ms_temp = build('"',trim(m_msgs_rec->msg_list[d.seq].s_msg_dt_tm),'",','"',trim(
       m_msgs_rec->msg_list[d.seq].s_relates_to_msgid),
      '",','"',trim(m_msgs_rec->msg_list[d.seq].s_err_code),'",','"',
      trim(substring(1,400,m_msgs_rec->msg_list[d.seq].s_err_msg)),'",','"',trim(m_msgs_rec->
       msg_list[d.seq].s_prescriber),'",',
      '"',trim(m_msgs_rec->msg_list[d.seq].s_drug_descr),'",','"',trim(m_msgs_rec->msg_list[d.seq].
       s_pat_name),
      '",','"',trim(m_msgs_rec->msg_list[d.seq].s_pat_dob),'"'), col 0,
     ms_temp
    FOOT REPORT
     row + 2, ms_temp = build('"Total number of errors: ",','"',m_msgs_rec->l_err_cntr,'"'), col 0,
     ms_temp, row + 1, ms_temp = concat('"For time period of: ",','" start ',trim(m_msgs_rec->
       s_beg_dt_tm)," end ",trim(m_msgs_rec->s_end_dt_tm),
      '"'),
     col 0, ms_temp
    WITH nocounter, format = variable, formfeed = none,
     maxcol = 500
   ;end select
   SET ms_temp = concat("eprescribe_err_log_from_",trim(m_msgs_rec->s_beg_dt_tm),"_to_",trim(
     m_msgs_rec->s_end_dt_tm),".csv")
   SET ms_temp = replace(ms_temp," ","_",0)
   SET ms_temp = replace(ms_temp,":","-",0)
   EXECUTE bhs_ma_email_file
   CALL emailfile(value(ms_filename),ms_filename,ms_recipients,ms_temp,1)
   IF ((m_msgs_rec->l_err_cntr > mn_page_threshold)
    AND mn_ops=1
    AND mn_page_ind=0)
    CALL echo("PAGEING CORE ON-CALL")
    CALL uar_send_mail(nullterm("94556@epage.bhs.org"),nullterm(concat("SureScripts OPS JOB ",curnode
       )),nullterm(build(curnode," eRX_SureScripts_TCPIP_BI - ",m_msgs_rec->l_err_cntr,
       " errors - check your email")),nullterm(concat("SureScripts OPS JOB ",curnode)),1,
     nullterm("IPM.NOTE"))
    CALL uar_send_mail(nullterm("ciscore@bhs.org"),nullterm(concat("SureScripts OPS JOB ",curnode)),
     nullterm(build(curnode," eRX_SureScripts_TCPIP_BI - ",m_msgs_rec->l_err_cntr,
       " errors - check your email")),nullterm(concat("SureScripts OPS JOB ",curnode)),1,
     nullterm("IPM.NOTE"))
    SET ms_temp = build("EPRESCRIBE PAGE SENT TO CORE - ",m_msgs_rec->l_err_cntr,
     " errors found for range ",ms_beg_dt_tm," to ",
     ms_end_dt_tm)
    CALL bhs_sbr_log("log","",0,"EPRESCRIBE",0.0,
     "EPRESCRIBE ERR PAGE",ms_temp,"S")
   ENDIF
   IF (mn_ops=0)
    SET ms_temp = build(m_msgs_rec->l_err_cntr," errors found for range ",ms_beg_dt_tm," to ",
     ms_end_dt_tm,
     ". Email is sent.")
   ENDIF
  ELSE
   IF (mn_ops=0)
    SET ms_temp = build(m_msgs_rec->l_err_cntr," errors found for range ",ms_beg_dt_tm," to ",
     ms_end_dt_tm,
     ". Email/Page will not be sent.")
   ENDIF
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(m_msgs_rec)
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "Stop Script","End Time","S")
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, ms_temp
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_msgs_rec
END GO
