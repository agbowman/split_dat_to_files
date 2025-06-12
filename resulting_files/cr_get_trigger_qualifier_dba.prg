CREATE PROGRAM cr_get_trigger_qualifier:dba
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
 SET log_program_name = "CR_GET_TRIGGER_QUALIFIER"
 IF (validate(request) != 1)
  RECORD request(
    1 param_information_ind = i2
    1 qual[*]
      2 trigger_id = f8
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
 FREE RECORD working
 RECORD working(
   1 cnt = i4
   1 qual[*]
     2 chart_trigger_id = f8
     2 seq = i4
 )
 FREE RECORD non_working
 RECORD non_working(
   1 cnt = i4
   1 qual[*]
     2 chart_trigger_id = f8
     2 prev_chart_trigger_id = f8
     2 seq = i4
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 DECLARE current_date_time = q8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE non_discharged_patients = i4 WITH constant(0), protect
 DECLARE discharged_patients = i4 WITH constant(1), protect
 DECLARE both_discharged_nondischarged_patients = i4 WITH constant(2), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE loadqualifierinformation(null) = null
 DECLARE loadbaseinformationbyids(null) = null
 DECLARE loadparaminformationforworkingtriggers(null) = null
 DECLARE loadparaminformationfornonworkingtriggers(null) = null
 CALL log_message("Begin script: cr_get_trigger_qualifier",log_level_debug)
 SET reply->status_data.status = "F"
 CALL loadqualifierinformation(null)
 SET reply->status_data.status = "S"
 SUBROUTINE loadqualifierinformation(null)
   CALL log_message("In LoadQualifierInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   IF (size(request->qual,5) > 0)
    CALL loadbaseinformationbyids(null)
    IF (request->param_information_ind)
     IF ((working->cnt > 0))
      CALL loadparaminformationforworkingtriggers(null)
     ENDIF
     IF ((non_working->cnt > 0))
      CALL loadparaminformationfornonworkingtriggers(null)
     ENDIF
    ENDIF
   ENDIF
   CALL log_message(build("Exit LoadQualifierInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadbaseinformationbyids(null)
   CALL log_message("In LoadBaseInformationByIds()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(size(request->qual,5)), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(request->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET request->qual[i].trigger_id = request->qual[nrecordsize].trigger_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_trigger ct
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (ct
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ct.chart_trigger_id,request->qual[idx].
      trigger_id,
      bind_cnt))
    HEAD REPORT
     ncount = 0
    DETAIL
     ncount += 1
     IF (ncount > size(reply->qual,5))
      stat = alterlist(reply->qual,(ncount+ 9))
     ENDIF
     reply->qual[ncount].chart_trigger_id = ct.chart_trigger_id, reply->qual[ncount].
     prev_chart_trigger_id = ct.prev_chart_trigger_id, reply->qual[ncount].trigger_name = ct
     .trigger_name,
     reply->qual[ncount].trigger_name_key = ct.trigger_name_key, reply->qual[ncount].
     trigger_type_flag = ct.trigger_type_flag, reply->qual[ncount].active_ind = ct.active_ind,
     reply->qual[ncount].beg_effective_dt_tm = cnvtdatetime(ct.beg_effective_dt_tm), reply->qual[
     ncount].chart_format_id = ct.chart_format_id, reply->qual[ncount].complete_flag = ct
     .complete_flag,
     reply->qual[ncount].default_output_dest_cd = ct.default_output_dest_cd, reply->qual[ncount].
     discharge_flag = ct.discharge_type_flag, reply->qual[ncount].end_effective_dt_tm = cnvtdatetime(
      ct.end_effective_dt_tm),
     reply->qual[ncount].expired_reltn_ind = ct.expired_reltn_ind, reply->qual[ncount].
     file_storage_cd = ct.file_storage_cd, reply->qual[ncount].file_storage_location = ct
     .file_storage_location,
     reply->qual[ncount].name_ident = ct.name_ident, reply->qual[ncount].pending_flag = ct
     .pending_flag, reply->qual[ncount].print_range_flag = ct.print_range_flag,
     reply->qual[ncount].report_template_id = ct.report_template_id, reply->qual[ncount].
     route_location_bit_map = ct.route_location_bit_map, reply->qual[ncount].scope_flag = ct
     .scope_flag,
     reply->qual[ncount].updt_dt_tm = cnvtdatetime(ct.updt_dt_tm), reply->qual[ncount].updt_id = ct
     .updt_id, reply->qual[ncount].days_nbr = ct.days_nbr,
     reply->qual[ncount].date_dt_tm = validate(ct.date_dt_tm,null), reply->qual[ncount].
     dms_service_name = ct.dms_service_name, reply->qual[ncount].additional_copy_nbr = ct
     .additional_copy_nbr,
     reply->qual[ncount].sending_organization_id = ct.sending_org_id
     IF (ct.chart_trigger_id=ct.prev_chart_trigger_id)
      working->cnt += 1
      IF ((working->cnt > size(working->qual,5)))
       stat = alterlist(working->qual,(working->cnt+ 9))
      ENDIF
      working->qual[working->cnt].chart_trigger_id = ct.chart_trigger_id, working->qual[working->cnt]
      .seq = ncount
     ELSE
      non_working->cnt += 1
      IF ((non_working->cnt > size(non_working->qual,5)))
       stat = alterlist(non_working->qual,(non_working->cnt+ 9))
      ENDIF
      non_working->qual[non_working->cnt].chart_trigger_id = ct.chart_trigger_id, non_working->qual[
      non_working->cnt].prev_chart_trigger_id = ct.prev_chart_trigger_id, non_working->qual[
      non_working->cnt].seq = ncount,
      non_working->qual[non_working->cnt].beg_dt_tm = cnvtdatetime(ct.beg_effective_dt_tm),
      non_working->qual[non_working->cnt].end_dt_tm = cnvtdatetime(ct.end_effective_dt_tm)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->qual,ncount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_TRIGGER","LoadBaseInformationByIds",1,1)
   CALL log_message(build("Exit LoadBaseInformationByIds(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadparaminformationfornonworkingtriggers(null)
   CALL log_message("In LoadParamInformationForNonWorkingTriggers()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   SELECT INTO "nl:"
    FROM chart_trigger_param ctp,
     (dummyt d  WITH seq = value(non_working->cnt))
    PLAN (d)
     JOIN (ctp
     WHERE (ctp.chart_trigger_id=non_working->qual[d.seq].prev_chart_trigger_id)
      AND ctp.end_effective_dt_tm >= cnvtdatetime(non_working->qual[d.seq].end_dt_tm)
      AND ctp.beg_effective_dt_tm < cnvtdatetime(non_working->qual[d.seq].end_dt_tm))
    ORDER BY ctp.chart_trigger_id
    HEAD ctp.chart_trigger_id
     ncount = 0, ntrigloc = non_working->qual[d.seq].seq
    DETAIL
     IF (ntrigloc > 0)
      ncount += 1
      IF (ncount > size(reply->qual[ntrigloc].params,5))
       stat = alterlist(reply->qual[ntrigloc].params,(ncount+ 19))
      ENDIF
      reply->qual[ntrigloc].params[ncount].active_ind = ctp.active_ind, reply->qual[ntrigloc].params[
      ncount].beg_effective_dt_tm = cnvtdatetime(ctp.beg_effective_dt_tm), reply->qual[ntrigloc].
      params[ncount].chart_trigger_id = ctp.chart_trigger_id,
      reply->qual[ntrigloc].params[ncount].chart_trigger_param_id = ctp.chart_trigger_param_id, reply
      ->qual[ntrigloc].params[ncount].end_effective_dt_tm = cnvtdatetime(ctp.end_effective_dt_tm),
      reply->qual[ntrigloc].params[ncount].include_ind = ctp.include_ind,
      reply->qual[ntrigloc].params[ncount].parent_entity_id = ctp.parent_entity_id, reply->qual[
      ntrigloc].params[ncount].parent_entity_name = ctp.parent_entity_name, reply->qual[ntrigloc].
      params[ncount].param_type_flag = ctp.param_type_flag,
      reply->qual[ntrigloc].params[ncount].updt_dt_tm = cnvtdatetime(ctp.updt_dt_tm)
     ENDIF
    FOOT  ctp.chart_trigger_id
     stat = alterlist(reply->qual[ntrigloc].params,ncount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_TRIGGER_PARAM","LoadParamInformation",1,1)
   CALL log_message(build(
     "Exit LoadParamInformationForNonWorkingTriggers(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadparaminformationforworkingtriggers(null)
   CALL log_message("In LoadParamInformationForWorkingTriggers()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idx2 = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(size(working->qual,5)), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(working->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET working->qual[i].chart_trigger_id = working->qual[nrecordsize].chart_trigger_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_trigger_param ctp
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (ctp
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ctp.chart_trigger_id,working->qual[idx].
      chart_trigger_id,
      bind_cnt)
      AND ctp.active_ind=1)
    ORDER BY ctp.chart_trigger_id
    HEAD ctp.chart_trigger_id
     ncount = 0, loc = locateval(idx2,1,nrecordsize,ctp.chart_trigger_id,working->qual[idx2].
      chart_trigger_id), ntrigloc = working->qual[loc].seq
    DETAIL
     IF (ntrigloc > 0)
      ncount += 1
      IF (ncount > size(reply->qual[ntrigloc].params,5))
       stat = alterlist(reply->qual[ntrigloc].params,(ncount+ 19))
      ENDIF
      reply->qual[ntrigloc].params[ncount].active_ind = ctp.active_ind, reply->qual[ntrigloc].params[
      ncount].beg_effective_dt_tm = cnvtdatetime(ctp.beg_effective_dt_tm), reply->qual[ntrigloc].
      params[ncount].chart_trigger_id = ctp.chart_trigger_id,
      reply->qual[ntrigloc].params[ncount].chart_trigger_param_id = ctp.chart_trigger_param_id, reply
      ->qual[ntrigloc].params[ncount].end_effective_dt_tm = cnvtdatetime(ctp.end_effective_dt_tm),
      reply->qual[ntrigloc].params[ncount].include_ind = ctp.include_ind,
      reply->qual[ntrigloc].params[ncount].parent_entity_id = ctp.parent_entity_id, reply->qual[
      ntrigloc].params[ncount].parent_entity_name = ctp.parent_entity_name, reply->qual[ntrigloc].
      params[ncount].param_type_flag = ctp.param_type_flag,
      reply->qual[ntrigloc].params[ncount].updt_dt_tm = cnvtdatetime(ctp.updt_dt_tm)
     ENDIF
    FOOT  ctp.chart_trigger_id
     stat = alterlist(reply->qual[ntrigloc].params,ncount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_TRIGGER_PARAM","LoadParamInformation",1,1)
   CALL log_message(build("Exit LoadParamInformationForWorkingTriggers(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cr_get_trigger_qualifier",log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
