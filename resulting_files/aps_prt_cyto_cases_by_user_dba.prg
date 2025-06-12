CREATE PROGRAM aps_prt_cyto_cases_by_user:dba
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
 RECORD captions(
   1 ab = vc
   1 anua = vc
   1 allgynngyn = vc
   1 atyp = vc
   1 bby = vc
   1 ccase = vc
   1 casessel = vc
   1 contd = vc
   1 cytocasesbyuser = vc
   1 ddate = vc
   1 dir = vc
   1 evt = vc
   1 exclsec = vc
   1 exclqa = vc
   1 exclman = vc
   1 exclmax = vc
   1 exclnorequeue = vc
   1 inclcasetype = vc
   1 inclsec = vc
   1 inclqa = vc
   1 inclman = vc
   1 inclmax = vc
   1 inclnorequeue = vc
   1 inclpref = vc
   1 initscreener = vc
   1 initsrv = vc
   1 noqual = vc
   1 normal = vc
   1 ppage = vc
   1 pathnet = vc
   1 rptaps = vc
   1 rptcyto = vc
   1 rescreener = vc
   1 ttime = vc
   1 unsat = vc
   1 userdt = vc
   1 userresult = vc
   1 userrole = vc
   1 user = vc
   1 veras = vc
   1 verby = vc
   1 ver = vc
   1 lookfwd = vc
   1 lookbk = vc
   1 cases = vc
   1 reportend = vc
 )
 SET captions->ab = uar_i18ngetmessage(i18nhandle,"ab","ABNORMAL")
 SET captions->anua = uar_i18ngetmessage(i18nhandle,"anua","ABNORMAL, NORMAL, UNSAT, ATYPICAL")
 SET captions->allgynngyn = uar_i18ngetmessage(i18nhandle,"allgynngyn","ALL GYN AND NGYN PREFIXES")
 SET captions->atyp = uar_i18ngetmessage(i18nhandle,"atyp","ATYPICAL")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->ccase = uar_i18ngetmessage(i18nhandle,"ccase","CASE")
 SET captions->casessel = uar_i18ngetmessage(i18nhandle,"casessel","CASES SELECTED BY")
 SET captions->contd = uar_i18ngetmessage(i18nhandle,"contd","CONTINUED...")
 SET captions->cytocasesbyuser = uar_i18ngetmessage(i18nhandle,"cytocasebyuser",
  "CYTOLOGY CASES BY USER")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->evt = uar_i18ngetmessage(i18nhandle,"evt","EVENT")
 SET captions->exclsec = uar_i18ngetmessage(i18nhandle,"exclsec",
  "EXCLUDE CASES AUTOMATICALLY SELECTED DUE TO INSUFFICIENT VERIFICATION SECURITY")
 SET captions->exclqa = uar_i18ngetmessage(i18nhandle,"exclqa",
  "EXCLUDE CASES AUTOMATICALLY SELECTED DUE TO QA % REQUIREMENTS")
 SET captions->exclman = uar_i18ngetmessage(i18nhandle,"exclman",
  "EXCLUDE CASES MANUALLY SELECTED FOR REVIEW")
 SET captions->exclmax = uar_i18ngetmessage(i18nhandle,"exclmax",
  "EXCLUDE CASES REQUEUED DUE TO EXCEEDING MAXIMUM DAILY SLIDE COUNT")
 SET captions->exclnorequeue = uar_i18ngetmessage(i18nhandle,"exclnorequeue",
  "EXCLUDE CASES NOT SELECTED FOR REQUEUE")
 SET captions->inclcasetype = uar_i18ngetmessage(i18nhandle,"inclcasetype","INCLUDE CASE TYPE")
 SET captions->inclsec = uar_i18ngetmessage(i18nhandle,"inclsec",
  "INCLUDE CASES AUTOMATICALLY SELECTED DUE TO INSUFFICIENT VERIFICATION SECURITY")
 SET captions->inclqa = uar_i18ngetmessage(i18nhandle,"inclqa",
  "INCLUDE CASES AUTOMATICALLY SELECTED DUE TO QA % REQUIREMENTS")
 SET captions->inclman = uar_i18ngetmessage(i18nhandle,"inclman",
  "INCLUDE CASES MANUALLY SELECTED FOR REVIEW")
 SET captions->inclmax = uar_i18ngetmessage(i18nhandle,"inclmax",
  "INCLUDE CASES REQUEUED DUE TO EXCEEDING MAXIMUM DAILY SLIDE COUNT")
 SET captions->inclnorequeue = uar_i18ngetmessage(i18nhandle,"inclnorequeue",
  "INCLUDE CASES NOT SELECTED FOR REQUEUE")
 SET captions->inclpref = uar_i18ngetmessage(i18nhandle,"inclpref","INCLUDE PREFIXES")
 SET captions->initscreener = uar_i18ngetmessage(i18nhandle,"initscreener","INITIAL SCREENER")
 SET captions->initsrv = uar_i18ngetmessage(i18nhandle,"initsrv",
  "INITIAL SCREENER, RESCREENER, OR VERIFIER")
 SET captions->noqual = uar_i18ngetmessage(i18nhandle,"noqual","No cases qualified for this user.")
 SET captions->normal = uar_i18ngetmessage(i18nhandle,"normal","NORMAL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"pathnet","PATHNET ANATOMIC PATHOLOGY")
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_CYTO_CASES_BY_USER.PRG")
 SET captions->rptcyto = uar_i18ngetmessage(i18nhandle,"rptcyto","REPORT: CYTO CASES BY USER")
 SET captions->rescreener = uar_i18ngetmessage(i18nhandle,"rescreener","RESCREENER")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->unsat = uar_i18ngetmessage(i18nhandle,"unsat","UNSAT")
 SET captions->userdt = uar_i18ngetmessage(i18nhandle,"userdt","USER DATE")
 SET captions->userresult = uar_i18ngetmessage(i18nhandle,"userresult","USER RESULTED AS")
 SET captions->userrole = uar_i18ngetmessage(i18nhandle,"userrole","USER ROLE")
 SET captions->user = uar_i18ngetmessage(i18nhandle,"user","USER")
 SET captions->veras = uar_i18ngetmessage(i18nhandle,"veras","VERIFIED AS")
 SET captions->verby = uar_i18ngetmessage(i18nhandle,"verby","VERIFIED BY")
 SET captions->ver = uar_i18ngetmessage(i18nhandle,"ver","VERIFIER")
 SET captions->lookfwd = uar_i18ngetmessage(i18nhandle,"lookfwd","look forward")
 SET captions->lookbk = uar_i18ngetmessage(i18nhandle,"lookbk","look back")
 SET captions->cases = uar_i18ngetmessage(i18nhandle,"cases","cases")
 SET captions->reportend = uar_i18ngetmessage(i18nhandle,"reportend","END OF REPORT")
 RECORD primary(
   1 new_prefix_cnt = i4
   1 screener_name = c50
   1 qual[*]
     2 case_id = f8
     2 accession_nbr = c21
     2 sequence = i4
     2 verify_dt_tm = dq8
     2 user_role = c1
 )
 RECORD secondary(
   1 max_users = i4
   1 qual[*]
     2 meets_requeue_info = c1
     2 meets_case_type = c1
     2 case_id = f8
     2 accession_nbr = c21
     2 verify_dt_tm = dq8
     2 verified_as_cd = f8
     2 verified_as_disp = c24
     2 verified_by_id = f8
     2 verified_by_name = c26
     2 user_qual[*]
       3 user_id = f8
       3 user_role = c1
       3 flag_type_cd = f8
       3 review_reason_flag = i2
       3 resulted_as_cd = f8
       3 resulted_as_disp = c24
       3 resulted_by_id = f8
       3 verify_ind = i2
 )
 RECORD temp_pref(
   1 pref_qual[1]
     2 prefix_id = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_display = vc
     2 site_prefix = vc
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
 SET reply->status_data.status = "F"
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
    stat = alter(temp_pref->pref_qual,value(size(request->prefix_qual,5))), pref_cntr = 0
   HEAD site_prefix
    pref_cntr += 1, temp_pref->pref_qual[pref_cntr].prefix_id = ap.prefix_id, temp_pref->pref_qual[
    pref_cntr].prefix_name = ap.prefix_name,
    temp_pref->pref_qual[pref_cntr].site_cd = ap.site_cd, temp_pref->pref_qual[pref_cntr].
    site_display = cv.display, primary->new_prefix_cnt = pref_cntr
   FOOT REPORT
    stat = alter(temp_pref->pref_qual,pref_cntr)
   WITH nocounter
  ;end select
 ELSE
  SET gyn_cd = 0.0
  SET ngyn_cd = 0.0
  CALL initresourcesecurity(1)
  SELECT INTO "nl:"
   cv.*
   FROM code_value cv
   WHERE cv.code_set=1301
    AND cv.cdf_meaning IN ("NGYN", "GYN")
   DETAIL
    IF (cv.cdf_meaning="GYN")
     gyn_cd = cv.code_value
    ENDIF
    IF (cv.cdf_meaning="NGYN")
     ngyn_cd = cv.code_value
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cv_display = cv.display"#####", site_prefix = build(substring(1,5,cv.display),ap.prefix_name), ap
   .prefix_name,
   ap.prefix_id, ap.site_cd
   FROM ap_prefix ap,
    code_value cv
   PLAN (ap
    WHERE ap.case_type_cd IN (gyn_cd, ngyn_cd))
    JOIN (cv
    WHERE ap.site_cd=cv.code_value)
   ORDER BY site_prefix
   HEAD REPORT
    pref_cntr = 0, service_resource_cd = 0.0
   DETAIL
    IF (ap.prefix_id != 0.0)
     service_resource_cd = ap.service_resource_cd
     IF (isresourceviewable(service_resource_cd)=true)
      pref_cntr += 1, stat = alter(temp_pref->pref_qual,pref_cntr), temp_pref->pref_qual[pref_cntr].
      prefix_id = ap.prefix_id,
      temp_pref->pref_qual[pref_cntr].prefix_name = ap.prefix_name, temp_pref->pref_qual[pref_cntr].
      site_cd = ap.site_cd, temp_pref->pref_qual[pref_cntr].site_display = cv.display,
      primary->new_prefix_cnt = pref_cntr
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (getresourcesecuritystatus(0)="F")
   SET reply->status_data.status = getresourcesecuritystatus(0)
   CALL populateressecstatusblock(1)
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE pc_select_string = vc
 IF ((request->prefix_cnt > 0))
  SET pc_select_string = " pc.prefix_id in ("
  FOR (x = 1 TO (request->prefix_cnt - 1))
    SET pc_select_string = concat(trim(pc_select_string)," ",cnvtstring(request->prefix_qual[x].
      prefix_id,32,2),",")
  ENDFOR
  SET pc_select_string = concat(trim(pc_select_string)," ",cnvtstring(request->prefix_qual[x].
    prefix_id,32,2),")")
 ELSE
  SET pc_select_string = " pc.prefix_id in ("
  FOR (x = 1 TO (primary->new_prefix_cnt - 1))
    SET pc_select_string = concat(trim(pc_select_string)," ",cnvtstring(temp_pref->pref_qual[x].
      prefix_id,32,2),",")
  ENDFOR
  SET pc_select_string = concat(trim(pc_select_string)," ",cnvtstring(temp_pref->pref_qual[x].
    prefix_id,32,2),")")
 ENDIF
 IF ((request->date_type="D"))
  CALL change_times(request->beg_dt_tm,request->end_dt_tm)
  SET request->end_dt_tm = dtemp->end_of_day
  SET request->beg_dt_tm = dtemp->beg_of_day
  SET pc_select_string = concat(trim(pc_select_string),
   " and pc.main_report_cmplete_dt_tm between cnvtdatetime(request->beg_dt_tm) and cnvtdatetime(request->end_dt_tm)"
   )
 ELSEIF ((request->date_type="E"))
  CALL change_times(request->event_dt_tm,cnvtdatetime(sysdate))
  IF ((request->lookforward="T"))
   SET request->event_dt_tm = dtemp->beg_of_day
   SET pc_select_string = concat(trim(pc_select_string),
    " and pc.main_report_cmplete_dt_tm >= cnvtdatetime(request->event_dt_tm) ")
  ELSE
   SET request->event_dt_tm = dtemp->end_of_day
   SET pc_select_string = concat(trim(pc_select_string),
    " and pc.main_report_cmplete_dt_tm <= cnvtdatetime(request->event_dt_tm) ")
  ENDIF
 ENDIF
 SET user_role_string = fillstring(2000," ")
 SET case_requeue_string = fillstring(2000," ")
 SET user_role_string = " cse.screener_id = request->user_id and pc.case_id = cse.case_id"
 IF ((request->events=1))
  SET user_role_string = concat(trim(user_role_string)," and cse.initial_screener_ind = 1")
 ELSEIF ((request->events=2))
  SET user_role_string = concat(trim(user_role_string)," and cse.verify_ind = 1")
 ENDIF
 SET case_requeue_string = " secondary->qual[d1.seq].user_qual[d2.seq].review_reason_flag in (  "
 SET one_exists = "F"
 IF ((request->qa_req_sel=1))
  SET case_requeue_string = concat(trim(case_requeue_string)," 2,3,4,5,6")
  SET one_exists = "T"
 ENDIF
 IF ((request->exceed_sel=1))
  IF (one_exists="T")
   SET case_requeue_string = concat(trim(case_requeue_string),",1")
  ELSE
   SET case_requeue_string = concat(trim(case_requeue_string)," 1")
   SET one_exists = "T"
  ENDIF
 ENDIF
 IF ((request->insuf_security_sel=1))
  IF (one_exists="T")
   SET case_requeue_string = concat(trim(case_requeue_string),",7")
  ELSE
   SET case_requeue_string = concat(trim(case_requeue_string)," 7")
   SET one_exists = "T"
  ENDIF
 ENDIF
 IF ((request->manually_sel=1))
  IF (one_exists="T")
   SET case_requeue_string = concat(trim(case_requeue_string),",8")
  ELSE
   SET case_requeue_string = concat(trim(case_requeue_string)," 8")
   SET one_exists = "T"
  ENDIF
 ENDIF
 IF ((request->norequeue_sel=1))
  IF (one_exists="T")
   SET case_requeue_string = concat(trim(case_requeue_string),",0")
  ELSE
   SET case_requeue_string = concat(trim(case_requeue_string)," 0")
   SET one_exists = "T"
  ENDIF
 ENDIF
 SET case_requeue_string = concat(trim(case_requeue_string)," )")
 SET abnormal_cd = 0.0
 SET normal_cd = 0.0
 SET atypical_cd = 0.0
 SET unsat_cd = 0.0
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=1316
  DETAIL
   IF (cv.cdf_meaning="NORMAL")
    normal_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="ABNORMAL")
    abnormal_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="ATYPICAL")
    atypical_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="UNSAT")
    unsat_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET case_type_string = fillstring(2000," ")
 IF ((request->case_type_cnt > 0))
  SET case_type_string = " secondary->qual[d1.seq].user_qual[d2.seq].flag_type_cd in ("
  FOR (x = 1 TO (request->case_type_cnt - 1))
    SET case_type_string = concat(trim(case_type_string)," ",cnvtstring(request->case_type_qual[x].
      case_type_cd,32,2),",")
  ENDFOR
  SET case_type_string = concat(trim(case_type_string)," ",cnvtstring(request->case_type_qual[x].
    case_type_cd,32,2),")")
 ELSE
  SET case_type_string = " secondary->qual[d1.seq].user_qual[d2.seq].flag_type_cd in ("
  SET case_type_string = concat(trim(case_type_string),cnvtstring(abnormal_cd,32,2),",",cnvtstring(
    normal_cd,32,2),",",
   cnvtstring(atypical_cd,32,2),",",cnvtstring(unsat_cd,32,2))
  SET case_type_string = concat(trim(case_type_string)," )")
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM prsnl p
  WHERE (p.person_id=request->user_id)
  DETAIL
   primary->screener_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pc.accession_nbr, cse.active_ind, cse.*
  FROM cyto_screening_event cse,
   pathology_case pc
  PLAN (pc
   WHERE parser(pc_select_string))
   JOIN (cse
   WHERE parser(user_role_string)
    AND cse.active_ind=1)
  ORDER BY cse.screen_dt_tm, pc.accession_nbr
  HEAD REPORT
   nbr = 0
  DETAIL
   nbr += 1
   IF ((request->date_type="E"))
    IF ((nbr <= request->volume))
     stat = alterlist(primary->qual,nbr), primary->qual[nbr].case_id = pc.case_id, primary->qual[nbr]
     .accession_nbr = pc.accession_nbr,
     primary->qual[nbr].sequence = cse.sequence, primary->qual[nbr].verify_dt_tm = pc
     .main_report_cmplete_dt_tm
     IF (cse.verify_ind=1)
      primary->qual[nbr].user_role = "V"
     ELSEIF (cse.initial_screener_ind=1)
      primary->qual[nbr].user_role = "I"
     ELSE
      primary->qual[nbr].user_role = "R"
     ENDIF
    ENDIF
   ELSE
    stat = alterlist(primary->qual,nbr), primary->qual[nbr].case_id = pc.case_id, primary->qual[nbr].
    accession_nbr = pc.accession_nbr,
    primary->qual[nbr].sequence = cse.sequence, primary->qual[nbr].verify_dt_tm = pc
    .main_report_cmplete_dt_tm
    IF (cse.verify_ind=1)
     primary->qual[nbr].user_role = "V"
    ELSEIF (cse.initial_screener_ind=1)
     primary->qual[nbr].user_role = "I"
    ELSE
     primary->qual[nbr].user_role = "R"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO report_maker
 ENDIF
 SELECT INTO "nl:"
  accession_nbr = primary->qual[d1.seq].accession_nbr, sequence = cse.sequence, verified_as_disp =
  uar_get_code_display(cse.diagnostic_category_cd),
  resulted_as_disp = uar_get_code_display(cse.diagnostic_category_cd), verify_dt_tm = primary->qual[
  d1.seq].verify_dt_tm
  FROM cyto_screening_event cse,
   (dummyt d1  WITH seq = value(size(primary->qual,5))),
   ap_qa_info aqi
  PLAN (d1
   WHERE (primary->qual[d1.seq].case_id > 0))
   JOIN (cse
   WHERE (primary->qual[d1.seq].case_id=cse.case_id)
    AND cse.active_ind=1)
   JOIN (aqi
   WHERE cse.case_id=aqi.case_id)
  ORDER BY accession_nbr, sequence
  HEAD REPORT
   x = 0, sec_cnt = 0, user_cnt = 0
  HEAD accession_nbr
   sec_cnt += 1, stat = alterlist(secondary->qual,sec_cnt), secondary->qual[sec_cnt].case_id = cse
   .case_id,
   secondary->qual[sec_cnt].accession_nbr = accession_nbr, secondary->qual[sec_cnt].verify_dt_tm =
   verify_dt_tm, secondary->qual[sec_cnt].meets_requeue_info = "F",
   secondary->qual[sec_cnt].meets_case_type = "F", user_cnt = 0
  HEAD sequence
   user_cnt += 1
   IF ((user_cnt > secondary->max_users))
    secondary->max_users = user_cnt
   ENDIF
   stat = alterlist(secondary->qual[sec_cnt].user_qual,user_cnt), secondary->qual[sec_cnt].user_qual[
   user_cnt].user_id = cse.screener_id
   IF (cse.verify_ind=1)
    secondary->qual[sec_cnt].user_qual[user_cnt].user_role = "V"
   ELSEIF (cse.initial_screener_ind=1)
    secondary->qual[sec_cnt].user_qual[user_cnt].user_role = "I"
   ELSE
    secondary->qual[sec_cnt].user_qual[user_cnt].user_role = "R"
   ENDIF
   secondary->qual[sec_cnt].user_qual[user_cnt].flag_type_cd = aqi.flag_type_cd, secondary->qual[
   sec_cnt].user_qual[user_cnt].review_reason_flag = cse.review_reason_flag, secondary->qual[sec_cnt]
   .user_qual[user_cnt].verify_ind = cse.verify_ind
   IF (cse.verify_ind=1)
    secondary->qual[sec_cnt].verified_as_cd = cse.diagnostic_category_cd, secondary->qual[sec_cnt].
    verified_as_disp = verified_as_disp, secondary->qual[sec_cnt].verified_by_id = cse.screener_id,
    secondary->qual[sec_cnt].user_qual[user_cnt].resulted_as_cd = cse.diagnostic_category_cd,
    secondary->qual[sec_cnt].user_qual[user_cnt].resulted_as_disp = resulted_as_disp, secondary->
    qual[sec_cnt].user_qual[user_cnt].resulted_by_id = cse.screener_id
   ELSE
    secondary->qual[sec_cnt].user_qual[user_cnt].resulted_as_cd = cse.diagnostic_category_cd,
    secondary->qual[sec_cnt].user_qual[user_cnt].resulted_as_disp = resulted_as_disp, secondary->
    qual[sec_cnt].user_qual[user_cnt].resulted_by_id = cse.screener_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  accession_nbr = secondary->qual[d1.seq].accession_nbr
  FROM (dummyt d1  WITH seq = value(size(secondary->qual,5))),
   (dummyt d2  WITH seq = value(secondary->max_users))
  PLAN (d1
   WHERE (secondary->qual[d1.seq].case_id > 0))
   JOIN (d2
   WHERE d2.seq <= size(secondary->qual[d1.seq].user_qual,5)
    AND (secondary->qual[d1.seq].user_qual[d2.seq].verify_ind > 0)
    AND parser(case_type_string))
  DETAIL
   secondary->qual[d1.seq].meets_case_type = "T"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  accession_nbr = secondary->qual[d1.seq].accession_nbr
  FROM (dummyt d1  WITH seq = value(size(secondary->qual,5))),
   (dummyt d2  WITH seq = value(secondary->max_users))
  PLAN (d1
   WHERE (secondary->qual[d1.seq].case_id > 0))
   JOIN (d2
   WHERE d2.seq <= size(secondary->qual[d1.seq].user_qual,5)
    AND (secondary->qual[d1.seq].user_qual[d2.seq].user_id=request->user_id)
    AND parser(case_requeue_string))
  DETAIL
   secondary->qual[d1.seq].meets_requeue_info = "T"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  accession_nbr = secondary->qual[d1.seq].accession_nbr, p.name_full_formatted
  FROM (dummyt d1  WITH seq = value(size(secondary->qual,5))),
   (dummyt d2  WITH seq = value(secondary->max_users)),
   prsnl p
  PLAN (d1
   WHERE (secondary->qual[d1.seq].case_id > 0))
   JOIN (d2
   WHERE d2.seq <= size(secondary->qual[d1.seq].user_qual,5))
   JOIN (p
   WHERE (secondary->qual[d1.seq].user_qual[d2.seq].user_id=p.person_id))
  DETAIL
   IF ((secondary->qual[d1.seq].user_qual[d2.seq].verify_ind > 0))
    secondary->qual[d1.seq].verified_by_name = p.name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "aps_case_by_user", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SET pathologist_name = fillstring(80," ")
 DECLARE uar_fmt_accession(p1,p2) = c25
 SELECT INTO value(reply->print_status_data.print_filename)
  secondary->qual[d1.seq].accession_nbr, meets_case_type = secondary->qual[d1.seq].meets_case_type,
  meeets_requeue_info = secondary->qual[d1.seq].meets_requeue_info,
  request->volume
  FROM (dummyt d1  WITH seq = value(size(secondary->qual,5))),
   (dummyt d2  WITH seq = value(secondary->max_users))
  PLAN (d1
   WHERE (secondary->qual[d1.seq].case_id > 0)
    AND (secondary->qual[d1.seq].meets_requeue_info="T")
    AND (secondary->qual[d1.seq].meets_case_type="T"))
   JOIN (d2
   WHERE d2.seq <= size(secondary->qual[d1.seq].user_qual,5)
    AND (secondary->qual[d1.seq].user_qual[d2.seq].user_id=request->user_id))
  ORDER BY format(cnvtdatetime(secondary->qual[d1.seq].verify_dt_tm),"@SHORTDATE;;q"), secondary->
   qual[d1.seq].accession_nbr
  HEAD REPORT
   line1 = fillstring(125,"-"), 20stars = fillstring(20,"*"), bfirstpage = "Y",
   bfirsttimethru = "Y", cases_printed = 0
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   CALL center(captions->pathnet,0,132), col 110, captions->ddate,
   ":", cdate = format(curdate,"@SHORTDATE;;q"), col 117,
   cdate, row + 1, col 0,
   captions->dir, ":", col 110,
   captions->ttime, ":", col 117,
   curtime, row + 1,
   CALL center(captions->cytocasesbyuser,0,132),
   col 112, captions->bby, ":",
   col 117, request->scuruser"##############", row + 1,
   col 110, captions->ppage, ":",
   col 117, curpage"###"
   IF (curpage=1)
    row + 2, col 0, captions->user,
    ": ", col 7, primary->screener_name,
    row + 1, col 0, captions->casessel,
    ":", col 20
    IF ((request->date_type="D"))
     captions->ddate, temp1 = format(request->beg_dt_tm,"@SHORTDATE;;q"), temp2 = format(request->
      end_dt_tm,"@SHORTDATE;;q"),
     row + 1, col 20, temp1,
     " - ", temp2
    ELSE
     captions->evt
     IF ((request->lookforward="T"))
      temp1 = format(request->event_dt_tm,"@SHORTDATE;;q"), row + 1, col 20,
      temp1, ", ", captions->lookfwd,
      " ", request->volume, col + 1,
      captions->cases, "."
     ELSE
      temp1 = format(request->event_dt_tm,"@SHORTDATE;;q"), row + 1, col 20,
      temp1, ", ", captions->lookbk,
      " ", request->volume, col + 1,
      captions->cases, "."
     ENDIF
    ENDIF
    row + 1, col 0, captions->userrole,
    ": ", col 11
    IF ((request->events=1))
     captions->initscreener
    ELSEIF ((request->events=2))
     captions->ver
    ELSEIF ((request->events=3))
     captions->initsrv
    ENDIF
    row + 1, col 0, captions->inclpref,
    ": ", col 20
    IF ((request->prefix_cnt=0))
     captions->allgynngyn
    ELSE
     FOR (x = 1 TO primary->new_prefix_cnt)
       temp_pref->pref_qual[x].site_display, temp_pref->pref_qual[x].prefix_name
       IF ((x < primary->new_prefix_cnt))
        ", "
       ENDIF
       col + 1
       IF (col > 120)
        row + 1, col 20
       ENDIF
     ENDFOR
    ENDIF
    row + 1, col 0, captions->inclcasetype,
    ": ", one_exists = "F", col 20
    IF ((request->case_type_cnt=0))
     captions->anua
    ELSE
     FOR (x = 1 TO request->case_type_cnt)
       IF ((request->case_type_qual[x].case_type_cd=abnormal_cd))
        IF (one_exists="T")
         ", ", captions->ab
        ELSE
         captions->ab
        ENDIF
        one_exists = "T"
       ENDIF
       IF ((request->case_type_qual[x].case_type_cd=normal_cd))
        IF (one_exists="T")
         ", ", captions->normal
        ELSE
         captions->normal
        ENDIF
        one_exists = "T"
       ENDIF
       IF ((request->case_type_qual[x].case_type_cd=unsat_cd))
        IF (one_exists="T")
         ", ", captions->unsat
        ELSE
         captions->unsat
        ENDIF
        one_exists = "T"
       ENDIF
       IF ((request->case_type_qual[x].case_type_cd=atypical_cd))
        IF (one_exists="T")
         ", ", captions->atyp
        ELSE
         captions->atyp
        ENDIF
        one_exists = "T"
       ENDIF
     ENDFOR
    ENDIF
    IF ((request->exceed_sel=1))
     row + 1, col 0, captions->inclmax
    ELSE
     row + 1, col 0, captions->exclmax
    ENDIF
    IF ((request->qa_req_sel=1))
     row + 1, col 0, captions->inclqa
    ELSE
     row + 1, col 0, captions->exclqa
    ENDIF
    IF ((request->insuf_security_sel=1))
     row + 1, col 0, captions->inclsec
    ELSE
     row + 1, col 0, captions->exclsec
    ENDIF
    IF ((request->manually_sel=1))
     row + 1, col 0, captions->inclman
    ELSE
     row + 1, col 0, captions->exclman
    ENDIF
    IF ((request->norequeue_sel=1))
     row + 1, col 0, captions->inclnorequeue
    ELSE
     row + 1, col 0, captions->exclnorequeue
    ENDIF
   ENDIF
   row + 1, row + 1, col 0,
   captions->ccase, col 21, captions->userdt,
   col 32, captions->userrole, col 50,
   captions->userresult, col 77, captions->veras,
   col 104, captions->verby, row + 1,
   col 0, "-------------------", col 21,
   "---------", col 32, "----------------",
   col 50, "-------------------------", col 77,
   "-------------------------", col 104, "---------------------------"
   IF (value(size(secondary->qual,5))=0)
    row + 2,
    CALL center(captions->noqual,0,132), cases_printed = 1
   ENDIF
  DETAIL
   cases_printed += 1
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   accession_nbr = uar_fmt_accession(secondary->qual[d1.seq].accession_nbr,size(trim(secondary->qual[
      d1.seq].accession_nbr),1)), row + 1, col 0,
   accession_nbr, temp1 = format(secondary->qual[d1.seq].verify_dt_tm,"@SHORTDATE;;q"), col 21,
   temp1, col 32
   IF ((secondary->qual[d1.seq].user_qual[d2.seq].user_role="I"))
    captions->initscreener
   ELSEIF ((secondary->qual[d1.seq].user_qual[d2.seq].user_role="V"))
    captions->ver
   ELSEIF ((secondary->qual[d1.seq].user_qual[d2.seq].user_role="R"))
    captions->rescreener
   ENDIF
   col 50, secondary->qual[d1.seq].user_qual[d2.seq].resulted_as_disp, col 77,
   secondary->qual[d1.seq].verified_as_disp, col 104, secondary->qual[d1.seq].verified_by_name
  FOOT PAGE
   IF (cases_printed=0)
    row + 2,
    CALL center(captions->noqual,0,132)
   ENDIF
   row 60, col 0, line1,
   row + 1, col 0, captions->rptcyto,
   today = concat(format(curdate,"@WEEKDAYABBREV;;d")," ",format(curdate,"@SHORTDATE;;q")), col 53,
   today,
   col 110, captions->ppage, ":",
   col 117, curpage"###", row + 1,
   col 53, captions->contd
  FOOT REPORT
   col 53, captions->reportend
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
