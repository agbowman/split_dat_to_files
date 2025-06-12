CREATE PROGRAM bbt_rpt_ex_msbos:dba
 RECORD data(
   1 qual[*]
     2 accession = vc
     2 override_reason_cd = f8
     2 override_reason_disp = c40
     2 order_id = f8
     2 order_mnemonic = vc
     2 order_dt_tm = dq8
     2 person_id = f8
     2 patient_name = vc
     2 catalog_cd = f8
     2 catalog_desc = c40
     2 catalog_disp = c40
     2 order_provider_id = f8
     2 order_provider_name = vc
     2 encntr_mrn = vc
     2 surgical_procedure_cd = f8
     2 surgical_procedure_disp = c40
     2 nbr_units_prompt_cd = f8
     2 nbr_units_guideline = i2
     2 nbr_units_requested = i2
     2 nbr_units_approved = i2
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 guideline_flag = i2
     2 name_last = vc
     2 name_first = vc
     2 name_middle = vc
 )
 DECLARE get_uar_variables(none=i2) = i2
 DECLARE sscript_name = c23 WITH protect, constant("bb_rpt_msbos_exception")
 DECLARE sdta_entity_name = c19 WITH protect, constant("DISCRETE_TASK_ASSAY")
 DECLARE lbb_surg_proc_msbos_cs = i4 WITH protect, constant(4554)
 DECLARE doe_promt_field_meaning_id = f8 WITH protect, constant(9001.0)
 DECLARE doe_surg_proc_field_meaning_id = f8 WITH protect, constant(7000.0)
 DECLARE lbb_processing_cs = i4 WITH protect, constant(1636)
 DECLARE sbb_nbr_units_cdf = c12 WITH protect, constant("NBR UNITS")
 DECLARE smax_surgical_blood_order = vc WITH protect, constant("Maximum Surgical Blood Order")
 DECLARE stype_screen_only = vc WITH protect, constant("Type and Screen Only")
 DECLARE lrop_prompt_interface_flag = i4 WITH protect, constant(4)
 DECLARE lexcept_review_interface_flag = i4 WITH protect, constant(9)
 DECLARE nguideline_exists_flag = i2 WITH protect, constant(0)
 DECLARE nno_testing_required_flag = i2 WITH protect, constant(1)
 DECLARE ntype_and_screen_only_flag = i2 WITH protect, constant(2)
 DECLARE dbb_nbr_units_cd = f8 WITH protect, noconstant(0.0)
 DECLARE lordercnt = i4 WITH protect, noconstant(0)
 DECLARE sexceptiondisp = c40 WITH protect, noconstant(" ")
 DECLARE sexceptionmean = c12 WITH protect, noconstant(" ")
 DECLARE datafoundflag = i2 WITH protect, noconstant(false)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE orderid_index = i4 WITH noconstant(0)
 DECLARE orderid_index_found = i4 WITH protect, noconstant(0.0)
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
 RECORD testsites(
   1 qual[*]
     2 service_resource_cd = f8
     2 service_resource_disp = c40
 )
 DECLARE const_serv_res_section_cdf = c12 WITH protect, constant("SECTION")
 DECLARE const_serv_res_subsection_cdf = c12 WITH protect, constant("SUBSECTION")
 DECLARE const_serv_res_bench_cdf = c12 WITH protect, constant("BENCH")
 DECLARE const_serv_res_instrument_cdf = c12 WITH protect, constant("INSTRUMENT")
 DECLARE const_serv_res_type_cs = i4 WITH protect, constant(223)
 DECLARE const_return_security_ok = i2 WITH protect, constant(1)
 DECLARE const_return_no_security = i2 WITH protect, constant(0)
 DECLARE const_return_invalid = i2 WITH protect, constant(- (1))
 DECLARE const_security_on = i2 WITH protect, constant(1)
 DECLARE const_security_off = i2 WITH protect, constant(0)
 DECLARE dservressectioncd = f8 WITH protect, noconstant(0.0)
 DECLARE dservressubsectioncd = f8 WITH protect, noconstant(0.0)
 DECLARE nstat = i4 WITH protect, noconstant(0)
 SUBROUTINE (initservresroutine(nservressecind=i2) =i2)
   SET nstat = uar_get_meaning_by_codeset(const_serv_res_type_cs,const_serv_res_section_cdf,1,
    dservressectioncd)
   IF (dservressectioncd=0.0)
    RETURN(const_return_invalid)
   ENDIF
   SET nstat = uar_get_meaning_by_codeset(const_serv_res_type_cs,const_serv_res_subsection_cdf,1,
    dservressubsectioncd)
   IF (dservressubsectioncd=0.0)
    RETURN(const_return_invalid)
   ENDIF
   CALL initresourcesecurity(nservressecind)
   RETURN(const_return_security_ok)
 END ;Subroutine
 SUBROUTINE (determineservresaccess(dserviceresourcecd=f8) =i2)
   DECLARE sservrescdfmeaning = vc WITH protect, noconstant("")
   DECLARE iservreslevelflag = i2 WITH protect, noconstant(- (1))
   DECLARE itestsitecnt = i2 WITH protect, noconstant(0)
   DECLARE dcurservres = f8 WITH protect, noconstant(0.0)
   DECLARE ierrorcd = i4 WITH protect, noconstant(0)
   DECLARE serrormsg = vc WITH protect, noconstant("")
   IF (dserviceresourcecd=0.0)
    SET iservreslevelflag = 3
   ELSE
    SET sservrescdfmeaning = uar_get_code_meaning(dserviceresourcecd)
    IF (trim(sservrescdfmeaning) IN (const_serv_res_bench_cdf, const_serv_res_instrument_cdf))
     IF (isresourceviewable(dserviceresourcecd)=true)
      SET itestsitecnt = 1
      SET nstat = alterlist(testsites->qual,itestsitecnt)
      SET testsites->qual[itestsitecnt].service_resource_cd = dserviceresourcecd
      SET testsites->qual[itestsitecnt].service_resource_disp = uar_get_code_display(
       dserviceresourcecd)
      RETURN(const_return_security_ok)
     ELSE
      RETURN(const_return_no_security)
     ENDIF
    ELSEIF (trim(sservrescdfmeaning)=const_serv_res_subsection_cdf)
     SET iservreslevelflag = 1
    ELSEIF (trim(sservrescdfmeaning)=const_serv_res_section_cdf)
     SET iservreslevelflag = 2
    ELSE
     RETURN(const_return_invalid)
    ENDIF
   ENDIF
   IF (iservreslevelflag=1)
    SELECT INTO "nl:"
     subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     FROM resource_group subsect
     WHERE subsect.parent_service_resource_cd=dserviceresourcecd
      AND subsect.resource_group_type_cd=dservressubsectioncd
      AND ((subsect.root_service_resource_cd+ 0)=0.0)
     ORDER BY subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     HEAD REPORT
      itestsitecnt = 0, dcurservres = 0.0
     HEAD subsect.parent_service_resource_cd
      dcurservres = subsect.parent_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     HEAD subsect.child_service_resource_cd
      dcurservres = subsect.child_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     FOOT REPORT
      nstat = alterlist(testsites->qual,itestsitecnt)
     WITH nocounter
    ;end select
   ELSEIF (iservreslevelflag=2)
    SELECT INTO "nl:"
     sect.parent_service_resource_cd, subsect.parent_service_resource_cd, subsect
     .child_service_resource_cd
     FROM resource_group sect,
      resource_group subsect
     PLAN (sect
      WHERE sect.resource_group_type_cd=dservressectioncd
       AND sect.parent_service_resource_cd=dserviceresourcecd
       AND ((sect.root_service_resource_cd+ 0)=0.0))
      JOIN (subsect
      WHERE subsect.parent_service_resource_cd=sect.child_service_resource_cd
       AND subsect.resource_group_type_cd=dservressubsectioncd
       AND ((subsect.root_service_resource_cd+ 0)=0.0))
     ORDER BY subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     HEAD REPORT
      itestsitecnt = 0, dcurservres = 0.0
     HEAD subsect.parent_service_resource_cd
      dcurservres = subsect.parent_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     HEAD subsect.child_service_resource_cd
      dcurservres = subsect.child_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     FOOT REPORT
      nstat = alterlist(testsites->qual,itestsitecnt)
     WITH nocounter
    ;end select
   ELSEIF (iservreslevelflag=3)
    SELECT INTO "nl:"
     sect.parent_service_resource_cd, subsect.parent_service_resource_cd, subsect
     .child_service_resource_cd
     FROM resource_group sect,
      resource_group subsect
     PLAN (sect
      WHERE sect.resource_group_type_cd=dservressectioncd
       AND sect.root_service_resource_cd=0.0)
      JOIN (subsect
      WHERE subsect.parent_service_resource_cd=sect.child_service_resource_cd
       AND subsect.resource_group_type_cd=dservressubsectioncd
       AND ((subsect.root_service_resource_cd+ 0)=0.0))
     ORDER BY subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     HEAD REPORT
      itestsitecnt = 0, dcurservres = 0.0
     HEAD subsect.parent_service_resource_cd
      dcurservres = subsect.parent_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     HEAD subsect.child_service_resource_cd
      dcurservres = subsect.child_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     FOOT REPORT
      nstat = alterlist(testsites->qual,itestsitecnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (size(testsites->qual,5) > 0)
    RETURN(const_return_security_ok)
   ELSE
    RETURN(const_return_no_security)
   ENDIF
 END ;Subroutine
 DECLARE nsecurityind = i2 WITH project, noconstant(const_security_on)
 DECLARE nreturnstat = i2 WITH protect, noconstant(const_return_invalid)
 DECLARE ntestsitecnt = i4 WITH protect, noconstant(0)
 SET nsecurityind = const_security_on
 IF (size(trim(request->batch_selection),1) > 0)
  SET nsecurityind = const_security_off
 ENDIF
 IF (initservresroutine(nsecurityind)=const_return_invalid)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_ex_msbos"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "InitServResRoutine()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Status Returned."
  GO TO exit_script
 ENDIF
 IF (size(request->qual,5) > 0)
  SET nreturnstat = determineservresaccess(request->qual[1].service_resource_cd)
 ELSE
  SET nreturnstat = determineservresaccess(0.0)
 ENDIF
 IF (nreturnstat=const_return_invalid)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_ex_msbos"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DetermineServResAccess()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Service Resource"
  GO TO exit_script
 ELSEIF (nreturnstat=const_return_no_security)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_ex_msbos"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DetermineServResAccess()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "No security access for specified Service Resource"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET dbb_nbr_units_cd = uar_get_code_by("MEANING",lbb_processing_cs,nullterm(sbb_nbr_units_cdf))
 IF (dbb_nbr_units_cd <= 0.0)
  SET uar_error_string = concat("Failed to retrieve cdf meaning of ",trim(sbb_nbr_units_cdf),
   " from code set ",cnvtstring(lbb_processing_cs),".")
  CALL errorhandler("F","uar_get_code_by",uar_error_string)
  GO TO exit_script
 ENDIF
 IF (load_review_items(0)=0)
  GO TO exit_script
 ENDIF
 IF (generate_report(0)=0)
  GO TO exit_script
 ENDIF
 GO TO set_status
 SUBROUTINE (load_review_items(none=i2) =i2)
   SELECT INTO "nl:"
    FROM bb_exception be,
     orders o,
     person p,
     encntr_alias ea,
     accession_order_r aor,
     order_serv_res_container osrc,
     order_action oa,
     prsnl pl
    PLAN (be
     WHERE be.exception_type_cd=exception_code
      AND be.override_reason_cd > 0.0)
     JOIN (o
     WHERE o.order_id=be.order_id
      AND o.orig_order_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
      end_dt_tm))
     JOIN (aor
     WHERE aor.order_id=o.order_id
      AND aor.primary_flag=0)
     JOIN (p
     WHERE p.person_id=o.person_id)
     JOIN (ea
     WHERE (ea.encntr_id= Outerjoin(o.encntr_id))
      AND (ea.encntr_alias_type_cd= Outerjoin(encntr_mrn_code))
      AND (ea.active_ind= Outerjoin(1)) )
     JOIN (osrc
     WHERE osrc.order_id=o.order_id
      AND expand(ntestsitecnt,1,size(testsites->qual,5),osrc.service_resource_cd,testsites->qual[
      ntestsitecnt].service_resource_cd))
     JOIN (oa
     WHERE oa.order_id=o.order_id)
     JOIN (pl
     WHERE pl.person_id=oa.order_provider_id)
    ORDER BY osrc.service_resource_cd, o.orig_order_dt_tm, p.name_full_formatted,
     oa.action_sequence DESC, osrc.order_id
    HEAD REPORT
     lmrncount = 0, bnewexception = "T", bmrnfound = "F",
     stat = alterlist(alias->person_alias,lmrncount)
    HEAD p.name_full_formatted
     row + 0
    HEAD oa.action_sequence
     row + 0
    HEAD osrc.order_id
     orderid_index_found = locateval(orderid_index,1,size(data->qual,5),osrc.order_id,data->qual[
      orderid_index].order_id)
     IF (orderid_index_found <= 0)
      lordercnt += 1
      IF (lordercnt > size(data->qual,5))
       stat = alterlist(data->qual,(lordercnt+ 9))
      ENDIF
      data->qual[lordercnt].order_id = o.order_id, data->qual[lordercnt].order_mnemonic = o
      .order_mnemonic, data->qual[lordercnt].order_dt_tm = o.orig_order_dt_tm,
      data->qual[lordercnt].person_id = o.person_id, data->qual[lordercnt].patient_name = p
      .name_full_formatted, data->qual[lordercnt].catalog_cd = o.catalog_cd,
      data->qual[lordercnt].catalog_disp = uar_get_code_display(o.catalog_cd), data->qual[lordercnt].
      accession = cnvtacc(aor.accession), data->qual[lordercnt].order_provider_id = oa
      .order_provider_id,
      data->qual[lordercnt].order_provider_name = pl.name_full_formatted, data->qual[lordercnt].
      encntr_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), data->qual[lordercnt].override_reason_cd =
      be.override_reason_cd,
      data->qual[lordercnt].override_reason_disp = uar_get_code_display(be.override_reason_cd), data
      ->qual[lordercnt].service_resource_cd = osrc.service_resource_cd, data->qual[lordercnt].
      service_resource_disp = uar_get_code_display(osrc.service_resource_cd),
      data->qual[lordercnt].name_last = p.name_last, data->qual[lordercnt].name_first = p.name_first,
      data->qual[lordercnt].name_middle = p.name_middle
     ENDIF
    DETAIL
     row + 0
    FOOT  osrc.order_id
     row + 0
    FOOT  oa.action_sequence
     row + 0
    FOOT  p.name_full_formatted
     row + 0
    FOOT REPORT
     stat = alterlist(data->qual,lordercnt)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select orderable information",errmsg)
    RETURN(0)
   ENDIF
   IF (lordercnt=0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM order_detail od,
     order_entry_fields oef,
     discrete_task_assay dta,
     (dummyt d  WITH seq = size(data->qual,5))
    PLAN (d
     WHERE d.seq <= size(data->qual,5))
     JOIN (od
     WHERE (od.order_id=data->qual[d.seq].order_id)
      AND od.oe_field_meaning_id IN (doe_promt_field_meaning_id, doe_surg_proc_field_meaning_id))
     JOIN (oef
     WHERE (oef.oe_field_id= Outerjoin(od.oe_field_id))
      AND (oef.prompt_entity_name= Outerjoin(sdta_entity_name)) )
     JOIN (dta
     WHERE (dta.task_assay_cd= Outerjoin(oef.prompt_entity_id))
      AND (dta.bb_result_processing_cd= Outerjoin(dbb_nbr_units_cd)) )
    ORDER BY od.order_id
    HEAD REPORT
     hold_action_sequence = 0
    HEAD od.order_id
     data->qual[d.seq].nbr_units_requested = - (1)
    DETAIL
     CASE (od.oe_field_meaning_id)
      OF doe_promt_field_meaning_id:
       IF (oef.prompt_entity_name=sdta_entity_name
        AND dta.bb_result_processing_cd=dbb_nbr_units_cd)
        data->qual[d.seq].nbr_units_prompt_cd = dta.task_assay_cd, data->qual[d.seq].
        nbr_units_requested = cnvtint(od.oe_field_display_value)
       ENDIF
      OF doe_surg_proc_field_meaning_id:
       data->qual[d.seq].surgical_procedure_cd = od.oe_field_value,data->qual[d.seq].
       surgical_procedure_disp = od.oe_field_display_value
     ENDCASE
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select surgical procedure and number of units information",errmsg)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM result r,
     perform_result pr,
     (dummyt d  WITH seq = size(data->qual,5))
    PLAN (d
     WHERE d.seq <= size(data->qual,5))
     JOIN (r
     WHERE (r.order_id=data->qual[d.seq].order_id)
      AND (r.task_assay_cd=data->qual[d.seq].nbr_units_prompt_cd))
     JOIN (pr
     WHERE pr.result_id=r.result_id
      AND pr.interface_flag IN (lrop_prompt_interface_flag, lexcept_review_interface_flag))
    ORDER BY pr.interface_flag
    DETAIL
     data->qual[d.seq].nbr_units_approved = pr.result_value_numeric
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select approved number of units information",errmsg)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    sdisp = uar_get_code_display(cvs.code_value)
    FROM code_value cv,
     code_value_extension cvs,
     (dummyt d  WITH seq = size(data->qual,5))
    PLAN (d
     WHERE d.seq <= size(data->qual,5))
     JOIN (cv
     WHERE cv.code_set=lbb_surg_proc_msbos_cs
      AND (cv.code_value=data->qual[d.seq].surgical_procedure_cd))
     JOIN (cvs
     WHERE cvs.code_value=cv.code_value)
    DETAIL
     IF ((data->qual[d.seq].guideline_flag < ntype_and_screen_only_flag))
      CASE (cvs.field_name)
       OF smax_surgical_blood_order:
        IF (cnvtint(cvs.field_value)=0)
         data->qual[d.seq].guideline_flag = nno_testing_required_flag
        ELSE
         data->qual[d.seq].guideline_flag = nguideline_exists_flag, data->qual[d.seq].
         nbr_units_guideline = cnvtint(cvs.field_value)
        ENDIF
       OF stype_screen_only:
        IF (cnvtint(cvs.field_value)=1)
         data->qual[d.seq].guideline_flag = ntype_and_screen_only_flag
        ENDIF
      ENDCASE
     ENDIF
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select MSBOS guideline information",errmsg)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (generate_report(none=i2) =i2)
   SET sexceptiondisp = uar_get_code_display(exception_code)
   SET sexceptionmean = uar_get_code_meaning(exception_code)
   IF (sexceptionmean="MSBOS")
    EXECUTE cpm_create_file_name_logical "bbt_msbos", "txt", "x"
   ELSE
    GO TO exit_script
   ENDIF
   SELECT INTO cpm_cfn_info->file_name_logical
    sort_date = format(data->qual[d.seq].order_dt_tm,"@SHORTDATE;;d"), sort_svc = data->qual[d.seq].
    service_resource_cd, sort_person_id = data->qual[d.seq].person_id,
    sort_last_name = cnvtupper(substring(1,100,data->qual[d.seq].name_last)), sort_first_name =
    cnvtupper(substring(1,100,data->qual[d.seq].name_first)), sort_middle_name = cnvtupper(substring(
      1,100,data->qual[d.seq].name_middle))
    FROM (dummyt d  WITH seq = value(size(data->qual,5)))
    PLAN (d
     WHERE d.seq <= value(size(data->qual,5)))
    ORDER BY sort_svc, sort_date, sort_last_name,
     sort_first_name, sort_middle_name, sort_person_id
    HEAD REPORT
     col_head_7 = fillstring(7,"-"), col_head_9 = fillstring(9,"-"), col_head_11 = fillstring(11,"-"),
     col_head_15 = fillstring(15,"-"), col_head_20 = fillstring(20,"-"), col_head_25 = fillstring(25,
      "-"),
     col_head_34 = fillstring(34,"-"), dholdsr_cd = 0.00, bfirsttime = "T",
     bnewpage = "T", bnewdate = "T"
    HEAD PAGE
     bnewpage = "T", beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->
      end_dt_tm),
     inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
     IF (sub_get_location_name="<<INFORMATION NOT FOUND>>")
      inc_info_not_found = uar_i18ngetmessage(inc_i18nhandle,"inc_information_not_found",
       "<<INFORMATION NOT FOUND>>"), col 1, inc_info_not_found
     ELSE
      col 1, sub_get_location_name
     ENDIF
     row + 1
     IF (sub_get_location_name != "<<INFORMATION NOT FOUND>>")
      IF (sub_get_location_address1 != " ")
       col 1, sub_get_location_address1, row + 1
      ENDIF
      IF (sub_get_location_address2 != " ")
       col 1, sub_get_location_address2, row + 1
      ENDIF
      IF (sub_get_location_address3 != " ")
       col 1, sub_get_location_address3, row + 1
      ENDIF
      IF (sub_get_location_address4 != " ")
       col 1, sub_get_location_address4, row + 1
      ENDIF
      IF (sub_get_location_citystatezip != ",   ")
       col 1, sub_get_location_citystatezip, row + 1
      ENDIF
      IF (sub_get_location_country != " ")
       col 1, sub_get_location_country, row + 1
      ENDIF
     ENDIF
     save_row = row, row 0,
     CALL center(captions->bb_exception,1,125),
     col 104, captions->time, col 118,
     curtime"@TIMENOSECONDS;;M", row + 1, col 104,
     captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
     row save_row, row + 1, col 1,
     captions->service_resource
     IF (lordercnt > 0)
      col 19, data->qual[d.seq].service_resource_disp
     ENDIF
     row + 2, col 32, captions->beg_date,
     col 48, beg_dt_tm"@DATECONDENSED;;d", col 56,
     beg_dt_tm"@TIMENOSECONDS;;M", col 69, captions->end_date,
     col 82, end_dt_tm"@DATECONDENSED;;d", col 90,
     end_dt_tm"@TIMENOSECONDS;;M", row + 2, col 1,
     sexceptiondisp, row + 2, col 2,
     captions->accession, col 29, captions->physician,
     row + 1, col 2, captions->name,
     col 29, captions->orderable,
     CALL center(captions->units,71,89),
     row + 1, col 2, captions->mrn,
     col 29, captions->procedure,
     CALL center(captions->guideline,57,67),
     CALL center(captions->requested,71,79),
     CALL center(captions->approved,81,89),
     CALL center(captions->reason,92,125),
     row + 1, col 2, col_head_25,
     col 29, col_head_25, col 57,
     col_head_11, col 71, col_head_9,
     col 81, col_head_9, col 92,
     col_head_34, row + 1
    HEAD sort_svc
     IF ((dholdsr_cd != data->qual[d.seq].service_resource_cd))
      dholdsr_cd = data->qual[d.seq].service_resource_cd
      IF (bfirsttime="F")
       BREAK
      ELSE
       bfirsttime = "F"
      ENDIF
     ENDIF
    HEAD sort_date
     IF (row > 53)
      BREAK
     ENDIF
     bnewdate = "T"
     IF (bnewpage="F")
      row + 2
     ENDIF
     col 1, sort_date
    DETAIL
     datafoundflag = true, bnewpage = "F"
     IF (row > 54)
      BREAK
     ENDIF
     IF (bnewdate="F"
      AND bnewpage="F")
      row + 1
     ELSEIF (bnewdate="F"
      AND bnewpage="T")
      row- (1)
     ELSE
      bnewdate = "F"
     ENDIF
     row + 1, col 2, data->qual[d.seq].accession"#########################",
     col 29, data->qual[d.seq].order_provider_name"#########################", row + 1,
     col 2, data->qual[d.seq].patient_name"#########################", col 29,
     data->qual[d.seq].order_mnemonic"#########################", row + 1
     IF (trim(data->qual[d.seq].encntr_mrn) > "")
      col 2, data->qual[d.seq].encntr_mrn"#########################"
     ELSE
      col 2, captions->not_on_file"#########################"
     ENDIF
     col 29, data->qual[d.seq].surgical_procedure_disp"#########################"
     CASE (data->qual[d.seq].guideline_flag)
      OF nguideline_exists_flag:
       col 57,data->qual[d.seq].nbr_units_guideline"###########"
      OF nno_testing_required_flag:
       col 57,captions->nt_required"###########;R"
      OF ntype_and_screen_only_flag:
       col 57,captions->ts_only"###########;R"
     ENDCASE
     IF ((data->qual[d.seq].nbr_units_requested=- (1)))
      col 71, captions->none"#########", col 81,
      captions->none"#########"
     ELSE
      col 71, data->qual[d.seq].nbr_units_requested"#########", col 81,
      data->qual[d.seq].nbr_units_approved"#########"
     ENDIF
     col 92, data->qual[d.seq].override_reason_disp"##################################"
    FOOT  sort_date
     row + 0
    FOOT  sort_svc
     row + 0
    FOOT PAGE
     row 57, col 1, line,
     row + 1, col 1, cpm_cfn_info->file_name_path,
     col 58, captions->page_no, col 64,
     curpage"###", col 100, captions->printed,
     col 109, curdate"@DATECONDENSED;;d", col 120,
     curtime"@TIMENOSECONDS;;M"
    FOOT REPORT
     row 60, col 51, captions->end_of_report
    WITH maxrow = 61, nullreport, compress,
     nolandscape, nocounter
   ;end select
   IF (((datafoundflag=true) OR ((request->null_ind=1))) )
    SET rpt_cnt += 1
    SET stat = alterlist(reply->rpt_list,rpt_cnt)
    SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
    SET datafoundflag = false
   ENDIF
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Generate Report",errmsg)
    RETURN(0)
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
 SET reply->status_data.status = "S"
#exit_script
 FREE SET testsites
END GO
