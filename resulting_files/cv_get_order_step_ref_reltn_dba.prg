CREATE PROGRAM cv_get_order_step_ref_reltn:dba
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
 DECLARE m_nosrreqcnt = i4 WITH protect, noconstant(0)
 DECLARE m_nosrreqidx = i4 WITH protect, noconstant(0)
 DECLARE m_nosrblock = i4 WITH protect, constant(20)
 DECLARE m_nosrpad = i4 WITH protect, noconstant(0)
 DECLARE m_nosrstart = i4 WITH protect, noconstant(1)
 DECLARE m_nosrrepcnt = i4 WITH protect, noconstant(0)
 DECLARE m_nosrrepidx = i4 WITH protect, noconstant(0)
 DECLARE c_activity_type_cardiovascul = f8 WITH protect, constant(uar_get_code_by("MEANING",106,
   "CARDIOVASCUL"))
 DECLARE c_default_result_type_11 = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"11"))
 IF (validate(reply) != 1)
  RECORD reply(
    1 reltn[*]
      2 catalog_cd = f8
      2 catalog_disp = vc
      2 catalog_mean = c12
      2 task_assay_cd = f8
      2 task_assay_disp = vc
      2 task_assay_mean = c12
      2 step_type_cd = f8
      2 step_type_disp = vc
      2 step_type_mean = c12
      2 step_sequence = i4
      2 active_ind = i2
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
  SET m_nosrreqcnt = size(request->step_types,5)
 ENDIF
 IF (m_nosrreqcnt > 0)
  SET m_nosrpad = (m_nosrreqcnt+ ((m_nosrblock - 1) - mod((m_nosrreqcnt - 1),m_nosrblock)))
  SET stat = alterlist(request->step_types,m_nosrpad)
  FOR (m_nosrreqidx = (m_nosrreqcnt+ 1) TO m_nosrpad)
    SET request->step_types[m_nosrreqidx].step_type_cd = request->step_types[m_nosrreqcnt].
    step_type_cd
  ENDFOR
 ENDIF
 SELECT
  IF (m_nosrreqcnt > 0)
   FROM (dummyt d  WITH seq = value((m_nosrpad/ m_nosrblock))),
    cv_step_ref csr,
    profile_task_r ptr
   PLAN (d
    WHERE assign(m_nosrstart,evaluate(d.seq,1,1,(m_nosrstart+ m_nosrblock))))
    JOIN (csr
    WHERE expand(m_nosrreqidx,m_nosrstart,((m_nosrstart+ m_nosrblock) - 1),csr.step_type_cd,request->
     step_types[m_nosrreqidx].step_type_cd))
    JOIN (ptr
    WHERE ptr.task_assay_cd=csr.task_assay_cd
     AND ptr.active_ind=1)
   WITH nocounter
  ELSE
  ENDIF
  INTO "NL:"
  FROM cv_step_ref csr,
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (dta
   WHERE dta.activity_type_cd=c_activity_type_cardiovascul
    AND dta.default_result_type_cd=c_default_result_type_11)
   JOIN (csr
   WHERE (csr.task_assay_cd= Outerjoin(dta.task_assay_cd)) )
   JOIN (ptr
   WHERE ptr.task_assay_cd=csr.task_assay_cd
    AND ptr.active_ind=1)
  ORDER BY ptr.sequence
  HEAD REPORT
   m_nosrrepidx = 0, m_nosrrepcnt = 0
  DETAIL
   m_nosrrepidx += 1
   IF (m_nosrrepidx > m_nosrrepcnt)
    m_nosrrepcnt += 9, stat = alterlist(reply->reltn,m_nosrrepcnt)
   ENDIF
   reply->reltn[m_nosrrepidx].catalog_cd = ptr.catalog_cd, reply->reltn[m_nosrrepidx].step_sequence
    = ptr.sequence, reply->reltn[m_nosrrepidx].task_assay_cd = ptr.task_assay_cd,
   reply->reltn[m_nosrrepidx].active_ind = ptr.active_ind, reply->reltn[m_nosrrepidx].step_type_cd =
   csr.step_type_cd
  FOOT REPORT
   stat = alterlist(reply->reltn,m_nosrrepidx)
  WITH nocounter
 ;end select
 IF (m_nosrrepidx > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_info,"cv_get_order_step_ref_reltn returned status = 'Z'")
 ELSEIF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"cv_get_order_step_ref_reltn failed")
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 CALL cv_log_msg_post("002 03/19/2007 Adilson M. Ribeiro")
END GO
