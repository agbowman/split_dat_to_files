CREATE PROGRAM aps_get_processing_group:dba
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
   1 qual[10]
     2 parent_entity_id = f8
     2 active_ind = i2
     2 code_value_updt_cnt = i4
     2 task_qual[*]
       3 task_assay_cd = f8
       3 begin_section = i4
       3 begin_level = i4
       3 no_charge_ind = i2
       3 sequence = i4
       3 updt_cnt = i4
     2 prefix_assoc_qual[*]
       3 prefix_id = f8
       3 access_to_prefix_ind = i2
     2 prefix_assoc_ctr = i4
     2 access_to_grp_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE idx = i4 WITH noconstant(0)
 CALL initresourcesecurity(1)
 SET reply->status_data.status = "F"
 SET dynamic_where = fillstring(50," ")
 SET max_cnt = 0
 SET max_task_cnt = 0
 SET task_cnt = 0
 SET cnt = 0
 IF ((request->parent_entity_id > 0))
  SET dynamic_where = build("cv.code_value = ",request->parent_entity_id)
 ELSE
  SET dynamic_where = "cv.code_set = 1310 and cv.active_ind = 1"
 ENDIF
 SELECT INTO "nl:"
  cv.code_value, agi.parent_entity_id
  FROM code_value cv,
   ap_processing_grp_r agi
  PLAN (cv
   WHERE parser(dynamic_where))
   JOIN (agi
   WHERE agi.parent_entity_id=cv.code_value
    AND agi.parent_entity_name="CODE_VALUE")
  ORDER BY cv.code_value
  HEAD REPORT
   max_cnt = 10, cnt = 0
  HEAD cv.code_value
   cnt += 1, max_task_cnt = 10, task_cnt = 0
   IF (cnt > max_cnt)
    stat = alter(reply->qual,(cnt+ 10)), max_cnt = (cnt+ 10)
   ENDIF
   stat = alterlist(reply->qual[cnt].task_qual,(task_cnt+ 10))
  DETAIL
   task_cnt += 1
   IF (task_cnt > max_task_cnt)
    stat = alterlist(reply->qual[cnt].task_qual,(task_cnt+ 10)), max_task_cnt = (task_cnt+ 10)
   ENDIF
   reply->qual[cnt].parent_entity_id = cv.code_value, reply->qual[cnt].active_ind = cv.active_ind,
   reply->qual[cnt].code_value_updt_cnt = cv.updt_cnt,
   reply->qual[cnt].task_qual[task_cnt].task_assay_cd = agi.task_assay_cd, reply->qual[cnt].
   task_qual[task_cnt].begin_section = agi.begin_section, reply->qual[cnt].task_qual[task_cnt].
   begin_level = agi.begin_level,
   reply->qual[cnt].task_qual[task_cnt].no_charge_ind = agi.no_charge_ind, reply->qual[cnt].
   task_qual[task_cnt].sequence = agi.sequence, reply->qual[cnt].task_qual[task_cnt].updt_cnt = agi
   .updt_cnt
  FOOT  cv.code_value
   stat = alterlist(reply->qual[cnt].task_qual,task_cnt)
  FOOT REPORT
   stat = alter(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM ap_prefix_proc_grp_r apgr,
    ap_prefix ap
   PLAN (apgr
    WHERE expand(idx,1,cnt,apgr.processing_grp_cd,reply->qual[idx].parent_entity_id))
    JOIN (ap
    WHERE ap.prefix_id=apgr.prefix_id)
   ORDER BY apgr.processing_grp_cd
   HEAD apgr.processing_grp_cd
    access_to_grp_ind = 0, lvindex = 0, lvindex = locateval(idx,1,cnt,apgr.processing_grp_cd,reply->
     qual[idx].parent_entity_id)
   DETAIL
    IF (lvindex > 0)
     reply->qual[lvindex].prefix_assoc_ctr += 1
     IF ((reply->qual[lvindex].prefix_assoc_ctr > size(reply->qual[lvindex].prefix_assoc_qual,5)))
      stat = alterlist(reply->qual[lvindex].prefix_assoc_qual,(reply->qual[lvindex].prefix_assoc_ctr
       + 9))
     ENDIF
     reply->qual[lvindex].prefix_assoc_qual[reply->qual[lvindex].prefix_assoc_ctr].prefix_id = apgr
     .prefix_id
     IF (isresourceviewable(ap.service_resource_cd)=true)
      access_to_grp_ind = 1, reply->qual[lvindex].prefix_assoc_qual[reply->qual[lvindex].
      prefix_assoc_ctr].access_to_prefix_ind = 1
     ELSE
      reply->qual[lvindex].prefix_assoc_qual[reply->qual[lvindex].prefix_assoc_ctr].
      access_to_prefix_ind = 0
     ENDIF
    ENDIF
   FOOT  apgr.processing_grp_cd
    IF (lvindex > 0)
     reply->qual[lvindex].access_to_grp_ind = access_to_grp_ind, stat = alterlist(reply->qual[lvindex
      ].prefix_assoc_qual,reply->qual[lvindex].prefix_assoc_ctr)
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (idx = 1 TO cnt)
    IF ((reply->qual[idx].prefix_assoc_ctr=0))
     SET reply->qual[idx].access_to_grp_ind = 1
    ENDIF
  ENDFOR
 ENDIF
 IF (getresourcesecuritystatus(0)="F")
  SET reply->status_data.status = "F"
  CALL populateressecstatusblock(0)
 ELSEIF (cnt=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PROCESSING_GRP_R"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
