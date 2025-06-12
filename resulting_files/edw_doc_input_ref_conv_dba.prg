CREATE PROGRAM edw_doc_input_ref_conv:dba
 DECLARE uar_user_name = vc WITH noconstant(" ")
 DECLARE uar_domain = vc WITH noconstant(" ")
 DECLARE uar_password = vc WITH noconstant(" ")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="PI EDW SYSTEMS CONFIGURATION|*"
  DETAIL
   q_info_name = substring(1,(findstring("|",di.info_name,1) - 1),di.info_name), q_info_char =
   substring(1,(findstring("|",di.info_char,1) - 1),di.info_char), q_info_domain = substring((
    findstring("|",di.info_domain,1)+ 1),(size(di.info_domain,1) - findstring("|",di.info_domain,1)),
    di.info_domain)
   CASE (q_info_name)
    OF "UAR_USER_NAME":
     uar_user_name = q_info_char
    OF "UAR_DOMAIN":
     uar_domain = q_info_char
    OF "UAR_PASSWORD":
     uar_password = q_info_char
   ENDCASE
  WITH nocounter
 ;end select
 SET stat = uar_sec_login(value(uar_user_name),value(uar_domain),value(uar_password))
 IF (stat != 0)
  CALL echo("Invalid UAR Login.  Exiting...")
  GO TO end_program
 ENDIF
 DECLARE printdebugstatement(debug_message=vc) = null WITH public
 DECLARE printcoststatement(cost_message=vc) = null WITH public
 DECLARE edwgetcodevaluefromcdfmeaning(code_set=i4(value),cdf_meaning=vc(value)) = f8 WITH protect
 SUBROUTINE edwgetcodevaluefromcdfmeaning(code_set,cdf_meaning)
   DECLARE return_value = f8 WITH protected, noconstant(0.0)
   DECLARE cdf_mean = vc WITH protected, constant(trim(cnvtupper(cdf_meaning)))
   SET return_value = uar_get_code_by(nullterm("MEANING"),code_set,nullterm(cdf_mean))
   IF ((return_value=- (1.0)))
    SELECT INTO "nl:"
     c.code_value
     FROM code_value c
     PLAN (c
      WHERE c.code_set=code_set
       AND c.cdf_meaning=cdf_mean
       AND c.active_ind=1)
     ORDER BY c.code_value
     HEAD c.code_value
      return_value = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 DECLARE edwcreatescriptstatus(filetype=vc(value)) = null WITH protect
 DECLARE edwupdatescriptstatus(filetype=vc(value),recordcount=i4(value),getscriptversion=vc(value),
  createscriptversion=vc(value)) = null WITH protect
 DECLARE edwupdatestats(filetype=vc(value),start_dt_tm=vc(value),error_ind=i2(value)) = null WITH
 public
 DECLARE edwincrementfilecount(filetype=vc(value),filecount=i4(value)) = null WITH public
 SUBROUTINE edwcreatescriptstatus(filetype)
   DECLARE ilogcount = i4 WITH private, noconstant(0)
   SET ilogcount = (size(rstats->qual,5)+ 1)
   SET stat = alterlist(rstats->qual,ilogcount)
   SET rstats->qual[ilogcount].file_type = filetype
   SET rstats->qual[ilogcount].extract_date = extract_dt_fmt
   SET rstats->qual[ilogcount].extract_time = extract_tm_fmt
 END ;Subroutine
 SUBROUTINE edwupdatescriptstatus(filetype,recordcount,getscriptversion,createscriptversion)
   DECLARE num = i4 WITH private, noconstant(0)
   DECLARE start = i4 WITH private, noconstant(0)
   SET index = locateval(num,start,size(rstats->qual,5),filetype,rstats->qual[num].file_type)
   IF (index != 0)
    SET rstats->qual[index].extract_date = extract_dt_fmt
    SET rstats->qual[index].extract_time = extract_tm_fmt
    SET rstats->qual[index].record_count = recordcount
    SET rstats->qual[index].get_script_version = getscriptversion
    SET rstats->qual[index].create_script_version = createscriptversion
   ENDIF
 END ;Subroutine
 SUBROUTINE edwupdatestats(filetype,start_dt_tm,error_ind)
   DECLARE num = i4 WITH private, noconstant(0)
   DECLARE start = i4 WITH private, noconstant(0)
   SET index = locateval(num,start,size(rstats->qual,5),filetype,rstats->qual[num].file_type)
   IF (index != 0)
    SET rstats->qual[index].script_start_dt_tm = start_dt_tm
    SET rstats->qual[index].script_end_dt_tm = format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")
    SET rstats->qual[index].error_ind = error_ind
   ENDIF
 END ;Subroutine
 SUBROUTINE edwincrementfilecount(filetype,filecount)
   DECLARE num = i4 WITH private, noconstant(0)
   DECLARE start = i4 WITH private, noconstant(0)
   SET index = locateval(num,0,size(rstats->qual,5),filetype,rstats->qual[num].file_type)
   IF (index != 0)
    SET rstats->qual[index].file_cnt = filecount
   ENDIF
 END ;Subroutine
 DECLARE gettimezone(location=f8,encounter_id=f8) = f8 WITH public
 SUBROUTINE gettimezone(location,encounter_id)
   DECLARE time_zone_result = f8
   DECLARE indx = i4
   DECLARE max_updt_dt_tm = f8
   SET record_size = size(time_zone_by_loc->qual,5)
   SET cntr = 1
   SET cached = 0
   IF (location > 0)
    SET location_indx = locateval(indx,1,record_size,location,time_zone_by_loc->qual[indx].
     location_id)
    IF (location_indx > 0)
     SET time_zone_result = time_zone_by_loc->qual[location_indx].time_zone
     SET cached = 1
    ENDIF
   ENDIF
   IF ( NOT (cached))
    IF ( NOT (time_zone_by_loc->preloaded_ind)
     AND location > 0)
     SELECT INTO "nl:"
      FROM time_zone_r tzr
      WHERE tzr.parent_entity_name="LOCATION"
       AND tzr.parent_entity_id=location
      DETAIL
       time_zone_result = datetimezonebyname(tzr.time_zone)
      WITH nocounter
     ;end select
    ENDIF
    IF (location=0
     AND encounter_id != 0)
     SELECT INTO "nl:"
      FROM sch_appt sa,
       time_zone_r tzr
      PLAN (sa
       WHERE sa.role_meaning="PATIENT"
        AND sa.encntr_id=encounter_id
        AND  NOT (sa.state_meaning IN ("RESCHEDULED", "CANCELED")))
       JOIN (tzr
       WHERE tzr.parent_entity_name="LOCATION"
        AND tzr.parent_entity_id=sa.appt_location_cd)
      ORDER BY cnvtdatetime(sa.updt_dt_tm)
      DETAIL
       location = sa.appt_location_cd, time_zone_result = datetimezonebyname(tzr.time_zone)
      WITH nocounter
     ;end select
    ENDIF
    IF (time_zone_result=0)
     SET time_zone_result = default_time_zone
    ENDIF
    IF (location > 0)
     SET x = alterlist(time_zone_by_loc->qual,(record_size+ 1))
     SET time_zone_by_loc->qual[(record_size+ 1)].location_id = location
     SET time_zone_by_loc->qual[(record_size+ 1)].time_zone = time_zone_result
    ENDIF
   ENDIF
   RETURN(time_zone_result)
 END ;Subroutine
 DECLARE tm_valid(input_dt_tm=f8) = i4 WITH protect
 SUBROUTINE tm_valid(input_dt_tm)
   IF (cnvttime(input_dt_tm)=0)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE get_encounter_nk(var_encounter_id=f8) = vc WITH protect
 SUBROUTINE get_encounter_nk(var_encounter_id)
   DECLARE enc_nk = vc WITH noconstant("0")
   DECLARE parse_encounter_nk = vc WITH noconstant(concat("build(",encounter_nk,")"))
   DECLARE enc_index = i4 WITH noconstant(0)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE list_size = i4
   DECLARE encounter_clause = vc WITH noconstant("1=1"), protect
   DECLARE inverse_encounter_clause = vc WITH noconstant("1=1"), protect
   DECLARE person_clause = vc WITH noconstant("1=1"), protect
   DECLARE inverse_person_clause = vc WITH noconstant("1=1"), protect
   DECLARE encntr_loc_hist_clause = vc WITH noconstant("1=1"), protect
   DECLARE inverse_encntr_loc_hist_clause = vc WITH noconstant("1=1"), protect
   DECLARE encntr_plan_reltn_clause = vc WITH noconstant("1=1"), protect
   DECLARE inverse_encntr_plan_reltn_clause = vc WITH noconstant("1=1"), protect
   DECLARE encntr_alias_clause = vc WITH noconstant("1=1"), protect
   DECLARE inverse_encntr_alias_clause = vc WITH noconstant("1=1"), protect
   SET loop_cnt = 1
   SET enc_index = locateval(num,1,size(encounter_nk_list->qual,5),var_encounter_id,encounter_nk_list
    ->qual[num].encounter_id)
   IF (enc_index > 0)
    SET enc_nk = encounter_nk_list->qual[enc_index].encounter_nk
   ELSE
    IF (((filter_field_1 != "") OR (((filter_field_2 != "") OR (filter_field_3 != "")) )) )
     IF (filter_field_1 != "")
      SET filter_table_1 = cnvtupper(substring(1,(findstring(".",filter_field_1) - 1),filter_field_1)
       )
      CASE (filter_table_1)
       OF "ENCOUNTER":
        SET encounter_clause = concat(encounter_clause," and ",filter_field_1," IN(",filter_value_1,
         ")")
        SET inverse_encounter_clause = concat(inverse_encounter_clause," and ",filter_field_1,
         " NOT IN(",filter_value_1,
         ")")
       OF "PERSON":
        SET person_clause = concat(person_clause," and ",filter_field_1," IN(",filter_value_1,
         ")")
        SET inverse_person_clause = concat(inverse_person_clause," and ",filter_field_1," NOT IN(",
         filter_value_1,
         ")")
       OF "ENCNTR_LOC_HIST":
        SET encntr_loc_hist_clause = concat(encntr_loc_hist_clause," and ",filter_field_1," IN(",
         filter_value_1,
         ")")
        SET inverse_encntr_loc_hist_clause = concat(inverse_encntr_loc_hist_clause," and ",
         filter_field_1," NOT IN(",filter_value_1,
         ")")
       OF "ENCNTR_PLAN_RELTN":
        SET encntr_plan_reltn_clause = concat(encntr_plan_reltn_clause," and ",filter_field_1," IN(",
         filter_value_1,
         ")")
        SET inverse_encntr_plan_reltn_clause = concat(inverse_encntr_plan_reltn_clause," and ",
         filter_field_1," NOT IN(",filter_value_1,
         ")")
       OF "ENCNTR_ALIAS":
        SET encntr_alias_clause = concat(encntr_alias_clause," and ",filter_field_1," IN(",
         filter_value_1,
         ")")
        SET inverse_encntr_alias_clause = concat(inverse_encntr_alias_clause," and ",filter_field_1,
         " NOT IN(",filter_value_1,
         ")")
      ENDCASE
     ENDIF
     IF (filter_field_2 != "")
      SET filter_table_2 = cnvtupper(substring(1,(findstring(".",filter_field_2) - 1),filter_field_2)
       )
      CASE (filter_table_2)
       OF "ENCOUNTER":
        SET encounter_clause = concat(encounter_clause," and ",filter_field_2," IN(",filter_value_2,
         ")")
        SET inverse_encounter_clause = concat(inverse_encounter_clause," and ",filter_field_2,
         " NOT IN(",filter_value_2,
         ")")
       OF "PERSON":
        SET person_clause = concat(person_clause," and ",filter_field_2," IN(",filter_value_2,
         ")")
        SET inverse_person_clause = concat(inverse_person_clause," and ",filter_field_2," NOT IN(",
         filter_value_2,
         ")")
       OF "ENCNTR_LOC_HIST":
        SET encntr_loc_hist_clause = concat(encntr_loc_hist_clause," and ",filter_field_2," IN(",
         filter_value_2,
         ")")
        SET inverse_encntr_loc_hist_clause = concat(inverse_encntr_loc_hist_clause," and ",
         filter_field_2," NOT IN(",filter_value_2,
         ")")
       OF "ENCNTR_PLAN_RELTN":
        SET encntr_plan_reltn_clause = concat(encntr_plan_reltn_clause," and ",filter_field_2," IN(",
         filter_value_2,
         ")")
        SET inverse_encntr_plan_reltn_clause = concat(inverse_encntr_plan_reltn_clause," and ",
         filter_field_2," NOT IN(",filter_value_2,
         ")")
       OF "ENCNTR_ALIAS":
        SET encntr_alias_clause = concat(encntr_alias_clause," and ",filter_field_2," IN(",
         filter_value_2,
         ")")
        SET inverse_encntr_alias_clause = concat(inverse_encntr_alias_clause," and ",filter_field_2,
         " NOT IN(",filter_value_2,
         ")")
      ENDCASE
     ENDIF
     IF (filter_field_3 != "")
      SET filter_table_3 = cnvtupper(substring(1,(findstring(".",filter_field_3) - 1),filter_field_3)
       )
      CASE (filter_table_3)
       OF "ENCOUNTER":
        SET encounter_clause = concat(encounter_clause," and ",filter_field_3," IN(",filter_value_3,
         ")")
        SET inverse_encounter_clause = concat(inverse_encounter_clause," and ",filter_field_3,
         " NOT IN(",filter_value_3,
         ")")
       OF "PERSON":
        SET person_clause = concat(person_clause," and ",filter_field_3," IN(",filter_value_3,
         ")")
        SET inverse_person_clause = concat(inverse_person_clause," and ",filter_field_3," NOT IN(",
         filter_value_3,
         ")")
       OF "ENCNTR_LOC_HIST":
        SET encntr_loc_hist_clause = concat(encntr_loc_hist_clause," and ",filter_field_3," IN(",
         filter_value_3,
         ")")
        SET inverse_encntr_loc_hist_clause = concat(inverse_encntr_loc_hist_clause," and ",
         filter_field_3," NOT IN(",filter_value_3,
         ")")
       OF "ENCNTR_PLAN_RELTN":
        SET encntr_plan_reltn_clause = concat(encntr_plan_reltn_clause," and ",filter_field_3," IN(",
         filter_value_3,
         ")")
        SET inverse_encntr_plan_reltn_clause = concat(inverse_encntr_plan_reltn_clause," and ",
         filter_field_3," NOT IN(",filter_value_3,
         ")")
       OF "ENCNTR_ALIAS":
        SET encntr_alias_clause = concat(encntr_alias_clause," and ",filter_field_3," IN(",
         filter_value_3,
         ")")
        SET inverse_encntr_alias_clause = concat(inverse_encntr_alias_clause," and ",filter_field_3,
         " NOT IN(",filter_value_3,
         ")")
      ENDCASE
     ENDIF
     SET loop_cnt = 2
    ENDIF
    SET message = noinformation
    WHILE (loop_cnt > 0)
      SELECT INTO "nl:"
       FROM encounter,
        person,
        encntr_loc_hist,
        encntr_plan_reltn,
        encntr_alias
       PLAN (encounter
        WHERE encounter.encntr_id=var_encounter_id
         AND parser(encounter_clause))
        JOIN (person
        WHERE person.person_id=encounter.person_id
         AND parser(person_clause))
        JOIN (encntr_loc_hist
        WHERE encntr_loc_hist.encntr_id=outerjoin(encounter.encntr_id)
         AND encntr_loc_hist.beg_effective_dt_tm <= outerjoin(encounter.reg_dt_tm)
         AND encntr_loc_hist.end_effective_dt_tm >= outerjoin(encounter.reg_dt_tm)
         AND parser(encntr_loc_hist_clause))
        JOIN (encntr_plan_reltn
        WHERE encntr_plan_reltn.encntr_id=outerjoin(encounter.encntr_id)
         AND parser(encntr_plan_reltn_clause))
        JOIN (encntr_alias
        WHERE encntr_alias.encntr_id=outerjoin(encounter.encntr_id)
         AND encntr_alias.active_ind=outerjoin(1)
         AND encntr_alias.end_effective_dt_tm > outerjoin(sysdate)
         AND parser(encntr_alias_clause))
       DETAIL
        enc_nk = parser(parse_encounter_nk)
       WITH nocounter
      ;end select
      IF (((filter_field_1 != "") OR (((filter_field_2 != "") OR (filter_field_3 != "")) )) )
       SET encounter_clause = inverse_encounter_clause
       SET person_clause = inverse_person_clause
       SET encntr_loc_hist_clause = inverse_encntr_loc_hist_clause
       SET encntr_plan_reltn_clause = inverse_encntr_plan_reltn_clause
       SET encntr_alias_clause = inverse_encntr_alias_clause
       SET parse_encounter_nk = "build(cnvtstring(encounter.encntr_id,16),health_system_source_id)"
      ENDIF
      SET loop_cnt = (loop_cnt - 1)
    ENDWHILE
    IF (debug="Y")
     SET message = information
    ELSE
     SET message = noinformation
    ENDIF
    SET list_size = size(encounter_nk_list->qual,5)
    SET stat = alterlist(encounter_nk_list->qual,(list_size+ 1))
    SET encounter_nk_list->qual[(list_size+ 1)].encounter_id = var_encounter_id
    SET encounter_nk_list->qual[(list_size+ 1)].encounter_nk = enc_nk
   ENDIF
   RETURN(enc_nk)
 END ;Subroutine
 DECLARE getinstfilter(location=vc) = vc WITH public
 SUBROUTINE getinstfilter(location)
  IF (size(inst_list->qual,5) > 0)
   SET location_filter = build("EXPAND(idx,1,size(inst_list->qual,5),",location,
    ",inst_list->qual[idx]->loc_cd)")
  ELSE
   SET location_filter = "1=1"
  ENDIF
  RETURN(location_filter)
 END ;Subroutine
 DECLARE getorgfilter(organization=vc) = vc WITH public
 SUBROUTINE getorgfilter(organization)
  IF (size(org_list->qual,5) > 0)
   SET organization_filter = build("EXPAND(idx,1,size(org_list->qual,5),",organization,
    ",org_list->qual[idx]->org_id)")
  ELSE
   SET organization_filter = "1=1"
  ENDIF
  RETURN(organization_filter)
 END ;Subroutine
 RECORD person_keys(
   1 qual[*]
     2 person_id = f8
 )
 RECORD next_of_kin_keys(
   1 qual[*]
     2 person_id = f8
 )
 RECORD per_prsl(
   1 qual[*]
     2 per_person_sk = f8
     2 per_personnel_sk = f8
     2 medical_record_nbr = vc
     2 formatted_medical_record_nbr = vc
     2 medical_record_nbr_raw = vc
     2 community_medical_record_nbr = vc
     2 formatted_comm_med_rec_nbr = vc
     2 comm_med_rec_nbr_raw = vc
     2 national_ident = vc
     2 full_name = vc
     2 first_name = vc
     2 middle_name = vc
     2 last_name = vc
     2 maiden_full_name = vc
     2 maiden_first_name = vc
     2 maiden_middle_name = vc
     2 maiden_last_name = vc
     2 mother_maiden_last_name = vc
     2 address_line_1 = vc
     2 address_line_2 = vc
     2 address_line_3 = vc
     2 address_line_4 = vc
     2 city = vc
     2 state_ref = f8
     2 state = vc
     2 postal_code = vc
     2 postal_code_nls = vc
     2 county_ref = f8
     2 county = vc
     2 country_ref = f8
     2 country = vc
     2 residence_ref = f8
     2 residence_type_ref = f8
     2 phone_nbr = vc
     2 email_address = vc
     2 gender_ref = f8
     2 parent_marital_status_ref = f8
     2 marital_status_ref = f8
     2 race_ref = f8
     2 ethnic_group_ref = f8
     2 language_ref = f8
     2 language_dialect_ref = f8
     2 nationality_ref = f8
     2 religion_ref = f8
     2 birth_dt_ref = f8
     2 birth_dt_tm = dq8
     2 birth_tm_zn = f8
     2 multiple_birth_ref = f8
     2 birth_order = vc
     2 birth_length = f8
     2 birth_length_units_ref = f8
     2 birth_weight = f8
     2 birth_weight_units_ref = f8
     2 conception_dt_tm = dq8
     2 conception_tm_zn = f8
     2 gestational_age_days_at_birth = vc
     2 gestational_age_method_ref = f8
     2 nbr_of_brothers = vc
     2 nbr_of_sisters = vc
     2 family_income = f8
     2 family_size = vc
     2 living_arrangement_ref = f8
     2 living_will_ref = f8
     2 deceased_dt_tm = dq8
     2 deceased_tm_zn = f8
     2 cause_of_death_ref = f8
     2 cause_of_death_txt = vc
     2 deceased_ref = f8
     2 deceased_loc_bed_ref = f8
     2 deceased_loc_room_ref = f8
     2 deceased_loc_nurse_unit_ref = f8
     2 deceased_loc_building_ref = f8
     2 deceased_loc_facility_ref = f8
     2 smokes_ref = f8
     2 organ_donor_status_ref = f8
     2 nbr_of_pregnancies = vc
     2 adopted_status_ref = f8
     2 bad_debt_ref = f8
     2 callback_consent_ref = f8
     2 student_ref = f8
     2 highest_grade_complete_ref = f8
     2 highest_degree_complete_ref = f8
     2 diet_type_ref = f8
     2 disease_alert_ref = f8
     2 tumor_registry_ref = f8
     2 autopsy_ref = f8
     2 citizenship_ref = f8
     2 confidential_level_ref = f8
     2 military_base_location = vc
     2 military_rank_ref = f8
     2 military_service_ref = f8
     2 vet_military_status_ref = f8
     2 sex_change_ind = i2
     2 species_ref = f8
     2 vip_ref = f8
     2 nok_relation_ref = f8
     2 nok_related_person_sk = f8
     2 nok_related_person_reltn_ref = f8
     2 nok_specific_family_reltn_ref = f8
     2 nok_genetic_reltn_ind = i2
     2 nok_living_with_ind = i2
     2 nok_mother_child_reltn_ind = i2
     2 nok_full_name = vc
     2 nok_first_name = vc
     2 nok_middle_name = vc
     2 nok_last_name = vc
     2 nok_address_line_1 = vc
     2 nok_address_line_2 = vc
     2 nok_address_line_3 = vc
     2 nok_address_line_4 = vc
     2 nok_city_txt = vc
     2 nok_state_ref = f8
     2 nok_state = vc
     2 nok_postal_code = vc
     2 nok_postal_code_nls = vc
     2 nok_county_ref = f8
     2 nok_county = vc
     2 nok_country_ref = f8
     2 nok_country = vc
     2 nok_residence_ref = f8
     2 nok_residence_type_ref = f8
     2 nok_phone_nbr = vc
     2 nok_email_address = vc
     2 occupation_ref = f8
     2 employer_org = f8
     2 employer_organization_name_txt = vc
     2 employer_contact_title = vc
     2 employer_contact_name = vc
     2 employee_type_ref = f8
     2 employee_status_ref = f8
     2 employee_position = vc
     2 employee_title = vc
     2 employee_nbr = vc
     2 employee_hire_dt_tm = dq8
     2 employee_hire_tm_zn = f8
     2 employee_retire_dt_tm = dq8
     2 employee_retire_tm_zn = f8
     2 employee_terminated_dt_tm = dq8
     2 employee_terminated_tm_zn = f8
     2 primary_care_physician_prsnl = f8
     2 primary_care_physician_ft_name = vc
     2 ob_gyn_physician_prsnl = f8
     2 ob_gyn_physician_ft_name = vc
     2 pediatrician_physician_prsnl = f8
     2 pediatrician_physician_ft_name = vc
     2 family_physician_prsnl = f8
     2 family_physician_ft_name = vc
     2 life_case_manager_prsnl = f8
     2 life_case_manager_ft_name = vc
     2 subscriber_person_sk = f8
     2 subscriber_person_reltn_ref = f8
     2 person_subscriber_reltn_ref = f8
     2 prsnl_personnel_sk = f8
     2 prsnl_person_sk = f8
     2 personnel_full_name = vc
     2 personnel_first_name = vc
     2 personnel_last_name = vc
     2 business_address_line_1 = vc
     2 business_address_line_2 = vc
     2 business_address_line_3 = vc
     2 business_address_line_4 = vc
     2 business_city = vc
     2 business_state_ref = f8
     2 business_state = vc
     2 business_postal_code = vc
     2 business_postal_code_nls = vc
     2 business_county_ref = f8
     2 business_county = vc
     2 business_country_ref = f8
     2 business_country = vc
     2 business_residence_ref = f8
     2 business_residence_type_ref = f8
     2 business_phone_nbr = vc
     2 business_email_address = vc
     2 business_fax_nbr = vc
     2 business_pager_nbr = vc
     2 state_license_nbr = vc
     2 state_license_exp_dt_tm = dq8
     2 state_license_exp_tm_zn = f8
     2 upin_nbr = vc
     2 upin_nbr_exp_dt_tm = dq8
     2 upin_nbr_exp_tm_zn = f8
     2 dea_nbr = vc
     2 dea_nbr_exp_dt_tm = dq8
     2 dea_nbr_exp_tm_zn = f8
     2 emergency_staff_nbr = vc
     2 community_physician_nbr = vc
     2 organization_physician_nbr = vc
     2 external_identifier_nbr = vc
     2 primary_medical_specialty_ref = f8
     2 position_ref = f8
     2 physician_ind = i2
     2 last_encntr_id = f8
     2 nok_table = vc
     2 alt1_table_name = vc
     2 alt1_type = f8
     2 alt1_pool = f8
     2 alt1_alias = vc
     2 alt2_table_name = vc
     2 alt2_type = f8
     2 alt2_pool = f8
     2 alt2_alias = vc
     2 alt3_table_name = vc
     2 alt3_type = f8
     2 alt3_pool = f8
     2 alt3_alias = vc
     2 alt4_table_name = vc
     2 alt4_type = f8
     2 alt4_pool = f8
     2 alt4_alias = vc
     2 alt5_table_name = vc
     2 alt5_type = f8
     2 alt5_pool = f8
     2 alt5_alias = vc
     2 per_alt1_alias = vc
     2 per_alt2_alias = vc
     2 per_alt3_alias = vc
     2 per_alt4_alias = vc
     2 per_alt5_alias = vc
     2 birth_prec_flag = i2
     2 abs_birth_dt_tm = dq8
     2 antenatal_person_prsnl_reltn_id = f8
     2 primary_care_person_prsnl_reltn_id = f8
     2 primary_care_physician_org = f8
     2 antenatal_physician_prsnl = f8
     2 antenatal_physician_org = f8
     2 contact_method_ref = f8
     2 written_format_ref = f8
     2 school_org = f8
     2 process_alert_ref = f8
     2 living_dependency_ref = f8
     2 national_ident_status_ref = f8
     2 contact_time_txt = vc
     2 non_gen_practitioner_ident = vc
     2 deceased_source_cd = f8
     2 gen_practitioner_org = f8
     2 src_create_dt_tm = dq8
     2 src_active_ind = i2
     2 prsl_src_create_dt_tm = dq8
     2 prsl_src_active_ind = i2
     2 community_phys_group_ref = f8
     2 prim_assign_loc_ref = f8
 )
 RECORD prsl(
   1 qual[*]
     2 prsnl_personnel_sk = f8
     2 prsnl_person_sk = f8
     2 personnel_full_name = vc
     2 personnel_first_name = vc
     2 personnel_last_name = vc
     2 business_address_line_1 = vc
     2 business_address_line_2 = vc
     2 business_address_line_3 = vc
     2 business_address_line_4 = vc
     2 business_city = vc
     2 business_state_ref = f8
     2 business_state = vc
     2 business_postal_code = vc
     2 business_postal_code_nls = vc
     2 business_county_ref = f8
     2 business_county = vc
     2 business_country_ref = f8
     2 business_country = vc
     2 business_residence_ref = f8
     2 business_residence_type_ref = f8
     2 business_phone_nbr = vc
     2 business_email_address = vc
     2 business_fax_nbr = vc
     2 business_pager_nbr = vc
     2 state_license_nbr = vc
     2 state_license_exp_dt_tm = dq8
     2 upin_nbr = vc
     2 upin_nbr_exp_dt_tm = dq8
     2 dea_nbr = vc
     2 dea_nbr_exp_dt_tm = dq8
     2 emergency_staff_nbr = vc
     2 community_physician_nbr = vc
     2 organization_physician_nbr = vc
     2 external_identifier_nbr = vc
     2 primary_medical_specialty_ref = f8
     2 position_ref = f8
     2 physician_ind = i2
     2 organization_id = f8
     2 src_create_dt_tm = dq8
     2 src_active_ind = i2
     2 community_phys_group_ref = f8
     2 non_gen_practitioner_ident = vc
     2 gen_practitioner_org = f8
     2 prim_assign_loc_ref = f8
 )
 RECORD allpts(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD encounters(
   1 qual[*]
     2 encntr_id = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 person_hss_id = f8
     2 person_sk = f8
     2 financial_nbr_raw = vc
     2 fin_alias_pool_cd = f8
     2 pre_admit_testing_ref = f8
     2 pre_admit_dt_tm = dq8
     2 pre_admit_tm_zn = f8
     2 admit_loc_bed_ref = f8
     2 admit_loc_room_ref = f8
     2 admit_loc_nurse_unit_ref = f8
     2 admit_loc_building_ref = f8
     2 admit_loc_facility_ref = f8
     2 admit_loc_institution_ref = f8
     2 admit_source_ref = f8
     2 admit_type = f8
     2 admit_status = f8
     2 admit_mode_ref = f8
     2 admit_dt_tm = dq8
     2 admit_tm_zn = f8
     2 inpatient_admit_dt_tm = dq8
     2 inpatient_admit_tm_zn = f8
     2 arrive_dt_tm = dq8
     2 arrive_tm_zn = f8
     2 estimated_arrive_dt_tm = dq8
     2 estimated_arrive_tm_zn = f8
     2 discharge_to_loc_ref = f8
     2 discharge_disposition_ref = f8
     2 discharge_dt_tm = dq8
     2 discharge_tm_zn = f8
     2 estimated_depart_dt_tm = dq8
     2 estimated_depart_tm_zn = f8
     2 depart_dt_tm = dq8
     2 depart_tm_zn = f8
     2 visit_nbr = vc
     2 patient_type_ref = f8
     2 encounter_class_ref = f8
     2 encounter_type_class_ref = f8
     2 age_in_years = vc
     2 age_in_days = vc
     2 organization_sk = f8
     2 current_loc_bed_ref = f8
     2 current_loc_room_ref = f8
     2 current_loc_nurse_unit_ref = f8
     2 current_loc_building_ref = f8
     2 current_loc_facility_ref = f8
     2 temporary_loc_cd = f8
     2 temporary_loc_bed_ref = f8
     2 temporary_loc_room_ref = f8
     2 temporary_loc_nurse_unit_ref = f8
     2 temporary_loc_building_ref = f8
     2 temporary_loc_facility_ref = f8
     2 loc_program_service_ref = f8
     2 specialty_unit_ref = f8
     2 isolation_code = f8
     2 accommodation_ref = f8
     2 ambulatory_condition_ref = f8
     2 encounter_status_ref = f8
     2 service_category_ref = f8
     2 medical_service_ref = f8
     2 patient_classification_ref = f8
     2 financial_class_ref = f8
     2 reason_for_visit_txt = vc
     2 mental_category_ref = f8
     2 mental_health_dt_tm = dq8
     2 mental_health_tm_zn = f8
     2 readmit_ref = f8
     2 accommodation_reason_ref = f8
     2 accommodation_request_ref = f8
     2 accompanied_by_ref = f8
     2 admit_with_medication_ref = f8
     2 alternate_decomp_dt_tm = dq8
     2 alternate_decomp_tm_zn = f8
     2 alternate_reason_ref = f8
     2 alternate_lvl_care_ref = f8
     2 alternate_lvl_care_dt_tm = dq8
     2 alternate_lvl_care_tm_zn = f8
     2 blood_bank_donor_procedure_ref = f8
     2 confidential_lvl_ref = f8
     2 care_contract_status_ref = f8
     2 courtesy_ref = f8
     2 diet_type_ref = f8
     2 estimated_length_of_stay = f8
     2 person_giving_information = vc
     2 psychiatric_status_ref = f8
     2 referring_facility_ref = f8
     2 referral_received_dt_tm = dq8
     2 referral_received_tm_zn = f8
     2 region_ref = f8
     2 safekeeping_ref = f8
     2 security_access_ref = f8
     2 sitter_required_ref = f8
     2 trauma_ref = f8
     2 trauma_dt_tm = dq8
     2 trauma_tm_zn = f8
     2 triage_ref = f8
     2 triage_dt_tm = dq8
     2 triage_tm_zn = f8
     2 valuables_ref = f8
     2 vip_ref = f8
     2 visitor_status_ref = f8
     2 primary_insurance_group_sk = vc
     2 primary_insurance_plan_name = vc
     2 primary_insurance_policy_sk = vc
     2 secondary_insurance_group_sk = vc
     2 secondary_insurance_plan_name = vc
     2 secondary_insurance_policy_sk = vc
     2 assign_to_loc_dt_tm = dq8
     2 assign_to_loc_tm_zn = f8
     2 chart_complete_dt_tm = dq8
     2 chart_complete_tm_zn = f8
     2 document_received_dt_tm = dq8
     2 document_received_tm_zn = f8
     2 zero_balance_dt_tm = dq8
     2 zero_balance_tm_zn = f8
     2 source_created_dt_tm = dq8
     2 active_ind = i2
     2 reg_dt_tm = dq8
     2 cancer_code_cnt = i4
     2 coding_dt_tm = dq8
     2 coding_tm_zn = f8
     2 coding_completed_dt_tm = dq8
     2 coding_completed_tm_zn = f8
     2 event_id = f8
     2 final_coding_episode_cnt = i4
     2 enc_alt_ident_1 = vc
     2 enc_alt_ident_2 = vc
     2 enc_alt_ident_3 = vc
     2 enc_alt_ident_4 = vc
     2 enc_alt_ident_5 = vc
     2 total_charge_amt = f8
     2 nhs_commissioning_org = f8
     2 nhs_providing_org = f8
     2 referral_recvd_dt_tm = dq8
     2 referral_recvd_tm_zn = f8
     2 registering_prsnl = f8
     2 wait_list_start_dt_tm = dq8
     2 wait_list_start_tm_zn = f8
     2 medical_record_nbr = vc
     2 formatted_medical_record_nbr = vc
     2 medical_record_nbr_raw = vc
     2 admit_type_ref = f8
     2 mental_health_ind = i2
     2 mother_encounter_sk = f8
     2 formatted_financial_nbr = vc
     2 related_person_reltn_cd = f8
     2 related_person_id = f8
     2 pre_reg_prsnl_id = f8
     2 referring_comment = vc
     2 deceased_ind = vc
     2 coding_prsnl = f8
 )
 RECORD encounters_key(
   1 qual[*]
     2 encounter_sk = f8
 )
 RECORD allorg(
   1 qual[*]
     2 organization_id = f8
     2 org_name = vc
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state_cd = f8
     2 state = vc
     2 zipcode = vc
     2 county_cd = f8
     2 county = vc
     2 country_cd = f8
     2 country = vc
     2 phone_number = vc
     2 fax_phone = vc
     2 email = vc
     2 location_cd = f8
     2 nhs_organization_nbr = vc
     2 nhs_trust_nbr = vc
     2 nhs_trust_ind = i2
     2 src_active_ind = c1
 )
 RECORD allorg_keys(
   1 qual[*]
     2 organization_id = f8
 )
 RECORD nmcltr(
   1 qual[*]
     2 nomenclature_id = f8
     2 cmti = vc
     2 concept_cki = vc
     2 concept_identifier = vc
     2 concept_source_cd = f8
     2 principle_type_cd = f8
     2 source_vocabulary_cd = f8
     2 vocab_axis_cd = f8
     2 mnemonic = vc
     2 short_string = vc
     2 source_string = vc
     2 source_identifier = vc
     2 primary_vterm_ind = i2
     2 amlos = f8
     2 gmlos = f8
     2 drg_weight = f8
     2 drg_category = vc
     2 mdc_cd = f8
     2 valid_flag_desc = vc
     2 sex_flag_desc = vc
     2 age_flag_desc = vc
     2 beg_effective_dt_tm = dq8
     2 src_active_ind = c1
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 code_form_flg = i2
     2 primary_diag_ind = i2
     2 sex_flg = i2
     2 sex_type_edit_flg = i2
     2 age_check_ind = i2
     2 age_low = f8
     2 age_high = f8
     2 age_type_edit_flg = i2
     2 external_cause_flg = i2
     2 occurrence_loc_required_ind = i2
     2 activity_required_ind = i2
     2 cancer_notification_ind = i2
     2 block_nbr_txt = vc
     2 rare_diag_ind = i2
 )
 RECORD nmcltr_keys(
   1 qual[*]
     2 nomenclature_id = f8
 )
 RECORD diag(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 nomenclature_id = f8
     2 diagnosis_id = f8
     2 diagnosis_sk = f8
     2 encntr_slice_id = f8
     2 diag_priority = i4
     2 clinical_diag_priority = i4
     2 diag_type_cd = f8
     2 attestation_dt_tm = dq8
     2 attestation_tm_zn = f8
     2 certainty_cd = f8
     2 classification_cd = f8
     2 clinical_service_cd = f8
     2 confirmation_status_cd = f8
     2 diagnosis_display = vc
     2 diag_ftdesc = vc
     2 diagnostic_category_cd = f8
     2 diag_class_cd = f8
     2 diag_dt_tm = dq8
     2 diag_tm_zn = f8
     2 diag_note = vc
     2 diag_prsnl_id = f8
     2 diag_prsnl_name = vc
     2 probability = i4
     2 ranking_cd = f8
     2 severity_cd = f8
     2 severity_class_cd = f8
     2 severity_ftdesc = vc
     2 svc_cat_hist_id = f8
     2 loc_facility_cd = f8
     2 active_ind = i2
     2 present_on_admit = vc
     2 updt_id = f8
     2 create_dt_tm = dq8
     2 create_tm_zn = f8
     2 contributor_system_cd = f8
 )
 RECORD diag_keys(
   1 qual[*]
     2 diagnosis_id = f8
 )
 RECORD diag_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
     2 encntr_slice_sk = f8
 )
 RECORD enc_hist(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 enc_history_sk = f8
     2 encntr_type_ref = f8
     2 encntr_class_type_ref = f8
     2 organiztion_sk = f8
     2 loc_facility_ref = f8
     2 loc_building_ref = f8
     2 loc_nurse_unit_ref = f8
     2 loc_room_ref = f8
     2 loc_bed_ref = f8
     2 transfer_reason_ref = f8
     2 arrive_dt_tm = dq8
     2 arrive_tm_zn = f8
     2 depart_dt_tm = dq8
     2 depart_tm_zn = f8
     2 depart_prsnl = f8
     2 admit_type_ref = f8
     2 isolation_ref = f8
     2 accommodation_ref = f8
     2 accommodation_reason_ref = f8
     2 medical_service_ref = f8
     2 service_category_ref = f8
     2 specialty_unit_ref = f8
     2 alternate_level_of_care_ref = f8
     2 alternate_lvl_of_care_dt_tm = dq8
     2 alternate_lvl_of_care_tm_zn = f8
     2 transaction_dt_tm = dq8
     2 transaction_tm_zn = f8
     2 active_ind = i2
     2 activity_dt_tm = dq8
     2 active_status_prsnl = f8
 )
 RECORD enc_hist_keys(
   1 qual[*]
     2 encntr_loc_hist_id = f8
 )
 RECORD enc_hist_parent_keys(
   1 qual[*]
     2 encntr_sk = f8
 )
 RECORD enc_grp(
   1 qual[*]
     2 encounter_nk = vc
     2 drg_id = f8
     2 nomenclature_id = f8
     2 encntr_slice_id = f8
     2 svc_cat_hist = f8
     2 encntr_id = f8
     2 comorbidity_cd = f8
     2 drg_payment = i4
     2 drg_payor_cd = f8
     2 drg_priority = i4
     2 mdc_apr_cd = f8
     2 mdc_cd = f8
     2 outlier_cost = i4
     2 outlier_days = i4
     2 outlier_reimbursement_cost = i4
     2 outlier_mortality_cd = f8
     2 risk_of_mortality_cd = f8
     2 severity_of_illness_cd = f8
     2 source_vocabulary_cd = f8
     2 alos = f8
     2 case_resource_weight = i4
     2 complexity_overlay = i4
     2 day_threshold = i4
     2 elos = f8
     2 hospital_base_rate = i4
     2 mcc = i4
     2 mcc_text = vc
     2 ontario_case_weight = f8
     2 patient_status_cd = f8
     2 perdiem = f8
     2 total_est_reimb = i4
     2 total_reimb_value = f8
     2 active_ind = i2
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 high_trim_value = f8
     2 low_trim_value = f8
     2 wies_weight_value = f8
 )
 RECORD enc_grp_keys(
   1 qual[*]
     2 drg_id = f8
     2 encounter_id = f8
     2 enc_nk = vc
 )
 RECORD enc_grp_parent_keys(
   1 qual[*]
     2 encntr_id = f8
     2 encntr_slice_sk = f8
 )
 RECORD enc_prsnl(
   1 qual[*]
     2 encounter_nk = vc
     2 encntr_sk = f8
     2 enc_prsnl_reltn_sk = vc
     2 encounter_prsnl = f8
     2 personnel_free_text_name = vc
     2 personnel_type_ref = vc
     2 personnel_internal_seq = f8
     2 beg_prsnl_activity_dt_tm = dq8
     2 beg_prsnl_activity_tm_zn = f8
     2 loc_facility_cd = f8
     2 active_ind = i2
     2 practice_org = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 beg_effective_tm_zn = f8
     2 end_effective_tm_zn = f8
 )
 RECORD enc_prsnl_keys(
   1 qual[*]
     2 enc_prsnl_reltn_sk = vc
     2 personnel_type_ref = vc
 )
 DECLARE loadorphans(subject_area=vc,db_name=vc) = i2 WITH public
 SUBROUTINE loadorphans(subject_area,db_name)
   DECLARE syscmd = vc WITH private, noconstant("")
   DECLARE len = i4 WITH private, noconstant(0)
   DECLARE return_val = i4 WITH private, noconstant(0)
   DECLARE rtl2_defined = i2 WITH private, noconstant(0)
   FREE DEFINE rtl2
   FREE RECORD reply_orphans
   RECORD reply_orphans(
     1 qual[*]
       2 orphan_key = f8
       2 orphan_key_vc = vc
   ) WITH persistscript
   CASE (subject_area)
    OF "ENCOUNTER":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh ENCOUNTER ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load ENCOUNTER ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:encounter.dat") != 0)
      CALL echo("processing encounter.dat")
      DEFINE rtl2 "ORPHANLOCAL:ENCOUNTER.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "ENCNTR":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh ENCOUNTER ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load ENCOUNTER ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:encounter.dat") != 0)
      CALL echo("processing encounter.dat")
      DEFINE rtl2 "ORPHANLOCAL:ENCOUNTER.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "MIC_ORDER":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh MIC_ORDER ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load MIC_ORDER ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:mic_order.dat") != 0)
      CALL echo("processing mic_order.dat")
      DEFINE rtl2 "ORPHANLOCAL:MIC_ORDER.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "MIC_TASK":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh MIC_TASK ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load MIC_TASK ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:mic_task.dat") != 0)
      CALL echo("processing mic_task.dat")
      DEFINE rtl2 "ORPHANLOCAL:MIC_TASK.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "GLB_ORDR":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh GLB_ORDR ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load GLB_ORDR ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:glb_ordr.dat") != 0)
      CALL echo("processing glb_ordr.dat")
      DEFINE rtl2 "ORPHANLOCAL:GLB_ORDR.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "PHA_DISP":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh PHA_DISP ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load PHA_DISP ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:pha_disp.dat") != 0)
      CALL echo("processing pha_disp.dat")
      DEFINE rtl2 "ORPHANLOCAL:PHA_DISP.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "PHA_INGR":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh PHA_INGR ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load PHA_INGR ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:pha_ingr.dat") != 0)
      CALL echo("processing pha_ingr.dat")
      DEFINE rtl2 "ORPHANLOCAL:PHA_INGR.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "PHA_ORD":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh PHA_ORD ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load PHA_ORD ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:pha_ord.dat") != 0)
      CALL echo("processing pha_ord.dat")
      DEFINE rtl2 "ORPHANLOCAL:PHA_ORD.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "SURG_CS":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh SURG_CS ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load SURG_CS ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:surg_cs.dat") != 0)
      CALL echo("processing surg_cs.dat")
      DEFINE rtl2 "ORPHANLOCAL:SURG_CS.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "SURG_P":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh SURG_P ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load SURG_P ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:surg_p.dat") != 0)
      CALL echo("processing surg_p.dat")
      DEFINE rtl2 "ORPHANLOCAL:SURG_P.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "ORDER":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh ORDER ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load ORDER ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:order.dat") != 0)
      CALL echo("processing order.dat")
      DEFINE rtl2 "ORPHANLOCAL:ORDER.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "PWPHSE":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh PWPHSE ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load PWPHSE ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:pwphse.dat") != 0)
      CALL echo("processing pwphse.dat")
      DEFINE rtl2 "ORPHANLOCAL:PWPHSE.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "OUTCME":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh OUTCME ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load OUTCME ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:outcme.dat") != 0)
      CALL echo("processing outcme.dat")
      DEFINE rtl2 "ORPHANLOCAL:OUTCME.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "CLN_EVNT":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh CLN_EVNT ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load CLN_EVNT ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:cln_evnt.dat") != 0)
      CALL echo("processing cln_evnt.dat")
      DEFINE rtl2 "ORPHANLOCAL:CLN_EVNT.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "SCH_CAL":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh SCH_CAL ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load SCH_CAL ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:sch_cal.dat") != 0)
      CALL echo("processing sch_cal.dat")
      DEFINE rtl2 "ORPHANLOCAL:SCH_CAL.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "SCH_APPT":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh SCH_APPT ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load SCH_APPT ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:sch_appt.dat") != 0)
      CALL echo("processing sch_appt.dat")
      DEFINE rtl2 "ORPHANLOCAL:SCH_APPT.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "TRK_EVNT":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh TRK_EVNT ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load TRK_EVNT ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:trk_evnt.dat") != 0)
      CALL echo("processing trk_evnt.dat")
      DEFINE rtl2 "ORPHANLOCAL:TRK_EVNT.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "TRK_ITEM":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh TRK_ITEM ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load TRK_ITEM ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:trk_item.dat") != 0)
      CALL echo("processing trk_item.dat")
      DEFINE rtl2 "ORPHANLOCAL:TRK_ITEM.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "PREARR":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh PREARR ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load PREARR ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:prearr.dat") != 0)
      CALL echo("processing prearr.dat")
      DEFINE rtl2 "ORPHANLOCAL:PREARR.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "AP_SPEC":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh AP_SPEC ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load AP_SPEC ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:ap_spec.dat") != 0)
      CALL echo("processing ap_spec.dat")
      DEFINE rtl2 "ORPHANLOCAL:AP_SPEC.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "AP_BLK":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh AP_BLK ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load AP_BLK ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:ap_blk.dat") != 0)
      CALL echo("processing ap_blk.dat")
      DEFINE rtl2 "ORPHANLOCAL:AP_BLK.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "AP_SLIDE":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh AP_SLIDE ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load AP_SLIDE ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:ap_slide.dat") != 0)
      CALL echo("processing ap_slide.dat")
      DEFINE rtl2 "ORPHANLOCAL:AP_SLIDE.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "AP_CASE":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh AP_CASE ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load AP_CASE ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:ap_case.dat") != 0)
      CALL echo("processing ap_case.dat")
      DEFINE rtl2 "ORPHANLOCAL:AP_CASE.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "SCD_STY":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh SCD_STY ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load SCD_STY ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:scd_sty.dat") != 0)
      CALL echo("processing scd_sty.dat")
      DEFINE rtl2 "ORPHANLOCAL:SCD_STY.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "SCD_TERM":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh SCD_TERM ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load SCD_TERM ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:scd_term.dat") != 0)
      CALL echo("processing scd_term.dat")
      DEFINE rtl2 "ORPHANLOCAL:SCD_TERM.DAT"
      SET rtl2_defined = 1
     ENDIF
    OF "FIN_ENC":
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh FIN_ENC ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load FIN_ENC ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile("orphanlocal:fin_enc.dat") != 0)
      CALL echo("processing fin_enc.dat")
      DEFINE rtl2 "ORPHANLOCAL:FIN_ENC.DAT"
      SET rtl2_defined = 1
     ENDIF
    ELSE
     IF (cursys="AIX")
      SET syscmd = concat("$cer_install/orphan_load.sh ",cnvtupper(subject_area)," ",trim(db_name))
     ELSE
      SET syscmd = concat("@cer_install:orphan_load ",cnvtupper(subject_area)," ",trim(db_name))
     ENDIF
     SET len = size(trim(syscmd))
     CALL dcl(syscmd,len,return_val)
     IF (return_val != 1)
      RETURN(return_val)
     ENDIF
     IF (findfile(concat("orphanlocal:",cnvtlower(subject_area),".dat")) != 0)
      CALL echo(concat("processing ",cnvtlower(subject_area),".dat"))
      DEFINE rtl2 concat("ORPHANLOCAL:",cnvtupper(subject_area),".DAT")
      SET rtl2_defined = 1
     ENDIF
   ENDCASE
   IF (rtl2_defined=1)
    SELECT INTO "nl:"
     FROM rtl2t t
     HEAD REPORT
      line_cnt = 0, pipe_loc = 0, line_length = 0
     DETAIL
      line_cnt = (line_cnt+ 1)
      IF (mod(line_cnt,10)=1)
       stat = alterlist(reply_orphans->qual,(line_cnt+ 9))
      ENDIF
      pipe_loc = findstring("|",t.line), line_length = textlen(trim(t.line))
      CASE (subject_area)
       OF "MULTUM":
        reply_orphans->qual[line_cnt].orphan_key_vc = trim(substring((pipe_loc+ 1),(line_length -
          pipe_loc),t.line),3)
       OF "DRUG_CLS":
        reply_orphans->qual[line_cnt].orphan_key_vc = trim(substring((pipe_loc+ 1),(line_length -
          pipe_loc),t.line),3)
       OF "ORD_ACT":
        reply_orphans->qual[line_cnt].orphan_key_vc = trim(substring((pipe_loc+ 1),(line_length -
          pipe_loc),t.line),3)
       ELSE
        reply_orphans->qual[line_cnt].orphan_key = cnvtreal(substring((pipe_loc+ 1),(line_length -
          pipe_loc),t.line))
      ENDCASE
     FOOT REPORT
      stat = alterlist(reply_orphans->qual,line_cnt)
     WITH nocounter, maxcol = 2000
    ;end select
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 RECORD prcdr(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 procedure_id = f8
     2 nomenclature_id = f8
     2 encntr_slice_id = f8
     2 proc_priority = i4
     2 proc_dt_tm = dq8
     2 proc_tm_zn = f8
     2 proc_dt_prec_cd = f8
     2 proc_dt_prec_flag = i2
     2 proc_minutes = i4
     2 dgvp_ind = i2
     2 anesthesia_cd = f8
     2 anesthesia_minutes = i4
     2 proc_ftdesc = vc
     2 proc_type_flag = i2
     2 ranking_cd = f8
     2 svc_cat_hist_id = f8
     2 sg_prsnl_person_id = f8
     2 sg_ft_prsnl_name = vc
     2 an_prsnl_person_id = f8
     2 an_ft_prsnl_name = vc
     2 cg_prsnl_person_id = f8
     2 cg_ft_prsnl_name = vc
     2 loc_facility_cd = f8
     2 active_ind = i2
     2 create_dt_tm = dq8
     2 create_tm_zn = f8
     2 contributor_system_cd = f8
 )
 RECORD prcdr_keys(
   1 qual[*]
     2 procedure_id = f8
 )
 RECORD prcdr_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
     2 encntr_slice_sk = f8
 )
 RECORD problem(
   1 qual[*]
     2 problem_instance_id = f8
     2 problem_id = f8
     2 person_id = f8
     2 actual_resolution_dt_tm = dq8
     2 actual_resolution_tm_zn = f8
     2 annotated_display = vc
     2 cancel_reason_cd = f8
     2 certainty_cd = f8
     2 classification_cd = f8
     2 cond_type_flag = i2
     2 confirmation_status_cd = f8
     2 course_cd = f8
     2 estimated_resolution_dt_tm = dq8
     2 estimated_resolution_tm_zn = f8
     2 family_aware_cd = f8
     2 life_cycle_dt_cd = f8
     2 life_cycle_dt_flag = i2
     2 life_cycle_dt_tm = dq8
     2 life_cycle_tz = i4
     2 life_cycle_status_cd = f8
     2 nomenclature_id = f8
     2 onset_dt_cd = f8
     2 onset_dt_flag = i2
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 organization_id = f8
     2 persistence_cd = f8
     2 person_aware_cd = f8
     2 person_aware_prognosis_cd = f8
     2 probability = f8
     2 problem_ftdesc = vc
     2 problem_instance_uuid = vc
     2 problem_uuid = vc
     2 prognosis_cd = f8
     2 qualifier_cd = f8
     2 ranking_cd = f8
     2 severity_cd = f8
     2 severity_class_cd = f8
     2 severity_ftdesc = c40
     2 status_updt_dt_tm = dq8
     2 status_updt_tm_zn = f8
     2 status_updt_flag = i2
     2 status_updt_precision_cd = f8
     2 recorded_prsnl = vc
     2 responsible_prsnl = vc
     2 modifier_txt = vc
     2 modifier_nomen_txt = vc
     2 beg_effective_dt_tm = dq8
     2 src_active_ind = i2
 )
 RECORD problem_keys(
   1 qual[*]
     2 problem_instance_id = f8
 )
 RECORD problem_text(
   1 qual[*]
     2 problem_id = f8
 )
 RECORD alerts(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 dlg_event_id = f8
     2 alert_ref = vc
     2 dlg_name = vc
     2 dlg_dt_tm = dq8
     2 dlg_tm_zn = f8
     2 dlg_prsnl_id = f8
     2 override_reason_cd = f8
     2 override_ind = i2
     2 trigger_order_id = f8
     2 trigger_entity_id = f8
     2 attr_value = vc
     2 displayed_ind = vc
     2 active_ind = i2
     2 loc_facility_cd = f8
     2 first_existing_ord_sk = vc
     2 first_existing_ordbl = vc
     2 first_existing_alert_nm = vc
     2 severity_flg = vc
 )
 RECORD alerts_keys(
   1 qual[*]
     2 dlg_event_id = f8
 )
 RECORD alerts_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
 )
 RECORD edw_all_orders(
   1 qual[*]
     2 order_id = f8
     2 default_time_zone = i2
 )
 RECORD edw_orderable(
   1 qual[*]
     2 orderable_sk = f8
     2 catalog_cd = f8
     2 orderable_display = vc
     2 orderable_desc = vc
     2 orderable_type_ref = f8
     2 activity_type_ref = f8
     2 activity_sub_type_ref = f8
     2 bill_only_ind = vc
     2 cki = vc
     2 concept_cki = vc
     2 cont_order_method_flg = vc
     2 clinical_category_ref = f8
     2 dept_display_name = vc
     2 dc_interaction_days = vc
     2 modifiable_flg = vc
     2 orderable_type_flg = vc
     2 orderable_event_ref = f8
     2 orderable_synonym = vc
     2 orderable_synonym_type_ref = f8
     2 opcs_nomen = vc
     2 order_catalog_ref = f8
     2 orderable_cki = vc
     2 src_active_ind = c1
     2 order_sentence_sk = f8
 )
 RECORD edw_orderable_keys(
   1 qual[*]
     2 catalog_cd = f8
 )
 RECORD edw_orderable_orphan_keys(
   1 qual[*]
     2 synonym_id = f8
 )
 RECORD enc_ins(
   1 qual[*]
     2 loc_facility_cd = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 enc_insurance_sk = f8
     2 insurance_hlthpln = f8
     2 assign_benefits_ref = f8
     2 balance_type_ref = f8
     2 card_category_ref = f8
     2 coordination_of_benefits_ref = f8
     2 deduct_amt = vc
     2 deduct_met_amt = vc
     2 deduct_met_dt_tm = dq8
     2 deduct_met_tm_zn = f8
     2 family_deduct_met_amt = vc
     2 family_deduct_met_dt_tm = dq8
     2 family_deduct_met_tm_zn = f8
     2 denial_reason_ref = f8
     2 health_card_expire_dt_tm = dq8
     2 health_card_expire_tm_zn = f8
     2 health_card_issue_dt_tm = dq8
     2 health_card_issue_tm_zn = f8
     2 health_card_nbr = vc
     2 health_card_province = vc
     2 health_card_type = vc
     2 insurance_source_info_ref = f8
     2 insured_card_name = vc
     2 life_rsv_days = i4
     2 life_rsv_daily_ded_amt = vc
     2 life_rsv_daily_ded_qual_ref = f8
     2 member_nbr = vc
     2 orig_priority_seq = i4
     2 priority_seq = i4
     2 plan_class_ref = f8
     2 plan_type_ref = f8
     2 policy_nbr = vc
     2 program_status_ref = f8
     2 coverage_type_ref = f8
     2 max_out_pocket_amt = vc
     2 max_out_pocket_dt_tm = dq8
     2 max_out_pocket_tm_zn = f8
     2 verify_status_ref = f8
     2 active_ind = i2
     2 group_name = vc
     2 group_nbr = vc
     2 organization_id = f8
     2 signature_on_file_cd = f8
     2 src_beg_effective_dt_tm = dq8
     2 src_beg_effective_tm_zn = f8
     2 src_end_effective_dt_tm = dq8
     2 src_end_effective_tm_zn = f8
     2 auth_beg_dt_tm = dq8
     2 auth_beg_tm_zn = i4
     2 auth_end_dt_tm = dq8
     2 auth_end_tm_zn = i4
     2 auth_type_cd = f8
 )
 RECORD enc_ins_keys(
   1 qual[*]
     2 enc_insurance_sk = f8
 )
 RECORD enc_ins_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
 )
 RECORD allergy(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 person_sk = f8
     2 loc_facility_cd = f8
     2 allergy_reaction_sk = vc
     2 allergy_instance_id = f8
     2 allergy_id = f8
     2 cancel_dt_tm = dq8
     2 cancel_tm_zn = f8
     2 cancel_prsnl_id = f8
     2 cancel_reason_cd = f8
     2 created_dt_tm = dq8
     2 created_tm_zn = f8
     2 created_prsnl_id = f8
     2 onset_dt_tm = dq8
     2 onset_tm_zn = i4
     2 onset_precision_cd = f8
     2 onset_precision_flag = i2
     2 alg_onset_precision_offset = i2
     2 orig_prsnl_id = f8
     2 reaction_class_cd = f8
     2 reaction_status_cd = f8
     2 reaction_status_dt_tm = dq8
     2 reaction_status_tm_zn = f8
     2 reviewed_dt_tm = dq8
     2 reviewed_tm_zn = i4
     2 reviewed_prsnl_id = f8
     2 severity_cd = f8
     2 source_of_info_cd = f8
     2 source_of_info_ft = vc
     2 substance_ftdesc = vc
     2 substance_nom_id = f8
     2 substance_type_cd = f8
     2 organization_id = f8
     2 reaction_id = f8
     2 reaction_nom_id = f8
     2 reaction_ftdesc = vc
     2 beg_effective_dt_tm = dq8
     2 alg_beg_effective_dt_tm = dq8
     2 alg_beg_effective_tz = i4
     2 alg_end_effective_dt_tm = dq8
     2 alg_end_effective_tz = i4
     2 react_beg_effective_dt_tm = dq8
     2 react_beg_effective_tz = i4
     2 react_end_effective_dt_tm = dq8
     2 react_end_effective_tz = i4
     2 alg_active_ind = i2
     2 react_active_ind = i2
     2 src_updt_prsnl = f8
     2 src_updt_dt_tm = dq8
     2 src_updt_tz = i4
 )
 RECORD allergy_keys(
   1 qual[*]
     2 allergy_instance_id = f8
 )
 RECORD allergy_react(
   1 qual[*]
     2 allergy_instance_id = f8
     2 reaction_id = f8
 )
 RECORD edw_container(
   1 qual[*]
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 container_sk = f8
     2 parent_container_sk = f8
     2 additional_labels = vc
     2 label_dt_tm = dq8
     2 specimen_sk = f8
     2 storage_rack_cell_sk = f8
     2 collection_list_sk = f8
     2 transfer_list_sk = f8
     2 specimen_type_ref = f8
     2 spec_cntnr_ref = f8
     2 coll_class_ref = f8
     2 spec_hndl_ref = f8
     2 current_location_ref = f8
     2 remaining_volume = vc
     2 volume = vc
     2 drawn_dt_tm = dq8
     2 drawn_sk = f8
     2 received_dt_tm = dq8
     2 received_sk = f8
     2 collection_method_ref = f8
     2 units_ref = f8
     2 original_storage_dt_tm = dq8
     2 suggested_discard_dt_tm = dq8
     2 discard_dt_tm = dq8
     2 task_log_sk = f8
     2 coll_comment_sk = f8
     2 on_robotics_line_flg = i2
     2 instr_login_ind = vc
     2 auto_print_aliquot_ind = vc
     2 storage_status_ref = f8
     2 label_tm_zn = i4
     2 drawn_tm_zn = i4
     2 received_tm_zn = i4
     2 original_storage_tm_zn = i4
     2 suggested_discard_tm_zn = i4
     2 discard_tm_zn = i4
 )
 RECORD edw_osrc(
   1 qual[*]
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 order_sk = f8
     2 container_sk = f8
     2 service_resource_ref = f8
     2 location_ref = f8
     2 status_flg = vc
     2 in_lab_dt_tm = dq8
     2 current_location_ref = f8
     2 av_ind = i2
     2 display_dt_tm = dq8
     2 warning_dt_tm = dq8
     2 alert_dt_tm = dq8
     2 spec_warning_dt_tm = dq8
     2 spec_expire_dt_tm = dq8
     2 in_lab_tm_zn = i4
     2 display_tm_zn = i4
     2 warning_tm_zn = i4
     2 alert_storage_tm_zn = i4
     2 spec_warning_discard_tm_zn = i4
     2 spec_expire_tm_zn = i4
 )
 RECORD edw_all_mic_orders(
   1 qual[*]
     2 order_id = f8
 )
 RECORD edw_mic_orders(
   1 qual[*]
     2 order_sk = f8
     2 micro_order_sk = f8
     2 loc_facility_cd = f8
     2 first_ctnr_drawn_dt_tm_txt = dq8
     2 first_ctnr_drawn_tm_zn = i4
     2 first_ctnr_received_dt_tm_txt = dq8
     2 first_ctnr_received_tm_zn = i4
     2 specimen_received_prsnl = f8
     2 first_ctnr_coll_method_ref = f8
     2 first_ctnr_type_ref = f8
     2 first_specimen_type_ref = f8
     2 frst_perf_svc_res_dept_hier_sk = f8
     2 first_cntr_units_ref = f8
     2 first_cntr_volume = vc
     2 nbr_of_containers = vc
     2 nbr_of_specimens = vc
     2 first_creation_dt_tm_txt = dq8
     2 creation_tm_zn = i4
     2 first_specimen_entr_prsnl = f8
     2 first_specimen_coll_prsnl = f8
     2 first_specimen_source_comment = c40
     2 completed_dt_tm_txt = dq8
     2 completed_tm_zn = i4
     2 ord_test_ref = vc
     2 test_cnt = vc
     2 order_nbr = f8
     2 collection_priority_ref = f8
     2 central_collection_dt_tm_txt = dq8
     2 central_collection_tm_zn = i4
     2 lab_type_flg = vc
     2 continuing_order_ind = vc
     2 order_positive_ind = vc
     2 status_ref = f8
     2 specific_source = vc
     2 specific_source_axis = vc
     2 source_site_freetext = vc
     2 first_specimen_site_ref = f8
     2 long_text_id = f8
     2 sus_nbr_ver = vc
     2 sus_ver_count = vc
     2 collected_ind = vc
     2 frozen_section_requested_ind = vc
     2 culture_start_dt_tm_txt = dq8
     2 culture_start_tm_zn = i4
     2 nosocoimal_ind = vc
     2 active_ind = i2
 )
 RECORD edw_mic_task_ids(
   1 qual[*]
     2 task_log_id = f8
 )
 RECORD edw_mic_tasks(
   1 qual[*]
     2 mic_order_id = f8
     2 micro_order_sk = vc
     2 micro_task_sk = vc
     2 abnormal_ind = vc
     2 action_dt_tm = dq8
     2 action_tm_zn = i4
     2 last_updated_prsnl = f8
     2 instrument_identifier = vc
     2 instrmt_svc_res_dept_hier_sk = f8
     2 task_positive_ind = vc
     2 task_ref = f8
     2 susceptibility_method_ref = f8
     2 report_type_ref = f8
     2 biochemical_group_type_ref = f8
     2 biochemical_detail_type_ref = f8
     2 organism_ref = f8
     2 task_svc_res_dept_hier_sk = f8
     2 task_seq = vc
     2 task_status_ref = f8
     2 performing_prsnl = f8
     2 task_type_flg = vc
     2 active_ind = i2
     2 loc_facility_cd = f8
     2 encntr_id = f8
     2 observed_dt_tm = dq8
     2 observed_tm_zn = i4
 )
 RECORD ce_edw_mic_tasks(
   1 qual[*]
     2 event_id = f8
     2 micro_seq_nbr = i4
 )
 RECORD micro_report(
   1 qual[*]
     2 task_log_id = f8
     2 micro_report_response_sk = vc
     2 response_seq = i4
     2 src_positive_ind = vc
     2 positive_ind = vc
     2 response_ref = f8
     2 response_txt = vc
     2 organism_ref = f8
     2 response_class_flag = i2
     2 abnormal_ind = vc
     2 new_phrase_ind = vc
     2 active_ind = i2
     2 org_task_log_id = f8
 )
 RECORD micro_report_key(
   1 qual[*]
     2 task_log_id = f8
     2 response_seq = i4
 )
 RECORD clinical_evnt(
   1 qual[*]
     2 encounter_nk = vc
     2 person_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 event_id = f8
     2 accession_nbr = vc
     2 authentic_flag = vc
     2 synonym_id = f8
     2 clinical_seq = vc
     2 clinsig_dt_tm = dq8
     2 clinsig_tm_zn = i4
     2 collation_seq = vc
     2 critical_high = vc
     2 critical_low = vc
     2 entry_mode_cd = f8
     2 event_cd = f8
     2 event_class_cd = f8
     2 event_end_dt_tm = dq8
     2 event_end_dt_tm_os = f8
     2 event_end_tm_zn = i4
     2 event_reltn_cd = f8
     2 event_start_dt_tm = dq8
     2 event_start_tm_zn = i4
     2 event_tag = vc
     2 event_tag_set_flag = vc
     2 event_title_text = vc
     2 expiration_dt_tm = dq8
     2 expiration_tm_zn = i4
     2 inquire_sec_cd = f8
     2 event_normacy_ref = f8
     2 normacy_method_cd = f8
     2 normal_high = vc
     2 normal_low = vc
     2 order_action_seq = vc
     2 order_id = f8
     2 parent_event_id = f8
     2 performed_dt_tm = dq8
     2 performed_tm_zn = i4
     2 performed_prsnl_id = f8
     2 publish_flag = vc
     2 record_status_cd = f8
     2 reference_nbr = vc
     2 resource_cd = f8
     2 result_normalcy_flag = i4
     2 result_status_cd = f8
     2 result_time_units_cd = f8
     2 result_units_cd = f8
     2 result_val = vc
     2 result_dt_tm = dq8
     2 result_tm_zn = i4
     2 date_type_flag = vc
     2 result_dt_tm_os = f8
     2 result_val_num = vc
     2 result_val_text = vc
     2 feasible_ind = vc
     2 inaccurate_ind = vc
     2 equation_txt = vc
     2 source_cd = f8
     2 task_assay_cd = f8
     2 task_assay_vrsn_nbr = f8
     2 valid_from_dt_tm = dq8
     2 valid_from_tm_zn = i4
     2 verified_dt_tm = dq8
     2 verified_tm_zn = i4
     2 verified_prsnl_id = f8
     2 active_ind = i2
     2 subtable_bit_map = i4
     2 equation_id = f8
     2 catalog_cd = f8
     2 contributor_system_cd = f8
     2 ce_dynamic_label_id = f8
 )
 RECORD clinical_evnt_keys(
   1 qual[*]
     2 event_id = f8
 )
 RECORD clinical_evnt_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD evt_code(
   1 qual[*]
     2 event_coded_result_sk = vc
     2 event_id = f8
     2 acr_code_str = vc
     2 descriptor = vc
     2 group_nbr = i4
     2 nomenclature_id = f8
     2 pathology_str = vc
     2 proc_code_str = vc
     2 result_cd = f8
     2 sequence_nbr = i4
     2 unit_of_measure_cd = f8
     2 valid_from_dt_tm = dq8
     2 valid_from_tm_zn = i4
     2 active_ind = i4
     2 loc_facility_cd = f8
     2 encntr_id = f8
 )
 RECORD evt_code_keys(
   1 qual[*]
     2 event_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD evt_ids(
   1 qual[*]
     2 event_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD intk_output(
   1 qual[*]
     2 event_id = f8
     2 io_result_id = f8
     2 io_start_dt_tm = dq8
     2 io_start_tm_zn = i4
     2 io_end_dt_tm = dq8
     2 io_end_tm_zn = i4
     2 io_status_cd = f8
     2 io_type_flg = i2
     2 io_volume = f8
     2 valid_from_dt_tm = dq8
     2 valid_from_tm_zn = i4
     2 active_ind = i2
     2 loc_facility_cd = f8
     2 encntr_id = f8
     2 ce_io_result_id = f8
 )
 RECORD intk_output_keys(
   1 qual[*]
     2 ce_io_result_id = f8
 )
 RECORD intk_output_parent_keys(
   1 qual[*]
     2 event_id = f8
 )
 RECORD ce_med_keys(
   1 qual[*]
     2 med_key = f8
     2 encounter_nk = vc
     2 loc_facility_cd = f8
 )
 RECORD rad_med_keys(
   1 qual[*]
     2 med_key = f8
 )
 RECORD med_admin(
   1 qual[*]
     2 med_key = f8
     2 encounter_nk = vc
     2 person_sk = f8
     2 encounter_sk = f8
     2 med_admin_sk = vc
     2 event_sk = f8
     2 med_admin_event_sk = f8
     2 order_sk = f8
     2 dosage = f8
     2 admin_end_dt_tm = dq
     2 admin_end_tm_zn = i4
     2 method_ref = f8
     2 note = vc
     2 admin_prsnl = f8
     2 patient_location_loc = f8
     2 route_ref = f8
     2 site_ref = f8
     2 start_dt_tm = dq
     2 start_tm_zn = i4
     2 strength = i4
     2 strength_unit_ref = f8
     2 diluent_type_ref = f8
     2 dosage_unit_ref = f8
     2 immunization_type_ref = f8
     2 infused_volume = f8
     2 infused_volume_unit_ref = f8
     2 infusion_rate = f8
     2 infusion_time_ref = f8
     2 infusion_unit_ref = f8
     2 initial_dosage = f8
     2 initial_volume = f8
     2 iv_event_ref = f8
     2 medication_form_ref = f8
     2 reason_required_flg = vc
     2 refusal_ref = f8
     2 remaining_volume = f8
     2 remaining_volume_unit_ref = f8
     2 response_required_flg = vc
     2 substance_exp_dt_tm = dq
     2 substance_exp_tm_zn = i4
     2 substance_lot_nbr = vc
     2 substance_manufacturer_ref = f8
     2 med_admin_ordbl = f8
     2 system_entry_dt_tm = dq
     2 system_entry_tm_zn = i4
     2 total_intake_volume = f8
     2 consent_received_ind = vc
     2 approved_prsnl = f8
     2 active_ind = i2
     2 loc_facility_cd = f8
     2 rad_med_id = f8
     2 comments_long_text_sk = f8
     2 freetext_reason = vc
 )
 RECORD fill_cycle(
   1 qual[*]
     2 fill_cycle_hist_sk = vc
     2 fill_list_hist_sk = f8
     2 cycle_time = i4
     2 cycle_time_unit_flg = i2
     2 discontinue_time = i4
     2 discontinue_time_unit_flg = i2
     2 fill_list_complete_dt_tm = dq8
     2 fill_list_completed_tm_zn = i4
     2 fill_time = i4
     2 fill_time_unit_flg = i2
     2 incomplete_order_ind = vc
     2 alt_dispense_location_ref = f8
     2 max_cycle_time = i4
     2 max_cycle_time_unit_flg = i2
     2 max_fill_time = i4
     2 max_fill_time_unit_flg = i2
     2 min_elapsed_time = i4
     2 min_elapsed_time_unit_flg = i2
     2 output_device_type_ref = f8
     2 output_device_desc = vc
     2 output_format_ref = f8
     2 prn_fill_time = i4
     2 prn_fill_time_unit_flg = i2
     2 fill_list_start_dt_tm = dq8
     2 fill_list_start_tm_zn = i4
     2 suspend_time = i4
     2 suspend_time_unit_flg = i2
     2 unverified_order_ind = vc
     2 audit_prsnl = f8
     2 dispense_category_ref = f8
     2 med_admin_loc = f8
     2 processing_end_dt_tm = dq8
     2 processing_end_tm_zn = i4
     2 cycle_range_begin_dt_tm = dq8
     2 cycle_range_begin_tm_zn = i4
     2 last_operation_flg = i2
     2 order_cnt = vc
     2 processing_began_dt_tm = dq8
     2 processing_began_tm_zn = i4
     2 cycle_range_end_dt_tm = dq8
     2 cycle_range_end_tm_zn = i4
     2 loc_facility_cd = f8
 )
 RECORD fill_cycle_keys(
   1 qual[*]
     2 fill_list_hist_sk = f8
 )
 FREE RECORD ritem
 RECORD ritem(
   1 qual[*]
     2 pharm_type_cd = f8
     2 item_id = f8
 )
 FREE RECORD rpharmacy_codes
 RECORD rpharmacy_codes(
   1 qual[*]
     2 pharmacy_codes = f8
 )
 FREE RECORD ritemdtl
 RECORD ritemdtl(
   1 item_list[*]
     2 med_def_item = f8
     2 manf_item = vc
     2 pharm_type_ref = f8
     2 always_disp_from_flag = i2
     2 cki = vc
     2 continuous_filter_ind = i2
     2 dispense_qty = f8
     2 dispense_qty_unit_ref = f8
     2 divisible_ind = i2
     2 formulary_status_ref = f8
     2 form_ref = f8
     2 given_strength = vc
     2 intermittent_filter_ind = i2
     2 legal_status_ref = f8
     2 micromedex_nomen = f8
     2 med_filter_ind = i2
     2 med_type_flag = i2
     2 meq_factor = f8
     2 mmol_factor = f8
     2 strength = f8
     2 strength_unit_ref = f8
     2 volume = f8
     2 volume_unit_ref = f8
     2 avg_wholesale_price = f8
     2 avg_wholesale_price_bulk = f8
     2 avg_wholesale_price_factor = f8
     2 manufacturer_ref = f8
     2 brand_ind = i2
     2 unit_dose_ind = i2
     2 reusable_ind = i2
     2 ndc = vc
     2 brandname = vc
     2 generic_name = vc
     2 dispense_category_ref = f8
     2 med_product_id = f8
 )
 FREE RECORD info_request
 RECORD info_request(
   1 itemlist[*]
     2 item_id = f8
   1 pharm_type_cd = f8
   1 facility_cd = f8
   1 pharm_loc_cd = f8
   1 pat_loc_cd = f8
   1 encounter_type_cd = f8
   1 package_type_id = f8
   1 med_all_ind = i2
   1 med_pha_flex_ind = i2
   1 med_identifier_ind = i2
   1 med_dispense_ind = i2
   1 med_oe_default_ind = i2
   1 med_def_ind = i2
   1 ther_class_ind = i2
   1 med_product_ind = i2
   1 med_product_prim_ind = i2
   1 med_product_ident_ind = i2
   1 med_cost_ind = i2
   1 misc_object_ind = i2
   1 med_cost_type_cd = f8
   1 med_child_ind = i2
   1 parent_item_id = f8
   1 options_pref = i4
   1 birthdate = dq8
 )
 FREE RECORD myrequest_old
 RECORD myrequest_old(
   1 care_locn_cd = f8
   1 pharm_type_cd = f8
   1 facility_loc_cd = f8
   1 qual[*]
     2 item_id = f8
   1 get_orc_info_ind = i2
   1 get_comment_text_ind = i2
   1 get_ord_sent_info_ind = i2
   1 def_dispense_category_cd = f8
   1 encounter_type_cd = f8
 )
 FREE RECORD myreply_new
 RECORD myreply_new(
   1 itemlist[*]
     2 parent_item_id = f8
     2 sequence = i4
     2 active_ind = i2
     2 med_def_flex_sys_id = f8
     2 med_def_flex_syspkg_id = f8
     2 item_id = f8
     2 package_type_id = f8
     2 form_cd = f8
     2 cki = vc
     2 med_type_flag = i2
     2 mdx_gfc_nomen_id = f8
     2 base_issue_factor = f8
     2 given_strength = vc
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 compound_text_id = f8
     2 mixing_instructions = vc
     2 pkg_qty = f8
     2 pkg_qty_cd = f8
     2 catalog_cd = f8
     2 catalog_cki = vc
     2 synonym_id = f8
     2 oeformatid = f8
     2 orderabletypeflag = i2
     2 catalogdescription = vc
     2 catalogtypecd = f8
     2 mnemonicstr = vc
     2 primarymnemonic = vc
     2 label_description = vc
     2 brand_name = vc
     2 mnemonic = vc
     2 generic_name = vc
     2 profile_desc = vc
     2 cdm = vc
     2 rx_mask = i4
     2 med_oe_defaults_id = f8
     2 med_oe_strength = f8
     2 med_oe_strength_unit_cd = f8
     2 med_oe_volume = f8
     2 med_oe_volume_unit_cd = f8
     2 freetext_dose = vc
     2 frequency_cd = f8
     2 route_cd = f8
     2 prn_ind = i2
     2 infuse_over = f8
     2 infuse_over_cd = f8
     2 duration = f8
     2 duration_unit_cd = f8
     2 stop_type_cd = f8
     2 default_par_doses = i4
     2 max_par_supply = i4
     2 dispense_category_cd = f8
     2 alternate_dispense_category_cd = f8
     2 comment1_id = f8
     2 comment1_type = i2
     2 comment2_id = f8
     2 comment2_type = i2
     2 comment1_text = vc
     2 comment2_text = vc
     2 price_sched_id = f8
     2 nbr_labels = i4
     2 ord_as_synonym_id = f8
     2 rx_qty = f8
     2 daw_cd = f8
     2 sig_codes = vc
     2 med_dispense_id = f8
     2 med_disp_package_type_id = f8
     2 med_disp_strength = f8
     2 med_disp_strength_unit_cd = f8
     2 med_disp_volume = f8
     2 med_disp_volume_unit_cd = f8
     2 legal_status_cd = f8
     2 formulary_status_cd = f8
     2 oe_format_flag = i2
     2 med_filter_ind = i2
     2 continuous_filter_ind = i2
     2 intermittent_filter_ind = i2
     2 divisible_ind = i2
     2 used_as_base_ind = i2
     2 always_dispense_from_flag = i2
     2 floorstock_ind = i2
     2 dispense_qty = f8
     2 dispense_factor = f8
     2 label_ratio = f8
     2 prn_reason_cd = f8
     2 infinite_div_ind = f8
     2 reusable_ind = i2
     2 base_pkg_type_id = f8
     2 base_pkg_qty = f8
     2 base_pkg_uom_cd = f8
     2 medidqual[*]
       3 identifier_id = f8
       3 identifier_type_cd = f8
       3 value = vc
       3 value_key = vc
       3 sequence = i4
     2 medproductqual[*]
       3 active_ind = i2
       3 med_product_id = f8
       3 manf_item_id = f8
       3 inner_pkg_type_id = f8
       3 inner_pkg_qty = f8
       3 inner_pkg_uom_cd = f8
       3 bio_equiv_ind = i2
       3 brand_ind = i2
       3 unit_dose_ind = i2
       3 manufacturer_cd = f8
       3 manufacturer_name = vc
       3 label_description = vc
       3 ndc = c13
       3 brand = vc
       3 sequence = i2
       3 awp = f8
       3 awp_factor = f8
       3 formulary_status_cd = f8
       3 item_master_id = f8
       3 base_pkg_type_id = f8
       3 base_pkg_qty = f8
       3 base_pkg_uom_cd = f8
       3 medcostqual[*]
         4 cost_type_cd = f8
         4 cost = f8
     2 medingredqual[*]
       3 med_ingred_set_id = f8
       3 sequence = i2
       3 child_item_id = f8
       3 child_med_prod_id = f8
       3 child_pkg_type_id = f8
       3 base_ind = i2
       3 cmpd_qty = f8
       3 default_action_cd = f8
       3 cost1 = f8
       3 cost2 = f8
       3 awp = f8
       3 inc_in_total_ind = i2
       3 normalized_rate_ind = i2
     2 theraclassqual[*]
       3 alt_sel_category_id = f8
       3 ahfs_code = c6
     2 miscobjectqual[*]
       3 parent_entity_id = f8
       3 cdf_meaning = vc
     2 firstdoselocqual[*]
       3 location_cd = f8
     2 pkg_qty_per_pkg = f8
     2 pkg_disp_more_ind = i2
     2 dispcat_flex_ind = i4
     2 pricesch_flex_ind = i4
     2 workflow_cd = f8
     2 cmpd_qty = f8
     2 warning_labels[*]
       3 label_nbr = i4
       3 label_seq = i2
       3 label_text = vc
       3 label_default_print = i2
       3 label_exception_ind = i2
     2 premix_ind = i2
     2 ord_as_mnemonic = vc
     2 tpn_balance_method_cd = f8
     2 tpn_chloride_pct = f8
     2 tpn_default_ingred_item_id = f8
     2 tpn_fill_method_cd = f8
     2 tpn_include_ions_flag = i2
     2 tpn_overfill_amt = f8
     2 tpn_overfill_unit_cd = f8
     2 tpn_preferred_cation_cd = f8
     2 tpn_product_type_flag = i2
     2 lot_tracking_ind = i2
     2 rate = f8
     2 rate_cd = f8
     2 normalized_rate = f8
     2 normalized_rate_cd = f8
     2 freetext_rate = vc
     2 normalized_rate_ind = i2
     2 ord_detail_opts[*]
       3 facility_cd = f8
       3 age_range_id = f8
       3 oe_field_meaning_id = f8
       3 restrict_ind = i4
       3 opt_list[*]
         4 opt_txt = vc
         4 opt_cd = f8
         4 opt_nbr = f8
         4 default_ind = i4
         4 display_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD myreply_old
 RECORD myreply_old(
   1 qual[*]
     2 item_id = f8
     2 form_cd = f8
     2 dispense_category_cd = f8
     2 alternate_dispense_category_cd = f8
     2 order_sentence_id = f8
     2 med_type_flag = i2
     2 med_filter_ind = i2
     2 intermittent_filter_ind = i2
     2 continuous_filter_ind = i2
     2 floorstock_ind = i2
     2 always_dispense_from_flag = i2
     2 oe_format_flag = i2
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 used_as_base_ind = i2
     2 divisible_ind = i2
     2 base_issue_factor = f8
     2 prn_reason_cd = f8
     2 infinite_div_ind = i2
     2 alert_qual[*]
       3 order_alert_cd = f8
     2 order_alert1_cd = f8
     2 order_alert2_cd = f8
     2 comment1_id = f8
     2 comment1_type = i4
     2 comment2_id = f8
     2 comment2_type = i4
     2 comment1 = vc
     2 comment2 = vc
     2 given_strength = c25
     2 default_par_doses = i4
     2 max_par_supply = i4
     2 cki = vc
     2 multumid = vc
     2 manf_item_id = f8
     2 awp = f8
     2 awp_factor = f8
     2 cost1 = f8
     2 cost2 = f8
     2 dispense_qty = f8
     2 dispense_qty_cd = f8
     2 price_sched_id = f8
     2 ndc = vc
     2 item_description = vc
     2 brand_name = vc
     2 generic_name = vc
     2 manufacturer_cd = f8
     2 manufacturer_disp = c40
     2 manufacturer_desc = c60
     2 primary_manf_item_id = f8
     2 formulary_status_cd = f8
     2 long_description = vc
     2 oeformatid = f8
     2 orderabletypeflag = i2
     2 synonymid = f8
     2 catalogcd = f8
     2 catalogdescription = vc
     2 catalogtypecd = f8
     2 mnemonicstr = vc
     2 primarymnemonic = vc
     2 altselcatid = f8
     2 qual[*]
       3 sequence = i4
       3 oe_field_value = f8
       3 oe_field_id = f8
       3 oe_field_display_value = vc
       3 oe_field_meaning_id = f8
       3 field_type_flag = i2
     2 med_oe_defaults_id = f8
     2 med_oe_strength = f8
     2 med_oe_strength_unit_cd = f8
     2 med_oe_volume = f8
     2 med_oe_volume_unit_cd = f8
     2 legal_status_cd = f8
     2 freetext_dose = vc
     2 frequency_cd = f8
     2 route_cd = f8
     2 prn_ind = i2
     2 infuse_over = f8
     2 infuse_over_cd = f8
     2 duration = f8
     2 duration_unit_cd = f8
     2 stop_type_cd = f8
     2 nbr_labels = i4
     2 rx_qty = f8
     2 daw_cd = f8
     2 sig_codes = vc
     2 dispense_factor = f8
     2 medproductqual[*]
       3 active_ind = i2
       3 med_product_id = f8
       3 manf_item_id = f8
       3 inner_pkg_type_id = f8
       3 inner_pkg_qty = f8
       3 inner_pkg_uom_cd = f8
       3 bio_equiv_ind = i2
       3 brand_ind = i2
       3 unit_dose_ind = i2
       3 manufacturer_cd = f8
       3 manufacturer_name = vc
       3 label_description = vc
       3 ndc = c13
       3 sequence = i2
       3 awp = f8
       3 awp_factor = f8
       3 formulary_status_cd = f8
       3 item_master_id = f8
       3 base_pkg_type_id = f8
       3 base_pkg_qty = f8
       3 base_pkg_uom_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD frequency(
   1 qual[*]
     2 freq_schedule_sk = f8
     2 frequency_ref = f8
     2 frequency_qualifier = i4
     2 parent_entity_sk = f8
     2 associated_code_value_ref = f8
     2 associated_order_cat_ref = f8
     2 associated_folder_sk = f8
     2 associated_prsnl = f8
     2 associated_orders_sk = f8
     2 activity_type_ref = f8
     2 instance = i4
     2 facility_loc = f8
     2 description = vc
     2 frequency_type_flg = i4
     2 first_dose_method_flg = i4
     2 first_dose_range = i4
     2 first_dose_range_unit_ref = i4
     2 interval = i4
     2 interval_unit_ref = i4
     2 max_event_per_day = i4
     2 prn_default_ind = vc
     2 day_of_week = vc
     2 sunday_ind = i4
     2 monday_ind = i4
     2 tuesday_ind = i4
     2 wednesday_ind = i4
     2 thursday_ind = i4
     2 friday_ind = i4
     2 saturday_ind = i4
     2 time_of_day = vc
     2 src_active_ind = c1
 )
 RECORD frequency_keys(
   1 qual[*]
     2 freq_schedule_sk = f8
 )
 RECORD item_ref(
   1 qual[*]
     2 item_sk = f8
     2 item_type_ref = f8
     2 component_ind = vc
     2 latex_ind = vc
     2 reusable_ind = vc
     2 shelf_life = vc
     2 shelf_life_uom_ref = f8
     2 substitution_ind = vc
     2 cost_center_ref = f8
     2 countable_ind = vc
     2 critical_ind = vc
     2 fda_reportable_ind = vc
     2 schedulable_ind = vc
     2 sterilization_required_ind = vc
     2 storage_requirement_ref = f8
     2 description = vc
     2 manufacturer_item_nbr = vc
     2 lot_nbr = vc
     2 safety_check_ind = vc
     2 classification_node_ref = f8
     2 src_active_ind = c1
     2 sub_account_ref = vc
     2 create_prsnl = vc
     2 create_dt_tm = dq8
     2 standard_tm_zn = i2
     2 updt_prsnl = vc
     2 src_updt_dt_tm = dq8
     2 base_package_type_sk = f8
     2 ndc = vc
     2 item_nbr = vc
     2 vendor_item_nbr = vc
     2 manufact_item_sk = f8
     2 vendor_item_sk = f8
     2 vendor_manf_ref = f8
 )
 RECORD item_ref_keys(
   1 qual[*]
     2 item_sk = f8
 )
 RECORD pathway(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 pathway_phase_sk = f8
     2 plan_pathway_catalog_sk = f8
     2 phase_pathway_catalog_sk = f8
     2 cycle_nbr = i4
     2 discontinued_dt_tm = f8
     2 discontinued_dt_tm_zn = i4
     2 discontinued_prsnl = f8
     2 order_dt_tm = dq8
     2 order_dt_tm_zn = i4
     2 start_dt_tm = dq8
     2 start_dt_tm_zn = i4
     2 started_ind = vc
     2 actual_end_dt_tm = dq8
     2 actual_end_tm_zn = i4
     2 calculated_end_dt_tm = dq8
     2 calculated_end_tm_zn = i4
     2 discontinued_ref = f8
     2 discontinued_ind = vc
     2 ended_ind = vc
     2 last_action_seq = i4
     2 pathway_status_ref = f8
     2 pathway_catalog_version = i4
     2 pathway_group_nbr = f8
     2 status_dt_tm = dq8
     2 status_tm_zn = i4
     2 status_prsnl = f8
     2 first_planned_dt_tm = dq8
     2 first_planned_tm_zn = i4
     2 first_planned_prsnl = f8
     2 first_initiated_dt_tm = dq8
     2 first_initiated_tm_zn = i4
     2 first_initiated_prsnl = f8
     2 loc_facility_cd = f8
     2 pathway_type_cd = f8
     2 pathway_cust_plan_id = f8
     2 description = vc
     2 type_mean = vc
 )
 RECORD pathway_phase_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD gen_lab_result_keys(
   1 qual[*]
     2 result_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD gen_lab_result_info(
   1 qual[*]
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 gen_lab_order_sk = f8
     2 gen_lab_result_sk = f8
     2 task_assay_sk = f8
     2 biological_category_ref = f8
     2 result_status_ref = f8
     2 long_text_id = f8
     2 result_value_formatted = vc
     2 codified_result_nomen = f8
     2 result_raw_value_txt = vc
     2 result_value_txt = vc
     2 result_value_dt_tm = dq8
     2 result_value_tm_zn = i4
     2 result_value_tm_vld_flg = i4
     2 result_value_numeric = vc
     2 result_raw_value_numeric = vc
     2 result_value_unit_ref = f8
     2 critical_ref = f8
     2 feasible_ref = f8
     2 linear_ref = f8
     2 normal_ref = f8
     2 qc_override_ref = f8
     2 review_ref = f8
     2 delta_ref = f8
     2 dilution_factor = vc
     2 interface_flg = vc
     2 interp_override_ind = vc
     2 qual_operator_flg = vc
     2 normal_alpha = vc
     2 normal_high = vc
     2 normal_low = vc
     2 perform_dt_tm = dq8
     2 perform_prsnl = f8
     2 perform_tm_zn = i4
     2 perform_tm_vld_flg = i4
     2 reference_range_factor_sk = f8
     2 repeat_seq = i4
     2 result_type_ref = f8
     2 perform_svc_res_dept_hier_sk = f8
     2 verified_dt_tm = dq8
     2 verified_tm_zn = i4
     2 verified_tm_vld_flg = i4
     2 verified_prsnl = f8
     2 reference_lab = vc
 )
 RECORD gen_lab_result_parent_keys(
   1 qual[*]
     2 order_id = f8
 )
 RECORD gen_lab_keys(
   1 qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD gen_lab_info(
   1 qual[*]
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 order_sk = f8
     2 gen_lab_order_sk = f8
     2 first_ctnr_drawn_dt_tm = dq8
     2 first_ctnr_drawn_tm_zn = i4
     2 first_ctnr_received_dt_tm = dq8
     2 first_ctnr_received_tm_zn = i4
     2 specimen_received_prsnl = vc
     2 first_ctnr_coll_method_ref = f8
     2 first_ctnr_type_ref = f8
     2 first_specimen_type_ref = f8
     2 frst_perf_svc_res_dept_hier_sk = f8
     2 first_cntr_units_ref = f8
     2 first_cntr_volume = vc
     2 cntr_first_in_lab_dt_tm = dq8
     2 cntr_first_in_lab_tm_zn = i4
     2 nbr_of_containers = i4
     2 nbr_of_specimens = i4
     2 first_creation_dt_tm = dq8
     2 first_creation_tm_zn = i4
     2 first_specimen_entr_prsnl = f8
     2 first_specimen_coll_prsnl = f8
     2 first_specimen_source_comment = vc
     2 collection_priority_ref = f8
     2 source_site_freetext_id = f8
     2 source_site_freetext = vc
     2 collected_ind = vc
     2 route_level_flg = vc
     2 first_specimen_site_ref = f8
 )
 RECORD long_text_ids(
   1 qual[*]
     2 long_text_id = f8
 )
 RECORD specimen_ids(
   1 qual[*]
     2 specimen_id = f8
 )
 RECORD container_ids(
   1 qual[*]
     2 container_id = f8
 )
 RECORD gen_lab_result_event_keys(
   1 qual[*]
     2 result_id = f8
     2 perform_result_id = f8
     2 event_sequence = f8
     2 order_id = f8
     2 loc_facility_cd = f8
     2 encntr_id = f8
     2 default_time_zone = f8
 )
 RECORD result_event_parent_keys(
   1 qual[*]
     2 order_id = f8
 )
 RECORD rx_claim_parent_keys(
   1 qual[*]
     2 dispense_hx_id = f8
 )
 RECORD pha_p_dp_parent_keys(
   1 qual[*]
     2 dispense_hx_id = f8
 )
 RECORD pha_ingr_keys(
   1 qual[*]
     2 order_id = f8
     2 action_sequence = i4
     2 comp_sequence = i4
 )
 RECORD pha_disp_keys(
   1 qual[*]
     2 dispense_hx_id = f8
 )
 RECORD pha_disp_parents(
   1 qual[*]
     2 parent_key = f8
 )
 RECORD pha_disp(
   1 qual[*]
     2 pharm_order_sk = f8
     2 pharm_dsp_hist_sk = f8
     2 action_seq = i4
     2 authorization_nbr = vc
     2 bill_qty = vc
     2 charge_dt_tm = dq8
     2 charge_ind = vc
     2 charge_tm_zn = i4
     2 copay_amt = vc
     2 credit_pharm_dispense_hist_sk = f8
     2 discount_amt = vc
     2 dispense_dt_tm = dq8
     2 dispense_fee_amt = vc
     2 dispense_prsnl = f8
     2 dispense_tm_zn = i4
     2 dispense_event_type_ref = f8
     2 dispense_loc = f8
     2 dispense_priority_ref = f8
     2 dispense_priority_dt_tm = dq8
     2 dispense_priority_tm_zn = i4
     2 dispense_qty = vc
     2 dispense_qty_unit_ref = f8
     2 dispense_svc_res_dept_hier_sk = f8
     2 dispense_doses = vc
     2 early_refill_reason_ref = f8
     2 event_sk = f8
     2 dispense_event_total_price_amt = vc
     2 refill_extra_reason_ref = f8
     2 fill_list_hist_sk = f8
     2 fill_list_nbr = vc
     2 first_dose_dt_tm = dq8
     2 first_dose_tm_zn = i4
     2 first_iv_seq = vc
     2 future_charge_ind = vc
     2 dispense_hlthpln = f8
     2 incentive_amt = vc
     2 late_refill_reason_ref = f8
     2 next_dispense_dt_tm = dq8
     2 next_dispense_tm_zn = i4
     2 orig_action_seq = vc
     2 orig_action_dt_tm = dq8
     2 orig_action_tm_zn = i4
     2 orig_action_com_type_ref = vc
     2 orig_action_prsnl = vc
     2 partial_refill_reason_ref = f8
     2 pharm_type_ref = f8
     2 prev_dispense_dt_tm = dq8
     2 prev_dispense_tm_zn = i4
     2 remaining_qty = vc
     2 reason_ref = f8
     2 remaining_refill_qty = vc
     2 reimbursement_amt = vc
     2 residual_doses_qty = vc
     2 residual_price_amt = vc
     2 dispense_reverse_ind = vc
     2 dispense_event_prsnl = f8
     2 sale_tax_amt = vc
     2 track_nbr = vc
     2 usual_customary_price_amt = vc
     2 witness_prsnl = f8
 )
 RECORD ord_product_keys(
   1 qual[*]
     2 order_id = f8
     2 action_sequence = f8
     2 medication_prod_sk = vc
 )
 RECORD ord_product_parents(
   1 qual[*]
     2 order_id = f8
     2 action_sequence = f8
     2 ingred_sequence = f8
 )
 RECORD pha_ord_keys(
   1 qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD pha_ord(
   1 qual[*]
     2 order_sk = f8
     2 pharm_order_sk = f8
     2 iv_ind = vc
     2 multiple_ingredient_ind = vc
     2 med_order_type_ref = f8
     2 rx_mask = vc
     2 rx_diluent_ind = c1
     2 rx_additive_ind = c1
     2 rx_med_ind = c1
     2 rx_tpn_ind = c1
     2 rx_sliding_scale_ind = c1
     2 rx_tapering_dose_ind = c1
     2 rx_pca_ind = c1
     2 infuse_over = vc
     2 infuse_unit_ref = vc
     2 duration = vc
     2 duration_unit_ref = vc
     2 take_home_med = vc
     2 take_home_med_qty = vc
     2 sample_given_ind = vc
     2 sample_given_qty = vc
     2 sample_given_qty_unit_ref = vc
     2 total_volume = vc
     2 route_type_ref = vc
     2 claim_flg = vc
     2 coordinate_of_benefit_ind = vc
     2 dispense_as_written_ref = f8
     2 days_supply = vc
     2 dispense_category_ref = f8
     2 expire_dt_tm = dq8
     2 expire_tm_zn = i4
     2 fill_nbr = vc
     2 floorstock_ind = vc
     2 floorstock_override_ind = vc
     2 frequency_sk = f8
     2 future_loc = f8
     2 order_hlthpln = f8
     2 ignore_ind = vc
     2 iv_set_cnt = vc
     2 last_clin_rev_act_seq = vc
     2 last_clin_rev_act_dt_tm = dq8
     2 last_clin_rev_act_tm_zn = i4
     2 last_clin_rev_com_type_ref = f8
     2 last_clin_rev_prsnl = f8
     2 last_clin_rev_spvs_prsnl = f8
     2 last_clin_review_ingr_seq = vc
     2 last_fill_action_seq = vc
     2 last_fill_action_dt_tm = dq8
     2 last_fill_action_tm_zn = i4
     2 last_fill_action_com_type_ref = f8
     2 last_fill_action_prsnl = f8
     2 last_fill_spvs_prsnl = f8
     2 last_refill_dt_tm = dq8
     2 last_refill_tm_zn = i4
     2 next_iv_seq = vc
     2 order_dispense_ind = vc
     2 order_type_flg = vc
     2 parent_order_sk = f8
     2 par_dose = vc
     2 pharm_type_ref = f8
     2 remaining_qty = vc
     2 remaining_refill_cnt = vc
     2 replace_interval = vc
     2 replace_interval_unit_ref = f8
     2 research_account_sk = f8
     2 total_dispense_doses = vc
     2 total_rx_qty = vc
     2 rx_transfer_cnt = vc
     2 unverified_action_type_ref = f8
     2 unverified_comm_type_ref = f8
     2 unverified_route_ref = f8
     2 unverified_rx_ord_priority_ref = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 order_dispense_loc = vc
 )
 RECORD case_cart_pick_list_keys(
   1 qual[*]
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 surg_case_id = f8
     2 case_cart_pick_list_id = f8
 )
 RECORD periop_doc_ids(
   1 qual[*]
     2 periop_doc_id = f8
 )
 RECORD case_cart_pick_list_info(
   1 qual[*]
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 surgical_case_sk = f8
     2 case_cart_pick_lst_sk = f8
     2 document_type_ref = f8
     2 doc_terminated_reason_ref = f8
     2 doc_terminated_dt_tm = dq8
     2 doc_terminated_tm_zn = i4
     2 doc_terminated_tm_vld_flg = i4
     2 doc_terminated_by_prsnl = f8
     2 case_cart_finalized_dt_tm = dq8
     2 case_cart_finalized_tm_zn = i4
     2 case_cart_finalized_tm_vld_flg = i4
     2 case_cart_verfd_dt_tm = dq8
     2 case_cart_verfd_tm_zn = i4
     2 case_cart_verfd_tm_vld_flg = i4
     2 case_cart_verfd_by_prsnl = f8
     2 surgical_area_ref = f8
     2 pick_list_item = f8
     2 ft_item_desc = vc
     2 fill_loc = f8
     2 return_loc = f8
     2 wasted_reason_ref = f8
     2 fill_qty = vc
     2 hold_qty = vc
     2 open_qty = vc
     2 used_qty = vc
     2 requested_qty = vc
     2 return_qty = vc
     2 wasted_qty = vc
     2 item_type_flg = vc
     2 parent_case_cart_pick_lst_sk = f8
     2 charge_duration = vc
     2 charge_unit_qty = vc
     2 charge_qty = vc
     2 cost_type_ref = f8
     2 avg_cost_amt = vc
     2 last_cost_amt = vc
     2 active_ind = vc
 )
 RECORD implant_log_keys(
   1 qual[*]
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 surg_case_id = f8
     2 implant_log_st_id = f8
 )
 RECORD implant_log_periop_doc_ids(
   1 qual[*]
     2 periop_doc_id = f8
 )
 RECORD implant_log_info(
   1 qual[*]
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 surgical_case_sk = f8
     2 implant_log_sk = f8
     2 perioperative_doc_type_ref = f8
     2 doc_terminated_reason_ref = f8
     2 doc_terminated_dt_tm = dq8
     2 doc_terminated_tm_zn = i4
     2 doc_terminated_by_prsnl = f8
     2 segment_ref = f8
     2 cultured_ind = vc
     2 expiration_dt_tm = dq8
     2 expiration_tm_zn = i4
     2 implanted_by_prsnl = f8
     2 implant_item = f8
     2 ft_implant = vc
     2 implanted_site_txt = vc
     2 implanted_size_txt = vc
     2 implant_batch_nbr = vc
     2 implant_catalog_nbr = vc
     2 ecri_device_code = vc
     2 implant_lot_nbr = vc
     2 implant_serial_nbr = vc
     2 implant_manufacturer_txt = vc
     2 implant_manufacturer_ecri_code = vc
     2 implant_model_nbr = vc
 )
 RECORD pref_card_keys(
   1 qual[*]
     2 surg_case_id = f8
     2 surg_case_proc_id = f8
     2 surg_case_proc_doc_id = f8
 )
 RECORD surg_case_proc_ids(
   1 qual[*]
     2 surg_case_proc_id = f8
 )
 RECORD scheduled_pick_list_keys(
   1 qual[*]
     2 surg_case_id = f8
     2 sched_case_pick_list_id = f8
 )
 RECORD pref_card_item_keys(
   1 qual[*]
     2 pref_card_pick_list_id = f8
 )
 RECORD pref_card_item_info(
   1 qual[*]
     2 pref_card_sk = f8
     2 pref_card_item_sk = f8
     2 catalog_ref = f8
     2 associated_prsnl = f8
     2 surgical_specialty_ref = f8
     2 surgical_area_ref = f8
     2 document_type_ref = f8
     2 hist_avg_duration = vc
     2 total_case_nbr = vc
     2 override_hist_avg_duration = vc
     2 override_total_case_nbr = vc
     2 override_lookback_nbr = vc
     2 recent_avg_case_nbr = vc
     2 recent_avg_duration = vc
     2 request_open_qty = vc
     2 request_hold_qty = vc
     2 src_active_ind = c1
     2 item_sk = f8
 )
 RECORD pathway_order(
   1 qual[*]
     2 pathway_phase_sk = f8
     2 pathway_order_sk = f8
     2 order_sk = f8
     2 pathway_order_ref_sk = f8
     2 activated_dt_tm = dq8
     2 activated_tm_zn = i4
     2 activated_ind = vc
     2 activated_prsnl = f8
     2 cross_phase_group_ind = vc
     2 included_dt_tm = dq8
     2 included_tm_zn = i4
     2 included_ind = vc
     2 last_action_seq = vc
     2 last_action_dt_tm = dq8
     2 last_action_tm_zn = i4
     2 linked_to_time_frame_ind = vc
     2 order_sentence_sk = f8
     2 pathway_component_seq = vc
     2 added_to_plan_ind = i2
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD pathway_order_keys(
   1 qual[*]
     2 pathway_order_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD pathway_order_parent_keys(
   1 qual[*]
     2 pathway_id = f8
 )
 RECORD suscept_rslt(
   1 qual[*]
     2 micro_task_sk = vc
     2 mic_task_log = f8
     2 detail_sus_seq = i4
     2 micro_seq_nbr = i4
     2 suscept_results_sk = vc
     2 detail_test_type_ref = f8
     2 panel_ref = f8
     2 procedure_status_ref = f8
     2 antibiotic_medication_ref = f8
     2 result_status_ref = f8
     2 result_type_flg = vc
     2 interpretation_result_ref = f8
     2 alpha_numeric_result_ref = f8
     2 numeric_result = f8
     2 result_txt = vc
     2 result_unit_ref = f8
     2 abnormal_response_ind = vc
     2 chartable_ind = vc
     2 chartable_ind = vc
     2 panel_complete_required_ind = vc
     2 performed_dt_tm = dq8
     2 performed_tm_zn = i4
     2 verified_dt_tm = dq8
     2 verified_tm_zn = i4
     2 canceled_dt_tm = dq8
     2 canceled_tm_zn = i4
     2 pending_dt_tm = dq8
     2 pending_tm_zn = i4
     2 corrected_dt_tm = dq8
     2 corrected_tm_zn = i4
     2 event_sk = f8
     2 active_ind = i4
     2 loc_facility_cd = f8
     2 encntr_id = f8
     2 order_id = f8
     2 event_id = f8
 )
 RECORD suscept_rslt_keys(
   1 qual[*]
     2 mic_task_log = f8
     2 event_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 order_id = f8
     2 detail_sus_seq = i4
     2 micro_seq_nbr = i4
 )
 RECORD suscept_rslt_keys2(
   1 qual[*]
     2 mic_task_log = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 detail_sus_seq = i4
     2 event_id = f8
     2 micro_seq_nbr = i4
 )
 RECORD micro_suscept_rslt_parent_keys(
   1 qual[*]
     2 mic_task_log = f8
 )
 RECORD ce_suscept_rslt_parent_keys(
   1 qual[*]
     2 order_sk = f8
 )
 RECORD edw_all_surgical_case_keys(
   1 qual[*]
     2 surgical_case_id = f8
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 encounter_nk = vc
 )
 RECORD edw_all_surgical_case_proc_keys(
   1 qual[*]
     2 surgical_case_proc_id = f8
     2 surgical_case_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD rad_order_keys(
   1 qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD rad_order_info(
   1 qual[*]
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 order_sk = f8
     2 rad_order_sk = f8
     2 accession_add_on_ind = f8
     2 comment_txt = vc
     2 exam_completed_dt_tm = dq8
     2 exam_completed_tm_zn = i4
     2 exam_status_ref = f8
     2 group_event_sk = f8
     2 order_loc = f8
     2 packet_routing_ref = f8
     2 parent_order_sk = f8
     2 pull_list_request_dt_tm = dq8
     2 pull_list_request_tm_zn = i4
     2 pull_list_print_dt_tm = dq8
     2 pull_list_print_tm_zn = i4
     2 reason_for_exam = vc
     2 removed_by_prsnl = f8
     2 removed_ref = f8
     2 removed_dt_tm = dq8
     2 removed_tm_zn = i4
     2 replaced_order_sk = f8
     2 report_status_ref = f8
     2 restored_ind = vc
     2 exam_start_dt_tm = dq8
     2 exam_start_tm_zn = i4
     2 vetting_dt_tm = dq8
     2 vetting_tm_zn = i4
     2 vetting_prsnl = f8
     2 vetting_status_flg = f8
     2 request_dt_tm = dq8
     2 request_tm_zn = i4
     2 cancelled_dt_tm = dq8
     2 cancelled_tm_zn = i4
 )
 RECORD sch_appt_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD sch_appt_keys(
   1 qual[*]
     2 sch_event_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 patient_appt_ind = i2
 )
 RECORD sch_appt_keys_patient(
   1 qual[*]
     2 sch_event_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 patient_appt_ind = i2
 )
 RECORD sch_appt_keys_non_patient(
   1 qual[*]
     2 sch_event_id = f8
     2 loc_facility_cd = f8
     2 encntr_id = f8
     2 patient_appt_ind = i2
 )
 RECORD sch_appt(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 person_sk = f8
     2 sch_appointment_sk = f8
     2 requested_reason_txt = vc
     2 appt_type_synonym_ref = f8
     2 appt_type_synonym_txt = vc
     2 appt_type_dtl_sk = f8
     2 group_desc = vc
     2 group_type_flg = vc
     2 group_capacity_qty = vc
     2 group_closed_ind = vc
     2 group_sched_person_qty = vc
     2 group_shared_ind = vc
     2 first_group_ses_beg_dt_tm = dq8
     2 first_group_ses_beg_tm_zn = i4
     2 last_group_ses_end_dt_tm = dq8
     2 last_group_ses_end_tm_zn = i4
     2 offset_sch_appointment_sk = f8
     2 offset_from_type_ref = f8
     2 offset_type_ref = f8
     2 offset_beg_appt_qty = vc
     2 offset_beg_appt_units_ref = f8
     2 offset_end_appt_qty = vc
     2 offset_end_appt_units_ref = f8
     2 protocol_sch_appointment_sk = f8
     2 protocol_seq = vc
     2 protocol_type_flg = vc
     2 recur_sch_appointment_sk = f8
     2 recur_seq = i4
     2 recur_type_flg = i4
     2 referred_dt_tm = dq8
     2 referred_tm_zn = i4
     2 sch_appointment_state_ref = f8
     2 scheduled_loc = f8
     2 scheduled_loc_txt = vc
     2 scheduled_location_type_ref = f8
     2 active_ind = i2
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 nhs_providing_org = f8
     2 schedule_seq = f8
     2 first_chart_access_dt_tm = dq8
     2 first_chart_access_tz = i4
     2 scheduled_loc_org = f8
     2 patient_appt_ind = i2
     2 sch_appt_sk = f8
     2 active_stat_dt_tm = dq8
     2 active_stat_tm_zn = i4
     2 beg_dt_tm = dq8
     2 beg_tm_zn = i4
 )
 RECORD outcome_ref(
   1 qual[*]
     2 outcome_id = f8
     2 apc_id = f8
     2 outcome_ref_sk = vc
     2 pathway_component_seq = vc
     2 description = vc
     2 outcome_type_ref = f8
     2 expand_qty = vc
     2 expand_unit_ref = f8
     2 offset_qty = vc
     2 offset_unit_ref = vc
     2 target_type_ref = f8
     2 clinical_category_ref = f8
     2 clinical_sub_category_ref = f8
     2 intended_duration_qty = vc
     2 intended_duration_unit_ref = f8
     2 linked_to_time_frame_ind = vc
     2 chemo_related_ind = vc
     2 required_ind = vc
     2 event_ref = f8
     2 expectation = vc
     2 result_type_ref = f8
     2 outcome_catalog_id = f8
     2 task_assay_sk = f8
     2 active_dt_tm = dq8
     2 active_tm_zn = f8
     2 outcome_ref_source_flg = i4
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 src_active_ind = c1
 )
 RECORD outcome_ref_keys(
   1 qual[*]
     2 outcome_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD outcome_reference_keys(
   1 qual[*]
     2 apc_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD outcome_ref_parent_keys(
   1 qual[*]
     2 pathway_id = f8
 )
 RECORD outcome(
   1 qual[*]
     2 pathway_phase_sk = f8
     2 outcome_sk = f8
     2 outcome_ref_sk = vc
     2 end_dt_tm = dq8
     2 end_tm_zn = i4
     2 expand_qty = i4
     2 expand_unit_ref = f8
     2 result_type_ref = f8
     2 activated_dt_tm = dq8
     2 activated_tm_zn = i4
     2 activated_ind = vc
     2 activated_prsnl = i4
     2 cross_phase_group_ind = vc
     2 included_dt_tm = dq8
     2 included_tm_zn = i4
     2 included_ind = vc
     2 last_action_seq = vc
     2 last_action_dt_tm = dq8
     2 last_action_tm_zn = i4
     2 linked_to_time_frame_ind = vc
     2 pathway_component_seq = i4
     2 added_to_plan_ind = i4
     2 duration_qty = i4
     2 duration_unit_ref = f8
     2 outcome_source_flg = i4
     2 expectation = vc
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD outcome_keys(
   1 qual[*]
     2 outcome_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD outcome_parent_keys(
   1 qual[*]
     2 pathway_id = f8
 )
 RECORD outcome_evnt(
   1 outcomes[*]
     2 outcome_activity_id = f8
     2 outcome_sk = f8
     2 event_sk = f8
     2 result_value = vc
     2 outcome_met_ind = i4
     2 result_unit_ref = f8
     2 performed_dt_tm = dq8
     2 performed_tm_zn = i4
     2 result_status_ref = f8
     2 outcome_event_sk = vc
     2 reason_ref = f8
     2 result_ref = f8
     2 variance_action_ref = f8
     2 variance_charted_dt_tm = dq8
     2 variance_charted_tm_zn = i4
     2 variance_charted_prnsl = i4
     2 variance_uncharted_dt_tm = dq8
     2 variance_uncharted_tm_zn = i4
     2 variance_uncharted_prnsl = i4
     2 variance_type_ref = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD outcome_evnt_keys(
   1 qual[*]
     2 outcome_activity_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD outcome_evnt_keys_subset(
   1 qual[*]
     2 outcome_activity_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD outcome_evnt_parent_keys(
   1 qual[*]
     2 act_pw_comp_id = f8
 )
 FREE RECORD temp_outcome_evnt
 RECORD temp_outcome_evnt(
   1 outcomes[*]
     2 outcomeactid = f8
     2 outcome_sk = f8
     2 results[*]
       3 metind = i4
       3 event_id = f8
       3 event_sk = vc
       3 resultval = vc
       3 resultunitscd = f8
       3 resultstatuscd = f8
       3 performdttm = dq8
   1 variances[*]
     2 event_id = f8
     2 event_sk = vc
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 variance_type_ref = f8
     2 action_cd = f8
     2 reason_cd = f8
     2 chart_dt_tm = dq8
     2 chart_prsnl_id = f8
     2 unchart_dt_tm = dq8
     2 unchart_prsnl_id = f8
     2 result_ref = f8
     2 variance_action_ref = f8
 )
 FREE RECORD request
 RECORD request(
   1 personid = f8
   1 outcomeidlist[*]
     2 outcomeactid = f8
     2 startdttm = dq8
     2 enddttm = dq8
   1 loadactivevarianceind = i2
   1 loadinactivevarianceind = i2
   1 loadinactiveresultsind = i2
   1 loadlatestvarianceind = i2
 )
 FREE SET request_holder
 RECORD request_holder(
   1 personid[*]
     2 personid = f8
     2 outcomeidlist[*]
       3 outcomeactid = f8
       3 startdttm = dq8
       3 enddttm = dq8
     2 loadactivevarianceind = i2
     2 loadinactivevarianceind = i2
     2 loadinactiveresultsind = i2
     2 loadlatestvarianceind = i2
 )
 FREE RECORD reply
 RECORD reply(
   1 outcomes[*]
     2 outcomeactid = f8
     2 outcomecatid = f8
     2 description = vc
     2 expectation = f8
     2 outcomestatuscd = f8
     2 outcometypecd = f8
     2 outcomeclasscd = f8
     2 encntrid = f8
     2 startdttm = dq8
     2 enddttm = dq8
     2 lastmetind = i4
     2 lastresultdttm = dq8
     2 metnomenclatureid = f8
     2 operandmean = vc
     2 singleselectind = i4
     2 hideexpectationind = i4
     2 results[*]
       3 metind = i4
       3 clineventid = i4
       3 eventid = f8
       3 eventenddtm = dq8
       3 resultval = vc
       3 resultunitscd = f8
       3 resultunitsdisp = vc
       3 resultstatuscd = f8
       3 performdttm = dq8
       3 performprsnlname = vc
       3 updtcnt = i4
       3 entrymodecd = f8
       3 accessionnbr = vc
     2 criteria[*]
       3 outcomecriteriaid = f8
       3 operatorcd = f8
       3 resultvalue = f8
       3 resultunitcd = f8
       3 nomenclatureid = f8
       3 sequence = i4
   1 variances[*]
     2 variance_reltn_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 pathway_id = f8
     2 event_id = f8
     2 variance_type_cd = f8
     2 variance_type_disp = vc
     2 variance_type_mean = vc
     2 action_cd = f8
     2 action_disp = vc
     2 action_mean = vc
     2 action_text_id = f8
     2 action_text = vc
     2 action_text_updt_cnt = i4
     2 reason_cd = f8
     2 reason_disp = vc
     2 reason_mean = vc
     2 reason_text_id = f8
     2 reason_text = vc
     2 reason_text_updt_cnt = i4
     2 variance_updt_cnt = i4
     2 active_ind = i4
     2 note_text_id = f8
     2 note_text = vc
     2 note_text_updt_cnt = i4
     2 chart_prsnl_name = vc
     2 chart_dt_tm = dq8
     2 chart_prsnl_id = f8
     2 unchart_prsnl_name = vc
     2 unchart_dt_tm = dq8
     2 unchart_prsnl_id = f8
   1 status_data[*]
     2 status = vc
     2 subeventstatus[*]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD sch_cal_act_apply_id(
   1 qual[*]
     2 apply_slot_id = f8
 )
 RECORD sch_cal_act_id(
   1 qual[*]
     2 sch_action_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD sch_cal_act(
   1 qual[*]
     2 parent_id = f8
     2 sch_action_id = f8
     2 action_dt_tm = dq8
     2 action_tm_zn = i4
     2 perform_dt_tm = dq8
     2 perform_tm_zn = i4
     2 sch_action_cd = f8
     2 sch_reason_cd = f8
     2 active_ind = i2
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD sch_apt_act_id(
   1 qual[*]
     2 sch_event_id = f8
     2 sch_action_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD sch_apt_act(
   1 qual[*]
     2 sch_event_id = f8
     2 sch_action_id = f8
     2 action_dt_tm = dq8
     2 action_tm_zn = i4
     2 perform_dt_tm = dq8
     2 perform_tm_zn = i4
     2 sch_action_cd = f8
     2 sch_reason_cd = f8
     2 ver_status_cd = f8
     2 eso_action_cd = f8
     2 hipaa_action_cd = f8
     2 resource_cd = f8
     2 orig_action_id = f8
     2 req_action_cd = f8
     2 product_cd = f8
     2 latest_req_start_dt_tm = dq8
     2 latest_req_start_tm_zn = i4
     2 earliest_req_start_dt_tm = dq8
     2 earliest_req_start_tm_zn = i4
     2 active_ind = i2
     2 action_prsnl_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 schedule_id = f8
 )
 RECORD sch_apt_det_id(
   1 qual[*]
     2 sch_event_id = f8
     2 sch_action_id = f8
     2 oe_field_id = f8
     2 seq_nbr = i4
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 patient_appt_ind = i2
 )
 RECORD sch_apt_det_patient_id(
   1 qual[*]
     2 sch_event_id = f8
     2 sch_action_id = f8
     2 oe_field_id = f8
     2 seq_nbr = i4
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 patient_appt_ind = i2
 )
 RECORD sch_apt_det_non_patient_id(
   1 qual[*]
     2 sch_event_id = f8
     2 sch_action_id = f8
     2 oe_field_id = f8
     2 seq_nbr = i4
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 patient_appt_ind = i2
 )
 RECORD sch_apt_det(
   1 qual[*]
     2 sch_event_id = f8
     2 sch_action_id = f8
     2 oe_field_id = f8
     2 oe_field_meaning = vc
     2 seq_nbr = i4
     2 oe_field_value_ref = f8
     2 codeset = i4
     2 oe_field_value_nomen = f8
     2 oe_field_value_prsnl = f8
     2 oe_field_display_value_txt = vc
     2 oe_field_display_value_numeric = vc
     2 oe_field_dt_tm_value = dq8
     2 oe_field_tm_zn = i4
     2 oe_field_display_value_raw = vc
     2 oe_field_value_raw = f8
     2 active_ind = i2
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tm_tz = i4
     2 end_effective_dt_tm = dq8
     2 end_effective_tm_tz = i4
     2 patient_appt_ind = i2
 )
 RECORD sch_cal_keys(
   1 qual[*]
     2 sch_appt_id = f8
     2 sch_event_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD sch_cal_apply_slot_id(
   1 qual[*]
     2 apply_slot_id = f8
 )
 RECORD sch_cal_appt_keys(
   1 qual[*]
     2 sch_appt_id = f8
 )
 RECORD sch_cal(
   1 qual[*]
     2 sch_calendar_sk = f8
     2 sch_appointment_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 active_ind = vc
     2 activity_type_ref = f8
     2 bookings_prsnl = f8
     2 block_instance_sk = f8
     2 apply_slot_sk = f8
     2 slot_begin_dt_tm = dq8
     2 slot_begin_tm_zn = i4
     2 booking_slot_begin_dt_tm = dq8
     2 booking_slot_begin_tm_zn = i4
     2 book_beg_effective_dt_tm = dq8
     2 book_beg_effective_tm_zn = i4
     2 cleanup_duration_qty = vc
     2 contiguous_ind = i2
     2 calendar_description = vc
     2 duration_qty = i4
     2 slot_end_dt_tm = dq8
     2 slot_end_tm_zn = i4
     2 booking_slot_end_dt_tm = dq8
     2 booking_slot_end_tm_zn = i4
     2 group_sch_appointment_sk = f8
     2 holiday_weekend_flg = vc
     2 original_slot_begin_dt_tm = dq8
     2 original_slot_begin_tm_zn = i4
     2 original_slot_end_dt_tm = dq8
     2 original_slot_end_tm_zn = i4
     2 primary_role_ind = i2
     2 book_slot_release_dt_tm = dq8
     2 book_slot_release_tm_zn = i4
     2 resource_dtl_sk = f8
     2 role_description = vc
     2 role_seq = i4
     2 role_ref = f8
     2 current_appointment_state_ref = f8
     2 schedule_seq = i4
     2 service_resource_ref = f8
     2 setup_duration_qty = vc
     2 current_slot_state_ref = f8
     2 time_type_flg = i2
     2 calendar_slot_prsnl = vc
     2 current_visible_ind = i2
     2 booked_correctly_ind = i2
     2 def_slot_id = i4
     2 slot_type_id = i4
     2 schedule_sk = f8
     2 role_meaning = vc
     2 slot_meaning = vc
     2 slot_state_meaning = vc
     2 encounter_nk = vc
     2 appt_location_ref = f8
 )
 RECORD sch_cal_apply_slot_parent(
   1 qual[*]
     2 apply_slot_id = f8
 )
 RECORD sch_cal_def_id(
   1 qual[*]
     2 apply_def_id = f8
     2 appt_def_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD sch_cal_def(
   1 qual[*]
     2 appt_def_id = f8
     2 apply_def_id = f8
     2 slot_type_id_field = vc
     2 slot_type_id = f8
     2 description = vc
     2 slot_mnemonic = vc
     2 beg_dt_tm = dq8
     2 beg_dt_tm_zn = i4
     2 end_dt_tm = dq8
     2 end_dt_tm_zn = i4
     2 duration = i4
     2 interval = vc
     2 vis_beg_dt_tm = dq8
     2 vis_beg_dt_tm_zn = i4
     2 vis_beg_units = i4
     2 vis_beg_units_cd = f8
     2 vis_end_dt_tm = dq8
     2 vis_end_dt_tm_zn = i4
     2 vis_end_units = i4
     2 vis_end_units_cd = f8
     2 def_state_cd = f8
     2 active_ind = vc
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD doc_response(
   1 cnt = i4
   1 qual[*]
     2 form_event_id = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 doc_activity_sk = f8
     2 form_person_sk = f8
     2 form_status_ref = f8
     2 form_dt_tm = dq8
     2 form_tm_zn = i4
     2 form_version_dt_tm = dq8
     2 form_version_tm_zn = i4
     2 first_documented_dt_tm = dq8
     2 first_documented_tm_zn = i4
     2 last_documented_dt_tm = dq8
     2 last_documented_tm_zn = i4
     2 completion_flg = i4
     2 component_ref = f8
     2 active_ind = i2
     2 res_cnt = i4
     2 loc_facility_cd = f8
     2 dcp_form_instance_id = f8
     2 dcp_section_instance_id = f8
     2 ce1_event_id = f8
     2 task_activity_sk = f8
     2 grid_component_cnt = i4
     2 grid_components[*]
       3 event_id = f8
       3 ce2_event_cd = f8
       3 ce2_collating_seq = vc
     2 power_grid_component_cnt = i4
     2 power_grid_components[*]
       3 event_id = f8
       3 ce2_event_cd = f8
       3 ce3_event_cd = f8
       3 parent_event_id = f8
     2 results[*]
       3 event_class_cd = f8
       3 event_sk = f8
       3 ce2_event_id = f8
       3 ce3_event_id = f8
       3 ce4_event_id = f8
       3 ce2_event_cd = f8
       3 ce3_event_cd = f8
       3 ce4_event_cd = f8
       3 collating_seq_3 = vc
       3 doc_response_sk = vc
       3 doc_response_seq = vc
       3 doc_input_sk = vc
       3 date_time_response_dt_tm = dq8
       3 date_time_response_tm_zn = i4
       3 string_response = vc
       3 numeric_response = vc
       3 alpha_response_sk = vc
       3 response_value = vc
       3 set_ind = i2
       3 parent_event_sk = f8
       3 section_event_sk = f8
       3 grid_event_sk = f8
       3 column_event_sk = f8
       3 row_event_sk = f8
       3 active_ind = i2
       3 result_ref = f8
 )
 RECORD doc_response_keys(
   1 qual[*]
     2 form_event_id = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 doc_activity_sk = f8
     2 form_person_sk = f8
     2 form_status_ref = f8
     2 form_dt_tm = dq8
     2 form_tm_zn = i4
     2 form_version_dt_tm = dq8
     2 form_version_tm_zn = i4
     2 first_documented_dt_tm = dq8
     2 first_documented_tm_zn = i4
     2 last_documented_dt_tm = dq8
     2 last_documented_tm_zn = i4
     2 completion_flg = i4
     2 component_ref = f8
     2 active_ind = i2
     2 res_cnt = i4
     2 loc_facility_cd = f8
     2 dcp_form_instance_id = f8
     2 dcp_section_instance_id = f8
     2 ce1_event_id = f8
 )
 RECORD doc_response_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD tracking_prsnl_ref_keys(
   1 qual[*]
     2 tracking_prsnl_ref_id = f8
 )
 RECORD tracking_item_keys(
   1 qual[*]
     2 tracking_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 time_zone = i4
 )
 RECORD pat_ed_doc_act_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD pat_ed_doc_act_keys(
   1 qual[*]
     2 pat_ed_doc_activity_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 time_zone = i4
     2 encntr_nk = vc
 )
 RECORD tracking_prearrival_keys(
   1 qual[*]
     2 tracking_prearrival_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 time_zone = i4
 )
 RECORD tracking_evnt_keys(
   1 qual[*]
     2 tracking_event_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 time_zone = i4
 )
 RECORD enc_followup_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD enc_followup_keys(
   1 qual[*]
     2 pat_ed_doc_followup_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 time_zone = i4
     2 encntr_nk = vc
 )
 RECORD trk_chkn(
   1 qual[*]
     2 tracking_item_sk = f8
     2 tracking_checkin_sk = f8
     2 tracking_group_ref = f8
     2 tracking_event_type_ref = f8
     2 checkin_dt_tm = dq8
     2 checkin_tm_zn = i4
     2 checkin_by_prsnl = f8
     2 checkout_dt_tm = dq8
     2 checkout_tm_zn = i4
     2 checkout_by_prsnl = f8
     2 trauma_ind = vc
     2 arrive_acuity_track_detail_sk = f8
     2 depart_acuity_track_detail_sk = f8
     2 primary_doc_prsnl = f8
     2 secondary_doc_prsnl = f8
     2 primary_nurse_prsnl = f8
     2 secondary_nurse_prsnl = f8
     2 speciality_track_detail_sk = f8
     2 team_track_detail_sk = f8
     2 rank_seq = vc
     2 pat_ed_acknowledge_ind = vc
     2 pat_ed_acknowledge_prsnl = f8
     2 reactive_prsnl = f8
     2 reactivate_dt_tm = dq8
     2 reactivate_tm_zn = i4
     2 reg_status_track_event_sk = f8
     2 family_present_ref = f8
     2 document_status_ref = f8
     2 checkout_disposition_ref = f8
 )
 RECORD trk_chkn_keys(
   1 qual[*]
     2 tracking_checkin_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD trk_chkn_parent_keys(
   1 qual[*]
     2 tracking_id = f8
 )
 RECORD trk_loc(
   1 qual[*]
     2 tracking_item_sk = f8
     2 tracking_locator_sk = f8
     2 tracking_loc = f8
     2 tracking_service_resource_ref = f8
     2 tracking_location_ref = f8
     2 arrive_prsnl = f8
     2 arrive_dt_tm = dq8
     2 arrive_tm_zn = i4
     2 depart_prsnl = f8
     2 depart_dt_tm = dq8
     2 depart_tm_zn = i4
     2 availability_ind = vc
     2 rank_seq = vc
     2 scheduled_dt_tm = dq8
     2 scheduled_tm_zn = i4
     2 acuity_level_track_detail_sk = i4
     2 tracking_reason_ref = f8
     2 tracking_reason_comment_txt = vc
     2 updt_id = i4
     2 loc_facility_cd = f8
     2 encounter_sk = f8
 )
 RECORD trk_loc_keys(
   1 qual[*]
     2 tracking_locator_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD trk_loc_parent_keys(
   1 qual[*]
     2 tracking_id = f8
 )
 RECORD trk_evnt(
   1 qual[*]
     2 tracking_item_sk = f8
     2 tracking_event_sk = f8
     2 tracking_group_ref = f8
     2 track_event_sk = f8
     2 requested_prsnl = f8
     2 requested_dt_tm = dq8
     2 requested_tm_zn = i4
     2 onset_prsnl = f8
     2 onset_dt_tm = dq8
     2 onset_tm_zn = i4
     2 in_lab_prsnl = f8
     2 in_lab_dt_tm = dq8
     2 in_lab_tm_zn = i4
     2 complete_prsnl = f8
     2 complete_dt_tm = dq8
     2 complete_tm_zn = i4
     2 collected_prsnl = f8
     2 collected_dt_tm = dq8
     2 collected_tm_zn = i4
     2 complete_on_exit_ind = vc
     2 status_ref = f8
     2 clinical_event_ref = f8
     2 complete_not_rev_prsnl = f8
     2 complete_not_rev_dt_tm = dq8
     2 complete_not_rev_tm_zn = i4
     2 updt_id = f8
 )
 RECORD trk_evnt_keys(
   1 qual[*]
     2 tracking_event_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD trk_evnt_parent_keys(
   1 qual[*]
     2 tracking_id = f8
 )
 RECORD trk_item(
   1 qual[*]
     2 encounter_sk = f8
     2 encounter_nk = vc
     2 tracking_item_sk = f8
     2 person_sk = f8
     2 inventory_item = f8
     2 tracking_prearrive_sk = f8
     2 sch_appointment_sk = f8
     2 surgical_case_sk = f8
     2 tracking_item_table_name = vc
     2 tracking_item_table_sk = f8
     2 tracking_prsnl = f8
     2 tracking_type_flg = vc
     2 start_dt_tm = dq8
     2 start_tm_zn = i4
     2 started_by_prsnl = f8
     2 end_dt_tm = dq8
     2 end_tm_zn = i4
     2 ended_by_prsnl = f8
     2 status_flg = vc
     2 current_tracking_locator_sk = f8
     2 base_location_ref = f8
     2 base_loc_dt_tm = dq8
     2 base_loc_tm_zn = i4
     2 loc_facility_cd = f8
 )
 RECORD trk_item_keys(
   1 qual[*]
     2 tracking_item_sk = f8
     2 encounter_nk = vc
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD trk_item_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
 )
 RECORD trk_prearrive(
   1 qual[*]
     2 encounter_sk = f8
     2 encounter_nk = vc
     2 tracking_prearrive_sk = f8
     2 person_sk = f8
     2 first_name_ft = vc
     2 last_name_ft = vc
     2 birth_dt_tm = dq8
     2 birth_tm_zn = i4
     2 sex_ref = f8
     2 prearrival_type_ref = f8
     2 prearrival_chief_complaint_txt = vc
     2 age_txt = vc
     2 estimated_arrival_dt_tm = dq8
     2 estimated_arrival_tm_zn = i4
     2 tracking_group_ref = f8
     2 reg_prsnl = f8
     2 reg_prsnl_txt = vc
     2 primary_care_prsnl = f8
     2 primary_care_txt = vc
     2 referring_source_prsnl = f8
     2 referring_source_txt = vc
     2 patient_showed_ind = i2
     2 loc_facility_cd = f8
 )
 RECORD trk_prearrive_keys(
   1 qual[*]
     2 tracking_prearrive_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 encounter_nk = vc
 )
 RECORD trk_prearrive_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
 )
 RECORD trk_evnt_ord_keys(
   1 qual[*]
     2 tracking_event_sk = f8
 )
 RECORD edw_get_raw_event_prsnl(
   1 qual[*]
     2 ce_event_prsnl_id = f8
     2 event_prsnl_id = f8
     2 event_id = f8
     2 action_comment = vc
     2 action_dt_tm = dq8
     2 action_tm_zn = i4
     2 action_prsnl_id = f8
     2 action_prsnl_ft = vc
     2 action_status_cd = f8
     2 action_type_cd = f8
     2 linked_event_id = vc
     2 person_id = f8
     2 proxy_prsnl_id = f8
     2 proxy_prsnl_ft = vc
     2 request_comment = vc
     2 request_dt_tm = dq8
     2 request_prsnl_id = f8
     2 request_prsnl_ft = vc
     2 request_tm_zn = i4
     2 loc_facility_cd = f8
     2 encntr_id = f8
     2 valid_until_dt_tm = dq8
     2 valid_until_tm_zn = i4
     2 valid_from_dt_tm = dq8
     2 valid_from_tm_zn = i4
 )
 RECORD event_prsnl_keys(
   1 qual[*]
     2 ce_event_prsnl_id = f8
     2 loc_facility_cd = f8
     2 encntr_id = f8
 )
 RECORD edw_pathway_action(
   1 qual[*]
     2 pathway_phase_sk = f8
     2 action_seq = i4
     2 start_dt_tm = dq8
     2 communication_type_ref = vc
     2 duration_unit_ref = f8
     2 end_dt_tm = dq8
     2 pathway_status_ref = f8
     2 action_prsnl = f8
     2 action_dt_tm = dq8
     2 duration_qty = vc
     2 action_type_ref = f8
     2 provider_prsnl = vc
     2 action_tm_zn = i4
     2 start_tm_zn = i4
     2 end_tm_zn = i4
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 pathway_phase_action_sk = f8
     2 pathway_catalog_sk = f8
     2 action_reason_ref = f8
     2 action_comment = vc
     2 start_estimated_ind = vc
     2 end_estimated_ind = vc
 )
 RECORD edw_ap_specimen_keys(
   1 qual[*]
     2 case_specimen_id = f8
     2 ap_case_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD edw_ap_specimen(
   1 qual[*]
     2 ap_specimen_sk = f8
     2 ap_case_sk = f8
     2 collection_dt_tm = dq8
     2 collection_tm_zn = i4
     2 discard_dt_tm = dq8
     2 discard_tm_zn = i4
     2 discard_reason_ref = f8
     2 inadequacy_reason_ref = f8
     2 orig_storage_dt_tm = dq8
     2 orig_storage_tm_zn = i4
     2 received_dt_tm = dq8
     2 received_tm_zn = i4
     2 received_fixative_ref = f8
     2 received_prsnl = f8
     2 specimen_ref = f8
     2 specimen_desc = vc
     2 specimen_label = vc
     2 comment_long_text_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD edw_ap_diag_corr_keys(
   1 qual[*]
     2 event_id = f8
     2 ap_case_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD edw_ap_diag_corr(
   1 qual[*]
     2 ap_diag_corr_sk = f8
     2 ap_case_sk = f8
     2 event_sk = f8
     2 initiated_dt_tm = dq8
     2 initiated_tm_zn = i4
     2 initiated_prsnl = f8
     2 completed_dt_tm = dq8
     2 completed_tm_zn = i4
     2 completed_prsnl = f8
     2 correlated_case_sk = f8
     2 disagree_reason_ref = f8
     2 investigation_ref = f8
     2 study_comment_long_text_sk = f8
     2 slides_reviewed_cnt = f8
     2 study_description = vc
     2 initial_discrepancy_ref = f8
     2 final_discrepancy_ref = f8
     2 init_eval_reason_ref = f8
     2 init_eval_description = vc
     2 init_eval_display = vc
     2 init_eval_investigatn_req_flg = vc
     2 init_eval_reason_req_flg = vc
     2 init_eval_resolution_req_flg = vc
     2 final_eval_reason_ref = f8
     2 final_eval_description = vc
     2 final_eval_display = vc
     2 final_eval_investigatn_req_flg = vc
     2 final_eval_reason_req_flg = vc
     2 final_eval_resolution_req_flg = vc
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD edw_ap_block_keys(
   1 qual[*]
     2 cassette_id = f8
     2 case_specimen_id = f8
     2 ap_case_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD edw_ap_block(
   1 qual[*]
     2 ap_block_sk = f8
     2 ap_specimen_sk = f8
     2 ap_case_sk = f8
     2 block_label = vc
     2 block_label_modifier = vc
     2 discard_dt_tm = dq8
     2 discard_tm_zn = i4
     2 discard_reason_ref = f8
     2 fixative_ref = f8
     2 orig_storage_dt_tm = dq8
     2 orig_storage_tm_zn = i4
     2 pieces = vc
     2 task_assay_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD slide(
   1 qual[*]
     2 ap_slide_sk = f8
     2 ap_block_sk = f8
     2 ap_specimen_sk = f8
     2 ap_case_sk = f8
     2 discard_dt_tm = dq8
     2 discard_tm_zn = i4
     2 discard_reason_ref = f8
     2 orig_storage_dt_tm = dq8
     2 orig_storage_tm_zn = i4
     2 task_assay_sk = f8
     2 special_stain = vc
     2 slide_seq = vc
     2 origin_modifier = vc
     2 stain_task_assay_sk = f8
     2 task_assay_sk = f8
     2 slide_label = vc
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD slide_keys(
   1 qual[*]
     2 ap_slide_sk = f8
     2 case_specimen_id = f8
     2 encounter_sk = f8
     2 loc_facility_cd = f8
 )
 RECORD slide_parent_keys(
   1 qual[*]
     2 ap_specimen_sk = f8
 )
 RECORD process(
   1 qual[*]
     2 ap_process_sk = f8
     2 ap_block_sk = f8
     2 ap_slide_sk = f8
     2 ap_case_sk = f8
     2 ap_specimen_sk = f8
     2 order_sk = f8
     2 comment_long_text_sk = f8
     2 no_charge_ind = i2
     2 priority_ref = f8
     2 request_dt_tm = dq8
     2 request_tm_zn = i4
     2 request_prsnl = f8
     2 research_account_sk = f8
     2 task_svc_res_dept_hier_sk = f8
     2 status_ref = f8
     2 status_dt_tm = dq8
     2 status_tm_zn = i4
     2 status_prsnl = f8
     2 task_assay_sk = f8
     2 worklist_nbr = vc
     2 cancel_ref = f8
     2 cancel_dt_tm = dq8
     2 cancel_tm_zn = i4
     2 cancel_prsnl = f8
     2 process_ordbl = f8
     2 slide_label = vc
     2 encounter_sk = f8
     2 loc_facility_cd = f8
 )
 RECORD process_keys(
   1 qual[*]
     2 ap_process_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD process_parent_keys(
   1 qual[*]
     2 ap_specimen_sk = f8
 )
 RECORD enc_flex_keys(
   1 qual[*]
     2 enc_flex_hist_sk = f8
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 encounter_nk = vc
     2 loc_cd = f8
 )
 RECORD enc_flex_hist_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
 )
 RECORD enc_flex(
   1 qual[*]
     2 loc_facility_cd = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 enc_flex_hist_sk = f8
     2 accommodation_ref = f8
     2 accommodation_request_ref = f8
     2 active_ind = i2
     2 activity_dt_tm = dq8
     2 activity_tm_zn = i4
     2 admit_mode_ref = f8
     2 admit_source_ref = f8
     2 admit_type_ref = f8
     2 alternate_lvl_care_ref = f8
     2 alt_lvl_care_decomp_dt_tm = dq8
     2 alt_lvl_care_decomp_tm_zn = i4
     2 alternate_lvl_care_dt_tm = dq8
     2 alternate_lvl_care_tm_zn = i4
     2 change_bit = i4
     2 change_bit_txt = vc
     2 discharge_disposition_ref = f8
     2 discharge_dt_tm = dq8
     2 discharge_tm_zn = i4
     2 discharge_to_loc_ref = f8
     2 encounter_status_ref = f8
     2 patient_type_ref = f8
     2 inpatient_admit_dt_tm = dq8
     2 inpatient_admit_tm_zn = i4
     2 isolation_ref = f8
     2 current_loc = f8
     2 temporary_loc = f8
     2 medical_service_ref = f8
     2 mental_category_ref = f8
     2 mental_health_ref = f8
     2 mental_health_dt_tm = dq8
     2 mental_health_tm_zn = i4
     2 organization_sk = f8
     2 patient_classification_ref = f8
     2 person_sk = f8
     2 placement_auth_prsnl = f8
     2 psychiatric_status_ref = f8
     2 region_ref = f8
     2 admit_dt_tm = dq8
     2 admit_tm_zn = i4
     2 tracking_bit = i4
     2 tracking_bit_txt = vc
     2 transaction_dt_tm = dq8
     2 transaction_tm_zn = i4
     2 transfer_reason_ref = f8
     2 trauma_ref = f8
     2 trauma_dt_tm = dq8
     2 trauma_tm_zn = i4
     2 triage_ref = f8
     2 triage_dt_tm = dq8
     2 triage_tm_zn = i4
     2 extract_dt_tm = dq8
 )
 RECORD health_plan(
   1 qual[*]
     2 health_plan_sk = f8
     2 plan_name = vc
     2 financial_class_ref = f8
     2 plan_type_ref = f8
     2 ins_carrier_org = f8
     2 ins_sponsor_org = f8
     2 baby_coverage_ref = f8
     2 group_name = vc
     2 group_nbr = vc
     2 person_bill_pref_flg = vc
     2 policy_nbr = vc
     2 product_ref = f8
     2 src_active_ind = c1
 )
 RECORD ap_case_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD ap_case_keys(
   1 qual[*]
     2 ap_case_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD ap_case(
   1 qual[*]
     2 ap_case_sk = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 accession = vc
     2 accessioned_dt_tm = dq8
     2 accessioned_tm_zn = i4
     2 accession_prsnl = f8
     2 case_received_dt_tm = dq8
     2 case_received_tm_zn = i4
     2 case_type_ref = f8
     2 clinical_high_risk_flg = i2
     2 comment_long_text_sk = f8
     2 order_loc = f8
     2 case_collected_dt_tm = dq8
     2 case_collected_tm_zn = i4
     2 main_rpt_verf_dt_tm = dq8
     2 main_rpt_verf_tm_zn = i4
     2 origin_flg = vc
     2 ext_smear_received_flg = i2
     2 order_prsnl = f8
     2 reserved_flg = vc
     2 resp_prsnl = f8
     2 resp_resident_prsnl = f8
     2 source_of_smear_ref = f8
     2 cancel_ref = f8
     2 cancel_dt_tm = dq8
     2 cancel_tm_zn = i4
     2 cancel_prsnl = f8
     2 normalcy_ref = f8
     2 loc_facility_cd = f8
 )
 RECORD ap_report_parents(
   1 qual[*]
     2 case_id = f8
 )
 RECORD ap_report_keys(
   1 qual[*]
     2 ap_report_id = f8
     2 ap_task_assay_cd = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD ap_report(
   1 qual[*]
     2 ap_rpt_section_sk = vc
     2 ap_case_sk = f8
     2 report_sk = f8
     2 section_type_task_assay_sk = f8
     2 report_type_ref = f8
     2 report_test_ref = f8
     2 report_seq = i4
     2 order_dt_tm = dq8
     2 order_tm_zn = i4
     2 event_sk = f8
     2 order_prsnl = f8
     2 signing_loc = f8
     2 report_status_ref = f8
     2 report_status_dt_tm = dq8
     2 report_status_tm_zn = i4
     2 report_status_prsnl = f8
     2 synoptic_stale_dt_tm = dq8
     2 synoptic_stale_tm_zn = i4
     2 cancel_ref = f8
     2 cancel_dt_tm = dq8
     2 cancel_tm_zn = i4
     2 cancel_prsnl = f8
     2 report_text = vc
     2 primary_report_flg = vc
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD ap_concept_parents(
   1 qual[*]
     2 case_id = f8
 )
 RECORD ap_concept_keys(
   1 qual[*]
     2 ap_concept_id = f8
     2 ap_concept_id_2 = f8
 )
 RECORD ap_concept(
   1 qual[*]
     2 ap_concept_sk = vc
     2 ap_case_sk = f8
     2 concept_type_flg = i2
     2 concept_nomen = f8
     2 ap_rpt_section_sk = vc
     2 report_sk = f8
     2 specimen_sk = f8
     2 concept_group_ident = f8
     2 concept_value_txt = vc
     2 concept_truth_state_ref = f8
     2 units_ref = f8
     2 auto_code_flg = i2
     2 ap_concept_id = f8
     2 ap_concept_id_2 = f8
 )
 RECORD scd_org_parents(
   1 qual[*]
     2 story_id = f8
 )
 RECORD scd_ccpt_parents(
   1 qual[*]
     2 story_id = f8
 )
 RECORD scd_term_data_parents(
   1 qual[*]
     2 scd_term_id = f8
     2 scd_story_id = f8
 )
 RECORD scd_term_data_parents_term(
   1 qual[*]
     2 scd_term_id = f8
 )
 RECORD scd_term_data_keys(
   1 qual[*]
     2 scd_term_data_id = f8
     2 scd_story_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD scd_term_data(
   1 qual[*]
     2 scd_story_sk = f8
     2 scd_term_sk = f8
     2 term_data_sk = f8
     2 scd_term_data_sk = vc
     2 data_txt = vc
     2 data_type_ref = f8
     2 entity_name = vc
     2 entity_ident = f8
     2 event_sk = f8
     2 diagnosis_sk = f8
     2 procedure_sk = f8
     2 order_sk = f8
     2 encounter_nk = vc
     2 code_set = f8
     2 code_value_ref = f8
     2 term_data_blob_format_ref = f8
     2 value_txt = vc
     2 value_nbr = f8
     2 value_dt_tm = dq8
     2 value_tm_zn = i4
     2 value_dt_tm_offset = f8
     2 value_unit_of_measure_ref = f8
     2 active_ind = i2
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD scd_term_parents(
   1 qual[*]
     2 scd_story_id = f8
 )
 RECORD scd_term_keys(
   1 qual[*]
     2 scd_term_id = f8
 )
 RECORD scd_term(
   1 qual[*]
     2 scd_story_sk = f8
     2 scd_term_sk = f8
     2 scd_paragraph_sk = f8
     2 scr_para_type_sk = f8
     2 paragraph_seq = i4
     2 paragraph_truth_state_ref = f8
     2 paragraph_scd_term_data_sk = f8
     2 paragraph_event_sk = f8
     2 scd_sentence_sk = f8
     2 canonical_sentence_pattern_sk = f8
     2 sentence_event_sk = f8
     2 sentence_scr_term_hier_sk = f8
     2 sentence_seq = i4
     2 sentence_author_prsnl = f8
     2 scr_term_sk = f8
     2 term_scr_term_hier_sk = f8
     2 parent_scd_term_sk = f8
     2 succesor_scd_term_sk = f8
     2 term_seq = i4
     2 concept_cki = vc
     2 scd_term_data_sk = f8
     2 truth_state_ref = f8
     2 event_sk = f8
     2 modify_prsnl = f8
     2 phase_txt = vc
     2 active_ind = i2
 )
 RECORD scd_story_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD scd_story_keys(
   1 qual[*]
     2 scd_story_id = f8
     2 encntr_id = f8
     2 encntr_nk = vc
     2 loc_facility_cd = f8
 )
 RECORD scd_story(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 scd_story_sk = f8
     2 person_sk = f8
     2 note_author_prsnl = f8
     2 entry_mode_ref = f8
     2 event_sk = f8
     2 note_completion_status_ref = f8
     2 documentation_type_ref = f8
     2 title = vc
     2 note_signed_dt_tm = dq8
     2 note_signed_tm_zn = i4
     2 signed_prsnl = f8
     2 first_addendum_dt_tm = dq8
     2 first_addendum_tm_zn = i4
     2 first_addendum_prsnl = f8
     2 last_addendum_dt_tm = dq8
     2 last_addendum_tm_zn = i4
     2 last_addendum_prsnl = f8
     2 active_ind = i2
     2 loc_facility_cd = f8
 )
 RECORD enc_slice_keys(
   1 qual[*]
     2 encounter_sk = f8
     2 encntr_slice_sk = f8
     2 loc_facility_cd = f8
     2 encounter_nk = vc
 )
 RECORD enc_slice_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
     2 encntr_slice_sk = f8
 )
 RECORD enc_slice(
   1 qual[*]
     2 loc_facility_cd = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 encntr_slice_sk = f8
     2 active_ind_txt = i2
     2 encntr_slice_flg = i2
     2 encntr_slice_type_ref = f8
     2 start_dt_tm = dq8
     2 start_tm_zn = i4
     2 end_dt_tm = dq8
     2 end_tm_zn = i4
     2 extract_dt_tm = dq8
 )
 RECORD scr_term_hier(
   1 qual[*]
     2 scr_term_hier_sk = f8
     2 canonical_sentence_pattern_sk = f8
     2 sentence_recommended_ref = f8
     2 scr_pattern_sk = f8
     2 scr_para_type_sk = f8
     2 paragraph_seq = vc
     2 paragraph_sk = f8
     2 sentence_seq = vc
     2 sentence_topic_ref = f8
     2 sentence_text_format_rule_ref = f8
     2 sentence_sk = f8
     2 term_hier_cki_source = vc
     2 term_hier_cki_identifier = vc
     2 concept_cki = vc
     2 term_hier_dependency_ref = f8
     2 term_hier_dependency_group = vc
     2 parent_scr_term_hier_sk = f8
     2 term_hier_recommended_ref = f8
     2 scr_term_sk = f8
     2 term_seq = vc
     2 source_scr_term_hier_sk = f8
     2 term_required_ind = f8
 )
 RECORD scr_term_hier_keys(
   1 qual[*]
     2 scr_term_hier_sk = f8
 )
 RECORD edw_wait_list_keys(
   1 qual[*]
     2 wait_list_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 encounter_nk = vc
 )
 RECORD wait_list(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 wait_list_sk = f8
     2 active_ind = i2
     2 adj_waiting_start_dt_tm = dq8
     2 adj_wait_start_tm_zn = i4
     2 admit_booking_ref = f8
     2 admit_category_ref = f8
     2 admit_decision_dt_tm = dq8
     2 admit_decision_tm_zn = i4
     2 admit_guaranteed_dt_tm = dq8
     2 admit_guaranteed_tm_zn = i4
     2 admit_offer_outcome_ref = f8
     2 admit_type_ref = f8
     2 anesthetic_ref = f8
     2 appointment_ref = f8
     2 appt_loc = vc
     2 appt_synonym_ref = vc
     2 appt_type_ref = vc
     2 attendance_ref = f8
     2 attenddoc_clin_service_ref = f8
     2 auto_blood_ind = vc
     2 change_dt_tm = dq8
     2 change_tm_zn = i4
     2 change_prsnl = f8
     2 wl_comment_long_text_sk = f8
     2 commissioner_reference_txt = vc
     2 decline_status_ref = f8
     2 decline_status_dt_tm = dq8
     2 decline_status_tm_zn = i4
     2 delay_status_ref = f8
     2 delay_status_dt_tm = dq8
     2 delay_status_tm_zn = i4
     2 est_admit_dt_tm = dq8
     2 est_admit_tm_zn = i4
     2 est_length_procedure_ref = f8
     2 financial_class_ref = f8
     2 financial_class_eff_dt_tm = dq8
     2 financial_class_eff_tm_zn = i4
     2 fnctnl_deficiency_cause_ref = f8
     2 fnctnl_deficiency_ref = f8
     2 last_dna_dt_tm = dq8
     2 last_dna_tm_zn = i4
     2 patient_loc = f8
     2 management_ref = f8
     2 operation_ref = f8
     2 orig_request_rcvd_dt_tm = dq8
     2 orig_request_rcvd_tm_zn = i4
     2 other_med_condition_txt = vc
     2 pend_acceptance_dt_tm = dq8
     2 pend_acceptance_tm_zn = i4
     2 pend_notification_dt_tm = dq8
     2 pend_notification_tm_zn = i4
     2 pend_place_priority_ref = f8
     2 pend_place_priority_dt_tm = dq8
     2 pend_place_priority_tm_zn = i4
     2 planned_admit_dt_tm = dq8
     2 planned_admit_tm_zn = i4
     2 planned_procedure_ref = f8
     2 planned_procedure_dt_tm = dq8
     2 planned_procedure_tm_zn = i4
     2 pre_admit_attend_ind = vc
     2 pre_admit_clin_appt_dt_tm = dq8
     2 pre_admit_clin_appt_tm_zn = i4
     2 pre_prov_admit_dt_tm = dq8
     2 pre_prov_admit_tm_zn = i4
     2 provisional_admit_dt_tm = dq8
     2 provisional_admit_tm_zn = i4
     2 reason_for_change_ref = f8
     2 reason_for_removal_txt = vc
     2 reason_for_removal_ref = f8
     2 recommend_dt_tm = dq8
     2 recommend_tm_zn = i4
     2 referral_dt_tm = dq8
     2 referral_tm_zn = i4
     2 referral_reason_ref = f8
     2 referral_source_ref = f8
     2 referral_type_ref = f8
     2 removal_dt_tm = dq8
     2 removal_tm_zn = i4
     2 requested_dt_tm = dq8
     2 requested_tm_zn = i4
     2 resource_ref = vc
     2 sch_appointment_sk = vc
     2 schedule_dt_tm = dq8
     2 schedule_tm_zn = i4
     2 service_type_requested_ref = f8
     2 stand_by_ref = f8
     2 status_ref = f8
     2 status_dt_tm = dq8
     2 status_tm_zn = i4
     2 status_end_dt_tm = dq8
     2 status_end_tm_zn = i4
     2 status_review_dt_tm = dq8
     2 status_review_tm_zn = i4
     2 supra_service_request_ref = f8
     2 suspended_days = i4
     2 urgency_ref = f8
     2 urgency_dt_tm = dq8
     2 urgency_tm_zn = i4
     2 waiting_end_dt_tm = dq8
     2 waiting_end_tm_zn = i4
     2 waiting_start_dt_tm = dq8
     2 waiting_start_tm_zn = i4
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD user_defined_hist_keys(
   1 qual[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 udf_type_cd = f8
     2 loc_facility_cd = f8
 )
 RECORD user_defined_keys(
   1 qual[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 udf_type_cd = f8
     2 loc_facility_cd = f8
 )
 RECORD user_defined_hist_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD user_defined_hist(
   1 qual[*]
     2 user_defined_hist_sk = f8
     2 src_active_ind = i2
     2 parent_entity_sk = f8
     2 parent_entity_name = vc
     2 transaction_dt_tm = dq8
     2 transaction_tm_zn = i4
     2 user_defined_type_ref = f8
     2 value_ref = f8
     2 value_ref_code_set = vc
     2 value_dt_tm = dq8
     2 value_tm_zn = i4
     2 value_long_text_sk = f8
     2 value_nbr = i4
     2 value_type_flg = f8
     2 loc_facility_cd = f8
 )
 RECORD enc_acp_parents(
   1 qual_enc[*]
     2 encntr_id = f8
   1 qual_sl[*]
     2 encntr_slice_id = f8
 )
 RECORD enc_acp_keys(
   1 qual[*]
     2 encntr_augm_care_period_id = f8
 )
 RECORD enc_acp(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 encntr_slice_sk = f8
     2 encntr_augm_care_period_id = f8
     2 acp_disposal_ref = f8
     2 acp_plan_ref = f8
     2 acp_source_ref = f8
     2 acp_medical_service_ref = f8
     2 acp_loc = f8
     2 src_beg_effective_dt_tm = dq8
     2 src_beg_effective_tm_zn = i4
     2 src_beg_effective_tm_vld_flg = i2
     2 src_end_effective_dt_tm = dq8
     2 src_end_effective_tm_zn = i4
     2 src_end_effective_tm_vld_flg = i2
     2 discharge_to_loc_ref = f8
     2 high_depend_care_lvl_days = vc
     2 intensive_care_lvl_days = vc
     2 num_organ_sys_support_nbr = vc
     2 active_ind = i2
 )
 RECORD enc_accident_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
 )
 RECORD enc_accident_keys(
   1 qual[*]
     2 encntr_accident_id = f8
 )
 RECORD enc_accident(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 encntr_accident_id = f8
     2 acc_ref = f8
     2 acc_dt_tm = dq8
     2 acc_tm_zn = i4
     2 acc_tm_vld_flg = vc
     2 acc_loctn_text = vc
     2 acc_death_ref = f8
     2 acc_emp_org = vc
     2 acc_job_reltn_ref = f8
     2 acc_state_ref = f8
     2 ambul_arrive_ref = vc
     2 ambul_geog_ref = vc
     2 ambul_serv_nbr = c20
     2 appl_dt_tm = dq8
     2 appl_tm_zn = i4
     2 appl_tm_vld_flg = vc
     2 attd_dt_tm = dq8
     2 attd_tm_zn = i4
     2 attd_tm_vld_flg = vc
     2 init_asse_dt_tm = dq8
     2 init_asse_tm_zn = i4
     2 init_asse_tm_vld_flg = vc
     2 place_ref = f8
     2 police_badge_nbr = c20
     2 police_force_ref = vc
     2 police_invo_ref = vc
     2 treat_start_dt_tm = dq8
     2 treat_start_tm_zn = i4
     2 treat_start_tm_vld_flg = vc
     2 rec_source_ref = vc
     2 ea_active_ind = c1
     2 loc_facility_cd = f8
     2 nhs_providing_org = f8
     2 accident_text = vc
 )
 RECORD ep_enc_parents(
   1 qual_enc[*]
     2 encntr_id = f8
 )
 RECORD ep_enc_keys(
   1 qual[*]
     2 episode_encntr_reltn_id = f8
 )
 RECORD ep_enc(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 episode_encntr_reltn_id = f8
     2 episode_start_dt_tm = dq8
     2 episode_start_tm_zn = i4
     2 episode_start_tm_vld_flg = i2
     2 episode_end_dt_tm = dq8
     2 episode_end_tm_zn = i4
     2 episode_end_tm_vld_flg = i2
     2 create_dt_tm = dq8
     2 create_tm_zn = i4
     2 create_tm_vld_flg = i2
     2 episode_name = vc
     2 episode_type_ref = f8
     2 active_ind = c1
     2 loc_facility_cd = f8
     2 refer_facility_cd = f8
     2 episode_sk = f8
 )
 RECORD edw_address_keys(
   1 qual[*]
     2 address_id = f8
 )
 RECORD edw_address(
   1 qual[*]
     2 address_sk = f8
     2 src_active_ind = vc
     2 address_info_status_ref = f8
     2 address_type_ref = f8
     2 address_type_seq = i4
     2 src_beg_effective_dt_tm = dq8
     2 src_beg_effective_tm_zn = i4
     2 src_end_effective_dt_tm = dq8
     2 src_end_effective_tm_zn = i4
     2 city_txt = vc
     2 comment_txt = vc
     2 contact_name = vc
     2 country_txt = vc
     2 country_ref = f8
     2 county_txt = vc
     2 county_ref = f8
     2 district_health_ref = f8
     2 address_long_text_sk = f8
     2 operations_hours = vc
     2 src_parent_entity_sk = f8
     2 src_parent_entity_name = vc
     2 postal_barcode_info = vc
     2 postal_identifier = vc
     2 postal_identifier_srch = vc
     2 primary_care_ref = f8
     2 residence_ref = f8
     2 residence_type_ref = f8
     2 source_identifier = vc
     2 state_txt = vc
     2 state_ref = f8
     2 street_addr1 = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 zipcode = vc
     2 zipcode_srch = vc
     2 zipcode_group_ref = f8
 )
 RECORD edw_phone_keys(
   1 qual[*]
     2 phone_id = f8
 )
 RECORD edw_phone(
   1 qual[*]
     2 phone_sk = f8
     2 src_active_ind = vc
     2 src_beg_effective_dt_tm = dq8
     2 src_beg_effective_tm_zn = i4
     2 src_end_effective_dt_tm = dq8
     2 src_end_effective_tm_zn = i4
     2 call_instruction = vc
     2 contact_name = vc
     2 contact_method_ref = f8
     2 description = vc
     2 extension = vc
     2 phone_long_text_sk = vc
     2 modem_capability_ref = f8
     2 operation_hours = vc
     2 paging_code = vc
     2 src_parent_entity_sk = f8
     2 src_parent_entity_name = vc
     2 phone_nbr = vc
     2 phone_type_ref = f8
     2 phone_type_seq = i4
     2 source_identifier = vc
     2 phone_format_ref = f8
     2 formatted_phone_nbr = vc
 )
 RECORD enc_leav_parents(
   1 qual_enc[*]
     2 encntr_id = f8
 )
 RECORD enc_leav_keys(
   1 qual[*]
     2 encntr_leave_id = f8
 )
 RECORD enc_leav(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 enc_leave_sk = f8
     2 active_ind = i2
     2 auto_discharge_dt_tm = dq8
     2 auto_discharge_tm_zn = i4
     2 auto_discharge_tm_vld_flg = i2
     2 cancel_comment = vc
     2 cancel_dt_tm = dq8
     2 cancel_tm_zn = i4
     2 cancel_tm_vld_flg = i2
     2 cancel_reason_ref = f8
     2 cancel_prsnl = f8
     2 estimated_return_dt_tm = dq8
     2 estimated_return_tm_zn = i4
     2 estimated_return_tm_vld_flg = i2
     2 hold_removal_dt_tm = dq8
     2 hold_removal_tm_zn = i4
     2 hold_removal_tm_vld_flg = i2
     2 leave_comment = vc
     2 leave_dt_tm = dq8
     2 leave_tm_zn = i4
     2 leave_tm_vld_flg = i2
     2 leave_ind = c1
     2 leave_location = vc
     2 leave_reason_ref = f8
     2 leave_type_ref = f8
     2 leave_prsnl = f8
     2 return_comment = vc
     2 return_dt_tm = dq8
     2 return_tm_zn = i4
     2 return_tm_vld_flg = i2
     2 return_loc = f8
     2 return_reason_ref = f8
     2 return_prsnl = f8
     2 loc_facility_cd = f8
 )
 RECORD benefit_alloc_keys(
   1 qual[*]
     2 encounter_nk = vc
     2 benefit_alloc_sk = f8
     2 encntr_slice_sk = f8
     2 encounter_sk = f8
     2 loc_facility_cd = f8
 )
 RECORD benefit_alloc(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 encntr_slice_sk = f8
     2 benefit_alloc_sk = f8
     2 active_ind = vc
     2 benefit_sk = f8
     2 finalized_dt_tm = dq8
     2 finalized_tm_zn = i4
     2 health_plan_sk = f8
     2 made_by_prsnl = f8
     2 nca_ind = f8
     2 benefit_org = f8
     2 loc_facility_cd = f8
 )
 RECORD benefit_keys(
   1 qual[*]
     2 benefit_sk = f8
 )
 RECORD benefit(
   1 qual[*]
     2 benefit_sk = f8
     2 active_ind = vc
     2 benefit_type_ref = f8
     2 cost_per_bed_day = vc
     2 cost_per_case = vc
     2 data_type_ref = f8
     2 value_dt_tm = dq8
     2 value_tm_zn = i4
     2 double_value = f8
     2 benefit_desc = vc
     2 local_rvu = vc
     2 long_text_sk = f8
     2 mnemonic = vc
     2 national_rvu = vc
     2 nbr_pat_agreed = vc
     2 rvu_amount = vc
     2 string_value = vc
     2 units_ref = f8
     2 variance_level = vc
 )
 RECORD edw_person_keys(
   1 qual[*]
     2 person_name_sk = f8
 )
 RECORD edw_person_name(
   1 qual[*]
     2 health_system_source_id = i4
     2 person_name_sk = f8
     2 person_sk = f8
     2 name_type_ref = f8
     2 src_active_ind = vc
     2 name_degree = vc
     2 name_first = vc
     2 name_first_srch = vc
     2 name_full = vc
     2 name_initials = vc
     2 name_last = vc
     2 name_last_srch = vc
     2 name_middle = vc
     2 name_middle_srch = vc
     2 name_original = vc
     2 name_prefix = vc
     2 name_suffix = vc
     2 name_title = vc
     2 name_type_seq = i4
     2 source_identifier = vc
     2 src_beg_effective_dt_tm = dq8
     2 src_beg_effective_tm_zn = i4
     2 src_end_effective_dt_tm = dq8
     2 src_end_effective_tm_zn = i4
 )
 RECORD edw_encntr_encntr_reltn_parents(
   1 qual_enc[*]
     2 encntr_id = f8
   1 qual_rel_enc[*]
     2 related_encntr_id = f8
 )
 RECORD edw_encntr_encntr_reltn_keys(
   1 qual[*]
     2 encntr_encntr_reltn_id = f8
 )
 RECORD edw_encntr_encntr_reltn(
   1 qual[*]
     2 encounter_nk = vc
     2 related_encounter_nk = vc
     2 encounter_sk = f8
     2 related_encounter_sk = f8
     2 enc_enc_reltn_sk = f8
     2 enc_reltn_type_ref = f8
     2 src_active_ind = vc
 )
 RECORD mltm_drug_class_rltn_all_keys(
   1 qual[*]
     2 ndc_code = c18
     2 mmdc_pattern = vc
 )
 RECORD mltm_drug_class_rltn_keys(
   1 qual[*]
     2 ndc_code = c18
     2 mmdc_pattern = vc
 )
 RECORD mltm_drug_code_cki(
   1 qual[*]
     2 main_multum_drug_code = i4
 )
 RECORD mltm_drug_class_rltn(
   1 qual[*]
     2 d_dclass_reltn_sk = vc
     2 ndc_code = c18
     2 main_multum_drug_code = i4
     2 formulary_cki = vc
     2 mltm_drug_ident = c6
     2 mltm_drug_cki = vc
     2 mltm_therapeutic_class_ident = f8
     2 mltm_therapeutic_class_name = vc
     2 mltm_therapeutic_class_lvl_nbr = i4
     2 mltm_therapeutic_subclass_ident = f8
     2 d_dsubclass_reltn_sk = vc
 )
 RECORD multum_med(
   1 cnt = i4
   1 qual[*]
     2 ndc = c18
 ) WITH protect
 RECORD uniq_multum_med(
   1 cnt = i4
   1 qual[*]
     2 ndc = c18
 ) WITH protect
 RECORD drug_cls_orphan_keys(
   1 qual[*]
     2 cki = vc
 )
 RECORD cdsctnt_parents(
   1 qual_enc[*]
     2 encntr_id = f8
 )
 RECORD cdsctnt_keys(
   1 qual[*]
     2 cds_batch_cntnt_sk = f8
 )
 RECORD cdsctnt(
   1 qual[*]
     2 cds_batch_cntnt_sk = f8
     2 cds_batch_sk = f8
     2 activity_dt_tm = dq8
     2 activity_tm_zn = i4
     2 activity_tm_vld_flg = i2
     2 cds_row_error_ind = vc
     2 cds_type_ref = f8
     2 encounter_sk = f8
     2 cds_org = f8
     2 parent_entity_sk = f8
     2 parent_entity_name = vc
     2 update_del_flg = vc
     2 loc_facility_cd = f8
 )
 RECORD edw_por_keys(
   1 qual[*]
     2 prsnl_org_reltn_id = f8
 )
 RECORD edw_por(
   1 qual[*]
     2 prsnl_org_reltn_sk = f8
     2 src_beg_effective_dt_tm = dq8
     2 src_beg_effective_tm_zn = i4
     2 src_end_effective_dt_tm = dq8
     2 src_end_effective_tm_zn = i4
     2 src_active_ind = vc
     2 confidence_level_ref = f8
     2 organization_sk = f8
     2 personnel_sk = f8
 )
 RECORD cdsctnth_parents(
   1 qual_enc[*]
     2 encntr_id = f8
 )
 RECORD cdsctnth_keys(
   1 qual[*]
     2 h_cds_batch_cntnt_sk = f8
 )
 RECORD cdsctnth(
   1 qual[*]
     2 h_cds_batch_cntnt_sk = f8
     2 cds_batch_cntnt_sk = f8
     2 cds_batch_sk = f8
     2 cds_row_error_ind = vc
     2 activity_dt_tm = dq8
     2 activity_tm_zn = i4
     2 activity_tm_vld_flg = i2
     2 cds_type_ref = f8
     2 encounter_sk = f8
     2 cds_org = f8
     2 parent_entity_sk = f8
     2 parent_entity_name = vc
     2 transaction_dt_tm_txt = dq8
     2 transaction_tm_zn = i4
     2 transaction_tm_vld_flg = i2
     2 update_del_flg = vc
     2 loc_facility_cd = f8
 )
 RECORD enc_info_parent_keys(
   1 qual_enc[*]
     2 encntr_id = f8
 )
 RECORD enc_info_keys(
   1 qual[*]
     2 encntr_info_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 encounter_nk = vc
 )
 RECORD enc_info(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 encntr_info_sk = f8
     2 src_beg_effective_dt_tm = dq8
     2 src_beg_effective_tm_zn = i4
     2 src_beg_effective_tm_vld_flg = i4
     2 src_end_effective_dt_tm = dq8
     2 src_end_effective_tm_zn = i4
     2 src_end_effective_tm_vld_flg = i4
     2 info_sub_type_ref = f8
     2 info_type_ref = f8
     2 value_long_text_sk = f8
     2 priority_seq = vc
     2 value_ref = f8
     2 value_dt_tm = dq8
     2 value_tm_zn = i4
     2 value_tm_vld_flg = i4
     2 value_numeric = vc
     2 value_txt = vc
     2 active_ind = vc
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 chartable_ind = vc
     2 value_code_set = f8
 )
 RECORD edw_wait_list_status_parents(
   1 qual[*]
     2 wait_list_id = f8
 )
 RECORD edw_wait_list_status_keys(
   1 qual[*]
     2 wait_list_status_id = f8
 )
 RECORD edw_wait_list_status(
   1 qual[*]
     2 wait_list_sk = f8
     2 wait_list_status_sk = f8
     2 active_ind = i4
     2 comment_long_text_sk = f8
     2 reason_for_change_ref = f8
     2 status_ref = f8
     2 status_beg_dt_tm = dq8
     2 status_beg_tm_zn = i4
     2 status_end_dt_tm = dq8
     2 status_end_tm_zn = i4
     2 source_flg = f8
     2 extract_dt_tm = dq8
 )
 RECORD fin_encounter_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD fin_encounter_keys(
   1 qual[*]
     2 pft_encntr_id = f8
     2 encntr_id = f8
     2 encntr_nk = vc
     2 loc_facility_cd = f8
 )
 RECORD fin_encounter(
   1 qual[*]
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 fin_encounter_sk = f8
     2 account_sk = f8
     2 billing_entity_sk = f8
     2 financial_account_ident = vc
     2 adjustment_balance_amt = vc
     2 adj_balance_credit_debit_flg = vc
     2 applied_payment_balance_amt = vc
     2 bad_debt_balance_amt = vc
     2 bad_debt_credit_debit_flg = i2
     2 bad_debt_dt_tm = dq8
     2 bad_debt_tm_zn = i4
     2 total_balance_amt = vc
     2 balance_debit_credit_flg = vc
     2 bill_status_ref = f8
     2 total_charge_amt = vc
     2 charge_debit_credit_flg = vc
     2 collection_letter_flg = i2
     2 combined_into_fin_encounter_sk = f8
     2 consolidation_flg = i2
     2 cardiac_rehab_start_dt_tm = dq8
     2 cardiac_rehab_start_tm_zn = i4
     2 total_cardiac_rehab_visits = vc
     2 disch_dt_tm = dq8
     2 disch_tm_zn = i4
     2 dunning_hold_flg = vc
     2 dunning_flg = i2
     2 dunning_level_ref = f8
     2 dunning_level_chg_dt_tm = dq8
     2 dunning_level_chg_tm_zn = i4
     2 dunning_level_cnt = vc
     2 dunning_no_pay_cnt = vc
     2 dunning_pay_cnt = vc
     2 dunning_unacceptable_pay_cnt = vc
     2 ext_collection_flg = vc
     2 financial_class_ref = f8
     2 ontime_paid_off_flg = vc
     2 ins_pending_balance_fwd_amt = vc
     2 interim_billing_flg = vc
     2 last_adjustment_dt_tm = dq8
     2 last_adjustment_tm_zn = i4
     2 last_charge_dt_tm = dq8
     2 last_charge_tm_zn = i4
     2 last_claim_dt_tm = dq8
     2 last_claim_tm_zn = i4
     2 last_patient_pay_dt_tm = dq8
     2 last_patient_pay_tm_zn = i4
     2 last_payment_dt_tm = dq8
     2 last_payment_tm_zn = i4
     2 last_statement_dt_tm = dq8
     2 last_statement_tm_zn = i4
     2 total_statement_cnt = vc
     2 orig_bill_submit_dt_tm = dq8
     2 orig_bill_submit_tm_zn = i4
     2 orig_bill_transmit_dt_tm = dq8
     2 orig_bill_transmit_tm_zn = i4
     2 ot_start_dt_tm = dq8
     2 ot_start_tm_zn = i4
     2 total_ot_visits = vc
     2 pat_balance_carry_forward_amt = vc
     2 payment_plan_flg = vc
     2 payment_plan_status_ref = f8
     2 status_ref = f8
     2 pt_start_dt_tm = dq8
     2 pt_start_tm_zn = i4
     2 total_pt_visits = vc
     2 qualifier_ref = f8
     2 recur_bill_generated_flg = vc
     2 recur_bill_ready_flg = vc
     2 recur_current_month_nbr = vc
     2 recur_current_year_nbr = i4
     2 recur_flg = vc
     2 recur_seq = vc
     2 sent_to_collection_flg = i2
     2 slt_start_dt_tm = dq8
     2 slt_start_tm_zn = i4
     2 total_slt_visits = vc
     2 unapplied_payment_balance_amt = vc
     2 zero_balance_dt_tm = dq8
     2 zero_balance_tm_zn = i4
     2 primary_health_plan_hlthpln = f8
     2 resp_health_plan_hlthpln = f8
     2 resp_health_plan_priority_seq = i4
     2 primary_hold_type_flg = i2
     2 primary_hold_type_ref = f8
     2 daily_charge_amt = f8
     2 daily_payment_amt = f8
     2 daily_adjustment_amt = f8
     2 bill_transmission_dt_tm = dq8
     2 bill_transmission_tm_zn = i4
     2 wkfw_queue_assigned_prsnl = f8
     2 wkfw_queue_spvsr_prsnl = f8
     2 coding_prsnl = f8
     2 coding_spvsr_prsnl = f8
     2 loc_facility_cd = f8
 )
 FREE RECORD holds
 RECORD holds(
   1 cnt = i4
   1 item[*]
     2 pft_encntr_id = f8
     2 hold_id = f8
     2 hold_type = vc
     2 hold_type_cd = f8
     2 hold_reason = vc
     2 hold_priority = i4
     2 xref = i4
 )
 RECORD fin_bill_parents(
   1 qual[*]
     2 pft_encntr_id = f8
 )
 RECORD fin_bill_keys(
   1 qual[*]
     2 corsp_activity_id = f8
     2 bill_vrsn_nbr = i4
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD fin_bill(
   1 qual[*]
     2 fin_encounter_sk = f8
     2 fin_bill_sk = f8
     2 bill_version_nbr = i4
     2 bill_type_ref = f8
     2 balance_amt = vc
     2 balance_credit_debit_flg = i2
     2 balance_due_amt = f8
     2 balance_due_credit_debit_flg = i2
     2 balance_fwd_amt = f8
     2 balance_fwd_credit_debit_flg = f8
     2 bill_class_ref = f8
     2 bill_nbr_disp = c40
     2 bill_status_ref = f8
     2 bill_status_reason_ref = f8
     2 claim_file_ref = f8
     2 claim_serial_nbr = f8
     2 claim_event_status_ref = f8
     2 claim_status_ctrl_dt_tm = dq8
     2 claim_status_ctrl_tm_zn = i4
     2 contract_mgmt_status_ref = f8
     2 demand_flg = i2
     2 from_service_dt_tm = dq8
     2 from_service_tm_zn = i4
     2 to_service_dt_tm = dq8
     2 to_service_tm_zn = i4
     2 claim_event_gen_dt_tm = dq8
     2 claim_event_gen_tm_zn = i4
     2 image_flg = i2
     2 interim_bill_flg = i2
     2 last_adjustment_dt_tm = dq8
     2 last_adjustment_tm_zn = i4
     2 last_payment_dt_tm = dq8
     2 last_payment_tm_zn = i4
     2 manual_review_flg = i2
     2 media_type_ref = f8
     2 media_sub_type_ref = f8
     2 new_amt = f8
     2 new_amt_credit_debit_flg = i2
     2 page_cnt = vc
     2 ra_claim_field_ref = f8
     2 ra_claim_status_ref = f8
     2 claim_resp_party_ref = f8
     2 route_user_name = c40
     2 submission_route_ref = f8
     2 submit_dt_tm = dq8
     2 submit_tm_zn = i4
     2 transmission_dt_tm = dq8
     2 transmission_tm_zn = i4
     2 health_plan_hlthpln = f8
     2 priority_seq = i4
     2 denial_dt_tm = dq8
     2 denial_tm_zn = i4
     2 demographic_mod_dt_tm = dq8
     2 demographic_mod_tm_zn = i4
     2 encntr_combine_dt_tm = dq8
     2 encntr_combine_tm_zn = i4
     2 src_active_ind = vc
     2 encounter_sk = f8
     2 loc_facility_cd = f8
 )
 RECORD collection_keys(
   1 qual[*]
     2 pft_encntr_collection_r_id = f8
     2 pft_encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD edw_collection(
   1 qual[*]
     2 pft_encntr_id = f8
     2 loc_facility_cd = f8
     2 pft_encntr_collection_r_id = f8
     2 collection_state_cd = f8
     2 coll_percentage = vc
     2 current_balance = f8
     2 curr_bal_dr_cr_flag = i4
     2 orig_write_off_bal = f8
     2 orig_write_off_dt_tm = dq8
     2 orig_write_off_tz = i2
     2 pre_collect_agency_sk = f8
     2 collect_agency_sk = f8
     2 return_balance = f8
     2 return_dt_tm = dq8
     2 return_tz = i2
     2 send_back_reason_cd = f8
     2 send_dt_tm = dq8
     2 send_tz = i2
     2 total_adj_amt = f8
     2 total_adj_dr_cr_flag = i2
     2 total_payment_amt = f8
     2 total_pay_dr_cr_flag = i2
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i2
     2 end_effective_dt_tm = dq8
     2 end_effective_tz = i2
 )
 RECORD fin_coll_encntr_parents(
   1 qual[*]
     2 pft_encntr_id = f8
 )
 RECORD pay_plan_keys(
   1 qual[*]
     2 pft_pay_plan_pe_reltn_id = f8
     2 pft_encntr_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD edw_pay_plan(
   1 cnt = i4
   1 qual[*]
     2 pft_encntr_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 pft_pay_plan_pe_reltn_id = f8
     2 ending_encntr_dt_tm = dq8
     2 ending_encntr_tz = i2
     2 ending_encntr_status_cd = f8
     2 orig_encntr_bal = f8
     2 orig_encntr_dt_tm = dq8
     2 orig_encntr_tz = i2
     2 pft_payment_plan_id = f8
     2 guarantor_person_sk = f8
     2 resp_party_table_name = vc
     2 resp_party_table_sk = f8
     2 pre_collect_agency_sk = f8
     2 billing_entity_sk = f8
     2 cur_period_start_dt_tm = dq8
     2 cur_period_start_tz = i2
     2 cur_period_vld_flg = i2
     2 current_plan_status_cd = f8
     2 cycle_length = i4
     2 due_day = vc
     2 duration_plan_dt_tm = dq8
     2 duration_plan_tz = i2
     2 ending_plan_dt_tm = dq8
     2 ending_plan_tz = i2
     2 begin_plan_dt_tm = dq8
     2 begin_plan_tz = i2
     2 installment_amount = f8
     2 number_of_payments = vc
     2 total_amount_due = f8
 )
 RECORD fin_pay_plan_encntr_parents(
   1 qual[*]
     2 pft_encntr_id = f8
 )
 RECORD denial_keys(
   1 qual[*]
     2 denial_id = f8
     2 pft_encntr_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD edw_denial(
   1 cnt = i4
   1 qual[*]
     2 pft_encntr_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 denial_id = f8
     2 corsp_activity_id = f8
     2 denial_reason_cd = f8
     2 denial_txt = vc
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i2
     2 remark_code_attrib_value = vc
     2 charge_item_id = f8
     2 claim_billed_amt = vc
     2 total_payment_amt = vc
     2 total_adjustment_amt = vc
     2 denial_billed_amt = vc
     2 created_prsnl_id = f8
     2 batch_trans_file_id = f8
     2 batch_trans_id = f8
     2 post_supervisor_person_id = f8
 )
 RECORD fin_denial_encntr_parents(
   1 qual[*]
     2 pft_encntr_id = f8
 )
 RECORD edw_daily_bal(
   1 cnt = i4
   1 qual[*]
     2 fin_encntr_key = f8
     2 loc_facility_cd = f8
     2 encntr_id = f8
     2 pft_encntr_id = f8
     2 acct_id = f8
     2 fin_daily_bal_id = vc
     2 daily_balance_type = vc
     2 activity_dt_tm = dq8
     2 activity_tm_zn = i2
     2 adjustment_amt = vc
     2 adj_dr_cr_flag = vc
     2 beg_balance = vc
     2 beg_dr_cr_flag = vc
     2 billing_entity_id = f8
     2 calculated_end_bal = vc
     2 calc_end_bal_cr_dr_flg = vc
     2 charge_amt = vc
     2 chrg_dr_cr_flg = vc
     2 end_balance_amt = vc
     2 end_bal_dr_cr_flg = vc
     2 last_payment_dt_tm = dq8
     2 last_payment_tm_zn = i2
     2 payment_amount = vc
     2 payment_dr_cr_flg = vc
     2 total_adjustment_amt = vc
     2 total_charge_amt = vc
     2 total_payment_amt = vc
     2 transfer_amt = vc
     2 transfer_dr_cr_flg = vc
 )
 RECORD fin_daily_bal_encntr_parents(
   1 qual[*]
     2 pft_encntr_id = f8
 )
 RECORD pay_adj_keys(
   1 qual[*]
     2 activity_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD edw_pay_adj(
   1 cnt = i4
   1 qual[*]
     2 fin_encntr_sk = f8
     2 encntr_sk = f8
     2 loc_facility_cd = f8
     2 fin_pay_adj_sk = f8
     2 fin_bill_sk = f8
     2 fin_batch_trans_sk = f8
     2 trans_activity_type_ref = f8
     2 activity_event_ref = f8
     2 activity_productivity_flg = vc
     2 activity_productivity_wt = vc
     2 activity_dt_tm = dq8
     2 activity_tz = i4
     2 created_dt_tm = dq8
     2 created_tz = i4
     2 bill_ind = vc
     2 gl_posted_ind = vc
     2 posted_dt_tm = dq8
     2 posted_tz = i4
     2 supression_flg = vc
     2 transaction_type_ref = f8
     2 transaction_sub_type_ref = f8
     2 transaction_status_ref = f8
     2 trans_status_reason_ref = f8
     2 transaction_reason_ref = f8
     2 transaction_amt = f8
     2 trans_credit_debit_flg = i4
     2 credit_card_auth_nbr_txt = vc
     2 credit_card_beg_eff_dt_tm = dq8
     2 credit_card_beg_eff_tz = i4
     2 credit_card_end_eff_dt_tm = dq8
     2 credit_card_end_eff_tz = i4
     2 change_due_amt = vc
     2 check_dt_tm = dq8
     2 check_tm_zn = i4
     2 current_currency_ref = f8
     2 deposit_status_ref = f8
     2 original_currency_ref = f8
     2 payment_method_ref = f8
     2 payment_number_txt = vc
     2 payor_name = vc
     2 posting_method_ref = f8
     2 pay_detail_posted_dt_tm = dq8
     2 pay_detail_posted_tm_zn = i4
     2 tendered_amt = vc
     2 total_payment_amt = f8
     2 gl_account_sk = vc
     2 gl_rsp_unit_sk = vc
     2 health_plan_hlthpln = f8
     2 priority_seq = f8
     2 created_prsnl = f8
     2 trans_alias_sk = f8
 )
 RECORD fin_pay_adj_encntr_parents(
   1 qual[*]
     2 pft_encntr_id = f8
 )
 RECORD charge_keys(
   1 qual[*]
     2 charge_item_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 encntr_nk = vc
 )
 RECORD edw_charge(
   1 qual[*]
     2 fin_encntr_sk = f8
     2 encounter_nk = vc
     2 encntr_sk = f8
     2 loc_facility_cd = f8
     2 fin_charges_sk = f8
     2 bill_item_id = f8
     2 charge_type_cd = f8
     2 abn_status_cd = f8
     2 activity_type_cd = f8
     2 adjusted_dt_tm = dq8
     2 adjusted_tz = i2
     2 alpha_nomen_id = f8
     2 charge_description = vc
     2 cost_center_cd = f8
     2 credited_dt_tm = dq8
     2 credited_tz = i2
     2 department_cd = f8
     2 discount_amount = f8
     2 epsdt_ind = vc
     2 gross_price = f8
     2 health_plan_id = f8
     2 institution_cd = f8
     2 item_copay = f8
     2 item_deductible_amt = f8
     2 item_extended_price = f8
     2 item_list_price = f8
     2 item_price = f8
     2 item_quantity = f8
     2 item_reimbursement = f8
     2 manual_ind = vc
     2 med_service_cd = f8
     2 order_id = f8
     2 ord_loc_cd = f8
     2 parent_charge_item_id = f8
     2 patient_responsibility_flag = vc
     2 payor_id = f8
     2 payor_type_cd = f8
     2 perf_loc_cd = f8
     2 perf_phys_id = f8
     2 posted_cd = f8
     2 posted_dt_tm = dq8
     2 posted_tz = i2
     2 process_flag = vc
     2 ref_phys_id = f8
     2 server_process_flag = vc
     2 service_dt_tm = dq8
     2 service_tz = i2
     2 start_dt_tm = dq8
     2 start_tz = i2
     2 stop_dt_tm = dq8
     2 stop_tz = i2
     2 tier_group_cd = f8
     2 verify_phys_id = f8
     2 updt_id = f8
     2 poster_supervisor_id = f8
     2 gl_account_sk = vc
     2 gl_rsp_unit_sk = vc
     2 total_charge_amount = f8
     2 gl_interface_dt_tm = dq8
     2 gl_interface_tz = i2
     2 hcpcs_nomen_id = f8
     2 cpt_nomen_id = f8
     2 icd9_nomen_id = f8
     2 revenue_code = f8
     2 cdm_code = vc
     2 billing_amount = vc
     2 billing_quantity = vc
     2 billing_entity_id = f8
     2 client_org_id = f8
     2 collection_priority_cd = f8
     2 cr_acct_id = f8
     2 dr_acct_id = f8
     2 late_chrg_flag = vc
     2 pft_charge_status_cd = f8
     2 pft_charge_status_reason_cd = f8
     2 interface_file_id = f8
     2 gl_trans_log_id = f8
     2 charge_active_ind = i2
     2 charge_item_id = f8
     2 charge_event_id = f8
     2 cdm_nomen_id = f8
     2 credit_nomen_id = f8
     2 credit_note_txt = vc
     2 credit_reason = f8
     2 credit_prsnl = f8
     2 fin_class_cd = f8
     2 ord_phys_id = f8
     2 activity_dt_tm = dq8
     2 activity_tz = i2
     2 hcpcs_charge_mod_id = f8
     2 cpt_charge_mod_id = f8
     2 icd9_charge_mod_id = f8
     2 cdm_charge_mod_id = f8
     2 credit_charge_mod_id = f8
     2 activity_id = f8
 )
 RECORD fin_charge_encntr_parents(
   1 qual[*]
     2 pft_encntr_id = f8
 )
 RECORD fin_charge_item_encntr_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD billing_entity_keys(
   1 qual[*]
     2 billing_entity_sk = f8
 )
 RECORD billing_entity(
   1 qual[*]
     2 billing_entity_sk = f8
     2 billing_entity_name = vc
     2 billing_entity_desc = vc
     2 parent_billing_entity_sk = f8
     2 delivery_system_name = vc
     2 default_ar_account_sk = f8
     2 bad_debt_check_flg = i2
     2 calculated_balance_flg = i2
     2 currency_type_ref = f8
     2 current_seq = f8
     2 late_charge_eval_day_nbr = i4
     2 default_selfpay_hlthplan = f8
     2 default_posting_method_ref = f8
     2 view_historical_encntr_flg = i2
     2 fee_scheduled_flg = vc
     2 fiscal_reporting_flg = i4
     2 hcfa_1500_dx_flg = vc
     2 place_of_service = vc
     2 application_by_proc_coding_flg = vc
     2 processed_by_proc_coding_flg = i2
     2 program_ref = f8
     2 reclass_ar_flg = i4
     2 recur_bill_opt_flg = vc
     2 prior_month_recur_bill_day = vc
     2 recur_bill_gen_delay_day_nbr = vc
     2 recur_bill_gen_flg = vc
     2 recur_wait_code_flg = vc
     2 rug_order_flg = vc
     2 seq_start_nbr = i4
     2 std_delay_day_nbr = vc
     2 deb_credit_offset_visible_flg = i2
     2 zero_balance_wait_day_nbr = i4
     2 deliverysystemid = i4
     2 billing_entity_type_flg = f8
     2 src_active_ind = vc
     2 acute_care_ind = i4
     2 acute_care_lt_encntr_ind = vc
     2 home_health_ind = i4
     2 home_health_lt_encntr_ind = vc
     2 lab_ind = i4
     2 lab_lt_encntr_ind = vc
     2 pharmacy_ind = i4
     2 pharmacy_lt_encntr_ind = vc
     2 physician_office_ind = i4
     2 pco_lt_encntr_ind = vc
     2 skilled_office_ind = i4
     2 skilled_office_lt_encntr_ind = vc
     2 special_facility_ind = i4
     2 special_facility_lt_encntr_ind = vc
     2 application_post_method_ref = f8
     2 billing_entity_org = f8
 )
 RECORD media_master_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD edw_media_master_keys(
   1 qual[*]
     2 media_master_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 encounter_nk = vc
 )
 RECORD media_master(
   1 qual[*]
     2 media_master_sk = f8
     2 person_sk = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 media_master_org = f8
     2 media_type_ref = f8
     2 parent_media_master_sk = f8
     2 loc_facility_cd = f8
     2 permanent_loc_ref = i4
     2 current_loc_ref = f8
     2 create_dt_tm = dq8
     2 create_dt_tm_zn = f8
     2 create_dt_tm_vld_flg = f8
     2 create_prsnl = f8
     2 return_loc_ref = f8
     2 media_status_ref = f8
     2 episode = f8
     2 volume_nbr = f8
     2 storage_ref = f8
     2 movement_dt_tm = dq8
     2 movement_dt_tm_zn = f8
     2 movement_dt_tm_vld_flg = f8
     2 src_beg_effective_dt_tm = dq8
     2 src_beg_effective_dt_tm_zn = f8
     2 src_beg_effective_dt_tm_vld_flg = f8
     2 src_end_effective_dt_tm = dq8
     2 src_end_effective_dt_tm_zn = f8
     2 src_end_effective_dt_tm_vld_flg = f8
     2 active_ind = f8
     2 prev_internal_loc_ref = f8
     2 contributor_system_ref = f8
     2 frame = vc
     2 freetext_roll_frame = vc
     2 media_comment = vc
     2 roll = vc
     2 source_flg = f8
     2 extract_dt_tm = dq8
 )
 RECORD edw_him_request_patient_parents(
   1 qual[*]
     2 him_request_sk = f8
 )
 RECORD edw_him_request_patient_encntr_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD edw_him_request_patient_keys(
   1 qual[*]
     2 him_request_patient_sk = f8
     2 encntr_id = f8
     2 him_request_sk = f8
     2 loc_facility_cd = f8
     2 encounter_nk = vc
 )
 RECORD edw_him_request_patient(
   1 qual[*]
     2 him_request_patient_sk = f8
     2 him_request_sk = f8
     2 request_status_ref = f8
     2 request_status_dt_tm = dq8
     2 request_status_dt_tm_zn = f8
     2 request_status_prsnl_sk = f8
     2 approval_ind = f8
     2 src_beg_effective_dt_tm = dq8
     2 src_beg_effective_dt_tm_zn = f8
     2 src_end_effective_dt_tm = dq8
     2 src_end_effective_dt_tm_zn = f8
     2 person_sk = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 create_prsnl_sk = f8
     2 last_update_prsnl_sk = f8
     2 cancel_prsnl_sk = f8
     2 rejected_reason_ref = f8
     2 authorized_ind = f8
     2 authorized_reject_reason_ref = f8
     2 active_ind = f8
 )
 RECORD edw_him_request_keys(
   1 qual[*]
     2 him_request_sk = f8
 )
 RECORD edw_him_request(
   1 qual[*]
     2 him_request_sk = f8
     2 request_type_ref = f8
     2 request_status_ref = f8
     2 request_status_prsnl_sk = f8
     2 requester_sk = f8
     2 requester_nbr = f8
     2 requester_nbr_pool_ref = f8
     2 to_loc_ref = f8
     2 create_prsnl_sk = f8
     2 last_update_prsnl_sk = f8
     2 cancel_prsnl_sk = f8
     2 active_ind = f8
     2 phone_sk = f8
     2 contributor_system_ref = f8
     2 pull_list_printed_ind = f8
     2 locked_ind = f8
     2 org_sk = f8
     2 roi_requester_id = f8
     2 sch_event_sk = f8
     2 onsite_ind = f8
     2 required_dt_tm = dq8
     2 required_dt_tm_zn = f8
     2 request_status_dt_tm = dq8
     2 request_status_dt_tm_zn = f8
     2 src_beg_effective_dt_tm = dq8
     2 src_beg_effective_dt_tm_zn = f8
     2 src_end_effective_dt_tm = dq8
     2 src_end_effective_dt_tm_zn = f8
     2 pull_list_printed_dt_tm = dq8
     2 pull_list_printed_dt_tm_zn = f8
     2 request_dt_tm = dq8
     2 request_dt_tm_zn = f8
 )
 RECORD edw_pm_post_doc_keys(
   1 qual[*]
     2 pm_post_doc_id = f8
 )
 RECORD edw_pm_post_doc(
   1 qual[*]
     2 pm_post_doc_sk = f8
     2 pm_post_doc_ref_sk = f8
     2 parent_entity_name = vc
     2 parent_entity_sk = f8
     2 print_dt_tm = dq8
     2 print_tm_zn = i4
     2 manual_create_ind = f8
     2 create_dt_tm = dq8
     2 create_tm_zn = i4
     2 create_prsnl_sk = f8
     2 active_dt_tm = dq8
     2 active_tm_zn = i4
     2 src_active_ind = i2
 )
 RECORD ce_spec(
   1 qual[*]
     2 event_id = f8
     2 collect_dt_tm = dq8
     2 collect_tm_zn = i4
     2 collect_method_cd = f8
     2 collect_loc_cd = f8
     2 collect_prsnl_id = f8
     2 collect_volume = f8
     2 collect_unit_cd = f8
     2 collect_priority_cd = f8
     2 container_type_cd = f8
     2 danger_cd = f8
     2 positive_ind = f8
     2 source_type_cd = f8
     2 source_text = vc
     2 specimen_status_cd = f8
     2 valid_from_dt_tm = dq8
     2 valid_from_tm_zn = i4
     2 loc_facility_cd = f8
     2 encntr_id = f8
     2 valid_from_dt_tm = dq8
     2 valid_from_tm_zn = i4
     2 body_site_cd = f8
     2 received_dt_tm = dq8
     2 received_tm_zn = i4
     2 active_ind = f8
 )
 RECORD ce_spec_keys(
   1 qual[*]
     2 event_id = f8
 )
 RECORD ce_spec_parent_keys(
   1 qual[*]
     2 event_id = f8
 )
 RECORD workload_keys(
   1 qual[*]
     2 workload_id = f8
     2 charge_event_id = f8
 )
 RECORD edw_workload(
   1 qual[*]
     2 workload_sk = f8
     2 charge_event_sk = f8
     2 workload_code = vc
     2 workload_desc = vc
     2 workload_multiplier = f8
     2 workload_type_ref = f8
     2 workload_quantity = f8
     2 workload_units = f8
     2 workload_extended_units = f8
     2 item_for_count_ref = f8
     2 bill_item_sk = f8
     2 active_ind = f8
 )
 RECORD fin_workload_charge_event_parents(
   1 qual[*]
     2 charge_event_id = f8
 )
 RECORD charge_event_keys(
   1 qual[*]
     2 charge_event_id = f8
     2 encounter_id = f8
     2 encounter_nk = vc
 )
 RECORD edw_charge_event(
   1 qual[*]
     2 fin_charge_event_sk = f8
     2 encounter_sk = f8
     2 encounter_nk = vc
     2 loc_facility_cd = f8
     2 encounter_sk = f8
     2 encounter_nk = f8
     2 master_charge_event_sk = f8
     2 primary_charge_event_sk = f8
     2 bill_item_sk = f8
     2 master_bill_item_sk = f8
     2 primary_bill_item_sk = f8
     2 order_sk = f8
     2 contributor_system_ref = f8
     2 person_sk = f8
     2 collection_priority_ref = f8
     2 report_priority_ref = f8
     2 perf_location_ref = f8
     2 charge_event_hlthpln = f8
     2 epsdt_ind = vc
     2 cancelled_ind = vc
     2 cancelled_dt_tm = dq8
     2 cancelled_tm_zn = dq8
     2 cancelled_prsnl = f8
     2 ordered_prsnl = f8
     2 abn_status_ref = f8
     2 accession = vc
     2 active_ind = vc
 )
 RECORD fin_charge_event_encounter_parents(
   1 qual[*]
     2 encounter_id = f8
 )
 RECORD ord_comp_keys(
   1 qual[*]
     2 order_comp_detail_id = f8
     2 order_comp_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 encntr_nk = vc
 )
 RECORD edw_order_comp(
   1 qual[*]
     2 order_comp_detail_id = f8
     2 order_comp_id = f8
     2 loc_facility_cd = f8
     2 encntr_id = f8
     2 encntr_nk = vc
     2 order_nbr = f8
     2 performed_prsnl_id = f8
     2 performed_dt_tm = dq8
     2 performed_tm_zn = i2
     2 encntr_compliance_status_flag = vc
     2 no_known_home_meds_ind = vc
     2 unable_to_obtain_ind = vc
     2 compliance_capture_dt_tm = dq8
     2 compliance_capture_tm_zn = i2
     2 last_occured_dt_tm = dq8
     2 last_occured_tm_zn = i2
     2 updt_dt_tm = dq8
     2 updt_tm_zn = i2
     2 updt_id = f8
     2 compliance_status_cd = f8
     2 information_source_cd = f8
     2 long_text = vc
     2 long_text_id = f8
 )
 RECORD ord_comp_order_parents(
   1 qual[*]
     2 order_id = f8
 )
 RECORD ord_comp_encntr_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD ord_recon_keys(
   1 qual[*]
     2 order_recon_detail_id = f8
     2 order_recon_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 encntr_nk = vc
 )
 RECORD edw_order_recon(
   1 qual[*]
     2 order_recon_detail_id = f8
     2 order_recon_id = f8
     2 loc_facility_cd = f8
     2 encntr_id = f8
     2 encntr_nk = vc
     2 order_nbr = f8
     2 order_mnemonic = vc
     2 performed_prsnl_id = f8
     2 performed_dt_tm = dq8
     2 performed_tm_zn = i2
     2 updt_dt_tm = dq8
     2 updt_tm_zn = i2
     2 updt_id = f8
     2 recon_type_flg = vc
     2 no_known_meds_ind = vc
     2 clinical_display_line = vc
     2 simplified_display_line = vc
     2 continue_order_ind = vc
     2 recon_order_action_meaning = vc
 )
 RECORD ord_recon_order_parents(
   1 qual[*]
     2 order_id = f8
 )
 RECORD ord_recon_encntr_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD ce_assoc(
   1 qual[*]
     2 ref_cd_map_detail_id = f8
     2 event_id = f8
     2 parent_ref_cd_map_detail_id = f8
     2 reference_nbr = vc
     2 nomenclature_id = f8
     2 entity_column_value = f8
     2 entity_cd = f8
     2 assignment_method_cd = f8
     2 active_ind = f8
 )
 RECORD ce_assoc_keys(
   1 qual[*]
     2 ref_cd_map_detail_id = f8
 )
 RECORD ce_assoc_parent_keys(
   1 qual[*]
     2 event_id = f8
 )
 IF (validate(pers_prsnl_org_reltn_keys)=0)
  RECORD pers_prsnl_org_reltn_keys(
    1 qual[*]
      2 per_prsnl_reltn_id = f8
  )
 ENDIF
 IF (validate(edw_pers_prsnl_org_reltn)=0)
  RECORD edw_pers_prsnl_org_reltn(
    1 qual[*]
      2 per_prsnl_reltn_id = f8
      2 per_prsnl_org_reltn_sk = vc
      2 per_prsnl_reltn_id = f8
      2 person_id = f8
      2 related_prsnl = f8
      2 relationship_type_ref = f8
      2 org_alias_type_ref = f8
      2 organization_id = f8
      2 parent_organization_id = f8
      2 primary_care_ref = f8
      2 src_beg_effective_dt_tm = dq8
      2 src_end_effective_dt_tm = dq8
      2 src_updt_dt_tm = dq8
      2 active_ind = i2
  )
 ENDIF
 RECORD rad_exam_keys(
   1 qual[*]
     2 rad_exam_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD rad_exam_info(
   1 qual[*]
     2 rad_exam_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 rad_order_sk = f8
     2 task_assay_sk = f8
     2 svc_res_dept_hier_sk = f8
     2 exam_desc = vc
     2 exam_seq = f8
     2 exam_primary_prsnl = f8
     2 sched_req_dt_tm = dq8
     2 sched_req_tm_zn = i2
     2 starting_dt_tm = dq8
     2 starting_tm_zn = i2
     2 complete_dt_tm = dq8
     2 complete_tm_zn = i2
     2 required_ind = vc
     2 quantity = f8
     2 credit_ind = vc
     2 charges_sent_ind = vc
 )
 RECORD rad_exam_parent_order_keys(
   1 qual[*]
     2 order_id = f8
 )
 RECORD rad_report_keys(
   1 qual[*]
     2 rad_report_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD rad_report_info(
   1 qual[*]
     2 rad_report_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 rad_order_sk = f8
     2 classification_ref = f8
     2 report_creation_mthd_ref = f8
     2 scd_story_sk = f8
     2 dictated_by_prsnl = f8
     2 prev_owner_prsnl = f8
     2 rad_rpt_reference_nbr = vc
     2 no_proxy_ind = vc
     2 redictate_ind = vc
     2 modified_ind = vc
     2 res_queue_ind = vc
     2 addendum_ind = vc
     2 batch_sign_ind = vc
     2 charges_sent_ind = vc
     2 report_seq = f8
     2 org_trans_dt_tm = dq8
     2 org_trans_tm_zn = i2
     2 final_dt_tm = dq8
     2 final_tm_zn = i2
     2 dictated_dt_tm = dq8
     2 dictated_tm_zn = i2
     2 posted_final_dt_tm = dq8
     2 posted_final_tm_zn = i2
     2 ret_to_res_dt_tm = dq8
     2 ret_to_res_tm_zn = i2
     2 voice_del_succ_dt_tm = dq8
     2 voice_del_succ_tm_zn = i2
     2 voice_del_atmt_dt_tm = dq8
     2 voice_del_atmt_tm_zn = i2
 )
 RECORD rad_report_parent_order_keys(
   1 qual[*]
     2 order_id = f8
 )
 RECORD ent_position(
   1 qual[*]
     2 etr_location_change_log_id = f8
     2 enterprise_position_sk = vc
     2 eps_trackable_sk = f8
     2 parent_entity_name = vc
     2 parent_entity_sk = f8
     2 tracking_start_dt_tm = dq8
     2 tracking_start_tm_zn = i4
     2 tracking_end_dt_tm = dq8
     2 tracking_end_tm_zn = i4
     2 person_sk = f8
     2 tracked_prsnl = f8
     2 to_loc = f8
     2 to_arrival_dt_tm = dq8
     2 to_arrive_tm_zn = i4
     2 to_depart_dt_tm = dq8
     2 to_depart_tm_zn = i4
     2 manual_ind = i2
     2 from_enter_position_sk = vc
     2 from_loc = f8
     2 from_depart_dt_tm = dq8
     2 from_depart_tm_zn = i4
     2 initial_loc = f8
     2 initial_arrival_dt_tm = dq8
     2 initial_arrival_tm_zn = i4
     2 final_loc = f8
     2 final_depart_dt_tm = dq8
     2 final_depart_tm_zn = i4
 )
 RECORD etr_location_change_log_keys(
   1 qual[*]
     2 etr_location_change_log_id = f8
 )
 RECORD ce_microbiology(
   1 qual[*]
     2 event_id = f8
     2 ce_microbiology_sk = vc
     2 micro_seq_nbr = f8
     2 organism_cd = f8
     2 organism_occurrence_nbr = f8
     2 organism_type_cd = f8
     2 observation_prsnl_id = f8
     2 biotype = vc
     2 positive_ind = f8
     2 active_ind = f8
 )
 RECORD ce_microbiology_keys(
   1 qual[*]
     2 event_id = f8
     2 micro_seq_nbr = f8
 )
 RECORD ce_microbiology_parent_keys(
   1 qual[*]
     2 event_id = f8
 )
 RECORD ce_sus(
   1 qual[*]
     2 ce_susceptibility_sk = vc
     2 ce_microbiology_sk = vc
     2 event_id = f8
     2 micro_seq_nbr = f8
     2 suscep_seq_nbr = f8
     2 susceptibility_test_ref = f8
     2 detail_susceptibility_ref = f8
     2 panel_antibiotic_ref = f8
     2 antibiotic_ref = f8
     2 diluent_volume = f8
     2 result_ref = f8
     2 result_text_value = vc
     2 result_numeric_value = f8
     2 result_unit_ref = f8
     2 result_dt_tm = dq8
     2 result_tm_zn = i4
     2 result_prsnl_id = f8
     2 susceptibility_status_ref = f8
     2 abnormal_flag = f8
     2 chartable_flag = f8
     2 nomenclature_ref = f8
     2 antibiotic_note = vc
     2 loc_facility_cd = f8
     2 encntr_id = f8
     2 active_ind = f8
 )
 RECORD ce_sus_keys(
   1 qual[*]
     2 event_id = f8
     2 micro_seq_nbr = f8
     2 suscep_seq_nbr = f8
 )
 RECORD ce_sus_parent_keys(
   1 qual[*]
     2 event_id = f8
     2 micro_seq_nbr = f8
 )
 RECORD pregnancy_keys(
   1 qual[*]
     2 pregnancy_inst_sk = f8
 )
 RECORD edw_pregnancy(
   1 qual[*]
     2 pregnancy_inst_sk = f8
     2 parent_pregnancy_sk = f8
     2 person_sk = f8
     2 problem_sk = f8
     2 pregnancy_org = f8
     2 sensitive_ind = vc
     2 preg_start_dt_tm = dq8
     2 preg_start_tm_zn = i2
     2 preg_end_dt_tm = dq8
     2 preg_end_tm_zn = i2
     2 override_comment = vc
     2 confirmed_dt_tm = dq8
     2 confirmed_tm_zn = i2
     2 confirmation_method_ref = f8
     2 historical_ind = vc
     2 src_active_ind = vc
     2 src_beg_effective_dt_tm = dq8
     2 src_end_effective_dt_tm = dq8
     2 src_tz = i2
     2 create_dt_tm = dq8
     2 create_tm_zn = i2
     2 create_prsnl = f8
     2 review_dt_tm = dq8
     2 review_tm_zn = i2
     2 review_prsnl = f8
     2 cancel_dt_tm = dq8
     2 cancel_tm_zn = i2
     2 cancel_prsnl = f8
     2 labor_start_dt_tm = dq8
     2 labor_start_tm_zn = i2
     2 labor_start_prsnl = f8
     2 labor_cancel_dt_tm = dq8
     2 labor_cancel_tm_zn = i2
     2 labor_cancel_prsnl = f8
     2 delete_dt_tm = dq8
     2 delete_tm_zn = i2
     2 delete_prsnl = f8
 )
 RECORD pregnancy_child_keys(
   1 qual[*]
     2 pregnancy_child_sk = f8
 )
 RECORD edw_pregnancy_child(
   1 qual[*]
     2 pregnancy_child_sk = f8
     2 pregnancy_inst_sk = f8
     2 gender_ref = f8
     2 child_name = vc
     2 child_person_sk = f8
     2 father_name = vc
     2 delivery_method_ref = f8
     2 delivery_hospital = vc
     2 gestation_age = f8
     2 weight_amt = f8
     2 weight_unit_ref = f8
     2 anesthesia_txt = vc
     2 preterm_labor_txt = vc
     2 delivery_dt_tm = dq8
     2 delivery_tm_zn = i2
     2 neonate_outcome_ref = f8
     2 child_long_text_sk = f8
     2 src_active_ind = vc
     2 src_beg_effective_dt_tm = dq8
     2 src_end_effective_dt_tm = dq8
     2 src_tz = i2
     2 labor_duration = f8
     2 delivery_date_precision_flg = f8
     2 delivery_date_qualifier_flg = f8
     2 restrict_person_ind = vc
     2 newborn_complication_nomen = f8
     2 newborn_complication_long_text_sk = f8
     2 anesthesia_ref = f8
     2 mother_complication_nomen = f8
     2 mother_complication_long_text_sk = f8
     2 preterm_labor_ref = f8
     2 fetus_complication_nomen = f8
     2 fetus_complication_long_text_sk = f8
     2 pregnancy_sk = f8
 )
 RECORD pregnancy_child_parent_keys(
   1 qual[*]
     2 pregnancy_inst_sk = f8
 )
 RECORD preg_detail_keys(
   1 qual[*]
     2 pregnancy_detail_id = f8
     2 pregnancy_estimate_id = f8
 )
 RECORD edw_preg_detail(
   1 qual[*]
     2 pregnancy_detail_sk = f8
     2 pregnancy_estimate_sk = f8
     2 lmp_symptoms_txt = vc
     2 pregnancy_test_dt_tm = dq8
     2 contraception_ind = vc
     2 contraception_duration = f8
     2 breastfeeding_ind = vc
     2 menarche_age = f8
     2 menstrual_freq = f8
     2 prior_menses_dt_tm = dq8
     2 time_zone = i4
     2 src_active_ind = vc
 )
 RECORD preg_det_preg_est_parents(
   1 qual[*]
     2 pregnancy_estimate_id = f8
 )
 RECORD preg_estimate_keys(
   1 qual[*]
     2 pregnancy_estimate_id = f8
     2 pregnancy_id = f8
 )
 RECORD edw_preg_estimate(
   1 qual[*]
     2 pregnancy_estimate_sk = f8
     2 pregnancy_inst_sk = f8
     2 prev_preg_estimate_sk = f8
     2 status_flg = f8
     2 method_ref = f8
     2 descriptor_ref = f8
     2 descriptor_txt = vc
     2 descriptor_flg = f8
     2 edd_long_text_sk = f8
     2 method_dt_tm = dq8
     2 crown_rump_length = f8
     2 biparietal_diameter = f8
     2 head_circumference = f8
     2 est_gest_age_days = f8
     2 est_delivery_dt_tm = dq8
     2 confirmation_ref = f8
     2 author_prsnl = f8
     2 entered_dt_tm = dq8
     2 time_zone = i4
     2 src_active_ind = vc
 )
 RECORD preg_est_preg_inst_parents(
   1 qual[*]
     2 pregnancy_inst_id = f8
 )
 RECORD shx_comment_keys(
   1 qual[*]
     2 shx_comment_inst_sk = f8
 )
 RECORD edw_shx_comment(
   1 qual[*]
     2 shx_comment_inst_sk = f8
     2 shx_activity_sk = f8
     2 shx_activity_group_sk = f8
     2 long_text_sk = f8
     2 comment_prsnl_sk = f8
     2 comment_dt_tm = dq8
     2 comment_tm_zn = i2
     2 active_ind = i2
 )
 RECORD shx_comment_parent_keys(
   1 qual[*]
     2 shx_comment_inst_sk = f8
 )
 RECORD shx_response_keys(
   1 qual[*]
     2 shx_response_inst_sk = f8
     2 shx_alpha_response_inst_sk = f8
 )
 RECORD edw_shx_response(
   1 qual[*]
     2 response_sk = f8
     2 shx_alpha_response_sk = f8
     2 shx_activity_sk = f8
     2 response_modifier_flag = i2
     2 response_type = vc
     2 response_unit_ref = f8
     2 response_val = vc
     2 task_assay_sk = f8
     2 alpha_response_nomen = f8
     2 other_txt = vc
     2 active_ind = i2
 )
 RECORD shx_response_parent_keys(
   1 qual[*]
     2 shx_response_inst_sk = f8
 )
 RECORD shx_element_keys(
   1 qual[*]
     2 shx_element_inst_sk = f8
 )
 RECORD edw_shx_element(
   1 qual[*]
     2 shx_element_inst_sk = f8
     2 shx_category_sk = f8
     2 category_ref = f8
     2 element_desc = vc
     2 category_comment_ind = f8
     2 input_type_ref = f8
     2 element_task_assay_sk = f8
     2 response_label = vc
     2 response_label_layout_flg = i2
     2 element_seq = f8
     2 required_ind = i2
 )
 RECORD shx_activity_keys(
   1 qual[*]
     2 shx_activity_inst_sk = f8
 )
 RECORD edw_shx_activity(
   1 qual[*]
     2 shx_activity_inst_sk = f8
     2 shx_activity_group_sk = f8
     2 person_sk = f8
     2 shx_activity_org = f8
     2 long_text_sk = f8
     2 shx_category_sk = f8
     2 perform_dt_tm = dq8
     2 perform_tm_zn = i2
     2 assessment_ref = f8
     2 status_ref = f8
     2 type_mean = vc
     2 unable_to_obtain_ind = i2
     2 active_ind = i2
     2 create_prsnl = f8
     2 create_dt_tm = dq8
     2 create_tm_zn = i2
     2 last_modified_prsnl = f8
     2 last_modified_dt_tm = dq8
     2 last_modified_tm_zn = i2
     2 error_prsnl = f8
     2 error_dt_tm = dq8
     2 error_tm_zn = i2
     2 last_review_prsnl = f8
     2 last_review_dt_tm = dq8
     2 last_review_tm_zn = i2
 )
 RECORD application_keys(
   1 qual[*]
     2 application_inst_sk = f8
 )
 RECORD edw_application(
   1 qual[*]
     2 application_inst_sk = f8
     2 application_owner = vc
     2 application_desc = vc
     2 application_ft_desc = vc
     2 application_name = vc
     2 common_application_ind = i2
 )
 RECORD application_context_keys(
   1 qual[*]
     2 application_context_inst_sk = f8
 )
 RECORD edw_application_context(
   1 qual[*]
     2 application_context_inst_sk = f8
     2 application_sk = f8
     2 activity_prsnl = f8
     2 activity_tran_prsnl = f8
     2 application_username = vc
     2 activity_position_ref = f8
     2 start_dt_tm = dq8
     2 start_tm_zn = i2
     2 end_dt_tm = dq8
     2 end_tm_zn = i2
     2 application_image = vc
     2 application_dir = vc
     2 application_status = f8
     2 device_location = vc
     2 authorization_ind = i2
     2 application_version = vc
     2 client_start_dt_tm = dq8
     2 client_tz = i2
 )
 RECORD order_container_keys(
   1 qual[*]
     2 order_sk = f8
     2 container_sk = f8
     2 event_seq = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 encntr_nk = vc
 )
 RECORD edw_order_container(
   1 qual[*]
     2 order_sk = f8
     2 container_sk = f8
     2 encntr_sk = f8
     2 loc_facility_cd = f8
     2 encntr_nk = vc
     2 parent_container_sk = f8
     2 event_sequence_nbr = f8
     2 event_type_ref = f8
     2 coll_status_flg = vc
     2 reason_missed_ref = f8
     2 reason_missed_prsnl = f8
     2 additional_labels = vc
     2 specimen_type_ref = f8
     2 specimen_container_ref = f8
     2 specimen_handle_ref = f8
     2 drawn_dt_tm = dq8
     2 drawn_tm_zn = i4
     2 drawn_prsnl = f8
     2 label_dt_tm = dq8
     2 label_tm_zn = i4
     2 received_dt_tm = dq8
     2 received_tm_zn = i4
     2 received_prsnl = f8
     2 volume = f8
     2 remaining_volume = f8
     2 volume_units_ref = f8
 )
 RECORD order_container_parent_keys(
   1 qual[*]
     2 order_id = f8
 )
 RECORD question_keys(
   1 qual[*]
     2 question_inst_sk = f8
 )
 RECORD edw_question(
   1 qual[*]
     2 qst_question_inst_sk = f8
     2 entity_name = vc
     2 questionnaire_name = vc
     2 questionnaire_type_flg = i2
     2 questionnaire_cond = vc
     2 question_parent_value = vc
     2 question_parent_sk = f8
     2 question_meaning = vc
     2 question_seq = i2
     2 quest_txt = vc
     2 question_type = vc
 )
 RECORD answer_keys(
   1 qual[*]
     2 answer_inst_sk = f8
 )
 RECORD edw_answer(
   1 qual[*]
     2 qst_answer_inst_sk = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 parent_entity_name = vc
     2 parent_entity_sk = f8
     2 qst_question_sk = f8
     2 value_ref = f8
     2 value_chc = f8
     2 value_dt_tm = dq8
     2 value_tm_zn = i2
     2 value_ind = i2
     2 value_nbr = f8
     2 value_txt = vc
     2 string_value = vc
     2 value_data_type = vc
     2 value_type = vc
     2 encounter_id = f8
     2 loc_facility_cd = f8
     2 active_ind = i2
     2 value_cd_set = f8
 )
 RECORD answer_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
 )
 RECORD vendor_keys(
   1 qual[*]
     2 vendor_inst_sk = f8
     2 site_inst_sk = f8
     2 item_inst_sk = f8
 )
 RECORD edw_vendor(
   1 qual[*]
     2 vendor_inst_sk = f8
     2 vendor_site_sk = f8
     2 item_sk = f8
     2 vendor_disp = vc
     2 vendor_desc = vc
     2 vendor_type_ref = f8
     2 vendor_type_disp = vc
     2 approved_vendor_status_ref = f8
     2 approved_vendor_status_disp = vc
     2 output_dest_sk = f8
     2 logical_domain_sk = f8
     2 min_order_cost = f8
     2 vendor_nbr = f8
     2 tax_payer_nbr = vc
     2 backorder_ind = f8
     2 consolidate_rqstn_ind = i2
     2 acknowledgement_ind = i2
     2 auto_commit_po_ind = i2
     2 auto_commit_receipt_ind = i2
     2 tax_exempt_ind = i2
     2 vendor_active_ind = i2
     2 vendor_active_type_ref = f8
     2 vendor_active_type_display = vc
     2 vendor_active_dt_tm = dq8
     2 vendor_active_tm_zn = i2
     2 vendor_ref = f8
     2 vendor_price_schedule_sk = f8
     2 vendor_site_account_number = vc
     2 vendor_site_description = vc
     2 freight_terms_ref = f8
     2 freight_terms_disp = vc
     2 payment_terms_ref = f8
     2 payment_terms_disp = vc
     2 po_print_format_ref = f8
     2 po_print_format_disp = vc
     2 po_transmit_type_ref = f8
     2 po_transmit_type_disp = vc
     2 ship_via_ref = f8
     2 ship_via_disp = vc
     2 vendor_item_lead_time = f8
     2 vendor_item_lead_time_uom_ref = f8
     2 vendor_item_lead_time_uom_disp = vc
     2 price_review_ind = i2
 )
 RECORD item_loc_keys(
   1 qual[*]
     2 item_sk = f8
     2 item_loc = f8
     2 locator_ref = f8
     2 relationship_type_ref = f8
     2 package_type_sk = f8
 )
 RECORD edw_item_loc(
   1 qual[*]
     2 item_sk = f8
     2 item_loc = f8
     2 locator_ref = f8
     2 package_type_sk = f8
     2 relationship_type_ref = f8
     2 average_item_cost = f8
     2 standard_item_cost = f8
     2 manufacturer_retail_cost = f8
     2 qoh_type_ref = f8
     2 qoh_qty = f8
     2 acc_stockout_freq_ref = f8
     2 avg_daily_usage = vc
     2 avg_weeks_order_qty = vc
     2 fixed_order_qty = f8
     2 last_syscalc_dt_tm = dq8
     2 last_syscalc_tm_zn = vc
     2 locator_qty = f8
     2 locator_type_ref = f8
     2 lock_ind = i2
     2 maximum_lvl = vc
     2 max_days_adu = vc
     2 minimum_lvl = vc
     2 min_days_adu = vc
     2 reorder_method_ref = f8
     2 reorder_point = vc
     2 reorder_type_ref = f8
     2 safety_stock_qty = vc
     2 seasonal_item_ind = vc
     2 syscalc_abc_class_ind = vc
     2 syscalc_freq_nbr_days = vc
     2 syscalc_par_lvl_ind = vc
     2 syscalc_reorder_point_ind = vc
     2 syscalc_safety_stock_ind = vc
     2 abc_class_ref = f8
     2 charge_type_ref = f8
     2 cost_center_ref = f8
     2 countback_flg = f8
     2 count_cycle_ref = f8
     2 first_dose_flg = vc
     2 instance_ind = vc
     2 list_role_sk = f8
     2 lot_tracking_lvl_ref = f8
     2 override_clsfctn_ref = f8
     2 sch_qty = vc
     2 sch_role_ref = f8
     2 stock_package_type_sk = f8
     2 stock_type_ind = vc
     2 sub_account_ref = f8
     2 average_lead_time = vc
     2 average_lead_time_uom_ref = f8
     2 consignment_ind = vc
     2 economic_order_qty = vc
     2 fill_loc = f8
     2 primary_vendor_sk = f8
     2 primary_vendor_item_sk = f8
     2 product_origin_ref = f8
     2 reorder_package_type_sk = f8
     2 syscalc_eoq_ind = vc
     2 vendor_site_sk = f8
 )
 RECORD pmoffer_keys(
   1 qual[*]
     2 pmoffer_inst_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 encntr_nk = vc
 )
 RECORD edw_pmoffer(
   1 qual[*]
     2 pmoffer_inst_sk = f8
     2 encounter_sk = f8
     2 encounter_nk = vc
     2 loc_facility_cd = f8
     2 schedule_id = f8
     2 offer_type_cd = f8
     2 offer_made_dt_tm = dq8
     2 offer_dt_tm = dq8
     2 reasonable_offer_ind = i2
     2 tci_dt_tm = dq8
     2 admit_offer_outcome_cd = f8
     2 attendance_cd = f8
     2 outcome_of_attendance_cd = f8
     2 sch_reason_cd = f8
     2 remove_from_wl_ind = i2
     2 wl_reason_for_removal_cd = f8
     2 wl_removal_dt_tm = dq8
     2 arrived_on_time_ind = i2
     2 active_ind = i2
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 active_status_cd = f8
     2 pat_initiated_ind = i2
     2 cancel_dt_tm = dq8
     2 dna_dt_tm = dq8
     2 appt_dt_tm = dq8
     2 encounter_id = f8
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 time_zone = i2
     2 archive_ind = i2
 )
 RECORD pmoffer_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
 )
 RECORD hm_expect_keys(
   1 qual[*]
     2 hm_expect_inst_sk = f8
     2 hm_expect_series_sk = f8
     2 hm_expect_sched_sk = f8
 )
 RECORD edw_hm_expect(
   1 qual[*]
     2 hm_expect_inst_sk = f8
     2 expect_meaning = vc
     2 expect_name = vc
     2 always_count_hist_ind = i2
     2 interval_only_ind = i2
     2 last_action_seq = f8
     2 max_age = f8
     2 seq_nbr = f8
     2 step_cnt = f8
     2 hm_expect_series_sk = f8
     2 expect_series_name = vc
     2 first_step_age = f8
     2 last_action_seq = f8
     2 priority_meaning = vc
     2 rule_associated_ind = i2
     2 series_meaning = vc
     2 hm_expect_sched_sk = f8
     2 expect_sched_loc = f8
     2 expect_sched_meaning = vc
     2 expect_sched_name = vc
     2 expect_sched_type_flg = f8
     2 last_action_seq = f8
     2 on_time_start_age = f8
     2 sched_level_flg = f8
 )
 RECORD hm_recommend_keys(
   1 qual[*]
     2 hm_recommend_inst_sk = f8
 )
 RECORD edw_hm_recommend(
   1 qual[*]
     2 hm_recommend_inst_sk = f8
     2 person_sk = f8
     2 hm_expect_sk = f8
     2 hm_expect_step_sk = f8
     2 due_override_hm_action_sk = f8
     2 freq_override_hm_action_sk = f8
     2 assigned_by_prsnl = f8
     2 due_dt_tm = dq8
     2 expire_dt_tm = dq8
     2 near_due_dt_tm = dq8
     2 overdue_dt_tm = dq8
     2 qualified_dt_tm = dq8
     2 frequency_val = f8
     2 frequency_unit_ref = f8
     2 expectation_ftdesc = vc
     2 status_flg = i2
     2 first_due_dt_tm = dq8
     2 last_satisfaction_dt_tm = dq8
     2 last_satisfaction_sk = f8
     2 last_satisfaction_source = vc
     2 last_satisfied_by_prsnl = f8
 )
 RECORD hm_recommend_action_keys(
   1 qual[*]
     2 hm_recommend_action_inst_sk = f8
 )
 RECORD edw_hm_recommend_action(
   1 qual[*]
     2 hm_recommend_action_inst_sk = f8
     2 hm_recommend_sk = f8
     2 hm_expect_sat_sk = f8
     2 related_hm_recommend_action_sk = f8
     2 on_behalf_of_prsnl = f8
     2 action_dt_tm = dq8
     2 action_flag = f8
     2 due_dt_tm = dq8
     2 expire_dt_tm = dq8
     2 qualified_dt_tm = dq8
     2 long_text_sk = f8
     2 reason_ref = f8
     2 frequency_val = f8
     2 frequency_unit_ref = f8
     2 expectation_ftdesc = vc
     2 satisfaction_dt_tm = dq8
     2 satisfaction_sk = f8
     2 satisfaction_source = vc
     2 prev_due_dt_tm = dq8
     2 prev_expire_dt_tm = dq8
     2 prev_qualified_dt_tm = dq8
     2 prev_frequency_val = f8
     2 prev_frequency_unit_ref = f8
 )
 RECORD hm_recommend_action_parent_keys(
   1 qual[*]
     2 hm_recommend_action_inst_sk = f8
 )
 RECORD ce_med_evt_keys(
   1 qual[*]
     2 med_key = f8
 )
 RECORD rad_med_evt_keys(
   1 qual[*]
     2 med_evt_key = f8
 )
 RECORD med_admin_evt(
   1 qual[*]
     2 med_evt_key = f8
     2 med_key = f8
     2 order_sk = f8
     2 beg_dt_tm = dq
     2 beg_tm_zn = i4
     2 end_dt_tm = dq
     2 end_tm_zn = i4
     2 careaware_used_ind = i2
     2 clinical_warning_cnt = f8
     2 documentation_action_seq = f8
     2 event_cnt = f8
     2 event_type_ref = f8
     2 needs_verify_flg = i2
     2 nurse_unit_ref = f8
     2 order_result_var_ind = i2
     2 position_ref = f8
     2 positive_med_ident_ind = i2
     2 positive_patient_ident_ind = i2
     2 prsnl_sk = f8
     2 sched_dt_tm = dq
     2 sched_tm_zn = i4
     2 src_app_flg = i4
     2 verification_dt_tm = dq
     2 verification_tm_zn = i4
     2 verified_prsnl_sk = f8
     2 med_admin_event_seq = f8
 )
 RECORD abstract_data_keys(
   1 qual[*]
     2 abstract_data_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 encntr_nk = vc
 )
 RECORD edw_abstract_data(
   1 qual[*]
     2 abstract_data_sk = f8
     2 encounter_sk = f8
     2 encounter_nk = vc
     2 loc_facility_cd = f8
     2 encntr_slice_sk = f8
     2 person_sk = f8
     2 svc_cat_hist_sk = f8
     2 abstract_field_def_ref = f8
     2 abstract_field_type_ref = f8
     2 value_ref = f8
     2 value_code_set = f8
     2 value_dt_tm = dq8
     2 value_tm_zn = i4
     2 value_free_txt = vc
     2 value_nbr = f8
     2 active_ind = i2
 )
 RECORD abstract_data_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
 )
 RECORD pathway_catalog_custm_keys(
   1 qual[*]
     2 pathway_cust_plan_sk = f8
 )
 RECORD edw_get_pathway_custm(
   1 qual[*]
     2 pathway_cust_plan_sk = f8
     2 pathway_catalog_sk = f8
     2 plan_name = vc
     2 create_dt_tm = dq8
     2 status_flg = i4
     2 src_active_ind = i2
     2 customized_prsnl = f8
     2 default_tm_zn = i4
 )
 RECORD task_activity_keys(
   1 qual[*]
     2 task_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 reference_task_id = f8
     2 encntr_nk = vc
 )
 RECORD task_activity_parent_keys(
   1 qual[*]
     2 parent_encntr_id = f8
 )
 RECORD task_activity_info(
   1 qual[*]
     2 task_activity_sk = f8
     2 encntr_nk = vc
     2 encntr_sk = f8
     2 event_sk = f8
     2 order_sk = f8
     2 catalog_ref = f8
     2 catalog_type_ref = f8
     2 charted_by_agent_ref = f8
     2 charted_by_agent_ident = vc
     2 charting_context_reference = vc
     2 comments = vc
     2 confidential_ind = i2
     2 continuous_ind = i2
     2 contributor_system_ref = f8
     2 delivery_ind = i2
     2 event_ref = f8
     2 event_class_ref = f8
     2 external_reference_number = vc
     2 iv_ind = i2
     2 linked_order_ind = i2
     2 location_ref = f8
     2 med_order_type_ref = f8
     2 msg_sender_prsnl = f8
     2 msg_sender_person_sk = f8
     2 msg_subject = vc
     2 msg_subject_ref = f8
     2 email_message_ident = vc
     2 orig_pool_task_sk = f8
     2 performed_prsnl = f8
     2 performed_tran_prsnl = vc
     2 performed_dt_tm = dq8
     2 physician_order_ind = i2
     2 read_ind = i2
     2 remind_dt_tm = dq8
     2 reschedule_ind = i2
     2 reschedule_reason_ref = f8
     2 routine_ind = i2
     2 scheduled_dt_tm = dq8
     2 source_tag = vc
     2 stat_ind = i2
     2 suggested_entity_sk = f8
     2 suggested_entity_name = vc
     2 task_activity_ref = f8
     2 task_activity_class_ref = f8
     2 task_class_ref = f8
     2 task_desc = vc
     2 task_create_dt_tm = dq8
     2 task_dt_tm = dq8
     2 task_priority_ref = f8
     2 task_status_ref = f8
     2 task_status_reason_ref = f8
     2 task_type_ref = f8
     2 template_task_flg = f8
     2 tpn_ind = i2
     2 updt_prsnl = f8
     2 updt_tran_prsnl = f8
     2 active_ind = i2
 )
 RECORD task_activity_assign_keys(
   1 qual[*]
     2 task_activity_assign_id = f8
 )
 RECORD task_activity_assign_parent_keys(
   1 qual[*]
     2 parent_task_id = f8
 )
 RECORD task_activity_assign_info(
   1 qual[*]
     2 task_activity_assign_sk = f8
     2 task_activity_sk = f8
     2 task_activity_key = f8
     2 assign_person_sk = f8
     2 assign_prsnl = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contributor_system_ref = f8
     2 copy_type_flg = f8
     2 event_prsnl = f8
     2 external_reference_number = vc
     2 proxy_prsnl = f8
     2 rejection_ind = i2
     2 remind_dt_tm = dq8
     2 reply_allowed_ind = i2
     2 scheduled_dt_tm = dq8
     2 task_status_ref = f8
     2 active_ind = i2
 )
 RECORD ce_event_note_keys(
   1 qual[*]
     2 ce_event_note_id = f8
 )
 RECORD ce_event_note_parent_keys(
   1 qual[*]
     2 clinical_event_id = f8
 )
 RECORD ce_event_note_info(
   1 qual[*]
     2 ce_event_note_sk = f8
     2 event_note_sk = f8
     2 event_sk = f8
     2 note_type_ref = f8
     2 note_format_ref = f8
     2 valid_from_dt_tm = dq8
     2 valid_from_tm_zn = i2
     2 valid_until_dt_tm = dq8
     2 valid_until_tm_zn = i2
     2 entry_method_ref = f8
     2 note_prsnl = f8
     2 note_dt_tm = dq8
     2 note_tm_zn = i2
     2 record_status_ref = f8
     2 compression_ref = f8
     2 checksum = i4
     2 src_long_text_sk = f8
     2 non_chartable_flg = i2
     2 importance_flg = i2
     2 note_text = vc
 )
 RECORD bb_person_aborh_keys(
   1 qual[*]
     2 person_aborh_id = f8
 )
 RECORD bb_person_aborh_info(
   1 qual[*]
     2 bb_person_aborh_sk = f8
     2 abo_ref = f8
     2 src_begin_effective_dt_tm = dq8
     2 contributor_system_ref = f8
     2 end_effective_dt_tm = dq8
     2 last_verified_dt_tm = dq8
     2 person_sk = f8
     2 rh_ref = f8
     2 active_ind = i2
 )
 RECORD bb_person_antibody_keys(
   1 qual[*]
     2 person_antibody_id = f8
     2 encntr_id = f8
     2 encounter_nk = vc
 )
 RECORD bb_person_antibody_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD bb_person_antibody_info(
   1 qual[*]
     2 bb_person_antibody_sk = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 person_sk = f8
     2 antibody_ref = f8
     2 bb_result_nbr = f8
     2 contributor_system_ref = f8
     2 gen_lab_result_sk = f8
     2 active_ind = i2
 )
 RECORD bb_person_antigen_keys(
   1 qual[*]
     2 person_antigen_id = f8
     2 encntr_id = f8
     2 encounter_nk = vc
 )
 RECORD bb_person_antigen_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD bb_person_antigen_info(
   1 qual[*]
     2 bb_person_antigen_sk = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 person_sk = f8
     2 antigen_ref = f8
     2 bb_result_nbr = f8
     2 contributor_system_ref = f8
     2 bb_prsn_rh_phntype_sk = f8
     2 gen_lab_result_sk = f8
     2 active_ind = i2
 )
 RECORD bb_device_keys(
   1 qual[*]
     2 bb_device_id = f8
     2 bb_inv_device_id = f8
 )
 RECORD bb_device_info(
   1 qual[*]
     2 device_sk = f8
     2 bb_inv_device_sk = f8
     2 description = vc
     2 device_type_ref = f8
     2 device_type_mean = vc
     2 device_type_disp = vc
     2 device_type_desc = vc
     2 inventory_area_ref = f8
     2 device_loc = f8
     2 service_resource_ref = f8
     2 interface_flag = vc
     2 active_ind = i2
 )
 RECORD prdct_evnt_keys(
   1 qual[*]
     2 product_event_id = f8
     2 product_id = f8
     2 encounter_nk = vc
     2 loc_facility_cd = f8
 )
 RECORD bbhist_prdct_evnt_keys(
   1 qual[*]
     2 product_event_id = f8
     2 product_id = f8
     2 encounter_nk = vc
 )
 RECORD parent_prdct_evnt_keys(
   1 qual[*]
     2 product_id = f8
     2 bbhist_product_id = f8
 )
 RECORD prdct_evnt(
   1 qual[*]
     2 product_event_id = f8
     2 product_id = f8
     2 encntr_id = f8
     2 encntr_nk = vc
     2 loc_facility_cd = f8
     2 person_id = f8
     2 order_id = f8
     2 bb_id_nbr = f8
     2 bb_result_id = f8
     2 contributor_system_cd = f8
     2 event_dt_tm = dq8
     2 event_tm_zn = i4
     2 event_prsnl_id = f8
     2 event_status_flg = vc
     2 event_type_cd = f8
     2 international_unit = f8
     2 inventory_area_cd = f8
     2 organization_id = f8
     2 overrie_ind = f8
     2 override_reason_cd = f8
     2 owner_area_cd = f8
     2 prsnl_id = f8
     2 qty = f8
     2 related_product_event_id = f8
     2 volume = f8
     2 assign_intl_units = f8
     2 assign_qty = f8
     2 assign_reason_cd = f8
     2 orig_assign_qty = f8
     2 orig_assign_intl_units = f8
     2 prov_id = f8
     2 from_device_id = f8
     2 to_device_id = f8
     2 device_reason_cd = f8
     2 from_inv_area_cd = f8
     2 from_owner_area_cd = f8
     2 to_inv_area_cd = f8
     2 to_owner_area_cd = f8
     2 transfer_reason_cd = f8
     2 crossmatch_exp_dt_tm = dq8
     2 crossmatch_exp_tm_zn = i4
     2 crossmatch_qty = f8
     2 reinstate_reason_cd = f8
     2 release_dt_tm = dq8
     2 release_tm_zn = i4
     2 release_prsnl_id = f8
     2 release_qty = f8
     2 release_reason_cd = f8
     2 xm_reason_cd = f8
     2 autoclave_ind = i2
     2 box_nbr = vc
     2 destroyed_qty = f8
     2 destruction_org_id = f8
     2 manifest_nbr = vc
     2 method_cd = f8
     2 disposed_intl_units = f8
     2 disposed_qty = f8
     2 disposition_reason_cd = f8
     2 accessory = vc
     2 crossover_reason_cd = f8
     2 device_type_cd = f8
     2 cur_expire_dt_tm = dq8
     2 cur_expire_tm_zn = i4
     2 lot_nbr = vc
     2 modified_qty = f8
     2 option_id = f8
     2 orig_expire_dt_tm = dq8
     2 orig_expire_tm_zn = i4
     2 orig_unit_meas_cd = f8
     2 orig_volume = f8
     2 start_dt_tm = dq8
     2 start_tm_zn = i4
     2 stop_dt_tm = dq8
     2 stop_tm_zn = i4
     2 cur_unit_meas_cd = f8
     2 mod_vis_insp_cd = f8
     2 cur_volume = f8
     2 device_id = f8
     2 dispense_cooler_id = f8
     2 dispense_cooler_text = vc
     2 dispense_courier_id = f8
     2 dispense_courier_text = vc
     2 dispense_from_locn_cd = f8
     2 cur_dispense_intl_units = f8
     2 dispense_prov_id = f8
     2 cur_dispense_qty = f8
     2 dispense_reason_cd = f8
     2 dispense_status_flag = i2
     2 dispense_to_locn_cd = f8
     2 dispense_vis_insp_cd = f8
     2 orig_dispense_intl_units = f8
     2 orig_dispense_qty = f8
     2 unknown_patient_ind = i4
     2 unknown_patient_text = vc
     2 orig_quar_intl_units = f8
     2 orig_quar_qty = f8
     2 cur_quar_intl_units = f8
     2 cur_quar_qty = f8
     2 quar_reason_cd = f8
     2 alpha_translation_id = f8
     2 bb_supplier_id = f8
     2 electronic_receipt_ind = f8
     2 orig_intl_units = f8
     2 orig_rcvd_qty = f8
     2 ship_cond_cd = f8
     2 temperature_degree_cd = f8
     2 temperature_value = f8
     2 receipt_vis_insp_cd = f8
     2 bag_returned_ind = i2
     2 orig_transfused_qty = f8
     2 trfsn_tag_returned_ind = f8
     2 transfused_intl_units = f8
     2 transfused_vol = f8
     2 cur_transfused_qty = f8
     2 active_ind = vc
     2 active_status_ref = f8
     2 active_status_dt_tm = dq
     2 active_status_tm_zn = i4
     2 active_status_prsnl = f8
 )
 RECORD bb_release_keys(
   1 qual[*]
     2 quar_release_id = f8
     2 assign_release_id = f8
 )
 RECORD bb_release_parent_keys(
   1 qual[*]
     2 product_event_id = f8
 )
 RECORD bb_release_info(
   1 qual[*]
     2 bb_assign_release_sk = f8
     2 bb_quar_release_sk = f8
     2 product_event_sk = f8
     2 product_sk = f8
     2 release_type_flg = f8
     2 release_dt_tm = dq8
     2 release_intl_units = i4
     2 release_prsnl = f8
     2 release_qty = i4
     2 release_reason_ref = f8
     2 active_ind = i2
 )
 RECORD parent_bb_special_keys(
   1 qual[*]
     2 product_id = f8
     2 bbhist_product_id = f8
 )
 RECORD bb_special_keys(
   1 qual[*]
     2 special_testing_id = f8
 )
 RECORD bb_bbhist_special_keys(
   1 qual[*]
     2 bbhist_special_testing_id = f8
 )
 RECORD bb_special(
   1 qual[*]
     2 special_testing_id = f8
     2 product_id = f8
     2 barcode_value_txt = vc
     2 confirmed_ind = i2
     2 modifiable_flag = i4
     2 nomenclature_id = f8
     2 special_testing_cd = f8
     2 active_ind = vc
 )
 RECORD bb_person_trans_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD bb_dispense_return_parent_keys(
   1 qual[*]
     2 product_event_id = f8
 )
 RECORD sch_date_comment_keys(
   1 qual[*]
     2 date_comment_id = f8
 )
 RECORD edw_sch_date_comment(
   1 qual[*]
     2 date_comment_sk = f8
     2 parent_id = f8
     2 parent_table = vc
     2 action_dt_tm = dq8
     2 action_prsnl = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 mnemonic = vc
     2 orig_long_text_sk = f8
     2 apply_mnemonic = vc
     2 apply_text_type_ref = f8
     2 apply_days_of_wk = vc
     2 apply_sch_state_ref = f8
     2 apply_long_text_sk = f8
     2 apply_sub_text_ref = f8
     2 sch_state_ref = f8
     2 sub_text_ref = f8
     2 long_text_sk = f8
     2 text_type_ref = f8
     2 version_dt_tm = dq8
     2 active_ind = vc
 )
 RECORD sch_entry_parents(
   1 qual[*]
     2 sch_event_id = f8
 )
 RECORD sch_entry_keys(
   1 qual[*]
     2 sch_entry_id = f8
     2 encounter_id = f8
     2 encounter_nk = vc
     2 loc_facility_cd = f8
 )
 RECORD edw_sch_entry(
   1 qual[*]
     2 sch_entry_sk = f8
     2 loc_facility_cd = f8
     2 sch_appointment_sk = f8
     2 schedule_sk = f8
     2 sch_appt_action_sk = f8
     2 sch_calendar_sk = f8
     2 encounter_sk = f8
     2 encounter_nk = vc
     2 appt_type_ref = f8
     2 earliest_dt_tm = dq8
     2 earliest_tm_zn = i4
     2 entry_state_ref = f8
     2 entry_type_ref = f8
     2 latest_dt_tm = dq8
     2 latest_tm_zn = i4
     2 person_sk = f8
     2 queue_mnemonic = vc
     2 queue_desc = vc
     2 request_made_dt_tm = dq8
     2 request_tm_zn = i4
     2 req_action_ref = f8
     2 standby_priority_ref = f8
     2 version_dt_tm = dq8
     2 version_tm_zn = i4
     2 active_ind = vc
     2 object_sub_meaning = vc
     2 event_alias = vc
 )
 RECORD sch_event_attach_parents(
   1 qual[*]
     2 sch_event_id = f8
 )
 RECORD sch_event_comm_parents(
   1 qual[*]
     2 sch_event_id = f8
 )
 RECORD bb_product_keys(
   1 qual[*]
     2 p_product_id = f8
     2 bb_product_id = f8
     2 bp_product_id = f8
     2 d_product_id = f8
 )
 RECORD bb_product_info(
   1 qual[*]
     2 p_product_sk = f8
     2 bb_product_sk = f8
     2 p_product_nbr = vc
     2 bb_product_nbr_format_ref = f8
     2 p_product_sub_nbr = vc
     2 bp_donor_person_sk = f8
     2 abo_ref = f8
     2 bp_orig_abo_ref = f8
     2 p_alternate_nbr = vc
     2 bp_autologous_ind = f8
     2 p_barcode_nbr = vc
     2 p_biohazard_ind = f8
     2 p_contributor_system_ref = f8
     2 p_corrected_ind = f8
     2 p_create_dt_tm = dq8
     2 p_create_tm_vld_flg = f8
     2 bb_cross_reference = vc
     2 d_avail_qty = f8
     2 p_cur_dispense_device_id = f8
     2 bp_directed_ind = i2
     2 bp_drawn_dt_tm = dq8
     2 p_disease_ref = f8
     2 p_donated_by_relative_ind = f8
     2 p_donation_type_ref = f8
     2 bb_donor_xref_txt = vc
     2 p_electronic_entry_flg = i2
     2 p_expire_dt_tm = dq8
     2 bp_orig_expire_dt_tm = dq8
     2 p_inv_area_ref = f8
     2 p_inventory_loc = f8
     2 p_orig_inventory_loc = f8
     2 d_intl_units = f8
     2 p_cur_inv_device_id = f8
     2 bp_lot_nbr = vc
     2 p_owner_area_ref = f8
     2 d_manufacturer_org = f8
     2 p_supplier_org = f8
     2 supplier_prefix = vc
     2 bp_orig_volume = f8
     2 p_orig_unit_meas_ref = f8
     2 volume = f8
     2 p_unit_meas_ref = f8
     2 d_item_unit_meas_ref = f8
     2 d_item_volume = f8
     2 d_units_per_vial = f8
     2 p_flag_chars = vc
     2 p_intended_use_print_param_txt = vc
     2 p_interfaced_device_flg = i2
     2 p_locked_ind = i2
     2 p_modified_product_sk = f8
     2 p_modified_product_ind = i2
     2 p_orig_ship_cong_ref = f8
     2 p_orig_vis_insp_ref = f8
     2 p_pool_option_id = f8
     2 p_pooled_product_sk = f8
     2 p_pooled_product_ind = i2
     2 p_product_cat_ref = f8
     2 p_product_ref = f8
     2 p_product_class_ref = f8
     2 p_product_type_barcode = vc
     2 p_recv_dt_tm = dq8
     2 p_received_prsnl = f8
     2 p_req_label_verify_ind = i2
     2 bp_org_rh_ref = f8
     2 rh_ref = f8
     2 p_storage_temp_ref = f8
     2 bp_segment_nbr = vc
     2 bb_upload_dt_tm = dq8
     2 p_active_ind = i2
 )
 RECORD ce_blob_keys(
   1 qual[*]
     2 event_id = f8
 )
 RECORD ce_blob_parent_keys(
   1 qual[*]
     2 event_id = f8
 )
 RECORD rad_detail_keys(
   1 qual[*]
     2 rad_report_id = f8
     2 task_assay_cd = f8
     2 section_sequence = f8
 )
 RECORD edw_rad_detail(
   1 qual[*]
     2 rad_report_id = f8
     2 detail_event_id = f8
     2 task_assay_cd = f8
     2 event_title_text = vc
     2 section_sequence = f8
     2 acr_code_ind = vc
     2 required_ind = vc
     2 detail_reference_nbr = vc
     2 template_id = f8
 )
 RECORD rad_detail_parent_keys(
   1 qual[*]
     2 rad_report_id = f8
 )
 RECORD long_blob_keys(
   1 qual[*]
     2 long_blob_id = f8
 )
 RECORD ep_act_enc_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD ep_act_enc_reltn_parents(
   1 qual[*]
     2 episode_encntr_reltn_id = f8
 )
 RECORD ep_activity(
   1 qual[*]
     2 episode_activity_id = f8
     2 created_by_encntr_id = f8
     2 episode_id = f8
 )
 RECORD ep_activity_info(
   1 qual[*]
     2 episode_activity_sk = f8
     2 episode_sk = f8
     2 epi_enc_reltn_sk = f8
     2 activity_dt_tm = dq8
     2 activity_ref = f8
     2 activity_type_ref = f8
     2 episode_status_ref = f8
     2 episode_pause_days_cnt = i4
     2 created_by_encntr_sk = f8
     2 created_by_schedule_sk = f8
     2 created_by_ce_event_sk = f8
     2 active_ind = i2
     2 updt_sk = f8
 )
 RECORD fhx_activity_keys(
   1 qual[*]
     2 fhx_activity_id = f8
 )
 RECORD edw_fhx_activity(
   1 qual[*]
     2 fhx_activity_sk = f8
     2 fhx_activity_group_sk = f8
     2 person_sk = f8
     2 related_person_sk = f8
     2 related_person_reltn_ref = f8
     2 fhx_value_flg = f8
     2 onset_age = f8
     2 onset_age_prec_ref = f8
     2 onset_age_unit_ref = f8
     2 activity_org = f8
     2 course_ref = f8
     2 life_cycle_status_ref = f8
     2 activity_nomen = f8
     2 severity_ref = f8
     2 type_mean = vc
     2 src_beg_effect_dt_tm = dq8
     2 src_end_effect_dt_tm = dq8
     2 active_ind = vc
     2 create_prsnl = f8
     2 create_dt_tm = dq8
     2 create_tm_zn = i4
     2 inactivate_prsnl = f8
     2 inactivate_dt_tm = dq8
     2 inactivate_tm_zn = i4
     2 first_review_prsnl = f8
     2 first_review_dt_tm = dq8
     2 first_review_tm_zn = i4
     2 last_review_prsnl = f8
     2 last_review_dt_tm = dq8
     2 last_review_tm_zn = i4
 )
 RECORD fhx_activity_r_keys(
   1 qual[*]
     2 fhx_activity_s_id = f8
     2 fhx_activity_t_id = f8
     2 type_mean = vc
 )
 RECORD fhx_activity_r_parent_keys(
   1 qual[*]
     2 fhx_activity_id = f8
 )
 RECORD fhx_long_text_r_keys(
   1 qual[*]
     2 fhx_long_text_r_id = f8
 )
 RECORD fhx_long_text_r_parent_keys(
   1 qual[*]
     2 fhx_activity_id = f8
 )
 RECORD sn_doc_pref_keys(
   1 qual[*]
     2 doc_ref_id = f8
     2 name_value_prefs_id = f8
 )
 RECORD cd_value_keys(
   1 qual[*]
     2 code_value = f8
 )
 RECORD drg_extension_keys(
   1 qual[*]
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 beg_effective_dt_tm = dq8
     2 severity_of_illness_cd = f8
     2 nomenclature_id = f8
 )
 RECORD drg_extension(
   1 qual[*]
     2 drg_extension_sk = vc
     2 nomenclature_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 amlos = f8
     2 beg_effective_dt_tm = dq8
     2 drg_category = vc
     2 drg_weight = f8
     2 end_effective_dt_tm = dq8
     2 gmlos = f8
     2 mdc_cd = f8
     2 severity_of_illness_cd = f8
     2 source_identifier = vc
     2 source_vocabulary_cd = f8
     2 transfer_rule_ind = i2
 )
 RECORD br_hlth_sntry_mill_keys(
   1 qual[*]
     2 br_hlth_sntry_mill_id = f8
 )
 RECORD br_hlth_sntry(
   1 qual[*]
     2 br_hlth_sntry_mill_id = f8
     2 br_hlth_sntry_id = f8
     2 source_item_ref = i4
     2 source_item_disp = vc
     2 source_item_meaning = vc
     2 source_item_desc = vc
     2 item_code_set = i4
     2 description_1 = vc
     2 description_2 = vc
     2 description_3 = vc
     2 description_4 = vc
     2 description_5 = vc
     2 description_6 = vc
     2 dim_item_ident = i4
     2 ignore_ind = i4
 )
 RECORD encntr_person_reltn_keys(
   1 qual[*]
     2 encntr_person_reltn_sk = f8
     2 encntr_id = f8
     2 encounter_nk = vc
     2 loc_facility_cd = f8
 )
 RECORD encntr_person_reltn_parent_keys(
   1 qual[*]
     2 encounter_sk = f8
 )
 RECORD encntr_person_reltn_info(
   1 qual[*]
     2 encntr_person_reltn_sk = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 related_person_sk = f8
     2 related_person_reltn_ref = f8
     2 person_reltn_type_ref = f8
     2 person_reltn_ref = f8
     2 contributor_system_ref = f8
     2 contact_role_ref = f8
     2 genetic_reltn_ind = i2
     2 living_with_ind = i2
     2 visitation_allowed_ref = f8
     2 priority_seq = i4
     2 free_text_ref = f8
     2 rel_person_name_ft = vc
     2 internal_seq = i4
     2 family_reltn_sub_type_ref = f8
     2 default_reltn_ind = i2
     2 source_identifier = vc
     2 copy_correspondence_ref = f8
     2 relation_seq = i4
     2 src_beg_effective_dt_tm = dq8
     2 src_end_effective_dt_tm = dq8
     2 src_beg_effective_tm_zn = i4
     2 src_end_effective_tm_zn = i4
     2 active_ind = i2
     2 loc_facility_cd = f8
 )
 RECORD ord_act_keys(
   1 qual[*]
     2 order_sk = f8
     2 action_sequence = i4
 )
 RECORD mental_health_keys(
   1 qual[*]
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 encntr_nk = vc
 )
 RECORD mental_health_encntr_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD mental_health_data(
   1 qual[*]
     2 mental_health_sk = f8
     2 encounter_sk = f8
     2 encounter_nk = vc
     2 loc_facility_cd = f8
     2 mental_health_category_ref = f8
     2 mental_health_ref = f8
     2 mental_health_tm_zn = i2
     2 mental_health_dt_tm = dq8
     2 renewal_determ_dt_tm = dq8
     2 first_dt_tm = dq8
     2 first_fac_ref = f8
     2 first_prsnl = f8
     2 second_dt_tm = dq8
     2 second_fac_ref = f8
     2 second_prsnl = f8
     2 next_panel_dt_tm = dq8
     2 active_ind = i2
     2 pm_mental_health_sk = f8
 )
 RECORD legal_status_keys(
   1 qual[*]
     2 legal_status_r_id = f8
     2 encntr_id = f8
     2 encntr_nk = vc
     2 loc_facility_cd = f8
 )
 RECORD legal_status_encntr_parents(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD legal_status_data(
   1 qual[*]
     2 legal_status_sk = f8
     2 encounter_id = f8
     2 encounter_nk = vc
     2 loc_facility_cd = f8
     2 person_sk = f8
     2 legal_status_ref = f8
     2 legal_status_inactive_ind = i2
     2 legal_status_tm_zn = i2
     2 start_dt_tm = dq8
     2 end_dt_tm = dq8
     2 court_dt_tm = dq8
     2 court_file_num = vc
     2 court_location_ref = f8
     2 adjournment_dt_tm = dq8
     2 next_review_dt_tm = dq8
     2 probable_sentence_dt_tm = dq8
     2 referral_dt_tm = dq8
     2 referral_facility_ref = f8
     2 referral_source_ref = f8
     2 referral_type_ref = f8
     2 region_ref = f8
     2 req_extension_dt_tm = dq8
     2 sentence_dt_tm = dq8
     2 stay_of_proceedings_dt_tm = dq8
     2 verbal_stay_dt_tm = dq8
     2 written_stay_dt_tm = dq8
     2 l_rev_decision_ref = f8
     2 l_rev_disp_recv_dt_tm = dq8
     2 l_rev_hearing_dt_tm = dq8
     2 l_rev_loc = f8
     2 l_rev_leg_recommend_ref = f8
     2 l_rev_oth_recommend_ref = f8
     2 l_rev_reason_recvd_dt_tm = dq8
     2 l_rev_recommend_ref = f8
     2 l_review_board_ref = f8
     2 active_ind = i2
 )
 RECORD mammo_assessment_keys(
   1 qual[*]
     2 series_sk = f8
     2 sequence = f8
 )
 RECORD mammo_assessment_parent_keys(
   1 qual[*]
     2 study_id = f8
 )
 RECORD mammo_assessment_info(
   1 qual[*]
     2 mammo_assess_series_sk = vc
     2 mammo_study_sk = vc
     2 study_sk = f8
     2 series_sk = f8
     2 recommend_seq = f8
     2 recommend_fol_up_field_sk = f8
     2 assessment_seq = f8
     2 assessment_fol_up_field_sk = f8
     2 recall_interval = i4
     2 follow_up_proc_ref = f8
     2 assigned_dt_tm = dq8
     2 series_open_ind = i2
     2 rad_prsnl = f8
     2 letter_sk = f8
 )
 RECORD mammo_study_parent_keys(
   1 qual[*]
     2 order_id = f8
 )
 RECORD mammo_study_keys(
   1 qual[*]
     2 study_sk = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD mammo_study_info(
   1 qual[*]
     2 mammo_study_sk = f8
     2 enc_nk = vc
     2 loc_facility_cd = f8
     2 encounter_sk = f8
     2 order_sk = f8
     2 person_sk = f8
     2 catalog_ref = f8
     2 study_dt_tm = dq8
     2 reason_fol_up_field_sk = f8
     2 asmnt_fol_up_field_sk = f8
     2 recommend_fol_up_field_sk = f8
     2 stat_cat_fol_up_field_sk = f8
     2 recall_interval = i4
     2 active_ind = i2
     2 subsection_ref = f8
     2 contributor_system_ref = f8
     2 group_reference_nbr = vc
     2 edition_nbr = i4
     2 letter_sk = f8
     2 download_ind = i2
     2 stat_cat_flag = i2
     2 no_fol_up_req_ind = i2
     2 study_tz = i4
     2 exclude_from_audit_ind = i2
     2 seq_exam_sk = f8
     2 radiologist_prsnl_sk = f8
     2 order_doc_prsnl_sk = f8
     2 technologist_prsnl_sk = f8
 )
 RECORD mammo_usrdef_keys(
   1 qual[*]
     2 user_value_id = f8
 )
 RECORD mammo_usrdef_parent_keys(
   1 qual[*]
     2 study_id = f8
 )
 RECORD mammo_usrdef_info(
   1 qual[*]
     2 mammo_user_def_sk = f8
     2 mammo_study_sk = f8
     2 fol_up_field_sk = f8
     2 numeric_val = f8
     2 value_dt_tm = dq8
     2 value_txt = vc
     2 value_tm_zn = i4
 )
 RECORD mammo_breast_find_keys(
   1 qual[*]
     2 breast_find_id = f8
 )
 RECORD mammo_breast_find_parent_keys(
   1 qual[*]
     2 study_id = f8
 )
 RECORD mammo_breast_info(
   1 qual[*]
     2 breast_find_id = f8
     2 mammo_breast_find_sk = vc
     2 mammo_study_sk = f8
     2 find_sk = f8
     2 find_detail_sk = f8
     2 side_field_sk = f8
     2 breast_comp_field_sk = f8
     2 find_seq = i4
     2 lesion_class_field_sk = f8
     2 path_field_sk = f8
     2 scd_term_sk = f8
     2 field_foll_up_sk = f8
     2 numeric_val = f8
     2 value_dt_tm = dq8
     2 value_tm_zn = i4
     2 text_val = vc
 )
 RECORD long_text_ref_keys(
   1 qual[*]
     2 long_text_id = f8
 )
 RECORD ppr_consent_policy_keys(
   1 qual[*]
     2 consent_policy_id = f8
 )
 RECORD ppr_consent_policy_rows(
   1 qual[*]
     2 consent_policy_id = f8
     2 consent_policy_sk = f8
     2 policy_long_blob_sk = f8
     2 policy_consent_org = f8
     2 version_nbr = f8
     2 comment_txt = vc
     2 blob_ref_scan_ident = f8
     2 policy_consent_name = vc
     2 consent_type_disp = vc
     2 consent_type_mean = vc
 )
 RECORD ppr_consent_status_keys(
   1 qual[*]
     2 consent_id = f8
     2 encounter_nk = vc
 )
 RECORD consent_status_parent_keys(
   1 qual[*]
     2 parent_encntr_id = f8
 )
 RECORD ppr_consent_status_rows(
   1 qual[*]
     2 consent_status_id = f8
     2 consent_id = f8
     2 consent_status_sk = f8
     2 encounter_nk = vc
     2 encounter_sk = f8
     2 person_sk = f8
     2 consent_status_org = f8
     2 consent_policy_sk = f8
     2 parent_entity_name = vc
     2 parent_entity_sk = f8
     2 consent_parent_entity_name = vc
     2 consent_parent_entity_sk = f8
     2 status_ref = f8
     2 consent_type_ref = f8
     2 reason_ref = f8
     2 contributor_system_ref = f8
     2 status_change_reason_ref = f8
     2 blob_ref_scan_ident = f8
     2 document_on_file_ind = i4
     2 comment_txt = vc
     2 status_change_reason_text = vc
     2 beg_effective_dt_tm = dq8
     2 active_ind = i4
     2 active_status_prsnl = f8
     2 active_status_dt_tm = dq8
     2 active_status_ref = f8
 )
 RECORD glalias_keys(
   1 qual[*]
     2 gl_trans_log_id = f8
     2 gl_company_alias_nbr = vc
     2 gl_company_unit_alias_nbr = vc
     2 gl_account_alias_nbr = vc
     2 gl_acct_unit_alias_nbr = vc
     2 dr_cr_flag = f8
 )
 RECORD keys_rsp(
   1 qual[*]
     2 gl_rsp_unit_skpt1 = f8
     2 gl_rsp_unit_skpt2 = f8
 )
 RECORD keys_acct(
   1 qual[*]
     2 gl_trans_log_id = f8
     2 gl_account_skpt1 = f8
     2 gl_account_skpt2 = f8
     2 dr_cr_flag = f8
 )
 RECORD glrspu_r(
   1 qual[*]
     2 gl_rsp_unit_skpt1 = f8
     2 gl_rsp_unit_skpt2 = f8
     2 gl_rsp_unit_nbr = vc
     2 gl_rsp_unit_name = vc
     2 gl_rsp_unit_desc = vc
     2 gl_rsp_unit_type = vc
     2 gl_entity_nbr = vc
     2 gl_entity_name = vc
     2 gl_entity_desc = vc
 )
 RECORD glacct_r(
   1 qual[*]
     2 gl_account_skpt1 = f8
     2 gl_account_skpt2 = f8
     2 gl_account_nbr = vc
     2 gl_sub_acct_unit_nbr = vc
     2 gl_account_name = vc
     2 gl_account_desc = vc
     2 gl_acct_unit_type = vc
     2 gl_sub_acct_unit_type = vc
     2 gl_sub_acct_unit_name = vc
     2 gl_sub_acct_unit_desc = vc
     2 balance_type = f8
     2 debit_credit_flg = f8
     2 financial_class_nbr = f8
     2 financial_class_desc = vc
     2 gl_trans_log_id = f8
 )
 RECORD refmed_key(
   1 qual[*]
     2 sa_medication_sk = f8
 )
 RECORD ref_medication(
   1 qual[*]
     2 sa_medication_sk = f8
     2 med_product_sk = f8
     2 item_sk = f8
     2 ref_type_flag = i4
     2 pyxis_nbr = vc
     2 med_brand_name = vc
     2 med_gen_name = vc
     2 med_desc = vc
     2 sequence = i4
     2 primary_cat_name = vc
     2 primary_cat_type_disp = vc
     2 primary_cat_type_mean = vc
     2 secondary_cat_name = vc
     2 secondary_cat_type_disp = vc
     2 secondary_cat_type_mean = vc
     2 tertiary_cat_name = vc
     2 tertiary_cat_type_disp = vc
     2 tertiary_cat_type_mean = vc
     2 src_active_ind = c1
     2 active_ind = c1
 )
 RECORD refactitm_keys(
   1 qual[*]
     2 sa_r_action_item_sk = f8
 )
 RECORD ref_actitm(
   1 qual[*]
     2 sa_r_action_item_sk = f8
     2 action_item_name = vc
     2 action_item_desc = vc
     2 value_type_flag = i4
     2 value_required_ind = i4
     2 child_selection_req_ind = i4
     2 default_value = vc
     2 task_assay_sk = f8
     2 sequence = i4
     2 prim_grp_multi_select_ind = i4
     2 prim_grp_select_required_ind = i4
     2 prim_grp_prompt = vc
     2 prim_grp_print_ind = i4
     2 prim_grp_bill_ind = i4
     2 sec_grp_multi_select_ind = i4
     2 sec_grp_select_required_ind = i4
     2 sec_grp_prompt = vc
     2 sec_grp_print_ind = i4
     2 sec_grp_bill_ind = i4
     2 src_active_ind = c1
 )
 RECORD fldref_key(
   1 qual[*]
     2 sa_fluid_sk = f8
 )
 RECORD fldref_medication(
   1 qual[*]
     2 sa_fluid_sk = f8
     2 med_product_sk = f8
     2 out_ind = i4
     2 event_ref = f8
     2 task_assay_sk = f8
     2 item_sk = f8
     2 ref_type_flag = i4
     2 sequence = i4
     2 primary_cat_name = vc
     2 primary_cat_type_disp = vc
     2 primary_cat_type_mean = vc
     2 secondary_cat_name = vc
     2 secondary_cat_type_disp = vc
     2 secondary_cat_type_mean = vc
     2 tertiary_cat_name = vc
     2 tertiary_cat_type_disp = vc
     2 tertiary_cat_type_mean = vc
     2 src_active_ind = c1
     2 active_ind = c1
 )
 RECORD parmref_key(
   1 qual[*]
     2 sa_parameter_sk = f8
 )
 RECORD parmref_medication(
   1 qual[*]
     2 sa_parameter_sk = f8
     2 sa_ref_icon_sk = f8
     2 ref_type_flag = i4
     2 task_assay_sk = f8
     2 sequence = i4
     2 parameter_name = vc
     2 parameter_desc = vc
     2 primary_cat_name = vc
     2 primary_cat_type_disp = vc
     2 primary_cat_type_mean = vc
     2 secondary_cat_name = vc
     2 secondary_cat_type_disp = vc
     2 secondary_cat_type_mean = vc
     2 tertiary_cat_name = vc
     2 tertiary_cat_type_disp = vc
     2 tertiary_cat_type_mean = vc
     2 src_active_ind = c1
 )
 RECORD anesthesia_rec_parent_keys(
   1 qual[*]
     2 surgical_case_id = f8
 )
 RECORD anesthesia_rec_keys(
   1 qual[*]
     2 sa_anesthesia_record_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD anesthesia_rec_info(
   1 qual[*]
     2 anesthesia_record_sk = f8
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 surgical_case_sk = f8
     2 event_sk = f8
     2 anesthesia_record_tm_zn = i4
     2 create_dt_tm = dq8
     2 create_loc = f8
     2 created_by_prsnl = f8
     2 last_doc_dt_tm = dq8
     2 last_doc_prsnl = f8
     2 sa_ref_doc_type_sk = f8
     2 finalization_type_flg = i2
     2 supervisor_req_ind = i2
     2 record_desc = vc
     2 fiinalized_print_status_flg = i2
     2 finalized_prsnl = f8
     2 finalized_status_dt_tm = dq8
     2 active_ind = i2
 )
 RECORD anesthesia_meditm_parent_keys(
   1 qual[*]
     2 sa_anesthesia_record_id = f8
 )
 RECORD anesthesia_meditm_keys(
   1 qual[*]
     2 sa_med_admin_item_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD anesthesia_meditm_info(
   1 qual[*]
     2 sa_med_admin_item_sk = f8
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 sa_medication_sk = f8
     2 sa_medication_admin_sk = f8
     2 anesthesia_record_sk = f8
     2 prev_sa_med_admin_sk = f8
     2 sa_macro_sk = f8
     2 medication_prsnl = f8
     2 sa_r_medication_sk = f8
     2 sa_admin_macro_sk = f8
     2 order_sk = f8
     2 template_order_sk = f8
     2 ordered_ind = f8
     2 event_sk = f8
     2 io_event_sk = f8
     2 group_event_sk = f8
     2 sa_ref_diluent_sk = f8
     2 result_set_sk = f8
     2 task_sk = f8
     2 med_admin_type_flg = i2
     2 med_admin_prsnl = f8
     2 long_text_sk = f8
     2 conc_amount = f8
     2 conc_amount_unit_ref = f8
     2 conc_dosage = f8
     2 conc_dosage_unit_ref = f8
     2 diluent_conc_volume = f8
     2 height = f8
     2 height_unit_ref = f8
     2 weight = f8
     2 weight_unit_ref = f8
     2 admin_dosage = f8
     2 dosage_unit_ref = f8
     2 admin_amount = f8
     2 amount_unit_ref = f8
     2 admin_route_ref = f8
     2 admin_site_ref = f8
     2 admin_rate_ref = f8
     2 pump_infusion_rate = f8
     2 pir_amount_unit_ref = f8
     2 pir_time_unit_ref = f8
     2 weight_based_dose = f8
     2 wbd_dosage_unit_ref = f8
     2 wbd_weight_unit_ref = f8
     2 wbd_time_unit_ref = f8
     2 dosing_infusion_rate = f8
     2 dir_dosage_unit_ref = f8
     2 dir_time_unit_ref = f8
     2 charged_ind = i2
     2 ddmo_ind = i2
     2 anes_med_admin_item_tm_zn = i4
     2 admin_start_dt_tm = dq8
     2 admin_end_dt_tm = dq8
     2 sent_dt_tm = dq8
     2 src_active_ind = i2
     2 active_ind = i2
 )
 RECORD anesthesia_actitm_parent_keys(
   1 qual[*]
     2 sa_anesthesia_record_id = f8
 )
 RECORD anesthesia_actitm_keys(
   1 qual[*]
     2 sa_action_id = f8
     2 sa_action_item_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD anesthesia_actitm_info(
   1 qual[*]
     2 sa_action_item_sk = vc
     2 sa_action_sk = f8
     2 action_item_sk = f8
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 anesthesia_record_sk = f8
     2 prev_sa_action_sk = f8
     2 event_sk = f8
     2 action_prsnl = f8
     2 action_long_text_sk = f8
     2 action_value = vc
     2 action_dt_tm = dq8
     2 action_tm_zn = i4
     2 sa_item_usage_sk = f8
     2 sa_macro_sk = f8
     2 sa_ref_action_sk = f8
     2 action_item_action_val = vc
     2 action_item_long_text_sk = f8
     2 action_item_prsnl = f8
     2 active_ind = i2
     2 sa_r_action_item_sk = f8
 )
 RECORD anesthesia_parmval_parent_keys(
   1 qual[*]
     2 sa_anesthesia_record_id = f8
 )
 RECORD anesthesia_parmval_keys(
   1 qual[*]
     2 sa_parameter_value_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD anesthesia_parmval_info(
   1 qual[*]
     2 sa_parameter_val_sk = f8
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 anesthesia_record_sk = f8
     2 sa_macro_sk = f8
     2 parameter_prsnl = f8
     2 sa_ref_parameter_sk = f8
     2 sa_parameter_sk = f8
     2 previous_parameter_value_sk = f8
     2 copied_from_value_sk = f8
     2 event_sk = f8
     2 param_val_nomen = f8
     2 long_text_sk = f8
     2 param_val_prsnl = f8
     2 value_dt_tm = dq8
     2 numeric_value = f8
     2 chart_ind = i2
     2 device_alias = vc
     2 monitored_value_ind = i2
     2 active_ind = i2
     2 sa_parameter_val_tm_zn = i4
 )
 RECORD anesthesia_flditm_parent_keys(
   1 qual[*]
     2 sa_anesthesia_record_id = f8
 )
 RECORD anesthesia_flditm_keys(
   1 qual[*]
     2 sa_fluid_admin_item_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
 )
 RECORD anesthesia_flditm_info(
   1 qual[*]
     2 sa_fluid_admin_item_sk = f8
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 anesthesia_record_sk = f8
     2 sa_fluid_sk = f8
     2 sa_fluid_admin_sk = f8
     2 sa_r_fluid_sk = f8
     2 sa_macro_sk = f8
     2 fluid_prsnl = f8
     2 previous_fluid_admin_sk = f8
     2 sa_admin_macro_sk = f8
     2 io_event_sk = f8
     2 result_set_sk = f8
     2 group_event_sk = f8
     2 template_order_sk = f8
     2 event_sk = f8
     2 order_sk = f8
     2 task_sk = f8
     2 admin_stop_dt_tm = dq8
     2 admin_start_dt_tm = dq8
     2 admin_amount = f8
     2 amount_unit_ref = f8
     2 admin_route_ref = f8
     2 admin_site_ref = f8
     2 admin_rate_ref = f8
     2 sent_dt_tm = dq8
     2 weight = f8
     2 weight_unit_ref = f8
     2 wbd_weight_unit_ref = f8
     2 height = f8
     2 height_unit_ref = f8
     2 volume_amount_unit_ref = f8
     2 volume_rate_amount_unit_ref = i2
     2 volume_rate_time_unit_ref = f8
     2 fluid_admin_type_flg = f8
     2 wbd_time_unit_ref = f8
     2 wbd_dosage_unit_ref = f8
     2 long_text_sk = f8
     2 admin_prsnl = f8
     2 charged_ind = i2
     2 ddmo_ind = i2
     2 ordered_ind = i2
     2 volume_rate = f8
     2 weight_based_rate = f8
     2 src_active_ind = i2
     2 active_ind = i2
     2 sa_fluid_admin_item_tm_zn = i4
 )
 RECORD refaction_keys(
   1 qual[*]
     2 sa_action_sk = f8
 )
 RECORD ref_action(
   1 qual[*]
     2 sa_action_sk = f8
     2 action_description = vc
     2 action_name = vc
     2 action_name_format = vc
     2 bill_ind = i4
     2 child_selection_req_ind = i4
     2 default_value = vc
     2 original_ref_action_sk = f8
     2 print_ind = i4
     2 ref_type_flg = i4
     2 signature_required_ind = i4
     2 single_doc_ind = i4
     2 supervisor_sign_req_ind = i4
     2 task_assay_sk = f8
     2 value_required_ind = i4
     2 value_type_flg = i4
     2 version_nbr = i8
     2 prim_cat_name = vc
     2 prim_cat_name_frmt = vc
     2 prim_cat_type_ref = f8
     2 prim_cat_loc = f8
     2 prim_cat_ref_type_flg = i4
     2 sec_cat_name = vc
     2 sec_cat_name_frmt = vc
     2 sec_cat_type_ref = f8
     2 sec_cat_loc = f8
     2 sec_cat_ref_type_flg = i4
     2 src_active_ind = c1
 )
 RECORD encntr_dom_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD encntr_dom_keys(
   1 qual[*]
     2 encntr_domain_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD encntr_dom_info(
   1 qual[*]
     2 encntr_domain_sk = f8
     2 enc_nk = vc
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 encntr_domain_tm_zn = i4
     2 person_sk = f8
     2 encntr_domain_type_ref = f8
     2 patient_loc = f8
     2 med_service_ref = f8
     2 src_beg_effective_dt_tm = dq8
     2 src_end_effective_dt_tm = dq8
     2 active_ind = i2
 )
 RECORD caremgmt_cmclnrv_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD caremgmt_cmclnrv_keys(
   1 qual[*]
     2 clinical_review_sk = f8
     2 clin_review_sk = f8
     2 encounter_sk = f8
     2 clin_review_result_id = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD caremgmt_cmclnrv_info(
   1 qual[*]
     2 enc_nk = vc
     2 encounter_sk = f8
     2 clinical_review_sk = f8
     2 clin_review_result_id = f8
     2 clin_review_result_sk = vc
     2 clin_review_sk = f8
     2 content_source_ref = f8
     2 content_version_ref = f8
     2 episode_ident = vc
     2 result_xml_long_text_sk = f8
     2 reviewed_dt_tm = dq8
     2 cm_clin_review_tm_zn = i4
     2 review_result_ref = f8
     2 review_status_ref = f8
     2 review_sub_type_sk = f8
     2 review_sub_type = vc
     2 review_type_ref = f8
     2 review_type_unit_value = f8
     2 version_dt_tm = dq8
     2 result_ref = f8
     2 result_comment_sk = f8
     2 result_long_blob_sk = f8
     2 result_type_ref = f8
     2 action_meaning = vc
     2 clin_rvw_create_prsnl = f8
     2 clin_rvw_create_dt_tm = dq8
     2 clin_rvw_outcome_prsnl = f8
     2 clin_rvw_outcome_dt_tm = dq8
     2 clin_rvw_communicated_prsnl = f8
     2 clin_rvw_communicated_dt_tm = dq8
     2 clin_rvw_finalized_prsnl = f8
     2 clin_rvw_finalized_dt_tm = dq8
     2 loc_facility_cd = f8
 )
 RECORD cmsecrv_parent_keys(
   1 qual[*]
     2 clinical_review_id = f8
 )
 RECORD cmsecrv_keys(
   1 qual[*]
     2 cm_clin_sec_review_sk = f8
     2 cm_clin_review_sk = f8
     2 loc_facility_cd = f8
     2 encntr_clin_sec_review_sk = f8
     2 encounter_sk = f8
 )
 RECORD cmsecrv_info(
   1 qual[*]
     2 cm_clin_sec_review_sk = f8
     2 communication_type_ref = f8
     2 cm_clin_review_sk = f8
     2 clin_sec_review_sk = f8
     2 clinical_review_sk = f8
     2 encounter_sk = f8
     2 encntr_clin_sec_review_sk = f8
     2 loc_facility_cd = f8
     2 external_review_ind = f8
     2 sec_review_comment_sk = f8
     2 sec_review_outcome_ref = f8
     2 sec_review_reason_ref = f8
     2 sec_review_resp_party_sk = f8
     2 sec_review_resp_party_txt = vc
     2 version_dt_tm = dq8
     2 version_tm_zn = i4
 )
 RECORD avoid_days_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD avoid_days_keys(
   1 qual[*]
     2 encntr_avoidable_days_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD avoid_days_info(
   1 qual[*]
     2 cm_encntr_avoid_days_sk = f8
     2 enc_nk = vc
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 encntr_avoid_days_tm_zn = i4
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 comment_long_text_sk = f8
     2 reason_ref = f8
     2 reason_type_ref = f8
     2 resp_party_business_org = f8
     2 resp_party_nurse_unit_ref = f8
     2 resp_party_other_ref = f8
     2 resp_party_payer_org = f8
     2 resp_party_prsnl = f8
     2 resp_party_self_ind = i2
     2 resp_party_service_type_ref = f8
     2 tlc_facility_sk = f8
     2 active_ind = i2
 )
 RECORD readmit_ass_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD readmit_ass_keys(
   1 qual[*]
     2 encntr_readmit_assess_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD readmit_ass_info(
   1 qual[*]
     2 cm_encntr_readmit_assess_sk = f8
     2 enc_nk = vc
     2 encounter_sk = f8
     2 previous_encntr_sk = f8
     2 avoidable_readmission_ind = i2
     2 classification_ref = f8
     2 long_text_comment_sk = f8
     2 readmission_org = f8
     2 readmission_reason_ref = f8
     2 tlc_facility_sk = f8
 )
 RECORD caremgmt_cmapldny_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD caremgmt_cmapldny_keys(
   1 qual[*]
     2 encntr_denied_sk = f8
     2 encntr_denial_appeal_reltn_id = f8
     2 encntr_appeal_id = f8
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD caremgmt_cmapldny_info(
   1 qual[*]
     2 enc_nk = vc
     2 encntr_denial_appeal_reltn_id = f8
     2 encounter_sk = f8
     2 encntr_appeal_id = f8
     2 encntr_appeal_sk = vc
     2 encntr_denied_sk = f8
     2 appeal_tm_zn = i4
     2 denied_tm_zn = i4
     2 advisor_prsnl = f8
     2 loc_facility_cd = f8
     2 appeal_comm_type_ref = f8
     2 appeal_expect_resp_dt_tm = dq8
     2 appeal_level_ref = f8
     2 appeal_outcome_ref = f8
     2 appeal_outcome_dt_tm = dq8
     2 appeal_prsnl = f8
     2 appeal_sent_dt_tm = dq8
     2 appeal_status_ref = f8
     2 appeal_verified_dt_tm = dq8
     2 appeal_long_text_sk = f8
     2 ext_appeal_agency_ref = f8
     2 payer_org = f8
     2 post_appeal_level_of_care_ref = f8
     2 pre_appeal_level_of_care_ref = f8
     2 provided_level_of_care_ref = f8
     2 tracking_nbr_txt = vc
     2 denial_appeal_by_dt_tm = dq8
     2 denied_beg_dt_tm = dq8
     2 denied_end_dt_tm = dq8
     2 claim_nbr_txt = vc
     2 closed_dt_tm = dq8
     2 denial_long_text_sk = f8
     2 denial_category_ref = f8
     2 denial_prsnl = f8
     2 denial_reason_ref = f8
     2 denial_risk_amt = f8
     2 denial_type_ref = f8
     2 letter_dt_tm = dq8
     2 notice_received_dt_tm = dq8
     2 denial_payer_org = f8
     2 pft_queue_item_sk = f8
     2 remark_ref = f8
     2 resp_party_nurse_unit_loc = f8
     2 resp_party_other_ref = f8
     2 resp_party_prsnl = f8
     2 resp_party_self_ind = i2
     2 resp_party_service_type_ref = f8
     2 service_beg_dt_tm = dq8
     2 service_end_dt_tm = dq8
     2 active_ind = i2
 )
 RECORD care_mgmt_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD care_mgmt_keys(
   1 qual[*]
     2 encntr_care_mgmt_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD care_mgmt_info(
   1 qual[*]
     2 cm_care_mgmt_sk = f8
     2 enc_nk = vc
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 cm_care_mgmt_tm_zn = i4
     2 clinical_review_due_dt_tm = dq8
     2 disch_plan_due_dt_tm = dq8
     2 disch_plan_status_ref = f8
     2 document_review_due_dt_tm = dq8
     2 document_review_status_ref = f8
     2 utlztn_mgmt_status_ref = f8
     2 active_ind = i2
 )
 RECORD sch_object_keys(
   1 qual[*]
     2 sch_object_id = f8
     2 association_id = f8
 )
 RECORD sch_object_info(
   1 qual[*]
     2 sch_object_assoc_sk = vc
     2 sch_object_sk = f8
     2 association_sk = f8
     2 mnemonic = vc
     2 mnemonic_key = vc
     2 description = vc
     2 object_sub_ref = f8
     2 object_sub_meaning = vc
     2 object_type_ref = f8
     2 object_type_meaning = vc
     2 child_table = vc
     2 child_sk = f8
     2 seq_nbr = f8
     2 assoc_type_ref = f8
     2 assoc_type_meaning = vc
     2 data_source_ref = f8
     2 data_source_meaning = vc
     2 sch_object_assoc_tz = i4
     2 version_dt_tm = dq8
     2 obj_beg_effective_dt_tm = dq8
     2 obj_end_effective_dt_tm = dq8
     2 assoc_beg_effective_dt_tm = dq8
     2 assoc_end_effective_dt_tm = dq8
     2 active_ind = i2
 )
 RECORD event_alloc_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD event_alloc_keys(
   1 qual[*]
     2 him_event_allocation_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD event_alloc_info(
   1 qual[*]
     2 him_event_allocation_sk = f8
     2 enc_nk = vc
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 event_sk = f8
     2 deficiency_prsnl = f8
     2 event_ref = f8
     2 action_type_ref = f8
     2 him_event_alloc_tz = i4
     2 request_dt_tm = dq8
     2 completed_dt_tm = dq8
     2 allocation_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 action_status_ref = f8
     2 active_ind = i2
 )
 RECORD pv_chart_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD pv_chart_keys(
   1 qual[*]
     2 him_pv_chart_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD pv_chart_info(
   1 qual[*]
     2 him_pv_chart_sk = f8
     2 enc_nk = vc
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 person_sk = f8
     2 sex_ref = f8
     2 birth_dt_tm = dq8
     2 encntr_type_ref = f8
     2 med_service_ref = f8
     2 financial_class_ref = f8
     2 him_pv_chart_tz = i4
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 allocation_dt_tm = dq8
     2 allocation_dt_flag = i2
     2 allocation_dt_modifier = i2
     2 chart_status_ref = f8
     2 deficiency_ind = i2
     2 chart_age = i4
     2 delinquent_ind = i4
     2 current_loc_ref = f8
     2 media_type_ref = f8
     2 volume_nbr = i4
     2 suspended_ind = i2
     2 media_master_alias_sk = vc
     2 org_name = vc
     2 admitting_person_sk = f8
     2 attending_person_sk = f8
     2 def_allocation_date_ind = i2
     2 organization_sk = f8
     2 media_master_sk = f8
 )
 RECORD pv_doc_parent_keys(
   1 qual[*]
     2 encntr_id = f8
 )
 RECORD pv_doc_keys(
   1 qual[*]
     2 him_pv_document_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 enc_nk = vc
 )
 RECORD pv_doc_info(
   1 qual[*]
     2 him_pv_document_sk = f8
     2 enc_nk = vc
     2 encounter_sk = f8
     2 loc_facility_cd = f8
     2 person_sk = f8
     2 prsnl_group_name = vc
     2 action_prsnl = f8
     2 action_type_ref = f8
     2 action_status_ref = f8
     2 request_dt_tm = dq8
     2 request_tz = i4
     2 request_prsnl = f8
     2 request_prsnl_ft = vc
     2 event_ref = f8
     2 event_sk = f8
     2 active_ind = i2
     2 view_level = f8
     2 parent_event_sk = f8
     2 him_pv_document_tz = i4
     2 valid_from_dt_tm = dq8
     2 publish_flag = f8
     2 storage_ref = f8
     2 profile_status = vc
     2 profile_status_ref = f8
     2 prsnl_alias = vc
     2 org_name = vc
     2 event_end_dt_tm = dq8
     2 event_end_tz = i4
     2 organization_sk = f8
     2 chart_age = f8
     2 event_allocation_dt_tm = dq8
     2 prsnl_position_desc = vc
     2 result_status_ref = f8
     2 position_ref = f8
 )
 DECLARE a_resp_ind = c1 WITH noconstant(""), protect
 DECLARE alrt_ind = c1 WITH noconstant(""), protect
 DECLARE allrgy_ind = c1 WITH noconstant(""), protect
 DECLARE cd_value_ind = c1 WITH noconstant(""), protect
 DECLARE concept_ind = c1 WITH noconstant(""), protect
 DECLARE diag_ind = c1 WITH noconstant(""), protect
 DECLARE enc_cmb_ind = c1 WITH noconstant(""), protect
 DECLARE enc_grp_ind = c1 WITH noconstant(""), protect
 DECLARE enc_hist_ind = c1 WITH noconstant(""), protect
 DECLARE enc_ins_ind = c1 WITH noconstant(""), protect
 DECLARE enc_psnl_ind = c1 WITH noconstant(""), protect
 DECLARE encntr_ind = c1 WITH noconstant(""), protect
 DECLARE fl_cyc_h_ind = c1 WITH noconstant(""), protect
 DECLARE hlth_pln_ind = c1 WITH noconstant(""), protect
 DECLARE loc_hier_ind = c1 WITH noconstant(""), protect
 DECLARE location_ind = c1 WITH noconstant(""), protect
 DECLARE loc_grp_ind = c1 WITH noconstant(""), protect
 DECLARE med_admn_ind = c1 WITH noconstant(""), protect
 DECLARE med_prod_ind = c1 WITH noconstant(""), protect
 DECLARE med_item_ind = c1 WITH noconstant(""), protect
 DECLARE nomen_ind = c1 WITH noconstant(""), protect
 DECLARE orgn_ind = c1 WITH noconstant(""), protect
 DECLARE pathway_ind = c1 WITH noconstant(""), protect
 DECLARE per_prsl_ind = c1 WITH noconstant(""), protect
 DECLARE prcdr_ind = c1 WITH noconstant(""), protect
 DECLARE order_ind = c1 WITH noconstant(""), protect
 DECLARE ordrbl_ind = c1 WITH noconstant(""), protect
 DECLARE ref_rnge_ind = c1 WITH noconstant(""), protect
 DECLARE task_asy_ind = c1 WITH noconstant(""), protect
 DECLARE micro_ind = c1 WITH noconstant(""), protect
 DECLARE clin_evnt_ind = c1 WITH noconstant(""), protect
 DECLARE evnt_cd_rst_ind = c1 WITH noconstant(""), protect
 DECLARE intk_otpt_rst_ind = c1 WITH noconstant(""), protect
 DECLARE evnt_prsl_ind = c1 WITH noconstant(""), protect
 DECLARE es_hier_ind = c1 WITH noconstant(""), protect
 DECLARE svcres_d_ind = c1 WITH noconstant(""), protect
 DECLARE res_grp_ind = c1 WITH noconstant(""), protect
 DECLARE docinput_ind = c1 WITH noconstant(""), protect
 DECLARE docresp_ind = c1 WITH noconstant(""), protect
 DECLARE gen_lab_ind = c1 WITH noconstant(""), protect
 DECLARE gen_lab_raw_ind = c1 WITH noconstant(""), protect
 DECLARE evnt_mod_ind = c1 WITH noconstant(""), protect
 DECLARE problem_ind = c1 WITH noconstant(""), protect
 DECLARE pha_order_ind = c1 WITH noconstant(""), protect
 DECLARE pha_ingredient_ind = c1 WITH noconstant(""), protect
 DECLARE pha_dispense_ind = c1 WITH noconstant(""), protect
 DECLARE pha_retail_ind = c1 WITH noconstant(""), protect
 DECLARE surgery_ind = c1 WITH noconstant(""), protect
 DECLARE suscept_ind = c1 WITH noconstant(""), protect
 DECLARE rd_order_ind = c1 WITH noconstant(""), protect
 DECLARE scheduling_ind = c1 WITH noconstant(""), protect
 DECLARE ed_ind = c1 WITH noconstant(""), protect
 DECLARE details_ref_ind = c1 WITH noconstant(""), protect
 DECLARE ap_ind = c1 WITH noconstant(""), protect
 DECLARE encntr_flex_hist_ind = c1 WITH noconstant(""), protect
 DECLARE es_canon_ind = c1 WITH noconstant(""), protect
 DECLARE pr_alias_ind = c1 WITH noconstant(""), protect
 DECLARE pr_psl_r_ind = c1 WITH noconstant(""), protect
 DECLARE lng_text_ind = c1 WITH noconstant(""), protect
 DECLARE powernote_ind = c1 WITH noconstant(""), protect
 DECLARE encntr_slice_ind = c1 WITH noconstant(""), protect
 DECLARE wait_list_ind = c1 WITH noconstant(""), protect
 DECLARE user_defined_hist_ind = c1 WITH noconstant(""), protect
 DECLARE encntr_augm_care_period_ind = c1 WITH noconstant(""), protect
 DECLARE enc_accident_ind = c1 WITH noconstant(""), protect
 DECLARE episode_encounter_ind = c1 WITH noconstant(""), protect
 DECLARE address_ind = c1 WITH noconstant(""), protect
 DECLARE phone_ind = c1 WITH noconstant(""), protect
 DECLARE encntr_leave_ind = c1 WITH noconstant(""), protect
 DECLARE benefit_alloc_ind = c1 WITH noconstant(""), protect
 DECLARE benefit_ind = c1 WITH noconstant(""), protect
 DECLARE per_nam_ind = c1 WITH noconstant(""), protect
 DECLARE per_per_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE org_org_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE cd_value_ext_ind = c1 WITH noconstant(""), protect
 DECLARE cd_grp_ind = c1 WITH noconstant(""), protect
 DECLARE enc_enc_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE loc_atr_ind = c1 WITH noconstant(""), protect
 DECLARE multum_ind = c1 WITH noconstant(""), protect
 DECLARE cd_value_out_ind = c1 WITH noconstant(""), protect
 DECLARE pct_sha_ind = c1 WITH noconstant(""), protect
 DECLARE cdsctnt_ind = c1 WITH noconstant(""), protect
 DECLARE prsnl_org_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE cds_batch_content_hist_ind = c1 WITH noconstant(""), protect
 DECLARE enc_info_ind = c1 WITH noconstant(""), protect
 DECLARE cds_batch_ind = c1 WITH noconstant(""), protect
 DECLARE cds_batch_hist_ind = c1 WITH noconstant(""), protect
 DECLARE wl_stat_ind = c1 WITH noconstant(""), protect
 DECLARE person_info_ind = c1 WITH noconstant(""), protect
 DECLARE hist_per_raw_ind = c1 WITH noconstant(""), protect
 DECLARE profit_ind = c1 WITH noconstant(""), protect
 DECLARE media_master_ind = c1 WITH noconstant(""), protect
 DECLARE requester_ind = c1 WITH noconstant(""), protect
 DECLARE him_request_ind = c1 WITH noconstant(""), protect
 DECLARE pm_post_doc_ind = c1 WITH noconstant(""), protect
 DECLARE edw_ind = c1 WITH noconstant(""), protect
 DECLARE healthfacts_ind = c1 WITH noconstant(""), protect
 DECLARE healthsentry_ind = c1 WITH noconstant(""), protect
 DECLARE raw_table = c1 WITH noconstant(""), protect
 DECLARE ce_spec_ind = c1 WITH noconstant(""), protect
 DECLARE chrg_ind = c1 WITH noconstant(""), protect
 DECLARE chrg_mod_ind = c1 WITH noconstant(""), protect
 DECLARE per_atr_ind = c1 WITH noconstant(""), protect
 DECLARE ce_assoc_ind = c1 WITH noconstant(""), protect
 DECLARE person_prsnl_org_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE rd_order_sub_activity_ind = c1 WITH noconstant(""), protect
 DECLARE periop_doc_proc_ind = c1 WITH noconstant(""), protect
 DECLARE eps_ind = c1 WITH noconstant(""), protect
 DECLARE ce_micro_ind = c1 WITH noconstant(""), protect
 DECLARE prsnl_alias_ind = c1 WITH noconstant(""), protect
 DECLARE maternity_ind = c1 WITH noconstant(""), protect
 DECLARE social_history_ind = c1 WITH noconstant(""), protect
 DECLARE application_context_ind = c1 WITH noconstant(""), protect
 DECLARE order_container_ind = c1 WITH noconstant(""), protect
 DECLARE questionnaire_ind = c1 WITH noconstant(""), protect
 DECLARE inventory_ref_ind = c1 WITH noconstant(""), protect
 DECLARE pm_offer_ind = c1 WITH noconstant(""), protect
 DECLARE label_ind = c1 WITH noconstant(""), protect
 DECLARE health_maint_ind = c1 WITH noconstant(""), protect
 DECLARE bedside_care_ind = c1 WITH noconstant(""), protect
 DECLARE abstract_data_ind = c1 WITH noconstant(""), protect
 DECLARE pathway_custom_ind = c1 WITH noconstant(""), protect
 DECLARE task_activity_ind = c1 WITH noconstant(""), protect
 DECLARE ce_event_note_ind = c1 WITH noconstant(""), protect
 DECLARE blood_bank_ind = c1 WITH noconstant(""), protect
 DECLARE scheduling_sub_activity_ind = c1 WITH noconstant(""), protect
 DECLARE ce_blob_ind = c1 WITH noconstant(""), protect
 DECLARE rd_report_detail_ind = c1 WITH noconstant(""), protect
 DECLARE long_blob_ind = c1 WITH noconstant(""), protect
 DECLARE lh_abs_ind = c1 WITH noconstant(""), protect
 DECLARE lh_qrda_ind = c1 WITH noconstant(""), protect
 DECLARE family_history_ind = c1 WITH noconstant(""), protect
 DECLARE surgery_pref_ind = c1 WITH noconstant(""), protect
 DECLARE si_oid_ind = c1 WITH noconstant(""), protect
 DECLARE drg_ext_ind = c1 WITH noconstant(""), protect
 DECLARE bedrock_hs_ind = c1 WITH noconstant(""), protect
 DECLARE encntr_person_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE mental_health_ind = c1 WITH noconstant(""), protect
 DECLARE legal_status_ind = c1 WITH noconstant(""), protect
 DECLARE pm_info_hist_ind = c1 WITH noconstant(""), protect
 DECLARE mammogram_ind = c1 WITH noconstant(""), protect
 DECLARE rad_fol_up_field_ind = c1 WITH noconstant(""), protect
 DECLARE prsnl_grp_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE signature_ind = c1 WITH noconstant(""), protect
 DECLARE long_text_ref_ind = c1 WITH noconstant(""), protect
 DECLARE consent_ind = c1 WITH noconstant(""), protect
 DECLARE lh_phi_null_ind = c1 WITH noconstant(""), protect
 DECLARE lh_e_ind = c1 WITH noconstant(""), protect
 DECLARE raw_interp_ind = c1 WITH noconstant(""), protect
 DECLARE gl_balance_ind = c1 WITH noconstant(""), protect
 DECLARE br_map_ind = c1 WITH noconstant(""), protect
 DECLARE anesthesia_ind = c1 WITH noconstant(""), protect
 DECLARE care_management_ind = c1 WITH noconstant(""), protect
 DECLARE lighthouse_readmission_ind = c1 WITH noconstant(""), protect
 DECLARE ordr_ordr_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE person_org_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE hist_a_resp_ind = c1 WITH noconstant(""), protect
 DECLARE hist_alrt_ind = c1 WITH noconstant(""), protect
 DECLARE hist_allrgy_ind = c1 WITH noconstant(""), protect
 DECLARE hist_cd_value_ind = c1 WITH noconstant(""), protect
 DECLARE hist_concept_ind = c1 WITH noconstant(""), protect
 DECLARE hist_diag_ind = c1 WITH noconstant(""), protect
 DECLARE hist_enc_cmb_ind = c1 WITH noconstant(""), protect
 DECLARE hist_enc_grp_ind = c1 WITH noconstant(""), protect
 DECLARE hist_enc_hist_ind = c1 WITH noconstant(""), protect
 DECLARE hist_enc_ins_ind = c1 WITH noconstant(""), protect
 DECLARE hist_enc_psnl_ind = c1 WITH noconstant(""), protect
 DECLARE hist_encntr_ind = c1 WITH noconstant(""), protect
 DECLARE hist_fl_cyc_h_ind = c1 WITH noconstant(""), protect
 DECLARE hist_hlth_pln_ind = c1 WITH noconstant(""), protect
 DECLARE hist_loc_hier_ind = c1 WITH noconstant(""), protect
 DECLARE hist_location_ind = c1 WITH noconstant(""), protect
 DECLARE hist_loc_grp_ind = c1 WITH noconstant(""), protect
 DECLARE hist_med_admn_ind = c1 WITH noconstant(""), protect
 DECLARE hist_med_prod_ind = c1 WITH noconstant(""), protect
 DECLARE hist_med_item_ind = c1 WITH noconstant(""), protect
 DECLARE hist_nomen_ind = c1 WITH noconstant(""), protect
 DECLARE hist_orgn_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pathway_ind = c1 WITH noconstant(""), protect
 DECLARE hist_per_prsl_ind = c1 WITH noconstant(""), protect
 DECLARE hist_prcdr_ind = c1 WITH noconstant(""), protect
 DECLARE hist_order_ind = c1 WITH noconstant(""), protect
 DECLARE hist_ordrbl_ind = c1 WITH noconstant(""), protect
 DECLARE hist_ref_rnge_ind = c1 WITH noconstant(""), protect
 DECLARE hist_task_asy_ind = c1 WITH noconstant(""), protect
 DECLARE hist_micro_ind = c1 WITH noconstant(""), protect
 DECLARE hist_clin_evnt_ind = c1 WITH noconstant(""), protect
 DECLARE hist_evnt_cd_rst_ind = c1 WITH noconstant(""), protect
 DECLARE hist_intk_otpt_rst_ind = c1 WITH noconstant(""), protect
 DECLARE hist_evnt_prsl_ind = c1 WITH noconstant(""), protect
 DECLARE hist_es_hier_ind = c1 WITH noconstant(""), protect
 DECLARE hist_svcres_d_ind = c1 WITH noconstant(""), protect
 DECLARE hist_res_grp_ind = c1 WITH noconstant(""), protect
 DECLARE hist_docinput_ind = c1 WITH noconstant(""), protect
 DECLARE hist_docresp_ind = c1 WITH noconstant(""), protect
 DECLARE hist_gen_lab_ind = c1 WITH noconstant(""), protect
 DECLARE hist_gen_lab_raw_ind = c1 WITH noconstant(""), protect
 DECLARE hist_evnt_mod_ind = c1 WITH noconstant(""), protect
 DECLARE hist_problem_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pha_order_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pha_ingredient_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pha_dispense_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pha_retail_ind = c1 WITH noconstant(""), protect
 DECLARE hist_surgery_ind = c1 WITH noconstant(""), protect
 DECLARE hist_suscept_ind = c1 WITH noconstant(""), protect
 DECLARE hist_rd_order_ind = c1 WITH noconstant(""), protect
 DECLARE hist_scheduling_ind = c1 WITH noconstant(""), protect
 DECLARE hist_ed_ind = c1 WITH noconstant(""), protect
 DECLARE hist_details_ref_ind = c1 WITH noconstant(""), protect
 DECLARE hist_ap_ind = c1 WITH noconstant(""), protect
 DECLARE hist_encntr_flex_hist_ind = c1 WITH noconstant(""), protect
 DECLARE hist_es_canon_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pr_alias_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pr_psl_r_ind = c1 WITH noconstant(""), protect
 DECLARE hist_lng_text_ind = c1 WITH noconstant(""), protect
 DECLARE hist_powernote_ind = c1 WITH noconstant(""), protect
 DECLARE hist_encntr_slice_ind = c1 WITH noconstant(""), protect
 DECLARE hist_wait_list_ind = c1 WITH noconstant(""), protect
 DECLARE hist_user_defined_hist_ind = c1 WITH noconstant(""), protect
 DECLARE hist_encntr_augm_care_period_ind = c1 WITH noconstant(""), protect
 DECLARE hist_enc_accident_ind = c1 WITH noconstant(""), protect
 DECLARE hist_episode_encounter_ind = c1 WITH noconstant(""), protect
 DECLARE hist_address_ind = c1 WITH noconstant(""), protect
 DECLARE hist_phone_ind = c1 WITH noconstant(""), protect
 DECLARE hist_encntr_leave_ind = c1 WITH noconstant(""), protect
 DECLARE hist_benefit_alloc_ind = c1 WITH noconstant(""), protect
 DECLARE hist_benefit_ind = c1 WITH noconstant(""), protect
 DECLARE hist_per_nam_ind = c1 WITH noconstant(""), protect
 DECLARE hist_per_per_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE hist_org_org_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE hist_cd_value_ext_ind = c1 WITH noconstant(""), protect
 DECLARE hist_cd_value_out_ind = c1 WITH noconstant(""), protect
 DECLARE hist_cd_grp_ind = c1 WITH noconstant(""), protect
 DECLARE hist_enc_enc_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE hist_loc_atr_ind = c1 WITH noconstant(""), protect
 DECLARE hist_multum_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pct_sha_ind = c1 WITH noconstant(""), protect
 DECLARE hist_cdsctnt_ind = c1 WITH noconstant(""), protect
 DECLARE hist_prsnl_org_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE hist_cds_batch_content_hist_ind = c1 WITH noconstant(""), protect
 DECLARE hist_enc_info_ind = c1 WITH noconstant(""), protect
 DECLARE hist_cds_batch_ind = c1 WITH noconstant(""), protect
 DECLARE hist_cds_batch_hist_ind = c1 WITH noconstant(""), protect
 DECLARE hist_wl_stat_ind = c1 WITH noconstant(""), protect
 DECLARE hist_person_info_ind = c1 WITH noconstant(""), protect
 DECLARE hist_profit_ind = c1 WITH noconstant(""), protect
 DECLARE hist_media_master_ind = c1 WITH noconstant(""), protect
 DECLARE hist_requester_ind = c1 WITH noconstant(""), protect
 DECLARE hist_him_request_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pm_post_doc_ind = c1 WITH noconstant(""), protect
 DECLARE hist_ce_spec_ind = c1 WITH noconstant(""), protect
 DECLARE hist_chrg_ind = c1 WITH noconstant(""), protect
 DECLARE hist_chrg_mod_ind = c1 WITH noconstant(""), protect
 DECLARE hist_per_atr_ind = c1 WITH noconstant(""), protect
 DECLARE hist_ce_assoc_ind = c1 WITH noconstant(""), protect
 DECLARE hist_person_prsnl_org_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE hist_rd_order_sub_activity_ind = c1 WITH noconstant(""), protect
 DECLARE hist_eps_ind = c1 WITH noconstant(""), protect
 DECLARE hist_ce_micro_ind = c1 WITH noconstant(""), protect
 DECLARE hist_activity = c1 WITH noconstant(""), protect
 DECLARE hist_reference = c1 WITH noconstant(""), protect
 DECLARE hist_raw_table = c1 WITH noconstant(""), protect
 DECLARE hist_solution = c16 WITH noconstant(""), protect
 DECLARE hist_parallelism = c1 WITH noconstant(""), protect
 DECLARE hist_prsnl_alias_ind = c1 WITH noconstant(""), protect
 DECLARE hist_maternity_ind = c1 WITH noconstant(""), protect
 DECLARE hist_bedrock_ind = c1 WITH noconstant(""), protect
 DECLARE hist_lighthouse_ind = c1 WITH noconstant(""), protect
 DECLARE hist_social_history_ind = c1 WITH noconstant(""), protect
 DECLARE hist_application_context_ind = c1 WITH noconstant(""), protect
 DECLARE hist_order_container_ind = c1 WITH noconstant(""), protect
 DECLARE hist_questionnaire_ind = c1 WITH noconstant(""), protect
 DECLARE hist_inventory_ref_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pm_offer_ind = c1 WITH noconstant(""), protect
 DECLARE hist_label_ind = c1 WITH noconstant(""), protect
 DECLARE hist_health_maint_ind = c1 WITH noconstant(""), protect
 DECLARE hist_bedside_care_ind = c1 WITH noconstant(""), protect
 DECLARE hist_abstract_data_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pathway_custom_ind = c1 WITH noconstant(""), protect
 DECLARE hist_task_activity_ind = c1 WITH noconstant(""), protect
 DECLARE hist_ce_event_note_ind = c1 WITH noconstant(""), protect
 DECLARE hist_blood_bank_ind = c1 WITH noconstant(""), protect
 DECLARE hist_scheduling_sub_activity_ind = c1 WITH noconstant(""), protect
 DECLARE hist_ce_blob_ind = c1 WITH noconstant(""), protect
 DECLARE hist_rd_report_detail_ind = c1 WITH noconstant(""), protect
 DECLARE hist_long_blob_ind = c1 WITH noconstant(""), protect
 DECLARE hist_lh_abs_ind = c1 WITH noconstant(""), protect
 DECLARE hist_lh_qrda_ind = c1 WITH noconstant(""), protect
 DECLARE hist_family_history_ind = c1 WITH noconstant(""), protect
 DECLARE hist_surgery_pref_ind = c1 WITH noconstant(""), protect
 DECLARE hist_si_oid_ind = c1 WITH noconstant(""), protect
 DECLARE hist_drg_ext_ind = c1 WITH noconstant(""), protect
 DECLARE hist_encntr_person_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE hist_mental_health_ind = c1 WITH noconstant(""), protect
 DECLARE hist_legal_status_ind = c1 WITH noconstant(""), protect
 DECLARE hist_pm_info_hist_ind = c1 WITH noconstant(""), protect
 DECLARE hist_mammogram_ind = c1 WITH noconstant(""), protect
 DECLARE hist_rad_fol_up_field_ind = c1 WITH noconstant(""), protect
 DECLARE hist_prsnl_grp_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE hist_bedrock_hs_ind = c1 WITH noconstant(""), protect
 DECLARE hist_signature_ind = c1 WITH noconstant(""), protect
 DECLARE hist_long_text_ref_ind = c1 WITH noconstant(""), protect
 DECLARE hist_consent_ind = c1 WITH noconstant(""), protect
 DECLARE hist_lh_e_ind = c1 WITH noconstant(""), protect
 DECLARE hist_raw_interp_ind = c1 WITH noconstant(""), protect
 DECLARE hist_gl_balance_ind = c1 WITH noconstant(""), protect
 DECLARE hist_br_map_ind = c1 WITH noconstant(""), protect
 DECLARE hist_anesthesia_ind = c1 WITH noconstant(""), protect
 DECLARE hist_care_management_ind = c1 WITH noconstant(""), protect
 DECLARE hist_lighthouse_readmission_ind = c1 WITH noconstant(""), protect
 DECLARE hist_ordr_ordr_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE hist_person_org_reltn_ind = c1 WITH noconstant(""), protect
 DECLARE p_address = c1 WITH noconstant(""), protect
 DECLARE p_encntr_person_reltn = c1 WITH noconstant(""), protect
 DECLARE p_person_person_reltn = c1 WITH noconstant(""), protect
 DECLARE p_person_prsnl_reltn = c1 WITH noconstant(""), protect
 DECLARE p_person_alias = c1 WITH noconstant(""), protect
 DECLARE p_person_name = c1 WITH noconstant(""), protect
 DECLARE p_person_org_reltn = c1 WITH noconstant(""), protect
 DECLARE p_person_patient = c1 WITH noconstant(""), protect
 DECLARE p_phone = c1 WITH noconstant(""), protect
 DECLARE p_prsnl_alias = c1 WITH noconstant(""), protect
 DECLARE p_next_of_kin = c1 WITH noconstant(""), protect
 DECLARE drg_extension_ind = c1 WITH noconstant(""), protect
 DECLARE icd9_extension_ind = c1 WITH noconstant(""), protect
 DECLARE p_prsnl_rltn_ind = c1 WITH noconstant(""), protect
 DECLARE drg_enc_ext_ind = c1 WITH noconstant(""), protect
 DECLARE d_encounter = c1 WITH noconstant(""), protect
 DECLARE org_address = c1 WITH noconstant(""), protect
 DECLARE org_phone = c1 WITH noconstant(""), protect
 DECLARE org_location = c1 WITH noconstant(""), protect
 DECLARE e_encntr_alias = c1 WITH noconstant(""), protect
 DECLARE e_coding = c1 WITH noconstant(""), protect
 DECLARE p_coding = c1 WITH noconstant(""), protect
 DECLARE hp_org_plan_reltn = c1 WITH noconstant(""), protect
 DECLARE hp_encntr_plan_reltn = c1 WITH noconstant(""), protect
 DECLARE hp_person_plan_reltn = c1 WITH noconstant(""), protect
 DECLARE ei_person_plan_reltn = c1 WITH noconstant(""), protect
 DECLARE order_catalog_synonym = c1 WITH noconstant(""), protect
 DECLARE order_code_value_extension = c1 WITH noconstant(""), protect
 DECLARE mic_container = c1 WITH noconstant(""), protect
 DECLARE mic_osrc = c1 WITH noconstant(""), protect
 DECLARE mic_v500_specimen = c1 WITH noconstant(""), protect
 DECLARE mic_order_laboratory = c1 WITH noconstant(""), protect
 DECLARE mic_long_text = c1 WITH noconstant(""), protect
 DECLARE sr_code_value = c1 WITH noconstant(""), protect
 DECLARE sr_service_resource = c1 WITH noconstant(""), protect
 DECLARE loc_location_ind = c1 WITH noconstant(""), protect
 DECLARE loc_code_value_ind = c1 WITH noconstant(""), protect
 DECLARE ma_rad_med_details = c1 WITH noconstant(""), protect
 DECLARE ma_order_radiology = c1 WITH noconstant(""), protect
 DECLARE fc_fill_batch_hx = c1 WITH noconstant(""), protect
 DECLARE mp_item_master_ind = c1 WITH noconstant(""), protect
 DECLARE mp_obj_idnt_idx_ind = c1 WITH noconstant(""), protect
 DECLARE mp_schd_day_of_week_ind = c1 WITH noconstant(""), protect
 DECLARE mp_schd_time_of_day_ind = c1 WITH noconstant(""), protect
 DECLARE pw_pathway_action_ind = c1 WITH noconstant(""), protect
 DECLARE pd_glb_result_event = c1 WITH noconstant(""), protect
 DECLARE pd_glb_long_text = c1 WITH noconstant(""), protect
 DECLARE pd_glb_v500_spec = c1 WITH noconstant(""), protect
 DECLARE pd_glb_container = c1 WITH noconstant(""), protect
 DECLARE pd_glb_osrc = c1 WITH noconstant(""), protect
 DECLARE pd_glb_ord_detl = c1 WITH noconstant(""), protect
 DECLARE po_order_dispense = c1 WITH noconstant(""), protect
 DECLARE pod_template_nonformulary = c1 WITH noconstant(""), protect
 DECLARE pd_order_action = c1 WITH noconstant(""), protect
 DECLARE sa_sch_event_patient = c1 WITH noconstant(""), protect
 DECLARE sa_sch_location = c1 WITH noconstant(""), protect
 DECLARE atdr_code_value = c1 WITH noconstant(""), protect
 DECLARE enc_pft_encntr_ind = c1 WITH noconstant(""), protect
 DECLARE pd_equip_master = c1 WITH noconstant("Y"), protect
 DECLARE pd_item_class_node = c1 WITH noconstant("Y"), protect
 DECLARE pd_seg_header = c1 WITH noconstant("Y"), protect
 DECLARE rd_pull_list = c1 WITH noconstant(""), protect
 DECLARE order_rad = c1 WITH noconstant(""), protect
 DECLARE surg_cs_perioperative_document = c1 WITH noconstant("Y"), protect
 DECLARE surg_cs_case_times = c1 WITH noconstant("Y"), protect
 DECLARE surg_cs_sn_surg_case_st = c1 WITH noconstant("Y"), protect
 DECLARE surg_cs_clinical_event = c1 WITH noconstant("Y"), protect
 DECLARE surg_p_perioperative_document = c1 WITH noconstant("Y"), protect
 DECLARE surg_p_segment_header = c1 WITH noconstant("Y"), protect
 DECLARE surg_p_surg_case_proc_modifier = c1 WITH noconstant("Y"), protect
 DECLARE surg_dly_perioperative_document = c1 WITH noconstant("Y"), protect
 DECLARE surg_dly_segment_header = c1 WITH noconstant("Y"), protect
 DECLARE surg_att_perioperative_document = c1 WITH noconstant("Y"), protect
 DECLARE surg_att_segment_procedure = c1 WITH noconstant("Y"), protect
 DECLARE surg_att_segment_header = c1 WITH noconstant("Y"), protect
 DECLARE sc_sch_booking = c1 WITH noconstant(""), protect
 DECLARE outcome_pw_variance_reltn = c1 WITH noconstant(" "), protect
 DECLARE sch_entry = c1 WITH noconstant("N"), protect
 DECLARE sch_cv = c1 WITH noconstant("Y"), protect
 DECLARE sch_det_ref = c1 WITH noconstant("Y"), protect
 DECLARE sch_slot_ref = c1 WITH noconstant("N"), protect
 DECLARE pwo_pathway_action_ind = c1 WITH noconstant(""), protect
 DECLARE sus_mic_evnt_dtl_ind = vc WITH noconstant(""), protect
 DECLARE ed_pat_ed_document = vc WITH noconstant(""), protect
 DECLARE ed_tracking_prsnl = vc WITH noconstant(""), protect
 DECLARE ap_spec_ap_tag = c1 WITH noconstant("N"), protect
 DECLARE ap_spec_long_text = c1 WITH noconstant("N"), protect
 DECLARE ap_diag_ap_dc_study = c1 WITH noconstant("N"), protect
 DECLARE ap_diag_ap_dc_discrepancy_term = c1 WITH noconstant("Y"), protect
 DECLARE ap_diag_ap_dc_evaluation_term = c1 WITH noconstant("Y"), protect
 DECLARE ap_blk_ap_tag = c1 WITH noconstant("N"), protect
 DECLARE ap_profile_task_r = c1 WITH noconstant("N"), protect
 DECLARE ap_process_ap_tag = c1 WITH noconstant("N"), protect
 DECLARE ap_case_specimen = c1 WITH noconstant("Y"), protect
 DECLARE ap_slide_ap_tag = c1 WITH noconstant("N"), protect
 DECLARE case_ap_qa_info = c1 WITH noconstant("N"), protect
 DECLARE case_long_text = c1 WITH noconstant("N"), protect
 DECLARE report_ce_blob = c1 WITH noconstant("N"), protect
 DECLARE report_clinical_event = c1 WITH noconstant("Y"), protect
 DECLARE concept_scd_term = c1 WITH noconstant("Y"), protect
 DECLARE concept_case_specimen = c1 WITH noconstant("N"), protect
 DECLARE concept_case_report = c1 WITH noconstant("N"), protect
 DECLARE ap_long_text = c1 WITH noconstant("N"), protect
 DECLARE term_scd_sentence = c1 WITH noconstant("N"), protect
 DECLARE term_scd_paragraph = c1 WITH noconstant("N"), protect
 DECLARE story_clinical_event = c1 WITH noconstant("Y"), protect
 DECLARE pn_scr_sentence = c1 WITH noconstant("N"), protect
 DECLARE pn_scr_paragraph = c1 WITH noconstant("N"), protect
 DECLARE pn_scr_action = c1 WITH noconstant("N"), protect
 DECLARE acp_encntr_loc_hist = c1 WITH noconstant("N"), protect
 DECLARE acp_encntr_flex_hist = c1 WITH noconstant("N"), protect
 DECLARE ea_tracking_checkin = c1 WITH noconstant("N"), protect
 DECLARE ea_tracking_event = c1 WITH noconstant("N"), protect
 DECLARE episode_encntr_reltn = c1 WITH noconstant("N"), protect
 DECLARE encntr_leave_encounter = c1 WITH noconstant("N"), protect
 DECLARE wl_stat_wait_list = c1 WITH noconstant("N"), protect
 DECLARE fin_encounter_coding = c1 WITH noconstant("Y"), protect
 DECLARE fin_encounter_pft_queue_item = c1 WITH noconstant("Y"), protect
 DECLARE fin_encounter_bill_rec = c1 WITH noconstant("Y"), protect
 DECLARE fin_encounter_daily_encntr_bal = c1 WITH noconstant("Y"), protect
 DECLARE fin_encounter_pe_status_reason = c1 WITH noconstant("Y"), protect
 DECLARE fin_encounter_pft_proration = c1 WITH noconstant("N"), protect
 DECLARE fin_encounter_encntr_plan_reltn = c1 WITH noconstant("Y"), protect
 DECLARE fin_encounter_bo_hp_reltn = c1 WITH noconstant("Y"), protect
 DECLARE fin_bill_bill_rec = c1 WITH noconstant("Y"), protect
 DECLARE fin_bill_bo_hp_reltn = c1 WITH noconstant("Y"), protect
 DECLARE fin_bill_denial = c1 WITH noconstant("Y"), protect
 DECLARE fin_bill_pft_queue_item = c1 WITH noconstant("Y"), protect
 DECLARE fin_bill_pft_queue_item_hist = c1 WITH noconstant("Y"), protect
 DECLARE fin_p_payment_plan = c1 WITH noconstant("Y"), protect
 DECLARE fin_chrg_pft_trans_reltn = c1 WITH noconstant("Y"), protect
 DECLARE fin_chrg_gl_trans_log = c1 WITH noconstant("Y"), protect
 DECLARE fin_chrg_charge_mod = c1 WITH noconstant("Y"), protect
 DECLARE fin_chrg_pft_charge = c1 WITH noconstant("Y"), protect
 DECLARE fin_pay_adj_ptr = c1 WITH noconstant("Y"), protect
 DECLARE fin_pay_adj_pay_detail = c1 WITH noconstant("Y"), protect
 DECLARE fin_pay_adj_gtl = c1 WITH noconstant("Y"), protect
 DECLARE fin_denial_ptr = c1 WITH noconstant("Y"), protect
 DECLARE fin_denial_bill_rec = c1 WITH noconstant("Y"), protect
 DECLARE fin_denial_pft_encntr = c1 WITH noconstant("Y"), protect
 DECLARE fin_denial_batch_trans_file = c1 WITH noconstant("N"), protect
 DECLARE fin_denial_batch_trans = c1 WITH noconstant("N"), protect
 DECLARE mma_alias_media_master = c1 WITH noconstant("N"), protect
 DECLARE hr_him_request_patient = c1 WITH noconstant("N"), protect
 DECLARE task_asy_ce = c1 WITH noconstant("N"), protect
 DECLARE fin_chrg_charge = c1 WITH noconstant("N"), protect
 DECLARE fin_chrg_workload = c1 WITH noconstant("N"), protect
 DECLARE fin_chrg_charge_event_act = c1 WITH noconstant("N"), protect
 DECLARE fin_chrg_charge_event = c1 WITH noconstant("N"), protect
 DECLARE rd_rad_exam_prsnl = c1 WITH noconstant("N"), protect
 DECLARE rd_rad_exam = c1 WITH noconstant("N"), protect
 DECLARE rd_rad_report = c1 WITH noconstant("N"), protect
 DECLARE rd_radexam_order_radiology = c1 WITH noconstant("N"), protect
 DECLARE rd_rad_rpt_order_radiology = c1 WITH noconstant("N"), protect
 DECLARE eps_track_ind = c1 WITH noconstant("N"), protect
 DECLARE maternity_pregnancy_action = c1 WITH noconstant("N"), protect
 DECLARE maternity_pregnancy_entity_r = c1 WITH noconstant("N"), protect
 DECLARE maternity_pregnancy_child_entity_r = c1 WITH noconstant("N",protect)
 DECLARE shx_action = c1 WITH noconstant("N",protect)
 DECLARE shx_alpha_response = c1 WITH noconstant("N",protect)
 DECLARE shx_category_ref = c1 WITH noconstant("N",protect)
 DECLARE shx_category_def = c1 WITH noconstant("N",protect)
 DECLARE qst_questionnaire = c1 WITH noconstant("N",protect)
 DECLARE inv_vendor_item = c1 WITH noconstant("N",protect)
 DECLARE inv_vendor_site = c1 WITH noconstant("N",protect)
 DECLARE inv_item_location_cost = c1 WITH noconstant("N",protect)
 DECLARE inv_item_control_info = c1 WITH noconstant("N",protect)
 DECLARE inv_quantity_requirement_info = c1 WITH noconstant("N",protect)
 DECLARE inv_acquirement_info = c1 WITH noconstant("N",protect)
 DECLARE inv_quantity_on_hand = c1 WITH noconstant("N",protect)
 DECLARE hm_expect_series = c1 WITH noconstant("N",protect)
 DECLARE hm_expect_sched = c1 WITH noconstant("N",protect)
 DECLARE med_admin_event = c1 WITH noconstant("N",protect)
 DECLARE ta_clinical_event = c1 WITH noconstant("N",protect)
 DECLARE ta_order_task = c1 WITH noconstant("N",protect)
 DECLARE ce_event_note = c1 WITH noconstant("Y",protect)
 DECLARE ce_clinical_event = c1 WITH noconstant("N",protect)
 DECLARE ce_long_blob = c1 WITH noconstant("N",protect)
 DECLARE ce_long_text = c1 WITH noconstant("N",protect)
 DECLARE bb_blood_product = c1 WITH noconstant("N",protect)
 DECLARE bb_derivative = c1 WITH noconstant("N",protect)
 DECLARE bb_assign = c1 WITH noconstant("Y",protect)
 DECLARE bb_crossmatch = c1 WITH noconstant("Y",protect)
 DECLARE bb_destruction = c1 WITH noconstant("Y",protect)
 DECLARE bb_patient_dispense = c1 WITH noconstant("Y",protect)
 DECLARE bb_receipt = c1 WITH noconstant("Y",protect)
 DECLARE bb_disposition = c1 WITH noconstant("Y",protect)
 DECLARE icd10_extension_ind = c1 WITH noconstant(""), protect
 DECLARE sch_apply = c1 WITH noconstant(""), protect
 DECLARE sch_object = c1 WITH noconstant(""), protect
 DECLARE ceb_ce_blob = c1 WITH noconstant(""), protect
 DECLARE rdrptdtl_rad_report_detail = c1 WITH noconstant(""), protect
 DECLARE rdrptdtl_clinical_event = c1 WITH noconstant(""), protect
 DECLARE rdrptdtl_rad_report = c1 WITH noconstant(""), protect
 DECLARE fhx_activity_fhx_action = c1 WITH noconstant(""), protect
 DECLARE fhx_activity_r_fhx_activity = c1 WITH noconstant(""), protect
 DECLARE fhx_long_text_r_fhx_activity = c1 WITH noconstant(""), protect
 DECLARE sgprefdc_sn_name_value_prefs = c1 WITH noconstant(""), protect
 DECLARE bhs_br_hlth_sntry_item = c1 WITH noconstant(""), protect
 DECLARE ls_encntr_legal_review_r = c1 WITH noconstant(""), protect
 DECLARE mh_pm_mental_health = c1 WITH noconstant(""), protect
 DECLARE mammo_assess = c1 WITH noconstant(""), protect
 DECLARE mammo_find_dr = c1 WITH noconstant(""), protect
 DECLARE mammo_find_dtl = c1 WITH noconstant(""), protect
 DECLARE sa_anesthesia_rec_status = c1 WITH noconstant("N"), protect
 DECLARE sa_med_admin_item = c1 WITH noconstant("Y"), protect
 DECLARE sa_action_item = c1 WITH noconstant("Y"), protect
 DECLARE sa_parameter_value = c1 WITH noconstant("Y"), protect
 DECLARE sa_fluid = c1 WITH noconstant("Y"), protect
 DECLARE sa_fluid_admin_item = c1 WITH noconstant("Y"), protect
 DECLARE sa_ref_cat_action = c1 WITH noconstant("N"), protect
 DECLARE encntr_clin_review_result = c1 WITH noconstant("Y"), protect
 DECLARE encntr_appeal = c1 WITH noconstant("Y"), protect
 DECLARE order_extractfile = vc WITH protect, noconstant("")
 DECLARE ord_act_extractfile = vc WITH protect, noconstant("")
 DECLARE ord_detl_extractfile = vc WITH protect, noconstant("")
 DECLARE ord_rev_extractfile = vc WITH protect, noconstant("")
 DECLARE ordbl_extractfile = vc WITH protect, noconstant("")
 DECLARE mic_order_extractfile = vc WITH protect, noconstant("")
 DECLARE container_extractfile = vc WITH protect, noconstant("")
 DECLARE osrc_extractfile = vc WITH protect, noconstant("")
 DECLARE ccpl_extractfile = vc WITH protect, noconstant("")
 DECLARE implant_log_extractfile = vc WITH protect, noconstant("")
 DECLARE gen_lab_result_extractfile = vc WITH protect, noconstant("")
 DECLARE gen_lab_order_extractfile = vc WITH protect, noconstant("")
 DECLARE gen_lab_rslt_event_extractfile = vc WITH protect, noconstant("")
 DECLARE pref_card_extractfile = vc WITH protect, noconstant("")
 DECLARE scheduled_pl_extractfile = vc WITH protect, noconstant("")
 DECLARE pref_card_item_extractfile = vc WITH protect, noconstant("")
 DECLARE periop_doc_ref_extractfile = vc WITH protect, noconstant("")
 DECLARE surg_cs_extractfile = vc WITH protect, noconstant("")
 DECLARE surg_p_extractfile = vc WITH protect, noconstant("")
 DECLARE surgical_delay_extractfile = vc WITH protect, noconstant("")
 DECLARE case_attendance_extractfile = vc WITH protect, noconstant("")
 DECLARE stats_extractfile = vc WITH protect, noconstant("")
 DECLARE edw_stats_extractfile = vc WITH protect, noconstant("")
 DECLARE hf_stats_extractfile = vc WITH protect, noconstant("")
 DECLARE rad_order_extractfile = vc WITH protect, noconstant("")
 DECLARE perioperative_doc_extractfile = vc WITH protect, noconstant("")
 DECLARE s_cal_at_extractfile = vc WITH protect, noconstant("")
 DECLARE s_apt_at_extractfile = vc WITH protect, noconstant("")
 DECLARE s_apt_dt_extractfile = vc WITH protect, noconstant("")
 DECLARE res_dt_r_extractfile = vc WITH protect, noconstant("")
 DECLARE detail_r_extractfile = vc WITH protect, noconstant("")
 DECLARE sch_cal_extractfile = vc WITH protect, noconstant("")
 DECLARE s_cal_def_extractfile = vc WITH protect, noconstant("")
 DECLARE slot_typ_extractfile = vc WITH protect, noconstant("")
 DECLARE agrp_rlt_extractfile = vc WITH protect, noconstant("")
 DECLARE rgrp_rlt_extractfile = vc WITH protect, noconstant("")
 DECLARE aptb_rlt_extractfile = vc WITH protect, noconstant("")
 DECLARE sgrp_rlt_extractfile = vc WITH protect, noconstant("")
 DECLARE tr_prsnl_ref_extractfile = vc WITH protect, noconstant("")
 DECLARE enc_follow_extractfile = vc WITH protect, noconstant("")
 DECLARE tr_evnt_hist_extractfile = vc WITH protect, noconstant("")
 DECLARE tr_ar_udf_extractfile = vc WITH protect, noconstant("")
 DECLARE pat_ed_doc_act_extractfile = vc WITH protect, noconstant("")
 DECLARE tr_prv_reltn_extractfile = vc WITH protect, noconstant("")
 DECLARE evnt_ref_extractfile = vc WITH protect, noconstant("")
 DECLARE trk_det_extractfile = vc WITH protect, noconstant("")
 DECLARE evnt_ord_extractfile = vc WITH protect, noconstant("")
 DECLARE trk_loc_extractfile = vc WITH protect, noconstant("")
 DECLARE trk_evnt_extractfile = vc WITH protect, noconstant("")
 DECLARE trk_ckin_extractfile = vc WITH protect, noconstant("")
 DECLARE trk_item_extractfile = vc WITH protect, noconstant("")
 DECLARE prearr_extractfile = vc WITH protect, noconstant("")
 DECLARE event_prsnl_extractfile = vc WITH protect, noconstant("")
 DECLARE pathway_action_extractfile = vc WITH protect, noconstant("")
 DECLARE ap_specimen_extractfile = vc WITH protect, noconstant("")
 DECLARE ap_diag_extractfile = vc WITH protect, noconstant("")
 DECLARE ap_blk_extractfile = vc WITH protect, noconstant("")
 DECLARE dm_info_extractfile = vc WITH protect, noconstant("")
 DECLARE ap_process_extractfile = vc WITH protect, noconstant("")
 DECLARE ap_slide_extractfile = vc WITH protect, noconstant("")
 DECLARE enc_flex_extractfile = vc WITH protect, noconstant("")
 DECLARE ap_case_extractfile = vc WITH protect, noconstant("")
 DECLARE ap_rpt_extractfile = vc WITH protect, noconstant("")
 DECLARE ap_cncpt_extractfile = vc WITH protect, noconstant("")
 DECLARE es_canon_extractfile = vc WITH protect, noconstant("")
 DECLARE pr_alias_extractfile = vc WITH protect, noconstant("")
 DECLARE pr_psl_r_extractfile = vc WITH protect, noconstant("")
 DECLARE lng_text_extractfile = vc WITH protect, noconstant("")
 DECLARE scd_org_extractfile = vc WITH protect, noconstant("")
 DECLARE scd_ccpt_extractfile = vc WITH protect, noconstant("")
 DECLARE scd_data_extractfile = vc WITH protect, noconstant("")
 DECLARE scd_term_extractfile = vc WITH protect, noconstant("")
 DECLARE scd_sty_extractfile = vc WITH protect, noconstant("")
 DECLARE scr_par_type_ref_extractfile = vc WITH protect, noconstant("")
 DECLARE scr_term_hier_extractfile = vc WITH protect, noconstant("")
 DECLARE scr_term_extractfile = vc WITH protect, noconstant("")
 DECLARE scr_pattern_extractfile = vc WITH protect, noconstant("")
 DECLARE scr_term_def_extractfile = vc WITH protect, noconstant("")
 DECLARE raw_scd_story_pat_extractfile = vc WITH protect, noconstant("")
 DECLARE encntr_slice_extractfile = vc WITH protect, noconstant("")
 DECLARE wait_lst_extractfile = vc WITH protect, noconstant("")
 DECLARE user_defined_hist_extractfile = vc WITH protect, noconstant("")
 DECLARE enc_acp_extractfile = vc WITH protect, noconstant("")
 DECLARE enc_acc_extractfile = vc WITH protect, noconstant("")
 DECLARE ep_enc_extractfile = vc WITH protect, noconstant("")
 DECLARE address_extractfile = vc WITH protect, noconstant("")
 DECLARE phone_extractfile = vc WITH protect, noconstant("")
 DECLARE enc_leav_extractfile = vc WITH protect, noconstant("")
 DECLARE benefit_alloc_extractfile = vc WITH protect, noconstant("")
 DECLARE benefit_extractfile = vc WITH protect, noconstant("")
 DECLARE per_nam_extractfile = vc WITH protect, noconstant("")
 DECLARE per_per_reltn_extractfile = vc WITH protect, noconstant("")
 DECLARE org_rel_reltn_extractfile = vc WITH protect, noconstant("")
 DECLARE cd_ext_extractfile = vc WITH protect, noconstant("")
 DECLARE cd_grp_extractfile = vc WITH protect, noconstant("")
 DECLARE encntr_encntr_reltn_extractfile = vc WITH protect, noconstant("")
 DECLARE loc_atr_extractfile = vc WITH protect, noconstant("")
 DECLARE multum_med_extractfile = vc WITH protect, noconstant("")
 DECLARE drug_cls_extractfile = vc WITH protect, noconstant("")
 DECLARE cd_out_extractfile = vc WITH protect, noconstant("")
 DECLARE pct_sha_data_extractfile = vc WITH protect, noconstant("")
 DECLARE cdsctnt_extractfile = vc WITH protect, noconstant("")
 DECLARE prsl_org_extractfile = vc WITH protect, noconstant("")
 DECLARE cdsctnth_extractfile = vc WITH protect, noconstant("")
 DECLARE enc_info_extractfile = vc WITH protect, noconstant("")
 DECLARE cds_batch_extractfile = vc WITH protect, noconstant("")
 DECLARE cds_batch_hist_extractfile = vc WITH protect, noconstant("")
 DECLARE wait_list_status_extractfile = vc WITH protect, noconstant("")
 DECLARE person_info_extractfile = vc WITH protect, noconstant("")
 DECLARE fin_enc_extractfile = vc WITH protect, noconstant("")
 DECLARE fin_bill_extractfile = vc WITH protect, noconstant("")
 DECLARE fin_batch_trans_extractfile = vc WITH protect, noconstant("")
 DECLARE fin_daily_bal_extractfile = vc WITH protect, noconstant("")
 DECLARE fin_denial_extractfile = vc WITH protect, noconstant("")
 DECLARE fin_pay_plan_extractfile = vc WITH protect, noconstant("")
 DECLARE fin_collect_extractfile = vc WITH protect, noconstant("")
 DECLARE fin_pay_adj_extractfile = vc WITH protect, noconstant("")
 DECLARE fin_charges_extractfile = vc WITH protect, noconstant("")
 DECLARE media_master_extractfile = vc WITH protect, noconstant("")
 DECLARE media_master_alias_extractfile = vc WITH protect, noconstant("")
 DECLARE requester_extractfile = vc WITH protect, noconstant("")
 DECLARE him_request_patient_extractfile = vc WITH protect, noconstant("")
 DECLARE def_sch_extractfile = vc WITH protect, noconstant("")
 DECLARE lh_extractfile = vc WITH protect, noconstant("")
 DECLARE br_extractfile = vc WITH protect, noconstant("")
 DECLARE qrda_extractfile = vc WITH protect, noconstant("")
 DECLARE ce_spec_extractfile = vc WITH protect, noconstant("")
 DECLARE charge_mod_raw_extractfile = vc WITH protect, noconstant("")
 DECLARE fin_charge_event_extractfile = vc WITH protect, noconstant("")
 DECLARE fin_workload_extractfile = vc WITH protect, noconstant("")
 DECLARE per_atr_extractfile = vc WITH protect, noconstant("")
 DECLARE ord_comp_extractfile = vc WITH protect, noconstant("")
 DECLARE ord_recon_extractfile = vc WITH protect, noconstant("")
 DECLARE rad_exam_extractfile = vc WITH protect, noconstant("")
 DECLARE rad_report_extractfile = vc WITH protect, noconstant("")
 DECLARE eps_pp_extractfile = vc WITH protect, noconstant("")
 DECLARE ce_micro_extractfile = vc WITH protect, noconstant("")
 DECLARE ce_sus_extractfile = vc WITH protect, noconstant("")
 DECLARE prsnl_alias_raw_extractfile = vc WITH protect, noconstant("")
 DECLARE preginst_extractfile = vc WITH protect, noconstant("")
 DECLARE pregchld_extractfile = vc WITH protect, noconstant("")
 DECLARE pregnancy_estimate_extractfile = vc WITH protect, noconstant("")
 DECLARE pregnancy_detail_extractfile = vc WITH protect, noconstant("")
 DECLARE shx_com_extractfile = vc WITH protect, noconstant("")
 DECLARE shx_act_extractfile = vc WITH protect, noconstant("")
 DECLARE shx_elem_extractfile = vc WITH protect, noconstant("")
 DECLARE shx_resp_extractfile = vc WITH protect, noconstant("")
 DECLARE app_extractfile = vc WITH protect, noconstant("")
 DECLARE app_ctx_extractfile = vc WITH protect, noconstant("")
 DECLARE ordc_order_container_r = vc WITH protect, noconstant("")
 DECLARE qstquest_extractfile = vc WITH protect, noconstant("")
 DECLARE qstanswr_extractfile = vc WITH protect, noconstant("")
 DECLARE venditem_extractfile = vc WITH protect, noconstant("")
 DECLARE itemloc_extractfile = vc WITH protect, noconstant("")
 DECLARE manuftr_extractfile = vc WITH protect, noconstant("")
 DECLARE itmprc_extractfile = vc WITH protect, noconstant("")
 DECLARE pkgtyp_extractfile = vc WITH protect, noconstant("")
 DECLARE pmoffer_extractfile = vc WITH protect, noconstant("")
 DECLARE label_extractfile = vc WITH protect, noconstant("")
 DECLARE hm_recmd_extractfile = vc WITH protect, noconstant("")
 DECLARE hm_recac_extractfile = vc WITH protect, noconstant("")
 DECLARE hm_satis_extractfile = vc WITH protect, noconstant("")
 DECLARE hm_step_extractfile = vc WITH protect, noconstant("")
 DECLARE hm_expct_extractfile = vc WITH protect, noconstant("")
 DECLARE medadevt_extractfile = vc WITH protect, noconstant("")
 DECLARE abstract_extractfile = vc WITH protect, noconstant("")
 DECLARE pthcustp_extractfile = vc WITH protect, noconstant("")
 DECLARE tskact_extractfile = vc WITH protect, noconstant("")
 DECLARE tskactas_extractfile = vc WITH protect, noconstant("")
 DECLARE ce_note_extractfile = vc WITH protect, noconstant("")
 DECLARE bbpratb_extractfile = vc WITH protect, noconstant("")
 DECLARE bbprsabo_extractfile = vc WITH protect, noconstant("")
 DECLARE bbpratg_extractfile = vc WITH protect, noconstant("")
 DECLARE bb_lng_txt_extractfile = vc WITH protect, noconstant("")
 DECLARE bbprdevt_extractfile = vc WITH protect, noconstant("")
 DECLARE bbspctst_extractfile = vc WITH protect, noconstant("")
 DECLARE bbprrhp_extractfile = vc WITH protect, noconstant("")
 DECLARE bbdsprtn_extractfile = vc WITH protect, noconstant("")
 DECLARE bbprstrn_extractfile = vc WITH protect, noconstant("")
 DECLARE schentry_extractfile = vc WITH protect, noconstant("")
 DECLARE schevtat_extractfile = vc WITH protect, noconstant("")
 DECLARE schevtcm_extractfile = vc WITH protect, noconstant("")
 DECLARE schdtcom_extractfile = vc WITH protect, noconstant("")
 DECLARE ce_blob_extractfile = vc WITH protect, noconstant("")
 DECLARE rdrptdtl_extractfile = vc WITH protect, noconstant("")
 DECLARE lngblob_extractfile = vc WITH protect, noconstant("")
 DECLARE ep_act_extractfile = vc WITH protect, noconstant("")
 DECLARE fhxact_extractfile = vc WITH protect, noconstant("")
 DECLARE fhxactr_extractfile = vc WITH protect, noconstant("")
 DECLARE fhxlong_extractfile = vc WITH protect, noconstant("")
 DECLARE sgprefdc_extractfile = vc WITH protect, noconstant("")
 DECLARE si_oid_extractfile = vc WITH protect, noconstant("")
 DECLARE drgext_extractfile = vc WITH protect, noconstant("")
 DECLARE brhlthsn_extractfile = vc WITH protect, noconstant("")
 DECLARE encpsrel_extractfile = vc WITH protect, noconstant("")
 DECLARE mntlhlth_extractfile = vc WITH protect, noconstant("")
 DECLARE legalst_extractfile = vc WITH protect, noconstant("")
 DECLARE pminfhst_extractfile = vc WITH protect, noconstant("")
 DECLARE m_study_extractfile = vc WITH protect, noconstant("")
 DECLARE m_usrdef_extractfile = vc WITH protect, noconstant("")
 DECLARE m_assess_extractfile = vc WITH protect, noconstant("")
 DECLARE m_brfind_extractfile = vc WITH protect, noconstant("")
 DECLARE flup_fld_extractfile = vc WITH protect, noconstant("")
 DECLARE conpolrf_extractfile = vc WITH protect, noconstant("")
 DECLARE consttus_extractfile = vc WITH protect, noconstant("")
 DECLARE pwosrltn_extractfile = vc WITH protect, noconstant("")
 DECLARE intpdata_extractfile = vc WITH protect, noconstant("")
 DECLARE rsltcmmt_extractfile = vc WITH protect, noconstant("")
 DECLARE glrspunit_extractfile = vc WITH protect, noconstant("")
 DECLARE glacctref_extractfile = vc WITH protect, noconstant("")
 DECLARE br_map_extractfile = vc WITH protect, noconstant("")
 DECLARE anesrec_extractfile = vc WITH protect, noconstant("")
 DECLARE samdadtm_extractfile = vc WITH protect, noconstant("")
 DECLARE saacitm_extractfile = vc WITH protect, noconstant("")
 DECLARE saparval_extractfile = vc WITH protect, noconstant("")
 DECLARE saflditm_extractfile = vc WITH protect, noconstant("")
 DECLARE samedref_extractfile = vc WITH protect, noconstant("")
 DECLARE saractim_extractfile = vc WITH protect, noconstant("")
 DECLARE saparref_extractfile = vc WITH protect, noconstant("")
 DECLARE safldref_extractfile = vc WITH protect, noconstant("")
 DECLARE saactref_extractfile = vc WITH protect, noconstant("")
 DECLARE encdom_extractfile = vc WITH protect, noconstant("")
 DECLARE cmclnrv_extractfile = vc WITH protect, noconstant("")
 DECLARE cmsecrv_extractfile = vc WITH protect, noconstant("")
 DECLARE cmavoid_extractfile = vc WITH protect, noconstant("")
 DECLARE cmreadmt_extractfile = vc WITH protect, noconstant("")
 DECLARE cmapldny_extractfile = vc WITH protect, noconstant("")
 DECLARE cmmang_extractfile = vc WITH protect, noconstant("")
 DECLARE lhwklst_extractfile = vc WITH protect, noconstant("")
 DECLARE lhrdmrsk_extractfile = vc WITH protect, noconstant("")
 DECLARE lhrdmsts_extractfile = vc WITH protect, noconstant("")
 DECLARE ordordrl_extractfile = vc WITH protect, noconstant("")
 DECLARE prsn_org_extractfile = vc WITH protect, noconstant("")
 DECLARE hm_mod_extractfile = vc WITH protect, noconstant("")
 DECLARE schobjct_extractfile = vc WITH protect, noconstant("")
 DECLARE himalloc_extractfile = vc WITH protect, noconstant("")
 DECLARE himpvchr_extractfile = vc WITH protect, noconstant("")
 DECLARE himpvdoc_extractfile = vc WITH protect, noconstant("")
 DECLARE himext_extractfile = vc WITH protect, noconstant("")
 DECLARE edw_end_effective_date = vc WITH public, constant("31-DEC-2100")
 DECLARE v_bar = c1 WITH constant("|"), protect
 DECLARE blank_field = c1 WITH constant(" "), protect
 DECLARE line = vc WITH noconstant(""), protect
 DECLARE stats_count = i2 WITH noconstant(0), protect
 DECLARE mill_source_cd = i1 WITH constant(3), protect
 DECLARE str_find = vc WITH constant, protect
 DECLARE str_replace = vc WITH constant, protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE comma_pos = i4 WITH noconstant(0), protect
 DECLARE data_type = vc WITH noconstant(""), protect
 DECLARE allptcnt = i4 WITH noconstant(0), protect
 DECLARE slice_cnt = i4 WITH noconstant(0), protect
 DECLARE uniqptcnt = i4 WITH noconstant(0), protect
 DECLARE iallordercnt = i4 WITH protect, noconstant(0)
 DECLARE micordercnt = i4 WITH protect, noconstant(0)
 DECLARE micrptcnt = i4 WITH protect, noconstant(0)
 DECLARE clinicalcnt = i4 WITH protect, noconstant(0)
 DECLARE gen_lab_order_cnt = i4 WITH protect, noconstant(0)
 DECLARE phadispcnt = i4 WITH protect, noconstant(0)
 DECLARE phaingrcnt = i4 WITH protect, noconstant(0)
 DECLARE phaordcnt = i4 WITH protect, noconstant(0)
 DECLARE pathway_cnt = i4 WITH protect, noconstant(0)
 DECLARE suscept_cntr = i4 WITH protect, noconstant(0)
 DECLARE outcome_counter = i4 WITH protect, noconstant(0)
 DECLARE isurgcasecnt = i4 WITH protect, noconstant(0)
 DECLARE isurgcaseproccnt = i4 WITH protect, noconstant(0)
 DECLARE iallapplyslotid = i4 WITH protect, noconstant(0)
 DECLARE health_system_source_id = vc WITH noconstant(""), protect
 DECLARE health_system_id = vc WITH noconstant(""), protect
 DECLARE client_type_ind = c1 WITH noconstant(""), protect
 DECLARE act_from_dt_tm = f8 WITH noconstant(0.0), protect
 DECLARE act_to_dt_tm = f8 WITH noconstant(0.0), protect
 DECLARE historic_ind = c1 WITH noconstant("N"), protect
 DECLARE hist_from_dt_tm = f8 WITH noconstant(0.0), protect
 DECLARE days_to_extract = i4 WITH noconstant(0), protect
 DECLARE extract_dt_tm = f8 WITH noconstant(0.0), protect
 DECLARE extract_dt_tm_fmt = vc WITH noconstant(""), protect
 DECLARE extract_dt_fmt = c6 WITH noconstant(""), protect
 DECLARE extract_tm_fmt = c6 WITH noconstant(""), protect
 DECLARE act_from_dt_tm_fmt = c16 WITH noconstant(""), protect
 DECLARE act_from_dt_fmt = c6 WITH noconstant(""), protect
 DECLARE act_from_tm_fmt = c4 WITH noconstant(""), protect
 DECLARE act_to_dt_tm_fmt = c16 WITH noconstant(""), protect
 DECLARE act_to_dt_fmt = c6 WITH noconstant(""), protect
 DECLARE act_to_tm_fmt = c4 WITH noconstant(""), protect
 DECLARE inst_input = vc WITH noconstant(""), protect
 DECLARE org_input = vc WITH noconstant(""), protect
 DECLARE hf_input = vc WITH noconstant(""), protect
 DECLARE ex_contrib_sys_input = vc WITH noconstant(""), protect
 DECLARE faclty_input = vc WITH noconstant(""), protect
 DECLARE encounter_nk = vc WITH noconstant(""), protect
 DECLARE admit_dt_tm = vc WITH noconstant(""), protect
 DECLARE discharge_dt_tm = vc WITH noconstant(""), protect
 DECLARE filter_field_1 = vc WITH noconstant(""), protect
 DECLARE filter_field_2 = vc WITH noconstant(""), protect
 DECLARE filter_field_3 = vc WITH noconstant(""), protect
 DECLARE filter_value_1 = vc WITH noconstant(""), protect
 DECLARE filter_value_2 = vc WITH noconstant(""), protect
 DECLARE filter_value_3 = vc WITH noconstant(""), protect
 DECLARE global_extract_ind = c1 WITH noconstant(""), protect
 DECLARE init_enterprise_ind = c1 WITH noconstant(""), protect
 DECLARE default_time_zone = f8 WITH noconstant(0.0), protect
 DECLARE debug = vc WITH noconstant(""), protect
 DECLARE printcost = vc WITH noconstant(""), protect
 DECLARE get_orphan_files = vc WITH noconstant(""), protect
 DECLARE alternate1_id = vc WITH noconstant(""), protect
 DECLARE alternate2_id = vc WITH noconstant(""), protect
 DECLARE alternate3_id = vc WITH noconstant(""), protect
 DECLARE alternate4_id = vc WITH noconstant(""), protect
 DECLARE alternate5_id = vc WITH noconstant(""), protect
 DECLARE per_alt_ident_1 = vc WITH noconstant(""), protect
 DECLARE per_alt_ident_2 = vc WITH noconstant(""), protect
 DECLARE per_alt_ident_3 = vc WITH noconstant(""), protect
 DECLARE per_alt_ident_4 = vc WITH noconstant(""), protect
 DECLARE per_alt_ident_5 = vc WITH noconstant(""), protect
 DECLARE enc_alt_ident_1 = vc WITH noconstant(""), protect
 DECLARE enc_alt_ident_2 = vc WITH noconstant(""), protect
 DECLARE enc_alt_ident_3 = vc WITH noconstant(""), protect
 DECLARE enc_alt_ident_4 = vc WITH noconstant(""), protect
 DECLARE enc_alt_ident_5 = vc WITH noconstant(""), protect
 DECLARE suscept_ce_interface_facilities = vc WITH noconstant(""), protect
 DECLARE suscept_ce_interface_flg = i2 WITH noconstant(0), protect
 DECLARE micro_order_interface_facilities = vc WITH noconstant(""), protect
 DECLARE micro_order_interface_flg = i2 WITH noconstant(0), protect
 DECLARE pharm_order_interface_facilities = vc WITH noconstant(""), protect
 DECLARE pharm_order_interface_flg = i2 WITH noconstant(0), protect
 DECLARE gen_lab_order_interface_facilities = vc WITH noconstant(""), protect
 DECLARE gen_lab_order_interface_flg = i2 WITH noconstant(0), protect
 DECLARE anatomic_path_order_interface_facilities = vc WITH noconstant(""), protect
 DECLARE anatomic_path_order_interface_flg = i2 WITH noconstant(0), protect
 DECLARE small_batch_size = i4 WITH protect, noconstant(0)
 DECLARE medium_batch_size = i4 WITH protect, noconstant(0)
 DECLARE large_batch_size = i4 WITH protect, noconstant(0)
 DECLARE script_start_dt_tm = c20 WITH noconstant(""), protect
 DECLARE script_end_dt_tm = c20 WITH noconstant(""), protect
 DECLARE error_ind = i2 WITH noconstant(0), protect
 DECLARE periop_doc_days_back = i4 WITH protect, noconstant(14)
 DECLARE reference_ind = i4 WITH protect, noconstant(1)
 DECLARE activity_ind = i4 WITH protect, noconstant(1)
 DECLARE historic_start_dt_tm_help = vc WITH protect
 DECLARE act_ext_from_dt_tm_help = vc WITH protect
 DECLARE act_ext_to_dt_tm_help = vc WITH protect
 DECLARE par = c20 WITH protect, noconstant(" ")
 DECLARE grp_nbr = i2 WITH protect, noconstant(0)
 DECLARE parallel_ind = i2 WITH protect, noconstant(0)
 DECLARE first_run_ind = i2 WITH protect, noconstant(0)
 DECLARE last_run_ind = i2 WITH protect, noconstant(0)
 DECLARE nbr_grps = i2 WITH protect, noconstant(0)
 DECLARE file_prefix = vc WITH protect, noconstant("")
 DECLARE file_suffix = vc WITH protect, noconstant("")
 DECLARE edw_file_prefix = vc WITH protect, noconstant("")
 DECLARE hf_file_prefix = vc WITH protect, noconstant("")
 DECLARE extract_filelist = vc WITH noconstant(""), protect
 DECLARE edw_extract_filelist = vc WITH noconstant(""), protect
 DECLARE hf_extract_filelist = vc WITH noconstant(""), protect
 DECLARE upd_grp_nbr = i2 WITH protect, noconstant(0)
 DECLARE extract_dir = vc WITH protect, noconstant("")
 DECLARE stand_by_ind = c1 WITH protect, noconstant("")
 DECLARE from_clause = vc WITH protect, noconstant("")
 DECLARE syscmd = vc WITH noconstant("")
 DECLARE len = i4 WITH noconstant(0)
 DECLARE return_val = i4 WITH noconstant(0)
 DECLARE otcm_cnt = i4 WITH noconstant(0), protect
 DECLARE trackevntcnt = i4 WITH noconstant(0), protect
 DECLARE trackitemcnt = i4 WITH noconstant(0), protect
 DECLARE trackpreacnt = i4 WITH noconstant(0), protect
 DECLARE trk_item_cnt = i4 WITH noconstant(0), protect
 DECLARE track_prearrive_cnt = i4 WITH noconstant(0), protect
 DECLARE trk_prearrive_cnt = i4 WITH noconstant(0), protect
 DECLARE trk_evnt_cnt = i4 WITH noconstant(0), protect
 DECLARE sch_appt_id_cnt = i4 WITH noconstant(0), protect
 DECLARE sch_apply_slot_id_cnt = i4 WITH noconstant(0), protect
 DECLARE akcnt = i4 WITH noconstant(0), protect
 DECLARE utc_timezone_index = i2 WITH constant(datetimezonebyname("UTC")), protect
 DECLARE default_encounter_nk = vc WITH constant(
  "CNVTSTRING(ENCOUNTER.ENCNTR_ID,16),HEALTH_SYSTEM_SOURCE_ID"), protect
 DECLARE iapspecimencount = i4 WITH protect, noconstant(0)
 DECLARE iapcasecount = i4 WITH protect, noconstant(0)
 DECLARE iapdiagcorrcount = i4 WITH protect, noconstant(0)
 DECLARE exclude_diagnosis_correlation = c1 WITH protect, noconstant("Y")
 DECLARE iapblockcount = i4 WITH protect, noconstant(0)
 DECLARE iapslidecount = i4 WITH protect, noconstant(0)
 DECLARE sort_dir = vc WITH protect, noconstant("")
 DECLARE scdstory_cnt = i4 WITH protect, noconstant(0)
 DECLARE scdterm_cnt = i4 WITH protect, noconstant(0)
 DECLARE scr_term_language = i4 WITH protect, noconstant(0)
 DECLARE org_filter = vc WITH protect, noconstant("1=1")
 DECLARE inst_filter = vc WITH protect, noconstant("1=1")
 DECLARE hf_filter = vc WITH protect, noconstant("1=1")
 DECLARE contrib_sys_filter = vc WITH protect, noconstant("1=1")
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE v_rdbms_user = vc WITH noconstant(""), protect
 DECLARE v_rdbms_pswd = vc WITH noconstant(""), protect
 DECLARE v_rdbms_con = vc WITH noconstant(""), protect
 DECLARE wl_cnt = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE v_lregview_db = vc WITH protect, noconstant("")
 DECLARE allpftenc_cnt = i4 WITH protect, noconstant(0)
 DECLARE ssn_ind = c1 WITH noconstant("Y"), protect
 DECLARE him_request_patient_cnt = i4 WITH noconstant(0), protect
 DECLARE him_request_cnt = i4 WITH noconstant(0), protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE count_loop = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE hf_item = i4 WITH protect, noconstant(0)
 DECLARE persons_only_on_activity_ind = c1 WITH noconstant("N"), protect
 DECLARE lighthouse_ind = c1 WITH noconstant("N"), protect
 DECLARE bedrock_ind = c1 WITH noconstant("N"), protect
 DECLARE mrn_ind = c1 WITH noconstant("Y"), protect
 DECLARE fin_ind = c1 WITH noconstant("Y"), protect
 DECLARE man_from_dt_tm = f8 WITH noconstant(0.0), protect
 DECLARE man_to_dt_tm = f8 WITH noconstant(0.0), protect
 DECLARE scripts_list = vc WITH noconstant(""), protect
 DECLARE stats_list = vc WITH noconstant(""), protect
 DECLARE ftp_flg = c1 WITH noconstant("N"), protect
 DECLARE task_asy_ce_days = i4 WITH noconstant(0), protect
 DECLARE charge_event_cnt = i4 WITH noconstant(0), protect
 DECLARE orphan_local_dir = vc WITH protect, noconstant("")
 DECLARE act_to_dt_tm_utc = f8 WITH noconstant(0.0), protect
 DECLARE allradordercnt = i4 WITH protect, noconstant(0)
 DECLARE ds_item_cnt = i4 WITH protect, noconstant(0)
 DECLARE microcnt = i4 WITH protect, noconstant(0)
 DECLARE iallpregcnt = i4 WITH protect, noconstant(0)
 DECLARE pregnancy_estimate_cnt = i4 WITH protect, noconstant(0)
 DECLARE iallactivitycnt = i4 WITH protect, noconstant(0)
 DECLARE iallrecommendcnt = i4 WITH protect, noconstant(0)
 DECLARE to_dt_tm_present_ind = vc WITH protect, noconstant("")
 DECLARE orig_act_to_dt_tm = f8 WITH noconstant(0.0), protect
 DECLARE buffer_hours = f8 WITH noconstant(0.0), protect
 DECLARE historic_alt_path_ind = vc WITH protect, noconstant("")
 DECLARE manual_alt_path_ind = vc WITH protect, noconstant("")
 DECLARE ialltacnt = i4 WITH protect, noconstant(0)
 DECLARE exam_id_cnt = i4 WITH protect, noconstant(0)
 DECLARE hf_use_compression = vc WITH protect, noconstant("")
 DECLARE use_hf_ftp_config = vc WITH protect, noconstant("")
 DECLARE healtheintent_ind = vc WITH protect, noconstant("")
 DECLARE total_prdct_evnt_cnt = i4 WITH protect, noconstant(0)
 DECLARE iallbbcnt = i4 WITH protect, noconstant(0)
 DECLARE archive_dir = vc WITH protect, noconstant("")
 DECLARE include_lighthouse = vc WITH protect, noconstant("N")
 DECLARE include_bedrock = vc WITH protect, noconstant("N")
 DECLARE ceb_ce_blob_len = i4 WITH protect, noconstant(0)
 DECLARE report_id_cnt = i4 WITH protect, noconstant(0)
 DECLARE lb_long_blob_len = i4 WITH protect, noconstant(0)
 DECLARE ssn_masking = vc WITH protect, noconstant("")
 DECLARE fin_masking = vc WITH protect, noconstant("")
 DECLARE mrn_masking = vc WITH protect, noconstant("")
 DECLARE cmrn_masking = vc WITH protect, noconstant("")
 DECLARE pralias_masking = vc WITH protect, noconstant("")
 DECLARE ep_reltn_cnt = i4 WITH protect, noconstant(0)
 DECLARE ifhxactcnt = i4 WITH protect, noconstant(0)
 DECLARE logical_domain_input = vc WITH protect, noconstant("")
 DECLARE logical_domain_filter = vc WITH protect, noconstant("1=1")
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE manual_solution = vc WITH noconstant(""), protect
 DECLARE parallel_profit = vc WITH noconstant(""), protect
 DECLARE use_cloud_config = c1 WITH noconstant("N"), protect
 DECLARE gl_profit = c1 WITH noconstant("Y"), protect
 DECLARE code_value_cnt = i4 WITH protect, noconstant(0)
 DECLARE drugcnt = i4 WITH protect, noconstant(0)
 DECLARE mult_cnt = i4 WITH protect, noconstant(0)
 DECLARE nmcltr_cnt = i4 WITH protect, noconstant(0)
 DECLARE ordblcnt = i4 WITH protect, noconstant(0)
 DECLARE total_br_hlth_sntry_mill_item_cnt = i4 WITH protect, noconstant(0)
 DECLARE ord_act_cnt = i4 WITH protect, noconstant(0)
 DECLARE ord_act_find = i4 WITH protect, noconstant(0)
 DECLARE mental_health_cnt = i4 WITH protect, noconstant(0)
 DECLARE legal_status_cnt = i4 WITH protect, noconstant(0)
 DECLARE pm_info_cnt = i4 WITH protect, noconstant(0)
 DECLARE mammo_study_cnt = i4 WITH protect, noconstant(0)
 DECLARE mammo_assess_cnt = i4 WITH protect, noconstant(0)
 DECLARE mammo_usrdef_cnt = i4 WITH protect, noconstant(0)
 DECLARE mammo_breast_cnt = i4 WITH protect, noconstant(0)
 DECLARE rad_fol_cnt = i4 WITH protect, noconstant(0)
 DECLARE ceblob_rtf = c1 WITH protect, noconstant("")
 DECLARE lngblob_rtf = c1 WITH protect, noconstant("")
 DECLARE sa_sch_appt_ind = c1 WITH noconstant(""), protect
 DECLARE lngtxtrf_rtf = c1 WITH protect, noconstant("")
 DECLARE glrspunit_ct = i4 WITH protect, noconstant(0)
 DECLARE glacctref_ct = i4 WITH protect, noconstant(0)
 DECLARE anestref_cnt = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE anesthesia_rec_cnt = i4 WITH protect, noconstant(0)
 DECLARE get_hf_orphan_files = c1 WITH protect, noconstant("N")
 DECLARE caremgmt_cmclnrv_cnt = i4 WITH protect, noconstant(0)
 RECORD time_zone_by_loc(
   1 qual[*]
     2 location_id = f8
     2 time_zone = f8
   1 preloaded_ind = i2
 )
 RECORD rstats(
   1 qual[*]
     2 file_type = vc
     2 extract_date = vc
     2 extract_time = vc
     2 record_count = i4
     2 get_script_version = vc
     2 create_script_version = vc
     2 script_start_dt_tm = vc
     2 script_end_dt_tm = vc
     2 error_ind = i2
     2 file_cnt = i2
 )
 RECORD inst_list(
   1 qual[*]
     2 loc_cd = f8
 )
 RECORD org_list(
   1 qual[*]
     2 org_id = f8
 )
 RECORD hf_list(
   1 qual[*]
     2 file_list = vc
 )
 RECORD faclty_list(
   1 qual[*]
     2 faclty_cd = f8
 )
 RECORD ex_contrib_sys_list(
   1 qual[*]
     2 contributor_system_cd = f8
 )
 RECORD encounter_nk_list(
   1 qual[*]
     2 encounter_id = f8
     2 encounter_nk = vc
 )
 RECORD man_scripts_list(
   1 qual[*]
     2 script = vc
     2 stats = vc
 )
 RECORD rbedrock(
   1 qual[*]
     2 file_type = vc
 )
 RECORD rlighthouse(
   1 qual[*]
     2 file_type = vc
 )
 RECORD cdf_list(
   1 qual[*]
     2 meaning = vc
 )
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = gvc
 )
 RECORD logical_domain_list(
   1 qual[*]
     2 logical_domain_id = f8
 )
 DECLARE file_dir = vc WITH protect, noconstant("")
 DECLARE file_name = vc WITH protect, noconstant("")
 SET par = reflect(parameter(1,0))
 IF (par=" ")
  CALL echo("File dir not passed in.  Exiting...")
  GO TO end_program
 ELSE
  SET file_dir = parameter(1,0)
 ENDIF
 SET par = reflect(parameter(2,0))
 IF (par=" ")
  CALL echo("File name not passed in.  Exiting...")
  GO TO end_program
 ELSE
  SET file_name = parameter(2,0)
 ENDIF
 SET from_clause = "dm_info"
 SET dbchk_from = "clinical_event"
 SET errcode = error(errmsg,1)
 SET errcode = 1
 SET count_loop = 0
 WHILE (errcode != 0)
   SELECT INTO "nl"
    FROM (parser(dbchk_from) c)
    WITH nocounter, maxrec = 1
   ;end select
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    CALL echo(build("The database is down. Retry in 5min - ",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")
      ))
    CALL pause(300)
    SET count_loop = (count_loop+ 1)
   ENDIF
   IF (count_loop=3)
    CALL echo("Extraction process aborted. Database is down")
    SET errcode = error(errmsg,1)
    GO TO end_program
   ENDIF
 ENDWHILE
 IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) < 80303))
  SET trace memsort 0
 ENDIF
 SELECT INTO "nl:"
  FROM time_zone_r t
  WHERE t.parent_entity_name="LOCATION"
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(time_zone_by_loc->qual,(cnt+ 9))
   ENDIF
   time_zone_by_loc->qual[cnt].location_id = t.parent_entity_id, time_zone_by_loc->qual[cnt].
   time_zone = datetimezonebyname(nullterm(t.time_zone))
  FOOT REPORT
   stat = alterlist(time_zone_by_loc->qual,cnt)
  WITH nocounter
 ;end select
 SET time_zone_by_loc->preloaded_ind = 1
 FOR (i = 1 TO 255)
   SET str_find = notrim(concat(str_find,char(i)))
 ENDFOR
 FOR (i = 1 TO 255)
   IF (((i < 32) OR (i IN (124, 127, 129, 141, 143,
   144, 157, 160))) )
    SET str_replace = notrim(concat(str_replace," "))
   ELSE
    SET str_replace = notrim(concat(str_replace,char(i)))
   ENDIF
 ENDFOR
 SET extract_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3),3)
 SELECT INTO "NL:"
  FROM (parser(from_clause) di)
  WHERE ((di.info_domain="PI EDW DATA CONFIGURATION|*") OR (((di.info_domain="PI EDW OPERATIONS|*")
   OR (di.info_domain="PI EDW SYSTEMS CONFIGURATION|*")) ))
  DETAIL
   q_info_name = substring(1,(findstring("|",di.info_name,1) - 1),di.info_name), q_info_char =
   substring(1,(findstring("|",di.info_char,1) - 1),di.info_char)
   CASE (q_info_name)
    OF "EDW_IND":
     edw_ind = q_info_char
    OF "HEALTHFACTS_IND":
     healthfacts_ind = q_info_char
    OF "HEALTHSENTRY_IND":
     healthsentry_ind = q_info_char
    OF "RAW_TABLE":
     raw_table = q_info_char
    OF "ACT_EXT_FROM_DT_TM":
     IF (cnvtdatetime(q_info_char)=null)
      act_from_dt_tm = cnvtdatetime(curdate,curtime3)
     ELSE
      act_from_dt_tm = cnvtdatetime(q_info_char)
     ENDIF
    OF "ACT_EXT_TO_DT_TM":
     IF (cnvtdatetime(q_info_char)=null)
      IF (stand_by_ind="N")
       act_to_dt_tm = cnvtdatetime(curdate,curtime3)
      ENDIF
     ELSE
      act_to_dt_tm = cnvtdatetime(q_info_char)
     ENDIF
    OF "HISTORIC_START_DT_TM":
     IF (cnvtdatetime(q_info_char) != null)
      hist_from_dt_tm = cnvtdatetime(q_info_char)
     ENDIF
    OF "HISTORIC_DAYS_TO_EXTRACT":
     days_to_extract = cnvtint(q_info_char)
    OF "HEALTH_SYSTEM_ID":
     health_system_id = q_info_char
    OF "HEALTH_SYSTEM_SOURCE_ID":
     health_system_source_id = q_info_char
    OF "ENCOUNTER_NK":
     encounter_nk = q_info_char
    OF "ADMIT_DT_TM":
     admit_dt_tm = q_info_char
    OF "DISCHARGE_DT_TM":
     discharge_dt_tm = q_info_char
    OF "FILTER_FIELD_1":
     filter_field_1 = q_info_char
    OF "FILTER_FIELD_2":
     filter_field_2 = q_info_char
    OF "FILTER_FIELD_3":
     filter_field_3 = q_info_char
    OF "FILTER_VALUE_1":
     filter_value_1 = q_info_char
    OF "FILTER_VALUE_2":
     filter_value_2 = q_info_char
    OF "FILTER_VALUE_3":
     filter_value_3 = q_info_char
    OF "EXTRACT_TYPE":
     global_extract_ind = q_info_char
    OF "INITIAL_ENTERPRISE_IND":
     init_enterprise_ind = q_info_char
    OF "INSTITUTION_LIST":
     inst_input = q_info_char,num = 0,
     WHILE ( NOT (inst_input=""))
       comma_pos = findstring(",",inst_input), num = (num+ 1), stat = alterlist(inst_list->qual,num)
       IF (comma_pos=0)
        inst_list->qual[num].loc_cd = cnvtint(inst_input), inst_input = ""
       ELSE
        inst_list->qual[num].loc_cd = cnvtint(substring(1,(comma_pos - 1),inst_input)), inst_input =
        trim(substring((comma_pos+ 1),(size(inst_input) - comma_pos),inst_input))
       ENDIF
     ENDWHILE
     ,
     IF (size(inst_list->qual,5) > 0)
      inst_filter =
      "EXPAND(idx,1,size(inst_list->qual,5),encounter.loc_facility_cd,inst_list->qual[idx]->loc_cd)"
     ENDIF
    OF "ORGANIZATION_LIST":
     org_input = q_info_char,num = 0,
     WHILE ( NOT (org_input=""))
       comma_pos = findstring(",",org_input), num = (num+ 1), stat = alterlist(org_list->qual,num)
       IF (comma_pos=0)
        org_list->qual[num].org_id = cnvtint(org_input), org_input = ""
       ELSE
        org_list->qual[num].org_id = cnvtint(substring(1,(comma_pos - 1),org_input)), org_input =
        trim(substring((comma_pos+ 1),(size(org_input) - comma_pos),org_input))
       ENDIF
     ENDWHILE
     ,
     IF (size(org_list->qual,5) > 0)
      org_filter =
      "EXPAND(idx,1,size(org_list->qual,5),encounter.organization_id,org_list->qual[idx]->org_id)"
     ENDIF
    OF "HF_FILETYPE_LIST":
     hf_input = q_info_char,num = 0,
     WHILE ( NOT (hf_input=""))
       comma_pos = findstring(",",hf_input), num = (num+ 1), stat = alterlist(hf_list->qual,num)
       IF (comma_pos=0)
        hf_list->qual[num].file_list = hf_input, hf_input = ""
       ELSE
        hf_list->qual[num].file_list = trim(substring(1,(comma_pos - 1),hf_input),3), hf_input = trim
        (substring((comma_pos+ 1),(size(hf_input) - comma_pos),hf_input),3)
       ENDIF
     ENDWHILE
    OF "EXCLUDE_CONTRIB_SYSTEM_LIST":
     ex_contrib_sys_input = q_info_char,num = 0,
     WHILE ( NOT (ex_contrib_sys_input=""))
       comma_pos = findstring(",",ex_contrib_sys_input), num = (num+ 1), stat = alterlist(
        ex_contrib_sys_list->qual,num)
       IF (comma_pos=0)
        ex_contrib_sys_list->qual[num].contributor_system_cd = cnvtint(ex_contrib_sys_input),
        ex_contrib_sys_input = ""
       ELSE
        ex_contrib_sys_list->qual[num].contributor_system_cd = cnvtint(substring(1,(comma_pos - 1),
          ex_contrib_sys_input)), ex_contrib_sys_input = trim(substring((comma_pos+ 1),(size(
           ex_contrib_sys_input) - comma_pos),ex_contrib_sys_input))
       ENDIF
     ENDWHILE
     ,
     IF (size(ex_contrib_sys_list->qual,5) > 0)
      contrib_sys_filter = concat("NOT EXPAND(idx,1,size(ex_contrib_sys_list->qual,5)",
       ",ce.contributor_system_cd,ex_contrib_sys_list->qual[idx]->contributor_system_cd)")
     ENDIF
    OF "TIME_ZONE":
     default_time_zone = cnvtreal(q_info_char)
    OF "DEBUG_IND":
     debug = q_info_char
    OF "PRINT_COST_IND":
     printcost = q_info_char
    OF "GET_ORPHAN_FILES":
     get_orphan_files = q_info_char
    OF "ALTERNATE1_ID":
     alternate1_id = q_info_char
    OF "ALTERNATE2_ID":
     alternate2_id = q_info_char
    OF "ALTERNATE3_ID":
     alternate3_id = q_info_char
    OF "ALTERNATE4_ID":
     alternate4_id = q_info_char
    OF "ALTERNATE5_ID":
     alternate5_id = q_info_char
    OF "PER_ALT_IDENT_1":
     per_alt_ident_1 = cnvtupper(q_info_char)
    OF "PER_ALT_IDENT_2":
     per_alt_ident_2 = cnvtupper(q_info_char)
    OF "PER_ALT_IDENT_3":
     per_alt_ident_3 = cnvtupper(q_info_char)
    OF "PER_ALT_IDENT_4":
     per_alt_ident_4 = cnvtupper(q_info_char)
    OF "PER_ALT_IDENT_5":
     per_alt_ident_5 = cnvtupper(q_info_char)
    OF "ENC_ALT_IDENT_1":
     enc_alt_ident_1 = cnvtupper(q_info_char)
    OF "ENC_ALT_IDENT_2":
     enc_alt_ident_2 = cnvtupper(q_info_char)
    OF "ENC_ALT_IDENT_3":
     enc_alt_ident_3 = cnvtupper(q_info_char)
    OF "ENC_ALT_IDENT_4":
     enc_alt_ident_4 = cnvtupper(q_info_char)
    OF "ENC_ALT_IDENT_5":
     enc_alt_ident_5 = cnvtupper(q_info_char)
    OF "SMALL_BATCH_SIZE":
     small_batch_size = cnvtint(q_info_char)
    OF "MEDIUM_BATCH_SIZE":
     medium_batch_size = cnvtint(q_info_char)
    OF "LARGE_BATCH_SIZE":
     large_batch_size = cnvtint(q_info_char)
    OF "PERIOP_DOC_DAYS_BACK":
     periop_doc_days_back = cnvtint(q_info_char)
    OF "EXTRACT_DIR":
     extract_dir = q_info_char
    OF "REFERENCE":
     IF (q_info_char="Y")
      reference_ind = 1
     ELSE
      reference_ind = 0
     ENDIF
    OF "ACTIVITY":
     IF (q_info_char="Y")
      activity_ind = 1
     ELSE
      activity_ind = 0
     ENDIF
    OF "SUSCEPT_CE_INTERFACE_FLG":
     suscept_ce_interface_flg = cnvtint(q_info_char)
    OF "SUSCEPT_CE_INTERFACE_FACILITIES":
     faclty_input = q_info_char,num = 0,
     WHILE ( NOT (faclty_input=""))
       comma_pos = findstring(",",faclty_input), num = (num+ 1), stat = alterlist(faclty_list->qual,
        num)
       IF (comma_pos=0)
        faclty_list->qual[num].faclty_cd = cnvtint(faclty_input), faclty_input = ""
       ELSE
        faclty_list->qual[num].faclty_cd = cnvtint(substring(1,(comma_pos - 1),faclty_input)),
        faclty_input = trim(substring((comma_pos+ 1),(size(faclty_input) - comma_pos),faclty_input))
       ENDIF
     ENDWHILE
    OF "ANATOMIC_PATH_ORDER_INTERFACE_FACILITIES":
     anatomic_path_order_interface_facilities = concat(" ",trim(q_info_char,4)," ")
    OF "ANATOMIC_PATH_ORDER_INTERFACE_FLG":
     anatomic_path_order_interface_flg = evaluate(isnumeric(q_info_char),0,0,cnvtint(q_info_char))
    OF "GEN_LAB_ORDER_INTERFACE_FACILITIES":
     gen_lab_order_interface_facilities = concat(" ",trim(q_info_char,4)," ")
    OF "GEN_LAB_ORDER_INTERFACE_FLG":
     gen_lab_order_interface_flg = evaluate(isnumeric(q_info_char),0,0,cnvtint(q_info_char))
    OF "MICRO_ORDER_INTERFACE_FACILITIES":
     micro_order_interface_facilities = concat(" ",trim(q_info_char,4)," ")
    OF "MICRO_ORDER_INTERFACE_FLG":
     micro_order_interface_flg = evaluate(isnumeric(q_info_char),0,0,cnvtint(q_info_char))
    OF "PHARM_ORDER_INTERFACE_FACILITIES":
     pharm_order_interface_facilities = concat(" ",trim(q_info_char,4)," ")
    OF "PHARM_ORDER_INTERFACE_FLG":
     pharm_order_interface_flg = evaluate(isnumeric(q_info_char),0,0,cnvtint(q_info_char))
    OF "EXCLUDE_DIAGNOSIS_CORRELATION":
     exclude_diagnosis_correlation = q_info_char
    OF "SORT_DIR":
     sort_dir = q_info_char,
     IF (sort_dir="")
      sort_dir = logical("cer_temp")
     ENDIF
    OF "SCR_TERM_LANGUAGE":
     scr_term_language = cnvtint(q_info_char)
    OF "RDBMS_USER_NAME":
     v_rdbms_user = q_info_char
    OF "RDBMS_PSWD":
     v_rdbms_pswd = q_info_char
    OF "LREGVIEW_DB":
     v_lregview_db = q_info_char
    OF "RAW_PERSON_EXTRACT_IND":
     hist_per_raw_ind = q_info_char
    OF "SSN_IND":
     ssn_ind = q_info_char
    OF "PERSONS_ONLY_ON_ACTIVITY_IND":
     persons_only_on_activity_ind = q_info_char
    OF "MRN_IND":
     mrn_ind = q_info_char
    OF "FIN_IND":
     fin_ind = q_info_char
   ENDCASE
  WITH check
 ;end select
 SET logical cclscratch sort_dir
 CALL echo(build("HEALTH_SYSTEM_ID IS > ",health_system_id))
 CALL echo(build("HEALTH_SYSTEM_SOURCE_ID IS > ",health_system_source_id))
 CALL echo(build("EXTRACT_DT_TM IS > ",format(extract_dt_tm,"MM/DD/YYYY HH:MM:SS;;Q")))
 IF (curqual=0
  AND hist_per_raw_ind="N")
  CALL echo("NO RECORDS FOUND ON THE DM_INFO TABLE.")
  GO TO end_program
 ENDIF
 IF (((admit_dt_tm != "ENCOUNTER.REG_DT_TM") OR (discharge_dt_tm != "ENCOUNTER.DISCH_DT_TM")) )
  SET admit_str_size = size(admit_dt_tm)
  SET disch_str_size = size(discharge_dt_tm)
  SET bad_date_field = 0
  SET admit_table = substring(1,(findstring(".",admit_dt_tm) - 1),admit_dt_tm)
  SET admit_column = substring((findstring(".",admit_dt_tm)+ 1),(admit_str_size - findstring(".",
    admit_dt_tm)),admit_dt_tm)
  SET disch_table = substring(1,(findstring(".",discharge_dt_tm) - 1),discharge_dt_tm)
  SET disch_column = substring((findstring(".",discharge_dt_tm)+ 1),(disch_str_size - findstring(".",
    discharge_dt_tm)),discharge_dt_tm)
  SELECT INTO "nl:"
   FROM dtableattr a,
    dtableattrl l
   WHERE a.table_name IN (admit_table, disch_table)
   DETAIL
    IF (((l.attr_name=admit_column) OR (l.attr_name=disch_column))
     AND l.type != "Q")
     bad_date_field = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (bad_date_field)
   CALL echo("The ADMIT_DT_TM and/or DISCHARGE_DT_TM are not valid date fields")
   GO TO end_program
  ENDIF
 ENDIF
 IF (debug="Y")
  SET message = information
 ELSE
  SET message = noinformation
 ENDIF
 IF (printcost="Y")
  SET trace = nordbdebug
  SET message = noinformation
 ENDIF
 SET extract_dt_fmt = format(extract_dt_tm,"MMDDYY;;D")
 SET extract_tm_fmt = format(extract_dt_tm,"HHMM;;M")
 SET extract_dt_tm_fmt = format(extract_dt_tm,"MM/DD/YYYY HH:MM;;D")
 SET act_from_dt_fmt = format(act_from_dt_tm,"MMDDYY;;D")
 SET act_from_tm_fmt = format(act_from_dt_tm,"HHMM;;M")
 SET act_from_dt_tm_fmt = format(act_from_dt_tm,"MM/DD/YYYY HH:MM;;D")
 SET act_to_dt_fmt = format(act_to_dt_tm,"MMDDYY;;D")
 SET act_to_tm_fmt = format(act_to_dt_tm,"HHMM;;M")
 SET act_to_dt_tm_fmt = format(act_to_dt_tm,"MM/DD/YYYY HH:MM;;D")
 SET script_start_dt_tm = format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")
 SET edw_file_prefix = concat(file_dir,"/EDW_",health_system_source_id,"_")
 SET file_prefix = concat(file_dir,"/DW_",health_system_source_id,"_")
 SET file_suffix = concat(extract_dt_fmt,"_",extract_tm_fmt)
 SET docinput_extractfile = concat(trim(file_prefix,3),"DOCINPUT_",trim(file_suffix,3))
 SET edw_stats_extractfile = concat(trim(edw_file_prefix,3),"STATS_",trim(file_suffix,3))
 CALL echo("##### DOCUMENTATION_INPUT_IND #####")
 CALL echo("***** EDW_DOC_INPUT_REF *****")
 CALL echo(cost(2))
 CALL echo(build("DOCINPUT Start :",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")))
 SET script_start_dt_tm = format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")
 CALL edwcreatescriptstatus("DOCINPUT")
 SET error_ind = 1
 DECLARE rtl2_defined = i2 WITH private, noconstant(0)
 FREE DEFINE rtl2
 DECLARE line_cnt = i4 WITH noconstant(0)
 FREE RECORD reply_orphans
 RECORD reply_orphans(
   1 qual[*]
     2 orphan_key = f8
 )
 SET full_file = concat(file_dir,"/",file_name)
 IF (findfile(full_file) != 0)
  CALL echo(build("processing ",full_file))
  SET logical file_name_l full_file
  DEFINE rtl2 "file_name_l"
  SET rtl2_defined = 1
 ENDIF
 IF (rtl2_defined=1)
  SELECT INTO "nl:"
   FROM rtl2t t
   HEAD REPORT
    line_cnt = 0, pipe_loc = 0, line_length = 0
   DETAIL
    line_cnt = (line_cnt+ 1)
    IF (mod(line_cnt,10)=1)
     stat = alterlist(reply_orphans->qual,(line_cnt+ 9))
    ENDIF
    pipe_loc = findstring("|",t.line), line_length = textlen(trim(t.line)), reply_orphans->qual[
    line_cnt].orphan_key = cnvtreal(substring((pipe_loc+ 1),(line_length - pipe_loc),t.line))
   FOOT REPORT
    stat = alterlist(reply_orphans->qual,line_cnt)
   WITH nocounter, maxcol = 2000
  ;end select
  SET return_val = 1
 ENDIF
 SET syscmd = concat("mv ",full_file," ",file_dir,"/archive/docinput_conv_",
  extract_dt_fmt,"_",extract_tm_fmt,".dat")
 SET len = size(trim(syscmd))
 SET status = 0
 CALL dcl(syscmd,len,status)
 RECORD doc_input_ref_keys(
   1 qual[*]
     2 dcp_form_instance_id = f8
     2 dcp_forms_def_id = f8
     2 dcp_section_instance_id = f8
     2 dcp_input_ref_id = f8
 )
 RECORD temp(
   1 index_cnt = i4
   1 index_qual[*]
     2 form_inst_sk = f8
     2 form_description = vc
     2 section_inst_sk = f8
     2 section_description = vc
     2 doc_component_sk = vc
     2 doc_input_sk = vc
     2 form_ref_sk = f8
     2 form_def_sk = f8
     2 form_definition = vc
     2 form_beg_effective_dt_tm = dq8
     2 form_end_effective_dt_tm = dq8
     2 section_ref_sk = f8
     2 section_definition = vc
     2 section_sequence = i4
     2 section_beg_effective_dt_tm = dq8
     2 section_end_effective_dt_tm = dq8
     2 input_desc = vc
     2 input_sequence = i4
     2 input_type_flg = i4
     2 input_task_assay_sk = f8
     2 input_display = vc
     2 merge_id = f8
     2 grid_name = vc
     2 grid_column_task_assay_sk = f8
     2 grid_row_task_assay_sk = f8
     2 grid_column_seq = i4
     2 grid_row_seq = i4
     2 grid_intersect_event_ref = f8
     2 input_type = i2
     2 grid_ind = i2
     2 grid_flag = i2
     2 dcp_input_ref_id = f8
     2 input_ref_seq = i4
     2 src_active_ind = c1
     2 grid_cnt = i2
     2 grid_qual[*]
       3 grid_doc_sk = vc
       3 grid_input_sk = vc
       3 input_desc = vc
       3 input_sequence = i4
       3 input_type_flg = i2
       3 input_task_assay_sk = f8
       3 input_display = vc
       3 grid_name = vc
       3 col_task_assay_sk = f8
       3 col_pvc_value = vc
       3 col_seq = i4
       3 col_merge_name = vc
       3 col_dta_mnemonic = vc
       3 col_dta_description = vc
       3 row_task_assay_sk = f8
       3 row_pvc_value = vc
       3 row_seq = i4
       3 row_merge_name = vc
       3 row_dta_mnemonic = vc
       3 row_dta_description = vc
       3 grid_intersect_event_ref = f8
       3 src_active_ind = c1
 )
 RECORD templabel(
   1 section_cnt = i4
   1 section_qual[*]
     2 dcp_section_instance_id = f8
     2 input_cnt = i4
     2 input_qual[*]
       3 dcp_input_ref_id = f8
       3 input_description = vc
       3 input_sequence = i4
       3 merge_id = f8
       3 pvc_value = vc
       3 input_type = i4
       3 attdta_ind = i2
       3 mnemonic = vc
       3 task_assay_cd = f8
 )
 RECORD label(
   1 cnt = i4
   1 qual[*]
     2 dcp_section_instance_id = f8
     2 dcp_input_ref_id = f8
     2 input_description = vc
     2 input_sequence = i4
     2 input_type = i2
     2 merge_id = f8
     2 pvc_value = vc
     2 mnemonic = vc
     2 task_assay_cd = f8
 )
 RECORD data(
   1 cnt = i4
   1 qual[*]
     2 form_inst_sk = f8
     2 section_inst_sk = f8
     2 doc_component_sk = vc
     2 doc_input_sk = vc
     2 form_ref_sk = f8
     2 form_description = vc
     2 form_definition = vc
     2 form_beg_effective_dt_tm = dq8
     2 form_end_effective_dt_tm = dq8
     2 section_ref_sk = f8
     2 section_description = vc
     2 section_definition = vc
     2 section_sequence = i4
     2 section_beg_effective_dt_tm = dq8
     2 section_end_effective_dt_tm = dq8
     2 input_desc = vc
     2 input_sequence = i4
     2 input_type_flg = i4
     2 input_task_assay_sk = f8
     2 input_display = vc
     2 grid_ind = i2
     2 grid_name = vc
     2 grid_column_task_assay_sk = f8
     2 grid_row_task_assay_sk = f8
     2 grid_column_seq = i4
     2 grid_row_seq = i4
     2 grid_intersect_event_ref = f8
     2 src_active_ind = c1
 )
 DECLARE cntx = i4 WITH protect, noconstant(0)
 DECLARE cnty = i4 WITH protect, noconstant(0)
 DECLARE cntz = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE key_cnt = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE nlines = i4 WITH protect, noconstant(0)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(small_batch_size)
 DECLARE outer_keys_start = i4 WITH noconstant(0)
 DECLARE outer_keys_end = i4 WITH noconstant(0)
 DECLARE outer_keys_batch = i4 WITH constant(small_batch_size)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(line_cnt)),
   dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr
  PLAN (d
   WHERE line_cnt > 0)
   JOIN (dfr
   WHERE (dfr.dcp_form_instance_id=reply_orphans->qual[d.seq].orphan_key))
   JOIN (dfd
   WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id
    AND dfd.dcp_forms_ref_id=dfr.dcp_forms_ref_id)
   JOIN (dsr
   WHERE dsr.dcp_section_instance_id > 0
    AND dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
    AND ((dsr.active_ind=1) OR (dsr.beg_effective_dt_tm BETWEEN dfr.beg_effective_dt_tm AND dfr
   .end_effective_dt_tm)) )
  HEAD REPORT
   key_cnt = 0
  DETAIL
   key_cnt = (key_cnt+ 1)
   IF (mod(key_cnt,100)=1)
    stat = alterlist(doc_input_ref_keys->qual,(key_cnt+ 99))
   ENDIF
   doc_input_ref_keys->qual[key_cnt].dcp_form_instance_id = dfr.dcp_form_instance_id,
   doc_input_ref_keys->qual[key_cnt].dcp_forms_def_id = dfd.dcp_forms_def_id, doc_input_ref_keys->
   qual[key_cnt].dcp_section_instance_id = dsr.dcp_section_instance_id
  FOOT REPORT
   stat = alterlist(doc_input_ref_keys->qual,key_cnt)
  WITH nocounter
 ;end select
 SET outer_keys_start = 1
 SET outer_keys_end = minval(((outer_keys_start+ outer_keys_batch) - 1),key_cnt)
 WHILE (outer_keys_start <= outer_keys_end)
   SET stat = alterlist(temp->index_qual,0)
   SET temp->index_cnt = 0
   IF (debug="Y")
    CALL echo(concat("Looping from outer_keys_start = ",build(outer_keys_start),
      " to outer_keys_end = ",build(outer_keys_end)))
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = ((outer_keys_end - outer_keys_start)+ 1)),
     dcp_section_ref dsr,
     dcp_input_ref dir
    PLAN (d)
     JOIN (dsr
     WHERE (dsr.dcp_section_instance_id=doc_input_ref_keys->qual[((d.seq+ outer_keys_start) - 1)].
     dcp_section_instance_id))
     JOIN (dir
     WHERE dir.dcp_input_ref_id > 0
      AND dir.dcp_section_instance_id=dsr.dcp_section_instance_id)
    HEAD REPORT
     cntx = 0, cnty = 0, cntz = 0
    DETAIL
     cntx = (cntx+ 1)
     IF (dir.dcp_input_ref_id > 0)
      IF (dir.input_type != 1)
       temp->index_cnt = (temp->index_cnt+ 1), stat = alterlist(temp->index_qual,temp->index_cnt),
       temp->index_qual[temp->index_cnt].dcp_input_ref_id = dir.dcp_input_ref_id,
       temp->index_qual[temp->index_cnt].form_inst_sk = doc_input_ref_keys->qual[d.seq].
       dcp_form_instance_id, temp->index_qual[temp->index_cnt].form_def_sk = doc_input_ref_keys->
       qual[d.seq].dcp_forms_def_id, temp->index_qual[temp->index_cnt].section_inst_sk =
       doc_input_ref_keys->qual[d.seq].dcp_section_instance_id,
       temp->index_qual[temp->index_cnt].input_type = dir.input_type, temp->index_qual[temp->
       index_cnt].input_ref_seq = dir.input_ref_seq, temp->index_qual[temp->index_cnt].input_desc =
       dir.description,
       temp->index_qual[temp->index_cnt].input_sequence = dir.input_ref_seq, temp->index_qual[temp->
       index_cnt].input_type_flg = dir.input_type
      ELSE
       cnty = (cnty+ 1), cntz = (cntz+ 1), templabel->section_cnt = cntz,
       stat = alterlist(templabel->section_qual,templabel->section_cnt)
       IF (cntz=1)
        templabel->section_qual[cntz].dcp_section_instance_id = dir.dcp_section_instance_id
       ELSE
        IF ((templabel->section_qual[(cntz - 1)].dcp_section_instance_id=dir.dcp_section_instance_id)
        )
         cntz = (cntz - 1)
        ELSE
         templabel->section_qual[cntz].dcp_section_instance_id = dir.dcp_section_instance_id
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = temp->index_cnt),
     dcp_section_ref dsr
    PLAN (d)
     JOIN (dsr
     WHERE (dsr.dcp_section_instance_id=temp->index_qual[d.seq].section_inst_sk))
    DETAIL
     temp->index_qual[d.seq].section_ref_sk = dsr.dcp_section_ref_id, temp->index_qual[d.seq].
     section_description = dsr.description, temp->index_qual[d.seq].section_definition = dsr
     .definition,
     temp->index_qual[d.seq].section_beg_effective_dt_tm = dsr.beg_effective_dt_tm, temp->index_qual[
     d.seq].section_end_effective_dt_tm = dsr.end_effective_dt_tm, temp->index_qual[d.seq].
     src_active_ind = evaluate(dsr.active_ind,0,"0","1")
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = temp->index_cnt),
     dcp_forms_def dfd
    PLAN (d)
     JOIN (dfd
     WHERE (dfd.dcp_forms_def_id=temp->index_qual[d.seq].form_def_sk))
    DETAIL
     temp->index_qual[d.seq].section_sequence = dfd.section_seq, temp->index_qual[d.seq].form_ref_sk
      = dfd.dcp_forms_ref_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = temp->index_cnt),
     dcp_forms_ref dfr
    PLAN (d)
     JOIN (dfr
     WHERE (dfr.dcp_form_instance_id=temp->index_qual[d.seq].form_inst_sk))
    DETAIL
     temp->index_qual[d.seq].form_description = dfr.description, temp->index_qual[d.seq].
     form_definition = dfr.definition, temp->index_qual[d.seq].form_beg_effective_dt_tm = dfr
     .beg_effective_dt_tm,
     temp->index_qual[d.seq].form_end_effective_dt_tm = dfr.end_effective_dt_tm, temp->index_qual[d
     .seq].src_active_ind = evaluate(dfr.active_ind,0,"0",temp->index_qual[d.seq].src_active_ind)
    WITH nocounter
   ;end select
   IF ((temp->index_cnt=0))
    IF (debug="Y")
     CALL echo(
      "NO matching record found from DCP_Forms_Ref, DCP_Forms_Def, DCP_Section_Ref and DCP_Input_Ref tables"
      )
    ENDIF
    GO TO endprogram
   ELSE
    IF (debug="Y")
     CALL echo(concat("Found ",build(temp->index_cnt),
       " records from DCP_Forms_Ref, DCP_Forms_Def, DCP_Section_Ref and DCP_Input_Ref tables",
       " matching specified time range "))
    ENDIF
   ENDIF
   SET cnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(temp->index_cnt)),
     name_value_prefs nvp,
     discrete_task_assay dta
    PLAN (d1
     WHERE d1.seq > 0)
     JOIN (nvp
     WHERE nvp.parent_entity_name="DCP_INPUT_REF"
      AND (nvp.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp.pvc_name="discrete_task_assay"
      AND  NOT ((temp->index_qual[d1.seq].input_type IN (1, 19, 17, 5, 15,
     14, 21))))
     JOIN (dta
     WHERE dta.task_assay_cd=nvp.merge_id)
    DETAIL
     cnt = (cnt+ 1), temp->index_qual[d1.seq].grid_flag = 1, temp->index_qual[d1.seq].grid_ind = 0
     IF ((temp->index_qual[d1.seq].input_type IN (2, 11)))
      temp->index_qual[d1.seq].doc_component_sk = concat("d",trim(cnvtstring(temp->index_qual[d1.seq]
         .dcp_input_ref_id)))
     ELSE
      temp->index_qual[d1.seq].doc_component_sk = trim(cnvtstring(dta.event_cd))
     ENDIF
     temp->index_qual[d1.seq].doc_input_sk = concat(trim(cnvtstring(temp->index_qual[d1.seq].
        form_inst_sk,16)),"~",trim(cnvtstring(temp->index_qual[d1.seq].section_inst_sk,16)),"~",trim(
       temp->index_qual[d1.seq].doc_component_sk)), temp->index_qual[d1.seq].merge_id = nvp.merge_id,
     temp->index_qual[d1.seq].input_display = dta.mnemonic,
     temp->index_qual[d1.seq].input_task_assay_sk = nvp.merge_id, temp->index_qual[d1.seq].
     src_active_ind = evaluate(nvp.active_ind,0,"0",evaluate(temp->index_qual[d1.seq].src_active_ind,
       "0","0","1"))
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cnt)," records for component"))
   ENDIF
   SET cntx = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(temp->index_cnt)),
     dcp_input_ref dir,
     name_value_prefs nvp,
     discrete_task_assay dta
    PLAN (d1
     WHERE d1.seq > 0
      AND (temp->index_qual[d1.seq].grid_flag=0)
      AND (temp->index_qual[d1.seq].input_type=2))
     JOIN (dir
     WHERE (dir.dcp_input_ref_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND dir.module="PVTRACKFORMS")
     JOIN (nvp
     WHERE nvp.parent_entity_id=dir.dcp_input_ref_id
      AND nvp.parent_entity_name="DCP_INPUT_REF"
      AND nvp.merge_id > 0)
     JOIN (dta
     WHERE dta.task_assay_cd=outerjoin(nvp.merge_id))
    HEAD d1.seq
     cntx = (cntx+ 1), cnt = 0, temp->index_qual[d1.seq].grid_ind = 1
    DETAIL
     cnt = (cnt+ 1), temp->index_qual[d1.seq].grid_cnt = cnt, stat = alterlist(temp->index_qual[d1
      .seq].grid_qual,temp->index_qual[d1.seq].grid_cnt),
     temp->index_qual[d1.seq].grid_qual[cnt].grid_doc_sk = build(cnvtstring(temp->index_qual[d1.seq].
       dcp_input_ref_id,16),"~",cnvtstring(dta.event_cd,16)), temp->index_qual[d1.seq].grid_qual[cnt]
     .grid_input_sk = build(cnvtstring(temp->index_qual[d1.seq].form_inst_sk,16),"~",cnvtstring(temp
       ->index_qual[d1.seq].section_inst_sk,16),"~",trim(temp->index_qual[d1.seq].grid_qual[cnt].
       grid_doc_sk)), temp->index_qual[d1.seq].grid_qual[cnt].grid_name = temp->index_qual[d1.seq].
     input_desc,
     temp->index_qual[d1.seq].grid_qual[cnt].input_desc = temp->index_qual[d1.seq].input_desc, temp->
     index_qual[d1.seq].grid_qual[cnt].input_sequence = temp->index_qual[d1.seq].input_ref_seq, temp
     ->index_qual[d1.seq].grid_qual[cnt].input_type_flg = temp->index_qual[d1.seq].input_type,
     temp->index_qual[d1.seq].grid_qual[cnt].input_task_assay_sk = nvp.merge_id, temp->index_qual[d1
     .seq].grid_qual[cnt].input_display = dta.mnemonic, temp->index_qual[d1.seq].grid_qual[cnt].
     col_task_assay_sk = nvp.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].col_pvc_value = nvp.pvc_value, temp->index_qual[d1.seq].
     grid_qual[cnt].col_seq = nvp.sequence, temp->index_qual[d1.seq].grid_qual[cnt].col_merge_name =
     nvp.merge_name,
     temp->index_qual[d1.seq].grid_qual[cnt].col_dta_mnemonic = dta.mnemonic, temp->index_qual[d1.seq
     ].grid_qual[cnt].col_dta_description = dta.description, temp->index_qual[d1.seq].grid_qual[cnt].
     grid_intersect_event_ref = nvp.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind = evaluate(nvp.active_ind,0,"0",evaluate(
       temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind,"0","0","1"))
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cntx)," records for Tracking Controls"))
   ENDIF
   SET cntx = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(temp->index_cnt)),
     name_value_prefs nvp,
     name_value_prefs nvp2,
     discrete_task_assay dta
    PLAN (d1
     WHERE d1.seq > 0
      AND (temp->index_qual[d1.seq].grid_flag=0)
      AND (temp->index_qual[d1.seq].input_type=14))
     JOIN (nvp
     WHERE nvp.parent_entity_name="DCP_INPUT_REF"
      AND (nvp.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp.pvc_name="discrete_task_assay")
     JOIN (dta
     WHERE dta.task_assay_cd=outerjoin(nvp.merge_id))
     JOIN (nvp2
     WHERE (nvp2.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp2.parent_entity_name="DCP_INPUT_REF"
      AND nvp2.pvc_name="grid_event_cd")
    HEAD d1.seq
     cntx = (cntx+ 1), cnt = 0, temp->index_qual[d1.seq].grid_ind = 1
    DETAIL
     cnt = (cnt+ 1), temp->index_qual[d1.seq].grid_cnt = cnt, stat = alterlist(temp->index_qual[d1
      .seq].grid_qual,temp->index_qual[d1.seq].grid_cnt),
     temp->index_qual[d1.seq].grid_qual[cnt].grid_doc_sk = build(cnvtstring(temp->index_qual[d1.seq].
       dcp_input_ref_id,16),"~",cnvtstring(dta.event_cd,16)), temp->index_qual[d1.seq].grid_qual[cnt]
     .grid_input_sk = build(cnvtstring(temp->index_qual[d1.seq].form_inst_sk,16),"~",cnvtstring(temp
       ->index_qual[d1.seq].section_inst_sk,16),"~",trim(temp->index_qual[d1.seq].grid_qual[cnt].
       grid_doc_sk)), temp->index_qual[d1.seq].grid_qual[cnt].grid_name = uar_get_code_display(nvp2
      .merge_id),
     temp->index_qual[d1.seq].grid_qual[cnt].input_desc = temp->index_qual[d1.seq].input_desc, temp->
     index_qual[d1.seq].grid_qual[cnt].input_sequence = temp->index_qual[d1.seq].input_ref_seq, temp
     ->index_qual[d1.seq].grid_qual[cnt].input_type_flg = temp->index_qual[d1.seq].input_type,
     temp->index_qual[d1.seq].grid_qual[cnt].input_task_assay_sk = nvp.merge_id, temp->index_qual[d1
     .seq].grid_qual[cnt].input_display = dta.mnemonic, temp->index_qual[d1.seq].grid_qual[cnt].
     col_task_assay_sk = nvp.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].col_pvc_value = nvp.pvc_value, temp->index_qual[d1.seq].
     grid_qual[cnt].col_seq = nvp.sequence, temp->index_qual[d1.seq].grid_qual[cnt].col_merge_name =
     nvp.merge_name,
     temp->index_qual[d1.seq].grid_qual[cnt].col_dta_mnemonic = dta.mnemonic, temp->index_qual[d1.seq
     ].grid_qual[cnt].col_dta_description = dta.description, temp->index_qual[d1.seq].grid_qual[cnt].
     grid_intersect_event_ref = nvp2.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind = evaluate(nvp.active_ind,0,"0",evaluate(
       nvp2.active_ind,0,"0",evaluate(temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind,"0","0",
        "1")))
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cntx)," records for discrete grid"))
   ENDIF
   SET cntx = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(temp->index_cnt)),
     name_value_prefs nvp,
     name_value_prefs nvp2,
     name_value_prefs nvp3,
     discrete_task_assay dta
    PLAN (d1
     WHERE d1.seq > 0
      AND (temp->index_qual[d1.seq].grid_flag=0)
      AND (temp->index_qual[d1.seq].input_type=17))
     JOIN (nvp
     WHERE nvp.parent_entity_name="DCP_INPUT_REF"
      AND (nvp.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp.pvc_name="discrete_task_assay")
     JOIN (dta
     WHERE dta.task_assay_cd=nvp.merge_id)
     JOIN (nvp2
     WHERE (nvp2.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp2.parent_entity_name="DCP_INPUT_REF"
      AND nvp2.pvc_name="grid_event_cd")
     JOIN (nvp3
     WHERE (nvp3.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp3.parent_entity_name="DCP_INPUT_REF"
      AND nvp3.pvc_name="row_event_cd")
    HEAD d1.seq
     cntx = (cntx+ 1), cnt = 0, temp->index_qual[d1.seq].grid_ind = 1
    DETAIL
     cnt = (cnt+ 1), temp->index_qual[d1.seq].grid_cnt = cnt, stat = alterlist(temp->index_qual[d1
      .seq].grid_qual,temp->index_qual[d1.seq].grid_cnt),
     temp->index_qual[d1.seq].grid_qual[cnt].grid_doc_sk = build(cnvtstring(nvp2.merge_id,16),"~",
      cnvtstring(nvp3.merge_id,16),"~",cnvtstring(nvp.merge_id,16)), temp->index_qual[d1.seq].
     grid_qual[cnt].grid_input_sk = build(cnvtstring(temp->index_qual[d1.seq].form_inst_sk,16),"~",
      cnvtstring(temp->index_qual[d1.seq].section_inst_sk,16),"~",trim(temp->index_qual[d1.seq].
       grid_qual[cnt].grid_doc_sk)), temp->index_qual[d1.seq].grid_qual[cnt].grid_name =
     uar_get_code_display(nvp2.merge_id),
     temp->index_qual[d1.seq].grid_qual[cnt].input_desc = temp->index_qual[d1.seq].input_desc, temp->
     index_qual[d1.seq].grid_qual[cnt].input_sequence = temp->index_qual[d1.seq].input_ref_seq, temp
     ->index_qual[d1.seq].grid_qual[cnt].input_type_flg = temp->index_qual[d1.seq].input_type,
     temp->index_qual[d1.seq].grid_qual[cnt].input_task_assay_sk = nvp.merge_id, temp->index_qual[d1
     .seq].grid_qual[cnt].input_display = dta.mnemonic, temp->index_qual[d1.seq].grid_qual[cnt].
     col_task_assay_sk = nvp.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].col_pvc_value = nvp.pvc_value, temp->index_qual[d1.seq].
     grid_qual[cnt].col_seq = nvp.sequence, temp->index_qual[d1.seq].grid_qual[cnt].col_merge_name =
     nvp.merge_name,
     temp->index_qual[d1.seq].grid_qual[cnt].col_dta_mnemonic = dta.mnemonic, temp->index_qual[d1.seq
     ].grid_qual[cnt].col_dta_description = dta.description, temp->index_qual[d1.seq].grid_qual[cnt].
     grid_intersect_event_ref = nvp2.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind = evaluate(nvp.active_ind,0,"0",evaluate(
       nvp2.active_ind,0,"0",evaluate(temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind,"0","0",
        "1")))
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cntx)," records for power grid"))
   ENDIF
   SET cntx = 0
   SELECT INTO "nl:"
    temp_sk = temp->index_qual[d1.seq].section_inst_sk
    FROM name_value_prefs nvp,
     name_value_prefs nvp2,
     name_value_prefs nvp3,
     discrete_task_assay dta,
     discrete_task_assay dta2,
     (dummyt d1  WITH seq = value(temp->index_cnt))
    PLAN (d1
     WHERE d1.seq > 0
      AND (temp->index_qual[d1.seq].grid_flag=0)
      AND (temp->index_qual[d1.seq].input_type=19))
     JOIN (nvp
     WHERE nvp.pvc_name="discrete_task_assay2"
      AND (nvp.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp.parent_entity_name="DCP_INPUT_REF")
     JOIN (dta
     WHERE dta.task_assay_cd=nvp.merge_id)
     JOIN (nvp2
     WHERE (nvp2.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp2.parent_entity_name="DCP_INPUT_REF"
      AND nvp2.pvc_name="discrete_task_assay"
      AND nvp2.merge_id > 0)
     JOIN (dta2
     WHERE dta2.task_assay_cd=nvp2.merge_id)
     JOIN (nvp3
     WHERE (nvp3.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp3.parent_entity_name="DCP_INPUT_REF"
      AND nvp3.pvc_name="grid_event_cd")
    HEAD d1.seq
     cntx = (cntx+ 1), cnt = 0, temp->index_qual[d1.seq].grid_ind = 1,
     temp->index_qual[d1.seq].doc_component_sk = concat(trim(cnvtstring(temp->index_qual[d1.seq].
        input_ref_seq)),"~",trim(cnvtstring(nvp.sequence)),"~",trim(cnvtstring(nvp2.sequence)))
    DETAIL
     cnt = (cnt+ 1), temp->index_qual[d1.seq].grid_cnt = cnt, stat = alterlist(temp->index_qual[d1
      .seq].grid_qual,temp->index_qual[d1.seq].grid_cnt),
     temp->index_qual[d1.seq].grid_qual[cnt].grid_doc_sk = concat(trim(cnvtstring(nvp3.merge_id)),"~",
      trim(cnvtstring(dta.event_cd)),"~",trim(cnvtstring(nvp2.merge_id))), temp->index_qual[d1.seq].
     grid_qual[cnt].grid_input_sk = concat(trim(cnvtstring(temp->index_qual[d1.seq].form_inst_sk,16)),
      "~",trim(cnvtstring(temp->index_qual[d1.seq].section_inst_sk,16)),"~",trim(temp->index_qual[d1
       .seq].grid_qual[cnt].grid_doc_sk)), temp->index_qual[d1.seq].grid_qual[cnt].grid_name =
     uar_get_code_display(nvp3.merge_id),
     temp->index_qual[d1.seq].grid_qual[cnt].input_desc = temp->index_qual[d1.seq].input_desc, temp->
     index_qual[d1.seq].grid_qual[cnt].input_sequence = temp->index_qual[d1.seq].input_ref_seq, temp
     ->index_qual[d1.seq].grid_qual[cnt].input_type_flg = temp->index_qual[d1.seq].input_type,
     temp->index_qual[d1.seq].grid_qual[cnt].input_task_assay_sk = nvp.merge_id, temp->index_qual[d1
     .seq].grid_qual[cnt].input_display = dta.mnemonic, temp->index_qual[d1.seq].grid_qual[cnt].
     col_task_assay_sk = nvp.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].col_pvc_value = nvp.pvc_value, temp->index_qual[d1.seq].
     grid_qual[cnt].col_seq = nvp.sequence, temp->index_qual[d1.seq].grid_qual[cnt].col_merge_name =
     nvp.merge_name,
     temp->index_qual[d1.seq].grid_qual[cnt].col_dta_mnemonic = dta.mnemonic, temp->index_qual[d1.seq
     ].grid_qual[cnt].col_dta_description = dta.description, temp->index_qual[d1.seq].grid_qual[cnt].
     row_task_assay_sk = nvp2.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].row_pvc_value = nvp2.pvc_value, temp->index_qual[d1.seq]
     .grid_qual[cnt].row_seq = nvp2.sequence, temp->index_qual[d1.seq].grid_qual[cnt].row_merge_name
      = nvp2.merge_name,
     temp->index_qual[d1.seq].grid_qual[cnt].row_dta_mnemonic = dta2.mnemonic, temp->index_qual[d1
     .seq].grid_qual[cnt].row_dta_description = dta2.description, temp->index_qual[d1.seq].grid_qual[
     cnt].grid_intersect_event_ref = nvp3.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind = evaluate(nvp.active_ind,0,"0",evaluate(
       nvp2.active_ind,0,"0",evaluate(nvp3.active_ind,0,"0",evaluate(temp->index_qual[d1.seq].
         grid_qual[cnt].src_active_ind,"0","0","1"))))
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cntx)," records for ultra grid"))
   ENDIF
   SET cnt = 0
   SELECT INTO "nl:"
    FROM dcp_input_ref dir,
     name_value_prefs nvp,
     name_value_prefs nvp2,
     discrete_task_assay dta,
     (dummyt d1  WITH seq = value(templabel->section_cnt))
    PLAN (d1
     WHERE d1.seq > 0
      AND (temp->index_qual[d1.seq].grid_ind=0))
     JOIN (dir
     WHERE (dir.dcp_section_instance_id=templabel->section_qual[d1.seq].dcp_section_instance_id))
     JOIN (nvp
     WHERE cnvtlower(nvp.pvc_name) IN ("question_role", "reference_role")
      AND nvp.parent_entity_id=dir.dcp_input_ref_id
      AND nvp.parent_entity_name="DCP_INPUT_REF")
     JOIN (nvp2
     WHERE cnvtlower(nvp2.pvc_name)="caption"
      AND nvp2.parent_entity_id=dir.dcp_input_ref_id
      AND nvp2.parent_entity_name="DCP_INPUT_REF")
     JOIN (dta
     WHERE dta.mnemonic=nvp.pvc_value)
    DETAIL
     cnt = (cnt+ 1), label->cnt = cnt, stat = alterlist(label->qual,label->cnt),
     label->qual[cnt].dcp_section_instance_id = templabel->section_qual[d1.seq].
     dcp_section_instance_id, label->qual[cnt].dcp_input_ref_id = dir.dcp_input_ref_id, label->qual[
     cnt].input_description = dir.description,
     label->qual[cnt].input_sequence = dir.input_ref_seq, label->qual[cnt].input_type = dir
     .input_type, label->qual[cnt].merge_id = nvp2.merge_id,
     label->qual[cnt].pvc_value = nvp.pvc_value, label->qual[cnt].mnemonic = dta.mnemonic, label->
     qual[cnt].task_assay_cd = dta.task_assay_cd
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cnt)," records for label within DTA associated"))
   ENDIF
   FOR (i = 1 TO temp->index_cnt)
     IF ((temp->index_qual[i].grid_ind=0))
      FOR (j = 1 TO label->cnt)
        IF ((temp->index_qual[i].merge_id=label->qual[j].task_assay_cd))
         SET temp->index_qual[i].input_display = label->qual[j].pvc_value
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   SET keys_start = 1
   SET keys_end = minval(((keys_start+ keys_batch) - 1),temp->index_cnt)
   WHILE (keys_start <= keys_end)
     IF (debug="Y")
      CALL echo(concat("Looping from keys_start = ",build(keys_start)," to keys_end = ",build(
         keys_end)))
     ENDIF
     SET data->cnt = 0
     FOR (i = keys_start TO keys_end)
       IF ((temp->index_qual[i].grid_cnt=0))
        SET data->cnt = (data->cnt+ 1)
        SET stat = alterlist(data->qual,data->cnt)
        SET data->qual[data->cnt].form_inst_sk = temp->index_qual[i].form_inst_sk
        SET data->qual[data->cnt].section_inst_sk = temp->index_qual[i].section_inst_sk
        SET data->qual[data->cnt].doc_component_sk = temp->index_qual[i].doc_component_sk
        SET data->qual[data->cnt].doc_input_sk = temp->index_qual[i].doc_input_sk
        SET data->qual[data->cnt].form_ref_sk = temp->index_qual[i].form_ref_sk
        SET data->qual[data->cnt].form_description = temp->index_qual[i].form_description
        SET data->qual[data->cnt].form_definition = temp->index_qual[i].form_definition
        SET data->qual[data->cnt].form_beg_effective_dt_tm = temp->index_qual[i].
        form_beg_effective_dt_tm
        SET data->qual[data->cnt].form_end_effective_dt_tm = temp->index_qual[i].
        form_end_effective_dt_tm
        SET data->qual[data->cnt].section_ref_sk = temp->index_qual[i].section_ref_sk
        SET data->qual[data->cnt].section_description = temp->index_qual[i].section_description
        SET data->qual[data->cnt].section_definition = temp->index_qual[i].section_definition
        SET data->qual[data->cnt].section_sequence = temp->index_qual[i].section_sequence
        SET data->qual[data->cnt].section_beg_effective_dt_tm = temp->index_qual[i].
        section_beg_effective_dt_tm
        SET data->qual[data->cnt].section_end_effective_dt_tm = temp->index_qual[i].
        section_end_effective_dt_tm
        SET data->qual[data->cnt].input_desc = temp->index_qual[i].input_desc
        SET data->qual[data->cnt].input_sequence = temp->index_qual[i].input_sequence
        SET data->qual[data->cnt].input_type_flg = temp->index_qual[i].input_type_flg
        SET data->qual[data->cnt].input_task_assay_sk = temp->index_qual[i].input_task_assay_sk
        SET data->qual[data->cnt].input_display = temp->index_qual[i].input_display
        SET data->qual[data->cnt].grid_ind = temp->index_qual[i].grid_ind
        SET data->qual[data->cnt].grid_name = temp->index_qual[i].grid_name
        SET data->qual[data->cnt].grid_column_task_assay_sk = temp->index_qual[i].
        grid_column_task_assay_sk
        SET data->qual[data->cnt].grid_row_task_assay_sk = temp->index_qual[i].grid_row_task_assay_sk
        SET data->qual[data->cnt].grid_column_seq = temp->index_qual[i].grid_column_seq
        SET data->qual[data->cnt].grid_intersect_event_ref = temp->index_qual[i].
        grid_intersect_event_ref
        SET data->qual[data->cnt].src_active_ind = temp->index_qual[i].src_active_ind
       ELSE
        FOR (j = 1 TO temp->index_qual[i].grid_cnt)
          SET data->cnt = (data->cnt+ 1)
          SET stat = alterlist(data->qual,data->cnt)
          SET data->qual[data->cnt].form_inst_sk = temp->index_qual[i].form_inst_sk
          SET data->qual[data->cnt].section_inst_sk = temp->index_qual[i].section_inst_sk
          SET data->qual[data->cnt].doc_component_sk = temp->index_qual[i].grid_qual[j].grid_doc_sk
          SET data->qual[data->cnt].doc_input_sk = temp->index_qual[i].grid_qual[j].grid_input_sk
          SET data->qual[data->cnt].form_ref_sk = temp->index_qual[i].form_ref_sk
          SET data->qual[data->cnt].form_description = temp->index_qual[i].form_description
          SET data->qual[data->cnt].form_definition = temp->index_qual[i].form_definition
          SET data->qual[data->cnt].form_beg_effective_dt_tm = temp->index_qual[i].
          form_beg_effective_dt_tm
          SET data->qual[data->cnt].form_end_effective_dt_tm = temp->index_qual[i].
          form_end_effective_dt_tm
          SET data->qual[data->cnt].section_ref_sk = temp->index_qual[i].section_ref_sk
          SET data->qual[data->cnt].section_description = temp->index_qual[i].section_description
          SET data->qual[data->cnt].section_definition = temp->index_qual[i].section_definition
          SET data->qual[data->cnt].section_sequence = temp->index_qual[i].section_sequence
          SET data->qual[data->cnt].section_beg_effective_dt_tm = temp->index_qual[i].
          section_beg_effective_dt_tm
          SET data->qual[data->cnt].section_end_effective_dt_tm = temp->index_qual[i].
          section_end_effective_dt_tm
          SET data->qual[data->cnt].input_desc = temp->index_qual[i].grid_qual[j].input_desc
          SET data->qual[data->cnt].input_sequence = temp->index_qual[i].grid_qual[j].input_sequence
          SET data->qual[data->cnt].input_type_flg = temp->index_qual[i].grid_qual[j].input_type_flg
          SET data->qual[data->cnt].input_task_assay_sk = temp->index_qual[i].grid_qual[j].
          input_task_assay_sk
          SET data->qual[data->cnt].input_display = temp->index_qual[i].grid_qual[j].input_display
          SET data->qual[data->cnt].grid_ind = temp->index_qual[i].grid_ind
          SET data->qual[data->cnt].grid_name = temp->index_qual[i].grid_qual[j].grid_name
          SET data->qual[data->cnt].grid_column_task_assay_sk = temp->index_qual[i].grid_qual[j].
          col_task_assay_sk
          SET data->qual[data->cnt].grid_row_task_assay_sk = temp->index_qual[i].grid_qual[j].
          row_task_assay_sk
          SET data->qual[data->cnt].grid_column_seq = temp->index_qual[i].grid_qual[j].col_seq
          SET data->qual[data->cnt].grid_row_seq = temp->index_qual[i].grid_qual[j].row_seq
          SET data->qual[data->cnt].grid_intersect_event_ref = temp->index_qual[i].grid_qual[j].
          grid_intersect_event_ref
          SET data->qual[data->cnt].src_active_ind = temp->index_qual[i].grid_qual[j].src_active_ind
        ENDFOR
       ENDIF
     ENDFOR
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(data->cnt)),
       code_value_event_r cver
      PLAN (d1
       WHERE d1.seq > 0
        AND (data->qual[d1.seq].grid_ind=1))
       JOIN (cver
       WHERE (cver.parent_cd=data->qual[d1.seq].input_task_assay_sk)
        AND (cver.flex1_cd=data->qual[d1.seq].grid_row_task_assay_sk))
      DETAIL
       data->qual[d1.seq].grid_intersect_event_ref = cver.event_cd
      WITH nocounter
     ;end select
     SELECT INTO value(docinput_extractfile)
      FROM (dummyt d  WITH seq = value(data->cnt))
      PLAN (d)
      DETAIL
       col 0, health_system_source_id, v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].form_inst_sk,16),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].section_inst_sk,16),3)),
       v_bar,
       CALL print(trim(data->qual[d.seq].doc_component_sk,3)), v_bar,
       CALL print(trim(data->qual[d.seq].doc_input_sk,3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].form_ref_sk,16),3)),
       v_bar,
       CALL print(trim(data->qual[d.seq].form_description,3)), v_bar,
       CALL print(trim(data->qual[d.seq].form_definition,3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].section_ref_sk,16),3)),
       v_bar,
       CALL print(trim(data->qual[d.seq].section_description,3)), v_bar,
       CALL print(trim(data->qual[d.seq].section_definition,3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].section_sequence),3)),
       v_bar,
       CALL print(trim(data->qual[d.seq].input_desc,3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].input_sequence),3)), v_bar,
       CALL print(trim(evaluate(data->qual[d.seq].input_type_flg,0,blank_field,cnvtstring(data->qual[
          d.seq].input_type_flg)),3)),
       v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].input_task_assay_sk,16),3)), v_bar,
       CALL print(trim(data->qual[d.seq].input_display,3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_ind),3)),
       v_bar,
       CALL print(trim(data->qual[d.seq].grid_name,3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_column_task_assay_sk,16),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_row_task_assay_sk,16),3)),
       v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_column_seq),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_row_seq),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_intersect_event_ref,16),3)),
       v_bar, "3", v_bar,
       extract_dt_tm_fmt, v_bar,
       CALL print(trim(datetimezoneformat(evaluate(curutc,1,data->qual[d.seq].
          form_beg_effective_dt_tm,0,cnvtdatetimeutc(data->qual[d.seq].form_beg_effective_dt_tm,3)),
         utc_timezone_index,"MM/DD/YYYY HH:mm"))),
       v_bar,
       CALL print(build(curtimezonesys)), v_bar,
       CALL print(evaluate(datetimezoneformat(data->qual[d.seq].form_beg_effective_dt_tm,cnvtint(
          curtimezonesys),"HHmmsscc"),"00000000","0","        ","0",
        "1")), v_bar,
       CALL print(trim(datetimezoneformat(evaluate(curutc,1,data->qual[d.seq].
          form_end_effective_dt_tm,0,cnvtdatetimeutc(data->qual[d.seq].form_end_effective_dt_tm,3)),
         utc_timezone_index,"MM/DD/YYYY HH:mm"))),
       v_bar,
       CALL print(build(curtimezonesys)), v_bar,
       CALL print(evaluate(datetimezoneformat(data->qual[d.seq].form_end_effective_dt_tm,cnvtint(
          curtimezonesys),"HHmmsscc"),"00000000","0","        ","0",
        "1")), v_bar,
       CALL print(trim(datetimezoneformat(evaluate(curutc,1,data->qual[d.seq].
          section_beg_effective_dt_tm,0,cnvtdatetimeutc(data->qual[d.seq].section_beg_effective_dt_tm,
           3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
       v_bar,
       CALL print(build(curtimezonesys)), v_bar,
       CALL print(evaluate(datetimezoneformat(data->qual[d.seq].section_beg_effective_dt_tm,cnvtint(
          curtimezonesys),"HHmmsscc"),"00000000","0","        ","0",
        "1")), v_bar,
       CALL print(trim(datetimezoneformat(evaluate(curutc,1,data->qual[d.seq].
          section_end_effective_dt_tm,0,cnvtdatetimeutc(data->qual[d.seq].section_end_effective_dt_tm,
           3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
       v_bar,
       CALL print(build(curtimezonesys)), v_bar,
       CALL print(evaluate(datetimezoneformat(data->qual[d.seq].section_end_effective_dt_tm,cnvtint(
          curtimezonesys),"HHmmsscc"),"00000000","0","        ","0",
        "1")), v_bar,
       CALL print(trim(data->qual[d.seq].src_active_ind,3)),
       v_bar, row + 1, nlines = (nlines+ 1)
      WITH noheading, nocounter, format = lfstream,
       maxcol = 1999, maxrow = 1, append
     ;end select
     SET keys_start = (keys_end+ 1)
     SET keys_end = minval(((keys_start+ keys_batch) - 1),temp->index_cnt)
   ENDWHILE
   SET stat = alterlist(temp->index_qual,0)
   SET outer_keys_start = (outer_keys_end+ 1)
   SET outer_keys_end = minval(((outer_keys_start+ outer_keys_batch) - 1),key_cnt)
 ENDWHILE
#endprogram
 IF (nlines=0)
  SELECT INTO value(docinput_extractfile)
   FROM dummyt
   WHERE nlines > 0
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1
  ;end select
 ENDIF
 FREE RECORD temp
 FREE RECORD templabel
 FREE RECORD label
 FREE RECORD data
 CALL edwupdatescriptstatus("DOCINPUT",nlines,"13","13")
 CALL echo(build("DOCINPUT Count = ",nlines))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "013 04/28/09 RW012837"
 CALL edwupdatestats("DOCINPUT",script_start_dt_tm,error_ind)
 CALL printcoststatement(cost(3))
 CALL echo(build("DOCINPUT End :",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")))
 SET stats_count = size(rstats->qual,5)
 IF (stats_count > 0)
  SELECT INTO value(edw_stats_extractfile)
   FROM (dummyt d  WITH seq = value(stats_count))
   PLAN (d)
   DETAIL
    line = build(health_system_source_id,v_bar,trim(rstats->qual[d.seq].file_type),v_bar,rstats->
     qual[d.seq].record_count,
     v_bar,act_from_dt_tm_fmt,v_bar,act_to_dt_tm_fmt,v_bar,
     rstats->qual[d.seq].get_script_version,v_bar,rstats->qual[d.seq].create_script_version,v_bar,
     evaluate(historic_ind,"Y","1","N","0"),
     v_bar,extract_dt_tm_fmt,v_bar,rstats->qual[d.seq].script_start_dt_tm,v_bar,
     rstats->qual[d.seq].script_end_dt_tm,v_bar,cnvtstring(rstats->qual[d.seq].error_ind),v_bar), col
     0, line,
    row + 1
   WITH check, noheading, nocounter,
    format = lfstream, maxcol = 1999, maxrow = 1
  ;end select
 ENDIF
 DECLARE docinput_textfile = vc WITH protect, noconstant(concat(file_dir,"/docinput_conv.txt"))
 DECLARE stats_textfile = vc WITH protect, noconstant(concat(file_dir,"/docinput_conv_stats.txt"))
 SELECT INTO value(docinput_textfile)
  FROM dummyt d
  FOOT REPORT
   col 0,
   CALL print(build("dw_",health_system_source_id,"_","docinput_",trim(file_suffix,3),
    ".dat"))
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1
 ;end select
 SELECT INTO value(stats_textfile)
  FROM dummyt d
  FOOT REPORT
   col 0,
   CALL print(build("edw_",health_system_source_id,"_","stats_",trim(file_suffix,3),
    ".dat"))
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1
 ;end select
 SUBROUTINE printdebugstatement(debug_message)
   IF (debug="Y")
    CALL echo(debug_message)
   ENDIF
 END ;Subroutine
 SUBROUTINE printcoststatement(cost_message)
   IF (printcost="Y")
    CALL echo(cost_message)
   ENDIF
 END ;Subroutine
#end_program
 SET script_version = "001 10/26/09 BZ016640"
END GO
