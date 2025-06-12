CREATE PROGRAM cv_upd_proc:dba
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
 DECLARE c_proc_status_signed = f8 WITH protect, constant(uar_get_code_by("MEANING",4000341,"SIGNED")
  )
 DECLARE c_step_type_finalreport = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "FINALREPORT"))
 DECLARE c_step_status_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "COMPLETED"))
 DECLARE c_step_status_notstarted = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "NOTSTARTED"))
 DECLARE c_activity_subtype_ecg = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"ECG"))
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request->cv_proc)=0)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","CV_PROC")
  CALL echorecord(request)
  CALL echorecord(reply)
  GO TO exit_script
 ENDIF
 DECLARE proc_cnt = i4 WITH protect, noconstant(size(request->cv_proc,5))
 DECLARE proc_idx = i4 WITH protect
 DECLARE step_cnt = i4 WITH protect
 DECLARE step_idx = i4 WITH protect
 DECLARE normalcy_cd_prev = f8 WITH protect
 DECLARE timezone_txt = vc WITH protect
 DECLARE timezone_index = i4 WITH protect, noconstant(0)
 IF (proc_cnt=0)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","CV_PROC list is empty")
  GO TO exit_script
 ENDIF
 FREE RECORD original_proc_status
 RECORD original_proc_status(
   1 cv_proc[*]
     2 proc_status_cd = f8
 )
 SET stat = alterlist(original_proc_status->cv_proc,proc_cnt)
 FOR (proc_idx = 1 TO proc_cnt)
   SET original_proc_status->cv_proc[proc_idx].proc_status_cd = request->cv_proc[proc_idx].
   proc_status_cd
   SET step_cnt = size(request->cv_proc[proc_idx].cv_step,5)
   SET step_idx = locateval(step_idx,1,step_cnt,c_step_type_finalreport,request->cv_proc[proc_idx].
    cv_step[step_idx].step_type_cd,
    c_step_status_completed,request->cv_proc[proc_idx].cv_step[step_idx].step_status_cd)
   IF (step_idx > 0
    AND (request->cv_proc[proc_idx].cv_step[step_idx].perf_provider_id > 0.0)
    AND (request->cv_proc[proc_idx].prim_physician_id != request->cv_proc[proc_idx].cv_step[step_idx]
   .perf_provider_id))
    SET request->cv_proc[proc_idx].prim_physician_id = request->cv_proc[proc_idx].cv_step[step_idx].
    perf_provider_id
    SET request->cv_proc[proc_idx].modified_ind = 1
   ENDIF
   SELECT INTO "nl:"
    c.normalcy_cd, c.cv_proc_id
    FROM cv_proc c
    WHERE (c.cv_proc_id=request->cv_proc[proc_idx].cv_proc_id)
    DETAIL
     normalcy_cd_prev = c.normalcy_cd
     IF ((normalcy_cd_prev != request->cv_proc[proc_idx].proc_normalcy_cd))
      request->cv_proc[proc_idx].modified_ind = 1
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 EXECUTE cv_calc_proc_status  WITH replace("REQUEST",request), replace("REPLY",reply)
 IF ((reply->status_data.status != "S"))
  CALL cv_log_stat(cv_warning,"EXECUTE",reply->status_data.status,"CV_CALC_PROC_STATUS","")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE ref_letter_records_ind = i2 WITH noconstant(0)
 FOR (proc_idx = 1 TO proc_cnt)
  IF (validate(request->order_action_tz)=0)
   CALL determinetimezone(proc_idx)
  ENDIF
  IF ((c_proc_status_signed=request->cv_proc[proc_idx].proc_status_cd)
   AND (original_proc_status->cv_proc[proc_idx].proc_status_cd != request->cv_proc[proc_idx].
  proc_status_cd))
   IF (ref_letter_records_ind=0)
    SET ref_letter_records_ind = 1
    FREE RECORD add_ref_letter_req
    RECORD add_ref_letter_req(
      1 proc_idx = i4
      1 use_on_off_ind = i2
    )
    SET add_ref_letter_req->use_on_off_ind = 1
    FREE RECORD add_ref_letter_reply
    RECORD add_ref_letter_reply(
      1 status_data
        2 status = c1
        2 subeventstatus[*]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
   ELSE
    CALL initrec(add_ref_letter_reply)
   ENDIF
   SET add_ref_letter_req->proc_idx = proc_idx
   EXECUTE cv_add_ref_letter  WITH replace("REQUEST",add_ref_letter_req), replace("REPLY",
    add_ref_letter_reply)
  ENDIF
 ENDFOR
 FOR (proc_idx = 1 TO proc_cnt)
  SET step_cnt = size(request->cv_proc[proc_idx].cv_step,5)
  FOR (step_idx = 1 TO step_cnt)
   IF ((request->cv_proc[proc_idx].cv_step[step_idx].unmatch_ind=1))
    SET request->order_action_tz = curtimezoneapp
   ENDIF
   IF ((request->cv_proc[proc_idx].activity_subtype_cd=c_activity_subtype_ecg))
    IF ((request->cv_proc[proc_idx].cv_step[step_idx].match_ind=1))
     CALL setdocdetails(proc_idx)
    ELSEIF ((request->cv_proc[proc_idx].cv_step[step_idx].unmatch_ind=1))
     CALL removedocdetails(proc_idx)
    ENDIF
   ENDIF
  ENDFOR
 ENDFOR
 EXECUTE cv_save_procs  WITH replace("REQUEST",request), replace("REPLY",reply)
 IF ((reply->status_data.status != "S"))
  CALL cv_log_stat(cv_warning,"EXECUTE",reply->status_data.status,"CV_SAVE_PROCS","")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE (determinetimezone(proc_idx=i4) =null)
   IF (proc_idx > 0)
    SET step_cnt = size(request->cv_proc[proc_idx].cv_step,5)
    SET step_idx = locateval(step_idx,1,step_cnt,c_step_type_finalreport,request->cv_proc[proc_idx].
     cv_step[step_idx].step_type_cd)
    IF (step_idx > 0)
     SELECT INTO "nl:"
      FROM long_text l
      WHERE (l.parent_entity_id=request->cv_proc[proc_idx].cv_step[step_idx].cv_step_id)
      DETAIL
       timezone_txt = l.long_text, timezone_index = cnvtint(l.long_text)
       IF (timezone_index > 0)
        request->order_action_tz = timezone_index
       ENDIF
      WITH nocounter, separator = " ", format
     ;end select
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (setdocdetails(proc_idx=i4) =null)
  SELECT INTO "nl:"
   FROM cv_step_ref csr,
    cv_step cs
   PLAN (cs
    WHERE (cs.cv_proc_id=request->cv_proc[proc_idx].cv_proc_id))
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd)
   HEAD REPORT
    step_count = 0
   DETAIL
    step_count += 1
    IF (mod(step_count,5)=1)
     stat = alterlist(request->cv_proc[1].cv_step,(step_count+ 2))
    ENDIF
    IF ((request->cv_proc[proc_idx].cv_step[step_count].cv_step_id > 1.0)
     AND (request->cv_proc[proc_idx].cv_step[step_count].step_status_cd != c_step_status_notstarted))
     request->cv_proc[proc_idx].cv_step[step_count].doc_id_str = csr.doc_id_str, request->cv_proc[
     proc_idx].cv_step[step_count].doc_type_cd = csr.doc_type_cd, request->cv_proc[proc_idx].cv_step[
     step_count].doc_template_id = csr.doc_template_id,
     request->cv_proc[proc_idx].cv_step[step_count].modified_ind = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(request->cv_proc[1].cv_step,step_count)
   WITH nocounter
  ;end select
  IF (curqual < 0)
   CALL cv_log_msg(cv_debug,"Doc details are not set in SetDocDetails()")
   CALL echorecord(request)
  ENDIF
 END ;Subroutine
 SUBROUTINE (removedocdetails(proc_idx=i4) =null)
  DECLARE step_index = i4 WITH protect
  FOR (step_index = 1 TO step_cnt)
    IF ((request->cv_proc[proc_idx].cv_step[step_index].step_status_cd=c_step_status_notstarted))
     SET request->cv_proc[proc_idx].cv_step[step_index].doc_id_str = ""
     SET request->cv_proc[proc_idx].cv_step[step_index].doc_type_cd = 0.0
     SET request->cv_proc[proc_idx].cv_step[step_index].doc_template_id = 0.0
     SET request->cv_proc[proc_idx].cv_step[step_index].modified_ind = 1
    ENDIF
  ENDFOR
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL echorecord(request)
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("022 09/05/18 VJ043510")
END GO
