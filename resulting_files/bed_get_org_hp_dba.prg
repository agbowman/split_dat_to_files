CREATE PROGRAM bed_get_org_hp:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 org_types[*]
      2 code_value = f8
      2 display = vc
      2 mean = vc
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
    1 health_plans[*]
      2 id = f8
      2 name = vc
      2 group_number = vc
      2 group_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 default_helath_plan[*]
      2 id = f8
      2 name = vc
      2 group_number = vc
      2 group_name = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET data_found = "N"
 SET sponsor_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=370
    AND c.cdf_meaning="SPONSOR")
  DETAIL
   sponsor_cd = c.code_value
  WITH nocounter
 ;end select
 SET carrier_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=370
    AND c.cdf_meaning="CARRIER")
  DETAIL
   carrier_cd = c.code_value
  WITH nocounter
 ;end select
 SET dfaltcrsovrh_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=370
    AND c.cdf_meaning="DFALTCRSOVRH")
  DETAIL
   dfaltcrsovrh_cd = c.code_value
  WITH nocounter
 ;end select
 IF ((request->load.get_org_type_ind=1))
  SELECT INTO "nl:"
   FROM org_type_reltn otr,
    code_value cv
   PLAN (otr
    WHERE (otr.organization_id=request->organization_id)
     AND otr.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=otr.org_type_cd
     AND cv.cdf_meaning != "FACILITY"
     AND cv.active_ind=1)
   HEAD REPORT
    otcnt = 0
   DETAIL
    otcnt = (otcnt+ 1), stat = alterlist(reply->org_types,otcnt), reply->org_types[otcnt].code_value
     = otr.org_type_cd,
    reply->org_types[otcnt].display = cv.display, reply->org_types[otcnt].mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET data_found = "Y"
  ENDIF
 ENDIF
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
    WHERE a.parent_entity_name="ORGANIZATION"
     AND (a.parent_entity_id=request->organization_id)
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
   FROM organization_alias oa,
    code_value cv1,
    code_value cv2
   PLAN (oa
    WHERE (oa.organization_id=request->organization_id)
     AND oa.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=oa.alias_pool_cd)
    JOIN (cv2
    WHERE cv2.code_value=oa.org_alias_type_cd)
   HEAD REPORT
    acnt = 0
   DETAIL
    acnt = (acnt+ 1), stat = alterlist(reply->aliases,acnt), reply->aliases[acnt].id = oa
    .organization_alias_id,
    reply->aliases[acnt].alias = oa.alias, reply->aliases[acnt].alias_pool.code_value = cv1
    .code_value, reply->aliases[acnt].alias_pool.display = cv1.display,
    reply->aliases[acnt].alias_pool.mean = cv1.cdf_meaning, reply->aliases[acnt].alias_type.
    code_value = cv2.code_value, reply->aliases[acnt].alias_type.display = cv2.display,
    reply->aliases[acnt].alias_type.mean = cv2.cdf_meaning
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET data_found = "Y"
  ENDIF
 ENDIF
 IF ((request->load.get_health_plan_ind=1))
  SET data_partition_ind = 0
  SET field_found = 0
  RANGE OF c IS code_value_set
  SET field_found = validate(c.br_client_id)
  FREE RANGE c
  IF (field_found=0)
   SET prg_exists_ind = 0
   SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
   IF (prg_exists_ind > 0)
    SET field_found = 0
    RANGE OF p IS prsnl
    SET field_found = validate(p.logical_domain_id)
    FREE RANGE p
    IF (field_found=1)
     SET data_partition_ind = 1
     FREE SET acm_get_acc_logical_domains_req
     RECORD acm_get_acc_logical_domains_req(
       1 write_mode_ind = i2
       1 concept = i4
     )
     FREE SET acm_get_acc_logical_domains_rep
     RECORD acm_get_acc_logical_domains_rep(
       1 logical_domain_grp_id = f8
       1 logical_domains_cnt = i4
       1 logical_domains[*]
         2 logical_domain_id = f8
       1 status_block
         2 status_ind = i2
         2 error_code = i4
     )
     SET acm_get_acc_logical_domains_req->write_mode_ind = 0
     SET acm_get_acc_logical_domains_req->concept = 4
     EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
     replace("REPLY",acm_get_acc_logical_domains_rep)
    ENDIF
   ENDIF
  ENDIF
  DECLARE hp_parse = vc
  SET hp_parse = "hp.active_ind = 1"
  IF (data_partition_ind=1)
   IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
    SET hp_parse = concat(hp_parse," and hp.logical_domain_id in (")
    FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
      IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
       SET hp_parse = build(hp_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
        logical_domain_id,")")
      ELSE
       SET hp_parse = build(hp_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
        logical_domain_id,",")
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM org_plan_reltn opr,
    health_plan hp
   PLAN (opr
    WHERE (opr.organization_id=request->organization_id)
     AND opr.active_ind=1
     AND opr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND opr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (hp
    WHERE hp.health_plan_id=opr.health_plan_id
     AND parser(hp_parse))
   ORDER BY opr.health_plan_id, opr.org_plan_reltn_cd
   HEAD REPORT
    hcnt = 0, dhcnt = 0
   HEAD opr.health_plan_id
    IF ((((request->load.get_sponsor_ind=1)
     AND opr.org_plan_reltn_cd=sponsor_cd) OR ((request->load.get_carrier_ind=1)
     AND opr.org_plan_reltn_cd=carrier_cd)) )
     hcnt = (hcnt+ 1), stat = alterlist(reply->health_plans,hcnt), reply->health_plans[hcnt].id = opr
     .health_plan_id,
     reply->health_plans[hcnt].name = hp.plan_name, reply->health_plans[hcnt].group_number = opr
     .group_nbr, reply->health_plans[hcnt].group_name = opr.group_name
    ENDIF
   HEAD opr.org_plan_reltn_cd
    IF ((request->load.get_dfaltcrsovrh_ind=1)
     AND opr.org_plan_reltn_cd=dfaltcrsovrh_cd)
     dhcnt = (dhcnt+ 1), stat = alterlist(reply->default_helath_plan,dhcnt), reply->
     default_helath_plan[dhcnt].id = opr.health_plan_id,
     reply->default_helath_plan[dhcnt].name = hp.plan_name, reply->default_helath_plan[dhcnt].
     group_number = opr.group_nbr, reply->default_helath_plan[dhcnt].group_name = opr.group_name
    ENDIF
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
