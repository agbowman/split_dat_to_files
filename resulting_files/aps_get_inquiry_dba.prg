CREATE PROGRAM aps_get_inquiry:dba
 FREE SET reply
 RECORD reply(
   1 context_more_data = c1
   1 qual[*]
     2 case_id = f8
     2 encntr_id = f8
     2 accession_nbr = c20
     2 blob_bitmap = i4
     2 case_collect_dt_tm = dq8
     2 case_received_dt_tm = dq8
     2 case_received_by_id = f8
     2 case_received_by_name = vc
     2 case_comment_long_text_id = f8
     2 case_comment = vc
     2 pc_cancel_cd = f8
     2 pc_cancel_disp = c40
     2 pc_cancel_id = f8
     2 pc_cancel_name = vc
     2 pc_cancel_dt_tm = dq8
     2 prefix_cd = f8
     2 case_year = i4
     2 case_number = i4
     2 responsible_pathologist_id = f8
     2 responsible_pathologist_name = vc
     2 responsible_resident_id = f8
     2 responsible_resident_name = vc
     2 req_physician_name = vc
     2 req_physician_id = f8
     2 spec_cnt = i2
     2 spec_qual[*]
       3 case_specimen_id = f8
       3 specimen_tag_group_cd = f8
       3 specimen_tag_cd = f8
       3 specimen_tag_display = c7
       3 specimen_tag_sequence = i4
       3 specimen_description = vc
       3 specimen_cd = f8
       3 specimen_disp = c40
     2 rpt_cnt = i2
     2 rpt_qual[*]
       3 report_id = f8
       3 blob_bitmap = i4
       3 report_sequence = i4
       3 catalog_cd = f8
       3 long_description = vc
       3 short_description = c50
       3 event_id = f8
       3 status_cd = f8
       3 status_disp = c40
       3 status_desc = vc
       3 status_mean = c12
       3 comment_long_text_id = f8
       3 comment = vc
       3 order_id = f8
       3 responsible_pathologist_id = f8
       3 responsible_resident_id = f8
       3 responsible_pathologist_name = vc
       3 responsible_resident_name = vc
       3 service_resource_cd = f8
       3 service_resource_disp = c40
     2 person_id = f8
     2 encntr_type_cd = f8
     2 encntr_type_disp = c40
     2 person_name = c100
     2 person_num = vc
     2 sex_cd = f8
     2 sex_disp = c40
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 deceased_dt_tm = dq8
     2 age = vc
     2 main_report_cmplete_dt_tm = dq8
     2 fill_ext_accession_id = f8
     2 ext_acc_qual[*]
       3 accession_external_summary_id = f8
       3 active_indicator = i4
       3 update_count = i4
       3 int_identifier[*]
         4 accession_id = f8
       3 ext_identifier[*]
         4 unformatted_external_accession = c40
         4 formatted_external_accession = c40
       3 summary[*]
         4 collect_dt = dq8
         4 comment_id = f8
         4 comment_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 case_id = f8
 )
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
 SUBROUTINE (determineexpandtotal(lactualsize=i4,lexpandsize=i4) =i4 WITH protect, noconstant(0))
   RETURN((ceil((cnvtreal(lactualsize)/ lexpandsize)) * lexpandsize))
 END ;Subroutine
 SUBROUTINE (determineexpandsize(lrecordsize=i4,lmaximumsize=i4) =i4 WITH protect, noconstant(0))
   DECLARE lreturn = i4 WITH protect, noconstant(0)
   IF (lrecordsize <= 1)
    SET lreturn = 1
   ELSEIF (lrecordsize <= 10)
    SET lreturn = 10
   ELSEIF (lrecordsize <= 500)
    SET lreturn = 50
   ELSE
    SET lreturn = 100
   ENDIF
   IF (lmaximumsize < lreturn)
    SET lreturn = lmaximumsize
   ENDIF
   RETURN(lreturn)
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
 DECLARE maxqualrows = i4 WITH protect, noconstant(0)
 DECLARE mrn_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE lpos = i4 WITH protect, noconstant(0)
 DECLARE eidx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE numofitems = i4 WITH protect, noconstant(0)
 DECLARE numofbatches = i4 WITH protect, noconstant(0)
 DECLARE padded_size = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE max_size = i4 WITH protect, constant(100)
 DECLARE by_adhoc_qual_range = i2 WITH protect, constant(2)
 DECLARE by_acession_nbr_range = i2 WITH protect, constant(1)
 DECLARE cs_cancel_where = vc WITH protected, noconstant(" 0 = 0 ")
 DECLARE cs1_cancel_where = vc WITH protected, noconstant(" 0 = 0 ")
 DECLARE cr_cancel_where = vc WITH protected, noconstant(" 0 = 0 ")
 DECLARE pc_cancel_where = vc WITH protected, noconstant(" 0 = 0 ")
 DECLARE get_alias_info(null) = null WITH protect
 DECLARE get_case_comments(null) = null WITH protect
 DECLARE get_report_comments(null) = null WITH protect
 DECLARE get_prsnl_name(null) = null WITH protect
 DECLARE validate_qual_data(i2) = null WITH protect
 DECLARE get_case_specimens(null) = null WITH protect
 DECLARE get_report_details(null) = null WITH protect
 SET reply->context_more_data = "F"
 SET reply->status_data.status = "F"
 RANGE OF cp IS case_provider
 RANGE OF cs1 IS case_specimen
 IF (validate(context->context_ind,0) != 0)
  SET maxqualrows = context->maxqual
  IF ((context->prefix_cnt=1)
   AND (context->single_case_ind=0)
   AND (context->case_year > 0)
   AND (context->case_number > 0))
   CALL getcasebyaccessionnbrrange(0)
  ELSE
   CALL getcasebyadhoccriteria(0)
  ENDIF
 ELSE
  SET maxqualrows = request->maxqual
  FREE SET context
  RECORD context(
    1 single_case_ind = i2
    1 prefix_cnt = i2
    1 prefix_cd = f8
    1 case_year = i4
    1 case_number = i4
    1 retrieve_canceled_ind = i2
    1 maxqual = i4
    1 accession_nbr = vc
    1 context_ind = i4
    1 case_where = c1000
    1 patient_where = c1000
    1 specimen_where = c1000
    1 provider_where = c1000
    1 patient_defined = c1
    1 case_defined = c1
    1 provider_defined = c1
    1 specimen_defined = c1
    1 soutsidecasenbrwhere = vc
  )
  IF ((request->prefix_cnt=1)
   AND (request->single_case_ind=0)
   AND (request->case_year > 0)
   AND (request->case_number > 0))
   CALL getcasebyaccessionnbrrange(1)
  ELSE
   CALL getcasebyadhoccriteria(1)
  ENDIF
 ENDIF
 SUBROUTINE (getcasebyadhoccriteria(initial_query_ind=i2) =null WITH protect)
   DECLARE nzeropos = i4 WITH protect, noconstant(0)
   DECLARE ssoundexnamefield = vc WITH protect, noconstant("")
   SET last_name_field = fillstring(100," ")
   SET first_name_field = fillstring(100," ")
   IF (initial_query_ind=0)
    SET context->case_where = concat(trim(context->case_where)," and PC.ACCESSION_NBR <= ")
    SET context->case_where = concat(trim(context->case_where)," '",context->accession_nbr,"' ")
    IF ((context->retrieve_canceled_ind=1))
     SET cs_cancel_where = " 0 = 0 "
     SET cs1_cancel_where = " 0 =  0"
     SET cr_cancel_where = " 0 = 0 "
     SET pc_cancel_where = " 0 = 0 "
    ELSE
     SET cs_cancel_where = " cs.cancel_cd = 0"
     SET cs1_cancel_where = " cs1.cancel_cd = 0"
     SET cr_cancel_where = " cr.cancel_cd = outerjoin(0)"
     SET pc_cancel_where = " pc.cancel_cd = 0"
    ENDIF
   ELSE
    IF ((request->person_name_last > " "))
     SET last_name_field = build(cnvtupper(cnvtalphanum(request->person_name_last)),"*")
    ENDIF
    IF (textlen(trim(request->person_name_first)) > 0)
     SET first_name_field = build(cnvtupper(cnvtalphanum(request->person_name_first)),"*")
    ENDIF
    IF ((request->pat_info_ind=1))
     SET context->patient_defined = "T"
     IF (textlen(trim(request->person_name_last)) > 0)
      IF ((request->soundex_ind="Y"))
       SET ssoundexnamefield = soundex(last_name_field)
       SET nzeropos = findstring("0",ssoundexnamefield,1,0)
       IF (nzeropos > 0)
        SET ssoundexnamefield = build(substring(1,(nzeropos - 1),ssoundexnamefield),"*")
       ELSEIF (textlen(ssoundexnamefield) < 8)
        SET ssoundexnamefield = concat(ssoundexnamefield,"*")
       ENDIF
       SET context->patient_where = concat("P.NAME_LAST_PHONETIC = '",trim(ssoundexnamefield),"'")
       IF ((request->person_name_first > " "))
        SET ssoundexnamefield = soundex(first_name_field)
        SET nzeropos = findstring("0",ssoundexnamefield,1,0)
        IF (nzeropos > 0)
         SET ssoundexnamefield = build(substring(1,(nzeropos - 1),ssoundexnamefield),"*")
        ELSEIF (textlen(ssoundexnamefield) < 8)
         SET ssoundexnamefield = concat(ssoundexnamefield,"*")
        ENDIF
        SET context->patient_where = concat(trim(context->patient_where)," AND ",
         "P.NAME_FIRST_PHONETIC = '",trim(ssoundexnamefield),"'")
       ENDIF
      ELSE
       SET context->patient_where = concat("P.NAME_LAST_KEY = PATSTRING('",trim(last_name_field),"')"
        )
       IF ((request->person_name_first > " "))
        SET context->patient_where = concat(trim(context->patient_where)," AND ",
         "P.NAME_FIRST_KEY = PATSTRING('",trim(first_name_field),"')")
       ENDIF
      ENDIF
     ELSEIF ((request->person_id > 0))
      SET context->patient_where = build(request->person_id," = P.PERSON_ID")
     ENDIF
     SET context->case_where = "P.PERSON_ID = PC.PERSON_ID"
     SET context->case_defined = "T"
    ENDIF
    IF ((request->date_type IN ("C", "R", "V")))
     IF ((context->case_defined="T"))
      SET context->case_where = concat(trim(context->case_where)," AND")
     ELSE
      SET context->case_defined = "T"
     ENDIF
     CALL change_times(request->date_from,request->date_to)
     SET request->date_to = dtemp->end_of_day
     SET request->date_from = dtemp->beg_of_day
     CASE (request->date_type)
      OF "C":
       SET context->case_where = concat(trim(context->case_where),
        " PC.CASE_COLLECT_DT_TM  BETWEEN CNVTDATETIME("," request->date_from) AND CNVTDATETIME(",
        " request->date_to)")
      OF "R":
       SET context->case_where = concat(trim(context->case_where),
        " PC.CASE_RECEIVED_DT_TM  BETWEEN CNVTDATETIME("," request->date_from) AND CNVTDATETIME(",
        " request->date_to)")
      OF "V":
       SET context->case_where = concat(trim(context->case_where),
        " PC.MAIN_REPORT_CMPLETE_DT_TM BETWEEN CNVTDATETIME(",
        " request->date_from) AND CNVTDATETIME("," request->date_to)")
     ENDCASE
    ENDIF
    IF ((request->responsible_pathologist_id > 0))
     IF ((context->case_defined="T"))
      SET context->case_where = concat(trim(context->case_where)," AND")
     ELSE
      SET context->case_defined = "T"
     ENDIF
     SET context->case_where = concat(trim(context->case_where)," ",cnvtstring(request->
       responsible_pathologist_id,32,6,r)," = PC.RESPONSIBLE_PATHOLOGIST_ID")
    ENDIF
    IF ((request->specimen_category_cd > 0))
     SET context->specimen_defined = "T"
     SET context->specimen_where = "PC.CASE_ID = CS1.CASE_ID"
     SET context->specimen_where = concat(trim(context->specimen_where)," AND ",cnvtstring(request->
       specimen_category_cd,32,2))
     SET context->specimen_where = concat(trim(context->specimen_where)," = CS1.SPECIMEN_CD")
     SET context->specimen_where = trim(context->specimen_where)
    ENDIF
    IF ((request->responsible_resident_id > 0))
     IF ((context->case_defined="T"))
      SET context->case_where = build(trim(context->case_where)," AND")
     ELSE
      SET context->case_defined = "T"
     ENDIF
     SET context->case_where = concat(trim(context->case_where)," ",cnvtstring(request->
       responsible_resident_id,32,6,r)," = PC.RESPONSIBLE_RESIDENT_ID")
    ENDIF
    IF ((request->prefix_cnt > 0))
     IF ((context->case_defined="T"))
      SET context->case_where = build(trim(context->case_where)," AND")
     ELSE
      SET context->case_defined = "T"
     ENDIF
     SET context->case_where = concat(trim(context->case_where)," PC.PREFIX_ID IN (")
     FOR (x = 1 TO (request->prefix_cnt - 1))
       SET context->case_where = concat(trim(context->case_where)," ",cnvtstring(request->
         prefix_qual[x].prefix_cd,32,6,r),",")
     ENDFOR
     SET context->case_where = concat(trim(context->case_where)," ",cnvtstring(request->prefix_qual[x
       ].prefix_cd,32,6,r),")")
    ENDIF
    IF ((request->group_cnt > 0))
     IF ((context->case_defined="T"))
      IF ((request->prefix_cnt > 0))
       SET context->case_where = build(trim(context->case_where)," OR")
      ELSE
       SET context->case_where = build(trim(context->case_where)," AND")
      ENDIF
     ELSE
      SET context->case_defined = "T"
     ENDIF
     IF ((request->date_type IN ("C", "R", "V")))
      SET context->case_where = concat(trim(context->case_where)," PC.GROUP_ID+0 IN (")
     ELSE
      SET context->case_where = concat(trim(context->case_where)," PC.GROUP_ID IN (")
     ENDIF
     FOR (x = 1 TO (request->group_cnt - 1))
       SET context->case_where = concat(trim(context->case_where)," ",cnvtstring(request->group_qual[
         x].group_cd,32,6,r),",")
     ENDFOR
     SET context->case_where = concat(trim(context->case_where)," ",cnvtstring(request->group_qual[x]
       .group_cd,32,6,r),")")
    ENDIF
    IF ((request->case_number > 0))
     IF ((context->case_defined="T"))
      SET context->case_where = concat(trim(context->case_where)," AND")
     ELSE
      SET context->case_defined = "T"
     ENDIF
     IF ((request->case_year <= 0))
      SET request->case_year = year(curdate)
     ENDIF
     IF ((request->single_case_ind=1))
      SET context->case_where = concat(trim(context->case_where)," ",cnvtstring(request->case_year,11,
        0,r)," = PC.CASE_YEAR")
      SET context->case_where = concat(trim(context->case_where)," AND ",cnvtstring(request->
        case_number,11,0,r))
      SET context->case_where = concat(trim(context->case_where)," = PC.CASE_NUMBER")
     ELSE
      SET context->case_where = concat(trim(context->case_where)," ( ( ",cnvtstring(request->
        case_year,11,0,r)," = PC.CASE_YEAR")
      SET context->case_where = concat(trim(context->case_where)," AND ",cnvtstring(request->
        case_number,11,0,r))
      SET context->case_where = concat(trim(context->case_where)," >= PC.CASE_NUMBER ) ")
      SET context->case_where = concat(trim(context->case_where)," OR ",cnvtstring(request->case_year,
        11,0,r)," > PC.CASE_YEAR ) ")
     ENDIF
    ENDIF
    IF ((request->physician_id > 0))
     SET context->provider_defined = "T"
     SET context->provider_where = build(request->physician_id," = PC.REQUESTING_PHYSICIAN_ID")
    ENDIF
    IF ((context->case_defined="T"))
     IF ((request->bretrievecanceled=1))
      SET context->case_where = concat(trim(context->case_where)," AND PC.RESERVED_IND != 1")
     ELSE
      SET context->case_where = concat(trim(context->case_where),
       " AND PC.CANCEL_CD IN( 0) AND PC.RESERVED_IND != 1")
     ENDIF
    ENDIF
    IF ((request->bretrievecanceled=1))
     SET cs_cancel_where = " 0 = 0 "
     SET cs1_cancel_where = " 0 =  0"
     SET cr_cancel_where = " 0 = 0 "
     SET pc_cancel_where = " 0 = 0 "
    ELSE
     SET cs_cancel_where = " cs.cancel_cd = 0"
     SET cs1_cancel_where = " cs1.cancel_cd = 0"
     SET cr_cancel_where = " cr.cancel_cd  = outerjoin(0)"
     SET pc_cancel_where = " pc.cancel_cd = 0"
    ENDIF
    IF (textlen(trim(cnvtalphanum(request->outsidecasenbr,3))) > 0)
     SET context->soutsidecasenbrwhere = concat("aes.external_accession_key = PATSTRING('",trim(
       cnvtupper(cnvtalphanum(request->outsidecasenbr,3))),"'))")
     IF ((context->case_defined="T"))
      SET context->case_where = concat(trim(context->case_where),
       " AND pc.case_id  IN(select aes.accession_id from accession_external_smry aes where ",context
       ->soutsidecasenbrwhere)
     ELSE
      SET context->case_where = concat(
       "pc.case_id  IN(select aes.accession_id from accession_external_smry aes where ",context->
       soutsidecasenbrwhere)
      SET context->case_defined = "T"
     ENDIF
    ENDIF
    SET context->retrieve_canceled_ind = request->bretrievecanceled
   ENDIF
   IF (trim(context->patient_where)="")
    SET context->patient_where = "0 = 0"
   ENDIF
   IF (trim(context->case_where)="")
    SET context->case_where = "0 = 0"
   ENDIF
   IF (trim(context->specimen_where)="")
    SET context->specimen_where = "0 = 0"
   ENDIF
   IF (trim(context->provider_where)="")
    SET context->provider_where = "0 = 0"
   ENDIF
   IF ((context->patient_defined="F")
    AND (context->case_defined="F")
    AND (context->provider_defined="F")
    AND (context->specimen_defined="F"))
    SET stat = alterlist(reply->qual,0)
   ELSE
    CALL getcasebycommon(by_adhoc_qual_range)
   ENDIF
 END ;Subroutine
 SUBROUTINE validate_qual_data(count_reply_items)
   IF (count_reply_items=0)
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
    SET reply->status_data.status = "Z"
    RETURN
   ELSEIF (getresourcesecuritystatus(0) != "S")
    SET reply->status_data.status = getresourcesecuritystatus(0)
    CALL populateressecstatusblock(1)
    RETURN
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   CALL get_alias_info(null)
   CALL get_case_comments(null)
   CALL get_report_comments(null)
   CALL get_report_details(null)
   CALL get_prsnl_name(null)
   EXECUTE pcs_fill_ext_accs_by_acc  WITH replace("REQUESTREPLY","REPLY")
   IF ((reply->status_data.status="Z"))
    SET reply->status_data.status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_case_specimens(null)
   SELECT INTO "nl:"
    t.tag_group_id, t.tag_sequence
    FROM ap_tag t,
     case_specimen cs
    PLAN (cs
     WHERE expand(eidx,1,size(reply->qual,5),cs.case_id,reply->qual[eidx].case_id)
      AND parser(cs_cancel_where))
     JOIN (t
     WHERE cs.specimen_tag_id=t.tag_id)
    ORDER BY t.tag_group_id, t.tag_sequence
    DETAIL
     lpos = 0
     WHILE (assign(lpos,locateval(idx,(lpos+ 1),size(reply->qual,5),cs.case_id,reply->qual[idx].
       case_id)) > 0)
       spec_cnt = assign(reply->qual[lpos].spec_cnt,(reply->qual[lpos].spec_cnt+ 1))
       IF (spec_cnt > size(reply->qual[lpos].spec_qual,5))
        stat = alterlist(reply->qual[lpos].spec_qual,(spec_cnt+ 4))
       ENDIF
       reply->qual[lpos].spec_cnt = spec_cnt, reply->qual[lpos].spec_qual[spec_cnt].case_specimen_id
        = cs.case_specimen_id, reply->qual[lpos].spec_qual[spec_cnt].specimen_tag_group_cd = t
       .tag_group_id,
       reply->qual[lpos].spec_qual[spec_cnt].specimen_tag_sequence = t.tag_sequence, reply->qual[lpos
       ].spec_qual[spec_cnt].specimen_tag_display = t.tag_disp, reply->qual[lpos].spec_qual[spec_cnt]
       .specimen_tag_cd = cs.specimen_tag_id,
       reply->qual[lpos].spec_qual[spec_cnt].specimen_description = trim(cs.specimen_description),
       reply->qual[lpos].spec_qual[spec_cnt].specimen_cd = cs.specimen_cd
     ENDWHILE
    FOOT REPORT
     FOR (index = 1 TO size(reply->qual,5))
       stat = alterlist(reply->qual[index].spec_qual,reply->qual[index].spec_cnt)
     ENDFOR
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_prsnl_name(null)
   DECLARE cnt_ids = i4 WITH protect, noconstant(0)
   FREE SET temp_list
   RECORD temp_list(
     1 qual[*]
       2 person_id = f8
   )
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(reply->qual,5)),
     (dummyt d1  WITH seq = 1)
    PLAN (d
     WHERE maxrec(d1,size(reply->qual[d.seq].rpt_qual,5)))
     JOIN (d1)
    HEAD REPORT
     cnt_ids = 1
    HEAD d.seq
     IF (((cnt_ids+ 4) > size(temp_list->qual,5)))
      stat = alterlist(temp_list->qual,(cnt_ids+ 9))
     ENDIF
     IF ((reply->qual[d.seq].pc_cancel_id > 0)
      AND locateval(idx,1,size(temp_list->qual,5),reply->qual[d.seq].pc_cancel_id,temp_list->qual[idx
      ].person_id)=0)
      temp_list->qual[cnt_ids].person_id = reply->qual[d.seq].pc_cancel_id, cnt_ids += 1
     ENDIF
     IF ((reply->qual[d.seq].case_received_by_id > 0)
      AND locateval(idx,1,size(temp_list->qual,5),reply->qual[d.seq].case_received_by_id,temp_list->
      qual[idx].person_id)=0)
      temp_list->qual[cnt_ids].person_id = reply->qual[d.seq].case_received_by_id, cnt_ids += 1
     ENDIF
     IF ((reply->qual[d.seq].responsible_pathologist_id > 0)
      AND locateval(idx,1,size(temp_list->qual,5),reply->qual[d.seq].responsible_pathologist_id,
      temp_list->qual[idx].person_id)=0)
      temp_list->qual[cnt_ids].person_id = reply->qual[d.seq].responsible_pathologist_id, cnt_ids +=
      1
     ENDIF
     IF ((reply->qual[d.seq].responsible_resident_id > 0)
      AND locateval(idx,1,size(temp_list->qual,5),reply->qual[d.seq].responsible_resident_id,
      temp_list->qual[idx].person_id)=0)
      temp_list->qual[cnt_ids].person_id = reply->qual[d.seq].responsible_resident_id, cnt_ids += 1
     ENDIF
    HEAD d1.seq
     IF (((cnt_ids+ 2) > size(temp_list->qual,5)))
      stat = alterlist(temp_list->qual,(cnt_ids+ 9))
     ENDIF
     IF ((reply->qual[d.seq].rpt_qual[d1.seq].responsible_pathologist_id > 0)
      AND locateval(idx,1,size(temp_list->qual,5),reply->qual[d.seq].rpt_qual[d1.seq].
      responsible_pathologist_id,temp_list->qual[idx].person_id)=0)
      temp_list->qual[cnt_ids].person_id = reply->qual[d.seq].rpt_qual[d1.seq].
      responsible_pathologist_id, cnt_ids += 1
     ENDIF
     IF ((reply->qual[d.seq].rpt_qual[d1.seq].responsible_resident_id > 0)
      AND locateval(idx,1,size(temp_list->qual,5),reply->qual[d.seq].rpt_qual[d1.seq].
      responsible_resident_id,temp_list->qual[idx].person_id)=0)
      temp_list->qual[cnt_ids].person_id = reply->qual[d.seq].rpt_qual[d1.seq].
      responsible_resident_id, cnt_ids += 1
     ENDIF
    FOOT REPORT
     stat = alterlist(temp_list->qual,(cnt_ids - 1))
    WITH nocounter
   ;end select
   SELECT
    IF (size(temp_list->qual,5) > 1000)
     WITH nocounter, expand = 2
    ELSEIF (size(temp_list->qual,5) > 200)
     WITH nocounter, expand = 1
    ELSE
    ENDIF
    INTO "nl:"
    p.name_full_formatted
    FROM prsnl p
    PLAN (p
     WHERE expand(eidx,1,size(temp_list->qual,5),p.person_id,temp_list->qual[eidx].person_id))
    DETAIL
     lpos = 0
     WHILE (assign(lpos,locateval(idx,(lpos+ 1),size(reply->qual,5),p.person_id,reply->qual[idx].
       pc_cancel_id)) > 0)
       reply->qual[lpos].pc_cancel_name = p.name_full_formatted
     ENDWHILE
     lpos = 0
     WHILE (assign(lpos,locateval(idx,(lpos+ 1),size(reply->qual,5),p.person_id,reply->qual[idx].
       case_received_by_id)) > 0)
       reply->qual[lpos].case_received_by_name = p.name_full_formatted
     ENDWHILE
     lpos = 0
     WHILE (assign(lpos,locateval(idx,(lpos+ 1),size(reply->qual,5),p.person_id,reply->qual[idx].
       responsible_pathologist_id)) > 0)
       reply->qual[lpos].responsible_pathologist_name = p.name_full_formatted
     ENDWHILE
     lpos = 0
     WHILE (assign(lpos,locateval(idx,(lpos+ 1),size(reply->qual,5),p.person_id,reply->qual[idx].
       responsible_resident_id)) > 0)
       reply->qual[lpos].responsible_resident_name = p.name_full_formatted
     ENDWHILE
     FOR (rpt_idx = 1 TO size(reply->qual,5))
       lpos = 0
       WHILE (assign(lpos,locateval(idx,(lpos+ 1),size(reply->qual[rpt_idx].rpt_qual,5),p.person_id,
         reply->qual[rpt_idx].rpt_qual[idx].responsible_resident_id)) > 0)
         reply->qual[rpt_idx].rpt_qual[lpos].responsible_resident_name = p.name_full_formatted
       ENDWHILE
       lpos = 0
       WHILE (assign(lpos,locateval(idx,(lpos+ 1),size(reply->qual[rpt_idx].rpt_qual,5),p.person_id,
         reply->qual[rpt_idx].rpt_qual[idx].responsible_pathologist_id)) > 0)
         reply->qual[rpt_idx].rpt_qual[lpos].responsible_pathologist_name = p.name_full_formatted
       ENDWHILE
     ENDFOR
    WITH nocounter
   ;end select
   FREE SET temp_list
 END ;Subroutine
 SUBROUTINE get_report_comments(null)
   SELECT INTO "nl:"
    lt.long_text_id, lt.long_text
    FROM (dummyt d1  WITH seq = size(reply->qual,5)),
     (dummyt d2  WITH seq = 1),
     long_text lt,
     report_task rt
    PLAN (d1
     WHERE maxrec(d2,size(reply->qual[d1.seq].rpt_qual,5)))
     JOIN (d2)
     JOIN (rt
     WHERE (rt.report_id=reply->qual[d1.seq].rpt_qual[d2.seq].report_id))
     JOIN (lt
     WHERE rt.comments_long_text_id=lt.long_text_id)
    ORDER BY d1.seq, d2.seq
    HEAD d1.seq
     row + 0
    HEAD d2.seq
     reply->qual[d1.seq].rpt_qual[d2.seq].comment_long_text_id = lt.long_text_id, reply->qual[d1.seq]
     .rpt_qual[d2.seq].comment = lt.long_text
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_report_details(null)
   SELECT INTO "nl:"
    rt.report_id
    FROM (dummyt d1  WITH seq = size(reply->qual,5)),
     (dummyt d2  WITH seq = 1),
     report_task rt
    PLAN (d1
     WHERE maxrec(d2,size(reply->qual[d1.seq].rpt_qual,5)))
     JOIN (d2)
     JOIN (rt
     WHERE (rt.report_id=reply->qual[d1.seq].rpt_qual[d2.seq].report_id))
    ORDER BY d1.seq, d2.seq
    HEAD d1.seq
     row + 0
    HEAD d2.seq
     reply->qual[d1.seq].rpt_qual[d2.seq].responsible_pathologist_id = rt.responsible_pathologist_id,
     reply->qual[d1.seq].rpt_qual[d2.seq].responsible_resident_id = rt.responsible_resident_id, reply
     ->qual[d1.seq].rpt_qual[d2.seq].service_resource_cd = rt.service_resource_cd
    WITH nocounter, separator = " ", format
   ;end select
 END ;Subroutine
 SUBROUTINE get_case_comments(null)
   SET numofitems = size(reply->qual,5)
   SET batch_size = determineexpandsize(numofitems,max_size)
   SET numofbatches = ceil((cnvtreal(numofitems)/ batch_size))
   SET padded_size = (numofbatches * batch_size)
   IF (numofbatches > 0)
    SET stat = alterlist(reply->qual,padded_size)
    FOR (idx = (numofitems+ 1) TO padded_size)
      SET reply->qual[idx].case_comment_long_text_id = reply->qual[numofitems].
      case_comment_long_text_id
    ENDFOR
    SELECT INTO "nl:"
     lt.long_text_id
     FROM (dummyt d  WITH seq = value(numofbatches)),
      long_text lt
     PLAN (d)
      JOIN (lt
      WHERE expand(eidx,(1+ ((d.seq - 1) * batch_size)),(d.seq * batch_size),lt.long_text_id,reply->
       qual[eidx].case_comment_long_text_id)
       AND lt.long_text_id > 0)
     DETAIL
      lpos = 0
      WHILE (assign(lpos,locateval(idx,(lpos+ 1),size(reply->qual,5),lt.long_text_id,reply->qual[idx]
        .case_comment_long_text_id)) > 0)
        reply->qual[lpos].case_comment = trim(lt.long_text)
      ENDWHILE
    ;end select
    SET stat = alterlist(reply->qual,numofitems)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_alias_info(null)
   SET numofitems = size(reply->qual,5)
   SET batch_size = determineexpandsize(numofitems,max_size)
   SET numofbatches = ceil((cnvtreal(numofitems)/ batch_size))
   SET padded_size = (numofbatches * batch_size)
   IF (numofbatches > 0)
    SET mrn_alias_type_cd = uar_get_code_by("MEANING",319,"MRN")
    SET stat = alterlist(reply->qual,padded_size)
    FOR (idx = (numofitems+ 1) TO padded_size)
      SET reply->qual[idx].encntr_id = reply->qual[numofitems].encntr_id
    ENDFOR
    SELECT INTO "nl:"
     ea.encntr_id, frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
     FROM (dummyt d  WITH seq = value(numofbatches)),
      encntr_alias ea,
      encounter e
     PLAN (d)
      JOIN (e
      WHERE expand(eidx,(1+ ((d.seq - 1) * batch_size)),(d.seq * batch_size),e.encntr_id,reply->qual[
       eidx].encntr_id)
       AND e.encntr_id > 0
       AND e.active_ind=1
       AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ((e.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (e.end_effective_dt_tm=null)) )
      JOIN (ea
      WHERE ea.encntr_id=e.encntr_id
       AND ea.encntr_alias_type_cd=mrn_alias_type_cd
       AND ea.active_ind=1
       AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
     DETAIL
      lpos = 0
      WHILE (assign(lpos,locateval(idx,(lpos+ 1),size(reply->qual,5),e.encntr_id,reply->qual[idx].
        encntr_id)) > 0)
        reply->qual[lpos].person_num = frmt_mrn
      ENDWHILE
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->qual,numofitems)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getcasebyaccessionnbrrange(initial_query_ind=i2) =null WITH protect)
   DECLARE giveme_canceled = i2 WITH protect, noconstant(0)
   DECLARE giveme_prefix_cnt = i2 WITH protect, noconstant(0)
   DECLARE giveme_case_year = i4 WITH protect, noconstant(0)
   DECLARE giveme_single_case_ind = i2 WITH protect, noconstant(0)
   DECLARE giveme_case_number = i4 WITH protect, noconstant(0)
   DECLARE giveme_prefix_cd = f8 WITH protect, noconstant(0.0)
   DECLARE attempted_years_cnt = i4 WITH protect, noconstant(0)
   DECLARE max_num = i4 WITH protect, noconstant(0)
   DECLARE min_num = i4 WITH protect, noconstant(0)
   DECLARE case_cnt = i4 WITH protect, noconstant(0)
   IF (initial_query_ind=0)
    SET giveme_canceled = context->retrieve_canceled_ind
    SET giveme_prefix_cnt = context->prefix_cnt
    SET giveme_case_year = context->case_year
    SET giveme_single_case_ind = context->single_case_ind
    SET giveme_case_number = context->case_number
    SET giveme_prefix_cd = context->prefix_cd
   ELSE
    SET giveme_canceled = request->bretrievecanceled
    SET giveme_prefix_cnt = request->prefix_cnt
    SET giveme_case_year = request->case_year
    SET giveme_single_case_ind = request->single_case_ind
    SET giveme_case_number = request->case_number
    SET giveme_prefix_cd = request->prefix_qual[1].prefix_cd
   ENDIF
   SET attempted_years_cnt += 1
   SET temp_flag = 1
   WHILE (temp_flag != 0)
     SET temp_flag = 0
     SET max_num = giveme_case_number
     IF (((max_num - maxqualrows) > 0))
      SET min_num = (max_num - maxqualrows)
     ELSE
      SET min_num = 0
     ENDIF
     SELECT INTO "nl:"
      pc.case_id
      FROM pathology_case pc
      PLAN (pc
       WHERE pc.case_year=giveme_case_year
        AND pc.prefix_id=giveme_prefix_cd
        AND pc.case_number BETWEEN min_num AND max_num
        AND pc.reserved_ind != 1)
      ORDER BY pc.accession_nbr DESC
      DETAIL
       IF (case_cnt=maxqualrows)
        IF ((reply->context_more_data="F"))
         reply->context_more_data = "T", context->prefix_cnt = giveme_prefix_cnt, context->prefix_cd
          = giveme_prefix_cd,
         context->single_case_ind = giveme_single_case_ind, context->retrieve_canceled_ind =
         giveme_canceled, context->case_year = pc.case_year,
         context->case_number = pc.case_number, context->context_ind = 1, context->maxqual =
         maxqualrows
        ENDIF
       ELSE
        case_cnt += 1
        IF (mod(case_cnt,10)=1)
         stat = alterlist(temp->qual,(case_cnt+ 9))
        ENDIF
        temp->qual[case_cnt].case_id = pc.case_id
       ENDIF
      WITH nocounter
     ;end select
     IF ((reply->context_more_data="F"))
      SET giveme_case_number = 0
      IF (min_num > 1)
       SELECT INTO "nl:"
        my_max_num = max(pc.case_number)
        FROM pathology_case pc
        WHERE pc.case_year=giveme_case_year
         AND pc.prefix_id=giveme_prefix_cd
         AND pc.case_number < min_num
         AND pc.reserved_ind != 1
        DETAIL
         giveme_case_number = my_max_num
        WITH nocounter
       ;end select
      ENDIF
      IF (giveme_case_number=0
       AND attempted_years_cnt <= 5)
       SET giveme_case_year -= 1
       SET attempted_years_cnt += 1
       SELECT INTO "nl:"
        my_max_num = max(pc.case_number)
        FROM pathology_case pc
        WHERE pc.case_year=giveme_case_year
         AND pc.prefix_id=giveme_prefix_cd
         AND pc.reserved_ind != 1
        DETAIL
         giveme_case_number = my_max_num
        WITH nocounter
       ;end select
      ENDIF
      IF (giveme_case_number != 0)
       SET temp_flag = 1
      ENDIF
     ENDIF
   ENDWHILE
   SET stat = alterlist(temp->qual,case_cnt)
   CALL getcasebycommon(by_acession_nbr_range)
 END ;Subroutine
 SUBROUTINE (getcasebycommon(inquiry_indicator=i2) =null WITH protect)
   DECLARE context_patient_where = vc WITH protect, noconstant(" 0 = 0 ")
   DECLARE context_case_where = vc WITH protect, noconstant(" 0 = 0 ")
   DECLARE context_specimen_where = vc WITH protect, noconstant(" 0 = 0 ")
   DECLARE context_provider_where = vc WITH protect, noconstant(" 0 = 0 ")
   DECLARE temp_size = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   IF (maxqualrows > 10)
    SET stat = alterlist(reply->qual,maxqualrows)
   ENDIF
   IF (inquiry_indicator=by_acession_nbr_range)
    CALL initresourcesecurity(0)
    SET temp_size = size(temp->qual,5)
    IF (temp_size=0)
     RETURN
    ENDIF
   ELSEIF (inquiry_indicator=by_adhoc_qual_range)
    CALL initresourcesecurity(1)
    SET context_patient_where = trim(context->patient_where)
    SET context_case_where = trim(context->case_where)
    SET context_specimen_where = trim(context->specimen_where)
    SET context_provider_where = trim(context->provider_where)
   ENDIF
   SELECT
    IF (inquiry_indicator=by_acession_nbr_range)INTO "nl:"
     pc.case_id, pc.accession_nbr, deceased_dt_tm_flag = evaluate(nullind(p.deceased_dt_tm),0,1,0),
     catalog_cd_flag = evaluate(nullind(sd.catalog_cd),0,1,0), temp_head = d1.seq
     FROM (dummyt d1  WITH seq = value(temp_size)),
      pathology_case pc,
      person p,
      prsnl pr,
      case_report cr,
      service_directory sd
     PLAN (d1)
      JOIN (pc
      WHERE (temp->qual[d1.seq].case_id=pc.case_id)
       AND pc.reserved_ind != 1)
      JOIN (pr
      WHERE pc.requesting_physician_id=pr.person_id)
      JOIN (p
      WHERE pc.person_id=p.person_id)
      JOIN (cr
      WHERE (cr.case_id= Outerjoin(pc.case_id)) )
      JOIN (sd
      WHERE (sd.catalog_cd= Outerjoin(cr.catalog_cd)) )
     ORDER BY temp_head, cr.report_sequence, sd.short_description
    ELSEIF ((context->patient_defined="T")
     AND (context->provider_defined="T")
     AND (context->specimen_defined="T"))
     PLAN (p
      WHERE parser(context_patient_where))
      JOIN (pc
      WHERE parser(context_case_where)
       AND parser(context_provider_where)
       AND pc.reserved_ind != 1)
      JOIN (ap
      WHERE pc.prefix_id=ap.prefix_id)
      JOIN (cs1
      WHERE parser(context_specimen_where)
       AND parser(cs1_cancel_where))
      JOIN (pr
      WHERE pc.requesting_physician_id=pr.person_id)
      JOIN (cr
      WHERE (cr.case_id= Outerjoin(pc.case_id))
       AND parser(cr_cancel_where))
      JOIN (sd
      WHERE (sd.catalog_cd= Outerjoin(cr.catalog_cd)) )
    ELSEIF ((context->patient_defined="T")
     AND (context->specimen_defined="T"))
     PLAN (p
      WHERE parser(context_patient_where))
      JOIN (pc
      WHERE parser(context_case_where)
       AND pc.reserved_ind != 1)
      JOIN (ap
      WHERE pc.prefix_id=ap.prefix_id)
      JOIN (cs1
      WHERE parser(context_specimen_where)
       AND parser(cs1_cancel_where))
      JOIN (pr
      WHERE pc.requesting_physician_id=pr.person_id)
      JOIN (cr
      WHERE (cr.case_id= Outerjoin(pc.case_id))
       AND parser(cr_cancel_where))
      JOIN (sd
      WHERE (sd.catalog_cd= Outerjoin(cr.catalog_cd)) )
    ELSEIF ((context->case_defined="T")
     AND (context->provider_defined="T")
     AND (context->specimen_defined="T"))
     PLAN (pc
      WHERE parser(context_case_where)
       AND parser(context_provider_where)
       AND pc.reserved_ind != 1)
      JOIN (ap
      WHERE pc.prefix_id=ap.prefix_id)
      JOIN (cs1
      WHERE parser(context_specimen_where)
       AND parser(cs1_cancel_where))
      JOIN (pr
      WHERE pc.requesting_physician_id=pr.person_id)
      JOIN (p
      WHERE pc.person_id=p.person_id)
      JOIN (cr
      WHERE (cr.case_id= Outerjoin(pc.case_id))
       AND parser(cr_cancel_where))
      JOIN (sd
      WHERE (sd.catalog_cd= Outerjoin(cr.catalog_cd)) )
    ELSEIF ((context->case_defined="T")
     AND (context->specimen_defined="T"))
     PLAN (pc
      WHERE parser(context_case_where)
       AND pc.reserved_ind != 1)
      JOIN (ap
      WHERE pc.prefix_id=ap.prefix_id)
      JOIN (cs1
      WHERE parser(context_specimen_where)
       AND parser(cs1_cancel_where))
      JOIN (pr
      WHERE pc.requesting_physician_id=pr.person_id)
      JOIN (p
      WHERE pc.person_id=p.person_id)
      JOIN (cr
      WHERE (cr.case_id= Outerjoin(pc.case_id))
       AND parser(cr_cancel_where))
      JOIN (sd
      WHERE (sd.catalog_cd= Outerjoin(cr.catalog_cd)) )
    ELSEIF ((context->provider_defined="T")
     AND (context->specimen_defined="T"))
     PLAN (pc
      WHERE parser(pc_cancel_where)
       AND pc.reserved_ind != 1
       AND parser(context_provider_where))
      JOIN (ap
      WHERE pc.prefix_id=ap.prefix_id)
      JOIN (cs1
      WHERE parser(context_specimen_where)
       AND parser(cs1_cancel_where))
      JOIN (pr
      WHERE pc.requesting_physician_id=pr.person_id)
      JOIN (p
      WHERE pc.person_id=p.person_id)
      JOIN (cr
      WHERE (cr.case_id= Outerjoin(pc.case_id))
       AND parser(cr_cancel_where))
      JOIN (sd
      WHERE (sd.catalog_cd= Outerjoin(cr.catalog_cd)) )
    ELSEIF ((context->patient_defined="T")
     AND (context->provider_defined="T"))
     PLAN (p
      WHERE parser(context_patient_where))
      JOIN (pc
      WHERE parser(context_case_where)
       AND parser(context_provider_where)
       AND pc.reserved_ind != 1)
      JOIN (ap
      WHERE pc.prefix_id=ap.prefix_id)
      JOIN (pr
      WHERE pc.requesting_physician_id=pr.person_id)
      JOIN (cr
      WHERE (cr.case_id= Outerjoin(pc.case_id))
       AND parser(cr_cancel_where))
      JOIN (sd
      WHERE (sd.catalog_cd= Outerjoin(cr.catalog_cd)) )
    ELSEIF ((context->patient_defined="T"))
     PLAN (p
      WHERE parser(context_patient_where))
      JOIN (pc
      WHERE parser(context_case_where)
       AND pc.reserved_ind != 1)
      JOIN (ap
      WHERE pc.prefix_id=ap.prefix_id)
      JOIN (pr
      WHERE pc.requesting_physician_id=pr.person_id)
      JOIN (cr
      WHERE (cr.case_id= Outerjoin(pc.case_id))
       AND parser(cr_cancel_where))
      JOIN (sd
      WHERE (sd.catalog_cd= Outerjoin(cr.catalog_cd)) )
    ELSEIF ((context->case_defined="T")
     AND (context->provider_defined="T"))
     PLAN (pc
      WHERE parser(context_case_where)
       AND parser(context_provider_where)
       AND pc.reserved_ind != 1)
      JOIN (ap
      WHERE pc.prefix_id=ap.prefix_id)
      JOIN (pr
      WHERE pc.requesting_physician_id=pr.person_id)
      JOIN (p
      WHERE pc.person_id=p.person_id)
      JOIN (cr
      WHERE (cr.case_id= Outerjoin(pc.case_id))
       AND parser(cr_cancel_where))
      JOIN (sd
      WHERE (sd.catalog_cd= Outerjoin(cr.catalog_cd)) )
    ELSEIF ((context->case_defined="T"))
     PLAN (pc
      WHERE parser(context_case_where)
       AND pc.reserved_ind != 1)
      JOIN (ap
      WHERE pc.prefix_id=ap.prefix_id)
      JOIN (pr
      WHERE pc.requesting_physician_id=pr.person_id)
      JOIN (p
      WHERE pc.person_id=p.person_id)
      JOIN (cr
      WHERE (cr.case_id= Outerjoin(pc.case_id))
       AND parser(cr_cancel_where))
      JOIN (sd
      WHERE (sd.catalog_cd= Outerjoin(cr.catalog_cd)) )
    ELSE
     PLAN (pc
      WHERE parser(pc_cancel_where)
       AND pc.reserved_ind != 1
       AND parser(context_provider_where))
      JOIN (ap
      WHERE pc.prefix_id=ap.prefix_id)
      JOIN (pr
      WHERE pc.requesting_physician_id=pr.person_id)
      JOIN (p
      WHERE pc.person_id=p.person_id)
      JOIN (cr
      WHERE (cr.case_id= Outerjoin(pc.case_id))
       AND parser(cr_cancel_where))
      JOIN (sd
      WHERE (sd.catalog_cd= Outerjoin(cr.catalog_cd)) )
    ENDIF
    INTO "nl:"
    pc.case_id, pc.accession_nbr, deceased_dt_tm_flag = evaluate(nullind(p.deceased_dt_tm),0,1,0),
    catalog_cd_flag = evaluate(nullind(sd.catalog_cd),0,1,0), temp_head = pc.accession_nbr
    FROM person p,
     pathology_case pc,
     ap_prefix ap,
     prsnl pr,
     case_report cr,
     service_directory sd
    ORDER BY temp_head DESC, cr.report_sequence, sd.short_description
    HEAD REPORT
     cnt = 0
     IF (inquiry_indicator=by_adhoc_qual_range)
      reply->context_more_data = "F"
     ENDIF
     service_resource_cd = 0.0, access_to_resource_ind = 0
    HEAD temp_head
     service_resource_cd = validate(ap.service_resource_cd,0.0), access_to_resource_ind = 0
     IF (isresourceviewable(service_resource_cd)=true)
      access_to_resource_ind = 1, cnt += 1
     ENDIF
     IF (access_to_resource_ind=1)
      IF ((cnt < (maxqualrows+ 1)))
       IF (cnt > size(reply->qual,5))
        stat = alterlist(reply->qual,(cnt+ 9))
       ENDIF
       rpt_cnt = 0, reply->qual[cnt].case_id = pc.case_id, reply->qual[cnt].fill_ext_accession_id =
       pc.case_id,
       reply->qual[cnt].encntr_id = pc.encntr_id, reply->qual[cnt].pc_cancel_cd = pc.cancel_cd, reply
       ->qual[cnt].pc_cancel_id = pc.cancel_id,
       reply->qual[cnt].pc_cancel_dt_tm = pc.cancel_dt_tm, reply->qual[cnt].accession_nbr = pc
       .accession_nbr, reply->qual[cnt].blob_bitmap = pc.blob_bitmap,
       reply->qual[cnt].case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm), reply->qual[cnt].
       case_received_dt_tm = cnvtdatetime(pc.case_received_dt_tm), reply->qual[cnt].
       case_received_by_id = pc.accession_prsnl_id,
       reply->qual[cnt].prefix_cd = pc.prefix_id, reply->qual[cnt].case_year = pc.case_year, reply->
       qual[cnt].case_number = pc.case_number,
       reply->qual[cnt].case_comment_long_text_id = pc.comments_long_text_id, reply->qual[cnt].
       req_physician_name = pr.name_full_formatted, reply->qual[cnt].req_physician_id = pr.person_id,
       reply->qual[cnt].person_id = p.person_id, reply->qual[cnt].person_name = p.name_full_formatted,
       reply->qual[cnt].sex_cd = p.sex_cd,
       reply->qual[cnt].responsible_pathologist_id = pc.responsible_pathologist_id, reply->qual[cnt].
       responsible_resident_id = pc.responsible_resident_id, reply->qual[cnt].
       main_report_cmplete_dt_tm = cnvtdatetime(pc.main_report_cmplete_dt_tm),
       reply->qual[cnt].age = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"), reply->qual[cnt]
       .birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->qual[cnt].birth_tz = validate(p.birth_tz,0)
       IF (deceased_dt_tm_flag=1)
        reply->qual[cnt].deceased_dt_tm = p.deceased_dt_tm
       ELSE
        reply->qual[cnt].deceased_dt_tm = 0
       ENDIF
      ENDIF
     ENDIF
     IF ((cnt=(maxqualrows+ 1)))
      reply->context_more_data = "T", context->accession_nbr = pc.accession_nbr, context->context_ind
       = 1,
      context->maxqual = maxqualrows
     ENDIF
    DETAIL
     IF (catalog_cd_flag=1)
      IF (access_to_resource_ind=1)
       IF ((cnt < (maxqualrows+ 1)))
        rpt_cnt += 1
        IF (rpt_cnt > size(reply->qual[cnt].rpt_qual,5))
         stat = alterlist(reply->qual[cnt].rpt_qual,(rpt_cnt+ 4))
        ENDIF
        reply->qual[cnt].rpt_cnt = rpt_cnt, reply->qual[cnt].rpt_qual[rpt_cnt].report_id = cr
        .report_id, reply->qual[cnt].rpt_qual[rpt_cnt].blob_bitmap = cr.blob_bitmap,
        reply->qual[cnt].rpt_qual[rpt_cnt].report_sequence = cr.report_sequence, reply->qual[cnt].
        rpt_qual[rpt_cnt].catalog_cd = cr.catalog_cd, reply->qual[cnt].rpt_qual[rpt_cnt].
        short_description = sd.short_description,
        reply->qual[cnt].rpt_qual[rpt_cnt].long_description = sd.description, reply->qual[cnt].
        rpt_qual[rpt_cnt].event_id = cr.event_id, reply->qual[cnt].rpt_qual[rpt_cnt].status_cd = cr
        .status_cd
       ENDIF
      ENDIF
     ENDIF
    FOOT  temp_head
     IF (access_to_resource_ind=1)
      IF ((cnt < (maxqualrows+ 1)))
       stat = alterlist(reply->qual[cnt].rpt_qual,rpt_cnt)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (cnt <= maxqualrows)
    SET stat = alterlist(reply->qual,cnt)
   ELSE
    SET stat = alterlist(reply->qual,maxqualrows)
   ENDIF
   IF (validate(temp_rsrc_security))
    FREE SET temp_rsrc_security
   ENDIF
   IF (validate(dtemp))
    FREE SET dtemp
   ENDIF
   IF (validate(temp))
    FREE SET temp
    SET temp_size = 0
   ENDIF
   CALL get_case_specimens(null)
   SET temp_size = size(reply->qual,5)
   FOR (idx = temp_size TO 1 BY - (1))
     IF (size(reply->qual[idx].spec_qual,5)=0
      AND size(reply->qual[idx].rpt_qual,5)=0)
      SET stat = alterlist(reply->qual,(size(reply->qual,5) - 1),(idx - 1))
     ENDIF
   ENDFOR
   CALL validate_qual_data(size(reply->qual,5))
   IF ((reply->context_more_data="F"))
    FREE SET context
   ENDIF
 END ;Subroutine
#exit_script
END GO
