CREATE PROGRAM aps_rpt_outstanding_rpts:dba
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
   1 report_queue_name = c40
   1 service_resource_name = c40
   1 responsible_pathologist_name = vc
   1 responsible_resident_name = vc
   1 case_qual[10]
     2 case_id = f8
     2 encntr_id = f8
     2 prefix_cd = f8
     2 accession_nbr = c18
     2 req_physician_name = vc
     2 person_id = f8
     2 person_name = vc
     2 person_num = c16
     2 report_qual[*]
       3 report_queue_seq = i4
       3 report_id = f8
       3 report_sequence = i4
       3 resp_pathologist_id = f8
       3 resp_pathologist_init = vc
       3 resp_resident_id = f8
       3 resp_resident_init = vc
       3 short_description = c50
       3 priority_cd = f8
       3 priority_disp = c8
       3 priority_cdf_mean = c12
       3 hold_cd = f8
       3 status_disp = c15
       3 primary_sort_string = c20
       3 secondary_sort_string = c18
       3 tertiary_sort_string = c15
 )
 RECORD srtemp(
   1 qual[1]
     2 service_resource_cd = f8
 )
 RECORD reply(
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
 RECORD captions(
   1 rpt_nm = vc
   1 ana = vc
   1 dt = vc
   1 dir = vc
   1 tm = vc
   1 out = vc
   1 bye = vc
   1 pg = vc
   1 md = vc
   1 que = vc
   1 res = vc
   1 cri = vc
   1 com = vc
   1 yes = vc
   1 no = vc
   1 pri = vc
   1 cse = vc
   1 rpt = vc
   1 stat = vc
   1 resp = vc
   1 pat = vc
   1 req_by = vc
   1 unkn = vc
   1 end_rpt = vc
   1 sv_rs = vc
   1 res_pat = vc
   1 res_res = vc
   1 none = vc
   1 hol = vc
 )
 SET captions->rpt_nm = uar_i18ngetmessage(i18nhandle,"t1","REPORT: APS_RPT_OUTSTANDING_RPTS.PRG")
 SET captions->ana = uar_i18ngetmessage(i18nhandle,"t2","Anatomic Pathology")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t3","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t4","DIRECTORY:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t5","TIME:")
 SET captions->out = uar_i18ngetmessage(i18nhandle,"t6","OUTSTANDING REPORTS")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t7","BY:")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t8","PAGE:")
 SET captions->md = uar_i18ngetmessage(i18nhandle,"t9","MODE:")
 SET captions->que = uar_i18ngetmessage(i18nhandle,"t10","BY QUEUE")
 SET captions->res = uar_i18ngetmessage(i18nhandle,"t11","BY RESPONSIBILITY")
 SET captions->cri = uar_i18ngetmessage(i18nhandle,"t12","CRITERIA:")
 SET captions->com = uar_i18ngetmessage(i18nhandle,"t13","COMPLETED REPORTS ONLY:")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"t14","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"t15","NO")
 SET captions->pri = uar_i18ngetmessage(i18nhandle,"t16","PRIORITY")
 SET captions->cse = uar_i18ngetmessage(i18nhandle,"t17","CASE")
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"t18","REPORT")
 SET captions->stat = uar_i18ngetmessage(i18nhandle,"t19","STATUS")
 SET captions->resp = uar_i18ngetmessage(i18nhandle,"t20","RESPONSIBILITY")
 SET captions->pat = uar_i18ngetmessage(i18nhandle,"t21","PATIENT")
 SET captions->req_by = uar_i18ngetmessage(i18nhandle,"t22","REQUESTED BY")
 SET captions->unkn = uar_i18ngetmessage(i18nhandle,"t23","Unknown")
 SET captions->end_rpt = uar_i18ngetmessage(i18nhandle,"t24","*** end of outstanding reports ***")
 SET captions->sv_rs = uar_i18ngetmessage(i18nhandle,"t25","SERVICE RESOURCE:")
 SET captions->res_pat = uar_i18ngetmessage(i18nhandle,"t26","              RESPONSIBLE PATHOLOGIST:"
  )
 SET captions->res_res = uar_i18ngetmessage(i18nhandle,"t27","       RESPONSIBLE RESIDENT:")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"t28","NONE")
 SET captions->hol = uar_i18ngetmessage(i18nhandle,"t29","HOLD")
 SET reply->status_data.status = "F"
 SET case_cnt = 0
 SET max_rpt_cnt = 0
 SET mrn_alias_type_cd = 0.0
 SET completed_status_cd = 0.0
 SET verified_status_cd = 0.0
 SET corrected_status_cd = 0.0
 SET name_type_cd = 0.0
 CALL initresourcesecurity(1)
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET error_cnt = 0
 SET code_set = 1305
 SET cdf_meaning = "VERIFIED"
 EXECUTE cpm_get_cd_for_cdf
 SET verified_status_cd = code_value
 SET code_set = 1305
 SET cdf_meaning = "COMPLETED"
 EXECUTE cpm_get_cd_for_cdf
 SET completed_status_cd = code_value
 SET code_set = 1305
 SET cdf_meaning = "CORRECTED"
 EXECUTE cpm_get_cd_for_cdf
 SET corrected_status_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 IF ((request->mode=1))
  SELECT INTO "nl:"
   c.display
   FROM code_value c
   WHERE 1319=c.code_set
    AND (request->report_queue_cd=c.code_value)
   DETAIL
    temp->report_queue_name = c.display
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","Z","TABLE","CODE_VALUE:CODE_SET_1319")
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   rqr.report_id, rt.report_id, cr.report_sequence,
   pc.case_id, cv1.display, cv2.display,
   sd.short_description, prr.primary_ind, p.name_full_formatted
   FROM report_queue_r rqr,
    report_task rt,
    case_report cr,
    pathology_case pc,
    code_value cv1,
    code_value cv2,
    service_directory sd,
    prefix_report_r prr,
    prsnl p
   PLAN (rqr
    WHERE (request->report_queue_cd=rqr.report_queue_cd))
    JOIN (rt
    WHERE rqr.report_id=rt.report_id)
    JOIN (cr
    WHERE rt.report_id=cr.report_id
     AND cr.cancel_cd IN (0, null)
     AND  NOT (cr.status_cd IN (verified_status_cd, corrected_status_cd)))
    JOIN (pc
    WHERE parser(
     IF ((request->show_complete=1)) " completed_status_cd = cr.status_cd"
     ELSE "0 = 0"
     ENDIF
     )
     AND cr.case_id=pc.case_id
     AND pc.reserved_ind IN (0, null)
     AND pc.cancel_cd IN (0, null))
    JOIN (cv1
    WHERE rt.priority_cd=cv1.code_value)
    JOIN (cv2
    WHERE cr.status_cd=cv2.code_value)
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    JOIN (prr
    WHERE cr.catalog_cd=prr.catalog_cd
     AND pc.prefix_id=prr.prefix_id)
    JOIN (p
    WHERE pc.requesting_physician_id=p.person_id)
   ORDER BY pc.case_id, rt.report_id
   HEAD REPORT
    case_cnt = 0, report_cnt = 0, service_resource_cd = 0.0
   HEAD pc.case_id
    report_cnt = 0
   HEAD rt.report_id
    service_resource_cd = rt.service_resource_cd
    IF (isresourceviewable(service_resource_cd)=true)
     IF (report_cnt=0)
      case_cnt += 1
      IF (mod(case_cnt,10)=1
       AND case_cnt != 1)
       stat = alter(temp->case_qual,(case_cnt+ 10))
      ENDIF
      temp->case_qual[case_cnt].accession_nbr = pc.accession_nbr, temp->case_qual[case_cnt].case_id
       = pc.case_id, temp->case_qual[case_cnt].person_id = pc.person_id,
      temp->case_qual[case_cnt].encntr_id = pc.encntr_id, temp->case_qual[case_cnt].prefix_cd = pc
      .prefix_id, temp->case_qual[case_cnt].req_physician_name = substring(1,17,p.name_full_formatted
       )
     ENDIF
     report_cnt += 1
     IF (report_cnt > max_rpt_cnt)
      max_rpt_cnt = report_cnt
     ENDIF
     stat = alterlist(temp->case_qual[case_cnt].report_qual,report_cnt), temp->case_qual[case_cnt].
     report_qual[report_cnt].report_queue_seq = rqr.sequence, temp->case_qual[case_cnt].report_qual[
     report_cnt].report_id = rt.report_id,
     temp->case_qual[case_cnt].report_qual[report_cnt].resp_pathologist_id = rt
     .responsible_pathologist_id, temp->case_qual[case_cnt].report_qual[report_cnt].resp_resident_id
      = rt.responsible_resident_id, temp->case_qual[case_cnt].report_qual[report_cnt].priority_cd =
     rt.priority_cd,
     temp->case_qual[case_cnt].report_qual[report_cnt].priority_cdf_mean = cv1.cdf_meaning, temp->
     case_qual[case_cnt].report_qual[report_cnt].priority_disp = substring(1,8,cv1.display), temp->
     case_qual[case_cnt].report_qual[report_cnt].status_disp = substring(1,15,cv2.display),
     temp->case_qual[case_cnt].report_qual[report_cnt].report_sequence = cr.report_sequence, temp->
     case_qual[case_cnt].report_qual[report_cnt].hold_cd = rt.hold_cd, temp->case_qual[case_cnt].
     report_qual[report_cnt].short_description = substring(1,15,sd.short_description),
     temp->case_qual[case_cnt].report_qual[report_cnt].primary_sort_string = format(rqr.sequence,
      "###"), temp->case_qual[case_cnt].report_qual[report_cnt].secondary_sort_string = " ", temp->
     case_qual[case_cnt].report_qual[report_cnt].tertiary_sort_string = " "
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","Z","TABLE","CASE AND RPT INFO:QUEUE MODE")
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ELSEIF (getresourcesecuritystatus(0) != "S")
   SET reply->status_data.status = getresourcesecuritystatus(0)
   CALL populateressecstatusblock(0)
   GO TO exit_script
  ENDIF
 ELSE
  IF ((request->service_resource_cd > 0))
   SELECT INTO "nl:"
    c.display
    FROM code_value c
    WHERE 221=c.code_set
     AND (request->service_resource_cd=c.code_value)
    DETAIL
     temp->service_resource_name = c.display
    WITH nocounter
   ;end select
  ENDIF
  IF ((request->responsible_pathologist_id > 0))
   SELECT INTO "nl:"
    p.name_full_formatted
    FROM prsnl p
    WHERE (request->responsible_pathologist_id=p.person_id)
    DETAIL
     temp->responsible_pathologist_name = p.name_full_formatted
    WITH nocounter
   ;end select
  ENDIF
  IF ((request->responsible_resident_id > 0))
   SELECT INTO "nl:"
    p.name_full_formatted
    FROM prsnl p
    WHERE (request->responsible_resident_id=p.person_id)
    DETAIL
     temp->responsible_resident_name = p.name_full_formatted
    WITH nocounter
   ;end select
  ENDIF
  IF ((request->service_resource_cd > 0))
   SET srtemp->qual[1].service_resource_cd = request->service_resource_cd
   SET cntr = 1
   SELECT INTO "nl:"
    rg.child_service_resource_cd
    FROM resource_group rg
    PLAN (rg
     WHERE (request->service_resource_cd=rg.parent_service_resource_cd)
      AND rg.active_ind=1
      AND rg.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND rg.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     cntr += 1, stat = alter(srtemp->qual,cntr), srtemp->qual[cntr].service_resource_cd = rg
     .child_service_resource_cd
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   rt.report_id, cr.report_sequence, pc.case_id,
   cv1.display, cv2.display, sd.short_description,
   prr.primary_ind, p.name_full_formatted
   FROM report_task rt,
    case_report cr,
    pathology_case pc,
    code_value cv1,
    code_value cv2,
    service_directory sd,
    prefix_report_r prr,
    prsnl p,
    (dummyt d  WITH seq = value(size(srtemp->qual,5)))
   PLAN (d)
    JOIN (rt
    WHERE parser(
     IF ((request->service_resource_cd > 0))
      " srtemp->qual[d.seq].service_resource_cd = rt.service_resource_cd"
     ELSE "0 = 0"
     ENDIF
     )
     AND parser(
     IF ((request->responsible_pathologist_id > 0))
      " request->responsible_pathologist_id = rt.responsible_pathologist_id"
     ELSE "0 = 0"
     ENDIF
     )
     AND parser(
     IF ((request->responsible_resident_id > 0))
      " request->responsible_resident_id = rt.responsible_resident_id"
     ELSE "0 = 0"
     ENDIF
     ))
    JOIN (cr
    WHERE parser(
     IF ((request->show_complete=1)) " completed_status_cd = cr.status_cd"
     ELSE "0 = 0"
     ENDIF
     )
     AND rt.report_id=cr.report_id
     AND cr.cancel_cd IN (0, null)
     AND  NOT (cr.status_cd IN (verified_status_cd, corrected_status_cd)))
    JOIN (pc
    WHERE cr.case_id=pc.case_id
     AND pc.reserved_ind IN (0, null)
     AND pc.cancel_cd IN (0, null))
    JOIN (cv1
    WHERE rt.priority_cd=cv1.code_value)
    JOIN (cv2
    WHERE cr.status_cd=cv2.code_value)
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    JOIN (prr
    WHERE cr.catalog_cd=prr.catalog_cd
     AND pc.prefix_id=prr.prefix_id)
    JOIN (p
    WHERE pc.requesting_physician_id=p.person_id)
   ORDER BY pc.case_id, rt.report_id
   HEAD REPORT
    case_cnt = 0, report_cnt = 0, service_resource_cd = 0.0
   HEAD pc.case_id
    report_cnt = 0
   HEAD rt.report_id
    service_resource_cd = rt.service_resource_cd
    IF (isresourceviewable(service_resource_cd)=true)
     IF (report_cnt=0)
      case_cnt += 1
      IF (mod(case_cnt,10)=1
       AND case_cnt != 1)
       stat = alter(temp->case_qual,(case_cnt+ 10))
      ENDIF
      temp->case_qual[case_cnt].accession_nbr = pc.accession_nbr, temp->case_qual[case_cnt].case_id
       = pc.case_id, temp->case_qual[case_cnt].person_id = pc.person_id,
      temp->case_qual[case_cnt].encntr_id = pc.encntr_id, temp->case_qual[case_cnt].prefix_cd = pc
      .prefix_id, temp->case_qual[case_cnt].req_physician_name = substring(1,17,p.name_full_formatted
       )
     ENDIF
     report_cnt += 1
     IF (report_cnt > max_rpt_cnt)
      max_rpt_cnt = report_cnt
     ENDIF
     stat = alterlist(temp->case_qual[case_cnt].report_qual,report_cnt), temp->case_qual[case_cnt].
     report_qual[report_cnt].report_id = rt.report_id, temp->case_qual[case_cnt].report_qual[
     report_cnt].priority_cd = rt.priority_cd,
     temp->case_qual[case_cnt].report_qual[report_cnt].priority_cdf_mean = cv1.cdf_meaning, temp->
     case_qual[case_cnt].report_qual[report_cnt].priority_disp = substring(1,8,cv1.display), temp->
     case_qual[case_cnt].report_qual[report_cnt].resp_pathologist_id = rt.responsible_pathologist_id,
     temp->case_qual[case_cnt].report_qual[report_cnt].resp_resident_id = rt.responsible_resident_id,
     temp->case_qual[case_cnt].report_qual[report_cnt].status_disp = substring(1,15,cv2.display),
     temp->case_qual[case_cnt].report_qual[report_cnt].report_sequence = cr.report_sequence,
     temp->case_qual[case_cnt].report_qual[report_cnt].hold_cd = rt.hold_cd, temp->case_qual[case_cnt
     ].report_qual[report_cnt].short_description = substring(1,15,sd.short_description)
     IF (textlen(trim(cv1.cdf_meaning))=0)
      temp->case_qual[case_cnt].report_qual[report_cnt].primary_sort_string = build("zzz",cv1.display
       )
     ELSE
      temp->case_qual[case_cnt].report_qual[report_cnt].primary_sort_string = build(cv1.cdf_meaning,
       cv1.display)
     ENDIF
     temp->case_qual[case_cnt].report_qual[report_cnt].secondary_sort_string = temp->case_qual[
     case_cnt].accession_nbr, temp->case_qual[case_cnt].report_qual[report_cnt].tertiary_sort_string
      = sd.short_description
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","Z","TABLE","CASE AND RPT INFO:RESPONSIBILITY MODE")
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ELSEIF (getresourcesecuritystatus(0) != "S")
   SET reply->status_data.status = getresourcesecuritystatus(0)
   CALL populateressecstatusblock(0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alter(temp->case_qual,case_cnt)
 SET code_set = 213
 SET cdf_meaning = "PRSNL"
 EXECUTE cpm_get_cd_for_cdf
 SET name_type_cd = code_value
 SELECT INTO "nl:"
  d1.seq, d2.seq, d3.seq,
  d4.seq, pn1.name_initials, pn2.name_initials,
  join_path = decode(pn1.seq,"PN1",pn2.seq,"PN2"," ")
  FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
   (dummyt d2  WITH seq = value(max_rpt_cnt)),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   person_name pn1,
   person_name pn2
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->case_qual[d1.seq].report_qual,5))
   JOIN (((d3
   WHERE 1=d3.seq)
   JOIN (pn1
   WHERE (temp->case_qual[d1.seq].report_qual[d2.seq].resp_pathologist_id=pn1.person_id)
    AND pn1.name_type_cd=name_type_cd
    AND pn1.active_ind=1
    AND pn1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pn1.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ) ORJOIN ((d4
   WHERE 1=d4.seq)
   JOIN (pn2
   WHERE (temp->case_qual[d1.seq].report_qual[d2.seq].resp_resident_id=pn2.person_id)
    AND pn2.name_type_cd=name_type_cd
    AND pn2.active_ind=1
    AND pn2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pn2.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ))
  DETAIL
   CASE (join_path)
    OF "PN1":
     temp->case_qual[d1.seq].report_qual[d2.seq].resp_pathologist_init = pn1.name_initials
    OF "PN2":
     temp->case_qual[d1.seq].report_qual[d2.seq].resp_resident_init = pn2.name_initials
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d1.seq, p.person_id
  FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
   person p
  PLAN (d1)
   JOIN (p
   WHERE (temp->case_qual[d1.seq].person_id=p.person_id))
  DETAIL
   temp->case_qual[d1.seq].person_name = substring(1,25,p.name_full_formatted)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","RPT_OUTSTANDING_RPTS:PATIENT INFORMATION")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 EXECUTE cpm_create_file_name_logical "aps_outs_reports", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 DECLARE uar_fmt_accession(p1,p2) = c25
 SET criteria_string = fillstring(100," ")
 SET criteria_title_string = fillstring(100," ")
 SET serv_resource_string = fillstring(30," ")
 SET resp_path_string = fillstring(30," ")
 SET resp_resi_string = fillstring(30," ")
 SET priority_string = fillstring(40," ")
 SET formatted_accession = fillstring(21," ")
 SET first_time = 0
 SELECT INTO value(reply->print_status_data.print_filename)
  d1.seq, d2.seq
  FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
   (dummyt d2  WITH seq = value(max_rpt_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->case_qual[d1.seq].report_qual,5))
  ORDER BY temp->case_qual[d1.seq].report_qual[d2.seq].primary_sort_string, temp->case_qual[d1.seq].
   report_qual[d2.seq].secondary_sort_string, temp->case_qual[d1.seq].report_qual[d2.seq].
   tertiary_sort_string
  HEAD REPORT
   first_time = 1
   IF ((request->mode=1))
    criteria_string = temp->report_queue_name
   ELSE
    criteria_title_string = build(captions->sv_rs,captions->res_pat,captions->res_res),
    CALL echo(criteria_title_string)
    IF ((request->service_resource_cd > 0))
     serv_resource_string = temp->service_resource_name
    ELSE
     serv_resource_string = captions->none
    ENDIF
    IF ((request->responsible_pathologist_id > 0))
     resp_path_string = temp->responsible_pathologist_name
    ELSE
     resp_path_string = captions->none
    ENDIF
    IF ((request->responsible_resident_id > 0))
     resp_resi_string = temp->responsible_resident_name
    ELSE
     resp_resi_string = captions->none
    ENDIF
    criteria_string = concat(serv_resource_string," ",resp_path_string," ",resp_resi_string)
   ENDIF
  HEAD PAGE
   col 0, captions->rpt_nm,
   CALL center(captions->ana,1,132),
   col 110, captions->dt, col 117,
   curdate"@SHORTDATE;;D", row + 1, col 0,
   captions->dir, col 110, captions->tm,
   col 117, curtime"@TIMENOSECONDS;;M", row + 1,
   CALL center(captions->out,1,132), col 112, captions->bye,
   col 117, request->curuser, row + 1,
   col 110, captions->pg, col 117,
   curpage"###", row + 1, col 18,
   captions->md
   IF ((request->mode=1))
    col 25, captions->que
   ELSE
    col 25, captions->res
   ENDIF
   row + 1, col 14, captions->cri
   IF ((request->mode=1))
    col 25, criteria_string
   ELSE
    col 25, criteria_title_string, row + 1,
    col 25, criteria_string
   ENDIF
   row + 1, col 0, captions->com
   IF ((request->show_complete=1))
    col 25, captions->yes
   ELSE
    col 25, captions->no
   ENDIF
   row + 2, col 0, captions->pri,
   col 10, captions->cse, col 33,
   captions->rpt, col 50, captions->hol,
   col 55, captions->stat, col 72,
   captions->resp, col 88, captions->pat,
   col 114, captions->req_by, row + 1,
   col 0, "--------", col 10,
   "---------------------", col 33, "---------------",
   col 50, "----", col 55,
   "---------------", col 72, "--------------",
   col 88, "-------------------------", col 114,
   "-----------------"
   IF (first_time=0)
    row + 1
   ELSE
    first_time = 0
   ENDIF
  DETAIL
   row + 1, col 0, temp->case_qual[d1.seq].report_qual[d2.seq].priority_disp,
   formatted_accession = uar_fmt_accession(temp->case_qual[d1.seq].accession_nbr,size(trim(temp->
      case_qual[d1.seq].accession_nbr),1)), col 10, formatted_accession,
   col 33, temp->case_qual[d1.seq].report_qual[d2.seq].short_description
   IF ((temp->case_qual[d1.seq].report_qual[d2.seq].hold_cd > 0))
    col 50, captions->yes
   ELSE
    col 50, captions->no
   ENDIF
   col 55, temp->case_qual[d1.seq].report_qual[d2.seq].status_disp, col 72,
   temp->case_qual[d1.seq].report_qual[d2.seq].resp_pathologist_init, col 80, temp->case_qual[d1.seq]
   .report_qual[d2.seq].resp_resident_init
   IF (textlen(temp->case_qual[d1.seq].person_name) > 0)
    col 88, temp->case_qual[d1.seq].person_name
   ELSE
    col 88, captions->unkn
   ENDIF
   col 114, temp->case_qual[d1.seq].req_physician_name
  FOOT REPORT
   row + 2,
   CALL center(captions->end_rpt,1,132), row + 2,
   CALL center("##########",1,132)
  WITH nocounter, maxrow = 63, compress
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TEMP RECORD","REPORT MAKER")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
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
#exit_script
END GO
