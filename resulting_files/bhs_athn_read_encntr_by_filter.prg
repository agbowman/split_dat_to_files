CREATE PROGRAM bhs_athn_read_encntr_by_filter
 DECLARE moutputdevice = vc WITH noconstant( $1)
 RECORD orequest(
   1 debug = i2
   1 encounter_id = f8
   1 options = vc
   1 person_id = f8
   1 return_all = i2
   1 security = i2
   1 user_id = f8
   1 user_name = vc
   1 limit_ind = i2
   1 max_encntr = i4
   1 filter[*]
     2 flag = i2
     2 meaning = vc
     2 options = vc
     2 phonetic = i2
     2 value = vc
     2 weight = f8
     2 values[*]
       3 value = vc
   1 result[*]
     2 flag = i2
     2 meaning = vc
     2 options = vc
   1 limit[*]
     2 encntr_type_class_cd = f8
     2 date_option = i2
     2 num_days = i2
   1 end_effective_dt_tm = dq8
   1 return_hidden_encounters_ind = i2
 )
 RECORD lrequest(
   1 encntr_ind = i2
   1 encntr_alias_ind = i2
   1 encntr_info_ind = i2
   1 encntr_prsnl_reltn_ind = i2
   1 entity_activity_ind = i2
   1 encntrs[*]
     2 encntr_id = f8
   1 reg_from_dt_tm = dq8
   1 reg_to_dt_tm = dq8
   1 encntr_nbr = i4
 )
 RECORD out_rec(
   1 status = vc
   1 encounters[*]
     2 encounter = vc
       3 accommodation_disp = vc
       3 accommodation_mean = vc
       3 accommodation_cd = vc
       3 accommodation_request_disp = vc
       3 accommodation_request_mean = vc
       3 accommodation_request_cd = vc
       3 admit_mode_disp = vc
       3 admit_mode_mean = vc
       3 admit_mode_cd = vc
       3 admit_src_disp = vc
       3 admit_src_mean = vc
       3 admit_src_cd = vc
       3 admit_type_disp = vc
       3 admit_type_mean = vc
       3 admit_type_cd = vc
       3 admit_with_medication_disp = vc
       3 admit_with_medication_mean = vc
       3 admit_with_medication_cd = vc
       3 alt_lvl_care_disp = vc
       3 alt_lvl_care_mean = vc
       3 alt_lvl_care_cd = vc
       3 alt_result_dest_disp = vc
       3 alt_result_dest_mean = vc
       3 alt_result_dest_cd = vc
       3 ambulatory_cond_disp = vc
       3 ambulatory_cond_mean = vc
       3 ambulatory_cond_cd = vc
       3 arrive_dt_tm = vc
       3 bed_disp = vc
       3 bed_mean = vc
       3 bed_cd = vc
       3 building_disp = vc
       3 building_mean = vc
       3 building_cd = vc
       3 confid_level_disp = vc
       3 confid_level_mean = vc
       3 confid_level_cd = vc
       3 contributor_system_disp = vc
       3 contributor_system_mean = vc
       3 contributor_system_cd = vc
       3 courtesy_disp = vc
       3 courtesy_mean = vc
       3 courtesy_cd = vc
       3 depart_dt_tm = vc
       3 diet_type_disp = vc
       3 diet_type_mean = vc
       3 diet_type_cd = vc
       3 disch_dt_tm = vc
       3 disch_disposition_disp = vc
       3 disch_disposition_mean = vc
       3 disch_disposition_cd = vc
       3 disch_to_loctn_disp = vc
       3 disch_to_loctn_mean = vc
       3 disch_to_loctn_cd = vc
       3 encntr_id = vc
       3 encntr_status_disp = vc
       3 encntr_status_mean = vc
       3 encntr_status_cd = vc
       3 encntr_type_disp = vc
       3 encntr_type_mean = vc
       3 encntr_type_cd = vc
       3 encntr_type_class_disp = vc
       3 encntr_type_class_mean = vc
       3 encntr_type_class_cd = vc
       3 est_arrive_dt_tm = vc
       3 est_depart_dt_tm = vc
       3 financial_class_disp = vc
       3 financial_class_mean = vc
       3 financial_class_cd = vc
       3 guarantor_type_disp = vc
       3 guarantor_type_mean = vc
       3 guarantor_type_cd = vc
       3 isolation_disp = vc
       3 isolation_mean = vc
       3 isolation_cd = vc
       3 med_service_disp = vc
       3 med_service_mean = vc
       3 med_service_cd = vc
       3 nurse_unit_disp = vc
       3 nurse_unit_mean = vc
       3 nurse_unit_cd = vc
       3 organization_id = vc
       3 person_id = vc
       3 preadmit_nbr = vc
       3 preadmit_testing_disp = vc
       3 preadmit_testing_mean = vc
       3 preadmit_testing_cd = vc
       3 pre_reg_dt_tm = vc
       3 pre_reg_prsnl_id = vc
       3 pre_reg_prsnl_name = vc
       3 reason_for_visit = vc
       3 referring_comment = vc
       3 reg_dt_tm = vc
       3 reg_prsnl_id = vc
       3 reg_prsnl_name = vc
       3 result_dest_disp = vc
       3 result_dest_mean = vc
       3 result_dest_cd = vc
       3 room_disp = vc
       3 room_mean = vc
       3 room_cd = vc
       3 temp_location_disp = vc
       3 temp_location_mean = vc
       3 temp_location_cd = vc
       3 vip_disp = vc
       3 vip_mean = vc
       3 vip_cd = vc
     2 encntr_alias[*]
       3 alias = vc
       3 alias_formatted = vc
       3 alias_pool_cd = vc
       3 alias_pool_disp = vc
       3 alias_pool_mean = vc
       3 encntr_alias_type_cd = vc
       3 encntr_alias_type_disp = vc
       3 encntr_alias_type_mean = vc
       3 encntr_alias_id = vc
       3 encntr_id = vc
     2 encntr_prsnl_reltn[*]
       3 encntr_prsnl_reltn_id = vc
       3 encntr_id = vc
       3 expiration_ind = vc
       3 ft_prsnl_name = vc
       3 prsnl_name = vc
       3 prsnl_person_id = vc
       3 encntr_prsnl_r_cd = vc
       3 encntr_prsnl_r_disp = vc
       3 encntr_prsnl_r_mean = vc
     2 encntr_info[*]
       3 chartable_ind = vc
       3 encntr_id = vc
       3 encntr_info_id = vc
       3 info_type_cd = vc
       3 info_type_disp = vc
       3 info_type_mean = vc
       3 info_sub_type_cd = vc
       3 info_sub_type_disp = vc
       3 info_sub_type_mean = vc
       3 long_text = vc
       3 long_text_id = vc
       3 value_dt_tm = vc
       3 value_numeric = vc
       3 value_cd = vc
       3 value_disp = vc
       3 value_mean = vc
 )
 DECLARE flag_cnt = i2
 SET orequest->person_id =  $2
 IF (( $3 > "")
  AND ( $4 > ""))
  SET flag_cnt += 1
  SET stat = alterlist(orequest->filter,flag_cnt)
  SET orequest->filter[flag_cnt].flag = 120
  SET orequest->filter[flag_cnt].meaning =  $3
  SET orequest->filter[flag_cnt].value =  $4
 ENDIF
 IF (( $5 > ""))
  SET flag_cnt += 1
  SET stat = alterlist(orequest->filter,flag_cnt)
  SET orequest->filter[flag_cnt].flag = 139
  SET orequest->filter[flag_cnt].value =  $5
 ENDIF
 IF (( $6 > ""))
  SET flag_cnt += 1
  SET stat = alterlist(orequest->filter,flag_cnt)
  SET orequest->filter[flag_cnt].flag = 140
  SET orequest->filter[flag_cnt].value =  $6
 ENDIF
 IF (( $7 > ""))
  SET flag_cnt += 1
  SET stat = alterlist(orequest->filter,flag_cnt)
  SET orequest->filter[flag_cnt].flag = 138
  SET orequest->filter[flag_cnt].value =  $7
 ENDIF
 IF (( $8 > ""))
  SET flag_cnt += 1
  SET stat = alterlist(orequest->filter,flag_cnt)
  SET orequest->filter[flag_cnt].flag = 148
  SET orequest->filter[flag_cnt].value =  $8
 ENDIF
 IF (( $9 > ""))
  SET flag_cnt += 1
  SET stat = alterlist(orequest->filter,flag_cnt)
  SET orequest->filter[flag_cnt].flag = 118
  SET orequest->filter[flag_cnt].value =  $9
 ENDIF
 IF (( $10 > ""))
  SET flag_cnt += 1
  SET stat = alterlist(orequest->filter,flag_cnt)
  SET orequest->filter[flag_cnt].flag = 160
  SET orequest->filter[flag_cnt].value =  $10
 ENDIF
 SET stat = tdbexecute(3200000,3200041,100041,"REC",orequest,
  "REC",oreply,4)
 SET stat = alterlist(lrequest->encntrs,size(oreply->encounter,5))
 FOR (i = 1 TO size(oreply->encounter,5))
   SET lrequest->encntrs[i].encntr_id = oreply->encounter[i].encounter_id
 ENDFOR
 IF (( $11 > "")
  AND ( $12 > ""))
  SET lrequest->reg_from_dt_tm = cnvtdatetime( $11)
  SET lrequest->reg_to_dt_tm = cnvtdatetime( $12)
 ENDIF
 SET lrequest->encntr_alias_ind =  $13
 SET lrequest->encntr_info_ind =  $14
 SET lrequest->encntr_prsnl_reltn_ind =  $15
 SET stat = tdbexecute(3200000,3200041,3200145,"REC",lrequest,
  "REC",lreply,4)
 IF ((lreply->status_data.status="S"))
  SET out_rec->status = "Success"
 ELSE
  SET out_rec->status = "Failed"
 ENDIF
 SET stat = alterlist(out_rec->encounters,size(lreply->encounter,5))
 FOR (i = 1 TO size(lreply->encounter,5))
   SET out_rec->encounters[i].encounter.accommodation_disp = uar_get_code_display(lreply->encounter[i
    ].encounter.accommodation_cd)
   SET out_rec->encounters[i].encounter.accommodation_mean = uar_get_code_display(lreply->encounter[i
    ].encounter.accommodation_cd)
   SET out_rec->encounters[i].encounter.accommodation_cd = cnvtstring(lreply->encounter[i].encounter.
    accommodation_cd)
   SET out_rec->encounters[i].encounter.accommodation_request_disp = uar_get_code_display(lreply->
    encounter[i].encounter.accommodation_request_cd)
   SET out_rec->encounters[i].encounter.accommodation_request_mean = uar_get_code_display(lreply->
    encounter[i].encounter.accommodation_request_cd)
   SET out_rec->encounters[i].encounter.accommodation_request_cd = cnvtstring(lreply->encounter[i].
    encounter.accommodation_request_cd)
   SET out_rec->encounters[i].encounter.admit_mode_disp = uar_get_code_display(lreply->encounter[i].
    encounter.admit_mode_cd)
   SET out_rec->encounters[i].encounter.admit_mode_mean = uar_get_code_display(lreply->encounter[i].
    encounter.admit_mode_cd)
   SET out_rec->encounters[i].encounter.admit_mode_cd = cnvtstring(lreply->encounter[i].encounter.
    admit_mode_cd)
   SET out_rec->encounters[i].encounter.admit_src_disp = uar_get_code_display(lreply->encounter[i].
    encounter.admit_src_cd)
   SET out_rec->encounters[i].encounter.admit_src_mean = uar_get_code_display(lreply->encounter[i].
    encounter.admit_src_cd)
   SET out_rec->encounters[i].encounter.admit_src_cd = cnvtstring(lreply->encounter[i].encounter.
    admit_src_cd)
   SET out_rec->encounters[i].encounter.admit_type_disp = uar_get_code_display(lreply->encounter[i].
    encounter.admit_type_cd)
   SET out_rec->encounters[i].encounter.admit_type_mean = uar_get_code_display(lreply->encounter[i].
    encounter.admit_type_cd)
   SET out_rec->encounters[i].encounter.admit_type_cd = cnvtstring(lreply->encounter[i].encounter.
    admit_type_cd)
   SET out_rec->encounters[i].encounter.admit_with_medication_disp = uar_get_code_display(lreply->
    encounter[i].encounter.admit_with_medication_cd)
   SET out_rec->encounters[i].encounter.admit_with_medication_mean = uar_get_code_display(lreply->
    encounter[i].encounter.admit_with_medication_cd)
   SET out_rec->encounters[i].encounter.admit_with_medication_cd = cnvtstring(lreply->encounter[i].
    encounter.admit_with_medication_cd)
   SET out_rec->encounters[i].encounter.alt_lvl_care_disp = uar_get_code_display(lreply->encounter[i]
    .encounter.alt_lvl_care_cd)
   SET out_rec->encounters[i].encounter.alt_lvl_care_mean = uar_get_code_display(lreply->encounter[i]
    .encounter.alt_lvl_care_cd)
   SET out_rec->encounters[i].encounter.alt_lvl_care_cd = cnvtstring(lreply->encounter[i].encounter.
    alt_lvl_care_cd)
   SET out_rec->encounters[i].encounter.alt_result_dest_disp = uar_get_code_display(lreply->
    encounter[i].encounter.alt_result_dest_cd)
   SET out_rec->encounters[i].encounter.alt_result_dest_mean = uar_get_code_display(lreply->
    encounter[i].encounter.alt_result_dest_cd)
   SET out_rec->encounters[i].encounter.alt_result_dest_cd = cnvtstring(lreply->encounter[i].
    encounter.alt_result_dest_cd)
   SET out_rec->encounters[i].encounter.ambulatory_cond_disp = uar_get_code_display(lreply->
    encounter[i].encounter.ambulatory_cond_cd)
   SET out_rec->encounters[i].encounter.ambulatory_cond_mean = uar_get_code_display(lreply->
    encounter[i].encounter.ambulatory_cond_cd)
   SET out_rec->encounters[i].encounter.ambulatory_cond_cd = cnvtstring(lreply->encounter[i].
    encounter.ambulatory_cond_cd)
   SET out_rec->encounters[i].encounter.arrive_dt_tm = datetimezoneformat(lreply->encounter[i].
    encounter.arrive_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET out_rec->encounters[i].encounter.bed_disp = uar_get_code_display(lreply->encounter[i].
    encounter.loc_bed_cd)
   SET out_rec->encounters[i].encounter.bed_mean = uar_get_code_display(lreply->encounter[i].
    encounter.loc_bed_cd)
   SET out_rec->encounters[i].encounter.bed_cd = cnvtstring(lreply->encounter[i].encounter.loc_bed_cd
    )
   SET out_rec->encounters[i].encounter.building_disp = uar_get_code_display(lreply->encounter[i].
    encounter.loc_building_cd)
   SET out_rec->encounters[i].encounter.building_mean = uar_get_code_display(lreply->encounter[i].
    encounter.loc_building_cd)
   SET out_rec->encounters[i].encounter.building_cd = cnvtstring(lreply->encounter[i].encounter.
    loc_building_cd)
   SET out_rec->encounters[i].encounter.confid_level_disp = uar_get_code_display(lreply->encounter[i]
    .encounter.confid_level_cd)
   SET out_rec->encounters[i].encounter.confid_level_mean = uar_get_code_display(lreply->encounter[i]
    .encounter.confid_level_cd)
   SET out_rec->encounters[i].encounter.confid_level_cd = cnvtstring(lreply->encounter[i].encounter.
    confid_level_cd)
   SET out_rec->encounters[i].encounter.contributor_system_disp = uar_get_code_display(lreply->
    encounter[i].encounter.contributor_system_cd)
   SET out_rec->encounters[i].encounter.contributor_system_mean = uar_get_code_display(lreply->
    encounter[i].encounter.contributor_system_cd)
   SET out_rec->encounters[i].encounter.contributor_system_cd = cnvtstring(lreply->encounter[i].
    encounter.contributor_system_cd)
   SET out_rec->encounters[i].encounter.courtesy_disp = uar_get_code_display(lreply->encounter[i].
    encounter.courtesy_cd)
   SET out_rec->encounters[i].encounter.courtesy_mean = uar_get_code_display(lreply->encounter[i].
    encounter.courtesy_cd)
   SET out_rec->encounters[i].encounter.courtesy_cd = cnvtstring(lreply->encounter[i].encounter.
    courtesy_cd)
   SET out_rec->encounters[i].encounter.depart_dt_tm = datetimezoneformat(lreply->encounter[i].
    encounter.depart_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET out_rec->encounters[i].encounter.diet_type_disp = uar_get_code_display(lreply->encounter[i].
    encounter.diet_type_cd)
   SET out_rec->encounters[i].encounter.diet_type_mean = uar_get_code_display(lreply->encounter[i].
    encounter.diet_type_cd)
   SET out_rec->encounters[i].encounter.diet_type_cd = cnvtstring(lreply->encounter[i].encounter.
    diet_type_cd)
   SET out_rec->encounters[i].encounter.disch_dt_tm = datetimezoneformat(lreply->encounter[i].
    encounter.disch_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET out_rec->encounters[i].encounter.disch_disposition_disp = uar_get_code_display(lreply->
    encounter[i].encounter.disch_disposition_cd)
   SET out_rec->encounters[i].encounter.disch_disposition_mean = uar_get_code_display(lreply->
    encounter[i].encounter.disch_disposition_cd)
   SET out_rec->encounters[i].encounter.disch_disposition_cd = cnvtstring(lreply->encounter[i].
    encounter.disch_disposition_cd)
   SET out_rec->encounters[i].encounter.disch_to_loctn_disp = uar_get_code_display(lreply->encounter[
    i].encounter.disch_to_loctn_cd)
   SET out_rec->encounters[i].encounter.disch_to_loctn_mean = uar_get_code_display(lreply->encounter[
    i].encounter.disch_to_loctn_cd)
   SET out_rec->encounters[i].encounter.disch_to_loctn_cd = cnvtstring(lreply->encounter[i].encounter
    .disch_to_loctn_cd)
   SET out_rec->encounters[i].encounter.encntr_id = cnvtstring(lreply->encounter[i].encounter.
    encntr_id)
   SET out_rec->encounters[i].encounter.encntr_status_disp = uar_get_code_display(lreply->encounter[i
    ].encounter.encntr_status_cd)
   SET out_rec->encounters[i].encounter.encntr_status_mean = uar_get_code_display(lreply->encounter[i
    ].encounter.encntr_status_cd)
   SET out_rec->encounters[i].encounter.encntr_status_cd = cnvtstring(lreply->encounter[i].encounter.
    encntr_status_cd)
   SET out_rec->encounters[i].encounter.encntr_type_disp = uar_get_code_display(lreply->encounter[i].
    encounter.encntr_type_cd)
   SET out_rec->encounters[i].encounter.encntr_type_mean = uar_get_code_display(lreply->encounter[i].
    encounter.encntr_type_cd)
   SET out_rec->encounters[i].encounter.encntr_type_cd = cnvtstring(lreply->encounter[i].encounter.
    encntr_type_cd)
   SET out_rec->encounters[i].encounter.encntr_type_class_disp = uar_get_code_display(lreply->
    encounter[i].encounter.encntr_type_class_cd)
   SET out_rec->encounters[i].encounter.encntr_type_class_mean = uar_get_code_display(lreply->
    encounter[i].encounter.encntr_type_class_cd)
   SET out_rec->encounters[i].encounter.encntr_type_class_cd = cnvtstring(lreply->encounter[i].
    encounter.encntr_type_class_cd)
   SET out_rec->encounters[i].encounter.est_arrive_dt_tm = datetimezoneformat(lreply->encounter[i].
    encounter.est_arrive_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET out_rec->encounters[i].encounter.est_depart_dt_tm = datetimezoneformat(lreply->encounter[i].
    encounter.est_depart_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET out_rec->encounters[i].encounter.financial_class_disp = uar_get_code_display(lreply->
    encounter[i].encounter.financial_class_cd)
   SET out_rec->encounters[i].encounter.financial_class_mean = uar_get_code_display(lreply->
    encounter[i].encounter.financial_class_cd)
   SET out_rec->encounters[i].encounter.financial_class_cd = cnvtstring(lreply->encounter[i].
    encounter.financial_class_cd)
   SET out_rec->encounters[i].encounter.guarantor_type_disp = uar_get_code_display(lreply->encounter[
    i].encounter.guarantor_type_cd)
   SET out_rec->encounters[i].encounter.guarantor_type_mean = uar_get_code_display(lreply->encounter[
    i].encounter.guarantor_type_cd)
   SET out_rec->encounters[i].encounter.guarantor_type_cd = cnvtstring(lreply->encounter[i].encounter
    .guarantor_type_cd)
   SET out_rec->encounters[i].encounter.isolation_disp = uar_get_code_display(lreply->encounter[i].
    encounter.isolation_cd)
   SET out_rec->encounters[i].encounter.isolation_mean = uar_get_code_display(lreply->encounter[i].
    encounter.isolation_cd)
   SET out_rec->encounters[i].encounter.isolation_cd = cnvtstring(lreply->encounter[i].encounter.
    isolation_cd)
   SET out_rec->encounters[i].encounter.med_service_disp = uar_get_code_display(lreply->encounter[i].
    encounter.med_service_cd)
   SET out_rec->encounters[i].encounter.med_service_mean = uar_get_code_display(lreply->encounter[i].
    encounter.med_service_cd)
   SET out_rec->encounters[i].encounter.med_service_cd = cnvtstring(lreply->encounter[i].encounter.
    med_service_cd)
   SET out_rec->encounters[i].encounter.nurse_unit_disp = uar_get_code_display(lreply->encounter[i].
    encounter.loc_nurse_unit_cd)
   SET out_rec->encounters[i].encounter.nurse_unit_mean = uar_get_code_display(lreply->encounter[i].
    encounter.loc_nurse_unit_cd)
   SET out_rec->encounters[i].encounter.nurse_unit_cd = cnvtstring(lreply->encounter[i].encounter.
    loc_nurse_unit_cd)
   SET out_rec->encounters[i].encounter.organization_id = cnvtstring(lreply->encounter[i].encounter.
    organization_id)
   SET out_rec->encounters[i].encounter.person_id = cnvtstring(lreply->encounter[i].encounter.
    person_id)
   SET out_rec->encounters[i].encounter.preadmit_nbr = lreply->encounter[i].encounter.preadmit_nbr
   SET out_rec->encounters[i].encounter.preadmit_testing_disp = uar_get_code_display(lreply->
    encounter[i].encounter.preadmit_testing_cd)
   SET out_rec->encounters[i].encounter.preadmit_testing_mean = uar_get_code_display(lreply->
    encounter[i].encounter.preadmit_testing_cd)
   SET out_rec->encounters[i].encounter.preadmit_testing_cd = cnvtstring(lreply->encounter[i].
    encounter.preadmit_testing_cd)
   SET out_rec->encounters[i].encounter.pre_reg_dt_tm = datetimezoneformat(lreply->encounter[i].
    encounter.pre_reg_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET out_rec->encounters[i].encounter.pre_reg_prsnl_id = cnvtstring(lreply->encounter[i].encounter.
    pre_reg_prsnl_id)
   SET out_rec->encounters[i].encounter.pre_reg_prsnl_name = lreply->encounter[i].encounter.
   pre_reg_prsnl_name
   SET out_rec->encounters[i].encounter.reason_for_visit = lreply->encounter[i].encounter.
   reason_for_visit
   SET out_rec->encounters[i].encounter.referring_comment = lreply->encounter[i].encounter.
   referring_comment
   SET out_rec->encounters[i].encounter.reg_dt_tm = datetimezoneformat(lreply->encounter[i].encounter
    .reg_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
   SET out_rec->encounters[i].encounter.reg_prsnl_id = cnvtstring(lreply->encounter[i].encounter.
    reg_prsnl_id)
   SET out_rec->encounters[i].encounter.reg_prsnl_name = lreply->encounter[i].encounter.
   reg_prsnl_name
   SET out_rec->encounters[i].encounter.result_dest_disp = uar_get_code_display(lreply->encounter[i].
    encounter.result_dest_cd)
   SET out_rec->encounters[i].encounter.result_dest_mean = uar_get_code_display(lreply->encounter[i].
    encounter.result_dest_cd)
   SET out_rec->encounters[i].encounter.result_dest_cd = cnvtstring(lreply->encounter[i].encounter.
    result_dest_cd)
   SET out_rec->encounters[i].encounter.room_disp = uar_get_code_display(lreply->encounter[i].
    encounter.loc_room_cd)
   SET out_rec->encounters[i].encounter.room_mean = uar_get_code_display(lreply->encounter[i].
    encounter.loc_room_cd)
   SET out_rec->encounters[i].encounter.room_cd = cnvtstring(lreply->encounter[i].encounter.
    loc_room_cd)
   SET out_rec->encounters[i].encounter.temp_location_disp = uar_get_code_display(lreply->encounter[i
    ].encounter.loc_temp_cd)
   SET out_rec->encounters[i].encounter.temp_location_mean = uar_get_code_display(lreply->encounter[i
    ].encounter.loc_temp_cd)
   SET out_rec->encounters[i].encounter.temp_location_cd = cnvtstring(lreply->encounter[i].encounter.
    loc_temp_cd)
   SET out_rec->encounters[i].encounter.vip_disp = uar_get_code_display(lreply->encounter[i].
    encounter.vip_cd)
   SET out_rec->encounters[i].encounter.vip_mean = uar_get_code_display(lreply->encounter[i].
    encounter.vip_cd)
   SET out_rec->encounters[i].encounter.vip_cd = cnvtstring(lreply->encounter[i].encounter.vip_cd)
   IF ((lrequest->encntr_alias_ind=1))
    SET stat = alterlist(out_rec->encounters[i].encntr_alias,size(lreply->encounter[i].encntr_alias,5
      ))
    FOR (j = 1 TO size(lreply->encounter[i].encntr_alias,5))
      SET out_rec->encounters[i].encntr_alias[j].alias = lreply->encounter[i].encntr_alias[j].alias
      SET out_rec->encounters[i].encntr_alias[j].alias_formatted = lreply->encounter[i].encntr_alias[
      j].alias_formatted
      SET out_rec->encounters[i].encntr_alias[j].alias_pool_cd = cnvtstring(lreply->encounter[i].
       encntr_alias[j].alias_pool_cd)
      SET out_rec->encounters[i].encntr_alias[j].alias_pool_disp = lreply->encounter[i].encntr_alias[
      j].alias_pool_disp
      SET out_rec->encounters[i].encntr_alias[j].alias_pool_mean = lreply->encounter[i].encntr_alias[
      j].alias_pool_mean
      SET out_rec->encounters[i].encntr_alias[j].encntr_alias_type_cd = cnvtstring(lreply->encounter[
       i].encntr_alias[j].encntr_alias_type_cd)
      SET out_rec->encounters[i].encntr_alias[j].encntr_alias_type_disp = lreply->encounter[i].
      encntr_alias[j].encntr_alias_type_disp
      SET out_rec->encounters[i].encntr_alias[j].encntr_alias_type_mean = lreply->encounter[i].
      encntr_alias[j].encntr_alias_type_mean
      SET out_rec->encounters[i].encntr_alias[j].encntr_alias_id = cnvtstring(lreply->encounter[i].
       encntr_alias[j].encntr_alias_id)
      SET out_rec->encounters[i].encntr_alias[j].encntr_id = cnvtstring(lreply->encounter[i].
       encntr_alias[j].encntr_id)
    ENDFOR
   ENDIF
   IF ((lrequest->encntr_prsnl_reltn_ind=1))
    SET stat = alterlist(out_rec->encounters[i].encntr_prsnl_reltn,size(lreply->encounter[i].
      encntr_prsnl_reltn,5))
    FOR (j = 1 TO size(lreply->encounter[i].encntr_prsnl_reltn,5))
      SET out_rec->encounters[i].encntr_prsnl_reltn[j].encntr_prsnl_reltn_id = cnvtstring(lreply->
       encounter[i].encntr_prsnl_reltn[j].encntr_prsnl_reltn_id)
      SET out_rec->encounters[i].encntr_prsnl_reltn[j].encntr_id = cnvtstring(lreply->encounter[i].
       encntr_prsnl_reltn[j].encntr_id)
      SET out_rec->encounters[i].encntr_prsnl_reltn[j].expiration_ind = cnvtstring(lreply->encounter[
       i].encntr_prsnl_reltn[j].expiration_ind)
      SET out_rec->encounters[i].encntr_prsnl_reltn[j].ft_prsnl_name = lreply->encounter[i].
      encntr_prsnl_reltn[j].ft_prsnl_name
      SET out_rec->encounters[i].encntr_prsnl_reltn[j].prsnl_name = lreply->encounter[i].
      encntr_prsnl_reltn[j].prsnl_name
      SET out_rec->encounters[i].encntr_prsnl_reltn[j].prsnl_person_id = cnvtstring(lreply->
       encounter[i].encntr_prsnl_reltn[j].prsnl_person_id)
      SET out_rec->encounters[i].encntr_prsnl_reltn[j].encntr_prsnl_r_cd = cnvtstring(lreply->
       encounter[i].encntr_prsnl_reltn[j].encntr_prsnl_r_cd)
      SET out_rec->encounters[i].encntr_prsnl_reltn[j].encntr_prsnl_r_disp = lreply->encounter[i].
      encntr_prsnl_reltn[j].encntr_prsnl_r_disp
      SET out_rec->encounters[i].encntr_prsnl_reltn[j].encntr_prsnl_r_mean = lreply->encounter[i].
      encntr_prsnl_reltn[j].encntr_prsnl_r_mean
    ENDFOR
   ENDIF
   IF ((lrequest->encntr_info_ind=1))
    SET stat = alterlist(out_rec->encounters[i].encntr_info,size(lreply->encounter[i].encntr_info,5))
    FOR (j = 1 TO size(lreply->encounter[i].encntr_info,5))
      SET out_rec->encounters[i].encntr_info[j].chartable_ind = cnvtstring(lreply->encounter[i].
       encntr_info[j].chartable_ind)
      SET out_rec->encounters[i].encntr_info[j].encntr_id = cnvtstring(lreply->encounter[i].
       encntr_info[j].encntr_id)
      SET out_rec->encounters[i].encntr_info[j].encntr_info_id = cnvtstring(lreply->encounter[i].
       encntr_info[j].encntr_info_id)
      SET out_rec->encounters[i].encntr_info[j].info_type_cd = cnvtstring(lreply->encounter[i].
       encntr_info[j].info_type_cd)
      SET out_rec->encounters[i].encntr_info[j].info_type_disp = lreply->encounter[i].encntr_info[j].
      info_type_disp
      SET out_rec->encounters[i].encntr_info[j].info_type_mean = lreply->encounter[i].encntr_info[j].
      info_type_mean
      SET out_rec->encounters[i].encntr_info[j].info_sub_type_cd = cnvtstring(lreply->encounter[i].
       encntr_info[j].info_sub_type_cd)
      SET out_rec->encounters[i].encntr_info[j].info_sub_type_disp = lreply->encounter[i].
      encntr_info[j].info_sub_type_disp
      SET out_rec->encounters[i].encntr_info[j].info_sub_type_mean = lreply->encounter[i].
      encntr_info[j].info_sub_type_mean
      SET out_rec->encounters[i].encntr_info[j].long_text = lreply->encounter[i].encntr_info[j].
      long_text
      SET out_rec->encounters[i].encntr_info[j].long_text_id = cnvtstring(lreply->encounter[i].
       encntr_info[j].long_text_id)
      SET out_rec->encounters[i].encntr_info[j].value_dt_tm = datetimezoneformat(lreply->encounter[i]
       .encntr_info[j].value_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
      SET out_rec->encounters[i].encntr_info[j].value_numeric = cnvtstring(lreply->encounter[i].
       encntr_info[j].value_numeric)
      SET out_rec->encounters[i].encntr_info[j].value_cd = cnvtstring(lreply->encounter[i].
       encntr_info[j].value_cd)
      SET out_rec->encounters[i].encntr_info[j].value_disp = lreply->encounter[i].encntr_info[j].
      value_disp
      SET out_rec->encounters[i].encntr_info[j].value_mean = lreply->encounter[i].encntr_info[j].
      value_mean
    ENDFOR
   ENDIF
 ENDFOR
 EXECUTE bhs_athn_write_json_output
END GO
