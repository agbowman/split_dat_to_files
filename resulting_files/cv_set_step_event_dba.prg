CREATE PROGRAM cv_set_step_event:dba
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
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_msg(cv_error,"Reply doesn't contain a status block")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE step_cnt = i4 WITH protect
 DECLARE step_idx = i4 WITH protect
 DECLARE step_prsnl_size = i4 WITH protect
 DECLARE g_doc_type_mean = vc WITH protect, noconstant(fillstring(13," "))
 DECLARE set_step_event_failed_ind = i2 WITH private
 DECLARE g_event_id = f8 WITH protect
 DECLARE g_result_status_cd = f8 WITH protect
 DECLARE g_perf_provider_id = f8 WITH protect
 DECLARE g_step_status_cd = f8 WITH protect
 DECLARE step_reltn_cd = f8 WITH protect
 DECLARE g_perf_stop_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE step_id = f8 WITH protect
 DECLARE timezone_name = vc WITH protect
 DECLARE g_perf_dt_tm = dq8 WITH protect, constant(0.0)
 DECLARE proc_id = f8 WITH protect, noconstant(0.0)
 DECLARE step_reltn_cs = i4 WITH protect, constant(4000400)
 DECLARE pattern_type_cs = i4 WITH protect, constant(14409)
 DECLARE pattern_type_ep = f8 WITH protect, constant(uar_get_code_by("MEANING",pattern_type_cs,"EP"))
 DECLARE cs_proc_category = i4 WITH protect, constant(4000560)
 DECLARE e_priv_flag_no = i2 WITH protect, constant(0)
 DECLARE e_priv_flag_unsigned = i2 WITH protect, constant(1)
 DECLARE e_priv_flag_signed = i2 WITH protect, constant(2)
 DECLARE c_step_type_finalreport = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "FINALREPORT"))
 DECLARE c_step_type_refletter = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "REFLETTER"))
 DECLARE c_doc_type_powernote = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,
   "POWERNOTE"))
 DECLARE c_result_status_transcribed = f8 WITH protect, constant(uar_get_code_by("MEANING",8,
   "TRANSCRIBED"))
 DECLARE time_now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE activity_subtype_ecg = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"ECG"))
 DECLARE doc_type_ecg = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"ECG"))
 DECLARE c_normalcy_cd_normal = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"NORMAL"))
 DECLARE c_doc_type_dicompdf = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"DICOMPDF"
   ))
 DECLARE addchartrequest(null) = i4
 DECLARE setperformedtimes(null) = null
 DECLARE updatelongtext(null) = null
 DECLARE updatedicomdata(null) = null
 DECLARE updatecvstepindexonunmatch(null) = null
 DECLARE updatecvstepstatusonunmatch(null) = null
 IF ((request->error_ind=1))
  SET request->unmatch_ind = 1
 ENDIF
 IF (validate(request->cv_step_id,0.0) <= 0.0)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","CV_STEP_ID=0.0")
  GO TO exit_script
 ENDIF
 CALL updatedicomdata(null)
 FREE RECORD proc_req
 RECORD proc_req(
   1 cv_proc[*]
     2 cv_proc_id = f8
   1 cv_step[*]
     2 cv_step_id = f8
     2 cv_step_ind = i2
   1 withlock_flag = i2
   1 fetch_inactive_steps = i2
   1 edit_doc_flag = i2
 )
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
 SET stat = alterlist(proc_req->cv_step,1)
 SET proc_req->cv_step[1].cv_step_id = request->cv_step_id
 SET proc_req->withlock_flag = request->withlock_flag
 SET proc_req->cv_step[1].cv_step_ind = request->cv_step_ind
 IF ((request->unmatch_ind=1))
  SET proc_req->fetch_inactive_steps = 1
 ELSE
  SET proc_req->fetch_inactive_steps = 0
 ENDIF
 CALL echorecord(proc_req)
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",proc_req), replace("REPLY",proc_list)
 CALL echorecord(proc_list)
 IF ((proc_list->status_data.status != "S"))
  DECLARE event_cnt = i4 WITH protect
  DECLARE event_idx = i4 WITH protect
  CALL cv_log_stat(cv_error,"EXECUTE",proc_list->status_data.status,"CV_FETCH_PROCS","")
  SET event_cnt = size(proc_list->status_data.subeventstatus,5)
  FOR (event_idx = 1 TO event_cnt)
    CALL cv_log_stat(cv_audit,proc_list->status_data.subeventstatus[event_idx].operationname,
     proc_list->status_data.subeventstatus[event_idx].operationstatus,proc_list->status_data.
     subeventstatus[event_idx].targetobjectname,proc_list->status_data.subeventstatus[event_idx].
     targetobjectvalue)
  ENDFOR
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET step_cnt = size(proc_list->cv_proc[1].cv_step,5)
 SET curalias proc proc_list->cv_proc[1]
 SET curalias step proc_list->cv_proc[1].cv_step[step_idx]
 IF ((request->error_ind=1))
  SET proc_list->cv_proc[1].cv_step[1].step_status_cd = step_stat_discontinued
  SET proc_list->cv_proc[1].cv_step[1].unmatch_ind = 1
  SET proc_list->cv_proc[1].cv_step[1].modified_ind = 1
 ENDIF
 SET step_idx = locateval(step_idx,1,step_cnt,request->cv_step_id,step->cv_step_id)
 SET step->cv_step_ind = request->cv_step_ind
 IF ((request->unmatch_ind=1))
  SET proc->proc_normalcy_cd = c_normalcy_cd_normal
 ENDIF
 SET g_doc_type_mean = uar_get_code_meaning(step->doc_type_cd)
 CALL cv_log_msg(cv_info,build("g_doc_type_mean=",g_doc_type_mean))
 DECLARE result_stat_inerror = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR"))
 IF (g_doc_type_mean IN ("POWERNOTE", "POWERFORM", "CLINICALNOTE"))
  IF ((proc_list->cv_proc[1].group_event_id=0.0))
   CALL cv_log_stat(cv_warning,"SELECT","F","CV_PROC","GROUP_EVENT_ID=0.0")
  ELSE
   CASE (g_doc_type_mean)
    OF "POWERFORM":
     SELECT
      IF ((step->event_id=0.0))
       PLAN (ce
        WHERE (ce.parent_event_id=proc_list->cv_proc[1].group_event_id)
         AND (ce.event_id != proc_list->cv_proc[1].group_event_id)
         AND ce.valid_until_dt_tm=cnvtdatetime(null_dt_tm)
         AND  NOT (((ce.result_status_cd+ 0.0) IN (result_stat_inerror, reqdata->auth_inerror_cd))))
        JOIN (dfac
        WHERE dfac.parent_entity_id=ce.event_id
         AND dfac.parent_entity_name="CLINICAL_EVENT")
        JOIN (dfa
        WHERE dfa.dcp_forms_activity_id=dfac.dcp_forms_activity_id
         AND ((dfa.dcp_forms_ref_id+ 0.0)=cnvtreal(step->doc_id_str)))
      ELSE
      ENDIF
      INTO "nl:"
      FROM clinical_event ce,
       dcp_forms_activity_comp dfac,
       dcp_forms_activity dfa
      PLAN (ce
       WHERE (ce.event_id=proc_list->cv_proc[1].cv_step[step_idx].event_id)
        AND ce.valid_until_dt_tm=cnvtdatetime(null_dt_tm)
        AND  NOT (((ce.result_status_cd+ 0.0) IN (result_stat_inerror, reqdata->auth_inerror_cd))))
       JOIN (dfac
       WHERE dfac.parent_entity_id=ce.event_id
        AND dfac.parent_entity_name="CLINICAL_EVENT")
       JOIN (dfa
       WHERE dfa.dcp_forms_activity_id=dfac.dcp_forms_activity_id
        AND ((dfa.dcp_forms_ref_id+ 0.0)=cnvtreal(step->doc_id_str)))
      DETAIL
       g_event_id = ce.event_id, g_result_status_cd = ce.result_status_cd, g_perf_provider_id = ce
       .performed_prsnl_id,
       g_perf_stop_dt_tm = ce.performed_dt_tm
      WITH nocounter
     ;end select
    OF "POWERNOTE":
     SELECT
      IF ((step->event_id=0.0))
       PLAN (ce
        WHERE (ce.parent_event_id=proc_list->cv_proc[1].group_event_id)
         AND (ce.event_id != proc_list->cv_proc[1].group_event_id)
         AND ce.valid_until_dt_tm=cnvtdatetime(null_dt_tm)
         AND  NOT (((ce.result_status_cd+ 0.0) IN (result_stat_inerror, reqdata->auth_inerror_cd))))
        JOIN (scs
        WHERE scs.event_id=ce.event_id)
        JOIN (scsp
        WHERE scsp.scd_story_id=scs.scd_story_id
         AND scsp.pattern_type_cd=pattern_type_ep)
        JOIN (scp
        WHERE scp.scr_pattern_id=scsp.scr_pattern_id
         AND (concat(trim(scp.cki_source),"!",trim(scp.cki_identifier))=step->doc_id_str))
      ELSE
      ENDIF
      INTO "nl:"
      FROM clinical_event ce,
       scd_story scs,
       scd_story_pattern scsp,
       scr_pattern scp
      PLAN (ce
       WHERE (ce.event_id=proc_list->cv_proc[1].cv_step[step_idx].event_id)
        AND ce.valid_until_dt_tm=cnvtdatetime(null_dt_tm)
        AND  NOT (((ce.result_status_cd+ 0.0) IN (result_stat_inerror, reqdata->auth_inerror_cd))))
       JOIN (scs
       WHERE scs.event_id=ce.event_id)
       JOIN (scsp
       WHERE scsp.scd_story_id=scs.scd_story_id
        AND scsp.pattern_type_cd=pattern_type_ep)
       JOIN (scp
       WHERE scp.scr_pattern_id=scsp.scr_pattern_id
        AND (concat(trim(scp.cki_source),"!",trim(scp.cki_identifier))=step->doc_id_str))
      DETAIL
       g_event_id = ce.event_id, g_result_status_cd = ce.result_status_cd, g_perf_provider_id = scs
       .author_id,
       g_perf_stop_dt_tm = ce.performed_dt_tm
      WITH nocounter
     ;end select
    OF "CLINICALNOTE":
     SELECT
      IF ((step->event_id=0.0))
       FROM clinical_event ce,
        note_type nt
       PLAN (nt
        WHERE nt.note_type_id=cnvtreal(step->doc_id_str))
        JOIN (ce
        WHERE (ce.parent_event_id=proc_list->cv_proc[1].group_event_id)
         AND (ce.event_id != proc_list->cv_proc[1].group_event_id)
         AND ce.valid_until_dt_tm=cnvtdatetime(null_dt_tm)
         AND  NOT (((ce.result_status_cd+ 0.0) IN (result_stat_inerror, reqdata->auth_inerror_cd)))
         AND ((ce.event_cd+ 0.0)=nt.event_cd))
      ELSE
      ENDIF
      INTO "nl:"
      FROM clinical_event ce
      PLAN (ce
       WHERE (ce.event_id=proc_list->cv_proc[1].cv_step[step_idx].event_id)
        AND ce.valid_until_dt_tm=cnvtdatetime(null_dt_tm)
        AND  NOT (((ce.result_status_cd+ 0.0) IN (result_stat_inerror, reqdata->auth_inerror_cd))))
      DETAIL
       g_event_id = ce.event_id, g_result_status_cd = ce.result_status_cd
       IF (ce.result_status_cd IN (reqdata->auth_auth_cd, reqdata->auth_modified_cd, reqdata->
       auth_altered_cd))
        g_perf_stop_dt_tm = ce.verified_dt_tm, g_perf_provider_id = ce.verified_prsnl_id
       ELSE
        g_perf_stop_dt_tm = ce.performed_dt_tm, g_perf_provider_id = ce.performed_prsnl_id
       ENDIF
      WITH nocounter
     ;end select
    ELSE
     CALL cv_log_stat(cv_warning,"SELECT","F","CV_STEP_REF",concat("DOC_TYPE_CD=",cnvtstring(step->
        doc_type_cd)))
   ENDCASE
   IF (g_event_id=0.0
    AND (((step->event_id > 0.0)) OR ((step->perf_start_dt_tm != 0.0))) )
    SET step->modified_ind = 1
    SET step->event_id = 0.0
    SET step->perf_provider_id = 0.0
    SET step->perf_start_dt_tm = cnvtdatetime(0,0)
    SET step->perf_stop_dt_tm = cnvtdatetime(0,0)
    IF ((step->step_type_cd=c_step_type_refletter))
     SET step->step_status_cd = step_stat_cancelled
    ELSE
     IF ((proc->proc_status_cd IN (proc_stat_cancelled, proc_stat_discontinued)))
      SET step->step_status_cd = step_stat_cancelled
     ELSE
      SET step->step_status_cd = step_stat_notstarted
     ENDIF
    ENDIF
    CALL addtostepprsnl(uar_get_code_by("MEANING",4000400,"ACTPRSNL"),reqinfo->updt_id)
   ELSEIF (g_event_id > 0.0)
    CASE (g_result_status_cd)
     OF reqdata->auth_auth_cd:
     OF reqdata->auth_modified_cd:
     OF reqdata->auth_altered_cd:
      IF ((step->step_type_cd=c_step_type_finalreport)
       AND g_doc_type_mean="POWERNOTE")
       CASE (cv_get_privs(proc->catalog_cd,0.0,g_perf_provider_id,0.0))
        OF e_priv_flag_no:
         SET g_step_status_cd = step_stat_saved
        OF e_priv_flag_unsigned:
         SET g_step_status_cd = step_stat_unsigned
        OF e_priv_flag_signed:
         SET g_step_status_cd = step_stat_completed
        ELSE
         CALL cv_log_stat(cv_warning,"SUBROUTINE","F","CV_GET_PRIVS","RETURN VALUE UNKNOWN")
         SET g_step_status_cd = step_stat_saved
       ENDCASE
      ELSEIF ((step->step_type_cd=c_step_type_refletter)
       AND g_doc_type_mean="CLINICALNOTE"
       AND (step->step_status_cd != step_stat_completed))
       SET stat = addchartrequest(null)
       IF (stat != 0)
        CALL cv_log_stat(cv_warning,"SUBROUTINE","F","AddChartRequest","")
        SET set_step_event_failed_ind = 1
        GO TO unlock
       ENDIF
       SET g_step_status_cd = step_stat_completed
      ELSE
       SET g_step_status_cd = step_stat_completed
      ENDIF
     OF reqdata->auth_inprogress_cd:
     OF reqdata->auth_unauth_cd:
     OF reqdata->auth_anticipated_cd:
     OF reqdata->auth_active_cd:
     OF c_result_status_transcribed:
      IF ((step->step_status_cd=step_stat_unsigned))
       SET g_step_status_cd = step_stat_unsigned
      ELSE
       SET g_step_status_cd = step_stat_saved
      ENDIF
     ELSE
      CALL cv_log_stat(cv_warning,"SELECT","F","CLINICAL_EVENT",concat("RESULT_STATUS_CD=",cnvtstring
        (g_result_status_cd)))
      SET set_step_event_failed_ind = 1
      GO TO unlock
    ENDCASE
    IF ((step->perf_provider_id != g_perf_provider_id))
     CALL addtostepprsnl(uar_get_code_by("MEANING",4000400,"PERFPROV"),step->perf_provider_id)
     SET step->modified_ind = 1
    ELSEIF ((step->step_status_cd != g_step_status_cd))
     CALL addtostepprsnl(uar_get_code_by("MEANING",4000400,"ACTPRSNL"),reqinfo->updt_id)
     SET step->modified_ind = 1
    ELSEIF ((step->event_id != g_event_id))
     SET step->modified_ind = 1
    ENDIF
    IF ((step->step_status_cd != g_step_status_cd))
     CALL setperformedtimes(null)
     SET step->modified_ind = 1
    ENDIF
    SET step->event_id = g_event_id
    SET step->perf_provider_id = g_perf_provider_id
    IF ((step->step_status_cd=step_stat_completed)
     AND (step->perf_stop_dt_tm != g_perf_stop_dt_tm)
     AND g_step_status_cd=step_stat_completed)
     SET step->perf_stop_dt_tm = g_perf_stop_dt_tm
     SET step->modified_ind = 1
    ENDIF
    SET step->step_status_cd = g_step_status_cd
   ENDIF
  ENDIF
 ENDIF
#unlock
 IF ((step->lock_prsnl_id != 0.0))
  CALL cv_log_msg(cv_info,"Setting lock to 0.0")
  SET step->lock_prsnl_id = 0.0
  SET step->modified_ind = 1
 ENDIF
 IF ((step->modified_ind=0)
  AND (proc->modified_ind=0))
  SET reply->status_data.status = "S"
  CALL cv_log_stat(cv_audit,"CHECK","Z","NO CHANGES","")
  GO TO exit_script
 ENDIF
 CALL updatelongtext(null)
 IF ((request->match_ind=1))
  SET step->match_ind = 1
 ENDIF
 IF ((request->unmatch_ind=1))
  SET step->unmatch_ind = 1
 ENDIF
 IF ((request->error_ind=1))
  SET step->step_status_cd = step_stat_discontinued
  SET step->modified_ind = 1
 ENDIF
 IF ((step->modified_ind=1))
  SET step->cv_step_ind = request->cv_step_ind
 ENDIF
 SET proc_list->edit_doc_flag = request->edit_doc_flag
 EXECUTE cv_upd_proc  WITH replace("REQUEST",proc_list)
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,build("cv_upd_proc returned status",reply->status_data.status))
  GO TO exit_script
 ENDIF
 SUBROUTINE (addtostepprsnl(step_reltn_cd=f8,prsnl_id=f8) =null)
   SET step_prsnl_size += 1
   SET stat = alterlist(proc_list->cv_step_prsnl,step_prsnl_size)
   SET proc_list->cv_step_prsnl[step_prsnl_size].action_type_cd = step->step_status_cd
   SET proc_list->cv_step_prsnl[step_prsnl_size].action_dt_tm = cnvtdatetime(sysdate)
   SET proc_list->cv_step_prsnl[step_prsnl_size].cv_step_id = step->cv_step_id
   SET proc_list->cv_step_prsnl[step_prsnl_size].step_prsnl_id = prsnl_id
   SET proc_list->cv_step_prsnl[step_prsnl_size].step_relation_cd = step_reltn_cd
 END ;Subroutine
 SUBROUTINE (cv_get_privs(p_catalog_cd=f8,p_proc_category_cd=f8,p_person_id=f8,p_position_cd=f8) =i2)
   DECLARE c_exception_orderables = f8 WITH protect, constant(uar_get_code_by("MEANING",6015,
     "ORDERABLES"))
   DECLARE c_exception_cvproccat = f8 WITH protect, constant(uar_get_code_by("MEANING",6015,
     "CVPROCCAT"))
   DECLARE c_privilege_cvsigned = f8 WITH protect, constant(uar_get_code_by("MEANING",6016,"CVSIGNED"
     ))
   DECLARE c_privilege_cvunsigned = f8 WITH protect, constant(uar_get_code_by("MEANING",6016,
     "CVUNSIGNED"))
   DECLARE c_priv_value_include = f8 WITH protect, constant(uar_get_code_by("MEANING",6017,"INCLUDE")
    )
   DECLARE priv_flag = i2 WITH protect
   IF ((reqdata->loglevel >= cv_debug))
    CALL cv_log_msg(cv_debug,build("c_exception_ORDERABLES=",c_exception_orderables))
    CALL cv_log_msg(cv_debug,build("c_exception_CVPROCCAT=",c_exception_cvproccat))
    CALL cv_log_msg(cv_debug,build("c_privilege_CVSIGNED=",c_privilege_cvsigned))
    CALL cv_log_msg(cv_debug,build("c_privilege_CVUNSIGNED=",c_privilege_cvunsigned))
    CALL cv_log_msg(cv_debug,build("c_priv_value_INCLUDE=",c_priv_value_include))
   ENDIF
   IF (p_proc_category_cd <= 0.0)
    SELECT INTO "nl:"
     FROM code_value_group cvg
     WHERE cvg.child_code_value=p_catalog_cd
     DETAIL
      IF (uar_get_code_set(cvg.parent_code_value)=cs_proc_category)
       p_proc_category_cd = cvg.parent_code_value
      ENDIF
     WITH nocounter, maxqual(cvg,1)
    ;end select
    IF (p_proc_category_cd <= 0.0)
     CALL cv_log_stat(cv_audit,"SELECT","F","CODE_VALUE_GROUP",build("CHILD_CODE_VALUE=",p_catalog_cd
       ))
     CALL cv_log_msg(cv_audit,"No proc_category_cd found in cv_get_privs subroutine")
    ENDIF
   ENDIF
   CALL cv_log_msg(cv_debug,concat(build("p_proc_category_cd=",p_proc_category_cd)))
   IF (p_position_cd <= 0.0)
    SELECT INTO "nl:"
     FROM prsnl p
     WHERE p.person_id=p_person_id
     DETAIL
      p_position_cd = p.position_cd
     WITH nocounter, maxqual(p,1)
    ;end select
    IF (p_position_cd <= 0.0)
     CALL cv_log_stat(cv_audit,"SELECT","F","PRSNL",build("PERSON_ID=",p.person_id,";POSITION_CD=",
       p_position_cd))
     CALL cv_log_msg(cv_audit,"No position_cd found in cv_get_privs subroutine")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    pe_null = nullind(pe.privilege_id)
    FROM privilege pr,
     priv_loc_reltn plr,
     privilege_exception pe
    PLAN (pr
     WHERE pr.privilege_cd IN (c_privilege_cvsigned, c_privilege_cvunsigned)
      AND pr.priv_value_cd=c_priv_value_include
      AND pr.active_ind=1)
     JOIN (plr
     WHERE plr.priv_loc_reltn_id=pr.priv_loc_reltn_id
      AND ((plr.person_id=p_person_id) OR (plr.position_cd=p_position_cd))
      AND plr.active_ind=1)
     JOIN (pe
     WHERE pe.privilege_id=pr.privilege_id
      AND ((pe.exception_type_cd=c_exception_orderables
      AND pe.exception_id=p_catalog_cd) OR (pe.exception_type_cd=c_exception_cvproccat
      AND pe.exception_id=p_proc_category_cd))
      AND pe.active_ind=1)
    ORDER BY pr.privilege_id
    HEAD pr.privilege_id
     IF (pr.privilege_cd=c_privilege_cvsigned)
      priv_flag = e_priv_flag_signed
     ELSEIF (priv_flag < e_priv_flag_unsigned)
      priv_flag = e_priv_flag_unsigned
     ENDIF
    WITH nocounter
   ;end select
   RETURN(priv_flag)
 END ;Subroutine
 SUBROUTINE addchartrequest(null)
   DECLARE final_report_idx = i4 WITH protect
   DECLARE temp_idx = i4 WITH protect
   DECLARE pref_idx = i4 WITH protect
   DECLARE refer_cnt = i4 WITH protect
   DECLARE refer_idx = i4 WITH protect
   FREE SET cgrli_req
   RECORD cgrli_req(
     1 encntr_id = f8
     1 prim_physician_id = f8
     1 task_assay_cd = f8
     1 catalog_cd = f8
   )
   FREE SET cgrli_reply
   RECORD cgrli_reply(
     1 ref_phys[*]
       2 ref_phys_id = f8
     1 template_id = f8
     1 chart_format_id = f8
     1 on_off_ind = i2
     1 include_report_ind = i2
     1 task_assay_cd = f8
     1 default_output_dest_cd = f8
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE SET ccr_req
   RECORD ccr_req(
     1 person_id = f8
     1 encntr_id = f8
     1 chart_format_id = f8
     1 ref_phys[*]
       2 ref_phys_id = f8
     1 event[*]
       2 event_id = f8
     1 default_output_dest_cd = f8
   )
   FREE SET ccr_reply
   RECORD ccr_reply(
     1 chart_request[*]
       2 chart_request_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET cgrli_req->encntr_id = proc->encntr_id
   SET cgrli_req->prim_physician_id = proc->prim_physician_id
   SET cgrli_req->task_assay_cd = step->task_assay_cd
   EXECUTE cv_get_ref_letter_info  WITH replace("REQUEST",cgrli_req), replace("REPLY",cgrli_reply)
   IF ((cgrli_reply->status_data.status != "S"))
    CALL cv_log_stat(cv_warning,"EXECUTE",cgrli_reply->status_data.status,"CV_GET_REF_LETTER_INFO",""
     )
    RETURN(1)
   ENDIF
   SET refer_cnt = size(cgrli_reply->ref_phys,5)
   IF (refer_cnt=0)
    CALL cv_log_stat(cv_warning,"SELECT","Z","ENCNTR_PRSNL_RELTN","REFERDOC")
    RETURN(1)
   ELSE
    SET stat = alterlist(ccr_req->ref_phys,refer_cnt)
    FOR (refer_idx = 1 TO refer_cnt)
      SET ccr_req->ref_phys[refer_idx].ref_phys_id = cgrli_reply->ref_phys[refer_idx].ref_phys_id
    ENDFOR
   ENDIF
   IF ((cgrli_reply->chart_format_id <= 0.0))
    CALL cv_log_stat(cv_warning,"PREFERENCE","F","chart format",build(cgrli_reply->chart_format_id))
    RETURN(1)
   ENDIF
   SET ccr_req->person_id = proc->person_id
   SET ccr_req->encntr_id = proc->encntr_id
   SET ccr_req->chart_format_id = cgrli_reply->chart_format_id
   SET ccr_req->default_output_dest_cd = cgrli_reply->default_output_dest_cd
   IF ((cgrli_reply->include_report_ind=1))
    SET final_report_idx = locateval(final_report_idx,1,step_cnt,c_step_type_finalreport,proc_list->
     cv_proc[1].cv_step[final_report_idx].step_type_cd,
     c_doc_type_powernote,proc_list->cv_proc[1].cv_step[final_report_idx].doc_type_cd)
   ENDIF
   IF (final_report_idx > 0)
    SET stat = alterlist(ccr_req->event,2)
    SET ccr_req->event[2].event_id = proc_list->cv_proc[1].cv_step[final_report_idx].event_id
   ELSE
    SET stat = alterlist(ccr_req->event,1)
   ENDIF
   SET ccr_req->event[1].event_id = step->event_id
   EXECUTE cv_chart_request  WITH replace("REQUEST",ccr_req), replace("REPLY",ccr_reply)
   IF ((ccr_reply->status_data.status != "S"))
    CALL cv_log_stat(cv_warning,"EXECUTE",ccr_reply->status_data.status,"CV_CHART_REQUEST","")
    CALL echorecord(ccr_req)
    CALL echorecord(ccr_reply)
    CALL echorecord(reply)
    RETURN(1)
   ENDIF
   FREE SET ccr_req
   RETURN(0)
 END ;Subroutine
 SUBROUTINE setperformedtimes(null)
   SELECT INTO "nl:"
    FROM cv_step s
    WHERE (s.cv_step_id=step->cv_step_id)
    DETAIL
     CASE (g_step_status_cd)
      OF step_stat_completed:
       step->perf_stop_dt_tm = time_now,
       IF ((step->perf_start_dt_tm=0.0))
        step->perf_start_dt_tm = time_now
       ENDIF
      OF step_stat_saved:
       IF (s.step_status_cd != step_stat_completed)
        IF (s.step_status_cd=step_stat_notstarted)
         IF ((step->perf_start_dt_tm=0.0))
          step->perf_start_dt_tm = g_perf_stop_dt_tm
         ENDIF
        ENDIF
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE updatelongtext(null)
   SET timezone_index_txt = trim(build2(curtimezoneapp),7)
   SELECT
    FROM long_text lt
    WHERE lt.parent_entity_name="CV_ACTION_TZ"
     AND (lt.parent_entity_id=request->cv_step_id)
   ;end select
   IF (curqual > 0)
    UPDATE  FROM long_text lt
     SET lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm
       = cnvtdatetime(sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = timezone_index_txt, lt
      .updt_applctx = reqinfo->updt_applctx,
      lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->
      updt_id,
      lt.updt_task = reqinfo->updt_task
     WHERE (lt.parent_entity_id=request->cv_step_id)
      AND trim(lt.parent_entity_name)="CV_ACTION_TZ"
     WITH nocounter
    ;end update
   ELSE
    INSERT  FROM long_text lt
     SET lt.parent_entity_name = "CV_ACTION_TZ", lt.long_text = timezone_index_txt, lt
      .parent_entity_id = request->cv_step_id,
      lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_cnt = 0, lt.updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.active_ind = 1,
      lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm = cnvtdatetime(sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id,
      lt.long_text_id = seq(long_data_seq,nextval)
     WITH nocounter
    ;end insert
   ENDIF
   SET proc_list->order_action_tz = curtimezoneapp
 END ;Subroutine
 SUBROUTINE updatedicomdata(null)
   DECLARE procidtmp = f8 WITH protect, noconstant(0.0)
   FREE RECORD update_normalcy_req
   RECORD update_normalcy_req(
     1 procedure_id = f8
   )
   SELECT INTO "nl:"
    FROM cv_normalcy_classification c
    WHERE c.active_ind=1
     AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
    WITH nocounter, separator = " ", format
   ;end select
   IF ((request->match_ind=1)
    AND curqual > 0)
    SELECT INTO "nl:"
     FROM cv_step cs,
      cv_step_ref csr,
      cv_proc cp
     PLAN (cs
      WHERE (cs.cv_step_id=request->cv_step_id))
      JOIN (csr
      WHERE cs.task_assay_cd=csr.task_assay_cd
       AND csr.doc_type_cd=doc_type_ecg)
      JOIN (cp
      WHERE cs.cv_proc_id=cp.cv_proc_id
       AND cp.activity_subtype_cd=activity_subtype_ecg)
     DETAIL
      procidtmp = cp.cv_proc_id
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET update_normalcy_req->procedure_id = procidtmp
     EXECUTE cv_match_update_dicom_data  WITH replace("REQUEST",update_normalcy_req), replace("REPLY",
      reply)
    ELSE
     SET reply->status_data.subeventstatus[1].operationstatus = "Z"
     SET reply->status_data.status = "Z"
     CALL cv_log_stat(cv_warning,"VALIDATE","Z","CV_SET_STEP_EVENT",
      "No procedures qualified for Normalcy Update")
    ENDIF
   ELSEIF ((request->match_ind=1)
    AND curqual=0)
    CALL cv_log_stat(cv_error,"VALIDATE","F","CV_SET_STEP_EVENT",
     "No active ECG Classification-Normalcy Mappings found")
   ENDIF
 END ;Subroutine
#exit_script
 IF (set_step_event_failed_ind=1)
  SET reply->status_data.status = "F"
 ENDIF
 IF ((reply->status_data.status != "S"))
  SET reqinfo->commit_ind = 0
  CALL echorecord(request)
  CALL echorecord(reply)
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("MOD 030 01/14/20 MA044943")
END GO
