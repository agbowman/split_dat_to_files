CREATE PROGRAM bbt_get_ssn_mrn_sex:dba
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
   1 ssn_alias = vc
   1 mrn_alias = vc
   1 sex_cd = f8
   1 sex_disp = c40
   1 age = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET ssn_cd = 0.0
 SET mrn_cd = 0.0
 SET reply->status_data.status = "F"
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "SSN"
 SET stat = uar_get_meaning_by_codeset(4,cdf_meaning,1,ssn_cd)
 IF (stat=1)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to find ssn and mrn meanings"
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "MRN"
 SET stat = uar_get_meaning_by_codeset(4,cdf_meaning,1,mrn_cd)
 IF (stat=1)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to find ssn and mrn meanings"
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pa.alias, p.sex_cd, p.person_id,
  pa.person_id
  FROM person p,
   dummyt d1,
   person_alias pa
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND ((pa.person_alias_type_cd=ssn_cd) OR (pa.person_alias_type_cd=mrn_cd)) )
  HEAD REPORT
   reply->sex_cd = p.sex_cd, reply->age = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE")
  DETAIL
   IF (pa.person_alias_type_cd=ssn_cd)
    reply->ssn_alias = pa.alias
   ENDIF
   IF (pa.person_alias_type_cd=mrn_cd)
    reply->mrn_alias = pa.alias
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "PERSON AND PERSON_ALIAS"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "unable to alias"
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
