CREATE PROGRAM aps_prt_cyto_reports_ver:dba
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
   1 ccase = vc
   1 name = vc
   1 id = vc
   1 ver = vc
   1 diagnosis = vc
   1 rreport = vc
   1 aps_prt = vc
   1 ap = vc
   1 ddate = vc
   1 dir = vc
   1 ttime = vc
   1 crvs = vc
   1 bby = vc
   1 ppage = vc
   1 prefix = vc
   1 incl = vc
   1 verpath = vc
   1 vernotpath = vc
   1 noqual = vc
   1 rptcrvs = vc
   1 contd = vc
   1 dtrange = vc
 )
 SET captions->ccase = uar_i18ngetmessage(i18nhandle,"ccase","CASE")
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","NAME")
 SET captions->id = uar_i18ngetmessage(i18nhandle,"id","ID")
 SET captions->ver = uar_i18ngetmessage(i18nhandle,"verby","VERIFIED")
 SET captions->diagnosis = uar_i18ngetmessage(i18nhandle,"diagnosis","DIAGNOSIS")
 SET captions->rreport = uar_i18ngetmessage(i18nhandle,"rreport","REPORT")
 SET captions->aps_prt = uar_i18ngetmessage(i18nhandle,"aps_prt","APS_PRT_CYTO_REPORTS_VER.PRG")
 SET captions->ap = uar_i18ngetmessage(i18nhandle,"ap","Anatomic Pathology")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"date","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"time","TIME")
 SET captions->crvs = uar_i18ngetmessage(i18nhandle,"crvs","CYTOLOGY REPORT VERIFICATION SUMMARY")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"prefix","PREFIX(ES)")
 SET captions->incl = uar_i18ngetmessage(i18nhandle,"incl","INCLUDES")
 SET captions->verpath = uar_i18ngetmessage(i18nhandle,"verpath","CASES VERIFIED BY A PATHOLOGIST")
 SET captions->vernotpath = uar_i18ngetmessage(i18nhandle,"vernotpath",
  "CASES VERIFIED BY A USER OTHER THAN A PATHOLOGIST")
 SET captions->noqual = uar_i18ngetmessage(i18nhandle,"noqual","NO CASES QUALIFY")
 SET captions->rptcrvs = uar_i18ngetmessage(i18nhandle,"rptcrvs",
  "REPORT: CYTOLOGY REPORT VERIFICATION SUMMARY")
 SET captions->contd = uar_i18ngetmessage(i18nhandle,"contd","CONTINUED...")
 SET captions->dtrange = uar_i18ngetmessage(i18nhandle,"dtrange","DATE RANGE")
 RECORD temp(
   1 case_qual[10]
     2 accession_nbr = c21
     2 person_id = f8
     2 encntr_id = f8
     2 patient_name = c25
     2 patient_alias = c20
     2 verified_date = dq8
     2 ver_id = f8
     2 ver_name = c18
     2 path_ind = c1
     2 diagnosis_alpha = c25
 )
 RECORD temp_pref(
   1 pref_qual[1]
     2 prefix_cd = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_display = vc
     2 site_prefix = vc
 )
 RECORD temp_qa_flag(
   1 list[*]
     2 qa_flag_type_cd = f8
     2 reference_range_factor_id = f8
     2 nomenclature_id = f8
     2 service_resource_cd = f8
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
 DECLARE nfilterbyqaflagtypeind = i2 WITH protect, noconstant(0)
 DECLARE naddcaseind = i2 WITH protect, noconstant(0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE lcur = i4 WITH protect, noconstant(0)
 DECLARE llocatevalidx = i4 WITH protect, noconstant(0)
 DECLARE lqaflagtypelistcnt = i4 WITH protect, noconstant(0)
 DECLARE dcytoqaflagabnormalcd = f8 WITH protect, noconstant(0.0)
 DECLARE dcytoqaflagatypicalcd = f8 WITH protect, noconstant(0.0)
 DECLARE dcytoqaflagnormalcd = f8 WITH protect, noconstant(0.0)
 DECLARE dcytoqaflagunsatcd = f8 WITH protect, noconstant(0.0)
 DECLARE dservressubsectiontypecd = f8 WITH protect, noconstant(0.0)
 DECLARE suarerror = vc WITH protect, noconstant("")
 DECLARE script_name = c24 WITH constant("aps_prt_cyto_reports_ver")
 DECLARE cyto_qa_flags_cs = i4 WITH protect, constant(1316)
 DECLARE const_cyto_qa_flag_abnormal_cdf = c12 WITH protect, constant("ABNORMAL")
 DECLARE const_cyto_qa_flag_atypical_cdf = c12 WITH protect, constant("ATYPICAL")
 DECLARE const_cyto_qa_flag_normal_cdf = c12 WITH protect, constant("NORMAL")
 DECLARE const_cyto_qa_flag_unsat_cdf = c12 WITH protect, constant("UNSAT")
 DECLARE const_serv_res_type_cs = i4 WITH protect, constant(223)
 DECLARE const_serv_res_subsection_cdf = c12 WITH protect, constant("SUBSECTION")
 DECLARE temp_accession = c21 WITH protect, noconstant("")
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
  SET headerx = fillstring(200," ")
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
    CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_date_str = trim(text),
    request->scuruser = "Operations",
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->satypical = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->sabnormal = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    request->snormal = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->sunsat = trim(text),
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
     SET site_str = substring(1,(site_code_len+ 1),trim(site_prefix_str))
     SET prefix_str = substring(((1+ site_code_len)+ 2),len,trim(site_prefix_str))
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
 SET path_found = "N"
 SET other_found = "N"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cv_display = cv.display"#####", site_prefix = build(substring(1,5,cv.display),ap.prefix_name), ap
  .prefix_name,
  ap.prefix_id, ap.site_cd
  FROM ap_prefix ap,
   code_value cv,
   (dummyt d  WITH seq = value(size(request->prefix_qual,5)))
  PLAN (d)
   JOIN (ap
   WHERE (request->prefix_qual[d.seq].prefix_cd=ap.prefix_id))
   JOIN (cv
   WHERE ap.site_cd=cv.code_value)
  ORDER BY site_prefix
  HEAD REPORT
   stat = alter(temp_pref->pref_qual,value(size(request->prefix_qual,5))), pref_cntr = 0
  HEAD site_prefix
   pref_cntr += 1, temp_pref->pref_qual[pref_cntr].prefix_cd = ap.prefix_id, temp_pref->pref_qual[
   pref_cntr].prefix_name = ap.prefix_name,
   temp_pref->pref_qual[pref_cntr].site_cd = ap.site_cd, temp_pref->pref_qual[pref_cntr].site_display
    = cv.display
  WITH nocounter
 ;end select
 SET code_value = 0.0
 SET pathologist_code = 0.0
 SET code_set = 0357
 SET cdf_meaning = "PATHOLOGIST"
 EXECUTE cpm_get_cd_for_cdf
 SET pathologist_code = code_value
 IF ((request->sabnormal="T")
  AND (request->satypical="T")
  AND (request->snormal="T")
  AND (request->sunsat="T"))
  SET nfilterbyqaflagtypeind = 0
 ELSEIF ((((request->sabnormal="T")) OR ((((request->satypical="T")) OR ((((request->snormal="T"))
  OR ((request->sunsat="T"))) )) ))
  AND size(temp->case_qual,5) > 0)
  SET nfilterbyqaflagtypeind = 1
 ENDIF
 IF (nfilterbyqaflagtypeind=1)
  IF ((request->sabnormal="T"))
   SET lstat = uar_get_meaning_by_codeset(cyto_qa_flags_cs,const_cyto_qa_flag_abnormal_cdf,1,
    dcytoqaflagabnormalcd)
   IF (dcytoqaflagabnormalcd <= 0.0)
    SET suarerror = concat("Failed to retrieve QA flag type code with meaning of ",trim(
      const_cyto_qa_flag_abnormal_cdf),".")
    CALL errorhandler("F","uar_get_meaning_by_codeset",suarerror)
   ENDIF
  ENDIF
  IF ((request->satypical="T"))
   SET lstat = uar_get_meaning_by_codeset(cyto_qa_flags_cs,const_cyto_qa_flag_atypical_cdf,1,
    dcytoqaflagatypicalcd)
   IF (dcytoqaflagatypicalcd <= 0.0)
    SET suarerror = concat("Failed to retrieve QA flag type code with meaning of ",trim(
      const_cyto_qa_flag_atypical_cdf),".")
    CALL errorhandler("F","uar_get_meaning_by_codeset",suarerror)
   ENDIF
  ENDIF
  IF ((request->snormal="T"))
   SET lstat = uar_get_meaning_by_codeset(cyto_qa_flags_cs,const_cyto_qa_flag_normal_cdf,1,
    dcytoqaflagnormalcd)
   IF (dcytoqaflagnormalcd <= 0.0)
    SET suarerror = concat("Failed to retrieve QA flag type code with meaning of ",trim(
      const_cyto_qa_flag_normal_cdf),".")
    CALL errorhandler("F","uar_get_meaning_by_codeset",suarerror)
   ENDIF
  ENDIF
  IF ((request->sunsat="T"))
   SET lstat = uar_get_meaning_by_codeset(cyto_qa_flags_cs,const_cyto_qa_flag_unsat_cdf,1,
    dcytoqaflagunsatcd)
   IF (dcytoqaflagunsatcd <= 0.0)
    SET suarerror = concat("Failed to retrieve QA flag type code with meaning of ",trim(
      const_cyto_qa_flag_unsat_cdf),".")
    CALL errorhandler("F","uar_get_meaning_by_codeset",suarerror)
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   cas.service_resource_cd
   FROM cyto_alpha_security cas
   WHERE cas.definition_ind IN (0, 1)
   HEAD REPORT
    lqaflagtypelistcnt = 0
   DETAIL
    lqaflagtypelistcnt += 1
    IF (lqaflagtypelistcnt > size(temp_qa_flag->list,5))
     lstat = alterlist(temp_qa_flag->list,(lqaflagtypelistcnt+ 10))
    ENDIF
    temp_qa_flag->list[lqaflagtypelistcnt].qa_flag_type_cd = cas.qa_flag_type_cd, temp_qa_flag->list[
    lqaflagtypelistcnt].reference_range_factor_id = cas.reference_range_factor_id, temp_qa_flag->
    list[lqaflagtypelistcnt].nomenclature_id = cas.nomenclature_id,
    temp_qa_flag->list[lqaflagtypelistcnt].service_resource_cd = cas.service_resource_cd
   FOOT REPORT
    lstat = alterlist(temp_qa_flag->list,lqaflagtypelistcnt)
   WITH nocounter
  ;end select
 ENDIF
 SET lstat = uar_get_meaning_by_codeset(const_serv_res_type_cs,const_serv_res_subsection_cdf,1,
  dservressubsectiontypecd)
 IF (dservressubsectiontypecd <= 0.0)
  SET suarerror = concat("Failed to retrieve service resource type code with meaning of ",trim(
    const_serv_res_subsection_cdf),".")
  CALL errorhandler("F","uar_get_meaning_by_codeset",suarerror)
 ENDIF
 SELECT INTO "nl:"
  n.mnemonic, cas.qa_flag_type_cd, cse.reference_range_factor_id,
  cse.screener_id, cse.nomenclature_id, pc.case_id,
  pc.requesting_physician_id, pc.prefix_id, pc.case_collect_dt_tm,
  pc.accession_nbr
  FROM (dummyt d  WITH seq = value(size(request->prefix_qual,5))),
   pathology_case pc,
   cyto_screening_event cse,
   nomenclature n,
   resource_group rg
  PLAN (d)
   JOIN (pc
   WHERE (request->prefix_qual[d.seq].prefix_cd=(pc.prefix_id+ 0))
    AND pc.main_report_cmplete_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(
    request->end_dt_tm))
   JOIN (cse
   WHERE pc.case_id=cse.case_id
    AND 1=cse.verify_ind
    AND 1=cse.active_ind)
   JOIN (n
   WHERE cse.nomenclature_id=n.nomenclature_id)
   JOIN (rg
   WHERE (rg.child_service_resource_cd= Outerjoin(cse.service_resource_cd))
    AND (rg.root_service_resource_cd= Outerjoin(0.0))
    AND ((rg.resource_group_type_cd+ 0)= Outerjoin(dservressubsectiontypecd))
    AND ((rg.active_ind+ 0)= Outerjoin(1))
    AND (rg.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
    AND (rg.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY pc.accession_nbr
  HEAD REPORT
   case_cnt = 0
  DETAIL
   IF (nfilterbyqaflagtypeind=1)
    naddcaseind = 0, lcur = 0
    IF (lqaflagtypelistcnt > 0)
     IF (cse.service_resource_cd > 0.0)
      lcur = locateval(llocatevalidx,1,lqaflagtypelistcnt,cse.reference_range_factor_id,temp_qa_flag
       ->list[llocatevalidx].reference_range_factor_id,
       cse.nomenclature_id,temp_qa_flag->list[llocatevalidx].nomenclature_id,cse.service_resource_cd,
       temp_qa_flag->list[llocatevalidx].service_resource_cd)
      IF (lcur=0)
       IF (rg.parent_service_resource_cd > 0.0)
        lcur = locateval(llocatevalidx,1,lqaflagtypelistcnt,cse.reference_range_factor_id,
         temp_qa_flag->list[llocatevalidx].reference_range_factor_id,
         cse.nomenclature_id,temp_qa_flag->list[llocatevalidx].nomenclature_id,rg
         .parent_service_resource_cd,temp_qa_flag->list[llocatevalidx].service_resource_cd)
       ENDIF
      ENDIF
     ENDIF
     IF (lcur=0)
      lcur = locateval(llocatevalidx,1,lqaflagtypelistcnt,cse.reference_range_factor_id,temp_qa_flag
       ->list[llocatevalidx].reference_range_factor_id,
       cse.nomenclature_id,temp_qa_flag->list[llocatevalidx].nomenclature_id,0.0,temp_qa_flag->list[
       llocatevalidx].service_resource_cd)
     ENDIF
     IF (lcur > 0)
      IF ((temp_qa_flag->list[lcur].qa_flag_type_cd IN (dcytoqaflagabnormalcd, dcytoqaflagatypicalcd,
      dcytoqaflagnormalcd, dcytoqaflagunsatcd)))
       naddcaseind = 1
      ENDIF
     ELSE
      naddcaseind = 1
     ENDIF
    ENDIF
   ELSE
    naddcaseind = 1
   ENDIF
   IF (naddcaseind=1)
    IF (temp_accession != pc.accession_nbr)
     case_cnt += 1
     IF (mod(case_cnt,10)=1
      AND case_cnt != 1)
      stat = alter(temp->case_qual,(case_cnt+ 10))
     ENDIF
     temp->case_qual[case_cnt].accession_nbr = pc.accession_nbr, temp->case_qual[case_cnt].person_id
      = pc.person_id, temp->case_qual[case_cnt].encntr_id = pc.encntr_id,
     temp->case_qual[case_cnt].verified_date = pc.main_report_cmplete_dt_tm, temp->case_qual[case_cnt
     ].ver_id = cse.screener_id, temp->case_qual[case_cnt].path_ind = "O",
     temp->case_qual[case_cnt].diagnosis_alpha = n.mnemonic, temp_accession = pc.accession_nbr
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alter(temp->case_qual,case_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET stat = alter(temp->case_qual,0)
 ENDIF
 SET code_value = 0.0
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d  WITH seq = value(size(temp->case_qual,5))),
   person p
  PLAN (d)
   JOIN (p
   WHERE (temp->case_qual[d.seq].person_id=p.person_id))
  DETAIL
   temp->case_qual[d.seq].patient_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM (dummyt d  WITH seq = value(size(temp->case_qual,5))),
   (dummyt d1  WITH seq = 1),
   encntr_alias ea
  PLAN (d)
   JOIN (d1)
   JOIN (ea
   WHERE (ea.encntr_id=temp->case_qual[d.seq].encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   IF ((temp->case_qual[d.seq].encntr_id=ea.encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd)
    temp->case_qual[d.seq].patient_alias = frmt_mrn
   ELSE
    temp->case_qual[d.seq].patient_alias = "Unknown"
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  pg.prsnl_group_type_cd, p.person_id, p.name_full_formatted
  FROM prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p,
   (dummyt d  WITH seq = value(size(temp->case_qual,5)))
  PLAN (d
   WHERE (temp->case_qual[d.seq].ver_id > 0))
   JOIN (p
   WHERE (temp->case_qual[d.seq].ver_id=p.person_id)
    AND 1=p.active_ind)
   JOIN (pgr
   WHERE p.person_id=pgr.person_id
    AND 1=pgr.active_ind)
   JOIN (pg
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND pg.prsnl_group_type_cd=pathologist_code
    AND pg.active_ind=1
    AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   IF (pg.prsnl_group_type_cd=pathologist_code)
    temp->case_qual[d.seq].path_ind = "P", path_found = "Y"
   ELSE
    temp->case_qual[d.seq].path_ind = "O", other_found = "Y"
   ENDIF
   temp->case_qual[d.seq].ver_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d1  WITH seq = value(size(temp->case_qual,5))),
   prsnl p
  PLAN (d1
   WHERE (temp->case_qual[d1.seq].path_ind="O"))
   JOIN (p
   WHERE (temp->case_qual[d1.seq].ver_id=p.person_id))
  DETAIL
   other_found = "Y", temp->case_qual[d1.seq].ver_name = p.name_full_formatted
  WITH nocounter
 ;end select
#report_maker
 SET case_string = fillstring(90," ")
 SET num_of_phys = value(size(temp->case_qual,5))
 SET x1 = 0
 SET x2 = 0
 SET x3 = 0
 SET x4 = 0
 SET path_printed = "N"
 SET other_printed = "N"
 IF ((request->sabnormal="T"))
  SET case_string = build(case_string," ABNORMAL,")
 ENDIF
 IF ((request->satypical="T"))
  SET case_string = build(case_string," ATYPICAL,")
 ENDIF
 IF ((request->snormal="T"))
  SET case_string = build(case_string," NORMAL,")
 ENDIF
 IF ((request->sunsat="T"))
  SET case_string = build(case_string," UNSATISFACTORY,")
 ENDIF
 SET x1 = findstring(",",case_string)
 IF (x1 > 0)
  SET x2 = findstring(",",case_string,(x1+ 1))
  IF (x2 > 0)
   SET x3 = findstring(",",case_string,(x2+ 1))
   IF (x3 > 0)
    SET x4 = findstring(",",case_string,(x3+ 1))
    IF (x4 > 0)
     SET case_string = substring(1,(x4 - 1),case_string)
    ELSE
     SET case_string = substring(1,(x3 - 1),case_string)
    ENDIF
   ELSE
    SET case_string = substring(1,(x2 - 1),case_string)
   ENDIF
  ELSE
   SET case_string = substring(1,(x1 - 1),case_string)
  ENDIF
 ENDIF
 EXECUTE cpm_create_file_name_logical "aps_cyto_rpt_ver", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SET h_str = fillstring(130," ")
 SELECT INTO value(reply->print_status_data.print_filename)
  x = 0, path_ind = temp->case_qual[d.seq].path_ind, temp->case_qual[d.seq].accession_nbr
  FROM (dummyt d  WITH seq = value(size(temp->case_qual,5)))
  PLAN (d)
  ORDER BY temp->case_qual[d.seq].path_ind DESC, temp->case_qual[d.seq].accession_nbr
  HEAD REPORT
   dotted_line1 = fillstring(130,"-"), dotted_line2 = fillstring(127,"-"), pdath_printed = "N",
   h_str = concat(captions->ccase,"                 ",captions->name,"                       ",
    captions->id,
    "                    ",captions->ver,"  ",captions->bby,"                 ",
    captions->diagnosis), u_str =
   "-------------------  -------------------------  --------------------  --------  -----------------  ---------------------"
  HEAD PAGE
   row + 1, col 0, captions->rreport,
   ":", col 8, captions->aps_prt,
   CALL center(captions->ap,0,132), col 110, captions->ddate,
   temp1 = format(curdate,"@SHORTDATE;;d"), col 117, temp1,
   row + 1, col 0, captions->dir,
   ":", col 110, captions->ttime,
   ":", col 117, curtime,
   row + 1,
   CALL center(captions->crvs,0,132), col 112,
   captions->bby, ":", col 117,
   request->scuruser"##############", row + 1, col 110,
   captions->ppage, ":", col 117,
   curpage"###", row + 1, col 0,
   captions->prefix, ":", col 15,
   last_pref = value(size(temp_pref->pref_qual,5))
   FOR (x = 1 TO last_pref)
     IF ((temp_pref->pref_qual[x].site_cd > 0))
      temp_pref->pref_qual[x].site_display
     ENDIF
     temp_pref->pref_qual[x].prefix_name
     IF (x < last_pref)
      ", "
     ENDIF
     col + 1
     IF (col > 120)
      row + 1, col 15
     ENDIF
   ENDFOR
   row + 1, col 0, captions->incl,
   ":", col 14, case_string,
   row + 1, col 0, captions->dtrange,
   ":", temp2 = format(request->beg_dt_tm,"@SHORTDATE;;d"), col 15,
   temp2, col 26, "-",
   temp3 = format(request->end_dt_tm,"@SHORTDATE;;d"), col 28, temp3,
   row + 1, dotted_line1
   IF (curpage > 1)
    row + 1, col 6, captions->ccase"###################",
    col 27, captions->name"#########################", col 54,
    captions->id"####################", col 76, captions->ver"########",
    col 86, captions->bby"#################", col 105,
    captions->diagnosis"#####################", row + 1, col 6,
    u_str
   ENDIF
  HEAD path_ind
   IF (path_found="Y")
    IF ((temp->case_qual[d.seq].path_ind="P"))
     row + 1, col 2, "--- ",
     captions->verpath, " ---", row + 1,
     col 6, captions->ccase"###################", col 27,
     captions->name"#########################", col 54, captions->id"####################",
     col 76, captions->ver"########", col 86,
     captions->bby"#################", col 105, captions->diagnosis"#####################",
     row + 1, col 6, u_str
    ELSE
     row + 1, col 2, "--- ",
     captions->vernotpath, " ---", row + 1,
     col 6, captions->ccase"###################", col 27,
     captions->name"#########################", col 54, captions->id"####################",
     col 76, captions->ver"########", col 86,
     captions->bby"#################", col 105, captions->diagnosis"#####################",
     row + 1, col 6, u_str
    ENDIF
   ELSE
    IF (other_found="Y")
     row + 1, col 2, "--- ",
     captions->verpath, " ---", row + 1,
     col 6, captions->ccase"###################", col 27,
     captions->name"#########################", col 54, captions->id"####################",
     col 76, captions->ver"########", col 86,
     captions->bby"#################", col 105, captions->diagnosis"#####################",
     row + 1, col 6, u_str,
     row + 1, col 6, "*** ",
     captions->noqual, " ***", row + 1,
     row + 1, col 2, "--- ",
     captions->vernotpath, " ---", row + 1,
     col 6, captions->ccase"###################", col 27,
     captions->name"#########################", col 54, captions->id"####################",
     col 76, captions->ver"########", col 86,
     captions->bby"#################", col 105, captions->diagnosis"#####################",
     row + 1, col 6, u_str
    ELSE
     row + 1, col 2, "--- ",
     captions->verpath, " ---", row + 1,
     col 6, captions->ccase"###################", col 27,
     captions->name"#########################", col 54, captions->id"####################",
     col 76, captions->ver"########", col 86,
     captions->bby"#################", col 105, captions->diagnosis"#####################",
     row + 1, col 6, u_str,
     row + 1, col 6, "*** ",
     captions->noqual, " ***", row + 1,
     row + 1, col 2, "--- ",
     captions->vernotpath, " ---", row + 1,
     col 6, captions->ccase"###################", col 27,
     captions->name"#########################", col 54, captions->id"####################",
     col 76, captions->ver"########", col 86,
     captions->bby"#################", col 105, captions->diagnosis"#####################",
     row + 1, col 6, u_str,
     row + 1, col 6, "*** ",
     captions->noqual, " ***", row + 1
    ENDIF
   ENDIF
  DETAIL
   IF (((path_found="Y") OR (other_found="Y")) )
    my_accession = uar_fmt_accession(temp->case_qual[d.seq].accession_nbr,size(trim(temp->case_qual[d
       .seq].accession_nbr),1)), row + 1, col 6,
    my_accession, col 27, temp->case_qual[d.seq].patient_name,
    col 54, temp->case_qual[d.seq].patient_alias"####################", temp4 = format(temp->
     case_qual[d.seq].verified_date,"@SHORTDATE;;d"),
    col 76, temp4, col 86,
    temp->case_qual[d.seq].ver_name, col 105, temp->case_qual[d.seq].diagnosis_alpha
    IF (((row+ 5) > maxrow))
     BREAK
    ENDIF
   ENDIF
  FOOT  path_ind
   row + 1
   IF (path_ind="P"
    AND other_found="N")
    row + 1, col 2, "--- ",
    captions->vernotpath, " ---", row + 1,
    col 6, captions->ccase"###################", col 27,
    captions->name"#########################", col 54, captions->id"####################",
    col 76, captions->ver"########", col 86,
    captions->bby"#################", col 105, captions->diagnosis"#####################",
    row + 1, col 6, u_str,
    row + 1, col 6, "*** ",
    captions->noqual, " ***", row + 1
   ENDIF
  FOOT PAGE
   row 60, col 0, dotted_line1,
   row + 1, col 0, captions->rptcrvs,
   today = concat(format(curdate,"@WEEKDAYABBREV;;d")," ",format(curdate,"@MEDIUMDATE4YR;;d")), col
   53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->contd
  FOOT REPORT
   col 55, "##########     "
  WITH nocounter, maxcol = 132, nullreport,
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
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#exit_script
 FREE RECORD temp_qa_flag
END GO
