CREATE PROGRAM cv_upd_proc_status:dba
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
 IF (validate(reply)=0)
  RECORD reply(
    1 proc_status_cd = f8
    1 proc_status_disp = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE start_proc_status_cd = f8 WITH noconstant(0.0)
 DECLARE g_proc_status_cd = f8 WITH noconstant(0.0)
 DECLARE scheduled_ind = i2 WITH noconstant(0)
 DECLARE stat_notstarted = f8 WITH noconstant(uar_get_code_by("MEANING",4000341,"NOTSTARTED"))
 DECLARE stat_ordered = f8 WITH noconstant(uar_get_code_by("MEANING",4000341,"ORDERED"))
 DECLARE stat_scheduled = f8 WITH noconstant(uar_get_code_by("MEANING",4000341,"SCHEDULED"))
 DECLARE stat_arrived = f8 WITH noconstant(uar_get_code_by("MEANING",4000341,"ARRIVED"))
 DECLARE stat_inprocess = f8 WITH noconstant(uar_get_code_by("MEANING",4000341,"INPROCESS"))
 DECLARE stat_completed = f8 WITH noconstant(uar_get_code_by("MEANING",4000341,"COMPLETED"))
 DECLARE stat_discontinued = f8 WITH noconstant(uar_get_code_by("MEANING",4000341,"DISCONTINUED"))
 DECLARE stat_cancelled = f8 WITH noconstant(uar_get_code_by("MEANING",4000341,"CANCELLED"))
 DECLARE stat_onhold = f8 WITH noconstant(uar_get_code_by("MEANING",4000341,"ONHOLD"))
 DECLARE steps_status_flag = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  collate = cv.collation_seq
  FROM cv_proc p,
   cv_step s,
   cv_step_ref sr,
   cv_step_sched ss,
   code_value cv
  PLAN (p
   WHERE (p.cv_proc_id=request->cv_proc_id))
   JOIN (s
   WHERE s.cv_proc_id=p.cv_proc_id)
   JOIN (sr
   WHERE sr.task_assay_cd=s.task_assay_cd
    AND sr.proc_status_cd > 0.0)
   JOIN (cv
   WHERE cv.code_value=sr.proc_status_cd)
   JOIN (ss
   WHERE ss.task_assay_cd=outerjoin(s.task_assay_cd)
    AND ss.cv_proc_id=outerjoin(s.cv_proc_id))
  ORDER BY collate
  HEAD REPORT
   status_incomplete = 0, start_proc_status_cd = p.proc_status_cd, discontinued_ind = 0,
   cancelled_ind = 0, onhold_ind = 0, started_ind = 0
  HEAD collate
   step_incomplete = status_incomplete
  DETAIL
   CALL echo(build("Processing:",s.cv_step_id,uar_get_code_meaning(s.step_status_cd),
    uar_get_code_meaning(sr.proc_status_cd))),
   CALL echo(build("Pre--Detail:",status_incomplete,", step:",step_incomplete))
   IF (ss.sched_start_dt_tm != null)
    scheduled_ind = 1
   ENDIF
   CASE (s.step_status_cd)
    OF stat_discontinued:
     discontinued_ind = 1
    OF stat_cancelled:
     cancelled_ind = 1
    OF stat_onhold:
     onhold_ind = 1
    OF stat_completed:
    OF stat_inprocess:
     started_ind = 1
   ENDCASE
   IF (s.step_status_cd != stat_completed)
    IF (status_incomplete=0)
     IF (sr.proc_status_cd=stat_completed)
      IF (s.step_status_cd=stat_inprocess)
       g_proc_status_cd = stat_inprocess,
       CALL echo("setting INPROCESS")
      ELSEIF (s.step_status_cd=stat_notstarted
       AND g_proc_status_cd != stat_inprocess
       AND ss.arrive_ind=1)
       g_proc_status_cd = stat_arrived,
       CALL echo("setting ARRIVED")
      ENDIF
     ENDIF
    ENDIF
    step_incomplete = 1
   ENDIF
   CALL echo(build("Post detail--Status:",status_incomplete,", step:",step_incomplete))
  FOOT  collate
   IF (step_incomplete=1)
    status_incomplete = 1
   ELSEIF (status_incomplete=0)
    g_proc_status_cd = sr.proc_status_cd,
    CALL echo("Post collate, setting",uar_get_code_meaning(g_proc_status_cd))
   ENDIF
  FOOT REPORT
   IF (((discontinued_ind=1) OR (cancelled_ind=1
    AND started_ind=1)) )
    g_proc_status_cd = stat_discontinued
   ELSEIF (cancelled_ind=1)
    g_proc_status_cd = stat_cancelled
   ELSEIF (onhold_ind=1)
    g_proc_status_cd = stat_onhold
   ENDIF
   IF (g_proc_status_cd=0.0)
    IF (scheduled_ind=1)
     g_proc_status_cd = stat_scheduled
    ELSE
     g_proc_status_cd = stat_ordered
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (g_proc_status_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "DETERMINE NEW STATUS"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_PROC"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "proc_status_cd determination failed"
  GO TO exit_script
 ENDIF
 IF (start_proc_status_cd != g_proc_status_cd)
  UPDATE  FROM cv_proc p
   SET p.proc_status_cd = g_proc_status_cd, p.updt_task = reqinfo->updt_task, p.updt_id = reqinfo->
    updt_id,
    p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt
     = (p.updt_cnt+ 1)
   WHERE (cv_proc_id=request->cv_proc_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL cv_chk_err("UPDATE","F","CV_PROC")
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->proc_status_cd = g_proc_status_cd
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
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
