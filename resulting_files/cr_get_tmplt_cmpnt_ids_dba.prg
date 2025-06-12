CREATE PROGRAM cr_get_tmplt_cmpnt_ids:dba
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
 SET log_program_name = "CR_GET_TMPLT_CMPNT_IDS"
 CALL log_message("Starting script: cr_get_tmplt_cmpnt_ids",log_level_debug)
 FREE RECORD reply
 RECORD reply(
   1 template_ids[*]
     2 id = f8
     2 name = vc
   1 section_ids[*]
     2 id = f8
     2 name = vc
   1 page_master_ids[*]
     2 id = f8
     2 name = vc
   1 style_profile_ids[*]
     2 id = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 legend_ids[*]
     2 id = f8
     2 name = vc
 )
 FREE RECORD names
 RECORD names(
   1 qual[*]
     2 name = vc
 )
 DECLARE retrievetemplateids(null) = null
 DECLARE retrievesectionids(null) = null
 DECLARE retrievepagemasterids(null) = null
 DECLARE retrievestyleprofileids(null) = null
 DECLARE retrievelegendids(null) = null
 DECLARE converttonamekey(null) = null
 DECLARE lnumoftemplates = i4 WITH noconstant(0)
 DECLARE lnumofsections = i4 WITH noconstant(0)
 DECLARE lnumofpagemasters = i4 WITH noconstant(0)
 DECLARE lnumofstyleprofiles = i4 WITH noconstant(0)
 DECLARE lnumoflegends = i4 WITH noconstant(0)
 SET lnumoftemplates = size(request->template_names,5)
 SET lnumofsections = size(request->section_names,5)
 SET lnumofpagemasters = size(request->page_master_names,5)
 SET lnumofstyleprofiles = size(request->style_profile_names,5)
 SET lnumoflegends = size(request->legend_names,5)
 SET reply->status_data.status = "F"
 IF (lnumoftemplates > 0)
  CALL echo("size of templates")
  CALL echo(lnumoftemplates)
  SET stat = alterlist(names->qual,lnumoftemplates)
  FOR (lforcount = 1 TO lnumoftemplates)
    SET names->qual[lforcount].name = trim(cnvtupper(cnvtalphanum(request->template_names[lforcount].
       name)),3)
  ENDFOR
  CALL echo("before template subroutine")
  CALL retrievetemplateids(null)
  SET stat = alterlist(names->qual,0)
 ENDIF
 IF (lnumofsections > 0)
  CALL echo("size of sections: ")
  CALL echo(lnumofsections)
  SET stat = alterlist(names->qual,lnumofsections)
  FOR (lforcount = 1 TO lnumofsections)
    SET names->qual[lforcount].name = trim(cnvtupper(cnvtalphanum(request->section_names[lforcount].
       name)),3)
  ENDFOR
  CALL echo("before section subroutine")
  CALL retrievesectionids(null)
  SET stat = alterlist(names->qual,0)
 ENDIF
 IF (lnumofpagemasters > 0)
  CALL echo("size of pagemasters: ")
  CALL echo(lnumofpagemasters)
  SET stat = alterlist(names->qual,lnumofpagemasters)
  FOR (lforcount = 1 TO lnumofpagemasters)
    SET names->qual[lforcount].name = trim(cnvtupper(cnvtalphanum(request->page_master_names[
       lforcount].name)),3)
  ENDFOR
  CALL echo("before pageMaster subroutine")
  CALL retrievepagemasterids(null)
  SET stat = alterlist(names->qual,0)
 ENDIF
 IF (lnumofstyleprofiles > 0)
  CALL echo("size of style profiles: ")
  CALL echo(lnumofstyleprofiles)
  SET stat = alterlist(names->qual,lnumofstyleprofiles)
  FOR (lforcount = 1 TO lnumofstyleprofiles)
    SET names->qual[lforcount].name = trim(cnvtupper(cnvtalphanum(request->style_profile_names[
       lforcount].name)),3)
  ENDFOR
  CALL echo("before style profile subroutine")
  CALL retrievestyleprofileids(null)
  SET stat = alterlist(names->qual,0)
 ENDIF
 IF (lnumoflegends > 0)
  CALL echo("size of legends: ")
  CALL echo(lnumoflegends)
  SET stat = alterlist(names->qual,lnumoflegends)
  FOR (lforcount = 1 TO lnumoflegends)
    SET names->qual[lforcount].name = trim(cnvtupper(cnvtalphanum(request->legend_names[lforcount].
       name)),3)
  ENDFOR
  CALL echo("before legends subroutine")
  CALL retrievelegendids(null)
  SET stat = alterlist(names->qual,0)
 ENDIF
 SUBROUTINE retrievetemplateids(null)
   CALL log_message("Entered RetrieveTemplateIds subroutine.",log_level_debug)
   CALL echo("In Templates")
   DECLARE lidx = i4
   DECLARE counter = i4
   DECLARE active_parser = vc WITH noconstant(" crt.active_ind = 1"), protect
   IF ((request->include_inactive_components=1))
    SET active_parser = " 1 = 1"
   ENDIF
   SELECT INTO "nl:"
    FROM cr_report_template crt
    WHERE ((crt.report_template_id+ 0)=(crt.template_id+ 0))
     AND parser(active_parser)
     AND expand(lidx,1,lnumoftemplates,crt.template_name_key,names->qual[lidx].name)
    HEAD REPORT
     stat = alterlist(reply->template_ids,5), counter = 0
    DETAIL
     counter += 1
     IF (mod(counter,5)=1)
      stat = alterlist(reply->template_ids,(counter+ 4))
     ENDIF
     reply->template_ids[counter].id = crt.template_id, reply->template_ids[counter].name = crt
     .template_name
    FOOT REPORT
     stat = alterlist(reply->template_ids,counter)
    WITH nocounter
   ;end select
   CALL log_message("Exiting RetrieveTemplateIds subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievesectionids(null)
   CALL log_message("Entered RetrieveSectionIds subroutine.",log_level_debug)
   CALL echo("In Sections")
   DECLARE lidx = i4
   DECLARE counter = i4
   DECLARE active_parser = vc WITH noconstant(" crs.active_ind = 1"), protect
   IF ((request->include_inactive_components=1))
    SET active_parser = " 1 = 1"
   ENDIF
   SELECT INTO "nl:"
    FROM cr_report_section crs
    WHERE ((crs.report_section_id+ 0)=(crs.section_id+ 0))
     AND parser(active_parser)
     AND expand(lidx,1,lnumofsections,crs.section_name_key,names->qual[lidx].name)
    HEAD REPORT
     stat = alterlist(reply->section_ids,5), counter = 0
    DETAIL
     counter += 1
     IF (mod(counter,5)=1)
      stat = alterlist(reply->section_ids,(counter+ 4))
     ENDIF
     reply->section_ids[counter].id = crs.section_id, reply->section_ids[counter].name = crs
     .section_name
    FOOT REPORT
     stat = alterlist(reply->section_ids,counter)
    WITH nocounter
   ;end select
   CALL echo("after select")
   CALL log_message("Exiting RetrieveSectionIds subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievepagemasterids(null)
   CALL log_message("Entered RetrievePageMasterIds subroutine.",log_level_debug)
   CALL echo("In PageMasters")
   DECLARE lidx = i4
   DECLARE counter = i4
   DECLARE active_parser = vc WITH noconstant(" crsr.active_ind = 1"), protect
   IF ((request->include_inactive_components=1))
    SET active_parser = " 1 = 1"
   ENDIF
   CALL echorecord(names)
   SELECT INTO "nl:"
    FROM cr_report_static_region crsr
    WHERE ((crsr.report_static_region_id+ 0)=(crsr.static_region_id+ 0))
     AND parser(active_parser)
     AND expand(lidx,1,lnumofpagemasters,crsr.region_name_key,names->qual[lidx].name)
    HEAD REPORT
     stat = alterlist(reply->page_master_ids,5), counter = 0
    DETAIL
     counter += 1
     IF (mod(counter,5)=1)
      stat = alterlist(reply->page_master_ids,(counter+ 4))
     ENDIF
     reply->page_master_ids[counter].id = crsr.static_region_id, reply->page_master_ids[counter].name
      = crsr.region_name
    FOOT REPORT
     stat = alterlist(reply->page_master_ids,counter)
    WITH nocounter
   ;end select
   CALL log_message("Exiting RetrievePageMasterIds subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievestyleprofileids(null)
   CALL log_message("Entered RetrieveStyleProfileIds subroutine.",log_level_debug)
   CALL echo("In StyleProfiles")
   DECLARE lidx = i4
   DECLARE counter = i4
   DECLARE active_parser = vc WITH noconstant(" crsp.active_ind = 1"), protect
   IF ((request->include_inactive_components=1))
    SET active_parser = " 1 = 1"
   ENDIF
   SELECT INTO "nl:"
    FROM cr_report_style_profile crsp
    WHERE ((crsp.report_style_profile_id+ 0)=(crsp.style_profile_id+ 0))
     AND parser(active_parser)
     AND expand(lidx,1,lnumofstyleprofiles,crsp.style_profile_name_key,names->qual[lidx].name)
    HEAD REPORT
     stat = alterlist(reply->style_profile_ids,5), counter = 0
    DETAIL
     counter += 1
     IF (mod(counter,5)=1)
      stat = alterlist(reply->style_profile_ids,(counter+ 4))
     ENDIF
     reply->style_profile_ids[counter].id = crsp.style_profile_id, reply->style_profile_ids[counter].
     name = crsp.style_profile_name
    FOOT REPORT
     stat = alterlist(reply->style_profile_ids,counter)
    WITH nocounter
   ;end select
   CALL echo("after select")
   CALL log_message("Exiting RetrieveStyleProfileIds subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievelegendids(null)
   CALL log_message("Entered RetrieveLegendIds subroutine.",log_level_debug)
   CALL echo("In Legends")
   DECLARE lidx = i4
   DECLARE counter = i4
   DECLARE active_parser = vc WITH noconstant(" crl.active_ind = 1"), protect
   IF ((request->include_inactive_components=1))
    SET active_parser = " 1 = 1"
   ENDIF
   SELECT INTO "nl:"
    FROM cr_report_legend crl
    WHERE ((crl.report_legend_id+ 0)=(crl.legend_id+ 0))
     AND parser(active_parser)
     AND expand(lidx,1,lnumoflegends,crl.legend_name_key,names->qual[lidx].name)
    HEAD REPORT
     stat = alterlist(reply->legend_ids,5), counter = 0
    DETAIL
     counter += 1
     IF (mod(counter,5)=1)
      stat = alterlist(reply->legend_ids,(counter+ 4))
     ENDIF
     reply->legend_ids[counter].id = crl.legend_id, reply->legend_ids[counter].name = crl.legend_name
    FOOT REPORT
     stat = alterlist(reply->legend_ids,counter)
    WITH nocounter
   ;end select
   CALL echo("after select")
   CALL log_message("Exiting RetrieveLegendIds subroutine.",log_level_debug)
 END ;Subroutine
 IF (size(reply->template_ids,5)=0
  AND size(reply->section_ids,5)=0
  AND size(reply->style_profile_ids,5)=0
  AND size(reply->page_master_ids,5)=0
  AND size(reply->legend_ids,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("End of script: cr_get_tmplt_cmpnt_ids",log_level_debug)
 CALL echorecord(reply)
END GO
