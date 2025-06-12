CREATE PROGRAM bed_get_erx_prsnl_reltn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prsnl_reltns[*]
      2 person_id = f8
      2 organization_id = f8
      2 prsnl_reltn_id = f8
      2 prsnl_reltn_seq = i4
      2 addresses[*]
        3 address_id = f8
        3 address_type
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 street_addr = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 street_addr4 = vc
        3 city
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 state
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 zip_code = vc
        3 country
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 county
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 residence_type
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 address_type_seq = i4
        3 contact_name = vc
        3 comment_txt = vc
        3 address_reltn_seq = i4
      2 phones[*]
        3 phone_id = f8
        3 phone_type
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 phone_format
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 phone_num = vc
        3 phone_formatted = vc
        3 sequence = i4
        3 description = vc
        3 contact = vc
        3 call_instruction = vc
        3 extension = vc
        3 paging_code = vc
        3 phone_reltn_seq = i4
      2 alias[*]
        3 alias_id = f8
        3 alias_type
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 alias = vc
        3 alias_pool
          4 code_value = f8
          4 meaning = vc
          4 display = vc
        3 alias_reltn_seq = i4
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
 SET req_cnt = 0
 SET req_cnt = size(request->filters,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET tcnt = 0
 SET demo_reln_code = uar_get_code_by("MEANING",30300,"DEMOGRELTN")
 SET active_status_code = uar_get_code_by("MEANING",48,"ACTIVE")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   prsnl_reltn pr,
   prsnl_reltn_child prc
  PLAN (d)
   JOIN (pr
   WHERE (pr.person_id=request->filters[d.seq].person_id)
    AND trim(pr.parent_entity_name)="ORGANIZATION"
    AND ((pr.parent_entity_id+ 0)=request->filters[d.seq].organization_id)
    AND pr.active_ind=1
    AND pr.active_status_cd=active_status_code
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pr.reltn_type_cd=demo_reln_code)
   JOIN (prc
   WHERE prc.prsnl_reltn_id=pr.prsnl_reltn_id
    AND prc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, pr.display_seq, pr.prsnl_reltn_id,
   prc.parent_entity_name, prc.display_seq, prc.prsnl_reltn_child_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->prsnl_reltns,100)
  HEAD pr.prsnl_reltn_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->prsnl_reltns,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->prsnl_reltns[tcnt].prsnl_reltn_id = pr.prsnl_reltn_id, reply->prsnl_reltns[tcnt].
   prsnl_reltn_seq = pr.display_seq, reply->prsnl_reltns[tcnt].organization_id = pr.parent_entity_id,
   reply->prsnl_reltns[tcnt].person_id = pr.person_id, address_cnt = 0, phone_cnt = 0,
   alias_cnt = 0
  DETAIL
   IF (prc.parent_entity_name="ADDRESS")
    address_cnt = (address_cnt+ 1), stat = alterlist(reply->prsnl_reltns[tcnt].addresses,address_cnt),
    reply->prsnl_reltns[tcnt].addresses[address_cnt].address_id = prc.parent_entity_id,
    reply->prsnl_reltns[tcnt].addresses[address_cnt].address_reltn_seq = prc.display_seq
   ENDIF
   IF (prc.parent_entity_name="PHONE")
    phone_cnt = (phone_cnt+ 1), stat = alterlist(reply->prsnl_reltns[tcnt].phones,phone_cnt), reply->
    prsnl_reltns[tcnt].phones[phone_cnt].phone_id = prc.parent_entity_id,
    reply->prsnl_reltns[tcnt].phones[phone_cnt].phone_reltn_seq = prc.display_seq
   ENDIF
   IF (prc.parent_entity_name="PRSNL_ALIAS")
    alias_cnt = (alias_cnt+ 1), stat = alterlist(reply->prsnl_reltns[tcnt].alias,alias_cnt), reply->
    prsnl_reltns[tcnt].alias[alias_cnt].alias_id = prc.parent_entity_id,
    reply->prsnl_reltns[tcnt].alias[alias_cnt].alias_reltn_seq = prc.display_seq
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->prsnl_reltns,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   (dummyt d2  WITH seq = 1),
   address a,
   code_value c,
   code_value c2,
   code_value c3,
   code_value c4,
   code_value c5,
   code_value c6
  PLAN (d
   WHERE maxrec(d2,size(reply->prsnl_reltns[d.seq].addresses,5)))
   JOIN (d2)
   JOIN (a
   WHERE (a.address_id=reply->prsnl_reltns[d.seq].addresses[d2.seq].address_id)
    AND a.address_id > 0
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (c
   WHERE c.code_value=a.address_type_cd
    AND c.active_ind=1)
   JOIN (c2
   WHERE c2.code_value=outerjoin(a.country_cd)
    AND c2.active_ind=outerjoin(1))
   JOIN (c3
   WHERE c3.code_value=outerjoin(a.county_cd)
    AND c3.active_ind=outerjoin(1))
   JOIN (c4
   WHERE c4.code_value=outerjoin(a.residence_type_cd)
    AND c4.active_ind=outerjoin(1))
   JOIN (c5
   WHERE c5.code_value=outerjoin(a.state_cd)
    AND c5.active_ind=outerjoin(1))
   JOIN (c6
   WHERE c6.code_value=outerjoin(a.city_cd)
    AND c6.active_ind=outerjoin(1))
  ORDER BY d.seq, d2.seq
  DETAIL
   reply->prsnl_reltns[d.seq].addresses[d2.seq].address_type.code_value = a.address_type_cd, reply->
   prsnl_reltns[d.seq].addresses[d2.seq].address_type.display = c.display, reply->prsnl_reltns[d.seq]
   .addresses[d2.seq].address_type.meaning = c.cdf_meaning,
   reply->prsnl_reltns[d.seq].addresses[d2.seq].city.display = a.city
   IF (c6.code_value > 0)
    reply->prsnl_reltns[d.seq].addresses[d2.seq].city.code_value = a.city_cd, reply->prsnl_reltns[d
    .seq].addresses[d2.seq].city.display = c6.display, reply->prsnl_reltns[d.seq].addresses[d2.seq].
    city.meaning = c6.cdf_meaning
   ENDIF
   reply->prsnl_reltns[d.seq].addresses[d2.seq].country.display = a.country
   IF (c2.code_value > 0)
    reply->prsnl_reltns[d.seq].addresses[d2.seq].country.code_value = a.country_cd, reply->
    prsnl_reltns[d.seq].addresses[d2.seq].country.display = c2.display, reply->prsnl_reltns[d.seq].
    addresses[d2.seq].country.meaning = c2.cdf_meaning
   ENDIF
   reply->prsnl_reltns[d.seq].addresses[d2.seq].county.display = a.county
   IF (c3.code_value > 0)
    reply->prsnl_reltns[d.seq].addresses[d2.seq].county.code_value = a.county_cd, reply->
    prsnl_reltns[d.seq].addresses[d2.seq].county.display = c3.display, reply->prsnl_reltns[d.seq].
    addresses[d2.seq].county.meaning = c3.cdf_meaning
   ENDIF
   reply->prsnl_reltns[d.seq].addresses[d2.seq].residence_type.code_value = a.residence_type_cd,
   reply->prsnl_reltns[d.seq].addresses[d2.seq].residence_type.display = c4.display, reply->
   prsnl_reltns[d.seq].addresses[d2.seq].residence_type.meaning = c4.cdf_meaning,
   reply->prsnl_reltns[d.seq].addresses[d2.seq].state.display = a.state
   IF (c5.code_value > 0)
    reply->prsnl_reltns[d.seq].addresses[d2.seq].state.code_value = a.state_cd, reply->prsnl_reltns[d
    .seq].addresses[d2.seq].state.display = c5.display, reply->prsnl_reltns[d.seq].addresses[d2.seq].
    state.meaning = c5.cdf_meaning
   ENDIF
   reply->prsnl_reltns[d.seq].addresses[d2.seq].street_addr = a.street_addr, reply->prsnl_reltns[d
   .seq].addresses[d2.seq].street_addr2 = a.street_addr2, reply->prsnl_reltns[d.seq].addresses[d2.seq
   ].street_addr3 = a.street_addr3,
   reply->prsnl_reltns[d.seq].addresses[d2.seq].street_addr4 = a.street_addr4, reply->prsnl_reltns[d
   .seq].addresses[d2.seq].zip_code = a.zipcode, reply->prsnl_reltns[d.seq].addresses[d2.seq].
   address_type_seq = a.address_type_seq,
   reply->prsnl_reltns[d.seq].addresses[d2.seq].contact_name = a.contact_name, reply->prsnl_reltns[d
   .seq].addresses[d2.seq].comment_txt = a.comment_txt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   (dummyt d2  WITH seq = 1),
   phone p,
   code_value c,
   code_value c2
  PLAN (d
   WHERE maxrec(d2,size(reply->prsnl_reltns[d.seq].phones,5)))
   JOIN (d2)
   JOIN (p
   WHERE (p.phone_id=reply->prsnl_reltns[d.seq].phones[d2.seq].phone_id)
    AND p.phone_id > 0
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (c
   WHERE c.code_value=p.phone_type_cd
    AND c.active_ind=1)
   JOIN (c2
   WHERE c2.code_value=p.phone_format_cd
    AND c.active_ind=1)
  ORDER BY d.seq, d2.seq
  DETAIL
   reply->prsnl_reltns[d.seq].phones[d2.seq].phone_num = p.phone_num, reply->prsnl_reltns[d.seq].
   phones[d2.seq].phone_formatted = cnvtphone(p.phone_num,p.phone_format_cd), reply->prsnl_reltns[d
   .seq].phones[d2.seq].phone_format.code_value = p.phone_format_cd,
   reply->prsnl_reltns[d.seq].phones[d2.seq].phone_format.display = c2.display, reply->prsnl_reltns[d
   .seq].phones[d2.seq].phone_format.meaning = c2.cdf_meaning, reply->prsnl_reltns[d.seq].phones[d2
   .seq].phone_type.code_value = c.code_value,
   reply->prsnl_reltns[d.seq].phones[d2.seq].phone_type.display = c.display, reply->prsnl_reltns[d
   .seq].phones[d2.seq].phone_type.meaning = c.cdf_meaning, reply->prsnl_reltns[d.seq].phones[d2.seq]
   .sequence = p.phone_type_seq,
   reply->prsnl_reltns[d.seq].phones[d2.seq].description = p.description, reply->prsnl_reltns[d.seq].
   phones[d2.seq].contact = p.contact, reply->prsnl_reltns[d.seq].phones[d2.seq].call_instruction = p
   .call_instruction,
   reply->prsnl_reltns[d.seq].phones[d2.seq].extension = p.extension, reply->prsnl_reltns[d.seq].
   phones[d2.seq].paging_code = p.paging_code
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   (dummyt d2  WITH seq = 1),
   prsnl_alias p,
   code_value c,
   code_value c2
  PLAN (d
   WHERE maxrec(d2,size(reply->prsnl_reltns[d.seq].alias,5)))
   JOIN (d2)
   JOIN (p
   WHERE (p.prsnl_alias_id=reply->prsnl_reltns[d.seq].alias[d2.seq].alias_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (c
   WHERE c.code_value=p.prsnl_alias_type_cd
    AND c.active_ind=1)
   JOIN (c2
   WHERE c2.code_value=outerjoin(p.alias_pool_cd)
    AND c2.active_ind=outerjoin(1))
  ORDER BY d.seq, d2.seq
  DETAIL
   reply->prsnl_reltns[d.seq].alias[d2.seq].alias = p.alias
   IF (c2.code_value > 0)
    reply->prsnl_reltns[d.seq].alias[d2.seq].alias_pool.code_value = p.alias_pool_cd, reply->
    prsnl_reltns[d.seq].alias[d2.seq].alias_pool.display = c2.display, reply->prsnl_reltns[d.seq].
    alias[d2.seq].alias_pool.meaning = c2.cdf_meaning
   ENDIF
   reply->prsnl_reltns[d.seq].alias[d2.seq].alias_type.code_value = p.prsnl_alias_type_cd, reply->
   prsnl_reltns[d.seq].alias[d2.seq].alias_type.display = c.display, reply->prsnl_reltns[d.seq].
   alias[d2.seq].alias_type.meaning = c.cdf_meaning
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
