CREATE PROGRAM cr_get_report_templates:dba
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
 SET log_program_name = "cr_get_report_templates"
 CALL log_message("Starting script: cr_get_report_templates",log_level_debug)
 IF ( NOT (validate(reply,0)))
  FREE RECORD reply
  RECORD reply(
    1 template_infos[*]
      2 version_mode = i2
      2 component_id = f8
      2 version_id = f8
      2 name = vc
      2 active_ind = i2
      2 updt_cnt = i4
      2 version_dt_tm = dq8
      2 xml_detail = gvc
      2 latest_publish_dt_tm = dq8
      2 related_sections[*]
        3 section_id = f8
        3 sequence_nbr = i4
        3 page_break_after_ind = i2
      2 related_page_masters[*]
        3 page_master_id = f8
      2 updt_id = f8
      2 updt_dt_tm = dq8
      2 publish_updt_id = f8
      2 publish_dt_tm = dq8
      2 related_style_profile = f8
      2 facesheet_id = f8
      2 portrait_watermark_id = f8
      2 landscape_watermark_id = f8
      2 associated_positions[*]
        3 position_cd = f8
      2 lab_legend_id = f8
      2 micro_legend_id = f8
      2 pat_care_legend_id = f8
      2 summary_type_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE nworking_version = i2 WITH protect, constant(1)
 DECLARE npublished_version = i2 WITH protect, constant(2)
 DECLARE ndate_range = i2 WITH protect, constant(3)
 DECLARE npub_date_range = i2 WITH protect, constant(4)
 DECLARE ltemplate_cnt = i4 WITH protect, constant(size(request->template_modes,5))
 DECLARE lcount = i4
 DECLARE spublishclause = vc
 DECLARE squalclause = vc
 DECLARE srelationsclause = vc
 DECLARE sxmlclause = vc
 DECLARE spositionsclause = vc
 DECLARE createxmlclause(null) = null
 SET reply->status_data.status = "F"
 SET lcount = 0
 CALL createxmlclause(null)
 IF (ltemplate_cnt > 0)
  FOR (lscount = 1 TO ltemplate_cnt)
    CALL retrievedetails(lscount)
  ENDFOR
 ENDIF
 SET stat = alterlist(reply->template_infos,lcount)
 SUBROUTINE (retrievedetails(lindex=i4) =null)
   CALL log_message("Entered RetrieveDetails subroutine.",log_level_debug)
   DECLARE lidx = i4
   DECLARE lstartidx = i4
   DECLARE lendidx = i4
   DECLARE lupperbound = i4
   SET lendidx = 0
   SET llistsize = size(request->template_modes[lindex].template_ids,5)
   SET lupperbound = ((llistsize/ 50)+ 1)
   CALL createpublishclause(lindex)
   CALL createqualclause(lindex)
   CALL createrelationsclause(lindex)
   CALL createpositionsclause(lindex)
   FOR (lforcount = 1 TO lupperbound)
     SET lstartidx = (lendidx+ 1)
     IF (lforcount=lupperbound)
      SET lendidx += (llistsize - lendidx)
     ELSE
      SET lendidx += 50
     ENDIF
     SELECT
      IF ((((request->template_modes[lindex].version_mode=nworking_version)) OR ((request->
      template_modes[lindex].version_mode=ndate_range))) )
       FROM cr_report_template crt,
        long_text_reference lt,
        cr_template_publish ctp,
        cr_template_snapshot cts,
        cr_template_position_reltn pos,
        cr_template_publish pub
       PLAN (crt
        WHERE parser(squalclause))
        JOIN (lt
        WHERE parser(sxmlclause))
        JOIN (ctp
        WHERE parser(spublishclause))
        JOIN (cts
        WHERE parser(srelationsclause))
        JOIN (pos
        WHERE parser(spositionsclause))
        JOIN (pub
        WHERE pub.template_publish_id=0)
      ELSEIF ((request->template_modes[lindex].version_mode=npublished_version))
       FROM cr_template_publish ctp,
        cr_report_template crt,
        long_text_reference lt,
        cr_template_snapshot cts,
        cr_template_position_reltn pos,
        cr_template_publish pub
       PLAN (ctp
        WHERE parser(squalclause))
        JOIN (crt
        WHERE crt.template_id=ctp.template_id
         AND crt.beg_effective_dt_tm <= ctp.publish_dt_tm
         AND crt.end_effective_dt_tm > ctp.publish_dt_tm)
        JOIN (lt
        WHERE parser(sxmlclause))
        JOIN (cts
        WHERE parser(srelationsclause))
        JOIN (pos
        WHERE parser(spositionsclause))
        JOIN (pub
        WHERE pub.template_publish_id=ctp.template_publish_id)
      ELSEIF ((request->template_modes[lindex].version_mode=npub_date_range))
       FROM cr_template_publish pub,
        cr_report_template crt,
        long_text_reference lt,
        cr_template_publish ctp,
        cr_template_snapshot cts,
        cr_template_position_reltn pos
       PLAN (pub
        WHERE parser(squalclause))
        JOIN (crt
        WHERE crt.template_id=pub.template_id
         AND crt.beg_effective_dt_tm <= pub.publish_dt_tm
         AND crt.end_effective_dt_tm > pub.publish_dt_tm)
        JOIN (lt
        WHERE parser(sxmlclause))
        JOIN (ctp
        WHERE parser(spublishclause))
        JOIN (cts
        WHERE parser(srelationsclause))
        JOIN (pos
        WHERE parser(spositionsclause))
      ELSE
      ENDIF
      INTO "nl:"
      ORDER BY crt.template_id, cts.sequence_nbr
      HEAD REPORT
       xoutbuf = fillstring(4096," ")
      HEAD crt.template_id
       xregioncnt = 0, xsectcnt = 0, xpositioncnt = 0,
       lcount += 1
       IF (mod(lcount,10)=1)
        stat = alterlist(reply->template_infos,(lcount+ 9))
       ENDIF
       reply->template_infos[lcount].version_mode = request->template_modes[lindex].version_mode,
       reply->template_infos[lcount].component_id = crt.template_id, reply->template_infos[lcount].
       version_id = crt.report_template_id,
       reply->template_infos[lcount].name = crt.template_name, reply->template_infos[lcount].
       active_ind = crt.active_ind, reply->template_infos[lcount].updt_cnt = crt.updt_cnt,
       reply->template_infos[lcount].updt_id = crt.updt_id, reply->template_infos[lcount].updt_dt_tm
        = cnvtdatetime(crt.updt_dt_tm), reply->template_infos[lcount].facesheet_id = crt.facesheet_id,
       reply->template_infos[lcount].portrait_watermark_id = crt.portrait_watermark_id, reply->
       template_infos[lcount].landscape_watermark_id = crt.landscape_watermark_id, reply->
       template_infos[lcount].lab_legend_id = crt.lab_legend_id,
       reply->template_infos[lcount].micro_legend_id = crt.micro_legend_id, reply->template_infos[
       lcount].pat_care_legend_id = crt.pat_care_legend_id, reply->template_infos[lcount].
       summary_type_cd = crt.summary_type_cd
       IF ((request->template_modes[lindex].version_mode=nworking_version))
        reply->template_infos[lcount].version_dt_tm = cnvtdatetime(crt.updt_dt_tm)
       ELSEIF ((request->template_modes[lindex].version_mode=npublished_version))
        reply->template_infos[lcount].version_dt_tm = cnvtdatetime(ctp.publish_dt_tm), reply->
        template_infos[lcount].publish_updt_id = ctp.updt_id, reply->template_infos[lcount].
        publish_dt_tm = cnvtdatetime(ctp.publish_dt_tm)
       ELSEIF ((request->template_modes[lindex].version_mode=npub_date_range))
        reply->template_infos[lcount].version_dt_tm = cnvtdatetime(request->template_modes[lindex].
         prev_version_dt_tm), reply->template_infos[lcount].publish_updt_id = pub.updt_id, reply->
        template_infos[lcount].publish_dt_tm = cnvtdatetime(pub.publish_dt_tm)
       ELSE
        reply->template_infos[lcount].version_dt_tm = cnvtdatetime(request->template_modes[lindex].
         prev_version_dt_tm)
       ENDIF
       IF ((request->load_latest_publish_dt_tm=1))
        reply->template_infos[lcount].latest_publish_dt_tm = cnvtdatetime(ctp.publish_dt_tm)
       ENDIF
       IF ((request->load_xml_ind=1))
        xoffset = 0, xretlen = 1
        WHILE (xretlen > 0)
          xretlen = blobget(xoutbuf,xoffset,lt.long_text)
          IF (xretlen=size(xoutbuf))
           reply->template_infos[lcount].xml_detail = notrim(concat(reply->template_infos[lcount].
             xml_detail,xoutbuf))
          ELSEIF (xretlen > 0)
           reply->template_infos[lcount].xml_detail = trim(concat(substring(1,xoffset,reply->
              template_infos[lcount].xml_detail),xoutbuf))
          ENDIF
          xoffset += xretlen
        ENDWHILE
       ENDIF
      DETAIL
       IF ((request->template_modes[lindex].version_mode=nworking_version))
        IF (cnvtdatetime(cts.beg_effective_dt_tm) > cnvtdatetime(reply->template_infos[lcount].
         version_dt_tm))
         reply->template_infos[lcount].version_dt_tm = cnvtdatetime(cts.beg_effective_dt_tm)
        ENDIF
       ENDIF
       IF ((request->load_relations_ind=1))
        reply->template_infos[lcount].related_style_profile = crt.report_style_profile_id, i = 0,
        sectionid = cts.section_id
        IF (sectionid > 0
         AND locateval(i,0,xsectcnt,sectionid,reply->template_infos[lcount].related_sections[i].
         section_id)=0)
         xsectcnt += 1
         IF (mod(xsectcnt,5)=1)
          stat = alterlist(reply->template_infos[lcount].related_sections,(xsectcnt+ 4))
         ENDIF
         reply->template_infos[lcount].related_sections[xsectcnt].section_id = cts.section_id, reply
         ->template_infos[lcount].related_sections[xsectcnt].sequence_nbr = cts.sequence_nbr, reply->
         template_infos[lcount].related_sections[xsectcnt].page_break_after_ind = cts
         .page_break_after_ind
        ENDIF
        j = 0, regionid = cts.static_region_id
        IF (regionid > 0
         AND locateval(j,0,xregioncnt,regionid,reply->template_infos[lcount].related_page_masters[j].
         page_master_id)=0)
         xregioncnt += 1
         IF (mod(xregioncnt,5)=1)
          stat = alterlist(reply->template_infos[lcount].related_page_masters,(xregioncnt+ 4))
         ENDIF
         reply->template_infos[lcount].related_page_masters[xregioncnt].page_master_id = cts
         .static_region_id
        ENDIF
       ENDIF
       IF (validate(request->load_positions_ind,0)=1)
        k = 0, positioncd = pos.position_cd
        IF (positioncd > 0.0
         AND locateval(k,0,xpositioncnt,positioncd,reply->template_infos[lcount].
         associated_positions[k].position_cd)=0)
         xpositioncnt += 1
         IF (mod(xpositioncnt,5)=1)
          stat = alterlist(reply->template_infos[lcount].associated_positions,(xpositioncnt+ 4))
         ENDIF
         reply->template_infos[lcount].associated_positions[xpositioncnt].position_cd = positioncd
        ENDIF
       ENDIF
      FOOT  crt.template_id
       stat = alterlist(reply->template_infos[lcount].related_page_masters,xregioncnt), stat =
       alterlist(reply->template_infos[lcount].related_sections,xsectcnt), stat = alterlist(reply->
        template_infos[lcount].associated_positions,xpositioncnt)
      WITH rdbarrayfetch = 1
     ;end select
     CALL error_and_zero_check(curqual,"RetrieveDetails",
      "CR_Report_Template table could not be read.  Exiting script.",1,0)
   ENDFOR
   CALL log_message("Exiting RetrieveTemplates subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (createpublishclause(lindex=i4) =null)
   CALL log_message("Entered CreatePublishClause.",log_level_debug)
   IF ((request->load_latest_publish_dt_tm=1))
    IF ((((request->template_modes[lindex].version_mode=nworking_version)) OR ((request->
    template_modes[lindex].version_mode=ndate_range))) )
     SET spublishclause =
     " ctp.template_id = outerjoin(crt.template_id) and ctp.active_ind = outerjoin(1)"
    ELSEIF ((request->template_modes[lindex].version_mode=npub_date_range))
     SET spublishclause = " ctp.template_id = crt.template_id and ctp.active_ind = 1"
    ELSE
     SET spublishclause = " ctp.template_publish_id > 0"
    ENDIF
   ELSE
    SET spublishclause = " ctp.template_publish_id = 0.00"
   ENDIF
   CALL log_message(build("Exiting CreatePublishClause subroutine. sPublishClause = ",spublishclause),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE (createqualclause(lindex=i4) =null)
   CALL log_message("Entered CreateQualClause subroutine.",log_level_debug)
   CASE (request->template_modes[lindex].version_mode)
    OF nworking_version:
     SET squalclause = "EXPAND(lIdx, lStartIdx, lEndIdx, crt.report_template_id,"
     SET squalclause = concat(squalclause,
      " request->template_modes[lIndex]->template_ids[lIdx].id) and")
     SET squalclause = concat(squalclause," crt.report_template_id > 0")
    OF npublished_version:
     SET squalclause = "EXPAND(lIdx, lStartIdx, lEndIdx, ctp.template_id,"
     SET squalclause = concat(squalclause,
      " request->template_modes[lIndex]->template_ids[lIdx].id) and")
     SET squalclause = concat(squalclause,"	ctp.active_ind = 1")
    OF ndate_range:
     SET squalclause = "EXPAND(lIdx, lStartIdx, lEndIdx, crt.template_id,"
     SET squalclause = concat(squalclause,
      " request->template_modes[lIndex]->template_ids[lIdx].id) and")
     SET squalclause = concat(squalclause," crt.template_id > 0 and")
     SET squalclause = concat(squalclause," crt.beg_effective_dt_tm")
     SET squalclause = concat(squalclause,
      " <= cnvtdatetime(request->template_modes[lIndex]->prev_version_dt_tm) and")
     SET squalclause = concat(squalclause," crt.end_effective_dt_tm")
     SET squalclause = concat(squalclause,
      " > cnvtdatetime(request->template_modes[lIndex]->prev_version_dt_tm)")
    OF npub_date_range:
     SET squalclause = "EXPAND(lIdx, lStartIdx, lEndIdx, pub.template_id,"
     SET squalclause = concat(squalclause,
      " request->template_modes[lIndex]->template_ids[lIdx].id) and")
     SET squalclause = concat(squalclause,"	pub.beg_effective_dt_tm")
     SET squalclause = concat(squalclause,
      " <= cnvtdatetime(request->template_modes[lIndex]->prev_version_dt_tm) and")
     SET squalclause = concat(squalclause," pub.end_effective_dt_tm")
     SET squalclause = concat(squalclause,
      " > cnvtdatetime(request->template_modes[lIndex]->prev_version_dt_tm)")
    ELSE
     CALL populate_subeventstatus("QualClause","F","unsupported version_mode",cnvtstring(request->
       template_modes[lindex].version_mode))
     GO TO exit_script
   ENDCASE
   CALL log_message(build("Exiting CreateQualClause subroutine. sQualClause = ",squalclause),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE (createrelationsclause(lindex=i4) =null)
   CALL log_message("Entered CreateRelationsClause.",log_level_debug)
   IF ((request->template_modes[lindex].version_mode=nworking_version))
    SET srelationsclause =
    " cts.template_id = outerjoin(crt.template_id) and cts.active_ind = outerjoin(1)"
   ELSEIF ((request->load_relations_ind=1))
    IF ((request->template_modes[lindex].version_mode=npublished_version))
     SET srelationsclause = " cts.template_id = outerjoin(ctp.template_id)"
     SET srelationsclause = concat(srelationsclause,
      " and cts.beg_effective_dt_tm <= outerjoin(ctp.publish_dt_tm)")
     SET srelationsclause = concat(srelationsclause,
      " and cts.end_effective_dt_tm > outerjoin(ctp.publish_dt_tm)")
    ELSEIF ((request->template_modes[lindex].version_mode=npub_date_range))
     SET srelationsclause = " cts.template_id = outerjoin(pub.template_id)"
     SET srelationsclause = concat(srelationsclause,
      " and cts.beg_effective_dt_tm <= outerjoin(pub.publish_dt_tm)")
     SET srelationsclause = concat(srelationsclause,
      " and cts.end_effective_dt_tm > outerjoin(pub.publish_dt_tm)")
    ELSE
     SET srelationsclause = " cts.template_id = outerjoin(crt.template_id)"
     SET srelationsclause = concat(srelationsclause," and cts.beg_effective_dt_tm <= outerjoin(")
     SET srelationsclause = concat(srelationsclause,
      "cnvtdatetime(request->template_modes[lIndex]->prev_version_dt_tm))")
     SET srelationsclause = concat(srelationsclause," and cts.end_effective_dt_tm > outerjoin(")
     SET srelationsclause = concat(srelationsclause,
      "cnvtdatetime(request->template_modes[lIndex]->prev_version_dt_tm))")
    ENDIF
   ELSE
    SET srelationsclause = " cts.template_snapshot_id = 0"
   ENDIF
   CALL log_message(build("Exiting CreateRelationsClause subroutine. sRelationsClause = ",
     srelationsclause),log_level_debug)
 END ;Subroutine
 SUBROUTINE (createpositionsclause(lindex=i4) =null)
   CALL log_message("Entered CreatePositionsClause.",log_level_debug)
   IF ((request->load_positions_ind=1))
    IF ((request->template_modes[lindex].version_mode=nworking_version))
     SET spositionsclause =
     " pos.template_id = outerjoin(crt.template_id) and pos.active_ind = outerjoin(1)"
    ELSEIF ((request->template_modes[lindex].version_mode=npublished_version))
     SET spositionsclause = " pos.template_id = outerjoin(ctp.template_id)"
     SET spositionsclause = concat(spositionsclause,
      " and pos.beg_effective_dt_tm <= outerjoin(ctp.publish_dt_tm)")
     SET spositionsclause = concat(spositionsclause,
      " and pos.end_effective_dt_tm > outerjoin(ctp.publish_dt_tm)")
    ELSEIF ((request->template_modes[lindex].version_mode=npub_date_range))
     SET spositionsclause = " pos.template_id = outerjoin(pub.template_id)"
     SET spositionsclause = concat(spositionsclause,
      " and pos.beg_effective_dt_tm <= outerjoin(pub.publish_dt_tm)")
     SET spositionsclause = concat(spositionsclause,
      " and pos.end_effective_dt_tm > outerjoin(pub.publish_dt_tm)")
    ELSE
     SET spositionsclause = " pos.template_id = outerjoin(crt.template_id)"
     SET spositionsclause = concat(spositionsclause," and pos.beg_effective_dt_tm <= outerjoin(")
     SET spositionsclause = concat(spositionsclause,
      "cnvtdatetime(request->template_modes[lIndex]->prev_version_dt_tm))")
     SET spositionsclause = concat(spositionsclause," and pos.end_effective_dt_tm > outerjoin(")
     SET spositionsclause = concat(spositionsclause,
      "cnvtdatetime(request->template_modes[lIndex]->prev_version_dt_tm))")
    ENDIF
   ELSE
    SET spositionsclause = " pos.template_id = 0"
   ENDIF
   CALL log_message(build("Exiting CreatePositionsClause subroutine. sPositionsClause = ",
     spositionsclause),log_level_debug)
 END ;Subroutine
 SUBROUTINE createxmlclause(null)
   CALL log_message("Entered CreateXMLClause.",log_level_debug)
   IF ((request->load_xml_ind=1))
    SET sxmlclause = " lt.long_text_id = crt.long_text_id"
   ELSE
    SET sxmlclause = " lt.long_text_id = 0.00"
   ENDIF
   CALL log_message(build("Exiting CreateXMLClause subroutine. sXMLClause = ",sxmlclause),
    log_level_debug)
 END ;Subroutine
 IF (size(reply->template_infos,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
 CALL log_message(build("End of script: cr_get_report_templates.  # Templates: ",size(reply->
    template_infos,5)),log_level_debug)
END GO
