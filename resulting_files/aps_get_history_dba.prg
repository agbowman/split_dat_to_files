CREATE PROGRAM aps_get_history:dba
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
 RECORD reply(
   1 person_id = f8
   1 qual[10]
     2 case_id = f8
     2 accession_nbr = c20
     2 prefix_cd = f8
     2 prefix_disp = c4
     2 case_year = i4
     2 case_number = i4
     2 case_collect_dt_tm = dq8
     2 comments_long_text_id = f8
     2 comments = vc
     2 physician_name = c100
     2 spec_cnt = i2
     2 spec_qual[*]
       3 case_specimen_id = f8
       3 specimen_tag_group_cd = f8
       3 specimen_tag_cd = f8
       3 specimen_description = vc
       3 specimen_tag_display = c7
       3 specimen_tag_sequence = i4
       3 specimen_cd = f8
       3 specimen_disp = c40
       3 specimen_collect_dt_tm = dq8
     2 person_id = f8
     2 person_name = c100
     2 person_num = c16
     2 sex_cd = f8
     2 sex_disp = c40
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 deceased_dt_tm = dq8
     2 age = vc
     2 further_action_result = vc
     2 diag_summary_id = f8
     2 diag_summary_mnemonic = c25
     2 diag_summary_comment = vc
     2 event_id = f8
     2 main_report_cmplete_dt_tm = dq8
     2 origin_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 case_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 accession_nbr = c20
     2 prefix_cd = f8
     2 prefix_disp = c40
     2 case_year = i4
     2 case_number = i4
     2 case_collect_dt_tm = dq8
     2 comments_long_text_id = f8
     2 requesting_physician_id = f8
     2 main_report_cmplete_dt_tm = dq8
     2 origin_flag = i2
 )
 RECORD pm_dummy(
   1 qual[*]
     2 person_id = f8
 )
 DECLARE nlocatevalidx = i4 WITH protect, noconstant(0)
 DECLARE nlocatevalidx2 = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE nidx = i4 WITH protect, noconstant(0)
 DECLARE dstoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE dformatcd = f8 WITH protect, noconstant(0.0)
 DECLARE dsuccessiontypecd = f8 WITH protect, noconstant(0.0)
 DECLARE sblobout = gvc WITH protect, noconstant("")
 DECLARE nlength = i4 WITH protect, noconstant(0)
 DECLARE dgyn = f8 WITH protect, noconstant(0.0)
 DECLARE dngyn = f8 WITH protect, noconstant(0.0)
 DECLARE npersonmatchcnt = i4 WITH protect, noconstant(0)
 DECLARE npersonidindx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET x = 0
 SET cnt = 0
 SET case_where = fillstring(32000," ")
 SET patalerts_where = fillstring(32000," ")
 SET mrn_alias_type_cd = 0.0
 SET cancel_cd = 0.0
 SET spec_cnt = 0
 SET max_spec_cnt = 5
 RANGE OF qa IS ap_qa_info
 IF ((request->skip_resource_security_ind=0))
  IF (istaskgranted(200437)=true)
   CALL initresourcesecurity(0)
  ELSE
   CALL initresourcesecurity(1)
  ENDIF
 ELSE
  CALL initresourcesecurity(0)
 ENDIF
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
 CALL change_times(request->date_from,request->date_to)
 SET request->date_from = dtemp->beg_of_day
 SET request->date_to = dtemp->end_of_day
 SET stat = alterlist(temp->qual,10)
 IF ((request->patalerts_cnt > 0))
  SET patalerts_where = concat("qa.case_id = pc.case_id and qa.active_ind = 1",
   " and qa.flag_type_cd in (")
  FOR (x = 1 TO (request->patalerts_cnt - 1))
    SET patalerts_where = concat(trim(patalerts_where)," ",cnvtstring(request->patalerts_qual[x].
      patalerts_cd,32,6,r),",")
  ENDFOR
  SET patalerts_where = concat(trim(patalerts_where)," ",cnvtstring(request->patalerts_qual[x].
    patalerts_cd,32,6,r),")")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_alias_type_cd)
 IF (mrn_alias_type_cd=0)
  SET reply->status_data.subeventstatus[1].operationname = "UAR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "319"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "MRN"
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CANCEL",1,cancel_cd)
 IF (cancel_cd=0)
  SET reply->status_data.subeventstatus[1].operationname = "UAR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "1305"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CANCEL"
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1301,"GYN",1,dgyn)
 IF (dgyn=0)
  SET reply->status_data.subeventstatus[1].operationname = "UAR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "1305"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "GYN"
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1301,"NGYN",1,dngyn)
 IF (dngyn=0)
  SET reply->status_data.subeventstatus[1].operationname = "UAR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "1305"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NGYN"
  GO TO exit_script
 ENDIF
 SET dstoragecd = uar_get_code_by("MEANING",25,"BLOB")
 IF (dstoragecd=0)
  SET reply->status_data.subeventstatus[1].operationname = "UAR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "25"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BLOB"
  GO TO exit_script
 ENDIF
 SET dformatcd = uar_get_code_by("MEANING",23,"RTF")
 SET dsuccessiontypecd = uar_get_code_by("MEANING",63,"FINAL")
 IF ((request->selection_mode=2))
  SELECT INTO "nl:"
   pc.person_id, p.person_id
   FROM pathology_case pc
   PLAN (pc
    WHERE (request->prefix_cd=pc.prefix_id)
     AND (request->case_year=pc.case_year)
     AND (request->case_number=pc.case_number)
     AND pc.cancel_cd=0)
   DETAIL
    reply->person_id = pc.person_id
   WITH nocounter
  ;end select
 ELSE
  SET reply->person_id = request->person_id
 ENDIF
 SET case_where = build("(pc.case_id != 0)")
 SET npersonmatchcnt = 0
 SET npersonmatchcnt += 1
 SET stat = alterlist(pm_dummy->qual,10)
 SET pm_dummy->qual[npersonmatchcnt].person_id = reply->person_id
 IF ((request->without_matches_ind=0))
  SELECT INTO "nl:"
   pm.a_person_id, pm.b_person_id
   FROM person_matches pm
   PLAN (pm
    WHERE (((pm.a_person_id=reply->person_id)) OR ((pm.b_person_id=reply->person_id)))
     AND pm.active_ind=1
     AND pm.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND ((pm.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (pm.end_effective_dt_tm=null)) )
   DETAIL
    IF ((pm.a_person_id=reply->person_id))
     npersonmatchcnt += 1
     IF (mod(npersonmatchcnt,10)=1
      AND npersonmatchcnt > 10)
      stat = alterlist(pm_dummy->qual,(npersonmatchcnt+ 9))
     ENDIF
     pm_dummy->qual[npersonmatchcnt].person_id = pm.b_person_id
    ELSEIF ((pm.b_person_id=reply->person_id))
     npersonmatchcnt += 1
     IF (mod(npersonmatchcnt,10)=1
      AND npersonmatchcnt > 10)
      stat = alterlist(pm_dummy->qual,(npersonmatchcnt+ 9))
     ENDIF
     pm_dummy->qual[npersonmatchcnt].person_id = pm.a_person_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(pm_dummy->qual,npersonmatchcnt)
 IF ((request->date_type IN ("C", "R", "V")))
  SET case_where = concat(trim(case_where)," AND (")
  CASE (request->date_type)
   OF "C":
    SET case_where = concat(trim(case_where)," PC.CASE_COLLECT_DT_TM BETWEEN CNVTDATETIME(",
     " request->date_from) AND CNVTDATETIME("," request->date_to))")
   OF "R":
    SET case_where = concat(trim(case_where)," PC.CASE_RECEIVED_DT_TM BETWEEN CNVTDATETIME(",
     " request->date_from) AND CNVTDATETIME("," request->date_to))")
   OF "V":
    SET case_where = concat(trim(case_where)," PC.MAIN_REPORT_CMPLETE_DT_TM BETWEEN"," CNVTDATETIME(",
     " request->date_from) AND CNVTDATETIME("," request->date_to))")
  ENDCASE
 ENDIF
 IF ((request->prefix_cnt > 0))
  SET case_where = concat(trim(case_where)," AND (PC.PREFIX_ID IN (")
  FOR (x = 1 TO (request->prefix_cnt - 1))
    SET case_where = concat(trim(case_where)," ",cnvtstring(request->prefix_qual[x].prefix_cd,32,6,r),
     ",")
  ENDFOR
  SET case_where = concat(trim(case_where)," ",cnvtstring(request->prefix_qual[x].prefix_cd,32,6,r),
   "))")
 ENDIF
 IF ((request->chr_ind=1)
  AND (request->patalerts_cnt=0))
  SET case_where = concat(trim(case_where)," and pc.chr_ind = 1")
  SET case_where = concat(trim(case_where)," and (nullind(pc.main_report_cmplete_dt_tm) = 0)")
 ENDIF
 IF ((request->patalerts_cnt > 0))
  SELECT
   IF (size(pm_dummy->qual,5) > 1000)
    WITH nocounter, expand = 2
   ELSEIF (size(pm_dummy->qual,5) > 200)
    WITH nocounter, expand = 1
   ELSE
   ENDIF
   INTO "nl:"
   pc.case_id, cr.case_id, qa.case_id,
   join_alert = evaluate(nullind(qa.case_id),0,"Y","N")
   FROM pathology_case pc,
    ap_prefix ap,
    case_report cr,
    (dummyt d  WITH seq = 1),
    ap_qa_info qa
   PLAN (pc
    WHERE parser(trim(case_where))
     AND pc.cancel_cd=0
     AND expand(npersonidindx,1,size(pm_dummy->qual,5),pc.person_id,pm_dummy->qual[npersonidindx].
     person_id))
    JOIN (ap
    WHERE ap.prefix_id=pc.prefix_id)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND cr.event_id > 0
     AND (request->report_task_id != cr.report_id)
     AND  NOT (cr.status_cd=cancel_cd))
    JOIN (d)
    JOIN (qa
    WHERE parser(trim(patalerts_where)))
   ORDER BY pc.case_id
   HEAD REPORT
    cnt = 0, service_resource_cd = 0.0
   HEAD pc.case_id
    IF ((((request->chr_ind=1)
     AND pc.chr_ind=1
     AND nullind(pc.main_report_cmplete_dt_tm)=0) OR (((join_alert="Y") OR ((request->patalerts_cnt=0
    ))) )) )
     service_resource_cd = ap.service_resource_cd
     IF (isresourceviewable(service_resource_cd)=true)
      cnt += 1
      IF (mod(cnt,10)=1
       AND cnt != 1)
       stat = alterlist(temp->qual,(cnt+ 9))
      ENDIF
      temp->qual[cnt].case_id = pc.case_id, temp->qual[cnt].person_id = pc.person_id, temp->qual[cnt]
      .accession_nbr = pc.accession_nbr,
      temp->qual[cnt].encntr_id = pc.encntr_id, temp->qual[cnt].prefix_cd = pc.prefix_id, temp->qual[
      cnt].case_year = pc.case_year,
      temp->qual[cnt].case_number = pc.case_number, temp->qual[cnt].case_collect_dt_tm = pc
      .case_collect_dt_tm, temp->qual[cnt].comments_long_text_id = pc.comments_long_text_id,
      temp->qual[cnt].requesting_physician_id = pc.requesting_physician_id, temp->qual[cnt].
      main_report_cmplete_dt_tm = pc.main_report_cmplete_dt_tm, temp->qual[cnt].origin_flag = pc
      .origin_flag
     ENDIF
    ENDIF
   WITH nocounter, outerjoin = d
  ;end select
  SET stat = alterlist(temp->qual,cnt)
  SET nbr_cases = cnvtint(size(temp->qual,5))
 ELSE
  SELECT
   IF (size(pm_dummy->qual,5) > 1000)
    WITH nocounter, expand = 2
   ELSEIF (size(pm_dummy->qual,5) > 200)
    WITH nocounter, expand = 1
   ELSE
   ENDIF
   INTO "nl:"
   pc.case_id, cr.case_id
   FROM pathology_case pc,
    ap_prefix ap,
    case_report cr
   PLAN (pc
    WHERE parser(trim(case_where))
     AND pc.cancel_cd=0
     AND expand(npersonidindx,1,size(pm_dummy->qual,5),pc.person_id,pm_dummy->qual[npersonidindx].
     person_id))
    JOIN (ap
    WHERE ap.prefix_id=pc.prefix_id)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND cr.event_id > 0
     AND (request->report_task_id != cr.report_id)
     AND  NOT (cr.status_cd=cancel_cd))
   ORDER BY pc.case_id
   HEAD REPORT
    cnt = 0, service_resource_cd = 0.0
   HEAD pc.case_id
    service_resource_cd = ap.service_resource_cd
    IF (isresourceviewable(service_resource_cd)=true)
     cnt += 1
     IF (mod(cnt,10)=1
      AND cnt != 1)
      stat = alterlist(temp->qual,(cnt+ 9))
     ENDIF
     temp->qual[cnt].case_id = pc.case_id, temp->qual[cnt].person_id = pc.person_id, temp->qual[cnt].
     accession_nbr = pc.accession_nbr,
     temp->qual[cnt].encntr_id = pc.encntr_id, temp->qual[cnt].prefix_cd = pc.prefix_id, temp->qual[
     cnt].case_year = pc.case_year,
     temp->qual[cnt].case_number = pc.case_number, temp->qual[cnt].case_collect_dt_tm = pc
     .case_collect_dt_tm, temp->qual[cnt].comments_long_text_id = pc.comments_long_text_id,
     temp->qual[cnt].requesting_physician_id = pc.requesting_physician_id, temp->qual[cnt].
     main_report_cmplete_dt_tm = pc.main_report_cmplete_dt_tm, temp->qual[cnt].origin_flag = pc
     .origin_flag
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(temp->qual,cnt)
  SET nbr_cases = cnvtint(size(temp->qual,5))
 ENDIF
 IF (nbr_cases=0)
  IF (getresourcesecuritystatus(0) != "S")
   SET reply->status_data.status = getresourcesecuritystatus(0)
   CALL populateressecstatusblock(1)
   SET cnt = 0
   GO TO exit_script
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
   SET reply->status_data.status = "Z"
   SET cnt = 0
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  d.seq, p.person_id, cs.case_id,
  spec_exists = decode(cs.seq,1,0), t_tag_cd = decode(t.seq,t.tag_id,0.0), t_tag_group_id = decode(t
   .seq,t.tag_group_id,0.0),
  t_tag_sequence = decode(t.seq,t.tag_sequence,0), p1.person_id, nullind_p_deceased_dt_tm = nullind(p
   .deceased_dt_tm)
  FROM (dummyt d  WITH seq = value(nbr_cases)),
   (dummyt d1  WITH seq = 1),
   case_specimen cs,
   person p,
   prsnl p1,
   ap_tag t
  PLAN (d)
   JOIN (p
   WHERE (temp->qual[d.seq].person_id=p.person_id))
   JOIN (p1
   WHERE (temp->qual[d.seq].requesting_physician_id=p1.person_id))
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (cs
   WHERE (temp->qual[d.seq].case_id=cs.case_id)
    AND cs.cancel_cd IN (null, 0.0))
   JOIN (t
   WHERE cs.specimen_tag_id=t.tag_id)
  ORDER BY temp->qual[d.seq].case_id, t_tag_group_id, t_tag_sequence
  HEAD REPORT
   cnt = 0
  HEAD d.seq
   spec_cnt = 0, max_spec_cnt = 5, cnt += 1
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alter(reply->qual,(cnt+ 9))
   ENDIF
   stat = alterlist(reply->qual[cnt].spec_qual,max_spec_cnt), reply->qual[cnt].case_id = temp->qual[d
   .seq].case_id, reply->qual[cnt].accession_nbr = temp->qual[d.seq].accession_nbr,
   reply->qual[cnt].prefix_cd = temp->qual[d.seq].prefix_cd, reply->qual[cnt].case_year = temp->qual[
   d.seq].case_year, reply->qual[cnt].case_number = temp->qual[d.seq].case_number,
   reply->qual[cnt].case_collect_dt_tm = cnvtdatetime(temp->qual[d.seq].case_collect_dt_tm), reply->
   qual[cnt].main_report_cmplete_dt_tm = cnvtdatetime(temp->qual[d.seq].main_report_cmplete_dt_tm),
   reply->qual[cnt].comments_long_text_id = temp->qual[d.seq].comments_long_text_id,
   reply->qual[cnt].physician_name = p1.name_full_formatted, reply->qual[cnt].person_id = p.person_id,
   reply->qual[cnt].person_name = p.name_full_formatted,
   reply->qual[cnt].person_num = "Unknown", reply->qual[cnt].sex_cd = p.sex_cd, reply->qual[cnt].age
    = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"),
   reply->qual[cnt].birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->qual[cnt].birth_tz = validate(p
    .birth_tz,0), reply->qual[cnt].origin_flag = temp->qual[d.seq].origin_flag
   IF (nullind_p_deceased_dt_tm=0)
    reply->qual[cnt].deceased_dt_tm = cnvtdatetime(p.deceased_dt_tm)
   ENDIF
  DETAIL
   IF (spec_exists=1)
    spec_cnt += 1
    IF (mod(spec_cnt,5)=1
     AND spec_cnt != 1)
     stat = alterlist(reply->qual[cnt].spec_qual,(spec_cnt+ 4))
    ENDIF
    reply->qual[cnt].spec_qual[spec_cnt].case_specimen_id = cs.case_specimen_id, reply->qual[cnt].
    spec_qual[spec_cnt].specimen_tag_group_cd = t.tag_group_id, reply->qual[cnt].spec_qual[spec_cnt].
    specimen_tag_sequence = t.tag_sequence,
    reply->qual[cnt].spec_qual[spec_cnt].specimen_tag_cd = cs.specimen_tag_id, reply->qual[cnt].
    spec_qual[spec_cnt].specimen_description = trim(cs.specimen_description), reply->qual[cnt].
    spec_qual[spec_cnt].specimen_tag_display = t.tag_disp,
    reply->qual[cnt].spec_qual[spec_cnt].specimen_cd = cs.specimen_cd, reply->qual[cnt].spec_qual[
    spec_cnt].specimen_collect_dt_tm = cs.collect_dt_tm
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->qual[cnt].spec_qual,spec_cnt)
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
  SET cnt = 0
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  lt.long_text
  FROM (dummyt d  WITH seq = value(cnt)),
   long_text lt
  PLAN (d
   WHERE (reply->qual[d.seq].comments_long_text_id > 0))
   JOIN (lt
   WHERE (reply->qual[d.seq].comments_long_text_id=lt.long_text_id))
  DETAIL
   reply->qual[d.seq].comments = lt.long_text
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
  FROM (dummyt d  WITH seq = value(nbr_cases)),
   encntr_alias ea
  PLAN (d
   WHERE (temp->qual[d.seq].encntr_id > 0))
   JOIN (ea
   WHERE (ea.encntr_id=temp->qual[d.seq].encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   reply->qual[d.seq].person_num = frmt_mrn
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM case_report cr,
   pathology_case pc,
   prefix_report_r prr,
   clinical_event ce,
   cyto_report_control crc
  PLAN (cr
   WHERE expand(nlocatevalidx,nstart,cnt,cr.case_id,reply->qual[nlocatevalidx].case_id))
   JOIN (pc
   WHERE pc.case_id=cr.case_id
    AND pc.case_type_cd IN (dgyn, dngyn))
   JOIN (prr
   WHERE pc.prefix_id=prr.prefix_id
    AND cr.catalog_cd=prr.catalog_cd
    AND 1=prr.primary_ind)
   JOIN (crc
   WHERE crc.catalog_cd=prr.catalog_cd
    AND crc.action_task_assay_cd > 0)
   JOIN (ce
   WHERE ce.parent_event_id=cr.event_id
    AND ce.task_assay_cd=crc.action_task_assay_cd
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   nidx = locateval(nlocatevalidx2,nstart,cnt,cr.case_id,reply->qual[nlocatevalidx2].case_id), reply
   ->qual[nidx].further_action_result = ce.result_val
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM case_report cr,
   pathology_case pc,
   prefix_report_r prr,
   clinical_event ce,
   cyto_report_control crc,
   ce_coded_result ccr,
   nomenclature n
  PLAN (cr
   WHERE expand(nlocatevalidx,nstart,cnt,cr.case_id,reply->qual[nlocatevalidx].case_id))
   JOIN (pc
   WHERE pc.case_id=cr.case_id
    AND pc.case_type_cd IN (dgyn, dngyn))
   JOIN (prr
   WHERE pc.prefix_id=prr.prefix_id
    AND cr.catalog_cd=prr.catalog_cd
    AND 1=prr.primary_ind)
   JOIN (crc
   WHERE crc.catalog_cd=prr.catalog_cd
    AND crc.diagnosis_task_assay_cd > 0)
   JOIN (ce
   WHERE ce.parent_event_id=cr.event_id
    AND ce.task_assay_cd=crc.diagnosis_task_assay_cd
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ccr
   WHERE ccr.event_id=ce.event_id
    AND ccr.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=ccr.nomenclature_id)
  DETAIL
   nidx = locateval(nlocatevalidx2,nstart,cnt,cr.case_id,reply->qual[nlocatevalidx2].case_id), reply
   ->qual[nidx].diag_summary_id = n.nomenclature_id, reply->qual[nidx].diag_summary_mnemonic = n
   .mnemonic
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  n.mnemonic
  FROM case_report cr,
   pathology_case pc,
   clinical_event ce,
   ce_coded_result ccr,
   nomenclature n
  PLAN (cr
   WHERE expand(nlocatevalidx,nstart,cnt,cr.case_id,reply->qual[nlocatevalidx].case_id))
   JOIN (pc
   WHERE pc.case_id=cr.case_id
    AND  NOT (pc.case_type_cd IN (dgyn, dngyn)))
   JOIN (ce
   WHERE ce.event_id=cr.event_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ccr
   WHERE ccr.event_id=ce.parent_event_id
    AND ccr.descriptor="SUMMARY"
    AND ccr.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=ccr.nomenclature_id)
  DETAIL
   nidx = locateval(nlocatevalidx2,nstart,cnt,cr.case_id,reply->qual[nlocatevalidx2].case_id), reply
   ->qual[nidx].diag_summary_mnemonic = n.mnemonic, reply->qual[nidx].event_id = ccr.event_id,
   reply->qual[nidx].diag_summary_id = n.nomenclature_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ce_blob_result cbr
  PLAN (cbr
   WHERE expand(nlocatevalidx,nstart,cnt,cbr.event_id,reply->qual[nlocatevalidx].event_id)
    AND cbr.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND cbr.storage_cd=dstoragecd
    AND cbr.format_cd=dformatcd
    AND cbr.succession_type_cd=dsuccessiontypecd)
  DETAIL
   nidx = locateval(nlocatevalidx2,nstart,cnt,cbr.event_id,reply->qual[nlocatevalidx2].event_id),
   recdate->datetime = cnvtdatetimeutc(cbr.valid_from_dt_tm), sblobout = "",
   nlength = uar_get_ceblobsize(cbr.event_id,recdate)
   IF (nlength > 0)
    stat = memrealloc(sblobout,1,build("C",nlength)), status = uar_get_ceblob(cbr.event_id,recdate,
     sblobout,nlength),
    CALL rtf_to_text(trim(sblobout),1,100),
    sblobout = trim(tmptext->qual[1].text), reply->qual[nidx].diag_summary_comment = sblobout
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET stat = alter(reply->qual,cnt)
END GO
