CREATE PROGRAM aps_rpt_followup_review:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD reply(
   1 ops_event = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 description = c40
   1 proc_qual[*]
     2 task_assay_cd = f8
   1 pat_qual[*]
     2 patient = c25
     2 id = c20
     2 encntr_id = f8
     2 init_case = c19
     2 verified = c8
     2 rev_case = c19
     2 accession_nbr = c21
     2 collected = c8
     2 ievent_id = f8
     2 idetail_qual[*]
       3 init_qual[*]
         4 itext = vc
         4 compression_cd = f8
     2 rdetail_qual[*]
       3 review_qual[*]
         4 rtext = vc
         4 compression_cd = f8
   1 site_name = vc
 )
 RECORD temp_pref(
   1 pref_qual[*]
     2 prefix_cd = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_display = c40
 )
 RECORD captions(
   1 rpt = vc
   1 dt = vc
   1 dir = vc
   1 tm = vc
   1 foll = vc
   1 bye = vc
   1 pg = vc
   1 typ = vc
   1 none = vc
   1 pat = vc
   1 id = vc
   1 init_case = vc
   1 ver = vc
   1 rev_cse = vc
   1 collect = vc
   1 init_c = vc
   1 not_ava = vc
   1 rev_c = vc
   1 title = vc
   1 cont = vc
   1 end_rpt = vc
   1 pre = vc
 )
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"t1","REPORT: APS_RPT_FOLLOWUP_REVIEW.PRG")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t2","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t3","DIRECTORY:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t4","TIME:")
 SET captions->foll = uar_i18ngetmessage(i18nhandle,"t5","FOLLOW-UP TRACKING TERMINATION REVIEW")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t6","BY:")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t7","PAGE:")
 SET captions->typ = uar_i18ngetmessage(i18nhandle,"t8","TYPE:")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"t9",
  "!!! NO PATIENTS QUALIFIED FOR THIS REPORT !!!")
 SET captions->pat = uar_i18ngetmessage(i18nhandle,"t10","PATIENT")
 SET captions->id = uar_i18ngetmessage(i18nhandle,"t11","ID")
 SET captions->init_case = uar_i18ngetmessage(i18nhandle,"t12","INITIATING CASE")
 SET captions->ver = uar_i18ngetmessage(i18nhandle,"t13","VERIFIED")
 SET captions->rev_cse = uar_i18ngetmessage(i18nhandle,"t14","REVIEW CASE")
 SET captions->collect = uar_i18ngetmessage(i18nhandle,"t15","COLLECTED")
 SET captions->init_c = uar_i18ngetmessage(i18nhandle,"t16","INITIATING CASE:")
 SET captions->not_ava = uar_i18ngetmessage(i18nhandle,"t17","* * * REPORT TEXT NOT AVAILABLE * * *")
 SET captions->rev_c = uar_i18ngetmessage(i18nhandle,"t18","REVIEW CASE:")
 SET captions->title = uar_i18ngetmessage(i18nhandle,"t19",
  "REPORT: FOLLOW-UP TRACKING TERMINATION REVIEW")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"t20","CONTINUED...")
 SET captions->end_rpt = uar_i18ngetmessage(i18nhandle,"t21","### END OF REPORT ###")
 SET captions->pre = uar_i18ngetmessage(i18nhandle,"t22","PREFIX(ES)")
 DECLARE sblobout = gvc WITH protect, noconstant(" ")
 DECLARE blob_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",25,"BLOB"))
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET site_name = "Your Site Name Here!"
 SET deleted_status_cd = 0.0
 SET cdf_meaning = fillstring(10," ")
 DECLARE pat_cnt = i4 WITH noconstant(0)
 DECLARE lprefixes = i4 WITH protect, noconstant(0)
 DECLARE gyn_case_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ngyn_case_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ngyn_case_type_found = c1 WITH protect, noconstant("N")
 DECLARE gyn_case_type_found = c1 WITH protect, noconstant("N")
 DECLARE sprefix_name = vc WITH protect, noconstant(" ")
 DECLARE ssitedisp = vc WITH protect, noconstant(" ")
 DECLARE sprefixparser = vc WITH protect, noconstant(" ")
 DECLARE pref_cntr = i4 WITH protect, noconstant(0)
 SET code_set = 48
 SET code_value = 0.0
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_status_cd = code_value
 SET code_set = 1301
 SET code_value = 0.0
 SET cdf_meaning = "GYN"
 EXECUTE cpm_get_cd_for_cdf
 SET gyn_case_type_cd = code_value
 SET code_set = 1301
 SET code_value = 0.0
 SET cdf_meaning = "NGYN"
 EXECUTE cpm_get_cd_for_cdf
 SET ngyn_case_type_cd = code_value
 IF (textlen(trim(request->batch_selection)) > 0)
  DECLARE text = c100
  DECLARE real = f8
  DECLARE six = i2
  DECLARE pos = i2
  DECLARE startpos2 = i2
  DECLARE len = i4
  DECLARE endstring = c2
  SUBROUTINE get_text(startpos,textstring,delimit)
    SET siz = size(trim(textstring),1)
    SET pos = startpos
    SET endstring = "F"
    WHILE (pos <= siz)
     IF (substring(pos,1,trim(textstring))=delimit)
      IF (pos=siz)
       SET endstring = "T"
      ENDIF
      SET len = (pos - startpos)
      SET text = substring(startpos,len,trim(textstring))
      SET real = cnvtreal(trim(text))
      SET startpos = (pos+ 1)
      SET startpos2 = (pos+ 1)
      SET pos = siz
     ENDIF
     SET pos += 1
    ENDWHILE
  END ;Subroutine
  DECLARE site_code_len = i4 WITH protect, noconstant(0)
  DECLARE site_code = f8 WITH protect, noconstant(0.0)
  DECLARE site_prefix_str = vc WITH protect, noconstant("")
  DECLARE prefix_str = vc WITH protect, noconstant("")
  DECLARE site_str = vc WITH protect, noconstant("")
  DECLARE prefix_code = f8 WITH protect, noconstant(0.0)
  DECLARE raw_ft_type_str = vc WITH protect, noconstant("")
  DECLARE raw_prefix_str = vc WITH protect, noconstant("")
  DECLARE printer = vc WITH protect, noconstant("")
  DECLARE copies = i4 WITH protect, noconstant(0)
  IF (textlen(trim(request->output_dist))=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with output_dist!"
   GO TO end_script
  ENDIF
  SELECT INTO "nl:"
   x = 1
   DETAIL
    CALL get_text(x,trim(request->batch_selection),"|"), raw_ft_type_str = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|")
    IF (substring(2,1,text)=",")
     text = concat(" ",text)
    ENDIF
    IF (size(trim(text)) > 0)
     raw_prefix_str = concat(trim(text),",")
    ENDIF
    request->curuser = "Operations",
    CALL get_text(1,trim(request->output_dist),"|"), printer = trim(text),
    CALL get_text(startpos2,trim(request->output_dist),"|"), copies = cnvtint(trim(text))
   WITH nocounter
  ;end select
  SET startpos2 = 1
  SET endstring = "F"
  SET new_size = 0
  SELECT INTO "nl:"
   ase.accession_setup_id
   FROM accession_setup ase
   WHERE ase.accession_setup_id > 0
   DETAIL
    site_code_len = ase.site_code_length
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with accession setup!"
   GO TO exit_script
  ENDIF
  IF (size(trim(raw_prefix_str))=0)
   SET endstring = "T"
  ENDIF
  WHILE (endstring="F")
    SELECT INTO "nl:"
     x = 1
     DETAIL
      CALL get_text(startpos2,trim(raw_prefix_str),","), site_prefix_str = text
     WITH nocounter
    ;end select
    IF (site_code_len > 0)
     SET site_str = substring(1,site_code_len,trim(site_prefix_str))
     SET prefix_str = substring((1+ site_code_len),len,trim(site_prefix_str))
     IF (size(trim(site_str)) > 0)
      SET site_code = 0.0
      SET site_code = uar_get_code_by("DISPLAYKEY",2062,nullterm(site_str))
      IF (site_code=0.0)
       SET reply->status_data.status = "F"
       SET reply->ops_event = "Failure - Error with codeset 2062"
       GO TO exit_script
      ENDIF
     ELSE
      SET site_code = 0.0
     ENDIF
    ELSE
     SET site_code = 0.0
     SET prefix_str = trim(site_prefix_str)
    ENDIF
    SELECT INTO "nl:"
     ap.prefix_id
     FROM ap_prefix ap
     WHERE site_code=ap.site_cd
      AND prefix_str=ap.prefix_name
     DETAIL
      new_size += 1, stat = alterlist(request->prefix_qual,new_size), request->prefix_qual[new_size].
      prefix_id = ap.prefix_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->ops_event = "Failure - Error with prefix setup!"
     GO TO exit_script
    ENDIF
  ENDWHILE
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE 1317=cv.code_set
    AND raw_ft_type_str=cv.display
   DETAIL
    request->followup_type_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with codeset 1317!"
   GO TO end_script
  ENDIF
 ENDIF
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 CALL initresourcesecurity(1)
 SET lprefixes = 0
 IF (value(size(request->prefix_qual,5))=0)
  SET sprefixparser = "1 = 1"
 ELSE
  SET sprefixparser = concat("expand(lPrefixes,1,value(size(request->prefix_qual,5)),",
   "ap.prefix_id,request->prefix_qual[lPrefixes].prefix_id)")
 ENDIF
 SELECT INTO "nl:"
  site_prefix = build(substring(1,5,trim(uar_get_code_display(ap.site_cd))),ap.prefix_name), ap
  .prefix_name, ap.prefix_id,
  ap.site_cd
  FROM ap_prefix ap
  WHERE ap.case_type_cd IN (gyn_case_type_cd, ngyn_case_type_cd)
   AND parser(sprefixparser)
  ORDER BY site_prefix
  HEAD REPORT
   pref_cntr = 0
  HEAD site_prefix
   IF (isresourceviewable(ap.service_resource_cd))
    pref_cntr += 1
    IF (pref_cntr > size(temp_pref->pref_qual,5))
     stat = alterlist(temp_pref->pref_qual,(pref_cntr+ 9))
    ENDIF
    temp_pref->pref_qual[pref_cntr].prefix_cd = ap.prefix_id, temp_pref->pref_qual[pref_cntr].
    prefix_name = ap.prefix_name, temp_pref->pref_qual[pref_cntr].site_cd = ap.site_cd,
    temp_pref->pref_qual[pref_cntr].site_display = substring(1,5,trim(uar_get_code_display(ap.site_cd
       )))
    IF (ap.case_type_cd=gyn_case_type_cd)
     gyn_case_type_found = "Y"
    ENDIF
    IF (ap.case_type_cd=ngyn_case_type_cd)
     ngyn_case_type_found = "Y"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(temp_pref->pref_qual,pref_cntr)
 IF (getresourcesecuritystatus(0)="F")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(0)
  SET error_cnt += 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ftt.description, ftt.followup_tracking_type_cd, ftrp.task_assay_cd
  FROM ap_ft_type ftt,
   ap_ft_report_proc ftrp
  PLAN (ftt
   WHERE (request->followup_type_cd=ftt.followup_tracking_type_cd))
   JOIN (ftrp
   WHERE (request->followup_type_cd=ftrp.followup_tracking_type_cd))
  ORDER BY ftt.followup_tracking_type_cd
  HEAD REPORT
   proc_cnt = 0
  HEAD ftt.followup_tracking_type_cd
   proc_cnt = 0, temp->description = ftt.description
  DETAIL
   proc_cnt += 1, stat = alterlist(temp->proc_qual,proc_cnt), temp->proc_qual[proc_cnt].task_assay_cd
    = ftrp.task_assay_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO report_maker
 ENDIF
 SET ce_where = fillstring(1500," ")
 SET ce2_where = fillstring(1500," ")
 FOR (x = 1 TO value(size(temp->proc_qual,5)))
   IF (x < value(size(temp->proc_qual,5)))
    SET ce_where = build(trim(ce_where),temp->proc_qual[x].task_assay_cd,",")
   ELSE
    SET ce_where = build(trim(ce_where),temp->proc_qual[x].task_assay_cd)
   ENDIF
 ENDFOR
 SET ce2_where = concat("ce2.task_assay_cd in(",trim(ce_where),")")
 SET ce_where = concat("ce.task_assay_cd in(",trim(ce_where),")")
 SET lprefixes = 0
 SET sprefixparser = concat("expand(lPrefixes,1,value(size(temp_pref->pref_qual,5)),",
  "pc.prefix_id,temp_pref->pref_qual[lPrefixes].prefix_cd)")
 SELECT INTO "nl:"
  ftcl.followup_event_id, ftcl.review_case_id, fte.followup_event_id,
  p.name_full_formatted, pc.accession_nbr, pc_accession_nbr = decode(pc.seq,uar_fmt_accession(pc
    .accession_nbr,size(pc.accession_nbr,1)),""),
  pc.main_report_cmplete_dt_tm, pc2.accession_nbr, pc2_accession_nbr = decode(pc.seq,
   uar_fmt_accession(pc2.accession_nbr,size(pc2.accession_nbr,1)),""),
  cr.event_id
  FROM ft_term_candidate_list ftcl,
   ap_ft_event fte,
   person p,
   pathology_case pc,
   cyto_screening_event cse,
   pathology_case pc2
  PLAN (ftcl)
   JOIN (fte
   WHERE ftcl.followup_event_id=fte.followup_event_id
    AND (request->followup_type_cd=fte.followup_type_cd))
   JOIN (p
   WHERE fte.person_id=p.person_id)
   JOIN (pc
   WHERE fte.case_id=pc.case_id
    AND parser(sprefixparser))
   JOIN (cse
   WHERE pc.case_id=cse.case_id
    AND 1=cse.verify_ind)
   JOIN (pc2
   WHERE ftcl.review_case_id=pc2.case_id)
  ORDER BY ftcl.followup_event_id
  HEAD ftcl.followup_event_id
   pat_cnt += 1
   IF (mod(pat_cnt,10)=1)
    stat = alterlist(temp->pat_qual,(pat_cnt+ 9))
   ENDIF
   temp->pat_qual[pat_cnt].patient = trim(p.name_full_formatted), temp->pat_qual[pat_cnt].init_case
    = pc_accession_nbr, temp->pat_qual[pat_cnt].encntr_id = pc.encntr_id,
   temp->pat_qual[pat_cnt].verified = format(cnvtdatetime(pc.main_report_cmplete_dt_tm),
    "@SHORTDATE;;D"), temp->pat_qual[pat_cnt].rev_case = pc2_accession_nbr, temp->pat_qual[pat_cnt].
   collected = format(cnvtdatetime(pc2.case_collect_dt_tm),"@SHORTDATE;;D"),
   temp->pat_qual[pat_cnt].ievent_id = cse.event_id, temp->pat_qual[pat_cnt].accession_nbr = pc2
   .accession_nbr
  FOOT REPORT
   stat = alterlist(temp->pat_qual,pat_cnt)
  WITH nocounter
 ;end select
 IF (pat_cnt=0)
  SET pat_cnt = 1
  GO TO report_maker
 ENDIF
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM (dummyt d1  WITH seq = value(pat_cnt)),
   (dummyt d2  WITH seq = 1),
   encntr_alias ea
  PLAN (d1)
   JOIN (d2)
   JOIN (ea
   WHERE (temp->pat_qual[d1.seq].encntr_id=ea.encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   IF ((temp->pat_qual[d1.seq].encntr_id=ea.encntr_id))
    temp->pat_qual[d1.seq].id = frmt_mrn
   ELSE
    temp->pat_qual[d1.seq].id = "Unknown"
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  d.seq, ce.event_id, cebr.event_id
  FROM (dummyt d  WITH seq = value(pat_cnt)),
   clinical_event ce,
   ce_blob_result cebr
  PLAN (d
   WHERE 0 < d.seq)
   JOIN (ce
   WHERE (temp->pat_qual[d.seq].ievent_id=ce.parent_event_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.record_status_cd != deleted_status_cd
    AND parser(trim(ce_where)))
   JOIN (cebr
   WHERE ce.event_id=cebr.event_id
    AND cebr.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND cebr.storage_cd=blob_cd)
  ORDER BY d.seq, cebr.event_id
  HEAD REPORT
   dcnt = 0, tcnt = 0
  HEAD d.seq
   row + 0, stat = alterlist(temp->pat_qual[d.seq].idetail_qual,10), dcnt = 0
  HEAD cebr.event_id
   dcnt += 1
   IF (mod(dcnt,10)=1
    AND dcnt != 1)
    stat = alterlist(temp->pat_qual[d.seq].idetail_qual,(dcnt+ 9))
   ENDIF
   recdate->datetime = cnvtdatetimeutc(cebr.valid_from_dt_tm), sblobout = "", blobsize =
   uar_get_ceblobsize(cebr.event_id,recdate)
   IF (blobsize > 0)
    stat = memrealloc(sblobout,1,build("C",blobsize)), status = uar_get_ceblob(cebr.event_id,recdate,
     sblobout,blobsize)
   ENDIF
   stat = alterlist(temp->pat_qual[d.seq].idetail_qual[dcnt].init_qual,1), temp->pat_qual[d.seq].
   idetail_qual[dcnt].init_qual[1].itext = sblobout
  FOOT  d.seq
   stat = alterlist(temp->pat_qual[d.seq].idetail_qual,dcnt)
  WITH nocounter, memsort
 ;end select
 SELECT INTO "nl:"
  d.seq, ce.event_id, cebr.event_id
  FROM (dummyt d  WITH seq = value(pat_cnt)),
   clinical_event ce,
   ce_blob_result cebr
  PLAN (d)
   JOIN (ce
   WHERE (temp->pat_qual[d.seq].accession_nbr=ce.accession_nbr)
    AND ce.record_status_cd != deleted_status_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND parser(trim(ce_where)))
   JOIN (cebr
   WHERE ce.event_id=cebr.event_id
    AND cebr.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND cebr.storage_cd=blob_cd)
  ORDER BY d.seq, cebr.event_id
  HEAD REPORT
   dcnt = 0, tcnt = 0
  HEAD d.seq
   row + 0, stat = alterlist(temp->pat_qual[d.seq].rdetail_qual,10), dcnt = 0
  HEAD cebr.event_id
   dcnt += 1
   IF (mod(dcnt,10)=1
    AND dcnt != 1)
    stat = alterlist(temp->pat_qual[d.seq].rdetail_qual,(dcnt+ 9))
   ENDIF
   recdate->datetime = cnvtdatetimeutc(cebr.valid_from_dt_tm), sblobout = "", blobsize =
   uar_get_ceblobsize(cebr.event_id,recdate)
   IF (blobsize > 0)
    stat = memrealloc(sblobout,1,build("C",blobsize)), status = uar_get_ceblob(cebr.event_id,recdate,
     sblobout,blobsize)
   ENDIF
   stat = alterlist(temp->pat_qual[d.seq].rdetail_qual[dcnt].review_qual,1), temp->pat_qual[d.seq].
   rdetail_qual[dcnt].review_qual[1].rtext = sblobout
  FOOT  d.seq
   stat = alterlist(temp->pat_qual[d.seq].rdetail_qual,dcnt)
  WITH nocounter, memsort
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apfrv", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  d.seq, concat_patient = concat(trim(temp->pat_qual[d.seq].patient),temp->pat_qual[d.seq].id)
  FROM (dummyt d  WITH seq = value(pat_cnt))
  WHERE d.seq > 0
   AND size(temp->pat_qual,5) > 0
   AND d.seq <= size(temp->pat_qual,5)
  ORDER BY concat_patient
  HEAD REPORT
   line1 = fillstring(125,"-"), text = fillstring(100," "), nodata = "Y"
  HEAD PAGE
   row + 1, col 0, captions->rpt,
   col 56,
   CALL center(temp->site_name,row,132), col 110,
   captions->dt, col 117, curdate"@MEDIUMDATE;;D",
   row + 1, col 0, captions->dir,
   col 110, captions->tm, col 117,
   curtime"@TIMENOSECONDS;;M", row + 1, col 52,
   CALL center(captions->foll,row,132), col 112, captions->bye,
   col 117, request->curuser, row + 1,
   col 110, captions->pg, col 117,
   curpage"###", row + 1, col 0,
   captions->typ, col 10, temp->description,
   row + 1, col 0, captions->pre,
   col 15, last_pref = value(size(temp_pref->pref_qual,5))
   IF (last_pref=0)
    sprefix_name = "( all )", sprefix_name
   ELSE
    FOR (x = 1 TO last_pref)
      IF ((temp_pref->pref_qual[x].site_cd > 0))
       ssitedisp = trim(temp_pref->pref_qual[x].site_display), ssitedisp
      ENDIF
      sprefix_name = trim(temp_pref->pref_qual[x].prefix_name), sprefix_name
      IF (x < last_pref)
       ", "
      ENDIF
      col + 1
      IF (col > 120)
       row + 1, col 15
      ENDIF
    ENDFOR
   ENDIF
   row + 1, line1, row + 4
  HEAD d.seq
   nodata = "N", isize = 0, rsize = 0,
   col 50, "                                             ", row + 1,
   col 0, captions->pat, col 28,
   captions->id, col 50, captions->init_case,
   col 71, captions->ver, col 81,
   captions->rev_cse, col 102, captions->collect,
   row + 1, col 0, "_________________________",
   col 28, "____________________", col 50,
   "___________________", col 71, "________",
   col 81, "___________________", col 102,
   "_________", row + 1, temp->pat_qual[d.seq].patient,
   col 28, temp->pat_qual[d.seq].id, col 50,
   temp->pat_qual[d.seq].init_case, col 71, temp->pat_qual[d.seq].verified,
   col 81, temp->pat_qual[d.seq].rev_case, col 102,
   temp->pat_qual[d.seq].collected, row + 1
  DETAIL
   idsize = cnvtint(size(temp->pat_qual[d.seq].idetail_qual,5)), rdsize = cnvtint(size(temp->
     pat_qual[d.seq].rdetail_qual,5)), npri = 0,
   npri2 = 0
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 1, col 10, captions->init_c,
   col 28, captions->not_ava
   FOR (idcnt = 1 TO idsize)
     col 28, "                                        ",
     CALL rtf_to_text(trim(temp->pat_qual[d.seq].idetail_qual[idcnt].init_qual[1].itext),1,80)
     FOR (z = 1 TO size(tmptext->qual,5))
       npri = 1, col 28, "                                        ",
       col 28, tmptext->qual[z].text, row + 1
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
     ENDFOR
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
     IF (npri > 0)
      row + 1
     ENDIF
   ENDFOR
   row + 1, col 14, captions->rev_c,
   col 28, captions->not_ava
   FOR (rdcnt = 1 TO rdsize)
     col 28, "                                        ",
     CALL rtf_to_text(trim(temp->pat_qual[d.seq].rdetail_qual[rdcnt].review_qual[1].rtext),1,80)
     FOR (z = 1 TO size(tmptext->qual,5))
       npri2 = 1, col 28, "                                        ",
       col 28, tmptext->qual[z].text, row + 1
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
     ENDFOR
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
     IF (npri2 > 0)
      row + 1
     ENDIF
   ENDFOR
   IF (npri2=0)
    row + 1
   ENDIF
  FOOT PAGE
   row + 1
   IF (nodata="Y")
    col 50, captions->none
   ENDIF
   row + 1, row 60, col 0,
   line1, row + 1, col 0,
   captions->title, wk = format(curdate,"@WEEKDAYABBREV;;D"), dy = format(curdate,"@MEDIUMDATE4YR;;D"
    ),
   today = concat(wk," ",dy), col 53, today,
   col 110, captions->pg, col 117,
   curpage"###", row + 1, col 35,
   captions->cont
  FOOT REPORT
   col 35, captions->end_rpt
  WITH nocounter, maxrow = 63, nullreport,
   compress
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
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = concat(trim(reply->status_data.subeventstatus[1].operationname),trim(reply->
    status_data.subeventstatus[1].operationstatus),trim(reply->status_data.subeventstatus[1].
    targetobjectname),trim(reply->status_data.subeventstatus[1].targetobjectvalue))
 ELSE
  IF ((reply->status_data.status="F"))
   SET reply->status_data.status = "S"
  ENDIF
  IF (textlen(trim(request->output_dist)) > 0)
   SET spool value(reply->print_status_data.print_dir_and_filename) value(printer) WITH copy = value(
    copies)
   SET reply->ops_event = concat("Successful ",trim(reply->print_status_data.print_dir_and_filename))
  ENDIF
 ENDIF
#end_script
END GO
