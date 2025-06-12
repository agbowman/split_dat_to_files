CREATE PROGRAM bhs_rpt_roi_summary:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Select Personnel" = value(0.0),
  "Enter Emails" = "",
  "Select for Summary" = 0,
  "Date Range" = "",
  "Select Request Status" = value(4198.00)
  WITH outdev, s_start_date, s_end_date,
  f_prsnl, s_emails, l_sum,
  s_range, f_status
 DECLARE cnt_prsnl = i4 WITH noconstant(0), protect
 DECLARE cnt_req = i4 WITH noconstant(0), protect
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE ms_week1end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE ml1_cnt = i4 WITH noconstant(0), protect
 DECLARE ml2_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_opr_var2 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_filename = vc WITH noconstant("bhs_roi_"), protect
 IF (( $L_SUM=1))
  SET ms_filename = build(trim(ms_filename,3),"summary")
 ELSEIF (( $L_SUM=0))
  SET ms_filename = build(trim(ms_filename,3),"detail")
 ENDIF
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),"_",trim(cnvtlower( $S_RANGE),
    3),format(sysdate,"MMDDYYYY;;q"),".csv")), protect
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD grec
 RECORD grec(
   1 list[*]
     2 f_prsnlid = f8
     2 s_name = c15
 )
 FREE RECORD grec1
 RECORD grec1(
   1 list[*]
     2 f_cv = f8
     2 s_disp = vc
 )
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_PRSNL),0)))
 SET ml_gcnt = 0
 IF (ms_lcheck="L")
  SET ms_opr_var1 = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_PRSNL),ml_gcnt)))
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec->list,(ml_gcnt+ 4))
     ENDIF
     SET grec->list[ml_gcnt].f_prsnlid = cnvtint(parameter(parameter2( $F_PRSNL),ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec->list,1)
  SET ml_gcnt = 1
  SET grec->list[1].f_prsnlid =  $F_PRSNL
  IF ((grec->list[1].f_prsnlid=0.0))
   SET ms_opr_var1 = "!="
  ELSE
   SET ms_opr_var1 = "="
  ENDIF
 ENDIF
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_STATUS),0)))
 SET ml_gcnt = 0
 IF (ms_lcheck="L")
  SET ms_opr_var2 = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_STATUS),ml_gcnt)))
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gcnt+ 4))
     ENDIF
     SET grec1->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_STATUS),ml_gcnt))
     SET grec1->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_STATUS),ml_gcnt)
      )
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec1->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gcnt = 1
  SET grec1->list[1].f_cv =  $F_STATUS
  IF ((grec1->list[1].f_cv=0.0))
   SET grec1->list[1].s_disp = "All DTAs"
   SET ms_opr_var2 = "!="
  ELSE
   SET grec1->list[1].s_disp = uar_get_code_display(grec1->list[1].f_cv)
   SET ms_opr_var2 = "="
  ENDIF
 ENDIF
 IF (cnvtupper(trim( $S_RANGE,3))="DAILY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0)),"D","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0)),"D","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ELSEIF (cnvtupper(trim( $S_RANGE,3))="WEEKLY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ELSEIF (cnvtupper(trim( $S_RANGE,3))="MONTHLY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ENDIF
 IF (cnvtdatetime(ms_start_date) > cnvtdatetime(ms_end_date))
  SET ms_error = "Start date must be less than end date."
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(ms_end_date),cnvtdatetime(ms_start_date)) > 93)
  SET ms_error = "Date range exceeds 93 days."
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
  GO TO exit_script
 ELSEIF (findstring("@", $S_EMAILS)=0
  AND textlen( $S_EMAILS) > 0
  AND ( $S_RANGE != "SCREEN"))
  SET ms_error = "Recipient email is invalid."
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
  GO TO exit_script
 ENDIF
 RECORD him_roi(
   1 total_requests = i4
   1 cnt_prsnl = i4
   1 prsnl[*]
     2 first_name = vc
     2 last_name = vc
     2 req_tot = i4
     2 tat_avg = f8
     2 request[*]
       3 req_dt = vc
       3 completed_dt = vc
       3 request = vc
       3 request_type = vc
       3 request_reason = vc
       3 status = vc
       3 tat = f8
 )
 SELECT INTO "nl:"
  FROM him_request hr,
   roi_request rr,
   roi_invoice ri,
   requester r,
   organization o,
   prsnl usr
  PLAN (hr
   WHERE operator(hr.request_status_cd,ms_opr_var2, $F_STATUS)
    AND hr.request_status_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)
    AND hr.active_ind=1)
   JOIN (rr
   WHERE rr.him_request_id=hr.him_request_id
    AND rr.active_ind=1)
   JOIN (ri
   WHERE (ri.request_id= Outerjoin(rr.him_request_id))
    AND (ri.active_ind= Outerjoin(1)) )
   JOIN (usr
   WHERE usr.person_id=hr.request_status_prsnl_id
    AND operator(usr.person_id,ms_opr_var1, $F_PRSNL))
   JOIN (r
   WHERE r.requester_id=hr.roi_requester_id)
   JOIN (o
   WHERE o.organization_id=hr.organization_id)
  ORDER BY usr.name_last, usr.name_first, hr.request_status_prsnl_id,
   hr.request_dt_tm
  HEAD REPORT
   stat = alterlist(him_roi->prsnl,10)
  HEAD hr.request_status_prsnl_id
   cnt_prsnl += 1, him_roi->cnt_prsnl = cnt_prsnl
   IF (mod(cnt_prsnl,10)=1
    AND cnt_prsnl > 1)
    stat = alterlist(him_roi->prsnl,(cnt_prsnl+ 9))
   ENDIF
   him_roi->prsnl[cnt_prsnl].last_name = trim(usr.name_last,3), him_roi->prsnl[cnt_prsnl].first_name
    = trim(usr.name_first,3), stat = alterlist(him_roi->prsnl[cnt_prsnl].request,10)
  DETAIL
   cnt_req += 1
   IF (mod(cnt_req,10)=1
    AND cnt_req > 1)
    stat = alterlist(him_roi->prsnl[cnt_prsnl].request,(cnt_req+ 9))
   ENDIF
   him_roi->prsnl[cnt_prsnl].request[cnt_req].request = cnvtstring(hr.request_number)
   IF (hr.request_status_dt_tm > hr.request_dt_tm)
    him_roi->prsnl[cnt_prsnl].request[cnt_req].tat = round(datetimediff(hr.request_status_dt_tm,hr
      .request_dt_tm,1),2), him_roi->prsnl[cnt_prsnl].tat_avg += datetimediff(hr.request_status_dt_tm,
     hr.request_dt_tm,1)
   ELSE
    him_roi->prsnl[cnt_prsnl].request[cnt_req].tat = 0
   ENDIF
   him_roi->prsnl[cnt_prsnl].request[cnt_req].req_dt = format(hr.request_dt_tm,"mm/dd/yyyy;;D"),
   him_roi->prsnl[cnt_prsnl].request[cnt_req].completed_dt = format(hr.request_status_dt_tm,
    "mm/dd/yyyy;;D"), him_roi->prsnl[cnt_prsnl].req_tot = cnt_req,
   him_roi->prsnl[cnt_prsnl].request[cnt_req].status = uar_get_code_display(hr.request_status_cd),
   him_roi->prsnl[cnt_prsnl].request[cnt_req].request_type = uar_get_code_display(hr.request_type_cd),
   him_roi->prsnl[cnt_prsnl].request[cnt_req].request_reason = uar_get_code_display(rr
    .request_reason_cd),
   him_roi->total_requests += 1
  FOOT  hr.request_status_prsnl_id
   stat = alterlist(him_roi->prsnl[cnt_prsnl].request,cnt_req), him_roi->prsnl[cnt_prsnl].tat_avg =
   round((him_roi->prsnl[cnt_prsnl].tat_avg/ cnt_req),2), cnt_req = 0
  FOOT REPORT
   stat = alterlist(him_roi->prsnl,cnt_prsnl), cnt_prsnl = 0
  WITH nocounter, format, separator = " "
 ;end select
 IF (( $S_RANGE="SCREEN")
  AND ( $L_SUM=1))
  SELECT INTO  $OUTDEV
   first_name = substring(1,30,him_roi->prsnl[d1.seq].first_name), last_name = substring(1,30,him_roi
    ->prsnl[d1.seq].last_name), requests_processed = him_roi->prsnl[d1.seq].req_tot,
   avg_create_to_final = him_roi->prsnl[d1.seq].tat_avg
   FROM (dummyt d1  WITH seq = size(him_roi->prsnl,5))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (( $S_RANGE="SCREEN")
  AND ( $L_SUM=0))
  SELECT INTO  $OUTDEV
   first_name = substring(1,30,him_roi->prsnl[d1.seq].first_name), last_name = substring(1,30,him_roi
    ->prsnl[d1.seq].last_name), request_number = substring(1,30,him_roi->prsnl[d1.seq].request[d2.seq
    ].request),
   request_type = substring(1,30,him_roi->prsnl[d1.seq].request[d2.seq].request_type), request_reason
    = substring(1,100,him_roi->prsnl[d1.seq].request[d2.seq].request_reason), create_date = substring
   (1,30,him_roi->prsnl[d1.seq].request[d2.seq].req_dt),
   completed_date = substring(1,30,him_roi->prsnl[d1.seq].request[d2.seq].completed_dt), status =
   substring(1,30,him_roi->prsnl[d1.seq].request[d2.seq].status), complete_to_final = him_roi->prsnl[
   d1.seq].request[d2.seq].tat
   FROM (dummyt d1  WITH seq = size(him_roi->prsnl,5)),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(him_roi->prsnl[d1.seq].request,5)))
    JOIN (d2)
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (( $S_RANGE != "SCREEN"))
  IF (( $L_SUM=1))
   SET frec->file_name = ms_output_file
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"First Name",','"Last Name",','"Request Count",',
    '"Create to Final Average",',char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml1_cnt = 1 TO size(him_roi->prsnl,5))
    SET frec->file_buf = build('"',substring(1,70,him_roi->prsnl[ml1_cnt].first_name),'","',substring
     (1,70,him_roi->prsnl[ml1_cnt].last_name),'","',
     him_roi->prsnl[ml1_cnt].req_tot,'","',him_roi->prsnl[ml1_cnt].tat_avg,'"',char(13))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
  ELSEIF (( $L_SUM=0))
   SET frec->file_name = ms_output_file
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"First Name",','"Last Name",','"Request Number",','"Request Type",',
    '"Request Information-Request Reason",',
    '"Create Date",','"Completed Date",','"Create to Final",',char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml1_cnt = 1 TO size(him_roi->prsnl,5))
     FOR (ml2_cnt = 1 TO size(him_roi->prsnl[ml1_cnt].request,5))
      SET frec->file_buf = build('"',substring(1,70,him_roi->prsnl[ml1_cnt].first_name),'","',
       substring(1,70,him_roi->prsnl[ml1_cnt].last_name),'","',
       substring(1,30,him_roi->prsnl[ml1_cnt].request[ml2_cnt].request),'","',substring(1,30,him_roi
        ->prsnl[ml1_cnt].request[ml2_cnt].request_type),'","',substring(1,30,him_roi->prsnl[ml1_cnt].
        request[ml2_cnt].request_reason),
       '","',substring(1,30,him_roi->prsnl[ml1_cnt].request[ml2_cnt].req_dt),'","',substring(1,30,
        him_roi->prsnl[ml1_cnt].request[ml2_cnt].completed_dt),'","',
       him_roi->prsnl[ml1_cnt].request[ml2_cnt].tat,'"',char(13))
      SET stat = cclio("WRITE",frec)
     ENDFOR
   ENDFOR
   SET stat = cclio("CLOSE",frec)
  ENDIF
  IF (textlen(trim( $S_EMAILS,3)) > 1
   AND textlen(trim(ms_error,3))=0)
   EXECUTE bhs_ma_email_file
   SET ms_subject = build2("ROI Report ",trim(format(cnvtdatetime(ms_start_date),
      "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),"mmm-dd-yyyy hh:mm;;d"
      ),3))
   CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
     CALL print(calcpos(36,18)),
     msg1, row + 2, msg2
    WITH dio = 08, maxcol = 300
   ;end select
  ENDIF
 ENDIF
 FREE RECORD frec
#exit_script
END GO
