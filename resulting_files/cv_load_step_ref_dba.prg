CREATE PROGRAM cv_load_step_ref:dba
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
 DECLARE m_nlsrreqcnt = i4 WITH protect, noconstant(0)
 DECLARE m_nlsrreqidx = i4 WITH protect, noconstant(0)
 DECLARE m_nlsrblock = i4 WITH protect, constant(20)
 DECLARE m_nlsrpad = i4 WITH protect, noconstant(0)
 DECLARE m_nlsrstart = i4 WITH protect, noconstant(1)
 DECLARE m_nlsrrepcnt = i4 WITH protect, noconstant(0)
 DECLARE m_nlsrrepidx = i4 WITH protect, noconstant(0)
 IF (validate(reply) != 1)
  RECORD reply(
    1 cv_step_ref[*]
      2 activity_subtype_cd = f8
      2 activity_subtype_disp = vc
      2 activity_subtype_mean = c12
      2 doc_type_cd = f8
      2 doc_type_disp = vc
      2 doc_type_mean = c12
      2 doc_id_str = vc
      2 doc_template_id = f8
      2 proc_status_cd = f8
      2 proc_status_disp = vc
      2 proc_status_mean = c12
      2 schedule_ind = i2
      2 step_level_flag = i2
      2 study_reltn_flag = i2
      2 task_assay_cd = f8
      2 task_assay_disp = vc
      2 task_assay_mean = c12
      2 step_type_cd = f8
      2 step_type_disp = vc
      2 step_type_mean = c12
      2 updt_cnt = i4
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
  CALL cv_log_msg(cv_error,"Reply doesn't contain status block")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request->step_types)=1)
  SET m_nlsrreqcnt = size(request->step_types,5)
 ENDIF
 IF (m_nlsrreqcnt > 0)
  SET m_nlsrpad = (m_nlsrreqcnt+ ((m_nlsrblock - 1) - mod((m_nlsrreqcnt - 1),m_nlsrblock)))
  SET stat = alterlist(request->step_types,m_nlsrpad)
  FOR (m_nlsrreqidx = (m_nlsrreqcnt+ 1) TO m_nlsrpad)
    SET request->step_types[m_nlsrreqidx].step_type_cd = request->step_types[m_nlsrreqcnt].
    step_type_cd
  ENDFOR
 ENDIF
 SELECT
  IF (m_nlsrreqcnt > 0)
   FROM (dummyt d  WITH seq = value((m_nlsrpad/ m_nlsrblock))),
    cv_step_ref csr
   PLAN (d
    WHERE assign(m_nlsrstart,evaluate(d.seq,1,1,(m_nlsrstart+ m_nlsrblock))))
    JOIN (csr
    WHERE expand(m_nlsrreqidx,m_nlsrstart,((m_nlsrstart+ m_nlsrblock) - 1),csr.step_type_cd,request->
     step_types[m_nlsrreqidx].step_type_cd))
   WITH nocounter
  ELSE
  ENDIF
  INTO "nl:"
  FROM cv_step_ref csr
  PLAN (csr
   WHERE csr.task_assay_cd > 0.0)
  HEAD REPORT
   m_nlsrrepidx = 0, m_nlsrrepcnt = 0
  DETAIL
   m_nlsrrepidx += 1
   IF (m_nlsrrepidx > m_nlsrrepcnt)
    m_nlsrrepcnt += 9, stat = alterlist(reply->cv_step_ref,m_nlsrrepcnt)
   ENDIF
   reply->cv_step_ref[m_nlsrrepidx].activity_subtype_cd = csr.activity_subtype_cd, reply->
   cv_step_ref[m_nlsrrepidx].doc_type_cd = csr.doc_type_cd, reply->cv_step_ref[m_nlsrrepidx].
   doc_id_str = csr.doc_id_str,
   reply->cv_step_ref[m_nlsrrepidx].doc_template_id = csr.doc_template_id, reply->cv_step_ref[
   m_nlsrrepidx].proc_status_cd = csr.proc_status_cd, reply->cv_step_ref[m_nlsrrepidx].schedule_ind
    = csr.schedule_ind,
   reply->cv_step_ref[m_nlsrrepidx].step_level_flag = csr.step_level_flag, reply->cv_step_ref[
   m_nlsrrepidx].study_reltn_flag = csr.study_reltn_flag, reply->cv_step_ref[m_nlsrrepidx].
   task_assay_cd = csr.task_assay_cd,
   reply->cv_step_ref[m_nlsrrepidx].step_type_cd = csr.step_type_cd, reply->cv_step_ref[m_nlsrrepidx]
   .updt_cnt = csr.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->cv_step_ref,m_nlsrrepidx)
  WITH nocounter
 ;end select
 IF (m_nlsrrepidx > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_info,"CV_LOAD_STEP_REF returned status = 'Z'")
 ELSEIF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_LOAD_STEP_REF failed")
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 CALL cv_log_msg_post("001 12/01/2016 MG023115")
END GO
