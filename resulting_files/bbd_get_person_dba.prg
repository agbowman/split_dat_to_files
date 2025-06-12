CREATE PROGRAM bbd_get_person:dba
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
 RECORD reply(
   1 updt_cnt = i4
   1 person_type_cd = f8
   1 person_type_cd_disp = vc
   1 name_last_key = vc
   1 name_first_key = vc
   1 name_full_formatted = vc
   1 birth_dt_cd = f8
   1 birth_dt_cd_disp = vc
   1 birth_dt_tm = di8
   1 age = vc
   1 conception_dt_tm = di8
   1 ethnic_group_cd = f8
   1 ethnic_group_cd_disp = vc
   1 language_cd = f8
   1 language_cd_disp = vc
   1 marital_type_cd = f8
   1 marital_type_cd_disp = vc
   1 race_cd = f8
   1 race_cd_disp = vc
   1 religion_cd = f8
   1 religion_cd_disp = vc
   1 gender_cd = f8
   1 gender_cd_disp = vc
   1 name_last = vc
   1 name_first = vc
   1 last_encounter_dt_tm = di8
   1 species_cd = f8
   1 species_cd_disp = vc
   1 mothers_maiden_name = vc
   1 nationality_cd = f8
   1 nationality_cd_disp = vc
   1 name_middle_key = vc
   1 name_middle = vc
   1 birth_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.*
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
    AND p.active_ind=1)
  DETAIL
   reply->updt_cnt = p.updt_cnt, reply->person_type_cd = p.person_type_cd, reply->name_last_key = p
   .name_last_key,
   reply->name_first_key = p.name_first_key, reply->name_full_formatted = p.name_full_formatted,
   reply->birth_dt_cd = p.birth_dt_cd,
   reply->birth_dt_tm = p.birth_dt_tm, reply->age = formatage(p.birth_dt_tm,p.deceased_dt_tm,
    "CHRONOAGE"), reply->conception_dt_tm = p.conception_dt_tm,
   reply->ethnic_group_cd = p.ethnic_grp_cd, reply->language_cd = p.language_cd, reply->
   marital_type_cd = p.marital_type_cd,
   reply->race_cd = p.race_cd, reply->religion_cd = p.religion_cd, reply->gender_cd = p.sex_cd,
   reply->name_last = p.name_last, reply->name_first = p.name_first, reply->last_encounter_dt_tm = p
   .last_encntr_dt_tm,
   reply->species_cd = p.species_cd, reply->mothers_maiden_name = p.mother_maiden_name, reply->
   nationality_cd = p.nationality_cd,
   reply->name_middle_key = p.name_middle_key, reply->name_middle = p.name_middle, reply->birth_tz =
   p.birth_tz
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
