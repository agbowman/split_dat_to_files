CREATE PROGRAM bhs_pex_procedure:dba
 RECORD reply(
   1 text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 RECORD rtfcontainer(
   1 rtflinecount = i4
   1 rtflines[*]
     2 rtfline = vc
 ) WITH protect
 RECORD procedurehx(
   1 itemcount = i4
   1 items[*]
     2 proceduredate = vc
     2 procedurename = vc
     2 laterality = vc
 ) WITH protect
 RECORD con_sys(
   1 system_cnt = i4
   1 systems[*]
     2 system_code = f8
 ) WITH protect
 RECORD applications(
   1 apps[*]
     2 app_num = i4
 ) WITH protect
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
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE rtf_head = vc WITH public, constant(build2("{\rtf1\ansi\deff0{\fonttbl",
   "{\f0\fswiss\fprq0\fcharset0 Microsoft Sans Serif;}}\f0\fs18 "))
 DECLARE rtf_eol = vc WITH public, constant("\par ")
 DECLARE rtf_ln = vc WITH public, constant("\line ")
 DECLARE rtf_r0 = vc WITH public, constant("\plain\f0\fs18 ")
 DECLARE rtf_b0 = vc WITH public, constant("\plain\f0\fs18\b ")
 DECLARE rtf_i0 = vc WITH public, constant("\plain\f0\fs18\i ")
 DECLARE rtf_bi0 = vc WITH public, constant("\plain\f0\fs18\b\i ")
 DECLARE rtf_bu0 = vc WITH public, constant("\plain\f0\fs18\b\ul ")
 DECLARE rtf_biu0 = vc WITH public, constant("\plain\f0\fs18\i\b\ul ")
 DECLARE rtf_u0 = vc WITH public, constant("\plain\f0\fs18\ul ")
 DECLARE rtf_iu0 = vc WITH public, constant("\plain\f0\fs18\i\ul ")
 DECLARE rtf_st0 = vc WITH public, constant("\plain\f0\fs18\strike")
 DECLARE rtf_left = vc WITH public, constant("\ql ")
 DECLARE rtf_center = vc WITH public, constant("\qc ")
 DECLARE rtf_right = vc WITH public, constant("\qr ")
 DECLARE rtf_black = vc WITH public, constant("\cf1 ")
 DECLARE rtf_red = vc WITH public, constant("\cf2 ")
 DECLARE rtf_blue = vc WITH public, constant("\cf3 ")
 DECLARE rtf_green = vc WITH public, constant("\cf4 ")
 DECLARE rtf_gray = vc WITH public, constant("\cf5 ")
 DECLARE rtf_tab = vc WITH public, constant("\tab ")
 DECLARE rtf_eof = vc WITH public, constant("}")
 DECLARE 1_blank = c1 WITH protect, constant(" ")
 DECLARE 4_blank = c4 WITH protect, constant("    ")
 DECLARE 14_blank = c14 WITH protect, constant("              ")
 DECLARE rtf_tbl1 = vc WITH public, constant("\trbrdrt\brdrs\brdrw10 \trbrdrr\brdrs\brdrw10")
 DECLARE rtf_tbl2 = vc WITH public, constant(
  "\trbrdrb\brdrs\brdrw10 \trpaddl108\trpaddr108\trpaddfl3\trpaddfr3")
 DECLARE rtf_tbl3 = vc WITH public, constant(
  "\clcbpat2\clbrdrl\brdrw10\brdrs\clbrdrt\brdrw10\brdrs\clbrdrr\brdrw10\brdrs\clbrdrb\brdrw10\brdrs"
  )
 DECLARE rtf_tbl4 = vc WITH public, constant("\pard\intbl\f0\fs18")
 DECLARE rtf_cl = vc WITH public, constant("\cell")
 DECLARE rtf_clx = vc WITH public, constant("\cellx")
 DECLARE rtf_row = vc WITH public, constant("\row\trowd\trgaph108\trleft-108\trbrdrl\brdrs\brdrw10 ")
 DECLARE PUBLIC::i18n_no_results(i18n_key=vc) = vc WITH protect
 DECLARE PUBLIC::i18n_no_familyhx(null) = vc WITH protect
 DECLARE PUBLIC::i18n_no_positive_familyhx(null) = vc WITH protect
 DECLARE PUBLIC::no_results_found(i18n_key=vc) = null WITH protect
 DECLARE PUBLIC::populate_reply_text(null) = null WITH protect
 DECLARE PUBLIC::set_reply_status(sts=c1,osts=c1,onm=vc,tonm=vc,tovl=vc) = null WITH protect
 DECLARE PUBLIC::validate_person(null) = null WITH protect
 SUBROUTINE PUBLIC::i18n_no_results(i18n_key)
   CALL log_message("Entering I18n_No_Results subroutine",log_level_debug)
   DECLARE get_i18n_begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE i18nhandle = i4 WITH persistscript
   DECLARE i18n_string = vc WITH private, noconstant("")
   IF (validate(i18nuar_def,999)=999)
    DECLARE i18nuar_def = i2 WITH persist
    SET i18nuar_def = 1
    DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
    DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
    DECLARE uar_i18nbuildmessage() = vc WITH persist
   ENDIF
   CALL uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
   SET i18n_string = build(uar_i18ngetmessage(i18nhandle,"cap1","No qualifying data available"),".")
   IF (validate(debug_ind,0)=1)
    CALL echo(build("I18N No qualifying data available. = ",i18n_string))
   ENDIF
   CALL log_message(build("Exiting I18n_No_Results subroutine, Elapsed time in seconds:",datetimediff
     (cnvtdatetime(curdate,curtime3),get_i18n_begin_date_time,5)),log_level_debug)
   RETURN(i18n_string)
 END ;Subroutine
 SUBROUTINE PUBLIC::i18n_no_familyhx(null)
   CALL log_message("Entering I18n_No_FamilyHx subroutine",log_level_debug)
   DECLARE get_i18n_begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE i18nhandle = i4 WITH persistscript
   DECLARE i18n_no_familyhx = vc WITH private, noconstant("")
   IF (validate(i18nuar_def,999)=999)
    DECLARE i18nuar_def = i2 WITH persist
    SET i18nuar_def = 1
    DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
    DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
    DECLARE uar_i18nbuildmessage() = vc WITH persist
   ENDIF
   CALL uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
   SET i18n_no_familyhx = build(uar_i18ngetmessage(i18nhandle,"no_family_hx",
     "No family history recorded"),".")
   IF (validate(debug_ind,0)=1)
    CALL echo(build("I18N No family history recorded. = ",i18n_no_familyhx))
   ENDIF
   CALL log_message(build("Exiting I18n_No_FamilyHx subroutine, Elapsed time in seconds:",
     datetimediff(cnvtdatetime(curdate,curtime3),get_i18n_begin_date_time,5)),log_level_debug)
   RETURN(i18n_no_familyhx)
 END ;Subroutine
 SUBROUTINE PUBLIC::i18n_no_positive_familyhx(null)
   CALL log_message("Entering I18n_No_Positive_FamilyHx subroutine",log_level_debug)
   DECLARE get_i18n_begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE i18nhandle = i4 WITH persistscript
   DECLARE i18n_no_positive_familyhx = vc WITH private, noconstant("")
   IF (validate(i18nuar_def,999)=999)
    DECLARE i18nuar_def = i2 WITH persist
    SET i18nuar_def = 1
    DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
    DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
    DECLARE uar_i18nbuildmessage() = vc WITH persist
   ENDIF
   CALL uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
   SET i18n_no_positive_familyhx = build(uar_i18ngetmessage(i18nhandle,"no_positive_history",
     "No positive family history reported"),".")
   IF (validate(debug_ind,0)=1)
    CALL echo(build("I18N No positive family history reported. = ",i18n_no_positive_familyhx))
   ENDIF
   CALL log_message(build("Exiting I18n_No_Positive_FamilyHx subroutine, Elapsed time in seconds:",
     datetimediff(cnvtdatetime(curdate,curtime3),get_i18n_begin_date_time,5)),log_level_debug)
   RETURN(i18n_no_positive_familyhx)
 END ;Subroutine
 SUBROUTINE PUBLIC::no_results_found(i18n_key)
   CALL log_message("Entering No_Results_Found subroutine",log_level_debug)
   DECLARE format_no_data_qualified_begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3
     )), private
   SET reply->text = concat(rtf_head," ",i18n_no_results(i18n_key),rtf_eol,rtf_eof)
   CALL set_reply_status("S","S","Main Program",curprog,"No qualifying data available.")
   IF (validate(debug_ind,0)=1)
    CALL echorecord(reply)
   ENDIF
   CALL log_message(build("Exiting No_Results_Found subroutine, Elapsed time in seconds:",
     datetimediff(cnvtdatetime(curdate,curtime3),format_no_data_qualified_begin_date_time,5)),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE PUBLIC::populate_reply_text(null)
   CALL log_message("Entering Populate_Reply_Text subroutine",log_level_debug)
   DECLARE format_reply_text_begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)),
   private
   DECLARE list_size = i4 WITH private, constant(size(results->list,5))
   DECLARE idx = i4 WITH private, noconstant(0)
   FOR (idx = 1 TO list_size)
     IF (idx=1)
      SET reply->text = concat(rtf_head," ",results->list[idx].item)
     ELSEIF (idx < list_size)
      SET reply->text = concat(reply->text,rtf_eol," ",results->list[idx].item)
     ELSE
      SET reply->text = concat(reply->text,rtf_eol," ",results->list[idx].item,rtf_eol,
       rtf_eof)
     ENDIF
   ENDFOR
   IF (validate(debug_ind,0)=1)
    CALL echorecord(reply)
   ENDIF
   CALL log_message(build("Exiting Populate_Reply_Text subroutine, Elapsed time in seconds:",
     datetimediff(cnvtdatetime(curdate,curtime3),format_reply_text_begin_date_time,5)),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE PUBLIC::set_reply_status(status,ostatus,oname,toname,tovalue)
   SET reply->status_data.status = status
   SET reply->status_data.subeventstatus.operationstatus = ostatus
   SET reply->status_data.subeventstatus.operationname = oname
   SET reply->status_data.subeventstatus.targetobjectname = toname
   SET reply->status_data.subeventstatus.targetobjectvalue = tovalue
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE PUBLIC::validate_person(null)
   CALL log_message("Entering Validate_Person subroutine",log_level_debug)
   DECLARE validate_request_begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)),
   private
   IF (size(request->person,5)=0)
    CALL set_reply_status("F","F","ValidateRequest",curprog,
     "No valid person information was found in the request")
   ENDIF
   IF ((request->person[1].person_id=0))
    CALL set_reply_status("F","F","ValidateRequest",curprog,
     "Invalid person information was found in the request")
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(request)
   ENDIF
   CALL log_message(build("Exiting Validate_Person subroutine, Elapsed time in seconds:",datetimediff
     (cnvtdatetime(curdate,curtime3),validate_request_begin_date_time,5)),log_level_debug)
 END ;Subroutine
 DECLARE PUBLIC::main(null) = null WITH private
 DECLARE PUBLIC::addprocedurehxitem(proceduredate=vc,procedurename=vc,laterality_display=vc) = i4
 WITH protect, copy
 DECLARE PUBLIC::addrtfline(rtfline=vc) = i4 WITH protect, copy
 DECLARE PUBLIC::validaterequest(null) = null WITH protect, copy
 DECLARE PUBLIC::retrievecontributorsystemcodes(null) = null WITH protect, copy
 DECLARE PUBLIC::determineappnumforcontributorsystemcodes(null) = null WITH protect, copy
 DECLARE PUBLIC::getprocedurehxitems(null) = null WITH protect, copy
 DECLARE PUBLIC::buildprocedurehxrtf(null) = null WITH protect, copy
 DECLARE PUBLIC::putrtfinreply(null) = null WITH protect, copy
 DECLARE PUBLIC::determineappnumusingappcontext(null) = i4 WITH protect, copy
 DECLARE PUBLIC::adddefaultcontributorsystemcodes(null) = null WITH protect, copy
 DECLARE person_id = f8 WITH protect, noconstant(0.0)
 DECLARE personnel_id = f8 WITH protect, noconstant(0.0)
 DECLARE application_num = i4 WITH protect, noconstant(0)
 DECLARE reqinfo_updtappnum = i4 WITH protect, constant(reqinfo->updt_app)
 DECLARE reqinfo_updtapplctx = i4 WITH protect, constant(reqinfo->updt_applctx)
 DECLARE no_data_i18n = vc WITH protect, noconstant("")
 DECLARE i18n_key = vc WITH protect, noconstant("")
 CALL main(null)
 SUBROUTINE PUBLIC::main(null)
   SET reply->status_data.status = "F"
   CALL validaterequest(null)
   SET i18n_key = "cap1"
   SET no_data_i18n = i18n_no_results(i18n_key)
   CALL determineappnumforcontributorsystemcodes(null)
   CALL retrievecontributorsystemcodes(null)
   CALL adddefaultcontributorsystemcodes(null)
   CALL getprocedurehxitems(null)
   CALL buildprocedurehxrtf(null)
   CALL putrtfinreply(null)
   SET reply->status_data.status = "S"
 END ;Subroutine
 SUBROUTINE PUBLIC::validaterequest(null)
   IF (size(request->person,5) > 0
    AND (request->person[1].person_id > 0))
    SET person_id = request->person[1].person_id
    SET personnel_id = request->prsnl[1].prsnl_id
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationstatus = "F"
    SET reply->status_data.subeventstatus.operationname = "ValidateRequest Failed"
    SET reply->status_data.subeventstatus.targetobjectname = "ValidateRequest Failed"
    SET reply->status_data.subeventstatus.targetobjectvalue =
    "No Valid person information found in request"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::determineappnumusingappcontext(null)
   DECLARE application_num = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM application_context ac
    WHERE ac.applctx=reqinfo_updtapplctx
     AND ac.application_number != 0
    DETAIL
     application_num = ac.application_number
    WITH nocounter
   ;end select
   RETURN(application_num)
 END ;Subroutine
 SUBROUTINE PUBLIC::determineappnumforcontributorsystemcodes(null)
   DECLARE powerchart_appnum = i4 WITH protect, constant(600005)
   SET stat = alterlist(applications->apps,1)
   SET applications->apps[1].app_num = powerchart_appnum
   IF (reqinfo_updtappnum != powerchart_appnum
    AND reqinfo_updtappnum != 0)
    SET stat = alterlist(applications->apps,2)
    SET applications->apps[2].app_num = reqinfo_updtappnum
   ENDIF
   IF (reqinfo_updtapplctx != 0
    AND reqinfo_updtapplctx != powerchart_appnum
    AND reqinfo_updtapplctx != reqinfo_updtappnum)
    SET application_num = determineappnumusingappcontext(null)
    IF (application_num != reqinfo_updtappnum
     AND application_num != powerchart_appnum
     AND application_num != 0)
     SET stat = alterlist(applications->apps,3)
     SET applications->apps[3].app_num = application_num
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::retrievecontributorsystemcodes(null)
   DECLARE app_idx = i4 WITH protect, noconstant(0)
   DECLARE cont_sys_cnt = i4 WITH protect, noconstant(0)
   DECLARE prochist = vc WITH protect, constant("PROCHIST")
   DECLARE position_cd = f8 WITH protect, constant(reqinfo->position_cd)
   SELECT INTO "nl:"
    app_priority =
    IF (dp.application_number=reqinfo_updtappnum
     AND reqinfo_updtappnum != 0) 1
    ELSEIF (dp.application_number=application_num
     AND application_num != 0) 2
    ELSEIF (dp.application_number=600005) 3
    ENDIF
    , pref_priority =
    IF (dp.prsnl_id > 0.0) 1
    ELSEIF (dp.position_cd > 0.0) 2
    ELSE 3
    ENDIF
    , con_sys_num =
    IF (nvp.pvc_name="PROCEDURES_CONTRIBUTOR_SYSTEMS*") cnvtint(replace(trim(substring(1,32,nvp
         .pvc_name),3),"PROCEDURES_CONTRIBUTOR_SYSTEMS",""))
    ELSE - (1)
    ENDIF
    FROM detail_prefs dp,
     name_value_prefs nvp
    PLAN (dp
     WHERE dp.prsnl_id IN (0.0, personnel_id)
      AND dp.position_cd IN (0.0, position_cd)
      AND expand(app_idx,1,size(applications->apps,5),dp.application_number,applications->apps[
      app_idx].app_num)
      AND dp.view_name=prochist
      AND dp.comp_name=prochist
      AND dp.active_ind > 0
      AND dp.view_seq=0
      AND dp.comp_seq=0)
     JOIN (nvp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name IN ("PROCEDURES_CONTRIBUTOR_SYSTEMS*", "PROCEDURES_ContributorSysListCnt")
      AND nvp.active_ind > 0)
    ORDER BY con_sys_num, app_priority, pref_priority
    HEAD con_sys_num
     IF ((con_sys_num=- (1)))
      con_sys->system_cnt = cnvtint(nvp.pvc_value), stat = alterlist(con_sys->systems,con_sys->
       system_cnt)
     ELSE
      IF ((cont_sys_cnt < con_sys->system_cnt))
       cont_sys_cnt = (cont_sys_cnt+ 1), con_sys->systems[cont_sys_cnt].system_code = cnvtreal(nvp
        .pvc_value)
      ENDIF
     ENDIF
    WITH check
   ;end select
 END ;Subroutine
 SUBROUTINE PUBLIC::adddefaultcontributorsystemcodes(null)
   DECLARE powerchart_system = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"POWERCHART"))
   DECLARE app_idx = i4 WITH protect, noconstant(0)
   IF (locateval(app_idx,1,con_sys->system_cnt,powerchart_system,con_sys->systems[app_idx].
    system_code) <= 0)
    SET con_sys->system_cnt = (con_sys->system_cnt+ 1)
    SET stat = alterlist(con_sys->systems,con_sys->system_cnt)
    SET con_sys->systems[con_sys->system_cnt].system_code = powerchart_system
   ENDIF
   SET con_sys->system_cnt = (con_sys->system_cnt+ 1)
   SET stat = alterlist(con_sys->systems,con_sys->system_cnt)
   SET con_sys->systems[con_sys->system_cnt].system_code = 0.0
 END ;Subroutine
 SUBROUTINE PUBLIC::getprocedurehxitems(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("**** Entering GetProcedureHxItems ***")
   ENDIF
   DECLARE display_name = vc WITH protect, noconstant("")
   DECLARE procedure_date = vc WITH protect, noconstant("")
   DECLARE app_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    date_found_ind =
    IF (pr.proc_dt_tm > 0) 1
    ELSE 0
    ENDIF
    FROM encounter e,
     procedure pr,
     nomenclature n
    PLAN (e
     WHERE e.person_id=person_id)
     JOIN (pr
     WHERE pr.encntr_id=e.encntr_id
      AND pr.active_ind=1
      AND expand(app_idx,1,con_sys->system_cnt,pr.contributor_system_cd,con_sys->systems[app_idx].
      system_code)
      AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (n
     WHERE n.nomenclature_id=pr.nomenclature_id
      AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
    ORDER BY date_found_ind DESC, pr.proc_dt_tm DESC
    DETAIL
     procedure_date = ""
     IF (date_found_ind=1)
      CASE (pr.proc_dt_tm_prec_flag)
       OF 0:
       OF 1:
        procedure_date = format(pr.proc_dt_tm,"@SHORTDATE")
       OF 2:
        procedure_date = format(pr.proc_dt_tm,"MM/YYYY;;d")
       OF 3:
        procedure_date = format(pr.proc_dt_tm,"YYYY;;d")
      ENDCASE
     ENDIF
     IF (trim(pr.procedure_note,3) > " ")
      display_name = trim(pr.procedure_note,3)
     ELSEIF (trim(pr.proc_ftdesc,3) > " ")
      display_name = trim(pr.proc_ftdesc,3)
     ELSE
      display_name = trim(n.source_string,3)
     ENDIF
     CALL addprocedurehxitem(procedure_date,display_name,uar_get_code_display(pr.laterality_cd))
    WITH nocounter
   ;end select
   SET stat = alterlist(procedurehx->items,procedurehx->itemcount)
   IF (validate(debug_ind,0)=1)
    CALL echo("**** Leaving GetProcedureHxItems ***")
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::addprocedurehxitem(proceduredate,procedurename,laterality_display)
   SET procedurehx->itemcount = (procedurehx->itemcount+ 1)
   IF ((procedurehx->itemcount > size(procedurehx->items,5)))
    SET stat = alterlist(procedurehx->items,(procedurehx->itemcount+ 10))
   ENDIF
   SET procedurehx->items[procedurehx->itemcount].proceduredate = proceduredate
   SET procedurehx->items[procedurehx->itemcount].procedurename = procedurename
   SET procedurehx->items[procedurehx->itemcount].laterality = laterality_display
   RETURN(procedurehx->itemcount)
 END ;Subroutine
 SUBROUTINE PUBLIC::buildprocedurehxrtf(null)
   DECLARE rtfline = vc WITH protect, noconstant("")
   CALL addrtfline(rtf_head)
   IF (size(procedurehx->items,5) > 0)
    FOR (procedurehxindex = 1 TO procedurehx->itemcount)
      SET rtfline = build2(rtf_r0," ",procedurehx->items[procedurehxindex].procedurename)
      IF ((procedurehx->items[procedurehxindex].laterality != ""))
       SET rtfline = build2(rtfline,", ",procedurehx->items[procedurehxindex].laterality)
      ENDIF
      IF ((procedurehx->items[procedurehxindex].proceduredate != ""))
       SET rtfline = build2(rtfline,": ",procedurehx->items[procedurehxindex].proceduredate)
      ENDIF
      SET rtfline = build2(rtfline,rtf_eol)
      CALL addrtfline(rtfline)
    ENDFOR
   ELSE
    CALL addrtfline(build2(" ",no_data_i18n,rtf_eol))
   ENDIF
   CALL addrtfline(rtf_eof)
   SET stat = alterlist(rtfcontainer->rtflines,rtfcontainer->rtflinecount)
 END ;Subroutine
 SUBROUTINE PUBLIC::addrtfline(rtfline)
   SET rtfcontainer->rtflinecount = (rtfcontainer->rtflinecount+ 1)
   IF ((rtfcontainer->rtflinecount > size(rtfcontainer->rtflines,5)))
    SET stat = alterlist(rtfcontainer->rtflines,(rtfcontainer->rtflinecount+ 10))
   ENDIF
   SET rtfcontainer->rtflines[rtfcontainer->rtflinecount].rtfline = rtfline
   RETURN(rtfcontainer->rtflinecount)
 END ;Subroutine
 SUBROUTINE PUBLIC::putrtfinreply(null)
  FOR (rtflineindex = 1 TO rtfcontainer->rtflinecount)
    SET reply->text = build2(reply->text,rtfcontainer->rtflines[rtflineindex].rtfline)
  ENDFOR
  SET reply->status_data.status = "S"
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echorecord(reply)
  CALL echo(reply->text)
 ENDIF
END GO
