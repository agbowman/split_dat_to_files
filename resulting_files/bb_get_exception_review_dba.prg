CREATE PROGRAM bb_get_exception_review:dba
 RECORD reply(
   1 qual[*]
     2 accession = vc
     2 order_id = f8
     2 order_mnemonic = vc
     2 order_dt_tm = dq8
     2 person_id = f8
     2 patient_name = vc
     2 mrn_alias = vc
     2 encntr_id = f8
     2 order_provider_id = f8
     2 order_provider_name = vc
     2 catalog_cd = f8
     2 catalog_disp = vc
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 task_assay_cd = f8
     2 task_assay_mnemonic = vc
     2 event_cd = f8
     2 bb_processing_cd = f8
     2 bb_processing_disp = vc
     2 bb_processing_mean = c12
     2 bb_result_processing_cd = f8
     2 bb_result_processing_disp = vc
     2 bb_result_processing_mean = c12
     2 surgical_procedure_cd = f8
     2 surgical_procedure_disp = vc
     2 nbr_units_requested = f8
     2 order_comment_ind = i2
     2 result_id = f8
     2 perform_result_id = f8
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 container_id = f8
     2 result_status_cd = f8
     2 result_status_disp = vc
     2 result_status_mean = c12
     2 result_type_cd = f8
     2 result_type_disp = vc
     2 result_type_mean = c12
     2 result_value_numeric = f8
     2 numeric_raw_value = f8
     2 normal_cd = f8
     2 result_updt_cnt = i4
     2 perform_result_updt_cnt = i4
     2 exception_id = f8
     2 default_expire_dt_tm = dq8
     2 event_type_cd = f8
     2 exception_dt_tm = dq8
     2 exception_prsnl_id = f8
     2 exception_type_cd = f8
     2 exception_updt_cnt = i4
     2 status_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 CALL initresourcesecurity(1)
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE sscript_name = c23 WITH protect, constant("bb_get_exception_review")
 DECLARE sdta_entity_name = c19 WITH protect, constant("DISCRETE_TASK_ASSAY")
 DECLARE lbb_surg_proc_msbos_cs = i4 WITH protect, constant(4554)
 DECLARE lbb_exception_type_cs = i4 WITH protect, constant(14072)
 DECLARE sbb_exception_msbos_cdf = c12 WITH protect, constant("MSBOS")
 DECLARE lorder_status_cs = i4 WITH protect, constant(6004)
 DECLARE sorder_status_ordered_cdf = c12 WITH protect, constant("ORDERED")
 DECLARE sorder_status_inprocess_cdf = c12 WITH protect, constant("INPROCESS")
 DECLARE sorder_status_canceled_cdf = c12 WITH protect, constant("CANCELED")
 DECLARE sorder_status_deleted_cdf = c12 WITH protect, constant("DELETED")
 DECLARE sorder_status_discontinued_cdf = c12 WITH protect, constant("DISCONTINUED")
 DECLARE ldept_status_cs = i4 WITH protect, constant(14281)
 DECLARE sdept_status_labinlab_cdf = c12 WITH protect, constant("LABINLAB")
 DECLARE sdept_status_labinprocess_cdf = c12 WITH protect, constant("LABINPROCESS")
 DECLARE doe_promt_field_meaning_id = f8 WITH protect, constant(9001.0)
 DECLARE doe_surg_proc_field_meaning_id = f8 WITH protect, constant(7000.0)
 DECLARE lbb_processing_cs = i4 WITH protect, constant(1636)
 DECLARE sbb_nbr_units_cdf = c12 WITH protect, constant("NBR UNITS")
 DECLARE lencounter_alias_type_cs = i4 WITH protect, constant(319)
 DECLARE sencounter_mrn_cdf = c12 WITH protect, constant("MRN")
 DECLARE nrop_prompt_interface_flag = i4 WITH protect, constant(4)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE dbb_exception_msbos_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dbb_nbr_units_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dencounter_mrn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dorder_status_ordered_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dorder_status_inprocess_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dorder_status_canceled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dorder_status_deleted_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dorder_status_discontinued_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ddept_status_labinlab_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ddept_status_labinprocess_cd = f8 WITH protect, noconstant(0.0)
 DECLARE lordercnt = i4 WITH protect, noconstant(0)
 DECLARE srs_granted = i2 WITH protect, noconstant(false)
 DECLARE dservice_resource_cd = f8 WITH protect, noconstant(0.0)
 IF (get_uar_variables(0)=0)
  GO TO exit_script
 ENDIF
 IF (load_review_results(0)=0)
  GO TO exit_script
 ENDIF
 GO TO set_status
 SUBROUTINE (get_uar_variables(none=i2) =i2)
   DECLARE uar_error_string = vc WITH protect, nocontant
   SET dbb_exception_msbos_cd = uar_get_code_by("MEANING",lbb_exception_type_cs,nullterm(
     sbb_exception_msbos_cdf))
   IF (dbb_exception_msbos_cd <= 0.0)
    SET uar_error_string = concat("Failed to retrieve cdf meaning of ",trim(sbb_exception_msbos_cdf),
     " from code set ",cnvtstring(lbb_exception_type_cs),".")
    CALL errorhandler("F","uar_get_code_by",uar_error_string)
    RETURN(0)
   ENDIF
   SET dbb_nbr_units_cd = uar_get_code_by("MEANING",lbb_processing_cs,nullterm(sbb_nbr_units_cdf))
   IF (dbb_nbr_units_cd <= 0.0)
    SET uar_error_string = concat("Failed to retrieve cdf meaning of ",trim(sbb_nbr_units_cdf),
     " from code set ",cnvtstring(lbb_processing_cs),".")
    CALL errorhandler("F","uar_get_code_by",uar_error_string)
    RETURN(0)
   ENDIF
   SET dencounter_mrn_cd = uar_get_code_by("MEANING",lencounter_alias_type_cs,nullterm(
     sencounter_mrn_cdf))
   IF (dencounter_mrn_cd <= 0.0)
    SET uar_error_string = concat("Failed to retrieve cdf meaning of ",trim(sencounter_mrn_cdf),
     " from code set ",cnvtstring(lencounter_alias_type_cs),".")
    CALL errorhandler("F","uar_get_code_by",uar_error_string)
    RETURN(0)
   ENDIF
   SET dorder_status_ordered_cd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(
     sorder_status_ordered_cdf))
   IF (dorder_status_ordered_cd <= 0.0)
    SET uar_error_string = concat("Failed to retrieve cdf meaning of ",trim(sorder_status_ordered_cdf
      )," from code set ",cnvtstring(lorder_status_cs),".")
    CALL errorhandler("F","uar_get_code_by",uar_error_string)
    RETURN(0)
   ENDIF
   SET dorder_status_inprocess_cd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(
     sorder_status_inprocess_cdf))
   IF (dorder_status_inprocess_cd <= 0.0)
    SET uar_error_string = concat("Failed to retrieve cdf meaning of ",trim(
      sorder_status_inprocess_cdf)," from code set ",cnvtstring(lorder_status_cs),".")
    CALL errorhandler("F","uar_get_code_by",uar_error_string)
    RETURN(0)
   ENDIF
   SET dorder_status_canceled_cd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(
     sorder_status_canceled_cdf))
   IF (dorder_status_canceled_cd <= 0.0)
    SET uar_error_string = concat("Failed to retrieve cdf meaning of ",trim(
      sorder_status_canceled_cdf)," from code set ",cnvtstring(lorder_status_cs),".")
    CALL errorhandler("F","uar_get_code_by",uar_error_string)
    RETURN(0)
   ENDIF
   SET dorder_status_deleted_cd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(
     sorder_status_deleted_cdf))
   IF (dorder_status_deleted_cd <= 0.0)
    SET uar_error_string = concat("Failed to retrieve cdf meaning of ",trim(sorder_status_deleted_cdf
      )," from code set ",cnvtstring(lorder_status_cs),".")
    CALL errorhandler("F","uar_get_code_by",uar_error_string)
    RETURN(0)
   ENDIF
   SET dorder_status_discontinued_cd = uar_get_code_by("MEANING",lorder_status_cs,nullterm(
     sorder_status_discontinued_cdf))
   IF (dorder_status_discontinued_cd <= 0.0)
    SET uar_error_string = concat("Failed to retrieve cdf meaning of ",trim(
      sorder_status_discontinued_cdf)," from code set ",cnvtstring(lorder_status_cs),".")
    CALL errorhandler("F","uar_get_code_by",uar_error_string)
    RETURN(0)
   ENDIF
   SET ddept_status_labinlab_cd = uar_get_code_by("MEANING",ldept_status_cs,nullterm(
     sdept_status_labinlab_cdf))
   IF (ddept_status_labinlab_cd <= 0.0)
    SET uar_error_string = concat("Failed to retrieve cdf meaning of ",trim(sdept_status_labinlab_cdf
      )," from code set ",cnvtstring(ldept_status_cs),".")
    CALL errorhandler("F","uar_get_code_by",uar_error_string)
    RETURN(0)
   ENDIF
   SET ddept_status_labinprocess_cd = uar_get_code_by("MEANING",ldept_status_cs,nullterm(
     sdept_status_labinprocess_cdf))
   IF (ddept_status_labinprocess_cd <= 0.0)
    SET uar_error_string = concat("Failed to retrieve cdf meaning of ",trim(
      sdept_status_labinprocess_cdf)," from code set ",cnvtstring(ldept_status_cs),".")
    CALL errorhandler("F","uar_get_code_by",uar_error_string)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (load_review_results(none=i2) =i2)
   SELECT INTO "nl:"
    FROM bb_exception be,
     orders o,
     accession_order_r aor,
     service_directory sd,
     order_serv_res_container osrc,
     order_action oa,
     prsnl pl,
     person p
    PLAN (be
     WHERE be.exception_type_cd=dbb_exception_msbos_cd
      AND be.override_reason_cd=0.0
      AND be.active_ind=1)
     JOIN (o
     WHERE o.order_id=be.order_id
      AND  NOT (o.order_status_cd IN (dorder_status_canceled_cd, dorder_status_deleted_cd,
     dorder_status_discontinued_cd)))
     JOIN (p
     WHERE p.person_id=o.person_id)
     JOIN (aor
     WHERE aor.order_id=o.order_id
      AND aor.primary_flag=0)
     JOIN (sd
     WHERE sd.catalog_cd=o.catalog_cd
      AND sd.active_ind=1)
     JOIN (osrc
     WHERE osrc.order_id=o.order_id)
     JOIN (oa
     WHERE oa.order_id=o.order_id)
     JOIN (pl
     WHERE pl.person_id=oa.order_provider_id)
    ORDER BY o.order_id, oa.action_sequence DESC
    HEAD o.order_id
     srs_granted = false, dservice_resource_cd = osrc.service_resource_cd, srs_granted =
     isresourceviewable(dservice_resource_cd)
     IF (srs_granted=true)
      lordercnt += 1
      IF (lordercnt > size(reply->qual,5))
       stat = alterlist(reply->qual,(lordercnt+ 9))
      ENDIF
      reply->qual[lordercnt].order_id = o.order_id, reply->qual[lordercnt].order_mnemonic = o
      .order_mnemonic, reply->qual[lordercnt].order_dt_tm = cnvtdatetime(o.orig_order_dt_tm),
      reply->qual[lordercnt].encntr_id = o.encntr_id, reply->qual[lordercnt].person_id = o.person_id,
      reply->qual[lordercnt].patient_name = p.name_full_formatted,
      reply->qual[lordercnt].catalog_cd = o.catalog_cd, reply->qual[lordercnt].catalog_type_cd = o
      .catalog_type_cd, reply->qual[lordercnt].accession = cnvtacc(aor.accession),
      reply->qual[lordercnt].order_provider_id = oa.order_provider_id, reply->qual[lordercnt].
      order_provider_name = pl.name_full_formatted, reply->qual[lordercnt].bb_processing_cd = sd
      .bb_processing_cd,
      reply->qual[lordercnt].exception_id = be.exception_id, reply->qual[lordercnt].
      default_expire_dt_tm = be.default_expire_dt_tm, reply->qual[lordercnt].event_type_cd = be
      .event_type_cd,
      reply->qual[lordercnt].exception_dt_tm = be.exception_dt_tm, reply->qual[lordercnt].
      exception_prsnl_id = be.exception_prsnl_id, reply->qual[lordercnt].exception_type_cd = be
      .exception_type_cd,
      reply->qual[lordercnt].status_flag = - (1), chk_osrc_status_flag = 0
      IF (osrc.status_flag=1
       AND ((o.order_status_cd=dorder_status_ordered_cd
       AND o.dept_status_cd != ddept_status_labinlab_cd) OR (o.order_status_cd=
      dorder_status_inprocess_cd
       AND o.dept_status_cd != ddept_status_labinlab_cd
       AND o.dept_status_cd != ddept_status_labinprocess_cd)) )
       chk_osrc_status_flag = 0
      ELSE
       chk_osrc_status_flag = osrc.status_flag
      ENDIF
      reply->qual[lordercnt].status_flag = chk_osrc_status_flag
     ENDIF
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select orderable information",errmsg)
    RETURN(0)
   ENDIF
   SET stat = alterlist(reply->qual,lordercnt)
   IF (lordercnt > 0)
    SELECT INTO "nl:"
     FROM order_detail od,
      order_entry_fields oef,
      discrete_task_assay dta,
      (dummyt d  WITH seq = size(reply->qual,5))
     PLAN (d
      WHERE d.seq <= size(reply->qual,5))
      JOIN (od
      WHERE (od.order_id=reply->qual[d.seq].order_id)
       AND od.oe_field_meaning_id IN (doe_promt_field_meaning_id, doe_surg_proc_field_meaning_id))
      JOIN (oef
      WHERE (oef.oe_field_id= Outerjoin(od.oe_field_id))
       AND (oef.prompt_entity_name= Outerjoin(sdta_entity_name)) )
      JOIN (dta
      WHERE (dta.task_assay_cd= Outerjoin(oef.prompt_entity_id))
       AND (dta.bb_result_processing_cd= Outerjoin(dbb_nbr_units_cd)) )
     DETAIL
      CASE (od.oe_field_meaning_id)
       OF doe_promt_field_meaning_id:
        IF (oef.prompt_entity_name=sdta_entity_name
         AND dta.bb_result_processing_cd=dbb_nbr_units_cd)
         reply->qual[d.seq].task_assay_cd = dta.task_assay_cd, reply->qual[d.seq].task_assay_mnemonic
          = dta.mnemonic, reply->qual[d.seq].bb_result_processing_cd = dta.bb_result_processing_cd,
         reply->qual[d.seq].event_cd = dta.event_cd, reply->qual[d.seq].nbr_units_requested =
         cnvtreal(od.oe_field_display_value)
        ENDIF
       OF doe_surg_proc_field_meaning_id:
        reply->qual[d.seq].surgical_procedure_cd = od.oe_field_value
      ENDCASE
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select surgical procedure and number of units information",errmsg)
     RETURN(0)
    ENDIF
    SELECT INTO "nl:"
     FROM encntr_alias ea,
      (dummyt d1  WITH seq = size(reply->qual,5))
     PLAN (d1
      WHERE d1.seq <= size(reply->qual,5))
      JOIN (ea
      WHERE (ea.encntr_id=reply->qual[d1.seq].encntr_id)
       AND ea.encntr_alias_type_cd=dencounter_mrn_cd)
     DETAIL
      IF (size(trim(ea.alias)) > 0)
       reply->qual[d1.seq].mrn_alias = cnvtalias(ea.alias,ea.alias_pool_cd)
      ENDIF
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select encntr alias",errmsg)
     RETURN(0)
    ENDIF
    SELECT INTO "nl:"
     FROM order_comment oc,
      (dummyt d2  WITH seq = size(reply->qual,5))
     PLAN (d2
      WHERE d2.seq <= size(reply->qual,5))
      JOIN (oc
      WHERE (oc.order_id=reply->qual[d2.seq].order_id))
     DETAIL
      reply->qual[d2.seq].order_comment_ind = 1
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select order comments information",errmsg)
     RETURN(0)
    ENDIF
    SELECT INTO "nl:"
     FROM result r,
      perform_result pr,
      (dummyt d3  WITH seq = size(reply->qual,5))
     PLAN (d3
      WHERE d3.seq <= size(reply->qual,5))
      JOIN (r
      WHERE (r.order_id=reply->qual[d3.seq].order_id)
       AND (r.task_assay_cd=reply->qual[d3.seq].task_assay_cd))
      JOIN (pr
      WHERE pr.result_id=r.result_id
       AND pr.interface_flag=nrop_prompt_interface_flag)
     DETAIL
      reply->qual[d3.seq].result_id = r.result_id, reply->qual[d3.seq].result_status_cd = r
      .result_status_cd, reply->qual[d3.seq].result_updt_cnt = r.updt_cnt,
      reply->qual[d3.seq].perform_result_id = pr.perform_result_id, reply->qual[d3.seq].container_id
       = pr.container_id, reply->qual[d3.seq].service_resource_cd = pr.service_resource_cd,
      reply->qual[d3.seq].result_type_cd = pr.result_type_cd, reply->qual[d3.seq].
      result_value_numeric = pr.result_value_numeric, reply->qual[d3.seq].numeric_raw_value = pr
      .numeric_raw_value,
      reply->qual[d3.seq].perform_result_updt_cnt = pr.updt_cnt, reply->qual[d3.seq].normal_cd = pr
      .normal_cd
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select perform result information",errmsg)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = sscript_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#set_status
 IF (lordercnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
