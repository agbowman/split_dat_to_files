CREATE PROGRAM bsc_interval_warning_detail:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date:" = "CURDATE",
  "Ending date:" = "CURDATE",
  "Display Level:" = 0,
  "Facility:" = 0,
  "Nurse unit(s):" = 0
  WITH out_dev, start_date, end_date,
  display_type, facility, nurse_unit
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
 FREE RECORD interval_info_summary
 RECORD interval_info_summary(
   1 total_unit_count = i4
   1 nurse_units[*]
     2 nurse_unit_cd = f8
     2 person_count = i4
     2 person_list[*]
       3 person_id = f8
       3 user_name = c100
       3 interval_alert_count = i4
       3 not_charted_count = i4
       3 not_given_count = i4
       3 yes_no_override_count = i4
       3 yes_override_count = i4
 )
 FREE RECORD interval_temp_event_info
 RECORD interval_temp_event_info(
   1 qual[*]
     2 driver_event_id = f8
     2 actual_event_id = f8
     2 notdone_override = i2
 )
 FREE RECORD interval_info_user
 RECORD interval_info_user(
   1 total_user_count = i4
   1 user_info[*]
     2 user_name = c100
     2 alert_count = i4
     2 alert_info[*]
       3 nurse_unit_cd = f8
       3 patient_name = c100
       3 patient_ident = c100
       3 order_name = c100
       3 alert_dt_tm = vc
       3 next_admin_dt_tm = vc
       3 result_action_disp = c20
       3 override_reason = vc
       3 event_id = f8
       3 performed_dt_tm = vc
 )
 FREE RECORD audit_reply
 RECORD audit_reply(
   1 summary_qual_cnt = i4
   1 cancelled_cnt = i4
   1 continued_cnt = i4
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
     2 ordered_qual[*]
       3 synonym_id = f8
       3 ordered_dose = c60
       3 syn_mne = c60
 )
 DECLARE llastcolumn = i4 WITH protect, constant(131)
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(130,"-"))
 DECLARE medintalert_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"MEDINTALERT"))
 DECLARE medintover_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000040,"MEDINTOVER"))
 DECLARE notdone_result_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE fin_nbr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE immun_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"IMMUN"))
 DECLARE med_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE grp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"GRP"))
 DECLARE last_row = c20 WITH protect, noconstant("00000000000000000000")
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE soutcome = vc WITH protect, noconstant("")
 DECLARE snua_clause = vc WITH protect, noconstant("1=1")
 DECLARE snue_clause = vc WITH protect, noconstant("1=1")
 DECLARE snurse_units = vc WITH protect, noconstant("")
 DECLARE last_mod = vc WITH protect, noconstant("")
 DECLARE mod_date = vc WITH protect, noconstant("")
 DECLARE lcontinued = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE uidx = i4 WITH protect, noconstant(0)
 DECLARE pidx = i4 WITH protect, noconstant(0)
 DECLARE aidx = i4 WITH protect, noconstant(0)
 DECLARE unitsidx = i4 WITH protect, noconstant(0)
 DECLARE lcancelledcnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt2 = i4 WITH protect, noconstant(0)
 DECLARE dstat = f8 WITH protect, noconstant(0.00)
 DECLARE itempidx = i4 WITH protect, noconstant(0)
 DECLARE iterator = i4 WITH protect, noconstant(0)
 DECLARE dpreveventid = f8 WITH protect, noconstant(0)
 DECLARE lextrainfocnt = i4 WITH protect, noconstant(0)
 DECLARE locateidx = i4 WITH protect, noconstant(0)
 DECLARE boutputrow = i2 WITH protect, noconstant(0)
 DECLARE dvalidclineventid = f8 WITH protect, noconstant(0)
 DECLARE doutputeventid = f8 WITH protect, noconstant(0)
 DECLARE validuntildttm = dq8 WITH protect, noconstant(0)
 DECLARE lprintpos = i4 WITH protect, noconstant(0)
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
    "Point of Care Audit Med Interval Alert Report"),3))
 DECLARE i18n_sdisplaylevel = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DISPLAY_PER","Display Level"),3))
 DECLARE i18n_suser = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_USER","User"
    ),3))
 DECLARE i18n_ssummary = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_SUMMARY",
    "Summary"),3))
 DECLARE i18n_slegend = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_LEGEND",
    "Legend"),3))
 DECLARE i18n_sloc = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_LOC","Loc"),3
   ))
 DECLARE i18n_slocation = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_LOCATION","Location"),3))
 DECLARE i18n_sname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NAME","Name"
    ),3))
 DECLARE i18n_swarncount = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_WARN_COUNT","Warn Count"),3))
 DECLARE i18n_snotcharted = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NOT_CHARTED","Not Charted"),3))
 DECLARE i18n_snotgiven = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NOT_GIVEN","Not Given"),3))
 DECLARE i18n_syesoverride = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_YES_OVERRIDE","Yes Override"),3))
 DECLARE i18n_spatid = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PATID",
    "PatID"),3))
 DECLARE i18n_spatientidentifier = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_PATIENT_IDENTIFIER","Patient Identifier"),3))
 DECLARE i18n_snaa = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NAA","NAA"),3
   ))
 DECLARE i18n_snextavailableadmin = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NEXT_AVAIL_ADMIN","Next Available Admin"),3))
 DECLARE i18n_sdttm = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_DT_TM",
    "Dt/Tm"),3))
 DECLARE i18n_sdatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DATE_TIME","Date/Time"),3))
 DECLARE i18n_sra = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_RA","RA"),3))
 DECLARE i18n_sresultingaction = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_RESULTING_ACTION","Resulting Action"),3))
 DECLARE i18n_scng = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_CNG","CNG"),3
   ))
 DECLARE i18n_schartnotgiven = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_CHART_NOT_GIVEN","Chart Not Given"),3))
 DECLARE i18n_syo = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_YO","Y/O"),3))
 DECLARE i18n_syeswithoverride = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_YES_WITH_OVERRIDE","Yes with Override"),3))
 DECLARE i18n_sona = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ONA","ON/A"),
   3))
 DECLARE i18n_syesoverridena = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_YES_OVERRIDE_NA","Yes Override N/A"),3))
 DECLARE i18n_spatient = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PATIENT",
    "Patient"),3))
 DECLARE i18n_sorder = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ORDER",
    "Order"),3))
 DECLARE i18n_salert = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ALERT",
    "Alert"),3))
 DECLARE i18n_soverride = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_OVERRIDE","Override"),3))
 DECLARE i18n_sevent = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_EVENT",
    "Event"),3))
 DECLARE i18n_sperformed = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_PERFORMED","Performed"),3))
 DECLARE i18n_smnemonic = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MNEMONIC","Mnemonic"),3))
 DECLARE i18n_sreason = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_REASON",
    "Reason"),3))
 DECLARE i18n_sid = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ID","ID"),3))
 DECLARE i18n_sno = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NO","No"),3))
 DECLARE i18n_sendofreport = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_END_OF_REPORT","End of Report"),3))
 DECLARE i18n_snoresultsqualified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_RESULTS_QUALIFIED","No Results Qualified"),3))
 SET audit_request->report_name = "BSC_INTERVAL_WARNING_DETAIL"
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
 SELECT INTO "nl:"
  FROM med_admin_alert maa,
   med_admin_med_error mame,
   clinical_event ce1,
   clinical_event ce2
  PLAN (maa
   WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
    audit_request->end_dt_tm)
    AND maa.alert_type_cd IN (medintalert_cd, medintover_cd)
    AND maa.nurse_unit_cd > 0.00
    AND parser(snua_clause))
   JOIN (mame
   WHERE mame.med_admin_alert_id=maa.med_admin_alert_id
    AND mame.event_id != 0.0)
   JOIN (ce1
   WHERE ce1.event_id=mame.event_id)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id)
  ORDER BY ce1.event_id, ce1.valid_until_dt_tm, ce2.event_id
  HEAD REPORT
   lextrainfocnt = 0
  HEAD ce1.event_id
   validuntildttm = 0, lextrainfocnt = (lextrainfocnt+ 1)
   IF (mod(lextrainfocnt,10)=1)
    dstat = alterlist(interval_temp_event_info->qual,(lextrainfocnt+ 9))
   ENDIF
  DETAIL
   IF (validuntildttm=0)
    validuntildttm = ce1.valid_until_dt_tm
   ENDIF
   IF (validuntildttm=ce2.valid_until_dt_tm
    AND (interval_temp_event_info->qual[lextrainfocnt].driver_event_id=0.0))
    IF (ce2.event_class_cd=grp_cd
     AND ce2.result_status_cd=notdone_result_cd)
     interval_temp_event_info->qual[lextrainfocnt].driver_event_id = ce1.event_id,
     interval_temp_event_info->qual[lextrainfocnt].actual_event_id = ce2.event_id,
     interval_temp_event_info->qual[lextrainfocnt].notdone_override = 1
    ENDIF
    IF (((ce2.event_class_cd=med_cd) OR (ce2.event_class_cd=immun_cd)) )
     interval_temp_event_info->qual[lextrainfocnt].driver_event_id = ce1.event_id,
     interval_temp_event_info->qual[lextrainfocnt].actual_event_id = ce2.event_id
     IF (ce2.result_status_cd=notdone_result_cd)
      interval_temp_event_info->qual[lextrainfocnt].notdone_override = 1
     ENDIF
    ENDIF
   ENDIF
  FOOT  ce1.event_id
   dvalidclineventid = 0.0
  FOOT REPORT
   dstat = alterlist(interval_temp_event_info->qual,lextrainfocnt)
 ;end select
 SET audit_request->display_ind =  $DISPLAY_TYPE
 CALL echo(build("**********display ind*******",audit_request->display_ind))
 IF ((audit_request->display_ind=1))
  SELECT INTO  $OUT_DEV
   sort_alert_type = evaluate(maa.alert_type_cd,medintover_cd,1,medintalert_cd,2)
   FROM med_admin_alert maa,
    prsnl p1,
    med_admin_med_error mame,
    clinical_event ce
   PLAN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.alert_type_cd IN (medintalert_cd, medintover_cd)
     AND maa.nurse_unit_cd > 0.00
     AND parser(snua_clause))
    JOIN (p1
    WHERE p1.person_id=maa.prsnl_id)
    JOIN (mame
    WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (ce
    WHERE ce.event_id=outerjoin(mame.event_id))
   ORDER BY maa.nurse_unit_cd, p1.name_last_key, p1.person_id,
    ce.event_id, sort_alert_type, ce.valid_until_dt_tm
   HEAD REPORT
    unitsidx = 0, dstat = alterlist(audit_reply->summary_qual,10)
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
    row + 1, sdisplay = concat(i18n_sdisplaylevel,": ",i18n_ssummary), lprintpos = (llastcolumn -
    size(sdisplay)),
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
    row + 1, sdisplay = formatlabelbylength(i18n_slocation,23), col 00,
    sdisplay, sdisplay = formatlabelbylength(i18n_sname,25), col 24,
    sdisplay, sdisplay = formatlabelbylength(i18n_swarncount,13), col 50,
    sdisplay, sdisplay = formatlabelbylength(i18n_snotcharted,13), col 64,
    sdisplay, sdisplay = formatlabelbylength(i18n_snotgiven,13), col 78,
    sdisplay, sdisplay = formatlabelbylength(i18n_syesoverridena,21), col 92,
    sdisplay, sdisplay = formatlabelbylength(i18n_syesoverride,13), col 114,
    sdisplay, row + 1, col 00,
    ctotal_line
   HEAD maa.nurse_unit_cd
    unitsidx = (unitsidx+ 1), interval_info_summary->total_unit_count = unitsidx
    IF (mod(unitsidx,10)=1)
     dstat = alterlist(interval_info_summary->nurse_units,(unitsidx+ 9))
    ENDIF
    pidx = 0, interval_info_summary->nurse_units[unitsidx].nurse_unit_cd = maa.nurse_unit_cd
   HEAD p1.person_id
    pidx = (pidx+ 1), interval_info_summary->nurse_units[unitsidx].person_count = pidx
    IF (mod(pidx,10)=1)
     dstat = alterlist(interval_info_summary->nurse_units[unitsidx].person_list,(pidx+ 9))
    ENDIF
    interval_info_summary->nurse_units[unitsidx].person_list[pidx].person_id = p1.person_id,
    interval_info_summary->nurse_units[unitsidx].person_list[pidx].user_name = p1.name_full_formatted,
    interval_info_summary->nurse_units[unitsidx].person_list[pidx].interval_alert_count = 0,
    interval_info_summary->nurse_units[unitsidx].person_list[pidx].not_charted_count = 0,
    interval_info_summary->nurse_units[unitsidx].person_list[pidx].not_given_count = 0,
    interval_info_summary->nurse_units[unitsidx].person_list[pidx].yes_no_override_count = 0,
    interval_info_summary->nurse_units[unitsidx].person_list[pidx].yes_override_count = 0
   HEAD ce.event_id
    dvalidclineventid = 0.0
   DETAIL
    IF (ce.clinical_event_id > 0.0
     AND dvalidclineventid=0.0)
     dvalidclineventid = ce.clinical_event_id
    ENDIF
    IF (((dvalidclineventid=0.0) OR (dvalidclineventid=ce.clinical_event_id)) )
     IF (mame.event_id != 0
      AND maa.alert_type_cd=medintover_cd)
      dpreveventid = mame.event_id
     ELSEIF (maa.alert_type_cd=medintover_cd)
      dpreveventid = 0
     ENDIF
     IF (maa.alert_type_cd=medintalert_cd)
      interval_info_summary->nurse_units[unitsidx].person_list[pidx].interval_alert_count = (
      interval_info_summary->nurse_units[unitsidx].person_list[pidx].interval_alert_count+ 1)
     ENDIF
     IF (mame.event_id=0
      AND maa.alert_type_cd=medintalert_cd)
      interval_info_summary->nurse_units[unitsidx].person_list[pidx].not_charted_count = (
      interval_info_summary->nurse_units[unitsidx].person_list[pidx].not_charted_count+ 1)
     ENDIF
     IF (ce.event_id > 0.0)
      locateidx = locateval(iterator,1,lextrainfocnt,ce.event_id,interval_temp_event_info->qual[
       iterator].driver_event_id)
      IF (maa.alert_type_cd=medintalert_cd)
       IF (((ce.result_status_cd=notdone_result_cd) OR (locateidx > 0
        AND (interval_temp_event_info->qual[locateidx].notdone_override=1))) )
        interval_info_summary->nurse_units[unitsidx].person_list[pidx].not_given_count = (
        interval_info_summary->nurse_units[unitsidx].person_list[pidx].not_given_count+ 1)
       ENDIF
      ENDIF
      IF (maa.alert_type_cd=medintalert_cd
       AND mame.event_id != 0)
       IF (mame.event_id != dpreveventid
        AND ce.result_status_cd != notdone_result_cd
        AND locateidx=0
        AND (interval_temp_event_info->qual[locateidx].notdone_override=0))
        interval_info_summary->nurse_units[unitsidx].person_list[pidx].yes_no_override_count = (
        interval_info_summary->nurse_units[unitsidx].person_list[pidx].yes_no_override_count+ 1)
       ENDIF
      ENDIF
      IF (maa.alert_type_cd=medintover_cd
       AND mame.event_id != 0
       AND ce.result_status_cd != notdone_result_cd
       AND ((locateidx=0) OR ((interval_temp_event_info->qual[locateidx].notdone_override=0))) )
       interval_info_summary->nurse_units[unitsidx].person_list[pidx].yes_override_count = (
       interval_info_summary->nurse_units[unitsidx].person_list[pidx].yes_override_count+ 1)
      ENDIF
     ENDIF
    ENDIF
   FOOT  p1.person_id
    itempidx = locateval(iterator,1,interval_info_summary->nurse_units[unitsidx].person_count,p1
     .person_id,interval_info_summary->nurse_units[unitsidx].person_list[iterator].person_id), row +
    1, sdisplay = formatlabelbylength(uar_get_code_display(interval_info_summary->nurse_units[
      unitsidx].nurse_unit_cd),23),
    col 00, sdisplay, sdisplay = formatlabelbylength(interval_info_summary->nurse_units[unitsidx].
     person_list[itempidx].user_name,23),
    col 24, sdisplay, sdisplay = nullterm(format(interval_info_summary->nurse_units[unitsidx].
      person_list[itempidx].interval_alert_count,"#########;It(1);I")),
    col 48, sdisplay, sdisplay = nullterm(format(interval_info_summary->nurse_units[unitsidx].
      person_list[itempidx].not_charted_count,"#########;It(1);I")),
    col 62, sdisplay, sdisplay = nullterm(format(interval_info_summary->nurse_units[unitsidx].
      person_list[itempidx].not_given_count,"#########;It(1);I")),
    col 74, sdisplay, sdisplay = nullterm(format(interval_info_summary->nurse_units[unitsidx].
      person_list[itempidx].yes_no_override_count,"#########;It(1);I")),
    col 92, sdisplay, sdisplay = nullterm(format(interval_info_summary->nurse_units[unitsidx].
      person_list[itempidx].yes_override_count,"#########;It(1);I")),
    col 112, sdisplay
   FOOT PAGE
    row + 1, col 0, i18n_spage,
    ":", col + 2, curpage
   FOOT REPORT
    row + 2, sdisplay = concat("***** ",i18n_sendofreport," *****"),
    CALL center(sdisplay,1,llastcolumn)
   WITH dio = postscript, maxrow = 45
  ;end select
 ELSEIF ((audit_request->display_ind=0))
  CALL echo("inside detail display type")
  DECLARE ioutputsectionheader = i2 WITH protect, noconstant(0)
  SELECT INTO  $OUT_DEV
   sort_alert_type = evaluate(maa.alert_type_cd,medintover_cd,1,medintalert_cd,2)
   FROM med_admin_alert maa,
    prsnl p1,
    med_admin_med_error mame,
    person p2,
    clinical_event ce,
    encntr_alias ea,
    orders o
   PLAN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.alert_type_cd IN (medintalert_cd, medintover_cd)
     AND maa.nurse_unit_cd > 0.00
     AND parser(snua_clause))
    JOIN (p1
    WHERE p1.person_id=maa.prsnl_id)
    JOIN (mame
    WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (p2
    WHERE p2.person_id=outerjoin(mame.person_id))
    JOIN (ce
    WHERE ce.event_id=outerjoin(mame.event_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(mame.encounter_id)
     AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd))
    JOIN (o
    WHERE o.order_id=outerjoin(mame.order_id))
   ORDER BY maa.nurse_unit_cd, p1.name_last_key, p1.person_id,
    ce.event_id, sort_alert_type, ce.valid_until_dt_tm
   HEAD REPORT
    uidx = 0, dstat = alterlist(audit_reply->summary_qual,10)
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
    row + 1, sdisplay = concat(i18n_sdisplaylevel,": ",i18n_suser), lprintpos = (llastcolumn - size(
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
    sdisplay, lprintpos = size(sdisplay), sdisplay = concat(i18n_sloc," = ",i18n_slocation,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_spatid," = ",i18n_spatientidentifier,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_snaa," = ",i18n_snextavailableadmin,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_sdttm," = ",i18n_sdatetime,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_sra," = ",i18n_sresultingaction,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_scng," = ",i18n_schartnotgiven,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_syo," = ",i18n_syeswithoverride,",")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    sdisplay = concat(i18n_sona," = ",i18n_syesoverridena,")")
    IF (((lprintpos+ size(sdisplay)) > llastcolumn))
     row + 1, lprintpos = (size(i18n_slegend)+ 2)
    ENDIF
    col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
    row + 1, col 00, cdashline,
    row + 1, sdisplay = formatlabelbylength(i18n_spatient,17), col 00,
    sdisplay, sdisplay = formatlabelbylength(i18n_sorder,15), col 34,
    sdisplay, sdisplay = formatlabelbylength(i18n_salert,14), col 50,
    sdisplay, sdisplay = formatlabelbylength(i18n_snaa,14), col 65,
    sdisplay, sdisplay = formatlabelbylength(i18n_soverride,19), col 85,
    sdisplay, sdisplay = formatlabelbylength(i18n_sevent,11), col 105,
    sdisplay, sdisplay = formatlabelbylength(i18n_sperformed,14), col 117,
    sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_sname,17),
    col 00, sdisplay, sdisplay = formatlabelbylength(i18n_spatid,15),
    col 18, sdisplay, sdisplay = formatlabelbylength(i18n_smnemonic,15),
    col 34, sdisplay, sdisplay = formatlabelbylength(i18n_sdttm,14),
    col 50, sdisplay, sdisplay = formatlabelbylength(i18n_sdttm,14),
    col 65, sdisplay, sdisplay = formatlabelbylength(i18n_sra,4),
    col 80, sdisplay, sdisplay = formatlabelbylength(i18n_sreason,14),
    col 85, sdisplay, sdisplay = formatlabelbylength(i18n_sid,11),
    col 105, sdisplay, sdisplay = formatlabelbylength(i18n_sdttm,14),
    col 117, sdisplay, row + 1,
    col 00, ctotal_line, row + 1,
    ioutputsectionheader = 1
   HEAD maa.nurse_unit_cd
    uidx = (uidx+ 1), interval_info_user->total_user_count = uidx
    IF (mod(uidx,10)=1)
     dstat = alterlist(interval_info_user->user_info,(uidx+ 9))
    ENDIF
    aidx = 0
   HEAD p1.person_id
    aidx = (aidx+ 1), interval_info_user->user_info[uidx].alert_count = aidx
    IF (mod(aidx,10)=1)
     dstat = alterlist(interval_info_user->user_info[uidx].alert_info,(aidx+ 9))
    ENDIF
    interval_info_user->user_info[uidx].user_name = p1.name_full_formatted, sdisplay = concat(
     i18n_suser," = ",interval_info_user->user_info[uidx].user_name), sdisplay = formatlabelbylength(
     sdisplay,45),
    col 10, sdisplay, sdisplay = concat(i18n_slocation," = ",uar_get_code_display(maa.nurse_unit_cd)),
    sdisplay = formatlabelbylength(sdisplay,llastcolumn), col 60, sdisplay,
    row + 1, col 00, cdashline,
    row + 1, ioutputsectionheader = 0
   HEAD ce.event_id
    dvalidclineventid = 0.0
   DETAIL
    IF (ce.clinical_event_id > 0.0
     AND dvalidclineventid=0.0)
     dvalidclineventid = ce.clinical_event_id
    ENDIF
    IF (((dvalidclineventid=0.0) OR (dvalidclineventid=ce.clinical_event_id)) )
     boutputrow = 1
     IF (mame.event_id != 0
      AND maa.alert_type_cd=medintover_cd)
      dpreveventid = mame.event_id
     ELSEIF (maa.alert_type_cd=medintover_cd)
      dpreveventid = 0
     ENDIF
     IF (row=42)
      BREAK
     ENDIF
     IF (last_row != maa.rowid)
      last_row = maa.rowid, aidx = (aidx+ 1)
      IF (mod(aidx,10)=1)
       dstat = alterlist(interval_info_user->user_info[uidx].alert_info,(aidx+ 9))
      ENDIF
      interval_info_user->user_info[uidx].alert_info[aidx].patient_name = p2.name_full_formatted,
      interval_info_user->user_info[uidx].alert_info[aidx].patient_ident = cnvtalias(ea.alias,ea
       .alias_pool_cd), interval_info_user->user_info[uidx].alert_info[aidx].order_name = o
      .order_mnemonic,
      interval_info_user->user_info[uidx].alert_info[aidx].alert_dt_tm = formatutcdatetime(maa
       .updt_dt_tm,0,0), interval_info_user->user_info[uidx].alert_info[aidx].next_admin_dt_tm =
      formatutcdatetime(maa.next_calc_dt_tm,0,0)
      IF (maa.alert_type_cd=medintalert_cd
       AND dpreveventid=mame.event_id
       AND mame.event_id != 0)
       boutputrow = 0
      ELSE
       IF (mame.event_id=0
        AND maa.alert_type_cd=medintalert_cd)
        interval_info_user->user_info[uidx].alert_info[aidx].result_action_disp = i18n_sno
       ENDIF
       IF (ce.event_id > 0.0)
        locateidx = locateval(iterator,1,lextrainfocnt,ce.event_id,interval_temp_event_info->qual[
         iterator].driver_event_id)
        IF (maa.alert_type_cd=medintalert_cd)
         IF (((ce.result_status_cd=notdone_result_cd) OR (locateidx > 0
          AND (interval_temp_event_info->qual[locateidx].notdone_override=1))) )
          interval_info_user->user_info[uidx].alert_info[aidx].result_action_disp = i18n_scng,
          interval_info_user->user_info[uidx].alert_info[aidx].performed_dt_tm = formatutcdatetime(
           mame.admin_dt_tm,0,0)
          IF (locateidx > 0
           AND (interval_temp_event_info->qual[locateidx].actual_event_id > 0.0))
           interval_info_user->user_info[uidx].alert_info[aidx].event_id = interval_temp_event_info->
           qual[locateidx].actual_event_id
          ELSE
           interval_info_user->user_info[uidx].alert_info[aidx].event_id = mame.event_id
          ENDIF
         ENDIF
        ENDIF
        IF (maa.alert_type_cd=medintalert_cd
         AND mame.event_id != 0)
         IF (mame.event_id != dpreveventid
          AND ce.result_status_cd != notdone_result_cd
          AND locateidx=0
          AND (interval_temp_event_info->qual[locateidx].notdone_override=0))
          interval_info_user->user_info[uidx].alert_info[aidx].result_action_disp = i18n_sona,
          interval_info_user->user_info[uidx].alert_info[aidx].performed_dt_tm = formatutcdatetime(
           mame.admin_dt_tm,0,0)
          IF (locateidx > 0
           AND (interval_temp_event_info->qual[locateidx].actual_event_id > 0.0))
           interval_info_user->user_info[uidx].alert_info[aidx].event_id = interval_temp_event_info->
           qual[locateidx].actual_event_id
          ELSE
           interval_info_user->user_info[uidx].alert_info[aidx].event_id = mame.event_id
          ENDIF
         ENDIF
        ENDIF
        IF (maa.alert_type_cd=medintover_cd
         AND mame.event_id != 0
         AND ce.result_status_cd != notdone_result_cd
         AND locateidx=0
         AND (interval_temp_event_info->qual[locateidx].notdone_override=0))
         interval_info_user->user_info[uidx].alert_info[aidx].result_action_disp = i18n_syo,
         interval_info_user->user_info[uidx].alert_info[aidx].override_reason = mame.freetext_reason,
         interval_info_user->user_info[uidx].alert_info[aidx].performed_dt_tm = formatutcdatetime(
          mame.admin_dt_tm,0,0)
         IF (locateidx > 0
          AND (interval_temp_event_info->qual[locateidx].actual_event_id > 0.0))
          interval_info_user->user_info[uidx].alert_info[aidx].event_id = interval_temp_event_info->
          qual[locateidx].actual_event_id
         ELSE
          interval_info_user->user_info[uidx].alert_info[aidx].event_id = mame.event_id
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      IF (boutputrow=1)
       IF (ioutputsectionheader)
        IF (row=39)
         BREAK
        ENDIF
        sdisplay = concat(i18n_suser," = ",interval_info_user->user_info[uidx].user_name), sdisplay
         = formatlabelbylength(sdisplay,45), col 10,
        sdisplay, sdisplay = concat(i18n_slocation," = ",uar_get_code_display(maa.nurse_unit_cd)),
        sdisplay = formatlabelbylength(sdisplay,llastcolumn),
        col 60, sdisplay, row + 1,
        col 00, cdashline, row + 1,
        ioutputsectionheader = 0
       ENDIF
       sdisplay = formatlabelbylength(interval_info_user->user_info[uidx].alert_info[aidx].
        patient_name,16), col 00, sdisplay,
       sdisplay = formatlabelbylength(interval_info_user->user_info[uidx].alert_info[aidx].
        patient_ident,15), col 17, sdisplay,
       sdisplay = formatlabelbylength(interval_info_user->user_info[uidx].alert_info[aidx].order_name,
        14), col 34, sdisplay,
       sdisplay = formatutcdatetime(mame.updt_dt_tm,0,0), col 50, sdisplay
       IF (maa.next_calc_dt_tm != 0)
        sdisplay = formatutcdatetime(maa.next_calc_dt_tm,0,0)
       ELSE
        sdisplay = ""
       ENDIF
       col 65, sdisplay, sdisplay = formatlabelbylength(interval_info_user->user_info[uidx].
        alert_info[aidx].result_action_disp,4),
       col 80, sdisplay, sdisplay = formatlabelbylength(interval_info_user->user_info[uidx].
        alert_info[aidx].override_reason,18),
       col 85, sdisplay
       IF (mame.event_id != 0)
        sdisplay = trim(cnvtstring(interval_info_user->user_info[uidx].alert_info[aidx].event_id,10,2
          )), col 105, sdisplay
       ENDIF
       sdisplay = interval_info_user->user_info[uidx].alert_info[aidx].performed_dt_tm, col 117,
       sdisplay,
       row + 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  p1.person_id
    col 00, cdashline, row + 1
   FOOT PAGE
    col 0, i18n_spage, ":",
    col + 2, curpage
   FOOT REPORT
    row + 2, sdisplay = concat("***** ",i18n_sendofreport," *****"),
    CALL center(sdisplay,1,llastcolumn)
   WITH dio = postscript, maxrow = 45
  ;end select
 ENDIF
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
    sdisplay = concat(i18n_spage,": ",cnvtstring(curpage)), lprintpos = (llastcolumn - size(sdisplay)
    ), col lprintpos,
    sdisplay, row + 1, sdisplay = concat(i18n_sfacility,": ",trim(uar_get_code_display(cnvtreal(
         $FACILITY)),3)),
    col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATE;;Q")," ",format(cnvtdatetime(curdate,curtime3),"@TIMENOSECONDS")),
    lprintpos = (llastcolumn - size(sdisplay)), col lprintpos, sdisplay,
    row + 1
    IF ((audit_request->display_ind=0))
     sdisplay = concat(i18n_sdisplaylevel,": ",i18n_suser), lprintpos = (llastcolumn - size(sdisplay)
     ), col lprintpos,
     sdisplay
    ELSEIF ((audit_request->display_ind=1))
     sdisplay = concat(i18n_sdisplaylevel,": ",i18n_ssummary), lprintpos = (llastcolumn - size(
      sdisplay)), col lprintpos,
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
 SET last_mod = "007"
 SET mod_date = "09/26/2013"
 SET modify = nopredeclare
 FREE RECORD audit_request
 FREE RECORD interval_info_summary
 FREE RECORD interval_info_user
 FREE RECORD audit_reply
 FREE RECORD interval_temp_event_info
END GO
