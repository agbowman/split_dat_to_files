CREATE PROGRAM alert_link_build_record:dba
 PROMPT
  "Type:" = "DISCERN.DISCERN_ALERT",
  "Priority:" = 0,
  "Subject:" = "",
  "Message:" = ""
  WITH type, priority, subject,
  message
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
 SET log_program_name = "alert_link_build_record"
 DECLARE setevent(null) = null WITH protect
 DECLARE retrievepersonid(null) = null WITH protect
 DECLARE populatepatienttopersonnelrltns(null) = null WITH protect
 DECLARE populateencountertopersonnelrltns(null) = null WITH protect
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE encntr_id = f8 WITH protect, constant(link_encntrid)
 DECLARE person_id = f8 WITH protect, noconstant(link_personid)
 DECLARE encntrprsnlreltncnt = i4 WITH protect, noconstant(0)
 DECLARE logical_domain_id = f8 WITH noconstant(0.0)
 FREE RECORD ejs_request
 RECORD ejs_request(
   1 fac_code = vc
   1 date = dq8
   1 type = vc
   1 priority = i2
   1 subject = vc
   1 message = vc
   1 context[*]
     2 ckey = vc
     2 cvalue = vc
   1 personpersonnelrelationship[*]
     2 personnelrelationshipcv = f8
     2 personpersonnelid = f8
   1 encounterpersonnelrelationship[*]
     2 encounterpersonnelrelationshipcv = f8
     2 encounterpersonpersonnelid = f8
   1 logicaldomainid = f8
 ) WITH persistscript
 DECLARE msgdate = dq8 WITH protect, noconstant(0)
 SET msgdate = cnvtdatetime(sysdate)
 CALL log_message(concat("Begin script alert_link_build_record: ",log_program_name),log_level_debug)
 CALL setevent(null)
 CALL log_message(concat("Exit script alert_link_build_record: ",log_program_name),log_level_debug)
 SUBROUTINE setevent(null)
   CALL log_message("In setEvent()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   CALL log_message(build("Subject: ", $SUBJECT),log_level_debug)
   CALL log_message(build("Type: ", $TYPE),log_level_debug)
   CALL log_message(build("Priority: ", $PRIORITY),log_level_debug)
   CALL log_message(build("Message: ", $MESSAGE),log_level_debug)
   CALL log_message(build("Current Dt Tm : ",msgdate),log_level_debug)
   SET ejs_request->date = cnvtdatetime(current_date_time)
   SET ejs_request->type =  $TYPE
   SET ejs_request->subject =  $SUBJECT
   SET ejs_request->priority =  $PRIORITY
   SET ejs_request->message =  $MESSAGE
   SET stat = alterlist(ejs_request->context,4)
   SET ejs_request->context[1].ckey = nullterm("com.cerner.icommand.event.location.alias.issuer")
   SET ejs_request->context[1].cvalue = nullterm("CERNER_MILLENNIUM")
   SET ejs_request->context[2].ckey = nullterm("com.cerner.icommand.event.location.alias.type")
   SET ejs_request->context[2].cvalue = nullterm("LOCATION_CD")
   SET ejs_request->context[3].ckey = nullterm("com.cerner.icommand.event.location.alias.id")
   SET ejs_request->context[4].ckey = nullterm("com.cerner.icommand.event.location.name")
   CALL retrievepersonid(null)
   IF (person_id > 0.0)
    CALL populatepatienttopersonnelrltns(null)
   ELSE
    CALL log_message("No Person ID found to populate Patient Personnel Relationship(s)",
     log_level_debug)
   ENDIF
   IF (encntr_id > 0.0)
    SELECT INTO "nl:"
     FROM encntr_loc_hist elh
     WHERE elh.encntr_id=encntr_id
     ORDER BY elh.beg_effective_dt_tm DESC
     HEAD REPORT
      ejs_request->context[3].cvalue = cnvtstring(elh.location_cd,25,0), ejs_request->context[4].
      cvalue = uar_get_code_display(elh.location_cd), ejs_request->fac_code = cnvtstring(elh
       .loc_facility_cd)
     WITH nocounter, maxrec = 1
    ;end select
    CALL populateencountertopersonnelrltns(null)
   ELSE
    CALL log_message("No Encounter ID Found",log_level_debug)
   ENDIF
   IF (person_id > 0.0)
    SELECT INTO "nl:"
     p.logical_domain_id
     FROM person p
     WHERE p.person_id=person_id
     DETAIL
      logical_domain_id = p.logical_domain_id
     WITH maxrec = 1
    ;end select
   ELSE
    CALL log_message("No Person ID found to resolve logical domain ID",log_level_debug)
   ENDIF
   SET ejs_request->logicaldomainid = logical_domain_id
   SET retval = 100
   CALL log_message("exit setEvent()",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievepersonid(null)
   CALL log_message("In retrievePatientID()",log_level_debug)
   IF (person_id=0.0)
    IF (encntr_id > 0.0)
     SELECT INTO "nl:"
      FROM encounter enctr
      WHERE enctr.encntr_id=encntr_id
      DETAIL
       person_id = enctr.person_id
      WITH nocounter, maxrec = 1
     ;end select
    ELSE
     CALL log_message("Could not retreieve PatientID as there is no valid Encounter ID",
      log_level_debug)
    ENDIF
   ELSE
    CALL log_message("PERSON_ID is already populated",log_level_debug)
   ENDIF
   CALL log_message("Exit retrievePatientID()",log_level_debug)
 END ;Subroutine
 SUBROUTINE populatepatienttopersonnelrltns(null)
   CALL log_message("In populatPatientToPersonnelRltns()",log_level_debug)
   SET personprsnlreltncnt = size(ejs_request->personpersonnelrelationship,5)
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr
    WHERE ppr.person_id=person_id
     AND ppr.active_ind=1
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(current_date_time)
     AND ppr.end_effective_dt_tm >= cnvtdatetime(current_date_time)
    DETAIL
     personprsnlreltncnt += 1
     IF (mod(personprsnlreltncnt,10)=1)
      stat = alterlist(ejs_request->personpersonnelrelationship,(personprsnlreltncnt+ 9))
     ENDIF
     ejs_request->personpersonnelrelationship[personprsnlreltncnt].personnelrelationshipcv = ppr
     .person_prsnl_r_cd, ejs_request->personpersonnelrelationship[personprsnlreltncnt].
     personpersonnelid = ppr.prsnl_person_id
    FOOT REPORT
     stat = alterlist(ejs_request->personpersonnelrelationship,personprsnlreltncnt)
    WITH nocounter
   ;end select
   CALL log_message("Exit populatPatientToPersonnelRltns()",log_level_debug)
 END ;Subroutine
 SUBROUTINE populateencountertopersonnelrltns(null)
   CALL log_message("In populateEncounterToPersonnelRltns()",log_level_debug)
   SET encntrprsnlreltncnt = size(ejs_request->encounterpersonnelrelationship,5)
   SELECT INTO "nl:"
    FROM encntr_prsnl_reltn epr
    WHERE epr.encntr_id=encntr_id
     AND epr.active_ind=1
     AND epr.expiration_ind=0
     AND epr.beg_effective_dt_tm <= cnvtdatetime(current_date_time)
     AND epr.end_effective_dt_tm >= cnvtdatetime(current_date_time)
    DETAIL
     encntrprsnlreltncnt += 1
     IF (mod(encntrprsnlreltncnt,10)=1)
      stat = alterlist(ejs_request->encounterpersonnelrelationship,(encntrprsnlreltncnt+ 9))
     ENDIF
     ejs_request->encounterpersonnelrelationship[encntrprsnlreltncnt].
     encounterpersonnelrelationshipcv = epr.encntr_prsnl_r_cd, ejs_request->
     encounterpersonnelrelationship[encntrprsnlreltncnt].encounterpersonpersonnelid = epr
     .prsnl_person_id
    FOOT REPORT
     stat = alterlist(ejs_request->encounterpersonnelrelationship,encntrprsnlreltncnt)
    WITH nocounter
   ;end select
   CALL log_message("Exit populateEncounterToPersonnelRltns()",log_level_debug)
 END ;Subroutine
 CALL log_message(concat("exiting script: ",log_program_name),log_level_debug)
END GO
