CREATE PROGRAM cv_process_doc_action:dba
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(sysdate),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt += 1
 ENDIF
 SUBROUTINE (cv_log_createhandle(dummy=i2) =null)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 SUBROUTINE (cv_log_current_default(dummy=i2) =null)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 SUBROUTINE (cv_echo(string=vc) =null)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_message(log_message_param=vc) =null)
   SET cv_log_err_num += 1
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_message_status(object_name_param=vc,operation_status_param=c1,
  operation_name_param=vc,target_object_value_param=vc) =null)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event += 1
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event += 1
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_check_err(opname=vc,opstatus=c1,targetname=vc) =null)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(sysdate),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 DECLARE g_step_status_cd = f8 WITH protect
 DECLARE result_status_mean = vc WITH noconstant(uar_get_code_meaning(request->result_status_cd)),
 protect
 DECLARE step_list_cnt = i4 WITH protect
 DECLARE pattern_type_ep = f8 WITH constant(uar_get_code_by("MEANING",14409,"EP")), protect
 DECLARE g_doc_id_str = vc WITH protect
 DECLARE g_dcp_forms_ref_id = f8 WITH protect
 DECLARE step_cnt = i4 WITH protect
 DECLARE step_idx = i4 WITH protect
 DECLARE doc_type_powerform = f8 WITH constant(uar_get_code_by("MEANING",4000360,"POWERFORM")),
 protect
 DECLARE doc_type_powernote = f8 WITH constant(uar_get_code_by("MEANING",4000360,"POWERNOTE")),
 protect
 DECLARE step_status_notstarted = f8 WITH constant(uar_get_code_by("MEANING",4000440,"NOTSTARTED")),
 protect
 DECLARE step_status_saved = f8 WITH constant(uar_get_code_by("MEANING",4000440,"SAVED")), protect
 DECLARE step_status_unsigned = f8 WITH constant(uar_get_code_by("MEANING",4000440,"UNSIGNED")),
 protect
 DECLARE step_status_completed = f8 WITH constant(uar_get_code_by("MEANING",4000440,"COMPLETED")),
 protect
 DECLARE time_now = q8 WITH constant(cnvtdatetime(sysdate)), protect
 SET modify = predeclare
 SET curalias proc proc_list->cv_proc[1]
 SET curalias step proc_list->cv_proc[1].cv_step[step_idx]
 IF (validate(reply) != 1)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request->cv_proc_id,0.0)=0.0)
  CALL cv_log_message("request->cv_proc_id missing or not set")
  GO TO exit_script
 ENDIF
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
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD proc_req(
   1 cv_proc[*]
     2 cv_proc_id = f8
   1 withlock_flag = i2
   1 fetch_inactive_steps = i2
 )
 RECORD step_list(
   1 step[*]
     2 step_idx = i4
 )
 SET stat = alterlist(proc_req->cv_proc,1)
 SET proc_req->cv_proc[1].cv_proc_id = request->cv_proc_id
 SET proc_req->withlock_flag = 0
 SET proc_req->fetch_inactive_steps = 0
 CALL echorecord(proc_req)
 SET modify = nopredeclare
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",proc_req), replace("REPLY",proc_list)
 SET modify = predeclare
 IF (validate(proc->cv_proc_id,0.0)=0.0)
  CALL cv_log_message("cv_fetch_procs failed")
  GO TO exit_script
 ENDIF
 SET step_cnt = size(proc->cv_step,5)
 SET step_idx = locateval(step_idx,1,step_cnt,request->event_id,step->event_id)
 WHILE (step_idx > 0)
   SET step_list_cnt += 1
   SET stat = alterlist(step_list->step,step_list_cnt)
   SET step_list->step[step_list_cnt].step_idx = step_idx
   SET step_idx = locateval(step_idx,(step_idx+ 1),step_cnt,request->event_id,step->event_id)
 ENDWHILE
 CALL echorecord(step_list)
 CASE (request->doc_type_cd)
  OF doc_type_powerform:
   SELECT INTO "nl:"
    l_doc_id_str = cnvtstring(dfa.dcp_forms_ref_id)
    FROM dcp_forms_activity dfa
    WHERE (dfa.dcp_forms_activity_id=request->doc_id)
    DETAIL
     step_idx = locateval(step_idx,1,step_cnt,0.0,step->event_id,
      doc_type_powerform,step->doc_type_cd,l_doc_id_str,step->doc_id_str),
     CALL cv_log_message(build("PF find:",step_idx))
     WHILE (step_idx > 0)
       step_list_cnt += 1, stat = alterlist(step_list->step,step_list_cnt), step_list->step[
       step_list_cnt].step_idx = step_idx,
       step_idx = locateval(step_idx,(step_idx+ 1),step_cnt,0.0,step->event_id,
        doc_type_powerform,step->doc_type_cd,l_doc_id_str,step->doc_id_str),
       CALL cv_log_message(build("PF find:",step_idx))
     ENDWHILE
    WITH nocounter
   ;end select
   IF (step_list_cnt=0)
    CALL cv_log_message("Failed to find open step matching POWERFORM")
    GO TO exit_script
   ENDIF
  OF doc_type_powernote:
   SELECT DISTINCT INTO "nl:"
    sp.scr_pattern_id, pattern_str = concat(trim(sp.cki_source),"!",trim(sp.cki_identifier))
    FROM scd_story_pattern ssp,
     scr_pattern sp
    PLAN (ssp
     WHERE (ssp.scd_story_id=request->doc_id)
      AND ssp.pattern_type_cd=pattern_type_ep)
     JOIN (sp
     WHERE sp.scr_pattern_id=ssp.scr_pattern_id
      AND expand(step_idx,1,step_cnt,0.0,step->event_id,
      doc_type_powernote,step->doc_type_cd,concat(trim(sp.cki_source),"!",trim(sp.cki_identifier)),
      step->doc_id_str))
    DETAIL
     step_idx = locateval(step_idx,1,step_cnt,0.0,step->event_id,
      doc_type_powernote,step->doc_type_cd,pattern_str,step->doc_id_str),
     CALL cv_log_message(build("PN find:",step_idx))
     WHILE (step_idx > 0)
       step_list_cnt += 1, stat = alterlist(step_list->step,step_list_cnt), step_list->step[
       step_list_cnt].step_idx = step_idx,
       step_idx = locateval(step_idx,(step_idx+ 1),step_cnt,0.0,step->event_id,
        doc_type_powernote,step->doc_type_cd,pattern_str,step->doc_id_str),
       CALL cv_log_message(build("PN find:",step_idx))
     ENDWHILE
    WITH nocounter
   ;end select
  ELSE
   CALL cv_log_message(build("Unknown doc_type_cd:",request->doc_type_cd))
   GO TO exit_script
 ENDCASE
 IF (step_list_cnt=0)
  CALL cv_log_message("No matching steps found for this document")
  GO TO exit_script
 ENDIF
 CALL echorecord(step_list)
 CASE (request->result_status_cd)
  OF reqdata->auth_auth_cd:
  OF reqdata->auth_modified_cd:
   SET g_step_status_cd = step_status_completed
  OF reqdata->auth_inerror_cd:
   SET g_step_status_cd = step_status_notstarted
  OF reqdata->auth_unauth_cd:
   SET g_step_status_cd = step_status_unsigned
  OF reqdata->auth_inprogress_cd:
   SET g_step_status_cd = step_status_saved
  ELSE
   CALL cv_log_message(build("Unexpected result_status_cd:",request->result_status_cd))
   GO TO exit_script
 ENDCASE
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = step_list_cnt)
  DETAIL
   step_idx = step_list->step[d.seq].step_idx
   CASE (g_step_status_cd)
    OF step_status_notstarted:
     step->event_id = 0.0,step->perf_provider_id = 0.0,step->perf_loc_cd = 0.0,
     step->perf_start_dt_tm = cnvtdatetime(0,0),step->perf_stop_dt_tm = cnvtdatetime(0,0)
    OF step_status_saved:
    OF step_status_unsigned:
     step->event_id = request->event_id,step->perf_provider_id = request->perf_provider_id
    OF step_status_completed:
     step->event_id = request->event_id,step->perf_provider_id = request->perf_provider_id,step->
     perf_stop_dt_tm = time_now
   ENDCASE
   step->step_status_cd = g_step_status_cd, step->modified_ind = 1
  WITH nocounter
 ;end select
 SET modify = nopredeclare
 CALL echorecord(proc_list)
 EXECUTE cv_save_procs  WITH replace("REQUEST",proc_list)
 IF ((reply->status_data.status != "S"))
  CALL cv_log_message("CV_SAVE_PROCS failed")
  CALL echorecord(proc_list)
  CALL echorecord(reply)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_message("CV_PROCESS_DOC_ACTION failed!")
  CALL echorecord(reply)
  CALL echorecord(request)
  SET reqinfo->commit_ind = 0
 ELSE
  CALL cv_log_message("CV_PROCESS_DOC_ACTION successful.")
  SET reqinfo->commit_ind = 1
 ENDIF
 SET modify = nopredeclare
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(sysdate),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE (cv_log_destroyhandle(dummy=i2) =null)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt -= 1
   ENDIF
 END ;Subroutine
 SET cv_process_doc_action_vrsn = "MOD 007 09/05/18 VJ043510"
END GO
