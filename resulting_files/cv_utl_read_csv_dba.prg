CREATE PROGRAM cv_utl_read_csv:dba
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
 CALL echorecord(request,"cer_temp:cv_utl_read_csv_request.dat")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 max_values = i4
    1 list[*]
      2 line = vc
      2 values[*]
        3 value = vc
        3 name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(internal_cvutlreadcsv,0)))
  RECORD internal_cvutlreadcsv(
    1 header[*]
      2 name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET failure = "F"
 SET header_row = fillstring(32000," ")
 IF ( NOT (validate(request->data_in_mem_ind,0)))
  FREE DEFINE rtl3
  DEFINE rtl3 value(request->file_name)
  SELECT INTO "NL:"
   log = r.line
   FROM rtl3t r
   HEAD REPORT
    nbr_lines = 0
   DETAIL
    nbr_lines = (nbr_lines+ 1)
    IF (nbr_lines > 1)
     stat = alterlist(reply->list,(nbr_lines - 1)), reply->list[(nbr_lines - 1)].line = r.line
    ELSE
     header_row = r.line
    ENDIF
   WITH nocounter, maxcol = 32000
  ;end select
 ELSE
  SET header_row = rep_parse->list[1].line
 ENDIF
 CALL echo(build("Header:",header_row))
 CALL echorecord(reply,"cer_temp:read_csv_reply.dat")
 DECLARE curparsedone = i2 WITH protect
 DECLARE curpos = i4 WITH protect
 DECLARE param_pos = i4 WITH protect
 DECLARE cv_parse_data(param_sep=vc(ref),param_string=vc(ref),param_pos=i4(ref)) = vc
 SUBROUTINE cv_parse_data(param_sep,param_string,param_pos)
   SET curparsedone = 0
   SET curpos = findstring(param_sep,param_string,param_pos)
   IF (curpos=0)
    SET curpos = (size(param_string,1)+ 1)
    SET curparsedone = 1
   ENDIF
   IF (param_pos=0)
    SET param_pos = 1
   ENDIF
   SET retval = substring(param_pos,(curpos - param_pos),param_string)
   SET param_pos = (curpos+ size(param_sep,1))
   IF (curparsedone=1)
    SET param_pos = - (1)
   ENDIF
   RETURN(retval)
 END ;Subroutine
 DECLARE parse_string = vc
 DECLARE parse_sep = vc
 IF (size(trim(request->delim))=0)
  SET parse_sep = "|"
 ELSE
  SET parse_sep = trim(request->delim)
 ENDIF
 CALL echo(build("The size of the Header is:",size(trim(header_row))))
 SET parse_pos = 0
 SET parse_string = header_row
 SET ret_str = fillstring(100," ")
 SET valuesize = 0
 WHILE ((parse_pos != - (1)))
   SET ret_str = cv_parse_data(parse_sep,parse_string,parse_pos)
   SET valuesize = (valuesize+ 1)
   SET stat = alterlist(internal_cvutlreadcsv->header,valuesize)
   SET internal_cvutlreadcsv->header[valuesize].name = ret_str
 ENDWHILE
 CALL echo(concat("The number of Columns is -",cnvtstring(valuesize)))
 CALL echo(concat("The number of rows of data is:",cnvtstring(size(reply->list,5))))
 FOR (i = 1 TO size(reply->list,5))
   SET parse_pos = 0
   SET parse_string = reply->list[i].line
   SET ret_str = fillstring(100," ")
   SET size = 0
   WHILE ((parse_pos != - (1)))
     SET size = (size+ 1)
     IF (size(internal_cvutlreadcsv->header,5) < size)
      CALL cv_log_message(build("There are more data columns than header columns ",size))
      GO TO exit_script
     ENDIF
     SET ret_str = cv_parse_data(parse_sep,parse_string,parse_pos)
     SET stat = alterlist(reply->list[i].values,size)
     SET reply->list[i].values[size].value = ret_str
     SET reply->list[i].values[size].name = internal_cvutlreadcsv->header[size].name
   ENDWHILE
   IF ((size > reply->max_values))
    SET reply->max_values = size
   ENDIF
   IF (valuesize != size)
    CALL cv_log_message("Error - Header Size, and Case Size are different")
    CALL echo(build("Header Sizes -",valuesize))
    CALL echo(build("List  Size  -",size))
   ENDIF
 ENDFOR
 CALL echorecord(reply,"cer_temp:read_csv_reply21.dat")
 SET failure = "F"
#exit_script
 IF (failure="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply,"cer_temp:cv_utl_read_csv_reply.dat")
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
