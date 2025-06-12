CREATE PROGRAM aps_get_rpts_by_resp:dba
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
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE susername = c50 WITH protect, noconstant("")
 DECLARE nstatus = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE sunknownstring = vc WITH protect, noconstant("")
 DECLARE sstillbornstring = vc WITH protect, noconstant("")
 SET nstatus = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET sunknownstring = uar_i18ngetmessage(i18nhandle,"UNKNOWN_AGE","Unknown")
 SET sstillbornstring = uar_i18ngetmessage(i18nhandle,"STILLBORN_AGE","Stillborn")
 SELECT INTO "nl:"
  FROM prsnl pl
  WHERE (person_id=reqinfo->updt_id)
  DETAIL
   susername = pl.username
  WITH nocounter
 ;end select
 SUBROUTINE (formatage(birth_dt_tm=f8,deceased_dt_tm=f8,policy=vc) =vc WITH protect)
   DECLARE eff_end_dt_tm = f8 WITH private, noconstant(0.0)
   SET eff_end_dt_tm = deceased_dt_tm
   IF (((eff_end_dt_tm=null) OR (eff_end_dt_tm=0.00)) )
    SET eff_end_dt_tm = cnvtdatetime(sysdate)
   ENDIF
   IF (((birth_dt_tm > eff_end_dt_tm) OR (birth_dt_tm=null)) )
    RETURN(sunknownstring)
   ELSEIF (birth_dt_tm=deceased_dt_tm)
    RETURN(sstillbornstring)
   ELSE
    RETURN(cnvtage2(birth_dt_tm,eff_end_dt_tm,0,concat(policy,"/",trim(susername),"/",trim(cnvtstring
       (reqinfo->position_cd,32,2)))))
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 omf_info_qual[*]
     2 dm_info_name = vc
     2 dm_info_date = dq8
     2 dm_info_char = vc
     2 dm_info_number = f8
     2 dm_info_long_id = f8
     2 updt_cnt = i4
   1 case_qual[10]
     2 case_id = f8
     2 case_type_cd = f8
     2 case_type_disp = c40
     2 case_type_desc = vc
     2 case_type_mean = c12
     2 encntr_id = f8
     2 case_collect_dt_tm = dq8
     2 case_received_dt_tm = dq8
     2 case_blob_bitmap = i4
     2 dataset_uid = vc
     2 prefix_cd = f8
     2 accession_nbr = c18
     2 case_year = i4
     2 case_number = i4
     2 resp_pathologist_id = f8
     2 resp_pathologist_name = vc
     2 resp_resident_id = f8
     2 resp_resident_name = vc
     2 req_physician_id = f8
     2 req_physician_name = vc
     2 chr_ind = i2
     2 pc_updt_cnt = i4
     2 person_id = f8
     2 person_name = vc
     2 person_num = c16
     2 sex_cd = f8
     2 sex_disp = c40
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 deceased_dt_tm = dq8
     2 age = vc
     2 case_comment_long_text_id = f8
     2 case_comment = vc
     2 lt_case_comment_updt_cnt = i4
     2 loc_facility_cd = f8
     2 report_qual[*]
       3 report_queue_seq = i4
       3 report_id = f8
       3 report_sequence = i4
       3 catalog_cd = f8
       3 service_resource_cd = f8
       3 service_resource_disp = c40
       3 resp_pathologist_id = f8
       3 resp_pathologist_name = vc
       3 resp_resident_id = f8
       3 resp_resident_name = vc
       3 description = vc
       3 short_description = c50
       3 request_priority_cd = f8
       3 request_priority_disp = c40
       3 request_priority_desc = vc
       3 request_priority_mean = c12
       3 hold_cd = f8
       3 hold_disp = c40
       3 hold_comment = vc
       3 hold_comment_long_text_id = f8
       3 lt_hold_comment_updt_cnt = i4
       3 status_cd = f8
       3 status_disp = c40
       3 status_mean = c12
       3 last_edit_dt_tm = dq8
       3 cyto_report_ind = i4
       3 updt_cnt = i4
       3 cr_updt_cnt = i4
       3 primary_ind = i2
       3 report_comment_long_text_id = f8
       3 report_comment = vc
       3 lt_report_comment_updt_cnt = i4
     2 spec_qual[*]
       3 case_specimen_id = f8
       3 specimen_tag_group_cd = f8
       3 specimen_tag_cd = f8
       3 specimen_tag_display = c7
       3 specimen_tag_sequence = i4
       3 specimen_description = vc
       3 specimen_cd = f8
       3 specimen_disp = c40
     2 phys_qual[*]
       3 physician_id = f8
       3 physician_name = vc
     2 main_report_complete_dt_tm = dq8
     2 accessioned_dt_tm = dq8
     2 accession_prsnl_id = f8
     2 tracking_interface_ind = i2
     2 tracking_service_resource_cd = f8
     2 tracking_send_updates_as_new = i2
     2 imaging_interface_ind = i2
     2 imaging_service_resource_cd = f8
     2 imaging_send_updates_as_new = i2
     2 priority_cd = f8
     2 person_unformat_mrn = vc
     2 person_unformat_cmrn = vc
     2 person_fin = vc
     2 case_digital_img_identifier = vc
   1 child_service_resource_qual[*]
     2 child_service_resource_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[1]
     2 service_resource_cd = f8
 )
 SET reply->status_data.status = "F"
 SET case_cnt = 0
 SET mrn_alias_type_cd = 0.0
 SET cmrn_alias_type_cd = 0.0
 SET fin_alias_type_cd = 0.0
 SET completed_cd = 0.0
 SET verified_cd = 0.0
 SET corrected_cd = 0.0
 SET signinproc_cd = 0.0
 SET csigninproc_cd = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET error_cnt = 0
 SET max_report_cnt = 0
 CALL initresourcesecurity(1)
 SELECT INTO "nl:"
  cv.cdf_meaning
  FROM code_value cv
  WHERE 1305=cv.code_set
   AND cv.cdf_meaning IN ("VERIFIED", "COMPLETED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "VERIFIED":
     verified_cd = cv.code_value
    OF "COMPLETED":
     completed_cd = cv.code_value
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
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE")
  GO TO exit_script
 ENDIF
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SET stat = uar_get_meaning_by_codeset(4,"CMRN",1,cmrn_alias_type_cd)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_alias_type_cd)
 IF ((request->service_resource_cd > 0))
  SET childcnt = 0
  SET temp->qual[1].service_resource_cd = request->service_resource_cd
  SET cntr = 1
  SELECT INTO "nl:"
   rg.child_service_resource_cd
   FROM resource_group rg
   PLAN (rg
    WHERE (request->service_resource_cd=rg.parent_service_resource_cd)
     AND rg.active_ind=1
     AND rg.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND rg.end_effective_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    cntr += 1, stat = alter(temp->qual,cntr), temp->qual[cntr].service_resource_cd = rg
    .child_service_resource_cd
    IF (rg.child_service_resource_cd > 0.00)
     childcnt += 1, stat = alterlist(reply->child_service_resource_qual,childcnt), reply->
     child_service_resource_qual[childcnt].child_service_resource_cd = rg.child_service_resource_cd
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  rt.report_id, cr.report_sequence, pc.case_id,
  sd.short_description, prr.primary_ind, crc.catalog_cd,
  cyto_rpt = decode(crc.seq,1,0), pr1.name_full_formatted, pr2.name_full_formatted,
  pr3.name_full_formatted, pr4.name_full_formatted, pr5.name_full_formatted
  FROM report_task rt,
   case_report cr,
   pathology_case pc,
   service_directory sd,
   prefix_report_r prr,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = value(size(temp->qual,5))),
   cyto_report_control crc,
   prsnl pr1,
   prsnl pr2,
   prsnl pr3,
   prsnl pr4,
   prsnl pr5,
   ap_prefix ap,
   encounter e
  PLAN (d2)
   JOIN (rt
   WHERE parser(
    IF ((request->service_resource_cd > 0))
     " temp->qual[d2.seq].service_resource_cd = rt.service_resource_cd"
    ELSE "0 = 0"
    ENDIF
    )
    AND parser(
    IF ((request->responsible_pathologist_id > 0))
     " request->responsible_pathologist_id = rt.responsible_pathologist_id"
    ELSE "0 = 0"
    ENDIF
    )
    AND parser(
    IF ((request->responsible_resident_id > 0))
     " request->responsible_resident_id = rt.responsible_resident_id"
    ELSE "0 = 0"
    ENDIF
    ))
   JOIN (cr
   WHERE parser(
    IF ((request->execute_flag=0))
     " cr.status_cd not in (verified_cd, corrected_cd, signinproc_cd, csigninproc_cd)"
    ELSEIF ((request->execute_flag=1)) " cr.status_cd not in (verified_cd, corrected_cd)"
    ELSE " cr.status_cd not in (verified_cd, corrected_cd) and completed_cd = cr.status_cd"
    ENDIF
    )
    AND rt.report_id=cr.report_id
    AND cr.cancel_cd IN (0, null))
   JOIN (pc
   WHERE cr.case_id=pc.case_id
    AND pc.reserved_ind IN (0, null)
    AND pc.cancel_cd IN (0, null))
   JOIN (e
   WHERE e.encntr_id=pc.encntr_id)
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   JOIN (prr
   WHERE cr.catalog_cd=prr.catalog_cd
    AND pc.prefix_id=prr.prefix_id)
   JOIN (pr1
   WHERE pc.responsible_pathologist_id=pr1.person_id)
   JOIN (pr2
   WHERE pc.responsible_resident_id=pr2.person_id)
   JOIN (pr3
   WHERE pc.requesting_physician_id=pr3.person_id)
   JOIN (pr4
   WHERE rt.responsible_pathologist_id=pr4.person_id)
   JOIN (pr5
   WHERE rt.responsible_resident_id=pr5.person_id)
   JOIN (ap
   WHERE ap.prefix_id=pc.prefix_id)
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (crc
   WHERE cr.catalog_cd=crc.catalog_cd
    AND 1=prr.primary_ind)
  ORDER BY pc.accession_nbr, pc.case_id, rt.report_id
  HEAD REPORT
   case_cnt = 0, report_cnt = 0, service_resource_cd = 0.0
  HEAD pc.case_id
   report_cnt = 0
  HEAD rt.report_id
   service_resource_cd = rt.service_resource_cd
   IF (isresourceviewable(service_resource_cd)=true)
    IF (report_cnt=0)
     case_cnt += 1
     IF (mod(case_cnt,10)=1
      AND case_cnt != 1)
      stat = alter(reply->case_qual,(case_cnt+ 10))
     ENDIF
     reply->case_qual[case_cnt].accession_nbr = pc.accession_nbr, reply->case_qual[case_cnt].case_id
      = pc.case_id, reply->case_qual[case_cnt].case_type_cd = pc.case_type_cd,
     reply->case_qual[case_cnt].case_year = pc.case_year, reply->case_qual[case_cnt].case_number = pc
     .case_number, reply->case_qual[case_cnt].person_id = pc.person_id,
     reply->case_qual[case_cnt].encntr_id = pc.encntr_id, reply->case_qual[case_cnt].prefix_cd = pc
     .prefix_id, reply->case_qual[case_cnt].case_blob_bitmap = pc.blob_bitmap,
     reply->case_qual[case_cnt].dataset_uid = pc.dataset_uid, reply->case_qual[case_cnt].
     resp_pathologist_id = pc.responsible_pathologist_id, reply->case_qual[case_cnt].resp_resident_id
      = pc.responsible_resident_id,
     reply->case_qual[case_cnt].req_physician_id = pc.requesting_physician_id, reply->case_qual[
     case_cnt].pc_updt_cnt = pc.updt_cnt, reply->case_qual[case_cnt].case_comment_long_text_id = pc
     .comments_long_text_id,
     reply->case_qual[case_cnt].case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm), reply->
     case_qual[case_cnt].case_received_dt_tm = cnvtdatetime(pc.case_received_dt_tm), reply->
     case_qual[case_cnt].resp_pathologist_name = pr1.name_full_formatted,
     reply->case_qual[case_cnt].resp_resident_name = pr2.name_full_formatted, reply->case_qual[
     case_cnt].req_physician_name = pr3.name_full_formatted, reply->case_qual[case_cnt].chr_ind = pc
     .chr_ind,
     reply->case_qual[case_cnt].loc_facility_cd = e.loc_facility_cd, reply->case_qual[case_cnt].
     main_report_complete_dt_tm = cnvtdatetime(pc.main_report_cmplete_dt_tm), reply->case_qual[
     case_cnt].accessioned_dt_tm = pc.accessioned_dt_tm,
     reply->case_qual[case_cnt].accession_prsnl_id = pc.accession_prsnl_id, reply->case_qual[case_cnt
     ].tracking_interface_ind = ap.interface_flag, reply->case_qual[case_cnt].
     tracking_service_resource_cd = ap.tracking_service_resource_cd,
     reply->case_qual[case_cnt].imaging_interface_ind = ap.imaging_interface_ind, reply->case_qual[
     case_cnt].imaging_service_resource_cd = ap.imaging_service_resource_cd
    ENDIF
    report_cnt += 1
    IF (report_cnt > max_report_cnt)
     max_report_cnt = report_cnt
    ENDIF
    stat = alterlist(reply->case_qual[case_cnt].report_qual,report_cnt), reply->case_qual[case_cnt].
    report_qual[report_cnt].report_id = rt.report_id, reply->case_qual[case_cnt].report_qual[
    report_cnt].request_priority_cd = rt.priority_cd,
    reply->case_qual[case_cnt].report_qual[report_cnt].service_resource_cd = rt.service_resource_cd,
    reply->case_qual[case_cnt].report_qual[report_cnt].resp_pathologist_id = rt
    .responsible_pathologist_id, reply->case_qual[case_cnt].report_qual[report_cnt].
    report_comment_long_text_id = rt.comments_long_text_id,
    reply->case_qual[case_cnt].report_qual[report_cnt].resp_pathologist_name = pr4
    .name_full_formatted, reply->case_qual[case_cnt].report_qual[report_cnt].resp_resident_id = rt
    .responsible_resident_id, reply->case_qual[case_cnt].report_qual[report_cnt].resp_resident_name
     = pr5.name_full_formatted,
    reply->case_qual[case_cnt].report_qual[report_cnt].status_cd = cr.status_cd, reply->case_qual[
    case_cnt].report_qual[report_cnt].report_sequence = cr.report_sequence, reply->case_qual[case_cnt
    ].report_qual[report_cnt].catalog_cd = cr.catalog_cd,
    reply->case_qual[case_cnt].report_qual[report_cnt].hold_cd = rt.hold_cd, reply->case_qual[
    case_cnt].report_qual[report_cnt].hold_comment_long_text_id = rt.hold_comment_long_text_id, reply
    ->case_qual[case_cnt].report_qual[report_cnt].updt_cnt = rt.updt_cnt,
    reply->case_qual[case_cnt].report_qual[report_cnt].cr_updt_cnt = cr.updt_cnt, reply->case_qual[
    case_cnt].report_qual[report_cnt].last_edit_dt_tm = cnvtdatetime(rt.last_edit_dt_tm), reply->
    case_qual[case_cnt].report_qual[report_cnt].description = sd.description,
    reply->case_qual[case_cnt].report_qual[report_cnt].short_description = sd.short_description,
    reply->case_qual[case_cnt].report_qual[report_cnt].cyto_report_ind = cyto_rpt, reply->case_qual[
    case_cnt].report_qual[report_cnt].primary_ind = prr.primary_ind
    IF ((reply->case_qual[case_cnt].report_qual[report_cnt].primary_ind=1))
     reply->case_qual[case_cnt].priority_cd = rt.priority_cd
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alter(reply->case_qual,case_cnt)
  WITH outerjoin = d1, nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","REPORT_BY_RESPONSIBILTY:CASE INFORMATION")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id, reply->case_qual[d1.seq].case_id, reply->case_qual[d1.seq].report_qual[d2.seq].
  report_id,
  reply->case_qual[d1.seq].report_qual[d2.seq].hold_comment_long_text_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(reply->case_qual,5))),
   (dummyt d2  WITH seq = value(max_report_cnt))
  PLAN (d1
   WHERE (reply->case_qual[d1.seq].case_id > 0))
   JOIN (d2
   WHERE d2.seq <= size(reply->case_qual[d1.seq].report_qual,5)
    AND (reply->case_qual[d1.seq].report_qual[d2.seq].hold_comment_long_text_id > 0))
   JOIN (lt
   WHERE (reply->case_qual[d1.seq].report_qual[d2.seq].hold_comment_long_text_id=lt.long_text_id))
  DETAIL
   reply->case_qual[d1.seq].report_qual[d2.seq].hold_comment = lt.long_text, reply->case_qual[d1.seq]
   .report_qual[d2.seq].lt_hold_comment_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id, reply->case_qual[d1.seq].case_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(reply->case_qual,5)))
  PLAN (d1
   WHERE (reply->case_qual[d1.seq].case_id > 0)
    AND (reply->case_qual[d1.seq].case_comment_long_text_id > 0))
   JOIN (lt
   WHERE (reply->case_qual[d1.seq].case_comment_long_text_id=lt.long_text_id))
  DETAIL
   reply->case_qual[d1.seq].case_comment = lt.long_text, reply->case_qual[d1.seq].
   lt_case_comment_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id, reply->case_qual[d1.seq].case_id, reply->case_qual[d1.seq].report_qual[d2.seq].
  report_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(reply->case_qual,5))),
   (dummyt d2  WITH seq = value(max_report_cnt))
  PLAN (d1
   WHERE (reply->case_qual[d1.seq].case_id > 0))
   JOIN (d2
   WHERE d2.seq <= size(reply->case_qual[d1.seq].report_qual,5)
    AND (reply->case_qual[d1.seq].report_qual[d2.seq].report_comment_long_text_id > 0))
   JOIN (lt
   WHERE (reply->case_qual[d1.seq].report_qual[d2.seq].report_comment_long_text_id=lt.long_text_id))
  DETAIL
   reply->case_qual[d1.seq].report_qual[d2.seq].report_comment = lt.long_text, reply->case_qual[d1
   .seq].report_qual[d2.seq].lt_report_comment_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d1.seq, p.person_id, ea.alias,
  pr.name_full_formatted, cs.specimen_description, cp.physician_id,
  spec_exists = decode(cs.seq,"Y","N"), join_path = decode(cs.seq,"S",cp.seq,"P"," "), t_tag_group_id
   = decode(t.seq,t.tag_group_id,0.0),
  t_tag_sequence = decode(t.seq,t.tag_sequence,0)
  FROM (dummyt d1  WITH seq = value(size(reply->case_qual,5))),
   person p,
   (dummyt d2  WITH seq = 1),
   case_specimen cs,
   ap_tag t,
   (dummyt d3  WITH seq = 1),
   case_provider cp,
   prsnl pr
  PLAN (d1)
   JOIN (p
   WHERE (reply->case_qual[d1.seq].person_id=p.person_id))
   JOIN (((d2
   WHERE 1=d2.seq)
   JOIN (cs
   WHERE (reply->case_qual[d1.seq].case_id=cs.case_id)
    AND cs.cancel_cd IN (null, 0.0))
   JOIN (t
   WHERE cs.specimen_tag_id=t.tag_id)
   ) ORJOIN ((d3
   WHERE 1=d3.seq)
   JOIN (cp
   WHERE (reply->case_qual[d1.seq].case_id=cp.case_id))
   JOIN (pr
   WHERE cp.physician_id=pr.person_id)
   ))
  ORDER BY d1.seq, t_tag_group_id, t_tag_sequence
  HEAD REPORT
   case_cnt = 0
  HEAD d1.seq
   max_spec_cnt = 5, max_phys_cnt = 5, spec_cnt = 0,
   phys_cnt = 0, stat = alterlist(reply->case_qual[d1.seq].spec_qual,max_spec_cnt), stat = alterlist(
    reply->case_qual[d1.seq].phys_qual,max_phys_cnt),
   reply->case_qual[d1.seq].person_name = p.name_full_formatted, reply->case_qual[d1.seq].sex_cd = p
   .sex_cd, reply->case_qual[d1.seq].age = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"),
   reply->case_qual[d1.seq].birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->case_qual[d1.seq].
   birth_tz = validate(p.birth_tz,0), reply->case_qual[d1.seq].deceased_dt_tm = cnvtdatetime(p
    .deceased_dt_tm)
  DETAIL
   CASE (join_path)
    OF "S":
     spec_cnt += 1,
     IF (spec_cnt > max_spec_cnt)
      stat = alterlist(reply->case_qual[d1.seq].spec_qual,spec_cnt), max_spec_cnt = spec_cnt
     ENDIF
     ,reply->case_qual[d1.seq].spec_qual[spec_cnt].case_specimen_id = cs.case_specimen_id,reply->
     case_qual[d1.seq].spec_qual[spec_cnt].specimen_tag_group_cd = t.tag_group_id,reply->case_qual[d1
     .seq].spec_qual[spec_cnt].specimen_tag_sequence = t.tag_sequence,
     reply->case_qual[d1.seq].spec_qual[spec_cnt].specimen_tag_display = t.tag_disp,reply->case_qual[
     d1.seq].spec_qual[spec_cnt].specimen_tag_cd = cs.specimen_tag_id,reply->case_qual[d1.seq].
     spec_qual[spec_cnt].specimen_description = trim(cs.specimen_description),
     reply->case_qual[d1.seq].spec_qual[spec_cnt].specimen_cd = cs.specimen_cd
    OF "P":
     phys_cnt += 1,
     IF (phys_cnt > max_phys_cnt)
      stat = alterlist(reply->case_qual[d1.seq].phys_qual,phys_cnt), max_phys_cnt = phys_cnt
     ENDIF
     ,reply->case_qual[d1.seq].phys_qual[phys_cnt].physician_id = cp.physician_id,reply->case_qual[d1
     .seq].phys_qual[phys_cnt].physician_name = trim(pr.name_full_formatted)
   ENDCASE
  FOOT  d1.seq
   stat = alterlist(reply->case_qual[d1.seq].spec_qual,spec_cnt), stat = alterlist(reply->case_qual[
    d1.seq].phys_qual,phys_cnt)
  WITH outerjoin = d2, nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","REPORT_BY_RESPONSIBILTY:PATIENT INFORMATION")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
  FROM (dummyt d1  WITH seq = value(size(reply->case_qual,5))),
   encntr_alias ea
  PLAN (d1)
   JOIN (ea
   WHERE (ea.encntr_id=reply->case_qual[d1.seq].encntr_id)
    AND ea.encntr_alias_type_cd IN (mrn_alias_type_cd, fin_alias_type_cd)
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   CASE (ea.encntr_alias_type_cd)
    OF mrn_alias_type_cd:
     reply->case_qual[d1.seq].person_num = frmt_mrn,reply->case_qual[d1.seq].person_unformat_mrn = ea
     .alias
    OF fin_alias_type_cd:
     reply->case_qual[d1.seq].person_fin = ea.alias
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  unfrmt_cmrn = pa.alias
  FROM (dummyt d1  WITH seq = value(size(reply->case_qual,5))),
   person_alias pa
  PLAN (d1)
   JOIN (pa
   WHERE (pa.person_id=reply->case_qual[d1.seq].person_id)
    AND pa.person_alias_type_cd=cmrn_alias_type_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   reply->case_qual[d1.seq].person_unformat_cmrn = unfrmt_cmrn
  WITH nocounter
 ;end select
 EXECUTE aps_get_omf_flags
 SELECT INTO "nl:"
  FROM code_value_group cvr,
   (dummyt d1  WITH seq = value(size(reply->case_qual,5)))
  PLAN (d1
   WHERE (reply->case_qual[d1.seq].tracking_service_resource_cd > 0)
    AND (reply->case_qual[d1.seq].tracking_interface_ind > 0))
   JOIN (cvr
   WHERE (cvr.child_code_value=reply->case_qual[d1.seq].tracking_service_resource_cd)
    AND  EXISTS (
   (SELECT
    cve.field_value
    FROM code_value_extension cve
    WHERE cve.code_value=cvr.parent_code_value
     AND cve.field_name="SEND_UPDATES_AS_NEW"
     AND cve.code_set=2074
     AND cve.field_value="1")))
  DETAIL
   reply->case_qual[d1.seq].tracking_send_updates_as_new = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value_group cvr,
   (dummyt d1  WITH seq = value(size(reply->case_qual,5)))
  PLAN (d1
   WHERE (reply->case_qual[d1.seq].imaging_service_resource_cd > 0)
    AND (reply->case_qual[d1.seq].imaging_interface_ind > 0))
   JOIN (cvr
   WHERE (cvr.child_code_value=reply->case_qual[d1.seq].imaging_service_resource_cd)
    AND  EXISTS (
   (SELECT
    cve.field_value
    FROM code_value_extension cve
    WHERE cve.code_value=cvr.parent_code_value
     AND cve.field_name="SEND_UPDATES_AS_NEW"
     AND cve.code_set=2074
     AND cve.field_value="1")))
  DETAIL
   reply->case_qual[d1.seq].imaging_send_updates_as_new = 1
  WITH nocounter
 ;end select
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
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(reply->case_qual,5))),
   ap_digital_slide ads,
   ap_digital_slide_info adsf
  PLAN (d1
   WHERE (reply->case_qual[d1.seq].case_id > 0))
   JOIN (ads
   WHERE (ads.case_id=reply->case_qual[d1.seq].case_id)
    AND ads.slide_id=0
    AND ads.active_ind=1)
   JOIN (adsf
   WHERE adsf.ap_digital_slide_id=ads.ap_digital_slide_id
    AND adsf.active_ind=1
    AND adsf.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND adsf.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND adsf.url_elem_type_tflg="identifier")
  ORDER BY d1.seq
  HEAD d1.seq
   reply->case_qual[d1.seq].case_digital_img_identifier = adsf.url_elem_string_txt
  WITH nocounter
 ;end select
#exit_script
END GO
