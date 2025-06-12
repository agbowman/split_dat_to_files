CREATE PROGRAM bed_get_loc_unit:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    01 location_code_value = f8
    01 blist[*]
      02 location_code_value = f8
      02 ulist[*]
        03 location_code_value = f8
        03 location_type_code_value = f8
        03 location_type_display = vc
        03 location_type_mean = vc
        03 short_description = vc
        03 full_description = vc
        03 sequence = i4
        03 nbr_rooms = i4
        03 ed_ind = i2
        03 icu_ind = i2
        03 addr_list[*]
          04 address_id = f8
          04 street_addr1 = vc
          04 street_addr2 = vc
          04 street_addr3 = vc
          04 street_addr4 = vc
          04 city = vc
          04 state = vc
          04 state_code_value = f8
          04 state_mean = vc
          04 county = vc
          04 county_mean = vc
          04 county_code_value = f8
          04 zipcode = vc
          04 country = vc
          04 country_mean = vc
          04 country_code_value = f8
          04 address_type_code_value = f8
          04 address_type_mean = vc
          04 address_type_display = vc
          04 contact_name = vc
          04 comment_txt = vc
        03 phone_list[*]
          04 phone_id = f8
          04 phone_type_code_value = f8
          04 phone_type_mean = vc
          04 phone_type_display = vc
          04 phone_format_code_value = f8
          04 phone_format_mean = vc
          04 phone_format_display = vc
          04 phone_num = vc
          04 sequence = i4
          04 description = vc
          04 contact = vc
          04 call_instruction = vc
          04 extension = vc
          04 paging_code = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->location_code_value = request->facility_code_value
 SET bcnt = size(request->blist,5)
 SET stat = alterlist(reply->blist,bcnt)
 DECLARE get_address_parse = vc
 SET get_address_parse = "a.active_ind = 1"
 IF (validate(request->exclude_ineffective_address_ind))
  IF (request->exclude_ineffective_address_ind)
   SET get_address_parse = build(get_address_parse,
    " and a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
    " and a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  ENDIF
 ENDIF
 FOR (x = 1 TO bcnt)
   SET reply->blist[x].location_code_value = request->blist[x].location_code_value
   SET ucnt = 0
   SELECT INTO "nl:"
    FROM location_group lg,
     location l,
     code_value cv,
     code_value cv2
    PLAN (lg
     WHERE (lg.parent_loc_cd=reply->blist[x].location_code_value)
      AND ((lg.active_ind=1) OR ((request->inc_inactive_ind=1)))
      AND lg.root_loc_cd=0)
     JOIN (l
     WHERE l.location_cd=lg.child_loc_cd
      AND ((l.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (cv
     WHERE cv.code_value=l.location_cd)
     JOIN (cv2
     WHERE cv2.code_value=l.location_type_cd)
    ORDER BY lg.sequence
    HEAD REPORT
     ucnt = 0
    DETAIL
     ucnt = (ucnt+ 1), stat = alterlist(reply->blist[x].ulist,ucnt), reply->blist[x].ulist[ucnt].
     location_code_value = l.location_cd,
     reply->blist[x].ulist[ucnt].location_type_code_value = l.location_type_cd, reply->blist[x].
     ulist[ucnt].location_type_display = cv2.display, reply->blist[x].ulist[ucnt].location_type_mean
      = cv2.cdf_meaning,
     reply->blist[x].ulist[ucnt].short_description = cv.display, reply->blist[x].ulist[ucnt].
     full_description = cv.description, reply->blist[x].ulist[ucnt].sequence = lg.sequence,
     reply->blist[x].ulist[ucnt].icu_ind = l.icu_ind
    WITH nocounter
   ;end select
   IF (ucnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = ucnt),
      location_group lg,
      location l,
      code_value cv,
      code_value cv1
     PLAN (d)
      JOIN (lg
      WHERE (lg.parent_loc_cd=reply->blist[x].ulist[d.seq].location_code_value)
       AND ((lg.active_ind=1) OR ((request->inc_inactive_ind=1)))
       AND lg.root_loc_cd=0)
      JOIN (l
      WHERE l.location_cd=lg.child_loc_cd
       AND ((l.active_ind=1) OR ((request->inc_inactive_ind=1))) )
      JOIN (cv
      WHERE cv.code_value=lg.parent_loc_cd
       AND cv.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=lg.location_group_type_cd
       AND cv1.cdf_meaning=cv.cdf_meaning
       AND cv1.active_ind=1)
     HEAD d.seq
      cnt = 0
     DETAIL
      cnt = (cnt+ 1)
     FOOT  d.seq
      reply->blist[x].ulist[d.seq].nbr_rooms = cnt
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = ucnt),
      br_name_value br
     PLAN (d)
      JOIN (br
      WHERE br.br_nv_key1="EDUNIT"
       AND br.br_name="CVFROMCS220"
       AND br.br_value=cnvtstring(reply->blist[x].ulist[d.seq].location_code_value))
     ORDER BY d.seq
     HEAD d.seq
      reply->blist[x].ulist[d.seq].ed_ind = 1
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = ucnt),
      address a,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      code_value cv4
     PLAN (d)
      JOIN (a
      WHERE (a.parent_entity_id=reply->blist[x].ulist[d.seq].location_code_value)
       AND a.parent_entity_name="LOCATION"
       AND parser(get_address_parse))
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
      acnt = (acnt+ 1), stat = alterlist(reply->blist[x].ulist[d.seq].addr_list,acnt), reply->blist[x
      ].ulist[d.seq].addr_list[acnt].address_id = a.address_id,
      reply->blist[x].ulist[d.seq].addr_list[acnt].address_type_code_value = a.address_type_cd
      IF (cv1.code_value > 0)
       reply->blist[x].ulist[d.seq].addr_list[acnt].address_type_mean = cv1.cdf_meaning, reply->
       blist[x].ulist[d.seq].addr_list[acnt].address_type_display = cv1.display
      ENDIF
      reply->blist[x].ulist[d.seq].addr_list[acnt].street_addr1 = a.street_addr, reply->blist[x].
      ulist[d.seq].addr_list[acnt].street_addr2 = a.street_addr2, reply->blist[x].ulist[d.seq].
      addr_list[acnt].street_addr3 = a.street_addr3,
      reply->blist[x].ulist[d.seq].addr_list[acnt].street_addr4 = a.street_addr4, reply->blist[x].
      ulist[d.seq].addr_list[acnt].city = a.city, reply->blist[x].ulist[d.seq].addr_list[acnt].
      state_code_value = a.state_cd
      IF (trim(a.state) > " ")
       reply->blist[x].ulist[d.seq].addr_list[acnt].state = a.state
      ELSEIF (cv2.code_value > 0
       AND trim(cv2.display) > " ")
       reply->blist[x].ulist[d.seq].addr_list[acnt].state = cv2.display, reply->blist[x].ulist[d.seq]
       .addr_list[acnt].state_mean = cv2.cdf_meaning
      ENDIF
      reply->blist[x].ulist[d.seq].addr_list[acnt].zipcode = a.zipcode, reply->blist[x].ulist[d.seq].
      addr_list[acnt].county_code_value = a.county_cd
      IF (trim(a.county) > " ")
       reply->blist[x].ulist[d.seq].addr_list[acnt].county = a.county
      ELSEIF (cv3.code_value > 0
       AND trim(cv3.display) > " ")
       reply->blist[x].ulist[d.seq].addr_list[acnt].county = cv3.display, reply->blist[x].ulist[d.seq
       ].addr_list[acnt].county_mean = cv3.cdf_meaning
      ENDIF
      reply->blist[x].ulist[d.seq].addr_list[acnt].country_code_value = a.country_cd
      IF (trim(a.country) > " ")
       reply->blist[x].ulist[d.seq].addr_list[acnt].country = a.country
      ELSEIF (cv4.code_value > 0
       AND trim(cv4.display) > " ")
       reply->blist[x].ulist[d.seq].addr_list[acnt].country = cv4.display, reply->blist[x].ulist[d
       .seq].addr_list[acnt].country_mean = cv4.cdf_meaning
      ENDIF
      reply->blist[x].ulist[d.seq].addr_list[acnt].contact_name = a.contact_name, reply->blist[x].
      ulist[d.seq].addr_list[acnt].comment_txt = a.comment_txt
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = ucnt),
      phone p,
      code_value cv1,
      code_value cv2
     PLAN (d)
      JOIN (p
      WHERE p.parent_entity_name="LOCATION"
       AND (p.parent_entity_id=reply->blist[x].ulist[d.seq].location_code_value)
       AND p.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=p.phone_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=p.phone_format_cd)
     HEAD d.seq
      pcnt = 0
     DETAIL
      pcnt = (pcnt+ 1), stat = alterlist(reply->blist[x].ulist[d.seq].phone_list,pcnt), reply->blist[
      x].ulist[d.seq].phone_list[pcnt].phone_id = p.phone_id,
      reply->blist[x].ulist[d.seq].phone_list[pcnt].phone_type_code_value = p.phone_type_cd
      IF (cv1.code_value > 0)
       reply->blist[x].ulist[d.seq].phone_list[pcnt].phone_type_mean = cv1.cdf_meaning, reply->blist[
       x].ulist[d.seq].phone_list[pcnt].phone_type_display = cv1.display
      ENDIF
      reply->blist[x].ulist[d.seq].phone_list[pcnt].phone_format_code_value = p.phone_format_cd
      IF (cv2.code_value > 0)
       reply->blist[x].ulist[d.seq].phone_list[pcnt].phone_format_mean = cv2.cdf_meaning, reply->
       blist[x].ulist[d.seq].phone_list[pcnt].phone_format_display = cv2.display
      ENDIF
      reply->blist[x].ulist[d.seq].phone_list[pcnt].phone_num = p.phone_num, reply->blist[x].ulist[d
      .seq].phone_list[pcnt].sequence = p.phone_type_seq, reply->blist[x].ulist[d.seq].phone_list[
      pcnt].description = p.description,
      reply->blist[x].ulist[d.seq].phone_list[pcnt].contact = p.contact, reply->blist[x].ulist[d.seq]
      .phone_list[pcnt].call_instruction = p.call_instruction, reply->blist[x].ulist[d.seq].
      phone_list[pcnt].extension = p.extension,
      reply->blist[x].ulist[d.seq].phone_list[pcnt].paging_code = p.paging_code
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 IF (bcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
