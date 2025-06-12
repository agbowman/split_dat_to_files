CREATE PROGRAM aps_get_query_results:dba
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
#script
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
 SET cnt = 0
 SET maxqualrows = 0
 SET accession_nbr_where = fillstring(50," ")
 SET case_query_id = 0.0
 SET reply->context_more_data = "F"
 SET reply->status_data.status = "F"
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 DECLARE get_report_details(null) = null WITH protect
 DECLARE get_prsnl_name(null) = null WITH protect
 CALL initresourcesecurity(1)
 IF (validate(context->context_ind,0) != 0)
  SET maxqualrows = context->maxqual
  SET case_query_id = context->case_query_id
  SET accession_nbr_where = build("'",context->accession_nbr,"' >= pc.accession_nbr ")
 ELSE
  SET maxqualrows = request->maxqual
  SET case_query_id = request->case_query_id
  SET accession_nbr_where = build(0," = ",0)
  RECORD context(
    1 context_ind = i4
    1 maxqual = i4
    1 accession_nbr = vc
    1 case_query_id = f8
  )
 ENDIF
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SELECT INTO "nl:"
  pc.case_id, pc.accession_nbr, join_path = decode(d1.seq,"S","R"),
  t.tag_group_id, t.tag_sequence, nullind_p_deceased_dt_tm = nullind(p.deceased_dt_tm)
  FROM pathology_case pc,
   prsnl pr,
   person p,
   ap_prefix ap,
   (dummyt d1  WITH seq = 1),
   case_specimen cs,
   ap_tag t,
   (dummyt d2  WITH seq = 1),
   case_report cr,
   service_directory sd,
   ap_query_result aqr
  PLAN (aqr
   WHERE aqr.case_query_id=case_query_id)
   JOIN (pc
   WHERE aqr.accession_nbr=pc.accession_nbr
    AND parser(accession_nbr_where))
   JOIN (pr
   WHERE pc.requesting_physician_id=pr.person_id)
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (ap
   WHERE pc.prefix_id=ap.prefix_id)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (cs
   WHERE pc.case_id=cs.case_id
    AND cs.cancel_cd IN (null, 0))
   JOIN (t
   WHERE cs.specimen_tag_id=t.tag_id)
   ) ORJOIN ((d2
   WHERE 1=d2.seq)
   JOIN (cr
   WHERE pc.case_id=cr.case_id
    AND cr.cancel_cd IN (null, 0))
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   ))
  ORDER BY pc.accession_nbr DESC, cr.report_sequence, sd.short_description,
   t.tag_group_id, t.tag_sequence
  HEAD REPORT
   cnt = 0, reply->context_more_data = "F", context->context_ind = 0,
   service_resource_cd = 0.0, access_to_resource_ind = 0
  HEAD pc.accession_nbr
   service_resource_cd = ap.service_resource_cd, access_to_resource_ind = 0
   IF (isresourceviewable(service_resource_cd)=true)
    access_to_resource_ind = 1, cnt += 1
    IF ((cnt < (maxqualrows+ 1)))
     IF (mod(cnt,10)=1)
      stat = alterlist(reply->qual,(cnt+ 9))
     ENDIF
     spec_cnt = 0, rpt_cnt = 0, stat = alterlist(reply->qual[cnt].spec_qual,5),
     stat = alterlist(reply->qual[cnt].rpt_qual,5), reply->qual[cnt].case_id = pc.case_id, reply->
     qual[cnt].fill_ext_accession_id = pc.case_id,
     reply->qual[cnt].encntr_id = pc.encntr_id, reply->qual[cnt].pc_cancel_cd = pc.cancel_cd, reply->
     qual[cnt].pc_cancel_id = pc.cancel_id,
     reply->qual[cnt].pc_cancel_dt_tm = pc.cancel_dt_tm, reply->qual[cnt].accession_nbr = pc
     .accession_nbr, reply->qual[cnt].blob_bitmap = pc.blob_bitmap,
     reply->qual[cnt].case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm), reply->qual[cnt].
     case_received_dt_tm = cnvtdatetime(pc.case_received_dt_tm), reply->qual[cnt].case_received_by_id
      = pc.accession_prsnl_id,
     reply->qual[cnt].prefix_cd = pc.prefix_id, reply->qual[cnt].case_year = pc.case_year, reply->
     qual[cnt].case_number = pc.case_number,
     reply->qual[cnt].case_comment_long_text_id = pc.comments_long_text_id, reply->qual[cnt].
     req_physician_name = pr.name_full_formatted, reply->qual[cnt].req_physician_id = pr.person_id,
     reply->qual[cnt].person_id = p.person_id, reply->qual[cnt].person_name = p.name_full_formatted,
     reply->qual[cnt].sex_cd = p.sex_cd,
     reply->qual[cnt].responsible_pathologist_id = pc.responsible_pathologist_id, reply->qual[cnt].
     responsible_resident_id = pc.responsible_resident_id, reply->qual[cnt].age = formatage(p
      .birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"),
     reply->qual[cnt].birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->qual[cnt].birth_tz = p
     .birth_tz
     IF (nullind_p_deceased_dt_tm=0)
      reply->qual[cnt].deceased_dt_tm = cnvtdatetime(p.deceased_dt_tm)
     ELSE
      reply->qual[cnt].deceased_dt_tm = 0
     ENDIF
    ENDIF
    IF ((cnt=(maxqualrows+ 1)))
     reply->context_more_data = "T", context->context_ind = 1, context->case_query_id = request->
     case_query_id,
     context->accession_nbr = pc.accession_nbr, context->maxqual = maxqualrows
    ENDIF
   ENDIF
  DETAIL
   IF (access_to_resource_ind=1)
    IF ((cnt < (maxqualrows+ 1)))
     CASE (join_path)
      OF "S":
       spec_cnt += 1,
       IF (mod(spec_cnt,5)=1
        AND spec_cnt != 1)
        stat = alterlist(reply->qual[cnt].spec_qual,(spec_cnt+ 4))
       ENDIF
       ,reply->qual[cnt].spec_cnt = spec_cnt,reply->qual[cnt].spec_qual[spec_cnt].case_specimen_id =
       cs.case_specimen_id,reply->qual[cnt].spec_qual[spec_cnt].specimen_tag_group_cd = t
       .tag_group_id,
       reply->qual[cnt].spec_qual[spec_cnt].specimen_tag_sequence = t.tag_sequence,reply->qual[cnt].
       spec_qual[spec_cnt].specimen_tag_display = t.tag_disp,reply->qual[cnt].spec_qual[spec_cnt].
       specimen_tag_cd = cs.specimen_tag_id,
       reply->qual[cnt].spec_qual[spec_cnt].specimen_description = trim(cs.specimen_description),
       reply->qual[cnt].spec_qual[spec_cnt].specimen_cd = cs.specimen_cd
      OF "R":
       rpt_cnt += 1,
       IF (mod(rpt_cnt,5)=1
        AND rpt_cnt != 1)
        stat = alterlist(reply->qual[cnt].rpt_qual,(rpt_cnt+ 4))
       ENDIF
       ,reply->qual[cnt].rpt_cnt = rpt_cnt,reply->qual[cnt].rpt_qual[rpt_cnt].report_id = cr
       .report_id,reply->qual[cnt].rpt_qual[rpt_cnt].blob_bitmap = cr.blob_bitmap,
       reply->qual[cnt].rpt_qual[rpt_cnt].report_sequence = cr.report_sequence,reply->qual[cnt].
       rpt_qual[rpt_cnt].catalog_cd = cr.catalog_cd,reply->qual[cnt].rpt_qual[rpt_cnt].
       short_description = sd.short_description,
       reply->qual[cnt].rpt_qual[rpt_cnt].long_description = sd.description,reply->qual[cnt].
       rpt_qual[rpt_cnt].event_id = cr.event_id,reply->qual[cnt].rpt_qual[rpt_cnt].status_cd = cr
       .status_cd
     ENDCASE
    ENDIF
   ENDIF
  FOOT  pc.accession_nbr
   IF (access_to_resource_ind=1)
    IF ((cnt < (maxqualrows+ 1)))
     stat = alterlist(reply->qual[cnt].spec_qual,spec_cnt), stat = alterlist(reply->qual[cnt].
      rpt_qual,rpt_cnt)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(1)
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (cnt <= maxqualrows)
  SET stat = alterlist(reply->qual,cnt)
 ELSE
  SET stat = alterlist(reply->qual,maxqualrows)
 ENDIF
 SELECT INTO "nl:"
  ea.encntr_id, frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM (dummyt d1  WITH seq = value(size(reply->qual,5))),
   encntr_alias ea,
   encounter e
  PLAN (d1
   WHERE (reply->qual[d1.seq].encntr_id > 0))
   JOIN (e
   WHERE (reply->qual[d1.seq].encntr_id=e.encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ((e.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (e.end_effective_dt_tm=null)) )
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY d1.seq
  DETAIL
   reply->qual[d1.seq].person_num = frmt_mrn
  WITH nocounter
 ;end select
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
 DECLARE idx = i4
 DECLARE lpos = i4
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt
  PLAN (lt
   WHERE expand(idx,1,size(reply->qual,5),lt.long_text_id,reply->qual[idx].case_comment_long_text_id)
    AND lt.long_text_id > 0)
  DETAIL
   lpos = locateval(idx,1,size(reply->qual,5),lt.long_text_id,reply->qual[idx].
    case_comment_long_text_id)
   IF (lpos > 0)
    reply->qual[lpos].case_comment = trim(lt.long_text)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 DECLARE eidx = i4
 DECLARE lpos1 = i4
 SELECT INTO "nl:"
  lt.long_text_id, lt.long_text
  FROM (dummyt d1  WITH seq = size(reply->qual,5)),
   long_text lt,
   report_task rt
  PLAN (d1
   WHERE (reply->qual[d1.seq].case_id > 0)
    AND (reply->qual[d1.seq].rpt_cnt > 0))
   JOIN (rt
   WHERE expand(eidx,1,maxval(1,reply->qual[d1.seq].rpt_cnt),rt.report_id,reply->qual[d1.seq].
    rpt_qual[eidx].report_id))
   JOIN (lt
   WHERE rt.comments_long_text_id=lt.long_text_id)
  DETAIL
   lpos1 = locateval(idx,1,reply->qual[d1.seq].rpt_cnt,rt.report_id,reply->qual[d1.seq].rpt_qual[idx]
    .report_id)
   IF (lpos1 > 0)
    IF (rt.comments_long_text_id > 0)
     reply->qual[d1.seq].rpt_qual[lpos1].comment_long_text_id = lt.long_text_id, reply->qual[d1.seq].
     rpt_qual[lpos1].comment = lt.long_text
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 CALL get_report_details(null)
 CALL get_prsnl_name(null)
 IF (size(reply->qual,5) > 0)
  IF ((reply->status_data.status="S"))
   EXECUTE pcs_fill_ext_accs_by_acc  WITH replace("REQUESTREPLY","REPLY")
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
 IF ((context->context_ind=0))
  FREE SET context
 ENDIF
END GO
