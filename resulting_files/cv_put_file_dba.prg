CREATE PROGRAM cv_put_file:dba
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
 DECLARE cv_get_case_date_ec(dataset_id=f8) = f8
 DECLARE cv_get_code_by_dataset(dataset_id=f8,short_name=vc) = f8
 DECLARE cv_get_code_by(string_type=vc,code_set=i4,value=vc) = f8
 DECLARE l_case_date = vc WITH protect
 DECLARE l_case_date_dta = f8 WITH protect, noconstant(- (1.0))
 DECLARE l_case_date_ec = f8 WITH protect, noconstant(- (1.0))
 DECLARE get_code_ret = f8 WITH protect, noconstant(- (1.0))
 DECLARE dataset_prefix = vc WITH protect
 SUBROUTINE cv_get_case_date_ec(dataset_id_param)
   SET l_case_date = " "
   SET l_case_date_dta = - (1.0)
   SET l_case_date_ec = - (1.0)
   SELECT INTO "nl:"
    d.case_date_mean
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     l_case_date = d.case_date_mean
    WITH nocounter
   ;end select
   IF (size(trim(l_case_date)) > 0)
    SET l_case_date_dta = cv_get_code_by("MEANING",14003,nullterm(l_case_date))
    IF (l_case_date_dta > 0.0)
     SELECT INTO "nl:"
      dta.event_cd
      FROM discrete_task_assay dta
      WHERE dta.task_assay_cd=l_case_date_dta
      DETAIL
       l_case_date_ec = dta.event_cd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(l_case_date_ec)
 END ;Subroutine
 SUBROUTINE cv_get_code_by_dataset(dataset_id_param,short_name)
   SET dataset_prefix = " "
   SET get_code_ret = - (1.0)
   SELECT INTO "nl:"
    d.dataset_internal_name
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     CASE (d.dataset_internal_name)
      OF "STS02":
       dataset_prefix = "ST02"
      ELSE
       dataset_prefix = d.dataset_internal_name
     ENDCASE
    WITH nocounter
   ;end select
   CALL echo(build("dataset_prefix:",dataset_prefix))
   IF (size(trim(dataset_prefix)) > 0)
    SELECT INTO "nl:"
     x.event_cd
     FROM cv_xref x
     WHERE x.xref_internal_name=concat(trim(dataset_prefix),"_",short_name)
     DETAIL
      get_code_ret = x.event_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("get_code_ret:",get_code_ret))
   RETURN(get_code_ret)
 END ;Subroutine
 SUBROUTINE cv_get_code_by(string_type,code_set_param,value)
   SET get_code_ret = uar_get_code_by(nullterm(string_type),code_set_param,nullterm(trim(value)))
   IF (get_code_ret <= 0.0)
    CALL echo(concat("Failed uar_get_code_by(",string_type,",",trim(cnvtstring(code_set_param)),",",
      value,")"))
    SELECT
     IF (string_type="MEANING")
      WHERE cv.code_set=code_set_param
       AND cv.cdf_meaning=value
     ELSEIF (string_type="DISPLAYKEY")
      WHERE cv.code_set=code_set_param
       AND cv.display_key=value
     ELSEIF (string_type="DISPLAY")
      WHERE cv.code_set=code_set_param
       AND cv.display=value
     ELSEIF (string_type="DESCRIPTION")
      WHERE cv.code_set=code_set_param
       AND cv.description=value
     ELSE
      WHERE cv.code_value=0.0
     ENDIF
     INTO "nl:"
     FROM code_value cv
     DETAIL
      get_code_ret = cv.code_value
     WITH nocounter
    ;end select
    CALL echo(concat("code_value lookup result =",cnvtstring(get_code_ret)))
   ENDIF
   RETURN(get_code_ret)
 END ;Subroutine
 RECORD reply(
   1 file_name = vc
   1 reply_message = vc
   1 files[*]
     2 filename = vc
     2 info_line[*]
       3 new_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echorecord(request,"CER_TEMP:CVPUTFILE_REQUEST.dat")
 DECLARE codevalue_l = f8
 DECLARE codevalue_s = f8
 SET codevalue_l = 0.0
 SET codevalue_s = 0.0
 SET curfileindex = 0
 SET cdfmeaning_l = "DSDAT_LNAME"
 SET cdfmeaning_s = "DSDAT_SNAME"
 SET codeset = 25691
 SET cvct = 1
 SET i = 0
 SET codevalue_l = cv_get_code_by("MEANING",codeset,cdfmeaning_l)
 SET codevalue_s = cv_get_code_by("MEANING",codeset,cdfmeaning_s)
 CALL cv_log_message(build("CodeValue_S = ",codevalue_s,"CodeValue_L = ",codevalue_l))
 RECORD cdrec(
   1 codeval_l = f8
   1 codeval_s = f8
 )
 SET cdrec->codeval_l = codevalue_l
 SET cdrec->codeval_s = codevalue_s
 CALL echorecord(cdrec,"CER_TEMP:CVPUTFILE_cdrec.dat")
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cnt = 0
 SET dcl_com = fillstring(32000," ")
 CALL echorecord(request,"cer_Temp:cv_put_fileRequest.dat")
 SET num_dbimport = 0
 SET reply_message = fillstring(1000," ")
 SET file_name = fillstring(100," ")
 SET file_number = size(request->file,5)
 FOR (put_idx = 1 TO file_number)
   IF ((request->file[put_idx].prog_cd IN (codevalue_l, codevalue_s)))
    SET curfileindex = put_idx
    CALL cv_log_message("Entering cv_add_dataset_data")
    CALL echorecord(request,"cer_temp:temp1.dat")
    EXECUTE cv_add_dataset_data
   ELSE
    SET num_dbimport = 1
    SET file_name = value(build(cnvtlower(request->file[put_idx].file_name)))
    SET nbr_lines = size(request->file[put_idx].line,5)
    SELECT INTO value(file_name)
     d.*
     FROM (dummyt d  WITH seq = value(nbr_lines))
     DETAIL
      col 0,
      CALL print(trim(request->file[put_idx].line[d.seq].linedata))
      IF (d.seq < nbr_lines)
       row + 1
      ENDIF
     WITH format = variable, maxcol = 32000, noformfeed,
      maxrow = 1
    ;end select
    IF (curqual > 0)
     SET reply->status_data.status = "S"
     SET failed = "F"
    ELSE
     SET errcode = error(errmsg,1)
     SET failed = "T"
    ENDIF
    SET dcl_com = build("Copy CCLUSERDIR:",request->file[put_idx].file_name," CER_INSTALL")
    SET len = size(trim(dcl_com))
    SET status = 0
    CALL dcl(dcl_com,len,status)
   ENDIF
 ENDFOR
 IF (num_dbimport=1)
  EXECUTE cv_run_dbimport
 ENDIF
 IF (size(trim(reply_message)) > 0)
  SET reply->file_name = build(reply->file_name,". ",reply_message)
  SET reply->reply_message = reply_message
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.subeventstatus[1].operationname = "put"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_PUT_FILE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply,"cer_Temp:cv_put_fileReply.dat")
END GO
