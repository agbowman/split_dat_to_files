CREATE PROGRAM cv_exam_update:dba
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
 RECORD request(
   1 study_identifier = vc
   1 modality_cd = f8
   1 performed_provider_id = f8
   1 study_dt_tm = dq8
   1 order_id = f8
   1 performed_start_dt_tm = dq8
   1 performed_stop_dt_tm = dq8
   1 accession = vc
   1 exam_status = c64
   1 vendor_cd = f8
   1 action_tz = i4
   1 pdf_doc_identifier = vc
   1 normalcy_cd = f8
   1 facility_cd = f8
 )
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
 FREE RECORD pref_request
 RECORD pref_request(
   1 context = vc
   1 context_id = vc
   1 section = vc
   1 section_id = vc
   1 groups[*]
     2 name = vc
   1 debug = vc
 )
 FREE RECORD pref_reply
 RECORD pref_reply(
   1 entries[*]
     2 name = vc
     2 values[*]
       3 value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD longtext_request
 RECORD longtext_request(
   1 qual[*]
     2 interpretation_text = vc
     2 interpretation_id = f8
   1 action = i2
 )
 FREE RECORD longtext_reply
 RECORD longtext_reply(
   1 interpretation_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE setperformedtimes(null) = null
 DECLARE resetecgstep(null) = null
 DECLARE resetprocstep(null) = null
 DECLARE resetstressholtersteps(null) = null
 DECLARE cangetactivitysubtypeforecg12lead(null) = null
 DECLARE setprocandstepdetails(null) = null
 DECLARE fetchinerrorreason(null) = vc
 DECLARE fetchinterpretation(null) = vc
 DECLARE study_state_mv = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"MV"))
 DECLARE study_state_n = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"N"))
 DECLARE doc_type_ecg = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"ECG"))
 DECLARE doc_type_dicom = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"DICOM"))
 DECLARE contrib_powerchart = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"POWERCHART"))
 DECLARE activity_subtype_ecg = f8 WITH protect, noconstant(0.0)
 DECLARE doc_type_dicom_pdf = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"DICOMPDF")
  )
 DECLARE dicom_pdf_report_type_stressecg = f8 WITH protect, constant(uar_get_code_by("MEANING",
   4002763,"STRESSECG"))
 DECLARE final_report_step = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "FINALREPORT"))
 DECLARE doc_type_powernote = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"POWERNOTE"
   ))
 DECLARE doc_type_dyndoc = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"DYNDOC"))
 DECLARE isnucmedsprocedure = i2 WITH protect, noconstant(0)
 DECLARE exam_status = c64 WITH protect, noconstant("")
 DECLARE generic_inerror_reason = vc WITH protect, noconstant("")
 DECLARE interpretation_text = vc WITH protect, noconstant("")
 DECLARE g_external_perf_provider_id = f8 WITH public, constant(request->performed_provider_id)
 DECLARE g_cv_login_id = f8 WITH public, constant(0.0)
 SET exam_status = cnvtupper(nullterm(trim(request->exam_status)))
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
 IF ((request->order_id=0))
  CALL cv_log_msg(cv_error,"cv_exam_update is called with an empty orderID")
  SET reply->status_data.subeventstatus[1].operationname = "REQUEST"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_EXAM_UPDATE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDER_ID is 0"
  GO TO exit_script
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
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD cvfp_request(
   1 order_id = f8
   1 withlock_flag = i2
 )
 SET cvfp_request->order_id = request->order_id
 SET cvfp_request->withlock_flag = 2
 EXECUTE cv_fetch_procedure_detail  WITH replace("REQUEST",cvfp_request), replace("REPLY",proc_list)
 IF ((proc_list->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"Failed to load proc_list")
  SET reply->status_data.subeventstatus[1].operationname = "Execute"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_EXAM_UPDATE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "CV_EXAM_UPDATE FAILED due to CV_FETCH_PROCEDURE_DETAIL FAILURE"
  GO TO exit_script
 ENDIF
 IF (size(proc_list->cv_proc,5) != 1)
  CALL cv_log_msg(cv_error,concat("cv_fetch_procedure_detail returned ",cnvtstring(size(proc_list->
      cv_proc,5))," proc"))
  SET reply->status_data.subeventstatus[1].operationname = "FETCH"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_EXAM_UPDATE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCEDURE NOT FOUND"
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
 SET fr_dicompdf_step_idx = locateval(step_idx,1,step_cnt,doc_type_dicom_pdf,proc_list->cv_proc[1].
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
 SET stat = size(proc_list->cv_proc,1)
 IF (((exam_status="COMPLETED") OR (((exam_status="UNLINK") OR (exam_status="INERROR")) )) )
  RECORD clin_event_request(
    1 parent_event_id = f8
    1 pdf_doc_identifier = vc
    1 post_ind = i2
    1 strconclusion = vc
    1 inerror_reason = vc
  )
  SET clin_event_request->parent_event_id = proc_list->cv_proc[1].group_event_id
  IF (exam_status="COMPLETED")
   SET clin_event_request->post_ind = 1
  ELSEIF (exam_status="UNLINK")
   SET clin_event_request->post_ind = 0
  ELSEIF (exam_status="INERROR")
   CALL fetchinerrorreason(null)
   CALL fetchinterpretation(null)
   SET clin_event_request->post_ind = 2
   SET clin_event_request->inerror_reason = generic_inerror_reason
   SET clin_event_request->strconclusion = interpretation_text
  ELSE
   CALL cv_log_msg(cv_error,"Invalid Exam_status and exiting the script")
   GO TO exit_script
  ENDIF
  SET clin_event_request->pdf_doc_identifier = request->pdf_doc_identifier
  EXECUTE cv_update_clinical_event  WITH replace("REQUEST",clin_event_request), replace("REPLY",reply
   )
  IF ((reply->status_data.status != "S"))
   SET reply->status_data.subeventstatus[1].operationname = "Execute"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CV_EXAM_UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "CV_EXAM_UPDATE FAILED due to CV_UPDATE_CLINICAL_EVENT FAILURE"
   CALL cv_log_msg(cv_error,"Failed to add a DOC row into CLINICAL_EVENT")
   GO TO exit_script
  ENDIF
 ENDIF
 CASE (exam_status)
  OF "COMPLETED":
  OF "STORED":
   IF (proc_step_idx > 0)
    IF ((( NOT ((proc_step->step_status_cd IN (step_stat_completed, step_stat_discontinued)))) OR ((
    proc_list->cv_proc[1].study_state_cd=0)
     AND (request->exam_status="STORED"))) )
     CALL setprocandstepdetails(null)
     CALL updatestressecgstatus(proc_stat_completed)
    ENDIF
   ELSE
    SET reply->status_data.status = "Z"
    CALL cv_log_msg(cv_debug,"No ECG Procedural step found")
    GO TO exit_script
   ENDIF
  OF "UNLINK":
  OF "INERROR":
   SET proc_list->cv_proc[1].study_state_cd = study_state_n
   SET proc_list->cv_proc[1].modified_ind = 1
   IF ((proc_list->cv_proc[1].proc_normalcy_cd > 0.0))
    SET proc_list->cv_proc[1].proc_normalcy_cd = - (1)
   ENDIF
   IF (ecg_step_idx > 0)
    CALL resetecgstep(null)
   ELSEIF (((fr_dicompdf_step_idx > 0) OR (((fr_powernote_step_idx > 0) OR (fr_dyndoc_step_idx > 0))
   )) )
    IF (isnucmedsprocedure != 1)
     CALL resetstressholtersteps(null)
    ENDIF
   ENDIF
   IF (proc_step_idx > 0)
    CALL resetprocstep(null)
   ENDIF
  ELSE
   CALL cv_log_msg(cv_debug,"Exam_status not handled, nothing to do")
   SET reply->status_data.status = "Z"
   GO TO exit_script
 ENDCASE
 EXECUTE cv_update_procedure  WITH replace("REQUEST",proc_list), replace("REPLY",reply)
 SUBROUTINE setprocandstepdetails(null)
   SET proc_step->step_status_cd = step_stat_completed
   SET proc_step->match_ind = 1
   SET proc_step->modified_ind = 1
   SET proc_step->perf_start_dt_tm = request->study_dt_tm
   SET proc_step->perf_stop_dt_tm = request->study_dt_tm
   SET proc_step->perf_provider_id = request->performed_provider_id
   SET proc_list->cv_proc[1].study_state_cd = study_state_mv
   SET proc_step->study_identifier = request->study_identifier
   SET proc_step->study_dt_tm = request->study_dt_tm
   SET proc_step->modality_cd = request->modality_cd
   SET proc_step->vendor_cd = request->vendor_cd
   SET proc_step->pdf_doc_identifier = request->pdf_doc_identifier
   SET proc_list->order_action_tz = request->action_tz
   SET proc_list->cv_proc[1].proc_normalcy_cd = request->normalcy_cd
   SET proc_list->cv_proc[1].modified_ind = 1
 END ;Subroutine
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
     ENDCASE
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE resetecgstep(null)
   IF ( NOT ((proc_list->cv_proc[1].proc_status_cd IN (proc_stat_cancelled, proc_stat_discontinued)))
   )
    IF ((request->exam_status="INERROR"))
     SET ecg_step->step_status_cd = step_stat_discontinued
    ELSE
     SET ecg_step->step_status_cd = step_stat_notstarted
    ENDIF
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
    IF ((request->exam_status="INERROR"))
     IF (fr_dicompdf_step_idx > 0)
      SET fr_dicompdf_step->step_status_cd = step_stat_discontinued
      SET fr_dicompdf_step->perf_start_dt_tm = 0.00
      SET fr_dicompdf_step->perf_stop_dt_tm = 0.00
      SET fr_dicompdf_step->perf_provider_id = 0.0
      SET fr_dicompdf_step->perf_loc_cd = 0.0
      SET fr_dicompdf_step->lock_prsnl_id = 0.0
      SET fr_dicompdf_step->modified_ind = 1
     ELSEIF (fr_dyndoc_step_idx > 0)
      SET fr_dyndoc_step->step_status_cd = step_stat_discontinued
      SET fr_dyndoc_step->perf_start_dt_tm = 0.00
      SET fr_dyndoc_step->perf_stop_dt_tm = 0.00
      SET fr_dyndoc_step->perf_provider_id = 0.0
      SET fr_dyndoc_step->perf_loc_cd = 0.0
      SET fr_dyndoc_step->lock_prsnl_id = 0.0
      SET fr_dyndoc_step->modified_ind = 1
     ELSEIF (fr_powernote_step_idx > 0)
      SET fr_powernote_step->step_status_cd = step_stat_discontinued
      SET fr_powernote_step->perf_start_dt_tm = 0.00
      SET fr_powernote_step->perf_stop_dt_tm = 0.00
      SET fr_powernote_step->perf_provider_id = 0.0
      SET fr_powernote_step->perf_loc_cd = 0.0
      SET fr_powernote_step->lock_prsnl_id = 0.0
      SET fr_powernote_step->modified_ind = 1
     ENDIF
    ELSEIF (fr_dicompdf_step > 0)
     SET fr_dicompdf_step->step_status_cd = step_stat_notstarted
     SET fr_dicompdf_step->perf_start_dt_tm = 0.00
     SET fr_dicompdf_step->perf_stop_dt_tm = 0.00
     SET fr_dicompdf_step->perf_provider_id = 0.0
     SET fr_dicompdf_step->perf_loc_cd = 0.0
     SET fr_dicompdf_step->modified_ind = 1
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE resetprocstep(null)
   IF ( NOT ((proc_list->cv_proc[1].proc_status_cd IN (step_stat_cancelled, step_stat_discontinued)))
   )
    IF ((request->exam_status="INERROR"))
     SET proc_step->step_status_cd = step_stat_discontinued
    ELSE
     SET proc_step->step_status_cd = step_stat_notstarted
     SET proc_step->pdf_doc_identifier = ""
     SET proc_step->study_identifier = ""
     SET proc_step->modality_cd = 0.0
     SET proc_step->vendor_cd = 0.0
     SET proc_step->study_dt_tm = 0.0
    ENDIF
   ELSE
    SET proc_step->step_status_cd = step_stat_cancelled
   ENDIF
   CALL updatestressecgstatus(0.0)
   SET proc_step->unmatch_ind = 1
   SET proc_step->modified_ind = 1
   SET proc_step->perf_start_dt_tm = 0.0
   SET proc_step->perf_stop_dt_tm = 0.0
   SET proc_step->perf_provider_id = 0.0
   SET proc_step->perf_loc_cd = 0.0
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
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "Z"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CV_EXAM_UPDATE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO ECG/Procedural Steps found"
    CALL cv_log_msg(cv_debug,
     "CanGetActivitySubtypeForECG12Lead didn't succeed as no ECG Document/Procedural steps found")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE fetchinerrorreason(null)
   SET pref_request->context = "facility"
   SET pref_request->context_id = cnvtstring(request->facility_cd,15,2)
   SET pref_request->section = "module"
   SET pref_request->section_id = "cvnet"
   EXECUTE cv_get_preferences  WITH replace("REQUEST",pref_request), replace("REPLY",pref_reply)
   IF ((pref_reply->status_data.status="F"))
    CALL cv_log_stat(cv_audit,"CALL","Z","FindPreference","generic_inerror_reason")
   ENDIF
   CALL echorecord(pref_reply)
   SET prefcnt = size(pref_reply->entries,5)
   FOR (curpref = 1 TO prefcnt)
     IF ((pref_reply->entries[curpref].name="generic inerror reason"))
      FOR (curvalue = 1 TO size(pref_reply->entries[curpref].values,5))
        SET generic_inerror_reason = pref_reply->entries[curpref].values[curvalue].value
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE fetchinterpretation(null)
   SET stat = alterlist(longtext_request->qual,1)
   IF (ecg_step_idx > 0)
    SET longtext_request->qual[1].interpretation_id = ecg_step->cv_step_id
   ELSEIF (fr_dicompdf_step_idx > 0)
    SET longtext_request->qual[1].interpretation_id = fr_dicompdf_step->cv_step_id
   ELSEIF (fr_powernote_step_idx > 0)
    SET longtext_request->qual[1].interpretation_id = fr_powernote_step->cv_step_id
   ELSEIF (fr_dyndoc_step_idx > 0)
    SET longtext_request->qual[1].interpretation_id = fr_dyndoc_step->cv_step_id
   ENDIF
   SET longtext_request->action = 2
   EXECUTE cv_manage_ecg_interp_text  WITH replace("REQUEST",longtext_request), replace("REPLY",
    longtext_reply)
   IF ((longtext_reply->status_data.status="F"))
    CALL cv_log_stat(cv_audit,"CALL","Z","LONG_TEXT","Fetch LONG_TEXT")
   ENDIF
   SET interpretation_text = longtext_reply->interpretation_text
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL echo("cv_exam_update did not succeed")
  SET reply->status_data.subeventstatus[1].operationname = "Execute"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_EXAM_UPDATE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CV_EXAM_UPDATE FAILED"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 IF ((reqdata->loglevel >= cv_debug))
  CALL echorecord(reply)
 ENDIF
 CALL cv_log_msg_post("000 04/08/24 AS043139")
END GO
