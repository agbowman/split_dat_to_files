CREATE PROGRAM bsc_scan_compliance
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date:" = "CURDATE",
  "Ending date:" = "CURDATE",
  "Facility:" = 0,
  "Nurse_unit(s):" = 0,
  "Display per:" = 0
  WITH out_dev, start_date, end_date,
  facility, nurse_unit, display_type
 SET modify = predeclare
 DECLARE butcind = i2 WITH protect, constant(curutc)
 DECLARE ctime_zone_format = vc WITH protect, constant("ZZZ")
 DECLARE parsezeroes(passfieldin=f8) = vc
 DECLARE formatutcdatetime(sdatetime=vc,ltzindex=i4,bshowtz=i2) = vc
 DECLARE formatlabelbylength(slabel=vc,lmaxlen=i4) = vc
 DECLARE formatstrength(dstrength=f8) = vc
 DECLARE formatvolume(dvolume=f8) = vc
 DECLARE formatrate(drate=f8) = vc
 DECLARE formatpercentwithdecimal(dpercent=f8) = vc
 SUBROUTINE parsezeroes(pass_field_in)
   DECLARE dsvalue = c16 WITH noconstant(fillstring(16," "))
   DECLARE move_fld = c16 WITH noconstant(fillstring(16," "))
   DECLARE strfld = c16 WITH noconstant(fillstring(16," "))
   DECLARE sig_dig = i4 WITH noconstant(0)
   DECLARE sig_dec = i4 WITH noconstant(0)
   DECLARE str_cnt = i4 WITH noconstant(1)
   DECLARE len = i4 WITH noconstant(0)
   SET strfld = cnvtstring(pass_field_in,16,4,r)
   WHILE (str_cnt < 12
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt = (str_cnt+ 1)
   ENDWHILE
   SET sig_dig = (str_cnt - 1)
   SET str_cnt = 16
   WHILE (str_cnt > 12
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt = (str_cnt - 1)
   ENDWHILE
   IF (str_cnt=12
    AND substring(str_cnt,1,strfld)=".")
    SET str_cnt = (str_cnt - 1)
   ENDIF
   SET sig_dec = str_cnt
   IF (sig_dig=11
    AND sig_dec=11)
    SET dsvalue = ""
   ELSE
    SET len = movestring(strfld,(sig_dig+ 1),move_fld,1,(sig_dec - sig_dig))
    SET dsvalue = trim(move_fld)
    IF (substring(1,1,dsvalue)=".")
     SET dsvalue = concat("0",trim(move_fld))
    ENDIF
   ENDIF
   RETURN(dsvalue)
 END ;Subroutine
 SUBROUTINE formatutcdatetime(sdatetime,ltzindex,bshowtz)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewdatetime = vc WITH protect, noconstant(" ")
   IF (ltzindex > 0)
    SET lnewindex = ltzindex
   ENDIF
   SET snewdatetime = datetimezoneformat(sdatetime,lnewindex,"@SHORTDATE")
   IF (size(trim(snewdatetime)) > 0)
    SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
      "@TIMENOSECONDS"))
    IF (butcind=1
     AND bshowtz=1)
     SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
       ctime_zone_format))
    ENDIF
   ENDIF
   SET snewdatetime = trim(snewdatetime)
   RETURN(snewdatetime)
 END ;Subroutine
 SUBROUTINE formatlabelbylength(slabel,lmaxlen)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = trim(slabel,3)
   IF (size(snewlabel) > 0
    AND lmaxlen > 0)
    IF (lmaxlen < 4)
     SET snewlabel = substring(1,lmaxlen,snewlabel)
    ELSEIF (size(snewlabel) > lmaxlen)
     SET snewlabel = concat(substring(1,(lmaxlen - 3),snewlabel),"...")
    ENDIF
   ENDIF
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE formatstrength(dstrength)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dstrength,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE formatvolume(dvolume)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dvolume,"######.##;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE formatrate(drate)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(drate,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE formatpercentwithdecimal(dpercent)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(format(dpercent,"###.##;I;F"))
   RETURN(snewlabel)
 END ;Subroutine
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE i18n_sdaterange = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DATE_RANGE","Date Range"),3))
 DECLARE i18n_spage = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PAGE","Page"
    ),3))
 DECLARE i18n_sfacility = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_FACILITY","Facility"),3))
 DECLARE i18n_srundatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_RUN_DATE","Run Date/Time"),3))
 DECLARE i18n_snurseunit = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NURSE_UNIT","Nurse Unit"),3))
 DECLARE i18n_snurseunits = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NURSE_UNITS","Nurse Units"),3))
 DECLARE i18n_sall = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ALL","All"),3
   ))
 DECLARE i18n_sunknownerror = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_UNKNOWN_ERROR","Unknown/Error"),3))
 DECLARE i18n_stitle = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TITLE",
    "Point of Care Audit Scan Compliance Report"),3))
 DECLARE i18n_sdisplayper = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DISPLAY_PER","Display per"),3))
 DECLARE i18n_slegend = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_LEGEND",
    "Legend"),3))
 DECLARE i18n_spos = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_POS","Pos"),3
   ))
 DECLARE i18n_sposition = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_POSITION","Position"),3))
 DECLARE i18n_suser = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_USER","User"
    ),3))
 DECLARE i18n_snurse = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NURSE",
    "Nurse"),3))
 DECLARE i18n_sscanned = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_SCANNED",
    "Scanned"),3))
 DECLARE i18n_sselected = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_SELECTED","Selected"),3))
 DECLARE i18n_spatient = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PATIENT",
    "Patient"),3))
 DECLARE i18n_smed = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MED","Med"),3
   ))
 DECLARE i18n_sname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NAME","Name"
    ),3))
 DECLARE i18n_sunit = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_UNIT","Unit"
    ),3))
 DECLARE i18n_spts = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PTS","Pts"),3
   ))
 DECLARE i18n_scompl = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_COMPL",
    "Compl"),3))
 DECLARE i18n_smeds = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MEDS","Meds"
    ),3))
 DECLARE i18n_stotal = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TOTAL",
    "Total"),3))
 DECLARE i18n_stotalsaverages = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_TOTALS_AVERAGES","Totals/Averages"),3))
 DECLARE i18n_snoresultsqualified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_RESULTS_QUALIFIED","No Results Qualified"),3))
 DECLARE i18n_sreport = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_REPORT",
    "Report"),3))
 DECLARE i18n_scompliance = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_COMPLIANCE","Compliance %"),3))
 DECLARE i18n_smedication = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MEDICATION","Medication"),3))
 DECLARE i18n_sfrom = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_FROM","From"
    ),3))
 DECLARE i18n_sto = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TO","To"),3))
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
 DECLARE llastcolumn = i4 WITH protect, constant(131)
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(130,"-"))
 DECLARE cnotdone = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE cnotgiven = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"NOTGIVEN"))
 DECLARE cchild = f8 WITH protect, constant(uar_get_code_by("MEANING",24,"CHILD"))
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
 DECLARE lnurse_units_length = i4 WITH protect, noconstant(0)
 DECLARE lmin_col_length = i4 WITH protect, noconstant(2000)
 DECLARE dstat = f8 WITH protect, noconstant(0.00)
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE snue_clause = vc WITH protect, noconstant("1=1")
 DECLARE snurse_units = vc WITH protect, noconstant("")
 DECLARE cnotadministred = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"TASKPURGED"))
 DECLARE coutput = vc WITH protect, noconstant(concat("scancomprpt",cnvtstring(cnvtdatetime(curdate,
     curtime3)),".csv"))
 SET audit_request->report_name = "BSC_SCAN_COMPLIANCE_REPORT"
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
 SET audit_request->facility_cd =  $FACILITY
 IF (substring(1,1,reflect(parameter(5,0)))="I")
  IF (( $NURSE_UNIT=0))
   SET nallind = 1
  ENDIF
 ELSEIF (substring(1,1,reflect(parameter(5,0)))="C")
  IF (( $NURSE_UNIT="*"))
   SET nallind = 1
  ENDIF
 ENDIF
 IF (nallind=1
  AND ( $FACILITY > 0))
  SELECT INTO "nl:"
   FROM code_value cv,
    location_group lg1,
    location_group lg2
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
     AND cv.active_ind=1)
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
     dstat = alterlist(audit_request->unit,(lcnt+ 9))
    ENDIF
    audit_request->unit[lcnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    dstat = alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
   WITH nocounter
  ;end select
  SET lcnt2 = 0
  WHILE (lcnt2 < lcnt)
    SET lcnt2 = (lcnt2+ 1)
    IF (lcnt2=1)
     SET snue_clause = build("mae.nurse_unit_cd in(",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = uar_get_code_display(audit_request->unit[lcnt2].nurse_unit_cd)
    ELSE
     SET snue_clause = build(snue_clause,",",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = build(snurse_units,"/",uar_get_code_display(audit_request->unit[lcnt2].
       nurse_unit_cd))
    ENDIF
    IF (lcnt2=lcnt)
     SET snue_clause = build(snue_clause,")")
    ENDIF
  ENDWHILE
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
     dstat = alterlist(audit_request->unit,(lcnt+ 9))
    ENDIF
    audit_request->unit[lcnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    dstat = alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
   WITH nocounter
  ;end select
  SET lcnt2 = 0
  WHILE (lcnt2 < lcnt)
    SET lcnt2 = (lcnt2+ 1)
    IF (lcnt2=1)
     SET snue_clause = build("mae.nurse_unit_cd in(",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = uar_get_code_display(audit_request->unit[lcnt2].nurse_unit_cd)
    ELSE
     SET snue_clause = build(snue_clause,",",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = build(snurse_units,"/",uar_get_code_display(audit_request->unit[lcnt2].
       nurse_unit_cd))
    ENDIF
    IF (lcnt2=lcnt)
     SET snue_clause = build(snue_clause,")")
    ENDIF
  ENDWHILE
 ENDIF
 SET audit_request->display_ind =  $DISPLAY_TYPE
 IF ((audit_request->display_ind=0))
  SELECT INTO  $OUT_DEV
   FROM med_admin_event mae,
    clinical_event ce,
    prsnl p
   PLAN (mae
    WHERE mae.med_admin_event_id > 0
     AND mae.beg_dt_tm >= cnvtdatetime(audit_request->start_dt_tm)
     AND mae.end_dt_tm <= cnvtdatetime(audit_request->end_dt_tm)
     AND mae.nurse_unit_cd > 0.00
     AND mae.event_type_cd != cnotadministred
     AND mae.event_type_cd != cnotgiven
     AND parser(snue_clause))
    JOIN (p
    WHERE p.person_id=mae.prsnl_id)
    JOIN (ce
    WHERE ce.event_reltn_cd=cchild
     AND ce.result_status_cd != cnotdone
     AND ((mae.event_id=ce.parent_event_id) OR (mae.event_id=ce.event_id))
     AND mae.event_type_cd > 0.00)
   ORDER BY p.name_full_formatted, mae.prsnl_id, uar_get_code_display(mae.nurse_unit_cd),
    mae.nurse_unit_cd, mae.med_admin_event_id
   HEAD REPORT
    posptcompliancetotal = 0, posmedcompliancetotal = 0, ptcompliancetotalevents = 0,
    medcompliancetotalevents = 0, complianceptpercent = 0.0, compliancemedpercent = 0.0,
    totalselectedpat = 0, totalselectedmed = 0
   HEAD PAGE
    IF ( NOT (( $OUT_DEV IN ("MINE"))))
     col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
    ENDIF
    CALL center(i18n_stitle,1,llastcolumn), row + 1, sdisplay = concat(i18n_sdaterange,":"),
    col 00, sdisplay, lprintpos = (size(sdisplay)+ 1),
    sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"@SHORTDATE;;Q")
    ENDIF
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"@SHORTDATE;;Q"))
    ENDIF
    IF (textlen(sdisplay) > 0)
     col lprintpos, sdisplay
    ENDIF
    sdisplay = concat(i18n_spage,": ",cnvtstring(curpage)), lprintpos = (llastcolumn - size(sdisplay)
    ), col lprintpos,
    sdisplay, row + 1, sdisplay = concat(i18n_sfacility,": ",trim(uar_get_code_display(cnvtreal(
         $FACILITY)),3)),
    col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATE;;Q")," ",format(cnvtdatetime(curdate,curtime3),"@TIMENOSECONDS")),
    lprintpos = (llastcolumn - size(sdisplay)), col lprintpos, sdisplay,
    row + 1, sdisplay = concat(i18n_sdisplayper,": ",i18n_sreport), lprintpos = (llastcolumn - size(
     sdisplay)),
    col lprintpos, sdisplay, lnewline = (lprintpos - 20),
    sdisplay = ""
    IF (nallind=1)
     sdisplay = concat(i18n_snurseunits,": ",i18n_sall), col 00, sdisplay
    ELSEIF ((audit_request->unit_cnt > 1))
     sdisplay = concat(i18n_snurseunits,": ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3),","), col 00, sdisplay,
     lprintpos = (size(sdisplay)+ 1)
     IF (lprintpos > lnewline)
      row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
     ENDIF
     FOR (lcnt = 2 TO audit_request->unit_cnt)
       sdisplay = trim(uar_get_code_display(audit_request->unit[lcnt].nurse_unit_cd),3)
       IF ((lcnt != audit_request->unit_cnt))
        sdisplay = concat(sdisplay,",")
       ENDIF
       IF (((lprintpos+ size(sdisplay)) > lnewline))
        row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
       ENDIF
       col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1)
     ENDFOR
    ELSEIF ((audit_request->unit_cnt=1))
     sdisplay = concat(i18n_snurseunit,": ",trim(uar_get_code_display(audit_request->unit[1].
        nurse_unit_cd),3)), col 00, sdisplay
    ELSE
     sdisplay = concat(i18n_snurseunits,": ",i18n_sunknownerror), col 00, sdisplay
    ENDIF
    row + 1, col 00, cdashline,
    row + 1, sdisplay = concat(i18n_slegend," (",i18n_spos," = ",i18n_sposition,
     ")"), col 00,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_suser,25),
    col 00, sdisplay, sdisplay = formatlabelbylength(i18n_snurse,25),
    col 37, sdisplay, sdisplay = formatlabelbylength(i18n_sscanned,10),
    col 63, sdisplay, sdisplay = formatlabelbylength(i18n_sselected,10),
    col 74, sdisplay, sdisplay = formatlabelbylength(i18n_spatient,10),
    col 85, sdisplay, sdisplay = formatlabelbylength(i18n_sscanned,10),
    col 96, sdisplay, sdisplay = formatlabelbylength(i18n_sselected,10),
    col 107, sdisplay, sdisplay = formatlabelbylength(i18n_smed,10),
    col 118, sdisplay, row + 1,
    sdisplay = formatlabelbylength(i18n_sname,25), col 00, sdisplay,
    sdisplay = formatlabelbylength(i18n_spos,10), col 26, sdisplay,
    sdisplay = formatlabelbylength(i18n_sunit,25), col 37, sdisplay,
    sdisplay = formatlabelbylength(i18n_spts,10), col 63, sdisplay,
    sdisplay = formatlabelbylength(i18n_spts,10), col 74, sdisplay,
    sdisplay = formatlabelbylength(i18n_scompl,10), col 85, sdisplay,
    sdisplay = formatlabelbylength(i18n_smeds,10), col 96, sdisplay,
    sdisplay = formatlabelbylength(i18n_smeds,10), col 107, sdisplay,
    sdisplay = formatlabelbylength(i18n_scompl,10), col 118, sdisplay,
    row + 1, col 00, ctotal_line,
    row + 1
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
    totalmedscannedpu = (totalmedscannedpu+ totalmedscanned), totalptselectedpu = (totalptselectedpu
    + totalptselected), totalmedselectedpu = (totalmedselectedpu+ totalmedselected),
    nurseunit = trim(replace(uar_get_code_display(mae.nurse_unit_cd),","," ",0),3), position = trim(
     replace(uar_get_code_display(mae.position_cd),","," ",0),3), totalptpercent = ((cnvtreal(
     totalptscanned)/ cnvtreal(pttotal)) * 100.00),
    totalmedpercent = ((cnvtreal(totalmedscanned)/ cnvtreal(medtotal)) * 100.00), username = trim(p
     .name_full_formatted,3), sdisplay = formatlabelbylength(username,25),
    col 00, sdisplay, sdisplay = formatlabelbylength(position,10),
    col 26, sdisplay, sdisplay = formatlabelbylength(nurseunit,25),
    col 37, sdisplay, sdisplay = trim(build2(totalptscanned),3),
    col 63, sdisplay, sdisplay = trim(build2(totalptselected),3),
    col 74, sdisplay, sdisplay = formatpercentwithdecimal(totalptpercent),
    sdisplay = build2(sdisplay,"%"), col 85, sdisplay,
    sdisplay = trim(build2(totalmedscanned),3), col 96, sdisplay,
    sdisplay = trim(build2(totalmedselected),3), col 107, sdisplay,
    sdisplay = formatpercentwithdecimal(totalmedpercent), sdisplay = build2(sdisplay,"%"), col 118,
    sdisplay, row + 1
   FOOT  mae.prsnl_id
    ptcompliancetotalevents = (pttotalpu+ ptcompliancetotalevents), medcompliancetotalevents = (
    medtotalpu+ medcompliancetotalevents), posptcompliancetotal = (posptcompliancetotal+
    totalptscannedpu),
    posmedcompliancetotal = (posmedcompliancetotal+ totalmedscannedpu), totalptpercentpu = ((cnvtreal
    (totalptscannedpu)/ cnvtreal(pttotalpu)) * 100.00), totalmedpercentpu = ((cnvtreal(
     totalmedscannedpu)/ cnvtreal(medtotalpu)) * 100.00)
    IF (lcnt > 1)
     sdisplay = formatlabelbylength(username,25), col 00, sdisplay,
     sdisplay = formatlabelbylength(position,10), col 26, sdisplay
     IF (size(i18n_stotal) > 25)
      sdisplay = formatlabelbylength(i18n_stotal,25)
     ELSE
      sdisplay = concat(i18n_stotal,"-------------------------"), sdisplay = formatlabelbylength(
       sdisplay,25)
     ENDIF
     col 37, sdisplay, sdisplay = trim(build2(totalptscannedpu),3),
     col 63, sdisplay, sdisplay = trim(build2(totalptselectedpu),3),
     col 74, sdisplay, sdisplay = formatpercentwithdecimal(totalptpercentpu),
     sdisplay = build2(sdisplay,"%"), col 85, sdisplay,
     sdisplay = trim(build2(totalmedscannedpu),3), col 96, sdisplay,
     sdisplay = trim(build2(totalmedselectedpu),3), col 107, sdisplay,
     sdisplay = formatpercentwithdecimal(totalmedpercentpu), sdisplay = build2(sdisplay,"%"), col
     118,
     sdisplay, row + 1
    ENDIF
   FOOT PAGE
    row + 1, col 0, i18n_spage,
    ": ", curpage
   FOOT REPORT
    complianceptpercent = ((cnvtreal(posptcompliancetotal)/ cnvtreal(ptcompliancetotalevents)) *
    100.00), compliancemedpercent = ((cnvtreal(posmedcompliancetotal)/ cnvtreal(
     medcompliancetotalevents)) * 100.00), totalselectedpat = (ptcompliancetotalevents -
    posptcompliancetotal),
    totalselectedmed = (medcompliancetotalevents - posmedcompliancetotal), row + 1, sdisplay =
    formatlabelbylength(i18n_stotalsaverages,60),
    col 00, sdisplay, ":",
    sdisplay = trim(build2(posptcompliancetotal),3), col 63, sdisplay,
    sdisplay = trim(build2(totalselectedpat),3), col 74, sdisplay,
    sdisplay = formatpercentwithdecimal(complianceptpercent), sdisplay = build2(sdisplay,"%"), col
    85,
    sdisplay, sdisplay = trim(build2(posmedcompliancetotal),3), col 96,
    sdisplay, sdisplay = trim(build2(totalselectedmed),3), col 107,
    sdisplay, sdisplay = formatpercentwithdecimal(compliancemedpercent), sdisplay = build2(sdisplay,
     "%"),
    col 118, sdisplay
   WITH nocounter, dio = postscript, maxrow = 45
  ;end select
  IF (curqual=0)
   SELECT INTO  $1
    FROM (dummyt d  WITH seq = 1)
    ORDER BY d.seq
    HEAD PAGE
     IF ( NOT (( $OUT_DEV IN ("MINE"))))
      col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
     ENDIF
     CALL center(i18n_stitle,1,llastcolumn), row + 1, sdisplay = concat(i18n_sdaterange,":"),
     col 00, sdisplay, lprintpos = (size(sdisplay)+ 1),
     sdisplay = ""
     IF ((audit_request->start_dt_tm > 0))
      sdisplay = format(audit_request->start_dt_tm,"@SHORTDATE;;Q")
     ENDIF
     IF ((audit_request->end_dt_tm > 0))
      sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"@SHORTDATE;;Q"))
     ENDIF
     IF (textlen(sdisplay) > 0)
      col lprintpos, sdisplay
     ENDIF
     sdisplay = concat(i18n_spage,": ",cnvtstring(curpage)), lprintpos = (llastcolumn - size(sdisplay
      )), col lprintpos,
     sdisplay, row + 1, sdisplay = concat(i18n_sfacility,": ",trim(uar_get_code_display(cnvtreal(
          $FACILITY)),3)),
     col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(curdate,curtime3),
       "@SHORTDATE;;Q")," ",format(cnvtdatetime(curdate,curtime3),"@TIMENOSECONDS")),
     lprintpos = (llastcolumn - size(sdisplay)), col lprintpos, sdisplay,
     row + 1, sdisplay = concat(i18n_sdisplayper,": ",i18n_sreport), lprintpos = (llastcolumn - size(
      sdisplay)),
     col lprintpos, sdisplay, lnewline = (lprintpos - 20),
     sdisplay = ""
     IF (nallind=1)
      sdisplay = concat(i18n_snurseunits,": ",i18n_sall), col 00, sdisplay
     ELSEIF ((audit_request->unit_cnt > 1))
      sdisplay = concat(i18n_snurseunits,": ",trim(uar_get_code_display(audit_request->unit[1].
         nurse_unit_cd),3),","), col 00, sdisplay,
      lprintpos = (size(sdisplay)+ 1)
      IF (lprintpos > lnewline)
       row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
      ENDIF
      FOR (lcnt = 2 TO audit_request->unit_cnt)
        sdisplay = trim(uar_get_code_display(audit_request->unit[lcnt].nurse_unit_cd),3)
        IF ((lcnt != audit_request->unit_cnt))
         sdisplay = concat(sdisplay,",")
        ENDIF
        IF (((lprintpos+ size(sdisplay)) > lnewline))
         row + 1, lprintpos = (size(i18n_snurseunits)+ 2)
        ENDIF
        col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1)
      ENDFOR
     ELSEIF ((audit_request->unit_cnt=1))
      sdisplay = concat(i18n_snurseunit,": ",trim(uar_get_code_display(audit_request->unit[1].
         nurse_unit_cd),3)), col 00, sdisplay
     ELSE
      sdisplay = concat(i18n_snurseunits,": ",i18n_sunknownerror), col 00, sdisplay
     ENDIF
     row + 1, col 00, cdashline,
     row + 1, sdisplay = concat("***** ",i18n_snoresultsqualified," *****"),
     CALL center(sdisplay,1,llastcolumn)
    WITH dio = postscript, maxrow = 45, maxcol = 142
   ;end select
  ENDIF
 ELSEIF ((audit_request->display_ind=1))
  SET lnurse_units_length = (size(snurse_units,1)+ 100)
  IF (lnurse_units_length < lmin_col_length)
   SET lnurse_units_length = lmin_col_length
  ENDIF
  SET coutput =  $OUT_DEV
  SET modify = nopredeclare
  EXECUTE bsc_scan_compliance_csv
  SET modify = predeclare
 ENDIF
 SET last_mod = "011"
 SET mod_date = "04/12/2017"
 SET modify = nopredeclare
 FREE RECORD audit_request
END GO
