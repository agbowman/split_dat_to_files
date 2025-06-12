CREATE PROGRAM cv_del_procedure_steps:dba
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
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
 FREE RECORD delsteps
 RECORD delsteps(
   1 objarray[*]
     2 cv_proc_id = f8
     2 cv_step_id = f8
 )
 DECLARE stepcount = i4 WITH constant(size(request->steps,5))
 SET stat = alterlist(delsteps->objarray,stepcount)
 FOR (idx = 1 TO stepcount)
  SET delsteps->objarray[idx].cv_proc_id = request->cv_proc_id
  SET delsteps->objarray[idx].cv_step_id = request->steps[idx].cv_step_id
 ENDFOR
 IF (stepcount > 0)
  EXECUTE cv_da_del_cv_step  WITH replace("REQUEST",delsteps)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DA_DEL_CV_STEP","")
   CALL echorecord(delsteps)
   GO TO exit_script
  ENDIF
  FREE RECORD fetch_req
  RECORD fetch_req(
    1 cv_proc[*]
      2 cv_proc_id = f8
    1 cv_step[*]
      2 cv_step_id = f8
      2 cv_step_ind = i2
    1 group_event_id = f8
    1 person_id = f8
    1 encntr_id = f8
    1 prim_physician_id = f8
    1 proc_status[*]
      2 proc_status_cd = f8
    1 action_start_dt_tm = dq8
    1 action_stop_dt_tm = dq8
    1 no_steps_ind = i2
    1 withlock_flag = i2
    1 orders[*]
      2 order_id = f8
    1 activity_subtype[*]
      2 activity_subtype_cd = f8
    1 pagesize = i4
    1 organization[*]
      2 organization_id = f8
      2 confid_level_seq = i4
    1 use_confid_ind = i2
    1 prsnl_id = f8
    1 location[*]
      2 location_cd = f8
    1 group_event_ids[*]
      2 group_event_id = f8
    1 fetch_inactive_steps = i2
    1 stress_ecg_status[*]
      2 stress_ecg_status_cd = f8
  )
  SET fetch_req->withlock_flag = 2
  SET stat = alterlist(fetch_req->cv_proc,1)
  SET fetch_req->cv_proc[1].cv_proc_id = request->cv_proc_id
  FREE RECORD proc_list
  RECORD proc_list(
    1 cv_proc[*]
      2 accession = vc
      2 accession_id = f8
      2 action_dt_tm = dq8
      2 catalog_cd = f8
      2 cv_proc_id = f8
      2 encntr_id = f8
      2 group_event_id = f8
      2 order_id = f8
      2 order_physician_id = f8
      2 person_id = f8
      2 phys_group_id = f8
      2 prim_physician_id = f8
      2 priority_cd = f8
      2 proc_status_cd = f8
      2 reason_for_proc = vc
      2 refer_physician_id = f8
      2 sequence = i4
      2 request_dt_tm = dq8
      2 updt_cnt = i4
      2 modified_ind = i2
      2 cv_step[*]
        3 cv_step_id = f8
        3 event_id = f8
        3 sequence = i4
        3 step_status_cd = f8
        3 task_assay_cd = f8
        3 updt_cnt = i4
        3 modified_ind = i2
        3 match_ind = i2
        3 unmatch_ind = i2
        3 activity_subtype_cd = f8
        3 doc_id_str = vc
        3 doc_type_cd = f8
        3 proc_status_cd = f8
        3 schedule_ind = i2
        3 step_level_flag = i2
        3 perf_loc_cd = f8
        3 perf_provider_id = f8
        3 perf_start_dt_tm = dq8
        3 perf_stop_dt_tm = dq8
        3 lock_prsnl_id = f8
        3 doc_template_id = f8
        3 cv_step_sched[*]
          4 arrive_dt_tm = dq8
          4 arrive_ind = i2
          4 cv_step_sched_id = f8
          4 sched_loc_cd = f8
          4 sched_phys_id = f8
          4 sched_start_dt_tm = dq8
          4 sched_stop_dt_tm = dq8
          4 updt_cnt = i4
          4 modified_ind = i2
        3 step_type_cd = f8
        3 lock_updt_dt_tm = dq8
        3 step_resident_id = f8
        3 cv_step_ind = i2
        3 action_tz = i4
        3 modality_cd = f8
        3 vendor_cd = f8
        3 study_identifier = vc
        3 study_dt_tm = dq8
        3 pdf_doc_identifier = vc
        3 normalcy_cd = f8
      2 activity_subtype_cd = f8
      2 ed_review_ind = i2
      2 ed_review_status_cd = f8
      2 ed_requestor_prsnl_id = f8
      2 ed_request_dt_tm = dq8
      2 orig_order_dt_tm = dq8
      2 proc_normalcy_cd = f8
      2 proc_indicator = vc
      2 stress_ecg_status_cd = f8
      2 future_order_ind = i2
      2 study_state_cd = f8
      2 study_state_disp = vc
      2 study_state_mean = c12
    1 calling_process_name = vc
    1 order_action_tz = i4
    1 edit_doc_flag = i2
    1 cv_step_prsnl[*]
      2 action_dt_tm = dq8
      2 action_type_cd = f8
      2 cv_step_id = f8
      2 cv_step_prsnl_id = f8
      2 step_prsnl_id = f8
      2 step_relation_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_req), replace("REPLY",proc_list)
  IF ((proc_list->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_FETCH_PROCS","")
   GO TO exit_script
  ENDIF
  EXECUTE cv_upd_proc  WITH replace("REQUEST",proc_list)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_UPD_PROC","")
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL cv_log_msg_post("005 09/05/18 VJ043510")
END GO
