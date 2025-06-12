CREATE PROGRAM aps_get_valid_case:dba
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
   1 case_id = f8
   1 accession_nbr = c21
   1 blob_bitmap = i4
   1 prefix_cd = f8
   1 case_year = i4
   1 case_number = i4
   1 encounter_id = f8
   1 case_collect_dt_tm = dq8
   1 physician_name = vc
   1 admit_doc = vc
   1 person_id = f8
   1 person_name = vc
   1 person_num = c16
   1 sex_cd = f8
   1 sex_disp = c40
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 deceased_dt_tm = dq8
   1 age = vc
   1 responsible_pathologist_id = f8
   1 responsible_pathologist_name = c100
   1 responsible_resident_id = f8
   1 responsible_resident_name = c100
   1 case_long_text_id = f8
   1 case_comments = vc
   1 case_lt_updt_cnt = i4
   1 spec_cnt = i2
   1 spec_qual[*]
     2 case_specimen_id = f8
     2 specimen_tag_group_cd = f8
     2 specimen_tag_cd = f8
     2 specimen_description = vc
     2 specimen_tag_display = c7
     2 specimen_tag_sequence = i4
     2 specimen_cd = f8
     2 specimen_disp = c40
     2 specimen_collect_dt_tm = dq8
     2 specimen_status_cd = f8
     2 specimen_status_disp = c40
     2 specimen_status_dt_tm = dq8
     2 specimen_status_prsnl_id = f8
     2 specimen_status_username = vc
     2 specimen_fixative_cd = f8
     2 specimen_fixative_disp = c40
     2 specimen_priority_cd = f8
     2 specimen_priority_disp = c40
     2 specimen_serv_resource_cd = f8
     2 specimen_serv_resource_disp = c40
     2 specimen_serv_resource_desc = vc
     2 specimen_task_assay_cd = f8
     2 specimen_task_assay_disp = c40
     2 order_id = f8
     2 updt_cnt = i4
     2 order_long_text_id = f8
     2 order_comments = vc
     2 order_lt_updt_cnt = i4
     2 request_dt_tm = dq8
     2 request_prsnl_id = f8
     2 request_prsnl_name = vc
     2 hold_cd = f8
     2 hold_disp = vc
     2 cancel_cd = f8
     2 cancel_disp = vc
     2 billing_processing_flag = i2
     2 content_status_cd = f8
     2 content_status_mean = c12
     2 specimen_received_dt_tm = dq8
     2 adequacy_reason_cd = f8
     2 adequacy_reason_disp = c40
     2 spec_comments_long_text_id = f8
     2 specimen_comments = vc
   1 rpt_qual[*]
     2 report_id = f8
     2 blob_bitmap = i4
     2 catalog_cd = f8
     2 report_priority_cd = f8
     2 report_priority_disp = c40
     2 report_primary_ind = i2
     2 status_cd = f8
     2 status_disp = vc
     2 status_mean = vc
   1 interface_flag = i2
   1 service_resource_cd = f8
   1 case_type_cd = f8
   1 accessioned_dt_tm = dq8
   1 accession_prsnl_id = f8
   1 physician_id = f8
   1 interface_send_updates_as_new = i2
   1 tracking_service_resource_cd = f8
   1 imaging_interface_ind = i2
   1 imaging_service_resource_cd = f8
   1 imaging_send_updates_as_new = i2
   1 tracking_send_slide_from_spec = i2
   1 admitting_physician_id = f8
   1 attending_physician_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE verified_flag = i2 WITH protect, noconstant(0)
 DECLARE lspecpos = i4 WITH protect, noconstant(0)
 DECLARE llocindex = i4 WITH protect, noconstant(0)
 DECLARE lexpandidx = i4 WITH protect, noconstant(0)
 DECLARE ddiscarded_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",2061,"DISCARDED"))
 DECLARE mrn_alias_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE verified_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1305,"VERIFIED"))
 DECLARE epr_attend_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE epr_admit_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 SET reply->status_data.status = "F"
 SET spec_cnt = 0
 SET max_spec_cnt = 5
 SET rpt_cnt = 0
 SET max_rpt_cnt = 5
 SET canceled_where = fillstring(100," ")
 CALL initresourcesecurity(1)
 IF (validate(request->bshowcanceled,0)=0)
  SET canceled_where = "cs.cancel_cd in (NULL, 0)"
 ELSE
  SET canceled_where = "0 = 0"
 ENDIF
 SELECT INTO "nl:"
  join_path = decode(epr.seq,"E",cs.seq,"S",cr.seq,
   "R"," "), pc.case_id, pc.person_id,
  p.person_id, cr.report_id, cs.case_id,
  t.tag_id, p1.person_id, epr.prsnl_person_id,
  p2.person_id, pr2.name_full_formatted, pr3.name_full_formatted,
  pt_exists = decode(pt.seq,1,0), rt_exists = decode(rt.seq,"Y","N")
  FROM pathology_case pc,
   case_specimen cs,
   case_report cr,
   processing_task pt,
   person p,
   prsnl p1,
   ap_prefix ap,
   prsnl pr2,
   prsnl pr3,
   ap_tag t,
   encntr_prsnl_reltn epr,
   prsnl p2,
   report_task rt,
   prefix_report_r prr,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   (dummyt d5  WITH seq = 1)
  PLAN (pc
   WHERE (request->accession_nbr=pc.accession_nbr)
    AND pc.cancel_cd IN (null, 0)
    AND pc.reserved_ind != 1
    AND ((validate(request->include_history_ind,0)=1) OR (pc.origin_flag != 1)) )
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (pr2
   WHERE pc.responsible_pathologist_id=pr2.person_id)
   JOIN (pr3
   WHERE pc.responsible_resident_id=pr3.person_id)
   JOIN (p1
   WHERE pc.requesting_physician_id=p1.person_id)
   JOIN (ap
   WHERE ap.prefix_id=pc.prefix_id)
   JOIN (((d2
   WHERE d2.seq=1)
   JOIN (epr
   WHERE epr.encntr_id=pc.encntr_id
    AND epr.encntr_prsnl_r_cd IN (epr_admit_doc_cd, epr_attend_doc_cd)
    AND epr.active_ind=1
    AND epr.manual_create_ind IN (0, null)
    AND epr.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p2
   WHERE p2.person_id=epr.prsnl_person_id)
   ) ORJOIN ((((d1
   WHERE d1.seq=1)
   JOIN (cs
   WHERE pc.case_id=cs.case_id
    AND parser(canceled_where))
   JOIN (t
   WHERE cs.specimen_tag_id=t.tag_id)
   JOIN (d3
   WHERE 1=d3.seq)
   JOIN (pt
   WHERE cs.case_specimen_id=pt.case_specimen_id)
   ) ORJOIN ((d4
   WHERE d4.seq=1)
   JOIN (cr
   WHERE pc.case_id=cr.case_id
    AND cr.cancel_cd IN (null, 0))
   JOIN (prr
   WHERE pc.prefix_id=prr.prefix_id
    AND cr.catalog_cd=prr.catalog_cd)
   JOIN (d5
   WHERE 1=d5.seq)
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
   )) ))
  ORDER BY t.tag_group_id, t.tag_sequence
  HEAD REPORT
   service_resource_cd = ap.service_resource_cd, access_to_resource_ind = 0
   IF (isresourceviewable(service_resource_cd)=true)
    access_to_resource_ind = 1, reply->case_id = pc.case_id, reply->accession_nbr = pc.accession_nbr,
    reply->blob_bitmap = pc.blob_bitmap, reply->prefix_cd = pc.prefix_id, reply->case_year = pc
    .case_year,
    reply->case_number = pc.case_number, reply->encounter_id = pc.encntr_id, reply->case_long_text_id
     = pc.comments_long_text_id,
    reply->case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm), reply->accessioned_dt_tm = pc
    .accessioned_dt_tm, reply->accession_prsnl_id = pc.accession_prsnl_id,
    reply->physician_name = p1.name_full_formatted, reply->physician_id = p1.person_id, reply->
    person_id = p.person_id,
    reply->person_name = p.name_full_formatted, reply->sex_cd = p.sex_cd, reply->age = formatage(p
     .birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"),
    reply->birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->birth_tz = validate(p.birth_tz,0), reply
    ->deceased_dt_tm = cnvtdatetime(p.deceased_dt_tm),
    reply->physician_name = p1.name_full_formatted, reply->responsible_pathologist_id = pc
    .responsible_pathologist_id, reply->responsible_pathologist_name = pr2.name_full_formatted,
    reply->responsible_resident_id = pc.responsible_resident_id, reply->responsible_resident_name =
    pr3.name_full_formatted, reply->interface_flag = ap.interface_flag,
    reply->service_resource_cd = ap.service_resource_cd, reply->case_type_cd = ap.case_type_cd, reply
    ->tracking_service_resource_cd = ap.tracking_service_resource_cd,
    reply->imaging_interface_ind = ap.imaging_interface_ind, reply->imaging_service_resource_cd = ap
    .imaging_service_resource_cd, spec_cnt = 0,
    max_spec_cnt = 5, stat = alterlist(reply->spec_qual,max_spec_cnt), rpt_cnt = 0,
    max_rpt_cnt = 5, stat = alterlist(reply->rpt_qual,max_rpt_cnt)
   ENDIF
  HEAD t.tag_sequence
   verified_flag = 0
   IF (access_to_resource_ind=1)
    IF (join_path="S")
     spec_cnt += 1
     IF (spec_cnt > max_spec_cnt)
      stat = alterlist(reply->spec_qual,spec_cnt), max_spec_cnt = spec_cnt
     ENDIF
     reply->spec_qual[spec_cnt].case_specimen_id = cs.case_specimen_id, reply->spec_qual[spec_cnt].
     specimen_tag_group_cd = t.tag_group_id, reply->spec_qual[spec_cnt].specimen_tag_sequence = t
     .tag_sequence,
     reply->spec_qual[spec_cnt].specimen_tag_cd = cs.specimen_tag_id, reply->spec_qual[spec_cnt].
     specimen_description = trim(cs.specimen_description), reply->spec_qual[spec_cnt].
     specimen_tag_display = t.tag_disp,
     reply->spec_qual[spec_cnt].specimen_cd = cs.specimen_cd, reply->spec_qual[spec_cnt].
     specimen_collect_dt_tm = cs.collect_dt_tm, reply->spec_qual[spec_cnt].specimen_fixative_cd = cs
     .received_fixative_cd,
     reply->spec_qual[spec_cnt].billing_processing_flag = 0, reply->spec_qual[spec_cnt].
     specimen_received_dt_tm = cs.received_dt_tm, reply->spec_qual[spec_cnt].adequacy_reason_cd = cs
     .inadequacy_reason_cd,
     reply->spec_qual[spec_cnt].spec_comments_long_text_id = cs.spec_comments_long_text_id
    ENDIF
   ENDIF
  DETAIL
   IF (access_to_resource_ind=1)
    CASE (join_path)
     OF "E":
      reply->admit_doc = p2.name_full_formatted,
      IF (epr.encntr_prsnl_r_cd=epr_admit_doc_cd)
       reply->admitting_physician_id = p2.person_id
      ELSE
       reply->attending_physician_id = p2.person_id
      ENDIF
     OF "R":
      rpt_cnt += 1,
      IF (rpt_cnt > max_rpt_cnt)
       stat = alterlist(reply->rpt_qual,rpt_cnt), max_rpt_cnt = rpt_cnt
      ENDIF
      ,reply->rpt_qual[rpt_cnt].report_id = cr.report_id,reply->rpt_qual[rpt_cnt].blob_bitmap = cr
      .blob_bitmap,reply->rpt_qual[rpt_cnt].catalog_cd = cr.catalog_cd,
      reply->rpt_qual[rpt_cnt].report_primary_ind = prr.primary_ind,
      IF (rt_exists="Y")
       reply->rpt_qual[rpt_cnt].report_priority_cd = rt.priority_cd
      ENDIF
      ,reply->rpt_qual[rpt_cnt].status_cd = cr.status_cd
     OF "S":
      IF (pt_exists=1)
       IF (pt.create_inventory_flag=4)
        reply->spec_qual[spec_cnt].specimen_task_assay_cd = pt.task_assay_cd, reply->spec_qual[
        spec_cnt].specimen_priority_cd = pt.priority_cd, reply->spec_qual[spec_cnt].
        specimen_serv_resource_cd = pt.service_resource_cd,
        reply->spec_qual[spec_cnt].specimen_status_cd = pt.status_cd, reply->spec_qual[spec_cnt].
        order_id = pt.order_id, reply->spec_qual[spec_cnt].updt_cnt = pt.updt_cnt,
        reply->spec_qual[spec_cnt].order_long_text_id = pt.comments_long_text_id, reply->spec_qual[
        spec_cnt].request_dt_tm = pt.request_dt_tm, reply->spec_qual[spec_cnt].request_prsnl_id = pt
        .request_prsnl_id,
        reply->spec_qual[spec_cnt].specimen_status_dt_tm = pt.status_dt_tm, reply->spec_qual[spec_cnt
        ].specimen_status_prsnl_id = pt.status_prsnl_id, reply->spec_qual[spec_cnt].hold_cd = pt
        .hold_cd,
        reply->spec_qual[spec_cnt].cancel_cd = pt.cancel_cd
       ELSE
        reply->spec_qual[spec_cnt].billing_processing_flag = 1
       ENDIF
       IF (cs.original_storage_dt_tm != null
        AND cs.discard_dt_tm != null)
        reply->spec_qual[spec_cnt].content_status_cd = ddiscarded_cd, reply->spec_qual[spec_cnt].
        content_status_mean = "DISCARDED"
       ENDIF
      ELSE
       verified_flag = 1
      ENDIF
    ENDCASE
   ENDIF
  FOOT  t.tag_sequence
   IF (access_to_resource_ind=1)
    IF (verified_flag=1)
     reply->spec_qual[spec_cnt].specimen_status_cd = verified_status_cd
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->spec_qual,spec_cnt), stat = alterlist(reply->rpt_qual,rpt_cnt)
  WITH nocounter, outerjoin = d2, outerjoin = d3,
   outerjoin = d5
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(1)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (spec_cnt > 0)
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM prsnl p,
    (dummyt d1  WITH seq = value(spec_cnt))
   PLAN (d1
    WHERE (reply->spec_qual[d1.seq].request_prsnl_id > 0))
    JOIN (p
    WHERE (reply->spec_qual[d1.seq].request_prsnl_id=p.person_id))
   DETAIL
    reply->spec_qual[d1.seq].request_prsnl_name = p.name_full_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM prsnl p,
    (dummyt d1  WITH seq = value(spec_cnt))
   PLAN (d1
    WHERE (reply->spec_qual[d1.seq].specimen_status_prsnl_id > 0))
    JOIN (p
    WHERE (reply->spec_qual[d1.seq].specimen_status_prsnl_id=p.person_id))
   DETAIL
    reply->spec_qual[d1.seq].specimen_status_username = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  pc.person_id, frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.encntr_alias_type_cd
  FROM pathology_case pc,
   encntr_alias ea
  PLAN (pc
   WHERE (request->accession_nbr=pc.accession_nbr)
    AND pc.cancel_cd IN (null, 0)
    AND pc.reserved_ind != 1
    AND pc.origin_flag != 1)
   JOIN (ea
   WHERE ea.encntr_id=pc.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   reply->person_num = frmt_mrn
  WITH nocounter
 ;end select
 IF (spec_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(spec_cnt)),
    long_text lt
   PLAN (d1
    WHERE (reply->spec_qual[d1.seq].order_long_text_id > 0))
    JOIN (lt
    WHERE (reply->spec_qual[d1.seq].order_long_text_id=lt.long_text_id))
   DETAIL
    reply->spec_qual[d1.seq].order_comments = lt.long_text, reply->spec_qual[d1.seq].
    order_lt_updt_cnt = lt.updt_cnt
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->case_long_text_id > 0))
  SELECT INTO "nl:"
   lt.long_text_id
   FROM long_text lt
   WHERE (lt.long_text_id=reply->case_long_text_id)
    AND (lt.parent_entity_id=reply->case_id)
    AND lt.parent_entity_name="PATHOLOGY_CASE"
   DETAIL
    reply->case_lt_updt_cnt = lt.updt_cnt, reply->case_comments = trim(lt.long_text)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(reply->spec_qual,5)))
  PLAN (d1
   WHERE (reply->spec_qual[d1.seq].spec_comments_long_text_id > 0))
   JOIN (lt
   WHERE (lt.long_text_id=reply->spec_qual[d1.seq].spec_comments_long_text_id)
    AND lt.parent_entity_name="CASE_SPECIMEN"
    AND (lt.parent_entity_id=reply->spec_qual[d1.seq].case_specimen_id))
  DETAIL
   reply->spec_qual[d1.seq].specimen_comments = trim(lt.long_text)
  WITH nocounter
 ;end select
 SET reply->spec_cnt = size(reply->spec_qual,5)
 IF ((reply->spec_cnt > 0))
  SELECT INTO "nl:"
   FROM storage_content sc
   PLAN (sc
    WHERE expand(lexpandidx,1,reply->spec_cnt,sc.content_table_id,reply->spec_qual[lexpandidx].
     case_specimen_id,
     0.0,reply->spec_qual[lexpandidx].content_status_cd)
     AND sc.content_table_name="CASE_SPECIMEN")
   DETAIL
    lspecpos = locateval(llocindex,1,reply->spec_cnt,sc.content_table_id,reply->spec_qual[llocindex].
     case_specimen_id), reply->spec_qual[lspecpos].content_status_cd = sc.content_status_cd, reply->
    spec_qual[lspecpos].content_status_mean = uar_get_code_meaning(sc.content_status_cd)
   WITH nocounter
  ;end select
 ENDIF
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
END GO
