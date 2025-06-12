CREATE PROGRAM co_ops_create_icu_rec:dba
 RECORD reply(
   1 count_ra_records_created = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD icu_request(
   1 encntr_id = f8
 )
 RECORD icu_reply(
   1 location_list[*]
     2 location_disp = vc
     2 location_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD loc_request(
   1 location_cd = f8
   1 search_depth = i4
 )
 RECORD child_loc_record(
   1 qual[*]
     2 level = i4
     2 parent_loc_cd = f8
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD pat_for_beds_req_record(
   1 bedlist[*]
     2 unit_cd = f8
     2 room_cd = f8
     2 bed_cd = f8
 )
 RECORD pat_for_beds_reply_record(
   1 bedlist[*]
     2 unit_cd = f8
     2 room_cd = f8
     2 bed_cd = f8
     2 person_id = f8
     2 encntr_id = f8
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD icu_admit_dt_tm_request(
   1 encntr_list[*]
     2 encntr_id = f8
 )
 RECORD icu_admit_dt_tm_reply(
   1 encntr_list[*]
     2 encntr_id = f8
     2 icu_transfer_in_dt_tm = dq8
 )
 RECORD new_encntr_list_record(
   1 encntr_list[*]
     2 encntr_id = f8
     2 person_id = f8
     2 admit_unit_cd = f8
     2 icu_admit_dt_tm = dq8
     2 cc_end_of_day1 = dq8
     2 bed_count = i2
     2 hosp_admit_dt_tm = dq8
     2 region_flag = i2
     2 teach_type_flag = i2
     2 admit_age = i4
     2 gender_flag = i2
     2 birth_dt_tm = dq8
 )
 RECORD temp_new_encntr_list_record(
   1 encntr_list[*]
     2 encntr_id = f8
     2 person_id = f8
     2 admit_unit_cd = f8
     2 icu_admit_dt_tm = dq8
     2 cc_end_of_day1 = dq8
     2 bed_count = i2
     2 hosp_admit_dt_tm = dq8
     2 region_flag = i2
     2 teach_type_flag = i2
     2 admit_age = i4
     2 gender_flag = i2
     2 birth_dt_tm = dq8
 )
 RECORD ra_request(
   1 reclist[*]
     2 admitsource_flag = i2
     2 admit_age = i4
     2 admit_diagnosis = vc
     2 admit_icu_cd = f8
     2 admit_source = vc
     2 adm_doc_id = f8
     2 aids_ind = i2
     2 ami_location = vc
     2 bed_count = i4
     2 body_system = vc
     2 cc_during_stay_ind = i2
     2 chronic_health_none_ind = i2
     2 chronic_health_unavail_ind = i2
     2 cirrhosis_ind = i2
     2 copd_flag = i2
     2 copd_ind = i2
     2 diabetes_ind = i2
     2 dialysis_ind = i2
     2 diedinhospital_ind = i2
     2 diedinicu_ind = i2
     2 discharge_location_cd = f8
     2 disease_category_cd = f8
     2 ejectfx_fraction = f8
     2 electivesurgery_ind = i2
     2 encntr_id = f8
     2 gender_flag = i2
     2 hepaticfailure_ind = i2
     2 hosp_admit_dt_tm = dq8
     2 hrs_at_source = i4
     2 icu_admit_dt_tm = dq8
     2 icu_disch_dt_tm = dq8
     2 ima_ind = i2
     2 immunosuppression_ind = i2
     2 leukemia_ind = i2
     2 lymphoma_ind = i2
     2 med_service_cd = f8
     2 metastaticcancer_ind = i2
     2 midur_ind = i2
     2 mi_within_6mo_ind = i2
     2 nbr_grafts_performed = i4
     2 person_id = f8
     2 ptca_device = vc
     2 readmit_ind = i2
     2 readmit_within_24hr_ind = i2
     2 region_flag = i2
     2 risk_adjustment_id = f8
     2 sv_graft_ind = i2
     2 teach_type_flag = i2
     2 therapy_level = i4
     2 thrombolytics_ind = i2
     2 xfer_within_48hr_ind = i2
     2 var03hspxlos_value = f8
     2 valid_from_dt_tm = dq8
     2 valid_until_dt_tm = dq8
 )
 RECORD ra_reply(
   1 reclist[*]
     2 risk_adjustment_id = f8
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD rad_request(
   1 reclist[*]
     2 activetx_ind = i2
     2 albumin_ce_id = f8
     2 apache_iii_score = i4
     2 apache_ii_score = i4
     2 aps_day1 = i4
     2 aps_score = i4
     2 aps_yesterday = i4
     2 bilirubin_ce_id = f8
     2 bun_ce_id = f8
     2 cc_beg_dt_tm = dq8
     2 cc_day = i4
     2 cc_end_dt_tm = dq8
     2 creatinine_ce_id = f8
     2 eyes_ce_id = f8
     2 fio2_ce_id = f8
     2 glucose_ce_id = f8
     2 heartrate_ce_id = f8
     2 hematocrit_ce_id = f8
     2 intubated_ce_id = f8
     2 intubated_ind = i2
     2 mean_blood_pressure = f8
     2 meds_ce_id = f8
     2 meds_ind = i2
     2 motor_ce_id = f8
     2 outcome_status = i4
     2 pao2_ce_id = f8
     2 pa_line_today_ind = i2
     2 pco2_ce_id = f8
     2 phys_res_pts = i4
     2 ph_ce_id = f8
     2 potassium_ce_id = f8
     2 resp_ce_id = f8
     2 risk_adjustment_id = f8
     2 risk_adjustment_day_id = f8
     2 sodium_ce_id = f8
     2 temp_ce_id = f8
     2 urine_24hr_output = f8
     2 urine_output = f8
     2 vent_ind = i2
     2 vent_today_ind = i2
     2 verbal_ce_id = f8
     2 wbc_ce_id = f8
     2 worst_albumin_result = f8
     2 worst_bilirubin_result = f8
     2 worst_bun_result = f8
     2 worst_creatinine_result = f8
     2 worst_fio2_result = f8
     2 worst_gcs_eye_score = i4
     2 worst_gcs_motor_score = i4
     2 worst_gcs_verbal_score = i4
     2 worst_glucose_result = f8
     2 worst_heart_rate = f8
     2 worst_hematocrit = f8
     2 worst_pao2_result = f8
     2 worst_pco2_result = f8
     2 worst_ph_result = f8
     2 worst_potassium_result = f8
     2 worst_resp_result = f8
     2 worst_sodium_result = f8
     2 worst_temp = f8
     2 worst_wbc_result = f8
     2 valid_from_dt_tm = dq8
     2 valid_until_dt_tm = dq8
 )
 RECORD rad_reply(
   1 reclist[*]
     2 risk_adjustment_day_id = f8
     2 risk_adjustment_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD cc_day_request(
   1 reclist[*]
     2 risk_adjustment_id = f8
     2 last_cc_end_dt_tm = dq8
     2 last_cc_day = i4
     2 ignore_flag = i2
     2 numrecs_rad = i4
 )
 RECORD cc_day_reply(
   1 reclist[*]
     2 risk_adjustment_id = f8
     2 risk_adjustment_day_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD pred_request(
   1 person_id = f8
   1 encntr_id = f8
   1 cc_start_day = i2
   1 icu_admit_dt_tm = dq8
 )
 RECORD pred_reply(
   1 recalc_days = i4
   1 risk_adjustment_day_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE indx = i2
 DECLARE person_id = f8
 DECLARE encntr_id = f8
 DECLARE discharge_date_time = dq8
 DECLARE req_index = i2
 DECLARE unset_date = vc WITH constant("31-DEC-2100 00:00:00:00")
 DECLARE nbr = i4
 DECLARE sfailed = c2 WITH private, noconstant("S")
 SET reply->count_ra_records_created = 0
 EXECUTE dcp_get_apache_icus  WITH replace("REQUEST","ICU_REQUEST"), replace("REPLY","ICU_REPLY")
 IF ((icu_reply->status_data.status != "S"))
  SET sfailed = "F"
  CALL set_reply_status(icu_reply->status_data.status,icu_reply->status_data.subeventstatus[1].
   operationname,icu_reply->status_data.subeventstatus[1].operationstatus,icu_reply->status_data.
   subeventstatus[1].targetobjectname,icu_reply->status_data.subeventstatus[1].targetobjectvalue)
  GO TO exit_script
 ENDIF
 SET icu_size = size(icu_reply->location_list,5)
 SET cnt = 0
 FOR (indx = 1 TO icu_size)
   SET loc_request->location_cd = icu_reply->location_list[indx].location_cd
   SET loc_request->search_depth = 3
   EXECUTE dcp_get_child_locations  WITH replace("REQUEST","LOC_REQUEST"), replace("REPLY",
    "CHILD_LOC_RECORD")
   SET level = 2
   SET bed_level_pos = 1
   SET nbr = 0
   SET location = loc_request->location_cd
   SET loc_size = size(child_loc_record->qual,5)
   WHILE (bed_level_pos > 0
    AND bed_level_pos < loc_size)
    SET bed_level_pos = locateval(nbr,(bed_level_pos+ 1),loc_size,level,child_loc_record->qual[nbr].
     level)
    IF (bed_level_pos > 0)
     SET cnt = (cnt+ 1)
     SET stat = alterlist(pat_for_beds_req_record->bedlist,cnt)
     SET pat_for_beds_req_record->bedlist[cnt].unit_cd = loc_request->location_cd
     SET pat_for_beds_req_record->bedlist[cnt].room_cd = child_loc_record->qual[bed_level_pos].
     parent_loc_cd
     SET pat_for_beds_req_record->bedlist[cnt].bed_cd = child_loc_record->qual[bed_level_pos].
     location_cd
    ENDIF
   ENDWHILE
 ENDFOR
 EXECUTE co_get_patients_for_beds  WITH replace("REQUEST","PAT_FOR_BEDS_REQ_RECORD"), replace("REPLY",
  "PAT_FOR_BEDS_REPLY_RECORD")
 IF ((pat_for_beds_reply_record->status_data.status != "S"))
  SET sfailed = "F"
  CALL set_reply_status(pat_for_beds_reply_record->status_data.status,pat_for_beds_reply_record->
   status_data.subeventstatus[1].operationname,pat_for_beds_reply_record->status_data.subeventstatus[
   1].operationstatus,pat_for_beds_reply_record->status_data.subeventstatus[1].targetobjectname,
   pat_for_beds_reply_record->status_data.subeventstatus[1].targetobjectvalue)
  GO TO exit_script
 ENDIF
 SET indx = 0
 SET cnt = 0
 SET list_size = size(pat_for_beds_reply_record->bedlist,5)
 FOR (indx = 1 TO list_size)
   IF ((pat_for_beds_reply_record->bedlist[indx].encntr_id > 0)
    AND (pat_for_beds_reply_record->bedlist[indx].reg_dt_tm > 0))
    SET cnt = (cnt+ 1)
    SET stat = alterlist(icu_admit_dt_tm_request->encntr_list,cnt)
    SET icu_admit_dt_tm_request->encntr_list[cnt].encntr_id = pat_for_beds_reply_record->bedlist[indx
    ].encntr_id
   ENDIF
 ENDFOR
 SET act_size = size(icu_admit_dt_tm_request->encntr_list,5)
 IF (act_size <= 0)
  SET reply->status_data.subeventstatus[1].operationname = "execute"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CO_GET_PATIENTS_FOR_BEDS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "No patients with location/room/bed list"
  GO TO exit_script
 ENDIF
 EXECUTE co_calc_loc_admit_dt  WITH replace("REQUEST","ICU_ADMIT_DT_TM_REQUEST"), replace("REPLY",
  "ICU_ADMIT_DT_TM_REPLY")
 SET encntr_list_size = size(icu_admit_dt_tm_reply->encntr_list,5)
 SET nbr = 0
 SET nbr_cnt = 0
 SET cnt = 0
 SET stat = alterlist(new_encntr_list_record->encntr_list,encntr_list_size)
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE expand(nbr,1,encntr_list_size,e.encntr_id,icu_admit_dt_tm_reply->encntr_list[nbr].encntr_id)
    AND  NOT ( EXISTS (
   (SELECT
    ra.encntr_id
    FROM risk_adjustment ra
    WHERE e.encntr_id=ra.encntr_id
     AND expand(nbr_cnt,1,encntr_list_size,ra.encntr_id,icu_admit_dt_tm_reply->encntr_list[nbr_cnt].
     encntr_id)
     AND ra.active_ind=1))))
  HEAD REPORT
   cnt = 0, pos = 0
  DETAIL
   cnt = (cnt+ 1), new_encntr_list_record->encntr_list[cnt].person_id = e.person_id,
   new_encntr_list_record->encntr_list[cnt].encntr_id = e.encntr_id,
   new_encntr_list_record->encntr_list[cnt].admit_unit_cd = e.loc_nurse_unit_cd, pos = locateval(nbr,
    1,encntr_list_size,e.encntr_id,icu_admit_dt_tm_reply->encntr_list[nbr].encntr_id)
   IF (pos > 0)
    new_encntr_list_record->encntr_list[cnt].icu_admit_dt_tm = icu_admit_dt_tm_reply->encntr_list[pos
    ].icu_transfer_in_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  PLAN (ra
   WHERE expand(nbr,1,encntr_list_size,ra.encntr_id,icu_admit_dt_tm_reply->encntr_list[nbr].encntr_id
    )
    AND ra.active_ind=1)
  ORDER BY ra.encntr_id, ra.icu_admit_dt_tm DESC
  HEAD ra.encntr_id
   pos = locateval(nbr,1,encntr_list_size,ra.encntr_id,icu_admit_dt_tm_reply->encntr_list[nbr].
    encntr_id)
   IF (pos > 0)
    new_icu_admit_dt_tm = icu_admit_dt_tm_reply->encntr_list[pos].icu_transfer_in_dt_tm,
    icu_discharge_date = nullval(ra.icu_disch_dt_tm,cnvtdatetime(value(unset_date)))
    IF (icu_discharge_date != cnvtdatetime(value(unset_date))
     AND cnvtdatetime(ra.icu_disch_dt_tm) < cnvtdatetime(new_icu_admit_dt_tm))
     cnt = (cnt+ 1), new_encntr_list_record->encntr_list[cnt].person_id = ra.person_id,
     new_encntr_list_record->encntr_list[cnt].encntr_id = ra.encntr_id,
     new_encntr_list_record->encntr_list[cnt].admit_unit_cd = ra.admit_icu_cd, new_encntr_list_record
     ->encntr_list[cnt].icu_admit_dt_tm = new_icu_admit_dt_tm
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET sfailed = "Z"
  GO TO check_for_ra_without_rad_data
 ENDIF
 SET list_size = size(new_encntr_list_record->encntr_list,5)
 SET num = 0
 SET num_cnt = 0
 SET gender = - (1)
 SET male_cd = meaning_code(57,"MALE")
 SET female_cd = meaning_code(57,"FEMALE")
 SELECT INTO "nl:"
  FROM person p
  PLAN (p
   WHERE expand(num,1,list_size,p.person_id,new_encntr_list_record->encntr_list[num].person_id)
    AND p.active_ind=1)
  ORDER BY p.person_id
  DETAIL
   pos = locateval(num,1,list_size,p.person_id,new_encntr_list_record->encntr_list[num].person_id)
   IF (pos > 0)
    IF (p.sex_cd=male_cd)
     gender = 0
    ELSEIF (p.sex_cd=female_cd)
     gender = 1
    ENDIF
    new_encntr_list_record->encntr_list[num].birth_dt_tm = p.birth_dt_tm, new_encntr_list_record->
    encntr_list[num].gender_flag = gender
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(new_encntr_list_record->encntr_list,cnt)
 SET num_new_ra_to_add = size(new_encntr_list_record->encntr_list,5)
 SET stat = alterlist(temp_new_encntr_list_record->encntr_list,cnt)
 SET stat = movereclist(new_encntr_list_record->encntr_list,temp_new_encntr_list_record->encntr_list,
  1,1,num_new_ra_to_add,
  0)
 SET stat = alterlist(new_encntr_list_record->encntr_list,0)
 SELECT INTO "nl:"
  FROM encounter e,
   risk_adjustment_ref rar
  PLAN (e
   WHERE expand(nbr,1,num_new_ra_to_add,e.person_id,temp_new_encntr_list_record->encntr_list[nbr].
    person_id))
   JOIN (rar
   WHERE (rar.organization_id=(e.organization_id+ 0))
    AND rar.active_ind=1)
  ORDER BY e.encntr_id
  HEAD REPORT
   cnt = 0, pos = 0
  DETAIL
   pos = locateval(nbr,1,num_new_ra_to_add,e.encntr_id,temp_new_encntr_list_record->encntr_list[nbr].
    encntr_id)
   IF (pos > 0)
    cc_day_start_time = rar.icu_day_start_time, cnt = (cnt+ 1), stat = alterlist(
     new_encntr_list_record->encntr_list,cnt),
    icu_admit_dt_tm = temp_new_encntr_list_record->encntr_list[pos].icu_admit_dt_tm, end_day1_date =
    cnvtdate(icu_admit_dt_tm), end_day1_dt_tm = cnvtdatetime(end_day1_date,cc_day_start_time),
    end_day1_dt_tm = datetimeadd(end_day1_dt_tm,- ((1.0/ 1440.0)))
    IF (datetimediff(cnvtdatetime(end_day1_dt_tm),cnvtdatetime(icu_admit_dt_tm)) < 0)
     end_day1_dt_tm = datetimeadd(end_day1_dt_tm,1)
    ENDIF
    IF (datetimediff(end_day1_dt_tm,icu_admit_dt_tm,3) < 8)
     end_day1_dt_tm = datetimeadd(end_day1_dt_tm,1)
    ENDIF
    new_encntr_list_record->encntr_list[cnt].person_id = temp_new_encntr_list_record->encntr_list[pos
    ].person_id, new_encntr_list_record->encntr_list[cnt].encntr_id = temp_new_encntr_list_record->
    encntr_list[pos].encntr_id, new_encntr_list_record->encntr_list[cnt].admit_unit_cd =
    temp_new_encntr_list_record->encntr_list[pos].admit_unit_cd,
    new_encntr_list_record->encntr_list[cnt].icu_admit_dt_tm = temp_new_encntr_list_record->
    encntr_list[pos].icu_admit_dt_tm, new_encntr_list_record->encntr_list[cnt].cc_end_of_day1 =
    end_day1_dt_tm, new_encntr_list_record->encntr_list[cnt].hosp_admit_dt_tm = e.reg_dt_tm,
    new_encntr_list_record->encntr_list[cnt].bed_count = rar.bed_count, new_encntr_list_record->
    encntr_list[cnt].region_flag = rar.region_flag, new_encntr_list_record->encntr_list[cnt].
    teach_type_flag = rar.teach_type_flag,
    age_in_years = apache_age(temp_new_encntr_list_record->encntr_list[pos].birth_dt_tm,e.reg_dt_tm),
    new_encntr_list_record->encntr_list[cnt].admit_age = age_in_years, new_encntr_list_record->
    encntr_list[cnt].gender_flag = temp_new_encntr_list_record->encntr_list[pos].gender_flag
   ENDIF
  WITH nocounter
 ;end select
 SET num_new_ra_to_add = size(new_encntr_list_record->encntr_list,5)
 IF (num_new_ra_to_add <= 0)
  SET sfailed = "Z"
  GO TO check_for_ra_without_rad_data
 ENDIF
 RECORD default_ra_record(
   1 reclist[*]
     2 admitsource_flag = i2
     2 admit_age = i4
     2 admit_diagnosis = vc
     2 admit_icu_cd = f8
     2 admit_source = vc
     2 adm_doc_id = f8
     2 aids_ind = i2
     2 ami_location = vc
     2 bed_count = i4
     2 body_system = vc
     2 cc_during_stay_ind = i2
     2 chronic_health_none_ind = i2
     2 chronic_health_unavail_ind = i2
     2 cirrhosis_ind = i2
     2 copd_flag = i2
     2 copd_ind = i2
     2 diabetes_ind = i2
     2 dialysis_ind = i2
     2 diesinhospital_ind = i2
     2 diedinicu_ind = i2
     2 discharge_location_cd = f8
     2 disease_category_cd = f8
     2 ejectfx_fraction = f8
     2 electivesurgery_ind = i2
     2 encntr_id = f8
     2 gender_flag = i2
     2 hepaticfailure_ind = i2
     2 hosp_admit_dt_tm = dq8
     2 hrs_at_source = i4
     2 icu_admit_dt_tm = dq8
     2 icu_disch_dt_tm = dq8
     2 ima_ind = i2
     2 immunosuppression_ind = i2
     2 leukemia_ind = i2
     2 lymphoma_ind = i2
     2 med_service_cd = f8
     2 metastaticcancer_ind = i2
     2 midur_ind = i2
     2 mi_within_6mo_ind = i2
     2 nbr_grafts_performed = i4
     2 person_id = f8
     2 ptca_device = vc
     2 readmit_ind = i2
     2 readmit_within_24hr_ind = i2
     2 region_flag = i2
     2 risk_adjustment_id = f8
     2 sv_graft_ind = i2
     2 teach_type_flag = i2
     2 therapy_level = i4
     2 thrombolytics_ind = i2
     2 xfer_within_48hr_ind = i2
     2 var03hspxlos_value = f8
     2 valid_from_dt_tm = dq8
     2 valid_until_dt_tm = dq8
 )
 RECORD default_rad_record(
   1 reclist[*]
     2 activetx_ind = i2
     2 albumin_ce_id = f8
     2 apache_iii_score = i4
     2 apache_ii_score = i4
     2 aps_day1 = i4
     2 aps_score = i4
     2 aps_yesterday = i4
     2 bilirubin_ce_id = f8
     2 bun_ce_id = f8
     2 cc_beg_dt_tm = dq8
     2 cc_day = i4
     2 cc_end_dt_tm = dq8
     2 creatinine_ce_id = f8
     2 eyes_ce_id = f8
     2 fio2_ce_id = f8
     2 glucose_ce_id = f8
     2 heartrate_ce_id = f8
     2 hematocrit_ce_id = f8
     2 intubated_ce_id = f8
     2 intubated_ind = i2
     2 mean_blood_pressure = f8
     2 meds_ce_id = f8
     2 meds_ind = i2
     2 motor_ce_id = f8
     2 outcome_status = i4
     2 pao2_ce_id = f8
     2 pa_line_today_ind = i2
     2 pco2_ce_id = f8
     2 phys_res_pts = i4
     2 ph_ce_id = f8
     2 potassium_ce_id = f8
     2 resp_ce_id = f8
     2 risk_adjustment_id = f8
     2 risk_adjustment_day_id = f8
     2 sodium_ce_id = f8
     2 temp_ce_id = f8
     2 urine_24hr_output = f8
     2 urine_output = f8
     2 vent_ind = i2
     2 vent_today_ind = i2
     2 verbal_ce_id = f8
     2 wbc_ce_id = f8
     2 worst_albumin_result = f8
     2 worst_bilirubin_result = f8
     2 worst_bun_result = f8
     2 worst_creatinine_result = f8
     2 worst_fio2_result = f8
     2 worst_gcs_eye_score = i4
     2 worst_gcs_motor_score = i4
     2 worst_gcs_verbal_score = i4
     2 worst_glucose_result = f8
     2 worst_heart_rate = f8
     2 worst_hematocrit = f8
     2 worst_pao2_result = f8
     2 worst_pco2_result = f8
     2 worst_ph_result = f8
     2 worst_potassium_result = f8
     2 worst_resp_result = f8
     2 worst_sodium_result = f8
     2 worst_temp = f8
     2 worst_wbc_result = f8
     2 valid_from_dt_tm = dq8
     2 valid_until_dt_tm = dq8
 )
 SET stat = alterlist(default_rad_record->reclist,1)
 SET default_rad_record->reclist[1].activetx_ind = - (1)
 SET default_rad_record->reclist[1].albumin_ce_id = 0
 SET default_rad_record->reclist[1].apache_iii_score = - (1)
 SET default_rad_record->reclist[1].apache_ii_score = - (1)
 SET default_rad_record->reclist[1].aps_day1 = - (1)
 SET default_rad_record->reclist[1].aps_score = - (1)
 SET default_rad_record->reclist[1].aps_yesterday = - (1)
 SET default_rad_record->reclist[1].bilirubin_ce_id = 0
 SET default_rad_record->reclist[1].bun_ce_id = 0
 SET default_rad_record->reclist[1].creatinine_ce_id = 0
 SET default_rad_record->reclist[1].eyes_ce_id = 0
 SET default_rad_record->reclist[1].fio2_ce_id = 0
 SET default_rad_record->reclist[1].glucose_ce_id = 0
 SET default_rad_record->reclist[1].heartrate_ce_id = 0
 SET default_rad_record->reclist[1].hematocrit_ce_id = 0
 SET default_rad_record->reclist[1].intubated_ce_id = 0
 SET default_rad_record->reclist[1].intubated_ind = - (1)
 SET default_rad_record->reclist[1].mean_blood_pressure = - (1)
 SET default_rad_record->reclist[1].meds_ce_id = 0
 SET default_rad_record->reclist[1].meds_ind = - (1)
 SET default_rad_record->reclist[1].motor_ce_id = 0
 SET default_rad_record->reclist[1].outcome_status = - (1)
 SET default_rad_record->reclist[1].pao2_ce_id = 0
 SET default_rad_record->reclist[1].pa_line_today_ind = - (1)
 SET default_rad_record->reclist[1].pco2_ce_id = 0
 SET default_rad_record->reclist[1].phys_res_pts = - (1)
 SET default_rad_record->reclist[1].resp_ce_id = 0
 SET default_rad_record->reclist[1].ph_ce_id = 0
 SET default_rad_record->reclist[1].potassium_ce_id = 0
 SET default_rad_record->reclist[1].sodium_ce_id = 0
 SET default_rad_record->reclist[1].temp_ce_id = 0
 SET default_rad_record->reclist[1].urine_24hr_output = - (1)
 SET default_rad_record->reclist[1].urine_output = - (1)
 SET default_rad_record->reclist[1].vent_ind = - (1)
 SET default_rad_record->reclist[1].vent_today_ind = - (1)
 SET default_rad_record->reclist[1].verbal_ce_id = 0
 SET default_rad_record->reclist[1].wbc_ce_id = 0
 SET default_rad_record->reclist[1].worst_albumin_result = - (1)
 SET default_rad_record->reclist[1].worst_bilirubin_result = - (1)
 SET default_rad_record->reclist[1].worst_bun_result = - (1)
 SET default_rad_record->reclist[1].worst_creatinine_result = - (1)
 SET default_rad_record->reclist[1].worst_fio2_result = - (1)
 SET default_rad_record->reclist[1].worst_gcs_eye_score = - (1)
 SET default_rad_record->reclist[1].worst_gcs_motor_score = - (1)
 SET default_rad_record->reclist[1].worst_gcs_verbal_score = - (1)
 SET default_rad_record->reclist[1].worst_glucose_result = - (1)
 SET default_rad_record->reclist[1].worst_heart_rate = - (1)
 SET default_rad_record->reclist[1].worst_hematocrit = - (1)
 SET default_rad_record->reclist[1].worst_pao2_result = - (1)
 SET default_rad_record->reclist[1].worst_pco2_result = - (1)
 SET default_rad_record->reclist[1].worst_ph_result = - (1)
 SET default_rad_record->reclist[1].worst_potassium_result = - (1)
 SET default_rad_record->reclist[1].worst_resp_result = - (1)
 SET default_rad_record->reclist[1].worst_sodium_result = - (1)
 SET default_rad_record->reclist[1].worst_temp = - (1)
 SET default_rad_record->reclist[1].worst_wbc_result = - (1)
 SET default_rad_record->reclist[1].valid_from_dt_tm = cnvtdatetime(curdate,curtime3)
 SET default_rad_record->reclist[1].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
 SET stat = alterlist(default_ra_record->reclist,1)
 SET default_ra_record->reclist[1].admitsource_flag = 0
 SET default_ra_record->reclist[1].admit_age = 0
 SET default_ra_record->reclist[1].admit_diagnosis = ""
 SET default_ra_record->reclist[1].admit_icu_cd = - (1)
 SET default_ra_record->reclist[1].admit_source = ""
 SET default_ra_record->reclist[1].adm_doc_id = 0
 SET default_ra_record->reclist[1].aids_ind = 0
 SET default_ra_record->reclist[1].ami_location = ""
 SET default_ra_record->reclist[1].body_system = ""
 SET default_ra_record->reclist[1].cc_during_stay_ind = - (1)
 SET default_ra_record->reclist[1].chronic_health_none_ind = 0
 SET default_ra_record->reclist[1].chronic_health_unavail_ind = 0
 SET default_ra_record->reclist[1].cirrhosis_ind = 0
 SET default_ra_record->reclist[1].copd_flag = 0
 SET default_ra_record->reclist[1].copd_ind = 0
 SET default_ra_record->reclist[1].diabetes_ind = 0
 SET default_ra_record->reclist[1].dialysis_ind = - (1)
 SET default_ra_record->reclist[1].diesinhospital_ind = - (1)
 SET default_ra_record->reclist[1].diedinicu_ind = - (1)
 SET default_ra_record->reclist[1].discharge_location_cd = - (1)
 SET default_ra_record->reclist[1].disease_category_cd = - (1)
 SET default_ra_record->reclist[1].ejectfx_fraction = - (1)
 SET default_ra_record->reclist[1].electivesurgery_ind = - (1)
 SET default_ra_record->reclist[1].gender_flag = - (1)
 SET default_ra_record->reclist[1].hepaticfailure_ind = 0
 SET default_ra_record->reclist[1].hrs_at_source = - (1)
 SET default_ra_record->reclist[1].icu_disch_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
 SET default_ra_record->reclist[1].ima_ind = - (1)
 SET default_ra_record->reclist[1].immunosuppression_ind = 0
 SET default_ra_record->reclist[1].leukemia_ind = 0
 SET default_ra_record->reclist[1].lymphoma_ind = 0
 SET default_ra_record->reclist[1].med_service_cd = - (1)
 SET default_ra_record->reclist[1].metastaticcancer_ind = 0
 SET default_ra_record->reclist[1].midur_ind = - (1)
 SET default_ra_record->reclist[1].mi_within_6mo_ind = - (1)
 SET default_ra_record->reclist[1].nbr_grafts_performed = - (1)
 SET default_ra_record->reclist[1].ptca_device = ""
 SET default_ra_record->reclist[1].readmit_ind = 0
 SET default_ra_record->reclist[1].readmit_within_24hr_ind = - (1)
 SET default_ra_record->reclist[1].sv_graft_ind = - (1)
 SET default_ra_record->reclist[1].therapy_level = - (1)
 SET default_ra_record->reclist[1].thrombolytics_ind = - (1)
 SET default_ra_record->reclist[1].xfer_within_48hr_ind = - (1)
 SET default_ra_record->reclist[1].var03hspxlos_value = 0
 SET default_ra_record->reclist[1].valid_from_dt_tm = cnvtdatetime(curdate,curtime3)
 SET default_ra_record->reclist[1].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
 SET stat = alterlist(ra_request->reclist,num_new_ra_to_add)
 SET stat = alterlist(rad_request->reclist,num_new_ra_to_add)
 SET stat = alterlist(cc_day_request->reclist,num_new_ra_to_add)
 SET indx = 0
 SET stat = movereclist(default_ra_record->reclist,ra_request->reclist,1,1,1,
  0)
 SET stat = movereclist(default_rad_record->reclist,rad_request->reclist,1,1,1,
  0)
 SET stat = movereclist(ra_request->reclist,ra_request->reclist,1,2,(num_new_ra_to_add - 1),
  0)
 SET stat = movereclist(rad_request->reclist,rad_request->reclist,1,2,(num_new_ra_to_add - 1),
  0)
 FOR (indx = 1 TO num_new_ra_to_add)
   SET cc_end_day1 = new_encntr_list_record->encntr_list[indx].cc_end_of_day1
   SET abc = fillstring(20," ")
   SET abc2 = fillstring(20," ")
   SET abc = format(new_encntr_list_record->encntr_list[indx].icu_admit_dt_tm,"dd-mmm-yyyy hh:mm;;d")
   SET abc2 = concat(substring(1,18,abc),"00")
   SET icu_admit_dt_tm = cnvtdatetime(value(abc2))
   SET person_id = new_encntr_list_record->encntr_list[indx].person_id
   SET encntr_id = new_encntr_list_record->encntr_list[indx].encntr_id
   SET ra_request->reclist[indx].icu_admit_dt_tm = icu_admit_dt_tm
   SET ra_request->reclist[indx].encntr_id = encntr_id
   SET ra_request->reclist[indx].person_id = person_id
   SET ra_request->reclist[indx].bed_count = new_encntr_list_record->encntr_list[indx].bed_count
   SET ra_request->reclist[indx].teach_type_flag = new_encntr_list_record->encntr_list[indx].
   teach_type_flag
   SET ra_request->reclist[indx].region_flag = new_encntr_list_record->encntr_list[indx].region_flag
   SET ra_request->reclist[indx].hosp_admit_dt_tm = new_encntr_list_record->encntr_list[indx].
   hosp_admit_dt_tm
   SET ra_request->reclist[indx].icu_disch_dt_tm = cnvtdatetime(value(unset_date))
   SET ra_request->reclist[indx].gender_flag = new_encntr_list_record->encntr_list[indx].gender_flag
   SET ra_request->reclist[indx].admit_age = new_encntr_list_record->encntr_list[indx].admit_age
   SET req_index = indx
   CALL set_readmit_ind(person_id,encntr_id,indx)
   SET rad_request->reclist[indx].cc_beg_dt_tm = icu_admit_dt_tm
   SET rad_request->reclist[indx].cc_day = 1
   SET rad_request->reclist[indx].cc_end_dt_tm = cc_end_day1
   SET cc_day_request->reclist[indx].last_cc_end_dt_tm = cc_end_day1
   SET cc_day_request->reclist[indx].last_cc_day = 1
 ENDFOR
 EXECUTE co_add_risk_adjustment  WITH replace("REQUEST","RA_REQUEST"), replace("REPLY","RA_REPLY")
 IF ((ra_reply->status_data.status != "S"))
  SET sfailed = "F"
  CALL set_reply_status(ra_reply->status_data.status,ra_reply->status_data.subeventstatus[1].
   operationname,ra_reply->status_data.subeventstatus[1].operationstatus,ra_reply->status_data.
   subeventstatus[1].targetobjectname,ra_reply->status_data.subeventstatus[1].targetobjectvalue)
  GO TO exit_script
 ENDIF
 SET ra_size = size(ra_reply->reclist,5)
 IF (ra_size=num_new_ra_to_add
  AND (ra_reply->reclist[1].encntr_id=ra_request->reclist[1].encntr_id)
  AND (ra_reply->reclist[ra_size].encntr_id=ra_request->reclist[num_new_ra_to_add].encntr_id))
  FOR (indx = 1 TO num_new_ra_to_add)
   SET rad_request->reclist[indx].risk_adjustment_id = ra_reply->reclist[indx].risk_adjustment_id
   SET cc_day_request->reclist[indx].risk_adjustment_id = ra_reply->reclist[indx].risk_adjustment_id
  ENDFOR
  EXECUTE co_add_risk_adjustment_day  WITH replace("REQUEST","RAD_REQUEST"), replace("REPLY",
   "RAD_REPLY")
  IF ((rad_reply->status_data.status != "S"))
   SET sfailed = "F"
   CALL set_reply_status(rad_reply->status_data.status,rad_reply->status_data.subeventstatus[1].
    operationname,rad_reply->status_data.subeventstatus[1].operationstatus,rad_reply->status_data.
    subeventstatus[1].targetobjectname,rad_reply->status_data.subeventstatus[1].targetobjectvalue)
   GO TO exit_script
  ENDIF
  SET rad_size = size(rad_reply->reclist,5)
  IF (rad_size=ra_size
   AND (rad_reply->reclist[1].risk_adjustment_id=rad_request->reclist[1].risk_adjustment_id)
   AND (rad_reply->reclist[rad_size].risk_adjustment_id=rad_request->reclist[num_new_ra_to_add].
  risk_adjustment_id))
   EXECUTE co_create_icu_days  WITH replace("REQUEST","CC_DAY_REQUEST"), replace("REPLY",
    "CC_DAY_REPLY")
   IF ((cc_day_reply->status_data.status="F"))
    SET sfailed = "F"
    CALL set_reply_status(cc_day_reply->status_data.status,cc_day_reply->status_data.subeventstatus[1
     ].operationname,cc_day_reply->status_data.subeventstatus[1].operationstatus,cc_day_reply->
     status_data.subeventstatus[1].targetobjectname,cc_day_reply->status_data.subeventstatus[1].
     targetobjectvalue)
    GO TO exit_script
   ENDIF
   FOR (indx = 1 TO num_new_ra_to_add)
     SET pred_request->person_id = new_encntr_list_record->encntr_list[indx].person_id
     SET pred_request->encntr_id = new_encntr_list_record->encntr_list[indx].encntr_id
     SET pred_request->cc_start_day = 1
     SET pred_request->icu_admit_dt_tm = new_encntr_list_record->encntr_list[indx].icu_admit_dt_tm
     EXECUTE dcp_recalc_apache_predictions  WITH replace("REQUEST",pred_request), replace("REPLY",
      "PRED_REPLY")
   ENDFOR
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->count_ra_records_created = num_new_ra_to_add
 ENDIF
#check_for_ra_without_rad_data
 RECORD default_ra_record(
   1 reclist[*]
     2 admitsource_flag = i2
     2 admit_age = i4
     2 admit_diagnosis = vc
     2 admit_icu_cd = f8
     2 admit_source = vc
     2 adm_doc_id = f8
     2 aids_ind = i2
     2 ami_location = vc
     2 bed_count = i4
     2 body_system = vc
     2 cc_during_stay_ind = i2
     2 chronic_health_none_ind = i2
     2 chronic_health_unavail_ind = i2
     2 cirrhosis_ind = i2
     2 copd_flag = i2
     2 copd_ind = i2
     2 diabetes_ind = i2
     2 dialysis_ind = i2
     2 diesinhospital_ind = i2
     2 diedinicu_ind = i2
     2 discharge_location_cd = f8
     2 disease_category_cd = f8
     2 ejectfx_fraction = f8
     2 electivesurgery_ind = i2
     2 encntr_id = f8
     2 gender_flag = i2
     2 hepaticfailure_ind = i2
     2 hosp_admit_dt_tm = dq8
     2 hrs_at_source = i4
     2 icu_admit_dt_tm = dq8
     2 icu_disch_dt_tm = dq8
     2 ima_ind = i2
     2 immunosuppression_ind = i2
     2 leukemia_ind = i2
     2 lymphoma_ind = i2
     2 med_service_cd = f8
     2 metastaticcancer_ind = i2
     2 midur_ind = i2
     2 mi_within_6mo_ind = i2
     2 nbr_grafts_performed = i4
     2 person_id = f8
     2 ptca_device = vc
     2 readmit_ind = i2
     2 readmit_within_24hr_ind = i2
     2 region_flag = i2
     2 risk_adjustment_id = f8
     2 sv_graft_ind = i2
     2 teach_type_flag = i2
     2 therapy_level = i4
     2 thrombolytics_ind = i2
     2 xfer_within_48hr_ind = i2
     2 var03hspxlos_value = f8
     2 valid_from_dt_tm = dq8
     2 valid_until_dt_tm = dq8
 )
 RECORD default_rad_record(
   1 reclist[*]
     2 activetx_ind = i2
     2 albumin_ce_id = f8
     2 apache_iii_score = i4
     2 apache_ii_score = i4
     2 aps_day1 = i4
     2 aps_score = i4
     2 aps_yesterday = i4
     2 bilirubin_ce_id = f8
     2 bun_ce_id = f8
     2 cc_beg_dt_tm = dq8
     2 cc_day = i4
     2 cc_end_dt_tm = dq8
     2 creatinine_ce_id = f8
     2 eyes_ce_id = f8
     2 fio2_ce_id = f8
     2 glucose_ce_id = f8
     2 heartrate_ce_id = f8
     2 hematocrit_ce_id = f8
     2 intubated_ce_id = f8
     2 intubated_ind = i2
     2 mean_blood_pressure = f8
     2 meds_ce_id = f8
     2 meds_ind = i2
     2 motor_ce_id = f8
     2 outcome_status = i4
     2 pao2_ce_id = f8
     2 pa_line_today_ind = i2
     2 pco2_ce_id = f8
     2 phys_res_pts = i4
     2 ph_ce_id = f8
     2 potassium_ce_id = f8
     2 resp_ce_id = f8
     2 risk_adjustment_id = f8
     2 risk_adjustment_day_id = f8
     2 sodium_ce_id = f8
     2 temp_ce_id = f8
     2 urine_24hr_output = f8
     2 urine_output = f8
     2 vent_ind = i2
     2 vent_today_ind = i2
     2 verbal_ce_id = f8
     2 wbc_ce_id = f8
     2 worst_albumin_result = f8
     2 worst_bilirubin_result = f8
     2 worst_bun_result = f8
     2 worst_creatinine_result = f8
     2 worst_fio2_result = f8
     2 worst_gcs_eye_score = i4
     2 worst_gcs_motor_score = i4
     2 worst_gcs_verbal_score = i4
     2 worst_glucose_result = f8
     2 worst_heart_rate = f8
     2 worst_hematocrit = f8
     2 worst_pao2_result = f8
     2 worst_pco2_result = f8
     2 worst_ph_result = f8
     2 worst_potassium_result = f8
     2 worst_resp_result = f8
     2 worst_sodium_result = f8
     2 worst_temp = f8
     2 worst_wbc_result = f8
     2 valid_from_dt_tm = dq8
     2 valid_until_dt_tm = dq8
 )
 SET stat = alterlist(default_rad_record->reclist,1)
 SET default_rad_record->reclist[1].activetx_ind = - (1)
 SET default_rad_record->reclist[1].albumin_ce_id = 0
 SET default_rad_record->reclist[1].apache_iii_score = - (1)
 SET default_rad_record->reclist[1].apache_ii_score = - (1)
 SET default_rad_record->reclist[1].aps_day1 = - (1)
 SET default_rad_record->reclist[1].aps_score = - (1)
 SET default_rad_record->reclist[1].aps_yesterday = - (1)
 SET default_rad_record->reclist[1].bilirubin_ce_id = 0
 SET default_rad_record->reclist[1].bun_ce_id = 0
 SET default_rad_record->reclist[1].creatinine_ce_id = 0
 SET default_rad_record->reclist[1].eyes_ce_id = 0
 SET default_rad_record->reclist[1].fio2_ce_id = 0
 SET default_rad_record->reclist[1].glucose_ce_id = 0
 SET default_rad_record->reclist[1].heartrate_ce_id = 0
 SET default_rad_record->reclist[1].hematocrit_ce_id = 0
 SET default_rad_record->reclist[1].intubated_ce_id = 0
 SET default_rad_record->reclist[1].intubated_ind = - (1)
 SET default_rad_record->reclist[1].mean_blood_pressure = - (1)
 SET default_rad_record->reclist[1].meds_ce_id = 0
 SET default_rad_record->reclist[1].meds_ind = - (1)
 SET default_rad_record->reclist[1].motor_ce_id = 0
 SET default_rad_record->reclist[1].outcome_status = - (1)
 SET default_rad_record->reclist[1].pao2_ce_id = 0
 SET default_rad_record->reclist[1].pa_line_today_ind = - (1)
 SET default_rad_record->reclist[1].pco2_ce_id = 0
 SET default_rad_record->reclist[1].phys_res_pts = - (1)
 SET default_rad_record->reclist[1].resp_ce_id = 0
 SET default_rad_record->reclist[1].ph_ce_id = 0
 SET default_rad_record->reclist[1].potassium_ce_id = 0
 SET default_rad_record->reclist[1].sodium_ce_id = 0
 SET default_rad_record->reclist[1].temp_ce_id = 0
 SET default_rad_record->reclist[1].urine_24hr_output = - (1)
 SET default_rad_record->reclist[1].urine_output = - (1)
 SET default_rad_record->reclist[1].vent_ind = - (1)
 SET default_rad_record->reclist[1].vent_today_ind = - (1)
 SET default_rad_record->reclist[1].verbal_ce_id = 0
 SET default_rad_record->reclist[1].wbc_ce_id = 0
 SET default_rad_record->reclist[1].worst_albumin_result = - (1)
 SET default_rad_record->reclist[1].worst_bilirubin_result = - (1)
 SET default_rad_record->reclist[1].worst_bun_result = - (1)
 SET default_rad_record->reclist[1].worst_creatinine_result = - (1)
 SET default_rad_record->reclist[1].worst_fio2_result = - (1)
 SET default_rad_record->reclist[1].worst_gcs_eye_score = - (1)
 SET default_rad_record->reclist[1].worst_gcs_motor_score = - (1)
 SET default_rad_record->reclist[1].worst_gcs_verbal_score = - (1)
 SET default_rad_record->reclist[1].worst_glucose_result = - (1)
 SET default_rad_record->reclist[1].worst_heart_rate = - (1)
 SET default_rad_record->reclist[1].worst_hematocrit = - (1)
 SET default_rad_record->reclist[1].worst_pao2_result = - (1)
 SET default_rad_record->reclist[1].worst_pco2_result = - (1)
 SET default_rad_record->reclist[1].worst_ph_result = - (1)
 SET default_rad_record->reclist[1].worst_potassium_result = - (1)
 SET default_rad_record->reclist[1].worst_resp_result = - (1)
 SET default_rad_record->reclist[1].worst_sodium_result = - (1)
 SET default_rad_record->reclist[1].worst_temp = - (1)
 SET default_rad_record->reclist[1].worst_wbc_result = - (1)
 SET default_rad_record->reclist[1].valid_from_dt_tm = cnvtdatetime(curdate,curtime3)
 SET default_rad_record->reclist[1].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
 SET stat = alterlist(default_ra_record->reclist,1)
 SET default_ra_record->reclist[1].admitsource_flag = 0
 SET default_ra_record->reclist[1].admit_age = 0
 SET default_ra_record->reclist[1].admit_diagnosis = ""
 SET default_ra_record->reclist[1].admit_icu_cd = - (1)
 SET default_ra_record->reclist[1].admit_source = ""
 SET default_ra_record->reclist[1].adm_doc_id = 0
 SET default_ra_record->reclist[1].aids_ind = 0
 SET default_ra_record->reclist[1].ami_location = ""
 SET default_ra_record->reclist[1].body_system = ""
 SET default_ra_record->reclist[1].cc_during_stay_ind = - (1)
 SET default_ra_record->reclist[1].chronic_health_none_ind = 0
 SET default_ra_record->reclist[1].chronic_health_unavail_ind = 0
 SET default_ra_record->reclist[1].cirrhosis_ind = 0
 SET default_ra_record->reclist[1].copd_flag = 0
 SET default_ra_record->reclist[1].copd_ind = 0
 SET default_ra_record->reclist[1].diabetes_ind = 0
 SET default_ra_record->reclist[1].dialysis_ind = - (1)
 SET default_ra_record->reclist[1].diesinhospital_ind = - (1)
 SET default_ra_record->reclist[1].diedinicu_ind = - (1)
 SET default_ra_record->reclist[1].discharge_location_cd = - (1)
 SET default_ra_record->reclist[1].disease_category_cd = - (1)
 SET default_ra_record->reclist[1].ejectfx_fraction = - (1)
 SET default_ra_record->reclist[1].electivesurgery_ind = - (1)
 SET default_ra_record->reclist[1].gender_flag = - (1)
 SET default_ra_record->reclist[1].hepaticfailure_ind = 0
 SET default_ra_record->reclist[1].hrs_at_source = - (1)
 SET default_ra_record->reclist[1].icu_disch_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
 SET default_ra_record->reclist[1].ima_ind = - (1)
 SET default_ra_record->reclist[1].immunosuppression_ind = 0
 SET default_ra_record->reclist[1].leukemia_ind = 0
 SET default_ra_record->reclist[1].lymphoma_ind = 0
 SET default_ra_record->reclist[1].med_service_cd = - (1)
 SET default_ra_record->reclist[1].metastaticcancer_ind = 0
 SET default_ra_record->reclist[1].midur_ind = - (1)
 SET default_ra_record->reclist[1].mi_within_6mo_ind = - (1)
 SET default_ra_record->reclist[1].nbr_grafts_performed = - (1)
 SET default_ra_record->reclist[1].ptca_device = ""
 SET default_ra_record->reclist[1].readmit_ind = 0
 SET default_ra_record->reclist[1].readmit_within_24hr_ind = - (1)
 SET default_ra_record->reclist[1].sv_graft_ind = - (1)
 SET default_ra_record->reclist[1].therapy_level = - (1)
 SET default_ra_record->reclist[1].thrombolytics_ind = - (1)
 SET default_ra_record->reclist[1].xfer_within_48hr_ind = - (1)
 SET default_ra_record->reclist[1].var03hspxlos_value = 0
 SET default_ra_record->reclist[1].valid_from_dt_tm = cnvtdatetime(curdate,curtime3)
 SET default_ra_record->reclist[1].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
 RECORD ra_encntr_list_record(
   1 encntr_list[*]
     2 ra_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 admit_unit_cd = f8
     2 icu_admit_dt_tm = dq8
     2 cc_end_of_day1 = dq8
     2 bed_count = i2
     2 hosp_admit_dt_tm = dq8
     2 region_flag = i2
     2 teach_type_flag = i2
 )
 RECORD ra_encntr_rar_list_record(
   1 encntr_list[*]
     2 ra_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 admit_unit_cd = f8
     2 icu_admit_dt_tm = dq8
 )
 DECLARE rad_cnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad
  PLAN (ra
   WHERE ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=outerjoin(ra.risk_adjustment_id)
    AND rad.active_ind=outerjoin(1)
    AND rad.cc_day=outerjoin(1)
    AND rad.risk_adjustment_day_id=null)
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (ra.person_id > 0.0
    AND ra.encntr_id > 0.0)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(ra_encntr_rar_list_record->encntr_list,(cnt+ 9))
    ENDIF
    ra_encntr_rar_list_record->encntr_list[cnt].ra_id = ra.risk_adjustment_id,
    ra_encntr_rar_list_record->encntr_list[cnt].person_id = ra.person_id, ra_encntr_rar_list_record->
    encntr_list[cnt].encntr_id = ra.encntr_id,
    ra_encntr_rar_list_record->encntr_list[cnt].admit_unit_cd = ra.admit_icu_cd,
    ra_encntr_rar_list_record->encntr_list[cnt].icu_admit_dt_tm = ra.icu_admit_dt_tm
   ENDIF
  FOOT REPORT
   stat = alterlist(ra_encntr_rar_list_record->encntr_list,cnt)
  WITH nocounter
 ;end select
 SET cnt = size(ra_encntr_rar_list_record->encntr_list,5)
 SELECT INTO "nl:"
  FROM encounter e,
   risk_adjustment_ref rar,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=ra_encntr_rar_list_record->encntr_list[d.seq].encntr_id)
    AND ((e.active_ind+ 0)=1))
   JOIN (rar
   WHERE (rar.organization_id=(e.organization_id+ 0))
    AND rar.active_ind=1)
  HEAD REPORT
   rad_cnt = 0
  DETAIL
   rad_cnt = (rad_cnt+ 1)
   IF (mod(rad_cnt,10)=1)
    stat = alterlist(ra_encntr_list_record->encntr_list,(rad_cnt+ 9))
   ENDIF
   ra_encntr_list_record->encntr_list[rad_cnt].ra_id = ra_encntr_rar_list_record->encntr_list[d.seq].
   ra_id, ra_encntr_list_record->encntr_list[rad_cnt].person_id = ra_encntr_rar_list_record->
   encntr_list[d.seq].person_id, ra_encntr_list_record->encntr_list[rad_cnt].encntr_id =
   ra_encntr_rar_list_record->encntr_list[d.seq].encntr_id,
   ra_encntr_list_record->encntr_list[rad_cnt].admit_unit_cd = ra_encntr_rar_list_record->
   encntr_list[d.seq].admit_unit_cd, ra_encntr_list_record->encntr_list[rad_cnt].icu_admit_dt_tm =
   ra_encntr_rar_list_record->encntr_list[d.seq].icu_admit_dt_tm, ra_encntr_list_record->encntr_list[
   rad_cnt].bed_count = rar.bed_count,
   ra_encntr_list_record->encntr_list[rad_cnt].teach_type_flag = rar.teach_type_flag,
   ra_encntr_list_record->encntr_list[rad_cnt].region_flag = rar.region_flag, ra_encntr_list_record->
   encntr_list[rad_cnt].hosp_admit_dt_tm = e.reg_dt_tm,
   cc_day_start_time = rar.icu_day_start_time, end_day1_date = cnvtdate(ra_encntr_rar_list_record->
    encntr_list[d.seq].icu_admit_dt_tm), end_day1_dt_tm = cnvtdatetime(end_day1_date,
    cc_day_start_time),
   end_day1_dt_tm = datetimeadd(end_day1_dt_tm,- ((1.0/ 1440.0)))
   IF (datetimediff(cnvtdatetime(end_day1_dt_tm),cnvtdatetime(ra_encntr_rar_list_record->encntr_list[
     d.seq].icu_admit_dt_tm)) < 0)
    end_day1_dt_tm = datetimeadd(end_day1_dt_tm,1)
   ENDIF
   IF (datetimediff(end_day1_dt_tm,ra_encntr_rar_list_record->encntr_list[d.seq].icu_admit_dt_tm,3)
    < 8)
    end_day1_dt_tm = datetimeadd(end_day1_dt_tm,1)
   ENDIF
   ra_encntr_list_record->encntr_list[rad_cnt].cc_end_of_day1 = end_day1_dt_tm
  FOOT REPORT
   stat = alterlist(ra_encntr_list_record->encntr_list,rad_cnt)
  WITH nocounter
 ;end select
 IF (rad_cnt=0)
  CALL echo("no RA without RAD records, going to exit")
  GO TO exit_script
 ELSE
  CALL echo(build("NUMBER OF RA RECORDS WITHOUT RAD RECORDS=",rad_cnt))
 ENDIF
 SET stat = alterlist(rad_request->reclist,rad_cnt)
 SET stat = alterlist(cc_day_request->reclist,rad_cnt)
 SET indx = 0
 SET stat = movereclist(default_rad_record->reclist,rad_request->reclist,1,1,1,
  0)
 SET stat = movereclist(rad_request->reclist,rad_request->reclist,1,2,(rad_cnt - 1),
  0)
 FOR (indx = 1 TO rad_cnt)
   SET rad_request->reclist[indx].cc_beg_dt_tm = ra_encntr_list_record->encntr_list[indx].
   icu_admit_dt_tm
   SET rad_request->reclist[indx].cc_day = 1
   SET rad_request->reclist[indx].cc_end_dt_tm = ra_encntr_list_record->encntr_list[indx].
   cc_end_of_day1
   SET cc_day_request->reclist[indx].last_cc_end_dt_tm = ra_encntr_list_record->encntr_list[indx].
   cc_end_of_day1
   SET cc_day_request->reclist[indx].last_cc_day = 1
   SET rad_request->reclist[indx].risk_adjustment_id = ra_encntr_list_record->encntr_list[indx].ra_id
   SET cc_day_request->reclist[indx].risk_adjustment_id = ra_encntr_list_record->encntr_list[indx].
   ra_id
 ENDFOR
 EXECUTE co_add_risk_adjustment_day  WITH replace("REQUEST","RAD_REQUEST"), replace("REPLY",
  "RAD_REPLY")
 IF ((rad_reply->status_data.status != "S"))
  SET sfailed = "F"
  CALL set_reply_status(rad_reply->status_data.status,rad_reply->status_data.subeventstatus[1].
   operationname,rad_reply->status_data.subeventstatus[1].operationstatus,rad_reply->status_data.
   subeventstatus[1].targetobjectname,rad_reply->status_data.subeventstatus[1].targetobjectvalue)
  GO TO exit_script
 ENDIF
 SET rad_size = size(rad_reply->reclist,5)
 IF (rad_size=rad_cnt
  AND (rad_reply->reclist[1].risk_adjustment_id=rad_request->reclist[1].risk_adjustment_id)
  AND (rad_reply->reclist[rad_size].risk_adjustment_id=rad_request->reclist[rad_cnt].
 risk_adjustment_id))
  EXECUTE co_create_icu_days  WITH replace("REQUEST","CC_DAY_REQUEST"), replace("REPLY",
   "CC_DAY_REPLY")
  IF ((cc_day_reply->status_data.status="F"))
   SET sfailed = "F"
   CALL set_reply_status(cc_day_reply->status_data.status,cc_day_reply->status_data.subeventstatus[1]
    .operationname,cc_day_reply->status_data.subeventstatus[1].operationstatus,cc_day_reply->
    status_data.subeventstatus[1].targetobjectname,cc_day_reply->status_data.subeventstatus[1].
    targetobjectvalue)
   GO TO exit_script
  ENDIF
  FOR (indx = 1 TO rad_cnt)
    SET pred_request->person_id = ra_encntr_list_record->encntr_list[indx].person_id
    SET pred_request->encntr_id = ra_encntr_list_record->encntr_list[indx].encntr_id
    SET pred_request->cc_start_day = 1
    SET pred_request->icu_admit_dt_tm = ra_encntr_list_record->encntr_list[indx].icu_admit_dt_tm
    EXECUTE dcp_recalc_apache_predictions  WITH replace("REQUEST",pred_request), replace("REPLY",
     "PRED_REPLY")
  ENDFOR
 ENDIF
 GO TO exit_script
 SUBROUTINE set_readmit_ind(personid,encntrid,reqindex)
   SELECT INTO "nl:"
    FROM risk_adjustment ra
    PLAN (ra
     WHERE ra.person_id=personid
      AND ra.encntr_id=encntrid
      AND ra.active_ind=1)
    ORDER BY cnvtdatetime(ra.icu_disch_dt_tm) DESC
    HEAD REPORT
     first_time = "Y"
    DETAIL
     IF (first_time="Y")
      first_time = "N", discharge_date_time = ra.icu_disch_dt_tm, ra_request->reclist[reqindex].
      readmit_ind = 1,
      date_time_diff = datetimediff(ra_request->reclist[reqindex].icu_admit_dt_tm,discharge_date_time,
       3)
      IF (abs(date_time_diff) < 24
       AND (ra_request->reclist[reqindex].readmit_ind=1))
       ra_request->reclist[reqindex].readmit_within_24hr_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE set_reply_status(status,opsname,opstatus,targetname,targetvalue)
   SET reply->status_data.status = status
   SET reply->status_data.subeventstatus[1].operationname = opsname
   SET reply->status_data.subeventstatus[1].operationstatus = opstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetvalue
 END ;Subroutine
 SUBROUTINE apache_age(birth_dt_tm,admit_dt_tm)
   SET return_age = 0
   SET age_diff_days = 0.0
   SET age_diff_years = 0.0
   SET agex = fillstring(12," ")
   SET a_yr = year(cnvtdatetime(admit_dt_tm))
   SET b_yr = year(cnvtdatetime(birth_dt_tm))
   SET a_mn = month(cnvtdatetime(admit_dt_tm))
   SET b_mn = month(cnvtdatetime(birth_dt_tm))
   SET a_dy = day(cnvtdatetime(admit_dt_tm))
   SET b_dy = day(cnvtdatetime(birth_dt_tm))
   SET yr_diff = (a_yr - b_yr)
   SET mn_diff = (a_mn - b_mn)
   SET dy_diff = (a_dy - b_dy)
   IF (yr_diff > 3)
    SET agex = cnvtage(cnvtdatetime(birth_dt_tm),cnvtdatetime(admit_dt_tm),0)
    SET agex = replace(agex," ","0",0)
    SET return_age = cnvtint(substring(1,3,agex))
   ELSE
    IF (dy_diff < 0)
     SET mn_diff = (mn_diff - 1)
     SET dy_diff = (31+ dy_diff)
    ENDIF
    IF (mn_diff < 0)
     SET yr_diff = (yr_diff - 1)
     SET mn_diff = (12+ mn_diff)
    ENDIF
    SET return_age = yr_diff
   ENDIF
   RETURN(return_age)
 END ;Subroutine
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(30," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#exit_script
 IF (sfailed="Z")
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "execute"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CO_OPS_CREATE_ICU_REC_1"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "No new Risk Adjustment records need to be created."
 ENDIF
END GO
