CREATE PROGRAM aps_build_signature_line:dba
 IF ((request->called_ind != "Y"))
  RECORD reply(
    1 qual[*]
      2 signature_line = vc
    1 signature_line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE bretrievedprsnldata = i2
 DECLARE cnt_qualified = i2
 DECLARE cur_col_pos = i2
 DECLARE cur_row = i2
 DECLARE cur_row_pos = i2
 DECLARE iapiip = i2
 DECLARE ibsldr = i2
 DECLARE igpip = i2
 DECLARE igvd = i2
 DECLARE isection = i2
 DECLARE max_cols = i2
 DECLARE nprsnlitem = i2
 DECLARE prsnl_cnt = i2
 DECLARE prsnl_ind = i2
 DECLARE resi_ind = i2
 DECLARE resi_prsnl_id = f8
 DECLARE return_string = vc
 DECLARE return_val = i2
 DECLARE screener_cnt = i2
 DECLARE section_cnt = i2
 DECLARE status_flag = i2
 DECLARE date_example = vc
 DECLARE findpt = i2
 DECLARE deflength = i2
 DECLARE date_mask = c100
 DECLARE time_mask = c100
 DECLARE time_now = c100
 DECLARE date_now = c100
 DECLARE zone_now = c100
 DECLARE nlocadloaded = i4 WITH protect, noconstant(0)
 DECLARE nlocphloaded = i4 WITH protect, noconstant(0)
 DECLARE retrievelocationinfo(cloadtype=c2) = null WITH protect
 RECORD prsnl_info(
   1 qual[*]
     2 prsnl_id = f8
     2 initials = c3
     2 name_full = c100
     2 name_first = c100
     2 name_middle = c100
     2 name_last = c100
     2 name_title = c100
 )
 RECORD tempdate(
   1 date_now = dq8
   1 date_tz = i4
 )
 RECORD req_srv_rsrc_tz(
   1 qual[*]
     2 service_resource_cd = f8
 )
 RECORD rep_srv_rsrc_tz(
   1 qual[*]
     2 service_resource_cd = f8
     2 facility_tz = i4
 )
 RECORD temp_hold_date(
   1 date_value = dq8
 )
 DECLARE time_zone_err_msg = vc WITH protect, noconstant("")
 DECLARE addtimezonerequest(service_resource_cd=f8) = null
 SUBROUTINE addtimezonerequest(service_resource_cd)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE size_rep = i4 WITH protect, noconstant(0)
   DECLARE size_req = i4 WITH protect, noconstant(0)
   SET size_rep = size(rep_srv_rsrc_tz->qual,5)
   SET size_req = size(req_srv_rsrc_tz->qual,5)
   FOR (idx = 1 TO size_rep)
     IF ((service_resource_cd=rep_srv_rsrc_tz->qual[idx].service_resource_cd))
      RETURN
     ENDIF
   ENDFOR
   FOR (idx = 1 TO size_req)
     IF ((service_resource_cd=req_srv_rsrc_tz->qual[idx].service_resource_cd))
      RETURN
     ENDIF
   ENDFOR
   SET size_req = (size_req+ 1)
   SET stat = alterlist(req_srv_rsrc_tz->qual,size_req)
   SET req_srv_rsrc_tz->qual[size_req].service_resource_cd = service_resource_cd
 END ;Subroutine
 DECLARE getrequestedtimezone(service_resource_cd=f8) = i4
 SUBROUTINE getrequestedtimezone(service_resource_cd)
   DECLARE idx = i4 WITH protect, noconstant(0)
   FOR (idx = 1 TO size(rep_srv_rsrc_tz->qual,5))
     IF ((rep_srv_rsrc_tz->qual[idx].service_resource_cd=service_resource_cd))
      RETURN(rep_srv_rsrc_tz->qual[idx].facility_tz)
     ENDIF
   ENDFOR
   RETURN(curtimezoneapp)
 END ;Subroutine
 DECLARE loadrequestedtimezone() = i4
 SUBROUTINE loadrequestedtimezone(null)
   DECLARE lapp_num = i4 WITH protect, constant(5000)
   DECLARE ltask_num = i4 WITH protect, constant(1050001)
   DECLARE lreq_num = i4 WITH protect, constant(1050064)
   DECLARE ecrmok = i2 WITH protect, constant(0)
   DECLARE happ = i4 WITH protect, noconstant(0)
   DECLARE htask = i4 WITH protect, noconstant(0)
   DECLARE hstep = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hrep = i4 WITH protect, noconstant(0)
   DECLARE hstatusdata = i4 WITH protect, noconstant(0)
   DECLARE ncrmstat = i2 WITH protect, noconstant(0)
   DECLARE nsrvstat = i2 WITH protect, noconstant(0)
   DECLARE sstatus = c1 WITH protect, noconstant(" ")
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE size_req = i4 WITH protect, noconstant(0)
   SET size_req = size(req_srv_rsrc_tz->qual,5)
   IF (size_req=0)
    RETURN(1)
   ELSE
    SET ncrmstat = uar_crmbeginapp(lapp_num,happ)
    IF (((ncrmstat != ecrmok) OR (happ=0)) )
     SET time_zone_err_msg = build("CrmBeginApp returned:",ncrmstat)
     RETURN(0)
    ENDIF
    SET ncrmstat = uar_crmbegintask(happ,ltask_num,htask)
    IF (((ncrmstat != ecrmok) OR (htask=0)) )
     SET time_zone_err_msg = build("CrmBeginTask returned:",ncrmstat)
     CALL exit_1050064(happ,htask,hreq)
     RETURN(0)
    ENDIF
    FOR (idx = 1 TO size_req)
      SET ncrmstat = uar_crmbeginreq(htask,0,lreq_num,hstep)
      IF (((ncrmstat != ecrmok) OR (hstep=0)) )
       SET time_zone_err_msg = build("CrmBeginReq returned:",ncrmstat)
       CALL exit_1050064(happ,htask,hreq)
       RETURN(0)
      ENDIF
      SET hreq = uar_crmgetrequest(hstep)
      IF (hreq=0)
       SET time_zone_err_msg = build("CrmGetRequest returned:",ncrmstat)
       CALL exit_1050064(happ,htask,hreq)
       RETURN(0)
      ENDIF
      SET nsrvstat = uar_srvsetdouble(hreq,"service_resource_cd",req_srv_rsrc_tz->qual[idx].
       service_resource_cd)
      SET ncrmstat = uar_crmperform(hstep)
      IF (ncrmstat=ecrmok)
       SET hrep = uar_crmgetreply(hstep)
       SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
       SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
       IF (sstatus="S")
        SET stat = alterlist(rep_srv_rsrc_tz->qual,(size(rep_srv_rsrc_tz->qual,5)+ 1))
        SET rep_srv_rsrc_tz->qual[size(rep_srv_rsrc_tz->qual,5)].facility_tz = uar_srvgetdouble(hrep,
         "time_zone")
        SET rep_srv_rsrc_tz->qual[size(rep_srv_rsrc_tz->qual,5)].service_resource_cd =
        req_srv_rsrc_tz->qual[idx].service_resource_cd
        IF (hreq != 0)
         SET ncrmstat = uar_crmendreq(hstep)
        ENDIF
       ELSE
        SET time_zone_err_msg = build("CrmGetReply returned:",ncrmstat)
        CALL exit_1050064(happ,htask,hreq)
        RETURN(0)
       ENDIF
      ELSE
       SET time_zone_err_msg = build("CrmPerform returned:",ncrmstat)
       CALL exit_1050064(happ,htask,hreq)
       RETURN(0)
      ENDIF
    ENDFOR
    CALL exit_1050064(happ,htask,hreq)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE exit_1050064(happ,htask,hreq)
   IF (hreq != 0)
    SET ncrmstat = uar_crmendreq(hstep)
   ENDIF
   IF (htask != 0)
    SET ncrmstat = uar_crmendtask(htask)
   ENDIF
   IF (happ != 0)
    SET ncrmstat = uar_crmendapp(happ)
   ENDIF
 END ;Subroutine
 DECLARE gettimezoneshortname(tz=i4) = vc
 SUBROUTINE gettimezoneshortname(tz)
   DECLARE offset = i4 WITH protect, noconstant(0)
   DECLARE daylight = i4 WITH protect, noconstant(0)
   DECLARE short_name = vc WITH protect, noconstant("")
   IF ((temp_hold_date->date_value > 0.0))
    SET short_name = datetimezonebyindex(tz,offset,daylight,7,temp_hold_date->date_value)
   ELSE
    SET short_name = datetimezonebyindex(tz,offset,daylight,7)
   ENDIF
   RETURN(short_name)
 END ;Subroutine
 DECLARE gettimezoneerrmsg() = vc
 SUBROUTINE gettimezoneerrmsg(null)
   RETURN(time_zone_err_msg)
 END ;Subroutine
 RECORD temp(
   1 qual[*]
     2 line_nbr = i4
     2 column_pos = i4
     2 meaning = c12
     2 literal_display = vc
     2 max_size = i4
     2 literal_size = i4
     2 format_desc = c60
     2 suppress_line_ind = i2
 )
 RECORD location_info(
   1 name = vc
   1 street_addr = vc
   1 street_addr2 = vc
   1 street_addr3 = vc
   1 street_addr4 = vc
   1 city = vc
   1 state = vc
   1 zip = c25
   1 county = vc
   1 country = vc
   1 phone = vc
   1 fax_phone = vc
 )
 SET iapiip = 0
 SET ibsldr = 0
 SET igpip = 0
 SET igvd = 0
 SET isection = 0
 SET bretrievedprsnldata = 0
 SET cnt_qualified = 0
 SET cur_row = 0
 SET cur_row_pos = 0
 SET cur_col_pos = 0
 SET max_cols = 0
 SET nprsnlitem = 0
 SET prsnl_cnt = 0
 SET prsnl_ind = 0
 SET resi_ind = 0
 SET resi_prsnl_id = 0.0
 SET return_string = ""
 SET return_val = 0
 SET section_cnt = 0
 SET screener_cnt = 0
 SET status_flag = 0
 SET date_mask = fillstring(100," ")
 SET time_mask = fillstring(100," ")
 SET time_now = fillstring(100," ")
 SET zone_now = fillstring(200," ")
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].operationstatus)))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].targetobjectname)))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].targetobjectvalue)))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt = (lglbslsubeventcnt+ 1)
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
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
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "APS_BUILD_SIGNATURE_LINE"
 SET reply->status_data.status = "F"
 IF ((request->status_mean IN ("VERIFIED", "CORRECTED", "CSIGNINPROC", "SIGNINPROC")))
  SET status_flag = 2
 ELSE
  SET status_flag = 1
 ENDIF
 SET section_cnt = size(request->section_qual,5)
 SET stat = alterlist(reply->qual,section_cnt)
 FOR (isection = 1 TO section_cnt)
   SET stat = alterlist(request->row_qual,0)
   SET request->max_cols = 0
   SET request->called_ind = "Y"
   SET return_val = getformatforsection(status_flag)
   IF (return_val > 0)
    IF (prsnl_ind=1)
     CALL retrieveprsnlinfo(0)
    ENDIF
    CALL buildsldatarequest(return_val)
    EXECUTE aps_get_signature_line
    SET reply->qual[isection].signature_line = reply->signature_line
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 DECLARE getformatforsection(gffsstatus_flag) = i2
 SUBROUTINE getformatforsection(gffsstatus_flag)
   CALL echo("Just entered GetFormatForSection...")
   SET cnt_qualified = 0
   SET stat = alterlist(temp->qual,0)
   SELECT INTO "nl:"
    sldr.task_assay_cd, sldr.status_flag, slf.format_id,
    slfd.format_id, slfd.sequence, cv.cdf_meaning,
    format_desc = uar_get_code_description(slfd.data_element_format_cd)
    FROM code_value cv1,
     sign_line_dta_r sldr,
     sign_line_format slf,
     sign_line_format_detail slfd,
     code_value cv
    PLAN (cv1
     WHERE cv1.code_set=5801
      AND cv1.cdf_meaning="APREPORT"
      AND cv1.active_ind=1)
     JOIN (sldr
     WHERE (sldr.task_assay_cd=request->section_qual[isection].task_assay_cd)
      AND sldr.status_flag IN (gffsstatus_flag, 0)
      AND sldr.activity_subtype_cd=cv1.code_value)
     JOIN (slf
     WHERE sldr.format_id=slf.format_id
      AND slf.active_ind=1)
     JOIN (slfd
     WHERE sldr.format_id=slfd.format_id)
     JOIN (cv
     WHERE slfd.data_element_cd=cv.code_value)
    ORDER BY slfd.format_id DESC, sldr.task_assay_cd DESC, sldr.status_flag DESC,
     slfd.sequence
    HEAD REPORT
     cnt = 0, cnt_qualified = 0, temp_status_flag = 0,
     temp_task_assay_cd = 0.0
    DETAIL
     cnt = (cnt+ 1)
     IF (cnt=1)
      temp_task_assay_cd = sldr.task_assay_cd, temp_status_flag = sldr.status_flag
     ENDIF
     IF (sldr.task_assay_cd=temp_task_assay_cd
      AND sldr.status_flag=temp_status_flag)
      cnt_qualified = (cnt_qualified+ 1)
      IF (mod(cnt_qualified,10)=1)
       stat = alterlist(temp->qual,(cnt_qualified+ 9))
      ENDIF
      temp->qual[cnt_qualified].line_nbr = slfd.line_nbr, temp->qual[cnt_qualified].suppress_line_ind
       = slfd.suppress_line_ind, temp->qual[cnt_qualified].column_pos = slfd.column_pos
      IF (cv.code_value != 0.0)
       temp->qual[cnt_qualified].meaning = cv.cdf_meaning
      ELSE
       temp->qual[cnt_qualified].meaning = ""
      ENDIF
      temp->qual[cnt_qualified].literal_display = slfd.literal_display, temp->qual[cnt_qualified].
      max_size = slfd.max_size, temp->qual[cnt_qualified].literal_size = slfd.literal_size
      IF (cv.code_value != 0.0
       AND  NOT (cv.cdf_meaning IN ("APPERFORMDT", "APVERIFYDT")))
       prsnl_ind = 1
       IF (cv.cdf_meaning IN ("APRESIFNAME", "APRESIINIT", "APRESILNAME", "APRESIMNAME", "APRESINAME",
       "APRESITITLE"))
        resi_ind = 1
       ENDIF
      ENDIF
      temp->qual[cnt_qualified].format_desc = format_desc
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->qual,cnt_qualified)
    WITH nocounter
   ;end select
   RETURN(cnt_qualified)
 END ;Subroutine
 SUBROUTINE addprsnlinfoitem(apiiprsnlid)
   IF (apiiprsnlid != 0)
    SET nprsnlitem = 0
    SET iapiip = 1
    WHILE (iapiip <= prsnl_cnt
     AND nprsnlitem=0)
     IF ((apiiprsnlid=prsnl_info->qual[iapiip].prsnl_id))
      SET nprsnlitem = iapiip
     ENDIF
     SET iapiip = (iapiip+ 1)
    ENDWHILE
    IF (nprsnlitem=0)
     SET prsnl_cnt = (prsnl_cnt+ 1)
     SET stat = alterlist(prsnl_info->qual,prsnl_cnt)
     SET prsnl_info->qual[prsnl_cnt].prsnl_id = apiiprsnlid
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getprsnlinfobyid(gpiprsnlid)
  SET nprsnlitem = 0
  IF (gpiprsnlid != 0)
   SET igpip = 1
   WHILE (igpip <= prsnl_cnt
    AND nprsnlitem=0)
    IF ((gpiprsnlid=prsnl_info->qual[igpip].prsnl_id))
     SET nprsnlitem = igpip
    ENDIF
    SET igpip = (igpip+ 1)
   ENDWHILE
  ENDIF
 END ;Subroutine
 SUBROUTINE retrieveprsnlinfo(rpidummy)
   IF (bretrievedprsnldata=0)
    SET screener_cnt = size(request->screener_qual,5)
    CALL addprsnlinfoitem(request->verified_prsnl_id)
    CALL addprsnlinfoitem(request->proxy_prsnl_id)
    FOR (ib = 1 TO section_cnt)
     CALL addprsnlinfoitem(request->section_qual[ib].dictating_prsnl_id)
     CALL addprsnlinfoitem(request->section_qual[ib].trans_prsnl_id)
    ENDFOR
    FOR (ib = 1 TO screener_cnt)
      CALL addprsnlinfoitem(request->screener_qual[ib].screener_id)
    ENDFOR
    IF (resi_ind=1)
     SELECT INTO "nl:"
      pc.responsible_resident_id
      FROM pathology_case pc
      WHERE (request->case_id=pc.case_id)
       AND  NOT (pc.responsible_resident_id IN (0, null))
      DETAIL
       resi_prsnl_id = pc.responsible_resident_id,
       CALL addprsnlinfoitem(resi_prsnl_id)
      WITH nocounter
     ;end select
    ENDIF
    IF (prsnl_cnt > 0)
     SELECT INTO "nl:"
      d.seq, pn.person_id
      FROM code_value cv,
       person_name pn,
       (dummyt d  WITH seq = value(prsnl_cnt))
      PLAN (cv
       WHERE cv.code_set=213
        AND cv.cdf_meaning="PRSNL"
        AND cv.active_ind=1)
       JOIN (d)
       JOIN (pn
       WHERE (prsnl_info->qual[d.seq].prsnl_id=pn.person_id)
        AND cv.code_value=pn.name_type_cd
        AND pn.active_ind=1
        AND pn.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (pn.end_effective_dt_tm=
       null)) )
      DETAIL
       prsnl_info->qual[d.seq].initials = substring(1,3,pn.name_initials), prsnl_info->qual[d.seq].
       name_full = trim(pn.name_full), prsnl_info->qual[d.seq].name_first = trim(pn.name_first),
       prsnl_info->qual[d.seq].name_middle = trim(pn.name_middle), prsnl_info->qual[d.seq].name_last
        = trim(pn.name_last), prsnl_info->qual[d.seq].name_title = trim(pn.name_title)
      WITH nocounter
     ;end select
    ENDIF
    SET bretrievedprsnldata = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE buildsldatarequest(bsldrcnt)
   CALL echo("Just entered BuildSLDataRequest...")
   SET cur_row_pos = 0
   SET cur_row = 0
   SET max_cols = 0
   FOR (ibsldr = 1 TO bsldrcnt)
     SET return_string = ""
     IF ((temp->qual[ibsldr].line_nbr != cur_row))
      SET cur_row_pos = (cur_row_pos+ 1)
      SET cur_row = temp->qual[ibsldr].line_nbr
      SET cur_col_pos = 1
      SET stat = alterlist(request->row_qual,cur_row_pos)
      SET stat = alterlist(request->row_qual[cur_row_pos].col_qual,cur_col_pos)
      SET request->row_qual[cur_row_pos].line_num = temp->qual[ibsldr].line_nbr
      SET request->row_qual[cur_row_pos].suppress_line_ind = temp->qual[ibsldr].suppress_line_ind
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].position = temp->qual[ibsldr].
      column_pos
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].max_size = temp->qual[ibsldr].max_size
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_size = temp->qual[ibsldr].
      literal_size
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[ibsldr].
      literal_display
      IF (trim(temp->qual[ibsldr].meaning) != "")
       CALL getvaluedata(trim(temp->qual[ibsldr].meaning),temp->qual[ibsldr].format_desc)
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].value = trim(return_string)
       IF (textlen(trim(return_string))=0)
        SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = ""
       ELSE
        SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[ibsldr]
        .literal_display
       ENDIF
      ENDIF
     ELSE
      SET cur_col_pos = (cur_col_pos+ 1)
      SET stat = alterlist(request->row_qual[cur_row_pos].col_qual,cur_col_pos)
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].position = temp->qual[ibsldr].
      column_pos
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].max_size = temp->qual[ibsldr].max_size
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_size = temp->qual[ibsldr].
      literal_size
      SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[ibsldr].
      literal_display
      IF (trim(temp->qual[ibsldr].meaning) != "")
       CALL getvaluedata(trim(temp->qual[ibsldr].meaning),temp->qual[ibsldr].format_desc)
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].value = trim(return_string)
       IF (textlen(trim(return_string))=0)
        SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = ""
       ELSE
        SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[ibsldr]
        .literal_display
       ENDIF
      ENDIF
     ENDIF
     IF (cur_col_pos > max_cols)
      SET max_cols = cur_col_pos
     ENDIF
   ENDFOR
   SET request->max_cols = max_cols
 END ;Subroutine
 SUBROUTINE getvaluedata(gvdmeaning,formatdef)
  SET return_string = ""
  CASE (trim(gvdmeaning))
   OF "APRESIINIT":
    CALL getprsnlinfobyid(resi_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].initials
    ENDIF
   OF "APRESINAME":
    CALL getprsnlinfobyid(resi_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_full
    ENDIF
   OF "APRESIFNAME":
    CALL getprsnlinfobyid(resi_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_first
    ENDIF
   OF "APRESIMNAME":
    CALL getprsnlinfobyid(resi_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_middle
    ENDIF
   OF "APRESILNAME":
    CALL getprsnlinfobyid(resi_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_last
    ENDIF
   OF "APRESITITLE":
    CALL getprsnlinfobyid(resi_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_title
    ENDIF
   OF "APDICTINIT":
    CALL getprsnlinfobyid(request->section_qual[isection].dictating_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].initials
    ENDIF
   OF "APDICTNAME":
    CALL getprsnlinfobyid(request->section_qual[isection].dictating_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_full
    ENDIF
   OF "APDICTFNAME":
    CALL getprsnlinfobyid(request->section_qual[isection].dictating_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_first
    ENDIF
   OF "APDICTMNAME":
    CALL getprsnlinfobyid(request->section_qual[isection].dictating_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_middle
    ENDIF
   OF "APDICTLNAME":
    CALL getprsnlinfobyid(request->section_qual[isection].dictating_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_last
    ENDIF
   OF "APDICTTITLE":
    CALL getprsnlinfobyid(request->section_qual[isection].dictating_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_title
    ENDIF
   OF "APPERFORMDT":
    IF (textlen(trim(formatdef))=0)
     SET return_string = format(cnvtdatetime(request->section_qual[isection].perform_dt_tm),
      "@SHORTDATE")
    ELSE
     SET tempdate->date_now = request->section_qual[isection].perform_dt_tm
     SET action_type = 0.0
     SET stat = uar_get_meaning_by_codeset(21,"PERFORM",1,action_type)
     SET tempdate->date_tz = 0
     SELECT INTO "nl:"
      FROM clinical_event ce,
       ce_event_prsnl cep
      PLAN (ce
       WHERE (ce.parent_event_id=request->event_id)
        AND (ce.task_assay_cd=request->section_qual[isection].task_assay_cd)
        AND ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (cep
       WHERE cep.event_id=ce.event_id
        AND cep.action_type_cd=action_type
        AND cep.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND cep.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
      DETAIL
       tempdate->date_tz = cep.action_tz
      WITH nocounter
     ;end select
     CALL formatdatebymask(formatdef)
    ENDIF
    CALL echo(build("date_performed is: ",return_string))
   OF "APSIGNINIT":
    CALL getprsnlinfobyid(request->verified_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].initials
    ENDIF
   OF "APSIGNNAME":
    CALL getprsnlinfobyid(request->verified_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_full
    ENDIF
   OF "APSIGNFNAME":
    CALL getprsnlinfobyid(request->verified_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_first
    ENDIF
   OF "APSIGNMNAME":
    CALL getprsnlinfobyid(request->verified_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_middle
    ENDIF
   OF "APSIGNLNAME":
    CALL getprsnlinfobyid(request->verified_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_last
    ENDIF
   OF "APSIGNTITLE":
    CALL getprsnlinfobyid(request->verified_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_title
    ENDIF
   OF "APVERIFYDT":
    IF ((request->verified_prsnl_id != 0.0))
     IF (textlen(trim(formatdef))=0)
      SET return_string = format(cnvtdatetime(request->verified_dt_tm),"@SHORTDATE")
     ELSE
      SET tempdate->date_now = request->verified_dt_tm
      SET tempdate->date_tz = request->verified_tz
      CALL formatdatebymask(formatdef)
     ENDIF
    ENDIF
    CALL echo(build("date_verified is:",return_string))
   OF "APTRXINIT":
    CALL getprsnlinfobyid(request->section_qual[isection].trans_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].initials
    ENDIF
   OF "AP1SCRNINIT":
    IF (screener_cnt > 0)
     CALL getprsnlinfobyid(request->screener_qual[1].screener_id)
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    ENDIF
   OF "AP1SCRNNAME":
    IF (screener_cnt > 0)
     CALL getprsnlinfobyid(request->screener_qual[1].screener_id)
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_full
     ENDIF
    ENDIF
   OF "AP1SCRNFNAME":
    IF (screener_cnt > 0)
     CALL getprsnlinfobyid(request->screener_qual[1].screener_id)
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_first
     ENDIF
    ENDIF
   OF "AP1SCRNMNAME":
    IF (screener_cnt > 0)
     CALL getprsnlinfobyid(request->screener_qual[1].screener_id)
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_middle
     ENDIF
    ENDIF
   OF "AP1SCRNLNAME":
    IF (screener_cnt > 0)
     CALL getprsnlinfobyid(request->screener_qual[1].screener_id)
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_last
     ENDIF
    ENDIF
   OF "AP1SCRNTITLE":
    IF (screener_cnt > 0)
     CALL getprsnlinfobyid(request->screener_qual[1].screener_id)
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    ENDIF
   OF "APRESCRNINIT":
    FOR (igvd = 2 TO screener_cnt)
     CALL getprsnlinfobyid(request->screener_qual[igvd].screener_id)
     IF (nprsnlitem != 0)
      IF (igvd=2)
       SET return_string = prsnl_info->qual[nprsnlitem].initials
      ELSE
       SET return_string = concat(trim(return_string),",",prsnl_info->qual[nprsnlitem].initials)
      ENDIF
     ENDIF
    ENDFOR
   OF "APPROXFNAME":
    CALL getprsnlinfobyid(request->proxy_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_first
    ENDIF
   OF "APPROXINIT":
    CALL getprsnlinfobyid(request->proxy_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].initials
    ENDIF
   OF "APPROXLNAME":
    CALL getprsnlinfobyid(request->proxy_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_last
    ENDIF
   OF "APPROXMNAME":
    CALL getprsnlinfobyid(request->proxy_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_middle
    ENDIF
   OF "APPROXNAME":
    CALL getprsnlinfobyid(request->proxy_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_full
    ENDIF
   OF "APPROXTITLE":
    CALL getprsnlinfobyid(request->proxy_prsnl_id)
    IF (nprsnlitem != 0)
     SET return_string = prsnl_info->qual[nprsnlitem].name_title
    ENDIF
   OF "APSNLOCNM":
    CALL retrievelocationinfo("NM")
    SET return_string = location_info->name
   OF "APSNLOCAD1":
    CALL retrievelocationinfo("AD")
    SET return_string = location_info->street_addr
   OF "APSNLOCAD2":
    CALL retrievelocationinfo("AD")
    SET return_string = location_info->street_addr2
   OF "APSNLOCAD3":
    CALL retrievelocationinfo("AD")
    SET return_string = location_info->street_addr3
   OF "APSNLOCAD4":
    CALL retrievelocationinfo("AD")
    SET return_string = location_info->street_addr4
   OF "APSNLOCCTY":
    CALL retrievelocationinfo("AD")
    SET return_string = location_info->city
   OF "APSNLOCSTA":
    CALL retrievelocationinfo("AD")
    SET return_string = location_info->state
   OF "APSNLOCZIP":
    CALL retrievelocationinfo("AD")
    SET return_string = location_info->zip
   OF "APSNLOCCNTY":
    CALL retrievelocationinfo("AD")
    SET return_string = location_info->county
   OF "APSNLOCCTRY":
    CALL retrievelocationinfo("AD")
    SET return_string = location_info->country
   OF "APSNLOCPHN":
    CALL retrievelocationinfo("PH")
    SET return_string = location_info->phone
   OF "APSNLOCFAX":
    CALL retrievelocationinfo("PH")
    SET return_string = location_info->fax_phone
  ENDCASE
 END ;Subroutine
 SUBROUTINE formatdatebymask(formatdesc)
   SET deflength = 0
   SET findptf = 0
   SET findptl = 0
   SET findptc = 0
   SET return_string = ""
   SET findptf = findstring("|",formatdesc)
   IF (findptf=0)
    IF (curutc=1)
     SET findptc = findstring(";;D",formatdesc)
     IF (findptc != 0)
      SET formatdesc = substring(1,(findptc - 1),formatdesc)
     ENDIF
     SET return_string = datetimezoneformat(cnvtdatetime(tempdate->date_now),tempdate->date_tz,trim(
       formatdesc))
    ELSE
     SET return_string = format(tempdate->date_now,formatdesc)
    ENDIF
   ELSE
    SET findptl = findstring("|",formatdesc,1,1)
    SET deflength = textlen(trim(formatdesc))
    SET date_mask = substring(1,(findptf - 1),formatdesc)
    IF (findptl != findptf)
     SET time_mask = substring((findptf+ 1),((findptl - 1) - findptf),formatdesc)
     SET zone_mask = substring((findptl+ 1),deflength,formatdesc)
     SET temp_hold_date->date_value = tempdate->date_now
     SET zone_now = gettimezoneshortname(tempdate->date_tz)
    ELSE
     SET time_mask = substring((findptf+ 1),deflength,formatdesc)
    ENDIF
    IF (curutc=1)
     SET findptc = findstring(";3;S",time_mask)
     IF (findptc != 0)
      SET time_mask = build(cnvtlower(substring(2,(findptc - 2),time_mask))," tt")
     ENDIF
     SET findptc = findstring(";3;M",time_mask)
     IF (findptc != 0)
      SET time_mask = build(cnvtupper(substring(1,2,time_mask)),substring(3,(findptc - 3),time_mask))
     ENDIF
     SET time_now = datetimezoneformat(cnvtdatetime(tempdate->date_now),tempdate->date_tz,trim(
       time_mask))
    ELSE
     SET time_now = format(tempdate->date_now,time_mask)
     IF (substring(textlen(trim(time_mask)),textlen(trim(time_mask)),formatdesc)="S")
      IF (substring(1,1,time_now)="0")
       SET time_now = substring(2,textlen(time_now),time_now)
      ENDIF
     ENDIF
    ENDIF
    IF (curutc=1)
     SET findptc = findstring(";;D",date_mask)
     IF (findptc != 0)
      SET date_mask = substring(1,(findptc - 1),date_mask)
     ENDIF
     SET date_now = datetimezoneformat(cnvtdatetime(tempdate->date_now),tempdate->date_tz,trim(
       date_mask))
    ELSE
     SET date_now = format(tempdate->date_now,date_mask)
    ENDIF
    IF (findptl != findptf)
     SET return_string = concat(trim(date_now)," ",trim(time_now)," ",trim(zone_now))
    ELSE
     SET return_string = concat(trim(date_now)," ",trim(time_now))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE retrievelocationinfo(cloadtype)
   DECLARE dbusinessaddresscd = f8 WITH protect, noconstant(0.0)
   DECLARE dbusinessphonecd = f8 WITH protect, noconstant(0.0)
   DECLARE dbusinessfaxcd = f8 WITH protect, noconstant(0.0)
   IF ((request->signing_location_cd=0))
    RETURN
   ENDIF
   CASE (cloadtype)
    OF "NM":
     IF ((request->signing_location_cd != 0))
      SET location_info->name = uar_get_code_display(request->signing_location_cd)
      IF (size(trim(location_info->name))=0)
       CALL log_message("UAR failed on signing_location_cd",log_level_debug)
      ENDIF
     ENDIF
    OF "AD":
     IF (nlocadloaded=1)
      RETURN
     ENDIF
     SET dbusinessaddresscd = uar_get_code_by("MEANING",212,"BUSINESS")
     IF (dbusinessaddresscd=0)
      CALL log_message("UAR failed on BUSINESS, code set 212",log_level_debug)
      RETURN
     ENDIF
     SELECT INTO "nl:"
      FROM address a
      PLAN (a
       WHERE a.parent_entity_name="LOCATION"
        AND (a.parent_entity_id=request->signing_location_cd)
        AND a.address_type_cd=dbusinessaddresscd)
      DETAIL
       location_info->street_addr = a.street_addr, location_info->street_addr2 = a.street_addr2,
       location_info->street_addr3 = a.street_addr3,
       location_info->street_addr4 = a.street_addr4, location_info->city = a.city, location_info->
       state = a.state,
       location_info->zip = a.zipcode, location_info->county = a.county, location_info->country = a
       .country
      WITH nocounter
     ;end select
     SET nlocadloaded = 1
    OF "PH":
     IF (nlocphloaded=1)
      RETURN
     ENDIF
     SET dbusinessphonecd = uar_get_code_by("MEANING",43,"BUSINESS")
     SET dbusinessfaxcd = uar_get_code_by("MEANING",43,"FAX BUS")
     IF (dbusinessphonecd=0
      AND dbusinessfaxcd=0)
      CALL log_message("UAR failed on BUSINESS Phone, code set 43",log_level_debug)
      CALL log_message("UAR failed on FAX BUS phone, code set 43",log_level_debug)
      RETURN
     ENDIF
     SELECT INTO "nl:"
      phone = cnvtphone(p.phone_num,p.phone_format_cd,2)
      FROM phone p
      PLAN (p
       WHERE p.parent_entity_name="LOCATION"
        AND (p.parent_entity_id=request->signing_location_cd)
        AND p.phone_type_cd IN (dbusinessphonecd, dbusinessfaxcd)
        AND p.phone_type_cd != 0)
      DETAIL
       CASE (p.phone_type_cd)
        OF dbusinessphonecd:
         location_info->phone = phone
        OF dbusinessfaxcd:
         location_info->fax_phone = phone
       ENDCASE
      WITH nocounter
     ;end select
     SET nlocphloaded = 1
   ENDCASE
 END ;Subroutine
END GO
