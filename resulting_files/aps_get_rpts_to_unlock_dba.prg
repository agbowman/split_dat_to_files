CREATE PROGRAM aps_get_rpts_to_unlock:dba
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
    RETURN(cnvtage2(birth_dt_tm,eff_end_dt_tm,0,concat(policy,"/",trim(susername),"/",trim(cnvtstring
       (reqinfo->position_cd,32,2)))))
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 person_name = vc
   1 person_num = c16
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 deceased_dt_tm = dq8
   1 age = vc
   1 sex_cd = f8
   1 sex_disp = c40
   1 rpt_cnt = i2
   1 rpt_qual[1]
     2 report_id = f8
     2 report_sequence = i4
     2 short_description = c50
     2 editing_name = vc
     2 editing_dt_tm = dq8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET max_rpt_cnt = 1
 SET mrn_alias_type_cd = 0.0
 DECLARE p_person_id = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=319
   AND cv.cdf_meaning="MRN"
   AND cv.active_ind=1
  HEAD REPORT
   mrn_alias_type_cd = 0.0
  DETAIL
   mrn_alias_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pc.case_id, p.person_id, ea.alias,
  rt.report_id, sd.short_description, pl.name_full_formatted
  FROM case_report cr,
   pathology_case pc,
   person p,
   prsnl pl,
   report_task rt,
   service_directory sd
  PLAN (pc
   WHERE (pc.accession_nbr=request->accession_nbr))
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (cr
   WHERE pc.case_id=cr.case_id)
   JOIN (rt
   WHERE cr.report_id=rt.report_id
    AND  NOT (rt.editing_prsnl_id IN (null, 0)))
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   JOIN (pl
   WHERE rt.editing_prsnl_id=pl.person_id)
  HEAD REPORT
   rpt_cnt = 0, reply->person_name = p.name_full_formatted, reply->sex_cd = p.sex_cd,
   reply->age = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"), reply->birth_dt_tm = p
   .birth_dt_tm, reply->birth_tz = validate(p.birth_tz,0),
   reply->deceased_dt_tm = p.deceased_dt_tm, p_person_id = p.person_id
  DETAIL
   rpt_cnt = (rpt_cnt+ 1)
   IF (rpt_cnt > max_rpt_cnt)
    stat = alter(reply->rpt_qual,rpt_cnt), max_rpt_cnt = rpt_cnt
   ENDIF
   reply->rpt_cnt = rpt_cnt, reply->rpt_qual[rpt_cnt].report_id = rt.report_id, reply->rpt_qual[
   rpt_cnt].report_sequence = cr.report_sequence,
   reply->rpt_qual[rpt_cnt].short_description = sd.short_description, reply->rpt_qual[rpt_cnt].
   editing_name = pl.name_full_formatted, reply->rpt_qual[rpt_cnt].editing_dt_tm = rt.editing_dt_tm,
   reply->rpt_qual[rpt_cnt].updt_cnt = rt.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_TO_UNLOCK"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM pathology_case pc,
   encntr_alias ea
  PLAN (pc
   WHERE (pc.accession_nbr=request->accession_nbr))
   JOIN (ea
   WHERE ea.encntr_id=pc.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   reply->person_num = frmt_mrn
  WITH nocounter
 ;end select
 SET modify = hipaa
 EXECUTE cclaudit 0, "Access Person", "Demographics",
 "Person", "Patient", "Patient Number",
 "Access/Use", p_person_id, ""
END GO
