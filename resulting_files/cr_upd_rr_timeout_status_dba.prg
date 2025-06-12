CREATE PROGRAM cr_upd_rr_timeout_status:dba
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
 SET log_program_name = "cr_upd_rr_timeout_status"
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temprec
 RECORD temprec(
   1 qual[*]
     2 report_request_id = f8
     2 report_status_cd = f8
 )
 CALL log_message("Starting script: cr_upd_rr_timeout_status",log_level_debug)
 DECLARE currentdatetime = q8 WITH public, noconstant(cnvtdatetime(sysdate))
 DECLARE param_delimiter = vc WITH constant(";")
 DECLARE value_delimiter = vc WITH constant("=")
 DECLARE inprocess = vc WITH constant("INPROCESS")
 DECLARE inprocdatart = vc WITH constant("INPROCDATART")
 DECLARE inprocrgen = vc WITH constant("INPROCRGEN")
 DECLARE senttodist = vc WITH constant("SENTTODIST")
 DECLARE batchinproc = vc WITH constant("BATCHINPROC")
 DECLARE archivedinpr = vc WITH constant("ARCHIVEDINPR")
 DECLARE rdistinproc = vc WITH constant("RDISTINPROC")
 DECLARE unsubmitted = vc WITH constant("UNSUBMITTED")
 DECLARE iinproctimeout = i4 WITH noconstant(3)
 DECLARE iinprocdatarttimeout = i4 WITH noconstant(3)
 DECLARE iinprocrgentimeout = i4 WITH noconstant(3)
 DECLARE isenttodisttimeout = i4 WITH noconstant(3)
 DECLARE irdistinproctimeout = i4 WITH noconstant(24)
 DECLARE ibatchtimeout = i4 WITH noconstant(24)
 DECLARE iarchivedinproctimeout = i4 WITH noconstant(3)
 DECLARE iunsubmittedtimeout = i4 WITH noconstant(24)
 DECLARE dbatchinproccd = f8
 DECLARE dinproccd = f8
 DECLARE dinprocdatartcd = f8
 DECLARE dinprocrgencd = f8
 DECLARE dsenttodistcd = f8
 DECLARE darchivedinproccd = f8
 DECLARE drdistinproccd = f8
 DECLARE dunsubmittedcd = f8
 DECLARE dtounsubmitcd = f8
 DECLARE dtoinproccd = f8
 DECLARE dtoindatacd = f8
 DECLARE dtoinrptgetcd = f8
 DECLARE dtosentdistcd = f8
 DECLARE dtoinbatchcd = f8
 DECLARE dtoinarchcd = f8
 DECLARE dtoinrptdistcd = f8
 SET stat = uar_get_meaning_by_codeset(367571,"INPROCESS",1,dinproccd)
 SET stat = uar_get_meaning_by_codeset(367571,"INPROCDATART",1,dinprocdatartcd)
 SET stat = uar_get_meaning_by_codeset(367571,"INPROCRGEN",1,dinprocrgencd)
 SET stat = uar_get_meaning_by_codeset(367571,"SENTTODIST",1,dsenttodistcd)
 SET stat = uar_get_meaning_by_codeset(367571,"BATCHINPROC",1,dbatchinproccd)
 SET stat = uar_get_meaning_by_codeset(367571,"ARCHIVEDINPR",1,darchivedinproccd)
 SET stat = uar_get_meaning_by_codeset(367571,"RDISTINPROC",1,drdistinproccd)
 SET stat = uar_get_meaning_by_codeset(367571,"UNSUBMITTED",1,dunsubmittedcd)
 SET stat = uar_get_meaning_by_codeset(367571,"TO_UNSUBMIT",1,dtounsubmitcd)
 SET stat = uar_get_meaning_by_codeset(367571,"TO_INPROC",1,dtoinproccd)
 SET stat = uar_get_meaning_by_codeset(367571,"TO_INDATA",1,dtoindatacd)
 SET stat = uar_get_meaning_by_codeset(367571,"TO_INRPTGEN",1,dtoinrptgetcd)
 SET stat = uar_get_meaning_by_codeset(367571,"TO_SENTDIST",1,dtosentdistcd)
 SET stat = uar_get_meaning_by_codeset(367571,"TO_INBATCH",1,dtoinbatchcd)
 SET stat = uar_get_meaning_by_codeset(367571,"TO_INARCH",1,dtoinarchcd)
 SET stat = uar_get_meaning_by_codeset(367571,"TO_INRPTDIST",1,dtoinrptdistcd)
 DECLARE getstatustimeoutperiod(null) = null
 DECLARE gettimeoutrequests(null) = null
 DECLARE updatetimeoutrequests(null) = null
 DECLARE insertrequestactivities(null) = null
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 CALL getstatustimeoutperiod(null)
 CALL gettimeoutrequests(null)
 CALL updatetimeoutrequests(null)
 CALL insertrequestactivities(null)
 SUBROUTINE getstatustimeoutperiod(null)
   CALL log_message("GetStatusTimeOutPeriod subroutine.",log_level_debug)
   DECLARE timeoutparams = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="ClinicalReporting"
      AND di.info_name="XR Status TimeOut Param")
    DETAIL
     timeoutparams = di.info_char
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GetStatusTimeOutPeriod",
    "Retrieving XR report status time-out parameter from dm_info table",1,0)
   IF (size(timeoutparams) > 0)
    CALL log_message(build("Timeout parameters found: ",timeoutparams),log_level_debug)
    CALL parsetimeoutparameters(timeoutparams)
   ELSE
    CALL log_message(
     "Timeout parameters are not found in dm_info table.  The default values will be used.",
     log_level_debug)
   ENDIF
   CALL log_message("Exit GetStatusTimeOutPeriod subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (parsetimeoutparameters(parameters=vc) =null)
   CALL log_message("ParseTimeOutParameters subroutine.",log_level_debug)
   DECLARE paramsize = i4 WITH private, noconstant(size(parameters))
   DECLARE startpos = i4 WITH private, noconstant(1)
   DECLARE endpos = i4 WITH private, noconstant(0)
   DECLARE param = vc WITH private, noconstant(" ")
   WHILE (startpos <= paramsize)
    SET endpos = findstring(param_delimiter,parameters,startpos,0)
    IF (endpos > 0)
     SET param = substring(startpos,(endpos - startpos),parameters)
     CALL parseparameter(param)
     SET startpos = (endpos+ 1)
    ELSE
     SET param = substring(startpos,((paramsize - startpos)+ 1),parameters)
     CALL parseparameter(param)
     SET startpos = (paramsize+ 1)
    ENDIF
   ENDWHILE
   CALL log_message("Exit ParseTimeOutParameters subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (parseparameter(parameter=vc) =null)
   CALL log_message("ParseParameter subroutine.",log_level_debug)
   DECLARE paramname = vc WITH private, noconstant(" ")
   DECLARE paramvalue = i4 WITH private, noconstant(0)
   DECLARE paramsize = i4 WITH private, noconstant(size(parameter))
   DECLARE delimiterpos = i4 WITH private, noconstant(findstring(value_delimiter,parameter,1,0))
   IF (delimiterpos > 0)
    SET paramname = trim(substring(1,(delimiterpos - 1),parameter),3)
    SET paramvalue = cnvtint(trim(substring((delimiterpos+ 1),(paramsize - delimiterpos),parameter),3
      ))
    IF (paramvalue > 0)
     IF (paramname=inprocess)
      SET iinproctimeout = paramvalue
     ELSEIF (paramname=inprocdatart)
      SET iinprocdatarttimeout = paramvalue
     ELSEIF (paramname=inprocrgen)
      SET iinprocrgentimeout = paramvalue
     ELSEIF (paramname=senttodist)
      SET isenttodisttimeout = paramvalue
     ELSEIF (paramname=batchinproc)
      SET ibatchtimeout = paramvalue
     ELSEIF (paramname=archivedinpr)
      SET iarchivedinproctimeout = paramvalue
     ELSEIF (paramname=rdistinproc)
      SET irdistinproctimeout = paramvalue
     ELSEIF (paramname=unsubmitted)
      SET iunsubmittedtimeout = paramvalue
     ELSE
      CALL log_message(build("The parameter name: ",paramname," is invalid."),log_level_debug)
     ENDIF
    ELSE
     CALL log_message(build("The parameter value: ",paramvalue," is invalid."),log_level_debug)
    ENDIF
   ELSE
    CALL log_message(build("The parameter: ",parameter," is invalid."),log_level_debug)
   ENDIF
   CALL log_message("Exit ParseParameter subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE gettimeoutrequests(null)
   CALL log_message("GetTimeOutRequests subroutine.",log_level_debug)
   DECLARE unsubmittedexpiretime = dq8 WITH noconstant(cnvtlookbehind(nullterm(build(
       iunsubmittedtimeout,", H")),currentdatetime))
   DECLARE inprocexpiretime = dq8 WITH noconstant(cnvtlookbehind(nullterm(build(iinproctimeout,", H")
      ),currentdatetime))
   DECLARE inprocdatartexpiretime = dq8 WITH noconstant(cnvtlookbehind(nullterm(build(
       iinprocdatarttimeout,", H")),currentdatetime))
   DECLARE inprocrgenexpiretime = dq8 WITH noconstant(cnvtlookbehind(nullterm(build(
       iinprocrgentimeout,", H")),currentdatetime))
   DECLARE senttodistexpiretime = dq8 WITH noconstant(cnvtlookbehind(nullterm(build(
       isenttodisttimeout,", H")),currentdatetime))
   DECLARE batchexpiretime = dq8 WITH noconstant(cnvtlookbehind(nullterm(build(ibatchtimeout,", H")),
     currentdatetime))
   DECLARE archivedinprocexpiretime = dq8 WITH noconstant(cnvtlookbehind(nullterm(build(
       iarchivedinproctimeout,", H")),currentdatetime))
   DECLARE rdistinprocexpiretime = dq8 WITH noconstant(cnvtlookbehind(nullterm(build(
       irdistinproctimeout,", H")),currentdatetime))
   SELECT INTO "nl:"
    FROM cr_report_request cr
    PLAN (cr
     WHERE ((cr.report_request_id+ 0) > 0.0)
      AND ((cr.report_status_cd=dinproccd
      AND cr.updt_dt_tm <= cnvtdatetime(inprocexpiretime)) OR (((cr.report_status_cd=dinprocdatartcd
      AND cr.updt_dt_tm <= cnvtdatetime(inprocdatartexpiretime)) OR (((cr.report_status_cd=
     dinprocrgencd
      AND cr.updt_dt_tm <= cnvtdatetime(inprocrgenexpiretime)) OR (((cr.report_status_cd=
     dsenttodistcd
      AND cr.updt_dt_tm <= cnvtdatetime(senttodistexpiretime)) OR (((cr.report_status_cd=
     dbatchinproccd
      AND cr.updt_dt_tm <= cnvtdatetime(batchexpiretime)) OR (((cr.report_status_cd=darchivedinproccd
      AND cr.updt_dt_tm <= cnvtdatetime(archivedinprocexpiretime)) OR (((cr.report_status_cd=
     drdistinproccd
      AND cr.updt_dt_tm <= cnvtdatetime(rdistinprocexpiretime)) OR (cr.report_status_cd=
     dunsubmittedcd
      AND cr.updt_dt_tm <= cnvtdatetime(unsubmittedexpiretime))) )) )) )) )) )) )) )
    HEAD REPORT
     count = 0
    DETAIL
     count += 1
     IF (mod(count,10)=1)
      stat = alterlist(temprec->qual,(count+ 9))
     ENDIF
     temprec->qual[count].report_request_id = cr.report_request_id, temprec->qual[count].
     report_status_cd =
     IF (cr.report_status_cd=dinproccd) dtoinproccd
     ELSEIF (cr.report_status_cd=dinprocdatartcd) dtoindatacd
     ELSEIF (cr.report_status_cd=dinprocrgencd) dtoinrptgetcd
     ELSEIF (cr.report_status_cd=dsenttodistcd) dtosentdistcd
     ELSEIF (cr.report_status_cd=dbatchinproccd) dtoinbatchcd
     ELSEIF (cr.report_status_cd=darchivedinproccd) dtoinarchcd
     ELSEIF (cr.report_status_cd=dunsubmittedcd) dtounsubmitcd
     ELSE dtoinrptdistcd
     ENDIF
    FOOT REPORT
     stat = alterlist(temprec->qual,count)
    WITH nocounter, forupdate(cr)
   ;end select
   CALL error_and_zero_check(curqual,"GetTimeOutRequests",
    "Retrieving report requests with timeout status",1,1)
   CALL log_message("Exit GetTimeOutRequests subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE updatetimeoutrequests(null)
   CALL log_message("Entered UpdateTimeOutRequests subroutine.",log_level_debug)
   DECLARE reqnbr = i4 WITH private, noconstant(size(temprec->qual,5))
   UPDATE  FROM (dummyt d  WITH seq = value(reqnbr)),
     cr_report_request cr
    SET cr.report_status_cd = temprec->qual[d.seq].report_status_cd, cr.updt_cnt = (cr.updt_cnt+ 1),
     cr.updt_dt_tm = cnvtdatetime(currentdatetime),
     cr.updt_id = reqinfo->updt_id, cr.updt_applctx = reqinfo->updt_applctx, cr.updt_task = reqinfo->
     updt_task
    PLAN (d)
     JOIN (cr
     WHERE (cr.report_request_id=temprec->qual[d.seq].report_request_id))
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"UpdateTimeOutRequests",
    "Update report status into cr_report_request table",1,1)
   CALL log_message("Exit UpdateReportRequests subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertrequestactivities(null)
   CALL log_message("Entered InsertRequestActivities subroutine.",log_level_debug)
   INSERT  FROM cr_report_request_activity act,
     (dummyt d  WITH seq = size(temprec->qual,5))
    SET act.report_request_activity_id = seq(chart_act_seq,nextval), act.report_request_id = temprec
     ->qual[d.seq].report_request_id, act.report_status_cd = temprec->qual[d.seq].report_status_cd
    PLAN (d)
     JOIN (act)
    WITH nocounter, rdbarrayinsert = 1
   ;end insert
   CALL error_and_zero_check(curqual,"InsertRequestActivities",
    "Insertion into cr_report_request_activity table failed. Exiting script.",1,0)
   CALL log_message("Exit InsertRequestActivities subroutine.",log_level_debug)
 END ;Subroutine
 CALL echorecord(temprec)
 SET reply->status_data.status = "S"
 IF ((request->test_ind=0))
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
 FREE RECORD temprec
 CALL log_message("End of script: cr_upd_rr_timeout_status",log_level_debug)
END GO
