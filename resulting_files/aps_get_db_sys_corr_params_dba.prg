CREATE PROGRAM aps_get_db_sys_corr_params:dba
 RECORD temp_rsrc_security(
   1 l_cnt = i4
   1 list[*]
     2 service_resource_cd = f8
     2 viewable_srvc_rsrc_ind = i2
   1 security_enabled = i2
 )
 RECORD default_service_type_cd(
   1 service_type_cd_list[*]
     2 service_type_cd = f8
 )
 DECLARE nres_sec_failed = i2 WITH protect, constant(0)
 DECLARE nres_sec_passed = i2 WITH protect, constant(1)
 DECLARE nres_sec_err = i2 WITH protect, constant(2)
 DECLARE nres_sec_msg_type = i2 WITH protect, constant(0)
 DECLARE ncase_sec_msg_type = i2 WITH protect, constant(1)
 DECLARE ncorr_group_sec_msg_type = i2 WITH protect, constant(2)
 DECLARE sres_sec_error_msg = c23 WITH protect, constant("RESOURCE SECURITY ERROR")
 DECLARE sres_sec_failed_msg = c24 WITH protect, constant("RESOURCE SECURITY FAILED")
 DECLARE scase_sec_failed_msg = c20 WITH protect, constant("CASE SECURITY FAILED")
 DECLARE scorr_group_sec_failed_msg = c24 WITH protect, constant("CORR GRP SECURITY FAILED")
 DECLARE m_nressecind = i2 WITH protect, noconstant(0)
 DECLARE m_sressecstatus = c1 WITH protect, noconstant("S")
 DECLARE m_nressecapistatus = i2 WITH protect, noconstant(0)
 DECLARE m_nressecerrorind = i2 WITH protect, noconstant(0)
 DECLARE m_lressecfailedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_lresseccheckedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_nressecalterstatus = i2 WITH protect, noconstant(0)
 DECLARE m_lressecstatusblockcnt = i4 WITH protect, noconstant(0)
 DECLARE m_ntaskgrantedind = i2 WITH protect, noconstant(0)
 DECLARE m_sfailedmsg = c25 WITH protect
 DECLARE m_bresourceapicalled = i2 WITH protect, noconstant(0)
 SET temp_rsrc_security->l_cnt = 0
 SUBROUTINE (initresourcesecurity(resource_security_ind=i2) =null)
   IF (resource_security_ind=1)
    SET m_nressecind = true
   ELSE
    SET m_nressecind = false
   ENDIF
 END ;Subroutine
 SUBROUTINE (isresourceviewable(service_resource_cd=f8) =i2)
   DECLARE srvc_rsrc_idx = i4 WITH protect, noconstant(0)
   DECLARE l_srvc_rsrc_pos = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET m_lresseccheckedcnt += 1
   IF (m_nressecind=false)
    RETURN(true)
   ENDIF
   IF (m_nressecerrorind=true)
    RETURN(false)
   ENDIF
   IF (service_resource_cd=0)
    RETURN(true)
   ENDIF
   IF (m_bresourceapicalled=true)
    IF ((temp_rsrc_security->security_enabled=1)
     AND size(temp_rsrc_security->list,5)=0)
     SET m_nressecapistatus = nres_sec_failed
    ELSEIF ((temp_rsrc_security->security_enabled=0)
     AND size(temp_rsrc_security->list,5)=0)
     SET m_nressecapistatus = nres_sec_passed
    ELSEIF ((temp_rsrc_security->l_cnt > 0))
     SET l_srvc_rsrc_pos = locateval(srvc_rsrc_idx,1,temp_rsrc_security->l_cnt,service_resource_cd,
      temp_rsrc_security->list[srvc_rsrc_idx].service_resource_cd)
     IF (l_srvc_rsrc_pos > 0)
      IF ((temp_rsrc_security->list[l_srvc_rsrc_pos].viewable_srvc_rsrc_ind=1))
       SET m_nressecapistatus = nres_sec_passed
      ELSE
       SET m_nressecapistatus = nres_sec_failed
      ENDIF
     ELSE
      SET m_nressecapistatus = nres_sec_failed
     ENDIF
    ENDIF
   ELSE
    RECORD request_3202551(
      1 prsnl_id = f8
      1 explicit_ind = i4
      1 debug_ind = i4
      1 service_type_cd_list[*]
        2 service_type_cd = f8
    )
    RECORD reply_3202551(
      1 security_enabled = i2
      1 service_resource_list[*]
        2 service_resource_cd = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET request_3202551->prsnl_id = reqinfo->updt_id
    IF (size(default_service_type_cd->service_type_cd_list,5) > 0)
     SET stat = alterlist(request_3202551->service_type_cd_list,size(default_service_type_cd->
       service_type_cd_list,5))
     FOR (idx = 1 TO size(default_service_type_cd->service_type_cd_list,5))
       SET request_3202551->service_type_cd_list[idx].service_type_cd = default_service_type_cd->
       service_type_cd_list[idx].service_type_cd
     ENDFOR
    ELSE
     SET stat = alterlist(request_3202551->service_type_cd_list,5)
     SET request_3202551->service_type_cd_list[1].service_type_cd = uar_get_code_by("MEANING",223,
      "SECTION")
     SET request_3202551->service_type_cd_list[2].service_type_cd = uar_get_code_by("MEANING",223,
      "SUBSECTION")
     SET request_3202551->service_type_cd_list[3].service_type_cd = uar_get_code_by("MEANING",223,
      "BENCH")
     SET request_3202551->service_type_cd_list[4].service_type_cd = uar_get_code_by("MEANING",223,
      "INSTRUMENT")
     SET request_3202551->service_type_cd_list[5].service_type_cd = uar_get_code_by("MEANING",223,
      "DEPARTMENT")
    ENDIF
    EXECUTE msvc_get_prsnl_svc_resources  WITH replace("REQUEST",request_3202551), replace("REPLY",
     reply_3202551)
    SET m_bresourceapicalled = true
    IF ((reply_3202551->status_data.status != "S"))
     SET m_nressecapistatus = nres_sec_err
    ELSEIF ((reply_3202551->security_enabled=1)
     AND size(reply_3202551->service_resource_list,5)=0)
     SET temp_rsrc_security->security_enabled = 1
     SET m_nressecapistatus = nres_sec_failed
    ELSEIF ((reply_3202551->security_enabled=0)
     AND size(reply_3202551->service_resource_list,5)=0)
     SET temp_rsrc_security->security_enabled = 0
     SET m_nressecapistatus = nres_sec_passed
    ELSE
     SET temp_rsrc_security->l_cnt = size(reply_3202551->service_resource_list,5)
     SET temp_rsrc_security->security_enabled = reply_3202551->security_enabled
     IF ((temp_rsrc_security->l_cnt > 0))
      SET stat = alterlist(temp_rsrc_security->list,temp_rsrc_security->l_cnt)
      FOR (idx = 1 TO size(reply_3202551->service_resource_list,5))
       SET temp_rsrc_security->list[idx].service_resource_cd = reply_3202551->service_resource_list[
       idx].service_resource_cd
       SET temp_rsrc_security->list[idx].viewable_srvc_rsrc_ind = 1
      ENDFOR
     ENDIF
     SET l_srvc_rsrc_pos = locateval(srvc_rsrc_idx,1,temp_rsrc_security->l_cnt,service_resource_cd,
      temp_rsrc_security->list[srvc_rsrc_idx].service_resource_cd)
     IF (l_srvc_rsrc_pos > 0)
      IF ((temp_rsrc_security->list[l_srvc_rsrc_pos].viewable_srvc_rsrc_ind=1))
       SET m_nressecapistatus = nres_sec_passed
      ELSE
       SET m_nressecapistatus = nres_sec_failed
      ENDIF
     ELSE
      SET m_nressecapistatus = nres_sec_failed
     ENDIF
    ENDIF
   ENDIF
   CASE (m_nressecapistatus)
    OF nres_sec_passed:
     RETURN(true)
    OF nres_sec_failed:
     SET m_lressecfailedcnt += 1
     RETURN(false)
    ELSE
     SET m_nressecerrorind = true
     RETURN(false)
   ENDCASE
 END ;Subroutine
 SUBROUTINE (getresourcesecuritystatus(fail_all_ind=i2) =c1)
  IF (m_nressecerrorind=true)
   SET m_sressecstatus = "F"
  ELSEIF (m_lresseccheckedcnt > 0
   AND m_lresseccheckedcnt=m_lressecfailedcnt)
   SET m_sressecstatus = "Z"
  ELSEIF (fail_all_ind=1
   AND m_lressecfailedcnt > 0)
   SET m_sressecstatus = "Z"
  ELSE
   SET m_sressecstatus = "S"
  ENDIF
  RETURN(m_sressecstatus)
 END ;Subroutine
 SUBROUTINE (populateressecstatusblock(message_type=i2) =null)
   IF (((m_sressecstatus="S") OR (validate(reply->status_data.status,"-1")="-1")) )
    RETURN
   ENDIF
   SET m_lressecstatusblockcnt = size(reply->status_data.subeventstatus,5)
   IF (m_lressecstatusblockcnt=1
    AND trim(reply->status_data.subeventstatus[1].operationname)="")
    SET m_ressecalterstatus = 0
   ELSE
    SET m_lressecstatusblockcnt += 1
    SET m_nressecalterstatus = alter(reply->status_data.subeventstatus,m_lressecstatusblockcnt)
   ENDIF
   CASE (message_type)
    OF ncase_sec_msg_type:
     SET m_sfailedmsg = scase_sec_failed_msg
    OF ncorr_group_sec_msg_type:
     SET m_sfailedmsg = scorr_group_sec_failed_msg
    ELSE
     SET m_sfailedmsg = sres_sec_failed_msg
   ENDCASE
   CASE (m_sressecstatus)
    OF "F":
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationname =
     sres_sec_error_msg
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationstatus = "F"
    OF "Z":
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationname = m_sfailedmsg
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationstatus = "Z"
   ENDCASE
 END ;Subroutine
 SUBROUTINE (istaskgranted(task_number=i4) =i2)
   SET m_ntaskgrantedind = false
   SELECT INTO "nl:"
    FROM application_group ag,
     task_access ta
    PLAN (ag
     WHERE (ag.position_cd=reqinfo->position_cd)
      AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ag.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (ta
     WHERE ta.app_group_cd=ag.app_group_cd
      AND ta.task_number=task_number)
    DETAIL
     m_ntaskgrantedind = true
    WITH nocounter
   ;end select
   RETURN(m_ntaskgrantedind)
 END ;Subroutine
 IF ((reqinfo->updt_app != 200070))
  CALL initresourcesecurity(1)
 ELSE
  CALL initresourcesecurity(0)
 ENDIF
#script
 DECLARE x = i2 WITH private, noconstant(0)
 DECLARE return_inactive_ind = i2 WITH private, noconstant(0)
 DECLARE return_trigger_ind = i2 WITH private, noconstant(0)
 DECLARE return_lookback_ind = i2 WITH private, noconstant(0)
 DECLARE use_request_reply_ind = i2 WITH private, noconstant(0)
 DECLARE sys_corr_cnt = i2
 DECLARE sys_corr_param_cnt = i2
 DECLARE sys_corr_detail_cnt = i2
 DECLARE dummyt_rows = i2
 DECLARE sys_corr_where = vc WITH private, noconstant("1=1")
 DECLARE sys_corr_detail_where = vc WITH private, noconstant(" ")
 DECLARE resource_viewable_ind = i2 WITH private, noconstant(0)
 IF (validate(req200393->called_from_script_ind,- (1)) != 1)
  RECORD reply(
    1 sys_corr_qual[*]
      2 sys_corr_id = f8
      2 study_id = f8
      2 case_percentage = i2
      2 active_ind = i2
      2 execute_on_rescreen_ind = i2
      2 lookback_case_type_cd = f8
      2 lookback_months = i2
      2 lookback_all_cases_ind = i2
      2 notify_user_online_ind = i2
      2 assign_to_group_ind = i2
      2 assign_to_group_id = f8
      2 assign_to_prsnl_id = f8
      2 assign_to_verifying_ind = i2
      2 updt_cnt = i4
      2 param_qual[*]
        3 param_name = c20
        3 param_sequence = i4
        3 lookback_ind = i2
        3 detail_qual[*]
          4 parent_entity_name = c32
          4 parent_entity_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET use_request_reply_ind = 1
  SET return_inactive_ind = request->return_inactive_ind
  SET return_trigger_ind = request->return_trigger_ind
  SET return_lookback_ind = request->return_lookback_ind
  SET sys_corr_cnt = cnvtint(size(request->sys_corr_qual,5))
  SET curalias sys_corr reply->sys_corr_qual[sys_corr_cnt]
  SET curalias reply_status reply->status_data
 ELSE
  SET use_request_reply_ind = 0
  SET return_inactive_ind = req200393->return_inactive_ind
  SET return_trigger_ind = req200393->return_trigger_ind
  SET return_lookback_ind = req200393->return_lookback_ind
  SET sys_corr_cnt = cnvtint(size(req200393->sys_corr_qual,5))
  SET curalias sys_corr reply200393->sys_corr_qual[sys_corr_cnt]
  SET curalias reply_status reply200393->status_data
 ENDIF
 SET reply_status->status = "F"
 IF (sys_corr_cnt > 0)
  IF (use_request_reply_ind=1)
   FOR (x = 1 TO sys_corr_cnt)
     IF (x=1)
      SET sys_corr_where = build("apsc.sys_corr_id IN (",request->sys_corr_qual[x].sys_corr_id)
     ELSE
      SET sys_corr_where = concat(sys_corr_where,build(",",request->sys_corr_qual[x].sys_corr_id))
     ENDIF
   ENDFOR
  ELSE
   FOR (x = 1 TO sys_corr_cnt)
     IF (x=1)
      SET sys_corr_where = build("apsc.sys_corr_id IN (",req200393->sys_corr_qual[x].sys_corr_id)
     ELSE
      SET sys_corr_where = concat(sys_corr_where,build(",",req200393->sys_corr_qual[x].sys_corr_id))
     ENDIF
   ENDFOR
  ENDIF
  SET sys_corr_where = concat(sys_corr_where,")")
 ENDIF
 IF (return_inactive_ind=0)
  SET sys_corr_where = concat(trim(sys_corr_where)," and apsc.active_ind = 1")
 ENDIF
 IF (return_trigger_ind=1
  AND return_lookback_ind=1)
  SET sys_corr_detail_where = "apsc.sys_corr_id = ascd.sys_corr_id"
 ELSEIF (return_trigger_ind=1)
  SET sys_corr_detail_where = "apsc.sys_corr_id = ascd.sys_corr_id and ascd.lookback_ind = 0"
 ELSE
  SET sys_corr_detail_where = "apsc.sys_corr_id = ascd.sys_corr_id and ascd.lookback_ind = 1"
 ENDIF
 SELECT INTO "nl:"
  apsc.sys_corr_id
  FROM ap_sys_corr apsc
  PLAN (apsc
   WHERE parser(sys_corr_where))
  HEAD REPORT
   sys_corr_cnt = 0
  DETAIL
   sys_corr_cnt += 1
  WITH nocounter
 ;end select
 IF (use_request_reply_ind=1)
  SET stat = alterlist(reply->sys_corr_qual,(sys_corr_cnt+ 9))
 ELSE
  SET stat = alterlist(reply200393->sys_corr_qual,(sys_corr_cnt+ 9))
 ENDIF
 IF (sys_corr_cnt > 0)
  SELECT INTO "nl:"
   apsc.sys_corr_id
   FROM ap_sys_corr apsc,
    ap_sys_corr_detail ascd,
    ap_dc_study ads
   PLAN (apsc
    WHERE parser(sys_corr_where))
    JOIN (ascd
    WHERE parser(sys_corr_detail_where))
    JOIN (ads
    WHERE apsc.study_id=ads.study_id)
   ORDER BY apsc.sys_corr_id, ascd.lookback_ind, ascd.param_name,
    ascd.param_sequence, ascd.sys_corr_detail_id
   HEAD REPORT
    sys_corr_cnt = 0
   HEAD apsc.sys_corr_id
    service_resource_cd = ads.service_resource_cd, resource_viewable_ind = isresourceviewable(
     service_resource_cd)
    IF (resource_viewable_ind=true)
     sys_corr_param_cnt = 0, sys_corr_cnt += 1, sys_corr->sys_corr_id = apsc.sys_corr_id,
     sys_corr->study_id = apsc.study_id, sys_corr->case_percentage = apsc.case_percentage, sys_corr->
     active_ind = apsc.active_ind,
     sys_corr->execute_on_rescreen_ind = apsc.execute_on_rescreen_ind, sys_corr->
     lookback_case_type_cd = apsc.lookback_case_type_cd, sys_corr->lookback_months = apsc
     .lookback_months,
     sys_corr->lookback_all_cases_ind = apsc.lookback_all_cases_ind, sys_corr->notify_user_online_ind
      = apsc.notify_user_online_ind, sys_corr->assign_to_group_ind = apsc.assign_to_group_ind,
     sys_corr->assign_to_group_id = apsc.assign_to_group_id, sys_corr->assign_to_prsnl_id = apsc
     .assign_to_prsnl_id, sys_corr->assign_to_verifying_ind = apsc.assign_to_verifying_ind,
     sys_corr->updt_cnt = apsc.updt_cnt
    ENDIF
   HEAD ascd.lookback_ind
    sys_corr_cnt = sys_corr_cnt
   HEAD ascd.param_name
    sys_corr_cnt = sys_corr_cnt
   HEAD ascd.param_sequence
    IF (resource_viewable_ind=true)
     sys_corr_detail_cnt = 0, sys_corr_param_cnt += 1
     IF (mod(sys_corr_param_cnt,10)=1)
      stat = alterlist(sys_corr->param_qual,(sys_corr_param_cnt+ 9))
     ENDIF
     sys_corr->param_qual[sys_corr_param_cnt].lookback_ind = ascd.lookback_ind, sys_corr->param_qual[
     sys_corr_param_cnt].param_name = ascd.param_name, sys_corr->param_qual[sys_corr_param_cnt].
     param_sequence = ascd.param_sequence
    ENDIF
   DETAIL
    IF (resource_viewable_ind=true)
     sys_corr_detail_cnt += 1
     IF (mod(sys_corr_detail_cnt,10)=1)
      stat = alterlist(sys_corr->param_qual[sys_corr_param_cnt].detail_qual,(sys_corr_detail_cnt+ 9))
     ENDIF
     sys_corr->param_qual[sys_corr_param_cnt].detail_qual[sys_corr_detail_cnt].parent_entity_name =
     ascd.parent_entity_name, sys_corr->param_qual[sys_corr_param_cnt].detail_qual[
     sys_corr_detail_cnt].parent_entity_id = ascd.parent_entity_id
    ENDIF
   FOOT  ascd.param_sequence
    IF (resource_viewable_ind=true)
     stat = alterlist(sys_corr->param_qual[sys_corr_param_cnt].detail_qual,sys_corr_detail_cnt)
    ENDIF
   FOOT  ascd.param_name
    row + 0
   FOOT  ascd.lookback_ind
    row + 0
   FOOT  apsc.sys_corr_id
    IF (resource_viewable_ind=true)
     stat = alterlist(sys_corr->param_qual,sys_corr_param_cnt)
    ENDIF
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 IF (use_request_reply_ind=1)
  SET stat = alterlist(reply->sys_corr_qual,sys_corr_cnt)
 ELSE
  SET stat = alterlist(reply200393->sys_corr_qual,sys_corr_cnt)
 ENDIF
 IF (curqual=0)
  SET reply_status->status = "Z"
  SET reply_status->subeventstatus[1].operationname = "SELECT"
  SET reply_status->subeventstatus[1].operationstatus = "Z"
  SET reply_status->subeventstatus[1].targetobjectname = "TABLE"
  SET reply_status->subeventstatus[1].targetobjectvalue = "AP_SYS_CORR"
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(0)
 ELSE
  SET reply_status->status = "S"
 ENDIF
 SET curalias sys_corr off
 SET curalias reply_status off
#exit_script
END GO
