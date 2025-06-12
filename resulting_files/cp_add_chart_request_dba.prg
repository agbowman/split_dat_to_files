CREATE PROGRAM cp_add_chart_request:dba
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
 SET log_program_name = "CP_ADD_CHART_REQUEST"
 FREE RECORD request_dates
 RECORD request_dates(
   1 qual[*]
     2 non_ce_begin_dt_tm = dq8
     2 non_ce_end_dt_tm = dq8
 )
 DECLARE x = i4
 SET stat = alterlist(request_dates->qual,size(request->qual,5))
 FOR (x = 1 TO size(request->qual,5))
  SET request_dates->qual[x].non_ce_begin_dt_tm = validate(request->qual[x].non_ce_begin_dt_tm,null)
  SET request_dates->qual[x].non_ce_end_dt_tm = validate(request->qual[x].non_ce_end_dt_tm,null)
 ENDFOR
 CALL echorecord(request_dates)
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 qual[*]
      2 chart_request_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD temp_request
 RECORD temp_request(
   1 qual[*]
     2 encntr_id = f8
     2 index_event_cnt = i4
     2 event_id_list[*]
       3 cr_event_id = f8
       3 event_id = f8
       3 result_status_cd = f8
 )
 DECLARE getchartrequestids(null) = null
 DECLARE insertchartrequest(null) = null
 DECLARE getencounterlist(null) = null
 DECLARE getchartbatchids(null) = null
 DECLARE nbr_to_add = i4 WITH noconstant(size(request->qual,5)), protect
 SET stat = alterlist(reply->qual,nbr_to_add)
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE idx2 = i4 WITH noconstant(0), protect
 DECLARE section_nbr = i4 WITH noconstant(0), protect
 DECLARE status_cd = f8 WITH constant(uar_get_code_by("MEANING",18609,"UNPROCESSED")), protect
 DECLARE current_date = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 CALL log_message("Begin script: cp_add_chart_request",log_level_debug)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF (nbr_to_add=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "cp_add_chart_request"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "WARNING! - This request has no items to add."
  CALL log_message(reply->status_data.subeventstatus[1].targetobjectvalue,log_level_debug)
  GO TO exit_script
 ENDIF
 IF ((request->qual[1].request_type=8)
  AND (request->qual[1].scope_flag=6)
  AND (request->qual[1].encntr_id=0.0))
  CALL getencounterlist(null)
  SET nbr_to_add = size(request->qual,5)
 ENDIF
 CALL getchartrequestids(null)
 IF (nbr_to_add > 0
  AND (((request->qual[1].request_type=8)) OR ((request->qual[1].request_type=4))) )
  CALL getchartbatchids(null)
 ENDIF
 CALL insertchartrequest(null)
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
 SUBROUTINE getchartbatchids(null)
   CALL log_message("In GetChartBatchIds()",log_level_debug)
   FREE RECORD unique_output_dests
   RECORD unique_output_dests(
     1 qual[*]
       2 output_dest = f8
       2 batch_id = f8
   )
   DECLARE printer_count = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    output_dest = request->qual[d.seq].output_dest_cd
    FROM (dummyt d  WITH seq = size(request->qual,5))
    PLAN (d)
    ORDER BY output_dest
    HEAD REPORT
     printer_count = 0
    HEAD output_dest
     printer_count += 1
     IF (mod(printer_count,10)=1)
      stat = alterlist(unique_output_dests->qual,(printer_count+ 9))
     ENDIF
     unique_output_dests->qual[printer_count].output_dest = output_dest
    FOOT REPORT
     stat = alterlist(unique_output_dests->qual,printer_count)
    WITH nocounter
   ;end select
   FOR (idx = 1 TO printer_count)
    SELECT INTO "nl:"
     y2 = seq(chart_seq,nextval)
     FROM dual
     DETAIL
      unique_output_dests->qual[idx].batch_id = y2
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"DUAL_3","GetChartBatchIds",1,1)
   ENDFOR
   SELECT INTO "nl:"
    output_dest = request->qual[d1.seq].output_dest_cd
    FROM (dummyt d1  WITH seq = size(request->qual,5)),
     (dummyt d2  WITH seq = size(unique_output_dests->qual,5))
    PLAN (d1)
     JOIN (d2)
    ORDER BY d1.seq
    HEAD d1.seq
     locval = locateval(idx2,1,printer_count,output_dest,unique_output_dests->qual[idx2].output_dest),
     request->qual[d1.seq].batch_id = unique_output_dests->qual[locval].batch_id
    WITH nocounter
   ;end select
   CALL error_and_zero_check(1,"AssignBatchIdPerPrinter","GetChartBatchIds",1,0)
 END ;Subroutine
 SUBROUTINE getchartrequestids(null)
   CALL log_message("In GetChartRequestIds()",log_level_debug)
   DECLARE nbr_of_events = i4 WITH noconstant(0), protect
   FOR (idx = 1 TO nbr_to_add)
     SELECT INTO "nl:"
      y2 = seq(chart_seq,nextval)
      FROM dual
      DETAIL
       reply->qual[idx].chart_request_id = y2
      WITH nocounter
     ;end select
     CALL error_and_zero_check(curqual,"DUAL_1","GETCHARTREQUESTIDS",1,1)
     SET nbr_of_events = size(request->qual[idx].event_id_list,5)
     FOR (idx2 = 1 TO nbr_of_events)
      SELECT INTO "nl:"
       x2 = seq(chart_request_event_seq,nextval)
       FROM dual
       DETAIL
        request->qual[idx].event_id_list[idx2].cr_event_id = x2
       WITH nocounter
      ;end select
      CALL error_and_zero_check(curqual,"DUAL_2","GETCHARTREQUESTIDS",1,1)
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE insertchartrequest(null)
   CALL log_message("In InsertChartRequest()",log_level_debug)
   DECLARE idxreq = i4 WITH noconstant(0), protect
   INSERT  FROM chart_request cr,
     (dummyt d  WITH seq = value(nbr_to_add))
    SET cr.seq = 1, cr.chart_request_id = reply->qual[d.seq].chart_request_id, cr.handle_id = 0,
     cr.request_type = request->qual[d.seq].request_type, cr.scope_flag = request->qual[d.seq].
     scope_flag, cr.event_ind = request->qual[d.seq].event_ind,
     cr.person_id = request->qual[d.seq].person_id, cr.encntr_id = request->qual[d.seq].encntr_id, cr
     .order_id = request->qual[d.seq].order_id,
     cr.accession_nbr =
     IF ((request->qual[d.seq].accession_nbr > " ")) request->qual[d.seq].accession_nbr
     ELSE null
     ENDIF
     , cr.request_prsnl_id =
     IF (((cr.request_type=1) OR (cr.request_type=8)) ) reqinfo->updt_id
     ELSEIF (validate(request->qual[d.seq].requesting_prsnl_id,0) > 0) validate(request->qual[d.seq].
       requesting_prsnl_id,0)
     ELSEIF (size(trim(validate(request->qual[d.seq].trigger_name,"")))=0
      AND validate(request->qual[d.seq].chart_trigger_id,0)=0) reqinfo->updt_id
     ELSE 0
     ENDIF
     , cr.chart_format_id = request->qual[d.seq].chart_format_id,
     cr.trigger_id = request->qual[d.seq].trigger_id, cr.trigger_type = request->qual[d.seq].
     trigger_type, cr.distribution_id = request->qual[d.seq].distribution_id,
     cr.dist_run_type_cd = request->qual[d.seq].dist_run_type_cd, cr.dist_run_dt_tm = cnvtdatetime(
      request->qual[d.seq].dist_run_dt_tm), cr.dist_terminator_ind = request->qual[d.seq].
     dist_terminator_ind,
     cr.dist_initiator_ind = request->qual[d.seq].dist_initiator_ind, cr.reader_group = request->
     qual[d.seq].reader_group, cr.date_range_ind =
     IF ((request->qual[d.seq].date_range_ind=1)
      AND  NOT ((request->qual[d.seq].request_type IN (1, 2)))
      AND cnvtdatetime(request->qual[d.seq].begin_dt_tm)=null
      AND cnvtdatetime(request->qual[d.seq].end_dt_tm)=null) 0
     ELSEIF ((request->qual[d.seq].request_type IN (1, 2))) 1
     ELSE request->qual[d.seq].date_range_ind
     ENDIF
     ,
     cr.begin_dt_tm =
     IF (cnvtdatetime(request->qual[d.seq].begin_dt_tm)=null
      AND ((cnvtdatetime(request->qual[d.seq].end_dt_tm) != null) OR ((request->qual[d.seq].
     request_type IN (1, 2)))) ) cnvtdatetime("01-jan-1800 00:00:00.00")
     ELSE cnvtdatetime(request->qual[d.seq].begin_dt_tm)
     ENDIF
     , cr.end_dt_tm =
     IF (cnvtdatetime(request->qual[d.seq].end_dt_tm)=null
      AND ((cnvtdatetime(request->qual[d.seq].begin_dt_tm) != null) OR ((request->qual[d.seq].
     request_type IN (1, 2)))) ) cnvtdatetime(current_date)
     ELSE cnvtdatetime(request->qual[d.seq].end_dt_tm)
     ENDIF
     , cr.page_range_ind = request->qual[d.seq].page_range_ind,
     cr.begin_page = request->qual[d.seq].begin_page, cr.end_page = request->qual[d.seq].end_page, cr
     .print_complete_flag = request->qual[d.seq].print_complete_flag,
     cr.chart_pending_flag = request->qual[d.seq].chart_pending_flag, cr.addl_copies = request->qual[
     d.seq].addl_copies, cr.output_dest_cd = request->qual[d.seq].output_dest_cd,
     cr.output_device_cd = request->qual[d.seq].output_device_cd, cr.rrd_deliver_dt_tm = cnvtdatetime
     (request->qual[d.seq].rrd_deliver_dt_tm), cr.rrd_country_access = request->qual[d.seq].
     rrd_country_access,
     cr.rrd_area_code = request->qual[d.seq].rrd_area_code, cr.rrd_exchange = request->qual[d.seq].
     rrd_exchange, cr.rrd_phone_suffix = request->qual[d.seq].rrd_phone_suffix,
     cr.status_flag = 0, cr.chart_status_cd = status_cd, cr.active_ind = 1,
     cr.active_status_cd = reqdata->active_status_cd, cr.active_status_dt_tm = cnvtdatetime(
      current_date), cr.active_status_prsnl_id = reqinfo->updt_id,
     cr.updt_cnt = 0, cr.updt_dt_tm = cnvtdatetime(current_date), cr.updt_id = reqinfo->updt_id,
     cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->updt_applctx, cr.request_dt_tm =
     cnvtdatetime(current_date),
     cr.resubmit_cnt = 0, cr.resubmit_dt_tm = null, cr.recover_cnt = 0,
     cr.recover_dt_tm = null, cr.mcis_ind =
     IF ((request->qual[d.seq].distribution_id > 0)
      AND (request->qual[d.seq].request_type=2)) 1
     ELSE 0
     ENDIF
     , cr.prsnl_person_id = request->qual[d.seq].prsnl_person_id,
     cr.prsnl_person_r_cd = request->qual[d.seq].prsnl_person_r_cd, cr.process_time = 0.0, cr
     .server_name = null,
     cr.total_pages = 0, cr.file_storage_cd = request->qual[d.seq].file_storage_cd, cr
     .file_storage_location = request->qual[d.seq].file_storage_location,
     cr.trigger_name = validate(request->qual[d.seq].trigger_name,""), cr.prsnl_reltn_id = validate(
      request->qual[d.seq].prsnl_reltn_id,0), cr.chart_route_id = validate(request->qual[d.seq].
      chart_route_id,0),
     cr.sequence_group_id = validate(request->qual[d.seq].sequence_group_id,0), cr.chart_batch_id =
     validate(request->qual[d.seq].batch_id,0), cr.suppress_mrpnodata_ind = validate(request->qual[d
      .seq].suppress_mrpnodata_ind,0),
     cr.order_group_flag = validate(request->qual[d.seq].order_group_flag,0), cr.group_order_id =
     validate(request->qual[d.seq].group_order_id,0), cr.result_lookup_ind = validate(request->qual[d
      .seq].result_lookup_ind,0),
     cr.cr_mask_id = validate(request->qual[d.seq].cr_mask_id,0), cr.chart_trigger_id = validate(
      request->qual[d.seq].chart_trigger_id,0), cr.user_role_profile = validate(request->qual[d.seq].
      user_role_profile,""),
     cr.non_ce_begin_dt_tm = cnvtdatetime(request_dates->qual[d.seq].non_ce_begin_dt_tm), cr
     .non_ce_end_dt_tm = cnvtdatetime(request_dates->qual[d.seq].non_ce_end_dt_tm)
    PLAN (d)
     JOIN (cr)
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_REQUEST","INSERTCHARTREQUEST",1,1)
   FOR (idxreq = 1 TO nbr_to_add)
     CALL insertchartrequestevent(idxreq)
     CALL insertchartrequestencntr(idxreq)
     CALL insertchartrequestorder(idxreq)
     CALL insertchartrequestsection(idxreq)
     CALL insertchartrequestaudit(idxreq)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (insertchartrequestevent(idx=i4(val)) =null)
   CALL log_message("In InsertChartRequestEvent()",log_level_debug)
   DECLARE nbr_of_events = i4 WITH noconstant(size(request->qual[idx].event_id_list,5)), protect
   IF (nbr_of_events)
    INSERT  FROM chart_request_event cre,
      (dummyt d  WITH seq = value(nbr_of_events))
     SET cre.cr_event_id = request->qual[idx].event_id_list[d.seq].cr_event_id, cre.chart_request_id
       = reply->qual[idx].chart_request_id, cre.event_id = request->qual[idx].event_id_list[d.seq].
      event_id,
      cre.result_status_cd = request->qual[idx].event_id_list[d.seq].result_status_cd, cre
      .cr_event_seq = d.seq, cre.updt_cnt = 0,
      cre.updt_dt_tm = cnvtdatetime(current_date), cre.updt_id = reqinfo->updt_id, cre.updt_task =
      reqinfo->updt_task,
      cre.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (cre)
     WITH nocounter
    ;end insert
    CALL error_and_zero_check(curqual,"CHART_REQUEST_EVENT","INSERTCHARTREQUESTEVENT",1,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (insertchartrequestencntr(idx=i4(val)) =null)
   CALL log_message("In InsertChartRequestEncntr()",log_level_debug)
   DECLARE idxencntr = i4 WITH noconstant(0), protect
   DECLARE next_sequence = f8 WITH noconstant(0.0), protect
   IF ((request->qual[idx].scope_flag=5))
    SET encntr_nbr = size(request->qual[idx].encntr_list,5)
    FOR (idxencntr = 1 TO encntr_nbr)
      SELECT INTO "nl:"
       w2 = seq(chart_request_encntr_seq,nextval)
       FROM dual
       DETAIL
        next_sequence = w2
       WITH nocounter
      ;end select
      INSERT  FROM chart_request_encntr cn
       SET cn.chart_request_encntr_id = next_sequence, cn.chart_request_id = reply->qual[idx].
        chart_request_id, cn.encntr_id = request->qual[idx].encntr_list[idxencntr].encntr_id,
        cn.cr_encntr_seq = idxencntr, cn.active_ind = 1, cn.active_status_cd = reqdata->
        active_status_cd,
        cn.active_status_dt_tm = cnvtdatetime(current_date), cn.active_status_prsnl_id = reqinfo->
        updt_id, cn.updt_cnt = 0,
        cn.updt_dt_tm = cnvtdatetime(current_date), cn.updt_id = reqinfo->updt_id, cn.updt_task =
        reqinfo->updt_task,
        cn.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      CALL error_and_zero_check(curqual,"CHART_REQUEST_ENCNTR","INSERTCHARTREQUESTENCNTR",1,1)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (insertchartrequestorder(idx=i4(val)) =null)
  CALL log_message("In InsertChartRequestOrder()",log_level_debug)
  IF (validate(request->qual[idx].order_list))
   IF ((request->qual[idx].scope_flag=3)
    AND size(request->qual[idx].order_list,5) > 0)
    INSERT  FROM chart_request_order cro,
      (dummyt d  WITH seq = value(size(request->qual[idx].order_list,5)))
     SET cro.chart_request_order_id = seq(chart_request_event_seq,nextval), cro.chart_request_id =
      reply->qual[idx].chart_request_id, cro.order_id = request->qual[idx].order_list[d.seq].order_id,
      cro.active_ind = 1, cro.active_status_cd = reqdata->active_status_cd, cro.active_status_dt_tm
       = cnvtdatetime(current_date),
      cro.active_status_prsnl_id = reqinfo->updt_id, cro.updt_cnt = 0, cro.updt_dt_tm = cnvtdatetime(
       current_date),
      cro.updt_id = reqinfo->updt_id, cro.updt_task = reqinfo->updt_task, cro.updt_applctx = reqinfo
      ->updt_applctx
     PLAN (d)
      JOIN (cro)
     WITH nocounter
    ;end insert
    CALL error_and_zero_check(curqual,"CHART_REQUEST_ORDER","INSERTCHARTREQUESTORDER",1,1)
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (insertchartrequestsection(idx=i4(val)) =null)
   CALL log_message("In InsertChartRequestSection()",log_level_debug)
   DECLARE section_nbr = i4 WITH noconstant(0), protect
   IF ((((request->qual[idx].request_type=1)) OR ((request->qual[idx].request_type=8))) )
    SET section_nbr = size(request->qual[idx].chart_sect_list,5)
    IF (section_nbr > 0)
     INSERT  FROM chart_request_section crs,
       (dummyt dt  WITH seq = value(section_nbr))
      SET crs.chart_request_id = reply->qual[idx].chart_request_id, crs.chart_section_id = request->
       qual[idx].chart_sect_list[dt.seq].chart_section_id, crs.cr_sect_seq = dt.seq,
       crs.active_ind = 1, crs.active_status_cd = reqdata->active_status_cd, crs.active_status_dt_tm
        = cnvtdatetime(current_date),
       crs.active_status_prsnl_id = reqinfo->updt_id, crs.updt_cnt = 0, crs.updt_dt_tm = cnvtdatetime
       (current_date),
       crs.updt_id = reqinfo->updt_id, crs.updt_task = reqinfo->updt_task, crs.updt_applctx = reqinfo
       ->updt_applctx
      PLAN (dt)
       JOIN (crs)
      WITH nocounter
     ;end insert
     CALL error_and_zero_check(curqual,"CHART_REQUEST_SECTION","INSERTCHARTREQUESTSECTION",1,1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (insertchartrequestaudit(idx=i4(val)) =null)
  CALL log_message("In InsertChartRequestAudit()",log_level_debug)
  IF ((request->qual[idx].request_type=8))
   INSERT  FROM chart_request_audit cra
    SET cra.chart_request_id = reply->qual[idx].chart_request_id, cra.dest_pe_name =
     IF ((request->qual[idx].dest_ind=0)) "PERSON"
     ELSEIF ((request->qual[idx].dest_ind=1)) "ORGANIZATION"
     ELSEIF ((request->qual[idx].dest_ind=3)) "CODE_VALUE"
     ELSEIF ((request->qual[idx].dest_ind=4)) "REQUESTER"
     ELSE "FREETEXT"
     ENDIF
     , cra.dest_pe_id = request->qual[idx].dest_id,
     cra.requestor_pe_name =
     IF ((request->qual[idx].requestor_ind=0)) "PERSON"
     ELSEIF ((request->qual[idx].requestor_ind=1)) "ORGANIZATION"
     ELSEIF ((request->qual[idx].requestor_ind=3)) "CODE_VALUE"
     ELSEIF ((request->qual[idx].requestor_ind=4)) "REQUESTER"
     ELSE "FREETEXT"
     ENDIF
     , cra.requestor_pe_id = request->qual[idx].requestor_id, cra.dest_txt = request->qual[idx].
     dest_txt,
     cra.requestor_txt = request->qual[idx].requestor_txt, cra.reason_cd = request->qual[idx].
     reason_cd, cra.comments = request->qual[idx].comments,
     cra.patconobt_ind = request->qual[idx].pco_ind, cra.input_device = request->qual[idx].
     input_device, cra.active_ind = 1,
     cra.active_status_cd = reqdata->active_status_cd, cra.active_status_dt_tm = cnvtdatetime(
      current_date), cra.active_status_prsnl_id = reqinfo->updt_id,
     cra.updt_cnt = 0, cra.updt_dt_tm = cnvtdatetime(current_date), cra.updt_id = reqinfo->updt_id,
     cra.updt_task = reqinfo->updt_task, cra.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_REQUEST_AUDIT","INSERTCHARTREQUESTAUDIT",1,1)
  ENDIF
 END ;Subroutine
 SUBROUTINE getencounterlist(null)
   CALL log_message("In GetEncounterList()",log_level_debug)
   DECLARE cur_event_id_size = i4 WITH noconstant(0), protect
   DECLARE cur_temp_req_size = i4 WITH noconstant(0), protect
   DECLARE qual_nbr = i4 WITH noconstant(0), protect
   DECLARE nstart = i4 WITH constant(1)
   SET stat = alterlist(temp_request->qual,5)
   SET cur_event_id_size = size(request->qual[1].event_id_list,5)
   SELECT DISTINCT INTO "nl:"
    FROM clinical_event ce
    WHERE expand(idx,nstart,cur_event_id_size,ce.event_id,request->qual[1].event_id_list[idx].
     event_id)
    DETAIL
     cur_temp_req_size = size(temp_request->qual,5), index_event = locateval(idx2,1,cur_event_id_size,
      ce.event_id,request->qual[1].event_id_list[idx2].event_id), index_encntr = locateval(idx2,1,
      cur_temp_req_size,ce.encntr_id,temp_request->qual[idx2].encntr_id)
     IF (index_encntr != 0
      AND ce.encntr_id != 0)
      temp_request->qual[index_encntr].index_event_cnt += 1, temp_index = temp_request->qual[
      index_encntr].index_event_cnt, stat = alterlist(temp_request->qual[index_encntr].event_id_list,
       temp_index),
      temp_request->qual[index_encntr].event_id_list[temp_index].event_id = ce.event_id, temp_request
      ->qual[index_encntr].event_id_list[temp_index].cr_event_id = request->qual[1].event_id_list[
      index_event].cr_event_id, temp_request->qual[index_encntr].event_id_list[temp_index].
      result_status_cd = request->qual[1].event_id_list[index_event].result_status_cd
     ELSE
      qual_nbr += 1
      IF (mod(qual_nbr,5)=1)
       stat = alterlist(temp_request->qual,(qual_nbr+ 4))
      ENDIF
      stat = alterlist(request->qual,qual_nbr), stat = alterlist(request_dates->qual,qual_nbr),
      temp_request->qual[qual_nbr].index_event_cnt += 1,
      temp_index = temp_request->qual[qual_nbr].index_event_cnt, stat = alterlist(temp_request->qual[
       qual_nbr].event_id_list,temp_index), temp_request->qual[qual_nbr].encntr_id = ce.encntr_id,
      temp_request->qual[qual_nbr].event_id_list[temp_index].event_id = ce.event_id, temp_request->
      qual[qual_nbr].event_id_list[temp_index].cr_event_id = request->qual[1].event_id_list[
      index_event].cr_event_id, temp_request->qual[qual_nbr].event_id_list[temp_index].
      result_status_cd = request->qual[1].event_id_list[index_event].result_status_cd,
      CALL copy_qual(qual_nbr)
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETENCOUNTERLIST",1,1)
   SET stat = alterlist(temp_request->qual,qual_nbr)
   SET stat = alterlist(request->qual,qual_nbr)
   SET stat = alterlist(reply->qual,qual_nbr)
   FOR (x = 1 TO size(temp_request->qual,5))
    SET request->qual[x].encntr_id = temp_request->qual[x].encntr_id
    FOR (y = 1 TO size(temp_request->qual[x].event_id_list,5))
      SET stat = alterlist(temp_request->qual[x].event_id_list,temp_request->qual[x].index_event_cnt)
      SET stat = alterlist(request->qual[x].event_id_list,temp_request->qual[x].index_event_cnt)
      SET request->qual[x].event_id_list[y].event_id = temp_request->qual[x].event_id_list[y].
      event_id
      SET request->qual[x].event_id_list[y].cr_event_id = temp_request->qual[x].event_id_list[y].
      cr_event_id
      SET request->qual[x].event_id_list[y].result_status_cd = temp_request->qual[x].event_id_list[y]
      .result_status_cd
    ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE (copy_qual(nunrec=i4) =null)
   CALL log_message("In Copy_Qual()",log_level_debug)
   SET request->qual[nunrec].accession_nbr = request->qual[1].accession_nbr
   SET request->qual[nunrec].activity_type_mean = request->qual[1].activity_type_mean
   SET request->qual[nunrec].addl_copies = request->qual[1].addl_copies
   SET request->qual[nunrec].bed = request->qual[1].bed
   SET request->qual[nunrec].begin_dt_tm = request->qual[1].begin_dt_tm
   SET request->qual[nunrec].begin_page = request->qual[1].begin_page
   SET request->qual[nunrec].chart_format_id = request->qual[1].chart_format_id
   SET request->qual[nunrec].chart_pending_flag = request->qual[1].chart_pending_flag
   IF (validate(request->qual[1].chart_route_id))
    SET request->qual[nunrec].chart_route_id = request->qual[1].chart_route_id
   ENDIF
   SET request->qual[nunrec].comments = request->qual[1].comments
   SET request->qual[nunrec].date_range_ind = request->qual[1].date_range_ind
   SET request->qual[nunrec].dest_id = request->qual[1].dest_id
   SET request->qual[nunrec].dest_ind = request->qual[1].dest_ind
   SET request->qual[nunrec].dest_txt = request->qual[1].dest_txt
   SET request->qual[nunrec].device_cd = request->qual[1].device_cd
   SET request->qual[nunrec].display = request->qual[1].display
   SET request->qual[nunrec].end_dt_tm = request->qual[1].end_dt_tm
   SET request->qual[nunrec].end_page = request->qual[1].end_page
   SET request->qual[nunrec].event_ind = request->qual[1].event_ind
   SET request->qual[nunrec].fac = request->qual[1].fac
   SET request->qual[nunrec].file_storage_cd = request->qual[1].file_storage_cd
   SET request->qual[nunrec].file_storage_location = request->qual[1].file_storage_location
   IF (validate(request->qual[1].group_order_id))
    SET request->qual[nunrec].group_order_id = request->qual[1].group_order_id
   ENDIF
   SET request->qual[nunrec].input_device = request->qual[1].input_device
   SET request->qual[nunrec].mrn = request->qual[1].mrn
   SET request->qual[nunrec].mrnt = request->qual[1].mrnt
   SET request->qual[nunrec].name = request->qual[1].name
   SET request->qual[nunrec].nurse_unit_cv = request->qual[1].nurse_unit_cv
   IF (validate(request->qual[1].order_group_flag))
    SET request->qual[nunrec].order_group_flag = request->qual[1].order_group_flag
   ENDIF
   SET request->qual[nunrec].order_id = request->qual[1].order_id
   SET request->qual[nunrec].org = request->qual[1].org
   SET request->qual[nunrec].output_dest_cd = request->qual[1].output_dest_cd
   SET request->qual[nunrec].output_device_cd = request->qual[1].output_device_cd
   SET request->qual[nunrec].page_range_ind = request->qual[1].page_range_ind
   SET request->qual[nunrec].pco_ind = request->qual[1].pco_ind
   SET request->qual[nunrec].person_id = request->qual[1].person_id
   SET request->qual[nunrec].print_complete_flag = request->qual[1].print_complete_flag
   SET request->qual[nunrec].prsnl_person_id = request->qual[1].prsnl_person_id
   SET request->qual[nunrec].prsnl_person_r_cd = request->qual[1].prsnl_person_r_cd
   SET request->qual[nunrec].prsnl_reltn_id = request->qual[1].prsnl_reltn_id
   SET request->qual[nunrec].reader_group = request->qual[1].reader_group
   SET request->qual[nunrec].reason_cd = request->qual[1].reason_cd
   SET request->qual[nunrec].request_type = request->qual[1].request_type
   SET request->qual[nunrec].requestor_id = request->qual[1].requestor_id
   SET request->qual[nunrec].requestor_ind = request->qual[1].requestor_ind
   SET request->qual[nunrec].requestor_txt = request->qual[1].requestor_txt
   IF (validate(request->qual[1].result_lookup_ind))
    SET request->qual[nunrec].result_lookup_ind = request->qual[1].result_lookup_ind
   ENDIF
   SET request->qual[nunrec].room = request->qual[1].room
   SET request->qual[nunrec].rrd_area_code = request->qual[1].rrd_area_code
   SET request->qual[nunrec].rrd_country_access = request->qual[1].rrd_country_access
   SET request->qual[nunrec].rrd_deliver_dt_tm = request->qual[1].rrd_deliver_dt_tm
   SET request->qual[nunrec].rrd_exchange = request->qual[1].rrd_exchange
   SET request->qual[nunrec].rrd_phone_suffix = request->qual[1].rrd_phone_suffix
   SET request->qual[nunrec].scope_flag = request->qual[1].scope_flag
   IF (validate(request->qual[1].sequence_group_id))
    SET request->qual[nunrec].sequence_group_id = request->qual[1].sequence_group_id
   ENDIF
   IF (validate(request->qual[1].suppress_mrpnodata_ind))
    SET request->qual[nunrec].suppress_mrpnodata_ind = request->qual[1].suppress_mrpnodata_ind
   ENDIF
   SET request->qual[nunrec].cr_mask_id = request->qual[1].cr_mask_id
   IF (validate(request->qual[1].chart_trigger_id))
    SET request->qual[nunrec].chart_trigger_id = request->qual[1].chart_trigger_id
   ENDIF
   IF (validate(request->qual[1].user_role_profile))
    SET request->qual[nunrec].user_role_profile = request->qual[1].user_role_profile
   ENDIF
   IF ((request_dates->qual[1].non_ce_begin_dt_tm != null))
    SET request->qual[nunrec].non_ce_begin_dt_tm = cnvtdatetime(request_dates->qual[1].
     non_ce_begin_dt_tm)
   ENDIF
   IF ((request_dates->qual[1].non_ce_end_dt_tm != null))
    SET request->qual[nunrec].non_ce_end_dt_tm = cnvtdatetime(request_dates->qual[1].non_ce_end_dt_tm
     )
   ENDIF
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_add_chart_request",log_level_debug)
END GO
