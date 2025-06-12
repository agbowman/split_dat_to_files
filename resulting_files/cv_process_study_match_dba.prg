CREATE PROGRAM cv_process_study_match:dba
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
 DECLARE setperformedtimes(null) = null
 DECLARE updatelongtext(null) = null
 DECLARE getsendingdeviceid(null) = null
 DECLARE updatedicomdata(null) = null
 DECLARE getmanufacturer(null) = null
 DECLARE updatecvstepindicator(null) = null
 DECLARE resetecgstep(null) = null
 DECLARE resetprocstep(null) = null
 DECLARE setprocedureactivitysubtype(null) = null
 DECLARE resetstressholtersteps(null) = null
 DECLARE cangetactivitysubtypeforecg12lead(null) = null
 DECLARE finddicommodality(null) = i2
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
 DECLARE study_state_mv = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"MV"))
 DECLARE study_state_n = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"N"))
 DECLARE doc_type_ecg = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"ECG"))
 DECLARE doc_type_dicom = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"DICOM"))
 DECLARE doc_type_dicompdf = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"DICOMPDF"))
 DECLARE doc_type_powernote = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"POWERNOTE"
   ))
 DECLARE doc_type_dyndoc = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"DYNDOC"))
 DECLARE contrib_powerchart = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"POWERCHART"))
 DECLARE activity_subtype_ecg = f8 WITH protect, noconstant(0.0)
 DECLARE doc_type_dicom_pdf = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"DICOMPDF")
  )
 DECLARE dicom_pdf_report_type_stressecg = f8 WITH protect, constant(uar_get_code_by("MEANING",
   4002763,"STRESSECG"))
 DECLARE cnvtstr2secs(p_time_str=vc) = i4
 DECLARE cnvtdttmnoshift(p_internal_dt=i4,p_tm_secs=i4) = dq8
 DECLARE time_now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE timezone_name = vc WITH protect
 DECLARE timezoneindex = i4 WITH protect
 DECLARE sendingdeviceid = f8 WITH protect, noconstant(0.0)
 DECLARE manufacturer = vc WITH protect, noconstant("")
 DECLARE mortara_manufacturer = vc WITH protect, constant("Mortara Instrument, Inc.")
 DECLARE activity_subtype_echo_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"ECHO"))
 DECLARE proc_activity_subtype_cd = f8 WITH protect, noconstant(0.0)
 DECLARE isnucmedsprocedure = i2 WITH protect, noconstant(0)
 DECLARE series_count = i4 WITH public, noconstant(0)
 DECLARE isecgfound = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE cva.alias="ECG"
   AND cva.code_set=5801
   AND cva.contributor_source_cd=contrib_powerchart
   AND ((cva.alias_type_meaning=null) OR (((cva.alias_type_meaning <= " ") OR (cva.alias_type_meaning
  ="DEFAULT")) ))
  DETAIL
   activity_subtype_ecg = cva.code_value
  WITH nocounter
 ;end select
 IF (activity_subtype_ecg <= 0.0)
  CALL cv_log_msg(cv_error,"Failed to lookup ECG modality")
  GO TO exit_script
 ENDIF
 IF (size(request->cv_proc,5)=0)
  CALL cv_log_msg(cv_error,"cv_process_study_match called with an empty procedure list")
  GO TO exit_script
 ELSEIF (size(request->cv_proc,5) > 1)
  CALL cv_log_msg(cv_warning,"Extra cv_proc_id values ignored. Only 1 proc currently supported")
 ENDIF
 CALL updatedicomdata(null)
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
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD seriesrec
 RECORD seriesrec(
   1 series[*]
     2 mpps_id = f8
     2 series_id = f8
     2 modality = vc
 )
 RECORD cvfp_request(
   1 cv_proc[*]
     2 cv_proc_id = f8
   1 withlock_flag = i2
   1 fetch_inactive_steps = i2
 )
 SET stat = alterlist(cvfp_request->cv_proc,1)
 SET cvfp_request->cv_proc[1].cv_proc_id = request->cv_proc[1].cv_proc_id
 SET cvfp_request->withlock_flag = 2
 IF ((request->study_state_cd=study_state_n))
  SET cvfp_request->fetch_inactive_steps = 1
 ELSE
  SET cvfp_request->fetch_inactive_steps = 0
 ENDIF
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",cvfp_request), replace("REPLY",proc_list)
 IF ((proc_list->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"Failed to load proc_list")
  GO TO exit_script
 ENDIF
 IF (size(proc_list->cv_proc,5) != 1)
  CALL cv_log_msg(cv_error,concat("cv_fetch_procs returned ",cnvtstring(size(proc_list->cv_proc,5)),
    " procs"))
  GO TO exit_script
 ENDIF
 DECLARE step_idx = i4 WITH protect
 DECLARE step_cnt = i4 WITH protect, noconstant(size(proc_list->cv_proc[1].cv_step,5))
 DECLARE ecg_step_idx = i4 WITH protect
 DECLARE proc_step_idx = i4 WITH protect
 DECLARE fr_dicompdf_step_idx = i4 WITH protect
 DECLARE fr_powernote_step_idx = i4 WITH protect
 DECLARE fr_dyndoc_step_idx = i4 WITH protect
 SET curalias ecg_step proc_list->cv_proc[1].cv_step[ecg_step_idx]
 SET curalias proc_step proc_list->cv_proc[1].cv_step[proc_step_idx]
 SET curalias fr_dicompdf_step proc_list->cv_proc[1].cv_step[fr_dicompdf_step_idx]
 SET curalias fr_powernote_step proc_list->cv_proc[1].cv_step[fr_powernote_step_idx]
 SET curalias fr_dyndoc_step proc_list->cv_proc[1].cv_step[fr_dyndoc_step_idx]
 CALL cangetactivitysubtypeforecg12lead(0)
 SET fr_dicompdf_step_idx = locateval(step_idx,1,step_cnt,doc_type_dicompdf,proc_list->cv_proc[1].
  cv_step[step_idx].doc_type_cd)
 IF (fr_dicompdf_step_idx=0)
  CALL cv_log_msg(cv_debug,"FinalReport DICOM-PDF step not found")
 ELSE
  CALL cv_log_msg(cv_debug,build("FinalReport DICOM-PDF Step found at index=",fr_dicompdf_step_idx))
  IF (dicom_pdf_report_type_stressecg=uar_get_code_by("MEANING",4002763,cnvtupper(proc_list->cv_proc[
    1].cv_step[fr_dicompdf_step_idx].doc_id_str)))
   SET isnucmedsprocedure = 1
   CALL cv_log_msg(cv_debug,build("It is a Nucmeds Procedure and IsNucmedsProcedure = ",
     isnucmedsprocedure))
  ENDIF
 ENDIF
 SET fr_powernote_step_idx = locateval(step_idx,1,step_cnt,doc_type_powernote,proc_list->cv_proc[1].
  cv_step[step_idx].doc_type_cd)
 IF (fr_powernote_step_idx=0)
  CALL cv_log_msg(cv_debug,"FinalReport POWERNOTE step not found")
 ELSE
  CALL cv_log_msg(cv_debug,build("FinalReport POWERNOTE Step found at index=",fr_powernote_step_idx))
 ENDIF
 SET fr_dyndoc_step_idx = locateval(step_idx,1,step_cnt,doc_type_dyndoc,proc_list->cv_proc[1].
  cv_step[step_idx].doc_type_cd)
 IF (fr_dyndoc_step_idx=0)
  CALL cv_log_msg(cv_debug,"FinalReport DYNDOC step not found")
 ELSE
  CALL cv_log_msg(cv_debug,build("FinalReport DYNDOC Step found at index=",fr_dyndoc_step_idx))
 ENDIF
 CALL setprocedureactivitysubtype(null)
 IF (activity_subtype_echo_cd != proc_activity_subtype_cd
  AND (request->study_state_cd != study_state_n))
  IF (fr_dicompdf_step_idx > 0
   AND ((fr_powernote_step_idx > 0) OR (fr_dyndoc_step_idx > 0)) )
   IF (isnucmedsprocedure != 1)
    CALL updatecvstepindicator(null)
   ENDIF
  ENDIF
 ENDIF
 DECLARE g_perf_dt_tm = dq8 WITH protect
 CASE (request->study_state_cd)
  OF study_state_mv:
   IF ((((proc_list->cv_proc[1].proc_status_cd=proc_stat_signed)) OR ((proc_list->cv_proc[1].
   proc_status_cd=proc_stat_unsigned))) )
    CALL cv_log_msg(cv_debug,
     "No action required on a Match Viewable - Signed Procedure . Nothing to Update.")
    SET reply->status_data.status = "S"
    GO TO exit_script
   ENDIF
   IF (ecg_step_idx > 0)
    IF ( NOT ((proc_list->cv_proc[1].proc_status_cd IN (proc_stat_cancelled, proc_stat_discontinued,
    proc_stat_edreview))))
     SET ecg_step->step_status_cd = step_stat_saved
     CALL setperformedtimes(null)
     SET ecg_step->modified_ind = 1
    ELSEIF ((ecg_step->step_status_cd=step_stat_edreview))
     SET ecg_step->step_status_cd = step_stat_edreview
     CALL setperformedtimes(null)
     SET ecg_step->modified_ind = 1
    ELSEIF ((ecg_step->step_status_cd != step_stat_discontinued))
     SET ecg_step->step_status_cd = step_stat_discontinued
     CALL setperformedtimes(null)
     SET ecg_step->modified_ind = 1
    ENDIF
   ENDIF
   CALL setperformedstartstopdttm(null)
   IF (proc_step_idx > 0)
    IF ( NOT ((proc_step->step_status_cd IN (step_stat_completed, step_stat_discontinued))))
     IF (activity_subtype_ecg != proc_activity_subtype_cd)
      CALL finddicommodality(null)
      IF (isecgfound=1)
       CALL cv_log_msg(cv_debug,
        "The DICOM is of Modality ECG. Nothing to do in CV_PROCESS_STUDY_MATCH.")
       SET proc_step->step_status_cd = step_stat_completed
       SET proc_step->modified_ind = 1
       SET proc_step->perf_start_dt_tm = g_perf_dt_tm
       SET proc_step->perf_stop_dt_tm = g_perf_dt_tm
       CALL updatestressecgstatus(proc_stat_completed)
      ELSE
       CALL cv_log_msg(cv_debug,
        "The DICOM is not of Modality ECG. Nothing to do in CV_PROCESS_STUDY_MATCH.")
       SET reply->status_data.status = "S"
       GO TO exit_script
      ENDIF
     ELSE
      SET proc_step->step_status_cd = step_stat_completed
      SET proc_step->modified_ind = 1
      SET proc_step->perf_start_dt_tm = g_perf_dt_tm
      SET proc_step->perf_stop_dt_tm = g_perf_dt_tm
     ENDIF
    ENDIF
   ENDIF
  OF study_state_n:
   IF (ecg_step_idx > 0)
    CALL resetecgstep(null)
   ELSEIF (((fr_powernote_step_idx > 0) OR (((fr_dyndoc_step_idx > 0) OR (fr_dicompdf_step_idx > 0))
   )) )
    IF (isnucmedsprocedure != 1)
     CALL resetstressholtersteps(null)
    ENDIF
   ENDIF
   IF (proc_step_idx > 0)
    CALL resetprocstep(null)
   ENDIF
  ELSE
   CALL cv_log_msg(cv_debug,"request->study_state_cd not handled, nothing to do")
   SET reply->status_data.status = "Z"
   GO TO exit_script
 ENDCASE
 IF ((request->action_flag=7))
  CALL updatelongtext(null)
 ENDIF
 EXECUTE cv_upd_proc  WITH replace("REQUEST",proc_list), replace("REPLY",reply)
 SUBROUTINE setperformedtimes(null)
   SELECT INTO "nl:"
    FROM cv_step s
    WHERE (s.cv_step_id=ecg_step->cv_step_id)
    DETAIL
     CASE (ecg_step->step_status_cd)
      OF step_stat_notstarted:
      OF step_stat_cancelled:
      OF step_stat_discontinued:
       ecg_step->perf_start_dt_tm = cnvtdatetime(0,0),ecg_step->perf_stop_dt_tm = cnvtdatetime(0,0)
      OF step_stat_saved:
       IF (s.step_status_cd != step_stat_completed)
        IF ((ecg_step->perf_start_dt_tm=0.0))
         ecg_step->perf_start_dt_tm = time_now
        ENDIF
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE updatelongtext(null)
   CALL getsendingdeviceid(null)
   SELECT INTO "nl:"
    FROM im_device d
    WHERE d.im_device_id=sendingdeviceid
    DETAIL
     timezoneindex = d.timezone
   ;end select
   SET timezone_index_txt = build(timezoneindex)
   SELECT
    FROM long_text lt
    WHERE lt.parent_entity_name="CV_ACTION_TZ"
     AND (lt.parent_entity_id=ecg_step->cv_step_id)
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
     WHERE (lt.parent_entity_id=ecg_step->cv_step_id)
      AND trim(lt.parent_entity_name)="CV_ACTION_TZ"
     WITH nocounter
    ;end update
   ELSE
    INSERT  FROM long_text lt
     SET lt.parent_entity_name = "CV_ACTION_TZ", lt.long_text = timezone_index_txt, lt
      .parent_entity_id = ecg_step->cv_step_id,
      lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_cnt = 0, lt.updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.active_ind = 1,
      lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm = cnvtdatetime(sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id,
      lt.long_text_id = seq(long_data_seq,nextval)
     WITH nocounter
    ;end insert
   ENDIF
   SET proc_list->order_action_tz = timezoneindex
 END ;Subroutine
 SUBROUTINE getsendingdeviceid(null)
   IF ((request->im_acquired_study_id > 0.0))
    SELECT INTO "nl:"
     FROM im_acquired_study ias
     WHERE (ias.im_acquired_study_id=request->im_acquired_study_id)
     DETAIL
      IF (ias.sending_device_id > 0.0)
       sendingdeviceid = ias.sending_device_id
      ELSE
       IF (ias.im_device_id > 0.0)
        sendingdeviceid = ias.im_device_id
       ENDIF
      ENDIF
     WITH nocounter, maxqual(ias,1)
    ;end select
   ELSE
    CALL cv_log_msg(cv_warning,"No valid im_acquired_study_id in request")
   ENDIF
 END ;Subroutine
 SUBROUTINE updatedicomdata(null)
   IF ((request->study_state_cd=study_state_mv))
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
    IF (curqual > 0)
     SELECT INTO "nl:"
      FROM cv_proc cp,
       cv_step cs,
       cv_step_ref csr
      PLAN (cp
       WHERE (cp.cv_proc_id=request->cv_proc[1].cv_proc_id)
        AND cp.activity_subtype_cd=activity_subtype_ecg
        AND  NOT (cp.proc_status_cd IN (proc_stat_cancelled, proc_stat_discontinued)))
       JOIN (cs
       WHERE cs.cv_proc_id=cp.cv_proc_id)
       JOIN (csr
       WHERE cs.task_assay_cd=csr.task_assay_cd
        AND csr.doc_type_cd=doc_type_ecg)
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET update_normalcy_req->procedure_id = request->cv_proc[1].cv_proc_id
      EXECUTE cv_match_update_dicom_data  WITH replace("REQUEST",update_normalcy_req), replace(
       "REPLY",reply)
     ELSE
      SET reply->status_data.subeventstatus[1].operationstatus = "Z"
      SET reply->status_data.status = "Z"
      CALL cv_log_stat(cv_warning,"VALIDATE","Z","CV_PROCESS_STUDY_MATCH",
       "No procedures qualified for Normalcy Update")
     ENDIF
    ELSE
     CALL cv_log_stat(cv_error,"VALIDATE","F","CV_PROCESS_STUDY_MATCH",
      "No active ECG Classification-Normalcy Mappings found")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE setperformedstartstopdttm(null)
   IF ((request->im_acquired_study_id > 0.0))
    SELECT INTO "nl:"
     FROM im_acquired_study ias
     WHERE (ias.im_acquired_study_id=request->im_acquired_study_id)
     DETAIL
      g_perf_dt_tm = cnvtdatetimeutc2(ias.study_date,"YYYYMMDD",substring(1,6,concat(ias.study_time,
         "000000")),"HHMMSS",0),
      CALL cv_log_msg(cv_info,datetimezoneformat(g_perf_dt_tm,curtimezoneapp,
       "DD-MMM-YYYY HH:mm:ss ZZZZZZ"))
     WITH nocounter, maxqual(ias,1)
    ;end select
   ELSE
    CALL cv_log_msg(cv_warning,"No valid im_acquired_study_id in request")
   ENDIF
 END ;Subroutine
 SUBROUTINE getmanufacturer(null)
   SELECT INTO "nl:"
    FROM im_acquired_study ias
    WHERE (ias.im_acquired_study_id=request->im_acquired_study_id)
    DETAIL
     manufacturer = ias.manufacturer
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE updatecvstepindicator(null)
  CALL getmanufacturer(null)
  IF (mortara_manufacturer=manufacturer)
   IF (fr_powernote_step_idx > 0)
    SET fr_powernote_step->modified_ind = 1
    SET fr_powernote_step->cv_step_ind = 1
   ELSEIF (fr_dyndoc_step_idx > 0)
    SET fr_dyndoc_step->modified_ind = 1
    SET fr_dyndoc_step->cv_step_ind = 1
   ENDIF
  ELSEIF (fr_dicompdf_step_idx > 0)
   SET fr_dicompdf_step->modified_ind = 1
   SET fr_dicompdf_step->cv_step_ind = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE resetecgstep(null)
   IF ( NOT ((proc_list->cv_proc[1].proc_status_cd IN (proc_stat_cancelled, proc_stat_discontinued)))
   )
    SET ecg_step->step_status_cd = step_stat_notstarted
   ELSE
    SET ecg_step->step_status_cd = step_stat_cancelled
   ENDIF
   SET ecg_step->modified_ind = 1
   CALL setperformedtimes(null)
   SET ecg_step->perf_provider_id = 0.0
   SET ecg_step->perf_loc_cd = 0.0
 END ;Subroutine
 SUBROUTINE resetstressholtersteps(null)
   IF ( NOT ((proc_list->cv_proc[1].proc_status_cd IN (proc_stat_cancelled, proc_stat_discontinued)))
   )
    IF (fr_dicompdf_step_idx > 0)
     SET fr_dicompdf_step->modified_ind = 1
     SET fr_dicompdf_step->cv_step_ind = 0
    ENDIF
    IF (fr_powernote_step_idx > 0)
     SET fr_powernote_step->modified_ind = 1
     SET fr_powernote_step->cv_step_ind = 0
    ELSEIF (fr_dyndoc_step_idx > 0)
     SET fr_dyndoc_step->modified_ind = 1
     SET fr_dyndoc_step->cv_step_ind = 0
    ENDIF
    IF ((fr_dicompdf_step->step_status_cd=step_stat_saved))
     SET fr_dicompdf_step->step_status_cd = step_stat_notstarted
     SET fr_dicompdf_step->perf_start_dt_tm = g_perf_dt_tm
     SET fr_dicompdf_step->perf_stop_dt_tm = g_perf_dt_tm
     SET fr_dicompdf_step->perf_provider_id = 0.0
     SET fr_dicompdf_step->perf_loc_cd = 0.0
    ELSEIF ((fr_dicompdf_step->step_status_cd=step_stat_completed))
     SET fr_dicompdf_step->step_status_cd = step_stat_notstarted
     SET fr_dicompdf_step->perf_start_dt_tm = g_perf_dt_tm
     SET fr_dicompdf_step->perf_stop_dt_tm = g_perf_dt_tm
     SET fr_dicompdf_step->perf_provider_id = 0.0
     SET fr_dicompdf_step->perf_loc_cd = 0.0
    ELSEIF ((fr_dicompdf_step->step_status_cd=step_stat_unsigned))
     SET fr_dicompdf_step->step_status_cd = step_stat_notstarted
     SET fr_dicompdf_step->perf_start_dt_tm = g_perf_dt_tm
     SET fr_dicompdf_step->perf_stop_dt_tm = g_perf_dt_tm
     SET fr_dicompdf_step->perf_provider_id = 0.0
     SET fr_dicompdf_step->perf_loc_cd = 0.0
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE resetprocstep(null)
   IF ( NOT ((proc_list->cv_proc[1].proc_status_cd IN (step_stat_cancelled, step_stat_discontinued)))
   )
    SET proc_step->step_status_cd = step_stat_notstarted
    CALL updatestressecgstatus(0.0)
   ELSE
    SET proc_step->step_status_cd = step_stat_cancelled
   ENDIF
   SET proc_step->modified_ind = 1
   SET proc_step->perf_start_dt_tm = 0.0
   SET proc_step->perf_stop_dt_tm = 0.0
   SET proc_step->perf_provider_id = 0.0
   SET proc_step->perf_loc_cd = 0.0
 END ;Subroutine
 SUBROUTINE setprocedureactivitysubtype(null)
   SELECT INTO "nl:"
    FROM cv_proc c
    WHERE (c.cv_proc_id=request->cv_proc[1].cv_proc_id)
    DETAIL
     proc_activity_subtype_cd = c.activity_subtype_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (updatestressecgstatus(stressecgstatuscd=f8) =null)
   DECLARE empty_doc_type_cd = f8 WITH private, constant(0.0)
   DECLARE tech_stressecg_step = i4 WITH private, noconstant(0)
   DECLARE final_report_stressecg_step = i4 WITH private, noconstant(0)
   SET tech_stressecg_step = locateval(step_idx,1,step_cnt,dicom_pdf_report_type_stressecg,
    uar_get_code_by("MEANING",4002763,cnvtupper(proc_list->cv_proc[1].cv_step[step_idx].doc_id_str)),
    empty_doc_type_cd,proc_list->cv_proc[1].cv_step[step_idx].doc_type_cd)
   SET final_report_stressecg_step = locateval(step_idx,1,step_cnt,dicom_pdf_report_type_stressecg,
    uar_get_code_by("MEANING",4002763,cnvtupper(proc_list->cv_proc[1].cv_step[step_idx].doc_id_str)),
    doc_type_dicom_pdf,proc_list->cv_proc[1].cv_step[step_idx].doc_type_cd)
   IF (((final_report_stressecg_step > 0) OR (tech_stressecg_step > 0)) )
    SET proc_list->cv_proc[1].stress_ecg_status_cd = stressecgstatuscd
    SET proc_list->cv_proc[1].modified_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cangetactivitysubtypeforecg12lead(null)
   SET ecg_step_idx = locateval(step_idx,1,step_cnt,doc_type_ecg,proc_list->cv_proc[1].cv_step[
    step_idx].doc_type_cd)
   IF (ecg_step_idx=0)
    CALL cv_log_msg(cv_debug,"ECG Documentation Step not found")
   ELSE
    CALL cv_log_msg(cv_debug,build("ECG Documentation Step found at index=",ecg_step_idx))
   ENDIF
   SET proc_step_idx = locateval(step_idx,1,step_cnt,activity_subtype_ecg,proc_list->cv_proc[1].
    cv_step[step_idx].activity_subtype_cd,
    doc_type_dicom,proc_list->cv_proc[1].cv_step[step_idx].doc_type_cd)
   IF (proc_step_idx=0)
    CALL cv_log_msg(cv_debug,"ECG Procedural step not found")
   ELSE
    CALL cv_log_msg(cv_debug,build("ECG Procedural Step found at index=",proc_step_idx))
   ENDIF
   IF (ecg_step_idx=0
    AND proc_step_idx=0)
    SET reply->status_data.status = "Z"
    CALL cv_log_msg(cv_debug,
     "CanGetActivitySubtypeForECG12Lead dint succeed as no ECG Document/Procedural steps found")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE finddicommodality(null)
   FREE RECORD seriesrec
   RECORD seriesrec(
     1 series[*]
       2 modality = vc
   )
   SELECT INTO "n1:"
    FROM im_acquired_study i,
     im_mpps mpps,
     im_series ise
    PLAN (i
     WHERE (i.im_acquired_study_id=request->im_acquired_study_id))
     JOIN (mpps
     WHERE mpps.parent_entity_id=i.im_acquired_study_id)
     JOIN (ise
     WHERE ise.im_mpps_id=mpps.im_mpps_id)
    HEAD REPORT
     series_count = 0, stat = alterlist(seriesrec->series,5)
    DETAIL
     series_count += 1
     IF (mod(series_count,5)=1
      AND series_count != 1)
      stat = alterlist(seriesrec->series,(series_count+ 4))
     ENDIF
     seriesrec->series[series_count].modality = ise.modality
     IF ((seriesrec->series[series_count].modality="ECG"))
      isecgfound = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(seriesrec->series,series_count)
    WITH nocounter
   ;end select
   RETURN(isecgfound)
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL echo("cv_process_study_match did not succeed")
  SET reqinfo->commit_ind = 0
  CALL echorecord(request)
  CALL echorecord(reply)
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("028 03/01/21 SS028138")
END GO
