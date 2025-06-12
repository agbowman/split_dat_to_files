CREATE PROGRAM bhs_rpt_roi_req_productivity:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Select Personnel" = value(0.0),
  "Select Request Status" = value(4198.00),
  "Enter Emails" = "",
  "Date Range" = ""
  WITH outdev, s_start_date, s_end_date,
  f_prsnl, f_status, s_emails,
  s_range
 DECLARE mf_bhsmradministrator = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSMRADMINISTRATOR")), protect
 DECLARE mf_bhsmrwmerge = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSMRWMERGE")), protect
 DECLARE mf_bhsmrwomerge = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSMRWOMERGE")), protect
 DECLARE mf_bhsmrmanagement = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSMRMANAGEMENT")),
 protect
 DECLARE cnt_wks = i4 WITH noconstant(0), protect
 DECLARE cnt_preq = i4 WITH noconstant(0), protect
 DECLARE cnt_prsnl = i4 WITH noconstant(0), protect
 DECLARE cnt_inv = i4 WITH noconstant(0), protect
 DECLARE cnt_wk = i4 WITH protect
 DECLARE processing_var = f8 WITH constant(uar_get_code_by("MEANING",14172,"PROCESSING")), protect
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE ms_week1end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE ml1_cnt = i4 WITH noconstant(0), protect
 DECLARE ml2_cnt = i4 WITH noconstant(0), protect
 DECLARE ml3_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_opr_var2 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_filename = vc WITH noconstant("bhs_roi_audit"), protect
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
   1 l_cnt_him = i4
   1 cnt_wks = i4
   1 total_charges = f8
   1 total_paid = f8
   1 total_balance = f8
   1 total_invoices = i4
   1 weeks[*]
     2 wk_of = vc
     2 wk_tot_chgs = f8
     2 cnt_prsnl = i4
     2 prsnl[*]
       3 first_name = vc
       3 last_name = vc
       3 inv_tot = i4
       3 pr_tot_chgs = f8
       3 pr_tot_paid = f8
       3 invoice[*]
         4 req_dt = vc
         4 payer = vc
         4 inv_charge = f8
         4 inv_balance = f8
         4 invoice = vc
         4 paid = f8
         4 status = vc
   1 him_prsl[*]
     2 cnt_i = i4
     2 inv[*]
       3 wkof = cv
 )
 SELECT INTO "nl:"
  week_of = format(datetimefind(hr.request_status_dt_tm,"W","B","B"),"YYYY/MM/DD;;D")
  FROM him_request hr,
   roi_request rr,
   roi_invoice ri,
   requester r,
   organization o,
   prsnl usr
  PLAN (hr
   WHERE operator(hr.request_status_cd,ms_opr_var2, $F_STATUS)
    AND hr.request_status_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959))
   JOIN (rr
   WHERE rr.him_request_id=hr.him_request_id)
   JOIN (ri
   WHERE (ri.request_id= Outerjoin(rr.him_request_id))
    AND (ri.active_ind= Outerjoin(1)) )
   JOIN (usr
   WHERE usr.person_id=hr.request_status_prsnl_id
    AND usr.position_cd IN (mf_bhsmrwomerge, mf_bhsmrmanagement, mf_bhsmrwmerge,
   mf_bhsmradministrator)
    AND operator(usr.person_id,ms_opr_var1, $F_PRSNL))
   JOIN (r
   WHERE r.requester_id=hr.roi_requester_id)
   JOIN (o
   WHERE o.organization_id=hr.organization_id)
  ORDER BY week_of, usr.name_last, usr.name_first,
   hr.request_status_prsnl_id, hr.request_dt_tm
  HEAD REPORT
   stat = alterlist(him_roi->weeks,10)
  HEAD week_of
   cnt_wks += 1, him_roi->cnt_wks = cnt_wks
   IF (mod(cnt_wks,10)=1
    AND cnt_wks > 1)
    stat = alterlist(him_roi->weeks,(cnt_wks+ 9))
   ENDIF
   him_roi->weeks[cnt_wks].wk_of = trim(week_of,3), stat = alterlist(him_roi->weeks[cnt_wks].prsnl,10
    )
  HEAD hr.request_status_prsnl_id
   cnt_prsnl += 1, him_roi->weeks[cnt_wks].cnt_prsnl = cnt_prsnl
   IF (mod(cnt_prsnl,10)=1
    AND cnt_prsnl > 1)
    stat = alterlist(him_roi->weeks[cnt_wks].prsnl,(cnt_prsnl+ 9))
   ENDIF
   him_roi->weeks[cnt_wks].prsnl[cnt_prsnl].last_name = trim(usr.name_last,3), him_roi->weeks[cnt_wks
   ].prsnl[cnt_prsnl].first_name = trim(usr.name_first,3), stat = alterlist(him_roi->weeks[cnt_wks].
    prsnl[cnt_prsnl].invoice,10)
  DETAIL
   cnt_inv += 1
   IF (mod(cnt_inv,10)=1
    AND cnt_inv > 1)
    stat = alterlist(him_roi->weeks[cnt_wks].prsnl[cnt_prsnl].invoice,(cnt_inv+ 9))
   ENDIF
   him_roi->weeks[cnt_wks].prsnl[cnt_prsnl].invoice[cnt_inv].payer = substring(1,100,r.name_last),
   him_roi->weeks[cnt_wks].prsnl[cnt_prsnl].invoice[cnt_inv].inv_charge = ri.total_charges, him_roi->
   weeks[cnt_wks].prsnl[cnt_prsnl].invoice[cnt_inv].inv_balance = ri.balance,
   him_roi->weeks[cnt_wks].prsnl[cnt_prsnl].invoice[cnt_inv].paid = ri.total_paid, him_roi->weeks[
   cnt_wks].prsnl[cnt_prsnl].invoice[cnt_inv].invoice = cnvtstring(hr.request_number), him_roi->
   weeks[cnt_wks].prsnl[cnt_prsnl].invoice[cnt_inv].req_dt = format(hr.request_dt_tm,"mm/dd/yyyy;;D"),
   him_roi->weeks[cnt_wks].prsnl[cnt_prsnl].inv_tot = cnt_inv, him_roi->weeks[cnt_wks].prsnl[
   cnt_prsnl].invoice[cnt_inv].status = uar_get_code_display(hr.request_status_cd), him_roi->weeks[
   cnt_wks].prsnl[cnt_prsnl].pr_tot_paid += ri.total_paid,
   him_roi->weeks[cnt_wks].prsnl[cnt_prsnl].pr_tot_chgs += ri.total_charges, him_roi->weeks[cnt_wks].
   wk_tot_chgs += ri.total_charges, him_roi->total_charges += ri.total_charges,
   him_roi->total_balance += ri.balance, him_roi->total_paid += ri.total_paid, him_roi->
   total_invoices += 1
  FOOT  hr.request_status_prsnl_id
   stat = alterlist(him_roi->weeks[cnt_wks].prsnl[cnt_prsnl].invoice,cnt_inv), cnt_inv = 0
  FOOT  week_of
   stat = alterlist(him_roi->weeks[cnt_wks].prsnl,cnt_prsnl), cnt_prsnl = 0
  FOOT REPORT
   stat = alterlist(him_roi->weeks,cnt_wks), cnt_wks = 0
  WITH nocounter, format, separator = " "
 ;end select
 IF (( $S_RANGE="SCREEN"))
  SELECT INTO  $OUTDEV
   week_of = substring(1,30,him_roi->weeks[d1.seq].wk_of), first_name = substring(1,30,him_roi->
    weeks[d1.seq].prsnl[d2.seq].first_name), last_name = substring(1,30,him_roi->weeks[d1.seq].prsnl[
    d2.seq].last_name),
   invoice_number = him_roi->weeks[d1.seq].prsnl[d2.seq].invoice[d3.seq].invoice, create_date =
   substring(1,30,him_roi->weeks[d1.seq].prsnl[d2.seq].invoice[d3.seq].req_dt), payer = substring(1,
    30,him_roi->weeks[d1.seq].prsnl[d2.seq].invoice[d3.seq].payer),
   invoice_charge = him_roi->weeks[d1.seq].prsnl[d2.seq].invoice[d3.seq].inv_charge, invoice_paid =
   him_roi->weeks[d1.seq].prsnl[d2.seq].invoice[d3.seq].paid, invoice_inv_balance = him_roi->weeks[d1
   .seq].prsnl[d2.seq].invoice[d3.seq].inv_balance,
   invoice_status = substring(1,30,him_roi->weeks[d1.seq].prsnl[d2.seq].invoice[d3.seq].status),
   total_weekly_charges_per_personnel = him_roi->weeks[d1.seq].prsnl[d2.seq].pr_tot_chgs,
   total_weekly_paid_per_personnel = him_roi->weeks[d1.seq].prsnl[d2.seq].pr_tot_paid,
   number_invoices_per_personnel = him_roi->weeks[d1.seq].prsnl[d2.seq].inv_tot, weeks_total_charges
    = him_roi->weeks[d1.seq].wk_tot_chgs, weeks_total_paid = him_roi->weeks[d1.seq].prsnl[d2.seq].
   pr_tot_paid,
   report_total_charges = him_roi->total_charges, report_total_paid = him_roi->total_paid,
   report_total_balance = him_roi->total_balance,
   report_total_number_of_invoices = him_roi->total_invoices
   FROM (dummyt d1  WITH seq = size(him_roi->weeks,5)),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(him_roi->weeks[d1.seq].prsnl,5)))
    JOIN (d2
    WHERE maxrec(d3,size(him_roi->weeks[d1.seq].prsnl[d2.seq].invoice,5)))
    JOIN (d3)
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (( $S_RANGE != "SCREEN"))
  IF (textlen(trim( $S_EMAILS,3)) > 1
   AND textlen(trim(ms_error,3))=0)
   SET frec->file_name = ms_output_file
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"Week Of",','"First Name",','"Last Name",','"Invoice Number",',
    '"Create Date",',
    '"Payer",','"Invoice Charge",','"Invoice Paid",','"Invoice Inv Balance",','"Invoice Status",',
    '"Total Weekly Charges Pe Personnel",','"Total Weekly Paid Per Personnel",',
    '"Number Invoices Per Personnel",','"Week Total Charges",','"Week Total Paid",',
    '"Report Total Charges",','"Report Total Paid",','"Report Total Balance",',
    '"Report Total Number Of Invoices",',char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml1_cnt = 1 TO size(him_roi->weeks,5))
     FOR (ml2_cnt = 1 TO size(him_roi->weeks[ml1_cnt].prsnl,5))
       FOR (ml3_cnt = 1 TO size(him_roi->weeks[ml1_cnt].prsnl[ml2_cnt].invoice,5))
        SET frec->file_buf = build('"',substring(1,30,him_roi->weeks[ml1_cnt].wk_of),'","',substring(
          1,30,him_roi->weeks[ml1_cnt].prsnl[ml2_cnt].first_name),'","',
         substring(1,30,him_roi->weeks[ml1_cnt].prsnl[ml2_cnt].last_name),'","',him_roi->weeks[
         ml1_cnt].prsnl[ml2_cnt].invoice[ml3_cnt].invoice,'","',substring(1,30,him_roi->weeks[ml1_cnt
          ].prsnl[ml2_cnt].invoice[ml3_cnt].req_dt),
         '","',substring(1,30,him_roi->weeks[ml1_cnt].prsnl[ml2_cnt].invoice[ml3_cnt].payer),'","',
         him_roi->weeks[ml1_cnt].prsnl[ml2_cnt].invoice[ml3_cnt].inv_charge,'","',
         him_roi->weeks[ml1_cnt].prsnl[ml2_cnt].invoice[ml3_cnt].paid,'","',him_roi->weeks[ml1_cnt].
         prsnl[ml2_cnt].invoice[ml3_cnt].inv_balance,'","',substring(1,30,him_roi->weeks[ml1_cnt].
          prsnl[ml2_cnt].invoice[ml3_cnt].status),
         '","',him_roi->weeks[ml1_cnt].prsnl[ml2_cnt].pr_tot_chgs,'","',him_roi->weeks[ml1_cnt].
         prsnl[ml2_cnt].pr_tot_paid,'","',
         him_roi->weeks[ml1_cnt].prsnl[ml2_cnt].inv_tot,'","',him_roi->weeks[ml1_cnt].wk_tot_chgs,
         '","',him_roi->weeks[ml1_cnt].prsnl[ml2_cnt].pr_tot_paid,
         '","',him_roi->total_charges,'","',him_roi->total_paid,'","',
         him_roi->total_balance,'","',him_roi->total_invoices,'"',char(13))
        SET stat = cclio("WRITE",frec)
       ENDFOR
     ENDFOR
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   EXECUTE bhs_ma_email_file
   SET ms_subject = build2("ROI Audit Report ",trim(format(cnvtdatetime(ms_start_date),
      "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),"mmm-dd-yyyy hh:mm;;d"
      ),3))
   CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
   SELECT INTO value( $OUTDEV)
    FROM dummyt d
    HEAD REPORT
     msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
     CALL print(calcpos(36,18)),
     msg1, row + 2, msg2
    WITH dio = 08
   ;end select
  ENDIF
 ENDIF
 FREE RECORD frec
#exit_script
END GO
