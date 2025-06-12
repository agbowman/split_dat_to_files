CREATE PROGRAM cr_upd_report_requests:dba
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
 SET log_program_name = "cr_upd_report_requests"
 IF ( NOT (validate(reply->requests)))
  FREE RECORD reply
  RECORD reply(
    1 requests[*]
      2 report_request_id = f8
      2 parent_request_id = f8
      2 report_status_cd = f8
      2 request_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD emailtextidrecord
 RECORD emailtextidrecord(
   1 qual[*]
     2 long_text_id_email_subject = f8
     2 long_text_id_email_message = f8
 )
 FREE RECORD requestlogrecord
 RECORD requestlogrecord(
   1 qual[*]
     2 report_request_id = f8
     2 long_text_id_status = f8
 )
 CALL log_message("Starting script: cr_upd_report_requests",log_level_debug)
 DECLARE errmsg = c132 WITH protect
 DECLARE nnumofreq = i4 WITH noconstant(size(request->requests,5))
 DECLARE num = i4 WITH protect
 DECLARE nnumprintedsections = i4 WITH protect
 DECLARE skipped_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",367571,"SKIPPED"))
 DECLARE currenttime = f8 WITH public, noconstant(curtime3)
 DECLARE currentdatetime = q8 WITH public, noconstant(cnvtdatetime(curdate,currenttime))
 DECLARE cross_encounter_scope = i2 WITH constant(5)
 DECLARE event_scope = i2 WITH constant(6)
 DECLARE event_plus_scope = i2 WITH constant(7)
 DECLARE working_mode_type = i2 WITH constant(1), protected
 DECLARE published_mode_type = i2 WITH constant(2), protected
 DECLARE active_as_of_mode_type = i2 WITH constant(3), protected
 DECLARE published_as_of_mode_type = i2 WITH constant(4), protected
 DECLARE insertreportrequests(null) = null
 DECLARE insertrequestencntrs(null) = null
 DECLARE insertrequestsections(null) = null
 DECLARE insertrequestevents(null) = null
 DECLARE insertrequestoutputdestinations(null) = null
 DECLARE insertrequestactivities(null) = null
 DECLARE insertrequestactivitiesonreportrequestupdate(null) = null
 DECLARE insertrequeststatuslog(null) = null
 DECLARE insertemailsubjectandmessageintolongtext(null) = null
 DECLARE updatereportrequests(null) = null
 DECLARE updatereportrequestdiscidentifier(null) = null
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 CALL error_and_zero_check(nnumofreq,"ReportRequests",
  "No report request to be inserted/updated.  Exiting script.",1,1)
 SET stat = alterlist(reply->requests,nnumofreq)
 SET stat = alterlist(emailtextidrecord->qual,nnumofreq)
 SET stat = alterlist(requestlogrecord->qual,nnumofreq)
 IF ((request->update_ind=0))
  CALL insertreportrequests(null)
  CALL updatedirectparentresubmitcount(null)
 ELSE
  CALL updatereportrequests(null)
 ENDIF
 SUBROUTINE insertreportrequests(null)
   CALL log_message("Entered InsertReportRequests subroutine.",log_level_debug)
   IF ((request->requests[1].report_request_id=0))
    FOR (n = 1 TO nnumofreq)
      SELECT INTO "nl:"
       reqid = seq(chart_seq,nextval)
       FROM dual
       DETAIL
        reply->requests[n].report_request_id = reqid
        IF ((request->requests[n].parent_request_id=0))
         reply->requests[n].parent_request_id = reqid
        ELSE
         reply->requests[n].parent_request_id = request->requests[n].parent_request_id
        ENDIF
       WITH nocounter
      ;end select
    ENDFOR
   ELSE
    FOR (n = 1 TO nnumofreq)
     SET reply->requests[n].report_request_id = request->requests[n].report_request_id
     SET reply->requests[n].parent_request_id = request->requests[n].report_request_id
    ENDFOR
   ENDIF
   CALL error_and_zero_check(curqual,"InsertReportRequests",
    "Insert request xml into long_text table failed. Exiting script.",1,1)
   CALL insertemailsubjectandmessageintolongtext(null)
   DECLARE dpendingcd = f8
   SET stat = uar_get_meaning_by_codeset(367571,"PENDING",1,dpendingcd)
   CALL echo(build("dPendingCd: ",dpendingcd))
   INSERT  FROM (dummyt d  WITH seq = value(nnumofreq)),
     cr_report_request cr
    SET cr.seq = 1, cr.report_request_id = reply->requests[d.seq].report_request_id, cr
     .parent_request_id = reply->requests[d.seq].parent_request_id,
     cr.direct_parent_request_id =
     IF ((request->requests[d.seq].direct_parent_request_id=0)) reply->requests[d.seq].
      report_request_id
     ELSE request->requests[d.seq].direct_parent_request_id
     ENDIF
     , cr.person_id = request->requests[d.seq].person_id, cr.encntr_id = request->requests[d.seq].
     encntr_id,
     cr.order_id = request->requests[d.seq].order_id, cr.accession_nbr = request->requests[d.seq].
     accession_nbr, reply->requests[d.seq].report_status_cd =
     IF ((request->requests[d.seq].report_status_cd != 0)) request->requests[d.seq].report_status_cd
     ELSE dpendingcd
     ENDIF
     ,
     cr.report_status_cd = reply->requests[d.seq].report_status_cd, cr.request_type_flag = request->
     requests[d.seq].request_type_flag, cr.scope_flag = request->requests[d.seq].scope_flag,
     cr.template_id = request->requests[d.seq].template_id, cr.template_version_mode_flag =
     IF ((request->requests[d.seq].template_version_mode_flag > 0)) request->requests[d.seq].
      template_version_mode_flag
     ELSE published_as_of_mode_type
     ENDIF
     , cr.template_version_dt_tm =
     IF ((request->requests[d.seq].template_version_mode_flag IN (working_mode_type,
     published_mode_type))) null
     ELSEIF ((request->requests[d.seq].template_version_dt_tm != null)) cnvtdatetime(request->
       requests[d.seq].template_version_dt_tm)
     ELSEIF ((request->requests[d.seq].request_dt_tm != null)) cnvtdatetime(request->requests[d.seq].
       request_dt_tm)
     ELSE cnvtdatetime(currentdatetime)
     ENDIF
     ,
     cr.distribution_id = request->requests[d.seq].distribution_id, cr.dist_run_type_cd = request->
     requests[d.seq].dist_run_type_cd, cr.dist_run_dt_tm = cnvtdatetime(request->requests[d.seq].
      dist_run_dt_tm),
     cr.reader_group = request->requests[d.seq].reader_group, cr.provider_prsnl_id = request->
     requests[d.seq].provider_prsnl_id, cr.provider_reltn_cd = request->requests[d.seq].
     provider_reltn_cd,
     cr.trigger_id = request->requests[d.seq].eso_trigger_id, cr.trigger_type = request->requests[d
     .seq].eso_trigger_type, cr.trigger_name = request->requests[d.seq].trigger_name,
     cr.chart_trigger_id = request->requests[d.seq].chart_trigger_id, cr.request_prsnl_id = request->
     requests[d.seq].request_prsnl_id, cr.requesting_role_profile = request->requests[d.seq].
     request_role_profile,
     cr.begin_dt_tm =
     IF ((request->requests[d.seq].begin_dt_tm > cnvtdatetime("01-JAN-1800"))) cnvtdatetime(request->
       requests[d.seq].begin_dt_tm)
     ELSE null
     ENDIF
     , cr.end_dt_tm =
     IF ((request->requests[d.seq].end_dt_tm=null)) cnvtdatetime(currentdatetime)
     ELSE cnvtdatetime(request->requests[d.seq].end_dt_tm)
     ENDIF
     , cr.non_ce_begin_dt_tm =
     IF ((request->requests[d.seq].non_ce_begin_dt_tm > cnvtdatetime("01-JAN-1800"))) cnvtdatetime(
       request->requests[d.seq].non_ce_begin_dt_tm)
     ELSE null
     ENDIF
     ,
     cr.non_ce_end_dt_tm =
     IF ((request->requests[d.seq].non_ce_end_dt_tm=null)) null
     ELSE cnvtdatetime(request->requests[d.seq].non_ce_end_dt_tm)
     ENDIF
     , cr.result_status_flag = request->requests[d.seq].result_status_flag, cr.route_id = request->
     requests[d.seq].route_id,
     cr.route_stop_id = request->requests[d.seq].route_stop_id, cr.copies_nbr =
     IF ((request->requests[d.seq].num_copies > 0)) request->requests[d.seq].num_copies
     ELSE 1
     ENDIF
     , cr.dms_service_name = request->requests[d.seq].dms_service_name,
     cr.dms_service_ident = request->requests[d.seq].dms_service_ident, cr.dms_fax_distribute_dt_tm
      =
     IF ((request->requests[d.seq].fax_distribute_dt_tm != null)) cnvtdatetime(request->requests[d
       .seq].fax_distribute_dt_tm)
     ELSE null
     ENDIF
     , cr.dms_adhoc_fax_number_txt = request->requests[d.seq].adhoc_fax_number,
     cr.disk_label = request->requests[d.seq].disk_label, cr.disk_type_flag = request->requests[d.seq
     ].disk_type_flag, cr.sequence_nbr = request->requests[d.seq].dist_seq,
     cr.use_posting_date_ind = request->requests[d.seq].use_posting_date_ind, cr
     .patient_consent_received_ind = request->requests[d.seq].patient_consent_received_ind, cr
     .release_reason_cd = request->requests[d.seq].release_reason_cd,
     cr.release_comment = request->requests[d.seq].release_comment, cr.requestor_type_flag = request
     ->requests[d.seq].requestor_type_flag, cr.requestor_value_txt = request->requests[d.seq].
     requestor_value_txt,
     cr.destination_type_flag = request->requests[d.seq].destination_type_flag, cr
     .destination_value_txt = request->requests[d.seq].destination_value_txt, cr.output_dest_cd =
     request->requests[d.seq].output_dest_cd,
     cr.output_content_type_str = request->requests[d.seq].output_content_type, cr
     .output_content_type_cd = request->requests[d.seq].output_content_type_cd, cr.prsnl_reltn_id =
     request->requests[d.seq].prsnl_reltn_id,
     cr.custodial_org_id = request->requests[d.seq].custodial_org_id, cr.email_subject_id =
     emailtextidrecord->qual[d.seq].long_text_id_email_subject, cr.email_body_id = emailtextidrecord
     ->qual[d.seq].long_text_id_email_message,
     cr.sender_email = request->requests[d.seq].sender_email, cr.message_ident = request->requests[d
     .seq].message_identifier, cr.contact_info = request->requests[d.seq].contact_info,
     cr.request_app_nbr = request->requests[d.seq].request_app_nbr, reply->requests[d.seq].
     request_dt_tm = cnvtdatetime(currentdatetime), cr.request_dt_tm = cnvtdatetime(currentdatetime),
     cr.updt_cnt = 0, cr.updt_dt_tm = cnvtdatetime(currentdatetime), cr.updt_id = reqinfo->updt_id,
     cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->updt_applctx, cr
     .patient_request_ind = request->requests[d.seq].patient_request_ind,
     cr.file_mask = request->requests[d.seq].file_mask, cr.file_name = request->requests[d.seq].
     file_name, cr.external_content_ident = request->requests[d.seq].external_content_ident,
     cr.external_content_name = request->requests[d.seq].external_content_name, cr
     .prsnl_role_profile_uid = request->requests[d.seq].prsnl_role_profile_uid, cr
     .concept_service_name = request->requests[d.seq].concept_service_name,
     cr.persona_txt = request->requests[d.seq].persona_txt
    PLAN (d)
     JOIN (cr)
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertReportRequests",
    "Insert report requests into cr_report_request table failed. Exiting script.",1,1)
   CALL insertrequestencntrs(null)
   CALL insertrequestsections(null)
   CALL insertrequestevents(null)
   CALL insertrequestoutputdestinations(null)
   CALL insertrequestactivities(null)
   CALL updatereportrequestdiscidentifier(null)
   CALL log_message("Exit InsertReportRequests subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE updatedirectparentresubmitcount(null)
   CALL log_message("Enter UpdateDirectParentResubmitCount subroutine.",log_level_debug)
   UPDATE  FROM cr_report_request cr
    SET cr.resubmit_cnt = (cr.resubmit_cnt+ 1), cr.updt_cnt = (cr.updt_cnt+ 1), cr.updt_dt_tm =
     cnvtdatetime(currentdatetime),
     cr.updt_id = reqinfo->updt_id, cr.updt_applctx = reqinfo->updt_applctx, cr.updt_task = reqinfo->
     updt_task
    WHERE expand(num,1,nnumofreq,cr.report_request_id,request->requests[num].direct_parent_request_id
     )
     AND cr.report_request_id > 0
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"UpdateDirectParentResubmitCount",
    "Update resubmit count into cr_report_request table failed. Exiting script.",1,0)
   CALL log_message("Exit UpdateDirectParentResubmitCount subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE updatereportrequestdiscidentifier(null)
   CALL log_message("Entering UpdateReportRequestDiscIdentifier subroutine.",log_level_debug)
   DECLARE requestidx = i4 WITH private, noconstant(1)
   DECLARE isdestinationdisc = i2 WITH private, noconstant(false)
   RECORD requeststoupdate(
     1 requests[*]
       2 reportrequestid = f8
       2 discidentifier = f8
   )
   WHILE ( NOT (isdestinationdisc)
    AND requestidx <= size(request->requests,5))
    IF ((request->requests[requestidx].disk_type_flag > 0))
     SET isdestinationdisc = true
    ENDIF
    SET requestidx += 1
   ENDWHILE
   IF ( NOT (isdestinationdisc))
    RETURN
   ENDIF
   SELECT INTO "nl:"
    cr.provider_prsnl_id
    FROM (dummyt d  WITH seq = size(reply->requests,5)),
     cr_report_request cr
    PLAN (d)
     JOIN (cr
     WHERE (cr.report_request_id=reply->requests[d.seq].report_request_id)
      AND cr.disk_type_flag > 0)
    ORDER BY cr.provider_prsnl_id
    HEAD REPORT
     diskidentifier = 0.0, requestcnt = 0
    HEAD cr.provider_prsnl_id
     diskidentifier = cr.report_request_id
    DETAIL
     requestcnt += 1, stat = alterlist(requeststoupdate->requests,requestcnt), requeststoupdate->
     requests[requestcnt].reportrequestid = cr.report_request_id,
     requeststoupdate->requests[requestcnt].discidentifier = diskidentifier
    WITH nocounter
   ;end select
   UPDATE  FROM (dummyt d  WITH seq = size(requeststoupdate->requests,5)),
     cr_report_request cr
    SET cr.disk_identifier = requeststoupdate->requests[d.seq].discidentifier
    PLAN (d)
     JOIN (cr
     WHERE (cr.report_request_id=requeststoupdate->requests[d.seq].reportrequestid))
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"UpdateReportRequestDiscIdentifier",
    "Update report request into cr_report_request table failed. Exiting script.",1,1)
   CALL log_message("Exiting UpdateReportRequestDiscIdentifier subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertrequestencntrs(null)
   CALL log_message("Entered InsertRequestEncntrs subroutine.",log_level_debug)
   INSERT  FROM (dummyt d1  WITH seq = size(request->requests,5)),
     (dummyt d2  WITH seq = 1),
     cr_report_request_encntr cen
    SET cen.report_request_encntr_id = seq(chart_seq,nextval), cen.report_request_id = reply->
     requests[d1.seq].report_request_id, cen.encntr_id = request->requests[d1.seq].xencntr_ids[d2.seq
     ].encntr_id,
     cen.encntr_seq = d2.seq, cen.updt_cnt = 0, cen.updt_dt_tm = cnvtdatetime(currentdatetime),
     cen.updt_id = reqinfo->updt_id, cen.updt_task = reqinfo->updt_task, cen.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d1
     WHERE maxrec(d2,size(request->requests[d1.seq].xencntr_ids,5))
      AND (request->requests[d1.seq].scope_flag=cross_encounter_scope))
     JOIN (d2)
     JOIN (cen)
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertReportRequests",
    "Insert encounter into cr_report_request_encntr table failed. Exiting script.",1,0)
   CALL log_message("Exit InsertRequestEncntrs subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertprintedsections(nnbrsections=i4,reportrequestid=f8,idx=i4) =null)
   CALL log_message("Entered InsertPrintedSections subroutine.",log_level_debug)
   SELECT INTO "nl:"
    FROM cr_printed_sections cp
    WHERE cp.report_request_id=reportrequestid
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM (dummyt d  WITH seq = value(nnbrsections)),
      cr_printed_sections cps
     SET cps.printed_section_id = seq(chart_seq,nextval), cps.report_request_id = reportrequestid,
      cps.section_id = request->requests[idx].printed_section[d.seq].section_id,
      cps.updt_cnt = 0, cps.updt_dt_tm = cnvtdatetime(currentdatetime), cps.updt_id = reqinfo->
      updt_id,
      cps.updt_task = reqinfo->updt_task, cps.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (cps)
     WITH nocounter
    ;end insert
   ENDIF
   CALL error_and_zero_check(curqual,"InsertReportRequests",
    "Insert printed section into cr_printed_sections table failed. Exiting script.",1,1)
   CALL log_message("Exit InsertPrintedSections.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertrequestsections(null)
   CALL log_message("Enter InsertRequestSections subroutine.",log_level_debug)
   INSERT  FROM (dummyt d1  WITH seq = size(request->requests,5)),
     (dummyt d2  WITH seq = 1),
     cr_report_request_section csect
    SET csect.report_request_section_id = seq(chart_seq,nextval), csect.report_request_id = reply->
     requests[d1.seq].report_request_id, csect.section_id = request->requests[d1.seq].sections[d2.seq
     ].section_id,
     csect.updt_cnt = 0, csect.updt_dt_tm = cnvtdatetime(currentdatetime), csect.updt_id = reqinfo->
     updt_id,
     csect.updt_task = reqinfo->updt_task, csect.updt_applctx = reqinfo->updt_applctx
    PLAN (d1
     WHERE maxrec(d2,size(request->requests[d1.seq].sections,5)))
     JOIN (d2)
     JOIN (csect)
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertRequestSections",
    "Insert sections into cr_report_request_section table failed. Exiting script.",1,0)
   CALL log_message("Exit InsertRequestSections subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertrequestevents(null)
   CALL log_message("Enter InsertRequestEvents subroutine.",log_level_debug)
   INSERT  FROM (dummyt d1  WITH seq = size(request->requests,5)),
     (dummyt d2  WITH seq = 1),
     cr_report_request_event cevent
    SET cevent.report_request_event_id = seq(chart_seq,nextval), cevent.report_request_id = reply->
     requests[d1.seq].report_request_id, cevent.event_id = request->requests[d1.seq].events[d2.seq].
     event_id,
     cevent.updt_cnt = 0, cevent.updt_dt_tm = cnvtdatetime(currentdatetime), cevent.updt_id = reqinfo
     ->updt_id,
     cevent.updt_task = reqinfo->updt_task, cevent.updt_applctx = reqinfo->updt_applctx
    PLAN (d1
     WHERE maxrec(d2,size(request->requests[d1.seq].events,5))
      AND (((request->requests[d1.seq].scope_flag=event_scope)) OR ((((request->requests[d1.seq].
     scope_flag=event_plus_scope)) OR ((request->requests[d1.seq].eso_trigger_id > 0))) )) )
     JOIN (d2)
     JOIN (cevent)
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertRequestEvents",
    "Insert events into cr_report_request_event table failed. Exiting script.",1,0)
   CALL log_message("Exit InsertRequestEvents subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertrequestoutputdestinations(null)
   CALL log_message("Enter InsertRequestOutputDestinations subroutine.",log_level_debug)
   INSERT  FROM (dummyt d1  WITH seq = size(request->requests,5)),
     (dummyt d2  WITH seq = 1),
     cr_output_destination coutputdest
    SET coutputdest.cr_output_destination_id = seq(chart_seq,nextval), coutputdest.report_request_id
      = reply->requests[d1.seq].report_request_id, coutputdest.output_dest_cd = request->requests[d1
     .seq].output_destinations[d2.seq].output_dest_cd,
     coutputdest.dms_service_ident = request->requests[d1.seq].output_destinations[d2.seq].
     dms_service_ident, coutputdest.dms_fax_distribute_dt_tm =
     IF ((request->requests[d1.seq].output_destinations[d2.seq].dms_fax_distribute_dt_tm != null))
      cnvtdatetime(request->requests[d1.seq].output_destinations[d2.seq].dms_fax_distribute_dt_tm)
     ELSE null
     ENDIF
     , coutputdest.dms_adhoc_fax_number_txt = request->requests[d1.seq].output_destinations[d2.seq].
     dms_adhoc_fax_number,
     coutputdest.disk_label = request->requests[d1.seq].output_destinations[d2.seq].disk_label,
     coutputdest.disk_type_flag = request->requests[d1.seq].output_destinations[d2.seq].
     disk_type_flag, coutputdest.copies_nbr = request->requests[d1.seq].output_destinations[d2.seq].
     copies_nbr,
     coutputdest.updt_cnt = 0, coutputdest.updt_dt_tm = cnvtdatetime(currentdatetime), coutputdest
     .updt_id = reqinfo->updt_id,
     coutputdest.updt_task = reqinfo->updt_task, coutputdest.updt_applctx = reqinfo->updt_applctx
    PLAN (d1
     WHERE maxrec(d2,size(request->requests[d1.seq].output_destinations,5)))
     JOIN (d2)
     JOIN (coutputdest)
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertRequestOutputDestinations",
    "Insert output_destinations into cr_output_destination table failed. Exiting script.",1,0)
   CALL log_message("Exit InsertRequestOutputDestinations subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertrequestactivities(null)
   CALL log_message("Entered InsertRequestActivities subroutine.",log_level_debug)
   INSERT  FROM (dummyt d1  WITH seq = size(request->requests,5)),
     cr_report_request_activity act
    SET act.report_request_activity_id = seq(chart_act_seq,nextval), act.report_request_id = reply->
     requests[d1.seq].report_request_id, act.report_status_cd = reply->requests[d1.seq].
     report_status_cd
    PLAN (d1)
     JOIN (act)
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertRequestActivities",
    "Insertion into cr_report_request_activity table failed. Exiting script.",1,0)
   CALL log_message("Exit InsertRequestActivities subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertrequestactivitiesonreportrequestupdate(null)
   CALL log_message("Entered InsertRequestActivitiesOnReportRequestUpdate subroutine.",
    log_level_debug)
   FOR (i = 1 TO size(request->requests,5))
     IF ((request->requests[i].report_status_cd=skipped_cd))
      INSERT  FROM cr_report_request_activity act
       SET act.report_request_activity_id = seq(chart_act_seq,nextval), act.report_request_id =
        request->requests[i].report_request_id, act.report_status_cd = request->requests[i].
        report_status_cd
       PLAN (act)
       WITH nocounter
      ;end insert
     ENDIF
   ENDFOR
   CALL error_and_zero_check(curqual,"InsertRequestActivitiesOnReportRequestUpdate",
    "Insertion into cr_report_request_activity table failed. Exiting script.",1,0)
   CALL log_message("Exit InsertRequestActivitiesOnReportRequestUpdate subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE updatereportrequests(null)
   CALL log_message("Entered UpdateReportRequests subroutine.",log_level_debug)
   IF ((request->update_status_only_ind=0))
    UPDATE  FROM (dummyt d  WITH seq = value(nnumofreq)),
      cr_report_request cr
     SET cr.report_status_cd = request->requests[d.seq].report_status_cd, cr.total_pages_nbr =
      request->requests[d.seq].total_pages_nbr, cr.processing_time = request->requests[d.seq].
      processing_time,
      cr.updt_cnt = (cr.updt_cnt+ 1), cr.updt_dt_tm = cnvtdatetime(currentdatetime), cr.updt_id =
      reqinfo->updt_id,
      cr.updt_applctx = reqinfo->updt_applctx, cr.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (cr
      WHERE (cr.report_request_id=request->requests[d.seq].report_request_id))
     WITH nocounter
    ;end update
   ELSE
    CALL insertrequeststatuslog(null)
    UPDATE  FROM (dummyt d  WITH seq = value(nnumofreq)),
      cr_report_request cr
     SET cr.report_status_cd = request->requests[d.seq].report_status_cd, cr.status_text_id =
      requestlogrecord->qual[d.seq].long_text_id_status, cr.updt_cnt = (cr.updt_cnt+ 1),
      cr.updt_dt_tm = cnvtdatetime(currentdatetime), cr.updt_id = reqinfo->updt_id, cr.updt_applctx
       = reqinfo->updt_applctx,
      cr.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (cr
      WHERE (cr.report_request_id=request->requests[d.seq].report_request_id))
     WITH nocounter
    ;end update
   ENDIF
   IF ((request->update_status_only_ind=0))
    DECLARE nnumofsections = i4
    FOR (i = 1 TO nnumofreq)
     SET nnumofsections = size(request->requests[i].printed_section,5)
     IF (nnumofsections > 0)
      CALL insertprintedsections(nnumofsections,request->requests[i].report_request_id,i)
     ENDIF
    ENDFOR
   ENDIF
   CALL insertrequestactivitiesonreportrequestupdate(null)
   CALL error_and_zero_check(curqual,"UpdateReportRequests",
    "Update report request into cr_report_request table failed. Exiting script.",1,1)
   CALL log_message("Exit UpdateReportRequests subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertemailsubjectandmessageintolongtext(null)
   CALL log_message("Entered InsertEmailMessageIntoLongText subroutine.",log_level_debug)
   FOR (n = 1 TO nnumofreq)
    IF (size(request->requests[n].email_subject)=0)
     SET emailtextidrecord->qual[n].long_text_id_email_subject = 0
    ELSE
     SELECT INTO "nl:"
      textidforsubject = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       emailtextidrecord->qual[n].long_text_id_email_subject = textidforsubject
      WITH nocounter
     ;end select
    ENDIF
    IF (size(request->requests[n].email_body)=0)
     SET emailtextidrecord->qual[n].long_text_id_email_message = 0
    ELSE
     SELECT INTO "nl:"
      textidformessage = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       emailtextidrecord->qual[n].long_text_id_email_message = textidformessage
      WITH nocounter
     ;end select
    ENDIF
   ENDFOR
   INSERT  FROM (dummyt d  WITH seq = value(nnumofreq)),
     long_text lt
    SET lt.seq = 1, lt.long_text_id = emailtextidrecord->qual[d.seq].long_text_id_email_subject, lt
     .parent_entity_id = reply->requests[d.seq].report_request_id,
     lt.parent_entity_name = "CR_REPORT_REQUEST", lt.long_text = request->requests[d.seq].
     email_subject, lt.active_ind = 1,
     lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm = cnvtdatetime(
      currentdatetime), lt.active_status_prsnl_id = reqinfo->updt_id,
     lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(currentdatetime), lt.updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx
    PLAN (d
     WHERE (emailtextidrecord->qual[d.seq].long_text_id_email_subject != 0))
     JOIN (lt)
    WITH nocounter
   ;end insert
   INSERT  FROM (dummyt d  WITH seq = value(nnumofreq)),
     long_text lt
    SET lt.seq = 1, lt.long_text_id = emailtextidrecord->qual[d.seq].long_text_id_email_message, lt
     .parent_entity_id = reply->requests[d.seq].report_request_id,
     lt.parent_entity_name = "CR_REPORT_REQUEST", lt.long_text = request->requests[d.seq].email_body,
     lt.active_ind = 1,
     lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm = cnvtdatetime(
      currentdatetime), lt.active_status_prsnl_id = reqinfo->updt_id,
     lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(currentdatetime), lt.updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx
    PLAN (d
     WHERE (emailtextidrecord->qual[d.seq].long_text_id_email_message != 0))
     JOIN (lt)
    WITH nocounter
   ;end insert
   CALL log_message("Exit InsertEmailMessageIntoLongText subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertrequeststatuslog(null)
   CALL log_message("Entered InsertRequestStatusLog subroutine.",log_level_debug)
   FOR (n = 1 TO nnumofreq)
     IF (size(request->requests[n].status_log)=0)
      SET requestlogrecord->qual[n].long_text_id_status = 0
      SET requestlogrecord->qual[n].report_request_id = request->requests[n].report_request_id
     ELSE
      SELECT INTO "nl:"
       statuslog_textid = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        requestlogrecord->qual[n].long_text_id_status = statuslog_textid, requestlogrecord->qual[n].
        report_request_id = request->requests[n].report_request_id
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   INSERT  FROM (dummyt d  WITH seq = value(nnumofreq)),
     long_text lt
    SET lt.seq = 1, lt.long_text_id = requestlogrecord->qual[d.seq].long_text_id_status, lt
     .parent_entity_id = requestlogrecord->qual[d.seq].report_request_id,
     lt.parent_entity_name = "CR_REPORT_REQUEST", lt.long_text = request->requests[d.seq].status_log,
     lt.active_ind = 1,
     lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm = cnvtdatetime(
      currentdatetime), lt.active_status_prsnl_id = reqinfo->updt_id,
     lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(currentdatetime), lt.updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx
    PLAN (d
     WHERE (requestlogrecord->qual[d.seq].long_text_id_status > 0))
     JOIN (lt)
    WITH nocounter
   ;end insert
   CALL log_message("Exit InsertRequestStatusLog subroutine.",log_level_debug)
 END ;Subroutine
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 FREE RECORD temprec
 CALL log_message("End of script: cr_upd_report_requests",log_level_debug)
END GO
