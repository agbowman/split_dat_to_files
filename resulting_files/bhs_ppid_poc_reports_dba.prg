CREATE PROGRAM bhs_ppid_poc_reports:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date:" = "CURDATE",
  "Ending date:" = "CURDATE",
  "Facility:" = 0,
  "Nurse unit(s):" = 0,
  "Display per:" = 0
  WITH out_dev, start_date, end_date,
  facility, nurse_unit, display_type
 FREE RECORD audit_request
 IF ( NOT (validate(audit_request)))
  RECORD audit_request(
    1 report_name = vc
    1 start_dt_tm = dq8
    1 end_dt_tm = dq8
    1 facility_cd = f8
    1 unit_cnt = i4
    1 unit[*]
      2 nurse_unit_cd = f8
    1 display_ind = i2
  ) WITH persist
 ENDIF
 FREE RECORD audit_reply
 RECORD audit_reply(
   1 summary_qual_cnt = i4
   1 summary_qual[*]
     2 prsnl_id = f8
     2 name_full_formatted = vc
     2 internal_date = i4
     2 date_string = vc
     2 med_admin_event_cnt = i4
     2 positive_pat_cnt = i4
     2 positive_med_cnt = i4
     2 mae_alert_cnt = i4
     2 pat_mismatch_cnt = i4
     2 pat_not_ident_cnt = i4
     2 overdose_cnt = i4
     2 underdose_cnt = i4
     2 inc_drug_form_cnt = i4
     2 inc_form_route_cnt = i4
     2 task_not_found_cnt = i4
     2 med_not_ident_cnt = i4
     2 expired_med_cnt = i4
   1 summary_qual_cnt2 = i4
   1 summary_qual2[*]
     2 prsnl_id = f8
     2 name_full_formatted = vc
     2 internal_date = i4
     2 date_string = vc
     2 med_admin_event_cnt = i4
     2 positive_pat_cnt = i4
     2 positive_med_cnt = i4
     2 mae_alert_cnt = i4
     2 pat_mismatch_cnt = i4
     2 pat_not_ident_cnt = i4
     2 overdose_cnt = i4
     2 underdose_cnt = i4
     2 inc_drug_form_cnt = i4
     2 inc_form_route_cnt = i4
     2 task_not_found_cnt = i4
     2 med_not_ident_cnt = i4
     2 expired_med_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persist
 DECLARE ndisplayperuser = i2 WITH protect, constant(0)
 DECLARE ndisplayperday = i2 WITH protect, constant(1)
 DECLARE ctitle = vc
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(79,"-"))
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lmaecnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalmaecnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalptidcnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalmedidcnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalaacnt = i4 WITH protect, noconstant(0)
 DECLARE lpatnotidentcnt = i4 WITH protect, noconstant(0)
 DECLARE lmednotidentcnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalaacnt = i4 WITH protect, noconstant(0)
 DECLARE lpatmismatchcnt = i4 WITH protect, noconstant(0)
 DECLARE loverdosecnt = i4 WITH protect, noconstant(0)
 DECLARE lunderdosecnt = i4 WITH protect, noconstant(0)
 DECLARE lincdrugformcnt = i4 WITH protect, noconstant(0)
 DECLARE lincformroutecnt = i4 WITH protect, noconstant(0)
 DECLARE ltasknotfoundcnt = i4 WITH protect, noconstant(0)
 DECLARE lexpiredmedcnt = i4 WITH protect, noconstant(0)
 DECLARE dpercent = f8 WITH protect, noconstant(0.0)
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE any_status_ind = c1
 SET any_status_ind = substring(1,1,reflect(parameter(5,0)))
 IF (( $START_DATE="curdate"))
  SET audit_request->start_dt_tm = cnvtdatetime(curdate,0)
 ELSE
  SET audit_request->start_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $START_DATE)),0)
 ENDIF
 IF (( $END_DATE="curdate"))
  SET audit_request->end_dt_tm = cnvtdatetime(curdate,235959)
 ELSE
  SET audit_request->end_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $END_DATE)),235959)
 ENDIF
 SET audit_request->facility_cd =  $FACILITY
 IF (any_status_ind="C")
  SELECT INTO "nl:"
   FROM code_value cv,
    nurse_unit n,
    code_value cv1,
    code_value cv2
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="BUILDING"
     AND cv.display_key IN ("BFMC", "BFMCINPTPSYCH", "BMLH", "BMC", "BMCINPTPSYCH",
    "BWH", "BWHINPTPSYCH", "BNH", "BNHINPTPSYCH")
     AND cv.active_ind=1)
    JOIN (n
    WHERE (n.loc_facility_cd= $FACILITY)
     AND n.loc_building_cd=cv.code_value
     AND n.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=n.location_cd
     AND cv1.code_set=220
     AND cv1.active_ind=1
     AND cv1.cdf_meaning="NURSEUNIT")
    JOIN (cv2
    WHERE cv2.code_value=cv1.data_status_cd
     AND cv2.display_key="AUTHVERIFIED")
   ORDER BY cv1.display
   HEAD REPORT
    lcnt = 0, nallind = 1
   DETAIL
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     dstat = alterlist(audit_request->unit,(lcnt+ 9))
    ENDIF
    audit_request->unit[lcnt].nurse_unit_cd = cv1.code_value
   FOOT REPORT
    dstat = alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE (cv.code_value= $NURSE_UNIT))
   ORDER BY cv.display
   HEAD REPORT
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     dstat = alterlist(audit_request->unit,(lcnt+ 9))
    ENDIF
    audit_request->unit[lcnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    dstat = alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
   WITH nocounter
  ;end select
 ENDIF
 SET audit_request->display_ind =  $DISPLAY_TYPE
 SET modify = nopredeclare
 EXECUTE bhs_bsc_get_audit_info
 DECLARE cur_report = i2
 SET cur_report = 1
 IF ((audit_reply->status_data.status="s")
  AND (audit_reply->summary_qual_cnt > 0))
  IF ((audit_request->display_ind=ndisplayperuser))
   SET stat = alterlist(audit_reply->summary_qual2,audit_reply->summary_qual_cnt)
   SELECT INTO "nl:"
    name = audit_reply->summary_qual[d.seq].name_full_formatted
    FROM (dummyt d  WITH seq = value(audit_reply->summary_qual_cnt))
    ORDER BY name
    HEAD name
     audit_reply->summary_qual_cnt2 = (audit_reply->summary_qual_cnt2+ 1), idx = audit_reply->
     summary_qual_cnt2, audit_reply->summary_qual2[idx].date_string = audit_reply->summary_qual[d.seq
     ].date_string,
     audit_reply->summary_qual2[idx].expired_med_cnt = audit_reply->summary_qual[d.seq].
     expired_med_cnt, audit_reply->summary_qual2[idx].inc_drug_form_cnt = audit_reply->summary_qual[d
     .seq].inc_drug_form_cnt, audit_reply->summary_qual2[idx].inc_form_route_cnt = audit_reply->
     summary_qual[d.seq].inc_form_route_cnt,
     audit_reply->summary_qual2[idx].internal_date = audit_reply->summary_qual[d.seq].internal_date,
     audit_reply->summary_qual2[idx].mae_alert_cnt = audit_reply->summary_qual[d.seq].mae_alert_cnt,
     audit_reply->summary_qual2[idx].med_admin_event_cnt = audit_reply->summary_qual[d.seq].
     med_admin_event_cnt,
     audit_reply->summary_qual2[idx].med_not_ident_cnt = audit_reply->summary_qual[d.seq].
     med_not_ident_cnt, audit_reply->summary_qual2[idx].name_full_formatted = audit_reply->
     summary_qual[d.seq].name_full_formatted, audit_reply->summary_qual2[idx].overdose_cnt =
     audit_reply->summary_qual[d.seq].overdose_cnt,
     audit_reply->summary_qual2[idx].pat_mismatch_cnt = audit_reply->summary_qual[d.seq].
     pat_mismatch_cnt, audit_reply->summary_qual2[idx].pat_not_ident_cnt = audit_reply->summary_qual[
     d.seq].pat_not_ident_cnt, audit_reply->summary_qual2[idx].positive_med_cnt = audit_reply->
     summary_qual[d.seq].positive_med_cnt,
     audit_reply->summary_qual2[idx].positive_pat_cnt = audit_reply->summary_qual[d.seq].
     positive_pat_cnt, audit_reply->summary_qual2[idx].prsnl_id = audit_reply->summary_qual[d.seq].
     prsnl_id, audit_reply->summary_qual2[idx].task_not_found_cnt = audit_reply->summary_qual[d.seq].
     task_not_found_cnt,
     audit_reply->summary_qual2[idx].underdose_cnt = audit_reply->summary_qual[d.seq].underdose_cnt
    WITH nocounter
   ;end select
   SELECT INTO  $1
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    HEAD PAGE
     IF (cur_report != 4)
      IF ( NOT (( $1 IN ("MINE"))))
       col 0, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
      ENDIF
      col 0, "Date Range: ", sdisplay = ""
      IF ((audit_request->start_dt_tm > 0))
       sdisplay = format(audit_request->start_dt_tm,"mm/dd/yyyy;;d")
      ENDIF
      IF ((audit_request->end_dt_tm > 0))
       sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"mm/dd/yyyy;;d"))
      ENDIF
      IF (textlen(sdisplay) > 0)
       col 12, sdisplay
      ENDIF
      col 122, "Page: ", curpage"###",
      row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $FACILITY),3)), col 0,
      sdisplay, col 96, "Run Date: ",
      curdate"mm/dd/yyyy;;d", " Time: ", curtime"hh:mm;;s",
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
       sdisplay = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].
          nurse_unit_cd),3))
      ELSE
       sdisplay = "Nurse Unit:"
      ENDIF
      col 0, sdisplay
      IF (nallind=0
       AND (audit_request->unit_cnt > 1))
       row + 1
      ENDIF
     ENDIF
     IF (cur_report=1)
      ctitle = "Point of Care Utilization",
      CALL center(ctitle,1,131), row + 1,
      col 0, cdashline, row + 1,
      col 0,
      "Legend (MAE = Med Admin Events, ID = where barcode used to identify, Pt = Patient, AA = where Audit Alert)",
      row + 2,
      col 30, "Total #", col 41,
      "# of MAE", col 53, "% of MAE",
      col 65, "# of MAE", col 77,
      "% of MAE", col 89, "# of MAE",
      col 101, "% of MAE", row + 1,
      col 00, "User", col 30,
      "of MAE", col 41, "  ID Pt",
      col 53, "  ID Pt", col 65,
      " ID Med", col 77, " ID Med",
      col 89, "AA fired", col 101,
      "AA fired", row + 2
     ENDIF
     IF (cur_report=2)
      ctitle = "Point of Care Identification Issues",
      CALL center(ctitle,1,131), row + 1,
      col 0, cdashline, row + 1,
      col 0, "Legend (MAE = Med Admin Events, ID = where barcode used to identify, Pt = Patient)",
      row + 2,
      col 30, "Total #", col 41,
      "# of MAE", col 53, "# of MAE",
      col 65, "  Pt Not", col 79,
      "  Med Not", row + 1, col 0,
      "User", col 30, "of MAE",
      col 41, "  ID Pt", col 53,
      " ID Med", col 65, "Identified",
      col 79, "Identified", row + 2
     ENDIF
     IF (cur_report=3)
      ctitle = "Point of Care Audit Alert Numbers",
      CALL center(ctitle,1,131), row + 1,
      col 0, cdashline, row + 1,
      col 0,
      "Legend (MAE = Med Admin Events, AA = where Audit Alert, Pt = Patient, MM = Mismatch, Inc = Incompatible)",
      row + 2,
      col 30, "Total #", col 40,
      "# of MAE", col 51, "% of MAE",
      col 63, "Pt", col 69,
      "Over", col 77, "Under",
      col 86, "Inc Drug", col 98,
      " Inc Drug", col 112, "Task Not",
      col 124, "Expired", row + 1,
      col 0, "User", col 30,
      "of MAE", col 40, "AA fired",
      col 51, "AA fired", col 63,
      "MM", col 69, "Dose",
      col 77, "Dose", col 86,
      "  Form", col 98, "Form Route",
      col 112, "  Found", col 124,
      "  Med", row + 2
     ENDIF
    DETAIL
     FOR (i = 1 TO audit_reply->summary_qual_cnt2)
       ltotalmaecnt = (ltotalmaecnt+ audit_reply->summary_qual2[i].med_admin_event_cnt),
       ltotalptidcnt = (ltotalptidcnt+ audit_reply->summary_qual2[i].positive_pat_cnt),
       ltotalmedidcnt = (ltotalmedidcnt+ audit_reply->summary_qual2[i].positive_med_cnt),
       ltotalaacnt = (ltotalaacnt+ audit_reply->summary_qual2[i].mae_alert_cnt), col 0, audit_reply->
       summary_qual2[i].name_full_formatted,
       lmaecnt = audit_reply->summary_qual2[i].med_admin_event_cnt, sdisplay = format(lmaecnt,"#####"
        ), col 30,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].positive_pat_cnt,"#####"), col 42,
       sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual2[i].positive_pat_cnt)/ lmaecnt) *
       100), sdisplay = format(dpercent,"###"),
       col 56, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].positive_med_cnt,"#####"),
       col 66, sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual2[i].positive_med_cnt)/
       lmaecnt) * 100),
       sdisplay = format(dpercent,"###"), col 80, sdisplay,
       sdisplay = format(audit_reply->summary_qual2[i].mae_alert_cnt,"#####"), col 90, sdisplay,
       dpercent = ((cnvtreal(audit_reply->summary_qual2[i].mae_alert_cnt)/ lmaecnt) * 100), sdisplay
        = format(dpercent,"###"), col 104,
       sdisplay, row + 1
       IF ((i=audit_reply->summary_qual_cnt2))
        BREAK
       ENDIF
     ENDFOR
     FOR (i = 1 TO audit_reply->summary_qual_cnt2)
       lpatnotidentcnt = (lpatnotidentcnt+ audit_reply->summary_qual2[i].pat_not_ident_cnt),
       lmednotidentcnt = (lmednotidentcnt+ audit_reply->summary_qual2[i].med_not_ident_cnt), col 0,
       audit_reply->summary_qual2[i].name_full_formatted, sdisplay = format(audit_reply->
        summary_qual2[i].med_admin_event_cnt,"#####"), col 30,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].positive_pat_cnt,"#####"), col 42,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].positive_med_cnt,"#####"), col 54,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].pat_not_ident_cnt,"#####"), col 67,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].med_not_ident_cnt,"#####"), col 81,
       sdisplay, row + 1
       IF ((i=audit_reply->summary_qual_cnt2))
        BREAK
       ENDIF
     ENDFOR
     FOR (i = 1 TO audit_reply->summary_qual_cnt2)
       lpatmismatchcnt = (lpatmismatchcnt+ audit_reply->summary_qual2[i].pat_mismatch_cnt),
       loverdosecnt = (loverdosecnt+ audit_reply->summary_qual2[i].overdose_cnt), lunderdosecnt = (
       lunderdosecnt+ audit_reply->summary_qual2[i].underdose_cnt),
       lincdrugformcnt = (lincdrugformcnt+ audit_reply->summary_qual2[i].inc_drug_form_cnt),
       lincformroutecnt = (lincformroutecnt+ audit_reply->summary_qual2[i].inc_form_route_cnt),
       ltasknotfoundcnt = (ltasknotfoundcnt+ audit_reply->summary_qual2[i].task_not_found_cnt),
       lexpiredmedcnt = (lexpiredmedcnt+ audit_reply->summary_qual2[i].expired_med_cnt), col 0,
       audit_reply->summary_qual[i].name_full_formatted,
       lmaecnt = audit_reply->summary_qual2[i].med_admin_event_cnt, sdisplay = format(lmaecnt,"#####"
        ), col 30,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].mae_alert_cnt,"#####"), col 41,
       sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual2[i].mae_alert_cnt)/ lmaecnt) * 10),
       sdisplay = format(dpercent,"###"),
       col 54, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].pat_mismatch_cnt,"#####"),
       col 60, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].overdose_cnt,"#####"),
       col 68, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].underdose_cnt,"#####"),
       col 76, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].inc_drug_form_cnt,"#####"),
       col 86, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].inc_form_route_cnt,"#####"),
       col 99, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].task_not_found_cnt,"#####"),
       col 112, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].expired_med_cnt,"#####"),
       col 124, sdisplay, row + 1
       IF ((i=audit_reply->summary_qual_cnt2))
        BREAK
       ENDIF
     ENDFOR
    FOOT PAGE
     IF (cur_report=3)
      col 30, ctotal_line, row + 1,
      col 0, "Total", sdisplay = format(ltotalmaecnt,"#####"),
      col 30, sdisplay, sdisplay = format(ltotalaacnt,"#####"),
      col 41, sdisplay, dpercent = ((cnvtreal(ltotalaacnt)/ ltotalmaecnt) * 100),
      sdisplay = format(dpercent,"###"), col 54, sdisplay,
      sdisplay = format(lpatmismatchcnt,"#####"), col 60, sdisplay,
      sdisplay = format(loverdosecnt,"#####"), col 68, sdisplay,
      sdisplay = format(lunderdosecnt,"#####"), col 76, sdisplay,
      sdisplay = format(lincdrugformcnt,"#####"), col 86, sdisplay,
      sdisplay = format(lincformroutecnt,"#####"), col 99, sdisplay,
      sdisplay = format(ltasknotfoundcnt,"#####"), col 112, sdisplay,
      sdisplay = format(lexpiredmedcnt,"#####"), col 124, sdisplay,
      cur_report = 4, row + 2, sdisplay = build2("***** End of Report *****"),
      CALL center(sdisplay,1,131)
     ENDIF
     IF (cur_report=2)
      col 30, ctotal_line, row + 1,
      col 0, "Total", sdisplay = format(ltotalmaecnt,"#####"),
      col 30, sdisplay, sdisplay = format(ltotalptidcnt,"#####"),
      col 42, sdisplay, sdisplay = format(ltotalmedidcnt,"#####"),
      col 54, sdisplay, sdisplay = format(lpatnotidentcnt,"#####"),
      col 67, sdisplay, sdisplay = format(lmednotidentcnt,"#####"),
      col 81, sdisplay, cur_report = 3
     ENDIF
     IF (cur_report=1)
      col 30, ctotal_line, row + 1,
      col 0, "Total", sdisplay = format(ltotalmaecnt,"#####"),
      col 30, sdisplay, sdisplay = format(ltotalptidcnt,"#####"),
      col 42, sdisplay, dpercent = ((cnvtreal(ltotalptidcnt)/ ltotalmaecnt) * 100),
      sdisplay = format(dpercent,"###"), col 56, sdisplay,
      sdisplay = format(ltotalmedidcnt,"#####"), col 66, sdisplay,
      dpercent = ((cnvtreal(ltotalmedidcnt)/ ltotalmaecnt) * 100), sdisplay = format(dpercent,"###"),
      col 80,
      sdisplay, sdisplay = format(ltotalaacnt,"#####"), col 90,
      sdisplay, dpercent = ((cnvtreal(ltotalaacnt)/ ltotalmaecnt) * 100), sdisplay = format(dpercent,
       "###"),
      col 104, sdisplay, cur_report = 2
     ENDIF
    WITH dio = postscript, maxrow = 45
   ;end select
  ELSEIF ((audit_request->display_ind=ndisplayperday))
   SET stat = alterlist(audit_reply->summary_qual2,audit_reply->summary_qual_cnt)
   SELECT INTO "nl:"
    int_date = audit_reply->summary_qual[d.seq].internal_date
    FROM (dummyt d  WITH seq = value(audit_reply->summary_qual_cnt))
    ORDER BY int_date
    HEAD int_date
     audit_reply->summary_qual_cnt2 = (audit_reply->summary_qual_cnt2+ 1), idx = audit_reply->
     summary_qual_cnt2, audit_reply->summary_qual2[idx].date_string = audit_reply->summary_qual[d.seq
     ].date_string,
     audit_reply->summary_qual2[idx].expired_med_cnt = audit_reply->summary_qual[d.seq].
     expired_med_cnt, audit_reply->summary_qual2[idx].inc_drug_form_cnt = audit_reply->summary_qual[d
     .seq].inc_drug_form_cnt, audit_reply->summary_qual2[idx].inc_form_route_cnt = audit_reply->
     summary_qual[d.seq].inc_form_route_cnt,
     audit_reply->summary_qual2[idx].internal_date = audit_reply->summary_qual[d.seq].internal_date,
     audit_reply->summary_qual2[idx].mae_alert_cnt = audit_reply->summary_qual[d.seq].mae_alert_cnt,
     audit_reply->summary_qual2[idx].med_admin_event_cnt = audit_reply->summary_qual[d.seq].
     med_admin_event_cnt,
     audit_reply->summary_qual2[idx].med_not_ident_cnt = audit_reply->summary_qual[d.seq].
     med_not_ident_cnt, audit_reply->summary_qual2[idx].name_full_formatted = audit_reply->
     summary_qual[d.seq].name_full_formatted, audit_reply->summary_qual2[idx].overdose_cnt =
     audit_reply->summary_qual[d.seq].overdose_cnt,
     audit_reply->summary_qual2[idx].pat_mismatch_cnt = audit_reply->summary_qual[d.seq].
     pat_mismatch_cnt, audit_reply->summary_qual2[idx].pat_not_ident_cnt = audit_reply->summary_qual[
     d.seq].pat_not_ident_cnt, audit_reply->summary_qual2[idx].positive_med_cnt = audit_reply->
     summary_qual[d.seq].positive_med_cnt,
     audit_reply->summary_qual2[idx].positive_pat_cnt = audit_reply->summary_qual[d.seq].
     positive_pat_cnt, audit_reply->summary_qual2[idx].prsnl_id = audit_reply->summary_qual[d.seq].
     prsnl_id, audit_reply->summary_qual2[idx].task_not_found_cnt = audit_reply->summary_qual[d.seq].
     task_not_found_cnt,
     audit_reply->summary_qual2[idx].underdose_cnt = audit_reply->summary_qual[d.seq].underdose_cnt
    WITH nocounter
   ;end select
   SELECT INTO  $1
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    HEAD PAGE
     IF (cur_report != 4)
      IF ( NOT (( $1 IN ("MINE"))))
       col 0, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
      ENDIF
      col 0, "Date Range: ", sdisplay = ""
      IF ((audit_request->start_dt_tm > 0))
       sdisplay = format(audit_request->start_dt_tm,"mm/dd/yyyy;;d")
      ENDIF
      IF ((audit_request->end_dt_tm > 0))
       sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"mm/dd/yyyy;;d"))
      ENDIF
      IF (textlen(sdisplay) > 0)
       col 12, sdisplay
      ENDIF
      col 122, "Page: ", curpage"###",
      row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $FACILITY),3)), col 0,
      sdisplay, col 96, "Run Date: ",
      curdate"mm/dd/yyyy;;d", " Time: ", curtime"hh:mm;;s",
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
       sdisplay = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].
          nurse_unit_cd),3))
      ELSE
       sdisplay = "Nurse Unit:"
      ENDIF
      col 0, sdisplay
      IF (nallind=0
       AND (audit_request->unit_cnt > 1))
       row + 1
      ENDIF
     ENDIF
     IF (cur_report=1)
      ctitle = "Point of Care Utilization",
      CALL center(ctitle,1,131), row + 1,
      col 0, cdashline, row + 1,
      col 0,
      "Legend (MAE = Med Admin Events, ID = where barcode used to identify, Pt = Patient, AA = where Audit Alert)",
      row + 2,
      col 30, "Total #", col 41,
      "# of MAE", col 53, "% of MAE",
      col 65, "# of MAE", col 77,
      "% of MAE", col 89, "# of MAE",
      col 101, "% of MAE", row + 1,
      col 00, "Day", col 30,
      "of MAE", col 41, "  ID Pt",
      col 53, "  ID Pt", col 65,
      " ID Med", col 77, " ID Med",
      col 89, "AA fired", col 101,
      "AA fired", row + 2
     ENDIF
     IF (cur_report=2)
      ctitle = "Point of Care Identification Issues",
      CALL center(ctitle,1,131), row + 1,
      col 0, cdashline, row + 1,
      col 0, "Legend (MAE = Med Admin Events, ID = where barcode used to identify, Pt = Patient)",
      row + 2,
      col 30, "Total #", col 41,
      "# of MAE", col 53, "# of MAE",
      col 65, "  Pt Not", col 79,
      "  Med Not", row + 1, col 0,
      "Day", col 30, "of MAE",
      col 41, "  ID Pt", col 53,
      " ID Med", col 65, "Identified",
      col 79, "Identified", row + 2
     ENDIF
     IF (cur_report=3)
      ctitle = "Point of Care Audit Alert Numbers",
      CALL center(ctitle,1,131), row + 1,
      col 0, cdashline, row + 1,
      col 0,
      "Legend (MAE = Med Admin Events, AA = where Audit Alert, Pt = Patient, MM = Mismatch, Inc = Incompatible)",
      row + 2,
      col 30, "Total #", col 40,
      "# of MAE", col 51, "% of MAE",
      col 63, "Pt", col 69,
      "Over", col 77, "Under",
      col 86, "Inc Drug", col 98,
      " Inc Drug", col 112, "Task Not",
      col 124, "Expired", row + 1,
      col 0, "Day", col 30,
      "of MAE", col 40, "AA fired",
      col 51, "AA fired", col 63,
      "MM", col 69, "Dose",
      col 77, "Dose", col 86,
      "  Form", col 98, "Form Route",
      col 112, "  Found", col 124,
      "  Med", row + 2
     ENDIF
    DETAIL
     FOR (i = 1 TO audit_reply->summary_qual_cnt2)
       ltotalmaecnt = (ltotalmaecnt+ audit_reply->summary_qual2[i].med_admin_event_cnt),
       ltotalptidcnt = (ltotalptidcnt+ audit_reply->summary_qual2[i].positive_pat_cnt),
       ltotalmedidcnt = (ltotalmedidcnt+ audit_reply->summary_qual2[i].positive_med_cnt),
       ltotalaacnt = (ltotalaacnt+ audit_reply->summary_qual2[i].mae_alert_cnt), col 0, audit_reply->
       summary_qual2[i].date_string,
       lmaecnt = audit_reply->summary_qual2[i].med_admin_event_cnt, sdisplay = format(lmaecnt,"#####"
        ), col 30,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].positive_pat_cnt,"#####"), col 42,
       sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual2[i].positive_pat_cnt)/ lmaecnt) *
       100), sdisplay = format(dpercent,"###"),
       col 56, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].positive_med_cnt,"#####"),
       col 66, sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual2[i].positive_med_cnt)/
       lmaecnt) * 100),
       sdisplay = format(dpercent,"###"), col 80, sdisplay,
       sdisplay = format(audit_reply->summary_qual2[i].mae_alert_cnt,"#####"), col 90, sdisplay,
       dpercent = ((cnvtreal(audit_reply->summary_qual2[i].mae_alert_cnt)/ lmaecnt) * 100), sdisplay
        = format(dpercent,"###"), col 104,
       sdisplay, row + 1
       IF ((i=audit_reply->summary_qual_cnt2))
        BREAK
       ENDIF
     ENDFOR
     FOR (i = 1 TO audit_reply->summary_qual_cnt2)
       lpatnotidentcnt = (lpatnotidentcnt+ audit_reply->summary_qual2[i].pat_not_ident_cnt),
       lmednotidentcnt = (lmednotidentcnt+ audit_reply->summary_qual2[i].med_not_ident_cnt), col 0,
       audit_reply->summary_qual2[i].date_string, sdisplay = format(audit_reply->summary_qual2[i].
        med_admin_event_cnt,"#####"), col 30,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].positive_pat_cnt,"#####"), col 42,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].positive_med_cnt,"#####"), col 54,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].pat_not_ident_cnt,"#####"), col 67,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].med_not_ident_cnt,"#####"), col 81,
       sdisplay, row + 1
       IF ((i=audit_reply->summary_qual_cnt2))
        BREAK
       ENDIF
     ENDFOR
     FOR (i = 1 TO audit_reply->summary_qual_cnt2)
       lpatmismatchcnt = (lpatmismatchcnt+ audit_reply->summary_qual2[i].pat_mismatch_cnt),
       loverdosecnt = (loverdosecnt+ audit_reply->summary_qual2[i].overdose_cnt), lunderdosecnt = (
       lunderdosecnt+ audit_reply->summary_qual2[i].underdose_cnt),
       lincdrugformcnt = (lincdrugformcnt+ audit_reply->summary_qual2[i].inc_drug_form_cnt),
       lincformroutecnt = (lincformroutecnt+ audit_reply->summary_qual2[i].inc_form_route_cnt),
       ltasknotfoundcnt = (ltasknotfoundcnt+ audit_reply->summary_qual2[i].task_not_found_cnt),
       lexpiredmedcnt = (lexpiredmedcnt+ audit_reply->summary_qual2[i].expired_med_cnt), col 0,
       audit_reply->summary_qual2[i].date_string,
       lmaecnt = audit_reply->summary_qual2[i].med_admin_event_cnt, sdisplay = format(lmaecnt,"#####"
        ), col 30,
       sdisplay, sdisplay = format(audit_reply->summary_qual2[i].mae_alert_cnt,"#####"), col 41,
       sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual2[i].mae_alert_cnt)/ lmaecnt) * 10),
       sdisplay = format(dpercent,"###"),
       col 54, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].pat_mismatch_cnt,"#####"),
       col 60, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].overdose_cnt,"#####"),
       col 68, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].underdose_cnt,"#####"),
       col 76, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].inc_drug_form_cnt,"#####"),
       col 86, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].inc_form_route_cnt,"#####"),
       col 99, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].task_not_found_cnt,"#####"),
       col 112, sdisplay, sdisplay = format(audit_reply->summary_qual2[i].expired_med_cnt,"#####"),
       col 124, sdisplay, row + 1
       IF ((i=audit_reply->summary_qual_cnt2))
        BREAK
       ENDIF
     ENDFOR
    FOOT PAGE
     IF (cur_report=3)
      col 30, ctotal_line, row + 1,
      col 0, "Total", sdisplay = format(ltotalmaecnt,"#####"),
      col 30, sdisplay, sdisplay = format(ltotalaacnt,"#####"),
      col 41, sdisplay, dpercent = ((cnvtreal(ltotalaacnt)/ ltotalmaecnt) * 100),
      sdisplay = format(dpercent,"###"), col 54, sdisplay,
      sdisplay = format(lpatmismatchcnt,"#####"), col 60, sdisplay,
      sdisplay = format(loverdosecnt,"#####"), col 68, sdisplay,
      sdisplay = format(lunderdosecnt,"#####"), col 76, sdisplay,
      sdisplay = format(lincdrugformcnt,"#####"), col 86, sdisplay,
      sdisplay = format(lincformroutecnt,"#####"), col 99, sdisplay,
      sdisplay = format(ltasknotfoundcnt,"#####"), col 112, sdisplay,
      sdisplay = format(lexpiredmedcnt,"#####"), col 124, sdisplay,
      cur_report = 4, row + 2, sdisplay = build2("***** End of Report *****"),
      CALL center(sdisplay,1,131)
     ENDIF
     IF (cur_report=2)
      col 30, ctotal_line, row + 1,
      col 0, "Total", sdisplay = format(ltotalmaecnt,"#####"),
      col 30, sdisplay, sdisplay = format(ltotalptidcnt,"#####"),
      col 42, sdisplay, sdisplay = format(ltotalmedidcnt,"#####"),
      col 54, sdisplay, sdisplay = format(lpatnotidentcnt,"#####"),
      col 67, sdisplay, sdisplay = format(lmednotidentcnt,"#####"),
      col 81, sdisplay, cur_report = 3
     ENDIF
     IF (cur_report=1)
      col 30, ctotal_line, row + 1,
      col 0, "Total", sdisplay = format(ltotalmaecnt,"#####"),
      col 30, sdisplay, sdisplay = format(ltotalptidcnt,"#####"),
      col 42, sdisplay, dpercent = ((cnvtreal(ltotalptidcnt)/ ltotalmaecnt) * 100),
      sdisplay = format(dpercent,"###"), col 56, sdisplay,
      sdisplay = format(ltotalmedidcnt,"#####"), col 66, sdisplay,
      dpercent = ((cnvtreal(ltotalmedidcnt)/ ltotalmaecnt) * 100), sdisplay = format(dpercent,"###"),
      col 80,
      sdisplay, sdisplay = format(ltotalaacnt,"#####"), col 90,
      sdisplay, dpercent = ((cnvtreal(ltotalaacnt)/ ltotalmaecnt) * 100), sdisplay = format(dpercent,
       "###"),
      col 104, sdisplay, cur_report = 2
     ENDIF
    WITH dio = postscript, maxrow = 45
   ;end select
  ELSE
   SELECT INTO  $1
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    HEAD PAGE
     IF ( NOT (( $1 IN ("MINE"))))
      col 0, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
     ENDIF
     col 0, "Date Range: ", sdisplay = ""
     IF ((audit_request->start_dt_tm > 0))
      sdisplay = format(audit_request->start_dt_tm,"mm/dd/yyyy;;d")
     ENDIF
     IF ((audit_request->end_dt_tm > 0))
      sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"mm/dd/yyyy;;d"))
     ENDIF
     IF (textlen(sdisplay) > 0)
      col 12, sdisplay
     ENDIF
     col 122, "Page: ", curpage"###",
     row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $FACILITY),3)), col 0,
     sdisplay, col 96, "Run Date: ",
     curdate"mm/dd/yyyy;;d", " Time: ", curtime"hh:mm;;s",
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
     col 0, sdisplay
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
 ENDIF
END GO
