CREATE PROGRAM cv_process_order:dba
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
 IF (validate(proc_stat_ordered)=0)
  DECLARE cs_proc_stat = i4 WITH constant(4000341), public
  DECLARE proc_stat_ordered = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"ORDERED")),
  public
  DECLARE proc_stat_scheduled = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"SCHEDULED")),
  public
  DECLARE proc_stat_arrived = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"ARRIVED")),
  public
  DECLARE proc_stat_inprocess = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"INPROCESS")),
  public
  DECLARE proc_stat_completed = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"COMPLETED")),
  public
  DECLARE proc_stat_discontinued = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,
    "DISCONTINUED")), public
  DECLARE proc_stat_cancelled = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"CANCELLED")),
  public
  DECLARE proc_stat_verified = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"VERIFIED")),
  public
  DECLARE proc_stat_unsigned = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"UNSIGNED")),
  public
  DECLARE proc_stat_signed = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"SIGNED")),
  public
  DECLARE proc_stat_edreview = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"EDREVIEW")),
  public
  DECLARE cs_step_stat = i4 WITH constant(4000440), public
  DECLARE step_stat_notstarted = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"NOTSTARTED"
    )), public
  DECLARE step_stat_inprocess = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"INPROCESS")),
  public
  DECLARE step_stat_saved = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"SAVED")), public
  DECLARE step_stat_unsigned = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"UNSIGNED")),
  public
  DECLARE step_stat_completed = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"COMPLETED")),
  public
  DECLARE step_stat_discontinued = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,
    "DISCONTINUED")), public
  DECLARE step_stat_cancelled = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"CANCELLED")),
  public
  DECLARE step_stat_edreview = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"EDREVIEW")),
  public
  DECLARE cs_edreview_stat = i4 WITH constant(4002463), public
  DECLARE edreview_stat_available = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,
    "AVAILABLE")), public
  DECLARE edreview_stat_agreed = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,"AGREED"
    )), public
  DECLARE edreview_stat_disagreed = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,
    "DISAGREED")), public
  DECLARE edreview_stat_acknowledged = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,
    "ACKNOWLEDGED")), public
  DECLARE edreview_stat_removed = f8 WITH constant(null), public
 ENDIF
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
  CALL cv_log_msg(cv_error,"No status block in defined reply")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE proc_size = i4 WITH protect, noconstant(0)
 DECLARE proc_idx = i4 WITH protect, noconstant(0)
 DECLARE step_idx = i4 WITH protect, noconstant(0)
 DECLARE ord_size = i4 WITH protect, noconstant(0)
 DECLARE ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE ord_idx = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE proc_reference_prefix = c8 WITH constant("CV_PROC:")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE event_changed_ind = i2 WITH protect
 DECLARE fetch_proc_changed_ind = i2 WITH protect
 DECLARE external_report_state_cd = f8 WITH protect, noconstant(0.0)
 DECLARE external_report_state = vc WITH noconstant(""), protect
 FREE RECORD order_event_req
 RECORD order_event_req(
   1 catalog_cd = f8
   1 order_id = f8
   1 accession_nbr = vc
   1 encntr_id = f8
   1 person_id = f8
   1 result_val = vc
   1 event_end_dt_tm = dq8
   1 event_start_dt_tm = dq8
   1 reference_nbr = vc
   1 event_cd = f8
   1 event_id = f8
   1 proc_status_cd = f8
   1 proc_normalcy_cd = f8
   1 verified_prsnl_id = f8
   1 order_prsnl_id = f8
   1 report_status_cd = f8
   1 modality_cd = f8
   1 study_state_cd = f8
   1 doc_type_cd = f8
   1 future_order_ind = i2
 )
 FREE RECORD order_event_rep
 RECORD order_event_rep(
   1 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD fetch_proc_req
 RECORD fetch_proc_req(
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
 FREE RECORD fetch_proc_rep
 RECORD fetch_proc_rep(
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
 IF (validate(request->orders) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","ORDERS")
  GO TO exit_script
 ENDIF
 SET ord_size = size(request->orders,5)
 IF (ord_size < 1)
  CALL cv_log_stat(cv_error,"SELECT","Z","REQUEST","ORDERS")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(fetch_proc_req->orders,ord_size)
 FOR (ord_idx = 1 TO ord_size)
   IF ((request->orders[ord_idx].order_id > 0.0))
    SET ord_cnt += 1
    SET fetch_proc_req->orders[ord_cnt].order_id = request->orders[ord_idx].order_id
   ENDIF
 ENDFOR
 IF (ord_cnt != ord_size)
  SET stat = alterlist(fetch_proc_req->orders,ord_cnt)
  SET ord_size = ord_cnt
  CALL cv_log_msg(cv_warning,"Request had an order with no order_id")
 ENDIF
 SET ord_cnt = 0
 SET fetch_proc_req->withlock_flag = 1
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc_req), replace("REPLY",fetch_proc_rep)
 SET proc_size = size(fetch_proc_rep->cv_proc,5)
 IF (proc_size < 1)
  CALL cv_log_stat(cv_error,"SELECT","Z","CV_PROC","")
  GO TO exit_script
 ENDIF
 IF (proc_size=1)
  IF ((request->calling_process_name="CVORDSRVSHR")
   AND (fetch_proc_rep->cv_proc[proc_size].group_event_id=0))
   CALL cv_log_msg(cv_debug,build("No clinical_event action due to future order group_event_id",
     fetch_proc_rep->cv_proc[proc_size].group_event_id))
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (ord_idx = 1 TO ord_size)
   SET stat = initrec(order_event_req)
   SET proc_idx = locateval(proc_idx,1,proc_size,request->orders[ord_idx].order_id,fetch_proc_rep->
    cv_proc[proc_idx].order_id)
   IF (proc_idx=0)
    CALL cv_log_stat(cv_debug,"VALIDATE","F","FETCH_PROC_REP",build("ORDER_ID=",order_event_req->
      order_id))
   ELSEIF ((fetch_proc_rep->cv_proc[proc_idx].encntr_id=0.0))
    CALL cv_log_msg(cv_debug,build("No clinical_event action due to encntr_id=0.0 for cv_proc_id=",
      fetch_proc_rep->cv_proc[proc_idx].cv_proc_id))
   ELSE
    SET order_event_req->catalog_cd = fetch_proc_rep->cv_proc[proc_idx].catalog_cd
    SET order_event_req->order_id = fetch_proc_rep->cv_proc[proc_idx].order_id
    SET order_event_req->accession_nbr = fetch_proc_rep->cv_proc[proc_idx].accession
    SET order_event_req->encntr_id = fetch_proc_rep->cv_proc[proc_idx].encntr_id
    SET order_event_req->person_id = fetch_proc_rep->cv_proc[proc_idx].person_id
    SET order_event_req->result_val = uar_get_code_display(fetch_proc_rep->cv_proc[proc_idx].
     proc_status_cd)
    SET order_event_req->proc_status_cd = fetch_proc_rep->cv_proc[proc_idx].proc_status_cd
    IF (validate(g_external_report_state)
     AND (fetch_proc_rep->cv_proc[proc_idx].proc_status_cd=proc_stat_signed))
     SET external_report_state = g_external_report_state
     SET external_report_state_cd = uar_get_code_by("DISPLAYKEY",4390006,replace(cnvtupper(
        external_report_state)," ","",0))
    ENDIF
    SET order_event_req->report_status_cd = external_report_state_cd
    SET order_event_req->modality_cd = fetch_proc_rep->cv_proc[proc_idx].activity_subtype_cd
    SET order_event_req->future_order_ind = request->orders[ord_idx].future_order_ind
    SELECT INTO "nl:"
     FROM im_study ims
     WHERE (ims.orig_entity_id=fetch_proc_rep->cv_proc[proc_idx].cv_proc_id)
      AND ims.orig_entity_name="CV_PROC"
     DETAIL
      order_event_req->study_state_cd = ims.study_state_cd
     WITH nocounter
    ;end select
    DECLARE final_step_prfmer = f8 WITH noconstant(0.0)
    SET order_event_req->order_prsnl_id = fetch_proc_rep->cv_proc[proc_idx].order_physician_id
    SET order_event_req->proc_normalcy_cd = fetch_proc_rep->cv_proc[proc_idx].proc_normalcy_cd
    IF (size(fetch_proc_rep->cv_proc[proc_idx].cv_step,5) > 0)
     FOR (step_idx = 1 TO size(fetch_proc_rep->cv_proc[proc_idx].cv_step,5))
       IF ((fetch_proc_rep->cv_proc[proc_idx].proc_status_cd=proc_stat_signed)
        AND (fetch_proc_rep->cv_proc[proc_idx].cv_step[step_idx].modified_ind=1))
        SET order_event_req->verified_prsnl_id = fetch_proc_rep->cv_proc[proc_idx].cv_step[step_idx].
        perf_provider_id
       ENDIF
       IF ((fetch_proc_rep->cv_proc[proc_idx].proc_status_cd=proc_stat_completed)
        AND (fetch_proc_rep->cv_proc[proc_idx].cv_step[step_idx].modified_ind=1))
        SET order_event_req->verified_prsnl_id = fetch_proc_rep->cv_proc[proc_idx].cv_step[step_idx].
        perf_provider_id
       ENDIF
       SET final_step_prfmer = fetch_proc_rep->cv_proc[proc_idx].cv_step[step_idx].perf_provider_id
       SET order_event_req->doc_type_cd = fetch_proc_rep->cv_proc[proc_idx].cv_step[step_idx].
       doc_type_cd
     ENDFOR
    ENDIF
    IF ((order_event_req->verified_prsnl_id <= 0.0))
     DECLARE cv_login_id = f8 WITH noconstant(0.0)
     DECLARE provider_id = f8 WITH noconstant(0.0)
     IF (validate(g_cv_login_id)
      AND validate(g_external_perf_provider_id))
      SET cv_login_id = g_cv_login_id
      SET provider_id = g_external_perf_provider_id
     ENDIF
     IF ((fetch_proc_rep->cv_proc[proc_idx].proc_status_cd=proc_stat_signed))
      IF (((cv_login_id=0.0
       AND provider_id > 0.0) OR (provider_id > 0.0)) )
       SET order_event_req->verified_prsnl_id = g_external_perf_provider_id
      ELSE
       SET order_event_req->verified_prsnl_id = final_step_prfmer
      ENDIF
     ELSE
      SET order_event_req->verified_prsnl_id = reqinfo->updt_id
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM code_value_event_r cver
     WHERE (cver.parent_cd=fetch_proc_rep->cv_proc[proc_idx].catalog_cd)
     DETAIL
      order_event_req->event_cd = cver.event_cd
     WITH nocounter
    ;end select
    IF ((order_event_req->event_cd=0.0))
     CALL cv_log_stat(cv_audit,"SELECT","F","CODE_VALUE_EVENT_R",build("CATALOG_CD=",fetch_proc_rep->
       cv_proc[proc_idx].catalog_cd))
    ELSEIF ((fetch_proc_rep->cv_proc[proc_idx].group_event_id=0.0))
     SET fetch_proc_changed_ind = 1
    ELSEIF ((fetch_proc_rep->cv_proc[proc_idx].group_event_id > 0.0))
     SET event_changed_ind = 0
     SELECT INTO "nl:"
      FROM clinical_event ce
      WHERE (ce.event_id=fetch_proc_rep->cv_proc[proc_idx].group_event_id)
       AND ce.valid_until_dt_tm=cnvtdatetime(null_dt_tm)
      DETAIL
       IF (((ce.event_end_dt_tm != cnvtdatetime(fetch_proc_rep->cv_proc[proc_idx].action_dt_tm)) OR (
       (ce.result_val != order_event_req->result_val))) )
        event_changed_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL cv_log_stat(cv_error,"SELECT","F","CLINICAL_EVENT",build("EVENT_ID=",fetch_proc_rep->
        cv_proc[proc_idx].group_event_id))
     ELSEIF (event_changed_ind=0)
      CALL cv_log_msg(cv_debug,"No update needed on clinical_event")
     ELSE
      SET order_event_req->event_id = fetch_proc_rep->cv_proc[proc_idx].group_event_id
      SET order_event_req->event_end_dt_tm = fetch_proc_rep->cv_proc[proc_idx].action_dt_tm
      SET order_event_req->event_start_dt_tm = fetch_proc_rep->cv_proc[proc_idx].action_dt_tm
      SET order_event_req->reference_nbr = concat(proc_reference_prefix,cnvtstring(fetch_proc_rep->
        cv_proc[proc_idx].cv_proc_id))
      IF ((order_event_req->future_order_ind=0))
       CALL cv_log_msg(cv_debug,
        "Incoming order is not future order. Hence upadtaing Clinical event table.")
       EXECUTE cv_upd_order_event  WITH replace("REQUEST",order_event_req), replace("REPLY",
        order_event_rep)
      ENDIF
      CALL echorecord(order_event_rep)
      IF ((order_event_rep->status_data.status != "S"))
       CALL cv_log_msg(cv_error,"Saving results to clinical_event table failed")
      ELSE
       IF ((order_event_rep->event_id != fetch_proc_rep->cv_proc[proc_idx].group_event_id))
        CALL cv_log_stat(cv_error,"SELECT","F","CV_PROC",concat("GROUP_EVENT_ID=",cnvtstring(
           fetch_proc_rep->cv_proc[proc_idx].group_event_id)))
       ELSE
        CALL cv_log_msg(cv_info,"Saving results to clinical_event table succeeded!")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (fetch_proc_changed_ind != 0)
  SET fetch_proc_rep->calling_process_name = request->calling_process_name
  EXECUTE cv_save_procs  WITH replace("REQUEST",fetch_proc_rep), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_msg(cv_error,"Call to CV_SAVE_PROCS failed")
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_PROCESS_ORDER failed!")
  CALL echorecord(reply)
  CALL echorecord(request)
  CALL echorecord(order_event_req)
  CALL echorecord(order_event_rep)
  CALL echorecord(fetch_proc_req)
  CALL echorecord(fetch_proc_rep)
  SET reqinfo->commit_ind = 0
 ELSE
  CALL cv_log_msg(cv_info,"CV_PROCESS_ORDER successful.")
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("035 05/24/22 TK095466")
END GO
