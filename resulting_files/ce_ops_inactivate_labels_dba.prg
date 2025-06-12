CREATE PROGRAM ce_ops_inactivate_labels:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE event_batch_ensure_transaction_number = i4 WITH protect, constant(1000071)
 DECLARE subroutine_failure = i2 WITH protect, constant(0)
 DECLARE subroutine_success = i2 WITH protect, constant(1)
 DECLARE script_name = c23 WITH protect, constant("ce_ops_inactivate_labels")
 DECLARE label_cnt = i4 WITH noconstant(0.0)
 DECLARE event_batch_ensure_step_handle = i4 WITH protect, noconstant(0)
 DECLARE event_batch_ensure_request_handle = i4 WITH protect, noconstant(0)
 DECLARE event_batch_ensure_reply_handle = i4 WITH protect, noconstant(0)
 DECLARE application_handle = i4 WITH protect, noconstant(0)
 DECLARE task_handle = i4 WITH protect, noconstant(0)
 DECLARE crm_status = i4 WITH protect, noconstant(0)
 DECLARE enable_debug = i2 WITH protect, noconstant(0)
 DECLARE status_data_handle = i4 WITH protect, noconstant(0)
 DECLARE transaction_status = i2 WITH protect, noconstant(0)
 DECLARE dynamic_label_handle = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationstatus))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectvalue))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt += 1
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 RECORD dynamic_label(
   1 qual_list[*]
     2 ce_dynamic_label_id = f8
     2 new_dynamic_label_id = f8
     2 prev_dynamic_label_id = f8
     2 label_name = vc
     2 new_label_prsnl_id = f8
     2 label_template_id = f8
     2 label_status_cd = f8
     2 person_id = f8
     2 result_set_id = f8
 )
 RECORD cval(
   1 inactive_status_cd = f8
   1 inerror_status_cd = f8
 )
 DECLARE discharge_hours = f8 WITH protect, constant(get_in_discharge_hours_preference(null))
 SUBROUTINE (get_in_discharge_hours_preference(null) =f8)
   DECLARE dsch_hours = f8
   CALL echo("looking up INDSCH_HRS preference")
   SELECT INTO "nl:"
    cp.config_name
    FROM config_prefs cp
    WHERE cp.config_name="INDSCH_HRS"
    DETAIL
     dsch_hours = cnvtreal(trim(cp.config_value))
    WITH nocounter
   ;end select
   RETURN(dsch_hours)
 END ;Subroutine
 DECLARE discharge_days = i4
 SET discharge_days = ((discharge_hours/ 24)+ 2)
 CALL echo(build("discharge_days-->",discharge_days))
 SET now = cnvtdatetime(sysdate)
 SET minimum_discharge_date_time = datetimeadd(now,- (discharge_days))
 SET maximum_discharge_date_time = cnvtdatetime(sysdate)
 IF (discharge_hours > 0)
  SET maximum_discharge_date_time = datetimeadd(now,- ((discharge_hours/ 24.0)))
 ENDIF
 CALL echo(build("maximum_discharge_date_time->",format(maximum_discharge_date_time,";;Q")))
 CALL echo(build("minimum_discharge_date_time->",format(minimum_discharge_date_time,";;Q")))
 CALL echo("looking up code_values")
 SET code_set = 4002015
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "INACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET cval->inactive_status_cd = code_value
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET cval->inerror_status_cd = code_value
 CALL echo("retrieving dynamic labels")
 SELECT DISTINCT INTO "nl:"
  ce.ce_dynamic_label_id
  FROM encounter e,
   clinical_event ce,
   ce_dynamic_label cdl,
   dynamic_label_template dlt
  PLAN (e
   WHERE e.disch_dt_tm > cnvtdatetime(minimum_discharge_date_time)
    AND e.disch_dt_tm < cnvtdatetime(maximum_discharge_date_time))
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.ce_dynamic_label_id > 0
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (cdl
   WHERE cdl.ce_dynamic_label_id=ce.ce_dynamic_label_id
    AND (cdl.label_status_cd != cval->inactive_status_cd)
    AND (cdl.label_status_cd != cval->inerror_status_cd))
   JOIN (dlt
   WHERE cdl.label_template_id=dlt.label_template_id
    AND dlt.encounter_specific_ind=1)
  HEAD REPORT
   label_cnt = 0
  DETAIL
   label_cnt += 1
   IF (label_cnt > size(dynamic_label->qual_list,5))
    stat = alterlist(dynamic_label->qual_list,(label_cnt+ 5))
   ENDIF
   dynamic_label->qual_list[label_cnt].ce_dynamic_label_id = cdl.ce_dynamic_label_id, dynamic_label->
   qual_list[label_cnt].prev_dynamic_label_id = cdl.prev_dynamic_label_id, dynamic_label->qual_list[
   label_cnt].label_name = cdl.label_name,
   dynamic_label->qual_list[label_cnt].new_label_prsnl_id = reqinfo->updt_id, dynamic_label->
   qual_list[label_cnt].label_status_cd = cdl.label_status_cd, dynamic_label->qual_list[label_cnt].
   label_template_id = cdl.label_template_id,
   dynamic_label->qual_list[label_cnt].person_id = cdl.person_id, dynamic_label->qual_list[label_cnt]
   .result_set_id = cdl.result_set_id
  FOOT REPORT
   stat = alterlist(dynamic_label->qual_list,label_cnt)
  WITH nocounter, orahintcbo("INDEX(e XIE4ENCOUNTER)","INDEX(ce XIE19CLINICAL_EVENT)",
    "INDEX(cdl XPKCE_DYNAMIC_LABEL)","INDEX(dlt XPKDYNAMIC_LABEL_TEMPLATE)","USE_NL(e ce cdl dlt)",
    "LEADING(e ce cdl dlt)")
 ;end select
 FOR (x = 1 TO label_cnt)
   SELECT INTO "nl:"
    y = seq(ocf_seq,nextval)
    FROM dual
    DETAIL
     dynamic_label->qual_list[x].new_dynamic_label_id = y
    WITH nocounter
   ;end select
 ENDFOR
 FOR (index = 1 TO label_cnt)
   IF (populate_event_batch_ensure_request(null)=subroutine_failure)
    GO TO exit_script
   ENDIF
   IF (call_event_batch_ensure(null)=subroutine_failure)
    GO TO exit_script
   ENDIF
   CALL uar_crmendreq(event_batch_ensure_step_handle)
   CALL uar_crmendtask(task_handle)
   CALL uar_crmendapp(application_handle)
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL uar_crmendreq(event_batch_ensure_step_handle)
 CALL uar_crmendtask(task_handle)
 CALL uar_crmendapp(application_handle)
 SUBROUTINE (populate_event_batch_ensure_request(null) =i4)
   SET crm_status = uar_crmbeginapp(event_batch_ensure_transaction_number,application_handle)
   IF (((crm_status != 0) OR (application_handle=0)) )
    CALL subevent_add("ERROR","F",script_name,"Unable to retrieve application handle")
    RETURN(subroutine_failure)
   ENDIF
   SET crm_status = uar_crmbegintask(application_handle,event_batch_ensure_transaction_number,
    task_handle)
   IF (((crm_status != 0) OR (task_handle=0)) )
    CALL log_message(build("Unable to begin task #",event_batch_ensure_transaction_number,
      " for ce_ops_inactivate_labels"),log_level_error)
    CALL subevent_add("ERROR","F",script_name,build("Unable to begin task #",
      event_batch_ensure_transaction_number))
    RETURN(subroutine_failure)
   ENDIF
   SET crm_status = uar_crmbeginreq(task_handle,"",event_batch_ensure_transaction_number,
    event_batch_ensure_step_handle)
   IF (((crm_status != 0) OR (event_batch_ensure_step_handle=0)) )
    CALL log_message(build("Unable to begin request #",event_batch_ensure_transaction_number,
      ", for ce_ops_inactivate_labels, stat=",stat),log_level_error)
    CALL subevent_add("ERROR","F",script_name,build("Unable to begin request #",
      event_batch_ensure_transaction_number,", for ce_ops_inactivate_labels, stat=",stat))
    RETURN(subroutine_failure)
   ELSE
    SET event_batch_ensure_request_handle = uar_crmgetrequest(event_batch_ensure_step_handle)
    IF (event_batch_ensure_request_handle=0)
     CALL uar_crmendreq(event_batch_ensure_step_handle)
     CALL log_message(build("Unable to get request #",event_batch_ensure_transaction_number,
       ", for ce_ops_inactivate_labels, stat=",stat),log_level_error)
     CALL subevent_add("ERROR","F",script_name,build("Unable to get request #",
       event_batch_ensure_transaction_number,", for ce_ops_inactivate_labels"))
     RETURN(subroutine_failure)
    ELSE
     CALL populate_dynamic_labels(null)
    ENDIF
   ENDIF
   RETURN(subroutine_success)
 END ;Subroutine
 SUBROUTINE (populate_dynamic_labels(null) =null)
   SET curalias label dynamic_label->qual_list[index]
   SET dynamic_label_handle = uar_srvadditem(event_batch_ensure_request_handle,"dynamic_label")
   SET stat = uar_srvsetdouble(dynamic_label_handle,"label_template_id",label->label_template_id)
   SET stat = uar_srvsetstringfixed(dynamic_label_handle,"label_name",nullterm(label->label_name),
    size(label->label_name,1))
   SET stat = uar_srvsetdouble(dynamic_label_handle,"ce_dynamic_label_id",label->
    prev_dynamic_label_id)
   SET stat = uar_srvsetdouble(dynamic_label_handle,"replacement_label_id",label->
    new_dynamic_label_id)
   SET stat = uar_srvsetdouble(dynamic_label_handle,"result_set_group",label->result_set_id)
   SET stat = uar_srvsetdouble(dynamic_label_handle,"label_status_cd",cval->inactive_status_cd)
   SET stat = uar_srvsetdouble(dynamic_label_handle,"label_prsnl_id",label->new_label_prsnl_id)
   SET stat = uar_srvsetdouble(dynamic_label_handle,"person_id",label->person_id)
 END ;Subroutine
 SUBROUTINE (call_event_batch_ensure(null) =i2)
   SET stat = uar_crmperform(event_batch_ensure_step_handle)
   IF (stat != 0)
    CALL log_message(build("Event Batch Ensure call failed with status= ",stat,
      ", for ce_ops_inactivate_labels"),log_level_error)
    CALL subevent_add("ERROR","F",script_name,build("Event Batch Ensure call failed with status= ",
      stat))
    SET stat = uar_crmendreq(event_batch_ensure_step_handle)
    RETURN(subroutine_failure)
   ENDIF
   SET event_batch_ensure_reply_handle = uar_crmgetreply(event_batch_ensure_step_handle)
   CALL log_message("******Log CE Reply",log_level_debug)
   IF (enable_debug=1)
    CALL uar_crmlogmessage(event_batch_ensure_reply_handle,"ce_ops_inactivate_labels.dat")
   ENDIF
   IF (event_batch_ensure_reply_handle > 0)
    SET status_data_handle = uar_srvgetstruct(event_batch_ensure_reply_handle,"sb")
    SET transaction_status = uar_srvgetlong(status_data_handle,"statusCd")
    IF (transaction_status != 0)
     SET sstatusmsg = uar_srvgetstringptr(status_data_handle,"statusText")
     CALL log_message(build(trim(sstatusmsg)," ce_ops_inactivate_labels "),log_level_error)
     CALL subevent_add("ERROR","F",script_name,trim(sstatusmsg))
     CALL uar_crmendreq(event_batch_ensure_step_handle)
     RETURN(subroutine_failure)
    ENDIF
   ELSE
    CALL log_message(build("Invalid handle for event batch ensure reply for ce_ops_inactivate_labels"
      ),log_level_error)
    CALL subevent_add("ERROR","F",script_name,"Invalid handle for event batch ensure reply")
    CALL uar_crmendreq(event_batch_ensure_step_handle)
    RETURN(subroutine_failure)
   ENDIF
   RETURN(subroutine_success)
 END ;Subroutine
END GO
