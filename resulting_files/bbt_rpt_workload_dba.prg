CREATE PROGRAM bbt_rpt_workload:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 blood_bank_owner = vc
   1 inventory_area = vc
   1 begin_date = vc
   1 ending_date = vc
   1 orderable_detail = vc
   1 totals = vc
   1 cell = vc
   1 action = vc
   1 priority = vc
   1 paren_p = vc
   1 paren_a = vc
   1 paren_c = vc
   1 paren_od_a = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 end_of_report = vc
   1 all = vc
   1 summary_by = vc
   1 personnel = vc
   1 orderable_activity = vc
   1 cell_header = vc
   1 action_header = vc
   1 priority_header = vc
   1 user = vc
   1 unknown = vc
   1 total = vc
 )
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "B L O O D   B A N K   W O R K L O A D   R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->blood_bank_owner = uar_i18ngetmessage(i18nhandle,"blood_bank_owner",
  "Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->begin_date = uar_i18ngetmessage(i18nhandle,"begin_date","Beginning Date:")
 SET captions->ending_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->orderable_detail = uar_i18ngetmessage(i18nhandle,"orderable_detail",
  "Orderable - Detail / Activity (OD/A)")
 SET captions->totals = uar_i18ngetmessage(i18nhandle,"totals","Totals")
 SET captions->cell = uar_i18ngetmessage(i18nhandle,"cell","Cell (C)")
 SET captions->action = uar_i18ngetmessage(i18nhandle,"action","Action (A)")
 SET captions->priority = uar_i18ngetmessage(i18nhandle,"priority","Priority (P)")
 SET captions->paren_p = uar_i18ngetmessage(i18nhandle,"paren_p","(P)")
 SET captions->paren_a = uar_i18ngetmessage(i18nhandle,"paren_a","(A)")
 SET captions->paren_c = uar_i18ngetmessage(i18nhandle,"paren_c","(C)")
 SET captions->paren_od_a = uar_i18ngetmessage(i18nhandle,"paren_od_a","(OD/A)")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBT_RPT_WORKLOAD")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->summary_by = uar_i18ngetmessage(i18nhandle,"summary_by","Summary by:")
 SET captions->personnel = uar_i18ngetmessage(i18nhandle,"personnel","Personnel,")
 SET captions->orderable_activity = uar_i18ngetmessage(i18nhandle,"orderable_activity",
  "Orderable/Activity")
 SET captions->cell_header = uar_i18ngetmessage(i18nhandle,"cell_header",", Cell")
 SET captions->action_header = uar_i18ngetmessage(i18nhandle,"action_header",", Action")
 SET captions->priority_header = uar_i18ngetmessage(i18nhandle,"priority_header",", Priority")
 SET captions->user = uar_i18ngetmessage(i18nhandle,"user","User:")
 SET captions->unknown = uar_i18ngetmessage(i18nhandle,"unknown","Unknown   ")
 SET captions->total = uar_i18ngetmessage(i18nhandle,"total","(Total ")
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
 RECORD testsites(
   1 qual[*]
     2 service_resource_cd = f8
     2 service_resource_disp = c40
 )
 DECLARE const_serv_res_section_cdf = c12 WITH protect, constant("SECTION")
 DECLARE const_serv_res_subsection_cdf = c12 WITH protect, constant("SUBSECTION")
 DECLARE const_serv_res_bench_cdf = c12 WITH protect, constant("BENCH")
 DECLARE const_serv_res_instrument_cdf = c12 WITH protect, constant("INSTRUMENT")
 DECLARE const_serv_res_type_cs = i4 WITH protect, constant(223)
 DECLARE const_return_security_ok = i2 WITH protect, constant(1)
 DECLARE const_return_no_security = i2 WITH protect, constant(0)
 DECLARE const_return_invalid = i2 WITH protect, constant(- (1))
 DECLARE const_security_on = i2 WITH protect, constant(1)
 DECLARE const_security_off = i2 WITH protect, constant(0)
 DECLARE dservressectioncd = f8 WITH protect, noconstant(0.0)
 DECLARE dservressubsectioncd = f8 WITH protect, noconstant(0.0)
 DECLARE nstat = i4 WITH protect, noconstant(0)
 SUBROUTINE (initservresroutine(nservressecind=i2) =i2)
   SET nstat = uar_get_meaning_by_codeset(const_serv_res_type_cs,const_serv_res_section_cdf,1,
    dservressectioncd)
   IF (dservressectioncd=0.0)
    RETURN(const_return_invalid)
   ENDIF
   SET nstat = uar_get_meaning_by_codeset(const_serv_res_type_cs,const_serv_res_subsection_cdf,1,
    dservressubsectioncd)
   IF (dservressubsectioncd=0.0)
    RETURN(const_return_invalid)
   ENDIF
   CALL initresourcesecurity(nservressecind)
   RETURN(const_return_security_ok)
 END ;Subroutine
 SUBROUTINE (determineservresaccess(dserviceresourcecd=f8) =i2)
   DECLARE sservrescdfmeaning = vc WITH protect, noconstant("")
   DECLARE iservreslevelflag = i2 WITH protect, noconstant(- (1))
   DECLARE itestsitecnt = i2 WITH protect, noconstant(0)
   DECLARE dcurservres = f8 WITH protect, noconstant(0.0)
   DECLARE ierrorcd = i4 WITH protect, noconstant(0)
   DECLARE serrormsg = vc WITH protect, noconstant("")
   IF (dserviceresourcecd=0.0)
    SET iservreslevelflag = 3
   ELSE
    SET sservrescdfmeaning = uar_get_code_meaning(dserviceresourcecd)
    IF (trim(sservrescdfmeaning) IN (const_serv_res_bench_cdf, const_serv_res_instrument_cdf))
     IF (isresourceviewable(dserviceresourcecd)=true)
      SET itestsitecnt = 1
      SET nstat = alterlist(testsites->qual,itestsitecnt)
      SET testsites->qual[itestsitecnt].service_resource_cd = dserviceresourcecd
      SET testsites->qual[itestsitecnt].service_resource_disp = uar_get_code_display(
       dserviceresourcecd)
      RETURN(const_return_security_ok)
     ELSE
      RETURN(const_return_no_security)
     ENDIF
    ELSEIF (trim(sservrescdfmeaning)=const_serv_res_subsection_cdf)
     SET iservreslevelflag = 1
    ELSEIF (trim(sservrescdfmeaning)=const_serv_res_section_cdf)
     SET iservreslevelflag = 2
    ELSE
     RETURN(const_return_invalid)
    ENDIF
   ENDIF
   IF (iservreslevelflag=1)
    SELECT INTO "nl:"
     subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     FROM resource_group subsect
     WHERE subsect.parent_service_resource_cd=dserviceresourcecd
      AND subsect.resource_group_type_cd=dservressubsectioncd
      AND ((subsect.root_service_resource_cd+ 0)=0.0)
     ORDER BY subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     HEAD REPORT
      itestsitecnt = 0, dcurservres = 0.0
     HEAD subsect.parent_service_resource_cd
      dcurservres = subsect.parent_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     HEAD subsect.child_service_resource_cd
      dcurservres = subsect.child_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     FOOT REPORT
      nstat = alterlist(testsites->qual,itestsitecnt)
     WITH nocounter
    ;end select
   ELSEIF (iservreslevelflag=2)
    SELECT INTO "nl:"
     sect.parent_service_resource_cd, subsect.parent_service_resource_cd, subsect
     .child_service_resource_cd
     FROM resource_group sect,
      resource_group subsect
     PLAN (sect
      WHERE sect.resource_group_type_cd=dservressectioncd
       AND sect.parent_service_resource_cd=dserviceresourcecd
       AND ((sect.root_service_resource_cd+ 0)=0.0))
      JOIN (subsect
      WHERE subsect.parent_service_resource_cd=sect.child_service_resource_cd
       AND subsect.resource_group_type_cd=dservressubsectioncd
       AND ((subsect.root_service_resource_cd+ 0)=0.0))
     ORDER BY subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     HEAD REPORT
      itestsitecnt = 0, dcurservres = 0.0
     HEAD subsect.parent_service_resource_cd
      dcurservres = subsect.parent_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     HEAD subsect.child_service_resource_cd
      dcurservres = subsect.child_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     FOOT REPORT
      nstat = alterlist(testsites->qual,itestsitecnt)
     WITH nocounter
    ;end select
   ELSEIF (iservreslevelflag=3)
    SELECT INTO "nl:"
     sect.parent_service_resource_cd, subsect.parent_service_resource_cd, subsect
     .child_service_resource_cd
     FROM resource_group sect,
      resource_group subsect
     PLAN (sect
      WHERE sect.resource_group_type_cd=dservressectioncd
       AND sect.root_service_resource_cd=0.0)
      JOIN (subsect
      WHERE subsect.parent_service_resource_cd=sect.child_service_resource_cd
       AND subsect.resource_group_type_cd=dservressubsectioncd
       AND ((subsect.root_service_resource_cd+ 0)=0.0))
     ORDER BY subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     HEAD REPORT
      itestsitecnt = 0, dcurservres = 0.0
     HEAD subsect.parent_service_resource_cd
      dcurservres = subsect.parent_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     HEAD subsect.child_service_resource_cd
      dcurservres = subsect.child_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     FOOT REPORT
      nstat = alterlist(testsites->qual,itestsitecnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (size(testsites->qual,5) > 0)
    RETURN(const_return_security_ok)
   ELSE
    RETURN(const_return_no_security)
   ENDIF
 END ;Subroutine
 DECLARE nsecurityind = i2 WITH project, noconstant(const_security_on)
 DECLARE nreturnstat = i2 WITH protect, noconstant(const_return_invalid)
 DECLARE ntestsitecnt = i4 WITH protect, noconstant(0)
 RECORD workload_rec(
   1 workload[*]
     2 personnel_id = f8
     2 product_event_ind = i2
     2 activity_event_cd = f8
     2 task_assay_cd = f8
     2 interp_cd = f8
     2 bb_order_cell_cd = f8
     2 report_priority_cd = f8
     2 status = c2
     2 report_ind = i2
     2 workload_sort
       3 personnel_id = f8
       3 bb_order_cell_cd = f8
       3 status_sort = i2
       3 report_priority_cd = f8
 )
 RECORD ops_params(
   1 qual[*]
     2 param = c100
 )
 SET nsecurityind = const_security_on
 IF (size(trim(request->batch_selection),1) > 0)
  SET nsecurityind = const_security_off
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_workload")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL check_owner_cd("bbt_rpt_workload")
  CALL check_inventory_cd("bbt_rpt_workload")
  CALL check_location_cd("bbt_rpt_workload")
  CALL check_svc_opt("bbt_rpt_workload")
  SET stat = alterlist(request->parameter_list,1)
  SET request->parameter_list[1].personnel_break_ind = 0
  SET request->parameter_list[1].cell_break_ind = 0
  SET request->parameter_list[1].action_break_ind = 0
  SET request->parameter_list[1].priority_break_ind = 0
 ENDIF
 SUBROUTINE check_opt_date_passed(script_name)
   SET ddmmyy_flag = 0
   SET dd_flag = 0
   SET mm_flag = 0
   SET yy_flag = 0
   SET dayentered = 0
   SET monthentered = 0
   SET yearentered = 0
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("DAY[",temp_string)))
   IF (temp_pos > 0)
    SET day_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET day_pos = cnvtint(value(findstring("]",day_string)))
    IF (day_pos > 0)
     SET day_nbr = substring(1,(day_pos - 1),day_string)
     IF (trim(day_nbr) > " ")
      SET ddmmyy_flag += 1
      SET dd_flag = 1
      SET dayentered = cnvtreal(day_nbr)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY value"
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY value"
    ENDIF
   ENDIF
   IF ((reply->status_data.status != "F"))
    SET temp_pos = 0
    SET temp_pos = cnvtint(value(findstring("MONTH[",temp_string)))
    IF (temp_pos > 0)
     SET month_string = substring((temp_pos+ 6),size(temp_string),temp_string)
     SET month_pos = cnvtint(value(findstring("]",month_string)))
     IF (month_pos > 0)
      SET month_nbr = substring(1,(month_pos - 1),month_string)
      IF (trim(month_nbr) > " ")
       SET ddmmyy_flag += 1
       SET mm_flag = 1
       SET monthentered = cnvtreal(month_nbr)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse MONTH value"
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse MONTH value"
     ENDIF
    ENDIF
   ENDIF
   IF ((reply->status_data.status != "F"))
    SET temp_pos = 0
    SET temp_pos = cnvtint(value(findstring("YEAR[",temp_string)))
    IF (temp_pos > 0)
     SET year_string = substring((temp_pos+ 5),size(temp_string),temp_string)
     SET year_pos = cnvtint(value(findstring("]",year_string)))
     IF (year_pos > 0)
      SET year_nbr = substring(1,(year_pos - 1),year_string)
      IF (trim(year_nbr) > " ")
       SET ddmmyy_flag += 1
       SET yy_flag = 1
       SET yearentered = cnvtreal(year_nbr)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse YEAR value"
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse YEAR value"
     ENDIF
    ENDIF
   ENDIF
   IF (ddmmyy_flag > 1)
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY or MONTH or YEAR value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "multi date selection"
    GO TO exit_script
   ENDIF
   IF ((reply->status_data.status="F"))
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
    GO TO exit_script
   ENDIF
   IF (dd_flag=1)
    IF (dayentered > 0)
     SET interval = build(abs(dayentered),"d")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET begday = cnvtlookahead(interval,request->ops_date)
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),235959)
     SET endday = cnvtlookahead(interval,request->ops_date)
    ELSE
     SET interval = build(abs(dayentered),"d")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET begday = cnvtlookbehind(interval,request->ops_date)
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),235959)
     SET endday = cnvtlookbehind(interval,request->ops_date)
    ENDIF
   ELSEIF (mm_flag=1)
    IF (monthentered > 0)
     SET interval = build(abs(monthentered),"m")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = cnvtstring(month(request->ops_date))
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookahead(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1m",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ELSE
     SET interval = build(abs(monthentered),"m")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = cnvtstring(month(request->ops_date))
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookbehind(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1m",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ENDIF
   ELSEIF (yy_flag=1)
    IF (yearentered > 0)
     SET interval = build(abs(yearentered),"y")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = "01"
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookahead(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1y",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ELSE
     SET interval = build(abs(yearentered),"y")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = "01"
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookbehind(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1y",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY or MONTH or YEAR value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO date selection"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_bb_organization(script_name)
   DECLARE norgpos = i2 WITH protect, noconstant(0)
   DECLARE ntemppos = i2 WITH protect, noconstant(0)
   DECLARE ncodeset = i4 WITH protect, constant(278)
   DECLARE sorgname = vc WITH protect, noconstant(fillstring(132,""))
   DECLARE sorgstring = vc WITH protect, noconstant(fillstring(132,""))
   DECLARE dbbmanufcd = f8 WITH protect, noconstant(0.0)
   DECLARE dbbsupplcd = f8 WITH protect, noconstant(0.0)
   DECLARE dbbclientcd = f8 WITH protect, noconstant(0.0)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBMANUF",1,dbbmanufcd)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBSUPPL",1,dbbsupplcd)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBCLIENT",1,dbbclientcd)
   SET ntemppos = cnvtint(value(findstring("ORG[",temp_string)))
   IF (ntemppos > 0)
    SET sorgstring = substring((ntemppos+ 4),size(temp_string),temp_string)
    SET norgpos = cnvtint(value(findstring("]",sorgstring)))
    IF (norgpos > 0)
     SET sorgname = substring(1,(norgpos - 1),sorgstring)
     IF (trim(sorgname) > " ")
      SELECT INTO "nl:"
       FROM org_type_reltn ot,
        organization o
       PLAN (ot
        WHERE ot.org_type_cd IN (dbbmanufcd, dbbsupplcd, dbbclientcd)
         AND ot.active_ind=1)
        JOIN (o
        WHERE o.org_name_key=trim(cnvtupper(sorgname))
         AND o.active_ind=1)
       DETAIL
        request->organization_id = o.organization_id
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ELSE
    SET request->organization_id = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_owner_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("OWN[",temp_string)))
   IF (temp_pos > 0)
    SET own_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET own_pos = cnvtint(value(findstring("]",own_string)))
    IF (own_pos > 0)
     SET own_area = substring(1,(own_pos - 1),own_string)
     IF (trim(own_area) > " ")
      SET request->cur_owner_area_cd = cnvtreal(own_area)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse owner area code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse owner area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->cur_owner_area_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_inventory_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("INV[",temp_string)))
   IF (temp_pos > 0)
    SET inv_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET inv_pos = cnvtint(value(findstring("]",inv_string)))
    IF (inv_pos > 0)
     SET inv_area = substring(1,(inv_pos - 1),inv_string)
     IF (trim(inv_area) > " ")
      SET request->cur_inv_area_cd = cnvtreal(inv_area)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse inventory area code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse inventory area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->cur_inv_area_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_location_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("LOC[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET location_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(location_cd) > " ")
      SET request->address_location_cd = cnvtreal(location_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse location code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse location code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->address_location_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_sort_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("SORT[",temp_string)))
   IF (temp_pos > 0)
    SET sort_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET sort_pos = cnvtint(value(findstring("]",sort_string)))
    IF (sort_pos > 0)
     SET sort_selection = substring(1,(sort_pos - 1),sort_string)
    ELSE
     SET sort_selection = " "
    ENDIF
   ELSE
    SET sort_selection = " "
   ENDIF
 END ;Subroutine
 SUBROUTINE check_mode_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("MODE[",temp_string)))
   IF (temp_pos > 0)
    SET mode_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET mode_pos = cnvtint(value(findstring("]",mode_string)))
    IF (mode_pos > 0)
     SET mode_selection = substring(1,(mode_pos - 1),mode_string)
    ELSE
     SET mode_selection = " "
    ENDIF
   ELSE
    SET mode_selection = " "
   ENDIF
 END ;Subroutine
 SUBROUTINE check_rangeofdays_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("RANGEOFDAYS[",temp_string)))
   IF (temp_pos > 0)
    SET next_string = substring((temp_pos+ 12),size(temp_string),temp_string)
    SET next_pos = cnvtint(value(findstring("]",next_string)))
    SET days_look_ahead = cnvtint(trim(substring(1,(next_pos - 1),next_string)))
    IF (days_look_ahead > 0)
     SET days_look_ahead = days_look_ahead
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse look ahead days"
     GO TO exit_script
    ENDIF
   ELSE
    SET days_look_ahead = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_hrs_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("HRS[",temp_string)))
   IF (temp_pos > 0)
    SET hrs_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET hrs_pos = cnvtint(value(findstring("]",hrs_string)))
    IF (hrs_pos > 0)
     SET num_hrs = substring(1,(hrs_pos - 1),hrs_string)
     IF (trim(num_hrs) > " ")
      IF (cnvtint(trim(num_hrs)) > 0)
       SET hoursentered = cnvtreal(num_hrs)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = script_name
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
       GO TO exit_script
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
     GO TO exit_script
    ENDIF
   ELSE
    SET hoursentered = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_svc_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("SVC[",temp_string)))
   IF (temp_pos > 0)
    SET svc_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET svc_pos = cnvtint(value(findstring("]",svc_string)))
    SET parm_string = fillstring(100," ")
    SET parm_string = substring(1,(svc_pos - 1),svc_string)
    SET ptr = 1
    SET back_ptr = 1
    SET param_idx = 1
    SET nbr_of_services = size(trim(parm_string))
    SET flag_exit_loop = 0
    FOR (param_idx = 1 TO nbr_of_services)
      SET ptr = findstring(",",parm_string,back_ptr)
      IF (ptr=0)
       SET ptr = (nbr_of_services+ 1)
       SET flag_exit_loop = 1
      ENDIF
      SET parm_len = (ptr - back_ptr)
      SET stat = alterlist(ops_params->qual,param_idx)
      SET ops_params->qual[param_idx].param = trim(substring(back_ptr,value(parm_len),parm_string),3)
      SET back_ptr = (ptr+ 1)
      SET stat = alterlist(request->qual,param_idx)
      SET request->qual[param_idx].service_resource_cd = cnvtreal(ops_params->qual[param_idx].param)
      IF (flag_exit_loop=1)
       SET param_idx = nbr_of_services
      ENDIF
    ENDFOR
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse service resource"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_donation_location(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("DLOC[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET location_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(location_cd) > " ")
      SET request->donation_location_cd = cnvtreal(trim(location_cd))
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse donation location"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse donation location"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->donation_location_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_null_report(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("NULLRPT[",temp_string)))
   IF (temp_pos > 0)
    SET null_string = substring((temp_pos+ 8),size(temp_string),temp_string)
    SET null_pos = cnvtint(value(findstring("]",null_string)))
    IF (null_pos > 0)
     SET null_selection = substring(1,(null_pos - 1),null_string)
     IF (trim(null_selection)="Y")
      SET request->null_ind = 1
     ELSE
      SET request->null_ind = 0
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse null report indicator"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_outcome_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("OUTCOME[",temp_string)))
   IF (temp_pos > 0)
    SET outcome_string = substring((temp_pos+ 8),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",outcome_string)))
    IF (loc_pos > 0)
     SET outcome_cd = substring(1,(loc_pos - 1),outcome_string)
     IF (trim(outcome_cd) > " ")
      SET request->outcome_cd = cnvtreal(outcome_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse outcome code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse outcome code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->outcome_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE (check_facility_cd(script_name=vc) =null)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("FACILITY[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 9),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET facility_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(facility_cd) > " ")
      SET request->facility_cd = cnvtreal(facility_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no facility code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse facility code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no facility code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse facility code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->facility_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE (check_exception_type_cd(script_name=vc) =null)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("EXCEPT[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 7),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET exception_type_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(exception_type_cd) > " ")
      IF (trim(exception_type_cd)="ALL")
       SET request->exception_type_cd = 0.0
      ELSE
       SET request->exception_type_cd = cnvtreal(exception_type_cd)
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "no exception type code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse exception type code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "no exception type code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse exception type code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->exception_type_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_misc_functionality(param_name)
   SET temp_pos = 0
   SET status_param = ""
   SET temp_str = concat(param_name,"[")
   SET temp_pos = cnvtint(value(findstring(temp_str,temp_string)))
   IF (temp_pos > 0)
    SET status_string = substring((temp_pos+ textlen(temp_str)),size(temp_string),temp_string)
    SET status_pos = cnvtint(value(findstring("]",status_string)))
    IF (status_pos > 0)
     SET status_param = substring(1,(status_pos - 1),status_string)
     IF (trim(status_param) > " ")
      SET ops_param_status = cnvtint(status_param)
     ENDIF
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 IF (initservresroutine(nsecurityind)=const_return_invalid)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_workload"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "InitServResRoutine()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Status Returned."
  GO TO exit_script
 ENDIF
 SET nreturnstat = determineservresaccess(request->qual[1].service_resource_cd)
 IF (nreturnstat=const_return_invalid)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_workload"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DetermineServResAccess()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Service Resource"
  GO TO exit_script
 ELSEIF (nreturnstat=const_return_no_security)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_workload"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DetermineServResAccess()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "No security access for specified Service Resource"
  GO TO exit_script
 ENDIF
 SET select_ok_ind = 1
 SET sub_get_location_name = fillstring(25," ")
 SET sub_get_location_address1 = fillstring(100," ")
 SET sub_get_location_address2 = fillstring(100," ")
 SET sub_get_location_address3 = fillstring(100," ")
 SET sub_get_location_address4 = fillstring(100," ")
 SET sub_get_location_citystatezip = fillstring(100," ")
 SET sub_get_location_country = fillstring(100," ")
 IF ((request->address_location_cd != 0))
  SET addr_type_cd = 0.0
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",code_cnt,addr_type_cd)
  IF (addr_type_cd=0.0)
   SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
  ELSE
   SELECT INTO "nl:"
    a.street_addr, a.street_addr2, a.street_addr3,
    a.street_addr4, a.city, a.state,
    a.zipcode, a.country, l.location_cd
    FROM address a
    WHERE a.active_ind=1
     AND a.address_type_cd=addr_type_cd
     AND a.parent_entity_name="LOCATION"
     AND (a.parent_entity_id=request->address_location_cd)
    DETAIL
     sub_get_location_name = uar_get_code_display(request->address_location_cd),
     sub_get_location_address1 = a.street_addr, sub_get_location_address2 = a.street_addr2,
     sub_get_location_address3 = a.street_addr3, sub_get_location_address4 = a.street_addr4,
     sub_get_location_citystatezip = concat(trim(a.city),", ",trim(a.state),"  ",trim(a.zipcode)),
     sub_get_location_country = a.country
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
   ENDIF
  ENDIF
 ELSE
  SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
 ENDIF
 DECLARE workload_cnt = i4
 DECLARE order_start_cnt = i4
 DECLARE personnel_id_hold = f8
 DECLARE personnel_cnt = i2
 DECLARE bb_code = f8
 DECLARE bb_product_code = f8
 DECLARE bbdonor_code = f8
 DECLARE bbdonorprod_code = f8
 DECLARE autologous_code = f8
 DECLARE directed_code = f8
 DECLARE dispensed_code = f8
 DECLARE disposed_code = f8
 DECLARE modified_code = f8
 DECLARE pooled_product_code = f8
 DECLARE received_code = f8
 DECLARE transfused_code = f8
 DECLARE verified_code = f8 WITH protect, noconstant(0.0)
 DECLARE old_verified_code = f8 WITH protect, noconstant(0.0)
 DECLARE performed_code = f8 WITH protect, noconstant(0.0)
 DECLARE old_performed_code = f8 WITH protect, noconstant(0.0)
 DECLARE corrected_code = f8 WITH protect, noconstant(0.0)
 DECLARE old_corrected_code = f8 WITH protect, noconstant(0.0)
 DECLARE inreview_code = f8 WITH protect, noconstant(0.0)
 DECLARE old_inreveiw_code = f8 WITH protect, noconstant(0.0)
 DECLARE corr_inreview_code = f8 WITH protect, noconstant(0.0)
 DECLARE old_corr_inreview_code = f8 WITH protect, noconstant(0.0)
 SET owner_area_disp = fillstring(40," ")
 SET inv_area_disp = fillstring(40," ")
 IF ((request->cur_owner_area_cd > 0.0))
  SET owner_area_disp = uar_get_code_display(request->cur_owner_area_cd)
 ELSE
  SET owner_area_disp = captions->all
 ENDIF
 IF ((request->cur_inv_area_cd > 0.0))
  SET inv_area_disp = uar_get_code_display(request->cur_inv_area_cd)
 ELSE
  SET inv_area_disp = captions->all
 ENDIF
 DECLARE code_set_106 = i4 WITH protect, noconstant(106)
 DECLARE code_set_1901 = i4 WITH protect, noconstant(1901)
 DECLARE code_set_1610 = i4 WITH protect, noconstant(1610)
 DECLARE cdfmean = vc WITH protect, noconstant("MEANING")
 SET bb_code = uar_get_code_by(cdfmean,code_set_106,"BB")
 SET bb_product_code = uar_get_code_by(cdfmean,code_set_106,"BB PRODUCT")
 SET bbdonor_code = uar_get_code_by(cdfmean,code_set_106,"BBDONOR")
 SET bbdonorprod_code = uar_get_code_by(cdfmean,code_set_106,"BBDONORPROD")
 IF (((bb_code <= 0) OR (((bb_product_code <= 0) OR (((bbdonor_code <= 0) OR (bbdonorprod_code <= 0
 )) )) )) )
  SET select_ok_ind = 0
 ENDIF
 IF (select_ok_ind=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_workload"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "failed for select of code set 106"
  GO TO exit_script
 ENDIF
 SET verified_code = uar_get_code_by(cdfmean,code_set_1901,"VERIFIED")
 SET old_verified_code = uar_get_code_by(cdfmean,code_set_1901,"OLDVERIFIED")
 SET performed_code = uar_get_code_by(cdfmean,code_set_1901,"PERFORMED")
 SET old_performed_code = uar_get_code_by(cdfmean,code_set_1901,"OLDPERFORMED")
 SET corrected_code = uar_get_code_by(cdfmean,code_set_1901,"CORRECTED")
 SET old_corrected_code = uar_get_code_by(cdfmean,code_set_1901,"OLDCORRECTED")
 SET inreview_code = uar_get_code_by(cdfmean,code_set_1901,"INREVIEW")
 SET old_inreveiw_code = uar_get_code_by(cdfmean,code_set_1901,"OLDINREVIEW")
 SET corr_inreview_code = uar_get_code_by(cdfmean,code_set_1901,"CORRINREV")
 SET old_corr_inreview_code = uar_get_code_by(cdfmean,code_set_1901,"OLDCORRINREV")
 IF (((verified_code <= 0) OR (((old_verified_code <= 0) OR (((performed_code <= 0) OR (((
 old_performed_code <= 0) OR (((corrected_code <= 0) OR (((old_corrected_code <= 0) OR (((
 inreview_code <= 0) OR (((old_inreveiw_code <= 0) OR (((corr_inreview_code <= 0) OR (
 old_corr_inreview_code <= 0)) )) )) )) )) )) )) )) )) )
  SET select_ok_ind = 0
 ENDIF
 IF (select_ok_ind=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_workload"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "failed for select of code set 1901"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  product_cell = decode(boc.seq,boc.product_id,r.bb_control_cell_cd), order_lab_ind = decode(ol.seq,1,
   0), bb_result_processing_mean = uar_get_code_meaning(dta.bb_result_processing_cd)
  FROM result_event re,
   perform_result pr,
   result r,
   discrete_task_assay dta,
   orders o,
   product p,
   (dummyt d_ol  WITH seq = 1),
   order_laboratory ol,
   (dummyt d_boc  WITH seq = 1),
   bb_order_cell boc,
   profile_task_r ptr
  PLAN (re
   WHERE re.event_dt_tm >= cnvtdatetime(request->beg_dt_tm)
    AND re.event_dt_tm <= cnvtdatetime(request->end_dt_tm))
   JOIN (r
   WHERE r.result_id=re.result_id)
   JOIN (o
   WHERE o.order_id=r.order_id
    AND o.activity_type_cd IN (bb_code, bb_product_code, bbdonor_code, bbdonorprod_code))
   JOIN (p
   WHERE p.product_id=o.product_id
    AND ((o.product_id=0.0) OR ((((request->cur_owner_area_cd > 0.0)
    AND ((p.cur_owner_area_cd+ 0)=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)
   ))
    AND (((request->cur_inv_area_cd > 0.0)
    AND ((p.cur_inv_area_cd+ 0)=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )) )
   JOIN (ptr
   WHERE ptr.catalog_cd=o.catalog_cd
    AND ptr.task_assay_cd=r.task_assay_cd
    AND ptr.item_type_flag != 1
    AND ptr.active_ind=1)
   JOIN (pr
   WHERE pr.perform_result_id=re.perform_result_id
    AND pr.result_id=re.result_id
    AND expand(ntestsitecnt,1,size(testsites->qual,5),pr.service_resource_cd,testsites->qual[
    ntestsitecnt].service_resource_cd))
   JOIN (dta
   WHERE dta.task_assay_cd=r.task_assay_cd)
   JOIN (d_ol
   WHERE d_ol.seq=1)
   JOIN (ol
   WHERE ol.order_id=o.order_id)
   JOIN (d_boc
   WHERE d_boc.seq=1)
   JOIN (boc
   WHERE boc.order_id=o.order_id
    AND boc.product_id > 0.0
    AND boc.product_id != null
    AND boc.bb_result_id=r.bb_result_id
    AND boc.bb_result_id > 0.0
    AND boc.bb_result_id != null)
  ORDER BY o.order_id, product_cell, r.result_id,
   pr.perform_result_id, re.event_sequence
  HEAD REPORT
   select_ok_ind = 0, workload_cnt = 0, stat = alterlist(workload_rec->workload,10)
  HEAD o.order_id
   select_ok_ind = select_ok_ind
  HEAD product_cell
   order_start_cnt = (workload_cnt+ 1), report_all_ind = 1
  HEAD pr.perform_result_id
   personnel_id_hold = 0, personnel_cnt = 0
  HEAD re.event_sequence
   IF (re.seq > 0)
    IF (re.event_personnel_id != personnel_id_hold)
     workload_cnt += 1
     IF (workload_cnt > size(workload_rec->workload,5))
      stat = alterlist(workload_rec->workload,(workload_cnt+ 9))
     ENDIF
     personnel_cnt += 1, personnel_id_hold = re.event_personnel_id, workload_rec->workload[
     workload_cnt].personnel_id = re.event_personnel_id,
     workload_rec->workload[workload_cnt].activity_event_cd = o.catalog_cd, workload_rec->workload[
     workload_cnt].task_assay_cd = r.task_assay_cd, workload_rec->workload[workload_cnt].interp_cd =
     dta.bb_result_processing_cd
     IF (order_lab_ind=1)
      workload_rec->workload[workload_cnt].report_priority_cd = ol.report_priority_cd
     ELSE
      workload_rec->workload[workload_cnt].report_priority_cd = 0
     ENDIF
     workload_rec->workload[workload_cnt].bb_order_cell_cd = product_cell, workload_rec->workload[
     workload_cnt].product_event_ind = 0
     IF (bb_result_processing_mean IN ("HISTRY & UPD", "HISTRY ONLY", "AB SCRN INTP", "AB TITER",
     "ABSC CI",
     "AG BILL", "AG INTERP", "CELLPHASEINT", "RH PHENOTYPE", "ABID INTERP"))
      report_all_ind = 0, workload_rec->workload[workload_cnt].report_ind = 1
     ELSE
      workload_rec->workload[workload_cnt].report_ind = 0
     ENDIF
     IF (pr.result_status_cd IN (performed_code, old_performed_code, inreview_code, old_inreveiw_code
     ))
      workload_rec->workload[workload_cnt].status = "PO"
     ELSEIF (pr.result_status_cd IN (corrected_code, old_corrected_code, corr_inreview_code,
     old_corr_inreview_code))
      workload_rec->workload[workload_cnt].status = "CO"
     ENDIF
    ENDIF
    IF (((pr.result_status_cd=verified_code) OR (pr.result_status_cd=old_verified_code)) )
     IF (re.event_type_cd=performed_code)
      workload_rec->workload[workload_cnt].status = "PO"
     ELSEIF (re.event_type_cd=verified_code)
      IF (personnel_cnt=1)
       workload_rec->workload[workload_cnt].status = "PV"
      ELSE
       workload_rec->workload[workload_cnt].status = "VO"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  product_cell
   IF (report_all_ind=1)
    FOR (idx = order_start_cnt TO workload_cnt)
      workload_rec->workload[idx].report_ind = 1
    ENDFOR
   ENDIF
  FOOT REPORT
   select_ok_ind = 1, stat = alterlist(workload_rec->workload,workload_cnt)
  WITH nocounter, dontcare(ol), outerjoin(d_boc),
   orahintcbo("index(PTR  XPKPROFILE_TASK_R) index(R  XPKRESULT) index(O  XPKORDERS)")
 ;end select
 IF (select_ok_ind=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_workload"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "failed for select of orderables"
  GO TO exit_script
 ENDIF
 SET autologous_code = uar_get_code_by(cdfmean,code_set_1610,"10")
 SET directed_code = uar_get_code_by(cdfmean,code_set_1610,"11")
 SET dispensed_code = uar_get_code_by(cdfmean,code_set_1610,"4")
 SET disposed_code = uar_get_code_by(cdfmean,code_set_1610,"5")
 SET modified_code = uar_get_code_by(cdfmean,code_set_1610,"8")
 SET pooled_product_code = uar_get_code_by(cdfmean,code_set_1610,"18")
 SET received_code = uar_get_code_by(cdfmean,code_set_1610,"13")
 SET transfused_code = uar_get_code_by(cdfmean,code_set_1610,"7")
 IF (((autologous_code <= 0) OR (((directed_code <= 0) OR (((dispensed_code <= 0) OR (((disposed_code
  <= 0) OR (((modified_code <= 0) OR (((pooled_product_code <= 0) OR (((received_code <= 0) OR (
 transfused_code <= 0)) )) )) )) )) )) )) )
  SET select_ok_ind = 0
 ENDIF
 IF (select_ok_ind=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_workload"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "select failed for select of code set 1610"
  GO TO exit_script
 ENDIF
 SET personnel_id = 0.0
 SET activity_event_cd = 0.0
 SELECT INTO "nl:"
  dsp_ind = decode(dsp.seq,1,0), pe.product_event_id, pe.event_dt_tm,
  pe.event_prsnl_id, pe.event_type_cd, pe.order_id,
  pe.related_product_event_id, p.product_id, p.cur_owner_area_cd,
  p.cur_inv_area_cd, reason_meaning = uar_get_code_meaning(dsp.reason_cd), method_meaning =
  uar_get_code_meaning(dst.method_cd)
  FROM product_event pe,
   product p,
   (dummyt d_dsp  WITH seq = 1),
   disposition dsp,
   product_event rpe,
   destruction dst
  PLAN (pe
   WHERE pe.event_dt_tm >= cnvtdatetime(request->beg_dt_tm)
    AND pe.event_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND ((pe.event_type_cd=dispensed_code) OR (((pe.order_id=0.0) OR (pe.order_id=null)) ))
    AND pe.event_prsnl_id > 0
    AND pe.event_prsnl_id != null
    AND ((pe.event_type_cd IN (autologous_code, directed_code, dispensed_code, modified_code,
   pooled_product_code,
   received_code, transfused_code)) OR (pe.event_type_cd=disposed_code
    AND ((pe.related_product_event_id=0) OR (pe.related_product_event_id=null)) )) )
   JOIN (p
   WHERE p.product_id=pe.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (p.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (p.cur_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (d_dsp
   WHERE d_dsp.seq=1)
   JOIN (dsp
   WHERE dsp.product_event_id=pe.product_event_id)
   JOIN (rpe
   WHERE rpe.related_product_event_id=dsp.product_event_id)
   JOIN (dst
   WHERE dst.product_event_id=rpe.product_event_id)
  ORDER BY pe.event_prsnl_id, pe.product_event_id
  HEAD REPORT
   select_ok_ind = 0,
   MACRO (add_workload_row)
    workload_cnt += 1
    IF (workload_cnt > size(workload_rec->workload,5))
     stat = alterlist(workload_rec->workload,(workload_cnt+ 9))
    ENDIF
    workload_rec->workload[workload_cnt].personnel_id = personnel_id, workload_rec->workload[
    workload_cnt].activity_event_cd = activity_event_cd, workload_rec->workload[workload_cnt].
    task_assay_cd = 0.0,
    workload_rec->workload[workload_cnt].interp_cd = 0.0, workload_rec->workload[workload_cnt].
    report_priority_cd = 0.0, workload_rec->workload[workload_cnt].bb_order_cell_cd = 0.0,
    workload_rec->workload[workload_cnt].report_ind = 1, workload_rec->workload[workload_cnt].
    product_event_ind = 1, workload_rec->workload[workload_cnt].status = "  "
   ENDMACRO
  DETAIL
   IF (pe.event_type_cd IN (dispensed_code, modified_code, pooled_product_code, transfused_code,
   received_code,
   autologous_code, directed_code))
    personnel_id = pe.event_prsnl_id, activity_event_cd = pe.event_type_cd, add_workload_row
   ELSEIF (pe.event_type_cd=disposed_code
    AND dsp_ind=1)
    IF ( NOT (reason_meaning IN ("POOLED", "MODIFIED")))
     IF (method_meaning="DESTNOW")
      personnel_id = rpe.event_prsnl_id, activity_event_cd = rpe.event_type_cd, add_workload_row
     ELSE
      personnel_id = pe.event_prsnl_id, activity_event_cd = pe.event_type_cd, add_workload_row
      IF (method_meaning="DESTLATR"
       AND rpe.event_status_flag=0)
       personnel_id = rpe.event_prsnl_id, activity_event_cd = rpe.event_type_cd, add_workload_row
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   select_ok_ind = 1, stat = alterlist(workload_rec->workload,workload_cnt)
  WITH nocounter, outerjoin(d_dsp)
 ;end select
 IF (select_ok_ind=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_workload"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "failed for select of product events"
  GO TO exit_script
 ENDIF
 IF (workload_cnt > 0)
  FOR (idx = 1 TO size(request->parameter_list,5))
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(workload_cnt))
    DETAIL
     IF ((request->parameter_list[idx].personnel_break_ind=1))
      workload_rec->workload[d.seq].workload_sort.personnel_id = workload_rec->workload[d.seq].
      personnel_id
     ELSE
      workload_rec->workload[d.seq].workload_sort.personnel_id = 0
     ENDIF
     IF ((request->parameter_list[idx].cell_break_ind=1))
      workload_rec->workload[d.seq].workload_sort.bb_order_cell_cd = workload_rec->workload[d.seq].
      bb_order_cell_cd
     ELSE
      workload_rec->workload[d.seq].workload_sort.bb_order_cell_cd = 0
     ENDIF
     IF ((request->parameter_list[idx].action_break_ind=1))
      workload_rec->workload[d.seq].workload_sort.status_sort =
      IF ((workload_rec->workload[d.seq].status="PO")) 1
      ELSEIF ((workload_rec->workload[d.seq].status="PV")) 2
      ELSEIF ((workload_rec->workload[d.seq].status="VO")) 3
      ELSEIF ((workload_rec->workload[d.seq].status="CO")) 4
      ELSE 5
      ENDIF
     ELSE
      workload_rec->workload[d.seq].workload_sort.status_sort = 0
     ENDIF
     IF ((request->parameter_list[idx].priority_break_ind=1))
      workload_rec->workload[d.seq].workload_sort.report_priority_cd = workload_rec->workload[d.seq].
      report_priority_cd
     ELSE
      workload_rec->workload[d.seq].workload_sort.report_priority_cd = 0
     ENDIF
    WITH nocounter
   ;end select
   CALL print_report(request->parameter_list[idx].personnel_break_ind,request->parameter_list[idx].
    cell_break_ind,request->parameter_list[idx].action_break_ind,request->parameter_list[idx].
    priority_break_ind)
  ENDFOR
 ELSE
  SET stat = alterlist(workload_rec->workload,1)
  SET workload_cnt = 1
  FOR (idx = 1 TO size(request->parameter_list,5))
    CALL print_report(request->parameter_list[idx].personnel_break_ind,request->parameter_list[idx].
     cell_break_ind,request->parameter_list[idx].action_break_ind,request->parameter_list[idx].
     priority_break_ind)
  ENDFOR
 ENDIF
 SUBROUTINE print_report(personnel_break_ind,cell_break_ind,action_break_ind,priority_break_ind)
   SET task_assay_break_ind = 1
   SET break_down_disp = fillstring(125," ")
   SET rpt_cnt = 0
   EXECUTE cpm_create_file_name_logical "bbt_workload", "txt", "x"
   SELECT INTO cpm_cfn_info->file_name_logical
    personnel_id = workload_rec->workload[d.seq].personnel_id, product_event_ind = workload_rec->
    workload[d.seq].product_event_ind, activity_event_cd = workload_rec->workload[d.seq].
    activity_event_cd,
    activity_event_disp = concat(trim(uar_get_code_display(workload_rec->workload[d.seq].
       activity_event_cd)),
     IF ((workload_rec->workload[d.seq].product_event_ind=1)) ""
     ELSE " - "
     ENDIF
     ,trim(uar_get_code_display(workload_rec->workload[d.seq].task_assay_cd))), task_assay_cd =
    workload_rec->workload[d.seq].task_assay_cd, task_assay_disp =
    IF ((workload_rec->workload[d.seq].task_assay_cd > 0)) trim(uar_get_code_display(workload_rec->
       workload[d.seq].task_assay_cd))
    ELSE ""
    ENDIF
    ,
    interp_cd = workload_rec->workload[d.seq].interp_cd, interp_disp =
    IF ((workload_rec->workload[d.seq].interp_cd > 0)) trim(uar_get_code_display(workload_rec->
       workload[d.seq].interp_cd))
    ELSE ""
    ENDIF
    , bb_order_cell_cd = workload_rec->workload[d.seq].bb_order_cell_cd,
    bb_order_cell_disp =
    IF ((workload_rec->workload[d.seq].bb_order_cell_cd > 0)) trim(uar_get_code_display(workload_rec
       ->workload[d.seq].bb_order_cell_cd))
    ELSE ""
    ENDIF
    , report_priority_cd = workload_rec->workload[d.seq].report_priority_cd, report_priority_disp =
    IF ((workload_rec->workload[d.seq].report_priority_cd > 0)) trim(uar_get_code_display(
       workload_rec->workload[d.seq].report_priority_cd))
    ELSE ""
    ENDIF
    ,
    status = workload_rec->workload[d.seq].status, status_sort =
    IF ((workload_rec->workload[d.seq].status="PO")) 1
    ELSEIF ((workload_rec->workload[d.seq].status="PV")) 2
    ELSEIF ((workload_rec->workload[d.seq].status="VO")) 3
    ELSEIF ((workload_rec->workload[d.seq].status="CO")) 4
    ELSE 5
    ENDIF
    , sort_person = workload_rec->workload[d.seq].workload_sort.personnel_id,
    sort_cell = workload_rec->workload[d.seq].workload_sort.bb_order_cell_cd, sort_action =
    workload_rec->workload[d.seq].workload_sort.status_sort, sort_priority = workload_rec->workload[d
    .seq].workload_sort.report_priority_cd
    FROM (dummyt d  WITH seq = value(workload_cnt)),
     (dummyt d_p  WITH seq = 1),
     prsnl p
    PLAN (d
     WHERE (workload_rec->workload[d.seq].report_ind=1))
     JOIN (d_p
     WHERE d_p.seq=1)
     JOIN (p
     WHERE (p.person_id=workload_rec->workload[d.seq].personnel_id))
    ORDER BY
     IF (personnel_break_ind=1) p.username
     ELSE null
     ENDIF
     , sort_person, product_event_ind,
     activity_event_disp, activity_event_cd, task_assay_cd,
     sort_cell, sort_action, sort_priority
    HEAD REPORT
     continue_ind = 0, select_ok_ind = 0, dash_line = fillstring(125,"-"),
     print_tech_head = 1, print_order_act_head = 1, status_sort_disp = "                    ",
     task_assay_cnt = 0, bb_order_cell_cnt = 0, priority_cnt = 0,
     status_cnt = 0, person_cnt = 0, break_down_disp = trim(captions->summary_by)
     IF (personnel_break_ind=1)
      break_down_disp = trim(concat(trim(break_down_disp)," ",captions->personnel))
     ENDIF
     break_down_disp = trim(concat(trim(break_down_disp)," ",captions->orderable_activity))
     IF (cell_break_ind=1)
      break_down_disp = trim(concat(trim(break_down_disp),captions->cell_header))
     ENDIF
     IF (action_break_ind=1)
      break_down_disp = trim(concat(trim(break_down_disp),captions->action_header))
     ENDIF
     IF (priority_break_ind=1)
      break_down_disp = trim(concat(trim(break_down_disp),captions->priority_header))
     ENDIF
     break_down_length = size(trim(break_down_disp))
    HEAD PAGE
     beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
     CALL center(captions->rpt_title,1,125),
     col 104, captions->rpt_time, col 118,
     curtime"@TIMENOSECONDS;;M", row + 1, col 104,
     captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d",
     inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
     IF (sub_get_location_name="<<INFORMATION NOT FOUND>>")
      inc_info_not_found = uar_i18ngetmessage(inc_i18nhandle,"inc_information_not_found",
       "<<INFORMATION NOT FOUND>>"), col 1, inc_info_not_found
     ELSE
      col 1, sub_get_location_name
     ENDIF
     row + 1
     IF (sub_get_location_name != "<<INFORMATION NOT FOUND>>")
      IF (sub_get_location_address1 != " ")
       col 1, sub_get_location_address1, row + 1
      ENDIF
      IF (sub_get_location_address2 != " ")
       col 1, sub_get_location_address2, row + 1
      ENDIF
      IF (sub_get_location_address3 != " ")
       col 1, sub_get_location_address3, row + 1
      ENDIF
      IF (sub_get_location_address4 != " ")
       col 1, sub_get_location_address4, row + 1
      ENDIF
      IF (sub_get_location_citystatezip != ",   ")
       col 1, sub_get_location_citystatezip, row + 1
      ENDIF
      IF (sub_get_location_country != " ")
       col 1, sub_get_location_country, row + 1
      ENDIF
     ENDIF
     CALL center(substring(1,break_down_length,break_down_disp),1,125), row + 1, col 1,
     captions->blood_bank_owner, col 19, owner_area_disp,
     row + 1, col 1, captions->inventory_area,
     col 17, inv_area_disp, row + 2,
     col 32, captions->begin_date, col 48,
     beg_dt_tm"@DATETIMECONDENSED;;d", col 69, captions->ending_date,
     col 82, end_dt_tm"@DATETIMECONDENSED;;d", row + 1,
     col 1, dash_line, row + 1,
     col 1, captions->orderable_detail, col 75,
     captions->totals, row + 1, col 5,
     captions->cell, col 25, captions->action,
     col 50, captions->priority, col 72,
     captions->paren_p, col 82, captions->paren_a,
     col 92, captions->paren_c, col 100,
     captions->paren_od_a, row + 1, col 1,
     dash_line
     IF (sort_person > 0)
      IF (continue_ind=1)
       row + 1, cont_disp = trim(concat("(",trim(p.username)," continued)")), col 1,
       cont_disp, row + 1
      ENDIF
     ENDIF
    HEAD sort_person
     IF (sort_person > 0)
      IF (row > 50)
       BREAK
      ENDIF
      row + 1
      IF (trim(p.username) > "")
       user = p.username, dash = " - "
      ELSE
       user = captions->unknown, dash = "   "
      ENDIF
      col 1, captions->user, full_user_disp = trim(concat(trim(user),dash,trim(p.name_full_formatted)
        )),
      col 7, full_user_disp"###################################", person_cnt = 0,
      continue_ind = 1
     ENDIF
    HEAD activity_event_cd
     row + 0
    HEAD task_assay_cd
     first_time_cell = 1, first_time_status = 1, first_time_priority = 1,
     row + 2
     IF (row > 52)
      BREAK, row + 1
     ENDIF
     col 1, activity_event_disp"##################################################"
     IF (product_event_ind != 1)
      IF (row > 55)
       BREAK, row + 1
      ENDIF
      IF (((sort_cell > 0) OR (((sort_action > 0) OR (sort_priority > 0)) )) )
       row + 1
      ENDIF
     ENDIF
     task_assay_cnt = 0
    HEAD sort_cell
     IF (sort_cell > 0)
      IF (first_time_cell=0)
       row + 1
      ENDIF
      IF (row > 55)
       BREAK, row + 1
      ENDIF
      col 5, bb_order_cell_disp"###############", first_time_status = 1,
      first_time_priority = 1
     ENDIF
     bb_order_cell_cnt = 0, first_time_cell = 0
    HEAD sort_action
     IF (sort_action > 0)
      IF (product_event_ind=0)
       IF (first_time_status=0)
        row + 1
       ENDIF
       IF (row > 55)
        BREAK, row + 1
       ENDIF
       IF (sort_action=1)
        status_sort_disp = "Perform Only"
       ELSEIF (sort_action=2)
        status_sort_disp = "Perform/Verify"
       ELSEIF (sort_action=3)
        status_sort_disp = "Verify Only"
       ELSEIF (sort_action=4)
        status_sort_disp = "Corrected"
       ELSEIF (sort_action=0)
        status_sort_disp = ""
       ELSE
        status_sort_disp = "ERROR"
       ENDIF
       col 25, status_sort_disp
      ENDIF
      first_time_status = 0, status_cnt = 0, first_time_priority = 1
     ENDIF
    HEAD sort_priority
     IF (sort_priority > 0)
      IF (first_time_priority=0)
       row + 1
      ENDIF
      IF (row > 55)
       BREAK, row + 1
      ENDIF
      col 50, report_priority_disp"####################"
     ENDIF
     first_time_priority = 0, priority_cnt = 0
    DETAIL
     person_cnt += 1, task_assay_cnt += 1, bb_order_cell_cnt += 1,
     priority_cnt += 1, status_cnt += 1
    FOOT  sort_priority
     IF (sort_priority > 0)
      IF (sort_priority > 0)
       IF (row > 55)
        BREAK, row + 1
       ENDIF
       col 70, priority_cnt"######;R"
      ENDIF
     ENDIF
    FOOT  sort_action
     IF (product_event_ind=0)
      IF (row > 55)
       BREAK, row + 1
      ENDIF
      IF (sort_priority > 0)
       row + 1, col 70, "------"
       IF (sort_action > 0)
        IF (row > 55)
         BREAK
        ENDIF
        row + 1, s_disp = trim(concat(captions->total,trim(status_sort_disp),")")), col 25,
        s_disp"##############################"
       ENDIF
      ENDIF
      IF (sort_action > 0)
       col 80, status_cnt"######;R", row + 1
      ENDIF
     ENDIF
    FOOT  sort_cell
     IF (sort_cell > 0)
      IF (row > 55)
       BREAK, row + 1
      ENDIF
      IF (sort_action > 0)
       col 80, "------"
       IF (row > 55)
        BREAK
       ENDIF
       row + 1, b_disp = trim(concat(captions->total,trim(bb_order_cell_disp),")")), col 5,
       b_disp"#########################"
      ENDIF
      IF (sort_priority > 0
       AND  NOT (sort_action > 0))
       IF (row > 55)
        BREAK
       ENDIF
       row + 1
      ENDIF
      col 90, bb_order_cell_cnt"######;R", row + 1
     ENDIF
    FOOT  task_assay_cd
     IF (row > 55)
      BREAK, row + 1
     ENDIF
     IF (product_event_ind != 1)
      IF (((sort_cell > 0) OR (sort_action > 0)) )
       IF (bb_order_cell_cd > 0
        AND sort_cell > 0)
        col 90, "------"
       ELSE
        col 80, "------"
       ENDIF
       IF (row > 55)
        BREAK
       ENDIF
      ENDIF
      IF (((sort_cell > 0) OR (((sort_action > 0) OR (sort_priority > 0)) )) )
       row + 1, o_disp = trim(concat(captions->total,trim(activity_event_disp),")")), col 1,
       o_disp
      ENDIF
     ENDIF
     col 100, task_assay_cnt"######;R"
    FOOT  sort_person
     IF (row > 55)
      BREAK
     ENDIF
     row + 1, col 100, "------"
     IF (row > 55)
      BREAK
     ENDIF
     row + 1
     IF (sort_person > 0)
      p_disp = trim(concat(captions->total,trim(user),")"))
     ELSE
      p_disp = trim(concat(captions->total,")"))
     ENDIF
     col 1, p_disp"##################", col 100,
     person_cnt"######;R"
     IF (row > 55)
      BREAK
     ELSE
      row + 1, col 1, dash_line
     ENDIF
     continue_ind = 0
    FOOT PAGE
     row 57, col 1, dash_line,
     row + 1, col 1, captions->rpt_id,
     col 58, captions->rpt_page, col 64,
     curpage"###;L", col 100, captions->printed,
     col 110, curdate"@DATECONDENSED;;d", col 120,
     curtime"@TIMENOSECONDS;;M"
    FOOT REPORT
     row 60, col 51, captions->end_of_report,
     select_ok_ind = 1
    WITH nocounter, outerjoin(d_p), nullreport,
     maxrow = 61, compress
   ;end select
   IF (select_ok_ind=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_workload"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "select"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "failed for select of workload structure"
    GO TO exit_script
   ENDIF
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   IF (trim(request->batch_selection) > " ")
    SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
   ENDIF
 END ;Subroutine
#exit_script
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
