CREATE PROGRAM aps_prt_diag_code_assgn_review:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD temp(
   1 max_tasks = i4
   1 max_groups = i4
   1 max_sequences = i4
   1 event_qual[*]
     2 event_id = f8
     2 accession_disp = c21
     2 verified_prsnl_id = f8
     2 verified_name = vc
     2 verified_dt_tm = dq8
     2 task_qual[*]
       3 text_cnt = i4
       3 text_qual[*]
         4 text = vc
       3 clinical_event_id = f8
       3 event_id = f8
       3 collating_seq = c40
       3 task_assay_cd = f8
       3 task_assay_disp = c50
       3 group_qual[*]
         4 group_nbr = i4
         4 seq_qual[*]
           5 sequence_nbr = i4
           5 nomenclature_id = f8
           5 nomenclature_disp = vc
           5 code = vc
 )
 RECORD temp_2(
   1 prefix_qual[*]
     2 prefix_id = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_display = vc
   1 path_qual[*]
     2 pathologist_name = vc
 )
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
 CALL initresourcesecurity(1)
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
 RECORD event(
   1 qual[1]
     2 parent_cd = f8
     2 event_cd = f8
 )
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
 RECORD captions(
   1 title = vc
   1 pathnet = vc
   1 dt = vc
   1 dir = vc
   1 tm = vc
   1 diag = vc
   1 bye = vc
   1 pg = vc
   1 dt_rg = vc
   1 pre = vc
   1 all_pre = vc
   1 path = vc
   1 all_path = vc
   1 none = vc
   1 resp = vc
   1 case_no = vc
   1 verify = vc
   1 pro = vc
   1 assign_cd = vc
   1 group = vc
   1 cd = vc
   1 descript = vc
   1 end_list = vc
   1 cont = vc
   1 no_assign = vc
 )
 SET captions->title = uar_i18ngetmessage(i18nhandle,"t1",
  "REPORT: APS_PRT_DIAG_CODE_ASSIG_REVIEW.PRG")
 SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"t2","PATHNET ANATOMIC PATHOLOGY")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t3","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t4","DIRECTORY:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t5","TIME:")
 SET captions->diag = uar_i18ngetmessage(i18nhandle,"t6","DIAGNOSTIC CODE ASSIGNMENT REVIEW")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t7","BY:")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t8","PAGE:")
 SET captions->dt_rg = uar_i18ngetmessage(i18nhandle,"t9","DATE RANGE:")
 SET captions->pre = uar_i18ngetmessage(i18nhandle,"t10","PREFIX(ES):")
 SET captions->all_pre = uar_i18ngetmessage(i18nhandle,"t11","ALL PREFIXES")
 SET captions->path = uar_i18ngetmessage(i18nhandle,"t12","PATHOLOGIST:")
 SET captions->all_path = uar_i18ngetmessage(i18nhandle,"t13","ALL PATHOLOGISTS:")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"t14","NO CASES FOUND MEETING SELECTION CRITERIA"
  )
 SET captions->resp = uar_i18ngetmessage(i18nhandle,"t15","RESPONSIBLE PATHOLOGIST:")
 SET captions->case_no = uar_i18ngetmessage(i18nhandle,"t16","CASE:")
 SET captions->verify = uar_i18ngetmessage(i18nhandle,"t17","VERIFIED:")
 SET captions->pro = uar_i18ngetmessage(i18nhandle,"t18","PROCEDURE:")
 SET captions->assign_cd = uar_i18ngetmessage(i18nhandle,"t19","ASSIGNED CODES:")
 SET captions->group = uar_i18ngetmessage(i18nhandle,"t20","GROUPING")
 SET captions->cd = uar_i18ngetmessage(i18nhandle,"t21","CODE")
 SET captions->descript = uar_i18ngetmessage(i18nhandle,"t22","DESCRIPTION")
 SET captions->end_list = uar_i18ngetmessage(i18nhandle,"t23","* * * END OF CASE LIST * * *")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"t24","CONTINUED...")
 SET captions->no_assign = uar_i18ngetmessage(i18nhandle,"t25","NO CODES WERE ASSIGNED")
 DECLARE tblobout = gvc WITH protect, noconstant(" ")
 DECLARE blob_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",25,"BLOB"))
 DECLARE doc_image_event_cd = f8 WITH protect, noconstant(0.0)
 SET deleted_status_cd = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(10," ")
 SET code_set = 48
 SET code_value = 0.0
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_status_cd = code_value
 SET stat = initrec(event)
 CALL echo("Retrieving doc image event_cd")
 SET code_set = 73
 SET cdf_meaning = "DOC_IMAGE"
 EXECUTE cpm_get_cd_for_cdf
 SET event->qual[1].parent_cd = code_value
 EXECUTE aps_get_event_codes
 IF ((event->qual[1].event_cd > 0))
  SET doc_image_event_cd = event->qual[1].event_cd
 ELSE
  SET doc_image_event_cd = 23456.00
 ENDIF
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
    stat = alterlist(temp_2->prefix_qual,value(size(request->prefix_qual,5))), pref_cntr = 0
   HEAD ap.prefix_id
    pref_cntr += 1, temp_2->prefix_qual[pref_cntr].prefix_id = ap.prefix_id, temp_2->prefix_qual[
    pref_cntr].prefix_name = ap.prefix_name
    IF (ap.site_cd > 0)
     temp_2->prefix_qual[pref_cntr].site_cd = ap.site_cd, temp_2->prefix_qual[pref_cntr].site_display
      = cv.display
    ENDIF
   FOOT REPORT
    stat = alterlist(temp_2->prefix_qual,pref_cntr)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->pathologist_id > 0))
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM prsnl p
   WHERE (request->pathologist_id=p.person_id)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1, stat = alterlist(temp_2->path_qual,cnt), temp_2->path_qual[cnt].pathologist_name = p
    .name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->pathologist_id=0))
  SET path_where1 = fillstring(50," ")
  SET path_where1 = "( adrr.verified_prsnl_id > 0 )"
 ELSE
  SET path_where1 = fillstring(1000," ")
  SET path_where1 = concat(" adrr.verified_prsnl_id = ")
  SET path_where1 = concat(trim(path_where1)," ",cnvtstring(request->pathologist_id,32,6,r)," ")
 ENDIF
 DECLARE prefix_where1 = vc WITH protect, noconstant("")
 DECLARE temp_prefixids = vc WITH protect, noconstant("")
 SET prefix_where1 = fillstring(2000," ")
 SET prefix_where1 = "( 0 = 0 )"
 IF ((request->prefix_cnt > 0))
  SET prefix_where1 = concat(trim(prefix_where1)," and adrr.prefix_id in (")
  FOR (x = 1 TO (request->prefix_cnt - 1))
    SET prefix_where1 = concat(trim(prefix_where1)," ",cnvtstring(request->prefix_qual[x].prefix_id,
      32,6,r),",")
  ENDFOR
  SET prefix_where1 = concat(trim(prefix_where1)," ",cnvtstring(request->prefix_qual[x].prefix_id,32,
    6,r),")")
 ELSE
  SELECT INTO "nl:"
   FROM ap_prefix ap
   PLAN (ap
    WHERE ap.prefix_id != 0.0)
   DETAIL
    service_resource_cd = ap.service_resource_cd
    IF (isresourceviewable(service_resource_cd)=true)
     IF (textlen(trim(temp_prefixids))=0)
      temp_prefixids = cnvtstring(ap.prefix_id,32,6,r)
     ELSE
      temp_prefixids = build(trim(temp_prefixids),",",cnvtstring(ap.prefix_id,32,6,r))
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET stat = alterlist(temp->event_qual,1)
   GO TO report_maker
  ELSEIF (getresourcesecuritystatus(0) != "S")
   IF (getresourcesecuritystatus(0)="F")
    SET reply->status_data.status = "F"
    CALL populateressecstatusblock(1)
    GO TO exit_script
   ELSE
    CALL populateressecstatusblock(1)
    SET stat = alterlist(temp->event_qual,1)
    GO TO report_maker
   ENDIF
  ELSE
   IF (textlen(trim(temp_prefixids)) > 0)
    SET prefix_where1 = concat("adrr.prefix_id in (",temp_prefixids)
    SET prefix_where1 = concat(trim(prefix_where1),")")
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM prsnl p,
   ap_diag_rpt_review adrr
  PLAN (adrr
   WHERE parser(prefix_where1)
    AND parser(path_where1)
    AND adrr.verified_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm))
   JOIN (p
   WHERE adrr.verified_prsnl_id=p.person_id)
  ORDER BY p.name_full_formatted
  HEAD REPORT
   event_qual = 0
  DETAIL
   event_qual += 1, stat = alterlist(temp->event_qual,event_qual), temp->event_qual[event_qual].
   event_id = adrr.event_id,
   temp->event_qual[event_qual].verified_prsnl_id = adrr.verified_prsnl_id, temp->event_qual[
   event_qual].verified_dt_tm = adrr.verified_dt_tm, temp->event_qual[event_qual].verified_name = p
   .name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET stat = alterlist(temp->event_qual,1)
  GO TO report_maker
 ENDIF
 SELECT INTO "nl:"
  ce.accession_nbr, ce1.event_id, ce1.task_assay_cd,
  ce1.collating_seq, ce.event_id, ce.collating_seq,
  task_assay_disp = uar_get_code_display(ce1.task_assay_cd)
  FROM (dummyt d1  WITH seq = value(size(temp->event_qual,5))),
   clinical_event ce,
   clinical_event ce1,
   ap_diag_auto_code adac
  PLAN (d1)
   JOIN (ce
   WHERE (ce.event_id=temp->event_qual[d1.seq].event_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
   JOIN (ce1
   WHERE ce.event_id=ce1.parent_event_id
    AND ce1.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce1.record_status_cd != deleted_status_cd
    AND ce1.event_cd != doc_image_event_cd)
   JOIN (adac
   WHERE ce.catalog_cd=adac.catalog_cd
    AND ce1.task_assay_cd=adac.task_assay_cd)
  ORDER BY d1.seq, ce.accession_nbr, ce1.task_assay_cd,
   ce.collating_seq, ce1.collating_seq
  HEAD REPORT
   task_qual = 0
  HEAD ce.accession_nbr
   task_qual = 0
  HEAD ce1.task_assay_cd
   temp->event_qual[d1.seq].accession_disp = ce.accession_nbr, task_qual += 1
   IF ((task_qual > temp->max_tasks))
    temp->max_tasks = task_qual
   ENDIF
   stat = alterlist(temp->event_qual[d1.seq].task_qual,task_qual)
  HEAD ce.collating_seq
   temp->event_qual[d1.seq].task_qual[task_qual].collating_seq = ce1.collating_seq, temp->event_qual[
   d1.seq].task_qual[task_qual].task_assay_cd = ce1.task_assay_cd, temp->event_qual[d1.seq].
   task_qual[task_qual].task_assay_disp = task_assay_disp,
   temp->event_qual[d1.seq].task_qual[task_qual].event_id = ce1.event_id, temp->event_qual[d1.seq].
   task_qual[task_qual].clinical_event_id = ce1.clinical_event_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  event_id = temp->event_qual[d1.seq].task_qual[d2.seq].event_id, cebr.event_id
  FROM (dummyt d1  WITH seq = value(size(temp->event_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_tasks)),
   ce_blob_result cebr
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->event_qual[d1.seq].task_qual,5))
   JOIN (cebr
   WHERE (temp->event_qual[d1.seq].task_qual[d2.seq].event_id=cebr.event_id)
    AND cebr.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND cebr.storage_cd=blob_cd)
  HEAD event_id
   blob_cntr = 0, recdate->datetime = cnvtdatetimeutc(cebr.valid_from_dt_tm), tblobout = "",
   blobsize = uar_get_ceblobsize(cebr.event_id,recdate)
   IF (blobsize > 0)
    stat = memrealloc(tblobout,1,build("C",blobsize)), status = uar_get_ceblob(cebr.event_id,recdate,
     tblobout,blobsize)
    IF (findstring("\*\txdiagcoding",tblobout,1,0) > 0)
     tblobout = replace(tblobout,"{\*\txdiagcoding}","\'a6",0)
    ENDIF
    CALL rtf_to_text(tblobout,1,105)
    FOR (z = 1 TO size(tmptext->qual,5))
      blob_cntr += 1, stat = alterlist(temp->event_qual[d1.seq].task_qual[d2.seq].text_qual,blob_cntr
       ), temp->event_qual[d1.seq].task_qual[d2.seq].text_cnt = blob_cntr,
      temp->event_qual[d1.seq].task_qual[d2.seq].text_qual[blob_cntr].text = trim(tmptext->qual[z].
       text)
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d1.seq, d2.seq, ccr.event_id,
  ccr.group_nbr, ccr.sequence_nbr
  FROM (dummyt d1  WITH seq = value(size(temp->event_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_tasks)),
   ce_coded_result ccr,
   nomenclature nmn
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->event_qual[d1.seq].task_qual,5))
   JOIN (ccr
   WHERE (temp->event_qual[d1.seq].task_qual[d2.seq].event_id=ccr.event_id)
    AND ccr.valid_until_dt_tm > cnvtdatetime(sysdate))
   JOIN (nmn
   WHERE ccr.nomenclature_id=nmn.nomenclature_id)
  ORDER BY d1.seq, d2.seq, ccr.event_id,
   ccr.group_nbr, ccr.sequence_nbr
  HEAD REPORT
   group_nbr = 0
  HEAD ccr.event_id
   group_nbr = 0
  HEAD ccr.group_nbr
   group_nbr += 1
   IF ((group_nbr > temp->max_groups))
    temp->max_groups = group_nbr
   ENDIF
   stat = alterlist(temp->event_qual[d1.seq].task_qual[d2.seq].group_qual,group_nbr), temp->
   event_qual[d1.seq].task_qual[d2.seq].group_qual[group_nbr].group_nbr = ccr.group_nbr, seq_nbr = 0
  HEAD ccr.sequence_nbr
   seq_nbr += 1
   IF ((seq_nbr > temp->max_sequences))
    temp->max_sequences = seq_nbr
   ENDIF
   stat = alterlist(temp->event_qual[d1.seq].task_qual[d2.seq].group_qual[group_nbr].seq_qual,seq_nbr
    ), temp->event_qual[d1.seq].task_qual[d2.seq].group_qual[group_nbr].seq_qual[seq_nbr].
   sequence_nbr = ccr.sequence_nbr, temp->event_qual[d1.seq].task_qual[d2.seq].group_qual[group_nbr].
   seq_qual[seq_nbr].nomenclature_id = ccr.nomenclature_id,
   temp->event_qual[d1.seq].task_qual[d2.seq].group_qual[group_nbr].seq_qual[seq_nbr].
   nomenclature_disp = nmn.source_string, temp->event_qual[d1.seq].task_qual[d2.seq].group_qual[
   group_nbr].seq_qual[seq_nbr].code = nmn.source_identifier
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "aps_diagcode_rvw", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SET pathologist_name = fillstring(80," ")
 DECLARE uar_fmt_accession(p1,p2) = c25
 SELECT INTO value(reply->print_status_data.print_filename)
  verified_name = temp->event_qual[d1.seq].verified_name, formatted_accession = uar_fmt_accession(
   temp->event_qual[d1.seq].accession_disp,size(trim(temp->event_qual[d1.seq].accession_disp),1)),
  collating_seq = temp->event_qual[d1.seq].task_qual[d2.seq].collating_seq,
  task_assay_disp = temp->event_qual[d1.seq].task_qual[d2.seq].task_assay_disp
  FROM (dummyt d1  WITH seq = value(size(temp->event_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_tasks))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->event_qual[d1.seq].task_qual,5))
  ORDER BY verified_name, formatted_accession, collating_seq
  HEAD REPORT
   line1 = fillstring(125,"-"), 20stars = fillstring(20,"*")
  HEAD PAGE
   date1 = format(curdate,"@SHORTDATE;;D"), time1 = format(curtime,"@TIMENOSECONDS;;M"), beg_dt =
   format(request->beg_dt_tm,"@SHORTDATE;;D"),
   end_dt = format(request->end_dt_tm,"@SHORTDATE;;D"), row + 1, col 0,
   captions->title,
   CALL center(captions->pathnet,1,132), col 110,
   captions->dt, col 117, date1,
   row + 1, col 0, captions->dir,
   col 110, captions->tm, col 117,
   time1, row + 1,
   CALL center(captions->diag,0,132),
   col 112, captions->bye, col 117,
   request->scuruser"##############", row + 1, col 110,
   captions->pg, col 117, curpage"###",
   row + 2, col 0, captions->dt_rg,
   col 16, beg_dt, col 25,
   "-", col 27, end_dt,
   row + 1, col 0, captions->pre,
   col 16, last_pref = value(size(temp_2->prefix_qual,5))
   IF (last_pref=0)
    captions->all_pre
   ELSE
    FOR (x = 1 TO last_pref)
      temp_2->prefix_qual[x].site_display, temp_2->prefix_qual[x].prefix_name
      IF (x < last_pref)
       ", "
      ENDIF
      col + 1
      IF (col > 120)
       row + 1, col 16
      ENDIF
    ENDFOR
   ENDIF
   row + 1, col 0, captions->path,
   col 16
   IF ((request->pathologist_id=0))
    col 16, captions->all_path
   ELSEIF ((request->pathologist_id > 0))
    temp_2->path_qual[1].pathologist_name, row + 1
   ENDIF
   IF ((temp->event_qual[1].event_id=0))
    row + 7,
    CALL center(captions->none,0,132)
   ENDIF
   row + 2,
   CALL center(" * * * * * * * * * * * * * * * ",0,132), row + 1
  HEAD verified_name
   IF (((((row+ 10) > maxrow)) OR ((request->bpagebreak="Y")
    AND curpage > 1)) )
    BREAK
   ENDIF
   row + 1, col 0, captions->resp,
   col 25, temp->event_qual[d1.seq].verified_name
  HEAD formatted_accession
   ver_dt = format(temp->event_qual[d1.seq].verified_dt_tm,"@SHORTDATE;;D")
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 0, captions->case_no,
   col 6, formatted_accession, col + 3,
   captions->verify, col + 1, ver_dt
  HEAD collating_seq
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 6, captions->pro,
   col 19, task_assay_disp, row + 1
   IF ((temp->event_qual[d1.seq].task_qual[d2.seq].text_cnt > 0))
    FOR (loop2 = 1 TO temp->event_qual[d1.seq].task_qual[d2.seq].text_cnt)
      row + 1, col 19, temp->event_qual[d1.seq].task_qual[d2.seq].text_qual[loop2].text
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
    ENDFOR
   ENDIF
   row + 2, col 19, captions->assign_cd
   IF (size(temp->event_qual[d1.seq].task_qual[d2.seq].group_qual,5) > 0)
    row + 2, col 19, captions->group,
    col 30, captions->cd, col 48,
    captions->descript, row + 1, col 19,
    "--------", col 30, "---------------",
    multi_dash = fillstring(80,"-"), col 48, multi_dash
    FOR (loop1 = 1 TO size(temp->event_qual[d1.seq].task_qual[d2.seq].group_qual,5))
      FOR (loop2 = 1 TO size(temp->event_qual[d1.seq].task_qual[d2.seq].group_qual[loop1].seq_qual,5)
       )
        row + 1, col 19, temp->event_qual[d1.seq].task_qual[d2.seq].group_qual[loop1].group_nbr
        "########",
        col 30, temp->event_qual[d1.seq].task_qual[d2.seq].group_qual[loop1].seq_qual[loop2].code
        "##############", col 48,
        temp->event_qual[d1.seq].task_qual[d2.seq].group_qual[loop1].seq_qual[loop2].
        nomenclature_disp"#########################################################################"
        IF (((row+ 10) > maxrow))
         BREAK
        ENDIF
      ENDFOR
    ENDFOR
   ELSE
    row + 2, col 44, captions->no_assign
   ENDIF
  FOOT  verified_name
   row + 2,
   CALL center(captions->end_list,0,132), row + 1
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
