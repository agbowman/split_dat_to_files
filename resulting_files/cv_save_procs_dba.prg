CREATE PROGRAM cv_save_procs:dba
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
 DECLARE calcprocstatus(null) = null
 DECLARE updorderevents(null) = null
 DECLARE updorderstatus(null) = null
 DECLARE mscvprocobjname = vc WITH constant("cv_save_procs"), protect
 IF (validate(null_f8,0.0)=0.0)
  DECLARE null_f8 = f8 WITH constant(- (0.00001))
 ENDIF
 IF (validate(null_i2,0)=0)
  DECLARE null_i2 = i2 WITH constant(- (1))
 ENDIF
 IF (validate(null_i4,0)=0)
  DECLARE null_i4 = i4 WITH constant(- (1))
 ENDIF
 IF ((validate(null_dt,- (1.0))=- (1.0)))
  DECLARE null_dt = dq8 WITH constant(0.0)
 ENDIF
 IF (validate(null_vc,"Z")="Z")
  DECLARE null_vc = vc WITH constant("")
 ENDIF
 DECLARE cv_proc_size = i4 WITH protect, noconstant(size(request->cv_proc,5))
 DECLARE addproccnt = i4 WITH noconstant(0), protect
 DECLARE uptproccnt = i4 WITH noconstant(0), protect
 DECLARE addstepcnt = i4 WITH noconstant(0), protect
 DECLARE uptstepcnt = i4 WITH noconstant(0), protect
 DECLARE uptstepschedcnt = i4 WITH noconstant(0), protect
 DECLARE addstepschedcnt = i4 WITH noconstant(0), protect
 DECLARE cv_step_prsnl_size = i4 WITH noconstant(0), protect
 DECLARE requestcount = i4 WITH noconstant(0), protect
 DECLARE removecount = i4 WITH noconstant(0), protect
 DECLARE proc_reference_prefix = c8 WITH constant("CV_PROC:"), protect
 DECLARE time_now = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE proc_step_modifiedind = i2 WITH noconstant(0), protect
 DECLARE amended_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4390006,"AMENDED"))
 DECLARE reviewed_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4390006,"REVIEWED")
  )
 DECLARE qc_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4390006,"QC"))
 DECLARE externalreportstatecd = f8 WITH protect, noconstant(0.00)
 DECLARE order_action_id = f8 WITH protect, noconstant(0)
 DECLARE amended_stress_status = f8 WITH protect, constant(uar_get_code_by("MEANING",4000341,
   "AMENDED"))
 DECLARE step_type_finalreport_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "FINALREPORT"))
 DECLARE step_activity_subtype_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"ECG"))
 FREE RECORD addprocrec
 RECORD addprocrec(
   1 objarray[*]
     2 cv_proc_id = f8
     2 order_id = f8
     2 accession_id = f8
     2 accession = vc
     2 catalog_cd = f8
     2 order_physician_id = f8
     2 refer_physician_id = f8
     2 prim_physician_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 proc_status_cd = f8
     2 priority_cd = f8
     2 reason_for_proc = vc
     2 group_event_id = f8
     2 sequence = i4
     2 updt_cnt = i4
     2 phys_group_id = f8
     2 action_dt_tm = dq8
     2 action_dt_tm_null = i2
     2 request_dt_tm = dq8
     2 request_dt_tm_null = i2
     2 activity_subtype_cd = f8
     2 ed_review_ind = i2
     2 orig_order_dt_tm = dq8
 )
 FREE RECORD uptprocrec
 RECORD uptprocrec(
   1 objarray[*]
     2 cv_proc_id = f8
     2 order_id = f8
     2 accession_id = f8
     2 accession = vc
     2 catalog_cd = f8
     2 order_physician_id = f8
     2 refer_physician_id = f8
     2 prim_physician_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 proc_status_cd = f8
     2 priority_cd = f8
     2 reason_for_proc = vc
     2 group_event_id = f8
     2 sequence = i4
     2 updt_cnt = i4
     2 phys_group_id = f8
     2 action_dt_tm = dq8
     2 action_dt_tm_null = i2
     2 request_dt_tm = dq8
     2 request_dt_tm_null = i2
     2 activity_subtype_cd = f8
     2 ed_review_ind = i2
     2 normalcy_cd = f8
     2 stress_ecg_status_cd = f8
 )
 FREE RECORD addsteprec
 RECORD addsteprec(
   1 objarray[*]
     2 cv_step_id = f8
     2 cv_proc_id = f8
     2 task_assay_cd = f8
     2 event_id = f8
     2 updt_cnt = i4
     2 step_status_cd = f8
     2 sequence = i4
     2 perf_loc_cd = f8
     2 perf_provider_id = f8
     2 perf_start_dt_tm = dq8
     2 perf_start_dt_tm_null = i2
     2 perf_stop_dt_tm = dq8
     2 perf_stop_dt_tm_null = i2
     2 lock_prsnl_id = f8
     2 step_resident_id = f8
 )
 FREE RECORD uptsteprec
 RECORD uptsteprec(
   1 objarray[*]
     2 cv_step_id = f8
     2 cv_proc_id = f8
     2 task_assay_cd = f8
     2 event_id = f8
     2 updt_cnt = i4
     2 step_status_cd = f8
     2 sequence = i4
     2 perf_loc_cd = f8
     2 perf_provider_id = f8
     2 perf_start_dt_tm = dq8
     2 perf_start_dt_tm_null = i2
     2 perf_stop_dt_tm = dq8
     2 perf_stop_dt_tm_null = i2
     2 lock_prsnl_id = f8
     2 step_resident_id = f8
     2 cv_doc_type_cd = f8
     2 cv_doc_id_str = vc
     2 cv_doc_template_id = f8
     2 cv_step_ind = i2
     2 normalcy_cd = f8
 )
 FREE RECORD addstepschedrec
 RECORD addstepschedrec(
   1 objarray[*]
     2 cv_step_sched_id = f8
     2 cv_step_id = f8
     2 cv_proc_id = f8
     2 task_assay_cd = f8
     2 arrive_dt_tm = dq8
     2 arrive_dt_tm_null = i2
     2 arrive_ind = i2
     2 sched_loc_cd = f8
     2 sched_phys_id = f8
     2 sched_start_dt_tm = dq8
     2 sched_start_dt_tm_null = i2
     2 sched_stop_dt_tm = dq8
     2 sched_stop_dt_tm_null = i2
     2 updt_cnt = i4
 )
 FREE RECORD uptstepschedrec
 RECORD uptstepschedrec(
   1 objarray[*]
     2 cv_step_sched_id = f8
     2 cv_step_id = f8
     2 cv_proc_id = f8
     2 task_assay_cd = f8
     2 arrive_dt_tm = dq8
     2 arrive_dt_tm_null = i2
     2 arrive_ind = i2
     2 sched_loc_cd = f8
     2 sched_phys_id = f8
     2 sched_start_dt_tm = dq8
     2 sched_start_dt_tm_null = i2
     2 sched_stop_dt_tm = dq8
     2 sched_stop_dt_tm_null = i2
     2 updt_cnt = i4
 )
 FREE RECORD addstepprsnlrec
 RECORD addstepprsnlrec(
   1 objarray[*]
     2 cv_step_prsnl_id = f8
     2 cv_step_id = f8
     2 step_prsnl_id = f8
     2 step_relation_cd = f8
     2 action_type_cd = f8
     2 action_dt_tm = dq8
     2 action_dt_tm_null = i2
     2 action_sequence = i4
     2 updt_cnt = i4
 )
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
   1 ordered_dt_tm = dq8
   1 action_tz = i4
   1 order_action_tz = i4
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
 FREE RECORD orig_status
 RECORD orig_status(
   1 cv_proc[*]
     2 proc_status_cd = f8
     2 ed_review_ind = i2
 )
 FREE RECORD order_status_req
 RECORD order_status_req(
   1 person_id = f8
   1 orders[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 encntr_id = f8
     2 proc_status_cd = f8
     2 communication_type_cd = f8
     2 order_dt_tm = dq8
   1 order_action_tz = i4
 )
 FREE RECORD fetch_comm_type_req
 RECORD fetch_comm_type_req(
   1 cv_order_id = f8
 )
 FREE RECORD fetch_comm_type_reply
 RECORD fetch_comm_type_reply(
   1 communication_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
  CALL cv_log_stat(cv_error,"VALIDATE","F","REPLY","")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(orig_status->cv_proc,cv_proc_size)
 FOR (i = 1 TO cv_proc_size)
  SET orig_status->cv_proc[i].proc_status_cd = request->cv_proc[i].proc_status_cd
  SET orig_status->cv_proc[i].ed_review_ind = request->cv_proc[i].ed_review_ind
 ENDFOR
 CALL calcprocstatus(null)
 IF ((reply->status_data.status != "S"))
  GO TO exit_script
 ENDIF
 EXECUTE cv_request_ed_review_rr  WITH replace("REQUEST",reqrequestedreview), replace("REPLY",
  reprequestedreview)
 EXECUTE cv_remove_ed_review_rr  WITH replace("REQUEST",reqremoveedreview), replace("REPLY",
  repremoveedreview)
 SET reqrequestedreview->requestor_prsnl_id = reqinfo->updt_id
 IF (cv_proc_size > 0)
  SET stat = alterlist(addprocrec->objarray,cv_proc_size)
  SET stat = alterlist(uptprocrec->objarray,cv_proc_size)
  SET stat = alterlist(reqrequestedreview->orderlist,cv_proc_size)
  SET stat = alterlist(reqremoveedreview->orderlist,cv_proc_size)
  FOR (i = 1 TO cv_proc_size)
    IF ((request->cv_proc[i].modified_ind=1))
     IF ((orig_status->cv_proc[i].ed_review_ind != request->cv_proc[i].ed_review_ind))
      IF ((request->cv_proc[i].ed_review_ind=1))
       IF ((request->cv_proc[i].proc_status_cd=proc_stat_edreview))
        SET requestcount += 1
        SET reqrequestedreview->orderlist[i].order_id = request->cv_proc[i].order_id
       ENDIF
      ELSE
       IF ((request->cv_proc[i].ed_review_ind=0)
        AND (request->cv_proc[i].ed_review_status_cd=edreview_stat_available))
        SET removecount += 1
        SET reqremoveedreview->orderlist[i].order_id = request->cv_proc[i].order_id
       ENDIF
      ENDIF
     ENDIF
    ELSE
     IF ((request->cv_proc[i].ed_review_ind=1)
      AND (request->cv_proc[i].proc_status_cd=proc_stat_edreview))
      IF ((request->cv_proc[i].ed_review_status_cd=0.0))
       SET requestcount += 1
       SET reqrequestedreview->orderlist[i].order_id = request->cv_proc[i].order_id
      ENDIF
     ENDIF
    ENDIF
    IF ((request->cv_proc[i].proc_status_cd=proc_stat_ordered)
     AND (request->cv_proc[i].ed_review_status_cd > 0.0))
     SET removecount += 1
     SET reqremoveedreview->orderlist[i].order_id = request->cv_proc[i].order_id
    ELSEIF ((request->cv_proc[i].proc_status_cd=proc_stat_discontinued)
     AND (request->cv_proc[i].ed_review_status_cd > 0.0))
     SET removecount += 1
     SET reqremoveedreview->orderlist[i].order_id = request->cv_proc[i].order_id
    ENDIF
    IF ((request->cv_proc[i].cv_proc_id < 1.0)
     AND (request->cv_proc[i].modified_ind=1))
     SET addproccnt += 1
     SELECT INTO "nl:"
      proc_seq = seq(card_vas_seq,nextval)
      FROM dual d
      DETAIL
       request->cv_proc[i].cv_proc_id = proc_seq
      WITH format, counter
     ;end select
     SET addprocrec->objarray[addproccnt].cv_proc_id = request->cv_proc[i].cv_proc_id
     SET addprocrec->objarray[addproccnt].order_id = request->cv_proc[i].order_id
     SET addprocrec->objarray[addproccnt].accession_id = request->cv_proc[i].accession_id
     SET addprocrec->objarray[addproccnt].accession = request->cv_proc[i].accession
     SET addprocrec->objarray[addproccnt].catalog_cd = request->cv_proc[i].catalog_cd
     SET addprocrec->objarray[addproccnt].order_physician_id = request->cv_proc[i].order_physician_id
     SET addprocrec->objarray[addproccnt].refer_physician_id = request->cv_proc[i].refer_physician_id
     SET addprocrec->objarray[addproccnt].prim_physician_id = request->cv_proc[i].prim_physician_id
     SET addprocrec->objarray[addproccnt].person_id = request->cv_proc[i].person_id
     SET addprocrec->objarray[addproccnt].encntr_id = request->cv_proc[i].encntr_id
     SET addprocrec->objarray[addproccnt].proc_status_cd = request->cv_proc[i].proc_status_cd
     SET addprocrec->objarray[addproccnt].priority_cd = request->cv_proc[i].priority_cd
     SET addprocrec->objarray[addproccnt].reason_for_proc = request->cv_proc[i].reason_for_proc
     SET addprocrec->objarray[addproccnt].group_event_id = request->cv_proc[i].group_event_id
     SET addprocrec->objarray[addproccnt].sequence = request->cv_proc[i].sequence
     SET addprocrec->objarray[addproccnt].updt_cnt = request->cv_proc[i].updt_cnt
     SET addprocrec->objarray[addproccnt].phys_group_id = request->cv_proc[i].phys_group_id
     SET addprocrec->objarray[addproccnt].action_dt_tm = request->cv_proc[i].action_dt_tm
     SET addprocrec->objarray[addproccnt].activity_subtype_cd = request->cv_proc[i].
     activity_subtype_cd
     SET addprocrec->objarray[addproccnt].ed_review_ind = request->cv_proc[i].ed_review_ind
     IF ((request->cv_proc[i].action_dt_tm != null_dt))
      SET addprocrec->objarray[addproccnt].action_dt_tm_null = 0
     ELSE
      SET addprocrec->objarray[addproccnt].action_dt_tm_null = 1
     ENDIF
     SET addprocrec->objarray[addproccnt].request_dt_tm = request->cv_proc[i].request_dt_tm
     IF ((request->cv_proc[i].request_dt_tm != null_dt))
      SET addprocrec->objarray[addproccnt].request_dt_tm_null = 0
     ELSE
      SET addprocrec->objarray[addproccnt].request_dt_tm_null = 1
     ENDIF
     SET addprocrec->objarray[addproccnt].orig_order_dt_tm = request->cv_proc[i].orig_order_dt_tm
    ELSEIF ((request->cv_proc[i].cv_proc_id > 0.0)
     AND (request->cv_proc[i].modified_ind=1))
     SET uptproccnt += 1
     SET uptprocrec->objarray[uptproccnt].cv_proc_id = request->cv_proc[i].cv_proc_id
     SET uptprocrec->objarray[uptproccnt].order_id = request->cv_proc[i].order_id
     SET uptprocrec->objarray[uptproccnt].accession_id = request->cv_proc[i].accession_id
     SET uptprocrec->objarray[uptproccnt].accession = request->cv_proc[i].accession
     SET uptprocrec->objarray[uptproccnt].catalog_cd = request->cv_proc[i].catalog_cd
     SET uptprocrec->objarray[uptproccnt].order_physician_id = request->cv_proc[i].order_physician_id
     SET uptprocrec->objarray[uptproccnt].refer_physician_id = request->cv_proc[i].refer_physician_id
     SET uptprocrec->objarray[uptproccnt].prim_physician_id = request->cv_proc[i].prim_physician_id
     SET uptprocrec->objarray[uptproccnt].person_id = request->cv_proc[i].person_id
     SET uptprocrec->objarray[uptproccnt].encntr_id = request->cv_proc[i].encntr_id
     SET uptprocrec->objarray[uptproccnt].proc_status_cd = request->cv_proc[i].proc_status_cd
     SET uptprocrec->objarray[uptproccnt].priority_cd = request->cv_proc[i].priority_cd
     SET uptprocrec->objarray[uptproccnt].reason_for_proc = request->cv_proc[i].reason_for_proc
     SET uptprocrec->objarray[uptproccnt].group_event_id = request->cv_proc[i].group_event_id
     SET uptprocrec->objarray[uptproccnt].sequence = request->cv_proc[i].sequence
     SET uptprocrec->objarray[uptproccnt].updt_cnt = request->cv_proc[i].updt_cnt
     SET uptprocrec->objarray[uptproccnt].phys_group_id = request->cv_proc[i].phys_group_id
     SET uptprocrec->objarray[uptproccnt].action_dt_tm = request->cv_proc[i].action_dt_tm
     SET uptprocrec->objarray[uptproccnt].activity_subtype_cd = request->cv_proc[i].
     activity_subtype_cd
     SET uptprocrec->objarray[uptproccnt].ed_review_ind = request->cv_proc[i].ed_review_ind
     SET uptprocrec->objarray[uptproccnt].stress_ecg_status_cd = request->cv_proc[i].
     stress_ecg_status_cd
     IF ((request->cv_proc[i].action_dt_tm != null_dt))
      SET uptprocrec->objarray[uptproccnt].action_dt_tm_null = 0
     ELSE
      SET uptprocrec->objarray[uptproccnt].action_dt_tm_null = 1
     ENDIF
     SET uptprocrec->objarray[uptproccnt].request_dt_tm = request->cv_proc[i].request_dt_tm
     IF ((request->cv_proc[i].request_dt_tm != null_dt))
      SET uptprocrec->objarray[uptproccnt].request_dt_tm_null = 0
     ELSE
      SET uptprocrec->objarray[uptproccnt].request_dt_tm_null = 1
     ENDIF
     SET uptprocrec->objarray[uptproccnt].normalcy_cd = request->cv_proc[i].proc_normalcy_cd
    ELSEIF ((request->cv_proc[i].cv_step[1].schedule_ind=1)
     AND (request->cv_proc[i].cv_step[1].cv_step_sched[1].cv_step_sched_id > 0.0)
     AND (request->cv_proc[i].cv_step[1].cv_step_sched[1].modified_ind=1))
     SET uptproccnt += 1
     SET uptprocrec->objarray[uptproccnt].cv_proc_id = request->cv_proc[i].cv_proc_id
     SET uptprocrec->objarray[uptproccnt].order_id = request->cv_proc[i].order_id
     SET uptprocrec->objarray[uptproccnt].accession_id = request->cv_proc[i].accession_id
     SET uptprocrec->objarray[uptproccnt].accession = request->cv_proc[i].accession
     SET uptprocrec->objarray[uptproccnt].catalog_cd = request->cv_proc[i].catalog_cd
     SET uptprocrec->objarray[uptproccnt].order_physician_id = request->cv_proc[i].order_physician_id
     SET uptprocrec->objarray[uptproccnt].refer_physician_id = request->cv_proc[i].refer_physician_id
     SET uptprocrec->objarray[uptproccnt].prim_physician_id = request->cv_proc[i].prim_physician_id
     SET uptprocrec->objarray[uptproccnt].person_id = request->cv_proc[i].person_id
     SET uptprocrec->objarray[uptproccnt].encntr_id = request->cv_proc[i].encntr_id
     SET uptprocrec->objarray[uptproccnt].proc_status_cd = request->cv_proc[i].proc_status_cd
     SET uptprocrec->objarray[uptproccnt].priority_cd = request->cv_proc[i].priority_cd
     SET uptprocrec->objarray[uptproccnt].reason_for_proc = request->cv_proc[i].reason_for_proc
     SET uptprocrec->objarray[uptproccnt].group_event_id = request->cv_proc[i].group_event_id
     SET uptprocrec->objarray[uptproccnt].sequence = request->cv_proc[i].sequence
     SET uptprocrec->objarray[uptproccnt].updt_cnt = request->cv_proc[i].updt_cnt
     SET uptprocrec->objarray[uptproccnt].phys_group_id = request->cv_proc[i].phys_group_id
     SET uptprocrec->objarray[uptproccnt].action_dt_tm = request->cv_proc[i].action_dt_tm
     SET uptprocrec->objarray[uptproccnt].activity_subtype_cd = request->cv_proc[i].
     activity_subtype_cd
     SET uptprocrec->objarray[uptproccnt].ed_review_ind = request->cv_proc[i].ed_review_ind
     SET uptprocrec->objarray[uptproccnt].stress_ecg_status_cd = request->cv_proc[i].
     stress_ecg_status_cd
     IF ((request->cv_proc[i].action_dt_tm != null_dt))
      SET uptprocrec->objarray[uptproccnt].action_dt_tm_null = 0
     ELSE
      SET uptprocrec->objarray[uptproccnt].action_dt_tm_null = 1
     ENDIF
     SET uptprocrec->objarray[uptproccnt].request_dt_tm = request->cv_proc[i].request_dt_tm
     IF ((request->cv_proc[i].request_dt_tm != null_dt))
      SET uptprocrec->objarray[uptproccnt].request_dt_tm_null = 0
     ELSE
      SET uptprocrec->objarray[uptproccnt].request_dt_tm_null = 1
     ENDIF
     SET uptprocrec->objarray[uptproccnt].normalcy_cd = request->cv_proc[i].proc_normalcy_cd
    ENDIF
    IF (size(request->cv_proc[i].cv_step,5) > 0)
     FOR (j = 1 TO size(request->cv_proc[i].cv_step,5))
      IF ((request->cv_proc[i].cv_step[j].cv_step_id < 1.0)
       AND (request->cv_proc[i].cv_step[j].modified_ind=1))
       SET addstepcnt += 1
       SET stat = alterlist(addsteprec->objarray,addstepcnt)
       SELECT INTO "nl:"
        step_seq = seq(card_vas_seq,nextval)
        FROM dual d
        DETAIL
         request->cv_proc[i].cv_step[j].cv_step_id = step_seq
        WITH format, counter
       ;end select
       SET addsteprec->objarray[addstepcnt].cv_step_id = request->cv_proc[i].cv_step[j].cv_step_id
       SET addsteprec->objarray[addstepcnt].cv_proc_id = request->cv_proc[i].cv_proc_id
       SET addsteprec->objarray[addstepcnt].task_assay_cd = request->cv_proc[i].cv_step[j].
       task_assay_cd
       SET addsteprec->objarray[addstepcnt].event_id = request->cv_proc[i].cv_step[j].event_id
       SET addsteprec->objarray[addstepcnt].updt_cnt = request->cv_proc[i].cv_step[j].updt_cnt
       SET addsteprec->objarray[addstepcnt].step_status_cd = request->cv_proc[i].cv_step[j].
       step_status_cd
       SET addsteprec->objarray[addstepcnt].sequence = request->cv_proc[i].cv_step[j].sequence
       SET addsteprec->objarray[addstepcnt].perf_loc_cd = request->cv_proc[i].cv_step[j].perf_loc_cd
       SET addsteprec->objarray[addstepcnt].perf_provider_id = request->cv_proc[i].cv_step[j].
       perf_provider_id
       SET addsteprec->objarray[addstepcnt].perf_start_dt_tm = request->cv_proc[i].cv_step[j].
       perf_start_dt_tm
       IF ((request->cv_proc[i].cv_step[j].perf_start_dt_tm != null_dt))
        SET addsteprec->objarray[addstepcnt].perf_start_dt_tm_null = 0
       ELSE
        SET addsteprec->objarray[addstepcnt].perf_start_dt_tm_null = 1
       ENDIF
       SET addsteprec->objarray[addstepcnt].perf_stop_dt_tm = request->cv_proc[i].cv_step[j].
       perf_stop_dt_tm
       IF ((request->cv_proc[i].cv_step[j].perf_stop_dt_tm != null_dt))
        SET addsteprec->objarray[addstepcnt].perf_stop_dt_tm_null = 0
       ELSE
        SET addsteprec->objarray[addstepcnt].perf_stop_dt_tm_null = 1
       ENDIF
       SET addsteprec->objarray[addstepcnt].lock_prsnl_id = request->cv_proc[i].cv_step[j].
       lock_prsnl_id
       IF (validate(request->cv_proc[i].cv_step[j].step_resident_id))
        SET addsteprec->objarray[addstepcnt].step_resident_id = request->cv_proc[i].cv_step[j].
        step_resident_id
       ENDIF
      ELSEIF ((request->cv_proc[i].cv_step[j].cv_step_id > 0.0)
       AND (request->cv_proc[i].cv_step[j].modified_ind=1))
       SET uptstepcnt += 1
       SET stat = alterlist(uptsteprec->objarray,uptstepcnt)
       SET uptsteprec->objarray[uptstepcnt].cv_step_id = request->cv_proc[i].cv_step[j].cv_step_id
       SET uptsteprec->objarray[uptstepcnt].cv_proc_id = request->cv_proc[i].cv_proc_id
       SET uptsteprec->objarray[uptstepcnt].task_assay_cd = request->cv_proc[i].cv_step[j].
       task_assay_cd
       SET uptsteprec->objarray[uptstepcnt].event_id = request->cv_proc[i].cv_step[j].event_id
       SET uptsteprec->objarray[uptstepcnt].updt_cnt = request->cv_proc[i].cv_step[j].updt_cnt
       SET uptsteprec->objarray[uptstepcnt].step_status_cd = request->cv_proc[i].cv_step[j].
       step_status_cd
       SET uptsteprec->objarray[uptstepcnt].sequence = request->cv_proc[i].cv_step[j].sequence
       SET uptsteprec->objarray[uptstepcnt].perf_loc_cd = request->cv_proc[i].cv_step[j].perf_loc_cd
       SET uptsteprec->objarray[uptstepcnt].perf_provider_id = request->cv_proc[i].cv_step[j].
       perf_provider_id
       SET uptsteprec->objarray[uptstepcnt].perf_start_dt_tm = request->cv_proc[i].cv_step[j].
       perf_start_dt_tm
       IF (validate(request->cv_proc[i].cv_step[j].cv_step_ind))
        SET uptsteprec->objarray[uptstepcnt].cv_step_ind = request->cv_proc[i].cv_step[j].cv_step_ind
       ENDIF
       IF ((request->cv_proc[i].cv_step[j].perf_start_dt_tm != null_dt))
        SET uptsteprec->objarray[uptstepcnt].perf_start_dt_tm_null = 0
       ELSE
        SET uptsteprec->objarray[uptstepcnt].perf_start_dt_tm_null = 1
       ENDIF
       SET uptsteprec->objarray[uptstepcnt].perf_stop_dt_tm = request->cv_proc[i].cv_step[j].
       perf_stop_dt_tm
       IF ((request->cv_proc[i].cv_step[j].perf_stop_dt_tm != null_dt))
        SET uptsteprec->objarray[uptstepcnt].perf_stop_dt_tm_null = 0
       ELSE
        SET uptsteprec->objarray[uptstepcnt].perf_stop_dt_tm_null = 1
       ENDIF
       SET uptsteprec->objarray[uptstepcnt].lock_prsnl_id = request->cv_proc[i].cv_step[j].
       lock_prsnl_id
       IF (validate(request->cv_proc[i].cv_step[j].step_resident_id))
        SET uptsteprec->objarray[uptstepcnt].step_resident_id = request->cv_proc[i].cv_step[j].
        step_resident_id
       ENDIF
       IF ((request->cv_proc[i].cv_step[j].step_status_cd != step_stat_notstarted))
        SET uptsteprec->objarray[uptstepcnt].cv_doc_type_cd = request->cv_proc[i].cv_step[j].
        doc_type_cd
        SET uptsteprec->objarray[uptstepcnt].cv_doc_id_str = request->cv_proc[i].cv_step[j].
        doc_id_str
        SET uptsteprec->objarray[uptstepcnt].cv_doc_template_id = request->cv_proc[i].cv_step[j].
        doc_template_id
       ELSE
        SET uptsteprec->objarray[uptstepcnt].cv_doc_type_cd = 0.0
        SET uptsteprec->objarray[uptstepcnt].cv_doc_id_str = " "
        SET uptsteprec->objarray[uptstepcnt].cv_doc_template_id = 0.0
       ENDIF
       SET uptsteprec->objarray[uptstepcnt].normalcy_cd = request->cv_proc[i].cv_step[j].normalcy_cd
       DECLARE external_report_state = vc WITH protect, noconstant("")
       IF (validate(g_external_report_state))
        SET external_report_state = g_external_report_state
       ENDIF
       SET externalreportstatecd = uar_get_code_by("MEANING",4390006,replace(cnvtupper(
          external_report_state)," ","",0))
       IF (((externalreportstatecd=reviewed_status_cd) OR (externalreportstatecd=amended_status_cd))
       )
        IF ((request->cv_proc[i].cv_step[j].doc_id_str="COMPLETE")
         AND (request->cv_proc[i].stress_ecg_status_cd=amended_stress_status)
         AND (request->cv_proc[i].cv_step[j].step_type_cd=step_type_finalreport_cd))
         CALL cv_log_msg(cv_debug,"Updating StressECGstatus column to blank")
         SET uptprocrec->objarray[uptproccnt].stress_ecg_status_cd = 0.0
        ENDIF
       ENDIF
      ENDIF
      IF ((request->cv_proc[i].cv_step[j].schedule_ind=1)
       AND (request->cv_proc[i].cv_step[j].cv_step_sched[1].cv_step_sched_id < 1.0)
       AND (request->cv_proc[i].cv_step[j].cv_step_sched[1].modified_ind=1))
       SET addstepschedcnt += 1
       SET stat = alterlist(addstepschedrec->objarray,addstepschedcnt)
       SELECT INTO "nl:"
        step_sched_seq = seq(card_vas_seq,nextval)
        FROM dual d
        DETAIL
         request->cv_proc[i].cv_step[j].cv_step_sched[1].cv_step_sched_id = step_sched_seq
        WITH format, counter
       ;end select
       SET addstepschedrec->objarray[addstepschedcnt].cv_step_sched_id = request->cv_proc[i].cv_step[
       j].cv_step_sched[1].cv_step_sched_id
       SET addstepschedrec->objarray[addstepschedcnt].cv_step_id = request->cv_proc[i].cv_step[j].
       cv_step_id
       SET addstepschedrec->objarray[addstepschedcnt].cv_proc_id = request->cv_proc[i].cv_proc_id
       SET addstepschedrec->objarray[addstepschedcnt].task_assay_cd = request->cv_proc[i].cv_step[j].
       task_assay_cd
       SET addstepschedrec->objarray[addstepschedcnt].arrive_dt_tm = request->cv_proc[i].cv_step[j].
       cv_step_sched[1].arrive_dt_tm
       IF ((request->cv_proc[i].cv_step[j].cv_step_sched[1].arrive_dt_tm != null_dt))
        SET addstepschedrec->objarray[addstepschedcnt].arrive_dt_tm_null = 0
       ELSE
        SET addstepschedrec->objarray[addstepschedcnt].arrive_dt_tm_null = 1
       ENDIF
       SET addstepschedrec->objarray[addstepschedcnt].arrive_ind = request->cv_proc[i].cv_step[j].
       cv_step_sched[1].arrive_ind
       SET addstepschedrec->objarray[addstepschedcnt].sched_loc_cd = request->cv_proc[i].cv_step[j].
       cv_step_sched[1].sched_loc_cd
       SET addstepschedrec->objarray[addstepschedcnt].sched_phys_id = request->cv_proc[i].cv_step[j].
       cv_step_sched[1].sched_phys_id
       SET addstepschedrec->objarray[addstepschedcnt].sched_start_dt_tm = request->cv_proc[i].
       cv_step[j].cv_step_sched[1].sched_start_dt_tm
       IF ((request->cv_proc[i].cv_step[j].cv_step_sched[1].sched_start_dt_tm != null_dt))
        SET addstepschedrec->objarray[addstepschedcnt].sched_start_dt_tm_null = 0
       ELSE
        SET addstepschedrec->objarray[addstepschedcnt].sched_start_dt_tm_null = 1
       ENDIF
       SET addstepschedrec->objarray[addstepschedcnt].sched_stop_dt_tm = request->cv_proc[i].cv_step[
       j].cv_step_sched[1].sched_stop_dt_tm
       IF ((request->cv_proc[i].cv_step[j].cv_step_sched[1].sched_stop_dt_tm != null_dt))
        SET addstepschedrec->objarray[addstepschedcnt].sched_stop_dt_tm_null = 0
       ELSE
        SET addstepschedrec->objarray[addstepschedcnt].sched_stop_dt_tm_null = 1
       ENDIF
       SET addstepschedrec->objarray[addstepschedcnt].updt_cnt = 0
      ELSEIF ((request->cv_proc[i].cv_step[j].schedule_ind=1)
       AND (request->cv_proc[i].cv_step[j].cv_step_sched[1].cv_step_sched_id > 0.0)
       AND (request->cv_proc[i].cv_step[j].cv_step_sched[1].modified_ind=1))
       SET uptstepschedcnt += 1
       SET stat = alterlist(uptstepschedrec->objarray,uptstepschedcnt)
       SET uptstepschedrec->objarray[uptstepschedcnt].cv_step_sched_id = request->cv_proc[i].cv_step[
       j].cv_step_sched[1].cv_step_sched_id
       SET uptstepschedrec->objarray[uptstepschedcnt].cv_step_id = request->cv_proc[i].cv_step[j].
       cv_step_id
       SET uptstepschedrec->objarray[uptstepschedcnt].cv_proc_id = request->cv_proc[i].cv_proc_id
       SET uptstepschedrec->objarray[uptstepschedcnt].task_assay_cd = request->cv_proc[i].cv_step[j].
       task_assay_cd
       SET uptstepschedrec->objarray[uptstepschedcnt].arrive_dt_tm = request->cv_proc[i].cv_step[j].
       cv_step_sched[1].arrive_dt_tm
       IF ((request->cv_proc[i].cv_step[j].cv_step_sched[1].arrive_dt_tm != null_dt))
        SET uptstepschedrec->objarray[uptstepschedcnt].arrive_dt_tm_null = 0
       ELSE
        SET uptstepschedrec->objarray[uptstepschedcnt].arrive_dt_tm_null = 1
       ENDIF
       SET uptstepschedrec->objarray[uptstepschedcnt].arrive_ind = request->cv_proc[i].cv_step[j].
       cv_step_sched[1].arrive_ind
       SET uptstepschedrec->objarray[uptstepschedcnt].sched_loc_cd = request->cv_proc[i].cv_step[j].
       cv_step_sched[1].sched_loc_cd
       SET uptstepschedrec->objarray[uptstepschedcnt].sched_phys_id = request->cv_proc[i].cv_step[j].
       cv_step_sched[1].sched_phys_id
       SET uptstepschedrec->objarray[uptstepschedcnt].sched_start_dt_tm = request->cv_proc[i].
       cv_step[j].cv_step_sched[1].sched_start_dt_tm
       IF ((request->cv_proc[i].cv_step[j].cv_step_sched[1].sched_start_dt_tm != null_dt))
        SET uptstepschedrec->objarray[uptstepschedcnt].sched_start_dt_tm_null = 0
       ELSE
        SET uptstepschedrec->objarray[uptstepschedcnt].sched_start_dt_tm_null = 1
       ENDIF
       SET uptstepschedrec->objarray[uptstepschedcnt].sched_stop_dt_tm = request->cv_proc[i].cv_step[
       j].cv_step_sched[1].sched_stop_dt_tm
       IF ((request->cv_proc[i].cv_step[j].cv_step_sched[1].sched_stop_dt_tm != null_dt))
        SET uptstepschedrec->objarray[uptstepschedcnt].sched_stop_dt_tm_null = 0
       ELSE
        SET uptstepschedrec->objarray[uptstepschedcnt].sched_stop_dt_tm_null = 1
       ENDIF
       SET uptstepschedrec->objarray[uptstepschedcnt].updt_cnt = request->cv_proc[i].cv_step[j].
       cv_step_sched[1].updt_cnt
      ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  SET stat = alterlist(uptprocrec->objarray,uptproccnt)
  SET stat = alterlist(addprocrec->objarray,addproccnt)
 ENDIF
 IF (size(uptprocrec->objarray,5) > 0)
  CALL cv_log_msg(cv_debug,"Updating CV_PROC")
  EXECUTE cv_da_upt_cv_proc  WITH replace("REQUEST",uptprocrec), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DA_UPT_CV_PROC","")
   CALL echorecord(uptprocrec)
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_msg(cv_debug,"Nothing to update for CV_PROC")
 ENDIF
 IF (size(addprocrec->objarray,5) > 0)
  CALL cv_log_msg(cv_debug,"Inserting to CV_PROC")
  EXECUTE cv_da_add_cv_proc  WITH replace("REQUEST",addprocrec), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DA_ADD_CV_PROC","")
   CALL echorecord(addprocrec)
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_msg(cv_debug,"Nothing to insert for CV_PROC")
 ENDIF
 IF (size(uptsteprec->objarray,5) > 0)
  CALL cv_log_msg(cv_debug,"Dropping charges to charge server")
  EXECUTE cv_drop_charges  WITH replace("REQUEST",uptsteprec), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DROP_CHARGES","")
   CALL echorecord(uptsteprec)
   GO TO exit_script
  ENDIF
  CALL cv_log_msg(cv_debug,"Updating CV_STEP")
  EXECUTE cv_da_upt_cv_step  WITH replace("REQUEST",uptsteprec), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DA_UPT_CV_STEP","")
   CALL echorecord(uptsteprec)
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_msg(cv_debug,"Nothing to update for CV_STEP")
 ENDIF
 IF (size(addsteprec->objarray,5) > 0)
  EXECUTE cv_da_add_cv_step  WITH replace("REQUEST",addsteprec), replace("REPLY",reply)
  CALL cv_log_msg(cv_debug,"Inserting to CV_STEP")
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DA_ADD_CV_STEP","")
   CALL echorecord(addsteprec)
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_msg(cv_debug,"Nothing to insert for CV_STEP")
 ENDIF
 IF (size(uptstepschedrec->objarray,5) > 0)
  CALL cv_log_msg(cv_debug,"Updating CV_STEP_SCHED")
  EXECUTE cv_da_upt_cv_step_sched  WITH replace("REQUEST",uptstepschedrec), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DA_UPT_CV_STEP_SCHED","")
   CALL echorecord(uptstepschedrec)
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_msg(cv_debug,"Nothing to update for CV_STEP_SCHED")
 ENDIF
 IF (size(addstepschedrec->objarray,5) > 0)
  CALL cv_log_msg(cv_debug,"Inserting to CV_STEP_SCHED")
  EXECUTE cv_da_add_cv_step_sched  WITH replace("REQUEST",addstepschedrec), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DA_ADD_CV_STEP_SCHED","")
   CALL echorecord(addstepschedrec)
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_msg(cv_debug,"Nothing to insert for CV_STEP_SCHED")
 ENDIF
 IF (validate(request->cv_step_prsnl)=1)
  SET cv_step_prsnl_size = size(request->cv_step_prsnl,5)
 ENDIF
 IF (cv_step_prsnl_size > 0)
  CALL cv_log_msg(cv_debug,"Inserting to CV_STEP_PRSNL")
  SET stat = alterlist(addstepprsnlrec->objarray,cv_step_prsnl_size)
  FOR (i = 1 TO cv_step_prsnl_size)
    SELECT INTO "nl:"
     step_prsnl_seq = seq(card_vas_seq,nextval)
     FROM dual d
     DETAIL
      request->cv_step_prsnl[i].cv_step_prsnl_id = step_prsnl_seq
     WITH format, counter
    ;end select
    IF ((request->cv_step_prsnl[i].action_dt_tm != null_dt))
     SET addstepprsnlrec->objarray[i].action_dt_tm_null = 0
    ELSE
     SET addstepprsnlrec->objarray[i].action_dt_tm_null = 1
    ENDIF
    SET addstepprsnlrec->objarray[i].action_dt_tm = request->cv_step_prsnl[i].action_dt_tm
    SET addstepprsnlrec->objarray[i].action_type_cd = request->cv_step_prsnl[i].action_type_cd
    SET addstepprsnlrec->objarray[i].cv_step_id = request->cv_step_prsnl[i].cv_step_id
    SET addstepprsnlrec->objarray[i].cv_step_prsnl_id = request->cv_step_prsnl[i].cv_step_prsnl_id
    SET addstepprsnlrec->objarray[i].step_prsnl_id = request->cv_step_prsnl[i].step_prsnl_id
    SET addstepprsnlrec->objarray[i].step_relation_cd = request->cv_step_prsnl[i].step_relation_cd
    SET addstepprsnlrec->objarray[i].updt_cnt = 0
  ENDFOR
  EXECUTE cv_da_add_cv_step_prsnl  WITH replace("REQUEST",addstepprsnlrec), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DA_ADD_CV_STEP_PRSNL","")
   CALL echorecord(addstepprsnlrec)
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_msg(cv_debug,"Nothing to insert for CV_STEP_PRSNL")
 ENDIF
 IF (removecount > 0
  AND size(reqremoveedreview->orderlist,5) > 0)
  SET stat = alterlist(reqremoveedreview->orderlist,removecount)
  EXECUTE cv_remove_ed_review  WITH replace("REQUEST",reqremoveedreview), replace("REPLY",
   repremoveedreview)
  IF ((repremoveedreview->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",repremoveedreview->status_data.status,"CV_REMOVE_ED_REVIEW","")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (requestcount > 0
  AND size(reqrequestedreview->orderlist,5) > 0)
  SET stat = alterlist(reqrequestedreview->orderlist,requestcount)
  EXECUTE cv_request_ed_review  WITH replace("REQUEST",reqrequestedreview), replace("REPLY",
   reprequestedreview)
  IF ((reprequestedreview->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reprequestedreview->status_data.status,"CV_REQUEST_ED_REVIEW",
    "")
   GO TO exit_script
  ENDIF
 ENDIF
 CALL updorderevents(null)
 IF ((reply->status_data.status != "S"))
  GO TO exit_script
 ENDIF
 DECLARE calling_process_name = vc WITH constant(validate(request->calling_process_name,""))
 IF (calling_process_name != "CVORDSRVSHR")
  CALL cv_log_msg(cv_debug,"Calling UpdOrderStatus")
  CALL updorderstatus(null)
 ELSE
  CALL cv_log_msg(cv_debug,"Skipping call to UpdOrderStatus")
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE calcprocstatus(null)
  EXECUTE cv_calc_proc_status  WITH replace("REQUEST",request), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_warning,"SCRIPT",reply->status_data.status,"CV_CALC_PROC_STATUS","")
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE (noupdatetoflowsheetforstressamendment(externalreportstatecd=f8,flow_ind=i2,i=i2) =i2)
  IF (size(request->cv_proc[i].cv_step,5) > 0)
   FOR (j = 1 TO size(request->cv_proc[i].cv_step,5))
     IF ((request->cv_proc[i].cv_step[j].doc_id_str="STRESSECG")
      AND externalreportstatecd=amended_status_cd
      AND (request->cv_proc[i].cv_step[j].modified_ind=1))
      SET flow_ind = 0
     ENDIF
   ENDFOR
  ENDIF
  RETURN(flow_ind)
 END ;Subroutine
 SUBROUTINE updorderevents(null)
   DECLARE result = vc WITH protect
   DECLARE event_dt_tm = dq8 WITH protect
   DECLARE proc_status = vc WITH noconstant(""), protect
   DECLARE flow_ind = i2 WITH noconstant(0), protect
   RECORD cverlist(
     1 item[*]
       2 catalog_cd = f8
       2 event_cd = f8
   ) WITH protect
   DECLARE cvercount = i4 WITH noconstant(0), protect
   SET stat = initrec(order_event_req)
   IF (cv_proc_size > 0)
    FOR (i = 1 TO cv_proc_size)
      SET result = ""
      SET event_dt_tm = cnvtdatetime("01-JAN-1900")
      SET proc_status = uar_get_code_display(request->cv_proc[i].proc_status_cd)
      IF ((request->cv_proc[i].group_event_id > 0.0))
       SELECT INTO "nl:"
        FROM clinical_event ce
        WHERE (ce.event_id=request->cv_proc[i].group_event_id)
         AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
        DETAIL
         result = ce.result_val, event_dt_tm = ce.event_start_dt_tm
        WITH nocounter
       ;end select
      ENDIF
      IF (validate(g_external_report_state)
       AND (request->cv_proc[i].proc_status_cd=proc_stat_signed))
       SET external_report_state = g_external_report_state
       SET externalreportstatecd = uar_get_code_by("DISPLAYKEY",4390006,replace(cnvtupper(
          external_report_state)," ","",0))
       IF (((externalreportstatecd=amended_status_cd) OR (((externalreportstatecd=reviewed_status_cd)
        OR (externalreportstatecd=qc_status_cd)) )) )
        SET flow_ind = 1
       ENDIF
       SET flow_ind = noupdatetoflowsheetforstressamendment(externalreportstatecd,flow_ind,i)
      ENDIF
      IF (((proc_status != result) OR ((((request->cv_proc[i].action_dt_tm != event_dt_tm)) OR (((
      flow_ind=1) OR ((request->edit_doc_flag=1))) )) )) )
       SET order_event_req->catalog_cd = request->cv_proc[i].catalog_cd
       SET order_event_req->order_id = request->cv_proc[i].order_id
       SET order_event_req->accession_nbr = request->cv_proc[i].accession
       SET order_event_req->encntr_id = request->cv_proc[i].encntr_id
       SET order_event_req->person_id = request->cv_proc[i].person_id
       SET order_event_req->result_val = proc_status
       SET order_event_req->event_end_dt_tm = request->cv_proc[i].action_dt_tm
       SET order_event_req->event_start_dt_tm = request->cv_proc[i].action_dt_tm
       SET order_event_req->reference_nbr = concat(proc_reference_prefix,cnvtstring(request->cv_proc[
         i].cv_proc_id))
       SET order_event_req->event_id = request->cv_proc[i].group_event_id
       SET order_event_req->proc_status_cd = request->cv_proc[i].proc_status_cd
       SET order_event_req->proc_normalcy_cd = request->cv_proc[i].proc_normalcy_cd
       SET order_event_req->order_prsnl_id = request->cv_proc[i].order_physician_id
       SET order_event_req->ordered_dt_tm = request->cv_proc[i].orig_order_dt_tm
       SET order_event_req->report_status_cd = externalreportstatecd
       SET order_event_req->modality_cd = request->cv_proc[i].activity_subtype_cd
       SET order_event_req->future_order_ind = request->cv_proc[i].future_order_ind
       SET order_event_req->order_action_tz = request->order_action_tz
       SELECT INTO "nl:"
        FROM im_study ims
        WHERE (ims.orig_entity_id=request->cv_proc[i].cv_proc_id)
         AND ims.orig_entity_name="CV_PROC"
        DETAIL
         order_event_req->study_state_cd = ims.study_state_cd
        WITH nocounter
       ;end select
       DECLARE final_step_prfmer = f8 WITH noconstant(0.0)
       IF (size(request->cv_proc[i].cv_step,5) > 0)
        FOR (j = 1 TO size(request->cv_proc[i].cv_step,5))
          IF ((request->cv_proc[i].proc_status_cd=proc_stat_signed)
           AND (request->cv_proc[i].cv_step[j].modified_ind=1))
           SET order_event_req->verified_prsnl_id = request->cv_proc[i].cv_step[j].perf_provider_id
          ENDIF
          IF ((request->cv_proc[i].proc_status_cd=proc_stat_completed)
           AND (request->cv_proc[i].cv_step[j].modified_ind=1))
           SET order_event_req->verified_prsnl_id = request->cv_proc[i].cv_step[j].perf_provider_id
          ENDIF
          SET final_step_prfmer = request->cv_proc[i].cv_step[j].perf_provider_id
          SET order_event_req->doc_type_cd = request->cv_proc[i].cv_step[j].doc_type_cd
          IF ((request->cv_proc[i].cv_step[j].action_tz > 0))
           SET order_event_req->action_tz = request->cv_proc[i].cv_step[j].action_tz
          ENDIF
        ENDFOR
       ENDIF
       IF ((order_event_req->verified_prsnl_id <= 0.0))
        DECLARE cv_login_id = f8 WITH noconstant(0.0)
        DECLARE external_perf_provider_id = f8 WITH noconstant(0.0)
        IF (validate(g_cv_login_id)
         AND validate(g_external_perf_provider_id))
         SET cv_login_id = g_cv_login_id
         SET external_perf_provider_id = g_external_perf_provider_id
        ENDIF
        IF ((request->cv_proc[i].proc_status_cd=proc_stat_signed))
         IF (((cv_login_id=0.0
          AND external_perf_provider_id > 0.0) OR (external_perf_provider_id > 0.0)) )
          SET order_event_req->verified_prsnl_id = g_external_perf_provider_id
         ELSE
          SET order_event_req->verified_prsnl_id = final_step_prfmer
         ENDIF
        ELSE
         SET order_event_req->verified_prsnl_id = reqinfo->updt_id
        ENDIF
       ENDIF
       SET order_event_req->event_cd = 0
       FOR (idx = 1 TO cvercount)
         IF ((request->cv_proc[i].catalog_cd=cverlist->item[idx].catalog_cd))
          SET order_event_req->event_cd = cverlist->item[idx].event_cd
          SET idx = cvercount
         ENDIF
       ENDFOR
       IF ((order_event_req->event_cd=0))
        SELECT INTO "nl:"
         FROM code_value_event_r cver
         WHERE (cver.parent_cd=request->cv_proc[i].catalog_cd)
         DETAIL
          cvercount += 1, stat = alterlist(cverlist->item,cvercount), cverlist->item[cvercount].
          catalog_cd = cver.parent_cd,
          cverlist->item[cvercount].event_cd = cver.event_cd, order_event_req->event_cd = cver
          .event_cd
         WITH nocounter
        ;end select
       ENDIF
       IF ((order_event_req->event_cd=0.0))
        CALL cv_log_stat(cv_audit,"SELECT","F","CODE_VALUE_EVENT_R",build("CATALOG_CD=",request->
          cv_proc[i].catalog_cd))
       ENDIF
       IF ((order_event_req->future_order_ind=0))
        CALL cv_log_msg(cv_debug,
         "Incoming order is not future order. Hence upadtaing Clinical event table.")
        EXECUTE cv_upd_order_event  WITH replace("REQUEST",order_event_req), replace("REPLY",
         order_event_rep)
       ENDIF
       IF ((order_event_rep->status_data.status != "S"))
        CALL cv_log_msg(cv_error,"Saving results to clinical_event table failed")
        CALL echorecord(order_event_rep)
       ELSE
        CALL cv_log_msg(cv_info,"Saving results to clinical_event table succeeded")
        IF ((request->cv_proc[i].group_event_id=0.0))
         UPDATE  FROM cv_proc cp
          SET cp.group_event_id = order_event_rep->event_id
          WHERE (cp.cv_proc_id=request->cv_proc[i].cv_proc_id)
          WITH nocounter
         ;end update
        ENDIF
        SET request->cv_proc[i].group_event_id = order_event_rep->event_id
        SET request->cv_proc[i].modified_ind = 1
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE updorderstatus(null)
   SET proc_step_modifiedind = 0
   IF (cv_proc_size > 0)
    FOR (i = 1 TO cv_proc_size)
      FOR (j = 1 TO size(request->cv_proc[i].cv_step,5))
        IF ((request->cv_proc[i].cv_step[j].unmatch_ind=1))
         CALL updorderactiontimezone(request->cv_proc[i].order_id)
         GO TO exit_script
        ELSE
         IF ((request->cv_proc[i].modified_ind=1))
          SET proc_step_modifiedind = 1
          IF ((request->edit_doc_flag=1)
           AND (request->cv_proc[i].activity_subtype_cd=step_activity_subtype_cd))
           SET proc_step_modifiedind = 1
          ENDIF
         ELSE
          IF ((request->cv_proc[i].cv_step[j].match_ind=1))
           CALL updorderactiontimezone(request->cv_proc[i].order_id)
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      IF (proc_step_modifiedind=1)
       SET stat = initrec(order_status_req)
       SET order_status_req->person_id = request->cv_proc[i].person_id
       SET order_status_req->order_action_tz = request->order_action_tz
       SET stat = alterlist(order_status_req->orders,1)
       SET fetch_comm_type_req->cv_order_id = request->cv_proc[i].order_id
       EXECUTE cv_fetch_communication_type  WITH replace("REQUEST",fetch_comm_type_req), replace(
        "REPLY",fetch_comm_type_reply)
       IF ((fetch_comm_type_reply->status_data.status != "S"))
        CALL cv_log_msg(cv_error,"Fetching Communication Type failed")
       ENDIF
       SET order_status_req->orders[1].communication_type_cd = fetch_comm_type_reply->
       communication_type_cd
       SET order_status_req->orders[1].encntr_id = request->cv_proc[i].encntr_id
       SET order_status_req->orders[1].order_id = request->cv_proc[i].order_id
       SET order_status_req->orders[1].proc_status_cd = request->cv_proc[i].proc_status_cd
       SET order_status_req->orders[1].order_dt_tm = time_now
       SET order_status_req->orders[1].catalog_cd = request->cv_proc[i].catalog_cd
       IF ((request->edit_doc_flag=1)
        AND (request->cv_proc[i].activity_subtype_cd=step_activity_subtype_cd))
        SET order_status_req->orders[1].proc_status_cd = proc_stat_completed
       ENDIF
       EXECUTE cv_upd_order_status  WITH replace("REQUEST",order_status_req), replace("REPLY",reply)
       IF ((request->edit_doc_flag=1)
        AND (request->cv_proc[i].activity_subtype_cd=step_activity_subtype_cd))
        SET order_status_req->orders[1].proc_status_cd = proc_stat_signed
        EXECUTE cv_upd_order_status  WITH replace("REQUEST",order_status_req), replace("REPLY",reply)
       ENDIF
      ENDIF
      IF ((reply->status_data.status != "S"))
       CALL cv_log_msg(cv_error,"Updating Orders Status failed")
       CALL echorecord(order_status_req)
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   SET request->edit_doc_flag = 0
 END ;Subroutine
 SUBROUTINE (updorderactiontimezone(order_id=f8) =null)
  SELECT INTO "nl:"
   FROM order_action o
   WHERE (o.order_action_id=
   (SELECT
    max(o.order_action_id)
    FROM order_action o
    WHERE o.order_id=order_id))
   DETAIL
    order_action_id = o.order_action_id
   WITH nocounter
  ;end select
  IF ((request->order_action_tz != 0))
   UPDATE  FROM order_action o
    SET o.action_tz = request->order_action_tz, o.effective_tz = request->order_action_tz, o.order_tz
      = request->order_action_tz
    WHERE o.order_action_id=order_action_id
   ;end update
  ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_SAVE_PROCS failed")
  CALL echorecord(request)
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("041 01/09/2024 NM096572")
END GO
