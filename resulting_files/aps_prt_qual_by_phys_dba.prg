CREATE PROGRAM aps_prt_qual_by_phys:dba
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
   1 physician_qual[5]
     2 physician_id = f8
     2 physician_name = vc
     2 p_gsat_cnt = i4
     2 p_gsatl_cnt = i4
     2 p_gsatu_cnt = i4
     2 p_gyn_cnt = i4
     2 p_ngsat_cnt = i4
     2 p_ngsatl_cnt = i4
     2 p_ngsatu_cnt = i4
     2 p_ngyn_cnt = i4
     2 p_endo_pres_cnt = i4
     2 p_endo_unac_cnt = i4
     2 p_endo_all_cnt = i4
     2 case_qual[*]
       3 case_id = f8
       3 accession_nbr = c21
       3 collected_date = dq8
       3 person_id = f8
       3 encntr_id = f8
       3 patient_name = c25
       3 patient_alias = c20
       3 adeq_flag = i2
       3 adequacy_disp = c45
       3 endocerv_ind = i2
   1 max_case_cnt = i4
 )
 RECORD temp_pref(
   1 pref_qual[*]
     2 prefix_cd = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_display = vc
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
    CALL get_text(startpos2,trim(request->batch_selection),"|")
    IF (trim(text)="T")
     request->bunsatonly = "T"
    ELSE
     request->bunsatonly = "F"
    ENDIF
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
   1 sample_phy = vc
   1 bye = vc
   1 pg = vc
   1 pre = vc
   1 phy = vc
   1 all = vc
   1 dt_rg = vc
   1 none = vc
   1 sample_sum = vc
   1 gyn = vc
   1 phys = vc
   1 all_cse = vc
   1 sample_qual = vc
   1 an = vc
   1 aand = vc
   1 sat = vc
   1 sat_lim = vc
   1 un_sat = vc
   1 non_gyn = vc
   1 summ = vc
   1 endo_cell = vc
   1 pres = vc
   1 unaccept = vc
   1 all_gyn = vc
   1 sample_exclud = vc
   1 cse = vc
   1 collect = vc
   1 nm = vc
   1 id = vc
   1 qual = vc
   1 no_found = vc
   1 cell_ex = vc
   1 title = vc
   1 end_stat = vc
   1 cont = vc
   1 inadeq = vc
 )
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"t1","REPORT:")
 SET captions->rpt_nm = uar_i18ngetmessage(i18nhandle,"t2","APS_PRT_QUAL_BY_PHYS.PRG")
 SET captions->ana = uar_i18ngetmessage(i18nhandle,"t3","Anatomic Pathology")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t4","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t5","DIRECTORY:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t6","TIME:")
 SET captions->sample_phy = uar_i18ngetmessage(i18nhandle,"t7","SAMPLE QUALITY BY PHYSICIAN")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t8","BY:")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t9","PAGE:")
 SET captions->pre = uar_i18ngetmessage(i18nhandle,"t10","PREFIX(ES):")
 SET captions->phy = uar_i18ngetmessage(i18nhandle,"t11","PHYSICIAN:")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"t12","ALL")
 SET captions->dt_rg = uar_i18ngetmessage(i18nhandle,"t13","DATE RANGE:")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"t14",
  "*** No cases found meeting established criteria. ***")
 SET captions->sample_sum = uar_i18ngetmessage(i18nhandle,"t15","SAMPLE QUALITY STATISTICAL SUMMARY")
 SET captions->gyn = uar_i18ngetmessage(i18nhandle,"t16","GYN CYTOLOGY")
 SET captions->phys = uar_i18ngetmessage(i18nhandle,"t17","PHYSICIAN")
 SET captions->all_cse = uar_i18ngetmessage(i18nhandle,"t18","ALL CASES")
 SET captions->sample_qual = uar_i18ngetmessage(i18nhandle,"t19","SAMPLE QUALITY")
 SET captions->an = uar_i18ngetmessage(i18nhandle,"t20","#  AND %")
 SET captions->aand = uar_i18ngetmessage(i18nhandle,"t21","#   AND %")
 SET captions->sat = uar_i18ngetmessage(i18nhandle,"t22","SATISFACTORY")
 SET captions->sat_lim = uar_i18ngetmessage(i18nhandle,"t23","SATISFACTORY, LIMITED")
 SET captions->un_sat = uar_i18ngetmessage(i18nhandle,"t24","UNSATISFACTORY")
 SET captions->non_gyn = uar_i18ngetmessage(i18nhandle,"t25","NON-GYN CYTOLOGY")
 SET captions->summ = uar_i18ngetmessage(i18nhandle,"t26","ENDOCERVICAL CELLS STATISTICAL SUMMARY")
 SET captions->endo_cell = uar_i18ngetmessage(i18nhandle,"t27","ENDOCERVICAL CELLS")
 SET captions->pres = uar_i18ngetmessage(i18nhandle,"t28","PRESENT, OR ACCEPTABLE ABSENCE")
 SET captions->unaccept = uar_i18ngetmessage(i18nhandle,"t29","UNACCEPTABLE ABSENCE")
 SET captions->all_gyn = uar_i18ngetmessage(i18nhandle,"t30","ALL GYN CASES")
 SET captions->sample_exclud = uar_i18ngetmessage(i18nhandle,"t31",
  "SAMPLE QUALITY CASE SUMMARY, EXCLUDING SATISFACTORY CASES")
 SET captions->cse = uar_i18ngetmessage(i18nhandle,"t32","CASE")
 SET captions->collect = uar_i18ngetmessage(i18nhandle,"t33","COLLECTED")
 SET captions->nm = uar_i18ngetmessage(i18nhandle,"t34","NAME")
 SET captions->id = uar_i18ngetmessage(i18nhandle,"t35","ID")
 SET captions->qual = uar_i18ngetmessage(i18nhandle,"t36","QUALITY")
 SET captions->no_found = uar_i18ngetmessage(i18nhandle,"t37","No cases found.")
 SET captions->cell_ex = uar_i18ngetmessage(i18nhandle,"t38",
  "ENDOCERVICAL CELLS CASE SUMMARY, EXCLUDING SATISFACTORY CASES")
 SET captions->title = uar_i18ngetmessage(i18nhandle,"t39","REPORT: SAMPLE QUALITY BY PHYSICIAN")
 SET captions->end_stat = uar_i18ngetmessage(i18nhandle,"t40","*** end of physician statistics ***")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"t41","CONTINUED...")
 SET captions->inadeq = uar_i18ngetmessage(i18nhandle,"t42",
  "Include only physicians with sample quality inadequacies")
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
 SET reply->status_data.status = "Z"
 SET gyn_case_type_cd = 0.0
 SET ngyn_case_type_cd = 0.0
 SET code_value = 0.0
 SET deleted_status_cd = 0.0
 SET cdf_meaning = fillstring(10," ")
 SET code_set = 48
 SET code_value = 0.0
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_status_cd = code_value
 DECLARE nprintablephysiciansfound = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
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
  SET phys_where = "pc.requesting_physician_id = request->req_physician_id"
 ENDIF
 SET gyn_cnt = 0
 SET gsat_cnt = 0
 SET gsatl_cnt = 0
 SET gunsat_cnt = 0
 SET ngyn_cnt = 0
 SET ngsat_cnt = 0
 SET ngsatl_cnt = 0
 SET ngunsat_cnt = 0
 SET gsat_perc = 0.00
 SET gsatl_perc = 0.00
 SET gunsat_perc = 0.00
 SET ngsat_perc = 0.00
 SET ngsatl_perc = 0.00
 SET ngunsat_perc = 0.00
 SET endo_pres_cnt = 0
 SET endo_unac_cnt = 0
 SET endo_all_cnt = 0
 SET endo_pres_perc = 0.00
 SET endo_unac_perc = 0.00
 SET endo_all_perc = 0.00
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
  cse.case_id, request->beg_dt_tm"mm/dd/yy;;d", request->end_dt_tm"mm/dd/yy;;d",
  pc.accession_nbr, pc.case_collect_dt_tm, pc.case_id
  FROM (dummyt d  WITH seq = value(size(request->prefix_qual,5))),
   pathology_case pc,
   cyto_screening_event cse
  PLAN (d)
   JOIN (pc
   WHERE (request->prefix_qual[d.seq].prefix_cd=(pc.prefix_id+ 0))
    AND pc.case_collect_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND pc.case_type_cd IN (gyn_case_type_cd, ngyn_case_type_cd))
   JOIN (cse
   WHERE pc.case_id=cse.case_id
    AND 1=cse.verify_ind)
  HEAD REPORT
   row + 0, pref_cnt = 0
  DETAIL
   IF (pc.case_type_cd=gyn_case_type_cd)
    CASE (cse.adequacy_flag)
     OF 0:
      gsat_cnt += 1
     OF 1:
      gsatl_cnt += 1
     OF 2:
      gunsat_cnt += 1
    ENDCASE
    gyn_cnt += 1
    CASE (cse.endocerv_ind)
     OF 0:
      endo_pres_cnt += 1
     OF 1:
      endo_unac_cnt += 1
    ENDCASE
    endo_all_cnt += 1
   ELSEIF (pc.case_type_cd=ngyn_case_type_cd)
    CASE (cse.adequacy_flag)
     OF 0:
      ngsat_cnt += 1
     OF 1:
      ngsatl_cnt += 1
     OF 2:
      ngunsat_cnt += 1
    ENDCASE
    ngyn_cnt += 1
   ENDIF
  FOOT REPORT
   gsat_perc = ((cnvtreal(gsat_cnt)/ cnvtreal(gyn_cnt)) * 100), gsatl_perc = ((cnvtreal(gsatl_cnt)/
   cnvtreal(gyn_cnt)) * 100), gunsat_perc = ((cnvtreal(gunsat_cnt)/ cnvtreal(gyn_cnt)) * 100),
   ngsat_perc = ((cnvtreal(ngsat_cnt)/ cnvtreal(ngyn_cnt)) * 100), ngsatl_perc = ((cnvtreal(
    ngsatl_cnt)/ cnvtreal(ngyn_cnt)) * 100), ngunsat_perc = ((cnvtreal(ngunsat_cnt)/ cnvtreal(
    ngyn_cnt)) * 100),
   endo_pres_perc = ((cnvtreal(endo_pres_cnt)/ cnvtreal(endo_all_cnt)) * 100), endo_unac_perc = ((
   cnvtreal(endo_unac_cnt)/ cnvtreal(endo_all_cnt)) * 100)
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
  cse.case_id, pc.requesting_physician_id, pc.case_id
  FROM (dummyt d  WITH seq = value(size(request->prefix_qual,5))),
   pathology_case pc,
   cyto_screening_event cse,
   person p
  PLAN (d)
   JOIN (pc
   WHERE (request->prefix_qual[d.seq].prefix_cd=(pc.prefix_id+ 0))
    AND parser(phys_where)
    AND pc.case_type_cd IN (gyn_case_type_cd, ngyn_case_type_cd)
    AND pc.case_collect_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm))
   JOIN (cse
   WHERE pc.case_id=cse.case_id
    AND 1=cse.verify_ind)
   JOIN (p
   WHERE pc.person_id=p.person_id)
  ORDER BY pc.requesting_physician_id, pc.accession_nbr
  HEAD REPORT
   stat = alter(temp->physician_qual,5), row + 0, phys_cnt = 0,
   case_cnt = 0
  HEAD pc.requesting_physician_id
   phys_cnt += 1, case_cnt = 0
   IF (mod(phys_cnt,5)=1
    AND phys_cnt != 1)
    stat = alter(temp->physician_qual,(phys_cnt+ 5))
   ENDIF
   temp->physician_qual[phys_cnt].physician_id = pc.requesting_physician_id, temp->physician_qual[
   phys_cnt].p_gsat_cnt = 0, temp->physician_qual[phys_cnt].p_gsatl_cnt = 0,
   temp->physician_qual[phys_cnt].p_gsatu_cnt = 0, temp->physician_qual[phys_cnt].p_gyn_cnt = 0, temp
   ->physician_qual[phys_cnt].p_ngsat_cnt = 0,
   temp->physician_qual[phys_cnt].p_ngsatl_cnt = 0, temp->physician_qual[phys_cnt].p_ngsatu_cnt = 0,
   temp->physician_qual[phys_cnt].p_ngyn_cnt = 0,
   temp->physician_qual[phys_cnt].p_endo_pres_cnt = 0, temp->physician_qual[phys_cnt].p_endo_unac_cnt
    = 0, temp->physician_qual[phys_cnt].p_endo_all_cnt = 0
  DETAIL
   IF (pc.case_type_cd=gyn_case_type_cd)
    CASE (cse.adequacy_flag)
     OF 0:
      temp->physician_qual[phys_cnt].p_gsat_cnt += 1
     OF 1:
      temp->physician_qual[phys_cnt].p_gsatl_cnt += 1
     OF 2:
      temp->physician_qual[phys_cnt].p_gsatu_cnt += 1
    ENDCASE
    temp->physician_qual[phys_cnt].p_gyn_cnt += 1
    CASE (cse.endocerv_ind)
     OF 0:
      temp->physician_qual[phys_cnt].p_endo_pres_cnt += 1
     OF 1:
      temp->physician_qual[phys_cnt].p_endo_unac_cnt += 1
    ENDCASE
    temp->physician_qual[phys_cnt].p_endo_all_cnt += 1
   ELSEIF (pc.case_type_cd=ngyn_case_type_cd)
    CASE (cse.adequacy_flag)
     OF 0:
      temp->physician_qual[phys_cnt].p_ngsat_cnt += 1
     OF 1:
      temp->physician_qual[phys_cnt].p_ngsatl_cnt += 1
     OF 2:
      temp->physician_qual[phys_cnt].p_ngsatu_cnt += 1
    ENDCASE
    temp->physician_qual[phys_cnt].p_ngyn_cnt += 1
   ENDIF
   case_cnt += 1, stat = alterlist(temp->physician_qual[phys_cnt].case_qual,case_cnt)
   IF ((case_cnt > temp->max_case_cnt))
    temp->max_case_cnt = case_cnt
   ENDIF
   temp->physician_qual[phys_cnt].case_qual[case_cnt].accession_nbr = pc.accession_nbr, temp->
   physician_qual[phys_cnt].case_qual[case_cnt].case_id = pc.case_id, temp->physician_qual[phys_cnt].
   case_qual[case_cnt].collected_date = pc.case_collect_dt_tm,
   temp->physician_qual[phys_cnt].case_qual[case_cnt].person_id = pc.person_id, temp->physician_qual[
   phys_cnt].case_qual[case_cnt].encntr_id = pc.encntr_id, temp->physician_qual[phys_cnt].case_qual[
   case_cnt].endocerv_ind = cse.endocerv_ind,
   temp->physician_qual[phys_cnt].case_qual[case_cnt].adeq_flag = cse.adequacy_flag, temp->
   physician_qual[phys_cnt].case_qual[case_cnt].patient_name = p.name_full_formatted
  FOOT  pc.requesting_physician_id
   IF ((request->bunsatonly="T")
    AND (temp->physician_qual[phys_cnt].p_gsatl_cnt=0)
    AND (temp->physician_qual[phys_cnt].p_gsatu_cnt=0)
    AND (temp->physician_qual[phys_cnt].p_ngsatl_cnt=0)
    AND (temp->physician_qual[phys_cnt].p_ngsatu_cnt=0)
    AND (temp->physician_qual[phys_cnt].p_endo_unac_cnt=0))
    temp->physician_qual[phys_cnt].physician_id = 0
   ELSE
    nprintablephysiciansfound = 1
   ENDIF
  FOOT REPORT
   stat = alter(temp->physician_qual,phys_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM (dummyt d  WITH seq = value(size(temp->physician_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_case_cnt)),
   (dummyt d3  WITH seq = 1),
   encntr_alias ea
  PLAN (d
   WHERE (temp->physician_qual[d.seq].physician_id > 0))
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
 SELECT INTO "nl:"
  pr.name_full_formatted
  FROM prsnl pr,
   (dummyt d  WITH seq = value(size(temp->physician_qual,5)))
  PLAN (d
   WHERE (temp->physician_qual[d.seq].physician_id > 0))
   JOIN (pr
   WHERE (temp->physician_qual[d.seq].physician_id=pr.person_id))
  DETAIL
   temp->physician_qual[d.seq].physician_name = pr.name_full_formatted
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(size(temp->physician_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_case_cnt)),
   case_report cr,
   cyto_report_control crc,
   clinical_event ce
  PLAN (d
   WHERE (temp->physician_qual[d.seq].physician_id > 0))
   JOIN (d2
   WHERE d2.seq <= size(temp->physician_qual[d.seq].case_qual,5)
    AND (temp->physician_qual[d.seq].case_qual[d2.seq].adeq_flag != 0))
   JOIN (cr
   WHERE (temp->physician_qual[d.seq].case_qual[d2.seq].case_id=cr.case_id))
   JOIN (crc
   WHERE cr.catalog_cd=crc.catalog_cd)
   JOIN (ce
   WHERE cr.event_id=ce.parent_event_id
    AND crc.adequacy_task_assay_cd=ce.task_assay_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.record_status_cd != deleted_status_cd
    AND trim(ce.accession_nbr)=trim(temp->physician_qual[d.seq].case_qual[d2.seq].accession_nbr))
  DETAIL
   temp->physician_qual[d.seq].case_qual[d2.seq].adequacy_disp = ce.result_val
  WITH nocounter
 ;end select
#report_section
 SET phys_cnt = 0
 SET num_of_phys = value(size(temp->physician_qual,5))
 EXECUTE cpm_create_file_name_logical "aps_qual_by_phys", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  x = 0, d.seq, concat_name_id = build(temp->physician_qual[d.seq].physician_name,temp->
   physician_qual[d.seq].physician_id),
  accession_nbr = temp->physician_qual[d.seq].case_qual[d2.seq].accession_nbr
  FROM (dummyt d  WITH seq = value(size(temp->physician_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_case_cnt))
  PLAN (d
   WHERE (temp->physician_qual[d.seq].physician_id > 0))
   JOIN (d2
   WHERE d2.seq <= size(temp->physician_qual[d.seq].case_qual,5))
  ORDER BY concat_name_id, accession_nbr
  HEAD REPORT
   dotted_line1 = fillstring(130,"-"), dotted_line2 = fillstring(127,"-")
  HEAD PAGE
   date1 = format(curdate,"@SHORTDATE;;D"), time1 = format(curtime,"@TIMENOSECONDS;;M"), row + 1,
   col 0, captions->rpt, col 8,
   captions->rpt_nm,
   CALL center(captions->ana,0,132), col 110,
   captions->dt, col 117, date1,
   row + 1, col 0, captions->dir,
   col 110, captions->tm, col 117,
   time1, row + 1, col 52,
   CALL center(captions->sample_phy,0,132), col 112, captions->bye,
   col 117, request->scuruser"##############", row + 1,
   col 110, captions->pg, col 117,
   curpage"###", row + 1, col 0,
   captions->pre, col 15, last_pref = value(size(temp_pref->pref_qual,5))
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
   row + 1, captions->phy
   IF ((request->req_physician_id=0))
    col 15, captions->all
   ELSE
    IF ((temp->physician_qual[1].physician_id > 0))
     col 15, temp->physician_qual[1].physician_name
    ENDIF
   ENDIF
   IF ((request->bunsatonly="T"))
    row + 1, captions->inadeq, col 15
   ENDIF
   row + 1, col 0, captions->dt_rg,
   col 15, request->beg_dt_tm"@SHORTDATE;;D", col 26,
   "-", col 28, request->end_dt_tm"@SHORTDATE;;D"
   IF (nprintablephysiciansfound=0)
    row + 6,
    CALL center(captions->none,0,132)
   ENDIF
  HEAD concat_name_id
   phys_cnt += 1
   IF ((request->bpagebreak="T"))
    IF (phys_cnt > 1)
     BREAK
    ENDIF
   ENDIF
   row + 1, dotted_line1, row + 1,
   captions->phy, col 15, temp->physician_qual[d.seq].physician_name,
   row + 1, p_gsat_perc = ((cnvtreal(temp->physician_qual[d.seq].p_gsat_cnt)/ cnvtreal(temp->
    physician_qual[d.seq].p_gyn_cnt)) * 100), p_gsatl_perc = ((cnvtreal(temp->physician_qual[d.seq].
    p_gsatl_cnt)/ cnvtreal(temp->physician_qual[d.seq].p_gyn_cnt)) * 100),
   p_gsatu_perc = ((cnvtreal(temp->physician_qual[d.seq].p_gsatu_cnt)/ cnvtreal(temp->physician_qual[
    d.seq].p_gyn_cnt)) * 100), p_ngsat_perc = ((cnvtreal(temp->physician_qual[d.seq].p_ngsat_cnt)/
   cnvtreal(temp->physician_qual[d.seq].p_ngyn_cnt)) * 100), p_ngsatl_perc = ((cnvtreal(temp->
    physician_qual[d.seq].p_ngsatl_cnt)/ cnvtreal(temp->physician_qual[d.seq].p_ngyn_cnt)) * 100),
   p_ngsatu_perc = ((cnvtreal(temp->physician_qual[d.seq].p_ngsatu_cnt)/ cnvtreal(temp->
    physician_qual[d.seq].p_ngyn_cnt)) * 100), p_endo_pres_perc = ((cnvtreal(temp->physician_qual[d
    .seq].p_endo_pres_cnt)/ cnvtreal(temp->physician_qual[d.seq].p_endo_all_cnt)) * 100),
   p_endo_unac_perc = ((cnvtreal(temp->physician_qual[d.seq].p_endo_unac_cnt)/ cnvtreal(temp->
    physician_qual[d.seq].p_endo_all_cnt)) * 100)
   IF (((row+ 12) > maxrow))
    BREAK
   ENDIF
   row + 1, col 4, dotted_line2,
   col 8, captions->sample_sum
   IF (gyn_case_type_found="Y")
    row + 1, col 5, captions->gyn,
    col 40, captions->phys, col 57,
    captions->all_cse, row + 1, col 5,
    captions->sample_qual, col 40, captions->an,
    col 57, captions->aand, row + 1,
    col 5, "--------------------------", col 39,
    "-----", col 47, "------",
    col 55, "-------", col 65,
    "------", row + 1, col 5,
    captions->sat, col 39, temp->physician_qual[d.seq].p_gsat_cnt"#####",
    col 47, p_gsat_perc"###.#;i;f", col 55,
    gsat_cnt"#######", col 65, gsat_perc"###.#;i;f",
    row + 1, col 5, captions->sat_lim,
    col 39, temp->physician_qual[d.seq].p_gsatl_cnt"#####", col 47,
    p_gsatl_perc"###.#;i;f", col 55, gsatl_cnt"#######",
    col 65, gsatl_perc"###.#;i;f", row + 1,
    col 5, captions->un_sat, col 39,
    temp->physician_qual[d.seq].p_gsatu_cnt"#####", col 47, p_gsatu_perc"###.#;i;f",
    col 55, gunsat_cnt"#######", col 65,
    gunsat_perc"###.#;i;f", row + 1, col 5,
    captions->all_cse, col 39, temp->physician_qual[d.seq].p_gyn_cnt"#####",
    col 55, gyn_cnt"#######"
   ENDIF
   IF (((row+ 12) > maxrow))
    BREAK
   ENDIF
   IF (ngyn_case_type_found="Y")
    row + 2, col 5, captions->non_gyn,
    col 40, captions->phys, col 57,
    captions->all_cse, row + 1, col 5,
    captions->sample_qual, col 40, captions->an,
    col 57, captions->aand, row + 1,
    col 5, "--------------------------", col 39,
    "-----", col 47, "------",
    col 55, "-------", col 65,
    "------", row + 1, col 5,
    captions->sat, col 39, temp->physician_qual[d.seq].p_ngsat_cnt"#####",
    col 47, p_ngsat_perc"###.#;i;f", col 55,
    ngsat_cnt"#######", col 65, ngsat_perc"###.#;i;f",
    row + 1, col 5, captions->sat_lim,
    col 39, temp->physician_qual[d.seq].p_ngsatl_cnt"#####", col 47,
    p_ngsatl_perc"###.#;i;f", col 55, ngsatl_cnt"#######",
    col 65, ngsatl_perc"###.#;i;f", row + 1,
    col 5, captions->un_sat, col 39,
    temp->physician_qual[d.seq].p_ngsatu_cnt"#####", col 47, p_ngsatu_perc"###.#;i;f",
    col 55, ngunsat_cnt"#######", col 65,
    ngunsat_perc"###.#;i;f", row + 1, col 5,
    captions->all_cse, col 39, temp->physician_qual[d.seq].p_ngyn_cnt"#####",
    col 55, ngyn_cnt"#######"
   ENDIF
   IF (((row+ 12) > maxrow))
    BREAK
   ENDIF
   row + 2, col 4, dotted_line2,
   col 8, captions->summ, row + 1,
   col 40, captions->phys, col 57,
   captions->all_cse, row + 1, col 5,
   captions->endo_cell, col 40, captions->an,
   col 57, captions->aand, row + 1,
   col 5, "--------------------------", col 39,
   "-----", col 47, "------",
   col 55, "-------", col 65,
   "------", row + 1, col 5,
   captions->pres, col 39, temp->physician_qual[d.seq].p_endo_pres_cnt"#####",
   col 47, p_endo_pres_perc"###.#;i;f", col 55,
   endo_pres_cnt"#######", col 65, endo_pres_perc"###.#;i;f",
   row + 1, col 5, captions->unaccept,
   col 39, temp->physician_qual[d.seq].p_endo_unac_cnt"#####", col 47,
   p_endo_unac_perc"###.#;i;f", col 55, endo_unac_cnt"#######",
   col 65, endo_unac_perc"###.#;i;f", row + 1,
   col 5, captions->all_gyn, col 39,
   temp->physician_qual[d.seq].p_endo_all_cnt"#####", col 55, endo_all_cnt"#######"
   IF (((row+ 12) > maxrow))
    BREAK
   ENDIF
   IF ((request->blistcases="T"))
    row + 2, col 4, dotted_line2,
    col 8, captions->sample_exclud, row + 1,
    col 5, captions->cse, col 25,
    captions->collect, col 36, captions->nm,
    col 62, captions->id, col 83,
    captions->qual, row + 1, col 5,
    "------------------", col 25, "---------",
    col 36, "-------------------------", col 62,
    "--------------------", col 83, "------------------------------------------------",
    case_cnt1 = size(temp->physician_qual[d.seq].case_qual,5)
    IF (case_cnt1 > 0)
     prnt_cnt = 0
     FOR (case_cnt = 1 TO size(temp->physician_qual[d.seq].case_qual,5))
       IF ((temp->physician_qual[d.seq].case_qual[case_cnt].adeq_flag != 0))
        prnt_cnt += 1, my_accession = uar_fmt_accession(temp->physician_qual[d.seq].case_qual[
         case_cnt].accession_nbr,size(trim(temp->physician_qual[d.seq].case_qual[case_cnt].
           accession_nbr),1)), row + 1,
        col 5, my_accession, col 25,
        temp->physician_qual[d.seq].case_qual[case_cnt].collected_date"@SHORTDATE;;D", col 36, temp->
        physician_qual[d.seq].case_qual[case_cnt].patient_name,
        col 62, temp->physician_qual[d.seq].case_qual[case_cnt].patient_alias"####################",
        col 83,
        temp->physician_qual[d.seq].case_qual[case_cnt].adequacy_disp
        "#############################################"
        IF (((row+ 12) > maxrow))
         BREAK
        ENDIF
       ENDIF
     ENDFOR
    ELSE
     row + 1, col 5, captions->no_found
    ENDIF
    IF (prnt_cnt=0)
     row + 1, col 5, captions->no_found
    ENDIF
    row + 2, col 4, dotted_line2,
    col 8, captions->cell_ex, row + 1,
    col 5, captions->cse, col 25,
    captions->collect, col 36, captions->nm,
    col 62, captions->id, row + 1,
    col 5, "------------------", col 25,
    "---------", col 36, "-------------------------",
    col 62, "--------------------", case_cnt1 = size(temp->physician_qual[d.seq].case_qual,5),
    prnt_cnt = 0
    IF (case_cnt1 > 0)
     FOR (case_cnt = 1 TO size(temp->physician_qual[d.seq].case_qual,5))
       IF ((temp->physician_qual[d.seq].case_qual[case_cnt].endocerv_ind != 0))
        prnt_cnt += 1, my_accession = uar_fmt_accession(temp->physician_qual[d.seq].case_qual[
         case_cnt].accession_nbr,size(trim(temp->physician_qual[d.seq].case_qual[case_cnt].
           accession_nbr),1)), row + 1,
        col 5, my_accession, col 25,
        temp->physician_qual[d.seq].case_qual[case_cnt].collected_date"@SHORTDATE;;D", col 36, temp->
        physician_qual[d.seq].case_qual[case_cnt].patient_name,
        col 62, temp->physician_qual[d.seq].case_qual[case_cnt].patient_alias
        IF (((row+ 12) > maxrow))
         BREAK
        ENDIF
       ENDIF
     ENDFOR
    ELSE
     row + 1, col 5, captions->no_found
    ENDIF
    IF (prnt_cnt=0)
     row + 1, col 5, captions->no_found
    ENDIF
   ENDIF
   row + 2,
   CALL center(captions->end_stat,0,132)
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
