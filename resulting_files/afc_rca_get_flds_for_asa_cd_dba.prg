CREATE PROGRAM afc_rca_get_flds_for_asa_cd:dba
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 DECLARE __lpahsys = i4 WITH protect, noconstant(0)
 DECLARE __lpalsysstat = i4 WITH protect, noconstant(0)
 IF (validate(logmessage,char(128))=char(128))
  SUBROUTINE (logmessage(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    IF (size(trim(psubroutine,3)) > 0)
     CALL echo(concat(curprog," : ",psubroutine,"() : ",pmessage))
    ELSE
     CALL echo(concat(curprog," : ",pmessage))
    ENDIF
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __lpahsys = 0
    SET __lpalsysstat = 0
    CALL uar_syscreatehandle(__lpahsys,__lpalsysstat)
    IF (__lpahsys > 0)
     CALL uar_sysevent(__lpahsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__lpahsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
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
 DECLARE start_timer = dq8 WITH noconstant(0)
 DECLARE stop_timer = dq8 WITH noconstant(0)
 DECLARE chk = i4 WITH public, noconstant(0)
 DECLARE populateanesthesiaflexfields(null) = null
 CALL logmessage("Main","Begining main processing",log_debug)
 SET start_timer = cnvtdatetime(sysdate)
 CALL populateanesthesiaflexfields(null)
 FOR (chk = 1 TO size(reply->serviceitems[1].categories[1].fields,5))
   IF ((reply->serviceitems[1].categories[1].fields[chk].fieldcode != 0))
    SET ispopulateanesthesiaflexfields = 1
   ENDIF
 ENDFOR
 SET stop_timer = cnvtdatetime(sysdate)
 CALL logmessage("Main","END of afc_rca_get_flds_for_asa_cd",log_debug)
 CALL log_message(build(" Elapsed time in seconds:",datetimediff(stop_timer,start_timer,5)),
  log_level_debug)
 SUBROUTINE populateanesthesiaflexfields(null)
   CALL logmessage("populateAnesthesiaFlexFields","Entering",log_debug)
   SET stat = alterlist(reply->serviceitems,1)
   SET reply->serviceitems[1].serviceitemid = request->serviceitems[1].serviceitemid
   SET stat = alterlist(reply->serviceitems[1].categories,1)
   SET reply->serviceitems[1].categories[1].categoryname = uar_get_code_display(
    cs4002353_anesthesia_cd)
   SET reply->serviceitems[1].categories[1].categorycd = cs4002353_anesthesia_cd
   SET reply->serviceitems[1].categories[1].categorymeaning = uar_get_code_meaning(
    cs4002353_anesthesia_cd)
   SET stat = alterlist(reply->serviceitems[1].categories[1].fields,11)
   IF ( NOT (getfieldvalue(cs4002352_casetime_cd,fieldvalue,type)))
    SET reply->serviceitems[1].categories[1].fields[1].fieldtype = "RANGE"
   ELSE
    SET reply->serviceitems[1].categories[1].fields[1].fieldtype = fieldvalue
   ENDIF
   SET reply->serviceitems[1].categories[1].fields[1].fielddisplay = uar_get_code_display(
    cs4002352_casetime_cd)
   SET reply->serviceitems[1].categories[1].fields[1].fieldmeaning = uar_get_code_meaning(
    cs4002352_casetime_cd)
   SET reply->serviceitems[1].categories[1].fields[1].fieldcode = cs4002352_casetime_cd
   SET reply->serviceitems[1].categories[1].fields[1].fieldrequiredind = true
   IF ( NOT (getfieldvalue(cs4002352_physrelief_cd,fieldvalue,type)))
    SET reply->serviceitems[1].categories[1].fields[2].fieldtype = "PROVIDERTIME"
   ELSE
    SET reply->serviceitems[1].categories[1].fields[2].fieldtype = fieldvalue
   ENDIF
   SET reply->serviceitems[1].categories[1].fields[2].fielddisplay = uar_get_code_display(
    cs4002352_physrelief_cd)
   SET reply->serviceitems[1].categories[1].fields[2].fieldmeaning = uar_get_code_meaning(
    cs4002352_physrelief_cd)
   SET reply->serviceitems[1].categories[1].fields[2].fieldcode = cs4002352_physrelief_cd
   IF ( NOT (getfieldvalue(cs4002352_crnarelief_cd,fieldvalue,type)))
    SET reply->serviceitems[1].categories[1].fields[3].fieldtype = "PROVIDERTIME"
   ELSE
    SET reply->serviceitems[1].categories[1].fields[3].fieldtype = fieldvalue
   ENDIF
   SET reply->serviceitems[1].categories[1].fields[3].fielddisplay = uar_get_code_display(
    cs4002352_crnarelief_cd)
   SET reply->serviceitems[1].categories[1].fields[3].fieldmeaning = uar_get_code_meaning(
    cs4002352_crnarelief_cd)
   SET reply->serviceitems[1].categories[1].fields[3].fieldcode = cs4002352_crnarelief_cd
   IF ( NOT (getfieldvalue(cs4002352_holdtime_cd,fieldvalue,type)))
    SET reply->serviceitems[1].categories[1].fields[4].fieldtype = "PROVIDERTIME"
   ELSE
    SET reply->serviceitems[1].categories[1].fields[4].fieldtype = fieldvalue
   ENDIF
   SET reply->serviceitems[1].categories[1].fields[4].fielddisplay = uar_get_code_display(
    cs4002352_holdtime_cd)
   SET reply->serviceitems[1].categories[1].fields[4].fieldmeaning = uar_get_code_meaning(
    cs4002352_holdtime_cd)
   SET reply->serviceitems[1].categories[1].fields[4].fieldcode = cs4002352_holdtime_cd
   IF ( NOT (getfieldvalue(cs4002352_surgeon_cd,fieldvalue,type)))
    SET reply->serviceitems[1].categories[1].fields[5].fieldtype = "PROVLOOKUP"
   ELSE
    SET reply->serviceitems[1].categories[1].fields[5].fieldtype = fieldvalue
   ENDIF
   SET reply->serviceitems[1].categories[1].fields[5].fielddisplay = uar_get_code_display(
    cs4002352_surgeon_cd)
   SET reply->serviceitems[1].categories[1].fields[5].fieldmeaning = uar_get_code_meaning(
    cs4002352_surgeon_cd)
   SET reply->serviceitems[1].categories[1].fields[5].fieldcode = cs4002352_surgeon_cd
   IF ( NOT (getfieldvalue(cs4002352_clmlvlnote_cd,fieldvalue,type)))
    SET reply->serviceitems[1].categories[1].fields[6].fieldtype = "STRING"
   ELSE
    SET reply->serviceitems[1].categories[1].fields[6].fieldtype = fieldvalue
   ENDIF
   SET reply->serviceitems[1].categories[1].fields[6].fielddisplay = uar_get_code_display(
    cs4002352_clmlvlnote_cd)
   SET reply->serviceitems[1].categories[1].fields[6].fieldmeaning = uar_get_code_meaning(
    cs4002352_clmlvlnote_cd)
   SET reply->serviceitems[1].categories[1].fields[6].fieldcode = cs4002352_clmlvlnote_cd
   IF ( NOT (getfieldvalue(cs4002352_linelvlnote_cd,fieldvalue,type)))
    SET reply->serviceitems[1].categories[1].fields[7].fieldtype = "STRING"
   ELSE
    SET reply->serviceitems[1].categories[1].fields[7].fieldtype = fieldvalue
   ENDIF
   SET reply->serviceitems[1].categories[1].fields[7].fielddisplay = uar_get_code_display(
    cs4002352_linelvlnote_cd)
   SET reply->serviceitems[1].categories[1].fields[7].fieldmeaning = uar_get_code_meaning(
    cs4002352_linelvlnote_cd)
   SET reply->serviceitems[1].categories[1].fields[7].fieldcode = cs4002352_linelvlnote_cd
   IF ( NOT (getfieldvalue(cs4002352_asacode_cd,fieldvalue,type)))
    SET reply->serviceitems[1].categories[1].fields[8].fieldtype = "CODE"
   ELSE
    SET reply->serviceitems[1].categories[1].fields[8].fieldtype = fieldvalue
   ENDIF
   SET reply->serviceitems[1].categories[1].fields[8].fielddisplay = uar_get_code_display(
    cs4002352_asacode_cd)
   SET reply->serviceitems[1].categories[1].fields[8].fieldmeaning = uar_get_code_meaning(
    cs4002352_asacode_cd)
   SET reply->serviceitems[1].categories[1].fields[8].fieldcode = cs4002352_asacode_cd
   IF ( NOT (getfieldvalue(cs4002352_anesthesiologist_cd,fieldvalue,type)))
    SET reply->serviceitems[1].categories[1].fields[9].fieldtype = "PROVLOOKUP"
   ELSE
    SET reply->serviceitems[1].categories[1].fields[9].fieldtype = fieldvalue
   ENDIF
   SET reply->serviceitems[1].categories[1].fields[9].fielddisplay = uar_get_code_display(
    cs4002352_anesthesiologist_cd)
   SET reply->serviceitems[1].categories[1].fields[9].fieldmeaning = uar_get_code_meaning(
    cs4002352_anesthesiologist_cd)
   SET reply->serviceitems[1].categories[1].fields[9].fieldcode = cs4002352_anesthesiologist_cd
   IF ( NOT (getfieldvalue(cs4002352_crnaaa_cd,fieldvalue,type)))
    SET reply->serviceitems[1].categories[1].fields[10].fieldtype = "PROVLOOKUP"
   ELSE
    SET reply->serviceitems[1].categories[1].fields[10].fieldtype = fieldvalue
   ENDIF
   SET reply->serviceitems[1].categories[1].fields[10].fielddisplay = uar_get_code_display(
    cs4002352_crnaaa_cd)
   SET reply->serviceitems[1].categories[1].fields[10].fieldmeaning = uar_get_code_meaning(
    cs4002352_crnaaa_cd)
   SET reply->serviceitems[1].categories[1].fields[10].fieldcode = cs4002352_crnaaa_cd
   IF ( NOT (getfieldvalue(cs4002352_cptcode_cd,fieldvalue,type)))
    SET reply->serviceitems[1].categories[1].fields[11].fieldtype = "STRING"
   ELSE
    SET reply->serviceitems[1].categories[1].fields[11].fieldtype = fieldvalue
   ENDIF
   SET reply->serviceitems[1].categories[1].fields[11].fielddisplay = uar_get_code_display(
    cs4002352_cptcode_cd)
   SET reply->serviceitems[1].categories[1].fields[11].fieldmeaning = uar_get_code_meaning(
    cs4002352_cptcode_cd)
   SET reply->serviceitems[1].categories[1].fields[11].fieldcode = cs4002352_cptcode_cd
   CALL logmessage("populateAnesthesiaFlexFields","Exit",log_debug)
 END ;Subroutine
END GO
