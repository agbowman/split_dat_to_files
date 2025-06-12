CREATE PROGRAM bhs_rpt_dsi_feedback:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Enter Emails" = "",
  "Check to Email" = 0,
  "Date Range" = ""
  WITH outdev, s_start_date, s_end_date,
  s_emails, chk_emails, s_range
 DECLARE test = vc WITH protect
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE ml1_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_filename = vc WITH noconstant("dsi_feedback"), protect
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),"_",format(sysdate,
    "YYYYMMDDHHSS;;q"),".csv")), protect
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 FREE RECORD dsi
 RECORD dsi(
   1 p_cnt = i4
   1 feedbck[*]
     2 domain = vc
     2 fin = vc
     2 user = vc
     2 userid = f8
     2 user_name = vc
     2 rule_name = vc
     2 feed_back = vc
     2 location = vc
 )
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 IF (cnvtupper(trim( $S_RANGE,3))="DAILY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0)),"D","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0)),"D","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
  SET ms_output_file = build(trim(ms_filename,3),"_daily_",format(sysdate,"YYYYMMDDHHSS;;q"),".csv")
  SET ms_subject = build2("Daily DSI Feed Back ",trim(format(cnvtdatetime(ms_end_date),
     "mmm-dd-yyyy hh:mm ;;d"),3))
 ELSEIF (cnvtupper(trim( $S_RANGE,3))="WEEKLY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
  SET ms_output_file = build(trim(ms_filename,3),"_weekly_",format(sysdate,"YYYYMMDDHHSS;;q"),".csv")
  SET ms_subject = build2("Weekly DSI Feed Back ",trim(format(cnvtdatetime(ms_end_date),
     "mmm-dd-yyyy hh:mm ;;d"),3))
 ELSEIF (cnvtupper(trim( $S_RANGE,3))="MONTHLY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
  SET ms_output_file = build(trim(ms_filename,3),"_monthly_",format(sysdate,"YYYYMMDDHHSS;;q"),".csv"
   )
  SET ms_subject = build2("Monthly DSI Feed Back ",trim(format(cnvtdatetime(ms_end_date),
     "mmm-dd-yyyy hh:mm ;;d"),3))
 ELSE
  SET ms_output_file = build(trim(ms_filename,3),"_",format(sysdate,"YYYYMMDDHHSS;;q"),".csv")
  SET ms_subject = build2("DSI Feed Back ",trim(format(cnvtdatetime(ms_end_date),
     "mmm-dd-yyyy hh:mm ;;d"),3))
 ENDIF
 SELECT INTO "nl:"
  FROM dsi_feedback d,
   prsnl p,
   encntr_alias ea
  PLAN (d
   WHERE d.dsi_feedback_id > 0
    AND d.dsi_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),curtime3) AND
   cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),curtime3))
   JOIN (p
   WHERE p.person_id=d.prsnl_id)
   JOIN (ea
   WHERE ea.encntr_id=d.encntr_id
    AND ea.encntr_alias_type_cd=mf_cs319_fin)
  HEAD REPORT
   stat = alterlist(dsi->feedbck,10)
  DETAIL
   dsi->p_cnt += 1
   IF (mod(dsi->p_cnt,10)=1
    AND (dsi->p_cnt > 1))
    stat = alterlist(dsi->feedbck,(dsi->p_cnt+ 9))
   ENDIF
   dsi->feedbck[dsi->p_cnt].domain = trim(curdomain,3), dsi->feedbck[dsi->p_cnt].fin = trim(ea.alias,
    3), dsi->feedbck[dsi->p_cnt].user = trim(p.username,3),
   dsi->feedbck[dsi->p_cnt].userid = p.person_id, dsi->feedbck[dsi->p_cnt].user_name = trim(p
    .name_full_formatted,3), dsi->feedbck[dsi->p_cnt].feed_back = trim(replace(replace(d.feedback_txt,
      char(10)," "),char(13)," "),3),
   dsi->feedbck[dsi->p_cnt].location = trim(replace(replace(d.location_txt,char(10)," "),char(13)," "
     ),3)
   IF (d.dsi_name IN ("BHS_*", "PHA_*"))
    dsi->feedbck[dsi->p_cnt].rule_name = trim(substring(9,50,d.dsi_name),0)
   ELSEIF (d.dsi_name="BH_*")
    dsi->feedbck[dsi->p_cnt].rule_name = trim(substring(8,50,d.dsi_name),0)
   ENDIF
  FOOT REPORT
   stat = alterlist(dsi->feedbck,dsi->p_cnt)
  WITH nocounter, format, separator = " "
 ;end select
 IF (( $CHK_EMAILS=0)
  AND size(dsi->feedbck,5) > 0)
  SELECT INTO  $OUTDEV
   domain = substring(1,30,dsi->feedbck[d1.seq].domain), fin = substring(1,30,dsi->feedbck[d1.seq].
    fin), user = substring(1,30,dsi->feedbck[d1.seq].user),
   userid = dsi->feedbck[d1.seq].userid, personnel = substring(1,100,dsi->feedbck[d1.seq].user_name),
   rule_name = substring(1,50,dsi->feedbck[d1.seq].rule_name),
   feed_back = substring(1,250,dsi->feedbck[d1.seq].feed_back), location = substring(1,250,dsi->
    feedbck[d1.seq].location)
   FROM (dummyt d1  WITH seq = size(dsi->feedbck,5))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (( $CHK_EMAILS=1)
  AND size(dsi->feedbck,5) > 0)
  SET frec->file_name = ms_output_file
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"Domain",','"FIN",','"Personnel",','"User Name",','"Rule Name",',
   '"Feed Back",','"Location",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml1_cnt = 1 TO size(dsi->feedbck,5))
   SET frec->file_buf = build('"',trim(dsi->feedbck[ml1_cnt].domain,3),'","',trim(dsi->feedbck[
     ml1_cnt].fin,3),'","',
    trim(dsi->feedbck[ml1_cnt].user,3),'","',trim(dsi->feedbck[ml1_cnt].user_name,3),'","',trim(dsi->
     feedbck[ml1_cnt].rule_name,3),
    '","',trim(dsi->feedbck[ml1_cnt].feed_back,3),'","',trim(dsi->feedbck[ml1_cnt].location,3),'"',
    char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  IF (findstring("@", $S_EMAILS))
   EXECUTE bhs_ma_email_file
   CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
     CALL print(calcpos(36,18)),
     msg1, row + 2, msg2
    WITH dio = 08
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     msg1 = concat("File: ",build2(ms_output_file)),
     CALL print(calcpos(36,18)), msg1
    WITH dio = 08
   ;end select
  ENDIF
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt d
   HEAD REPORT
    msg1 = "No Data",
    CALL print(calcpos(36,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
