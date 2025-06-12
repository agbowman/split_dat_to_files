CREATE PROGRAM aps_get_person_info:dba
 DECLARE epr_admit_doc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"ADMITDOC")), protect
 DECLARE epr_attend_doc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC")), protect
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
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 IF ((validate(reply->sex_cd,- (1))=- (1)))
  RECORD reply(
    1 patient_name = vc
    1 primary_alias = vc
    1 birth_dt_tm = dq8
    1 birth_tz = i4
    1 deceased_dt_tm = dq8
    1 age = vc
    1 sex_cd = f8
    1 sex_disp = c40
    1 organization_id = f8
    1 organization = vc
    1 location_cd = f8
    1 location_disp = c40
    1 loc_facility_cd = f8
    1 loc_facility_disp = c40
    1 loc_building_cd = f8
    1 loc_building_disp = c40
    1 loc_nurse_unit_cd = f8
    1 loc_nurse_unit_disp = c40
    1 loc_room_cd = f8
    1 loc_room_disp = c40
    1 loc_bed_cd = f8
    1 loc_bed_disp = c40
    1 admit_doc = vc
    1 admit_doc_id = f8
    1 facility_accn_prefix_cd = f8
    1 ft_ind = i2
    1 open_cases_ind = i2
    1 attend_doc = vc
    1 attend_doc_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET reply->status_data.status = "F"
 ENDIF
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM person p
  WHERE (p.person_id=request->person_id)
   AND p.active_ind=1
  DETAIL
   reply->patient_name = p.name_full_formatted
   IF (validate(reply->age,"N") != "N")
    reply->age = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE")
   ENDIF
   reply->birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->birth_tz = validate(p.birth_tz,0), reply
   ->deceased_dt_tm = cnvtdatetime(p.deceased_dt_tm),
   reply->sex_cd = p.sex_cd
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PERSON"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e,
   location l,
   organization o,
   (dummyt d1  WITH seq = 1)
  PLAN (e
   WHERE (e.encntr_id=request->encounter_id)
    AND (e.person_id=request->person_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND e.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (l
   WHERE e.loc_facility_cd=l.location_cd)
   JOIN (d1)
   JOIN (o
   WHERE o.organization_id=e.organization_id)
  DETAIL
   reply->location_cd = e.location_cd, reply->loc_facility_cd = e.loc_facility_cd, reply->
   loc_building_cd = e.loc_building_cd,
   reply->loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply->loc_room_cd = e.loc_room_cd, reply->
   loc_bed_cd = e.loc_bed_cd,
   reply->facility_accn_prefix_cd = l.facility_accn_prefix_cd
   IF (o.organization_id != 0.0)
    reply->organization_id = o.organization_id, reply->organization = o.org_name
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  e.encntr_id, frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), p.name_full_formatted,
  ea.alias
  FROM person p,
   encounter e,
   encntr_alias ea
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
   JOIN (e
   WHERE e.person_id=p.person_id
    AND (e.encntr_id=request->encounter_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND e.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   reply->primary_alias = frmt_mrn
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  epr.prsnl_person_id, p.person_id
  FROM encntr_prsnl_reltn epr,
   prsnl p
  PLAN (epr
   WHERE (epr.encntr_id=request->encounter_id)
    AND epr.encntr_prsnl_r_cd=epr_admit_doc_cd
    AND epr.active_ind=1
    AND epr.manual_create_ind IN (0, null)
    AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  DETAIL
   reply->admit_doc = p.name_full_formatted, reply->admit_doc_id = p.person_id
  WITH nocounter
 ;end select
 IF (epr_attend_doc_cd > 0.0)
  SELECT INTO "nl:"
   epr.prsnl_person_id, p.person_id
   FROM encntr_prsnl_reltn epr,
    prsnl p
   PLAN (epr
    WHERE (epr.encntr_id=request->encounter_id)
     AND epr.encntr_prsnl_r_cd=epr_attend_doc_cd
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=epr.prsnl_person_id)
   DETAIL
    reply->attend_doc = p.name_full_formatted, reply->attend_doc_id = p.person_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((validate(request->get_ft_and_oc_alerts_ind,- (1)) != - (1)))
  IF ((reply->status_data.status="S")
   AND (request->get_ft_and_oc_alerts_ind=1))
   EXECUTE aps_get_ft_and_oc_alerts
  ENDIF
 ENDIF
END GO
