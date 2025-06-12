CREATE PROGRAM co_ops_create_next_day_rec:dba
 RECORD reply(
   1 num_rec_with_icu_day_created = i2
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
 RECORD temp_pred_req(
   1 reclist[*]
     2 person_id = f8
     2 encntr_id = f8
     2 cc_start_day = i2
     2 icu_admit_dt_tm = dq8
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
 DECLARE unset_date = vc WITH constant("31-DEC-2100 00:00:00:00")
 SET cnt = 0
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
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   encounter e,
   risk_adjustment_ref rar
  PLAN (ra
   WHERE ra.icu_disch_dt_tm=cnvtdatetime(value(unset_date))
    AND ra.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    rad.risk_adjustment_id
    FROM risk_adjustment_day rad
    WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
     AND rad.active_ind=1))))
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1)
   JOIN (rar
   WHERE rar.organization_id=e.organization_id
    AND rar.active_ind=1)
  ORDER BY ra.risk_adjustment_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(rad_request->reclist,cnt), stat = movereclist(default_rad_record
    ->reclist,rad_request->reclist,1,cnt,1,
    0),
   cc_day_start_time = rar.icu_day_start_time, icu_admit_dt_tm = ra.icu_admit_dt_tm, end_day1_date =
   cnvtdate(icu_admit_dt_tm),
   end_day1_dt_tm = cnvtdatetime(end_day1_date,cc_day_start_time), end_day1_dt_tm = datetimeadd(
    end_day1_dt_tm,- ((1.0/ 1440.0)))
   IF (datetimediff(cnvtdatetime(end_day1_dt_tm),cnvtdatetime(icu_admit_dt_tm)) < 0)
    end_day1_dt_tm = datetimeadd(end_day1_dt_tm,1)
   ENDIF
   IF (datetimediff(end_day1_dt_tm,icu_admit_dt_tm,3) < 8)
    end_day1_dt_tm = datetimeadd(end_day1_dt_tm,1)
   ENDIF
   rad_request->reclist[cnt].risk_adjustment_id = ra.risk_adjustment_id, rad_request->reclist[cnt].
   cc_beg_dt_tm = icu_admit_dt_tm, rad_request->reclist[cnt].cc_day = 1,
   rad_request->reclist[cnt].cc_end_dt_tm = end_day1_dt_tm
  WITH nocounter
 ;end select
 CALL echorecord(rad_request)
 IF (cnt > 0)
  EXECUTE co_add_risk_adjustment_day  WITH replace("REQUEST","RAD_REQUEST"), replace("REPLY",
   "RAD_REPLY")
  CALL echorecord(rad_reply)
 ENDIF
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad
  PLAN (ra
   WHERE ra.icu_disch_dt_tm=cnvtdatetime(value(unset_date))
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.active_ind=1)
  ORDER BY rad.risk_adjustment_id, rad.cc_day DESC
  HEAD REPORT
   cnt = 0
  HEAD rad.risk_adjustment_id
   cc_day = 0, cnt = (cnt+ 1), stat = alterlist(cc_day_request->reclist,cnt),
   stat = alterlist(temp_pred_req->reclist,cnt), cc_day_request->reclist[cnt].risk_adjustment_id = ra
   .risk_adjustment_id, temp_pred_req->reclist[cnt].person_id = ra.person_id,
   temp_pred_req->reclist[cnt].encntr_id = ra.encntr_id
  DETAIL
   IF (rad.cc_day > cc_day)
    cc_day = rad.cc_day, cc_end_dt_tm = rad.cc_end_dt_tm, icu_admit_dt_tm = ra.icu_admit_dt_tm
   ENDIF
  FOOT  rad.risk_adjustment_id
   cc_day_request->reclist[cnt].last_cc_day = cc_day, cc_day_request->reclist[cnt].last_cc_end_dt_tm
    = cc_end_dt_tm, temp_pred_req->reclist[cnt].cc_start_day = cc_day,
   temp_pred_req->reclist[cnt].icu_admit_dt_tm = icu_admit_dt_tm
  FOOT REPORT
   stat = alterlist(cc_day_request->reclist,cnt)
  WITH nocounter
 ;end select
 EXECUTE co_create_icu_days  WITH replace("REQUEST","CC_DAY_REQUEST"), replace("REPLY","CC_DAY_REPLY"
  )
 IF ((cc_day_reply->status_data.status != "S"))
  CALL set_reply_status(cc_day_reply->status_data.status,cc_day_reply->status_data.subeventstatus[1].
   operationname,cc_day_reply->status_data.subeventstatus[1].operationstatus,cc_day_reply->
   status_data.subeventstatus[1].targetobjectname,cc_day_reply->status_data.subeventstatus[1].
   targetobjectvalue)
  GO TO exit_script
 ENDIF
 SET list_size = size(temp_pred_req->reclist,5)
 FOR (indx = 1 TO list_size)
   SET pred_request->person_id = temp_pred_req->reclist[indx].person_id
   SET pred_request->encntr_id = temp_pred_req->reclist[indx].encntr_id
   SET pred_request->cc_start_day = temp_pred_req->reclist[indx].cc_start_day
   SET pred_request->icu_admit_dt_tm = temp_pred_req->reclist[indx].icu_admit_dt_tm
   CALL echorecord(pred_request)
   EXECUTE dcp_recalc_apache_predictions  WITH replace("REQUEST","PRED_REQUEST"), replace("REPLY",
    "PRED_REPLY")
 ENDFOR
 SET reply->num_rec_with_icu_day_created = size(cc_day_reply->reclist,5)
 CALL set_reply_status("S","","","","")
 CALL echorecord(reply)
#exit_script
 SUBROUTINE set_reply_status(status,opsname,opstatus,targetname,targetvalue)
   SET reply->status_data.status = status
   SET reply->status_data.subeventstatus[1].operationname = opsname
   SET reply->status_data.subeventstatus[1].operationstatus = opstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetvalue
 END ;Subroutine
END GO
