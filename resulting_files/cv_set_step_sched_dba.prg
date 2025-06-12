CREATE PROGRAM cv_set_step_sched:dba
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
 SET reply->status_data.status = "F"
 FREE RECORD step_req
 RECORD step_req(
   1 cv_step[*]
     2 cv_step_id = f8
     2 updt_cnt = i4
     2 cv_step_sched[*]
       3 sched_loc_cd = f8
       3 sched_phys_id = f8
       3 sched_start_dt_tm = dq8
       3 sched_stop_dt_tm = dq8
       3 updt_cnt = i4
 )
 RECORD step_list(
   1 cv_step[*]
     2 cv_step_id = f8
     2 updt_cnt = i4
     2 sched_updt_cnt = i4
     2 sched_start_dt_tm = dq8
     2 sched_stop_dt_tm = dq8
     2 sched_phys_id = f8
     2 sched_loc_cd = f8
 )
 SET req_step_cnt = size(request->cv_step_sched_list,5)
 IF (req_step_cnt > 0)
  SET stat = alterlist(step_list->cv_step,req_step_cnt)
  FOR (req_step_idx = 1 TO req_step_cnt)
    SET step_list->cv_step[req_step_idx].cv_step_id = request->cv_step_sched_list[req_step_idx].
    cv_step_id
    SET step_list->cv_step[req_step_idx].updt_cnt = request->cv_step_sched_list[req_step_idx].
    updt_cnt
    SET step_list->cv_step[req_step_idx].sched_updt_cnt = request->cv_step_sched_list[req_step_idx].
    sched_updt_cnt
    SET step_list->cv_step[req_step_idx].sched_start_dt_tm = request->cv_step_sched_list[req_step_idx
    ].sched_start_dt_tm
    SET step_list->cv_step[req_step_idx].sched_stop_dt_tm = request->cv_step_sched_list[req_step_idx]
    .sched_stop_dt_tm
    SET step_list->cv_step[req_step_idx].sched_phys_id = request->cv_step_sched_list[req_step_idx].
    sched_phys_id
    SET step_list->cv_step[req_step_idx].sched_loc_cd = request->cv_step_sched_list[req_step_idx].
    sched_loc_cd
  ENDFOR
 ENDIF
 IF ((request->cv_step_id > 0.0))
  SET step_list_cnt = size(step_list->cv_step,5)
  SET step_list_idx = (step_list_cnt+ 1)
  SET stat = alterlist(step_list->cv_step,(step_list_cnt+ 1))
  SET step_list->cv_step[step_list_idx].cv_step_id = request->cv_step_id
  SET step_list->cv_step[step_list_idx].updt_cnt = request->updt_cnt
  SET step_list->cv_step[step_list_idx].sched_updt_cnt = request->sched_updt_cnt
  SET step_list->cv_step[step_list_idx].sched_start_dt_tm = request->sched_start_dt_tm
  SET step_list->cv_step[step_list_idx].sched_stop_dt_tm = request->sched_stop_dt_tm
  SET step_list->cv_step[step_list_idx].sched_phys_id = request->sched_phys_id
  SET step_list->cv_step[step_list_idx].sched_loc_cd = request->sched_loc_cd
 ENDIF
 SET step_list_cnt = size(step_list->cv_step,5)
 SET stat = alterlist(step_req->cv_step,step_list_cnt)
 FOR (step_idx = 1 TO step_list_cnt)
   SET step_req->cv_step[step_idx].cv_step_id = step_list->cv_step[step_idx].cv_step_id
   SET step_req->cv_step[step_idx].updt_cnt = step_list->cv_step[step_idx].updt_cnt
   SET stat = alterlist(step_req->cv_step[step_idx].cv_step_sched,1)
   SET step_req->cv_step[step_idx].cv_step_sched[1].sched_loc_cd = step_list->cv_step[step_idx].
   sched_loc_cd
   SET step_req->cv_step[step_idx].cv_step_sched[1].sched_phys_id = step_list->cv_step[step_idx].
   sched_phys_id
   SET step_req->cv_step[step_idx].cv_step_sched[1].sched_start_dt_tm = step_list->cv_step[step_idx].
   sched_start_dt_tm
   SET step_req->cv_step[step_idx].cv_step_sched[1].sched_stop_dt_tm = step_list->cv_step[step_idx].
   sched_stop_dt_tm
   SET step_req->cv_step[step_idx].cv_step_sched[1].updt_cnt = step_list->cv_step[step_idx].
   sched_updt_cnt
 ENDFOR
 EXECUTE cv_upd_step  WITH replace("REQUEST","STEP_REQ")
#exit_script
 CALL cv_log_msg_post("003 12/01/09 TM019232")
END GO
