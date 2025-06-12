CREATE PROGRAM cp_get_charting_security:dba
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
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
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
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
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
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
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
 SET log_program_name = "CP_GET_CHARTING_SECURITY"
 FREE RECORD option_rec
 RECORD option_rec(
   1 opt_cnt = i4
   1 options[*]
     2 non_i18n_lbl = vc
     2 i18n_lbl = vc
     2 val_cnt = i4
     2 info_domain = vc
     2 info_name = vc
     2 values[*]
       3 i18n_lbl = vc
       3 info_number = f8
 )
 DECLARE initializeoptionrec(null) = null
 DECLARE section_level_info_domain = vc WITH constant("CHARTING SECURITY"), protect
 DECLARE datalevel_override_info_domain = vc WITH constant("DATALEVEL CHART_SERVER"), protect
 DECLARE section_level_auth_val = i4 WITH constant(1), protect
 DECLARE datalevel_override_val = i4 WITH constant(2), protect
 DECLARE section_level_auth_lbl = vc WITH constant("Section level auth"), protect
 DECLARE datalevel_override_lbl = vc WITH constant("Data level priv"), protect
 DECLARE enable_val = f8 WITH constant(1.0), protect
 DECLARE disable_val = f8 WITH constant(0.0), protect
 DECLARE i18nhandle = i4 WITH noconstant(0), protect
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog," ",curcclrev)
 DECLARE chartingsecurityheader = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO1",
   "CHARTING SECURITY"))
 DECLARE sectionlevelauthlabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO2",
   "Section level authentication"))
 DECLARE dataleveloverridelabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO3",
   "Data level privileges"))
 DECLARE enablelabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO4","Enable"))
 DECLARE disablelabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO5","Disable"))
 DECLARE helpmenurequest = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO6","Shift/F5 for Help"
   ))
 DECLARE selectoptiontoupdate = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO7",
   "Select option to update"))
 DECLARE exitinglabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO8","EXITING"))
 DECLARE selectvaluetocommit = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO9",
   "Select value to commit"))
 DECLARE quitlabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO10","Quit"))
 DECLARE errinsertupdatedminfo = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR1",
   "Error inserting/updating into DM_INFO"))
 DECLARE errupdateoptionvalues = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR2",
   "Incorrect option value selected"))
 SUBROUTINE initializeoptionrec(null)
   IF ((option_rec->opt_cnt=0))
    SET option_rec->opt_cnt = 2
    SET stat = alterlist(option_rec->options,option_rec->opt_cnt)
    SET option_rec->options[1].non_i18n_lbl = section_level_auth_lbl
    SET option_rec->options[1].i18n_lbl = sectionlevelauthlabel
    SET option_rec->options[1].info_domain = section_level_info_domain
    SET option_rec->options[1].info_name = section_level_auth_lbl
    SET option_rec->options[1].val_cnt = 2
    SET stat = alterlist(option_rec->options[1].values,option_rec->options[1].val_cnt)
    SET option_rec->options[1].values[1].i18n_lbl = enablelabel
    SET option_rec->options[1].values[1].info_number = enable_val
    SET option_rec->options[1].values[2].i18n_lbl = disablelabel
    SET option_rec->options[1].values[2].info_number = disable_val
    SET option_rec->options[2].non_i18n_lbl = datalevel_override_lbl
    SET option_rec->options[2].i18n_lbl = dataleveloverridelabel
    SET option_rec->options[2].info_domain = datalevel_override_info_domain
    SET option_rec->options[2].info_name = datalevel_override_lbl
    SET option_rec->options[2].val_cnt = 2
    SET stat = alterlist(option_rec->options[2].values,option_rec->options[1].val_cnt)
    SET option_rec->options[2].values[1].i18n_lbl = enablelabel
    SET option_rec->options[2].values[1].info_number = enable_val
    SET option_rec->options[2].values[2].i18n_lbl = disablelabel
    SET option_rec->options[2].values[2].info_number = disable_val
   ENDIF
 END ;Subroutine
 SUBROUTINE (getoptionvaluebylabel(option_lbl=vc(val)) =i4)
   DECLARE idx = i4 WITH noconstant(0), private
   DECLARE option_idx = i4 WITH noconstant(0), private
   CALL initializeoptionrec(null)
   SET option_idx = locateval(idx,1,option_rec->opt_cnt,option_lbl,option_rec->options[idx].
    non_i18n_lbl)
   IF (option_idx > 0)
    RETURN(getdminfovaluebyoptionindex(option_idx))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getdminfovaluebyoptionindex(option_idx=i4(val)) =f8)
   CALL initializeoptionrec(null)
   FREE RECORD temp_request
   RECORD temp_request(
     1 debug_ind = i2
     1 info_domain = vc
     1 info_name = vc
     1 info_date = dq8
     1 info_char = vc
     1 info_number = f8
     1 info_long_id = f8
   )
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 qual[*]
       2 info_domain = vc
       2 info_name = vc
       2 info_date = dq8
       2 info_char = vc
       2 info_number = f8
       2 info_long_id = f8
       2 updt_applctx = f8
       2 updt_task = i4
       2 updt_dt_tm = dq8
       2 updt_cnt = i4
       2 updt_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET temp_request->info_name = option_rec->options[option_idx].info_name
   SET temp_request->info_domain = option_rec->options[option_idx].info_domain
   EXECUTE dm_get_dm_info  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY","TEMP_REPLY")
   IF ((temp_reply->status_data.status="Z"))
    RETURN(0)
   ELSEIF ((temp_reply->status_data.status != "S"))
    CALL echorecord(temp_reply)
    SET reply->status_data.status = temp_reply->status_data.status
    CALL moverec(temp_reply->status_data.subeventstatus,reply->status_data.subeventstatus)
    GO TO exit_script
   ENDIF
   RETURN(temp_reply->qual[1].info_number)
 END ;Subroutine
 SUBROUTINE (getdminfovalueindexbyoptionindex(option_idx=i4(val)) =i4)
   DECLARE optionvalue = f8 WITH noconstant(0.0), private
   SET optionvalue = getdminfovaluebyoptionindex(option_idx)
   DECLARE idx = i4 WITH noconstant(0), protect
   RETURN(locateval(idx,1,option_rec->options[option_idx].val_cnt,optionvalue,option_rec->options[
    option_idx].values[idx].info_number))
 END ;Subroutine
 RECORD reply(
   1 charting_security = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE option_idx = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 CALL log_message("Begin script: cp_get_charting_security",log_level_debug)
 SET reply->status_data.status = "F"
 CALL initializeoptionrec(null)
 SET option_idx = locateval(idx,1,option_rec->opt_cnt,section_level_auth_lbl,option_rec->options[idx]
  .non_i18n_lbl)
 SET reply->status_data.status = "S"
 SET reply->charting_security = cnvtstring(getdminfovaluebyoptionindex(option_idx))
#exit_script
 CALL log_message("Exiting script: cp_get_charting_security",log_level_debug)
 CALL echorecord(reply)
END GO
