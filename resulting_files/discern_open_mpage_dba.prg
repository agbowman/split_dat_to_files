CREATE PROGRAM discern_open_mpage:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD criterion
 RECORD criterion(
   1 prsnl_id = f8
   1 prsnl_name
     2 name_full = vc
   1 position_cd = f8
   1 application_id = i4
   1 application_name = vc
   1 current_locale = vc
   1 static_content = vc
   1 debug_ind = i2
   1 read_only = i2
   1 browser_ind = i2
   1 param_cnt = i4
   1 params[*]
     2 name = vc
     2 value = vc
 )
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
 DECLARE i18nhandle = i4 WITH protect
 DECLARE class_begin_ts = dm12 WITH protect, constant(systimestamp)
 CREATE CLASS mp_i18n
 init
 IF (validate(debug_ind,0)=1)
  DECLARE PRIVATE::obj_create_start = dm12 WITH constant(systimestamp)
  CALL echo("BEGIN MP_I18N object creation")
 ENDIF
 RECORD PRIVATE::settings(
   1 i18nhandle = i4
   1 domainlocale = vc
   1 locale = vc
   1 langid = vc
   1 langlocaleid = vc
   1 logprgname = vc
   1 localeobjectname = vc
   1 localefilename = vc
   1 worklistfilename = vc
   1 localefilepath = vc
   1 worklistlocalefilepath = vc
 )
 DECLARE PRIVATE::overrideind = i2 WITH protect, noconstant(0)
 DECLARE PRIVATE::locidx = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_prg_global_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_prg_prsnl_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_all_global_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_all_prsnl_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_prg_global_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_prg_user_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_global_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_usr_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_prg_global_val = vc WITH noconstant("")
 DECLARE PRIVATE::override_prg_user_val = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_global_val = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_usr_val = vc WITH noconstant("")
 DECLARE _::getdomainlocale(null) = vc
 DECLARE _::getlocale(null) = vc
 DECLARE _::getlangid(null) = vc
 DECLARE _::getlanglocaleid(null) = vc
 DECLARE _::getlocaleobjectname(null) = vc
 DECLARE _::getlocalefilename(null) = vc
 DECLARE _::getworklistfilename(null) = vc
 DECLARE _::getlogprgname(null) = vc
 DECLARE _::geti18nhandle(null) = i4
 DECLARE _::getlocalefilepath(null) = vc
 DECLARE _::getworklistlocalefilepath(null) = vc
 DECLARE _::dump(null) = null
 DECLARE _::generatemasks(null) = null
 SUBROUTINE _::generatemasks(null)
   FREE RECORD datetimeformats
   RECORD datetimeformats(
     1 formatters
       2 decimal_point = vc
       2 thousands_sep = vc
       2 grouping = vc
       2 dollar = vc
       2 time24hr = vc
       2 time24hrnosec = vc
       2 shortdate2yr = vc
       2 fulldate2yr = vc
       2 fulldate4yr = vc
       2 fullmonth4yrnodate = vc
       2 full4yr = vc
       2 fulldatetime2yr = vc
       2 fulldatetime4yr = vc
     1 dateformats
       2 shortdate = vc
       2 mediumdate = vc
       2 longdate = vc
       2 shortdatetime = vc
       2 mediumdatetime = vc
       2 longdatetime = vc
       2 timewithseconds = vc
       2 timenoseconds = vc
       2 weekdaynumber = vc
       2 weekdayabbrev = vc
       2 weekdayname = vc
       2 monthname = vc
       2 monthnumber = vc
       2 monthabbrev = vc
       2 shortdate4yr = vc
       2 mediumdate4yr = vc
       2 shortdatetimenosec = vc
       2 datetimecondensed = vc
       2 datecondensed = vc
       2 mediumdate4yr2 = vc
       2 default = vc
       2 short_date2 = vc
       2 short_date3 = vc
       2 short_date4 = vc
       2 short_date5 = vc
       2 medium_date = vc
       2 long_date = vc
       2 short_time = vc
       2 medium_time = vc
       2 military_time = vc
       2 iso_date = vc
       2 iso_time = vc
       2 iso_date_time = vc
       2 iso_utc_date_time = vc
       2 long_date_time2 = vc
       2 long_date_time3 = vc
       2 medium_date_no_year = vc
       2 month_year = vc
     1 weekmonthnames
       2 weekabbrev = vc
       2 weekfull = vc
       2 monthabbrev = vc
       2 monthfull = vc
   ) WITH persistscript
   SET datetimeformats->dateformats.longdate = replace(cclfmt->longdate,";;d","")
   SET datetimeformats->dateformats.longdatetime = replace(cclfmt->longdatetime,";3;d","")
   SET datetimeformats->dateformats.mediumdate = replace(cclfmt->mediumdate,";;d","")
   SET datetimeformats->dateformats.mediumdatetime = replace(cclfmt->mediumdatetime,";3;d","")
   SET datetimeformats->dateformats.shortdate = replace(cclfmt->shortdate,";;d","")
   SET datetimeformats->dateformats.shortdatetime = replace(cclfmt->shortdatetime,";3;d","")
   SET datetimeformats->dateformats.timenoseconds = replace(cclfmt->timenoseconds,";3;m","")
   SET datetimeformats->dateformats.timewithseconds = replace(cclfmt->timewithseconds,";3;m","")
   SET datetimeformats->dateformats.shortdate4yr = replace(cclfmt->shortdate4yr,";;d","")
   SET datetimeformats->dateformats.mediumdate4yr = replace(cclfmt->mediumdate4yr,";;d","")
   SET datetimeformats->dateformats.shortdatetimenosec = replace(cclfmt->shortdatetimenosec,";3;d",""
    )
   SET datetimeformats->dateformats.datetimecondensed = replace(cclfmt->datetimecondensed,";3;d","")
   SET datetimeformats->dateformats.datecondensed = replace(cclfmt->datecondensed,";;d","")
   IF (validate(cclfmt->mediumdate4yr2))
    SET datetimeformats->dateformats.mediumdate4yr2 = replace(cclfmt->mediumdate4yr2,";;d","")
   ELSE
    SET datetimeformats->dateformats.mediumdate4yr2 = replace(cclfmt->shortdate4yr,";;d","")
   ENDIF
   SET datetimeformats->dateformats.monthname = replace(cclfmt->monthname,";;d","")
   SET datetimeformats->dateformats.monthabbrev = replace(cclfmt->monthabbrev,";;d","")
   SET datetimeformats->dateformats.monthnumber = replace(cclfmt->monthnumber,";;d","")
   SET datetimeformats->dateformats.weekdayabbrev = replace(cclfmt->weekdayabbrev,";;d","")
   SET datetimeformats->dateformats.weekdayname = replace(cclfmt->weekdayname,";;d","")
   SET datetimeformats->dateformats.weekdaynumber = replace(cclfmt->weekdaynumber,";;d","")
   SET datetimeformats->formatters.thousands_sep = notrim(curlocale("THOUSAND"))
   SET datetimeformats->formatters.decimal_point = curlocale("DECIMAL")
   SET datetimeformats->formatters.dollar = curlocale("DOLLAR")
   SET datetimeformats->formatters.grouping = "3"
   SET datetimeformats->formatters.time24hr = "HH:mm:ss"
   SET datetimeformats->formatters.time24hrnosec = "HH:mm"
   SET datetimeformats->formatters.full4yr = "yyyy"
   SET datetimeformats->formatters.shortdate2yr = datetimeformats->dateformats.shortdate
   SET datetimeformats->formatters.fulldate2yr = datetimeformats->dateformats.shortdate
   SET datetimeformats->formatters.fulldate4yr = datetimeformats->dateformats.shortdate4yr
   SET datetimeformats->formatters.fullmonth4yrnodate = "MMM/yyyy"
   SET datetimeformats->formatters.fulldatetime2yr = build2(datetimeformats->dateformats.shortdate,
    " ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->formatters.fulldatetime4yr = build2(datetimeformats->dateformats.shortdate4yr,
    " ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->dateformats.military_time = "HH:mm"
   SET datetimeformats->dateformats.iso_date = "yyyy-MM-dd"
   SET datetimeformats->dateformats.iso_time = "HH:mm:ss"
   SET datetimeformats->dateformats.iso_date_time = "yyyy-MM-dd'T'HH:mm:ss"
   SET datetimeformats->dateformats.iso_utc_date_time = "UTC:yyyy-MM-dd'T'HH:mm:ss'Z'"
   SET datetimeformats->dateformats.short_date5 = "yyyy"
   SET datetimeformats->dateformats.default = datetimeformats->dateformats.longdatetime
   SET datetimeformats->dateformats.short_date2 = datetimeformats->dateformats.shortdate4yr
   SET datetimeformats->dateformats.short_date3 = datetimeformats->dateformats.shortdate
   SET datetimeformats->dateformats.short_date4 = "MMM/yyyy"
   SET datetimeformats->dateformats.medium_date = datetimeformats->dateformats.mediumdate4yr2
   SET datetimeformats->dateformats.long_date = datetimeformats->dateformats.longdate
   SET datetimeformats->dateformats.short_time = datetimeformats->dateformats.timenoseconds
   SET datetimeformats->dateformats.medium_time = datetimeformats->dateformats.timewithseconds
   SET datetimeformats->dateformats.long_date_time2 = build2(datetimeformats->dateformats.shortdate,
    " ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->dateformats.long_date_time3 = build2(datetimeformats->dateformats.
    shortdate4yr," ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->dateformats.medium_date_no_year = "d mmm"
   SET datetimeformats->dateformats.month_year = "MAC. yyyy"
   SET datetimeformats->weekmonthnames.weekabbrev = curlocale("WEEKABBREV")
   SET datetimeformats->weekmonthnames.weekfull = curlocale("WEEKFULL")
   SET datetimeformats->weekmonthnames.monthabbrev = curlocale("MONTHABBREV")
   SET datetimeformats->weekmonthnames.monthfull = concat(format(cnvtdatetime("01-jan-2015"),
     "mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-feb-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime(
      "01-mar-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-apr-2015"),"mmmmmmmmmmmm,;;q"),
    format(cnvtdatetime("01-may-2015"),"mmmmmmmmmmmm,;;q"),
    format(cnvtdatetime("01-jun-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-jul-2015"),
     "mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-aug-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime(
      "01-sep-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-oct-2015"),"mmmmmmmmmmmm,;;q"),
    format(cnvtdatetime("01-nov-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-dec-2015"),
     "mmmmmmmmmmmm;;q"))
   IF (validate(debug_ind,0)=1)
    CALL echorecord(datetimeformats)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::setlocale(str=vc) =null)
   SET private::settings->locale = str
 END ;Subroutine
 SUBROUTINE (_::setlangid(str=vc) =null)
   SET private::settings->langid = str
 END ;Subroutine
 SUBROUTINE (_::setlanglocaleid(str=vc) =null)
   SET private::settings->langlocaleid = str
 END ;Subroutine
 SUBROUTINE (_::setlogprgname(str=vc) =null)
   SET private::settings->logprgname = str
 END ;Subroutine
 SUBROUTINE (_::setlocaleobjectname(str=vc) =null)
   SET private::settings->localeobjectname = str
 END ;Subroutine
 SUBROUTINE (_::setlocalefilename(str=vc) =null)
   SET private::settings->localefilename = str
 END ;Subroutine
 SUBROUTINE (_::setlocalefilepath(str=vc) =null)
   SET private::settings->localefilepath = str
 END ;Subroutine
 SUBROUTINE (_::setdomainlocale(str=vc) =null)
   SET private::settings->domainlocale = str
 END ;Subroutine
 SUBROUTINE (_::seti18nhandle(val=i4) =null)
   SET private::settings->i18nhandle = val
 END ;Subroutine
 SUBROUTINE (_::setworklistfilename(str=vc) =null)
   SET private::settings->worklistfilename = str
 END ;Subroutine
 SUBROUTINE (_::setworklistlocalefilepath(str=vc) =null)
   SET private::settings->worklistlocalefilepath = str
 END ;Subroutine
 SUBROUTINE _::getworklistfilename(null)
   RETURN(private::settings->worklistfilename)
 END ;Subroutine
 SUBROUTINE _::getlocale(null)
   RETURN(private::settings->locale)
 END ;Subroutine
 SUBROUTINE _::getlangid(null)
   RETURN(private::settings->langid)
 END ;Subroutine
 SUBROUTINE _::getlanglocaleid(null)
   RETURN(private::settings->langlocaleid)
 END ;Subroutine
 SUBROUTINE _::getlogprgname(null)
   RETURN(private::settings->logprgname)
 END ;Subroutine
 SUBROUTINE _::getdomainlocale(null)
   DECLARE tlocale = c5 WITH private, noconstant("     ")
   SET tlocale = cnvtupper(logical("CCL_LANG"))
   IF (tlocale=" ")
    SET tlocale = cnvtupper(logical("LANG"))
    IF (tlocale IN (" ", "C"))
     SET tlocale = "EN_US"
    ENDIF
   ENDIF
   CALL _::setdomainlocale(tlocale)
   RETURN(tlocale)
 END ;Subroutine
 SUBROUTINE _::getlocaleobjectname(null)
   RETURN(private::settings->localeobjectname)
 END ;Subroutine
 SUBROUTINE _::getlocalefilename(null)
   RETURN(private::settings->localefilename)
 END ;Subroutine
 SUBROUTINE _::getlocalefilepath(null)
   RETURN(private::settings->localefilepath)
 END ;Subroutine
 SUBROUTINE _::geti18nhandle(null)
   RETURN(private::settings->i18nhandle)
 END ;Subroutine
 SUBROUTINE _::getworklistlocalefilepath(null)
   RETURN(private::settings->worklistlocalefilepath)
 END ;Subroutine
 SUBROUTINE (_::initlocale(str=vc) =null)
   DECLARE tlangid = vc WITH private, noconstant("")
   DECLARE tlanglocaleid = vc WITH private, noconstant("")
   CALL _::setlocale(trim(str,3))
   IF (textlen(_::getlocale(null))=0)
    CALL _::setlocale(_::getdomainlocale(null))
   ELSE
    IF (validate(debug_ind,0)=1)
     CALL echo(build2("Current Domain locale value: ",_::getdomainlocale(null)))
     CALL echo(build2("Overriding locale to: ",str))
    ENDIF
    SET PRIVATE::overrideind = 1
   ENDIF
   CALL _::setlangid(cnvtlower(substring(1,2,_::getlocale(null))))
   CALL _::setlanglocaleid(cnvtupper(substring(4,2,_::getlocale(null))))
   SET tlangid = _::getlangid(null)
   SET tlanglocaleid = _::getlanglocaleid(null)
   CASE (tlangid)
    OF "en":
     CALL _::setlocalefilename("locale")
     CALL _::setlocaleobjectname("en_US")
     IF (((cnvtupper(_::getlocale(null))="EN_AU") OR (cnvtupper(_::getlocale(null))="EN_GB")) )
      CALL _::setlocaleobjectname(concat(tlangid,"_",tlanglocaleid))
      CALL _::setlocalefilename(concat("locale.",tlangid,"_",tlanglocaleid))
      CALL _::setworklistfilename(concat(cnvtupper(tlangid),"_",cnvtupper(tlanglocaleid)))
     ELSE
      CALL _::setworklistfilename("EN_US")
     ENDIF
    OF "es":
    OF "de":
    OF "fr":
    OF "pt":
     CALL _::setlocalefilename(concat("locale.",tlangid))
     CALL _::setlocaleobjectname(concat(tlangid,"_",tlanglocaleid))
     IF (cnvtupper(tlangid)="PT")
      CALL _::setworklistfilename("PT_BR")
     ELSE
      CALL _::setworklistfilename(concat(cnvtupper(tlangid),"_",cnvtupper(tlangid)))
     ENDIF
    ELSE
     CALL _::setlocalefilename("locale")
     CALL _::setlocaleobjectname("en_US")
     CALL _::setworklistfilename("EN_US")
   ENDCASE
   IF ((PRIVATE::overrideind=0))
    CALL uar_i18nlocalizationinit(i18nhandle,nullterm(curprog),nullterm(""),curcclrev)
    CALL _::seti18nhandle(i18nhandle)
   ELSE
    CALL uar_i18nlocalizationinit(i18nhandle,nullterm(curprog),nullterm(_::getlocale(null)),curcclrev
     )
    CALL _::seti18nhandle(i18nhandle)
    IF (validate(debug_ind,0)=1)
     CALL echo("**** OVERRIDING VALUES IN CCLFMT ****")
     CALL echo("CCLFMT BEFORE OVERRIDE:")
     CALL echorecord(cclfmt)
    ENDIF
    EXECUTE cclstartup_locale _::getlocale(null)
    IF (validate(debug_ind,0)=1)
     CALL echo("CCLFMT AFTER OVERRIDE:")
     CALL echorecord(cclfmt)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE _::dump(null)
   CALL echorecord(PRIVATE::settings)
 END ;Subroutine
 IF (validate(log_program_name))
  CALL _::setlogprgname(log_program_name)
 ELSE
  CALL _::setlogprgname(curprog)
 ENDIF
 IF (validate(_mp_18n_override))
  IF (validate(debug_ind,0)=1)
   CALL echorecord(_mp_18n_override)
  ENDIF
  SET PRIVATE::override_prg_global_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5
    ),cnvtupper(_::getlogprgname(null)),cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   0.0,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  SET PRIVATE::override_prg_prsnl_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5),
   cnvtupper(_::getlogprgname(null)),cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   reqinfo->updt_id,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  SET PRIVATE::override_all_global_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5
    ),"ALL",cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   0.0,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  SET PRIVATE::override_all_prsnl_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5),
   "ALL",cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   reqinfo->updt_id,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  IF ((PRIVATE::override_prg_prsnl_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].
     worklistlocalefile)
   ENDIF
  ELSEIF ((PRIVATE::override_all_prsnl_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].
     worklistlocalefile)
   ENDIF
  ELSEIF ((PRIVATE::override_prg_global_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].
     worklistlocalefile)
   ENDIF
  ELSEIF ((PRIVATE::override_all_global_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].
     worklistlocalefile)
   ENDIF
  ENDIF
 ENDIF
 CALL _::initlocale(_::getlocale(null))
 IF (checkfun("LOG_MESSAGE")=7)
  CALL log_message(concat("-mp_i18n Locale file name: ",_::getlocalefilename(null)),log_level_debug)
  CALL log_message(concat("-mp_i18n Worklist Locale file name: ",_::getworklistfilename(null)),
   log_level_debug)
  CALL log_message(concat("-mp_i18n Locale object name: ",_::getlocaleobjectname(null)),
   log_level_debug)
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echo(concat("END MP_I18N object creation, Elapsed time:",cnvtstring(timestampdiff(systimestamp,
      class_begin_ts),17,4)))
  CALL _::dump(null)
 ENDIF
 END; class scope:init
 final
 IF ((PRIVATE::overrideind=1))
  EXECUTE cclstartup_locale _::getdomainlocale(null)
  IF (checkprg("CCLSTARTUP_CUSTREFLOG") > 0)
   EXECUTE cclstartup_custreflog
  ENDIF
  IF (validate(debug_ind,0)=1)
   CALL echo("**** REVERTED OVERRIDDEN VALUES IN CCLFMT ****")
   CALL echo("CCLFMT AFTER OVERRIDE REVERT:")
   CALL echorecord(cclfmt)
  ENDIF
 ENDIF
 END; class scope:final
 WITH copy = 0
 DECLARE MP::i18n = null WITH class(mp_i18n)
 DECLARE getrootpath(null) = vc
 DECLARE processparams(null) = null
 DECLARE generatepagehtml(null) = vc
 DECLARE getlocaledata(null) = null WITH protect
 DECLARE getprsnlname(null) = null WITH protect
 DECLARE getwebserverdefpath(null) = vc WITH protect
 DECLARE webind = i2 WITH protect, noconstant(0)
 DECLARE contentserviceind = i2 WITH protect, noconstant(0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE firebugind = i2 WITH protect, noconstant(0)
 DECLARE jsname = vc WITH protect, noconstant("")
 DECLARE cssname = vc WITH protect, noconstant("")
 DECLARE lpos = i4 WITH protect, noconstant(0)
 DECLARE rpath = vc WITH protect
 DECLARE wbsrvpath = vc WITH protect
 DECLARE ngapp = vc WITH protect, noconstant("")
 DECLARE html_fname = vc
 DECLARE mpage_name = vc
 DECLARE errmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE sscript_name = vc WITH protect, constant("discern_open_mpage")
 DECLARE localeoverideind = i2 WITH protect, noconstant(0)
 DECLARE localefilename = vc WITH protect, noconstant("i18n")
 DECLARE localeobjectname = vc WITH protect, noconstant("en_US")
 DECLARE sieversiontag = vc WITH protect, noconstant("")
 DECLARE timertag = vc WITH protect, noconstant("")
 DECLARE globaljscode = vc WITH protect, noconstant(" ")
 DECLARE parserstring = vc WITH protect, noconstant("")
 SET modify maxvarlen 10000000
 SET criterion->position_cd = reqinfo->position_cd
 SET criterion->prsnl_id = reqinfo->updt_id
 SET criterion->application_id = reqinfo->updt_app
 CALL getprsnlname(null)
 SET sieversiontag = '<meta http-equiv="X-UA-Compatible" content="IE=11">'
 CALL processparams(null)
 IF (findstring("&",html_fname,1,0)=1)
  SET contentserviceind = 1
  SET webind = 1
 ENDIF
 IF ((((reqinfo->updt_app=3202004)) OR (webind=1)) )
  IF (contentserviceind=1)
   SET lpos = 1
  ELSE
   SET lpos = findstring("/",html_fname,1,1)
  ENDIF
 ELSE
  SET lpos = findstring("\",html_fname,1,1)
 ENDIF
 SET mpage_name = substring((lpos+ 1),size(html_fname),html_fname)
 CALL echo(build("MPAGE_NAME ==>",trim(mpage_name)))
 IF (((findstring("$",html_fname,1,0)=1) OR ((reqinfo->updt_app=3202004))) )
  SET html_fname = replace(html_fname,"$","",0)
  SET localefilename = build2(html_fname,"/i18n/i18n.js")
 ELSEIF (contentserviceind=1)
  SET wbsrvpath = getwebserverdefpath(null)
  SET html_fname = build2(wbsrvpath,"/",replace(html_fname,"&","",0))
  SET localefilename = getlocalefilepath(wbsrvpath)
 ELSE
  DECLARE lastchar = vc WITH protect, noconstant("")
  SET rpath = getrootpath(0)
  SET lastchar = substring(textlen(rpath),1,rpath)
  WHILE (((lastchar="\") OR (lastchar="/")) )
   SET rpath = substring(0,(textlen(rpath) - 1),rpath)
   SET lastchar = substring(textlen(rpath),1,rpath)
  ENDWHILE
  SET html_fname = concat(rpath,html_fname)
  SET localefilename = getlocalefilepath(build2(rpath,"\\static_content"))
 ENDIF
 SET criterion->static_content = html_fname
 IF (localeoverideind=0)
  CALL getlocaledata(null)
 ENDIF
 CALL generatepagehtml(null)
 GO TO exit_script
 SUBROUTINE getrootpath(null)
   DECLARE pstr = vc WITH protect
   SELECT INTO "nl"
    FROM dm_info di
    WHERE di.info_name="FE_WH"
    DETAIL
     pstr = trim(di.info_char)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select (DM_INFO):",errmsg)
   ENDIF
   SET lstat = 0
   SET lstat = findstring("winintel",pstr)
   IF (lstat=0)
    SET pstr = concat(pstr,"\winintel")
   ENDIF
   SET pstr = replace(pstr,"\","\\",0)
   SET pstr = replace(pstr,"/","\\",0)
   CALL echo(build("pStr ==>",trim(pstr)))
   RETURN(pstr)
 END ;Subroutine
 SUBROUTINE getprsnlname(null)
  DECLARE prsnl_name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
  SELECT INTO "nl:"
   FROM prsnl p,
    (left JOIN person_name pn ON pn.person_id=p.person_id
     AND pn.name_type_cd=prsnl_name_type_cd
     AND pn.active_ind=1
     AND pn.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND pn.end_effective_dt_tm > cnvtdatetime(sysdate))
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id))
    JOIN (pn)
   ORDER BY p.person_id, pn.end_effective_dt_tm DESC
   HEAD REPORT
    IF (pn.person_id > 0.0)
     criterion->prsnl_name.name_full = pn.name_full
    ELSE
     criterion->prsnl_name.name_full = p.name_full_formatted
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE processparams(null)
   DECLARE par = c20
   DECLARE tempstr = vc
   DECLARE curvcparam = vc
   DECLARE paramname = vc
   SET lnum = 0
   SET num = 2
   SET cnt = 0
   SET cnt2 = 0
   WHILE (num > 0)
     SET tempstr = ""
     SET paramname = ""
     SET par = reflect(parameter(num,0))
     IF (par=" ")
      SET cnt = (num - 1)
      SET num = 0
     ELSE
      IF (substring(1,1,par)="L")
       CALL echo(build("$(",num,")",par))
       SET lnum = 1
       SET criterion->param_cnt += 1
       SET stat = alterlist(criterion->params,criterion->param_cnt)
       WHILE (lnum > 0)
        SET par = reflect(parameter(num,lnum))
        IF (par=" ")
         SET cnt2 = (lnum - 1)
         SET lnum = 0
        ELSE
         CALL echo(build("$(",num,".",lnum,")",
           par,"=",parameter(num,lnum)))
         IF (isnumeric(parameter(num,lnum)))
          SET tempstr = cnvtstring(parameter(num,lnum))
         ELSE
          SET tempstr = parameter(num,lnum)
         ENDIF
         SET tempstr = replace(tempstr,",","@44@")
         SET criterion->params[criterion->param_cnt].value = concat(criterion->params[criterion->
          param_cnt].value,",",tempstr)
         SET lnum += 1
        ENDIF
       ENDWHILE
       SET criterion->params[criterion->param_cnt].value = replace(criterion->params[criterion->
        param_cnt].value,",","",1)
      ELSE
       CALL echo(build("$(",num,")",par,"=",
         parameter(num,lnum)))
       IF (num=2)
        SET html_fname = parameter(num,lnum)
       ELSE
        IF (isnumeric(parameter(num,lnum)))
         SET tempstr = cnvtstring(parameter(num,lnum))
        ELSE
         SET curvcparam = parameter(num,lnum)
         SET lpos = findstring(":",curvcparam,1,0)
         CALL echo(build("location of :",lpos))
         IF (lpos > 0)
          SET paramname = substring(1,(lpos - 1),curvcparam)
          SET tempstr = substring((lpos+ 1),size(curvcparam),curvcparam)
         ELSE
          SET paramname = ""
          SET tempstr = curvcparam
         ENDIF
        ENDIF
        SET tempstr = replace(tempstr,",","@44@")
        SET criterion->param_cnt += 1
        SET stat = alterlist(criterion->params,criterion->param_cnt)
        SET criterion->params[criterion->param_cnt].value = tempstr
        SET criterion->params[criterion->param_cnt].name = paramname
        CALL evaluatenameparam(paramname,tempstr)
       ENDIF
      ENDIF
      SET num += 1
     ENDIF
   ENDWHILE
   IF (size(trim(html_fname,3)) > 0)
    SET criterion->param_cnt += 1
    SET stat = alterlist(criterion->params,criterion->param_cnt)
    SET criterion->params[criterion->param_cnt].value = replace(html_fname,"\","\\")
    SET criterion->params[criterion->param_cnt].name = "STATIC_CONTENT"
   ENDIF
   CALL echo(build("num param=",cnt))
   CALL echo(cnvtupper(html_fname))
   IF (findstring("HTTP:",cnvtupper(html_fname)))
    CALL echo("FOUND IT!")
    SET webind = 1
   ENDIF
   IF ((reqinfo->updt_app != 3202004)
    AND webind=0)
    SET html_fname = replace(html_fname,"\","\\",0)
    SET html_fname = replace(html_fname,"/","\\",0)
   ENDIF
 END ;Subroutine
 SUBROUTINE generatepagehtml(null)
   DECLARE cssfile = vc WITH protect, noconstant(build2(mpage_name,".css"))
   DECLARE jsfile = vc WITH protect, noconstant(build2(mpage_name,".js"))
   DECLARE dateformatsjson = vc WITH protect, noconstant("")
   SET dateformatsjson = replace(cnvtrectojson(datetimeformats,4),"'","\'",0)
   IF (size(trim(cssname,3)) > 0)
    SET cssfile = cssname
   ENDIF
   IF (size(trim(jsname,3)) > 0)
    SET jsfile = jsname
   ENDIF
   SET _memory_reply_string = "<!DOCTYPE html>"
   IF (ngapp > " ")
    SET _memory_reply_string = build2(_memory_reply_string,'<html id="ng-app" lang="en">')
   ELSE
    SET _memory_reply_string = build2(_memory_reply_string,'<html lang="en">')
   ENDIF
   SET _memory_reply_string = build2(_memory_reply_string,'<meta charset="utf-8" /><head>',
    '<meta http-equiv="Content-Type" ',
    'content="APPLINK,CCLLINK,CCLEVENT,MPAGES_EVENT,XMLCCLREQUEST,CCLLINKPOPUP,CCLNEWSESSIONWINDOW,MPAGES_SVC_EVENT" ',
    'name="discern"/><meta http-equiv="X-UA-Compatible" content="IE=11">',
    trim(timertag,3))
   IF (webind=1)
    SET _memory_reply_string = build2(_memory_reply_string,
     '<link rel="stylesheet" type="text/css" charset="UTF-8" href="',criterion->static_content,
     '/css/tcpip-dummy.css" />')
   ENDIF
   SET _memory_reply_string = build2(_memory_reply_string,
    '<link rel="stylesheet" type="text/css" charset="UTF-8" href="',criterion->static_content,"/css/",
    cssfile,
    '" />')
   DECLARE criterionstr = vc WITH noconstant("")
   DECLARE configstr = vc WITH noconstant("")
   SET criterionstr = replace(cnvtrectojson(criterion),"'","&#39;",0)
   SET _memory_reply_string = build2(_memory_reply_string,
    '	<script type="text/javascript" charset="UTF-8">',"	var m_criterionJSON = '",criterionstr,"';",
    "   var m_dateformatJSON = '",dateformatsjson,"';"," var m_localeObjectName = '",localeobjectname,
    "';",'	var CERN_static_content = "',criterion->static_content,'";',trim(globaljscode,3),
    "</script>")
   SET _memory_reply_string = build2(_memory_reply_string,
    '<script type="text/javascript" charset="UTF-8" src="',localefilename,'"></script>',
    '<script type="text/javascript" charset="UTF-8" src="',
    criterion->static_content,"/js/",jsfile,'"></script>')
   IF (firebugind=1)
    SET _memory_reply_string = build2(_memory_reply_string,
     '<script type="text/javascript" src="https://getfirebug.com/firebug-lite.js"></script>')
   ENDIF
   SET _memory_reply_string = build2(_memory_reply_string,"</head>")
   IF (ngapp > " ")
    SET _memory_reply_string = build2(_memory_reply_string,"<body ng-app='",ngapp,"'>",
     "<base-layout/>",
     "</body>")
   ELSE
    SET _memory_reply_string = build2(_memory_reply_string,"<body></body>")
   ENDIF
   SET _memory_reply_string = build2(_memory_reply_string,"</html>")
   CALL echo(build2("Page HTML: ",_memory_reply_string))
 END ;Subroutine
 SUBROUTINE (evaluatenameparam(name=vc,value=vc) =null)
   CASE (cnvtupper(name))
    OF "APP_ID":
     SET criterion->application_id = cnvtreal(value)
    OF "BROWSER":
     IF (value="1")
      SET criterion->browser_ind = 1
     ENDIF
    OF "FIREBUG":
     IF (value="1")
      SET firebugind = 1
     ENDIF
    OF "DEBUG":
     IF (value="1")
      SET criterion->debug_ind = 1
     ENDIF
    OF "READONLY":
     IF (value="1")
      SET criterion->read_only = 1
     ENDIF
    OF "JSNAME":
     SET jsname = value
    OF "CSSNAME":
     SET cssname = value
    OF "ZOOM_LEVEL":
     SET _zoom_level = cnvtreal(value)
    OF "TIMER_NAME":
     DECLARE pos = i4 WITH noconstant(0), protect
     DECLARE timername = vc WITH noconstant(trim(replace(value,"@44@",","),3)), protect
     DECLARE subtimername = vc WITH noconstant(""), protect
     SET pos = findstring(";",timername)
     IF (pos > 0)
      SET subtimername = substring((pos+ 1),(size(timername,1) - pos),timername)
      SET timername = substring(1,(pos - 1),timername)
     ENDIF
     SET timertag = build2('	<script type="text/javascript" charset="UTF-8">',
      "	var _loadTimer = null;","	try{",
      '		_loadTimer = window.external.DiscernObjectFactory("SLATIMER");','		_loadTimer.TimerName = "',
      timername,'";','		_loadTimer.SubtimerName = "',subtimername,'";',
      "		_loadTimer.Start();","	}catch(err){}","	</script>")
    OF "GLOBAL_JS":
     RECORD globaljsrep(
       1 globaljs = vc
     )
     SET parserstring = build2("execute ",trim(value,3),' with replace ("REPLY", "GLOBALJSREP") go')
     CALL parser(parserstring)
     SET globaljscode = globaljsrep->globaljs
     CALL echo(build2("GLOBAL JS:",globaljscode))
     FREE RECORD globaljsrep
    OF "APPLICATION_NAME":
     SET criterion->application_name = cnvtupper(value)
    OF "LOCALE":
     SET localeoverideind = 1
     SET localeobjectname = value
     SET criterion->current_locale = cnvtupper(value)
     CALL MP::i18n.initlocale(localeobjectname)
     CALL MP::i18n.generatemasks(null)
    OF "NG-APP":
     SET ngapp = value
   ENDCASE
 END ;Subroutine
 SUBROUTINE getlocaledata(null)
   DECLARE locale = vc WITH protect, noconstant("")
   DECLARE langid = vc WITH noconstant(""), protect
   DECLARE langlocaleid = vc WITH noconstant(""), protect
   SET locale = cnvtupper(logical("CCL_LANG"))
   IF (locale="")
    SET locale = cnvtupper(logical("LANG"))
   ENDIF
   SET locale = substring(1,5,locale)
   SET langid = cnvtlower(substring(1,2,locale))
   SET langlocaleid = cnvtupper(substring(4,2,locale))
   SET localeobjectname = concat(langid,"_",langlocaleid)
   SET criterion->current_locale = localeobjectname
   CALL MP::i18n.initlocale(localeobjectname)
   CALL MP::i18n.generatemasks(null)
   CALL echo(build("-Locale file name: ",localefilename," -Locale object name: ",localeobjectname))
 END ;Subroutine
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET lstat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = sscript_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE getwebserverdefpath(null)
   DECLARE contentserverurl = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="INS"
     AND d.info_name="CONTENT_SERVICE_URL"
    DETAIL
     contentserverurl = trim(d.info_char,3)
    WITH nocounter
   ;end select
   RETURN(contentserverurl)
 END ;Subroutine
 SUBROUTINE (getlocalefilepath(path=vc) =vc)
   DECLARE transstr = vc WITH protect, noconstant("")
   DECLARE pathstr = vc WITH protect, noconstant("")
   DECLARE lastchar = vc WITH protect, noconstant("")
   SET pathstr = trim(path)
   SET lastchar = substring(textlen(pathstr),1,pathstr)
   WHILE (((lastchar="\") OR (lastchar="/")) )
    SET pathstr = substring(0,(textlen(pathstr) - 1),pathstr)
    SET lastchar = substring(textlen(pathstr),1,pathstr)
   ENDWHILE
   IF ((criterion->application_name != ""))
    SELECT INTO "nl"
     FROM dm_info di
     WHERE di.info_domain="TRANS"
      AND (di.info_name=criterion->application_name)
     DETAIL
      transstr = trim(di.info_char)
     WITH nocounter
    ;end select
    IF (transstr="")
     RETURN(build2(path,"//",cnvtlower(criterion->application_name),"//i18n//i18n.js"))
    ELSE
     SET transstr = replace(transstr,"\","\\",0)
     SET transstr = replace(transstr,"/","\\",0)
     RETURN(build2(pathstr,transstr))
    ENDIF
   ENDIF
   RETURN(build2(html_fname,"//i18n//i18n.js"))
 END ;Subroutine
#exit_script
 CALL echorecord(criterion)
 SET modify = maxvarlen
END GO
