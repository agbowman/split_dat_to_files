CREATE PROGRAM bed_imp_prsnl:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD prsnl_request(
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
 )
 FREE SET prsnl_reply
 RECORD prsnl_reply(
   1 person_list[*]
     2 person_id = f8
     2 status_msg = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "bed_imp_prsnl.log"
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "Personnel Import Log"
  DETAIL
   row + 2, col 2, " "
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET first_prsnl = 0
 SET dea_nbr = fillstring(200," ")
 SET upin = fillstring(200," ")
 SET comm_prov = fillstring(200," ")
 SET male_code_value = 0.0
 SET female_code_value = 0.0
 SET unknown_code_value = 0.0
 SET position_code_value = 0.0
 SET position_disp = fillstring(40," ")
 SET position_mean = fillstring(12," ")
 SET phone_type_code_value = 0.0
 SET phone_type_disp = fillstring(40," ")
 SET phone_type_mean = fillstring(12," ")
 SET last_phone_type = fillstring(40," ")
 SET phone_format_code_value = 0.0
 SET phone_format_disp = fillstring(40," ")
 SET phone_format_mean = fillstring(12," ")
 SET last_phone_format = fillstring(40," ")
 SET address_type_code_value = 0.0
 SET address_type_disp = fillstring(40," ")
 SET addresss_type_mean = fillstring(12," ")
 SET last_address_type = fillstring(40," ")
 SET state_code_value = 0.0
 SET state_disp = fillstring(40," ")
 SET last_state = fillstring(40," ")
 SET country_code_value = 0.0
 SET country_disp = fillstring(40," ")
 SET country_mean = fillstring(12," ")
 SET last_country = fillstring(40," ")
 SET county_code_value = 0.0
 SET county_disp = fillstring(40," ")
 SET county_mean = fillstring(12," ")
 SET last_county = fillstring(40," ")
 SET org_alias_pool_code_value = 0.0
 SET org_alias_pool_disp = fillstring(40," ")
 SET org_alias_pool_mean = fillstring(12," ")
 SET last_org_alias_pool = fillstring(40," ")
 SET org_set_id = 0.0
 SET org_set_name = fillstring(40," ")
 SET last_org_group = fillstring(40," ")
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=57
    AND cv.active_ind=1
    AND ((cv.cdf_meaning="FEMALE") OR (((cv.cdf_meaning="MALE") OR (cv.cdf_meaning="UNKNOWN")) )) )
  ORDER BY cv.code_value
  DETAIL
   CASE (cv.cdf_meaning)
    OF "FEMALE":
     female_code_value = cv.code_value
    OF "MALE":
     male_code_value = cv.code_value
    OF "UNKNOWN":
     unknown_code_value = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET ext_alias_pool_code_value = 0.0
 SET ext_alias_pool_disp = fillstring(40," ")
 SET ext_alias_pool_mean = fillstring(12," ")
 SET dea_alias_pool_code_value = 0.0
 SET dea_alias_pool_disp = fillstring(40," ")
 SET dea_alias_pool_mean = fillstring(12," ")
 SET upin_alias_pool_code_value = 0.0
 SET upin_alias_pool_disp = fillstring(40," ")
 SET upin_alias_pool_mean = fillstring(12," ")
 SET ssn_alias_pool_code_value = 0.0
 SET ssn_alias_pool_disp = fillstring(40," ")
 SET ssn_alias_pool_mean = fillstring(12," ")
 SET docc_alias_pool_code_value = 0.0
 SET docc_alias_pool_disp = fillstring(40," ")
 SET docc_alias_pool_mean = fillstring(12," ")
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=263
    AND cv.active_ind=1
    AND ((cv.display_key="PERSONNELEXTERNALID") OR (((cv.display_key="DOCDEA") OR (((cv.display_key=
   "DOCUPIN") OR (((cv.display_key="GMCDOCTORNUMBER") OR (cv.display_key="SSN")) )) )) )) )
  DETAIL
   CASE (cv.display_key)
    OF "PERSONNELEXTERNALID":
     ext_alias_pool_code_value = cv.code_value,ext_alias_pool_disp = cv.display,ext_alias_pool_mean
      = cv.cdf_meaning
    OF "DOCDEA":
     dea_alias_pool_code_value = cv.code_value,dea_alias_pool_disp = cv.display,dea_alias_pool_mean
      = cv.cdf_meaning
    OF "DOCUPIN":
     upin_alias_pool_code_value = cv.code_value,upin_alias_pool_disp = cv.display,
     upin_alias_pool_mean = cv.cdf_meaning
    OF "GMCDOCTORNUMBER":
     docc_alias_pool_code_value = cv.code_value,docc_alias_pool_disp = cv.display,
     docc_alias_pool_mean = cv.cdf_meaning
    OF "SSN":
     ssn_alias_pool_code_value = cv.code_value,ssn_alias_pool_disp = cv.display,ssn_alias_pool_mean
      = cv.cdf_meaning
   ENDCASE
  WITH nocounter
 ;end select
 SET ext_alias_type_code_value = 0.0
 SET ext_alias_type_disp = fillstring(40," ")
 SET ext_alias_type_mean = fillstring(12," ")
 SET docc_alias_type_code_value = 0.0
 SET docc_alias_type_disp = fillstring(40," ")
 SET docc_alias_type_mean = fillstring(12," ")
 SET dea_alias_type_code_value = 0.0
 SET dea_alias_type_disp = fillstring(40," ")
 SET dea_alias_type_mean = fillstring(12," ")
 SET upin_alias_type_code_value = 0.0
 SET upin_alias_type_disp = fillstring(40," ")
 SET upin_alias_type_mean = fillstring(12," ")
 SET doc_alias_type_code_value = 0.0
 SET doc_alias_type_disp = fillstring(40," ")
 SET doc_alias_type_mean = fillstring(12," ")
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=320
    AND cv.active_ind=1
    AND ((cv.cdf_meaning="EXTERNALID") OR (((cv.cdf_meaning="DOCCNBR") OR (((cv.cdf_meaning="DOCDEA")
    OR (((cv.cdf_meaning="DOCUPIN") OR (cv.cdf_meaning="DOCNBR")) )) )) )) )
  DETAIL
   CASE (cv.cdf_meaning)
    OF "EXTERNALID":
     ext_alias_type_code_value = cv.code_value,ext_alias_type_mean = cv.cdf_meaning,
     ext_alias_type_disp = cv.display
    OF "DOCCNBR":
     docc_alias_type_code_value = cv.code_value,docc_alias_type_mean = cv.cdf_meaning,
     docc_alias_type_disp = cv.display
    OF "DOCDEA":
     dea_alias_type_code_value = cv.code_value,dea_alias_type_mean = cv.cdf_meaning,
     dea_alias_type_disp = cv.display
    OF "DOCUPIN":
     upin_alias_type_code_value = cv.code_value,upin_alias_type_mean = cv.cdf_meaning,
     upin_alias_type_disp = cv.display
    OF "DOCNBR":
     doc_alias_type_code_value = cv.code_value,doc_alias_type_mean = cv.cdf_meaning,
     doc_alias_type_disp = cv.display
   ENDCASE
  WITH nocounter
 ;end select
 SET ssn_alias_type_code_value = 0.0
 SET ssn_alias_type_disp = fillstring(40," ")
 SET ssn_alias_type_mean = fillstring(12," ")
 SET int_alias_type_code_value = 0.0
 SET int_alias_type_disp = fillstring(40," ")
 SET int_alias_type_mean = fillstring(12," ")
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4
    AND cv.active_ind=1
    AND ((cv.cdf_meaning="SSN") OR (cv.cdf_meaning="INTPERSID")) )
  DETAIL
   CASE (cv.cdf_meaning)
    OF "SSN":
     ssn_alias_type_code_value = cv.code_value,ssn_alias_type_mean = cv.cdf_meaning,
     ssn_alias_type_disp = cv.display
    OF "INTPERSID":
     int_alias_type_code_value = cv.code_value,int_alias_type_mean = cv.cdf_meaning,
     int_alias_type_disp = cv.display
   ENDCASE
  WITH nocounter
 ;end select
 SET sec_type_code_value = 0.0
 SET sec_type_disp = fillstring(40," ")
 SET sec_type_mean = fillstring(12," ")
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=28881
    AND cv.active_ind=1
    AND cv.cdf_meaning="SECURITY")
  DETAIL
   sec_type_code_value = cv.code_value, sec_type_mean = cv.cdf_meaning, sec_type_disp = cv.display
  WITH nocounter
 ;end select
 SET numrows = size(requestin->list_0,5)
 SET last_name = fillstring(200," ")
 SET first_name = fillstring(200," ")
 SET middle_name = fillstring(200," ")
 SET first_time = "Y"
 SET stat = alterlist(prsnl_request->person_list,300)
 SET pcnt = 0
 SET ptot = 0
 SET phone_cnt = 0
 SET phone_total = 0
 SET add_cnt = 0
 SET add_total = 0
 SET alias_cnt = 0
 SET alias_total = 0
 SET org_grp_cnt = 0
 SET org_grp_total = 0
 FOR (x = 1 TO numrows)
   IF ((((((requestin->list_0[x].last_name=" *")) OR ((requestin->list_0[x].last_name=null)))
    AND (((requestin->list_0[x].first_name=" *")) OR ((requestin->list_0[x].first_name=null)))
    AND (((requestin->list_0[x].middle_name=" *")) OR ((requestin->list_0[x].middle_name=null))) )
    OR (last_name=cnvtupper(requestin->list_0[x].last_name)
    AND first_name=cnvtupper(requestin->list_0[x].first_name)
    AND middle_name=cnvtupper(requestin->list_0[x].middle_name))) )
    SET first_time = "N"
   ELSE
    IF (ptot > 0
     AND phone_total > 0)
     SET stat = alterlist(prsnl_request->person_list[ptot].phone_list,phone_total)
    ENDIF
    IF (ptot > 0
     AND add_total > 0)
     SET stat = alterlist(prsnl_request->person_list[ptot].address_list,add_total)
    ENDIF
    IF (ptot > 0
     AND alias_total > 0)
     SET stat = alterlist(prsnl_request->person_list[ptot].alias_list,alias_total)
    ENDIF
    IF (ptot > 0
     AND org_grp_total > 0)
     SET stat = alterlist(prsnl_request->person_list[ptot].org_group_list,org_grp_total)
    ENDIF
    SET pcnt = (pcnt+ 1)
    SET ptot = (ptot+ 1)
    IF (pcnt > 300)
     SET stat = alterlist(prsnl_request->person_list,(ptot+ 300))
     SET pcnt = 1
    ENDIF
    SET prsnl_request->person_list[ptot].action_flag = 1
    SET prsnl_request->person_list[ptot].person_id = 0
    SET last_name = cnvtupper(requestin->list_0[x].last_name)
    SET first_name = cnvtupper(requestin->list_0[x].first_name)
    SET middle_name = cnvtupper(requestin->list_0[x].middle_name)
    SET prsnl_request->person_list[ptot].submit_by = validate(requestin->list_0[x].submit_by," ")
    SET sch_ind = validate(requestin->list_0[x].sch_ind," ")
    IF (((sch_ind="Y") OR (((sch_ind="y") OR (sch_ind="1")) )) )
     SET prsnl_request->person_list[ptot].sch_ind = 1
    ELSE
     SET prsnl_request->person_list[ptot].sch_ind = 0
    ENDIF
    SET prsnl_request->person_list[ptot].name_title = validate(requestin->list_0[x].title," ")
    SET prsnl_request->person_list[ptot].name_first = requestin->list_0[x].first_name
    SET prsnl_request->person_list[ptot].name_middle = requestin->list_0[x].middle_name
    SET prsnl_request->person_list[ptot].name_last = requestin->list_0[x].last_name
    SET prsnl_request->person_list[ptot].name_suffix = requestin->list_0[x].suffix
    SET prsnl_request->person_list[ptot].name_full_formatted = uar_i18nbuildfullformatname(nullterm(
      trim(requestin->list_0[x].first_name,3)),nullterm(trim(requestin->list_0[x].last_name,3)),
     nullterm(trim(requestin->list_0[x].middle_name,3)),"",nullterm(trim(validate(requestin->list_0[x
        ].title," "),3)),
     "",nullterm(trim(requestin->list_0[x].suffix,3)),"","")
    CALL logprsnl(ptot)
    IF (((first_name=" ") OR (first_name=null)) )
     SET msg1 = fillstring(110," ")
     SET msg1 = concat("First Name must be defined.")
     CALL logrequest(msg1)
     SET error_flag = "Y"
    ENDIF
    IF (((last_name=" ") OR (last_name=null)) )
     SET msg1 = fillstring(110," ")
     SET msg1 = concat("Last Name must be defined.")
     CALL logrequest(msg1)
     SET error_flag = "Y"
    ENDIF
    SET prsnl_request->person_list[ptot].prsnl_name_first = requestin->list_0[x].first_name
    SET prsnl_request->person_list[ptot].prsnl_name_last = requestin->list_0[x].last_name
    SET prsnl_request->person_list[ptot].prsnl_name_full_formatted = prsnl_request->person_list[ptot]
    .name_full_formatted
    SET prsnl_request->person_list[ptot].username = requestin->list_0[x].username
    SET prsnl_request->person_list[ptot].email = " "
    IF ((requestin->list_0[x].birthdate > " "))
     SET temp_dt = cnvtdate2(requestin->list_0[x].birthdate,"MM/DD/YYYY")
     SET prsnl_request->person_list[ptot].birth_dt_tm = cnvtdatetime(temp_dt,0)
    ENDIF
    IF (cnvtupper(requestin->list_0[x].sex)="F*")
     SET prsnl_request->person_list[ptot].sex_code_value = female_code_value
     SET prsnl_request->person_list[ptot].sex_disp = "Female"
     SET prsnl_request->person_list[ptot].sex_mean = "FEMALE"
    ELSEIF (cnvtupper(requestin->list_0[x].sex)="M*")
     SET prsnl_request->person_list[ptot].sex_code_value = male_code_value
     SET prsnl_request->person_list[ptot].sex_disp = "Male"
     SET prsnl_request->person_list[ptot].sex_mean = "MALE"
    ELSE
     SET prsnl_request->person_list[ptot].sex_code_value = unknown_code_value
     SET prsnl_request->person_list[ptot].sex_disp = "Unknown"
     SET prsnl_request->person_list[ptot].sex_mean = "UNKNOWN"
    ENDIF
    SET phys_ind = validate(requestin->list_0[x].physician_ind," ")
    IF (((phys_ind="Y*") OR (((phys_ind="y*") OR (phys_ind="1")) )) )
     SET prsnl_request->person_list[ptot].physician_ind = 1
    ELSE
     SET prsnl_request->person_list[ptot].physician_ind = 0
    ENDIF
    SET position = validate(requestin->list_0[x].position," ")
    IF (position > " ")
     SET position_code_value = 0.0
     SET position_disp = fillstring(40," ")
     SET position_mean = fillstring(12," ")
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.active_ind=1
       AND cv.code_set=88
       AND cv.display_key=cnvtupper(cnvtalphanum(requestin->list_0[x].position))
      DETAIL
       position_code_value = cv.code_value, position_disp = cv.display, position_mean = cv
       .cdf_meaning
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET msg1 = fillstring(110," ")
      SET msg1 = concat(build("Position:  ",requestin->list_0[x].position,
        " is not defined on codeset 88."))
      CALL logrequest(msg1)
      SET error_flag = "Y"
     ENDIF
    ENDIF
    SET prsnl_request->person_list[ptot].position_code_value = position_code_value
    SET prsnl_request->person_list[ptot].position_disp = position_disp
    SET prsnl_request->person_list[ptot].position_mean = position_mean
    SET prsnl_request->person_list[ptot].primary_work_loc_code_value = 0.0
    SET prsnl_request->person_list[ptot].primary_work_loc_disp = " "
    SET prsnl_request->person_list[ptot].primary_work_loc_mean = " "
    SET phone_cnt = 0
    SET phone_total = 0
    SET add_cnt = 0
    SET add_total = 0
    SET org_grp_cnt = 0
    SET org_grp_total = 0
    SET stat = alterlist(prsnl_request->person_list[ptot].alias_list,5)
    SET alias_cnt = 0
    SET alias_total = 0
    SET external_id = validate(requestin->list_0[x].external_id," ")
    IF (external_id > " ")
     SELECT INTO "NL:"
      FROM prsnl_alias pa
      WHERE pa.alias_pool_cd=ext_alias_pool_code_value
       AND (pa.alias=requestin->list_0[x].external_id)
       AND pa.prsnl_alias_type_cd=ext_alias_type_code_value
       AND pa.active_ind=1
      DETAIL
       y = 0
      WITH nocounter
     ;end select
     IF (curqual=1)
      SET msg1 = fillstring(110," ")
      SET msg1 = concat("External ID: ",requestin->list_0[x].external_id,
       " already defined on prsnl_alias table.")
      CALL logrequest(msg1)
      SET error_flag = "Y"
     ENDIF
     SET alias_cnt = (alias_cnt+ 1)
     SET alias_total = (alias_total+ 1)
     SET prsnl_request->person_list[ptot].alias_list[alias_total].person_prsnl_flag = 1
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_id = 0
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_code_value =
     ext_alias_type_code_value
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_disp =
     ext_alias_type_disp
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_mean =
     ext_alias_type_mean
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_code_value =
     ext_alias_pool_code_value
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_disp =
     ext_alias_pool_disp
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_mean =
     ext_alias_pool_mean
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias = external_id
     SET prsnl_request->person_list[ptot].alias_list[alias_total].active_ind = 1
     SET prsnl_request->person_list[ptot].alias_list[alias_total].action_flag = 1
    ENDIF
    SET dea_nbr = validate(requestin->list_0[x].dea_nbr," ")
    IF (dea_nbr > "   ")
     SET alias_cnt = (alias_cnt+ 1)
     SET alias_total = (alias_total+ 1)
     SET prsnl_request->person_list[ptot].alias_list[alias_total].person_prsnl_flag = 1
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_id = 0
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_code_value =
     dea_alias_type_code_value
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_disp =
     dea_alias_type_disp
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_mean =
     dea_alias_type_mean
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_code_value =
     dea_alias_pool_code_value
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_disp =
     dea_alias_pool_disp
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_mean =
     dea_alias_pool_mean
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias = dea_nbr
     SET prsnl_request->person_list[ptot].alias_list[alias_total].active_ind = 1
     SET prsnl_request->person_list[ptot].alias_list[alias_total].action_flag = 1
    ENDIF
    SET upin = validate(requestin->list_0[x].upin," ")
    IF (upin > "   ")
     SET alias_cnt = (alias_cnt+ 1)
     SET alias_total = (alias_total+ 1)
     SET prsnl_request->person_list[ptot].alias_list[alias_total].person_prsnl_flag = 1
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_id = 0
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_code_value =
     upin_alias_type_code_value
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_disp =
     upin_alias_type_disp
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_mean =
     upin_alias_type_mean
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_code_value =
     upin_alias_pool_code_value
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_disp =
     upin_alias_pool_disp
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_mean =
     upin_alias_pool_mean
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias = upin
     SET prsnl_request->person_list[ptot].alias_list[alias_total].active_ind = 1
     SET prsnl_request->person_list[ptot].alias_list[alias_total].action_flag = 1
    ENDIF
    SET comm_prov = validate(requestin->list_0[x].comm_prov_nbr," ")
    IF (comm_prov > "   ")
     SET alias_cnt = (alias_cnt+ 1)
     SET alias_total = (alias_total+ 1)
     SET prsnl_request->person_list[ptot].alias_list[alias_total].person_prsnl_flag = 1
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_id = 0
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_code_value =
     docc_alias_type_code_value
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_disp =
     docc_alias_type_disp
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_mean =
     docc_alias_type_mean
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_code_value =
     docc_alias_pool_code_value
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_disp =
     docc_alias_pool_disp
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_mean =
     docc_alias_pool_mean
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias = comm_prov
     SET prsnl_request->person_list[ptot].alias_list[alias_total].active_ind = 1
     SET prsnl_request->person_list[ptot].alias_list[alias_total].action_flag = 1
    ENDIF
    IF ((requestin->list_0[x].ssn > "   "))
     SET alias_cnt = (alias_cnt+ 1)
     SET alias_total = (alias_total+ 1)
     SET prsnl_request->person_list[ptot].alias_list[alias_total].person_prsnl_flag = 2
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_id = 0
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_code_value =
     ssn_alias_type_code_value
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_disp =
     ssn_alias_type_disp
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_mean =
     ssn_alias_type_mean
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_code_value =
     ssn_alias_pool_code_value
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_disp =
     ssn_alias_pool_disp
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_mean =
     ssn_alias_pool_mean
     SET prsnl_request->person_list[ptot].alias_list[alias_total].alias = requestin->list_0[x].ssn
     SET prsnl_request->person_list[ptot].alias_list[alias_total].active_ind = 1
     SET prsnl_request->person_list[ptot].alias_list[alias_total].action_flag = 1
    ENDIF
   ENDIF
   SET org_id = validate(requestin->list_0[x].org_id," ")
   SET org_alias_pool = validate(requestin->list_0[x].org_alias_pool," ")
   IF (org_id > "   "
    AND org_alias_pool > "  ")
    IF (((last_org_alias_pool != cnvtupper(requestin->list_0[x].org_alias_pool)) OR (
    last_org_alias_pool="  ")) )
     SET org_alias_pool_code_value = 0.0
     SET org_alias_pool_disp = fillstring(40," ")
     SET org_alias_pool_mean = fillstring(12," ")
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=263
        AND cv.active_ind=1
        AND cv.display_key=cnvtupper(cnvtalphanum(org_alias_pool)))
      DETAIL
       last_org_alias_pool = cnvtupper(org_alias_pool), org_alias_pool_code_value = cv.code_value,
       org_alias_pool_disp = cv.display,
       org_alias_pool_mean = cv.cdf_meaning
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET msg1 = fillstring(110," ")
      SET msg1 = concat(build("Organization Alias Pool: ",org_alias_pool,
        " is not defined on codeset 263."))
      CALL logrequest(msg1)
      SET error_flag = "Y"
     ENDIF
    ENDIF
    SET alias_cnt = (alias_cnt+ 1)
    SET alias_total = (alias_total+ 1)
    IF (alias_cnt > 5)
     SET stat = alterlist(prsnl_request->person_list[ptot].alias_list,(alias_total+ 5))
     SET org_cnt = 0
    ENDIF
    SET prsnl_request->person_list[ptot].alias_list[alias_total].person_prsnl_flag = 1
    SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_id = 0
    SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_code_value =
    doc_alias_type_code_value
    SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_disp =
    doc_alias_type_disp
    SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_type_mean =
    doc_alias_type_mean
    SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_code_value =
    org_alias_pool_code_value
    SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_disp =
    org_alias_pool_disp
    SET prsnl_request->person_list[ptot].alias_list[alias_total].alias_pool_mean =
    org_alias_pool_mean
    SET prsnl_request->person_list[ptot].alias_list[alias_total].alias = org_id
    SET prsnl_request->person_list[ptot].alias_list[alias_total].active_ind = 1
    SET prsnl_request->person_list[ptot].alias_list[alias_total].action_flag = 1
   ENDIF
   SET org_group = validate(requestin->list_0[x].org_group," ")
   IF (org_group > "  ")
    IF (((last_org_group != cnvtupper(org_group)) OR (last_org_group="  ")) )
     SET org_set_id = 0.0
     SET org_set_name = fillstring(40," ")
     SELECT INTO "nl:"
      FROM org_set os
      PLAN (os
       WHERE cnvtupper(os.name)=cnvtupper(org_group))
      DETAIL
       last_org_group = cnvtupper(org_group), org_set_id = os.org_set_id, org_set_name = os.name
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET msg1 = fillstring(110," ")
      SET msg1 = concat(build("Organization Group: ",org_group," is not defined on table org_set."))
      CALL logrequest(msg1)
      SET error_flag = "Y"
     ENDIF
    ENDIF
    IF (org_grp_cnt=0)
     SET stat = alterlist(prsnl_request->person_list[ptot].org_group_list,5)
    ENDIF
    SET org_grp_cnt = (org_grp_cnt+ 1)
    SET org_grp_total = (org_grp_total+ 1)
    IF (org_grp_cnt > 5)
     SET stat = alterlist(prsnl_request->person_list[ptot].org_group_list,(org_grp_total+ 5))
     SET org_grp_cnt = 0
    ENDIF
    SET prsnl_request->person_list[ptot].org_group_list[org_grp_total].org_set_prsnl_r_id = 0
    SET prsnl_request->person_list[ptot].org_group_list[org_grp_total].org_set_type_code_value =
    sec_type_code_value
    SET prsnl_request->person_list[ptot].org_group_list[org_grp_total].org_set_type_disp =
    sec_type_disp
    SET prsnl_request->person_list[ptot].org_group_list[org_grp_total].org_set_type_mean =
    sec_type_mean
    SET prsnl_request->person_list[ptot].org_group_list[org_grp_total].org_set_id = org_set_id
    SET prsnl_request->person_list[ptot].org_group_list[org_grp_total].org_set_name = org_set_name
    SET prsnl_request->person_list[ptot].org_group_list[org_grp_total].action_flag = 1
   ENDIF
   SET phone_type = validate(requestin->list_0[x].phone_type," ")
   IF (phone_type > "  ")
    IF (phone_cnt=0)
     SET stat = alterlist(prsnl_request->person_list[ptot].phone_list,5)
    ENDIF
    SET phone_cnt = (phone_cnt+ 1)
    SET phone_total = (phone_total+ 1)
    IF (phone_cnt > 5)
     SET stat = alterlist(prsnl_request->person_list[ptot].phone_list,(phone_total+ 5))
     SET phone_cnt = 0
    ENDIF
    SET prsnl_request->person_list[ptot].phone_list[phone_total].phone_id = 0
    IF (((last_phone_type != cnvtupper(requestin->list_0[x].phone_type)) OR (last_phone_type="  ")) )
     SET phone_type_code_value = 0.0
     SET phone_type_disp = fillstring(40," ")
     SET phone_type_mean = fillstring(12," ")
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.active_ind=1
       AND cv.code_set=43
       AND cv.display_key=cnvtupper(cnvtalphanum(requestin->list_0[x].phone_type))
      DETAIL
       last_phone_type = cnvtupper(requestin->list_0[x].phone_type), phone_type_code_value = cv
       .code_value, phone_type_disp = cv.display,
       phone_type_mean = cv.cdf_meaning
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET msg1 = fillstring(110," ")
      SET msg1 = concat(build("Phone Type: ",requestin->list_0[x].phone_type,
        " is not defined on codeset 43."))
      CALL logrequest(msg1)
      SET error_flag = "Y"
     ENDIF
    ENDIF
    SET prsnl_request->person_list[ptot].phone_list[phone_total].phone_type_code_value =
    phone_type_code_value
    SET prsnl_request->person_list[ptot].phone_list[phone_total].phone_type_disp = phone_type_disp
    SET prsnl_request->person_list[ptot].phone_list[phone_total].phone_type_mean = phone_type_mean
    IF ((((requestin->list_0[x].phone_format="  *")) OR ((requestin->list_0[x].phone_format=null))) )
     SET requestin->list_0[x].phone_format = "US"
    ENDIF
    IF (((last_phone_format != cnvtupper(requestin->list_0[x].phone_format)) OR (last_phone_format=
    "  ")) )
     SET phone_format_code_value = 0.0
     SET phone_format_disp = fillstring(40," ")
     SET phone_format_mean = fillstring(12," ")
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.active_ind=1
       AND cv.code_set=281
       AND cv.cdf_meaning=cnvtupper(cnvtalphanum(requestin->list_0[x].phone_format))
      DETAIL
       last_phone_format = cnvtupper(requestin->list_0[x].phone_format), phone_format_code_value = cv
       .code_value, phone_format_disp = cv.display,
       phone_format_mean = cv.cdf_meaning
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET msg1 = fillstring(110," ")
      SET msg1 = concat(build("Phone Format: ",requestin->list_0[x].phone_format,
        " is not defined on codeset 281."))
      CALL logrequest(msg1)
      SET error_flag = "Y"
     ENDIF
    ENDIF
    SET prsnl_request->person_list[ptot].phone_list[phone_total].phone_format_code_value =
    phone_format_code_value
    SET prsnl_request->person_list[ptot].phone_list[phone_total].phone_format_disp =
    phone_format_disp
    SET prsnl_request->person_list[ptot].phone_list[phone_total].phone_format_mean =
    phone_format_mean
    SET prsnl_request->person_list[ptot].phone_list[phone_total].sequence = phone_total
    SET prsnl_request->person_list[ptot].phone_list[phone_total].phone_num = requestin->list_0[x].
    phone_nbr
    SET prsnl_request->person_list[ptot].phone_list[phone_total].phone_formatted = " "
    SET prsnl_request->person_list[ptot].phone_list[phone_total].description = requestin->list_0[x].
    phone_desc
    SET prsnl_request->person_list[ptot].phone_list[phone_total].contact = requestin->list_0[x].
    phone_contact
    SET prsnl_request->person_list[ptot].phone_list[phone_total].call_instruction = requestin->
    list_0[x].phone_inst
    SET prsnl_request->person_list[ptot].phone_list[phone_total].extension = requestin->list_0[x].
    phone_ext
    SET prsnl_request->person_list[ptot].phone_list[phone_total].paging_code = " "
    SET prsnl_request->person_list[ptot].phone_list[phone_total].action_flag = 1
   ENDIF
   SET address_type = validate(requestin->list_0[x].address_type," ")
   IF (address_type > "   ")
    IF (add_cnt=0)
     SET stat = alterlist(prsnl_request->person_list[ptot].address_list,5)
    ENDIF
    SET add_cnt = (add_cnt+ 1)
    SET add_total = (add_total+ 1)
    IF (add_cnt > 5)
     SET stat = alterlist(prsnl_request->person_list[ptot].address_list,(add_total+ 5))
     SET add_cnt = 0
    ENDIF
    SET prsnl_request->person_list[ptot].address_list[add_total].address_id = 0
    IF (((last_address_type != cnvtupper(requestin->list_0[x].address_type)) OR (last_address_type=
    "  ")) )
     SET address_type_code_value = 0.0
     SET address_type_disp = fillstring(40," ")
     SET address_type_mean = fillstring(12," ")
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.active_ind=1
       AND cv.code_set=212
       AND cv.display_key=cnvtupper(cnvtalphanum(requestin->list_0[x].address_type))
      DETAIL
       last_address_type = cnvtupper(requestin->list_0[x].address_type), address_type_code_value = cv
       .code_value, address_type_disp = cv.display,
       address_type_mean = cv.cdf_meaning
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET msg1 = fillstring(110," ")
      SET msg1 = concat(build("Address Type: ",requestin->list_0[x].address_type,
        " is not defined on codeset 212."))
      CALL logrequest(msg1)
      SET error_flag = "Y"
     ENDIF
    ENDIF
    SET prsnl_request->person_list[ptot].address_list[add_total].address_type_code_value =
    address_type_code_value
    SET prsnl_request->person_list[ptot].address_list[add_total].address_type_disp =
    address_type_disp
    SET prsnl_request->person_list[ptot].address_list[add_total].address_type_mean =
    address_type_mean
    SET prsnl_request->person_list[ptot].address_list[add_total].address_type_seq = add_total
    SET prsnl_request->person_list[ptot].address_list[add_total].street_addr = requestin->list_0[x].
    street1
    SET prsnl_request->person_list[ptot].address_list[add_total].street_addr2 = requestin->list_0[x].
    street2
    SET prsnl_request->person_list[ptot].address_list[add_total].street_addr3 = requestin->list_0[x].
    street3
    SET prsnl_request->person_list[ptot].address_list[add_total].street_addr4 = requestin->list_0[x].
    street4
    SET prsnl_request->person_list[ptot].address_list[add_total].city = requestin->list_0[x].city
    IF ((requestin->list_0[x].state > "  "))
     IF (last_state != cnvtupper(requestin->list_0[x].state))
      SET state_code_value = 0.0
      SET state_disp = fillstring(40," ")
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.active_ind=1
        AND cv.code_set=62
        AND cv.display_key=cnvtupper(requestin->list_0[x].state)
       DETAIL
        last_state = cnvtupper(requestin->list_0[x].state), state_code_value = cv.code_value,
        state_disp = cv.display
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET msg1 = fillstring(110," ")
       SET msg1 = concat(build("State: ",requestin->list_0[x].state," is not defined on codeset 62.")
        )
       CALL logrequest(msg1)
       SET error_flag = "Y"
      ENDIF
     ENDIF
     SET prsnl_request->person_list[ptot].address_list[add_total].state = requestin->list_0[x].state
     SET prsnl_request->person_list[ptot].address_list[add_total].state_code_value = state_code_value
     SET prsnl_request->person_list[ptot].address_list[add_total].state_disp = state_disp
    ENDIF
    SET prsnl_request->person_list[ptot].address_list[add_total].zipcode = requestin->list_0[x].
    zipcode
    IF ((requestin->list_0[x].country > " "))
     IF (((last_country != cnvtupper(requestin->list_0[x].country)) OR (last_country="  ")) )
      SET country_code_value = 0.0
      SET country_disp = fillstring(40," ")
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.active_ind=1
        AND cv.code_set=15
        AND cv.display_key=cnvtupper(cnvtalphanum(requestin->list_0[x].country))
       DETAIL
        last_country = cnvtupper(requestin->list_0[x].country), country_code_value = cv.code_value,
        country_disp = cv.display,
        country_mean = cv.cdf_meaning
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET msg1 = fillstring(110," ")
       SET msg1 = concat(build("Country: ",requestin->list_0[x].country,
         " is not defined on codeset 15."))
       CALL logrequest(msg1)
       SET error_flag = "Y"
      ENDIF
     ENDIF
     SET prsnl_request->person_list[ptot].address_list[add_total].country_code_value =
     country_code_value
     SET prsnl_request->person_list[ptot].address_list[add_total].country_disp = country_disp
     SET prsnl_request->person_list[ptot].address_list[add_total].country_mean = country_mean
    ENDIF
    IF ((requestin->list_0[x].county > " "))
     IF (((last_county != cnvtupper(requestin->list_0[x].county)) OR (last_county="  ")) )
      SET county_code_value = 0.0
      SET county_disp = fillstring(40," ")
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.active_ind=1
        AND cv.code_set=74
        AND cv.display_key=cnvtupper(cnvtalphanum(requestin->list_0[x].county))
       DETAIL
        last_county = cnvtupper(requestin->list_0[x].county), county_code_value = cv.code_value,
        county_disp = cv.display,
        county_mean = cv.cdf_meaning
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET msg1 = fillstring(110," ")
       SET msg1 = concat(build("County: ",requestin->list_0[x].county,
         " is not defined on codeset 74."))
       CALL logrequest(msg1)
       SET error_flag = "Y"
      ENDIF
     ENDIF
     SET prsnl_request->person_list[ptot].address_list[add_total].county_code_value =
     county_code_value
     SET prsnl_request->person_list[ptot].address_list[add_total].county_disp = county_disp
     SET prsnl_request->person_list[ptot].address_list[add_total].county_mean = county_mean
    ENDIF
    SET prsnl_request->person_list[ptot].address_list[add_total].contact_name = validate(requestin->
     list_0[x].contact_name," ")
    SET prsnl_request->person_list[ptot].address_list[add_total].residence_type_code_value = 0
    SET prsnl_request->person_list[ptot].address_list[add_total].residence_type_disp = " "
    SET prsnl_request->person_list[ptot].address_list[add_total].residence_type_mean = " "
    SET prsnl_request->person_list[ptot].address_list[add_total].comment_txt = validate(requestin->
     list_0[x].address_comments," ")
    SET prsnl_request->person_list[ptot].address_list[add_total].action_flag = 1
   ENDIF
 ENDFOR
 IF (ptot > 0
  AND phone_total > 0)
  SET stat = alterlist(prsnl_request->person_list[ptot].phone_list,phone_total)
 ENDIF
 IF (ptot > 0
  AND add_total > 0)
  SET stat = alterlist(prsnl_request->person_list[ptot].address_list,add_total)
 ENDIF
 IF (ptot > 0
  AND alias_total > 0)
  SET stat = alterlist(prsnl_request->person_list[ptot].alias_list,alias_total)
 ENDIF
 IF (ptot > 0
  AND org_grp_total > 0)
  SET stat = alterlist(prsnl_request->person_list[ptot].org_group_list,org_grp_total)
 ENDIF
 SET stat = alterlist(prsnl_request->person_list,ptot)
 IF (error_flag="N"
  AND bed_audit_prsnl_mode=0)
  EXECUTE bed_ens_prsnl  WITH replace("REQUEST",prsnl_request), replace("REPLY",prsnl_reply)
 ENDIF
 IF ((reply->status_data.status != "S"))
  SET msg1 = fillstring(110," ")
  SET msg1 = concat(build("Error encounter in mig_ens_prsnl- ",reply->error_msg))
  CALL logrequest(msg1)
  SET error_flag = "Y"
 ENDIF
 GO TO exit_script
 SUBROUTINE logprsnl(ptot)
   SELECT INTO "bed_imp_prsnl.log"
    DETAIL
     col 0, prsnl_request->person_list[ptot].name_full_formatted, first_prsnl = 1
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logrequest(msg1)
   SELECT INTO "bed_imp_prsnl.log"
    DETAIL
     IF (first_prsnl=1)
      col 2, "ROW", first_prsnl = 0,
      row + 1
     ENDIF
     row_number = (x+ 1)
     IF (msg1="ADDED")
      col 0, row_number"#####"
     ELSE
      col 0, row_number"#####", "  ",
      msg1
     ENDIF
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_PRSNL","  >> ERROR MSG: ",error_msg)
 ENDIF
END GO
