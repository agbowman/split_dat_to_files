CREATE PROGRAM aps_get_rpts_to_correct:dba
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
   1 case_id = f8
   1 rpt_qual[*]
     2 event_id = f8
     2 report_id = f8
     2 blob_bitmap = i4
     2 report_sequence = i4
     2 catalog_cd = f8
     2 description = vc
     2 short_description = c50
     2 responsible_pathologist_id = f8
     2 responsible_resident_id = f8
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 priority_cd = f8
     2 priority_disp = c40
     2 report_task_exists = i2
     2 primary_rpt_ind = i2
     2 rt_updt_cnt = i4
     2 cr_updt_cnt = i4
     2 resource_qual[*]
       3 service_resource_cd = f8
       3 service_resource_disp = c40
       3 service_resource_desc = vc
     2 cyto_report_ind = i2
   1 case_type_cd = f8
   1 case_type_disp = c40
   1 case_type_desc = vc
   1 case_type_mean = c12
   1 prefix_cd = f8
   1 accessioned_dt_tm = dq8
   1 accession_prsnl_id = f8
   1 tracking_interface_ind = i2
   1 tracking_service_resource_cd = f8
   1 tracking_send_updates_as_new = i2
   1 imaging_interface_ind = i2
   1 imaging_service_resource_cd = f8
   1 imaging_send_updates_as_new = i2
   1 priority_cd = f8
   1 accession_nbr = c18
   1 case_comment = vc
   1 case_comment_long_text_id = f8
   1 requesting_physician_id = f8
   1 requesting_physician_name = vc
   1 responsible_pathologist_id = f8
   1 responsible_pathologist_name = vc
   1 responsible_resident_id = f8
   1 responsible_resident_name = vc
   1 encntr_id = f8
   1 person_id = f8
   1 person_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dpowerchartsourcecd = f8 WITH protect, noconstant(0.0)
 DECLARE npathhistoryentryappnum = i4 WITH protect, constant(200044)
 SET reply->status_data.status = "F"
 SET rpt_cnt = 0
 SET verified_status_cd = 0.0
 SET corrected_status_cd = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 CALL initresourcesecurity(1)
 SET code_set = 1305
 SET cdf_meaning = "VERIFIED"
 EXECUTE cpm_get_cd_for_cdf
 SET verified_status_cd = code_value
 SET code_set = 1305
 SET cdf_meaning = "CORRECTED"
 EXECUTE cpm_get_cd_for_cdf
 SET corrected_status_cd = code_value
 SET stat = uar_get_meaning_by_codeset(89,"POWERCHART",1,dpowerchartsourcecd)
 SELECT INTO "nl:"
  pc.case_id, cr_exists = decode(cr.seq,1,0), cr_report_id = decode(cr.seq,cr.report_id,0.0),
  cr.report_sequence, sd.short_description, rt.report_id,
  report_task_exists = decode(rt.seq,1,0), orl_exists = decode(orl.seq,1,0)
  FROM pathology_case pc,
   ap_prefix ap,
   prsnl pr1,
   prsnl pr2,
   prsnl pr3,
   (dummyt d1  WITH seq = 1),
   case_report cr,
   service_directory sd,
   prefix_report_r prr,
   (dummyt d5  WITH seq = 1),
   cyto_report_control crc,
   (dummyt d2  WITH seq = 1),
   report_task rt,
   (dummyt d3  WITH seq = 1),
   orc_resource_list orl,
   clinical_event ce,
   (dummyt d4  WITH seq = 1),
   person p
  PLAN (pc
   WHERE (request->accession_nbr=pc.accession_nbr))
   JOIN (ap
   WHERE ap.prefix_id=pc.prefix_id)
   JOIN (pr1
   WHERE pc.requesting_physician_id=pr1.person_id)
   JOIN (pr2
   WHERE pc.responsible_pathologist_id=pr2.person_id)
   JOIN (pr3
   WHERE pc.responsible_resident_id=pr3.person_id)
   JOIN (d4
   WHERE 1=d4.seq)
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (cr
   WHERE pc.case_id=cr.case_id
    AND cr.cancel_cd IN (null, 0)
    AND cr.status_cd IN (verified_status_cd, corrected_status_cd))
   JOIN (ce
   WHERE ce.event_id=cr.event_id
    AND ce.contributor_system_cd=dpowerchartsourcecd
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND ce.updt_task != npathhistoryentryappnum)
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   JOIN (prr
   WHERE cr.catalog_cd=prr.catalog_cd
    AND pc.prefix_id=prr.prefix_id)
   JOIN (d5
   WHERE 1=d5.seq)
   JOIN (crc
   WHERE cr.catalog_cd=crc.catalog_cd
    AND prr.primary_ind=1)
   JOIN (d2
   WHERE 1=d2.seq)
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
   JOIN (d3
   WHERE 1=d3.seq)
   JOIN (orl
   WHERE cr.catalog_cd=orl.catalog_cd
    AND orl.active_ind=1
    AND orl.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND orl.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY cr_report_id
  HEAD REPORT
   rpt_cnt = 0, resource_cnt = 0, access_to_resource_ind = 1,
   stat = alterlist(reply->rpt_qual,5), reply->case_id = pc.case_id, service_resource_cd = 0.0,
   reply->case_type_cd = pc.case_type_cd, reply->prefix_cd = pc.prefix_id, reply->accessioned_dt_tm
    = pc.accessioned_dt_tm,
   reply->accession_prsnl_id = pc.accession_prsnl_id, reply->tracking_interface_ind = ap
   .interface_flag, reply->tracking_service_resource_cd = ap.tracking_service_resource_cd,
   reply->imaging_interface_ind = ap.imaging_interface_ind, reply->imaging_service_resource_cd = ap
   .imaging_service_resource_cd, reply->accession_nbr = pc.accession_nbr,
   reply->case_comment_long_text_id = pc.comments_long_text_id, reply->requesting_physician_id = pc
   .requesting_physician_id, reply->requesting_physician_name = pr1.name_full_formatted,
   reply->responsible_pathologist_id = pc.responsible_pathologist_id, reply->
   responsible_pathologist_name = pr2.name_full_formatted, reply->responsible_resident_id = pc
   .responsible_resident_id,
   reply->responsible_resident_name = pr3.name_full_formatted, reply->encntr_id = pc.encntr_id, reply
   ->person_id = pc.person_id,
   reply->person_name = p.name_full_formatted
  HEAD cr_report_id
   access_to_resource_ind = 0
   IF (report_task_exists=0)
    service_resource_cd = ap.service_resource_cd
   ELSE
    service_resource_cd = rt.service_resource_cd
   ENDIF
   IF (isresourceviewable(service_resource_cd)=true)
    access_to_resource_ind = 1
    IF (cr_exists=1)
     rpt_cnt += 1
     IF (mod(rpt_cnt,5)=1
      AND rpt_cnt != 1)
      stat = alterlist(reply->rpt_qual,(rpt_cnt+ 4))
     ENDIF
     reply->rpt_qual[rpt_cnt].event_id = cr.event_id, reply->rpt_qual[rpt_cnt].report_id = cr
     .report_id, reply->rpt_qual[rpt_cnt].blob_bitmap = cr.blob_bitmap,
     reply->rpt_qual[rpt_cnt].report_sequence = cr.report_sequence, reply->rpt_qual[rpt_cnt].
     catalog_cd = cr.catalog_cd, reply->rpt_qual[rpt_cnt].cr_updt_cnt = cr.updt_cnt,
     reply->rpt_qual[rpt_cnt].description = sd.description, reply->rpt_qual[rpt_cnt].
     short_description = sd.short_description, reply->rpt_qual[rpt_cnt].primary_rpt_ind = prr
     .primary_ind,
     reply->rpt_qual[rpt_cnt].report_task_exists = report_task_exists
     IF (crc.catalog_cd > 0)
      reply->rpt_qual[rpt_cnt].cyto_report_ind = 1
     ELSE
      reply->rpt_qual[rpt_cnt].cyto_report_ind = 0
     ENDIF
     IF (report_task_exists=1)
      reply->rpt_qual[rpt_cnt].service_resource_cd = rt.service_resource_cd, reply->rpt_qual[rpt_cnt]
      .priority_cd = rt.priority_cd, reply->rpt_qual[rpt_cnt].rt_updt_cnt = rt.updt_cnt,
      reply->rpt_qual[rpt_cnt].responsible_pathologist_id = rt.responsible_pathologist_id, reply->
      rpt_qual[rpt_cnt].responsible_resident_id = rt.responsible_resident_id
      IF ((reply->rpt_qual[rpt_cnt].primary_rpt_ind=1))
       reply->priority_cd = rt.priority_cd
      ENDIF
     ELSE
      reply->rpt_qual[rpt_cnt].responsible_pathologist_id = pc.responsible_pathologist_id, reply->
      rpt_qual[rpt_cnt].responsible_resident_id = pc.responsible_resident_id
     ENDIF
    ENDIF
    resource_cnt = 0, stat = alterlist(reply->rpt_qual[rpt_cnt].resource_qual,5)
   ENDIF
  DETAIL
   IF (access_to_resource_ind=1)
    IF (orl_exists=1)
     service_resource_cd = orl.service_resource_cd
     IF (isresourceviewable(service_resource_cd)=true)
      resource_cnt += 1
      IF (mod(resource_cnt,5)=1
       AND resource_cnt != 1)
       stat = alterlist(reply->rpt_qual[rpt_cnt].resource_qual,(resource_cnt+ 4))
      ENDIF
      reply->rpt_qual[rpt_cnt].resource_qual[resource_cnt].service_resource_cd = orl
      .service_resource_cd
     ENDIF
    ENDIF
   ENDIF
  FOOT  cr_report_id
   stat = alterlist(reply->rpt_qual[rpt_cnt].resource_qual,resource_cnt)
  FOOT REPORT
   stat = alterlist(reply->rpt_qual,rpt_cnt)
  WITH outerjoin = d4, outerjoin = d1, outerjoin = d5,
   dontcare = crc, outerjoin = d2, dontcare = rt,
   outerjoin = d3, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(0)
 ELSE
  IF (rpt_cnt=0)
   SET reply->status_data.status = "P"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt
  PLAN (lt
   WHERE (reply->case_comment_long_text_id > 0)
    AND (reply->case_comment_long_text_id=lt.long_text_id))
  DETAIL
   reply->case_comment = trim(lt.long_text)
  WITH nocounter
 ;end select
 IF ((reply->tracking_service_resource_cd > 0)
  AND (reply->tracking_interface_ind > 0))
  SELECT INTO "nl:"
   FROM code_value_group cvr
   WHERE (cvr.child_code_value=reply->tracking_service_resource_cd)
    AND  EXISTS (
   (SELECT
    cve.field_value
    FROM code_value_extension cve
    WHERE cve.code_value=cvr.parent_code_value
     AND cve.field_name="SEND_UPDATES_AS_NEW"
     AND cve.code_set=2074
     AND cve.field_value="1"))
   DETAIL
    reply->tracking_send_updates_as_new = 1
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->imaging_service_resource_cd > 0)
  AND (reply->imaging_interface_ind > 0))
  SELECT INTO "nl:"
   FROM code_value_group cvr
   WHERE (cvr.child_code_value=reply->imaging_service_resource_cd)
    AND  EXISTS (
   (SELECT
    cve.field_value
    FROM code_value_extension cve
    WHERE cve.code_value=cvr.parent_code_value
     AND cve.field_name="SEND_UPDATES_AS_NEW"
     AND cve.code_set=2074
     AND cve.field_value="1"))
   DETAIL
    reply->imaging_send_updates_as_new = 1
   WITH nocounter
  ;end select
 ENDIF
END GO
