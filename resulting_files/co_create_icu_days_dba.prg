CREATE PROGRAM co_create_icu_days:dba
 RECORD reply(
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
 RECORD use_req_rad_record(
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
 RECORD use_rep_rad_record(
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
 SET reply->status_data.status = "F"
 SET failure = "F"
 DECLARE sfailed = c2 WITH private, noconstant("S")
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE j = i4 WITH public, noconstant(0)
 DECLARE k = i4 WITH public, noconstant(0)
 DECLARE n = i4 WITH public, noconstant(0)
 DECLARE use_size = i4 WITH public, noconstant(0)
 DECLARE use_rep_rad_size = i4 WITH public, noconstant(0)
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE serrmsg = vc
 DECLARE day_diff = f8 WITH public, noconstant(0.0)
 DECLARE last_cc_day = i4 WITH public, noconstant(0)
 DECLARE last_cc_end_dt_tm = dq8 WITH public, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE ra_id = f8 WITH public, noconstant(0.0)
 DECLARE req_size = i4 WITH public, noconstant(size(request->reclist,5))
 FOR (i = 1 TO req_size)
   IF ((request->reclist[i].last_cc_day < 1))
    SET sfailed = "F"
    SET serrmsg = concat(serrmsg,build("Invalid record - Require cc_day >= 1 - Record details:",
      "risk_adjustment_id = ",request->reclist[i].risk_adjustment_id,"last_cc_day = ",request->
      reclist[i].last_cc_day))
    CALL echo(build("sErrMsg = ",serrmsg))
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "co_create_icu_days"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
 ENDFOR
 FOR (i = 1 TO req_size)
  SET day_diff = datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(request->reclist[i].
    last_cc_end_dt_tm),1)
  IF (day_diff >= 0)
   SET request->reclist[i].ignore_flag = 0
   SET use_size = (use_size+ ceil(day_diff))
   SET request->reclist[i].numrecs_rad = ceil(day_diff)
   CALL echo(build("first day_diff = ",day_diff))
   CALL echo(build("first use_size = ",use_size))
  ELSE
   SET request->reclist[i].ignore_flag = 1
   CALL echo(build(
     "Ignoring record with flag 1 - last_cc_end_dt_tm in future - risk_adjustment_id = ",request->
     reclist[i].risk_adjustment_id," last_cc_end_dt_tm = ",cnvtdatetime(request->reclist[i].
      last_cc_end_dt_tm)," last_cc_day = ",
     request->reclist[i].last_cc_day))
  ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad,
   (dummyt d  WITH seq = req_size)
  PLAN (d
   WHERE (request->reclist[d.seq].ignore_flag=0))
   JOIN (rad
   WHERE (rad.risk_adjustment_id=request->reclist[d.seq].risk_adjustment_id)
    AND ((rad.active_ind+ 0)=1))
  DETAIL
   IF ((rad.cc_day > request->reclist[d.seq].last_cc_day))
    request->reclist[d.seq].ignore_flag = 2,
    CALL echo(build("Ignoring record with flag 2 - record exists - risk_adjustment_id = ",request->
     reclist[d.seq].risk_adjustment_id," last_cc_end_dt_tm = ",cnvtdatetime(request->reclist[d.seq].
      last_cc_end_dt_tm)," last_cc_day = ",
     request->reclist[d.seq].last_cc_day," compare with cc_day = ",rad.cc_day))
   ELSE
    dummy = 0,
    CALL echo(build("Not ignoring record with flag 2 - risk_adjustment_id = ",request->reclist[d.seq]
     .risk_adjustment_id," last_cc_end_dt_tm = ",cnvtdatetime(request->reclist[d.seq].
      last_cc_end_dt_tm)," cc_day = ",
     request->reclist[d.seq].last_cc_day))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("use_size before ignore checks = ",use_size))
 FOR (i = 1 TO req_size)
   IF ((request->reclist[i].ignore_flag > 0))
    SET use_size = (use_size - request->reclist[i].numrecs_rad)
   ENDIF
 ENDFOR
 CALL echo(build("Actual use_size = ",use_size))
 IF (use_size <= 0)
  SET sfailed = "F"
  SET serrmsg = concat(serrmsg,build("No valid records to add"))
  CALL echo(build("sErrMsg = ",serrmsg))
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "co_create_icu_days"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET failure = "Z"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(use_req_rad_record->reclist,use_size)
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
 SET stat = movereclist(default_rad_record->reclist,use_req_rad_record->reclist,1,1,1,
  0)
 IF (use_size > 1)
  SET stat = movereclist(use_req_rad_record->reclist,use_req_rad_record->reclist,1,2,(use_size - 1),
   0)
 ENDIF
 SET j = 0
 FOR (i = 1 TO req_size)
   IF ((request->reclist[i].ignore_flag=0))
    SET day_diff = datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(request->reclist[i].
      last_cc_end_dt_tm),1)
    FOR (k = 1 TO ceil(day_diff))
      SET j = (j+ 1)
      SET use_req_rad_record->reclist[j].risk_adjustment_id = request->reclist[i].risk_adjustment_id
      SET use_req_rad_record->reclist[j].cc_beg_dt_tm = datetimeadd(request->reclist[i].
       last_cc_end_dt_tm,((1.0/ 1440.0)+ (k - 1)))
      SET use_req_rad_record->reclist[j].cc_end_dt_tm = datetimeadd(request->reclist[i].
       last_cc_end_dt_tm,(1+ (k - 1)))
      SET use_req_rad_record->reclist[j].cc_day = ((request->reclist[i].last_cc_day+ 1)+ (k - 1))
    ENDFOR
   ENDIF
 ENDFOR
 CALL echo(build("j = ",j," use_size = ",use_size))
 CALL echorecord(use_req_rad_record)
 EXECUTE co_add_risk_adjustment_day  WITH replace("REQUEST","USE_REQ_RAD_RECORD"), replace("REPLY",
  "USE_REP_RAD_RECORD")
 SET use_rep_rad_size = size(use_rep_rad_record->reclist,5)
 SET stat = alterlist(reply->reclist,use_rep_rad_size)
 FOR (n = 1 TO use_rep_rad_size)
  SET reply->reclist[n].risk_adjustment_id = use_rep_rad_record->reclist[n].risk_adjustment_id
  SET reply->reclist[n].risk_adjustment_day_id = use_rep_rad_record->reclist[n].
  risk_adjustment_day_id
 ENDFOR
 IF (size(reply->reclist,5) > 0)
  SET failure = "S"
 ENDIF
#exit_script
 IF (failure="F")
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->reclist,0)
  SET reqinfo->commit_ind = 0
 ELSEIF (failure="Z")
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->reclist,0)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
