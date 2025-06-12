CREATE PROGRAM cr_get_templates:dba
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
 SET log_program_name = "CR_GET_TEMPLATES"
 CALL log_message("Starting script: cr_get_templates",log_level_debug)
 FREE RECORD reply
 RECORD reply(
   1 templates[*]
     2 id = f8
     2 name = c150
     2 published_ind = i2
     2 publish_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nno_error = i2 WITH protect, constant(1)
 DECLARE nccl_error = i2 WITH protect, constant(2)
 DECLARE nupdate_cnt_error = i2 WITH protect, constant(3)
 DECLARE ngen_nbr_error = i2 WITH protect, constant(4)
 DECLARE npublished_ind = i2 WITH protect, constant(1)
 DECLARE nunpublished_ind = i2 WITH protect, constant(2)
 DECLARE templatecnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132
 SET errmsg = fillstring(132," ")
 RECORD temp_reply(
   1 templates[*]
     2 id = f8
     2 name = c150
     2 published_ind = i2
     2 publish_dt_tm = dq8
 )
 DECLARE retrievepublishedtemplates(null) = null
 DECLARE retrieveunpublishedtemplates(null) = null
 SET reply->status_data.status = "F"
 IF ((request->published_ind=1))
  CALL retrievepublishedtemplates(null)
 ENDIF
 IF ((request->unpublished_ind=1))
  CALL retrieveunpublishedtemplates(null)
 ENDIF
 IF (templatecnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alterlist(temp_reply->templates,templatecnt)
  CALL sorttemplatesbyname(null)
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE retrievepublishedtemplates(null)
   CALL log_message("Entered RetrievePublishedTemplates subroutine.",log_level_debug)
   SELECT INTO "nl:"
    crt.template_name
    FROM cr_report_template crt,
     cr_template_publish ctp
    PLAN (ctp
     WHERE ctp.template_id > 0
      AND ctp.active_ind=1)
     JOIN (crt
     WHERE crt.report_template_id=ctp.template_id
      AND crt.active_ind=1)
    DETAIL
     templatecnt += 1
     IF (mod(templatecnt,10)=1)
      stat = alterlist(temp_reply->templates,(templatecnt+ 9))
     ENDIF
     temp_reply->templates[templatecnt].id = crt.template_id, temp_reply->templates[templatecnt].name
      = crt.template_name, temp_reply->templates[templatecnt].published_ind = 1,
     temp_reply->templates[templatecnt].publish_dt_tm = cnvtdatetime(ctp.publish_dt_tm)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrievePublishedTemplates",
    "Cr_template_publish and/or cr_report_template table could not be read.  Exiting script.",1,0)
   CALL log_message("Exiting RetrievePublishedTemplates subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieveunpublishedtemplates(null)
   CALL log_message("Entered RetrivedUnpublishedTemplates subroutine.",log_level_debug)
   SELECT INTO "nl:"
    crt.template_name
    FROM cr_report_template crt
    PLAN (crt
     WHERE crt.template_id=crt.report_template_id
      AND crt.template_id > 0
      AND crt.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      ctp.template_id
      FROM cr_template_publish ctp
      WHERE ctp.template_id=crt.template_id
       AND ctp.active_ind=1))))
    DETAIL
     templatecnt += 1
     IF (mod(templatecnt,10)=1)
      stat = alterlist(temp_reply->templates,(templatecnt+ 9))
     ENDIF
     temp_reply->templates[templatecnt].id = crt.template_id, temp_reply->templates[templatecnt].name
      = crt.template_name, temp_reply->templates[templatecnt].published_ind = 0,
     temp_reply->templates[templatecnt].publish_dt_tm = null
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveUnpublishedTemplates",
    "Cr_template_publish and/or cr_report_template table could not be read.  Exiting script.",1,0)
   CALL log_message("Exiting RetrivedUnpublishedTemplates subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE sorttemplatesbyname(null)
   CALL log_message("Entered SortTemplatesByName subroutine.",log_level_debug)
   SET stat = alterlist(reply->templates,templatecnt)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(temp_reply->templates,5))
    ORDER BY cnvtupper(temp_reply->templates[d.seq].name)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1, reply->templates[cnt].id = temp_reply->templates[d.seq].id, reply->templates[cnt].name
      = temp_reply->templates[d.seq].name,
     reply->templates[cnt].published_ind = temp_reply->templates[d.seq].published_ind, reply->
     templates[cnt].publish_dt_tm = temp_reply->templates[d.seq].publish_dt_tm
    WITH nocounter
   ;end select
   CALL log_message("Exiting SortTemplatesByName subroutine.",log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message("End of script: cr_get_templates",log_level_debug)
 FREE RECORD temp_reply
 CALL echorecord(reply)
END GO
