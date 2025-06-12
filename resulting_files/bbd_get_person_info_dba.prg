CREATE PROGRAM bbd_get_person_info:dba
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
   1 name_full_formatted = c100
   1 birth_dt_tm = dq8
   1 sex_disp = c40
   1 formatted_ssn = vc
   1 formatted_mrn = vc
   1 abo_disp = c15
   1 rh_disp = c15
   1 abo_cd = f8
   1 rh_cd = f8
   1 diagnosis = vc
   1 age = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply_formatted_alias = fillstring(30," ")
 SET alias_ssn = fillstring(30," ")
 SET alias_mrn = fillstring(50," ")
 SET ssn_format_cd = 0
 SET mrn_format_cd = 0
 SET reply->status_data.status = "I"
 SET code_cnt = 1
 SET code_value = 0.0
 SET stat = uar_get_meaning_by_codeset(4,"SSN",code_cnt,code_value)
 IF (code_value=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_get_person_info"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 4 and SSN"
  GO TO exit_script
 ENDIF
 SET ssn_format_cd = code_value
 SET code_cnt = 1
 SET code_value = 0.0
 SET stat = uar_get_meaning_by_codeset(4,"MRN",code_cnt,code_value)
 IF (code_value=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_get_person_info"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 4 and MRN"
  GO TO exit_script
 ENDIF
 SET mrn_format_cd = code_value
 SELECT INTO "nl:"
  p.*
  FROM person p
  WHERE (p.person_id=request->person_id)
  DETAIL
   reply->name_full_formatted = p.name_full_formatted, reply->birth_dt_tm = p.birth_dt_tm, reply->age
    = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE"),
   reply->sex_disp = uar_get_code_display(p.sex_cd)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PERSON"
  GO TO exit_program
 ENDIF
 SET meaning_cd = 0
 SELECT INTO "nl:"
  p.seq
  FROM person_alias p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.person_alias_type_cd=ssn_format_cd
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   alias_ssn = p.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  new_alias = trim(cnvtalias(p.alias,p.alias_pool_cd))
  FROM person_alias p
  WHERE (p.person_id=request->person_id)
   AND p.alias=alias_ssn
   AND p.person_alias_type_cd=ssn_format_cd
  DETAIL
   reply->formatted_ssn = new_alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.*
  FROM person_aborh p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
  DETAIL
   reply->abo_cd = p.abo_cd, reply->abo_disp = uar_get_code_display(p.abo_cd), reply->rh_cd = p.rh_cd,
   reply->rh_disp = uar_get_code_display(p.rh_cd)
  WITH counter
 ;end select
 IF (curqual=0)
  SET reply->abo_cd = 0
  SET reply->rh_cd = 0
 ENDIF
 SET meaning_cd = 0
 SELECT INTO "nl:"
  p.seq
  FROM person_alias p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.person_alias_type_cd=mrn_format_cd
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   alias_mrn = p.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  new_alias = trim(cnvtalias(p.alias,p.alias_pool_cd))
  FROM person_alias p
  WHERE (p.person_id=request->person_id)
   AND p.alias=alias_mrn
   AND p.person_alias_type_cd=mrn_format_cd
  DETAIL
   reply->formatted_mrn = new_alias
  WITH nocounter
 ;end select
#exit_program
 IF ((reply->status_data.status="I"))
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
