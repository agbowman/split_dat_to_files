CREATE PROGRAM cv_set_step_perform:dba
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
 IF (validate(location_rep)=0)
  RECORD location_rep(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 performing_loc[*]
      2 perf_loc_cd = f8
  )
 ENDIF
 FREE RECORD step_req
 RECORD step_req(
   1 cv_step[*]
     2 cv_step_id = f8
     2 event_id = f8
     2 step_status_cd = f8
     2 updt_cnt = i4
     2 perf_loc_cd = f8
     2 perf_provider_id = f8
     2 perf_start_dt_tm = dq8
     2 perf_stop_dt_tm = dq8
     2 proc_normalcy_cd = f8
     2 edit_doc_flag = i2
     2 action_tz = i4
 )
 FREE RECORD location_req
 RECORD location_req(
   1 device_name = vc
   1 user_id = f8
 )
 DECLARE g_cv_login_id = f8 WITH public, constant(request->cv_login_id)
 DECLARE g_external_perf_provider_id = f8 WITH public, constant(request->perf_provider_id)
 DECLARE edit_doc_step_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE req_edit_doc_flag = i2 WITH public, noconstant(0)
 DECLARE g_external_report_state = vc WITH public, constant(request->report_state)
 DECLARE external_provider_available = i2 WITH protect, noconstant(0)
 DECLARE finalreport_var = f8 WITH constant(uar_get_code_by("MEANING",4001923,"FINALREPORT")),
 protect
 DECLARE completed_var = f8 WITH constant(uar_get_code_by("MEANING",4000440,"COMPLETED")), protect
 DECLARE step_activity_subtype_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"ECG"))
 IF (validate(null_f8,0.0)=0.0)
  DECLARE null_f8 = f8 WITH constant(- (0.00001))
 ENDIF
 SET edit_doc_step_status_cd = 0.0
 SELECT INTO "nl:"
  FROM cv_step s
  WHERE (s.cv_step_id=request->cv_step_id)
  DETAIL
   edit_doc_step_status_cd = s.step_status_cd
  WITH nocounter
 ;end select
 IF (edit_doc_step_status_cd=completed_var
  AND (request->step_status_cd=completed_var)
  AND (request->cv_step_type_cd=finalreport_var)
  AND (request->cv_activity_type_cd=step_activity_subtype_cd))
  SET req_edit_doc_flag = 1
 ENDIF
 IF (g_cv_login_id=0.0
  AND g_external_perf_provider_id > 0.0)
  SELECT INTO "nl:"
   FROM cv_step c,
    cv_step_ref cs,
    cv_proc cp
   PLAN (cp)
    JOIN (c
    WHERE c.cv_proc_id=cp.cv_proc_id
     AND (c.cv_step_id=request->cv_step_id))
    JOIN (cs
    WHERE cs.task_assay_cd=c.task_assay_cd
     AND cs.step_type_cd=finalreport_var)
   WITH nocounter, separator = " ", format
  ;end select
  IF (curqual > 0)
   SET location_req->user_id = g_external_perf_provider_id
   SET location_req->device_name = ""
   EXECUTE cv_fetch_locations  WITH replace("REQUEST",location_req), replace("REPLY",location_rep)
   CALL echorecord(location_rep)
   IF ((location_rep->status_data.status="S"))
    SET external_provider_available = 1
   ELSE
    SET external_provider_available = 0
   ENDIF
  ENDIF
 ENDIF
 SET stat = alterlist(step_req->cv_step,1)
 SET step_req->cv_step[1].cv_step_id = request->cv_step_id
 SET step_req->cv_step[1].updt_cnt = request->updt_cnt
 SET step_req->cv_step[1].step_status_cd = request->step_status_cd
 SET step_req->cv_step[1].edit_doc_flag = req_edit_doc_flag
 IF (external_provider_available=1)
  SET step_req->cv_step[1].perf_loc_cd = location_rep->performing_loc[1].perf_loc_cd
 ELSE
  SET step_req->cv_step[1].perf_loc_cd = request->perf_loc_cd
 ENDIF
 SET step_req->cv_step[1].perf_provider_id = request->perf_provider_id
 SET step_req->cv_step[1].perf_start_dt_tm = request->perf_start_dt_tm
 SET step_req->cv_step[1].perf_stop_dt_tm = request->perf_stop_dt_tm
 SET step_req->cv_step[1].proc_normalcy_cd = request->proc_normalcy_cd
 SET step_req->cv_step[1].action_tz = request->action_tz
 IF (validate(request->event_id,null_f8) != null_f8)
  SET step_req->cv_step[1].event_id = request->event_id
 ENDIF
 EXECUTE cv_upd_step  WITH replace("REQUEST",step_req), replace("REPLY",reply)
 CALL cv_log_msg_post("014 12/01/20 MA044943")
END GO
