CREATE PROGRAM cp_poll_for_new_requests:dba
 RECORD reply(
   1 qual[*]
     2 chart_request_id = f8
     2 chart_batch_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD unprocessed_charts(
   1 qual[*]
     2 chart_request_id = f8
     2 new_status_cd = f8
     2 output_dest_cd = f8
     2 request_type = i4
 )
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
 SET log_program_name = "CP_POLL_FOR_NEW_REQUESTS"
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE req_count = i4 WITH noconstant(0), protect
 DECLARE prov_count = i4 WITH noconstant(0), protect
 DECLARE chart_id = f8 WITH noconstant(0.0), protect
 DECLARE batch_id = f8 WITH noconstant(0.0), protect
 DECLARE request_in_recovery = i2 WITH noconstant(0), protect
 DECLARE where_clause = vc WITH noconstant(""), protect
 DECLARE unprocessed_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"UNPROCESSED")), protect
 DECLARE inrecovery_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"INRECOVERY")), protect
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"INPROCESS")), protect
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"PENDING")), protect
 DECLARE printnotinst_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"PRINTNOTINST")), protect
 DECLARE buildwhereclause(null) = null WITH protect
 DECLARE findchartorbatchforlocalprinting(null) = null WITH protect
 DECLARE findchartorbatchforexternalprinting(null) = null WITH protect
 DECLARE processunprocessedrequests(null) = null WITH protect
 DECLARE updateunprocessedcharts(null) = null WITH protect
 DECLARE getchartorbatch(null) = null WITH protect
 DECLARE updatechartorbatchtoinprocess(null) = null WITH protect
 SET reply->status_data.status = "F"
 CALL log_message("Starting script: cp_poll_for_new_requests",log_level_debug)
 IF ((request->chart_request_id > 0))
  CALL getchartorbatch(null)
 ELSE
  CALL buildwhereclause(null)
  IF ((request->local_host_printing=1))
   CALL findchartorbatchforlocalprinting(null)
  ELSE
   CALL findchartorbatchforexternalprinting(null)
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
 SUBROUTINE buildwhereclause(null)
   CALL log_message("In BuildWhereClause()",log_level_debug)
   SET c1 = fillstring(100," ")
   SET c3 = fillstring(100," ")
   SET c4 = fillstring(100," ")
   SET c5 = fillstring(100," ")
   SET c6 = fillstring(100," ")
   SET szor = " or "
   IF (btest(request->request_type,0)=1)
    SET c1 = "(cr.request_type = 1)"
   ELSE
    SET c1 = "(0 != 0)"
   ENDIF
   IF (btest(request->request_type,1)=1)
    SET c2 = "(cr.request_type = 2)"
   ELSE
    SET c2 = "(0 != 0)"
   ENDIF
   IF (btest(request->request_type,2)=1)
    SET c3 = "(cr.request_type = 4 and cr.chart_batch_id+0 > 0.0)"
   ELSE
    SET c3 = "(0 != 0)"
   ENDIF
   IF (btest(request->request_type,3)=1)
    SET c4 = "(cr.request_type = 8 and cr.chart_batch_id+0 > 0.0)"
   ELSE
    SET c4 = "(0 != 0)"
   ENDIF
   SET c5 = build(" (cr.chart_status_cd = INRECOVERY_CD and cr.server_name = ",
    " trim(request->server_name)) OR (")
   SET c6 = build(" )")
   SET where_clause = concat(trim(c5),trim(c1),szor,trim(c2),szor,
    trim(c3),szor,trim(c4),trim(c6))
   CALL echo(trim(where_clause))
   SET where_clause_size = size(where_clause,1)
   CALL error_and_zero_check(where_clause_size,"Generating where_clause","BuildWhereClause",1,1)
 END ;Subroutine
 SUBROUTINE findchartorbatchforexternalprinting(null)
   CALL log_message("In FindChartOrBatch()",log_level_debug)
   SELECT INTO "nl:"
    cr.chart_request_id
    FROM chart_request cr
    PLAN (cr
     WHERE parser(where_clause)
      AND cr.chart_status_cd IN (unprocessed_cd, pending_cd))
    ORDER BY cr.request_dt_tm, cr.chart_request_id
    DETAIL
     chart_id = cr.chart_request_id, batch_id = cr.chart_batch_id
    WITH nocounter, maxqual(cr,1)
   ;end select
   CALL echo(build("chart_id = ",chart_id))
   CALL echo(build("batch_id = ",batch_id))
   CALL error_and_zero_check(curqual,"Finding request or batch","FindChartOrBatchForExternalPrinting",
    1,0)
   IF (chart_id > 0)
    CALL getchartorbatch(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE findchartorbatchforlocalprinting(null)
   CALL log_message("In FindChartOrBatch()",log_level_debug)
   SELECT INTO "nl:"
    cr.chart_request_id
    FROM chart_request cr,
     chart_server_printer csp
    PLAN (cr
     WHERE parser(where_clause)
      AND cr.chart_status_cd IN (unprocessed_cd, pending_cd))
     JOIN (csp
     WHERE csp.output_dest_cd=cr.output_dest_cd
      AND csp.cs_param_id IN (0, request->cs_param_id, request->ghost_fax_id))
    ORDER BY cr.request_dt_tm, cr.chart_request_id
    DETAIL
     chart_id = cr.chart_request_id, batch_id = cr.chart_batch_id
    WITH nocounter, maxqual(cr,1)
   ;end select
   CALL echo(build("chart_id = ",chart_id))
   CALL echo(build("batch_id = ",batch_id))
   CALL error_and_zero_check(curqual,"Finding request or batch","FindChartOrBatchForLocalPrinting",1,
    0)
   IF (chart_id > 0)
    CALL getchartorbatch(null)
   ELSE
    CALL processunprocessedrequests(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE getchartorbatch(null)
   CALL log_message("In GetChartOrBatch()",log_level_debug)
   SELECT
    IF ((request->chart_request_id > 0))
     PLAN (cr
      WHERE (cr.chart_request_id=request->chart_request_id))
    ELSEIF (batch_id > 0)
     PLAN (cr
      WHERE cr.chart_batch_id=batch_id
       AND cr.chart_status_cd IN (unprocessed_cd, pending_cd, inrecovery_cd))
    ELSEIF (chart_id > 0)
     PLAN (cr
      WHERE cr.chart_request_id=chart_id
       AND cr.chart_status_cd IN (unprocessed_cd, pending_cd, inrecovery_cd))
    ELSE
     PLAN (cr
      WHERE 1=0)
    ENDIF
    INTO "nl:"
    cr.chart_request_id
    FROM chart_request cr
    ORDER BY cr.request_dt_tm, cr.chart_request_id
    HEAD REPORT
     req_count = 0
    DETAIL
     req_count += 1
     IF (mod(req_count,10)=1)
      stat = alterlist(reply->qual,(req_count+ 9))
     ENDIF
     reply->qual[req_count].chart_request_id = cr.chart_request_id, reply->qual[req_count].
     chart_batch_id = cr.chart_batch_id
     IF (cr.chart_status_cd=inrecovery_cd)
      request_in_recovery = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->qual,req_count)
    WITH nocounter, forupdatewait(cr)
   ;end select
   CALL error_and_zero_check(curqual,"Pick Up Request","GetRequestOrBatch",1,1)
   CALL updatechartorbatchtoinprocess(null)
 END ;Subroutine
 SUBROUTINE processunprocessedrequests(null)
   CALL log_message("In ProcessUnprocessedRequests()",log_level_debug)
   SELECT INTO "nl:"
    FROM chart_request cr
    PLAN (cr
     WHERE parser(where_clause)
      AND cr.chart_status_cd=unprocessed_cd
      AND cr.output_dest_cd > 0)
    ORDER BY cr.request_dt_tm, cr.chart_request_id
    HEAD REPORT
     chart_count = 0
    DETAIL
     chart_count += 1
     IF (mod(chart_count,10)=1)
      stat = alterlist(unprocessed_charts->qual,(chart_count+ 9))
     ENDIF
     unprocessed_charts->qual[chart_count].chart_request_id = cr.chart_request_id, unprocessed_charts
     ->qual[chart_count].output_dest_cd = cr.output_dest_cd, unprocessed_charts->qual[chart_count].
     request_type = cr.request_type
    FOOT REPORT
     stat = alterlist(unprocessed_charts->qual,chart_count)
    WITH nocounter, forupdatewait(cr)
   ;end select
   CALL error_and_zero_check(size(unprocessed_charts->qual,5),"cp_poll_for_new_requests",
    "ProcessUnprocessedRequest",1,1)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(unprocessed_charts->qual,5))),
     chart_server_printer csp,
     chart_server_settings css,
     chart_request cr
    PLAN (d)
     JOIN (cr
     WHERE (cr.chart_request_id=unprocessed_charts->qual[d.seq].chart_request_id))
     JOIN (csp
     WHERE (csp.output_dest_cd= Outerjoin(cr.output_dest_cd)) )
     JOIN (css
     WHERE (css.cs_param_id= Outerjoin(csp.cs_param_id)) )
    ORDER BY css.cs_param_id
    HEAD REPORT
     do_nothing = 0
    HEAD d.seq
     IF (csp.output_dest_cd=0)
      unprocessed_charts->qual[d.seq].new_status_cd = printnotinst_cd
     ENDIF
    DETAIL
     IF (btest(unprocessed_charts->qual[d.seq].request_type,0)=1
      AND css.adhoc_ind=1)
      unprocessed_charts->qual[d.seq].new_status_cd = pending_cd
     ELSEIF (btest(unprocessed_charts->qual[d.seq].request_type,1)=1
      AND css.expedite_ind=1)
      unprocessed_charts->qual[d.seq].new_status_cd = pending_cd
     ELSEIF (btest(unprocessed_charts->qual[d.seq].request_type,2)=1
      AND css.distribution_ind=1)
      unprocessed_charts->qual[d.seq].new_status_cd = pending_cd
     ELSEIF (btest(unprocessed_charts->qual[d.seq].request_type,3)=1
      AND css.mrp_ind=1)
      unprocessed_charts->qual[d.seq].new_status_cd = pending_cd
     ENDIF
    FOOT  d.seq
     IF ((unprocessed_charts->qual[d.seq].new_status_cd=0))
      unprocessed_charts->qual[d.seq].new_status_cd = printnotinst_cd
     ENDIF
    FOOT REPORT
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL echorecord(unprocessed_charts)
   CALL error_and_zero_check(curqual,"cp_poll_for_new_requests","ProcessUnprocessedRequest",1,1)
   IF (curqual > 0)
    CALL updateunprocessedcharts(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE updatechartorbatchtoinprocess(null)
   CALL log_message("In UpdateChartOrBatchToInprocess()",log_level_debug)
   UPDATE  FROM chart_request c,
     (dummyt d  WITH seq = value(size(reply->qual,5)))
    SET c.chart_status_cd = inprocess_cd, c.process_time =
     IF (request_in_recovery=0) 0
     ELSE c.process_time
     ENDIF
     , c.server_name = request->server_name,
     c.active_ind = 1, c.active_status_cd = reqdata->active_status_cd, c.active_status_prsnl_id =
     reqinfo->updt_id,
     c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo
     ->updt_id,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (c
     WHERE (c.chart_request_id=reply->qual[d.seq].chart_request_id))
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"cp_poll_for_new_requests",
    "UpdateChartRequestOrBatchToInprocess",1,1)
 END ;Subroutine
 SUBROUTINE updateunprocessedcharts(null)
   CALL log_message("In UpdateUnprocessedCharts()",log_level_debug)
   UPDATE  FROM chart_request c,
     (dummyt d  WITH seq = value(size(unprocessed_charts->qual,5)))
    SET c.chart_status_cd = unprocessed_charts->qual[d.seq].new_status_cd, c.active_ind = 1, c
     .active_status_cd = reqdata->active_status_cd,
     c.active_status_prsnl_id = reqinfo->updt_id, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
     updt_task
    PLAN (d)
     JOIN (c
     WHERE (c.chart_request_id=unprocessed_charts->qual[d.seq].chart_request_id))
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"cp_poll_for_new_requests","UpdateUnprocessedCharts",1,1)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting cp_poll_for_new_requests script",log_level_debug)
 CALL echorecord(reply)
END GO
