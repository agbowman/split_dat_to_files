CREATE PROGRAM aps_get_case_for_followup:dba
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
   1 alias = vc
   1 accession_nbr = c21
   1 case_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 case_collect_dt_tm = dq8
   1 main_report_cmplete_dt_tm = dq8
   1 reference_range_factor_id = f8
   1 nomenclature_id = f8
   1 source_string = vc
   1 cyto_alpha_security_avail = i4
   1 followup_tracking_type_cd = f8
   1 followup_initial_interval = i4
   1 followup_first_interval = i4
   1 followup_final_interval = i4
   1 followup_termination_interval = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD cytoalphasecurity(
   1 list[*]
     2 service_resource_cd = f8
 )
#script
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE dcytoalphasecservresourcecd = f8 WITH protect, noconstant(0.0)
 DECLARE dservressubsectiontypecd = f8 WITH protect, noconstant(0.0)
 DECLARE suarerror = vc WITH protect, noconstant("")
 DECLARE const_serv_res_type_cs = i4 WITH protect, constant(223)
 DECLARE const_serv_res_subsection_cdf = c12 WITH protect, constant("SUBSECTION")
 DECLARE const_serv_res_bench_cdf = c12 WITH protect, constant("BENCH")
 DECLARE const_serv_res_instrument_cdf = c12 WITH protect, constant("INSTRUMENT")
 DECLARE rescnt = i4 WITH protect, noconstant(0)
 DECLARE sidx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 CALL initresourcesecurity(1)
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = 14009
 SET lstat = uar_get_meaning_by_codeset(const_serv_res_type_cs,const_serv_res_subsection_cdf,1,
  dservressubsectiontypecd)
 IF (dservressubsectiontypecd=0.0)
  SET suarerror = concat("Failed to retrieve service resource type code with meaning of ",trim(
    const_serv_res_subsection_cdf),".")
  CALL handle_errors("aps_get_cyto_rpt_ref","F","uar_get_code_by",suarerror)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 DECLARE uar_fmt_accession(p1,p2) = c25
 SELECT INTO "nl:"
  pc.case_collect_dt_tm
  FROM pathology_case pc,
   ap_prefix ap,
   cyto_screening_event cse,
   nomenclature n
  PLAN (pc
   WHERE (request->accession_nbr=pc.accession_nbr)
    AND pc.cancel_cd IN (null, 0)
    AND pc.reserved_ind != 1
    AND pc.origin_flag != 1)
   JOIN (ap
   WHERE pc.prefix_id=ap.prefix_id)
   JOIN (cse
   WHERE pc.case_id=cse.case_id
    AND 1=cse.verify_ind)
   JOIN (n
   WHERE cse.nomenclature_id=n.nomenclature_id)
  HEAD REPORT
   service_resource_cd = 0.0
  DETAIL
   service_resource_cd = ap.service_resource_cd
   IF (isresourceviewable(service_resource_cd)=true)
    reply->accession_nbr = uar_fmt_accession(pc.accession_nbr,size(trim(pc.accession_nbr),1)), reply
    ->case_id = pc.case_id, reply->person_id = pc.person_id,
    reply->encntr_id = pc.encntr_id, reply->case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm),
    reply->main_report_cmplete_dt_tm = cnvtdatetime(pc.main_report_cmplete_dt_tm),
    reply->reference_range_factor_id = cse.reference_range_factor_id, reply->nomenclature_id = cse
    .nomenclature_id, reply->source_string = n.source_string,
    dcytoalphasecservresourcecd = cse.service_resource_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","PATHOLOGY_CASE")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(1)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(cytoalphasecurity->list,2)
 SET cytoalphasecurity->list[1].service_resource_cd = dcytoalphasecservresourcecd
 SET cytoalphasecurity->list[2].service_resource_cd = 0.0
 SET rescnt = 2
 IF (uar_get_code_meaning(dcytoalphasecservresourcecd) IN (const_serv_res_bench_cdf,
 const_serv_res_instrument_cdf))
  SELECT INTO "nl:"
   rg.parent_service_resource_cd
   FROM resource_group rg
   WHERE rg.child_service_resource_cd=dcytoalphasecservresourcecd
    AND rg.root_service_resource_cd=0.0
    AND ((rg.resource_group_type_cd+ 0)=dservressubsectiontypecd)
    AND ((rg.active_ind+ 0)=1)
    AND rg.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND rg.end_effective_dt_tm > cnvtdatetime(sysdate)
   DETAIL
    rescnt += 1, stat = alterlist(cytoalphasecurity->list,rescnt), cytoalphasecurity->list[rescnt].
    service_resource_cd = rg.parent_service_resource_cd
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  cas.service_resource_cd, resourcelevel = evaluate(uar_get_code_meaning(cas.service_resource_cd),
   const_serv_res_bench_cdf,3,const_serv_res_instrument_cdf,3,
   const_serv_res_subsection_cdf,2,1)
  FROM cyto_alpha_security cas
  WHERE (cas.reference_range_factor_id=reply->reference_range_factor_id)
   AND (cas.nomenclature_id=reply->nomenclature_id)
   AND cas.definition_ind IN (0, 2)
   AND expand(sidx,1,rescnt,cas.service_resource_cd,cytoalphasecurity->list[sidx].service_resource_cd
   )
  HEAD REPORT
   resourcelevelhold = 0
  DETAIL
   IF (resourcelevelhold < resourcelevel)
    resourcelevelhold = resourcelevel, reply->cyto_alpha_security_avail = 1, reply->
    followup_tracking_type_cd = cas.followup_tracking_type_cd,
    reply->followup_initial_interval = cas.followup_initial_interval, reply->followup_first_interval
     = cas.followup_first_interval, reply->followup_final_interval = cas.followup_final_interval,
    reply->followup_termination_interval = cas.followup_termination_interval
   ENDIF
  FOOT REPORT
   IF (resourcelevelhold=0)
    reply->cyto_alpha_security_avail = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), pc.case_collect_dt_tm
  FROM pathology_case pc,
   encntr_alias ea,
   (dummyt d1  WITH seq = 1)
  PLAN (pc
   WHERE (request->accession_nbr=pc.accession_nbr)
    AND pc.cancel_cd IN (null, 0)
    AND pc.reserved_ind != 1
    AND pc.origin_flag != 1)
   JOIN (d1)
   JOIN (ea
   WHERE ea.encntr_id=pc.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   IF (ea.encntr_id=pc.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd)
    reply->alias = frmt_mrn
   ELSE
    reply->alias = "Unknown"
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SET reply->status_data.status = "S"
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
END GO
