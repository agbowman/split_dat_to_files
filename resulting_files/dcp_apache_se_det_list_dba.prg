CREATE PROGRAM dcp_apache_se_det_list:dba
 RECORD reply(
   1 selist[*]
     2 encntr_id = f8
     2 icu_admit_dt_tm = dq8
     2 active_ind = i2
     2 icu_day = i2
     2 cc_beg_dt_tm = dq8
     2 cc_end_dt_tm = dq8
     2 valid_until_dt_tm = dq8
     2 intubated_ind = i2
     2 vent_ind = i2
     2 dialysis_ind = i2
     2 eyes = i4
     2 motor = i4
     2 verbal = i4
     2 meds_ind = i2
     2 urine = f8
     2 wbc = f8
     2 temp = f8
     2 resp = f8
     2 sodium = f8
     2 heartrate = f8
     2 meanbp = f8
     2 ph = f8
     2 hematocrit = f8
     2 creatinine = f8
     2 albumin = f8
     2 pao2 = f8
     2 pco2 = f8
     2 bun = f8
     2 glucose = f8
     2 bilirubin = f8
     2 potassium = f8
     2 fio2 = f8
     2 aps3day1 = i2
     2 aps3today = i2
     2 aps3yesterday = i2
     2 gender = i2
     2 teachtype = i2
     2 region = i2
     2 bedcount = i2
     2 admit_source = vc
     2 nbr_grafts_performed = i2
     2 age = i2
     2 icu_admit_dt_tm = dq8
     2 hosp_admit_dt_tm = dq8
     2 admitdiagnosis = vc
     2 thrombolytics_ind = i2
     2 diedinhospital_ind = i2
     2 aids_ind = i2
     2 hepaticfailure_ind = i2
     2 lymphoma_ind = i2
     2 metastaticcancer_ind = i2
     2 leukemia_ind = i2
     2 immunosuppression_ind = i2
     2 cirrhosis_ind = i2
     2 electivesurgery_ind = i2
     2 activetx_ind = i2
     2 vent_today_ind = i2
     2 pa_line_today_ind = i2
     2 readmit_ind = i2
     2 ima_ind = i2
     2 midur_ind = i2
     2 ventday1_ind = i2
     2 oobventday1_ind = i2
     2 oobintubday1_ind = i2
     2 diabetes_ind = i2
     2 var03hspxlos = f8
     2 ejectfx = f8
     2 aps_score = i4
     2 aps_day1 = i4
     2 aps_yesterday = i4
     2 phys_res_pts = i4
     2 outcome_status = i4
     2 copd_flag = i2
     2 copd_ind = i2
     2 xfer_within_48hr_ind = i2
     2 readmit_within_24hr_ind = i2
     2 ami_location = vc
     2 ptca_device = vc
     2 sv_graft_ind = i2
     2 mi_within_6mo_ind = i2
     2 cc_during_stay_ind = i2
     2 risk_adjustment_day_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD hdeath_parameters(
   1 risk_adjustment_id = f8
 )
 RECORD hdeath_reply(
   1 hosp_death_ind = i4
 )
 DECLARE meaning_code(p1,p2) = f8
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_read TO 2999_read_exit
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
 SET reply->status_data.status = "F"
 SET ambulatory_type_cd = meaning_code(222,"AMBULATORY")
 SET census_type_cd = meaning_code(339,"CENSUS")
 SET nurse_unit_type_cd = meaning_code(222,"NURSEUNIT")
 SET room_type_cd = meaning_code(222,"ROOM")
 SET attend_doc_cd = meaning_code(333,"ATTENDDOC")
 DECLARE nu_rm_bd = vc
#1999_initialize_exit
#2000_read
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad
  PLAN (ra
   WHERE (ra.person_id=request->person_id)
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.active_ind=1)
  ORDER BY ra.encntr_id, cnvtdatetime(ra.icu_admit_dt_tm), rad.cc_day DESC,
   cnvtdatetime(rad.valid_until_dt_tm) DESC
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->selist,cnt), reply->selist[cnt].encntr_id = ra.encntr_id,
   reply->selist[cnt].icu_admit_dt_tm = cnvtdatetime(ra.icu_admit_dt_tm), reply->selist[cnt].
   active_ind = rad.active_ind, reply->selist[cnt].icu_day = rad.cc_day,
   reply->selist[cnt].cc_beg_dt_tm = cnvtdatetime(rad.cc_beg_dt_tm), reply->selist[cnt].cc_end_dt_tm
    = cnvtdatetime(rad.cc_end_dt_tm), reply->selist[cnt].valid_until_dt_tm = cnvtdatetime(rad
    .valid_until_dt_tm),
   reply->selist[cnt].intubated_ind = rad.intubated_ind, reply->selist[cnt].vent_ind = rad.vent_ind,
   reply->selist[cnt].dialysis_ind = ra.dialysis_ind,
   reply->selist[cnt].eyes = rad.worst_gcs_eye_score, reply->selist[cnt].motor = rad
   .worst_gcs_motor_score, reply->selist[cnt].verbal = rad.worst_gcs_verbal_score,
   reply->selist[cnt].meds_ind = rad.meds_ind, reply->selist[cnt].urine = rad.urine_output, reply->
   selist[cnt].wbc = rad.worst_wbc_result,
   reply->selist[cnt].temp = rad.worst_temp, reply->selist[cnt].resp = rad.worst_resp_result, reply->
   selist[cnt].sodium = rad.worst_sodium_result,
   reply->selist[cnt].heartrate = rad.worst_heart_rate, reply->selist[cnt].meanbp = rad
   .mean_blood_pressure, reply->selist[cnt].ph = rad.worst_ph_result,
   reply->selist[cnt].hematocrit = rad.worst_hematocrit, reply->selist[cnt].creatinine = rad
   .worst_creatinine_result, reply->selist[cnt].albumin = rad.worst_albumin_result,
   reply->selist[cnt].pao2 = rad.worst_pao2_result, reply->selist[cnt].pco2 = rad.worst_pco2_result,
   reply->selist[cnt].bun = rad.worst_bun_result,
   reply->selist[cnt].glucose = rad.worst_glucose_result, reply->selist[cnt].bilirubin = rad
   .worst_bilirubin_result, reply->selist[cnt].potassium = rad.worst_potassium_result,
   reply->selist[cnt].fio2 = rad.worst_fio2_result, reply->selist[cnt].aps3day1 = (rad.aps_day1+ rad
   .phys_res_pts), reply->selist[cnt].aps3today = rad.apache_iii_score,
   reply->selist[cnt].aps3yesterday = (rad.aps_yesterday+ rad.phys_res_pts), reply->selist[cnt].
   gender = ra.gender_flag, reply->selist[cnt].teachtype = ra.teach_type_flag,
   reply->selist[cnt].region = ra.region_flag, reply->selist[cnt].bedcount = ra.bed_count, reply->
   selist[cnt].admit_source = ra.admit_source,
   reply->selist[cnt].nbr_grafts_performed = ra.nbr_grafts_performed, reply->selist[cnt].age = ra
   .admit_age, reply->selist[cnt].hosp_admit_dt_tm = cnvtdatetime(ra.hosp_admit_dt_tm),
   reply->selist[cnt].admitdiagnosis = ra.admit_diagnosis, reply->selist[cnt].thrombolytics_ind = ra
   .thrombolytics_ind, reply->selist[cnt].aids_ind = ra.aids_ind,
   reply->selist[cnt].hepaticfailure_ind = ra.hepaticfailure_ind, reply->selist[cnt].lymphoma_ind =
   ra.lymphoma_ind, reply->selist[cnt].metastaticcancer_ind = ra.metastaticcancer_ind,
   reply->selist[cnt].leukemia_ind = ra.leukemia_ind, reply->selist[cnt].immunosuppression_ind = ra
   .immunosuppression_ind, reply->selist[cnt].cirrhosis_ind = ra.cirrhosis_ind,
   reply->selist[cnt].electivesurgery_ind = ra.electivesurgery_ind, reply->selist[cnt].activetx_ind
    = rad.activetx_ind, reply->selist[cnt].readmit_ind = ra.readmit_ind,
   reply->selist[cnt].ima_ind = ra.ima_ind, reply->selist[cnt].midur_ind = ra.midur_ind, reply->
   selist[cnt].diabetes_ind = ra.diabetes_ind,
   reply->selist[cnt].var03hspxlos = ra.var03hspxlos_value, reply->selist[cnt].ejectfx = ra
   .ejectfx_fraction, reply->selist[cnt].aps_score = rad.aps_score,
   reply->selist[cnt].aps_day1 = rad.aps_day1, reply->selist[cnt].aps_yesterday = rad.aps_yesterday,
   reply->selist[cnt].vent_today_ind = rad.vent_today_ind,
   reply->selist[cnt].pa_line_today_ind = rad.pa_line_today_ind, reply->selist[cnt].outcome_status =
   rad.outcome_status, reply->selist[cnt].phys_res_pts = rad.phys_res_pts,
   reply->selist[cnt].copd_flag = ra.copd_flag, reply->selist[cnt].copd_ind = ra.copd_ind, reply->
   selist[cnt].xfer_within_48hr_ind = ra.xfer_within_48hr_ind,
   reply->selist[cnt].readmit_within_24hr_ind = ra.readmit_within_24hr_ind, reply->selist[cnt].
   ami_location = ra.ami_location, reply->selist[cnt].ptca_device = ra.ptca_device,
   reply->selist[cnt].sv_graft_ind = ra.sv_graft_ind, reply->selist[cnt].mi_within_6mo_ind = ra
   .mi_within_6mo_ind, reply->selist[cnt].cc_during_stay_ind = ra.cc_during_stay_ind,
   reply->selist[cnt].risk_adjustment_day_id = rad.risk_adjustment_day_id
  WITH nocounter
 ;end select
 SET hdeath_parameters->risk_adjustment_id = ra.risk_adjustment_id
 EXECUTE cco_get_died_hosp_from_ra
 SET reply->selist[cnt].diedinhospital_ind = hdeath_reply->hosp_death_ind
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#2999_read_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
