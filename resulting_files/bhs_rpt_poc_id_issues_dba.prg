CREATE PROGRAM bhs_rpt_poc_id_issues:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date:" = "CURDATE",
  "End date:" = "CURDATE",
  "Facility:" = 673936.00,
  "Nurse unit(s):" = value(*),
  "Display per:" = 0
  WITH outdev, ms_begin_dt, ms_end_dt,
  mf_facility, mf_nurse_unit, ml_display_type
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
 DECLARE llastcolumn = i4 WITH protect, constant(131)
 DECLARE ndisplayperuser = i2 WITH protect, constant(0)
 DECLARE ndisplayperday = i2 WITH protect, constant(1)
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(86,"-"))
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalmaecnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalptidcnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalmedidcnt = i4 WITH protect, noconstant(0)
 DECLARE lpatnotidentcnt = i4 WITH protect, noconstant(0)
 DECLARE lmednotidentcnt = i4 WITH protect, noconstant(0)
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
    "Point of Care Identification Issues"),3))
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
 DECLARE i18n_sid = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ID","ID"),3))
 DECLARE i18n_swherebarcodeusedtoidentify = vc WITH protect, constant(trim(uar_i18ngetmessage(
    i18nhandle,"i18n_BARCODE_USED","where barcode used to identify"),3))
 DECLARE i18n_spt = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PT","Pt"),3))
 DECLARE i18n_spatient = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PATIENT",
    "Patient"),3))
 DECLARE i18n_stotalnbr = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_TOTALNBR","Total #"),3))
 DECLARE i18n_snbrofmae = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NBR_OF_MAE","# of MAE"),3))
 DECLARE i18n_sptnot = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PT_NOT",
    "Pt Not"),3))
 DECLARE i18n_smednot = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MED_NOT",
    "Med Not"),3))
 DECLARE i18n_sofmae = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_OF_MAE",
    "of MAE"),3))
 DECLARE i18n_sidpt = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ID_PT",
    "ID Pt"),3))
 DECLARE i18n_sidmed = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ID_MED",
    "ID Med"),3))
 DECLARE i18n_sidentified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_IDENTIFIED","Identified"),3))
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
 SET audit_request->report_name = "BSC_RPT_POC_ID_ISSUES"
 SET audit_request->start_dt_tm = cnvtdatetime(concat(trim( $MS_BEGIN_DT)," 00:00:00"))
 SET audit_request->end_dt_tm = cnvtdatetime(concat(trim( $MS_END_DT)," 23:59:59"))
 SET audit_request->facility_cd =  $MF_FACILITY
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
     AND cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
     AND cv.active_ind=1
     AND cv.data_status_cd=25.0)
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
 SET audit_request->display_ind =  $ML_DISPLAY_TYPE
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
          $MF_FACILITY)),3)),
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
     sdisplay, lprintpos = size(sdisplay), sdisplay = concat(i18n_smae," = ",i18n_smedadminevents,","
      )
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     sdisplay = concat(i18n_sid," = ",i18n_swherebarcodeusedtoidentify,",")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     sdisplay = concat(i18n_spt," = ",i18n_spatient,")")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     row + 2, sdisplay = formatlabelbylength(i18n_stotalnbr,19), col 30,
     sdisplay, sdisplay = formatlabelbylength(i18n_snbrofmae,19), col 50,
     sdisplay, sdisplay = formatlabelbylength(i18n_snbrofmae,19), col 70,
     sdisplay, sdisplay = formatlabelbylength(i18n_sptnot,19), col 90,
     sdisplay, sdisplay = formatlabelbylength(i18n_smednot,19), col 110,
     sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_suser,29),
     col 00, sdisplay, sdisplay = formatlabelbylength(i18n_sofmae,19),
     col 30, sdisplay, sdisplay = formatlabelbylength(i18n_sidpt,19),
     col 50, sdisplay, sdisplay = formatlabelbylength(i18n_sidmed,19),
     col 70, sdisplay, sdisplay = formatlabelbylength(i18n_sidentified,19),
     col 90, sdisplay, sdisplay = formatlabelbylength(i18n_sidentified,19),
     col 110, sdisplay, row + 2
    HEAD name
     ltotalmaecnt = (ltotalmaecnt+ audit_reply->summary_qual[d.seq].med_admin_event_cnt),
     ltotalptidcnt = (ltotalptidcnt+ audit_reply->summary_qual[d.seq].positive_pat_cnt),
     ltotalmedidcnt = (ltotalmedidcnt+ audit_reply->summary_qual[d.seq].positive_med_cnt),
     lpatnotidentcnt = (lpatnotidentcnt+ audit_reply->summary_qual[d.seq].pat_not_ident_cnt),
     lmednotidentcnt = (lmednotidentcnt+ audit_reply->summary_qual[d.seq].med_not_ident_cnt), col 00,
     audit_reply->summary_qual[d.seq].name_full_formatted, sdisplay = nullterm(format(audit_reply->
       summary_qual[d.seq].med_admin_event_cnt,"#####;It(1);I")), col 30,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].positive_pat_cnt,
       "#####;It(1);I")), col 50,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].positive_med_cnt,
       "#####;It(1);I")), col 70,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].pat_not_ident_cnt,
       "#####;It(1);I")), col 90,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].med_not_ident_cnt,
       "#####;It(1);I")), col 110,
     sdisplay, row + 1
    FOOT REPORT
     col 30, ctotal_line, row + 1,
     sdisplay = formatlabelbylength(i18n_stotal,28), col 00, sdisplay,
     sdisplay = nullterm(format(ltotalmaecnt,"######;It(1);I")), col 29, sdisplay,
     sdisplay = nullterm(format(ltotalptidcnt,"######;It(1);I")), col 49, sdisplay,
     sdisplay = nullterm(format(ltotalmedidcnt,"######;It(1);I")), col 69, sdisplay,
     sdisplay = nullterm(format(lpatnotidentcnt,"######;It(1);I")), col 89, sdisplay,
     sdisplay = nullterm(format(lmednotidentcnt,"######;It(1);I")), col 109, sdisplay,
     row + 2, sdisplay = concat("***** ",i18n_sendofreport,":",curprog," *****"),
     CALL center(sdisplay,1,llastcolumn)
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
          $MF_FACILITY)),3)),
     col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(curdate,curtime3),
       "@SHORTDATE;;Q")," ",format(cnvtdatetime(curdate,curtime3),"@TIMENOSECONDS")),
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
     sdisplay = concat(i18n_sid," = ",i18n_swherebarcodeusedtoidentify,",")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     sdisplay = concat(i18n_spt," = ",i18n_spatient,")")
     IF (((lprintpos+ size(sdisplay)) > llastcolumn))
      row + 1, lprintpos = (size(i18n_slegend)+ 2)
     ENDIF
     col lprintpos, sdisplay, lprintpos = ((lprintpos+ size(sdisplay))+ 1),
     row + 2, sdisplay = formatlabelbylength(i18n_stotalnbr,19), col 30,
     sdisplay, sdisplay = formatlabelbylength(i18n_snbrofmae,19), col 50,
     sdisplay, sdisplay = formatlabelbylength(i18n_snbrofmae,19), col 70,
     sdisplay, sdisplay = formatlabelbylength(i18n_sptnot,19), col 90,
     sdisplay, sdisplay = formatlabelbylength(i18n_smednot,19), col 110,
     sdisplay, row + 1, sdisplay = formatlabelbylength(i18n_sday,29),
     col 00, sdisplay, sdisplay = formatlabelbylength(i18n_sofmae,19),
     col 30, sdisplay, sdisplay = formatlabelbylength(i18n_sidpt,19),
     col 50, sdisplay, sdisplay = formatlabelbylength(i18n_sidmed,19),
     col 70, sdisplay, sdisplay = formatlabelbylength(i18n_sidentified,19),
     col 90, sdisplay, sdisplay = formatlabelbylength(i18n_sidentified,19),
     col 110, sdisplay, row + 2
    HEAD int_date
     ltotalmaecnt = (ltotalmaecnt+ audit_reply->summary_qual[d.seq].med_admin_event_cnt),
     ltotalptidcnt = (ltotalptidcnt+ audit_reply->summary_qual[d.seq].positive_pat_cnt),
     ltotalmedidcnt = (ltotalmedidcnt+ audit_reply->summary_qual[d.seq].positive_med_cnt),
     lpatnotidentcnt = (lpatnotidentcnt+ audit_reply->summary_qual[d.seq].pat_not_ident_cnt),
     lmednotidentcnt = (lmednotidentcnt+ audit_reply->summary_qual[d.seq].med_not_ident_cnt), col 00,
     audit_reply->summary_qual[d.seq].date_string, sdisplay = nullterm(format(audit_reply->
       summary_qual[d.seq].med_admin_event_cnt,"#####;It(1);I")), col 30,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].positive_pat_cnt,
       "#####;It(1);I")), col 50,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].positive_med_cnt,
       "#####;It(1);I")), col 70,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].pat_not_ident_cnt,
       "#####;It(1);I")), col 90,
     sdisplay, sdisplay = nullterm(format(audit_reply->summary_qual[d.seq].med_not_ident_cnt,
       "#####;It(1);I")), col 110,
     sdisplay, row + 1
    FOOT REPORT
     col 30, ctotal_line, row + 1,
     sdisplay = formatlabelbylength(i18n_stotal,28), col 00, sdisplay,
     sdisplay = nullterm(format(ltotalmaecnt,"######;It(1);I")), col 29, sdisplay,
     sdisplay = nullterm(format(ltotalptidcnt,"######;It(1);I")), col 49, sdisplay,
     sdisplay = nullterm(format(ltotalmedidcnt,"######;It(1);I")), col 69, sdisplay,
     sdisplay = nullterm(format(lpatnotidentcnt,"######;It(1);I")), col 89, sdisplay,
     sdisplay = nullterm(format(lmednotidentcnt,"######;It(1);I")), col 109, sdisplay,
     row + 2, sdisplay = concat("***** ",i18n_sendofreport,":",curprog," *****"),
     CALL center(sdisplay,1,llastcolumn)
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
         $MF_FACILITY)),3)),
    col 00, sdisplay, sdisplay = concat(i18n_srundatetime,": ",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATE;;Q")," ",format(cnvtdatetime(curdate,curtime3),"@TIMENOSECONDS")),
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
 SET last_mod = "003"
 SET mod_date = "01/31/2017"
 SET modify = nopredeclare
END GO
