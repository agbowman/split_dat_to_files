CREATE PROGRAM auto_corsp_sign_note:dba
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
 RECORD cv_app_info(
   1 updt_id = f8
   1 updt_applctx = i4
   1 updt_appid = i4
   1 position_cd = f8
   1 location_cd = f8
   1 default_loc_cd = f8
   1 request_log_level = i2
   1 qual[*]
     2 task_number = i4
     2 request_number = i4
     2 cpmsend_ind = i2
     2 client_node_name = vc
 ) WITH protect
 SUBROUTINE (cvgetappinfo(p_happ=i4) =i4)
   DECLARE happinfo = i4 WITH protect
   SET stat = initrec(cv_app_info)
   SET happinfo = uar_crmgetappinfo(p_happ)
   IF (happinfo=0)
    RETURN(1)
   ENDIF
   SET cv_app_info->updt_id = uar_srvgetdouble(happinfo,"updt_id")
   SET cv_app_info->updt_applctx = uar_srvgetlong(happinfo,"updt_applctx")
   SET cv_app_info->updt_appid = uar_srvgetlong(happinfo,"updt_appid")
   SET cv_app_info->position_cd = uar_srvgetdouble(happinfo,"position_cd")
   SET cv_app_info->location_cd = uar_srvgetdouble(happinfo,"location_cd")
   SET cv_app_info->default_loc_cd = uar_srvgetdouble(happinfo,"default_loc_cd")
   SET cv_app_info->request_log_level = uar_srvgetshort(happinfo,"request_log_level")
   RETURN(0)
 END ;Subroutine
 EXECUTE crmrtl
 EXECUTE srvrtl
 IF (validate(reply->status_data.status)=0)
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
 DECLARE c_action_type_verify = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"VERIFY"))
 DECLARE c_action_type_perform = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
 DECLARE c_action_type_sign = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE c_action_status_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",103,
   "COMPLETED"))
 DECLARE c_action_status_pending = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"PENDING")
  )
 DECLARE c_action_status_deleted = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"DELETED")
  )
 DECLARE c_app_nbr = i4 WITH constant(1000012), protect
 DECLARE c_task_nbr = i4 WITH constant(1000012), protect
 DECLARE c_request_nbr = i4 WITH constant(1000012), protect
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
 DECLARE g_publish_flag = i4 WITH protect
 DECLARE iret = i4 WITH protect
 DECLARE srvstat = i4 WITH protect
 DECLARE g_event_cd = f8 WITH protect
 DECLARE g_person_id = f8 WITH protect
 DECLARE g_sign_pending_event_prsnl_id = f8 WITH protect
 DECLARE g_sign_pending_prsnl_id = f8
 DECLARE g_child_event_id = f8 WITH protect
 DECLARE now_dt_tm = q8 WITH noconstant(cnvtdatetime(sysdate)), protect
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.parent_event_id=request->event_id)
    AND ce.valid_until_dt_tm=cnvtdatetime(null_dt_tm)
    AND ce.event_class_cd=c_event_class_doc
    AND (ce.event_id != request->event_id))
  HEAD REPORT
   IF ((ce.result_status_cd != reqdata->auth_inprogress_cd))
    CALL cv_log_stat(cv_warning,"SELECT","F","CLINICAL_EVENT",build("EVENT_ID:",request->event_id,
     ": has result_status_cd=",ce.result_status_cd)),
    CALL cancel(1)
   ENDIF
   g_child_event_id = ce.event_id, g_event_cd = ce.event_cd, g_person_id = ce.person_id
  DETAIL
   col 0
  WITH nocounter
 ;end select
 IF (g_child_event_id=0.0)
  CALL cv_log_stat(cv_warning,"SELECT","F","CLINICAL_EVENT",build("PARENT_EVENT_ID=",request->
    event_id))
  GO TO exit_script
 ENDIF
 CALL cv_log_msg(cv_info,build("g_child_event_id=",g_child_event_id))
 CALL cv_log_msg(cv_info,build("g_event_cd=",g_event_cd))
 CALL cv_log_msg(cv_info,build("g_person_id=",g_person_id))
 IF (g_event_cd=0.0)
  CALL cv_log_stat(cv_warning,"SELECT","F","CLINICAL_EVENT",build2("EVENT_ID:",request->event_id,
    " has EVENT_CD=0.0"))
  GO TO exit_script
 ELSE
  SELECT INTO "nl:"
   FROM note_type nt
   WHERE nt.event_cd=g_event_cd
   DETAIL
    IF (nt.publish_level < 5)
     g_publish_flag = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_stat(cv_warning,"SELECT","F","NOTE_TYPE",build("EVENT_CD=",g_event_cd))
   CALL cv_log_msg(cv_warning,"Publish_flag will not be set")
  ENDIF
 ENDIF
 CALL cv_log_msg(cv_info,build("g_publish_flag =",g_publish_flag))
 SELECT INTO "nl:"
  FROM ce_event_prsnl cep
  WHERE (cep.event_id=request->event_id)
   AND cep.action_type_cd=c_action_type_sign
   AND cep.action_status_cd=c_action_status_pending
   AND cep.valid_until_dt_tm=cnvtdatetime(null_dt_tm)
  ORDER BY cep.action_dt_tm
  DETAIL
   g_sign_pending_prsnl_id = cep.request_prsnl_id, g_sign_pending_event_prsnl_id = cep.event_prsnl_id
  WITH maxqual(cep,1)
 ;end select
 CALL cv_log_msg(cv_info,build("g_sign_pending_event_prsnl_id=",g_sign_pending_event_prsnl_id))
 CALL cv_log_msg(cv_info,build("g_sign_pending_prsnl_id      =",g_sign_pending_prsnl_id))
 IF (cvbeginatr(c_app_nbr,c_task_nbr,c_request_nbr) != 0)
  GO TO exit_script
 ENDIF
 SET stat = cvgetappinfo(cv_atr->happ)
 CALL cv_log_msg(cv_info,build("cv_app_info->updt_id         =",cv_app_info->updt_id))
 CALL cv_log_msg(cv_info,build("reqinfo->updt_id             =",reqinfo->updt_id))
 SET hce = uar_srvgetstruct(cv_atr->hrequest,"clin_event")
 CALL cv_log_msg(cv_debug,build("hCE:",hce))
 SET srvstat = uar_srvsetshort(cv_atr->hrequest,"ensure_type",258)
 IF (hce)
  SET srvstat = uar_srvsetdouble(hce,"event_id",request->event_id)
  SET srvstat = uar_srvsetdouble(hce,"result_status_cd",reqdata->auth_auth_cd)
  SET srvstat = uar_srvsetdate(hce,"verified_dt_tm",now_dt_tm)
  SET srvstat = uar_srvsetdouble(hce,"verified_prsnl_id",reqinfo->updt_id)
  SET srvstat = uar_srvsetshort(hce,"publish_flag",g_publish_flag)
  SET srvstat = uar_srvsetshort(hce,"authentic_flag",1)
  SET srvstat = uar_srvsetshort(hce,"view_level",1)
  SET srvstat = uar_srvsetshort(hce,"view_level_ind",1)
  SET hprsnl = uar_srvadditem(hce,"event_prsnl_list")
  IF (hprsnl)
   IF ((cv_app_info->updt_id=g_sign_pending_prsnl_id))
    CALL cv_log_msg(cv_info,"Updating existing SIGN ce_event_prsnl")
    SET srvstat = uar_srvsetdouble(hprsnl,"event_prsnl_id",g_sign_pending_event_prsnl_id)
    SET srvstat = uar_srvsetdouble(hprsnl,"request_prsnl_id",g_sign_pending_prsnl_id)
   ELSE
    SET srvstat = uar_srvsetdouble(hprsnl,"request_prsnl_id",reqinfo->updt_id)
    CALL cv_log_stat(cv_audit,"INFO","S","CE_EVENT_PRSNL","Creating new SIGN ce_event_prsnl")
   ENDIF
   SET srvstat = uar_srvsetdouble(hprsnl,"event_id",request->event_id)
   SET srvstat = uar_srvsetdouble(hprsnl,"request_prsnl_id",reqinfo->updt_id)
   SET srvstat = uar_srvsetdate(hprsnl,"request_dt_tm",now_dt_tm)
   SET srvstat = uar_srvsetdouble(hprsnl,"person_id",g_person_id)
   SET srvstat = uar_srvsetdouble(hprsnl,"action_prsnl_id",cv_app_info->updt_id)
   SET srvstat = uar_srvsetdouble(hprsnl,"action_type_cd",c_action_type_sign)
   SET srvstat = uar_srvsetdouble(hprsnl,"action_status_cd",c_action_status_completed)
   SET srvstat = uar_srvsetdate(hprsnl,"action_dt_tm",now_dt_tm)
  ELSE
   CALL cv_log_stat(cv_error,"UAR_SRVADDITEM","F","event_prsnl_list","")
   GO TO exit_script
  ENDIF
  SET hprsnl = uar_srvadditem(hce,"event_prsnl_list")
  IF (hprsnl)
   SET srvstat = uar_srvsetdouble(hprsnl,"person_id",g_person_id)
   SET srvstat = uar_srvsetdouble(hprsnl,"action_prsnl_id",reqinfo->updt_id)
   SET srvstat = uar_srvsetdouble(hprsnl,"action_type_cd",c_action_type_verify)
   SET srvstat = uar_srvsetdouble(hprsnl,"action_status_cd",c_action_status_completed)
   SET srvstat = uar_srvsetdate(hprsnl,"action_dt_tm",now_dt_tm)
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
   SET srvstat = uar_srvsetdouble(hce2,"event_id",g_child_event_id)
   SET srvstat = uar_srvsetdouble(hce2,"result_status_cd",reqdata->auth_auth_cd)
   SET srvstat = uar_srvsetdate(hce2,"verified_dt_tm",now_dt_tm)
   SET srvstat = uar_srvsetdouble(hce2,"verified_prsnl_id",reqinfo->updt_id)
   SET srvstat = uar_srvsetshort(hce2,"publish_flag",g_publish_flag)
   SET srvstat = uar_srvsetshort(hce2,"authentic_flag",1)
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
  GO TO exit_script
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
 IF ((reply->event_id <= 0.0))
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL echorecord(cv_atr)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cvendatr(null)
 CALL cv_log_msg(cv_audit,reply->sb_statustext)
 CALL cv_log_msg_post("002 06/19/2006 MH9140")
END GO
