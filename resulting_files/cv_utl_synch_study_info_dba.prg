CREATE PROGRAM cv_utl_synch_study_info:dba
 PROMPT
  "Enter Beginning Date: [01-JAN-2007] " = "01-JAN-2007",
  "Enter Ending Date:    [01-JUL-2008] " = "01-JUL-2008"
  WITH startdate, stopdate
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
 SUBROUTINE (cvcnvtdttmtz(p_dt=i4,p_time_str=vc,p_tz=i4) =q8)
   RETURN(cnvtdatetimeutc(build2(format(p_dt,"DD-MMM-YYYY;;d")," ",format(substring(1,6,build(
        p_time_str,"000000")),"##:##:##")),3,p_tz))
 END ;Subroutine
 SUBROUTINE (cvcnvtdttm(p_dt=i4,p_time_str=vc) =q8)
   RETURN(cnvtdatetimeutc(build2(format(p_dt,"DD-MMM-YYYY;;d")," ",format(substring(1,6,build(
        p_time_str,"000000")),"##:##:##")),0))
 END ;Subroutine
 IF (validate(xxcclseclogin->loggedin,99) != 1)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(reply) != 1)
  RECORD reply(
    1 cv_steps[*]
      2 cv_step_id = f8
      2 updt_cnt = i4
      2 perf_start_dt_tm = dq8
      2 perf_stop_dt_tm = dq8
      2 perf_provider_id = f8
      2 perf_loc_cd = f8
      2 step_status_cd = f8
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
  CALL cv_log_stat(cv_error,"VALIDATE","F","REPLY","Reply doesn't contain status block")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 DECLARE contrib_powerchart = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"POWERCHART"))
 DECLARE study_state_mv = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"MV"))
 DECLARE doc_type_dicom = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"DICOM"))
 DECLARE g_perf_dt_tm = q8 WITH protect
 DECLARE act_subtype_ecg = f8 WITH protect
 DECLARE step_cnt = i4 WITH protect
 DECLARE step_idx = i4 WITH protect
 DECLARE fail_cnt = i4 WITH protect
 DECLARE subeventstatus_idx = i4 WITH protect
 DECLARE start_date = q8 WITH protect, constant(cnvtdatetime( $STARTDATE))
 DECLARE stop_date = q8 WITH protect, constant(cnvtdatetime( $STOPDATE))
 IF (start_date > stop_date)
  CALL cv_log_msg(cv_warning,"Beginning date is after ending date. Exiting program.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE cva.alias="ECG"
   AND cva.code_set=5801
   AND ((cva.contributor_source_cd+ 0)=contrib_powerchart)
   AND ((cva.alias_type_meaning=null) OR (cva.alias_type_meaning <= " "))
  DETAIL
   act_subtype_ecg = cva.code_value
  WITH nocounter
 ;end select
 IF (act_subtype_ecg <= 0.0)
  CALL cv_log_msg(cv_warning,"Failed to lookup ECG modality")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM cv_proc cp,
   cv_step_ref csr,
   cv_step cs,
   im_study_parent_r ispr,
   im_study im,
   im_acquired_study ias
  PLAN (csr
   WHERE csr.activity_subtype_cd=act_subtype_ecg
    AND csr.doc_type_cd=doc_type_dicom)
   JOIN (cp
   WHERE cp.action_dt_tm BETWEEN cnvtdatetime(cnvtdate(start_date),0) AND cnvtdatetime(cnvtdate(
     stop_date),235959))
   JOIN (cs
   WHERE cs.cv_proc_id=cp.cv_proc_id
    AND cs.task_assay_cd=csr.task_assay_cd)
   JOIN (ispr
   WHERE ispr.parent_entity_name="CV_PROC"
    AND ispr.parent_entity_id=cp.cv_proc_id)
   JOIN (im
   WHERE im.im_study_id=ispr.im_study_id
    AND im.study_state_cd=study_state_mv)
   JOIN (ias
   WHERE ias.matched_study_id=im.im_study_id)
  HEAD REPORT
   step_cnt = 0
  DETAIL
   g_perf_dt_tm = cvcnvtdttm(cnvtdate2(ias.study_date,"YYYYMMDD"),ias.study_time)
   IF (g_perf_dt_tm != cp.action_dt_tm)
    step_cnt += 1
    IF (step_cnt > size(reply->cv_steps,5))
     stat = alterlist(reply->cv_steps,(step_cnt+ 10))
    ENDIF
    reply->cv_steps[step_cnt].cv_step_id = cs.cv_step_id, reply->cv_steps[step_cnt].updt_cnt = cs
    .updt_cnt, reply->cv_steps[step_cnt].perf_start_dt_tm = g_perf_dt_tm,
    reply->cv_steps[step_cnt].perf_stop_dt_tm = g_perf_dt_tm, reply->cv_steps[step_cnt].
    perf_provider_id = cs.perf_provider_id, reply->cv_steps[step_cnt].perf_loc_cd = cs.perf_loc_cd,
    reply->cv_steps[step_cnt].step_status_cd = cs.step_status_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->cv_steps,step_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  CALL cv_log_stat(cv_info,"SELECT","Z","CV_PROC","No items with out of synch study dates found.")
  GO TO exit_script
 ENDIF
 FREE RECORD step_perform_request
 RECORD step_perform_request(
   1 cv_step_id = f8
   1 updt_cnt = i4
   1 perf_start_dt_tm = dq8
   1 perf_stop_dt_tm = dq8
   1 perf_provider_id = f8
   1 perf_loc_cd = f8
   1 step_status_cd = f8
 )
 FREE RECORD step_perform_reply
 RECORD step_perform_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET fail_cnt = 0
 FOR (step_idx = 1 TO step_cnt)
   SET step_perform_request->cv_step_id = reply->cv_steps[step_idx].cv_step_id
   SET step_perform_request->updt_cnt = reply->cv_steps[step_idx].updt_cnt
   SET step_perform_request->perf_start_dt_tm = reply->cv_steps[step_idx].perf_start_dt_tm
   SET step_perform_request->perf_stop_dt_tm = reply->cv_steps[step_idx].perf_stop_dt_tm
   SET step_perform_request->perf_provider_id = reply->cv_steps[step_idx].perf_provider_id
   SET step_perform_request->perf_loc_cd = reply->cv_steps[step_idx].perf_loc_cd
   SET step_perform_request->step_status_cd = reply->cv_steps[step_idx].step_status_cd
   SET step_perform_reply->status_data.status = "F"
   EXECUTE cv_set_step_perform  WITH replace("REQUEST",step_perform_request), replace("REPLY",
    step_perform_reply)
   IF ((step_perform_reply->status_data.status != "S"))
    SET fail_cnt += 1
    IF (size(step_perform_reply->status_data.subeventstatus,5) > 0)
     FOR (subeventstatus_idx = 1 TO size(step_perform_reply->status_data.subeventstatus,5))
       CALL cv_log_stat(cv_error,step_perform_reply->status_data.subeventstatus[subeventstatus_idx].
        operationname,step_perform_reply->status_data.subeventstatus[subeventstatus_idx].
        operationstatus,step_perform_reply->status_data.subeventstatus[subeventstatus_idx].
        targetobjectname,step_perform_reply->status_data.subeventstatus[subeventstatus_idx].
        targetobjectvalue)
     ENDFOR
    ENDIF
   ENDIF
   IF ((reqinfo->commit_ind=1))
    CALL echo(concat("Successfully updated cv_step_id ",trim(cnvtstring(step_perform_request->
        cv_step_id))))
   ELSE
    CALL echo(concat("Unable to update cv_step_id ",trim(cnvtstring(step_perform_request->cv_step_id)
       )))
   ENDIF
   IF (((mod(step_idx,100)=0) OR (step_idx=step_cnt)) )
    CALL echo("Committing batch of up to 100 updates")
    COMMIT
   ENDIF
   SET stat = initrec(step_perform_request)
   SET stat = initrec(step_perform_reply)
 ENDFOR
 IF (fail_cnt > 0
  AND fail_cnt < step_cnt)
  SET reply->status_data.status = "P"
  GO TO exit_script
 ELSEIF (fail_cnt >= step_cnt)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="F"))
  CALL cv_log_msg(cv_error,"CV_UTL_SYNCH_STUDY_INFO failed!")
  CALL echorecord(reply)
 ELSEIF ((reply->status_data.status="P"))
  CALL cv_log_msg(cv_warning,concat("Unable to update ",cnvtstring(fail_cnt),
    " steps. Make sure steps are not locked and try again."))
 ELSE
  CALL cv_log_msg(cv_info,"CV_UTL_SYNCH_STUDY_INFO successful")
 ENDIF
 CALL cv_log_msg_post("MOD 001 BM9013 03/17/2008")
END GO
