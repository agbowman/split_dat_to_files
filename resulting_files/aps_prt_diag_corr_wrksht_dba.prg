CREATE PROGRAM aps_prt_diag_corr_wrksht:dba
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
 SUBROUTINE (populatesrtypesforsecurity(case_ind=i2) =null)
   IF (case_ind=1)
    SET stat = alterlist(default_service_type_cd->service_type_cd_list,6)
    SET default_service_type_cd->service_type_cd_list[1].service_type_cd = uar_get_code_by("MEANING",
     223,"INSTITUTION")
    SET default_service_type_cd->service_type_cd_list[2].service_type_cd = uar_get_code_by("MEANING",
     223,"DEPARTMENT")
    SET default_service_type_cd->service_type_cd_list[3].service_type_cd = uar_get_code_by("MEANING",
     223,"SECTION")
    SET default_service_type_cd->service_type_cd_list[4].service_type_cd = uar_get_code_by("MEANING",
     223,"SUBSECTION")
    SET default_service_type_cd->service_type_cd_list[5].service_type_cd = uar_get_code_by("MEANING",
     223,"BENCH")
    SET default_service_type_cd->service_type_cd_list[6].service_type_cd = uar_get_code_by("MEANING",
     223,"INSTRUMENT")
   ENDIF
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
 )
 RECORD generic_temp(
   1 requesting_path_name_full_formatted = vc
   1 study_description = vc
   1 group_name = vc
   1 group_description = vc
   1 across_case_ind = i2
   1 prefix_qual[*]
     2 prefix_id = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_display = vc
   1 specimen_header_qual[*]
     2 specimen_cd = f8
     2 specimen_display = vc
   1 comp_specimen_header_qual[*]
     2 specimen_cd = f8
     2 specimen_display = vc
   1 study_id_qual[*]
     2 task_assay_cd = f8
     2 task_assay_disp = vc
 )
 RECORD temp(
   1 max_members_in_group = i4
   1 max_dtas = i4
   1 max_comp_dtas = i4
   1 case_qual[*]
     2 system_group_person = c7
     2 prsnl_group_id = f8
     2 prsnl_group_desc = vc
     2 num_of_members = i4
     2 prsnl_group_qual[*]
       3 prsnl_group_id = f8
       3 prsnl_id = f8
       3 prsnl_name_full_formatted = vc
     2 valid_case_specimens = c1
     2 case_id = f8
     2 case_accession = c21
     2 proc_cnt = i4
     2 valid_proc_qual[*]
       3 ce_event_id = f8
       3 discrete_task_assay_cd = f8
       3 discrete_task_assay_disp = vc
       3 catalog_cd = f8
       3 text_cnt = i4
       3 text_qual[*]
         4 text = vc
     2 valid_compare_case_specimens = c1
     2 correlate_case_id = f8
     2 compare_to_accession = c21
     2 compare_proc_cnt = i4
     2 compare_proc_qual[*]
       3 ce_event_id = f8
       3 discrete_task_assay_cd = f8
       3 discrete_task_assay_disp = vc
       3 catalog_cd = f8
       3 text_cnt = i4
       3 text_qual[*]
         4 text = vc
     2 init_eval_term_id = f8
     2 init_eval_term_disp = c15
     2 init_discrep_term_id = f8
     2 init_discrep_term_disp = vc
     2 disagree_reason_cd = f8
     2 disagree_reason_disp = vc
     2 investigation_cd = f8
     2 investigation_disp = vc
     2 resolution_cd = f8
     2 resolution_disp = vc
     2 final_eval_term_id = f8
     2 final_eval_term_disp = vc
     2 final_discrep_term_id = f8
     2 final_discrep_term_disp = vc
     2 long_text_id = f8
     2 long_text_cntr = i4
     2 long_text_qual[*]
       3 text = vc
     2 initiated_prsnl_id = f8
     2 initiated_prsnl_name = vc
     2 initiated_dt_tm = dq8
 )
 RECORD temp_print(
   1 max_members_in_group = i4
   1 case_qual[*]
     2 system_group_person = c7
     2 prsnl_group_id = f8
     2 prsnl_group_desc = vc
     2 num_of_members = i4
     2 prsnl_group_qual[*]
       3 prsnl_group_id = f8
       3 prsnl_id = f8
       3 prsnl_name_full_formatted = vc
     2 case_id = f8
     2 case_accession = c21
     2 proc_cnt = i4
     2 valid_proc_qual[*]
       3 ce_event_id = f8
       3 discrete_task_assay_cd = f8
       3 discrete_task_assay_disp = vc
       3 catalog_cd = f8
       3 text_cnt = i4
       3 text_qual[*]
         4 text = vc
     2 correlate_case_id = f8
     2 compare_to_accession = c21
     2 compare_proc_cnt = i4
     2 compare_proc_qual[*]
       3 ce_event_id = f8
       3 discrete_task_assay_cd = f8
       3 discrete_task_assay_disp = vc
       3 catalog_cd = f8
       3 text_cnt = i4
       3 text_qual[*]
         4 text = vc
     2 init_eval_term_id = f8
     2 init_eval_term_disp = c15
     2 init_discrep_term_id = f8
     2 init_discrep_term_disp = vc
     2 disagree_reason_cd = f8
     2 disagree_reason_disp = vc
     2 investigation_cd = f8
     2 investigation_disp = vc
     2 resolution_cd = f8
     2 resolution_disp = vc
     2 final_eval_term_id = f8
     2 final_eval_term_disp = vc
     2 final_discrep_term_id = f8
     2 final_discrep_term_disp = vc
     2 long_text_id = f8
     2 long_text_cntr = i4
     2 long_text_qual[*]
       3 text = vc
     2 initiated_prsnl_id = f8
     2 initiated_prsnl_name = vc
     2 initiated_dt_tm = dq8
 )
 RECORD catalog(
   1 catalog_qual[*]
     2 catalog_cd = f8
     2 catalog_disp = vc
 )
 CALL initresourcesecurity(1)
 CALL populatesrtypesforsecurity(1)
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE uar_get_ceblobsize(p1=f8(ref),p2=vc(ref)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblobsize", persist
 DECLARE uar_get_ceblob(p1=f8(ref),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblob", persist
 RECORD recdate(
   1 datetime = dq8
 ) WITH protect
 DECLARE format = i2
 DECLARE outbuffer = vc
 DECLARE nortftext = vc
 SET format = 0
 DECLARE txt_pos = i4
 DECLARE start = i4
 DECLARE len = i4
 DECLARE linecnt = i4
 SUBROUTINE (rtf_to_text(rtftext=vc,format=i2,line_len=i2) =null)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET text_pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(value(size(rtftext))," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = ""
   SET nortftext = ""
   SET stat = memrealloc(outbuffer,1,build("C",value(size(rtftext))))
   SET stat = memrealloc(nortftext,1,build("C",value(size(rtftext))))
   IF (substring(1,5,rtftext)=asis("{\rtf"))
    SET inbuffer = trim(rtftext)
    CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
     bfl)
   ELSE
    SET outbuffer = trim(rtftext)
   ENDIF
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   SET lfchar = char(10)
   SET ffchar = char(12)
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET text_pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND text_pos >= all_len)
         SET text_pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (text_pos >= start
         AND all_len > tot_len)
          IF (text_pos=start)
           SET text_pos = ((start+ line_len) - 1)
           SET linecnt += 1
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((text_pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (text_pos+ 1)
           SET crstart = (text_pos+ 1)
           SET text_pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(text_pos,1,outbuffer)=" ")
            SET len = (text_pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt += 1
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (text_pos+ 1)
            SET crstart = (text_pos+ 1)
            SET text_pos = 0
            SET tot_len += len
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len += 1
            ENDIF
            SET text_pos -= 1
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt += 1
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         IF (substring(crpos,1,outbuffer)=crchar)
          SET crstart = (crpos+ textlen(crchar))
         ELSEIF (substring(crpos,1,outbuffer)=lfchar)
          SET crstart = (crpos+ textlen(lfchar))
         ELSEIF (substring(crpos,1,outbuffer)=ffchar)
          SET crstart = (crpos+ textlen(ffchar))
         ENDIF
         SET tot_len += crlen
        ENDIF
       ENDIF
       SET crpos += 1
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(value(size(rtftext))," ")
   SET inbuffer = fillstring(value(size(rtftext))," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE (decompress_text(tblobin=vc) =null)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 RECORD dtemp(
   1 beg_of_day = dq8
   1 end_of_day = dq8
   1 beg_of_day_abs = dq8
   1 end_of_day_abs = dq8
   1 beg_of_month = dq8
   1 end_of_month = dq8
   1 beg_of_month_abs = dq8
   1 end_of_month_abs = dq8
 )
 SUBROUTINE change_times(start_date,end_date)
  CALL getstartofday(start_date,0)
  CALL getendofday(end_date,0)
 END ;Subroutine
 SUBROUTINE getstartofdayabs(date_time,date_offset)
  CALL getstartofday(date_time,date_offset)
  SET dtemp->beg_of_day_abs = cnvtdatetimeutc(dtemp->beg_of_day,2)
 END ;Subroutine
 SUBROUTINE getstartofday(date_time,date_offset)
   SET dtemp->beg_of_day = cnvtdatetime((cnvtdate(date_time) - date_offset),0)
 END ;Subroutine
 SUBROUTINE getendofdayabs(date_time,date_offset)
  CALL getendofday(date_time,date_offset)
  SET dtemp->end_of_day_abs = cnvtdatetimeutc(dtemp->end_of_day,2)
 END ;Subroutine
 SUBROUTINE getendofday(date_time,date_offset)
   SET dtemp->end_of_day = cnvtdatetime((cnvtdate(date_time) - date_offset),235959)
 END ;Subroutine
 SUBROUTINE getstartofmonthabs(date_time,month_offset)
  CALL getstartofmonth(date_time,month_offset)
  SET dtemp->beg_of_month_abs = cnvtdatetimeutc(dtemp->beg_of_month,2)
 END ;Subroutine
 SUBROUTINE getstartofmonth(date_time,month_offset)
   DECLARE nyearoffset = i4
   DECLARE nmonthremainder = i4
   DECLARE nbeginningmonth = i4
   IF (((month(date_time)+ month_offset) <= 0))
    IF (mod(((month(date_time)+ month_offset) - 12),12) != 0)
     SET nyearoffset = (((month(date_time)+ month_offset) - 12)/ 12)
    ELSE
     SET nyearoffset = (((month(date_time)+ month_offset) - 11)/ 12)
    ENDIF
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = (12+ nmonthremainder)
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ELSE
    SET nyearoffset = (((month(date_time)+ month_offset) - 1)/ 12)
    SET nmonthremainder = mod((month(date_time)+ month_offset),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = nmonthremainder
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ENDIF
   SET date_string = build("01",format(nbeginningmonth,"##;p0"),(year(date_time)+ nyearoffset))
   SET dtemp->beg_of_month = cnvtdatetime(cnvtdate2(date_string,"ddmmyyyy"),0)
 END ;Subroutine
 SUBROUTINE getendofmonthabs(date_time,month_offset)
  CALL getendofmonth(date_time,month_offset)
  SET dtemp->end_of_month_abs = cnvtdatetimeutc(dtemp->end_of_month,2)
 END ;Subroutine
 SUBROUTINE getendofmonth(date_time,month_offset)
   DECLARE nyearoffset = i4
   DECLARE nmonthremainder = i4
   DECLARE nbeginningmonth = i4
   IF (((month(date_time)+ month_offset) < 0))
    IF (mod(((month(date_time)+ month_offset) - 12),12) != 0)
     SET nyearoffset = (((month(date_time)+ month_offset) - 12)/ 12)
    ELSE
     SET nyearoffset = (((month(date_time)+ month_offset) - 11)/ 12)
    ENDIF
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = (12+ nmonthremainder)
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ELSE
    SET nyearoffset = ((month(date_time)+ month_offset)/ 12)
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = nmonthremainder
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ENDIF
   SET date_string = build("01",format(nbeginningmonth,"##;p0"),(year(date_time)+ nyearoffset))
   SET dtemp->end_of_month = cnvtdatetime((cnvtdate2(date_string,"ddmmyyyy") - 1),235959)
 END ;Subroutine
 CALL change_times(request->beg_dt_tm,request->end_dt_tm)
 SET request->end_dt_tm = dtemp->end_of_day
 SET request->beg_dt_tm = dtemp->beg_of_day
 DECLARE locindx = i4
 DECLARE ind = i4
 DECLARE catalog_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_catlog_cd = f8 WITH protect, noconstant(0.0)
 RECORD captions(
   1 title = vc
   1 pathnet = vc
   1 dt = vc
   1 dir = vc
   1 tm = vc
   1 diag = vc
   1 bye = vc
   1 pg = vc
   1 study = vc
   1 pre = vc
   1 all_pre = vc
   1 spec = vc
   1 all_spec = vc
   1 beg_dt = vc
   1 end_dt = vc
   1 grp = vc
   1 all_grp = vc
   1 no_grp = vc
   1 path = vc
   1 no_path = vc
   1 all_path = vc
   1 no_case = vc
   1 correlat = vc
   1 cas = vc
   1 compto = vc
   1 init = vc
   1 f_eval = vc
   1 f_dis = vc
   1 i_eval = vc
   1 i_dis = vc
   1 na = vc
   1 dis_rea = vc
   1 invest = vc
   1 res = vc
   1 grp_mem = vc
   1 corr_com = vc
   1 cases = vc
   1 rpt = vc
   1 cont = vc
   1 comp = vc
   1 section = vc
 )
 SET captions->title = uar_i18ngetmessage(i18nhandle,"t1","REPORT: APS_PRT_DIAG_CORR_WRKSHT.PRG")
 SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"t2","PATHNET ANATOMIC PATHOLOGY")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t3","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t4","DIRECTORY:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t5","TIME:")
 SET captions->diag = uar_i18ngetmessage(i18nhandle,"t6","DIAGNOSTIC CORRELATION WORKSHEET")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t7","BY:")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t8","PAGE:")
 SET captions->study = uar_i18ngetmessage(i18nhandle,"t9","         STUDY:")
 SET captions->pre = uar_i18ngetmessage(i18nhandle,"t10","    PREFIX(ES):")
 SET captions->all_pre = uar_i18ngetmessage(i18nhandle,"t11","ALL PREFIXES")
 SET captions->spec = uar_i18ngetmessage(i18nhandle,"t12","   SPECIMEN(S):")
 SET captions->all_spec = uar_i18ngetmessage(i18nhandle,"t13","ALL SPECIMENS")
 SET captions->beg_dt = uar_i18ngetmessage(i18nhandle,"t14","BEGINNING DATE:")
 SET captions->end_dt = uar_i18ngetmessage(i18nhandle,"t15","   ENDING DATE:")
 SET captions->grp = uar_i18ngetmessage(i18nhandle,"t16","         GROUP:")
 SET captions->all_grp = uar_i18ngetmessage(i18nhandle,"t17","ALL GROUPS")
 SET captions->no_grp = uar_i18ngetmessage(i18nhandle,"t18","NO GROUP SELECTED")
 SET captions->path = uar_i18ngetmessage(i18nhandle,"t19","   PATHOLOGIST:")
 SET captions->no_path = uar_i18ngetmessage(i18nhandle,"t20","NO PATHOLOGISTS")
 SET captions->all_path = uar_i18ngetmessage(i18nhandle,"t21","ALL PATHOLOGISTS")
 SET captions->no_case = uar_i18ngetmessage(i18nhandle,"t22","No cases match selection criteria.")
 SET captions->correlat = uar_i18ngetmessage(i18nhandle,"t23","CORRELATION EVALUATED BY:")
 SET captions->cas = uar_i18ngetmessage(i18nhandle,"t24","CASE")
 SET captions->compto = uar_i18ngetmessage(i18nhandle,"t25","COMPARE TO")
 SET captions->init = uar_i18ngetmessage(i18nhandle,"t26","INITIATED")
 SET captions->f_eval = uar_i18ngetmessage(i18nhandle,"t27","FINAL EVALUATION")
 SET captions->f_dis = uar_i18ngetmessage(i18nhandle,"t28","FINAL DISCREPANCY")
 SET captions->i_eval = uar_i18ngetmessage(i18nhandle,"t29","INITIAL EVALUATION:")
 SET captions->i_dis = uar_i18ngetmessage(i18nhandle,"t30","INITIAL DISCREPANCY:")
 SET captions->na = uar_i18ngetmessage(i18nhandle,"t31","N/A")
 SET captions->dis_rea = uar_i18ngetmessage(i18nhandle,"t32","DISAGREEMENT REASON:")
 SET captions->invest = uar_i18ngetmessage(i18nhandle,"t33","INVESTIGATION:")
 SET captions->res = uar_i18ngetmessage(i18nhandle,"t34","RESOLUTION:")
 SET captions->grp_mem = uar_i18ngetmessage(i18nhandle,"t35","GROUP MEMBERS:")
 SET captions->corr_com = uar_i18ngetmessage(i18nhandle,"t36","CORRELATION COMMENT:")
 SET captions->cases = uar_i18ngetmessage(i18nhandle,"t37","CASE:")
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"t38","REPORT:")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"t39","CONTINUED...")
 SET captions->comp = uar_i18ngetmessage(i18nhandle,"t40","COMP. SPEC.(S):")
 SET captions->section = uar_i18ngetmessage(i18nhandle,"t41","Section:")
 DECLARE tblobout = gvc WITH protect, noconstant(" ")
 DECLARE blob_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",25,"BLOB"))
 SET reply->status_data.status = "F"
 SET deleted_status_cd = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(10," ")
 SET code_set = 48
 SET code_value = 0.0
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_status_cd = code_value
 SELECT INTO "nl:"
  FROM ap_dc_study ads
  WHERE (ads.study_id=request->study_id)
  DETAIL
   generic_temp->study_description = ads.description, generic_temp->across_case_ind = ads
   .across_case_ind
  WITH nocounter
 ;end select
 IF ((request->prefix_cnt > 0))
  SELECT INTO "nl:"
   cv_display = cv.display"#####", site_prefix = build(substring(1,5,cv.display),ap.prefix_name), ap
   .prefix_name,
   ap.prefix_id, ap.site_cd
   FROM ap_prefix ap,
    code_value cv,
    (dummyt d  WITH seq = value(size(request->prefix_qual,5)))
   PLAN (d)
    JOIN (ap
    WHERE (request->prefix_qual[d.seq].prefix_id=ap.prefix_id))
    JOIN (cv
    WHERE ap.site_cd=cv.code_value)
   ORDER BY site_prefix
   HEAD REPORT
    stat = alterlist(generic_temp->prefix_qual,value(size(request->prefix_qual,5))), pref_cntr = 0
   HEAD ap.prefix_id
    pref_cntr += 1, generic_temp->prefix_qual[pref_cntr].prefix_id = ap.prefix_id, generic_temp->
    prefix_qual[pref_cntr].prefix_name = ap.prefix_name
    IF (ap.site_cd > 0)
     generic_temp->prefix_qual[pref_cntr].site_cd = ap.site_cd, generic_temp->prefix_qual[pref_cntr].
     site_display = cv.display
    ENDIF
   FOOT REPORT
    stat = alterlist(generic_temp->prefix_qual,pref_cntr)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->specimen_cnt > 0))
  SELECT INTO "nl:"
   cv.display
   FROM code_value cv,
    (dummyt d  WITH seq = value(size(request->specimen_qual,5)))
   PLAN (d)
    JOIN (cv
    WHERE (request->specimen_qual[d.seq].specimen_cd=cv.code_value))
   ORDER BY cv.display_key
   HEAD REPORT
    stat = alterlist(generic_temp->specimen_header_qual,value(size(request->specimen_qual,5))),
    spec_cntr = 0
   DETAIL
    spec_cntr += 1, generic_temp->specimen_header_qual[spec_cntr].specimen_cd = cv.code_value,
    generic_temp->specimen_header_qual[spec_cntr].specimen_display = cv.display
   FOOT REPORT
    stat = alterlist(generic_temp->specimen_header_qual,spec_cntr)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->specimen_comp_cnt > 0))
  SELECT INTO "nl:"
   cv.display
   FROM code_value cv,
    (dummyt d  WITH seq = value(size(request->specimen_comp_to_qual,5)))
   PLAN (d)
    JOIN (cv
    WHERE (request->specimen_comp_to_qual[d.seq].specimen_cd=cv.code_value))
   ORDER BY cv.display_key
   HEAD REPORT
    stat = alterlist(generic_temp->comp_specimen_header_qual,value(size(request->
       specimen_comp_to_qual,5))), spec_cntr = 0
   DETAIL
    spec_cntr += 1, generic_temp->comp_specimen_header_qual[spec_cntr].specimen_cd = cv.code_value,
    generic_temp->comp_specimen_header_qual[spec_cntr].specimen_display = cv.display
   FOOT REPORT
    stat = alterlist(generic_temp->comp_specimen_header_qual,spec_cntr)
   WITH nocounter
  ;end select
 ENDIF
 DECLARE ce_where = vc
 SET ce_where = trim("0 = 0")
 SET bno_details = "F"
 SELECT INTO "nl:"
  cv.display
  FROM ap_dc_study_rpt_proc adsrp,
   code_value cv
  PLAN (adsrp
   WHERE (adsrp.study_id=request->study_id))
   JOIN (cv
   WHERE adsrp.task_assay_cd=cv.code_value)
  HEAD REPORT
   x = 0, ce_where = "ce.task_assay_cd in ("
  DETAIL
   x += 1, stat = alterlist(generic_temp->study_id_qual,x), generic_temp->study_id_qual[x].
   task_assay_cd = adsrp.task_assay_cd,
   ce_where = concat(trim(ce_where),trim(cnvtstring(adsrp.task_assay_cd,32,2)),", "), generic_temp->
   study_id_qual[x].task_assay_disp = cv.display
  FOOT REPORT
   templen = textlen(trim(ce_where)), ce_where = concat(substring(1,(templen - 1),trim(ce_where)),
    ") ")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET bno_details = "T"
 ENDIF
 IF ((request->pathologist_param="S"))
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM prsnl p
   WHERE (request->pathologist_id=p.person_id)
   DETAIL
    generic_temp->requesting_path_name_full_formatted = p.name_full_formatted
   WITH nocounter
  ;end select
 ELSE
  SET generic_temp->requesting_path_name_full_formatted = ""
 ENDIF
 IF ((request->group_param="S"))
  SELECT INTO "nl:"
   pg.prsnl_group_desc
   FROM prsnl_group pg
   WHERE (request->prsnl_group_id=pg.prsnl_group_id)
   DETAIL
    generic_temp->group_description = pg.prsnl_group_desc, generic_temp->group_name = pg
    .prsnl_group_name
   WITH nocounter
  ;end select
 ELSE
  SET generic_temp->group_description = ""
  SET generic_temp->group_name = " "
 ENDIF
 DECLARE prefix_where1 = vc WITH protect, noconstant("")
 DECLARE temp_prefixids = vc WITH protect, noconstant("")
 SET prefix_where1 = fillstring(2000," ")
 SET prefix_where1 = "( 0 = 0 )"
 IF ((request->prefix_cnt > 0))
  SET prefix_where1 = concat(trim(prefix_where1)," and pc1.prefix_id in (")
  FOR (x = 1 TO (request->prefix_cnt - 1))
    SET prefix_where1 = concat(trim(prefix_where1)," ",cnvtstring(request->prefix_qual[x].prefix_id,
      32,2,r),",")
  ENDFOR
  SET prefix_where1 = concat(trim(prefix_where1)," ",cnvtstring(request->prefix_qual[x].prefix_id,32,
    2,r),")")
 ELSE
  SELECT INTO "nl:"
   FROM ap_prefix ap
   PLAN (ap
    WHERE ap.prefix_id != 0.0)
   DETAIL
    service_resource_cd = ap.service_resource_cd
    IF (isresourceviewable(service_resource_cd)=true)
     IF (textlen(trim(temp_prefixids))=0)
      temp_prefixids = cnvtstring(ap.prefix_id,32,2,r)
     ELSE
      temp_prefixids = build(trim(temp_prefixids),",",cnvtstring(ap.prefix_id,32,2,r))
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET prefix_where1 = "( 0 != 0 )"
  ELSEIF (getresourcesecuritystatus(0) != "S")
   IF (getresourcesecuritystatus(0)="F")
    SET reply->status_data.status = "F"
    CALL populateressecstatusblock(1)
    GO TO exit_script
   ELSE
    CALL populateressecstatusblock(1)
    SET prefix_where1 = "( 0 != 0 )"
   ENDIF
  ELSE
   IF (textlen(trim(temp_prefixids)) > 0)
    SET prefix_where1 = concat("pc1.prefix_id in (",temp_prefixids)
    SET prefix_where1 = concat(trim(prefix_where1),")")
   ENDIF
  ENDIF
 ENDIF
 IF ((((request->group_param="N")
  AND (request->pathologist_param="A")) OR ((((request->group_param="N")
  AND (request->pathologist_param="S")) OR ((((request->group_param="A")
  AND (request->pathologist_param="A")) OR ((((request->group_param="A")
  AND (request->pathologist_param="S")) OR ((((request->group_param="S")
  AND (request->pathologist_param="A")) OR ((request->group_param="S")
  AND (request->pathologist_param="S"))) )) )) )) )) )
  SET join_ade_table = fillstring(1000," ")
  SET join_ade_table = "( 0 = 0 )"
  SET join_adep_table = fillstring(1000," ")
  SET join_adep_table = "( 0 = 0 )"
  IF ((request->group_param="N")
   AND (request->pathologist_param="S"))
   SET join_ade_table = build(trim(join_ade_table)," and (ade.prsnl_group_id = 0)")
   SET join_adep_table = build(trim(join_adep_table),
    " and (adep.prsnl_group_id = 0) and (adep.prsnl_id = request->pathologist_id)")
  ELSEIF ((request->group_param="N")
   AND (request->pathologist_param="A"))
   SET join_ade_table = build(trim(join_ade_table)," and (ade.prsnl_group_id = 0)")
   SET join_adep_table = build(trim(join_adep_table),
    " and (adep.prsnl_group_id = 0) and (adep.prsnl_id > 0)")
  ELSEIF ((request->group_param="A")
   AND (request->pathologist_param="S"))
   SET join_ade_table = build(trim(join_ade_table)," and (ade.prsnl_group_id > 0)")
   SET join_adep_table = build(trim(join_adep_table),
    " and (ade.prsnl_group_id = adep.prsnl_group_id) and (adep.prsnl_id = request->pathologist_id)")
  ELSEIF ((request->group_param="S")
   AND (request->pathologist_param="A"))
   SET join_ade_table = build(trim(join_ade_table),
    " and (ade.prsnl_group_id = request->prsnl_group_id )")
   SET join_adep_table = build(trim(join_adep_table),
    " and (adep.prsnl_group_id = ade.prsnl_group_id)")
  ELSEIF ((request->group_param="S")
   AND (request->pathologist_param="S"))
   SET join_ade_table = build(trim(join_ade_table),
    " and (ade.prsnl_group_id = request->prsnl_group_id )")
   SET join_adep_table = build(trim(join_adep_table),
    " and (adep.prsnl_group_id = ade.prsnl_group_id) and (adep.prsnl_id = request->pathologist_id)")
  ENDIF
  SET m_lresseccheckedcnt = 0
  SET m_lressecfailedcnt = 0
  SELECT INTO "nl:"
   disagree_disp = uar_get_code_display(ade.disagree_reason_cd), investigation_disp =
   uar_get_code_display(ade.investigation_cd), resolution_disp = uar_get_code_display(ade
    .resolution_cd),
   pc_accession_nbr = pc1.accession_nbr, ade.study_id, ade.event_id,
   ade.case_id, pc1.case_id
   FROM ap_dc_event ade,
    ap_dc_event_prsnl adep,
    pathology_case pc1,
    prsnl_group pg
   PLAN (ade
    WHERE (ade.study_id=request->study_id)
     AND ade.complete_prsnl_id IN (null, 0)
     AND ade.initiated_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND ade.cancel_dt_tm IN (null)
     AND parser(trim(join_ade_table)))
    JOIN (adep
    WHERE ade.event_id=adep.event_id
     AND parser(trim(join_adep_table)))
    JOIN (pc1
    WHERE ade.case_id=pc1.case_id
     AND parser(prefix_where1))
    JOIN (pg
    WHERE pg.prsnl_group_id=ade.prsnl_group_id)
   ORDER BY pc_accession_nbr, ade.event_id
   HEAD REPORT
    case_cntr = 0, prsnl_cntr = 0, access_to_resource_ind = 0
   HEAD ade.event_id
    access_to_resource_ind = 1
    IF (pg.prsnl_group_id > 0.0)
     IF (isresourceviewable(pg.service_resource_cd)=false)
      access_to_resource_ind = 0
     ENDIF
    ENDIF
    IF (access_to_resource_ind=1)
     case_cntr += 1, stat = alterlist(temp->case_qual[case_cntr],case_cntr), temp->case_qual[
     case_cntr].valid_case_specimens = "N",
     temp->case_qual[case_cntr].valid_compare_case_specimens = "N", temp->case_qual[case_cntr].
     case_id = ade.case_id, temp->case_qual[case_cntr].correlate_case_id = ade.correlate_case_id,
     temp->case_qual[case_cntr].init_eval_term_id = ade.init_eval_term_id, temp->case_qual[case_cntr]
     .init_discrep_term_id = ade.init_discrep_term_id, temp->case_qual[case_cntr].disagree_reason_cd
      = ade.disagree_reason_cd,
     temp->case_qual[case_cntr].disagree_reason_disp = disagree_disp, temp->case_qual[case_cntr].
     investigation_cd = ade.investigation_cd, temp->case_qual[case_cntr].investigation_disp =
     investigation_disp,
     temp->case_qual[case_cntr].resolution_cd = ade.resolution_cd, temp->case_qual[case_cntr].
     resolution_disp = resolution_disp, temp->case_qual[case_cntr].final_eval_term_id = ade
     .final_eval_term_id,
     temp->case_qual[case_cntr].final_discrep_term_id = ade.final_discrep_term_id, temp->case_qual[
     case_cntr].long_text_id = ade.long_text_id, temp->case_qual[case_cntr].prsnl_group_id = ade
     .prsnl_group_id,
     temp->case_qual[case_cntr].initiated_prsnl_id = ade.initiated_prsnl_id, temp->case_qual[
     case_cntr].initiated_dt_tm = ade.initiated_dt_tm
     IF (ade.prsnl_group_id IN (null, 0)
      AND ade.initiated_prsnl_id > 0)
      temp->case_qual[case_cntr].system_group_person = "3PERSON"
     ELSEIF (ade.prsnl_group_id > 0)
      temp->case_qual[case_cntr].system_group_person = "2GROUP "
     ENDIF
     prsnl_cntr = 0
    ENDIF
   DETAIL
    IF (access_to_resource_ind=1)
     prsnl_cntr += 1
     IF ((prsnl_cntr > temp->max_members_in_group))
      temp->max_members_in_group = prsnl_cntr
     ENDIF
     stat = alterlist(temp->case_qual[case_cntr].prsnl_group_qual,prsnl_cntr), temp->case_qual[
     case_cntr].num_of_members = prsnl_cntr, temp->case_qual[case_cntr].prsnl_group_qual[prsnl_cntr].
     prsnl_group_id = adep.prsnl_group_id,
     temp->case_qual[case_cntr].prsnl_group_qual[prsnl_cntr].prsnl_id = adep.prsnl_id
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   GO TO report_maker
  ELSEIF (getresourcesecuritystatus(0) != "S")
   IF (getresourcesecuritystatus(0)="F")
    SET reply->status_data.status = "F"
    CALL populateressecstatusblock(ncorr_group_sec_msg_type)
    GO TO exit_script
   ELSE
    CALL populateressecstatusblock(ncorr_group_sec_msg_type)
    GO TO report_maker
   ENDIF
  ENDIF
 ENDIF
 DECLARE spec_where1 = vc
 IF ((request->specimen_cnt=0))
  SET spec_where1 = "( 0 = 0 )"
 ELSE
  SET spec_where1 = concat(" cs.specimen_cd in (")
  FOR (x = 1 TO (request->specimen_cnt - 1))
    SET spec_where1 = concat(trim(spec_where1)," ",cnvtstring(request->specimen_qual[x].specimen_cd,
      32,2,r),",")
  ENDFOR
  SET spec_where1 = concat(trim(spec_where1)," ",cnvtstring(request->specimen_qual[x].specimen_cd,32,
    2,r),")")
 ENDIF
 DECLARE spec_where2 = vc
 IF ((request->specimen_comp_cnt=0))
  SET spec_where2 = "( 0 = 0 )"
 ELSE
  SET spec_where2 = concat(" cs.specimen_cd in (")
  FOR (x = 1 TO (request->specimen_comp_cnt - 1))
    SET spec_where2 = concat(trim(spec_where2)," ",cnvtstring(request->specimen_comp_to_qual[x].
      specimen_cd,32,2,r),",")
  ENDFOR
  SET spec_where2 = concat(trim(spec_where2)," ",cnvtstring(request->specimen_comp_to_qual[x].
    specimen_cd,32,2,r),")")
 ENDIF
 SELECT INTO "nl:"
  cs.*
  FROM case_specimen cs,
   (dummyt d1  WITH seq = value(size(temp->case_qual,5)))
  PLAN (d1)
   JOIN (cs
   WHERE (temp->case_qual[d1.seq].case_id=cs.case_id)
    AND cs.cancel_cd IN (null, 0)
    AND parser(spec_where1))
  DETAIL
   temp->case_qual[d1.seq].valid_case_specimens = "Y"
  WITH nocounter
 ;end select
 IF ((generic_temp->across_case_ind=1))
  SELECT INTO "nl:"
   cs.*
   FROM case_specimen cs,
    (dummyt d1  WITH seq = value(size(temp->case_qual,5)))
   PLAN (d1
    WHERE (temp->case_qual[d1.seq].correlate_case_id > 0))
    JOIN (cs
    WHERE (temp->case_qual[d1.seq].correlate_case_id=cs.case_id)
     AND cs.cancel_cd IN (null, 0)
     AND parser(spec_where2))
   DETAIL
    temp->case_qual[d1.seq].valid_compare_case_specimens = "Y"
   WITH nocounter
  ;end select
  FOR (loop1 = 1 TO value(size(temp->case_qual,5)))
    IF ((temp->case_qual[loop1].valid_compare_case_specimens="N"))
     SET temp->case_qual[loop1].valid_case_specimens = "N"
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_members_in_group)),
   prsnl p
  PLAN (d1
   WHERE (temp->case_qual[d1.seq].valid_case_specimens="Y"))
   JOIN (d2
   WHERE d2.seq <= size(temp->case_qual[d1.seq].prsnl_group_qual,5))
   JOIN (p
   WHERE (temp->case_qual[d1.seq].prsnl_group_qual[d2.seq].prsnl_id=p.person_id))
  DETAIL
   IF ((temp->case_qual[d1.seq].prsnl_group_id=0)
    AND (temp->case_qual[d1.seq].prsnl_group_qual[d2.seq].prsnl_group_id=0))
    temp->case_qual[d1.seq].prsnl_group_desc = p.name_full_formatted
   ENDIF
   temp->case_qual[d1.seq].prsnl_group_qual[d2.seq].prsnl_name_full_formatted = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pc.accession_nbr
  FROM pathology_case pc,
   (dummyt d1  WITH seq = value(size(temp->case_qual,5)))
  PLAN (d1
   WHERE (temp->case_qual[d1.seq].valid_case_specimens="Y"))
   JOIN (pc
   WHERE (temp->case_qual[d1.seq].case_id=pc.case_id))
  DETAIL
   temp->case_qual[d1.seq].case_accession = pc.accession_nbr
  WITH nocounter
 ;end select
 IF ((generic_temp->across_case_ind=1))
  SELECT INTO "nl:"
   pc.accession_nbr
   FROM pathology_case pc,
    (dummyt d1  WITH seq = value(size(temp->case_qual,5)))
   PLAN (d1
    WHERE (temp->case_qual[d1.seq].valid_compare_case_specimens="Y"))
    JOIN (pc
    WHERE (temp->case_qual[d1.seq].correlate_case_id=pc.case_id))
   DETAIL
    temp->case_qual[d1.seq].compare_to_accession = pc.accession_nbr
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  d1.seq, ce.collating_seq, accession_nbr = temp->case_qual[d1.seq].case_accession,
  ce_catalog_disp = uar_get_code_display(ce.catalog_cd)
  FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
   clinical_event ce
  PLAN (d1
   WHERE (temp->case_qual[d1.seq].valid_case_specimens="Y"))
   JOIN (ce
   WHERE (ce.accession_nbr=temp->case_qual[d1.seq].case_accession)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.record_status_cd != deleted_status_cd
    AND parser(ce_where))
  ORDER BY d1.seq, ce_catalog_disp, ce.collating_seq
  HEAD REPORT
   proc_qual = 0
  HEAD d1.seq
   proc_qual = 0
  HEAD ce_catalog_disp
   ind = locateval(locindx,1,catalog_cnt,ce.catalog_cd,catalog->catalog_qual[locindx].catalog_cd)
   IF (ind=0)
    catalog_cnt += 1, stat = alterlist(catalog->catalog_qual,catalog_cnt), catalog->catalog_qual[
    catalog_cnt].catalog_cd = ce.catalog_cd,
    catalog->catalog_qual[catalog_cnt].catalog_disp = ce_catalog_disp
   ENDIF
  DETAIL
   proc_qual += 1
   IF ((proc_qual > temp->max_dtas))
    temp->max_dtas = proc_qual
   ENDIF
   stat = alterlist(temp->case_qual[d1.seq].valid_proc_qual,proc_qual), temp->case_qual[d1.seq].
   proc_cnt = proc_qual, temp->case_qual[d1.seq].valid_proc_qual[proc_qual].discrete_task_assay_cd =
   ce.task_assay_cd,
   temp->case_qual[d1.seq].valid_proc_qual[proc_qual].ce_event_id = ce.event_id, temp->case_qual[d1
   .seq].valid_proc_qual[proc_qual].catalog_cd = ce.catalog_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce_event_id = temp->case_qual[d1.seq].valid_proc_qual[d2.seq].ce_event_id, cebr.event_id
  FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_dtas)),
   ce_blob_result cebr
  PLAN (d1
   WHERE (temp->case_qual[d1.seq].valid_case_specimens="Y"))
   JOIN (d2
   WHERE d2.seq <= size(temp->case_qual[d1.seq].valid_proc_qual,5))
   JOIN (cebr
   WHERE (temp->case_qual[d1.seq].valid_proc_qual[d2.seq].ce_event_id=cebr.event_id)
    AND cebr.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND cebr.storage_cd=blob_cd)
  ORDER BY d1.seq, ce_event_id
  HEAD d1.seq
   blob_cntr = 0
  HEAD ce_event_id
   blob_cntr = 0, recdate->datetime = cnvtdatetimeutc(cebr.valid_from_dt_tm), tblobout = "",
   blobsize = uar_get_ceblobsize(cebr.event_id,recdate)
   IF (blobsize > 0)
    stat = memrealloc(tblobout,1,build("C",blobsize)), status = uar_get_ceblob(cebr.event_id,recdate,
     tblobout,blobsize),
    CALL rtf_to_text(tblobout,1,90)
    FOR (z = 1 TO size(tmptext->qual,5))
      blob_cntr += 1, stat = alterlist(temp->case_qual[d1.seq].valid_proc_qual[d2.seq].text_qual,
       blob_cntr), temp->case_qual[d1.seq].valid_proc_qual[d2.seq].text_cnt = blob_cntr,
      temp->case_qual[d1.seq].valid_proc_qual[d2.seq].text_qual[blob_cntr].text = trim(tmptext->qual[
       z].text)
    ENDFOR
   ENDIF
  WITH nocounter, memsort
 ;end select
 IF (bno_details="T")
  SELECT INTO "nl:"
   cv.display
   FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
    (dummyt d2  WITH seq = value(temp->max_dtas)),
    code_value cv
   PLAN (d1
    WHERE (temp->case_qual[d1.seq].valid_case_specimens="Y"))
    JOIN (d2
    WHERE d2.seq <= size(temp->case_qual[d1.seq].valid_proc_qual,5))
    JOIN (cv
    WHERE (temp->case_qual[d1.seq].valid_proc_qual[d2.seq].discrete_task_assay_cd=cv.code_value))
   DETAIL
    temp->case_qual[d1.seq].valid_proc_qual[d2.seq].discrete_task_assay_disp = cv.display
   WITH nocounter
  ;end select
 ENDIF
 IF ((generic_temp->across_case_ind=1))
  SELECT INTO "nl:"
   ce.collating_seq, accession_nbr = temp->case_qual[d1.seq].compare_to_accession, d1.seq,
   ce_catalog_disp = uar_get_code_display(ce.catalog_cd)
   FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
    clinical_event ce
   PLAN (d1
    WHERE (temp->case_qual[d1.seq].valid_compare_case_specimens="Y")
     AND (temp->case_qual[d1.seq].correlate_case_id > 0))
    JOIN (ce
    WHERE (ce.accession_nbr=temp->case_qual[d1.seq].compare_to_accession)
     AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND ce.record_status_cd != deleted_status_cd
     AND parser(ce_where))
   ORDER BY d1.seq, ce_catalog_disp, ce.collating_seq
   HEAD REPORT
    compare_proc_cnt = 0
   HEAD d1.seq
    compare_proc_cnt = 0
   HEAD ce_catalog_disp
    ind = locateval(locindx,1,catalog_cnt,ce.catalog_cd,catalog->catalog_qual[locindx].catalog_cd)
    IF (ind=0)
     catalog_cnt += 1, stat = alterlist(catalog->catalog_qual,catalog_cnt), catalog->catalog_qual[
     catalog_cnt].catalog_cd = ce.catalog_cd,
     catalog->catalog_qual[catalog_cnt].catalog_disp = ce_catalog_disp
    ENDIF
   DETAIL
    compare_proc_cnt += 1
    IF ((compare_proc_cnt > temp->max_comp_dtas))
     temp->max_comp_dtas = compare_proc_cnt
    ENDIF
    stat = alterlist(temp->case_qual[d1.seq].compare_proc_qual,compare_proc_cnt), temp->case_qual[d1
    .seq].compare_proc_cnt = compare_proc_cnt, temp->case_qual[d1.seq].compare_proc_qual[
    compare_proc_cnt].discrete_task_assay_cd = ce.task_assay_cd,
    temp->case_qual[d1.seq].compare_proc_qual[compare_proc_cnt].catalog_cd = ce.catalog_cd, temp->
    case_qual[d1.seq].compare_proc_qual[compare_proc_cnt].ce_event_id = ce.event_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ce_event_id = temp->case_qual[d1.seq].compare_proc_qual[d2.seq].ce_event_id, cebr.event_id
   FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
    (dummyt d2  WITH seq = value(temp->max_comp_dtas)),
    ce_blob_result cebr
   PLAN (d1
    WHERE (temp->case_qual[d1.seq].valid_compare_case_specimens="Y"))
    JOIN (d2
    WHERE d2.seq <= size(temp->case_qual[d1.seq].compare_proc_qual,5))
    JOIN (cebr
    WHERE (temp->case_qual[d1.seq].compare_proc_qual[d2.seq].ce_event_id=cebr.event_id)
     AND cebr.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND cebr.storage_cd=blob_cd)
   ORDER BY d1.seq, ce_event_id
   HEAD d1.seq
    blob_cntr = 0
   HEAD ce_event_id
    blob_cntr = 0, recdate->datetime = cnvtdatetimeutc(cebr.valid_from_dt_tm), tblobout = "",
    blobsize = uar_get_ceblobsize(cebr.event_id,recdate)
    IF (blobsize > 0)
     stat = memrealloc(tblobout,1,build("C",blobsize)), status = uar_get_ceblob(cebr.event_id,recdate,
      tblobout,blobsize),
     CALL rtf_to_text(tblobout,1,90)
     FOR (z = 1 TO size(tmptext->qual,5))
       blob_cntr += 1, stat = alterlist(temp->case_qual[d1.seq].compare_proc_qual[d2.seq].text_qual,
        blob_cntr), temp->case_qual[d1.seq].compare_proc_qual[d2.seq].text_cnt = blob_cntr,
       temp->case_qual[d1.seq].compare_proc_qual[d2.seq].text_qual[blob_cntr].text = trim(tmptext->
        qual[z].text)
     ENDFOR
    ENDIF
   WITH nocounter, memsort
  ;end select
  IF (bno_details="T")
   SELECT INTO "nl:"
    cv.display
    FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
     (dummyt d2  WITH seq = value(temp->max_comp_dtas)),
     code_value cv
    PLAN (d1
     WHERE (temp->case_qual[d1.seq].valid_compare_case_specimens="Y"))
     JOIN (d2
     WHERE d2.seq <= size(temp->case_qual[d1.seq].compare_proc_qual,5))
     JOIN (cv
     WHERE (temp->case_qual[d1.seq].compare_proc_qual[d2.seq].discrete_task_assay_cd=cv.code_value))
    DETAIL
     temp->case_qual[d1.seq].compare_proc_qual[d2.seq].discrete_task_assay_disp = cv.display
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  adet.display
  FROM ap_dc_evaluation_term adet,
   (dummyt d1  WITH seq = value(size(temp->case_qual,5)))
  PLAN (d1
   WHERE (temp->case_qual[d1.seq].init_eval_term_id > 0)
    AND (temp->case_qual[d1.seq].valid_case_specimens="Y"))
   JOIN (adet
   WHERE (temp->case_qual[d1.seq].init_eval_term_id=adet.evaluation_term_id))
  DETAIL
   temp->case_qual[d1.seq].init_eval_term_disp = adet.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  addt.display
  FROM ap_dc_discrepancy_term addt,
   (dummyt d1  WITH seq = value(size(temp->case_qual,5)))
  PLAN (d1
   WHERE (temp->case_qual[d1.seq].init_discrep_term_id > 0)
    AND (temp->case_qual[d1.seq].valid_case_specimens="Y"))
   JOIN (addt
   WHERE (temp->case_qual[d1.seq].init_discrep_term_id=addt.discrepancy_term_id))
  DETAIL
   temp->case_qual[d1.seq].init_discrep_term_disp = addt.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d1.seq, lt.long_text_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(temp->case_qual,5)))
  PLAN (d1
   WHERE (temp->case_qual[d1.seq].valid_case_specimens="Y")
    AND (temp->case_qual[d1.seq].long_text_id > 0))
   JOIN (lt
   WHERE (lt.long_text_id=temp->case_qual[d1.seq].long_text_id)
    AND lt.parent_entity_name="AP_DC_EVENT")
  ORDER BY lt.long_text_id
  HEAD REPORT
   tmplt_cntr = 0
  HEAD d1.seq
   tmplt_cntr = 0, temp->case_qual[d1.seq].long_text_cntr = 0
  DETAIL
   CALL rtf_to_text(lt.long_text,1,100)
   FOR (z = 1 TO size(tmptext->qual,5))
     tmplt_cntr += 1, stat = alterlist(temp->case_qual[d1.seq].long_text_qual,tmplt_cntr), temp->
     case_qual[d1.seq].long_text_cntr = tmplt_cntr,
     temp->case_qual[d1.seq].long_text_qual[tmplt_cntr].text = trim(tmptext->qual[z].text)
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pg.prsnl_group_name
  FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
   prsnl_group pg
  PLAN (d1
   WHERE (temp->case_qual[d1.seq].prsnl_group_id > 0)
    AND (temp->case_qual[d1.seq].valid_case_specimens="Y"))
   JOIN (pg
   WHERE (temp->case_qual[d1.seq].prsnl_group_id=pg.prsnl_group_id))
  DETAIL
   temp->case_qual[d1.seq].prsnl_group_desc = pg.prsnl_group_name
  WITH nocounter
 ;end select
 FOR (loop1 = 1 TO size(temp->case_qual,5))
   FOR (loop2 = 1 TO size(temp->case_qual[loop1].valid_proc_qual,5))
     FOR (loop3 = 1 TO size(generic_temp->study_id_qual,5))
       IF ((generic_temp->study_id_qual[loop3].task_assay_cd=temp->case_qual[loop1].valid_proc_qual[
       loop2].discrete_task_assay_cd))
        SET temp->case_qual[loop1].valid_proc_qual[loop2].discrete_task_assay_disp = generic_temp->
        study_id_qual[loop3].task_assay_disp
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 FOR (loop1 = 1 TO size(temp->case_qual,5))
   FOR (loop2 = 1 TO size(temp->case_qual[loop1].compare_proc_qual,5))
     FOR (loop3 = 1 TO size(generic_temp->study_id_qual,5))
       IF ((generic_temp->study_id_qual[loop3].task_assay_cd=temp->case_qual[loop1].
       compare_proc_qual[loop2].discrete_task_assay_cd))
        SET temp->case_qual[loop1].compare_proc_qual[loop2].discrete_task_assay_disp = generic_temp->
        study_id_qual[loop3].task_assay_disp
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 SET temp_print->max_members_in_group = temp->max_members_in_group
 SET cntr = 0
 FOR (loop1 = 1 TO size(temp->case_qual,5))
   IF ((temp->case_qual[loop1].valid_case_specimens="Y"))
    SET cntr += 1
    SET stat = alterlist(temp_print->case_qual,cntr)
    SET temp_print->case_qual[cntr].num_of_members = temp->case_qual[loop1].num_of_members
    SET temp_print->case_qual[cntr].prsnl_group_id = temp->case_qual[loop1].prsnl_group_id
    SET temp_print->case_qual[cntr].prsnl_group_desc = temp->case_qual[loop1].prsnl_group_desc
    SET stat = alterlist(temp_print->case_qual[cntr].prsnl_group_qual,value(size(temp->case_qual[
       loop1].prsnl_group_qual,5)))
    FOR (loop2 = 1 TO size(temp->case_qual[loop1].prsnl_group_qual,5))
     SET temp_print->case_qual[cntr].prsnl_group_qual[loop2].prsnl_id = temp->case_qual[loop1].
     prsnl_group_qual[loop2].prsnl_id
     SET temp_print->case_qual[cntr].prsnl_group_qual[loop2].prsnl_name_full_formatted = temp->
     case_qual[loop1].prsnl_group_qual[loop2].prsnl_name_full_formatted
    ENDFOR
    SET temp_print->case_qual[cntr].case_id = temp->case_qual[loop1].case_id
    SET temp_print->case_qual[cntr].case_accession = temp->case_qual[loop1].case_accession
    SET temp_print->case_qual[cntr].proc_cnt = temp->case_qual[loop1].proc_cnt
    SET stat = alterlist(temp_print->case_qual[cntr].valid_proc_qual,temp->case_qual[loop1].proc_cnt)
    FOR (loop2 = 1 TO temp->case_qual[loop1].proc_cnt)
      SET temp_print->case_qual[cntr].valid_proc_qual[loop2].discrete_task_assay_cd = temp->
      case_qual[loop1].valid_proc_qual[loop2].discrete_task_assay_cd
      SET temp_print->case_qual[cntr].valid_proc_qual[loop2].discrete_task_assay_disp = temp->
      case_qual[loop1].valid_proc_qual[loop2].discrete_task_assay_disp
      SET temp_print->case_qual[cntr].valid_proc_qual[loop2].catalog_cd = temp->case_qual[loop1].
      valid_proc_qual[loop2].catalog_cd
      SET temp_print->case_qual[cntr].valid_proc_qual[loop2].text_cnt = temp->case_qual[loop1].
      valid_proc_qual[loop2].text_cnt
      SET stat = alterlist(temp_print->case_qual[cntr].valid_proc_qual[loop2].text_qual,temp->
       case_qual[loop1].valid_proc_qual[loop2].text_cnt)
      FOR (loop3 = 1 TO temp->case_qual[loop1].valid_proc_qual[loop2].text_cnt)
        SET temp_print->case_qual[cntr].valid_proc_qual[loop2].text_qual[loop3].text = temp->
        case_qual[loop1].valid_proc_qual[loop2].text_qual[loop3].text
      ENDFOR
    ENDFOR
    SET temp_print->case_qual[cntr].correlate_case_id = temp->case_qual[loop1].correlate_case_id
    SET temp_print->case_qual[cntr].compare_to_accession = temp->case_qual[loop1].
    compare_to_accession
    SET temp_print->case_qual[cntr].compare_proc_cnt = temp->case_qual[loop1].compare_proc_cnt
    SET stat = alterlist(temp_print->case_qual[cntr].compare_proc_qual,temp->case_qual[loop1].
     compare_proc_cnt)
    FOR (loop2 = 1 TO temp->case_qual[loop1].compare_proc_cnt)
      SET temp_print->case_qual[cntr].compare_proc_qual[loop2].discrete_task_assay_cd = temp->
      case_qual[loop1].compare_proc_qual[loop2].discrete_task_assay_cd
      SET temp_print->case_qual[cntr].compare_proc_qual[loop2].discrete_task_assay_disp = temp->
      case_qual[loop1].compare_proc_qual[loop2].discrete_task_assay_disp
      SET temp_print->case_qual[cntr].compare_proc_qual[loop2].catalog_cd = temp->case_qual[loop1].
      compare_proc_qual[loop2].catalog_cd
      SET temp_print->case_qual[cntr].compare_proc_qual[loop2].text_cnt = temp->case_qual[loop1].
      compare_proc_qual[loop2].text_cnt
      SET stat = alterlist(temp_print->case_qual[cntr].compare_proc_qual[loop2].text_qual,temp->
       case_qual[loop1].compare_proc_qual[loop2].text_cnt)
      FOR (loop3 = 1 TO temp->case_qual[loop1].compare_proc_qual[loop2].text_cnt)
        SET temp_print->case_qual[cntr].compare_proc_qual[loop2].text_qual[loop3].text = temp->
        case_qual[loop1].compare_proc_qual[loop2].text_qual[loop3].text
      ENDFOR
    ENDFOR
    SET temp_print->case_qual[cntr].init_eval_term_id = temp->case_qual[loop1].init_eval_term_id
    SET temp_print->case_qual[cntr].init_eval_term_disp = temp->case_qual[loop1].init_eval_term_disp
    SET temp_print->case_qual[cntr].init_discrep_term_id = temp->case_qual[loop1].
    init_discrep_term_id
    SET temp_print->case_qual[cntr].init_discrep_term_disp = temp->case_qual[loop1].
    init_discrep_term_disp
    SET temp_print->case_qual[cntr].disagree_reason_cd = temp->case_qual[loop1].disagree_reason_cd
    SET temp_print->case_qual[cntr].disagree_reason_disp = temp->case_qual[loop1].
    disagree_reason_disp
    SET temp_print->case_qual[cntr].investigation_cd = temp->case_qual[loop1].investigation_cd
    SET temp_print->case_qual[cntr].investigation_disp = temp->case_qual[loop1].investigation_disp
    SET temp_print->case_qual[cntr].resolution_cd = temp->case_qual[loop1].resolution_cd
    SET temp_print->case_qual[cntr].resolution_disp = temp->case_qual[loop1].resolution_disp
    SET temp_print->case_qual[cntr].final_eval_term_id = temp->case_qual[loop1].final_eval_term_id
    SET temp_print->case_qual[cntr].final_eval_term_disp = temp->case_qual[loop1].
    final_eval_term_disp
    SET temp_print->case_qual[cntr].final_discrep_term_id = temp->case_qual[loop1].
    final_discrep_term_id
    SET temp_print->case_qual[cntr].final_discrep_term_disp = temp->case_qual[loop1].
    final_discrep_term_disp
    SET temp_print->case_qual[cntr].long_text_id = temp->case_qual[loop1].long_text_id
    SET temp_print->case_qual[cntr].long_text_cntr = temp->case_qual[loop1].long_text_cntr
    SET stat = alterlist(temp_print->case_qual[cntr].long_text_qual,size(temp->case_qual[loop1].
      long_text_qual,5))
    FOR (loop2 = 1 TO temp->case_qual[loop1].long_text_cntr)
      SET temp_print->case_qual[cntr].long_text_qual[loop2].text = temp->case_qual[loop1].
      long_text_qual[loop2].text
    ENDFOR
    SET temp_print->case_qual[cntr].initiated_prsnl_id = temp->case_qual[loop1].initiated_prsnl_id
    SET temp_print->case_qual[cntr].initiated_prsnl_name = temp->case_qual[loop1].
    initiated_prsnl_name
    SET temp_print->case_qual[cntr].initiated_dt_tm = temp->case_qual[loop1].initiated_dt_tm
    SET temp_print->case_qual[cntr].system_group_person = temp->case_qual[loop1].system_group_person
   ENDIF
 ENDFOR
 SET stat = alterlist(temp->case_qual,0)
#report_maker
 EXECUTE cpm_create_file_name_logical "aps_corr_wrksht", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 DECLARE uar_fmt_accession(p1,p2) = c25
 SELECT INTO value(reply->print_status_data.print_filename)
  raw_accession = temp_print->case_qual[d1.seq].case_accession, raw_comp_accession = temp_print->
  case_qual[d1.seq].compare_to_accession, init_eval_term_id = temp_print->case_qual[d1.seq].
  init_eval_term_id,
  system_group_person = temp_print->case_qual[d1.seq].system_group_person, prsnl_group_desc =
  temp_print->case_qual[d1.seq].prsnl_group_desc
  FROM (dummyt d1  WITH seq = value(size(temp_print->case_qual,5))),
   (dummyt d2  WITH seq = value(temp_print->max_members_in_group))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp_print->case_qual[d1.seq].prsnl_group_qual,5))
  ORDER BY system_group_person, prsnl_group_desc, raw_accession,
   raw_comp_accession
  HEAD REPORT
   line1 = fillstring(125,"-"), 20stars = fillstring(20,"*"), bfirstpage = "Y",
   sformataccession = fillstring(22," "), sformatcompaccession = fillstring(22," "), head_cntr = 0
  HEAD PAGE
   date1 = format(curdate,"@SHORTDATE;;D"), time1 = format(curtime,"@TIMENOSECONDS;;M"), beg_date =
   format(request->beg_dt_tm,"@SHORTDATE;;D"),
   end_date = format(request->end_dt_tm,"@SHORTDATE;;D"), row + 1, col 0,
   captions->title,
   CALL center(captions->pathnet,0,132), col 110,
   captions->dt, col 117, date1,
   row + 1, col 0, captions->dir,
   col 110, captions->tm, col 117,
   time1, row + 1,
   CALL center(captions->diag,0,132),
   col 112, captions->bye, col 117,
   request->scuruser"##############", row + 1, col 110,
   captions->pg, col 117, curpage"###",
   row + 2
   IF (bfirstpage="Y")
    col 0, captions->study, generic_temp->study_description,
    row + 1, col 0, captions->pre,
    col 16, last_pref = value(size(generic_temp->prefix_qual,5))
    IF (last_pref=0)
     captions->all_pre
    ELSE
     FOR (x = 1 TO last_pref)
       generic_temp->prefix_qual[x].site_display, generic_temp->prefix_qual[x].prefix_name
       IF (x < last_pref)
        ", "
       ENDIF
       col + 1
       IF (col > 120)
        row + 1, col 16
       ENDIF
     ENDFOR
    ENDIF
    row + 1, col 0, captions->spec,
    col 16
    IF ((request->specimen_cnt=0))
     captions->all_spec
    ELSE
     last_spec = value(size(generic_temp->specimen_header_qual,5))
     FOR (x = 1 TO last_spec)
       generic_temp->specimen_header_qual[x].specimen_display
       IF (x < last_spec)
        ", "
       ENDIF
       col + 1
       IF (col > 110)
        row + 1, col 16
       ENDIF
     ENDFOR
    ENDIF
    IF ((generic_temp->across_case_ind=1))
     row + 1, col 0, captions->comp,
     col 16
     IF ((request->specimen_comp_cnt=0))
      captions->all_spec
     ELSE
      last_spec = value(size(generic_temp->comp_specimen_header_qual,5))
      FOR (x = 1 TO last_spec)
        generic_temp->comp_specimen_header_qual[x].specimen_display
        IF (x < last_spec)
         ", "
        ENDIF
        col + 1
        IF (col > 110)
         row + 1, col 16
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    row + 1, col 0, captions->beg_dt,
    col 16, beg_date, row + 1,
    col 0, captions->end_dt, col 16,
    end_date, row + 1, col 0,
    captions->grp, col 16
    IF ((request->group_param="A"))
     captions->all_grp
    ELSEIF ((request->group_param="S"))
     generic_temp->group_name
    ELSEIF ((request->group_param="N"))
     captions->no_grp
    ENDIF
    row + 1, col 0, captions->path,
    col 16
    IF ((request->pathologist_param="N"))
     captions->no_path
    ELSEIF ((request->pathologist_param="S"))
     generic_temp->requesting_path_name_full_formatted
    ELSEIF ((request->pathologist_param="A"))
     captions->all_path
    ENDIF
    row + 2,
    CALL center(20stars,0,132), bfirstpage = "N"
   ENDIF
   IF (value(size(temp_print->case_qual,5))=0)
    row + 2,
    CALL center(captions->no_case,0,132), row + 2,
    CALL center(20stars,0,132)
   ENDIF
  HEAD prsnl_group_desc
   IF (head_cntr > 0
    AND (request->bpagebreak="T"))
    BREAK
   ENDIF
   head_cntr += 1, row + 2, col 0,
   "CORRELATION EVALUATED BY: "
   IF (system_group_person="2GROUP ")
    col 30, temp_print->case_qual[d1.seq].prsnl_group_desc
   ELSEIF (system_group_person="3PERSON")
    col 30, temp_print->case_qual[d1.seq].prsnl_group_desc
   ENDIF
  DETAIL
   init_date = format(temp_print->case_qual[d1.seq].initiated_dt_tm,"@SHORTDATE;;D"), row + 2, col 0,
   captions->cas, col 21, captions->compto,
   col 42, captions->init, col 53,
   captions->f_eval, col 86, captions->f_dis,
   row + 1, col 0, "-------------------",
   col 21, "-------------------", col 42,
   "---------", col 53, "-------------------------------",
   col 86, "--------------------------------", sformataccession = uar_fmt_accession(temp_print->
    case_qual[d1.seq].case_accession,size(trim(temp_print->case_qual[d1.seq].case_accession),1)),
   row + 1, col 0, sformataccession,
   col 21
   IF (raw_comp_accession > "")
    sformatcompaccession = uar_fmt_accession(temp_print->case_qual[d1.seq].compare_to_accession,size(
      trim(temp_print->case_qual[d1.seq].compare_to_accession),1)), sformatcompaccession
   ELSE
    captions->na
   ENDIF
   col 42, init_date, col 53,
   "_______________________________", col 86, "________________________________"
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 21, captions->i_eval
   IF ((temp_print->case_qual[d1.seq].init_eval_term_id > 0))
    col 41, temp_print->case_qual[d1.seq].init_eval_term_disp
   ELSE
    col 41, "___________________________________________"
   ENDIF
   row + 1, col 21, captions->i_dis
   IF ((temp_print->case_qual[d1.seq].init_discrep_term_disp > ""))
    temp_print->case_qual[d1.seq].init_discrep_term_disp
   ELSE
    col 42, "__________________________________________"
   ENDIF
   row + 1, col 21, captions->dis_rea
   IF ((temp_print->case_qual[d1.seq].disagree_reason_disp > ""))
    temp_print->case_qual[d1.seq].disagree_reason_disp
   ELSE
    col 42, "__________________________________________"
   ENDIF
   row + 1, col 21, captions->invest
   IF ((temp_print->case_qual[d1.seq].investigation_disp > ""))
    temp_print->case_qual[d1.seq].investigation_disp
   ELSE
    col 36, "________________________________________________"
   ENDIF
   row + 1, col 21, captions->res
   IF ((temp_print->case_qual[d1.seq].resolution_disp > ""))
    temp_print->case_qual[d1.seq].resolution_disp
   ELSE
    col 33, "___________________________________________________"
   ENDIF
   IF (system_group_person="2GROUP ")
    row + 1, col 21, captions->grp_mem
    FOR (loop1 = 1 TO temp_print->case_qual[d1.seq].num_of_members)
      col 40, temp_print->case_qual[d1.seq].prsnl_group_qual[loop1].prsnl_name_full_formatted, row +
      1
    ENDFOR
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   IF ((temp_print->case_qual[d1.seq].long_text_cntr > 0))
    row + 1, col 21, captions->corr_com
    FOR (loop1 = 1 TO temp_print->case_qual[d1.seq].long_text_cntr)
      row + 1, col 21, temp_print->case_qual[d1.seq].long_text_qual[loop1].text
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
    ENDFOR
   ELSE
    row + 1
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 21, captions->cases,
   sformataccession = uar_fmt_accession(temp_print->case_qual[d1.seq].case_accession,size(trim(
      temp_print->case_qual[d1.seq].case_accession),1)), col 27, sformataccession,
   temp_catlog_cd = 0.0
   FOR (loop1 = 1 TO temp_print->case_qual[d1.seq].proc_cnt)
    IF ((temp_print->case_qual[d1.seq].valid_proc_qual[loop1].catalog_cd != temp_catlog_cd))
     ind = locateval(locindx,1,catalog_cnt,temp_print->case_qual[d1.seq].valid_proc_qual[loop1].
      catalog_cd,catalog->catalog_qual[locindx].catalog_cd)
     IF (ind > 0)
      row + 1, col 21, captions->rpt,
      " ", catalog->catalog_qual[ind].catalog_disp, row + 1
     ENDIF
     temp_catlog_cd = temp_print->case_qual[d1.seq].valid_proc_qual[loop1].catalog_cd
    ENDIF
    ,
    IF ((temp_print->case_qual[d1.seq].valid_proc_qual[loop1].text_cnt > 0))
     row + 1, col 21, captions->section,
     col 30, temp_print->case_qual[d1.seq].valid_proc_qual[loop1].discrete_task_assay_disp
     FOR (loop2 = 1 TO temp_print->case_qual[d1.seq].valid_proc_qual[loop1].text_cnt)
       row + 1, col 21, temp_print->case_qual[d1.seq].valid_proc_qual[loop1].text_qual[loop2].text
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
     ENDFOR
     row + 1
    ENDIF
   ENDFOR
   IF ((generic_temp->across_case_ind=1))
    temp_catlog_cd = 0.0, row + 2, col 21,
    captions->cases, sformatcompaccession = uar_fmt_accession(temp_print->case_qual[d1.seq].
     compare_to_accession,size(trim(temp_print->case_qual[d1.seq].compare_to_accession),1)), col 27,
    sformatcompaccession
    FOR (loop1 = 1 TO temp_print->case_qual[d1.seq].compare_proc_cnt)
     IF ((temp_print->case_qual[d1.seq].compare_proc_qual[loop1].catalog_cd != temp_catlog_cd))
      ind = locateval(locindx,1,catalog_cnt,temp_print->case_qual[d1.seq].compare_proc_qual[loop1].
       catalog_cd,catalog->catalog_qual[locindx].catalog_cd)
      IF (ind > 0)
       row + 1, col 21, captions->rpt,
       " ", catalog->catalog_qual[ind].catalog_disp, row + 1
      ENDIF
      temp_catlog_cd = temp_print->case_qual[d1.seq].compare_proc_qual[loop1].catalog_cd
     ENDIF
     ,
     IF ((temp_print->case_qual[d1.seq].compare_proc_qual[loop1].text_cnt > 0))
      row + 1, col 21, captions->section,
      " ", col 30, temp_print->case_qual[d1.seq].compare_proc_qual[loop1].discrete_task_assay_disp
      FOR (loop2 = 1 TO temp_print->case_qual[d1.seq].compare_proc_qual[loop1].text_cnt)
        row + 1, col 21, temp_print->case_qual[d1.seq].compare_proc_qual[loop1].text_qual[loop2].text
        IF (((row+ 10) > maxrow))
         BREAK
        ENDIF
      ENDFOR
      row + 1
     ENDIF
    ENDFOR
   ENDIF
  FOOT  prsnl_group_desc
   row + 1,
   CALL center(20stars,0,132)
  FOOT PAGE
   wk = format(curdate,"@WEEKDAYABBREV;;D"), day = format(curdate,"@MEDIUMDATE;;D"), today = concat(
    wk," ",day),
   row 60, col 0, line1,
   row + 1, col 0, captions->title,
   col 53, today, col 110,
   captions->pg, col 117, curpage"###",
   row + 1, col 55, captions->cont
  FOOT REPORT
   col 55, "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
#exit_script
END GO
