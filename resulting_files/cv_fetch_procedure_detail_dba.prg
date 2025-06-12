CREATE PROGRAM cv_fetch_procedure_detail:dba
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
 DECLARE proc_cnt = i4 WITH public, noconstant(0)
 DECLARE proc_idx = i4 WITH protect
 DECLARE fillproceduredetail(null) = null
 DECLARE fillstepdetail(null) = null
 IF ((reqdata->loglevel >= cv_debug))
  CALL echorecord(request)
 ENDIF
 IF (validate(reply)=0)
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
 SET reply->status_data.status = "F"
 IF ((request->order_id <= 0))
  CALL cv_log_stat(cv_audit,"SIZE","Z","ORDERS","")
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_FETCH_PROCEDURE_DETAIL"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Order_id is 0"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->cv_proc,1)
 CALL fillproceduredetail(null)
 IF ((reply->cv_proc[1].cv_proc_id <= 0))
  CALL cv_log_stat(cv_info,"SELECT","Z","CV_PROC","")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 CALL fillstepdetail(null)
 SUBROUTINE fillproceduredetail(null)
   SELECT
    IF ((request->order_id > 0)
     AND (request->withlock_flag=2))
     FROM cv_proc p
     PLAN (p
      WHERE (p.order_id=request->order_id))
     WITH nocounter, forupdatewait(p)
    ELSE
    ENDIF
    INTO "n1:"
    FROM cv_proc p
    PLAN (p
     WHERE (p.cv_proc_id=- (1.0)))
    DETAIL
     proc_cnt = 1, reply->cv_proc[proc_cnt].accession = p.accession, reply->cv_proc[proc_cnt].
     accession_id = p.accession_id,
     reply->cv_proc[proc_cnt].action_dt_tm = p.action_dt_tm, reply->cv_proc[proc_cnt].catalog_cd = p
     .catalog_cd, reply->cv_proc[proc_cnt].cv_proc_id = p.cv_proc_id,
     reply->cv_proc[proc_cnt].encntr_id = p.encntr_id, reply->cv_proc[proc_cnt].group_event_id = p
     .group_event_id, reply->cv_proc[proc_cnt].order_id = p.order_id,
     reply->cv_proc[proc_cnt].order_physician_id = p.order_physician_id, reply->cv_proc[proc_cnt].
     person_id = p.person_id, reply->cv_proc[proc_cnt].phys_group_id = p.phys_group_id,
     reply->cv_proc[proc_cnt].prim_physician_id = p.prim_physician_id, reply->cv_proc[proc_cnt].
     priority_cd = p.priority_cd, reply->cv_proc[proc_cnt].proc_status_cd = p.proc_status_cd,
     reply->cv_proc[proc_cnt].reason_for_proc = p.reason_for_proc, reply->cv_proc[proc_cnt].
     refer_physician_id = p.refer_physician_id, reply->cv_proc[proc_cnt].request_dt_tm = p
     .request_dt_tm,
     reply->cv_proc[proc_cnt].activity_subtype_cd = p.activity_subtype_cd, reply->cv_proc[proc_cnt].
     sequence = p.sequence, reply->cv_proc[proc_cnt].updt_cnt = p.updt_cnt,
     reply->cv_proc[proc_cnt].orig_order_dt_tm = p.orig_order_dt_tm, reply->cv_proc[proc_cnt].
     proc_normalcy_cd = p.normalcy_cd, reply->cv_proc[proc_cnt].stress_ecg_status_cd = p
     .stress_ecg_status_cd,
     reply->cv_proc[proc_cnt].study_state_cd = p.study_state_cd
    FOOT REPORT
     stat = alterlist(reply->cv_proc,1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE fillstepdetail(null)
   SELECT INTO "nl:"
    l_block_start = 1
    FROM cv_step_ref csr,
     cv_step cs
    PLAN (cs
     WHERE (cs.cv_proc_id=reply->cv_proc[proc_cnt].cv_proc_id))
     JOIN (csr
     WHERE csr.task_assay_cd=cs.task_assay_cd)
    ORDER BY cs.cv_proc_id, cs.sequence
    HEAD cs.cv_proc_id
     l_step_cnt = 0
    DETAIL
     IF ((reply->cv_proc[1].cv_proc_id > 0))
      l_step_cnt += 1
      IF (mod(l_step_cnt,3)=1)
       stat = alterlist(reply->cv_proc[proc_idx].cv_step,(l_step_cnt+ 2))
      ENDIF
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].activity_subtype_cd = csr.activity_subtype_cd,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].cv_step_id = cs.cv_step_id, reply->cv_proc[
      proc_idx].cv_step[l_step_cnt].event_id = cs.event_id,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].proc_status_cd = csr.proc_status_cd, reply->
      cv_proc[proc_idx].cv_step[l_step_cnt].schedule_ind = csr.schedule_ind, reply->cv_proc[proc_idx]
      .cv_step[l_step_cnt].sequence = cs.sequence,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].step_status_cd = cs.step_status_cd
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
      l_step_cnt].perf_provider_id = cs.perf_provider_id,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].perf_start_dt_tm = cs.perf_start_dt_tm, reply->
      cv_proc[proc_idx].cv_step[l_step_cnt].perf_stop_dt_tm = cs.perf_stop_dt_tm, reply->cv_proc[
      proc_idx].cv_step[l_step_cnt].lock_prsnl_id = cs.lock_prsnl_id,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].step_type_cd = csr.step_type_cd, reply->cv_proc[
      proc_idx].cv_step[l_step_cnt].study_identifier = cs.study_identifier, reply->cv_proc[proc_idx].
      cv_step[l_step_cnt].modality_cd = cs.modality_cd,
      reply->cv_proc[proc_idx].cv_step[l_step_cnt].study_dt_tm = cs.study_dt_tm, reply->cv_proc[
      proc_idx].cv_step[l_step_cnt].vendor_cd = cs.vendor_cd, reply->cv_proc[proc_idx].cv_step[
      l_step_cnt].pdf_doc_identifier = cs.pdf_doc_identifier
     ENDIF
    FOOT  cs.cv_proc_id
     stat = alterlist(reply->cv_proc[proc_idx].cv_step,l_step_cnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->cv_proc,proc_cnt)
   SET reply->status_data.status = "S"
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_info,"No procs found")
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="F"))
  CALL cv_log_msg(cv_error,"CV_FETCH_PROCEDURE_DETAIL failed")
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="S"))
  CALL cv_log_msg(cv_debug,"Successfully found procs")
  IF ((reqdata->loglevel >= cv_debug))
   CALL echorecord(reply)
  ENDIF
  SET reqinfo->commit_ind = 1
 ELSE
  CALL cv_log_msg(cv_audit,"Unknown status")
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL cv_log_msg_post("MOD 00 03/31/23 AS043139")
END GO
