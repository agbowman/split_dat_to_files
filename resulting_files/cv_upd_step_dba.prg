CREATE PROGRAM cv_upd_step:dba
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
 IF ((reqdata->loglevel >= cv_debug))
  CALL echorecord(request)
 ENDIF
 DECLARE deletetechstepsfornucmedstress(dummy) = null WITH protect
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
 DECLARE step_type_cd_final_report_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "FINALREPORT"))
 DECLARE dicom_pdf_report_type_stressecg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
   4002763,"STRESSECG"))
 DECLARE edit_doc_flag = i2 WITH public
 DECLARE step_size = i4 WITH protect
 DECLARE step_idx = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE step_prsnl_size = i4 WITH protect
 DECLARE req_proc_id = f8 WITH protect, noconstant(validate(request->cv_proc_id,0.0))
 DECLARE doc_id_cd = f8 WITH protect, noconstant(0.0)
 DECLARE delete_step = i2 WITH protect, noconstant(1)
 DECLARE req_step_id = f8 WITH protect, noconstant(0.0)
 DECLARE final_report_stressecg_signed_or_unsigned = i2 WITH protect, noconstant(0)
 DECLARE step_id_stressecg_technologist = f8 WITH protect, noconstant(0.0)
 DECLARE step_id_stressecg_finalreport = f8 WITH protect, noconstant(0.0)
 DECLARE step_status_stressecg_technologist = f8 WITH protect, noconstant(0.0)
 DECLARE now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE step_reltn_cs = i4 WITH protect, constant(4000400)
 DECLARE activity_subtype_ecg = f8 WITH protect, noconstant(0.0)
 DECLARE contrib_powerchart = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"POWERCHART"))
 DECLARE critical = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"CRITICAL"))
 DECLARE criticality_found = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE cva.alias="ECG"
   AND cva.code_set=5801
   AND cva.contributor_source_cd=contrib_powerchart
   AND ((cva.alias_type_meaning=null) OR (cva.alias_type_meaning <= " "))
  DETAIL
   activity_subtype_ecg = cva.code_value
  WITH nocounter
 ;end select
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
  CALL cv_log_msg(cv_error,"Reply doesn't have a status block")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 IF (validate(request->cv_step))
  SET step_size = size(request->cv_step,5)
 ENDIF
 IF (step_size < 1
  AND req_proc_id=0.0)
  CALL cv_log_stat(cv_warning,"SIZE","Z","REQUEST","size(request->cv_step,5)=0")
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
 IF (req_proc_id > 0.0)
  IF (validate(request->updt_cnt,null_i4)=null_i4)
   SET fetch_req->withlock_flag = 2
  ENDIF
  SET stat = alterlist(fetch_req->cv_proc,1)
  SET fetch_req->cv_proc[1].cv_proc_id = req_proc_id
 ELSE
  FOR (step_idx = 1 TO step_size)
    IF (validate(request->cv_step[step_idx].cv_step_id,0.0)=0.0)
     CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","CV_STEP_ID=0.0")
     GO TO exit_script
    ELSEIF ((validate(request->cv_step[step_idx].updt_cnt,- (1))=- (1)))
     SET fetch_req->withlock_flag = 2
    ENDIF
  ENDFOR
  SET stat = alterlist(fetch_req->cv_step,1)
  SET fetch_req->cv_step[1].cv_step_id = request->cv_step[1].cv_step_id
 ENDIF
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
  CALL cv_log_msg(cv_error,"CV_FETCH_PROCS failed")
  GO TO exit_script
 ENDIF
 IF (size(proc_list->cv_proc,5) > 1)
  CALL cv_log_stat(cv_error,"SIZE","F","PROC_LIST","size(proc_list->cv_proc,5)>1")
  GO TO exit_script
 ENDIF
 DECLARE proc_step_cnt = i4 WITH noconstant(size(proc_list->cv_proc[1].cv_step,5)), protect
 DECLARE proc_step_idx = i4 WITH protect
 SET curalias procstepschedrec proc_list->cv_proc[1].cv_step[proc_step_idx].cv_step_sched[1]
 SET curalias reqstepschedrec request->cv_step[step_idx].cv_step_sched[1]
 SET curalias procsteprec proc_list->cv_proc[1].cv_step[proc_step_idx]
 SET curalias reqsteprec request->cv_step[step_idx]
 FOR (step_idx = 1 TO step_size)
   FOR (proc_step_idx = 1 TO proc_step_cnt)
     IF ((procsteprec->cv_step_id != reqsteprec->cv_step_id)
      AND (procsteprec->normalcy_cd=critical))
      SET criticality_found = 1
     ENDIF
   ENDFOR
 ENDFOR
 IF (validate(request->cv_step[1].proc_normalcy_cd,null_f8) != null_f8)
  IF (criticality_found=1)
   SET proc_list->cv_proc[1].proc_normalcy_cd = critical
  ELSE
   SET proc_list->cv_proc[1].proc_normalcy_cd = request->cv_step[1].proc_normalcy_cd
  ENDIF
 ENDIF
 FOR (step_idx = 1 TO step_size)
   FOR (proc_step_idx = 1 TO proc_step_cnt)
     IF ((reqsteprec->cv_step_id=procsteprec->cv_step_id))
      SET procsteprec->modified_ind = 1
      IF ((validate(reqsteprec->updt_cnt,- (1)) != - (1))
       AND (reqsteprec->updt_cnt != procsteprec->updt_cnt))
       CALL cv_log_stat(cv_audit,"SELECT","F","CV_STEP",build("UPDT_CNT=",procsteprec->updt_cnt))
       GO TO exit_script
      ENDIF
      IF (validate(reqsteprec->event_id,null_f8) != null_f8)
       SET procsteprec->event_id = reqsteprec->event_id
      ENDIF
      IF (validate(reqsteprec->sequence,null_i2) != null_i2)
       SET procsteprec->sequence = reqsteprec->sequence
      ENDIF
      SET procsteprec->normalcy_cd = request->cv_step[1].proc_normalcy_cd
      IF ((proc_list->cv_proc[1].activity_subtype_cd=activity_subtype_ecg))
       IF ((reqsteprec->step_status_cd != procsteprec->step_status_cd))
        DECLARE oldstatusmeaning = vc WITH noconstant(uar_get_code_meaning(procsteprec->
          step_status_cd))
        DECLARE newstatusmeaning = vc WITH noconstant(uar_get_code_meaning(reqsteprec->step_status_cd
          ))
        IF (oldstatusmeaning="NOTSTARTED"
         AND newstatusmeaning="SAVED")
         SET procsteprec->perf_start_dt_tm = now
        ENDIF
       ENDIF
      ENDIF
      IF (validate(reqsteprec->step_status_cd,null_f8) != null_f8)
       DECLARE oldstatusmeaning = vc WITH noconstant(uar_get_code_meaning(procsteprec->step_status_cd
         ))
       IF ((procsteprec->step_status_cd=0.0))
        SET oldstatusmeaning = ""
       ENDIF
       DECLARE newstatusmeaning = vc WITH noconstant(uar_get_code_meaning(reqsteprec->step_status_cd)
        )
       IF ((reqsteprec->step_status_cd=0.0))
        SET newstatusmeaning = ""
       ENDIF
       IF ((procsteprec->step_status_cd != reqsteprec->step_status_cd))
        IF (((1=step_size
         AND newstatusmeaning="NOTSTARTED"
         AND oldstatusmeaning="COMPLETED") OR ((step_type_cd_final_report_cd != procsteprec->
        step_type_cd))) )
         SET delete_step = 0
        ENDIF
        SET procsteprec->step_status_cd = reqsteprec->step_status_cd
        IF ((procsteprec->step_resident_id=0.0))
         IF (((newstatusmeaning="UNSIGNED") OR (newstatusmeaning="EDREVIEW")) )
          IF (validate(reqsteprec->perf_provider_id) != 0)
           SET procsteprec->step_resident_id = reqsteprec->perf_provider_id
          ENDIF
         ENDIF
        ELSE
         IF (newstatusmeaning="SAVED")
          IF (((oldstatusmeaning="UNSIGNED") OR (oldstatusmeaning="EDREVIEW")) )
           SET procsteprec->step_resident_id = 0
          ENDIF
         ENDIF
        ENDIF
        CALL addtostepprsnl(uar_get_code_by("MEANING",step_reltn_cs,"ACTPRSNL"),reqinfo->updt_id)
       ENDIF
      ENDIF
      IF (validate(reqsteprec->task_assay_cd,null_f8) != null_f8)
       SET procsteprec->task_assay_cd = reqsteprec->task_assay_cd
      ENDIF
      IF (validate(reqsteprec->perf_loc_cd,null_f8) != null_f8)
       SET procsteprec->perf_loc_cd = reqsteprec->perf_loc_cd
      ELSE
       SET procsteprec->perf_loc_cd = 0.0
      ENDIF
      IF (validate(reqsteprec->perf_provider_id,null_f8) != null_f8)
       IF ((procsteprec->perf_provider_id != reqsteprec->perf_provider_id))
        SET procsteprec->perf_provider_id = reqsteprec->perf_provider_id
        CALL addtostepprsnl(uar_get_code_by("MEANING",step_reltn_cs,"PERFPROV"),request->cv_step[
         step_idx].perf_provider_id)
       ENDIF
      ENDIF
      IF (validate(reqsteprec->action_tz)=1)
       SET procsteprec->action_tz = reqsteprec->action_tz
      ENDIF
      IF (validate(reqsteprec->perf_start_dt_tm)=1)
       SET procsteprec->perf_start_dt_tm = reqsteprec->perf_start_dt_tm
      ENDIF
      IF (validate(reqsteprec->perf_stop_dt_tm)=1)
       SET procsteprec->perf_stop_dt_tm = reqsteprec->perf_stop_dt_tm
      ENDIF
      IF (validate(reqsteprec->lock_prsnl_id,null_f8) != null_f8)
       SET procsteprec->lock_prsnl_id = reqsteprec->lock_prsnl_id
      ENDIF
      IF (validate(request->cv_step[step_idx].cv_step_sched)=1)
       IF (size(request->cv_step[step_idx].cv_step_sched,5) > 0)
        IF ( NOT (validate(reqstepschedrec->updt_cnt,- (1)) IN (- (1), procstepschedrec->updt_cnt)))
         CALL cv_log_stat(cv_error,"SELECT","F","CV_STEP_SCHED",build("UPDT_CNT=",procstepschedrec->
           updt_cnt))
         GO TO exit_script
        ENDIF
        SET procstepschedrec->modified_ind = 1
        IF (validate(reqstepschedrec->arrive_dt_tm)=1)
         SET procstepschedrec->arrive_dt_tm = reqstepschedrec->arrive_dt_tm
        ENDIF
        IF (validate(reqstepschedrec->arrive_ind,null_i2) != null_i2)
         SET procstepschedrec->arrive_ind = reqstepschedrec->arrive_ind
        ENDIF
        IF (validate(reqstepschedrec->cv_step_sched_id,null_f8) != null_f8)
         SET procstepschedrec->cv_step_sched_id = reqstepschedrec->cv_step_sched_id
        ENDIF
        IF (validate(reqstepschedrec->sched_loc_cd,null_f8) != null_f8)
         SET procstepschedrec->sched_loc_cd = reqstepschedrec->sched_loc_cd
        ENDIF
        IF (validate(reqstepschedrec->sched_phys_id,null_f8) != null_f8)
         IF ((procstepschedrec->sched_phys_id != reqstepschedrec->sched_phys_id))
          SET procstepschedrec->sched_phys_id = reqstepschedrec->sched_phys_id
          CALL addtostepprsnl(uar_get_code_by("MEANING",step_reltn_cs,"SCHEDPROV"),reqstepschedrec->
           sched_phys_id)
         ENDIF
        ENDIF
        IF (validate(reqstepschedrec->sched_start_dt_tm)=1)
         SET procstepschedrec->sched_start_dt_tm = reqstepschedrec->sched_start_dt_tm
         SET proc_list->cv_proc[1].action_dt_tm = reqstepschedrec->sched_start_dt_tm
        ENDIF
        IF (validate(reqstepschedrec->sched_stop_dt_tm)=1)
         SET procstepschedrec->sched_stop_dt_tm = reqstepschedrec->sched_stop_dt_tm
        ENDIF
       ENDIF
      ENDIF
      SET proc_step_idx = proc_step_cnt
     ENDIF
   ENDFOR
 ENDFOR
 IF (req_proc_id > 0.0)
  IF ( NOT ((request->updt_cnt IN (null_i4, proc_list->cv_proc[1].updt_cnt))))
   CALL cv_log_stat(cv_audit,"SELECT","F","CV_PROC",build("UPDT_CNT=",proc_list->cv_proc[1].updt_cnt)
    )
   GO TO exit_script
  ENDIF
  IF ( NOT (validate(request->prim_physician_id,null_f8) IN (null_f8, proc_list->cv_proc[1].
  prim_physician_id)))
   SET proc_list->cv_proc[1].prim_physician_id = request->prim_physician_id
   SET proc_list->cv_proc[1].modified_ind = 1
  ENDIF
  IF ( NOT (validate(request->phys_group_id,null_f8) IN (null_f8, proc_list->cv_proc[1].phys_group_id
  )))
   SET proc_list->cv_proc[1].phys_group_id = request->phys_group_id
   SET proc_list->cv_proc[1].modified_ind = 1
  ENDIF
 ENDIF
 DECLARE step_index = i4 WITH protect, noconstant(0)
 DECLARE step_count = i4 WITH protect, constant(size(proc_list->cv_proc[1].cv_step,5))
 DECLARE step_id_diagnostic = f8 WITH protect, noconstant(0.0)
 DECLARE step_status_diagnostic = f8 WITH protect, noconstant(0.0)
 DECLARE step_id_interventional = f8 WITH protect, noconstant(0.0)
 DECLARE step_status_interventional = f8 WITH protect, noconstant(0.0)
 DECLARE step_id_complete = f8 WITH protect, noconstant(0.0)
 DECLARE step_status_complete = f8 WITH protect, noconstant(0.0)
 DECLARE step_status_cd_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "COMPLETED"))
 DECLARE step_status_cd_unsigned = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "UNSIGNED"))
 DECLARE doc_type_cd_dicom_pdf = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,
   "DICOMPDF"))
 FOR (step_index = 1 TO step_count)
   IF ((proc_list->cv_proc[1].cv_step[step_index].doc_type_cd=doc_type_cd_dicom_pdf))
    CASE (proc_list->cv_proc[1].cv_step[step_index].doc_id_str)
     OF "DIAGNOSTIC":
      SET step_id_diagnostic = proc_list->cv_proc[1].cv_step[step_index].cv_step_id
      SET step_status_diagnostic = proc_list->cv_proc[1].cv_step[step_index].step_status_cd
     OF "INTERVENTION":
      SET step_id_interventional = proc_list->cv_proc[1].cv_step[step_index].cv_step_id
      SET step_status_interventional = proc_list->cv_proc[1].cv_step[step_index].step_status_cd
     OF "COMPLETE":
      SET step_id_complete = proc_list->cv_proc[1].cv_step[step_index].cv_step_id
      SET step_status_complete = proc_list->cv_proc[1].cv_step[step_index].step_status_cd
    ENDCASE
   ENDIF
 ENDFOR
 DECLARE step_id_technologist = f8 WITH protect, noconstant(0.0)
 DECLARE step_status_technologist = f8 WITH protect, noconstant(0.0)
 DECLARE activity_subtype_cd_cath = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,
   "CARDIACCATH"))
 DECLARE activity_subtype_cd_ep = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,
   "ELECTROPHYS"))
 DECLARE step_type_cd_technologist = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "TECHNOLOGIST"))
 DECLARE final_report_is_signed_or_unsigned = i2 WITH protect, noconstant(0)
 IF ((proc_list->cv_proc[1].activity_subtype_cd != activity_subtype_cd_cath)
  AND (proc_list->cv_proc[1].activity_subtype_cd != activity_subtype_cd_ep))
  FOR (step_index = 1 TO step_count)
    SET doc_id_cd = uar_get_code_by("MEANING",4002763,cnvtupper(proc_list->cv_proc[1].cv_step[
      step_index].doc_id_str))
    IF ((proc_list->cv_proc[1].cv_step[step_index].step_type_cd=step_type_cd_technologist))
     IF (dicom_pdf_report_type_stressecg_cd=doc_id_cd)
      SET step_id_stressecg_technologist = proc_list->cv_proc[1].cv_step[step_index].cv_step_id
      SET step_status_stressecg_technologist = proc_list->cv_proc[1].cv_step[step_index].
      step_status_cd
     ELSE
      SET step_id_technologist = proc_list->cv_proc[1].cv_step[step_index].cv_step_id
      SET step_status_technologist = proc_list->cv_proc[1].cv_step[step_index].step_status_cd
     ENDIF
    ENDIF
    IF ((proc_list->cv_proc[1].cv_step[step_index].step_type_cd=step_type_cd_final_report_cd))
     IF ((request->cv_step[1].edit_doc_flag=1))
      SET proc_list->edit_doc_flag = 1
     ENDIF
     IF (dicom_pdf_report_type_stressecg_cd=doc_id_cd)
      SET step_id_stressecg_finalreport = proc_list->cv_proc[1].cv_step[step_index].cv_step_id
     ENDIF
     IF ((((proc_list->cv_proc[1].cv_step[step_index].step_status_cd=step_status_cd_completed)) OR ((
     proc_list->cv_proc[1].cv_step[step_index].step_status_cd=step_status_cd_unsigned))) )
      IF (dicom_pdf_report_type_stressecg_cd=doc_id_cd)
       SET final_report_stressecg_signed_or_unsigned = 1
      ELSE
       SET final_report_is_signed_or_unsigned = 1
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF ((reqdata->loglevel=4))
  CALL echo(build2("step_id_diagnostic = ",step_id_diagnostic,"(",step_status_diagnostic,
    "); step_id_interventional = ",
    step_id_interventional,"(",step_status_interventional,"); step_id_complete = ",step_id_complete,
    "(",step_status_complete,")"))
 ENDIF
 SET proc_list->order_action_tz = curtimezoneapp
 EXECUTE cv_upd_proc  WITH replace("REQUEST",proc_list), replace("REPLY",reply)
 FREE RECORD req_del_steps
 RECORD req_del_steps(
   1 cv_proc_id = f8
   1 steps[*]
     2 cv_step_id = f8
 )
 DECLARE del_steps_count = i4 WITH noconstant(0)
 IF (step_status_complete=step_status_cd_completed)
  IF (step_id_diagnostic != 0.0)
   SET del_steps_count += 1
   SET stat = alterlist(req_del_steps->steps,del_steps_count)
   SET req_del_steps->steps[del_steps_count].cv_step_id = step_id_diagnostic
  ENDIF
  IF (step_id_interventional != 0.0)
   SET del_steps_count += 1
   SET stat = alterlist(req_del_steps->steps,del_steps_count)
   SET req_del_steps->steps[del_steps_count].cv_step_id = step_id_interventional
  ENDIF
 ENDIF
 IF (del_steps_count=0
  AND step_status_interventional=step_status_cd_completed)
  IF (step_id_complete != 0.0)
   SET del_steps_count += 1
   SET stat = alterlist(req_del_steps->steps,del_steps_count)
   SET req_del_steps->steps[del_steps_count].cv_step_id = step_id_complete
  ENDIF
 ENDIF
 IF (step_id_technologist != 0
  AND step_status_technologist != step_status_cd_completed
  AND final_report_is_signed_or_unsigned=1
  AND step_id_stressecg_technologist=0
  AND step_id_stressecg_finalreport=0
  AND delete_step=1)
  SET del_steps_count += 1
  SET stat = alterlist(req_del_steps->steps,del_steps_count)
  SET req_del_steps->steps[del_steps_count].cv_step_id = step_id_technologist
 ENDIF
 IF (((step_id_stressecg_technologist != 0) OR (step_id_stressecg_finalreport != 0)) )
  IF (delete_step=1)
   CALL deletetechstepsfornucmedstress(0)
  ENDIF
 ENDIF
 IF ((reqdata->loglevel=4))
  CALL echo(build2("del_steps_count = ",del_steps_count))
 ENDIF
 IF (del_steps_count != 0)
  SET req_del_steps->cv_proc_id = proc_list->cv_proc[1].cv_proc_id
  EXECUTE cv_del_procedure_steps  WITH replace("REQUEST",req_del_steps)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DEL_PROCEDURE_STEPS","")
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE (addtostepprsnl(step_reltn_cd=f8,prsnl_id=f8) =null)
   SET step_prsnl_size += 1
   SET stat = alterlist(proc_list->cv_step_prsnl,step_prsnl_size)
   SET proc_list->cv_step_prsnl[step_prsnl_size].action_type_cd = procsteprec->step_status_cd
   SET proc_list->cv_step_prsnl[step_prsnl_size].action_dt_tm = now
   SET proc_list->cv_step_prsnl[step_prsnl_size].cv_step_id = procsteprec->cv_step_id
   SET proc_list->cv_step_prsnl[step_prsnl_size].step_prsnl_id = prsnl_id
   SET proc_list->cv_step_prsnl[step_prsnl_size].step_relation_cd = step_reltn_cd
 END ;Subroutine
 SUBROUTINE deletetechstepsfornucmedstress(dummy)
   IF (step_id_technologist != 0
    AND step_status_technologist != step_status_cd_completed
    AND final_report_is_signed_or_unsigned=1)
    SET del_steps_count += 1
    SET stat = alterlist(req_del_steps->steps,del_steps_count)
    SET req_del_steps->steps[del_steps_count].cv_step_id = step_id_technologist
   ELSEIF (step_id_stressecg_technologist != 0
    AND step_status_stressecg_technologist != step_status_cd_completed
    AND final_report_stressecg_signed_or_unsigned=1)
    SET del_steps_count += 1
    SET stat = alterlist(req_del_steps->steps,del_steps_count)
    SET req_del_steps->steps[del_steps_count].cv_step_id = step_id_stressecg_technologist
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_UPD_STEP failed")
  CALL echorecord(reply)
  CALL echorecord(request)
  CALL echorecord(proc_list)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET curalias procstepschedrec off
 SET curalias reqstepschedrec off
 SET curalias procsteprec off
 SET curalias reqsteprec off
 IF ((reqdata->loglevel >= cv_debug))
  CALL echorecord(reply)
 ENDIF
 CALL cv_log_msg_post("024 03/10/2020 AP067478")
END GO
