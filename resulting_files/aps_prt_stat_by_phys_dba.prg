CREATE PROGRAM aps_prt_stat_by_phys:dba
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
   1 physician_qual[*]
     2 physician_id = f8
     2 physician_name = vc
     2 phy_gyn_ttl_cnt = i4
     2 phy_ngyn_ttl_cnt = i4
     2 diag_qual[*]
       3 diag_cat_cd = f8
       3 cnt = i4
     2 case_qual[*]
       3 accession_nbr = c21
       3 collected_date = dq8
       3 verified_date = dq8
       3 person_id = f8
       3 encntr_id = f8
       3 patient_name = c25
       3 patient_alias = c20
       3 mnemonic = c25
   1 max_diag_qual = i4
   1 max_case_qual = i4
 )
 RECORD temp_pref(
   1 pref_qual[*]
     2 prefix_cd = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_display = vc
 )
 RECORD temp_diag(
   1 diag_cat[*]
     2 code_value = f8
     2 display = c40
     2 active_ind = i2
     2 diag_cd = f8
     2 ttl_cnt = i4
     2 percentage = i4
     2 gyn_or_ngyn = c4
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
  SET site_code_len = 0
  SET site_str = "     "
  SET site_code = 0.0
  SET raw_prefix_str = fillstring(100," ")
  SET site_prefix_str = fillstring(100," ")
  SET prefix_str = fillstring(100," ")
  SET site_str = fillstring(100," ")
  SET prefix_code = 0.0
  SET raw_req_phys_str = fillstring(100," ")
  SET raw_date_str = fillstring(4," ")
  SET raw_date_num_str = 0
  SET printer = fillstring(100," ")
  SET copies = 0
  CALL initresourcesecurity(1)
  IF (textlen(trim(request->output_dist))=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with output_dist!"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   x = 1
   DETAIL
    CALL get_text(x,trim(request->batch_selection),"|")
    IF (substring(2,1,text)=",")
     text = concat(" ",text)
    ENDIF
    raw_prefix_str = concat(trim(text),","),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_req_phys_str = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_date_str = trim(text), request->
    scuruser = "Operations",
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->blistcases = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    request->bpagebreak = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->bshowstats = trim(text),
    CALL get_text(1,trim(request->output_dist),"|"), printer = trim(text),
    CALL get_text(startpos2,trim(request->output_dist),"|"),
    copies = cnvtint(trim(text))
   WITH nocounter
  ;end select
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
     IF (cnvtint(site_str) > 0)
      SELECT INTO "nl:"
       cv.code_value
       FROM code_value cv
       WHERE 2062=cv.code_set
        AND site_str=cv.display_key
       DETAIL
        site_code = cv.code_value
       WITH nocounter
      ;end select
      IF (curqual=0)
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
      IF (ap.prefix_id != 0.0)
       service_resource_cd = ap.service_resource_cd
       IF (isresourceviewable(service_resource_cd)=true)
        new_size += 1, stat = alterlist(request->prefix_qual,new_size), request->prefix_qual[new_size
        ].prefix_cd = ap.prefix_id
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (((curqual=0) OR (getresourcesecuritystatus(0) != "S")) )
     SET reply->status_data.status = "F"
     SET reply->ops_event = "Failure - Error with prefix setup!"
     GO TO exit_script
    ENDIF
  ENDWHILE
  IF (textlen(trim(raw_req_phys_str)) > 0)
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p
    WHERE raw_req_phys_str=p.username
    DETAIL
     request->req_physician_id = p.person_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with req physician setup!"
    GO TO exit_script
   ENDIF
  ELSE
   SET request->req_physician_id = 0
  ENDIF
  SET raw_date_num_str = cnvtint(substring(1,3,raw_date_str))
  SET request->end_dt_tm = cnvtdatetime(sysdate)
  CASE (substring(4,1,raw_date_str))
   OF "D":
    SET request->beg_dt_tm = cnvtagedatetime(0,0,0,raw_date_num_str)
   OF "M":
    SET request->beg_dt_tm = cnvtagedatetime(0,raw_date_num_str,0,0)
   OF "Y":
    SET request->beg_dt_tm = cnvtagedatetime(raw_date_num_str,0,0,0)
   ELSE
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with date routine setup!"
    GO TO exit_script
  ENDCASE
 ENDIF
 RECORD captions(
   1 rpt = vc
   1 rpt_nm = vc
   1 ana = vc
   1 dt = vc
   1 dir = vc
   1 tm = vc
   1 b_phy = vc
   1 bye = vc
   1 pg = vc
   1 pre = vc
   1 phy = vc
   1 phy = vc
   1 all = vc
   1 dt_rg = vc
   1 none = vc
   1 fo = vc
   1 phy_cse = vc
   1 all_cse = vc
   1 cat = vc
   1 no = vc
   1 per = vc
   1 an = vc
   1 tot = vc
   1 non_cat = vc
   1 cse = vc
   1 nm = vc
   1 id = vc
   1 coll = vc
   1 ver = vc
   1 diag = vc
   1 end_stat = vc
   1 title = vc
   1 cont = vc
 )
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"t1","REPORT:")
 SET captions->rpt_nm = uar_i18ngetmessage(i18nhandle,"t2","APS_PRT_STAT_BY_PHYS.PRG")
 SET captions->ana = uar_i18ngetmessage(i18nhandle,"t3","Anatomic Pathology")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t3a","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t4","DIRECTORY:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t5","TIME:")
 SET captions->b_phy = uar_i18ngetmessage(i18nhandle,"t6","CYTOLOGY STATISTICS BY PHYSICIAN")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t7","BY:")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t8","PAGE:")
 SET captions->pre = uar_i18ngetmessage(i18nhandle,"t9","PREFIX(ES):")
 SET captions->phy = uar_i18ngetmessage(i18nhandle,"t10","PHYSICIAN:")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"t11","ALL")
 SET captions->dt_rg = uar_i18ngetmessage(i18nhandle,"t12","DATE RANGE:")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"t13","No cases meeting specified criteria.")
 SET captions->fo = uar_i18ngetmessage(i18nhandle,"t14","FOR:")
 SET captions->phy_cse = uar_i18ngetmessage(i18nhandle,"t15","PHYSICIAN CASES")
 SET captions->all_cse = uar_i18ngetmessage(i18nhandle,"t16","ALL CASES")
 SET captions->cat = uar_i18ngetmessage(i18nhandle,"t17","GYN CYTOLOGY DIAGNOSTIC CATEGORY")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"t18","#")
 SET captions->per = uar_i18ngetmessage(i18nhandle,"t19","%")
 SET captions->an = uar_i18ngetmessage(i18nhandle,"t20","AND")
 SET captions->tot = uar_i18ngetmessage(i18nhandle,"t21","--TOTAL--")
 SET captions->non_cat = uar_i18ngetmessage(i18nhandle,"t22","NON-GYN CYTOLOGY DIAGNOSTIC CATEGORY")
 SET captions->cse = uar_i18ngetmessage(i18nhandle,"t23","CASE")
 SET captions->nm = uar_i18ngetmessage(i18nhandle,"t24","NAME")
 SET captions->id = uar_i18ngetmessage(i18nhandle,"t25","ID")
 SET captions->coll = uar_i18ngetmessage(i18nhandle,"t26","COLLECTED")
 SET captions->ver = uar_i18ngetmessage(i18nhandle,"t27","VERIFIED")
 SET captions->diag = uar_i18ngetmessage(i18nhandle,"t28","DIAGNOSIS")
 SET captions->end_stat = uar_i18ngetmessage(i18nhandle,"t29","END OF PHYSICIAN'S STATISTICS")
 SET captions->title = uar_i18ngetmessage(i18nhandle,"t30","REPORT: CYTOLOGY STATISTICS BY PHYSICIAN"
  )
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"t31","CONTINUED...")
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
 SET no_phys = 0
 SET gyn_ttl_cnt = 0.0
 SET ngyn_ttl_cnt = 0.0
 SET gyn_case_type_cd = 0.0
 SET ngyn_case_type_cd = 0.0
 SET code_value = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1301
   AND cv.cdf_meaning IN ("GYN", "NGYN")
  DETAIL
   IF (cv.cdf_meaning="GYN")
    gyn_case_type_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="NGYN")
    ngyn_case_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->req_physician_id=0))
  SET phys_where = "0 = 0"
 ELSE
  SET phys_where = "pc.requesting_physician_id = request->req_physician_id+0"
 ENDIF
 SET ngyn_case_type_found = "N"
 SET gyn_case_type_found = "N"
 SELECT INTO "nl:"
  cv_display = cv.display"#####", site_prefix = build(substring(1,5,cv.display),ap.prefix_name), ap
  .prefix_name,
  ap.prefix_id, ap.site_cd
  FROM ap_prefix ap,
   code_value cv,
   (dummyt d  WITH seq = value(size(request->prefix_qual,5)))
  PLAN (d)
   JOIN (ap
   WHERE (request->prefix_qual[d.seq].prefix_cd=ap.prefix_id)
    AND ap.case_type_cd IN (gyn_case_type_cd, ngyn_case_type_cd))
   JOIN (cv
   WHERE ap.site_cd=cv.code_value)
  ORDER BY site_prefix
  HEAD REPORT
   stat = alterlist(temp_pref->pref_qual,value(size(request->prefix_qual,5))), pref_cntr = 0
  HEAD site_prefix
   pref_cntr += 1, temp_pref->pref_qual[pref_cntr].prefix_cd = ap.prefix_id, temp_pref->pref_qual[
   pref_cntr].prefix_name = ap.prefix_name,
   temp_pref->pref_qual[pref_cntr].site_cd = ap.site_cd, temp_pref->pref_qual[pref_cntr].site_display
    = cv.display
   IF (ap.case_type_cd=gyn_case_type_cd)
    gyn_case_type_found = "Y"
   ENDIF
   IF (ap.case_type_cd=ngyn_case_type_cd)
    ngyn_case_type_found = "Y"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_set, cv.cdf_meaning, cv.display,
  cv.collation_seq
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1314
    AND cv.cdf_meaning IN ("GYN", "NGYN"))
  ORDER BY cv.cdf_meaning, cv.collation_seq
  HEAD REPORT
   cat_cnt = 0
  DETAIL
   cat_cnt += 1, stat = alterlist(temp_diag->diag_cat,cat_cnt), temp_diag->diag_cat[cat_cnt].display
    = cv.display,
   temp_diag->diag_cat[cat_cnt].code_value = cv.code_value, temp_diag->diag_cat[cat_cnt].gyn_or_ngyn
    = cv.cdf_meaning, temp_diag->diag_cat[cat_cnt].active_ind = cv.active_ind
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pc.requesting_physician_id, cse.diagnostic_category_cd
  FROM (dummyt d  WITH seq = value(size(request->prefix_qual,5))),
   pathology_case pc,
   cyto_screening_event cse
  PLAN (d)
   JOIN (pc
   WHERE (request->prefix_qual[d.seq].prefix_cd=(pc.prefix_id+ 0))
    AND pc.case_collect_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm))
   JOIN (cse
   WHERE pc.case_id=cse.case_id
    AND 1=cse.verify_ind)
  ORDER BY cse.diagnostic_category_cd
  HEAD REPORT
   row + 0
  HEAD cse.diagnostic_category_cd
   FOR (x = 1 TO value(size(temp_diag->diag_cat,5)))
     IF ((cse.diagnostic_category_cd=temp_diag->diag_cat[x].code_value))
      curr_cd_num = x, x = value(size(temp_diag->diag_cat,5))
     ENDIF
   ENDFOR
  DETAIL
   temp_diag->diag_cat[curr_cd_num].ttl_cnt += 1
   IF (pc.case_type_cd=gyn_case_type_cd)
    gyn_ttl_cnt += 1
   ENDIF
   IF (pc.case_type_cd=ngyn_case_type_cd)
    ngyn_ttl_cnt += 1
   ENDIF
  FOOT REPORT
   FOR (x = 1 TO value(size(temp_diag->diag_cat,5)))
    IF ((temp_diag->diag_cat[x].gyn_or_ngyn="GYN"))
     temp_diag->diag_cat[x].percentage = round(((cnvtreal(temp_diag->diag_cat[x].ttl_cnt)/ cnvtreal(
       gyn_ttl_cnt)) * 100),0)
    ENDIF
    ,
    IF ((temp_diag->diag_cat[x].gyn_or_ngyn="NGYN"))
     temp_diag->diag_cat[x].percentage = round(((cnvtreal(temp_diag->diag_cat[x].ttl_cnt)/ cnvtreal(
       ngyn_ttl_cnt)) * 100),0)
    ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO report_section
 ENDIF
 SET code_value = 0.0
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SELECT INTO "nl:"
  pc.requesting_physician_id, cse.diagnostic_category_cd, pc.accession_nbr
  FROM (dummyt d  WITH seq = value(size(request->prefix_qual,5))),
   pathology_case pc,
   cyto_screening_event cse,
   person p,
   nomenclature n
  PLAN (d)
   JOIN (pc
   WHERE (request->prefix_qual[d.seq].prefix_cd=(pc.prefix_id+ 0))
    AND parser(phys_where)
    AND pc.case_collect_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm))
   JOIN (cse
   WHERE pc.case_id=cse.case_id
    AND 1=cse.verify_ind)
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (n
   WHERE cse.nomenclature_id=n.nomenclature_id)
  ORDER BY pc.requesting_physician_id, cse.diagnostic_category_cd
  HEAD REPORT
   row + 0, phys_cnt = 0, case_cnt = 0,
   diag_cnt = 0
  HEAD pc.requesting_physician_id
   phys_cnt += 1, case_cnt = 0, case_per_phy = 0,
   stat = alterlist(temp->physician_qual,phys_cnt), temp->physician_qual[phys_cnt].physician_id = pc
   .requesting_physician_id, diag_cnt = 0
  HEAD cse.diagnostic_category_cd
   diag_cnt += 1, stat = alterlist(temp->physician_qual[phys_cnt].diag_qual,diag_cnt), temp->
   physician_qual[phys_cnt].diag_qual[diag_cnt].diag_cat_cd = cse.diagnostic_category_cd,
   case_cnt = 0
  DETAIL
   case_cnt += 1, case_per_phy += 1
   IF ((case_cnt > temp->max_diag_qual))
    temp->max_diag_qual = case_cnt
   ENDIF
   temp->physician_qual[phys_cnt].diag_qual[diag_cnt].cnt = case_cnt
   IF (pc.case_type_cd=gyn_case_type_cd)
    temp->physician_qual[phys_cnt].phy_gyn_ttl_cnt += 1
   ENDIF
   IF (pc.case_type_cd=ngyn_case_type_cd)
    temp->physician_qual[phys_cnt].phy_ngyn_ttl_cnt += 1
   ENDIF
   stat = alterlist(temp->physician_qual[phys_cnt].case_qual,case_per_phy)
   IF ((case_per_phy > temp->max_case_qual))
    temp->max_case_qual = case_per_phy
   ENDIF
   temp->physician_qual[phys_cnt].case_qual[case_per_phy].accession_nbr = pc.accession_nbr, temp->
   physician_qual[phys_cnt].case_qual[case_per_phy].patient_name = p.name_full_formatted, temp->
   physician_qual[phys_cnt].case_qual[case_per_phy].collected_date = pc.case_collect_dt_tm,
   temp->physician_qual[phys_cnt].case_qual[case_per_phy].verified_date = pc
   .main_report_cmplete_dt_tm, temp->physician_qual[phys_cnt].case_qual[case_per_phy].person_id = pc
   .person_id, temp->physician_qual[phys_cnt].case_qual[case_per_phy].encntr_id = pc.encntr_id,
   temp->physician_qual[phys_cnt].case_qual[case_per_phy].mnemonic = n.mnemonic
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ea.alias, frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), temp->physician_qual[d.seq].case_qual[d2
  .seq].encntr_id
  FROM (dummyt d  WITH seq = value(size(temp->physician_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_case_qual)),
   (dummyt d3  WITH seq = 1),
   encntr_alias ea
  PLAN (d)
   JOIN (d2
   WHERE d2.seq <= size(temp->physician_qual[d.seq].case_qual,5))
   JOIN (d3)
   JOIN (ea
   WHERE (temp->physician_qual[d.seq].case_qual[d2.seq].encntr_id=ea.encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   IF ((temp->physician_qual[d.seq].case_qual[d2.seq].encntr_id=ea.encntr_id))
    temp->physician_qual[d.seq].case_qual[d2.seq].patient_alias = frmt_mrn
   ELSE
    temp->physician_qual[d.seq].case_qual[d2.seq].patient_alias = "Unknown"
   ENDIF
  WITH nocounter, outerjoin = d3
 ;end select
 IF (value(size(temp->physician_qual,5)) > 0)
  SELECT INTO "nl:"
   pr.name_full_formatted
   FROM prsnl pr,
    (dummyt d  WITH seq = value(size(temp->physician_qual,5)))
   PLAN (d)
    JOIN (pr
    WHERE (temp->physician_qual[d.seq].physician_id=pr.person_id))
   DETAIL
    temp->physician_qual[d.seq].physician_name = pr.name_full_formatted
   WITH nocounter
  ;end select
 ELSE
  SET no_phys = 1
  SELECT INTO "nl:"
   pr.name_full_formatted
   FROM prsnl pr
   WHERE (request->req_physician_id=pr.person_id)
   DETAIL
    phys_cnt = 1, stat = alterlist(temp->physician_qual,1), temp->physician_qual[phys_cnt].
    physician_name = pr.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
#report_section
 SET phys_cnt = 0
 SET num_of_phys = value(size(temp->physician_qual,5))
 EXECUTE cpm_create_file_name_logical "aps_stat_by_phys", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  concat_name_id = build(temp->physician_qual[d.seq].physician_name,temp->physician_qual[d.seq].
   physician_id), accession_nbr = temp->physician_qual[d.seq].case_qual[d2.seq].accession_nbr
  FROM (dummyt d  WITH seq = value(size(temp->physician_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_case_qual))
  PLAN (d)
   JOIN (d2
   WHERE d2.seq <= size(temp->physician_qual[d.seq].case_qual,5))
  ORDER BY concat_name_id, accession_nbr
  HEAD REPORT
   dotted_line1 = fillstring(130,"-"), dotted_line2 = fillstring(127,"-"), ttl_phys_perc = 0.0,
   ttl_gyn_all_perc = 0.0, ttl_ngyn_all_perc = 0.0, ttl_indiv_gyn_phys_perc = 0.0,
   ttl_indiv_ngyn_phys_perc = 0.0
  HEAD PAGE
   row + 1, col 0, captions->rpt,
   col 8, captions->rpt_nm,
   CALL center(captions->ana,0,132),
   col 110, captions->dt, col 117,
   curdate"@SHORTDATE;;D", row + 1, col 0,
   captions->dir, col 110, captions->tm,
   col 117, curtime"@TIMENOSECONDS;;M", row + 1,
   col 52,
   CALL center(captions->b_phy,0,132), col 112,
   captions->bye, col 117, request->scuruser"##############",
   row + 1, col 110, captions->pg,
   col 117, curpage"###", row + 1,
   col 0, captions->pre, col 15,
   last_pref = value(size(temp_pref->pref_qual,5))
   FOR (x = 1 TO last_pref)
     temp_pref->pref_qual[x].site_display, temp_pref->pref_qual[x].prefix_name
     IF (x < last_pref)
      ", "
     ENDIF
     col + 1
     IF (col > 120)
      row + 1, col 15
     ENDIF
   ENDFOR
   row + 1, captions->phy
   IF ((request->req_physician_id=0))
    col 15, captions->all
   ELSE
    col 15, temp->physician_qual[d.seq].physician_name
   ENDIF
   row + 1, col 0, captions->dt_rg,
   col 15, request->beg_dt_tm"@SHORTDATE;;D", col 26,
   "-", col 28, request->end_dt_tm"@SHORTDATE;;D"
   IF (((num_of_phys=0) OR (no_phys=1)) )
    row + 7,
    CALL center(captions->none,0,132)
   ENDIF
  HEAD concat_name_id
   IF (((row+ 7) > maxrow))
    BREAK
   ENDIF
   row + 1, dotted_line1, row + 1,
   captions->fo, col 15, temp->physician_qual[d.seq].physician_name,
   row + 1, phys_cnt += 1, row + 0
   IF ((request->bshowstats="T"))
    IF (gyn_case_type_found="Y")
     col 53, captions->phy_cse, col 81,
     captions->all_cse, row + 1, col 5,
     captions->cat, col 56, captions->no,
     col 60, captions->an, col 67,
     captions->per, col 80, captions->no,
     col 84, captions->an, col 91,
     captions->per, row + 1, col 5,
     "--------------------------------", col 53, "-------",
     col 65, "-----", col 77,
     "-------", col 90, "---"
     FOR (cat_cnt = 1 TO value(size(temp_diag->diag_cat,5)))
       IF ((temp_diag->diag_cat[cat_cnt].gyn_or_ngyn="GYN"))
        IF ((((temp_diag->diag_cat[cat_cnt].active_ind=1)) OR ((temp_diag->diag_cat[cat_cnt].
        active_ind=0)
         AND (temp_diag->diag_cat[cat_cnt].ttl_cnt > 0))) )
         row + 1, col 5, temp_diag->diag_cat[cat_cnt].display,
         col 59, "0", col 68,
         "0", col 83, "0",
         col 92, "0"
         FOR (y = 1 TO size(temp->physician_qual[d.seq].diag_qual,5))
           IF ((temp_diag->diag_cat[cat_cnt].code_value=temp->physician_qual[d.seq].diag_qual[y].
           diag_cat_cd))
            col 53, temp->physician_qual[d.seq].diag_qual[y].cnt"#######", ttl_phys_perc = ((cnvtreal
            (temp->physician_qual[d.seq].diag_qual[y].cnt)/ cnvtreal(temp->physician_qual[d.seq].
             phy_gyn_ttl_cnt)) * 100),
            col 66, ttl_phys_perc"###.#;i;f", ttl_indiv_gyn_phys_perc += ttl_phys_perc
           ENDIF
           col 77, temp_diag->diag_cat[cat_cnt].ttl_cnt"#######", gyn_all_perc = 0.0,
           gyn_all_perc = ((cnvtreal(temp_diag->diag_cat[cat_cnt].ttl_cnt)/ cnvtreal(gyn_ttl_cnt)) *
           100), col 90, gyn_all_perc"###.#;i;f"
         ENDFOR
         ttl_gyn_all_perc += gyn_all_perc, gyn_all_perc = 0.0
         IF (((row+ 10) > maxrow))
          BREAK
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     row + 1, col 5, captions->tot,
     col 53, temp->physician_qual[d.seq].phy_gyn_ttl_cnt"#######", col 66,
     ttl_indiv_gyn_phys_perc"###.#;i;f", col 77, gyn_ttl_cnt"#######",
     col 90, ttl_gyn_all_perc"###.#;i;f", ttl_phys_cnt = 0,
     row + 2
    ENDIF
   ENDIF
   IF ((request->bshowstats="T"))
    IF (ngyn_case_type_found="Y")
     col 53, captions->phy_cse, col 81,
     captions->all_cse, row + 1, col 5,
     captions->non_cat, col 56, captions->no,
     col 60, captions->an, col 67,
     captions->per, col 80, captions->no,
     col 84, captions->an, col 91,
     captions->per, row + 1, col 5,
     "------------------------------------", col 53, "-------",
     col 65, "-----", col 77,
     "-------", col 90, "---"
     FOR (cat_cnt = 1 TO value(size(temp_diag->diag_cat,5)))
       IF ((temp_diag->diag_cat[cat_cnt].gyn_or_ngyn="NGYN"))
        IF ((((temp_diag->diag_cat[cat_cnt].active_ind=1)) OR ((temp_diag->diag_cat[cat_cnt].
        active_ind=0)
         AND (temp_diag->diag_cat[cat_cnt].ttl_cnt > 0))) )
         row + 1, col 5, temp_diag->diag_cat[cat_cnt].display,
         col 59, "0", col 68,
         "0", col 83, "0",
         col 92, "0"
         FOR (y = 1 TO size(temp->physician_qual[d.seq].diag_qual,5))
           IF ((temp_diag->diag_cat[cat_cnt].code_value=temp->physician_qual[d.seq].diag_qual[y].
           diag_cat_cd))
            col 53, temp->physician_qual[d.seq].diag_qual[y].cnt"#######", ttl_phys_perc = ((cnvtreal
            (temp->physician_qual[d.seq].diag_qual[y].cnt)/ cnvtreal(temp->physician_qual[d.seq].
             phy_ngyn_ttl_cnt)) * 100),
            col 66, ttl_phys_perc"###.#;i;f", ttl_indiv_ngyn_phys_perc += ttl_phys_perc
           ENDIF
           col 77, temp_diag->diag_cat[cat_cnt].ttl_cnt"#######", ngyn_all_perc = 0.0,
           ngyn_all_perc = ((cnvtreal(temp_diag->diag_cat[cat_cnt].ttl_cnt)/ cnvtreal(ngyn_ttl_cnt))
            * 100), col 90, ngyn_all_perc"###.#;i;f"
         ENDFOR
         ttl_ngyn_all_perc += ngyn_all_perc, ngyn_all_perc = 0.0
         IF (((row+ 10) > maxrow))
          BREAK
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     row + 1, col 5, captions->tot,
     col 53, temp->physician_qual[d.seq].phy_ngyn_ttl_cnt"#######", col 66,
     ttl_indiv_ngyn_phys_perc"###.#;i;f", col 77, ngyn_ttl_cnt"#######",
     col 90, ttl_ngyn_all_perc"###.#;i;f", row + 1
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
   ENDIF
   IF ((request->blistcases="T"))
    row + 1, col 5, captions->cse,
    col 26, captions->nm, col 53,
    captions->id, col 75, captions->coll,
    col 86, captions->ver, col 96,
    captions->diag, row + 1, col 5,
    "-------------------", col 26, "-------------------------",
    col 53, "--------------------", col 75,
    "---------", col 86, "--------",
    col 96, "----------------------------"
   ENDIF
  DETAIL
   IF ((request->blistcases="T"))
    print_accession = uar_fmt_accession(temp->physician_qual[d.seq].case_qual[d2.seq].accession_nbr,
     size(trim(temp->physician_qual[d.seq].case_qual[d2.seq].accession_nbr),1)), row + 1, col 5,
    print_accession, col 26, temp->physician_qual[d.seq].case_qual[d2.seq].patient_name
    "#########################",
    col 53, temp->physician_qual[d.seq].case_qual[d2.seq].patient_alias"####################", col 75,
    temp->physician_qual[d.seq].case_qual[d2.seq].collected_date"@SHORTDATE;;D", col 86, temp->
    physician_qual[d.seq].case_qual[d2.seq].verified_date"@SHORTDATE;;D",
    col 96, temp->physician_qual[d.seq].case_qual[d2.seq].mnemonic"#########################"
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
   ENDIF
  FOOT  concat_name_id
   row + 1, row + 1,
   CALL center(captions->end_stat,0,132),
   row + 1, ttl_gyn_all_perc = 0.0, ttl_ngyn_all_perc = 0.0,
   ttl_indiv_gyn_phys_perc = 0.0, ttl_indiv_ngyn_phys_perc = 0.0
   IF ((request->bpagebreak="T"))
    IF (num_of_phys > 0
     AND phys_cnt < num_of_phys)
     BREAK
    ENDIF
   ENDIF
  FOOT PAGE
   wk = format(curdate,"@WEEKDAYABBREV;;D"), day = format(curdate,"@MEDIUMDATE4YR;;D"), today =
   concat(wk," ",day),
   row 60, col 0, dotted_line1,
   row + 1, col 0, captions->title,
   col 53, today, col 110,
   captions->pg, col 117, curpage"###",
   row + 1, col 55, captions->cont
  FOOT REPORT
   col 55, "##########  "
  WITH nocounter, nullreport, maxcol = 132,
   maxrow = 63, compress
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  IF (textlen(trim(request->output_dist)) > 0)
   SET spool value(reply->print_status_data.print_dir_and_filename) value(printer) WITH copy = value(
    copies)
   SET reply->ops_event = concat("Successful ",trim(reply->print_status_data.print_dir_and_filename))
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
