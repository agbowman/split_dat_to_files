CREATE PROGRAM aps_rpt_followup:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD temp(
   1 auto_qual[*]
     2 event_id = f8
     2 encntr_id = f8
     2 name_full_formatted = c40
     2 alias = vc
     2 accession_nbr = c21
     2 doc_name = vc
     2 verified_date = c8
     2 due_date = c8
     2 term_long_text_id = f8
   1 proc_qual[*]
     2 task_assay_cd = f8
   1 patient_notification_ind = i2
   1 patient_notif_template_id = f8
   1 patient_first_overdue_ind = i2
   1 patient_first_template_id = f8
   1 patient_final_overdue_ind = i2
   1 patient_final_template_id = f8
   1 doctor_notification_ind = i2
   1 doctor_notif_template_id = f8
   1 doctor_first_overdue_ind = i2
   1 doctor_first_template_id = f8
   1 doctor_final_overdue_ind = i2
   1 doctor_final_template_id = f8
   1 doc_temp_qual[3]
     2 template_id = f8
   1 type_qual[3]
     2 type_code = i2
     2 doc_template_qual[*]
       3 dtext = vc
     2 pat_template_qual[*]
       3 ptext = vc
   1 max_pat_cnt = i2
   1 doc_qual[*]
     2 doc_id = f8
     2 doc_name = vc
     2 doc_addr1 = c40
     2 doc_addr2 = c40
     2 doc_addr3 = c40
     2 doc_city = vc
     2 doc_st = vc
     2 doc_zip = c25
     2 123_qual[3]
       3 pat_qual[*]
         4 fte_event_id = f8
         4 name_full_formatted = c40
         4 encntr_id = f8
         4 alias = vc
         4 age = vc
         4 accession_nbr = c21
         4 verified_date = c8
         4 diagnostic_category_cd = f8
         4 display = c40
         4 description = vc
         4 due_date = c8
         4 updt_cnt = i4
         4 event_id = f8
         4 rpt_qual[*]
           5 detail_text = vc
   1 site_name = vc
   1 site_addr1 = c38
   1 site_addr2 = c38
   1 site_addr3 = c38
   1 site_city = vc
   1 site_st = vc
   1 site_zip = c10
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
 RECORD temp_fte(
   1 qual[*]
     2 followup_event_id = f8
     2 case_id = f8
     2 term_long_text_id = f8
     2 initial_notif_dt_tm = dq8
 )
 RECORD temp_pref(
   1 pref_qual[*]
     2 prefix_cd = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_display = c40
 )
 RECORD captions(
   1 rpt_nm = vc
   1 dt = vc
   1 dir = vc
   1 tm = vc
   1 term = vc
   1 bye = vc
   1 pg = vc
   1 pat = vc
   1 id = vc
   1 cse = vc
   1 req = vc
   1 ver = vc
   1 due = vc
   1 no_term = vc
   1 note = vc
   1 no_pat = vc
   1 init = vc
   1 in_over = vc
   1 over = vc
   1 too = vc
   1 fro = vc
   1 ver_as = vc
   1 no_qual = vc
   1 rpt = vc
   1 end_init = vc
   1 end_in_over = vc
   1 end_over = vc
   1 prt = vc
   1 cont = vc
   1 end_rpt = vc
   1 ag = vc
   1 pre = vc
 )
 SET captions->rpt_nm = uar_i18ngetmessage(i18nhandle,"t1","REPORT: APS_RPT_FOLLOWUP.PRG")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t2","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t3","DIRECTORY:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t4","TIME:")
 SET captions->term = uar_i18ngetmessage(i18nhandle,"t5",
  "FOLLOW-UP TRACKING SYSTEM TERMINATION LISTING")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t6","BY:")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t7","PAGE:")
 SET captions->pat = uar_i18ngetmessage(i18nhandle,"t8","PATIENT")
 SET captions->id = uar_i18ngetmessage(i18nhandle,"t9","ID")
 SET captions->cse = uar_i18ngetmessage(i18nhandle,"t10","CASE")
 SET captions->req = uar_i18ngetmessage(i18nhandle,"t11","REQUESTED")
 SET captions->ver = uar_i18ngetmessage(i18nhandle,"t12","VERIFIED")
 SET captions->due = uar_i18ngetmessage(i18nhandle,"t13","DUE")
 SET captions->no_term = uar_i18ngetmessage(i18nhandle,"t14","*** No patients terminated ***")
 SET captions->note = uar_i18ngetmessage(i18nhandle,"t15","FOLLOW-UP TRACKING NOTIFICATION")
 SET captions->no_pat = uar_i18ngetmessage(i18nhandle,"t16","No PATIENTS QUALIFIED FOR:")
 SET captions->init = uar_i18ngetmessage(i18nhandle,"t17","I N I T I A L  N O T I F I C A T I O N")
 SET captions->in_over = uar_i18ngetmessage(i18nhandle,"t18",
  "F I R S T  O V E R D U E  N O T I F I C A T I O N")
 SET captions->over = uar_i18ngetmessage(i18nhandle,"t19",
  "F I N A L  O V E R D U E  N O T I F I C A T I O N")
 SET captions->too = uar_i18ngetmessage(i18nhandle,"t20","TO:")
 SET captions->fro = uar_i18ngetmessage(i18nhandle,"t21","FROM:")
 SET captions->ver_as = uar_i18ngetmessage(i18nhandle,"t22","VERIFIED AS")
 SET captions->no_qual = uar_i18ngetmessage(i18nhandle,"t23","*** No patients qualified ***")
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"t24","REPORT:")
 SET captions->end_init = uar_i18ngetmessage(i18nhandle,"t25",
  "*** END OF INITIAL NOTIFICATION REPORT ***")
 SET captions->end_in_over = uar_i18ngetmessage(i18nhandle,"t26",
  "*** END OF INITIAL OVERDUE NOTIFICATION REPORT ***")
 SET captions->end_over = uar_i18ngetmessage(i18nhandle,"t27",
  "*** END OF OVERDUE NOTIFICATION REPORT ***")
 SET captions->prt = uar_i18ngetmessage(i18nhandle,"t28","REPRINT...")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"t29","CONTINUED...")
 SET captions->end_rpt = uar_i18ngetmessage(i18nhandle,"t30","### END OF REPORT ###")
 SET captions->ag = uar_i18ngetmessage(i18nhandle,"t31","AGE")
 SET captions->pre = uar_i18ngetmessage(i18nhandle,"t32","PREFIX(ES)")
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
 DECLARE blob_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",25,"BLOB"))
 DECLARE blobout = gvc WITH protect, noconstant("")
#script
 DECLARE doc_cnt = i4 WITH noconstant(0)
 DECLARE auto_cnt = i4 WITH noconstant(0)
 DECLARE fte_cnt = i4 WITH noconstant(0)
 DECLARE lprefixes = i4 WITH protect, noconstant(0)
 DECLARE gyn_case_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ngyn_case_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ngyn_case_type_found = c1 WITH protect, noconstant("N")
 DECLARE gyn_case_type_found = c1 WITH protect, noconstant("N")
 DECLARE sprefix_name = vc WITH protect, noconstant(" ")
 DECLARE ssitedisp = vc WITH protect, noconstant(" ")
 DECLARE sprefixparser = vc WITH protect, noconstant(" ")
 DECLARE pref_cntr = i4 WITH protect, noconstant(0)
 DECLARE cdf_meaning = c12 WITH protect, noconstant(" ")
 SET reply->status_data.status = "F"
 SET gyn_case_type_cd = 0.0
 SET ngyn_case_type_cd = 0.0
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET mrn_alias_type_cd = 0.0
 SET address_type_cd = 0.0
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
  DECLARE site_prefix_str = vc WITH protect, noconstant(" ")
  DECLARE prefix_str = vc WITH protect, noconstant(" ")
  DECLARE site_str = vc WITH protect, noconstant(" ")
  DECLARE prefix_code = f8 WITH protect, noconstant(0.0)
  DECLARE raw_ft_type_str = vc WITH protect, noconstant(" ")
  DECLARE raw_prefix_str = vc WITH protect, noconstant(" ")
  DECLARE printer = vc WITH protect, noconstant(" ")
  DECLARE copies = i4 WITH protect, noconstant(0)
  SET raw_doctor_str = fillstring(100," ")
  SET raw_date_str = fillstring(4," ")
  SET raw_date_num_str = 0
  SET raw_organization_id = 0.00
  IF (textlen(trim(request->output_dist))=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with output_dist!"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   x = 1
   DETAIL
    CALL get_text(1,trim(request->batch_selection),"|"), raw_ft_type_str = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    raw_date_str = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_doctor_str = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->print_text = cnvtint(trim(
      text)),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    request->print_init = cnvtint(trim(text)),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->print_first = cnvtint(trim(
      text)),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->print_final = cnvtint(trim(
      text)),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    request->mode = cnvtint(trim(text)),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_organization_id = cnvtint(trim(
      text)),
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
  IF (textlen(trim(raw_doctor_str)) > 0)
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p
    WHERE raw_doctor_str=p.username
    DETAIL
     request->doctor_id = p.person_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with req physician setup!"
    GO TO end_script
   ENDIF
  ELSE
   SET request->doctor_id = 0
  ENDIF
  SET raw_date_num_str = cnvtint(substring(1,3,raw_date_str))
  SET request->date_to = cnvtdatetime(sysdate)
  CASE (substring(4,1,raw_date_str))
   OF "D":
    SET request->date_from = cnvtagedatetime(0,0,0,raw_date_num_str)
   OF "M":
    SET request->date_from = cnvtagedatetime(0,raw_date_num_str,0,0)
   OF "Y":
    SET request->date_from = cnvtagedatetime(raw_date_num_str,0,0,0)
   ELSE
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with date routine setup!"
    GO TO end_script
  ENDCASE
  IF (raw_organization_id > 0.00)
   SET code_value = 0.0
   SET code_set = 212
   SET cdf_meaning = "BUSINESS"
   EXECUTE cpm_get_cd_for_cdf
   SET address_type_cd = code_value
   SET code_value = 0.0
   SELECT INTO "nl:"
    org.organization_id
    FROM organization org
    WHERE org.organization_id=raw_organization_id
     AND org.active_ind=1
     AND org.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND org.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     temp->site_name = trim(substring(1,38,org.org_name))
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    addr.parent_entity_id
    FROM address addr
    WHERE addr.parent_entity_id=raw_organization_id
     AND addr.parent_entity_name="ORGANIZATION"
     AND addr.address_type_cd=address_type_cd
     AND addr.active_ind=1
     AND addr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND addr.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     temp->site_addr1 = trim(addr.street_addr), temp->site_addr2 = trim(addr.street_addr2), temp->
     site_addr3 = trim(addr.street_addr3),
     temp->site_city = trim(addr.city), temp->site_st = trim(addr.state), temp->site_zip = addr
     .zipcode
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 CALL change_times(request->date_from,request->date_to)
 SET request->date_from = dtemp->beg_of_day
 SET request->date_to = dtemp->end_of_day
 SET code_value = 0.0
 SET code_set = 212
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET address_type_cd = code_value
 SET code_value = 0.0
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
 IF (getresourcesecuritystatus(0)="F")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp_pref->pref_qual,pref_cntr)
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
#ft_event
 SELECT INTO "nl:"
  ftt.patient_notification_ind, ftt.followup_tracking_type_cd
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
   proc_cnt = 0, temp->patient_notification_ind = ftt.patient_notification_ind, temp->
   patient_notif_template_id = ftt.patient_notif_template_id,
   temp->patient_first_overdue_ind = ftt.patient_first_overdue_ind, temp->patient_first_template_id
    = ftt.patient_first_template_id, temp->patient_final_overdue_ind = ftt.patient_final_overdue_ind,
   temp->patient_final_template_id = ftt.patient_final_template_id, temp->doctor_notification_ind =
   ftt.doctor_notification_ind, temp->doctor_notif_template_id = ftt.doctor_notif_template_id,
   temp->doctor_first_overdue_ind = ftt.doctor_first_overdue_ind, temp->doctor_first_template_id =
   ftt.doctor_first_template_id, temp->doctor_final_overdue_ind = ftt.doctor_final_overdue_ind,
   temp->doctor_final_template_id = ftt.doctor_final_template_id, temp->doc_temp_qual[1].template_id
    = ftt.doctor_notif_template_id, temp->doc_temp_qual[2].template_id = ftt.doctor_first_template_id,
   temp->doc_temp_qual[3].template_id = ftt.doctor_final_template_id
  DETAIL
   proc_cnt += 1
   IF (mod(proc_cnt,10)=1)
    stat = alterlist(temp->proc_qual,(proc_cnt+ 9))
   ENDIF
   temp->proc_qual[proc_cnt].task_assay_cd = ftrp.task_assay_cd
  FOOT REPORT
   stat = alterlist(temp->proc_qual,proc_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO report_maker
 ENDIF
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = 3),
   wp_template_text wp,
   long_text lt
  PLAN (d)
   JOIN (wp
   WHERE (temp->doc_temp_qual[d.seq].template_id=wp.template_id))
   JOIN (lt
   WHERE wp.long_text_id=lt.long_text_id)
  ORDER BY wp.sequence
  HEAD REPORT
   text_cnt = 0
  HEAD d.seq
   text_cnt = 0
  DETAIL
   CALL rtf_to_text(lt.long_text,1,100)
   FOR (z = 1 TO size(tmptext->qual,5))
     text_cnt += 1, stat = alterlist(temp->type_qual[d.seq].doc_template_qual,text_cnt), temp->
     type_qual[d.seq].doc_template_qual[text_cnt].dtext = trim(tmptext->qual[z].text)
   ENDFOR
  WITH nocounter
 ;end select
 FOR (x = 1 TO 3)
   SET temp->type_qual[x].type_code = x
 ENDFOR
 SET lprefixes = 0
 SET sprefixparser = concat("expand(lPrefixes,1,value(size(temp_pref->pref_qual,5)),",
  "pc.prefix_id+0,temp_pref->pref_qual[lPrefixes].prefix_cd)")
 SET ce_where = fillstring(500," ")
 FOR (x = 1 TO value(size(temp->proc_qual,5)))
   IF (x < value(size(temp->proc_qual,5)))
    SET ce_where = build(trim(ce_where),temp->proc_qual[x].task_assay_cd,",")
   ELSE
    SET ce_where = build(trim(ce_where),temp->proc_qual[x].task_assay_cd)
   ENDIF
 ENDFOR
 SET ce_where = concat("ce.task_assay_cd in(",trim(ce_where),")")
 SELECT INTO "nl:"
  doc_name = trim(concat(trim(p2.name_full_formatted),cnvtstring(p2.person_id,19,0))), type_code =
  temp->type_qual[d.seq].type_code, pat_name = trim(concat(trim(p.name_full_formatted),cnvtstring(p
     .person_id,19,0))),
  pc_accession_nbr = decode(pc.seq,uar_fmt_accession(pc.accession_nbr,size(pc.accession_nbr,1)),"")
  FROM (dummyt d  WITH seq = 3),
   ap_ft_event fte,
   pathology_case pc,
   person p,
   cyto_screening_event cse,
   code_value cv,
   prsnl p2
  PLAN (d
   WHERE (((1=temp->type_qual[d.seq].type_code)
    AND (1=request->print_init)) OR ((((2=temp->type_qual[d.seq].type_code)
    AND (1=request->print_first)) OR ((3=temp->type_qual[d.seq].type_code)
    AND (1=request->print_final))) )) )
   JOIN (fte
   WHERE (request->followup_type_cd=fte.followup_type_cd)
    AND fte.expected_term_dt >= cnvtdatetime(request->date_from)
    AND fte.term_dt_tm = null
    AND (((1=temp->type_qual[d.seq].type_code)
    AND fte.initial_notif_dt_tm BETWEEN cnvtdatetime(request->date_from) AND cnvtdatetime(request->
    date_to)
    AND (((request->mode=1)) OR ((temp->doctor_notification_ind > 0)
    AND  NOT (fte.initial_notif_print_flag IN (1, 3)))) ) OR ((((2=temp->type_qual[d.seq].type_code)
    AND fte.first_overdue_dt_tm BETWEEN cnvtdatetime(request->date_from) AND cnvtdatetime(request->
    date_to)
    AND (((request->mode=1)) OR ((temp->doctor_first_overdue_ind > 0)
    AND  NOT (fte.first_overdue_print_flag IN (1, 3)))) ) OR ((3=temp->type_qual[d.seq].type_code)
    AND fte.final_overdue_dt_tm BETWEEN cnvtdatetime(request->date_from) AND cnvtdatetime(request->
    date_to)
    AND (((request->mode=1)) OR ((temp->doctor_final_overdue_ind > 0)
    AND  NOT (fte.final_overdue_print_flag IN (1, 3)))) )) )) )
   JOIN (pc
   WHERE fte.case_id=pc.case_id
    AND parser(
    IF ((request->doctor_id > 0)) "request->doctor_id   = pc.requesting_physician_id"
    ELSE "0                 = 0"
    ENDIF
    )
    AND parser(sprefixparser))
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (cse
   WHERE pc.case_id=cse.case_id
    AND 1=cse.verify_ind)
   JOIN (cv
   WHERE 1314=cv.code_set
    AND cse.diagnostic_category_cd=cv.code_value)
   JOIN (p2
   WHERE pc.requesting_physician_id=p2.person_id)
  ORDER BY doc_name, type_code, pat_name
  HEAD REPORT
   doc_cnt = 0
  HEAD doc_name
   pcnt = 0, pcnt2 = 0, pcnt3 = 0,
   doc_cnt += 1
   IF (mod(doc_cnt,10)=1)
    stat = alterlist(temp->doc_qual,(doc_cnt+ 9))
   ENDIF
   temp->doc_qual[doc_cnt].doc_id = pc.requesting_physician_id, temp->doc_qual[doc_cnt].doc_name =
   IF (pc.requesting_physician_id=0) "<UNKNOWN>"
   ELSE p2.name_full_formatted
   ENDIF
  DETAIL
   CASE (type_code)
    OF 1:
     pcnt += 1,stat = alterlist(temp->doc_qual[doc_cnt].123_qual[1].pat_qual,pcnt),
     IF ((pcnt > temp->max_pat_cnt))
      temp->max_pat_cnt = pcnt
     ENDIF
     ,temp->doc_qual[doc_cnt].123_qual[1].pat_qual[pcnt].fte_event_id = fte.followup_event_id,temp->
     doc_qual[doc_cnt].123_qual[1].pat_qual[pcnt].accession_nbr = pc_accession_nbr,temp->doc_qual[
     doc_cnt].123_qual[1].pat_qual[pcnt].name_full_formatted = p.name_full_formatted,
     temp->doc_qual[doc_cnt].123_qual[1].pat_qual[pcnt].encntr_id = pc.encntr_id,temp->doc_qual[
     doc_cnt].123_qual[1].pat_qual[pcnt].diagnostic_category_cd = cse.diagnostic_category_cd,temp->
     doc_qual[doc_cnt].123_qual[1].pat_qual[pcnt].display = cv.display,
     temp->doc_qual[doc_cnt].123_qual[1].pat_qual[pcnt].description = cv.description,temp->doc_qual[
     doc_cnt].123_qual[1].pat_qual[pcnt].due_date = format(cnvtdatetime(fte.initial_notif_dt_tm),
      "@SHORTDATE;;D"),temp->doc_qual[doc_cnt].123_qual[1].pat_qual[pcnt].verified_date = format(
      cnvtdatetime(pc.main_report_cmplete_dt_tm),"@SHORTDATE;;D"),
     temp->doc_qual[doc_cnt].123_qual[1].pat_qual[pcnt].age = formatage(p.birth_dt_tm,p
      .deceased_dt_tm,"LABRPTAGE"),temp->doc_qual[doc_cnt].123_qual[1].pat_qual[pcnt].event_id = cse
     .event_id
    OF 2:
     pcnt2 += 1,stat = alterlist(temp->doc_qual[doc_cnt].123_qual[2].pat_qual,pcnt2),
     IF ((pcnt2 > temp->max_pat_cnt))
      temp->max_pat_cnt = pcnt2
     ENDIF
     ,temp->doc_qual[doc_cnt].123_qual[2].pat_qual[pcnt2].fte_event_id = fte.followup_event_id,temp->
     doc_qual[doc_cnt].123_qual[2].pat_qual[pcnt2].accession_nbr = pc_accession_nbr,temp->doc_qual[
     doc_cnt].123_qual[2].pat_qual[pcnt2].name_full_formatted = p.name_full_formatted,
     temp->doc_qual[doc_cnt].123_qual[2].pat_qual[pcnt2].encntr_id = pc.encntr_id,temp->doc_qual[
     doc_cnt].123_qual[2].pat_qual[pcnt2].diagnostic_category_cd = cse.diagnostic_category_cd,temp->
     doc_qual[doc_cnt].123_qual[2].pat_qual[pcnt2].display = cv.display,
     temp->doc_qual[doc_cnt].123_qual[2].pat_qual[pcnt2].description = cv.description,temp->doc_qual[
     doc_cnt].123_qual[2].pat_qual[pcnt2].due_date = format(cnvtdatetime(fte.initial_notif_dt_tm),
      "@SHORTDATE;;D"),temp->doc_qual[doc_cnt].123_qual[2].pat_qual[pcnt2].verified_date = format(
      cnvtdatetime(pc.main_report_cmplete_dt_tm),"@SHORTDATE;;D"),
     temp->doc_qual[doc_cnt].123_qual[2].pat_qual[pcnt2].age = formatage(p.birth_dt_tm,p
      .deceased_dt_tm,"LABRPTAGE"),temp->doc_qual[doc_cnt].123_qual[2].pat_qual[pcnt2].event_id = cse
     .event_id
    OF 3:
     pcnt3 += 1,stat = alterlist(temp->doc_qual[doc_cnt].123_qual[3].pat_qual,pcnt3),
     IF ((pcnt3 > temp->max_pat_cnt))
      temp->max_pat_cnt = pcnt3
     ENDIF
     ,temp->doc_qual[doc_cnt].123_qual[3].pat_qual[pcnt3].fte_event_id = fte.followup_event_id,temp->
     doc_qual[doc_cnt].123_qual[3].pat_qual[pcnt3].accession_nbr = pc_accession_nbr,temp->doc_qual[
     doc_cnt].123_qual[3].pat_qual[pcnt3].name_full_formatted = p.name_full_formatted,
     temp->doc_qual[doc_cnt].123_qual[3].pat_qual[pcnt3].encntr_id = pc.encntr_id,temp->doc_qual[
     doc_cnt].123_qual[3].pat_qual[pcnt3].diagnostic_category_cd = cse.diagnostic_category_cd,temp->
     doc_qual[doc_cnt].123_qual[3].pat_qual[pcnt3].display = cv.display,
     temp->doc_qual[doc_cnt].123_qual[3].pat_qual[pcnt3].description = cv.description,temp->doc_qual[
     doc_cnt].123_qual[3].pat_qual[pcnt3].due_date = format(cnvtdatetime(fte.initial_notif_dt_tm),
      "@SHORTDATE;;D"),temp->doc_qual[doc_cnt].123_qual[3].pat_qual[pcnt3].verified_date = format(
      cnvtdatetime(pc.main_report_cmplete_dt_tm),"@SHORTDATE;;D"),
     temp->doc_qual[doc_cnt].123_qual[3].pat_qual[pcnt3].age = formatage(p.birth_dt_tm,p
      .deceased_dt_tm,"LABRPTAGE"),temp->doc_qual[doc_cnt].123_qual[3].pat_qual[pcnt3].event_id = cse
     .event_id
   ENDCASE
  FOOT REPORT
   stat = alterlist(temp->doc_qual,doc_cnt)
  WITH nocounter
 ;end select
 IF (doc_cnt=0)
  SET doc_cnt = 1
  GO TO report_maker
 ENDIF
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM (dummyt d1  WITH seq = value(doc_cnt)),
   (dummyt d2  WITH seq = 3),
   (dummyt d3  WITH seq = value(temp->max_pat_cnt)),
   (dummyt d4  WITH seq = 1),
   encntr_alias ea
  PLAN (d1)
   JOIN (d2)
   JOIN (d3
   WHERE d3.seq <= cnvtint(size(temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual,5)))
   JOIN (d4)
   JOIN (ea
   WHERE (temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual[d3.seq].encntr_id=ea.encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   IF ((temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual[d3.seq].encntr_id=ea.encntr_id))
    temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual[d3.seq].alias = frmt_mrn
   ELSE
    temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual[d3.seq].alias = "Unknown"
   ENDIF
  WITH nocounter, outerjoin = d4
 ;end select
 SELECT INTO "nl:"
  addr.street_addr
  FROM (dummyt d1  WITH seq = value(doc_cnt)),
   address addr
  PLAN (d1
   WHERE (temp->doc_qual[d1.seq].doc_id > 0))
   JOIN (addr
   WHERE (temp->doc_qual[d1.seq].doc_id=addr.parent_entity_id)
    AND addr.parent_entity_name="PERSON"
    AND addr.address_type_cd=address_type_cd
    AND addr.active_ind=1
    AND addr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND addr.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   temp->doc_qual[d1.seq].doc_addr1 = trim(addr.street_addr), temp->doc_qual[d1.seq].doc_addr2 = trim
   (addr.street_addr2), temp->doc_qual[d1.seq].doc_addr3 = trim(addr.street_addr3),
   temp->doc_qual[d1.seq].doc_city = trim(addr.city), temp->doc_qual[d1.seq].doc_st = trim(addr.state
    ), temp->doc_qual[d1.seq].doc_zip = addr.zipcode
  WITH nocounter
 ;end select
 IF ((request->print_text=1))
  SELECT INTO "nl:"
   d3.seq
   FROM (dummyt d1  WITH seq = value(doc_cnt)),
    (dummyt d2  WITH seq = 3),
    (dummyt d3  WITH seq = value(temp->max_pat_cnt)),
    clinical_event ce,
    ce_blob_result cebr
   PLAN (d1)
    JOIN (d2)
    JOIN (d3
    WHERE d3.seq <= cnvtint(size(temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual,5)))
    JOIN (ce
    WHERE (temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual[d3.seq].event_id=ce.parent_event_id)
     AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND parser(trim(ce_where)))
    JOIN (cebr
    WHERE ce.event_id=cebr.event_id
     AND cebr.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND cebr.storage_cd=blob_cd)
   HEAD REPORT
    dtcnt = 0
   HEAD d1.seq
    dtcnt = 0
   HEAD d2.seq
    dtcnt = 0
   HEAD d3.seq
    recdate->datetime = cnvtdatetimeutc(cebr.valid_from_dt_tm), blobout = "", blobsize =
    uar_get_ceblobsize(cebr.event_id,recdate)
    IF (blobsize > 0)
     stat = memrealloc(blobout,1,build("C",blobsize)), status = uar_get_ceblob(cebr.event_id,recdate,
      blobout,blobsize)
    ENDIF
    stat = alterlist(temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual[d3.seq].rpt_qual,1), temp->
    doc_qual[d1.seq].123_qual[d2.seq].pat_qual[d3.seq].rpt_qual[1].detail_text = blobout
   WITH nocounter
  ;end select
 ENDIF
#report_maker
 EXECUTE cpm_create_file_name_logical "apfol", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  dd.seq, d.seq
  FROM (dummyt dd  WITH seq = value(doc_cnt)),
   (dummyt d  WITH seq = 3)
  PLAN (dd
   WHERE size(temp->doc_qual,5) > 0)
   JOIN (d
   WHERE d.seq > 0
    AND ((d.seq=1
    AND (request->print_init=1)
    AND (temp->doctor_notification_ind=1)) OR (((d.seq=2
    AND (request->print_first=1)
    AND (temp->doctor_first_overdue_ind=1)) OR (d.seq=3
    AND (request->print_final=1)
    AND (temp->doctor_final_overdue_ind=1))) )) )
  HEAD REPORT
   line1 = fillstring(125,"-"), text = fillstring(100," "), first_time = 0
  HEAD PAGE
   row + 1, col 0, captions->rpt_nm,
   col 56,
   CALL center(temp->site_name,row,132), col 110,
   captions->dt, col 117, curdate"@SHORTDATE;;D",
   row + 1, col 0, captions->dir,
   col 110, captions->tm, col 117,
   curtime"@TIMENOSECONDS;;M", row + 1, col 112,
   captions->bye, col 117, request->curuser,
   row + 1, col 110, captions->pg,
   col 117, curpage"###", row + 2,
   col 52,
   CALL center("FOLLOW-UP TRACKING NOTIFICATION",row,132), row + 1,
   col 0, captions->pre, col 15,
   last_pref = value(size(temp_pref->pref_qual,5))
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
  HEAD dd.seq
   IF (first_time=0)
    first_time = 1
   ELSE
    BREAK
   ENDIF
  DETAIL
   IF (d.seq=1)
    CALL center(build(captions->no_pat," ",captions->init),row,132)
   ELSEIF (d.seq=2)
    CALL center(build(captions->no_pat," ",captions->in_over),row,132)
   ELSEIF (d.seq=3)
    CALL center(build(captions->no_pat," ",captions->over),row,132)
   ENDIF
   col 0,
   CALL center("                                                                                   ",
   row,132), col 19,
   captions->too, col 93, captions->fro,
   row + 1, col 19
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_name)) > 0)
    temp->doc_qual[dd.seq].doc_name"########################################"
   ENDIF
   col 93
   IF (textlen(trim(temp->site_name)) > 0)
    temp->site_name
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_addr2, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_addr3, col 93, temp->site_city,
    ", ", temp->site_st, col + 2,
    temp->site_zip, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_addr2, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_addr3, col 93, temp->site_addr3,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_city,
    ", ", temp->doc_qual[dd.seq].doc_st, col + 2,
    temp->doc_qual[dd.seq].doc_zip, col 93, temp->site_city,
    ", ", temp->site_st, col + 2,
    temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_addr3, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_addr3, col 93, temp->site_city,
    ", ", temp->site_st, col + 2,
    temp->site_zip, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_addr3, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_addr3, col 93, temp->site_city,
    ", ", temp->site_st, col + 2,
    temp->site_zip, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr3, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr2, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr2, row + 1,
    col 93, temp->site_addr3, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr3, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr3, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr3, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_addr2, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_addr2, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, col 93,
    temp->site_addr3, row + 1, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_addr3, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_addr3, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr3, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr2, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_addr2, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_addr2, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, col 93,
    temp->site_addr3, row + 1, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_addr3, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_addr3, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    col 93, temp->site_addr3, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr2, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr2, row + 1,
    col 93, temp->site_addr3, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr3, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr3, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr3, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_addr2, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_addr2, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, col 93,
    temp->site_addr3, row + 1, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_addr3, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_addr3, row + 1, col 19,
    temp->doc_qual[dd.seq].doc_city, ", ", temp->doc_qual[dd.seq].doc_st,
    col + 2, temp->doc_qual[dd.seq].doc_zip, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    col 93, temp->site_addr3, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_addr3, col 93,
    temp->site_city, ", ", temp->site_st,
    col + 2, temp->site_zip, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr3,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr3,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr2, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr3,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr2, row + 1,
    col 93, temp->site_addr3, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr3,
    col 93, temp->site_addr1, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr3, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr3,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr3,
    col 93, temp->site_addr2, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_addr3, row + 1,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr3,
    col 93, temp->site_addr3, row + 1,
    col 19, temp->doc_qual[dd.seq].doc_city, ", ",
    temp->doc_qual[dd.seq].doc_st, col + 2, temp->doc_qual[dd.seq].doc_zip,
    col 93, temp->site_city, ", ",
    temp->site_st, col + 2, temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 93, temp->site_addr1,
    row + 1, col 93, temp->site_city,
    ", ", temp->site_st, col + 2,
    temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 93, temp->site_addr1,
    row + 1, col 93, temp->site_addr2,
    row + 1, col 93, temp->site_city,
    ", ", temp->site_st, col + 2,
    temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 93, temp->site_addr1,
    row + 1, col 93, temp->site_addr2,
    row + 1, col 93, temp->site_addr3,
    row + 1, col 93, temp->site_city,
    ", ", temp->site_st, col + 2,
    temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1)) > 0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 93, temp->site_addr1,
    row + 1, col 93, temp->site_addr3,
    row + 1, col 93, temp->site_city,
    ", ", temp->site_st, col + 2,
    temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 93, temp->site_addr2,
    row + 1, col 93, temp->site_city,
    ", ", temp->site_st, col + 2,
    temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2)) > 0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 93, temp->site_addr2,
    row + 1, col 93, temp->site_addr3,
    row + 1, col 93, temp->site_city,
    ", ", temp->site_st, col + 2,
    temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3)) > 0)
    row + 1, col 93, temp->site_addr3,
    row + 1, col 93, temp->site_city,
    ", ", temp->site_st, col + 2,
    temp->site_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_city,
    ", ", temp->doc_qual[dd.seq].doc_st, col + 2,
    temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_city,
    ", ", temp->doc_qual[dd.seq].doc_st, col + 2,
    temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr3,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_city,
    ", ", temp->doc_qual[dd.seq].doc_st, col + 2,
    temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr1,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr3,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_city,
    ", ", temp->doc_qual[dd.seq].doc_st, col + 2,
    temp->doc_qual[dd.seq].doc_zip, col 93, temp->site_addr3
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3))=0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_city,
    ", ", temp->doc_qual[dd.seq].doc_st, col + 2,
    temp->doc_qual[dd.seq].doc_zip
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2)) > 0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr2,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr3,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_city,
    ", ", temp->doc_qual[dd.seq].doc_st, col + 2,
    temp->doc_qual[dd.seq].doc_zip, col 93, temp->site_addr3
   ENDIF
   IF (textlen(trim(temp->doc_qual[dd.seq].doc_addr1))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr2))=0
    AND textlen(trim(temp->doc_qual[dd.seq].doc_addr3)) > 0
    AND textlen(trim(temp->site_addr1))=0
    AND textlen(trim(temp->site_addr2))=0
    AND textlen(trim(temp->site_addr3))=0)
    row + 1, col 19, temp->doc_qual[dd.seq].doc_addr3,
    row + 1, col 19, temp->doc_qual[dd.seq].doc_city,
    ", ", temp->doc_qual[dd.seq].doc_st, col + 2,
    temp->doc_qual[dd.seq].doc_zip
   ENDIF
   row + 2, line1, row + 1
   IF (d.seq=1)
    CALL center(captions->init,row,132)
   ELSEIF (d.seq=2)
    CALL center(captions->in_over,row,132)
   ELSEIF (d.seq=3)
    CALL center(captions->over,row,132)
   ENDIF
   row + 1, line1, row + 1
   FOR (tcnt = 1 TO cnvtint(size(temp->type_qual[d.seq].doc_template_qual,5)))
     row + 1, col 10, temp->type_qual[d.seq].doc_template_qual[tcnt].dtext
   ENDFOR
   row + 1, col 0, line1,
   row + 1, col 0, captions->pat,
   col 26, captions->id, col 47,
   captions->ag, col 51, captions->cse,
   col 71, captions->ver, col 81,
   captions->ver_as, col 117, captions->due,
   row + 1, line1, row + 1,
   col 0,
   CALL center(captions->no_qual,row,132)
   FOR (pcnt = 1 TO cnvtint(size(temp->doc_qual[dd.seq].123_qual[d.seq].pat_qual,5)))
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
     col 0,
     CALL center("                             ",row,132), col 0,
     temp->doc_qual[dd.seq].123_qual[d.seq].pat_qual[pcnt].name_full_formatted, col 26, temp->
     doc_qual[dd.seq].123_qual[d.seq].pat_qual[pcnt].alias,
     col 47, temp->doc_qual[dd.seq].123_qual[d.seq].pat_qual[pcnt].age"###", col 51,
     temp->doc_qual[dd.seq].123_qual[d.seq].pat_qual[pcnt].accession_nbr, col 71, temp->doc_qual[dd
     .seq].123_qual[d.seq].pat_qual[pcnt].verified_date,
     col 81, temp->doc_qual[dd.seq].123_qual[d.seq].pat_qual[pcnt].description, col 116,
     temp->doc_qual[dd.seq].123_qual[d.seq].pat_qual[pcnt].due_date, row + 1
     IF ((request->print_text=1))
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
      col 5, "REPORT:",
      CALL rtf_to_text(trim(temp->doc_qual[dd.seq].123_qual[d.seq].pat_qual[pcnt].rpt_qual[1].
       detail_text),1,80)
      FOR (z = 1 TO size(tmptext->qual,5))
        col 15, tmptext->qual[z].text, row + 1
        IF (((row+ 10) > maxrow))
         BREAK
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   row + 2
   IF (d.seq=1)
    col 0,
    CALL center(captions->end_init,row,132)
   ELSEIF (d.seq=2)
    col 0,
    CALL center(captions->end_in_over,row,132)
   ELSEIF (d.seq=3)
    col 0,
    CALL center(captions->end_over,row,132)
   ENDIF
   IF (d.seq < 3)
    BREAK
   ENDIF
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rpt,
   wk = format(curdate,"@WEEKDAYABBREV;;D"), dy = format(curdate,"@MEDIUMDATE4YR;;D"), today = concat
   (wk," ",dy),
   col 53, today, col 110,
   captions->pg, col 117, curpage"###",
   row + 1, col 0
   IF ((request->mode=1))
    captions->prt
   ENDIF
   col 35, captions->cont, col 60
   IF (size(temp->doc_qual,5) > 0)
    temp->doc_qual[dd.seq].doc_name"########################################"
   ENDIF
  FOOT REPORT
   col 35, captions->end_rpt, col 60
   IF (size(temp->doc_qual,5) > 0)
    temp->doc_qual[dd.seq].doc_name"########################################"
   ENDIF
  WITH nocounter, maxrow = 63, maxcol = 132,
   nullreport, compress
 ;end select
#end_rpt
 IF (doc_cnt > 0
  AND (temp->max_pat_cnt > 0))
  SELECT INTO "nl:"
   fte.followup_event_id
   FROM ap_ft_event fte,
    (dummyt d1  WITH seq = value(doc_cnt)),
    (dummyt d2  WITH seq = 3),
    (dummyt d3  WITH seq = value(temp->max_pat_cnt))
   PLAN (d1
    WHERE size(temp->doc_qual,5) > 0)
    JOIN (d2)
    JOIN (d3
    WHERE d3.seq <= cnvtint(size(temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual,5)))
    JOIN (fte
    WHERE (temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual[d3.seq].fte_event_id=fte
    .followup_event_id))
   WITH nocounter, forupdate(fte)
  ;end select
  UPDATE  FROM ap_ft_event fte,
    (dummyt d1  WITH seq = value(doc_cnt)),
    (dummyt d2  WITH seq = 3),
    (dummyt d3  WITH seq = value(temp->max_pat_cnt))
   SET fte.initial_notif_print_flag =
    IF (d2.seq=1) 1
    ELSE fte.initial_notif_print_flag
    ENDIF
    , fte.first_overdue_print_flag =
    IF (d2.seq=2) 1
    ELSE fte.first_overdue_print_flag
    ENDIF
    , fte.final_overdue_print_flag =
    IF (d2.seq=3) 1
    ELSE fte.final_overdue_print_flag
    ENDIF
    ,
    fte.updt_dt_tm = cnvtdatetime(curdate,curtime), fte.updt_id = reqinfo->updt_id, fte.updt_task =
    reqinfo->updt_task,
    fte.updt_applctx = reqinfo->updt_applctx, fte.updt_cnt = (fte.updt_cnt+ 1)
   PLAN (d1
    WHERE size(temp->doc_qual,5) > 0)
    JOIN (d2)
    JOIN (d3
    WHERE d3.seq <= cnvtint(size(temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual,5)))
    JOIN (fte
    WHERE (temp->doc_qual[d1.seq].123_qual[d2.seq].pat_qual[d3.seq].fte_event_id=fte
    .followup_event_id))
   WITH nocounter
  ;end update
 ENDIF
 SET lprefixes = 0
 SET sprefixparser = concat("expand(lPrefixes,1,value(size(temp_pref->pref_qual,5)),",
  "pc.prefix_id,temp_pref->pref_qual[lPrefixes].prefix_cd)")
 IF ((request->mode=0))
  SELECT INTO "nl:"
   fte.followup_type_cd
   FROM ap_ft_event fte
   PLAN (fte
    WHERE (request->followup_type_cd=fte.followup_type_cd)
     AND fte.term_dt_tm = null
     AND fte.expected_term_dt BETWEEN cnvtdatetime(request->date_from) AND cnvtdatetime(request->
     date_to)
     AND fte.case_id != 0)
   HEAD REPORT
    fte_cnt = 0
   DETAIL
    fte_cnt += 1
    IF (mod(fte_cnt,10)=1)
     stat = alterlist(temp_fte->qual,(fte_cnt+ 9))
    ENDIF
    temp_fte->qual[fte_cnt].followup_event_id = fte.followup_event_id, temp_fte->qual[fte_cnt].
    case_id = fte.case_id, temp_fte->qual[fte_cnt].term_long_text_id = fte.term_long_text_id,
    temp_fte->qual[fte_cnt].initial_notif_dt_tm = fte.initial_notif_dt_tm
   FOOT REPORT
    stat = alterlist(temp_fte->qual,fte_cnt)
   WITH nocounter, forupdate(fte)
  ;end select
  IF (curqual != 0)
   SELECT INTO "nl:"
    pc.accession_nbr, pc_accession_nbr = decode(pc.seq,uar_fmt_accession(pc.accession_nbr,size(pc
       .accession_nbr,1)),""), pc.requesting_physician_id,
    pc.main_report_cmplete_dt_tm, p2.name_full_formatted, p2.birth_dt_tm,
    p1.name_full_formatted
    FROM (dummyt d  WITH seq = value(fte_cnt)),
     pathology_case pc,
     person p2,
     dummyt d1,
     prsnl p1
    PLAN (d)
     JOIN (pc
     WHERE (temp_fte->qual[d.seq].case_id=pc.case_id)
      AND parser(sprefixparser))
     JOIN (p2
     WHERE pc.person_id=p2.person_id)
     JOIN (d1
     WHERE 1=d1.seq)
     JOIN (p1
     WHERE pc.requesting_physician_id=p1.person_id)
    HEAD REPORT
     auto_cnt = 0
    DETAIL
     auto_cnt += 1
     IF (mod(auto_cnt,10)=1)
      stat = alterlist(temp->auto_qual,(auto_cnt+ 9))
     ENDIF
     temp->auto_qual[auto_cnt].event_id = temp_fte->qual[d.seq].followup_event_id, temp->auto_qual[
     auto_cnt].term_long_text_id = temp_fte->qual[d.seq].term_long_text_id, temp->auto_qual[auto_cnt]
     .name_full_formatted = p2.name_full_formatted,
     temp->auto_qual[auto_cnt].alias = "Unknown", temp->auto_qual[auto_cnt].accession_nbr =
     pc_accession_nbr, temp->auto_qual[auto_cnt].encntr_id = pc.encntr_id,
     temp->auto_qual[auto_cnt].doc_name =
     IF (pc.requesting_physician_id=0) "<UNKNOWN>"
     ELSE p1.name_full_formatted
     ENDIF
     , temp->auto_qual[auto_cnt].verified_date = format(cnvtdatetime(pc.main_report_cmplete_dt_tm),
      "@SHORTDATE;;D"), temp->auto_qual[auto_cnt].due_date = format(cnvtdatetime(temp_fte->qual[d.seq
       ].initial_notif_dt_tm),"@SHORTDATE;;D")
    FOOT REPORT
     stat = alterlist(temp->auto_qual,auto_cnt)
    WITH nocounter, outerjoin = d1
   ;end select
  ENDIF
  IF (auto_cnt=0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
   FROM (dummyt d1  WITH seq = value(auto_cnt)),
    encntr_alias ea
   PLAN (d1)
    JOIN (ea
    WHERE (temp->auto_qual[d1.seq].encntr_id=ea.encntr_id)
     AND ea.encntr_alias_type_cd=mrn_alias_type_cd
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    temp->auto_qual[d1.seq].alias = frmt_mrn
   WITH nocounter
  ;end select
  SET nextseqloop = 0
  FOR (nextseqloop = 1 TO value(auto_cnt))
   SELECT INTO "nl:"
    seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
    FROM dual
    WHERE (temp->auto_qual[nextseqloop].term_long_text_id=0)
    DETAIL
     temp->auto_qual[nextseqloop].term_long_text_id = seq_nbr
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL handle_errors("NEWSEQ","Z","TABLE","REFERENCE_SEQ")
    SET reply->status_data.status = "F"
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ENDFOR
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = value(auto_cnt))
   SET lt.long_text_id = temp->auto_qual[d.seq].term_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm =
    cnvtdatetime(sysdate),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(sysdate),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "AP_FT_EVENT", lt
    .parent_entity_id = temp->auto_qual[d.seq].event_id,
    lt.long_text = "AUTO TERMINATED BY SYSTEM"
   PLAN (d)
    JOIN (lt)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","LONG_TEXT")
   SET reply->status_data.status = "F"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM ap_ft_event fte,
    (dummyt d  WITH seq = value(auto_cnt))
   SET fte.term_id = 0, fte.term_dt_tm = cnvtdatetime(curdate,curtime), fte.term_reason_cd = 0,
    fte.term_long_text_id = temp->auto_qual[d.seq].term_long_text_id, fte.updt_dt_tm = cnvtdatetime(
     curdate,curtime), fte.updt_id = reqinfo->updt_id,
    fte.updt_task = reqinfo->updt_task, fte.updt_applctx = reqinfo->updt_applctx, fte.updt_cnt = (fte
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (fte
    WHERE (temp->auto_qual[d.seq].event_id=fte.followup_event_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","AP_FT_EVENT")
   SET reply->status_data.status = "F"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  SELECT INTO value(reply->print_status_data.print_filename)
   x = 0
   HEAD REPORT
    line1 = fillstring(125,"-"), line2 = fillstring(116,"-"), first_time = 0
   HEAD PAGE
    row + 1, col 0, captions->rpt,
    col 56, col 110, captions->dt,
    col 117, curdate"@SHORTDATE;;D", row + 1,
    col 0, captions->dir, col 110,
    captions->tm, col 117, curtime"@TIMENOSECONDS;;M",
    row + 1, col 52,
    CALL center(captions->term,row,132),
    col 112, captions->bye, col 117,
    request->curuser, row + 1, col 110,
    captions->pg, col 117, curpage"###",
    row + 2, col 0, captions->pat,
    col 28, captions->id, col 50,
    captions->cse, col 71, captions->req,
    col 98, captions->ver, col 109,
    captions->due
   DETAIL
    row + 1, line1, row + 1,
    col 0,
    CALL center(captions->no_term,row,132)
    FOR (acnt = 1 TO cnvtint(size(temp->auto_qual,5)))
      col 0,
      CALL center("                             ",row,132), col 0,
      temp->auto_qual[acnt].name_full_formatted, col 28, temp->auto_qual[acnt].alias,
      col 50, temp->auto_qual[acnt].accession_nbr, col 71,
      temp->auto_qual[acnt].doc_name"########################################", col 98, temp->
      auto_qual[acnt].verified_date,
      col 109, temp->auto_qual[acnt].due_date, row + 1
    ENDFOR
   WITH nocounter, compress, append
  ;end select
 ENDIF
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
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->ops_event = concat(trim(reply->status_data.subeventstatus[1].operationname),trim(reply->
    status_data.subeventstatus[1].operationstatus),trim(reply->status_data.subeventstatus[1].
    targetobjectname),trim(reply->status_data.subeventstatus[1].targetobjectvalue))
 ELSE
  SET reqinfo->commit_ind = 1
  IF ((reply->status_data.status="F"))
   SET reply->status_data.status = "S"
  ENDIF
  IF (textlen(trim(request->output_dist)) > 0)
   IF (textlen(trim(reply->print_status_data.print_dir_and_filename)) > 0)
    SET spool value(reply->print_status_data.print_dir_and_filename) value(printer) WITH copy = value
    (copies)
   ENDIF
   SET reply->ops_event = concat("Successful ",trim(reply->print_status_data.print_dir_and_filename))
  ENDIF
 ENDIF
 FREE SET temp_fte
#end_script
END GO
