CREATE PROGRAM cr_generate_facesheet:dba
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
 SET log_program_name = "cr_generate_facesheet"
 SET modify maxvarlen 20000000
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 facesheetdocument = gvc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD getfacesheetreq
 RECORD getfacesheetreq(
   1 facesheetlist[*]
     2 facesheetid = f8
 )
 FREE RECORD getfacesheetrep
 RECORD getfacesheetrep(
   1 facesheets[*]
     2 facesheetid = f8
     2 display = vc
     2 data_source_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD ekssourcerequest
 RECORD ekssourcerequest(
   1 module_dir = vc
   1 module_name = vc
   1 basblob = i2
 )
 FREE RECORD ekssourcereply
 RECORD ekssourcereply(
   1 info_line[*]
     2 new_line = vc
   1 data_blob = gvc
   1 data_blob_size = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE facesheetfilename = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 CALL log_message("Begin Service: cr_generate_facesheet",log_level_debug)
 IF ((((request->facesheetid <= 0.0)) OR ((request->personid <= 0.0))) )
  CALL log_message("Invalid Request",log_level_error)
  GO TO exit_script
 ENDIF
 SET facesheetfilename = getuniquefilename(concat("cr_facesheet_",trim(cnvtstring(request->
     facesheetid,16,0))))
 SET stat = alterlist(getfacesheetreq->facesheetlist,1)
 SET getfacesheetreq->facesheetlist[1].facesheetid = request->facesheetid
 EXECUTE cr_get_facesheets  WITH replace("REQUEST",getfacesheetreq), replace("REPLY",getfacesheetrep)
 IF ((getfacesheetrep->status_data.status != "S"))
  CALL log_message(
   "The facesheet provided is invalid. Ensure its active and the XR_FACESHEET extension is set.",
   log_level_error)
  GO TO exit_script
 ENDIF
 EXECUTE value(cnvtupper(trim(getfacesheetrep->facesheets[1].data_source_name,3))) facesheetfilename,
 trim(cnvtstring(request->personid,16,0),3), trim(cnvtstring(request->encounterid,16,0),3),
 "0.0", "0.0"
 IF (validate(debug,- (1)) > 0)
  CALL echo(facesheetfilename)
 ENDIF
 SET ekssourcerequest->module_dir = "ccluserdir:"
 SET ekssourcerequest->module_name = facesheetfilename
 SET ekssourcerequest->basblob = true
 EXECUTE eks_get_source  WITH replace("REQUEST",ekssourcerequest), replace("REPLY",ekssourcereply)
 SET reply->facesheetdocument = ekssourcereply->data_blob
 IF (findfile(facesheetfilename))
  SET stat = remove(facesheetfilename)
 ENDIF
 IF ((ekssourcereply->status_data.status != "S"))
  CALL log_message("The generated facesheet could not be found",log_level_error)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL log_message("End Service: cr_generate_facesheet",log_level_debug)
 SUBROUTINE (getuniquefilename(prefix=vc) =vc)
   CALL log_message("Entering getUniqueFilename()",log_level_debug)
   DECLARE file_name = vc WITH protect
   EXECUTE cpm_create_file_name prefix, "pdf"
   SET file_name = cpm_cfn_info->file_name
   CALL log_message(build2("Exiting getUniqueFilename with filename: ",file_name),log_level_debug)
   RETURN(file_name)
 END ;Subroutine
 FREE RECORD getfacesheetreq
 FREE RECORD getfacesheetrep
 FREE RECORD ekssourcerequest
 FREE RECORD ekssourcereply
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
END GO
