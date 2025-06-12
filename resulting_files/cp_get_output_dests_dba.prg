CREATE PROGRAM cp_get_output_dests:dba
 RECORD reply(
   1 queues[*]
     2 device_type_flag = i2
     2 description = vc
     2 dest_cds[*]
       3 output_dest_cd = f8
       3 phone_number = vc
       3 device_tz = i4
   1 ghost_fax_id = f8
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
 SET log_program_name = "CP_GET_OUTPUT_DESTS"
 RECORD req_queues(
   1 queues[*]
     2 queue_name = vc
     2 uppercase_queue_name = vc
     2 already_retrieved = i2
 )
 DECLARE prequeuecnt = i4 WITH noconstant(0), protect
 DECLARE postqueuecnt = i4 WITH noconstant(0), protect
 DECLARE status = c1 WITH noconstant(""), protect
 DECLARE x = i4 WITH noconstant(0), protect
 DECLARE printer_cd = f8 WITH noconstant(0.0), protect
 DECLARE found_fax = i2 WITH noconstant(0), protect
 DECLARE delete_fax_id = f8 WITH noconstant(0.0), protect
 DECLARE getprinterdestcds(null) = null
 DECLARE updatechartserverprinter(null) = null
 DECLARE getfaxremotedestcds(null) = null
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(3000,"PRINT QUEUE",1,printer_cd)
 SET prequeuecnt = size(request->queues,5)
 SET stat = alterlist(req_queues->queues,prequeuecnt)
 SET stat = alterlist(reply->queues,prequeuecnt)
 CALL log_message("Starting script: cp_get_output_dests",log_level_debug)
 FOR (x = 1 TO prequeuecnt)
  SET req_queues->queues[x].queue_name = request->queues[x].queue_name
  SET req_queues->queues[x].uppercase_queue_name = cnvtupper(request->queues[x].queue_name)
 ENDFOR
 DECLARE reqqueuecnt = i4 WITH noconstant(0), protect
 SET reqqueuecnt = size(req_queues->queues,5)
 CALL getprinterdestcds(null)
 CALL getfaxremotedestcds(null)
 IF ((request->local_host_printing=1))
  CALL updatechartserverprinter(null)
 ENDIF
 SET stat = alterlist(reply->queues,postqueuecnt)
 IF (postqueuecnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET reqinfo->commit_ind = 1
 FREE RECORD req_queues
 SUBROUTINE getprinterdestcds(null)
   CALL log_message("In GetPrinterDestCds()",log_level_debug)
   SET n = 0
   SET num = 0
   SELECT DISTINCT INTO "nl:"
    FROM device d,
     device_xref dx,
     output_dest od,
     printer p
    PLAN (d
     WHERE d.device_type_cd=printer_cd
      AND expand(n,1,reqqueuecnt,cnvtupper(d.description),req_queues->queues[n].uppercase_queue_name)
     )
     JOIN (dx
     WHERE dx.parent_entity_id=d.device_cd
      AND dx.parent_entity_name="PRINTER / QUEUE")
     JOIN (od
     WHERE od.device_cd=dx.device_cd)
     JOIN (p
     WHERE p.device_cd=od.device_cd)
    ORDER BY cnvtupper(d.description), od.output_dest_cd
    HEAD REPORT
     destcdscnt = 0, reqindex = 0, getdestcodesind = 0
    HEAD d.description
     getdestcodesind = 0, reqindex = locateval(num,1,reqqueuecnt,cnvtupper(d.description),req_queues
      ->queues[num].uppercase_queue_name)
     IF ((req_queues->queues[reqindex].already_retrieved=0))
      getdestcodesind = 1, postqueuecnt += 1, reply->queues[postqueuecnt].description = req_queues->
      queues[reqindex].queue_name,
      reply->queues[postqueuecnt].device_type_flag = 1, req_queues->queues[reqindex].
      already_retrieved = 1
     ENDIF
    DETAIL
     IF (getdestcodesind=1)
      destcdscnt += 1
      IF (mod(destcdscnt,10)=1)
       stat = alterlist(reply->queues[postqueuecnt].dest_cds,(destcdscnt+ 9))
      ENDIF
      reply->queues[postqueuecnt].dest_cds[destcdscnt].output_dest_cd = od.output_dest_cd, reply->
      queues[postqueuecnt].dest_cds[destcdscnt].device_tz = p.device_tz
     ENDIF
    FOOT  d.description
     stat = alterlist(reply->queues[postqueuecnt].dest_cds,destcdscnt), destcdscnt = 0
    FOOT REPORT
     do_nothing = 0
    WITH nocounter, expand = 1
   ;end select
   CALL error_and_zero_check(curqual,"DEVICE","GETPRINTERDESTCDS",1,0)
 END ;Subroutine
 SUBROUTINE getfaxremotedestcds(null)
   CALL log_message("In GetFaxRemoteDestCds()",log_level_debug)
   SET n = 0
   SET num = 0
   SELECT DISTINCT INTO "nl:"
    FROM code_value cv,
     remote_device_type rdt,
     remote_device rd,
     output_dest od
    PLAN (cv
     WHERE cv.code_set=2210
      AND expand(n,1,reqqueuecnt,cnvtupper(cv.description),req_queues->queues[n].uppercase_queue_name
      ))
     JOIN (rdt
     WHERE rdt.output_format_cd=cv.code_value)
     JOIN (rd
     WHERE rd.remote_dev_type_id=rdt.remote_dev_type_id)
     JOIN (od
     WHERE od.device_cd=rd.device_cd)
    ORDER BY cnvtupper(cv.description), od.output_dest_cd
    HEAD REPORT
     destcdscnt = 0, reqindex = 0, getdestcodesind = 0
    HEAD cv.description
     getdestcodesind = 0, reqindex = locateval(num,1,reqqueuecnt,cnvtupper(cv.description),req_queues
      ->queues[num].uppercase_queue_name)
     IF ((req_queues->queues[reqindex].already_retrieved=0))
      getdestcodesind = 1, postqueuecnt += 1, reply->queues[postqueuecnt].description = req_queues->
      queues[reqindex].queue_name
      IF (cv.cdf_meaning="FAX")
       reply->queues[postqueuecnt].device_type_flag = 2, found_fax = 1
      ELSE
       reply->queues[postqueuecnt].device_type_flag = 3
      ENDIF
      req_queues->queues[reqindex].already_retrieved = 1
     ENDIF
    DETAIL
     IF (getdestcodesind=1)
      destcdscnt += 1
      IF (mod(destcdscnt,10)=1)
       stat = alterlist(reply->queues[postqueuecnt].dest_cds,(destcdscnt+ 9))
      ENDIF
      reply->queues[postqueuecnt].dest_cds[destcdscnt].output_dest_cd = od.output_dest_cd, reply->
      queues[postqueuecnt].dest_cds[destcdscnt].phone_number = concat(trim(rd.country_access),trim(rd
        .area_code),trim(rd.exchange),trim(rd.phone_suffix))
     ENDIF
    FOOT  cv.description
     stat = alterlist(reply->queues[postqueuecnt].dest_cds,destcdscnt), destcdscnt = 0
    FOOT REPORT
     do_nothing = 0
    WITH nocounter, expand = 1
   ;end select
   CALL error_and_zero_check(curqual,"CODE_VALUE","GETFAXREMOTEDESTCDS",1,0)
 END ;Subroutine
 SUBROUTINE updatechartserverprinter(null)
   IF (found_fax=0)
    SET delete_fax_id = request->cs_param_id
    SET reply->ghost_fax_id = 0
   ELSE
    SET delete_fax_id = request->ghost_fax_id
    SET reply->ghost_fax_id = request->ghost_fax_id
   ENDIF
   DELETE  FROM chart_server_printer csp
    WHERE ((csp.cs_param_id IN (request->cs_param_id, delete_fax_id)) OR (csp.updt_dt_tm <
    datetimeadd(cnvtdatetime(sysdate),- (7))
     AND csp.chart_server_printer_id > 0))
    WITH nocounter
   ;end delete
   CALL error_and_zero_check(curqual,"delete chart_server_printer","UpdateChartServerPrinter",1,0)
   FOR (i = 1 TO size(reply->queues,5))
     FOR (j = 1 TO size(reply->queues[i].dest_cds,5))
       INSERT  FROM chart_server_printer csp
        SET csp.chart_server_printer_id = seq(chart_view_seq,nextval), csp.cs_param_id =
         IF ((reply->queues[i].device_type_flag=2)) request->ghost_fax_id
         ELSE request->cs_param_id
         ENDIF
         , csp.output_dest_cd = reply->queues[i].dest_cds[j].output_dest_cd,
         csp.updt_id = reqinfo->updt_id, csp.updt_dt_tm = cnvtdatetime(sysdate), csp.updt_task =
         reqinfo->updt_task,
         csp.updt_applctx = reqinfo->updt_applctx, csp.updt_cnt = 0
        WITH nocounter
       ;end insert
     ENDFOR
   ENDFOR
   CALL error_and_zero_check(curqual,"chart_server_printer","UpdateChartServerPrinter",1,0)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_get_output_dests",log_level_debug)
END GO
