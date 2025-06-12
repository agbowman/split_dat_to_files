CREATE PROGRAM cr_get_report_requests:dba
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
 SET log_program_name = "cr_get_report_requests"
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
      2 parent_request_id = f8
      2 report_status_cd = f8
      2 updt_dt_tm = dq8
      2 processing_time = f8
      2 total_pages = i4
      2 request_xml_id = f8
      2 request_xml = vc
      2 summary_xml_id = f8
      2 summary_xml = vc
      2 debug_zip_id = f8
      2 person_id = f8
      2 request_prsnl_id = f8
      2 provider_prsnl_id = f8
      2 provider_reltn_cd = f8
      2 scope_flag = i2
      2 encounters[*]
        3 encounter_id = f8
      2 updt_id = f8
      2 request_dt_tm = dq8
      2 chart_trigger_id = f8
      2 request_role_profile = vc
      2 sections[*]
        3 section_id = f8
        3 name = vc
        3 sequence_nbr = i4
      2 events[*]
        3 event_id = f8
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 result_status_flag = i2
      2 route_id = f8
      2 route_stop_id = f8
      2 num_copies = i4
      2 sequence_nbr = i4
      2 use_posting_date_ind = i2
      2 patient_consent_received_ind = i2
      2 release_reason_cd = f8
      2 release_comment = vc
      2 requestor_type_flag = i2
      2 requestor_value_txt = vc
      2 destination_type_flag = i2
      2 destination_value_txt = vc
      2 output_dest_cd = f8
      2 dms_service_name = vc
      2 template_id = f8
      2 accession_nbr = c20
      2 order_id = f8
      2 request_type_flag = i2
      2 trigger_id = f8
      2 trigger_type = c15
      2 distribution_id = f8
      2 reader_group = c15
      2 distribution_run_dt_tm = dq8
      2 distribution_run_type_cd = f8
      2 trigger_name = vc
      2 route_name = vc
      2 route_stop_name = vc
      2 template_name = vc
      2 printed_sections[*]
        3 section_id = f8
        3 name = vc
        3 sequence_nbr = i4
        3 content_type_cd = f8
      2 encntr_id = f8
      2 dms_service_ident = vc
      2 fax_distribute_dt_tm = dq8
      2 adhoc_fax_number = vc
      2 output_content_type = vc
      2 disk_label = vc
      2 disk_type_flag = i2
      2 template_version_mode_flag = i2
      2 template_version_dt_tm = dq8
      2 prsnl_reltn_id = f8
      2 patient_request_ind = i2
      2 output_content_type_cd = f8
      2 file_mask = vc
      2 file_name = vc
      2 output_destinations[*]
        3 output_destination_id = f8
        3 output_dest_cd = f8
        3 dms_service_ind = vc
        3 dms_fax_distribute_dt_tm = dq8
        3 dms_adhoc_fax_number = vc
        3 copies_nbr = i4
        3 report_request_id = f8
        3 disk_label = vc
        3 disk_type_flag = i2
        3 distributed_status_ind = i2
      2 disk_identifier = f8
      2 non_ce_begin_dt_tm = dq8
      2 non_ce_end_dt_tm = dq8
      2 custodial_org_id = f8
      2 server_full_name = vc
      2 sender_email = vc
      2 message_identifier = vc
      2 email_subject = vc
      2 email_body = vc
      2 email_subject_id = f8
      2 email_body_id = f8
      2 status_text_id = f8
      2 status_text = vc
      2 contact_info = vc
      2 rrd_handle_id = f8
      2 request_app_nbr = i4
      2 request_app_descr = vc
      2 resubmit_cnt = i4
      2 direct_parent_request_id = f8
      2 transmission_status_cd = f8
      2 external_content_ident = vc
      2 external_content_name = vc
      2 prsnl_role_profile_uid = vc
      2 concept_service_name = vc
      2 persona_txt = vc
      2 formatted_accession_nbr = vc
      2 report_status_raw_cd = f8
      2 request_state_cd = f8
      2 xr_bitmap = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD event_flat_rec
 RECORD event_flat_rec(
   1 cnt = i4
   1 qual[*]
     2 request_id = f8
     2 request_seq = i4
 )
 FREE RECORD section_flat_rec
 RECORD section_flat_rec(
   1 cnt = i4
   1 qual[*]
     2 section_id = f8
     2 request_seq = i4
     2 requested_seq = i4
     2 printed_seq = i4
     2 request_dt_tm = dq8
     2 template_id = f8
 )
 DECLARE retrieveadditionalencounters(null) = null
 DECLARE retrieverequestedsections(null) = null
 DECLARE retrieveprocessedsections(null) = null
 DECLARE retrieverequestedevents(null) = null
 DECLARE retrieveroutes(null) = null
 DECLARE retrieveroutestops(null) = null
 DECLARE retrieveadditionalreportrequestinformation(null) = null
 DECLARE retrievesectioninformation(null) = null
 DECLARE verifyloadindicators(null) = null
 DECLARE retrievesecureemaildetail(null) = null
 DECLARE retrieveapplicationdescription(null) = null
 DECLARE retrieverequeststatuslog(null) = null
 DECLARE retrievefaxtransmissionstatus(null) = null
 DECLARE retrievestate(null) = null
 DECLARE published_as_of_mode_type = i2 WITH constant(4), protected
 DECLARE dest_count = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
 CALL verifyloadindicators(null)
 IF (num_request_ids > 0)
  CALL retrievereportrequestsbyids(null)
 ELSE
  CALL createqualclause(null)
  CALL retrievereportrequestsbycriteria(null)
 ENDIF
 IF ((xencntr_flat_rec->cnt != 0))
  CALL retrieveadditionalencounters(null)
 ENDIF
 IF ((route_flat_rec->cnt != 0)
  AND request->load_indicators.route_information)
  CALL retrieveroutes(null)
 ENDIF
 IF ((route_stop_flat_rec->cnt != 0)
  AND request->load_indicators.route_information)
  CALL retrieveroutestops(null)
 ENDIF
 IF ((event_flat_rec->cnt != 0))
  CALL retrieverequestedevents(null)
 ENDIF
 IF ((request->load_indicators.secure_email_detail=1))
  CALL retrievesecureemaildetail(null)
 ENDIF
 CALL retrieveapplicationdescription(null)
 IF ((request->load_indicators.status_log=1))
  CALL retrieverequeststatuslog(null)
 ENDIF
 CALL retrieveadditionalreportrequestinformation(null)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 SUBROUTINE verifyloadindicators(null)
   IF ((request->honor_load_indicators=0))
    SET request->load_indicators.additional_section_information = 1
    SET request->load_indicators.processed_section_information = 1
    SET request->load_indicators.requested_section_information = 1
    SET request->load_indicators.route_information = 1
    SET request->load_indicators.secure_email_detail = 0
    SET request->load_indicators.status_log = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE addreportrequestrow(null)
   CALL log_message("Enter AddReportRequestRow subroutine.",log_level_debug)
   DECLARE in_process = f8 WITH constant(uar_get_code_by("MEANING",367571,"INPROCESS")), protect
   DECLARE in_process_data_retrieval = f8 WITH constant(uar_get_code_by("MEANING",367571,
     "INPROCDATART")), protect
   DECLARE in_process_report_generation = f8 WITH constant(uar_get_code_by("MEANING",367571,
     "INPROCRGEN")), protect
   DECLARE archived_in_process = f8 WITH constant(uar_get_code_by("MEANING",367571,"ARCHIVEDINPR")),
   protect
   DECLARE report_sent_to_distributor = f8 WITH constant(uar_get_code_by("MEANING",367571,
     "SENTTODIST")), protect
   DECLARE distributing_report_in_progress = f8 WITH constant(uar_get_code_by("MEANING",367571,
     "RDISTINPROC")), protect
   DECLARE err_processing_report = f8 WITH constant(uar_get_code_by("MEANING",367571,"ERRPROCESRPT")),
   protect
   DECLARE err_distribute_report = f8 WITH constant(uar_get_code_by("MEANING",367571,"DMSERR")),
   protect
   DECLARE to_inprocess = f8 WITH constant(uar_get_code_by("MEANING",367571,"TO_INPROC")), protect
   DECLARE to_batch_inprocess = f8 WITH constant(uar_get_code_by("MEANING",367571,"TO_INBATCH")),
   protect
   DECLARE to_archived_inprocess = f8 WITH constant(uar_get_code_by("MEANING",367571,"TO_INARCH")),
   protect
   DECLARE to_inprocess_data_retrieval = f8 WITH constant(uar_get_code_by("MEANING",367571,
     "TO_INDATA")), protect
   DECLARE to_inprocess_report_generation = f8 WITH constant(uar_get_code_by("MEANING",367571,
     "TO_INRPTGEN")), protect
   DECLARE to_report_sent_to_distributor = f8 WITH constant(uar_get_code_by("MEANING",367571,
     "TO_SENTDIST")), protect
   DECLARE to_distribution_inprocess = f8 WITH constant(uar_get_code_by("MEANING",367571,
     "TO_INRPTDIST")), protect
   DECLARE unsubmitted = f8 WITH constant(uar_get_code_by("MEANING",367571,"UNSUBMITTED")), protect
   DECLARE pending = f8 WITH constant(uar_get_code_by("MEANING",367571,"PENDING")), protect
   DECLARE to_unsubmitted = f8 WITH constant(uar_get_code_by("MEANING",367571,"TO_UNSUBMIT")),
   protect
   SET count += 1
   IF (mod(count,20)=1)
    SET stat = alterlist(reply->requests,(count+ 19))
   ENDIF
   IF (((cr.report_status_cd=in_process_data_retrieval) OR (cr.report_status_cd=
   in_process_report_generation)) )
    SET reply->requests[count].report_status_cd = in_process
   ELSEIF (((cr.report_status_cd=report_sent_to_distributor) OR (cr.report_status_cd=
   distributing_report_in_progress)) )
    SET reply->requests[count].report_status_cd = archived_in_process
   ELSEIF (((cr.report_status_cd=to_inprocess) OR (((cr.report_status_cd=to_batch_inprocess) OR (((cr
   .report_status_cd=to_archived_inprocess) OR (((cr.report_status_cd=to_inprocess_data_retrieval)
    OR (((cr.report_status_cd=to_inprocess_report_generation) OR (cr.report_status_cd=to_unsubmitted
   )) )) )) )) )) )
    SET reply->requests[count].report_status_cd = err_processing_report
   ELSEIF (((cr.report_status_cd=to_report_sent_to_distributor) OR (cr.report_status_cd=
   to_distribution_inprocess)) )
    SET reply->requests[count].report_status_cd = err_distribute_report
   ELSEIF (cr.report_status_cd=unsubmitted)
    SET reply->requests[count].report_status_cd = pending
   ELSE
    SET reply->requests[count].report_status_cd = cr.report_status_cd
   ENDIF
   SET reply->requests[count].report_status_raw_cd = cr.report_status_cd
   SET reply->requests[count].report_request_id = cr.report_request_id
   SET reply->requests[count].parent_request_id = cr.parent_request_id
   SET reply->requests[count].updt_dt_tm = cr.updt_dt_tm
   SET reply->requests[count].processing_time = cr.processing_time
   SET reply->requests[count].total_pages = cr.total_pages_nbr
   SET reply->requests[count].request_xml_id = cr.request_xml_id
   SET reply->requests[count].request_xml = lt1.long_text
   SET reply->requests[count].debug_zip_id = cr.debug_zip_id
   SET reply->requests[count].person_id = cr.person_id
   SET reply->requests[count].request_prsnl_id = cr.request_prsnl_id
   SET reply->requests[count].provider_prsnl_id = cr.provider_prsnl_id
   SET reply->requests[count].provider_reltn_cd = cr.provider_reltn_cd
   SET reply->requests[count].chart_trigger_id = cr.chart_trigger_id
   SET reply->requests[count].scope_flag = cr.scope_flag
   IF (cr.begin_dt_tm > cnvtdatetime("01-JAN-1800"))
    SET reply->requests[count].begin_dt_tm = cr.begin_dt_tm
   ENDIF
   SET reply->requests[count].end_dt_tm = cr.end_dt_tm
   SET reply->requests[count].non_ce_begin_dt_tm = cr.non_ce_begin_dt_tm
   SET reply->requests[count].non_ce_end_dt_tm = cr.non_ce_end_dt_tm
   SET reply->requests[count].result_status_flag = cr.result_status_flag
   SET reply->requests[count].route_id = cr.route_id
   IF (cr.route_id > 0)
    SET route_flat_rec->cnt += 1
    IF ((route_flat_rec->cnt > size(route_flat_rec->qual,5)))
     SET stat = alterlist(route_flat_rec->qual,(route_flat_rec->cnt+ 9))
    ENDIF
    SET route_flat_rec->qual[route_flat_rec->cnt].request_seq = count
    SET route_flat_rec->qual[route_flat_rec->cnt].route_id = cr.route_id
   ENDIF
   SET reply->requests[count].route_stop_id = cr.route_stop_id
   IF (cr.route_stop_id > 0)
    SET route_stop_flat_rec->cnt += 1
    IF ((route_stop_flat_rec->cnt > size(route_stop_flat_rec->qual,5)))
     SET stat = alterlist(route_stop_flat_rec->qual,(route_stop_flat_rec->cnt+ 9))
    ENDIF
    SET route_stop_flat_rec->qual[route_stop_flat_rec->cnt].request_seq = count
    SET route_stop_flat_rec->qual[route_stop_flat_rec->cnt].route_stop_id = cr.route_stop_id
   ENDIF
   IF (cr.scope_flag=cross_encounter)
    SET xencntr_flat_rec->cnt += 1
    IF ((xencntr_flat_rec->cnt > size(xencntr_flat_rec->qual,5)))
     SET stat = alterlist(xencntr_flat_rec->qual,(xencntr_flat_rec->cnt+ 9))
    ENDIF
    SET xencntr_flat_rec->qual[xencntr_flat_rec->cnt].request_seq = count
    SET xencntr_flat_rec->qual[xencntr_flat_rec->cnt].request_id = cr.report_request_id
   ELSEIF (((cr.scope_flag=event_scope) OR (((cr.scope_flag=event_plus_scope) OR (cr.trigger_id > 0
   )) )) )
    SET event_flat_rec->cnt += 1
    IF ((event_flat_rec->cnt > size(event_flat_rec->qual,5)))
     SET stat = alterlist(event_flat_rec->qual,(event_flat_rec->cnt+ 9))
    ENDIF
    SET event_flat_rec->qual[event_flat_rec->cnt].request_seq = count
    SET event_flat_rec->qual[event_flat_rec->cnt].request_id = cr.report_request_id
   ENDIF
   IF (cr.copies_nbr > 0)
    SET reply->requests[count].num_copies = cr.copies_nbr
   ELSE
    SET reply->requests[count].num_copies = 1
   ENDIF
   SET reply->requests[count].sequence_nbr = cr.sequence_nbr
   SET reply->requests[count].patient_consent_received_ind = cr.patient_consent_received_ind
   SET reply->requests[count].use_posting_date_ind = cr.use_posting_date_ind
   SET reply->requests[count].release_reason_cd = cr.release_reason_cd
   SET reply->requests[count].release_comment = cr.release_comment
   SET reply->requests[count].requestor_type_flag = cr.requestor_type_flag
   SET reply->requests[count].requestor_value_txt = cr.requestor_value_txt
   SET reply->requests[count].destination_type_flag = cr.destination_type_flag
   SET reply->requests[count].destination_value_txt = cr.destination_value_txt
   SET reply->requests[count].output_dest_cd = cr.output_dest_cd
   SET reply->requests[count].dms_service_name = cr.dms_service_name
   SET reply->requests[count].dms_service_ident = cr.dms_service_ident
   SET reply->requests[count].fax_distribute_dt_tm = cr.dms_fax_distribute_dt_tm
   SET reply->requests[count].adhoc_fax_number = cr.dms_adhoc_fax_number_txt
   SET reply->requests[count].disk_label = cr.disk_label
   SET reply->requests[count].disk_type_flag = cr.disk_type_flag
   SET reply->requests[count].template_id = cr.template_id
   IF (cr.template_version_mode_flag > 0)
    SET reply->requests[count].template_version_mode_flag = cr.template_version_mode_flag
    SET reply->requests[count].template_version_dt_tm = cr.template_version_dt_tm
   ELSE
    SET reply->requests[count].template_version_mode_flag = published_as_of_mode_type
    SET reply->requests[count].template_version_dt_tm = cr.request_dt_tm
   ENDIF
   SET reply->requests[count].accession_nbr = cr.accession_nbr
   SET reply->requests[count].order_id = cr.order_id
   SET reply->requests[count].request_type_flag = cr.request_type_flag
   SET reply->requests[count].trigger_id = cr.trigger_id
   SET reply->requests[count].trigger_type = cr.trigger_type
   SET reply->requests[count].distribution_id = cr.distribution_id
   SET reply->requests[count].reader_group = cr.reader_group
   SET reply->requests[count].distribution_run_dt_tm = cr.dist_run_dt_tm
   SET reply->requests[count].distribution_run_type_cd = cr.dist_run_type_cd
   IF (cr.encntr_id > 0)
    SET stat = alterlist(reply->requests[count].encounters,1)
    SET reply->requests[count].encounters[1].encounter_id = cr.encntr_id
   ENDIF
   SET reply->requests[count].encntr_id = cr.encntr_id
   SET reply->requests[count].updt_id = cr.updt_id
   SET reply->requests[count].request_dt_tm = cr.request_dt_tm
   SET reply->requests[count].request_role_profile = cr.requesting_role_profile
   SET reply->requests[count].trigger_name = cr.trigger_name
   SET reply->requests[count].template_name = rt.template_name
   SET reply->requests[count].output_content_type = cr.output_content_type_str
   SET reply->requests[count].output_content_type_cd = cr.output_content_type_cd
   SET reply->requests[count].prsnl_reltn_id = cr.prsnl_reltn_id
   SET reply->requests[count].patient_request_ind = cr.patient_request_ind
   SET reply->requests[count].file_mask = cr.file_mask
   SET reply->requests[count].file_name = cr.file_name
   SET reply->requests[count].disk_identifier = cr.disk_identifier
   SET reply->requests[count].custodial_org_id = cr.custodial_org_id
   SET reply->requests[count].server_full_name = cr.server_full_name
   SET reply->requests[count].sender_email = cr.sender_email
   SET reply->requests[count].message_identifier = cr.message_ident
   SET reply->requests[count].email_body_id = cr.email_body_id
   SET reply->requests[count].email_subject_id = cr.email_subject_id
   SET reply->requests[count].status_text_id = cr.status_text_id
   SET reply->requests[count].contact_info = cr.contact_info
   SET reply->requests[count].rrd_handle_id = cr.rrd_handle_id
   SET reply->requests[count].request_app_nbr = cr.request_app_nbr
   SET reply->requests[count].resubmit_cnt = cr.resubmit_cnt
   SET reply->requests[count].direct_parent_request_id = cr.direct_parent_request_id
   SET reply->requests[count].external_content_ident = cr.external_content_ident
   SET reply->requests[count].external_content_name = cr.external_content_name
   SET reply->requests[count].prsnl_role_profile_uid = cr.prsnl_role_profile_uid
   SET reply->requests[count].concept_service_name = cr.concept_service_name
   SET reply->requests[count].persona_txt = cr.persona_txt
   SET reply->requests[count].formatted_accession_nbr = uar_fmt_accession(cr.accession_nbr,size(cr
     .accession_nbr,1))
   SET reply->requests[count].xr_bitmap = cr.xr_bitmap
   CALL log_message("Exit AddReportRequestRow subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE addoutputdestinations(null)
   DECLARE dest_count = i2 WITH noconstant((size(reply->requests[count].output_destinations,5)+ 1))
   CALL log_message("Enter AddOutputDestinations subroutine.",log_level_debug)
   SET stat = alterlist(reply->requests[count].output_destinations,dest_count)
   SET reply->requests[count].output_destinations[dest_count].output_dest_cd = od.output_dest_cd
   SET reply->requests[count].output_destinations[dest_count].dms_service_ind = od.dms_service_ident
   SET reply->requests[count].output_destinations[dest_count].dms_fax_distribute_dt_tm = od
   .dms_fax_distribute_dt_tm
   SET reply->requests[count].output_destinations[dest_count].dms_adhoc_fax_number = od
   .dms_adhoc_fax_number_txt
   SET reply->requests[count].output_destinations[dest_count].disk_label = od.disk_label
   SET reply->requests[count].output_destinations[dest_count].disk_type_flag = od.disk_type_flag
   SET reply->requests[count].output_destinations[dest_count].copies_nbr = od.copies_nbr
   SET reply->requests[count].output_destinations[dest_count].distributed_status_ind = od
   .distributed_status_ind
   SET reply->requests[count].output_destinations[dest_count].report_request_id = od
   .report_request_id
   SET reply->requests[count].output_destinations[dest_count].output_destination_id = od
   .cr_output_destination_id
   CALL log_message("Exit AddOutputDestinations subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieveadditionalreportrequestinformation(null)
   CALL log_message("Entering RetrieveAdditionalReportRequestInformation",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(size(reply->requests,5)), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(reply->requests,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET reply->requests[i].report_request_id = reply->requests[nrecordsize].report_request_id
   ENDFOR
   IF (request->load_indicators.requested_section_information)
    CALL retrieverequestedsections(null)
   ENDIF
   SET idx = 0
   SET idxstart = 1
   IF (request->load_indicators.processed_section_information)
    CALL retrieveprocessedsections(null)
   ENDIF
   SET stat = alterlist(reply->requests,nrecordsize)
   IF ((section_flat_rec->cnt > 0)
    AND request->load_indicators.additional_section_information)
    CALL retrievesectioninformation(null)
   ENDIF
   CALL retrievefaxtransmissionstatus(null)
   CALL retrievestate(null)
   CALL log_message(build(
     "Exiting RetrieveAdditionalReportRequestInformation, Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieveroutes(null)
   CALL log_message("Entering RetrieveRoutes",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(route_flat_rec->cnt), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(route_flat_rec->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
    SET route_flat_rec->qual[i].request_seq = route_flat_rec->qual[nrecordsize].request_seq
    SET route_flat_rec->qual[i].route_id = route_flat_rec->qual[nrecordsize].route_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_route cr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cr.chart_route_id,route_flat_rec->qual[idx]
      .route_id,
      bind_cnt))
    HEAD REPORT
     locval = 0
    HEAD cr.chart_route_id
     locval = locateval(idx2,1,nrecordsize,cr.chart_route_id,route_flat_rec->qual[idx2].route_id)
     WHILE (locval != 0)
       request_seq = route_flat_rec->qual[locval].request_seq, reply->requests[request_seq].
       route_name = cr.route_name, locval = locateval(idx2,(locval+ 1),nrecordsize,cr.chart_route_id,
        route_flat_rec->qual[idx2].route_id)
     ENDWHILE
    DETAIL
     donothing = 0
    FOOT  cr.chart_route_id
     donothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_ROUTE","RETRIEVEROUTES",1,0)
   CALL log_message(build("Exiting RetrieveRoutes, Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieveroutestops(null)
   CALL log_message("Entering RetrieveRouteStops",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(route_stop_flat_rec->cnt), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(route_stop_flat_rec->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
    SET route_stop_flat_rec->qual[i].request_seq = route_stop_flat_rec->qual[nrecordsize].request_seq
    SET route_stop_flat_rec->qual[i].route_stop_id = route_stop_flat_rec->qual[nrecordsize].
    route_stop_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_sequence_group csg
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (csg
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),csg.sequence_group_id,route_stop_flat_rec->
      qual[idx].route_stop_id,
      bind_cnt))
    HEAD REPORT
     locval = 0
    HEAD csg.sequence_group_id
     locval = locateval(idx2,1,nrecordsize,csg.sequence_group_id,route_stop_flat_rec->qual[idx2].
      route_stop_id)
     WHILE (locval != 0)
       request_seq = route_flat_rec->qual[locval].request_seq, reply->requests[request_seq].
       route_stop_name = csg.group_name, locval = locateval(idx2,(locval+ 1),nrecordsize,csg
        .sequence_group_id,route_stop_flat_rec->qual[idx2].route_stop_id)
     ENDWHILE
    DETAIL
     donothing = 0
    FOOT  csg.sequence_group_id
     donothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_SEQUENCE_GROUP","RETRIEVEROUTESTOPSS",1,0)
   CALL log_message(build("Exiting RetrieveRouteStops, Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieveadditionalencounters(null)
   CALL log_message("Entering RetrieveAdditionalEncounters",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(xencntr_flat_rec->cnt), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(xencntr_flat_rec->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
    SET xencntr_flat_rec->qual[i].request_seq = xencntr_flat_rec->qual[nrecordsize].request_seq
    SET xencntr_flat_rec->qual[i].request_id = xencntr_flat_rec->qual[nrecordsize].request_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     cr_report_request_encntr cr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cr.report_request_id,xencntr_flat_rec->
      qual[idx].request_id,
      bind_cnt))
    ORDER BY cr.report_request_id, cr.encntr_seq
    HEAD REPORT
     locval = 0
    HEAD cr.report_request_id
     locval = locateval(idx2,1,nrecordsize,cr.report_request_id,xencntr_flat_rec->qual[idx2].
      request_id), encntr_cnt = 0
    DETAIL
     IF (locval != 0)
      request_seq = xencntr_flat_rec->qual[locval].request_seq, encntr_cnt += 1
      IF (encntr_cnt > size(reply->requests[request_seq].encounters,5))
       stat = alterlist(reply->requests[request_seq].encounters,(encntr_cnt+ 9))
      ENDIF
      reply->requests[request_seq].encounters[encntr_cnt].encounter_id = cr.encntr_id
     ENDIF
    FOOT  cr.report_request_id
     stat = alterlist(reply->requests[request_seq].encounters,encntr_cnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"AdditionalEncountersQuery","ReportRequestQuery",1,0)
 END ;Subroutine
 SUBROUTINE retrieverequestedsections(null)
   CALL log_message("Entering RetrieveRequestedSections",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx2 = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     cr_report_request_section cr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cr.report_request_id,reply->requests[idx].
      report_request_id,
      bind_cnt))
    ORDER BY cr.report_request_id
    HEAD cr.report_request_id
     request_seq = locateval(idx2,1,nrecordsize,cr.report_request_id,reply->requests[idx2].
      report_request_id), sect_cnt = 0
    DETAIL
     sect_cnt += 1
     IF (sect_cnt > size(reply->requests[request_seq].sections,5))
      stat = alterlist(reply->requests[request_seq].sections,(sect_cnt+ 9))
     ENDIF
     reply->requests[request_seq].sections[sect_cnt].section_id = cr.section_id,
     CALL addsectiontorecord(cr.section_id,request_seq,sect_cnt,0)
    FOOT  cr.report_request_id
     stat = alterlist(reply->requests[request_seq].sections,sect_cnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST_SECTION","RETRIEVEREQUESTEDSECTIONS",1,0)
   CALL log_message(build("Exit RetrieveRequestedSections, Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieveprocessedsections(null)
   CALL log_message("Entering RetrieveProcessedSections",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx2 = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     cr_printed_sections cr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cr.report_request_id,reply->requests[idx].
      report_request_id,
      bind_cnt))
    ORDER BY cr.report_request_id
    HEAD cr.report_request_id
     request_seq = locateval(idx2,1,nrecordsize,cr.report_request_id,reply->requests[idx2].
      report_request_id), sect_cnt = 0
    DETAIL
     sect_cnt += 1
     IF (sect_cnt > size(reply->requests[request_seq].printed_sections,5))
      stat = alterlist(reply->requests[request_seq].printed_sections,(sect_cnt+ 9))
     ENDIF
     reply->requests[request_seq].printed_sections[sect_cnt].section_id = cr.section_id, reply->
     requests[request_seq].printed_sections[sect_cnt].content_type_cd = cr.content_type_cd,
     CALL addsectiontorecord(cr.section_id,request_seq,0,sect_cnt)
    FOOT  cr.report_request_id
     stat = alterlist(reply->requests[request_seq].printed_sections,sect_cnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CR_PRINTED_SECTIONS","RETRIEVEPROCESSEDSECTIONS",1,0)
   CALL log_message(build("Exit RetrieveProcessedSections, Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addsectiontorecord(section_id,request_seq,requested_seq,printed_seq)
   SET section_flat_rec->cnt += 1
   IF ((section_flat_rec->cnt > size(section_flat_rec->qual,5)))
    SET stat = alterlist(section_flat_rec->qual,(section_flat_rec->cnt+ 9))
   ENDIF
   SET section_flat_rec->qual[section_flat_rec->cnt].section_id = section_id
   SET section_flat_rec->qual[section_flat_rec->cnt].request_seq = request_seq
   SET section_flat_rec->qual[section_flat_rec->cnt].requested_seq = requested_seq
   SET section_flat_rec->qual[section_flat_rec->cnt].printed_seq = printed_seq
   SET section_flat_rec->qual[section_flat_rec->cnt].request_dt_tm = reply->requests[request_seq].
   request_dt_tm
   SET section_flat_rec->qual[section_flat_rec->cnt].template_id = reply->requests[request_seq].
   template_id
 END ;Subroutine
 SUBROUTINE retrievesectioninformation(null)
   CALL log_message("Entering RetrieveSectionInformation",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM cr_report_section cr,
     cr_template_publish ctp,
     cr_template_snapshot cts,
     (dummyt d  WITH seq = value(section_flat_rec->cnt))
    PLAN (d)
     JOIN (cr
     WHERE (cr.report_section_id=section_flat_rec->qual[d.seq].section_id))
     JOIN (ctp
     WHERE (ctp.template_id=section_flat_rec->qual[d.seq].template_id)
      AND ctp.end_effective_dt_tm > cnvtdatetime(section_flat_rec->qual[d.seq].request_dt_tm)
      AND ctp.beg_effective_dt_tm <= cnvtdatetime(section_flat_rec->qual[d.seq].request_dt_tm))
     JOIN (cts
     WHERE cts.section_id=cr.report_section_id
      AND cts.template_id=ctp.template_id
      AND cts.end_effective_dt_tm > ctp.publish_dt_tm
      AND cts.beg_effective_dt_tm <= ctp.publish_dt_tm)
    DETAIL
     request_seq = section_flat_rec->qual[d.seq].request_seq, printed_seq = section_flat_rec->qual[d
     .seq].printed_seq, requested_seq = section_flat_rec->qual[d.seq].requested_seq
     IF (printed_seq)
      reply->requests[request_seq].printed_sections[printed_seq].name = cr.section_name, reply->
      requests[request_seq].printed_sections[printed_seq].sequence_nbr = cts.sequence_nbr
     ENDIF
     IF (requested_seq)
      reply->requests[request_seq].sections[requested_seq].name = cr.section_name, reply->requests[
      request_seq].sections[requested_seq].sequence_nbr = cts.sequence_nbr
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CR_REPORT_SECTION","RETRIEVESECTIONINFORMATION",1,0)
   CALL log_message(build("Exiting RetrieveSectionInformation, Elapsed time in seconds:",datetimediff
     (cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieverequestedevents(null)
   CALL log_message("Entering RetrieveRequestedEvents",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(event_flat_rec->cnt), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(event_flat_rec->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
    SET event_flat_rec->qual[i].request_seq = event_flat_rec->qual[nrecordsize].request_seq
    SET event_flat_rec->qual[i].request_id = event_flat_rec->qual[nrecordsize].request_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     cr_report_request_event cr
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cr
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cr.report_request_id,event_flat_rec->qual[
      idx].request_id,
      bind_cnt))
    ORDER BY cr.report_request_id
    HEAD REPORT
     locval = 0
    HEAD cr.report_request_id
     locval = locateval(idx2,1,nrecordsize,cr.report_request_id,event_flat_rec->qual[idx2].request_id
      ), event_cnt = 0
    DETAIL
     IF (locval != 0)
      request_seq = event_flat_rec->qual[locval].request_seq, event_cnt += 1
      IF (event_cnt > size(reply->requests[request_seq].events,5))
       stat = alterlist(reply->requests[request_seq].events,(event_cnt+ 9))
      ENDIF
      reply->requests[request_seq].events[event_cnt].event_id = cr.event_id
     ENDIF
    FOOT  cr.report_request_id
     stat = alterlist(reply->requests[request_seq].events,event_cnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST_EVENT","RETRIEVEREQUESTEDEVENTS",1,0)
   CALL log_message(build("Exiting RetrieveRequestedEvents, Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievesecureemaildetail(null)
   CALL log_message("Entering RetrieveSecureEmailDetail",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(idx,1,size(reply->requests,5),lt.long_text_id,reply->requests[idx].email_subject_id,
      lt.parent_entity_id,reply->requests[idx].report_request_id)
      AND lt.parent_entity_name="CR_REPORT_REQUEST"
      AND lt.long_text_id > 0.0)
    ORDER BY lt.long_text_id
    DETAIL
     pos = locateval(idx,1,size(reply->requests,5),lt.long_text_id,reply->requests[idx].
      email_subject_id)
     IF (pos > 0)
      reply->requests[pos].email_subject = lt.long_text
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   CALL error_and_zero_check(curqual,"LONG_TEXT","RETRIEVE EMAIL SUBJECT",1,0)
   SET idx = 0
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(idx,1,size(reply->requests,5),lt.long_text_id,reply->requests[idx].email_body_id,
      lt.parent_entity_id,reply->requests[idx].report_request_id)
      AND lt.parent_entity_name="CR_REPORT_REQUEST"
      AND lt.long_text_id > 0.0)
    ORDER BY lt.long_text_id
    DETAIL
     pos = locateval(idx,1,size(reply->requests,5),lt.long_text_id,reply->requests[idx].email_body_id
      )
     IF (pos > 0)
      reply->requests[pos].email_body = lt.long_text
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   CALL error_and_zero_check(curqual,"LONG_TEXT","RETRIEVE EMAIL BODY",1,0)
   CALL log_message(build("Exiting RetrieveSecureEmailDetail, Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieveapplicationdescription(null)
   CALL log_message("Entering RetrieveApplicationDescription",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE lvalstart = i4 WITH noconstant(0)
   DECLARE lvalstop = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM application app
    PLAN (app
     WHERE expand(idx,1,size(reply->requests,5),app.application_number,reply->requests[idx].
      request_app_nbr)
      AND app.application_number > 0.0)
    ORDER BY app.application_number
    DETAIL
     lvalstart = locateval(num,1,size(reply->requests,5),app.application_number,reply->requests[num].
      request_app_nbr)
     IF (lvalstart > 0)
      reply->requests[lvalstart].request_app_descr = app.description, next = lvalstart, lvalstop =
      lvalstart
      WHILE (next != 0)
       next = locateval(num,(next+ 1),size(reply->requests,5),app.application_number,reply->requests[
        num].request_app_nbr),
       IF (next != 0)
        reply->requests[next].request_app_descr = app.description, lvalstop = next
       ENDIF
      ENDWHILE
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   CALL error_and_zero_check(curqual,"APPLICATION","RETRIEVE APPLICATION DESCRIPTION",1,0)
   CALL log_message(build("Exiting RetrieveApplicationDescription, Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieverequeststatuslog(null)
   CALL log_message("Entering RetrieveRequestStatusLog",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(idx,1,size(reply->requests,5),lt.long_text_id,reply->requests[idx].status_text_id,
      lt.parent_entity_id,reply->requests[idx].report_request_id)
      AND lt.parent_entity_name="CR_REPORT_REQUEST"
      AND lt.long_text_id > 0.0)
    ORDER BY lt.long_text_id
    DETAIL
     pos = locateval(idx,1,size(reply->requests,5),lt.long_text_id,reply->requests[idx].
      status_text_id)
     IF (pos > 0)
      reply->requests[pos].status_text = lt.long_text
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   CALL error_and_zero_check(curqual,"LONG_TEXT","RETRIEVE REQUEST STATUS LOG",1,0)
 END ;Subroutine
 SUBROUTINE retrievefaxtransmissionstatus(null)
   CALL log_message("Entering RetrieveFaxTransmissionStatus",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM report_queue r
    PLAN (r
     WHERE expand(idx,1,size(reply->requests,5),r.output_handle_id,reply->requests[idx].rrd_handle_id
      )
      AND r.output_handle_id > 0.0)
    DETAIL
     pos = locateval(idx,1,size(reply->requests,5),r.output_handle_id,reply->requests[idx].
      rrd_handle_id)
     IF (pos > 0)
      reply->requests[pos].transmission_status_cd = r.transmission_status_cd
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   CALL error_and_zero_check(curqual,"CR_REPORT_REQUEST","RETRIEVE FAX TRANSMISSION STATUS",1,0)
   CALL log_message(build("Exiting RetrieveFaxTransmissionStatus, Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievestate(null)
   CALL log_message("Entering RetrieveState",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(reply->requests,5)),
     code_value_group cvg,
     code_value cv
    PLAN (d)
     JOIN (cvg
     WHERE (cvg.child_code_value=reply->requests[d.seq].report_status_cd)
      AND cvg.code_set=367571)
     JOIN (cv
     WHERE cv.code_value=cvg.parent_code_value)
    DETAIL
     reply->requests[d.seq].request_state_cd = cv.code_value
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CODE_VALUE","RETRIEVESTATE",1,0)
   CALL log_message(build("Exiting RetrieveState, Elapsed time in seconds:",datetimediff(cnvtdatetime
      (sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0)=0)
  FREE RECORD route_flat_rec
  FREE RECORD route_stop_flat_rec
  FREE RECORD xencntr_flat_rec
  FREE RECORD event_flat_rec
  FREE RECORD section_flat_rec
 ENDIF
 CALL log_message("End of script: cr_get_report_requests",log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
