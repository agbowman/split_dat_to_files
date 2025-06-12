CREATE PROGRAM dd_get_mpage_structure_url:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
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
 IF (validate(debug_ind,0)=1)
  DECLARE MP_I18N::ns_create_start = dq8 WITH constant(curtime3)
  CALL echo("BEGIN MP_I18N namespace creation")
 ENDIF
 IF ( NOT (validate(MP_I18N::settings,0)))
  RECORD MP_I18N::settings(
    1 i18nhandle = i4
    1 locale = vc
    1 localeobjectname = vc
    1 localefilename = vc
  )
 ENDIF
 DECLARE MP_I18N::locale = vc WITH protect, noconstant("")
 DECLARE MP_I18N::langid = vc WITH protect, noconstant("")
 DECLARE MP_I18N::langlocaleid = vc WITH protect, noconstant("")
 DECLARE MP_I18N::logprgname = vc WITH protect, noconstant("")
 DECLARE MP_I18N::overrideind = i2 WITH protect, noconstant(0)
 DECLARE MP_I18N::locidx = i4 WITH protect, noconstant(0)
 DECLARE MP_I18N::override_prg_global_pos = i4 WITH protect, noconstant(0)
 DECLARE MP_I18N::override_prg_prsnl_pos = i4 WITH protect, noconstant(0)
 DECLARE MP_I18N::override_all_global_pos = i4 WITH protect, noconstant(0)
 DECLARE MP_I18N::override_all_prsnl_pos = i4 WITH protect, noconstant(0)
 DECLARE MP_I18N::override_prg_global_str = vc WITH protect, noconstant("")
 DECLARE MP_I18N::override_prg_user_str = vc WITH protect, noconstant("")
 DECLARE MP_I18N::override_all_global_str = vc WITH protect, noconstant("")
 DECLARE MP_I18N::override_all_usr_str = vc WITH protect, noconstant("")
 DECLARE MP_I18N::override_prg_global_val = vc WITH protect, noconstant("")
 DECLARE MP_I18N::override_prg_user_val = vc WITH protect, noconstant("")
 DECLARE MP_I18N::override_all_global_val = vc WITH protect, noconstant("")
 DECLARE MP_I18N::override_all_usr_val = vc WITH protect, noconstant("")
 DECLARE MP_I18N::getlocale(null) = vc WITH protect
 DECLARE MP_I18N::getlocaleobjectname(null) = vc WITH protect
 DECLARE MP_I18N::getlocalefilename(null) = vc WITH protect
 DECLARE MP_I18N::dump(null) = null WITH protect
 SUBROUTINE (MP_I18N::setlocale(str=vc) =null WITH protect)
   SET mp_i18n::settings->locale = str
 END ;Subroutine
 SUBROUTINE (MP_I18N::setlocaleobjectname(str=vc) =null WITH protect)
   SET mp_i18n::settings->localeobjectname = str
 END ;Subroutine
 SUBROUTINE (MP_I18N::setlocalefilename(str=vc) =null WITH protect)
   SET mp_i18n::settings->localefilename = str
 END ;Subroutine
 SUBROUTINE (MP_I18N::seti18nhandle(val=i4) =null WITH protect)
   SET mp_i18n::settings->i18nhandle = val
 END ;Subroutine
 SUBROUTINE MP_I18N::getlocale(null)
   RETURN(mp_i18n::settings->locale)
 END ;Subroutine
 SUBROUTINE MP_I18N::getlocaleobjectname(null)
   RETURN(mp_i18n::settings->localeobjectname)
 END ;Subroutine
 SUBROUTINE MP_I18N::getlocalefilename(null)
   RETURN(mp_i18n::settings->localefilename)
 END ;Subroutine
 SUBROUTINE (MP_I18N::geti18nhandle(val=i4) =null WITH protect)
   RETURN(mp_i18n::settings->i18nhandle)
 END ;Subroutine
 SUBROUTINE (MP_I18N::initlocale(str=vc) =null WITH protect)
   SET MP_I18N::locale = trim(str,3)
   IF (textlen(MP_I18N::locale)=0)
    SET MP_I18N::locale = cnvtupper(logical("CCL_LANG"))
    IF ((MP_I18N::locale=""))
     SET MP_I18N::locale = cnvtupper(logical("LANG"))
    ENDIF
   ELSE
    IF (validate(debug_ind,0)=1)
     CALL echo(build2("Overriding locale to: ",str))
    ENDIF
    SET MP_I18N::overrideind = 1
   ENDIF
   SET MP_I18N::langid = cnvtlower(substring(1,2,MP_I18N::locale))
   SET MP_I18N::langlocaleid = cnvtupper(substring(4,2,MP_I18N::locale))
   CASE (MP_I18N::langid)
    OF "en":
     CALL MP_I18N::setlocalefilename("locale")
     CALL MP_I18N::setlocaleobjectname("en_US")
     IF (((cnvtupper(MP_I18N::locale)="EN_AU") OR (cnvtupper(MP_I18N::locale)="EN_GB")) )
      CALL MP_I18N::setlocaleobjectname(concat(MP_I18N::langid,"_",MP_I18N::langlocaleid))
      CALL MP_I18N::setlocalefilename(concat("locale.",MP_I18N::langid,"_",MP_I18N::langlocaleid))
      CALL MP_I18N::setlocale(substring(1,5,MP_I18N::locale))
     ELSE
      CALL MP_I18N::setlocale("EN_US")
     ENDIF
    OF "es":
     CALL MP_I18N::setlocalefilename(concat("locale.",MP_I18N::langid))
     CALL MP_I18N::setlocaleobjectname("es_ES")
     CALL MP_I18N::setlocale("ES_ES")
    OF "de":
     CALL MP_I18N::setlocalefilename(concat("locale.",MP_I18N::langid))
     CALL MP_I18N::setlocaleobjectname("de_DE")
     CALL MP_I18N::setlocale("DE_DE")
    OF "fr":
     CALL MP_I18N::setlocalefilename(concat("locale.",MP_I18N::langid))
     CALL MP_I18N::setlocaleobjectname("fr_FR")
     CALL MP_I18N::setlocale("FR_FR")
    OF "pt":
     CALL MP_I18N::setlocalefilename(concat("locale.",MP_I18N::langid))
     CALL MP_I18N::setlocaleobjectname("pt_BR")
     CALL MP_I18N::setlocale("PT_BR")
    OF "nl":
     CALL MP_I18N::setlocaleobjectname(concat(MP_I18N::langid,"_",MP_I18N::langlocaleid))
     CALL MP_I18N::setlocalefilename(concat("locale.",MP_I18N::langid,"_",MP_I18N::langlocaleid))
     CALL MP_I18N::setlocale(substring(1,5,MP_I18N::locale))
    OF "sv":
     CALL MP_I18N::setlocalefilename(concat("locale.",MP_I18N::langid))
     CALL MP_I18N::setlocaleobjectname("sv_SE")
     CALL MP_I18N::setlocale("SV_SE")
    ELSE
     CALL MP_I18N::setlocalefilename("locale")
     CALL MP_I18N::setlocaleobjectname("en_US")
     CALL MP_I18N::setlocale("EN_US")
   ENDCASE
   IF ((MP_I18N::overrideind=0))
    CALL uar_i18nlocalizationinit(mp_i18n::settings->i18nhandle,curprog,"",curcclrev)
   ELSE
    CALL uar_i18nlocalizationinit(mp_i18n::settings->i18nhandle,curprog,MP_I18N::getlocale(null),
     curcclrev)
   ENDIF
   SET i18nhandle = mp_i18n::settings->i18nhandle
 END ;Subroutine
 SUBROUTINE MP_I18N::dump(null)
   CALL echorecord(MP_I18N::settings)
 END ;Subroutine
 IF (validate(log_program_name))
  SET MP_I18N::logprgname = log_program_name
 ELSE
  SET MP_I18N::logprgname = curprog
 ENDIF
 IF (validate(_mp_18n_override))
  IF (validate(debug_ind,0)=1)
   CALL echorecord(_mp_18n_override)
  ENDIF
  SET MP_I18N::override_prg_global_pos = locateval(MP_I18N::locidx,1,size(_mp_18n_override->scripts,5
    ),cnvtupper(MP_I18N::logprgname),cnvtupper(_mp_18n_override->scripts[MP_I18N::locidx].name),
   0.0,_mp_18n_override->scripts[MP_I18N::locidx].prsnl_id)
  SET MP_I18N::override_prg_prsnl_pos = locateval(MP_I18N::locidx,1,size(_mp_18n_override->scripts,5),
   cnvtupper(MP_I18N::logprgname),cnvtupper(_mp_18n_override->scripts[MP_I18N::locidx].name),
   reqinfo->updt_id,_mp_18n_override->scripts[MP_I18N::locidx].prsnl_id)
  SET MP_I18N::override_all_global_pos = locateval(MP_I18N::locidx,1,size(_mp_18n_override->scripts,5
    ),"ALL",cnvtupper(_mp_18n_override->scripts[MP_I18N::locidx].name),
   0.0,_mp_18n_override->scripts[MP_I18N::locidx].prsnl_id)
  SET MP_I18N::override_all_prsnl_pos = locateval(MP_I18N::locidx,1,size(_mp_18n_override->scripts,5),
   "ALL",cnvtupper(_mp_18n_override->scripts[MP_I18N::locidx].name),
   reqinfo->updt_id,_mp_18n_override->scripts[MP_I18N::locidx].prsnl_id)
  IF ((MP_I18N::override_prg_prsnl_pos > 0))
   SET MP_I18N::locale = _mp_18n_override->scripts[MP_I18N::override_prg_prsnl_pos].locale
  ELSEIF ((MP_I18N::override_all_prsnl_pos > 0))
   SET MP_I18N::locale = _mp_18n_override->scripts[MP_I18N::override_all_prsnl_pos].locale
  ELSEIF ((MP_I18N::override_prg_global_pos > 0))
   SET MP_I18N::locale = _mp_18n_override->scripts[MP_I18N::override_prg_global_pos].locale
  ELSEIF ((MP_I18N::override_all_global_pos > 0))
   SET MP_I18N::locale = _mp_18n_override->scripts[MP_I18N::override_all_global_pos].locale
  ENDIF
 ENDIF
 CALL MP_I18N::initlocale(MP_I18N::locale)
 IF (checkfun("LOG_MESSAGE")=7)
  CALL log_message(build("-Locale file name: ",mp_i18n::settings->localefilename,
    " -Locale object name: ",mp_i18n::settings->localeobjectname),log_level_debug)
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echo(concat("END MP_I18N Namespace creation, Elapsed time:",cnvtstring(((curtime3 - MP_I18N::
     ns_create_start)/ 100.0),11,2)))
  CALL MP_I18N::dump(null)
 ENDIF
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE current_time_zone = i4 WITH constant(datetimezonebyname(curtimezone)), protect
 DECLARE ending_date_time = dq8 WITH constant(cnvtdatetime("31-DEC-2100")), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE codelistcnt = i4 WITH noconstant(0), protect
 DECLARE prsnllistcnt = i4 WITH noconstant(0), protect
 DECLARE code_idx = i4 WITH noconstant(0), protect
 DECLARE prsnl_idx = i4 WITH noconstant(0), protect
 SUBROUTINE (putstringtofile(svalue=vc(val)) =null WITH protect)
  DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
  IF (validate(_memory_reply_string)=1)
   SET _memory_reply_string = svalue
  ELSE
   FREE RECORD putrequest
   RECORD putrequest(
     1 source_dir = vc
     1 source_filename = vc
     1 nbrlines = i4
     1 line[*]
       2 linedata = vc
     1 overflowpage[*]
       2 ofr_qual[*]
         3 ofr_line = vc
     1 isblob = c1
     1 document_size = i4
     1 document = gvc
   )
   SET putrequest->source_dir =  $OUTDEV
   SET putrequest->isblob = "1"
   SET putrequest->document = svalue
   SET putrequest->document_size = size(putrequest->document)
   EXECUTE eks_put_source  WITH replace("REQUEST",putrequest), replace("REPLY",putreply)
  ENDIF
 END ;Subroutine
 SUBROUTINE (putjsonrecordtofile(record_data=vc(ref)) =null WITH protect)
  DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
  CALL putstringtofile(cnvtrectojson(record_data))
 END ;Subroutine
 DECLARE getcontentserverurl(null) = null WITH protect
 DECLARE generatecontenttags(null) = null WITH protect
 DECLARE contentserverurl = vc WITH protect, noconstant("")
 DECLARE static_content_folder = vc WITH protect, constant("UnifiedContent")
 RECORD reply(
   1 locale_js = gvc
   1 structure_js = gvc
   1 structure_css = gvc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 CALL getcontentserverurl(null)
 CALL generatecontenttags(null)
 SUBROUTINE getcontentserverurl(null)
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="INS"
    AND d.info_name="CONTENT_SERVICE_URL"
   DETAIL
    contentserverurl = build2(trim(d.info_char,3),"/",static_content_folder)
   WITH nocounter
  ;end select
  IF (((contentserverurl="") OR (contentserverurl=build2("/",static_content_folder))) )
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationname = "GetContentServerURL"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "No static content server OR static content file location defined in CONTENT_SERVICE_URL"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE generatecontenttags(null)
   SET reply->locale_js = build2(contentserverurl,"/js/locale/",MP_I18N::getlocalefilename(null),
    ".js")
   SET reply->structure_js = build2(contentserverurl,"/js/structured-modal.js")
   SET reply->structure_css = build2(contentserverurl,"/css/structured-modal.css")
   SET reply->status_data.status = "S"
 END ;Subroutine
#exit_script
 CALL putjsonrecordtofile(reply)
END GO
