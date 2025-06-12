CREATE PROGRAM cps_get_demographic:dba
 RECORD reply(
   1 person_id = f8
   1 name_full_formatted = vc
   1 name_last = vc
   1 name_first = vc
   1 name_last_key = vc
   1 name_first_key = vc
   1 birth_date_formatted = vc
   1 birth_dt_cd = f8
   1 birth_dt_disp = c40
   1 birth_dt_desc = c40
   1 birth_dt_mean = c12
   1 birth_dt_tm = dq8
   1 ethnic_grp_cd = f8
   1 ethnic_grp_disp = c40
   1 ethnic_grp_desc = c40
   1 ethnic_grp_mean = c12
   1 language_cd = f8
   1 language_disp = c40
   1 language_desc = c40
   1 language_mean = c12
   1 race_cd = f8
   1 race_disp = c40
   1 race_desc = c40
   1 race_mean = c12
   1 sex_cd = f8
   1 sex_disp = c40
   1 sex_desc = c40
   1 sex_mean = c12
   1 address_qual = i4
   1 address[*]
     2 address_id = f8
     2 address_type_cd = f8
     2 address_type_disp = c40
     2 address_type_desc = c40
     2 address_type_mean = c12
     2 address_format_cd = f8
     2 contact_name = vc
     2 residence_type_cd = f8
     2 residence_type_disp = c40
     2 residence_type_desc = c40
     2 residence_type_mean = c12
     2 comment_txt = vc
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state = vc
     2 state_cd = f8
     2 state_disp = c40
     2 state_desc = c40
     2 state_mean = c12
     2 zipcode = c25
     2 zip_code_group_cd = f8
     2 zip_code_group_disp = c40
     2 zip_code_group_desc = c40
     2 zip_code_group_mean = c12
     2 county = vc
     2 county_cd = f8
     2 county_disp = c40
     2 county_desc = c40
     2 county_mean = c12
     2 country = vc
     2 country_cd = f8
     2 country_disp = c40
     2 country_desc = c40
     2 country_mean = c12
     2 residence_cd = f8
     2 residence_disp = c40
     2 residence_desc = c40
     2 residence_mean = c12
     2 mail_stop = vc
   1 phone_qual = i4
   1 phone[*]
     2 phone_id = f8
     2 phone_type_cd = f8
     2 phone_type_disp = c40
     2 phone_type_desc = vc
     2 phone_type_mean = c12
     2 phone_format_cd = f8
     2 phone_num = vc
     2 phone_type_seq = i4
     2 description = vc
     2 contact = vc
     2 call_instruction = vc
     2 extension = vc
     2 paging_code = vc
   1 alias_qual = i4
   1 alias[*]
     2 alias_id = f8
     2 alias_pool_cd = f8
     2 alias_pool_disp = c40
     2 person_alias_type_cd = f8
     2 person_alias_type_disp = c40
     2 person_alias_type_desc = c40
     2 person_alias_type_mean = c12
     2 alias = c200
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 contributor_system_desc = c40
     2 contributor_system_mean = c12
   1 pcp_person_id = f8
   1 pcp_name_full_formatted = vc
   1 pcp_name_first = vc
   1 pcp_name_middle = vc
   1 pcp_name_last = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 SET count1 = 0
 SELECT INTO "NL:"
  p.person_id
  FROM person p,
   (dummyt d  WITH seq = 1),
   encounter e
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (d
   WHERE d.seq=1)
   JOIN (e
   WHERE p.person_id=e.person_id)
  ORDER BY p.person_id, e.encntr_id DESC
  HEAD p.person_id
   reply->person_id = p.person_id, reply->name_full_formatted = p.name_full_formatted, reply->
   name_last = p.name_last,
   reply->name_first = p.name_first, reply->name_last_key = p.name_last_key, reply->name_first_key =
   p.name_first_key,
   reply->birth_date_formatted = cnvtage(cnvtdate(p.birth_dt_tm),cnvttime(p.birth_dt_tm)), reply->
   birth_dt_cd = p.birth_dt_cd, reply->birth_dt_tm = p.birth_dt_tm,
   reply->ethnic_grp_cd = p.ethnic_grp_cd, reply->language_cd = p.language_cd, reply->race_cd = p
   .race_cd,
   reply->sex_cd = p.sex_cd
  DETAIL
   count1 = (count1+ 1)
   IF (count1 >= size(reply->encntr,5))
    stat = alterlist(reply->encntr,(count1+ 10))
   ENDIF
   reply->encntr[count1].encntr_id = e.encntr_id
  WITH nocounter, outerjoin = d
 ;end select
 SET reply->encntr_qual = count1
 SET stat = alterlist(reply->encntr,count1)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request->address_ind=true))
  SET count1 = 0
  SELECT INTO "NL:"
   a.address_id
   FROM address a,
    (dummyt d  WITH seq = value(size(reply->encntr,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (a
    WHERE (a.parent_entity_id=reply->encntr[d.seq].encntr_id)
     AND a.parent_entity_name="ENCOUNTER"
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY a.beg_effective_dt_tm DESC
   DETAIL
    count1 = (count1+ 1)
    IF (size(reply->address,5) <= count1)
     stat = alterlist(reply->address,(count1+ 10))
    ENDIF
    reply->address[count1].address_id = a.address_id, reply->address[count1].address_type_cd = a
    .address_type_cd, reply->address[count1].address_format_cd = a.address_format_cd,
    reply->address[count1].contact_name = a.contact_name, reply->address[count1].residence_type_cd =
    a.residence_type_cd, reply->address[count1].comment_txt = a.comment_txt,
    reply->address[count1].street_addr = a.street_addr, reply->address[count1].street_addr2 = a
    .street_addr2, reply->address[count1].street_addr3 = a.street_addr3,
    reply->address[count1].street_addr4 = a.street_addr4, reply->address[count1].city = a.city, reply
    ->address[count1].state = a.state,
    reply->address[count1].state_cd = a.state_cd, reply->address[count1].zipcode = a.zipcode, reply->
    address[count1].zip_code_group_cd = a.zip_code_group_cd,
    reply->address[count1].county = a.county, reply->address[count1].county_cd = a.county_cd, reply->
    address[count1].country = a.country,
    reply->address[count1].country_cd = a.country_cd, reply->address[count1].residence_cd = a
    .residence_cd, reply->address[count1].mail_stop = a.mail_stop,
    reply->address[count1].encntr_id = a.parent_entity_id
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   a.address_id
   FROM address a
   PLAN (a
    WHERE (a.parent_entity_id=request->person_id)
     AND a.parent_entity_name="PERSON"
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY a.beg_effective_dt_tm DESC
   DETAIL
    count1 = (count1+ 1)
    IF (size(reply->address,5) <= count1)
     stat = alterlist(reply->address,(count1+ 10))
    ENDIF
    reply->address[count1].address_id = a.address_id, reply->address[count1].address_type_cd = a
    .address_type_cd, reply->address[count1].address_format_cd = a.address_format_cd,
    reply->address[count1].contact_name = a.contact_name, reply->address[count1].residence_type_cd =
    a.residence_type_cd, reply->address[count1].comment_txt = a.comment_txt,
    reply->address[count1].street_addr = a.street_addr, reply->address[count1].street_addr2 = a
    .street_addr2, reply->address[count1].street_addr3 = a.street_addr3,
    reply->address[count1].street_addr4 = a.street_addr4, reply->address[count1].city = a.city, reply
    ->address[count1].state = a.state,
    reply->address[count1].state_cd = a.state_cd, reply->address[count1].zipcode = a.zipcode, reply->
    address[count1].zip_code_group_cd = a.zip_code_group_cd,
    reply->address[count1].county = a.county, reply->address[count1].county_cd = a.county_cd, reply->
    address[count1].country = a.country,
    reply->address[count1].country_cd = a.country_cd, reply->address[count1].residence_cd = a
    .residence_cd, reply->address[count1].mail_stop = a.mail_stop
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->address,count1)
  SET reply->address_qual = count1
 ENDIF
 IF ((request->phone_ind=true))
  SET count1 = 0
  SELECT INTO "NL:"
   p.phone_id
   FROM phone p,
    (dummyt d  WITH seq = value(size(reply->encntr,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (p
    WHERE (p.parent_entity_id=reply->encntr[d.seq].encntr_id)
     AND p.parent_entity_name="ENCOUNTER"
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY p.beg_effective_dt_tm DESC
   DETAIL
    count1 = (count1+ 1)
    IF (size(reply->phone,5) <= count1)
     stat = alterlist(reply->phone,(count1+ 10))
    ENDIF
    reply->phone[count1].phone_id = p.phone_id, reply->phone[count1].phone_type_cd = p.phone_type_cd,
    reply->phone[count1].phone_format_cd = p.phone_format_cd,
    reply->phone[count1].phone_num = p.phone_num, reply->phone[count1].phone_type_seq = p
    .phone_type_seq, reply->phone[count1].description = p.description,
    reply->phone[count1].contact = p.contact, reply->phone[count1].call_instruction = p
    .call_instruction, reply->phone[count1].extension = p.extension,
    reply->phone[count1].paging_code = p.paging_code, reply->phone[count1].encntr_id = p
    .parent_entity_id
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   p.phone_id
   FROM phone p
   WHERE (p.parent_entity_id=request->person_id)
    AND p.parent_entity_name="PERSON"
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   ORDER BY p.beg_effective_dt_tm DESC
   DETAIL
    count1 = (count1+ 1)
    IF (size(reply->phone,5) <= count1)
     stat = alterlist(reply->phone,(count1+ 10))
    ENDIF
    reply->phone[count1].phone_id = p.phone_id, reply->phone[count1].phone_type_cd = p.phone_type_cd,
    reply->phone[count1].phone_format_cd = p.phone_format_cd,
    reply->phone[count1].phone_num = p.phone_num, reply->phone[count1].phone_type_seq = p
    .phone_type_seq, reply->phone[count1].description = p.description,
    reply->phone[count1].contact = p.contact, reply->phone[count1].call_instruction = p
    .call_instruction, reply->phone[count1].extension = p.extension,
    reply->phone[count1].paging_code = p.paging_code
   WITH nocounter
  ;end select
  SET reply->phone_qual = count1
  SET stat = alterlist(reply->phone,count1)
 ENDIF
 IF ((request->alias_ind=true))
  SET count1 = 0
  SELECT INTO "nl:"
   e.encntr_alias_id
   FROM encntr_alias e,
    (dummyt d  WITH seq = value(size(reply->encntr,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (e
    WHERE (e.encntr_id=reply->encntr[d.seq].encntr_id)
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY e.encntr_alias_type_cd, e.beg_effective_dt_tm DESC
   DETAIL
    count1 = (count1+ 1)
    IF (size(reply->alias,5) <= count1)
     stat = alterlist(reply->alias,(count1+ 5))
    ENDIF
    reply->alias[count1].alias_id = e.encntr_alias_id, reply->alias[count1].alias_pool_cd = e
    .alias_pool_cd, reply->alias[count1].person_alias_type_cd = e.encntr_alias_type_cd,
    reply->alias[count1].alias = e.alias, reply->alias[count1].contributor_system_cd = e
    .contributor_system_cd, reply->alias[count1].encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.person_alias_id
   FROM person_alias p
   WHERE (person_id=request->person_id)
    AND active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   ORDER BY p.person_alias_type_cd, p.beg_effective_dt_tm DESC
   DETAIL
    count1 = (count1+ 1)
    IF (size(reply->alias,5) <= count1)
     stat = alterlist(reply->alias,(count1+ 5))
    ENDIF
    reply->alias[count1].alias_id = p.person_alias_id, reply->alias[count1].alias_pool_cd = p
    .alias_pool_cd, reply->alias[count1].person_alias_type_cd = p.person_alias_type_cd,
    reply->alias[count1].alias = p.alias, reply->alias[count1].contributor_system_cd = p
    .contributor_system_cd
   WITH nocounter
  ;end select
  SET reply->alias_qual = count1
  SET stat = alterlist(reply->alias,count1)
 ENDIF
 IF ((request->pcp_ind=true))
  SELECT INTO "NL:"
   ppr.person_id, c.cdf_meaning, p.name_full_formatted
   FROM person_prsnl_reltn ppr,
    code_value c,
    prsnl p
   PLAN (ppr
    WHERE (ppr.person_id=request->person_id))
    JOIN (c
    WHERE c.code_value=ppr.person_prsnl_r_cd
     AND c.cdf_meaning="PCP"
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE ppr.prsnl_person_id=p.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ppr.updt_dt_tm DESC
   HEAD REPORT
    reply->pcp_person_id = ppr.prsnl_person_id, reply->pcp_name_full_formatted = p
    .name_full_formatted, reply->pcp_name_first = p.name_first,
    reply->pcp_name_last = p.name_last
   DETAIL
    x = 1
   WITH nocounter
  ;end select
 ENDIF
END GO
