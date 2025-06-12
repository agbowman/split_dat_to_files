CREATE PROGRAM cv_utl_export_dataset:dba
 PROMPT
  "Output Device: 'mine' " = "mine",
  "ACC or STS(ACC02/STS) 'STS': " = "STS",
  "Export Validation Data(Y/N)'Y': " = "Y",
  "Export Dataset Data(Y/N)'Y': " = "Y",
  "Dataset File(Y/N)'Y': " = "Y"
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
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET failed_cnt = 0
 SET dataset_id = 0.0
 SELECT INTO "nl:"
  d.*
  FROM cv_dataset d
  PLAN (d
   WHERE d.dataset_internal_name=cnvtupper( $2))
  DETAIL
   dataset_id = d.dataset_id
  WITH nocounter
 ;end select
 IF (cnvtupper( $3)="Y")
  SET file_name = concat("cer_temp:", $2,"_validation.csv")
  SELECT INTO value(file_name)
   *
   FROM cv_xref_validation xv,
    cv_xref x,
    cv_response r,
    cv_xref x2,
    cv_response r2
   PLAN (xv)
    JOIN (x
    WHERE x.xref_id=xv.xref_id
     AND x.dataset_id=dataset_id)
    JOIN (r
    WHERE r.response_id=xv.response_id)
    JOIN (x2
    WHERE x2.xref_id=xv.child_xref_id)
    JOIN (r2
    WHERE r2.response_id=xv.child_response_id)
   HEAD REPORT
    file_str = build("xref_internal_name",",","response_internal_name",",","child_xref_internal_name",
     ",","child_response_internal_name",",","rltnship_flag",",",
     "reqd_flag",",","offset_nbr"), file_str, row + 1
   DETAIL
    file_str = build(x.xref_internal_name,",",r.response_internal_name,",",x2.xref_internal_name,
     ",",r2.response_internal_name,",",xv.rltnship_flag,",",
     xv.reqd_flag,",",xv.offset_nbr), file_str, row + 1
   WITH nocounter, maxcol = 10000, format = variable,
    maxrow = 1, formfeed = post
  ;end select
  IF (curqual=0)
   SET cv_log_level = 0
   CALL cv_log_current_default(0)
   SET failed_cnt = (failed_cnt+ 1)
   CALL cv_log_message("Failure in getting valiadation data!")
  ENDIF
 ENDIF
 IF (cnvtupper( $4)="Y")
  SET file_name = concat("cer_temp:", $2,"_dataset.csv")
  SELECT INTO value(file_name)
   *
   FROM cv_dataset cd,
    cv_xref cx,
    cv_response cr
   PLAN (cd
    WHERE cd.dataset_id=dataset_id)
    JOIN (cx
    WHERE cd.dataset_id=cx.dataset_id)
    JOIN (cr
    WHERE cx.xref_id=cr.xref_id)
   HEAD REPORT
    one_row = 0, file_str = build("DatasetName",",","InternalFieldName_xref",",",
     "InternalFieldName_res",
     ",","RegistryFieldName",",","RegistryFieldShortName",",",
     "RegistryFieldCodeName",",","CDF_Meaning",",","CernSourceTableName",
     ",","CernSourceFieldName",",","FieldType",",",
     "A1",",","A2",",","A3",
     ",","A4",",","A5",",",
     "EventType",",","SubEventType",",","GroupType",
     ",","FieldTypeMean",",","ValidationScript",",",
     "AliasPoolMean",",","REQDFlag",",","DisplayFldInd",
     ",","CaseDateMean"), file_str,
    row + 1
   DETAIL
    IF (one_row=0)
     file_str = build(cd.dataset_internal_name,",",cd.display_name,",","Version # ----->",
      ",","01",",",",",",",
      ",",",",",",",",",",
      ",",",",",",",",",",
      ",",",",",",cd.validation_script,",",
      cd.alias_pool_mean,",",",",",",cd.case_date_mean), file_str, row + 1,
     one_row = (one_row+ 1)
    ENDIF
    safea1 =
    IF (findstring(",",cr.a1)) build('"',cr.a1,'"')
    ELSE cr.a1
    ENDIF
    , safea3 =
    IF (findstring(",",substring(1,50,cr.a3))) build('"',substring(1,50,cr.a3),'"')
    ELSE substring(1,50,cr.a3)
    ENDIF
    , file_str = build(cd.dataset_internal_name,",",cx.xref_internal_name,",",cr
     .response_internal_name,
     ",",cx.registry_field_name,",",",",",",
     uar_get_code_meaning(cx.task_assay_cd),",",cx.cern_source_table_name,",",cx
     .cern_source_field_name,
     ",",cr.field_type,",",safea1,",",
     cr.a2,",",safea3,",",cr.a4,
     ",",cr.a5,",",uar_get_code_meaning(cx.event_type_cd),",",
     uar_get_code_meaning(cx.sub_event_type_cd),",",uar_get_code_meaning(cx.group_type_cd),",",
     uar_get_code_meaning(cx.field_type_cd),
     ",",",",",",cx.reqd_flag,",",
     cx.display_field_ind,","),
    file_str, row + 1
   WITH nocounter, maxcol = 10000, format = variable,
    maxrow = 1, formfeed = post
  ;end select
  IF (curqual=0)
   SET cv_log_level = 0
   CALL cv_log_current_default(0)
   SET failed_cnt = (failed_cnt+ 1)
   CALL cv_log_message("Failure in getting dataset data!")
  ENDIF
 ENDIF
 IF (cnvtupper( $5)="Y")
  SET file_name = concat("cer_temp:", $2,"_files.csv")
  SELECT INTO value(file_name)
   *
   FROM cv_dataset cd,
    cv_xref cx,
    cv_xref_field cxf,
    cv_dataset_file cdf
   PLAN (cd
    WHERE cd.dataset_id=dataset_id)
    JOIN (cx
    WHERE cx.dataset_id=cd.dataset_id)
    JOIN (cxf
    WHERE cxf.dataset_id=cx.dataset_id
     AND cxf.xref_id=cx.xref_id)
    JOIN (cdf
    WHERE cdf.file_id=cxf.file_id)
   HEAD REPORT
    file_str = build("Dataset_Name",",","File_Name",",","File_Extension",
     ",","file_name_format",",","file_nbr",",",
     "Delimiter",",","Table_name",",","Column_name",
     ",","field_internal_name",",","position",",",
     "length",",","field_format",",","start",
     ",","columns",",","display_name"), file_str, row + 1
   DETAIL
    file_str = build(cd.dataset_internal_name,",",cdf.name,",",cdf.extension,
     ",",cdf.format_string,",",cdf.file_nbr,",",
     cdf.delimiter,",",cdf.table_name,",",cdf.column_name,
     ",",cx.xref_internal_name,",",cxf.position,",",
     cxf.length,",",cxf.format,",",",",
     ",",cxf.display_name), file_str, row + 1
   WITH nocounter, maxcol = 10000, format = variable,
    maxrow = 1, formfeed = post
  ;end select
  IF (curqual=0)
   SET cv_log_level = 0
   CALL cv_log_current_default(0)
   SET failed_cnt = (failed_cnt+ 1)
   CALL cv_log_message("Failure in getting dataset file data!")
  ENDIF
 ENDIF
#exit_script
 IF (failed_cnt=3)
  SET failed = "T"
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "F"
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
