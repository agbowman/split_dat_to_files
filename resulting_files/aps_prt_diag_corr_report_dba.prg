CREATE PROGRAM aps_prt_diag_corr_report:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 unassigned = vc
   1 apsprtdiagcorrrpt = vc
   1 pathnetap = vc
   1 ddate = vc
   1 ddirectory = vc
   1 ttime = vc
   1 diagcorrrpt = vc
   1 bby2 = vc
   1 ppage = vc
   1 study = vc
   1 prefixes = vc
   1 allprefixes = vc
   1 sspecimens = vc
   1 compspec = vc
   1 allspecimens = vc
   1 allpathologists = vc
   1 includestatsummary = vc
   1 excludestatsummary = vc
   1 includecaseinfo = vc
   1 excludecaseinfo = vc
   1 includerpttext = vc
   1 excluderpttext = vc
   1 statsummary = vc
   1 correlated = vc
   1 disagreements = vc
   1 correlation = vc
   1 ttotal2 = vc
   1 events = vc
   1 agreements = vc
   1 minor = vc
   1 major = vc
   1 other = vc
   1 incomplete = vc
   1 pathologist2 = vc
   1 cases3 = vc
   1 ddate6 = vc
   1 ttotal = vc
   1 caseinformation = vc
   1 nocasesmatchcrit = vc
   1 nopathselected = vc
   1 corractivity = vc
   1 ccase2 = vc
   1 compareto = vc
   1 bby = vc
   1 finaleval = vc
   1 discrepancy = vc
   1 reason = vc
   1 investigation = vc
   1 resolution = vc
   1 na = vc
   1 ggroup = vc
   1 corrcomment = vc
   1 ccase = vc
   1 rreport = vc
   1 groupname = vc
   1 beginningdate = vc
   1 endingdate = vc
   1 pathologist = vc
   1 continued = vc
   1 section = vc
 )
 SET captions->unassigned = uar_i18ngetmessage(i18nhandle,"d2","Unassigned")
 SET captions->apsprtdiagcorrrpt = uar_i18ngetmessage(i18nhandle,"h1",
  "REPORT:APS_PRT_DIAG_CORR_REPORT.PRG")
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h2","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"h3","DATE:")
 SET captions->ddirectory = uar_i18ngetmessage(i18nhandle,"h4","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h5","TIME:")
 SET captions->diagcorrrpt = uar_i18ngetmessage(i18nhandle,"h6","DIAGNOSTIC CORRELATION REPORT")
 SET captions->bby2 = uar_i18ngetmessage(i18nhandle,"h7","BY:")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h8","PAGE:")
 SET captions->study = uar_i18ngetmessage(i18nhandle,"h9","STUDY:")
 SET captions->prefixes = uar_i18ngetmessage(i18nhandle,"h10","PREFIX(ES):")
 SET captions->allprefixes = uar_i18ngetmessage(i18nhandle,"h11","ALL PREFIXES")
 SET captions->sspecimens = uar_i18ngetmessage(i18nhandle,"h12","SPECIMENS")
 SET captions->compspec = uar_i18ngetmessage(i18nhandle,"h13","COMP. SPEC.(S):")
 SET captions->allspecimens = uar_i18ngetmessage(i18nhandle,"h14","ALL SPECIMENS")
 SET captions->allpathologists = uar_i18ngetmessage(i18nhandle,"h15","ALL PATHOLOGISTS")
 SET captions->includestatsummary = uar_i18ngetmessage(i18nhandle,"h16",
  " INCLUDE STATISTICAL SUMMARY")
 SET captions->excludestatsummary = uar_i18ngetmessage(i18nhandle,"h17","EXCLUDE STATISTICAL SUMMARY"
  )
 SET captions->includecaseinfo = uar_i18ngetmessage(i18nhandle,"h18","INCLUDE CASE INFORMATION")
 SET captions->excludecaseinfo = uar_i18ngetmessage(i18nhandle,"h19","EXCLUDE CASE INFORMATION")
 SET captions->includerpttext = uar_i18ngetmessage(i18nhandle,"h20","INCLUDE REPORT TEXT")
 SET captions->excluderpttext = uar_i18ngetmessage(i18nhandle,"h21","EXCLUDE REPORT TEXT")
 SET captions->statsummary = uar_i18ngetmessage(i18nhandle,"h22","STATISTICAL SUMMARY")
 SET captions->correlated = uar_i18ngetmessage(i18nhandle,"h23","CORRELATED")
 SET captions->disagreements = uar_i18ngetmessage(i18nhandle,"h24","DISAGREEMENTS")
 SET captions->correlation = uar_i18ngetmessage(i18nhandle,"h25","CORRELATION")
 SET captions->ttotal2 = uar_i18ngetmessage(i18nhandle,"h26","TOTAL")
 SET captions->events = uar_i18ngetmessage(i18nhandle,"h27","EVENTS")
 SET captions->agreements = uar_i18ngetmessage(i18nhandle,"h28","AGREEMENTS")
 SET captions->minor = uar_i18ngetmessage(i18nhandle,"h29","MINOR")
 SET captions->major = uar_i18ngetmessage(i18nhandle,"h30","MAJOR")
 SET captions->other = uar_i18ngetmessage(i18nhandle,"h31","OTHER")
 SET captions->incomplete = uar_i18ngetmessage(i18nhandle,"h32","INCOMPLETE")
 SET captions->pathologist2 = uar_i18ngetmessage(i18nhandle,"h33","PATHOLOGIST")
 SET captions->cases3 = uar_i18ngetmessage(i18nhandle,"h34","CASES")
 SET captions->ttotal = uar_i18ngetmessage(i18nhandle,"h37","** TOTAL ***")
 SET captions->caseinformation = uar_i18ngetmessage(i18nhandle,"h38","CASE INFORMATION")
 SET captions->nocasesmatchcrit = uar_i18ngetmessage(i18nhandle,"h39",
  "No cases matching selection criteria.")
 SET captions->nopathselected = uar_i18ngetmessage(i18nhandle,"h40","No pathologists selected")
 SET captions->corractivity = uar_i18ngetmessage(i18nhandle,"h41","Correlation activity for:")
 SET captions->ccase2 = uar_i18ngetmessage(i18nhandle,"h42","CASE")
 SET captions->compareto = uar_i18ngetmessage(i18nhandle,"h43","COMPARE TO")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h44","BY")
 SET captions->finaleval = uar_i18ngetmessage(i18nhandle,"h45","FINAL EVAL")
 SET captions->discrepancy = uar_i18ngetmessage(i18nhandle,"h46","DISCREPANCY")
 SET captions->reason = uar_i18ngetmessage(i18nhandle,"h47","REASON")
 SET captions->investigation = uar_i18ngetmessage(i18nhandle,"h48","INVESTIGATION")
 SET captions->resolution = uar_i18ngetmessage(i18nhandle,"h49","RESOLUTION")
 SET captions->na = uar_i18ngetmessage(i18nhandle,"h50","N/A")
 SET captions->ggroup = uar_i18ngetmessage(i18nhandle,"h51","(Group *)")
 SET captions->corrcomment = uar_i18ngetmessage(i18nhandle,"h52","CORRELATION COMMENT:")
 SET captions->ccase = uar_i18ngetmessage(i18nhandle,"h53","CASE:")
 SET captions->rreport = uar_i18ngetmessage(i18nhandle,"h54","REPORT:")
 SET captions->groupname = uar_i18ngetmessage(i18nhandle,"h55","Group name:")
 SET captions->beginningdate = uar_i18ngetmessage(i18nhandle,"h56","BEGINNING DATE:")
 SET captions->endingdate = uar_i18ngetmessage(i18nhandle,"h57","ENDING DATE:")
 SET captions->pathologist = uar_i18ngetmessage(i18nhandle,"h58","PATHOLOGIST:")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET captions->section = uar_i18ngetmessage(i18nhandle,"h59","Section:")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
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
 RECORD stat_temp(
   1 max_cases = i4
   1 max_corr_cases = i4
   1 max_dtas = i4
   1 max_comp_dtas = i4
   1 path_qual[*]
     2 pathologist_id = f8
     2 pathologist_name = vc
     2 correlated_events = i4
     2 agreements = i4
     2 min_disagreements = i4
     2 maj_disagreements = i4
     2 other = i4
     2 incomplete = i4
     2 cases_cnt = i4
     2 corr_evnt_prcnt_cnt = i4
     2 case_qual[*]
       3 print_this_case = c1
       3 valid_case_specs = c1
       3 case_id = f8
       3 case_accession = c18
       3 corr_qual[*]
         4 event_id = f8
         4 individ_or_group = c1
         4 corr_initials = c3
         4 corr_group_name = c60
         4 disagree_reason_cd = f8
         4 disagree_reason_disp = vc
         4 investigation_cd = f8
         4 investigation_disp = vc
         4 resolution_cd = f8
         4 resolution_disp = vc
         4 final_eval_term_id = f8
         4 final_eval_term_disp = vc
         4 final_discrep_term_id = f8
         4 final_discrep_term_disp = vc
         4 long_text_id = f8
         4 long_text_cntr = i4
         4 long_text_qual[*]
           5 text = vc
         4 correlate_accession = c21
         4 correlate_case_id = f8
         4 valid_comp_case_specs = c1
   1 srtd_path_qual[*]
     2 pathologist_id = f8
     2 pathologist_name = vc
     2 correlated_events = i4
     2 agreements = i4
     2 min_disagreements = i4
     2 maj_disagreements = i4
     2 other = i4
     2 incomplete = i4
     2 cases_cnt = i4
     2 corr_evnt_prcnt_cnt = i4
     2 case_qual[*]
       3 print_this_case = c1
       3 valid_case_specs = c1
       3 case_id = f8
       3 case_accession = c18
       3 corr_qual[*]
         4 event_id = f8
         4 individ_or_group = c1
         4 corr_initials = c3
         4 corr_group_name = c60
         4 disagree_reason_cd = f8
         4 disagree_reason_disp = vc
         4 investigation_cd = f8
         4 investigation_disp = vc
         4 resolution_cd = f8
         4 resolution_disp = vc
         4 final_eval_term_id = f8
         4 final_eval_term_disp = vc
         4 final_discrep_term_id = f8
         4 final_discrep_term_disp = vc
         4 long_text_id = f8
         4 long_text_cntr = i4
         4 long_text_qual[*]
           5 text = vc
         4 correlate_accession = c21
         4 correlate_case_id = f8
         4 valid_comp_case_specs = c1
         4 v_comp_cnt = i4
         4 v_comp_qual[*]
           5 ce_event_id = f8
           5 discrete_task_assay_cd = f8
           5 discrete_task_assay_disp = vc
           5 catalog_cd = f8
           5 text_cnt = i4
           5 text_qual[*]
             6 text = vc
       3 v_proc_cnt = i4
       3 v_proc_qual[*]
         4 ce_event_id = f8
         4 discrete_task_assay_cd = f8
         4 discrete_task_assay_disp = vc
         4 text_cnt = i4
         4 catalog_cd = f8
         4 text_qual[*]
           5 text = vc
 )
 RECORD generic_temp(
   1 path_qual[*]
     2 pathologist_name = vc
   1 study_description = vc
   1 across_case_ind = i2
   1 prefix_qual[*]
     2 prefix_id = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_display = vc
   1 specimen_header_qual[*]
     2 specimen_cd = f8
     2 specimen_disp = vc
   1 specimen_header_comp[*]
     2 specimen_cd = f8
     2 specimen_disp = vc
   1 study_id_qual[*]
     2 task_assay_cd = f8
     2 task_assay_disp = vc
 )
 RECORD catalog(
   1 catalog_qual[*]
     2 catalog_cd = f8
     2 catalog_disp = vc
 )
 CALL initresourcesecurity(1)
 CALL populatesrtypesforsecurity(1)
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
 CALL change_times(request->beg_dt_tm,request->end_dt_tm)
 SET request->end_dt_tm = dtemp->end_of_day
 SET request->beg_dt_tm = dtemp->beg_of_day
 DECLARE agree_type_cd = f8
 DECLARE disagree_type_cd = f8
 DECLARE other_type_cd = f8
 DECLARE minor_type_cd = f8
 DECLARE major_type_cd = f8
 DECLARE cdf_meaning = c12
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormessage = vc WITH protect, noconstant(" ")
 DECLARE locindx = i4
 DECLARE ind = i4
 DECLARE catalog_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_catlog_cd = f8 WITH protect, noconstant(0.0)
 DECLARE sblobout = gvc WITH protect, noconstant(" ")
 DECLARE blob_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",25,"BLOB"))
 SET reply->status_data.status = "F"
 SET valid_cases_to_print = "N"
 SET agree_type_cd = 0.0
 SET code_set = 15469
 SET code_value = 0.0
 SET cdf_meaning = "AGREE"
 EXECUTE cpm_get_cd_for_cdf
 SET agree_type_cd = code_value
 SET disagree_type_cd = 0.0
 SET code_set = 15469
 SET code_value = 0.0
 SET cdf_meaning = "DISAGREE"
 EXECUTE cpm_get_cd_for_cdf
 SET disagree_type_cd = code_value
 SET other_type_cd = 0.0
 SET code_set = 15469
 SET code_value = 0.0
 SET cdf_meaning = "OTHER"
 EXECUTE cpm_get_cd_for_cdf
 SET other_type_cd = code_value
 SET minor_type_cd = 0.0
 SET code_set = 15451
 SET code_value = 0.0
 SET cdf_meaning = "MINOR"
 EXECUTE cpm_get_cd_for_cdf
 SET minor_type_cd = code_value
 SET major_type_cd = 0.0
 SET code_set = 15451
 SET code_value = 0.0
 SET cdf_meaning = "MAJOR"
 EXECUTE cpm_get_cd_for_cdf
 SET major_type_cd = code_value
 SET current_type_cd = 0.0
 SET code_set = 213
 SET code_value = 0.0
 SET cdf_meaning = "PRSNL"
 EXECUTE cpm_get_cd_for_cdf
 SET current_type_cd = code_value
 SET deleted_status_cd = 0.0
 SET code_set = 48
 SET code_value = 0.0
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_status_cd = code_value
 SELECT INTO "nl:"
  FROM ap_dc_study ads
  WHERE (ads.study_id=request->study_id)
  DETAIL
   generic_temp->study_description = ads.description, generic_temp->across_case_ind = ads
   .across_case_ind
  WITH nocounter
 ;end select
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
    stat = alterlist(generic_temp->prefix_qual,value(size(request->prefix_qual,5))), pref_cntr = 0
   HEAD ap.prefix_id
    pref_cntr += 1, generic_temp->prefix_qual[pref_cntr].prefix_id = ap.prefix_id, generic_temp->
    prefix_qual[pref_cntr].prefix_name = ap.prefix_name
    IF (ap.site_cd > 0)
     generic_temp->prefix_qual[pref_cntr].site_cd = ap.site_cd, generic_temp->prefix_qual[pref_cntr].
     site_display = cv.display
    ENDIF
   FOOT REPORT
    stat = alterlist(generic_temp->prefix_qual,pref_cntr)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->specimen_cnt > 0))
  SELECT INTO "nl:"
   cv.display
   FROM code_value cv,
    (dummyt d  WITH seq = value(size(request->specimen_qual,5)))
   PLAN (d)
    JOIN (cv
    WHERE (request->specimen_qual[d.seq].specimen_cd=cv.code_value))
   ORDER BY cv.display_key
   HEAD REPORT
    stat = alterlist(generic_temp->specimen_header_qual,value(size(request->specimen_qual,5))),
    spec_cntr = 0
   DETAIL
    spec_cntr += 1, generic_temp->specimen_header_qual[spec_cntr].specimen_cd = cv.code_value,
    generic_temp->specimen_header_qual[spec_cntr].specimen_disp = cv.display
   FOOT REPORT
    stat = alterlist(generic_temp->specimen_header_qual,spec_cntr)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->specimen_comp_cnt > 0))
  SELECT INTO "nl:"
   cv.display
   FROM code_value cv,
    (dummyt d  WITH seq = value(size(request->specimen_comp_to_qual,5)))
   PLAN (d)
    JOIN (cv
    WHERE (request->specimen_comp_to_qual[d.seq].specimen_cd=cv.code_value))
   ORDER BY cv.display_key
   HEAD REPORT
    stat = alterlist(generic_temp->specimen_header_comp,value(size(request->specimen_comp_to_qual,5))
     ), spec_cntr = 0
   DETAIL
    spec_cntr += 1, generic_temp->specimen_header_comp[spec_cntr].specimen_cd = cv.code_value,
    generic_temp->specimen_header_comp[spec_cntr].specimen_disp = cv.display
   FOOT REPORT
    stat = alterlist(generic_temp->specimen_header_comp,spec_cntr)
   WITH nocounter
  ;end select
 ENDIF
 DECLARE ce_where = vc
 SET ce_where = trim("0 = 0")
 SET bno_details = "F"
 SELECT INTO "nl:"
  cv.display
  FROM ap_dc_study_rpt_proc adsrp,
   code_value cv
  PLAN (adsrp
   WHERE (adsrp.study_id=request->study_id))
   JOIN (cv
   WHERE adsrp.task_assay_cd=cv.code_value)
  HEAD REPORT
   x = 0, ce_where = "ce.task_assay_cd in ("
  DETAIL
   x += 1, stat = alterlist(generic_temp->study_id_qual,x), generic_temp->study_id_qual[x].
   task_assay_cd = adsrp.task_assay_cd,
   ce_where = concat(trim(ce_where),trim(cnvtstring(adsrp.task_assay_cd,32,2)),", "), generic_temp->
   study_id_qual[x].task_assay_disp = cv.display
  FOOT REPORT
   templen = textlen(trim(ce_where)), ce_where = concat(substring(1,(templen - 1),trim(ce_where)),
    ") ")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET bno_details = "T"
 ENDIF
 SET lerrorcode = error(serrormessage,0)
 IF (lerrorcode != 0)
  SET reply->status_data.subeventstatus.operationname = "Error getting tasks"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
  GO TO exit_script
 ENDIF
 IF ((request->pathologist_cnt > 0))
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM prsnl p,
    (dummyt d1  WITH seq = value(size(request->pathologist_qual,5)))
   PLAN (d1)
    JOIN (p
    WHERE (request->pathologist_qual[d1.seq].pathologist_id=p.person_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1, stat = alterlist(generic_temp->path_qual,cnt), generic_temp->path_qual[cnt].
    pathologist_name = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 DECLARE prefix_where1 = vc WITH protect, noconstant("")
 DECLARE temp_prefixids = vc WITH protect, noconstant("")
 SET prefix_where1 = fillstring(2000," ")
 SET prefix_where1 = "( 0 = 0 )"
 IF ((request->prefix_cnt > 0))
  SET prefix_where1 = concat(trim(prefix_where1)," and pc.prefix_id in (")
  FOR (x = 1 TO (request->prefix_cnt - 1))
    SET prefix_where1 = concat(trim(prefix_where1)," ",cnvtstring(request->prefix_qual[x].prefix_id,
      32,2,r),",")
  ENDFOR
  SET prefix_where1 = concat(trim(prefix_where1)," ",cnvtstring(request->prefix_qual[x].prefix_id,32,
    2,r),")")
 ELSE
  SELECT INTO "nl:"
   FROM ap_prefix ap
   PLAN (ap
    WHERE ap.prefix_id != 0.0)
   DETAIL
    service_resource_cd = ap.service_resource_cd
    IF (isresourceviewable(service_resource_cd)=true)
     IF (textlen(trim(temp_prefixids))=0)
      temp_prefixids = cnvtstring(ap.prefix_id,32,2,r)
     ELSE
      temp_prefixids = build(trim(temp_prefixids),",",cnvtstring(ap.prefix_id,32,2,r))
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   GO TO report_maker
  ELSEIF (getresourcesecuritystatus(0) != "S")
   IF (getresourcesecuritystatus(0)="F")
    SET reply->status_data.status = "F"
    CALL populateressecstatusblock(1)
    GO TO exit_script
   ELSE
    CALL populateressecstatusblock(1)
    GO TO report_maker
   ENDIF
  ELSE
   IF (textlen(trim(temp_prefixids)) > 0)
    SET prefix_where1 = concat("pc.prefix_id in (",temp_prefixids)
    SET prefix_where1 = concat(trim(prefix_where1),")")
   ENDIF
  ENDIF
 ENDIF
 DECLARE spec_where1 = vc
 IF ((request->specimen_cnt=0))
  SET spec_where1 = "( 0 = 0 )"
 ELSE
  SET spec_where1 = concat(" cs.specimen_cd in (")
  FOR (x = 1 TO (request->specimen_cnt - 1))
    SET spec_where1 = concat(trim(spec_where1)," ",cnvtstring(request->specimen_qual[x].specimen_cd,
      32,2,r),",")
  ENDFOR
  SET spec_where1 = concat(trim(spec_where1)," ",cnvtstring(request->specimen_qual[x].specimen_cd,32,
    2,r),")")
 ENDIF
 DECLARE spec_where2 = vc
 IF ((request->specimen_comp_cnt=0))
  SET spec_where2 = "( 0 = 0 )"
 ELSE
  SET spec_where2 = concat(" cs.specimen_cd in (")
  FOR (x = 1 TO (request->specimen_comp_cnt - 1))
    SET spec_where2 = concat(trim(spec_where2)," ",cnvtstring(request->specimen_comp_to_qual[x].
      specimen_cd,32,2,r),",")
  ENDFOR
  SET spec_where2 = concat(trim(spec_where2)," ",cnvtstring(request->specimen_comp_to_qual[x].
    specimen_cd,32,2,r),")")
 ENDIF
 IF ((request->pathologist_cnt=0))
  SET path_where1 = "( pc.responsible_pathologist_id >= 0 )"
 ELSE
  SET path_where1 = fillstring(1000," ")
  SET path_where1 = concat(" pc.responsible_pathologist_id in (")
  FOR (x = 1 TO (request->pathologist_cnt - 1))
    SET path_where1 = concat(trim(path_where1)," ",cnvtstring(request->pathologist_qual[x].
      pathologist_id,32,2,r),",")
  ENDFOR
  SET path_where1 = concat(trim(path_where1)," ",cnvtstring(request->pathologist_qual[x].
    pathologist_id,32,2,r),")")
 ENDIF
 SELECT INTO "nl:"
  pc.responsible_pathologist_id, pc.case_id, pc.accession_nbr,
  cs.cancel_cd
  FROM pathology_case pc,
   case_specimen cs
  PLAN (pc
   WHERE parser(path_where1)
    AND parser(prefix_where1)
    AND pc.main_report_cmplete_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(
    request->end_dt_tm))
   JOIN (cs
   WHERE pc.case_id=cs.case_id
    AND cs.cancel_cd IN (null, 0)
    AND parser(spec_where1))
  ORDER BY pc.responsible_pathologist_id, pc.accession_nbr
  HEAD REPORT
   cnt = 0, case_cnt = 0
  HEAD pc.responsible_pathologist_id
   cnt += 1, stat = alterlist(stat_temp->path_qual,cnt), stat_temp->path_qual[cnt].pathologist_id =
   pc.responsible_pathologist_id,
   case_cnt = 0
  HEAD pc.accession_nbr
   case_cnt += 1, stat = alterlist(stat_temp->path_qual[cnt].case_qual,case_cnt), stat_temp->
   path_qual[cnt].cases_cnt = case_cnt
   IF ((case_cnt > stat_temp->max_cases))
    stat_temp->max_cases = case_cnt
   ENDIF
   stat_temp->path_qual[cnt].case_qual[case_cnt].case_id = pc.case_id, stat_temp->path_qual[cnt].
   case_qual[case_cnt].case_accession = pc.accession_nbr
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO report_maker
 ENDIF
 SET lerrorcode = error(serrormessage,0)
 IF (lerrorcode != 0)
  SET reply->status_data.subeventstatus.operationname = "Statistical analysis"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  stat_temp->path_qual[d1.seq].pathologist_id, p.name_full_formatted
  FROM (dummyt d1  WITH seq = value(size(stat_temp->path_qual,5))),
   prsnl p
  PLAN (d1)
   JOIN (p
   WHERE (stat_temp->path_qual[d1.seq].pathologist_id=p.person_id))
  DETAIL
   IF ((stat_temp->path_qual[d1.seq].pathologist_id=0))
    stat_temp->path_qual[d1.seq].pathologist_name = captions->unassigned
   ELSE
    stat_temp->path_qual[d1.seq].pathologist_name = p.name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  stat_temp->path_qual[d1.seq].case_qual[d2.seq].case_accession, ade.final_eval_term_id, ade
  .long_text_id,
  ade.disagree_reason_cd, ade.complete_dt_tm, disagree_disp = uar_get_code_display(ade
   .disagree_reason_cd),
  investigation_disp = uar_get_code_display(ade.investigation_cd), resolution_disp =
  uar_get_code_display(ade.resolution_cd), resp_path_id = stat_temp->path_qual[d1.seq].pathologist_id,
  resp_path_name = stat_temp->path_qual[d1.seq].pathologist_name, case_id = stat_temp->path_qual[d1
  .seq].case_qual[d2.seq].case_id
  FROM (dummyt d1  WITH seq = value(size(stat_temp->path_qual,5))),
   (dummyt d2  WITH seq = value(stat_temp->max_cases)),
   ap_dc_event ade,
   ap_dc_evaluation_term adet,
   ap_dc_discrepancy_term addt,
   prsnl_group pg
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(stat_temp->path_qual[d1.seq].case_qual,5))
   JOIN (ade
   WHERE (ade.case_id=stat_temp->path_qual[d1.seq].case_qual[d2.seq].case_id)
    AND ((ade.study_id+ 0)=request->study_id)
    AND ade.cancel_dt_tm=null)
   JOIN (adet
   WHERE adet.evaluation_term_id=ade.final_eval_term_id)
   JOIN (addt
   WHERE addt.discrepancy_term_id=ade.final_discrep_term_id)
   JOIN (pg
   WHERE pg.prsnl_group_id=ade.prsnl_group_id)
  ORDER BY resp_path_name, case_id
  HEAD case_id
   max_corr_cases = 0, access_to_resource_ind = 0, stat_temp->path_qual[d1.seq].corr_evnt_prcnt_cnt
    += 1
  DETAIL
   IF (ade.complete_dt_tm != null)
    IF (adet.agreement_cd=other_type_cd)
     stat_temp->path_qual[d1.seq].other += 1
    ELSEIF (adet.agreement_cd=agree_type_cd)
     stat_temp->path_qual[d1.seq].agreements += 1
    ELSEIF (adet.agreement_cd=disagree_type_cd)
     IF (addt.discrepancy_cd=minor_type_cd)
      stat_temp->path_qual[d1.seq].min_disagreements += 1
     ELSE
      stat_temp->path_qual[d1.seq].maj_disagreements += 1
     ENDIF
    ENDIF
   ELSE
    stat_temp->path_qual[d1.seq].incomplete += 1
   ENDIF
   stat_temp->path_qual[d1.seq].correlated_events += 1, access_to_resource_ind = 1
   IF (pg.prsnl_group_id > 0.0)
    IF (isresourceviewable(pg.service_resource_cd)=false)
     access_to_resource_ind = 0
    ENDIF
   ENDIF
   IF (access_to_resource_ind=1)
    max_corr_cases += 1, stat = alterlist(stat_temp->path_qual[d1.seq].case_qual[d2.seq].corr_qual,
     max_corr_cases)
    IF ((max_corr_cases > stat_temp->max_corr_cases))
     stat_temp->max_corr_cases = max_corr_cases
    ENDIF
    stat_temp->path_qual[d1.seq].case_qual[d2.seq].print_this_case = "Y", stat_temp->path_qual[d1.seq
    ].case_qual[d2.seq].valid_case_specs = "N", stat_temp->path_qual[d1.seq].case_qual[d2.seq].
    corr_qual[max_corr_cases].valid_comp_case_specs = "N",
    stat_temp->path_qual[d1.seq].case_qual[d2.seq].corr_qual[max_corr_cases].correlate_case_id = ade
    .correlate_case_id, stat_temp->path_qual[d1.seq].case_qual[d2.seq].corr_qual[max_corr_cases].
    event_id = ade.event_id, stat_temp->path_qual[d1.seq].case_qual[d2.seq].corr_qual[max_corr_cases]
    .disagree_reason_cd = ade.disagree_reason_cd,
    stat_temp->path_qual[d1.seq].case_qual[d2.seq].corr_qual[max_corr_cases].disagree_reason_disp =
    disagree_disp, stat_temp->path_qual[d1.seq].case_qual[d2.seq].corr_qual[max_corr_cases].
    investigation_cd = ade.investigation_cd, stat_temp->path_qual[d1.seq].case_qual[d2.seq].
    corr_qual[max_corr_cases].investigation_disp = investigation_disp,
    stat_temp->path_qual[d1.seq].case_qual[d2.seq].corr_qual[max_corr_cases].resolution_cd = ade
    .resolution_cd, stat_temp->path_qual[d1.seq].case_qual[d2.seq].corr_qual[max_corr_cases].
    resolution_disp = resolution_disp, stat_temp->path_qual[d1.seq].case_qual[d2.seq].corr_qual[
    max_corr_cases].final_eval_term_id = ade.final_eval_term_id,
    stat_temp->path_qual[d1.seq].case_qual[d2.seq].corr_qual[max_corr_cases].final_discrep_term_id =
    ade.final_discrep_term_id, stat_temp->path_qual[d1.seq].case_qual[d2.seq].corr_qual[
    max_corr_cases].long_text_id = ade.long_text_id
   ENDIF
  WITH nocounter
 ;end select
 IF (getresourcesecuritystatus(0)="F")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(ncorr_group_sec_msg_type)
  GO TO exit_script
 ENDIF
 SET lerrorcode = error(serrormessage,0)
 IF (lerrorcode != 0)
  SET reply->status_data.subeventstatus.operationname = "Pathologist Counts"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  path_id = stat_temp->path_qual[d1.seq].pathologist_id, path_name = cnvtupper(stat_temp->path_qual[
   d1.seq].pathologist_name)
  FROM (dummyt d1  WITH seq = value(size(stat_temp->path_qual,5)))
  ORDER BY path_name
  HEAD REPORT
   cnt = 0, stat = alterlist(stat_temp->srtd_path_qual,value(size(stat_temp->path_qual,5)))
  HEAD path_name
   cnt += 1, stat_temp->srtd_path_qual[cnt].pathologist_name = stat_temp->path_qual[d1.seq].
   pathologist_name, stat_temp->srtd_path_qual[cnt].pathologist_id = stat_temp->path_qual[d1.seq].
   pathologist_id,
   stat_temp->srtd_path_qual[cnt].cases_cnt = stat_temp->path_qual[d1.seq].cases_cnt, stat_temp->
   srtd_path_qual[cnt].correlated_events = stat_temp->path_qual[d1.seq].correlated_events, stat_temp
   ->srtd_path_qual[cnt].agreements = stat_temp->path_qual[d1.seq].agreements,
   stat_temp->srtd_path_qual[cnt].min_disagreements = stat_temp->path_qual[d1.seq].min_disagreements,
   stat_temp->srtd_path_qual[cnt].maj_disagreements = stat_temp->path_qual[d1.seq].maj_disagreements,
   stat_temp->srtd_path_qual[cnt].other = stat_temp->path_qual[d1.seq].other,
   stat_temp->srtd_path_qual[cnt].incomplete = stat_temp->path_qual[d1.seq].incomplete, stat_temp->
   srtd_path_qual[cnt].corr_evnt_prcnt_cnt = stat_temp->path_qual[d1.seq].corr_evnt_prcnt_cnt,
   case_cnt = 0,
   stat = alterlist(stat_temp->srtd_path_qual[cnt].case_qual,size(stat_temp->path_qual[d1.seq].
     case_qual,5))
   FOR (case_cnt = 1 TO size(stat_temp->path_qual[d1.seq].case_qual,5))
     stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].case_id = stat_temp->path_qual[d1.seq].
     case_qual[case_cnt].case_id, stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].case_accession
      = stat_temp->path_qual[d1.seq].case_qual[case_cnt].case_accession, stat_temp->srtd_path_qual[
     cnt].case_qual[case_cnt].print_this_case = stat_temp->path_qual[d1.seq].case_qual[case_cnt].
     print_this_case,
     stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].valid_case_specs = stat_temp->path_qual[d1
     .seq].case_qual[case_cnt].valid_case_specs, corr_case_cnt = 0, stat = alterlist(stat_temp->
      srtd_path_qual[cnt].case_qual[case_cnt].corr_qual,size(stat_temp->path_qual[d1.seq].case_qual[
       case_cnt].corr_qual,5))
     FOR (corr_case_cnt = 1 TO size(stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual,5))
       stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt].event_id =
       stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[corr_case_cnt].event_id, stat_temp
       ->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt].disagree_reason_cd =
       stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[corr_case_cnt].disagree_reason_cd,
       stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt].
       disagree_reason_disp = stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[
       corr_case_cnt].disagree_reason_disp,
       stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt].investigation_cd
        = stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[corr_case_cnt].investigation_cd,
       stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt].investigation_disp
        = stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[corr_case_cnt].
       investigation_disp, stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt
       ].resolution_cd = stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[corr_case_cnt].
       resolution_cd,
       stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt].resolution_disp =
       stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[corr_case_cnt].resolution_disp,
       stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt].final_eval_term_id
        = stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[corr_case_cnt].
       final_eval_term_id, stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt
       ].final_discrep_term_id = stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[
       corr_case_cnt].final_discrep_term_id,
       stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt].long_text_id =
       stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[corr_case_cnt].long_text_id,
       stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt].correlate_case_id
        = stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[corr_case_cnt].correlate_case_id,
       stat_temp->srtd_path_qual[cnt].case_qual[case_cnt].corr_qual[corr_case_cnt].
       valid_comp_case_specs = stat_temp->path_qual[d1.seq].case_qual[case_cnt].corr_qual[
       corr_case_cnt].valid_comp_case_specs
     ENDFOR
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].event_id, p1.name_initials,
  adep.prsnl_id
  FROM person_name p1,
   (dummyt d1  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
   (dummyt d2  WITH seq = value(stat_temp->max_cases)),
   (dummyt d3  WITH seq = value(stat_temp->max_corr_cases)),
   ap_dc_event_prsnl adep
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual,5))
   JOIN (adep
   WHERE (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].event_id=adep
   .event_id)
    AND adep.prsnl_group_id=0)
   JOIN (p1
   WHERE adep.prsnl_id=p1.person_id
    AND current_type_cd=p1.name_type_cd)
  DETAIL
   stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].corr_initials = substring(1,
    3,p1.name_initials), stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
   individ_or_group = "I"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pg.prsnl_group_desc
  FROM prsnl_group pg,
   (dummyt d1  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
   (dummyt d2  WITH seq = value(stat_temp->max_cases)),
   (dummyt d3  WITH seq = value(stat_temp->max_corr_cases)),
   ap_dc_event ade
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual,5))
   JOIN (ade
   WHERE (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].event_id=ade.event_id
   )
    AND ade.prsnl_group_id > 0)
   JOIN (pg
   WHERE ade.prsnl_group_id=pg.prsnl_group_id)
  DETAIL
   stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].corr_group_name = pg
   .prsnl_group_desc, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
   individ_or_group = "G"
  WITH nocounter
 ;end select
 SET lerrorcode = error(serrormessage,0)
 IF (lerrorcode != 0)
  SET reply->status_data.subeventstatus.operationname = "Correlators' group name"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
  GO TO exit_script
 ENDIF
 IF ((generic_temp->across_case_ind=1))
  SELECT INTO "nl:"
   FROM pathology_case pc,
    (dummyt d1  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
    (dummyt d2  WITH seq = value(stat_temp->max_cases)),
    (dummyt d3  WITH seq = value(stat_temp->max_corr_cases))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual,5))
    JOIN (d3
    WHERE d3.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual,5))
    JOIN (pc
    WHERE (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].correlate_case_id=pc
    .case_id))
   DETAIL
    stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].correlate_accession = pc
    .accession_nbr
   WITH nocounter
  ;end select
 ENDIF
 SET lerrorcode = error(serrormessage,0)
 IF (lerrorcode != 0)
  SET reply->status_data.subeventstatus.operationname = "Comparison Accession Nbrs"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d1.seq, ce.collating_seq, ce_catalog_disp = uar_get_code_display(ce.catalog_cd)
  FROM (dummyt d1  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
   (dummyt d2  WITH seq = value(stat_temp->max_cases)),
   clinical_event ce
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual,5))
   JOIN (ce
   WHERE (ce.accession_nbr=stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].case_accession)
    AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].print_this_case="Y")
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.record_status_cd != deleted_status_cd
    AND parser(ce_where))
  ORDER BY d1.seq, ce.accession_nbr, ce_catalog_disp,
   ce.collating_seq
  HEAD REPORT
   proc_qual = 0
  HEAD d1.seq
   proc_qual = 0
  HEAD ce.accession_nbr
   proc_qual = 0
  HEAD ce_catalog_disp
   ind = locateval(locindx,1,catalog_cnt,ce.catalog_cd,catalog->catalog_qual[locindx].catalog_cd)
   IF (ind=0)
    catalog_cnt += 1, stat = alterlist(catalog->catalog_qual,catalog_cnt), catalog->catalog_qual[
    catalog_cnt].catalog_cd = ce.catalog_cd,
    catalog->catalog_qual[catalog_cnt].catalog_disp = ce_catalog_disp
   ENDIF
  DETAIL
   proc_qual += 1
   IF ((proc_qual > stat_temp->max_dtas))
    stat_temp->max_dtas = proc_qual
   ENDIF
   stat = alterlist(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_qual,proc_qual),
   stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].valid_case_specs = "Y", stat_temp->
   srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_cnt = proc_qual,
   stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_qual[proc_qual].discrete_task_assay_cd
    = ce.task_assay_cd, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_qual[proc_qual].
   ce_event_id = ce.event_id, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_qual[
   proc_qual].catalog_cd = ce.catalog_cd
  WITH nocounter
 ;end select
 SET lerrorcode = error(serrormessage,0)
 IF (lerrorcode != 0)
  SET reply->status_data.subeventstatus.operationname = "Error getting acc text"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
  GO TO exit_script
 ENDIF
 IF ((request->include_report_text="Y"))
  SELECT INTO "nl:"
   ce_event_id = stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].v_proc_qual[d2.seq].ce_event_id,
   cebr.event_id
   FROM (dummyt d  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
    (dummyt d1  WITH seq = value(stat_temp->max_cases)),
    (dummyt d2  WITH seq = value(stat_temp->max_dtas)),
    ce_blob_result cebr
   PLAN (d)
    JOIN (d1
    WHERE d1.seq <= size(stat_temp->srtd_path_qual[d.seq].case_qual,5))
    JOIN (d2
    WHERE d2.seq <= size(stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].v_proc_qual,5)
     AND (stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].valid_case_specs="Y"))
    JOIN (cebr
    WHERE (stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].v_proc_qual[d2.seq].ce_event_id=cebr
    .event_id)
     AND cebr.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND cebr.storage_cd=blob_cd)
   ORDER BY d1.seq, ce_event_id
   HEAD d1.seq
    blob_cntr = 0
   HEAD ce_event_id
    blob_cntr = 0, recdate->datetime = cnvtdatetimeutc(cebr.valid_from_dt_tm), sblobout = "",
    blobsize = uar_get_ceblobsize(cebr.event_id,recdate)
    IF (blobsize > 0)
     stat = memrealloc(sblobout,1,build("C",blobsize)), status = uar_get_ceblob(cebr.event_id,recdate,
      sblobout,blobsize),
     CALL rtf_to_text(sblobout,1,90)
     FOR (z = 1 TO size(tmptext->qual,5))
       blob_cntr += 1, stat = alterlist(stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].
        v_proc_qual[d2.seq].text_qual,blob_cntr), stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].
       v_proc_qual[d2.seq].text_cnt = blob_cntr,
       stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].v_proc_qual[d2.seq].text_qual[blob_cntr].
       text = trim(tmptext->qual[z].text)
     ENDFOR
    ENDIF
   WITH nocounter, memsort
  ;end select
  IF (bno_details="T")
   SELECT INTO "nl:"
    cv.display
    FROM (dummyt d  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
     (dummyt d1  WITH seq = value(stat_temp->max_cases)),
     (dummyt d2  WITH seq = value(stat_temp->max_dtas)),
     code_value cv
    PLAN (d)
     JOIN (d1
     WHERE d1.seq <= size(stat_temp->srtd_path_qual[d.seq].case_qual,5))
     JOIN (d2
     WHERE d2.seq <= size(stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].v_proc_qual,5)
      AND (stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].valid_case_specs="Y"))
     JOIN (cv
     WHERE (stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].v_proc_qual[d2.seq].
     discrete_task_assay_cd=cv.code_value))
    DETAIL
     stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].v_proc_qual[d2.seq].discrete_task_assay_disp
      = cv.display
    WITH nocounter
   ;end select
  ENDIF
  SET lerrorcode = error(serrormessage,0)
  IF (lerrorcode != 0)
   SET reply->status_data.subeventstatus.operationname = "Error getting rpt text"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
   (dummyt d2  WITH seq = value(stat_temp->max_cases)),
   (dummyt d3  WITH seq = value(stat_temp->max_corr_cases)),
   case_specimen cs
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual,5))
   JOIN (cs
   WHERE (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].correlate_case_id=cs
   .case_id)
    AND parser(spec_where2))
  DETAIL
   stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].valid_comp_case_specs = "Y"
  WITH nocounter
 ;end select
 IF ((generic_temp->across_case_ind=1)
  AND (request->include_report_text="Y"))
  SELECT INTO "nl:"
   ce.collating_seq, d1.seq, ce_catalog_disp = uar_get_code_display(ce.catalog_cd)
   FROM (dummyt d1  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
    (dummyt d2  WITH seq = value(stat_temp->max_cases)),
    (dummyt d3  WITH seq = value(stat_temp->max_corr_cases)),
    clinical_event ce
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual,5))
    JOIN (d3
    WHERE d3.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual,5))
    JOIN (ce
    WHERE (ce.accession_nbr=stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
    correlate_accession)
     AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].correlate_case_id > 0
    )
     AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].valid_comp_case_specs
    ="Y")
     AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND ce.record_status_cd != deleted_status_cd
     AND parser(ce_where))
   ORDER BY d1.seq, d2.seq, d3.seq,
    ce.accession_nbr, ce_catalog_disp, ce.collating_seq
   HEAD REPORT
    compare_proc_cnt = 0
   HEAD d1.seq
    compare_proc_cnt = 0
   HEAD d2.seq
    compare_proc_cnt = 0
   HEAD d3.seq
    compare_proc_cnt = 0
   HEAD ce_catalog_disp
    ind = locateval(locindx,1,catalog_cnt,ce.catalog_cd,catalog->catalog_qual[locindx].catalog_cd)
    IF (ind=0)
     catalog_cnt += 1, stat = alterlist(catalog->catalog_qual,catalog_cnt), catalog->catalog_qual[
     catalog_cnt].catalog_cd = ce.catalog_cd,
     catalog->catalog_qual[catalog_cnt].catalog_disp = ce_catalog_disp
    ENDIF
   DETAIL
    compare_proc_cnt += 1
    IF ((compare_proc_cnt > stat_temp->max_comp_dtas))
     stat_temp->max_comp_dtas = compare_proc_cnt
    ENDIF
    stat = alterlist(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
     v_comp_qual,compare_proc_cnt), stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3
    .seq].v_comp_cnt = compare_proc_cnt, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].
    corr_qual[d3.seq].v_comp_qual[compare_proc_cnt].discrete_task_assay_cd = ce.task_assay_cd,
    stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].v_comp_qual[
    compare_proc_cnt].ce_event_id = ce.event_id, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].
    corr_qual[d3.seq].v_comp_qual[compare_proc_cnt].catalog_cd = ce.catalog_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ce_event_id = stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual[d2.seq].v_comp_qual[d3
   .seq].ce_event_id, d1.seq, cebr.event_id
   FROM (dummyt d  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
    (dummyt d1  WITH seq = value(stat_temp->max_cases)),
    (dummyt d2  WITH seq = value(stat_temp->max_corr_cases)),
    (dummyt d3  WITH seq = value(stat_temp->max_comp_dtas)),
    ce_blob_result cebr
   PLAN (d)
    JOIN (d1
    WHERE d1.seq <= size(stat_temp->srtd_path_qual[d.seq].case_qual,5))
    JOIN (d2
    WHERE d2.seq <= size(stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual,5))
    JOIN (d3
    WHERE d3.seq <= size(stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual[d2.seq].
     v_comp_qual,5)
     AND (stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual[d2.seq].valid_comp_case_specs=
    "Y"))
    JOIN (cebr
    WHERE (stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual[d2.seq].v_comp_qual[d3.seq].
    ce_event_id=cebr.event_id)
     AND cebr.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND cebr.storage_cd=blob_cd)
   ORDER BY d1.seq, ce_event_id
   HEAD d1.seq
    blob_cntr = 0
   HEAD ce_event_id
    blob_cntr = 0, recdate->datetime = cnvtdatetimeutc(cebr.valid_from_dt_tm), sblobout = "",
    blobsize = uar_get_ceblobsize(cebr.event_id,recdate)
    IF (blobsize > 0)
     stat = memrealloc(sblobout,1,build("C",blobsize)), status = uar_get_ceblob(cebr.event_id,recdate,
      sblobout,blobsize),
     CALL rtf_to_text(sblobout,1,90)
     FOR (z = 1 TO size(tmptext->qual,5))
       blob_cntr += 1, stat = alterlist(stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual[
        d2.seq].v_comp_qual[d3.seq].text_qual,blob_cntr), stat_temp->srtd_path_qual[d.seq].case_qual[
       d1.seq].corr_qual[d2.seq].v_comp_qual[d3.seq].text_cnt = blob_cntr,
       stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual[d2.seq].v_comp_qual[d3.seq].
       text_qual[blob_cntr].text = trim(tmptext->qual[z].text)
     ENDFOR
    ENDIF
   WITH nocounter, memsort
  ;end select
  IF (bno_details="T")
   SELECT INTO "nl:"
    cv.display
    FROM (dummyt d  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
     (dummyt d1  WITH seq = value(stat_temp->max_cases)),
     (dummyt d2  WITH seq = value(stat_temp->max_corr_cases)),
     (dummyt d3  WITH seq = value(stat_temp->max_comp_dtas)),
     code_value cv
    PLAN (d)
     JOIN (d1
     WHERE d1.seq <= size(stat_temp->srtd_path_qual[d.seq].case_qual,5))
     JOIN (d2
     WHERE d2.seq <= size(stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual,5))
     JOIN (d3
     WHERE d3.seq <= size(stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual[d2.seq].
      v_comp_qual,5)
      AND (stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual[d2.seq].valid_comp_case_specs
     ="Y"))
     JOIN (cv
     WHERE (stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual[d2.seq].v_comp_qual[d3.seq].
     discrete_task_assay_cd=cv.code_value))
    DETAIL
     stat_temp->srtd_path_qual[d.seq].case_qual[d1.seq].corr_qual[d2.seq].v_comp_qual[d3.seq].
     discrete_task_assay_disp = cv.display
    WITH nocounter
   ;end select
  ENDIF
  SET lerrorcode = error(serrormessage,0)
  IF (lerrorcode != 0)
   SET reply->status_data.subeventstatus.operationname = "Error getting comp txt"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->include_case_info="Y"))
  SELECT INTO "nl:"
   lt.long_text_id, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].case_accession, lt.long_text
   FROM long_text lt,
    (dummyt d1  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
    (dummyt d2  WITH seq = value(stat_temp->max_cases)),
    (dummyt d3  WITH seq = value(stat_temp->max_corr_cases))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual,5))
    JOIN (d3
    WHERE d3.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual,5)
     AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].valid_case_specs="Y"))
    JOIN (lt
    WHERE (lt.long_text_id=stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
    long_text_id)
     AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].long_text_id > 0)
     AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].valid_comp_case_specs
    ="Y")
     AND lt.parent_entity_name="AP_DC_EVENT")
   ORDER BY lt.long_text_id
   HEAD REPORT
    tmplt_cntr = 0
   HEAD lt.long_text_id
    tmplt_cntr = 0, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
    long_text_cntr = 0
   DETAIL
    CALL rtf_to_text(lt.long_text,1,100)
    FOR (z = 1 TO size(tmptext->qual,5))
      tmplt_cntr += 1, stat = alterlist(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].
       corr_qual[d3.seq].long_text_qual,tmplt_cntr), stat_temp->srtd_path_qual[d1.seq].case_qual[d2
      .seq].corr_qual[d3.seq].long_text_cntr = tmplt_cntr,
      stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].long_text_qual[tmplt_cntr
      ].text = trim(tmptext->qual[z].text)
    ENDFOR
   WITH nocounter
  ;end select
  SET lerrorcode = error(serrormessage,0)
  IF (lerrorcode != 0)
   SET reply->status_data.subeventstatus.operationname = "Error getting long text"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
   (dummyt d2  WITH seq = value(stat_temp->max_cases)),
   (dummyt d3  WITH seq = value(stat_temp->max_corr_cases)),
   ap_dc_evaluation_term adet
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual,5)
    AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].valid_case_specs="Y"))
   JOIN (adet
   WHERE (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].final_eval_term_id=
   adet.evaluation_term_id)
    AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].valid_comp_case_specs=
   "Y")
    AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].final_eval_term_id > 0
   ))
  DETAIL
   stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].final_eval_term_disp = adet
   .display
  WITH nocounter
 ;end select
 SET lerrorcode = error(serrormessage,0)
 IF (lerrorcode != 0)
  SET reply->status_data.subeventstatus.operationname = "Error getting eval cd"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
   (dummyt d2  WITH seq = value(stat_temp->max_cases)),
   (dummyt d3  WITH seq = value(stat_temp->max_corr_cases)),
   ap_dc_discrepancy_term addt
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual,5)
    AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].valid_case_specs="Y"))
   JOIN (addt
   WHERE (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].final_discrep_term_id
   =addt.discrepancy_term_id)
    AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].valid_comp_case_specs=
   "Y")
    AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].final_discrep_term_id
    > 0))
  DETAIL
   stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].final_discrep_term_disp =
   addt.display
  WITH nocounter
 ;end select
 SET lerrorcode = error(serrormessage,0)
 IF (lerrorcode != 0)
  SET reply->status_data.subeventstatus.operationname = "Error getting discrp info"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
  GO TO exit_script
 ENDIF
 FOR (loop1 = 1 TO size(stat_temp->srtd_path_qual,5))
   FOR (loop2 = 1 TO size(stat_temp->srtd_path_qual[loop1].case_qual,5))
     FOR (loop3 = 1 TO size(stat_temp->srtd_path_qual[loop1].case_qual[loop2].v_proc_qual,5))
       FOR (loop4 = 1 TO size(generic_temp->study_id_qual,5))
         IF ((generic_temp->study_id_qual[loop4].task_assay_cd=stat_temp->srtd_path_qual[loop1].
         case_qual[loop2].v_proc_qual[loop3].discrete_task_assay_cd))
          SET stat_temp->srtd_path_qual[loop1].case_qual[loop2].v_proc_qual[loop3].
          discrete_task_assay_disp = generic_temp->study_id_qual[loop4].task_assay_disp
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 FOR (loop1 = 1 TO size(stat_temp->srtd_path_qual,5))
   FOR (loop2 = 1 TO size(stat_temp->srtd_path_qual[loop1].case_qual,5))
     FOR (loop3 = 1 TO size(stat_temp->srtd_path_qual[loop1].case_qual[loop2].corr_qual,5))
       FOR (loop4 = 1 TO size(stat_temp->srtd_path_qual[loop1].case_qual[loop2].corr_qual[loop3].
        v_comp_qual,5))
         FOR (loop5 = 1 TO size(generic_temp->study_id_qual,5))
           IF ((generic_temp->study_id_qual[loop5].task_assay_cd=stat_temp->srtd_path_qual[loop1].
           case_qual[loop2].corr_qual[loop3].v_comp_qual[loop4].discrete_task_assay_cd))
            SET stat_temp->srtd_path_qual[loop1].case_qual[loop2].corr_qual[loop3].v_comp_qual[loop4]
            .discrete_task_assay_disp = generic_temp->study_id_qual[loop5].task_assay_disp
           ENDIF
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  valid = stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].valid_case_specs
  FROM (dummyt d1  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
   (dummyt d2  WITH seq = value(stat_temp->max_cases)),
   (dummyt d3  WITH seq = value(stat_temp->max_corr_cases)),
   (dummyt d4  WITH seq = 1)
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual,5)
    AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].valid_case_specs="Y"))
   JOIN (d4
   WHERE d4.seq <= 1
    AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].valid_comp_case_specs=
   "Y"))
  HEAD REPORT
   x = 0
  DETAIL
   valid_cases_to_print = "Y"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET valid_cases_to_print = "Y"
 ENDIF
#report_maker
 EXECUTE cpm_create_file_name_logical "aps_diagcorr_rpt", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 DECLARE bfirsttimethru = vc
 SELECT INTO value(reply->print_status_data.print_filename)
  pathologist_name = stat_temp->srtd_path_qual[d1.seq].pathologist_name
  FROM (dummyt d1  WITH seq = value(size(stat_temp->srtd_path_qual,5))),
   (dummyt d2  WITH seq = value(stat_temp->max_cases)),
   (dummyt d3  WITH seq = value(stat_temp->max_corr_cases)),
   (dummyt d4  WITH seq = 1)
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual,5)
    AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].valid_case_specs="Y"))
   JOIN (d4
   WHERE d4.seq <= 1
    AND (stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].valid_comp_case_specs=
   "Y"))
  ORDER BY stat_temp->srtd_path_qual[d1.seq].pathologist_name
  HEAD REPORT
   line1 = fillstring(125,"-"), 20stars = fillstring(20,"*"), bfirstpage = "Y",
   bfirsttimethru = "Y", ttl_cases_cnt = 0.0, ttl_corr_events = 0.0,
   ttl_agreements = 0.0, ttl_min_disagreements = 0.0, ttl_maj_disagreements = 0.0,
   ttl_other = 0.0, ttl_incomplete = 0.0, head_cntr = 0,
   h_nbr_paths = 0, ttl_corr_evnt_prcnt_cnt = 0.0
  HEAD PAGE
   row + 1, col 0, captions->apsprtdiagcorrrpt,
   CALL center(captions->pathnetap,0,132), col 110, captions->ddate,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->ddirectory, col 110,
   captions->ttime, col 117, curtime,
   row + 1,
   CALL center(captions->diagcorrrpt,0,132), col 112,
   captions->bby2, col 117, request->scuruser"##############",
   row + 1, col 110, captions->ppage,
   col 117, curpage"###", row + 2
   IF (bfirstpage="Y")
    col 0, "         ", captions->study,
    " ", generic_temp->study_description, row + 1,
    col 0, "    ", captions->prefixes,
    " ", col 16, last_pref = value(size(generic_temp->prefix_qual,5))
    IF (last_pref=0)
     captions->allprefixes
    ELSE
     FOR (x = 1 TO last_pref)
       generic_temp->prefix_qual[x].site_display, generic_temp->prefix_qual[x].prefix_name
       IF (x < last_pref)
        ", "
       ENDIF
       col + 1
       IF (col > 120)
        row + 1, col 16
       ENDIF
     ENDFOR
    ENDIF
    row + 1, col 0, "    ",
    captions->sspecimens, " ", col 16
    IF ((request->specimen_cnt=0))
     captions->allspecimens
    ELSE
     last_spec = value(size(generic_temp->specimen_header_qual,5))
     FOR (x = 1 TO last_spec)
       generic_temp->specimen_header_qual[x].specimen_disp
       IF (x < last_spec)
        ", "
       ENDIF
       col + 1
       IF (col > 110)
        row + 1, col 16
       ENDIF
     ENDFOR
    ENDIF
    IF ((generic_temp->across_case_ind=1))
     row + 1, col 0, captions->compspec,
     " ", col 16
     IF ((request->specimen_comp_cnt=0))
      captions->allspecimens
     ELSE
      last_spec = value(size(generic_temp->specimen_header_comp,5))
      FOR (x = 1 TO last_spec)
        generic_temp->specimen_header_comp[x].specimen_disp
        IF (x < last_spec)
         ", "
        ENDIF
        col + 1
        IF (col > 110)
         row + 1, col 16
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    row + 1, col 0, captions->beginningdate,
    " ", request->beg_dt_tm"@SHORTDATE;;Q", row + 1,
    col 0, "   ", captions->endingdate,
    " ", request->end_dt_tm"@SHORTDATE;;Q", row + 1,
    col 0, "   ", captions->pathologist,
    " "
    IF ((request->pathologist_cnt=0))
     captions->allpathologists
    ELSEIF ((request->pathologist_cnt > 0))
     FOR (x = 1 TO value(size(generic_temp->path_qual,5)))
      generic_temp->path_qual[x].pathologist_name,
      IF (x < value(size(generic_temp->path_qual,5)))
       row + 1, col 16
      ENDIF
     ENDFOR
    ENDIF
    IF ((request->include_statistics="Y"))
     row + 2, col 0, captions->includestatsummary
    ELSE
     row + 2, col 0, captions->excludestatsummary
    ENDIF
    IF ((request->include_case_info="Y"))
     row + 1, col 0, captions->includecaseinfo
    ELSE
     row + 1, col 0, captions->excludecaseinfo
    ENDIF
    IF ((request->include_report_text="Y"))
     row + 1, col 0, captions->includerpttext
    ELSE
     row + 1, col 0, captions->excluderpttext
    ENDIF
    IF ((request->include_statistics="Y"))
     row + 2,
     CALL center(20stars,0,132), row + 1,
     CALL center(captions->statsummary,0,132), row + 1,
     CALL center(20stars,0,132),
     row + 1, row + 1, col 42,
     captions->correlated, col 72, captions->disagreements,
     col 87, captions->disagreements, col 117,
     captions->correlation, row + 1, col 34,
     captions->ttotal2, col 42, captions->events,
     col 57, captions->agreements, col 72,
     captions->minor, col 87, captions->major,
     col 102, captions->other, col 117,
     captions->incomplete, row + 1, col 0,
     captions->pathologist2, col 34, captions->cases3,
     col 48, "#", col 54,
     "%", col 63, "#",
     col 69, "%", col 78,
     "#", col 84, "%",
     col 93, "#", col 99,
     "%", col 108, "#",
     col 114, "%", col 123,
     "#", col 129, "%",
     row + 1, col 0, "-----------------------------",
     col 32, "--------", col 42,
     "-------", col 50, "-----",
     col 57, "-------", col 65,
     "-----", col 72, "-------",
     col 80, "-----", col 87,
     "-------", col 95, "-----",
     col 102, "-------", col 110,
     "-----", col 117, "-------",
     col 125, "-----"
    ELSE
     row + 1
    ENDIF
    bfirstpage = "N"
   ENDIF
   IF ((request->include_statistics="Y"))
    IF (bfirsttimethru="Y")
     IF (value(size(stat_temp->srtd_path_qual,5)) > 0)
      ttl_cases_cnt = 0
      FOR (nbr_paths = 1 TO value(size(stat_temp->srtd_path_qual,5)))
        IF ((stat_temp->srtd_path_qual[nbr_paths].pathologist_name="Unassigned"))
         h_nbr_paths = nbr_paths
        ELSE
         row + 1, col 0, stat_temp->srtd_path_qual[nbr_paths].pathologist_name
         "#############################",
         col 32, stat_temp->srtd_path_qual[nbr_paths].cases_cnt"########", ttl_cases_cnt += stat_temp
         ->srtd_path_qual[nbr_paths].cases_cnt,
         col 42, stat_temp->srtd_path_qual[nbr_paths].correlated_events"#######", ttl_corr_events +=
         stat_temp->srtd_path_qual[nbr_paths].correlated_events,
         ttl_corr_evnt_prcnt_cnt += stat_temp->srtd_path_qual[nbr_paths].corr_evnt_prcnt_cnt,
         percent_total = format(cnvtreal(((cnvtreal(stat_temp->srtd_path_qual[nbr_paths].
            corr_evnt_prcnt_cnt)/ cnvtreal(stat_temp->srtd_path_qual[nbr_paths].cases_cnt)) * 100)),
          "###.#;I;F"), col 50,
         percent_total, col 57, stat_temp->srtd_path_qual[nbr_paths].agreements"#######",
         ttl_agreements += stat_temp->srtd_path_qual[nbr_paths].agreements, percent_agree = format(
          cnvtreal(((cnvtreal(stat_temp->srtd_path_qual[nbr_paths].agreements)/ cnvtreal(stat_temp->
            srtd_path_qual[nbr_paths].correlated_events)) * 100)),"###.#;I;F"), col 65,
         percent_agree, col 72, stat_temp->srtd_path_qual[nbr_paths].min_disagreements"#######",
         ttl_min_disagreements += stat_temp->srtd_path_qual[nbr_paths].min_disagreements, percent_min
          = format(cnvtreal(((cnvtreal(stat_temp->srtd_path_qual[nbr_paths].min_disagreements)/
           cnvtreal(stat_temp->srtd_path_qual[nbr_paths].correlated_events)) * 100)),"###.#;I;F"),
         col 80,
         percent_min, col 87, stat_temp->srtd_path_qual[nbr_paths].maj_disagreements"#######",
         ttl_maj_disagreements += stat_temp->srtd_path_qual[nbr_paths].maj_disagreements, percent_maj
          = format(cnvtreal(((cnvtreal(stat_temp->srtd_path_qual[nbr_paths].maj_disagreements)/
           cnvtreal(stat_temp->srtd_path_qual[nbr_paths].correlated_events)) * 100)),"###.#;I;F"),
         col 95,
         percent_maj, col 102, stat_temp->srtd_path_qual[nbr_paths].other"#######",
         ttl_other += stat_temp->srtd_path_qual[nbr_paths].other, percent_other = format(cnvtreal(((
           cnvtreal(stat_temp->srtd_path_qual[nbr_paths].other)/ cnvtreal(stat_temp->srtd_path_qual[
            nbr_paths].correlated_events)) * 100)),"###.#;I;F"), col 110,
         percent_other, col 117, stat_temp->srtd_path_qual[nbr_paths].incomplete"#######",
         ttl_incomplete += stat_temp->srtd_path_qual[nbr_paths].incomplete, percent_incomplete =
         format(cnvtreal(((cnvtreal(stat_temp->srtd_path_qual[nbr_paths].incomplete)/ cnvtreal(
            stat_temp->srtd_path_qual[nbr_paths].correlated_events)) * 100)),"###.#;I;F"), col 125,
         percent_incomplete
        ENDIF
      ENDFOR
      IF (h_nbr_paths > 0)
       IF ((stat_temp->srtd_path_qual[h_nbr_paths].pathologist_name="Unassigned"))
        row + 1, col 0, stat_temp->srtd_path_qual[h_nbr_paths].pathologist_name
        "#############################",
        col 32, stat_temp->srtd_path_qual[h_nbr_paths].cases_cnt"########", ttl_cases_cnt +=
        stat_temp->srtd_path_qual[h_nbr_paths].cases_cnt,
        col 42, stat_temp->srtd_path_qual[h_nbr_paths].correlated_events"#######", ttl_corr_events
         += stat_temp->srtd_path_qual[h_nbr_paths].correlated_events,
        ttl_corr_evnt_prcnt_cnt += stat_temp->srtd_path_qual[h_nbr_paths].corr_evnt_prcnt_cnt,
        percent_total = format(cnvtreal(((cnvtreal(stat_temp->srtd_path_qual[h_nbr_paths].
           corr_evnt_prcnt_cnt)/ cnvtreal(stat_temp->srtd_path_qual[h_nbr_paths].cases_cnt)) * 100)),
         "###.#;I;F"), col 50,
        percent_total, col 57, stat_temp->srtd_path_qual[h_nbr_paths].agreements"#######",
        ttl_agreements += stat_temp->srtd_path_qual[h_nbr_paths].agreements, percent_agree = format(
         cnvtreal(((cnvtreal(stat_temp->srtd_path_qual[h_nbr_paths].agreements)/ cnvtreal(stat_temp->
           srtd_path_qual[h_nbr_paths].correlated_events)) * 100)),"###.#;I;F"), col 65,
        percent_agree, col 72, stat_temp->srtd_path_qual[h_nbr_paths].min_disagreements"#######",
        ttl_min_disagreements += stat_temp->srtd_path_qual[h_nbr_paths].min_disagreements,
        percent_min = format(cnvtreal(((cnvtreal(stat_temp->srtd_path_qual[h_nbr_paths].
           min_disagreements)/ cnvtreal(stat_temp->srtd_path_qual[h_nbr_paths].correlated_events)) *
          100)),"###.#;I;F"), col 80,
        percent_min, col 87, stat_temp->srtd_path_qual[h_nbr_paths].maj_disagreements"#######",
        ttl_maj_disagreements += stat_temp->srtd_path_qual[h_nbr_paths].maj_disagreements,
        percent_maj = format(cnvtreal(((cnvtreal(stat_temp->srtd_path_qual[h_nbr_paths].
           maj_disagreements)/ cnvtreal(stat_temp->srtd_path_qual[h_nbr_paths].correlated_events)) *
          100)),"###.#;I;F"), col 95,
        percent_maj, col 102, stat_temp->srtd_path_qual[h_nbr_paths].other"#######",
        ttl_other += stat_temp->srtd_path_qual[h_nbr_paths].other, percent_other = format(cnvtreal(((
          cnvtreal(stat_temp->srtd_path_qual[h_nbr_paths].other)/ cnvtreal(stat_temp->srtd_path_qual[
           h_nbr_paths].correlated_events)) * 100)),"###.#;I;F"), col 110,
        percent_other, col 117, stat_temp->srtd_path_qual[h_nbr_paths].incomplete"#######",
        ttl_incomplete += stat_temp->srtd_path_qual[h_nbr_paths].incomplete, percent_incomplete =
        format(cnvtreal(((cnvtreal(stat_temp->srtd_path_qual[h_nbr_paths].incomplete)/ cnvtreal(
           stat_temp->srtd_path_qual[h_nbr_paths].correlated_events)) * 100)),"###.#;I;F"), col 125,
        percent_incomplete
       ENDIF
      ENDIF
      row + 1, col 0, captions->ttotal,
      col 32, ttl_cases_cnt"########", col 42,
      ttl_corr_events"#######", ttl_percent_total = format(cnvtreal(((cnvtreal(
         ttl_corr_evnt_prcnt_cnt)/ cnvtreal(ttl_cases_cnt)) * 100)),"###.#;I;F"), col 50,
      ttl_percent_total, col 57, ttl_agreements"#######",
      ttl_percent_agreements = format(cnvtreal(((cnvtreal(ttl_agreements)/ cnvtreal(ttl_corr_events))
         * 100)),"###.#;I;F"), col 65, ttl_percent_agreements,
      col 72, ttl_min_disagreements"#######", ttl_percent_min_disagreements = format(cnvtreal(((
        cnvtreal(ttl_min_disagreements)/ cnvtreal(ttl_corr_events)) * 100)),"###.#;I;F"),
      col 80, ttl_percent_min_disagreements, col 87,
      ttl_maj_disagreements"#######", ttl_percent_maj_disagreements = format(cnvtreal(((cnvtreal(
         ttl_maj_disagreements)/ cnvtreal(ttl_corr_events)) * 100)),"###.#;I;F"), col 95,
      ttl_percent_maj_disagreements, col 102, ttl_other"#######",
      ttl_percent_other = format(cnvtreal(((cnvtreal(ttl_other)/ cnvtreal(ttl_corr_events)) * 100)),
       "###.#;I;F"), col 110, ttl_percent_other,
      col 117, ttl_incomplete"#######", ttl_percent_incomplete = format(cnvtreal(((cnvtreal(
         ttl_incomplete)/ cnvtreal(ttl_corr_events)) * 100)),"###.#;I;F"),
      col 125, ttl_percent_incomplete
      IF ((request->include_case_info="Y"))
       row + 2,
       CALL center(20stars,0,132), row + 1,
       CALL center(captions->caseinformation,0,132), row + 1,
       CALL center(20stars,0,132)
       IF (valid_cases_to_print="N")
        row + 2,
        CALL center(captions->nocasesmatchcrit,0,132)
       ENDIF
      ENDIF
     ELSE
      row + 1, col 0, captions->nopathselected
      IF ((request->include_case_info="Y"))
       row + 2,
       CALL center(20stars,0,132), row + 1,
       CALL center(captions->caseinformation,0,132), row + 1,
       CALL center(20stars,0,132),
       row + 2,
       CALL center(captions->nocasesmatchcrit,0,132)
      ENDIF
     ENDIF
    ENDIF
    bfirsttimethru = "N"
   ELSEIF (valid_cases_to_print="N")
    row + 2,
    CALL center(20stars,0,132), row + 1,
    CALL center(captions->caseinformation,0,132), row + 1,
    CALL center(20stars,0,132),
    row + 2,
    CALL center(captions->nocasesmatchcrit,0,132)
   ELSE
    IF (bfirsttimethru="Y")
     row + 2,
     CALL center(20stars,0,132), row + 1,
     CALL center(captions->caseinformation,0,132), row + 1,
     CALL center(20stars,0,132),
     bfirsttimethru = "N"
    ENDIF
   ENDIF
  HEAD pathologist_name
   IF ((request->include_case_info="Y"))
    IF (head_cntr > 0
     AND (request->bpagebreak="T"))
     BREAK
    ENDIF
    head_cntr += 1, row + 1, col 0,
    captions->corractivity, " ", pathologist_name
   ENDIF
  DETAIL
   IF ((request->include_case_info="Y"))
    row + 1, col 0, captions->ccase2,
    col 20, captions->compareto, col 40,
    captions->bby, col 50, captions->finaleval,
    col 67, captions->discrepancy, col 83,
    captions->reason, col 99, captions->investigation,
    col 115, captions->resolution, row + 1,
    col 0, "-------------------", col 20,
    "-------------------", col 40, "---------",
    col 50, "----------------", col 67,
    "--------------", col 83, "---------------",
    col 99, "---------------", col 115,
    "---------------", sformataccession = uar_fmt_accession(stat_temp->srtd_path_qual[d1.seq].
     case_qual[d2.seq].case_accession,size(trim(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].
       case_accession),1)), row + 1,
    col 0, sformataccession
    IF ((generic_temp->across_case_ind=1))
     scomparetoaccession = uar_fmt_accession(stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].
      corr_qual[d3.seq].correlate_accession,size(trim(stat_temp->srtd_path_qual[d1.seq].case_qual[d2
        .seq].corr_qual[d3.seq].correlate_accession),1)), col 20, scomparetoaccession
    ELSE
     col 20, captions->na
    ENDIF
    col 40
    IF ((stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].individ_or_group="I"))
     stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].corr_initials
    ELSE
     captions->ggroup
    ENDIF
    col 50, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
    final_eval_term_disp"################", col 67,
    stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].final_discrep_term_disp
    "###############", col 83, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
    disagree_reason_disp"###############",
    col 99, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].investigation_disp
    "###############", col 115,
    stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].resolution_disp
    "###############"
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
    IF ((stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].long_text_cntr > 0))
     row + 2, col 20, captions->corrcomment,
     row + 1, col 20
     FOR (loop1 = 1 TO stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
     long_text_cntr)
       row + 1, col 20, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
       long_text_qual[loop1].text
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
     ENDFOR
    ELSE
     row + 1
    ENDIF
    IF ((request->include_report_text="Y"))
     row + 2, col 20, captions->ccase,
     sformataccession, temp_catlog_cd = 0.0
     FOR (loop1 = 1 TO stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_cnt)
       IF ((stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_qual[loop1].catalog_cd !=
       temp_catlog_cd))
        ind = locateval(locindx,1,catalog_cnt,stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].
         v_proc_qual[loop1].catalog_cd,catalog->catalog_qual[locindx].catalog_cd)
        IF (ind > 0)
         row + 1, col 20, captions->rreport,
         " ", catalog->catalog_qual[ind].catalog_disp, row + 1
        ENDIF
        temp_catlog_cd = stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_qual[loop1].
        catalog_cd
       ENDIF
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
       IF ((stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_qual[loop1].text_cnt > 0))
        row + 1, col 20, captions->section,
        " ", col 29, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_qual[loop1].
        discrete_task_assay_disp
        FOR (loop2 = 1 TO stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_qual[loop1].
        text_cnt)
          row + 1, col 20, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].v_proc_qual[loop1].
          text_qual[loop2].text
          IF (((row+ 10) > maxrow))
           BREAK
          ENDIF
        ENDFOR
        row + 1
       ENDIF
     ENDFOR
     IF ((generic_temp->across_case_ind=1))
      temp_catlog_cd = 0.0, row + 2, col 20,
      captions->ccase, " ", sformatcompaccession = uar_fmt_accession(stat_temp->srtd_path_qual[d1.seq
       ].case_qual[d2.seq].corr_qual[d3.seq].correlate_accession,size(trim(stat_temp->srtd_path_qual[
         d1.seq].case_qual[d2.seq].corr_qual[d3.seq].correlate_accession),1)),
      col 27, sformatcompaccession
      FOR (loop1 = 1 TO stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
      v_comp_cnt)
        IF ((stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].v_comp_qual[loop1]
        .catalog_cd != temp_catlog_cd))
         ind = locateval(locindx,1,catalog_cnt,stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].
          corr_qual[d3.seq].v_comp_qual[loop1].catalog_cd,catalog->catalog_qual[locindx].catalog_cd)
         IF (ind > 0)
          row + 1, col 20, captions->rreport,
          " ", catalog->catalog_qual[ind].catalog_disp, row + 1
         ENDIF
         temp_catlog_cd = stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
         v_comp_qual[loop1].catalog_cd
        ENDIF
        IF (((row+ 10) > maxrow))
         BREAK
        ENDIF
        IF ((stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].v_comp_qual[loop1]
        .text_cnt > 0))
         row + 1, col 20, captions->section,
         " ", col 29, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
         v_comp_qual[loop1].discrete_task_assay_disp
         FOR (loop2 = 1 TO stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
         v_comp_qual[loop1].text_cnt)
           row + 1, col 20, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
           v_comp_qual[loop1].text_qual[loop2].text
           IF (((row+ 10) > maxrow))
            BREAK
           ENDIF
         ENDFOR
         row + 1
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    IF ((stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].individ_or_group="G"))
     row + 1, col 10, captions->groupname,
     " ", col 22, stat_temp->srtd_path_qual[d1.seq].case_qual[d2.seq].corr_qual[d3.seq].
     corr_group_name,
     row + 1
    ENDIF
   ENDIF
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->apsprtdiagcorrrpt,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued
  FOOT REPORT
   col 55, "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET lerrorcode = error(serrormessage,0)
 IF (lerrorcode != 0)
  SET reply->status_data.subeventstatus.operationname = "Error printing report"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = serrormessage
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
