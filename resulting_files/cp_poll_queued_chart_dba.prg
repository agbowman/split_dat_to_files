CREATE PROGRAM cp_poll_queued_chart:dba
 RECORD reply(
   1 distribution_id = f8
   1 queued_charts[*]
     2 chart_queue_id = f8
     2 batch_id = f8
     2 request_id = f8
     2 chart_path = vc
     2 num_copies = i4
     2 begin_page = i4
     2 end_page = i4
     2 print_path = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 SET log_program_name = "CP_POLL_QUEUED_CHART"
 DECLARE unspooled_cd = f8 WITH noconstant(0.0), protect
 DECLARE spooling_cd = f8 WITH noconstant(0.0), protect
 DECLARE inprocess_cd = f8 WITH noconstant(0.0), protect
 DECLARE non_dist_batch_id = f8 WITH noconstant(0.0), protect
 DECLARE temp_chart_batch_id = f8 WITH noconstant(0.0), protect
 DECLARE final_chart_batch_id = f8 WITH noconstant(0.0), protect
 DECLARE non_dist_queue_dt_tm = q8
 DECLARE temp_chart_batch_queue_dt_tm = q8
 DECLARE final_chart_batch_queue_dt_tm = q8
 DECLARE end_loop = i2 WITH noconstant(0), protect
 DECLARE something_qualed = i2 WITH noconstant(0), protect
 DECLARE checked_batch_cnt = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE getnonbatchrequests(null) = null
 DECLARE getbatchrequests(null) = null
 DECLARE populatetempcharts(null) = null
 DECLARE populatereply(null) = null
 DECLARE updatetospooling(null) = null
 RECORD temp_charts(
   1 qual[*]
     2 batch_id = f8
 )
 RECORD checked_batches(
   1 qual[*]
     2 chart_batch_id = f8
 )
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SET stat = uar_get_meaning_by_codeset(28800,"UNSPOOLED",1,unspooled_cd)
 SET stat = uar_get_meaning_by_codeset(28800,"SPOOLING",1,spooling_cd)
 SET stat = uar_get_meaning_by_codeset(18609,"INPROCESS",1,inprocess_cd)
 CALL log_message("Starting script: cp_get_output_dests",log_level_debug)
 CALL getnonbatchrequests(null)
 CALL getbatchrequests(null)
 CALL error_and_zero_check(something_qualed,"Nothing Qualified","0 Requests OR Batches",1,1)
 IF (final_chart_batch_id != 0
  AND ((non_dist_queue_dt_tm=null) OR (final_chart_batch_queue_dt_tm < non_dist_queue_dt_tm)) )
  CALL populatetempcharts(null)
 ELSE
  SET stat = alterlist(temp_charts->qual,1)
  SET temp_charts->qual[1].batch_id = non_dist_batch_id
 ENDIF
 CALL populatereply(null)
 CALL updatetospooling(null)
 FREE RECORD temp_charts
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 SUBROUTINE getnonbatchrequests(null)
  SELECT INTO "nl:"
   FROM chart_print_queue cpq,
    chart_request cr
   PLAN (cpq
    WHERE cpq.queue_status_cd=unspooled_cd
     AND cpq.distribution_id=0)
    JOIN (cr
    WHERE cr.chart_request_id=cpq.request_id
     AND cr.chart_batch_id=0)
   ORDER BY cpq.queued_dt_tm
   DETAIL
    something_qualed = 1, non_dist_batch_id = cpq.batch_id, non_dist_queue_dt_tm = cpq.queued_dt_tm
   WITH nocounter, maxqual(cpq,1)
  ;end select
  CALL error_and_zero_check(curqual,"cp_poll_queued_chart","GetNonBatchRequests",1,0)
 END ;Subroutine
 SUBROUTINE getbatchrequests(null)
   SELECT INTO "nl:"
    FROM chart_print_queue cpq,
     chart_request cr
    PLAN (cpq
     WHERE cpq.queue_status_cd=unspooled_cd)
     JOIN (cr
     WHERE cr.chart_request_id=cpq.request_id
      AND cr.chart_batch_id != 0)
    ORDER BY cpq.queued_dt_tm
    DETAIL
     temp_chart_batch_id = cr.chart_batch_id, temp_chart_batch_queue_dt_tm = cpq.queued_dt_tm
    WITH nocounter, maxqual(cpq,1)
   ;end select
   IF (curqual > 0)
    SET end_loop = 0
    WHILE (end_loop=0)
     SELECT INTO "nl:"
      FROM chart_request cr
      WHERE cr.chart_batch_id=temp_chart_batch_id
       AND ((cr.chart_status_cd+ 0)=inprocess_cd)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET final_chart_batch_id = temp_chart_batch_id
      SET final_chart_batch_queue_dt_tm = temp_chart_batch_queue_dt_tm
      SET something_qualed = 1
      SET end_loop = 1
     ELSE
      SET checked_batch_cnt += 1
      SET stat = alterlist(checked_batches->qual,checked_batch_cnt)
      SET checked_batches->qual[checked_batch_cnt].chart_batch_id = temp_chart_batch_id
      SELECT INTO "nl:"
       FROM chart_print_queue cpq,
        chart_request cr,
        (dummyt d  WITH seq = value(checked_batch_cnt))
       PLAN (d)
        JOIN (cpq
        WHERE cpq.queue_status_cd=unspooled_cd)
        JOIN (cr
        WHERE cr.chart_request_id=cpq.request_id
         AND cr.chart_batch_id != 0
         AND  NOT (expand(idx,1,size(checked_batches->qual,5),cr.chart_batch_id,checked_batches->
         qual[idx].chart_batch_id)))
       ORDER BY cpq.queued_dt_tm
       DETAIL
        temp_chart_batch_id = cr.chart_batch_id, temp_chart_batch_queue_dt_tm = cpq.queued_dt_tm
       WITH nocounter, maxqual(cpq,1)
      ;end select
      IF (curqual=0)
       SET end_loop = 1
      ENDIF
     ENDIF
    ENDWHILE
   ELSE
    SET end_loop = 1
   ENDIF
   CALL echorecord(checked_batches)
   FREE RECORD checked_batches
   CALL error_and_zero_check(curqual,"cp_poll_queued_chart","GetBatchRequests",1,0)
 END ;Subroutine
 SUBROUTINE populatetempcharts(null)
  SELECT INTO "nl:"
   FROM chart_print_queue cpq,
    chart_request cr
   PLAN (cpq
    WHERE cpq.queue_status_cd=unspooled_cd)
    JOIN (cr
    WHERE cr.chart_request_id=cpq.request_id
     AND cr.chart_batch_id=final_chart_batch_id)
   ORDER BY cpq.batch_id
   HEAD REPORT
    batchchartcnt = 0
   HEAD cpq.batch_id
    batchchartcnt += 1
    IF (mod(batchchartcnt,10)=1)
     stat = alterlist(temp_charts->qual,(batchchartcnt+ 9))
    ENDIF
    temp_charts->qual[batchchartcnt].batch_id = cpq.batch_id
   FOOT  cpq.batch_id
    do_nothing = 0
   FOOT REPORT
    stat = alterlist(temp_charts->qual,batchchartcnt)
   WITH nocounter
  ;end select
  CALL error_and_zero_check(curqual,"No Batched Requests","PopulateTempCharts",1,1)
 END ;Subroutine
 SUBROUTINE populatereply(null)
  SELECT INTO "nl:"
   FROM chart_print_queue cpq,
    (dummyt d  WITH seq = size(temp_charts->qual,5))
   PLAN (d)
    JOIN (cpq
    WHERE (cpq.batch_id=temp_charts->qual[d.seq].batch_id))
   ORDER BY cpq.chart_queue_id
   HEAD REPORT
    chartqueuecnt = 0
   DETAIL
    chartqueuecnt += 1
    IF (mod(chartqueuecnt,10)=1)
     stat = alterlist(reply->queued_charts,(chartqueuecnt+ 9))
    ENDIF
    reply->distribution_id = cpq.distribution_id, reply->queued_charts[chartqueuecnt].chart_queue_id
     = cpq.chart_queue_id, reply->queued_charts[chartqueuecnt].batch_id = cpq.batch_id,
    reply->queued_charts[chartqueuecnt].request_id = cpq.request_id, reply->queued_charts[
    chartqueuecnt].chart_path = cpq.chart_path, reply->queued_charts[chartqueuecnt].num_copies = cpq
    .num_copies,
    reply->queued_charts[chartqueuecnt].begin_page = cpq.begin_page, reply->queued_charts[
    chartqueuecnt].end_page = cpq.end_page, reply->queued_charts[chartqueuecnt].print_path = cpq
    .print_path
   FOOT REPORT
    stat = alterlist(reply->queued_charts,chartqueuecnt)
   WITH nocounter, forupdate(cpq)
  ;end select
  CALL error_and_zero_check(curqual,"Chart_Print_Queue","PopulateReply",1,1)
 END ;Subroutine
 SUBROUTINE updatetospooling(null)
  UPDATE  FROM chart_print_queue cpq,
    (dummyt d  WITH seq = size(reply->queued_charts,5))
   SET cpq.queue_status_cd = spooling_cd, cpq.updt_cnt = (cpq.updt_cnt+ 1), cpq.updt_dt_tm =
    cnvtdatetime(sysdate),
    cpq.updt_id = reqinfo->updt_id, cpq.updt_task = reqinfo->updt_task, cpq.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (cpq
    WHERE (cpq.chart_queue_id=reply->queued_charts[d.seq].chart_queue_id))
   WITH nocounter
  ;end update
  CALL error_and_zero_check(curqual,"update chart_print_queue","UpdateToSpooling",1,1)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_poll_queued_chart",log_level_debug)
 CALL echorecord(reply)
END GO
