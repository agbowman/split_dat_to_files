CREATE PROGRAM bed_aud_org_fltr:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 alias_pool_ind = i2
    1 org_types[*]
      2 code_value = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   01 olist[*]
     02 organization_id = f8
     02 org_name = vc
     02 org_prefix = vc
     02 logical_domain_id = f8
     02 federal_tax_id_nbr = vc
     02 active_ind = i2
     02 org_type[*]
       03 org_type_code_value = f8
       03 org_type_display = vc
       03 org_type_mean = vc
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
     02 facility
       03 code_value = f8
       03 description = vc
       03 display = vc
       03 mean = vc
       03 time_zone_id = f8
       03 time_zone_display = c100
     02 alias[*]
       03 alias = vc
       03 org_alias_type_cd = f8
       03 org_alias_type_disp = vc
       03 alias_pool_display = vc
       03 mask = vc
       03 next_nbr = f8
       03 max_nbr = f8
       03 dup_allowed_flag = i2
       03 system_assign_flag = i2
     02 alias_pool[*]
       03 alias_pool_cd = f8
       03 alias_pool_disp = vc
       03 alias_entity_alias_type_cd = f8
       03 alias_entity_alias_type_disp = vc
       03 alias_pool_category = vc
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET total_col = 26
 SET fac_cd = uar_get_code_by("MEANING",222,"FACILITY")
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 SET reqorgtype = size(request->org_types,5)
 DECLARE orgtypeparse = vc
 SET orgtypeparse = "otr.org_type_cd in ("
 FOR (o = 1 TO reqorgtype)
  IF (o > 1)
   SET orgtypeparse = build(orgtypeparse,",")
  ENDIF
  SET orgtypeparse = build(orgtypeparse,request->org_types[o].code_value)
 ENDFOR
 SET orgtypeparse = build(orgtypeparse,")")
 SET ocnt = 0
 IF (reqorgtype > 0)
  SELECT INTO "nl:"
   FROM organization o,
    br_organization bo,
    org_type_reltn otr
   PLAN (o
    WHERE o.active_ind=1
     AND o.data_status_cd=auth_cd
     AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (otr
    WHERE otr.organization_id=o.organization_id
     AND parser(orgtypeparse)
     AND otr.active_ind=1
     AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND otr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (bo
    WHERE bo.organization_id=outerjoin(o.organization_id))
   ORDER BY cnvtupper(o.org_name), o.organization_id
   HEAD REPORT
    ocnt = 0
   HEAD o.organization_id
    ocnt = (ocnt+ 1), stat = alterlist(temp->olist,ocnt), temp->olist[ocnt].organization_id = o
    .organization_id,
    temp->olist[ocnt].org_name = o.org_name, temp->olist[ocnt].logical_domain_id = o
    .logical_domain_id, temp->olist[ocnt].federal_tax_id_nbr = o.federal_tax_id_nbr
    IF (bo.organization_id > 0)
     temp->olist[ocnt].org_prefix = bo.br_prefix
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM organization o,
    br_organization bo
   PLAN (o
    WHERE o.active_ind=1
     AND o.data_status_cd=auth_cd
     AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (bo
    WHERE bo.organization_id=outerjoin(o.organization_id))
   ORDER BY cnvtupper(o.org_name)
   HEAD REPORT
    ocnt = 0
   DETAIL
    ocnt = (ocnt+ 1), stat = alterlist(temp->olist,ocnt), temp->olist[ocnt].organization_id = o
    .organization_id,
    temp->olist[ocnt].org_name = o.org_name, temp->olist[ocnt].logical_domain_id = o
    .logical_domain_id, temp->olist[ocnt].federal_tax_id_nbr = o.federal_tax_id_nbr
    IF (bo.organization_id > 0)
     temp->olist[ocnt].org_prefix = bo.br_prefix
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ocnt),
   org_type_reltn otr,
   code_value cv
  PLAN (d)
   JOIN (otr
   WHERE (otr.organization_id=temp->olist[d.seq].organization_id)
    AND otr.active_ind=1)
   JOIN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=278
    AND cv.code_value=otr.org_type_cd)
  HEAD d.seq
   otcnt = 0
  DETAIL
   otcnt = (otcnt+ 1), stat = alterlist(temp->olist[d.seq].org_type,otcnt), temp->olist[d.seq].
   org_type[otcnt].org_type_code_value = otr.org_type_cd,
   temp->olist[d.seq].org_type[otcnt].org_type_display = cv.display, temp->olist[d.seq].org_type[
   otcnt].org_type_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 IF ((request->alias_pool_ind=1))
  SET total_col = 29
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt),
    org_alias_pool_reltn oapr,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (oapr
    WHERE (oapr.organization_id=temp->olist[d.seq].organization_id)
     AND oapr.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=oapr.alias_pool_cd)
    JOIN (cv2
    WHERE cv2.code_value=oapr.alias_entity_alias_type_cd)
   ORDER BY d.seq, oapr.alias_entity_name, cv1.display_key
   HEAD d.seq
    apcnt = 0
   DETAIL
    apcnt = (apcnt+ 1), stat = alterlist(temp->olist[d.seq].alias_pool,apcnt), temp->olist[d.seq].
    alias_pool[apcnt].alias_pool_cd = oapr.alias_pool_cd
    IF (cv1.code_value > 0
     AND cv1.display > " ")
     temp->olist[d.seq].alias_pool[apcnt].alias_pool_disp = cv1.display
    ENDIF
    temp->olist[d.seq].alias_pool[apcnt].alias_entity_alias_type_cd = oapr.alias_entity_alias_type_cd
    IF (cv2.code_value > 0
     AND cv2.display > " ")
     temp->olist[d.seq].alias_pool[apcnt].alias_entity_alias_type_disp = cv2.display
    ENDIF
    temp->olist[d.seq].alias_pool[apcnt].alias_pool_category = oapr.alias_entity_name
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ocnt),
   location l,
   code_value cv
  PLAN (d)
   JOIN (l
   WHERE (l.organization_id=temp->olist[d.seq].organization_id)
    AND l.active_ind=1
    AND l.location_type_cd=fac_cd)
   JOIN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=220
    AND cv.code_value=l.location_cd)
  DETAIL
   temp->olist[d.seq].facility.display = cv.display, temp->olist[d.seq].facility.description = cv
   .description, temp->olist[d.seq].facility.code_value = cv.code_value,
   temp->olist[d.seq].facility.mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ocnt),
   org_type_reltn otr,
   code_value cv
  PLAN (d)
   JOIN (otr
   WHERE (otr.organization_id=temp->olist[d.seq].organization_id)
    AND otr.active_ind=1)
   JOIN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=278
    AND cv.code_value=otr.org_type_cd)
  HEAD d.seq
   otcnt = 0
  DETAIL
   otcnt = (otcnt+ 1), stat = alterlist(temp->olist[d.seq].org_type,otcnt), temp->olist[d.seq].
   org_type[otcnt].org_type_code_value = otr.org_type_cd,
   temp->olist[d.seq].org_type[otcnt].org_type_display = cv.display, temp->olist[d.seq].org_type[
   otcnt].org_type_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ocnt),
   address a,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   code_value cv4
  PLAN (d)
   JOIN (a
   WHERE a.parent_entity_name="ORGANIZATION"
    AND (a.parent_entity_id=temp->olist[d.seq].organization_id)
    AND a.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=a.address_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=a.state_cd)
   JOIN (cv3
   WHERE cv3.code_value=a.county_cd)
   JOIN (cv4
   WHERE cv4.code_value=a.country_cd)
  HEAD d.seq
   acnt = 0
  DETAIL
   IF (((a.street_addr > " ") OR (((a.street_addr2 > " ") OR (((a.street_addr3 > " ") OR (((a
   .street_addr4 > " ") OR (((a.city > " ") OR (((cv2.display > " ") OR (((a.state > " ") OR (a
   .zipcode > " ")) )) )) )) )) )) )) )
    acnt = (acnt+ 1), stat = alterlist(temp->olist[d.seq].address,acnt), temp->olist[d.seq].address[
    acnt].address_id = a.address_id,
    temp->olist[d.seq].address[acnt].address_type_code_value = a.address_type_cd
    IF (cv1.code_value > 0)
     temp->olist[d.seq].address[acnt].address_type_display = cv1.display, temp->olist[d.seq].address[
     acnt].address_type_mean = cv1.cdf_meaning
    ENDIF
    temp->olist[d.seq].address[acnt].street_addr1 = a.street_addr, temp->olist[d.seq].address[acnt].
    street_addr2 = a.street_addr2, temp->olist[d.seq].address[acnt].street_addr3 = a.street_addr3,
    temp->olist[d.seq].address[acnt].street_addr4 = a.street_addr4, temp->olist[d.seq].address[acnt].
    city = a.city, temp->olist[d.seq].address[acnt].state_code_value = a.state_cd
    IF (trim(a.state) > " ")
     temp->olist[d.seq].address[acnt].state_display = a.state
    ELSEIF (cv2.code_value > 0
     AND trim(cv2.display) > " ")
     temp->olist[d.seq].address[acnt].state_display = cv2.display, temp->olist[d.seq].address[acnt].
     state_mean = cv2.cdf_meaning
    ENDIF
    temp->olist[d.seq].address[acnt].zipcode = a.zipcode, temp->olist[d.seq].address[acnt].
    county_code_value = a.county_cd
    IF (trim(a.county) > " ")
     temp->olist[d.seq].address[acnt].county_display = a.county
    ELSEIF (cv3.code_value > 0
     AND trim(cv3.display) > " ")
     temp->olist[d.seq].address[acnt].county_display = cv3.display, temp->olist[d.seq].address[acnt].
     county_mean = cv3.cdf_meaning
    ENDIF
    temp->olist[d.seq].address[acnt].country_code_value = a.country_cd
    IF (trim(a.country) > " ")
     temp->olist[d.seq].address[acnt].country_display = a.country
    ELSEIF (cv4.code_value > 0
     AND trim(cv4.display) > " ")
     temp->olist[d.seq].address[acnt].country_display = cv4.display, temp->olist[d.seq].address[acnt]
     .country_mean = cv4.cdf_meaning
    ENDIF
    temp->olist[d.seq].address[acnt].contact_name = a.contact_name, temp->olist[d.seq].address[acnt].
    comment_txt = a.comment_txt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ocnt),
   phone p,
   code_value cv1,
   code_value cv2
  PLAN (d)
   JOIN (p
   WHERE p.parent_entity_name="ORGANIZATION"
    AND (p.parent_entity_id=temp->olist[d.seq].organization_id)
    AND p.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=p.phone_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=p.phone_format_cd)
  HEAD d.seq
   pcnt = 0
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(temp->olist[d.seq].phone,pcnt), temp->olist[d.seq].phone[pcnt].
   phone_id = p.phone_id,
   temp->olist[d.seq].phone[pcnt].phone_type_code_value = p.phone_type_cd
   IF (cv1.code_value > 0)
    temp->olist[d.seq].phone[pcnt].phone_type_display = cv1.display, temp->olist[d.seq].phone[pcnt].
    phone_type_mean = cv1.cdf_meaning
   ENDIF
   temp->olist[d.seq].phone[pcnt].phone_format_code_value = p.phone_format_cd
   IF (cv2.code_value > 0)
    temp->olist[d.seq].phone[pcnt].phone_format_display = cv2.display, temp->olist[d.seq].phone[pcnt]
    .phone_format_mean = cv2.cdf_meaning
   ENDIF
   temp->olist[d.seq].phone[pcnt].phone_num = p.phone_num, temp->olist[d.seq].phone[pcnt].sequence =
   p.phone_type_seq, temp->olist[d.seq].phone[pcnt].description = p.description,
   temp->olist[d.seq].phone[pcnt].contact = p.contact, temp->olist[d.seq].phone[pcnt].
   call_instruction = p.call_instruction, temp->olist[d.seq].phone[pcnt].extension = p.extension,
   temp->olist[d.seq].phone[pcnt].paging_code = p.paging_code
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ocnt),
   organization_alias oa,
   code_value cv1,
   alias_pool ap,
   alias_pool_seq aps
  PLAN (d)
   JOIN (oa
   WHERE (oa.organization_id=temp->olist[d.seq].organization_id)
    AND oa.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=oa.org_alias_type_cd)
   JOIN (ap
   WHERE ap.alias_pool_cd=oa.alias_pool_cd
    AND ap.active_ind=1)
   JOIN (aps
   WHERE aps.alias_pool_cd=ap.alias_pool_cd)
  HEAD d.seq
   oacnt = 0
  DETAIL
   oacnt = (oacnt+ 1), stat = alterlist(temp->olist[d.seq].alias,oacnt), temp->olist[d.seq].alias[
   oacnt].alias = oa.alias,
   temp->olist[d.seq].alias[oacnt].org_alias_type_cd = oa.org_alias_type_cd, temp->olist[d.seq].
   alias[oacnt].org_alias_type_disp = cv1.display, temp->olist[d.seq].alias[oacnt].mask = ap
   .format_mask,
   temp->olist[d.seq].alias[oacnt].next_nbr = aps.next_nbr, temp->olist[d.seq].alias[oacnt].max_nbr
    = aps.max_nbr, temp->olist[d.seq].alias[oacnt].dup_allowed_flag = ap.dup_allowed_flag,
   temp->olist[d.seq].alias[oacnt].system_assign_flag = ap.sys_assign_flag, temp->olist[d.seq].alias[
   oacnt].alias_pool_display = ap.description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,total_col)
 SET reply->collist[1].header_text = "Organization Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Short Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Logical Domain ID"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Abbreviation"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Federal Tax ID"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Organization Type"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Address Type"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Street Address"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Street Address 2"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Street Address 3"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Street Address 4"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "City"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "State"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "ZIP Code"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Country"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Phone Number Type"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Phone Number"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Organization Identifier Type"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Organization Identifier"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Organization Identifier Alias Pool"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Identifier Pool Mask"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 1
 SET reply->collist[22].header_text = "Identifier Next Number"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 1
 SET reply->collist[23].header_text = "Identifier Max Number"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 1
 SET reply->collist[24].header_text = "Identifier Duplicate Allowed"
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 1
 SET reply->collist[25].header_text = "Identifier System Assigned"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 1
 SET reply->collist[26].header_text = "Organization ID"
 SET reply->collist[26].data_type = 2
 SET reply->collist[26].hide_ind = 0
 IF ((request->alias_pool_ind=1))
  SET reply->collist[27].header_text = "Associated Alias Pool"
  SET reply->collist[27].data_type = 1
  SET reply->collist[27].hide_ind = 0
  SET reply->collist[28].header_text = "Associated Alias Pool Category"
  SET reply->collist[28].data_type = 1
  SET reply->collist[28].hide_ind = 0
  SET reply->collist[29].header_text = "Associated Alias Pool Type"
  SET reply->collist[29].data_type = 1
  SET reply->collist[29].hide_ind = 0
 ENDIF
 SET lines = 0
 SET records = 0
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = ocnt)
  DETAIL
   lines = maxval(1,size(temp->olist[d.seq].org_type,5),size(temp->olist[d.seq].address,5),size(temp
     ->olist[d.seq].phone,5),size(temp->olist[d.seq].alias,5),
    size(temp->olist[d.seq].alias_pool,5)), stat = alterlist(reply->rowlist,(lines+ records))
   FOR (i = (records+ 1) TO (lines+ records))
     stat = alterlist(reply->rowlist[i].celllist,total_col), reply->rowlist[i].celllist[1].
     string_value = temp->olist[d.seq].org_name, reply->rowlist[i].celllist[2].string_value = temp->
     olist[d.seq].facility.display,
     reply->rowlist[i].celllist[3].double_value = temp->olist[d.seq].logical_domain_id, reply->
     rowlist[i].celllist[26].double_value = temp->olist[d.seq].organization_id
   ENDFOR
   reply->rowlist[(records+ 1)].celllist[4].string_value = temp->olist[d.seq].org_prefix, reply->
   rowlist[(records+ 1)].celllist[5].string_value = temp->olist[d.seq].federal_tax_id_nbr
   FOR (i = 1 TO size(temp->olist[d.seq].org_type,5))
     reply->rowlist[(i+ records)].celllist[6].string_value = temp->olist[d.seq].org_type[i].
     org_type_display
   ENDFOR
   FOR (i = 1 TO size(temp->olist[d.seq].address,5))
     reply->rowlist[(i+ records)].celllist[7].string_value = temp->olist[d.seq].address[i].
     address_type_display, reply->rowlist[(i+ records)].celllist[8].string_value = temp->olist[d.seq]
     .address[i].street_addr1, reply->rowlist[(i+ records)].celllist[9].string_value = temp->olist[d
     .seq].address[i].street_addr2,
     reply->rowlist[(i+ records)].celllist[10].string_value = temp->olist[d.seq].address[i].
     street_addr3, reply->rowlist[(i+ records)].celllist[11].string_value = temp->olist[d.seq].
     address[i].street_addr4, reply->rowlist[(i+ records)].celllist[12].string_value = temp->olist[d
     .seq].address[i].city,
     reply->rowlist[(i+ records)].celllist[13].string_value = temp->olist[d.seq].address[i].
     state_display, reply->rowlist[(i+ records)].celllist[14].string_value = temp->olist[d.seq].
     address[i].zipcode, reply->rowlist[(i+ records)].celllist[15].string_value = temp->olist[d.seq].
     address[i].country_display
   ENDFOR
   FOR (i = 1 TO size(temp->olist[d.seq].phone,5))
    reply->rowlist[(i+ records)].celllist[16].string_value = temp->olist[d.seq].phone[i].
    phone_type_display,reply->rowlist[(i+ records)].celllist[17].string_value = temp->olist[d.seq].
    phone[i].phone_num
   ENDFOR
   FOR (i = 1 TO size(temp->olist[d.seq].alias,5))
     reply->rowlist[(i+ records)].celllist[18].string_value = temp->olist[d.seq].alias[i].
     org_alias_type_disp, reply->rowlist[(i+ records)].celllist[19].string_value = temp->olist[d.seq]
     .alias[i].alias, reply->rowlist[(i+ records)].celllist[20].string_value = temp->olist[d.seq].
     alias[i].alias_pool_display,
     reply->rowlist[(i+ records)].celllist[21].string_value = temp->olist[d.seq].alias[i].mask, reply
     ->rowlist[(i+ records)].celllist[22].string_value = cnvtstring(temp->olist[d.seq].alias[i].
      next_nbr), reply->rowlist[(i+ records)].celllist[23].string_value = cnvtstring(temp->olist[d
      .seq].alias[i].max_nbr)
     IF ((temp->olist[d.seq].alias[i].dup_allowed_flag=1))
      reply->rowlist[(i+ records)].celllist[24].string_value = "Yes"
     ELSEIF ((temp->olist[d.seq].alias[i].dup_allowed_flag=2))
      reply->rowlist[(i+ records)].celllist[24].string_value = "Yes (but warn the user)"
     ELSEIF ((temp->olist[d.seq].alias[i].dup_allowed_flag=3))
      reply->rowlist[(i+ records)].celllist[24].string_value = "No"
     ENDIF
     IF ((temp->olist[d.seq].alias[i].system_assign_flag=1))
      reply->rowlist[(i+ records)].celllist[25].string_value = "Yes"
     ELSE
      reply->rowlist[(i+ records)].celllist[25].string_value = "No"
     ENDIF
   ENDFOR
   FOR (i = 1 TO size(temp->olist[d.seq].alias_pool,5))
     reply->rowlist[(i+ records)].celllist[27].string_value = temp->olist[d.seq].alias_pool[i].
     alias_pool_disp, reply->rowlist[(i+ records)].celllist[28].string_value = temp->olist[d.seq].
     alias_pool[i].alias_pool_category, reply->rowlist[(i+ records)].celllist[29].string_value = temp
     ->olist[d.seq].alias_pool[i].alias_entity_alias_type_disp
   ENDFOR
   records = (records+ lines)
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  CALL echo(build("Row_cnt: ",records))
  IF (records > 30000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (records > 20000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("org_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
