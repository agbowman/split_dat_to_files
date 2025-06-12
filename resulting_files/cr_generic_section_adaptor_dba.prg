CREATE PROGRAM cr_generic_section_adaptor:dba
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
 SET log_program_name = "CR_GENERIC_SECTION_ADAPTOR"
 IF (validate(request) != 1)
  FREE RECORD request
  RECORD request(
    1 id = f8
    1 script_name = vc
    1 max_chars_per_line = i2
    1 person_id = f8
    1 encntr_list[*]
      2 encntr_id = f8
    1 event_list[*]
      2 event_id = f8
    1 accession_nbr = vc
    1 start_dt_tm = dq8
    1 end_dt_tm = dq8
    1 provider_prsnl_id = f8
    1 provider_prsnl_r_cd = f8
    1 encntr_list_populated = i2
  )
 ENDIF
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 rtf_documents[*]
      2 rtf[*]
        3 rtf_string = vc
    1 text[*]
      2 line = vc
    1 log_info[*]
      2 log_level = i2
      2 log_message = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE legacy_script(null) = null WITH protect
 DECLARE adaptor_script(null) = null WITH protect
 DECLARE look_for_ccl_errors(null) = i2 WITH protect
 DECLARE copy_log_messages(null) = null WITH protect
 DECLARE script_type = i2 WITH noconstant(- (1)), protect
 DECLARE process_type = i2 WITH noconstant(0), protect
 DECLARE execute_string = vc WITH noconstant(""), protect
 DECLARE log_reply_error = i2 WITH constant(0), protect
 DECLARE log_reply_info = i2 WITH constant(1), protect
 DECLARE log_reply_debug = i2 WITH constant(2), protect
 DECLARE log_reply_count = i4 WITH noconstant(0), protect
 DECLARE win32 = i2 WITH constant(0), protect
 DECLARE xr = i2 WITH constant(1), protect
 DECLARE win32_and_xr = i2 WITH constant(2), protect
 DECLARE xr_custom_dataelements = i2 WITH constant(3), protect
 DECLARE line_by_line = i2 WITH constant(0), protect
 DECLARE postscript = i2 WITH constant(1), protect
 DECLARE rtf = i2 WITH constant(2), protect
 DECLARE legacy = i2 WITH constant(1), protect
 DECLARE adaptor = i2 WITH constant(2), protect
 FREE RECORD adaptor_request
 RECORD adaptor_request(
   1 person_id = f8
   1 provider_prsnl_id = f8
   1 provider_prsnl_r_cd = f8
   1 accession_nbr = c20
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 event_list[*]
     2 event_id = f8
   1 encntr_list[*]
     2 encntr_id = f8
   1 max_chars_per_line = i2
   1 encntr_list_populated = i2
 )
 FREE RECORD legacy_request
 RECORD legacy_request(
   1 chart_request_id = f8
   1 chart_format_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 order_id = f8
   1 accession_nbr = c20
   1 request_type = i2
   1 scope_flag = i2
   1 pending_flag = i2
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 code_list[*]
     2 procedure_type_flag = i2
     2 code = f8
   1 event_list[*]
     2 event_id = f8
   1 encntr_list[*]
     2 encntr_id = f8
   1 param_list[*]
     2 value = vc
     2 value_type = vc
   1 result_lookup_ind = i2
   1 privileges[*]
     2 privilege_cd = f8
     2 default[*]
       3 granted_ind = i2
       3 exceptions[*]
         4 entity_name = vc
         4 type_cd = f8
         4 id = f8
       3 status
         4 success_ind = i2
     2 locations[*]
       3 location_id = f8
       3 privilege
         4 granted_ind = i2
         4 exceptions[*]
           5 entity_name = vc
           5 type_cd = f8
           5 id = f8
         4 status
           5 success_ind = i2
   1 non_ce_start_dt_tm = dq8
   1 non_ce_end_dt_tm = dq8
 )
 FREE RECORD legacy_reply
 RECORD legacy_reply(
   1 num_lines = f8
   1 qual[*]
     2 line = c255
   1 output_file = vc
   1 log_info[*]
     2 log_level = i2
     2 log_message = vc
   1 filtered_list[*]
     2 order_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD rtf_reply
 RECORD rtf_reply(
   1 error_ind = i2
   1 rtf_documents[*]
     2 rtf[*]
       3 rtf_string = vc
   1 log_info[*]
     2 log_level = i2
     2 log_message = vc
 )
 FREE RECORD line_by_line_reply
 RECORD line_by_line_reply(
   1 error_ind = i2
   1 text[*]
     2 line = vc
   1 log_info[*]
     2 log_level = i2
     2 log_message = vc
 )
 CALL log_message("Begin script: cr_generic_section_adaptor",log_level_debug)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM chart_discern_request cdr
  WHERE (cdr.script_name=request->script_name)
  DETAIL
   process_type = cdr.process_flag
   IF (cdr.process_system_flag=win32_and_xr
    AND cdr.process_flag=line_by_line
    AND cdr.request_number > 0
    AND cdr.active_ind=1)
    script_type = legacy
   ELSEIF (((cdr.process_system_flag=xr) OR (((cdr.process_system_flag=win32_and_xr) OR (cdr
   .process_system_flag=xr_custom_dataelements)) ))
    AND ((cdr.process_flag=line_by_line) OR (cdr.process_flag=rtf))
    AND cdr.request_number=0
    AND cdr.active_ind=1)
    script_type = adaptor
   ENDIF
  WITH nocounter
 ;end select
 DECLARE script_type_name = vc WITH noconstant(""), protect
 IF (script_type=adaptor)
  SET script_type_name = "adaptor"
 ELSEIF (script_type=legacy)
  SET script_type_name = "legacy"
 ELSE
  CALL log_reply(build2(request->script_name,
    " is an unsupported type of script. Check the chart_discern_request table."),log_reply_error)
  SET reply->status_data.status = "F"
  SET stat = populate_subeventstatus_msg("EXECUTE","F","XR","invalid script type",log_level_error)
  GO TO exit_script
 ENDIF
 IF (process_type=line_by_line)
  CALL log_reply(build2(request->script_name," is an ",script_type_name,
    " script that is line by line"),log_reply_debug)
 ELSEIF (process_type=rtf)
  CALL log_reply(build2(request->script_name," is an ",script_type_name," script that is rtf"),
   log_reply_debug)
 ELSE
  CALL log_reply(build2(request->script_name," is an ",script_type_name,
    " script of an unsupported output type"),log_reply_error)
  SET reply->status_data.status = "F"
  SET stat = populate_subeventstatus_msg("EXECUTE","F","XR","unsupported output type",log_level_error
   )
  GO TO exit_script
 ENDIF
 CALL error_and_zero_check(curqual,"chart_discern_request","determine script type",1,1)
 IF (script_type=legacy)
  SET legacy_request->person_id = request->person_id
  SET legacy_request->accession_nbr = request->accession_nbr
  SET legacy_request->start_dt_tm = request->start_dt_tm
  SET legacy_request->end_dt_tm = request->end_dt_tm
  IF (size(request->encntr_list,5) > 0)
   SET legacy_request->encntr_id = request->encntr_list[0].encntr_id
   SET stat = moverec(request->encntr_list,legacy_request->encntr_list)
  ENDIF
  IF (size(request->event_list,5) > 0)
   SET stat = moverec(request->event_list,legacy_request->event_list)
  ENDIF
  SELECT INTO "nl:"
   FROM cr_report_request rr
   WHERE (rr.report_request_id=request->id)
   DETAIL
    legacy_request->order_id = rr.order_id, legacy_request->request_type = rr.request_type_flag,
    legacy_request->scope_flag = rr.scope_flag,
    legacy_request->pending_flag = rr.result_status_flag, legacy_request->result_lookup_ind = rr
    .use_posting_date_ind
   WITH nocounter
  ;end select
  CALL error_and_zero_check(curqual,"report_request","populate report request ",1,1)
  CALL legacy_script(null)
 ELSEIF (script_type=adaptor)
  SET adaptor_request->person_id = request->person_id
  SET adaptor_request->accession_nbr = request->accession_nbr
  SET adaptor_request->start_dt_tm = request->start_dt_tm
  SET adaptor_request->end_dt_tm = request->end_dt_tm
  SET adaptor_request->provider_prsnl_id = request->provider_prsnl_id
  SET adaptor_request->provider_prsnl_r_cd = request->provider_prsnl_r_cd
  SET adaptor_request->encntr_list_populated = request->encntr_list_populated
  IF (size(request->encntr_list,5) > 0)
   SET stat = moverec(request->encntr_list,adaptor_request->encntr_list)
  ENDIF
  IF (size(request->event_list,5) > 0)
   SET stat = moverec(request->event_list,adaptor_request->event_list)
  ENDIF
  CALL adaptor_script(null)
 ENDIF
 SUBROUTINE legacy_script(null)
   SET execute_string = build2("Execute ",value(request->script_name),
    " with replace(request, legacy_request), replace(reply, legacy_reply) go")
   CALL log_message(value(execute_string),log_level_debug)
   CALL parser(execute_string,1)
   CALL copy_log_messages(null)
   SET reply->status_data = legacy_reply->status_data
   SET reply->status_data.status = legacy_reply->status_data.status
   IF ((((legacy_reply->status_data.status="s")) OR ((((legacy_reply->status_data.status="S")) OR (((
   (legacy_reply->status_data.status="z")) OR ((legacy_reply->status_data.status="Z"))) )) )) )
    SET ccl_error = look_for_ccl_errors(null)
    IF (ccl_error=1)
     SET reply->status_data.status = "F"
     SET stat = populate_subeventstatus_msg("EXECUTE","F","XR","legacy script produced ccl errors",
      log_level_error)
     GO TO exit_script
    ENDIF
    SET stat = alterlist(reply->text,size(legacy_reply->qual,5))
    IF (size(legacy_reply->qual,5) > 0)
     FOR (i = 1 TO size(legacy_reply->qual,5))
       SET reply->text[i].line = legacy_reply->qual[i].line
     ENDFOR
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET stat = alter(reply->status_data.subeventstatus,size(legacy_reply->status_data.subeventstatus,
      5))
    IF (size(reply->status_data.subeventstatus,5) > 0)
     FOR (i = 1 TO size(reply->status_data.subeventstatus,5))
       SET reply->status_data.subeventstatus[i].operationname = legacy_reply->status_data.
       subeventstatus[i].operationname
       SET reply->status_data.subeventstatus[i].operationstatus = legacy_reply->status_data.
       subeventstatus[i].operationstatus
       SET reply->status_data.subeventstatus[i].targetobjectname = legacy_reply->status_data.
       subeventstatus[i].targetobjectname
       SET reply->status_data.subeventstatus[i].targetobjectvalue = legacy_reply->status_data.
       subeventstatus[i].targetobjectvalue
     ENDFOR
    ENDIF
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE adaptor_script(null)
   DECLARE error_string = vc WITH noconstant(" "), protect
   SET adaptor_request->max_chars_per_line = request->max_chars_per_line
   IF (process_type=line_by_line)
    SET execute_string = build2("Execute ",value(request->script_name),
     " with replace(request, adaptor_request), replace(reply, line_by_line_reply) go")
    CALL log_message(value(execute_string),log_level_debug)
    CALL parser(execute_string,1)
    CALL copy_log_messages(null)
    SET ccl_error = look_for_ccl_errors(null)
    IF ((((line_by_line_reply->error_ind=1)) OR (ccl_error=1)) )
     SET reply->status_data.status = "F"
     IF ((line_by_line_reply->error_ind=1))
      SET error_string = concat(error_string," returned a error_ind = 1")
     ENDIF
     IF ((line_by_line_reply->error_ind=1)
      AND ccl_error=1)
      SET error_string = concat(error_string," and ")
     ENDIF
     IF (ccl_error=1)
      SET error_string = concat(error_string," produced ccl errors")
     ENDIF
     SET stat = populate_subeventstatus_msg("EXECUTE","F","XR",concat(build("The generic script: ",
        request->script_name),error_string),log_level_error)
     GO TO exit_script
    ELSE
     SET stat = moverec(line_by_line_reply->text,reply->text)
     SET do_nothing = 1
    ENDIF
   ELSEIF (process_type=rtf)
    SET execute_string = build2("Execute ",value(request->script_name),
     " with replace(REQUEST, adaptor_request), replace(REPLY, rtf_reply) go")
    CALL log_message(value(execute_string),log_level_debug)
    CALL parser(execute_string,1)
    CALL copy_log_messages(null)
    SET ccl_error = look_for_ccl_errors(null)
    IF ((((rtf_reply->error_ind=1)) OR (ccl_error=1)) )
     SET reply->status_data.status = "F"
     IF ((rtf_reply->error_ind=1))
      SET error_string = concat(error_string," returned a error_ind = 1")
     ENDIF
     IF ((rtf_reply->error_ind=1)
      AND ccl_error=1)
      SET error_string = concat(error_string," and ")
     ENDIF
     IF (ccl_error=1)
      SET error_string = concat(error_string," produced ccl errors")
     ENDIF
     SET stat = populate_subeventstatus_msg("EXECUTE","F","XR",concat(build("The generic script: ",
        request->script_name),error_string),log_level_error)
     GO TO exit_script
    ELSE
     SET stat = moverec(rtf_reply->rtf_documents,reply->rtf_documents)
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET stat = populate_subeventstatus_msg("EXECUTE","F","XR",
     "Unsupported process type.  XR only supports Line by Line (text) and RTF process types",
     log_level_error)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE look_for_ccl_errors(null)
   RETURN(error_message(1))
 END ;Subroutine
 SUBROUTINE (log_reply(message=vc,level=i2) =null WITH protect)
   SET log_reply_count += 1
   IF (mod(log_reply_count,10)=1)
    SET stat = alterlist(reply->log_info,(log_reply_count+ 10))
   ENDIF
   SET reply->log_info[log_reply_count].log_level = level
   SET reply->log_info[log_reply_count].log_message = message
   CALL echo(message)
 END ;Subroutine
 SUBROUTINE copy_log_messages(null)
   DECLARE max = i4 WITH noconstant(0), private
   SET max = size(line_by_line_reply->log_info,5)
   IF (max=0)
    SET max = size(legacy_reply->log_info,5)
    IF (max=0)
     SET max = size(rtf_reply->log_info,5)
    ENDIF
   ENDIF
   IF (max > 0)
    FOR (i = 1 TO max)
      SET log_reply_count += 1
      IF (mod(log_reply_count,10)=1)
       SET stat = alterlist(reply->log_info,(log_reply_count+ 10))
      ENDIF
      IF (size(line_by_line_reply->log_info,5) > 0)
       SET reply->log_info[log_reply_count].log_level = line_by_line_reply->log_info[i].log_level
       SET reply->log_info[log_reply_count].log_message = line_by_line_reply->log_info[i].log_message
      ELSEIF (size(legacy_reply->log_info,5) > 0)
       SET reply->log_info[log_reply_count].log_level = legacy_reply->log_info[i].log_level
       SET reply->log_info[log_reply_count].log_message = legacy_reply->log_info[i].log_message
      ELSEIF (size(rtf_reply->log_info,5) > 0)
       SET reply->log_info[log_reply_count].log_level = rtf_reply->log_info[i].log_level
       SET reply->log_info[log_reply_count].log_message = rtf_reply->log_info[i].log_message
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 IF (size(reply->text,5)=0
  AND size(reply->rtf_documents,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SET stat = alterlist(reply->log_info,log_reply_count)
 CALL log_message("Exiting script: cr_generic_section_adaptor",log_level_debug)
END GO
