CREATE PROGRAM cr_get_report_requests_lite:dba
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
 SET log_program_name = "cr_get_report_requests_lite"
 DECLARE slogicaldomainawareclause = vc WITH noconstant("p.person_id = cr.person_id"), protect
 DECLARE squalclause = vc WITH noconstant(""), protect
 DECLARE sdateclause = vc WITH noconstant(""), protect
 DECLARE stemp = vc WITH noconstant(""), protect
 DECLARE sindexfound = c3 WITH noconstant("+0 "), protect
 DECLARE num_request_ids = i4 WITH noconstant(size(request->report_requests,5))
 DECLARE num_request_types = i4 WITH noconstant(size(request->request_types,5))
 DECLARE num_scopes = i4 WITH noconstant(size(request->scopes,5))
 DECLARE num_report_statuses = i4 WITH noconstant(size(request->report_statuses,5))
 DECLARE cross_encounter = i2 WITH constant(5)
 DECLARE event_scope = i2 WITH constant(6)
 DECLARE event_plus_scope = i2 WITH constant(7)
 DECLARE current_date_time = q8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE userlogicaldomain = f8 WITH noconstant(0), protect
 FREE RECORD route_flat_rec
 RECORD route_flat_rec(
   1 cnt = i4
   1 qual[*]
     2 route_id = f8
     2 request_seq = i4
 )
 FREE RECORD route_stop_flat_rec
 RECORD route_stop_flat_rec(
   1 cnt = i4
   1 qual[*]
     2 route_stop_id = f8
     2 request_seq = i4
 )
 FREE RECORD xencntr_flat_rec
 RECORD xencntr_flat_rec(
   1 cnt = i4
   1 qual[*]
     2 request_id = f8
     2 request_seq = i4
 )
 DECLARE createqualclause(null) = null
 DECLARE retrievereportrequestsbyids(null) = null
 DECLARE retrievereportrequestsbycriteria(null) = null
 DECLARE addreportrequestrow(null) = null
 DECLARE logicaldomainlookup(null) = null
 SUBROUTINE createqualclause(null)
   CALL log_message("Entering CreateQualClause",log_level_debug)
   SET squalclause = "cr.report_request_id > 0"
   IF ((request->parent_request_id > 0))
    CALL addqualsection(build("cr.parent_request_id=",request->parent_request_id))
   ENDIF
   IF (num_request_types > 0)
    SET stemp = "cr.request_type_flag in ("
    FOR (i = 1 TO (num_request_types - 1))
      SET stemp = build(stemp,request->request_types[i].request_type_flag,",")
    ENDFOR
    SET stemp = build(stemp,request->request_types[num_request_types].request_type_flag,")")
    CALL addqualsection(stemp)
   ENDIF
   IF (num_scopes > 0)
    SET stemp = "cr.scope_flag in ("
    FOR (i = 1 TO (num_scopes - 1))
      SET stemp = build(stemp,request->scopes[i].scope_flag,",")
    ENDFOR
    SET stemp = build(stemp,request->scopes[num_scopes].scope_flag,")")
    CALL addqualsection(stemp)
   ENDIF
   IF (num_report_statuses > 0)
    SET stemp = "cr.report_status_cd in ("
    FOR (i = 1 TO (num_report_statuses - 1))
      SET stemp = build(stemp,request->report_statuses[i].report_status_cd,",")
    ENDFOR
    SET stemp = build(stemp,request->report_statuses[num_report_statuses].report_status_cd,")")
    CALL addqualsection(stemp)
   ENDIF
   IF ((request->person_id > 0))
    CALL addqualsection(build("cr.person_id=",request->person_id))
    SET sindexfound = "+0 "
   ENDIF
   IF ((request->encntr_id > 0))
    CALL addqualsection(build("cr.encntr_id=",request->encntr_id))
    SET sindexfound = "+0 "
   ENDIF
   IF ((request->accession_nbr != null)
    AND size(trim(request->accession_nbr),1) > 0)
    CALL addqualsection(concat('cr.accession_nbr="',request->accession_nbr,'"'))
    SET sindexfound = "+0 "
   ENDIF
   IF ((request->request_prsnl_id > 0))
    CALL addqualsection(build("cr.request_prsnl_id=",request->request_prsnl_id))
   ENDIF
   IF ((request->provider_prsnl_id > 0))
    CALL addqualsection(build("cr.provider_prsnl_id=",request->provider_prsnl_id))
   ENDIF
   IF ((request->template_id > 0))
    CALL addqualsection(build("cr.template_id=",request->template_id))
   ENDIF
   IF ((request->page_cnt_threshold > 0))
    CALL addqualsection(build("cr.total_pages_nbr>=",request->page_cnt_threshold))
   ENDIF
   IF ((request->process_time_threshold > 0))
    CALL addqualsection(build("cr.processing_time>=",request->process_time_threshold))
   ENDIF
   IF ((request->trigger_name != null)
    AND size(trim(request->trigger_name),1) > 0)
    CALL addqualsection(concat('cr.trigger_name="',request->trigger_name,'"'))
   ENDIF
   IF ((request->chart_trigger_id > 0))
    CALL addqualsection(build("cr.chart_trigger_id=",request->chart_trigger_id))
   ENDIF
   IF ((request->distribution_id > 0))
    CALL addqualsection(build("cr.distribution_id=",request->distribution_id))
    IF ((request->dist_run_type_cd > 0))
     CALL addqualsection(build("cr.dist_run_type_cd=",request->dist_run_type_cd))
    ENDIF
   ENDIF
   IF ((((request->search_start_dt_tm > 0)) OR ((request->search_end_dt_tm > 0))) )
    IF ((request->search_start_dt_tm=0)
     AND (request->search_end_dt_tm > 0))
     SET sdateclause = concat("cr.request_dt_tm"," <= cnvtdatetime(request->search_end_dt_tm)")
    ELSEIF ((request->search_start_dt_tm > 0)
     AND (request->search_end_dt_tm=0))
     SET sdateclause = concat("cr.request_dt_tm"," >= cnvtdatetime(request->search_start_dt_tm)")
    ELSE
     SET sdateclause = concat("(cr.request_dt_tm",
      " between cnvtdatetime(request->search_start_dt_tm) ",
      " and cnvtdatetime(request->search_end_dt_tm))")
    ENDIF
    CALL addqualsection(sdateclause)
   ENDIF
   IF ((request->facility_id > 0))
    CALL addqualsection("((cr.encntr_id > 0 and cr.scope_flag != 1) or cr.scope_flag = 5)")
   ENDIF
   IF ((request->device_service_identifier != null)
    AND size(trim(request->device_service_identifier),1) > 0
    AND (request->device_output_dest_cd > 0))
    CALL addqualsection(concat("(cr.dms_service_ident = request->device_service_identifier",
      " or exists(select od2.report_request_id from cr_output_destination od2",
      " where od2.report_request_id = cr.report_request_id",
      " and od2.dms_service_ident = request->device_service_identifier))"," or",
      build(" (cr.output_dest_cd =",request->device_output_dest_cd),
      " or exists(select od2.report_request_id from cr_output_destination od2",
      " where od2.report_request_id = cr.report_request_id",build(" and od2.output_dest_cd =",request
       ->device_output_dest_cd),"))"))
   ELSEIF ((request->device_service_identifier != null)
    AND size(trim(request->device_service_identifier),1) > 0)
    DECLARE device_service_identifier = vc WITH noconstant(""), protect
    IF (trim(request->device_service_identifier)="@ADHOC@SECURE_EMAIL")
     SET device_service_identifier = "*@SECURE_EMAIL"
    ELSE
     SET device_service_identifier = trim(request->device_service_identifier)
    ENDIF
    CALL addqualsection(concat('(cr.dms_service_ident = "',device_service_identifier,'"',
      " or exists(select od2.report_request_id from cr_output_destination od2",
      " where od2.report_request_id = cr.report_request_id",
      ' and od2.dms_service_ident = "',device_service_identifier,'"))'))
   ENDIF
   IF ((request->patient_request_ind=1))
    CALL addqualsection("(cr.patient_request_ind = 1)")
   ENDIF
   IF ((request->concept_service_name != null)
    AND size(trim(request->concept_service_name),3) > 0)
    CALL addqualsection(build('cr.concept_service_name="',request->concept_service_name,'"'))
   ENDIF
   CALL echo(concat("sQualClause = ",squalclause))
   CALL log_message("Exiting CreateQualClause",log_level_debug)
 END ;Subroutine
 SUBROUTINE (addqualsection(squalportion=vc) =null)
   SET squalclause = concat(squalclause," and ",squalportion)
 END ;Subroutine
 SUBROUTINE retrievereportrequestsbyids(null)
   CALL log_message("Entering RetrieveReportRequestsByIds",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(num_request_ids)/ bind_cnt)) * bind_cnt
    )), protect
   DECLARE count = i4 WITH noconstant(0), protect
   SET stat = alterlist(request->report_requests,noptimizedtotal)
   FOR (i = (num_request_ids+ 1) TO noptimizedtotal)
     SET request->report_requests[i].report_request_id = request->report_requests[num_request_ids].
     report_request_id
   ENDFOR
   IF ((request->logical_domain_aware_ind=1))
    CALL logicaldomainlookup(null)
    SET slogicaldomainawareclause = concat(slogicaldomainawareclause," and ",
     "p.logical_domain_id = userLogicalDomain")
   ENDIF
   CALL echo(concat("sLogicalDomainAwareClause = ",slogicaldomainawareclause))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     cr_report_request cr,
     long_text lt1,
     cr_report_template rt,
     cr_output_destination od,
     person p
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cr.report_request_id,request->
      report_requests[idx].report_request_id,
      bind_cnt)
      AND cr.report_request_id > 0)
     JOIN (lt1
     WHERE lt1.long_text_id=cr.request_xml_id)
     JOIN (rt
     WHERE rt.report_template_id=cr.template_id)
     JOIN (od
     WHERE (od.report_request_id= Outerjoin(cr.report_request_id)) )
     JOIN (p
     WHERE parser(slogicaldomainawareclause))
    ORDER BY cr.report_request_id, od.cr_output_destination_id
    HEAD REPORT
     count = 0
    HEAD cr.report_request_id
     CALL addreportrequestrow(null)
    HEAD od.cr_output_destination_id
     CALL addoutputdestinations(null)
    FOOT REPORT
     stat = alterlist(reply->requests,count), stat = alterlist(route_flat_rec->qual,route_flat_rec->
      cnt), stat = alterlist(route_stop_flat_rec->qual,route_stop_flat_rec->cnt),
     stat = alterlist(xencntr_flat_rec->qual,xencntr_flat_rec->cnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveReportRequestsByIds","ReportRequestQuery",1,1)
   CALL log_message(build("Exiting RetrieveReportRequestsByIds, Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievereportrequestsbycriteria(null)
   CALL log_message("Entering RetrieveReportRequestsByCriteria",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   CALL logicaldomainlookup(null)
   DECLARE count = i4 WITH noconstant(0), protect
   DECLARE requestcount = i4 WITH noconstant(0), protect
   DECLARE qualcount = i4 WITH noconstant(0), protect
   DECLARE max_size = i4 WITH constant(65000), protect
   SELECT
    IF ((request->facility_id > 0.0))
     FROM cr_report_request cr,
      encounter e,
      long_text lt1,
      cr_report_template rt,
      cr_output_destination od,
      person p
     PLAN (cr
      WHERE parser(squalclause))
      JOIN (e
      WHERE ((e.organization_id+ 0)=request->facility_id)
       AND e.encntr_id IN (
      IF (cr.scope_flag != 5) cr.encntr_id
      ELSE
       (SELECT
        re.encntr_id
        FROM cr_report_request_encntr re
        WHERE re.report_request_id=cr.report_request_id)
      ENDIF
      ))
      JOIN (lt1
      WHERE lt1.long_text_id=cr.request_xml_id)
      JOIN (rt
      WHERE rt.report_template_id=cr.template_id)
      JOIN (od
      WHERE (od.report_request_id= Outerjoin(cr.report_request_id)) )
      JOIN (p
      WHERE cr.person_id=p.person_id
       AND p.logical_domain_id=userlogicaldomain)
    ELSE
     FROM cr_report_request cr,
      long_text lt1,
      cr_report_template rt,
      cr_output_destination od,
      person p
     PLAN (cr
      WHERE parser(squalclause))
      JOIN (lt1
      WHERE lt1.long_text_id=cr.request_xml_id)
      JOIN (rt
      WHERE rt.report_template_id=cr.template_id)
      JOIN (od
      WHERE (od.report_request_id= Outerjoin(cr.report_request_id)) )
      JOIN (p
      WHERE cr.person_id=p.person_id
       AND p.logical_domain_id=userlogicaldomain)
    ENDIF
    INTO "nl:"
    ORDER BY cr.report_request_id, od.cr_output_destination_id
    HEAD REPORT
     count = 0, qualcount = 0, requestcount = 0
    HEAD cr.report_request_id
     CALL addreportrequestrow(null)
    HEAD od.cr_output_destination_id
     CALL addoutputdestinations(null)
    FOOT REPORT
     IF (count <= max_size)
      stat = alterlist(reply->requests,count)
     ENDIF
     stat = alterlist(route_flat_rec->qual,route_flat_rec->cnt), stat = alterlist(route_stop_flat_rec
      ->qual,route_stop_flat_rec->cnt), stat = alterlist(xencntr_flat_rec->qual,xencntr_flat_rec->cnt
      )
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RetrieveReportRequestsByCriteria","ReportRequestQuery",1,1)
   CALL log_message(build("Exiting RetrieveReportRequestsByCriteria, Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE logicaldomainlookup(null)
   FREE RECORD logical_domain_reply
   RECORD logical_domain_reply(
     1 logical_domain_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE cr_get_logical_domain  WITH replace(reply,logical_domain_reply)
   IF ((logical_domain_reply->status_data.status="F"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "cr_requests_by_criteria_sub"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "EXECUTE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "ERROR! - CCL errors occurred in cr_get_logical_domain!  Exiting Job."
    SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
    GO TO exit_script
   ENDIF
   SET userlogicaldomain = logical_domain_reply->logical_domain_id
 END ;Subroutine
 IF (validate(request) != 1)
  RECORD request(
    1 report_requests[*]
      2 report_request_id = f8
    1 parent_request_id = f8
    1 request_types[*]
      2 request_type_flag = i2
    1 report_statuses[*]
      2 report_status_cd = f8
    1 scopes[*]
      2 scope_flag = i2
    1 person_id = f8
    1 encntr_id = f8
    1 accession_nbr = c20
    1 request_prsnl_id = f8
    1 provider_prsnl_id = f8
    1 template_id = f8
    1 search_start_dt_tm = dq8
    1 search_end_dt_tm = dq8
    1 page_cnt_threshold = i4
    1 process_time_threshold = i4
    1 distribution_id = f8
    1 dist_run_type_cd = f8
    1 trigger_name = vc
    1 chart_trigger_id = f8
    1 honor_load_indicators = i2
    1 load_indicators
      2 route_information = i2
      2 requested_section_information = i2
      2 processed_section_information = i2
      2 additional_section_information = i2
      2 secure_email_detail = i2
      2 status_log = i2
    1 facility_id = f8
    1 patient_request_ind = i2
    1 logical_domain_aware_ind = i2
    1 custodial_org_id = f8
    1 server_full_name = vc
    1 device_service_identifier = vc
    1 device_output_dest_cd = f8
    1 concept_service_name = vc
  )
 ENDIF
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 requests[*]
      2 report_request_id = f8
      2 request_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 qual[*]
      2 request[*]
        3 report_request_id = f8
        3 request_dt_tm = dq8
    1 count = i4
  )
 ENDIF
 SET reply->status_data.status = "F"
 IF (num_request_ids > 0)
  CALL retrievereportrequestsbyids(null)
 ELSE
  CALL createqualclause(null)
  CALL retrievereportrequestsbycriteria(null)
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE addreportrequestrow(null)
   SET count += 1
   IF (count <= max_size)
    IF (mod(count,20)=1)
     SET stat = alterlist(reply->requests,(count+ 19))
    ENDIF
    SET reply->requests[count].report_request_id = cr.report_request_id
    SET reply->requests[count].request_dt_tm = cr.request_dt_tm
   ELSE
    IF (mod(count,max_size)=1)
     SET qualcount += 1
     SET stat = alterlist(reply->qual,qualcount)
    ENDIF
    SET requestcount = mod(count,max_size)
    IF (mod(count,max_size)=0)
     SET requestcount = max_size
    ENDIF
    SET stat = alterlist(reply->qual[qualcount].request,requestcount)
    SET reply->qual[qualcount].request[requestcount].report_request_id = cr.report_request_id
    SET reply->qual[qualcount].request[requestcount].request_dt_tm = cr.request_dt_tm
   ENDIF
   SET reply->count = count
 END ;Subroutine
 SUBROUTINE addoutputdestinations(null)
   SET i = 0
 END ;Subroutine
#exit_script
 FREE RECORD route_flat_rec
 FREE RECORD route_stop_flat_rec
 FREE RECORD xencntr_flat_rec
 CALL log_message("End of script: cr_get_report_requests_lite",log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
