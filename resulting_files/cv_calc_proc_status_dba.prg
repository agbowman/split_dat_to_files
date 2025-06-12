CREATE PROGRAM cv_calc_proc_status:dba
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
 SET reply->status_data.status = "F"
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
 DECLARE step_type_procedure_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "PROCEDURE"))
 DECLARE dicom_pdf_report_type_stressecg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
   4002763,"STRESSECG"))
 DECLARE step_type_cd_final_report_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "FINALREPORT"))
 IF (validate(request->cv_proc[1].proc_status_cd) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","CV_PROC[1].PROC_STATUS_CD")
  GO TO exit_script
 ENDIF
 DECLARE cv_proc_size = i4 WITH noconstant(size(request->cv_proc,5)), protect
 DECLARE proc_idx = i4 WITH noconstant(0), protect
 DECLARE cv_step_size = i4 WITH noconstant(0), protect
 DECLARE step_idx = i4 WITH noconstant(0), protect
 DECLARE discontinued_ind = i2 WITH noconstant(0)
 DECLARE cancelled_ind = i2 WITH noconstant(0)
 DECLARE proc_started_ind = i2 WITH noconstant(0)
 DECLARE step_started_ind = i2 WITH noconstant(0)
 DECLARE status_started_ind = i2 WITH noconstant(0)
 DECLARE step_incomplete_ind = i2 WITH noconstant(0)
 DECLARE report_unsigned_flag = i2
 DECLARE report_edreview_flag = i2
 DECLARE g_proc_status_cd = f8 WITH noconstant(0.0)
 DECLARE status_incomplete_ind = i2 WITH noconstant(0)
 DECLARE prev_proc_status_cd = f8 WITH noconstant(0.0)
 DECLARE prev_status_incomplete_ind = i2 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE procedure_start_dt_tm = dq8 WITH noconstant(null_dt_tm)
 DECLARE nucmed_procedure_ind = i2 WITH noconstant(0)
 DECLARE stressecg_final_report_status_cd = f8 WITH noconstant(0.0)
 DECLARE final_report_status_cd = f8 WITH noconstant(0.0)
 DECLARE nucmeds_report_unsigned_flag = i2 WITH noconstant(0)
 FREE RECORD stat_list
 RECORD stat_list(
   1 status[*]
     2 proc_status_cd = f8
 )
 FREE RECORD stat_collate
 RECORD stat_collate(
   1 status[*]
     2 proc_status_cd = f8
     2 collation_seq = i4
     2 cdf_meaning = vc
 )
 DECLARE stat_size = i4 WITH noconstant(0), protect
 DECLARE stat_idx = i4 WITH noconstant(0), protect
 FREE RECORD stat_xref
 RECORD stat_xref(
   1 step[*]
     2 step_idx = i4
 )
 DECLARE xref_size = i4 WITH noconstant(0), protect
 DECLARE xref_idx = i4 WITH noconstant(0), protect
 SET curalias proc request->cv_proc[proc_idx]
 SET curalias step request->cv_proc[proc_idx].cv_step[step_idx]
 SET curalias sched request->cv_proc[proc_idx].cv_step[step_idx].cv_step_sched[1]
 FOR (proc_idx = 1 TO cv_proc_size)
  SET cv_step_size = size(proc->cv_step,5)
  FOR (step_idx = 1 TO cv_step_size)
    IF ((step->proc_status_cd > 0.0)
     AND 0=locateval(stat_idx,1,stat_size,step->proc_status_cd,stat_list->status[stat_idx].
     proc_status_cd))
     SET stat_size += 1
     SET stat = alterlist(stat_list->status,stat_size)
     SET stat_list->status[stat_size].proc_status_cd = step->proc_status_cd
    ENDIF
  ENDFOR
 ENDFOR
 SET stat = alterlist(stat_collate->status,stat_size)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE expand(stat_idx,1,stat_size,cv.code_value,stat_list->status[stat_idx].proc_status_cd)
   AND cv.code_set=cs_proc_stat
   AND cv.active_ind=1
  ORDER BY cv.collation_seq
  HEAD REPORT
   stat_idx = 0
  DETAIL
   stat_idx += 1, stat_collate->status[stat_idx].proc_status_cd = cv.code_value, stat_collate->
   status[stat_idx].collation_seq = cv.collation_seq,
   stat_collate->status[stat_idx].cdf_meaning = cv.cdf_meaning
  FOOT REPORT
   IF (stat_size != stat_idx)
    stat_size = stat_idx, stat = alterlist(stat_collate->status,stat_size),
    CALL cv_log_msg(cv_audit,"STAT_COLLATE is smaller than STAT_LIST"),
    CALL echorecord(stat_list),
    CALL echorecord(stat_collate)
   ENDIF
  WITH nocounter
 ;end select
 FREE RECORD stat_list
 CALL echorecord(stat_collate)
 FOR (proc_idx = 1 TO cv_proc_size)
   SET g_proc_status_cd = 0.0
   SET prev_proc_status_cd = 0.0
   SET prev_status_incomplete_ind = 0
   SET discontinued_ind = 0
   SET cancelled_ind = 0
   SET cv_step_size = size(proc->cv_step,5)
   CALL echo(cv_step_size)
   IF (cv_step_size=0)
    CALL cv_log_msg(cv_warning,build2("cv_proc_id=",proc->cv_proc_id," has no steps"))
   ELSE
    SET procedure_start_dt_tm = null_dt_tm
    FOR (step_idx = 1 TO cv_step_size)
      IF ((step->step_type_cd=step_type_procedure_cd)
       AND (step->perf_start_dt_tm != 0.0)
       AND (step->perf_start_dt_tm < procedure_start_dt_tm))
       SET procedure_start_dt_tm = step->perf_start_dt_tm
       CALL cv_log_msg(cv_debug,build("procedure_start_dt_tm=",procedure_start_dt_tm))
      ELSEIF ((step->step_type_cd=step_type_cd_final_report_cd))
       IF (dicom_pdf_report_type_stressecg_cd=uar_get_code_by("MEANING",4002763,step->doc_id_str))
        SET nucmed_procedure_ind = 1
        SET stressecg_final_report_status_cd = step->step_status_cd
       ELSE
        SET final_report_status_cd = step->step_status_cd
       ENDIF
      ENDIF
    ENDFOR
    IF (procedure_start_dt_tm != null_dt_tm
     AND (procedure_start_dt_tm != proc->action_dt_tm))
     SET proc->action_dt_tm = procedure_start_dt_tm
     SET proc->modified_ind = 1
    ENDIF
    SET stat = initrec(stat_xref)
    SET stat = alterlist(stat_xref->step,cv_step_size)
    SET xref_idx = 0
    FOR (stat_idx = 1 TO stat_size)
     SET idx = locateval(step_idx,1,cv_step_size,stat_collate->status[stat_idx].proc_status_cd,step->
      proc_status_cd)
     WHILE (idx > 0)
       SET xref_idx += 1
       SET stat_xref->step[xref_idx].step_idx = idx
       SET idx = locateval(step_idx,(idx+ 1),cv_step_size,stat_collate->status[stat_idx].
        proc_status_cd,step->proc_status_cd)
     ENDWHILE
    ENDFOR
    SET xref_size = xref_idx
    SET stat = alterlist(stat_xref->step,xref_size)
    CALL echorecord(stat_xref)
    SET status_started_ind = 0
    SET status_incomplete_ind = 0
    SET proc_started_ind = 0
    SET report_unsigned_flag = 0
    SET report_edreview_flag = 0
    FOR (xref_idx = 1 TO xref_size)
      SET step_idx = stat_xref->step[xref_idx].step_idx
      SET step_started_ind = 0
      IF ((reqdata->loglevel >= cv_debug))
       CALL cv_log_msg(cv_debug,build("xref_idx:",xref_idx))
       CALL cv_log_msg(cv_debug,build("step_idx:",step_idx))
       CALL cv_log_msg(cv_debug,build("prev_proc_status_cd:",prev_proc_status_cd))
       CALL cv_log_msg(cv_debug,build("g_proc_status_cd:",g_proc_status_cd))
       CALL cv_log_msg(cv_debug,build("discontinued_ind:",discontinued_ind))
       CALL cv_log_msg(cv_debug,build("cancelled_ind:",cancelled_ind))
      ENDIF
      IF (xref_size=1
       AND cv_step_size=1
       AND (request->cv_proc[xref_idx].cv_step[xref_idx].step_status_cd=step_stat_inprocess)
       AND (request->cv_proc[xref_idx].cv_step[xref_idx].proc_status_cd=proc_stat_signed))
       SET status_incomplete_ind = 1
       SET g_proc_status_cd = proc_stat_inprocess
       SET status_started_ind = 1
       SET proc_started_ind = 1
       CALL cv_log_msg(cv_debug,build("Selected procedure step is part of single step procedure."))
      ENDIF
      IF ((prev_proc_status_cd != step->proc_status_cd))
       IF (prev_status_incomplete_ind=0)
        IF (status_incomplete_ind=0)
         SET g_proc_status_cd = prev_proc_status_cd
        ELSE
         IF (prev_proc_status_cd=proc_stat_completed
          AND status_started_ind=1)
          SET g_proc_status_cd = proc_stat_inprocess
         ENDIF
         SET prev_status_incomplete_ind = 1
        ENDIF
        SET prev_proc_status_cd = step->proc_status_cd
       ENDIF
       SET status_started_ind = 0
       SET status_incomplete_ind = 0
      ENDIF
      CASE (step->step_status_cd)
       OF step_stat_discontinued:
        SET discontinued_ind = 1
        SET step_started_ind = 1
        SET status_started_ind = 1
        SET proc_started_ind = 1
       OF step_stat_cancelled:
        SET cancelled_ind = 1
       OF step_stat_completed:
       OF step_stat_inprocess:
       OF step_stat_saved:
       OF step_stat_edreview:
       OF step_stat_unsigned:
        SET step_started_ind = 1
        SET status_started_ind = 1
      ENDCASE
      IF ((step->proc_status_cd=proc_stat_completed)
       AND step_started_ind=1)
       SET proc_started_ind = 1
       CALL cv_log_msg(cv_debug,"proc_started_ind = 1")
      ENDIF
      IF ((step->step_status_cd != step_stat_completed))
       SET status_incomplete_ind = 1
       CALL cv_log_msg(cv_debug,"status_incomplete_ind = 1")
      ENDIF
      IF ((step->proc_status_cd=proc_stat_signed))
       IF ( NOT ((step->step_status_cd IN (step_stat_completed, step_stat_unsigned,
       step_stat_edreview))))
        SET report_edreview_flag = - (1)
       ELSEIF ((step->step_status_cd=step_stat_edreview)
        AND (report_edreview_flag != - (1)))
        SET report_edreview_flag = 1
       ENDIF
       IF ((step->step_status_cd=step_stat_unsigned)
        AND (report_unsigned_flag != - (1)))
        SET report_unsigned_flag = 1
       ENDIF
      ELSEIF (status_incomplete_ind=1)
       SET report_unsigned_flag = - (1)
      ENDIF
    ENDFOR
    IF (final_report_status_cd=step_stat_unsigned
     AND ((stressecg_final_report_status_cd=step_stat_unsigned) OR (stressecg_final_report_status_cd=
    step_stat_completed)) )
     SET nucmeds_report_unsigned_flag = 1
    ENDIF
    IF (prev_status_incomplete_ind=0
     AND status_incomplete_ind=0)
     SET g_proc_status_cd = step->proc_status_cd
    ELSEIF (report_unsigned_flag=1
     AND nucmed_procedure_ind != 1)
     SET g_proc_status_cd = proc_stat_unsigned
    ELSEIF (report_unsigned_flag=1
     AND nucmed_procedure_ind=1)
     IF (nucmeds_report_unsigned_flag=1)
      SET g_proc_status_cd = proc_stat_unsigned
     ELSE
      SET g_proc_status_cd = proc->proc_status_cd
     ENDIF
    ELSEIF (report_edreview_flag=1)
     SET g_proc_status_cd = proc_stat_edreview
     SET request->cv_proc[proc_idx].ed_review_ind = 1
    ENDIF
    IF ((request->cv_proc[proc_idx].ed_review_ind=1)
     AND g_proc_status_cd=proc_stat_completed
     AND (step->step_status_cd=step_stat_saved)
     AND (request->cv_proc[proc_idx].ed_review_status_cd=edreview_stat_available))
     SET request->cv_proc[proc_idx].ed_review_ind = 0
    ENDIF
    IF (((discontinued_ind=1) OR (cancelled_ind=1))
     AND proc_started_ind=1)
     SET g_proc_status_cd = proc_stat_discontinued
    ELSEIF (cancelled_ind=1)
     SET g_proc_status_cd = proc_stat_cancelled
    ENDIF
    IF (g_proc_status_cd=0.0)
     SET step_idx = locateval(step_idx,1,cv_step_size,1,step->schedule_ind)
     WHILE (step_idx > 0)
      IF ((sched->arrive_ind=1))
       SET g_proc_status_cd = proc_stat_arrived
      ELSEIF (g_proc_status_cd=0.0
       AND (sched->sched_stop_dt_tm != cnvtdatetime(0,0)))
       SET g_proc_status_cd = proc_stat_scheduled
      ENDIF
      SET step_idx = locateval(step_idx,(step_idx+ 1),cv_step_size,1,step->schedule_ind)
     ENDWHILE
    ENDIF
    IF (g_proc_status_cd=0.0)
     SET g_proc_status_cd = proc_stat_ordered
    ENDIF
    CALL cv_log_msg(cv_debug,build("Status =",uar_get_code_display(g_proc_status_cd)))
    IF ((request->cv_proc[proc_idx].proc_status_cd != g_proc_status_cd))
     SET request->cv_proc[proc_idx].modified_ind = 1
     SET request->cv_proc[proc_idx].proc_status_cd = g_proc_status_cd
    ENDIF
   ENDIF
 ENDFOR
 IF ((reqdata->loglevel >= cv_debug))
  FOR (proc_idx = 1 TO cv_proc_size)
    CALL cv_log_msg(cv_debug,build("Proc=",proc_idx,": Status =",uar_get_code_display(proc->
       proc_status_cd)))
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  CALL cv_log_msg(cv_warning,"CV_CALC_PROC_STATUS failed")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ENDIF
 SET curalias proc off
 SET curalias step off
 SET curalias sched off
 CALL cv_log_msg_post("013 09/03/18 VJ043510")
END GO
