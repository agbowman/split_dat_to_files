CREATE PROGRAM cv_add_proc:dba
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
 DECLARE g_status_notstarted = f8 WITH noconstant(0.0)
 DECLARE g_status_ordered = f8 WITH noconstant(0.0)
 SET g_status_notstarted = uar_get_code_by("MEANING",4000440,"NOTSTARTED")
 SET g_status_ordered = uar_get_code_by("MEANING",4000341,"ORDERED")
 IF (validate(reply)=0)
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
 FREE RECORD proc
 RECORD proc(
   1 cv_proc_id = f8
   1 step[*]
     2 task_assay_cd = f8
     2 step_level_flag = i2
     2 schedule_ind = i2
     2 cv_step_sched_id = f8
     2 cv_step_id = f8
     2 cv_doc_id_str = vc
     2 cv_doc_template_id = f8
     2 cv_doc_type_cd = f8
 )
 DECLARE step_cnt = i4 WITH noconstant(0)
 DECLARE sched_cnt = i4 WITH noconstant(0)
 DECLARE step_idx = i4 WITH noconstant(0)
 CALL echorecord(request,"cer_temp:cv_addproc_req.txt")
 IF (currdbname="DTEST")
  IF ((request->catalog_cd=6937768.00))
   SET sched_cnt = 1
   SET step_cnt = 3
   SET stat = alterlist(proc->step,step_cnt)
   SET proc->step[1].task_assay_cd = uar_get_code_by("MEANING",14003,"CV_USPROC")
   SET proc->step[2].task_assay_cd = uar_get_code_by("MEANING",14003,"CV_USTDOC")
   SET proc->step[3].task_assay_cd = uar_get_code_by("MEANING",14003,"CV_USPDOC")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = 3),
     cv_step_ref sr
    PLAN (d)
     JOIN (sr
     WHERE (sr.task_assay_cd=proc->step[d.seq].task_assay_cd))
    DETAIL
     proc->step[d.seq].schedule_ind = sr.schedule_ind
    WITH nocounter
   ;end select
  ELSEIF ((request->catalog_cd=2161859165.00))
   SET sched_cnt = 1
   SET step_cnt = 3
   SET stat = alterlist(proc->step,step_cnt)
   SET proc->step[1].task_assay_cd = uar_get_code_by("MEANING",14003,"CV_TTEPROC")
   SET proc->step[2].task_assay_cd = uar_get_code_by("MEANING",14003,"CV_TTETDOC")
   SET proc->step[3].task_assay_cd = uar_get_code_by("MEANING",14003,"CV_TTEPDOC")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = 3),
     cv_step_ref sr
    PLAN (d)
     JOIN (sr
     WHERE (sr.task_assay_cd=proc->step[d.seq].task_assay_cd))
    DETAIL
     proc->step[d.seq].schedule_ind = sr.schedule_ind, proc->step[d.seq].cv_doc_id_str = sr
     .doc_id_str, proc->step[d.seq].cv_doc_template_id = sr.doc_template_id,
     proc->step[d.seq].cv_doc_type_cd = sr.doc_type_cd
    WITH nocounter
   ;end select
  ELSE
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   sr.schedule_ind, ptr.task_assay_cd
   FROM profile_task_r ptr,
    cv_step_ref sr
   PLAN (ptr
    WHERE (ptr.catalog_cd=request->catalog_cd)
     AND ptr.active_ind=1)
    JOIN (sr
    WHERE sr.task_assay_cd=ptr.task_assay_cd)
   ORDER BY ptr.sequence
   HEAD REPORT
    step_cnt = 0
   DETAIL
    step_cnt = (step_cnt+ 1), stat = alterlist(proc->step,step_cnt), proc->step[step_cnt].
    task_assay_cd = ptr.task_assay_cd,
    proc->step[step_cnt].schedule_ind = sr.schedule_ind, sched_cnt = (sched_cnt+ sr.schedule_ind),
    proc->step[step_cnt].cv_doc_id_str = sr.doc_id_str,
    proc->step[step_cnt].cv_doc_template_id = sr.doc_template_id, proc->step[step_cnt].cv_doc_type_cd
     = sr.doc_type_cd
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[1].operationname = "CV Step Selection"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "profile_task_r"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "No task_assays match cv_step_ref entries"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  seqnum = seq(card_vas_seq,nextval)
  FROM dual d
  DETAIL
   proc->cv_proc_id = seqnum
  WITH nocounter
 ;end select
 FOR (step_idx = 1 TO step_cnt)
   SELECT INTO "nl:"
    seqnum = seq(card_vas_seq,nextval)
    FROM dual d
    DETAIL
     proc->step[step_idx].cv_step_id = seqnum
    WITH nocounter
   ;end select
 ENDFOR
 CALL echorecord(proc)
 INSERT  FROM cv_proc p
  SET p.cv_proc_id = proc->cv_proc_id, p.catalog_cd = request->catalog_cd, p.order_id = request->
   order_id,
   p.proc_status_cd = g_status_ordered, p.priority_cd = request->priority_cd, p.order_physician_id =
   request->order_physician_id,
   p.prim_physician_id = request->order_physician_id, p.accession = request->accession, p
   .accession_id = request->accession_id,
   p.person_id = request->person_id, p.encntr_id = request->encntr_id, p.updt_task = reqinfo->
   updt_task,
   p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   p.updt_cnt = 0
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL cv_chk_err("INSERT","F","CV_PROC")
 ENDIF
 INSERT  FROM cv_step s,
   (dummyt d  WITH seq = step_cnt)
  SET s.cv_proc_id = proc->cv_proc_id, s.task_assay_cd = proc->step[d.seq].task_assay_cd, s
   .cv_step_id = proc->step[d.seq].cv_step_id,
   s.step_status_cd = g_status_notstarted, s.sequence = d.seq, s.cv_doc_id_str = proc->step[d.seq].
   cv_doc_id_str,
   s.cv_doc_template_id = proc->step[d.seq].cv_doc_template_id, s.cv_doc_type_cd = proc->step[d.seq].
   cv_doc_type_cd, s.updt_task = reqinfo->updt_task,
   s.updt_id = reqinfo->updt_id, s.updt_applctx = reqinfo->updt_applctx, s.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   s.updt_cnt = 0
  PLAN (d)
   JOIN (s)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL cv_chk_err("INSERT","F","CV_STEP")
 ENDIF
 IF (sched_cnt > 0)
  INSERT  FROM cv_step_sched ss,
    (dummyt d  WITH seq = step_cnt)
   SET ss.cv_step_sched_id = seq(card_vas_seq,nextval), ss.cv_step_id = proc->step[d.seq].cv_step_id,
    ss.cv_proc_id = proc->cv_proc_id,
    ss.task_assay_cd = proc->step[d.seq].task_assay_cd, ss.arrive_ind = 0, ss.updt_task = reqinfo->
    updt_task,
    ss.updt_id = reqinfo->updt_id, ss.updt_applctx = reqinfo->updt_applctx, ss.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    ss.updt_cnt = 0
   PLAN (d
    WHERE (proc->step[d.seq].schedule_ind=1))
    JOIN (ss)
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL cv_chk_err("INSERT","F","CV_STEP_SCHED")
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echo(build("cv_proc_id=",proc->cv_proc_id))
#exit_script
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
 CALL echorecord(reply,"cer_temp:cv_addproc_rep.txt")
 SET cv_add_proc_version = "MOD 001 12/13/16 MG023115"
END GO
