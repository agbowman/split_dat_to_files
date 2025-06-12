CREATE PROGRAM aps_get_person:dba
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
 RECORD reply(
   1 name_full_formatted = vc
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 deceased_dt_tm = dq8
   1 age = vc
   1 sex_cd = f8
   1 sex_disp = c40
   1 race_cd = f8
   1 race_disp = c40
   1 species_cd = f8
   1 species_disp = c40
   1 person_other_name = vc
   1 abo_cd = f8
   1 abo_disp = c40
   1 rh_cd = f8
   1 rh_disp = c40
   1 person_alias[*]
     2 person_alias_type_cd = f8
     2 alias = vc
     2 alias_pool_cd = f8
     2 person_alias_type_disp = c40
     2 person_alias_type_desc = vc
   1 encntr_type_cd = f8
   1 encntr_type_disp = c40
   1 fin_class_cd = f8
   1 fin_class_disp = c40
   1 reg_dt_tm = dq8
   1 disch_dt_tm = dq8
   1 organization_name = vc
   1 organization_id = f8
   1 loc_facility_cd = f8
   1 loc_facility_disp = c40
   1 admit_doc = vc
   1 attending_doc = vc
   1 encntr_alias[*]
     2 encntr_alias_type_cd = f8
     2 encntr_alias_type_disp = c40
     2 encntr_alias_type_desc = vc
     2 alias = vc
   1 race_list[*]
     2 race_cd = f8
     2 race_list_disp = c40
   1 birth_sex_cd = f8
   1 birth_sex_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE dshin = f8 WITH protect, noconstant(0.0)
 SET dshin = uar_get_code_by("MEANING",4,"SHIN")
 DECLARE dmaiden = f8 WITH protect, noconstant(0.0)
 SET dmaiden = uar_get_code_by("MEANING",213,"MAIDEN")
 DECLARE dadmitdoc = f8 WITH protect, noconstant(0.0)
 SET dadmitdoc = uar_get_code_by("MEANING",333,"ADMITDOC")
 DECLARE dattenddoc = f8 WITH protect, noconstant(0.0)
 SET dattenddoc = uar_get_code_by("MEANING",333,"ATTENDDOC")
 DECLARE dnmdpcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"NMDP"))
 DECLARE dunoscd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"UNOS"))
 DECLARE dhicrcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"HICR"))
 DECLARE dintldcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"INTLD"))
 DECLARE dnmdpdcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"NMDPD"))
 DECLARE dopodcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"OPOD"))
 DECLARE doporcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"OPOR"))
 DECLARE dunosdcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"UNOSD"))
 DECLARE dnmdprcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"NMDPR"))
 DECLARE dracemultiplecd = f8 WITH protect, constant(uar_get_code_by("MEANING",282,"MULTIPLE"))
 DECLARE ncount = i2 WITH protect, noconstant(0)
 DECLARE npersonaliasqualsize = i2 WITH protect, noconstant(0)
 DECLARE sdescription = vc WITH protect, noconstant("")
 DECLARE smnem_on_or_off = vc WITH protect, noconstant("")
 DECLARE shealthcardvercd = vc WITH protect, noconstant("")
 DECLARE li18nhandle = i4 WITH noconstant(uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev))
 DECLARE sphnaliasdisp = vc WITH noconstant(uar_i18ngetmessage(i18nhandle,"PHN_KEY","PHN"))
 SELECT INTO "nl:"
  p.name_full_formatted, p.birth_dt_tm, p.race_cd,
  p.sex_cd
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   reply->name_full_formatted = p.name_full_formatted, reply->age = formatage(p.birth_dt_tm,p
    .deceased_dt_tm,"CHRONOAGE"), reply->birth_dt_tm = p.birth_dt_tm,
   reply->birth_tz = validate(p.birth_tz,0), reply->deceased_dt_tm = p.deceased_dt_tm, reply->race_cd
    = p.race_cd,
   reply->sex_cd = p.sex_cd, reply->species_cd = p.species_cd
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PERSON"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  pp.birth_sex_cd
  FROM person_patient pp
  PLAN (pp
   WHERE (pp.person_id=request->person_id)
    AND pp.active_ind=1
    AND pp.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pp.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   reply->birth_sex_cd = pp.birth_sex_cd
  WITH nocounter
 ;end select
 IF ((reply->race_cd=dracemultiplecd))
  IF ( NOT (validate(pm_get_person_race_req)))
   RECORD pm_get_person_race_req(
     1 call_echo_ind = i2
     1 person[*]
       2 person_id = f8
   )
  ENDIF
  IF ( NOT (validate(pm_get_person_race_rep)))
   RECORD pm_get_person_race_rep(
     1 person_count = i4
     1 person[*]
       2 person_id = f8
       2 race = vc
       2 race_disp = vc
       2 race_cd = f8
       2 race_list_count = i4
       2 race_list[*]
         3 race_cd = f8
         3 race_disp = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  SET stat = alterlist(pm_get_person_race_req->person,1)
  SET pm_get_person_race_req->person[1].person_id = request->person_id
  EXECUTE pm_get_person_race
  IF ((pm_get_person_race_rep->status_data.status="S"))
   SET stat = alterlist(reply->race_list,pm_get_person_race_rep->person[1].race_list_count)
   FOR (i = 1 TO pm_get_person_race_rep->person[1].race_list_count)
     SET reply->race_list[i].race_cd = pm_get_person_race_rep->person[1].race_list[i].race_cd
   ENDFOR
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  pn.name_full
  FROM person_name pn
  PLAN (pn
   WHERE (pn.person_id=request->person_id)
    AND pn.name_type_cd=dmaiden
    AND pn.active_ind=1
    AND pn.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pn.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   reply->person_other_name = pn.name_full
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  frmt_alias = cnvtalias(pa.alias,pa.alias_pool_cd)
  FROM person_alias pa
  WHERE (pa.person_id=request->person_id)
   AND pa.active_ind=1
   AND pa.beg_effective_dt_tm < cnvtdatetime(sysdate)
   AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND  NOT (pa.person_alias_type_cd IN (dnmdpcd, dunoscd, dhicrcd, dintldcd, dnmdpdcd,
  dopodcd, doporcd, dunosdcd, dnmdprcd))
  HEAD REPORT
   count = 0
  DETAIL
   count += 1, stat = alterlist(reply->person_alias,count), reply->person_alias[count].
   person_alias_type_cd = pa.person_alias_type_cd,
   reply->person_alias[count].alias = frmt_alias, reply->person_alias[count].alias_pool_cd = pa
   .alias_pool_cd
   IF (pa.person_alias_type_cd=dshin)
    shealthcardvercd = pa.health_card_ver_code, reply->person_alias[count].person_alias_type_desc =
    sphnaliasdisp, reply->person_alias[count].person_alias_type_disp = sphnaliasdisp
   ELSE
    reply->person_alias[count].person_alias_type_desc = uar_get_code_description(reply->person_alias[
     count].person_alias_type_cd), reply->person_alias[count].person_alias_type_disp =
    uar_get_code_display(reply->person_alias[count].person_alias_type_cd)
   ENDIF
  WITH nocounter
 ;end select
 SET npersonaliasqualsize = size(reply->person_alias,5)
 FOR (ncount = 1 TO npersonaliasqualsize)
   IF ((reply->person_alias[ncount].person_alias_type_cd=dshin))
    SELECT INTO "nl:"
     cve.field_value
     FROM code_value_extension cve
     WHERE cve.code_value=dshin
      AND cve.field_name="USEMNEM"
     DETAIL
      smnem_on_or_off = trim(cve.field_value)
     WITH nocounter
    ;end select
    IF (smnem_on_or_off="1")
     SELECT INTO "nl:"
      cve.field_value
      FROM code_value_extension cve
      WHERE (cve.code_value=reply->person_alias[ncount].alias_pool_cd)
       AND cve.field_name="MNEMONIC"
      DETAIL
       reply->person_alias[ncount].alias = concat(trim(cve.field_value)," ",trim(reply->person_alias[
         ncount].alias))
      WITH nocounter
     ;end select
    ELSE
     SET sdescription = uar_get_code_description(reply->person_alias[ncount].alias_pool_cd)
     SET reply->person_alias[ncount].alias = concat(trim(sdescription)," ",trim(reply->person_alias[
       ncount].alias))
    ENDIF
    IF (trim(shealthcardvercd) != "")
     SET reply->person_alias[ncount].alias = concat(trim(reply->person_alias[ncount].alias)," (",trim
      (shealthcardvercd),")")
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM person_aborh pa
  WHERE (pa.person_id=request->person_id)
   AND pa.active_ind=1
   AND pa.begin_effective_dt_tm < cnvtdatetime(sysdate)
   AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
  DETAIL
   reply->abo_cd = pa.abo_cd, reply->rh_cd = pa.rh_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e,
   organization o
  PLAN (e
   WHERE (e.encntr_id=request->encounter_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (o
   WHERE e.organization_id=o.organization_id)
  DETAIL
   reply->encntr_type_cd = e.encntr_type_cd, reply->fin_class_cd = e.financial_class_cd, reply->
   reg_dt_tm = e.reg_dt_tm,
   reply->disch_dt_tm = e.disch_dt_tm, reply->loc_facility_cd = e.loc_facility_cd, reply->
   organization_name = o.org_name,
   reply->organization_id = o.organization_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  frmt_alias = cnvtalias(ea.alias,ea.alias_pool_cd)
  FROM encntr_alias ea
  WHERE (ea.encntr_id=request->encounter_id)
   AND ea.active_ind=1
   AND ea.beg_effective_dt_tm < cnvtdatetime(sysdate)
   AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
  HEAD REPORT
   count = 0
  DETAIL
   count += 1, stat = alterlist(reply->encntr_alias,count), reply->encntr_alias[count].
   encntr_alias_type_cd = ea.encntr_alias_type_cd,
   reply->encntr_alias[count].alias = frmt_alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  epr.prsnl_person_id, p.person_id
  FROM encntr_prsnl_reltn epr,
   prsnl p
  PLAN (epr
   WHERE (epr.encntr_id=request->encounter_id)
    AND epr.encntr_prsnl_r_cd IN (dadmitdoc, dattenddoc)
    AND epr.active_ind=1
    AND epr.manual_create_ind IN (0, null)
    AND epr.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  DETAIL
   IF (epr.encntr_prsnl_r_cd=dadmitdoc)
    reply->admit_doc = p.name_full_formatted,
    CALL echo(build("Admit doc = ",reply->admit_doc))
   ELSE
    reply->attending_doc = p.name_full_formatted,
    CALL echo(build("Attending doc = ",reply->attending_doc))
   ENDIF
  WITH nocounter
 ;end select
END GO
