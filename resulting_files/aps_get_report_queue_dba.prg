CREATE PROGRAM aps_get_report_queue:dba
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
     2 report_queue_cd = f8
     2 updt_cnt = i4
     2 rpt_cnt = i2
     2 rpt_qual[1]
       3 report_id = f8
       3 accession_nbr = c21
       3 prefix_cd = f8
       3 case_year = i4
       3 case_number = i4
       3 person_name = vc
       3 responsible_pathologist_name = vc
       3 responsible_resident_name = vc
       3 short_description = c50
       3 report_sequence = i4
       3 queue_sequence = i4
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET max_rpt_cnt = 1
 SET cnt = 0
 SET verified_cd = 0.0
 SET corrected_cd = 0.0
 SET signinproc_cd = 0.0
 SET csigninproc_cd = 0.0
 CALL initresourcesecurity(1)
 SELECT INTO "nl:"
  cv.cdf_meaning
  FROM code_value cv
  WHERE 1305=cv.code_set
   AND cv.cdf_meaning IN ("VERIFIED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "VERIFIED":
     verified_cd = cv.code_value
    OF "CORRECTED":
     corrected_cd = cv.code_value
    OF "SIGNINPROC":
     signinproc_cd = cv.code_value
    OF "CSIGNINPROC":
     csigninproc_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  c.updt_cnt, cr.case_id, cr.report_id,
  cr.report_sequence, rq.report_queue_cd, rq.report_id,
  sd.short_description, rt.responsible_pathologist_id, rpt_exists = decode(rt.seq,"Y","N")
  FROM code_value c,
   case_report cr,
   report_queue_r rq,
   report_task rt,
   service_directory sd,
   pathology_case pc,
   person p,
   prsnl p1,
   prsnl p2,
   (dummyt d  WITH seq = 1)
  PLAN (c
   WHERE c.code_set=1319
    AND (request->report_queue_cd=c.code_value))
   JOIN (d
   WHERE 1=d.seq)
   JOIN (rq
   WHERE (request->report_queue_cd=rq.report_queue_cd))
   JOIN (cr
   WHERE rq.report_id=cr.report_id
    AND  NOT (cr.status_cd IN (verified_cd, corrected_cd, signinproc_cd, csigninproc_cd))
    AND cr.cancel_cd IN (null, 0))
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   JOIN (pc
   WHERE cr.case_id=pc.case_id
    AND pc.cancel_cd IN (null, 0))
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (p1
   WHERE rt.responsible_pathologist_id=p1.person_id)
   JOIN (p2
   WHERE rt.responsible_resident_id=p2.person_id)
  ORDER BY rq.report_queue_cd
  HEAD REPORT
   cnt = 0, rpt_cnt = 0, service_resource_cd = 0.0
  HEAD rq.report_queue_cd
   rpt_cnt = 0
  DETAIL
   IF (rpt_exists="Y")
    service_resource_cd = rt.service_resource_cd
    IF (isresourceviewable(service_resource_cd)=true)
     IF (rpt_cnt=0)
      cnt += 1
      IF (mod(cnt,10)=1
       AND cnt != 1)
       stat = alter(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].report_queue_cd = rq.report_queue_cd, reply->qual[cnt].updt_cnt = c.updt_cnt
     ENDIF
     rpt_cnt += 1
     IF (rpt_cnt > max_rpt_cnt)
      max_rpt_cnt = rpt_cnt
     ENDIF
     stat = alter(reply->qual.rpt_qual,rpt_cnt), reply->qual[cnt].rpt_cnt = rpt_cnt, reply->qual[cnt]
     .rpt_qual[rpt_cnt].report_id = cr.report_id,
     reply->qual[cnt].rpt_qual[rpt_cnt].accession_nbr = pc.accession_nbr, reply->qual[cnt].rpt_qual[
     rpt_cnt].prefix_cd = pc.prefix_id, reply->qual[cnt].rpt_qual[rpt_cnt].case_year = pc.case_year,
     reply->qual[cnt].rpt_qual[rpt_cnt].case_number = pc.case_number, reply->qual[cnt].rpt_qual[
     rpt_cnt].person_name = trim(p.name_full_formatted), reply->qual[cnt].rpt_qual[rpt_cnt].
     responsible_pathologist_name = trim(p1.name_full_formatted),
     reply->qual[cnt].rpt_qual[rpt_cnt].responsible_resident_name = trim(p2.name_full_formatted),
     reply->qual[cnt].rpt_qual[rpt_cnt].short_description = sd.short_description, reply->qual[cnt].
     rpt_qual[rpt_cnt].report_sequence = cr.report_sequence,
     reply->qual[cnt].rpt_qual[rpt_cnt].queue_sequence = rq.sequence, reply->qual[cnt].rpt_qual[
     rpt_cnt].updt_cnt = rq.updt_cnt
    ENDIF
   ELSE
    service_resource_cd = 0.0, stat = isresourceviewable(service_resource_cd)
   ENDIF
  FOOT  rq.report_queue_cd
   IF (rpt_cnt > 0)
    stat = alter(reply->qual.rpt_qual,rpt_cnt)
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "OPEN CASES"
  SET reply->status_data.status = "Z"
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,cnt)
#exit_script
END GO
