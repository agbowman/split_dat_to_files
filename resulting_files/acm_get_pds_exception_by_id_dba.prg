CREATE PROGRAM acm_get_pds_exception_by_id:dba
 IF (validate(reply,"-999")="-999")
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 local_person_data
      2 birth_dt_tm = dq8
      2 birth_prec_flag = i2
      2 birth_tz = i4
      2 gender_cd = f8
      2 nhs_number = vc
      2 phone_format_cd = f8
      2 comparison_data
        3 current_name_ind = i2
        3 birth_info_ind = i2
        3 home_address_ind = i2
        3 mailing_address_ind = i2
        3 temp_address_ind = i2
      2 current_name
        3 name_first = vc
        3 name_last = vc
        3 name_prefix = vc
        3 name_suffix = vc
      2 home_phone
        3 phone_number = vc
      2 home_address
        3 street_addr = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 city = vc
        3 county = vc
        3 zipcode = vc
      2 mailing_address
        3 street_addr = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 city = vc
        3 county = vc
        3 zipcode = vc
      2 temp_address
        3 street_addr = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 city = vc
        3 county = vc
        3 zipcode = vc
    1 pds_person_data
      2 birth_dt_tm = dq8
      2 birth_prec_flag = i2
      2 birth_tz = i4
      2 current_name
        3 name_first = vc
        3 name_last = vc
        3 name_prefix = vc
        3 name_suffix = vc
      2 home_phone
        3 phone_number = vc
      2 home_address
        3 street_addr = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 city = vc
        3 county = vc
        3 zipcode = vc
      2 mailing_address
        3 street_addr = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 city = vc
        3 county = vc
        3 zipcode = vc
      2 temp_address
        3 street_addr = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 city = vc
        3 county = vc
        3 zipcode = vc
  )
 ENDIF
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE temp_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE current_name_cd = f8 WITH protect, constant(loadcodevalue(213,"CURRENT",0))
 DECLARE home_address_cd = f8 WITH protect, constant(loadcodevalue(212,"HOME",0))
 DECLARE temp_address_cd = f8 WITH protect, constant(loadcodevalue(212,"TEMPORARY",0))
 DECLARE mailing_address_cd = f8 WITH protect, constant(loadcodevalue(212,"MAILING",0))
 DECLARE home_phone_cd = f8 WITH protect, constant(loadcodevalue(43,"HOME",0))
 DECLARE ssn_cd = f8 WITH protect, constant(loadcodevalue(4,"SSN",0))
 DECLARE tel_cd = f8 WITH protect, constant(loadcodevalue(23056,"TEL",0))
 DECLARE use_city = i2 WITH protect, noconstant(false)
 DECLARE nhscityoptcd = f8 WITH protect, constant(loadcodevalue(20790,"NHSCITYOPT",0))
 DECLARE temp_source_version_number = vc WITH protect, noconstant("")
 IF (nhscityoptcd > 0)
  SELECT INTO "nl:"
   FROM code_value_extension cve
   WHERE cve.code_value=nhscityoptcd
    AND cve.field_name="OPTION"
    AND cve.code_set=20790
   DETAIL
    IF (trim(cve.field_value,3)="1")
     use_city = true
    ELSE
     use_city = false
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET temp_source_version_number = ""
 SET comparison_person_id = 0
 SELECT INTO "nl:"
  ppp.comparison_person_id, ppp.source_version_number, ppp.person_id
  FROM pm_post_process ppp
  WHERE (ppp.pm_post_process_id=request->pds_exception_id)
  DETAIL
   comparison_person_id = ppp.comparison_person_id, temp_source_version_number = ppp
   .source_version_number, temp_person_id = ppp.person_id
  WITH nocounter
 ;end select
 IF (temp_person_id <= 0)
  SET failed = select_error
  SET table_name = "No matching person_id for pds_exception_id"
  GO TO exit_script
 ENDIF
 IF (comparison_person_id > 0.0)
  SELECT INTO "nl:"
   person_name_ind = nullind(pn.person_name_id), birth_date_ind = nullind(p.birth_dt_tm)
   FROM person p,
    person_name pn
   PLAN (p
    WHERE p.person_id=comparison_person_id)
    JOIN (pn
    WHERE (pn.person_id= Outerjoin(p.person_id))
     AND (pn.name_type_cd= Outerjoin(current_name_cd)) )
   DETAIL
    IF (validate(reply->pds_person_data.person_id))
     stat = assign(validate(reply->pds_person_data.person_id),p.person_id)
    ENDIF
    IF (validate(reply->pds_person_data.source_version_number))
     stat2 = assign(validate(reply->pds_person_data.source_version_number),temp_source_version_number
      )
    ENDIF
    IF (person_name_ind=0)
     reply->local_person_data.comparison_data.current_name_ind = 1, reply->pds_person_data.
     current_name.name_first = pn.name_first, reply->pds_person_data.current_name.name_last = pn
     .name_last,
     reply->pds_person_data.current_name.name_prefix = pn.name_prefix, reply->pds_person_data.
     current_name.name_suffix = pn.name_suffix
     IF (validate(reply->pds_person_data.current_name.person_name_id))
      stat = assign(validate(reply->pds_person_data.current_name.person_name_id),pn.person_name_id)
     ENDIF
     IF (validate(reply->pds_person_data.current_name.name_middle))
      stat2 = assign(validate(reply->pds_person_data.current_name.name_middle),cnvtalphanum(pn
        .name_middle))
     ENDIF
     IF (validate(reply->pds_person_data.current_name.source_identifier))
      stat2 = assign(validate(reply->pds_person_data.current_name.source_identifier),pn
       .source_identifier)
     ENDIF
     IF (validate(reply->pds_person_data.current_name.beg_effective_dt_tm))
      stat = assign(validate(reply->pds_person_data.current_name.beg_effective_dt_tm),pn
       .beg_effective_dt_tm)
     ENDIF
     IF (validate(reply->pds_person_data.current_name.end_effective_dt_tm))
      stat = assign(validate(reply->pds_person_data.current_name.end_effective_dt_tm),pn
       .end_effective_dt_tm)
     ENDIF
    ENDIF
    IF (birth_date_ind=0)
     reply->local_person_data.comparison_data.birth_info_ind = 1
     IF (p.birth_dt_tm != cnvtdatetime("31-DEC-2100"))
      reply->pds_person_data.birth_dt_tm = p.birth_dt_tm, reply->pds_person_data.birth_prec_flag = p
      .birth_prec_flag, reply->pds_person_data.birth_tz = p.birth_tz
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT
  IF (comparison_person_id > 0)
   address_type_cd = a.address_type_cd, street_addr4 = a.street_addr4, city_null_ind = nullind(a.city
    )
   WHERE a.parent_entity_id=comparison_person_id
    AND a.parent_entity_name="PERSON"
  ELSE
   address_type_cd = a.address_type_cd, street_addr4 = a.street_addr4, city_null_ind = nullind(a.city
    )
   WHERE (a.parent_entity_id=request->pds_exception_id)
    AND a.parent_entity_name="PM_POST_PROCESS"
    AND a.address_type_cd=home_address_cd
  ENDIF
  FROM address a
  DETAIL
   IF (address_type_cd=home_address_cd)
    reply->local_person_data.comparison_data.home_address_ind = 1
    IF (validate(reply->pds_person_data.home_address.address_id))
     stat = assign(validate(reply->pds_person_data.home_address.address_id),a.address_id)
    ENDIF
    reply->pds_person_data.home_address.street_addr = a.street_addr, reply->pds_person_data.
    home_address.street_addr2 = a.street_addr2, reply->pds_person_data.home_address.street_addr3 = a
    .street_addr3
    IF (use_city=0
     AND ((city_null_ind=1) OR (size(trim(a.city),1)=0))
     AND comparison_person_id <= 0)
     reply->pds_person_data.home_address.city = street_addr4
    ELSE
     reply->pds_person_data.home_address.city = a.city
    ENDIF
    reply->pds_person_data.home_address.county = a.county, reply->pds_person_data.home_address.
    zipcode = a.zipcode
    IF (validate(reply->pds_person_data.home_address.postal_identifier))
     stat2 = assign(validate(reply->pds_person_data.home_address.postal_identifier),a
      .postal_identifier)
    ENDIF
    IF (validate(reply->pds_person_data.home_address.comment_txt))
     stat2 = assign(validate(reply->pds_person_data.home_address.comment_txt),a.comment_txt)
    ENDIF
    IF (validate(reply->pds_person_data.home_address.source_identifier))
     stat2 = assign(validate(reply->pds_person_data.home_address.source_identifier),a
      .source_identifier)
    ENDIF
    IF (validate(reply->pds_person_data.home_address.beg_effective_dt_tm))
     stat = assign(validate(reply->pds_person_data.home_address.beg_effective_dt_tm),a
      .beg_effective_dt_tm)
    ENDIF
    IF (validate(reply->pds_person_data.home_address.end_effective_dt_tm))
     stat = assign(validate(reply->pds_person_data.home_address.end_effective_dt_tm),a
      .end_effective_dt_tm)
    ENDIF
   ELSEIF (address_type_cd=temp_address_cd)
    reply->local_person_data.comparison_data.temp_address_ind = 1
    IF (validate(reply->pds_person_data.temp_address.address_id))
     stat = assign(validate(reply->pds_person_data.temp_address.address_id),a.address_id)
    ENDIF
    reply->pds_person_data.temp_address.street_addr = a.street_addr, reply->pds_person_data.
    temp_address.street_addr2 = a.street_addr2, reply->pds_person_data.temp_address.street_addr3 = a
    .street_addr3
    IF (use_city=0
     AND ((city_null_ind=1) OR (size(trim(a.city),1)=0))
     AND comparison_person_id <= 0)
     reply->pds_person_data.temp_address.city = street_addr4
    ELSE
     reply->pds_person_data.temp_address.city = a.city
    ENDIF
    reply->pds_person_data.temp_address.county = a.county, reply->pds_person_data.temp_address.
    zipcode = a.zipcode
    IF (validate(reply->pds_person_data.temp_address.postal_identifier))
     stat2 = assign(validate(reply->pds_person_data.temp_address.postal_identifier),a
      .postal_identifier)
    ENDIF
    IF (validate(reply->pds_person_data.temp_address.comment_txt))
     stat2 = assign(validate(reply->pds_person_data.temp_address.comment_txt),a.comment_txt)
    ENDIF
    IF (validate(reply->pds_person_data.temp_address.source_identifier))
     stat2 = assign(validate(reply->pds_person_data.temp_address.source_identifier),a
      .source_identifier)
    ENDIF
    IF (validate(reply->pds_person_data.temp_address.beg_effective_dt_tm))
     stat = assign(validate(reply->pds_person_data.temp_address.beg_effective_dt_tm),a
      .beg_effective_dt_tm)
    ENDIF
    IF (validate(reply->pds_person_data.temp_address.end_effective_dt_tm))
     stat = assign(validate(reply->pds_person_data.temp_address.end_effective_dt_tm),a
      .end_effective_dt_tm)
    ENDIF
   ELSEIF (address_type_cd=mailing_address_cd)
    reply->local_person_data.comparison_data.mailing_address_ind = 1
    IF (validate(reply->pds_person_data.mailing_address.address_id))
     stat = assign(validate(reply->pds_person_data.mailing_address.address_id),a.address_id)
    ENDIF
    reply->pds_person_data.mailing_address.street_addr = a.street_addr, reply->pds_person_data.
    mailing_address.street_addr2 = a.street_addr2, reply->pds_person_data.mailing_address.
    street_addr3 = a.street_addr3
    IF (use_city=0
     AND ((city_null_ind=1) OR (size(trim(a.city),1)=0))
     AND comparison_person_id <= 0)
     reply->pds_person_data.mailing_address.city = street_addr4
    ELSE
     reply->pds_person_data.mailing_address.city = a.city
    ENDIF
    reply->pds_person_data.mailing_address.county = a.county, reply->pds_person_data.mailing_address.
    zipcode = a.zipcode
    IF (validate(reply->pds_person_data.mailing_address.postal_identifier))
     stat2 = assign(validate(reply->pds_person_data.mailing_address.postal_identifier),a
      .postal_identifier)
    ENDIF
    IF (validate(reply->pds_person_data.mailing_address.comment_txt))
     stat2 = assign(validate(reply->pds_person_data.mailing_address.comment_txt),a.comment_txt)
    ENDIF
    IF (validate(reply->pds_person_data.mailing_address.source_identifier))
     stat2 = assign(validate(reply->pds_person_data.mailing_address.source_identifier),a
      .source_identifier)
    ENDIF
    IF (validate(reply->pds_person_data.mailing_address.beg_effective_dt_tm))
     stat = assign(validate(reply->pds_person_data.mailing_address.beg_effective_dt_tm),a
      .beg_effective_dt_tm)
    ENDIF
    IF (validate(reply->pds_person_data.mailing_address.end_effective_dt_tm))
     stat = assign(validate(reply->pds_person_data.mailing_address.end_effective_dt_tm),a
      .end_effective_dt_tm)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  IF (comparison_person_id > 0)
   WHERE ph.parent_entity_id=comparison_person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd=home_phone_cd
  ELSE
   WHERE (ph.parent_entity_id=request->pds_exception_id)
    AND ph.parent_entity_name="PM_POST_PROCESS"
    AND ph.phone_type_cd=home_phone_cd
  ENDIF
  FROM phone ph
  DETAIL
   IF (validate(reply->pds_person_data.home_phone.phone_id))
    stat = assign(validate(reply->pds_person_data.home_phone.phone_id),ph.phone_id)
   ENDIF
   reply->pds_person_data.home_phone.phone_number = ph.phone_num
   IF (validate(reply->pds_person_data.home_phone.contact_method_cd))
    stat = assign(validate(reply->pds_person_data.home_phone.contact_method_cd),ph.contact_method_cd)
   ENDIF
   IF (validate(reply->pds_person_data.home_phone.source_identifier))
    stat2 = assign(validate(reply->pds_person_data.home_phone.source_identifier),ph.source_identifier
     )
   ENDIF
   IF (validate(reply->pds_person_data.home_phone.beg_effective_dt_tm))
    stat = assign(validate(reply->pds_person_data.home_phone.beg_effective_dt_tm),ph
     .beg_effective_dt_tm)
   ENDIF
   IF (validate(reply->pds_person_data.home_phone.end_effective_dt_tm))
    stat = assign(validate(reply->pds_person_data.home_phone.end_effective_dt_tm),ph
     .end_effective_dt_tm)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person p,
   person_alias pa,
   person_patient pp
  PLAN (p
   WHERE p.person_id=temp_person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=ssn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pp
   WHERE (pp.person_id= Outerjoin(p.person_id))
    AND (pp.active_ind= Outerjoin(1))
    AND (pp.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (pp.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  DETAIL
   IF (validate(reply->local_person_data.person_id))
    stat = assign(validate(reply->local_person_data.person_id),p.person_id)
   ENDIF
   IF (validate(reply->local_person_data.source_version_number))
    stat2 = assign(validate(reply->local_person_data.source_version_number),pp.source_version_number)
   ENDIF
   reply->local_person_data.birth_dt_tm = p.birth_dt_tm, reply->local_person_data.birth_prec_flag = p
   .birth_prec_flag, reply->local_person_data.birth_tz = p.birth_tz,
   reply->local_person_data.gender_cd = p.sex_cd, reply->local_person_data.nhs_number = pa.alias
   IF (validate(reply->local_person_data.nhs_alias_pool_cd))
    stat = assign(validate(reply->local_person_data.nhs_alias_pool_cd),pa.alias_pool_cd)
   ENDIF
  WITH nocounter
 ;end select
 IF (reply->local_person_data.comparison_data.current_name_ind)
  SELECT INTO "nl:"
   FROM person_name pn
   WHERE pn.person_id=temp_person_id
    AND pn.name_type_cd=current_name_cd
    AND pn.active_ind=1
    AND pn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pn.end_effective_dt_tm > cnvtdatetime(sysdate)
   DETAIL
    IF (validate(reply->local_person_data.current_name.person_name_id))
     stat = assign(validate(reply->local_person_data.current_name.person_name_id),pn.person_name_id)
    ENDIF
    reply->local_person_data.current_name.name_first = pn.name_first, reply->local_person_data.
    current_name.name_last = pn.name_last, reply->local_person_data.current_name.name_prefix = pn
    .name_prefix,
    reply->local_person_data.current_name.name_suffix = pn.name_suffix
    IF (validate(reply->local_person_data.current_name.name_middle))
     stat2 = assign(validate(reply->local_person_data.current_name.name_middle),pn.name_middle)
    ENDIF
    IF (validate(reply->local_person_data.current_name.source_identifier))
     stat2 = assign(validate(reply->local_person_data.current_name.source_identifier),pn
      .source_identifier)
    ENDIF
    IF (validate(reply->local_person_data.current_name.beg_effective_dt_tm))
     stat = assign(validate(reply->local_person_data.current_name.beg_effective_dt_tm),pn
      .beg_effective_dt_tm)
    ENDIF
    IF (validate(reply->local_person_data.current_name.end_effective_dt_tm))
     stat = assign(validate(reply->local_person_data.current_name.end_effective_dt_tm),pn
      .end_effective_dt_tm)
    ENDIF
  ;end select
 ENDIF
 IF (reply->local_person_data.comparison_data.home_address_ind)
  SELECT INTO "nl:"
   FROM address a
   WHERE a.parent_entity_name="PERSON"
    AND a.parent_entity_id=temp_person_id
    AND a.address_type_cd=home_address_cd
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate)
   DETAIL
    IF (validate(reply->local_person_data.home_address.address_id))
     stat = assign(validate(reply->local_person_data.home_address.address_id),a.address_id)
    ENDIF
    reply->local_person_data.home_address.street_addr = a.street_addr, reply->local_person_data.
    home_address.street_addr2 = a.street_addr2, reply->local_person_data.home_address.street_addr3 =
    a.street_addr3
    IF (use_city=1)
     reply->local_person_data.home_address.city = a.city
    ELSE
     reply->local_person_data.home_address.city = a.street_addr4
    ENDIF
    reply->local_person_data.home_address.county = a.county, reply->local_person_data.home_address.
    zipcode = a.zipcode
    IF (validate(reply->local_person_data.home_address.postal_identifier))
     stat2 = assign(validate(reply->local_person_data.home_address.postal_identifier),a
      .postal_identifier)
    ENDIF
    IF (validate(reply->local_person_data.home_address.comment_txt))
     stat2 = assign(validate(reply->local_person_data.home_address.comment_txt),a.comment_txt)
    ENDIF
    IF (validate(reply->local_person_data.home_address.source_identifier))
     stat2 = assign(validate(reply->local_person_data.home_address.source_identifier),a
      .source_identifier)
    ENDIF
    IF (validate(reply->local_person_data.home_address.beg_effective_dt_tm))
     stat = assign(validate(reply->local_person_data.home_address.beg_effective_dt_tm),a
      .beg_effective_dt_tm)
    ENDIF
    IF (validate(reply->local_person_data.home_address.end_effective_dt_tm))
     stat = assign(validate(reply->local_person_data.home_address.end_effective_dt_tm),a
      .end_effective_dt_tm)
    ENDIF
   WITH maxrec = 1, nocounter
  ;end select
  FREE RECORD temp_phone_reply
  RECORD temp_phone_reply(
    1 phone_cnt = i4
    1 phone_list[*]
      2 phone_id = f8
      2 phone_num = vc
      2 contact_method_cd = f8
      2 source_identifier = vc
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 phone_format_cd = f8
  )
  SET phone_index = 1
  SELECT INTO "nl:"
   FROM phone ph
   WHERE ph.parent_entity_id=temp_person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd=home_phone_cd
    AND ph.contact_method_cd IN (tel_cd, 0)
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ph.end_effective_dt_tm > cnvtdatetime(sysdate)
   HEAD REPORT
    phone_cnt = 0
   DETAIL
    phone_cnt += 1
    IF (mod(phone_cnt,10)=1)
     stat = alterlist(temp_phone_reply->phone_list,(phone_cnt+ 9))
    ENDIF
    IF (ph.contact_method_cd=tel_cd)
     phone_index = phone_cnt
    ENDIF
    temp_phone_reply->phone_list[phone_cnt].phone_id = ph.phone_id, temp_phone_reply->phone_list[
    phone_cnt].phone_num = ph.phone_num, temp_phone_reply->phone_list[phone_cnt].contact_method_cd =
    ph.contact_method_cd,
    temp_phone_reply->phone_list[phone_cnt].source_identifier = ph.source_identifier,
    temp_phone_reply->phone_list[phone_cnt].beg_effective_dt_tm = ph.beg_effective_dt_tm,
    temp_phone_reply->phone_list[phone_cnt].end_effective_dt_tm = ph.end_effective_dt_tm,
    temp_phone_reply->phone_list[phone_cnt].phone_format_cd = ph.phone_format_cd
   FOOT REPORT
    stat = alterlist(temp_phone_reply->phone_list,phone_cnt), temp_phone_reply->phone_cnt = phone_cnt
   WITH nocounter
  ;end select
  SET phone_cnt = temp_phone_reply->phone_cnt
  IF (phone_cnt > 0)
   IF (validate(reply->local_person_data.home_phone.phone_id)=1)
    SET reply->local_person_data.home_phone.phone_id = temp_phone_reply->phone_list[phone_index].
    phone_id
   ENDIF
   SET reply->local_person_data.home_phone.phone_number = temp_phone_reply->phone_list[phone_index].
   phone_num
   SET reply->local_person_data.phone_format_cd = temp_phone_reply->phone_list[phone_index].
   phone_format_cd
   IF (validate(reply->local_person_data.home_phone.contact_method_cd)=1)
    SET reply->local_person_data.home_phone.contact_method_cd = tel_cd
   ENDIF
   IF (validate(reply->local_person_data.home_phone.source_identifier)=1)
    SET reply->local_person_data.home_phone.source_identifier = temp_phone_reply->phone_list[
    phone_index].source_identifier
   ENDIF
   IF (validate(reply->local_person_data.home_phone.beg_effective_dt_tm)=1)
    SET reply->local_person_data.home_phone.beg_effective_dt_tm = temp_phone_reply->phone_list[
    phone_index].beg_effective_dt_tm
   ENDIF
   IF (validate(reply->local_person_data.home_phone.end_effective_dt_tm)=1)
    SET reply->local_person_data.home_phone.end_effective_dt_tm = temp_phone_reply->phone_list[
    phone_index].end_effective_dt_tm
   ENDIF
  ENDIF
 ENDIF
 IF (reply->local_person_data.comparison_data.mailing_address_ind)
  FREE RECORD temp_address_reply
  RECORD temp_address_reply(
    1 address_id = f8
    1 street_addr = vc
    1 street_addr2 = vc
    1 street_addr3 = vc
    1 city = vc
    1 county = vc
    1 zipcode = vc
    1 postal_identifier = vc
    1 comment_txt = vc
    1 source_identifier = vc
    1 beg_effective_dt_tm = dq8
    1 end_effective_dt_tm = dq8
  )
  CALL get_local_addresses(mailing_address_cd)
  IF (validate(reply->local_person_data.mailing_address.address_id))
   SET reply->local_person_data.mailing_address.address_id = temp_address_reply->address_id
  ENDIF
  SET reply->local_person_data.mailing_address.street_addr = temp_address_reply->street_addr
  SET reply->local_person_data.mailing_address.street_addr2 = temp_address_reply->street_addr2
  SET reply->local_person_data.mailing_address.street_addr3 = temp_address_reply->street_addr3
  SET reply->local_person_data.mailing_address.city = temp_address_reply->city
  SET reply->local_person_data.mailing_address.county = temp_address_reply->county
  SET reply->local_person_data.mailing_address.zipcode = temp_address_reply->zipcode
  IF (validate(reply->local_person_data.mailing_address.postal_identifier)=1)
   SET reply->local_person_data.mailing_address.postal_identifier = temp_address_reply->
   postal_identifier
  ENDIF
  IF (validate(reply->local_person_data.mailing_address.comment_txt)=1)
   SET reply->local_person_data.mailing_address.comment_txt = temp_address_reply->comment_txt
  ENDIF
  IF (validate(reply->local_person_data.mailing_address.source_identifier)=1)
   SET reply->local_person_data.mailing_address.source_identifier = temp_address_reply->
   source_identifier
  ENDIF
  IF (validate(reply->local_person_data.mailing_address.beg_effective_dt_tm)=1)
   SET reply->local_person_data.mailing_address.beg_effective_dt_tm = temp_address_reply->
   beg_effective_dt_tm
  ENDIF
  IF (validate(reply->local_person_data.mailing_address.end_effective_dt_tm)=1)
   SET reply->local_person_data.mailing_address.end_effective_dt_tm = temp_address_reply->
   end_effective_dt_tm
  ENDIF
 ENDIF
 IF (reply->local_person_data.comparison_data.temp_address_ind)
  FREE RECORD temp_address_reply
  RECORD temp_address_reply(
    1 address_id = f8
    1 street_addr = vc
    1 street_addr2 = vc
    1 street_addr3 = vc
    1 city = vc
    1 county = vc
    1 zipcode = vc
    1 postal_identifier = vc
    1 comment_txt = vc
    1 source_identifier = vc
    1 beg_effective_dt_tm = dq8
    1 end_effective_dt_tm = dq8
  )
  CALL get_local_addresses(temp_address_cd)
  IF (validate(reply->local_person_data.temp_address.address_id))
   SET reply->local_person_data.temp_address.address_id = temp_address_reply->address_id
  ENDIF
  SET reply->local_person_data.temp_address.street_addr = temp_address_reply->street_addr
  SET reply->local_person_data.temp_address.street_addr2 = temp_address_reply->street_addr2
  SET reply->local_person_data.temp_address.street_addr3 = temp_address_reply->street_addr3
  SET reply->local_person_data.temp_address.city = temp_address_reply->city
  SET reply->local_person_data.temp_address.county = temp_address_reply->county
  SET reply->local_person_data.temp_address.zipcode = temp_address_reply->zipcode
  IF (validate(reply->local_person_data.temp_address.postal_identifier)=1)
   SET reply->local_person_data.temp_address.postal_identifier = temp_address_reply->
   postal_identifier
  ENDIF
  IF (validate(reply->local_person_data.temp_address.comment_txt)=1)
   SET reply->local_person_data.temp_address.comment_txt = temp_address_reply->comment_txt
  ENDIF
  IF (validate(reply->local_person_data.temp_address.source_identifier)=1)
   SET reply->local_person_data.temp_address.source_identifier = temp_address_reply->
   source_identifier
  ENDIF
  IF (validate(reply->local_person_data.temp_address.beg_effective_dt_tm)=1)
   SET reply->local_person_data.temp_address.beg_effective_dt_tm = temp_address_reply->
   beg_effective_dt_tm
  ENDIF
  IF (validate(reply->local_person_data.temp_address.end_effective_dt_tm)=1)
   SET reply->local_person_data.temp_address.end_effective_dt_tm = temp_address_reply->
   end_effective_dt_tm
  ENDIF
 ENDIF
 SUBROUTINE (get_local_addresses(address_type_cd=f8) =null)
   IF (validate(temp_address_reply) > 0)
    SELECT INTO "nl:"
     FROM address a
     WHERE a.parent_entity_name="PERSON"
      AND a.parent_entity_id=temp_person_id
      AND a.address_type_cd=address_type_cd
      AND a.active_ind=1
      AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND a.end_effective_dt_tm > cnvtdatetime(sysdate)
     ORDER BY a.beg_effective_dt_tm DESC, a.end_effective_dt_tm DESC, a.address_type_seq,
      a.address_id
     DETAIL
      temp_address_reply->address_id = a.address_id, temp_address_reply->street_addr = a.street_addr,
      temp_address_reply->street_addr2 = a.street_addr2,
      temp_address_reply->street_addr3 = a.street_addr3
      IF (use_city=1)
       temp_address_reply->city = a.city
      ELSE
       temp_address_reply->city = a.street_addr4
      ENDIF
      temp_address_reply->county = a.county, temp_address_reply->zipcode = a.zipcode,
      temp_address_reply->postal_identifier = a.postal_identifier,
      temp_address_reply->comment_txt = a.comment_txt, temp_address_reply->source_identifier = a
      .source_identifier, temp_address_reply->beg_effective_dt_tm = a.beg_effective_dt_tm,
      temp_address_reply->end_effective_dt_tm = a.end_effective_dt_tm
     WITH maxrec = 1, nocounter
    ;end select
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
END GO
