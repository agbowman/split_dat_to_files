CREATE PROGRAM cr_get_report_long_text:dba
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
 SET log_program_name = "CR_GET_REPORT_LONG_TEXT"
 CALL log_message("Starting script: cr_get_report_long_text",log_level_debug)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 template_version
      2 item[*]
        3 version_id = f8
        3 xml_detail = gvc
    1 section_version
      2 item[*]
        3 version_id = f8
        3 xml_detail = gvc
    1 static_region_version
      2 item[*]
        3 version_id = f8
        3 xml_detail = gvc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE lnumoftemplates = i4 WITH noconstant(0)
 DECLARE lnumofsections = i4 WITH noconstant(0)
 DECLARE lnumofregions = i4 WITH noconstant(0)
 DECLARE errmsg = c132
 DECLARE nno_error = i2 WITH protect, constant(1)
 DECLARE nccl_error = i2 WITH protect, constant(2)
 DECLARE nupdate_cnt_error = i2 WITH protect, constant(3)
 DECLARE ngen_nbr_error = i2 WITH protect, constant(4)
 DECLARE retrievesectiondetails(null) = null
 DECLARE retrieveregiondetails(null) = null
 DECLARE retrievetemplatedetails(null) = null
 SET lnumoftemplates = size(request->cr_report_templates,5)
 SET lnumofsections = size(request->cr_report_sections,5)
 SET lnumofregions = size(request->cr_report_static_regions,5)
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 CALL echo(build("num of sects : ",lnumofsections))
 CALL echo(build("num of regs : ",lnumofregions))
 CALL echo(build("num of temps : ",lnumoftemplates))
 IF (lnumofsections > 0)
  CALL echo("before sects")
  CALL retrievesectiondetails(null)
 ENDIF
 IF (lnumofregions > 0)
  CALL echo("before regs")
  CALL retrieveregiondetails(null)
 ENDIF
 IF (lnumoftemplates > 0)
  CALL echo("before temps")
  CALL retrievetemplatedetails(null)
 ENDIF
 SUBROUTINE retrievesectiondetails(null)
   CALL log_message("Entered RetrieveSectionDetails subroutine.",log_level_debug)
   CALL echo("In Sections")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(lnumofsections)),
     cr_report_section crs,
     long_text_reference ltr
    PLAN (d1)
     JOIN (crs
     WHERE (crs.report_section_id=request->cr_report_sections[d1.seq].report_section_id)
      AND crs.report_section_id > 0)
     JOIN (ltr
     WHERE ltr.long_text_id=crs.long_text_id)
    HEAD REPORT
     outbuf = fillstring(100," "), longtextcnt = 0
    DETAIL
     longtextcnt += 1
     IF (mod(longtextcnt,10)=1)
      stat = alterlist(reply->section_version.item,(longtextcnt+ 9))
     ENDIF
     offset = 0, retlen = 1
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,ltr.long_text)
       IF (offset=0)
        reply->section_version.item[longtextcnt].xml_detail = concat(reply->section_version.item[
         longtextcnt].xml_detail,outbuf,"*")
       ELSE
        reply->section_version.item[longtextcnt].xml_detail = concat(substring(1,offset,reply->
          section_version.item[longtextcnt].xml_detail),outbuf,"*")
       ENDIF
       offset += retlen
     ENDWHILE
     reply->section_version.item[longtextcnt].xml_detail = substring(1,(textlen(reply->
       section_version.item[longtextcnt].xml_detail) - 1),reply->section_version.item[longtextcnt].
      xml_detail), reply->section_version.item[longtextcnt].version_id = crs.report_section_id
    FOOT REPORT
     stat = alterlist(reply->section_version.item,longtextcnt)
    WITH rdbarrayfetch = 1
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveSectionDetails",
    "Long_Text could not be read.  Exiting script.",1,0)
 END ;Subroutine
 SUBROUTINE retrieveregiondetails(null)
   CALL log_message("Entered RetrieveRegionDetails subroutine.",log_level_debug)
   CALL echo("In Regions")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(lnumofregions)),
     cr_report_static_region crsr,
     long_text_reference ltr
    PLAN (d1)
     JOIN (crsr
     WHERE (crsr.report_static_region_id=request->cr_report_static_regions[d1.seq].
     report_static_region_id)
      AND crsr.report_static_region_id > 0)
     JOIN (ltr
     WHERE ltr.long_text_id=crsr.long_text_id)
    HEAD REPORT
     outbuf = fillstring(100," "), longtextcnt = 0
    DETAIL
     longtextcnt += 1
     IF (mod(longtextcnt,10)=1)
      stat = alterlist(reply->static_region_version.item,(longtextcnt+ 9))
     ENDIF
     offset = 0, retlen = 1
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,ltr.long_text)
       IF (offset=0)
        reply->static_region_version.item[longtextcnt].xml_detail = concat(reply->
         static_region_version.item[longtextcnt].xml_detail,outbuf,"*")
       ELSE
        reply->static_region_version.item[longtextcnt].xml_detail = concat(substring(1,offset,reply->
          static_region_version.item[longtextcnt].xml_detail),outbuf,"*")
       ENDIF
       offset += retlen
     ENDWHILE
     reply->static_region_version.item[longtextcnt].xml_detail = substring(1,(textlen(reply->
       static_region_version.item[longtextcnt].xml_detail) - 1),reply->static_region_version.item[
      longtextcnt].xml_detail), reply->static_region_version.item[longtextcnt].version_id = crsr
     .report_static_region_id
    FOOT REPORT
     stat = alterlist(reply->static_region_version.item,longtextcnt)
    WITH rdbarrayfetch = 1
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveRegionDetails",
    "Long_Text could not be read.  Exiting script.",1,0)
 END ;Subroutine
 SUBROUTINE retrievetemplatedetails(null)
   CALL log_message("Entered RetrieveTemplateDetails subroutine.",log_level_debug)
   CALL echo("In Templates")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(lnumoftemplates)),
     cr_report_template crt,
     long_text_reference ltr
    PLAN (d1)
     JOIN (crt
     WHERE (crt.report_template_id=request->cr_report_templates[d1.seq].report_template_id)
      AND crt.report_template_id > 0)
     JOIN (ltr
     WHERE ltr.long_text_id=crt.long_text_id)
    HEAD REPORT
     outbuf = fillstring(100," "), longtextcnt = 0
    DETAIL
     longtextcnt += 1
     IF (mod(longtextcnt,10)=1)
      stat = alterlist(reply->template_version.item,(longtextcnt+ 9))
     ENDIF
     offset = 0, retlen = 1
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,ltr.long_text)
       IF (offset=0)
        reply->template_version.item[longtextcnt].xml_detail = concat(reply->template_version.item[
         longtextcnt].xml_detail,outbuf,"*")
       ELSE
        reply->template_version.item[longtextcnt].xml_detail = concat(substring(1,offset,reply->
          template_version.item[longtextcnt].xml_detail),outbuf,"*")
       ENDIF
       offset += retlen
     ENDWHILE
     reply->template_version.item[longtextcnt].xml_detail = substring(1,(textlen(reply->
       template_version.item[longtextcnt].xml_detail) - 1),reply->template_version.item[longtextcnt].
      xml_detail), reply->template_version.item[longtextcnt].version_id = crt.report_template_id
    FOOT REPORT
     stat = alterlist(reply->template_version.item,longtextcnt)
    WITH nocounter, rdbarrayfetch = 1
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveTemplateDetails",
    "Long_Text could not be read.  Exiting script.",1,0)
 END ;Subroutine
 IF (size(reply->template_version.item,5)=0
  AND size(reply->section_version.item,5)=0
  AND size(reply->static_region_version.item,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("End of script: cr_get_report_long_text",log_level_debug)
 CALL echorecord(reply)
END GO
