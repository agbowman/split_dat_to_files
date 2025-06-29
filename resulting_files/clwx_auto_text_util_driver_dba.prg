CREATE PROGRAM clwx_auto_text_util_driver:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Personnel ID:" = 0.00,
  "Static Content Location:" = "",
  "Override Locale:" = ""
  WITH outdev, personnelid, staticcontentlocation,
  locale_override
 FREE RECORD criterion
 RECORD criterion(
   1 domain = vc
   1 static_content = vc
   1 prsnl_id = f8
   1 locale_id = vc
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
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
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
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
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
 DECLARE error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2,
  recorddata=vc(ref)) = i2
 SUBROUTINE error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,recorddata)
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
 DECLARE error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2) = i2
 SUBROUTINE error_and_zero_check(qualnum,opname,logmsg,errorforceexit,zeroforceexit)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 DECLARE populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) = i2
 SUBROUTINE populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,
  targetobjectvalue,recorddata)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].operationstatus)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectname)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectvalue)))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt = (lcrslsubeventcnt+ 1)
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
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CLWX_AUTO_TEXT_UTIL_DRIVER"
 DECLARE vcjsreqs = vc WITH protect, noconstant("")
 DECLARE vccssreqs = vc WITH protect, noconstant("")
 DECLARE vcjsrenderfunc = vc WITH protect, noconstant("")
 DECLARE vcpagelayout = vc WITH protect, noconstant("")
 DECLARE vcstaticcontent = vc WITH protect, noconstant("")
 DECLARE localefilename = vc WITH noconstant(""), protect
 DECLARE localeobjectname = vc WITH noconstant(""), protect
 DECLARE user_id = vc WITH public, noconstant("1=1")
 IF ((validate(debug_ind,- (99))=- (99)))
  DECLARE debug_ind = i2 WITH protect, noconstant(0)
 ENDIF
 SET criterion->prsnl_id =  $PERSONNELID
 SET criterion->locale_id =  $LOCALE_OVERRIDE
 SET criterion->static_content =  $STATICCONTENTLOCATION
 SET criterion->domain = trim(curdomain)
 CALL getstaticcontentloc(null)
 CALL getlocaledata(null)
 CALL generatestaticcontentreqs(null)
 CALL generatepagehtml(null)
 SUBROUTINE getstaticcontentloc(null)
   CALL log_message("In GetStaticContentLoc()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE contentserverurl = vc WITH noconstant("")
   IF (size(trim(criterion->static_content,3))=0)
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="INS"
      AND d.info_name="CONTENT_SERVICE_URL"
     DETAIL
      contentserverurl = trim(d.info_char,3)
     WITH nocounter
    ;end select
    CALL error_and_zero_check_rec(curqual,"STATIC_CONTENT","GetStaticContentLoc",1,0,
     criterion)
    IF (contentserverurl="")
     SET _memory_reply_string =
     "No Static Content passed to script or defined in CONTENT_SERVICE_URL"
     GO TO exit_script
    ENDIF
    SET criterion->static_content = build2(contentserverurl,
     "/custom_mpage_content/clwx_auto_text_util")
   ENDIF
   CALL log_message(build("Exit GetStaticContentLoc(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getlocaledata(null)
   CALL log_message("In GetLocaleData()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE locale = vc WITH protect, noconstant("")
   DECLARE lang_id = vc WITH noconstant(""), protect
   DECLARE lang_locale_id = vc WITH noconstant(""), protect
   IF (size(trim(criterion->locale_id,3))=0)
    SET locale = cnvtupper(logical("CCL_LANG"))
    IF (locale="")
     SET locale = cnvtupper(logical("LANG"))
    ENDIF
    SET criterion->locale_id = locale
   ELSE
    SET locale = cnvtupper(criterion->locale_id)
   ENDIF
   SET lang_id = cnvtlower(substring(1,2,locale))
   SET lang_locale_id = cnvtlower(substring(4,2,locale))
   CASE (lang_id)
    OF "en":
     IF (lang_locale_id="au")
      SET localefilename = "locale.en_AU"
      SET localeobjectname = "en_AU"
     ELSEIF (lang_locale_id="gb")
      SET localefilename = "locale.en_GB"
      SET localeobjectname = "en_GB"
     ELSE
      SET localefilename = "locale"
      SET localeobjectname = "en_US"
     ENDIF
    OF "es":
     SET localefilename = "locale.es"
     SET localeobjectname = "es_ES"
    OF "de":
     SET localefilename = "locale.de"
     SET localeobjectname = "de_DE"
    OF "fr":
     SET localefilename = "locale.fr"
     SET localeobjectname = "fr_FR"
    OF "nl":
     SET localefilename = "locale.nl"
     SET localeobjectname = "nl_NL"
    OF "pt":
     SET localefilename = "locale.pt_BR"
     SET localeobjectname = "pt_BR"
    OF "sv":
     SET localefilename = "locale.sv"
     SET localeobjectname = "sv_SE"
    ELSE
     SET localefilename = "locale"
     SET localeobjectname = "en_US"
   ENDCASE
   CALL log_message(build("Exit GetLocaleData(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE generatestaticcontentreqs(null)
   CALL log_message("In GenerateStaticContentReqs()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   SET vcjsreqs = build2('<script type="text/javascript" src="',criterion->static_content,
    '/js/externallib/blackbird.js"></script>')
   SET vcjsreqs = build2(vcjsreqs,'<script type="text/javascript" src="',criterion->static_content,
    '/js/externallib/timer.js"></script>')
   SET vcjsreqs = build2(vcjsreqs,'<script type="text/javascript" src="',criterion->static_content,
    "/js/locale/",localefilename,
    '.js"></script>')
   SET vcjsreqs = build2(vcjsreqs,'<script type="text/javascript" src="',criterion->static_content,
    '/js/clwx_auto_text.js"></script>')
   SET vccssreqs = build2('<link rel="stylesheet" type="text/css" href="',criterion->static_content,
    '/css/clwx_auto_text.css" />')
   CALL log_message(build("Exit GenerateStaticContentReqs(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE generatepagehtml(null)
   CALL log_message("In GeneratePageHTML()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   SET _memory_reply_string = build("<!DOCTYPE html>","<html>","<head>",
    '<meta http-equiv="X-UA-Compatible" content="IE=11">','<meta http-equiv="Content-Type"',
    'content="APPLINK,CCLLINK,MPAGES_EVENT,XMLCCLREQUEST,CCLLINKPOPUP,CCLNEWSESSIONWINDOW" name="discern"/>',
    vccssreqs,vcjsreqs,'<script type="text/javascript">',"var m_criterionJSON = '",
    replace(cnvtrectojson(criterion),"'","\'"),"';",'var CERN_static_content = "',criterion->
    static_content,'";',
    "</script>","</head>","<body>","</body>","</html>")
   IF (debug_ind=1)
    CALL log_message(_memory_reply_string,log_level_debug)
   ENDIF
   CALL log_message(build("Exit GeneratePageHTML(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 IF (debug_ind=1)
  CALL echorecord(criterion)
 ENDIF
END GO
