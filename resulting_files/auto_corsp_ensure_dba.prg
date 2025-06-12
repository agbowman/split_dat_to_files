CREATE PROGRAM auto_corsp_ensure:dba
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
 RECORD cv_atr(
   1 stat = i4
   1 app_nbr = i4
   1 task_nbr = i4
   1 step_nbr = i4
   1 happ = i4
   1 htask = i4
   1 hstep = i4
   1 hrequest = i4
   1 hreply = i4
 ) WITH protect
 DECLARE cvperformatr(null) = i4 WITH protect
 DECLARE cvendatr(null) = null WITH protect
 SUBROUTINE (cvbeginatr(p_app_nbr=i4,p_task_nbr=i4,p_step_nbr=i4) =i4 WITH protect)
   SET cv_atr->app_nbr = p_app_nbr
   SET cv_atr->task_nbr = p_task_nbr
   SET cv_atr->step_nbr = p_step_nbr
   SET cv_atr->stat = uar_crmbeginapp(cv_atr->app_nbr,cv_atr->happ)
   IF ((cv_atr->stat != 0))
    CALL cv_log_stat(cv_error,"CALL","F","uar_CrmBeginApp",cnvtstring(cv_atr->stat))
    RETURN(1)
   ENDIF
   SET cv_atr->stat = uar_crmbegintask(cv_atr->happ,cv_atr->task_nbr,cv_atr->htask)
   IF ((cv_atr->stat != 0))
    CALL cv_log_stat(cv_error,"CALL","F","uar_CrmBeginTask",cnvtstring(cv_atr->stat))
    RETURN(2)
   ENDIF
   SET cv_atr->stat = uar_crmbeginreq(cv_atr->htask,"",cv_atr->step_nbr,cv_atr->hstep)
   IF ((cv_atr->stat != 0))
    CALL cv_log_stat(cv_error,"CALL","F","uar_CrmBeginReq",cnvtstring(cv_atr->stat))
    RETURN(3)
   ENDIF
   SET cv_atr->hrequest = uar_crmgetrequest(cv_atr->hstep)
   IF ((cv_atr->hrequest=0))
    CALL cv_log_stat(cv_error,"CALL","F","UAR_CrmGetRequest","0")
    RETURN(4)
   ENDIF
   CALL cv_log_msg(cv_info,"CvBeginAtr completed successfully")
   RETURN(0)
 END ;Subroutine
 SUBROUTINE cvperformatr(null)
   SET cv_atr->stat = uar_crmperform(cv_atr->hstep)
   IF ((cv_atr->stat != 0))
    CALL cv_log_stat(cv_error,"CALL","F","uar_CrmPerform",cnvtstring(cv_atr->stat))
    RETURN(1)
   ENDIF
   SET cv_atr->hreply = uar_crmgetreply(cv_atr->hstep)
   IF ((cv_atr->hreply=0))
    CALL cv_log_stat(cv_error,"CALL","F","uar_CrmGetReply","0")
    RETURN(2)
   ENDIF
   CALL cv_log_msg(cv_info,"CvPerformAtr completed succesfully")
   RETURN(0)
 END ;Subroutine
 SUBROUTINE cvendatr(null)
   IF (cv_atr->hstep)
    CALL uar_crmendreq(cv_atr->hstep)
   ENDIF
   IF (cv_atr->htask)
    CALL uar_crmendtask(cv_atr->htask)
   ENDIF
   IF (cv_atr->happ)
    CALL uar_crmendapp(cv_atr->happ)
   ENDIF
   SET stat = initrec(cv_atr)
 END ;Subroutine
 EXECUTE crmrtl
 EXECUTE srvrtl
 IF (validate(reply->status_data.status)=0)
  FREE SET reply
  RECORD reply(
    1 sb_severity = i4
    1 sb_status = i4
    1 sb_statustext = vc
    1 event_id = f8
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
 DECLARE c_event_class_doc = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE c_event_class_mdoc = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE c_succession_interim = f8 WITH protect, constant(uar_get_code_by("MEANING",63,"INTERIM"))
 DECLARE c_format_rtf = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"RTF"))
 DECLARE c_storage_blob = f8 WITH protect, constant(uar_get_code_by("MEANING",25,"BLOB"))
 DECLARE c_action_type_perform = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
 DECLARE c_action_type_sign = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE c_action_status_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",103,
   "COMPLETED"))
 DECLARE c_action_status_pending = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"PENDING")
  )
 DECLARE applicationid = i4 WITH constant(1000012), protect
 DECLARE taskid = i4 WITH constant(1000012), protect
 DECLARE requestid = i4 WITH constant(1000012), protect
 DECLARE hce = i4 WITH protect
 DECLARE hce2 = i4 WITH protect
 DECLARE hprsnl = i4 WITH protect
 DECLARE hce_type = i4 WITH protect
 DECLARE hce_struct = i4 WITH protect
 DECLARE hblob = i4 WITH protect
 DECLARE hblob2 = i4 WITH protect
 DECLARE hstatus = i4 WITH protect
 DECLARE hrb_list = i4 WITH protect
 DECLARE hrb = i4 WITH protect
 DECLARE rb_cnt = i4 WITH protect
 DECLARE rb_idx = i4 WITH protect
 DECLARE g_event_id = f8 WITH protect
 DECLARE g_parent_event_id = f8 WITH protect
 DECLARE now_dt_tm = q8 WITH noconstant(cnvtdatetime(sysdate)), protect
 DECLARE note_size = i4 WITH protect, noconstant(textlen(trim(request->note)))
 IF (note_size=0)
  CALL cv_log_stat(cv_warning,"REQUEST","F","NOTE","size=0")
  GO TO exit_script
 ENDIF
 IF (cvbeginatr(applicationid,taskid,requestid) != 0)
  GO TO exit_script
 ENDIF
 SET stat = uar_srvsetshort(cv_atr->hrequest,"ensure_type",1)
 SET hce = uar_srvgetstruct(cv_atr->hrequest,"clin_event")
 CALL cv_log_msg(cv_debug,build("hCE:",hce))
 IF (hce)
  SET stat = uar_srvsetdouble(hce,"person_id",request->person_id)
  SET stat = uar_srvsetdouble(hce,"contributor_system_cd",reqdata->contributor_system_cd)
  SET stat = uar_srvsetdouble(hce,"event_class_cd",c_event_class_mdoc)
  SET stat = uar_srvsetdouble(hce,"encntr_id",request->encntr_id)
  SET stat = uar_srvsetdouble(hce,"event_cd",request->event_cd)
  SET stat = uar_srvsetdouble(hce,"result_status_cd",reqdata->auth_inprogress_cd)
  SET stat = uar_srvsetdate(hce,"event_end_dt_tm",now_dt_tm)
  SET stat = uar_srvsetdouble(hce,"record_status_cd",reqdata->active_status_cd)
  SET stat = uar_srvsetlong(hce,"view_level",1)
  SET stat = uar_srvsetshort(hce,"authentic_flag",0)
  SET stat = uar_srvsetshort(hce,"publish_flag",request->publish_flag)
  SET stat = uar_srvsetstring(hce,"event_title_text",nullterm(request->title_text))
  SET stat = uar_srvsetdouble(hce,"parent_event_id",request->parent_event_id)
  SET hprsnl = uar_srvadditem(hce,"event_prsnl_list")
  IF (hprsnl)
   SET stat = uar_srvsetdouble(hprsnl,"person_id",request->person_id)
   SET stat = uar_srvsetdouble(hprsnl,"action_prsnl_id",request->prsnl_id)
   SET stat = uar_srvsetdouble(hprsnl,"action_type_cd",c_action_type_perform)
   SET stat = uar_srvsetdouble(hprsnl,"action_status_cd",c_action_status_completed)
   SET stat = uar_srvsetdate(hprsnl,"action_dt_tm",now_dt_tm)
  ELSE
   CALL cv_log_stat(cv_error,"UAR_SRVADDITEM","F","event_prsnl_list","")
   GO TO exit_script
  ENDIF
  SET hprsnl = uar_srvadditem(hce,"event_prsnl_list")
  IF (hprsnl)
   SET stat = uar_srvsetdouble(hprsnl,"person_id",request->person_id)
   SET stat = uar_srvsetdouble(hprsnl,"action_prsnl_id",request->prsnl_id)
   SET stat = uar_srvsetdouble(hprsnl,"action_type_cd",c_action_type_sign)
   SET stat = uar_srvsetdouble(hprsnl,"action_status_cd",c_action_status_pending)
   SET stat = uar_srvsetdouble(hprsnl,"request_prsnl_id",request->prsnl_id)
   SET stat = uar_srvsetdate(hprsnl,"request_dt_tm",now_dt_tm)
  ELSE
   CALL cv_log_stat(cv_error,"UAR_SRVADDITEM","F","event_prsnl_list","")
   GO TO exit_script
  ENDIF
  SET hce_type = uar_srvcreatetypefrom(cv_atr->hrequest,"clin_event")
  CALL cv_log_msg(cv_debug,build("hCE_Type:",hce_type))
  SET hce_struct = uar_srvgetstruct(cv_atr->hrequest,"clin_event")
  CALL cv_log_msg(cv_debug,build("hCE_Struct:",hce_struct))
  SET stat = uar_srvbinditemtype(hce_struct,"child_event_list",hce_type)
  SET hce2 = uar_srvadditem(hce_struct,"child_event_list")
  CALL cv_log_msg(cv_debug,build("hCE2:",hce2))
  IF (hce2)
   CALL uar_srvbinditemtype(hce2,"child_event_list",hce_type)
   SET stat = uar_srvsetdouble(hce2,"contributor_system_cd",reqdata->contributor_system_cd)
   SET stat = uar_srvsetdouble(hce2,"event_class_cd",c_event_class_doc)
   SET stat = uar_srvsetdouble(hce2,"person_id",request->person_id)
   SET stat = uar_srvsetdouble(hce2,"encntr_id",request->encntr_id)
   SET stat = uar_srvsetdouble(hce2,"event_cd",request->event_cd)
   SET stat = uar_srvsetdouble(hce2,"result_status_cd",reqdata->auth_inprogress_cd)
   SET stat = uar_srvsetdate(hce2,"event_end_dt_tm",now_dt_tm)
   SET stat = uar_srvsetstring(hce2,"collating_seq","1")
   SET stat = uar_srvsetdouble(hce2,"record_status_cd",reqdata->active_status_cd)
   SET stat = uar_srvsetlong(hce2,"view_level",0)
   SET stat = uar_srvsetshort(hce2,"authentic_flag",0)
   SET stat = uar_srvsetshort(hce2,"publish_flag",request->publish_flag)
   SET hprsnl = uar_srvadditem(hce2,"event_prsnl_list")
   IF (hprsnl)
    SET stat = uar_srvsetdouble(hprsnl,"person_id",request->person_id)
    SET stat = uar_srvsetdouble(hprsnl,"action_prsnl_id",request->prsnl_id)
    SET stat = uar_srvsetdouble(hprsnl,"action_type_cd",c_action_type_perform)
    SET stat = uar_srvsetdouble(hprsnl,"action_status_cd",c_action_status_completed)
    SET stat = uar_srvsetdate(hprsnl,"action_dt_tm",now_dt_tm)
   ELSE
    CALL cv_log_stat(cv_error,"UAR_SRVADDITEM","F","event_prsnl_list","")
    GO TO exit_script
   ENDIF
   SET hblob = uar_srvadditem(hce2,"blob_result")
   IF (hblob)
    SET stat = uar_srvsetdouble(hblob,"succession_type_cd",c_succession_interim)
    SET stat = uar_srvsetdouble(hblob,"storage_cd",c_storage_blob)
    SET stat = uar_srvsetdouble(hblob,"format_cd",c_format_rtf)
    SET hblob2 = uar_srvadditem(hblob,"blob")
    IF (hblob2)
     SET stat = uar_srvsetasis(hblob2,"blob_contents",request->note,note_size)
    ELSE
     CALL cv_log_stat(cv_error,"UAR_SRVADDITEM","F","blob","")
     GO TO exit_script
    ENDIF
   ELSE
    CALL cv_log_stat(cv_error,"UAR_SRVADDITEM","F","blob_result","")
    GO TO exit_script
   ENDIF
  ELSE
   CALL cv_log_stat(cv_error,"UAR_SRVADDITEM","F","child_event_list","")
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_stat(cv_error,"UAR_SRVGETSTRUCT","F","clin_event","")
  GO TO exit_script
 ENDIF
 IF (cvperformatr(null) != 0)
  GO TO exit_script
 ENDIF
 SET hstatus = uar_srvgetstruct(cv_atr->hreply,"sb")
 IF (hstatus)
  SET reply->sb_severity = uar_srvgetlong(hstatus,"severityCd")
  SET reply->sb_status = uar_srvgetlong(hstatus,"statusCd")
  SET reply->sb_statustext = uar_srvgetstringptr(hstatus,"statusText")
 ELSE
  CALL cv_log_stat(cv_warning,"UAR_SRVGETSTRUCT","F","sb","")
 ENDIF
 SET rb_cnt = uar_srvgetitemcount(cv_atr->hreply,"rb_list")
 IF (rb_cnt >= 1)
  SET hrb = uar_srvgetitem(cv_atr->hreply,"rb_list",1)
  SET reply->event_id = uar_srvgetdouble(hrb,"parent_event_id")
  CALL cv_log_msg(cv_info,build("event_id:",uar_srvgetdouble(hrb,"event_id"),",  parent_event_id:",
    reply->event_id))
 ELSE
  CALL cv_log_msg(cv_warning,"Reply rb_list is empty!")
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reqinfo->commit_ind = 0
  CALL echorecord(cv_atr)
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cvendatr(null)
 CALL cv_log_msg_post("002 10/16/2006 MH9140")
END GO
