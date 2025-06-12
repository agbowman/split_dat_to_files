CREATE PROGRAM aps_get_dc_studies:dba
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
 RECORD reply(
   1 qual[*]
     2 study_id = f8
     2 description = vc
     2 across_case_ind = i2
     2 active_ind = i2
     2 slide_counts_prompt_ind = i2
     2 include_cytotechs_ind = i2
     2 default_to_group_ind = i2
     2 updt_cnt = i4
   1 adetqual[*]
     2 evaluation_term_id = f8
     2 display = c15
     2 description = vc
     2 agreement_cd = f8
     2 discrepancy_req_ind = i2
     2 reason_req_ind = i2
     2 investigation_req_ind = i2
     2 resolution_req_ind = i2
     2 active_ind = i2
   1 addtqual[*]
     2 discrepancy_term_id = f8
     2 display = c15
     2 description = vc
     2 discrepancy_cd = f8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL initresourcesecurity(1)
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET ads_inactives_where = fillstring(30," ")
 SET adet_inactives_where = fillstring(30," ")
 SET addt_inactives_where = fillstring(30," ")
 IF ((request->bshowinactives=0))
  SET ads_inactives_where = "ads.active_ind = 1"
  SET adet_inactives_where = "adet.active_ind = 1"
  SET addt_inactives_where = "addt.active_ind = 1"
 ELSE
  SET ads_inactives_where = "ads.active_ind in (1,0)"
  SET adet_inactives_where = "adet.active_ind in (1,0)"
  SET addt_inactives_where = "addt.active_ind in (1,0)"
 ENDIF
 SELECT INTO "nl:"
  ads.study_id
  FROM ap_dc_study ads
  PLAN (ads
   WHERE parser(
    IF ((request->study_id > 0)) "request->study_id = ads.study_id"
    ELSE "0 < ads.study_id"
    ENDIF
    )
    AND parser(ads_inactives_where))
  HEAD REPORT
   scnt = 0, stat = alterlist(reply->qual,10)
  DETAIL
   service_resource_cd = ads.service_resource_cd
   IF (isresourceviewable(service_resource_cd)=true)
    scnt += 1
    IF (mod(scnt,10)=1
     AND scnt != 1)
     stat = alterlist(reply->qual,(scnt+ 9))
    ENDIF
    reply->qual[scnt].study_id = ads.study_id, reply->qual[scnt].description = ads.description, reply
    ->qual[scnt].across_case_ind = ads.across_case_ind,
    reply->qual[scnt].active_ind = ads.active_ind, reply->qual[scnt].slide_counts_prompt_ind = ads
    .slide_counts_prompt_ind, reply->qual[scnt].include_cytotechs_ind = ads.include_cytotechs_ind,
    reply->qual[scnt].default_to_group_ind = ads.default_to_group_ind, reply->qual[scnt].updt_cnt =
    ads.updt_cnt
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,scnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_cnt += 1
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[error_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[error_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[error_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = "AP_DC_STUDY"
  GO TO exit_script
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET error_cnt += 1
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  adet.evaluation_term_id, adet.display, adet.description,
  adet.agreement_cd, adet.discrepancy_req_ind, adet.reason_req_ind,
  adet.investigation_req_ind, adet.resolution_req_ind, adet.active_ind
  FROM ap_dc_evaluation_term adet
  PLAN (adet
   WHERE parser(adet_inactives_where))
  HEAD REPORT
   adetcnt = 0, stat = alterlist(reply->adetqual,10)
  DETAIL
   adetcnt += 1
   IF (mod(adetcnt,10)=1
    AND adetcnt != 1)
    stat = alterlist(reply->adetqual,(adetcnt+ 9))
   ENDIF
   reply->adetqual[adetcnt].evaluation_term_id = adet.evaluation_term_id, reply->adetqual[adetcnt].
   display = adet.display, reply->adetqual[adetcnt].description = adet.description,
   reply->adetqual[adetcnt].agreement_cd = adet.agreement_cd, reply->adetqual[adetcnt].
   discrepancy_req_ind = adet.discrepancy_req_ind, reply->adetqual[adetcnt].reason_req_ind = adet
   .reason_req_ind,
   reply->adetqual[adetcnt].investigation_req_ind = adet.investigation_req_ind, reply->adetqual[
   adetcnt].resolution_req_ind = adet.resolution_req_ind, reply->adetqual[adetcnt].active_ind = adet
   .active_ind
  FOOT REPORT
   stat = alterlist(reply->adetqual,adetcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_cnt += 1
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[error_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[error_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[error_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = "AP_DC_EVALUATION_TERM"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  addt.discrepancy_term_id, addt.display, addt.description,
  addt.discrepancy_cd, addt.active_ind
  FROM ap_dc_discrepancy_term addt
  PLAN (addt
   WHERE parser(addt_inactives_where))
  HEAD REPORT
   addtcnt = 0, stat = alterlist(reply->addtqual,10)
  DETAIL
   addtcnt += 1
   IF (mod(addtcnt,10)=1
    AND addtcnt != 1)
    stat = alterlist(reply->addtqual,(addtcnt+ 9))
   ENDIF
   reply->addtqual[addtcnt].discrepancy_term_id = addt.discrepancy_term_id, reply->addtqual[addtcnt].
   display = addt.display, reply->addtqual[addtcnt].description = addt.description,
   reply->addtqual[addtcnt].discrepancy_cd = addt.discrepancy_cd, reply->addtqual[addtcnt].active_ind
    = addt.active_ind
  FOOT REPORT
   stat = alterlist(reply->addtqual,addtcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_cnt += 1
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[error_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[error_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[error_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = "AP_DC_DISCREPANCY_TERM"
  GO TO exit_script
 ENDIF
 GO TO exit_script
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  CALL echo("<<<<< ROLLBACK <<<<<")
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(">>>>> COMMIT >>>>>")
 ENDIF
END GO
