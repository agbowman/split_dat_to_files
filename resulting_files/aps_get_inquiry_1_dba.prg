CREATE PROGRAM aps_get_inquiry_1:dba
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
 RECORD temp(
   1 qual[*]
     2 case_id = f8
 )
#script
 SET reply->context_more_data = "F"
 SET reply->status_data.status = "F"
 DECLARE attempted_years_cnt = i4 WITH protect, noconstant(0)
 DECLARE maxqualrows = i4 WITH protect, noconstant(0)
 DECLARE max_num = i4 WITH protect, noconstant(0)
 DECLARE min_num = i4 WITH protect, noconstant(0)
 DECLARE mrn_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE case_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE max_rpt_cnt = i4 WITH protect, noconstant(0)
 IF (validate(context->context_ind,0) != 0)
  SET maxqualrows = context->maxqual
  EXECUTE FROM build_context_where_clauses_start TO build_context_where_clauses_end
  GO TO begin_final_run
 ELSE
  SET maxqualrows = request->maxqual
  EXECUTE FROM build_initial_where_clauses_start TO build_initial_where_clauses_end
  GO TO begin_final_run
 ENDIF
#build_initial_where_clauses_start
 SET giveme_canceled = request->bretrievecanceled
 SET giveme_prefix_cnt = request->prefix_cnt
 SET giveme_case_year = request->case_year
 SET giveme_single_case_ind = request->single_case_ind
 SET giveme_case_number = request->case_number
 SET giveme_prefix_cd = request->prefix_qual[1].prefix_cd
#build_initial_where_clauses_end
#build_context_where_clauses_start
 SET giveme_canceled = context->retrieve_canceled_ind
 SET giveme_prefix_cnt = context->prefix_cnt
 SET giveme_case_year = context->case_year
 SET giveme_single_case_ind = context->single_case_ind
 SET giveme_case_number = context->case_number
 SET giveme_prefix_cd = context->prefix_cd
#build_context_where_clauses_end
#begin_final_run
 SET attempted_years_cnt += 1
 IF (maxqualrows > 10)
  SET stat = alter(reply->qual,maxqualrows)
 ENDIF
 RANGE OF cp IS case_provider
 RANGE OF cs1 IS case_specimen
 SET mrn_alias_type_cd = uar_get_code_by("MEANING",319,"MRN")
#main_select
 SET max_num = giveme_case_number
 IF (((max_num - maxqualrows) > 0))
  SET min_num = (max_num - maxqualrows)
 ELSE
  SET min_num = 0
 ENDIF
 SELECT INTO "nl:"
  pc.case_id
  FROM pathology_case pc
  PLAN (pc
   WHERE pc.case_year=giveme_case_year
    AND pc.prefix_id=giveme_prefix_cd
    AND pc.case_number BETWEEN min_num AND max_num
    AND pc.reserved_ind != 1)
  ORDER BY pc.accession_nbr DESC
  DETAIL
   IF (case_cnt=maxqualrows)
    IF ((reply->context_more_data="F"))
     reply->context_more_data = "T", context->prefix_cnt = giveme_prefix_cnt, context->prefix_cd =
     giveme_prefix_cd,
     context->single_case_ind = giveme_single_case_ind, context->retrieve_canceled_ind =
     giveme_canceled, context->case_year = pc.case_year,
     context->case_number = pc.case_number, context->context_ind = 1, context->maxqual = maxqualrows
    ENDIF
   ELSE
    case_cnt += 1
    IF (mod(case_cnt,10)=1)
     stat = alterlist(temp->qual,(case_cnt+ 9))
    ENDIF
    temp->qual[case_cnt].case_id = pc.case_id
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->context_more_data="F"))
  SET giveme_case_number = 0
  IF (min_num > 1)
   SELECT INTO "nl:"
    my_max_num = max(pc.case_number)
    FROM pathology_case pc
    WHERE pc.case_year=giveme_case_year
     AND pc.prefix_id=giveme_prefix_cd
     AND pc.case_number < min_num
     AND pc.reserved_ind != 1
    DETAIL
     giveme_case_number = my_max_num
    WITH nocounter
   ;end select
  ENDIF
  IF (giveme_case_number=0
   AND attempted_years_cnt <= 5)
   SET giveme_case_year -= 1
   SET attempted_years_cnt += 1
   SELECT INTO "nl:"
    my_max_num = max(pc.case_number)
    FROM pathology_case pc
    WHERE pc.case_year=giveme_case_year
     AND pc.prefix_id=giveme_prefix_cd
     AND pc.reserved_ind != 1
    DETAIL
     giveme_case_number = my_max_num
    WITH nocounter
   ;end select
  ENDIF
  IF (giveme_case_number != 0)
   GO TO main_select
  ENDIF
 ENDIF
 IF (case_cnt > 0)
  SELECT INTO "nl:"
   pc.case_id, pc.accession_nbr, join_path = decode(d2.seq,"S","R"),
   t.tag_group_id, t.tag_sequence, nullind_p_deceased_dt_tm = nullind(p.deceased_dt_tm)
   FROM (dummyt d1  WITH seq = value(case_cnt)),
    pathology_case pc,
    person p,
    prsnl pr,
    case_specimen cs,
    ap_tag t,
    case_report cr,
    service_directory sd,
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1)
    JOIN (pc
    WHERE (temp->qual[d1.seq].case_id=pc.case_id))
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (((d2
    WHERE 1=d2.seq)
    JOIN (cs
    WHERE pc.case_id=cs.case_id)
    JOIN (t
    WHERE cs.specimen_tag_id=t.tag_id)
    ) ORJOIN ((d3
    WHERE 1=d3.seq)
    JOIN (cr
    WHERE pc.case_id=cr.case_id)
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    ))
   ORDER BY d1.seq, cr.report_sequence, sd.short_description,
    t.tag_group_id, t.tag_sequence
   HEAD REPORT
    spec_cnt = 0, rpt_cnt = 0
   HEAD d1.seq
    cnt += 1
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alter(reply->qual,(cnt+ 9))
    ENDIF
    spec_cnt = 0, rpt_cnt = 0, stat = alterlist(reply->qual[cnt].spec_qual,5),
    stat = alterlist(reply->qual[cnt].rpt_qual,5), reply->qual[cnt].case_id = pc.case_id, reply->
    qual[cnt].fill_ext_accession_id = pc.case_id,
    reply->qual[cnt].encntr_id = pc.encntr_id, reply->qual[cnt].pc_cancel_cd = pc.cancel_cd, reply->
    qual[cnt].pc_cancel_id = pc.cancel_id,
    reply->qual[cnt].pc_cancel_dt_tm = pc.cancel_dt_tm, reply->qual[cnt].accession_nbr = pc
    .accession_nbr, reply->qual[cnt].blob_bitmap = pc.blob_bitmap,
    reply->qual[cnt].case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm), reply->qual[cnt].
    case_received_dt_tm = cnvtdatetime(pc.case_received_dt_tm), reply->qual[cnt].case_received_by_id
     = pc.accession_prsnl_id,
    reply->qual[cnt].prefix_cd = pc.prefix_id, reply->qual[cnt].case_year = pc.case_year, reply->
    qual[cnt].case_number = pc.case_number,
    reply->qual[cnt].case_comment_long_text_id = pc.comments_long_text_id, reply->qual[cnt].
    req_physician_name = pr.name_full_formatted, reply->qual[cnt].req_physician_id = pr.person_id,
    reply->qual[cnt].person_id = p.person_id, reply->qual[cnt].person_name = p.name_full_formatted,
    reply->qual[cnt].sex_cd = p.sex_cd,
    reply->qual[cnt].responsible_pathologist_id = pc.responsible_pathologist_id, reply->qual[cnt].
    responsible_resident_id = pc.responsible_resident_id, reply->qual[cnt].birth_dt_tm = cnvtdatetime
    (p.birth_dt_tm),
    reply->qual[cnt].birth_tz = validate(p.birth_tz,0)
    IF (nullind_p_deceased_dt_tm=0)
     reply->qual[cnt].deceased_dt_tm = cnvtdatetime(p.deceased_dt_tm)
    ELSE
     reply->qual[cnt].deceased_dt_tm = 0
    ENDIF
    reply->qual[cnt].age = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE")
   DETAIL
    CASE (join_path)
     OF "S":
      spec_cnt += 1,
      IF (mod(spec_cnt,5)=1
       AND spec_cnt != 1)
       stat = alterlist(reply->qual[cnt].spec_qual,(spec_cnt+ 4))
      ENDIF
      ,reply->qual[cnt].spec_cnt = spec_cnt,reply->qual[cnt].spec_qual[spec_cnt].case_specimen_id =
      cs.case_specimen_id,reply->qual[cnt].spec_qual[spec_cnt].specimen_tag_group_cd = t.tag_group_id,
      reply->qual[cnt].spec_qual[spec_cnt].specimen_tag_sequence = t.tag_sequence,reply->qual[cnt].
      spec_qual[spec_cnt].specimen_tag_display = t.tag_disp,reply->qual[cnt].spec_qual[spec_cnt].
      specimen_tag_cd = cs.specimen_tag_id,
      reply->qual[cnt].spec_qual[spec_cnt].specimen_description = trim(cs.specimen_description),reply
      ->qual[cnt].spec_qual[spec_cnt].specimen_cd = cs.specimen_cd
     OF "R":
      rpt_cnt += 1,
      IF (mod(rpt_cnt,5)=1
       AND rpt_cnt != 1)
       stat = alterlist(reply->qual[cnt].rpt_qual,(rpt_cnt+ 4))
      ENDIF
      ,reply->qual[cnt].rpt_cnt = rpt_cnt,reply->qual[cnt].rpt_qual[rpt_cnt].report_id = cr.report_id,
      reply->qual[cnt].rpt_qual[rpt_cnt].blob_bitmap = cr.blob_bitmap,
      reply->qual[cnt].rpt_qual[rpt_cnt].report_sequence = cr.report_sequence,reply->qual[cnt].
      rpt_qual[rpt_cnt].catalog_cd = cr.catalog_cd,reply->qual[cnt].rpt_qual[rpt_cnt].
      short_description = sd.short_description,
      reply->qual[cnt].rpt_qual[rpt_cnt].long_description = sd.description,reply->qual[cnt].rpt_qual[
      rpt_cnt].event_id = cr.event_id,reply->qual[cnt].rpt_qual[rpt_cnt].status_cd = cr.status_cd
    ENDCASE
   FOOT  d1.seq
    stat = alterlist(reply->qual[cnt].spec_qual,spec_cnt), stat = alterlist(reply->qual[cnt].rpt_qual,
     rpt_cnt)
    IF (rpt_cnt > max_rpt_cnt)
     max_rpt_cnt = rpt_cnt
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FREE SET temp
 SET stat = alter(reply->qual,cnt)
 IF ((reply->context_more_data="F"))
  FREE SET context
 ENDIF
 IF (cnt=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  ea.encntr_id, frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM (dummyt d1  WITH seq = value(size(reply->qual,5))),
   encntr_alias ea,
   encounter e
  PLAN (d1
   WHERE (reply->qual[d1.seq].encntr_id > 0))
   JOIN (e
   WHERE (reply->qual[d1.seq].encntr_id=e.encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ((e.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (e.end_effective_dt_tm=null)) )
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY d1.seq
  DETAIL
   reply->qual[d1.seq].person_num = frmt_mrn
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id
  FROM (dummyt d1  WITH seq = value(size(reply->qual,5))),
   long_text lt
  PLAN (d1
   WHERE (reply->qual[d1.seq].case_comment_long_text_id > 0))
   JOIN (lt
   WHERE (reply->qual[d1.seq].case_comment_long_text_id=lt.long_text_id))
  DETAIL
   reply->qual[d1.seq].case_comment = trim(lt.long_text)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id, reply->qual[d1.seq].accession_nbr, lt.long_text
  FROM (dummyt d1  WITH seq = value(size(reply->qual,5))),
   (dummyt d2  WITH seq = value(max_rpt_cnt)),
   long_text lt,
   report_task rt
  PLAN (d1
   WHERE (reply->qual[d1.seq].case_id > 0))
   JOIN (d2
   WHERE (d2.seq <= reply->qual[d1.seq].rpt_cnt))
   JOIN (rt
   WHERE (reply->qual[d1.seq].rpt_qual[d2.seq].report_id=rt.report_id)
    AND rt.comments_long_text_id > 0)
   JOIN (lt
   WHERE rt.comments_long_text_id=lt.long_text_id)
  DETAIL
   reply->qual[d1.seq].rpt_qual[d2.seq].comment_long_text_id = lt.long_text_id, reply->qual[d1.seq].
   rpt_qual[d2.seq].comment = lt.long_text
  WITH nocounter
 ;end select
 IF (giveme_canceled=1)
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
    prsnl p
   PLAN (d
    WHERE (reply->qual[d.seq].pc_cancel_id > 0))
    JOIN (p
    WHERE (reply->qual[d.seq].pc_cancel_id=p.person_id))
   DETAIL
    reply->qual[d.seq].pc_cancel_name = p.name_full_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
    prsnl p
   PLAN (d
    WHERE (reply->qual[d.seq].case_received_by_id > 0))
    JOIN (p
    WHERE (reply->qual[d.seq].case_received_by_id=p.person_id))
   DETAIL
    reply->qual[d.seq].case_received_by_name = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
   prsnl p
  PLAN (d
   WHERE (reply->qual[d.seq].responsible_pathologist_id > 0))
   JOIN (p
   WHERE (reply->qual[d.seq].responsible_pathologist_id=p.person_id))
  DETAIL
   reply->qual[d.seq].responsible_pathologist_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
   prsnl p
  PLAN (d
   WHERE (reply->qual[d.seq].responsible_resident_id > 0))
   JOIN (p
   WHERE (reply->qual[d.seq].responsible_resident_id=p.person_id))
  DETAIL
   reply->qual[d.seq].responsible_resident_name = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (size(reply->qual,5) > 0)
  IF ((reply->status_data.status="S"))
   EXECUTE pcs_fill_ext_accs_by_acc  WITH replace("REQUESTREPLY","REPLY")
   IF ((reply->status_data.status="Z"))
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
#exit_script
END GO
