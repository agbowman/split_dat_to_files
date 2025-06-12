CREATE PROGRAM dcp_get_gc_print_info:dba
 FREE RECORD reply
 RECORD reply(
   1 patients[*]
     2 person_id = f8
     2 patient_name = vc
     2 dob = vc
     2 mrn = vc
     2 sex = f8
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state = vc
     2 country = vc
     2 zip = vc
     2 comm_subject_cd = f8
     2 comm_subject_txt = vc
     2 encntr_id = f8
   1 msg_subject = vc
   1 msg_txt = vc
   1 sender_prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
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
 DECLARE getpatientinfo(null) = null
 DECLARE getmsginfo(null) = null
 DECLARE replyfailure(targetobjname,errordescription) = null
 DECLARE letter_comm_type_flag = i4 WITH protect, constant(2)
 DECLARE person_alias_type_cd_set = i4 WITH protect, constant(4)
 DECLARE mrn_person_alias_type_cd = i4 WITH protect, constant(uar_get_code_by("MEANING",
   person_alias_type_cd_set,"MRN"))
 DECLARE home_address_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mail_address_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"MAILING"))
 DECLARE alternate_address_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"ALTERNATE"))
 DECLARE business_address_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE temporary_address_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"TEMPORARY"))
 SET errmsg = fillstring(132," ")
 SET errcode = error(errmsg,1)
 SET reply->status_data.status = "Z"
 CALL getpatientinfo(null)
 CALL getmsginfo(null)
#exit_script
 IF ((reply->status_data.status != "F"))
  SET reply->status_data.status = "S"
  SET errcode = error(errmsg,0)
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE getpatientinfo(null)
   CALL log_message("Begin getPatientInfo()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE person_cnt = i4 WITH noconstant(0)
   DECLARE current_priority = i4 WITH noconstant(0), private
   DECLARE lowest_priority = i4 WITH noconstant(0), private
   DECLARE business_priority = i4 WITH noconstant(0), private
   DECLARE alternate_priority = i4 WITH noconstant(0), private
   DECLARE mail_priority = i4 WITH noconstant(0), private
   DECLARE home_priority = i4 WITH noconstant(0), private
   DECLARE usethisaddress = i2 WITH noconstant(0), private
   SELECT INTO "nl:"
    FROM dcp_mp_pl_comm gc,
     dcp_mp_pl_comm_patient gcp,
     person p,
     person_alias pa,
     address a
    PLAN (gc
     WHERE (gc.broadcast_ident_uuid=request->broadcast_id)
      AND gc.active_ind=1)
     JOIN (gcp
     WHERE gcp.dcp_mp_pl_comm_id=gc.dcp_mp_pl_comm_id
      AND gcp.comm_type_flag=letter_comm_type_flag
      AND gcp.active_ind=1)
     JOIN (p
     WHERE p.person_id=gcp.person_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (pa
     WHERE pa.person_id=gcp.person_id
      AND pa.person_alias_type_cd=mrn_person_alias_type_cd
      AND pa.active_ind=1
      AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (a
     WHERE (a.parent_entity_id= Outerjoin(gcp.person_id))
      AND (a.parent_entity_name= Outerjoin("PERSON"))
      AND (a.active_ind= Outerjoin(1))
      AND (a.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (a.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY p.name_last_key, p.name_first_key, p.name_middle_key,
     p.person_id
    HEAD REPORT
     person_cnt = 0
    HEAD p.person_id
     person_cnt += 1
     IF (mod(person_cnt,50)=1)
      stat = alterlist(reply->patients,(person_cnt+ 49))
     ENDIF
     reply->patients[person_cnt].person_id = p.person_id, reply->patients[person_cnt].patient_name =
     p.name_full_formatted, reply->patients[person_cnt].dob = datetimezoneformat(p.birth_dt_tm,p
      .birth_tz,"@SHORTDATE4YR"),
     reply->patients[person_cnt].sex = p.sex_cd, reply->patients[person_cnt].mrn = cnvtalias(pa.alias,
      pa.alias_pool_cd), reply->patients[person_cnt].encntr_id = gcp.encntr_id,
     lowest_priority = 6, temporary_priority = 5, business_priority = 4,
     alternate_priority = 3, mail_priority = 2, home_priority = 1,
     current_priority = lowest_priority
    DETAIL
     usethisaddress = 0
     CASE (a.address_type_cd)
      OF home_address_cd:
       IF (current_priority > home_priority)
        usethisaddress = 1, current_priority = home_priority
       ENDIF
      OF mail_address_cd:
       IF (current_priority > mail_priority)
        usethisaddress = 1, current_priority = mail_priority
       ENDIF
      OF alternate_address_cd:
       IF (current_priority > alternate_priority)
        usethisaddress = 1, current_priority = alternate_priority
       ENDIF
      OF business_address_cd:
       IF (current_priority > business_priority)
        usethisaddress = 1, current_priority = business_priority
       ENDIF
      OF temporary_address_cd:
       IF (current_priority > temporary_priority)
        usethisaddress = 1, current_priority = temporary_priority
       ENDIF
     ENDCASE
     IF (usethisaddress=1)
      reply->patients[person_cnt].street_addr = a.street_addr, reply->patients[person_cnt].
      street_addr2 = a.street_addr2, reply->patients[person_cnt].street_addr3 = a.street_addr3,
      reply->patients[person_cnt].street_addr4 = a.street_addr4
      IF (a.city_cd > 0.0)
       reply->patients[person_cnt].city = uar_get_code_display(a.city_cd)
      ELSE
       reply->patients[person_cnt].city = a.city
      ENDIF
      IF (a.state_cd > 0.0)
       reply->patients[person_cnt].state = uar_get_code_display(a.state_cd)
      ELSE
       reply->patients[person_cnt].state = a.state
      ENDIF
      reply->patients[person_cnt].zip = a.zipcode
      IF (a.country_cd > 0.0)
       reply->patients[person_cnt].country = uar_get_code_display(a.country_cd)
      ELSE
       reply->patients[person_cnt].country = a.country
      ENDIF
     ENDIF
     reply->patients[person_cnt].comm_subject_cd = gc.comm_subject_cd, reply->patients[person_cnt].
     comm_subject_txt = gc.comm_subject_txt
    FOOT REPORT
     stat = alterlist(reply->patients,person_cnt)
    WITH nocounter
   ;end select
   CALL log_message(build2("End getPatientInfo(), Elapsed time:",cnvtint((curtime3 - begin_time)),
     "0 ms "),log_level_debug)
   IF (size(reply->patients,5)=0)
    CALL replyfailure("getPatientInfo",build2("No patients found for broadcast ", $BROADCAST_ID))
   ENDIF
 END ;Subroutine
 SUBROUTINE getmsginfo(null)
   CALL log_message("In getMsgInfo()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   SELECT INTO "nl:"
    FROM dcp_mp_pl_comm gc,
     long_blob lb
    PLAN (gc
     WHERE (gc.broadcast_ident_uuid=request->broadcast_id)
      AND gc.active_ind=1)
     JOIN (lb
     WHERE lb.long_blob_id=gc.msg_long_blob_id
      AND lb.active_ind=1)
    DETAIL
     reply->msg_txt = lb.long_blob, reply->msg_subject = gc.comm_subject_txt, reply->sender_prsnl_id
      = gc.sender_prsnl_id
    WITH nocounter
   ;end select
   CALL log_message(build2("End getMsgInfo(), Elapsed time:",cnvtint((curtime3 - begin_time)),"0 ms"),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE replyfailure(targetobjname,errordescription)
   CALL log_message("In replyFailure()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "MP_DCP_GET_GC_PRINT_INFO"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjname
   IF (trim(errmsg)="")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errordescription
    CALL log_message(build("Error: ",targetobjname," - ",errordescription),log_level_error)
   ELSE
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
    CALL log_message(build("Error: ",targetobjname," - ",trim(errmsg)),log_level_error)
   ENDIF
   CALL log_message(build2("End replyFailure(), Elapsed time:",cnvtint((curtime3 - begin_time)),
     "0 ms"),log_level_debug)
   GO TO exit_script
 END ;Subroutine
END GO
