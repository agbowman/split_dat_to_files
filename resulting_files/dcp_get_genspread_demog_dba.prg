CREATE PROGRAM dcp_get_genspread_demog:dba
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
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE g_s_patient_demographics = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "g_s_patient_demographics","PATIENT DEMOGRAPHICS"))
 DECLARE g_s_name = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_name","Name"))
 DECLARE g_s_sex = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_sex","Sex"))
 DECLARE g_s_date_of_birth = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_date_of_birth",
   "Date of Birth"))
 DECLARE g_s_race = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_race","Race"))
 DECLARE g_s_age = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_age","Age"))
 DECLARE g_s_citizenship = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_citizenship",
   "Citizenship"))
 DECLARE g_s_data_status = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_data_status",
   "Data Status"))
 DECLARE g_s_deceased = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_deceased","Deceased"))
 DECLARE g_s_ethnic_group = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_ethnic_group",
   "Ethnic Group"))
 DECLARE g_s_language_dialect = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_language_dialect",
   "Language Dialect"))
 DECLARE g_s_language = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_language","Language"))
 DECLARE g_s_marital_status = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_marital_status",
   "Marital Status"))
 DECLARE g_s_religion = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_religion","Religion"))
 DECLARE g_s_vip = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_vip","VIP"))
 DECLARE g_s_immunizations = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_immunizations",
   "Immunizations"))
 DECLARE g_s_living_will = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_living_will",
   "Living Will"))
 DECLARE g_s_organ_donor = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_organ_donor",
   "Organ Donor"))
 DECLARE g_s_smokes = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_smokes","Smokes"))
 DECLARE g_s_birth_weight = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_birth_weight",
   "Birth Weight"))
 DECLARE g_s_allergies = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_Allergies","Allergies"))
 DECLARE g_s_address_type = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_address_type",
   "Address Type"))
 DECLARE g_s_street = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_street","Street"))
 DECLARE g_s_street_2 = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_street_2","Street 2"))
 DECLARE g_s_street_3 = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_street_3","Street 3"))
 DECLARE g_s_street_4 = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_street_4","Street 4"))
 DECLARE g_s_city_state_zip = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_city_state_zip",
   "City State Zip"))
 DECLARE g_s_county = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_county","County"))
 DECLARE g_s_citystatezip = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_citystatezip",
   "CityStateZip"))
 DECLARE g_s_country = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_country","Country"))
 DECLARE g_s_phone_type = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_phone_type",
   "Phone Type"))
 DECLARE g_s_phone = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_phone","Phone"))
 DECLARE g_s_alias_type = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_alias_type",
   "Alias Type"))
 DECLARE g_s_alias = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_alias","Alias"))
 DECLARE g_s_name_type = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_name_type","Name Type"))
 DECLARE g_s_diagnosis_type = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_diagnosis_type",
   "Diagnosis Type"))
 DECLARE g_s_diagnosis = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_diagnosis","Diagnosis"))
 DECLARE g_s_diagnosis_identifier = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "g_s_diagnosis_identifier","Diagnosis Identifier"))
 DECLARE g_s_diagnosis_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_diagnosis_date",
   "Diagnosis Date"))
 DECLARE g_s_health_plan_type = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_health_plan_type",
   "Health Plan Type"))
 DECLARE g_s_deductible_amount = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "g_s_deductible_amount","Deductible Amount"))
 DECLARE g_s_deductible_met_amount = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "g_s_deductible_met_amount","Deductible MET Amount"))
 DECLARE g_s_deductible_met_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "g_s_deductible_met_date","Deductible MET date"))
 DECLARE g_s_family_deductible_met_amount = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "g_s_family_deductible_met_amount","Family Deductible MET Amount"))
 DECLARE g_s_family_deductible_met_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "g_s_family_deductible_met_date","Family Deductible MET Date"))
 DECLARE g_s_maximum_out_of_pocket_amount = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "g_s_maximum_out_of_pocket_amount","Maximum Out of Pocket Amount"))
 DECLARE g_s_signature_on_file = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "g_s_signature_on_file","Signature On File"))
 DECLARE g_s_plan_name = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_plan_name","Plan Name"))
 DECLARE g_s_baby_coverage = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_baby_coverage",
   "Baby Coverage"))
 DECLARE g_s_baby_bill = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_baby_bill","Baby Bill"))
 DECLARE g_s_relation_type = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_relation_type",
   "Relation Type"))
 DECLARE g_s_phone_number = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_phone_number",
   "Phone Number"))
 DECLARE g_s_business = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_business","Business"))
 DECLARE g_s_employer_status = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_employer_status",
   "Employer Status"))
 DECLARE g_s_employer = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_employer","Employer"))
 DECLARE g_s_yes = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_yes","Yes"))
 DECLARE g_s_relation = vc WITH constant(uar_i18ngetmessage(i18nhandle,"g_s_Relation","Relation"))
 IF ((request->person[1].person_id <= 0))
  GO TO exit_script
 ENDIF
 SET modify = predeclare
 DECLARE fmtphone = vc WITH noconstant(fillstring(22," "))
 DECLARE tempphone = vc WITH noconstant(fillstring(22," "))
 DECLARE phone_home_cd = f8 WITH noconstant(0.0)
 DECLARE phone_bus_cd = f8 WITH noconstant(0.0)
 DECLARE default_phone_cd = f8 WITH noconstant(0.0)
 DECLARE home_address_cd = f8 WITH noconstant(0.0)
 DECLARE bus_address_cd = f8 WITH noconstant(0.0)
 DECLARE employer_cd = f8 WITH noconstant(0.0)
 DECLARE tempitem = vc WITH noconstant(fillstring(100," "))
 DECLARE tempget = vc WITH noconstant(fillstring(100," "))
 DECLARE column_cnt = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 SET phone_home_cd = uar_get_code_by("MEANING",43,"HOME")
 SET phone_bus_cd = uar_get_code_by("MEANING",43,"BUSINESS")
 SET default_phone_cd = uar_get_code_by("MEANING",281,"DEFAULT")
 SET home_address_cd = uar_get_code_by("MEANING",212,"HOME")
 SET bus_address_cd = uar_get_code_by("MEANING",212,"BUSINESS")
 SET employer_cd = uar_get_code_by("MEANING",338,"EMPLOYER")
 SET reply->report_title = g_s_patient_demographics
 SET reply->spread_type = 0
 SET reply->col_cnt = 0
 SET reply->row_cnt = 0
 DECLARE name_ind = i2 WITH noconstant(1)
 DECLARE sex_ind = i2 WITH noconstant(0)
 DECLARE birth_dt_ind = i2 WITH noconstant(1)
 DECLARE race_ind = i2 WITH noconstant(1)
 DECLARE age_ind = i2 WITH noconstant(0)
 DECLARE citizenship_ind = i2 WITH noconstant(0)
 DECLARE data_status_ind = i2 WITH noconstant(1)
 DECLARE deceased_ind = i2 WITH noconstant(0)
 DECLARE ethnic_ind = i2 WITH noconstant(0)
 DECLARE dialect_ind = i2 WITH noconstant(0)
 DECLARE language_ind = i2 WITH noconstant(0)
 DECLARE marital_ind = i2 WITH noconstant(1)
 DECLARE religion_ind = i2 WITH noconstant(1)
 DECLARE vip_ind = i2 WITH noconstant(1)
 SELECT INTO "nl:"
  null_ind = nullind(p.deceased_dt_tm)
  FROM person p
  WHERE (p.person_id=request->person[1].person_id)
  HEAD REPORT
   IF (name_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_name
   ENDIF
   IF (sex_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_sex
   ENDIF
   IF (birth_dt_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_date_of_birth
   ENDIF
   IF (race_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_race
   ENDIF
   IF (age_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_age
   ENDIF
   IF (citizenship_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_citizenship
   ENDIF
   IF (data_status_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_data_status
   ENDIF
   IF (deceased_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_deceased
   ENDIF
   IF (ethnic_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_ethnic_group
   ENDIF
   IF (dialect_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_language_dialect
   ENDIF
   IF (language_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_language
   ENDIF
   IF (marital_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_marital_status
   ENDIF
   IF (religion_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_religion
   ENDIF
   IF (vip_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_vip
   ENDIF
   start_cnt = 0
  DETAIL
   reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row,reply->row_cnt), column_cnt =
   start_cnt
   IF (name_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = p.name_full_formatted
   ENDIF
   IF (sex_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(p.sex_cd)
   ENDIF
   IF (birth_dt_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = format(p.birth_dt_tm,"mm/dd/yy;;d")
   ENDIF
   IF (race_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(p.race_cd)
   ENDIF
   IF (age_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (null_ind=0)
     age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p
        .birth_dt_tm,"hhmm;;m")),cnvtdate2(format(p.deceased_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),
      cnvtint(format(p.deceased_dt_tm,"hhmm;;m")))
    ELSE
     age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p
        .birth_dt_tm,"hhmm;;m")))
    ENDIF
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = age
   ENDIF
   IF (citizenship_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(p.citizenship_cd)
   ENDIF
   IF (data_status_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(p.data_status_cd)
   ENDIF
   IF (deceased_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(p.deceased_cd)
   ENDIF
   IF (ethnic_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(p.ethnic_grp_cd)
   ENDIF
   IF (dialect_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(p
     .language_dialect_cd)
   ENDIF
   IF (language_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(p.language_cd)
   ENDIF
   IF (marital_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(p.marital_type_cd)
   ENDIF
   IF (religion_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(p.religion_cd)
   ENDIF
   IF (vip_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(p.vip_cd)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE immun_ind = i2 WITH noconstant(0)
 DECLARE will_ind = i2 WITH noconstant(0)
 DECLARE organ_ind = i2 WITH noconstant(0)
 DECLARE smoke_ind = i2 WITH noconstant(0)
 DECLARE birth_wt_ind = i2 WITH noconstant(1)
 SELECT INTO "nl:"
  FROM person_patient pp
  WHERE (pp.person_id=request->person[1].person_id)
  HEAD REPORT
   IF (immun_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_immunizations
   ENDIF
   IF (will_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_living_will
   ENDIF
   IF (organ_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_organ_donor
   ENDIF
   IF (smoke_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_smokes
   ENDIF
   IF (birth_wt_ind=1)
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_birth_weight
   ENDIF
   start_cnt = column_cnt
  DETAIL
   column_cnt = start_cnt
   IF (immun_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(pp.immun_on_file_cd
     )
   ENDIF
   IF (will_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(pp.living_will_cd)
   ENDIF
   IF (organ_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(pp.organ_donor_cd)
   ENDIF
   IF (smoke_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(pp.smokes_cd)
   ENDIF
   IF (birth_wt_ind=1)
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = cnvtstring(pp.birth_weight)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE allergy_ind = i2 WITH noconstant(1)
 IF (allergy_ind=1)
  SELECT INTO "nl:"
   FROM allergy a
   WHERE (a.person_id=request->person[1].person_id)
    AND a.active_ind=1
   HEAD REPORT
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_allergies,
    start_cnt = column_cnt
   DETAIL
    column_cnt = start_cnt, column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = g_s_yes
   WITH nocounter, maxqual(a,1)
  ;end select
 ENDIF
 DECLARE address_ind = i2 WITH noconstant(1)
 DECLARE address_type_ind = i2 WITH noconstant(1)
 DECLARE street_ind = i2 WITH noconstant(1)
 DECLARE street2_ind = i2 WITH noconstant(1)
 DECLARE street3_ind = i2 WITH noconstant(0)
 DECLARE street4_ind = i2 WITH noconstant(0)
 DECLARE citystatezip_ind = i2 WITH noconstant(1)
 DECLARE county_ind = i2 WITH noconstant(1)
 DECLARE country_ind = i2 WITH noconstant(1)
 IF (address_ind=1)
  SELECT INTO "nl:"
   FROM address a
   WHERE trim(a.parent_entity_name)="PERSON"
    AND (a.parent_entity_id=request->person[1].person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   HEAD REPORT
    IF (address_type_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_address_type,
     reply->col[reply->col_cnt].width = 150
    ENDIF
    IF (street_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street
    ENDIF
    IF (street2_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street_2
    ENDIF
    IF (street3_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street_3
    ENDIF
    IF (street4_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street_4
    ENDIF
    IF (citystatezip_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_city_state_zip
    ENDIF
    IF (county_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_county
    ENDIF
    IF (country_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_country
    ENDIF
    start_cnt = column_cnt, save_row = reply->row_cnt, row_cnt = 0
   HEAD a.address_id
    column_cnt = start_cnt, row_cnt = (row_cnt+ 1), reply->row_cnt = row_cnt
    IF (row_cnt > size(reply->row,5))
     stat = alterlist(reply->row,row_cnt)
    ENDIF
    IF (address_type_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(a.address_type_cd)
    ENDIF
    IF (street_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr
    ENDIF
    IF (street2_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (a.street_addr2 > " ")
      reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr2
     ENDIF
    ENDIF
    IF (street3_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (a.street_addr3 > " ")
      reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr3
     ENDIF
    ENDIF
    IF (street4_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (a.street_addr4 > " ")
      reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr4
     ENDIF
    ENDIF
    IF (citystatezip_ind=1)
     tempitem = "", tempget = ""
     IF (a.city > " ")
      tempitem = a.city
     ENDIF
     IF (a.state > " ")
      tempget = concat(trim(tempitem),", ",trim(a.state))
     ELSEIF (a.state <= " ")
      tempget = concat(trim(tempitem),", ",trim(uar_get_code_display(a.state_cd)))
     ENDIF
     tempitem = tempget
     IF (a.zipcode > " ")
      tempget = concat(trim(tempitem),", ",trim(a.zipcode))
     ENDIF
     tempitem = tempget, column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (tempitem > ", ")
      reply->row[reply->row_cnt].col[column_cnt].data_string = tempitem
     ELSE
      reply->row[reply->row_cnt].col[column_cnt].data_string = " "
     ENDIF
    ENDIF
    IF (county_ind=1)
     IF (a.county_cd <= 0)
      tempget = a.county
     ELSE
      tempget = uar_get_code_display(a.county_cd)
     ENDIF
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = tempget
    ENDIF
    IF (country_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(a.country_cd)
    ENDIF
   FOOT  a.address_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
   WITH nocounter
  ;end select
 ENDIF
 DECLARE phone_ind = i2 WITH noconstant(1)
 DECLARE phone_type_ind = i2 WITH noconstant(1)
 IF (phone_ind=1)
  SELECT INTO "nl:"
   FROM phone ph
   WHERE (ph.parent_entity_id=request->person[1].person_id)
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   ORDER BY ph.phone_type_cd
   HEAD REPORT
    IF (phone_type_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_phone_type
    ENDIF
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_phone,
    start_cnt = column_cnt, save_row = reply->row_cnt, row_cnt = 0
   HEAD ph.phone_id
    column_cnt = start_cnt, row_cnt = (row_cnt+ 1), reply->row_cnt = row_cnt
    IF (row_cnt > size(reply->row,5))
     stat = alterlist(reply->row,row_cnt)
    ENDIF
    IF (phone_type_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(ph.phone_type_cd)
    ENDIF
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    tempphone = fillstring(22," "), tempphone = cnvtalphanum(ph.phone_num)
    IF (tempphone != ph.phone_num)
     fmtphone = ph.phone_num
    ELSE
     IF (ph.phone_format_cd > 0)
      fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
     ELSEIF (default_phone_cd > 0)
      fmtphone = cnvtphone(trim(ph.phone_num),default_phone_cd)
     ELSEIF (size(tempphone) < 8)
      fmtphone = format(trim(ph.phone_num),"###-####")
     ELSE
      fmtphone = format(trim(ph.phone_num),"(###) ###-####")
     ENDIF
    ENDIF
    IF (fmtphone <= " ")
     fmtphone = ph.phone_num
    ENDIF
    IF (ph.extension > " ")
     fmtphone = concat(trim(fmtphone)," x",ph.extension)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = fmtphone
   FOOT  ph.phone_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
   WITH nocounter
  ;end select
 ENDIF
 DECLARE alias_ind = i2 WITH noconstant(0)
 IF (alias_ind=1)
  SELECT INTO "nl:"
   FROM person_alias pa
   WHERE (pa.person_id=request->person[1].person_id)
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ((pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (pa.end_effective_dt_tm=null))
   ORDER BY pa.person_alias_type_cd
   HEAD REPORT
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_alias_type,
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_alias,
    start_cnt = column_cnt, save_row = reply->row_cnt, row_cnt = 0
   HEAD pa.person_alias_id
    column_cnt = start_cnt, row_cnt = (row_cnt+ 1), reply->row_cnt = row_cnt
    IF (row_cnt > size(reply->row,5))
     stat = alterlist(reply->row,row_cnt)
    ENDIF
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(pa
     .person_alias_type_cd), column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    IF (pa.alias > " ")
     reply->row[reply->row_cnt].col[column_cnt].data_string = cnvtalias(pa.alias,pa.alias_pool_cd)
    ENDIF
   FOOT  pa.person_alias_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
   WITH nocounter
  ;end select
 ENDIF
 DECLARE person_name_ind = i2 WITH noconstant(1)
 IF (person_name_ind=1)
  SELECT INTO "nl:"
   FROM person_name pn
   WHERE (pn.person_id=request->person[1].person_id)
   ORDER BY pn.name_type_cd
   HEAD REPORT
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_name_type,
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_name,
    start_cnt = column_cnt, save_row = reply->row_cnt, row_cnt = 0
   HEAD pn.person_name_id
    column_cnt = start_cnt, row_cnt = (row_cnt+ 1), reply->row_cnt = row_cnt
    IF (row_cnt > size(reply->row,5))
     stat = alterlist(reply->row,row_cnt)
    ENDIF
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    IF (pn.name_full > " ")
     reply->row[reply->row_cnt].col[column_cnt].data_string = concat("Name (",trim(
       uar_get_code_display(pn.name_type_cd)),")")
    ENDIF
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    IF (pn.name_full > " ")
     reply->row[reply->row_cnt].col[column_cnt].data_string = pn.name_full
    ENDIF
   FOOT  pn.person_name_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
   WITH nocounter
  ;end select
 ENDIF
 DECLARE diagnosis_ind = i2 WITH noconstant(1)
 DECLARE diag_type_ind = i2 WITH noconstant(1)
 DECLARE diag_ident_ind = i2 WITH noconstant(1)
 DECLARE diag_date_ind = i2 WITH noconstant(1)
 IF (diagnosis_ind=1)
  SELECT INTO "nl:"
   FROM diagnosis d,
    (dummyt d1  WITH seq = 1),
    nomenclature n
   PLAN (d
    WHERE (d.person_id=request->person[1].person_id)
     AND d.active_ind=1
     AND d.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (d.end_effective_dt_tm=null))
    )
    JOIN (d1)
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id)
   ORDER BY n.source_vocabulary_cd, d.diag_dt_tm DESC
   HEAD REPORT
    IF (diag_type_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_diagnosis_type,
     reply->col[reply->col_cnt].width = 150
    ENDIF
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_diagnosis
    IF (diag_ident_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_diagnosis_identifier,
     reply->col[reply->col_cnt].width = 150
    ENDIF
    IF (diag_date_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_diagnosis_date,
     reply->col[reply->col_cnt].width = 150
    ENDIF
    start_cnt = column_cnt, save_row = reply->row_cnt, row_cnt = 0
   HEAD d.diagnosis_id
    column_cnt = start_cnt, row_cnt = (row_cnt+ 1), reply->row_cnt = row_cnt
    IF (row_cnt > size(reply->row,5))
     stat = alterlist(reply->row,row_cnt)
    ENDIF
    IF (diag_type_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(n
      .source_vocabulary_cd)
    ENDIF
    IF (trim(n.source_string) > "")
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = n.source_string
    ELSE
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = d.diag_ftdesc
    ENDIF
    IF (diag_ident_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = n.source_identifier
    ENDIF
    IF (diag_date_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = format(d.diag_dt_tm,"mm/dd/yy hh:mm;;d"
      )
    ENDIF
   FOOT  d.diagnosis_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
   WITH nocounter, outerjoin = d1, dontcare = n
  ;end select
 ENDIF
 DECLARE health_plan_ind = i2 WITH noconstant(1)
 DECLARE health_plan_type_ind = i2 WITH noconstant(1)
 DECLARE deduct_amt_ind = i2 WITH noconstant(0)
 DECLARE deduct_met_amt_ind = i2 WITH noconstant(0)
 DECLARE deduct_met_date_ind = i2 WITH noconstant(0)
 DECLARE fam_deduct_met_amt_ind = i2 WITH noconstant(0)
 DECLARE fam_deduct_met_date_ind = i2 WITH noconstant(0)
 DECLARE max_pckt_amt_ind = i2 WITH noconstant(0)
 DECLARE max_pckt_date_ind = i2 WITH noconstant(0)
 DECLARE signature_ind = i2 WITH noconstant(0)
 DECLARE plan_name_ind = i2 WITH noconstant(1)
 DECLARE baby_coverage_ind = i2 WITH noconstant(1)
 DECLARE baby_bill_ind = i2 WITH noconstant(1)
 IF (health_plan_ind=1)
  SELECT INTO "nl:"
   FROM person_plan_reltn ppr,
    (dummyt d1  WITH seq = 1),
    health_plan hp
   PLAN (ppr
    WHERE (ppr.person_id=request->person[1].person_id)
     AND ppr.active_ind=1)
    JOIN (d1)
    JOIN (hp
    WHERE hp.health_plan_id=ppr.health_plan_id
     AND hp.active_ind=1)
   ORDER BY hp.plan_type_cd
   HEAD REPORT
    IF (health_plan_type_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_health_plan_type
    ENDIF
    IF (deduct_amt_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_deductible_amount
    ENDIF
    IF (deduct_met_amt_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_deductible_met_amount
    ENDIF
    IF (deduct_met_date_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_deductible_met_date
    ENDIF
    IF (fam_deduct_met_amt_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_family_deductible_met_amount
    ENDIF
    IF (fam_deduct_met_date_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_family_deductible_met_date
    ENDIF
    IF (max_pckt_amt_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_maximum_out_of_pocket_amount
    ENDIF
    IF (max_pckt_date_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = "Maximum Out of Pocket Date"
    ENDIF
    IF (signature_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_signature_on_file
    ENDIF
    IF (plan_name_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_plan_name
    ENDIF
    IF (baby_coverage_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_baby_coverage
    ENDIF
    IF (baby_bill_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_baby_bill
    ENDIF
    start_cnt = column_cnt, save_row = reply->row_cnt, row_cnt = 0
   HEAD ppr.health_plan_id
    column_cnt = start_cnt, row_cnt = (row_cnt+ 1), reply->row_cnt = row_cnt
    IF (row_cnt > size(reply->row,5))
     stat = alterlist(reply->row,row_cnt)
    ENDIF
    IF (health_plan_type_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(hp.plan_type_cd)
    ENDIF
    IF (deduct_amt_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[1].data_string = g_s_deductible_amount, reply->row[reply->row_cnt
     ].col[column_cnt].data_string = cnvtstring(ppr.deduct_amt)
    ENDIF
    IF (deduct_met_amt_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = cnvtstring(ppr.deduct_met_amt)
    ENDIF
    IF (deduct_met_date_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = format(ppr.deduct_met_dt_tm,
      "mm/dd/yy;;d")
    ENDIF
    IF (fam_deduct_met_amt_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = cnvtstring(ppr.fam_deduct_met_amt)
    ENDIF
    IF (fam_deduct_met_date_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = format(ppr.fam_deduct_met_dt_tm,
      "mm/dd/yy;;d")
    ENDIF
    IF (max_pckt_amt_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = cnvtstring(ppr.max_out_pckt_amt)
    ENDIF
    IF (max_pckt_date_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = format(ppr.max_out_pckt_dt_tm,
      "mm/dd/yy;;d")
    ENDIF
    IF (signature_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(ppr
      .signature_on_file_cd)
    ENDIF
    IF (plan_name_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = hp.plan_name
    ENDIF
    IF (baby_coverage_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(hp
      .baby_coverage_cd)
    ENDIF
    IF (baby_bill_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(hp
      .comb_baby_bill_cd)
    ENDIF
   FOOT  ppr.health_plan_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
   WITH nocounter, outerjoin = d1, dontcare = hp
  ;end select
 ENDIF
 DECLARE person_person_reltn_ind = i2 WITH noconstant(1)
 DECLARE rel_address_type_ind = i2 WITH noconstant(1)
 DECLARE rel_street_ind = i2 WITH noconstant(1)
 DECLARE rel_street2_ind = i2 WITH noconstant(1)
 DECLARE rel_street3_ind = i2 WITH noconstant(1)
 DECLARE rel_street4_ind = i2 WITH noconstant(0)
 DECLARE rel_citystatezip_ind = i2 WITH noconstant(1)
 DECLARE rel_county_ind = i2 WITH noconstant(1)
 DECLARE rel_country_ind = i2 WITH noconstant(0)
 DECLARE rel_phone_ind = i2 WITH noconstant(1)
 IF (person_person_reltn_ind=1)
  SELECT INTO "nl:"
   FROM person_person_reltn ppr,
    (dummyt d1  WITH seq = 1),
    person p,
    (dummyt d2  WITH seq = 1),
    address a,
    (dummyt d3  WITH seq = 1),
    phone ph
   PLAN (ppr
    WHERE (ppr.person_id=request->person[1].person_id)
     AND ppr.active_ind=1)
    JOIN (d1)
    JOIN (p
    WHERE p.person_id=ppr.related_person_id
     AND p.active_ind=1)
    JOIN (d2)
    JOIN (a
    WHERE trim(a.parent_entity_name)="PERSON"
     AND a.parent_entity_id=ppr.related_person_id
     AND a.address_type_cd=home_address_cd
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d3)
    JOIN (ph
    WHERE ph.parent_entity_name="PERSON"
     AND ph.parent_entity_id=ppr.related_person_id
     AND ((ph.phone_type_cd=phone_bus_cd) OR (ph.phone_type_cd=phone_home_cd))
     AND ph.active_ind=1
     AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY ppr.person_reltn_type_cd, a.address_type_seq DESC, ph.phone_type_seq DESC
   HEAD REPORT
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_relation_type,
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_name,
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_relation
    IF (rel_address_type_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_address_type
    ENDIF
    IF (rel_street_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street
    ENDIF
    IF (rel_street2_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street_2
    ENDIF
    IF (rel_street3_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street_3
    ENDIF
    IF (rel_street4_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street_4
    ENDIF
    IF (rel_citystatezip_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_citystatezip
    ENDIF
    IF (rel_county_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_county
    ENDIF
    IF (rel_country_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_country
    ENDIF
    IF (rel_phone_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_phone_type,
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_phone_number
    ENDIF
    start_cnt = column_cnt, save_row = reply->row_cnt, row_cnt = 0,
    phone_cnt = 0
   HEAD ppr.person_person_reltn_id
    column_cnt = start_cnt, row_cnt = (row_cnt+ 1), reply->row_cnt = row_cnt
    IF (row_cnt > size(reply->row,5))
     stat = alterlist(reply->row,row_cnt)
    ENDIF
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(ppr
     .person_reltn_type_cd), column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = p.name_full_formatted, column_cnt = (
    column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(ppr.person_reltn_cd
     )
   HEAD a.address_id
    IF (rel_address_type_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(a.address_type_cd)
    ENDIF
    IF (rel_street_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr
    ENDIF
    IF (rel_street2_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (a.street_addr2 > " ")
      reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr2
     ENDIF
    ENDIF
    IF (rel_street3_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (a.street_addr3 > " ")
      reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr3
     ENDIF
    ENDIF
    IF (rel_street4_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (a.street_addr4)
      reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr4
     ENDIF
    ENDIF
    IF (rel_citystatezip_ind=1)
     tempitem = "", tempget = ""
     IF (a.city > " ")
      tempitem = a.city
     ENDIF
     IF (a.state > " ")
      tempget = concat(trim(tempitem),", ",trim(a.state))
     ELSEIF (a.state <= " ")
      tempget = concat(trim(tempitem),", ",trim(uar_get_code_display(a.state_cd)))
     ENDIF
     tempitem = tempget
     IF (a.zipcode > " ")
      tempget = concat(trim(tempitem),", ",trim(a.zipcode))
     ENDIF
     tempitem = tempget, column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (tempitem > ", ")
      reply->row[reply->row_cnt].col[column_cnt].data_string = tempitem
     ELSE
      reply->row[reply->row_cnt].col[column_cnt].data_string = " "
     ENDIF
    ENDIF
    IF (rel_county_ind=1)
     IF (a.county_cd <= 0)
      tempget = a.county
     ELSE
      tempget = uar_get_code_display(a.county_cd)
     ENDIF
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = tempget
    ENDIF
    IF (rel_country_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(a.country_cd)
    ENDIF
   HEAD ph.phone_id
    IF (rel_phone_ind=1)
     phone_cnt = (phone_cnt+ 1)
     IF (phone_cnt=1)
      temp_column_cnt = column_cnt
     ELSEIF (phone_cnt > 1)
      column_cnt = temp_column_cnt, row_cnt = (row_cnt+ 1), reply->row_cnt = row_cnt
      IF (row_cnt > size(reply->row,5))
       stat = alterlist(reply->row,row_cnt)
      ENDIF
     ENDIF
     IF (ph.phone_type_cd=phone_home_cd)
      column_cnt = (column_cnt+ 1)
      IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
       stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
      ENDIF
      reply->row[reply->row_cnt].col[column_cnt].data_string = "Home", tempphone = fillstring(22," "),
      tempphone = cnvtalphanum(ph.phone_num)
      IF (tempphone != ph.phone_num)
       fmtphone = ph.phone_num
      ELSE
       IF (ph.phone_format_cd > 0)
        fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
       ELSEIF (default_phone_cd > 0)
        fmtphone = cnvtphone(trim(ph.phone_num),default_phone_cd)
       ELSEIF (size(tempphone) < 8)
        fmtphone = format(trim(ph.phone_num),"###-####")
       ELSE
        fmtphone = format(trim(ph.phone_num),"(###) ###-####")
       ENDIF
      ENDIF
      IF (ph.extension > " ")
       fmtphone = concat(trim(fmtphone)," x",ph.extension)
      ENDIF
      column_cnt = (column_cnt+ 1)
      IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
       stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
      ENDIF
      reply->row[reply->row_cnt].col[column_cnt].data_string = fmtphone
     ELSEIF (ph.phone_type_cd=phone_bus_cd)
      column_cnt = (column_cnt+ 1)
      IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
       stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
      ENDIF
      reply->row[reply->row_cnt].col[column_cnt].data_string = g_s_business, tempphone = fillstring(
       22," "), tempphone = cnvtalphanum(ph.phone_num)
      IF (tempphone != ph.phone_num)
       fmtphone = ph.phone_num
      ELSE
       IF (ph.phone_format_cd > 0)
        fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
       ELSEIF (default_phone_cd > 0)
        fmtphone = cnvtphone(trim(ph.phone_num),default_phone_cd)
       ELSEIF (size(tempphone) < 8)
        fmtphone = format(trim(ph.phone_num),"###-####")
       ELSE
        fmtphone = format(trim(ph.phone_num),"(###) ###-####")
       ENDIF
      ENDIF
      IF (ph.extension > " ")
       fmtphone = concat(trim(fmtphone)," x",ph.extension)
      ENDIF
      column_cnt = (column_cnt+ 1)
      IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
       stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
      ENDIF
      reply->row[reply->row_cnt].col[column_cnt].data_string = fmtphone
     ELSE
      column_cnt = (column_cnt+ 2)
      IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
       stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
      ENDIF
     ENDIF
    ENDIF
   FOOT  ph.phone_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT  ppr.person_person_reltn_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
    phone_cnt = 0
   FOOT REPORT
    reply->row_cnt = save_row
   WITH nocounter, outerjoin = d2, outerjoin = d3,
    dontcare = addr, dontcare = ph
  ;end select
 ENDIF
 DECLARE org_ind = i2 WITH noconstant(1)
 DECLARE org_address_type_ind = i2 WITH noconstant(0)
 DECLARE org_street_ind = i2 WITH noconstant(1)
 DECLARE org_street2_ind = i2 WITH noconstant(1)
 DECLARE org_street3_ind = i2 WITH noconstant(0)
 DECLARE org_street4_ind = i2 WITH noconstant(0)
 DECLARE org_citystatezip_ind = i2 WITH noconstant(1)
 DECLARE org_county_ind = i2 WITH noconstant(1)
 DECLARE org_country_ind = i2 WITH noconstant(0)
 DECLARE org_phone_ind = i2 WITH noconstant(1)
 IF (org_ind=1)
  SELECT INTO "nl:"
   FROM person_org_reltn por,
    (dummyt d1  WITH seq = 1),
    address a,
    (dummyt d2  WITH seq = 1),
    phone ph,
    (dummyt d3  WITH seq = 1),
    organization o
   PLAN (por
    WHERE (por.person_id=request->person[1].person_id)
     AND por.person_org_reltn_cd=employer_cd
     AND por.active_ind=1)
    JOIN (d1)
    JOIN (a
    WHERE trim(a.parent_entity_name)="ORGANIZATION"
     AND a.parent_entity_id=por.organization_id
     AND a.address_type_cd=bus_address_cd
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d2)
    JOIN (ph
    WHERE ph.parent_entity_name="ORGANIZATION"
     AND ph.parent_entity_id=por.organization_id
     AND ph.phone_type_cd=phone_bus_cd
     AND ph.active_ind=1
     AND ph.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ph.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (d3)
    JOIN (o
    WHERE o.organization_id=por.organization_id
     AND o.active_ind=1)
   ORDER BY por.person_org_reltn_cd, a.address_type_seq DESC, ph.phone_type_seq DESC
   HEAD REPORT
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_employer_status,
    reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
    reply->col_cnt].header = g_s_employer
    IF (org_address_type_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_address_type
    ENDIF
    IF (org_street_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street
    ENDIF
    IF (org_street2_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street_2
    ENDIF
    IF (org_street3_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street_3
    ENDIF
    IF (org_street4_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_street_4
    ENDIF
    IF (org_citystatezip_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_citystatezip
    ENDIF
    IF (org_county_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_county
    ENDIF
    IF (org_country_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_country
    ENDIF
    IF (org_phone_ind=1)
     reply->col_cnt = (reply->col_cnt+ 1), stat = alterlist(reply->col,reply->col_cnt), reply->col[
     reply->col_cnt].header = g_s_phone_number
    ENDIF
    start_cnt = column_cnt, save_row = reply->row_cnt, row_cnt = 0
   HEAD por.organization_id
    column_cnt = start_cnt, row_cnt = (row_cnt+ 1), reply->row_cnt = row_cnt
    IF (row_cnt > size(reply->row,5))
     stat = alterlist(reply->row,row_cnt)
    ENDIF
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(por.empl_status_cd),
    column_cnt = (column_cnt+ 1)
    IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
     stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
    ENDIF
    reply->row[reply->row_cnt].col[column_cnt].data_string = o.org_name
   HEAD a.address_id
    IF (org_address_type_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(a.address_type_cd)
    ENDIF
    IF (org_street_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr
    ENDIF
    IF (org_street2_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (a.street_addr2 > " ")
      reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr2
     ENDIF
    ENDIF
    IF (org_street3_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (a.street_addr3 > " ")
      reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr3
     ENDIF
    ENDIF
    IF (org_street4_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (a.street_addr4 > " ")
      reply->row[reply->row_cnt].col[column_cnt].data_string = a.street_addr4
     ENDIF
    ENDIF
    IF (org_citystatezip_ind=1)
     tempitem = "", tempget = ""
     IF (a.city > " ")
      tempitem = a.city
     ENDIF
     IF (a.state > " ")
      tempget = concat(trim(tempitem),", ",trim(a.state))
     ELSEIF (a.state <= " ")
      tempget = concat(trim(tempitem),", ",trim(uar_get_code_display(a.state_cd)))
     ENDIF
     tempitem = tempget
     IF (a.zipcode > " ")
      tempget = concat(trim(tempitem),", ",trim(a.zipcode))
     ENDIF
     tempitem = tempget, column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     IF (tempitem > ", ")
      reply->row[reply->row_cnt].col[column_cnt].data_string = tempitem
     ELSE
      reply->row[reply->row_cnt].col[column_cnt].data_string = " "
     ENDIF
    ENDIF
    IF (org_county_ind=1)
     IF (a.county_cd <= 0)
      tempget = a.county
     ELSE
      tempget = uar_get_code_display(a.county_cd)
     ENDIF
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = tempget
    ENDIF
    IF (org_country_ind=1)
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = uar_get_code_display(a.country_cd)
    ENDIF
   HEAD ph.phone_id
    IF (org_phone_ind=1)
     tempphone = fillstring(22," "), tempphone = cnvtalphanum(ph.phone_num)
     IF (tempphone != ph.phone_num)
      fmtphone = ph.phone_num
     ELSE
      IF (ph.phone_format_cd > 0)
       fmtphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
      ELSEIF (default_phone_cd > 0)
       fmtphone = cnvtphone(trim(ph.phone_num),default_phone_cd)
      ELSEIF (size(tempphone) < 8)
       fmtphone = format(trim(ph.phone_num),"###-####")
      ELSE
       fmtphone = format(trim(ph.phone_num),"(###) ###-####")
      ENDIF
     ENDIF
     IF (ph.extension > " ")
      fmtphone = concat(trim(fmtphone)," x",ph.extension)
     ENDIF
     column_cnt = (column_cnt+ 1)
     IF (size(reply->row[reply->row_cnt].col,5) < column_cnt)
      stat = alterlist(reply->row[reply->row_cnt].col,column_cnt)
     ENDIF
     reply->row[reply->row_cnt].col[column_cnt].data_string = fmtphone
    ENDIF
   FOOT  por.organization_id
    IF ((reply->row_cnt > save_row))
     save_row = reply->row_cnt
    ENDIF
   FOOT REPORT
    reply->row_cnt = save_row
   WITH nocounter, outerjoin = d1, dontcare = a,
    dontcare = ph
  ;end select
 ENDIF
#exit_script
END GO
