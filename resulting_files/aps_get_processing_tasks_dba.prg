CREATE PROGRAM aps_get_processing_tasks:dba
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
     2 catalog_cd = f8
     2 mnemonic = vc
     2 description = vc
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 task_assay_desc = c60
     2 slide_origin_flag = i2
     2 create_inventory_flag = i2
     2 task_type_flag = i2
     2 stain_ind = i2
     2 date_of_service_cd = f8
     2 date_of_service_disp = vc
     2 updt_cnt = i4
     2 resource_route_lvl = i4
     2 resource_qual[*]
       3 service_resource_cd = f8
       3 service_resource_disp = vc
       3 service_resource_desc = vc
       3 access_to_resource_ind = i2
     2 print_label_ind = i2
     2 resource_ctr = i4
     2 prefix_assoc_qual[*]
       3 prefix_id = f8
       3 access_to_prefix_ind = i2
     2 prefix_assoc_ctr = i4
     2 access_to_task_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE batch_size = i4 WITH noconstant(20)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE lvindex = i4 WITH noconstant(0)
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE padded_size = i4 WITH noconstant(0)
 DECLARE access_to_rsrc_ind = i2 WITH noconstant(0)
 DECLARE access_to_task_ind = i2 WITH noconstant(0)
 DECLARE ap_billing_type_cd = f8 WITH noconstant(0.0)
 DECLARE ap_process_type_cd = f8 WITH noconstant(0.0)
 DECLARE task_type_indicator = i2 WITH noconstant(0)
 DECLARE var1 = f8 WITH noconstant(0.0)
 DECLARE var2 = f8 WITH noconstant(0.0)
 SET stat = alterlist(reply->qual,10)
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET lab_catalog_type_cd = 0.0
 SET ap_activity_type_cd = 0.0
 CALL initresourcesecurity(1)
 SET stat = uar_get_meaning_by_codeset(6000,"GENERAL LAB",1,lab_catalog_type_cd)
 SET stat = uar_get_meaning_by_codeset(106,"AP",1,ap_activity_type_cd)
 SET stat = uar_get_meaning_by_codeset(5801,"APPROCESS",1,ap_process_type_cd)
 SET stat = uar_get_meaning_by_codeset(5801,"APBILLING",1,ap_billing_type_cd)
 IF (((lab_catalog_type_cd <= 0) OR (ap_activity_type_cd <= 0)) )
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  IF (lab_catalog_type_cd <= 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - GENERAL LAB"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - AP"
  ENDIF
  GO TO exit_script
 ENDIF
 SET task_type_indicator = validate(request->task_type_ind,- (1))
 IF (task_type_indicator=1)
  SET var1 = 0
  SET var2 = ap_billing_type_cd
 ELSEIF (task_type_indicator=2)
  SET var1 = ap_process_type_cd
  SET var2 = ap_billing_type_cd
 ELSE
  SET var1 = ap_process_type_cd
  SET var2 = 0
 ENDIF
 SUBROUTINE (determineexpandtotal(lactualsize=i4,lexpandsize=i4) =i4 WITH protect, noconstant(0))
   RETURN((ceil((cnvtreal(lactualsize)/ lexpandsize)) * lexpandsize))
 END ;Subroutine
 SUBROUTINE (determineexpandsize(lrecordsize=i4,lmaximumsize=i4) =i4 WITH protect, noconstant(0))
   DECLARE lreturn = i4 WITH protect, noconstant(0)
   IF (lrecordsize <= 1)
    SET lreturn = 1
   ELSEIF (lrecordsize <= 10)
    SET lreturn = 10
   ELSEIF (lrecordsize <= 500)
    SET lreturn = 50
   ELSE
    SET lreturn = 100
   ENDIF
   IF (lmaximumsize < lreturn)
    SET lreturn = lmaximumsize
   ENDIF
   RETURN(lreturn)
 END ;Subroutine
 SELECT INTO "nl:"
  oc.catalog_cd, ptr.catalog_cd, ataa.task_assay_cd
  FROM order_catalog oc,
   profile_task_r ptr,
   ap_task_assay_addl ataa
  PLAN (oc
   WHERE oc.catalog_type_cd=lab_catalog_type_cd
    AND oc.activity_type_cd=ap_activity_type_cd
    AND oc.activity_subtype_cd IN (var1, var2)
    AND oc.activity_subtype_cd != 0.0
    AND oc.active_ind=1)
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd
    AND ptr.active_ind=1
    AND ptr.item_type_flag=0
    AND ptr.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ptr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ataa
   WHERE ataa.task_assay_cd=ptr.task_assay_cd)
  ORDER BY oc.catalog_cd
  HEAD REPORT
   cnt = 0
  HEAD oc.catalog_cd
   cnt += 1
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].catalog_cd = oc.catalog_cd, reply->qual[cnt].mnemonic = trim(oc.primary_mnemonic),
   reply->qual[cnt].description = trim(oc.description),
   reply->qual[cnt].task_assay_cd = ataa.task_assay_cd, reply->qual[cnt].slide_origin_flag = ataa
   .slide_origin_flag, reply->qual[cnt].create_inventory_flag = ataa.create_inventory_flag,
   reply->qual[cnt].task_type_flag = ataa.task_type_flag, reply->qual[cnt].stain_ind = ataa.stain_ind,
   reply->qual[cnt].date_of_service_cd = ataa.date_of_service_cd,
   reply->qual[cnt].updt_cnt = ataa.updt_cnt, reply->qual[cnt].resource_route_lvl = oc
   .resource_route_lvl, reply->qual[cnt].print_label_ind = ataa.print_label_ind,
   reply->qual[cnt].resource_ctr = 0
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SET m_nressecind = true
  SELECT INTO "nl:"
   FROM ap_prefix_task_r aptr,
    ap_prefix ap
   PLAN (aptr
    WHERE expand(idx,1,cnt,aptr.catalog_cd,reply->qual[idx].catalog_cd))
    JOIN (ap
    WHERE ap.prefix_id=aptr.prefix_id)
   ORDER BY aptr.catalog_cd
   HEAD aptr.catalog_cd
    access_to_task_ind = 0, lvindex = 0, lvindex = locateval(idx,1,cnt,aptr.catalog_cd,reply->qual[
     idx].catalog_cd)
   DETAIL
    IF (lvindex > 0)
     reply->qual[lvindex].prefix_assoc_ctr += 1
     IF ((reply->qual[lvindex].prefix_assoc_ctr > size(reply->qual[lvindex].prefix_assoc_qual,5)))
      stat = alterlist(reply->qual[lvindex].prefix_assoc_qual,(reply->qual[lvindex].prefix_assoc_ctr
       + 9))
     ENDIF
     reply->qual[lvindex].prefix_assoc_qual[reply->qual[lvindex].prefix_assoc_ctr].prefix_id = aptr
     .prefix_id
     IF (isresourceviewable(ap.service_resource_cd)=true)
      access_to_task_ind = 1, reply->qual[lvindex].prefix_assoc_qual[reply->qual[lvindex].
      prefix_assoc_ctr].access_to_prefix_ind = 1
     ELSE
      reply->qual[lvindex].prefix_assoc_qual[reply->qual[lvindex].prefix_assoc_ctr].
      access_to_prefix_ind = 0
     ENDIF
    ENDIF
   FOOT  aptr.catalog_cd
    IF (lvindex > 0)
     reply->qual[lvindex].access_to_task_ind = access_to_task_ind, stat = alterlist(reply->qual[
      lvindex].prefix_assoc_qual,reply->qual[lvindex].prefix_assoc_ctr)
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  IF (istaskgranted(200436)=true)
   SET m_nressecind = false
  ELSE
   SET m_nressecind = true
  ENDIF
  SELECT INTO "nl:"
   orl.catalog_cd, orl.service_resource_cd
   FROM orc_resource_list orl
   PLAN (orl
    WHERE expand(idx,1,cnt,orl.catalog_cd,reply->qual[idx].catalog_cd,
     1,reply->qual[idx].resource_route_lvl))
   DETAIL
    lvindex = locateval(idx,1,cnt,orl.catalog_cd,reply->qual[idx].catalog_cd,
     1,reply->qual[idx].resource_route_lvl)
    IF (lvindex > 0)
     reply->qual[lvindex].resource_ctr += 1
     IF ((reply->qual[lvindex].resource_ctr > size(reply->qual[lvindex].resource_qual,5)))
      stat = alterlist(reply->qual[lvindex].resource_qual,(reply->qual[lvindex].resource_ctr+ 4))
     ENDIF
     reply->qual[lvindex].resource_qual[reply->qual[lvindex].resource_ctr].service_resource_cd = orl
     .service_resource_cd
     IF (isresourceviewable(orl.service_resource_cd)=true)
      reply->qual[lvindex].resource_qual[reply->qual[lvindex].resource_ctr].access_to_resource_ind =
      1
     ELSE
      reply->qual[lvindex].resource_qual[reply->qual[lvindex].resource_ctr].access_to_resource_ind =
      0
     ENDIF
    ENDIF
   WITH nocounter, expand = 1, orahintcbo("INDEX(ORL XIF560ORC_RESOURCE_LIST)")
  ;end select
  SET stat = alterlist(reply->qual,cnt)
  FOR (idx = 1 TO cnt)
   SET stat = alterlist(reply->qual[idx].resource_qual,reply->qual[idx].resource_ctr)
   IF ((reply->qual[idx].prefix_assoc_ctr=0))
    SET reply->qual[idx].access_to_task_ind = 1
   ENDIF
  ENDFOR
 ENDIF
 IF (validate(request->only_with_srvc_rsrc_ind,0)=1)
  FOR (idx = cnt TO 1 BY - (1))
    IF ((reply->qual[idx].resource_ctr=0))
     SET stat = alterlist(reply->qual,(size(reply->qual,5) - 1),(idx - 1))
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
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TASK_ASSAY_ADDL"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF (validate(temp_rsrc_security))
  FREE SET temp_rsrc_security
 ENDIF
END GO
