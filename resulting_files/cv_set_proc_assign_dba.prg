CREATE PROGRAM cv_set_proc_assign:dba
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
 ENDIF
 SET reply->status_data.status = "F"
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
 IF (validate(null_f8,0.0)=0.0)
  DECLARE null_f8 = f8 WITH constant(- (0.00001))
 ENDIF
 IF (validate(null_i4,0)=0)
  DECLARE null_i4 = i4 WITH constant(- (1))
 ENDIF
 DECLARE req_proc_cnt = i4 WITH protect, noconstant(size(request->cv_proc,5))
 DECLARE req_proc_idx = i4
 DECLARE proc_cnt = i4 WITH protect
 DECLARE proc_idx = i4
 IF (req_proc_cnt=0)
  CALL cv_log_msg(cv_warning,"CV_PROC list is empty")
  SET reply->status_data.status = "Z"
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
 SET fetch_req->withlock_flag = 1
 SET stat = alterlist(fetch_req->cv_proc,req_proc_cnt)
 FOR (req_proc_idx = 1 TO req_proc_cnt)
   SET fetch_req->cv_proc[req_proc_idx].cv_proc_id = request->cv_proc[req_proc_idx].cv_proc_id
 ENDFOR
 EXECUTE cv_fetch_procs  WITH replace("REPLY","PROC_LIST"), replace("REQUEST","FETCH_REQ")
 IF ((proc_list->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_FETCH_PROCS failed")
  GO TO exit_script
 ENDIF
 SET proc_cnt = size(proc_list->cv_proc,5)
 IF (proc_cnt < req_proc_cnt)
  CALL cv_log_msg(cv_audit,"Unable to lock all procedures for update")
  GO TO exit_script
 ENDIF
 FOR (proc_idx = 1 TO proc_cnt)
   SET req_proc_idx = locateval(req_proc_idx,1,req_proc_cnt,proc_list->cv_proc[proc_idx].cv_proc_id,
    request->cv_proc[req_proc_idx].cv_proc_id)
   CALL cv_log_msg(cv_debug,build("cv_proc_id=",request->cv_proc[req_proc_idx].cv_proc_id))
   IF ( NOT ((request->cv_proc[req_proc_idx].updt_cnt IN (null_i4, proc_list->cv_proc[proc_idx].
   updt_cnt))))
    CALL cv_log_stat(cv_audit,"SELECT","F","CV_PROC",build("UPDT_CNT=",proc_list->cv_proc[proc_idx].
      updt_cnt,", CV_PROC_ID=",request->cv_proc[req_proc_idx].cv_proc_id))
    GO TO exit_script
   ENDIF
   IF ( NOT ((request->cv_proc[req_proc_idx].prim_physician_id IN (null_f8, proc_list->cv_proc[
   proc_idx].prim_physician_id))))
    SET proc_list->cv_proc[proc_idx].prim_physician_id = request->cv_proc[req_proc_idx].
    prim_physician_id
    SET proc_list->cv_proc[proc_idx].modified_ind = 1
    CALL cv_log_msg(cv_debug,"Setting prim_physician_id")
   ENDIF
   IF ( NOT ((request->cv_proc[req_proc_idx].phys_group_id IN (null_f8, proc_list->cv_proc[proc_idx].
   phys_group_id))))
    SET proc_list->cv_proc[proc_idx].phys_group_id = request->cv_proc[req_proc_idx].phys_group_id
    SET proc_list->cv_proc[proc_idx].modified_ind = 1
    CALL cv_log_msg(cv_debug,"Setting phys_group_id")
   ENDIF
 ENDFOR
 EXECUTE cv_upd_proc  WITH replace("REQUEST","PROC_LIST")
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_warning,"EXECUTE",reply->status_data.status,"CV_UPD_PROC","")
 ENDIF
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echorecord(request)
  CALL echorecord(proc_list)
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL cv_log_msg_post("005 09/05/18 VJ043510")
END GO
