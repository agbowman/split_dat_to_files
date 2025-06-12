CREATE PROGRAM cr_template_maintenance:dba
 PAINT
 EXECUTE cclseclogin
 SET width = 132
 SET modify = system
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
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
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
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
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
 DECLARE error_and_zero_check(qualnum=i4,opname=vc,logname=vc,errorforceexit=i2,zeroforceexit=i2) =
 i2
 SUBROUTINE error_and_zero_check(qualnum,opname,logname,errorforceexit,zeroforceexit)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",logname,serrmsg)
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
    CALL populate_subeventstatus(opname,"Z",logname,"No records qualified")
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(reply->status_data.subeventstatus[
      lcrslsubeventcnt].operationstatus)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(reply->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectname)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(reply->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectvalue)))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt = (lcrslsubeventcnt+ 1)
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
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#initialize
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE h = i4 WITH noconstant(0)
 DECLARE tempstr = vc WITH noconstant("")
 DECLARE templatelongtext = vc WITH noconstant("")
 DECLARE sectionlongtext = vc WITH noconstant("")
 DECLARE selectedsection = c32 WITH noconstant("")
 DECLARE selectedregion = c32 WITH noconstant("")
 DECLARE sectionid = f8 WITH noconstant(0.0)
 DECLARE regionid = f8 WITH noconstant(0.0)
 DECLARE xml_request = vc WITH noconstant("<?xml version='1.0' encoding='UTF-8' standalone='yes'?>")
 DECLARE num_sections = i4 WITH noconstant(1)
 DECLARE showing = c5 WITH noconstant("")
 DECLARE sequence = i4 WITH noconstant(0)
 DECLARE literal = vc WITH noconstant("")
 DECLARE lsectscnt = i4 WITH noconstant(0)
 DECLARE leventsetcnt = i4 WITH noconstant(0)
 DECLARE populatetemplatelongtext(templatename=c32) = null
 DECLARE populatesectionlongtext(sectionname=c32) = null
 DECLARE extractxmlvalue(lookup=vc,searchtext=vc,isparam=12) = null
 DECLARE newtemplate(null) = null
 DECLARE modifytemplate(null) = null
 DECLARE modifysection(null) = null
 DECLARE modifyimmunizationsection(newind=i2) = null
 DECLARE modifygenlabsection(newind=i2) = null
 DECLARE modifyclaimvisitsection(newind=i2) = null
 DECLARE modifymedsprofilesection(newind=i2) = null
 DECLARE newsection(null) = null
 DECLARE newpagemaster(null) = null
 DECLARE modifypagemaster(null) = null
 DECLARE associatesectiontotemplate(null) = null
 DECLARE mainapp(null) = null
 DECLARE populatetemptables(null) = null
 DECLARE saveimmunizationsection(null) = null
 DECLARE savegenlabsection(eventsetcnt=i4) = null
 DECLARE saveclaimvisitsection(null) = null
 DECLARE savemedsprofilesection(null) = null
 DECLARE savepagemaster(sectioncnt=i4) = null
 DECLARE savetemplate(null) = null
 DECLARE savestaticregion(null) = null
 DECLARE freerecordstructs(null) = null
 FREE RECORD report_template
 RECORD report_template(
   1 template_name = c32
   1 template_id = f8
   1 template[1]
     2 sections[*]
       3 section_name = c32
       3 section_id = f8
       3 sequence_nbr = i4
     2 static_regions[1]
       3 region_name = c32
       3 static_region_id = f8
 )
 FREE RECORD immunization_section
 RECORD immunization_section(
   1 immunization[1]
     2 content_type = c50
     2 label = c32
     2 name = c32
     2 section_id = f8
     2 updt_cnt = i4
     2 param_lot_num[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_expiration_time[1]
       3 showing = c5
     2 param_admin_person[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_manufacturer[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_expiration_date[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_amount[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_time_format[1]
       3 literal = c50
     2 param_result_seq[1]
       3 showing = c5
       3 literal = c50
     2 param_site[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_date_format[1]
       3 literal = c50
     2 param_vaccine[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_provider[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_date_given[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_time_given[1]
       3 showing = c5
     2 param_admin_note[1]
       3 showing = c5
       3 literal = c50
     2 param_age[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
 )
 FREE RECORD genlab_section
 RECORD genlab_section(
   1 genlab[1]
     2 content_type = c50
     2 label = c32
     2 name = c32
     2 section_id = f8
     2 updt_cnt = i4
     2 param_procedure[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_result[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_units[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_ref_range[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_date[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_time[1]
       3 showing = c5
     2 param_accession_nbr[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_body_site[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_collected_dt[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_collected_dt_tm[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_department_status[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_order_dt[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_order_dt_tm[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_orderable_name[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_specimen_type[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_ordering_provider[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_result_seq[1]
       3 showing = c5
       3 literal = c50
     2 param_event_set[*]
       3 label = c32
       3 name = c50
       3 code = f8
 )
 FREE RECORD claimvisit_section
 RECORD claimvisit_section(
   1 claimvisit[1]
     2 content_type = c50
     2 label = c32
     2 name = c32
     2 section_id = f8
     2 updt_cnt = i4
     2 param_service_dt_tm[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_visit_type[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_facility[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_billing_provider[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_procedure[1]
       3 showing = c5
       3 literal = c50
     2 param_diagnosis[1]
       3 showing = c5
       3 literal = c50
     2 param_result_seq[1]
       3 literal = c50
 )
 FREE RECORD medsprofile_section
 RECORD medsprofile_section(
   1 medsprofile[1]
     2 content_type = c50
     2 label = c32
     2 name = c32
     2 section_id = f8
     2 updt_cnt = i4
     2 param_ordered_as_mnemonic[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_clinical_display_line[1]
       3 showing = c5
       3 sequence = i4
       3 literal = c50
     2 param_result_seq[1]
       3 literal = c50
     2 param_primary_sort[1]
       3 literal = c50
     2 param_primary_sort_direction[1]
       3 literal = c50
     2 param_secondary_sort[1]
       3 literal = c50
     2 param_secondary_sort_direction[1]
       3 literal = c50
 )
 FREE RECORD section_types
 RECORD section_types(
   1 sections[4]
     2 section = c50
 )
 DECLARE new_template = i4 WITH constant(1)
 DECLARE modify_template = i4 WITH constant(2)
 DECLARE new_section = i4 WITH constant(3)
 DECLARE modify_section = i4 WITH constant(4)
 DECLARE new_page_master = i4 WITH constant(5)
 DECLARE modify_page_master = i4 WITH constant(6)
 DECLARE associate_sect_to_temp = i4 WITH constant(7)
 DECLARE quit = i4 WITH constant(99)
 DECLARE immun_sect = c12 WITH constant("immunization")
 DECLARE genlab_sect = c18 WITH constant("general-laboratory")
 DECLARE claimvisit_sect = c10 WITH constant("claimvisit")
 DECLARE medsprofile_sect = c17 WITH constant("medication-claims")
 DECLARE content_type = c12 WITH constant("content-type")
 DECLARE finished = c8 WITH constant("FINISHED")
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog," ",curcclrev)
 CALL populatetemptables(null)
 WHILE (1=1)
   CALL mainapp(null)
 ENDWHILE
 SUBROUTINE mainapp(null)
   CALL clear(1,1)
   CALL box(2,1,14,79)
   CALL text(1,25,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Template Maintenance")
    )
   CALL text(4,2,uar_i18nbuildmessage(i18nhandle,"MAINMODTMP","0%1 New template.","i",new_template))
   CALL text(5,2,uar_i18nbuildmessage(i18nhandle,"MAINMODTMP","0%1 Modify template.","i",
     modify_template))
   CALL text(6,2,uar_i18nbuildmessage(i18nhandle,"MAINNEWSECT","0%1 New section.","i",new_section))
   CALL text(7,2,uar_i18nbuildmessage(i18nhandle,"MAINMODSECT","0%1 Modify section.","i",
     modify_section))
   CALL text(8,2,uar_i18nbuildmessage(i18nhandle,"MAINMODPGMSTR","0%1 New page master.","i",
     new_page_master))
   CALL text(9,2,uar_i18nbuildmessage(i18nhandle,"MAINMODPGMSTR","0%1 Modify page master.","i",
     modify_page_master))
   CALL text(10,2,uar_i18nbuildmessage(i18nhandle,"MAINASSOCSECTOTEMP",
     "0%1 Associate sections and page masters to template.","i",associate_sect_to_temp))
   CALL text(11,2,uar_i18nbuildmessage(i18nhandle,"MAINCONQT","%1 Exit.","i",quit))
   CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT","Select Option?"))
   CALL accept(12,24,"99;",99
    WHERE curaccept IN (new_template, modify_template, modify_section, new_section, new_page_master,
    modify_page_master, associate_sect_to_temp, quit))
   CASE (curaccept)
    OF new_template:
     CALL newtemplate(null)
    OF modify_template:
     CALL modifytemplate(null)
    OF new_section:
     CALL newsection(null)
    OF modify_section:
     CALL modifysection(null)
    OF new_page_master:
     CALL newpagemaster(null)
    OF modify_page_master:
     CALL modifypagemaster(null)
    OF associate_sect_to_temp:
     CALL associatesectiontotemplate(null)
    OF quit:
     GO TO end_program
   ENDCASE
 END ;Subroutine
 SUBROUTINE newtemplate(null)
   CALL clear(1,1)
   CALL text(1,25,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Template Maintenance")
    )
   CALL text(3,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Enter the template name: "))
   CALL accept(4,2,"P(32);C")
   SET report_template->template_name = trim(curaccept)
   CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Enter the template xml: "))
   DECLARE whilenum = i2 WITH noconstant(1)
   WHILE (whilenum=1)
     CALL clear(8,1)
     CALL accept(8,2,"P(80);C")
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(9,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(10,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(11,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(12,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(13,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(14,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(15,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(16,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(17,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(18,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(19,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(20,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
       "Main Menu(1), Continue(2) or Quit(3)? "))
     CALL accept(22,40,"9;",2
      WHERE curaccept IN (1, 2, 3))
     IF (curaccept=3)
      GO TO end_program
     ELSEIF (curaccept=2)
      SET do_nothing = 0
     ELSE
      CALL savetemplate(null)
      SET whilenum = 0
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE modifytemplate(null)
   CALL clear(1,1)
   CALL text(1,25,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Template Maintenance")
    )
   CALL text(3,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Select a template: "))
   CALL text(4,2,"Shift/F5 to see a list of templates")
   SET help =
   SELECT DISTINCT INTO "nl:"
    crt.template_name
    FROM cr_report_template crt
    WHERE crt.template_id > 0
     AND crt.active_ind=1
     AND crt.report_template_id=crt.template_id
    ORDER BY crt.template_name
    WITH nocounter
   ;end select
   CALL accept(5,2,"P(32);C")
   SET help = off
   SET report_template->template_name = trim(curaccept)
   CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Enter the template xml: "))
   DECLARE whilenum = i2 WITH noconstant(1)
   WHILE (whilenum=1)
     CALL clear(8,1)
     CALL accept(8,2,"P(80);C")
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(9,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(10,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(11,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(12,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(13,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(14,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(15,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(16,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(17,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(18,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(19,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(20,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
       "Main Menu(1), Continue(2) or Quit(3)? "))
     CALL accept(22,40,"9;",2
      WHERE curaccept IN (1, 2, 3))
     IF (curaccept=3)
      GO TO end_program
     ELSEIF (curaccept=2)
      SET do_nothing = 0
     ELSE
      CALL savetemplate(null)
      SET whilenum = 0
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE newpagemaster(null)
   CALL clear(1,1)
   CALL text(1,25,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Template Maintenance")
    )
   CALL text(3,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Enter a page master name: "))
   CALL accept(4,2,"P(32);C")
   SET selectedregion = trim(curaccept)
   CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Enter the page master xml: "))
   DECLARE whilenum = i2 WITH noconstant(1)
   WHILE (whilenum=1)
     CALL clear(8,1)
     CALL accept(8,2,"P(80);C")
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(9,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(10,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(11,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(12,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(13,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(14,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(15,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(16,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(17,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(18,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(19,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(20,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
       "Main Menu(1), Continue(2) or Quit(3)? "))
     CALL accept(22,40,"9;",2
      WHERE curaccept IN (1, 2, 3))
     IF (curaccept=3)
      GO TO end_program
     ELSEIF (curaccept=2)
      SET do_nothing = 0
     ELSE
      CALL savestaticregion(null)
      SET whilenum = 0
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE modifypagemaster(null)
   CALL clear(1,1)
   CALL text(1,25,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Template Maintenance")
    )
   CALL text(3,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Select a page master: "))
   CALL text(4,2,"Shift/F5 to see a list of page masters")
   SET help =
   SELECT DISTINCT INTO "nl:"
    crs.region_name
    FROM cr_report_static_region crs
    WHERE crs.static_region_id > 0
     AND crs.active_ind=1
     AND crs.report_static_region_id=crs.static_region_id
    ORDER BY crs.region_name
    WITH nocounter
   ;end select
   CALL accept(5,2,"P(32);C")
   SET help = off
   SET selectedregion = trim(curaccept)
   CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Enter the page master xml: "))
   DECLARE whilenum = i2 WITH noconstant(1)
   WHILE (whilenum=1)
     CALL clear(8,1)
     CALL accept(8,2,"P(80);C")
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(9,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(10,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(11,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(12,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(13,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(14,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(15,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(16,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(17,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(18,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(19,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL accept(20,2,"P(80);C",finished)
     IF (curaccept != finished)
      SET xml_request = concat(xml_request,trim(curaccept))
     ENDIF
     CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
       "Main Menu(1), Continue(2) or Quit(3)? "))
     CALL accept(22,40,"9;",2
      WHERE curaccept IN (1, 2, 3))
     IF (curaccept=3)
      GO TO end_program
     ELSEIF (curaccept=2)
      SET do_nothing = 0
     ELSE
      CALL savestaticregion(null)
      SET whilenum = 0
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE newsection(null)
   CALL clear(1,1)
   CALL box(2,1,20,79)
   CALL text(1,25,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Template Maintenance")
    )
   CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Select a section type: "))
   CALL text(5,2,"Shift/F5 to see a list of section types")
   SET help =
   SELECT DISTINCT INTO "nl:"
    section_types->sections[d.seq].section
    FROM (dummyt d  WITH seq = 4)
    PLAN (d)
    ORDER BY section_types->sections[d.seq].section
    WITH nocounter
   ;end select
   CALL accept(6,2,"P(50);C")
   SET help = off
   IF (curaccept=immun_sect)
    CALL modifyimmunizationsection(1)
   ELSEIF (curaccept=genlab_sect)
    CALL modifygenlabsection(1)
   ELSEIF (curaccept=claimvisit_sect)
    CALL modifyclaimvisitsection(1)
   ELSEIF (curaccept=medsprofile_sect)
    CALL modifymedsprofilesection(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE modifysection(null)
   CALL clear(1,1)
   CALL box(2,1,20,79)
   CALL text(1,25,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Template Maintenance")
    )
   CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Select a section: "))
   CALL text(5,2,"Shift/F5 to see a list of sections")
   SET help =
   SELECT DISTINCT INTO "nl:"
    crs.section_name
    FROM cr_report_section crs
    WHERE crs.section_id > 0
     AND crs.active_ind=1
     AND crs.report_section_id=crs.section_id
    ORDER BY crs.section_name
    WITH nocounter
   ;end select
   CALL accept(6,2,"P(32);C")
   SET help = off
   SET selectedsection = curaccept
   CALL populatesectionlongtext(selectedsection)
   CALL extractxmlvalue(content_type,sectionlongtext,0)
   IF (tempstr=immun_sect)
    CALL modifyimmunizationsection(0)
   ELSEIF (tempstr=genlab_sect)
    CALL modifygenlabsection(0)
   ELSEIF (tempstr=claimvisit_sect)
    CALL modifyclaimvisitsection(0)
   ELSEIF (tempstr=medsprofile_sect)
    CALL modifymedsprofilesection(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE modifyimmunizationsection(newind)
   SET immunization_section->immunization[1].content_type = immun_sect
   CALL clear(1,1)
   CALL text(1,20,uar_i18ngetmessage(i18nhandle,"MAINHEADIMMUN",
     "Clinical Reporting Template Maintenance - Immunization"))
   IF (newind=0)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section name: "))
    CALL extractxmlvalue("name",sectionlongtext,0)
    CALL accept(5,2,"P(50);C",tempstr)
    SET immunization_section->immunization[1].name = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section label: "))
    CALL extractxmlvalue("label",sectionlongtext,0)
    CALL accept(8,2,"P(50);C",tempstr)
    SET immunization_section->immunization[1].label = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter vaccine label: "))
    CALL extractxmlvalue("'vaccine'",sectionlongtext,1)
    CALL accept(11,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_vaccine[1].literal = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(12,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_vaccine[1].showing = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(13,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_vaccine[1].sequence = curaccept
    CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter provider label: "))
    CALL extractxmlvalue("'provider'",sectionlongtext,1)
    CALL accept(16,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_provider[1].literal = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(17,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_provider[1].showing = curaccept
    CALL text(18,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(18,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_provider[1].sequence = curaccept
    CALL text(20,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter date given label: "))
    CALL extractxmlvalue("'date-given'",sectionlongtext,1)
    CALL accept(21,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_date_given[1].literal = curaccept
    CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(22,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_date_given[1].showing = curaccept
    CALL text(23,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(23,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_date_given[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter showing (true or false) for Time Given: "))
    CALL extractxmlvalue("'time-given'",sectionlongtext,1)
    CALL accept(6,55,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_time_given[1].showing = curaccept
    CALL text(8,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter age label: "))
    CALL extractxmlvalue("'age'",sectionlongtext,1)
    CALL accept(9,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_age[1].literal = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(10,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_age[1].showing = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(11,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_age[1].sequence = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter admin person label: "))
    CALL extractxmlvalue("'admin-person'",sectionlongtext,1)
    CALL accept(14,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_admin_person[1].literal = curaccept
    CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(15,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_admin_person[1].showing = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(16,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_admin_person[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter amount label: "))
    CALL extractxmlvalue("'amount'",sectionlongtext,1)
    CALL accept(5,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_amount[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_amount[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(7,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_amount[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter site label: "))
    CALL extractxmlvalue("'site'",sectionlongtext,1)
    CALL accept(10,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_site[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_site[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(12,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_site[1].sequence = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter lot number label: "))
    CALL extractxmlvalue("'lot-num'",sectionlongtext,1)
    CALL accept(15,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_lot_num[1].literal = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(16,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_lot_num[1].showing = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(17,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_lot_num[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter manufacturer label: "))
    CALL extractxmlvalue("'manufacturer'",sectionlongtext,1)
    CALL accept(5,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_manufacturer[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_manufacturer[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(7,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_manufacturer[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter expiration date label: "))
    CALL extractxmlvalue("'expiration-date'",sectionlongtext,1)
    CALL accept(10,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_expiration_date[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_expiration_date[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(12,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_expiration_date[1].sequence = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter showing (true or false) for Expiration Time: "))
    CALL extractxmlvalue("'expiration-time'",sectionlongtext,1)
    CALL accept(16,55,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_expiration_time[1].showing = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter admin note label: "))
    CALL extractxmlvalue("'admin-note'",sectionlongtext,1)
    CALL accept(5,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_admin_note[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Show admin note? (true or false) "))
    CALL accept(6,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_admin_note[1].showing = curaccept
    CALL text(8,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter date format: "))
    CALL extractxmlvalue("'date-format'",sectionlongtext,1)
    CALL accept(9,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_date_format[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter time format: "))
    CALL extractxmlvalue("'time-format'",sectionlongtext,1)
    CALL accept(12,2,"P(50);C",literal)
    SET immunization_section->immunization[1].param_time_format[1].literal = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter result sequence (ascending or descending): "))
    CALL extractxmlvalue("'result-seq'",sectionlongtext,1)
    CALL accept(15,2,"P(50);C",literal
     WHERE curaccept IN ("ascending", "descending"))
    SET immunization_section->immunization[1].param_result_seq[1].literal = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
      "Save and return to Main Menu(1) or Quit(2)? "))
    CALL accept(17,50,"9;",1
     WHERE curaccept IN (1, 2))
    IF (curaccept=2)
     GO TO end_program
    ELSEIF (curaccept=1)
     CALL saveimmunizationsection(null)
    ENDIF
   ELSE
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section name: "))
    CALL accept(5,2,"P(50);C")
    SET immunization_section->immunization[1].name = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section label: "))
    CALL accept(8,2,"P(50);C")
    SET immunization_section->immunization[1].label = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter vaccine label: "))
    CALL accept(11,2,"P(50);C","Vaccine")
    SET immunization_section->immunization[1].param_vaccine[1].literal = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(12,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_vaccine[1].showing = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(13,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_vaccine[1].sequence = curaccept
    CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter provider label: "))
    CALL accept(16,2,"P(50);C","Provider")
    SET immunization_section->immunization[1].param_provider[1].literal = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(17,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_provider[1].showing = curaccept
    CALL text(18,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(18,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_provider[1].sequence = curaccept
    CALL text(20,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter date given label: "))
    CALL accept(21,2,"P(50);C","Date Given")
    SET immunization_section->immunization[1].param_date_given[1].literal = curaccept
    CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(22,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_date_given[1].showing = curaccept
    CALL text(23,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(23,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_date_given[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter showing (true or false) for Time Given: "))
    CALL accept(6,55,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_time_given[1].showing = curaccept
    CALL text(8,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter age label: "))
    CALL accept(9,2,"P(50);C","Age")
    SET immunization_section->immunization[1].param_age[1].literal = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(10,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_age[1].showing = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(11,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_age[1].sequence = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter admin person label: "))
    CALL accept(14,2,"P(50);C","Admin Person")
    SET immunization_section->immunization[1].param_admin_person[1].literal = curaccept
    CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(15,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_admin_person[1].showing = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(16,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_admin_person[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter amount label: "))
    CALL accept(5,2,"P(50);C","Amount")
    SET immunization_section->immunization[1].param_amount[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_amount[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(7,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_amount[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter site label: "))
    CALL accept(10,2,"P(50);C","Site")
    SET immunization_section->immunization[1].param_site[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_site[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(12,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_site[1].sequence = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter lot number label: "))
    CALL accept(15,2,"P(50);C","Lot Number")
    SET immunization_section->immunization[1].param_lot_num[1].literal = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(16,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_lot_num[1].showing = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(17,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_lot_num[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter manufacturer label: "))
    CALL accept(5,2,"P(50);C","Manufacturer")
    SET immunization_section->immunization[1].param_manufacturer[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_manufacturer[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(7,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_manufacturer[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter expiration date label: "))
    CALL accept(10,2,"P(50);C","Expiration Date")
    SET immunization_section->immunization[1].param_expiration_date[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_expiration_date[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-10): "))
    CALL accept(12,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10))
    SET immunization_section->immunization[1].param_expiration_date[1].sequence = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter showing (true or false) for Expiration Time: "))
    CALL accept(16,55,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_expiration_time[1].showing = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter admin note label: "))
    CALL accept(5,2,"P(50);C","Admin Note")
    SET immunization_section->immunization[1].param_admin_note[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Show admin note? (true or false) "))
    CALL accept(6,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET immunization_section->immunization[1].param_admin_note[1].showing = curaccept
    CALL text(8,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter date format: "))
    CALL accept(9,2,"P(50);C","mm-dd-yyyy")
    SET immunization_section->immunization[1].param_date_format[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter time format: "))
    CALL accept(12,2,"P(50);C","hh:mm:ss")
    SET immunization_section->immunization[1].param_time_format[1].literal = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter result sequence (ascending or descending): "))
    CALL accept(15,2,"P(50);C","ascending"
     WHERE curaccept IN ("ascending", "descending"))
    SET immunization_section->immunization[1].param_result_seq[1].literal = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
      "Save and return to Main Menu(1) or Quit(2)? "))
    CALL accept(17,50,"9;",1
     WHERE curaccept IN (1, 2))
    IF (curaccept=2)
     GO TO end_program
    ELSEIF (curaccept=1)
     CALL saveimmunizationsection(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE modifygenlabsection(newind)
   SET genlab_section->genlab[1].content_type = genlab_sect
   DECLARE eventsetcnt = i4 WITH noconstant(1)
   SET stat = alterlist(genlab_section->genlab[1].param_event_set,eventsetcnt)
   CALL clear(1,1)
   CALL text(1,20,uar_i18ngetmessage(i18nhandle,"MAINHEADIMMUN",
     "Clinical Reporting Template Maintenance - Gen Lab List"))
   IF (newind=0)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section name: "))
    CALL extractxmlvalue("name",sectionlongtext,0)
    CALL accept(5,2,"P(50);C",tempstr)
    SET genlab_section->genlab[1].name = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section label: "))
    CALL extractxmlvalue("label",sectionlongtext,0)
    CALL accept(8,2,"P(50);C",tempstr)
    SET genlab_section->genlab[1].label = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter procedure label: "))
    CALL extractxmlvalue("'procedure'",sectionlongtext,1)
    CALL accept(11,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_procedure[1].literal = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(12,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_procedure[1].showing = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(13,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_procedure[1].sequence = curaccept
    CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter result label: "))
    CALL extractxmlvalue("'result'",sectionlongtext,1)
    CALL accept(16,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_result[1].literal = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(17,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_result[1].showing = curaccept
    CALL text(18,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(18,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_result[1].sequence = curaccept
    CALL text(20,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter units label: "))
    CALL extractxmlvalue("'units'",sectionlongtext,1)
    CALL accept(21,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_units[1].literal = curaccept
    CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(22,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_units[1].showing = curaccept
    CALL text(23,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(23,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_units[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter ref range label: "))
    CALL extractxmlvalue("'ref-range'",sectionlongtext,1)
    CALL accept(5,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_ref_range[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_ref_range[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(7,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_ref_range[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter date label: "))
    CALL extractxmlvalue("'date'",sectionlongtext,1)
    CALL accept(10,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_date[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_date[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(12,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_date[1].sequence = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter showing (true or false) for Time: "))
    CALL extractxmlvalue("'time'",sectionlongtext,1)
    CALL accept(14,55,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_time[1].showing = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter accession nbr label: "))
    CALL extractxmlvalue("'accession-nbr'",sectionlongtext,1)
    CALL accept(5,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_accession_nbr[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_accession_nbr[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(7,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_accession_nbr[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter body site label: "))
    CALL extractxmlvalue("'body-site'",sectionlongtext,1)
    CALL accept(10,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_body_site[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_body_site[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(12,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_body_site[1].sequence = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter collected date label: "))
    CALL extractxmlvalue("'collected-dt'",sectionlongtext,1)
    CALL accept(15,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_collected_dt[1].literal = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(16,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_collected_dt[1].showing = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(17,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_collected_dt[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter collected date time label: "))
    CALL extractxmlvalue("'collected-dt-tm'",sectionlongtext,1)
    CALL accept(5,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_collected_dt_tm[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_collected_dt_tm[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(7,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_collected_dt_tm[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter department status label: "))
    CALL extractxmlvalue("'department-status'",sectionlongtext,1)
    CALL accept(10,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_department_status[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_department_status[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(12,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_department_status[1].sequence = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter order date label: "))
    CALL extractxmlvalue("'order-dt'",sectionlongtext,1)
    CALL accept(15,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_order_dt[1].literal = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(16,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_order_dt[1].showing = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(17,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_order_dt[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter order date time label: "))
    CALL extractxmlvalue("'order-dt-tm'",sectionlongtext,1)
    CALL accept(5,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_order_dt_tm[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_order_dt_tm[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(7,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_order_dt_tm[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter orderable name label: "))
    CALL extractxmlvalue("'orderable-name'",sectionlongtext,1)
    CALL accept(10,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_orderable_name[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_orderable_name[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(12,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_orderable_name[1].sequence = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter specimen type label: "))
    CALL extractxmlvalue("'specimen-type'",sectionlongtext,1)
    CALL accept(15,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_specimen_type[1].literal = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(16,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_specimen_type[1].showing = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(17,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_specimen_type[1].sequence = curaccept
    CALL text(19,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter ordering provider label: "))
    CALL extractxmlvalue("'ordering-provider'",sectionlongtext,1)
    CALL accept(20,2,"P(50);C",literal)
    SET genlab_section->genlab[1].param_ordering_provider[1].literal = curaccept
    CALL text(21,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(21,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_ordering_provider[1].showing = curaccept
    CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(22,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_ordering_provider[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter result sequence (ascending or descending): "))
    CALL extractxmlvalue("'result-seq'",sectionlongtext,1)
    CALL accept(5,2,"P(50);C",literal
     WHERE curaccept IN ("ascending", "descending"))
    SET genlab_section->genlab[1].param_result_seq[1].literal = curaccept
    DECLARE whilenum = i2 WITH noconstant(1)
    WHILE (whilenum=1)
      CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter group label: "))
      CALL accept(8,2,"P(32);C")
      SET genlab_section->genlab[1].param_event_set[eventsetcnt].label = curaccept
      CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter event set: "))
      CALL accept(11,2,"P(80);C")
      SET genlab_section->genlab[1].param_event_set[eventsetcnt].name = curaccept
      CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter event set code: "))
      CALL accept(13,25,"99999999;")
      SET genlab_section->genlab[1].param_event_set[eventsetcnt].code = curaccept
      CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
        "Main Menu(1), Continue(2) or Quit(3)? "))
      CALL accept(15,40,"9;",2
       WHERE curaccept IN (1, 2, 3))
      IF (curaccept=3)
       GO TO end_program
      ELSEIF (curaccept=2)
       SET eventsetcnt = (eventsetcnt+ 1)
       SET stat = alterlist(genlab_section->genlab[1].param_event_set,eventsetcnt)
      ELSE
       CALL savegenlabsection(eventsetcnt)
       SET whilenum = 0
      ENDIF
    ENDWHILE
   ELSE
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section name: "))
    CALL accept(5,2,"P(50);C")
    SET genlab_section->genlab[1].name = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section label: "))
    CALL accept(8,2,"P(50);C")
    SET genlab_section->genlab[1].label = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter procedure label: "))
    CALL accept(11,2,"P(50);C","Procedure")
    SET genlab_section->genlab[1].param_procedure[1].literal = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(12,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_procedure[1].showing = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(13,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_procedure[1].sequence = curaccept
    CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter result label: "))
    CALL accept(16,2,"P(50);C","Result")
    SET genlab_section->genlab[1].param_result[1].literal = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(17,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_result[1].showing = curaccept
    CALL text(18,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(18,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_result[1].sequence = curaccept
    CALL text(20,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter units label: "))
    CALL accept(21,2,"P(50);C","Units")
    SET genlab_section->genlab[1].param_units[1].literal = curaccept
    CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(22,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_units[1].showing = curaccept
    CALL text(23,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(23,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_units[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter ref range label: "))
    CALL accept(5,2,"P(50);C","Ref Range")
    SET genlab_section->genlab[1].param_ref_range[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_ref_range[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(7,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_ref_range[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter date label: "))
    CALL accept(10,2,"P(50);C","Date")
    SET genlab_section->genlab[1].param_date[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_date[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(12,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_date[1].sequence = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter showing (true or false) for Time: "))
    CALL accept(14,55,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_time[1].showing = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter accession nbr label: "))
    CALL accept(5,2,"P(50);C","Accession Nbr")
    SET genlab_section->genlab[1].param_accession_nbr[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_accession_nbr[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(7,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_accession_nbr[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter body site label: "))
    CALL accept(10,2,"P(50);C","Body Site")
    SET genlab_section->genlab[1].param_body_site[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_body_site[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(12,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_body_site[1].sequence = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter collected date label: "))
    CALL accept(15,2,"P(50);C","Collected Date")
    SET genlab_section->genlab[1].param_collected_dt[1].literal = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(16,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_collected_dt[1].showing = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(17,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_collected_dt[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter collected date time label: "))
    CALL accept(5,2,"P(50);C","Collected Date Time")
    SET genlab_section->genlab[1].param_collected_dt_tm[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_collected_dt_tm[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(7,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_collected_dt_tm[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter department status label: "))
    CALL accept(10,2,"P(50);C","Department Status")
    SET genlab_section->genlab[1].param_department_status[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_department_status[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(12,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_department_status[1].sequence = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter order date label: "))
    CALL accept(15,2,"P(50);C","Order Date")
    SET genlab_section->genlab[1].param_order_dt[1].literal = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(16,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_order_dt[1].showing = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(17,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_order_dt[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter order date time label: "))
    CALL accept(5,2,"P(50);C","Order Date Time")
    SET genlab_section->genlab[1].param_order_dt_tm[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_order_dt_tm[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(7,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_order_dt_tm[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter orderable name label: "))
    CALL accept(10,2,"P(50);C","Orderable Name")
    SET genlab_section->genlab[1].param_orderable_name[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_orderable_name[1].showing = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(12,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_orderable_name[1].sequence = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter specimen type label: "))
    CALL accept(15,2,"P(50);C","Specimen Type")
    SET genlab_section->genlab[1].param_specimen_type[1].literal = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(16,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_specimen_type[1].showing = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(17,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15))
    SET genlab_section->genlab[1].param_specimen_type[1].sequence = curaccept
    CALL text(19,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter ordering provider label: "))
    CALL accept(20,2,"P(50);C","Ordering Provider")
    SET genlab_section->genlab[1].param_ordering_provider[1].literal = curaccept
    CALL text(21,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(21,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET genlab_section->genlab[1].param_ordering_provider[1].showing = curaccept
    CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-15): "))
    CALL accept(22,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4, 5,
     6, 7, 8, 9, 10,
     11, 12, 13, 14, 15,
     15))
    SET genlab_section->genlab[1].param_ordering_provider[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter result sequence (ascending or descending): "))
    CALL accept(5,2,"P(50);C","ascending"
     WHERE curaccept IN ("ascending", "descending"))
    SET genlab_section->genlab[1].param_result_seq[1].literal = curaccept
    DECLARE whilenum = i2 WITH noconstant(1)
    WHILE (whilenum=1)
      CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter group name: "))
      CALL accept(8,2,"P(32);C")
      SET genlab_section->genlab[1].param_event_set[eventsetcnt].label = curaccept
      CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter event set: "))
      CALL accept(11,2,"P(80);C")
      SET genlab_section->genlab[1].param_event_set[eventsetcnt].name = curaccept
      CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter event set code: "))
      CALL accept(13,25,"99999999;")
      SET genlab_section->genlab[1].param_event_set[eventsetcnt].code = curaccept
      CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
        "Main Menu(1), Continue(2) or Quit(3)? "))
      CALL accept(15,40,"9;",2
       WHERE curaccept IN (1, 2, 3))
      IF (curaccept=3)
       GO TO end_program
      ELSEIF (curaccept=2)
       SET eventsetcnt = (eventsetcnt+ 1)
       SET stat = alterlist(genlab_section->genlab[1].param_event_set,eventsetcnt)
      ELSE
       CALL savegenlabsection(eventsetcnt)
       SET whilenum = 0
      ENDIF
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE modifyclaimvisitsection(newind)
   SET claimvisit_section->claimvisit[1].content_type = genlab_sect
   CALL clear(1,1)
   CALL text(1,20,uar_i18ngetmessage(i18nhandle,"MAINHEADIMMUN",
     "Clinical Reporting Template Maintenance - Claim Visit List"))
   IF (newind=0)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section name: "))
    CALL extractxmlvalue("name",sectionlongtext,0)
    CALL accept(5,2,"P(50);C",tempstr)
    SET claimvisit_section->claimvisit[1].name = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section label: "))
    CALL extractxmlvalue("label",sectionlongtext,0)
    CALL accept(8,2,"P(50);C",tempstr)
    SET claimvisit_section->claimvisit[1].label = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter service date time label: "))
    CALL extractxmlvalue("'service-dt-tm'",sectionlongtext,1)
    CALL accept(11,2,"P(50);C",literal)
    SET claimvisit_section->claimvisit[1].param_service_dt_tm[1].literal = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(12,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_service_dt_tm[1].showing = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-4): "))
    CALL accept(13,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4))
    SET claimvisit_section->claimvisit[1].param_service_dt_tm[1].sequence = curaccept
    CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter visit type label: "))
    CALL extractxmlvalue("'visit-type'",sectionlongtext,1)
    CALL accept(16,2,"P(50);C",literal)
    SET claimvisit_section->claimvisit[1].param_visit_type[1].literal = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(17,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_visit_type[1].showing = curaccept
    CALL text(18,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-4): "))
    CALL accept(18,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4))
    SET claimvisit_section->claimvisit[1].param_visit_type[1].sequence = curaccept
    CALL text(20,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter facility label: "))
    CALL extractxmlvalue("'facility'",sectionlongtext,1)
    CALL accept(21,2,"P(50);C",literal)
    SET claimvisit_section->claimvisit[1].param_facility[1].literal = curaccept
    CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(22,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_facility[1].showing = curaccept
    CALL text(23,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-4): "))
    CALL accept(23,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4))
    SET claimvisit_section->claimvisit[1].param_facility[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter billing provider label: "))
    CALL extractxmlvalue("'billing-provider'",sectionlongtext,1)
    CALL accept(5,2,"P(50);C",literal)
    SET claimvisit_section->claimvisit[1].param_billing_provider[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_billing_provider[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-4): "))
    CALL accept(7,40,"99;",sequence
     WHERE curaccept IN (1, 2, 3, 4))
    SET claimvisit_section->claimvisit[1].param_billing_provider[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter diagnosis label: "))
    CALL extractxmlvalue("'diagnosis'",sectionlongtext,1)
    CALL accept(10,2,"P(50);C",literal)
    SET claimvisit_section->claimvisit[1].param_diagnosis[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_diagnosis[1].showing = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter procedure type label: "))
    CALL extractxmlvalue("'procedure'",sectionlongtext,1)
    CALL accept(14,2,"P(50);C",literal)
    SET claimvisit_section->claimvisit[1].param_procedure[1].literal = curaccept
    CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(15,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_procedure[1].showing = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter result sequence (ascending or descending): "))
    CALL extractxmlvalue("'result-seq'",sectionlongtext,1)
    CALL accept(18,2,"P(50);C",literal
     WHERE curaccept IN ("ascending", "descending"))
    SET claimvisit_section->claimvisit[1].param_result_seq[1].literal = curaccept
    CALL text(20,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
      "Save and return to Main Menu(1) or Quit(2)? "))
    CALL accept(20,50,"9;",1
     WHERE curaccept IN (1, 2))
    IF (curaccept=2)
     GO TO end_program
    ELSEIF (curaccept=1)
     CALL saveclaimvisitsection(null)
    ENDIF
   ELSE
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section name: "))
    CALL accept(5,2,"P(50);C")
    SET claimvisit_section->claimvisit[1].name = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section label: "))
    CALL accept(8,2,"P(50);C")
    SET claimvisit_section->claimvisit[1].label = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter service date time label: "))
    CALL accept(11,2,"P(50);C","Service Date Time")
    SET claimvisit_section->claimvisit[1].param_service_dt_tm[1].literal = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(12,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_service_dt_tm[1].showing = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-4): "))
    CALL accept(13,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4))
    SET claimvisit_section->claimvisit[1].param_service_dt_tm[1].sequence = curaccept
    CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter visit type label: "))
    CALL accept(16,2,"P(50);C","Visit Type")
    SET claimvisit_section->claimvisit[1].param_visit_type[1].literal = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(17,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_visit_type[1].showing = curaccept
    CALL text(18,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-4): "))
    CALL accept(18,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4))
    SET claimvisit_section->claimvisit[1].param_visit_type[1].sequence = curaccept
    CALL text(20,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter facility label: "))
    CALL accept(21,2,"P(50);C","Facility")
    SET claimvisit_section->claimvisit[1].param_facility[1].literal = curaccept
    CALL text(22,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(22,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_facility[1].showing = curaccept
    CALL text(23,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-4): "))
    CALL accept(23,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4))
    SET claimvisit_section->claimvisit[1].param_facility[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter billing provider label: "))
    CALL accept(5,2,"P(50);C","Billing Provider")
    SET claimvisit_section->claimvisit[1].param_billing_provider[1].literal = curaccept
    CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(6,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_billing_provider[1].showing = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-4): "))
    CALL accept(7,40,"99;"
     WHERE curaccept IN (1, 2, 3, 4))
    SET claimvisit_section->claimvisit[1].param_billing_provider[1].sequence = curaccept
    CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter diagnosis label: "))
    CALL accept(10,2,"P(50);C","Diagnosis")
    SET claimvisit_section->claimvisit[1].param_diagnosis[1].literal = curaccept
    CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(11,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_diagnosis[1].showing = curaccept
    CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter procedure label: "))
    CALL accept(15,2,"P(50);C","Procedure")
    SET claimvisit_section->claimvisit[1].param_procedure[1].literal = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(16,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET claimvisit_section->claimvisit[1].param_procedure[1].showing = curaccept
    CALL text(18,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter result sequence (ascending or descending): "))
    CALL accept(19,2,"P(50);C","ascending"
     WHERE curaccept IN ("ascending", "descending"))
    SET claimvisit_section->claimvisit[1].param_result_seq[1].literal = curaccept
    CALL text(21,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
      "Save and return to Main Menu(1) or Quit(2)? "))
    CALL accept(21,50,"9;",1
     WHERE curaccept IN (1, 2))
    IF (curaccept=2)
     GO TO end_program
    ELSEIF (curaccept=1)
     CALL saveclaimvisitsection(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE modifymedsprofilesection(newind)
   SET medsprofile_section->medsprofile[1].content_type = medsprofile_sect
   CALL clear(1,1)
   CALL text(1,20,uar_i18ngetmessage(i18nhandle,"MAINHEADIMMUN",
     "Clinical Reporting Template Maintenance - Medications Profile List"))
   IF (newind=0)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section name: "))
    CALL extractxmlvalue("name",sectionlongtext,0)
    CALL accept(5,2,"P(50);C",tempstr)
    SET medsprofile_section->medsprofile[1].name = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section label: "))
    CALL extractxmlvalue("label",sectionlongtext,0)
    CALL accept(8,2,"P(50);C",tempstr)
    SET medsprofile_section->medsprofile[1].label = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter ordered as mnemonic label: "))
    CALL extractxmlvalue("'ordered-as-mnemonic'",sectionlongtext,1)
    CALL accept(11,2,"P(50);C",literal)
    SET medsprofile_section->medsprofile[1].param_ordered_as_mnemonic[1].literal = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(12,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET medsprofile_section->medsprofile[1].param_ordered_as_mnemonic[1].showing = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-2): "))
    CALL accept(13,40,"99;",sequence
     WHERE curaccept IN (1, 2))
    SET medsprofile_section->medsprofile[1].param_ordered_as_mnemonic[1].sequence = curaccept
    CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter clinical display line label: "
      ))
    CALL extractxmlvalue("'clinical-display-line'",sectionlongtext,1)
    CALL accept(16,2,"P(50);C",literal)
    SET medsprofile_section->medsprofile[1].param_clinical_display_line[1].literal = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(17,40,"P(5);C",showing
     WHERE curaccept IN ("true", "false"))
    SET medsprofile_section->medsprofile[1].param_clinical_display_line[1].showing = curaccept
    CALL text(18,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-2): "))
    CALL accept(18,40,"99;",sequence
     WHERE curaccept IN (1, 2))
    SET medsprofile_section->medsprofile[1].param_clinical_display_line[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter primary sort (ordered-as-mnemonic or last-action-dt-tm): "))
    CALL extractxmlvalue("'primary-sort'",sectionlongtext,1)
    CALL accept(5,2,"P(50);C",literal
     WHERE curaccept IN ("ordered-as-mnemonic", "last-action-dt-tm"))
    SET medsprofile_section->medsprofile[1].param_primary_sort[1].literal = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter primary sort direction (ascending or descending): "))
    CALL extractxmlvalue("'primary-sort-direction'",sectionlongtext,1)
    CALL accept(8,2,"P(50);C",literal
     WHERE curaccept IN ("ascending", "descending"))
    SET medsprofile_section->medsprofile[1].param_primary_sort_direction[1].literal = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter secondary sort (ordered-as-mnemonic or last-action-dt-tm): "))
    CALL extractxmlvalue("'secondary-sort'",sectionlongtext,1)
    CALL accept(11,2,"P(50);C",literal
     WHERE curaccept IN ("ordered-as-mnemonic", "last-action-dt-tm"))
    SET medsprofile_section->medsprofile[1].param_secondary_sort[1].literal = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter secondary sort direction (ascending or descending): "))
    CALL extractxmlvalue("'secondary-sort-direction'",sectionlongtext,1)
    CALL accept(14,2,"P(50);C",literal
     WHERE curaccept IN ("ascending", "descending"))
    SET medsprofile_section->medsprofile[1].param_secondary_sort_direction[1].literal = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
      "Save and return to Main Menu(1) or Quit(2)? "))
    CALL accept(16,50,"9;",1
     WHERE curaccept IN (1, 2))
    IF (curaccept=2)
     GO TO end_program
    ELSEIF (curaccept=1)
     CALL savemedsprofilesection(null)
    ENDIF
   ELSE
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section name: "))
    CALL accept(5,2,"P(50);C")
    SET medsprofile_section->medsprofile[1].name = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter a section label: "))
    CALL accept(8,2,"P(50);C")
    SET medsprofile_section->medsprofile[1].label = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter ordered as mnemonic label: "))
    CALL accept(11,2,"P(50);C","Ordered as Mnemonic")
    SET medsprofile_section->medsprofile[1].param_ordered_as_mnemonic[1].literal = curaccept
    CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(12,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET medsprofile_section->medsprofile[1].param_ordered_as_mnemonic[1].showing = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-2): "))
    CALL accept(13,40,"99;"
     WHERE curaccept IN (1, 2))
    SET medsprofile_section->medsprofile[1].param_ordered_as_mnemonic[1].sequence = curaccept
    CALL text(15,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter clinical display line label: "
      ))
    CALL accept(16,2,"P(50);C","Clinical Display Line")
    SET medsprofile_section->medsprofile[1].param_clinical_display_line[1].literal = curaccept
    CALL text(17,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter showing (true or false): "))
    CALL accept(17,40,"P(5);C","true"
     WHERE curaccept IN ("true", "false"))
    SET medsprofile_section->medsprofile[1].param_clinical_display_line[1].showing = curaccept
    CALL text(18,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence (1-2): "))
    CALL accept(18,40,"99;"
     WHERE curaccept IN (1, 2))
    SET medsprofile_section->medsprofile[1].param_clinical_display_line[1].sequence = curaccept
    CALL clear(4,1)
    CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter primary sort (ordered-as-mnemonic or last-action-dt-tm): "))
    CALL accept(5,2,"P(50);C","ordered-as-mnemonic"
     WHERE curaccept IN ("ordered-as-mnemonic", "last-action-dt-tm"))
    SET medsprofile_section->medsprofile[1].param_primary_sort[1].literal = curaccept
    CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter primary sort direction (ascending or descending): "))
    CALL accept(8,2,"P(50);C","ascending"
     WHERE curaccept IN ("ascending", "descending"))
    SET medsprofile_section->medsprofile[1].param_primary_sort_direction[1].literal = curaccept
    CALL text(10,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter secondary sort (ordered-as-mnemonic or last-action-dt-tm): "))
    CALL accept(11,2,"P(50);C","last-action-dt-tm"
     WHERE curaccept IN ("ordered-as-mnemonic", "last-action-dt-tm"))
    SET medsprofile_section->medsprofile[1].param_secondary_sort[1].literal = curaccept
    CALL text(13,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL",
      "Enter secondary sort direction (ascending or descending): "))
    CALL accept(14,2,"P(50);C","ascending"
     WHERE curaccept IN ("ascending", "descending"))
    SET medsprofile_section->medsprofile[1].param_secondary_sort_direction[1].literal = curaccept
    CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
      "Save and return to Main Menu(1) or Quit(2)? "))
    CALL accept(16,50,"9;",1
     WHERE curaccept IN (1, 2))
    IF (curaccept=2)
     GO TO end_program
    ELSEIF (curaccept=1)
     CALL savemedsprofilesection(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE associatesectiontotemplate(null)
   DECLARE sectioncnt = i4 WITH noconstant(1)
   SET stat = alterlist(report_template->template[1].sections,sectioncnt)
   CALL clear(1,1)
   CALL box(2,1,20,79)
   CALL text(1,25,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Template Maintenance")
    )
   CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Select a template: "))
   CALL text(5,2,"Shift/F5 to see a list of templates")
   SET help =
   SELECT DISTINCT INTO "nl:"
    crt.template_name
    FROM cr_report_template crt
    WHERE crt.template_id > 0
     AND crt.active_ind=1
     AND crt.report_template_id=crt.template_id
    ORDER BY crt.template_name
    WITH nocounter
   ;end select
   CALL accept(6,2,"P(32);C")
   SET help = off
   SET report_template->template_name = trim(curaccept)
   DECLARE whilenum = i2 WITH noconstant(1)
   WHILE (whilenum=1)
     CALL text(8,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Select a section: "))
     CALL text(9,2,"Shift/F5 to see a list of sections")
     SET help =
     SELECT DISTINCT INTO "nl:"
      crs.section_name
      FROM cr_report_section crs
      WHERE crs.section_id > 0
       AND crs.active_ind=1
       AND crs.report_section_id=crs.section_id
      ORDER BY crs.section_name
      WITH nocounter
     ;end select
     CALL accept(10,2,"P(32);C")
     SET help = off
     SET report_template->template[1].sections[sectioncnt].section_name = trim(curaccept)
     CALL text(12,2,uar_i18ngetmessage(i18nhandle,"MAINIMMUNLBL","Enter sequence number: "))
     CALL accept(12,40,"99;")
     SET report_template->template[1].sections[sectioncnt].sequence_nbr = curaccept
     CALL text(14,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2",
       "Save and return to Main Menu(1)  Continue(2) or Quit(3)? "))
     CALL accept(14,60,"9;",2
      WHERE curaccept IN (1, 2, 3))
     IF (curaccept=3)
      GO TO end_program
     ELSEIF (curaccept=2)
      SET sectioncnt = (sectioncnt+ 1)
      SET stat = alterlist(report_template->template[1].sections,sectioncnt)
     ELSEIF (curaccept=1)
      SELECT INTO "nl:"
       FROM cr_report_template crt
       WHERE crt.template_id > 0
        AND crt.active_ind=1
        AND crt.report_template_id=crt.template_id
        AND (crt.template_name=report_template->template_name)
       DETAIL
        report_template->template_id = crt.template_id
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM cr_report_section crs,
        (dummyt d  WITH seq = value(sectioncnt))
       PLAN (d)
        JOIN (crs
        WHERE crs.section_id > 0
         AND crs.active_ind=1
         AND crs.report_section_id=crs.section_id
         AND (crs.section_name=report_template->template[1].sections[d.seq].section_name))
       DETAIL
        report_template->template[1].sections[d.seq].section_id = crs.section_id
       FOOT REPORT
        do_nothing = 0
       WITH nocounter
      ;end select
      CALL text(16,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Select a static region: "))
      CALL text(17,2,"Shift/F5 to see a list of static regions")
      SET help =
      SELECT DISTINCT INTO "nl:"
       crs.region_name
       FROM cr_report_static_region crs
       WHERE crs.static_region_id > 0
        AND crs.active_ind=1
        AND crs.report_static_region_id=crs.static_region_id
       ORDER BY crs.region_name
       WITH nocounter
      ;end select
      CALL accept(18,2,"P(32);C")
      SET help = off
      SET report_template->template[1].static_regions[1].region_name = trim(curaccept)
      SELECT INTO "nl:"
       FROM cr_report_static_region crs
       WHERE crs.static_region_id > 0
        AND crs.active_ind=1
        AND crs.report_static_region_id=crs.static_region_id
        AND (crs.region_name=report_template->template[1].static_regions[1].region_name)
       DETAIL
        report_template->template[1].static_regions[1].static_region_id = crs.static_region_id
       WITH nocounter
      ;end select
      CALL savepagemaster(sectioncnt)
      SET whilenum = 0
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE savetemplate(null)
   FREE RECORD request
   RECORD request(
     1 template_id = f8
     1 template_name = c32
     1 xml_detail = vc
     1 updt_cnt = i4
     1 active_ind = i2
     1 xml_detail_dirty_ind = i2
     1 template_dirty_ind = i2
     1 relation_dirty_ind = i2
     1 cr_report_section[*]
       2 section_id = f8
       2 section_name = c32
       2 xml_detail = vc
       2 updt_cnt = i4
       2 active_ind = i2
       2 xml_detail_dirty_ind = i2
       2 section_dirty_ind = i2
       2 sequence_nbr = i4
     1 cr_report_static_region[*]
       2 static_region_id = f8
       2 region_name = c32
       2 xml_detail = vc
       2 updt_cnt = i4
       2 active_ind = i2
       2 xml_detail_dirty_ind = i2
       2 region_dirty_ind = i2
   )
   SELECT INTO "nl:"
    FROM cr_report_template crt
    WHERE crt.template_id > 0
     AND crt.active_ind=1
     AND crt.report_template_id=crt.template_id
     AND (crt.template_name=report_template->template_name)
    DETAIL
     request->template_id = crt.template_id, request->updt_cnt = crt.updt_cnt
    WITH nocounter
   ;end select
   SET request->template_name = report_template->template_name
   SET request->xml_detail = xml_request
   SET request->active_ind = 1
   SET request->xml_detail_dirty_ind = 1
   SET request->template_dirty_ind = 1
   SET request->relation_dirty_ind = 0
   EXECUTE cr_upd_report_templates
   COMMIT
   CALL freerecordstructs(null)
   SET xml_request = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?>"
 END ;Subroutine
 SUBROUTINE savestaticregion(null)
   FREE RECORD request
   RECORD request(
     1 cr_report_static_region[*]
       2 static_region_id = f8
       2 region_name = c32
       2 xml_detail = vc
       2 updt_cnt = i4
       2 active_ind = i2
       2 xml_detail_dirty_ind = i2
       2 region_dirty_ind = i2
   )
   DECLARE num_regions = i4 WITH noconstant(1)
   SET stat = alterlist(request->cr_report_static_region,num_regions)
   SELECT INTO "nl:"
    FROM cr_report_static_region crs
    WHERE crs.static_region_id > 0
     AND crs.active_ind=1
     AND crs.report_static_region_id=crs.static_region_id
     AND crs.region_name=selectedregion
    DETAIL
     regionid = crs.static_region_id, request->cr_report_static_region[1], updt_cnt = crs.updt_cnt
    WITH nocounter
   ;end select
   SET request->cr_report_static_region[1].static_region_id = regionid
   SET request->cr_report_static_region[1].region_name = selectedregion
   SET request->cr_report_static_region[1].xml_detail = xml_request
   SET request->cr_report_static_region[1].active_ind = 1
   SET request->cr_report_static_region[1].xml_detail_dirty_ind = 1
   SET request->cr_report_static_region[1].region_dirty_ind = 1
   EXECUTE cr_upd_report_regions
   COMMIT
   SET regionid = 0
   SET xml_request = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?>"
 END ;Subroutine
 SUBROUTINE savepagemaster(sectioncnt)
   FREE RECORD reply
   FREE RECORD request
   RECORD request(
     1 template_id = f8
     1 template_name = c32
     1 xml_detail = vc
     1 updt_cnt = i4
     1 active_ind = i2
     1 xml_detail_dirty_ind = i2
     1 template_dirty_ind = i2
     1 relation_dirty_ind = i2
     1 cr_report_section[*]
       2 section_id = f8
       2 section_name = c32
       2 xml_detail = vc
       2 updt_cnt = i4
       2 active_ind = i2
       2 xml_detail_dirty_ind = i2
       2 section_dirty_ind = i2
       2 sequence_nbr = i4
     1 cr_report_static_region[*]
       2 static_region_id = f8
       2 region_name = c32
       2 xml_detail = vc
       2 updt_cnt = i4
       2 active_ind = i2
       2 xml_detail_dirty_ind = i2
       2 region_dirty_ind = i2
   )
   SET request->template_id = report_template->template_id
   SET request->relation_dirty_ind = 1
   SET stat = alterlist(request->cr_report_static_region,1)
   SET request->cr_report_static_region[1].static_region_id = report_template->template[1].
   static_regions[1].static_region_id
   SET stat = alterlist(request->cr_report_section,sectioncnt)
   FOR (lsectscnt = 1 TO sectioncnt)
    SET request->cr_report_section[lsectscnt].section_id = report_template->template[1].sections[
    lsectscnt].section_id
    SET request->cr_report_section[lsectscnt].sequence_nbr = report_template->template[1].sections[
    lsectscnt].sequence_nbr
   ENDFOR
   EXECUTE cr_upd_report_templates
   COMMIT
   CALL freerecordstructs(null)
 END ;Subroutine
 SUBROUTINE saveimmunizationsection(null)
   SET xml_request = concat(xml_request," ","<section name=","'",trim(immunization_section->
     immunization[1].name),
    "'")
   SET xml_request = concat(xml_request," ","content-type=","'",immun_sect,
    "'")
   SET xml_request = concat(xml_request," ","layout='list'")
   SET xml_request = concat(xml_request," ","label=","'",trim(immunization_section->immunization[1].
     label),
    "'>")
   SET xml_request = concat(xml_request,"<parameter name='lot-num'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_lot_num[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_lot_num[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].param_lot_num[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='expiration-time'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_expiration_time[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_expiration_date[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='expiration-date'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_expiration_date[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_expiration_date[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].
     param_expiration_date[1].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='admin-person'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_admin_person[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_admin_person[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].
     param_admin_person[1].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='manufacturer'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_manufacturer[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_manufacturer[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].
     param_manufacturer[1].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='amount'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_amount[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_amount[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].param_amount[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='site'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_site[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_site[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].param_site[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='vaccine'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_vaccine[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_vaccine[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].param_vaccine[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='provider'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_provider[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_provider[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].param_provider[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='date-given'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_date_given[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_date_given[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].param_date_given[1
     ].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='time-given'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_time_given[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_date_given[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='age'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_age[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(immunization_section->
      immunization[1].param_age[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].param_age[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='time-format'")
   SET xml_request = concat(xml_request," ","showing='false'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].param_time_format[
     1].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='date-format'")
   SET xml_request = concat(xml_request," ","showing='false'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].param_date_format[
     1].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='result-seq'")
   SET xml_request = concat(xml_request," ","showing='false'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].param_result_seq[1
     ].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='admin-note'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(immunization_section->immunization[1]
     .param_admin_note[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(immunization_section->immunization[1].param_admin_note[1
     ].literal),"</parameter>")
   SET xml_request = concat(xml_request,"</section>")
   FREE RECORD reply
   FREE RECORD request
   RECORD request(
     1 cr_report_section[*]
       2 section_id = f8
       2 section_name = c32
       2 xml_detail = vc
       2 sequence_nbr = i4
       2 updt_cnt = i4
       2 active_ind = i2
       2 xml_detail_dirty_ind = i2
       2 section_dirty_ind = i2
   )
   SELECT INTO "nl:"
    FROM cr_report_section crs
    WHERE crs.section_id > 0
     AND crs.active_ind=1
     AND crs.report_section_id=crs.section_id
     AND crs.section_name=selectedsection
    DETAIL
     immunization_section->immunization[1].updt_cnt = crs.updt_cnt
    WITH nocounter
   ;end select
   SET stat = alterlist(request->cr_report_section,num_sections)
   SET request->cr_report_section[num_sections].section_id = sectionid
   SET request->cr_report_section[num_sections].section_name = trim(immunization_section->
    immunization[1].name)
   SET request->cr_report_section[num_sections].xml_detail = xml_request
   SET request->cr_report_section[num_sections].updt_cnt = immunization_section->immunization[1].
   updt_cnt
   SET request->cr_report_section[num_sections].active_ind = 1
   SET request->cr_report_section[num_sections].xml_detail_dirty_ind = 1
   SET request->cr_report_section[num_sections].section_dirty_ind = 1
   SET request->cr_report_section[num_sections].sequence_nbr = 1
   EXECUTE cr_upd_report_sections
   COMMIT
   SET sectionid = 0.0
   SET xml_request = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?>"
 END ;Subroutine
 SUBROUTINE savegenlabsection(eventsetcnt)
   SET xml_request = concat(xml_request," ","<section name=","'",trim(genlab_section->genlab[1].name),
    "'")
   SET xml_request = concat(xml_request," ","content-type=","'",genlab_sect,
    "'")
   SET xml_request = concat(xml_request," ","layout='list'")
   SET xml_request = concat(xml_request," ","label=","'",trim(genlab_section->genlab[1].label),
    "'>")
   SET xml_request = concat(xml_request,"<parameter name='procedure'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_procedure[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_procedure[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_procedure[1].literal),
    "</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='result'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_result[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_result[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_result[1].literal),
    "</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='units'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_units[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_units[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_units[1].literal),
    "</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='ref-range'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_ref_range[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_ref_range[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_ref_range[1].literal),
    "</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='date'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].param_date[
     1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_date[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_date[1].literal),
    "</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='time'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].param_time[
     1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_date[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='accession-nbr'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_accession_nbr[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_accession_nbr[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_accession_nbr[1].literal
     ),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='body-site'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_body_site[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_body_site[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_body_site[1].literal),
    "</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='collected-dt'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_collected_dt[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_collected_dt[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_collected_dt[1].literal),
    "</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='collected-dt-tm'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_collected_dt_tm[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_collected_dt_tm[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_collected_dt_tm[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='department-status'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_department_status[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_department_status[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_department_status[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='order-dt'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_order_dt[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_order_dt[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_order_dt[1].literal),
    "</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='order-dt-tm'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_order_dt_tm[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_order_dt_tm[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_order_dt_tm[1].literal),
    "</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='orderable-name'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_orderable_name[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_orderable_name[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_orderable_name[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='specimen-type'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_specimen_type[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_specimen_type[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_specimen_type[1].literal
     ),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='ordering-provider'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(genlab_section->genlab[1].
     param_ordering_provider[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(genlab_section->genlab[1]
      .param_ordering_provider[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_ordering_provider[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='result-seq'")
   SET xml_request = concat(xml_request," ","showing='false'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(genlab_section->genlab[1].param_result_seq[1].literal),
    "</parameter>")
   FOR (leventsetcnt = 1 TO eventsetcnt)
     SET xml_request = concat(xml_request,"<procedure-group label=","'",trim(genlab_section->genlab[1
       ].param_event_set[leventsetcnt].label),"'>")
     SET xml_request = concat(xml_request,"<procedure type='event-set'")
     SET xml_request = concat(xml_request," ","uid=","'",trim(genlab_section->genlab[1].
       param_event_set[leventsetcnt].name),
      "'>")
     SET xml_request = concat(xml_request,"<event-code code=","'",trim(cnvtstring(genlab_section->
        genlab[1].param_event_set[leventsetcnt].code)),"'/>")
     SET xml_request = concat(xml_request,"</procedure></procedure-group>")
   ENDFOR
   SET xml_request = concat(xml_request,"</section>")
   FREE RECORD reply
   FREE RECORD request
   RECORD request(
     1 cr_report_section[*]
       2 section_id = f8
       2 section_name = c32
       2 xml_detail = vc
       2 sequence_nbr = i4
       2 updt_cnt = i4
       2 active_ind = i2
       2 xml_detail_dirty_ind = i2
       2 section_dirty_ind = i2
   )
   SELECT INTO "nl:"
    FROM cr_report_section crs
    WHERE crs.section_id > 0
     AND crs.active_ind=1
     AND crs.report_section_id=crs.section_id
     AND crs.section_name=selectedsection
    DETAIL
     genlab_section->genlab[1].updt_cnt = crs.updt_cnt
    WITH nocounter
   ;end select
   SET stat = alterlist(request->cr_report_section,num_sections)
   SET request->cr_report_section[num_sections].section_id = sectionid
   SET request->cr_report_section[num_sections].section_name = trim(genlab_section->genlab[1].name)
   SET request->cr_report_section[num_sections].xml_detail = xml_request
   SET request->cr_report_section[num_sections].updt_cnt = genlab_section->genlab[1].updt_cnt
   SET request->cr_report_section[num_sections].active_ind = 1
   SET request->cr_report_section[num_sections].xml_detail_dirty_ind = 1
   SET request->cr_report_section[num_sections].section_dirty_ind = 1
   SET request->cr_report_section[num_sections].sequence_nbr = 1
   EXECUTE cr_upd_report_sections
   COMMIT
   CALL freerecordstructs(null)
   SET sectionid = 0.0
   SET xml_request = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?>"
 END ;Subroutine
 SUBROUTINE saveclaimvisitsection(null)
   SET xml_request = concat(xml_request," ","<section name=","'",trim(claimvisit_section->claimvisit[
     1].name),
    "'")
   SET xml_request = concat(xml_request," ","content-type=","'",claimvisit_sect,
    "'")
   SET xml_request = concat(xml_request," ","label=","'",trim(claimvisit_section->claimvisit[1].label
     ),
    "'>")
   SET xml_request = concat(xml_request,"<parameter name='service-dt-tm'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(claimvisit_section->claimvisit[1].
     param_service_dt_tm[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(claimvisit_section->
      claimvisit[1].param_service_dt_tm[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(claimvisit_section->claimvisit[1].param_service_dt_tm[1]
     .literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='visit-type'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(claimvisit_section->claimvisit[1].
     param_visit_type[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(claimvisit_section->
      claimvisit[1].param_visit_type[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(claimvisit_section->claimvisit[1].param_visit_type[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='facility'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(claimvisit_section->claimvisit[1].
     param_facility[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(claimvisit_section->
      claimvisit[1].param_facility[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(claimvisit_section->claimvisit[1].param_facility[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='billing-provider'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(claimvisit_section->claimvisit[1].
     param_billing_provider[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(claimvisit_section->
      claimvisit[1].param_billing_provider[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(claimvisit_section->claimvisit[1].
     param_billing_provider[1].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='diagnosis'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(claimvisit_section->claimvisit[1].
     param_diagnosis[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(claimvisit_section->claimvisit[1].param_diagnosis[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='procedure'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(claimvisit_section->claimvisit[1].
     param_procedure[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(claimvisit_section->claimvisit[1].param_procedure[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='result-seq'")
   SET xml_request = concat(xml_request," ","showing='false'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(claimvisit_section->claimvisit[1].param_result_seq[1].
     literal),"</parameter>")
   SET xml_request = concat(xml_request,"</section>")
   FREE RECORD reply
   FREE RECORD request
   RECORD request(
     1 cr_report_section[*]
       2 section_id = f8
       2 section_name = c32
       2 xml_detail = vc
       2 sequence_nbr = i4
       2 updt_cnt = i4
       2 active_ind = i2
       2 xml_detail_dirty_ind = i2
       2 section_dirty_ind = i2
   )
   SELECT INTO "nl:"
    FROM cr_report_section crs
    WHERE crs.section_id > 0
     AND crs.active_ind=1
     AND crs.report_section_id=crs.section_id
     AND crs.section_name=selectedsection
    DETAIL
     claimvisit_section->claimvisit[1].updt_cnt = crs.updt_cnt
    WITH nocounter
   ;end select
   SET stat = alterlist(request->cr_report_section,num_sections)
   SET request->cr_report_section[num_sections].section_id = sectionid
   SET request->cr_report_section[num_sections].section_name = trim(claimvisit_section->claimvisit[1]
    .name)
   SET request->cr_report_section[num_sections].xml_detail = xml_request
   SET request->cr_report_section[num_sections].updt_cnt = claimvisit_section->claimvisit[1].updt_cnt
   SET request->cr_report_section[num_sections].active_ind = 1
   SET request->cr_report_section[num_sections].xml_detail_dirty_ind = 1
   SET request->cr_report_section[num_sections].section_dirty_ind = 1
   SET request->cr_report_section[num_sections].sequence_nbr = 1
   EXECUTE cr_upd_report_sections
   COMMIT
   SET sectionid = 0.0
   SET xml_request = " "
 END ;Subroutine
 SUBROUTINE savemedsprofilesection(null)
   SET xml_request = concat(xml_request," ","<section name=","'",trim(medsprofile_section->
     medsprofile[1].name),
    "'")
   SET xml_request = concat(xml_request," ","content-type=","'",medsprofile_sect,
    "'")
   SET xml_request = concat(xml_request," ","label=","'",trim(medsprofile_section->medsprofile[1].
     label),
    "'>")
   SET xml_request = concat(xml_request,"<parameter name='ordered-as-mnemonic'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(medsprofile_section->medsprofile[1].
     param_ordered_as_mnemonic[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(medsprofile_section->
      medsprofile[1].param_ordered_as_mnemonic[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(medsprofile_section->medsprofile[1].
     param_ordered_as_mnemonic[1].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='clinical-display-line'")
   SET xml_request = concat(xml_request," ","showing=","'",trim(medsprofile_section->medsprofile[1].
     param_clinical_display_line[1].showing),
    "'")
   SET xml_request = concat(xml_request," ","sequence=","'",trim(cnvtstring(medsprofile_section->
      medsprofile[1].param_clinical_display_line[1].sequence)),
    "'>")
   SET xml_request = concat(xml_request,trim(medsprofile_section->medsprofile[1].
     param_clinical_display_line[1].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='primary-sort'")
   SET xml_request = concat(xml_request," ","showing='false'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(medsprofile_section->medsprofile[1].param_primary_sort[1
     ].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='primary-sort-direction'")
   SET xml_request = concat(xml_request," ","showing='false'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(medsprofile_section->medsprofile[1].
     param_primary_sort_direction[1].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='secondary-sort'")
   SET xml_request = concat(xml_request," ","showing='false'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(medsprofile_section->medsprofile[1].
     param_secondary_sort[1].literal),"</parameter>")
   SET xml_request = concat(xml_request,"<parameter name='secondary-sort-direction'")
   SET xml_request = concat(xml_request," ","showing='false'")
   SET xml_request = concat(xml_request," ","sequence='0'>")
   SET xml_request = concat(xml_request,trim(medsprofile_section->medsprofile[1].
     param_secondary_sort_direction[1].literal),"</parameter>")
   SET xml_request = concat(xml_request,"</section>")
   FREE RECORD reply
   FREE RECORD request
   RECORD request(
     1 cr_report_section[*]
       2 section_id = f8
       2 section_name = c32
       2 xml_detail = vc
       2 sequence_nbr = i4
       2 updt_cnt = i4
       2 active_ind = i2
       2 xml_detail_dirty_ind = i2
       2 section_dirty_ind = i2
   )
   SELECT INTO "nl:"
    FROM cr_report_section crs
    WHERE crs.section_id > 0
     AND crs.active_ind=1
     AND crs.report_section_id=crs.section_id
     AND crs.section_name=selectedsection
    DETAIL
     medsprofile_section->medsprofile[1].updt_cnt = crs.updt_cnt
    WITH nocounter
   ;end select
   SET stat = alterlist(request->cr_report_section,num_sections)
   SET request->cr_report_section[num_sections].section_id = sectionid
   SET request->cr_report_section[num_sections].section_name = trim(medsprofile_section->medsprofile[
    1].name)
   SET request->cr_report_section[num_sections].xml_detail = xml_request
   SET request->cr_report_section[num_sections].updt_cnt = medsprofile_section->medsprofile[1].
   updt_cnt
   SET request->cr_report_section[num_sections].active_ind = 1
   SET request->cr_report_section[num_sections].xml_detail_dirty_ind = 1
   SET request->cr_report_section[num_sections].section_dirty_ind = 1
   SET request->cr_report_section[num_sections].sequence_nbr = 1
   EXECUTE cr_upd_report_sections
   COMMIT
   SET sectionid = 0.0
   SET xml_request = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?>"
 END ;Subroutine
 SUBROUTINE populatetemptables(null)
   SET section_types->sections[1].section = immun_sect
   SET section_types->sections[2].section = genlab_sect
   SET section_types->sections[3].section = claimvisit_sect
   SET section_types->sections[4].section = medsprofile_sect
 END ;Subroutine
 SUBROUTINE freerecordstructs(null)
  SET stat = alterlist(report_template->template[1].sections,0)
  SET stat = alterlist(genlab_section->genlab[1].param_event_set,0)
 END ;Subroutine
 SUBROUTINE populatetemplatelongtext(templatename)
   SELECT INTO "nl:"
    FROM cr_report_template crt,
     long_text_reference ltr
    PLAN (crt
     WHERE crt.template_id > 0
      AND crt.active_ind=1
      AND crt.report_template_id=crt.template_id
      AND crt.template_name=templatename)
     JOIN (ltr
     WHERE ltr.long_text_id=crt.long_text_id)
    HEAD REPORT
     outbuf = fillstring(100," ")
    DETAIL
     offset = 0, retlen = 1
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,ltr.long_text), offset = (offset+ retlen), templatelongtext =
       concat(templatelongtext,outbuf)
     ENDWHILE
     report_template->template_id = crt.template_id
    FOOT REPORT
     do_nothing = 0
    WITH rdbarrayfetch = 1
   ;end select
 END ;Subroutine
 SUBROUTINE populatesectionlongtext(sectionname)
   SELECT INTO "nl:"
    FROM cr_report_section crs,
     long_text_reference ltr
    PLAN (crs
     WHERE crs.section_id > 0
      AND crs.active_ind=1
      AND crs.report_section_id=crs.section_id
      AND crs.section_name=sectionname)
     JOIN (ltr
     WHERE ltr.long_text_id=crs.long_text_id)
    HEAD REPORT
     outbuf = fillstring(100," ")
    DETAIL
     offset = 0, retlen = 1
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,ltr.long_text), offset = (offset+ retlen), sectionlongtext =
       concat(sectionlongtext,outbuf)
     ENDWHILE
     sectionid = crs.section_id
    FOOT REPORT
     do_nothing = 0
    WITH rdbarrayfetch = 1
   ;end select
 END ;Subroutine
 SUBROUTINE extractxmlvalue(lookup,searchtext,isparam)
   SET tempstr = ""
   SET showing = ""
   SET sequence = 0
   SET literal = ""
   SET first = findstring(lookup,searchtext,1,0)
   SET startvalue = findstring("'",searchtext,first,0)
   SET endvalue = findstring("'",searchtext,(startvalue+ 1),0)
   SET diff = (endvalue - startvalue)
   SET tempstr = substring((startvalue+ 1),(diff - 1),searchtext)
   IF (isparam=1)
    SET first = findstring("showing",searchtext,endvalue,0)
    SET startvalue = findstring("'",searchtext,first,0)
    SET endvalue = findstring("'",searchtext,(startvalue+ 1),0)
    SET diff = (endvalue - startvalue)
    SET showing = substring((startvalue+ 1),(diff - 1),searchtext)
    SET first = findstring("sequence",searchtext,endvalue,0)
    SET startvalue = findstring("'",searchtext,first,0)
    SET endvalue = findstring("'",searchtext,(startvalue+ 1),0)
    SET diff = (endvalue - startvalue)
    SET sequence = cnvtint(substring((startvalue+ 1),(diff - 1),searchtext))
    SET first = findstring(">",searchtext,endvalue,0)
    SET endvalue = findstring("<",searchtext,(first+ 1),0)
    SET diff = (endvalue - first)
    SET literal = substring((first+ 1),(diff - 1),searchtext)
   ENDIF
 END ;Subroutine
#end_program
 FOR (x = 1 TO 24)
   CALL clear(x,1,132)
 ENDFOR
END GO
