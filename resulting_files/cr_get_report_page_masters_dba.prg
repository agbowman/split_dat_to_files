CREATE PROGRAM cr_get_report_page_masters:dba
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
 SET log_program_name = "cr_get_report_page_masters"
 CALL log_message("Starting script: cr_get_report_page_masters",log_level_debug)
 CALL echorecord(request)
 FREE RECORD reply
 RECORD reply(
   1 page_master_infos[*]
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
     2 related_orgs[*]
       3 organization_id = f8
     2 related_locations[*]
       3 location_cd = f8
     2 related_serv_rescs[*]
       3 service_resource_cd = f8
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
 DECLARE lpage_master_cnt = i4 WITH protect, constant(size(request->page_master_modes,5))
 DECLARE lcount = i4
 DECLARE squalclause = vc
 DECLARE sorgsclause = vc
 DECLARE slocationsclause = vc
 DECLARE sservrescsclause = vc
 DECLARE createorgsclause(null) = null
 DECLARE createlocationsclause(null) = null
 DECLARE createservrescsclause(null) = null
 SET reply->status_data.status = "F"
 SET lcount = 0
 CALL createorgsclause(null)
 CALL createlocationsclause(null)
 CALL createservrescsclause(null)
 IF (lpage_master_cnt > 0)
  FOR (lpmcount = 1 TO lpage_master_cnt)
    CALL retrievedetails(lpmcount)
  ENDFOR
 ENDIF
 SET stat = alterlist(reply->page_master_infos,lcount)
 SUBROUTINE (retrievedetails(lindex=i4) =null)
   CALL log_message("Entered RetrieveDetails subroutine.",log_level_debug)
   DECLARE lidx = i4
   DECLARE lstartidx = i4
   DECLARE lendidx = i4
   DECLARE lupperbound = i4
   SET lendidx = 0
   SET llistsize = size(request->page_master_modes[lindex].page_master_ids,5)
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
      FROM cr_report_static_region crsr,
       long_text_reference lt,
       cr_static_region_org_reltn csror,
       cr_static_region_loc_reltn csrlr,
       cr_static_region_sr_reltn csrsr
      PLAN (crsr
       WHERE parser(squalclause))
       JOIN (lt
       WHERE (lt.long_text_id=
       IF ((request->load_xml_ind=0)) 0.00
       ELSE crsr.long_text_id
       ENDIF
       ))
       JOIN (csror
       WHERE parser(sorgsclause))
       JOIN (csrlr
       WHERE parser(slocationsclause))
       JOIN (csrsr
       WHERE parser(sservrescsclause))
      HEAD REPORT
       xoutbuf = fillstring(4096," ")
      HEAD crsr.static_region_id
       xorgcnt = 0, xlocationcnt = 0, xserviceresourcecnt = 0,
       lcount += 1
       IF (mod(lcount,10)=1)
        stat = alterlist(reply->page_master_infos,(lcount+ 9))
       ENDIF
       reply->page_master_infos[lcount].version_mode = request->page_master_modes[lindex].
       version_mode, reply->page_master_infos[lcount].component_id = crsr.static_region_id, reply->
       page_master_infos[lcount].version_id = crsr.report_static_region_id,
       reply->page_master_infos[lcount].name = crsr.region_name, reply->page_master_infos[lcount].
       active_ind = crsr.active_ind, reply->page_master_infos[lcount].updt_cnt = crsr.updt_cnt,
       reply->page_master_infos[lcount].updt_id = crsr.updt_id, reply->page_master_infos[lcount].
       updt_dt_tm = cnvtdatetime(crsr.updt_dt_tm)
       IF ((request->page_master_modes[lindex].version_mode=nworking_version))
        reply->page_master_infos[lcount].version_dt_tm = cnvtdatetime(crsr.updt_dt_tm)
       ELSE
        reply->page_master_infos[lcount].version_dt_tm = cnvtdatetime(request->page_master_modes[
         lindex].prev_version_dt_tm)
       ENDIF
       IF ((request->load_xml_ind=1))
        xoffset = 0, xretlen = 1
        WHILE (xretlen > 0)
          xretlen = blobget(xoutbuf,xoffset,lt.long_text)
          IF (xretlen=size(xoutbuf))
           reply->page_master_infos[lcount].xml_detail = notrim(concat(reply->page_master_infos[
             lcount].xml_detail,xoutbuf))
          ELSEIF (xretlen > 0)
           reply->page_master_infos[lcount].xml_detail = trim(concat(substring(1,xoffset,reply->
              page_master_infos[lcount].xml_detail),xoutbuf))
          ENDIF
          xoffset += xretlen
        ENDWHILE
       ENDIF
      DETAIL
       IF (validate(request->load_orgs_ind,0)=1)
        num = 0, orgid = csror.organization_id
        IF (orgid > 0
         AND locateval(num,0,xorgcnt,orgid,reply->page_master_infos[lcount].related_orgs[num].
         organization_id)=0)
         xorgcnt += 1, stat = alterlist(reply->page_master_infos[lcount].related_orgs,xorgcnt), reply
         ->page_master_infos[lcount].related_orgs[xorgcnt].organization_id = orgid
        ENDIF
       ENDIF
       IF (validate(request->load_locations_ind,0)=1)
        num = 0, locationcd = csrlr.location_cd
        IF (locationcd > 0
         AND locateval(num,0,xlocationcnt,locationcd,reply->page_master_infos[lcount].
         related_locations[num].location_cd)=0)
         xlocationcnt += 1, stat = alterlist(reply->page_master_infos[lcount].related_locations,
          xlocationcnt), reply->page_master_infos[lcount].related_locations[xlocationcnt].location_cd
          = locationcd
        ENDIF
       ENDIF
       IF (validate(request->load_serv_rescs_ind,0)=1)
        num = 0, serviceresourcecd = csrsr.service_resource_cd
        IF (serviceresourcecd > 0
         AND locateval(num,0,xserviceresourcecnt,serviceresourcecd,reply->page_master_infos[lcount].
         related_serv_rescs[num].service_resource_cd)=0)
         xserviceresourcecnt += 1, stat = alterlist(reply->page_master_infos[lcount].
          related_serv_rescs,xserviceresourcecnt), reply->page_master_infos[lcount].
         related_serv_rescs[xserviceresourcecnt].service_resource_cd = serviceresourcecd
        ENDIF
       ENDIF
      FOOT  crsr.static_region_id
       do_nothing = 0
      WITH rdbarrayfetch = 1
     ;end select
     CALL error_and_zero_check(curqual,"RetrieveDetails",
      "CR_Report_Static_Region table could not be read.  Exiting script.",1,0)
   ENDFOR
   CALL log_message("Exiting RetrievePageMasters subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (createqualclause(lindex=i4) =null)
   CALL log_message("Entered CreateQualClause subroutine.",log_level_debug)
   CASE (request->page_master_modes[lindex].version_mode)
    OF nworking_version:
     SET squalclause = "EXPAND(lIdx, lStartIdx, lEndIdx, crsr.report_static_region_id,"
     SET squalclause = concat(squalclause,
      " request->page_master_modes[lIndex]->page_master_ids[lIdx].id) and")
     SET squalclause = concat(squalclause," crsr.report_static_region_id > 0")
    OF ndate_range:
     SET squalclause = "EXPAND(lIdx, lStartIdx, lEndIdx, crsr.static_region_id,"
     SET squalclause = concat(squalclause,
      " request->page_master_modes[lIndex]->page_master_ids[lIdx].id) and")
     SET squalclause = concat(squalclause," crsr.static_region_id > 0 and")
     SET squalclause = concat(squalclause," crsr.beg_effective_dt_tm")
     SET squalclause = concat(squalclause,
      " <= cnvtdatetime(request->page_master_modes[lIndex]->prev_version_dt_tm) and")
     SET squalclause = concat(squalclause," crsr.end_effective_dt_tm ")
     SET squalclause = concat(squalclause,
      "> cnvtdatetime(request->page_master_modes[lIndex]->prev_version_dt_tm)")
    ELSE
     CALL populate_subeventstatus("QualClause","F","unsupported version_mode",cnvtstring(request->
       page_master_modes[lindex].version_mode))
     GO TO exit_script
   ENDCASE
   CALL log_message(build("Exiting CreateQualClause subroutine. sQualClause = ",squalclause),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE createorgsclause(null)
   CALL log_message("Entered CreateOrgsClause.",log_level_debug)
   IF (validate(request->load_orgs_ind,0)=1)
    SET sorgsclause = " csror.static_region_id = outerjoin(crsr.static_region_id)"
    SET sorgsclause = concat(sorgsclause,
     " and csror.beg_effective_dt_tm <= outerjoin(crsr.beg_effective_dt_tm)")
    SET sorgsclause = concat(sorgsclause,
     " and csror.end_effective_dt_tm >= outerjoin(crsr.end_effective_dt_tm)")
   ELSE
    SET sorgsclause = " csror.cr_static_region_org_reltn_id = 0"
   ENDIF
   CALL log_message(build("Exiting CreateOrgsClause subroutine. sOrgsClause = ",sorgsclause),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE createlocationsclause(null)
   CALL log_message("Entered CreateLocationsClause.",log_level_debug)
   IF (validate(request->load_locations_ind,0)=1)
    SET slocationsclause = " csrlr.static_region_id = outerjoin(crsr.static_region_id)"
    SET slocationsclause = concat(slocationsclause,
     " and csrlr.beg_effective_dt_tm <= outerjoin(crsr.beg_effective_dt_tm)")
    SET slocationsclause = concat(slocationsclause,
     " and csrlr.end_effective_dt_tm >= outerjoin(crsr.end_effective_dt_tm)")
   ELSE
    SET slocationsclause = " csrlr.cr_static_region_loc_reltn_id = 0"
   ENDIF
   CALL log_message(build("Exiting CreateLocationsClause subroutine. sLocationsClause = ",
     slocationsclause),log_level_debug)
 END ;Subroutine
 SUBROUTINE createservrescsclause(null)
   CALL log_message("Entered CreateServRescsClause.",log_level_debug)
   IF (validate(request->load_serv_rescs_ind,0)=1)
    SET sservrescsclause = " csrsr.static_region_id = outerjoin(crsr.static_region_id)"
    SET sservrescsclause = concat(sservrescsclause,
     " and csrsr.beg_effective_dt_tm <= outerjoin(crsr.beg_effective_dt_tm)")
    SET sservrescsclause = concat(sservrescsclause,
     " and csrsr.end_effective_dt_tm >= outerjoin(crsr.end_effective_dt_tm)")
   ELSE
    SET sservrescsclause = " csrsr.cr_static_region_sr_reltn_id = 0"
   ENDIF
   CALL log_message(build("Exiting CreateServRescsClause subroutine. sServRescsClause = ",
     sservrescsclause),log_level_debug)
 END ;Subroutine
 IF (size(reply->page_master_infos,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("End of script: cr_get_report_page_masters",log_level_debug)
 CALL echorecord(reply)
END GO
