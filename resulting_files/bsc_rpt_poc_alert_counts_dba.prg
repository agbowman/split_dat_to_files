CREATE PROGRAM bsc_rpt_poc_alert_counts:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date:" = "CURDATE",
  "Ending date:" = "CURDATE",
  "Facility:" = 0,
  "Nurse unit(s):" = 0,
  "Display per:" = 0
  WITH out_dev, start_date, end_date,
  facility, nurse_unit, display_type
 SET modify = predeclare
 DECLARE butcind = i2 WITH protect, constant(curutc)
 DECLARE ctime_zone_format = vc WITH protect, constant("ZZZ")
 SUBROUTINE (parsezeroes(pass_field_in=f8) =vc)
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
     SET str_cnt += 1
   ENDWHILE
   SET sig_dig = (str_cnt - 1)
   SET str_cnt = 16
   WHILE (str_cnt > 12
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt -= 1
   ENDWHILE
   IF (str_cnt=12
    AND substring(str_cnt,1,strfld)=".")
    SET str_cnt -= 1
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
 SUBROUTINE (formatutcdatetime(sdatetime=vc,ltzindex=i4,bshowtz=i2) =vc)
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
 SUBROUTINE (formatlabelbylength(slabel=vc,lmaxlen=i4) =vc)
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
 SUBROUTINE (formatstrength(dstrength=f8) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dstrength,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE (formatvolume(dvolume=f8) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dvolume,"######.##;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE (formatrate(drate=f8) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(drate,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE (formatpercentwithdecimal(dpercent=f8) =vc)
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
 DECLARE llastcolumn = i4 WITH protect, constant(131)
 DECLARE ndisplayperuser = i2 WITH protect, constant(0)
 DECLARE ndisplayperday = i2 WITH protect, constant(1)
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(111,"-"))
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lmaecnt = i4 WITH protect, noconstant(0)
 DECLARE dpercent = f8 WITH protect, noconstant(0.0)
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
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
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
    "Point of Care Audit Alert Numbers"),3))
 DECLARE i18n_sdisplayper = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DISPLAY_PER","Display per"),3))
 DECLARE i18n_suser = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_USER","User"
    ),3))
 DECLARE i18n_sday = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_DAY","Day"),3
   ))
 DECLARE i18n_slegend = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_LEGEND",
    "Legend"),3))
 DECLARE i18n_smae = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MAE","MAE"),3
   ))
 DECLARE i18n_smedadminevents = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MED_ADMIN_EVENTS","administered Med Admin Events"),3))
 DECLARE i18n_saa = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_AA","AA"),3))
 DECLARE i18n_swhereauditalert = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_WHERE_AUDIT_ALERT","where Audit Alert"),3))
 DECLARE i18n_spt = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PT","Pt"),3))
 DECLARE i18n_spatient = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PATIENT",
    "Patient"),3))
 DECLARE i18n_smm = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MM","MM"),3))
 DECLARE i18n_smismatch = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MISMATCH","Mismatch"),3))
 DECLARE i18n_sinc = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_INC","Inc"),3
   ))
 DECLARE i18n_sincompatible = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_INCOMPATIBLE","Incompatible"),3))
 DECLARE i18n_stotalnbr = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_TOTALNBR","Total #"),3))
 DECLARE i18n_snbrofmae = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NBR_OF_MAE","# of MAE"),3))
 DECLARE i18n_spercentofmae = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_PERCENT_OF_MAE","% of MAE"),3))
 DECLARE i18n_sover = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_OVER","Over"
    ),3))
 DECLARE i18n_sunder = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_UNDER",
    "Under"),3))
 DECLARE i18n_sincdrug = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_INC_DRUG",
    "Inc Drug"),3))
 DECLARE i18n_stasknot = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TASK_NOT",
    "Task Not"),3))
 DECLARE i18n_sexpired = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_EXPIRED",
    "Expired"),3))
 DECLARE i18n_searly = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_EARLY",
    "Early"),3))
 DECLARE i18n_sinterval = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_INTERVAL","Interval"),3))
 DECLARE i18n_sofmae = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_OF_MAE",
    "of MAE"),3))
 DECLARE i18n_saafired = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_AA_FIRED",
    "AA fired"),3))
 DECLARE i18n_sdose = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_DOSE","Dose"
    ),3))
 DECLARE i18n_sform = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_FORM","Form"
    ),3))
 DECLARE i18n_sformroute = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_FORM_ROUTE","Form Route"),3))
 DECLARE i18n_sfound = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_FOUND",
    "Found"),3))
 DECLARE i18n_smed = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MED","Med"),3
   ))
 DECLARE i18n_slate = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_LATE","Late"
    ),3))
 DECLARE i18n_swarning = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_WARNING",
    "Warning"),3))
 DECLARE i18n_stotal = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TOTAL",
    "Total"),3))
 DECLARE i18n_sendofreport = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_END_OF_REPORT","End of Report"),3))
 DECLARE i18n_snoresultsqualified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_RESULTS_QUALIFIED","No Results Qualified"),3))
 FREE RECORD audit_request
 SET modify = nopredeclare
 EXECUTE bsc_get_audit_info_rr
 SET modify = predeclare
 SET audit_request->report_name = "BSC_RPT_POC_ALERT_COUNTS"
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
 IF (nallind=1)
  SELECT DISTINCT INTO "nl:"
   cv.code_value
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
    lcnt += 1
    IF (mod(lcnt,10)=1)
     dstat = alterlist(audit_request->unit,(lcnt+ 9))
    ENDIF
    audit_request->unit[lcnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    dstat = alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
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
    lcnt += 1
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
 EXECUTE bsc_get_audit_info
 SET modify = predeclare
 IF ((audit_reply->status_data.status="S")
  AND (audit_reply->summary_qual_cnt > 0))
  IF ((audit_request->display_ind=ndisplayperuser))
   SELECT INTO  $1
    name = audit_reply->summary_qual[d.seq].name_full_formatted
    FROM (dummyt d  WITH seq = value(audit_reply->summary_qual_cnt))
    ORDER BY name
    HEAD PAGE
     IF ( NOT (( $1 IN ("MINE"))))
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
     col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(sysdate),
       "@SHORTDATE;;Q")," ",format(cnvtdatetime(sysdate),"@TIMENOSECONDS")),
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
     sdisplay, lprintpos = size(sdisplay), sdisplay = concat(i18n_smae," = ",i18n_smedadminevents,","
      )
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     sdisplay = concat(i18n_saa," = ",i18n_swhereauditalert,",")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     sdisplay = concat(i18n_spt," = ",i18n_spatient,",")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     sdisplay = concat(i18n_smm," = ",i18n_smismatch,",")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     sdisplay = concat(i18n_sinc," = ",i18n_sincompatible,")")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     row + 2, sdisplay = formatlabelbylength(i18n_stotalnbr,9), col 20,
     sdisplay, sdisplay = formatlabelbylength(i18n_snbrofmae,10), col 30,
     sdisplay, sdisplay = formatlabelbylength(i18n_spercentofmae,11), col 41,
     sdisplay, sdisplay = formatlabelbylength(i18n_spt,5), col 53,
     sdisplay, sdisplay = formatlabelbylength(i18n_sover,7), col 59,
     sdisplay, sdisplay = formatlabelbylength(i18n_sunder,6), col 67,
     sdisplay, sdisplay = formatlabelbylength(i18n_sincdrug,9), col 74,
     sdisplay, sdisplay = formatlabelbylength(i18n_sincdrug,11), col 84,
     sdisplay, sdisplay = formatlabelbylength(i18n_stasknot,9), col 96,
     sdisplay, sdisplay = formatlabelbylength(i18n_sexpired,8), col 106,
     sdisplay, sdisplay = formatlabelbylength(i18n_searly,6), sdisplay = concat(sdisplay,"/"),
     col 115, sdisplay, sdisplay = formatlabelbylength(i18n_sinterval,8),
     col 123, sdisplay, row + 1,
     sdisplay = formatlabelbylength(i18n_suser,19), col 00, sdisplay,
     sdisplay = formatlabelbylength(i18n_sofmae,9), col 20, sdisplay,
     sdisplay = formatlabelbylength(i18n_saafired,10), col 30, sdisplay,
     sdisplay = formatlabelbylength(i18n_saafired,11), col 41, sdisplay,
     sdisplay = formatlabelbylength(i18n_smm,5), col 53, sdisplay,
     sdisplay = formatlabelbylength(i18n_sdose,7), col 59, sdisplay,
     sdisplay = formatlabelbylength(sdisplay,6), col 67, sdisplay,
     sdisplay = formatlabelbylength(i18n_sform,9), col 74, sdisplay,
     sdisplay = formatlabelbylength(i18n_sformroute,11), col 84, sdisplay,
     sdisplay = formatlabelbylength(i18n_sfound,11), col 96, sdisplay,
     sdisplay = formatlabelbylength(i18n_smed,8), col 106, sdisplay,
     sdisplay = formatlabelbylength(i18n_slate,7), col 115, sdisplay,
     sdisplay = formatlabelbylength(i18n_swarning,8), col 123, sdisplay,
     row + 2
    HEAD name
     ltotalmaecnt += audit_reply->summary_qual[d.seq].med_admin_event_cnt, ltotalaacnt += audit_reply
     ->summary_qual[d.seq].mae_alert_cnt, lpatmismatchcnt += audit_reply->summary_qual[d.seq].
     pat_mismatch_cnt,
     loverdosecnt += audit_reply->summary_qual[d.seq].overdose_cnt, lunderdosecnt += audit_reply->
     summary_qual[d.seq].underdose_cnt, lincdrugformcnt += audit_reply->summary_qual[d.seq].
     inc_drug_form_cnt,
     lincformroutecnt += audit_reply->summary_qual[d.seq].inc_form_route_cnt, ltasknotfoundcnt +=
     audit_reply->summary_qual[d.seq].task_not_found_cnt, lexpiredmedcnt += audit_reply->
     summary_qual[d.seq].expired_med_cnt,
     learlylatecnt += audit_reply->summary_qual[d.seq].early_late_cnt, lintovercnt += audit_reply->
     summary_qual[d.seq].interval_over_cnt, lintwarncnt += audit_reply->summary_qual[d.seq].
     interval_warn_cnt,
     sdisplay = formatlabelbylength(audit_reply->summary_qual[d.seq].name_full_formatted,19), col 00,
     sdisplay,
     lmaecnt = audit_reply->summary_qual[d.seq].med_admin_event_cnt, sdisplay = nullterm(format(
       lmaecnt,"#####;It(1);I")), col 20,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].mae_alert_cnt,
       "#####;It(1);I")), col 31,
     sdisplay, dpercent = ((cnvtreal(audit_reply->summary_qual[d.seq].mae_alert_cnt)/ lmaecnt) * 100),
     sdisplay = nullterm(format(dpercent,"###;It(1);I")),
     col 44, sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].pat_mismatch_cnt,
       "#####;It(1);I")),
     col 50, sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].overdose_cnt,
       "#####;It(1);I")),
     col 58, sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].underdose_cnt,
       "#####;It(1);I")),
     col 66, sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].inc_drug_form_cnt,
       "#####;It(1);I")),
     col 74, sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].inc_form_route_cnt,
       "#####;It(1);I")),
     col 85, sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].task_not_found_cnt,
       "#####;It(1);I")),
     col 96, sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].expired_med_cnt,
       "#####;It(1);I")),
     col 105, sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].early_late_cnt,
       "#####;It(1);I")),
     col 114, sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].interval_warn_cnt,
       "#####;It(1);I")),
     col 123, sdisplay, row + 1
    FOOT REPORT
     col 20, ctotal_line, row + 1,
     sdisplay = formatlabelbylength(i18n_stotal,19), col 00, sdisplay,
     sdisplay = nullterm(format(ltotalmaecnt,"######;It(1);I")), col 19, sdisplay,
     sdisplay = nullterm(format(ltotalaacnt,"######;It(1);I")), col 30, sdisplay,
     dpercent = ((cnvtreal(ltotalaacnt)/ ltotalmaecnt) * 100), sdisplay = nullterm(format(dpercent,
       "###;It(1);I")), col 44,
     sdisplay, sdisplay = nullterm(format(lpatmismatchcnt,"######;It(1);I")), col 49,
     sdisplay, sdisplay = nullterm(format(loverdosecnt,"######;It(1);I")), col 57,
     sdisplay, sdisplay = nullterm(format(lunderdosecnt,"######;It(1);I")), col 65,
     sdisplay, sdisplay = nullterm(format(lincdrugformcnt,"######;It(1);I")), col 73,
     sdisplay, sdisplay = nullterm(format(lincformroutecnt,"######;It(1);I")), col 84,
     sdisplay, sdisplay = nullterm(format(ltasknotfoundcnt,"######;It(1);I")), col 95,
     sdisplay, sdisplay = nullterm(format(lexpiredmedcnt,"######;It(1);I")), col 104,
     sdisplay, sdisplay = nullterm(format(learlylatecnt,"######;It(1);I")), col 113,
     sdisplay, sdisplay = nullterm(format(lintwarncnt,"######;It(1);I")), col 122,
     sdisplay, row + 2, sdisplay = concat("***** ",i18n_sendofreport," *****"),
     CALL center(sdisplay,1,llastcolumn)
    WITH dio = postscript, maxrow = 45
   ;end select
  ELSEIF ((audit_request->display_ind=ndisplayperday))
   SELECT INTO  $1
    int_date = audit_reply->summary_qual[d.seq].internal_date
    FROM (dummyt d  WITH seq = value(audit_reply->summary_qual_cnt))
    ORDER BY int_date
    HEAD PAGE
     IF ( NOT (( $1 IN ("MINE"))))
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
     col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(sysdate),
       "@SHORTDATE;;Q")," ",format(cnvtdatetime(sysdate),"@TIMENOSECONDS")),
     lprintpos = (llastcolumn - size(sdisplay)), col lprintpos, sdisplay,
     row + 1, sdisplay = concat(i18n_sdisplayper,": ",i18n_sday), lprintpos = (llastcolumn - size(
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
     sdisplay, lprintpos = size(sdisplay), sdisplay = concat(i18n_smae," = ",i18n_smedadminevents,","
      )
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     sdisplay = concat(i18n_saa," = ",i18n_swhereauditalert,",")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     sdisplay = concat(i18n_spt," = ",i18n_spatient,",")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     sdisplay = concat(i18n_smm," = ",i18n_smismatch,",")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     sdisplay = concat(i18n_sinc," = ",i18n_sincompatible,")")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     row + 2, sdisplay = formatlabelbylength(i18n_stotalnbr,9), col 20,
     sdisplay, sdisplay = formatlabelbylength(i18n_snbrofmae,10), col 30,
     sdisplay, sdisplay = formatlabelbylength(i18n_spercentofmae,11), col 41,
     sdisplay, sdisplay = formatlabelbylength(i18n_spt,5), col 53,
     sdisplay, sdisplay = formatlabelbylength(i18n_sover,7), col 59,
     sdisplay, sdisplay = formatlabelbylength(i18n_sunder,6), col 67,
     sdisplay, sdisplay = formatlabelbylength(i18n_sincdrug,9), col 74,
     sdisplay, sdisplay = formatlabelbylength(i18n_sincdrug,11), col 84,
     sdisplay, sdisplay = formatlabelbylength(i18n_stasknot,9), col 96,
     sdisplay, sdisplay = formatlabelbylength(i18n_sexpired,8), col 106,
     sdisplay, sdisplay = formatlabelbylength(i18n_searly,6), sdisplay = concat(sdisplay,"/"),
     col 115, sdisplay, sdisplay = formatlabelbylength(i18n_sinterval,8),
     col 123, sdisplay, row + 1,
     sdisplay = formatlabelbylength(i18n_sday,19), col 00, sdisplay,
     sdisplay = formatlabelbylength(i18n_sofmae,9), col 20, sdisplay,
     sdisplay = formatlabelbylength(i18n_saafired,10), col 30, sdisplay,
     sdisplay = formatlabelbylength(i18n_saafired,11), col 41, sdisplay,
     sdisplay = formatlabelbylength(i18n_smm,5), col 53, sdisplay,
     sdisplay = formatlabelbylength(i18n_sdose,7), col 59, sdisplay,
     sdisplay = formatlabelbylength(sdisplay,6), col 67, sdisplay,
     sdisplay = formatlabelbylength(i18n_sform,9), col 74, sdisplay,
     sdisplay = formatlabelbylength(i18n_sformroute,11), col 84, sdisplay,
     sdisplay = formatlabelbylength(i18n_sfound,11), col 96, sdisplay,
     sdisplay = formatlabelbylength(i18n_smed,8), col 106, sdisplay,
     sdisplay = formatlabelbylength(i18n_slate,7), col 115, sdisplay,
     sdisplay = formatlabelbylength(i18n_swarning,8), col 123, sdisplay,
     row + 2
    HEAD int_date
     ltotalmaecnt += audit_reply->summary_qual[d.seq].med_admin_event_cnt, ltotalaacnt += audit_reply
     ->summary_qual[d.seq].mae_alert_cnt, lpatmismatchcnt += audit_reply->summary_qual[d.seq].
     pat_mismatch_cnt,
     loverdosecnt += audit_reply->summary_qual[d.seq].overdose_cnt, lunderdosecnt += audit_reply->
     summary_qual[d.seq].underdose_cnt, lincdrugformcnt += audit_reply->summary_qual[d.seq].
     inc_drug_form_cnt,
     lincformroutecnt += audit_reply->summary_qual[d.seq].inc_form_route_cnt, ltasknotfoundcnt +=
     audit_reply->summary_qual[d.seq].task_not_found_cnt, lexpiredmedcnt += audit_reply->
     summary_qual[d.seq].expired_med_cnt,
     learlylatecnt += audit_reply->summary_qual[d.seq].early_late_cnt, lintovercnt += audit_reply->
     summary_qual[d.seq].interval_over_cnt, lintwarncnt += audit_reply->summary_qual[d.seq].
     interval_warn_cnt,
     col 00, audit_reply->summary_qual[d.seq].date_string, lmaecnt = audit_reply->summary_qual[d.seq]
     .med_admin_event_cnt,
     sdisplay = nullterm(format(lmaecnt,"#####;It(1);I")), col 20, sdisplay,
     sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].mae_alert_cnt,"#####;It(1);I")), col
      31, sdisplay,
     dpercent = ((cnvtreal(audit_reply->summary_qual[d.seq].mae_alert_cnt)/ lmaecnt) * 100), sdisplay
      = nullterm(format(dpercent,"###;It(1);I")), col 44,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].pat_mismatch_cnt,
       "#####;It(1);I")), col 50,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].overdose_cnt,
       "#####;It(1);I")), col 58,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].underdose_cnt,
       "#####;It(1);I")), col 66,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].inc_drug_form_cnt,
       "#####;It(1);I")), col 74,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].inc_form_route_cnt,
       "#####;It(1);I")), col 85,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].task_not_found_cnt,
       "#####;It(1);I")), col 96,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].expired_med_cnt,
       "#####;It(1);I")), col 105,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].early_late_cnt,
       "#####;It(1);I")), col 114,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].interval_warn_cnt,
       "#####;It(1);I")), col 123,
     sdisplay, row + 1
    FOOT REPORT
     col 20, ctotal_line, row + 1,
     col 00, "Total", sdisplay = nullterm(format(ltotalmaecnt,"######;It(1);I")),
     col 19, sdisplay, sdisplay = nullterm(format(ltotalaacnt,"######;It(1);I")),
     col 30, sdisplay, dpercent = ((cnvtreal(ltotalaacnt)/ ltotalmaecnt) * 100),
     sdisplay = nullterm(format(dpercent,"###;It(1);I")), col 44, sdisplay,
     sdisplay = nullterm(format(lpatmismatchcnt,"######;It(1);I")), col 49, sdisplay,
     sdisplay = nullterm(format(loverdosecnt,"######;It(1);I")), col 57, sdisplay,
     sdisplay = nullterm(format(lunderdosecnt,"######;It(1);I")), col 65, sdisplay,
     sdisplay = nullterm(format(lincdrugformcnt,"######;It(1);I")), col 73, sdisplay,
     sdisplay = nullterm(format(lincformroutecnt,"######;It(1);I")), col 84, sdisplay,
     sdisplay = nullterm(format(ltasknotfoundcnt,"######;It(1);I")), col 95, sdisplay,
     sdisplay = nullterm(format(lexpiredmedcnt,"######;It(1);I")), col 104, sdisplay,
     sdisplay = nullterm(format(learlylatecnt,"######;It(1);I")), col 113, sdisplay,
     sdisplay = nullterm(format(lintwarncnt,"######;It(1);I")), col 122, sdisplay,
     row + 2, sdisplay = concat("***** ",i18n_sendofreport," *****"),
     CALL center(sdisplay,1,llastcolumn)
    WITH dio = postscript, maxrow = 45
   ;end select
  ENDIF
 ELSE
  SELECT INTO  $1
   FROM (dummyt d  WITH seq = 1)
   ORDER BY d.seq
   HEAD PAGE
    IF ( NOT (( $1 IN ("MINE"))))
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
    col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(sysdate),
      "@SHORTDATE;;Q")," ",format(cnvtdatetime(sysdate),"@TIMENOSECONDS")),
    lprintpos = (llastcolumn - size(sdisplay)), col lprintpos, sdisplay,
    row + 1
    IF ((audit_request->display_ind=ndisplayperuser))
     sdisplay = concat(i18n_sdisplayper,": ",i18n_suser), lprintpos = (llastcolumn - size(sdisplay)),
     col lprintpos,
     sdisplay
    ELSEIF ((audit_request->display_ind=ndisplayperday))
     sdisplay = concat(i18n_sdisplayper,": ",i18n_sday), lprintpos = (llastcolumn - size(sdisplay)),
     col lprintpos,
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
    row + 2, sdisplay = concat("***** ",i18n_snoresultsqualified," *****"),
    CALL center(sdisplay,1,llastcolumn)
   WITH dio = postscript
  ;end select
 ENDIF
 SET last_mod = "008"
 SET mod_date = "07/05/2019"
 SET modify = nopredeclare
END GO
