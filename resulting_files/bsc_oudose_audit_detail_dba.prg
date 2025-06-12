CREATE PROGRAM bsc_oudose_audit_detail:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date:" = "CURDATE",
  "Ending date:" = "CURDATE",
  "Facility:" = 0,
  "Nurse unit(s):" = 0,
  "Display per:" = 2
  WITH out_dev, start_date, end_date,
  facility, nurse_unit, display_type
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
 SET modify = predeclare
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
 FREE RECORD events_reply
 RECORD events_reply(
   1 administrations = i4
   1 not_done = i4
   1 not_given = i4
   1 total = i4
 )
 FREE RECORD parent_order
 RECORD parent_order(
   1 dupl_cnt = i4
   1 total_orders_cnt = i4
   1 qual[*]
     2 order_id = f8
     2 template_order_id = f8
     2 action_seq = i4
     2 ordered_qual = i4
     2 temp_dose_seq = i4
 )
 FREE RECORD ordered_ingrdnts
 RECORD ordered_ingrdnts(
   1 tot_par_order_cnt = i4
   1 dupl_cnt = i4
   1 qual[*]
     2 template_order_id = f8
     2 action_seq = i4
     2 dupl_ingr = i4
     2 dupl_cnt = i4
     2 total_ingr_cnt = i4
     2 ingr_qual[*]
       3 synonym_id = f8
       3 ordered_dose = c60
       3 catalog_disp = c60
       3 syn_mne = c60
     2 dose_qual[*]
       3 temp_dose_seq = i4
       3 synonym_id = f8
       3 ordered_dose = c60
       3 catalog_disp = c60
       3 syn_mne = c60
 )
 FREE RECORD parent_admined
 RECORD parent_admined(
   1 dupl_cnt = i4
   1 total_ingr_cnt = i4
   1 qual[*]
     2 total_cnt = i4
     2 dupl_cnt = i4
     2 mame_id = f8
     2 ingr_qual[*]
       3 synonym_id = f8
       3 catalog_disp = c60
       3 dose_admin = c60
       3 syn_mne = c60
 )
 FREE RECORD audit_reply
 RECORD audit_reply(
   1 summary_qual_cnt = i4
   1 cancelled_cnt = i4
   1 administered_cnt = i4
   1 not_given_cnt = i4
   1 not_done_cnt = i4
   1 summary_qual[*]
     2 alert_type = c35
     2 date = vc
     2 patient = c60
     2 location = c60
     2 fin = c60
     2 med_ident = i4
     2 medication = c60
     2 user = c60
     2 order_id = f8
     2 event_id = f8
     2 encounter_id = f8
     2 alert_id = f8
     2 mame_id = f8
     2 admined_qual[*]
       3 synonym_id = f8
       3 syn_mne = c60
       3 dose_admin = c60
     2 ordered_qual[*]
       3 synonym_id = f8
       3 ordered_dose = c60
       3 syn_mne = c60
 )
 DECLARE llastcolumn = i4 WITH protect, constant(131)
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(130,"-"))
 DECLARE s_nd_result_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE s_auth_result_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE fin_nbr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE overdose_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"OVERDOSE"))
 DECLARE underdose_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"UNDERDOSE"))
 DECLARE notdone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"NOTDONE"))
 DECLARE notgiven_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"NOTGIVEN"))
 DECLARE icompoundchild = i2 WITH protect, constant(5)
 DECLARE last_row = c20 WITH protect, noconstant("00000000000000000000")
 DECLARE last_mod = vc WITH protect, noconstant("")
 DECLARE mod_date = vc WITH protect, noconstant("")
 DECLARE smed_ident = vc WITH protect, noconstant("")
 DECLARE soutcome = vc WITH protect, noconstant("")
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE coutput = vc WITH protect, noconstant("oudose.csv")
 DECLARE snua_clause = vc WITH protect, noconstant("1=1")
 DECLARE snue_clause = vc WITH protect, noconstant("1=1")
 DECLARE snurse_units = vc WITH protect, noconstant("")
 DECLARE singredstrength = vc WITH protect, noconstant("")
 DECLARE singredvolume = vc WITH protect, noconstant("")
 DECLARE sadminstrength = vc WITH protect, noconstant("")
 DECLARE sadminvolume = vc WITH protect, noconstant("")
 DECLARE ierroridx = i4 WITH protect, noconstant(0)
 DECLARE ierrorcnt = i4 WITH protect, noconstant(0)
 DECLARE iorderidx = i4 WITH protect, noconstant(0)
 DECLARE iordingrcnt = i4 WITH protect, noconstant(0)
 DECLARE iparentorderidx = i4 WITH protect, noconstant(0)
 DECLARE lnum = i4 WITH protect, noconstant(0)
 DECLARE lnum2 = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE lidx3 = i4 WITH protect, noconstant(0)
 DECLARE lidx4 = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt2 = i4 WITH protect, noconstant(0)
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE dlastid = f8 WITH protect, noconstant(0.00)
 DECLARE dlastid2 = f8 WITH protect, noconstant(0.00)
 DECLARE dstat = f8 WITH protect, noconstant(0.00)
 DECLARE lprintpos = i4 WITH protect, noconstant(0)
 DECLARE max_temp_dose_cnt = i4 WITH noconstant(0)
 DECLARE ldosepos = i4 WITH protect, noconstant(0)
 DECLARE lnurse_units_length = i4 WITH protect, noconstant(0)
 DECLARE lmin_col_length = i4 WITH protect, noconstant(2000)
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
    "Point of Care Audit Over/Underdose Report"),3))
 DECLARE i18n_sdisplayper = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DISPLAY_PER","Display per"),3))
 DECLARE i18n_spatient = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PATIENT",
    "Patient"),3))
 DECLARE i18n_slegend = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_LEGEND",
    "Legend"),3))
 DECLARE i18n_smedicationident = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MEDICATION_IDENT","Medication Identification"),3))
 DECLARE i18n_smedid = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MEDID",
    "MedID"),3))
 DECLARE i18n_smedication = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MEDICATION","Medication"),3))
 DECLARE i18n_smed = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MED","Med"),3
   ))
 DECLARE i18n_sadministered = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ADMINISTERED","Administered"),3))
 DECLARE i18n_sadm = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ADM","ADM"),3
   ))
 DECLARE i18n_scancelled = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_CANCELLED","Cancelled"),3))
 DECLARE i18n_scx = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_CX","CX"),3))
 DECLARE i18n_sng = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NG","NG"),3))
 DECLARE i18n_snd = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ND","ND"),3))
 DECLARE i18n_soutcome = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_OUTCOME",
    "Outcome"),3))
 DECLARE i18n_soc = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_OC","OC"),3))
 DECLARE i18n_salert = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ALERT",
    "Alert"),3))
 DECLARE i18n_sordered = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ORDERED",
    "Ordered"),3))
 DECLARE i18n_suser = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_USER","User"
    ),3))
 DECLARE i18n_sdatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DATE_TIME","Date/Time"),3))
 DECLARE i18n_sname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NAME","name"
    ),3))
 DECLARE i18n_slocation = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_LOCATION","Location"),3))
 DECLARE i18n_sfin = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_FIN","FIN"),3
   ))
 DECLARE i18n_smethod = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_METHOD",
    "Method"),3))
 DECLARE i18n_sdose = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_DOSE","Dose"
    ),3))
 DECLARE i18n_soverdose = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_OVERDOSE","Overdose"),3))
 DECLARE i18n_sunderdose = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_UNDERDOSE","Underdose"),3))
 DECLARE i18n_sselect = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_SELECT",
    "Select"),3))
 DECLARE i18n_sscan = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_SCAN","Scan"
    ),3))
 DECLARE i18n_sunknown = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_UNKNOWN",
    "Unknown"),3))
 DECLARE i18n_sadministrations = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ADMINISTRATIONS","Administrations"),3))
 DECLARE i18n_stotalalerts = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_TOTAL_ALERTS","Total Alerts"),3))
 DECLARE i18n_snotdone = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NOTDONE",
    "Not Done"),3))
 DECLARE i18n_snotgiven = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NOTGIVEN","Not Given"),3))
 DECLARE i18n_stotal = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TOTAL",
    "Total"),3))
 DECLARE i18n_snoresultsqualified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_RESULTS_QUALIFIED","No Results Qualified"),3))
 DECLARE i18n_sallevents = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ALL_EVENTS","All Events"),3))
 DECLARE i18n_soverunderdoseevents = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_OVER/UNDERDOSE_EVENTS","Over/Underdose Events"),3))
 SET audit_request->report_name = "BSC_OUDOSE_AUDIT_DETAIL"
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
 IF (substring(1,1,reflect( $NURSE_UNIT))="I")
  IF (( $NURSE_UNIT=0))
   SET nallind = 1
  ENDIF
 ELSEIF (substring(1,1,reflect( $NURSE_UNIT))="C")
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
     SET snua_clause = build("maa.nurse_unit_cd in(",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = uar_get_code_display(audit_request->unit[lcnt2].nurse_unit_cd)
    ELSE
     SET snue_clause = build(snue_clause,",",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snua_clause = build(snua_clause,",",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = build(snurse_units,"/",uar_get_code_display(audit_request->unit[lcnt2].
       nurse_unit_cd))
    ENDIF
    IF (lcnt2=lcnt)
     SET snue_clause = build(snue_clause,")")
     SET snua_clause = build(snua_clause,")")
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
     SET snua_clause = build("maa.nurse_unit_cd in(",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = uar_get_code_display(audit_request->unit[lcnt2].nurse_unit_cd)
    ELSE
     SET snue_clause = build(snue_clause,",",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snua_clause = build(snua_clause,",",audit_request->unit[lcnt2].nurse_unit_cd)
     SET snurse_units = build(snurse_units,"/",uar_get_code_display(audit_request->unit[lcnt2].
       nurse_unit_cd))
    ENDIF
    IF (lcnt2=lcnt)
     SET snue_clause = build(snue_clause,")")
     SET snua_clause = build(snua_clause,")")
    ENDIF
  ENDWHILE
 ENDIF
 SET audit_request->display_ind =  $DISPLAY_TYPE
 SELECT INTO "nl:"
  FROM med_admin_event mae,
   clinical_event ce
  PLAN (mae
   WHERE mae.updt_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
    audit_request->end_dt_tm)
    AND mae.nurse_unit_cd > 0.00
    AND parser(snue_clause))
   JOIN (ce
   WHERE ce.event_id=mae.event_id
    AND ce.result_status_cd IN (s_nd_result_cd, s_auth_result_cd))
  HEAD REPORT
   events_reply->administrations = 0, events_reply->not_done = 0, events_reply->not_given = 0,
   events_reply->total = 0, lidx = 0
  DETAIL
   lidx = (lidx+ 1)
   IF (mae.event_type_cd=notdone_cd)
    events_reply->not_done = (events_reply->not_done+ 1)
   ELSEIF (mae.event_type_cd=notgiven_cd)
    events_reply->not_given = (events_reply->not_given+ 1)
   ELSE
    events_reply->administrations = (events_reply->administrations+ 1)
   ENDIF
  FOOT REPORT
   events_reply->total = lidx
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM med_admin_alert maa,
   med_admin_med_error mame,
   orders o
  PLAN (maa
   WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
    audit_request->end_dt_tm)
    AND ((maa.alert_type_cd=overdose_cd) OR (maa.alert_type_cd=underdose_cd))
    AND maa.nurse_unit_cd > 0.00
    AND parser(snua_clause))
   JOIN (mame
   WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
   JOIN (o
   WHERE o.order_id=mame.order_id)
  ORDER BY o.order_id
  HEAD REPORT
   dlastid = 0.00, parent_order->dupl_cnt = 0, parent_order->total_orders_cnt = 0,
   lidx = 0, lidx2 = 0, dstat = alterlist(parent_order->qual,10),
   parent_order->qual[1].action_seq = 0, parent_order->qual[1].order_id = 0.00, parent_order->qual[1]
   .template_order_id = 0.00
  DETAIL
   IF (dlastid=o.order_id)
    parent_order->dupl_cnt = (parent_order->dupl_cnt+ 1)
   ELSE
    dlastid = o.order_id, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
    IF (lidx2=10)
     dstat = alterlist(parent_order->qual,(lidx+ 11)), lidx2 = 0
    ENDIF
    parent_order->qual[lidx].order_id = o.order_id
    IF (o.template_order_id=0.00)
     parent_order->qual[lidx].template_order_id = o.order_id
    ELSE
     parent_order->qual[lidx].template_order_id = o.template_order_id
    ENDIF
    parent_order->qual[lidx].action_seq = mame.action_sequence, parent_order->qual[lidx].
    temp_dose_seq = o.template_dose_sequence
   ENDIF
  FOOT REPORT
   dstat = alterlist(parent_order->qual,lidx), parent_order->total_orders_cnt = lidx
  WITH nocounter
 ;end select
 IF (value(size(parent_order->qual,5)) > 0)
  SELECT INTO "nl:"
   template_order_id = parent_order->qual[d.seq].template_order_id
   FROM (dummyt d  WITH seq = value(size(parent_order->qual,5)))
   ORDER BY template_order_id
   HEAD REPORT
    dstat = alterlist(ordered_ingrdnts->qual,10), lidx = 0
   HEAD template_order_id
    lidx1 = 0, lidx = (lidx+ 1), dstat = alterlist(ordered_ingrdnts->qual[lidx].dose_qual,10)
    IF (mod(lidx,10)=0)
     dstat = alterlist(ordered_ingrdnts->qual,(lidx+ 10))
    ENDIF
    ordered_ingrdnts->qual[lidx].template_order_id = template_order_id, ordered_ingrdnts->qual[lidx].
    action_seq = parent_order->qual[d.seq].action_seq, ordered_ingrdnts->qual[lidx].dose_qual[lidx1].
    temp_dose_seq = parent_order->qual[d.seq].temp_dose_seq
   DETAIL
    lidx1 = (lidx1+ 1)
    IF (mod(lidx1,10)=0)
     dstat = alterlist(ordered_ingrdnts->qual[lidx].dose_qual,(lidx1+ 10))
    ENDIF
    ordered_ingrdnts->dupl_cnt = (ordered_ingrdnts->dupl_cnt+ 1), ordered_ingrdnts->qual[lidx].
    dupl_cnt = (ordered_ingrdnts->qual[lidx].dupl_cnt+ 1), parent_order->qual[d.seq].ordered_qual =
    lidx,
    ordered_ingrdnts->qual[lidx].dose_qual[lidx1].temp_dose_seq = parent_order->qual[d.seq].
    temp_dose_seq
    IF (max_temp_dose_cnt < lidx1)
     max_temp_dose_cnt = lidx1
    ENDIF
   FOOT  template_order_id
    row + 0, dstat = alterlist(ordered_ingrdnts->qual[lidx].dose_qual,lidx1)
   FOOT REPORT
    dstat = alterlist(ordered_ingrdnts->qual,lidx), ordered_ingrdnts->tot_par_order_cnt = lidx
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM order_ingredient oi,
   order_catalog_synonym ocs,
   order_ingredient_dose oid,
   (dummyt d  WITH seq = value(size(ordered_ingrdnts->qual,5))),
   (dummyt dtempdose  WITH seq = value(max_temp_dose_cnt))
  PLAN (d)
   JOIN (dtempdose
   WHERE dtempdose.seq <= cnvtint(size(ordered_ingrdnts->qual[d.seq].dose_qual,5)))
   JOIN (oi
   WHERE (oi.order_id=ordered_ingrdnts->qual[d.seq].template_order_id)
    AND (oi.action_sequence=
   (SELECT
    max(oi2.action_sequence)
    FROM order_ingredient oi2
    WHERE oi2.order_id=oi.order_id
     AND (oi2.action_sequence <= ordered_ingrdnts->qual[d.seq].action_seq)))
    AND oi.ingredient_type_flag != icompoundchild)
   JOIN (ocs
   WHERE ocs.synonym_id=oi.synonym_id)
   JOIN (oid
   WHERE oid.order_id=outerjoin(oi.order_id)
    AND oid.action_sequence=outerjoin(oi.action_sequence)
    AND oid.comp_sequence=outerjoin(oi.comp_sequence)
    AND oid.dose_sequence=outerjoin(ordered_ingrdnts->qual[d.seq].dose_qual[dtempdose.seq].
    temp_dose_seq))
  ORDER BY oi.order_id, oi.synonym_id, cnvtdatetime(oi.updt_dt_tm)
  HEAD oi.order_id
   dlastid = - (1.00), ordered_ingrdnts->qual[d.seq].dupl_cnt = 0, lidx2 = 0,
   lidx3 = 0, lnum = 0, lidx4 = locateval(lnum,1,ordered_ingrdnts->tot_par_order_cnt,oi.order_id,
    ordered_ingrdnts->qual[lnum].template_order_id)
   IF (oid.order_ingredient_dose_id=0)
    dstat = alterlist(ordered_ingrdnts->qual[lidx4].ingr_qual,10)
   ENDIF
  DETAIL
   singredstrength = "", singredvolume = ""
   IF (dlastid=oi.synonym_id
    AND oid.order_ingredient_dose_id=0)
    ordered_ingrdnts->qual[lidx4].dupl_ingr = (ordered_ingrdnts->qual[lidx4].dupl_ingr+ 1)
   ELSE
    dlastid = oi.synonym_id, lidx2 = (lidx2+ 1), lidx3 = (lidx3+ 1)
    IF (oid.order_ingredient_dose_id > 0)
     doseseqidx = locateval(lnum,1,size(ordered_ingrdnts->qual[lidx4].dose_qual,5),oid.dose_sequence,
      ordered_ingrdnts->qual[lidx4].dose_qual[lnum].temp_dose_seq)
     IF (oi.synonym_id != 0)
      ordered_ingrdnts->qual[lidx4].dose_qual[doseseqidx].syn_mne = ocs.mnemonic
     ELSE
      ordered_ingrdnts->qual[lidx4].dose_qual[doseseqidx].syn_mne = ""
     ENDIF
     ordered_ingrdnts->qual[lidx4].dose_qual[doseseqidx].synonym_id = oi.synonym_id, ordered_ingrdnts
     ->qual[lidx4].dose_qual[doseseqidx].catalog_disp = uar_get_code_display(oi.catalog_cd)
    ELSE
     IF (lidx3=10)
      dstat = alterlist(ordered_ingrdnts->qual[lidx4].ingr_qual,(lidx2+ 11)), lidx3 = 0
     ENDIF
     IF (oi.synonym_id != 0)
      ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].syn_mne = ocs.mnemonic
     ELSE
      ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].syn_mne = ""
     ENDIF
     ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].synonym_id = oi.synonym_id, ordered_ingrdnts->
     qual[lidx4].ingr_qual[lidx2].catalog_disp = uar_get_code_display(oi.catalog_cd)
    ENDIF
    IF ((audit_request->display_ind=3))
     IF (oid.order_ingredient_dose_id > 0)
      singredstrength = parsezeroes(oid.strength_dose_value), singredvolume = parsezeroes(oid
       .volume_dose_value)
     ELSE
      singredstrength = parsezeroes(oi.strength), singredvolume = parsezeroes(oi.volume)
     ENDIF
    ELSE
     IF (oid.order_ingredient_dose_id > 0)
      singredstrength = formatstrength(oid.strength_dose_value), singredvolume = formatvolume(oid
       .volume_dose_value)
     ELSE
      singredstrength = formatstrength(oi.strength), singredvolume = formatvolume(oi.volume)
     ENDIF
    ENDIF
    IF (oid.order_ingredient_dose_id > 0)
     IF (oid.strength_dose_unit_cd > 0.00)
      IF (oid.volume_dose_unit_cd > 0.00)
       ordered_ingrdnts->qual[lidx4].dose_qual[doseseqidx].ordered_dose = concat(trim(singredstrength
         )," ",trim(uar_get_code_display(oid.strength_dose_unit_cd)),"=",trim(singredvolume),
        " ",trim(uar_get_code_display(oid.volume_dose_unit_cd)))
      ELSE
       ordered_ingrdnts->qual[lidx4].dose_qual[doseseqidx].ordered_dose = concat(trim(singredstrength
         )," ",trim(uar_get_code_display(oid.strength_dose_unit_cd)))
      ENDIF
     ELSEIF (oid.volume_dose_unit_cd > 0.00)
      ordered_ingrdnts->qual[lidx4].dose_qual[doseseqidx].ordered_dose = concat(trim(singredvolume),
       " ",trim(uar_get_code_display(oid.volume_dose_unit_cd)))
     ENDIF
    ELSE
     IF (oi.strength_unit > 0.00)
      IF (oi.volume_unit > 0.00)
       ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].ordered_dose = concat(trim(singredstrength)," ",
        trim(uar_get_code_display(oi.strength_unit)),"=",trim(singredvolume),
        " ",trim(uar_get_code_display(oi.volume_unit)))
      ELSE
       ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].ordered_dose = concat(trim(singredstrength)," ",
        trim(uar_get_code_display(oi.strength_unit)))
      ENDIF
     ELSEIF (oi.volume_unit > 0.00)
      ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].ordered_dose = concat(trim(singredvolume)," ",
       trim(uar_get_code_display(oi.volume_unit)))
     ELSE
      ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].ordered_dose = oi.freetext_dose
     ENDIF
    ENDIF
   ENDIF
  FOOT  oi.order_id
   IF (oid.order_ingredient_dose_id > 0)
    ordered_ingrdnts->qual[lidx4].total_ingr_cnt = 1
   ELSE
    dstat = alterlist(ordered_ingrdnts->qual[lidx4].ingr_qual,lidx2), ordered_ingrdnts->qual[lidx4].
    total_ingr_cnt = lidx2
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM med_admin_alert maa,
   med_admin_med_error mame,
   med_admin_med_event_ingrdnt mamei,
   order_catalog_synonym ocs
  PLAN (maa
   WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
    audit_request->end_dt_tm)
    AND ((maa.alert_type_cd=overdose_cd) OR (maa.alert_type_cd=underdose_cd))
    AND maa.nurse_unit_cd > 0.00
    AND parser(snua_clause))
   JOIN (mame
   WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
   JOIN (mamei
   WHERE mamei.parent_entity_id=outerjoin(mame.med_admin_med_error_id))
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(mamei.synonym_id))
  ORDER BY mame.med_admin_med_error_id, mamei.parent_entity_id, mamei.synonym_id,
   cnvtdatetime(mamei.updt_dt_tm)
  HEAD REPORT
   dlastid = - (1.00), parent_admined->dupl_cnt = 0, parent_admined->total_ingr_cnt = 1,
   lidx = 0, lidx3 = 1, lidx4 = 1,
   dstat = alterlist(parent_admined->qual,10), parent_admined->qual[1].total_cnt = 0, parent_admined
   ->qual[1].mame_id = 0.00
  DETAIL
   sadminstrength = "", sadminvolume = ""
   IF (mame.med_admin_med_error_id > 0)
    IF (dlastid != mame.med_admin_med_error_id)
     dlastid = mame.med_admin_med_error_id, lidx3 = (lidx3+ 1), lidx4 = (lidx4+ 1)
     IF (lidx4=10)
      dstat = alterlist(parent_admined->qual,(lidx3+ 11)), lidx4 = 0
     ENDIF
     parent_admined->qual[lidx3].mame_id = mame.med_admin_med_error_id, parent_admined->qual[lidx3].
     total_cnt = 0, parent_admined->qual[lidx3].dupl_cnt = 0,
     lidx = 0, lidx2 = 0, dlastid2 = - (1.00)
    ENDIF
    IF (mamei.parent_entity_id > 0)
     IF (dlastid2=mamei.synonym_id
      AND (parent_admined->qual[lidx3].total_cnt > 0))
      parent_admined->qual[lidx3].dupl_cnt = (parent_admined->qual[lidx3].dupl_cnt+ 1)
     ELSE
      parent_admined->qual[lidx3].total_cnt = (parent_admined->qual[lidx3].total_cnt+ 1), dlastid2 =
      mamei.synonym_id, lidx = (lidx+ 1),
      dstat = alterlist(parent_admined->qual[lidx3].ingr_qual,lidx), parent_admined->qual[lidx3].
      ingr_qual[lidx].synonym_id = mamei.synonym_id, parent_admined->qual[lidx3].ingr_qual[lidx].
      syn_mne = ocs.mnemonic,
      parent_admined->qual[lidx3].ingr_qual[lidx].catalog_disp = uar_get_code_display(mamei
       .catalog_cd)
      IF ((audit_request->display_ind=3))
       sadminstrength = parsezeroes(mamei.strength), sadminvolume = parsezeroes(mamei.volume)
      ELSE
       sadminstrength = formatstrength(mamei.strength), sadminvolume = formatvolume(mamei.volume)
      ENDIF
      IF (mamei.strength_unit_cd > 0.00)
       IF (mamei.volume_unit_cd > 0.00)
        parent_admined->qual[lidx3].ingr_qual[lidx].dose_admin = concat(trim(sadminstrength)," ",trim
         (uar_get_code_display(mamei.strength_unit_cd)),"=",trim(sadminvolume),
         " ",trim(uar_get_code_display(mamei.volume_unit_cd)))
       ELSE
        parent_admined->qual[lidx3].ingr_qual[lidx].dose_admin = concat(trim(sadminstrength)," ",trim
         (uar_get_code_display(mamei.strength_unit_cd)))
       ENDIF
      ELSEIF (mamei.volume_unit_cd > 0.00)
       parent_admined->qual[lidx3].ingr_qual[lidx].dose_admin = concat(trim(sadminvolume)," ",trim(
         uar_get_code_display(mamei.volume_unit_cd)))
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   dstat = alterlist(parent_admined->qual,lidx3), parent_admined->total_ingr_cnt = lidx3
  WITH nocounter
 ;end select
 IF ((audit_request->display_ind=2))
  SELECT INTO  $OUT_DEV
   FROM med_admin_alert maa,
    prsnl p1,
    med_admin_med_error mame,
    med_admin_pt_error mape,
    person p2,
    encntr_alias ea,
    med_admin_event mae
   PLAN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND ((maa.alert_type_cd=overdose_cd) OR (maa.alert_type_cd=underdose_cd))
     AND maa.nurse_unit_cd > 0.00
     AND parser(snua_clause))
    JOIN (p1
    WHERE p1.person_id=outerjoin(maa.prsnl_id))
    JOIN (mame
    WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (mape
    WHERE mape.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (p2
    WHERE p2.person_id=outerjoin(mame.person_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(mame.encounter_id)
     AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd))
    JOIN (mae
    WHERE mae.event_id=outerjoin(mame.event_id)
     AND mae.event_id > outerjoin(0.00))
   ORDER BY maa.alert_type_cd, p2.name_last_key, p2.person_id,
    maa.rowid, mame.event_id, cnvtdatetime(mae.updt_dt_tm)
   HEAD REPORT
    last_row = "00000000000000000000", lidx = 0, lidx2 = 0,
    lidx3 = 0, lidx4 = 0, audit_reply->cancelled_cnt = 0,
    audit_reply->not_given_cnt = 0, audit_reply->not_done_cnt = 0, audit_reply->administered_cnt = 0,
    dstat = alterlist(audit_reply->summary_qual,10)
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
    row + 1, sdisplay = concat(i18n_sdisplayper,": ",i18n_spatient), lprintpos = (llastcolumn - size(
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
    row + 1, sdisplay = concat(i18n_slegend," ("), col 00,
    sdisplay, lprintpos = size(sdisplay), sdisplay = concat(i18n_smedid," = ",i18n_smedicationident,
     ",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_smed," = ",i18n_smedication,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_sadm," = ",i18n_sadministered,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_scx," = ",i18n_scancelled,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_soc," = ",i18n_soutcome,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_snd," = ",i18n_snotdone,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_sng," = ",i18n_snotgiven,")")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    row + 1, sdisplay = formatlabelbylength(i18n_salert,14), col 00,
    sdisplay, sdisplay = formatlabelbylength(i18n_spatient,16), col 15,
    sdisplay, sdisplay = formatlabelbylength(i18n_smedid,6), col 65,
    sdisplay, sdisplay = formatlabelbylength(i18n_sordered,10), col 88,
    sdisplay, sdisplay = formatlabelbylength(i18n_sdose,10), col 99,
    sdisplay, sdisplay = formatlabelbylength(i18n_suser,17), col 114,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_sdatetime,14),
    col 00, sdisplay, sdisplay = formatlabelbylength(i18n_sname,16),
    col 15, sdisplay, sdisplay = formatlabelbylength(i18n_slocation,16),
    col 32, sdisplay, sdisplay = formatlabelbylength(i18n_sfin,15),
    col 49, sdisplay, sdisplay = formatlabelbylength(i18n_smethod,6),
    col 65, sdisplay, sdisplay = formatlabelbylength(i18n_smed,15),
    col 72, sdisplay, sdisplay = formatlabelbylength(i18n_sdose,10),
    col 88, sdisplay, sdisplay = formatlabelbylength(i18n_sadm,10),
    col 99, sdisplay, sdisplay = i18n_soc
    IF (size(sdisplay) > 3)
     sdisplay = substring(1,3,sdisplay)
    ENDIF
    col 110, sdisplay, sdisplay = formatlabelbylength(i18n_sname,17),
    col 114, sdisplay, row + 1,
    col 00, ctotal_line, row + 1
   HEAD maa.alert_type_cd
    IF (maa.alert_type_cd=overdose_cd)
     col 00, i18n_soverdose
    ELSE
     col 00, i18n_sunderdose
    ENDIF
    row + 1, col 00, cdashline,
    row + 1
   DETAIL
    IF (row=42)
     BREAK
    ENDIF
    IF (last_row != maa.rowid)
     last_row = maa.rowid, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
     IF (lidx2=10)
      dstat = alterlist(audit_reply->summary_qual,(lidx+ 10)), lidx2 = 0
     ENDIF
     audit_reply->summary_qual[lidx].alert_type = uar_get_code_display(maa.alert_type_cd),
     audit_reply->summary_qual[lidx].date = formatutcdatetime(maa.event_dt_tm,0,0), audit_reply->
     summary_qual[lidx].patient = p2.name_full_formatted,
     audit_reply->summary_qual[lidx].location = uar_get_code_display(maa.nurse_unit_cd), audit_reply
     ->summary_qual[lidx].fin = cnvtalias(ea.alias,ea.alias_pool_cd), audit_reply->summary_qual[lidx]
     .med_ident = mae.positive_med_ident_ind,
     audit_reply->summary_qual[lidx].order_id = mame.order_id, audit_reply->summary_qual[lidx].
     event_id = mame.event_id, audit_reply->summary_qual[lidx].mame_id = mame.med_admin_med_error_id,
     audit_reply->summary_qual[lidx].encounter_id = mame.encounter_id, audit_reply->summary_qual[lidx
     ].alert_id = maa.med_admin_alert_id, audit_reply->summary_qual[lidx].user = p1
     .name_full_formatted
     IF (mae.positive_med_ident_ind=0)
      smed_ident = i18n_sselect
     ELSE
      smed_ident = i18n_sscan
     ENDIF
     IF (mame.event_id=0.00)
      soutcome = i18n_scx, audit_reply->cancelled_cnt = (audit_reply->cancelled_cnt+ 1)
     ELSEIF (mae.event_type_cd=notgiven_cd)
      soutcome = i18n_sng, audit_reply->not_given_cnt = (audit_reply->not_given_cnt+ 1)
     ELSEIF (mae.event_type_cd=notdone_cd)
      soutcome = i18n_snd, audit_reply->not_done_cnt = (audit_reply->not_done_cnt+ 1)
     ELSE
      soutcome = i18n_sadm, audit_reply->administered_cnt = (audit_reply->administered_cnt+ 1)
     ENDIF
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].date,14), col 00, sdisplay,
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].patient,16), col 15, sdisplay,
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].location,16), col 32, sdisplay,
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].fin,15), col 49, sdisplay,
     sdisplay = formatlabelbylength(smed_ident,6), col 65, sdisplay,
     ierroridx = locateval(lnum,1,parent_admined->total_ingr_cnt,mame.med_admin_med_error_id,
      parent_admined->qual[lnum].mame_id), iparentorderidx = locateval(lnum2,1,parent_order->
      total_orders_cnt,mame.order_id,parent_order->qual[lnum2].order_id), iorderidx = parent_order->
     qual[iparentorderidx].ordered_qual,
     ierrorcnt = parent_admined->qual[ierroridx].total_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].admined_qual,ierrorcnt), lnum = 0
     WHILE (lnum < ierrorcnt)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].admined_qual[lnum].synonym_id =
       parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       admined_qual[lnum].syn_mne = parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,
       audit_reply->summary_qual[lidx].admined_qual[lnum].dose_admin = parent_admined->qual[ierroridx
       ].ingr_qual[lnum].dose_admin
     ENDWHILE
     iordingrcnt = ordered_ingrdnts->qual[iorderidx].total_ingr_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].ordered_qual,iordingrcnt), lnum = 0
     IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
      WHILE (lnum < iordingrcnt)
        lnum = (lnum+ 1), audit_reply->summary_qual[lidx].ordered_qual[lnum].synonym_id =
        ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx]
        .ordered_qual[lnum].ordered_dose = ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum].
        ordered_dose,
        audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne = ordered_ingrdnts->qual[iorderidx
        ].ingr_qual[lnum].syn_mne
      ENDWHILE
     ELSE
      ldosepos = locateval(lnum,1,size(ordered_ingrdnts->qual[iorderidx].dose_qual,5),parent_order->
       qual[iparentorderidx].temp_dose_seq,ordered_ingrdnts->qual[iorderidx].dose_qual[lnum].
       temp_dose_seq), dstat = alterlist(audit_reply->summary_qual[lidx].ordered_qual,1), audit_reply
      ->summary_qual[lidx].ordered_qual[1].synonym_id = ordered_ingrdnts->qual[iorderidx].dose_qual[
      ldosepos].synonym_id,
      audit_reply->summary_qual[lidx].ordered_qual[1].ordered_dose = ordered_ingrdnts->qual[iorderidx
      ].dose_qual[ldosepos].ordered_dose, audit_reply->summary_qual[lidx].ordered_qual[1].syn_mne =
      ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne
     ENDIF
     lnum = 1, lnum2 = 0
     WHILE (lnum2 < iordingrcnt)
      lnum2 = (lnum2+ 1),
      IF (lnum <= ierrorcnt)
       IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
        WHILE (lnum <= size(parent_admined->qual[ierroridx].ingr_qual,5)
         AND lnum2 <= size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5)
         AND (parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id < ordered_ingrdnts->qual[
        iorderidx].ingr_qual[lnum2].synonym_id))
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15),
          col 72, sdisplay,
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin,
           10), col 99, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
           sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
        ENDWHILE
       ELSE
        WHILE (lnum <= size(parent_admined->qual[ierroridx].ingr_qual,5)
         AND lnum2 <= size(ordered_ingrdnts->qual[iorderidx].dose_qual,5)
         AND (parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id < ordered_ingrdnts->qual[
        iorderidx].dose_qual[ldosepos].synonym_id))
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15),
          col 72, sdisplay,
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin,
           10), col 99, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
           sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
        ENDWHILE
       ENDIF
       IF (lnum <= ierrorcnt)
        IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
         IF ((parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id=ordered_ingrdnts->qual[
         iorderidx].ingr_qual[lnum2].synonym_id))
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,
            15)
          ELSEIF (textlen(trim(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15)
          ELSE
           sdisplay = formatlabelbylength(i18n_sunknown,15)
          ENDIF
          col 72, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
           ingr_qual[lnum2].ordered_dose,10),
          col 88, sdisplay, sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[
           lnum].dose_admin,10),
          col 99, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
           sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
         ELSE
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,
            15)
          ELSE
           sdisplay = formatlabelbylength(i18n_sunknown,15)
          ENDIF
          col 72, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
           ingr_qual[lnum2].ordered_dose,10),
          col 88, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
           sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
          ENDIF
          row + 1
         ENDIF
        ELSE
         IF ((parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id=ordered_ingrdnts->qual[
         iorderidx].dose_qual[ldosepos].synonym_id))
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].
            syn_mne,15)
          ELSEIF (textlen(trim(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15)
          ELSE
           sdisplay = formatlabelbylength(i18n_sunknown,15)
          ENDIF
          col 72, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
           dose_qual[ldosepos].ordered_dose,10),
          col 88, sdisplay, sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[
           lnum].dose_admin,10),
          col 99, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
           sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
         ENDIF
        ENDIF
       ELSE
        IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
         IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
          sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,
           15)
         ELSE
          sdisplay = formatlabelbylength(i18n_sunknown,15)
         ENDIF
         col 72, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
          ingr_qual[lnum2].ordered_dose,10),
         col 88, sdisplay
         IF (lnum=1
          AND lnum2=1)
          sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
          sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
         ENDIF
         row + 1
        ENDIF
       ENDIF
      ELSE
       IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
        IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
         sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,15
          )
        ELSE
         sdisplay = formatlabelbylength(i18n_sunknown,15)
        ENDIF
        col 72, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[
         lnum2].ordered_dose,10),
        col 88, sdisplay
        IF (lnum=1
         AND lnum2=1)
         sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
         sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
        ENDIF
        row + 1
       ENDIF
      ENDIF
     ENDWHILE
     WHILE (lnum <= ierrorcnt)
       sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15),
       col 72, sdisplay,
       sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin,10),
       col 99, sdisplay
       IF (lnum=1
        AND lnum2=1)
        sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
        sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
       ENDIF
       lnum = (lnum+ 1), row + 1
     ENDWHILE
    ENDIF
   FOOT  maa.alert_type_cd
    col 00, cdashline, row + 1
   FOOT PAGE
    col 0, i18n_spage, ":",
    col + 2, curpage
   FOOT REPORT
    audit_reply->summary_qual_cnt = lidx, dstat = alterlist(audit_reply->summary_qual,lidx), row + 2,
    sdisplay = formatlabelbylength(i18n_sallevents,28), col 20, sdisplay,
    sdisplay = formatlabelbylength(i18n_soverunderdoseevents,28), col 70, sdisplay,
    row + 1, col 00, ctotal_line,
    row + 1, sdisplay = formatlabelbylength(i18n_sadministrations,28), col 20,
    sdisplay, sdisplay = nullterm(format(events_reply->administrations,"#########;It(1);I")), col 50,
    sdisplay, sdisplay = formatlabelbylength(i18n_sadministered,28), col 70,
    sdisplay, sdisplay = nullterm(format(audit_reply->administered_cnt,"#########;It(1);I")), col 100,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_snotdone,28),
    col 20, sdisplay, sdisplay = nullterm(format(events_reply->not_done,"#########;It(1);I")),
    col 50, sdisplay, sdisplay = formatlabelbylength(i18n_snotdone,28),
    col 70, sdisplay, sdisplay = nullterm(format(audit_reply->not_done_cnt,"#########;It(1);I")),
    col 100, sdisplay, row + 1,
    sdisplay = formatlabelbylength(i18n_snotgiven,28), col 20, sdisplay,
    sdisplay = nullterm(format(events_reply->not_given,"#########;It(1);I")), col 50, sdisplay,
    sdisplay = formatlabelbylength(i18n_snotgiven,28), col 70, sdisplay,
    sdisplay = nullterm(format(audit_reply->not_given_cnt,"#########;It(1);I")), col 100, sdisplay,
    row + 1, sdisplay = formatlabelbylength(i18n_stotal,28), col 20,
    sdisplay, sdisplay = nullterm(format(events_reply->total,"#########;It(1);I")), col 50,
    sdisplay, sdisplay = formatlabelbylength(i18n_scancelled,28), col 70,
    sdisplay, sdisplay = nullterm(format(audit_reply->cancelled_cnt,"#########;It(1);I")), col 100,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_stotalalerts,28),
    col 70, sdisplay, sdisplay = nullterm(format(lidx,"#########;It(1);I")),
    col 100, sdisplay, row + 1
   WITH outerjoin = d, dio = postscript, maxrow = 45
  ;end select
 ELSEIF ((audit_request->display_ind=0))
  SELECT INTO  $OUT_DEV
   FROM med_admin_alert maa,
    prsnl p1,
    med_admin_med_error mame,
    med_admin_pt_error mape,
    person p2,
    encntr_alias ea,
    med_admin_event mae
   PLAN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND ((maa.alert_type_cd=overdose_cd) OR (maa.alert_type_cd=underdose_cd))
     AND maa.nurse_unit_cd > 0.00
     AND parser(snua_clause))
    JOIN (p1
    WHERE p1.person_id=outerjoin(maa.prsnl_id))
    JOIN (mame
    WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (mape
    WHERE mape.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (p2
    WHERE p2.person_id=outerjoin(mame.person_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(mame.encounter_id)
     AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd))
    JOIN (mae
    WHERE mae.event_id=outerjoin(mame.event_id)
     AND mae.event_id > outerjoin(0.00))
   ORDER BY maa.alert_type_cd, p1.name_last_key, p1.person_id,
    maa.rowid, mame.event_id, cnvtdatetime(mae.updt_dt_tm)
   HEAD REPORT
    last_row = "00000000000000000000", lidx = 0, lidx2 = 0,
    lidx3 = 0, lidx4 = 0, dstat = alterlist(audit_reply->summary_qual,10)
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
    row + 1, sdisplay = concat(i18n_sdisplayper,": ",i18n_suser), lprintpos = (llastcolumn - size(
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
    row + 1, sdisplay = concat(i18n_slegend," ("), col 00,
    sdisplay, lprintpos = size(sdisplay), sdisplay = concat(i18n_smedid," = ",i18n_smedicationident,
     ",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_smed," = ",i18n_smedication,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_sadm," = ",i18n_sadministered,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_scx," = ",i18n_scancelled,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_soc," = ",i18n_soutcome,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_snd," = ",i18n_snotdone,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_sng," = ",i18n_snotgiven,")")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    row + 1, sdisplay = formatlabelbylength(i18n_suser,16), col 00,
    sdisplay, sdisplay = formatlabelbylength(i18n_salert,14), col 17,
    sdisplay, sdisplay = formatlabelbylength(i18n_spatient,16), col 32,
    sdisplay, sdisplay = formatlabelbylength(i18n_smedid,6), col 82,
    sdisplay, sdisplay = formatlabelbylength(i18n_sordered,10), col 105,
    sdisplay, sdisplay = formatlabelbylength(i18n_sdose,10), col 116,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_sname,16),
    col 00, sdisplay, sdisplay = formatlabelbylength(i18n_sdatetime,14),
    col 17, sdisplay, sdisplay = formatlabelbylength(i18n_sname,16),
    col 32, sdisplay, sdisplay = formatlabelbylength(i18n_slocation,16),
    col 49, sdisplay, sdisplay = formatlabelbylength(i18n_sfin,15),
    col 66, sdisplay, sdisplay = formatlabelbylength(i18n_smethod,6),
    col 82, sdisplay, sdisplay = formatlabelbylength(i18n_smed,15),
    col 89, sdisplay, sdisplay = formatlabelbylength(i18n_sdose,10),
    col 105, sdisplay, sdisplay = formatlabelbylength(i18n_sadm,10),
    col 116, sdisplay, sdisplay = i18n_soc
    IF (size(sdisplay) > 3)
     sdisplay = substring(1,3,sdisplay)
    ENDIF
    col 127, sdisplay, row + 1,
    col 00, ctotal_line, row + 1
   HEAD maa.alert_type_cd
    IF (maa.alert_type_cd=overdose_cd)
     col 00, i18n_soverdose
    ELSE
     col 00, i18n_sunderdose
    ENDIF
    row + 1, col 00, cdashline,
    row + 1
   DETAIL
    IF (row=42)
     BREAK
    ENDIF
    IF (last_row != maa.rowid)
     last_row = maa.rowid, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
     IF (lidx2=10)
      dstat = alterlist(audit_reply->summary_qual,(lidx+ 10)), lidx2 = 0
     ENDIF
     audit_reply->summary_qual[lidx].alert_type = uar_get_code_display(maa.alert_type_cd),
     audit_reply->summary_qual[lidx].date = formatutcdatetime(maa.event_dt_tm,0,0), audit_reply->
     summary_qual[lidx].patient = p2.name_full_formatted,
     audit_reply->summary_qual[lidx].location = uar_get_code_display(maa.nurse_unit_cd), audit_reply
     ->summary_qual[lidx].fin = cnvtalias(ea.alias,ea.alias_pool_cd), audit_reply->summary_qual[lidx]
     .med_ident = mae.positive_med_ident_ind,
     audit_reply->summary_qual[lidx].order_id = mame.order_id, audit_reply->summary_qual[lidx].
     event_id = mame.event_id, audit_reply->summary_qual[lidx].mame_id = mame.med_admin_med_error_id,
     audit_reply->summary_qual[lidx].encounter_id = mame.encounter_id, audit_reply->summary_qual[lidx
     ].alert_id = maa.med_admin_alert_id, audit_reply->summary_qual[lidx].user = p1
     .name_full_formatted
     IF (mae.positive_med_ident_ind=0)
      smed_ident = i18n_sselect
     ELSE
      smed_ident = i18n_sscan
     ENDIF
     IF (mame.event_id=0.00)
      soutcome = i18n_scx, audit_reply->cancelled_cnt = (audit_reply->cancelled_cnt+ 1)
     ELSEIF (mae.event_type_cd=notgiven_cd)
      soutcome = i18n_sng, audit_reply->not_given_cnt = (audit_reply->not_given_cnt+ 1)
     ELSEIF (mae.event_type_cd=notdone_cd)
      soutcome = i18n_snd, audit_reply->not_done_cnt = (audit_reply->not_done_cnt+ 1)
     ELSE
      soutcome = i18n_sadm, audit_reply->administered_cnt = (audit_reply->administered_cnt+ 1)
     ENDIF
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 00, sdisplay,
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].date,14), col 17, sdisplay,
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].patient,16), col 32, sdisplay,
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].location,16), col 49, sdisplay,
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].fin,15), col 66, sdisplay,
     sdisplay = formatlabelbylength(smed_ident,6), col 82, sdisplay,
     ierroridx = locateval(lnum,1,parent_admined->total_ingr_cnt,mame.med_admin_med_error_id,
      parent_admined->qual[lnum].mame_id), iparentorderidx = locateval(lnum2,1,parent_order->
      total_orders_cnt,mame.order_id,parent_order->qual[lnum2].order_id), iorderidx = parent_order->
     qual[iparentorderidx].ordered_qual,
     ierrorcnt = parent_admined->qual[ierroridx].total_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].admined_qual,ierrorcnt), lnum = 0
     WHILE (lnum < ierrorcnt)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].admined_qual[lnum].synonym_id =
       parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       admined_qual[lnum].syn_mne = parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,
       audit_reply->summary_qual[lidx].admined_qual[lnum].dose_admin = parent_admined->qual[ierroridx
       ].ingr_qual[lnum].dose_admin
     ENDWHILE
     iordingrcnt = ordered_ingrdnts->qual[iorderidx].total_ingr_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].ordered_qual,iordingrcnt), lnum = 0
     IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
      WHILE (lnum < iordingrcnt)
        lnum = (lnum+ 1), audit_reply->summary_qual[lidx].ordered_qual[lnum].synonym_id =
        ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx]
        .ordered_qual[lnum].ordered_dose = ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum].
        ordered_dose,
        audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne = ordered_ingrdnts->qual[iorderidx
        ].ingr_qual[lnum].syn_mne
      ENDWHILE
     ELSE
      ldosepos = locateval(lnum,1,size(ordered_ingrdnts->qual[iorderidx].dose_qual,5),parent_order->
       qual[iparentorderidx].temp_dose_seq,ordered_ingrdnts->qual[iorderidx].dose_qual[lnum].
       temp_dose_seq), dstat = alterlist(audit_reply->summary_qual[lidx].ordered_qual,1), audit_reply
      ->summary_qual[lidx].ordered_qual[1].synonym_id = ordered_ingrdnts->qual[iorderidx].dose_qual[
      ldosepos].synonym_id,
      audit_reply->summary_qual[lidx].ordered_qual[1].ordered_dose = ordered_ingrdnts->qual[iorderidx
      ].dose_qual[ldosepos].ordered_dose, audit_reply->summary_qual[lidx].ordered_qual[1].syn_mne =
      ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne
     ENDIF
     lnum = 1, lnum2 = 0
     WHILE (lnum2 < iordingrcnt)
      lnum2 = (lnum2+ 1),
      IF (lnum <= ierrorcnt)
       IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
        WHILE (lnum <= size(parent_admined->qual[ierrorcnt].ingr_qual,5)
         AND lnum2 <= size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5)
         AND (parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id < ordered_ingrdnts->qual[
        iorderidx].ingr_qual[lnum2].synonym_id))
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15),
          col 89, sdisplay,
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin,
           10), col 116, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 127, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
        ENDWHILE
       ELSE
        WHILE (lnum <= size(parent_admined->qual[ierrorcnt].ingr_qual,5)
         AND lnum2 <= size(ordered_ingrdnts->qual[iorderidx].dose_qual,5)
         AND (parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id < ordered_ingrdnts->qual[
        iorderidx].dose_qual[ldosepos].synonym_id))
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15),
          col 89, sdisplay,
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin,
           10), col 116, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 127, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
        ENDWHILE
       ENDIF
       IF (lnum <= ierrorcnt)
        IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
         IF ((parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id=ordered_ingrdnts->qual[
         iorderidx].ingr_qual[lnum2].synonym_id))
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,
            15)
          ELSEIF (textlen(trim(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15)
          ELSE
           sdisplay = formatlabelbylength(i18n_sunknown,15)
          ENDIF
          col 89, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
           ingr_qual[lnum2].ordered_dose,10),
          col 105, sdisplay, sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].
           ingr_qual[lnum].dose_admin,10),
          col 116, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 127, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
         ELSE
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,
            15)
          ELSE
           sdisplay = formatlabelbylength(i18n_sunknown,15)
          ENDIF
          col 89, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
           ingr_qual[lnum2].ordered_dose,10),
          col 105, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 127, sdisplay
          ENDIF
          row + 1
         ENDIF
        ELSE
         IF ((parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id=ordered_ingrdnts->qual[
         iorderidx].dose_qual[ldosepos].synonym_id))
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].
            syn_mne,15)
          ELSEIF (textlen(trim(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15)
          ELSE
           sdisplay = formatlabelbylength(i18n_sunknown,15)
          ENDIF
          col 89, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
           dose_qual[ldosepos].ordered_dose,10),
          col 105, sdisplay, sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].
           ingr_qual[lnum].dose_admin,10),
          col 116, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 127, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
         ELSE
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].
            syn_mne,15)
          ELSE
           sdisplay = formatlabelbylength(i18n_sunknown,15)
          ENDIF
          col 89, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
           dose_qual[ldosepos].ordered_dose,10),
          col 105, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 127, sdisplay
          ENDIF
          row + 1
         ENDIF
        ENDIF
       ELSE
        IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
         IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
          sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,
           15)
         ELSE
          sdisplay = formatlabelbylength(i18n_sunknown,15)
         ENDIF
         col 89, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
          ingr_qual[lnum2].ordered_dose,10),
         col 105, sdisplay
         IF (lnum=1
          AND lnum2=1)
          sdisplay = formatlabelbylength(soutcome,3), col 127, sdisplay
         ENDIF
         row + 1
        ENDIF
       ENDIF
      ELSE
       IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
        IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
         sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,15
          )
        ELSE
         sdisplay = formatlabelbylength(i18n_sunknown,15)
        ENDIF
        col 89, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[
         lnum2].ordered_dose,10),
        col 105, sdisplay
        IF (lnum=1
         AND lnum2=1)
         sdisplay = formatlabelbylength(soutcome,3), col 127, sdisplay
        ENDIF
        row + 1
       ENDIF
      ENDIF
     ENDWHILE
     WHILE (lnum <= ierrorcnt)
       sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15),
       col 89, sdisplay,
       sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin,10),
       col 116, sdisplay
       IF (lnum=1
        AND lnum2=1)
        sdisplay = formatlabelbylength(soutcome,3), col 127, sdisplay
       ENDIF
       lnum = (lnum+ 1), row + 1
     ENDWHILE
    ENDIF
   FOOT  maa.alert_type_cd
    col 00, cdashline, row + 1
   FOOT PAGE
    col 0, i18n_spage, ":",
    col + 2, curpage
   FOOT REPORT
    audit_reply->summary_qual_cnt = lidx, dstat = alterlist(audit_reply->summary_qual,lidx), row + 2,
    sdisplay = formatlabelbylength(i18n_sallevents,28), col 20, sdisplay,
    sdisplay = formatlabelbylength(i18n_soverunderdoseevents,28), col 70, sdisplay,
    row + 1, col 00, ctotal_line,
    row + 1, sdisplay = formatlabelbylength(i18n_sadministrations,28), col 20,
    sdisplay, sdisplay = nullterm(format(events_reply->administrations,"#########;It(1);I")), col 50,
    sdisplay, sdisplay = formatlabelbylength(i18n_sadministered,28), col 70,
    sdisplay, sdisplay = nullterm(format(audit_reply->administered_cnt,"#########;It(1);I")), col 100,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_snotdone,28),
    col 20, sdisplay, sdisplay = nullterm(format(events_reply->not_done,"#########;It(1);I")),
    col 50, sdisplay, sdisplay = formatlabelbylength(i18n_snotdone,28),
    col 70, sdisplay, sdisplay = nullterm(format(audit_reply->not_done_cnt,"#########;It(1);I")),
    col 100, sdisplay, row + 1,
    sdisplay = formatlabelbylength(i18n_snotgiven,28), col 20, sdisplay,
    sdisplay = nullterm(format(events_reply->not_given,"#########;It(1);I")), col 50, sdisplay,
    sdisplay = formatlabelbylength(i18n_snotgiven,28), col 70, sdisplay,
    sdisplay = nullterm(format(audit_reply->not_given_cnt,"#########;It(1);I")), col 100, sdisplay,
    row + 1, sdisplay = formatlabelbylength(i18n_stotal,28), col 20,
    sdisplay, sdisplay = nullterm(format(events_reply->total,"#########;It(1);I")), col 50,
    sdisplay, sdisplay = formatlabelbylength(i18n_scancelled,28), col 70,
    sdisplay, sdisplay = nullterm(format(audit_reply->cancelled_cnt,"#########;It(1);I")), col 100,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_stotalalerts,28),
    col 70, sdisplay, sdisplay = nullterm(format(lidx,"#########;It(1);I")),
    col 100, sdisplay, row + 1
   WITH outerjoin = d, dio = postscript, maxrow = 45
  ;end select
 ELSEIF ((audit_request->display_ind=1))
  SELECT INTO  $OUT_DEV
   FROM med_admin_alert maa,
    prsnl p1,
    med_admin_med_error mame,
    med_admin_pt_error mape,
    person p2,
    encntr_alias ea,
    med_admin_event mae
   PLAN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND ((maa.alert_type_cd=overdose_cd) OR (maa.alert_type_cd=underdose_cd))
     AND maa.nurse_unit_cd > 0.00
     AND parser(snua_clause))
    JOIN (p1
    WHERE p1.person_id=outerjoin(maa.prsnl_id))
    JOIN (mame
    WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (mape
    WHERE mape.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (p2
    WHERE p2.person_id=outerjoin(mame.person_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(mame.encounter_id)
     AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd))
    JOIN (mae
    WHERE mae.event_id=outerjoin(mame.event_id)
     AND mae.event_id > outerjoin(0.00))
   ORDER BY maa.alert_type_cd, cnvtdatetime(maa.event_dt_tm), maa.rowid,
    mame.event_id, cnvtdatetime(mae.updt_dt_tm)
   HEAD REPORT
    last_row = "00000000000000000000", lidx = 0, lidx2 = 0,
    lidx3 = 0, lidx4 = 0, dstat = alterlist(audit_reply->summary_qual,10)
   HEAD PAGE
    IF ( NOT (( $OUT_DEV IN ("MINE"))))
     col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
    ENDIF
    CALL center(i18n_stitle,1,131), row + 1, sdisplay = concat(i18n_sdaterange,":"),
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
    row + 1, sdisplay = concat(i18n_sdisplayper,": ",i18n_sdatetime), lprintpos = (llastcolumn - size
    (sdisplay)),
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
    row + 1, sdisplay = concat(i18n_slegend," ("), col 00,
    sdisplay, lprintpos = size(sdisplay), sdisplay = concat(i18n_smedid," = ",i18n_smedicationident,
     ",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_smed," = ",i18n_smedication,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_sadm," = ",i18n_sadministered,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_scx," = ",i18n_scancelled,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_soc," = ",i18n_soutcome,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_snd," = ",i18n_snotdone,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_sng," = ",i18n_snotgiven,")")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    row + 1, sdisplay = formatlabelbylength(i18n_salert,14), col 00,
    sdisplay, sdisplay = formatlabelbylength(i18n_spatient,16), col 15,
    sdisplay, sdisplay = formatlabelbylength(i18n_smedid,6), col 65,
    sdisplay, sdisplay = formatlabelbylength(i18n_sordered,10), col 88,
    sdisplay, sdisplay = formatlabelbylength(i18n_sdose,10), col 99,
    sdisplay, sdisplay = formatlabelbylength(i18n_suser,17), col 114,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_sdatetime,14),
    col 00, sdisplay, sdisplay = formatlabelbylength(i18n_sname,16),
    col 15, sdisplay, sdisplay = formatlabelbylength(i18n_slocation,16),
    col 32, sdisplay, sdisplay = formatlabelbylength(i18n_sfin,15),
    col 49, sdisplay, sdisplay = formatlabelbylength(i18n_smethod,6),
    col 65, sdisplay, sdisplay = formatlabelbylength(i18n_smed,15),
    col 72, sdisplay, sdisplay = formatlabelbylength(i18n_sdose,10),
    col 88, sdisplay, sdisplay = formatlabelbylength(i18n_sadm,10),
    col 99, sdisplay, sdisplay = i18n_soc
    IF (size(sdisplay) > 3)
     sdisplay = substring(1,3,sdisplay)
    ENDIF
    col 110, sdisplay, sdisplay = formatlabelbylength(i18n_sname,17),
    col 114, sdisplay, row + 1,
    col 00, ctotal_line, row + 1
   HEAD maa.alert_type_cd
    IF (maa.alert_type_cd=overdose_cd)
     col 00, i18n_soverdose
    ELSE
     col 00, i18n_sunderdose
    ENDIF
    row + 1, col 00, cdashline,
    row + 1
   DETAIL
    IF (row=42)
     BREAK
    ENDIF
    IF (last_row != maa.rowid)
     last_row = maa.rowid, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
     IF (lidx2=10)
      dstat = alterlist(audit_reply->summary_qual,(lidx+ 10)), lidx2 = 0
     ENDIF
     audit_reply->summary_qual[lidx].alert_type = uar_get_code_display(maa.alert_type_cd),
     audit_reply->summary_qual[lidx].date = formatutcdatetime(maa.event_dt_tm,0,0), audit_reply->
     summary_qual[lidx].patient = p2.name_full_formatted,
     audit_reply->summary_qual[lidx].location = uar_get_code_display(maa.nurse_unit_cd), audit_reply
     ->summary_qual[lidx].fin = cnvtalias(ea.alias,ea.alias_pool_cd), audit_reply->summary_qual[lidx]
     .med_ident = mae.positive_med_ident_ind,
     audit_reply->summary_qual[lidx].order_id = mame.order_id, audit_reply->summary_qual[lidx].
     event_id = mame.event_id, audit_reply->summary_qual[lidx].mame_id = mame.med_admin_med_error_id,
     audit_reply->summary_qual[lidx].encounter_id = mame.encounter_id, audit_reply->summary_qual[lidx
     ].alert_id = maa.med_admin_alert_id, audit_reply->summary_qual[lidx].user = p1
     .name_full_formatted
     IF (mae.positive_med_ident_ind=0)
      smed_ident = i18n_sselect
     ELSE
      smed_ident = i18n_sscan
     ENDIF
     IF (mame.event_id=0.00)
      soutcome = i18n_scx, audit_reply->cancelled_cnt = (audit_reply->cancelled_cnt+ 1)
     ELSEIF (mae.event_type_cd=notgiven_cd)
      soutcome = i18n_sng, audit_reply->not_given_cnt = (audit_reply->not_given_cnt+ 1)
     ELSEIF (mae.event_type_cd=notdone_cd)
      soutcome = i18n_snd, audit_reply->not_done_cnt = (audit_reply->not_done_cnt+ 1)
     ELSE
      soutcome = i18n_sadm, audit_reply->administered_cnt = (audit_reply->administered_cnt+ 1)
     ENDIF
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].date,14), col 00, sdisplay,
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].patient,16), col 15, sdisplay,
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].location,16), col 32, sdisplay,
     sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].fin,15), col 49, sdisplay,
     sdisplay = formatlabelbylength(smed_ident,6), col 65, sdisplay,
     ierroridx = locateval(lnum,1,parent_admined->total_ingr_cnt,mame.med_admin_med_error_id,
      parent_admined->qual[lnum].mame_id), iparentorderidx = locateval(lnum2,1,parent_order->
      total_orders_cnt,mame.order_id,parent_order->qual[lnum2].order_id), iorderidx = parent_order->
     qual[iparentorderidx].ordered_qual,
     ierrorcnt = parent_admined->qual[ierroridx].total_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].admined_qual,ierrorcnt), lnum = 0
     WHILE (lnum < ierrorcnt)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].admined_qual[lnum].synonym_id =
       parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       admined_qual[lnum].syn_mne = parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,
       audit_reply->summary_qual[lidx].admined_qual[lnum].dose_admin = parent_admined->qual[ierroridx
       ].ingr_qual[lnum].dose_admin
     ENDWHILE
     iordingrcnt = ordered_ingrdnts->qual[iorderidx].total_ingr_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].ordered_qual,iordingrcnt), lnum = 0
     IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
      WHILE (lnum < iordingrcnt)
        lnum = (lnum+ 1), audit_reply->summary_qual[lidx].ordered_qual[lnum].synonym_id =
        ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx]
        .ordered_qual[lnum].ordered_dose = ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum].
        ordered_dose,
        audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne = ordered_ingrdnts->qual[iorderidx
        ].ingr_qual[lnum].syn_mne
      ENDWHILE
     ELSE
      ldosepos = locateval(lnum,1,size(ordered_ingrdnts->qual[iorderidx].dose_qual,5),parent_order->
       qual[iparentorderidx].temp_dose_seq,ordered_ingrdnts->qual[iorderidx].dose_qual[lnum].
       temp_dose_seq), dstat = alterlist(audit_reply->summary_qual[lidx].ordered_qual,1), audit_reply
      ->summary_qual[lidx].ordered_qual[1].synonym_id = ordered_ingrdnts->qual[iorderidx].dose_qual[
      ldosepos].synonym_id,
      audit_reply->summary_qual[lidx].ordered_qual[1].ordered_dose = ordered_ingrdnts->qual[iorderidx
      ].dose_qual[ldosepos].ordered_dose, audit_reply->summary_qual[lidx].ordered_qual[1].syn_mne =
      ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne
     ENDIF
     lnum = 1, lnum2 = 0
     WHILE (lnum2 < iordingrcnt)
      lnum2 = (lnum2+ 1),
      IF (lnum <= ierrorcnt)
       IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
        WHILE (lnum <= size(parent_admined->qual[ierrorcnt].ingr_qual,5)
         AND lnum2 <= size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5)
         AND (parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id < ordered_ingrdnts->qual[
        iorderidx].ingr_qual[lnum2].synonym_id))
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15),
          col 72, sdisplay,
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin,
           10), col 99, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
           sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
        ENDWHILE
       ELSE
        WHILE (lnum <= size(parent_admined->qual[ierrorcnt].ingr_qual,5)
         AND lnum2 <= size(ordered_ingrdnts->qual[iorderidx].dose_qual,5)
         AND (parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id < ordered_ingrdnts->qual[
        iorderidx].dose_qual[ldosepos].synonym_id))
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15),
          col 72, sdisplay,
          sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin,
           10), col 99, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
           sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
        ENDWHILE
       ENDIF
       IF (lnum <= ierrorcnt)
        IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
         IF ((parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id=ordered_ingrdnts->qual[
         iorderidx].ingr_qual[lnum2].synonym_id))
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,
            15)
          ELSEIF (textlen(trim(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15)
          ELSE
           sdisplay = formatlabelbylength(i18n_sunknown,15)
          ENDIF
          col 72, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
           ingr_qual[lnum2].ordered_dose,10),
          col 88, sdisplay, sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[
           lnum].dose_admin,10),
          col 99, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
           sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
         ELSE
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,
            15)
          ELSE
           sdisplay = formatlabelbylength(i18n_sunknown,15)
          ENDIF
          col 72, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
           ingr_qual[lnum2].ordered_dose,10),
          col 88, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
           sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
          ENDIF
          row + 1
         ENDIF
        ELSE
         IF ((parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id=ordered_ingrdnts->qual[
         iorderidx].dose_qual[ldosepos].synonym_id))
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].
            syn_mne,15)
          ELSEIF (textlen(trim(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15)
          ELSE
           sdisplay = formatlabelbylength(i18n_sunknown,15)
          ENDIF
          col 72, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
           dose_qual[ldosepos].ordered_dose,10),
          col 88, sdisplay, sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[
           lnum].dose_admin,10),
          col 99, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
           sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
          ENDIF
          lnum = (lnum+ 1), row + 1
         ELSE
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne,3)) > 0)
           sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].
            syn_mne,15)
          ELSE
           sdisplay = formatlabelbylength(i18n_sunknown,15)
          ENDIF
          col 72, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
           dose_qual[ldosepos].ordered_dose,10),
          col 88, sdisplay
          IF (lnum=1
           AND lnum2=1)
           sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
           sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
          ENDIF
          row + 1
         ENDIF
        ENDIF
       ELSE
        IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
         IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
          sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,
           15)
         ELSE
          sdisplay = formatlabelbylength(i18n_sunknown,15)
         ENDIF
         col 72, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].
          ingr_qual[lnum2].ordered_dose,10),
         col 88, sdisplay
         IF (lnum=1
          AND lnum2=1)
          sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
          sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
         ENDIF
         row + 1
        ENDIF
       ENDIF
      ELSE
       IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
        IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
         sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,15
          )
        ELSE
         sdisplay = formatlabelbylength(i18n_sunknown,15)
        ENDIF
        col 72, sdisplay, sdisplay = formatlabelbylength(ordered_ingrdnts->qual[iorderidx].ingr_qual[
         lnum2].ordered_dose,10),
        col 88, sdisplay
        IF (lnum=1
         AND lnum2=1)
         sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
         sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
        ENDIF
        row + 1
       ENDIF
      ENDIF
     ENDWHILE
     WHILE (lnum <= ierrorcnt)
       sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,15),
       col 72, sdisplay,
       sdisplay = formatlabelbylength(parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin,10),
       col 99, sdisplay
       IF (lnum=1
        AND lnum2=1)
        sdisplay = formatlabelbylength(soutcome,3), col 110, sdisplay,
        sdisplay = formatlabelbylength(audit_reply->summary_qual[lidx].user,16), col 114, sdisplay
       ENDIF
       lnum = (lnum+ 1), row + 1
     ENDWHILE
    ENDIF
   FOOT  maa.alert_type_cd
    col 00, cdashline, row + 1
   FOOT PAGE
    col 0, i18n_spage, ":",
    col + 2, curpage
   FOOT REPORT
    audit_reply->summary_qual_cnt = lidx, dstat = alterlist(audit_reply->summary_qual,lidx), row + 2,
    sdisplay = formatlabelbylength(i18n_sallevents,28), col 20, sdisplay,
    sdisplay = formatlabelbylength(i18n_soverunderdoseevents,28), col 70, sdisplay,
    row + 1, col 00, ctotal_line,
    row + 1, sdisplay = formatlabelbylength(i18n_sadministrations,28), col 20,
    sdisplay, sdisplay = nullterm(format(events_reply->administrations,"#########;It(1);I")), col 50,
    sdisplay, sdisplay = formatlabelbylength(i18n_sadministered,28), col 70,
    sdisplay, sdisplay = nullterm(format(audit_reply->administered_cnt,"#########;It(1);I")), col 100,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_snotdone,28),
    col 20, sdisplay, sdisplay = nullterm(format(events_reply->not_done,"#########;It(1);I")),
    col 50, sdisplay, sdisplay = formatlabelbylength(i18n_snotdone,28),
    col 70, sdisplay, sdisplay = nullterm(format(audit_reply->not_done_cnt,"#########;It(1);I")),
    col 100, sdisplay, row + 1,
    sdisplay = formatlabelbylength(i18n_snotgiven,28), col 20, sdisplay,
    sdisplay = nullterm(format(events_reply->not_given,"#########;It(1);I")), col 50, sdisplay,
    sdisplay = formatlabelbylength(i18n_snotgiven,28), col 70, sdisplay,
    sdisplay = nullterm(format(audit_reply->not_given_cnt,"#########;It(1);I")), col 100, sdisplay,
    row + 1, sdisplay = formatlabelbylength(i18n_stotal,28), col 20,
    sdisplay, sdisplay = nullterm(format(events_reply->total,"#########;It(1);I")), col 50,
    sdisplay, sdisplay = formatlabelbylength(i18n_scancelled,28), col 70,
    sdisplay, sdisplay = nullterm(format(audit_reply->cancelled_cnt,"#########;It(1);I")), col 100,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_stotalalerts,28),
    col 70, sdisplay, sdisplay = nullterm(format(lidx,"#########;It(1);I")),
    col 100, sdisplay, row + 1
   WITH outerjoin = d, dio = postscript, maxrow = 45
  ;end select
 ELSEIF ((audit_request->display_ind=3))
  SET lnurse_units_length = (size(snurse_units,1)+ 100)
  IF (lnurse_units_length < lmin_col_length)
   SET lnurse_units_length = lmin_col_length
  ENDIF
  SET coutput =  $OUT_DEV
  SET modify = nopredeclare
  EXECUTE bsc_oudose_audit_detail_csv
  SET modify = predeclare
 ENDIF
 IF ((audit_request->display_ind != 3)
  AND curqual=0)
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
    sdisplay = concat(i18n_spage,": ",cnvtstring(curpage)), lprintpos = (llastcolumn - size(sdisplay)
    ), col lprintpos,
    sdisplay, row + 1, sdisplay = concat(i18n_sfacility,": ",trim(uar_get_code_display(cnvtreal(
         $FACILITY)),3)),
    col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATE;;Q")," ",format(cnvtdatetime(curdate,curtime3),"@TIMENOSECONDS")),
    lprintpos = (llastcolumn - size(sdisplay)), col lprintpos, sdisplay,
    row + 1
    IF ((audit_request->display_ind=0))
     sdisplay = concat(i18n_sdisplayper,": ",i18n_suser), lprintpos = (llastcolumn - size(sdisplay)),
     col lprintpos,
     sdisplay
    ELSEIF ((audit_request->display_ind=1))
     sdisplay = concat(i18n_sdisplayper,": ",i18n_sdatetime), lprintpos = (llastcolumn - size(
      sdisplay)), col lprintpos,
     sdisplay
    ELSEIF ((audit_request->display_ind=2))
     sdisplay = concat(i18n_sdisplayper,": ",i18n_spatient), lprintpos = (llastcolumn - size(sdisplay
      )), col lprintpos,
     sdisplay
    ENDIF
    lnewline = (lprintpos - 20), sdisplay = ""
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
 SET last_mod = "011"
 SET mod_date = "04/10/2017"
 SET modify = nopredeclare
 FREE RECORD audit_request
 FREE RECORD events_reply
 FREE RECORD parent_order
 FREE RECORD parent_admined
 FREE RECORD audit_reply
 FREE RECORD ordered_ingrdnts
END GO
