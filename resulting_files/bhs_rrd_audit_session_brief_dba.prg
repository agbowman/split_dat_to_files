CREATE PROGRAM bhs_rrd_audit_session_brief:dba
 PROMPT
  "Start Date (MMDDYY)" = "YDAY",
  "End Date (MMDDYY)" = "YDAY",
  "Do you want <A>ll or <U>nsuccessful sessions?" = "U",
  "Station Name or Phone Number or <A>ll" = "A",
  "Output to File/Printer/MINE" = "MINE"
  WITH s_start_dt, s_end_dt, s_sessions,
  s_station, outdev
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 RECORD temp(
   1 qual[*]
     2 session_num = i4
   1 newstat = vc
 )
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_temp = vc WITH protect, noconstant("")
 DECLARE ms_recipients = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET reply->status_data[1].status = "F"
  SET mn_ops = 1
  SET ms_output = cnvtlower(build(trim(curprog,3),"_",trim(format(sysdate,"mm_dd_yy_hh_mm_ss ;;d"),3),
    ".pdf"))
  SET ms_subject = build2("RRD Audit Session Brief ",trim(format(sysdate,"mm/dd/yy;;d"),3))
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RRD_AUDIT_SESSION_BRIEF"
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
 ENDIF
 SET pos = findstring(" ", $4)
 IF (pos > 0)
  SET temp->newstat = substring(1,(findstring(" ", $4) - 1), $4)
 ENDIF
 SET temp->newstat =  $4
 IF (( $1="TODAY"))
  SET currdate = curdate
 ELSEIF (( $1="YDAY"))
  SET currdate = (curdate - 1)
 ELSE
  SET currdate = cnvtdate( $1)
 ENDIF
 SET b_session_view_dt_tm = cnvtdatetime(currdate,000001)
 IF (( $2="TODAY"))
  SET e_currdate = curdate
 ELSEIF (( $2="YDAY"))
  SET e_currdate = (curdate - 1)
 ELSE
  SET e_currdate = cnvtdate( $2)
 ENDIF
 SET e_session_view_dt_tm = cnvtdatetime(e_currdate,235959)
 IF (( $4 != "A")
  AND ( $4 != "a"))
  SET pline = concat('cnvtupper(s.message_text) = "*',cnvtupper(trim(temp->newstat,3)),'*"')
 ELSE
  SET pline = "NOSTATION"
 ENDIF
 IF (((( $3="A")) OR (( $3="a"))) )
  IF (pline="NOSTATION")
   SELECT INTO "nl:"
    s.session_num
    FROM session_log s
    WHERE s.qualifier=1
     AND s.sess_dt_tm >= cnvtdatetime(b_session_view_dt_tm)
     AND s.sess_dt_tm <= cnvtdatetime(e_session_view_dt_tm)
    DETAIL
     ml_cnt += 1, stat = alterlist(temp->qual,ml_cnt), temp->qual[ml_cnt].session_num = s.session_num
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    s.session_num
    FROM session_log s
    WHERE s.qualifier=1
     AND ((parser(pline)) OR (((( $4="A")) OR (( $4="a"))) ))
     AND s.sess_dt_tm >= cnvtdatetime(b_session_view_dt_tm)
     AND s.sess_dt_tm <= cnvtdatetime(e_session_view_dt_tm)
    DETAIL
     ml_cnt += 1, stat = alterlist(temp->qual,ml_cnt), temp->qual[ml_cnt].session_num = s.session_num
    WITH nocounter
   ;end select
  ENDIF
  SELECT DISTINCT INTO value(ms_output)
   s2.session_num, s2.qualifier, textlen_s2_message_text = textlen(s2.message_text),
   textlen_s2_message_text = textlen(s2.message_text)
   FROM code_value c,
    (dummyt d  WITH seq = value(ml_cnt)),
    session_log s2
   PLAN (c
    WHERE c.code_set=2205
     AND ((c.cdf_meaning="STATUS") OR (((c.cdf_meaning="DIALING") OR (((c.cdf_meaning="DEST_PHONE")
     OR (c.cdf_meaning="ERROR")) )) )) )
    JOIN (d)
    JOIN (s2
    WHERE (s2.session_num=temp->qual[d.seq].session_num)
     AND ((s2.message_cd=c.code_value) OR (((s2.qualifier=2) OR (s2.message_text="Sent*")) )) )
   ORDER BY s2.session_num, s2.qualifier
   HEAD REPORT
    prev_num = 0, prev_qual = 0, row + 1,
    col 0, " Current Date/Time:", col 30,
    " ALL SESSION NUMBERS FROM ", col 58, currdate"MM/DD/YY;;D",
    col 67, " TO ", col 74,
    e_currdate"MM/DD/YY;;D", row + 1, col 0,
    curdate, col 9, curtime3
    IF (pline != "NOSTATION")
     col 30, "FOR STATION", col 42,
      $4
    ENDIF
    row + 1, col 106, "",
    row + 1, col 0, "Sess_Num",
    col 11, "Session Date/Time", col 31,
    "Message_Text", row + 1, col 0,
    "-----------------------------------------", col 41, "----------------------------------------",
    col 58, "----------------------------------------"
   DETAIL
    row + 1
    IF (s2.session_num != prev_num)
     row + 1, col 0, s2.session_num"########",
     prev_num = s2.session_num
    ENDIF
    col 11, s2.sess_dt_tm"MM/DD/YY HH:MM:SS", col 31,
    CALL print(substring(1,90,s2.message_text))
    IF (textlen_s2_message_text > 90)
     row + 1, col 33, ms_temp = substring(91,(textlen_s2_message_text - 90),s2.message_text),
     CALL print(substring(1,88,ms_temp))
    ENDIF
    IF (textlen(ms_temp) > 88)
     row + 1, col 33,
     CALL print(substring(89,88,ms_temp))
    ENDIF
    ms_temp = ""
   WITH nocounter, check, maxcol = 300,
    dio = pdf, landscape
  ;end select
 ELSEIF (((( $3="U")) OR (( $3="u"))) )
  IF (pline="NOSTATION")
   SELECT DISTINCT INTO TABLE temp_sess
    s.session_num
    FROM code_value st,
     (dummyt d1  WITH seq = 1),
     session_log s
    PLAN (st
     WHERE st.code_set=2205
      AND st.cdf_meaning="ERROR")
     JOIN (d1)
     JOIN (s
     WHERE s.message_cd=st.code_value
      AND s.sess_dt_tm >= cnvtdatetime(b_session_view_dt_tm)
      AND s.sess_dt_tm <= cnvtdatetime(e_session_view_dt_tm))
    ORDER BY s.session_num
    WITH organization = work, nocounter
   ;end select
  ELSE
   SELECT DISTINCT INTO TABLE temp_sess
    s.session_num
    FROM code_value st,
     (dummyt d1  WITH seq = 1),
     session_log s,
     session_log s2
    PLAN (st
     WHERE st.code_set=2205
      AND st.cdf_meaning="ERROR")
     JOIN (d1)
     JOIN (s2
     WHERE s2.message_cd=st.code_value
      AND s2.sess_dt_tm >= cnvtdatetime(b_session_view_dt_tm)
      AND s2.sess_dt_tm <= cnvtdatetime(e_session_view_dt_tm))
     JOIN (s
     WHERE s.session_num=s2.session_num
      AND s.qualifier=1
      AND parser(pline))
    ORDER BY s.session_num
    WITH organization = work, nocounter
   ;end select
  ENDIF
  SELECT DISTINCT INTO value(ms_output)
   s.*, textlen_s_message_text = textlen(s.message_text), textlen_s_message_text = textlen(s
    .message_text)
   FROM temp_sess t,
    session_log s
   PLAN (t)
    JOIN (s
    WHERE s.session_num=t.session_num
     AND s.sess_dt_tm >= cnvtdatetime(b_session_view_dt_tm)
     AND s.sess_dt_tm <= cnvtdatetime(e_session_view_dt_tm))
   ORDER BY s.session_num, s.qualifier
   HEAD REPORT
    prev_num = 0, prev_qual = 0, row + 1,
    col 0, " Current Date/Time:", col 30,
    " ERROR SESSIONS FROM ", col 52, currdate"MM/DD/YY;;D",
    col 62, " TO ", col 67,
    e_currdate"MM/DD/YY;;D", row + 1, col 0,
    curdate, col 9, curtime3
    IF (pline != "NOSTATION")
     col 30, "FOR STATION ", col 42,
      $4
    ENDIF
    row + 1, col 106, "",
    row + 1, col 0, "Sess_Num",
    col 11, "Session Date/Time", col 31,
    "Message_Text", row + 1, col 0,
    "-----------------------------------------", col 41, "----------------------------------------",
    col 58, "----------------------------------------"
   DETAIL
    row + 1
    IF (s.session_num != prev_num)
     row + 1, col 0, s.session_num"########",
     prev_num = s.session_num
    ENDIF
    col 11, s.sess_dt_tm"MM/DD/YY HH:MM:SS", col 31,
    CALL print(substring(1,90,s.message_text))
    IF (textlen_s_message_text > 90)
     row + 1, col 33, ms_temp = substring(91,(textlen_s_message_text - 90),s.message_text),
     CALL print(substring(1,88,ms_temp))
    ENDIF
    IF (textlen(ms_temp) > 88)
     row + 1, col 33,
     CALL print(substring(89,88,ms_temp))
    ENDIF
    ms_temp = ""
   WITH nocounter, check, maxcol = 300,
    nullreport, dio = pdf, landscape
  ;end select
  IF (mn_ops=1)
   EXECUTE bhs_ma_email_file
   CALL emailfile(ms_output,ms_output,ms_recipients,ms_subject,1)
   SET ms_dclcom = "rm -f bhs_rrd_audit_session_brief*"
   SET stat = 0
   SET stat = dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
  ENDIF
 ENDIF
#999_exit
END GO
