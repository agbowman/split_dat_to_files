CREATE PROGRAM bed_get_organization:dba
 IF ( NOT (validate(reply,0)))
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
      02 beg_effective_dt_tm = dq8
      02 end_effective_dt_tm = dq8
      02 sequence = i4
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
      02 beg_effective_dt_tm = dq8
      02 end_effective_dt_tm = dq8
      02 contact_method_code_value = f8
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
      02 active_ind = i2
    01 begin_effective_dt_tm = dq8
    01 end_effective_dt_tm = dq8
    01 org_alias[*]
      02 org_alias_id = f8
      02 alias = vc
      02 org_alias_type
        03 code_value = f8
        03 meaning = vc
        03 display = vc
      02 alias_pool
        03 code_value = f8
        03 description = vc
    01 research_accounts[*]
      02 research_account_id = f8
      02 name = vc
      02 description = vc
      02 account_nbr = vc
      02 encounter_type
        03 code_value = f8
        03 meaning = vc
        03 display = vc
    1 external_org_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    01 facilities[*]
      02 code_value = f8
      02 description = vc
      02 display = vc
      02 mean = vc
      02 time_zone_id = f8
      02 time_zone_display = c100
      02 active_ind = i2
  )
 ENDIF
 DECLARE location_cd = f8 WITH protect
 DECLARE facility_cd = f8 WITH protect
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
   reply->active_ind = o.active_ind, reply->begin_effective_dt_tm = o.beg_effective_dt_tm, reply->
   end_effective_dt_tm = o.end_effective_dt_tm,
   reply->external_org_ind = o.external_ind
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
 IF (validate(request->load.include_inactive_facility_ind))
  IF ((request->load.include_inactive_facility_ind=0))
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
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(reply->facilities,cnt), reply->facilities[cnt].display = cv
     .display,
     reply->facilities[cnt].description = cv.description, reply->facilities[cnt].code_value = cv
     .code_value, reply->facilities[cnt].mean = cv.cdf_meaning,
     reply->facilities[cnt].active_ind = l.active_ind
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM location l,
     code_value cv
    PLAN (l
     WHERE (l.organization_id=request->organization_id))
     JOIN (cv
     WHERE cv.code_set=220
      AND cv.cdf_meaning="FACILITY"
      AND cv.code_value=l.location_cd)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(reply->facilities,cnt), reply->facilities[cnt].display = cv
     .display,
     reply->facilities[cnt].description = cv.description, reply->facilities[cnt].code_value = cv
     .code_value, reply->facilities[cnt].mean = cv.cdf_meaning,
     reply->facilities[cnt].active_ind = l.active_ind
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 DECLARE region = vc WITH protect
 SET region = fillstring(100," ")
 SELECT INTO "NL:"
  FROM br_client b
  DETAIL
   region = b.region
  WITH nocounter
 ;end select
 IF (region="    *")
  SET region = "USA"
 ENDIF
 DECLARE idx = i4 WITH protect
 DECLARE pos = i4 WITH protect
 SELECT INTO "NL:"
  FROM time_zone_r tz
  PLAN (tz
   WHERE expand(idx,1,size(reply->facilities,5),tz.parent_entity_id,reply->facilities[idx].code_value
    )
    AND tz.parent_entity_name="LOCATION")
  ORDER BY tz.parent_entity_id
  HEAD tz.parent_entity_id
   cnt = locateval(pos,1,size(reply->facilities,5),tz.parent_entity_id,reply->facilities[pos].
    code_value), reply->facilities[cnt].time_zone_display = tz.time_zone, reply->facilities[cnt].
   time_zone_id = 0.0
  WITH nocounter
 ;end select
 IF ((request->load.get_org_type_ind=1))
  DECLARE otcnt = i4 WITH protect
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
     AND ((cv.cdf_meaning != "FACILITY") OR (nullind(cv.cdf_meaning)=1))
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
    .comment_txt, reply->address[acnt].beg_effective_dt_tm = a.beg_effective_dt_tm,
    reply->address[acnt].end_effective_dt_tm = a.end_effective_dt_tm, reply->address[acnt].sequence
     = a.address_type_seq
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
    reply->phone[pcnt].paging_code = p.paging_code, reply->phone[pcnt].beg_effective_dt_tm = p
    .beg_effective_dt_tm, reply->phone[pcnt].end_effective_dt_tm = p.end_effective_dt_tm,
    reply->phone[pcnt].contact_method_code_value = p.contact_method_cd
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load.get_instr_ind=1))
  SET icnt = 0
  SELECT INTO "nl:"
   FROM br_instr_org_reltn bior
   PLAN (bior
    WHERE (bior.organization_id=request->organization_id))
   ORDER BY bior.manufacturer, bior.model_disp
   HEAD REPORT
    icnt = 0
   DETAIL
    icnt = (icnt+ 1), stat = alterlist(reply->instr,icnt), reply->instr[icnt].manufacturer = bior
    .manufacturer,
    reply->instr[icnt].br_instr_id = bior.br_instr_id, reply->instr[icnt].br_instr_org_reltn_id =
    bior.br_instr_org_reltn_id, reply->instr[icnt].imodel = bior.model,
    reply->instr[icnt].model_disp = bior.model_disp, reply->instr[icnt].itype = bior.type, reply->
    instr[icnt].activity_type_mean = bior.activity_type_mean,
    reply->instr[icnt].point_of_care_ind = bior.poc_ind, reply->instr[icnt].robotics_ind = bior
    .robotics_ind, reply->instr[icnt].multiplexor_ind = bior.multiplexor_ind,
    reply->instr[icnt].uni_ind = bior.uni_ind, reply->instr[icnt].bi_ind = bior.bi_ind, reply->instr[
    icnt].hq_ind = bior.hq_ind,
    reply->instr[icnt].interface_ind = bior.interface_ind
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(request->get_org_alias_ind))
  IF ((request->get_org_alias_ind=1))
   SELECT INTO "nl:"
    FROM organization_alias o,
     alias_pool ap,
     code_value c1
    PLAN (o
     WHERE (o.organization_id=request->organization_id)
      AND o.active_ind=1
      AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (ap
     WHERE ap.alias_pool_cd=o.alias_pool_cd
      AND ap.active_ind=1
      AND ap.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ap.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (c1
     WHERE c1.code_value=o.org_alias_type_cd
      AND c1.active_ind=1)
    HEAD REPORT
     acnt = 0, atot_cnt = 0, stat = alterlist(reply->org_alias,10)
    DETAIL
     acnt = (acnt+ 1), atot_cnt = (atot_cnt+ 1)
     IF (acnt > 10)
      stat = alterlist(reply->org_alias,(atot_cnt+ 10)), acnt = 1
     ENDIF
     reply->org_alias[atot_cnt].alias = o.alias, reply->org_alias[atot_cnt].alias_pool.code_value =
     ap.alias_pool_cd, reply->org_alias[atot_cnt].alias_pool.description = ap.description,
     reply->org_alias[atot_cnt].org_alias_id = o.organization_alias_id, reply->org_alias[atot_cnt].
     org_alias_type.code_value = c1.code_value, reply->org_alias[atot_cnt].org_alias_type.meaning =
     c1.cdf_meaning,
     reply->org_alias[atot_cnt].org_alias_type.display = c1.display
    FOOT REPORT
     stat = alterlist(reply->org_alias,atot_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (validate(request->get_research_account_ind))
  IF ((request->get_research_account_ind=1))
   SELECT INTO "nl:"
    FROM research_account r,
     code_value c1
    PLAN (r
     WHERE (r.organization_id=request->organization_id)
      AND r.active_ind=1
      AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (c1
     WHERE c1.code_value=r.encntr_type_cd
      AND c1.active_ind=1)
    HEAD REPORT
     rcnt = 0, rtot_cnt = 0, stat = alterlist(reply->research_accounts,10)
    DETAIL
     rcnt = (rcnt+ 1), rtot_cnt = (rtot_cnt+ 1)
     IF (rcnt > 10)
      stat = alterlist(reply->research_accounts,(rtot_cnt+ 10)), rcnt = 1
     ENDIF
     reply->research_accounts[rtot_cnt].research_account_id = r.research_account_id, reply->
     research_accounts[rtot_cnt].name = r.name, reply->research_accounts[rtot_cnt].description = r
     .description,
     reply->research_accounts[rtot_cnt].account_nbr = r.account_nbr, reply->research_accounts[
     rtot_cnt].encounter_type.code_value = c1.code_value, reply->research_accounts[rtot_cnt].
     encounter_type.meaning = c1.cdf_meaning,
     reply->research_accounts[rtot_cnt].encounter_type.display = c1.display
    FOOT REPORT
     stat = alterlist(reply->research_accounts,rtot_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
