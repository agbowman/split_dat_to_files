CREATE PROGRAM cv_utl_verify_install:dba
 PROMPT
  "OutPut[Mine]" = "Mine",
  "Dataset(ACC02 / STS02)[STS02]" = "STS02"
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(curdate,curtime3),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 DECLARE cv_log_createhandle(dummy=i2) = null
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 DECLARE cv_log_current_default(dummy=i2) = null
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 DECLARE cv_echo(string=vc) = null
 SUBROUTINE cv_echo(string)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message(log_message_param=vc) = null
 SUBROUTINE cv_log_message(log_message_param)
   SET cv_log_err_num = (cv_log_err_num+ 1)
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message_status(object_name_param=vc,operation_status_param=c1,operation_name_param=vc,
  target_object_value_param=vc) = null
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 DECLARE cv_check_err(opname=vc,opstatus=c1,targetname=vc) = null
 SUBROUTINE cv_check_err(opname,opstatus,targetname)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD internal(
   1 line[*]
     2 prompt_msg = vc
     2 message = vc
 )
 SET reply->status_data.status = "F"
 SET failure = "F"
 DECLARE cv_dataset_id = f8 WITH noconstant
 DECLARE cv_msg_cnt = i4 WITH noconstant
 SET cv_dataset_internal_name =  $2
 SELECT INTO "nl:"
  t.*
  FROM cv_dataset t
  WHERE t.dataset_internal_name=cv_dataset_internal_name
  DETAIL
   cv_dataset_id = t.dataset_id
  WITH nocounter
 ;end select
 SET cv_msg_cnt = (cv_msg_cnt+ 1)
 SET stat = alterlist(internal->line,cv_msg_cnt)
 SET internal->line[cv_msg_cnt].prompt_msg = "Number of Dataset Found:"
 SET internal->line[cv_msg_cnt].message = build(curqual)
 SELECT INTO "nl:"
  t.*
  FROM cv_xref t
  WHERE t.dataset_id=cv_dataset_id
  WITH nocounter
 ;end select
 SET cv_msg_cnt = (cv_msg_cnt+ 1)
 SET stat = alterlist(internal->line,cv_msg_cnt)
 SET internal->line[cv_msg_cnt].prompt_msg = "Number of Xref Found:"
 SET internal->line[cv_msg_cnt].message = build(curqual)
 SELECT INTO "nl:"
  t.*
  FROM cv_xref t
  WHERE t.dataset_id=cv_dataset_id
   AND t.event_cd=0
  WITH nocounter
 ;end select
 SET cv_msg_cnt = (cv_msg_cnt+ 1)
 SET stat = alterlist(internal->line,cv_msg_cnt)
 SET internal->line[cv_msg_cnt].prompt_msg = "Number of Xref with 0 event code Found:"
 SET internal->line[cv_msg_cnt].message = build(curqual)
 SELECT INTO "nl:"
  t.*
  FROM cv_response t
  WHERE t.xref_id IN (
  (SELECT
   xref_id
   FROM cv_xref
   WHERE dataset_id=cv_dataset_id))
  WITH nocounter
 ;end select
 SET cv_msg_cnt = (cv_msg_cnt+ 1)
 SET stat = alterlist(internal->line,cv_msg_cnt)
 SET internal->line[cv_msg_cnt].prompt_msg = "Number of Response Found:"
 SET internal->line[cv_msg_cnt].message = build(curqual)
 SELECT INTO "nl:"
  t.*
  FROM cv_response t
  WHERE t.xref_id IN (
  (SELECT
   xref_id
   FROM cv_xref
   WHERE dataset_id=cv_dataset_id))
   AND t.field_type="A"
   AND t.nomenclature_id=0
  WITH nocounter
 ;end select
 SET cv_msg_cnt = (cv_msg_cnt+ 1)
 SET stat = alterlist(internal->line,cv_msg_cnt)
 SET internal->line[cv_msg_cnt].prompt_msg = "Number of Response with no Nomen  Found:"
 SET internal->line[cv_msg_cnt].message = build(curqual)
 SELECT INTO "nl:"
  t.*
  FROM cv_xref_validation t
  WHERE t.xref_id IN (
  (SELECT
   xref_id
   FROM cv_xref
   WHERE dataset_id=cv_dataset_id))
  WITH nocounter
 ;end select
 SET cv_msg_cnt = (cv_msg_cnt+ 1)
 SET stat = alterlist(internal->line,cv_msg_cnt)
 SET internal->line[cv_msg_cnt].prompt_msg = "Number of cv_xref_validation Found:"
 SET internal->line[cv_msg_cnt].message = build(curqual)
 SELECT INTO "nl:"
  t.*
  FROM cv_dataset_file t
  WHERE t.dataset_id=cv_dataset_id
  WITH nocounter
 ;end select
 SET cv_msg_cnt = (cv_msg_cnt+ 1)
 SET stat = alterlist(internal->line,cv_msg_cnt)
 SET internal->line[cv_msg_cnt].prompt_msg = "Number of cv_Dataset_file Found:"
 SET internal->line[cv_msg_cnt].message = build(curqual)
 SELECT INTO "nl:"
  t.*
  FROM cv_xref_field t
  WHERE t.xref_id IN (
  (SELECT
   xref_id
   FROM cv_xref
   WHERE dataset_id=cv_dataset_id))
  WITH nocounter
 ;end select
 SET cv_msg_cnt = (cv_msg_cnt+ 1)
 SET stat = alterlist(internal->line,cv_msg_cnt)
 SET internal->line[cv_msg_cnt].prompt_msg = "Number of cv_xref_field Found:"
 SET internal->line[cv_msg_cnt].message = build(curqual)
 SET cv_table_name = "CV_ALGORITHM"
 SET cv_table_where = "t.dataset_id = cv_Dataset_id"
 SET cv_parser_command = fillstring(32000," ")
 SET quote = char(34)
 SET cv_parser_command = concat("select into ",char(34),"nl:",char(34)," t.* from ",
  cv_table_name," t where ",cv_table_where," with nocounter go")
 CALL echo(cv_parser_command)
 CALL parser(cv_parser_command)
 SET cv_msg_cnt = (cv_msg_cnt+ 1)
 SET stat = alterlist(internal->line,cv_msg_cnt)
 SET internal->line[cv_msg_cnt].prompt_msg = "Number of Algorithm Found:"
 SET internal->line[cv_msg_cnt].message = build(curqual)
 SELECT INTO  $1
  t.*
  FROM (dummyt t  WITH seq = size(internal->line,5))
  HEAD REPORT
   "CVNet Installation Verification Report     ", "Count Number", row + 1
  DETAIL
   internal->line[t.seq].prompt_msg, col 50, internal->line[t.seq].message,
   row + 1
  WITH nocounter
 ;end select
#exit_script
 IF (failure="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 DECLARE cv_log_destroyhandle(dummy=i2) = null
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE cv_log_destroyhandle(dummy)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt = (cv_log_handle_cnt - 1)
   ENDIF
 END ;Subroutine
END GO
