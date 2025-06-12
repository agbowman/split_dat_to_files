CREATE PROGRAM bhs_rpt_foley_cauti:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Days to Report" = "1",
  "Recipient email(s)" = ""
  WITH outdev, ms_days_to_report, ms_recipient_emails
 FREE RECORD request_foley
 RECORD request_foley(
   1 f_facility_cd = f8
   1 f_nurse_unit_cd = f8
   1 d_start_dt_tm = dq8
   1 d_end_dt_tm = dq8
 ) WITH protect
 FREE RECORD reply_foley
 RECORD reply_foley(
   1 c_status = c1
   1 cath_cnt = i4
   1 caths[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 encntr_id = f8
     2 fin = vc
     2 admit_dt_tm = dq8
     2 loc_nurse_unit = c40
     2 loc_when_cath_ordered = c40
     2 cath_type_str = vc
     2 cath_order_dt_tm = dq8
     2 cath_insertion_dt_tm = dq8
     2 cath_removal_dt_tm = dq8
     2 cath_remove_ind = c5
     2 cath_indication_str = vc
     2 ordering_provider_name = vc
     2 order_indication_str = vc
     2 physician_notified_name = vc
 ) WITH protect
 DECLARE mn_days_to_report = i4 WITH protect, constant(cnvtint( $MS_DAYS_TO_REPORT))
 SET reply_foley->c_status = "F"
 SET request_foley->f_facility_cd = 0
 SET request_foley->f_nurse_unit_cd = 0
 SET request_foley->d_end_dt_tm = cnvtdatetime(curdate,0)
 SET request_foley->d_start_dt_tm = datetimeadd(request_foley->d_end_dt_tm,(0 - mn_days_to_report))
 DECLARE ms_outdev = vc WITH protect, constant(trim( $OUTDEV))
 DECLARE ms_outfile = vc WITH protect, constant(concat("cauti_foley_",format(curdate,"YYYYMMDD;;D"),
   ".csv"))
 DECLARE ms_time = vc WITH protect, constant(concat(format(request_foley->d_start_dt_tm,
    "MM/DD/YY HH:MM;;D")," to ",format(request_foley->d_end_dt_tm,"MM/DD/YY HH:MM;;D")))
 DECLARE ms_header = vc WITH protect, constant(concat("CAUTI Prevention - Foley Catheter Report for ",
   ms_time))
 DECLARE mn_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE ms_timer_start = dq8 WITH protect, noconstant(sysdate)
 DECLARE ms_timer_stop = dq8 WITH protect, noconstant(sysdate)
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_email_list = vc WITH protect, noconstant(" ")
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 EXECUTE bhs_sys_stand_subroutine
 SUBROUTINE pgbreak(dummy)
   IF (mn_debug_flag > 0)
    CALL echo("Page break")
   ENDIF
   SET d0 = pagebreak(dummy)
   SET d0 = headpagesection(rpt_render)
   SET d0 = columnheadersection(rpt_render)
 END ;Subroutine
 IF (mn_debug_flag > 0)
  SET ms_email_list = "Vitaliy.Kiriukhin@bhs.org"
 ELSEIF (( $MS_RECIPIENT_EMAILS="OPS"))
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_FOLEY_CAUTI"
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt = (ml_cnt+ 1)
    IF (ml_cnt=1)
     ms_email_list = trim(di.info_name)
    ELSE
     ms_email_list = concat(ms_email_list,", ",trim(di.info_name))
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (textlen(trim( $MS_RECIPIENT_EMAILS,3)) > 0)
  SET ms_email_list = trim( $MS_RECIPIENT_EMAILS,3)
 ELSE
  SET ms_error = concat(ms_error,"Please input an email. ")
  GO TO exit_script
 ENDIF
 IF (textlen(ms_email_list) > 0
  AND findstring("@",ms_email_list)=0)
  SET ms_error = concat(ms_error,"Invalid email recipients list. ")
  GO TO exit_script
 ENDIF
 EXECUTE bhs_foley_audit
 IF ((reply_foley->c_status="F"))
  SET ms_error = concat(ms_error,"Bhs_rpt_foley_audit did not return success status. ")
  GO TO exit_script
 ENDIF
 SET reply_foley->c_status = "F"
 SELECT INTO value(ms_outfile)
  FROM (dummyt d  WITH seq = reply_foley->cath_cnt)
  ORDER BY reply_foley->caths[d.seq].name_full_formatted, reply_foley->caths[d.seq].admit_dt_tm
  HEAD REPORT
   row 0, col 0, ms_header,
   ms_line = concat(
    '"Patient Location","Patient Name","Account Number","Admit Date/Time","Patient Location when Order Placed"',
    ',"Urinary Catheter Order Date/Time","Type of Urinary Catheter","Ordering Provider","Order Indication"',
    ',"Insert Catheter Date/Time","Indication for Urinary Catheter","Remove Catheter","Remove Catheter Date/Time"',
    ',"Physician Notified of Removal"'), row + 1, col 0,
   ms_line
  DETAIL
   ms_line = build('"',reply_foley->caths[d.seq].loc_nurse_unit,'"',",",'"',
    reply_foley->caths[d.seq].name_full_formatted,'"',",",'"',reply_foley->caths[d.seq].fin,
    '"',",",format(reply_foley->caths[d.seq].admit_dt_tm,"MM/DD/YY HH:MM:SS;;D"),",",'"',
    reply_foley->caths[d.seq].loc_when_cath_ordered,'"',",",format(reply_foley->caths[d.seq].
     cath_order_dt_tm,"MM/DD/YY HH:MM:SS;;D"),",",
    '"',reply_foley->caths[d.seq].cath_type_str,'"',",",'"',
    reply_foley->caths[d.seq].ordering_provider_name,'"',",",'"',reply_foley->caths[d.seq].
    order_indication_str,
    '"',",",format(reply_foley->caths[d.seq].cath_insertion_dt_tm,"MM/DD/YY HH:MM:SS;;D"),",",'"',
    reply_foley->caths[d.seq].cath_indication_str,'"',",",'"',reply_foley->caths[d.seq].
    cath_remove_ind,
    '"',",",format(reply_foley->caths[d.seq].cath_removal_dt_tm,"MM/DD/YY HH:MM:SS;;D"),",",'"',
    reply_foley->caths[d.seq].physician_notified_name,'"'), row + 1, col 0,
   ms_line
  FOOT REPORT
   row + 0
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 2000, maxrow = 1
 ;end select
 CALL emailfile(ms_outfile,ms_outfile,ms_email_list,ms_header,1)
 SET ms_timer_stop = sysdate
 SELECT INTO value(ms_outdev)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row 0, col 0, "The CAUTI Prevention - Foley Catheter Report was created.",
   ms_line = concat("Days reported:          ",cnvtstring(mn_days_to_report)), row + 1, col 0,
   ms_line, ms_line = concat("Data time range start:  ",format(request_foley->d_start_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D")), row + 1,
   col 0, ms_line, ms_line = concat("Data time range end:    ",format(request_foley->d_end_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D")),
   row + 1, col 0, ms_line,
   ms_line = concat("Output file:            ",ms_outfile), row + 1, col 0,
   ms_line, ms_line = concat("Emailed to:             ",ms_email_list), row + 1,
   col 0, ms_line, ms_line = concat("Records:                ",cnvtstring(size(reply_foley->caths,5))
    ),
   row + 1, col 0, ms_line,
   ms_line = concat("Processing start time:  ",format(ms_timer_start,"DD-MMM-YYYY HH:MM:SS;;D")), row
    + 1, col 0,
   ms_line, ms_line = concat("Processing end time:    ",format(ms_timer_stop,
     "DD-MMM-YYYY HH:MM:SS;;D")), row + 1,
   col 0, ms_line, ms_line = concat("Processing time:        ",trim(cnvtstring(datetimediff(
       ms_timer_stop,ms_timer_start,4)),3)," minutes"),
   row + 1, col 0, ms_line,
   ms_line = concat("Debug flag:             ",cnvtstring(mn_debug_flag)), row + 1, col 0,
   ms_line
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 3000, maxrow = 1
 ;end select
 SET reply_foley->c_status = "S"
#exit_script
 IF ((reply_foley->c_status != "S"))
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", "{F/1}{CPI/7}",
    CALL print(calcpos(10,10)), "CAUTI Prevention - Foley Catheter Report", "{F/1}{CPI/14}",
    CALL print(calcpos(10,30)), ms_error
   WITH dio = postscript, maxrow = 300, maxcol = 300
  ;end select
 ENDIF
END GO
