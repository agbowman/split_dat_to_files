CREATE PROGRAM bhs_scan_compliancetest
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date(mm/dd/yyyy):" = "CURDATE",
  "Ending date(mm/dd/yyyy):" = "CURDATE",
  "Facility:" = 0,
  "Nurse_unit(s): " = 0
  WITH out_dev, start_date, end_date,
  facility, nurse_unit
 FREE RECORD audit_request
 RECORD audit_request(
   1 report_name = vc
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 facility_cd = f8
   1 unit_cnt = i4
   1 unit[*]
     2 nurse_unit_cd = f8
   1 display_ind = i2
 )
 DECLARE ctitle = vc WITH protect, constant("Point of Care Audit Scan Compliance Report")
 DECLARE cnotgiven = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"NOTGIVEN"))
 DECLARE cnotdone = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"NOTDONE"))
 DECLARE cnotadministered = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"TASKPURGED")
  )
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(130,"-"))
 DECLARE last_mod = vc WITH protect, noconstant("")
 DECLARE mod_date = vc WITH protect, noconstant("")
 DECLARE nurseunit = vc WITH protect, noconstant("")
 DECLARE username = vc WITH protect, noconstant("")
 DECLARE position = vc WITH protect, noconstant("")
 DECLARE posptcompliancetotal = i4 WITH protect, noconstant(0)
 DECLARE posmedcompliancetotal = i4 WITH protect, noconstant(0)
 DECLARE ptcompliancetotalevents = i4 WITH protect, noconstant(0)
 DECLARE medcompliancetotalevents = i4 WITH protect, noconstant(0)
 DECLARE complianceptpercent = f8 WITH protect, noconstant(0.0)
 DECLARE compliancemedpercent = f8 WITH protect, noconstant(0.0)
 DECLARE totalselectedpat = i4 WITH protect, noconstant(0)
 DECLARE totalselectedmed = i4 WITH protect, noconstant(0)
 DECLARE totalptscanned = i4 WITH protect, noconstant(0)
 DECLARE totalptselected = i4 WITH protect, noconstant(0)
 DECLARE totalptpercent = f8 WITH protect, noconstant(0.0)
 DECLARE totalmedscanned = i4 WITH protect, noconstant(0)
 DECLARE totalmedselected = i4 WITH protect, noconstant(0)
 DECLARE totalmedpercent = f8 WITH protect, noconstant(0.0)
 DECLARE pttotal = i4 WITH protect, noconstant(0)
 DECLARE medtotal = i4 WITH protect, noconstant(0)
 DECLARE totalptscannedpu = i4 WITH protect, noconstant(0)
 DECLARE totalptselectedpu = i4 WITH protect, noconstant(0)
 DECLARE totalptpercentpu = f8 WITH protect, noconstant(0.0)
 DECLARE totalmedscannedpu = i4 WITH protect, noconstant(0)
 DECLARE totalmedselectedpu = i4 WITH protect, noconstant(0)
 DECLARE totalmedpercentpu = f8 WITH protect, noconstant(0.0)
 DECLARE pttotalpu = i4 WITH protect, noconstant(0)
 DECLARE medtotalpu = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt2 = i4 WITH protect, noconstant(0)
 DECLARE dstat = f8 WITH protect, noconstant(0.00)
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE snurse_units = vc WITH protect, noconstant("")
 DECLARE any_status_ind = c1
 DECLARE indx = i4
 DECLARE nsize = i4
 DECLARE nbucketsize = i4
 DECLARE ntotal = i4
 DECLARE nstart = i4
 DECLARE nbuckets = i4
 SET audit_request->report_name = "BSC_SCAN_COMPLIANCE_REPORT"
 SET audit_request->facility_cd =  $FACILITY
 IF (( $START_DATE="CURDATE"))
  SET audit_request->start_dt_tm = cnvtdatetime(curdate,0)
 ELSE
  SET audit_request->start_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $START_DATE)),0)
 ENDIF
 IF (( $END_DATE="CURDATE"))
  SET audit_request->end_dt_tm = cnvtdatetime(curdate,235959)
 ELSE
  SET audit_request->end_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $END_DATE)),235959)
 ENDIF
 SET any_status_ind = substring(1,1,reflect(parameter(5,0)))
 IF (any_status_ind="C")
  SET nallind = 1
  SELECT INTO "nl:"
   FROM code_value cv,
    nurse_unit n,
    code_value cv1,
    code_value cv2
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="BUILDING"
     AND cv.display_key IN ("BFMC", "BFMCINPTPSYCH", "BMLH", "BMC", "BMCINPTPSYCH",
    "CTRCACARE")
     AND cv.active_ind=1)
    JOIN (n
    WHERE (n.loc_facility_cd= $FACILITY)
     AND n.loc_building_cd=cv.code_value
     AND n.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=n.location_cd
     AND cv1.code_set=220
     AND cv1.active_ind=1
     AND cv1.cdf_meaning IN ("NURSEUNIT", "AMBULATORY"))
    JOIN (cv2
    WHERE cv2.code_value=cv1.data_status_cd
     AND cv2.display_key="AUTHVERIFIED")
   ORDER BY cv1.display
   HEAD REPORT
    lcnt = 0
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
 SET nsize = audit_request->unit_cnt
 SET nbucketsize = 20
 SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
 SET nstart = 1
 SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
 SET stat = alterlist(audit_request->unit,ntotal)
 FOR (j = (nsize+ 1) TO ntotal)
   SET audit_request->unit[j].nurse_unit_cd = audit_request->unit[nsize].nurse_unit_cd
 ENDFOR
 SELECT INTO  $OUT_DEV
  FROM (dummyt d  WITH seq = nbuckets),
   med_admin_event mae,
   prsnl p
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (mae
   WHERE mae.beg_dt_tm >= cnvtdatetime(audit_request->start_dt_tm)
    AND mae.end_dt_tm <= cnvtdatetime(audit_request->end_dt_tm)
    AND  NOT (mae.event_type_cd IN (cnotadministered, cnotgiven, cnotdone))
    AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(mae.nurse_unit_cd+ 0),audit_request->unit[
    indx].nurse_unit_cd)
    AND mae.prsnl_id > 0.00)
   JOIN (p
   WHERE p.person_id=mae.prsnl_id
    AND p.position_cd != 441.00)
  ORDER BY p.name_full_formatted, mae.prsnl_id, uar_get_code_display(mae.nurse_unit_cd),
   mae.nurse_unit_cd
  HEAD REPORT
   posptcompliancetotal = 0, posmedcompliancetotal = 0, ptcompliancetotalevents = 0,
   medcompliancetotalevents = 0, complianceptpercent = 0.0, compliancemedpercent = 0.0,
   totalselectedpat = 0, totalselectedmed = 0
  HEAD PAGE
   IF ( NOT (( $OUT_DEV IN ("MINE"))))
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
    sdisplay = concat("Nurse Units: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd),
      3))
    FOR (lcnt = 2 TO audit_request->unit_cnt)
      sdisplay = concat(sdisplay,", ",trim(uar_get_code_display(audit_request->unit[lcnt].
         nurse_unit_cd),3))
    ENDFOR
   ELSEIF ((audit_request->unit_cnt=1))
    sdisplay = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd),
      3))
   ELSE
    sdisplay = "Nurse Unit: Unknown/Error"
   ENDIF
   col 0, sdisplay
   IF (nallind=0
    AND (audit_request->unit_cnt > 1))
    row + 1
   ENDIF
   CALL center(ctitle,1,131), col 109, "Display per: Date/Time",
   row + 1, col 00, cdashline,
   row + 1, col 00, "Legend",
   col 07, "(Pos = Position)", row + 1,
   col 00, "User", col 37,
   "Nurse", col 63, "Scan",
   col 74, "Select", col 85,
   "Patient", col 96, "Scan",
   col 107, "Select", col 118,
   "Med", row + 1, col 00,
   "Name", col 26, "Pos",
   col 37, "Unit", col 63,
   "Pts", col 74, "Pts",
   col 85, "Compl", col 96,
   "Meds", col 107, "Meds",
   col 118, "Compl", row + 1,
   col 00, ctotal_line, row + 1
  HEAD mae.prsnl_id
   lcnt = 0, totalptscannedpu = 0, totalptselectedpu = 0,
   totalptpercentpu = 0.0, totalmedscannedpu = 0, totalmedselectedpu = 0,
   totalmedpercentpu = 0.0, pttotalpu = 0, medtotalpu = 0
  HEAD mae.nurse_unit_cd
   lcnt = (lcnt+ 1)
   IF (row=42)
    BREAK
   ENDIF
   totalptscanned = 0, totalptselected = 0, totalptpercent = 0.0,
   totalmedscanned = 0, totalmedselected = 0, totalmedpercent = 0.0,
   pttotal = 0, medtotal = 0, nurseunit = "",
   position = ""
  HEAD mae.med_admin_event_id
   IF (row=42)
    BREAK
   ENDIF
   IF (mae.event_id != 0)
    medtotal = (medtotal+ 1.0)
    IF (mae.positive_med_ident_ind=1)
     totalmedscanned = (totalmedscanned+ 1.0)
    ELSE
     totalmedselected = (totalmedselected+ 1.0)
    ENDIF
   ENDIF
   pttotal = (pttotal+ 1.0)
   IF (mae.positive_patient_ident_ind=1)
    totalptscanned = (totalptscanned+ 1.0)
   ELSE
    totalptselected = (totalptselected+ 1.0)
   ENDIF
  DETAIL
   col + 0
  FOOT  mae.med_admin_event_id
   col + 0
  FOOT  mae.nurse_unit_cd
   pttotalpu = (pttotal+ pttotalpu), medtotalpu = (medtotal+ medtotalpu), totalptscannedpu = (
   totalptscannedpu+ totalptscanned),
   totalmedscannedpu = (totalmedscannedpu+ totalmedscanned), totalptselectedpu = (totalptselectedpu+
   totalptselected), totalmedselectedpu = (totalmedselectedpu+ totalmedselected),
   nurseunit = trim(replace(uar_get_code_display(mae.nurse_unit_cd),","," ",0),3), position = trim(
    replace(uar_get_code_display(mae.position_cd),","," ",0),3), totalptpercent = ((cnvtreal(
    totalptscanned)/ cnvtreal(pttotal)) * 100.00),
   totalmedpercent = ((cnvtreal(totalmedscanned)/ cnvtreal(medtotal)) * 100.00), username = trim(p
    .name_full_formatted,3), sdisplay = substring(1,25,username),
   col 00, sdisplay, sdisplay = substring(1,10,position),
   col 26, sdisplay, sdisplay = substring(1,25,nurseunit),
   col 37, sdisplay, sdisplay = trim(build2(totalptscanned),3),
   col 63, sdisplay, sdisplay = trim(build2(totalptselected),3),
   col 74, sdisplay, sdisplay = trim(build2(totalptpercent,"%"),3),
   col 85, sdisplay, sdisplay = trim(build2(totalmedscanned),3),
   col 96, sdisplay, sdisplay = trim(build2(totalmedselected),3),
   col 107, sdisplay, sdisplay = trim(build2(totalmedpercent,"%"),3),
   col 118, sdisplay, row + 1
  FOOT  mae.prsnl_id
   ptcompliancetotalevents = (pttotalpu+ ptcompliancetotalevents), medcompliancetotalevents = (
   medtotalpu+ medcompliancetotalevents), posptcompliancetotal = (posptcompliancetotal+
   totalptscannedpu),
   posmedcompliancetotal = (posmedcompliancetotal+ totalmedscannedpu), totalptpercentpu = ((cnvtreal(
    totalptscannedpu)/ cnvtreal(pttotalpu)) * 100.00), totalmedpercentpu = ((cnvtreal(
    totalmedscannedpu)/ cnvtreal(medtotalpu)) * 100.00)
   IF (lcnt > 1)
    sdisplay = substring(1,25,username), col 00, sdisplay,
    sdisplay = substring(1,10,position), col 26, sdisplay,
    sdisplay = "Total--------------------", col 37, sdisplay,
    sdisplay = trim(build2(totalptscannedpu),3), col 63, sdisplay,
    sdisplay = trim(build2(totalptselectedpu),3), col 74, sdisplay,
    sdisplay = trim(build2(totalptpercentpu,"%"),3), col 85, sdisplay,
    sdisplay = trim(build2(totalmedscannedpu),3), col 96, sdisplay,
    sdisplay = trim(build2(totalmedselectedpu),3), col 107, sdisplay,
    sdisplay = trim(build2(totalmedpercentpu,"%"),3), col 118, sdisplay,
    row + 1
   ENDIF
  FOOT PAGE
   col 0, "Page:", col + 2,
   curpage
  FOOT REPORT
   complianceptpercent = ((cnvtreal(posptcompliancetotal)/ cnvtreal(ptcompliancetotalevents)) *
   100.00), compliancemedpercent = ((cnvtreal(posmedcompliancetotal)/ cnvtreal(
    medcompliancetotalevents)) * 100.00), totalselectedpat = (ptcompliancetotalevents -
   posptcompliancetotal),
   totalselectedmed = (medcompliancetotalevents - posmedcompliancetotal), row + 1, col 00,
   "Totals/Averages:", sdisplay = trim(build2(posptcompliancetotal),3), col 63,
   sdisplay, sdisplay = trim(build2(totalselectedpat),3), col 74,
   sdisplay, sdisplay = trim(build2(complianceptpercent,"%"),3), col 85,
   sdisplay, sdisplay = trim(build2(posmedcompliancetotal),3), col 96,
   sdisplay, sdisplay = trim(build2(totalselectedmed),3), col 107,
   sdisplay, sdisplay = trim(build2(compliancemedpercent,"%"),3), col 118,
   sdisplay
  WITH nocounter, dio = postscript, maxrow = 45
 ;end select
 FREE RECORD audit_request
END GO
