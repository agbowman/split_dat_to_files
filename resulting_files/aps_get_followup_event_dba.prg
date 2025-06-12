CREATE PROGRAM aps_get_followup_event:dba
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
   1 event_qual[*]
     2 followup_event_id = f8
     2 followup_type_cd = f8
     2 origin_flag = i2
     2 origin_dt_tm = dq8
     2 origin_prsnl_id = f8
     2 origin_prsnl_name = vc
     2 expected_term_dt = dq8
     2 initial_notif_dt_tm = dq8
     2 initial_notif_print_flag = i2
     2 first_overdue_dt_tm = dq8
     2 first_overdue_print_flag = i2
     2 final_overdue_dt_tm = dq8
     2 final_overdue_print_flag = i2
     2 term_id = f8
     2 term_name = vc
     2 term_dt_tm = dq8
     2 term_reason_cd = f8
     2 term_reason_disp = c40
     2 term_reason_desc = vc
     2 term_accession_nbr = c21
     2 term_case_id = f8
     2 term_comment = vc
     2 term_long_text_id = f8
     2 term_updt_cnt = i4
     2 alias = vc
     2 case_person_id = f8
     2 encounter_id = f8
     2 case_id = f8
     2 accession_nbr = c21
     2 status_flag = i2
     2 case_collect_dt_tm = dq8
     2 main_report_cmplete_dt_tm = dq8
     2 reference_range_factor_id = f8
     2 nomenclature_id = f8
     2 source_string = vc
     2 updt_cnt = i4
   1 type_qual[*]
     2 followup_tracking_type_cd = f8
     2 description = vc
     2 patient_notification_ind = i2
     2 patient_first_overdue_ind = i2
     2 patient_final_overdue_ind = i2
     2 doctor_notification_ind = i2
     2 doctor_first_overdue_ind = i2
     2 doctor_final_overdue_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 IF ((request->skip_resource_security_ind=0))
  CALL initresourcesecurity(1)
 ELSE
  CALL initresourcesecurity(0)
 ENDIF
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SELECT INTO "nl:"
  fte.origin_flag, pc_accession_nbr = decode(pc.seq,uar_fmt_accession(pc.accession_nbr,size(pc
     .accession_nbr,1)),""), fte_term_accession_nbr = decode(pc.seq,uar_fmt_accession(fte
    .term_accession_nbr,size(fte.term_accession_nbr,1)),""),
  fte_term_case_id = decode(pcterm.case_id,pcterm.case_id,0.0)
  FROM ap_ft_event fte,
   pathology_case pc,
   pathology_case pcterm,
   ap_prefix ap,
   cyto_screening_event cse,
   nomenclature n,
   dummyt d1,
   prsnl p1,
   dummyt d2,
   prsnl p2
  PLAN (fte
   WHERE (request->person_id=fte.person_id))
   JOIN (pc
   WHERE fte.case_id=pc.case_id)
   JOIN (ap
   WHERE ap.prefix_id=pc.prefix_id)
   JOIN (cse
   WHERE fte.case_id=cse.case_id
    AND 1=cse.verify_ind)
   JOIN (n
   WHERE cse.nomenclature_id=n.nomenclature_id)
   JOIN (pcterm
   WHERE (pcterm.accession_nbr= Outerjoin(fte.term_accession_nbr))
    AND (pcterm.cancel_cd= Outerjoin(0)) )
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (p1
   WHERE fte.origin_prsnl_id=p1.person_id)
   JOIN (d2
   WHERE 1=d2.seq)
   JOIN (p2
   WHERE fte.term_id=p2.person_id)
  HEAD REPORT
   ecnt = 0, ftstatus = 0, access_to_resource_ind = 0,
   service_resource_cd = 0.0
  DETAIL
   service_resource_cd = ap.service_resource_cd
   IF (isresourceviewable(service_resource_cd)=true)
    ecnt += 1
    IF (mod(ecnt,10)=1)
     stat = alterlist(reply->event_qual,(ecnt+ 9))
    ENDIF
    reply->event_qual[ecnt].followup_type_cd = fte.followup_type_cd, reply->event_qual[ecnt].
    followup_event_id = fte.followup_event_id, reply->event_qual[ecnt].origin_flag = fte.origin_flag,
    reply->event_qual[ecnt].origin_dt_tm = cnvtdatetime(fte.origin_dt_tm), reply->event_qual[ecnt].
    origin_prsnl_id = fte.origin_prsnl_id, reply->event_qual[ecnt].origin_prsnl_name = p1
    .name_full_formatted,
    reply->event_qual[ecnt].expected_term_dt = cnvtdatetime(fte.expected_term_dt), reply->event_qual[
    ecnt].initial_notif_dt_tm = cnvtdatetime(fte.initial_notif_dt_tm), reply->event_qual[ecnt].
    initial_notif_print_flag = fte.initial_notif_print_flag,
    reply->event_qual[ecnt].first_overdue_dt_tm = cnvtdatetime(fte.first_overdue_dt_tm), reply->
    event_qual[ecnt].first_overdue_print_flag = fte.first_overdue_print_flag, reply->event_qual[ecnt]
    .final_overdue_dt_tm = cnvtdatetime(fte.final_overdue_dt_tm),
    reply->event_qual[ecnt].final_overdue_print_flag = fte.final_overdue_print_flag, reply->
    event_qual[ecnt].term_id = fte.term_id, reply->event_qual[ecnt].term_name = p2
    .name_full_formatted,
    reply->event_qual[ecnt].term_dt_tm = cnvtdatetime(fte.term_dt_tm), reply->event_qual[ecnt].
    term_reason_cd = fte.term_reason_cd, reply->event_qual[ecnt].term_accession_nbr =
    fte_term_accession_nbr,
    reply->event_qual[ecnt].term_case_id = fte_term_case_id, reply->event_qual[ecnt].
    term_long_text_id = fte.term_long_text_id, reply->event_qual[ecnt].case_person_id = pc.person_id,
    reply->event_qual[ecnt].case_id = pc.case_id, reply->event_qual[ecnt].encounter_id = pc.encntr_id,
    reply->event_qual[ecnt].accession_nbr = pc_accession_nbr,
    reply->event_qual[ecnt].case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm), reply->
    event_qual[ecnt].main_report_cmplete_dt_tm = cnvtdatetime(pc.main_report_cmplete_dt_tm), reply->
    event_qual[ecnt].reference_range_factor_id = cse.reference_range_factor_id,
    reply->event_qual[ecnt].nomenclature_id = cse.nomenclature_id, reply->event_qual[ecnt].
    source_string = n.source_string, ftstatus = 0
    IF (cnvtdatetime(fte.term_dt_tm) > 0)
     ftstatus = 4
    ELSE
     IF (fte.initial_notif_print_flag > 0)
      ftstatus = 1
     ENDIF
     IF (fte.first_overdue_print_flag > 0)
      ftstatus = 2
     ENDIF
     IF (fte.final_overdue_print_flag > 0)
      ftstatus = 3
     ENDIF
    ENDIF
    reply->event_qual[ecnt].status_flag = ftstatus
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->event_qual,ecnt)
  WITH nocounter, outerjoin = d1, dontcare = p1,
   outerjoin = d2, dontcare = p2
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","P","TABLE","AP_FT_EVENT")
  SET reply->status_data.status = "S"
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(1)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM (dummyt d1  WITH seq = value(size(reply->event_qual,5))),
   (dummyt d2  WITH seq = 1),
   encntr_alias ea
  PLAN (d1
   WHERE (reply->event_qual[d1.seq].encounter_id > 0))
   JOIN (d2)
   JOIN (ea
   WHERE (ea.encntr_id=reply->event_qual[d1.seq].encounter_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  HEAD REPORT
   ecnt = 0
  DETAIL
   IF ((ea.encntr_id=reply->event_qual[d1.seq].encounter_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd)
    reply->event_qual[d1.seq].alias = frmt_mrn
   ELSE
    reply->event_qual[d1.seq].alias = "Unknown"
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id
  FROM (dummyt d1  WITH seq = value(size(reply->event_qual,5))),
   long_text lt
  PLAN (d1
   WHERE (reply->event_qual[d1.seq].term_long_text_id > 0))
   JOIN (lt
   WHERE (reply->event_qual[d1.seq].term_long_text_id=lt.long_text_id)
    AND lt.parent_entity_name="AP_FT_EVENT"
    AND (lt.parent_entity_id=reply->event_qual[d1.seq].followup_event_id))
  DETAIL
   reply->event_qual[d1.seq].term_comment = lt.long_text, reply->event_qual[d1.seq].term_updt_cnt =
   lt.updt_cnt
  WITH nocounter
 ;end select
 IF ((request->need_types_flag=1))
  SELECT INTO "nl:"
   ftt.followup_tracking_type_cd
   FROM ap_ft_type ftt
   WHERE ftt.followup_tracking_type_cd > 0
   HEAD REPORT
    tcnt = 0
   DETAIL
    tcnt += 1
    IF (mod(tcnt,10)=1)
     stat = alterlist(reply->type_qual,(tcnt+ 9))
    ENDIF
    reply->type_qual[tcnt].followup_tracking_type_cd = ftt.followup_tracking_type_cd, reply->
    type_qual[tcnt].description = ftt.description, reply->type_qual[tcnt].patient_notification_ind =
    ftt.patient_notification_ind,
    reply->type_qual[tcnt].patient_first_overdue_ind = ftt.patient_first_overdue_ind, reply->
    type_qual[tcnt].patient_final_overdue_ind = ftt.patient_final_overdue_ind, reply->type_qual[tcnt]
    .doctor_notification_ind = ftt.doctor_notification_ind,
    reply->type_qual[tcnt].doctor_first_overdue_ind = ftt.doctor_first_overdue_ind, reply->type_qual[
    tcnt].doctor_final_overdue_ind = ftt.doctor_final_overdue_ind
   FOOT REPORT
    stat = alterlist(reply->type_qual,tcnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","Z","TABLE","AP_FT_TYPE")
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
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
