CREATE PROGRAM cv_new_steps:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 IF (validate(reply->status_data.status) != 1)
  FREE SET reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  CALL cv_log_msg(cv_info,"Reply already defined")
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(proc_list->cv_proc) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","PROC_LIST","CV_PROC")
  GO TO exit_script
 ENDIF
 DECLARE c_block_size = i4 WITH protect, constant(20)
 DECLARE c_step_type_refletter = f8 WITH protect, noconstant(uar_get_code_by("MEANING",4001923,
   "REFLETTER"))
 DECLARE req_proc_idx = i4 WITH protect, noconstant(validate(request->proc_idx,1))
 DECLARE req_task_assay_cd = f8 WITH protect, noconstant(validate(request->task_assay_cd,0.0))
 DECLARE proc_cnt = i4 WITH protect, noconstant(size(proc_list->cv_proc,5))
 IF (proc_cnt <= 0)
  CALL cv_log_stat(cv_warning,"SIZE","F","PROC_LIST->CV_PROC",build(proc_cnt))
  GO TO exit_script
 ELSEIF (proc_cnt=1)
  IF (req_proc_idx=0)
   CALL cv_log_msg(cv_info,"Setting req_proc_idx to 1")
   SET req_proc_idx = 1
  ENDIF
 ELSEIF (req_proc_idx=0)
  CALL cv_log_stat(cv_warning,"REQUEST","F","PROC_IDX",
   "REQUEST->PROC_IDX > 0 required when size(proc_list,5) > 1")
  GO TO exit_script
 ENDIF
 DECLARE req_step_cnt = i4 WITH protect
 IF (validate(request->cv_step[1].task_assay_cd)=1)
  SET req_step_cnt = size(request->cv_step,5)
 ENDIF
 IF (validate(step_stat_notstarted)=0)
  DECLARE step_stat_notstarted = f8 WITH constant(uar_get_code_by("MEANING",4000440,"NOTSTARTED")),
  protect
 ENDIF
 DECLARE step_cnt = i4 WITH protect, noconstant(0)
 SELECT
  IF (req_step_cnt > 0)
   FROM (dummyt d  WITH seq = req_step_cnt),
    cv_step_ref sr
   PLAN (d
    WHERE (request->cv_step[d.seq].task_assay_cd > 0.0))
    JOIN (sr
    WHERE (sr.task_assay_cd=request->cv_step[d.seq].task_assay_cd))
   ORDER BY d.seq
  ELSE
  ENDIF
  INTO "nl:"
  FROM profile_task_r ptr,
   cv_step_ref sr,
   discrete_task_assay dta
  PLAN (ptr)
   JOIN (sr
   WHERE sr.task_assay_cd=ptr.task_assay_cd)
   JOIN (dta
   WHERE sr.task_assay_cd=dta.task_assay_cd
    AND (ptr.catalog_cd=proc_list->cv_proc[req_proc_idx].catalog_cd)
    AND ptr.active_ind=1
    AND ptr.beg_effective_dt_tm != null
    AND ptr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ptr.end_effective_dt_tm != null
    AND ptr.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND sr.step_type_cd != c_step_type_refletter
    AND dta.active_ind=1
    AND dta.beg_effective_dt_tm != null
    AND dta.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND dta.end_effective_dt_tm != null
    AND dta.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY ptr.sequence
  HEAD REPORT
   step_cnt = size(proc_list->cv_proc[req_proc_idx].cv_step,5)
  DETAIL
   step_cnt += 1, stat = alterlist(proc_list->cv_proc[req_proc_idx].cv_step,step_cnt), proc_list->
   cv_proc[req_proc_idx].cv_step[step_cnt].task_assay_cd = sr.task_assay_cd,
   proc_list->cv_proc[req_proc_idx].cv_step[step_cnt].modified_ind = 1, proc_list->cv_proc[
   req_proc_idx].cv_step[step_cnt].doc_id_str = sr.doc_id_str, proc_list->cv_proc[req_proc_idx].
   cv_step[step_cnt].doc_type_cd = sr.doc_type_cd,
   proc_list->cv_proc[req_proc_idx].cv_step[step_cnt].proc_status_cd = sr.proc_status_cd, proc_list->
   cv_proc[req_proc_idx].cv_step[step_cnt].schedule_ind = sr.schedule_ind, proc_list->cv_proc[
   req_proc_idx].cv_step[step_cnt].sequence = step_cnt,
   proc_list->cv_proc[req_proc_idx].cv_step[step_cnt].step_status_cd = step_stat_notstarted,
   proc_list->cv_proc[req_proc_idx].cv_step[step_cnt].step_level_flag = sr.step_level_flag, proc_list
   ->cv_proc[req_proc_idx].cv_step[step_cnt].step_type_cd = sr.step_type_cd,
   proc_list->cv_proc[req_proc_idx].cv_step[step_cnt].doc_template_id = sr.doc_template_id
   IF (sr.schedule_ind=1)
    stat = alterlist(proc_list->cv_proc[req_proc_idx].cv_step[step_cnt].cv_step_sched,1), proc_list->
    cv_proc[req_proc_idx].cv_step[step_cnt].cv_step_sched[1].modified_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_stat(cv_audit,"SELECT","Z","PROFILE_TASK_R","")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_info,"No steps matched")
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_NEW_STEPS failed")
  CALL echorecord(proc_list)
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("015 09/05/18 VJ043510")
END GO
