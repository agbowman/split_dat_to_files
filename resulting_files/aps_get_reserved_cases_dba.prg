CREATE PROGRAM aps_get_reserved_cases:dba
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
 RECORD reply(
   1 qual[*]
     2 case_nbr = c21
     2 case_id = f8
     2 path_case_updt_cnt = i4
     2 person_id = f8
     2 encntr_id = f8
     2 comments_long_text_id = f8
     2 c_lt_updt_cnt = i4
     2 comments = vc
     2 accessioned_dt_tm = dq8
     2 accession_prsnl_id = f8
     2 accession_name = vc
     2 patient_name = vc
     2 primary_alias = vc
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 deceased_dt_tm = dq8
     2 age = vc
     2 sex_cd = f8
     2 sex_disp = c40
     2 location_cd = f8
     2 location_disp = c40
     2 loc_facility_cd = f8
     2 loc_facility_disp = c40
     2 loc_building_cd = f8
     2 loc_building_disp = c40
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = c40
     2 loc_room_cd = f8
     2 loc_room_disp = c40
     2 loc_bed_cd = f8
     2 loc_bed_disp = c40
     2 admit_doc = vc
     2 admit_doc_id = f8
     2 facility_accn_prefix_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 prefix_qual[*]
     2 prefix_id = f8
 )
 SET reply->status_data.status = "F"
 SET max_cnt = 0
 SET cnt = 0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET epr_admit_doc_cd = 0.0
 SET stat = alterlist(reply->qual,10)
 IF ((request->facility_accn_prefix_cd > 0))
  SELECT INTO "nl:"
   ap.prefix_id
   FROM ap_prefix ap
   WHERE (request->facility_accn_prefix_cd=ap.site_cd)
   HEAD REPORT
    prefix_cnt = 0
   DETAIL
    prefix_cnt += 1
    IF (mod(prefix_cnt,10)=1)
     stat = alterlist(temp->prefix_qual,(prefix_cnt+ 9))
    ENDIF
    temp->prefix_qual[prefix_cnt].prefix_id = ap.prefix_id
   FOOT REPORT
    stat = alterlist(temp->prefix_qual,prefix_cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX"
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
  SET pc_where1 = fillstring(1000," ")
  FOR (x = 1 TO value(size(temp->prefix_qual,5)))
    IF (x < value(size(temp->prefix_qual,5)))
     SET pc_where1 = build(trim(pc_where1),temp->prefix_qual[x].prefix_id,",")
    ELSE
     SET pc_where1 = build(trim(pc_where1),temp->prefix_qual[x].prefix_id)
    ENDIF
  ENDFOR
  SET pc_where1 = concat("pc.prefix_id in(",trim(pc_where1),")")
  SET pc_where = build("(",trim(pc_where1),") and ",
   "((request->person_id = pc.person_id) or (pc.person_id = 0))")
 ELSE
  SET pc_where = "(request->person_id = pc.person_id) or (pc.person_id = 0)"
 ENDIF
 CALL initresourcesecurity(1)
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET epr_admit_doc_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SELECT INTO "nl:"
  pc.reserved_ind, pc.accession_nbr, pr.name_full_formatted,
  p.name_full_formatted, e.encntr_id, ea.alias,
  epr.prsnl_person_id
  FROM pathology_case pc,
   prsnl pr,
   person p,
   prsnl p2,
   encounter e,
   location l,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   dummyt d0,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   ap_prefix ap
  PLAN (pc
   WHERE 1=pc.reserved_ind
    AND parser(pc_where))
   JOIN (ap
   WHERE ap.prefix_id=pc.prefix_id)
   JOIN (pr
   WHERE pc.accession_prsnl_id=pr.person_id)
   JOIN (d0)
   JOIN (p
   WHERE p.person_id=pc.person_id
    AND p.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=pc.encntr_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (l
   WHERE e.location_cd=l.location_cd)
   JOIN (d1)
   JOIN (ea
   WHERE ea.encntr_id=pc.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d2)
   JOIN (epr
   WHERE epr.encntr_id=pc.encntr_id
    AND epr.encntr_prsnl_r_cd=epr_admit_doc_cd
    AND epr.active_ind=1
    AND epr.manual_create_ind IN (0, null)
    AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d3)
   JOIN (p2
   WHERE p2.person_id=epr.prsnl_person_id)
  HEAD REPORT
   max_cnt = 10, cnt = 0
  DETAIL
   IF (isresourceviewable(ap.service_resource_cd)=true)
    cnt += 1
    IF (cnt > max_cnt)
     stat = alterlist(reply->qual,(cnt+ 10)), max_cnt = (cnt+ 10)
    ENDIF
    reply->qual[cnt].case_nbr = pc.accession_nbr, reply->qual[cnt].case_id = pc.case_id, reply->qual[
    cnt].path_case_updt_cnt = pc.updt_cnt,
    reply->qual[cnt].person_id = pc.person_id, reply->qual[cnt].encntr_id = pc.encntr_id, reply->
    qual[cnt].accessioned_dt_tm = pc.accessioned_dt_tm,
    reply->qual[cnt].accession_prsnl_id = pc.accession_prsnl_id, reply->qual[cnt].accession_name = pr
    .name_full_formatted, reply->qual[cnt].comments_long_text_id = pc.comments_long_text_id,
    reply->qual[cnt].patient_name = p.name_full_formatted, reply->qual[cnt].age = formatage(p
     .birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"), reply->qual[cnt].birth_dt_tm = cnvtdatetime(p
     .birth_dt_tm),
    reply->qual[cnt].birth_tz = p.birth_tz, reply->qual[cnt].deceased_dt_tm = cnvtdatetime(p
     .deceased_dt_tm), reply->qual[cnt].sex_cd = p.sex_cd,
    reply->qual[cnt].location_cd = e.location_cd, reply->qual[cnt].loc_facility_cd = e
    .loc_facility_cd, reply->qual[cnt].loc_building_cd = e.loc_building_cd,
    reply->qual[cnt].loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply->qual[cnt].loc_room_cd = e
    .loc_room_cd, reply->qual[cnt].loc_bed_cd = e.loc_bed_cd,
    reply->qual[cnt].primary_alias = cnvtalias(ea.alias,ea.alias_pool_cd), reply->qual[cnt].
    facility_accn_prefix_cd = e.loc_facility_cd, reply->qual[cnt].admit_doc = p2.name_full_formatted,
    reply->qual[cnt].admit_doc_id = p2.person_id
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH outerjoin = pc, outerjoin = d0, outerjoin = d1,
   outerjoin = d2, outerjoin = d3, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(reply->qual,5)))
  PLAN (d1
   WHERE (reply->qual[d1.seq].comments_long_text_id > 0))
   JOIN (lt
   WHERE (reply->qual[d1.seq].comments_long_text_id=lt.long_text_id)
    AND lt.parent_entity_name="PATHOLOGY_CASE"
    AND (lt.parent_entity_id=reply->qual[d1.seq].case_id))
  DETAIL
   reply->qual[d1.seq].comments = lt.long_text, reply->qual[d1.seq].c_lt_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
#exit_script
END GO
