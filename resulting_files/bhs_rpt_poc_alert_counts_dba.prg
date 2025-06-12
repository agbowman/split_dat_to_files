CREATE PROGRAM bhs_rpt_poc_alert_counts:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Begin date:" = "CURDATE",
  "End date:" = "CURDATE",
  "Facility:" = 673936.00,
  "Nurse unit(s):" = value(*),
  "Display per:" = 1
  WITH outdev, ms_start_dt, ms_end_dt,
  mf_facility, mf_nurse_unit, mf_display_type
 DECLARE ms_start_dt_tm = vc WITH protect, constant(concat(trim( $MS_START_DT)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $MS_END_DT)," 23:59:59"))
 DECLARE ctitle = vc WITH protect, constant("Point of Care Audit Alert Numbers")
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(111,"-"))
 DECLARE ndisplayperuser = i2 WITH protect, constant(0)
 DECLARE ndisplayperday = i2 WITH protect, constant(1)
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE dpercent = f8 WITH protect, noconstant(0.0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lmaecnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalmaecnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalaacnt = i4 WITH protect, noconstant(0)
 DECLARE lpatmismatchcnt = i4 WITH protect, noconstant(0)
 DECLARE loverdosecnt = i4 WITH protect, noconstant(0)
 DECLARE lunderdosecnt = i4 WITH protect, noconstant(0)
 DECLARE lincdrugformcnt = i4 WITH protect, noconstant(0)
 DECLARE lincformroutecnt = i4 WITH protect, noconstant(0)
 DECLARE ltasknotfoundcnt = i4 WITH protect, noconstant(0)
 DECLARE lexpiredmedcnt = i4 WITH protect, noconstant(0)
 DECLARE learlylatecnt = i4 WITH protect, noconstant(0)
 DECLARE lintovercnt = i4 WITH protect, noconstant(0)
 DECLARE lintwarncnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE nallind = i2 WITH protect, noconstant(0)
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
 SET audit_request->report_name = "BSC_RPT_POC_ALERT_COUNTS"
 SET audit_request->start_dt_tm = cnvtdatetime(ms_start_dt_tm)
 SET audit_request->end_dt_tm = cnvtdatetime(ms_end_dt_tm)
 SET audit_request->display_ind =  $MF_DISPLAY_TYPE
 SET audit_request->facility_cd =  $MF_FACILITY
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
  IF (( $MF_NURSE_UNIT=0))
   SET nallind = 1
  ENDIF
 ELSEIF (substring(1,1,reflect(parameter(5,0)))="C")
  IF (( $MF_NURSE_UNIT="*"))
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
     AND cv.active_ind=1
     AND ((cv.cdf_meaning="NURSEUNIT") OR (cv.cdf_meaning="AMBULATORY"
     AND expand(ml_cnt,1,aunit->l_cnt,cv.display_key,aunit->list[ml_cnt].s_unit_display_key))) )
    JOIN (lg1
    WHERE lg1.child_loc_cd=cv.code_value
     AND lg1.root_loc_cd=0)
    JOIN (lg2
    WHERE lg2.child_loc_cd=lg1.parent_loc_cd
     AND lg2.root_loc_cd=0
     AND (lg2.parent_loc_cd= $MF_FACILITY))
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
    WHERE cv.code_value IN ( $MF_NURSE_UNIT))
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
 SET modify = nopredeclare
 EXECUTE bsc_get_audit_info
 SET modify = predeclare
 IF ((audit_reply->status_data.status="S")
  AND (audit_reply->summary_qual_cnt > 0))
  IF ((audit_request->display_ind=ndisplayperuser))
   SELECT INTO  $OUTDEV
    name = audit_reply->summary_qual[d.seq].name_full_formatted
    FROM (dummyt d  WITH seq = value(audit_reply->summary_qual_cnt))
    ORDER BY name
    HEAD PAGE
     IF (( $OUTDEV != "MINE"))
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
     row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $MF_FACILITY),3)), col 00,
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
     "(MAE = administered Med Admin Events, AA = where Audit Alert, Pt = Patient, MM = Mismatch, Inc = Incompatible)",
     row + 2, col 20, "Total #",
     col 30, "# of MAE", col 41,
     "% of MAE", col 53, "Pt",
     col 59, "Over", col 67,
     "Under", col 74, "Inc Drug",
     col 84, " Inc Drug", col 96,
     "Task Not", col 106, "Expired",
     col 115, "Early/", col 123,
     "Interval", row + 1, col 00,
     "User", col 20, "of MAE",
     col 30, "AA fired", col 41,
     "AA fired", col 53, "MM",
     col 59, "Dose", col 67,
     "Dose", col 74, "  Form",
     col 84, "Form Route", col 96,
     "  Found", col 105, "  Med",
     col 115, " Late", col 123,
     "Warning", row + 2
    HEAD name
     ltotalmaecnt = (ltotalmaecnt+ audit_reply->summary_qual[d.seq].med_admin_event_cnt), ltotalaacnt
      = (ltotalaacnt+ audit_reply->summary_qual[d.seq].mae_alert_cnt), lpatmismatchcnt = (
     lpatmismatchcnt+ audit_reply->summary_qual[d.seq].pat_mismatch_cnt),
     loverdosecnt = (loverdosecnt+ audit_reply->summary_qual[d.seq].overdose_cnt), lunderdosecnt = (
     lunderdosecnt+ audit_reply->summary_qual[d.seq].underdose_cnt), lincdrugformcnt = (
     lincdrugformcnt+ audit_reply->summary_qual[d.seq].inc_drug_form_cnt),
     lincformroutecnt = (lincformroutecnt+ audit_reply->summary_qual[d.seq].inc_form_route_cnt),
     ltasknotfoundcnt = (ltasknotfoundcnt+ audit_reply->summary_qual[d.seq].task_not_found_cnt),
     lexpiredmedcnt = (lexpiredmedcnt+ audit_reply->summary_qual[d.seq].expired_med_cnt),
     learlylatecnt = (learlylatecnt+ audit_reply->summary_qual[d.seq].early_late_cnt), lintovercnt =
     (lintovercnt+ audit_reply->summary_qual[d.seq].interval_over_cnt), lintwarncnt = (lintwarncnt+
     audit_reply->summary_qual[d.seq].interval_warn_cnt),
     audit_reply->summary_qual[d.seq].name_full_formatted = substring(1,19,audit_reply->summary_qual[
      d.seq].name_full_formatted), col 00, audit_reply->summary_qual[d.seq].name_full_formatted,
     lmaecnt = audit_reply->summary_qual[d.seq].med_admin_event_cnt, sdisplay = format(lmaecnt,
      "#####"), col 20,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].mae_alert_cnt,"#####"), col 31,
     sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual[d.seq].mae_alert_cnt)/ lmaecnt) * 100),
     sdisplay = format(dpercent,"###"),
     col 44, sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].pat_mismatch_cnt,"#####"),
     col 50, sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].overdose_cnt,"#####"),
     col 58, sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].underdose_cnt,"#####"),
     col 66, sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].inc_drug_form_cnt,"#####"),
     col 74, sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].inc_form_route_cnt,"#####"),
     col 85, sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].task_not_found_cnt,"#####"),
     col 96, sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].expired_med_cnt,"#####"),
     col 105, sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].early_late_cnt,"#####"),
     col 114, sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].interval_warn_cnt,"#####"),
     col 123, sdisplay, row + 1
    FOOT REPORT
     col 20, ctotal_line, row + 1,
     col 00, "total", sdisplay = format(ltotalmaecnt,"######"),
     col 19, sdisplay, sdisplay = format(ltotalaacnt,"######"),
     col 30, sdisplay, dpercent = ((cnvtreal(ltotalaacnt)/ ltotalmaecnt) * 100),
     sdisplay = format(dpercent,"###"), col 44, sdisplay,
     sdisplay = format(lpatmismatchcnt,"######"), col 49, sdisplay,
     sdisplay = format(loverdosecnt,"######"), col 57, sdisplay,
     sdisplay = format(lunderdosecnt,"######"), col 65, sdisplay,
     sdisplay = format(lincdrugformcnt,"######"), col 73, sdisplay,
     sdisplay = format(lincformroutecnt,"######"), col 84, sdisplay,
     sdisplay = format(ltasknotfoundcnt,"######"), col 95, sdisplay,
     sdisplay = format(lexpiredmedcnt,"######"), col 104, sdisplay,
     sdisplay = format(learlylatecnt,"######"), col 113, sdisplay,
     sdisplay = format(lintwarncnt,"######"), col 122, sdisplay,
     row + 2, sdisplay = build2("***** end of report *****"),
     CALL center(sdisplay,1,131)
    WITH dio = postscript, maxrow = 45
   ;end select
  ELSEIF ((audit_request->display_ind=ndisplayperday))
   SELECT INTO  $OUTDEV
    int_date = audit_reply->summary_qual[d.seq].internal_date
    FROM (dummyt d  WITH seq = value(audit_reply->summary_qual_cnt))
    ORDER BY int_date
    HEAD PAGE
     IF (( $OUTDEV != "MINE"))
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
     row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $MF_FACILITY),3)), col 00,
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
     "(MAE = administered Med Admin Events, AA = where Audit Alert, Pt = Patient, MM = Mismatch, Inc = Incompatible)",
     row + 2, col 20, "Total #",
     col 30, "# of MAE", col 41,
     "% of MAE", col 53, "Pt",
     col 59, "Over", col 67,
     "Under", col 74, "Inc Drug",
     col 84, " Inc Drug", col 96,
     "Task Not", col 106, "Expired",
     col 115, "Early/", col 123,
     "Interval", row + 1, col 00,
     "Day", col 20, "of MAE",
     col 30, "AA fired", col 41,
     "AA fired", col 53, "MM",
     col 59, "Dose", col 67,
     "Dose", col 74, "  Form",
     col 84, "Form Route", col 96,
     "  Found", col 105, "  Med",
     col 115, " Late", col 123,
     "Warning", row + 2
    HEAD int_date
     ltotalmaecnt = (ltotalmaecnt+ audit_reply->summary_qual[d.seq].med_admin_event_cnt), ltotalaacnt
      = (ltotalaacnt+ audit_reply->summary_qual[d.seq].mae_alert_cnt), lpatmismatchcnt = (
     lpatmismatchcnt+ audit_reply->summary_qual[d.seq].pat_mismatch_cnt),
     loverdosecnt = (loverdosecnt+ audit_reply->summary_qual[d.seq].overdose_cnt), lunderdosecnt = (
     lunderdosecnt+ audit_reply->summary_qual[d.seq].underdose_cnt), lincdrugformcnt = (
     lincdrugformcnt+ audit_reply->summary_qual[d.seq].inc_drug_form_cnt),
     lincformroutecnt = (lincformroutecnt+ audit_reply->summary_qual[d.seq].inc_form_route_cnt),
     ltasknotfoundcnt = (ltasknotfoundcnt+ audit_reply->summary_qual[d.seq].task_not_found_cnt),
     lexpiredmedcnt = (lexpiredmedcnt+ audit_reply->summary_qual[d.seq].expired_med_cnt),
     learlylatecnt = (learlylatecnt+ audit_reply->summary_qual[d.seq].early_late_cnt), lintovercnt =
     (lintovercnt+ audit_reply->summary_qual[d.seq].interval_over_cnt), lintwarncnt = (lintwarncnt+
     audit_reply->summary_qual[d.seq].interval_warn_cnt),
     col 00, audit_reply->summary_qual[d.seq].date_string, lmaecnt = audit_reply->summary_qual[d.seq]
     .med_admin_event_cnt,
     sdisplay = format(lmaecnt,"#####"), col 20, sdisplay,
     sdisplay = format(audit_reply->summary_qual[d.seq].mae_alert_cnt,"#####"), col 31, sdisplay,
     dpercent = ((cnvtreal(audit_reply->summary_qual[d.seq].mae_alert_cnt)/ lmaecnt) * 100), sdisplay
      = format(dpercent,"###"), col 44,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].pat_mismatch_cnt,"#####"), col 50,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].overdose_cnt,"#####"), col 58,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].underdose_cnt,"#####"), col 66,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].inc_drug_form_cnt,"#####"), col 74,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].inc_form_route_cnt,"#####"), col 85,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].task_not_found_cnt,"#####"), col 96,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].expired_med_cnt,"#####"), col 105,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].early_late_cnt,"#####"), col 114,
     sdisplay, sdisplay = format(audit_reply->summary_qual[d.seq].interval_warn_cnt,"#####"), col 123,
     sdisplay, row + 1
    FOOT REPORT
     col 20, ctotal_line, row + 1,
     col 00, "Total", sdisplay = format(ltotalmaecnt,"######"),
     col 19, sdisplay, sdisplay = format(ltotalaacnt,"######"),
     col 30, sdisplay, dpercent = ((cnvtreal(ltotalaacnt)/ ltotalmaecnt) * 100),
     sdisplay = format(dpercent,"###"), col 44, sdisplay,
     sdisplay = format(lpatmismatchcnt,"######"), col 49, sdisplay,
     sdisplay = format(loverdosecnt,"######"), col 57, sdisplay,
     sdisplay = format(lunderdosecnt,"######"), col 65, sdisplay,
     sdisplay = format(lincdrugformcnt,"######"), col 73, sdisplay,
     sdisplay = format(lincformroutecnt,"######"), col 84, sdisplay,
     sdisplay = format(ltasknotfoundcnt,"######"), col 95, sdisplay,
     sdisplay = format(lexpiredmedcnt,"######"), col 104, sdisplay,
     sdisplay = format(learlylatecnt,"######"), col 113, sdisplay,
     sdisplay = format(lintwarncnt,"######"), col 122, sdisplay,
     row + 2, sdisplay = build2("***** End of Report *****"),
     CALL center(sdisplay,1,131)
    WITH dio = postscript, maxrow = 45
   ;end select
  ENDIF
 ELSE
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   ORDER BY d.seq
   HEAD PAGE
    IF (( $OUTDEV != "MINE"))
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
    row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $MF_FACILITY),3)), col 00,
    sdisplay, col 96, "Run Date: ",
    curdate"MM/DD/YYYY;;D", " Time: ", curtime"HH:MM;;S",
    row + 1, sdisplay = ""
    IF (nallind=1)
     sdisplay = "Nurse Units: All"
    ELSEIF ((audit_request->unit_cnt > 1))
     sdisplay = concat("nurse units: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd
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
END GO
