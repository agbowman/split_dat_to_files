CREATE PROGRAM cv_set_step_lock:dba
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
 SET modify = predeclare
 IF (validate(reply) != 1)
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
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_msg(cv_error,"Incorrect reply for program. Exiting")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE g_withlock_flag = i2 WITH protect, noconstant(- (1))
 DECLARE prev_updt_cnt = i4 WITH protect, noconstant(- (1))
 DECLARE prev_lock_prsnl_id = f8 WITH protect, noconstant(- (1.0))
 IF (validate(request->withlock_flag,1) != 2)
  SET g_withlock_flag = 1
 ELSE
  SET g_withlock_flag = 2
 ENDIF
 IF (validate(request->cv_proc_id,0.0)=0.0)
  CALL cv_log_stat(cv_audit,"VALIDATE","F","REQUEST","CV_PROC_ID")
  GO TO exit_script
 ENDIF
 IF ((validate(request->updt_cnt,- (1))=- (1)))
  CALL cv_log_stat(cv_audit,"VALIDATE","F","REQUEST","UPDT_CNT")
  GO TO exit_script
 ENDIF
 IF (validate(request->cv_step_id,0.0)=0.0)
  CALL cv_log_stat(cv_audit,"VALIDATE","F","REQUEST","CV_STEP_ID")
  GO TO exit_script
 ENDIF
 IF (g_withlock_flag=1)
  SELECT INTO "nl:"
   FROM cv_proc cp
   WHERE (cp.cv_proc_id=request->cv_proc_id)
   WITH nocounter, forupdate(cp)
  ;end select
 ELSEIF (g_withlock_flag=2)
  SELECT INTO "nl:"
   FROM cv_proc cp
   WHERE (cp.cv_proc_id=request->cv_proc_id)
   WITH nocounter, forupdatewait(cp)
  ;end select
 ENDIF
 IF (curqual=0)
  CALL cv_log_stat(cv_info,"SELECT","Z","CV_PROC","")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM cv_step cs,
   cv_step_ref sr
  PLAN (cs
   WHERE (cs.cv_step_id=request->cv_step_id)
    AND ((cs.cv_proc_id+ 0.0)=request->cv_proc_id))
   JOIN (sr
   WHERE sr.task_assay_cd=cs.task_assay_cd)
  DETAIL
   prev_lock_prsnl_id = cs.lock_prsnl_id, prev_updt_cnt = cs.updt_cnt
  WITH nocounter
 ;end select
 DECLARE g_exit_now_ind = i2 WITH protect
 IF ((request->updt_cnt != prev_updt_cnt))
  CALL cv_log_stat(cv_info,"SELECT","F","CV_STEP",build("UPDT_CNT=",prev_updt_cnt))
  SET g_exit_now_ind = 1
 ENDIF
 IF (prev_lock_prsnl_id != 0.0)
  DECLARE g_lock_prsnl_name = vc WITH protect
  CALL cv_log_stat(cv_info,"SELECT","F","CV_STEP",build("LOCK_PRSNL_ID=",prev_lock_prsnl_id))
  SELECT INTO "nl:"
   FROM person p
   WHERE p.person_id=prev_lock_prsnl_id
   DETAIL
    g_lock_prsnl_name = p.name_full_formatted
   WITH nocounter
  ;end select
  CALL cv_log_stat(cv_info,"SELECT","F","CV_STEP",build("LOCK_PRSNL_NAME=",g_lock_prsnl_name))
  GO TO exit_script
 ENDIF
 IF (g_exit_now_ind=1)
  GO TO exit_script
 ENDIF
 UPDATE  FROM cv_step cs
  SET cs.lock_prsnl_id = request->lock_prsnl_id, cs.updt_cnt = (prev_updt_cnt+ 1), cs.updt_applctx =
   reqinfo->updt_applctx,
   cs.updt_dt_tm = cnvtdatetime(sysdate), cs.updt_id = reqinfo->updt_id, cs.updt_task = reqinfo->
   updt_task
  WHERE (cs.cv_step_id=request->cv_step_id)
  WITH nocounter
 ;end update
 IF (curqual != 0)
  CALL cv_log_stat(cv_info,"UPDATE","S","CV_STEP",build("LOCK_PRSNL_ID=",request->lock_prsnl_id))
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_info,"CV_SET_STEP_LOCK failed!")
  SET reqinfo->commit_ind = 0
  CALL echorecord(reply)
  CALL echorecord(request)
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET modify = nopredeclare
 CALL cv_log_msg_post("002 12/10/08 SM013833")
END GO
