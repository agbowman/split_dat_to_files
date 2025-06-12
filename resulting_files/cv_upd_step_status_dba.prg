CREATE PROGRAM cv_upd_step_status:dba
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
 IF (validate(reply) != 1)
  RECORD reply(
    1 proc_status_cd = f8
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
 FREE RECORD req_proc
 RECORD req_proc(
   1 cv_proc[*]
     2 cv_proc_id = f8
   1 cv_step[*]
     2 cv_step_id = f8
   1 prim_physician_id = f8
   1 phys_group[*]
     2 phys_group_id = f8
   1 proc_status[*]
     2 proc_status_cd = f8
   1 catalog[*]
     2 catalog_cd = f8
   1 action_start_dt_tm = dq8
   1 action_stop_dt_tm = dq8
   1 step_ind = i2
 )
 IF (validate(request) != 1)
  CALL cv_log_message("Empty request")
  SET reply->status_data.subeventstatus[1].operationname = "CV_UPD_STEP_STATUS"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Request is empty"
  GO TO exit_script
 ELSE
  SET stat = alterlist(req_proc->cv_step,1)
  SET req_proc->cv_step[1].cv_step_id = request->cv_step_id
 ENDIF
 FREE RECORD proc
 RECORD proc(
   1 cv_proc[*]
     2 accession = vc
     2 accession_id = f8
     2 action_dt_tm = dq8
     2 catalog_cd = f8
     2 cv_proc_id = f8
     2 encntr_id = f8
     2 group_event_id = f8
     2 order_id = f8
     2 order_physician_id = f8
     2 person_id = f8
     2 phys_group_id = f8
     2 prim_physician_id = f8
     2 priority_cd = f8
     2 proc_status_cd = f8
     2 reason_for_proc = vc
     2 refer_physician_id = f8
     2 sequence = i4
     2 request_dt_tm = dq8
     2 updt_cnt = i4
     2 modified_ind = i2
     2 cv_step[*]
       3 cv_step_id = f8
       3 event_id = f8
       3 sequence = i4
       3 step_status_cd = f8
       3 task_assay_cd = f8
       3 updt_cnt = i4
       3 modified_ind = i2
       3 activity_subtype_cd = f8
       3 doc_id_str = vc
       3 doc_type_cd = f8
       3 proc_status_cd = f8
       3 schedule_ind = i2
       3 step_level_flag = i2
       3 perf_loc_cd = f8
       3 perf_provider_id = f8
       3 perf_start_dt_tm = dq8
       3 perf_stop_dt_tm = dq8
       3 lock_prsnl_id = f8
       3 cv_step_sched[*]
         4 arrive_dt_tm = dq8
         4 arrive_ind = i2
         4 cv_step_sched_id = f8
         4 sched_loc_cd = f8
         4 sched_phys_id = f8
         4 sched_start_dt_tm = dq8
         4 sched_stop_dt_tm = dq8
         4 updt_cnt = i4
         4 modified_ind = i2
       3 step_type_cd = f8
     2 activity_subtype_cd = f8
     2 ed_review_ind = i2
     2 ed_review_status_cd = f8
     2 ed_requestor_prsnl_id = f8
     2 ed_request_dt_tm = dq8
     2 orig_order_dt_tm = dq8
   1 calling_process_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD order_status
 RECORD order_status(
   1 person_id = f8
   1 orders[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 encntr_id = f8
     2 proc_status_cd = f8
     2 communication_type_cd = f8
     2 order_dt_tm = dq8
     2 order_provider_id = f8
 )
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",req_proc), replace("REPLY",proc)
 IF ((proc->status_data.status != "S"))
  CALL cv_log_message("CV_FETCH_PROCS failed")
  SET reply->status_data.subeventstatus[1].operationname = proc->status_data.subeventstatus[1].
  operationname
  SET reply->status_data.subeventstatus[1].operationstatus = proc->status_data.subeventstatus[1].
  operationstatus
  SET reply->status_data.subeventstatus[1].targetobjectname = proc->status_data.subeventstatus[1].
  targetobjectname
  SET reply->status_data.subeventstatus[1].targetobjectvalue = proc->status_data.subeventstatus[1].
  targetobjectvalue
  GO TO exit_script
 ENDIF
 FOR (step_idx = 1 TO size(proc->cv_proc[1].cv_step,5))
   IF ((proc->cv_proc[1].cv_step[step_idx].cv_step_id=request->cv_step_id))
    IF ((proc->cv_proc[1].cv_step[step_idx].step_status_cd=request->step_status_cd))
     CALL cv_log_message("No change in step_status_cd")
     SET reply->status_data.status = "Z"
     GO TO exit_script
    ELSE
     SET proc->cv_proc[1].cv_step[step_idx].step_status_cd = request->step_status_cd
     EXECUTE cv_save_procs  WITH replace("REQUEST",proc)
     IF ((reply->status_data.status != "S"))
      CALL cv_log_message("CV_SAVE_PROCS failed")
      GO TO exit_script
     ENDIF
    ENDIF
    SET step_idx = size(proc->cv_proc[1].cv_step,5)
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_message("CV_UPD_STEP_STATUS failed")
  CALL echorecord(proc)
  SET reqinfo->commit_ind = 0
 ELSE
  IF (currdbname="DTEST")
   CALL cv_log_message("CV_UPD_STEP_STATUS was successful")
   CALL echorecord(proc)
  ENDIF
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
 SET cv_upd_step_status_vrsn = "09/18/08 AR012547"
END GO
