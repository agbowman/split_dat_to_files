CREATE PROGRAM aps_get_cyto_rpts_by_que:dba
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
   1 rpt_qual[*]
     2 sequence = i4
     2 case_id = f8
     2 encntr_id = f8
     2 accession_nbr = c20
     2 case_collect_dt_tm = dq8
     2 case_received_dt_tm = dq8
     2 case_blob_bitmap = f8
     2 case_updt_cnt = i4
     2 dataset_uid = vc
     2 prefix_cd = f8
     2 case_year = i4
     2 case_number = i4
     2 report_id = f8
     2 primary_ind = i2
     2 report_sequence = i4
     2 catalog_cd = f8
     2 description = vc
     2 short_description = c50
     2 request_priority_cd = f8
     2 request_priority_disp = c40
     2 request_priority_desc = vc
     2 request_priority_mean = c12
     2 hold_cd = f8
     2 hold_disp = c40
     2 hold_comment = vc
     2 hold_comment_long_text_id = f8
     2 hold_comment_updt_cnt = i4
     2 status_cd = f8
     2 status_disp = c40
     2 status_mean = c12
     2 edit_dt_tm = dq8
     2 person_id = f8
     2 person_name = vc
     2 person_num = c16
     2 sex_cd = f8
     2 sex_disp = c40
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 deceased_dt_tm = dq8
     2 age = vc
     2 req_physician_id = f8
     2 req_physician_name = vc
     2 case_resp_pathologist_id = f8
     2 case_resp_pathologist_name = vc
     2 case_resp_resident_id = f8
     2 case_resp_resident_name = vc
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 resp_pathologist_id = f8
     2 resp_pathologist_name = vc
     2 resp_resident_id = f8
     2 resp_resident_name = vc
     2 chr_ind = i2
     2 updt_cnt = i4
     2 case_comment = vc
     2 case_comment_long_text_id = f8
     2 case_comment_long_text_updt_cnt = i4
     2 loc_facility_cd = f8
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
       3 physician_name = vc
       3 physician_id = f8
     2 person_unformat_mrn = vc
     2 person_unformat_cmrn = vc
     2 person_fin = vc
     2 case_digital_img_identifier = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 DECLARE verified_cd = f8 WITH protect, noconstant(0.0)
 DECLARE canceled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE corrected_cd = f8 WITH protect, noconstant(0.0)
 DECLARE signinproc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE csigninproc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE code_value = f8 WITH protect, noconstant(0.0)
 DECLARE mrn_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cmrn_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE fin_alias_type_cd = f8 WITH protect, noconstant(0.0)
 CALL initresourcesecurity(1)
 SET bfoundlongtextid = 0
 SET lpcnumofcasecomments = 0
 SET lltnumofcasecomments = 0
 SET stat = alterlist(reply->rpt_qual,1)
 SET stat = alterlist(reply->rpt_qual[1].phys_qual,1)
 SET stat = alterlist(reply->rpt_qual[1].spec_qual,1)
 SET spec_cnt = 0
 SET phys_cnt = 0
 SET stat = uar_get_meaning_by_codeset(1305,"VERIFIED",1,verified_cd)
 IF (verified_cd=0.0)
  CALL subevent_add("UAR","F","1305","CANNOT GET VERIFIED CODE VALUE")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CORRECTED",1,corrected_cd)
 IF (corrected_cd=0.0)
  CALL subevent_add("UAR","F","1305","CANNOT GET CORRECTED CODE VALUE")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CANCEL",1,canceled_cd)
 IF (canceled_cd=0.0)
  CALL subevent_add("UAR","F","1305","CANNOT GET CANCEL CODE VALUE")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"SIGNINPROC",1,signinproc_cd)
 IF (signinproc_cd=0.0)
  CALL subevent_add("UAR","F","1305","CANNOT GET SIGNINPROC CODE VALUE")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CSIGNINPROC",1,csigninproc_cd)
 IF (csigninproc_cd=0.0)
  CALL subevent_add("UAR","F","1305","CANNOT GET CSIGNINPROC CODE VALUE")
  GO TO exit_script
 ENDIF
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SET stat = uar_get_meaning_by_codeset(4,"CMRN",1,cmrn_alias_type_cd)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_alias_type_cd)
 SELECT INTO "nl:"
  rqr.report_queue_cd, rt.report_id, cr.case_id,
  join_path = decode(cs.seq,"S",cp.seq,"P"," "), t_tag_group_id = decode(t.seq,t.tag_group_id,0.0),
  t_tag_sequence = decode(t.seq,t.tag_sequence,0)
  FROM report_queue_r rqr,
   report_task rt,
   case_report cr,
   cyto_report_control crc,
   pathology_case pc,
   prsnl pr1,
   prsnl pr2,
   prsnl pr3,
   prsnl pr5,
   prsnl pr6,
   prefix_report_r prr,
   service_directory sd,
   person p,
   (dummyt d1  WITH seq = 1),
   case_specimen cs,
   ap_tag t,
   (dummyt d2  WITH seq = 1),
   case_provider cp,
   prsnl pr4,
   encounter e
  PLAN (rqr
   WHERE (request->report_queue_cd=rqr.report_queue_cd))
   JOIN (cr
   WHERE rqr.report_id=cr.report_id
    AND  NOT (cr.status_cd IN (verified_cd, canceled_cd, corrected_cd, signinproc_cd, csigninproc_cd)
   ))
   JOIN (crc
   WHERE cr.catalog_cd=crc.catalog_cd)
   JOIN (pc
   WHERE cr.case_id=pc.case_id)
   JOIN (prr
   WHERE pc.prefix_id=prr.prefix_id
    AND cr.catalog_cd=prr.catalog_cd
    AND 1=prr.primary_ind)
   JOIN (pr1
   WHERE pc.requesting_physician_id=pr1.person_id)
   JOIN (pr5
   WHERE pc.responsible_pathologist_id=pr5.person_id)
   JOIN (pr6
   WHERE pc.responsible_resident_id=pr6.person_id)
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
   JOIN (pr2
   WHERE rt.responsible_pathologist_id=pr2.person_id)
   JOIN (pr3
   WHERE rt.responsible_resident_id=pr3.person_id)
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (e
   WHERE pc.encntr_id=e.encntr_id)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (cs
   WHERE pc.case_id=cs.case_id
    AND cs.cancel_cd IN (null, 0.0))
   JOIN (t
   WHERE cs.specimen_tag_id=t.tag_id)
   ) ORJOIN ((d2
   WHERE 1=d2.seq)
   JOIN (cp
   WHERE pc.case_id=cp.case_id)
   JOIN (pr4
   WHERE cp.physician_id=pr4.person_id)
   ))
  ORDER BY cr.report_id, join_path DESC, t_tag_group_id,
   t_tag_sequence
  HEAD REPORT
   service_resource_cd = 0.0, access_to_resource_ind = 0, cnt = 0
  HEAD rt.report_id
   service_resource_cd = rt.service_resource_cd, access_to_resource_ind = 0
   IF (isresourceviewable(service_resource_cd)=true)
    access_to_resource_ind = 1, cnt += 1, stat = alterlist(reply->rpt_qual,cnt),
    reply->rpt_qual[cnt].sequence = rqr.sequence, reply->rpt_qual[cnt].report_id = rt.report_id,
    reply->rpt_qual[cnt].request_priority_cd = rt.priority_cd,
    reply->rpt_qual[cnt].status_cd = cr.status_cd, reply->rpt_qual[cnt].report_sequence = cr
    .report_sequence, reply->rpt_qual[cnt].catalog_cd = cr.catalog_cd,
    reply->rpt_qual[cnt].hold_cd = rt.hold_cd, reply->rpt_qual[cnt].hold_comment_long_text_id = rt
    .hold_comment_long_text_id
    IF ((reply->rpt_qual[cnt].hold_comment_long_text_id > 0))
     bfoundlongtextid = 1
    ENDIF
    reply->rpt_qual[cnt].edit_dt_tm = cnvtdatetime(rt.last_edit_dt_tm), reply->rpt_qual[cnt].case_id
     = pc.case_id, reply->rpt_qual[cnt].encntr_id = pc.encntr_id,
    reply->rpt_qual[cnt].accession_nbr = pc.accession_nbr, reply->rpt_qual[cnt].prefix_cd = pc
    .prefix_id, reply->rpt_qual[cnt].case_year = pc.case_year,
    reply->rpt_qual[cnt].case_number = pc.case_number, reply->rpt_qual[cnt].case_comment_long_text_id
     = pc.comments_long_text_id
    IF (pc.comments_long_text_id > 0)
     lpcnumofcasecomments += 1
    ENDIF
    reply->rpt_qual[cnt].case_blob_bitmap = pc.blob_bitmap, reply->rpt_qual[cnt].case_updt_cnt = pc
    .updt_cnt, reply->rpt_qual[cnt].dataset_uid = pc.dataset_uid,
    reply->rpt_qual[cnt].primary_ind = prr.primary_ind, reply->rpt_qual[cnt].case_collect_dt_tm =
    cnvtdatetime(pc.case_collect_dt_tm), reply->rpt_qual[cnt].case_received_dt_tm = cnvtdatetime(pc
     .case_received_dt_tm),
    reply->rpt_qual[cnt].description = sd.description, reply->rpt_qual[cnt].short_description = sd
    .short_description, reply->rpt_qual[cnt].person_id = p.person_id,
    reply->rpt_qual[cnt].person_name = p.name_full_formatted, reply->rpt_qual[cnt].sex_cd = p.sex_cd,
    reply->rpt_qual[cnt].age = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"),
    reply->rpt_qual[cnt].birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->rpt_qual[cnt].birth_tz =
    validate(p.birth_tz,0), reply->rpt_qual[cnt].deceased_dt_tm = cnvtdatetime(p.deceased_dt_tm),
    reply->rpt_qual[cnt].person_num = "Unknown", reply->rpt_qual[cnt].req_physician_name = pr1
    .name_full_formatted, reply->rpt_qual[cnt].req_physician_id = pc.requesting_physician_id,
    reply->rpt_qual[cnt].case_resp_pathologist_id = pc.responsible_pathologist_id, reply->rpt_qual[
    cnt].case_resp_pathologist_name = pr5.name_full_formatted, reply->rpt_qual[cnt].
    case_resp_resident_id = pc.responsible_resident_id,
    reply->rpt_qual[cnt].case_resp_resident_name = pr6.name_full_formatted, reply->rpt_qual[cnt].
    service_resource_cd = rt.service_resource_cd, reply->rpt_qual[cnt].resp_pathologist_id = rt
    .responsible_pathologist_id,
    reply->rpt_qual[cnt].resp_pathologist_name = pr2.name_full_formatted, reply->rpt_qual[cnt].
    resp_resident_id = rt.responsible_resident_id, reply->rpt_qual[cnt].resp_resident_name = pr3
    .name_full_formatted,
    reply->rpt_qual[cnt].chr_ind = pc.chr_ind, reply->rpt_qual[cnt].updt_cnt = rt.updt_cnt, reply->
    rpt_qual[cnt].loc_facility_cd = e.loc_facility_cd,
    spec_cnt = 0, phys_cnt = 0
   ENDIF
  HEAD cs.case_specimen_id
   IF (access_to_resource_ind=1)
    IF (join_path="S")
     spec_cnt += 1, stat = alterlist(reply->rpt_qual[cnt].spec_qual,spec_cnt), reply->rpt_qual[cnt].
     spec_qual[spec_cnt].case_specimen_id = cs.case_specimen_id,
     reply->rpt_qual[cnt].spec_qual[spec_cnt].specimen_tag_group_cd = t.tag_group_id, reply->
     rpt_qual[cnt].spec_qual[spec_cnt].specimen_tag_sequence = t.tag_sequence, reply->rpt_qual[cnt].
     spec_qual[spec_cnt].specimen_tag_display = t.tag_disp,
     reply->rpt_qual[cnt].spec_qual[spec_cnt].specimen_tag_cd = cs.specimen_tag_id, reply->rpt_qual[
     cnt].spec_qual[spec_cnt].specimen_description = trim(cs.specimen_description), reply->rpt_qual[
     cnt].spec_qual[spec_cnt].specimen_cd = cs.specimen_cd
    ENDIF
   ENDIF
  DETAIL
   IF (access_to_resource_ind=1)
    IF (join_path="P")
     phys_cnt += 1, stat = alterlist(reply->rpt_qual[cnt].phys_qual,phys_cnt), reply->rpt_qual[cnt].
     phys_qual[phys_cnt].physician_name = trim(pr4.name_full_formatted),
     reply->rpt_qual[cnt].phys_qual[phys_cnt].physician_id = cp.physician_id
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","REPORT_QUEUE_R")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(reply->rpt_qual,5)))
  PLAN (d1
   WHERE (reply->rpt_qual[d1.seq].case_comment_long_text_id > 0))
   JOIN (lt
   WHERE (lt.long_text_id=reply->rpt_qual[d1.seq].case_comment_long_text_id))
  DETAIL
   reply->rpt_qual[d1.seq].case_comment = lt.long_text, reply->rpt_qual[d1.seq].
   case_comment_long_text_updt_cnt = lt.updt_cnt, lltnumofcasecomments += 1
  WITH nocounter
 ;end select
 IF (((curqual=0
  AND lpcnumofcasecomments > 0) OR (lpcnumofcasecomments != lltnumofcasecomments)) )
  CALL handle_errors("SELECT","F","TABLE","CASE, LONG_TEXT")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(reply->rpt_qual,5)))
  PLAN (d1
   WHERE (reply->rpt_qual[d1.seq].hold_comment_long_text_id > 0))
   JOIN (lt
   WHERE (lt.long_text_id=reply->rpt_qual[d1.seq].hold_comment_long_text_id))
  DETAIL
   reply->rpt_qual[d1.seq].hold_comment = lt.long_text, reply->rpt_qual[d1.seq].hold_comment_updt_cnt
    = lt.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0
  AND bfoundlongtextid=1)
  CALL handle_errors("SELECT","F","TABLE","LONG_TEXT")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
  FROM encntr_alias ea,
   (dummyt d1  WITH seq = value(size(reply->rpt_qual,5)))
  PLAN (d1
   WHERE (reply->rpt_qual[d1.seq].case_id > 0))
   JOIN (ea
   WHERE (ea.encntr_id=reply->rpt_qual[d1.seq].encntr_id)
    AND ea.encntr_alias_type_cd IN (mrn_alias_type_cd, fin_alias_type_cd)
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   CASE (ea.encntr_alias_type_cd)
    OF mrn_alias_type_cd:
     reply->rpt_qual[d1.seq].person_num = frmt_mrn,reply->rpt_qual[d1.seq].person_unformat_mrn = ea
     .alias
    OF fin_alias_type_cd:
     reply->rpt_qual[d1.seq].person_fin = ea.alias
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  unfrmt_cmrn = pa.alias
  FROM (dummyt d1  WITH seq = value(size(reply->rpt_qual,5))),
   person_alias pa
  PLAN (d1
   WHERE (reply->rpt_qual[d1.seq].case_id > 0))
   JOIN (pa
   WHERE (pa.person_id=reply->rpt_qual[d1.seq].person_id)
    AND pa.person_alias_type_cd=cmrn_alias_type_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   reply->rpt_qual[d1.seq].person_unformat_cmrn = unfrmt_cmrn
  WITH nocounter
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
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(reply->rpt_qual,5))),
   ap_digital_slide ads,
   ap_digital_slide_info adsf
  PLAN (d1
   WHERE (reply->rpt_qual[d1.seq].case_id > 0))
   JOIN (ads
   WHERE (ads.case_id=reply->rpt_qual[d1.seq].case_id)
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
   reply->rpt_qual[d1.seq].case_digital_img_identifier = adsf.url_elem_string_txt
  WITH nocounter
 ;end select
#exit_script
END GO
