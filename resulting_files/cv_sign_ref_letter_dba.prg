CREATE PROGRAM cv_sign_ref_letter:dba
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
 IF (validate(reply->status_data.status)=0)
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
 ENDIF
 DECLARE g_step_id = f8 WITH protect
 DECLARE g_withlock_flag = i2 WITH protect, noconstant(1)
 DECLARE g_step_status_cd = f8 WITH protect
 DECLARE c_step_type_refletter = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "REFLETTER"))
 DECLARE c_step_status_unsigned = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "UNSIGNED"))
 FREE SET cv_set_step_lock_req
 RECORD cv_set_step_lock_req(
   1 cv_proc_id = f8
   1 cv_step_id = f8
   1 lock_prsnl_id = f8
   1 updt_cnt = i4
   1 withlock_flag = i2
 )
 SELECT INTO "nl:"
  FROM cv_step s,
   cv_step_ref sr
  PLAN (s
   WHERE (s.event_id=request->event_id))
   JOIN (sr
   WHERE sr.task_assay_cd=s.task_assay_cd
    AND sr.step_type_cd=c_step_type_refletter)
  DETAIL
   g_step_id = s.cv_step_id, cv_set_step_lock_req->cv_proc_id = s.cv_proc_id, g_step_status_cd = s
   .step_status_cd,
   cv_set_step_lock_req->updt_cnt = s.updt_cnt
  WITH nocounter
 ;end select
 IF (g_step_id=0.0)
  CALL cv_log_stat(cv_audit,"SELECT","F","CV_STEP",build("EVENT_ID=",request->event_id))
  GO TO exit_script
 ENDIF
 IF (g_step_status_cd != c_step_status_unsigned)
  CALL cv_log_stat(cv_audit,"VALIDATE","F","STEP_STATUS_CD",build(g_step_status_cd,", meaning=",value
    (uar_get_code_meaning(g_step_status_cd))))
  GO TO exit_script
 ENDIF
 SET cv_set_step_lock_req->cv_step_id = g_step_id
 SET cv_set_step_lock_req->lock_prsnl_id = reqinfo->updt_id
 SET cv_set_step_lock_req->withlock_flag = g_withlock_flag
 EXECUTE cv_set_step_lock  WITH replace("REQUEST","CV_SET_STEP_LOCK_REQ"), replace("REPLY",reply)
 IF ((reply->status_data.status != "S"))
  CALL cv_log_stat(cv_warning,"EXECUTE",reply->status_data.status,"CV_SET_STEP_LOCK","")
  CALL echorecord(cv_set_step_lock_req)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 FREE SET ac_sign_note_reply
 RECORD ac_sign_note_reply(
   1 sb_severity = i4
   1 sb_status = i4
   1 sb_statustext = vc
   1 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE auto_corsp_sign_note  WITH replace("REQUEST",request), replace("REPLY","AC_SIGN_NOTE_REPLY")
 IF ((ac_sign_note_reply->status_data.status != "S"))
  CALL cv_log_stat(cv_warning,"EXECUTE",ac_sign_note_reply->status_data.status,"AUTO_CORSP_SIGN_NOTE",
   "")
  CALL echorecord(ac_sign_note_reply)
  CALL echo(ac_sign_note_reply->sb_statustext)
  GO TO exit_script
 ENDIF
 FREE SET cv_set_step_event_req
 RECORD cv_set_step_event_req(
   1 cv_step_id = f8
   1 withlock_flag = i2
 )
 SET cv_set_step_event_req->cv_step_id = g_step_id
 SET cv_set_step_event_req->withlock_flag = g_withlock_flag
 EXECUTE cv_set_step_event  WITH replace("REQUEST","CV_SET_STEP_EVENT_REQ"), replace("REPLY",reply)
 IF ((reply->status_data.status != "S"))
  CALL cv_log_stat(cv_warning,"EXECUTE",reply->status_data.status,"CV_SET_STEP_EVENT","")
  CALL echorecord(cv_set_step_event_req)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 CALL cv_log_msg_post("000 06/07/2006 MH9140")
END GO
