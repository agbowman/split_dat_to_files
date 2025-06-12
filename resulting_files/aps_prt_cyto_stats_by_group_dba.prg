CREATE PROGRAM aps_prt_cyto_stats_by_group:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 title = vc
   1 aprpt = vc
   1 ddate = vc
   1 dir = vc
   1 ttime = vc
   1 cytstats = vc
   1 bby = vc
   1 ppage = vc
   1 group = vc
   1 inactincl = vc
   1 dtrange = vc
   1 summarycase = vc
   1 numinslides = vc
   1 numoutslides = vc
   1 numcases = vc
   1 numslides = vc
   1 casetype = vc
   1 scrn = vc
   1 total = vc
   1 gyncytflwup = vc
   1 nocases = vc
   1 footer = vc
   1 continued = vc
   1 specimen = vc
   1 allspec = vc
   1 followuptype = vc
   1 inprognoovrdue = vc
   1 inprogovrdue = vc
   1 flwupdiscont = vc
   1 wtermreason = vc
   1 autotermbysys = vc
   1 notermdtrange = vc
   1 gyncyto = vc
   1 nongyncyto = vc
   1 allcyto = vc
   1 source = vc
   1 numspec = vc
   1 nospecfound = vc
   1 vardisstats = vc
   1 category = vc
   1 percases = vc
   1 discrep = vc
   1 variance = vc
   1 diagsum = vc
   1 rptveras = vc
   1 gyncytdiagcat = vc
   1 aand = vc
   1 nongyncytdiagcat = vc
   1 nongynspec = vc
 )
 SET captions->title = uar_i18ngetmessage(i18nhandle,"title",
  "REPORT: APS_PRT_CYTO_STATS_BY_GROUP.PRG")
 SET captions->aprpt = uar_i18ngetmessage(i18nhandle,"aprpt","Anatomic Pathology Report")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->cytstats = uar_i18ngetmessage(i18nhandle,"cytstats","CYTOLOGY STATISTICS BY GROUP")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->group = uar_i18ngetmessage(i18nhandle,"group","GROUP")
 SET captions->inactincl = uar_i18ngetmessage(i18nhandle,"inactincl","(Inactives included)")
 SET captions->dtrange = uar_i18ngetmessage(i18nhandle,"dtrange","DATE RANGE")
 SET captions->summarycase = uar_i18ngetmessage(i18nhandle,"summarycase",
  "SUMMARY CASE AND SLIDE COUNTS STATISTICS")
 SET captions->numinslides = uar_i18ngetmessage(i18nhandle,"numinslides","# INSIDE SLIDES")
 SET captions->numoutslides = uar_i18ngetmessage(i18nhandle,"numoutslides","# OUTSIDE SLIDES")
 SET captions->numcases = uar_i18ngetmessage(i18nhandle,"numcases","# CASES")
 SET captions->numslides = uar_i18ngetmessage(i18nhandle,"numslides","# SLIDES")
 SET captions->casetype = uar_i18ngetmessage(i18nhandle,"casetype","CASE TYPE")
 SET captions->scrn = uar_i18ngetmessage(i18nhandle,"scrn","SCREENED/RESCREENED")
 SET captions->total = uar_i18ngetmessage(i18nhandle,"total","TOTAL")
 SET captions->gyncytflwup = uar_i18ngetmessage(i18nhandle,"gyncytflwup",
  "GYNECOLOGIC CYTOLOGY FOLLOW-UP TRACKING STATISTICS")
 SET captions->nocases = uar_i18ngetmessage(i18nhandle,"nocases",
  "No cases meeting selection criteria.")
 SET captions->footer = uar_i18ngetmessage(i18nhandle,"footer","REPORT: CYTOLOGY STATISTICS BY GROUP"
  )
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"continued","CONTINUED...")
 SET captions->specimen = uar_i18ngetmessage(i18nhandle,"specimen","SPECIMEN")
 SET captions->allspec = uar_i18ngetmessage(i18nhandle,"allspec","ALL SPECIMENS")
 SET captions->followuptype = uar_i18ngetmessage(i18nhandle,"followuptype","FOLLOW-UP TYPE")
 SET captions->inprognoovrdue = uar_i18ngetmessage(i18nhandle,"inprognoovrdue",
  "TOTAL # CASES WHERE FOLLOW-UP IS IN PROGRESS, AND NOT OVERDUE")
 SET captions->inprogovrdue = uar_i18ngetmessage(i18nhandle,"inprogovrdue",
  "TOTAL # CASES WHERE FOLLOW-UP IS IN PROGRESS, AND OVERDUE")
 SET captions->flwupdiscont = uar_i18ngetmessage(i18nhandle,"flwupdiscont",
  "TOTAL # CASES WHERE FOLLOW-UP WAS DISCONTINUED")
 SET captions->wtermreason = uar_i18ngetmessage(i18nhandle,"wtermreason","WITH TERMINATION REASON")
 SET captions->autotermbysys = uar_i18ngetmessage(i18nhandle,"autotermbysys",
  "AUTO TERMINATED BY SYSTEM")
 SET captions->notermdtrange = uar_i18ngetmessage(i18nhandle,"notermdtrange",
  "NO CASES TERMINATED WITHIN SELECTED DATE RANGE")
 SET captions->gyncyto = uar_i18ngetmessage(i18nhandle,"gyncyto","GYNECOLOGIC CYTOLOGY")
 SET captions->nongyncyto = uar_i18ngetmessage(i18nhandle,"nongyncyto","NON-GYNECOLOGIC CYTOLOGY")
 SET captions->allcyto = uar_i18ngetmessage(i18nhandle,"allcyto","ALL CYTOLOGY")
 SET captions->source = uar_i18ngetmessage(i18nhandle,"source","SOURCE")
 SET captions->numspec = uar_i18ngetmessage(i18nhandle,"numspec","# SPECIMENS")
 SET captions->nospecfound = uar_i18ngetmessage(i18nhandle,"nospecfound","NO SPECIMENS FOUND")
 SET captions->vardisstats = uar_i18ngetmessage(i18nhandle,"vardisstats",
  "VARIANCE AND DISCREPANCY STATISTICS")
 SET captions->category = uar_i18ngetmessage(i18nhandle,"category","CATEGORY")
 SET captions->percases = uar_i18ngetmessage(i18nhandle,"percases","% CASES")
 SET captions->discrep = uar_i18ngetmessage(i18nhandle,"discrep","DISCREPANCY")
 SET captions->variance = uar_i18ngetmessage(i18nhandle,"variance","VARIANCE")
 SET captions->diagsum = uar_i18ngetmessage(i18nhandle,"diagsum","DIAGNOSTIC SUMMARY")
 SET captions->rptveras = uar_i18ngetmessage(i18nhandle,"rptveras","REPORT VERIFIED AS")
 SET captions->gyncytdiagcat = uar_i18ngetmessage(i18nhandle,"gyncytdiagcat",
  "GYN CYTOLOGY DIAGNOSTIC CATEGORY")
 SET captions->aand = uar_i18ngetmessage(i18nhandle,"aand","AND")
 SET captions->nongyncytdiagcat = uar_i18ngetmessage(i18nhandle,"nongyncytdiagcat",
  "NON-GYN CYTOLOGY DIAGNOSTIC CATEGORY")
 SET captions->nongynspec = uar_i18ngetmessage(i18nhandle,"nongynspec",
  "NON-GYNECOLOGIC CYTOLOGY SPECIMENS BY SOURCE")
 RECORD temp(
   1 run_group = c40
   1 run_date = c40
   1 d_start_dt = dq8
   1 d_end_dt = dq8
   1 d2_start_dt = dq8
   1 d2_end_dt = dq8
   1 m_start_dt = dq8
   1 m_end_dt = dq8
   1 process_monthly_flag = c1
   1 screener_qual[*]
     2 prsnl_id = f8
   1 section_qual[*]
     2 section = i4
     2 row_qual[*]
       3 row_text = c150
   1 diag_cat_qual[*]
     2 category_cd = f8
     2 category_disp = c40
     2 cdf_meaning = c12
     2 rpt_cnt = i4
   1 another_qual[*]
     2 case_id = f8
     2 diagnostic_category_cd = f8
     2 specimen_cd = f8
   1 sorted_another_qual[*]
     2 case_id = f8
     2 diagnostic_category_cd = f8
     2 specimen_cd = f8
   1 specimen_qual[*]
     2 specimen_cd = f8
     2 specimen_disp = vc
     2 tot_diag_cnt = i4
     2 diagnosis[*]
       3 diagnostic_category_cd = f8
       3 diagnostic_category_disp = vc
       3 diagnostic_cnt = i4
       3 case_qual[*]
         4 case_id = f8
 )
 RECORD temp_spec(
   1 total = i4
   1 qual[*]
     2 cdf_description = c40
     2 spec_cd = f8
     2 spec_cnt = i4
 )
 RECORD temp_term(
   1 qual[*]
     2 followup_type_cd = f8
     2 term_qual[*]
       3 term_reason_cd = f8
       3 term_reason_description = c40
       3 term_cnt = i4
 )
 RECORD temp_followup(
   1 qual[*]
     2 followup_type_cd = f8
     2 followup_type_short_name = c40
     2 followup_type_desc = c60
     2 followup_not_overdue = i4
     2 followup_overdue = i4
 )
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
#script
 SET no_ngyn_diagnosis = "F"
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET check_pg_active = fillstring(30," ")
 SET check_pgr_active = fillstring(30," ")
 SET check_pgr1_active = fillstring(30," ")
 SET check_csl_active = fillstring(30," ")
 SET check_css_active = fillstring(30," ")
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
 IF (textlen(trim(request->batch_selection)) > 0)
  SET raw_ft_type_str = fillstring(100," ")
  SET ft_type_str = fillstring(100," ")
  SET raw_prsnl_group_str = fillstring(100," ")
  SET new_size = 0
  SET raw_date_str = fillstring(4," ")
  SET raw_date_num_str = 0
  SET printer = fillstring(100," ")
  SET copies = 0
  CALL initresourcesecurity(1)
  CALL populatesrtypesforsecurity(1)
  IF (textlen(trim(request->output_dist))=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with output_dist!"
   GO TO end_script
  ENDIF
  SELECT INTO "nl:"
   x = 1
   DETAIL
    CALL get_text(x,trim(request->batch_selection),"|"), raw_ft_type_str = concat(trim(text),","),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    raw_date_str = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_prsnl_group_str = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->separate_diagnosis = trim(
     text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    request->bshowinactives = cnvtint(trim(text)), request->scuruser = "Operations",
    CALL get_text(1,trim(request->output_dist),"|"),
    printer = trim(text),
    CALL get_text(startpos2,trim(request->output_dist),"|"), copies = cnvtint(trim(text))
   WITH nocounter
  ;end select
  IF ((request->bshowinactives=0))
   SET check_pg_active = "pg.active_ind = 1"
   SET check_pgr_active = "pgr.active_ind = 1"
   SET check_pgr1_active = "pgr1.active_ind = 1"
   SET check_csl_active = "csl.active_ind = 1"
   SET check_css_active = "css.active_ind = 1"
  ELSE
   SET check_pg_active = "pg.active_ind in (0,1)"
   SET check_pgr_active = "pgr.active_ind in (0,1)"
   SET check_pgr1_active = "pgr1.active_ind in (0,1)"
   SET check_csl_active = "csl.active_ind in (0,1)"
   SET check_css_active = "css.active_ind in (0,1)"
  ENDIF
  SET startpos2 = 1
  SET endstring = "F"
  WHILE (endstring="F")
    SELECT INTO "nl:"
     x = 1
     DETAIL
      CALL get_text(startpos2,trim(raw_ft_type_str),","), ft_type_str = text
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     WHERE 1317=cv.code_set
      AND ft_type_str=cv.display
     DETAIL
      new_size += 1, stat = alterlist(request->followup_qual,new_size), request->followup_qual[
      new_size].followup_type_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->ops_event = "Failure - Error with codeset 1317!"
     GO TO end_script
    ENDIF
  ENDWHILE
  IF (textlen(trim(raw_prsnl_group_str)) > 0)
   SELECT INTO "nl:"
    cv.code_value, pg.prsnl_group_id
    FROM code_value cv,
     prsnl_group pg
    PLAN (cv
     WHERE cv.code_set=357
      AND cv.cdf_meaning="CYTORPTGRP")
     JOIN (pg
     WHERE cv.code_value=pg.prsnl_group_type_cd
      AND raw_prsnl_group_str=pg.prsnl_group_name
      AND parser(check_pg_active)
      AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     service_resource_cd = pg.service_resource_cd
     IF (isresourceviewable(service_resource_cd)=true)
      request->prsnl_group_id = pg.prsnl_group_id
     ENDIF
    WITH nocounter
   ;end select
   IF (((curqual=0) OR (getresourcesecuritystatus(0) != "S")) )
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with prsnl_group id!"
    GO TO end_script
   ENDIF
  ELSE
   SET request->prsnl_group_id = 0
  ENDIF
  SET raw_date_num_str = cnvtint(substring(1,3,raw_date_str))
  SET request->end_dt = cnvtdatetime(sysdate)
  CASE (substring(4,1,raw_date_str))
   OF "D":
    SET request->start_dt = cnvtagedatetime(0,0,0,raw_date_num_str)
   OF "M":
    SET request->start_dt = cnvtagedatetime(0,raw_date_num_str,0,0)
   OF "Y":
    SET request->start_dt = cnvtagedatetime(raw_date_num_str,0,0,0)
   ELSE
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with date routine setup!"
    GO TO end_script
  ENDCASE
 ENDIF
 IF ((request->bshowinactives=0))
  SET check_pg_active = "pg.active_ind = 1"
  SET check_pgr_active = "pgr.active_ind = 1"
  SET check_pgr1_active = "pgr1.active_ind = 1"
  SET check_csl_active = "csl.active_ind = 1"
  SET check_css_active = "css.active_ind = 1"
 ELSE
  SET check_pg_active = "pg.active_ind in (0,1)"
  SET check_pgr_active = "pgr.active_ind in (0,1)"
  SET check_pgr1_active = "pgr1.active_ind in (0,1)"
  SET check_csl_active = "csl.active_ind in (0,1)"
  SET check_css_active = "css.active_ind in (0,1)"
 ENDIF
 CALL getstartofday(request->start_dt,0)
 SET request->start_dt = dtemp->beg_of_day
 CALL getendofday(request->end_dt,0)
 SET request->end_dt = dtemp->end_of_day
 SET end_month = cnvtint(format(cnvtdatetime(request->end_dt),"mm;;d"))
 SET start_month = cnvtint(format(cnvtdatetime(request->start_dt),"mm;;d"))
 SET end_year = cnvtint(format(cnvtdatetime(request->end_dt),"yy;;d"))
 SET start_year = cnvtint(format(cnvtdatetime(request->start_dt),"yy;;d"))
 SET strdate = cnvtdate2(format(cnvtdatetime(request->start_dt),"yy/mm/dd;;d"),"yy/mm/dd")
 SET enddate = cnvtdate2(format(cnvtdatetime(request->end_dt),"yy/mm/dd;;d"),"yy/mm/dd")
 IF (cnvtint(format(cnvtdatetime(datetimediff(request->end_dt,request->start_dt,1)),"mm;;d")) > 2)
  CALL getstartofdayabs(request->start_dt,0)
  SET temp->d_start_dt = dtemp->beg_of_day_abs
  CALL echo("*******************Reached Here")
  CALL getendofmonthabs(request->start_dt,0)
  SET temp->d_end_dt = dtemp->end_of_month_abs
  CALL getstartofmonthabs(request->end_dt,0)
  SET temp->d2_start_dt = dtemp->beg_of_month_abs
  CALL getendofdayabs(request->end_dt,0)
  SET temp->d2_end_dt = dtemp->end_of_day_abs
  CALL getstartofmonthabs(request->start_dt,1)
  SET temp->m_start_dt = dtemp->beg_of_month_abs
  CALL getendofmonthabs(request->end_dt,- (1))
  SET temp->m_end_dt = dtemp->end_of_month_abs
  SET temp->process_monthly_flag = "Y"
 ELSE
  CALL getstartofdayabs(request->start_dt,0)
  SET temp->d_start_dt = dtemp->beg_of_day_abs
  CALL getendofdayabs(request->end_dt,0)
  SET temp->d_end_dt = dtemp->end_of_day_abs
  CALL getstartofdayabs(request->start_dt,0)
  SET temp->d2_start_dt = dtemp->beg_of_day_abs
  CALL getendofdayabs(request->end_dt,0)
  SET temp->d2_end_dt = dtemp->end_of_day_abs
  SET temp->m_start_dt = null
  SET temp->m_end_dt = null
  SET temp->process_monthly_flag = "N"
 ENDIF
 SET temp->run_date = concat(format(cnvtdatetime(request->start_dt),"@SHORTDATE4YR;;d"),"  -  ",
  format(cnvtdatetime(request->end_dt),"@SHORTDATE4YR;;d"))
 SELECT INTO "nl:"
  pg.prsnl_group_name
  FROM prsnl_group pg
  WHERE (request->prsnl_group_id=pg.prsnl_group_id)
   AND parser(check_pg_active)
   AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
   AND pg.end_effective_dt_tm > cnvtdatetime(sysdate)
  DETAIL
   temp->run_group = trim(pg.prsnl_group_name)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","PRSNL_GROUP")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pgr.prsnl_group_reltn_id, pgr.person_id
  FROM prsnl_group_reltn pgr,
   dummyt d,
   cyto_screening_limits csl,
   cyto_screening_security css,
   code_value cv,
   prsnl_group pg,
   prsnl_group_reltn pgr1
  PLAN (pgr
   WHERE (request->prsnl_group_id=pgr.prsnl_group_id)
    AND parser(check_pgr_active))
   JOIN (d)
   JOIN (((csl
   WHERE pgr.person_id=csl.prsnl_id
    AND parser(check_csl_active))
   JOIN (css
   WHERE csl.prsnl_id=css.prsnl_id
    AND parser(check_css_active))
   ) ORJOIN ((cv
   WHERE cv.code_set=357
    AND ((cv.cdf_meaning="PATHOLOGIST") OR (cv.cdf_meaning="PATHRESIDENT")) )
   JOIN (pg
   WHERE cv.code_value=pg.prsnl_group_type_cd
    AND parser(check_pg_active)
    AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pgr1
   WHERE pg.prsnl_group_id=pgr1.prsnl_group_id
    AND pgr.person_id=pgr1.person_id
    AND parser(check_pgr1_active))
   ))
  ORDER BY pgr.person_id
  HEAD REPORT
   cnt = 0
  HEAD pgr.person_id
   cnt += 1, stat = alterlist(temp->screener_qual,cnt), temp->screener_qual[cnt].prsnl_id = pgr
   .person_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","PRSNL_GROUP_RELTN")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cv.code_value, cv.display_key
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(request->followup_qual,5)))
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=1317
    AND (cv.code_value=request->followup_qual[d.seq].followup_type_cd))
  ORDER BY cv.display_key
  HEAD REPORT
   x = 0
  DETAIL
   x += 1, stat = alterlist(temp_followup->qual,x), temp_followup->qual[x].followup_type_cd = cv
   .code_value,
   temp_followup->qual[x].followup_type_short_name = cv.display, temp_followup->qual[x].
   followup_type_desc = cv.description
  WITH nocounter
 ;end select
 SET code_value = 0.0
 SET ngyn_code = 0.0
 SET code_set = 1301
 SET cdf_meaning = "NGYN"
 EXECUTE cpm_get_cd_for_cdf
 SET ngyn_code = code_value
 SELECT INTO "nl:"
  cs.specimen_cd
  FROM cyto_screening_event cse1,
   cyto_screening_event cse2,
   case_specimen cs,
   (dummyt d  WITH seq = value(size(temp->screener_qual,5))),
   pathology_case pc
  PLAN (d)
   JOIN (cse1
   WHERE (cse1.screener_id=temp->screener_qual[d.seq].prsnl_id)
    AND cse1.screen_dt_tm BETWEEN cnvtdatetime(request->start_dt) AND cnvtdatetime(request->end_dt)
    AND cse1.active_ind=1
    AND cse1.initial_screener_ind=1)
   JOIN (cse2
   WHERE cse1.case_id=cse2.case_id
    AND cse2.verify_ind=1
    AND cse2.active_ind=1)
   JOIN (pc
   WHERE cse2.case_id=pc.case_id
    AND pc.case_type_cd=ngyn_code)
   JOIN (cs
   WHERE cse2.case_id=cs.case_id
    AND cs.cancel_cd IN (null, 0.0))
  ORDER BY cs.specimen_cd
  HEAD REPORT
   spec_cnt = 0
  HEAD cs.specimen_cd
   spec_cnt += 1, stat = alterlist(temp_spec->qual,spec_cnt), temp_spec->qual[spec_cnt].spec_cd = cs
   .specimen_cd,
   temp_spec->qual[spec_cnt].cdf_description = substring(1,40,uar_get_code_description(cs.specimen_cd
     ))
  DETAIL
   temp_spec->qual[spec_cnt].spec_cnt += 1, temp_spec->total += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cs.specimen_cd, pc.case_id, pc.accession_nbr,
  pc.main_report_cmplete_dt_tm, cse.case_id, cse.screener_id,
  cse.verify_ind, d.seq
  FROM pathology_case pc,
   cyto_screening_event cse,
   case_specimen cs,
   (dummyt d  WITH seq = value(size(temp->screener_qual,5)))
  PLAN (pc
   WHERE pc.main_report_cmplete_dt_tm BETWEEN cnvtdatetime(request->start_dt) AND cnvtdatetime(
    request->end_dt)
    AND pc.case_type_cd=ngyn_code)
   JOIN (d)
   JOIN (cse
   WHERE pc.case_id=cse.case_id
    AND ((cse.screener_id+ 0)=temp->screener_qual[d.seq].prsnl_id)
    AND cse.verify_ind=1)
   JOIN (cs
   WHERE cse.case_id=cs.case_id
    AND cs.cancel_cd IN (null, 0.0))
  ORDER BY cs.specimen_cd, cse.diagnostic_category_cd
  HEAD REPORT
   spec_cnt = 0, cntr = 0
  HEAD cs.specimen_cd
   spec_cnt += 1
  DETAIL
   cntr += 1, stat = alterlist(temp->another_qual,cntr), temp->another_qual[cntr].case_id = cse
   .case_id,
   temp->another_qual[cntr].specimen_cd = cs.specimen_cd, temp->another_qual[cntr].
   diagnostic_category_cd = cse.diagnostic_category_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET no_ngyn_diagnosis = "T"
 ENDIF
 SET stat = alterlist(temp->diag_cat_qual,1)
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=1314
   AND cv.active_ind=1
  ORDER BY cv.cdf_meaning, cv.collation_seq
  HEAD REPORT
   dcnt = 0
  DETAIL
   dcnt += 1, stat = alterlist(temp->diag_cat_qual,dcnt), temp->diag_cat_qual[dcnt].category_cd = cv
   .code_value,
   temp->diag_cat_qual[dcnt].category_disp = cv.display, temp->diag_cat_qual[dcnt].cdf_meaning = cv
   .cdf_meaning, temp->diag_cat_qual[dcnt].rpt_cnt = 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE 2")
  GO TO exit_script
 ENDIF
 SET gyn_rpt_cnt = 0
 SET ngyn_rpt_cnt = 0
 SELECT INTO "nl:"
  cse1.screener_id, cse2.case_id, cse1.case_id,
  fte.followup_type_cd
  FROM (dummyt d  WITH seq = value(size(temp->screener_qual,5))),
   cyto_screening_event cse1,
   cyto_screening_event cse2,
   (dummyt d1  WITH seq = value(size(request->followup_qual,5))),
   ap_ft_event fte
  PLAN (d)
   JOIN (cse1
   WHERE (cse1.screener_id=temp->screener_qual[d.seq].prsnl_id)
    AND cse1.screen_dt_tm BETWEEN cnvtdatetime(request->start_dt) AND cnvtdatetime(request->end_dt)
    AND cse1.active_ind=1
    AND cse1.initial_screener_ind=1)
   JOIN (cse2
   WHERE cse1.case_id=cse2.case_id
    AND cse2.verify_ind=1
    AND cse2.active_ind=1)
   JOIN (d1)
   JOIN (fte
   WHERE cse2.case_id=fte.case_id
    AND (request->followup_qual[d1.seq].followup_type_cd=fte.followup_type_cd)
    AND fte.term_dt_tm = null)
  ORDER BY cse2.case_id, fte.followup_type_cd
  HEAD REPORT
   z = 0
  HEAD cse2.case_id
   FOR (z = 1 TO cnvtint(size(temp->diag_cat_qual,5)))
     IF ((cse2.diagnostic_category_cd=temp->diag_cat_qual[z].category_cd))
      temp->diag_cat_qual[z].rpt_cnt += 1
      IF ((temp->diag_cat_qual[z].cdf_meaning="GYN"))
       gyn_rpt_cnt += 1
      ENDIF
      IF ((temp->diag_cat_qual[z].cdf_meaning="NGYN"))
       ngyn_rpt_cnt += 1
      ENDIF
      z = cnvtint(size(temp->diag_cat_qual,5))
     ENDIF
   ENDFOR
  DETAIL
   FOR (z = 1 TO cnvtint(size(temp_followup->qual,5)))
     IF (fte.followup_event_id > 0
      AND (fte.followup_type_cd=temp_followup->qual[z].followup_type_cd))
      IF (cnvtdatetime(curdate,curtime) < fte.first_overdue_dt_tm)
       temp_followup->qual[z].followup_not_overdue += 1
      ENDIF
      IF (cnvtdatetime(curdate,curtime) >= fte.first_overdue_dt_tm)
       temp_followup->qual[z].followup_overdue += 1
      ENDIF
      z = cnvtint(size(temp_followup->qual,5))
     ENDIF
   ENDFOR
  WITH nocounter, outerjoin = d1
 ;end select
 IF ((request->separate_diagnosis="Y")
  AND no_ngyn_diagnosis="F")
  SET max_spec_cnt = 0
  SELECT INTO "nl:"
   diag_category = uar_get_code_display(temp->another_qual[d1.seq].diagnostic_category_cd), specimen
    = uar_get_code_display(temp->another_qual[d1.seq].specimen_cd)
   FROM (dummyt d1  WITH seq = value(size(temp->another_qual,5)))
   ORDER BY specimen, diag_category
   HEAD REPORT
    qual_cnt = 0
   DETAIL
    qual_cnt += 1, stat = alterlist(temp->sorted_another_qual,qual_cnt), temp->sorted_another_qual[
    qual_cnt].case_id = temp->another_qual[d1.seq].case_id,
    temp->sorted_another_qual[qual_cnt].diagnostic_category_cd = temp->another_qual[d1.seq].
    diagnostic_category_cd, temp->sorted_another_qual[qual_cnt].specimen_cd = temp->another_qual[d1
    .seq].specimen_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   specimen_cd = temp->sorted_another_qual[d1.seq].specimen_cd, specimen_disp = uar_get_code_display(
    temp->sorted_another_qual[d1.seq].specimen_cd), diagnostic_category_cd = temp->
   sorted_another_qual[d1.seq].diagnostic_category_cd,
   diagnostic_category_disp = uar_get_code_display(temp->sorted_another_qual[d1.seq].
    diagnostic_category_cd)
   FROM (dummyt d1  WITH seq = value(size(temp->sorted_another_qual,5)))
   ORDER BY specimen_disp, diagnostic_category_disp
   HEAD REPORT
    last_specimen_cd = 0.0, last_diagnosis_cd = 0, spec_cnt = 0,
    diag_cnt = 0
   HEAD specimen_disp
    IF ((temp->sorted_another_qual[d1.seq].specimen_cd != last_specimen_cd))
     last_specimen_cd = temp->sorted_another_qual[d1.seq].specimen_cd, spec_cnt += 1, stat =
     alterlist(temp->specimen_qual,spec_cnt),
     temp->specimen_qual[spec_cnt].specimen_cd = temp->sorted_another_qual[d1.seq].specimen_cd, temp
     ->specimen_qual[spec_cnt].specimen_disp = specimen_disp, last_diagnostic_category_cd = 0.0
     FOR (xx = 1 TO size(temp->diag_cat_qual,5))
       IF ((temp->diag_cat_qual[xx].cdf_meaning="NGYN"))
        diag_cnt += 1, stat = alterlist(temp->specimen_qual[spec_cnt].diagnosis,diag_cnt), temp->
        specimen_qual[spec_cnt].diagnosis[diag_cnt].diagnostic_category_cd = temp->diag_cat_qual[xx].
        category_cd,
        temp->specimen_qual[spec_cnt].diagnosis[diag_cnt].diagnostic_category_disp = temp->
        diag_cat_qual[xx].category_disp
       ENDIF
     ENDFOR
    ENDIF
    temp->specimen_qual[spec_cnt].tot_diag_cnt = 0
   HEAD diagnostic_category_disp
    diag_cnt = 0
    IF ((temp->sorted_another_qual[d1.seq].diagnostic_category_cd != last_diagnostic_category_cd))
     last_diagnostic_category_cd = temp->sorted_another_qual[d1.seq].diagnostic_category_cd
    ENDIF
    detail_cnt = 0
   DETAIL
    FOR (yy = 1 TO size(temp->specimen_qual[spec_cnt].diagnosis,5))
      IF ((temp->specimen_qual[spec_cnt].diagnosis[yy].diagnostic_category_cd=temp->
      sorted_another_qual[d1.seq].diagnostic_category_cd))
       temp->specimen_qual[spec_cnt].diagnosis[yy].diagnostic_cnt += 1, temp->specimen_qual[spec_cnt]
       .tot_diag_cnt += 1, yy = size(temp->diag_cat_qual,5)
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  cse.case_id, cse.screener_id, fte.term_reason_cd
  FROM (dummyt d1  WITH seq = value(size(request->followup_qual,5))),
   ap_ft_event fte,
   (dummyt d2  WITH seq = value(size(temp->screener_qual,5))),
   cyto_screening_event cse
  PLAN (d1)
   JOIN (fte
   WHERE fte.term_dt_tm BETWEEN cnvtdatetime(request->start_dt) AND cnvtdatetime(request->end_dt)
    AND (fte.followup_type_cd=request->followup_qual[d1.seq].followup_type_cd))
   JOIN (d2)
   JOIN (cse
   WHERE fte.case_id=cse.case_id
    AND cse.verify_ind=1
    AND (cse.screener_id=temp->screener_qual[d2.seq].prsnl_id))
  ORDER BY fte.followup_type_cd, fte.term_reason_cd
  HEAD REPORT
   term_reasons = 0, type_code = 0
  HEAD fte.followup_type_cd
   type_code += 1, stat = alterlist(temp_term->qual,type_code), temp_term->qual[type_code].
   followup_type_cd = fte.followup_type_cd,
   term_reasons = 0
  HEAD fte.term_reason_cd
   term_reasons += 1, stat = alterlist(temp_term->qual[type_code].term_qual,term_reasons), temp_term
   ->qual[type_code].term_qual[term_reasons].term_reason_cd = fte.term_reason_cd
   IF (fte.term_reason_cd > 0)
    temp_term->qual[type_code].term_qual[term_reasons].term_reason_description = substring(1,40,
     uar_get_code_description(fte.term_reason_cd))
   ENDIF
  DETAIL
   temp_term->qual[type_code].term_qual[term_reasons].term_cnt += 1
  WITH nocounter
 ;end select
 SET section = 0
 SET ncnt = 0
 SET grp_gyn_cases_is = 0
 SET grp_gyn_cases_rs = 0
 SET grp_gyn_slides_is = 0.0
 SET grp_gyn_slides_rs = 0.0
 SET grp_ngyn_cases_is = 0
 SET grp_ngyn_cases_rs = 0
 SET grp_ngyn_slides_is = 0.0
 SET grp_ngyn_slides_rs = 0.0
 SET grp_outside_gyn_is = 0.0
 SET grp_outside_gyn_rs = 0.0
 SET grp_outside_ngyn_is = 0.0
 SET grp_outside_ngyn_rs = 0.0
 SET grp_outside_all_is = 0.0
 SET grp_outside_all_rs = 0.0
 SET stat = alterlist(temp->section_qual,4)
 SELECT INTO "nl:"
  dcc.*
  FROM daily_cytology_counts dcc,
   (dummyt d  WITH seq = value(size(temp->screener_qual,5)))
  PLAN (d)
   JOIN (dcc
   WHERE (temp->screener_qual[d.seq].prsnl_id=dcc.prsnl_id)
    AND ((dcc.record_dt_tm BETWEEN cnvtdatetime(temp->d_start_dt) AND cnvtdatetime(temp->d_end_dt))
    OR (dcc.record_dt_tm BETWEEN cnvtdatetime(temp->d2_start_dt) AND cnvtdatetime(temp->d2_end_dt)))
   )
  DETAIL
   grp_gyn_cases_is += dcc.gyn_cases_is, grp_gyn_cases_rs += dcc.gyn_cases_rs, grp_gyn_slides_is +=
   dcc.gyn_slides_is,
   grp_gyn_slides_rs += dcc.gyn_slides_rs, grp_outside_gyn_is += dcc.outside_gyn_is,
   grp_outside_gyn_rs += dcc.outside_gyn_rs,
   grp_ngyn_slides_is += dcc.ngyn_slides_is, grp_ngyn_slides_rs += dcc.ngyn_slides_rs,
   grp_outside_ngyn_is += dcc.outside_ngyn_is,
   grp_outside_ngyn_rs += dcc.outside_ngyn_rs, grp_ngyn_cases_is += dcc.ngyn_cases_is,
   grp_ngyn_cases_rs += dcc.ngyn_cases_rs
  WITH nocounter
 ;end select
 SET no_cases_found = "F"
 IF ((temp->process_monthly_flag="Y"))
  SELECT INTO "nl:"
   mcc.*
   FROM monthly_cytology_counts mcc,
    (dummyt d  WITH seq = value(size(temp->screener_qual,5)))
   PLAN (d)
    JOIN (mcc
    WHERE (temp->screener_qual[d.seq].prsnl_id=mcc.prsnl_id)
     AND mcc.record_dt_tm BETWEEN cnvtdatetime(temp->m_start_dt) AND cnvtdatetime(temp->m_end_dt))
   DETAIL
    grp_gyn_cases_is += mcc.gyn_cases_is, grp_gyn_cases_rs += mcc.gyn_cases_rs, grp_gyn_slides_is +=
    mcc.gyn_slides_is,
    grp_gyn_slides_rs += mcc.gyn_slides_rs, grp_outside_gyn_is += mcc.outside_gyn_is,
    grp_outside_gyn_rs += mcc.outside_gyn_rs,
    grp_ngyn_slides_is += mcc.ngyn_slides_is, grp_ngyn_slides_rs += mcc.ngyn_slides_rs,
    grp_outside_ngyn_is += mcc.outside_ngyn_is,
    grp_outside_ngyn_rs += mcc.outside_ngyn_rs, grp_ngyn_cases_is += mcc.ngyn_cases_is,
    grp_ngyn_cases_rs += mcc.ngyn_cases_rs
   WITH nocounter
  ;end select
 ENDIF
 SET grp_gyn_cases_total = (grp_gyn_cases_is+ grp_gyn_cases_rs)
 SET grp_gyn_slides_total = (((grp_gyn_slides_is+ grp_gyn_slides_rs)+ grp_outside_gyn_is)+
 grp_outside_gyn_rs)
 SET grp_ngyn_slides_total = (((grp_ngyn_slides_is+ grp_ngyn_slides_rs)+ grp_outside_ngyn_is)+
 grp_outside_ngyn_rs)
 SET grp_ngyn_cases_total = (grp_ngyn_cases_is+ grp_ngyn_cases_rs)
 SET grp_all_cases_is = (grp_gyn_cases_is+ grp_ngyn_cases_is)
 SET grp_all_cases_rs = (grp_gyn_cases_rs+ grp_ngyn_cases_rs)
 SET grp_all_slide_is = (grp_gyn_slides_is+ grp_ngyn_slides_is)
 SET grp_all_slide_rs = (grp_gyn_slides_rs+ grp_ngyn_slides_rs)
 SET grp_outside_all_is = (grp_outside_gyn_is+ grp_outside_ngyn_is)
 SET grp_outside_all_rs = (grp_outside_gyn_rs+ grp_outside_ngyn_rs)
 SET grp_all_case_total = (grp_gyn_cases_total+ grp_ngyn_cases_total)
 SET grp_all_slides_total = (grp_gyn_slides_total+ grp_ngyn_slides_total)
 SET temp->section_qual[1].section = 1
 SET stat = alterlist(temp->section_qual[1].row_qual,3)
 SET ncnt = 1
 SET temp->section_qual[1].row_qual[ncnt].row_text = build(grp_gyn_cases_is,"|",grp_gyn_cases_rs,"|",
  grp_gyn_slides_is,
  "|",grp_gyn_slides_rs,"|",grp_outside_gyn_is,"|",
  grp_outside_gyn_rs,"|",grp_gyn_cases_total,"|",grp_gyn_slides_total,
  "|")
 SET ncnt += 1
 SET temp->section_qual[1].row_qual[ncnt].row_text = build(grp_ngyn_cases_is,"|",grp_ngyn_cases_rs,
  "|",grp_ngyn_slides_is,
  "|",grp_ngyn_slides_rs,"|",grp_outside_ngyn_is,"|",
  grp_outside_ngyn_rs,"|",grp_ngyn_cases_total,"|",grp_ngyn_slides_total,
  "|")
 SET ncnt += 1
 SET temp->section_qual[1].row_qual[ncnt].row_text = build(grp_all_cases_is,"|",grp_all_cases_rs,"|",
  grp_all_slide_is,
  "|",grp_all_slide_rs,"|",grp_outside_all_is,"|",
  grp_outside_all_rs,"|",grp_all_case_total,"|",grp_all_slides_total,
  "|")
 SET desccnt = 0.0
 SET descper = 0.0
 SET varicnt = 0.0
 SET variper = 0.0
 SELECT INTO "nl:"
  cse.nomenclature_id, cse2.nomenclature_id, cdd_nomenclature_x = cdd.nomenclature_x_id,
  cdd_nomenclature_y = cdd.nomenclature_y_id, cse.initial_screener_ind, cse2.initial_screener_ind,
  cse.*, cdd_internal_flag =
  IF (cdd.internal_flag=1) "VARIANCE"
  ELSEIF (cdd.internal_flag=2) "DISCREPANCY"
  ENDIF
  FROM cyto_screening_event cse,
   cyto_screening_event cse2,
   cyto_diag_discrepancy cdd,
   (dummyt d  WITH seq = value(size(temp->screener_qual,5)))
  PLAN (d)
   JOIN (cse
   WHERE (temp->screener_qual[d.seq].prsnl_id=cse.screener_id)
    AND cse.screen_dt_tm BETWEEN cnvtdatetime(request->start_dt) AND cnvtdatetime(request->end_dt)
    AND cse.initial_screener_ind=1
    AND cse.active_ind=1)
   JOIN (cse2
   WHERE cse.case_id=cse2.case_id
    AND cse2.verify_ind=1)
   JOIN (cdd
   WHERE cse.reference_range_factor_id=cdd.reference_range_factor_id
    AND cse.nomenclature_id=cdd.nomenclature_x_id
    AND cse2.nomenclature_id=cdd.nomenclature_y_id
    AND cdd.internal_flag > 0)
  DETAIL
   CASE (cdd.internal_flag)
    OF 1:
     varicnt += 1
    OF 2:
     desccnt += 1
   ENDCASE
  WITH counter, nullreport
 ;end select
 SET descper = ((desccnt/ grp_gyn_cases_total) * 100)
 SET variper = ((varicnt/ grp_gyn_cases_total) * 100)
 SET temp->section_qual[2].section = 2
 SET stat = alterlist(temp->section_qual[2].row_qual,2)
 SET temp->section_qual[2].row_qual[1].row_text = build(desccnt,"|",descper,"|")
 SET temp->section_qual[2].row_qual[2].row_text = build(varicnt,"|",variper,"|")
 SET section = 3
 SET temp->section_qual[section].section = section
 SET section = 4
 SET temp->section_qual[section].section = section
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(size(temp->diag_cat_qual,5)))
  HEAD REPORT
   gcnt = 0, ngcnt = 0
  DETAIL
   IF ((temp->diag_cat_qual[d.seq].cdf_meaning="GYN"))
    gcnt += 1, stat = alterlist(temp->section_qual[3].row_qual,gcnt), temp->section_qual[3].row_qual[
    gcnt].row_text = build(trim(temp->diag_cat_qual[d.seq].category_disp),"|",temp->diag_cat_qual[d
     .seq].rpt_cnt,"|",cnvtreal(((cnvtreal(temp->diag_cat_qual[d.seq].rpt_cnt)/ cnvtreal(gyn_rpt_cnt)
      ) * 100)),
     "|")
   ENDIF
   IF ((temp->diag_cat_qual[d.seq].cdf_meaning="NGYN"))
    ngcnt += 1, stat = alterlist(temp->section_qual[4].row_qual,ngcnt), temp->section_qual[4].
    row_qual[ngcnt].row_text = build(trim(temp->diag_cat_qual[d.seq].category_disp),"|",temp->
     diag_cat_qual[d.seq].rpt_cnt,"|",cnvtreal(((cnvtreal(temp->diag_cat_qual[d.seq].rpt_cnt)/
      cnvtreal(ngyn_rpt_cnt)) * 100)),
     "|")
   ENDIF
  FOOT REPORT
   gcnt += 1, stat = alterlist(temp->section_qual[3].row_qual,gcnt), temp->section_qual[3].row_qual[
   gcnt].row_text = build(gyn_rpt_cnt,"|"),
   ngcnt += 1, stat = alterlist(temp->section_qual[4].row_qual,ngcnt), temp->section_qual[4].
   row_qual[ngcnt].row_text = build(ngyn_rpt_cnt,"|")
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","DUMMYT 2")
  GO TO exit_script
 ENDIF
#report_maker
 EXECUTE cpm_create_file_name_logical "aps_stats_by_grp", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  HEAD REPORT
   line1 = fillstring(125,"-"), line2 = fillstring(131,"-"), term_reason_cnt = 0,
   term_rsn_cntr = 0, followup_type_cnt = 0, x = 0
  HEAD PAGE
   row + 1, col 0, captions->title,
   col 56,
   CALL center(captions->aprpt,row,132), col 110,
   captions->ddate, ":", col 117,
   cdate = format(curdate,"@SHORTDATE;;q"), cdate, row + 1,
   col 0, captions->dir, ":",
   col 110, captions->ttime, ":",
   col 117, curtime, row + 1,
   col 52,
   CALL center(captions->cytstats,row,132), col 112,
   captions->bby, ":", col 117,
   request->scuruser"##############", row + 1, col 110,
   captions->ppage, ":", col 117,
   curpage"###", row + 1, col 0,
   captions->group, ":", col 15,
   temp->run_group
   IF ((request->bshowinactives=1))
    row + 1, col 15, captions->inactincl
   ENDIF
   row + 1, col 0, captions->dtrange,
   ":", col 15, temp->run_date
  DETAIL
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   FOR (a = 1 TO cnvtint(size(temp->section_qual,5)))
     CASE (temp->section_qual[a].section)
      OF 1:
       row + 1,
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
       ,row + 1,col 0,line2,
       col 3," ",captions->summarycase,
       " ",row + 1,col 32,
       captions->numcases,col 56,captions->numinslides,
       col 80,captions->numoutslides,col 103,
       captions->numcases,col 114,captions->numslides,
       row + 1,col 4,captions->casetype,
       col 32,captions->scrn,col 56,
       captions->scrn,col 80,captions->scrn,
       col 103,captions->total,col 114,
       captions->total,row + 1,col 4,
       "------------------------",col 32,"-------------------",
       col 56,"-------------------",col 80,
       "-------------------",col 103,"-------",
       col 114,"-------",row + 1,
       col 4,captions->gyncyto,
       CALL get_text(1,temp->section_qual[1].row_qual[1].row_text,"|")col 32,real"#######",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[1].row_text,"|")col 41,real"#######",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[1].row_text,"|")col 56,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[1].row_text,"|")col 65,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[1].row_text,"|")col 80,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[1].row_text,"|")col 89,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[1].row_text,"|")col 103,real"#######",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[1].row_text,"|")col 114,real
       "#####.#;i;f",row + 1,col 4,captions->nongyncyto,
       CALL get_text(1,temp->section_qual[1].row_qual[2].row_text,"|")col 32,real"#######",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[2].row_text,"|")col 41,real"#######",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[2].row_text,"|")col 56,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[2].row_text,"|")col 65,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[2].row_text,"|")col 80,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[2].row_text,"|")col 89,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[2].row_text,"|")col 103,real"#######",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[2].row_text,"|")col 114,real
       "#####.#;i;f",row + 1,col 4,captions->allcyto,
       CALL get_text(1,temp->section_qual[1].row_qual[3].row_text,"|")col 32,real"#######",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[3].row_text,"|")col 41,real"#######",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[3].row_text,"|")col 56,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[3].row_text,"|")col 65,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[3].row_text,"|")col 80,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[3].row_text,"|")col 89,real
       "#####.#;i;f",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[3].row_text,"|")col 103,real"#######",
       CALL get_text(startpos2,temp->section_qual[1].row_qual[3].row_text,"|")col 114,real
       "#####.#;i;f",row + 2,col 0,line2,col 3," ",captions->nongynspec," ",row + 1,col 4,captions->
       source,col 47,captions->numspec,col 64,"%",row + 1,col 4,"------",col 47,"-----------",col 62,
       "------",
       IF (value(temp_spec->total) > 0)
        FOR (x = 1 TO value(size(temp_spec->qual,5)))
          IF (((row+ 10) > maxrow))
           BREAK, row + 2, col 4,
           captions->source, col 47, captions->numspec,
           col 64, "%", row + 1,
           col 4, "------", col 47,
           "-----------", col 62, "------",
           row + 1
          ENDIF
          row + 1, col 4, temp_spec->qual[x].cdf_description,
          col 49, temp_spec->qual[x].spec_cnt"#######", spec_perc = ((cnvtreal(temp_spec->qual[x].
           spec_cnt)/ cnvtreal(temp_spec->total)) * 100),
          col 62, spec_perc"###.##"
        ENDFOR
        row + 1, col 4, "--",
        captions->total, "--", col 45,
        temp_spec->total
       ELSE
        row + 1, col 4, captions->nospecfound
       ENDIF
      OF 2:
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
       ,row + 2,col 0,line2,
       col 4," ",captions->vardisstats,
       " ",row + 1,col 4,
       captions->category,col 16,captions->numcases,
       col 25,captions->percases,row + 1,
       col 4,"--------",col 16,
       "-------",col 25,"-------",
       row + 1,col 4,captions->discrep,
       CALL get_text(1,temp->section_qual[2].row_qual[1].row_text,"|")col 16,real"#####",
       CALL get_text(startpos2,temp->section_qual[2].row_qual[1].row_text,"|")col 25,real"###.##;i;f",
       col 32,"%",row + 1,
       col 4,captions->variance,
       CALL get_text(1,temp->section_qual[2].row_qual[2].row_text,"|")col 16,real"#####",
       CALL get_text(startpos2,temp->section_qual[2].row_qual[2].row_text,"|")col 25,real"###.##;i;f",
       col 32,"%"
      OF 3:
       row + 1,
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
       ,row + 1,col 0,line2,
       col 3," ",captions->diagsum,
       " ",row + 1,col 49,
       captions->rptveras,row + 1,col 4,
       captions->gyncytdiagcat,col 52,"#     ",
       captions->aand,"   %",row + 1,
       col 4,"--------------------------------",col 49,
       "--------",col 61,"-------",
       tcnt = cnvtint(size(temp->section_qual[3].row_qual,5)),
       FOR (ncnt = 1 TO (tcnt - 1))
         IF (((row+ 10) > maxrow))
          BREAK
         ENDIF
         row + 1,
         CALL get_text(1,temp->section_qual[3].row_qual[ncnt].row_text,"|"), col 4,
         text,
         CALL get_text(startpos2,temp->section_qual[3].row_qual[ncnt].row_text,"|"), col 49,
         real"########",
         CALL get_text(startpos2,temp->section_qual[3].row_qual[ncnt].row_text,"|"), col 62,
         real"###.##"
       ENDFOR
       ,row + 1,col 4,"--",
       captions->total,"--",
       CALL get_text(1,temp->section_qual[3].row_qual[tcnt].row_text,"|")col 49,real"########"
      OF 4:
       tcnt = cnvtint(size(temp->section_qual[4].row_qual,5)),
       IF ((((request->separate_diagnosis != "Y")) OR (no_ngyn_diagnosis="T")) )
        row + 1, row + 1
        IF (((row+ 10) > maxrow))
         BREAK, row + 1
        ENDIF
        col 49, captions->rptveras, row + 1,
        col 4, captions->nongyncytdiagcat, col 52,
        "#     ", captions->aand, "   %",
        row + 1, col 4, "-------------------------------------",
        col 49, "--------", col 61,
        "-------"
        FOR (ncnt = 1 TO (tcnt - 1))
          IF (((row+ 10) > maxrow))
           BREAK
          ENDIF
          row + 1,
          CALL get_text(1,temp->section_qual[4].row_qual[ncnt].row_text,"|"), col 4,
          text,
          CALL get_text(startpos2,temp->section_qual[4].row_qual[ncnt].row_text,"|"), col 49,
          real"########",
          CALL get_text(startpos2,temp->section_qual[4].row_qual[ncnt].row_text,"|"), col 62,
          real"###.##"
        ENDFOR
        row + 1, col 4, "--",
        captions->total, "--",
        CALL get_text(1,temp->section_qual[4].row_qual[tcnt].row_text,"|"),
        col 49, real"########"
       ELSE
        row + 1
        IF (((row+ 10) > maxrow))
         BREAK
        ENDIF
        row + 1, col 49, captions->rptveras,
        row + 1, col 4, captions->nongyncytdiagcat,
        col 52, "#     ", captions->aand,
        "   %", row + 1, col 4,
        "-------------------------------------", col 49, "--------",
        col 61, "-------", row + 1,
        col 4, captions->specimen, ": ",
        captions->allspec
        FOR (ncnt = 1 TO (tcnt - 1))
          IF (((row+ 10) > maxrow))
           BREAK
          ENDIF
          row + 1,
          CALL get_text(1,temp->section_qual[4].row_qual[ncnt].row_text,"|"), col 4,
          text,
          CALL get_text(startpos2,temp->section_qual[4].row_qual[ncnt].row_text,"|"), col 49,
          real"########",
          CALL get_text(startpos2,temp->section_qual[4].row_qual[ncnt].row_text,"|"), col 62,
          real"###.##"
        ENDFOR
        row + 1, col 4, "--",
        captions->total, "--",
        CALL get_text(1,temp->section_qual[4].row_qual[tcnt].row_text,"|"),
        col 49, real"########", row + 1,
        spec_cnt_size = value(size(temp->specimen_qual,5))
        FOR (spec_cnt = 1 TO spec_cnt_size)
          IF (((row+ 10) > maxrow))
           BREAK
          ENDIF
          row + 1, col 49, captions->rptveras,
          row + 1, col 4, captions->nongyncytdiagcat,
          col 52, "#     ", captions->aand,
          "   %", row + 1, col 4,
          "-------------------------------------", col 49, "--------",
          col 61, "-------", row + 1,
          col 4, captions->specimen, ": ",
          col 14, temp->specimen_qual[spec_cnt].specimen_disp, row + 1,
          tcnt = cnvtint(size(temp->specimen_qual[spec_cnt].diagnosis,5))
          FOR (ncnt = 1 TO tcnt)
            col 4, temp->specimen_qual[spec_cnt].diagnosis[ncnt].diagnostic_category_disp, col 49,
            temp->specimen_qual[spec_cnt].diagnosis[ncnt].diagnostic_cnt"########", col 62, perc_num
             = cnvtreal(((cnvtreal(temp->specimen_qual[spec_cnt].diagnosis[ncnt].diagnostic_cnt)/
             cnvtreal(temp->specimen_qual[spec_cnt].tot_diag_cnt)) * 100)),
            perc_num"###.##", row + 1
            IF (((row+ 10) > maxrow))
             BREAK, row + 1
            ENDIF
          ENDFOR
          col 4, "--", captions->total,
          "--", col 49, temp->specimen_qual[spec_cnt].tot_diag_cnt"########",
          row + 2
        ENDFOR
       ENDIF
     ENDCASE
   ENDFOR
   IF (no_cases_found="F")
    row + 2, col 0, line2,
    col 3, " ", captions->gyncytflwup,
    " "
   ELSE
    row + 8,
    CALL center(captions->nocases,0,132)
   ENDIF
   followup_qual_size = value(size(temp_followup->qual,5))
   IF (followup_qual_size > 0
    AND no_cases_found="F")
    FOR (loop = 1 TO followup_qual_size)
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
      row + 2, col 4, captions->followuptype,
      col 21, temp_followup->qual[loop].followup_type_short_name, row + 1,
      col 21, temp_followup->qual[loop].followup_type_desc, row + 2,
      col 21, captions->inprognoovrdue, col 86,
      temp_followup->qual[loop].followup_not_overdue"#######"
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
      row + 1, col 21, captions->inprogovrdue,
      col 86, temp_followup->qual[loop].followup_overdue"#######"
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
      row + 1, col 21, captions->flwupdiscont,
      array_size = value(size(temp_term->qual,5))
      IF (array_size > 0)
       term_reason_cnt = 0
       FOR (x = 1 TO array_size)
         IF ((temp_term->qual[x].followup_type_cd=temp_followup->qual[loop].followup_type_cd))
          term_reason_cnt += 1, num_of_term_reasons = size(temp_term->qual[x].term_qual,5)
          FOR (term_rsn_cntr = 1 TO num_of_term_reasons)
            row + 1, col 55, captions->wtermreason,
            col 80
            IF ((temp_term->qual[x].term_qual[term_rsn_cntr].term_reason_cd > 0))
             temp_term->qual[x].term_qual[term_rsn_cntr].term_reason_description
             "###################################"
            ELSE
             captions->autotermbysys
            ENDIF
            col 116, ":", col 118,
            temp_term->qual[x].term_qual[term_rsn_cntr].term_cnt"#######"
            IF (((row+ 10) > maxrow))
             BREAK
            ENDIF
          ENDFOR
         ENDIF
       ENDFOR
       IF (term_reason_cnt=0)
        col 92, "0"
       ENDIF
      ELSE
       row + 1, col 55, captions->notermdtrange
      ENDIF
    ENDFOR
   ENDIF
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->footer,
   today = concat(format(curdate,"@WEEKDAYABBREV;;d")," ",format(curdate,"@MEDIUMDATE4YR;;q")), col
   53, today,
   col 110, captions->ppage, ":",
   col 117, curpage"###", row + 1,
   col 55, captions->continued
  FOOT REPORT
   col 55, "##########     "
  WITH nocounter, nullreport, maxcol = 132,
   maxrow = 63, compress
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","ARRAY","REPORT MAKER")
  GO TO exit_script
 ENDIF
 GO TO exit_script
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
  SET reply->status_data.status = "S"
  IF (textlen(trim(request->output_dist)) > 0)
   SET spool value(reply->print_status_data.print_dir_and_filename) value(printer) WITH copy = value(
    copies)
   SET reply->ops_event = concat("Successful ",trim(reply->print_status_data.print_dir_and_filename))
  ENDIF
 ENDIF
#end_script
 FREE SET captions
 FREE SET temp
 FREE SET temp_spec
 FREE SET temp_term
 FREE SET temp_followup
END GO
