CREATE PROGRAM cv_add_ref_letter:dba
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
 IF (validate(reply->status_data.status)=0)
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
 DECLARE c_step_type_finalreport = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "FINALREPORT"))
 DECLARE c_doc_type_powernote = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,
   "POWERNOTE"))
 DECLARE proc_cnt = i4 WITH protect
 DECLARE proc_idx = i4 WITH protect
 DECLARE step_cnt = i4 WITH protect
 DECLARE step_idx = i4 WITH protect
 DECLARE ref_step_idx = i4 WITH protect
 DECLARE load_proc_list_ind = i2 WITH protect
 DECLARE g_withlock_flag = i2 WITH protect, noconstant(validate(request->withlock_flag,1))
 DECLARE g_template_id = f8 WITH protect, noconstant(validate(request->letter[1].template_id,0.0))
 DECLARE g_ref_phys_id = f8 WITH protect, noconstant(validate(request->letter[1].ref_phys_id,0.0))
 DECLARE g_task_assay_cd = f8 WITH protect, noconstant(validate(request->task_assay_cd,0.0))
 DECLARE g_use_on_off_ind = i2 WITH protect, noconstant(validate(request->use_on_off_ind,0))
 DECLARE req_proc_id = f8 WITH protect, noconstant(validate(request->cv_proc_id,0.0))
 IF (validate(proc_list->cv_proc[proc_idx].cv_proc_id,0.0)=0.0)
  SET load_proc_list_ind = 1
  IF (req_proc_id=0.0)
   CALL cv_log_stat(cv_warning,"REQUEST","F","CV_PROC_ID=0.0","")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (load_proc_list_ind=1)
  FREE SET fetch_procs_req
  RECORD fetch_procs_req(
    1 cv_proc[*]
      2 cv_proc_id = f8
    1 withlock_flag = i2
    1 fetch_inactive_steps = i2
  )
  FREE SET proc_list
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
  IF (g_withlock_flag=0)
   CALL cv_log_msg(cv_debug,"Defaulting g_withlock_flag to 1")
   SET g_withlock_flag = 1
  ELSEIF ( NOT (g_withlock_flag IN (1, 2)))
   CALL cv_log_stat(cv_warning,"REQUEST","F","WITHLOCK_FLAG",build(g_withlock_flag))
   GO TO exit_script
  ENDIF
  SET fetch_procs_req->withlock_flag = g_withlock_flag
  SET stat = alterlist(fetch_procs_req->cv_proc,1)
  SET fetch_procs_req->cv_proc[1].cv_proc_id = req_proc_id
  SET fetch_procs_req->fetch_inactive_steps = 0
  EXECUTE cv_fetch_procs  WITH replace("REPLY",proc_list), replace("REQUEST",fetch_procs_req)
  IF ((proc_list->status_data.status != "S"))
   CALL cv_log_stat(cv_audit,"EXECUTE",proc_list->status_data.status,"CV_FETCH_PROCS","")
   GO TO exit_script
  ENDIF
  SET proc_idx = 1
 ELSE
  SET proc_cnt = size(proc_list->cv_proc)
  SET proc_idx = validate(request->proc_idx,0)
  IF (((proc_idx < 1) OR (proc_idx > proc_cnt)) )
   CALL cv_log_stat(cv_warning,"REQUEST","F","PROC_IDX",build("PROC_LIST->CV_PROC[",proc_idx,
     "] is out of range"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (((g_ref_phys_id=0.0) OR (((g_task_assay_cd=0.0) OR (((g_template_id=0.0) OR (g_use_on_off_ind=1
 )) )) )) )
  DECLARE status_char = c1 WITH protect
  SET status_char = getrefletterinfo(g_use_on_off_ind,evaluate(g_ref_phys_id,0.0,1,0),proc_list->
   cv_proc[proc_idx].encntr_id,proc_list->cv_proc[proc_idx].prim_physician_id,proc_list->cv_proc[
   proc_idx].catalog_cd,
   g_task_assay_cd,g_template_id)
  IF (status_char="Z")
   SET reply->status_data.status = "S"
   GO TO exit_script
  ELSEIF (status_char != "S")
   GO TO exit_script
  ENDIF
 ENDIF
 CALL cv_log_msg(cv_debug,build("g_task_assay_cd=",g_task_assay_cd,", g_template_id=",g_template_id))
 SET step_cnt = size(proc_list->cv_proc[proc_idx].cv_step,5)
 SET ref_step_idx = locateval(step_idx,1,step_cnt,g_task_assay_cd,proc_list->cv_proc[proc_idx].
  cv_step[step_idx].task_assay_cd)
 IF (ref_step_idx=0)
  FREE SET cv_new_steps_req
  RECORD cv_new_steps_req(
    1 proc_idx = i4
    1 cv_step[*]
      2 task_assay_cd = f8
  )
  SET stat = alterlist(cv_new_steps_req->cv_step,1)
  SET cv_new_steps_req->cv_step[1].task_assay_cd = g_task_assay_cd
  SET cv_new_steps_req->proc_idx = proc_idx
  SET step_idx = step_cnt
  EXECUTE cv_new_steps  WITH replace("REQUEST",cv_new_steps_req), replace("REPLY",reply)
  IF ((reply->status_data.status="Z"))
   CALL cv_log_stat(cv_audit,"EXECUTE","Z","CV_NEW_STEPS","")
   GO TO exit_script
  ELSEIF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_audit,"EXECUTE",reply->status_data.status,"CV_NEW_STEPS","")
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "F"
  SET step_cnt = size(proc_list->cv_proc[proc_idx].cv_step,5)
  IF ((step_cnt != (step_idx+ 1)))
   CALL cv_log_stat(cv_audit,"REPLY","F","CV_NEW_STEPS",build("STEP_CNT=",step_cnt))
   GO TO exit_script
  ENDIF
  SET ref_step_idx = step_cnt
 ELSE
  CALL cv_log_msg(cv_debug,build("Found referral letter step at ref_step_idx=",ref_step_idx))
  IF ( NOT (uar_get_code_meaning(proc_list->cv_proc[proc_idx].cv_step[ref_step_idx].step_status_cd)
   IN ("CANCELLED", "NOTSTARTED", "DISCONTINUED")))
   CALL cv_log_stat(cv_audit,"VERFIY","F","PROC_LIST",build(
     "Active REFLETTER exists with cv_step_id=",proc_list->cv_proc[proc_idx].cv_step[ref_step_idx].
     cv_step_id))
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
  IF ((proc_list->cv_proc[proc_idx].cv_step[ref_step_idx].lock_prsnl_id != 0.0))
   CALL cv_log_stat(cv_warning,"LOCK","F","CV_PROC.LOCK_PRSNL_ID",build(proc_list->cv_proc[proc_idx].
     cv_step[ref_step_idx].lock_prsnl_id))
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echorecord(proc_list)
 DECLARE g_note_type_id = f8 WITH protect, noconstant(cnvtreal(proc_list->cv_proc[proc_idx].cv_step[
   ref_step_idx].doc_id_str))
 IF (g_note_type_id <= 0.0)
  CALL cv_log_stat(cv_warning,"CNVTREAL","F","DOC_ID_STR",proc_list->cv_proc[proc_idx].cv_step[
   ref_step_idx].doc_id_str)
  GO TO exit_script
 ENDIF
 FREE SET add_note_req
 RECORD add_note_req(
   1 template_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 prsnl_id = f8
   1 data[*]
     2 name = vc
     2 value = vc
   1 event_cd = f8
   1 parent_event_id = f8
   1 scd_story_id = f8
   1 publish_flag = i2
 )
 FREE SET add_note_reply
 RECORD add_note_reply(
   1 event_id = f8
   1 note_status_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (g_template_id != null_f8)
  SET add_note_req->template_id = g_template_id
 ENDIF
 SET add_note_req->person_id = proc_list->cv_proc[proc_idx].person_id
 SET add_note_req->encntr_id = proc_list->cv_proc[proc_idx].encntr_id
 SET add_note_req->prsnl_id = proc_list->cv_proc[proc_idx].prim_physician_id
 SET add_note_req->parent_event_id = proc_list->cv_proc[proc_idx].group_event_id
 SELECT INTO "nl:"
  FROM note_type nt
  WHERE nt.note_type_id=g_note_type_id
  DETAIL
   add_note_req->event_cd = nt.event_cd
   IF (nt.publish_level=1)
    add_note_req->publish_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 IF ((add_note_req->event_cd <= 0.0))
  CALL cv_log_stat(cv_warning,"SELECT","F","NOTE_TYPE",build("note_type_id=",g_note_type_id))
  GO TO exit_script
 ENDIF
 CALL adddatalist(proc_idx)
 SET step_idx = locateval(step_idx,1,step_cnt,c_step_type_finalreport,proc_list->cv_proc[proc_idx].
  cv_step[step_idx].step_type_cd,
  c_doc_type_powernote,proc_list->cv_proc[proc_idx].cv_step[step_idx].doc_type_cd)
 IF (step_idx > 0)
  IF ((proc_list->cv_proc[proc_idx].cv_step[step_idx].event_id > 0.0))
   SELECT INTO "nl:"
    FROM scd_story ss
    WHERE (ss.event_id=proc_list->cv_proc[proc_idx].cv_step[step_idx].event_id)
    DETAIL
     add_note_req->scd_story_id = ss.scd_story_id
    WITH nocounter, maxqual(ss,1)
   ;end select
   IF ((add_note_req->scd_story_id=0.0))
    CALL cv_log_stat(cv_warning,"SELECT","Z","SCD_STORY",build("EVENT_ID=",proc_list->cv_proc[
      proc_idx].cv_step[step_idx].event_id))
   ENDIF
  ELSE
   CALL cv_log_stat(cv_warning,"CHECK","Z","PROC_LIST","FINALREPORT step has event_id=0.0")
  ENDIF
 ELSE
  CALL cv_log_msg(cv_info,"No FINALREPORT POWERNOTE step found")
 ENDIF
 EXECUTE auto_corsp_add_note  WITH replace("REQUEST",add_note_req), replace("REPLY",add_note_reply)
 IF ((add_note_reply->status_data.status != "S"))
  CALL cv_log_stat(cv_warning,"EXECUTE",add_note_reply->status_data.status,"AUTO_CORSP_ADD_NOTE","")
  GO TO exit_script
 ENDIF
 IF ((add_note_reply->event_id <= 0.0))
  CALL cv_log_stat(cv_warning,"AUTO_CORSP_ADD_NOTE",add_note_reply->status_data.status,
   "REPLY->EVENT_ID",cnvtstring(add_note_reply->event_id))
  GO TO exit_script
 ENDIF
 SET proc_list->cv_proc[proc_idx].cv_step[ref_step_idx].modified_ind = 1
 SET proc_list->cv_proc[proc_idx].cv_step[ref_step_idx].perf_start_dt_tm = cnvtdatetime(curdate,
  curtime)
 SET proc_list->cv_proc[proc_idx].cv_step[ref_step_idx].event_id = add_note_reply->event_id
 SET proc_list->cv_proc[proc_idx].cv_step[ref_step_idx].perf_provider_id = proc_list->cv_proc[
 proc_idx].prim_physician_id
 IF ((add_note_reply->note_status_flag=1))
  SET proc_list->cv_proc[proc_idx].cv_step[ref_step_idx].step_status_cd = uar_get_code_by("MEANING",
   4000440,"UNSIGNED")
 ELSE
  SET proc_list->cv_proc[proc_idx].cv_step[ref_step_idx].step_status_cd = uar_get_code_by("MEANING",
   4000440,"SAVED")
 ENDIF
 IF (load_proc_list_ind=1)
  EXECUTE cv_upd_proc  WITH replace("REQUEST",proc_list), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_warning,"EXECUTE",reply->status_data.status,"CV_UPD_PROC","")
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE (getrefletterinfo(p_use_on_off_ind=i2,p_chk_ref_phys_ind=i2,p_encntr_id=f8,
  p_prim_physician_id=f8,p_catalog_cd=f8,r_task_assay_cd=f8(ref),r_template_id=f8(ref)) =c1 WITH
  protect)
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
   SET cgrli_req->encntr_id = p_encntr_id
   SET cgrli_req->prim_physician_id = p_prim_physician_id
   IF (r_task_assay_cd > 0.0)
    SET cgrli_req->task_assay_cd = r_task_assay_cd
   ELSE
    SET cgrli_req->catalog_cd = p_catalog_cd
   ENDIF
   EXECUTE cv_get_ref_letter_info  WITH replace("REQUEST",cgrli_req), replace("REPLY",cgrli_reply)
   IF ((cgrli_reply->status_data.status != "S"))
    CALL cv_log_stat(cv_warning,"EXECUTE",cgrli_reply->status_data.status,"CV_GET_REF_LETTER_INFO",""
     )
    RETURN(cgrli_reply->status_data.status)
   ENDIF
   IF (p_use_on_off_ind=1
    AND (cgrli_reply->on_off_ind=0))
    CALL cv_log_stat(cv_info,"REPLY","Z","CV_REF_LETTER_INFO","ON_OFF_IND=0")
    RETURN("Z")
   ENDIF
   IF (p_chk_ref_phys_ind=1
    AND size(cgrli_reply->ref_phys,5)=0)
    CALL cv_log_stat(cv_info,"REPLY","Z","CV_REF_LETTER_INFO","REF_PHYS is empty")
    RETURN("Z")
   ENDIF
   IF (r_task_assay_cd=0.0)
    IF ((cgrli_reply->task_assay_cd=0.0))
     CALL cv_log_stat(cv_info,"REPLY","Z","CV_REF_LETTER_INFO","TASK_ASSAY_CD=0.0")
     RETURN("Z")
    ELSE
     SET r_task_assay_cd = cgrli_reply->task_assay_cd
    ENDIF
   ENDIF
   IF (r_template_id=0.0)
    SET r_template_id = cgrli_reply->template_id
   ENDIF
   FREE SET cgrli_req
   FREE SET cgrli_reply
   CALL cv_log_msg(cv_info,build("Leaving GetRefLetterInfo with r_task_assay_cd=",r_task_assay_cd,
     ", r_template_id",r_template_id))
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (adddatalist(p_proc_idx=i4) =null)
   DECLARE step_cnt = i4 WITH protect, noconstant(size(proc_list->cv_proc[p_proc_idx].cv_step))
   DECLARE step_idx = i4 WITH protect
   DECLARE data_cnt = i4 WITH protect
   SET stat = alterlist(add_note_req->data,5)
   CALL adddataitem("PROCNAME",uar_get_code_display(proc_list->cv_proc[p_proc_idx].catalog_cd))
   CALL adddataitem("PROCDATE",nullterm(trim(format(proc_list->cv_proc[p_proc_idx].action_dt_tm,
       "@LONGDATE"),3)))
   CALL adddataitem("REASON",proc_list->cv_proc[p_proc_idx].reason_for_proc)
   SET step_idx = locateval(step_idx,1,step_cnt,1,proc_list->cv_proc[p_proc_idx].cv_step[step_idx].
    schedule_ind)
   IF (step_idx > 0)
    IF ((proc_list->cv_proc[p_proc_idx].cv_step[step_idx].cv_step_sched[1].sched_start_dt_tm != 0.0))
     CALL adddataitem("SCHEDSTART",nullterm(trim(format(proc_list->cv_proc[p_proc_idx].cv_step[
         step_idx].cv_step_sched[1].sched_start_dt_tm,"@LONGDATE"),3)))
    ELSE
     CALL cv_log_msg(cv_info,"sched_start_dt_tm is empty")
    ENDIF
   ELSE
    CALL cv_log_msg(cv_info,"No schedulable step found")
   ENDIF
   SET stat = alterlist(add_note_req->data,data_cnt)
 END ;Subroutine
 SUBROUTINE (adddataitem(p_name=vc,p_value=vc) =i4)
   SET data_cnt += 1
   SET add_note_req->data[data_cnt].name = p_name
   SET add_note_req->data[data_cnt].value = p_value
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
  CALL echorecord(proc_list)
 ENDIF
 CALL cv_log_msg_post("008 27/11/18 rr035230")
END GO
