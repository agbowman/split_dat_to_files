CREATE PROGRAM bhs_patmm_audit_detail:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Starting date(mm/dd/yyyy):" = "CURDATE",
  "Ending date(mm/dd/yyyy):" = "CURDATE",
  "Facility:" = 0,
  "Nurse unit(s):" = 0,
  "Display per:" = 2
  WITH out_dev, start_date, end_date,
  facility, nurse_unit, display_type
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
 DECLARE ctitle = vc WITH protect, constant("Point of Care Audit Patient Mismatch Report")
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(130,"-"))
 DECLARE coutput = vc WITH protect, noconstant(concat("patmismtch",cnvtstring(cnvtdatetime(curdate,
     curtime3)),".csv"))
 DECLARE cpatmismatch = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"PATMISMATCH"))
 DECLARE cpatmrn = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE from_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE to_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE last_mod = vc WITH protect, noconstant("")
 DECLARE mod_date = vc WITH protect, noconstant("")
 DECLARE expectedname = vc WITH protect, noconstant("")
 DECLARE identifiedname = vc WITH protect, noconstant("")
 DECLARE alert = vc WITH protect, noconstant("")
 DECLARE username = vc WITH protect, noconstant("")
 DECLARE position = vc WITH protect, noconstant("")
 DECLARE nurseunit = vc WITH protect, noconstant("")
 DECLARE expectedmrn = vc WITH protect, noconstant("")
 DECLARE identifiedmrn = vc WITH protect, noconstant("")
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE dstat = f8 WITH protect, noconstant(0.00)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt2 = i4 WITH protect, noconstant(0)
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE any_status_ind = c1
 DECLARE indx = i4
 DECLARE nsize = i4
 DECLARE nbucketsize = i4
 DECLARE ntotal = i4
 DECLARE nstart = i4
 DECLARE nbuckets = i4
 SET audit_request->report_name = "BSC_PATMISMATCH_AUDIT_DETAIL"
 SET audit_request->display_ind =  $DISPLAY_TYPE
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
     AND cv.display_key IN ("BFMC", "BFMCINPTPSYCH", "BMLH", "BMC", "BMCINPTPSYCH")
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
     AND cv2.display_key="AUTHVERifIED")
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
 IF ((audit_request->display_ind=2))
  SELECT INTO  $OUT_DEV
   FROM (dummyt d  WITH seq = nbuckets),
    med_admin_alert maa,
    med_admin_pt_error mape,
    prsnl p,
    person pers1,
    person pers2,
    person_alias pa,
    person_alias pa1,
    dummyt d1,
    dummyt d2
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.alert_type_cd=cpatmismatch
     AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(maa.nurse_unit_cd+ 0),audit_request->unit[
     indx].nurse_unit_cd)
     AND ((maa.prsnl_id+ 0) != 1))
    JOIN (p
    WHERE p.person_id=maa.prsnl_id)
    JOIN (mape
    WHERE mape.med_admin_alert_id=maa.med_admin_alert_id)
    JOIN (pers1
    WHERE pers1.person_id=mape.expected_pt_id)
    JOIN (d1)
    JOIN (pa
    WHERE pa.person_id=pers1.person_id
     AND pa.person_alias_type_cd=cpatmrn)
    JOIN (pers2
    WHERE pers2.person_id=mape.identified_pt_id)
    JOIN (d2)
    JOIN (pa1
    WHERE pa1.person_id=pers2.person_id
     AND pa1.person_alias_type_cd=cpatmrn)
   ORDER BY pers1.name_last_key, pers1.name_first_key, pers1.person_id,
    cnvtdatetime(maa.event_dt_tm), maa.prsnl_id
   HEAD REPORT
    null
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
    row + 1, sdisplay = concat("facility: ",trim(uar_get_code_display( $FACILITY),3)), col 0,
    sdisplay, col 96, "Run Date: ",
    curdate"mm/dd/yyyy;;d", " Time: ", curtime"hh:mm;;s",
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
    col 0, sdisplay
    IF (nallind=0
     AND (audit_request->unit_cnt > 1))
     row + 1
    ENDIF
    CALL center(ctitle,1,131), col 102, "Display per: Expected Patient",
    row + 1, col 0, cdashline,
    row + 1, col 0, "Legend",
    col 07, "(Pos = Position)", row + 1,
    totalalert = 0, col 0, "Alert",
    col 15, "Expected", col 36,
    "Expected", col 52, "Nurse",
    col 68, "Identified", col 89,
    "Identified", col 105, "User",
    row + 1, col 0, "date/time",
    col 15, "Patient Name", col 36,
    "MRN", col 52, "Unit",
    col 68, "Patient Name", col 89,
    "MRN", col 105, "Name",
    col 125, "Pos", row + 1,
    col 0, ctotal_line, row + 1
   HEAD mape.med_admin_pt_error_id
    null
   DETAIL
    x = 0
   FOOT  mape.med_admin_pt_error_id
    IF (row=42)
     BREAK
    ENDIF
    expectedname = "", identifiedname = "", alert = "",
    username = "", position = "", nurseunit = "",
    expectedmrn = "", identifiedmrn = "", totalalert = (totalalert+ 1),
    alert = uar_get_code_display(maa.alert_type_cd), alert_time = format(maa.event_dt_tm,
     "mm/dd/yy hh:mm"), expectedname = trim(replace(pers1.name_full_formatted,",","-",0),3),
    identifiedname = trim(replace(pers2.name_full_formatted,",","-",0),3), username = trim(replace(p
      .name_full_formatted,",","-",0),3), position = uar_get_code_display(maa.position_cd),
    nurseunit = trim(replace(uar_get_code_display(maa.nurse_unit_cd),","," ",0),3), expectedmrn =
    cnvtalias(pa.alias,pa.alias_pool_cd), identifiedmrn = cnvtalias(pa1.alias,pa1.alias_pool_cd),
    sdisplay = substring(1,14,alert_time), col 0, sdisplay,
    sdisplay = substring(1,20,expectedname), col 15, sdisplay,
    sdisplay = substring(1,15,expectedmrn), col 36, sdisplay,
    sdisplay = substring(1,15,nurseunit), col 52, sdisplay,
    sdisplay = substring(1,20,identifiedname), col 68, sdisplay,
    sdisplay = substring(1,15,identifiedmrn), col 89, sdisplay,
    sdisplay = substring(1,19,username), col 105, sdisplay,
    sdisplay = substring(1,5,position), col 125, sdisplay,
    row + 1
   FOOT PAGE
    col 0, "Page:", col + 2,
    curpage
   FOOT REPORT
    row + 1, col 0, "Total Alerts: ",
    col + 2, totalalert, row + 1
   WITH nocounter, outerjoin = d1, outerjoin = d2,
    dio = postscript, maxrow = 45
  ;end select
 ELSEIF ((audit_request->display_ind=0))
  SELECT INTO  $OUT_DEV
   FROM (dummyt d  WITH seq = nbuckets),
    med_admin_alert maa,
    med_admin_pt_error mape,
    prsnl p,
    person pers1,
    person pers2,
    person_alias pa,
    person_alias pa1,
    dummyt d1,
    dummyt d2
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.alert_type_cd=cpatmismatch
     AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(maa.nurse_unit_cd+ 0),audit_request->unit[
     indx].nurse_unit_cd)
     AND ((maa.prsnl_id+ 0) != 1))
    JOIN (p
    WHERE p.person_id=maa.prsnl_id)
    JOIN (mape
    WHERE mape.med_admin_alert_id=maa.med_admin_alert_id)
    JOIN (pers1
    WHERE pers1.person_id=mape.expected_pt_id)
    JOIN (d1)
    JOIN (pa
    WHERE pa.person_id=pers1.person_id
     AND pa.person_alias_type_cd=cpatmrn)
    JOIN (pers2
    WHERE pers2.person_id=mape.identified_pt_id)
    JOIN (d2)
    JOIN (pa1
    WHERE pa1.person_id=pers2.person_id
     AND pa1.person_alias_type_cd=cpatmrn)
   ORDER BY p.name_last_key, p.name_first_key, p.person_id,
    cnvtdatetime(maa.event_dt_tm), maa.prsnl_id
   HEAD REPORT
    null
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
    col 0, sdisplay
    IF (nallind=0
     AND (audit_request->unit_cnt > 1))
     row + 1
    ENDIF
    CALL center(ctitle,1,131), col 114, "Display per: User",
    row + 1, col 0, cdashline,
    row + 1, col 0, "Legend",
    col 07, "(Pos = Position)", row + 1,
    totalalert = 0, col 0, "User",
    col 20, "Alert", col 35,
    "Expected", col 56, "Expected",
    col 72, "Nurse", col 88,
    "Identified", col 109, "Identified",
    row + 1, col 0, "Name",
    col 20, "date/time", col 35,
    "Patient Name", col 56, "MRN",
    col 72, "Unit", col 88,
    "Patient Name", col 109, "MRN",
    col 125, "Pos", row + 1,
    col 0, ctotal_line, row + 1
   HEAD mape.med_admin_pt_error_id
    null
   DETAIL
    x = 0
   FOOT  mape.med_admin_pt_error_id
    IF (row=42)
     BREAK
    ENDIF
    expectedname = "", identifiedname = "", alert = "",
    username = "", position = "", nurseunit = "",
    expectedmrn = "", identifiedmrn = "", totalalert = (totalalert+ 1),
    alert = uar_get_code_display(maa.alert_type_cd), alert_time = format(maa.event_dt_tm,
     "mm/dd/yy hh:mm"), expectedname = trim(replace(pers1.name_full_formatted,",","-",0),3),
    identifiedname = trim(replace(pers2.name_full_formatted,",","-",0),3), username = trim(replace(p
      .name_full_formatted,",","-",0),3), position = uar_get_code_display(maa.position_cd),
    nurseunit = trim(replace(uar_get_code_display(maa.nurse_unit_cd),","," ",0),3), expectedmrn =
    cnvtalias(pa.alias,pa.alias_pool_cd), identifiedmrn = cnvtalias(pa1.alias,pa1.alias_pool_cd),
    sdisplay = substring(1,19,username), col 0, sdisplay,
    sdisplay = substring(1,14,alert_time), col 20, sdisplay,
    sdisplay = substring(1,20,expectedname), col 35, sdisplay,
    sdisplay = substring(1,15,expectedmrn), col 56, sdisplay,
    sdisplay = substring(1,15,nurseunit), col 72, sdisplay,
    sdisplay = substring(1,20,identifiedname), col 88, sdisplay,
    sdisplay = substring(1,15,identifiedmrn), col 109, sdisplay,
    sdisplay = substring(1,5,position), col 125, sdisplay,
    row + 1
   FOOT PAGE
    col 0, "Page:", col + 2,
    curpage
   FOOT REPORT
    row + 1, col 0, "Total Alerts: ",
    col + 2, totalalert, row + 1
   WITH nocounter, outerjoin = d1, outerjoin = d2,
    dio = postscript, maxrow = 45
  ;end select
 ELSEIF ((audit_request->display_ind=1))
  SELECT INTO  $OUT_DEV
   FROM (dummyt d  WITH seq = nbuckets),
    med_admin_alert maa,
    med_admin_pt_error mape,
    prsnl p,
    person pers1,
    person pers2,
    person_alias pa,
    person_alias pa1,
    dummyt d1,
    dummyt d2
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.alert_type_cd=cpatmismatch
     AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(maa.nurse_unit_cd+ 0),audit_request->unit[
     indx].nurse_unit_cd)
     AND maa.prsnl_id != 1)
    JOIN (p
    WHERE p.person_id=maa.prsnl_id)
    JOIN (mape
    WHERE mape.med_admin_alert_id=maa.med_admin_alert_id)
    JOIN (pers1
    WHERE pers1.person_id=mape.expected_pt_id)
    JOIN (d1)
    JOIN (pa
    WHERE pa.person_id=pers1.person_id
     AND pa.person_alias_type_cd=cpatmrn)
    JOIN (pers2
    WHERE pers2.person_id=mape.identified_pt_id)
    JOIN (d2)
    JOIN (pa1
    WHERE pa1.person_id=pers2.person_id
     AND pa1.person_alias_type_cd=cpatmrn)
   ORDER BY cnvtdatetime(maa.event_dt_tm), maa.prsnl_id
   HEAD REPORT
    col + 0
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
    col 0, sdisplay
    IF (nallind=0
     AND (audit_request->unit_cnt > 1))
     row + 1
    ENDIF
    CALL center(ctitle,1,131), col 109, "Display per: Date/Time",
    row + 1, col 0, cdashline,
    row + 1, col 0, "Legend",
    col 07, "(Pos = Position)", row + 1,
    totalalert = 0, col 0, "Alert",
    col 15, "Expected", col 36,
    "Expected", col 52, "Nurse",
    col 68, "Identified", col 89,
    "Identified", col 105, "User",
    row + 1, col 0, "date/time",
    col 15, "Patient Name", col 36,
    "MRN", col 52, "Unit",
    col 68, "Patient Name", col 89,
    "MRN", col 105, "Name",
    col 125, "Pos", row + 1,
    col 0, ctotal_line, row + 1
   HEAD mape.med_admin_pt_error_id
    null
   DETAIL
    x = 0
   FOOT  mape.med_admin_pt_error_id
    IF (row=42)
     BREAK
    ENDIF
    expectedname = "", identifiedname = "", alert = "",
    username = "", position = "", nurseunit = "",
    expectedmrn = "", identifiedmrn = "", totalalert = (totalalert+ 1),
    alert = uar_get_code_display(maa.alert_type_cd), alert_time = format(maa.event_dt_tm,
     "mm/dd/yy hh:mm"), expectedname = trim(replace(pers1.name_full_formatted,",","-",0),3),
    identifiedname = trim(replace(pers2.name_full_formatted,",","-",0),3), username = trim(replace(p
      .name_full_formatted,",","-",0),3), position = uar_get_code_display(maa.position_cd),
    nurseunit = trim(replace(uar_get_code_display(maa.nurse_unit_cd),","," ",0),3), expectedmrn =
    cnvtalias(pa.alias,pa.alias_pool_cd), identifiedmrn = cnvtalias(pa1.alias,pa1.alias_pool_cd),
    sdisplay = substring(1,14,alert_time), col 0, sdisplay,
    sdisplay = substring(1,20,expectedname), col 15, sdisplay,
    sdisplay = substring(1,15,expectedmrn), col 36, sdisplay,
    sdisplay = substring(1,15,nurseunit), col 52, sdisplay,
    sdisplay = substring(1,20,identifiedname), col 68, sdisplay,
    sdisplay = substring(1,15,identifiedmrn), col 89, sdisplay,
    sdisplay = substring(1,19,username), col 105, sdisplay,
    sdisplay = substring(1,5,position), col 125, sdisplay,
    row + 1
   FOOT PAGE
    col 0, "Page:", col + 2,
    curpage
   FOOT REPORT
    row + 1, col 0, "Total Alerts: ",
    col + 2, totalalert, row + 1
   WITH nocounter, outerjoin = d1, outerjoin = d2,
    dio = postscript, maxrow = 45
  ;end select
 ENDIF
 FREE RECORD audit_request
END GO
