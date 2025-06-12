CREATE PROGRAM bsc_rpt_poc_utilization_lc:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date:" = "CURDATE",
  "Ending date:" = "CURDATE",
  "Facility:" = 673936.00,
  "Nurse unit(s):" = value(*),
  "Display per:" = 0
  WITH out_dev, start_date, end_date,
  facility, nurse_unit, display_type
 SET modify = predeclare
 DECLARE ndisplayperuser = i2 WITH protect, constant(0)
 DECLARE ndisplayperday = i2 WITH protect, constant(1)
 DECLARE ctitle = vc WITH protect, constant("Point of Care Utilization")
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(79,"-"))
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lmaecnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalmaecnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalptidcnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalmedidcnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalaacnt = i4 WITH protect, noconstant(0)
 DECLARE dpercent = f8 WITH protect, noconstant(0.0)
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE ltotalnotdonecnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalnotgivencnt = i4 WITH protect, noconstant(0)
 FREE RECORD aunit
 RECORD aunit(
   1 l_cnt = i4
   1 list[*]
     2 s_unit_display_key = vc
 ) WITH protect
 FREE RECORD audit_request
 SET modify = nopredeclare
 EXECUTE bsc_get_audit_info_rr
 SET modify = predeclare
 SET audit_request->report_name = "BSC_RPT_POC_UTILIZATION"
 SET audit_request->start_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $START_DATE)),0)
 SET audit_request->end_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $END_DATE)),235959)
 SET audit_request->facility_cd =  $FACILITY
 SELECT INTO "nl:"
  FROM dm_info au
  WHERE au.info_domain="BHS_AMBULATORY_UNIT"
  HEAD REPORT
   aunit->l_cnt = 0
  DETAIL
   aunit->l_cnt = (aunit->l_cnt+ 1), stat = alterlist(aunit->list,aunit->l_cnt), aunit->list[aunit->
   l_cnt].s_unit_display_key = au.info_name
  WITH nocounter
 ;end select
 IF (substring(1,1,reflect(parameter(5,0)))="I")
  IF (( $NURSE_UNIT=0))
   SET nallind = 1
  ENDIF
 ELSEIF (substring(1,1,reflect(parameter(5,0)))="C")
  IF (( $NURSE_UNIT="*"))
   SET nallind = 1
  ENDIF
 ENDIF
 IF (nallind=1)
  SELECT INTO "nl:"
   FROM code_value cv,
    location_group lg1,
    location_group lg2
   PLAN (cv
    WHERE cv.code_set=220
     AND ((cv.cdf_meaning="NURSEUNIT") OR (cv.cdf_meaning="AMBULATORY"
     AND expand(ml_cnt,1,aunit->l_cnt,cv.display_key,aunit->list[ml_cnt].s_unit_display_key)))
     AND cv.active_ind=1
     AND cv.data_status_cd=25.0)
    JOIN (lg1
    WHERE lg1.child_loc_cd=cv.code_value
     AND lg1.root_loc_cd=0)
    JOIN (lg2
    WHERE lg2.child_loc_cd=lg1.parent_loc_cd
     AND lg2.root_loc_cd=0
     AND (lg2.parent_loc_cd= $FACILITY))
   ORDER BY cv.display
   HEAD REPORT
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     CALL alterlist(audit_request->unit,(lcnt+ 9))
    ENDIF
    audit_request->unit[lcnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    CALL alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_value IN ( $NURSE_UNIT))
   ORDER BY cv.display
   HEAD REPORT
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     CALL alterlist(audit_request->unit,(lcnt+ 9))
    ENDIF
    audit_request->unit[lcnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    CALL alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
   WITH nocounter
  ;end select
 ENDIF
 SET audit_request->display_ind =  $DISPLAY_TYPE
 SET modify = nopredeclare
 EXECUTE bsc_get_audit_info
 SET modify = predeclare
 IF ((audit_reply->status_data.status="S")
  AND (audit_reply->summary_qual_cnt > 0))
  IF ((audit_request->display_ind=ndisplayperuser))
   SELECT INTO  $OUT_DEV
    name = audit_reply->summary_qual[d.seq].name_full_formatted
    FROM (dummyt d  WITH seq = value(audit_reply->summary_qual_cnt))
    ORDER BY name
    HEAD PAGE
     IF (( $OUT_DEV != "MINE"))
      col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
     ENDIF
     col 00, "Date Range: ", sdisplay = ""
     IF ((audit_request->start_dt_tm > 0))
      sdisplay = format(audit_request->start_dt_tm,"MM/DD/YYYY;;D")
     ENDIF
     IF ((audit_request->end_dt_tm > 0))
      sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"MM/DD/YYYY;;D"))
     ENDIF
     IF (textlen(sdisplay) > 0)
      col 12, sdisplay
     ENDIF
     col 122, "Page: ", curpage"###",
     row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $FACILITY),3)), col 00,
     sdisplay, col 96, "Run Date: ",
     curdate"MM/DD/YYYY;;D", " Time: ", curtime"HH:MM;;S",
     row + 1, sdisplay = ""
     IF (nallind=1)
      sdisplay = "Nurse Units: All"
     ELSEIF ((audit_request->unit_cnt > 1))
      sdisplay = concat("Nurse Units: ",trim(uar_get_code_display(audit_request->unit[1].
         nurse_unit_cd),3))
      FOR (lcnt = 2 TO audit_request->unit_cnt)
        sdisplay = concat(sdisplay,", ",trim(uar_get_code_display(audit_request->unit[lcnt].
           nurse_unit_cd),3))
      ENDFOR
     ELSEIF ((audit_request->unit_cnt=1))
      sdisplay = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd
         ),3))
     ELSE
      sdisplay = "Nurse Unit:"
     ENDIF
     col 00, sdisplay
     IF (nallind=0
      AND (audit_request->unit_cnt > 1))
      row + 1
     ENDIF
     CALL center(ctitle,1,131), row + 1, col 00,
     cdashline, row + 1, col 00,
     "Legend", col 07,
     "(MAE = administered Med Admin Events, ID = where barcode used to identify, Pt = Patient, AA = where Audit Alert)",
     row + 2, col 30, "Total #",
     col 41, "# of MAE", col 53,
     "% of MAE", col 65, "# of MAE",
     col 77, "% of MAE", col 89,
     "# of MAE", col 101, "% of MAE",
     row + 1, col 00, "User",
     col 30, "of MAE", col 41,
     "  ID Pt", col 53, "  ID Pt",
     col 65, " ID Med", col 77,
     " ID Med", col 89, "AA fired",
     col 101, "AA fired", row + 2
    HEAD name
     ltotalmaecnt = (ltotalmaecnt+ audit_reply->summary_qual[d.seq].med_admin_event_cnt),
     ltotalptidcnt = (ltotalptidcnt+ audit_reply->summary_qual[d.seq].positive_pat_cnt),
     ltotalmedidcnt = (ltotalmedidcnt+ audit_reply->summary_qual[d.seq].positive_med_cnt),
     ltotalaacnt = (ltotalaacnt+ audit_reply->summary_qual[d.seq].mae_alert_cnt), ltotalnotdonecnt =
     (ltotalnotdonecnt+ audit_reply->summary_qual[d.seq].total_not_done_cnt), ltotalnotgivencnt = (
     ltotalnotgivencnt+ audit_reply->summary_qual[d.seq].total_not_given_cnt),
     col 00, audit_reply->summary_qual[d.seq].name_full_formatted, lmaecnt = audit_reply->
     summary_qual[d.seq].med_admin_event_cnt,
     sdisplay = format(lmaecnt,"#####"), col 30, sdisplay,
     sdisplay = format(audit_reply->summary_qual[d.seq].positive_pat_cnt,"#####"), col 42, sdisplay,
     dpercent = ((cnvtreal(audit_reply->summary_qual[d.seq].positive_pat_cnt)/ lmaecnt) * 100),
     sdisplay = format(dpercent,"###"), col 56,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].positive_med_cnt,"#####"), col 66,
     sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual[d.seq].positive_med_cnt)/ lmaecnt) *
     100), sdisplay = format(dpercent,"###"),
     col 80, sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].mae_alert_cnt,"#####"),
     col 90, sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual[d.seq].mae_alert_cnt)/ lmaecnt
     ) * 100),
     sdisplay = format(dpercent,"###"), col 104, sdisplay,
     row + 1
    FOOT REPORT
     col 30, ctotal_line, row + 1,
     col 00, "Total", sdisplay = format(ltotalmaecnt,"######"),
     col 29, sdisplay, sdisplay = format(ltotalptidcnt,"######"),
     col 41, sdisplay, dpercent = ((cnvtreal(ltotalptidcnt)/ ltotalmaecnt) * 100),
     sdisplay = format(dpercent,"###"), col 56, sdisplay,
     sdisplay = format(ltotalmedidcnt,"######"), col 65, sdisplay,
     dpercent = ((cnvtreal(ltotalmedidcnt)/ ltotalmaecnt) * 100), sdisplay = format(dpercent,"###"),
     col 80,
     sdisplay, sdisplay = format(ltotalaacnt,"######"), col 89,
     sdisplay, dpercent = ((cnvtreal(ltotalaacnt)/ ltotalmaecnt) * 100), sdisplay = format(dpercent,
      "###"),
     col 104, sdisplay, row + 1,
     col 00, "Total Not Done:", sdisplay = format(ltotalnotdonecnt,"######"),
     col 17, sdisplay, row + 1,
     col 00, "Total Not Given:", sdisplay = format(ltotalnotgivencnt,"######"),
     col 17, sdisplay, row + 2,
     sdisplay = build2("***** End of Report *****"),
     CALL center(sdisplay,1,131)
    WITH dio = postscript, maxrow = 45
   ;end select
  ELSEIF ((audit_request->display_ind=ndisplayperday))
   SELECT INTO  $OUT_DEV
    int_date = audit_reply->summary_qual[d.seq].internal_date
    FROM (dummyt d  WITH seq = value(audit_reply->summary_qual_cnt))
    ORDER BY int_date
    HEAD PAGE
     IF (( $OUT_DEV != "MINE"))
      col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
     ENDIF
     col 00, "Date Range: ", sdisplay = ""
     IF ((audit_request->start_dt_tm > 0))
      sdisplay = format(audit_request->start_dt_tm,"MM/DD/YYYY;;D")
     ENDIF
     IF ((audit_request->end_dt_tm > 0))
      sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"MM/DD/YYYY;;D"))
     ENDIF
     IF (textlen(sdisplay) > 0)
      col 12, sdisplay
     ENDIF
     col 122, "Page: ", curpage"###",
     row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $FACILITY),3)), col 00,
     sdisplay, col 96, "Run Date: ",
     curdate"MM/DD/YYYY;;D", " Time: ", curtime"HH:MM;;S",
     row + 1, sdisplay = ""
     IF (nallind=1)
      sdisplay = "Nurse Units: All"
     ELSEIF ((audit_request->unit_cnt > 1))
      sdisplay = concat("Nurse Units: ",trim(uar_get_code_display(audit_request->unit[1].
         nurse_unit_cd),3))
      FOR (lcnt = 2 TO audit_request->unit_cnt)
        sdisplay = concat(sdisplay,", ",trim(uar_get_code_display(audit_request->unit[lcnt].
           nurse_unit_cd),3))
      ENDFOR
     ELSEIF ((audit_request->unit_cnt=1))
      sdisplay = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd
         ),3))
     ELSE
      sdisplay = "Nurse Unit:"
     ENDIF
     col 00, sdisplay
     IF (nallind=0
      AND (audit_request->unit_cnt > 1))
      row + 1
     ENDIF
     CALL center(ctitle,1,131), row + 1, col 00,
     cdashline, row + 1, col 00,
     "Legend", col 07,
     "(MAE = administered Med Admin Events, ID = where barcode used to identify, Pt = Patient, AA = where Audit Alert)",
     row + 2, col 30, "Total #",
     col 41, "# of MAE", col 53,
     "% of MAE", col 65, "# of MAE",
     col 77, "% of MAE", col 89,
     "# of MAE", col 101, "% of MAE",
     row + 1, col 00, "Day",
     col 30, "of MAE", col 41,
     "  ID Pt", col 53, "  ID Pt",
     col 65, " ID Med", col 77,
     " ID Med", col 89, "AA fired",
     col 101, "AA fired", row + 2
    HEAD int_date
     ltotalmaecnt = (ltotalmaecnt+ audit_reply->summary_qual[d.seq].med_admin_event_cnt),
     ltotalptidcnt = (ltotalptidcnt+ audit_reply->summary_qual[d.seq].positive_pat_cnt),
     ltotalmedidcnt = (ltotalmedidcnt+ audit_reply->summary_qual[d.seq].positive_med_cnt),
     ltotalaacnt = (ltotalaacnt+ audit_reply->summary_qual[d.seq].mae_alert_cnt), ltotalnotdonecnt =
     (ltotalnotdonecnt+ audit_reply->summary_qual[d.seq].total_not_done_cnt), ltotalnotgivencnt = (
     ltotalnotgivencnt+ audit_reply->summary_qual[d.seq].total_not_given_cnt),
     col 00, audit_reply->summary_qual[d.seq].date_string, lmaecnt = audit_reply->summary_qual[d.seq]
     .med_admin_event_cnt,
     sdisplay = format(lmaecnt,"#####"), col 30, sdisplay,
     sdisplay = format(audit_reply->summary_qual[d.seq].positive_pat_cnt,"#####"), col 42, sdisplay,
     dpercent = ((cnvtreal(audit_reply->summary_qual[d.seq].positive_pat_cnt)/ lmaecnt) * 100),
     sdisplay = format(dpercent,"###"), col 56,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].positive_med_cnt,"#####"), col 66,
     sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual[d.seq].positive_med_cnt)/ lmaecnt) *
     100), sdisplay = format(dpercent,"###"),
     col 80, sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].mae_alert_cnt,"#####"),
     col 90, sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual[d.seq].mae_alert_cnt)/ lmaecnt
     ) * 100),
     sdisplay = format(dpercent,"###"), col 104, sdisplay,
     row + 1
    FOOT REPORT
     col 30, ctotal_line, row + 1,
     col 00, "Total", sdisplay = format(ltotalmaecnt,"######"),
     col 29, sdisplay, sdisplay = format(ltotalptidcnt,"######"),
     col 41, sdisplay, dpercent = ((cnvtreal(ltotalptidcnt)/ ltotalmaecnt) * 100),
     sdisplay = format(dpercent,"###"), col 56, sdisplay,
     sdisplay = format(ltotalmedidcnt,"######"), col 65, sdisplay,
     dpercent = ((cnvtreal(ltotalmedidcnt)/ ltotalmaecnt) * 100), sdisplay = format(dpercent,"###"),
     col 80,
     sdisplay, sdisplay = format(ltotalaacnt,"######"), col 89,
     sdisplay, dpercent = ((cnvtreal(ltotalaacnt)/ ltotalmaecnt) * 100), sdisplay = format(dpercent,
      "###"),
     col 104, sdisplay, row + 1,
     col 00, "Total Not Done:", sdisplay = format(ltotalnotdonecnt,"######"),
     col 17, sdisplay, row + 1,
     col 00, "Total Not Given:", sdisplay = format(ltotalnotgivencnt,"######"),
     col 17, sdisplay, row + 2,
     sdisplay = build2("***** End of Report *****"),
     CALL center(sdisplay,1,131)
    WITH dio = postscript, maxrow = 45
   ;end select
  ENDIF
 ELSE
  SELECT INTO  $OUT_DEV
   FROM (dummyt d  WITH seq = 1)
   ORDER BY d.seq
   HEAD PAGE
    IF (( $OUT_DEV != "MINE"))
     col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
    ENDIF
    col 00, "Date Range: ", sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"MM/DD/YYYY;;D")
    ENDIF
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"MM/DD/YYYY;;D"))
    ENDIF
    IF (textlen(sdisplay) > 0)
     col 12, sdisplay
    ENDIF
    col 122, "Page: ", curpage"###",
    row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $FACILITY),3)), col 00,
    sdisplay, col 96, "Run Date: ",
    curdate"MM/DD/YYYY;;D", " Time: ", curtime"HH:MM;;S",
    row + 1, sdisplay = ""
    IF (nallind=1)
     sdisplay = "Nurse Units: All"
    ELSEIF ((audit_request->unit_cnt > 1))
     sdisplay = concat("Nurse Units: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd
        ),3))
     FOR (lcnt = 2 TO audit_request->unit_cnt)
       sdisplay = concat(sdisplay,", ",trim(uar_get_code_display(audit_request->unit[lcnt].
          nurse_unit_cd),3))
     ENDFOR
    ELSEIF ((audit_request->unit_cnt=1))
     sdisplay = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd),
       3))
    ELSE
     sdisplay = "Nurse Unit:"
    ENDIF
    col 00, sdisplay
    IF (nallind=0
     AND (audit_request->unit_cnt > 1))
     row + 1
    ENDIF
    CALL center(ctitle,1,131), row + 1, col 00,
    cdashline, row + 2,
    CALL center("***** No Results Qualified *****",1,131)
   WITH dio = postscript
  ;end select
 ENDIF
 SET last_mod = "003"
 SET mod_date = "01/31/2017"
 SET modify = nopredeclare
END GO
