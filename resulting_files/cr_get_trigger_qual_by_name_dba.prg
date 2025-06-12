CREATE PROGRAM cr_get_trigger_qual_by_name:dba
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
 SET log_program_name = "CR_GET_TRIGGER_QUAL_BY_NAME"
 IF (validate(request) != 1)
  RECORD request(
    1 qual[*]
      2 trigger_name = vc
    1 exact_ind = i2
    1 active_status_flag = i2
  )
 ENDIF
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 qual[*]
      2 trigger_dirty_ind = i2
      2 params_dirty_ind = i2
      2 chart_trigger_id = f8
      2 prev_chart_trigger_id = f8
      2 trigger_type_flag = i2
      2 trigger_name = vc
      2 trigger_name_key = vc
      2 complete_flag = i2
      2 discharge_flag = i2
      2 scope_flag = i2
      2 pending_flag = i2
      2 report_template_id = f8
      2 chart_format_id = f8
      2 print_range_flag = i2
      2 route_location_bit_map = i4
      2 default_output_dest_cd = f8
      2 expired_reltn_ind = i2
      2 file_storage_cd = f8
      2 file_storage_location = vc
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 active_ind = i2
      2 name_ident = vc
      2 updt_dt_tm = dq8
      2 updt_id = f8
      2 days_nbr = i4
      2 date_dt_tm = dq8
      2 dms_service_name = vc
      2 additional_copy_nbr = i4
      2 params[*]
        3 chart_trigger_param_id = f8
        3 chart_trigger_id = f8
        3 include_ind = i2
        3 param_type_flag = i2
        3 parent_entity_id = f8
        3 parent_entity_name = vc
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
        3 active_ind = i2
        3 updt_dt_tm = dq8
      2 sending_organization_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE current_date_time = q8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE bind_cnt = i4 WITH constant(20)
 DECLARE active_triggers_only = i4 WITH constant(1), protect
 DECLARE inactive_triggers_only = i4 WITH constant(2), protect
 DECLARE all_triggers = i4 WITH constant(3), protect
 DECLARE both_active_inactive_working_triggers = i4 WITH constant(4), protect
 DECLARE i_asterisk = i4 WITH constant(ichar("*")), protect
 DECLARE active_clause = vc WITH noconstant(""), protect
 DECLARE buildactiveclause(null) = null
 DECLARE loadqualifierinformation(null) = null
 DECLARE loadbaseinformationbynames(null) = null
 CALL log_message("Begin script: cr_get_trigger_qual_by_name",log_level_debug)
 SET reply->status_data.status = "F"
 CALL loadqualifierinformation(null)
 CALL error_and_zero_check(size(reply->qual,5),"MAIN","No records found",1,1)
 SET reply->status_data.status = "S"
 SUBROUTINE loadqualifierinformation(null)
   CALL log_message("In LoadQualifierInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   IF (size(request->qual,5) > 0)
    CALL buildactiveclause(null)
    CALL loadbaseinformationbynames(null)
   ENDIF
   CALL log_message(build("Exit LoadQualifierInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE buildactiveclause(null)
  IF ((request->active_status_flag=active_triggers_only))
   SET active_clause = "ct.active_ind = 1 and ct.chart_trigger_id = ct.prev_chart_trigger_id"
  ELSEIF ((request->active_status_flag=inactive_triggers_only))
   SET active_clause = "ct.active_ind = 0 and ct.chart_trigger_id = ct.prev_chart_trigger_id"
  ELSEIF ((request->active_status_flag=all_triggers))
   SET active_clause = "ct.active_ind >= 0"
  ELSE
   SET active_clause = "ct.chart_trigger_id = ct.prev_chart_trigger_id"
  ENDIF
  CALL echo(concat("active_clause: ",active_clause))
 END ;Subroutine
 SUBROUTINE loadbaseinformationbynames(null)
   CALL log_message("In LoadBaseInformationByNames()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE nrecordsize = i4 WITH constant(size(request->qual,5)), protect
   IF (request->exact_ind)
    DECLARE idx = i4 WITH noconstant(0), protect
    DECLARE idxstart = i4 WITH noconstant(1), protect
    DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
    protect
    FREE RECORD name_key_rec
    RECORD name_key_rec(
      1 qual[*]
        2 name_key = vc
    )
    SET stat = alterlist(name_key_rec->qual,noptimizedtotal)
    FOR (i = 1 TO nrecordsize)
      SET name_key_rec->qual[i].name_key = trim(cnvtupper(cnvtalphanum(request->qual[i].trigger_name)
        ),3)
    ENDFOR
    FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
      SET name_key_rec->qual[i].name_key = trim(cnvtupper(cnvtalphanum(request->qual[nrecordsize].
         trigger_name)),3)
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      chart_trigger ct
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ct
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ct.trigger_name_key,name_key_rec->qual[idx
       ].name_key,
       bind_cnt)
       AND ct.chart_trigger_id > 0
       AND parser(active_clause))
     HEAD REPORT
      ncount = 0
     DETAIL
      CALL addinfotoreply(null)
     FOOT REPORT
      stat = alterlist(reply->qual,ncount)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_TRIGGER","ELoadBaseInformationByNames",1,1)
   ELSE
    DECLARE dseq = i4 WITH noconstant(0), protect
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(nrecordsize)),
      chart_trigger ct
     PLAN (d
      WHERE initarray(dseq,d.seq))
      JOIN (ct
      WHERE operator(ct.trigger_name_key,"LIKE",patstring(concat(trim(cnvtupper(cnvtalphanum(request
            ->qual[d.seq].trigger_name)),3),"*"),1))
       AND ct.chart_trigger_id > 0
       AND parser(active_clause))
     HEAD REPORT
      ncount = 0
     DETAIL
      CALL addinfotoreply(null)
     FOOT REPORT
      stat = alterlist(reply->qual,ncount)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_TRIGGER","DLoadBaseInformationByNames",1,1)
   ENDIF
   CALL log_message(build("Exit LoadBaseInformationByNames(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addinfotoreply(null)
   SET ncount += 1
   IF (ncount > size(reply->qual,5))
    SET stat = alterlist(reply->qual,(ncount+ 9))
   ENDIF
   SET reply->qual[ncount].chart_trigger_id = ct.chart_trigger_id
   SET reply->qual[ncount].prev_chart_trigger_id = ct.prev_chart_trigger_id
   SET reply->qual[ncount].trigger_name = ct.trigger_name
   SET reply->qual[ncount].trigger_name_key = ct.trigger_name_key
   SET reply->qual[ncount].trigger_type_flag = ct.trigger_type_flag
   SET reply->qual[ncount].active_ind = ct.active_ind
   SET reply->qual[ncount].beg_effective_dt_tm = cnvtdatetime(ct.beg_effective_dt_tm)
   SET reply->qual[ncount].chart_format_id = ct.chart_format_id
   SET reply->qual[ncount].complete_flag = ct.complete_flag
   SET reply->qual[ncount].default_output_dest_cd = ct.default_output_dest_cd
   SET reply->qual[ncount].discharge_flag = ct.discharge_type_flag
   SET reply->qual[ncount].end_effective_dt_tm = cnvtdatetime(ct.end_effective_dt_tm)
   SET reply->qual[ncount].expired_reltn_ind = ct.expired_reltn_ind
   SET reply->qual[ncount].file_storage_cd = ct.file_storage_cd
   SET reply->qual[ncount].file_storage_location = ct.file_storage_location
   SET reply->qual[ncount].name_ident = ct.name_ident
   SET reply->qual[ncount].pending_flag = ct.pending_flag
   SET reply->qual[ncount].print_range_flag = ct.print_range_flag
   SET reply->qual[ncount].report_template_id = ct.report_template_id
   SET reply->qual[ncount].route_location_bit_map = ct.route_location_bit_map
   SET reply->qual[ncount].scope_flag = ct.scope_flag
   SET reply->qual[ncount].updt_dt_tm = cnvtdatetime(ct.updt_dt_tm)
   SET reply->qual[ncount].days_nbr = ct.days_nbr
   SET reply->qual[ncount].date_dt_tm = ct.date_dt_tm
   SET reply->qual[ncount].dms_service_name = ct.dms_service_name
   SET reply->qual[ncount].additional_copy_nbr = ct.additional_copy_nbr
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cr_get_trigger_qual_by_name",log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
