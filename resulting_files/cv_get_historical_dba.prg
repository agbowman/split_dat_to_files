CREATE PROGRAM cv_get_historical:dba
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
 DECLARE doc_type_powernote = f8 WITH constant(uar_get_code_by("MEANING",4000360,"POWERNOTE")),
 protect
 DECLARE proc_status_signed = f8 WITH constant(uar_get_code_by("MEANING",4000341,"SIGNED")), protect
 DECLARE step_status_completed = f8 WITH constant(uar_get_code_by("MEANING",4000440,"COMPLETED")),
 protect
 DECLARE proc_cnt = i4 WITH protect
 DECLARE proc_idx = i4 WITH protect
 DECLARE index = i4 WITH protect
 IF (validate(reply) != 1)
  RECORD reply(
    1 cv_proc[*]
      2 cv_proc_id = f8
      2 encntr_id = f8
      2 order_id = f8
      2 action_dt_tm = dq8
      2 proc_status_cd = f8
      2 proc_status_disp = vc
      2 catalog_cd = f8
      2 catalog_disp = vc
      2 signed_event_id = f8
      2 created_study_uid = c64
      2 study_uid = c64
      2 study_state_cd = f8
      2 study_state_disp = vc
      2 study_state_mean = c12
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD uid_rep
 RECORD uid_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "NL:"
  FROM cv_proc cp
  WHERE (cp.person_id=request->person_id)
  ORDER BY cp.action_dt_tm DESC
  HEAD REPORT
   stat = alterlist(reply->cv_proc,10), proc_cnt = 0
  DETAIL
   proc_cnt += 1
   IF (mod(proc_cnt,10)=1
    AND proc_cnt != 1)
    stat = alterlist(reply->cv_proc,(proc_cnt+ 9))
   ENDIF
   reply->cv_proc[proc_cnt].cv_proc_id = cp.cv_proc_id, reply->cv_proc[proc_cnt].encntr_id = cp
   .encntr_id, reply->cv_proc[proc_cnt].order_id = cp.order_id,
   reply->cv_proc[proc_cnt].action_dt_tm = cp.action_dt_tm, reply->cv_proc[proc_cnt].proc_status_cd
    = cp.proc_status_cd, reply->cv_proc[proc_cnt].catalog_cd = cp.catalog_cd
  FOOT REPORT
   stat = alterlist(reply->cv_proc,proc_cnt)
  WITH nocounter
 ;end select
 IF (proc_cnt=0)
  CALL cv_log_stat(cv_warning,"SELECT","Z","CV_PROC","")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM cv_step cs,
   cv_step_ref csr
  PLAN (cs
   WHERE expand(proc_idx,1,proc_cnt,cs.cv_proc_id,reply->cv_proc[proc_idx].cv_proc_id)
    AND cs.step_status_cd=step_status_completed)
   JOIN (csr
   WHERE csr.proc_status_cd=proc_status_signed
    AND csr.doc_type_cd=doc_type_powernote
    AND cs.task_assay_cd=csr.task_assay_cd)
  ORDER BY cs.cv_proc_id, cs.sequence DESC
  HEAD cs.cv_proc_id
   index = locateval(proc_idx,1,proc_cnt,cs.cv_proc_id,reply->cv_proc[proc_idx].cv_proc_id)
   WHILE (index != 0)
    reply->cv_proc[index].signed_event_id = cs.event_id,index = locateval(proc_idx,(index+ 1),
     proc_cnt,cs.cv_proc_id,reply->cv_proc[proc_idx].cv_proc_id)
   ENDWHILE
  WITH nocounter
 ;end select
 EXECUTE cv_get_study_uid  WITH replace("REPLY","UID_REP"), replace("REQUEST","REPLY")
 SET reply->status_data.status = "S"
#exit_script
 CALL cv_log_msg_post("MOD 004 10/10/05   MH9140")
END GO
