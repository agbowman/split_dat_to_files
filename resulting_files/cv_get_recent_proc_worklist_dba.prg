CREATE PROGRAM cv_get_recent_proc_worklist:dba
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
 DECLARE organization_idx = i4 WITH noconstant(0)
 DECLARE physician_group_idx = i4 WITH noconstant(0)
 DECLARE proc_idx = i4 WITH noconstant(0), protect
 DECLARE foundindex = i4 WITH noconstant(0), protect
 DECLARE proc_cnt = i4 WITH protect, noconstant(0)
 DECLARE total_proc_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_idx = i4 WITH private, noconstant(0)
 FREE RECORD recent_procs
 RECORD recent_procs(
   1 procs[*]
     2 proc_id = f8
 )
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
 FREE RECORD reply
 IF (validate(reply) != 1)
  RECORD reply(
    1 cv_proc[*]
      2 accession = vc
      2 accession_id = f8
      2 action_dt_tm = dq8
      2 birth_dt_tm = dq8
      2 catalog_cd = f8
      2 catalog_disp = vc
      2 catalog_mean = c12
      2 cv_proc_id = f8
      2 encntr_id = f8
      2 encntr_mrn = vc
      2 encounter_type_cd = f8
      2 encounter_type_disp = vc
      2 encounter_type_mean = c12
      2 group_event_id = f8
      2 location_cd = f8
      2 location_disp = vc
      2 order_id = f8
      2 order_physician_id = f8
      2 person_id = f8
      2 person_name_first = vc
      2 person_name_last = vc
      2 person_name_middle = vc
      2 phys_group_id = f8
      2 prim_physician_id = f8
      2 priority_cd = f8
      2 priority_disp = vc
      2 priority_mean = c12
      2 proc_status_cd = f8
      2 proc_status_disp = vc
      2 proc_status_mean = c12
      2 reason_for_proc = vc
      2 refer_physician_id = f8
      2 sequence = i4
      2 sex_cd = f8
      2 sex_disp = vc
      2 sex_mean = c12
      2 request_dt_tm = dq8
      2 created_study_uid = c64
      2 study_uid = c64
      2 study_state_cd = f8
      2 study_state_disp = vc
      2 study_state_mean = c12
      2 loc_nurse_unit_cd = f8
      2 loc_nurse_unit_disp = vc
      2 loc_room_cd = f8
      2 loc_room_disp = vc
      2 loc_bed_cd = f8
      2 loc_bed_disp = vc
      2 updt_cnt = i4
      2 cv_step[*]
        3 cv_step_id = f8
        3 event_id = f8
        3 sequence = i4
        3 step_status_cd = f8
        3 step_status_disp = vc
        3 step_status_mean = c12
        3 task_assay_cd = f8
        3 task_assay_disp = vc
        3 task_assay_mean = c12
        3 updt_cnt = i4
        3 activity_subtype_cd = f8
        3 activity_subtype_disp = vc
        3 activity_subtype_mean = c12
        3 doc_id_str = vc
        3 doc_type_cd = f8
        3 doc_type_disp = vc
        3 doc_type_mean = c12
        3 proc_status_cd = f8
        3 proc_status_disp = vc
        3 proc_status_mean = c12
        3 schedule_ind = i2
        3 step_level_flag = i2
        3 perf_loc_cd = f8
        3 perf_loc_disp = vc
        3 perf_provider_id = f8
        3 perf_start_dt_tm = dq8
        3 perf_stop_dt_tm = dq8
        3 lock_prsnl_id = f8
        3 cv_step_sched[*]
          4 arrive_dt_tm = dq8
          4 arrive_ind = i2
          4 cv_step_sched_id = f8
          4 sched_loc_cd = f8
          4 sched_loc_disp = vc
          4 sched_phys_id = f8
          4 sched_start_dt_tm = dq8
          4 sched_stop_dt_tm = dq8
          4 updt_cnt = i4
          4 modified_ind = i2
        3 step_type_cd = f8
        3 step_type_disp = vc
        3 step_type_mean = c12
        3 modified_ind = i2
        3 lock_updt_dt_tm = dq8
        3 step_resident_id = f8
        3 doc_template_id = f8
        3 modality_cd = f8
        3 vendor_cd = f8
        3 study_identifier = vc
        3 study_dt_tm = dq8
        3 pdf_doc_identifier = vc
        3 normalcy_cd = f8
      2 activity_subtype_cd = f8
      2 activity_subtype_disp = vc
      2 activity_subtype_mean = c12
      2 device_name = c25
      2 ip_address = vc
      2 refer_phys[*]
        3 refer_phys_id = f8
        3 ft_prsnl_name = vc
      2 order_detail[*]
        3 oe_field_display_value = vc
        3 oe_field_dt_tm_value = dq8
        3 oe_field_id = f8
        3 oe_field_meaning_id = f8
        3 oe_field_tz = i4
        3 oe_field_value = f8
      2 organization_id = f8
      2 modified_ind = i2
      2 loc_building_cd = f8
      2 loc_building_disp = vc
      2 order_comment_ind = i4
      2 ed_review_ind = i2
      2 ed_review_status_cd = f8
      2 ed_requestor_prsnl_id = f8
      2 ed_request_dt_tm = dq8
      2 financial_class_cd = f8
      2 admit_phys[*]
        3 admit_phys_id = f8
        3 ft_phys_prsnl_name = vc
      2 encntr_finnbr = vc
      2 orig_order_dt_tm = dq8
      2 proc_normalcy_cd = f8
      2 encntr_mrn_raw = vc
      2 station_name = vc
      2 proc_indicator = vc
      2 im_device_id = f8
      2 stress_ecg_status_cd = f8
      2 stress_ecg_status_disp = vc
      2 dod_id = vc
      2 cmrn = vc
      2 birth_tz = i4
      2 loc_facility_cd = f8
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
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_msg(cv_error,"Reply doesn't contain status block")
  GO TO exit_script
 ENDIF
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 DECLARE getrecentprocs(dummy) = null WITH protect
 DECLARE get_reply(dummy) = null WITH protect
 DECLARE getrecentprocswithmineandmygroups(dummy) = null WITH protect
 DECLARE getrecentprocswithmine(dummy) = null WITH protect
 DECLARE getrecentprocswithgroups(dummy) = null WITH protect
 SUBROUTINE get_reply(dummy)
  SET total_proc_cnt = size(recent_procs->procs,5)
  IF (total_proc_cnt != 0)
   SET stat = alterlist(fetch_req->cv_proc,total_proc_cnt)
   FOR (temp_idx = 1 TO total_proc_cnt)
     SET fetch_req->cv_proc[temp_idx].cv_proc_id = recent_procs->procs[temp_idx].proc_id
   ENDFOR
   CALL echorecord(fetch_req)
  ELSE
   SET reply->status_data.status = "Z"
   CALL cv_log_msg(cv_debug,"Zero records were retrieved")
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE getrecentprocswithmine(dummy)
   SELECT INTO "nl:"
    FROM cv_step c,
     cv_proc cp,
     encounter e
    PLAN (c
     WHERE  NOT (c.step_status_cd IN (step_stat_notstarted, step_stat_discontinued,
     step_stat_cancelled))
      AND (c.updt_id=request->user_id))
     JOIN (cp
     WHERE cp.cv_proc_id=c.cv_proc_id
      AND (cp.prim_physician_id=request->user_id)
      AND  NOT (cp.proc_status_cd IN (proc_stat_ordered, proc_stat_scheduled, proc_stat_arrived,
     proc_stat_discontinued, proc_stat_cancelled)))
     JOIN (e
     WHERE cp.encntr_id=e.encntr_id
      AND expand(organization_idx,1,size(request->organization,5),e.organization_id,request->
      organization[organization_idx].organization_id))
    ORDER BY c.updt_dt_tm DESC
    HEAD REPORT
     stat = alterlist(recent_procs->procs,10)
    DETAIL
     foundindex = locateval(proc_idx,1,size(recent_procs->procs,5),c.cv_proc_id,recent_procs->procs[
      proc_idx].proc_id)
     IF (foundindex=0
      AND proc_cnt < 10)
      proc_cnt += 1, recent_procs->procs[proc_cnt].proc_id = c.cv_proc_id
     ENDIF
    FOOT REPORT
     stat = alterlist(recent_procs->procs,proc_cnt)
    WITH maxrec = 50, nocounter, separator = " ",
     format
   ;end select
 END ;Subroutine
 SUBROUTINE getrecentprocs(dummy)
   SELECT INTO "nl:"
    FROM cv_step c,
     cv_proc cp,
     encounter e
    PLAN (c
     WHERE  NOT (c.step_status_cd IN (step_stat_notstarted, step_stat_discontinued,
     step_stat_cancelled))
      AND (c.updt_id=request->user_id))
     JOIN (cp
     WHERE cp.cv_proc_id=c.cv_proc_id
      AND  NOT (cp.proc_status_cd IN (proc_stat_ordered, proc_stat_scheduled, proc_stat_arrived,
     proc_stat_discontinued, proc_stat_cancelled)))
     JOIN (e
     WHERE cp.encntr_id=e.encntr_id
      AND expand(organization_idx,1,size(request->organization,5),e.organization_id,request->
      organization[organization_idx].organization_id))
    ORDER BY c.updt_dt_tm DESC
    HEAD REPORT
     stat = alterlist(recent_procs->procs,10)
    DETAIL
     foundindex = locateval(proc_idx,1,size(recent_procs->procs,5),c.cv_proc_id,recent_procs->procs[
      proc_idx].proc_id)
     IF (foundindex=0
      AND proc_cnt < 10)
      proc_cnt += 1, recent_procs->procs[proc_cnt].proc_id = c.cv_proc_id
     ENDIF
    FOOT REPORT
     stat = alterlist(recent_procs->procs,proc_cnt)
    WITH maxrec = 50, nocounter, separator = " ",
     format
   ;end select
 END ;Subroutine
 SUBROUTINE getrecentprocswithmineandmygroups(dummy)
   SELECT INTO "nl:"
    FROM cv_step c,
     cv_proc cp,
     encounter e
    PLAN (c
     WHERE  NOT (c.step_status_cd IN (step_stat_notstarted, step_stat_discontinued,
     step_stat_cancelled))
      AND (c.updt_id=request->user_id))
     JOIN (cp
     WHERE cp.cv_proc_id=c.cv_proc_id
      AND  NOT (cp.proc_status_cd IN (proc_stat_ordered, proc_stat_scheduled, proc_stat_arrived,
     proc_stat_discontinued, proc_stat_cancelled))
      AND ((cp.phys_group_id <= 0.0
      AND (request->user_id=cp.prim_physician_id)) OR (cp.phys_group_id > 0.0
      AND expand(physician_group_idx,1,size(request->physician_group,5),cp.phys_group_id,request->
      physician_group[physician_group_idx].physician_group_id))) )
     JOIN (e
     WHERE cp.encntr_id=e.encntr_id
      AND expand(organization_idx,1,size(request->organization,5),e.organization_id,request->
      organization[organization_idx].organization_id))
    ORDER BY c.updt_dt_tm DESC
    HEAD REPORT
     stat = alterlist(recent_procs->procs,10)
    DETAIL
     foundindex = locateval(proc_idx,1,size(recent_procs->procs,5),c.cv_proc_id,recent_procs->procs[
      proc_idx].proc_id)
     IF (foundindex=0
      AND proc_cnt < 10)
      proc_cnt += 1, recent_procs->procs[proc_cnt].proc_id = c.cv_proc_id
     ENDIF
    FOOT REPORT
     stat = alterlist(recent_procs->procs,proc_cnt)
    WITH maxrec = 50, nocounter, separator = " ",
     format
   ;end select
 END ;Subroutine
 SUBROUTINE getrecentprocswithgroups(dummy)
   SELECT INTO "nl:"
    FROM cv_step c,
     cv_proc cp,
     encounter e
    PLAN (c
     WHERE  NOT (c.step_status_cd IN (step_stat_notstarted, step_stat_discontinued,
     step_stat_cancelled))
      AND (c.updt_id=request->user_id))
     JOIN (cp
     WHERE cp.cv_proc_id=c.cv_proc_id
      AND  NOT (cp.proc_status_cd IN (proc_stat_ordered, proc_stat_scheduled, proc_stat_arrived,
     proc_stat_discontinued, proc_stat_cancelled))
      AND (request->physician_group[0].physician_group_id=cp.phys_group_id))
     JOIN (e
     WHERE cp.encntr_id=e.encntr_id
      AND expand(organization_idx,1,size(request->organization,5),e.organization_id,request->
      organization[organization_idx].organization_id))
    ORDER BY c.updt_dt_tm DESC
    HEAD REPORT
     stat = alterlist(recent_procs->procs,10)
    DETAIL
     foundindex = locateval(proc_idx,1,size(recent_procs->procs,5),c.cv_proc_id,recent_procs->procs[
      proc_idx].proc_id)
     IF (foundindex=0
      AND proc_cnt < 10)
      proc_cnt += 1, recent_procs->procs[proc_cnt].proc_id = c.cv_proc_id
     ENDIF
    FOOT REPORT
     stat = alterlist(recent_procs->procs,proc_cnt)
    WITH maxrec = 50, nocounter, separator = " ",
     format
   ;end select
 END ;Subroutine
 DECLARE physician_group_cnt = i4 WITH private
 SET physician_group_cnt = size(request->physician_group,5)
 IF ((request->my_group_id=1))
  CALL getrecentprocswithmine(0)
 ELSEIF ((request->my_group_id=2))
  CALL getrecentprocswithmineandmygroups(0)
 ELSEIF ((request->my_group_id=3))
  CALL getrecentprocswithgroups(0)
 ELSE
  CALL getrecentprocs(0)
 ENDIF
 CALL get_reply(0)
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_req), replace("REPLY",reply)
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_FETCH_PROCS failed")
  GO TO exit_script
 ENDIF
 EXECUTE cv_fetch_demog  WITH replace("REQUEST","REPLY")
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_FETCH_DEMOG failed")
 ENDIF
 FREE RECORD uid_rep
 RECORD uid_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE cv_get_study_uid  WITH replace("REPLY","UID_REP"), replace("REQUEST","REPLY")
 IF ((uid_rep->status_data.status != "S"))
  CALL cv_log_msg(cv_error,build("cv_get_study_uid exited with status=",uid_rep->status_data.status))
 ENDIF
 SET reply->status_data.status = "F"
 IF ((uid_rep->status_data.status != "S"))
  CALL cv_log_msg(cv_error,build("cv_get_study_uid exited with status=",uid_rep->status_data.status))
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request->get_order_detail_ind,0)=1)
  EXECUTE cv_get_order_detail  WITH replace("PROC_LIST","REPLY")
  IF ( NOT ((reply->status_data.status IN ("S", "Z"))))
   CALL cv_log_stat(cv_warning,"EXECUTE",reply->status_data.status,"CV_GET_ORDER_DETAIL","")
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 FREE RECORD comments_ind_request
 RECORD comments_ind_request(
   1 orders[*]
     2 order_id = f8
     2 order_comment_ind = i4
 )
 FREE RECORD comments_ind_reply
 RECORD comments_ind_reply(
   1 orders[*]
     2 order_id = f8
     2 order_comment_ind = i4
 )
 DECLARE proc_count = i4 WITH protect, noconstant(0)
 DECLARE reply_count = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 SET proc_count = size(reply->cv_proc,5)
 SET stat = alterlist(comments_ind_request->orders,proc_count)
 FOR (idx = 1 TO proc_count)
   SET comments_ind_request->orders[idx].order_id = reply->cv_proc[idx].order_id
   SET comments_ind_request->orders[idx].order_comment_ind = 0
   SET reply->cv_proc[idx].order_comment_ind = 0
 ENDFOR
 EXECUTE cv_get_order_comment_ind  WITH replace("REQUEST",comments_ind_request), replace("REPLY",
  comments_ind_reply)
 SET reply_count = size(comments_ind_reply->orders,5)
 FOR (y = 1 TO reply_count)
   SET pos = 0
   SET pos = locateval(idx,1,proc_count,comments_ind_reply->orders[y].order_id,reply->cv_proc[idx].
    order_id)
   IF (pos > 0)
    SET reply->cv_proc[pos].order_comment_ind = comments_ind_reply->orders[y].order_comment_ind
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD uid_rep
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_audit,"No records found for Recent Procedure Worklist.")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="F"))
  CALL cv_log_msg(cv_error,"Recent Procedure Worklist retrieval failed.")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="S"))
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 1
 ELSE
  CALL cv_log_msg(cv_warning,"Unrecognized reply status")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL cv_log_msg_post("006 02/06/19 MA056659")
END GO
