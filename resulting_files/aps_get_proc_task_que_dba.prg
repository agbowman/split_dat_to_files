CREATE PROGRAM aps_get_proc_task_que:dba
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
 RECORD temp(
   1 case_qual[10]
     2 case_id = f8
     2 priority_cd = f8
     2 service_resource_cd = f8
     2 spec_qual[*]
       3 case_specimen_id = f8
 )
 RECORD srtemp(
   1 qual[1]
     2 service_resource_cd = f8
 )
 RECORD reply(
   1 case_cnt = i2
   1 case_qual[10]
     2 case_id = f8
     2 accession = c21
     2 priority_cd = f8
     2 priority_disp = c40
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 pathologist_name = c40
     2 resident_name = c40
     2 collect_dt_tm = dq8
     2 receive_dt_tm = dq8
     2 spec_cnt = i2
     2 spec_qual[*]
       3 case_specimen_id = f8
       3 specimen_desc = vc
       3 specimen_tag = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((request->serv_rsrc_cd > 0))
  SET cntr = 0
  SELECT INTO "nl:"
   rg.child_service_resource_cd
   FROM resource_group rg
   PLAN (rg
    WHERE (request->serv_rsrc_cd=rg.parent_service_resource_cd)
     AND rg.active_ind=1
     AND rg.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND rg.end_effective_dt_tm > cnvtdatetime(sysdate))
   HEAD REPORT
    cntr += 1, srtemp->qual[cntr].service_resource_cd = request->serv_rsrc_cd
   DETAIL
    cntr += 1
    IF (cntr > 1)
     stat = alter(srtemp->qual,cntr)
    ENDIF
    srtemp->qual[cntr].service_resource_cd = rg.child_service_resource_cd
   WITH nocounter
  ;end select
  IF (cntr=0)
   SET srtemp->qual[1].service_resource_cd = request->serv_rsrc_cd
  ENDIF
 ENDIF
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET status_ordered = 0.0
 SET max_spec_cnt = 0
 CALL initresourcesecurity(1)
 SET code_set = 1305
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET status_ordered = code_value
 SELECT INTO "nl:"
  pt.processing_task_id, pt.case_id
  FROM processing_task pt,
   (dummyt d  WITH seq = value(size(srtemp->qual,5)))
  PLAN (d)
   JOIN (pt
   WHERE pt.create_inventory_flag=4
    AND pt.status_cd=status_ordered
    AND parser(
    IF ((request->batch_nbr > 0)) "request->batch_nbr = pt.worklist_nbr"
    ELSE "0 = 0"
    ENDIF
    )
    AND parser(
    IF ((request->serv_rsrc_cd > 0))
     "srtemp->qual[d.seq].service_resource_cd = pt.service_resource_cd"
    ELSE "0 = 0"
    ENDIF
    ))
  ORDER BY pt.case_id
  HEAD REPORT
   case_cnt = 0, spec_cnt = 0
  HEAD pt.case_id
   spec_cnt = 0, case_cnt += 1
   IF (mod(case_cnt,10)=1
    AND case_cnt != 1)
    stat = alter(temp->case_qual,(case_cnt+ 9))
   ENDIF
   temp->case_qual[case_cnt].case_id = pt.case_id, temp->case_qual[case_cnt].priority_cd = pt
   .priority_cd, temp->case_qual[case_cnt].service_resource_cd = pt.service_resource_cd
  DETAIL
   spec_cnt += 1
   IF (spec_cnt > size(temp->case_qual[case_cnt].spec_qual,5))
    stat = alterlist(temp->case_qual[case_cnt].spec_qual,spec_cnt)
   ENDIF
   IF (spec_cnt > max_spec_cnt)
    max_spec_cnt = spec_cnt
   ENDIF
   temp->case_qual[case_cnt].spec_qual[spec_cnt].case_specimen_id = pt.case_specimen_id
  FOOT REPORT
   stat = alter(temp->case_qual,case_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","PROCESSING_TASK")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pc.case_id
  FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
   (dummyt d2  WITH seq = value(max_spec_cnt)),
   pathology_case pc,
   prsnl p1,
   prsnl p2,
   ap_prefix ap,
   case_specimen cs,
   ap_tag at
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->case_qual[d1.seq].spec_qual,5))
   JOIN (pc
   WHERE (temp->case_qual[d1.seq].case_id=pc.case_id)
    AND parser(
    IF ((request->pathologist_id > 0)) "request->pathologist_id = pc.responsible_pathologist_id"
    ELSE "0 = 0"
    ENDIF
    )
    AND parser(
    IF ((request->resident_id > 0)) "request->resident_id = pc.responsible_resident_id"
    ELSE "0 = 0"
    ENDIF
    ))
   JOIN (p1
   WHERE pc.responsible_pathologist_id=p1.person_id)
   JOIN (p2
   WHERE pc.responsible_resident_id=p2.person_id)
   JOIN (ap
   WHERE ap.prefix_id=pc.prefix_id)
   JOIN (cs
   WHERE (temp->case_qual[d1.seq].spec_qual[d2.seq].case_specimen_id=cs.case_specimen_id))
   JOIN (at
   WHERE cs.specimen_tag_id=at.tag_id)
  ORDER BY pc.case_id, at.tag_sequence
  HEAD REPORT
   case_cnt = 0, spec_cnt = 0, access_to_resource_ind = 0,
   service_resource_cd = 0.0
  HEAD pc.case_id
   spec_cnt = 0, service_resource_cd = ap.service_resource_cd, access_to_resource_ind = 0
   IF (isresourceviewable(service_resource_cd)=true)
    access_to_resource_ind = 1, case_cnt += 1
    IF (mod(case_cnt,10)=1
     AND case_cnt != 1)
     stat = alter(reply->case_qual,(case_cnt+ 9))
    ENDIF
    reply->case_cnt = case_cnt, reply->case_qual[case_cnt].case_id = pc.case_id, reply->case_qual[
    case_cnt].accession = pc.accession_nbr,
    reply->case_qual[case_cnt].priority_cd = temp->case_qual[d1.seq].priority_cd, reply->case_qual[
    case_cnt].service_resource_cd = temp->case_qual[d1.seq].service_resource_cd, reply->case_qual[
    case_cnt].pathologist_name = p1.name_full_formatted,
    reply->case_qual[case_cnt].resident_name = p2.name_full_formatted
   ENDIF
  DETAIL
   IF (access_to_resource_ind=1)
    spec_cnt += 1
    IF (spec_cnt > size(reply->case_qual[case_cnt].spec_qual,5))
     stat = alterlist(reply->case_qual[case_cnt].spec_qual,spec_cnt)
    ENDIF
    IF (spec_cnt=1)
     reply->case_qual[case_cnt].collect_dt_tm = cs.collect_dt_tm, reply->case_qual[case_cnt].
     receive_dt_tm = cs.received_dt_tm
    ENDIF
    reply->case_qual[case_cnt].spec_cnt = spec_cnt, reply->case_qual[case_cnt].spec_qual[spec_cnt].
    case_specimen_id = cs.case_specimen_id, reply->case_qual[case_cnt].spec_qual[spec_cnt].
    specimen_desc = cs.specimen_description,
    reply->case_qual[case_cnt].spec_qual[spec_cnt].specimen_tag = at.tag_disp
   ENDIF
  FOOT REPORT
   stat = alter(reply->case_qual,case_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","PATHOLOGY_CASE")
  SET reply->status_data.status = "Z"
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(1)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
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
