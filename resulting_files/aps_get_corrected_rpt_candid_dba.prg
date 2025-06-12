CREATE PROGRAM aps_get_corrected_rpt_candid:dba
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
 RECORD reply(
   1 case_id = f8
   1 encntr_id = f8
   1 accession_nbr = vc
   1 person_id = f8
   1 person_name = vc
   1 person_num = c16
   1 sex_cd = f8
   1 sex_disp = vc
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 deceased_dt_tm = dq8
   1 age = vc
   1 case_comment = vc
   1 case_comment_id = f8
   1 rpt_cnt = i4
   1 rpt_qual[*]
     2 report_id = f8
     2 report_sequence = i4
     2 catalog_cd = f8
     2 short_description = c50
     2 event_id = f8
     2 status_cd = f8
     2 status_disp = vc
     2 status_mean = vc
     2 report_comment = vc
     2 report_comment_id = f8
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
 SET reply->status_data.status = "S"
 DECLARE corrected_cd = f8 WITH protect, noconstant(0.0)
 DECLARE correctinit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE correctinprc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE csigninprc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mrn_alias_type_cd = f8 WITH protect, noconstant(0.0)
 CALL initresourcesecurity(1)
 SET stat = uar_get_meaning_by_codeset(1305,"CORRECTED",1,corrected_cd)
 IF (corrected_cd=0.0)
  CALL subevent_add("UAR","F","1305","CANNOT GET CORRECTED CODE VALUE")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CORRECTINIT",1,correctinit_cd)
 IF (correctinit_cd=0.0)
  CALL subevent_add("UAR","F","1305","CANNOT GET CORRECTINIT CODE VALUE")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CORRECTINPRC",1,correctinprc_cd)
 IF (correctinprc_cd=0.0)
  CALL subevent_add("UAR","F","1305","CANNOT GET CORRECTINPRC CODE VALUE")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CSIGNINPROC",1,csigninprc_cd)
 IF (csigninprc_cd=0.0)
  CALL subevent_add("UAR","F","1305","CANNOT GET CSIGNINPROC CODE VALUE")
 ENDIF
 SELECT INTO "nl:"
  pc.accession_nbr, cr.case_id, sd.short_description,
  cr.report_sequence, commented = evaluate(nullind(rt.comments_long_text_id),1,0,1)
  FROM pathology_case pc,
   ap_prefix ap,
   case_report cr,
   service_directory sd,
   report_task rt
  PLAN (pc
   WHERE (pc.accession_nbr=request->accession_nbr))
   JOIN (ap
   WHERE ap.prefix_id=pc.prefix_id)
   JOIN (cr
   WHERE pc.case_id=cr.case_id
    AND cr.status_cd IN (corrected_cd, correctinit_cd, correctinprc_cd, csigninprc_cd))
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   JOIN (rt
   WHERE (rt.report_id= Outerjoin(cr.report_id)) )
  ORDER BY cr.report_sequence
  HEAD REPORT
   rpt_cnt = 0, stat = alterlist(reply->rpt_qual,5), service_resource_cd = 0.0
  DETAIL
   service_resource_cd = ap.service_resource_cd
   IF (isresourceviewable(service_resource_cd)=true)
    rpt_cnt += 1
    IF (mod(rpt_cnt,5)=1
     AND rpt_cnt != 1)
     stat = alterlist(reply->rpt_qual,(rpt_cnt+ 4))
    ENDIF
    reply->rpt_cnt = rpt_cnt, reply->rpt_qual[rpt_cnt].report_id = cr.report_id, reply->rpt_qual[
    rpt_cnt].report_sequence = cr.report_sequence,
    reply->rpt_qual[rpt_cnt].short_description = sd.short_description, reply->rpt_qual[rpt_cnt].
    catalog_cd = cr.catalog_cd, reply->rpt_qual[rpt_cnt].event_id = cr.event_id,
    reply->rpt_qual[rpt_cnt].status_cd = cr.status_cd
    IF (commented=1)
     reply->rpt_qual[rpt_cnt].report_comment_id = rt.comments_long_text_id
    ELSE
     reply->rpt_qual[rpt_cnt].report_comment_id = 0
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rpt_qual,rpt_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(1)
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_alias_type_cd)
 IF (mrn_alias_type_cd=0.0)
  CALL subevent_add("UAR","F","319","CANNOT GET MRN CODE VALUE")
 ENDIF
 SELECT INTO "nl:"
  deceased = evaluate(nullind(p.deceased_dt_tm),1,0,1)
  FROM person p,
   pathology_case pc
  PLAN (pc
   WHERE (pc.accession_nbr=request->accession_nbr))
   JOIN (p
   WHERE pc.person_id=p.person_id)
  DETAIL
   reply->case_id = pc.case_id, reply->encntr_id = pc.encntr_id, reply->accession_nbr = pc
   .accession_nbr,
   reply->person_id = p.person_id, reply->person_name = p.name_full_formatted, reply->person_num =
   "Unknown",
   reply->sex_cd = p.sex_cd, reply->case_comment_id = pc.comments_long_text_id, reply->age =
   formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"),
   reply->birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->birth_tz = validate(p.birth_tz,0)
   IF (deceased=1)
    reply->deceased_dt_tm = cnvtdatetime(p.deceased_dt_tm)
   ELSE
    reply->deceased_dt_tm = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL subevent_add("SELECT","F","TABLE","PERSON")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ea.encntr_id, frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM encntr_alias ea,
   encounter e
  PLAN (e
   WHERE (reply->encntr_id=e.encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ((e.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (e.end_effective_dt_tm=null)) )
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   reply->person_num = frmt_mrn
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text
  FROM long_text lt
  WHERE (reply->case_comment_id=lt.long_text_id)
   AND lt.long_text_id > 0
  DETAIL
   reply->case_comment = trim(lt.long_text)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text
  FROM (dummyt d1  WITH seq = value(reply->rpt_cnt)),
   long_text lt
  PLAN (d1
   WHERE (reply->rpt_qual[d1.seq].report_comment_id > 0))
   JOIN (lt
   WHERE (reply->rpt_qual[d1.seq].report_comment_id=lt.long_text_id))
  DETAIL
   reply->rpt_qual[d1.seq].report_comment = trim(lt.long_text)
  WITH nocounter
 ;end select
#exit_script
END GO
