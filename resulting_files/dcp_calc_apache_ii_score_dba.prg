CREATE PROGRAM dcp_calc_apache_ii_score:dba
 RECORD ap2_reply(
   1 apache_ii_score = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD ap2_temp(
   1 risk_adjustment_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 risk_adjustment_day_id = f8
   1 admitdiagnosis = vc
   1 electivesurgery_ind = i2
   1 age = i4
   1 dialysis_ind = i2
   1 aids_ind = i2
   1 hepaticfailure_ind = i2
   1 lymphoma_ind = i2
   1 metastaticcancer_ind = i2
   1 leukemia_ind = i2
   1 immunosuppression_ind = i2
   1 cirrhosis_ind = i2
   1 diabetes_ind = i2
   1 copd_flag = i2
   1 copd_ind = i2
   1 chronic_health_unavail_ind = i2
   1 chronic_health_none_ind = i2
   1 accept_worst_lab_ind = i2
   1 accept_worst_vitals_ind = i2
   1 worst_gcs_eyes = i2
   1 worst_gcs_motor = i2
   1 worst_gcs_verbal = i2
   1 worst_gcs_meds = i2
   1 worst_ph = f8
   1 worst_pao2 = f8
   1 worst_pco2 = f8
   1 worst_fio2 = f8
   1 worst_temp = f8
   1 worst_map = f8
   1 worst_hr = f8
   1 worst_rr = f8
   1 worst_sodium = f8
   1 worst_potassium = f8
   1 worst_creat = f8
   1 worst_hemat = f8
   1 worst_wbc = f8
 )
 RECORD scores(
   1 ap_ii_score = i4
   1 gcs_score = i4
   1 temp_score = i4
   1 map_score = i4
   1 hr_score = i4
   1 rr_score = i4
   1 oxygen_score = f8
   1 aado2 = i4
   1 ph_score = i4
   1 sodium_score = i4
   1 potassium_score = i4
   1 creat_score = i4
   1 hemat_score = i4
   1 wbc_score = i4
   1 chronic_health_count = i4
   1 age_score = i4
   1 enough_data_count = i4
   1 got_dialysis = i4
   1 chronic_score = i4
 )
 DECLARE meaning_code(p1,p1) = f8
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 IF ((ap2_parameters->risk_adjustment_id=0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Risk_adjustment_id not populated in request, no updates made."
  GO TO 9999_exit_program
 ENDIF
 IF (ra_found="N")
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "No active risk_adjustment row found for risk_adjustment_id in request."
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM 2000_get_ap2_worsts TO 2099_get_ap2_worsts_exit
 EXECUTE FROM total_ap2_score TO total_ap2_score_exit
 IF ((scores->ap_ii_score >= 0))
  EXECUTE FROM write_ap2_score TO write_ap2_score_exit
 ENDIF
 IF (success_flag="Y")
  SET ap2_reply->apache_ii_score = scores->ap_ii_score
  SET reqinfo->commit_ind = 1
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue = "Success"
  SET ap2_reply->status_data.status = "S"
 ELSE
  SET ap2_reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 GO TO 9999_exit_program
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET scores->ap_ii_score = - (1)
 SET scores->gcs_score = - (1)
 SET scores->temp_score = - (1)
 SET scores->map_score = - (1)
 SET scores->hr_score = - (1)
 SET scores->rr_score = - (1)
 SET scores->oxygen_score = - (1)
 SET scores->ph_score = - (1)
 SET scores->sodium_score = - (1)
 SET scores->potassium_score = - (1)
 SET scores->creat_score = - (1)
 SET scores->hemat_score = - (1)
 SET scores->wbc_score = - (1)
 SET scores->aado2 = - (1)
 SET scores->chronic_health_count = - (1)
 SET scores->age_score = - (1)
 SET scores->enough_data_count = - (1)
 SET scores->got_dialysis = - (1)
 SET scores->chronic_score = - (1)
 SET scores->oxygen_score = - (1)
 SET ap2_temp->risk_adjustment_id = - (1)
 SET ap2_temp->person_id = - (1)
 SET ap2_temp->encntr_id = - (1)
 SET ap2_temp->admitdiagnosis = " "
 SET ap2_temp->electivesurgery_ind = - (1)
 SET ap2_temp->age = - (1)
 SET ap2_temp->dialysis_ind = - (1)
 SET ap2_temp->aids_ind = - (1)
 SET ap2_temp->hepaticfailure_ind = - (1)
 SET ap2_temp->lymphoma_ind = - (1)
 SET ap2_temp->metastaticcancer_ind = - (1)
 SET ap2_temp->leukemia_ind = - (1)
 SET ap2_temp->immunosuppression_ind = - (1)
 SET ap2_temp->cirrhosis_ind = - (1)
 SET ap2_temp->diabetes_ind = - (1)
 SET ap2_temp->copd_flag = - (1)
 SET ap2_temp->copd_ind = - (1)
 SET ap2_temp->chronic_health_unavail_ind = - (1)
 SET ap2_temp->chronic_health_none_ind = - (1)
 SET ap2_reply->apache_ii_score = - (1)
 SET ap2_reply->status_data.status = "F"
 SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
 "(Generic) Not enough information to Calculate APACHE II Score."
 SET success_flag = "N"
 SET ra_found = "N"
 SET org_id = 0.0
 SET encntr_id = 0.0
 SET inerror_cd = meaning_code(8,"INERROR")
 SET chf_event_cd = meaning_code(29242,"CHF")
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  PLAN (ra
   WHERE (ra.risk_adjustment_id=ap2_parameters->risk_adjustment_id)
    AND ra.active_ind=1)
  DETAIL
   ap2_temp->risk_adjustment_id = ra.risk_adjustment_id, ap2_temp->person_id = ra.person_id, ap2_temp
   ->encntr_id = ra.encntr_id,
   ap2_temp->admitdiagnosis = ra.admit_diagnosis, ap2_temp->electivesurgery_ind = ra
   .electivesurgery_ind, ap2_temp->age = ra.admit_age,
   ap2_temp->dialysis_ind = ra.dialysis_ind, ap2_temp->aids_ind = ra.aids_ind, ap2_temp->
   hepaticfailure_ind = ra.hepaticfailure_ind,
   ap2_temp->lymphoma_ind = ra.lymphoma_ind, ap2_temp->metastaticcancer_ind = ra.metastaticcancer_ind,
   ap2_temp->leukemia_ind = ra.leukemia_ind,
   ap2_temp->immunosuppression_ind = ra.immunosuppression_ind, ap2_temp->cirrhosis_ind = ra
   .cirrhosis_ind, ap2_temp->diabetes_ind = ra.diabetes_ind,
   ap2_temp->copd_flag = ra.copd_flag, ap2_temp->copd_ind = ra.copd_ind, ap2_temp->
   chronic_health_unavail_ind = ra.chronic_health_unavail_ind,
   ap2_temp->chronic_health_none_ind = ra.chronic_health_none_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ra_found = "N"
 ELSE
  SET ra_found = "Y"
 ENDIF
 IF (ra_found="Y")
  SELECT INTO "nl:"
   FROM encounter e
   WHERE (e.encntr_id=ap2_temp->encntr_id)
   DETAIL
    org_id = e.organization_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM risk_adjustment_ref rar
   PLAN (rar
    WHERE rar.organization_id=org_id)
   DETAIL
    ap2_temp->accept_worst_lab_ind = rar.accept_worst_lab_ind, ap2_temp->accept_worst_vitals_ind =
    rar.accept_worst_vitals_ind
   WITH nocounter
  ;end select
 ENDIF
#1099_initialize_exit
#2000_get_ap2_worsts
 EXECUTE FROM worst_rad_values TO worst_rad_values_exit
 IF ((scores->enough_data_count < 4))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (RAD Values) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM 3200_worst_lab TO 3299_worst_lab_exit
 EXECUTE FROM 3300_worst_vitals TO 3399_worst_vitals_exit
 EXECUTE FROM get_chronic TO get_chronic_exit
 IF ((scores->enough_data_count < 0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (Chronic) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
#2099_get_ap2_worsts_exit
#3200_worst_lab
 EXECUTE FROM worst_sodium TO worst_sodium_exit
 IF ((scores->enough_data_count < 0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (Sodium) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM worst_potassium TO worst_potassium_exit
 IF ((scores->enough_data_count < 0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (Potassium) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM worst_creat TO worst_creat_exit
 IF ((scores->enough_data_count < 0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (Creatinine) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM worst_hemat TO worst_hemat_exit
 IF ((scores->enough_data_count < 0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (Hematocrit) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM worst_wbc TO worst_wbc_exit
 IF ((scores->enough_data_count < 0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (WBC) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM get_age TO get_age_exit
 IF ((scores->enough_data_count < 0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (Age) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
#3299_worst_lab_exit
#3300_worst_vitals
 EXECUTE FROM worst_temp TO worst_temp_exit
 IF ((scores->enough_data_count < 0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (Temp) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM worst_mean_bp TO worst_mean_bp_exit
 IF ((scores->enough_data_count < 0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (Map) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM worst_hr TO worst_hr_exit
 IF ((scores->enough_data_count < 0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (HR) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM worst_rr TO worst_rr_exit
 IF ((scores->enough_data_count < 0))
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Not enough information (RR) to Calculate APACHE II Score."
  GO TO 9999_exit_program
 ENDIF
#3399_worst_vitals_exit
#worst_rad_values
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=ap2_parameters->risk_adjustment_id)
    AND rad.active_ind=1
    AND (rad.cc_day=ap2_parameters->cc_day))
  DETAIL
   ap2_temp->risk_adjustment_day_id = rad.risk_adjustment_day_id, ap2_temp->worst_gcs_eyes = rad
   .worst_gcs_eye_score, ap2_temp->worst_gcs_motor = rad.worst_gcs_motor_score,
   ap2_temp->worst_gcs_verbal = rad.worst_gcs_verbal_score, ap2_temp->worst_gcs_meds = rad.meds_ind,
   ap2_temp->worst_ph = rad.worst_ph_result,
   ap2_temp->worst_pao2 = rad.worst_pao2_result, ap2_temp->worst_pco2 = rad.worst_pco2_result,
   ap2_temp->worst_fio2 = rad.worst_fio2_result
   IF (rad.worst_temp > 50)
    ap2_temp->worst_temp = (((rad.worst_temp - 32) * 5.0)/ 9.0)
   ELSE
    ap2_temp->worst_temp = rad.worst_temp
   ENDIF
   ap2_temp->worst_map = rad.mean_blood_pressure, ap2_temp->worst_hr = rad.worst_heart_rate, ap2_temp
   ->worst_rr = rad.worst_resp_result,
   ap2_temp->worst_sodium = rad.worst_sodium_result, ap2_temp->worst_potassium = rad
   .worst_potassium_result, ap2_temp->worst_creat = rad.worst_creatinine_result,
   ap2_temp->worst_hemat = rad.worst_hematocrit, ap2_temp->worst_wbc = rad.worst_wbc_result
  WITH nocounter
 ;end select
 SET scores->enough_data_count = - (1)
 SET scores->oxygen_score = - (1)
 IF ((ap2_temp->worst_fio2 > 0)
  AND (ap2_temp->worst_pao2 > 0)
  AND (ap2_temp->worst_pco2 > 0))
  SET scores->enough_data_count = 3
  IF ((ap2_temp->worst_pao2 < 50))
   SET scores->oxygen_score = 4
   IF ((ap2_temp->worst_pao2 > 70))
    SET scores->oxygen_score = 0
   ELSE
    IF ((ap2_temp->worst_pao2 > 60))
     SET scores->oxygen_score = 1
    ELSE
     IF ((ap2_temp->worst_pao2 > 55))
      SET scores->oxygen_score = 3
     ENDIF
    ENDIF
   ENDIF
  ELSE
   SET scores->aado2 = (((ap2_temp->worst_fio2 * 7.13) - ap2_temp->worst_pao2) - ap2_temp->worst_pco2
   )
   IF ((scores->aado2 > 499))
    SET scores->oxygen_score = 4
   ELSE
    IF ((scores->aado2 > 349))
     SET scores->oxygen_score = 3
    ELSEIF ((scores->aado2 > 200))
     SET scores->oxygen_score = 2
    ELSE
     SET scores->oxygen_score = 0
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((ap2_temp->worst_ph <= 0))
  SET scores->enough_data_count = - (1)
 ELSE
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
  IF ((ap2_temp->worst_ph >= 7.7))
   SET scores->ph_score = 4
  ELSEIF ((ap2_temp->worst_ph >= 7.6))
   SET scores->ph_score = 3
  ELSEIF ((ap2_temp->worst_ph >= 7.5))
   SET scores->ph_score = 1
  ELSEIF ((ap2_temp->worst_ph >= 7.33))
   SET scores->ph_score = 0
  ELSEIF ((ap2_temp->worst_ph >= 7.25))
   SET scores->ph_score = 2
  ELSEIF ((ap2_temp->worst_ph > 7.15))
   SET scores->ph_score = 3
  ELSE
   SET scores->ph_score = 4
  ENDIF
 ENDIF
 IF ((scores->enough_data_count > 0))
  SET scores->gcs_score = - (1)
  IF ((ap2_temp->worst_gcs_meds=1))
   SET scores->gcs_score = 15
   SET scores->enough_data_count = (scores->enough_data_count+ 3)
  ELSE
   SET scores->gcs_score = 15
   IF ((ap2_temp->worst_gcs_eyes > 0))
    SET scores->enough_data_count = (scores->enough_data_count+ 1)
    SET scores->gcs_score = (scores->gcs_score - ap2_temp->worst_gcs_eyes)
   ELSE
    SET scores->enough_data_count = - (4)
   ENDIF
   IF ((ap2_temp->worst_gcs_motor > 0))
    SET scores->enough_data_count = (scores->enough_data_count+ 1)
    SET scores->gcs_score = (scores->gcs_score - ap2_temp->worst_gcs_motor)
   ELSE
    SET scores->enough_data_count = - (4)
   ENDIF
   IF ((ap2_temp->worst_gcs_verbal > 0))
    SET scores->enough_data_count = (scores->enough_data_count+ 1)
    SET scores->gcs_score = (scores->gcs_score - ap2_temp->worst_gcs_verbal)
   ELSE
    SET scores->enough_data_count = - (4)
   ENDIF
  ENDIF
 ENDIF
#worst_rad_values_exit
#get_chronic
 IF ((ap2_temp->dialysis_ind=1))
  SET scores->creat_score = (scores->creat_score * 2)
  SET scores->chronic_health_count = 1
 ENDIF
 IF ((scores->chronic_health_count=0))
  IF ((ap2_temp->aids_ind=1))
   SET scores->chronic_health_count = 1
  ELSEIF ((ap2_temp->hepaticfailure_ind=1))
   SET scores->chronic_health_count = 1
  ELSEIF ((ap2_temp->lymphoma_ind=1))
   SET scores->chronic_health_count = 1
  ELSEIF ((ap2_temp->metastaticcancer_ind=1))
   SET scores->chronic_health_count = 1
  ELSEIF ((ap2_temp->leukemia_ind=1))
   SET scores->chronic_health_count = 1
  ELSEIF ((ap2_temp->immunosuppression_ind=1))
   SET scores->chronic_health_count = 1
  ELSEIF ((ap2_temp->cirrhosis_ind=1))
   SET scores->chronic_health_count = 1
  ELSEIF ((ap2_temp->copd_flag > 1))
   SET scores->chronic_health_count = 1
  ENDIF
 ENDIF
 IF ((scores->chronic_health_count=0))
  SELECT INTO "nl:"
   FROM risk_adjustment_event rae
   PLAN (rae
    WHERE (rae.risk_adjustment_id=ap2_parameters->risk_adjustment_id)
     AND rae.active_ind=1
     AND chf_event_cd=rae.sentinel_event_code_cd)
   DETAIL
    scores->chronic_health_count = 1
   WITH nocounter
  ;end select
 ENDIF
 IF ((scores->chronic_health_count=0))
  IF ((ap2_temp->admitdiagnosis="CHF"))
   SET scores->chronic_health_count = 1
  ENDIF
 ENDIF
 IF ((scores->chronic_health_count <= 0))
  SET scores->chronic_score = 0
 ELSE
  IF ((ap2_temp->electivesurgery_ind=1))
   SET scores->chronic_score = 2
  ELSE
   SET scores->chronic_score = 5
  ENDIF
 ENDIF
#get_chronic_exit
#get_age
 IF ((ap2_temp->age=0))
  SET scores->enough_data_count = 0
  SET scores->age_score = 0
 ELSE
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
  IF ((ap2_temp->age > 74))
   SET scores->age_score = 6
  ELSEIF ((ap2_temp->age > 64))
   SET scores->age_score = 5
  ELSEIF ((ap2_temp->age > 54))
   SET scores->age_score = 3
  ELSEIF ((ap2_temp->age > 44))
   SET scores->age_score = 2
  ELSE
   SET scores->age_score = 0
  ENDIF
 ENDIF
#get_age_exit
#worst_temp
 SET max_hold = - (1.0)
 SET min_hold = - (1.0)
 SET max_hold = ap2_temp->worst_temp
 SET min_hold = ap2_temp->worst_temp
 SET event_tag_num = - (1.0)
 SET min_tag = - (1.0)
 SET midpoint = 0.0
 SET temp1_cd = 0.0
 SET temp2_cd = 0.0
 SET ap2_temp_cd = 0.0
 SET ax_temp4_cd = 0.0
 SET temp5_cd = 0.0
 SET temp6_cd = 0.0
 SET temp1_cd = uar_get_code_by_cki("CKI.EC!5502")
 SET temp2_cd = uar_get_code_by_cki("CKI.EC!5505")
 SET ap2_temp_cd = uar_get_code_by_cki("CKI.EC!5506")
 SET ax_temp4_cd = uar_get_code_by_cki("CKI.EC!5507")
 SET temp5_cd = uar_get_code_by_cki("CKI.EC!5508")
 SET temp6_cd = uar_get_code_by_cki("CKI.EC!5509")
 IF (temp1_cd <= 0.0
  AND temp2_cd <= 0.0
  AND ap2_temp_cd <= 0.0
  AND ax_temp4_cd <= 0.0
  AND temp5_cd <= 0.0
  AND temp6_cd <= 0.0)
  SET junk = "junk"
 ELSE
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=ap2_temp->person_id)
     AND ((ce.event_cd=temp1_cd) OR (((ce.event_cd=temp2_cd) OR (((ce.event_cd=ap2_temp_cd) OR (((ce
    .event_cd=ax_temp4_cd) OR (((ce.event_cd=temp5_cd) OR (ce.event_cd=temp6_cd)) )) )) )) ))
     AND ce.event_end_dt_tm >= cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(ap2_parameters->cc_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   HEAD REPORT
    temp_temp = 0.0, temp_diff = 0.0, hold_diff = 0.0,
    isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_temp = cnvtreal(ce.event_tag)
     IF (temp_temp > 0
      AND temp_temp < 50)
      temp_temp = temp_temp
     ELSE
      temp_temp = (((temp_temp - 32) * 5.0)/ 9.0)
     ENDIF
     IF (ce.event_cd=ax_temp4_cd)
      temp_temp = (temp_temp+ 1)
     ENDIF
     IF (temp_temp > max_hold)
      max_hold = temp_temp
     ENDIF
     IF ((((min_hold=- (1.0))) OR (temp_temp < min_hold)) )
      min_hold = temp_temp
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (max_hold >= 41)
  SET hold_diff = max_hold
  SET scores->temp_score = 4
 ELSEIF (min_hold <= 29.9
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->temp_score = 4
 ELSEIF (max_hold >= 39)
  SET hold_diff = max_hold
  SET scores->temp_score = 3
 ELSEIF (min_hold <= 31.9
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->temp_score = 3
 ELSEIF (min_hold <= 33.9
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->temp_score = 2
 ELSEIF (max_hold >= 38.5)
  SET hold_diff = max_hold
  SET scores->temp_score = 1
 ELSEIF (min_hold <= 35.9
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->temp_score = 1
 ELSE
  SET hold_diff = max_hold
  SET scores->temp_score = 0
 ENDIF
 IF (hold_diff > 0)
  SET ap2_temp->worst_temp = hold_diff
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
 ELSE
  SET scores->enough_data_count = - (1)
 ENDIF
#worst_temp_exit
#worst_wbc
 SET max_hold = ap2_temp->worst_wbc
 SET min_hold = ap2_temp->worst_wbc
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET max_tag = - (1.0)
 SET min_tag = - (1.0)
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!4046")
 IF (res_cd <= 0.0)
  SET junk = "junk"
 ELSE
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=ap2_temp->person_id)
     AND ce.event_cd=res_cd
     AND ce.event_end_dt_tm >= cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(ap2_parameters->cc_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   HEAD REPORT
    temp_temp = 0.0, temp_diff = 0.0, hold_diff = 0.0,
    isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_temp = cnvtreal(ce.event_tag)
     IF (temp_temp > max_hold)
      max_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
     IF ((((min_hold=- (1.0))) OR (temp_temp < min_hold)) )
      min_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (max_hold >= 40)
  SET hold_diff = max_hold
  SET scores->wbc_score = 4
 ELSEIF (min_hold <= 1
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->wbc_score = 4
 ELSEIF (max_hold >= 20)
  SET hold_diff = max_hold
  SET scores->wbc_score = 2
 ELSEIF (min_hold <= 2.9
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->wbc_score = 2
 ELSEIF (max_hold >= 15)
  SET hold_diff = max_hold
  SET scores->wbc_score = 1
 ELSE
  SET hold_diff = max_hold
  SET scores->wbc_score = 0
 ENDIF
 IF (hold_diff > 0)
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
  SET ap2_temp->worst_wbc = hold_diff
 ELSE
  SET scores->enough_data_count = - (1)
 ENDIF
#worst_wbc_exit
#worst_sodium
 SET max_hold = ap2_temp->worst_sodium
 SET min_hold = ap2_temp->worst_sodium
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3758")
 IF (res_cd <= 0.0)
  SET junk = "junk"
 ELSE
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=ap2_temp->person_id)
     AND ce.event_cd=res_cd
     AND ce.event_end_dt_tm >= cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(ap2_parameters->cc_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   HEAD REPORT
    hold_tag = 0.0, temp_temp = 0.0, temp_diff = 0.0,
    hold_diff = 0.0, isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_temp = cnvtreal(ce.event_tag)
     IF (temp_temp > max_hold)
      max_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
     IF ((((min_hold=- (1.0))) OR (temp_temp < min_hold)) )
      min_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (max_hold >= 180)
  SET hold_diff = max_hold
  SET scores->sodium_score = 4
 ELSEIF (min_hold <= 110
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->sodium_score = 4
 ELSEIF (max_hold >= 160)
  SET hold_diff = max_hold
  SET scores->sodium_score = 2
 ELSEIF (min_hold <= 119
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->sodium_score = 3
 ELSEIF (max_hold >= 155)
  SET hold_diff = max_hold
  SET scores->sodium_score = 2
 ELSEIF (min_hold <= 129
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->sodium_score = 2
 ELSEIF (max_hold >= 150)
  SET hold_diff = max_hold
  SET scores->sodium_score = 1
 ELSE
  SET hold_diff = max_hold
  SET scores->sodium_score = 0
 ENDIF
 IF (hold_diff > 0)
  SET ap2_temp->worst_sodium = hold_diff
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
 ELSE
  SET scores->enough_data_count = - (1)
 ENDIF
#worst_sodium_exit
#worst_hemat
 SET max_hold = ap2_temp->worst_hemat
 SET min_hold = ap2_temp->worst_hemat
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET max_tag = - (1.0)
 SET min_tag = - (1.0)
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3404")
 IF (res_cd <= 0.0)
  SET junk = "junk"
 ELSE
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=ap2_temp->person_id)
     AND ce.event_cd=res_cd
     AND ce.event_end_dt_tm >= cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(ap2_parameters->cc_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   HEAD REPORT
    hold_tag = 0.0, temp_temp = 0.0, temp_diff = 0.0,
    hold_diff = 0.0, isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_temp = cnvtreal(ce.event_tag)
     IF (temp_temp > max_hold)
      max_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
     IF ((((min_hold=- (1.0))) OR (temp_temp < min_hold)) )
      min_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (max_hold >= 60)
  SET hold_diff = max_hold
  SET scores->hemat_score = 4
 ELSEIF (min_hold <= 20
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->hemat_score = 4
 ELSEIF (max_hold >= 50)
  SET hold_diff = max_hold
  SET scores->hemat_score = 2
 ELSEIF (min_hold <= 29.9
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->hemat_score = 2
 ELSEIF (max_hold >= 46)
  SET hold_diff = max_hold
  SET scores->hemat_score = 1
 ELSE
  SET hold_diff = max_hold
  SET scores->hemat_score = 0
 ENDIF
 IF (hold_diff > 0)
  SET ap2_temp->worst_hemat = hold_diff
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
 ELSE
  SET scores->enough_data_count = - (1)
 ENDIF
#worst_hemat_exit
#worst_creat
 SET max_hold = ap2_temp->worst_creat
 SET min_hold = ap2_temp->worst_creat
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET max_tag = - (1.0)
 SET min_tag = - (1.0)
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3256")
 IF (res_cd > 0.0)
  SET junk = "junk"
 ELSE
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=ap2_temp->person_id)
     AND ce.event_cd=res_cd
     AND ce.event_end_dt_tm >= cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(ap2_parameters->cc_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   HEAD REPORT
    hold_tag = 0.0, temp_temp = 0.0, temp_diff = 0.0,
    hold_diff = 0.0, isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_temp = cnvtreal(ce.event_tag)
     IF (temp_temp > max_hold)
      max_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
     IF ((((min_hold=- (1.0))) OR (temp_temp < min_hold)) )
      min_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (max_hold >= 3.5)
  SET hold_diff = max_hold
  SET scores->creat_score = 4
 ELSEIF (max_hold >= 2)
  SET hold_diff = max_hold
  SET scores->creat_score = 3
 ELSEIF (min_hold <= 0.6
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->creat_score = 2
 ELSEIF (max_hold >= 1.5)
  SET hold_diff = max_hold
  SET scores->creat_score = 1
 ELSE
  SET hold_diff = max_hold
  SET scores->creat_score = 0
 ENDIF
 IF (hold_diff > 0)
  SET ap2_temp->worst_creat = hold_diff
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
 ELSE
  SET scores->enough_data_count = - (1)
 ENDIF
#worst_creat_exit
#worst_rr
 SET max_hold = ap2_temp->worst_rr
 SET min_hold = ap2_temp->worst_rr
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET max_tag = - (1.0)
 SET min_tag = - (1.0)
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!5501")
 IF (res_cd > 0.0)
  SET junk = "junk"
 ELSE
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=ap2_temp->person_id)
     AND ce.event_cd=res_cd
     AND ce.event_end_dt_tm >= cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   HEAD REPORT
    hold_tag = 0.0, temp_temp = 0.0, temp_diff = 0.0,
    hold_diff = 0.0, isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_temp = cnvtreal(ce.event_tag)
     IF (temp_temp > max_hold)
      max_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
     IF ((((min_hold=- (1.0))) OR (temp_temp < min_hold)) )
      min_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (max_hold >= 50)
  SET hold_diff = max_hold
  SET scores->rr_score = 4
 ELSEIF (min_hold <= 5
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->rr_score = 4
 ELSEIF (max_hold >= 35)
  SET hold_diff = max_hold
  SET scores->rr_score = 3
 ELSEIF (min_hold <= 9
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->rr_score = 2
 ELSEIF (max_hold >= 25)
  SET hold_diff = max_hold
  SET scores->rr_score = 1
 ELSE
  SET hold_diff = max_hold
  SET scores->rr_score = 0
 ENDIF
 IF (hold_diff > 0)
  SET ap2_temp->worst_rr = hold_diff
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
 ELSE
  SET scores->enough_data_count = - (1)
 ENDIF
#worst_rr_exit
#worst_hr
 SET max_hold = ap2_temp->worst_hr
 SET min_hold = ap2_temp->worst_hr
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET max_tag = - (1.0)
 SET min_tag = - (1.0)
 SET hr1_cd = 0.0
 SET hr1_cd = uar_get_code_by_cki("CKI.EC!40")
 SET hr2_cd = 0.0
 SET hr2_cd = uar_get_code_by_cki("CKI.EC!5500")
 IF (((hr1_cd > 0.0) OR (hr2_cd > 0.0)) )
  SET junk = "junk"
 ELSE
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=ap2_temp->person_id)
     AND ((ce.event_cd=hr1_cd) OR (ce.event_cd=hr2_cd))
     AND ce.event_end_dt_tm >= cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(ap2_parameters->cc_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   HEAD REPORT
    hold_tag = 0.0, temp_temp = 0.0, temp_diff = 0.0,
    hold_diff = 0.0, isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_temp = cnvtreal(ce.event_tag)
     IF (temp_temp > max_hold)
      max_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
     IF ((((min_hold=- (1.0))) OR (temp_temp < min_hold)) )
      min_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (max_hold >= 180)
  SET hold_diff = max_hold
  SET scores->hr_score = 4
 ELSEIF (min_hold <= 39
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->hr_score = 4
 ELSEIF (max_hold >= 140)
  SET hold_diff = max_hold
  SET scores->hr_score = 3
 ELSEIF (min_hold <= 54
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->hr_score = 3
 ELSEIF (max_hold >= 110)
  SET hold_diff = max_hold
  SET scores->hr_score = 2
 ELSEIF (max_hold <= 69
  AND min_hold > 0)
  SET hold_diff = max_hold
  SET scores->hr_score = 2
 ELSE
  SET hold_diff = max_hold
  SET scores->hr_score = 0
 ENDIF
 IF (hold_diff > 0)
  SET ap2_temp->worst_hr = hold_diff
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
 ELSE
  SET scores->enough_data_count = - (1)
 ENDIF
#worst_hr_exit
#worst_map
 SET max_hold = ap2_temp->worst_map
 SET min_hold = ap2_temp->worst_map
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET max_tag = - (1.0)
 SET min_tag = - (1.0)
 SET temp_map = 0.0
 SET hold_map = 0.0
 SET map_cd = 0.0
 SET map_cd = uar_get_code_by_cki("CKI.EC!6882")
 IF (map_cd <= 0.0)
  SET junk = "junk"
 ELSE
  SET midpoint = 90
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=ap2_temp->person_id)
     AND ce.event_cd=map_cd
     AND ce.event_end_dt_tm >= cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(ap2_parameters->cc_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm)
   HEAD REPORT
    hold_tag = 0.0, temp_temp = 0.0, temp_diff = 0.0,
    hold_diff = 0.0, isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_map = cnvtreal(ce.event_tag)
    ENDIF
    IF (temp_temp > max_hold)
     max_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
    ENDIF
    IF ((((min_hold=- (1.0))) OR (temp_temp < min_hold)) )
     min_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (max_hold >= 160)
  SET hold_diff = max_hold
  SET scores->map_score = 4
 ELSEIF (min_hold < 50
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->map_score = 4
 ELSEIF (max_hold >= 130)
  SET hold_diff = max_hold
  SET scores->map_score = 3
 ELSEIF (max_hold >= 110)
  SET hold_diff = max_hold
  SET scores->map_score = 2
 ELSEIF (min_hold < 70)
  SET hold_diff = max_hold
  SET scores->map_score = 2
 ELSE
  SET hold_diff = max_hold
  SET scores->map_score = 0
 ENDIF
 IF (hold_diff > 0)
  SET ap2_temp->worst_map = hold_diff
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
 ELSE
  SET scores->enough_data_count = - (1)
 ENDIF
#worst_map_exit
#worst_mean_bp
 SET max_hold = ap2_temp->worst_map
 SET min_hold = ap2_temp->worst_map
 SET event_tag_num = - (1.0)
 SET temp_sys = 0.0
 SET temp_dia = 0.0
 SET midpoint = 0.0
 SET max_tag = - (1.0)
 SET min_tag = - (1.0)
 SET temp_meanbp = 0.0
 SET hold_meanbp = 0.0
 SET systolic1_cd = 0.0
 SET diastolic1_cd = 0.0
 SET systolic2_cd = 0.0
 SET diastolic2_cd = 0.0
 SET systolic3_cd = 0.0
 SET diastolic3_cd = 0.0
 SET diastolic4_cd = 0.0
 SET systolic1_cd = uar_get_code_by_cki("CKI.EC!75")
 SET systolic2_cd = uar_get_code_by_cki("CKI.EC!7680")
 SET diastolic1_cd = uar_get_code_by_cki("CKI.EC!26")
 SET diastolic2_cd = uar_get_code_by_cki("CKI.EC!7681")
 SET diastolic3_cd = uar_get_code_by_cki(nullterm("CKI.EC!9370"))
 SET diastolic4_cd = uar_get_code_by_cki(nullterm("CKI.EC!9371"))
 SET systolic3_cd = uar_get_code_by_cki(nullterm("CKI.EC!9369"))
 IF (((systolic1_cd > 0.0
  AND diastolic1_cd > 0.0) OR (((systolic2_cd > 0.0
  AND diastolic2_cd > 0.0) OR (systolic3_cd > 0.0
  AND ((diastolic3_cd > 0.0) OR (diastolic4_cd > 0.0)) )) )) )
  SET midpoint = 90
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=ap2_temp->person_id)
     AND ce.event_cd IN (systolic1_cd, systolic2_cd, diastolic1_cd, diastolic2_cd, systolic3_cd,
    diastolic3_cd, diastolic4_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(ap2_parameters->cc_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm)
   HEAD REPORT
    hold_tag = 0.0, temp_temp1 = 0.0, temp_temp2 = 0.0,
    temp_temp3 = 0.0, temp_diff = 0.0, hold_diff = 0.0,
    isnum = 0, temp_sys1 = 0.0, temp_dia1 = 0.0,
    temp_sys2 = 0.0, temp_dia2 = 0.0, temp_sys3 = 0.0,
    temp_dia3 = 0.0, temp_dia4 = 0.0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     IF (ce.event_cd=systolic1_cd)
      temp_sys1 = cnvtreal(ce.event_tag)
     ELSEIF (ce.event_cd=systolic2_cd)
      temp_sys2 = cnvtreal(ce.event_tag)
     ELSEIF (ce.event_cd=diastolic1_cd)
      temp_dia1 = cnvtreal(ce.event_tag)
     ELSEIF (ce.event_cd=diastolic2_cd)
      temp_dia2 = cnvtreal(ce.event_tag)
     ELSEIF (ce.event_cd=systolic3_cd)
      temp_sys3 = cnvtreal(ce.event_tag)
     ELSEIF (ce.event_cd=diastolic3_cd)
      temp_dia3 = cnvtreal(ce.event_tag)
     ELSEIF (ce.event_cd=diastolic4_cd)
      temp_dia4 = cnvtreal(ce.event_tag)
     ENDIF
    ENDIF
   FOOT  ce.event_end_dt_tm
    IF (temp_sys1 > 0
     AND temp_dia1 > 0)
     temp_temp1 = (((temp_dia1 * 2)+ temp_sys1)/ 3)
    ENDIF
    IF (temp_sys2 > 0
     AND temp_dia2 > 0)
     temp_temp2 = (((temp_dia2 * 2)+ temp_sys2)/ 3)
    ENDIF
    IF (temp_sys3 > 0
     AND temp_dia3 > 0)
     temp_temp3 = (((temp_dia2 * 2)+ temp_sys2)/ 3)
    ELSEIF (temp_sys3 > 0
     AND temp_dia4 > 0)
     temp_temp3 = (((temp_dia2 * 2)+ temp_sys2)/ 3)
    ENDIF
    IF (temp_temp1 > max_hold)
     max_hold = temp_temp1, max_tag = cnvtreal(ce.event_tag)
    ENDIF
    IF (temp_temp2 > max_hold)
     max_hold = temp_temp2, max_tag = cnvtreal(ce.event_tag)
    ENDIF
    IF (temp_temp3 > max_hold)
     max_hold = temp_temp3, max_tag = cnvtreal(ce.event_tag)
    ENDIF
    IF ((((min_hold=- (1.0))) OR (temp_temp1 < min_hold)) )
     min_hold = temp_temp1, max_tag = cnvtreal(ce.event_tag)
    ENDIF
    IF ((((min_hold=- (1.0))) OR (temp_temp2 < min_hold)) )
     min_hold = temp_temp2, max_tag = cnvtreal(ce.event_tag)
    ENDIF
    IF ((((min_hold=- (1.0))) OR (temp_temp3 < min_hold)) )
     min_hold = temp_temp3, max_tag = cnvtreal(ce.event_tag)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (max_hold >= 160)
  SET hold_diff = max_hold
  SET scores->map_score = 4
 ELSEIF (min_hold < 50
  AND min_hold > 0)
  SET hold_diff = min_hold
  SET scores->map_score = 4
 ELSEIF (max_hold >= 130)
  SET hold_diff = max_hold
  SET scores->map_score = 3
 ELSEIF (max_hold >= 110)
  SET hold_diff = max_hold
  SET scores->map_score = 2
 ELSEIF (min_hold < 70)
  SET hold_diff = max_hold
  SET scores->map_score = 2
 ELSE
  SET hold_diff = max_hold
  SET scores->map_score = 0
 ENDIF
 IF (hold_diff > 0)
  SET ap2_temp->worst_map = hold_diff
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
 ELSE
  SET scores->enough_data_count = - (1)
 ENDIF
#worst_mean_bp_exit
#worst_potassium
 SET max_hold = ap2_temp->worst_potassium
 SET min_hold = ap2_temp->worst_potassium
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET max_tag = - (1.0)
 SET min_tag = - (1.0)
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3681")
 IF (res_cd > 0.0)
  SET junk = "junk"
 ELSE
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=ap2_temp->person_id)
     AND ce.event_cd=res_cd
     AND ce.event_end_dt_tm >= cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(ap2_parameters->cc_beg_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   HEAD REPORT
    hold_tag = 0.0, temp_temp = 0.0, temp_diff = 0.0,
    hold_diff = 0.0, isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_temp = cnvtreal(ce.event_tag)
     IF (temp_temp > max_hold)
      max_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
     IF ((((min_hold=- (1.0))) OR (temp_temp < min_hold)) )
      min_hold = temp_temp, max_tag = cnvtreal(ce.event_tag)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (max_hold >= 7)
  SET hold_diff = max_hold
  SET scores->potassium_score = 4
 ELSEIF (min_hold < 2.5)
  SET hold_dof = min_hold
  SET scores->potassium_score = 4
 ELSEIF (max_hold > 6)
  SET hold_diff = min_hold
  SET scores->potassium_score = 3
 ELSEIF (min_hold < 3.0)
  SET hold_diff = min_hold
  SET scores->potassium_score = 2
 ELSEIF (min_hold < 3.5)
  SET hold_diff = min_hold
  SET scores->potassium_score = 1
 ELSEIF (max_hold >= 5.5)
  SET hold_diff = max_hold
  SET scores->potassium_score = 1
 ELSE
  SET hold_diff = max_hold
  SET scores->potassium_score = 0
 ENDIF
 IF (hold_diff > 0)
  SET ap2_temp->worst_potassium = hold_diff
  SET scores->enough_data_count = (scores->enough_data_count+ 1)
 ELSE
  SET scores->enough_data_count = - (1)
 ENDIF
#worst_potassium_exit
#total_ap2_score
 SET scores->ap_ii_score = 0
 SET scores->ap_ii_score = (((scores->temp_score+ scores->map_score)+ scores->hr_score)+ scores->
 ph_score)
 SET scores->ap_ii_score = ((scores->ap_ii_score+ scores->rr_score)+ scores->oxygen_score)
 SET scores->ap_ii_score = ((scores->ap_ii_score+ scores->sodium_score)+ scores->potassium_score)
 SET scores->ap_ii_score = ((scores->ap_ii_score+ scores->hemat_score)+ scores->wbc_score)
 SET scores->ap_ii_score = ((scores->ap_ii_score+ scores->gcs_score)+ scores->age_score)
 SET scores->ap_ii_score = ((scores->ap_ii_score+ scores->chronic_score)+ scores->creat_score)
 SET ap2_reply->status_data.status = "a"
#total_ap2_score_exit
#write_ap2_score
 UPDATE  FROM risk_adjustment_day rad
  SET rad.apache_ii_score = scores->ap_ii_score
  WHERE (rad.risk_adjustment_id=ap2_parameters->risk_adjustment_id)
   AND (rad.cc_day=ap2_parameters->cc_day)
   AND rad.active_ind=1
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error updating risk_adjustment_day row with AP2 Score."
  SET success_flag = "N"
 ELSE
  SET ap2_reply->status_data.subeventstatus[1].targetobjectvalue = " "
  SET success_flag = "Y"
 ENDIF
#write_ap2_score_exit
#9999_exit_program
 CALL echorecord(ap2_temp)
 CALL echorecord(scores)
 CALL echorecord(ap2_reply)
END GO
