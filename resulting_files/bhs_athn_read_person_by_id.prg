CREATE PROGRAM bhs_athn_read_person_by_id
 DECLARE moutputdevice = vc WITH noconstant( $1)
 RECORD orequest(
   1 action = i2
   1 person_id = f8
   1 encntr_id = f8
   1 organization_id = f8
   1 conversation_id = f8
   1 swap_person_id = f8
   1 swap_encntr_id = f8
   1 all_person_aliases = i2
   1 hp_expire_ind = i2
   1 access_sensitive_data_bits = i4
   1 person_plan_profile_type_cd = f8
 )
 RECORD out_rec(
   1 birth_dt_tm = vc
   1 birth_time_zone = vc
   1 deceased_disp = vc
   1 deceased_value = vc
   1 ethnic_group_disp = vc
   1 ethnic_group_value = vc
   1 first_name = vc
   1 last_name = vc
   1 full_name = vc
   1 gender_disp = vc
   1 gender_meaning = vc
   1 gender_value = vc
   1 language_disp = vc
   1 language_meaning = vc
   1 language_value = vc
   1 last_encounter_date_time = vc
   1 marital_status_disp = vc
   1 marital_status_meaning = vc
   1 marital_status_value = vc
   1 person_id = vc
   1 person_type_disp = vc
   1 person_type_meaning = vc
   1 person_type_value = vc
   1 race_display = vc
   1 race_value = vc
   1 religion_disp = vc
   1 religion_value = vc
   1 veteran_military_status_display = vc
   1 veteran_military_status_value = vc
   1 person_aliases[*]
     2 alias = vc
     2 person_alias_type_disp = vc
     2 person_alias_type_meaning = vc
     2 person_alias_type_value = vc
     2 beg_effective_dt_tm = vc
     2 end_effective_dt_tm = vc
   1 person_names[*]
     2 beg_effective_dt_tm = vc
     2 end_effective_dt_tm = vc
     2 first_name = vc
     2 last_name = vc
     2 full_name = vc
     2 name_type_disp = vc
     2 name_type_meaning = vc
     2 name_type_value = vc
   1 addresses[*]
     2 address_id = vc
     2 address_type_display = vc
     2 address_type_meaning = vc
     2 address_type_value = vc
     2 street1 = vc
     2 street2 = vc
     2 street3 = vc
     2 street4 = vc
     2 city = vc
     2 state_display = vc
     2 state_value = vc
     2 state_freetext = vc
     2 zipcode = vc
   1 phones[*]
     2 format_disp = vc
     2 format_meaning = vc
     2 format_value = vc
     2 number = vc
     2 phone_id = vc
     2 phone_type_disp = vc
     2 phone_type_meaning = vc
     2 phone_type_value = vc
     2 phone_type_seq = vc
   1 email_addresses[*]
     2 address_id = vc
     2 address_type_disp = vc
     2 address_type_meaning = vc
     2 address_type_value = vc
     2 address = vc
     2 beg_effective_dt_tm = vc
     2 end_effective_dt_tm = vc
     2 address_type_seq = vc
   1 races[*]
     2 race_display = vc
     2 race_value = vc
   1 ethnic_groups[*]
     2 ethnic_group_disp = vc
     2 ethnic_group_value = vc
   1 person_person_reltns[*]
     2 person_reltn_disp = vc
     2 person_reltn_meaning = vc
     2 person_reltn_value = vc
     2 person_reltn_type_disp = vc
     2 person_reltn_type_meaning = vc
     2 person_reltn_type_value = vc
     2 related_person_birth_date_time = vc
     2 related_person_first_name = vc
     2 related_person_full_name = vc
     2 related_person_last_name = vc
     2 related_person_gender_disp = vc
     2 related_person_gender_meaning = vc
     2 related_person_gender_value = vc
     2 related_person_person_id = vc
     2 related_person_person_type_disp = vc
     2 related_person_person_type_meaning = vc
     2 related_person_person_type_value = vc
     2 data_staus_disp = vc
     2 data_status_meaning = vc
     2 data_status_value = vc
     2 priority_seq = vc
     2 addresses[*]
       3 address_id = vc
       3 address_type_display = vc
       3 address_type_meaning = vc
       3 address_type_value = vc
       3 street1 = vc
       3 street2 = vc
       3 street3 = vc
       3 street4 = vc
       3 city = vc
       3 state_display = vc
       3 state_value = vc
       3 state_freetext = vc
       3 zipcode = vc
     2 person_names[*]
       3 beg_effective_dt_tm = vc
       3 end_effective_dt_tm = vc
       3 first_name = vc
       3 last_name = vc
       3 full_name = vc
       3 name_type_disp = vc
       3 name_type_meaning = vc
       3 name_type_value = vc
     2 person_org_reltns[*]
       3 organization_id = vc
       3 organization_name = vc
       3 organization_reltn_disp = vc
       3 organization_reltn_meaning = vc
       3 organization_reltn_value = vc
       3 priority_seq = vc
     2 phones[*]
       3 format_disp = vc
       3 format_meaning = vc
       3 format_value = vc
       3 number = vc
       3 phone_id = vc
       3 phone_type_disp = vc
       3 phone_type_meaning = vc
       3 phone_type_value = vc
       3 phone_type_seq = vc
   1 person_prsnl_reltns[*]
     2 prsnl = vc
     2 prsnl_id = vc
     2 prsnl_reltn_type_disp = vc
     2 prsnl_reltn_type_meaning = vc
     2 prsnl_reltn_type_value = vc
 )
 DECLARE int1 = i4
 DECLARE int2 = i4
 DECLARE p_cnt = i4
 DECLARE e_cnt = i4
 SET orequest->person_id =  $2
 SET stat = tdbexecute(3200000,3200031,114604,"REC",orequest,
  "REC",oreply)
 SET out_rec->birth_dt_tm = datetimezoneformat(oreply->person.person.birth_dt_tm,curtimezoneapp,
  "MM/dd/yyyy hh:mm:ss",curtimezonedef)
 SET out_rec->birth_time_zone = datetimezonebyindex(oreply->person.person.birth_tz,int1,int2,7)
 SET out_rec->deceased_disp = uar_get_code_display(oreply->person.person.deceased_cd)
 SET out_rec->deceased_value = trim(cnvtstring(oreply->person.person.deceased_cd))
 SET out_rec->ethnic_group_disp = uar_get_code_display(oreply->person.person.ethnic_grp_cd)
 SET out_rec->ethnic_group_value = trim(cnvtstring(oreply->person.person.ethnic_grp_cd))
 SET out_rec->first_name = oreply->person.person.name_first
 SET out_rec->last_name = oreply->person.person.name_last
 SET out_rec->full_name = oreply->person.person.name_full_formatted
 SET out_rec->gender_disp = uar_get_code_display(oreply->person.person.sex_cd)
 SET out_rec->gender_meaning = uar_get_code_meaning(oreply->person.person.sex_cd)
 SET out_rec->gender_value = trim(cnvtstring(oreply->person.person.sex_cd))
 SET out_rec->language_disp = uar_get_code_display(oreply->person.person.language_cd)
 SET out_rec->language_meaning = uar_get_code_meaning(oreply->person.person.language_cd)
 SET out_rec->language_value = trim(cnvtstring(oreply->person.person.language_cd))
 SET out_rec->last_encounter_date_time = datetimezoneformat(oreply->person.person.last_encntr_dt_tm,
  curtimezoneapp,"MM/dd/yyyy hh:mm:ss",curtimezonedef)
 SET out_rec->marital_status_disp = uar_get_code_display(oreply->person.person.marital_type_cd)
 SET out_rec->marital_status_meaning = uar_get_code_meaning(oreply->person.person.marital_type_cd)
 SET out_rec->marital_status_value = trim(cnvtstring(oreply->person.person.marital_type_cd))
 SET out_rec->person_id = trim(cnvtstring(oreply->person.person.person_id))
 SET out_rec->person_type_disp = uar_get_code_display(oreply->person.person.person_type_cd)
 SET out_rec->person_type_meaning = uar_get_code_meaning(oreply->person.person.person_type_cd)
 SET out_rec->person_type_value = trim(cnvtstring(oreply->person.person.person_type_cd))
 SET out_rec->race_display = uar_get_code_display(oreply->person.person.race_cd)
 SET out_rec->race_value = trim(cnvtstring(oreply->person.person.race_cd))
 SET out_rec->religion_disp = uar_get_code_display(oreply->person.person.religion_cd)
 SET out_rec->religion_value = trim(cnvtstring(oreply->person.person.religion_cd))
 SET out_rec->veteran_military_status_display = uar_get_code_display(oreply->person.person.
  vet_military_status_cd)
 SET out_rec->veteran_military_status_value = trim(cnvtstring(oreply->person.person.
   vet_military_status_cd))
 SET stat = alterlist(out_rec->person_aliases,size(oreply->person.person_alias,5))
 FOR (i = 1 TO size(oreply->person.person_alias,5))
   SET out_rec->person_aliases[i].alias = oreply->person.person_alias[i].alias
   SET out_rec->person_aliases[i].person_alias_type_disp = uar_get_code_display(oreply->person.
    person_alias[i].person_alias_type_cd)
   SET out_rec->person_aliases[i].person_alias_type_meaning = uar_get_code_meaning(oreply->person.
    person_alias[i].person_alias_type_cd)
   SET out_rec->person_aliases[i].person_alias_type_value = trim(cnvtstring(oreply->person.
     person_alias[i].person_alias_type_cd))
   SET out_rec->person_aliases[i].beg_effective_dt_tm = datetimezoneformat(oreply->person.
    person_alias[i].beg_effective_dt_tm,curtimezoneapp,"MM/dd/yyyy hh:mm:ss",curtimezonedef)
   SET out_rec->person_aliases[i].end_effective_dt_tm = datetimezoneformat(oreply->person.
    person_alias[i].end_effective_dt_tm,curtimezoneapp,"MM/dd/yyyy hh:mm:ss",curtimezonedef)
 ENDFOR
 SET stat = alterlist(out_rec->person_names,size(oreply->person.person_name,5))
 FOR (i = 1 TO size(oreply->person.person_name,5))
   SET out_rec->person_names[i].beg_effective_dt_tm = datetimezoneformat(oreply->person.person_name[i
    ].beg_effective_dt_tm,curtimezoneapp,"MM/dd/yyyy hh:mm:ss",curtimezonedef)
   SET out_rec->person_names[i].end_effective_dt_tm = datetimezoneformat(oreply->person.person_name[i
    ].end_effective_dt_tm,curtimezoneapp,"MM/dd/yyyy hh:mm:ss",curtimezonedef)
   SET out_rec->person_names[i].first_name = oreply->person.person_name[i].name_first
   SET out_rec->person_names[i].last_name = oreply->person.person_name[i].name_last
   SET out_rec->person_names[i].full_name = oreply->person.person_name[i].name_full
   SET out_rec->person_names[i].name_type_disp = uar_get_code_display(oreply->person.person_name[i].
    name_type_cd)
   SET out_rec->person_names[i].name_type_meaning = uar_get_code_meaning(oreply->person.person_name[i
    ].name_type_cd)
   SET out_rec->person_names[i].name_type_value = trim(cnvtstring(oreply->person.person_name[i].
     name_type_cd))
 ENDFOR
 SET stat = alterlist(out_rec->addresses,size(oreply->person.address,5))
 FOR (i = 1 TO size(oreply->person.address,5))
   SET out_rec->addresses[i].address_id = trim(cnvtstring(oreply->person.address[i].address_id))
   SET out_rec->addresses[i].address_type_display = uar_get_code_display(oreply->person.address[i].
    address_type_cd)
   SET out_rec->addresses[i].address_type_meaning = uar_get_code_meaning(oreply->person.address[i].
    address_type_cd)
   SET out_rec->addresses[i].address_type_value = trim(cnvtstring(oreply->person.address[i].
     address_type_cd))
   SET out_rec->addresses[i].street1 = oreply->person.address[i].street_addr
   SET out_rec->addresses[i].street2 = oreply->person.address[i].street_addr2
   SET out_rec->addresses[i].street3 = oreply->person.address[i].street_addr3
   SET out_rec->addresses[i].street4 = oreply->person.address[i].street_addr4
   SET out_rec->addresses[i].city = oreply->person.address[i].city
   SET out_rec->addresses[i].state_display = uar_get_code_display(oreply->person.address[i].state_cd)
   SET out_rec->addresses[i].state_value = trim(cnvtstring(oreply->person.address[i].state_cd))
   SET out_rec->addresses[i].state_freetext = oreply->person.address[i].state
   SET out_rec->addresses[i].zipcode = oreply->person.address[i].zipcode
 ENDFOR
 FOR (i = 1 TO size(oreply->person.phone,5))
   IF ((oreply->person.phone[i].phone_num="*@*"))
    SET e_cnt += 1
    SET stat = alterlist(out_rec->email_addresses,e_cnt)
    SET out_rec->email_addresses[e_cnt].address_id = trim(cnvtstring(oreply->person.phone[i].phone_id
      ))
    SET out_rec->email_addresses[e_cnt].address_type_disp = uar_get_code_display(oreply->person.
     phone[i].phone_type_cd)
    SET out_rec->email_addresses[e_cnt].address_type_meaning = uar_get_code_display(oreply->person.
     phone[i].phone_type_cd)
    SET out_rec->email_addresses[e_cnt].address_type_value = trim(cnvtstring(oreply->person.phone[i].
      phone_type_cd))
    SET out_rec->email_addresses[e_cnt].address = oreply->person.phone[i].phone_num
    SET out_rec->email_addresses[e_cnt].beg_effective_dt_tm = datetimezoneformat(oreply->person.
     phone[i].beg_effective_dt_tm,curtimezoneapp,"MM/dd/yyyy hh:mm:ss",curtimezonedef)
    SET out_rec->email_addresses[e_cnt].end_effective_dt_tm = datetimezoneformat(oreply->person.
     phone[i].end_effective_dt_tm,curtimezoneapp,"MM/dd/yyyy hh:mm:ss",curtimezonedef)
    SET out_rec->email_addresses[e_cnt].address_type_seq = trim(cnvtstring(oreply->person.phone[i].
      phone_type_seq))
   ELSE
    SET p_cnt += 1
    SET stat = alterlist(out_rec->phones,p_cnt)
    SET out_rec->phones[p_cnt].format_disp = uar_get_code_display(oreply->person.phone[i].
     phone_format_cd)
    SET out_rec->phones[p_cnt].format_meaning = uar_get_code_display(oreply->person.phone[i].
     phone_format_cd)
    SET out_rec->phones[p_cnt].format_value = trim(cnvtstring(oreply->person.phone[i].phone_format_cd
      ))
    SET out_rec->phones[p_cnt].number = oreply->person.phone[i].phone_num
    SET out_rec->phones[p_cnt].phone_id = trim(cnvtstring(oreply->person.phone[i].phone_id))
    SET out_rec->phones[p_cnt].phone_type_disp = uar_get_code_display(oreply->person.phone[i].
     phone_type_cd)
    SET out_rec->phones[p_cnt].phone_type_meaning = uar_get_code_display(oreply->person.phone[i].
     phone_type_cd)
    SET out_rec->phones[p_cnt].phone_type_value = trim(cnvtstring(oreply->person.phone[i].
      phone_type_cd))
    SET out_rec->phones[p_cnt].phone_type_seq = trim(cnvtstring(oreply->person.phone[i].
      phone_type_seq))
   ENDIF
 ENDFOR
 SET stat = alterlist(out_rec->races,size(oreply->person.race_list,5))
 FOR (i = 1 TO size(oreply->person.race_list,5))
  SET out_rec->races[i].race_display = uar_get_code_display(oreply->person.race_list[i].value_cd)
  SET out_rec->races[i].race_value = trim(cnvtstring(oreply->person.race_list[i].value_cd))
 ENDFOR
 SET stat = alterlist(out_rec->ethnic_groups,size(oreply->person.ethnic_grp_list,5))
 FOR (i = 1 TO size(oreply->person.ethnic_grp_list,5))
  SET out_rec->ethnic_groups[i].ethnic_group_disp = uar_get_code_display(oreply->person.
   ethnic_grp_list[i].value_cd)
  SET out_rec->ethnic_groups[i].ethnic_group_value = trim(cnvtstring(oreply->person.ethnic_grp_list[i
    ].value_cd))
 ENDFOR
 SET stat = alterlist(out_rec->person_person_reltns,size(oreply->person.person_person_reltn,5))
 FOR (i = 1 TO size(oreply->person.person_person_reltn,5))
   SET out_rec->person_person_reltns[i].person_reltn_disp = uar_get_code_display(oreply->person.
    person_person_reltn[i].person_reltn_cd)
   SET out_rec->person_person_reltns[i].person_reltn_meaning = uar_get_code_meaning(oreply->person.
    person_person_reltn[i].person_reltn_cd)
   SET out_rec->person_person_reltns[i].person_reltn_value = trim(cnvtstring(oreply->person.
     person_person_reltn[i].person_reltn_cd))
   SET out_rec->person_person_reltns[i].person_reltn_type_disp = uar_get_code_display(oreply->person.
    person_person_reltn[i].person_reltn_type_cd)
   SET out_rec->person_person_reltns[i].person_reltn_type_meaning = uar_get_code_meaning(oreply->
    person.person_person_reltn[i].person_reltn_type_cd)
   SET out_rec->person_person_reltns[i].person_reltn_type_value = trim(cnvtstring(oreply->person.
     person_person_reltn[i].person_reltn_type_cd))
   SET out_rec->person_person_reltns[i].related_person_birth_date_time = datetimezoneformat(oreply->
    person.person_person_reltn[i].person.birth_dt_tm,curtimezoneapp,"MM/dd/yyyy hh:mm:ss",
    curtimezonedef)
   SET out_rec->person_person_reltns[i].related_person_first_name = oreply->person.
   person_person_reltn[i].person.name_first
   SET out_rec->person_person_reltns[i].related_person_last_name = oreply->person.
   person_person_reltn[i].person.name_last
   SET out_rec->person_person_reltns[i].related_person_full_name = oreply->person.
   person_person_reltn[i].person.name_full_formatted
   SET out_rec->person_person_reltns[i].related_person_gender_disp = uar_get_code_display(oreply->
    person.person_person_reltn[i].person.sex_cd)
   SET out_rec->person_person_reltns[i].related_person_gender_meaning = uar_get_code_meaning(oreply->
    person.person_person_reltn[i].person.sex_cd)
   SET out_rec->person_person_reltns[i].related_person_gender_value = trim(cnvtstring(oreply->person.
     person_person_reltn[i].person.sex_cd))
   SET out_rec->person_person_reltns[i].related_person_person_id = trim(cnvtstring(oreply->person.
     person_person_reltn[i].person.person_id))
   SET out_rec->person_person_reltns[i].related_person_person_type_disp = uar_get_code_display(oreply
    ->person.person_person_reltn[i].person.person_type_cd)
   SET out_rec->person_person_reltns[i].related_person_person_type_meaning = uar_get_code_meaning(
    oreply->person.person_person_reltn[i].person.person_type_cd)
   SET out_rec->person_person_reltns[i].related_person_person_type_value = trim(cnvtstring(oreply->
     person.person_person_reltn[i].person.person_type_cd))
   SET out_rec->person_person_reltns[i].data_staus_disp = uar_get_code_display(oreply->person.
    person_person_reltn[i].data_status_cd)
   SET out_rec->person_person_reltns[i].data_status_meaning = uar_get_code_meaning(oreply->person.
    person_person_reltn[i].data_status_cd)
   SET out_rec->person_person_reltns[i].data_status_value = trim(cnvtstring(oreply->person.
     person_person_reltn[i].data_status_cd))
   SET out_rec->person_person_reltns[i].priority_seq = trim(cnvtstring(oreply->person.
     person_person_reltn[i].priority_seq))
   SET stat = alterlist(out_rec->person_person_reltns[i].addresses,size(oreply->person.
     person_person_reltn.person.address,5))
   FOR (j = 1 TO size(oreply->person.person_person_reltn.person.address,5))
     SET out_rec->person_person_reltns[i].addresses[j].address_id = trim(cnvtstring(oreply->person.
       person_person_reltn.person.address[j].address_id))
     SET out_rec->person_person_reltns[i].addresses[j].address_type_display = uar_get_code_display(
      oreply->person.person_person_reltn.person.address[j].address_type_cd)
     SET out_rec->person_person_reltns[i].addresses[j].address_type_meaning = uar_get_code_meaning(
      oreply->person.person_person_reltn.person.address[j].address_type_cd)
     SET out_rec->person_person_reltns[i].addresses[j].address_type_value = trim(cnvtstring(oreply->
       person.person_person_reltn.person.address[j].address_type_cd))
     SET out_rec->person_person_reltns[i].addresses[j].street1 = oreply->person.person_person_reltn.
     person.address[j].street_addr
     SET out_rec->person_person_reltns[i].addresses[j].street2 = oreply->person.person_person_reltn.
     person.address[j].street_addr2
     SET out_rec->person_person_reltns[i].addresses[j].street3 = oreply->person.person_person_reltn.
     person.address[j].street_addr3
     SET out_rec->person_person_reltns[i].addresses[j].street4 = oreply->person.person_person_reltn.
     person.address[j].street_addr4
     SET out_rec->person_person_reltns[i].addresses[j].city = oreply->person.person_person_reltn.
     person.address[j].city
     SET out_rec->person_person_reltns[i].addresses[j].state_display = uar_get_code_display(oreply->
      person.person_person_reltn.person.address[j].state_cd)
     SET out_rec->person_person_reltns[i].addresses[j].state_value = trim(cnvtstring(oreply->person.
       person_person_reltn.person.address[j].state_cd))
     SET out_rec->person_person_reltns[i].addresses[j].state_freetext = oreply->person.
     person_person_reltn.person.address[j].state
     SET out_rec->person_person_reltns[i].addresses[j].zipcode = oreply->person.person_person_reltn.
     person.address[j].zipcode
   ENDFOR
   SET stat = alterlist(out_rec->person_person_reltns[i].person_names,size(oreply->person.
     person_person_reltn.person.person_name,5))
   FOR (j = 1 TO size(oreply->person.person_person_reltn.person.person_name,5))
     SET out_rec->person_person_reltns[i].person_names[j].beg_effective_dt_tm = datetimezoneformat(
      oreply->person.person_person_reltn.person.person_name[j].beg_effective_dt_tm,curtimezoneapp,
      "MM/dd/yyyy hh:mm:ss",curtimezonedef)
     SET out_rec->person_person_reltns[i].person_names[j].end_effective_dt_tm = datetimezoneformat(
      oreply->person.person_person_reltn.person.person_name[j].end_effective_dt_tm,curtimezoneapp,
      "MM/dd/yyyy hh:mm:ss",curtimezonedef)
     SET out_rec->person_person_reltns[i].person_names[j].first_name = oreply->person.
     person_person_reltn.person.person_name[j].name_first
     SET out_rec->person_person_reltns[i].person_names[j].last_name = oreply->person.
     person_person_reltn.person.person_name[j].name_last
     SET out_rec->person_person_reltns[i].person_names[j].full_name = oreply->person.
     person_person_reltn.person.person_name[j].name_full
     SET out_rec->person_person_reltns[i].person_names[j].name_type_disp = uar_get_code_display(
      oreply->person.person_person_reltn.person.person_name[j].name_type_cd)
     SET out_rec->person_person_reltns[i].person_names[j].name_type_meaning = uar_get_code_meaning(
      oreply->person.person_person_reltn.person.person_name[j].name_type_cd)
     SET out_rec->person_person_reltns[i].person_names[j].name_type_value = trim(cnvtstring(oreply->
       person.person_person_reltn.person.person_name[j].name_type_cd))
   ENDFOR
   SET stat = alterlist(out_rec->person_person_reltns[i].phones,size(oreply->person.
     person_person_reltn.person.phone,5))
   FOR (j = 1 TO size(oreply->person.person_person_reltn.person.phone,5))
     SET out_rec->person_person_reltns[i].phones[j].format_disp = uar_get_code_display(oreply->person
      .person_person_reltn.person.phone[j].phone_format_cd)
     SET out_rec->person_person_reltns[i].phones[j].format_meaning = uar_get_code_display(oreply->
      person.person_person_reltn.person.phone[j].phone_format_cd)
     SET out_rec->person_person_reltns[i].phones[j].format_value = trim(cnvtstring(oreply->person.
       person_person_reltn.person.phone[j].phone_format_cd))
     SET out_rec->person_person_reltns[i].phones[j].number = oreply->person.person_person_reltn.
     person.phone[j].phone_num
     SET out_rec->person_person_reltns[i].phones[j].phone_id = trim(cnvtstring(oreply->person.
       person_person_reltn.person.phone[j].phone_id))
     SET out_rec->person_person_reltns[i].phones[j].phone_type_disp = uar_get_code_display(oreply->
      person.person_person_reltn.person.phone[j].phone_type_cd)
     SET out_rec->person_person_reltns[i].phones[j].phone_type_meaning = uar_get_code_display(oreply
      ->person.person_person_reltn.person.phone[j].phone_type_cd)
     SET out_rec->person_person_reltns[i].phones[j].phone_type_value = trim(cnvtstring(oreply->person
       .person_person_reltn.person.phone[j].phone_type_cd))
     SET out_rec->person_person_reltns[i].phones[j].phone_type_seq = trim(cnvtstring(oreply->person.
       person_person_reltn.person.phone[j].phone_type_seq))
   ENDFOR
 ENDFOR
 SET stat = alterlist(out_rec->person_prsnl_reltns,size(oreply->person.person_prsnl_reltn,5))
 FOR (i = 1 TO size(oreply->person.person_prsnl_reltn,5))
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE (p.person_id=oreply->person.person_prsnl_reltn[i].prsnl_person_id))
    DETAIL
     out_rec->person_prsnl_reltns[i].prsnl = p.name_full_formatted
    WITH nocounter, time = 30
   ;end select
   SET out_rec->person_prsnl_reltns[i].prsnl_id = trim(cnvtstring(oreply->person.person_prsnl_reltn[i
     ].prsnl_person_id))
   SET out_rec->person_prsnl_reltns[i].prsnl_reltn_type_disp = uar_get_code_display(oreply->person.
    person_prsnl_reltn[i].person_prsnl_r_cd)
   SET out_rec->person_prsnl_reltns[i].prsnl_reltn_type_meaning = uar_get_code_meaning(oreply->person
    .person_prsnl_reltn[i].person_prsnl_r_cd)
   SET out_rec->person_prsnl_reltns[i].prsnl_reltn_type_value = trim(cnvtstring(oreply->person.
     person_prsnl_reltn[i].person_prsnl_r_cd))
 ENDFOR
 EXECUTE bhs_athn_write_json_output
END GO
