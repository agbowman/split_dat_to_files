CREATE PROGRAM cr_convert_archives_for_ld:dba
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
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD archiverequests
 RECORD archiverequests(
   1 archives[*]
     2 reportrequestarchiveid = f8
 )
 FREE RECORD archiverequest
 RECORD archiverequest(
   1 reportrequestarchiveid = f8
 )
 DECLARE archiveidx = i4 WITH private, noconstant(0)
 DECLARE archivefailedind = i2 WITH private, noconstant(false)
 CALL log_message(concat("Beginning ",curprog),log_level_debug)
 SET reply->status_data.status = "F"
 SET modify maxvarlen 9999999
 IF ( NOT (getarchiverows(archiverequests)))
  CALL log_message("Failed to retrieve archive rows",log_level_error)
  GO TO exit_script
 ENDIF
 IF ((( NOT (ismultitenant(null))) OR (size(archiverequests->archives,5) <= 0)) )
  CALL log_message(
   "The site is not a multi-tenant site or has not run a purge yet. No conversion is necessary.",
   log_level_info)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 FOR (archiveidx = 1 TO size(archiverequests->archives,5))
   SET archiverequest->reportrequestarchiveid = archiverequests->archives[archiveidx].
   reportrequestarchiveid
   CALL echo(build("Currently Processing Archive: ",archiverequest->reportrequestarchiveid))
   EXECUTE cr_purged_request_utility  WITH replace("REQUEST",archiverequest), replace("REPLY",reply)
   IF ((reply->status_data.status="F"))
    CALL log_message(build2("Archive (report_request_archive_id) ",archiverequests->archives[
      archiveidx].reportrequestarchiveid," Failed to convert."),log_level_error)
    SET archivefailedind = true
   ELSE
    CALL log_message(build2("Archive (report_request_archive_id) ",archiverequests->archives[
      archiveidx].reportrequestarchiveid," was Successfully to converted!"),log_level_error)
   ENDIF
 ENDFOR
 IF ( NOT (archivefailedind))
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE (getarchiverows(archives=vc(ref)) =i2)
   CALL log_message("Entering getArchiveRows",log_level_debug)
   SELECT INTO "nl:"
    FROM cr_report_request_archive cr
    WHERE cr.report_request_archive_id > 0.0
     AND cr.logical_domain_id=0.0
    ORDER BY cr.archived_dt_tm
    HEAD REPORT
     archivecnt = 0
    DETAIL
     archivecnt += 1, stat = alterlist(archives->archives,archivecnt), archives->archives[archivecnt]
     .reportrequestarchiveid = cr.report_request_archive_id
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(archives)
   ENDIF
   CALL log_message("Exiting getArchiveRows",log_level_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (ismultitenant(null=i2) =i2)
   CALL log_message("Entering isMultiTenant",log_level_debug)
   DECLARE ismultitenant = i2 WITH private, noconstant(false)
   DECLARE logicaldomaincnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM logical_domain ld
    WHERE ld.active_ind=1
    DETAIL
     logicaldomaincnt += 1
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echo(concat(cnvtstring(logicaldomaincnt)," Logical Domain(s) exist"))
   ENDIF
   IF (logicaldomaincnt > 1)
    SET ismultitenant = true
   ENDIF
   CALL log_message("Exiting isMultiTenant",log_level_debug)
   RETURN(ismultitenant)
 END ;Subroutine
#exit_script
 FREE RECORD archiverequests
 FREE RECORD archiverequest
 CALL echorecord(reply)
 CALL log_message(concat("Exiting ",curprog),log_level_debug)
END GO
