CREATE PROGRAM bed_get_health_plan:dba
 FREE SET reply
 RECORD reply(
   1 addresses[*]
     2 id = f8
     2 sequence = i4
     2 street_addr1 = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 county
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 zipcode = vc
     2 country
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 address_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 contact_name = vc
     2 comment_txt = vc
   1 phones[*]
     2 id = f8
     2 phone_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 phone_format
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 phone_number = vc
     2 sequence = i4
     2 description = vc
     2 contact = vc
     2 call_instruction = vc
     2 extension = vc
     2 paging_code = vc
   1 org_plans[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 organizations[*]
       3 id = f8
       3 name = vc
       3 group_number = vc
       3 group_name = vc
       3 org_plan_reltn_id = f8
   1 aliases[*]
     2 id = f8
     2 alias = vc
     2 alias_pool
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 alias_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
   1 facilities[*]
     2 organization_id = f8
     2 org_name = vc
     2 code_value = f8
     2 display = vc
     2 mean = vc
   1 number_formats[*]
     2 health_plan_field_format_id = f8
     2 field_type_meaning_txt = vc
     2 min_format_mask_char_cnt = i4
     2 format_mask_txt = vc
     2 field_required_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET data_found = "N"
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=222
   AND c.cdf_meaning="FACILITY"
  DETAIL
   facility_cd = c.code_value
  WITH nocounter
 ;end select
 DECLARE get_address_parse = vc
 SET get_address_parse = "a.active_ind = 1"
 IF (validate(request->load.exclude_ineffective_address_ind))
  IF (request->load.exclude_ineffective_address_ind)
   SET get_address_parse = build(get_address_parse,
    " and a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
    " and a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  ENDIF
 ENDIF
 IF ((request->load.get_address_ind=1))
  SELECT INTO "nl:"
   FROM address a,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4
   PLAN (a
    WHERE a.parent_entity_name="HEALTH_PLAN"
     AND (a.parent_entity_id=request->plan_id)
     AND parser(get_address_parse))
    JOIN (cv1
    WHERE cv1.code_value=a.address_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=a.state_cd)
    JOIN (cv3
    WHERE cv3.code_value=a.county_cd)
    JOIN (cv4
    WHERE cv4.code_value=a.country_cd)
   HEAD REPORT
    acnt = 0
   DETAIL
    acnt = (acnt+ 1), stat = alterlist(reply->addresses,acnt), reply->addresses[acnt].id = a
    .address_id,
    reply->addresses[acnt].sequence = a.address_type_seq, reply->addresses[acnt].address_type.
    code_value = a.address_type_cd
    IF (cv1.code_value > 0)
     reply->addresses[acnt].address_type.display = cv1.display, reply->addresses[acnt].address_type.
     mean = cv1.cdf_meaning
    ENDIF
    reply->addresses[acnt].street_addr1 = a.street_addr, reply->addresses[acnt].street_addr2 = a
    .street_addr2, reply->addresses[acnt].street_addr3 = a.street_addr3,
    reply->addresses[acnt].street_addr4 = a.street_addr4, reply->addresses[acnt].city = a.city, reply
    ->addresses[acnt].state.code_value = a.state_cd
    IF (trim(a.state) > " ")
     reply->addresses[acnt].state.display = a.state
    ELSEIF (cv2.code_value > 0
     AND trim(cv2.display) > " ")
     reply->addresses[acnt].state.display = cv2.display, reply->addresses[acnt].state.mean = cv2
     .cdf_meaning
    ENDIF
    reply->addresses[acnt].zipcode = a.zipcode, reply->addresses[acnt].county.code_value = a
    .county_cd
    IF (trim(a.county) > " ")
     reply->addresses[acnt].county.display = a.county
    ELSEIF (cv3.code_value > 0
     AND trim(cv3.display) > " ")
     reply->addresses[acnt].county.display = cv3.display, reply->addresses[acnt].county.mean = cv3
     .cdf_meaning
    ENDIF
    reply->addresses[acnt].country.code_value = a.country_cd
    IF (trim(a.country) > " ")
     reply->addresses[acnt].country.display = a.country
    ELSEIF (cv4.code_value > 0
     AND trim(cv4.display) > " ")
     reply->addresses[acnt].country.display = cv4.display, reply->addresses[acnt].country.mean = cv4
     .cdf_meaning
    ENDIF
    reply->addresses[acnt].contact_name = a.contact_name, reply->addresses[acnt].comment_txt = a
    .comment_txt
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET data_found = "Y"
  ENDIF
 ENDIF
 IF ((request->load.get_phone_ind=1))
  SELECT INTO "nl:"
   FROM phone p,
    code_value cv1,
    code_value cv2
   PLAN (p
    WHERE p.parent_entity_name="HEALTH_PLAN"
     AND (p.parent_entity_id=request->plan_id)
     AND p.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=p.phone_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=p.phone_format_cd)
   HEAD REPORT
    pcnt = 0
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->phones,pcnt), reply->phones[pcnt].id = p.phone_id,
    reply->phones[pcnt].phone_type.code_value = p.phone_type_cd
    IF (cv1.code_value > 0)
     reply->phones[pcnt].phone_type.display = cv1.display, reply->phones[pcnt].phone_type.mean = cv1
     .cdf_meaning
    ENDIF
    reply->phones[pcnt].phone_format.code_value = p.phone_format_cd
    IF (cv2.code_value > 0)
     reply->phones[pcnt].phone_format.display = cv2.display, reply->phones[pcnt].phone_format.mean =
     cv2.cdf_meaning
    ENDIF
    reply->phones[pcnt].phone_number = p.phone_num, reply->phones[pcnt].sequence = p.phone_type_seq,
    reply->phones[pcnt].description = p.description,
    reply->phones[pcnt].contact = p.contact, reply->phones[pcnt].call_instruction = p
    .call_instruction, reply->phones[pcnt].extension = p.extension,
    reply->phones[pcnt].paging_code = p.paging_code
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET data_found = "Y"
  ENDIF
 ENDIF
 IF ((request->load.get_alias_ind=1))
  SELECT INTO "nl:"
   FROM health_plan_alias hpa,
    code_value cv1,
    code_value cv2
   PLAN (hpa
    WHERE (hpa.health_plan_id=request->plan_id)
     AND hpa.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=hpa.alias_pool_cd)
    JOIN (cv2
    WHERE cv2.code_value=hpa.plan_alias_type_cd)
   HEAD REPORT
    acnt = 0
   DETAIL
    acnt = (acnt+ 1), stat = alterlist(reply->aliases,acnt), reply->aliases[acnt].id = hpa
    .health_plan_alias_id,
    reply->aliases[acnt].alias = hpa.alias, reply->aliases[acnt].alias_pool.code_value = hpa
    .alias_pool_cd, reply->aliases[acnt].alias_pool.display = cv1.display,
    reply->aliases[acnt].alias_pool.mean = cv1.cdf_meaning, reply->aliases[acnt].alias_type.
    code_value = hpa.plan_alias_type_cd, reply->aliases[acnt].alias_type.display = cv2.display,
    reply->aliases[acnt].alias_type.mean = cv2.cdf_meaning
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET data_found = "Y"
  ENDIF
 ENDIF
 IF ((request->load.get_facility_ind=1))
  SELECT INTO "nl:"
   FROM filter_entity_reltn f,
    location l,
    code_value cv
   PLAN (f
    WHERE (f.parent_entity_id=request->plan_id)
     AND f.parent_entity_name="HEALTH_PLAN"
     AND f.filter_entity1_name="LOCATION")
    JOIN (l
    WHERE l.location_cd=f.filter_entity1_id
     AND l.location_type_cd=facility_cd
     AND l.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=l.location_cd)
   ORDER BY cv.display
   HEAD REPORT
    fcnt = 0
   HEAD cv.display
    fcnt = (fcnt+ 1), stat = alterlist(reply->facilities,fcnt), reply->facilities[fcnt].code_value =
    cv.code_value,
    reply->facilities[fcnt].display = cv.display, reply->facilities[fcnt].mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET data_found = "Y"
  ENDIF
 ENDIF
 IF ((request->load.get_health_plan_number_formats=1))
  SELECT INTO "nl:"
   FROM health_plan_field_format hpff
   WHERE (hpff.health_plan_id=request->plan_id)
   HEAD REPORT
    hcnt = 0
   DETAIL
    hcnt = (hcnt+ 1), stat = alterlist(reply->number_formats,hcnt), reply->number_formats[hcnt].
    field_type_meaning_txt = hpff.field_type_meaning_txt,
    reply->number_formats[hcnt].health_plan_field_format_id = hpff.health_plan_field_format_id, reply
    ->number_formats[hcnt].min_format_mask_char_cnt = hpff.min_format_mask_char_cnt, reply->
    number_formats[hcnt].format_mask_txt = hpff.format_mask_txt,
    reply->number_formats[hcnt].field_required_ind = hpff.field_required_ind
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET data_found = "Y"
  ENDIF
 ENDIF
#exit_script
 IF (data_found="Y")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
