CREATE PROGRAM cr_maintain_trigger_qualifier:dba
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
 SET log_program_name = "CR_MAINTAIN_TRIGGER_QUALIFIER"
 IF (validate(request) != 1)
  RECORD request(
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
  )
 ENDIF
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 qual[*]
      2 trigger_id = f8
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
   1 param_information_ind = i2
   1 qual[*]
     2 trigger_id = f8
 )
 FREE RECORD temp_reply
 RECORD temp_reply(
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
 DECLARE current_date_time = q8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE max_date_time = q8 WITH constant(cnvtdatetime("31-DEC-2100")), protect
 DECLARE min_date_time = q8 WITH constant(cnvtdatetime("01-JAN-1800")), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE maintainqualifierinformation(null) = null
 DECLARE loadpreviousversion(null) = null
 DECLARE getnextexpeditesequencenumber(null) = f8
 DECLARE populatereply(null) = f8
 CALL log_message("Begin script: cr_maintain_trigger_qualifier",log_level_debug)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 CALL maintainqualifierinformation(null)
 CALL populatereply(null)
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
 SUBROUTINE maintainqualifierinformation(null)
   CALL log_message("In MaintainQualifierInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE next_chart_trigger_param_id = f8 WITH noconstant(0.0), protect
   FREE RECORD insert_seq
   RECORD insert_seq(
     1 cnt = i4
     1 qual[*]
       2 seq = i4
   )
   FREE RECORD modify_seq
   RECORD modify_seq(
     1 cnt = i4
     1 qual[*]
       2 seq = i4
       2 trigger_id = f8
       2 trigger_dirty = i2
       2 param_dirty = i2
   )
   FOR (x = 1 TO size(request->qual,5))
     IF ((request->qual[x].chart_trigger_id=0))
      SET insert_seq->cnt += 1
      SET stat = alterlist(insert_seq->qual,insert_seq->cnt)
      SET insert_seq->qual[insert_seq->cnt].seq = x
     ELSE
      SET modify_seq->cnt += 1
      SET stat = alterlist(modify_seq->qual,modify_seq->cnt)
      SET modify_seq->qual[modify_seq->cnt].seq = x
      SET modify_seq->qual[modify_seq->cnt].trigger_id = request->qual[x].chart_trigger_id
      SET modify_seq->qual[modify_seq->cnt].trigger_dirty = request->qual[x].trigger_dirty_ind
      SET modify_seq->qual[modify_seq->cnt].param_dirty = request->qual[x].params_dirty_ind
     ENDIF
   ENDFOR
   IF ((insert_seq->cnt > 0))
    FOR (y = 1 TO insert_seq->cnt)
     CALL insertnewtriggerfromrequest(insert_seq->qual[y].seq)
     FOR (z = 1 TO size(request->qual[insert_seq->qual[y].seq].params,5))
       CALL insertnewparameterfromrequest(insert_seq->qual[y].seq,z)
     ENDFOR
    ENDFOR
   ENDIF
   IF ((modify_seq->cnt > 0))
    CALL loadpreviousversion(null)
    FOR (y = 1 TO modify_seq->cnt)
     IF (modify_seq->qual[y].trigger_dirty)
      CALL modifyexistingtrigger(modify_seq->qual[y].seq)
     ENDIF
     IF (modify_seq->qual[y].param_dirty)
      CALL modifyexistingparams(modify_seq->qual[y].seq)
     ENDIF
    ENDFOR
   ENDIF
   CALL log_message(build("Exit MaintainQualifierInformation(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadpreviousversion(null)
   CALL log_message("In LoadPreviousVersion()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SET temp_request->param_information_ind = 1
   SET stat = alterlist(temp_request->qual,modify_seq->cnt)
   FOR (x = 1 TO modify_seq->cnt)
     SET temp_request->qual[x].trigger_id = modify_seq->qual[x].trigger_id
   ENDFOR
   EXECUTE cr_get_trigger_qualifier  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY",
    "TEMP_REPLY")
   CALL log_message(build("Exit LoadPreviousVersion(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertnewtriggerfromrequest(trig_seq=i4(val)) =null)
   CALL log_message("In InsertNewTriggerFromRequest()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE stiggernamekey = vc WITH noconstant(""), protect
   DECLARE next_chart_trigger_id = f8 WITH noconstant(0.0), protect
   SET next_chart_trigger_id = getnextexpeditesequencenumber(null)
   SET stiggernamekey = trim(cnvtupper(cnvtalphanum(request->qual[trig_seq].trigger_name)),3)
   SET request->qual[trig_seq].trigger_name_key = stiggernamekey
   SET request->qual[trig_seq].name_ident = concat(stiggernamekey,cnvtstring(cnvtdatetime(
      current_date_time)))
   SET request->qual[trig_seq].chart_trigger_id = next_chart_trigger_id
   SET request->qual[trig_seq].prev_chart_trigger_id = next_chart_trigger_id
   SET request->qual[trig_seq].beg_effective_dt_tm = cnvtdatetime(current_date_time)
   SET request->qual[trig_seq].end_effective_dt_tm = cnvtdatetime(max_date_time)
   SET request->qual[trig_seq].active_ind = 1
   CALL inserttriggerfromrequest(trig_seq)
   CALL log_message(build("Exit InsertNewTriggerFromRequest(), Elapsed time in seconds:",datetimediff
     (cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (inserttriggerfromrequest(trig_seq=i4(val)) =null)
   CALL log_message("In InsertTriggerFromRequest()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   INSERT  FROM chart_trigger ct
    SET ct.active_ind = request->qual[trig_seq].active_ind, ct.beg_effective_dt_tm = cnvtdatetime(
      request->qual[trig_seq].beg_effective_dt_tm), ct.chart_format_id = request->qual[trig_seq].
     chart_format_id,
     ct.chart_trigger_id = request->qual[trig_seq].chart_trigger_id, ct.complete_flag = request->
     qual[trig_seq].complete_flag, ct.default_output_dest_cd = request->qual[trig_seq].
     default_output_dest_cd,
     ct.discharge_type_flag = request->qual[trig_seq].discharge_flag, ct.end_effective_dt_tm =
     cnvtdatetime(request->qual[trig_seq].end_effective_dt_tm), ct.expired_reltn_ind = request->qual[
     trig_seq].expired_reltn_ind,
     ct.file_storage_cd = request->qual[trig_seq].file_storage_cd, ct.file_storage_location = request
     ->qual[trig_seq].file_storage_location, ct.name_ident = request->qual[trig_seq].name_ident,
     ct.pending_flag = request->qual[trig_seq].pending_flag, ct.prev_chart_trigger_id = request->
     qual[trig_seq].prev_chart_trigger_id, ct.print_range_flag = request->qual[trig_seq].
     print_range_flag,
     ct.report_template_id = request->qual[trig_seq].report_template_id, ct.route_location_bit_map =
     request->qual[trig_seq].route_location_bit_map, ct.scope_flag = request->qual[trig_seq].
     scope_flag,
     ct.trigger_name = request->qual[trig_seq].trigger_name, ct.trigger_name_key = request->qual[
     trig_seq].trigger_name_key, ct.trigger_type_flag = request->qual[trig_seq].trigger_type_flag,
     ct.days_nbr = request->qual[trig_seq].days_nbr, ct.date_dt_tm = cnvtdatetime(request->qual[
      trig_seq].date_dt_tm), ct.dms_service_name = request->qual[trig_seq].dms_service_name,
     ct.additional_copy_nbr = request->qual[trig_seq].additional_copy_nbr, ct.sending_org_id =
     request->qual[trig_seq].sending_organization_id, ct.updt_applctx = reqinfo->updt_applctx,
     ct.updt_cnt = 0, ct.updt_dt_tm = cnvtdatetime(sysdate), ct.updt_id = reqinfo->updt_id,
     ct.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertTriggerFromRequest","insert chart_trigger",1,1)
   CALL log_message(build("Exit InsertTriggerFromRequest(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (updatetriggerfromrequest(trig_seq=i4(val)) =null)
   CALL log_message("In UpdateTriggerFromRequest()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   UPDATE  FROM chart_trigger ct
    SET ct.active_ind = request->qual[trig_seq].active_ind, ct.beg_effective_dt_tm = cnvtdatetime(
      request->qual[trig_seq].beg_effective_dt_tm), ct.chart_format_id = request->qual[trig_seq].
     chart_format_id,
     ct.chart_trigger_id = request->qual[trig_seq].chart_trigger_id, ct.complete_flag = request->
     qual[trig_seq].complete_flag, ct.default_output_dest_cd = request->qual[trig_seq].
     default_output_dest_cd,
     ct.discharge_type_flag = request->qual[trig_seq].discharge_flag, ct.end_effective_dt_tm =
     cnvtdatetime(request->qual[trig_seq].end_effective_dt_tm), ct.expired_reltn_ind = request->qual[
     trig_seq].expired_reltn_ind,
     ct.file_storage_cd = request->qual[trig_seq].file_storage_cd, ct.file_storage_location = request
     ->qual[trig_seq].file_storage_location, ct.name_ident = request->qual[trig_seq].name_ident,
     ct.pending_flag = request->qual[trig_seq].pending_flag, ct.prev_chart_trigger_id = request->
     qual[trig_seq].prev_chart_trigger_id, ct.print_range_flag = request->qual[trig_seq].
     print_range_flag,
     ct.report_template_id = request->qual[trig_seq].report_template_id, ct.route_location_bit_map =
     request->qual[trig_seq].route_location_bit_map, ct.scope_flag = request->qual[trig_seq].
     scope_flag,
     ct.trigger_name = request->qual[trig_seq].trigger_name, ct.trigger_name_key = request->qual[
     trig_seq].trigger_name_key, ct.trigger_type_flag = request->qual[trig_seq].trigger_type_flag,
     ct.days_nbr = request->qual[trig_seq].days_nbr, ct.date_dt_tm = cnvtdatetime(request->qual[
      trig_seq].date_dt_tm), ct.dms_service_name = request->qual[trig_seq].dms_service_name,
     ct.additional_copy_nbr = request->qual[trig_seq].additional_copy_nbr, ct.sending_org_id =
     request->qual[trig_seq].sending_organization_id, ct.updt_applctx = reqinfo->updt_applctx,
     ct.updt_cnt = (ct.updt_cnt+ 1), ct.updt_dt_tm = cnvtdatetime(sysdate), ct.updt_id = reqinfo->
     updt_id,
     ct.updt_task = reqinfo->updt_task
    WHERE (ct.chart_trigger_id=request->qual[trig_seq].chart_trigger_id)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"UpdateTriggerFromRequest","updating chart_trigger",1,1)
   CALL log_message(build("Exit UpdateTriggerFromRequest(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (inserttriggerfromtempreply(trig_seq=i4(val)) =null)
   CALL log_message("In InsertTriggerFromTempReply()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   INSERT  FROM chart_trigger ct
    SET ct.active_ind = temp_reply->qual[trig_seq].active_ind, ct.beg_effective_dt_tm = cnvtdatetime(
      temp_reply->qual[trig_seq].beg_effective_dt_tm), ct.chart_format_id = temp_reply->qual[trig_seq
     ].chart_format_id,
     ct.chart_trigger_id = temp_reply->qual[trig_seq].chart_trigger_id, ct.complete_flag = temp_reply
     ->qual[trig_seq].complete_flag, ct.default_output_dest_cd = temp_reply->qual[trig_seq].
     default_output_dest_cd,
     ct.discharge_type_flag = temp_reply->qual[trig_seq].discharge_flag, ct.end_effective_dt_tm =
     cnvtdatetime(temp_reply->qual[trig_seq].end_effective_dt_tm), ct.expired_reltn_ind = temp_reply
     ->qual[trig_seq].expired_reltn_ind,
     ct.file_storage_cd = temp_reply->qual[trig_seq].file_storage_cd, ct.file_storage_location =
     temp_reply->qual[trig_seq].file_storage_location, ct.name_ident = temp_reply->qual[trig_seq].
     name_ident,
     ct.pending_flag = temp_reply->qual[trig_seq].pending_flag, ct.prev_chart_trigger_id = temp_reply
     ->qual[trig_seq].prev_chart_trigger_id, ct.print_range_flag = temp_reply->qual[trig_seq].
     print_range_flag,
     ct.report_template_id = temp_reply->qual[trig_seq].report_template_id, ct.route_location_bit_map
      = temp_reply->qual[trig_seq].route_location_bit_map, ct.scope_flag = temp_reply->qual[trig_seq]
     .scope_flag,
     ct.trigger_name = temp_reply->qual[trig_seq].trigger_name, ct.trigger_name_key = temp_reply->
     qual[trig_seq].trigger_name_key, ct.trigger_type_flag = temp_reply->qual[trig_seq].
     trigger_type_flag,
     ct.days_nbr = temp_reply->qual[trig_seq].days_nbr, ct.date_dt_tm = cnvtdatetime(temp_reply->
      qual[trig_seq].date_dt_tm), ct.dms_service_name = temp_reply->qual[trig_seq].dms_service_name,
     ct.additional_copy_nbr = temp_reply->qual[trig_seq].additional_copy_nbr, ct.sending_org_id =
     temp_reply->qual[trig_seq].sending_organization_id, ct.updt_applctx = reqinfo->updt_applctx,
     ct.updt_cnt = 0, ct.updt_dt_tm = cnvtdatetime(sysdate), ct.updt_id = reqinfo->updt_id,
     ct.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertTriggerFromTempReply","inserting chart_trigger",1,1)
   CALL log_message(build("Exit InsertTriggerFromTempReply(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertnewparameterfromrequest(trig_seq=i4(val),param_seq=i4(val)) =null)
   CALL log_message("In InsertNewParameterFromRequest()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE next_chart_trigger_param_id = f8 WITH noconstant(0.0), protect
   SET next_chart_trigger_param_id = getnextexpeditesequencenumber(null)
   SET request->qual[trig_seq].params[param_seq].chart_trigger_id = request->qual[trig_seq].
   chart_trigger_id
   SET request->qual[trig_seq].params[param_seq].chart_trigger_param_id = next_chart_trigger_param_id
   SET request->qual[trig_seq].params[param_seq].beg_effective_dt_tm = cnvtdatetime(current_date_time
    )
   SET request->qual[trig_seq].params[param_seq].end_effective_dt_tm = cnvtdatetime(max_date_time)
   SET request->qual[trig_seq].params[param_seq].active_ind = 1
   CALL insertparameterfromrequest(trig_seq,param_seq)
   CALL log_message(build("Exit InsertNewParameterFromRequest(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertparameterfromrequest(trig_seq=i4(val),param_seq=i4(val)) =null)
   CALL log_message("In InsertParameterFromRequest()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   INSERT  FROM chart_trigger_param ctp
    SET ctp.active_ind = request->qual[trig_seq].params[param_seq].active_ind, ctp
     .beg_effective_dt_tm = cnvtdatetime(request->qual[trig_seq].params[param_seq].
      beg_effective_dt_tm), ctp.chart_trigger_id = request->qual[trig_seq].params[param_seq].
     chart_trigger_id,
     ctp.chart_trigger_param_id = request->qual[trig_seq].params[param_seq].chart_trigger_param_id,
     ctp.end_effective_dt_tm = cnvtdatetime(request->qual[trig_seq].params[param_seq].
      end_effective_dt_tm), ctp.include_ind = request->qual[trig_seq].params[param_seq].include_ind,
     ctp.parent_entity_id = request->qual[trig_seq].params[param_seq].parent_entity_id, ctp
     .parent_entity_name = request->qual[trig_seq].params[param_seq].parent_entity_name, ctp
     .param_type_flag = request->qual[trig_seq].params[param_seq].param_type_flag,
     ctp.updt_applctx = reqinfo->updt_applctx, ctp.updt_cnt = 0, ctp.updt_dt_tm = cnvtdatetime(
      sysdate),
     ctp.updt_id = reqinfo->updt_id, ctp.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertParameterFromRequest","inserting chart_trigger_param",1,0
    )
   CALL log_message(build("Exit InsertParameterFromRequest(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (versiontriggerbyid(trigger_id=f8(val)) =i4)
   CALL log_message("In VersionTriggerById()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE temp_trigger_loc = i4 WITH noconstant(0), protect
   SET temp_trigger_loc = locateval(idx,1,size(temp_reply->qual,5),trigger_id,temp_reply->qual[idx].
    chart_trigger_id)
   IF (temp_trigger_loc=0)
    CALL log_message("In GetNextExpediteSequenceNumber(): Failed to locate chart_trigger_id",
     log_level_debug)
   ELSE
    SET temp_reply->qual[temp_trigger_loc].chart_trigger_id = getnextexpeditesequencenumber(null)
    SET temp_reply->qual[temp_trigger_loc].end_effective_dt_tm = cnvtdatetime(current_date_time)
   ENDIF
   CALL inserttriggerfromtempreply(temp_trigger_loc)
   CALL log_message(build("Exit VersionTriggerById(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   RETURN(temp_trigger_loc)
 END ;Subroutine
 SUBROUTINE (modifyexistingtrigger(trig_seq=i4(val)) =null)
   CALL log_message("In ModifyExistingTrigger()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE temp_trigger_loc = i4 WITH noconstant(0), protect
   SET temp_trigger_loc = versiontriggerbyid(request->qual[trig_seq].chart_trigger_id)
   SET request->qual[trig_seq].beg_effective_dt_tm = cnvtdatetime(current_date_time)
   SET request->qual[trig_seq].end_effective_dt_tm = cnvtdatetime(max_date_time)
   SET request->qual[trig_seq].name_ident = temp_reply->qual[temp_trigger_loc].name_ident
   SET request->qual[trig_seq].trigger_name_key = temp_reply->qual[temp_trigger_loc].trigger_name_key
   CALL updatetriggerfromrequest(trig_seq)
   CALL log_message(build("Exit ModifyExistingTrigger(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (modifyexistingparams(trig_seq=i4(val)) =null)
   CALL log_message("In ModifyExistingParams()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE ncount = i4 WITH constant(size(request->qual[trig_seq].params,5)), protect
   FOR (x = 1 TO ncount)
     IF ((request->qual[trig_seq].params[x].chart_trigger_param_id=0))
      CALL insertnewparameterfromrequest(trig_seq,x)
     ENDIF
   ENDFOR
   IF (ncount <= 200)
    CALL log_message("In ModifyExistingParams() <= 200 parameters",log_level_debug)
    UPDATE  FROM chart_trigger_param ctp
     SET ctp.active_ind = 0, ctp.end_effective_dt_tm = cnvtdatetime(current_date_time), ctp
      .updt_applctx = reqinfo->updt_applctx,
      ctp.updt_cnt = (ctp.updt_cnt+ 1), ctp.updt_dt_tm = cnvtdatetime(sysdate), ctp.updt_id = reqinfo
      ->updt_id,
      ctp.updt_task = reqinfo->updt_task
     PLAN (ctp
      WHERE  NOT (expand(idx,1,ncount,ctp.chart_trigger_param_id,request->qual[trig_seq].params[idx].
       chart_trigger_param_id,
       bind_cnt))
       AND (ctp.chart_trigger_id=request->qual[trig_seq].chart_trigger_id)
       AND ctp.active_ind=1
       AND ctp.end_effective_dt_tm >= cnvtdatetime(max_date_time))
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"ModifyExistingParams1","updating chart_trigger_param",1,0)
   ELSE
    CALL log_message("In ModifyExistingParams() > 200 parameters",log_level_debug)
    DECLARE idx2 = i4 WITH noconstant(0), protect
    FREE RECORD temp_rec
    RECORD temp_rec(
      1 cnt = i4
      1 qual[*]
        2 chart_trigger_param_id = f8
    )
    SELECT INTO "nl:"
     FROM chart_trigger_param ctp
     WHERE (ctp.chart_trigger_id=request->qual[trig_seq].chart_trigger_id)
      AND ctp.active_ind=1
      AND ctp.end_effective_dt_tm >= cnvtdatetime(max_date_time)
     HEAD REPORT
      temp_rec->cnt = 0
     DETAIL
      temploc = locateval(idx2,1,ncount,ctp.chart_trigger_param_id,request->qual[trig_seq].params[
       idx2].chart_trigger_param_id)
      IF (temploc=0)
       temp_rec->cnt += 1
       IF ((temp_rec->cnt > size(temp_rec->qual,5)))
        stat = alterlist(temp_rec->qual,((temp_rec->cnt+ bind_cnt) - 1))
       ENDIF
       temp_rec->qual[temp_rec->cnt].chart_trigger_param_id = ctp.chart_trigger_param_id
      ENDIF
     WITH nocounter
    ;end select
    DECLARE idxstart = i4 WITH noconstant(1), protect
    DECLARE noptimizedtotal = i4 WITH constant(size(temp_rec->qual,5)), protect
    FOR (x = (temp_rec->cnt+ 1) TO noptimizedtotal)
      SET temp_rec->qual[x].chart_trigger_param_id = temp_rec->qual[temp_rec->cnt].
      chart_trigger_param_id
    ENDFOR
    UPDATE  FROM chart_trigger_param ctp,
      (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt))))
     SET ctp.active_ind = 0, ctp.end_effective_dt_tm = cnvtdatetime(current_date_time), ctp
      .updt_applctx = reqinfo->updt_applctx,
      ctp.updt_cnt = (ctp.updt_cnt+ 1), ctp.updt_dt_tm = cnvtdatetime(sysdate), ctp.updt_id = reqinfo
      ->updt_id,
      ctp.updt_task = reqinfo->updt_task
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ctp
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ctp.chart_trigger_param_id,temp_rec->qual[
       idx].chart_trigger_param_id,
       bind_cnt))
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"ModifyExistingParams2","updating chart_trigger_param",1,0)
   ENDIF
   IF ((request->qual[trig_seq].trigger_dirty_ind=0))
    UPDATE  FROM chart_trigger ct
     SET ct.updt_cnt = (ct.updt_cnt+ 1), ct.updt_dt_tm = cnvtdatetime(sysdate), ct.updt_id = reqinfo
      ->updt_id,
      ct.updt_task = reqinfo->updt_task
     WHERE (ct.chart_trigger_id=request->qual[trig_seq].chart_trigger_id)
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"ModifyExistingParams","updating chart_trigger",1,1)
   ENDIF
   CALL log_message(build("Exit ModifyExistingParams(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getnextexpeditesequencenumber(null)
   CALL log_message("In GetNextExpediteSequenceNumber()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE returnval = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    nextseqnum = seq(expedite_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     returnval = nextseqnum
    WITH format, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"DUAL","GETNEXTEXPEDITESEQUENCENUMBER",1,1)
   CALL log_message(build("Exit GetNextExpediteSequenceNumber(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   RETURN(returnval)
 END ;Subroutine
 SUBROUTINE populatereply(null)
   CALL log_message("In GetNextExpediteSequenceNumber()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE nreplysize = i4 WITH constant(size(request->qual,5)), private
   SET stat = alterlist(reply->qual,nreplysize)
   FOR (x = 1 TO nreplysize)
     SET reply->qual[x].trigger_id = request->qual[x].chart_trigger_id
   ENDFOR
   CALL log_message(build("Exit GetNextExpediteSequenceNumber(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL echorecord(reply)
 CALL log_message("Exiting script: cr_maintain_trigger_qualifier",log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
