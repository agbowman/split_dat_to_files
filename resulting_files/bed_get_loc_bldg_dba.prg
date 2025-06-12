CREATE PROGRAM bed_get_loc_bldg:dba
 FREE SET reply
 RECORD reply(
   1 location_code_value = f8
   1 short_description = vc
   1 full_description = vc
   1 organization_id = f8
   1 org_name = vc
   1 br_prefix = vc
   1 blist[*]
     2 location_code_value = f8
     2 location_type_code_value = f8
     2 short_description = vc
     2 full_description = vc
     2 sequence = i4
     2 nbr_units = i4
     2 address[*]
       3 address_id = f8
       3 street_addr1 = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 city = vc
       3 state_display = vc
       3 state_code_value = f8
       3 state_mean = vc
       3 county_display = vc
       3 county_code_value = f8
       3 county_mean = vc
       3 zipcode = vc
       3 country_display = vc
       3 country_code_value = f8
       3 country_mean = vc
       3 address_type_code_value = f8
       3 address_type_display = vc
       3 address_type_mean = vc
       3 contact_name = vc
       3 comment_txt = vc
     2 phone[*]
       3 phone_id = f8
       3 phone_type_code_value = f8
       3 phone_type_display = vc
       3 phone_type_mean = vc
       3 phone_format_code_value = f8
       3 phone_format_display = vc
       3 phone_format_mean = vc
       3 phone_num = vc
       3 sequence = i4
       3 description = vc
       3 contact = vc
       3 call_instruction = vc
       3 extension = vc
       3 paging_code = vc
   1 time_zone = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value c,
   location l,
   organization o
  PLAN (c
   WHERE (c.code_value=request->facility_code_value))
   JOIN (l
   WHERE l.location_cd=c.code_value)
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND o.organization_id > 0)
  DETAIL
   reply->location_code_value = c.code_value, reply->short_description = c.display, reply->
   full_description = c.description,
   reply->organization_id = l.organization_id, reply->org_name = o.org_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM time_zone_r tz
  PLAN (tz
   WHERE (tz.parent_entity_id=reply->location_code_value)
    AND tz.parent_entity_name="LOCATION")
  DETAIL
   reply->time_zone = tz.time_zone
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_organization bo
  PLAN (bo
   WHERE (bo.organization_id=reply->organization_id))
  DETAIL
   reply->br_prefix = bo.br_prefix
  WITH nocounter
 ;end select
 SET bcnt = 0
 SELECT INTO "nl:"
  FROM location_group lg,
   location l,
   code_value cv
  PLAN (lg
   WHERE (lg.parent_loc_cd=request->facility_code_value)
    AND lg.active_ind=1
    AND lg.root_loc_cd=0)
   JOIN (l
   WHERE l.location_cd=lg.child_loc_cd
    AND l.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=l.location_cd)
  ORDER BY lg.sequence
  HEAD REPORT
   bcnt = 0, acnt = 0
  DETAIL
   bcnt = (bcnt+ 1), stat = alterlist(reply->blist,bcnt), reply->blist[bcnt].location_code_value = l
   .location_cd,
   reply->blist[bcnt].location_type_code_value = l.location_type_cd, reply->blist[bcnt].
   short_description = cv.display, reply->blist[bcnt].full_description = cv.description,
   reply->blist[bcnt].sequence = lg.sequence
  WITH nocounter
 ;end select
 DECLARE get_address_parse = vc
 SET get_address_parse = "a.active_ind = 1"
 IF (validate(request->exclude_ineffective_address_ind))
  IF (request->exclude_ineffective_address_ind)
   SET get_address_parse = build(get_address_parse,
    " and a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
    " and a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  ENDIF
 ENDIF
 IF (bcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = bcnt),
    address a,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4
   PLAN (d)
    JOIN (a
    WHERE a.parent_entity_name="LOCATION"
     AND (a.parent_entity_id=reply->blist[d.seq].location_code_value)
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
   HEAD d.seq
    acnt = 0
   DETAIL
    acnt = (acnt+ 1), stat = alterlist(reply->blist[d.seq].address,acnt), reply->blist[d.seq].
    address[acnt].address_id = a.address_id,
    reply->blist[d.seq].address[acnt].address_type_code_value = a.address_type_cd
    IF (cv1.code_value > 0)
     reply->blist[d.seq].address[acnt].address_type_display = cv1.display, reply->blist[d.seq].
     address[acnt].address_type_mean = cv1.cdf_meaning
    ENDIF
    reply->blist[d.seq].address[acnt].street_addr1 = a.street_addr, reply->blist[d.seq].address[acnt]
    .street_addr2 = a.street_addr2, reply->blist[d.seq].address[acnt].street_addr3 = a.street_addr3,
    reply->blist[d.seq].address[acnt].street_addr4 = a.street_addr4, reply->blist[d.seq].address[acnt
    ].city = a.city, reply->blist[d.seq].address[acnt].state_code_value = a.state_cd
    IF (trim(a.state) > " ")
     reply->blist[d.seq].address[acnt].state_display = a.state
    ELSEIF (cv2.code_value > 0
     AND trim(cv2.display) > " ")
     reply->blist[d.seq].address[acnt].state_display = cv2.display, reply->blist[d.seq].address[acnt]
     .state_mean = cv2.cdf_meaning
    ENDIF
    reply->blist[d.seq].address[acnt].zipcode = a.zipcode, reply->blist[d.seq].address[acnt].
    county_code_value = a.county_cd
    IF (trim(a.county) > " ")
     reply->blist[d.seq].address[acnt].county_display = a.county
    ELSEIF (cv3.code_value > 0
     AND trim(cv3.display) > " ")
     reply->blist[d.seq].address[acnt].county_display = cv3.display, reply->blist[d.seq].address[acnt
     ].county_mean = cv3.cdf_meaning
    ENDIF
    reply->blist[d.seq].address[acnt].country_code_value = a.country_cd
    IF (trim(a.country) > " ")
     reply->blist[d.seq].address[acnt].country_display = a.country
    ELSEIF (cv4.code_value > 0
     AND trim(cv4.display) > " ")
     reply->blist[d.seq].address[acnt].country_display = cv4.display, reply->blist[d.seq].address[
     acnt].country_mean = cv4.cdf_meaning
    ENDIF
    reply->blist[d.seq].address[acnt].contact_name = a.contact_name, reply->blist[d.seq].address[acnt
    ].comment_txt = a.comment_txt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = bcnt),
    phone p,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (p
    WHERE p.parent_entity_name="LOCATION"
     AND (p.parent_entity_id=reply->blist[d.seq].location_code_value)
     AND p.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=p.phone_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=p.phone_format_cd)
   HEAD REPORT
    pcnt = 0
   HEAD d.seq
    pcnt = 0
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->blist[d.seq].phone,pcnt), reply->blist[d.seq].phone[
    pcnt].phone_id = p.phone_id,
    reply->blist[d.seq].phone[pcnt].phone_type_code_value = p.phone_type_cd
    IF (cv1.code_value > 0)
     reply->blist[d.seq].phone[pcnt].phone_type_display = cv1.display, reply->blist[d.seq].phone[pcnt
     ].phone_type_mean = cv1.cdf_meaning
    ENDIF
    reply->blist[d.seq].phone[pcnt].phone_format_code_value = p.phone_format_cd
    IF (cv2.code_value > 0)
     reply->blist[d.seq].phone[pcnt].phone_format_display = cv2.display, reply->blist[d.seq].phone[
     pcnt].phone_format_mean = cv2.cdf_meaning
    ENDIF
    reply->blist[d.seq].phone[pcnt].phone_num = p.phone_num, reply->blist[d.seq].phone[pcnt].sequence
     = p.phone_type_seq, reply->blist[d.seq].phone[pcnt].description = p.description,
    reply->blist[d.seq].phone[pcnt].contact = p.contact, reply->blist[d.seq].phone[pcnt].
    call_instruction = p.call_instruction, reply->blist[d.seq].phone[pcnt].extension = p.extension,
    reply->blist[d.seq].phone[pcnt].paging_code = p.paging_code
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = bcnt),
    location_group lg,
    location l
   PLAN (d)
    JOIN (lg
    WHERE (lg.parent_loc_cd=reply->blist[d.seq].location_code_value)
     AND lg.active_ind=1
     AND lg.root_loc_cd=0)
    JOIN (l
    WHERE l.location_cd=lg.child_loc_cd
     AND l.active_ind=1)
   HEAD REPORT
    cnt = 0
   HEAD d.seq
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
   FOOT  d.seq
    reply->blist[d.seq].nbr_units = cnt
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF ((reply->location_code_value > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
