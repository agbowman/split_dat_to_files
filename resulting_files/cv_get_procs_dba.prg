CREATE PROGRAM cv_get_procs:dba
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
 DECLARE phys_group_idx = i4 WITH noconstant(0)
 DECLARE phys_group_cnt = i4 WITH noconstant(0)
 DECLARE proc_status_idx = i4 WITH noconstant(0)
 DECLARE proc_status_cnt = i4 WITH noconstant(0)
 DECLARE proc_cnt = i4 WITH noconstant(0)
 DECLARE catalog_cnt = i4 WITH noconstant(0)
 DECLARE catalog_idx = i4 WITH noconstant(0)
 IF (validate(reply)=0)
  RECORD reply(
    1 cv_proc[*]
      2 cv_proc_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  SET proc_cnt = size(reply->cv_proc,5)
 ENDIF
 SET proc_status_cnt = size(request->proc_status,5)
 SET phys_group_cnt = size(request->phys_group,5)
 SET catalog_cnt = size(request->catalog,5)
 IF (proc_status_cnt=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT
  IF (phys_group_cnt=0
   AND (request->prim_physician_id=0.0)
   AND catalog_cnt=0)
   WHERE expand(proc_status_idx,1,proc_status_cnt,p.proc_status_cd,request->proc_status[
    proc_status_idx].proc_status_cd)
    AND ((p.cv_proc_id+ 0) > 0.0)
  ELSEIF (phys_group_cnt=0
   AND (request->prim_physician_id != 0.0)
   AND catalog_cnt=0)
   WHERE (p.prim_physician_id=request->prim_physician_id)
    AND expand(proc_status_idx,1,proc_status_cnt,p.proc_status_cd,request->proc_status[
    proc_status_idx].proc_status_cd)
  ELSEIF (phys_group_cnt > 0
   AND (request->prim_physician_id=0.0)
   AND catalog_cnt=0)
   WHERE expand(phys_group_idx,1,phys_group_cnt,p.phys_group_cd,request->phys_group[phys_group_idx].
    phys_group_cd)
    AND expand(proc_status_idx,1,proc_status_cnt,p.proc_status_cd,request->proc_status[
    proc_status_idx].proc_status_cd)
    AND ((p.cv_proc_id+ 0) > 0.0)
  ELSEIF (phys_group_cnt > 0
   AND (request->prim_physician_id != 0.0)
   AND catalog_cnt=0)
   WHERE (p.prim_physician_id=request->prim_physician_id)
    AND expand(phys_group_idx,1,phys_group_cnt,p.phys_group_cd,request->phys_group[phys_group_idx].
    phys_group_cd)
    AND expand(proc_status_idx,1,proc_status_cnt,p.proc_status_cd,request->proc_status[
    proc_status_idx].proc_status_cd)
  ELSEIF (phys_group_cnt=0
   AND (request->prim_physician_id=0.0)
   AND catalog_cnt > 0)
   WHERE expand(proc_status_idx,1,proc_status_cnt,p.proc_status_cd,request->proc_status[
    proc_status_idx].proc_status_cd)
    AND expand(catalog_idx,1,catalog_cnt,p.catalog_cd,request->catalog[catalog_idx].catalog_cd)
    AND ((p.cv_proc_id+ 0) > 0.0)
  ELSEIF (phys_group_cnt=0
   AND (request->prim_physician_id != 0.0)
   AND catalog_cnt > 0)
   WHERE (p.prim_physician_id=request->prim_physician_id)
    AND expand(proc_status_idx,1,proc_status_cnt,p.proc_status_cd,request->proc_status[
    proc_status_idx].proc_status_cd)
    AND expand(catalog_idx,1,catalog_cnt,p.catalog_cd,request->catalog[catalog_idx].catalog_cd)
  ELSEIF (phys_group_cnt > 0
   AND (request->prim_physician_id=0.0)
   AND catalog_cnt > 0)
   WHERE expand(phys_group_idx,1,phys_group_cnt,p.phys_group_cd,request->phys_group[phys_group_idx].
    phys_group_cd)
    AND expand(proc_status_idx,1,proc_status_cnt,p.proc_status_cd,request->proc_status[
    proc_status_idx].proc_status_cd)
    AND expand(catalog_idx,1,catalog_cnt,p.catalog_cd,request->catalog[catalog_idx].catalog_cd)
    AND ((p.cv_proc_id+ 0) > 0.0)
  ELSEIF (phys_group_cnt > 0
   AND (request->prim_physician_id != 0.0)
   AND catalog_cnt > 0)
   WHERE (p.prim_physician_id=request->prim_physician_id)
    AND expand(phys_group_idx,1,phys_group_cnt,p.phys_group_cd,request->phys_group[phys_group_idx].
    phys_group_cd)
    AND expand(proc_status_idx,1,proc_status_cnt,p.proc_status_cd,request->proc_status[
    proc_status_idx].proc_status_cd)
    AND expand(catalog_idx,1,catalog_cnt,p.catalog_cd,request->catalog[catalog_idx].catalog_cd)
  ELSE
  ENDIF
  INTO "nl:"
  FROM cv_proc p
  HEAD REPORT
   added_cnt = 0
  DETAIL
   proc_cnt = (proc_cnt+ 1), added_cnt = (added_cnt+ 1)
   IF (mod(added_cnt,10)=1)
    stat = alterlist(reply->cv_proc,(proc_cnt+ 9))
   ENDIF
   reply->cv_proc[proc_cnt].cv_proc_id = p.cv_proc_id
  FOOT REPORT
   stat = alterlist(reply->cv_proc,proc_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
