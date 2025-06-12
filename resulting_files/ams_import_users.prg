CREATE PROGRAM ams_import_users
 PROMPT
  "Enter Groups to Load" = "",
  "Enter Position Display to Use" = ""
  WITH group, pos
 EXECUTE cclseclogin
 EXECUTE ams_define_toolkit_common
 FREE RECORD request
 RECORD request(
   1 audit_mode_ind = i2
   1 person_list[*]
     2 action_flag = i2
     2 person_id = f8
     2 submit_by = vc
     2 sch_ind = i2
     2 name_title = vc
     2 name_first = vc
     2 name_middle = vc
     2 name_last = vc
     2 name_full_formatted = vc
     2 name_suffix = vc
     2 prsnl_name_first = vc
     2 prsnl_name_last = vc
     2 prsnl_name_full_formatted = vc
     2 username = vc
     2 email = vc
     2 birth_dt_tm = dq8
     2 sex_code_value = f8
     2 sex_disp = vc
     2 sex_mean = vc
     2 physician_ind = i2
     2 position_code_value = f8
     2 position_disp = vc
     2 position_mean = vc
     2 primary_work_loc_code_value = f8
     2 primary_work_loc_disp = vc
     2 primary_work_loc_mean = vc
     2 alias_list[*]
       3 person_prsnl_flag = i2
       3 alias_id = f8
       3 alias_type_code_value = f8
       3 alias_type_disp = vc
       3 alias_type_mean = vc
       3 alias_pool_code_value = f8
       3 alias_pool_disp = vc
       3 alias_pool_mean = vc
       3 alias = vc
       3 active_ind = i2
       3 action_flag = i2
     2 address_list[*]
       3 address_id = f8
       3 address_type_code_value = f8
       3 address_type_disp = vc
       3 address_type_mean = vc
       3 address_type_seq = i4
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 city = vc
       3 state = vc
       3 state_code_value = f8
       3 state_disp = vc
       3 zipcode = vc
       3 country_code_value = f8
       3 country_disp = vc
       3 country_mean = vc
       3 county_code_value = f8
       3 county_disp = vc
       3 county_mean = vc
       3 contact_name = vc
       3 residence_type_code_value = f8
       3 residence_type_disp = vc
       3 residence_type_mean = vc
       3 comment_txt = vc
       3 action_flag = i2
     2 phone_list[*]
       3 phone_id = f8
       3 phone_type_code_value = f8
       3 phone_type_disp = vc
       3 phone_type_mean = vc
       3 phone_format_code_value = f8
       3 phone_format_disp = vc
       3 phone_format_mean = vc
       3 sequence = i4
       3 phone_num = vc
       3 phone_formatted = vc
       3 description = vc
       3 contact = vc
       3 call_instruction = vc
       3 extension = vc
       3 paging_code = vc
       3 action_flag = i2
       3 contact_method_code_value = f8
     2 org_list[*]
       3 prsnl_org_reltn_id = f8
       3 organization_id = f8
       3 organization_name = vc
       3 confid_level_code_value = f8
       3 confid_level_disp = vc
       3 confid_level_mean = vc
       3 action_flag = i2
     2 org_group_list[*]
       3 org_set_prsnl_r_id = f8
       3 org_set_type_code_value = f8
       3 org_set_type_disp = vc
       3 org_set_type_mean = vc
       3 org_set_id = f8
       3 org_set_name = vc
       3 action_flag = i2
     2 location_list[*]
       3 location_code_value = f8
       3 location_disp = vc
       3 location_mean = vc
       3 location_type_code_value = f8
       3 location_type_disp = vc
       3 location_type_mean = vc
       3 action_flag = i2
     2 credential_list[*]
       3 credential_id = f8
       3 notify_type_code_value = f8
       3 notify_type_disp = vc
       3 notify_type_mean = vc
       3 notify_prsnl_id = f8
       3 notify_prsnl_name_ff = vc
       3 credential_code_value = f8
       3 credential_disp = vc
       3 credential_mean = vc
       3 credential_type_code_value = f8
       3 credential_type_disp = vc
       3 credential_type_mean = vc
       3 state_code_value = f8
       3 state_disp = vc
       3 state_mean = vc
       3 id_number = vc
       3 renewal_dt_tm = dq8
       3 valid_for_code_value = f8
       3 valid_for_disp = vc
       3 valid_for_mean = vc
       3 notified_dt_tm = dq8
       3 action_flag = i2
     2 user_group_list[*]
       3 prsnl_group_reltn_id = f8
       3 prsnl_group_id = f8
       3 prsnl_group_name = vc
       3 prsnl_group_r_code_value = f8
       3 prsnl_group_r_disp = vc
       3 prsnl_group_r_mean = vc
       3 primary_ind = i2
       3 action_flag = i2
     2 clin_serv_list[*]
       3 clinical_service_reltn_id = f8
       3 clinical_service_code_value = f8
       3 clinical_service_disp = vc
       3 clinical_service_mean = vc
       3 priority = i4
       3 action_flag = i2
     2 service_resource_list[*]
       3 service_resource_code_value = f8
       3 service_resource_disp = vc
       3 service_resource_mean = vc
       3 action_flag = i2
     2 related_prsnl_list[*]
       3 prsnl_prsnl_reltn_id = f8
       3 prsnl_prsnl_reltn_code_value = f8
       3 prsnl_prsnl_reltn_disp = vc
       3 prsnl_prsnl_reltn_mean = vc
       3 related_person_id = f8
       3 related_person_name = vc
       3 action_flag = i2
     2 demog_reltn_list[*]
       3 prsnl_reltn_id = f8
       3 reltn_type_code_value = f8
       3 reltn_type_disp = vc
       3 reltn_type_mean = vc
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 action_flag = i2
       3 demog_reltn_child_list[*]
         4 prsnl_reltn_child_id = f8
         4 parent_entity_id = f8
         4 parent_entity_name = vc
         4 action_flag = i2
     2 priv_list[*]
       3 prsnl_priv_id = f8
       3 name = vc
       3 use_position_ind = i2
       3 use_org_reltn_ind = i2
       3 super_user_ind = i2
       3 priv_component_list[*]
         4 prsnl_priv_comp_id = f8
         4 priv_type_nbr = f8
         4 component_name = vc
       3 priv_detail_list[*]
         4 prsnl_priv_detail_id = f8
         4 priv_type_id = f8
         4 priv_type_name = vc
       3 action_flag = i2
     2 notify_list[*]
       3 prsnl_notify_id = f8
       3 task_activity_code_value = f8
       3 task_activity_disp = vc
       3 task_activity_mean = vc
       3 notify_flag = i2
       3 active_ind = i2
       3 action_flag = i2
     2 active_ind_ind = i2
     2 active_ind = i2
     2 external_ind = i2
 )
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 person_list[*]
      2 person_id = f8
      2 status_msg = vc
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET position
 RECORD position(
   1 position_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET sex
 RECORD sex(
   1 sex_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET alias_type
 RECORD alias_type(
   1 alias_type_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET alias_pool
 RECORD alias_pool(
   1 alias_pool_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET address_type
 RECORD address_type(
   1 address_type_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET state
 RECORD state(
   1 state_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET country
 RECORD country(
   1 country_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET county
 RECORD county(
   1 county_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET phone_type
 RECORD phone_type(
   1 phone_type_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET phone_format
 RECORD phone_format(
   1 phone_format_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET confid_level
 RECORD confid_level(
   1 confid_level_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET org_set_type
 RECORD org_set_type(
   1 org_set_type_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET task_activity
 RECORD task_activity(
   1 task_activity_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET org
 RECORD org(
   1 org_list[*]
     2 id = f8
     2 name = vc
 )
 FREE SET org_set
 RECORD org_set(
   1 org_set_list[*]
     2 id = f8
     2 name = vc
 )
 RECORD import(
   1 t_index = i4
   1 records_per = i4
   1 qual_cnt = i4
   1 beg_index = i4
   1 end_index = i4
   1 length = i4
   1 qual[*]
     2 action_ind = i2
     2 active_ind = i2
     2 name_last = vc
     2 name_first = vc
     2 name_middle = vc
     2 name_full_formatted = vc
     2 title = vc
     2 username = vc
     2 position_disp = vc
     2 position_cd = f8
     2 person_id = f8
     2 dob = dq8
     2 sex_cd = f8
     2 sex_disp = vc
     2 email = vc
     2 team_id = vc
     2 load_ind = i2
 )
 RECORD teams(
   1 qual[*]
     2 team_id = i2
     2 team_name = vc
 )
 DECLARE external_id_pool = f8 WITH protect
 DECLARE male_cd = f8 WITH protect
 DECLARE female_cd = f8 WITH protect
 DECLARE external_type_cd = f8 WITH protect
 DECLARE inactive_cd = f8 WITH protect
 DECLARE cnt = i4
 DECLARE current_cd = f8 WITH protect
 DECLARE prsnl_name_cd = f8 WITH protect
 DECLARE search_string = vc
 DECLARE search_ind = i2
 DECLARE script_name = vc WITH protect, constant("AMS_IMPORT_USERS")
 DECLARE bhistoryoption = f8 WITH protect, constant(0), persistscript
 SET male_cd = uar_get_code_by("MEANING",57,"MALE")
 SET female_cd = uar_get_code_by("MEANING",57,"FEMALE")
 SET external_type_cd = uar_get_code_by("MEANING",320,"EXTERNALID")
 SET current_cd = uar_get_code_by("MEANING",213,"CURRENT")
 SET prsnl_name_cd = uar_get_code_by("MEANING",213,"PRSNL")
 SET inactive_cd = uar_get_code_by("MEANING",48,"INACTIVE")
 SET import->records_per = 100
 FREE DEFINE rtl2
 DEFINE rtl2 "ccluserdir:amsuserimport.csv"
 SELECT INTO "nl:"
  r.line
  FROM rtl2t r
  HEAD REPORT
   import->qual_cnt = 0, cnt = 0, header_cnt = 0
  DETAIL
   header_cnt = (header_cnt+ 1)
   IF (header_cnt > 1)
    cnt = (cnt+ 1), import->qual_cnt = (import->qual_cnt+ 1)
    IF (mod(import->qual_cnt,100)=1)
     stat = alterlist(import->qual,(import->qual_cnt+ 99))
    ENDIF
    import->beg_index = 1, import->end_index = 0
    FOR (i = 1 TO 10)
      import->end_index = findstring(",",r.line,import->beg_index), import->length = (import->
      end_index - import->beg_index)
      CASE (i)
       OF 1:
        import->qual[import->qual_cnt].username = substring(import->beg_index,import->length,r.line)
       OF 2:
        import->qual[import->qual_cnt].name_last = concat(substring(import->beg_index,import->length,
          r.line)," (AMS)")
       OF 3:
        import->qual[import->qual_cnt].name_first = substring(import->beg_index,import->length,r.line
         )
       OF 4:
        import->qual[import->qual_cnt].name_middle = substring(import->beg_index,import->length,r
         .line)
       OF 5:
        import->qual[import->qual_cnt].dob = cnvtdatetime(cnvtdate(cnvtalphanum(substring(import->
            beg_index,import->length,r.line))),0000)
       OF 6:
        import->qual[import->qual_cnt].sex_disp = substring(import->beg_index,import->length,r.line)
       OF 8:
        import->qual[import->qual_cnt].email = substring(import->beg_index,import->length,r.line)
       OF 9:
        IF (substring(import->beg_index,import->length,r.line) > " ")
         import->qual[import->qual_cnt].action_ind = 3
        ELSE
         import->qual[import->qual_cnt].action_ind = 1
        ENDIF
       OF 10:
        import->qual[import->qual_cnt].team_id = substring(import->beg_index,import->length,r.line)
      ENDCASE
      import->beg_index = (import->end_index+ 1)
    ENDFOR
   ENDIF
  FOOT REPORT
   IF (mod(import->qual_cnt,100) != 0)
    stat = alterlist(import->qual,import->qual_cnt)
   ENDIF
  WITH nocounter
 ;end select
 FOR (a = 1 TO size(import->qual,5))
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.username=import->qual[a].username)
     AND p.username != " "
    DETAIL
     import->qual[a].active_ind = p.active_ind
     IF ((import->qual[a].action_ind=1))
      IF (p.active_ind=1)
       import->qual[a].person_id = p.person_id
      ELSE
       import->qual[a].person_id = p.person_id, import->qual[a].action_ind = 2
      ENDIF
     ELSE
      import->qual[a].person_id = p.person_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=88
     AND (c.display= $POS)
    DETAIL
     import->qual[a].position_cd = c.code_value, import->qual[a].position_disp = c.display
    WITH nocounter
   ;end select
   IF ((import->qual[a].sex_disp="M"))
    SET import->qual[a].sex_cd = male_cd
   ELSEIF ((import->qual[a].sex_disp="F"))
    SET import->qual[a].sex_cd = female_cd
   ENDIF
   IF (( $1="ALL"))
    SET import->qual[a].load_ind = 1
   ELSE
    SET search_string = cnvtstring(import->qual[a].team_id)
    SET search_ind = findstring(value(import->qual[a].team_id),value( $GROUP),0)
    IF (search_ind > 0)
     SET import->qual[a].load_ind = 1
    ELSE
     SET import->qual[a].load_ind = 0
    ENDIF
    CALL echo(build2("Search Ind: ",search_ind))
    CALL echo(build2("Load Ind: ",import->qual[a].load_ind))
    CALL echo(build2("Team Id: ",import->qual[a].team_id))
    CALL echo(build2("Group: ",value( $GROUP)))
    CALL echo(build2("Search String: ",search_string))
   ENDIF
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  FROM org_alias_pool_reltn o
  WHERE o.active_ind=1
   AND o.alias_entity_alias_type_cd=external_type_cd
  ORDER BY o.alias_pool_cd
  HEAD o.alias_pool_cd
   external_id_pool = o.alias_pool_cd
  WITH nocounter
 ;end select
 SET cnt = 0
 CALL echorecord(import)
 FOR (a = 1 TO size(import->qual,5))
  CALL echo(build2("Beginning For: ",import->qual[a].action_ind))
  IF ((import->qual[a].action_ind=1))
   CALL echo(build2("Action Ind: ",import->qual[a].action_ind))
   IF ((import->qual[a].person_id=0))
    IF ((import->qual[a].load_ind=1))
     SET cnt = (cnt+ 1)
     SET request->audit_mode_ind = 0
     SET stat = alterlist(request->person_list,cnt)
     SET request->person_list[cnt].action_flag = import->qual[a].action_ind
     SET request->person_list[cnt].person_id = import->qual[a].person_id
     SET request->person_list[cnt].name_title = import->qual[a].title
     SET request->person_list[cnt].name_first = import->qual[a].name_first
     SET request->person_list[cnt].prsnl_name_first = import->qual[a].name_first
     SET request->person_list[cnt].prsnl_name_last = import->qual[a].name_last
     SET request->person_list[cnt].name_last = import->qual[a].name_last
     SET request->person_list[cnt].name_middle = import->qual[a].name_middle
     SET request->person_list[cnt].username = import->qual[a].username
     SET request->person_list[cnt].sex_code_value = import->qual[a].sex_cd
     SET request->person_list[cnt].position_code_value = import->qual[a].position_cd
     SET request->person_list[cnt].position_disp = import->qual[a].position_disp
     SET request->person_list[cnt].birth_dt_tm = import->qual[a].dob
     SET request->person_list[cnt].email = import->qual[a].email
     SET request->person_list[cnt].external_ind = 1
     SET request->person_list[cnt].name_title = "Cerner AMS"
     IF (external_id_pool > 0.0)
      SET stat = alterlist(request->person_list[cnt].alias_list,1)
      SET request->person_list[cnt].alias_list[1].person_prsnl_flag = 1
      SET request->person_list[cnt].alias_list[1].alias_pool_code_value = external_id_pool
      SET request->person_list[cnt].alias_list[1].alias = import->qual[a].username
      SET request->person_list[cnt].alias_list[1].active_ind = 1
      SET request->person_list[cnt].alias_list[1].action_flag = 1
      SET request->person_list[cnt].alias_list[1].alias_type_code_value = external_type_cd
     ENDIF
    ENDIF
   ELSE
    UPDATE  FROM person_name p
     SET p.name_title = "Cerner AMS", p.updt_id = 4801, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (p.person_id=import->qual[a].person_id)
      AND p.name_type_cd IN (current_cd, prsnl_name_cd)
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end update
   ENDIF
  ELSEIF ((import->qual[a].action_ind=2))
   CALL echo(build2("Action Ind: ",import->qual[a].action_ind))
   IF ((import->qual[a].person_id > 0))
    SET cnt = (cnt+ 1)
    SET request->audit_mode_ind = 0
    SET stat = alterlist(request->person_list,cnt)
    SET request->person_list[cnt].action_flag = import->qual[a].action_ind
    SET request->person_list[cnt].person_id = import->qual[a].person_id
    SET request->person_list[cnt].name_title = import->qual[a].title
    SET request->person_list[cnt].name_first = import->qual[a].name_first
    SET request->person_list[cnt].prsnl_name_first = import->qual[a].name_first
    SET request->person_list[cnt].prsnl_name_last = import->qual[a].name_last
    SET request->person_list[cnt].name_last = import->qual[a].name_last
    SET request->person_list[cnt].name_middle = import->qual[a].name_middle
    SET request->person_list[cnt].username = import->qual[a].username
    SET request->person_list[cnt].sex_code_value = import->qual[a].sex_cd
    SET request->person_list[cnt].position_code_value = import->qual[a].position_cd
    SET request->person_list[cnt].position_disp = import->qual[a].position_disp
    SET request->person_list[cnt].birth_dt_tm = import->qual[a].dob
    SET request->person_list[cnt].email = import->qual[a].email
    SET request->person_list[cnt].name_title = "Cerner AMS"
    SET request->person_list[cnt].external_ind = 1
    UPDATE  FROM person_name p
     SET p.name_title = "Cerner AMS", p.updt_id = 4801, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (p.person_id=import->qual[a].person_id)
      AND p.name_type_cd IN (current_cd, prsnl_name_cd)
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end update
   ENDIF
  ELSEIF ((import->qual[a].action_ind=3))
   CALL echo(build2("Action Ind: ",import->qual[a].action_ind))
   IF ((import->qual[a].active_ind=1))
    SELECT
     FROM person_name p
     WHERE p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND (p.person_id=import->qual[a].person_id)
      AND p.name_title="Cerner AMS"
    ;end select
    IF (curqual > 0)
     UPDATE  FROM prsnl p
      SET p.active_ind = 0, p.active_status_cd = inactive_cd, p.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       p.updt_cnt = (p.updt_cnt+ 1), p.active_status_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (p.person_id=import->qual[a].person_id)
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
   COMMIT
  ENDIF
 ENDFOR
 CALL echorecord(request)
 IF (size(request->person_list,5) > 0)
  EXECUTE bed_ens_prsnl
 ENDIF
 SET total_cnt = size(request->person_list,5)
 CALL updtdminfo(script_name,cnvtreal(total_cnt))
 COMMIT
END GO
