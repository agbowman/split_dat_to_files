CREATE PROGRAM cv_get_proc_data:dba
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
     cnvtdatetime(sysdate),"HHMMSS;;q"),".dat"))
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
  SET cv_log_handle_cnt += 1
 ENDIF
 SUBROUTINE (cv_log_createhandle(dummy=i2) =null)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 SUBROUTINE (cv_log_current_default(dummy=i2) =null)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 SUBROUTINE (cv_echo(string=vc) =null)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_message(log_message_param=vc) =null)
   SET cv_log_err_num += 1
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
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
 SUBROUTINE (cv_log_message_status(object_name_param=vc,operation_status_param=c1,
  operation_name_param=vc,target_object_value_param=vc) =null)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event += 1
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event += 1
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_check_err(opname=vc,opstatus=c1,targetname=vc) =null)
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
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(sysdate),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 procs[*]
      2 cv_proc_id = f8
      2 person_id = f8
      2 encntr_id = f8
      2 event_id = f8
      2 person_fname = vc
      2 person_lname = vc
      2 person_mname = vc
      2 procedure_dt_tm = dq8
      2 proc_status_cd = f8
      2 proc_status_disp = vc
      2 priority_cd = f8
      2 priority_disp = vc
      2 sequence = i4
      2 catalog_cd = f8
      2 catalog_disp = vc
      2 sex_cd = f8
      2 sex_disp = vc
      2 order_physician_id = f8
      2 refer_physician_id = f8
      2 prim_physician_id = f8
      2 reason_for_proc = vc
      2 order_id = f8
      2 order_detail_display_line = vc
      2 steps[*]
        3 cv_step_id = f8
        3 task_assay_cd = f8
        3 task_assay_disp = vc
        3 event_id = f8
        3 step_status_cd = f8
        3 step_status_disp = vc
        3 doc_type_cd = f8
        3 doc_type_disp = vc
        3 doc_id_str = vc
        3 doc_template_id = f8
        3 activity_subtype_cd = f8
        3 activity_subtype_disp = vc
        3 activity_subtype_mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  CALL cv_log_message("Reply record already defined.")
  CALL echorecord(reply)
 ENDIF
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE num1 = i4 WITH public, noconstant(0)
 DECLARE num2 = i4 WITH public, noconstant(0)
 DECLARE index = i4 WITH public, noconstant(0)
 DECLARE failure = c1 WITH public, noconstant("T")
 DECLARE req_size = i4 WITH public, noconstant(size(request->cv_proc,5))
 DECLARE rep_size = i4 WITH public, noconstant(0)
 SET stat = alterlist(reply->procs,req_size)
 IF (req_size=0)
  CALL cv_log_message("Request record is empty. Nothing to do.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM cv_proc cp,
   person p,
   orders o
  PLAN (cp
   WHERE expand(num,1,req_size,cp.cv_proc_id,request->cv_proc[num].cv_proc_id))
   JOIN (p
   WHERE p.person_id=cp.person_id)
   JOIN (o
   WHERE o.order_id=cp.order_id)
  HEAD REPORT
   num1 = 0
  DETAIL
   num1 += 1, reply->procs[num1].cv_proc_id = cp.cv_proc_id, reply->procs[num1].person_id = cp
   .person_id,
   reply->procs[num1].encntr_id = cp.encntr_id, reply->procs[num1].event_id = cp.group_event_id,
   reply->procs[num1].person_fname = p.name_first,
   reply->procs[num1].person_lname = p.name_last, reply->procs[num1].person_mname = p.name_middle,
   reply->procs[num1].proc_status_cd = cp.proc_status_cd,
   reply->procs[num1].priority_cd = cp.priority_cd, reply->procs[num1].sequence = cp.sequence, reply
   ->procs[num1].order_physician_id = cp.order_physician_id,
   reply->procs[num1].refer_physician_id = cp.refer_physician_id, reply->procs[num1].
   prim_physician_id = cp.prim_physician_id, reply->procs[num1].reason_for_proc = cp.reason_for_proc,
   reply->procs[num1].order_id = cp.order_id, reply->procs[num1].catalog_cd = cp.catalog_cd, reply->
   procs[num1].sex_cd = p.sex_cd,
   reply->procs[num1].order_detail_display_line = o.order_detail_display_line
  FOOT REPORT
   stat = alterlist(reply->procs,num1)
  WITH nocounter
 ;end select
 SET rep_size = num1
 IF (rep_size=0)
  CALL cv_log_message("Couldn't find any of the listed proc. Aborting.")
  GO TO exit_script
 ENDIF
 IF ((request->step_ind=1))
  SELECT INTO "nl:"
   FROM cv_step cs,
    cv_step_ref sr
   PLAN (cs
    WHERE expand(num,1,rep_size,cs.cv_proc_id,reply->procs[num].cv_proc_id))
    JOIN (sr
    WHERE sr.task_assay_cd=cs.task_assay_cd)
   ORDER BY cs.cv_proc_id, cs.cv_step_id
   HEAD REPORT
    num1 = 0, index = 0
   HEAD cs.cv_proc_id
    num2 = 0, index = locateval(num1,1,rep_size,cs.cv_proc_id,reply->procs[num1].cv_proc_id)
   DETAIL
    num2 += 1
    IF (mod(num2,10)=1)
     stat = alterlist(reply->procs[index].steps,(num2+ 9))
    ENDIF
    reply->procs[index].steps[num2].cv_step_id = cs.cv_step_id, reply->procs[index].steps[num2].
    task_assay_cd = cs.task_assay_cd, reply->procs[index].steps[num2].event_id = cs.event_id,
    reply->procs[index].steps[num2].step_status_cd = cs.step_status_cd, reply->procs[index].steps[
    num2].doc_type_cd = sr.doc_type_cd, reply->procs[index].steps[num2].doc_id_str = sr.doc_id_str,
    reply->procs[index].steps[num2].activity_subtype_cd = sr.activity_subtype_cd
   FOOT  cs.cv_proc_id
    stat = alterlist(reply->procs[index].steps,num2)
   WITH nocounter
  ;end select
 ELSE
  CALL cv_log_message("Steps in reply not requested.")
 ENDIF
 SET failure = "F"
#exit_script
 IF (failure="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  CALL echorecord(reply)
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(sysdate),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE (cv_log_destroyhandle(dummy=i2) =null)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt -= 1
   ENDIF
 END ;Subroutine
 SET script_version = "MOD 001 07/11/17 VJ043510"
END GO
