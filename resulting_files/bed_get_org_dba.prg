CREATE PROGRAM bed_get_org:dba
 FREE SET reply
 RECORD reply(
   01 organization_id = f8
   01 org_name = vc
   01 org_prefix = vc
   01 federal_tax_id_nbr = vc
   01 active_ind = i2
   01 org_type[*]
     02 org_type_code_value = f8
     02 org_type_display = vc
     02 org_type_mean = vc
   01 address[*]
     02 address_id = f8
     02 street_addr1 = vc
     02 street_addr2 = vc
     02 street_addr3 = vc
     02 street_addr4 = vc
     02 city = vc
     02 state_display = vc
     02 state_code_value = f8
     02 state_mean = vc
     02 county_display = vc
     02 county_code_value = f8
     02 county_mean = vc
     02 zipcode = vc
     02 country_display = vc
     02 country_code_value = f8
     02 country_mean = vc
     02 address_type_code_value = f8
     02 address_type_display = vc
     02 address_type_mean = vc
     02 contact_name = vc
     02 comment_txt = vc
   01 phone[*]
     02 phone_id = f8
     02 phone_type_code_value = f8
     02 phone_type_display = vc
     02 phone_type_mean = vc
     02 phone_format_code_value = f8
     02 phone_format_display = vc
     02 phone_format_mean = vc
     02 phone_num = vc
     02 sequence = i4
     02 description = vc
     02 contact = vc
     02 call_instruction = vc
     02 extension = vc
     02 paging_code = vc
   01 instr[*]
     02 manufacturer = vc
     02 br_instr_id = f8
     02 br_instr_org_reltn_id = f8
     02 imodel = vc
     02 itype = vc
     02 iproperties = vc
     02 point_of_care_ind = i2
     02 model_disp = vc
     02 robotics_ind = i2
     02 multiplexor_ind = i2
     02 uni_ind = i2
     02 bi_ind = i2
     02 hq_ind = i2
     02 interface_ind = i2
     02 activity_type_disp = vc
     02 activity_type_mean = vc
   01 facility
     02 code_value = f8
     02 description = vc
     02 display = vc
     02 mean = vc
     02 time_zone_id = f8
     02 time_zone_display = c100
     02 address[*]
       03 address_id = f8
       03 street_addr1 = vc
       03 street_addr2 = vc
       03 street_addr3 = vc
       03 street_addr4 = vc
       03 city = vc
       03 state_display = vc
       03 state_code_value = f8
       03 state_mean = vc
       03 county_display = vc
       03 county_code_value = f8
       03 county_mean = vc
       03 zipcode = vc
       03 country_display = vc
       03 country_code_value = f8
       03 country_mean = vc
       03 address_type_code_value = f8
       03 address_type_display = vc
       03 address_type_mean = vc
       03 contact_name = vc
       03 comment_txt = vc
     02 phone[*]
       03 phone_id = f8
       03 phone_type_code_value = f8
       03 phone_type_display = vc
       03 phone_type_mean = vc
       03 phone_format_code_value = f8
       03 phone_format_display = vc
       03 phone_format_mean = vc
       03 phone_num = vc
       03 sequence = i4
       03 description = vc
       03 contact = vc
       03 call_instruction = vc
       03 extension = vc
       03 paging_code = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET location_cd = 0
 SET facility_cd = 0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=222
    AND c.cdf_meaning="FACILITY"
    AND c.active_ind=1)
  DETAIL
   facility_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM organization o
  PLAN (o
   WHERE (o.organization_id=request->organization_id))
  DETAIL
   reply->organization_id = o.organization_id, reply->org_name = o.org_name, reply->
   federal_tax_id_nbr = o.federal_tax_id_nbr,
   reply->active_ind = o.active_ind
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM br_organization bo
   PLAN (bo
    WHERE (bo.organization_id=request->organization_id))
   DETAIL
    reply->org_prefix = bo.br_prefix
   WITH nocounter
  ;end select
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM location l,
   code_value cv
  PLAN (l
   WHERE (l.organization_id=request->organization_id)
    AND l.active_ind=1)
   JOIN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=220
    AND cv.cdf_meaning="FACILITY"
    AND cv.code_value=l.location_cd)
  DETAIL
   reply->facility.display = cv.display, reply->facility.description = cv.description, reply->
   facility.code_value = cv.code_value,
   reply->facility.mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM time_zone_r tz,
   br_time_zone b
  PLAN (tz
   WHERE (tz.parent_entity_id=reply->facility.code_value)
    AND tz.parent_entity_name="LOCATION")
   JOIN (b
   WHERE b.time_zone=tz.time_zone)
  DETAIL
   reply->facility.time_zone_display = b.description, reply->facility.time_zone_id = b.time_zone_id
  WITH nocounter
 ;end select
 IF ((request->load.get_org_type_ind=1))
  SET otcnt = 0
  SELECT INTO "nl:"
   FROM org_type_reltn otr,
    code_value cv
   PLAN (otr
    WHERE (otr.organization_id=request->organization_id)
     AND otr.active_ind=1)
    JOIN (cv
    WHERE cv.active_ind=1
     AND cv.code_set=278
     AND cv.cdf_meaning != "FACILITY"
     AND cv.code_value=otr.org_type_cd)
   HEAD REPORT
    otcnt = 0
   DETAIL
    otcnt = (otcnt+ 1), stat = alterlist(reply->org_type,otcnt), reply->org_type[otcnt].
    org_type_code_value = otr.org_type_cd,
    reply->org_type[otcnt].org_type_display = cv.display, reply->org_type[otcnt].org_type_mean = cv
    .cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load.get_address_ind=1))
  SELECT INTO "nl:"
   FROM address a,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4
   PLAN (a
    WHERE a.parent_entity_name="ORGANIZATION"
     AND (a.parent_entity_id=request->organization_id)
     AND a.active_ind=1)
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
    acnt = (acnt+ 1), stat = alterlist(reply->address,acnt), reply->address[acnt].address_id = a
    .address_id,
    reply->address[acnt].address_type_code_value = a.address_type_cd
    IF (cv1.code_value > 0)
     reply->address[acnt].address_type_display = cv1.display, reply->address[acnt].address_type_mean
      = cv1.cdf_meaning
    ENDIF
    reply->address[acnt].street_addr1 = a.street_addr, reply->address[acnt].street_addr2 = a
    .street_addr2, reply->address[acnt].street_addr3 = a.street_addr3,
    reply->address[acnt].street_addr4 = a.street_addr4, reply->address[acnt].city = a.city, reply->
    address[acnt].state_code_value = a.state_cd
    IF (trim(a.state) > " ")
     reply->address[acnt].state_display = a.state
    ELSEIF (cv2.code_value > 0
     AND trim(cv2.display) > " ")
     reply->address[acnt].state_display = cv2.display, reply->address[acnt].state_mean = cv2
     .cdf_meaning
    ENDIF
    reply->address[acnt].zipcode = a.zipcode, reply->address[acnt].county_code_value = a.county_cd
    IF (trim(a.county) > " ")
     reply->address[acnt].county_display = a.county
    ELSEIF (cv3.code_value > 0
     AND trim(cv3.display) > " ")
     reply->address[acnt].county_display = cv3.display, reply->address[acnt].county_mean = cv3
     .cdf_meaning
    ENDIF
    reply->address[acnt].country_code_value = a.country_cd
    IF (trim(a.country) > " ")
     reply->address[acnt].country_display = a.country
    ELSEIF (cv4.code_value > 0
     AND trim(cv4.display) > " ")
     reply->address[acnt].country_display = cv4.display, reply->address[acnt].country_mean = cv4
     .cdf_meaning
    ENDIF
    reply->address[acnt].contact_name = a.contact_name, reply->address[acnt].comment_txt = a
    .comment_txt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM address a,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4
   PLAN (a
    WHERE a.parent_entity_name="LOCATION"
     AND (a.parent_entity_id=reply->facility.code_value)
     AND a.active_ind=1)
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
    acnt = (acnt+ 1), stat = alterlist(reply->facility.address,acnt), reply->facility.address[acnt].
    address_id = a.address_id,
    reply->facility.address[acnt].address_type_code_value = a.address_type_cd
    IF (cv1.code_value > 0)
     reply->facility.address[acnt].address_type_display = cv1.display, reply->facility.address[acnt].
     address_type_mean = cv1.cdf_meaning
    ENDIF
    reply->facility.address[acnt].street_addr1 = a.street_addr, reply->facility.address[acnt].
    street_addr2 = a.street_addr2, reply->facility.address[acnt].street_addr3 = a.street_addr3,
    reply->facility.address[acnt].street_addr4 = a.street_addr4, reply->facility.address[acnt].city
     = a.city, reply->facility.address[acnt].state_code_value = a.state_cd
    IF (trim(a.state) > " ")
     reply->facility.address[acnt].state_display = a.state
    ELSEIF (cv2.code_value > 0
     AND trim(cv2.display) > " ")
     reply->facility.address[acnt].state_display = cv2.display, reply->facility.address[acnt].
     state_mean = cv2.cdf_meaning
    ENDIF
    reply->facility.address[acnt].zipcode = a.zipcode, reply->facility.address[acnt].
    county_code_value = a.county_cd
    IF (trim(a.county) > " ")
     reply->facility.address[acnt].county_display = a.county
    ELSEIF (cv3.code_value > 0
     AND trim(cv3.display) > " ")
     reply->facility.address[acnt].county_display = cv3.display, reply->facility.address[acnt].
     county_mean = cv3.cdf_meaning
    ENDIF
    reply->facility.address[acnt].country_code_value = a.country_cd
    IF (trim(a.country) > " ")
     reply->facility.address[acnt].country_display = a.country
    ELSEIF (cv4.code_value > 0
     AND trim(cv4.display) > " ")
     reply->facility.address[acnt].country_display = cv4.display, reply->facility.address[acnt].
     country_mean = cv4.cdf_meaning
    ENDIF
    reply->facility.address[acnt].contact_name = a.contact_name, reply->facility.address[acnt].
    comment_txt = a.comment_txt
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load.get_phone_ind=1))
  SELECT INTO "nl:"
   FROM phone p,
    code_value cv1,
    code_value cv2
   PLAN (p
    WHERE p.parent_entity_name="ORGANIZATION"
     AND (p.parent_entity_id=request->organization_id)
     AND p.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=p.phone_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=p.phone_format_cd)
   HEAD REPORT
    pcnt = 0
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->phone,pcnt), reply->phone[pcnt].phone_id = p.phone_id,
    reply->phone[pcnt].phone_type_code_value = p.phone_type_cd
    IF (cv1.code_value > 0)
     reply->phone[pcnt].phone_type_display = cv1.display, reply->phone[pcnt].phone_type_mean = cv1
     .cdf_meaning
    ENDIF
    reply->phone[pcnt].phone_format_code_value = p.phone_format_cd
    IF (cv2.code_value > 0)
     reply->phone[pcnt].phone_format_display = cv2.display, reply->phone[pcnt].phone_format_mean =
     cv2.cdf_meaning
    ENDIF
    reply->phone[pcnt].phone_num = p.phone_num, reply->phone[pcnt].sequence = p.phone_type_seq, reply
    ->phone[pcnt].description = p.description,
    reply->phone[pcnt].contact = p.contact, reply->phone[pcnt].call_instruction = p.call_instruction,
    reply->phone[pcnt].extension = p.extension,
    reply->phone[pcnt].paging_code = p.paging_code
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM phone p,
    code_value cv1,
    code_value cv2
   PLAN (p
    WHERE p.parent_entity_name="LOCATION"
     AND (p.parent_entity_id=reply->facility.code_value)
     AND p.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=p.phone_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=p.phone_format_cd)
   HEAD REPORT
    pcnt = 0
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->facility.phone,pcnt), reply->facility.phone[pcnt].
    phone_id = p.phone_id,
    reply->facility.phone[pcnt].phone_type_code_value = p.phone_type_cd
    IF (cv1.code_value > 0)
     reply->facility.phone[pcnt].phone_type_display = cv1.display, reply->facility.phone[pcnt].
     phone_type_mean = cv1.cdf_meaning
    ENDIF
    reply->facility.phone[pcnt].phone_format_code_value = p.phone_format_cd
    IF (cv2.code_value > 0)
     reply->facility.phone[pcnt].phone_format_display = cv2.display, reply->facility.phone[pcnt].
     phone_format_mean = cv2.cdf_meaning
    ENDIF
    reply->facility.phone[pcnt].phone_num = p.phone_num, reply->facility.phone[pcnt].sequence = p
    .phone_type_seq, reply->facility.phone[pcnt].description = p.description,
    reply->facility.phone[pcnt].contact = p.contact, reply->facility.phone[pcnt].call_instruction = p
    .call_instruction, reply->facility.phone[pcnt].extension = p.extension,
    reply->facility.phone[pcnt].paging_code = p.paging_code
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load.get_instr_ind=1))
  SET icnt = 0
  SELECT INTO "nl:"
   FROM br_instr_org_reltn bior,
    code_value c
   PLAN (bior
    WHERE (bior.organization_id=request->organization_id))
    JOIN (c
    WHERE c.code_set=outerjoin(106)
     AND c.cdf_meaning=outerjoin(bior.activity_type_mean))
   ORDER BY bior.manufacturer, bior.model_disp
   HEAD REPORT
    icnt = 0
   DETAIL
    icnt = (icnt+ 1), stat = alterlist(reply->instr,icnt), reply->instr[icnt].manufacturer = bior
    .manufacturer,
    reply->instr[icnt].br_instr_id = bior.br_instr_id, reply->instr[icnt].br_instr_org_reltn_id =
    bior.br_instr_org_reltn_id, reply->instr[icnt].imodel = bior.model,
    reply->instr[icnt].model_disp = bior.model_disp, reply->instr[icnt].itype = bior.type, reply->
    instr[icnt].activity_type_mean = bior.activity_type_mean
    IF (c.code_value > 0)
     reply->instr[icnt].activity_type_disp = c.display
    ENDIF
    reply->instr[icnt].point_of_care_ind = bior.poc_ind, reply->instr[icnt].robotics_ind = bior
    .robotics_ind, reply->instr[icnt].multiplexor_ind = bior.multiplexor_ind,
    reply->instr[icnt].uni_ind = bior.uni_ind, reply->instr[icnt].bi_ind = bior.bi_ind, reply->instr[
    icnt].hq_ind = bior.hq_ind,
    reply->instr[icnt].interface_ind = bior.interface_ind
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
