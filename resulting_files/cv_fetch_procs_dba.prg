CREATE PROGRAM cv_fetch_procs:dba
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
 DECLARE requestedaccession = vc WITH protect, constant(nullterm(validate(request->accession,"")))
 IF (requestedaccession > "")
  DECLARE requestordercount = i4 WITH protect, noconstant(size(request->orders,5))
  SELECT INTO "nl:"
   FROM accession_order_r aor
   WHERE aor.accession=requestedaccession
   DETAIL
    requestordercount += 1, stat = alterlist(request->orders,requestordercount), request->orders[
    requestordercount].order_id = aor.order_id
   WITH nocounter
  ;end select
 ENDIF
 DECLARE getrescheduledprocs(dummy) = null WITH protect
 DECLARE getschedreply(dummy) = null WITH protect
 DECLARE filteronstressecgstatus(dummy) = null WITH protect
 DECLARE c_default_pagesize = i4 WITH constant(1000), protect
 DECLARE c_max_pagesize = i4 WITH constant(5000), protect
 DECLARE eoffset_act = i2 WITH constant(10), protect
 DECLARE eoffset_stat = i2 WITH constant(20), protect
 DECLARE eoffset_prim = i2 WITH constant(40), protect
 DECLARE eoffset_org = i2 WITH constant(80), protect
 DECLARE eoffset_loc = i2 WITH constant(100), protect
 DECLARE emethod_proc = i2 WITH constant(1000), protect
 DECLARE emethod_proc_list = i2 WITH constant(1010), protect
 DECLARE emethod_order = i2 WITH constant(1100), protect
 DECLARE emethod_order_list = i2 WITH constant(1110), protect
 DECLARE emethod_group_event = i2 WITH constant(1200), protect
 DECLARE emethod_step = i2 WITH constant(1300), protect
 DECLARE emethod_step_list = i2 WITH constant(1310), protect
 DECLARE emethod_person = i2 WITH constant(2000), protect
 DECLARE emethod_person_dt = i2 WITH constant(2160), protect
 DECLARE emethod_encntr = i2 WITH constant(2320), protect
 DECLARE emethod_wl = i2 WITH constant(3000), protect
 DECLARE emethod_wl_act = i2 WITH constant((emethod_wl+ eoffset_act)), protect
 DECLARE emethod_wl_stat = i2 WITH constant((emethod_wl+ eoffset_stat)), protect
 DECLARE emethod_wl_act_stat = i2 WITH constant((emethod_wl_act+ eoffset_stat)), protect
 DECLARE emethod_wl_prim = i2 WITH constant((emethod_wl+ eoffset_prim)), protect
 DECLARE emethod_wl_act_prim = i2 WITH constant((emethod_wl_act+ eoffset_prim)), protect
 DECLARE emethod_wl_stat_prim = i2 WITH constant((emethod_wl_stat+ eoffset_prim)), protect
 DECLARE emethod_wl_act_stat_prim = i2 WITH constant((emethod_wl_act_stat+ eoffset_prim)), protect
 DECLARE emethod_wl_org = i2 WITH constant((emethod_wl+ eoffset_org)), protect
 DECLARE emethod_wl_act_org = i2 WITH constant((emethod_wl_org+ eoffset_act)), protect
 DECLARE emethod_wl_stat_org = i2 WITH constant((emethod_wl_org+ eoffset_stat)), protect
 DECLARE emethod_wl_act_stat_org = i2 WITH constant((emethod_wl_act_org+ eoffset_stat)), protect
 DECLARE emethod_wl_prim_org = i2 WITH constant((emethod_wl_org+ eoffset_prim)), protect
 DECLARE emethod_wl_act_prim_org = i2 WITH constant((emethod_wl_act_org+ eoffset_prim)), protect
 DECLARE emethod_wl_stat_prim_org = i2 WITH constant((emethod_wl_stat_org+ eoffset_prim)), protect
 DECLARE emethod_wl_act_stat_prim_org = i2 WITH constant((emethod_wl_act_stat_org+ eoffset_prim)),
 protect
 DECLARE emethod_wl_loc_org = i2 WITH constant((emethod_wl_org+ eoffset_loc)), protect
 DECLARE emethod_wl_act_loc_org = i2 WITH constant((emethod_wl_act_org+ eoffset_loc)), protect
 DECLARE emethod_wl_stat_loc_org = i2 WITH constant((emethod_wl_stat_org+ eoffset_loc)), protect
 DECLARE emethod_wl_act_stat_loc_org = i2 WITH constant((emethod_wl_act_stat_org+ eoffset_loc)),
 protect
 DECLARE emethod_person_org = i2 WITH constant((emethod_person+ eoffset_org)), protect
 DECLARE emethod_person_dt_org = i2 WITH constant((emethod_person_dt+ eoffset_org)), protect
 DECLARE emethod_person_act = i2 WITH constant((emethod_person+ eoffset_act)), protect
 DECLARE emethod_person_act_stat = i2 WITH constant((emethod_person_act+ eoffset_stat)), protect
 DECLARE emethod_person_stat = i2 WITH constant((emethod_person+ eoffset_stat)), protect
 DECLARE emethod_group_event_list = i2 WITH constant(4000), protect
 DECLARE step_stat_notstarted = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "NOTSTARTED"))
 DECLARE req_cv_proc_cnt = i4 WITH protect
 DECLARE req_cv_step_cnt = i4 WITH protect
 DECLARE req_proc_status_cnt = i4 WITH protect
 DECLARE req_orders_cnt = i4 WITH protect
 DECLARE req_activity_subtype_cnt = i4 WITH protect
 DECLARE req_organization_cnt = i4 WITH protect
 DECLARE req_location_cnt = i4 WITH noconstant(0), protect
 DECLARE req_group_event_ids_cnt = i4 WITH noconstant(0), protect
 DECLARE req_stress_ecg_status_cnt = i4 WITH protect
 DECLARE step_count = i2 WITH noconstant(0), protect
 DECLARE g_prim_physician_id = f8 WITH noconstant(validate(request->prim_physician_id,0.0)), protect
 DECLARE g_act_start_dt_tm = dq8 WITH noconstant(validate(request->action_start_dt_tm,0.0)), protect
 DECLARE g_act_stop_dt_tm = dq8 WITH noconstant(validate(request->action_stop_dt_tm,0.0)), protect
 DECLARE g_person_id = f8 WITH noconstant(validate(request->person_id,0.0)), protect
 DECLARE g_encntr_id = f8 WITH noconstant(validate(request->encntr_id,0.0)), protect
 DECLARE g_group_event_id = f8 WITH noconstant(validate(request->group_event_id,0.0)), protect
 DECLARE g_no_steps_ind = i2 WITH noconstant(validate(request->no_steps_ind,0)), protect
 DECLARE g_withlock_flag = i4 WITH noconstant(validate(request->withlock_flag,0)), protect
 DECLARE g_pagesize = i4 WITH noconstant(validate(request->pagesize,c_default_pagesize)), protect
 DECLARE proc_cnt = i4 WITH noconstant(0), protect
 DECLARE padded_size = i4 WITH protect
 DECLARE proc_idx = i4 WITH protect
 DECLARE filter_cnt_indx = i4 WITH protect
 DECLARE alter_list_cnt = i4 WITH protect
 DECLARE method_flag = i2 WITH protect
 DECLARE var_idx = i4 WITH protect
 DECLARE var_pad = i4 WITH protect
 DECLARE var_cnt = i4 WITH protect
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE req_fetch_inactive_steps = i2 WITH noconstant(0), protect
 DECLARE block_size = i4 WITH protect, constant(20)
 DECLARE locate_idx = i4 WITH protect
 DECLARE bapplyencountersecurity = i2 WITH protect, noconstant(1)
 DECLARE age_show = i4 WITH noconstant(validate(request->age_show,- (1))), protect
 DECLARE my_group_id = i4 WITH noconstant(validate(request->my_group_id,- (1))), protect
 DECLARE filteredproccnts = i4 WITH noconstant(0), protect
 DECLARE procbatchsize = i4 WITH noconstant(0), protect
 DECLARE beginindx = i4 WITH noconstant(1), protect
 DECLARE endindx = i4 WITH noconstant(g_pagesize), protect
 DECLARE batchidx = i4 WITH noconstant(0), protect
 IF (validate(reply) != 1)
  RECORD reply(
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
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD tempreply
 RECORD tempreply(
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
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD remove_encounter_list
 RECORD remove_encounter_list(
   1 encounter[*]
     2 encntr_id = f8
 )
 FREE RECORD ed_review_info
 RECORD ed_review_info(
   1 orderlist[*]
     2 order_id = f8
     2 insert_idx = i4
 )
 FREE RECORD filteredcvprocids
 RECORD filteredcvprocids(
   1 qual[*]
     2 cv_proc_id = f8
     2 stress_ecg_status_cd = f8
 )
 SET reply->status_data.status = "F"
 IF (validate(request->cv_proc)=1)
  SET req_cv_proc_cnt = size(request->cv_proc,5)
 ENDIF
 IF (validate(request->cv_step)=1)
  SET req_cv_step_cnt = size(request->cv_step,5)
 ENDIF
 IF (validate(request->proc_status)=1)
  SET req_proc_status_cnt = size(request->proc_status,5)
 ENDIF
 IF (validate(request->orders)=1)
  SET req_orders_cnt = size(request->orders,5)
 ENDIF
 IF (validate(request->activity_subtype)=1)
  SET req_activity_subtype_cnt = size(request->activity_subtype,5)
 ENDIF
 IF (validate(request->organization)=1)
  SET req_organization_cnt = size(request->organization,5)
 ENDIF
 IF (validate(request->location)=1)
  SET req_location_cnt = size(request->location,5)
 ENDIF
 IF (validate(request->group_event_ids)=1)
  SET req_group_event_ids_cnt = size(request->group_event_ids,5)
 ENDIF
 IF (validate(request->fetch_inactive_steps)=1)
  SET req_fetch_inactive_steps = request->fetch_inactive_steps
 ELSE
  SET req_fetch_inactive_steps = 0
 ENDIF
 IF (validate(request->stress_ecg_status)=1)
  SET req_stress_ecg_status_cnt = size(request->stress_ecg_status,5)
 ENDIF
 IF (g_person_id > 0.0)
  SET req_proc_status_cnt = size(request->proc_status,5)
 ELSEIF (req_proc_status_cnt <= 0)
  SET stat = alterlist(request->proc_status,12)
  SET request->proc_status[1].proc_status_cd = uar_get_code_by("MEANING",4000341,"ARRIVED")
  SET request->proc_status[2].proc_status_cd = uar_get_code_by("MEANING",4000341,"CANCELLED")
  SET request->proc_status[3].proc_status_cd = uar_get_code_by("MEANING",4000341,"COMPLETED")
  SET request->proc_status[4].proc_status_cd = uar_get_code_by("MEANING",4000341,"DISCONTINUED")
  SET request->proc_status[5].proc_status_cd = uar_get_code_by("MEANING",4000341,"INPROCESS")
  SET request->proc_status[6].proc_status_cd = uar_get_code_by("MEANING",4000341,"ORDERED")
  SET request->proc_status[7].proc_status_cd = uar_get_code_by("MEANING",4000341,"SCHEDULED")
  SET request->proc_status[8].proc_status_cd = uar_get_code_by("MEANING",4000341,"SIGNED")
  SET request->proc_status[9].proc_status_cd = uar_get_code_by("MEANING",4000341,"VERIFIED")
  SET request->proc_status[10].proc_status_cd = uar_get_code_by("MEANING",4000341,"UNSIGNED")
  SET request->proc_status[11].proc_status_cd = uar_get_code_by("MEANING",4000341,"EDREVIEW")
  SET request->proc_status[12].proc_status_cd = uar_get_code_by("MEANING",4000341,"AMENDED")
  SET req_proc_status_cnt = size(request->proc_status,5)
 ENDIF
 IF (req_cv_proc_cnt=1)
  SET method_flag = emethod_proc
 ELSEIF (req_cv_proc_cnt > 1)
  SET method_flag = emethod_proc_list
 ELSEIF (req_cv_step_cnt=1)
  SET method_flag = emethod_step
 ELSEIF (req_cv_step_cnt > 1)
  SET method_flag = emethod_step_list
  CALL cv_log_stat(cv_warning,"REQUEST","F","CV_STEP",
   "request->cv_step currently only supports size 1 lists")
  GO TO exit_script
 ELSEIF (req_orders_cnt=1)
  SET method_flag = emethod_order
 ELSEIF (req_orders_cnt > 1)
  SET method_flag = emethod_order_list
 ELSEIF (g_group_event_id > 0.0)
  SET method_flag = emethod_group_event
 ELSEIF (req_group_event_ids_cnt > 0)
  SET method_flag = emethod_group_event_list
 ELSEIF (g_encntr_id > 0.0)
  SET method_flag = emethod_encntr
 ELSEIF (g_person_id > 0.0)
  IF (g_act_stop_dt_tm > 0.0)
   SET method_flag = emethod_person_dt
  ELSE
   SET method_flag = emethod_person
  ENDIF
  IF (req_activity_subtype_cnt > 0)
   SET method_flag += eoffset_act
  ENDIF
  IF (req_proc_status_cnt > 0)
   SET method_flag += eoffset_stat
  ENDIF
  IF (req_organization_cnt > 0)
   SET method_flag += eoffset_org
  ENDIF
  IF (req_location_cnt > 0)
   SET method_flag += eoffset_loc
  ENDIF
 ELSE
  SET method_flag = emethod_wl
  IF (req_activity_subtype_cnt > 0)
   SET method_flag += eoffset_act
  ENDIF
  IF (req_proc_status_cnt > 0)
   SET method_flag += eoffset_stat
  ENDIF
  IF (g_prim_physician_id > 0.0)
   SET method_flag += eoffset_prim
  ENDIF
  IF (req_organization_cnt > 0)
   SET method_flag += eoffset_org
  ENDIF
  IF (req_location_cnt > 0)
   SET method_flag += eoffset_loc
  ENDIF
 ENDIF
 IF (method_flag <= 0)
  CALL cv_log_msg(cv_error,"Failed to determine lookup method for fetch")
  GO TO exit_script
 ENDIF
 SET nstart = 1
 CASE (method_flag)
  OF emethod_proc:
  OF emethod_step:
  OF emethod_group_event:
  OF emethod_order:
   SET bapplyencountersecurity = 0
  OF emethod_proc_list:
   SET var_cnt = req_cv_proc_cnt
   SET var_pad = (var_cnt+ ((block_size - 1) - mod((var_cnt - 1),block_size)))
   SET stat = alterlist(request->cv_proc,var_pad)
   SET bapplyencountersecurity = 0
   FOR (var_idx = (var_cnt+ 1) TO var_pad)
     SET request->cv_proc[var_idx].cv_proc_id = request->cv_proc[var_cnt].cv_proc_id
   ENDFOR
  OF emethod_order_list:
   SET var_cnt = req_orders_cnt
   SET var_pad = (var_cnt+ ((block_size - 1) - mod((var_cnt - 1),block_size)))
   SET stat = alterlist(request->orders,var_pad)
   SET bapplyencountersecurity = 0
   FOR (var_idx = (var_cnt+ 1) TO var_pad)
     SET request->orders[var_idx].order_id = request->orders[var_cnt].order_id
   ENDFOR
  OF emethod_wl_act:
  OF emethod_wl_act_prim:
  OF emethod_wl_act_org:
  OF emethod_wl_act_prim_org:
  OF emethod_person_act:
   SET var_cnt = req_activity_subtype_cnt
   SET var_pad = (var_cnt+ ((block_size - 1) - mod((var_cnt - 1),block_size)))
   SET stat = alterlist(request->activity_subtype,var_pad)
   FOR (var_idx = (var_cnt+ 1) TO var_pad)
     SET request->activity_subtype[var_idx].activity_subtype_cd = request->activity_subtype[var_cnt].
     activity_subtype_cd
   ENDFOR
  OF emethod_wl_stat:
  OF emethod_wl_stat_prim:
  OF emethod_wl_act_stat:
  OF emethod_wl_act_stat_prim:
  OF emethod_wl_stat_org:
  OF emethod_wl_stat_prim_org:
  OF emethod_wl_act_stat_org:
  OF emethod_wl_act_stat_prim_org:
  OF emethod_person_stat:
  OF emethod_person_act_stat:
   SET var_cnt = req_proc_status_cnt
   SET var_pad = (var_cnt+ ((block_size - 1) - mod((var_cnt - 1),block_size)))
   SET stat = alterlist(request->proc_status,var_pad)
   FOR (var_idx = (var_cnt+ 1) TO var_pad)
     SET request->proc_status[var_idx].proc_status_cd = request->proc_status[var_cnt].proc_status_cd
   ENDFOR
  OF emethod_wl_org:
  OF emethod_wl_prim_org:
  OF emethod_person_org:
  OF emethod_person_dt_org:
   SET var_cnt = req_organization_cnt
   SET var_pad = (var_cnt+ ((block_size - 1) - mod((var_cnt - 1),block_size)))
   SET stat = alterlist(request->organization,var_pad)
   FOR (var_idx = (var_cnt+ 1) TO var_pad)
     SET request->organization[var_idx].organization_id = request->organization[var_cnt].
     organization_id
   ENDFOR
  OF emethod_group_event_list:
   SET var_cnt = req_group_event_ids_cnt
   SET var_pad = (var_cnt+ ((block_size - 1) - mod((var_cnt - 1),block_size)))
   SET stat = alterlist(request->group_event_ids,var_pad)
   SET bapplyencountersecurity = 0
   FOR (var_idx = (var_cnt+ 1) TO var_pad)
     SET request->group_event_ids[var_idx].group_event_id = request->group_event_ids[var_cnt].
     group_event_id
   ENDFOR
  OF emethod_wl_loc_org:
  OF emethod_wl_act_loc_org:
  OF emethod_wl_stat_loc_org:
  OF emethod_wl_act_stat_loc_org:
   SET var_cnt = req_location_cnt
   SET var_pad = (var_cnt+ ((block_size - 1) - mod((var_cnt - 1),block_size)))
   SET stat = alterlist(request->location,var_pad)
   FOR (var_idx = (var_cnt+ 1) TO var_pad)
     SET request->location[var_idx].location_cd = request->location[var_cnt].location_cd
   ENDFOR
 ENDCASE
 IF ((reqdata->loglevel >= cv_debug))
  CALL cv_log_msg(cv_debug,concat("req_cv_proc_cnt:",cnvtstring(req_cv_proc_cnt)))
  CALL cv_log_msg(cv_debug,concat("person_id:",cnvtstring(g_person_id)))
  CALL cv_log_msg(cv_debug,concat("encntr_id:",cnvtstring(g_encntr_id)))
  CALL cv_log_msg(cv_debug,concat("req_cv_step_cnt:",cnvtstring(req_cv_step_cnt)))
  CALL cv_log_msg(cv_debug,concat("req_proc_status_cnt:",cnvtstring(req_proc_status_cnt)))
  CALL cv_log_msg(cv_debug,concat("req_activity_subtype_cnt:",cnvtstring(req_activity_subtype_cnt)))
  CALL cv_log_msg(cv_debug,concat("req_stress_ecg_status_cnt:",cnvtstring(req_stress_ecg_status_cnt))
   )
  CALL cv_log_msg(cv_debug,concat("req_orders_cnt:",cnvtstring(req_orders_cnt)))
  CALL cv_log_msg(cv_debug,concat("prim_physician_id:",cnvtstring(g_prim_physician_id)))
  CALL cv_log_msg(cv_debug,concat("group_event_id:",cnvtstring(g_group_event_id)))
  CALL cv_log_msg(cv_debug,concat("action_start_dt_tm:",format(g_act_start_dt_tm,"MM/DD/YYYY;;D")))
  CALL cv_log_msg(cv_debug,concat("action_stop_dt_tm:",format(g_act_stop_dt_tm,"MM/DD/YYYY;;D")))
  CALL cv_log_msg(cv_debug,concat("method_flag:",cnvtstring(method_flag)))
  CALL cv_log_msg(cv_debug,concat("withlock_flag:",cnvtstring(g_withlock_flag)))
  CALL cv_log_msg(cv_debug,concat("pagesize:",cnvtstring(g_pagesize)))
  CALL echorecord(request)
 ENDIF
 IF (method_flag < emethod_person)
  IF (validate(request->pagesize,0) > 0)
   CALL cv_log_msg(cv_info,"request->pagesize ignored for non-pageable method")
  ENDIF
  SET g_pagesize = - (1)
 ELSE
  IF (g_withlock_flag > 0)
   CALL cv_log_stat(cv_warning,"REQUEST","F","WITHLOCK_FLAG",
    "withlock_flag not supported for this method")
   GO TO exit_script
  ENDIF
  IF (g_pagesize <= 0)
   CALL cv_log_msg(cv_info,build2("Invalid pagesize ",g_pagesize," changed to default ",
     c_default_pagesize))
   SET g_pagesize = c_default_pagesize
  ELSEIF (g_pagesize > c_max_pagesize)
   CALL cv_log_msg(cv_info,build2("Invalid pagesize ",g_pagesize," changed to max ",c_max_pagesize))
   SET g_pagesize = c_max_pagesize
  ENDIF
 ENDIF
 IF (((age_show=0) OR (((age_show=1) OR (my_group_id > 0)) )) )
  FREE RECORD tempfilteredcvprocidsreply
  RECORD tempfilteredcvprocidsreply(
    1 qual[*]
      2 cv_proc_id = f8
      2 stress_ecg_status_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  EXECUTE cv_filter_procs_by_groups_age  WITH replace("REQUEST",request), replace("REPLY",
   tempfilteredcvprocidsreply)
  IF ((tempfilteredcvprocidsreply->status_data.status="S"))
   FREE RECORD filteredcvprocids
   RECORD filteredcvprocids(
     1 qual[*]
       2 cv_proc_id = f8
       2 stress_ecg_status_cd = f8
   )
   SET proc_cnt = size(tempfilteredcvprocidsreply->qual,5)
   SET stat = alterlist(filteredcvprocids->qual,proc_cnt)
   FOR (indx = 1 TO proc_cnt)
    SET filteredcvprocids->qual[indx].cv_proc_id = tempfilteredcvprocidsreply->qual[indx].cv_proc_id
    SET filteredcvprocids->qual[indx].stress_ecg_status_cd = tempfilteredcvprocidsreply->qual[indx].
    stress_ecg_status_cd
   ENDFOR
   SET alter_list_cnt = size(filteredcvprocids->qual,5)
  ENDIF
 ELSE
  CALL getrescheduledprocs(0)
 ENDIF
 IF (req_stress_ecg_status_cnt > 0)
  CALL filteronstressecgstatus(0)
 ENDIF
 IF (validate(request->use_confid_ind) != 0)
  IF ((request->use_confid_ind=1))
   SET bapplyencountersecurity = 1
  ENDIF
 ENDIF
 SELECT
  IF (method_flag=emethod_proc
   AND g_withlock_flag=0)
   PLAN (p
    WHERE (p.cv_proc_id=request->cv_proc[1].cv_proc_id))
   WITH nocounter
  ELSEIF (method_flag=emethod_proc
   AND g_withlock_flag=1)
   PLAN (p
    WHERE (p.cv_proc_id=request->cv_proc[1].cv_proc_id))
   WITH nocounter, forupdate(p)
  ELSEIF (method_flag=emethod_proc
   AND g_withlock_flag=2)
   PLAN (p
    WHERE (p.cv_proc_id=request->cv_proc[1].cv_proc_id))
   WITH nocounter, forupdatewait(p)
  ELSEIF (method_flag=emethod_proc_list
   AND g_withlock_flag=0)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE expand(var_idx,nstart,((nstart+ block_size) - 1),p.cv_proc_id,request->cv_proc[var_idx].
     cv_proc_id))
   WITH nocounter
  ELSEIF (method_flag=emethod_proc_list
   AND g_withlock_flag=1)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE expand(var_idx,nstart,((nstart+ block_size) - 1),p.cv_proc_id,request->cv_proc[var_idx].
     cv_proc_id))
   WITH nocounter, forupdate(p)
  ELSEIF (method_flag=emethod_proc_list
   AND g_withlock_flag=2)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE expand(var_idx,nstart,((nstart+ block_size) - 1),p.cv_proc_id,request->cv_proc[var_idx].
     cv_proc_id))
   WITH nocounter, forupdatewait(p)
  ELSEIF (method_flag=emethod_order
   AND g_withlock_flag=0)
   PLAN (p
    WHERE (p.order_id=request->orders[1].order_id))
   WITH nocounter
  ELSEIF (method_flag=emethod_order
   AND g_withlock_flag=1)
   PLAN (p
    WHERE (p.order_id=request->orders[1].order_id))
   WITH nocounter, forupdate(p)
  ELSEIF (method_flag=emethod_order
   AND g_withlock_flag=2)
   PLAN (p
    WHERE (p.order_id=request->orders[1].order_id))
   WITH nocounter, forupdatewait(p)
  ELSEIF (method_flag=emethod_order_list
   AND g_withlock_flag=0)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE expand(var_idx,nstart,((nstart+ block_size) - 1),p.order_id,request->orders[var_idx].
     order_id))
   WITH nocounter
  ELSEIF (method_flag=emethod_order_list
   AND g_withlock_flag=1)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE expand(var_idx,nstart,((nstart+ block_size) - 1),p.order_id,request->orders[var_idx].
     order_id))
   WITH nocounter, forupdate(p)
  ELSEIF (method_flag=emethod_order_list
   AND g_withlock_flag=2)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE expand(var_idx,nstart,((nstart+ block_size) - 1),p.order_id,request->orders[var_idx].
     order_id))
   WITH nocounter, forupdatewait(p)
  ELSEIF (method_flag=emethod_group_event
   AND g_withlock_flag=0)
   PLAN (p
    WHERE (p.group_event_id=request->group_event_id))
   WITH nocounter
  ELSEIF (method_flag=emethod_group_event
   AND g_withlock_flag=1)
   PLAN (p
    WHERE (p.group_event_id=request->group_event_id))
   WITH nocounter, forupdate(p)
  ELSEIF (method_flag=emethod_group_event
   AND g_withlock_flag=2)
   PLAN (p
    WHERE (p.group_event_id=request->group_event_id))
   WITH nocounter, forupdatewait(p)
  ELSEIF (method_flag=emethod_step
   AND g_withlock_flag=0)
   PLAN (p
    WHERE (p.cv_proc_id=
    (SELECT
     s.cv_proc_id
     FROM cv_step s
     WHERE (s.cv_step_id=request->cv_step[1].cv_step_id))))
   WITH nocounter
  ELSEIF (method_flag=emethod_step
   AND g_withlock_flag=1)
   PLAN (p
    WHERE (p.cv_proc_id=
    (SELECT
     s.cv_proc_id
     FROM cv_step s
     WHERE (s.cv_step_id=request->cv_step[1].cv_step_id))))
   WITH nocounter, forupdate(p)
  ELSEIF (method_flag=emethod_step
   AND g_withlock_flag=2)
   PLAN (p
    WHERE (p.cv_proc_id=
    (SELECT
     s.cv_proc_id
     FROM cv_step s
     WHERE (s.cv_step_id=request->cv_step[1].cv_step_id))))
   WITH nocounter, forupdatewait(p)
  ELSEIF (method_flag=emethod_person)
   PLAN (p
    WHERE p.person_id=g_person_id)
   ORDER BY p.action_dt_tm DESC
  ELSEIF (method_flag=emethod_person_dt)
   PLAN (p
    WHERE p.person_id=g_person_id
     AND expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[filter_cnt_indx
     ].cv_proc_id))
   ORDER BY p.action_dt_tm DESC
  ELSEIF (method_flag=emethod_person_act_stat)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    (dummyt d1  WITH seq = value(req_activity_subtype_cnt)),
    cv_proc p
   PLAN (d1)
    JOIN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE p.person_id=g_person_id
     AND (p.activity_subtype_cd=request->activity_subtype[d1.seq].activity_subtype_cd)
     AND expand(var_idx,nstart,((nstart+ block_size) - 1),p.proc_status_cd,request->proc_status[
     var_idx].proc_status_cd))
   ORDER BY p.action_dt_tm DESC
  ELSEIF (method_flag=emethod_person_act)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    (dummyt d1  WITH seq = value(req_activity_subtype_cnt)),
    cv_proc p
   PLAN (d1)
    JOIN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE p.person_id=g_person_id
     AND (p.activity_subtype_cd=request->activity_subtype[d1.seq].activity_subtype_cd))
   ORDER BY p.action_dt_tm DESC
  ELSEIF (method_flag=emethod_person_stat)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE p.person_id=g_person_id
     AND expand(var_idx,nstart,((nstart+ block_size) - 1),p.proc_status_cd,request->proc_status[
     var_idx].proc_status_cd))
   ORDER BY p.action_dt_tm DESC
  ELSEIF (method_flag=emethod_person_org)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p,
    encounter e
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE p.person_id=g_person_id)
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,nstart,((nstart+ block_size) - 1),e.organization_id,request->organization[
     var_idx].organization_id))
   ORDER BY p.action_dt_tm DESC
  ELSEIF (method_flag=emethod_person_dt_org)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p,
    encounter e
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE p.person_id=g_person_id
     AND expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[filter_cnt_indx
     ].cv_proc_id))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,nstart,((nstart+ block_size) - 1),e.organization_id,request->organization[
     var_idx].organization_id))
   ORDER BY p.action_dt_tm DESC
  ELSEIF (method_flag=emethod_encntr)
   PLAN (p
    WHERE p.encntr_id=g_encntr_id)
  ELSEIF (method_flag=emethod_wl)
   PLAN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id))
  ELSEIF (method_flag=emethod_wl_act)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id)
     AND expand(var_idx,nstart,((nstart+ block_size) - 1),p.activity_subtype_cd,request->
     activity_subtype[var_idx].activity_subtype_cd))
  ELSEIF (method_flag=emethod_wl_stat)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id)
     AND expand(var_idx,nstart,((nstart+ block_size) - 1),p.proc_status_cd,request->proc_status[
     var_idx].proc_status_cd))
  ELSEIF (method_flag=emethod_wl_act_stat)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    (dummyt d1  WITH seq = value(req_activity_subtype_cnt)),
    cv_proc p
   PLAN (d1)
    JOIN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id)
     AND (p.activity_subtype_cd=request->activity_subtype[d1.seq].activity_subtype_cd)
     AND expand(var_idx,nstart,((nstart+ block_size) - 1),p.proc_status_cd,request->proc_status[
     var_idx].proc_status_cd))
   ORDER BY p.action_dt_tm, p.activity_subtype_cd, p.proc_status_cd,
    p.cv_proc_id
  ELSEIF (method_flag=emethod_wl_prim)
   PLAN (p
    WHERE p.prim_physician_id=g_prim_physician_id
     AND expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[filter_cnt_indx
     ].cv_proc_id))
  ELSEIF (method_flag=emethod_wl_act_prim)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE p.prim_physician_id=g_prim_physician_id
     AND expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[filter_cnt_indx
     ].cv_proc_id)
     AND expand(var_idx,nstart,((nstart+ block_size) - 1),(p.activity_subtype_cd+ 0),request->
     activity_subtype[var_idx].activity_subtype_cd))
  ELSEIF (method_flag=emethod_wl_stat_prim)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE p.prim_physician_id=g_prim_physician_id
     AND expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[filter_cnt_indx
     ].cv_proc_id)
     AND expand(var_idx,nstart,((nstart+ block_size) - 1),p.proc_status_cd,request->proc_status[
     var_idx].proc_status_cd))
  ELSEIF (method_flag=emethod_wl_act_stat_prim)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    (dummyt d1  WITH seq = value(req_activity_subtype_cnt)),
    cv_proc p
   PLAN (d1)
    JOIN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE p.prim_physician_id=g_prim_physician_id
     AND expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[filter_cnt_indx
     ].cv_proc_id)
     AND (p.activity_subtype_cd=request->activity_subtype[d1.seq].activity_subtype_cd)
     AND expand(var_idx,nstart,((nstart+ block_size) - 1),p.proc_status_cd,request->proc_status[
     var_idx].proc_status_cd))
  ELSEIF (method_flag=emethod_wl_org)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p,
    encounter e
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,nstart,((nstart+ block_size) - 1),e.organization_id,request->organization[
     var_idx].organization_id))
  ELSEIF (method_flag=emethod_wl_act_org)
   FROM cv_proc p,
    encounter e
   PLAN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id)
     AND expand(var_idx,1,req_activity_subtype_cnt,p.activity_subtype_cd,request->activity_subtype[
     var_idx].activity_subtype_cd))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,1,req_organization_cnt,e.organization_id,request->organization[var_idx].
     organization_id))
  ELSEIF (method_flag=emethod_wl_stat_org)
   FROM cv_proc p,
    encounter e
   PLAN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id)
     AND expand(var_idx,1,req_proc_status_cnt,p.proc_status_cd,request->proc_status[var_idx].
     proc_status_cd))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,1,req_organization_cnt,e.organization_id,request->organization[var_idx].
     organization_id))
  ELSEIF (method_flag=emethod_wl_act_stat_org)
   FROM cv_proc p,
    encounter e
   PLAN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id)
     AND expand(var_idx,1,req_activity_subtype_cnt,p.activity_subtype_cd,request->activity_subtype[
     var_idx].activity_subtype_cd)
     AND expand(var_idx,1,req_proc_status_cnt,p.proc_status_cd,request->proc_status[var_idx].
     proc_status_cd))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,1,req_organization_cnt,e.organization_id,request->organization[var_idx].
     organization_id))
  ELSEIF (method_flag=emethod_wl_prim_org)
   FROM cv_proc p,
    encounter e
   PLAN (p
    WHERE p.prim_physician_id=g_prim_physician_id
     AND expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[filter_cnt_indx
     ].cv_proc_id))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,1,req_organization_cnt,e.organization_id,request->organization[var_idx].
     organization_id))
  ELSEIF (method_flag=emethod_wl_act_prim_org)
   FROM cv_proc p,
    encounter e
   PLAN (p
    WHERE p.prim_physician_id=g_prim_physician_id
     AND expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[filter_cnt_indx
     ].cv_proc_id)
     AND expand(var_idx,1,req_activity_subtype_cnt,p.activity_subtype_cd,request->activity_subtype[
     var_idx].activity_subtype_cd))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,1,req_organization_cnt,e.organization_id,request->organization[var_idx].
     organization_id))
  ELSEIF (method_flag=emethod_wl_stat_prim_org)
   FROM cv_proc p,
    encounter e
   PLAN (p
    WHERE p.prim_physician_id=g_prim_physician_id
     AND expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[filter_cnt_indx
     ].cv_proc_id)
     AND expand(var_idx,1,req_proc_status_cnt,p.proc_status_cd,request->proc_status[var_idx].
     proc_status_cd))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,1,req_organization_cnt,e.organization_id,request->organization[var_idx].
     organization_id))
  ELSEIF (method_flag=emethod_wl_act_stat_prim_org)
   FROM cv_proc p,
    encounter e
   PLAN (p
    WHERE p.prim_physician_id=g_prim_physician_id
     AND expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[filter_cnt_indx
     ].cv_proc_id)
     AND expand(var_idx,1,req_activity_subtype_cnt,p.activity_subtype_cd,request->activity_subtype[
     var_idx].activity_subtype_cd)
     AND expand(var_idx,1,req_proc_status_cnt,p.proc_status_cd,request->proc_status[var_idx].
     proc_status_cd))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,1,req_organization_cnt,e.organization_id,request->organization[var_idx].
     organization_id))
  ELSEIF (method_flag=emethod_group_event_list)
   FROM (dummyt d  WITH seq = value((var_pad/ block_size))),
    cv_proc p
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (p
    WHERE expand(var_idx,nstart,((nstart+ block_size) - 1),p.group_event_id,request->group_event_ids[
     var_idx].group_event_id))
  ELSEIF (method_flag=emethod_wl_loc_org)
   FROM cv_proc p,
    encounter e
   PLAN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,1,req_organization_cnt,e.organization_id,request->organization[var_idx].
     organization_id)
     AND ((expand(var_idx,1,req_location_cnt,e.loc_facility_cd,request->location[var_idx].location_cd
     )) OR (((expand(var_idx,1,req_location_cnt,e.loc_building_cd,request->location[var_idx].
     location_cd)) OR (expand(var_idx,1,req_location_cnt,e.loc_nurse_unit_cd,request->location[
     var_idx].location_cd))) )) )
  ELSEIF (method_flag=emethod_wl_act_loc_org)
   FROM cv_proc p,
    encounter e
   PLAN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id)
     AND expand(var_idx,1,req_activity_subtype_cnt,p.activity_subtype_cd,request->activity_subtype[
     var_idx].activity_subtype_cd))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,1,req_organization_cnt,e.organization_id,request->organization[var_idx].
     organization_id)
     AND ((expand(var_idx,1,req_location_cnt,e.loc_facility_cd,request->location[var_idx].location_cd
     )) OR (((expand(var_idx,1,req_location_cnt,e.loc_building_cd,request->location[var_idx].
     location_cd)) OR (expand(var_idx,1,req_location_cnt,e.loc_nurse_unit_cd,request->location[
     var_idx].location_cd))) )) )
  ELSEIF (method_flag=emethod_wl_stat_loc_org)
   FROM cv_proc p,
    encounter e
   PLAN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id)
     AND expand(var_idx,1,req_proc_status_cnt,p.proc_status_cd,request->proc_status[var_idx].
     proc_status_cd))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,1,req_organization_cnt,e.organization_id,request->organization[var_idx].
     organization_id)
     AND ((expand(var_idx,1,req_location_cnt,e.loc_facility_cd,request->location[var_idx].location_cd
     )) OR (((expand(var_idx,1,req_location_cnt,e.loc_building_cd,request->location[var_idx].
     location_cd)) OR (expand(var_idx,1,req_location_cnt,e.loc_nurse_unit_cd,request->location[
     var_idx].location_cd))) )) )
  ELSEIF (method_flag=emethod_wl_act_stat_loc_org)
   FROM cv_proc p,
    encounter e
   PLAN (p
    WHERE expand(filter_cnt_indx,1,alter_list_cnt,p.cv_proc_id,filteredcvprocids->qual[
     filter_cnt_indx].cv_proc_id)
     AND expand(var_idx,1,req_activity_subtype_cnt,p.activity_subtype_cd,request->activity_subtype[
     var_idx].activity_subtype_cd)
     AND expand(var_idx,1,req_proc_status_cnt,p.proc_status_cd,request->proc_status[var_idx].
     proc_status_cd))
    JOIN (e
    WHERE e.encntr_id=p.encntr_id
     AND expand(var_idx,1,req_organization_cnt,e.organization_id,request->organization[var_idx].
     organization_id)
     AND ((expand(var_idx,1,req_location_cnt,e.loc_facility_cd,request->location[var_idx].location_cd
     )) OR (((expand(var_idx,1,req_location_cnt,e.loc_building_cd,request->location[var_idx].
     location_cd)) OR (expand(var_idx,1,req_location_cnt,e.loc_nurse_unit_cd,request->location[
     var_idx].location_cd))) )) )
  ELSE
  ENDIF
  INTO "nl:"
  FROM cv_proc p
  PLAN (p
   WHERE (p.cv_proc_id=- (1.0)))
  HEAD REPORT
   proc_cnt = 0, l_maxqual_ind = 0
  DETAIL
   proc_cnt += 1
   IF (proc_cnt > size(tempreply->cv_proc,5))
    stat = alterlist(tempreply->cv_proc,(proc_cnt+ block_size))
   ENDIF
   tempreply->cv_proc[proc_cnt].accession = p.accession, tempreply->cv_proc[proc_cnt].accession_id =
   p.accession_id, tempreply->cv_proc[proc_cnt].action_dt_tm = p.action_dt_tm,
   tempreply->cv_proc[proc_cnt].catalog_cd = p.catalog_cd, tempreply->cv_proc[proc_cnt].cv_proc_id =
   p.cv_proc_id, tempreply->cv_proc[proc_cnt].encntr_id = p.encntr_id,
   tempreply->cv_proc[proc_cnt].group_event_id = p.group_event_id, tempreply->cv_proc[proc_cnt].
   order_id = p.order_id, tempreply->cv_proc[proc_cnt].order_physician_id = p.order_physician_id,
   tempreply->cv_proc[proc_cnt].person_id = p.person_id, tempreply->cv_proc[proc_cnt].phys_group_id
    = p.phys_group_id, tempreply->cv_proc[proc_cnt].prim_physician_id = p.prim_physician_id,
   tempreply->cv_proc[proc_cnt].priority_cd = p.priority_cd, tempreply->cv_proc[proc_cnt].
   proc_status_cd = p.proc_status_cd, tempreply->cv_proc[proc_cnt].reason_for_proc = p
   .reason_for_proc,
   tempreply->cv_proc[proc_cnt].refer_physician_id = p.refer_physician_id, tempreply->cv_proc[
   proc_cnt].request_dt_tm = p.request_dt_tm, tempreply->cv_proc[proc_cnt].activity_subtype_cd = p
   .activity_subtype_cd,
   tempreply->cv_proc[proc_cnt].sequence = p.sequence, tempreply->cv_proc[proc_cnt].updt_cnt = p
   .updt_cnt, tempreply->cv_proc[proc_cnt].ed_review_ind = p.ed_review_ind,
   tempreply->cv_proc[proc_cnt].proc_indicator = p.proc_indicator, tempreply->cv_proc[proc_cnt].
   orig_order_dt_tm = p.orig_order_dt_tm, tempreply->cv_proc[proc_cnt].proc_normalcy_cd = p
   .normalcy_cd,
   tempreply->cv_proc[proc_cnt].stress_ecg_status_cd = p.stress_ecg_status_cd, tempreply->cv_proc[
   proc_cnt].study_state_cd = p.study_state_cd
  FOOT REPORT
   stat = alterlist(tempreply->cv_proc,proc_cnt)
  WITH expand = 1, nocounter
 ;end select
 CALL echo(build2("initial proc count in cv_fetch_procs is ",proc_cnt))
 IF (size(tempreply->cv_proc,5)=0)
  CALL cv_log_stat(cv_info,"SELECT","Z","CV_PROC","")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (bapplyencountersecurity=1)
  SET filteredproccnts = size(tempreply->cv_proc,5)
  SET procbatchsize = ceil((cnvtreal(filteredproccnts)/ g_pagesize))
  IF (procbatchsize < 0)
   SET procbatchsize = 1
   SET g_pagesize = 1
  ENDIF
  FOR (batchidx = 1 TO procbatchsize)
    IF (size(reply->cv_proc,5) < g_pagesize)
     IF (filteredproccnts <= g_pagesize)
      SET endindx = filteredproccnts
     ENDIF
     CALL filterprocbypagesize(beginindx,endindx)
     SET beginindx = (endindx+ 1)
     SET endindx = ((beginindx+ g_pagesize) - 1)
     IF (endindx >= filteredproccnts)
      SET endindx = filteredproccnts
     ENDIF
    ELSE
     SET stat = alterlist(reply->cv_proc,g_pagesize)
    ENDIF
  ENDFOR
  IF (size(reply->cv_proc,5) > g_pagesize)
   SET stat = alterlist(reply->cv_proc,g_pagesize)
  ENDIF
  SET g_pagesize = - (1)
 ELSE
  DECLARE itempproccnts = i4 WITH noconstant(0)
  SET filteredproccnts = size(tempreply->cv_proc,5)
  SET stat = alterlist(reply->cv_proc,filteredproccnts)
  FOR (itempproccnts = 1 TO filteredproccnts)
    CALL fillcvreply(itempproccnts,itempproccnts)
  ENDFOR
  IF (g_pagesize > 0)
   IF (filteredproccnts > g_pagesize)
    SET stat = alterlist(reply->cv_proc,g_pagesize)
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE (filterprocbypagesize(beginidx=i4,endidx=i4) =null WITH protect)
   DECLARE encntraccessidx = i4 WITH noconstant(0)
   DECLARE tempproccnt = i4 WITH noconstant(0)
   DECLARE replyproccnt = i4 WITH noconstant(0)
   DECLARE encntridx = i4 WITH noconstant(0)
   DECLARE enc_access_check_count = i4 WITH noconstant(0)
   EXECUTE cv_check_enc_access_req  WITH replace("CEAR_REQUEST",cear_request), replace("CEAR_REPLY",
    cear_reply)
   IF ((request->prsnl_id > 0.0))
    SET cear_request->prsnl_id = request->prsnl_id
   ELSE
    SET cear_request->prsnl_id = reqinfo->updt_id
   ENDIF
   SET proc_cnt = ((endidx - beginidx)+ 1)
   FOR (proc_idx = beginidx TO endidx)
     IF ((tempreply->cv_proc[proc_idx].encntr_id > 0.0))
      SET encntridx = locateval(encntridx,1,size(reply->cv_proc,5),tempreply->cv_proc[proc_idx].
       encntr_id,reply->cv_proc[encntridx].encntr_id)
      IF (encntridx > 0)
       IF (size(reply->cv_proc,5) < g_pagesize)
        SET replyproccnt = (size(reply->cv_proc,5)+ 1)
        SET stat = alterlist(reply->cv_proc,replyproccnt)
        CALL fillcvreply(replyproccnt,proc_idx)
       ENDIF
      ELSE
       SET tempproccnt += 1
       SET stat = alterlist(cear_request->encounter,tempproccnt)
       SET cear_request->encounter[tempproccnt].encntr_id = tempreply->cv_proc[proc_idx].encntr_id
       SET cear_request->encounter[tempproccnt].person_id = tempreply->cv_proc[proc_idx].person_id
       SET enc_access_check_count += 1
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(cear_request->encounter,enc_access_check_count)
   IF (enc_access_check_count > 0
    AND size(reply->cv_proc,5) < g_pagesize)
    EXECUTE cv_check_enc_access  WITH replace("REQUEST",cear_request), replace("REPLY",cear_reply)
    FOR (proc_idx = beginidx TO endidx)
     SET encntraccessidx = locateval(encntraccessidx,1,size(cear_reply->encounter,5),tempreply->
      cv_proc[proc_idx].encntr_id,cear_reply->encounter[encntraccessidx].encntr_id)
     IF (encntraccessidx > 0)
      IF ((cear_reply->encounter[encntraccessidx].access_ind=1))
       IF (size(reply->cv_proc,5) < g_pagesize)
        SET replyproccnt = (size(reply->cv_proc,5)+ 1)
        SET stat = alterlist(reply->cv_proc,replyproccnt)
        CALL fillcvreply(replyproccnt,proc_idx)
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (fillcvreply(toindex=i4,fromindex=i4) =null WITH protect)
   SET reply->cv_proc[toindex].accession = tempreply->cv_proc[fromindex].accession
   SET reply->cv_proc[toindex].accession_id = tempreply->cv_proc[fromindex].accession_id
   SET reply->cv_proc[toindex].action_dt_tm = tempreply->cv_proc[fromindex].action_dt_tm
   SET reply->cv_proc[toindex].catalog_cd = tempreply->cv_proc[fromindex].catalog_cd
   SET reply->cv_proc[toindex].cv_proc_id = tempreply->cv_proc[fromindex].cv_proc_id
   SET reply->cv_proc[toindex].encntr_id = tempreply->cv_proc[fromindex].encntr_id
   SET reply->cv_proc[toindex].group_event_id = tempreply->cv_proc[fromindex].group_event_id
   SET reply->cv_proc[toindex].order_id = tempreply->cv_proc[fromindex].order_id
   SET reply->cv_proc[toindex].order_physician_id = tempreply->cv_proc[fromindex].order_physician_id
   SET reply->cv_proc[toindex].person_id = tempreply->cv_proc[fromindex].person_id
   SET reply->cv_proc[toindex].phys_group_id = tempreply->cv_proc[fromindex].phys_group_id
   SET reply->cv_proc[toindex].prim_physician_id = tempreply->cv_proc[fromindex].prim_physician_id
   SET reply->cv_proc[toindex].priority_cd = tempreply->cv_proc[fromindex].priority_cd
   SET reply->cv_proc[toindex].proc_status_cd = tempreply->cv_proc[fromindex].proc_status_cd
   SET reply->cv_proc[toindex].reason_for_proc = tempreply->cv_proc[fromindex].reason_for_proc
   SET reply->cv_proc[toindex].refer_physician_id = tempreply->cv_proc[fromindex].refer_physician_id
   SET reply->cv_proc[toindex].request_dt_tm = tempreply->cv_proc[fromindex].request_dt_tm
   SET reply->cv_proc[toindex].activity_subtype_cd = tempreply->cv_proc[fromindex].
   activity_subtype_cd
   SET reply->cv_proc[toindex].sequence = tempreply->cv_proc[fromindex].sequence
   SET reply->cv_proc[toindex].updt_cnt = tempreply->cv_proc[fromindex].updt_cnt
   SET reply->cv_proc[toindex].ed_review_ind = tempreply->cv_proc[fromindex].ed_review_ind
   SET reply->cv_proc[toindex].proc_indicator = tempreply->cv_proc[fromindex].proc_indicator
   SET reply->cv_proc[toindex].orig_order_dt_tm = tempreply->cv_proc[fromindex].orig_order_dt_tm
   SET reply->cv_proc[toindex].proc_normalcy_cd = tempreply->cv_proc[fromindex].proc_normalcy_cd
   SET reply->cv_proc[toindex].stress_ecg_status_cd = tempreply->cv_proc[fromindex].
   stress_ecg_status_cd
   SET reply->cv_proc[toindex].study_state_cd = tempreply->cv_proc[fromindex].study_state_cd
 END ;Subroutine
 IF ((reqdata->loglevel >= cv_debug))
  CALL cv_log_msg(cv_debug,concat("proc count in cv_fetch_procs before steps are loaded is ",
    cnvtstring(size(reply->cv_proc,5))))
 ENDIF
 IF (g_no_steps_ind != 1)
  SET proc_cnt = size(reply->cv_proc,5)
  IF (proc_cnt > 1)
   SET padded_size = (proc_cnt+ ((block_size - 1) - mod((proc_cnt - 1),block_size)))
   SET stat = alterlist(reply->cv_proc,padded_size)
   FOR (proc_idx = (proc_cnt+ 1) TO padded_size)
     SET reply->cv_proc[proc_idx].cv_proc_id = reply->cv_proc[proc_cnt].cv_proc_id
   ENDFOR
  ENDIF
  SELECT
   IF (proc_cnt > 1)
    l_block_start = (((d.seq - 1) * block_size)+ 1)
    FROM cv_step_ref csr,
     cv_step cs,
     (dummyt d  WITH seq = value((padded_size/ block_size)))
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
     JOIN (cs
     WHERE expand(proc_idx,nstart,((nstart+ block_size) - 1),cs.cv_proc_id,reply->cv_proc[proc_idx].
      cv_proc_id))
     JOIN (csr
     WHERE csr.task_assay_cd=cs.task_assay_cd)
   ELSE
   ENDIF
   INTO "nl:"
   l_block_start = 1
   FROM cv_step_ref csr,
    cv_step cs
   PLAN (cs
    WHERE (cs.cv_proc_id=reply->cv_proc[1].cv_proc_id))
    JOIN (csr
    WHERE csr.task_assay_cd=cs.task_assay_cd)
   ORDER BY cs.cv_proc_id, cs.sequence
   HEAD cs.cv_proc_id
    l_step_cnt = 0, proc_idx = locateval(proc_idx,l_block_start,proc_cnt,cs.cv_proc_id,reply->
     cv_proc[proc_idx].cv_proc_id)
    IF (proc_idx=0)
     CALL cv_log_stat(cv_error,"LOCATEVAL","F","REPLY",build("CV_PROC_ID=",cs.cv_proc_id))
    ENDIF
   DETAIL
    IF (proc_idx > 0)
     l_step_cnt += 1
     IF (mod(l_step_cnt,3)=1)
      stat = alterlist(reply->cv_proc[proc_idx].cv_step,(l_step_cnt+ 2))
     ENDIF
     IF (((cs.cv_step_ind=0) OR (req_fetch_inactive_steps=1)) )
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].activity_subtype_cd = csr.activity_subtype_cd,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].cv_step_id = cs.cv_step_id, reply->cv_proc[
      proc_idx].cv_step[l_step_cnt].event_id = cs.event_id,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].proc_status_cd = csr.proc_status_cd, reply->
      cv_proc[proc_idx].cv_step[l_step_cnt].schedule_ind = csr.schedule_ind, reply->cv_proc[proc_idx]
      .cv_step[l_step_cnt].sequence = cs.sequence,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].step_level_flag = csr.step_level_flag, reply->
      cv_proc[proc_idx].cv_step[l_step_cnt].step_status_cd = cs.step_status_cd
      IF (cs.step_status_cd=step_stat_notstarted)
       reply->cv_proc[proc_idx].cv_step[l_step_cnt].doc_id_str = csr.doc_id_str, reply->cv_proc[
       proc_idx].cv_step[l_step_cnt].doc_type_cd = csr.doc_type_cd, reply->cv_proc[proc_idx].cv_step[
       l_step_cnt].doc_template_id = csr.doc_template_id
      ELSE
       reply->cv_proc[proc_idx].cv_step[l_step_cnt].doc_id_str = cs.cv_doc_id_str, reply->cv_proc[
       proc_idx].cv_step[l_step_cnt].doc_type_cd = cs.cv_doc_type_cd, reply->cv_proc[proc_idx].
       cv_step[l_step_cnt].doc_template_id = cs.cv_doc_template_id
      ENDIF
      IF (cs.cv_doc_type_cd=0.0)
       reply->cv_proc[proc_idx].cv_step[l_step_cnt].doc_id_str = csr.doc_id_str, reply->cv_proc[
       proc_idx].cv_step[l_step_cnt].doc_type_cd = csr.doc_type_cd, reply->cv_proc[proc_idx].cv_step[
       l_step_cnt].doc_template_id = csr.doc_template_id
      ENDIF
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].task_assay_cd = cs.task_assay_cd, reply->cv_proc[
      proc_idx].cv_step[l_step_cnt].updt_cnt = cs.updt_cnt, reply->cv_proc[proc_idx].cv_step[
      l_step_cnt].perf_loc_cd = cs.perf_loc_cd,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].perf_provider_id = cs.perf_provider_id, reply->
      cv_proc[proc_idx].cv_step[l_step_cnt].perf_start_dt_tm = cs.perf_start_dt_tm, reply->cv_proc[
      proc_idx].cv_step[l_step_cnt].perf_stop_dt_tm = cs.perf_stop_dt_tm,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].lock_prsnl_id = cs.lock_prsnl_id, reply->cv_proc[
      proc_idx].cv_step[l_step_cnt].step_type_cd = csr.step_type_cd
      IF (cs.lock_prsnl_id > 0)
       reply->cv_proc[proc_idx].cv_step[l_step_cnt].lock_updt_dt_tm = cs.updt_dt_tm
      ENDIF
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].step_resident_id = cs.preliminary_author_id, reply
      ->cv_proc[proc_idx].cv_step[l_step_cnt].modality_cd = cs.modality_cd, reply->cv_proc[proc_idx].
      cv_step[l_step_cnt].vendor_cd = cs.vendor_cd,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].study_dt_tm = cs.study_dt_tm, reply->cv_proc[
      proc_idx].cv_step[l_step_cnt].study_identifier = cs.study_identifier, reply->cv_proc[proc_idx].
      cv_step[l_step_cnt].pdf_doc_identifier = cs.pdf_doc_identifier,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].normalcy_cd = cs.normalcy_cd
     ENDIF
    ENDIF
   FOOT  cs.cv_proc_id
    stat = alterlist(reply->cv_proc[proc_idx].cv_step,l_step_cnt)
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->cv_proc,proc_cnt)
  CALL echo(build2("proc count in cv_fetch_procs after steps are loaded is ",proc_cnt))
 ENDIF
 CALL getschedreply(0)
 SET proc_cnt = size(reply->cv_proc,5)
 IF (proc_cnt > 0)
  SET nstart = 1
  SET locate_idx = 0
  DECLARE found_idx = i4 WITH noconstant(0)
  DECLARE ed_record_cnt = i4 WITH noconstant(0)
  SET stat = initrec(ed_review_info)
  SET stat = alterlist(ed_review_info->orderlist,proc_cnt)
  FOR (var_idx = 1 TO proc_cnt)
    IF ((reply->cv_proc[var_idx].ed_review_ind=1))
     SET ed_record_cnt += 1
     SET ed_review_info->orderlist[ed_record_cnt].order_id = reply->cv_proc[var_idx].order_id
     SET ed_review_info->orderlist[ed_record_cnt].insert_idx = var_idx
    ENDIF
  ENDFOR
  IF (ed_record_cnt > 0)
   SET var_pad = (ceil((cnvtreal(ed_record_cnt)/ block_size)) * block_size)
   SET stat = alterlist(ed_review_info->orderlist,var_pad)
   FOR (idx = (ed_record_cnt+ 1) TO var_pad)
    SET ed_review_info->orderlist[idx].order_id = ed_review_info->orderlist[ed_record_cnt].order_id
    SET ed_review_info->orderlist[idx].insert_idx = ed_review_info->orderlist[ed_record_cnt].
    insert_idx
   ENDFOR
   SELECT INTO "nl:"
    FROM cv_ed_review cer,
     (dummyt d  WITH seq = value((var_pad/ block_size)))
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
     JOIN (cer
     WHERE expand(var_idx,nstart,(nstart+ (block_size - 1)),cer.order_id,ed_review_info->orderlist[
      var_idx].order_id)
      AND cer.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    DETAIL
     found_idx = locateval(locate_idx,1,ed_record_cnt,cer.order_id,ed_review_info->orderlist[
      locate_idx].order_id)
     IF (found_idx > 0)
      reply->cv_proc[ed_review_info->orderlist[found_idx].insert_idx].ed_review_status_cd = cer
      .review_status_cd, reply->cv_proc[ed_review_info->orderlist[found_idx].insert_idx].
      ed_requestor_prsnl_id = cer.requestor_prsnl_id, reply->cv_proc[ed_review_info->orderlist[
      found_idx].insert_idx].ed_request_dt_tm = cer.request_dt_tm
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  CALL echo(build2("proc count in cv_fetch_procs after getting ed review info is ",proc_cnt))
 ENDIF
 SUBROUTINE getschedreply(dummy)
  SET proc_count = size(reply->cv_proc,5)
  FOR (proc_index = 1 TO proc_count)
   SET step_count = size(reply->cv_proc[proc_index].cv_step,5)
   FOR (step_index = 1 TO step_count)
    SET stat = alterlist(reply->cv_proc[proc_index].cv_step[step_index].cv_step_sched,1)
    SELECT INTO "nl:"
     FROM cv_step_sched css
     WHERE (css.cv_step_id=reply->cv_proc[proc_index].cv_step[step_index].cv_step_id)
     DETAIL
      reply->cv_proc[proc_index].cv_step[step_index].cv_step_sched[1].arrive_dt_tm = css.arrive_dt_tm,
      reply->cv_proc[proc_index].cv_step[step_index].cv_step_sched[1].arrive_ind = css.arrive_ind,
      reply->cv_proc[proc_index].cv_step[step_index].cv_step_sched[1].cv_step_sched_id = css
      .cv_step_sched_id,
      reply->cv_proc[proc_index].cv_step[step_index].cv_step_sched[1].sched_loc_cd = css.sched_loc_cd,
      reply->cv_proc[proc_index].cv_step[step_index].cv_step_sched[1].sched_phys_id = css
      .sched_phys_id, reply->cv_proc[proc_index].cv_step[step_index].cv_step_sched[1].
      sched_start_dt_tm = css.sched_start_dt_tm,
      reply->cv_proc[proc_index].cv_step[step_index].cv_step_sched[1].sched_stop_dt_tm = css
      .sched_stop_dt_tm, reply->cv_proc[proc_index].cv_step[step_index].cv_step_sched[1].updt_cnt =
      css.updt_cnt
     WITH nocounter
    ;end select
   ENDFOR
  ENDFOR
 END ;Subroutine
 SUBROUTINE getrescheduledprocs(dummy)
   SELECT INTO "nl:"
    FROM cv_proc p
    PLAN (p
     WHERE p.action_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(g_act_stop_dt_tm))
    HEAD REPORT
     stat = alterlist(filteredcvprocids->qual,100)
    DETAIL
     alter_list_cnt += 1
     IF (alter_list_cnt > 100
      AND mod(alter_list_cnt,100)=1)
      stat = alterlist(filteredcvprocids->qual,(99+ alter_list_cnt))
     ENDIF
     filteredcvprocids->qual[alter_list_cnt].cv_proc_id = p.cv_proc_id, filteredcvprocids->qual[
     alter_list_cnt].stress_ecg_status_cd = p.stress_ecg_status_cd
    FOOT REPORT
     stat = alterlist(filteredcvprocids->qual,alter_list_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM cv_proc p,
     cv_step_sched s
    PLAN (s
     WHERE s.sched_start_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(
      g_act_stop_dt_tm))
     JOIN (p
     WHERE p.cv_proc_id=s.cv_proc_id)
    HEAD REPORT
     stat = alterlist(filteredcvprocids->qual,(alter_list_cnt+ 100))
    DETAIL
     alter_list_cnt += 1
     IF (alter_list_cnt > 100
      AND mod(alter_list_cnt,100)=1)
      stat = alterlist(filteredcvprocids->qual,(99+ alter_list_cnt))
     ENDIF
     filteredcvprocids->qual[alter_list_cnt].cv_proc_id = p.cv_proc_id, filteredcvprocids->qual[
     alter_list_cnt].stress_ecg_status_cd = p.stress_ecg_status_cd
    FOOT REPORT
     stat = alterlist(filteredcvprocids->qual,alter_list_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM cv_proc p
    WHERE  NOT ( EXISTS (
    (SELECT
     1
     FROM cv_step_sched s
     WHERE s.cv_proc_id=p.cv_proc_id)))
     AND p.action_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(g_act_stop_dt_tm)
    HEAD REPORT
     stat = alterlist(filteredcvprocids->qual,(alter_list_cnt+ 100))
    DETAIL
     alter_list_cnt += 1
     IF (alter_list_cnt > 100
      AND mod(alter_list_cnt,100)=1)
      stat = alterlist(filteredcvprocids->qual,(99+ alter_list_cnt))
     ENDIF
     filteredcvprocids->qual[alter_list_cnt].cv_proc_id = p.cv_proc_id, filteredcvprocids->qual[
     alter_list_cnt].stress_ecg_status_cd = p.stress_ecg_status_cd
    FOOT REPORT
     stat = alterlist(filteredcvprocids->qual,alter_list_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE filteronstressecgstatus(dummy)
   DECLARE stress_var_idx = i4 WITH private
   DECLARE temp_proc_idx = i4 WITH private
   DECLARE filteredcvprocids_cnt = i4 WITH private
   SET filteredcvprocids_cnt = size(filteredcvprocids->qual,5)
   IF ((reqdata->loglevel >= cv_debug))
    CALL cv_log_msg(cv_debug,concat("filteredCVProcIds count before FilterOnStressEcgStatus()is ",
      cnvtstring(filteredcvprocids_cnt)))
   ENDIF
   IF (filteredcvprocids_cnt > 0)
    SET temp_proc_idx = 0
    SET stat = copyrec(filteredcvprocids,tempfilteredcvprocids,1)
    FOR (stress_var_idx = 1 TO req_stress_ecg_status_cnt)
     SET proc_idx = locateval(proc_idx,1,filteredcvprocids_cnt,request->stress_ecg_status[
      stress_var_idx].stress_ecg_status_cd,tempfilteredcvprocids->qual[proc_idx].stress_ecg_status_cd
      )
     WHILE (proc_idx != 0)
       SET temp_proc_idx += 1
       IF (temp_proc_idx > 10
        AND mod(temp_proc_idx,10)=1)
        SET stat = alterlist(filteredcvprocids->qual,(9+ temp_proc_idx))
       ENDIF
       SET filteredcvprocids->qual[temp_proc_idx].cv_proc_id = tempfilteredcvprocids->qual[proc_idx].
       cv_proc_id
       SET filteredcvprocids->qual[temp_proc_idx].stress_ecg_status_cd = tempfilteredcvprocids->qual[
       proc_idx].stress_ecg_status_cd
       SET proc_idx = locateval(proc_idx,(proc_idx+ 1),filteredcvprocids_cnt,request->
        stress_ecg_status[stress_var_idx].stress_ecg_status_cd,tempfilteredcvprocids->qual[proc_idx].
        stress_ecg_status_cd)
     ENDWHILE
    ENDFOR
    SET stat = alterlist(filteredcvprocids->qual,temp_proc_idx)
    SET stat = alterlist(tempfilteredcvprocids->qual,0)
    SET alter_list_cnt = temp_proc_idx
   ENDIF
   IF ((reqdata->loglevel >= cv_debug))
    CALL cv_log_msg(cv_debug,concat("filteredCVProcIds count after FilterOnStressEcgStatus()is ",
      cnvtstring(temp_proc_idx)))
   ENDIF
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD ed_review_info
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_info,"No procs found")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="F"))
  CALL cv_log_msg(cv_warning,"Program error")
  CALL echorecord(request)
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="S"))
  CALL cv_log_msg(cv_debug,"Successfully found procs")
  IF ((reqdata->loglevel >= cv_debug))
   CALL echorecord(reply)
  ENDIF
  SET reqinfo->commit_ind = 1
 ELSE
  CALL cv_log_msg(cv_audit,"Unknown status")
  CALL echorecord(request)
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL cv_log_msg_post("051 10/10/2023 SS028138")
END GO
