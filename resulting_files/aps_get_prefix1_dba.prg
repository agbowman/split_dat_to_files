CREATE PROGRAM aps_get_prefix1:dba
 DECLARE max_tag_cnt = i4 WITH protect, noconstant(0)
 DECLARE site_format = c5 WITH protect, constant("00000")
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
 IF ((validate(accession_common_version,- (1))=- (1)))
  DECLARE accession_common_version = i2 WITH constant(0)
  DECLARE acc_success = i2 WITH constant(0)
  DECLARE acc_error = i2 WITH constant(1)
  DECLARE acc_future = i2 WITH constant(2)
  DECLARE acc_null_dt_tm = i2 WITH constant(3)
  DECLARE acc_template = i2 WITH constant(300)
  DECLARE acc_pool = i2 WITH constant(310)
  DECLARE acc_pool_sequence = i2 WITH constant(320)
  DECLARE acc_duplicate = i2 WITH constant(410)
  DECLARE acc_modify = i2 WITH constant(420)
  DECLARE acc_sequence_id = i2 WITH constant(430)
  DECLARE acc_insert = i2 WITH constant(440)
  DECLARE acc_pool_id = i2 WITH constant(450)
  DECLARE acc_aor_false = i2 WITH constant(500)
  DECLARE acc_aor_true = i2 WITH constant(501)
  DECLARE acc_person_false = i2 WITH constant(502)
  DECLARE acc_person_true = i2 WITH constant(503)
  DECLARE site_length = i2 WITH constant(5)
  DECLARE julian_sequence_length = i2 WITH constant(6)
  DECLARE prefix_sequence_length = i2 WITH constant(7)
  DECLARE accession_status = i4 WITH noconstant(acc_success)
  DECLARE accession_meaning = c200 WITH noconstant(fillstring(200," "))
  RECORD acc_settings(
    1 acc_settings_loaded = i2
    1 site_code_length = i4
    1 julian_sequence_length = i4
    1 alpha_sequence_length = i4
    1 year_display_length = i4
    1 default_site_cd = f8
    1 default_site_prefix = c5
    1 assignment_days = i4
    1 assignment_dt_tm = dq8
    1 check_disp_ind = i2
  )
  RECORD accession_fmt(
    1 time_ind = i2
    1 insert_aor_ind = i2
    1 cpri_lookup = i2
    1 act_lookup = i2
    1 qual[*]
      2 order_id = f8
      2 catalog_cd = f8
      2 facility_cd = f8
      2 site_prefix_cd = f8
      2 site_prefix_disp = c5
      2 accession_format_cd = f8
      2 accession_format_mean = c12
      2 accession_class_cd = f8
      2 specimen_type_cd = f8
      2 accession_dt_tm = dq8
      2 accession_day = i4
      2 accession_year = i4
      2 alpha_prefix = c2
      2 accession_seq_nbr = i4
      2 accession_pool_id = f8
      2 assignment_meaning = vc
      2 assignment_status = i2
      2 accession_id = f8
      2 accession = c20
      2 accession_formatted = c25
      2 activity_type_cd = f8
      2 activity_type_mean = c12
      2 order_tag = i2
      2 accession_info_pos = i2
      2 accession_flag = i2
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 accession_parent = i2
      2 body_site_cd = f8
      2 body_site_ind = i2
      2 specimen_type_ind = i2
      2 service_area_cd = f8
      2 linked_qual[*]
        3 linked_pos = i2
  )
  RECORD accession_grp(
    1 cpri_lookup = i2
    1 act_lookup = i2
    1 qual[*]
      2 catalog_cd = f8
      2 specimen_type_cd = f8
      2 site_prefix_cd = f8
      2 accession_format_cd = f8
      2 accession_class_cd = f8
      2 accession_dt_tm = dq8
      2 accession_pool_id = f8
      2 accession_id = f8
      2 accession = c20
      2 activity_type_cd = f8
      2 accession_flag = i2
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 body_site_cd = f8
      2 service_area_cd = f8
  )
  DECLARE accession_nbr = c20 WITH noconstant(fillstring(20," "))
  DECLARE accession_nbr_chk = c50 WITH noconstant(fillstring(50," "))
  RECORD accession_str(
    1 site_prefix_disp = c5
    1 accession_year = i4
    1 accession_day = i4
    1 alpha_prefix = c2
    1 accession_seq_nbr = i4
    1 accession_pool_id = f8
  )
  DECLARE acc_site_prefix_cd = f8 WITH noconstant(0.0)
  DECLARE acc_site_prefix = c5 WITH noconstant(fillstring(value(site_length)," "))
  DECLARE accession_id = f8 WITH noconstant(0.0)
  DECLARE accession_dup_id = f8 WITH noconstant(0.0)
  DECLARE accession_updt_cnt = i4 WITH noconstant(0)
  DECLARE accession_assignment_ind = i2 WITH noconstant(0)
  RECORD accession_chk(
    1 check_disp_ind = i2
    1 site_prefix_cd = f8
    1 accession_year = i4
    1 accession_day = i4
    1 accession_pool_id = f8
    1 accession_seq_nbr = i4
    1 accession_class_cd = f8
    1 accession_format_cd = f8
    1 alpha_prefix = c2
    1 accession_id = f8
    1 accession = c20
    1 accession_nbr_check = c50
    1 accession_updt_cnt = i4
    1 action_ind = i2
    1 preactive_ind = i2
    1 assignment_ind = i2
  )
 ENDIF
 IF (istaskgranted(200436)=true)
  CALL initresourcesecurity(0)
 ELSE
  CALL initresourcesecurity(1)
 ENDIF
 EXECUTE accession_settings
 IF (accession_status != acc_success)
  SET reply->status_data.subeventstatus[1].operationname = "ACC_SETTINGS"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ACCESSION"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = accession_settings
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.prefix_id, c.specimen_meaning, site_unformatted = uar_get_code_display(p.site_cd)
  FROM ap_prefix p,
   case_specimen_type_r c
  PLAN (p
   WHERE  $1)
   JOIN (c
   WHERE p.case_type_cd=c.case_type_cd)
  HEAD REPORT
   spec_cnt = 0, reply->prefix_cd = p.prefix_id, reply->prefix_name = p.prefix_name,
   reply->prefix_desc = p.prefix_desc, reply->site_cd = p.site_cd, reply->accession_format_cd = p
   .accession_format_cd,
   reply->order_catalog_cd = p.order_catalog_cd, reply->case_type_cd = p.case_type_cd, reply->
   group_cd = p.group_id,
   reply->specimen_grouping_cd = p.specimen_grouping_cd, reply->interface_flag = p.interface_flag,
   reply->prefix_service_resource_cd = p.service_resource_cd
   IF (cnvtint(site_unformatted) != 0)
    reply->unformatted_site_disp = site_unformatted, reply->site_disp = build(substring(1,(
      acc_settings->site_code_length - textlen(trim(cnvtstring(cnvtint(site_unformatted))))),
      site_format),cnvtint(site_unformatted))
   ENDIF
   reply->imaging_interface_ind = p.imaging_interface_ind, reply->imaging_service_resource_cd = p
   .imaging_service_resource_cd, reply->tracking_service_resource_cd = p.tracking_service_resource_cd
  DETAIL
   spec_cnt += 1, stat = alter(reply->specimen_meaning_qual,spec_cnt), reply->specimen_meaning_qual[
   spec_cnt].specimen_meaning = c.specimen_meaning
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PREFIX"
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  orl.catalog_cd
  FROM order_catalog oc,
   orc_resource_list orl
  PLAN (oc
   WHERE (reply->order_catalog_cd=oc.catalog_cd)
    AND oc.resource_route_lvl=1)
   JOIN (orl
   WHERE oc.catalog_cd=orl.catalog_cd
    AND orl.active_ind=1
    AND orl.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND orl.end_effective_dt_tm > cnvtdatetime(sysdate))
  HEAD REPORT
   resource_cnt = 0, service_resource_cd = 0.0
  DETAIL
   service_resource_cd = orl.service_resource_cd
   IF (isresourceviewable(service_resource_cd)=true)
    resource_cnt += 1
    IF (mod(resource_cnt,5)=1
     AND resource_cnt != 1)
     stat = alterlist(reply->service_resource_qual,(resource_cnt+ 4))
    ENDIF
    reply->service_resource_qual[resource_cnt].service_resource_cd = orl.service_resource_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->service_resource_qual,resource_cnt)
  WITH nocounter
 ;end select
 IF ((reply->tracking_service_resource_cd > 0)
  AND (reply->interface_flag > 0))
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
    reply->interface_send_updates_as_new = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value_group cvr
   WHERE (cvr.child_code_value=reply->tracking_service_resource_cd)
    AND  EXISTS (
   (SELECT
    cve.field_value
    FROM code_value_extension cve
    WHERE cve.code_value=cvr.parent_code_value
     AND cve.field_name="SEND_SLIDE_FROM_SPECIMEN"
     AND cve.code_set=2074
     AND cve.field_value="1"))
   DETAIL
    reply->tracking_send_slide_from_spec = 1
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
 SET getprompttestsreq->prefix_cd = request->prefix_cd
 SET getprompttestsreq->default_catalog_cd = reply->order_catalog_cd
 EXECUTE aps_get_prompts  WITH replace("REQUEST",getprompttestsreq)
 FREE SET getprompttestsreq
 IF ((reply->status_data.status="F"))
  GO TO exit_script
 ENDIF
 IF ((reply->status_data.status != "Z"))
  EXECUTE aps_get_prompt_fields  WITH replace("REQUEST",reply)
 ENDIF
 IF ((reply->status_data.status="F"))
  GO TO exit_script
 ENDIF
 IF ((request->execute_ind != 0))
  EXECUTE aps_get_prefix_rpts
  IF ((reply->status_data.status="S"))
   EXECUTE aps_get_prefix_tag_info
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (getresourcesecuritystatus(0)="F")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(0)
 ENDIF
#exit_script
END GO
