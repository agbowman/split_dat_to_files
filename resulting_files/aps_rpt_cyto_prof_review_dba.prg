CREATE PROGRAM aps_rpt_cyto_prof_review:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD temp(
   1 junk_date = dq8
   1 run_group = c40
   1 run_user = c40
   1 start_dt = dq8
   1 end_dt = dq8
   1 group_qual[*]
     2 prsnl_group_id = f8
     2 prsnl_group_name = vc
     2 cur_qual[*]
       3 prsnl_id = f8
       3 name_full_formatted = c40
       3 slide_limit = i4
       3 screening_hrs = i4
       3 max_per_hr = f8
       3 cur_limit_date = dq8
       3 cur_limit_reviewer_name = c40
       3 cur_limit_comment_text_cnt = i4
       3 cur_limit_comment_qual[*]
         4 comment = vc
       3 verify_sec_level = i4
       3 pct_no_norm_hist = i4
       3 pct_atyp_hist = i4
       3 pct_abn_hist = i4
       3 pct_chr = i4
       3 pct_unsat = i4
       3 cur_qa_date = dq8
       3 cur_qa_reviewer_name = c40
       3 cur_qa_comment_text_cnt = i4
       3 cur_qa_comment_qual[*]
         4 comment = vc
       3 prof_qual[*]
         4 proficiency_type_disp = c40
         4 reviewer_name = c40
         4 reviewed_dttm = dq8
         4 comment_text_cnt = i4
         4 comment_qual[*]
           5 comment = vc
     2 prev_qual[*]
       3 limits_qual[*]
         4 slide_limit = i4
         4 screening_hrs = i4
         4 max_per_hr = f8
         4 date = dq8
         4 reviewer_name = c40
         4 comment_text_cnt = i4
         4 comment_qual[*]
           5 comment = vc
       3 qa_qual[*]
         4 verify_sec_level = i4
         4 pct_no_norm_hist = i4
         4 pct_atyp_hist = i4
         4 pct_abn_hist = i4
         4 pct_chr = i4
         4 pct_unsat = i4
         4 date = dq8
         4 reviewer_name = c40
         4 comment_text_cnt = i4
         4 comment_qual[*]
           5 comment = vc
       3 prof_qual[*]
         4 proficiency_type_disp = c40
         4 reviewer_name = c40
         4 date = dq8
         4 comment_text_cnt = i4
         4 comment_qual[*]
           5 comment = vc
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
 RECORD captions(
   1 rpt = vc
   1 ana = vc
   1 dt = vc
   1 tm = vc
   1 dir = vc
   1 cyt = vc
   1 bye = vc
   1 pg = vc
   1 grp = vc
   1 use = vc
   1 dt_rg = vc
   1 lg = vc
   1 tot_sl = vc
   1 sec = vc
   1 tot_hr = vc
   1 his = vc
   1 calc = vc
   1 atyp = vc
   1 abn = vc
   1 risk = vc
   1 unsat = vc
   1 curr = vc
   1 event = vc
   1 comm = vc
   1 none = vc
   1 prev = vc
   1 no_prev = vc
   1 req = vc
   1 no_req = vc
   1 prof = vc
   1 title = vc
   1 cont = vc
   1 no_prof = vc
   1 end_prof = vc
 )
 SET lrg =
 "--- CURRENT LIMITS -------------------------            --- CURRENT QA RESCREENING REQUIREMENTS ---"
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"t1","REPORT: APS_RPT_CYTO_PROF_REVIEW.PRG")
 SET captions->ana = uar_i18ngetmessage(i18nhandle,"t2","Anatomic Pathology")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t3","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t4","DIRECTORY:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t5","TIME:")
 SET captions->cyt = uar_i18ngetmessage(i18nhandle,"t6","CYTOLOGY PROFICIENCY REVIEW BY USER")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t7","BY:")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t8","PAGE:")
 SET captions->grp = uar_i18ngetmessage(i18nhandle,"t9","GROUP:")
 SET captions->use = uar_i18ngetmessage(i18nhandle,"t10","USER:")
 SET captions->dt_rg = uar_i18ngetmessage(i18nhandle,"t11","DATE RANGE:")
 SET captions->lg = uar_i18ngetmessage(i18nhandle,"t12",lrg)
 SET captions->tot_sl = uar_i18ngetmessage(i18nhandle,"t13","TOTAL # SLIDES:")
 SET captions->sec = uar_i18ngetmessage(i18nhandle,"t14","VERIFICATION SECURITY LEVEL:")
 SET captions->tot_hr = uar_i18ngetmessage(i18nhandle,"t15","TOTAL # HOURS:")
 SET captions->his = uar_i18ngetmessage(i18nhandle,"t16","% WITH NO, OR NORMAL HISTORY:")
 SET captions->calc = uar_i18ngetmessage(i18nhandle,"t17","CALCULATED MAXIMUM # SLIDES PER HOUR:")
 SET captions->atyp = uar_i18ngetmessage(i18nhandle,"t18","% ATYPICAL HISTORY:")
 SET captions->abn = uar_i18ngetmessage(i18nhandle,"t19","% ABNORMAL HISTORY:")
 SET captions->risk = uar_i18ngetmessage(i18nhandle,"t20","% WITH CLINICAL HIGH RISK:")
 SET captions->unsat = uar_i18ngetmessage(i18nhandle,"t21","% UNSATISFACTORY:")
 SET captions->curr = uar_i18ngetmessage(i18nhandle,"t22",
  "--- CURRENT PROFICIENCY EVENTS -------------")
 SET captions->event = uar_i18ngetmessage(i18nhandle,"t23","EVENT:")
 SET captions->comm = uar_i18ngetmessage(i18nhandle,"t24","COMMENT:")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"t25",
  "** NO CURRENT PROFICIENCIES FOR THIS USER **")
 SET captions->prev = uar_i18ngetmessage(i18nhandle,"t26",
  "--- PREVIOUS LIMITS ------------------------")
 SET captions->no_prev = uar_i18ngetmessage(i18nhandle,"t27","** NO PREVIOUS LIMITS FOR THIS USER **"
  )
 SET captions->req = uar_i18ngetmessage(i18nhandle,"t28",
  "--- PREVIOUS QA RESCREENING REQUIREMENTS ----")
 SET captions->no_req = uar_i18ngetmessage(i18nhandle,"t29",
  "** NO PREVIOUS QA RESCREENING REQUIREMENTS FOR THIS USER **")
 SET captions->prof = uar_i18ngetmessage(i18nhandle,"t30",
  "--- PREVIOUS PROFICIENCY EVENTS ------------")
 SET captions->title = uar_i18ngetmessage(i18nhandle,"t31",
  "REPORT: CYTOLOGY PROFICIENCY REVIEW BY USER")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"t32","CONTINUED...")
 SET captions->no_prof = uar_i18ngetmessage(i18nhandle,"t33",
  "** NO PREVIOUS PROFICIENCY EVENTS FOR THIS USER **")
 SET captions->end_prof = uar_i18ngetmessage(i18nhandle,"t34",
  "*** end of current user proficiencies ***")
#script
 SET junk_date = cnvtdatetime("01-JAN-1800, 00:00")
 SET reply->status_data.status = "F"
 SET error_cnt = 0
 SET max_scrnr_cnt = 0
 SET max_cur_prof_cnt = 0
 SET max_prev_limit_cnt = 0
 SET max_prev_qa_cnt = 0
 SET max_prev_prof_cnt = 0
 SET check_pg_active = fillstring(30," ")
 SET check_pgr_active = fillstring(30," ")
 SET check_pgr2_active = fillstring(30," ")
 CALL initresourcesecurity(1)
 CALL populatesrtypesforsecurity(1)
 IF ((request->bshowinactives=0))
  SET check_pg_active = " pg.active_ind = 1"
  SET check_pgr_active = " pgr.active_ind = 1"
  SET check_pgr2_active = " pgr2.active_ind = 1"
 ELSE
  SET check_pg_active = " pg.active_ind in (1, 0)"
  SET check_pgr_active = " pgr.active_ind in (1, 0)"
  SET check_pgr2_active = " pgr2.active_ind in (1, 0)"
 ENDIF
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
  SET raw_prsnl_group = fillstring(100," ")
  SET raw_prsnl = fillstring(100," ")
  SET raw_date_str = fillstring(4," ")
  SET raw_date_num_str = 0
  SET printer = fillstring(100," ")
  SET copies = 0
  IF (textlen(trim(request->output_dist))=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with output_dist!"
   GO TO end_script
  ENDIF
  SELECT INTO "nl:"
   x = 1
   DETAIL
    CALL get_text(x,trim(request->batch_selection),"|"), request->mode = cnvtint(trim(text)),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    raw_prsnl_group = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_prsnl = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_date_str = trim(text), request->
    curuser = "Operations",
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->page_break = cnvtint(trim(
      text)),
    CALL get_text(1,trim(request->output_dist),"|"),
    printer = trim(text),
    CALL get_text(startpos2,trim(request->output_dist),"|"), copies = cnvtint(trim(text))
   WITH nocounter
  ;end select
  IF (textlen(trim(raw_prsnl_group)) > 0)
   SELECT INTO "nl:"
    cv.code_value, pg.prsnl_group_id
    FROM code_value cv,
     prsnl_group pg
    PLAN (cv
     WHERE cv.code_set=357
      AND cv.cdf_meaning="CYTORPTGRP")
     JOIN (pg
     WHERE cv.code_value=pg.prsnl_group_type_cd
      AND raw_prsnl_group=pg.prsnl_group_name
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
   SELECT INTO "nl:"
    cv.code_value, pg.prsnl_group_id
    FROM code_value cv,
     prsnl_group pg
    PLAN (cv
     WHERE cv.code_set=357
      AND cv.cdf_meaning="CYTORPTGRP")
     JOIN (pg
     WHERE cv.code_value=pg.prsnl_group_type_cd
      AND parser(check_pg_active)
      AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     service_resource_cd = pg.service_resource_cd,
     CALL isresourceviewable(service_resource_cd)
    WITH nocounter
   ;end select
   IF (((curqual=0) OR (getresourcesecuritystatus(0) != "S")) )
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with prsnl_group id!"
    GO TO end_script
   ENDIF
  ENDIF
  IF (textlen(trim(raw_prsnl)) > 0)
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p
    WHERE raw_prsnl=p.username
    DETAIL
     request->prsnl_id = p.person_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with prsnl setup!"
    GO TO end_script
   ENDIF
  ELSE
   SET request->prsnl_id = 0
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
 SET temp->start_dt = cnvtdatetime(request->start_dt)
 SET temp->end_dt = cnvtdatetime(request->end_dt)
 IF ((request->mode=0))
  SELECT INTO "nl:"
   cv.code_value, pg.prsnl_group_id
   FROM code_value cv,
    prsnl_group pg
   PLAN (cv
    WHERE cv.code_set=357
     AND cv.cdf_meaning="CYTORPTGRP")
    JOIN (pg
    WHERE cv.code_value=pg.prsnl_group_type_cd
     AND parser(check_pg_active)
     AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
   HEAD REPORT
    cnt = 0, service_resource_cd = 0.0
   DETAIL
    service_resource_cd = pg.service_resource_cd
    IF (isresourceviewable(service_resource_cd)=true)
     cnt += 1, stat = alterlist(temp->group_qual,cnt), temp->group_qual[cnt].prsnl_group_id = pg
     .prsnl_group_id,
     temp->group_qual[cnt].prsnl_group_name = pg.prsnl_group_name
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","CODE_VALUE 1")
   GO TO exit_script
  ELSEIF (getresourcesecuritystatus(0)="F")
   SET reply->status_data.status = getresourcesecuritystatus(0)
   CALL populateressecstatusblock(0)
   GO TO end_script
  ENDIF
  SET temp->run_group = "ALL"
 ELSEIF ((request->mode IN (1, 2)))
  SELECT INTO "nl:"
   pg.prsnl_group_name
   FROM prsnl_group pg
   WHERE (request->prsnl_group_id=pg.prsnl_group_id)
    AND parser(check_pg_active)
    AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pg.end_effective_dt_tm > cnvtdatetime(sysdate)
   DETAIL
    stat = alterlist(temp->group_qual,1), temp->group_qual[1].prsnl_group_id = pg.prsnl_group_id,
    temp->group_qual[1].prsnl_group_name = pg.prsnl_group_name,
    temp->run_group = trim(pg.prsnl_group_name)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","PRSNL_GROUP")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->mode IN (0, 1)))
  SET temp->run_user = "ALL"
  SELECT INTO "nl:"
   d.seq, pgr.prsnl_group_reltn_id, pgr2.prsnl_group_reltn_id,
   p.name_full_formatted
   FROM (dummyt d  WITH seq = value(size(temp->group_qual,5))),
    prsnl_group_reltn pgr,
    prsnl p,
    code_value cv,
    prsnl_group pg,
    prsnl_group_reltn pgr2
   PLAN (d)
    JOIN (pgr
    WHERE (temp->group_qual[d.seq].prsnl_group_id=pgr.prsnl_group_id)
     AND parser(check_pgr_active))
    JOIN (p
    WHERE pgr.person_id=p.person_id)
    JOIN (cv
    WHERE cv.code_set=357
     AND cv.cdf_meaning="CYTOTECH")
    JOIN (pg
    WHERE cv.code_value=pg.prsnl_group_type_cd
     AND parser(check_pg_active)
     AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (pgr2
    WHERE pg.prsnl_group_id=pgr2.prsnl_group_id
     AND pgr.person_id=pgr2.person_id
     AND parser(check_pgr2_active))
   HEAD REPORT
    stat = 0
   HEAD d.seq
    cnt = 0
   DETAIL
    cnt += 1, stat = alterlist(temp->group_qual[d.seq].cur_qual,cnt), stat = alterlist(temp->
     group_qual[d.seq].prev_qual,cnt),
    temp->group_qual[d.seq].cur_qual[cnt].prsnl_id = pgr2.person_id, temp->group_qual[d.seq].
    cur_qual[cnt].name_full_formatted = p.name_full_formatted
    IF (cnt > max_scrnr_cnt)
     max_scrnr_cnt = cnt
    ENDIF
   FOOT  d.seq
    cnt = 0
   FOOT REPORT
    IF (d.seq < value(size(temp->group_qual,5)))
     stat = alterlist(temp->group_qual,d.seq)
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   pgr.prsnl_group_reltn_id, pgr2.prsnl_group_reltn_id, p.name_full_formatted
   FROM prsnl_group_reltn pgr,
    prsnl p,
    code_value cv,
    prsnl_group pg,
    prsnl_group_reltn pgr2
   PLAN (pgr
    WHERE (temp->group_qual[1].prsnl_group_id=pgr.prsnl_group_id)
     AND (request->prsnl_id=pgr.person_id)
     AND parser(check_pgr_active))
    JOIN (p
    WHERE pgr.person_id=p.person_id)
    JOIN (cv
    WHERE cv.code_set=357
     AND cv.cdf_meaning="CYTOTECH")
    JOIN (pg
    WHERE cv.code_value=pg.prsnl_group_type_cd
     AND parser(check_pg_active)
     AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (pgr2
    WHERE pg.prsnl_group_id=pgr2.prsnl_group_id
     AND pgr.person_id=pgr2.person_id
     AND parser(check_pgr2_active))
   DETAIL
    stat = alterlist(temp->group_qual[1].cur_qual,1), stat = alterlist(temp->group_qual[1].prev_qual,
     1), temp->group_qual[1].cur_qual[1].prsnl_id = pgr2.person_id,
    temp->group_qual[1].cur_qual[1].name_full_formatted = p.name_full_formatted, temp->run_user =
    temp->group_qual[1].cur_qual[1].name_full_formatted
   WITH nocounter
  ;end select
  SET max_scrnr_cnt = 1
 ENDIF
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","PRSNL_GROUP_RELTN")
  GO TO exit_script
 ENDIF
 SET comment_substring = fillstring(100," ")
 SET real_loop = 0.0
 SET int_loop = 0
 SET string_loop = " "
 SELECT INTO "nl:"
  d1_seq = d1.seq, d2_seq = d2.seq, csl.*,
  p.name_full_formatted, csl_null_check = nullind(csl.reviewed_dt_tm)
  FROM (dummyt d1  WITH seq = value(size(temp->group_qual,5))),
   (dummyt d2  WITH seq = value(max_scrnr_cnt)),
   cyto_screening_limits csl,
   prsnl p
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->group_qual[d1.seq].cur_qual,5))
   JOIN (csl
   WHERE (temp->group_qual[d1.seq].cur_qual[d2.seq].prsnl_id=csl.prsnl_id))
   JOIN (p
   WHERE csl.reviewer_id=p.person_id)
  ORDER BY d1_seq, d2_seq, cnvtdatetime(csl.reviewed_dt_tm) DESC,
   cnvtdatetime(csl.updt_dt_tm) DESC
  HEAD REPORT
   slide_limit = 0.0, screening_hrs = 0.0
  HEAD d2_seq
   csl_cnt = 0
  HEAD csl.prsnl_id
   lentext = 0, comment_cnt = 0, pos = 1
  DETAIL
   IF (csl.active_ind=1)
    temp->group_qual[d1.seq].cur_qual[d2.seq].slide_limit = csl.slide_limit, temp->group_qual[d1.seq]
    .cur_qual[d2.seq].screening_hrs = csl.screening_hours, slide_limit = csl.slide_limit,
    screening_hrs = csl.screening_hours, temp->group_qual[d1.seq].cur_qual[d2.seq].max_per_hr = (
    slide_limit/ screening_hrs)
    IF (csl_null_check=0)
     temp->group_qual[d1.seq].cur_qual[d2.seq].cur_limit_date = cnvtdatetime(csl.reviewed_dt_tm)
    ENDIF
    temp->group_qual[d1.seq].cur_qual[d2.seq].cur_limit_reviewer_name = p.name_full_formatted,
    lentext = textlen(trim(csl.comments))
    IF (lentext > 0)
     real_loop = (lentext/ 40), string_loop = trim(cnvtstring(real_loop)), int_loop = cnvtint(
      string_loop)
     IF (mod(lentext,40) != 0)
      int_loop += 1
     ENDIF
     stat = alterlist(temp->group_qual[d1.seq].cur_qual[d2.seq].cur_limit_comment_qual,int_loop),
     temp->group_qual[d1.seq].cur_qual[d2.seq].cur_limit_comment_text_cnt = int_loop, pos = 1
     FOR (comment_cnt = 1 TO int_loop)
       comment_substring = substring(pos,40,trim(csl.comments)), temp->group_qual[d1.seq].cur_qual[d2
       .seq].cur_limit_comment_qual[comment_cnt].comment = comment_substring, pos += 40
     ENDFOR
     pos = 1
    ENDIF
   ELSEIF (csl.active_ind=0)
    csl_cnt += 1, stat = alterlist(temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual,csl_cnt),
    temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[csl_cnt].slide_limit = csl.slide_limit,
    temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[csl_cnt].screening_hrs = csl
    .screening_hours, slide_limit = csl.slide_limit, screening_hrs = csl.screening_hours,
    temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[csl_cnt].max_per_hr = (slide_limit/
    screening_hrs)
    IF (csl_null_check=0)
     temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[csl_cnt].date = cnvtdatetime(csl
      .reviewed_dt_tm)
    ELSE
     temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[csl_cnt].date = cnvtdatetime(csl
      .updt_dt_tm)
    ENDIF
    temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[csl_cnt].reviewer_name = p
    .name_full_formatted, lentext = textlen(trim(csl.comments))
    IF (lentext > 0)
     real_loop = (lentext/ 50), string_loop = trim(cnvtstring(real_loop)), int_loop = cnvtint(
      string_loop)
     IF (mod(lentext,50) != 0)
      int_loop += 1
     ENDIF
     stat = alterlist(temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[csl_cnt].comment_qual,
      int_loop), temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[csl_cnt].comment_text_cnt =
     int_loop
     FOR (comment_cnt = 1 TO int_loop)
       comment_substring = substring(pos,50,trim(csl.comments)), temp->group_qual[d1.seq].prev_qual[
       d2.seq].limits_qual[csl_cnt].comment_qual[comment_cnt].comment = comment_substring, pos += 50
     ENDFOR
     pos = 1
    ENDIF
    IF (csl_cnt > max_prev_limit_cnt)
     max_prev_limit_cnt = csl_cnt
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","CYTOLOGY_SCREENING_LIMITS")
  GO TO exit_script
 ENDIF
 SET comment_substring = fillstring(100," ")
 SET real_loop = 0.0
 SET int_loop = 0
 SET string_loop = " "
 SELECT INTO "nl:"
  d1_seq = d1.seq, d2_seq = d2.seq, css.*,
  p.name_full_formatted, css_null_check = nullind(css.reviewed_dt_tm)
  FROM (dummyt d1  WITH seq = value(size(temp->group_qual,5))),
   (dummyt d2  WITH seq = value(max_scrnr_cnt)),
   cyto_screening_security css,
   prsnl p
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->group_qual[d1.seq].cur_qual,5))
   JOIN (css
   WHERE (temp->group_qual[d1.seq].cur_qual[d2.seq].prsnl_id=css.prsnl_id))
   JOIN (p
   WHERE css.reviewer_id=p.person_id)
  ORDER BY d1_seq, d2_seq, cnvtdatetime(css.reviewed_dt_tm) DESC
  HEAD d2_seq
   css_cnt = 0
  HEAD css.prsnl_id
   lentext = 0, comment_cnt = 0, pos = 1
  DETAIL
   IF (css.active_ind=1)
    temp->group_qual[d1.seq].cur_qual[d2.seq].verify_sec_level = css.verify_level, temp->group_qual[
    d1.seq].cur_qual[d2.seq].pct_no_norm_hist = css.normal_percentage, temp->group_qual[d1.seq].
    cur_qual[d2.seq].pct_atyp_hist = css.atypical_percentage,
    temp->group_qual[d1.seq].cur_qual[d2.seq].pct_abn_hist = css.abnormal_percentage, temp->
    group_qual[d1.seq].cur_qual[d2.seq].pct_chr = css.chr_percentage, temp->group_qual[d1.seq].
    cur_qual[d2.seq].pct_unsat = css.unsat_percentage
    IF (css_null_check=0)
     temp->group_qual[d1.seq].cur_qual[d2.seq].cur_qa_date = cnvtdatetime(css.reviewed_dt_tm)
    ENDIF
    temp->group_qual[d1.seq].cur_qual[d2.seq].cur_qa_reviewer_name = p.name_full_formatted, lentext
     = textlen(trim(css.comments))
    IF (lentext > 0)
     real_loop = (lentext/ 40), string_loop = trim(cnvtstring(real_loop)), int_loop = cnvtint(
      string_loop)
     IF (mod(lentext,40) != 0)
      int_loop += 1
     ENDIF
     stat = alterlist(temp->group_qual[d1.seq].cur_qual[d2.seq].cur_qa_comment_qual,int_loop), temp->
     group_qual[d1.seq].cur_qual[d2.seq].cur_qa_comment_text_cnt = int_loop, pos = 1
     FOR (comment_cnt = 1 TO int_loop)
       comment_substring = substring(pos,40,trim(css.comments)), temp->group_qual[d1.seq].cur_qual[d2
       .seq].cur_qa_comment_qual[comment_cnt].comment = comment_substring, pos += 40
     ENDFOR
     pos = 1
    ENDIF
   ELSE
    css_cnt += 1, stat = alterlist(temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual,css_cnt), temp
    ->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[css_cnt].verify_sec_level = css.verify_level,
    temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[css_cnt].pct_no_norm_hist = css
    .normal_percentage, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[css_cnt].pct_atyp_hist =
    css.atypical_percentage, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[css_cnt].pct_abn_hist
     = css.abnormal_percentage,
    temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[css_cnt].pct_chr = css.chr_percentage, temp->
    group_qual[d1.seq].prev_qual[d2.seq].qa_qual[css_cnt].pct_unsat = css.unsat_percentage, temp->
    group_qual[d1.seq].prev_qual[d2.seq].qa_qual[css_cnt].reviewer_name = p.name_full_formatted
    IF (css_null_check=0)
     temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[css_cnt].date = cnvtdatetime(css
      .reviewed_dt_tm)
    ELSE
     temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[css_cnt].date = cnvtdatetime(css.updt_dt_tm)
    ENDIF
    lentext = textlen(trim(css.comments))
    IF (lentext > 0)
     real_loop = (lentext/ 50), string_loop = trim(cnvtstring(real_loop)), int_loop = cnvtint(
      string_loop)
     IF (mod(lentext,50) != 0)
      int_loop += 1
     ENDIF
     stat = alterlist(temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[css_cnt].comment_qual,
      int_loop), temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[css_cnt].comment_text_cnt =
     int_loop
     FOR (comment_cnt = 1 TO int_loop)
       comment_substring = substring(pos,50,trim(css.comments)), temp->group_qual[d1.seq].prev_qual[
       d2.seq].qa_qual[css_cnt].comment_qual[comment_cnt].comment = comment_substring, pos += 50
     ENDFOR
     pos = 1
    ENDIF
    IF (css_cnt > max_prev_qa_cnt)
     max_prev_qa_cnt = css_cnt
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","CYTOLOGY_SCREENING_SECURITY")
  GO TO exit_script
 ENDIF
 SET comment_substring = fillstring(100," ")
 SET real_loop = 0.0
 SET int_loop = 0
 SET string_loop = " "
 SELECT INTO "nl:"
  d1_seq = d1.seq, d2_seq = d2.seq, pe.prsnl_id,
  pe.proficiency_type_cd, p.name_full_formatted, cv.code_value
  FROM (dummyt d1  WITH seq = value(size(temp->group_qual,5))),
   (dummyt d2  WITH seq = value(max_scrnr_cnt)),
   proficiency_event pe,
   prsnl p,
   code_value cv
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->group_qual[d1.seq].cur_qual,5))
   JOIN (pe
   WHERE (temp->group_qual[d1.seq].cur_qual[d2.seq].prsnl_id=pe.prsnl_id))
   JOIN (cv
   WHERE pe.proficiency_type_cd=cv.code_value)
   JOIN (p
   WHERE pe.reviewer_id=p.person_id)
  ORDER BY d1_seq, d2_seq, cnvtdatetime(pe.reviewed_dt_tm) DESC
  HEAD d1_seq
   cur_cnt = 0, prev_cnt = 0
  HEAD d2_seq
   cur_cnt = 0, prev_cnt = 0
  HEAD pe.proficiency_type_cd
   lentext = 0, comment_cnt = 0, pos = 1
  DETAIL
   IF (pe.active_ind=1)
    cur_cnt += 1, stat = alterlist(temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual,cur_cnt), temp
    ->group_qual[d1.seq].cur_qual[d2.seq].prof_qual[cur_cnt].proficiency_type_disp = cv.display,
    temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual[cur_cnt].reviewer_name = p
    .name_full_formatted, temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual[cur_cnt].reviewed_dttm
     = cnvtdatetime(pe.reviewed_dt_tm), lentext = textlen(trim(pe.comments))
    IF (lentext > 0)
     real_loop = (lentext/ 100), string_loop = trim(cnvtstring(real_loop)), int_loop = cnvtint(
      string_loop)
     IF (mod(lentext,100) != 0)
      int_loop += 1
     ENDIF
     stat = alterlist(temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual[cur_cnt].comment_qual,
      int_loop), temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual[cur_cnt].comment_text_cnt =
     int_loop
     FOR (comment_cnt = 1 TO int_loop)
       comment_substring = substring(pos,100,trim(pe.comments)), temp->group_qual[d1.seq].cur_qual[d2
       .seq].prof_qual[cur_cnt].comment_qual[comment_cnt].comment = comment_substring, pos += 100
     ENDFOR
     pos = 1
    ENDIF
    IF (cur_cnt > max_cur_prof_cnt)
     max_cur_prof_cnt = cur_cnt
    ENDIF
   ELSEIF (pe.active_ind=0)
    prev_cnt += 1, stat = alterlist(temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual,prev_cnt),
    temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual[prev_cnt].proficiency_type_disp = cv.display,
    temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual[prev_cnt].reviewer_name = p
    .name_full_formatted, temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual[prev_cnt].date =
    cnvtdatetime(pe.reviewed_dt_tm), lentext = textlen(trim(pe.comments))
    IF (lentext > 0)
     real_loop = (lentext/ 100), string_loop = trim(cnvtstring(real_loop)), int_loop = cnvtint(
      string_loop)
     IF (mod(lentext,100) != 0)
      int_loop += 1
     ENDIF
     stat = alterlist(temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual[prev_cnt].comment_qual,
      int_loop), temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual[prev_cnt].comment_text_cnt =
     int_loop
     FOR (comment_cnt = 1 TO int_loop)
       comment_substring = substring(pos,100,trim(pe.comments)), temp->group_qual[d1.seq].prev_qual[
       d2.seq].prof_qual[prev_cnt].comment_qual[comment_cnt].comment = comment_substring, pos += 100
     ENDFOR
     pos = 1
    ENDIF
    IF (prev_cnt > max_prev_prof_cnt)
     max_prev_prof_cnt = prev_cnt
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE cpm_create_file_name_logical "aps_prof_review", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  d1_seq = d1.seq, d2_seq = d2.seq
  FROM (dummyt d1  WITH seq = value(size(temp->group_qual,5))),
   (dummyt d2  WITH seq = value(max_scrnr_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->group_qual[d1.seq].cur_qual,5))
  HEAD REPORT
   line1 = fillstring(125,"-"), first_time = 0, exceeded_max_rows = "F"
  HEAD PAGE
   col 0, captions->rpt, col 56,
   CALL center(captions->ana,row,132), col 110, captions->dt,
   col 117, curdate"@SHORTDATE;;D", row + 1,
   col 0, captions->dir, col 110,
   captions->tm, col 117, curtime"@TIMENOSECONDS;;M",
   row + 1, col 52,
   CALL center(captions->cyt,row,132),
   col 112, captions->bye, col 117,
   request->curuser, row + 1, col 110,
   captions->pg, col 117, curpage"###",
   row + 1, col 0, captions->grp,
   col 15, temp->run_group, row + 1,
   col 0, captions->use, col 15,
   temp->run_user, row + 1, col 0,
   captions->dt_rg, col 15, request->start_dt"@SHORTDATE;;D",
   col 24, "-", col 26,
   request->end_dt"@SHORTDATE;;D", row + 1, line1,
   row + 1
   IF ((request->mode=0)
    AND (((request->page_break=1)) OR (exceeded_max_rows="T")) )
    row + 1, col 0, captions->grp,
    col 7, temp->group_qual[d1.seq].prsnl_group_name, exceeded_max_rows = "F"
   ENDIF
  HEAD d1_seq
   IF ((request->mode=0)
    AND (request->page_break=0))
    row + 1, col 0, captions->grp,
    col 7, temp->group_qual[d1.seq].prsnl_group_name
   ENDIF
  HEAD d2_seq
   printed_limits_hdr = "n", printed_qa_hdr = "n", printed_prof_hdr = "n"
   IF (first_time=0)
    first_time = 1
   ELSE
    IF ((request->page_break=1))
     BREAK
    ENDIF
   ENDIF
   IF (((row+ 16) > (maxrow - 3)))
    exceeded_max_rows = "T", BREAK
   ENDIF
   row + 1, col 2, captions->use,
   col 8, temp->group_qual[d1.seq].cur_qual[d2.seq].name_full_formatted, row + 2,
   col 8, captions->lg, row + 1,
   col 9, captions->tot_sl, col 25,
   temp->group_qual[d1.seq].cur_qual[d2.seq].slide_limit"###", col 67, captions->sec,
   col 99, temp->group_qual[d1.seq].cur_qual[d2.seq].verify_sec_level"###", row + 1,
   col 9, captions->tot_hr, col 24,
   temp->group_qual[d1.seq].cur_qual[d2.seq].screening_hrs"###", col 67, captions->his,
   col 99, temp->group_qual[d1.seq].cur_qual[d2.seq].pct_no_norm_hist"###", col 103,
   "%", row + 1, col 9,
   captions->calc, col 47, temp->group_qual[d1.seq].cur_qual[d2.seq].max_per_hr"###.##;i;f",
   col 67, captions->atyp, col 99,
   temp->group_qual[d1.seq].cur_qual[d2.seq].pct_atyp_hist"###", col 103, "%",
   row + 1, col 9, captions->dt,
   col 18, temp->group_qual[d1.seq].cur_qual[d2.seq].cur_limit_date"@SHORTDATE;;D", col 67,
   captions->abn, col 99, temp->group_qual[d1.seq].cur_qual[d2.seq].pct_abn_hist"###",
   col 103, "%", row + 1,
   col 9, captions->bye, col 18,
   temp->group_qual[d1.seq].cur_qual[d2.seq].cur_limit_reviewer_name, col 67, captions->risk,
   col 99, temp->group_qual[d1.seq].cur_qual[d2.seq].pct_chr"###", col 103,
   "%", row + 1, row_val_for_unsat_field = row,
   col 9, captions->comm
   FOR (text_cnt = 1 TO temp->group_qual[d1.seq].cur_qual[d2.seq].cur_limit_comment_text_cnt)
     IF (text_cnt > 1)
      row + 1
     ENDIF
     col 18, temp->group_qual[d1.seq].cur_qual[d2.seq].cur_limit_comment_qual[text_cnt].comment
   ENDFOR
   cur_limit_max_row_val = row, row row_val_for_unsat_field, col 67,
   captions->unsat, col 99, temp->group_qual[d1.seq].cur_qual[d2.seq].pct_unsat"###",
   col 103, "%", row + 1,
   col 67, captions->dt, col 76,
   temp->group_qual[d1.seq].cur_qual[d2.seq].cur_qa_date"@SHORTDATE;;D", row + 1, col 67,
   captions->bye, col 76, temp->group_qual[d1.seq].cur_qual[d2.seq].cur_qa_reviewer_name,
   row + 1, col 67, captions->comm
   FOR (text_cnt = 1 TO temp->group_qual[d1.seq].cur_qual[d2.seq].cur_qa_comment_text_cnt)
     IF (text_cnt > 1)
      row + 1
     ENDIF
     col 76, temp->group_qual[d1.seq].cur_qual[d2.seq].cur_qa_comment_qual[text_cnt].comment
   ENDFOR
   IF (cur_limit_max_row_val > row)
    row cur_limit_max_row_val
   ENDIF
  DETAIL
   IF (((row+ 6) > maxrow))
    exceeded_max_rows = "T", BREAK
   ENDIF
   row + 2, col 8, captions->curr
   IF (size(temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual,5) > 0)
    FOR (x = 1 TO size(temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual,5))
      IF (((row+ 5) > maxrow))
       exceeded_max_rows = "T", BREAK
      ENDIF
      row + 1, col 9, captions->event,
      col 18, temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual[x].proficiency_type_disp, row + 1,
      col 9, captions->dt, col 18,
      temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual[x].reviewed_dttm"@SHORTDATE;;D", row + 1,
      col 9,
      captions->bye, col 18, temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual[x].reviewer_name,
      row + 1, col 9, captions->comm
      FOR (text_cnt = 1 TO temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual[x].comment_text_cnt)
        IF (text_cnt > 1)
         row + 1
        ENDIF
        col 18, temp->group_qual[d1.seq].cur_qual[d2.seq].prof_qual[x].comment_qual[text_cnt].comment
      ENDFOR
      row + 1
    ENDFOR
   ELSE
    row + 1, col 8, captions->none,
    row + 1
   ENDIF
   row + 1
   IF (((row+ 8) > maxrow))
    exceeded_max_rows = "T", BREAK
   ENDIF
   row + 1, col 8, captions->prev
   IF (size(temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual,5) > 0)
    FOR (x = 1 TO size(temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual,5))
      IF (((row+ 7) > maxrow))
       exceeded_max_rows = "T", BREAK
      ENDIF
      row + 1, col 9, captions->tot_sl,
      col 25, temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[x].slide_limit"###", col 60,
      captions->dt, col 69, temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[x].date
      "@SHORTDATE;;D",
      row + 1, col 9, captions->tot_hr,
      col 24, temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[x].screening_hrs"###", col 60,
      captions->bye, col 69, temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[x].reviewer_name,
      row + 1, col 9, captions->calc,
      col 47, temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[x].max_per_hr"###.##;i;f", col
      60,
      captions->comm
      FOR (text_cnt = 1 TO temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[x].comment_text_cnt
       )
        IF (text_cnt > 1)
         row + 1
        ENDIF
        col 69, temp->group_qual[d1.seq].prev_qual[d2.seq].limits_qual[x].comment_qual[text_cnt].
        comment
      ENDFOR
      row + 1
    ENDFOR
   ELSE
    row + 1, col 8, captions->no_prev,
    row + 1
   ENDIF
   row + 1
   IF (((row+ 9) > maxrow))
    exceeded_max_rows = "T", BREAK
   ENDIF
   row + 1, col 8, captions->req
   IF (size(temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual,5) > 0)
    FOR (x = 1 TO size(temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual,5))
      IF (((row+ 9) > maxrow))
       exceeded_max_rows = "T", BREAK
      ENDIF
      row + 1, col 9, captions->sec,
      col 41, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].verify_sec_level"###", col 60,
      captions->dt, col 69, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].date"@SHORTDATE;;D",
      row + 1, col 9, captions->his,
      col 41, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].pct_no_norm_hist"###", col 45,
      "%", col 60, captions->bye,
      col 69, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].reviewer_name, row + 1,
      col 9, captions->atyp, col 41,
      temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].pct_atyp_hist"###", col 45, "%",
      col 60, captions->comm
      IF ((temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].comment_text_cnt >= 1))
       col 69, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].comment_qual[1].comment
      ENDIF
      row + 1, col 9, captions->abn,
      col 41, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].pct_abn_hist"###", col 45,
      "%"
      IF ((temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].comment_text_cnt >= 2))
       col 69, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].comment_qual[2].comment
      ENDIF
      row + 1, col 9, captions->risk,
      col 41, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].pct_chr"###", col 45,
      "%"
      IF ((temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].comment_text_cnt >= 3))
       col 69, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].comment_qual[3].comment
      ENDIF
      row + 1, col 9, captions->unsat,
      col 41, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].pct_unsat"###", col 45,
      "%"
      IF ((temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].comment_text_cnt=4))
       col 69, temp->group_qual[d1.seq].prev_qual[d2.seq].qa_qual[x].comment_qual[4].comment
      ENDIF
      row + 1
    ENDFOR
   ELSE
    row + 1, col 8, captions->no_req,
    row + 1
   ENDIF
   row + 1
   IF (((row+ 6) > maxrow))
    exceeded_max_rows = "T", BREAK
   ENDIF
   row + 1, col 8, captions->prof
   IF (size(temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual,5) > 0)
    FOR (x = 1 TO size(temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual,5))
      IF (((row+ 10) > maxrow))
       exceeded_max_rows = "T", BREAK
      ENDIF
      row + 1, col 9, captions->event,
      col 18, temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual[x].proficiency_type_disp, row + 1,
      col 9, captions->dt, col 18,
      temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual[x].date"@SHORTDATE;;D", row + 1, col 9,
      captions->bye, col 18, temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual[x].reviewer_name,
      row + 1, col 9, captions->comm
      FOR (text_cnt = 1 TO temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual[x].comment_text_cnt)
        IF (text_cnt > 1)
         row + 1
        ENDIF
        col 18, temp->group_qual[d1.seq].prev_qual[d2.seq].prof_qual[x].comment_qual[text_cnt].
        comment
      ENDFOR
      row + 1
    ENDFOR
   ELSE
    row + 1, col 8, captions->no_prof,
    row + 1
   ENDIF
   IF (((row+ 6) > maxrow))
    exceeded_max_rows = "T", BREAK
   ENDIF
   row + 1, row + 1,
   CALL center(captions->end_prof,0,132),
   row + 2
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->title,
   wk = format(curdate,"@WEEKDAYABBREV;;D"), dy = format(curdate,"@MEDIUMDATE4YR;;D"), today = concat
   (wk," ",dy),
   col 53, today, col 110,
   captions->pg, col 117, curpage"###",
   row + 1, col 55, captions->cont
  FOOT REPORT
   col 55, "##########  "
  WITH nocounter, outerjoin = d3, dontcare = d4,
   maxrow = 63, compress
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","ARRAY","REPORT MAKER")
  GO TO exit_script
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
END GO
