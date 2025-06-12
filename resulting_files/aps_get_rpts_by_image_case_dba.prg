CREATE PROGRAM aps_get_rpts_by_image_case:dba
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
   1 case_type_cd = f8
   1 case_type_disp = c40
   1 case_type_desc = vc
   1 case_type_mean = c12
   1 event_id = f8
   1 encntr_id = f8
   1 prefix_cd = f8
   1 accession_nbr = c18
   1 case_collect_dt_tm = dq8
   1 case_received_dt_tm = dq8
   1 person_id = f8
   1 person_name = vc
   1 person_num = c16
   1 resp_pathologist_id = f8
   1 resp_pathologist_name = vc
   1 resp_resident_id = f8
   1 resp_resident_name = vc
   1 req_physician_id = f8
   1 req_physician_name = vc
   1 sex_cd = f8
   1 sex_disp = c40
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 deceased_dt_tm = dq8
   1 age = vc
   1 updt_cnt = i4
   1 chr_ind = i2
   1 blob_bitmap = i4
   1 dataset_uid = vc
   1 rpt_qual[*]
     2 report_id = f8
     2 report_sequence = i4
     2 catalog_cd = f8
     2 description = vc
     2 short_description = c50
     2 hold_cd = f8
     2 hold_disp = c40
     2 hold_comment = vc
     2 hold_comment_long_text_id = f8
     2 primary_ind = i2
     2 status_cd = f8
     2 status_disp = c40
     2 status_mean = c12
     2 cyto_report_ind = i4
     2 updt_cnt = i4
     2 cr_updt_cnt = i4
     2 blob_bitmap = i4
     2 def_station_rpt_ind = i2
     2 event_id = f8
     2 dept_blob_bitmap = i4
   1 spec_qual[*]
     2 case_specimen_id = f8
     2 specimen_tag_group_cd = f8
     2 specimen_tag_cd = f8
     2 specimen_tag_display = c7
     2 specimen_tag_sequence = i4
     2 specimen_description = vc
     2 specimen_cd = f8
     2 specimen_disp = c40
   1 phys_qual[*]
     2 physician_id = f8
     2 physician_name = vc
   1 person_unformat_mrn = vc
   1 person_unformat_cmrn = vc
   1 person_fin = vc
   1 case_digital_img_identifier = vc
   1 rpt_info_qual[*]
     2 case_event_cd = f8
     2 case_event_id = f8
     2 case_updt_cnt = i4
     2 event_id = f8
     2 report_id = f8
     2 catalog_cd = f8
     2 event_cd = f8
     2 order_id = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 hold_cd = f8
     2 hold_disp = c40
     2 hold_comment = vc
     2 hold_comment_long_text_id = f8
     2 hold_comment_lt_updt_cnt = i4
     2 status_cd = f8
     2 status_disp = c40
     2 status_desc = vc
     2 status_mean = c12
     2 comments = vc
     2 comments_long_text_id = f8
     2 comments_updt_cnt = i4
     2 cancel_cd = f8
     2 cancel_disp = c40
     2 last_edit_dt_tm = dq8
     2 responsible_pathologist_id = f8
     2 responsible_pathologist_name = vc
     2 responsible_resident_id = f8
     2 responsible_resident_name = vc
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 blob_bitmap = i4
     2 dept_blob_bitmap = i4
     2 images_read_only_ind = i2
     2 updt_cnt = i4
     2 cr_updt_cnt = i4
     2 synoptic_stale_ind = i2
     2 synoptic_stale_dt_tm = dq8
     2 synoptic_worksheets_allowed_ind = i2
     2 synoptic_incomplete_ind = i2
     2 synoptic_results_exist_ind = i2
     2 section_qual[*]
       3 event_id = f8
       3 hist_act_cd = f8
       3 status_cd = f8
       3 status_disp = c40
       3 required_ind = i2
       3 modified_ind = i2
       3 task_assay_cd = f8
       3 task_assay_disp = c40
       3 task_assay_desc = vc
       3 event_cd = f8
       3 section_sequence = i4
       3 result_type_cd = f8
       3 result_type_disp = c40
       3 result_type_desc = vc
       3 result_type_mean = c12
       3 sign_line_ind = i2
       3 updt_cnt = i4
       3 prompt_rtf_text = vc
       3 report_detail_id = f8
       3 image_qual[*]
         4 blob_ref_id = f8
         4 sequence_nbr = i4
         4 owner_cd = f8
         4 storage_cd = f8
         4 format_cd = f8
         4 blob_handle = vc
         4 blob_title = vc
         4 tbnl_long_blob_id = f8
         4 tbnl_format_cd = f8
         4 long_blob = vgc
         4 create_prsnl_id = f8
         4 create_prsnl_name = vc
         4 source_device_cd = f8
         4 source_device_disp = c40
         4 chartable_note = vc
         4 chartable_note_id = f8
         4 chartable_note_updt_cnt = i4
         4 non_chartable_note = vc
         4 non_chartable_note_id = f8
         4 non_chartable_note_updt_cnt = i4
         4 publish_flag = i2
         4 valid_from_dt_tm = dq8
         4 updt_id = f8
         4 updt_cnt = i4
         4 blob_foreign_ident = vc
     2 screen_qual[*]
       3 sequence = i4
       3 screener_id = f8
       3 screener_name = vc
       3 screen_dt_tm = dq8
       3 verify_ind = i2
       3 review_reason_flag = i4
       3 initial_screener_ind = i2
       3 reference_range_factor_id = f8
       3 nomenclature_id = f8
       3 diagnostic_category_cd = f8
       3 endocerv_ind = i2
       3 adequacy_flag = i2
       3 standard_rpt_id = f8
       3 standard_rpt_desc = c40
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 updt_cnt = i4
     2 lock_username = vc
     2 lock_dt_tm = dq8
     2 image_qual[*]
       3 blob_ref_id = f8
       3 sequence_nbr = i4
       3 owner_cd = f8
       3 storage_cd = f8
       3 format_cd = f8
       3 blob_handle = vc
       3 blob_title = vc
       3 tbnl_long_blob_id = f8
       3 tbnl_format_cd = f8
       3 long_blob = vgc
       3 create_prsnl_id = f8
       3 create_prsnl_name = vc
       3 source_device_cd = f8
       3 source_device_disp = c40
       3 chartable_note = vc
       3 chartable_note_id = f8
       3 chartable_note_updt_cnt = i4
       3 non_chartable_note = vc
       3 non_chartable_note_id = f8
       3 non_chartable_note_updt_cnt = i4
       3 publish_flag = i2
       3 valid_from_dt_tm = dq8
       3 updt_id = f8
       3 updt_cnt = i4
       3 blob_foreign_ident = vc
     2 case_reports_blob_bitmap = i4
   1 report_status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD case_event(
   1 accession_nbr = c20
   1 event_id = f8
 )
 DECLARE n_doc_images = i2 WITH protect, constant(2)
 DECLARE correctinit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE correctinprc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET n_images = 1
 SET reply->status_data.status = "F"
 SET reply->report_status = "N"
 SET max_rpt_cnt = 5
 SET max_spec_cnt = 5
 SET max_phys_cnt = 5
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET cmrn_alias_type_cd = 0.0
 SET fin_alias_type_cd = 0.0
 SET rpt_cnt = 0
 SET spec_cnt = 0
 SET phys_cnt = 0
 SET verified_cd = 0.0
 SET cancelled_cd = 0.0
 SET corrected_cd = 0.0
 SET signinproc_cd = 0.0
 SET csigninproc_cd = 0.0
 SET reportindex = 0
 SET bfound = 0
 IF ((request->skip_resource_security_ind=0))
  CALL initresourcesecurity(1)
 ELSE
  CALL initresourcesecurity(0)
 ENDIF
 SET verified_cd = uar_get_code_by("MEANING",1305,"VERIFIED")
 SET cancelled_cd = uar_get_code_by("MEANING",1305,"CANCEL")
 SET corrected_cd = uar_get_code_by("MEANING",1305,"CORRECTED")
 SET signinproc_cd = uar_get_code_by("MEANING",1305,"SIGNINPROC")
 SET csigninproc_cd = uar_get_code_by("MEANING",1305,"CSIGNINPROC")
 SET correctinit_cd = uar_get_code_by("MEANING",1305,"CORRECTINIT")
 SET correctinprc_cd = uar_get_code_by("MEANING",1305,"CORRECTINPRC")
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SET stat = uar_get_meaning_by_codeset(4,"CMRN",1,cmrn_alias_type_cd)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_alias_type_cd)
 SELECT INTO "nl:"
  join_path = decode(cr.seq,"R",cs.seq,"S",cp.seq,
   "P"," "), t_tag_group_id = decode(t.seq,t.tag_group_id,0.0), t_tag_sequence = decode(t.seq,t
   .tag_sequence,0),
  pc.case_id, p.person_id, cr.report_sequence,
  crc.catalog_cd, sd.short_description, cs.specimen_description,
  pr1.name_full_formatted
  FROM pathology_case pc,
   (dummyt d4  WITH seq = 1),
   person p,
   (dummyt d1  WITH seq = 1),
   case_report cr,
   (dummyt d6  WITH seq = 1),
   cyto_report_control crc,
   service_directory sd,
   prefix_report_r prr,
   (dummyt d3  WITH seq = 1),
   case_specimen cs,
   ap_tag t,
   (dummyt d2  WITH seq = 1),
   case_provider cp,
   prsnl pr1,
   prsnl pr2,
   prsnl pr3,
   prsnl pr4,
   ap_prefix ap
  PLAN (pc
   WHERE (request->accession_nbr=pc.accession_nbr)
    AND pc.reserved_ind IN (0, null)
    AND pc.cancel_cd IN (0, null))
   JOIN (pr4
   WHERE pc.requesting_physician_id=pr4.person_id)
   JOIN (pr2
   WHERE pc.responsible_pathologist_id=pr2.person_id)
   JOIN (pr3
   WHERE pc.responsible_resident_id=pr3.person_id)
   JOIN (ap
   WHERE ap.prefix_id=pc.prefix_id)
   JOIN (d4
   WHERE 1=d4.seq)
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (cr
   WHERE pc.case_id=cr.case_id)
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   JOIN (prr
   WHERE cr.catalog_cd=prr.catalog_cd
    AND pc.prefix_id=prr.prefix_id)
   JOIN (d6
   WHERE 1=d6.seq)
   JOIN (crc
   WHERE cr.catalog_cd=crc.catalog_cd
    AND prr.primary_ind=1)
   ) ORJOIN ((((d2
   WHERE 1=d2.seq)
   JOIN (cs
   WHERE pc.case_id=cs.case_id
    AND cs.cancel_cd IN (null, 0.0))
   JOIN (t
   WHERE cs.specimen_tag_id=t.tag_id)
   ) ORJOIN ((d3
   WHERE 1=d3.seq)
   JOIN (cp
   WHERE pc.case_id=cp.case_id)
   JOIN (pr1
   WHERE cp.physician_id=pr1.person_id)
   )) ))
  ORDER BY prr.reporting_sequence, cr.report_sequence, t_tag_group_id,
   t_tag_sequence
  HEAD REPORT
   service_resource_cd = ap.service_resource_cd, access_to_resource_ind = 0
   IF (isresourceviewable(service_resource_cd)=true)
    access_to_resource_ind = 1, stat = alterlist(reply->rpt_qual,max_rpt_cnt), stat = alterlist(reply
     ->spec_qual,max_spec_cnt),
    stat = alterlist(reply->phys_qual,max_phys_cnt), reply->case_id = pc.case_id, reply->case_type_cd
     = pc.case_type_cd,
    reply->encntr_id = pc.encntr_id, reply->prefix_cd = pc.prefix_id, reply->blob_bitmap = pc
    .blob_bitmap,
    reply->dataset_uid = pc.dataset_uid, reply->accession_nbr = pc.accession_nbr, reply->
    resp_pathologist_id = pc.responsible_pathologist_id,
    reply->resp_pathologist_name = pr2.name_full_formatted, reply->resp_resident_id = pc
    .responsible_resident_id, reply->resp_resident_name = pr3.name_full_formatted,
    reply->req_physician_id = pc.requesting_physician_id, reply->req_physician_name = pr4
    .name_full_formatted, reply->case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm),
    reply->case_received_dt_tm = cnvtdatetime(pc.case_received_dt_tm), reply->updt_cnt = pc.updt_cnt,
    reply->person_id = p.person_id,
    reply->person_name = p.name_full_formatted, reply->sex_cd = p.sex_cd, reply->age = formatage(p
     .birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"),
    reply->birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->birth_tz = validate(p.birth_tz,0), reply
    ->deceased_dt_tm = cnvtdatetime(p.deceased_dt_tm),
    reply->chr_ind = pc.chr_ind
   ENDIF
  DETAIL
   IF (access_to_resource_ind=1)
    CASE (join_path)
     OF "R":
      rpt_cnt += 1,
      IF (rpt_cnt > max_rpt_cnt)
       stat = alterlist(reply->rpt_qual,rpt_cnt), max_rpt_cnt = rpt_cnt
      ENDIF
      ,reply->rpt_qual[rpt_cnt].report_id = cr.report_id,reply->rpt_qual[rpt_cnt].report_sequence =
      cr.report_sequence,reply->rpt_qual[rpt_cnt].status_cd = cr.status_cd,
      reply->rpt_qual[rpt_cnt].primary_ind = prr.primary_ind,reply->rpt_qual[rpt_cnt].catalog_cd = cr
      .catalog_cd,reply->rpt_qual[rpt_cnt].description = sd.description,
      reply->rpt_qual[rpt_cnt].short_description = sd.short_description,reply->rpt_qual[rpt_cnt].
      event_id = cr.event_id,
      CASE (reply->rpt_qual[reportindex].status_cd)
       OF cancelled_cd:
        reply->rpt_qual[rpt_cnt].blob_bitmap = 0,reply->rpt_qual[rpt_cnt].dept_blob_bitmap = 0
       OF verified_cd:
       OF corrected_cd:
        reply->rpt_qual[rpt_cnt].blob_bitmap = cr.blob_bitmap,reply->rpt_qual[rpt_cnt].
        dept_blob_bitmap = 0
       OF correctinit_cd:
       OF correctinprc_cd:
        reply->rpt_qual[rpt_cnt].blob_bitmap = cr.blob_bitmap,reply->rpt_qual[rpt_cnt].
        dept_blob_bitmap = n_images
       ELSE
        reply->rpt_qual[rpt_cnt].blob_bitmap = cr.blob_bitmap,reply->rpt_qual[rpt_cnt].
        dept_blob_bitmap = bor(n_doc_images,n_images)
      ENDCASE
      ,
      IF (crc.catalog_cd > 0)
       reply->rpt_qual[rpt_cnt].cyto_report_ind = 1
      ELSE
       reply->rpt_qual[rpt_cnt].cyto_report_ind = 0
      ENDIF
      ,reply->rpt_qual[rpt_cnt].cr_updt_cnt = cr.updt_cnt
     OF "S":
      spec_cnt += 1,
      IF (spec_cnt > max_spec_cnt)
       stat = alterlist(reply->spec_qual,spec_cnt), max_spec_cnt = spec_cnt
      ENDIF
      ,reply->spec_qual[spec_cnt].case_specimen_id = cs.case_specimen_id,reply->spec_qual[spec_cnt].
      specimen_tag_group_cd = t.tag_group_id,reply->spec_qual[spec_cnt].specimen_tag_sequence = t
      .tag_sequence,
      reply->spec_qual[spec_cnt].specimen_tag_display = t.tag_disp,reply->spec_qual[spec_cnt].
      specimen_tag_cd = cs.specimen_tag_id,reply->spec_qual[spec_cnt].specimen_description = trim(cs
       .specimen_description),
      reply->spec_qual[spec_cnt].specimen_cd = cs.specimen_cd
     OF "P":
      phys_cnt += 1,
      IF (phys_cnt > max_phys_cnt)
       stat = alterlist(reply->phys_qual,phys_cnt), max_phys_cnt = phys_cnt
      ENDIF
      ,reply->phys_qual[phys_cnt].physician_id = cp.physician_id,reply->phys_qual[phys_cnt].
      physician_name = trim(pr1.name_full_formatted)
    ENDCASE
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rpt_qual,rpt_cnt), stat = alterlist(reply->spec_qual,spec_cnt), stat =
   alterlist(reply->phys_qual,phys_cnt)
  WITH outerjoin = d4, outerjoin = d6, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Unable to retrieve case information."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_BY_IMAGE_CASE"
  SET reply->status_data.status = "Z"
  GO TO exit_program
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(1)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  rt.report_id
  FROM report_task rt
  WHERE expand(idx,1,rpt_cnt,rt.report_id,reply->rpt_qual[idx].report_id)
  HEAD REPORT
   locidx = 0
  DETAIL
   locidx = locateval(idx,1,rpt_cnt,rt.report_id,reply->rpt_qual[idx].report_id), reply->rpt_qual[
   locidx].hold_cd = rt.hold_cd, reply->rpt_qual[locidx].hold_comment_long_text_id = rt
   .hold_comment_long_text_id,
   reply->rpt_qual[locidx].updt_cnt = rt.updt_cnt
  WITH nocounter
 ;end select
 SET case_event->accession_nbr = reply->accession_nbr
 EXECUTE aps_get_case_event_id
 SET reply->event_id = case_event->event_id
 IF ((request->station_catalog_cd > 0))
  SET bfound = 0
  SET reportindex = 1
  WHILE (reportindex <= rpt_cnt
   AND bfound=0)
    IF ((reply->rpt_qual[reportindex].catalog_cd=request->station_catalog_cd))
     SET bfound = 1
     SET reply->rpt_qual[reportindex].def_station_rpt_ind = 1
    ELSE
     SET reportindex += 1
    ENDIF
  ENDWHILE
  IF (bfound=1)
   CASE (reply->rpt_qual[reportindex].status_cd)
    OF cancelled_cd:
     SET bfound = 0
     SET check_blob_reference_ind = 0
    OF verified_cd:
    OF corrected_cd:
     SET check_blob_reference_ind = 0
    OF signinproc_cd:
    OF csigninproc_cd:
     SET check_blob_reference_ind = 1
    ELSE
     SET check_blob_reference_ind = 1
   ENDCASE
  ENDIF
 ENDIF
 IF (bfound=0)
  SET bfound = 0
  SET reportindex = 1
  WHILE (reportindex <= rpt_cnt
   AND bfound=0)
    IF ((reply->rpt_qual[reportindex].primary_ind=1))
     SET bfound = 1
    ELSE
     SET reportindex += 1
    ENDIF
  ENDWHILE
  IF (bfound=0)
   SET check_blob_reference_ind = 0
   SET reportindex = 0
  ELSE
   CASE (reply->rpt_qual[reportindex].status_cd)
    OF cancelled_cd:
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "C"
     SET reply->status_data.subeventstatus[1].targetobjectname = "RPTS_CANCELLED"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_BY_IMAGE_CASE"
     SET reply->status_data.status = "C"
     GO TO exit_program
    OF verified_cd:
    OF corrected_cd:
    OF signinproc_cd:
    OF csigninproc_cd:
     SET check_blob_reference_ind = 1
    ELSE
     SET check_blob_reference_ind = 1
   ENDCASE
  ENDIF
 ENDIF
 SET request->prompt_ind = 0
 SET request->lock_ind = 0
 SET request->prompt_ind = 0
 SET request->cyto_report_ind = 0
 SET request->called_ind = 1
 IF (reportindex > 0)
  SET request->report_id = reply->rpt_qual[reportindex].report_id
 ENDIF
 SET request->blob_bitmap = bor(n_images,n_doc_images)
 IF (check_blob_reference_ind=1)
  EXECUTE aps_get_case_report
 ENDIF
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
  FROM encntr_alias ea
  PLAN (ea
   WHERE (ea.encntr_id=reply->encntr_id)
    AND ea.encntr_alias_type_cd IN (mrn_alias_type_cd, fin_alias_type_cd)
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   CASE (ea.encntr_alias_type_cd)
    OF mrn_alias_type_cd:
     reply->person_num = frmt_mrn,reply->person_unformat_mrn = ea.alias
    OF fin_alias_type_cd:
     reply->person_fin = ea.alias
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  unfrmt_cmrn = pa.alias
  FROM person_alias pa
  PLAN (pa
   WHERE (pa.person_id=reply->person_id)
    AND pa.person_alias_type_cd=cmrn_alias_type_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   reply->person_unformat_cmrn = unfrmt_cmrn
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 IF ((reply->case_id > 0))
  SELECT INTO "nl:"
   FROM ap_digital_slide ads,
    ap_digital_slide_info adsf
   PLAN (ads
    WHERE (ads.case_id=reply->case_id)
     AND ads.slide_id=0
     AND ads.active_ind=1)
    JOIN (adsf
    WHERE adsf.ap_digital_slide_id=ads.ap_digital_slide_id
     AND adsf.active_ind=1
     AND adsf.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND adsf.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND adsf.url_elem_type_tflg="identifier")
   HEAD REPORT
    reply->case_digital_img_identifier = adsf.url_elem_string_txt
   WITH nocounter
  ;end select
 ENDIF
#exit_program
END GO
