CREATE PROGRAM bbd_get_donors_demog:dba
 RECORD reply(
   1 donorlist[*]
     2 abo_cd = f8
     2 abo_disp = c15
     2 rh_cd = f8
     2 rh_disp = c15
     2 qual_address[*]
       3 address_id = f8
       3 address_type_cd = f8
       3 address_type_cd_mean = vc
       3 updt_cnt = i4
       3 address_format_cd = f8
       3 address_format_cd_mean = vc
       3 contact_name = vc
       3 residence_type_cd = f8
       3 residence_type_cd_mean = vc
       3 street_address_one = vc
       3 street_address_two = vc
       3 street_address_three = vc
       3 street_address_four = vc
       3 city = vc
       3 state = vc
       3 state_cd = f8
       3 zipcode = vc
       3 postal_barcode_info = vc
       3 county = vc
       3 county_cd = f8
       3 country = vc
       3 country_cd = f8
       3 residence_cd = f8
       3 mail_stop = vc
     2 qual_alias[*]
       3 person_alias_id = f8
       3 updt_cnt = i4
       3 alias_pool_cd = f8
       3 alias_pool_cd_disp = vc
       3 alias_type_cd = f8
       3 alias_type_cd_disp = vc
       3 alias_type_cd_mean = c12
       3 alias = vc
       3 alias_sub_type_cd = f8
       3 alias_sub_type_cd_mean = c12
       3 check_digit = i4
       3 check_digit_method_cd = f8
       3 formatted_alias = vc
     2 qual_antibody[*]
       3 person_antibody_id = f8
       3 encntr_id = f8
       3 antibody_cd = f8
       3 antibody_cd_disp = vc
       3 antibody_cd_mean = vc
       3 result_id = f8
       3 bb_result_id = f8
       3 updt_cnt = i4
     2 qual_antigen[*]
       3 person_antigen_id = f8
       3 encntr_id = f8
       3 antigen_cd = f8
       3 antigen_cd_disp = vc
       3 antigen_cd_mean = vc
       3 result_id = f8
       3 bb_result_id = f8
       3 updt_cnt = i4
     2 qual_employer[*]
       3 organization_id = f8
       3 organization_name = vc
     2 qual_name[*]
       3 person_name_id = f8
       3 name_type_cd = f8
       3 name_type_cd_disp = vc
       3 name_type_cd_mean = c12
       3 updt_cnt = i4
       3 name_original = vc
       3 name_format_cd = f8
       3 name_full = vc
       3 name_first = vc
       3 name_middle = vc
       3 name_last = vc
       3 name_degree = vc
       3 name_title = vc
       3 name_prefix = vc
       3 name_suffix = vc
       3 name_initials = vc
     2 qual_phone[*]
       3 phone_id = f8
       3 phone_type_cd = f8
       3 phone_type_disp = vc
       3 phone_type_mean = vc
       3 updt_cnt = i4
       3 phone_format_cd = f8
       3 phone_format_cd_mean = vc
       3 phone_format_cd_disp = vc
       3 phone_num = vc
       3 contact = vc
       3 call_instruction = vc
       3 extension = vc
       3 paging_code = vc
     2 updt_cnt = i4
     2 person_type_cd = f8
     2 person_type_cd_disp = vc
     2 name_last_key = vc
     2 name_first_key = vc
     2 name_full_formatted = vc
     2 birth_dt_cd = f8
     2 birth_dt_cd_disp = vc
     2 birth_dt_tm = di8
     2 age = vc
     2 conception_dt_tm = di8
     2 ethnic_group_cd = f8
     2 ethnic_group_cd_disp = vc
     2 language_cd = f8
     2 language_cd_disp = vc
     2 marital_type_cd = f8
     2 marital_type_cd_disp = vc
     2 race_cd = f8
     2 race_cd_disp = vc
     2 race_cd_mean = vc
     2 religion_cd = f8
     2 religion_cd_disp = vc
     2 gender_cd = f8
     2 gender_cd_disp = vc
     2 gender_cd_mean = vc
     2 name_last = vc
     2 name_first = vc
     2 last_encounter_dt_tm = di8
     2 species_cd = f8
     2 species_cd_disp = vc
     2 mothers_maiden_name = vc
     2 nationality_cd = f8
     2 nationality_cd_disp = vc
     2 name_middle_key = vc
     2 name_middle = vc
     2 birth_tz = i4
     2 person_donor[*]
       3 active_ind = i2
       3 counseling_reqrd_cd = f8
       3 counseling_reqrd_disp = vc
       3 counseling_reqrd_desc = vc
       3 counseling_reqrd_mean = c12
       3 defer_until_dt_tm = dq8
       3 donation_level = f8
       3 donation_level_trans = f8
       3 eligibility_type_cd = f8
       3 eligibility_type_disp = vc
       3 eligibility_type_desc = vc
       3 eligibility_type_mean = c12
       3 elig_for_reinstate_ind = i2
       3 last_donation_dt_tm = dq8
       3 lock_ind = i2
       3 mailings_ind = i2
       3 person_id = f8
       3 rare_donor_cd = f8
       3 rare_donor_disp = vc
       3 rare_donor_desc = vc
       3 rare_donor_mean = c12
       3 recruit_inv_area_cd = f8
       3 recruit_inv_area_disp = vc
       3 recruit_inv_area_desc = vc
       3 recruit_inv_area_mean = c12
       3 recruit_owner_area_cd = f8
       3 recruit_owner_area_disp = vc
       3 recruit_owner_area_desc = vc
       3 recruit_owner_area_mean = c12
       3 reinstated_dt_tm = dq8
       3 reinstated_ind = i2
       3 spec_dnr_interest_cd = f8
       3 spec_dnr_interest_disp = vc
       3 spec_dnr_interest_desc = vc
       3 spec_dnr_interest_mean = c12
       3 updt_cnt = i4
       3 watch_ind = i2
       3 watch_reason_cd = f8
       3 watch_reason_disp = vc
       3 watch_reason_desc = vc
       3 watch_reason_mean = c12
       3 willingness_level_cd = f8
       3 willingness_level_disp = vc
       3 willingness_level_desc = vc
       3 willingness_level_mean = c12
       3 comments_ind = i2
       3 applctx_id = f8
       3 application_nbr = i4
       3 user_name = vc
       3 app_start_dt_tm = dq8
       3 device_location = vc
       3 application_desc = vc
       3 pref_don_loc_cd = f8
       3 pref_don_loc_disp = vc
       3 pref_don_loc_mean = c12
     2 rare_types[*]
       3 rare_type_id = f8
       3 rare_type_cd = f8
       3 rare_type_disp = vc
       3 updt_cnt = i4
     2 special_interests[*]
       3 special_interest_id = f8
       3 special_interest_cd = f8
       3 special_interest_disp = vc
       3 updt_cnt = i4
     2 contact_methods[*]
       3 contact_method_id = f8
       3 contact_method_cd = f8
       3 contact_method_disp = vc
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD mult_request(
   1 person_id = f8
   1 get_aborh = i2
   1 get_address = i2
   1 get_alias = i2
   1 get_antibody = i2
   1 get_antigen = i2
   1 get_employer = i2
   1 get_name = i2
   1 get_phone = i2
   1 get_person = i2
   1 get_donor_id_ind = i2
   1 get_driver_license_ind = i2
   1 get_med_rec_nbr_ind = i2
   1 get_social_sec_ind = i2
   1 get_person_donor_ind = i2
   1 lock_donor_ind = i2
   1 get_recruit_rare_type_ind = i2
   1 get_recruit_special_ind = i2
   1 get_recruit_methods_ind = i2
 )
 DECLARE donor_cnt = i4 WITH protect, noconstant(0)
 DECLARE lindex = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE address_cnt = i4 WITH protect, noconstant(0)
 DECLARE alias_cnt = i4 WITH protect, noconstant(0)
 DECLARE ab_cnt = i4 WITH protect, noconstant(0)
 DECLARE ag_cnt = i4 WITH protect, noconstant(0)
 DECLARE employer_cnt = i4 WITH protect, noconstant(0)
 DECLARE name_cnt = i4 WITH protect, noconstant(0)
 DECLARE phone_cnt = i4 WITH protect, noconstant(0)
 DECLARE pd_cnt = i4 WITH protect, noconstant(0)
 DECLARE rt_cnt = i4 WITH protect, noconstant(0)
 DECLARE si_cnt = i4 WITH protect, noconstant(0)
 DECLARE cm_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET mult_request->get_aborh = request->get_aborh
 SET mult_request->get_address = request->get_address
 SET mult_request->get_alias = request->get_alias
 SET mult_request->get_antibody = request->get_antibody
 SET mult_request->get_antigen = request->get_antigen
 SET mult_request->get_employer = request->get_employer
 SET mult_request->get_name = request->get_name
 SET mult_request->get_phone = request->get_phone
 SET mult_request->get_person = request->get_person
 SET mult_request->get_donor_id_ind = request->get_donor_id_ind
 SET mult_request->get_driver_license_ind = request->get_driver_license_ind
 SET mult_request->get_med_rec_nbr_ind = request->get_med_rec_nbr_ind
 SET mult_request->get_social_sec_ind = request->get_social_sec_ind
 SET mult_request->get_person_donor_ind = request->get_person_donor_ind
 SET mult_request->lock_donor_ind = request->lock_donor_ind
 SET mult_request->get_recruit_special_ind = request->get_recruit_special_ind
 SET mult_request->get_recruit_rare_type_ind = request->get_recruit_rare_type_ind
 SET mult_request->get_recruit_methods_ind = request->get_recruit_methods_ind
 FOR (lindex = 1 TO size(request->donorlist,5))
   RECORD mult_reply(
     1 abo_cd = f8
     1 abo_disp = c15
     1 rh_cd = f8
     1 rh_disp = c15
     1 qual_address[*]
       2 address_id = f8
       2 address_type_cd = f8
       2 address_type_cd_mean = vc
       2 updt_cnt = i4
       2 address_format_cd = f8
       2 address_format_cd_mean = vc
       2 contact_name = vc
       2 residence_type_cd = f8
       2 residence_type_cd_mean = vc
       2 street_address_one = vc
       2 street_address_two = vc
       2 street_address_three = vc
       2 street_address_four = vc
       2 city = vc
       2 state = vc
       2 state_cd = f8
       2 zipcode = vc
       2 postal_barcode_info = vc
       2 county = vc
       2 county_cd = f8
       2 country = vc
       2 country_cd = f8
       2 residence_cd = f8
       2 mail_stop = vc
     1 qual_alias[*]
       2 person_alias_id = f8
       2 updt_cnt = i4
       2 alias_pool_cd = f8
       2 alias_pool_cd_disp = vc
       2 alias_type_cd = f8
       2 alias_type_cd_disp = vc
       2 alias_type_cd_mean = c12
       2 alias = vc
       2 alias_sub_type_cd = f8
       2 alias_sub_type_cd_mean = c12
       2 check_digit = i4
       2 check_digit_method_cd = f8
       2 formatted_alias = vc
     1 qual_antibody[*]
       2 person_antibody_id = f8
       2 encntr_id = f8
       2 antibody_cd = f8
       2 antibody_cd_disp = vc
       2 antibody_cd_mean = vc
       2 result_id = f8
       2 bb_result_id = f8
       2 updt_cnt = i4
     1 qual_antigen[*]
       2 person_antigen_id = f8
       2 encntr_id = f8
       2 antigen_cd = f8
       2 antigen_cd_disp = vc
       2 antigen_cd_mean = vc
       2 result_id = f8
       2 bb_result_id = f8
       2 updt_cnt = i4
     1 qual_employer[*]
       2 organization_id = f8
       2 organization_name = vc
     1 qual_name[*]
       2 person_name_id = f8
       2 name_type_cd = f8
       2 name_type_cd_disp = vc
       2 name_type_cd_mean = c12
       2 updt_cnt = i4
       2 name_original = vc
       2 name_format_cd = f8
       2 name_full = vc
       2 name_first = vc
       2 name_middle = vc
       2 name_last = vc
       2 name_degree = vc
       2 name_title = vc
       2 name_prefix = vc
       2 name_suffix = vc
       2 name_initials = vc
     1 qual_phone[*]
       2 phone_id = f8
       2 phone_type_cd = f8
       2 phone_type_disp = vc
       2 phone_type_mean = vc
       2 updt_cnt = i4
       2 phone_format_cd = f8
       2 phone_format_cd_mean = vc
       2 phone_format_cd_disp = vc
       2 phone_num = vc
       2 contact = vc
       2 call_instruction = vc
       2 extension = vc
       2 paging_code = vc
     1 updt_cnt = i4
     1 person_type_cd = f8
     1 person_type_cd_disp = vc
     1 name_last_key = vc
     1 name_first_key = vc
     1 name_full_formatted = vc
     1 birth_dt_cd = f8
     1 birth_dt_cd_disp = vc
     1 birth_dt_tm = di8
     1 age = vc
     1 conception_dt_tm = di8
     1 ethnic_group_cd = f8
     1 ethnic_group_cd_disp = vc
     1 language_cd = f8
     1 language_cd_disp = vc
     1 marital_type_cd = f8
     1 marital_type_cd_disp = vc
     1 race_cd = f8
     1 race_cd_disp = vc
     1 race_cd_mean = vc
     1 religion_cd = f8
     1 religion_cd_disp = vc
     1 gender_cd = f8
     1 gender_cd_disp = vc
     1 gender_cd_mean = vc
     1 name_last = vc
     1 name_first = vc
     1 last_encounter_dt_tm = di8
     1 species_cd = f8
     1 species_cd_disp = vc
     1 mothers_maiden_name = vc
     1 nationality_cd = f8
     1 nationality_cd_disp = vc
     1 name_middle_key = vc
     1 name_middle = vc
     1 birth_tz = i4
     1 person_donor[*]
       2 active_ind = i2
       2 counseling_reqrd_cd = f8
       2 counseling_reqrd_disp = vc
       2 counseling_reqrd_desc = vc
       2 counseling_reqrd_mean = c12
       2 defer_until_dt_tm = dq8
       2 donation_level = f8
       2 donation_level_trans = f8
       2 eligibility_type_cd = f8
       2 eligibility_type_disp = vc
       2 eligibility_type_desc = vc
       2 eligibility_type_mean = c12
       2 elig_for_reinstate_ind = i2
       2 last_donation_dt_tm = dq8
       2 lock_ind = i2
       2 mailings_ind = i2
       2 person_id = f8
       2 rare_donor_cd = f8
       2 rare_donor_disp = vc
       2 rare_donor_desc = vc
       2 rare_donor_mean = c12
       2 recruit_inv_area_cd = f8
       2 recruit_inv_area_disp = vc
       2 recruit_inv_area_desc = vc
       2 recruit_inv_area_mean = c12
       2 recruit_owner_area_cd = f8
       2 recruit_owner_area_disp = vc
       2 recruit_owner_area_desc = vc
       2 recruit_owner_area_mean = c12
       2 reinstated_dt_tm = dq8
       2 reinstated_ind = i2
       2 spec_dnr_interest_cd = f8
       2 spec_dnr_interest_disp = vc
       2 spec_dnr_interest_desc = vc
       2 spec_dnr_interest_mean = c12
       2 updt_cnt = i4
       2 watch_ind = i2
       2 watch_reason_cd = f8
       2 watch_reason_disp = vc
       2 watch_reason_desc = vc
       2 watch_reason_mean = c12
       2 willingness_level_cd = f8
       2 willingness_level_disp = vc
       2 willingness_level_desc = vc
       2 willingness_level_mean = c12
       2 comments_ind = i2
       2 applctx_id = f8
       2 application_nbr = i4
       2 user_name = vc
       2 app_start_dt_tm = dq8
       2 device_location = vc
       2 application_desc = vc
       2 pref_don_loc_cd = f8
       2 pref_don_loc_disp = vc
       2 pref_don_loc_mean = c12
     1 rare_types[*]
       2 rare_type_id = f8
       2 rare_type_cd = f8
       2 rare_type_disp = vc
       2 updt_cnt = i4
     1 special_interests[*]
       2 special_interest_id = f8
       2 special_interest_cd = f8
       2 special_interest_disp = vc
       2 updt_cnt = i4
     1 contact_methods[*]
       2 contact_method_id = f8
       2 contact_method_cd = f8
       2 contact_method_disp = vc
       2 updt_cnt = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET mult_request->person_id = request->donorlist[lindex].person_id
   EXECUTE bbd_get_donor_demog  WITH replace("REQUEST","MULT_REQUEST"), replace("REPLY","MULT_REPLY")
   IF ((mult_reply->status_data.status="F"))
    SET stat = alterlist(reply->donorlist,0)
    SET reply->status_data.subeventstatus[1].operationname = mult_reply->status_data.subeventstatus[1
    ].operationname
    SET reply->status_data.subeventstatus[1].operationstatus = mult_reply->status_data.
    subeventstatus[1].operationstatus
    SET reply->status_data.subeventstatus[1].targetobjectname = mult_reply->status_data.
    subeventstatus[1].targetobjectname
    SET reply->status_data.subeventstatus[1].targetobjectvalue = mult_reply->status_data.
    subeventstatus[1].targetobjectvalue
    GO TO exit_script
   ELSEIF ((((mult_reply->status_data.status="S")) OR ((mult_reply->status_data.status="L"))) )
    SET donor_cnt = (donor_cnt+ 1)
    SET stat = alterlist(reply->donorlist,donor_cnt)
    SET reply->donorlist[donor_cnt].abo_cd = mult_reply->abo_cd
    SET reply->donorlist[donor_cnt].abo_disp = mult_reply->abo_disp
    SET reply->donorlist[donor_cnt].rh_cd = mult_reply->rh_cd
    SET reply->donorlist[donor_cnt].rh_disp = mult_reply->rh_disp
    SET stat = alterlist(reply->donorlist[donor_cnt].qual_address,size(mult_reply->qual_address,5))
    FOR (address_cnt = 1 TO size(mult_reply->qual_address,5))
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].address_id = mult_reply->
      qual_address[address_cnt].address_id
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].address_type_cd = mult_reply->
      qual_address[address_cnt].address_type_cd
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].address_type_cd_mean = mult_reply->
      qual_address[address_cnt].address_type_cd_mean
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].updt_cnt = mult_reply->qual_address[
      address_cnt].updt_cnt
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].address_format_cd = mult_reply->
      qual_address[address_cnt].address_format_cd
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].address_format_cd_mean = mult_reply->
      qual_address[address_cnt].address_format_cd_mean
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].contact_name = mult_reply->
      qual_address[address_cnt].contact_name
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].residence_type_cd = mult_reply->
      qual_address[address_cnt].residence_type_cd
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].residence_type_cd_mean = mult_reply->
      qual_address[address_cnt].residence_type_cd_mean
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].street_address_one = mult_reply->
      qual_address[address_cnt].street_address_one
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].street_address_two = mult_reply->
      qual_address[address_cnt].street_address_two
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].street_address_three = mult_reply->
      qual_address[address_cnt].street_address_three
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].street_address_four = mult_reply->
      qual_address[address_cnt].street_address_four
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].city = mult_reply->qual_address[
      address_cnt].city
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].state = mult_reply->qual_address[
      address_cnt].state
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].state_cd = mult_reply->qual_address[
      address_cnt].state_cd
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].zipcode = mult_reply->qual_address[
      address_cnt].zipcode
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].postal_barcode_info = mult_reply->
      qual_address[address_cnt].postal_barcode_info
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].county = mult_reply->qual_address[
      address_cnt].county
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].county_cd = mult_reply->qual_address[
      address_cnt].county_cd
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].country = mult_reply->qual_address[
      address_cnt].country
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].country_cd = mult_reply->
      qual_address[address_cnt].country_cd
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].residence_cd = mult_reply->
      qual_address[address_cnt].residence_cd
      SET reply->donorlist[donor_cnt].qual_address[address_cnt].mail_stop = mult_reply->qual_address[
      address_cnt].mail_stop
    ENDFOR
    SET stat = alterlist(reply->donorlist[donor_cnt].qual_alias,size(mult_reply->qual_alias,5))
    FOR (alias_cnt = 1 TO size(mult_reply->qual_alias,5))
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].person_alias_id = mult_reply->qual_alias[
      alias_cnt].person_alias_id
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].updt_cnt = mult_reply->qual_alias[
      alias_cnt].updt_cnt
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].alias_pool_cd = mult_reply->qual_alias[
      alias_cnt].alias_pool_cd
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].alias_pool_cd_disp = mult_reply->
      qual_alias[alias_cnt].alias_pool_cd_disp
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].alias_type_cd = mult_reply->qual_alias[
      alias_cnt].alias_type_cd
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].alias_type_cd_disp = mult_reply->
      qual_alias[alias_cnt].alias_type_cd_disp
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].alias_type_cd_mean = mult_reply->
      qual_alias[alias_cnt].alias_type_cd_mean
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].alias = mult_reply->qual_alias[alias_cnt]
      .alias
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].alias_sub_type_cd = mult_reply->
      qual_alias[alias_cnt].alias_sub_type_cd
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].alias_sub_type_cd_mean = mult_reply->
      qual_alias[alias_cnt].alias_sub_type_cd_mean
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].check_digit = mult_reply->qual_alias[
      alias_cnt].check_digit
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].check_digit_method_cd = mult_reply->
      qual_alias[alias_cnt].check_digit_method_cd
      SET reply->donorlist[donor_cnt].qual_alias[alias_cnt].formatted_alias = mult_reply->qual_alias[
      alias_cnt].formatted_alias
    ENDFOR
    SET stat = alterlist(reply->donorlist[donor_cnt].qual_antibody,size(mult_reply->qual_antibody,5))
    FOR (ab_cnt = 1 TO size(mult_reply->qual_antibody,5))
      SET reply->donorlist[donor_cnt].qual_antibody[ab_cnt].person_antibody_id = mult_reply->
      qual_antibody[ab_cnt].person_antibody_id
      SET reply->donorlist[donor_cnt].qual_antibody[ab_cnt].encntr_id = mult_reply->qual_antibody[
      ab_cnt].encntr_id
      SET reply->donorlist[donor_cnt].qual_antibody[ab_cnt].antibody_cd = mult_reply->qual_antibody[
      ab_cnt].antibody_cd
      SET reply->donorlist[donor_cnt].qual_antibody[ab_cnt].antibody_cd_disp = mult_reply->
      qual_antibody[ab_cnt].antibody_cd_disp
      SET reply->donorlist[donor_cnt].qual_antibody[ab_cnt].antibody_cd_mean = mult_reply->
      qual_antibody[ab_cnt].antibody_cd_mean
      SET reply->donorlist[donor_cnt].qual_antibody[ab_cnt].result_id = mult_reply->qual_antibody[
      ab_cnt].result_id
      SET reply->donorlist[donor_cnt].qual_antibody[ab_cnt].bb_result_id = mult_reply->qual_antibody[
      ab_cnt].bb_result_id
      SET reply->donorlist[donor_cnt].qual_antibody[ab_cnt].updt_cnt = mult_reply->qual_antibody[
      ab_cnt].updt_cnt
    ENDFOR
    SET stat = alterlist(reply->donorlist[donor_cnt].qual_antigen,size(mult_reply->qual_antigen,5))
    FOR (ag_cnt = 1 TO size(mult_reply->qual_antigen,5))
      SET reply->donorlist[donor_cnt].qual_antigen[ag_cnt].person_antigen_id = mult_reply->
      qual_antigen[ag_cnt].person_antigen_id
      SET reply->donorlist[donor_cnt].qual_antigen[ag_cnt].encntr_id = mult_reply->qual_antigen[
      ag_cnt].encntr_id
      SET reply->donorlist[donor_cnt].qual_antigen[ag_cnt].antigen_cd = mult_reply->qual_antigen[
      ag_cnt].antigen_cd
      SET reply->donorlist[donor_cnt].qual_antigen[ag_cnt].antigen_cd_disp = mult_reply->
      qual_antigen[ag_cnt].antigen_cd_disp
      SET reply->donorlist[donor_cnt].qual_antigen[ag_cnt].antigen_cd_mean = mult_reply->
      qual_antigen[ag_cnt].antigen_cd_mean
      SET reply->donorlist[donor_cnt].qual_antigen[ag_cnt].result_id = mult_reply->qual_antigen[
      ag_cnt].result_id
      SET reply->donorlist[donor_cnt].qual_antigen[ag_cnt].bb_result_id = mult_reply->qual_antigen[
      ag_cnt].bb_result_id
      SET reply->donorlist[donor_cnt].qual_antigen[ag_cnt].updt_cnt = mult_reply->qual_antigen[ag_cnt
      ].updt_cnt
    ENDFOR
    SET stat = alterlist(reply->donorlist[donor_cnt].qual_employer,size(mult_reply->qual_employer,5))
    FOR (employer_cnt = 1 TO size(mult_reply->qual_employer,5))
     SET reply->donorlist[donor_cnt].qual_employer[employer_cnt].organization_id = mult_reply->
     qual_employer[employer_cnt].organization_id
     SET reply->donorlist[donor_cnt].qual_employer[employer_cnt].organization_name = mult_reply->
     qual_employer[employer_cnt].organization_name
    ENDFOR
    SET stat = alterlist(reply->donorlist[donor_cnt].qual_name,size(mult_reply->qual_name,5))
    FOR (name_cnt = 1 TO size(mult_reply->qual_name,5))
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].person_name_id = mult_reply->qual_name[
      name_cnt].person_name_id
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_type_cd = mult_reply->qual_name[
      name_cnt].name_type_cd
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_type_cd_disp = mult_reply->qual_name[
      name_cnt].name_type_cd_disp
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_type_cd_mean = mult_reply->qual_name[
      name_cnt].name_type_cd_mean
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].updt_cnt = mult_reply->qual_name[name_cnt].
      updt_cnt
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_original = mult_reply->qual_name[
      name_cnt].name_original
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_format_cd = mult_reply->qual_name[
      name_cnt].name_format_cd
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_full = mult_reply->qual_name[name_cnt]
      .name_full
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_first = mult_reply->qual_name[name_cnt
      ].name_first
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_middle = mult_reply->qual_name[
      name_cnt].name_middle
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_last = mult_reply->qual_name[name_cnt]
      .name_last
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_degree = mult_reply->qual_name[
      name_cnt].name_degree
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_title = mult_reply->qual_name[name_cnt
      ].name_title
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_prefix = mult_reply->qual_name[
      name_cnt].name_prefix
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_suffix = mult_reply->qual_name[
      name_cnt].name_suffix
      SET reply->donorlist[donor_cnt].qual_name[name_cnt].name_initials = mult_reply->qual_name[
      name_cnt].name_initials
    ENDFOR
    SET stat = alterlist(reply->donorlist[donor_cnt].qual_phone,size(mult_reply->qual_phone,5))
    FOR (phone_cnt = 1 TO size(mult_reply->qual_phone,5))
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].phone_id = mult_reply->qual_phone[
      phone_cnt].phone_id
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].phone_type_cd = mult_reply->qual_phone[
      phone_cnt].phone_type_cd
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].phone_type_disp = mult_reply->qual_phone[
      phone_cnt].phone_type_disp
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].phone_type_mean = mult_reply->qual_phone[
      phone_cnt].phone_type_mean
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].updt_cnt = mult_reply->qual_phone[
      phone_cnt].updt_cnt
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].phone_format_cd = mult_reply->qual_phone[
      phone_cnt].phone_format_cd
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].phone_format_cd_mean = mult_reply->
      qual_phone[phone_cnt].phone_format_cd_mean
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].phone_format_cd_disp = mult_reply->
      qual_phone[phone_cnt].phone_format_cd_disp
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].phone_num = mult_reply->qual_phone[
      phone_cnt].phone_num
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].contact = mult_reply->qual_phone[
      phone_cnt].contact
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].call_instruction = mult_reply->
      qual_phone[phone_cnt].call_instruction
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].extension = mult_reply->qual_phone[
      phone_cnt].extension
      SET reply->donorlist[donor_cnt].qual_phone[phone_cnt].paging_code = mult_reply->qual_phone[
      phone_cnt].paging_code
    ENDFOR
    SET reply->donorlist[donor_cnt].updt_cnt = mult_reply->updt_cnt
    SET reply->donorlist[donor_cnt].person_type_cd = mult_reply->person_type_cd
    SET reply->donorlist[donor_cnt].person_type_cd_disp = mult_reply->person_type_cd_disp
    SET reply->donorlist[donor_cnt].name_last_key = mult_reply->name_last_key
    SET reply->donorlist[donor_cnt].name_first_key = mult_reply->name_first_key
    SET reply->donorlist[donor_cnt].name_full_formatted = mult_reply->name_full_formatted
    SET reply->donorlist[donor_cnt].birth_dt_cd = mult_reply->birth_dt_cd
    SET reply->donorlist[donor_cnt].birth_dt_cd_disp = mult_reply->birth_dt_cd_disp
    SET reply->donorlist[donor_cnt].birth_dt_tm = mult_reply->birth_dt_tm
    SET reply->donorlist[donor_cnt].age = mult_reply->age
    SET reply->donorlist[donor_cnt].conception_dt_tm = mult_reply->conception_dt_tm
    SET reply->donorlist[donor_cnt].ethnic_group_cd = mult_reply->ethnic_group_cd
    SET reply->donorlist[donor_cnt].ethnic_group_cd_disp = mult_reply->ethnic_group_cd_disp
    SET reply->donorlist[donor_cnt].language_cd = mult_reply->language_cd
    SET reply->donorlist[donor_cnt].language_cd_disp = mult_reply->language_cd_disp
    SET reply->donorlist[donor_cnt].marital_type_cd = mult_reply->marital_type_cd
    SET reply->donorlist[donor_cnt].marital_type_cd_disp = mult_reply->marital_type_cd_disp
    SET reply->donorlist[donor_cnt].race_cd = mult_reply->race_cd
    SET reply->donorlist[donor_cnt].race_cd_disp = mult_reply->religion_cd_disp
    SET reply->donorlist[donor_cnt].race_cd_mean = mult_reply->race_cd_mean
    SET reply->donorlist[donor_cnt].religion_cd = mult_reply->religion_cd
    SET reply->donorlist[donor_cnt].religion_cd_disp = mult_reply->religion_cd_disp
    SET reply->donorlist[donor_cnt].gender_cd = mult_reply->gender_cd
    SET reply->donorlist[donor_cnt].gender_cd_disp = mult_reply->gender_cd_disp
    SET reply->donorlist[donor_cnt].gender_cd_mean = mult_reply->gender_cd_mean
    SET reply->donorlist[donor_cnt].name_last = mult_reply->name_last
    SET reply->donorlist[donor_cnt].name_first = mult_reply->name_first
    SET reply->donorlist[donor_cnt].last_encounter_dt_tm = mult_reply->last_encounter_dt_tm
    SET reply->donorlist[donor_cnt].species_cd = mult_reply->species_cd
    SET reply->donorlist[donor_cnt].species_cd_disp = mult_reply->species_cd_disp
    SET reply->donorlist[donor_cnt].mothers_maiden_name = mult_reply->mothers_maiden_name
    SET reply->donorlist[donor_cnt].nationality_cd = mult_reply->nationality_cd
    SET reply->donorlist[donor_cnt].nationality_cd_disp = mult_reply->nationality_cd_disp
    SET reply->donorlist[donor_cnt].name_middle_key = mult_reply->name_middle_key
    SET reply->donorlist[donor_cnt].name_middle = mult_reply->name_middle
    SET reply->donorlist[donor_cnt].birth_tz = mult_reply->birth_tz
    SET stat = alterlist(reply->donorlist[donor_cnt].person_donor,size(mult_reply->person_donor,5))
    FOR (pd_cnt = 1 TO size(mult_reply->person_donor,5))
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].active_ind = mult_reply->person_donor[
      pd_cnt].active_ind
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].counseling_reqrd_cd = mult_reply->
      person_donor[pd_cnt].counseling_reqrd_cd
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].counseling_reqrd_disp = mult_reply->
      person_donor[pd_cnt].counseling_reqrd_disp
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].counseling_reqrd_desc = mult_reply->
      person_donor[pd_cnt].counseling_reqrd_desc
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].counseling_reqrd_mean = mult_reply->
      person_donor[pd_cnt].counseling_reqrd_mean
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].defer_until_dt_tm = mult_reply->
      person_donor[pd_cnt].defer_until_dt_tm
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].donation_level = mult_reply->person_donor[
      pd_cnt].donation_level
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].donation_level_trans = mult_reply->
      person_donor[pd_cnt].donation_level_trans
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].eligibility_type_cd = mult_reply->
      person_donor[pd_cnt].eligibility_type_cd
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].eligibility_type_disp = mult_reply->
      person_donor[pd_cnt].eligibility_type_disp
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].eligibility_type_desc = mult_reply->
      person_donor[pd_cnt].eligibility_type_desc
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].eligibility_type_mean = mult_reply->
      person_donor[pd_cnt].eligibility_type_mean
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].elig_for_reinstate_ind = mult_reply->
      person_donor[pd_cnt].elig_for_reinstate_ind
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].last_donation_dt_tm = mult_reply->
      person_donor[pd_cnt].last_donation_dt_tm
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].lock_ind = mult_reply->person_donor[pd_cnt
      ].lock_ind
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].mailings_ind = mult_reply->person_donor[
      pd_cnt].mailings_ind
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].person_id = mult_reply->person_donor[
      pd_cnt].person_id
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].rare_donor_cd = mult_reply->person_donor[
      pd_cnt].rare_donor_cd
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].rare_donor_disp = mult_reply->
      person_donor[pd_cnt].rare_donor_disp
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].rare_donor_desc = mult_reply->
      person_donor[pd_cnt].rare_donor_desc
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].rare_donor_mean = mult_reply->
      person_donor[pd_cnt].rare_donor_mean
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].recruit_inv_area_cd = mult_reply->
      person_donor[pd_cnt].recruit_inv_area_cd
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].recruit_inv_area_disp = mult_reply->
      person_donor[pd_cnt].recruit_inv_area_disp
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].recruit_inv_area_desc = mult_reply->
      person_donor[pd_cnt].recruit_inv_area_desc
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].recruit_inv_area_mean = mult_reply->
      person_donor[pd_cnt].recruit_inv_area_mean
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].recruit_owner_area_cd = mult_reply->
      person_donor[pd_cnt].recruit_owner_area_cd
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].recruit_owner_area_disp = mult_reply->
      person_donor[pd_cnt].recruit_owner_area_disp
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].recruit_owner_area_desc = mult_reply->
      person_donor[pd_cnt].recruit_owner_area_desc
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].recruit_owner_area_mean = mult_reply->
      person_donor[pd_cnt].recruit_owner_area_mean
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].reinstated_dt_tm = mult_reply->
      person_donor[pd_cnt].reinstated_dt_tm
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].reinstated_ind = mult_reply->person_donor[
      pd_cnt].reinstated_ind
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].spec_dnr_interest_cd = mult_reply->
      person_donor[pd_cnt].spec_dnr_interest_cd
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].spec_dnr_interest_disp = mult_reply->
      person_donor[pd_cnt].spec_dnr_interest_disp
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].spec_dnr_interest_desc = mult_reply->
      person_donor[pd_cnt].spec_dnr_interest_desc
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].spec_dnr_interest_mean = mult_reply->
      person_donor[pd_cnt].spec_dnr_interest_mean
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].updt_cnt = mult_reply->person_donor[pd_cnt
      ].updt_cnt
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].watch_ind = mult_reply->person_donor[
      pd_cnt].watch_ind
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].watch_reason_cd = mult_reply->
      person_donor[pd_cnt].watch_reason_cd
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].watch_reason_disp = mult_reply->
      person_donor[pd_cnt].watch_reason_disp
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].watch_reason_desc = mult_reply->
      person_donor[pd_cnt].watch_reason_desc
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].watch_reason_mean = mult_reply->
      person_donor[pd_cnt].watch_reason_mean
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].willingness_level_cd = mult_reply->
      person_donor[pd_cnt].willingness_level_cd
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].willingness_level_disp = mult_reply->
      person_donor[pd_cnt].willingness_level_disp
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].willingness_level_desc = mult_reply->
      person_donor[pd_cnt].willingness_level_desc
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].willingness_level_mean = mult_reply->
      person_donor[pd_cnt].willingness_level_mean
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].comments_ind = mult_reply->person_donor[
      pd_cnt].comments_ind
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].applctx_id = mult_reply->person_donor[
      pd_cnt].applctx_id
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].application_nbr = mult_reply->
      person_donor[pd_cnt].application_nbr
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].user_name = mult_reply->person_donor[
      pd_cnt].user_name
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].app_start_dt_tm = mult_reply->
      person_donor[pd_cnt].app_start_dt_tm
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].device_location = mult_reply->
      person_donor[pd_cnt].device_location
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].application_desc = mult_reply->
      person_donor[pd_cnt].application_desc
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].pref_don_loc_cd = mult_reply->
      person_donor[pd_cnt].pref_don_loc_cd
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].pref_don_loc_disp = mult_reply->
      person_donor[pd_cnt].pref_don_loc_disp
      SET reply->donorlist[donor_cnt].person_donor[pd_cnt].pref_don_loc_mean = mult_reply->
      person_donor[pd_cnt].pref_don_loc_mean
    ENDFOR
    SET stat = alterlist(reply->donorlist[donor_cnt].rare_types,size(mult_reply->rare_types,5))
    FOR (rt_cnt = 1 TO size(mult_reply->rare_types,5))
      SET reply->donorlist[donor_cnt].rare_types[rt_cnt].rare_type_id = mult_reply->rare_types[rt_cnt
      ].rare_type_id
      SET reply->donorlist[donor_cnt].rare_types[rt_cnt].rare_type_cd = mult_reply->rare_types[rt_cnt
      ].rare_type_cd
      SET reply->donorlist[donor_cnt].rare_types[rt_cnt].rare_type_disp = mult_reply->rare_types[
      rt_cnt].rare_type_disp
      SET reply->donorlist[donor_cnt].rare_types[rt_cnt].updt_cnt = mult_reply->rare_types[rt_cnt].
      updt_cnt
    ENDFOR
    SET stat = alterlist(reply->donorlist[donor_cnt].special_interests,size(mult_reply->
      special_interests,5))
    FOR (si_cnt = 1 TO size(mult_reply->special_interests,5))
      SET reply->donorlist[donor_cnt].special_interests[si_cnt].special_interest_id = mult_reply->
      special_interests[si_cnt].special_interest_id
      SET reply->donorlist[donor_cnt].special_interests[si_cnt].special_interest_cd = mult_reply->
      special_interests[si_cnt].special_interest_cd
      SET reply->donorlist[donor_cnt].special_interests[si_cnt].special_interest_disp = mult_reply->
      special_interests[si_cnt].special_interest_disp
      SET reply->donorlist[donor_cnt].special_interests[si_cnt].updt_cnt = mult_reply->
      special_interests[si_cnt].updt_cnt
    ENDFOR
    SET stat = alterlist(reply->donorlist[donor_cnt].contact_methods,size(mult_reply->contact_methods,
      5))
    FOR (cm_cnt = 1 TO size(mult_reply->contact_methods,5))
      SET reply->donorlist[donor_cnt].contact_methods[cm_cnt].contact_method_id = mult_reply->
      contact_methods[cm_cnt].contact_method_id
      SET reply->donorlist[donor_cnt].contact_methods[cm_cnt].contact_method_cd = mult_reply->
      contact_methods[cm_cnt].contact_method_cd
      SET reply->donorlist[donor_cnt].contact_methods[cm_cnt].contact_method_disp = mult_reply->
      contact_methods[cm_cnt].contact_method_disp
      SET reply->donorlist[donor_cnt].contact_methods[cm_cnt].updt_cnt = mult_reply->contact_methods[
      cm_cnt].updt_cnt
    ENDFOR
   ENDIF
   FREE RECORD mult_reply
 ENDFOR
 FREE RECORD mult_request
 IF (size(reply->donorlist,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF ((reply->status_data.status="Z"))
  SET reply->status_data.subeventstatus[1].operationname = "Retrieve Donors - No Data"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BBD_GET_DONORS_DEMOG"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data does not exist."
 ENDIF
END GO
