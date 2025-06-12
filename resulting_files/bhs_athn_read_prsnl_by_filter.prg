CREATE PROGRAM bhs_athn_read_prsnl_by_filter
 FREE RECORD request
 RECORD request(
   1 data_flag = i2
   1 get_org_reltn = i2
   1 get_group_reltn = i2
   1 get_loc_reltn = i2
   1 first_name = vc
   1 inactive_ind = i2
   1 last_name = vc
   1 location_cd = f8
   1 organization_id = f8
   1 person_id = f8
   1 physician_ind = i2
   1 prim_prsnl_group_id = f8
   1 sec_prsnl_group_id = f8
   1 prsnl_list[*]
     2 person_id = f8
   1 username = vc
   1 free_text_flag = i2
   1 data_status_cd = f8
   1 active_status_cds[*]
     2 active_status_cd = f8
   1 active_status_cds_ind = i2
   1 prsnl_alias_flag = i2
   1 prsnl_aliases[*]
     2 alias = vc
     2 prsnl_alias_type_cd = f8
   1 prsnl_alias_organization_id = f8
   1 no_address_ind = i2
   1 no_alias_ind = i2
   1 no_name_ind = i2
   1 no_phone_ind = i2
   1 alias_mask_option = i2
 )
 RECORD reply(
   1 prsnls[*]
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 contributor_system_mean = c12
     2 birth_dt_tm = dq8
     2 department_cd = f8
     2 department_disp = c40
     2 department_mean = c12
     2 email = vc
     2 ethnic_group_cd = f8
     2 ethnic_group_disp = c40
     2 ethnic_group_mean = c12
     2 free_text_ind = i2
     2 name_first = vc
     2 name_full_formatted = vc
     2 gender_cd = f8
     2 gender_disp = c40
     2 gender_mean = c12
     2 language_cd = f8
     2 language_disp = c40
     2 language_mean = c12
     2 name_last = vc
     2 password = vc
     2 person_id = f8
     2 physician_ind = i2
     2 position_cd = f8
     2 position_disp = c40
     2 position_mean = c12
     2 prsnl_type_cd = f8
     2 prsnl_type_disp = c40
     2 prsnl_type_mean = c12
     2 race_cd = f8
     2 race_disp = c40
     2 race_mean = c12
     2 section_cd = f8
     2 section_disp = c40
     2 section_mean = c12
     2 username = vc
     2 addresses[*]
       3 address_id = f8
       3 city = vc
       3 country_cd = f8
       3 country_disp = c40
       3 country_mean = c12
       3 country = vc
       3 county_cd = f8
       3 county_disp = c40
       3 county_mean = c12
       3 county = vc
       3 state_cd = f8
       3 state_disp = c40
       3 state_mean = c12
       3 state = vc
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 address_type_cd = f8
       3 address_type_disp = c40
       3 address_type_mean = c12
       3 zipcode = vc
     2 aliases[*]
       3 alias = vc
       3 alias_formatted = vc
       3 alias_pool_cd = f8
       3 alias_pool_disp = c40
       3 alias_pool_mean = c12
       3 alias_type_cd = f8
       3 alias_type_disp = c40
       3 alias_type_mean = c12
       3 alias_beg_eff_dt_tm = dq8
       3 alias_end_eff_dt_tm = dq8
     2 groups[*]
       3 prsnl_group_id = f8
       3 prsnl_group_name = vc
     2 loc_reltns[*]
       3 location_cd = f8
       3 location_disp = c40
       3 location_mean = c12
       3 location_type_cd = f8
       3 location_type_disp = c40
       3 location_type_mean = c12
     2 org_reltns[*]
       3 confid_level_cd = f8
       3 confid_level_disp = c40
       3 confid_level_mean = c12
       3 organization_id = f8
       3 ft_org_name = vc
     2 phones[*]
       3 contact = vc
       3 extension = vc
       3 phone_format_cd = f8
       3 phone_format_disp = c40
       3 phone_format_mean = c12
       3 phone_id = f8
       3 phone_num = vc
       3 phone_type_cd = f8
       3 phone_type_disp = c40
       3 phone_type_mean = c12
     2 names[*]
       3 person_name_id = f8
       3 beg_eff_dt_tm = dq8
       3 end_eff_dt_tm = dq8
       3 first_name = vc
       3 full_name = vc
       3 last_name = vc
       3 middle_name = vc
       3 name_type_cd = f8
       3 name_type_disp = c40
       3 name_type_mean = c12
       3 prefix = vc
       3 suffix = vc
       3 updt_cnt = i4
       3 updt_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_disp = c40
     2 data_status_mean = c12
     2 active_status_cd = f8
     2 active_status_disp = c40
     2 active_status_mean = c12
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD t_record(
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 person_id = f8
     2 email = vc
 )
 RECORD out_rec(
   1 prsnls[*]
     2 name_first = vc
     2 name_last = vc
     2 name_full_formatted = vc
     2 physician_ind = vc
     2 position_disp = vc
     2 position_cd = vc
     2 email = vc
     2 prsnl_id = vc
     2 username = vc
     2 active_status_disp = vc
     2 active_status_mean = vc
     2 active_status_cd = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 resource_value = vc
   1 active_status = vc
   1 status = c1
 )
 DECLARE suspended_status_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",48,"SUSPENDED"
   ))
 IF (( $2 > 0))
  SET stat = alterlist(request->prsnl_list,1)
  SET request->prsnl_list[1].person_id =  $2
 ENDIF
 IF (( $3 > " "))
  SET request->username =  $3
  SELECT INTO "nl:"
   p.person_id
   FROM prsnl p
   PLAN (p
    WHERE p.username=cnvtupper( $3))
   HEAD p.person_id
    out_rec->active_status = uar_get_code_meaning(p.active_status_cd)
    IF (p.active_status_cd=suspended_status_cd)
     out_rec->status = "F"
    ELSE
     out_rec->status = "S"
    ENDIF
   WITH nocounter, time = 10, maxrec = 1
  ;end select
  IF ((out_rec->status != "S"))
   SET out_rec->status = "F"
   SET out_rec->active_status = uar_get_code_meaning(suspended_status_cd)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (( $4 > " "))
  SET request->first_name =  $4
 ENDIF
 IF (( $5 > " "))
  SET request->last_name =  $5
 ENDIF
 IF (( $6="PhysicianOnly"))
  SET request->physician_ind = 1
 ENDIF
 IF (( $6="NonPhysicianOnly"))
  SET request->physician_ind = 2
 ENDIF
 SET request->data_flag = 1
 DECLARE t_line = vc
 DECLARE date_line = vc
 DECLARE time_line = vc
 DECLARE tz_line = vc
 EXECUTE hna_obj_get_prsnls
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(reply->prsnls,5)),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=reply->prsnls[d.seq].person_id)
    AND p.email > " ")
  ORDER BY d.seq
  HEAD d.seq
   t_record->prsnl_cnt += 1, stat = alterlist(t_record->prsnl,t_record->prsnl_cnt), t_record->prsnl[
   t_record->prsnl_cnt].person_id = p.person_id,
   t_record->prsnl[t_record->prsnl_cnt].email = p.email
  WITH nocounter, time = 30
 ;end select
 SET stat = alterlist(out_rec->prsnls,size(reply->prsnls,5))
 FOR (i = 1 TO size(reply->prsnls,5))
   SET out_rec->prsnls[i].name_first = reply->prsnls[i].name_first
   SET out_rec->prsnls[i].name_last = reply->prsnls[i].name_last
   SET out_rec->prsnls[i].name_full_formatted = reply->prsnls[i].name_full_formatted
   IF ((reply->prsnls[i].physician_ind=1))
    SET out_rec->prsnls[i].physician_ind = "true"
   ELSE
    SET out_rec->prsnls[i].physician_ind = "false"
   ENDIF
   SET out_rec->prsnls[i].position_disp = uar_get_code_display(reply->prsnls[i].position_cd)
   SET out_rec->prsnls[i].position_cd = cnvtstring(reply->prsnls[i].position_cd)
   FOR (j = 1 TO t_record->prsnl_cnt)
     IF ((t_record->prsnl[j].person_id=reply->prsnls[i].person_id))
      SET out_rec->prsnls[i].email = t_record->prsnl[j].email
     ENDIF
   ENDFOR
   SET out_rec->prsnls[i].prsnl_id = cnvtstring(reply->prsnls[i].person_id)
   SET out_rec->prsnls[i].username = reply->prsnls[i].username
   SET out_rec->prsnls[i].active_status_disp = uar_get_code_display(reply->prsnls[i].active_status_cd
    )
   SET out_rec->prsnls[i].active_status_mean = uar_get_code_meaning(reply->prsnls[i].active_status_cd
    )
   SET out_rec->prsnls[i].active_status_cd = cnvtstring(reply->prsnls[i].active_status_cd)
   SET out_rec->prsnls[i].beg_effective_dt_tm = reply->prsnls[i].beg_effective_dt_tm
   SET out_rec->prsnls[i].end_effective_dt_tm = reply->prsnls[i].end_effective_dt_tm
 ENDFOR
 IF (size(reply->prsnls,5)=1)
  SELECT INTO "nl:"
   FROM application_ini ai
   PLAN (ai
    WHERE (ai.person_id=reply->prsnls[1].person_id)
     AND ai.section="CPSSCHEDULE"
     AND ai.parameter_data="*SCH_DEFAULTRES*")
   HEAD REPORT
    out_rec->prsnls[1].resource_value = cnvtstring(substring((findstring("SCH_DEFAULTRES",ai
       .parameter_data)+ 15),15,ai.parameter_data))
   WITH nocounter, time = 10
  ;end select
 ENDIF
#exit_script
 SET _memory_reply_string = cnvtrectojson(out_rec)
 FREE RECORD out_rec
END GO
