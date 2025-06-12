CREATE PROGRAM cp_get_person_master:dba
 RECORD reply(
   1 name_full_formatted = c100
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 deceased_dt_tm = dq8
   1 race_cd = f8
   1 race_disp = c40
   1 race_mean = c12
   1 sex_cd = f8
   1 sex_disp = c40
   1 sex_mean = c12
   1 name_last = c200
   1 name_first = c200
   1 species_cd = f8
   1 species_disp = c40
   1 species_mean = c12
   1 hla_diagnosis = c80
   1 person_alias[*]
     2 person_alias_id = f8
     2 alias_pool_cd = f8
     2 person_alias_type_cd = f8
     2 person_alias_type_disp = c40
     2 person_alias_type_mean = c12
     2 alias = c200
     2 health_card_ver_code = c3
     2 health_card_province = c3
   1 person_name[*]
     2 person_name_id = f8
     2 name_type_cd = f8
     2 name_type_disp = c40
     2 name_type_mean = c12
     2 name_full = c100
     2 name_first = c100
     2 name_last = c100
     2 name_middle = vc
     2 name_title = vc
   1 person_info[*]
     2 person_info_id = f8
     2 info_type_cd = f8
     2 info_type_disp = c40
     2 info_type_mean = c12
     2 long_text_id = f8
     2 long_text = vc
     2 value_numeric = i4
     2 chartable_ind = i2
   1 address[*]
     2 address_id = f8
     2 address_type_cd = f8
     2 address_type_disp = c40
     2 address_type_mean = c12
     2 street_addr = c100
     2 street_addr2 = c100
     2 street_addr3 = c100
     2 street_addr4 = c100
     2 city = c100
     2 state_cd = f8
     2 state = vc
     2 zipcode = c25
     2 country = vc
   1 phone[*]
     2 phone_id = f8
     2 phone_type_cd = f8
     2 phone_type_disp = c40
     2 phone_type_mean = c12
     2 phone_num = c100
     2 extension = vc
   1 person_prsnl_reltn[*]
     2 person_prsnl_reltn_id = f8
     2 prsnl_person_id = f8
     2 person_prsnl_r_cd = f8
     2 person_prsnl_r_disp = c40
     2 person_prsnl_r_mean = c12
     2 beg_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE home_cd = f8 WITH constant(uar_get_code_by("MEANING",212,"HOME")), protect
 DECLARE phone_freetext_cd = f8 WITH constant(uar_get_code_by("MEANING",281,"FREETEXT")), protect
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.name_full_formatted, p.birth_dt_tm, p.deceased_dt_tm,
  p.race_cd, p.sex_cd, p.name_last,
  p.name_first, p.species_cd
  FROM person p
  WHERE (p.person_id=request->person_id)
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   reply->name_full_formatted = p.name_full_formatted, reply->birth_dt_tm = p.birth_dt_tm, reply->
   birth_tz = validate(p.birth_tz,0),
   reply->deceased_dt_tm = p.deceased_dt_tm, reply->race_cd = p.race_cd, reply->sex_cd = p.sex_cd,
   reply->name_last = p.name_last, reply->name_first = p.name_first, reply->species_cd = p.species_cd
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PERSON"
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(build("person_id=",request->person_id))
 ENDIF
 SET count = 0
 SELECT
  IF ((request->scope_flag IN (2, 3, 4)))INTO "nl:"
   p.person_alias_id, p.alias_pool_cd, p.person_alias_type_cd,
   p.alias
   FROM org_alias_pool_reltn o,
    person_alias p
   PLAN (o
    WHERE (o.organization_id=request->organization_id))
    JOIN (p
    WHERE p.person_alias_type_cd=o.alias_entity_alias_type_cd
     AND (p.person_id=request->person_id)
     AND p.alias_pool_cd=o.alias_pool_cd
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    count = (count+ 1), stat = alterlist(reply->person_alias,count), reply->person_alias[count].
    person_alias_id = p.person_alias_id,
    reply->person_alias[count].alias_pool_cd = p.alias_pool_cd, reply->person_alias[count].
    person_alias_type_cd = p.person_alias_type_cd, reply->person_alias[count].alias = cnvtalias(p
     .alias,p.alias_pool_cd),
    reply->person_alias[count].health_card_ver_code = p.health_card_ver_code, reply->person_alias[
    count].health_card_province = p.health_card_province
   WITH nocounter
  ELSE INTO "nl:"
   p.person_alias_id, p.alias_pool_cd, p.person_alias_type_cd,
   p.alias
   FROM person_alias p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   DETAIL
    count = (count+ 1), stat = alterlist(reply->person_alias,count), reply->person_alias[count].
    person_alias_id = p.person_alias_id,
    reply->person_alias[count].alias_pool_cd = p.alias_pool_cd, reply->person_alias[count].
    person_alias_type_cd = p.person_alias_type_cd, reply->person_alias[count].alias = cnvtalias(p
     .alias,p.alias_pool_cd),
    reply->person_alias[count].health_card_ver_code = p.health_card_ver_code, reply->person_alias[
    count].health_card_province = p.health_card_province
   WITH nocounter
  ENDIF
 ;end select
 SET count = 0
 SELECT INTO "nl:"
  p.person_name_id, p.name_type_cd, p.name_full,
  p.name_first, p.name_last
  FROM person_name p
  WHERE (p.person_id=request->person_id)
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   count = (count+ 1), stat = alterlist(reply->person_name,count), reply->person_name[count].
   person_name_id = p.person_name_id,
   reply->person_name[count].name_type_cd = p.name_type_cd, reply->person_name[count].name_full = p
   .name_full, reply->person_name[count].name_first = p.name_first,
   reply->person_name[count].name_last = p.name_last, reply->person_name[count].name_middle = p
   .name_middle, reply->person_name[count].name_title = p.name_title
  WITH nocounter
 ;end select
 SET count = 0
 SELECT INTO "nl:"
  a.address_id, a.address_type_cd, a.street_addr,
  a.street_addr2, a.street_addr3, a.street_addr5,
  a.city, a.state_cd, a.state,
  a.zipcode, a.country
  FROM address a
  WHERE (a.parent_entity_id=request->person_id)
   AND a.parent_entity_name="PERSON"
   AND a.address_type_cd=home_cd
   AND a.active_ind=1
   AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY a.address_type_seq
  HEAD a.address_type_seq
   count = (count+ 1), stat = alterlist(reply->address,count), reply->address[count].address_id = a
   .address_id,
   reply->address[count].address_type_cd = a.address_type_cd, reply->address[count].street_addr = a
   .street_addr, reply->address[count].street_addr2 = a.street_addr2,
   reply->address[count].street_addr3 = a.street_addr3, reply->address[count].street_addr4 = a
   .street_addr4, reply->address[count].city = a.city
   IF (a.state_cd > 0)
    reply->address[count].state = uar_get_code_display(a.state_cd)
   ELSE
    reply->address[count].state = a.state
   ENDIF
   reply->address[count].state_cd = a.state_cd, reply->address[count].zipcode = a.zipcode
   IF (a.country_cd > 0)
    reply->address[count].country = uar_get_code_display(a.country_cd)
   ELSE
    reply->address[count].country = a.country
   ENDIF
  DETAIL
   donothing = 0
  FOOT  a.address_type_seq
   donothing = 0
  WITH nocounter
 ;end select
 SET count = 0
 SELECT INTO "nl:"
  p.phone_id, p.phone_type_cd, p.phone_num,
  p.phone_format_cd
  FROM phone p
  WHERE (p.parent_entity_id=request->person_id)
   AND p.parent_entity_name="PERSON"
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   count = (count+ 1), stat = alterlist(reply->phone,count), reply->phone[count].phone_id = p
   .phone_id,
   reply->phone[count].phone_type_cd = p.phone_type_cd
   IF (p.phone_format_cd=phone_freetext_cd)
    reply->phone[count].phone_num = p.phone_num
   ELSE
    reply->phone[count].phone_num = cnvtphone(cnvtalphanum(p.phone_num),p.phone_format_cd)
   ENDIF
   reply->phone[count].extension = p.extension
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.person_prsnl_reltn_id, p.prsnl_person_id, p.person_prsnl_r_cd
  FROM person_prsnl_reltn p
  WHERE (p.person_id=request->person_id)
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->person_prsnl_reltn,(count+ 9))
   ENDIF
   reply->person_prsnl_reltn[count].person_prsnl_reltn_id = p.person_prsnl_reltn_id, reply->
   person_prsnl_reltn[count].prsnl_person_id = p.prsnl_person_id, reply->person_prsnl_reltn[count].
   person_prsnl_r_cd = p.person_prsnl_r_cd,
   reply->person_prsnl_reltn[count].beg_effective_dt_tm = p.beg_effective_dt_tm
  FOOT REPORT
   stat = alterlist(reply->person_prsnl_reltn,count)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ptc.person_transplant_id
  FROM person_transplant_candidate ptc
  WHERE (ptc.person_id=request->person_id)
   AND ptc.transplant_ind=0
   AND ptc.active_ind=1
   AND ptc.diagnosis > ""
  DETAIL
   reply->hla_diagnosis = substring(1,80,ptc.diagnosis)
  WITH nocounter, maxqual(ptc,1)
 ;end select
 SET total_nbr = size(reply->person_prsnl_reltn,5)
 CALL echo(build("total =",total_nbr))
 FOR (x = 1 TO total_nbr)
   CALL echo(build("person_prsnl_reltn_id = ",reply->person_prsnl_reltn[x].person_prsnl_reltn_id))
   CALL echo(build("prsnl_person_id = ",reply->person_prsnl_reltn[x].prsnl_person_id))
   CALL echo(build("person_prsnl_r_cd = ",reply->person_prsnl_reltn[x].person_prsnl_r_cd))
 ENDFOR
 CALL echorecord(reply)
END GO
