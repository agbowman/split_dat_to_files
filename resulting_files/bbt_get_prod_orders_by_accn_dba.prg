CREATE PROGRAM bbt_get_prod_orders_by_accn:dba
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
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   DECLARE code_set = i4
   DECLARE cdf_meaning = c12
   DECLARE code_cnt = i4
   DECLARE code_value = f8
   SET code_set = sub_code_set
   SET cdf_meaning = sub_cdf_meaning
   SET code_cnt = 1
   SET sub_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,code_value)
   IF (stat=0)
    IF (code_cnt != 1)
     SET code_value = 0
    ENDIF
   ELSE
    SET code_value = 0
   ENDIF
   RETURN(code_value)
 END ;Subroutine
 RECORD reply(
   1 accession_id = f8
   1 accession_formatted = c20
   1 person_id = f8
   1 person_name_full_formatted = vc
   1 order_list[*]
     2 order_id = f8
     2 encntr_id = f8
     2 order_mnemonic = vc
     2 order_dt_tm = dq8
     2 order_tz = i4
     2 provider_id = f8
     2 provider_name = vc
     2 product_list[*]
       3 product_cd = f8
       3 product_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE activity_type_codeset = i4 WITH constant(106)
 DECLARE bb_orderable_proc_cs = i4 WITH constant(1635)
 DECLARE order_status_codeset = i4 WITH constant(6004)
 DECLARE activity_type_bb_cdf = vc WITH constant("BB")
 DECLARE order_status_ordered_cdf = vc WITH constant("ORDERED")
 DECLARE order_status_inprocess_cdf = vc WITH constant("INPROCESS")
 DECLARE order_status_completed_cdf = vc WITH constant("COMPLETED")
 DECLARE prod_req_order_mean = vc WITH constant("PRODUCT ORDR")
 DECLARE order_status_ordered_cd = f8 WITH noconstant(0.0)
 DECLARE order_status_inprocess_cd = f8 WITH noconstant(0.0)
 DECLARE order_status_completed_cd = f8 WITH noconstant(0.0)
 DECLARE bb_activity_cd = f8 WITH noconstant(0.0)
 DECLARE prod_req_order_cd = f8 WITH noconstant(0.0)
 DECLARE order_found = i2 WITH noconstant(false)
 DECLARE service_resource_cd = f8 WITH noconstant(0.0)
 DECLARE prodcnt = i4 WITH noconstant(0)
 DECLARE iserviceresaccess = i2 WITH noconstant(- (1))
 DECLARE lsize = i4 WITH noconstant(0)
 DECLARE serrormsg = c255
 SET nerrorstatus = error(serrormsg,1)
 DECLARE count1 = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 CALL initresourcesecurity(true)
 SET serrormsg = ""
 SET nerrorstatus = error(serrormsg,1)
 IF (getprocessingcodevalues(0)=0)
  GO TO exit_script
 ENDIF
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus > 0)
  CALL addreplystatusevent("F","Get processing Code Values","F","_cd fields",
   "CCL Error retrieving processing code values")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  formatted_accn = cnvtacc(aor.accession)
  FROM accession_order_r aor,
   orders o,
   service_directory sd,
   order_serv_res_container osrc,
   prsnl pnl,
   person p
  PLAN (aor
   WHERE (aor.accession=request->accession_nbr)
    AND aor.primary_flag=0)
   JOIN (o
   WHERE o.order_id=aor.order_id
    AND o.order_id > 0
    AND o.order_status_cd IN (order_status_ordered_cd, order_status_inprocess_cd,
   order_status_completed_cd)
    AND o.activity_type_cd=bb_activity_cd)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (osrc
   WHERE osrc.order_id=o.order_id)
   JOIN (sd
   WHERE sd.catalog_cd=o.catalog_cd
    AND sd.bb_processing_cd=prod_req_order_cd)
   JOIN (pnl
   WHERE pnl.person_id=o.last_update_provider_id)
  ORDER BY o.order_id, osrc.service_resource_cd
  HEAD REPORT
   reply->person_id = o.person_id, reply->person_name_full_formatted = p.name_full_formatted, reply->
   accession_id = aor.accession_id,
   reply->accession_formatted = substring(1,20,formatted_accn), lsize = 0
  HEAD o.order_id
   iserviceresaccess = 0, order_found = true
  HEAD osrc.service_resource_cd
   IF (iserviceresaccess=0)
    IF (isresourceviewable(osrc.service_resource_cd)=true)
     iserviceresaccess = 1, lsize += 1, stat = alterlist(reply->order_list,lsize),
     reply->order_list[lsize].order_id = o.order_id, reply->order_list[lsize].encntr_id = o.encntr_id,
     reply->order_list[lsize].order_mnemonic = o.order_mnemonic,
     reply->order_list[lsize].order_dt_tm = o.current_start_dt_tm, reply->order_list[lsize].order_tz
      = o.current_start_tz, reply->order_list[lsize].provider_id = pnl.person_id,
     reply->order_list[lsize].provider_name = pnl.name_full_formatted
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus > 0)
  CALL addreplystatusevent("F","Select Orders","F","reply->order_list",
   "CCL Error retrieving product orders associated with reqeust Accession #")
  GO TO exit_script
 ENDIF
 IF (getresourcesecuritystatus(0)="F")
  CALL populateressecstatusblock(0)
  GO TO exit_script
 ENDIF
 IF (lsize > 0)
  SET serrormsg = ""
  SET nerrorstatus = error(serrormsg,1)
  SELECT INTO "nl:"
   FROM (dummyt do  WITH seq = value(lsize)),
    orders o,
    prod_ord_prod_idx_r po
   PLAN (do)
    JOIN (o
    WHERE (reply->order_list[do.seq].order_id=o.order_id))
    JOIN (po
    WHERE po.catalog_cd=o.catalog_cd
     AND po.active_ind=1)
   ORDER BY o.order_id
   HEAD o.order_id
    prodcnt = 0
   DETAIL
    prodcnt += 1
    IF (prodcnt > size(reply->order_list[do.seq].product_list,5))
     lstatus = alterlist(reply->order_list[do.seq].product_list,(prodcnt+ 9))
    ENDIF
    reply->order_list[do.seq].product_list[prodcnt].product_cd = po.product_cd, reply->order_list[do
    .seq].product_list[prodcnt].product_disp = uar_get_code_display(po.product_cd)
   FOOT  o.order_id
    stat = alterlist(reply->order_list[do.seq].product_list,prodcnt)
   WITH nocounter
  ;end select
  SET nerrorstatus = error(serrormsg,0)
  IF (nerrorstatus > 0)
   CALL addreplystatusevent("F","Select prod_ord_prod_idx_r","F","reply->order_list->product_list",
    "CCL Error retrieving product types associated with product order(s)")
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
 ELSE
  SET reply->accession_formatted = cnvtacc(request->accession_nbr)
  IF (order_found=true)
   SET operation_name = "RESOURCE SECURITY FAILED"
  ELSE
   SET operation_name = "No orders found."
  ENDIF
  CALL addreplystatusevent("Z",operation_name,"Z","ORDERS","No orders returned.")
 ENDIF
#exit_script
 SUBROUTINE (getprocessingcodevalues(sub_dummy=i2) =i2)
   SET bb_activity_cd = get_code_value(activity_type_codeset,activity_type_bb_cdf)
   IF (bb_activity_cd < 1)
    CALL addreplystatusevent("F","uar_get_meaning_by_codeset","F","bb_activity_cd",
     "Unable to retrieve Blood Bank (BB) Activity Type code value")
    RETURN(0)
   ENDIF
   SET prod_req_order_cd = get_code_value(bb_orderable_proc_cs,prod_req_order_mean)
   IF (prod_req_order_cd < 1)
    CALL addreplystatusevent("F","uar_get_meaning_by_codeset","F","prod_req_order_cd",
     "Unable to retrieve Product order procedure type code value")
    RETURN(0)
   ENDIF
   SET order_status_ordered_cd = get_code_value(order_status_codeset,order_status_ordered_cdf)
   IF (order_status_ordered_cd < 1)
    CALL addreplystatusevent("F","uar_get_meaning_by_codeset","F","order_status_ordered_cd",
     "Unable to retrieve Ordered Order Status code value")
    RETURN(0)
   ENDIF
   SET order_status_inprocess_cd = get_code_value(order_status_codeset,order_status_inprocess_cdf)
   IF (order_status_inprocess_cd < 1)
    CALL addreplystatusevent("F","uar_get_meaning_by_codeset","F","order_status_inprocess_cd",
     "Unable to retrieve InProcess Order Status code value")
    RETURN(0)
   ENDIF
   SET order_status_completed_cd = get_code_value(order_status_codeset,order_status_completed_cdf)
   IF (order_status_completed_cd < 1)
    CALL addreplystatusevent("F","uar_get_meaning_by_codeset","F","order_status_completed_cd",
     "Unable to retrieve Completed Order Status code value")
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (addreplystatusevent(sub_scriptstatus=vc,sub_operationname=vc,sub_operationstatus=vc,
  sub_targetobjectname=vc,sub_targetobjectvalue=vc) =i2)
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.status = sub_scriptstatus
   SET reply->status_data.subeventstatus[count1].operationname = sub_operationname
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_operationstatus
   SET reply->status_data.subeventstatus[count1].targetobjectname = sub_targetobjectname
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_targetobjectvalue
   RETURN
 END ;Subroutine
END GO
