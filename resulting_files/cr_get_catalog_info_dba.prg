CREATE PROGRAM cr_get_catalog_info:dba
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
 SET log_program_name = "CR_GET_CATALOG_INFO"
 CALL log_message("Starting script: cr_get_catalog_info",log_level_debug)
 FREE RECORD reply
 RECORD reply(
   1 template_catalog
     2 item[*]
       3 id = f8
   1 section_catalog
     2 item[*]
       3 id = f8
   1 static_region_catalog
     2 item[*]
       3 id = f8
   1 style_profile_catalog
     2 item[*]
       3 id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 legend_catalog
     2 item[*]
       3 id = f8
 )
 DECLARE qual_clause = vc
 DECLARE errmsg = c132
 DECLARE nno_error = i2 WITH protect, constant(1)
 DECLARE nccl_error = i2 WITH protect, constant(2)
 DECLARE nupdate_cnt_error = i2 WITH protect, constant(3)
 DECLARE ngen_nbr_error = i2 WITH protect, constant(4)
 DECLARE ntemplate_ind = i2 WITH protect, constant(1)
 DECLARE nsection_ind = i2 WITH protect, constant(2)
 DECLARE nregion_ind = i2 WITH protect, constant(3)
 DECLARE nstyle_profile_ind = i2 WITH protect, constant(4)
 DECLARE nlegend_ind = i2 WITH protect, constant(5)
 DECLARE retrievesections(null) = null
 DECLARE retrieveregions(null) = null
 DECLARE retrievetemplates(null) = null
 DECLARE retrievestyleprofiles(null) = null
 DECLARE retrievelegends(null) = null
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 IF ((((request->active_sections_ind=1)) OR ((request->inactive_sections_ind=1))) )
  CALL retrievesections(null)
 ENDIF
 IF ((((request->active_regions_ind=1)) OR ((request->inactive_regions_ind=1))) )
  CALL retrieveregions(null)
 ENDIF
 IF ((((request->active_templates_ind=1)) OR ((request->inactive_templates_ind=1))) )
  CALL retrievetemplates(null)
 ENDIF
 IF ((((request->active_style_profiles_ind=1)) OR ((request->inactive_style_profiles_ind=1))) )
  CALL retrievestyleprofiles(null)
 ENDIF
 IF ((((request->active_legends_ind=1)) OR ((request->inactive_legends_ind=1))) )
  CALL retrievelegends(null)
 ENDIF
 SUBROUTINE retrievesections(null)
   CALL log_message("Entered RetrieveSections subroutine.",log_level_debug)
   CALL createqualclause(nsection_ind)
   SELECT INTO "nl:"
    FROM cr_report_section crs
    WHERE parser(qual_clause)
    HEAD REPORT
     sectcnt = 0
    DETAIL
     sectcnt += 1
     IF (mod(sectcnt,10)=1)
      stat = alterlist(reply->section_catalog.item,(sectcnt+ 9))
     ENDIF
     reply->section_catalog.item[sectcnt].id = crs.section_id
    FOOT REPORT
     stat = alterlist(reply->section_catalog.item,sectcnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveSections",
    "CR_Report_Section table could not be read.  Exiting script.",1,0)
   CALL log_message("Exiting RetrieveSections subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievestyleprofiles(null)
   CALL log_message("Entered RetrieveStyleProfiles subroutine.",log_level_debug)
   CALL createqualclause(nstyle_profile_ind)
   SELECT INTO "nl:"
    FROM cr_report_style_profile crsp
    WHERE parser(qual_clause)
    HEAD REPORT
     styleprofilecnt = 0
    DETAIL
     styleprofilecnt += 1
     IF (mod(styleprofilecnt,10)=1)
      stat = alterlist(reply->style_profile_catalog.item,(styleprofilecnt+ 9))
     ENDIF
     reply->style_profile_catalog.item[styleprofilecnt].id = crsp.style_profile_id
    FOOT REPORT
     stat = alterlist(reply->style_profile_catalog.item,styleprofilecnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveStyleProfiles",
    "CR_Report_Style_Profile table could not be read.  Exiting script.",1,0)
   CALL log_message("Exiting RetrieveStyleProfiles subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievelegends(null)
   CALL log_message("Entered RetrieveLegends subroutine.",log_level_debug)
   CALL createqualclause(nlegend_ind)
   SELECT INTO "nl:"
    FROM cr_report_legend crl
    WHERE parser(qual_clause)
    HEAD REPORT
     legendcnt = 0
    DETAIL
     legendcnt += 1
     IF (mod(legendcnt,10)=1)
      stat = alterlist(reply->legend_catalog.item,(legendcnt+ 9))
     ENDIF
     reply->legend_catalog.item[legendcnt].id = crl.legend_id
    FOOT REPORT
     stat = alterlist(reply->legend_catalog.item,legendcnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveLegends",
    "CR_report_legend table could not be read.  Exiting script.",1,0)
   CALL log_message("Exiting RetrieveLegends subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieveregions(null)
   CALL log_message("Entered RetrieveRegions subroutine.",log_level_debug)
   CALL createqualclause(nregion_ind)
   SELECT INTO "nl:"
    FROM cr_report_static_region crr
    WHERE parser(qual_clause)
    HEAD REPORT
     regcnt = 0
    DETAIL
     regcnt += 1
     IF (mod(regcnt,10)=1)
      stat = alterlist(reply->static_region_catalog.item,(regcnt+ 9))
     ENDIF
     reply->static_region_catalog.item[regcnt].id = crr.static_region_id
    FOOT REPORT
     stat = alterlist(reply->static_region_catalog.item,regcnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveRegions",
    "CR_Report_Static_Region table could not be read.  Exiting script.",1,0)
   CALL log_message("Exiting RetrieveRegions subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievetemplates(null)
   CALL log_message("Entered RetrieveTemplates subroutine.",log_level_debug)
   CALL createqualclause(ntemplate_ind)
   SELECT INTO "nl:"
    FROM cr_report_template crt
    WHERE parser(qual_clause)
    HEAD REPORT
     tempcnt = 0
    DETAIL
     tempcnt += 1
     IF (mod(tempcnt,10)=1)
      stat = alterlist(reply->template_catalog.item,(tempcnt+ 9))
     ENDIF
     reply->template_catalog.item[tempcnt].id = crt.template_id
    FOOT REPORT
     stat = alterlist(reply->template_catalog.item,tempcnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveTemplates",
    "CR_Report_Template table could not be read.  Exiting script.",1,0)
   CALL log_message("Exiting RetrieveTemplates subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (createqualclause(qualind=i2) =null)
   CALL log_message("Entered CreateQualClause subroutine.",log_level_debug)
   IF (qualind=nsection_ind)
    IF ((request->active_sections_ind=1))
     SET qual_clause = "(crs.section_id = crs.report_section_id and crs.section_id > 0)"
     IF ((request->inactive_sections_ind=1))
      SET qual_clause = concat(qual_clause," and (crs.active_ind = 1 or crs.active_ind = 0)")
     ELSE
      SET qual_clause = concat(qual_clause," and (crs.active_ind = 1)")
     ENDIF
    ELSEIF ((request->inactive_sections_ind=1))
     SET qual_clause = "(crs.section_id = crs.report_section_id and crs.section_id > 0)"
     SET qual_clause = concat(qual_clause," and (crs.active_ind = 0)")
    ENDIF
   ELSEIF (qualind=nregion_ind)
    IF ((request->active_regions_ind=1))
     SET qual_clause =
     "(crr.static_region_id = crr.report_static_region_id and crr.static_region_id > 0)"
     IF ((request->inactive_regions_ind=1))
      SET qual_clause = concat(qual_clause," and (crr.active_ind = 1 or crr.active_ind = 0)")
     ELSE
      SET qual_clause = concat(qual_clause," and (crr.active_ind = 1)")
     ENDIF
    ELSEIF ((request->inactive_regions_ind=1))
     SET qual_clause =
     "(crr.static_region_id = crr.report_static_region_id and crr.static_region_id > 0)"
     SET qual_clause = concat(qual_clause," and (crr.active_ind = 0)")
    ENDIF
   ELSEIF (qualind=nstyle_profile_ind)
    IF ((request->active_style_profiles_ind=1))
     SET qual_clause = "(crsp.style_profile_id = crsp.report_style_profile_id"
     SET qual_clause = concat(qual_clause," and crsp.style_profile_id > 0)")
     IF ((request->inactive_style_profiles_ind=1))
      SET qual_clause = concat(qual_clause," and (crsp.active_ind = 1 or crsp.active_ind = 0)")
     ELSE
      SET qual_clause = concat(qual_clause," and (crsp.active_ind = 1)")
     ENDIF
    ELSEIF ((request->inactive_style_profiles_ind=1))
     SET qual_clause = "(crsp.style_profile_id = crsp.report_style_profile_id"
     SET qual_clause = concat(qual_clause," and crsp.style_profile_id > 0)")
     SET qual_clause = concat(qual_clause," and (crsp.active_ind = 0)")
    ENDIF
   ELSEIF (qualind=nlegend_ind)
    IF ((request->active_legends_ind=1))
     SET qual_clause = "(crl.legend_id = crl.report_legend_id"
     SET qual_clause = concat(qual_clause," and crl.legend_id > 0)")
     IF ((request->inactive_legends_ind=1))
      SET qual_clause = concat(qual_clause," and (crl.active_ind = 1 or crl.active_ind = 0)")
     ELSE
      SET qual_clause = concat(qual_clause," and (crl.active_ind = 1)")
     ENDIF
    ELSEIF ((request->inactive_legends_ind=1))
     SET qual_clause = "(crl.legend_id = crl.report_legend_id"
     SET qual_clause = concat(qual_clause," and crl.legend_id > 0)")
     SET qual_clause = concat(qual_clause," and (crl.active_ind = 0)")
    ENDIF
   ELSEIF (qualind=ntemplate_ind)
    IF ((request->active_templates_ind=1))
     SET qual_clause = "(crt.template_id = crt.report_template_id and crt.template_id > 0)"
     IF ((request->inactive_templates_ind=1))
      SET qual_clause = concat(qual_clause," and (crt.active_ind = 1 or crt.active_ind = 0)")
     ELSE
      SET qual_clause = concat(qual_clause," and (crt.active_ind = 1)")
     ENDIF
    ELSEIF ((request->inactive_templates_ind=1))
     SET qual_clause = "(crt.template_id = crt.report_template_id and crt.template_id > 0)"
     SET qual_clause = concat(qual_clause," and (crt.active_ind = 0)")
    ENDIF
   ENDIF
   CALL echo(build("qual_clause = ",qual_clause))
   CALL log_message("Exiting CreateQualClause subroutine.",log_level_debug)
 END ;Subroutine
 IF (size(reply->template_catalog.item,5)=0
  AND size(reply->section_catalog.item,5)=0
  AND size(reply->static_region_catalog.item,5)=0
  AND size(reply->style_profile_catalog.item,5)=0
  AND size(reply->legend_catalog.item,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("End of script: cr_get_catalog_info",log_level_debug)
 CALL echorecord(reply)
END GO
