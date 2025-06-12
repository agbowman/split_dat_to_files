CREATE PROGRAM cp_void_pathway_instance:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Pathway Instance ID" = 0.0,
  "INPUT PERSON ID" = 0.0,
  "INPUT PROVIDER ID" = 0.0,
  "INPUT ENCOUNTER ID" = 0.0,
  "INPUT PPR" = 0.0,
  "SIGN EVENT CHECK" = 0.0
  WITH outdev, pathwayinstanceid, inputpersonid,
  inputproviderid, inputencounterid, inputppr,
  sign_event_check
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
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
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
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
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
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
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
 FREE RECORD audit_init_request
 RECORD audit_init_request(
   1 object_name = vc
   1 object_params = vc
   1 output_device = vc
   1 temp_file = vc
   1 report_type = c12
   1 person_id = f8
   1 omf_object_cd = f8
   1 long_text = vc
   1 crm_reqnum = i4
 ) WITH persistscript
 FREE RECORD audit_init_reply
 RECORD audit_init_reply(
   1 report_audit_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 SUBROUTINE (logblobindata(objectname=vc,longtext=vc,tempfile=vc) =null WITH protect)
   SET audit_init_request->object_name = objectname
   SET audit_init_request->object_params = "Blob In"
   SET audit_init_request->long_text = longtext
   SET audit_init_request->report_type = "REPORT"
   SET audit_init_request->output_device = "MINE"
   EXECUTE ccl_add_rpt_audit  WITH replace("REQUEST",audit_init_request), replace("REPLY",
    audit_init_reply)
 END ;Subroutine
 SUBROUTINE (updateauditinitreply(status=vc) =null WITH protect)
   IF ((audit_init_reply->report_audit_id > 0))
    UPDATE  FROM ccl_report_audit cra
     SET cra.status = status, cra.end_dt_tm = cnvtdatetime(sysdate), cra.updt_cnt = 1,
      cra.updt_id = reqinfo->updt_id, cra.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (cra.report_event_id=audit_init_reply->report_audit_id)
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE (setauditinitreplystatusbyprogramreplystatus(reply=vc(ref)) =null WITH protect)
  IF (validate(debug_ind,0)=1)
   CALL echorecord(audit_init_reply)
  ENDIF
  IF ((reply->status_data.status="S"))
   CALL updateauditinitreply("SUCCESS")
  ELSE
   CALL updateauditinitreply("FAILED")
  ENDIF
 END ;Subroutine
 IF ( NOT (validate(mp_common_output_imported)))
  EXECUTE mp_common_output
 ENDIF
 FREE RECORD cp_void_pathway_instance_reply
 RECORD cp_void_pathway_instance_reply(
   1 has_sign_events = i2
   1 in_error_status = i2
   1 in_error_on_first_call = i2
   1 failing_method_name = c25
   1 eventids[*]
     2 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD event_id_details
 RECORD event_id_details(
   1 event_ids[*]
     2 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD ce_request
 RECORD ce_request(
   1 event_id = f8
   1 query_mode = i4
   1 subtable_bit_map_ind = i2
   1 valid_from_dt_tm_ind = i2
   1 valid_from_dt_tm = dq8
 ) WITH protect
 FREE RECORD ce_record
 RECORD ce_record(
   1 rb_list[*]
     2 clinical_event_id = f8
     2 event_id = f8
     2 reference_nbr = vc
     2 valid_until_dt_tm = dq8
     2 clinsig_updt_dt_tm = dq8
     2 view_level = i4
     2 order_id = f8
     2 catalog_cd = f8
     2 catalog_cd_disp = vc
     2 series_ref_nbr = vc
     2 person_id = f8
     2 encntr_id = f8
     2 parent_event_id = f8
     2 valid_from_dt_tm = dq8
     2 event_class_cd = f8
     2 event_cd = f8
     2 event_cd_disp = vc
     2 event_title_text = vc
     2 event_start_dt_tm = dq8
     2 event_end_dt_tm = dq8
     2 result_status_cd = f8
     2 result_status_cd_disp = vc
     2 publish_flag = i2
     2 normalcy_cd = f8
     2 normalcy_cd_disp = vc
     2 normalcy_cd_mean = vc
     2 collating_seq = vc
     2 result_val = vc
     2 result_units_cd = f8
     2 result_units_cd_disp = vc
     2 verified_dt_tm = dq8
     2 verified_prsnl_id = f8
     2 performed_dt_tm = dq8
     2 performed_prsnl_id = f8
     2 normal_low = vc
     2 normal_high = vc
     2 critical_low = vc
     2 critical_high = vc
     2 updt_dt_tm = dq8
     2 contributor_system_cd = f8
     2 contributor_system_cd_disp = vc
     2 accession_nbr = vc
     2 resource_cd = f8
     2 resource_cd_disp = vc
     2 normal_ref_range_txt = vc
     2 blob_result[*]
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_until_dt_tm = dq8
       3 max_sequence_nbr = i4
       3 format_cd = f8
       3 blob[*]
         4 blob_length = i4
         4 compression_cd = f8
         4 blob_contents = gvc
         4 blob_text = vc
     2 child_event_list[*]
       3 clinical_event_id = f8
       3 event_id = f8
       3 valid_until_dt_tm = dq8
       3 clinsig_updt_dt_tm = dq8
       3 view_level = i4
       3 parent_event_id = f8
       3 valid_from_dt_tm = dq8
       3 event_class_cd = f8
       3 event_class_cd_disp = vc
       3 event_cd = f8
       3 event_cd_disp = vc
       3 event_title_text = vc
       3 event_tag = vc
       3 event_start_dt_tm = dq8
       3 event_end_dt_tm = dq8
       3 result_val = vc
       3 result_units_cd = f8
       3 result_units_cd_disp = vc
       3 result_status_cd = f8
       3 result_status_cd_disp = vc
       3 publish_flag = i2
       3 collating_seq = vc
       3 verified_dt_tm = dq8
       3 verified_prsnl_id = f8
       3 updt_dt_tm = dq8
       3 blob_result[*]
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_until_dt_tm = dq8
         4 max_sequence_nbr = i4
         4 format_cd = f8
         4 blob[*]
           5 blob_length = i4
           5 compression_cd = f8
           5 blob_contents = gvc
           5 blob_text = vc
         4 blob_handle = vc
       3 date_result[*]
         4 event_id = f8
         4 result_dt_tm = dq8
       3 event_note_list[*]
         4 ce_event_note_id = f8
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 event_note_id = f8
         4 event_id = f8
         4 note_type_cd = f8
         4 note_type_cd_disp = vc
         4 note_type_cd_mean = vc
         4 note_format_cd = f8
         4 note_format_cd_disp = vc
         4 note_format_cd_mean = vc
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 entry_method_cd = f8
         4 entry_method_cd_disp = vc
         4 entry_method_cd_mean = vc
         4 note_prsnl_id = f8
         4 note_dt_tm = dq8
         4 note_dt_tm_ind = i2
         4 record_status_cd = f8
         4 record_status_cd_disp = vc
         4 record_status_cd_mean = vc
         4 compression_cd = f8
         4 compression_cd_disp = vc
         4 compression_cd_mean = vc
         4 checksum = i4
         4 checksum_ind = i2
         4 long_blob = gvc
         4 long_blob_txt = vc
         4 long_blob_length = i4
         4 long_text = vc
         4 long_text_id = f8
         4 non_chartable_flag = i2
         4 importance_flag = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_id = f8
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
         4 note_tz = i4
       3 security_label_list[*]
         4 clinical_event_sec_lbl_id = f8
         4 event_id = f8
         4 sensitivity_reason_cd = f8
         4 sensitivity_reason_cd_disp = vc
         4 created_by_prsnl_id = f8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 active_ind = i2
         4 action_prsnl_id = f8
         4 updt_id = f8
         4 updt_dt_tm = dq8
         4 updt_task = i4
         4 updt_applctx = i4
         4 updt_cnt = i4
       3 child_event_list[*]
         4 clinical_event_id = f8
         4 event_id = f8
         4 valid_until_dt_tm = dq8
         4 clinsig_updt_dt_tm = dq8
         4 view_level = i4
         4 parent_event_id = f8
         4 valid_from_dt_tm = dq8
         4 event_class_cd = f8
         4 event_class_cd_disp = vc
         4 event_cd = f8
         4 event_cd_disp = vc
         4 event_title_text = vc
         4 event_start_dt_tm = dq8
         4 event_end_dt_tm = dq8
         4 result_val = vc
         4 result_units_cd = f8
         4 result_units_cd_disp = vc
         4 result_status_cd = f8
         4 result_status_cd_disp = vc
         4 publish_flag = i2
         4 collating_seq = vc
         4 verified_dt_tm = dq8
         4 verified_prsnl_id = f8
         4 updt_dt_tm = dq8
         4 blob_result[*]
           5 event_id = f8
           5 valid_from_dt_tm = dq8
           5 valid_until_dt_tm = dq8
           5 max_sequence_nbr = i4
           5 format_cd = f8
           5 blob[*]
             6 blob_length = i4
             6 compression_cd = f8
             6 blob_contents = gvc
             6 blob_text = vc
           5 blob_summary[*]
             6 ce_blob_summary_id = f8
             6 blob_summary_id = f8
             6 long_blob = gvc
         4 date_result[*]
           5 event_id = f8
           5 result_dt_tm = dq8
         4 event_note_list[*]
           5 ce_event_note_id = f8
           5 valid_until_dt_tm = dq8
           5 valid_until_dt_tm_ind = i2
           5 event_note_id = f8
           5 event_id = f8
           5 note_type_cd = f8
           5 note_type_cd_disp = vc
           5 note_type_cd_mean = vc
           5 note_format_cd = f8
           5 note_format_cd_disp = vc
           5 note_format_cd_mean = vc
           5 valid_from_dt_tm = dq8
           5 valid_from_dt_tm_ind = i2
           5 entry_method_cd = f8
           5 entry_method_cd_disp = vc
           5 entry_method_cd_mean = vc
           5 note_prsnl_id = f8
           5 note_dt_tm = dq8
           5 note_dt_tm_ind = i2
           5 record_status_cd = f8
           5 record_status_cd_disp = vc
           5 record_status_cd_mean = vc
           5 compression_cd = f8
           5 compression_cd_disp = vc
           5 compression_cd_mean = vc
           5 checksum = i4
           5 checksum_ind = i2
           5 long_blob = gvc
           5 long_blob_txt = vc
           5 long_blob_length = i4
           5 long_text = vc
           5 long_text_id = f8
           5 non_chartable_flag = i2
           5 importance_flag = i2
           5 updt_dt_tm = dq8
           5 updt_dt_tm_ind = i2
           5 updt_id = f8
           5 updt_task = i4
           5 updt_task_ind = i2
           5 updt_cnt = i4
           5 updt_cnt_ind = i2
           5 updt_applctx = i4
           5 updt_applctx_ind = i2
           5 note_tz = i4
         4 security_label_list[*]
           5 clinical_event_sec_lbl_id = f8
           5 event_id = f8
           5 sensitivity_reason_cd = f8
           5 sensitivity_reason_cd_disp = vc
           5 created_by_prsnl_id = f8
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 active_ind = i2
           5 action_prsnl_id = f8
           5 updt_id = f8
           5 updt_dt_tm = dq8
           5 updt_task = i4
           5 updt_applctx = i4
           5 updt_cnt = i4
         4 child_event_list[*]
           5 clinical_event_id = f8
           5 event_id = f8
           5 parent_event_id = f8
           5 event_class_cd = f8
           5 event_class_cd_disp = vc
           5 event_cd = f8
           5 event_cd_disp = vc
           5 event_title_text = vc
           5 event_start_dt_tm = dq8
           5 event_end_dt_tm = dq8
           5 result_val = vc
           5 result_units_cd = f8
           5 result_units_cd_disp = vc
           5 result_status_cd = f8
           5 result_status_cd_disp = vc
           5 collating_seq = vc
           5 date_result[*]
             6 event_id = f8
             6 result_dt_tm = dq8
           5 event_note_list[*]
             6 event_note_id = f8
           5 security_label_list[*]
             6 clinical_event_sec_lbl_id = f8
             6 event_id = f8
             6 sensitivity_reason_cd = f8
             6 sensitivity_reason_cd_disp = vc
             6 created_by_prsnl_id = f8
             6 beg_effective_dt_tm = dq8
             6 end_effective_dt_tm = dq8
             6 active_ind = i2
             6 action_prsnl_id = f8
             6 updt_id = f8
             6 updt_dt_tm = dq8
             6 updt_task = i4
             6 updt_applctx = i4
             6 updt_cnt = i4
           5 child_event_list[*]
             6 clinical_event_id = f8
             6 event_id = f8
             6 parent_event_id = f8
             6 event_class_cd = f8
             6 event_class_cd_disp = vc
             6 event_cd = f8
             6 event_cd_disp = vc
             6 event_title_text = vc
             6 event_start_dt_tm = dq8
             6 event_end_dt_tm = dq8
             6 result_val = vc
             6 result_units_cd = f8
             6 result_units_cd_disp = vc
             6 result_status_cd = f8
             6 result_status_cd_disp = vc
             6 collating_seq = vc
             6 date_result[*]
               7 event_id = f8
               7 result_dt_tm = dq8
             6 event_note_list[*]
               7 event_note_id = f8
             6 security_label_list[*]
               7 clinical_event_sec_lbl_id = f8
               7 event_id = f8
               7 sensitivity_reason_cd = f8
               7 sensitivity_reason_cd_disp = vc
               7 created_by_prsnl_id = f8
               7 beg_effective_dt_tm = dq8
               7 end_effective_dt_tm = dq8
               7 active_ind = i2
               7 action_prsnl_id = f8
               7 updt_id = f8
               7 updt_dt_tm = dq8
               7 updt_task = i4
               7 updt_applctx = i4
               7 updt_cnt = i4
       3 contributor_system_cd = f8
     2 event_note_list[*]
       3 ce_event_note_id = f8
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 event_note_id = f8
       3 event_id = f8
       3 note_type_cd = f8
       3 note_type_cd_disp = vc
       3 note_type_cd_mean = vc
       3 note_format_cd = f8
       3 note_format_cd_disp = vc
       3 note_format_cd_mean = vc
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 entry_method_cd = f8
       3 entry_method_cd_disp = vc
       3 entry_method_cd_mean = vc
       3 note_prsnl_id = f8
       3 note_dt_tm = dq8
       3 note_dt_tm_ind = i2
       3 record_status_cd = f8
       3 record_status_cd_disp = vc
       3 record_status_cd_mean = vc
       3 compression_cd = f8
       3 compression_cd_disp = vc
       3 compression_cd_mean = vc
       3 checksum = i4
       3 checksum_ind = i2
       3 long_blob = gvc
       3 long_blob_txt = vc
       3 long_blob_length = i4
       3 long_text = vc
       3 long_text_id = f8
       3 non_chartable_flag = i2
       3 importance_flag = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_id = f8
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 note_tz = i4
     2 event_prsnl_list[*]
       3 ce_event_prsnl_id = f8
       3 event_prsnl_id = f8
       3 person_id = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 action_type_cd = f8
       3 action_type_cd_disp = vc
       3 request_dt_tm = dq8
       3 request_dt_tm_ind = i2
       3 request_prsnl_id = f8
       3 request_prsnl_ft = vc
       3 request_comment = vc
       3 action_dt_tm = dq8
       3 action_dt_tm_ind = i2
       3 action_prsnl_id = f8
       3 action_prsnl_ft = vc
       3 proxy_prsnl_id = f8
       3 proxy_prsnl_ft = vc
       3 action_status_cd = f8
       3 action_status_cd_disp = vc
       3 action_comment = vc
       3 change_since_action_flag = i2
       3 change_since_action_flag_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_id = f8
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 long_text_id = f8
       3 long_text = vc
       3 linked_event_id = f8
       3 request_tz = i4
       3 action_tz = i4
       3 system_comment = vc
       3 digital_signature_ident = vc
       3 action_prsnl_group_id = f8
       3 request_prsnl_group_id = f8
       3 receiving_person_id = f8
       3 receiving_person_ft = vc
     2 specimen_coll[*]
       3 event_id = f8
       3 specimen_id = f8
       3 collect_dt_tm = dq8
       3 source_type_cd = f8
       3 source_type_cd_disp = vc
       3 collect_loc_cd = f8
       3 collect_loc_cd_disp = vc
       3 recvd_dt_tm = dq8
       3 body_site_cd_disp = vc
     2 date_result[*]
       3 event_id = f8
       3 result_dt_tm = dq8
     2 microbiology_list[*]
       3 event_id = f8
       3 micro_seq_nbr = i4
       3 micro_seq_nbr_ind = i2
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 organism_cd = f8
       3 organism_cd_disp = vc
       3 organism_cd_desc = vc
       3 organism_cd_mean = vc
       3 organism_occurrence_nbr = i4
       3 organism_occurrence_nbr_ind = i2
       3 organism_type_cd = f8
       3 organism_type_cd_disp = vc
       3 organism_type_cd_mean = vc
       3 observation_prsnl_id = f8
       3 biotype = vc
       3 probability = f8
       3 positive_ind = i2
       3 positive_ind_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_id = f8
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 susceptibility_list[*]
         4 event_id = f8
         4 micro_seq_nbr = i4
         4 micro_seq_nbr_ind = i2
         4 suscep_seq_nbr = i4
         4 suscep_seq_nbr_ind = i2
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 susceptibility_test_cd = f8
         4 susceptibility_test_cd_disp = vc
         4 susceptibility_test_cd_mean = vc
         4 detail_susceptibility_cd = f8
         4 detail_susceptibility_cd_disp = vc
         4 detail_susceptibility_cd_mean = vc
         4 panel_antibiotic_cd = f8
         4 panel_antibiotic_cd_disp = vc
         4 panel_antibiotic_cd_mean = vc
         4 antibiotic_cd = f8
         4 antibiotic_cd_disp = vc
         4 antibiotic_cd_desc = vc
         4 antibiotic_cd_mean = vc
         4 diluent_volume = f8
         4 diluent_volume_ind = i2
         4 result_cd = f8
         4 result_cd_disp = vc
         4 result_cd_mean = vc
         4 result_text_value = vc
         4 result_numeric_value = f8
         4 result_numeric_value_ind = i2
         4 result_unit_cd = f8
         4 result_unit_cd_disp = vc
         4 result_unit_cd_mean = vc
         4 result_dt_tm = dq8
         4 result_dt_tm_ind = i2
         4 result_prsnl_id = f8
         4 susceptibility_status_cd = f8
         4 susceptibility_status_cd_disp = vc
         4 susceptibility_status_cd_mean = vc
         4 abnormal_flag = i2
         4 abnormal_flag_ind = i2
         4 chartable_flag = i2
         4 chartable_flag_ind = i2
         4 nomenclature_id = f8
         4 antibiotic_note = vc
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_id = f8
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
         4 result_tz = i4
     2 suscep_footnote_r_list[*]
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 micro_seq_nbr = i4
       3 micro_seq_nbr_ind = i2
       3 suscep_seq_nbr = i4
       3 suscep_seq_nbr_ind = i2
       3 suscep_footnote_id = f8
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_id = f8
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 suscep_footnote[*]
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 ce_suscep_footnote_id = f8
         4 suscep_footnote_id = f8
         4 checksum = i4
         4 checksum_ind = i2
         4 compression_cd = f8
         4 format_cd = f8
         4 contributor_system_cd = f8
         4 blob_length = i4
         4 blob_length_ind = i2
         4 reference_nbr = vc
         4 long_blob = gvc
         4 long_text = vc
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_id = f8
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
     2 security_label_list[*]
       3 clinical_event_sec_lbl_id = f8
       3 event_id = f8
       3 sensitivity_reason_cd = f8
       3 sensitivity_reason_cd_disp = vc
       3 created_by_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
       3 action_prsnl_id = f8
       3 updt_id = f8
       3 updt_dt_tm = dq8
       3 updt_task = i4
       3 updt_applctx = i4
       3 updt_cnt = i4
   1 prsnl[*]
     2 id = f8
     2 person_name_id = f8
     2 active_date = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 provider_name
       3 name_full = vc
       3 name_first = vc
       3 name_middle = vc
       3 name_last = vc
       3 username = vc
       3 initials = vc
       3 title = vc
   1 codes[*]
     2 sequence = i4
     2 code = f8
     2 code_set = f8
     2 display = vc
     2 description = vc
     2 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD unchart_result_data
 RECORD unchart_result_data(
   1 rep[*]
     2 sb
       3 severitycd = i4
       3 statuscd = i4
       3 statustext = vc
       3 substatuslist[*]
         4 substatuscd = i4
     2 rb_list[*]
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 event_cd = f8
       3 result_status_cd = f8
       3 contributor_system_cd = f8
       3 reference_nbr = vc
       3 collating_seq = vc
       3 parent_event_id = f8
       3 prsnl_list[*]
         4 event_prsnl_id = f8
         4 action_prsnl_id = f8
         4 action_type_cd = f8
         4 action_dt_tm = dq8
         4 action_dt_tm_ind = i2
         4 action_tz = i4
         4 updt_cnt = i4
       3 clinical_event_id = f8
       3 updt_cnt = i4
       3 result_set_link_list[*]
         4 result_set_id = f8
         4 entry_type_cd = f8
         4 updt_cnt = i4
       3 ce_dynamic_label_id = f8
   1 dynamic_label_list[*]
     2 ce_dynamic_label_id = f8
     2 label_name = vc
     2 label_prsnl_id = f8
     2 label_status_cd = f8
     2 result_set_id = f8
     2 label_seq_nbr = i4
     2 valid_from_dt_tm = dq8
   1 sb
     2 severitycd = i4
     2 statuscd = i4
     2 statustext = vc
     2 substatuslist[*]
       3 substatuscd = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD structure_components
 RECORD structure_components(
   1 cnt = i4
   1 qual[*]
     2 event_id = f8
     2 workflow_component_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE main(null) = null WITH protect
 DECLARE loadstructurecomponents(null) = null WITH protect
 DECLARE inerrorstructurecomponents(null) = null WITH protect
 DECLARE inerrorsignevents(null) = null WITH protect
 DECLARE getsigneventids(null) = null WITH protect
 DECLARE pathway_instance_id = f8 WITH protect, constant(cnvtreal( $PATHWAYINSTANCEID))
 DECLARE commit_assessment_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4003135,
   "COMMITASSESS"))
 DECLARE commit_treatment_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4003135,
   "COMMITTREAT"))
 DECLARE save_doc_action_detail_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4003199,
   "SAVEDOC"))
 DECLARE sign_event_action_detail_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4003199,
   "SIGNEVENT"))
 DECLARE sign_event_check = f8 WITH protect, constant(cnvtreal( $SIGN_EVENT_CHECK))
 DECLARE input_person_id = f8 WITH protect, constant(cnvtreal( $INPUTPERSONID))
 DECLARE input_provider_id = f8 WITH protect, constant(cnvtreal( $INPUTPROVIDERID))
 DECLARE input_encounter_id = f8 WITH protect, constant(cnvtreal( $INPUTENCOUNTERID))
 DECLARE input_ppr = f8 WITH protect, constant(cnvtreal( $INPUTPPR))
 DECLARE query_mode = f8 WITH protect, constant(336551937)
 CALL log_message(build2("Begin program ",log_program_name),log_level_debug)
 DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
 SET cp_void_pathway_instance_reply->has_sign_events = 0
 SET cp_void_pathway_instance_reply->in_error_status = 0
 SET cp_void_pathway_instance_reply->status_data.status = "F"
 CALL main(null)
 SET cp_void_pathway_instance_reply->status_data.status = "S"
 SUBROUTINE main(null)
   CALL log_message("Begin main()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL loadstructurecomponents(null)
   IF (validate(debug_ind))
    CALL echorecord(structure_components)
   ENDIF
   IF (sign_event_check=0)
    CALL getsigneventids(null)
   ELSE
    CALL inerrorsignevents(null)
    CALL inerrorstructurecomponents(null)
   ENDIF
   CALL log_message(build("Exit main(), Elapsed time in seconds:",((curtime3 - begin_curtime3)/ 100.0
     )),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadstructurecomponents(null)
   CALL log_message("Begin loadStructureComponents()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE comp_cntr = i4 WITH protect, noconstant(0)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE comp_index = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM cp_pathway_action cpa,
     cp_pathway_action_detail cpad
    PLAN (cpa
     WHERE cpa.pathway_instance_id=pathway_instance_id
      AND cpa.action_type_cd IN (commit_assessment_action_cd, commit_treatment_action_cd))
     JOIN (cpad
     WHERE cpad.cp_pathway_action_id=cpa.cp_pathway_action_id
      AND ((cpad.cp_action_detail_type_cd+ 0)=save_doc_action_detail_cd))
    ORDER BY cpa.cp_component_id, cpa.action_dt_tm
    HEAD cpa.cp_component_id
     comp_cntr += 1
     IF (comp_cntr > size(structure_components->qual,5))
      stat = alterlist(structure_components->qual,(comp_cntr+ 5))
     ENDIF
    DETAIL
     structure_components->qual[comp_cntr].event_id = cpad.action_detail_entity_id
    FOOT REPORT
     structure_components->cnt = comp_cntr, stat = alterlist(structure_components->qual,
      structure_components->cnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"CP_PATHWAY_ACTION","loadStructureComponents",1,0,
    cp_void_pathway_instance_reply)
   CALL log_message(build("Exit loadStructureComponents(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE inerrorstructurecomponents(null)
   CALL log_message("Begin inErrorStructureComponents()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE comp_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_wkf_comp_id = f8 WITH protect, noconstant(0)
   DECLARE cur_event_id = f8 WITH protect, noconstant(0)
   FREE RECORD err_struct_reply
   RECORD err_struct_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   FOR (comp_cntr = 1 TO structure_components->cnt)
     IF ((structure_components->qual[comp_cntr].event_id > 0)
      AND (structure_components->qual[comp_cntr].workflow_component_id > 0))
      SET cur_event_id = structure_components->qual[comp_cntr].event_id
      SET cur_wkf_comp_id = structure_components->qual[comp_cntr].workflow_component_id
      SET stat = initrec(err_struct_reply)
      EXECUTE cp_inerr_structure_doc "NOFORMS", value(cur_event_id), value(cur_wkf_comp_id) WITH
      replace("REPLY","ERR_STRUCT_REPLY")
      IF ((err_struct_reply->status_data.status="F"))
       SET stat = moverec(err_struct_reply->status_data,cp_void_pathway_instance_reply->status_data)
       ROLLBACK
       GO TO exit_script
      ELSE
       COMMIT
      ENDIF
     ENDIF
   ENDFOR
   CALL log_message(build("Exit inErrorStructureComponents(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE inerrorsignevents(null)
   CALL log_message("Begin inErrorSignEvents()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE event_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_event_id = f8 WITH protect, noconstant(0)
   DECLARE cur_event_cd = f8 WITH protect, noconstant(0)
   IF (validate(request->blob_in))
    IF ((request->blob_in > " "))
     CALL logblobindata("cp_void_pathway_instance",request->blob_in, $OUTDEV)
     IF (validate(debug_ind,0)=1)
      CALL echo(request->blob_in)
     ENDIF
     SET jrec = cnvtjsontorec(request->blob_in)
     IF (jrec=1)
      FOR (event_cntr = 1 TO size(event_id_details->event_ids,5))
        IF ((event_id_details->event_ids[event_cntr].event_id > 0))
         SET cur_event_id = event_id_details->event_ids[event_cntr].event_id
         SET stat = initrec(ce_request)
         SET ce_request->event_id = cur_event_id
         SET ce_request->query_mode = query_mode
         SET ce_request->subtable_bit_map_ind = 1
         SET ce_request->valid_from_dt_tm_ind = 0
         SET ce_request->valid_from_dt_tm = current_date_time
         EXECUTE mp_event_detail_query  WITH replace("REQUEST","CE_REQUEST"), replace("REPLY",
          "CE_RECORD")
         IF (size(ce_record->rb_list,5) > 0)
          SET cur_event_cd = ce_record->rb_list[1].event_cd
         ENDIF
         IF (cur_event_cd > 0)
          SET debug_ind = 1
          EXECUTE inn_mp_unchart_result "NOFORMS", input_person_id, input_provider_id,
          input_encounter_id, cur_event_cd, cur_event_id,
          input_ppr WITH replace("REPORT_DATA","UNCHART_RESULT_DATA")
          SET debug_ind = 0
         ENDIF
         IF ((unchart_result_data->status_data.status="F"))
          SET cp_void_pathway_instance_reply->in_error_status = 1
          SET cp_void_pathway_instance_reply->failing_method_name = unchart_result_data->status_data.
          subeventstatus[1].operationname
          SET cp_void_pathway_instance_reply->status_data.status = "S"
          GO TO exit_script
         ENDIF
        ENDIF
      ENDFOR
     ELSE
      GO TO exit_script
     ENDIF
     FREE RECORD request
    ENDIF
   ENDIF
   CALL log_message(build("Exit inErrorSignEvents(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getsigneventids(null)
   CALL log_message("Begin getSignEventIds()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE event_cntr = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM cp_pathway_action cpa,
     cp_pathway_action_detail cpad
    PLAN (cpa
     WHERE cpa.pathway_instance_id=pathway_instance_id
      AND cpa.action_type_cd IN (commit_treatment_action_cd))
     JOIN (cpad
     WHERE cpad.cp_pathway_action_id=cpa.cp_pathway_action_id
      AND ((cpad.cp_action_detail_type_cd+ 0) IN (sign_event_action_detail_cd)))
    DETAIL
     stat = alterlist(cp_void_pathway_instance_reply->eventids,(event_cntr+ 1)), event_cntr += 1,
     cp_void_pathway_instance_reply->eventids[event_cntr].event_id = cpad.action_detail_entity_id
    WITH nocounter
   ;end select
   IF (size(cp_void_pathway_instance_reply->eventids,5) > 0)
    SET cp_void_pathway_instance_reply->has_sign_events = 1
   ELSE
    CALL inerrorstructurecomponents(null)
    SET cp_void_pathway_instance_reply->in_error_on_first_call = 1
   ENDIF
   CALL log_message(build("Exit getSignEventIds(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0)=1)
  CALL echorecord(cp_void_pathway_instance_reply)
 ENDIF
 CALL putjsonrecordtofile(cp_void_pathway_instance_reply, $OUTDEV)
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",((curtime3 - begin_curtime3)/ 100.0)),
  log_level_debug)
END GO
