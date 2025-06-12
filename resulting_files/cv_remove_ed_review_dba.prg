CREATE PROGRAM cv_remove_ed_review:dba
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
 FREE RECORD error_info
 RECORD error_info(
   1 error_list[*]
     2 status = vc
     2 error_code = i2
     2 error_msg = vc
 )
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
 DECLARE removecount = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET removecount = size(request->orderlist,5)
 IF (removecount > 0)
  CALL cv_log_msg(cv_debug,concat("removeCount is : ",cnvtstring(removecount)))
  SET stat = alterlist(error_info->error_list,removecount)
  UPDATE  FROM cv_ed_review cer,
    (dummyt d  WITH seq = removecount)
   SET cer.review_status_cd = edreview_stat_removed, cer.valid_until_dt_tm = cnvtdatetime(sysdate),
    cer.updt_id = reqinfo->updt_id,
    cer.updt_dt_tm = cnvtdatetime(sysdate), cer.updt_task = reqinfo->updt_task, cer.updt_applctx =
    reqinfo->updt_applctx,
    cer.updt_cnt = (cer.updt_cnt+ 1)
   PLAN (d)
    JOIN (cer
    WHERE (cer.order_id=request->orderlist[d.seq].order_id)
     AND cer.review_status_cd > 0.0
     AND cer.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   WITH status(error_info->error_list[d.seq].status,error_info->error_list[d.seq].error_code,
    error_info->error_list[d.seq].error_msg), nocounter
  ;end update
  CALL cv_log_msg(cv_debug,concat("curqual after update was : ",cnvtstring(curqual)))
  SET ierrcode = error(serrmsg,0)
  IF (curqual != removecount)
   SET reply->status_data.status = "F"
   CALL cv_log_message_status("CV_ED_REVIEW","F","UPDATE",concat("There were ",cnvtstring((
      removecount - curqual)),"Invalid Records filtered from update"))
   CALL cv_log_msg(cv_debug,"Update failure details...")
   FOR (idx = 1 TO removecount)
     IF ((error_info->error_list[idx].error_code != 0))
      CALL cv_log_msg(cv_debug,concat("order_id : ",cnvtstring(error_info->validreviewinfolist[idx].
         order_id)))
      CALL cv_log_msg(cv_debug,concat("Reason for failure : ",error_info->error_list[idx].error_msg))
     ENDIF
   ENDFOR
  ENDIF
  IF (ierrcode > 0)
   CALL cv_log_msg(cv_debug,"Exiting cv_remove_ed_review from since update failed...")
   CALL cv_check_err("UPDATE","F","CV_ED_REVIEW")
  ENDIF
  IF (curqual=removecount)
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  CALL cv_log_message_status("CV_ED_REVIEW","F","NULLCHECK","Request List was found Empty")
  CALL cv_log_msg(cv_debug,"Exiting cv_remove_ed_review since removeCount was zero...")
 ENDIF
 GO TO exit_script
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"cv_remove_ed_review failed")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("000 11/12/09 RV018483")
END GO
