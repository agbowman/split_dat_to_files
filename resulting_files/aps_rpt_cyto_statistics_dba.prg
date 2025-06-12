CREATE PROGRAM aps_rpt_cyto_statistics:dba
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
 RECORD scrn_dt_tm(
   1 screener_qual[*]
     2 initial_dt_tm = dq8
     2 initial_slide_limit = i4
     2 qual[*]
       3 reviewed_dt_tm = dq8
       3 slide_limit = i4
 )
 RECORD temp(
   1 run_group = c40
   1 run_user = c40
   1 run_date = c40
   1 d_start_dt = dq8
   1 d_end_dt = dq8
   1 d2_start_dt = dq8
   1 d2_end_dt = dq8
   1 m_start_dt = dq8
   1 m_end_dt = dq8
   1 process_monthly_flag = c1
   1 group_qual[*]
     2 prsnl_group_id = f8
   1 max_cases = i4
   1 ind_screener_qual[*]
     2 cnt = i4
     2 prsnl_id = f8
     2 individ_qual[*]
       3 case_id = f8
       3 diagnostic_category_cd = f8
       3 specimen_cd = f8
     2 sorted_individ_qual[*]
       3 case_id = f8
       3 diagnostic_category_cd = f8
       3 specimen_cd = f8
     2 specimen_qual[*]
       3 specimen_cd = f8
       3 specimen_disp = vc
       3 tot_diag_cnt = i4
       3 diagnosis[*]
         4 diagnostic_category_cd = f8
         4 diagnostic_category_disp = vc
         4 diagnostic_cnt = i4
         4 case_qual[*]
           5 case_id = f8
   1 all_qual[*]
     2 case_id = f8
     2 diagnostic_category_cd = f8
     2 specimen_cd = f8
   1 sorted_all_qual[*]
     2 case_id = f8
     2 diagnostic_category_cd = f8
     2 specimen_cd = f8
   1 all_specimen_qual[*]
     2 specimen_cd = f8
     2 specimen_disp = vc
     2 tot_diag_cnt = i4
     2 diagnosis[*]
       3 diagnostic_category_cd = f8
       3 diagnostic_category_disp = vc
       3 diagnostic_cnt = i4
       3 case_qual[*]
         4 case_id = f8
   1 rpt_qual[*]
     2 case_id = f8
     2 diagnostic_category_cd = f8
     2 specimen_cd = f8
   1 sorted_rpt_qual[*]
     2 case_id = f8
     2 diagnostic_category_cd = f8
     2 specimen_cd = f8
   1 rpt_specimen_qual[*]
     2 specimen_cd = f8
     2 specimen_disp = vc
     2 tot_diag_cnt = i4
     2 diagnosis[*]
       3 diagnostic_category_cd = f8
       3 diagnostic_category_disp = vc
       3 diagnostic_cnt = i4
       3 case_qual[*]
         4 case_id = f8
   1 screener_qual[*]
     2 prsnl_id = f8
     2 name_full_formatted = c40
     2 slide_limit = i4
     2 security = i4
     2 section_qual[*]
       3 section = i4
       3 available = c1
       3 row_qual[*]
         4 row_text = c150
       3 date_qual[*]
         4 drow_qual[*]
           5 drow_text = c150
   1 diag_cat_qual[*]
     2 category_cd = f8
     2 category_disp = c40
     2 cdf_meaning = c12
     2 all_cnt = i4
     2 rpt_cnt = i4
     2 screener_cnt = i4
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
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 RECORD captions(
   1 rpt = vc
   1 nm = vc
   1 ana = vc
   1 st = vc
   1 dt = vc
   1 dir = vc
   1 tm = vc
   1 title = vc
   1 bye = vc
   1 grp = vc
   1 use = vc
   1 inac = vc
   1 dt_rg = vc
   1 cur_lim = vc
   1 cur_qa = vc
   1 tot_sl = vc
   1 n_his = vc
   1 tot_hr = vc
   1 a_his = vc
   1 calc_max = vc
   1 ab_his = vc
   1 ver_sec = vc
   1 h_risk = vc
   1 unsat = vc
   1 sum_stat = vc
   1 i_slide = vc
   1 o_slide = vc
   1 cse_no = vc
   1 slide_no = vc
   1 sc_resc = vc
   1 tot = vc
   1 gyn = vc
   1 non_gyn = vc
   1 all_cse = vc
   1 qual_stat = vc
   1 pat_cse = vc
   1 per = vc
   1 avail = vc
   1 sel = vc
   1 nor_h = vc
   1 aty_h = vc
   1 ab_h = vc
   1 clin_high = vc
   1 not_sat = vc
   1 exceed = vc
   1 user_sel = vc
   1 var_dis = vc
   1 cat = vc
   1 cse_per = vc
   1 dis = vc
   1 var = vc
   1 cse = vc
   1 scr = vc
   1 init_scr = vc
   1 rescr = vc
   1 typ = vc
   1 ver_by = vc
   1 diag_sum = vc
   1 us_scr = vc
   1 all_scr = vc
   1 rpt_ver = vc
   1 diag_cat = vc
   1 an = vc
   1 non_diag = vc
   1 spe = vc
   1 all_spe = vc
   1 tot_lim = vc
   1 per_lim = vc
   1 no_hrs = vc
   1 calc_hr = vc
   1 end_stat = vc
   1 cont = vc
   1 pag = vc
   1 noted = vc
   1 total = vc
   1 day_cnt = vc
   1 tot_scr = vc
 )
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"t1","REPORT:")
 SET captions->nm = uar_i18ngetmessage(i18nhandle,"t2","APS_RPT_CYTO_STATISTICS.PRG")
 SET captions->ana = uar_i18ngetmessage(i18nhandle,"t3","Anatomic Pathology")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t4","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t5","DIRECTORY:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t6","TIME:")
 SET captions->title = uar_i18ngetmessage(i18nhandle,"t7","CYTOLOGY STATISTICS BY USER")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t8","BY:")
 SET captions->grp = uar_i18ngetmessage(i18nhandle,"t9","GROUP:")
 SET captions->use = uar_i18ngetmessage(i18nhandle,"t10","USER:")
 SET captions->inac = uar_i18ngetmessage(i18nhandle,"t11","(Inactives included)")
 SET captions->dt_rg = uar_i18ngetmessage(i18nhandle,"t12","DATE RANGE:")
 SET captions->cur_lim = uar_i18ngetmessage(i18nhandle,"t13",
  "--- CURRENT LIMITS ------------------------")
 SET captions->cur_qa = uar_i18ngetmessage(i18nhandle,"t14",
  "--- CURRENT QA RESCREENING REQUIREMENTS ---")
 SET captions->tot_sl = uar_i18ngetmessage(i18nhandle,"t15","TOTAL # SLIDES:")
 SET captions->n_his = uar_i18ngetmessage(i18nhandle,"t16","% WITH NO, OR NORMAL HISTORY:")
 SET captions->tot_hr = uar_i18ngetmessage(i18nhandle,"t17","TOTAL # HOURS:")
 SET captions->a_his = uar_i18ngetmessage(i18nhandle,"t18","% WITH ATYPICAL HISTORY:")
 SET captions->calc_max = uar_i18ngetmessage(i18nhandle,"t19","CALCULATED MAXIMUM # SLIDES PER HOUR:"
  )
 SET captions->ab_his = uar_i18ngetmessage(i18nhandle,"t20","% WITH ABNORMAL HISTORY:")
 SET captions->ver_sec = uar_i18ngetmessage(i18nhandle,"t21","VERIFICATION SECURITY LEVEL:")
 SET captions->h_risk = uar_i18ngetmessage(i18nhandle,"t22","% WITH CLINICAL HIGH RISK:")
 SET captions->unsat = uar_i18ngetmessage(i18nhandle,"t23","% UNSATISFACTORY:")
 SET captions->sum_stat = uar_i18ngetmessage(i18nhandle,"t24",
  "SUMMARY CASE AND SLIDE COUNTS STATISTICS")
 SET captions->i_slide = uar_i18ngetmessage(i18nhandle,"t25","# INSIDE SLIDES")
 SET captions->o_slide = uar_i18ngetmessage(i18nhandle,"t26","# OUTSIDE SLIDES")
 SET captions->cse_no = uar_i18ngetmessage(i18nhandle,"t27","# CASES")
 SET captions->slide_no = uar_i18ngetmessage(i18nhandle,"t28","# SLIDES")
 SET captions->sc_resc = uar_i18ngetmessage(i18nhandle,"t29","SCREENED/RESCREENED")
 SET captions->tot = uar_i18ngetmessage(i18nhandle,"t30","TOTAL")
 SET captions->gyn = uar_i18ngetmessage(i18nhandle,"t31","GYNECOLOGIC CYTOLOGY")
 SET captions->non_gyn = uar_i18ngetmessage(i18nhandle,"t32","NON-GYNECOLOGIC CYTOLOGY")
 SET captions->all_cse = uar_i18ngetmessage(i18nhandle,"t33","ALL CASES")
 SET captions->qual_stat = uar_i18ngetmessage(i18nhandle,"t34",
  "QUALITY ASSURANCE RESCREENING STATISTICS")
 SET captions->pat_cse = uar_i18ngetmessage(i18nhandle,"t35","PATIENT/CASE")
 SET captions->per = uar_i18ngetmessage(i18nhandle,"t36","PERCENT")
 SET captions->avail = uar_i18ngetmessage(i18nhandle,"t37","AVAILABLE")
 SET captions->sel = uar_i18ngetmessage(i18nhandle,"t38","SELECTED")
 SET captions->nor_h = uar_i18ngetmessage(i18nhandle,"t39","NORMAL, OR NO HISTORY")
 SET captions->aty_h = uar_i18ngetmessage(i18nhandle,"t40","ATYPICAL HISTORY")
 SET captions->ab_h = uar_i18ngetmessage(i18nhandle,"t41","ABNORMAL HISTORY")
 SET captions->clin_high = uar_i18ngetmessage(i18nhandle,"t42","CLINICAL HIGH RISK")
 SET captions->not_sat = uar_i18ngetmessage(i18nhandle,"t43","UNSATISFACTORY")
 SET captions->exceed = uar_i18ngetmessage(i18nhandle,"t44","EXCEEDED SCREENING LIMITS")
 SET captions->user_sel = uar_i18ngetmessage(i18nhandle,"t45","USER-SELECTED")
 SET captions->var_dis = uar_i18ngetmessage(i18nhandle,"t46","VARIANCE AND DISCREPANCY STATISTICS")
 SET captions->cat = uar_i18ngetmessage(i18nhandle,"t47","CATEGORY")
 SET captions->cse_per = uar_i18ngetmessage(i18nhandle,"t48","% CASES")
 SET captions->dis = uar_i18ngetmessage(i18nhandle,"t49","DISCREPANCY")
 SET captions->var = uar_i18ngetmessage(i18nhandle,"t50","VARIANCE")
 SET captions->cse = uar_i18ngetmessage(i18nhandle,"t51","CASE")
 SET captions->scr = uar_i18ngetmessage(i18nhandle,"t52","SCREENED")
 SET captions->init_scr = uar_i18ngetmessage(i18nhandle,"t53","INITIAL SCREEN")
 SET captions->rescr = uar_i18ngetmessage(i18nhandle,"t54","RESCREEN")
 SET captions->typ = uar_i18ngetmessage(i18nhandle,"t55","TYPE")
 SET captions->ver_by = uar_i18ngetmessage(i18nhandle,"t56","VERIFIED BY")
 SET captions->diag_sum = uar_i18ngetmessage(i18nhandle,"t57","DIAGNOSTIC SUMMARY")
 SET captions->us_scr = uar_i18ngetmessage(i18nhandle,"t58","USER INITIAL SCREEN")
 SET captions->all_scr = uar_i18ngetmessage(i18nhandle,"t59","ALL INITIAL SCREEN")
 SET captions->rpt_ver = uar_i18ngetmessage(i18nhandle,"t60","REPORT VERIFIED AS")
 SET captions->diag_cat = uar_i18ngetmessage(i18nhandle,"t61","GYN CYTOLOGY DIAGNOSTIC CATEGORY")
 SET captions->an = uar_i18ngetmessage(i18nhandle,"t62","#   AND   %")
 SET captions->non_diag = uar_i18ngetmessage(i18nhandle,"t63","NON-GYN CYTOLOGY DIAGNOSTIC CATEGORY")
 SET captions->spe = uar_i18ngetmessage(i18nhandle,"t64","SPECIMEN:")
 SET captions->all_spe = uar_i18ngetmessage(i18nhandle,"t65","ALL SPECIMENS")
 SET captions->tot_lim = uar_i18ngetmessage(i18nhandle,"t66",
  "TOTAL # OF SLIDES DAILY SCREENING LIMIT:")
 SET captions->per_lim = uar_i18ngetmessage(i18nhandle,"t67",
  "% OF SLIDES DAILY SLIDE LIMIT ACHIEVED:")
 SET captions->no_hrs = uar_i18ngetmessage(i18nhandle,"t68","NUMBER OF SCREENING HOURS:")
 SET captions->calc_hr = uar_i18ngetmessage(i18nhandle,"t69","CALCULATED NUMBER OF SLIDES PER HOUR:")
 SET captions->end_stat = uar_i18ngetmessage(i18nhandle,"t70",
  "******************** END OF USER'S STATISTICS ********************")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"t71","CONTINUED...")
 SET captions->pag = uar_i18ngetmessage(i18nhandle,"t72","PAGE:")
 SET captions->noted = uar_i18ngetmessage(i18nhandle,"t73","*** NO DISCREPANCY OR VARIANCE NOTED ***"
  )
 SET captions->total = uar_i18ngetmessage(i18nhandle,"t74","-- TOTAL --")
 SET captions->day_cnt = uar_i18ngetmessage(i18nhandle,"t75","DAILY CASE AND SLIDE COUNTS STATISTICS"
  )
 SET captions->tot_scr = uar_i18ngetmessage(i18nhandle,"t76",
  "TOTAL # OF SLIDES SCREENED AND RESCREENED:")
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
#script
 SET no_ngyn_all_cnts = "F"
 SET no_ngyn_rpt_cnts = "F"
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET check_pg_active = fillstring(30," ")
 SET check_pgr_active = fillstring(30," ")
 SET check_pgr2_active = fillstring(30," ")
 SET check_csl_active = fillstring(30," ")
 SET check_css_active = fillstring(30," ")
 SET check_p_active = fillstring(30," ")
 DECLARE prsnl_group_type_code_set = i4 WITH protect, constant(357)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE pathologist_cd = f8 WITH protect, noconstant(0.0)
 DECLARE resident_cd = f8 WITH protect, noconstant(0.0)
 CALL initresourcesecurity(1)
 CALL populatesrtypesforsecurity(1)
 SET stat = uar_get_meaning_by_codeset(prsnl_group_type_code_set,"PATHOLOGIST",1,pathologist_cd)
 IF (pathologist_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F","357","CANNOT GET PATHOLOGIST CODE VALUE")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(prsnl_group_type_code_set,"PATHRESIDENT",1,resident_cd)
 IF (resident_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F","357","CANNOT GET RESIDENT CODE VALUE")
 ENDIF
 IF (textlen(trim(request->batch_selection)) > 0)
  SET raw_prsnl_group = fillstring(100," ")
  SET raw_prsnl = fillstring(100," ")
  SET raw_date_str = fillstring(4," ")
  SET raw_date_num_str = 0
  SET printer = fillstring(100," ")
  SET copies = 0
  IF (textlen(trim(request->output_dist))=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with output_dist!"
   GO TO exit_script
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
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->print_daily_ind = cnvtint(
     trim(text)),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    request->page_break = cnvtint(trim(text)),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->separate_diagnosis = trim(
     text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->bshowinactives = cnvtint(
     trim(text)),
    CALL get_text(1,trim(request->output_dist),"|"),
    printer = trim(text),
    CALL get_text(startpos2,trim(request->output_dist),"|"), copies = cnvtint(trim(text))
   WITH nocounter
  ;end select
  IF ((request->bshowinactives=0))
   SET check_pg_active = "pg.active_ind = 1"
   SET check_pgr_active = "pgr.active_ind = 1"
   SET check_pgr2_active = "pgr2.active_ind = 1"
   SET check_csl_active = "csl.active_ind = 1"
   SET check_css_active = "css.active_ind = 1"
   SET check_p_active = "p.active_ind =1 "
  ELSE
   SET check_pg_active = "pg.active_ind in (0,1)"
   SET check_pgr_active = "pgr.active_ind in (0,1)"
   SET check_pgr2_active = "pgr2.active_ind in (0,1)"
   SET check_csl_active = "csl.active_ind in (0,1)"
   SET check_css_active = "css.active_ind in (0,1)"
   SET check_p_active = "p.active_ind in (0,1) "
  ENDIF
  IF (textlen(trim(raw_prsnl_group)) > 0)
   SELECT INTO "nl:"
    pg.prsnl_group_id
    FROM prsnl_group pg,
     code_value cv
    PLAN (pg
     WHERE raw_prsnl_group=pg.prsnl_group_name
      AND parser(check_pg_active)
      AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (cv
     WHERE pg.prsnl_group_type_cd=cv.code_value
      AND cv.cdf_meaning="CYTORPTGRP")
    DETAIL
     service_resource_cd = pg.service_resource_cd
     IF (isresourceviewable(service_resource_cd)=true)
      request->prsnl_group_id = pg.prsnl_group_id
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with prsnl_group id!"
    GO TO exit_script
   ELSEIF (getresourcesecuritystatus(0) != "S")
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
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with prsnl_group id!"
    GO TO exit_script
   ELSEIF (getresourcesecuritystatus(0) != "S")
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with prsnl_group id!"
    GO TO end_script
   ENDIF
   SET request->prsnl_group_id = 0
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
    GO TO exit_script
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
    GO TO exit_script
  ENDCASE
 ENDIF
 CALL getstartofday(request->start_dt,0)
 SET request->start_dt = dtemp->beg_of_day
 CALL getendofday(request->end_dt,0)
 SET request->end_dt = dtemp->end_of_day
 IF ((request->bshowinactives=0))
  SET check_pg_active = "pg.active_ind = 1"
  SET check_pgr_active = "pgr.active_ind = 1"
  SET check_pgr2_active = "pgr2.active_ind = 1"
  SET check_csl_active = "csl.active_ind = 1"
  SET check_css_active = "css.active_ind = 1"
  SET check_p_active = "p.active_ind = 1"
 ELSE
  SET check_pg_active = "pg.active_ind in (0,1)"
  SET check_pgr_active = "pgr.active_ind in (0,1)"
  SET check_pgr2_active = "pgr2.active_ind in (0,1)"
  SET check_csl_active = "csl.active_ind in (0,1)"
  SET check_css_active = "css.active_ind in (0,1)"
  SET check_p_active = "p.active_ind in (0,1)"
 ENDIF
 SET end_month = cnvtint(format(cnvtdatetime(request->end_dt),"mm;;d"))
 SET start_month = cnvtint(format(cnvtdatetime(request->start_dt),"mm;;d"))
 SET end_year = cnvtint(format(cnvtdatetime(request->end_dt),"yy;;d"))
 SET start_year = cnvtint(format(cnvtdatetime(request->start_dt),"yy;;d"))
 SET strdate = cnvtdate2(format(cnvtdatetime(request->start_dt),"yy/mm/dd;;d"),"yy/mm/dd")
 SET enddate = cnvtdate2(format(cnvtdatetime(request->end_dt),"yy/mm/dd;;d"),"yy/mm/dd")
 SET month_diff = cnvtint(format(cnvtdatetime(datetimediff(request->end_dt,request->start_dt,1)),
   "mm;;d"))
 IF (month_diff > 2
  AND (request->print_daily_ind=0))
  CALL getstartofdayabs(request->start_dt,0)
  SET temp->d_start_dt = dtemp->beg_of_day_abs
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
 SET temp->run_date = concat(format(cnvtdatetime(request->start_dt),"@SHORTDATE;;D")," - ",format(
   cnvtdatetime(request->end_dt),"@SHORTDATE;;D"))
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
     .prsnl_group_id
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
    temp->run_group = trim(pg.prsnl_group_name)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","PRSNL_GROUP")
   GO TO exit_script
  ENDIF
  SET stat = alterlist(temp->group_qual,1)
  SET temp->group_qual[1].prsnl_group_id = request->prsnl_group_id
 ENDIF
 SELECT INTO "nl:"
  d.seq, pgr.prsnl_group_reltn_id, pgr2.prsnl_group_reltn_id,
  p.name_full_formatted, role = uar_get_code_meaning(pg.prsnl_group_type_cd)
  FROM (dummyt d  WITH seq = value(size(temp->group_qual,5))),
   prsnl_group_reltn pgr,
   prsnl p,
   prsnl_group pg,
   prsnl_group_reltn pgr2,
   dummyt d2,
   cyto_screening_limits csl,
   cyto_screening_security css
  PLAN (d)
   JOIN (pgr
   WHERE (temp->group_qual[d.seq].prsnl_group_id=pgr.prsnl_group_id)
    AND parser(check_pgr_active))
   JOIN (p
   WHERE pgr.person_id=p.person_id
    AND parser(check_p_active))
   JOIN (d2)
   JOIN (((csl
   WHERE pgr.person_id=csl.prsnl_id
    AND parser(check_csl_active))
   JOIN (css
   WHERE csl.prsnl_id=css.prsnl_id
    AND parser(check_css_active))
   ) ORJOIN ((pg
   WHERE pg.prsnl_group_type_cd IN (pathologist_cd, resident_cd)
    AND parser(check_pg_active)
    AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pgr2
   WHERE pg.prsnl_group_id=pgr2.prsnl_group_id
    AND pgr.person_id=pgr2.person_id
    AND parser(check_pgr2_active))
   ))
  ORDER BY pgr.person_id
  HEAD REPORT
   cnt = 0
  HEAD pgr.person_id
   cnt += 1, stat = alterlist(temp->screener_qual,cnt), stat = alterlist(temp->ind_screener_qual,cnt),
   temp->screener_qual[cnt].prsnl_id = pgr.person_id, temp->ind_screener_qual[cnt].prsnl_id = pgr
   .person_id, temp->screener_qual[cnt].name_full_formatted = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","PRSNL_GROUP_RELTN")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp->diag_cat_qual,1)
 SELECT INTO "nl:"
  cv.code_set
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
   .cdf_meaning, temp->diag_cat_qual[dcnt].all_cnt = 0,
   temp->diag_cat_qual[dcnt].rpt_cnt = 0, temp->diag_cat_qual[dcnt].screener_cnt = 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE 2")
  GO TO exit_script
 ENDIF
 SET gyn_all_cnt = 0
 SET ngyn_all_cnt = 0
 SET gyn_rpt_cnt = 0
 SET ngyn_rpt_cnt = 0
 SET all_case_cnt = 0
 SET rpt_case_cnt = 0
 SELECT INTO "nl:"
  cse.diagnostic_category_cd
  FROM (dummyt d  WITH seq = value(size(temp->screener_qual,5))),
   cyto_screening_event cse,
   cyto_screening_event cse2,
   (dummyt d2  WITH seq = value(size(temp->diag_cat_qual,5))),
   (dummyt d3  WITH seq = value(size(temp->diag_cat_qual,5)))
  PLAN (d)
   JOIN (cse
   WHERE (cse.screener_id=temp->screener_qual[d.seq].prsnl_id)
    AND cse.screen_dt_tm >= cnvtdatetime(request->start_dt)
    AND cse.screen_dt_tm <= cnvtdatetime(request->end_dt)
    AND cse.initial_screener_ind=1
    AND cse.active_ind=1)
   JOIN (d2
   WHERE (temp->diag_cat_qual[d2.seq].category_cd=cse.diagnostic_category_cd))
   JOIN (cse2
   WHERE cse.case_id=cse2.case_id
    AND cse2.verify_ind=1)
   JOIN (d3
   WHERE (temp->diag_cat_qual[d3.seq].category_cd=cse2.diagnostic_category_cd))
  DETAIL
   temp->diag_cat_qual[d2.seq].all_cnt += 1, temp->diag_cat_qual[d3.seq].rpt_cnt += 1
   IF ((temp->diag_cat_qual[d2.seq].cdf_meaning="GYN"))
    gyn_all_cnt += 1, gyn_rpt_cnt += 1
   ENDIF
   IF ((temp->diag_cat_qual[d2.seq].cdf_meaning="NGYN"))
    ngyn_all_cnt += 1, stat = alterlist(temp->all_qual,ngyn_all_cnt), temp->all_qual[ngyn_all_cnt].
    case_id = cse.case_id,
    temp->all_qual[ngyn_all_cnt].diagnostic_category_cd = cse.diagnostic_category_cd, ngyn_rpt_cnt
     += 1, stat = alterlist(temp->rpt_qual,ngyn_rpt_cnt),
    temp->rpt_qual[ngyn_rpt_cnt].case_id = cse.case_id, temp->rpt_qual[ngyn_rpt_cnt].
    diagnostic_category_cd = cse2.diagnostic_category_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (ngyn_rpt_cnt=0)
  SET no_ngyn_rpt_cnts = "T"
 ENDIF
 IF (ngyn_all_cnt=0)
  SET no_ngyn_all_cnts = "T"
 ENDIF
 SET section = 0
 SET ncnt = 0
 IF ((((request->mode=2)) OR ((request->mode=1)
  AND (request->prsnl_id > 0))) )
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(size(temp->screener_qual,5)))
   HEAD REPORT
    name_full_formatted = fillstring(40," ")
   DETAIL
    IF ((temp->screener_qual[d.seq].prsnl_id=request->prsnl_id))
     name_full_formatted = temp->screener_qual[d.seq].name_full_formatted
    ENDIF
   FOOT REPORT
    stat = alterlist(temp->screener_qual,0), stat = alterlist(temp->screener_qual,1), temp->
    screener_qual[1].prsnl_id = request->prsnl_id,
    temp->screener_qual[1].name_full_formatted = name_full_formatted, temp->run_user = trim(
     name_full_formatted)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","DUMMY")
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   csl.sequence, csl.prsnl_id, csl.reviewed_dt_tm
   FROM cyto_screening_limits csl
   PLAN (csl
    WHERE (csl.prsnl_id=temp->screener_qual[1].prsnl_id))
   ORDER BY csl.prsnl_id, csl.reviewed_dt_tm DESC
   HEAD csl.prsnl_id
    stat = alterlist(scrn_dt_tm->screener_qual,1), num_of_rev_dates = 0
   HEAD csl.reviewed_dt_tm
    num_of_rev_dates += 1, stat = alterlist(scrn_dt_tm->screener_qual[1].qual,num_of_rev_dates)
    IF (csl.sequence=0)
     scrn_dt_tm->screener_qual[1].qual[num_of_rev_dates].reviewed_dt_tm = cnvtdatetime(
      "31-DEC-9999 00:00"), scrn_dt_tm->screener_qual[1].qual[num_of_rev_dates].slide_limit = csl
     .slide_limit, scrn_dt_tm->screener_qual[1].initial_dt_tm = cnvtdatetime("31-DEC-9999 00:00"),
     scrn_dt_tm->screener_qual[1].initial_slide_limit = csl.slide_limit
    ELSE
     scrn_dt_tm->screener_qual[1].qual[num_of_rev_dates].reviewed_dt_tm = csl.reviewed_dt_tm,
     scrn_dt_tm->screener_qual[1].qual[num_of_rev_dates].slide_limit = csl.slide_limit
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET temp->run_user = "ALL"
  SET stat = alterlist(scrn_dt_tm->screener_qual,value(size(temp->screener_qual,5)))
 ENDIF
 FOR (scrnr = 1 TO size(temp->screener_qual,5))
   SET stat = alterlist(temp->screener_qual[scrnr].section_qual,8)
   FOR (cnt = 1 TO cnvtint(size(temp->diag_cat_qual,5)))
     SET temp->diag_cat_qual[cnt].screener_cnt = 0
   ENDFOR
   SET section = 1
   SET stat = alterlist(temp->screener_qual[scrnr].section_qual[section].row_qual,1)
   SET temp->screener_qual[scrnr].section_qual[section].section = section
   SELECT INTO "nl:"
    csl.prsnl_id
    FROM cyto_screening_limits csl,
     cyto_screening_security css
    PLAN (csl
     WHERE (temp->screener_qual[scrnr].prsnl_id=csl.prsnl_id)
      AND parser(check_csl_active))
     JOIN (css
     WHERE csl.prsnl_id=css.prsnl_id
      AND parser(check_css_active))
    HEAD REPORT
     ncnt = 0, slide_limit = 0.0, screening_hrs = 0.0,
     maxperhr = 0.0
    DETAIL
     temp->screener_qual[scrnr].slide_limit = csl.slide_limit, temp->screener_qual[scrnr].security =
     css.prsnl_id, ncnt += 1,
     slide_limit = csl.slide_limit, screening_hrs = csl.screening_hours, maxperhr = cnvtreal((
      cnvtreal(slide_limit)/ cnvtreal(screening_hrs)))
     IF ((size(temp->screener_qual[scrnr].section_qual[section].row_qual,5) < (ncnt+ 5)))
      stat = alterlist(temp->screener_qual[scrnr].section_qual[section].row_qual,(ncnt+ 5))
     ENDIF
     temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(csl.slide_limit,
      "|",css.normal_percentage,"|"), ncnt += 1, temp->screener_qual[scrnr].section_qual[section].
     row_qual[ncnt].row_text = build(csl.screening_hours,"|",css.atypical_percentage,"|"),
     ncnt += 1, temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(
      maxperhr,"|",css.abnormal_percentage,"|"), ncnt += 1,
     temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(css
      .verify_level,"|",css.chr_percentage,"|"), ncnt += 1, temp->screener_qual[scrnr].section_qual[
     section].row_qual[ncnt].row_text = build(css.unsat_percentage,"|"),
     stat = alterlist(temp->screener_qual[scrnr].section_qual[section].row_qual,ncnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    screener = scrnr, temp->screener_qual[scrnr].prsnl_id, csl.sequence,
    csl.prsnl_id, csl.reviewed_dt_tm, csl.slide_limit
    FROM cyto_screening_limits csl
    PLAN (csl
     WHERE (csl.prsnl_id=temp->screener_qual[scrnr].prsnl_id))
    ORDER BY csl.prsnl_id, csl.reviewed_dt_tm DESC
    HEAD REPORT
     num_of_rev_dates = 0
    HEAD csl.prsnl_id
     add_row_qual = 0
     IF ((temp->screener_qual[scrnr].security=0)
      AND size(temp->screener_qual[scrnr].section_qual[1].row_qual,5) < 3)
      stat = alterlist(temp->screener_qual[scrnr].section_qual[1].row_qual,3), add_row_qual = 1
     ENDIF
    HEAD csl.reviewed_dt_tm
     num_of_rev_dates += 1, stat = alterlist(scrn_dt_tm->screener_qual[scrnr].qual,num_of_rev_dates)
     IF (csl.sequence=0)
      scrn_dt_tm->screener_qual[scrnr].qual[num_of_rev_dates].reviewed_dt_tm = cnvtdatetime(
       "31-DEC-9999 00:00"), scrn_dt_tm->screener_qual[scrnr].qual[num_of_rev_dates].slide_limit =
      csl.slide_limit, scrn_dt_tm->screener_qual[scrnr].initial_dt_tm = cnvtdatetime(
       "31-DEC-9999 00:00"),
      scrn_dt_tm->screener_qual[scrnr].initial_slide_limit = csl.slide_limit
     ELSE
      scrn_dt_tm->screener_qual[scrnr].qual[num_of_rev_dates].reviewed_dt_tm = csl.reviewed_dt_tm,
      scrn_dt_tm->screener_qual[scrnr].qual[num_of_rev_dates].slide_limit = csl.slide_limit
     ENDIF
     IF (add_row_qual > 0)
      temp->screener_qual[scrnr].slide_limit = csl.slide_limit, temp->screener_qual[scrnr].
      section_qual[1].row_qual[1].row_text = build(csl.slide_limit,"|"), temp->screener_qual[scrnr].
      section_qual[1].row_qual[2].row_text = build(csl.screening_hours,"|"),
      temp->screener_qual[scrnr].section_qual[1].row_qual[3].row_text = build(cnvtreal((cnvtreal(csl
         .slide_limit)/ cnvtreal(csl.screening_hours))),"|")
     ENDIF
    WITH nocounter
   ;end select
   SET gyn_cases_is = 0
   SET gyn_cases_rs = 0
   SET gyn_slides_is = 0.0
   SET gyn_slides_rs = 0.0
   SET ngyn_slides_is = 0.0
   SET ngyn_slides_rs = 0.0
   SET ngyn_cases_is = 0
   SET ngyn_cases_rs = 0
   SET normal_cases = 0
   SET normal_slides = 0.0
   SET normal_slides_requeued = 0.0
   SET chr_cases = 0
   SET chr_slides = 0.0
   SET chr_slides_requeued = 0.0
   SET prev_atypical_cases = 0
   SET prev_atypical_slides = 0.0
   SET prev_atyp_slides_requeued = 0.0
   SET prev_abnormal_cases = 0
   SET prev_abnormal_slides = 0.0
   SET prev_abn_slides_requeued = 0.0
   SET unsat_cases = 0
   SET unsat_slides = 0.0
   SET unsat_slides_requeued = 0.0
   SET exceeded_limit_cases = 0
   SET exceeded_limit_slides = 0.0
   SET user_preference_cases = 0
   SET user_preference_slides = 0.0
   SET outside_gyn_is = 0.0
   SET outside_gyn_rs = 0.0
   SET outside_ngyn_is = 0.0
   SET outside_ngyn_rs = 0.0
   SET outside_all_is = 0.0
   SET outside_all_rs = 0.0
   SELECT INTO "nl:"
    dcc.prsnl_id
    FROM daily_cytology_counts dcc
    PLAN (dcc
     WHERE (temp->screener_qual[scrnr].prsnl_id=dcc.prsnl_id)
      AND ((dcc.record_dt_tm >= cnvtdatetime(temp->d_start_dt)
      AND dcc.record_dt_tm <= cnvtdatetime(temp->d_end_dt)) OR (dcc.record_dt_tm >= cnvtdatetime(temp
      ->d2_start_dt)
      AND dcc.record_dt_tm <= cnvtdatetime(temp->d2_end_dt))) )
    ORDER BY dcc.record_dt_tm
    HEAD REPORT
     dcnt = 0
    DETAIL
     dcnt += 1, gyn_cases_is += dcc.gyn_cases_is, gyn_cases_rs += dcc.gyn_cases_rs,
     gyn_slides_is += dcc.gyn_slides_is, gyn_slides_rs += dcc.gyn_slides_rs, outside_gyn_is += dcc
     .outside_gyn_is,
     outside_gyn_rs += dcc.outside_gyn_rs, ngyn_slides_is += dcc.ngyn_slides_is, ngyn_slides_rs +=
     dcc.ngyn_slides_rs,
     outside_ngyn_is += dcc.outside_ngyn_is, outside_ngyn_rs += dcc.outside_ngyn_rs, ngyn_cases_is
      += dcc.ngyn_cases_is,
     ngyn_cases_rs += dcc.ngyn_cases_rs, normal_cases += dcc.normal_cases, normal_slides += dcc
     .normal_slides,
     normal_slides_requeued += dcc.normal_slides_requeued, chr_cases += dcc.chr_cases, chr_slides +=
     dcc.chr_slides,
     chr_slides_requeued += dcc.chr_slides_requeued, prev_atypical_cases += dcc.prev_atypical_cases,
     prev_atypical_slides += dcc.prev_atypical_slides,
     prev_atyp_slides_requeued += dcc.prev_atyp_slides_requeued, prev_abnormal_cases += dcc
     .prev_abnormal_cases, prev_abnormal_slides += dcc.prev_abnormal_slides,
     prev_abn_slides_requeued += dcc.prev_abn_slides_requeued, unsat_cases += dcc.unsat_cases,
     unsat_slides += dcc.unsat_slides,
     unsat_slides_requeued += dcc.unsat_slides_requeued, exceeded_limit_cases += dcc
     .exceeded_limit_cases, exceeded_limit_slides += dcc.exceeded_limit_slides,
     user_preference_cases += dcc.user_preference_cases, user_preference_slides += dcc
     .user_preference_slides
     IF ((request->print_daily_ind=1))
      section = 8, temp->screener_qual[scrnr].section_qual[section].section = section,
      gyn_cases_total = (dcc.gyn_cases_is+ dcc.gyn_cases_rs),
      gyn_slides_total = (((dcc.gyn_slides_is+ dcc.gyn_slides_rs)+ dcc.outside_gyn_is)+ dcc
      .outside_gyn_rs), ngyn_slides_total = (((dcc.ngyn_slides_is+ dcc.ngyn_slides_rs)+ dcc
      .outside_ngyn_is)+ dcc.outside_ngyn_rs), ngyn_cases_total = (dcc.ngyn_cases_is+ dcc
      .ngyn_cases_rs),
      all_slides_total = (gyn_slides_total+ ngyn_slides_total), slide_per_hour = cnvtreal((cnvtreal(
        temp->screener_qual[scrnr].slide_limit)/ cnvtreal(dcc.screen_hours))), percent_total = format
      (cnvtreal(((cnvtreal(all_slides_total)/ cnvtreal(temp->screener_qual[scrnr].slide_limit)) * 100
        )),"###.##"),
      stat = alterlist(temp->screener_qual[scrnr].section_qual[section].date_qual,dcnt), stat =
      alterlist(temp->screener_qual[scrnr].section_qual[section].date_qual[dcnt].drow_qual,8), temp->
      screener_qual[scrnr].section_qual[section].date_qual[dcnt].drow_qual[1].drow_text = build(
       format(cnvtdatetimeutc(dcc.record_dt_tm,1),"@SHORTDATE;;D"),"|"),
      temp->screener_qual[scrnr].section_qual[section].date_qual[dcnt].drow_qual[2].drow_text = build
      (dcc.gyn_cases_is,"|",dcc.gyn_cases_rs,"|",dcc.gyn_slides_is,
       "|",dcc.gyn_slides_rs,"|",dcc.outside_gyn_is,"|",
       dcc.outside_gyn_rs,"|",gyn_cases_total,"|",gyn_slides_total,
       "|"), temp->screener_qual[scrnr].section_qual[section].date_qual[dcnt].drow_qual[3].drow_text
       = build(dcc.ngyn_cases_is,"|",dcc.ngyn_cases_rs,"|",dcc.ngyn_slides_is,
       "|",dcc.ngyn_slides_rs,"|",dcc.outside_ngyn_is,"|",
       dcc.outside_ngyn_rs,"|",ngyn_cases_total,"|",ngyn_slides_total,
       "|"), temp->screener_qual[scrnr].section_qual[section].date_qual[dcnt].drow_qual[4].drow_text
       = build(all_slides_total,"|"),
      temp->screener_qual[scrnr].section_qual[section].date_qual[dcnt].drow_qual[6].drow_text = build
      (percent_total,"|"), temp->screener_qual[scrnr].section_qual[section].date_qual[dcnt].
      drow_qual[7].drow_text = build(dcc.screen_hours,"|"), temp->screener_qual[scrnr].section_qual[
      section].date_qual[dcnt].drow_qual[8].drow_text = build(slide_per_hour,"|")
     ENDIF
    WITH nocounter
   ;end select
   IF ((request->print_daily_ind=1))
    SELECT INTO "nl:"
     initial_slide_limit = scrn_dt_tm->screener_qual[1].initial_slide_limit, temp_scrn_qual_prsnl_id
      = temp->screener_qual[scrnr].prsnl_id, dcc.prsnl_id,
     dcc.record_dt_tm
     FROM daily_cytology_counts dcc
     PLAN (dcc
      WHERE (temp->screener_qual[scrnr].prsnl_id=dcc.prsnl_id)
       AND ((dcc.record_dt_tm >= cnvtdatetime(temp->d_start_dt)
       AND dcc.record_dt_tm <= cnvtdatetime(temp->d_end_dt)) OR (dcc.record_dt_tm >= cnvtdatetime(
       temp->d2_start_dt)
       AND dcc.record_dt_tm <= cnvtdatetime(temp->d2_end_dt))) )
     ORDER BY dcc.record_dt_tm
     HEAD REPORT
      num_of_rev_dates = value(size(scrn_dt_tm->screener_qual[scrnr].qual,5)), cnting_loop = 0, found
       = "N",
      dcnt = 1, section = 8, date_qual_cnt = 0
     DETAIL
      date_qual_cnt += 1, cnting_loop = 1, found = "N"
      WHILE (num_of_rev_dates >= cnting_loop)
        IF ((dcc.record_dt_tm >= scrn_dt_tm->screener_qual[scrnr].qual[cnting_loop].reviewed_dt_tm))
         temp->screener_qual[scrnr].section_qual[section].date_qual[date_qual_cnt].drow_qual[5].
         drow_text = build(scrn_dt_tm->screener_qual[scrnr].qual[cnting_loop].slide_limit,"|"), found
          = "Y", cnting_loop = (num_of_rev_dates+ 1)
        ELSE
         found = "N", cnting_loop += 1
        ENDIF
      ENDWHILE
      IF (found="N")
       temp->screener_qual[scrnr].section_qual[section].date_qual[date_qual_cnt].drow_qual[5].
       drow_text = build(scrn_dt_tm->screener_qual[scrnr].initial_slide_limit,"|")
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((temp->process_monthly_flag="Y"))
    SELECT INTO "nl:"
     mcc.prsnl_id
     FROM monthly_cytology_counts mcc
     PLAN (mcc
      WHERE (temp->screener_qual[scrnr].prsnl_id=mcc.prsnl_id)
       AND mcc.record_dt_tm >= cnvtdatetime(temp->m_start_dt)
       AND mcc.record_dt_tm <= cnvtdatetime(temp->m_end_dt))
     DETAIL
      gyn_cases_is += mcc.gyn_cases_is, gyn_cases_rs += mcc.gyn_cases_rs, gyn_slides_is += mcc
      .gyn_slides_is,
      gyn_slides_rs += mcc.gyn_slides_rs, outside_gyn_is += mcc.outside_gyn_is, outside_gyn_rs += mcc
      .outside_gyn_rs,
      ngyn_slides_is += mcc.ngyn_slides_is, ngyn_slides_rs += mcc.ngyn_slides_rs, outside_ngyn_is +=
      mcc.outside_ngyn_is,
      outside_ngyn_rs += mcc.outside_ngyn_rs, ngyn_cases_is += mcc.ngyn_cases_is, ngyn_cases_rs +=
      mcc.ngyn_cases_rs,
      normal_cases += mcc.normal_cases, normal_slides += mcc.normal_slides, normal_slides_requeued
       += mcc.normal_slides_requeued,
      chr_cases += mcc.chr_cases, chr_slides += mcc.chr_slides, chr_slides_requeued += mcc
      .chr_slides_requeued,
      prev_atypical_cases += mcc.prev_atypical_cases, prev_atypical_slides += mcc
      .prev_atypical_slides, prev_atyp_slides_requeued += mcc.prev_atyp_slides_requeued,
      prev_abnormal_cases += mcc.prev_abnormal_cases, prev_abnormal_slides += mcc
      .prev_abnormal_slides, prev_abn_slides_requeued += mcc.prev_abn_slides_requeued,
      unsat_cases += mcc.unsat_cases, unsat_slides += mcc.unsat_slides, unsat_slides_requeued += mcc
      .unsat_slides_requeued,
      exceeded_limit_cases += mcc.exceeded_limit_cases, exceeded_limit_slides += mcc
      .exceeded_limit_slides, user_preference_cases += mcc.user_preference_cases,
      user_preference_slides += mcc.user_preference_slides
     WITH nocounter
    ;end select
   ENDIF
   SET section = 2
   SET temp->screener_qual[scrnr].section_qual[section].section = section
   SET gyn_cases_total = (gyn_cases_is+ gyn_cases_rs)
   SET gyn_slides_total = (((gyn_slides_is+ gyn_slides_rs)+ outside_gyn_is)+ outside_gyn_rs)
   SET ngyn_slides_total = (((ngyn_slides_is+ ngyn_slides_rs)+ outside_ngyn_is)+ outside_ngyn_rs)
   SET ngyn_cases_total = (ngyn_cases_is+ ngyn_cases_rs)
   SET all_cases_is = (gyn_cases_is+ ngyn_cases_is)
   SET all_cases_rs = (gyn_cases_rs+ ngyn_cases_rs)
   SET all_slide_is = (gyn_slides_is+ ngyn_slides_is)
   SET all_slide_rs = (gyn_slides_rs+ ngyn_slides_rs)
   SET outside_all_is = (outside_gyn_is+ outside_ngyn_is)
   SET outside_all_rs = (outside_gyn_rs+ outside_ngyn_rs)
   SET all_case_total = (gyn_cases_total+ ngyn_cases_total)
   SET all_slides_total = (gyn_slides_total+ ngyn_slides_total)
   SET ncnt = 1
   SET stat = alterlist(temp->screener_qual[scrnr].section_qual[section].row_qual,3)
   SET temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(gyn_cases_is,
    "|",gyn_cases_rs,"|",gyn_slides_is,
    "|",gyn_slides_rs,"|",outside_gyn_is,"|",
    outside_gyn_rs,"|",gyn_cases_total,"|",gyn_slides_total,
    "|")
   SET ncnt += 1
   SET temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(ngyn_cases_is,
    "|",ngyn_cases_rs,"|",ngyn_slides_is,
    "|",ngyn_slides_rs,"|",outside_ngyn_is,"|",
    outside_ngyn_rs,"|",ngyn_cases_total,"|",ngyn_slides_total,
    "|")
   SET ncnt += 1
   SET temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(all_cases_is,
    "|",all_cases_rs,"|",all_slide_is,
    "|",all_slide_rs,"|",outside_all_is,"|",
    outside_all_rs,"|",all_case_total,"|",all_slides_total,
    "|")
   SET section = 3
   SET temp->screener_qual[scrnr].section_qual[section].section = section
   SET normal_percentage = format(((cnvtreal(normal_slides_requeued)/ cnvtreal(normal_slides)) * 100),
    "###.##")
   SET prev_atyp_percentage = format(((cnvtreal(prev_atyp_slides_requeued)/ cnvtreal(
     prev_atypical_slides)) * 100),"###.##")
   SET prev_abn_percentage = format(((cnvtreal(prev_abn_slides_requeued)/ cnvtreal(
     prev_abnormal_slides)) * 100),"###.##")
   SET chr_percentage = format(((cnvtreal(chr_slides_requeued)/ cnvtreal(chr_slides)) * 100),"###.##"
    )
   SET unsat_percentage = format(((cnvtreal(unsat_slides_requeued)/ cnvtreal(unsat_slides)) * 100),
    "###.##")
   SET ncnt = 1
   SET stat = alterlist(temp->screener_qual[scrnr].section_qual[section].row_qual,7)
   SET temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(normal_slides,
    "|",normal_slides_requeued,"|",normal_percentage,
    "|")
   SET ncnt += 1
   SET temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(
    prev_atypical_slides,"|",prev_atyp_slides_requeued,"|",prev_atyp_percentage,
    "|")
   SET ncnt += 1
   SET temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(
    prev_abnormal_slides,"|",prev_abn_slides_requeued,"|",prev_abn_percentage,
    "|")
   SET ncnt += 1
   SET temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(chr_slides,
    "|",chr_slides_requeued,"|",chr_percentage,
    "|")
   SET ncnt += 1
   SET temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(unsat_slides,
    "|",unsat_slides_requeued,"|",unsat_percentage,
    "|")
   SET ncnt += 1
   SET temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(
    exceeded_limit_slides,"|")
   SET ncnt += 1
   SET temp->screener_qual[scrnr].section_qual[section].row_qual[ncnt].row_text = build(
    user_preference_slides,"|")
   SET temp->screener_qual[scrnr].section_qual[5].section = 5
   SET gyn_scr_cnt = 0
   SET ngyn_scr_cnt = 0
   SELECT INTO "nl:"
    cse.screener_id, cse2.screener_id, n.mnemonic,
    n2.mnemonic, p.name_full_formatted, cdd_internal_flagn = decode(cdd.seq,cdd.internal_flag,0),
    cdd_internal_flag = decode(cdd.seq,
     IF (cdd.internal_flag=1) "VARIANCE"
     ELSEIF (cdd.internal_flag=2) "DISCREPANCY"
     ENDIF
     ,"NONE"), pc_accession_nbr = decode(pc.seq,uar_fmt_accession(pc.accession_nbr,size(pc
       .accession_nbr,1)),"")
    FROM cyto_screening_event cse,
     cyto_screening_event cse2,
     pathology_case pc,
     nomenclature n,
     nomenclature n2,
     prsnl p,
     dummyt d,
     cyto_diag_discrepancy cdd
    PLAN (cse
     WHERE (temp->screener_qual[scrnr].prsnl_id=cse.screener_id)
      AND cse.screen_dt_tm >= cnvtdatetime(request->start_dt)
      AND cse.screen_dt_tm <= cnvtdatetime(request->end_dt)
      AND cse.initial_screener_ind=1
      AND cse.active_ind=1)
     JOIN (cse2
     WHERE cse.case_id=cse2.case_id
      AND cse2.verify_ind=1)
     JOIN (pc
     WHERE cse.case_id=pc.case_id)
     JOIN (n
     WHERE cse.nomenclature_id=n.nomenclature_id)
     JOIN (n2
     WHERE cse2.nomenclature_id=n2.nomenclature_id)
     JOIN (p
     WHERE cse2.screener_id=p.person_id)
     JOIN (d)
     JOIN (cdd
     WHERE cse.reference_range_factor_id=cdd.reference_range_factor_id
      AND cse.nomenclature_id=cdd.nomenclature_x_id
      AND cse2.nomenclature_id=cdd.nomenclature_y_id
      AND cdd.internal_flag > 0)
    ORDER BY cse.diagnostic_category_cd
    HEAD REPORT
     accession_number = "                   ", desccnt = 0.0, descper = 0.0,
     varicnt = 0.0, variper = 0.0, totcnt = 0,
     dcnt = 0, ncnt = 0, temp->screener_qual[scrnr].section_qual[5].available = "N"
    DETAIL
     IF (cdd_internal_flagn > 0)
      temp->screener_qual[scrnr].section_qual[5].available = "Y", accession_number = pc_accession_nbr,
      ncnt += 1,
      stat = alterlist(temp->screener_qual[scrnr].section_qual[5].row_qual,ncnt), temp->
      screener_qual[scrnr].section_qual[5].row_qual[ncnt].row_text = build(accession_number,"|",
       format(cnvtdatetime(cse.screen_dt_tm),"@SHORTDATE;;D"),"|",trim(n.mnemonic),
       "|",trim(n2.mnemonic),"|",cdd_internal_flag,"|",
       trim(p.name_full_formatted),"|",format(cnvtdatetime(cse2.screen_dt_tm),"@SHORTDATE;;D"),"|"),
      totcnt += 1
      CASE (cdd_internal_flagn)
       OF 1:
        varicnt += 1
       OF 2:
        desccnt += 1
      ENDCASE
     ENDIF
     FOR (dcnt = 1 TO cnvtint(size(temp->diag_cat_qual,5)))
       IF ((cse.diagnostic_category_cd=temp->diag_cat_qual[dcnt].category_cd))
        temp->diag_cat_qual[dcnt].screener_cnt += 1
        IF ((temp->diag_cat_qual[dcnt].cdf_meaning="GYN"))
         gyn_scr_cnt += 1
        ENDIF
        IF ((temp->diag_cat_qual[dcnt].cdf_meaning="NGYN"))
         ngyn_scr_cnt += 1
         FOR (scrn = 1 TO size(temp->ind_screener_qual,5))
           IF ((temp->ind_screener_qual[scrn].prsnl_id=cse.screener_id))
            temp->ind_screener_qual[scrn].cnt += 1, cnt = temp->ind_screener_qual[scrn].cnt
            IF ((cnt > temp->max_cases))
             temp->max_cases = cnt
            ENDIF
            stat = alterlist(temp->ind_screener_qual[scrn].individ_qual,cnt), temp->
            ind_screener_qual[scrn].individ_qual[cnt].case_id = cse.case_id, temp->ind_screener_qual[
            scrn].individ_qual[cnt].diagnostic_category_cd = cse.diagnostic_category_cd
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
    FOOT REPORT
     descper = ((desccnt/ gyn_cases_total) * 100), variper = ((varicnt/ gyn_cases_total) * 100), temp
     ->screener_qual[scrnr].section_qual[4].section = 4,
     stat = alterlist(temp->screener_qual[scrnr].section_qual[4].row_qual,2), temp->screener_qual[
     scrnr].section_qual[4].row_qual[1].row_text = build(desccnt,"|",descper,"|"), temp->
     screener_qual[scrnr].section_qual[4].row_qual[2].row_text = build(varicnt,"|",variper,"|")
    WITH nocounter, outerjoin = d, nullreport
   ;end select
   SET section = 6
   SET temp->screener_qual[scrnr].section_qual[section].section = section
   SET section = 7
   SET temp->screener_qual[scrnr].section_qual[section].section = section
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(size(temp->diag_cat_qual,5)))
    HEAD REPORT
     gcnt = 0, ngcnt = 0
    DETAIL
     IF ((temp->diag_cat_qual[d.seq].cdf_meaning="GYN"))
      gcnt += 1, stat = alterlist(temp->screener_qual[scrnr].section_qual[6].row_qual,gcnt), temp->
      screener_qual[scrnr].section_qual[6].row_qual[gcnt].row_text = build(trim(temp->diag_cat_qual[d
        .seq].category_disp),"|",temp->diag_cat_qual[d.seq].screener_cnt,"|",cnvtreal(((cnvtreal(temp
         ->diag_cat_qual[d.seq].screener_cnt)/ cnvtreal(gyn_scr_cnt)) * 100)),
       "|",temp->diag_cat_qual[d.seq].all_cnt,"|",cnvtreal(((cnvtreal(temp->diag_cat_qual[d.seq].
         all_cnt)/ cnvtreal(gyn_all_cnt)) * 100)),"|",
       temp->diag_cat_qual[d.seq].rpt_cnt,"|",cnvtreal(((cnvtreal(temp->diag_cat_qual[d.seq].rpt_cnt)
        / cnvtreal(gyn_rpt_cnt)) * 100)),"|")
     ENDIF
     IF ((temp->diag_cat_qual[d.seq].cdf_meaning="NGYN"))
      ngcnt += 1, stat = alterlist(temp->screener_qual[scrnr].section_qual[7].row_qual,ngcnt), temp->
      screener_qual[scrnr].section_qual[7].row_qual[ngcnt].row_text = build(trim(temp->diag_cat_qual[
        d.seq].category_disp),"|",temp->diag_cat_qual[d.seq].screener_cnt,"|",cnvtreal(((cnvtreal(
         temp->diag_cat_qual[d.seq].screener_cnt)/ cnvtreal(ngyn_scr_cnt)) * 100)),
       "|",temp->diag_cat_qual[d.seq].all_cnt,"|",cnvtreal(((cnvtreal(temp->diag_cat_qual[d.seq].
         all_cnt)/ cnvtreal(ngyn_all_cnt)) * 100)),"|",
       temp->diag_cat_qual[d.seq].rpt_cnt,"|",cnvtreal(((cnvtreal(temp->diag_cat_qual[d.seq].rpt_cnt)
        / cnvtreal(ngyn_rpt_cnt)) * 100)),"|")
     ENDIF
    FOOT REPORT
     gcnt += 1, stat = alterlist(temp->screener_qual[scrnr].section_qual[6].row_qual,gcnt), temp->
     screener_qual[scrnr].section_qual[6].row_qual[gcnt].row_text = build(gyn_scr_cnt,"|",gyn_all_cnt,
      "|",gyn_rpt_cnt,
      "|"),
     ngcnt += 1, stat = alterlist(temp->screener_qual[scrnr].section_qual[7].row_qual,ngcnt), temp->
     screener_qual[scrnr].section_qual[7].row_qual[ngcnt].row_text = build(ngyn_scr_cnt,"|",
      ngyn_all_cnt,"|",ngyn_rpt_cnt,
      "|")
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","DUMMYT 2")
    GO TO exit_script
   ENDIF
 ENDFOR
 IF ((request->separate_diagnosis="Y"))
  SELECT INTO "nl:"
   cs.specimen_cd
   FROM (dummyt d1  WITH seq = value(size(temp->ind_screener_qual,5))),
    (dummyt d2  WITH seq = value(temp->max_cases)),
    case_specimen cs
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(temp->ind_screener_qual[d1.seq].individ_qual,5))
    JOIN (cs
    WHERE (temp->ind_screener_qual[d1.seq].individ_qual[d2.seq].case_id=cs.case_id)
     AND cs.cancel_cd IN (null, 0.0))
   HEAD REPORT
    x = 0
   DETAIL
    temp->ind_screener_qual[d1.seq].individ_qual[d2.seq].specimen_cd = cs.specimen_cd
   WITH nocounter
  ;end select
  IF (no_ngyn_all_cnts="F")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(temp->all_qual,5))),
     case_specimen cs
    PLAN (d1)
     JOIN (cs
     WHERE (temp->all_qual[d1.seq].case_id=cs.case_id)
      AND cs.cancel_cd IN (null, 0.0))
    HEAD REPORT
     x = 0
    DETAIL
     temp->all_qual[d1.seq].specimen_cd = cs.specimen_cd, temp->rpt_qual[d1.seq].specimen_cd = cs
     .specimen_cd
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->separate_diagnosis="Y")
  AND (temp->max_cases > 0))
  SELECT INTO "nl:"
   d1_seq = d1.seq, temp->ind_screener_qual[d1.seq].individ_qual[d2.seq].diagnostic_category_cd,
   diag_category = uar_get_code_display(temp->ind_screener_qual[d1.seq].individ_qual[d2.seq].
    diagnostic_category_cd),
   temp->ind_screener_qual[d1.seq].individ_qual[d2.seq].specimen_cd, specimen = uar_get_code_display(
    temp->ind_screener_qual[d1.seq].individ_qual[d2.seq].specimen_cd)
   FROM (dummyt d1  WITH seq = value(size(temp->ind_screener_qual,5))),
    (dummyt d2  WITH seq = value(temp->max_cases))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(temp->ind_screener_qual[d1.seq].individ_qual,5))
   ORDER BY d1_seq, specimen, diag_category
   HEAD REPORT
    qual_cnt = 0
   HEAD d1_seq
    qual_cnt = 0
   DETAIL
    qual_cnt += 1, stat = alterlist(temp->ind_screener_qual[d1.seq].sorted_individ_qual,qual_cnt),
    temp->ind_screener_qual[d1.seq].sorted_individ_qual[qual_cnt].case_id = temp->ind_screener_qual[
    d1.seq].individ_qual[d2.seq].case_id,
    temp->ind_screener_qual[d1.seq].sorted_individ_qual[qual_cnt].diagnostic_category_cd = temp->
    ind_screener_qual[d1.seq].individ_qual[d2.seq].diagnostic_category_cd, temp->ind_screener_qual[d1
    .seq].sorted_individ_qual[qual_cnt].specimen_cd = temp->ind_screener_qual[d1.seq].individ_qual[d2
    .seq].specimen_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   specimen_cd = temp->all_qual[d1.seq].specimen_cd, specimen_disp = uar_get_code_display(temp->
    all_qual[d1.seq].specimen_cd)
   FROM (dummyt d1  WITH seq = value(size(temp->all_qual,5)))
   PLAN (d1)
   ORDER BY specimen_disp, specimen_cd
   HEAD REPORT
    spec_cnt = 0
   HEAD specimen_disp
    row + 0
   HEAD specimen_cd
    spec_cnt += 1
    IF (mod(spec_cnt,10)=1)
     stat = alterlist(temp->all_specimen_qual,(spec_cnt+ 9)), stat = alterlist(temp->
      rpt_specimen_qual,(spec_cnt+ 9))
    ENDIF
    temp->all_specimen_qual[spec_cnt].specimen_cd = temp->all_qual[d1.seq].specimen_cd, temp->
    all_specimen_qual[spec_cnt].specimen_disp = specimen_disp, temp->rpt_specimen_qual[spec_cnt].
    specimen_cd = temp->all_qual[d1.seq].specimen_cd,
    temp->rpt_specimen_qual[spec_cnt].specimen_disp = specimen_disp
   DETAIL
    row + 0
   FOOT REPORT
    stat = alterlist(temp->all_specimen_qual,spec_cnt), stat = alterlist(temp->rpt_specimen_qual,
     spec_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   d1.seq, specimen_cd = temp->ind_screener_qual[d1.seq].sorted_individ_qual[d2.seq].specimen_cd,
   specimen_disp = uar_get_code_display(temp->ind_screener_qual[d1.seq].sorted_individ_qual[d2.seq].
    specimen_cd),
   diagnostic_category_cd = temp->ind_screener_qual[d1.seq].sorted_individ_qual[d2.seq].
   diagnostic_category_cd, diagnostic_category_disp = uar_get_code_display(temp->ind_screener_qual[d1
    .seq].sorted_individ_qual[d2.seq].diagnostic_category_cd)
   FROM (dummyt d1  WITH seq = value(size(temp->ind_screener_qual,5))),
    (dummyt d2  WITH seq = value(temp->max_cases))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(temp->ind_screener_qual[d1.seq].sorted_individ_qual,5))
   ORDER BY d1.seq, specimen_disp, specimen_cd
   HEAD REPORT
    last_specimen_cd = 0, last_diagnosis_cd = 0, spec_cnt = 0,
    diag_cnt = 0
   HEAD d1.seq
    spec_cnt = 0
   HEAD specimen_disp
    row + 0
   HEAD specimen_cd
    diag_cnt = 0, spec_cnt += 1, stat = alterlist(temp->ind_screener_qual[d1.seq].specimen_qual,
     spec_cnt),
    temp->ind_screener_qual[d1.seq].specimen_qual[spec_cnt].specimen_cd = temp->ind_screener_qual[d1
    .seq].sorted_individ_qual[d2.seq].specimen_cd, temp->ind_screener_qual[d1.seq].specimen_qual[
    spec_cnt].specimen_disp = specimen_disp, last_diagnostic_category_cd = 0,
    temp->ind_screener_qual[d1.seq].specimen_qual[spec_cnt].tot_diag_cnt = 0
    FOR (xx = 1 TO size(temp->diag_cat_qual,5))
      IF ((temp->diag_cat_qual[xx].cdf_meaning="NGYN"))
       diag_cnt += 1, stat = alterlist(temp->ind_screener_qual[d1.seq].specimen_qual[spec_cnt].
        diagnosis,diag_cnt), temp->ind_screener_qual[d1.seq].specimen_qual[spec_cnt].diagnosis[
       diag_cnt].diagnostic_category_cd = temp->diag_cat_qual[xx].category_cd,
       temp->ind_screener_qual[d1.seq].specimen_qual[spec_cnt].diagnosis[diag_cnt].
       diagnostic_category_disp = temp->diag_cat_qual[xx].category_disp
      ENDIF
    ENDFOR
   DETAIL
    FOR (yy = 1 TO size(temp->ind_screener_qual[d1.seq].specimen_qual[spec_cnt].diagnosis,5))
      IF ((temp->ind_screener_qual[d1.seq].specimen_qual[spec_cnt].diagnosis[yy].
      diagnostic_category_cd=temp->ind_screener_qual[d1.seq].sorted_individ_qual[d2.seq].
      diagnostic_category_cd))
       temp->ind_screener_qual[d1.seq].specimen_qual[spec_cnt].diagnosis[yy].diagnostic_cnt += 1,
       temp->ind_screener_qual[d1.seq].specimen_qual[spec_cnt].tot_diag_cnt += 1, yy = size(temp->
        diag_cat_qual,5)
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   d3exists = decode(d3.seq,1,0)
   FROM (dummyt d1  WITH seq = value(size(temp->all_specimen_qual,5))),
    (dummyt d2  WITH seq = value(size(temp->diag_cat_qual,5))),
    (dummyt d3  WITH seq = value(size(temp->all_qual,5)))
   PLAN (d1)
    JOIN (d2
    WHERE (temp->diag_cat_qual[d2.seq].cdf_meaning="NGYN"))
    JOIN (d3
    WHERE (temp->all_specimen_qual[d1.seq].specimen_cd=temp->all_qual[d3.seq].specimen_cd)
     AND (temp->diag_cat_qual[d2.seq].category_cd=temp->all_qual[d3.seq].diagnostic_category_cd))
   ORDER BY d1.seq, d2.seq
   HEAD d1.seq
    diag_cnt = 0
   HEAD d2.seq
    diag_cnt += 1
    IF (mod(diag_cnt,10)=1)
     stat = alterlist(temp->all_specimen_qual[d1.seq].diagnosis,(diag_cnt+ 9))
    ENDIF
    temp->all_specimen_qual[d1.seq].diagnosis[diag_cnt].diagnostic_category_cd = temp->diag_cat_qual[
    d2.seq].category_cd, temp->all_specimen_qual[d1.seq].diagnosis[diag_cnt].diagnostic_category_disp
     = temp->diag_cat_qual[d2.seq].category_disp, temp->all_specimen_qual[d1.seq].diagnosis[diag_cnt]
    .diagnostic_cnt = 0
   DETAIL
    IF (d3exists=1)
     temp->all_specimen_qual[d1.seq].diagnosis[diag_cnt].diagnostic_cnt += 1, temp->
     all_specimen_qual[d1.seq].tot_diag_cnt += 1
    ENDIF
   FOOT  d1.seq
    stat = alterlist(temp->all_specimen_qual[d1.seq].diagnosis,diag_cnt)
   WITH outerjoin = d2
  ;end select
  SELECT INTO "nl:"
   d3exists = decode(d3.seq,1,0)
   FROM (dummyt d1  WITH seq = value(size(temp->rpt_specimen_qual,5))),
    (dummyt d2  WITH seq = value(size(temp->diag_cat_qual,5))),
    (dummyt d3  WITH seq = value(size(temp->rpt_qual,5)))
   PLAN (d1)
    JOIN (d2
    WHERE (temp->diag_cat_qual[d2.seq].cdf_meaning="NGYN"))
    JOIN (d3
    WHERE (temp->rpt_specimen_qual[d1.seq].specimen_cd=temp->rpt_qual[d3.seq].specimen_cd)
     AND (temp->diag_cat_qual[d2.seq].category_cd=temp->rpt_qual[d3.seq].diagnostic_category_cd))
   ORDER BY d1.seq, d2.seq
   HEAD d1.seq
    diag_cnt = 0
   HEAD d2.seq
    diag_cnt += 1
    IF (mod(diag_cnt,10)=1)
     stat = alterlist(temp->rpt_specimen_qual[d1.seq].diagnosis,(diag_cnt+ 9))
    ENDIF
    temp->rpt_specimen_qual[d1.seq].diagnosis[diag_cnt].diagnostic_category_cd = temp->diag_cat_qual[
    d2.seq].category_cd, temp->rpt_specimen_qual[d1.seq].diagnosis[diag_cnt].diagnostic_category_disp
     = temp->diag_cat_qual[d2.seq].category_disp
   DETAIL
    IF (d3exists=1)
     temp->rpt_specimen_qual[d1.seq].diagnosis[diag_cnt].diagnostic_cnt += 1, temp->
     rpt_specimen_qual[d1.seq].tot_diag_cnt += 1
    ENDIF
   FOOT  d1.seq
    stat = alterlist(temp->rpt_specimen_qual[d1.seq].diagnosis,diag_cnt)
   WITH outerjoin = d2
  ;end select
 ENDIF
 EXECUTE cpm_create_file_name_logical "aps_cyto_stats", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  screener_name = concat(trim(temp->screener_qual[d.seq].name_full_formatted),cnvtstring(temp->
    screener_qual[d.seq].prsnl_id,19,0))
  FROM (dummyt d  WITH seq = value(size(temp->screener_qual,5)))
  ORDER BY screener_name
  HEAD REPORT
   line1 = fillstring(125,"-"), line2 = fillstring(116,"-"), first_time = 0,
   screener_num = 0, cnt1 = 0, rpt_printed = " "
  HEAD PAGE
   row + 1, col 0, captions->rpt,
   col + 1, captions->nm, col 56,
   CALL center(captions->ana,row,132), col 110, captions->dt,
   col 117, curdate"@SHORTDATE;;D", row + 1,
   col 0, captions->dir, col 110,
   captions->tm, col 117, curtime"@TIMENOSECONDS;;M",
   row + 1, col 52,
   CALL center(captions->title,row,132),
   col 112, captions->bye, col 117,
   request->curuser, row + 1, col 110,
   captions->pag, col 117, curpage"###",
   row + 1, col 0, captions->grp,
   col 15, temp->run_group, row + 1,
   col 0, captions->use, col 15,
   temp->run_user
   IF ((request->bshowinactives=1))
    row + 1, col 15, captions->inac
   ENDIF
   row + 1, col 0, captions->dt_rg,
   col 15, temp->run_date, row + 2,
   line1, row + 1
  DETAIL
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   IF (first_time=0)
    first_time = 1
   ELSE
    IF ((request->page_break=1))
     BREAK
    ENDIF
   ENDIF
   col 0, captions->use, col 8,
   temp->screener_qual[d.seq].name_full_formatted, row + 1
   FOR (a = 1 TO cnvtint(size(temp->screener_qual[d.seq].section_qual,5)))
    row + 1,
    CASE (temp->screener_qual[d.seq].section_qual[a].section)
     OF 1:
      IF ((temp->screener_qual[d.seq].slide_limit > 0))
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
       col 10, captions->cur_lim, col 63
       IF ((temp->screener_qual[d.seq].security > 0))
        captions->cur_qa
       ENDIF
       row + 1, col 11, captions->tot_sl,
       CALL get_text(1,temp->screener_qual[d.seq].section_qual[1].row_qual[1].row_text,"|"), col 27,
       real"###.#;i;f",
       col 64
       IF ((temp->screener_qual[d.seq].security > 0))
        captions->n_his,
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[1].row_qual[1].row_text,"|"),
        col 98,
        real"###", col 102, "%"
       ENDIF
       row + 1, col 11, captions->tot_hr,
       CALL get_text(1,temp->screener_qual[d.seq].section_qual[1].row_qual[2].row_text,"|"), col 27,
       real"###.#;i;f",
       col 64
       IF ((temp->screener_qual[d.seq].security > 0))
        captions->a_his,
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[1].row_qual[2].row_text,"|"),
        col 98,
        real"###", col 102, "%"
       ENDIF
       row + 1, col 11, captions->calc_max,
       CALL get_text(1,temp->screener_qual[d.seq].section_qual[1].row_qual[3].row_text,"|"), col 49,
       real"###.##;i;f",
       col 64
       IF ((temp->screener_qual[d.seq].security > 0))
        captions->ab_his,
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[1].row_qual[3].row_text,"|"),
        col 98,
        real"###", col 102, "%"
       ENDIF
       row + 1, col 11
       IF ((temp->screener_qual[d.seq].security > 0))
        captions->ver_sec,
        CALL get_text(1,temp->screener_qual[d.seq].section_qual[1].row_qual[4].row_text,"|"), col 39,
        real"###", col 64, captions->h_risk,
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[1].row_qual[4].row_text,"|"),
        col 98, real"###",
        col 102, "%", row + 1
       ENDIF
       col 64
       IF ((temp->screener_qual[d.seq].security > 0))
        captions->unsat,
        CALL get_text(1,temp->screener_qual[d.seq].section_qual[1].row_qual[5].row_text,"|"), col 98,
        real"###", col 102, "%"
       ENDIF
       row + 1
      ELSE
       row- (1)
      ENDIF
     OF 2:
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
      ,row + 1,col 10,line2,
      col 13," ",captions->sum_stat,
      " ",row + 1,col 38,
      captions->cse_no,col 61,captions->i_slide,
      col 84,captions->o_slide,col 108,
      captions->cse_no,col 117,captions->slide_no,
      row + 1,col 11,captions->cse,
      " ",captions->typ,col 38,
      captions->sc_resc,col 61,captions->sc_resc,
      col 84,captions->sc_resc,col 108,
      captions->tot,col 117,captions->tot,
      row + 1,col 11,"---------",
      col 38,"-------------------",col 61,
      "-------------------",col 83,"-------------------",
      col 108,"-----",col 117,
      "-----",row + 1,col 11,
      captions->gyn,
      CALL get_text(1,temp->screener_qual[d.seq].section_qual[2].row_qual[1].row_text,"|")col 38,
      real"#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[1].row_text,"|")col
       47,
      real"#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[1].row_text,"|")col
       60,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[1].row_text,"|")col
       69,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[1].row_text,"|")col
       83,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[1].row_text,"|")col
       92,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[1].row_text,"|")col
       108,
      real"#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[1].row_text,"|")col
       116,
      real"#####.#;i;f",row + 1,col 11,
      captions->non_gyn,
      CALL get_text(1,temp->screener_qual[d.seq].section_qual[2].row_qual[2].row_text,"|")col 38,
      real"#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[2].row_text,"|")col
       47,
      real"#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[2].row_text,"|")col
       60,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[2].row_text,"|")col
       69,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[2].row_text,"|")col
       83,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[2].row_text,"|")col
       92,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[2].row_text,"|")col
       108,
      real"#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[2].row_text,"|")col
       116,
      real"#####.#;i;f",row + 1,col 11,
      captions->all_cse,
      CALL get_text(1,temp->screener_qual[d.seq].section_qual[2].row_qual[3].row_text,"|")col 38,
      real"#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[3].row_text,"|")col
       47,
      real"#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[3].row_text,"|")col
       60,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[3].row_text,"|")col
       69,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[3].row_text,"|")col
       83,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[3].row_text,"|")col
       92,
      real"#####.#;i;f",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[3].row_text,"|")col
       108,
      real"#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[2].row_qual[3].row_text,"|")col
       116,
      real"#####.#;i;f"
     OF 3:
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
      ,row + 1,col 10,line2,
      col 13," ",captions->qual_stat,
      " ",row + 1,col 11,
      captions->pat_cse,col 39,captions->slide_no,
      col 52,captions->slide_no,col 63,
      captions->per,row + 1,col 39,
      captions->avail,col 52,captions->sel,
      col 63,captions->sel,row + 1,
      col 11,"---------------------------",col 39,
      "---------",col 52,"--------",
      col 63,"--------",
      IF ((temp->screener_qual[d.seq].security > 0))
       row + 1, col 11, captions->nor_h,
       CALL get_text(1,temp->screener_qual[d.seq].section_qual[3].row_qual[1].row_text,"|"), col 39,
       real"#####.#;i;f",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[3].row_qual[1].row_text,"|"),
       col 51, real"#####.#;i;f",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[3].row_qual[1].row_text,"|"),
       col 64, real"###.##;i;f",
       col 71, "%", row + 1,
       col 11, captions->aty_h,
       CALL get_text(1,temp->screener_qual[d.seq].section_qual[3].row_qual[2].row_text,"|"),
       col 39, real"#####.#;i;f",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[3].row_qual[2].row_text,"|"),
       col 51, real"#####.#;i;f",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[3].row_qual[2].row_text,"|"),
       col 64, real"###.##;i;f", col 71,
       "%", row + 1, col 11,
       captions->ab_h,
       CALL get_text(1,temp->screener_qual[d.seq].section_qual[3].row_qual[3].row_text,"|"), col 39,
       real"#####.#;i;f",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[3].row_qual[3].row_text,"|"),
       col 51,
       real"#####.#;i;f",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[3].row_qual[3].row_text,"|"),
       col 64,
       real"###.##;i;f", col 71, "%",
       row + 1, col 11, captions->clin_high,
       CALL get_text(1,temp->screener_qual[d.seq].section_qual[3].row_qual[4].row_text,"|"), col 39,
       real"#####.#;i;f",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[3].row_qual[4].row_text,"|"),
       col 51, real"#####.#;i;f",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[3].row_qual[4].row_text,"|"),
       col 64, real"###.##;i;f",
       col 71, "%", row + 1,
       col 11, captions->not_sat,
       CALL get_text(1,temp->screener_qual[d.seq].section_qual[3].row_qual[5].row_text,"|"),
       col 39, real"#####.#;i;f",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[3].row_qual[5].row_text,"|"),
       col 51, real"#####.#;i;f",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[3].row_qual[5].row_text,"|"),
       col 64, real"###.##;i;f", col 71,
       "%"
      ENDIF
      ,row + 1,col 11,captions->exceed,
      CALL get_text(1,temp->screener_qual[d.seq].section_qual[3].row_qual[6].row_text,"|")col 51,real
      "#####.#;i;f",
      IF ((temp->screener_qual[d.seq].security > 0))
       row + 1, col 11, captions->user_sel,
       CALL get_text(1,temp->screener_qual[d.seq].section_qual[3].row_qual[7].row_text,"|"), col 51,
       real"#####.#;i;f"
      ENDIF
     OF 4:
      IF (((row+ 5) > maxrow))
       BREAK
      ENDIF
      ,row + 1,col 10,line2,
      col 13," ",captions->var_dis,
      " ",row + 1,col 11,
      captions->cat,col 23,captions->cse_no,
      col 32,captions->cse_per,row + 1,
      col 11,"--------",col 23,
      "-------",col 32,"-------",
      row + 1,col 11,captions->dis,
      CALL get_text(1,temp->screener_qual[d.seq].section_qual[4].row_qual[1].row_text,"|")col 23,real
      "#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[4].row_qual[1].row_text,"|")col
       32,real"###.##;i;f",
      col 39,"%",row + 1,
      col 11,captions->var,
      CALL get_text(1,temp->screener_qual[d.seq].section_qual[4].row_qual[2].row_text,"|")col 23,real
      "#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[4].row_qual[2].row_text,"|")col
       32,real"###.##;i;f",col 39,"%"
     OF 5:
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
      ,row + 1,col 11,captions->cse,
      col 30,captions->scr,col 40,
      captions->init_scr,col 64,captions->rescr,
      col 89,captions->typ,col 102,
      " ",col 108,captions->ver_by,
      row + 1,col 11,line2,
      IF ((temp->screener_qual[d.seq].section_qual[5].available="Y"))
       FOR (ncnt = 1 TO cnvtint(size(temp->screener_qual[d.seq].section_qual[5].row_qual,5)))
         IF (((row+ 10) > maxrow))
          BREAK
         ENDIF
         row + 1,
         CALL get_text(1,temp->screener_qual[d.seq].section_qual[5].row_qual[ncnt].row_text,"|"), col
          11,
         text"###################",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[5].row_qual[ncnt].row_text,
         "|"), col 30,
         text"#########",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[5].row_qual[ncnt].row_text,
         "|"), col 40,
         text"####################",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[5].row_qual[ncnt].row_text,
         "|"), col 64,
         text"####################",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[5].row_qual[ncnt].row_text,
         "|"), col 89,
         text"####################",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[5].row_qual[ncnt].row_text,
         "|"), col 108,
         text"#############",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[5].row_qual[ncnt].row_text,
         "|"), col 122,
         text"########"
       ENDFOR
      ELSE
       row + 2,
       CALL center(captions->noted,row,132)
      ENDIF
      ,row + 1
     OF 6:
      IF (((row+ 15) > maxrow))
       BREAK
      ENDIF
      ,row + 1,col 10,line2,
      col 13," ",captions->diag_sum,
      " ",row + 1,col 53,
      captions->us_scr,col 79,captions->all_scr,
      col 105,captions->rpt_ver,row + 1,
      col 11,captions->diag_cat,col 54,
      captions->an,col 80,captions->an,
      col 107,captions->an,row + 1,
      col 11,"--------------------------------",col 53,
      "-----",col 63,"-----",
      col 79,"-----",col 89,
      "-----",col 105,"--------",
      col 117,"-----",tcnt = cnvtint(size(temp->screener_qual[d.seq].section_qual[6].row_qual,5)),
      FOR (ncnt = 1 TO (tcnt - 1))
        IF (((row+ 5) > maxrow))
         BREAK
        ENDIF
        row + 1,
        CALL get_text(1,temp->screener_qual[d.seq].section_qual[6].row_qual[ncnt].row_text,"|"), col
        11,
        text"#########################################",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[6].row_qual[ncnt].row_text,
        "|"), col 53,
        real"#####",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[6].row_qual[ncnt].row_text,
        "|"), col 63,
        real"###.##;i;f",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[6].row_qual[ncnt].row_text,
        "|"), col 79,
        real"#####",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[6].row_qual[ncnt].row_text,
        "|"), col 89,
        real"###.##;i;f",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[6].row_qual[ncnt].row_text,
        "|"), col 105,
        real"########",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[6].row_qual[ncnt].row_text,
        "|"), col 117,
        real"###.##;i;f"
      ENDFOR
      ,row + 1,col 11,captions->total,
      CALL get_text(1,temp->screener_qual[d.seq].section_qual[6].row_qual[tcnt].row_text,"|")col 53,
      real"#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[6].row_qual[tcnt].row_text,"|")
      col 79,real"#####",
      CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[6].row_qual[tcnt].row_text,"|")
      col 105,real"########"
     OF 7:
      IF ((request->separate_diagnosis != "Y"))
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
       row + 1, col 53, captions->us_scr,
       col 79, captions->all_scr, col 105,
       captions->rpt_ver, row + 1, col 11,
       captions->non_diag, col 54, captions->an,
       col 80, captions->an, col 107,
       captions->an, row + 1, col 11,
       "-------------------------------------", col 53, "-----",
       col 63, "-----", col 79,
       "-----", col 89, "-----",
       col 105, "--------", col 117,
       "-----", tcnt = cnvtint(size(temp->screener_qual[d.seq].section_qual[7].row_qual,5))
       FOR (ncnt = 1 TO (tcnt - 1))
         IF (((row+ 10) > maxrow))
          BREAK
         ENDIF
         row + 1,
         CALL get_text(1,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,"|"), col
          11,
         text"#########################################",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 53,
         real"#####",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 63,
         real"###.##;i;f",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 79,
         real"#####",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 89,
         real"###.##;i;f",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 105,
         real"########",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 117,
         real"###.##;i;f"
       ENDFOR
       row + 1, col 11, captions->total,
       CALL get_text(1,temp->screener_qual[d.seq].section_qual[7].row_qual[tcnt].row_text,"|"), col
       53, real"#####",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[tcnt].row_text,"|"
       ), col 79, real"#####",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[tcnt].row_text,"|"
       ), col 105, real"########"
      ELSE
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
       row + 1, col 53, captions->us_scr,
       col 79, captions->all_scr, col 105,
       captions->rpt_ver, row + 1, col 11,
       captions->non_diag, col 54, captions->an,
       col 80, captions->an, col 107,
       captions->an, row + 1, col 11,
       "-------------------------------------", col 53, "-----",
       col 63, "-----", col 79,
       "-----", col 89, "-----",
       col 105, "--------", col 117,
       "-----", row + 1, col 11,
       captions->spe, col + 1, captions->all_spe,
       tcnt = cnvtint(size(temp->screener_qual[d.seq].section_qual[7].row_qual,5))
       FOR (ncnt = 1 TO (tcnt - 1))
         IF (((row+ 10) > maxrow))
          BREAK
         ENDIF
         row + 1,
         CALL get_text(1,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,"|"), col
          11,
         text"#########################################",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 53,
         real"#####",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 63,
         real"###.##;i;f",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 79,
         real"#####",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 89,
         real"###.##;i;f",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 105,
         real"########",
         CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[ncnt].row_text,
         "|"), col 117,
         real"###.##;i;f"
       ENDFOR
       row + 1, col 11, captions->total,
       CALL get_text(1,temp->screener_qual[d.seq].section_qual[7].row_qual[tcnt].row_text,"|"), col
       53, real"#####",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[tcnt].row_text,"|"
       ), col 79, real"#####",
       CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[7].row_qual[tcnt].row_text,"|"
       ), col 105, real"########",
       row + 1
       FOR (cnt1 = 1 TO value(size(temp->ind_screener_qual,5)))
         IF ((temp->ind_screener_qual[cnt1].prsnl_id=temp->screener_qual[d.seq].prsnl_id))
          screener_num = cnt1
         ENDIF
       ENDFOR
       speccnt = cnvtint(size(temp->ind_screener_qual[screener_num].specimen_qual,5)), diagcnt =
       cnvtint(size(temp->ind_screener_qual[screener_num].specimen_qual[speccnt].diagnosis,5))
       FOR (i_loop1 = 1 TO speccnt)
         IF (((row+ 10) > maxrow))
          BREAK
         ENDIF
         row + 1, col 53, captions->us_scr,
         col 79, captions->all_scr, col 105,
         captions->rpt_ver, row + 1, col 11,
         captions->non_diag, col 54, captions->an,
         col 80, captions->an, col 107,
         captions->an, row + 1, col 11,
         "-------------------------------------", col 53, "-----",
         col 63, "------", col 79,
         "-----", col 89, "------",
         col 105, "--------", col 117,
         "------", row + 1, col 11,
         captions->spe, temp->ind_screener_qual[screener_num].specimen_qual[i_loop1].specimen_disp
         "####################################", ind_spec_diag_cnt = 0,
         all_spec_diag_cnt = 0, rpt_spec_diag_cnt = 0
         FOR (i_loop2 = 1 TO diagcnt)
           IF (((row+ 10) > maxrow))
            BREAK
           ENDIF
           row + 1, col 11, temp->ind_screener_qual[screener_num].specimen_qual[i_loop1].diagnosis[
           i_loop2].diagnostic_category_disp"####################################",
           col 53, temp->ind_screener_qual[screener_num].specimen_qual[i_loop1].diagnosis[i_loop2].
           diagnostic_cnt"#####", ind_spec_diag_cnt += temp->ind_screener_qual[screener_num].
           specimen_qual[i_loop1].diagnosis[i_loop2].diagnostic_cnt,
           perc_num_1 = cnvtreal(((cnvtreal(temp->ind_screener_qual[screener_num].specimen_qual[
             i_loop1].diagnosis[i_loop2].diagnostic_cnt)/ cnvtreal(temp->ind_screener_qual[
             screener_num].specimen_qual[i_loop1].tot_diag_cnt)) * 100)), col 63, perc_num_1"###.##"
           IF (no_ngyn_all_cnts="F")
            FOR (a_loop1 = 1 TO size(temp->all_specimen_qual,5))
              IF ((temp->all_specimen_qual[a_loop1].specimen_cd=temp->ind_screener_qual[screener_num]
              .specimen_qual[i_loop1].specimen_cd))
               col 79, temp->all_specimen_qual[a_loop1].diagnosis[i_loop2].diagnostic_cnt"#####",
               all_spec_diag_cnt += temp->all_specimen_qual[a_loop1].diagnosis[i_loop2].
               diagnostic_cnt,
               perc_num_2 = cnvtreal(((cnvtreal(temp->all_specimen_qual[a_loop1].diagnosis[i_loop2].
                 diagnostic_cnt)/ cnvtreal(temp->all_specimen_qual[a_loop1].tot_diag_cnt)) * 100)),
               col 89, perc_num_2"###.##"
              ENDIF
            ENDFOR
           ELSE
            zero_number = cnvtreal(0), col 79, zero_number"######",
            col 89, zero_number"#####.##"
           ENDIF
           IF (no_ngyn_rpt_cnts="F")
            rpt_printed = "N"
            FOR (r_loop1 = 1 TO size(temp->rpt_specimen_qual,5))
              IF ((temp->rpt_specimen_qual[r_loop1].specimen_cd=temp->ind_screener_qual[screener_num]
              .specimen_qual[i_loop1].specimen_cd))
               col 105, temp->rpt_specimen_qual[r_loop1].diagnosis[i_loop2].diagnostic_cnt"########",
               rpt_spec_diag_cnt += temp->rpt_specimen_qual[r_loop1].diagnosis[i_loop2].
               diagnostic_cnt,
               perc_num_3 = cnvtreal(((cnvtreal(temp->rpt_specimen_qual[r_loop1].diagnosis[i_loop2].
                 diagnostic_cnt)/ cnvtreal(temp->rpt_specimen_qual[r_loop1].tot_diag_cnt)) * 100)),
               col 117, perc_num_3"###.##",
               rpt_printed = "Y"
              ENDIF
            ENDFOR
            IF (rpt_printed="N")
             zero_number = cnvtreal(0), col 105, zero_number"########",
             col 117, zero_number"###.##"
            ENDIF
           ELSE
            zero_number = cnvtreal(0), col 79, zero_number"#####",
            col 89, zero_number"#####.##", col 105,
            zero_number"########", col 117, zero_number"###.##"
           ENDIF
         ENDFOR
         row + 1, col 11, captions->total,
         col 53, ind_spec_diag_cnt"#####", col 79,
         all_spec_diag_cnt"#####", col 105, rpt_spec_diag_cnt"########",
         row + 1
       ENDFOR
      ENDIF
     OF 8:
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
      ,row + 1,col 10,line2,
      col 13,
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
      ," ",captions->day_cnt," ",
      FOR (dcnt = 1 TO size(temp->screener_qual[d.seq].section_qual[8].date_qual,5))
        IF (((row+ 10) > maxrow))
         BREAK
        ENDIF
        row + 1, col 11, captions->dt,
        CALL get_text(1,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[1].
        drow_text,"|"), col 17, text"####################",
        row + 1, col 44, captions->cse_no,
        col 65, captions->i_slide, col 86,
        captions->o_slide, col 108, captions->cse_no,
        col 117, captions->slide_no, row + 1,
        col 11, captions->cse, " ",
        captions->typ, col 44, captions->sc_resc,
        col 65, captions->sc_resc, col 86,
        captions->sc_resc, col 108, captions->tot,
        col 117, captions->tot, row + 1,
        col 17, "---------", col 44,
        "-------------------", col 65, "-------------------",
        col 86, "-------------------", col 108,
        "-----", col 117, "-----",
        row + 1, col 17, captions->gyn,
        CALL get_text(1,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[2].
        drow_text,"|"), col 44, real"#####",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        2].drow_text,"|"), col 53, real"#####",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        2].drow_text,"|"), col 64, real"#####.#;i;f",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        2].drow_text,"|"), col 73, real"#####.#;i;f",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        2].drow_text,"|"), col 85, real"#####.#;i;f",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        2].drow_text,"|"), col 94, real"#####.#;i;f",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        2].drow_text,"|"), col 108, real"#####",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        2].drow_text,"|"), col 116, real"#####.#;i;f",
        row + 1, col 17, captions->non_gyn,
        CALL get_text(1,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[3].
        drow_text,"|"), col 44, real"#####",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        3].drow_text,"|"), col 53, real"#####",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        3].drow_text,"|"), col 64, real"#####.#;i;f",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        3].drow_text,"|"), col 73, real"#####.#;i;f",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        3].drow_text,"|"), col 85, real"#####.#;i;f",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        3].drow_text,"|"), col 94, real"#####.#;i;f",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        3].drow_text,"|"), col 108, real"#####",
        CALL get_text(startpos2,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[
        3].drow_text,"|"), col 116, real"#####.#;i;f",
        row + 2
        IF (((row+ 10) > maxrow))
         BREAK, row + 1
        ENDIF
        col 11, captions->tot_scr,
        CALL get_text(1,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[4].
        drow_text,"|"),
        col 60, slides_1 = real, real"#####.#;i;f",
        row + 1, col 11, captions->tot_lim,
        CALL get_text(1,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[5].
        drow_text,"|"), col 60, screen_limit = real,
        real"#####.#;i;f", row + 1, col 11,
        captions->per_lim,
        CALL get_text(1,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[6].
        drow_text,"|"), percent_achieved = ((cnvtreal(slides_1)/ cnvtreal(screen_limit)) * 100),
        col 61, percent_achieved"###.##;i;f", row + 2,
        col 11, captions->no_hrs,
        CALL get_text(1,temp->screener_qual[d.seq].section_qual[8].date_qual[dcnt].drow_qual[7].
        drow_text,"|"),
        col 60, hours_1 = real, real"#####.#;i;f",
        row + 1, col 11, captions->calc_hr,
        col 61, calcul = (cnvtreal(slides_1)/ cnvtreal(hours_1)), calcul"###.##;i;f"
      ENDFOR
    ENDCASE
   ENDFOR
   row + 1,
   CALL center(captions->end_stat,1,130), row + 2
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rpt,
   col + 1, captions->title, wk = format(curdate,"@WEEKDAYABBREV;;d"),
   dy = format(curdate,"@MEDIUMDATE4YR;;D"), today = concat(wk," ",dy), col 53,
   today, col 110, captions->pag,
   col 117, curpage"###", row + 1,
   col 55, captions->cont
  FOOT REPORT
   col 55, "##########  "
  WITH nocounter, maxcol = 132, maxrow = 63,
   compress
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
END GO
