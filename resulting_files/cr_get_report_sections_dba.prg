CREATE PROGRAM cr_get_report_sections:dba
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
 SET log_program_name = "cr_get_report_sections"
 CALL log_message("Starting script: cr_get_report_sections",log_level_debug)
 CALL echorecord(request)
 FREE RECORD reply
 RECORD reply(
   1 section_infos[*]
     2 version_mode = i2
     2 component_id = f8
     2 version_id = f8
     2 name = vc
     2 active_ind = i2
     2 updt_cnt = i4
     2 version_dt_tm = dq8
     2 xml_detail = gvc
     2 updt_id = f8
     2 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nworking_version = i2 WITH protect, constant(1)
 DECLARE ndate_range = i2 WITH protect, constant(3)
 DECLARE lsection_cnt = i4 WITH protect, constant(size(request->section_modes,5))
 DECLARE lcount = i4
 DECLARE squalclause = vc
 SET reply->status_data.status = "F"
 SET lcount = 0
 IF (lsection_cnt > 0)
  FOR (lscount = 1 TO lsection_cnt)
    CALL retrievedetails(lscount)
  ENDFOR
 ENDIF
 SET stat = alterlist(reply->section_infos,lcount)
 SUBROUTINE (retrievedetails(lindex=i4) =null)
   CALL log_message("Entered RetrieveDetails subroutine.",log_level_debug)
   DECLARE lidx = i4
   DECLARE lstartidx = i4
   DECLARE lendidx = i4
   DECLARE lupperbound = i4
   SET lendidx = 0
   SET llistsize = size(request->section_modes[lindex].section_ids,5)
   SET lupperbound = ((llistsize/ 50)+ 1)
   CALL createqualclause(lindex)
   FOR (lforcount = 1 TO lupperbound)
     SET lstartidx = (lendidx+ 1)
     IF (lforcount=lupperbound)
      SET lendidx += (llistsize - lendidx)
     ELSE
      SET lendidx += 50
     ENDIF
     SELECT INTO "nl:"
      FROM cr_report_section crs,
       long_text_reference lt
      PLAN (crs
       WHERE parser(squalclause))
       JOIN (lt
       WHERE (lt.long_text_id=
       IF ((request->load_xml_ind=0)) 0.00
       ELSE crs.long_text_id
       ENDIF
       ))
      HEAD REPORT
       xoutbuf = fillstring(4096," ")
      DETAIL
       lcount += 1
       IF (mod(lcount,10)=1)
        stat = alterlist(reply->section_infos,(lcount+ 9))
       ENDIF
       reply->section_infos[lcount].version_mode = request->section_modes[lindex].version_mode, reply
       ->section_infos[lcount].component_id = crs.section_id, reply->section_infos[lcount].version_id
        = crs.report_section_id,
       reply->section_infos[lcount].name = crs.section_name, reply->section_infos[lcount].active_ind
        = crs.active_ind, reply->section_infos[lcount].updt_cnt = crs.updt_cnt,
       reply->section_infos[lcount].updt_id = crs.updt_id, reply->section_infos[lcount].updt_dt_tm =
       cnvtdatetime(crs.updt_dt_tm)
       IF ((request->section_modes[lindex].version_mode=nworking_version))
        reply->section_infos[lcount].version_dt_tm = cnvtdatetime(crs.updt_dt_tm)
       ELSE
        reply->section_infos[lcount].version_dt_tm = cnvtdatetime(request->section_modes[lindex].
         prev_version_dt_tm)
       ENDIF
       IF ((request->load_xml_ind=1))
        xoffset = 0, xretlen = 1
        WHILE (xretlen > 0)
          xretlen = blobget(xoutbuf,xoffset,lt.long_text)
          IF (xretlen=size(xoutbuf))
           reply->section_infos[lcount].xml_detail = notrim(concat(reply->section_infos[lcount].
             xml_detail,xoutbuf))
          ELSEIF (xretlen > 0)
           reply->section_infos[lcount].xml_detail = trim(concat(substring(1,xoffset,reply->
              section_infos[lcount].xml_detail),xoutbuf))
          ENDIF
          xoffset += xretlen
        ENDWHILE
       ENDIF
      WITH rdbarrayfetch = 1
     ;end select
     CALL error_and_zero_check(curqual,"RetrieveDetails",
      "CR_Report_Section table could not be read.  Exiting script.",1,0)
   ENDFOR
   CALL log_message("Exiting RetrieveSections subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (createqualclause(lindex=i4) =null)
   CALL log_message("Entered CreateQualClause subroutine.",log_level_debug)
   CASE (request->section_modes[lindex].version_mode)
    OF nworking_version:
     SET squalclause = "EXPAND(lIdx, lStartIdx, lEndIdx, crs.report_section_id,"
     SET squalclause = concat(squalclause,
      " request->section_modes[lIndex]->section_ids[lIdx].id) and")
     SET squalclause = concat(squalclause," crs.report_section_id > 0")
    OF ndate_range:
     SET squalclause = "EXPAND(lIdx, lStartIdx, lEndIdx, crs.section_id,"
     SET squalclause = concat(squalclause,
      " request->section_modes[lIndex]->section_ids[lIdx].id) and")
     SET squalclause = concat(squalclause," crs.section_id > 0 and")
     SET squalclause = concat(squalclause," crs.beg_effective_dt_tm")
     SET squalclause = concat(squalclause,
      " <= cnvtdatetime(request->section_modes[lIndex]->prev_version_dt_tm) and")
     SET squalclause = concat(squalclause," crs.end_effective_dt_tm ")
     SET squalclause = concat(squalclause,
      "> cnvtdatetime(request->section_modes[lIndex]->prev_version_dt_tm)")
    ELSE
     CALL populate_subeventstatus("QualClause","F","unsupported version_mode",cnvtstring(request->
       section_modes[lindex].version_mode))
     GO TO exit_script
   ENDCASE
   CALL log_message(build("Exiting CreateQualClause subroutine. sQualClause = ",squalclause),
    log_level_debug)
 END ;Subroutine
 IF (size(reply->section_infos,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("End of script: cr_get_report_sections",log_level_debug)
 CALL echorecord(reply)
END GO
