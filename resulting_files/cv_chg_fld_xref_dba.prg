CREATE PROGRAM cv_chg_fld_xref:dba
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
 FREE RECORD holder
 RECORD holder(
   1 rec[*]
     2 task_assay_cd = f8
     2 event_cd = f8
 )
 IF (validate(reply,"0")="0")
  RECORD reply(
    1 return_rec[*]
      2 xref_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  CALL cv_log_message("reply already defined!")
 ENDIF
 IF (validate(cv_trns_del)=0)
  DECLARE cv_trns_add = i2 WITH protect, constant(1)
  DECLARE cv_trns_chg = i2 WITH protect, constant(2)
  DECLARE cv_trns_del = i2 WITH protect, constant(3)
 ENDIF
 DECLARE xref_id = f8 WITH protect
 DECLARE failed = c1 WITH protect, noconstant("T")
 DECLARE event_cd = f8 WITH protect
 DECLARE meaningval = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE codeset = i4 WITH protect, constant(14003)
 DECLARE codevalue = f8 WITH protect
 DECLARE cvct = i4 WITH protect, noconstant(1)
 DECLARE cvct2 = i4 WITH protect
 DECLARE i = i4 WITH protect
 DECLARE irecordsize = i4 WITH protect, noconstant(cnvtint(size(request->cv_xref_rec,5)))
 DECLARE eventcnt = i4 WITH protect
 DECLARE updt_cnt = i4 WITH protect
 DECLARE updt_id = f8 WITH protect, noconstant(reqinfo->updt_id)
 DECLARE stat = i4 WITH protect
 SET stat = alterlist(holder->rec,irecordsize)
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->return_rec,irecordsize)
 FOR (initial_cnt = 1 TO irecordsize)
   IF ((request->cv_xref_rec[initial_cnt].transaction=cv_trns_chg))
    SET reply->return_rec[initial_cnt].xref_id = request->cv_xref_rec[initial_cnt].xref_id
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = value(irecordsize))
  PLAN (d
   WHERE (request->cv_xref_rec[d.seq].cdf_meaning > " "))
   JOIN (cv
   WHERE (cv.cdf_meaning=request->cv_xref_rec[d.seq].cdf_meaning)
    AND cv.code_set=codeset
    AND cv.active_ind=1)
  DETAIL
   holder->rec[d.seq].task_assay_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM discrete_task_assay dta,
   (dummyt d1  WITH seq = value(irecordsize))
  PLAN (d1
   WHERE (holder->rec[d1.seq].task_assay_cd != 0.0))
   JOIN (dta
   WHERE (dta.task_assay_cd=holder->rec[d1.seq].task_assay_cd)
    AND dta.active_ind=1)
  DETAIL
   holder->rec[d1.seq].event_cd = dta.event_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "F"
  GO TO selection_failure
 ENDIF
 UPDATE  FROM cv_xref ref,
   (dummyt d3  WITH seq = value(irecordsize))
  SET ref.xref_internal_name = request->cv_xref_rec[d3.seq].xref_internal_name, ref
   .registry_field_name = request->cv_xref_rec[d3.seq].registry_field_name, ref
   .cern_source_table_name = request->cv_xref_rec[d3.seq].cern_source_table_name,
   ref.cern_source_field_name = request->cv_xref_rec[d3.seq].cern_source_field_name, ref
   .event_type_cd = request->cv_xref_rec[d3.seq].event_type_cd, ref.sub_event_type_cd = request->
   cv_xref_rec[d3.seq].sub_event_type_cd,
   ref.field_type_cd = request->cv_xref_rec[d3.seq].field_type_cd, ref.group_type_cd = request->
   cv_xref_rec[d3.seq].group_type_cd, ref.event_cd = holder->rec[d3.seq].event_cd,
   ref.task_assay_cd = holder->rec[d3.seq].task_assay_cd, ref.reqd_flag = request->cv_xref_rec[d3.seq
   ].reqdflag, ref.display_field_ind = request->cv_xref_rec[d3.seq].display_fld_ind,
   ref.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ref.end_effective_dt_tm = cnvtdatetime(
    "31-Dec-2100"), ref.updt_dt_tm = cnvtdatetime(curdate,curtime),
   ref.updt_cnt = (ref.updt_cnt+ 1), ref.updt_id = reqinfo->updt_id, ref.updt_task = reqinfo->
   updt_task,
   ref.updt_applctx = reqinfo->updt_applctx, ref.active_status_cd = reqdata->active_status_cd, ref
   .updt_req = reqinfo->updt_req,
   ref.updt_app = reqinfo->updt_app, ref.active_ind = 1, ref.collect_start_dt_tm = cnvtdatetime(
    request->cv_xref_rec[d3.seq].collect_start_dt_tm),
   ref.collect_stop_dt_tm = cnvtdatetime(request->cv_xref_rec[d3.seq].collect_stop_dt_tm), ref
   .audit_flag = request->cv_xref_rec[d3.seq].audit_flag, ref.element_nbr = request->cv_xref_rec[d3
   .seq].element_nbr
  PLAN (d3
   WHERE (request->cv_xref_rec[d3.seq].transaction=cv_trns_chg))
   JOIN (ref
   WHERE (ref.xref_id=request->cv_xref_rec[d3.seq].xref_id)
    AND ref.active_ind=1)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "F"
  GO TO update_failure
 ENDIF
 GO TO exit_script
#selection_failure
 IF (failed="F")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname =
  "CODE_VALUE, DISCRETE_TASK_ASSAY tableS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "EVENT_CD, TASK_ASSAY_CD"
  GO TO exit_script
 ENDIF
#update_failure
 IF (failed="F")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "update record"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
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
 DECLARE cv_chg_fld_xref_vrsn = vc WITH private, constant("MOD 005 - MH9140 - 12/30/2004")
END GO
