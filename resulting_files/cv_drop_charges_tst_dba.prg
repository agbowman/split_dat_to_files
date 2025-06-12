CREATE PROGRAM cv_drop_charges_tst:dba
 SET trace = rdbdebug
 SET trace = rdbbind
 CALL trace(7)
 SET reqdata->loglevel = 4
 SET modify = predeclare
 FREE RECORD fetch_proc
 RECORD fetch_proc(
   1 cv_proc[*]
     2 cv_proc_id = f8
   1 cv_step[*]
     2 cv_step_id = f8
 )
 FREE RECORD request
 RECORD request(
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
     2 activity_subtype_cd = f8
     2 ed_review_ind = i2
     2 ed_review_status_cd = f8
     2 ed_requestor_prsnl_id = f8
     2 ed_request_dt_tm = dq8
     2 orig_order_dt_tm = dq8
     2 proc_normalcy_cd = f8
     2 proc_indicator = vc
   1 calling_process_name = vc
   1 order_action_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE step_type_procedure_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "PROCEDURE"))
 DECLARE step_type_final_report_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "FINALREPORT"))
 DECLARE step_status_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "COMPLETED"))
 DECLARE step_status_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "CANCELLED"))
 DECLARE step_status_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "DISCONTINUED"))
 DECLARE step_status_notstarted_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "NOTSTARTED"))
 DECLARE proc_status_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000341,
   "CANCELLED"))
 DECLARE proc_status_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000341,
   "DISCONTINUED"))
 DECLARE cur_step_status = f8 WITH protect
 DECLARE cur_start_dt_tm = dq8 WITH protect
 DECLARE cur_stop_dt_tm = dq8 WITH protect
 DECLARE testvar_01 = c1 WITH protect, noconstant("F")
 DECLARE testvar_02 = c1 WITH protect, noconstant("F")
 DECLARE testvar_03 = c1 WITH protect, noconstant("F")
 DECLARE testvar_04 = c1 WITH protect, noconstant("F")
 DECLARE testvar_05 = c1 WITH protect, noconstant("F")
 DECLARE testvar_06 = c1 WITH protect, noconstant("F")
 DECLARE testvar_07 = c1 WITH protect, noconstant("F")
 DECLARE testvar_08 = c1 WITH protect, noconstant("F")
 DECLARE testvar_09 = c1 WITH protect, noconstant("F")
 DECLARE testvar_10 = c1 WITH protect, noconstant("F")
 DECLARE testvar_11 = c1 WITH protect, noconstant("F")
 DECLARE testvar_12 = c1 WITH protect, noconstant("F")
 DECLARE stat = i4 WITH protect
 SET stat = alterlist(fetch_proc->cv_step,1)
 SELECT INTO "nl:"
  FROM cv_step cs,
   cv_step_ref csr,
   cv_proc cp
  PLAN (csr
   WHERE csr.step_type_cd=step_type_procedure_cd
    AND csr.schedule_ind=1)
   JOIN (cs
   WHERE cs.task_assay_cd=csr.task_assay_cd
    AND cs.step_status_cd=step_status_notstarted_cd
    AND cs.cv_step_id != 0.0)
   JOIN (cp
   WHERE cp.cv_proc_id=cs.cv_proc_id
    AND  NOT (cp.proc_status_cd IN (proc_status_cancelled_cd, proc_status_discontinued_cd))
    AND cp.action_dt_tm > cnvtdatetime((curdate - 365),0))
  DETAIL
   cur_step_status = cs.step_status_cd, cur_start_dt_tm = cs.perf_start_dt_tm, cur_stop_dt_tm = cs
   .perf_stop_dt_tm,
   fetch_proc->cv_step[1].cv_step_id = cs.cv_step_id
  WITH nocounter, maxqual(cs,1)
 ;end select
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
 FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
   IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
    SET request->cv_proc[1].cv_step[step_idx].step_status_cd = step_status_completed_cd
    SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cnvtdatetime(curdate,curtime3)
    SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cnvtdatetime(curdate,curtime3)
    SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
   ENDIF
 ENDFOR
 EXECUTE cv_save_procs
 SET testvar_01 = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 SET stat = initrec(reply)
 SET stat = initrec(request)
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
 FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
   IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
    SET request->cv_proc[1].cv_step[step_idx].step_status_cd = cur_step_status
    SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cur_start_dt_tm
    SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cur_stop_dt_tm
    SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
   ENDIF
 ENDFOR
 EXECUTE cv_save_procs
 SET testvar_02 = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 SET stat = initrec(reply)
 SET stat = initrec(request)
 SET stat = alterlist(fetch_proc->cv_step,1)
 SELECT INTO "nl:"
  FROM cv_step cs,
   cv_step_ref csr,
   cv_proc cp
  PLAN (csr
   WHERE csr.step_type_cd=step_type_final_report_cd
    AND csr.schedule_ind=0)
   JOIN (cs
   WHERE cs.task_assay_cd=csr.task_assay_cd
    AND  NOT (cs.step_status_cd IN (step_status_completed_cd, step_status_cancelled_cd,
   step_status_discontinued_cd))
    AND cs.cv_step_id != 0.0)
   JOIN (cp
   WHERE cp.cv_proc_id=cs.cv_proc_id
    AND  NOT (cp.proc_status_cd IN (proc_status_cancelled_cd, proc_status_discontinued_cd))
    AND cp.action_dt_tm > cnvtdatetime((curdate - 365),0))
  DETAIL
   cur_step_status = cs.step_status_cd, cur_start_dt_tm = cs.perf_start_dt_tm, cur_stop_dt_tm = cs
   .perf_stop_dt_tm,
   fetch_proc->cv_step[1].cv_step_id = cs.cv_step_id
  WITH nocounter, maxqual(cs,1)
 ;end select
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
 FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
   IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
    SET request->cv_proc[1].cv_step[step_idx].step_status_cd = step_status_completed_cd
    SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cnvtdatetime(curdate,curtime3)
    SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cnvtdatetime(curdate,curtime3)
    SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
   ENDIF
 ENDFOR
 EXECUTE cv_save_procs
 SET testvar_03 = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 SET stat = initrec(reply)
 SET stat = initrec(request)
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
 FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
   IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
    SET request->cv_proc[1].cv_step[step_idx].step_status_cd = cur_step_status
    SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cur_start_dt_tm
    SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cur_stop_dt_tm
    SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
   ENDIF
 ENDFOR
 EXECUTE cv_save_procs
 SET testvar_04 = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 SET stat = initrec(reply)
 SET stat = initrec(request)
 SET stat = alterlist(fetch_proc->cv_step,1)
 SELECT INTO "nl:"
  FROM cv_step cs,
   cv_step_ref csr,
   cv_step cs1,
   cv_step_ref csr1,
   cv_proc cp
  PLAN (csr
   WHERE csr.step_type_cd=step_type_procedure_cd
    AND csr.schedule_ind=1)
   JOIN (cs
   WHERE cs.task_assay_cd=csr.task_assay_cd
    AND cs.step_status_cd=step_status_notstarted_cd
    AND cs.cv_step_id != 0.0)
   JOIN (cs1
   WHERE cs1.cv_proc_id=cs.cv_proc_id
    AND cs1.cv_step_id != cs.cv_step_id)
   JOIN (csr1
   WHERE csr1.step_type_cd=step_type_final_report_cd
    AND csr1.schedule_ind=0
    AND csr1.task_assay_cd=cs1.task_assay_cd)
   JOIN (cp
   WHERE cp.cv_proc_id=cs.cv_proc_id
    AND  NOT (cp.proc_status_cd IN (proc_status_cancelled_cd, proc_status_discontinued_cd))
    AND cp.action_dt_tm > cnvtdatetime((curdate - 365),0))
  DETAIL
   cur_step_status = cs.step_status_cd, cur_start_dt_tm = cs.perf_start_dt_tm, cur_stop_dt_tm = cs
   .perf_stop_dt_tm,
   fetch_proc->cv_step[1].cv_step_id = cs.cv_step_id
  WITH nocounter, maxqual(csr1,1)
 ;end select
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
 FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
   IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
    SET request->cv_proc[1].cv_step[step_idx].step_status_cd = step_status_completed_cd
    SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cnvtdatetime(curdate,curtime3)
    SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cnvtdatetime(curdate,curtime3)
    SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
   ENDIF
 ENDFOR
 EXECUTE cv_save_procs
 SET testvar_05 = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 SET stat = initrec(reply)
 SET stat = initrec(request)
 EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
 FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
   IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
    SET request->cv_proc[1].cv_step[step_idx].step_status_cd = cur_step_status
    SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cur_start_dt_tm
    SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cur_stop_dt_tm
    SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
   ENDIF
 ENDFOR
 EXECUTE cv_save_procs
 SET testvar_06 = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 FREE RECORD fetch_proc
 RECORD fetch_proc(
   1 cv_proc[*]
     2 cv_proc_id = f8
   1 cv_step[*]
     2 cv_step_id = f8
 )
 FREE RECORD request
 RECORD request(
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
     2 activity_subtype_cd = f8
     2 ed_review_ind = i2
     2 ed_review_status_cd = f8
     2 ed_requestor_prsnl_id = f8
     2 ed_request_dt_tm = dq8
     2 orig_order_dt_tm = dq8
     2 proc_normalcy_cd = f8
     2 proc_indicator = vc
   1 calling_process_name = vc
   1 order_action_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(fetch_proc->cv_step,1)
 SELECT INTO "nl:"
  FROM cv_step cs,
   cv_step_ref csr,
   cv_proc cp,
   orders o
  PLAN (csr
   WHERE csr.step_type_cd=step_type_procedure_cd
    AND csr.schedule_ind=1)
   JOIN (cs
   WHERE cs.task_assay_cd=csr.task_assay_cd
    AND cs.step_status_cd=step_status_notstarted_cd
    AND cs.cv_step_id != 0.0)
   JOIN (cp
   WHERE cp.cv_proc_id=cs.cv_proc_id
    AND  NOT (cp.proc_status_cd IN (proc_status_cancelled_cd, proc_status_discontinued_cd))
    AND cp.action_dt_tm > cnvtdatetime((curdate - 365),0))
   JOIN (o
   WHERE o.order_id=cp.order_id
    AND o.cs_order_id != 0.0)
  DETAIL
   cur_step_status = cs.step_status_cd, cur_start_dt_tm = cs.perf_start_dt_tm, cur_stop_dt_tm = cs
   .perf_stop_dt_tm,
   fetch_proc->cv_step[1].cv_step_id = cs.cv_step_id
  WITH nocounter, maxqual(cs,1)
 ;end select
 IF (curqual=0)
  CALL echo("No Cardiovascular orders found in an order set")
 ELSE
  EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
  FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
    IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
     SET request->cv_proc[1].cv_step[step_idx].step_status_cd = step_status_completed_cd
     SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cnvtdatetime(curdate,curtime3)
     SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cnvtdatetime(curdate,curtime3)
     SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
    ENDIF
  ENDFOR
  EXECUTE cv_save_procs
  SET testvar_07 = reply->status_data.status
  CALL echorecord(request)
  CALL echorecord(reply)
  SET stat = initrec(reply)
  SET stat = initrec(request)
  EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
  FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
    IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
     SET request->cv_proc[1].cv_step[step_idx].step_status_cd = cur_step_status
     SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cur_start_dt_tm
     SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cur_stop_dt_tm
     SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
    ENDIF
  ENDFOR
  EXECUTE cv_save_procs
  SET testvar_08 = reply->status_data.status
 ENDIF
 CALL echorecord(request)
 CALL echorecord(reply)
 SET stat = initrec(reply)
 SET stat = initrec(request)
 SET stat = alterlist(fetch_proc->cv_step,1)
 SELECT INTO "nl:"
  FROM cv_step cs,
   cv_step_ref csr,
   cv_proc cp,
   orders o
  PLAN (csr
   WHERE csr.step_type_cd=step_type_final_report_cd
    AND csr.schedule_ind=0)
   JOIN (cs
   WHERE cs.task_assay_cd=csr.task_assay_cd
    AND  NOT (cs.step_status_cd IN (step_status_completed_cd, step_status_cancelled_cd,
   step_status_discontinued_cd))
    AND cs.cv_step_id != 0.0)
   JOIN (cp
   WHERE cp.cv_proc_id=cs.cv_proc_id
    AND  NOT (cp.proc_status_cd IN (proc_status_cancelled_cd, proc_status_discontinued_cd))
    AND cp.action_dt_tm > cnvtdatetime((curdate - 365),0))
   JOIN (o
   WHERE o.order_id=cp.order_id
    AND o.cs_order_id != 0.0)
  DETAIL
   cur_step_status = cs.step_status_cd, cur_start_dt_tm = cs.perf_start_dt_tm, cur_stop_dt_tm = cs
   .perf_stop_dt_tm,
   fetch_proc->cv_step[1].cv_step_id = cs.cv_step_id
  WITH nocounter, maxqual(cs,1)
 ;end select
 IF (curqual=0)
  CALL echo("No Cardiovascular orders found in an order set")
 ELSE
  EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
  FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
    IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
     SET request->cv_proc[1].cv_step[step_idx].step_status_cd = step_status_completed_cd
     SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cnvtdatetime(curdate,curtime3)
     SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cnvtdatetime(curdate,curtime3)
     SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
    ENDIF
  ENDFOR
  EXECUTE cv_save_procs
  SET testvar_09 = reply->status_data.status
  CALL echorecord(request)
  CALL echorecord(reply)
  SET stat = initrec(reply)
  SET stat = initrec(request)
  EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
  FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
    IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
     SET request->cv_proc[1].cv_step[step_idx].step_status_cd = cur_step_status
     SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cur_start_dt_tm
     SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cur_stop_dt_tm
     SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
    ENDIF
  ENDFOR
  EXECUTE cv_save_procs
  SET testvar_10 = reply->status_data.status
 ENDIF
 CALL echorecord(request)
 CALL echorecord(reply)
 SET stat = initrec(reply)
 SET stat = initrec(request)
 SET stat = alterlist(fetch_proc->cv_step,1)
 SELECT INTO "nl:"
  FROM cv_step cs,
   cv_step_ref csr,
   cv_step cs1,
   cv_step_ref csr1,
   cv_proc cp,
   orders o
  PLAN (csr
   WHERE csr.step_type_cd=step_type_procedure_cd
    AND csr.schedule_ind=1)
   JOIN (cs
   WHERE cs.task_assay_cd=csr.task_assay_cd
    AND cs.step_status_cd=step_status_notstarted_cd
    AND cs.cv_step_id != 0.0)
   JOIN (cs1
   WHERE cs1.cv_proc_id=cs.cv_proc_id
    AND cs1.cv_step_id != cs.cv_step_id)
   JOIN (csr1
   WHERE csr1.step_type_cd=step_type_final_report_cd
    AND csr1.schedule_ind=0
    AND csr1.task_assay_cd=cs1.task_assay_cd)
   JOIN (cp
   WHERE cp.cv_proc_id=cs.cv_proc_id
    AND  NOT (cp.proc_status_cd IN (proc_status_cancelled_cd, proc_status_discontinued_cd))
    AND cp.action_dt_tm > cnvtdatetime((curdate - 365),0))
   JOIN (o
   WHERE o.order_id=cp.order_id
    AND o.cs_order_id != 0.0)
  DETAIL
   cur_step_status = cs.step_status_cd, cur_start_dt_tm = cs.perf_start_dt_tm, cur_stop_dt_tm = cs
   .perf_stop_dt_tm,
   fetch_proc->cv_step[1].cv_step_id = cs.cv_step_id
  WITH nocounter, maxqual(csr1,1)
 ;end select
 IF (curqual=0)
  CALL echo("No Cardiovascular orders found in an order set")
 ELSE
  EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
  FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
    IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
     SET request->cv_proc[1].cv_step[step_idx].step_status_cd = step_status_completed_cd
     SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cnvtdatetime(curdate,curtime3)
     SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cnvtdatetime(curdate,curtime3)
     SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
    ENDIF
  ENDFOR
  EXECUTE cv_save_procs
  SET testvar_11 = reply->status_data.status
  CALL echorecord(request)
  CALL echorecord(reply)
  SET stat = initrec(reply)
  SET stat = initrec(request)
  EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetch_proc), replace("REPLY",request)
  FOR (step_idx = 1 TO size(request->cv_proc[1].cv_step,5))
    IF ((request->cv_proc[1].cv_step[step_idx].cv_step_id=fetch_proc->cv_step[1].cv_step_id))
     SET request->cv_proc[1].cv_step[step_idx].step_status_cd = cur_step_status
     SET request->cv_proc[1].cv_step[step_idx].perf_start_dt_tm = cur_start_dt_tm
     SET request->cv_proc[1].cv_step[step_idx].perf_stop_dt_tm = cur_stop_dt_tm
     SET request->cv_proc[1].cv_step[step_idx].modified_ind = 1
    ENDIF
  ENDFOR
  EXECUTE cv_save_procs
  SET testvar_12 = reply->status_data.status
 ENDIF
 CALL echorecord(request)
 CALL echorecord(reply)
 SET stat = initrec(reply)
 SET stat = initrec(request)
 CALL echo(concat("TEST 1 - One procedure step going to a completed state. Status = ",testvar_01,
   ". Expected result = S"))
 CALL echo(concat("TEST 2 - One procedure step leaving a completed state. Status = ",testvar_02,
   ". Expected result = S"))
 CALL echo(concat("TEST 3 - One final report step going to a completed state. Status = ",testvar_03,
   ". Expected result = S"))
 CALL echo(concat("TEST 4 - One final report step leaving a completed state. Status = ",testvar_04,
   ". Expected result = S"))
 CALL echo(concat(
   "TEST 5 - One procedure and one final report step. Procedure step going to a completed state. Status = ",
   testvar_05,". Expected result = S"))
 CALL echo(concat(
   "TEST 6 - One procedure and one final report step. Procedure step leaving a completed state. Status = ",
   testvar_06,". Expected result = S"))
 CALL echo(concat(
   "TEST 7 - One procedure step going to a completed state, ordered from an order set. Status = ",
   testvar_07,". Expected result = S"))
 CALL echo(concat(
   "TEST 8 - One procedure step leaving a completed state, ordered from an order set. Status = ",
   testvar_08,". Expected result = S"))
 CALL echo(concat(
   "TEST 9 - One final report step going to a completed state, ordered from an order set. Status = ",
   testvar_09,". Expected result = S"))
 CALL echo(concat(
   "TEST 10 - One final report step leaving a completed state, ordered from an order set. Status = ",
   testvar_10,". Expected result = S"))
 CALL echo(concat("TEST 11 - One procedure and one final report step.",
   " Procedure step going to a completed state, ordered from an order set. Status = ",testvar_11,
   ". Expected result = S"))
 CALL echo(concat("TEST 12 - One procedure and one final report step.",
   " Procedure step leaving a completed state, ordered from an order set. Status = ",testvar_12,
   ". Expected result = S"))
END GO
