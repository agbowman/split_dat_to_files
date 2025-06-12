CREATE PROGRAM aps_get_inquiry2:dba
 DECLARE initresourcesecurity(resource_security_ind=i2) = null
 DECLARE isresourceviewable(service_resource_cd=f8) = i2
 DECLARE getresourcesecuritystatus(fail_all_ind=i2) = c1
 DECLARE populateressecstatusblock(message_type=i2) = null
 DECLARE istaskgranted(task_number=i4) = i2
 DECLARE nres_sec_failed = i2 WITH protect, constant(0)
 DECLARE nres_sec_passed = i2 WITH protect, constant(1)
 DECLARE nres_sec_msg_type = i2 WITH protect, constant(0)
 DECLARE ncase_sec_msg_type = i2 WITH protect, constant(1)
 DECLARE sres_sec_error_msg = c23 WITH protect, constant("RESOURCE SECURITY ERROR")
 DECLARE sres_sec_failed_msg = c24 WITH protect, constant("RESOURCE SECURITY FAILED")
 DECLARE scase_sec_failed_msg = c20 WITH protect, constant("CASE SECURITY FAILED")
 DECLARE m_nressecind = i2 WITH protect, noconstant(0)
 DECLARE m_sressecstatus = c1 WITH protect, noconstant("S")
 DECLARE m_nressecuarstatus = i2 WITH protect, noconstant(0)
 DECLARE m_nressecerrorind = i2 WITH protect, noconstant(0)
 DECLARE m_lressecfailedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_lresseccheckedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_nressecalterstatus = i2 WITH protect, noconstant(0)
 DECLARE m_lressecstatusblockcnt = i4 WITH protect, noconstant(0)
 DECLARE m_ntaskgrantedind = i2 WITH protect, noconstant(0)
 DECLARE m_sfailedmsg = c25 WITH protect, noconstant
 EXECUTE cpmsrsrtl
 SUBROUTINE initresourcesecurity(resource_security_ind)
   IF (resource_security_ind=1)
    SET m_nressecind = true
   ELSE
    SET m_nressecind = false
   ENDIF
 END ;Subroutine
 SUBROUTINE isresourceviewable(service_resource_cd)
   SET m_lresseccheckedcnt = (m_lresseccheckedcnt+ 1)
   IF (m_nressecind=false)
    RETURN(true)
   ENDIF
   IF (m_nressecerrorind=true)
    RETURN(false)
   ENDIF
   IF (service_resource_cd=0)
    RETURN(true)
   ENDIF
   SET m_nressecuarstatus = uar_srsprsnlhasaccess(reqinfo->updt_id,reqinfo->position_cd,
    service_resource_cd)
   CASE (m_nressecuarstatus)
    OF nres_sec_passed:
     RETURN(true)
    OF nres_sec_failed:
     SET m_lressecfailedcnt = (m_lressecfailedcnt+ 1)
     RETURN(false)
    ELSE
     SET m_nressecerrorind = true
     RETURN(false)
   ENDCASE
 END ;Subroutine
 SUBROUTINE getresourcesecuritystatus(fail_all_ind)
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
 SUBROUTINE populateressecstatusblock(message_type)
   IF (((m_sressecstatus="S") OR (validate(reply->status_data.status,"-1")="-1")) )
    RETURN
   ENDIF
   SET m_lressecstatusblockcnt = size(reply->status_data.subeventstatus,5)
   IF (m_lressecstatusblockcnt=1
    AND trim(reply->status_data.subeventstatus[1].operationname)="")
    SET m_ressecalterstatus = 0
   ELSE
    SET m_lressecstatusblockcnt = (m_lressecstatusblockcnt+ 1)
    SET m_nressecalterstatus = alter(reply->status_data.subeventstatus,m_lressecstatusblockcnt)
   ENDIF
   CASE (message_type)
    OF ncase_sec_msg_type:
     SET m_sfailedmsg = scase_sec_failed_msg
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
 SUBROUTINE istaskgranted(task_number)
   SET m_ntaskgrantedind = false
   SELECT INTO "nl:"
    FROM application_group ag,
     task_access ta
    PLAN (ag
     WHERE (ag.position_cd=reqinfo->position_cd)
      AND ag.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ag.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
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
 DECLARE formatage(birth_dt_tm=f8,deceased_dt_tm=f8,policy=vc) = vc WITH protect
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
 SUBROUTINE formatage(birth_dt_tm,deceased_dt_tm,policy)
   DECLARE eff_end_dt_tm = f8 WITH private, noconstant(0.0)
   SET eff_end_dt_tm = deceased_dt_tm
   IF (((eff_end_dt_tm=null) OR (eff_end_dt_tm=0.00)) )
    SET eff_end_dt_tm = cnvtdatetime(curdate,curtime3)
   ENDIF
   IF (((birth_dt_tm > eff_end_dt_tm) OR (birth_dt_tm=null)) )
    RETURN(sunknownstring)
   ELSEIF (birth_dt_tm=deceased_dt_tm)
    RETURN(sstillbornstring)
   ELSE
    RETURN(cnvtage2(birth_dt_tm,eff_end_dt_tm,0,concat(policy,"/",trim(susername),"/",cnvtstring(
       reqinfo->position_cd))))
   ENDIF
 END ;Subroutine
 DECLARE max_rpt_cnt = i4 WITH protect, noconstant(0)
 RANGE OF cp IS case_provider
 RANGE OF cs1 IS case_specimen
 SET cnt = 0
 SET mrn_alias_type_cd = 0.0
 SET rpt_cnt = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=319
   AND cv.cdf_meaning="MRN"
  HEAD REPORT
   mrn_alias_type_cd = 0.0
  DETAIL
   mrn_alias_type_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL initresourcesecurity(1)
 SELECT
  IF ((context->patient_defined="T")
   AND (context->provider_defined="T")
   AND (context->specimen_defined="T"))
   PLAN (p
    WHERE  $1)
    JOIN (pc
    WHERE  $2
     AND  $3)
    JOIN (ap
    WHERE pc.prefix_id=ap.prefix_id)
    JOIN (cs1
    WHERE  $4
     AND parser(cs1_cancel_where))
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (((d1
    WHERE 1=d1.seq)
    JOIN (cs
    WHERE pc.case_id=cs.case_id
     AND parser(cs_cancel_where))
    JOIN (t
    WHERE cs.specimen_tag_id=t.tag_id)
    ) ORJOIN ((d2
    WHERE 1=d2.seq)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND parser(cr_cancel_where))
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    ))
  ELSEIF ((context->patient_defined="T")
   AND (context->specimen_defined="T"))
   PLAN (p
    WHERE  $1)
    JOIN (pc
    WHERE  $2)
    JOIN (ap
    WHERE pc.prefix_id=ap.prefix_id)
    JOIN (cs1
    WHERE  $4
     AND parser(cs1_cancel_where))
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (((d1
    WHERE 1=d1.seq)
    JOIN (cs
    WHERE pc.case_id=cs.case_id
     AND parser(cs_cancel_where))
    JOIN (t
    WHERE cs.specimen_tag_id=t.tag_id)
    ) ORJOIN ((d2
    WHERE 1=d2.seq)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND parser(cr_cancel_where))
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    ))
  ELSEIF ((context->case_defined="T")
   AND (context->provider_defined="T")
   AND (context->specimen_defined="T"))
   PLAN (pc
    WHERE  $2
     AND  $3)
    JOIN (ap
    WHERE pc.prefix_id=ap.prefix_id)
    JOIN (cs1
    WHERE  $4
     AND parser(cs1_cancel_where))
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (((d1
    WHERE 1=d1.seq)
    JOIN (cs
    WHERE pc.case_id=cs.case_id
     AND parser(cs_cancel_where))
    JOIN (t
    WHERE cs.specimen_tag_id=t.tag_id)
    ) ORJOIN ((d2
    WHERE 1=d2.seq)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND parser(cr_cancel_where))
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    ))
  ELSEIF ((context->case_defined="T")
   AND (context->specimen_defined="T"))
   PLAN (pc
    WHERE  $2)
    JOIN (ap
    WHERE pc.prefix_id=ap.prefix_id)
    JOIN (cs1
    WHERE  $4
     AND parser(cs1_cancel_where))
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (((d1
    WHERE 1=d1.seq)
    JOIN (cs
    WHERE pc.case_id=cs.case_id
     AND parser(cs_cancel_where))
    JOIN (t
    WHERE cs.specimen_tag_id=t.tag_id)
    ) ORJOIN ((d2
    WHERE 1=d2.seq)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND parser(cr_cancel_where))
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    ))
  ELSEIF ((context->provider_defined="T")
   AND (context->specimen_defined="T"))
   PLAN (pc
    WHERE parser(pc_cancel_where)
     AND pc.reserved_ind != 1
     AND  $3)
    JOIN (ap
    WHERE pc.prefix_id=ap.prefix_id)
    JOIN (cs1
    WHERE  $4
     AND parser(cs1_cancel_where))
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (((d1
    WHERE 1=d1.seq)
    JOIN (cs
    WHERE pc.case_id=cs.case_id
     AND parser(cs_cancel_where))
    JOIN (t
    WHERE cs.specimen_tag_id=t.tag_id)
    ) ORJOIN ((d2
    WHERE 1=d2.seq)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND parser(cr_cancel_where))
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    ))
  ELSEIF ((context->patient_defined="T")
   AND (context->provider_defined="T"))
   PLAN (p
    WHERE  $1)
    JOIN (pc
    WHERE  $2
     AND  $3)
    JOIN (ap
    WHERE pc.prefix_id=ap.prefix_id)
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (((d1
    WHERE 1=d1.seq)
    JOIN (cs
    WHERE pc.case_id=cs.case_id
     AND parser(cs_cancel_where))
    JOIN (t
    WHERE cs.specimen_tag_id=t.tag_id)
    ) ORJOIN ((d2
    WHERE 1=d2.seq)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND parser(cr_cancel_where))
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    ))
  ELSEIF ((context->patient_defined="T"))
   PLAN (p
    WHERE  $1)
    JOIN (pc
    WHERE  $2)
    JOIN (ap
    WHERE pc.prefix_id=ap.prefix_id)
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (((d1
    WHERE 1=d1.seq)
    JOIN (cs
    WHERE pc.case_id=cs.case_id
     AND parser(cs_cancel_where))
    JOIN (t
    WHERE cs.specimen_tag_id=t.tag_id)
    ) ORJOIN ((d2
    WHERE 1=d2.seq)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND parser(cr_cancel_where))
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    ))
  ELSEIF ((context->case_defined="T")
   AND (context->provider_defined="T"))
   PLAN (pc
    WHERE  $2
     AND  $3)
    JOIN (ap
    WHERE pc.prefix_id=ap.prefix_id)
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (((d1
    WHERE 1=d1.seq)
    JOIN (cs
    WHERE pc.case_id=cs.case_id
     AND parser(cs_cancel_where))
    JOIN (t
    WHERE cs.specimen_tag_id=t.tag_id)
    ) ORJOIN ((d2
    WHERE 1=d2.seq)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND parser(cr_cancel_where))
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    ))
  ELSEIF ((context->case_defined="T"))
   PLAN (pc
    WHERE  $2)
    JOIN (ap
    WHERE pc.prefix_id=ap.prefix_id)
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (((d1
    WHERE 1=d1.seq)
    JOIN (cs
    WHERE pc.case_id=cs.case_id
     AND parser(cs_cancel_where))
    JOIN (t
    WHERE cs.specimen_tag_id=t.tag_id)
    ) ORJOIN ((d2
    WHERE 1=d2.seq)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND parser(cr_cancel_where))
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    ))
  ELSEIF ((context->provider_defined="T"))
   PLAN (pc
    WHERE parser(pc_cancel_where)
     AND pc.reserved_ind != 1
     AND  $3)
    JOIN (ap
    WHERE pc.prefix_id=ap.prefix_id)
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (((d1
    WHERE 1=d1.seq)
    JOIN (cs
    WHERE pc.case_id=cs.case_id
     AND parser(cs_cancel_where))
    JOIN (t
    WHERE cs.specimen_tag_id=t.tag_id)
    ) ORJOIN ((d2
    WHERE 1=d2.seq)
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND parser(cr_cancel_where))
    JOIN (sd
    WHERE cr.catalog_cd=sd.catalog_cd)
    ))
  ELSE
  ENDIF
  INTO "nl:"
  pc.case_id, pc.accession_nbr, join_path = decode(d1.seq,"S","R"),
  t.tag_group_id, t.tag_sequence
  FROM person p,
   pathology_case pc,
   ap_prefix ap,
   prsnl pr,
   (dummyt d1  WITH seq = 1),
   case_specimen cs,
   ap_tag t,
   (dummyt d2  WITH seq = 1),
   case_report cr,
   service_directory sd
  ORDER BY pc.accession_nbr DESC, cr.report_sequence, sd.short_description,
   t.tag_group_id, t.tag_sequence
  HEAD REPORT
   cnt = 0, reply->context_more_data = "F", service_resource_cd = 0.0,
   access_to_resource_ind = 0
  HEAD pc.accession_nbr
   service_resource_cd = ap.service_resource_cd, access_to_resource_ind = 0
   IF (isresourceviewable(service_resource_cd)=true)
    access_to_resource_ind = 1, cnt = (cnt+ 1)
    IF ((cnt < (maxqualrows+ 1)))
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
     responsible_resident_id = pc.responsible_resident_id, reply->qual[cnt].age = formatage(p
      .birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"),
     reply->qual[cnt].birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->qual[cnt].birth_tz = validate
     (p.birth_tz,0)
     IF (nullind(p.deceased_dt_tm)=0)
      reply->qual[cnt].deceased_dt_tm = cnvtdatetime(p.deceased_dt_tm)
     ELSE
      reply->qual[cnt].deceased_dt_tm = 0
     ENDIF
    ENDIF
    IF ((cnt=(maxqualrows+ 1)))
     reply->context_more_data = "T", context->accession_nbr = pc.accession_nbr, context->context_ind
      = 1,
     context->maxqual = maxqualrows
    ENDIF
   ENDIF
  DETAIL
   IF (access_to_resource_ind=1)
    IF ((cnt < (maxqualrows+ 1)))
     CASE (join_path)
      OF "S":
       spec_cnt = (spec_cnt+ 1),
       IF (mod(spec_cnt,5)=1
        AND spec_cnt != 1)
        stat = alterlist(reply->qual[cnt].spec_qual,(spec_cnt+ 4))
       ENDIF
       ,reply->qual[cnt].spec_cnt = spec_cnt,reply->qual[cnt].spec_qual[spec_cnt].case_specimen_id =
       cs.case_specimen_id,reply->qual[cnt].spec_qual[spec_cnt].specimen_tag_group_cd = t
       .tag_group_id,
       reply->qual[cnt].spec_qual[spec_cnt].specimen_tag_sequence = t.tag_sequence,reply->qual[cnt].
       spec_qual[spec_cnt].specimen_tag_display = t.tag_disp,reply->qual[cnt].spec_qual[spec_cnt].
       specimen_tag_cd = cs.specimen_tag_id,
       reply->qual[cnt].spec_qual[spec_cnt].specimen_description = trim(cs.specimen_description),
       reply->qual[cnt].spec_qual[spec_cnt].specimen_cd = cs.specimen_cd
      OF "R":
       rpt_cnt = (rpt_cnt+ 1),
       IF (mod(rpt_cnt,5)=1
        AND rpt_cnt != 1)
        stat = alterlist(reply->qual[cnt].rpt_qual,(rpt_cnt+ 4))
       ENDIF
       ,reply->qual[cnt].rpt_cnt = rpt_cnt,reply->qual[cnt].rpt_qual[rpt_cnt].report_id = cr
       .report_id,reply->qual[cnt].rpt_qual[rpt_cnt].blob_bitmap = cr.blob_bitmap,
       reply->qual[cnt].rpt_qual[rpt_cnt].report_sequence = cr.report_sequence,reply->qual[cnt].
       rpt_qual[rpt_cnt].catalog_cd = cr.catalog_cd,reply->qual[cnt].rpt_qual[rpt_cnt].
       short_description = sd.short_description,
       reply->qual[cnt].rpt_qual[rpt_cnt].long_description = sd.description,reply->qual[cnt].
       rpt_qual[rpt_cnt].event_id = cr.event_id,reply->qual[cnt].rpt_qual[rpt_cnt].status_cd = cr
       .status_cd
     ENDCASE
    ENDIF
   ENDIF
  FOOT  pc.accession_nbr
   IF (access_to_resource_ind=1)
    IF ((cnt < (maxqualrows+ 1)))
     stat = alterlist(reply->qual[cnt].spec_qual,spec_cnt), stat = alterlist(reply->qual[cnt].
      rpt_qual,rpt_cnt)
     IF (rpt_cnt > max_rpt_cnt)
      max_rpt_cnt = rpt_cnt
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(1)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (cnt <= maxqualrows)
  SET stat = alter(reply->qual,cnt)
 ELSE
  SET stat = alter(reply->qual,maxqualrows)
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
    AND e.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ((e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (e.end_effective_dt_tm=null)) )
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
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
   WHERE (reply->qual[d1.seq].rpt_qual[d2.seq].report_id=rt.report_id))
   JOIN (lt
   WHERE rt.comments_long_text_id=lt.long_text_id)
  DETAIL
   IF (rt.comments_long_text_id > 0)
    reply->qual[d1.seq].rpt_qual[d2.seq].comment_long_text_id = lt.long_text_id, reply->qual[d1.seq].
    rpt_qual[d2.seq].comment = lt.long_text
   ENDIF
   reply->qual[d1.seq].rpt_qual[d2.seq].order_id = rt.order_id
  WITH nocounter
 ;end select
 IF ((context->retrieve_canceled_ind=1))
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
 IF ((context->context_ind=0))
  FREE SET context
 ENDIF
 IF (size(reply->qual,5) > 0)
  IF ((reply->status_data.status="S"))
   EXECUTE pcs_fill_ext_accs_by_acc  WITH replace("REQUESTREPLY","REPLY")
   IF ((reply->status_data.status="Z"))
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
END GO
