CREATE PROGRAM cps_get_demographics:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
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
   1 deceased_cd = f8
   1 deceased_disp = c40
   1 deceased_dt_tm = dq8
   1 cause_of_death = vc
   1 encntr_qual = i4
   1 encntr[*]
     2 encntr_id = f8
   1 person_reltn_qual = i4
   1 person_reltn[*]
     2 encntr_id = f8
     2 related_person_id = f8
     2 related_person_name = vc
     2 person_reltn_type_cd = f8
     2 person_reltn_type_disp = c40
     2 person_reltn_type_desc = c40
     2 person_reltn_type_mean = c12
     2 person_reltn_cd = f8
     2 person_reltn_disp = c40
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
     2 encntr_id = f8
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
     2 encntr_id = f8
   1 alias_qual = i4
   1 alias[*]
     2 alias_id = f8
     2 alias_pool_cd = f8
     2 alias_pool_disp = c40
     2 alias_pool_desc = vc
     2 person_alias_type_cd = f8
     2 person_alias_type_disp = c40
     2 person_alias_type_desc = c40
     2 person_alias_type_mean = c12
     2 alias = vc
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 contributor_system_desc = c40
     2 contributor_system_mean = c12
     2 encntr_id = f8
   1 pcp_person_id = f8
   1 pcp_name_full_formatted = vc
   1 pcp_name_first = vc
   1 pcp_name_middle = vc
   1 pcp_name_last = vc
   1 reltn_knt = i4
   1 reltn[*]
     2 reltn_cd = f8
     2 person_id = f8
     2 person_name = vc
     2 beg_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET dvar = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 0
 SET bus_ph = fillstring(30," ")
 SET hom_ph = fillstring(30," ")
 SET bus_ph_cd = 0.0
 SET hom_ph_cd = 0.0
 SET get_phone_cd = true
 SET count1 = 0
 SET pcp_cd = 0.0
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "NL:"
  p.person_id
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person_id))
  DETAIL
   reply->person_id = p.person_id, reply->name_full_formatted = p.name_full_formatted, reply->
   name_last = p.name_last,
   reply->name_first = p.name_first, reply->name_last_key = p.name_last_key, reply->name_first_key =
   p.name_first_key,
   reply->birth_date_formatted = cnvtage(cnvtdate(p.birth_dt_tm),cnvttime(p.birth_dt_tm)), reply->
   birth_dt_cd = p.birth_dt_cd, reply->birth_dt_tm = p.birth_dt_tm,
   reply->ethnic_grp_cd = p.ethnic_grp_cd, reply->language_cd = p.language_cd, reply->race_cd = p
   .race_cd,
   reply->sex_cd = p.sex_cd, reply->deceased_cd = p.deceased_cd, reply->cause_of_death = p
   .cause_of_death,
   reply->deceased_dt_tm = p.deceased_dt_tm
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON"
  GO TO exit_script
 ENDIF
 IF ((request->encntr_qual > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(request->encntr_qual)),
    encounter e
   PLAN (d
    WHERE d.seq > 0)
    JOIN (e
    WHERE (e.encntr_id=request->encntr[d.seq].encntr_id))
   ORDER BY e.encntr_id DESC
   HEAD REPORT
    knt = 0, stat = alterlist(reply->encntr,10)
   HEAD e.encntr_id
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->encntr,(knt+ 9))
    ENDIF
    reply->encntr[knt].encntr_id = e.encntr_id
   FOOT REPORT
    reply->encntr_qual = knt, stat = alterlist(reply->encntr,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "ENCOUNTER"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (get_phone_cd=true)
  SET code_value = 0.0
  SET code_set = 43
  SET cdf_meaning = "HOME"
  EXECUTE cpm_get_cd_for_cdf
  SET hom_ph_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = concat("Failed to find a code_value for cdf_meaning ",trim(cdf_meaning),
    " in codeset ",trim(cnvtstring(code_set)))
   GO TO exit_script
  ENDIF
  SET code_value = 0.0
  SET cdf_meaning = "BUSINESS"
  EXECUTE cpm_get_cd_for_cdf
  SET bus_ph_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = concat("Failed to find a code_value for cdf_meaning ",trim(cdf_meaning),
    " in codeset ",trim(cnvtstring(code_set)))
   GO TO exit_script
  ENDIF
  SET get_phone_cd = false
 ENDIF
 IF ((reply->encntr_qual < 1))
  GO TO skip_reltn_encntr
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT DISTINCT INTO "nl:"
  epr.related_person_id, epr.person_reltn_type_cd
  FROM (dummyt d  WITH seq = value(reply->encntr_qual)),
   encntr_person_reltn epr,
   person p,
   person_name pn
  PLAN (d
   WHERE d.seq > 0)
   JOIN (epr
   WHERE (epr.encntr_id=reply->encntr[d.seq].encntr_id)
    AND epr.active_ind=true
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=epr.related_person_id)
   JOIN (pn
   WHERE pn.person_id=p.person_id)
  ORDER BY epr.person_reltn_type_cd, epr.beg_effective_dt_tm DESC, epr.related_person_id
  HEAD REPORT
   knt = 0, stat = alterlist(reply->person_reltn,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->person_reltn,(knt+ 9))
   ENDIF
   reply->person_reltn[knt].encntr_id = reply->encntr[d.seq].encntr_id, reply->person_reltn[knt].
   person_reltn_type_cd = epr.person_reltn_type_cd, reply->person_reltn[knt].person_reltn_cd = epr
   .person_reltn_cd,
   reply->person_reltn[knt].related_person_id = epr.related_person_id
   IF (p.name_full_formatted > " ")
    reply->person_reltn[knt].related_person_name = p.name_full_formatted
   ELSE
    reply->person_reltn[knt].related_person_name = pn.name_full
   ENDIF
  FOOT REPORT
   reply->person_reltn_qual = knt, stat = alterlist(reply->person_reltn,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCNTR_PERSON_RELTN"
  GO TO exit_script
 ENDIF
#skip_reltn_encntr
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT DISTINCT INTO "nl:"
  epr.related_person_id, epr.person_reltn_type_cd
  FROM person_person_reltn epr,
   person p,
   person_name pn
  PLAN (epr
   WHERE (epr.person_id=request->person_id)
    AND epr.active_ind=true
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=epr.related_person_id)
   JOIN (pn
   WHERE pn.person_id=p.person_id)
  ORDER BY epr.person_reltn_type_cd, epr.beg_effective_dt_tm DESC, epr.related_person_id
  HEAD REPORT
   knt = reply->person_reltn_qual, stat = alterlist(reply->person_reltn,(knt+ 10))
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->person_reltn,(knt+ 9))
   ENDIF
   reply->person_reltn[knt].related_person_id = epr.related_person_id
   IF (p.name_full_formatted > " ")
    reply->person_reltn[knt].related_person_name = p.name_full_formatted
   ELSE
    reply->person_reltn[knt].related_person_name = pn.name_full
   ENDIF
   reply->person_reltn[knt].person_reltn_type_cd = epr.person_reltn_type_cd, reply->person_reltn[knt]
   .person_reltn_cd = epr.person_reltn_cd
  FOOT REPORT
   reply->person_reltn_qual = knt, stat = alterlist(reply->person_reltn,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON_PERSON_RELTN"
  GO TO exit_script
 ENDIF
 IF ((reply->person_reltn_qual > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   person_id = reply->person_reltn[d.seq].related_person_id
   FROM (dummyt d  WITH seq = value(reply->person_reltn_qual)),
    phone ph
   PLAN (d
    WHERE d.seq > 0)
    JOIN (ph
    WHERE (ph.parent_entity_id=reply->person_reltn[d.seq].related_person_id)
     AND ph.parent_entity_name="PERSON"
     AND ph.phone_type_cd IN (hom_ph_cd, bus_ph_cd)
     AND ph.active_ind=true
     AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ph.end_effective_dt_tm < cnvtdatetime(curdate,curtime3))
   HEAD person_id
    dvar = 0
   DETAIL
    IF (ph.phone_type_cd=hom_ph_cd)
     IF (ph.phone_format_cd > 0)
      hom_ph = concat("H: ",trim(cnvtphone(cnvtalphanum(ph.phone_num),ph.phone_format_cd)))
     ELSE
      hom_ph = concat("H: ",trim(ph.phone_num))
     ENDIF
    ENDIF
    IF (ph.phone_type_cd=bus_ph_cd)
     IF (ph.phone_format_cd > 0)
      bus_ph = concat("B: ",trim(cnvtphone(cnvtalphanum(ph.phone_num),ph.phone_format_cd)))
     ELSE
      bus_ph = concat("B: ",trim(ph.phone_num))
     ENDIF
    ENDIF
   FOOT  person_id
    reply->person_reltn[d.seq].related_person_name = concat(trim(reply->person_reltn[d.seq].
      related_person_name),"  ",trim(hom_ph),"  ",trim(bus_ph))
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "PHONE"
   GO TO exit_script
  ENDIF
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
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "ADDRESS"
   GO TO exit_script
  ENDIF
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
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "ADDRESS"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->phone_ind=true))
  SET count1 = 0
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "NL:"
   p.phone_id, phone_nbr = cnvtphone(cnvtalphanum(p.phone_num),p.phone_format_cd)
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
    reply->phone[count1].phone_format_cd = p.phone_format_cd
    IF (p.phone_format_cd > 0)
     reply->phone[count1].phone_num = phone_nbr
    ELSE
     reply->phone[count1].phone_num = p.phone_num
    ENDIF
    reply->phone[count1].phone_type_seq = p.phone_type_seq, reply->phone[count1].description = p
    .description, reply->phone[count1].contact = p.contact,
    reply->phone[count1].call_instruction = p.call_instruction, reply->phone[count1].extension = p
    .extension, reply->phone[count1].paging_code = p.paging_code,
    reply->phone[count1].encntr_id = p.parent_entity_id
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "PHONE"
   GO TO exit_script
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "NL:"
   p.phone_id, phone_nbr = cnvtphone(cnvtalphanum(p.phone_num),p.phone_format_cd)
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
    reply->phone[count1].phone_format_cd = p.phone_format_cd
    IF (p.phone_format_cd > 0)
     reply->phone[count1].phone_num = phone_nbr
    ELSE
     reply->phone[count1].phone_num = p.phone_num
    ENDIF
    reply->phone[count1].phone_type_seq = p.phone_type_seq, reply->phone[count1].description = p
    .description, reply->phone[count1].contact = p.contact,
    reply->phone[count1].call_instruction = p.call_instruction, reply->phone[count1].extension = p
    .extension, reply->phone[count1].paging_code = p.paging_code
   WITH nocounter
  ;end select
  SET reply->phone_qual = count1
  SET stat = alterlist(reply->phone,count1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET table_name = "PHONE"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->alias_ind=true))
  SET count1 = 0
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   e.encntr_alias_id, alias = cnvtalias(cnvtalphanum(e.alias),e.alias_pool_cd)
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
    .alias_pool_cd, reply->alias[count1].person_alias_type_cd = e.encntr_alias_type_cd
    IF (e.alias_pool_cd > 0)
     reply->alias[count1].alias = alias
    ELSE
     reply->alias[count1].alias = e.alias
    ENDIF
    reply->alias[count1].contributor_system_cd = e.contributor_system_cd, reply->alias[count1].
    encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "ENCNTR_ALIAS"
   GO TO exit_script
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   p.person_alias_id, alias = cnvtalias(cnvtalphanum(p.alias),p.alias_pool_cd)
   FROM person_alias p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   ORDER BY p.person_alias_type_cd, p.beg_effective_dt_tm DESC
   DETAIL
    count1 = (count1+ 1)
    IF (size(reply->alias,5) <= count1)
     stat = alterlist(reply->alias,(count1+ 5))
    ENDIF
    reply->alias[count1].alias_id = p.person_alias_id, reply->alias[count1].alias_pool_cd = p
    .alias_pool_cd, reply->alias[count1].person_alias_type_cd = p.person_alias_type_cd
    IF (p.alias_pool_cd > 0)
     reply->alias[count1].alias = alias
    ELSE
     reply->alias[count1].alias = p.alias
    ENDIF
    reply->alias[count1].contributor_system_cd = p.contributor_system_cd
   WITH nocounter
  ;end select
  SET reply->alias_qual = count1
  SET stat = alterlist(reply->alias,count1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "PERSON_ALIAS"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->pcp_ind=true))
  SET code_value = 0.0
  SET code_set = 331
  SET cdf_meaning = "PCP"
  EXECUTE cpm_get_cd_for_cdf
  SET pcp_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = concat("Failed to find a code_value for cdf_meaning ",trim(cdf_meaning),
    " in codeset ",trim(cnvtstring(code_set)))
   GO TO exit_script
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "NL:"
   ppr.person_id, ppr.beg_effective_dt_tm, p.name_full_formatted
   FROM person_prsnl_reltn ppr,
    prsnl p
   PLAN (ppr
    WHERE (ppr.person_id=request->person_id)
     AND ppr.person_prsnl_r_cd=pcp_cd
     AND ppr.active_ind=1
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE p.person_id=ppr.prsnl_person_id)
   ORDER BY ppr.beg_effective_dt_tm DESC
   HEAD REPORT
    reply->pcp_person_id = ppr.prsnl_person_id, reply->pcp_name_full_formatted = p
    .name_full_formatted, reply->pcp_name_first = p.name_first,
    reply->pcp_name_last = p.name_last
   DETAIL
    x = 1
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "PERSON_PRSNL_RELTN"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->reltn_knt < 1))
  GO TO skip_ppr
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(request->reltn_knt)),
   person_prsnl_reltn ppr,
   prsnl p
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND (ppr.person_prsnl_r_cd=request->reltn[d1.seq].reltn_cd)
    AND ppr.active_ind=true
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
  ORDER BY ppr.person_id, ppr.person_prsnl_r_cd, ppr.beg_effective_dt_tm DESC
  HEAD REPORT
   knt = 0, stat = 0, stat = alterlist(reply->reltn,10)
  HEAD ppr.person_prsnl_r_cd
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->reltn,(knt+ 9))
   ENDIF
   reply->reltn[knt].reltn_cd = ppr.person_prsnl_r_cd, reply->reltn[knt].person_id = p.person_id,
   reply->reltn[knt].person_name = p.name_full_formatted,
   reply->reltn[knt].beg_effective_dt_tm = ppr.beg_effective_dt_tm
  FOOT REPORT
   reply->reltn_knt = knt, stat = alterlist(reply->reltn,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON_PRSNL_RELTN"
  GO TO exit_script
 ENDIF
#skip_ppr
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_versoin = "014 03/01/01 SF3151"
END GO
