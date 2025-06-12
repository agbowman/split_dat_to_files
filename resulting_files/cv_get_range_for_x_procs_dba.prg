CREATE PROGRAM cv_get_range_for_x_procs:dba
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
 IF (validate(reply,"-1")="-1")
  RECORD reply(
    1 end_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(reply->status_data.status,"-1")="-1")
  CALL cv_log_stat(cv_error,"VALIDATE","F","status_block","No status block found in reply.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE g_beg_dt_tm = q8 WITH protect, constant(validate(request->beg_dt_tm,cnvtdatetime(
    "01-JAN-1800")))
 DECLARE serrmsg = vc WITH protect
 DECLARE cur_list_size = i4 WITH protect, noconstant(size(request->activity_subtype,5))
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE new_list_size = i4 WITH protect
 DECLARE loop_cnt = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE proc_status_signed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000341,"SIGNED"
   ))
 IF (cur_list_size <= 0)
  CALL cv_log_msg(cv_info,"No activity subtypes to filter against. Exiting script.")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (validate(request->procs_to_retrieve,0)=0)
  CALL cv_log_stat(cv_info,"VALIDATE","Z","proc_to_retrieve",
   "Procs to retrieve zero or not defined. Exit script.")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (cur_list_size > 1)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(request->activity_subtype,new_list_size)
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET request->activity_subtype[idx].activity_subtype_cd = request->activity_subtype[cur_list_size]
    .activity_subtype_cd
  ENDFOR
 ENDIF
 SELECT
  IF (cur_list_size > 1)
   FROM cv_proc cp,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (cp
    WHERE cp.proc_status_cd=proc_status_signed_cd
     AND expand(idx,nstart,(nstart+ (batch_size - 1)),cp.activity_subtype_cd,request->
     activity_subtype[idx].activity_subtype_cd)
     AND cp.action_dt_tm >= cnvtdatetime(g_beg_dt_tm))
  ELSE
   FROM cv_proc cp
   WHERE cp.proc_status_cd=proc_status_signed_cd
    AND (cp.activity_subtype_cd=request->activity_subtype[1].activity_subtype_cd)
    AND cp.action_dt_tm >= cnvtdatetime(g_beg_dt_tm)
  ENDIF
  INTO "nl:"
  FROM cv_proc cp
  WHERE (cp.cv_proc_id=- (1.0))
  ORDER BY cp.action_dt_tm
  FOOT REPORT
   reply->end_dt_tm = cp.action_dt_tm
  WITH nocounter, maxqual(cp,value(request->procs_to_retrieve))
 ;end select
 SET stat = alterlist(request->activity_subtype,cur_list_size)
 IF (error(serrmsg,0) > 0)
  CALL cv_log_stat(cv_error,"SELECT","F","CV_PROC",serrmsg)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="F"))
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
END GO
