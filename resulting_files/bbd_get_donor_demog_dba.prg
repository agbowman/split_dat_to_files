CREATE PROGRAM bbd_get_donor_demog:dba
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
 IF (validate(reply,"N")="N")
  RECORD reply(
    1 abo_cd = f8
    1 abo_disp = c15
    1 rh_cd = f8
    1 rh_disp = c15
    1 qual_address[*]
      2 address_id = f8
      2 address_type_cd = f8
      2 address_type_cd_mean = vc
      2 updt_cnt = i4
      2 address_format_cd = f8
      2 address_format_cd_mean = vc
      2 contact_name = vc
      2 residence_type_cd = f8
      2 residence_type_cd_mean = vc
      2 street_address_one = vc
      2 street_address_two = vc
      2 street_address_three = vc
      2 street_address_four = vc
      2 city = vc
      2 state = vc
      2 state_cd = f8
      2 zipcode = vc
      2 postal_barcode_info = vc
      2 county = vc
      2 county_cd = f8
      2 country = vc
      2 country_cd = f8
      2 residence_cd = f8
      2 mail_stop = vc
    1 qual_alias[*]
      2 person_alias_id = f8
      2 updt_cnt = i4
      2 alias_pool_cd = f8
      2 alias_pool_cd_disp = vc
      2 alias_type_cd = f8
      2 alias_type_cd_disp = vc
      2 alias_type_cd_mean = c12
      2 alias = vc
      2 alias_sub_type_cd = f8
      2 alias_sub_type_cd_mean = c12
      2 check_digit = i4
      2 check_digit_method_cd = f8
      2 formatted_alias = vc
    1 qual_antibody[*]
      2 person_antibody_id = f8
      2 encntr_id = f8
      2 antibody_cd = f8
      2 antibody_cd_disp = vc
      2 antibody_cd_mean = vc
      2 result_id = f8
      2 bb_result_id = f8
      2 updt_cnt = i4
    1 qual_antigen[*]
      2 person_antigen_id = f8
      2 encntr_id = f8
      2 antigen_cd = f8
      2 antigen_cd_disp = vc
      2 antigen_cd_mean = vc
      2 result_id = f8
      2 bb_result_id = f8
      2 updt_cnt = i4
    1 qual_employer[*]
      2 organization_id = f8
      2 organization_name = vc
    1 qual_name[*]
      2 person_name_id = f8
      2 name_type_cd = f8
      2 name_type_cd_disp = vc
      2 name_type_cd_mean = c12
      2 updt_cnt = i4
      2 name_original = vc
      2 name_format_cd = f8
      2 name_full = vc
      2 name_first = vc
      2 name_middle = vc
      2 name_last = vc
      2 name_degree = vc
      2 name_title = vc
      2 name_prefix = vc
      2 name_suffix = vc
      2 name_initials = vc
    1 qual_phone[*]
      2 phone_id = f8
      2 phone_type_cd = f8
      2 phone_type_disp = vc
      2 phone_type_mean = vc
      2 updt_cnt = i4
      2 phone_format_cd = f8
      2 phone_format_cd_mean = vc
      2 phone_format_cd_disp = vc
      2 phone_num = vc
      2 contact = vc
      2 call_instruction = vc
      2 extension = vc
      2 paging_code = vc
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
    1 race_cd_mean = vc
    1 religion_cd = f8
    1 religion_cd_disp = vc
    1 gender_cd = f8
    1 gender_cd_disp = vc
    1 gender_cd_mean = vc
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
    1 person_donor[*]
      2 active_ind = i2
      2 counseling_reqrd_cd = f8
      2 counseling_reqrd_disp = vc
      2 counseling_reqrd_desc = vc
      2 counseling_reqrd_mean = c12
      2 defer_until_dt_tm = dq8
      2 donation_level = f8
      2 donation_level_trans = f8
      2 eligibility_type_cd = f8
      2 eligibility_type_disp = vc
      2 eligibility_type_desc = vc
      2 eligibility_type_mean = c12
      2 elig_for_reinstate_ind = i2
      2 last_donation_dt_tm = dq8
      2 lock_ind = i2
      2 mailings_ind = i2
      2 person_id = f8
      2 rare_donor_cd = f8
      2 rare_donor_disp = vc
      2 rare_donor_desc = vc
      2 rare_donor_mean = c12
      2 recruit_inv_area_cd = f8
      2 recruit_inv_area_disp = vc
      2 recruit_inv_area_desc = vc
      2 recruit_inv_area_mean = c12
      2 recruit_owner_area_cd = f8
      2 recruit_owner_area_disp = vc
      2 recruit_owner_area_desc = vc
      2 recruit_owner_area_mean = c12
      2 reinstated_dt_tm = dq8
      2 reinstated_ind = i2
      2 spec_dnr_interest_cd = f8
      2 spec_dnr_interest_disp = vc
      2 spec_dnr_interest_desc = vc
      2 spec_dnr_interest_mean = c12
      2 updt_cnt = i4
      2 watch_ind = i2
      2 watch_reason_cd = f8
      2 watch_reason_disp = vc
      2 watch_reason_desc = vc
      2 watch_reason_mean = c12
      2 willingness_level_cd = f8
      2 willingness_level_disp = vc
      2 willingness_level_desc = vc
      2 willingness_level_mean = c12
      2 comments_ind = i2
      2 applctx_id = f8
      2 application_nbr = i4
      2 user_name = vc
      2 app_start_dt_tm = dq8
      2 device_location = vc
      2 application_desc = vc
      2 pref_don_loc_cd = f8
      2 pref_don_loc_disp = vc
      2 pref_don_loc_mean = c12
    1 rare_types[*]
      2 rare_type_id = f8
      2 rare_type_cd = f8
      2 rare_type_disp = vc
      2 updt_cnt = i4
    1 special_interests[*]
      2 special_interest_id = f8
      2 special_interest_cd = f8
      2 special_interest_disp = vc
      2 updt_cnt = i4
    1 contact_methods[*]
      2 contact_method_id = f8
      2 contact_method_cd = f8
      2 contact_method_disp = vc
      2 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
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
 SET reply->status_data.status = "F"
 DECLARE cnvtphone_option = i2 WITH protect, constant(1)
 DECLARE pd_cnt = i4 WITH protect, noconstant(0)
 DECLARE pd_pre_lock = i2 WITH protect, noconstant(0)
 DECLARE billing_add_cd = f8
 DECLARE temporary_add_cd = f8
 DECLARE business_add_cd = f8
 DECLARE home_add_cd = f8
 DECLARE mailing_add_cd = f8
 DECLARE email_add_cd = f8
 DECLARE business_ph_cd = f8
 DECLARE home_ph_cd = f8
 DECLARE temporary_ph_cd = f8
 DECLARE pager_bus_ph_cd = f8
 DECLARE pager_pers_ph_cd = f8
 DECLARE pager_temp_ph_cd = f8
 DECLARE code_cnt = i4
 SET address_code_set = 212
 SET phone_code_set = 43
 SET billing_cdf = fillstring(12," ")
 SET temporary_cdf = fillstring(12," ")
 SET business_cdf = fillstring(12," ")
 SET home_cdf = fillstring(12," ")
 SET mailing_cdf = fillstring(12," ")
 SET email_cdf = fillstring(12," ")
 SET pager_bus_cdf = fillstring(12," ")
 SET pager_pers_cdf = fillstring(12," ")
 SET pager_temp_cdf = fillstring(12," ")
 SET billing_cdf = "BILLING"
 SET temporary_cdf = "TEMPORARY"
 SET business_cdf = "BUSINESS"
 SET home_cdf = "HOME"
 SET mailing_cdf = "MAILING"
 SET email_cdf = "EMAIL"
 SET pager_bus_cdf = "PAGER BUS"
 SET pager_pers_cdf = "PAGER PERS"
 SET pager_temp_cdf = "PAGER TEMP"
 SET billing_add_cd = 0.0
 SET temporary_add_cd = 0.0
 SET business_add_cd = 0.0
 SET home_add_cd = 0.0
 SET mailing_add_cd = 0.0
 SET email_add_cd = 0.0
 SET business_ph_cd = 0.0
 SET home_ph_cd = 0.0
 SET temporary_ph_cd = 0.0
 SET pager_bus_ph_cd = 0.0
 SET pager_pers_ph_cd = 0.0
 SET pager_temp_ph_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(address_code_set,billing_cdf,code_cnt,billing_add_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(address_code_set,temporary_cdf,code_cnt,temporary_add_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(address_code_set,business_cdf,code_cnt,business_add_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(address_code_set,home_cdf,code_cnt,home_add_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(address_code_set,mailing_cdf,code_cnt,mailing_add_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(address_code_set,email_cdf,code_cnt,email_add_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(phone_code_set,business_cdf,code_cnt,business_ph_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(phone_code_set,home_cdf,code_cnt,home_ph_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(phone_code_set,temporary_cdf,code_cnt,temporary_ph_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(phone_code_set,pager_bus_cdf,code_cnt,pager_bus_ph_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(phone_code_set,pager_pers_cdf,code_cnt,pager_pers_ph_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(phone_code_set,pager_temp_cdf,code_cnt,pager_temp_ph_cd)
 IF ((request->get_aborh=1))
  SELECT INTO "nl:"
   d.*
   FROM donor_aborh d
   WHERE (d.person_id=request->person_id)
    AND d.active_ind=1
   DETAIL
    reply->abo_cd = d.abo_cd, reply->rh_cd = d.rh_cd
   WITH counter
  ;end select
 ENDIF
 IF ((request->get_address=1))
  SET count = 0
  SELECT INTO "nl:"
   a.*
   FROM address a
   PLAN (a
    WHERE (a.parent_entity_id=request->person_id)
     AND a.parent_entity_name="PERSON"
     AND a.address_type_cd IN (billing_add_cd, temporary_add_cd, business_add_cd, home_add_cd,
    mailing_add_cd,
    email_add_cd)
     AND cnvtdatetime(curdate,curtime3) >= a.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= a.end_effective_dt_tm
     AND a.active_ind=1)
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual_address,count), reply->qual_address[count].
    address_id = a.address_id,
    reply->qual_address[count].address_type_cd = a.address_type_cd, reply->qual_address[count].
    address_type_cd_mean = uar_get_code_meaning(a.address_type_cd), reply->qual_address[count].
    updt_cnt = a.updt_cnt,
    reply->qual_address[count].address_format_cd = a.address_format_cd, reply->qual_address[count].
    contact_name = a.contact_name, reply->qual_address[count].residence_type_cd = a.residence_type_cd,
    reply->qual_address[count].street_address_one = a.street_addr, reply->qual_address[count].
    street_address_two = a.street_addr2, reply->qual_address[count].street_address_three = a
    .street_addr3,
    reply->qual_address[count].street_address_four = a.street_addr4, reply->qual_address[count].city
     = a.city, reply->qual_address[count].state = a.state,
    reply->qual_address[count].state_cd = a.state_cd, reply->qual_address[count].zipcode = a.zipcode,
    reply->qual_address[count].postal_barcode_info = a.postal_barcode_info,
    reply->qual_address[count].county = a.county, reply->qual_address[count].county_cd = a.county_cd,
    reply->qual_address[count].country = a.country,
    reply->qual_address[count].country_cd = a.country_cd, reply->qual_address[count].residence_cd = a
    .residence_cd, reply->qual_address[count].mail_stop = a.mail_stop
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_alias=1))
  SET donor_id_type_cd = 0.0
  SET social_security_type_cd = 0.0
  SET drivers_license_type_cd = 0.0
  SET medical_rec_nbr_type_cd = 0.0
  SET person_count = 0
  SET cv_cnt = 1
  SET stat = uar_get_meaning_by_codeset(4,"DONORID",cv_cnt,donor_id_type_cd)
  SET stat = uar_get_meaning_by_codeset(4,"SSN",cv_cnt,social_security_type_cd)
  SET stat = uar_get_meaning_by_codeset(4,"MRN",cv_cnt,medical_rec_nbr_type_cd)
  SET stat = uar_get_meaning_by_codeset(4,"DRLIC",cv_cnt,drivers_license_type_cd)
  SELECT INTO "nl:"
   pa.*, formatted_alias = cnvtalias(pa.alias,pa.alias_pool_cd)
   FROM person_alias pa
   PLAN (pa
    WHERE (pa.person_id=request->person_id)
     AND ((pa.person_alias_type_cd=donor_id_type_cd
     AND (request->get_donor_id_ind=1)) OR (((pa.person_alias_type_cd=social_security_type_cd
     AND (request->get_social_sec_ind=1)) OR (((pa.person_alias_type_cd=medical_rec_nbr_type_cd
     AND (request->get_med_rec_nbr_ind=1)) OR (pa.person_alias_type_cd=drivers_license_type_cd
     AND (request->get_driver_license_ind=1))) )) ))
     AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm
     AND pa.active_ind=1)
   DETAIL
    person_count = (person_count+ 1), stat = alterlist(reply->qual_alias,person_count), reply->
    qual_alias[person_count].person_alias_id = pa.person_alias_id,
    reply->qual_alias[person_count].updt_cnt = pa.updt_cnt, reply->qual_alias[person_count].
    alias_pool_cd = pa.alias_pool_cd, reply->qual_alias[person_count].alias_type_cd = pa
    .person_alias_type_cd,
    reply->qual_alias[person_count].alias = pa.alias, reply->qual_alias[person_count].
    alias_sub_type_cd = pa.person_alias_sub_type_cd, reply->qual_alias[person_count].check_digit = pa
    .check_digit,
    reply->qual_alias[person_count].check_digit_method_cd = pa.check_digit_method_cd, reply->
    qual_alias[person_count].formatted_alias = formatted_alias
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_antibody=1))
  SET count = 0
  SELECT DISTINCT INTO "nl:"
   da.antibody_cd
   FROM encounter e,
    donor_antibody da
   PLAN (e
    WHERE (e.person_id=request->person_id))
    JOIN (da
    WHERE da.encntr_id=e.encntr_id
     AND da.active_ind=1)
   ORDER BY da.antibody_cd, 0
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual_antibody,count), reply->qual_antibody[count].
    person_antibody_id = da.donor_antibody_id,
    reply->qual_antibody[count].encntr_id = da.encntr_id, reply->qual_antibody[count].antibody_cd =
    da.antibody_cd, reply->qual_antibody[count].result_id = da.result_id,
    reply->qual_antibody[count].bb_result_id = da.bb_result_nbr, reply->qual_antibody[count].updt_cnt
     = da.updt_cnt
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_antigen=1))
  SET count = 0
  SELECT DISTINCT INTO "nl:"
   da.antigen_cd
   FROM encounter e,
    donor_antigen da
   PLAN (e
    WHERE (e.person_id=request->person_id))
    JOIN (da
    WHERE da.encntr_id=e.encntr_id
     AND da.active_ind=1)
   ORDER BY da.antigen_cd, 0
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual_antigen,count), reply->qual_antigen[count].
    person_antigen_id = da.donor_antigen_id,
    reply->qual_antigen[count].encntr_id = da.encntr_id, reply->qual_antigen[count].antigen_cd = da
    .antigen_cd, reply->qual_antigen[count].result_id = da.result_id,
    reply->qual_antigen[count].bb_result_id = da.bb_result_nbr, reply->qual_antigen[count].updt_cnt
     = da.updt_cnt
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_employer=1))
  SET count = 0
  SET employer_type_cd = 0.0
  SET cv_cnt = 1
  SET stat = uar_get_meaning_by_codeset(338,"EMPLOYER",cv_cnt,employer_type_cd)
  SELECT INTO "nl:"
   po.*, o.*
   FROM person_org_reltn po,
    organization o
   PLAN (po
    WHERE (po.person_id=request->person_id)
     AND po.person_org_reltn_cd=employer_type_cd
     AND cnvtdatetime(curdate,curtime3) >= po.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= po.end_effective_dt_tm
     AND po.active_ind=1)
    JOIN (o
    WHERE o.organization_id=po.organization_id
     AND cnvtdatetime(curdate,curtime3) >= o.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= o.end_effective_dt_tm
     AND o.active_ind=1)
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual_employer,count), reply->qual_employer[count].
    organization_id = o.organization_id,
    reply->qual_employer[count].organization_name = o.org_name
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_name=1))
  SET count = 0
  SELECT INTO "nl:"
   p.person_id
   FROM person_name p
   PLAN (p
    WHERE (p.person_id=request->person_id)
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
     AND p.active_ind=1)
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual_name,count), reply->qual_name[count].
    person_name_id = p.person_name_id,
    reply->qual_name[count].name_type_cd = p.name_type_cd, reply->qual_name[count].updt_cnt = p
    .updt_cnt, reply->qual_name[count].name_original = p.name_original,
    reply->qual_name[count].name_format_cd = p.name_format_cd, reply->qual_name[count].name_full = p
    .name_full, reply->qual_name[count].name_first = p.name_first,
    reply->qual_name[count].name_middle = p.name_middle, reply->qual_name[count].name_last = p
    .name_last, reply->qual_name[count].name_degree = p.name_degree,
    reply->qual_name[count].name_title = p.name_title, reply->qual_name[count].name_prefix = p
    .name_prefix, reply->qual_name[count].name_suffix = p.name_suffix,
    reply->qual_name[count].name_initials = p.name_initials
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_phone=1))
  SET count = 0
  SELECT INTO "nl:"
   p.*
   FROM phone p
   PLAN (p
    WHERE (p.parent_entity_id=request->person_id)
     AND p.parent_entity_name="PERSON"
     AND p.phone_type_cd IN (business_ph_cd, home_ph_cd, temporary_ph_cd, pager_bus_ph_cd,
    pager_pers_ph_cd,
    pager_temp_ph_cd)
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
     AND p.active_ind=1)
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual_phone,count), reply->qual_phone[count].phone_id
     = p.phone_id,
    reply->qual_phone[count].phone_type_cd = p.phone_type_cd, reply->qual_phone[count].updt_cnt = p
    .updt_cnt, reply->qual_phone[count].phone_format_cd = p.phone_format_cd,
    reply->qual_phone[count].phone_num = cnvtphone(p.phone_num,p.phone_format_cd,cnvtphone_option),
    reply->qual_phone[count].contact = p.contact, reply->qual_phone[count].call_instruction = p
    .call_instruction,
    reply->qual_phone[count].extension = p.extension, reply->qual_phone[count].paging_code = p
    .paging_code
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_person=1))
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
    reply->name_middle_key = p.name_middle_key, reply->name_middle = p.name_middle, reply->birth_tz
     = p.birth_tz
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_recruit_rare_type_ind=1))
  SELECT INTO "nl:"
   rt.rare_id, display = uar_get_code_display(rt.rare_type_cd)
   FROM bbd_rare_types rt
   WHERE (rt.person_id=request->person_id)
    AND rt.active_ind=1
   ORDER BY display
   HEAD REPORT
    rt_cnt = 0
   DETAIL
    rt_cnt = (rt_cnt+ 1), stat = alterlist(reply->rare_types,rt_cnt), reply->rare_types[rt_cnt].
    rare_type_id = rt.rare_id,
    reply->rare_types[rt_cnt].rare_type_cd = rt.rare_type_cd, reply->rare_types[rt_cnt].updt_cnt = rt
    .updt_cnt
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_recruit_special_ind=1))
  SELECT INTO "nl:"
   si.special_interest_id, display = uar_get_code_display(si.special_interest_cd)
   FROM bbd_special_interest si
   WHERE (si.person_id=request->person_id)
    AND si.active_ind=1
   ORDER BY display
   HEAD REPORT
    si_cnt = 0
   DETAIL
    si_cnt = (si_cnt+ 1), stat = alterlist(reply->special_interests,si_cnt), reply->
    special_interests[si_cnt].special_interest_id = si.special_interest_id,
    reply->special_interests[si_cnt].special_interest_cd = si.special_interest_cd, reply->
    special_interests[si_cnt].updt_cnt = si.updt_cnt
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_recruit_methods_ind=1))
  SELECT INTO "nl:"
   cm.contact_method_id, display = uar_get_code_display(cm.contact_method_cd)
   FROM bbd_contact_method cm
   WHERE (cm.person_id=request->person_id)
    AND cm.active_ind=1
   ORDER BY display
   HEAD REPORT
    cm_cnt = 0
   DETAIL
    cm_cnt = (cm_cnt+ 1), stat = alterlist(reply->contact_methods,cm_cnt), reply->contact_methods[
    cm_cnt].contact_method_id = cm.contact_method_id,
    reply->contact_methods[cm_cnt].contact_method_cd = cm.contact_method_cd, reply->contact_methods[
    cm_cnt].updt_cnt = cm.updt_cnt
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_person_donor_ind=1))
  SELECT INTO "nl:"
   FROM person_donor pd,
    bbd_donor_note dn
   PLAN (pd
    WHERE (pd.person_id=request->person_id)
     AND pd.active_ind=1)
    JOIN (dn
    WHERE dn.person_id=outerjoin(pd.person_id))
   ORDER BY pd.person_id
   HEAD REPORT
    pd_cnt = 0
   HEAD pd.person_id
    pd_cnt = (pd_cnt+ 1), stat = alterlist(reply->person_donor,pd_cnt), reply->person_donor[pd_cnt].
    active_ind = pd.active_ind,
    reply->person_donor[pd_cnt].person_id = pd.person_id, reply->person_donor[pd_cnt].
    counseling_reqrd_cd = pd.counseling_reqrd_cd, reply->person_donor[pd_cnt].defer_until_dt_tm =
    cnvtdatetime(pd.defer_until_dt_tm),
    reply->person_donor[pd_cnt].donation_level = pd.donation_level, reply->person_donor[pd_cnt].
    donation_level_trans = pd.donation_level_trans, reply->person_donor[pd_cnt].eligibility_type_cd
     = pd.eligibility_type_cd,
    reply->person_donor[pd_cnt].elig_for_reinstate_ind = pd.elig_for_reinstate_ind, reply->
    person_donor[pd_cnt].last_donation_dt_tm = cnvtdatetime(pd.last_donation_dt_tm), reply->
    person_donor[pd_cnt].mailings_ind = pd.mailings_ind,
    reply->person_donor[pd_cnt].rare_donor_cd = pd.rare_donor_cd, reply->person_donor[pd_cnt].
    recruit_inv_area_cd = pd.recruit_inv_area_cd, reply->person_donor[pd_cnt].recruit_owner_area_cd
     = pd.recruit_owner_area_cd,
    reply->person_donor[pd_cnt].reinstated_dt_tm = cnvtdatetime(pd.reinstated_dt_tm), reply->
    person_donor[pd_cnt].reinstated_ind = pd.reinstated_ind, reply->person_donor[pd_cnt].
    spec_dnr_interest_cd = pd.spec_dnr_interest_cd,
    reply->person_donor[pd_cnt].watch_ind = pd.watch_ind, reply->person_donor[pd_cnt].watch_reason_cd
     = pd.watch_reason_cd, reply->person_donor[pd_cnt].willingness_level_cd = pd.willingness_level_cd,
    reply->person_donor[pd_cnt].lock_ind = pd.lock_ind, reply->person_donor[pd_cnt].updt_cnt = pd
    .updt_cnt, reply->person_donor[pd_cnt].applctx_id = pd.updt_applctx,
    reply->person_donor[pd_cnt].pref_don_loc_cd = pd.preferred_donation_location_cd
   DETAIL
    IF (dn.active_ind=1)
     reply->person_donor[pd_cnt].comments_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SELECT
    IF ((request->lock_donor_ind=1))
     WITH forupdate(pd)
    ELSE
    ENDIF
    INTO "nl:"
    pd.lock_ind, pd.updt_cnt, pd.active_ind,
    pd.updt_applctx
    FROM person_donor pd
    WHERE (pd.person_id=request->person_id)
    DETAIL
     IF (pd.lock_ind=1)
      pd_pre_lock = 1
     ELSE
      pd_pre_lock = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual > 0
    AND pd_pre_lock=0)
    IF ((request->lock_donor_ind=1))
     UPDATE  FROM person_donor pd
      SET pd.lock_ind = 1, pd.updt_cnt = (pd.updt_cnt+ 1), pd.updt_applctx = reqinfo->updt_applctx,
       pd.updt_dt_tm = cnvtdatetime(curdate,curtime3), pd.updt_id = reqinfo->updt_id, pd.updt_task =
       reqinfo->updt_task
      WHERE (pd.person_id=request->person_id)
      WITH nocounter
     ;end update
     IF (curqual > 0)
      FOR (pd_cnt = 1 TO size(reply->person_donor,5))
        IF ((reply->person_donor[pd_cnt].person_id=request->person_id))
         SET reply->person_donor[pd_cnt].updt_cnt = (reply->person_donor[pd_cnt].updt_cnt+ 1)
         SET reply->person_donor[pd_cnt].lock_ind = 1
        ENDIF
      ENDFOR
     ELSE
      SET reply->status_data.status = "F"
      CALL subevent_add("Select Failed","F","BBD_GET_DONOR_DEMOG","Failed to update person donor.")
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF (curqual > 0
    AND pd_pre_lock=1)
    SELECT INTO "nl:"
     ac.app_ctx_id, ac.application_number, ac.name,
     ac.start_dt_tm, ac.device_location, a.application_number,
     a.description
     FROM application_context ac,
      application a
     PLAN (ac
      WHERE (ac.applctx=reply->person_donor[1].applctx_id))
      JOIN (a
      WHERE ac.application_number=a.application_number)
     DETAIL
      reply->person_donor[1].application_nbr = ac.application_number, reply->person_donor[1].
      user_name = ac.name, reply->person_donor[1].app_start_dt_tm = ac.start_dt_tm,
      reply->person_donor[1].device_location = ac.device_location, reply->person_donor[1].
      application_desc = a.description
     WITH nocounter
    ;end select
    SET reply->status_data.status = "L"
    CALL subevent_add("Donor is Locked","L","BBD_GET_DONOR_DEMOG",
     "Person_Donor is previously locked.")
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "F"
    CALL subevent_add("Select Failed","F","BBD_GET_DONOR_DEMOG","Failed to retrieve data to lock.")
    GO TO exit_script
   ENDIF
  ELSE
   SET reply->status_data.status = "Z"
   CALL subevent_add("Select successful","Z","BBD_GET_DONOR_DEMOG","Data does not exist.")
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
