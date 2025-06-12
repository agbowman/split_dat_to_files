CREATE PROGRAM cv_utl_num_ce_only:dba
 PROMPT
  "output(Mine):" = mine,
  "Event_Id(9999):" = 9999
 SET event_id =  $2
 SET myeventid = fillstring(32000," ")
 SET myneweventid = fillstring(32000," ")
 SET myeventid = build("ce.parent_event_id = ",event_id," and ce.event_id != ",event_id)
 SET numevents = 0
 SET dcp_event_cd = 0
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
 SUBROUTINE cv_get_cd_for_cdf(param_codeset,param_cdfmeaning)
   SET cdf_meaning = fillstring(12," ")
   SET code_value = 0.0
   SET cdf_meaning = param_cdfmeaning
   SET code_set = param_codeset
   SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
   IF (code_value=0)
    CALL cv_log_message(concat("UAR Routine failed for code_set ",cnvtstring(code_set),
      "with cdf_meaning ",cdf_meaning))
   ENDIF
   IF (iret > 1)
    CALL cv_log_message(concat("UAR Routine found multiple code_values(",cnvtstring(iret),
      ") for code_set ",cnvtstring(code_set),"with cdf_meaning ",
      cdf_meaning))
   ENDIF
   RETURN(code_value)
 END ;Subroutine
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
 SET dcp_event_cd = cv_get_cd_for_cdf(72,"DCPGENERIC")
 CALL echo(build("The event Code is::",dcp_event_cd))
 RECORD internal(
   1 fields[*]
     2 event_cd = f8
     2 event_disp = vc
     2 dta_cd = f8
     2 dta_disp = vc
     2 event_id = f8
     2 result_val = vc
   1 event[*]
     2 event_mean = vc
     2 event_cnt = i4
     2 sub_event[*]
       3 sub_event_mean = vc
       3 sub_event_cnt = i4
 )
#start_select
 SELECT
  ce.event_id, event_disp = uar_get_code_display(ce.event_cd), task_assay = uar_get_code_display(ce
   .task_assay_cd),
  result = ce.result_val
  FROM clinical_event ce
  PLAN (ce
   WHERE parser(myeventid)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-dec-2100"))
  ORDER BY event_disp
  HEAD REPORT
   "event_disp", col + 5, "task_assay",
   col + 5, "result ", row + 1
  DETAIL
   numevents = (numevents+ 1)
   IF (size(trim(myneweventid)) > 0)
    myneweventid = build(myneweventid,",",ce.event_id)
   ELSE
    myneweventid = build("ce.parent_event_id in (",ce.event_id)
   ENDIF
   IF (ce.event_cd != dcp_event_cd)
    event_disp, col + 5, task_assay,
    col + 5, result, row + 1,
    stat = alterlist(internal->fields,(size(internal->fields,5)+ 1)), internal->fields[size(internal
     ->fields,5)].event_cd = ce.event_cd, internal->fields[size(internal->fields,5)].event_disp =
    event_disp,
    internal->fields[size(internal->fields,5)].dta_cd = ce.task_assay_cd, internal->fields[size(
     internal->fields,5)].dta_disp = task_assay, internal->fields[size(internal->fields,5)].event_id
     = ce.event_id,
    internal->fields[size(internal->fields,5)].result_val = result
   ENDIF
  WITH nocounter, maxcol = 1000, format = variable,
   maxrow = 1, noformfeed
 ;end select
 IF (curqual > 0)
  SET myeventid = build(myneweventid,")")
  SET myneweventid = fillstring(32000," ")
  GO TO start_select
 ENDIF
 SELECT INTO  $1
  *
  FROM (dummyt d  WITH seq = value(size(internal->fields,5)))
  PLAN (d)
  HEAD REPORT
   rep = fillstring(1000," "), "event_disp", col + 5,
   "task_assay", col + 5, "result ",
   row + 1
  DETAIL
   internal->fields[d.seq].event_id, ",", col + 5,
   internal->fields[d.seq].event_cd, ",", col + 5,
   internal->fields[d.seq].event_disp, ",", col + 5,
   internal->fields[d.seq].dta_cd, ",", col + 5,
   internal->fields[d.seq].dta_disp, ",", col + 5,
   internal->fields[d.seq].result_val, row + 1
  WITH nocounter, maxcol = 10000, format = variable,
   maxrow = 1, noformfeed
 ;end select
END GO
