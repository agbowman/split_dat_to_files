CREATE PROGRAM dcp_recalc_apache_predictions:dba
 RECORD reply(
   1 recalc_days = i4
   1 risk_adjustment_day_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD recalc_record(
   1 risk_adjustment_id = f8
   1 cc_day = i2
   1 risk_adjustment_day_id = f8
   1 cc_beg_dt_tm = dq8
   1 cc_end_dt_tm = dq8
   1 intubated_ind = i2
   1 intubated_ce_id = f8
   1 vent_ind = i2
   1 eyes = i2
   1 eyes_ce_id = f8
   1 motor = i2
   1 motor_ce_id = f8
   1 verbal = i2
   1 verbal_ce_id = f8
   1 meds_ind = i2
   1 meds_ce_id = f8
   1 urine = f8
   1 urine_actual = f8
   1 wbc = f8
   1 wbc_ce_id = f8
   1 temp = f8
   1 temp_ce_id = f8
   1 resp = f8
   1 resp_ce_id = f8
   1 sodium = f8
   1 sodium_ce_id = f8
   1 heartrate = f8
   1 heartrate_ce_id = f8
   1 meanbp = f8
   1 ph = f8
   1 ph_ce_id = f8
   1 hematocrit = f8
   1 hematocrit_ce_id = f8
   1 creatinine = f8
   1 creatinine_ce_id = f8
   1 albumin = f8
   1 albumin_ce_id = f8
   1 pao2 = f8
   1 pao2_ce_id = f8
   1 pco2 = f8
   1 pco2_ce_id = f8
   1 bun = f8
   1 bun_ce_id = f8
   1 glucose = f8
   1 glucose_ce_id = f8
   1 bilirubin = f8
   1 bilirubin_ce_id = f8
   1 potassium = f8
   1 potassium_ce_id = f8
   1 fio2 = f8
   1 fio2_ce_id = f8
   1 vent_ce_id = f8
   1 meanbp_ce_ind = i2
   1 urine_ce_ind = i2
   1 activetx_ind = i2
   1 vent_today_ind = i2
   1 pa_line_today_ind = i2
   1 dialysis_ind = i2
   1 aids_ind = i2
   1 hepaticfailure_ind = i2
   1 lymphoma_ind = i2
   1 metastaticcancer_ind = i2
   1 leukemia_ind = i2
   1 immunosuppression_ind = i2
   1 cirrhosis_ind = i2
   1 thrombolytics_ind = i2
   1 diabetes_ind = i2
   1 copd_ind = i2
   1 chronic_health_unavail_ind = i2
   1 chronic_health_none_ind = i2
   1 electivesurgery_ind = i2
   1 readmit_ind = i2
   1 ima_ind = i2
   1 midur_ind = i2
   1 admitdiagnosis = vc
   1 admit_source = vc
   1 oobventday1_ind = i2
   1 oobintubday1_ind = i2
   1 ventday1_ind = i2
   1 nbr_grafts_performed = i2
   1 hosp_admit_dt_tm = dq8
   1 var03hspxlos = f8
   1 ejectfx = f8
   1 diedinhospital_ind = i2
   1 discharge_location = vc
   1 visit_number = i2
   1 ami_location = vc
 )
 RECORD aps_variable(
   1 sintubated = i2
   1 svent = i2
   1 sdialysis = i2
   1 seyes = i2
   1 smotor = i2
   1 sverbal = i2
   1 smeds = i2
   1 filler1 = c2
   1 dwurine = f8
   1 dwwbc = f8
   1 dwtemp = f8
   1 dwrespiratoryrate = f8
   1 dwsodium = f8
   1 dwheartrate = f8
   1 dwmeanbp = f8
   1 dwph = f8
   1 dwhematocrit = f8
   1 dwcreatinine = f8
   1 dwalbumin = f8
   1 dwpao2 = f8
   1 dwpco2 = f8
   1 dwbun = f8
   1 dwglucose = f8
   1 dwbilirubin = f8
   1 dwfio2 = f8
   1 filler2 = c50
 )
 IF (((cursys="AXP") OR (cursys2="HPX")) )
  RECORD aps_prediction(
    1 sicuday = i2
    1 saps3day1 = i2
    1 saps3today = i2
    1 saps3yesterday = i2
    1 sgender = i2
    1 steachtype = i2
    1 sregion = i2
    1 sbedcount = i2
    1 sadmitsource = i2
    1 sgraftcount = i2
    1 smeds = i2
    1 sverbal = i2
    1 smotor = i2
    1 seyes = i2
    1 sage = i2
    1 szicuadmitdate = c27
    1 szhospadmitdate = c27
    1 szadmitdiagnosis = c11
    1 filler1 = c1
    1 bthrombolytics = i2
    1 bdiedinhospital = i2
    1 baids = i2
    1 bhepaticfailure = i2
    1 blymphoma = i2
    1 bmetastaticcancer = i2
    1 bleukemia = i2
    1 bimmunosuppression = i2
    1 bcirrhosis = i2
    1 belectivesurgery = i2
    1 bactivetx = i2
    1 breadmit = i2
    1 bima = i2
    1 bmidur = i2
    1 bventday1 = i2
    1 boobventday1 = i2
    1 boobintubday1 = i2
    1 bdiabetes = i2
    1 bmanagementsystem = i2
    1 filler2 = c2
    1 dwvar03hspxlos = f8
    1 dwpao2 = f8
    1 dwfio2 = f8
    1 dwejectfx = f8
    1 dwcreatinine = f8
    1 sdischargelocation = i2
    1 svisitnumber = i2
    1 samilocation = i2
    1 szicuadmitdatetime = c27
    1 szhospadmitdatetime = c27
    1 sday1meds = i2
    1 sday1verbal = i2
    1 sday1motor = i2
    1 sday1eyes = i2
    1 filler3 = c4
    1 dwday1pao2 = f8
    1 dwday1fio2 = f8
  )
  RECORD aps_outcome(
    1 qual[100]
      2 cversionnumber = c1
      2 filler1 = c7
      2 dwoutcome = f8
      2 szequationname = c50
      2 filler2 = c2
      2 nequationnamenumber = i2
      2 filler2 = c2
  )
 ELSE
  RECORD aps_prediction(
    1 sicuday = i2
    1 saps3day1 = i2
    1 saps3today = i2
    1 saps3yesterday = i2
    1 sgender = i2
    1 steachtype = i2
    1 sregion = i2
    1 sbedcount = i2
    1 sadmitsource = i2
    1 sgraftcount = i2
    1 smeds = i2
    1 sverbal = i2
    1 smotor = i2
    1 seyes = i2
    1 sage = i2
    1 szicuadmitdate = c27
    1 szhospadmitdate = c27
    1 szadmitdiagnosis = c11
    1 filler1 = c1
    1 bthrombolytics = i2
    1 bdiedinhospital = i2
    1 baids = i2
    1 bhepaticfailure = i2
    1 blymphoma = i2
    1 bmetastaticcancer = i2
    1 bleukemia = i2
    1 bimmunosuppression = i2
    1 bcirrhosis = i2
    1 belectivesurgery = i2
    1 bactivetx = i2
    1 breadmit = i2
    1 bima = i2
    1 bmidur = i2
    1 bventday1 = i2
    1 boobventday1 = i2
    1 boobintubday1 = i2
    1 bdiabetes = i2
    1 bmanagementsystem = i2
    1 filler2 = c2
    1 dwvar03hspxlos = f8
    1 dwpao2 = f8
    1 dwfio2 = f8
    1 dwejectfx = f8
    1 dwcreatinine = f8
    1 sdischargelocation = i2
    1 svisitnumber = i2
    1 samilocation = i2
    1 szicuadmitdatetime = c27
    1 szhospadmitdatetime = c27
    1 sday1meds = i2
    1 sday1verbal = i2
    1 sday1motor = i2
    1 sday1eyes = i2
    1 dwday1pao2 = f8
    1 dwday1fio2 = f8
  )
  RECORD aps_outcome(
    1 qual[100]
      2 cversionnumber = c1
      2 filler1 = c3
      2 dwoutcome = f8
      2 szequationname = c50
      2 filler2 = c2
      2 nequationnamenumber = i2
      2 filler2 = c2
  )
 ENDIF
 RECORD ap2_parameters(
   1 risk_adjustment_id = f8
   1 cc_day = i2
   1 cc_beg_dt_tm = dq8
   1 cc_end_dt_tm = dq8
 )
 RECORD hdeath_parameters(
   1 risk_adjustment_id = f8
 )
 RECORD hdeath_reply(
   1 hosp_death_ind = i4
 )
 RECORD get_visit_parameters(
   1 risk_adjustment_id = f8
 )
 RECORD get_visit_reply(
   1 visit_number = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ra_id = f8
 DECLARE status = i4
 DECLARE aps_status = i4
 DECLARE outcome_status = i4
 DECLARE teach_type_flag = i2
 DECLARE region_flag = i2
 DECLARE bedcount = i4
 DECLARE use_map_ind = i2
 DECLARE apache_age(birth_dt_tm,admit_dt_tm) = i2
 SET reply->status_data.status = "S"
 SET failed_ind = "N"
 DECLARE failed_text = vc
 DECLARE actual_urine = f8
 DECLARE age_in_years = i2
 DECLARE act_icu_ever = f8
 DECLARE meaning_code(p1,p2) = f8
 SET phys_res_pts = - (1)
 SET aps_score = - (1)
 SET aps_day1 = - (1)
 SET aps_yesterday = - (1)
 SET age_in_years = - (1)
 SET gender = - (1)
 SET outcome_status = - (1.0)
 SET act_icu_ever = - (1.0)
 SET cc_end_day = request->cc_start_day
 SET day1meds = - (1)
 SET day1verbal = - (1)
 SET day1motor = - (1)
 SET day1eyes = - (1)
 SET day1pao2 = - (1.0)
 SET day1fio2 = - (1.0)
 EXECUTE apachertl
 SET male_cd = meaning_code(57,"MALE")
 SET female_cd = meaning_code(57,"FEMALE")
 EXECUTE FROM load_ra TO load_ra_exit
 IF (ra_id < 0.0)
  SET failed_ind = "Y"
  SET failed_text = "UNABLE TO LOAD RISK_ADJUSTMENT RECORD!"
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM load_encntr TO load_encntr_exit
 IF (failed_ind="Y")
  SET failed_text = "UNABLE TO LOAD RISK_ADJUSTMENT RECORD!"
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM load_rar TO load_rar_exit
 IF (failed_ind="Y")
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM load_person TO load_person_exit
 IF (failed_ind="Y")
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM count_days TO count_days_exit
 IF (failed_ind="Y")
  GO TO 9999_exit_program
 ENDIF
 IF ((cc_end_day >= request->cc_start_day))
  FOR (recalc_day_num = request->cc_start_day TO cc_end_day)
   EXECUTE FROM 2700_recalc TO 2799_recalc_exit
   IF (failed_ind="Y")
    GO TO 9999_exit_program
   ENDIF
  ENDFOR
 ENDIF
 GO TO 9999_exit_program
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
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#load_ra
 SET ra_id = - (1.0)
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  PLAN (ra
   WHERE (ra.person_id=request->person_id)
    AND (ra.encntr_id=request->encntr_id)
    AND ra.icu_admit_dt_tm=cnvtdatetime(request->icu_admit_dt_tm)
    AND ra.active_ind=1)
  DETAIL
   ra_id = ra.risk_adjustment_id, recalc_record->risk_adjustment_id = ra.risk_adjustment_id
  WITH nocounter
 ;end select
#load_ra_exit
#count_days
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad
  PLAN (ra
   WHERE ra.risk_adjustment_id=ra_id
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.active_ind=1
    AND (rad.cc_day >= request->cc_start_day))
  ORDER BY rad.cc_day
  DETAIL
   cc_end_day = rad.cc_day
  WITH nocounter
 ;end select
#count_days_exit
#load_encntr
 SET org_id = 0.0
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id)
    AND e.active_ind=1)
  DETAIL
   org_id = e.organization_id
  WITH nocounter
 ;end select
 IF (org_id=0.0)
  SET failed_ind = "Y"
  SET failed_text = "Error loading a valid org_id from encounter table."
 ENDIF
#load_encntr_exit
#load_rar
 SET teach_type_flag = - (1)
 SELECT INTO "nl:"
  FROM risk_adjustment_ref rar
  PLAN (rar
   WHERE rar.organization_id=org_id
    AND rar.active_ind=1)
  DETAIL
   IF (rar.teach_type_flag IN (0, 1, 2))
    teach_type_flag = rar.teach_type_flag
   ENDIF
   IF (rar.region_flag IN (1, 2, 3, 4))
    region_flag = rar.region_flag
   ENDIF
   IF (rar.bed_count > 0)
    bedcount = rar.bed_count
   ENDIF
  WITH nocounter
 ;end select
 IF (teach_type_flag < 0)
  SET failed_ind = "Y"
  SET failed_text = build("Error reading risk_adjustment_ref table.",org_id)
 ENDIF
#load_rar_exit
#load_person
 SET age_in_years = - (1)
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   person p
  PLAN (ra
   WHERE (ra.risk_adjustment_id=recalc_record->risk_adjustment_id)
    AND ra.active_ind=1)
   JOIN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
  HEAD REPORT
   agex = "            ", age_in_mo = 0
  DETAIL
   CALL echo("got in detail"),
   CALL echo(build("p.person_id=",p.person_id)),
   CALL echo(build("name =",p.name_full_formatted)),
   CALL echo(build("dob=",p.birth_dt_tm)), recalc_record->electivesurgery_ind = ra
   .electivesurgery_ind, recalc_record->readmit_ind = ra.readmit_ind,
   recalc_record->ima_ind = ra.ima_ind, recalc_record->midur_ind = ra.midur_ind, recalc_record->
   admitdiagnosis = ra.admit_diagnosis,
   recalc_record->admit_source = ra.admit_source, recalc_record->discharge_location =
   uar_get_code_meaning(ra.discharge_location_cd)
   IF (ra.diedinicu_ind=1)
    recalc_record->discharge_location = "DEATH"
   ENDIF
   recalc_record->nbr_grafts_performed = ra.nbr_grafts_performed, recalc_record->hosp_admit_dt_tm =
   ra.hosp_admit_dt_tm, recalc_record->var03hspxlos = ra.var03hspxlos_value,
   recalc_record->ejectfx = ra.ejectfx_fraction, recalc_record->dialysis_ind = ra.dialysis_ind,
   recalc_record->aids_ind = ra.aids_ind,
   recalc_record->hepaticfailure_ind = ra.hepaticfailure_ind, recalc_record->lymphoma_ind = ra
   .lymphoma_ind, recalc_record->metastaticcancer_ind = ra.metastaticcancer_ind,
   recalc_record->leukemia_ind = ra.leukemia_ind, recalc_record->immunosuppression_ind = ra
   .immunosuppression_ind, recalc_record->cirrhosis_ind = ra.cirrhosis_ind,
   recalc_record->thrombolytics_ind = ra.thrombolytics_ind, recalc_record->diabetes_ind = ra
   .diabetes_ind, recalc_record->copd_ind = ra.copd_ind,
   recalc_record->chronic_health_unavail_ind = ra.chronic_health_unavail_ind, recalc_record->
   chronic_health_none_ind = ra.chronic_health_none_ind, recalc_record->ami_location = ra
   .ami_location
   IF (p.sex_cd=male_cd)
    gender = 0
   ELSEIF (p.sex_cd=female_cd)
    gender = 1
   ENDIF
   IF (cnvtdatetime(p.birth_dt_tm)=0)
    age_in_years = - (1)
   ELSE
    age_in_years = apache_age(p.birth_dt_tm,ra.hosp_admit_dt_tm)
   ENDIF
  WITH nocounter
 ;end select
 SET hdeath_parameters->risk_adjustment_id = recalc_record->risk_adjustment_id
 EXECUTE cco_get_died_hosp_from_ra
 SET recalc_record->diedinhospital_ind = hdeath_reply->hosp_death_ind
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE rad.risk_adjustment_id=ra_id
    AND rad.cc_day=1
    AND rad.active_ind=1)
  DETAIL
   recalc_record->oobventday1_ind = rad.vent_ind, recalc_record->oobintubday1_ind = rad.intubated_ind,
   recalc_record->ventday1_ind = rad.vent_today_ind
  WITH nocounter
 ;end select
 SET get_visit_parameters->risk_adjustment_id = value(recalc_record->risk_adjustment_id)
 EXECUTE cco_get_apache_visit_number
#load_person_exit
#2700_recalc
 SET outcome_status = - (1)
 SET risk_adjustment_day_id = 0.0
 SET recalc_record->risk_adjustment_day_id = - (1)
 SET recalc_record->cc_day = - (1)
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE rad.risk_adjustment_id=ra_id
    AND rad.cc_day=recalc_day_num
    AND rad.active_ind=1)
  DETAIL
   recalc_record->risk_adjustment_day_id = rad.risk_adjustment_day_id, recalc_record->cc_day = rad
   .cc_day, recalc_record->cc_beg_dt_tm = cnvtdatetime(rad.cc_beg_dt_tm),
   recalc_record->cc_end_dt_tm = cnvtdatetime(rad.cc_end_dt_tm), recalc_record->intubated_ind = rad
   .intubated_ind, recalc_record->intubated_ce_id = rad.intubated_ce_id,
   recalc_record->vent_ind = rad.vent_ind, recalc_record->eyes = rad.worst_gcs_eye_score,
   recalc_record->eyes_ce_id = rad.eyes_ce_id,
   recalc_record->motor = rad.worst_gcs_motor_score, recalc_record->motor_ce_id = rad.motor_ce_id,
   recalc_record->verbal = rad.worst_gcs_verbal_score,
   recalc_record->verbal_ce_id = rad.verbal_ce_id, recalc_record->meds_ind = rad.meds_ind,
   recalc_record->meds_ce_id = rad.meds_ce_id,
   recalc_record->urine = rad.urine_24hr_output, recalc_record->urine_actual = rad.urine_output,
   recalc_record->wbc = rad.worst_wbc_result,
   recalc_record->wbc_ce_id = rad.wbc_ce_id, recalc_record->temp = rad.worst_temp, recalc_record->
   temp_ce_id = rad.temp_ce_id,
   recalc_record->resp = rad.worst_resp_result, recalc_record->resp_ce_id = rad.resp_ce_id,
   recalc_record->sodium = rad.worst_sodium_result,
   recalc_record->sodium_ce_id = rad.sodium_ce_id, recalc_record->heartrate = rad.worst_heart_rate,
   recalc_record->heartrate_ce_id = rad.heartrate_ce_id,
   recalc_record->meanbp = rad.mean_blood_pressure, recalc_record->ph = rad.worst_ph_result,
   recalc_record->ph_ce_id = rad.ph_ce_id,
   recalc_record->hematocrit = rad.worst_hematocrit, recalc_record->hematocrit_ce_id = rad
   .hematocrit_ce_id, recalc_record->creatinine = rad.worst_creatinine_result,
   recalc_record->creatinine_ce_id = rad.creatinine_ce_id, recalc_record->albumin = rad
   .worst_albumin_result, recalc_record->albumin_ce_id = rad.albumin_ce_id,
   recalc_record->pao2 = rad.worst_pao2_result, recalc_record->pao2_ce_id = rad.pao2_ce_id,
   recalc_record->pco2 = rad.worst_pco2_result,
   recalc_record->pco2_ce_id = rad.pco2_ce_id, recalc_record->bun = rad.worst_bun_result,
   recalc_record->bun_ce_id = rad.bun_ce_id,
   recalc_record->glucose = rad.worst_glucose_result, recalc_record->glucose_ce_id = rad
   .glucose_ce_id, recalc_record->bilirubin = rad.worst_bilirubin_result,
   recalc_record->bilirubin_ce_id = rad.bilirubin_ce_id, recalc_record->potassium = rad
   .worst_potassium_result, recalc_record->potassium_ce_id = rad.potassium_ce_id,
   recalc_record->fio2 = rad.worst_fio2_result, recalc_record->fio2_ce_id = rad.fio2_ce_id,
   recalc_record->activetx_ind = - (1),
   recalc_record->vent_today_ind = - (1), recalc_record->pa_line_today_ind = - (1), recalc_record->
   vent_ce_id = rad.vent_ce_id,
   recalc_record->meanbp_ce_ind = rad.map_ce_ind, recalc_record->urine_ce_ind = rad.urine_ce_ind
  WITH nocounter
 ;end select
 IF ((recalc_record->risk_adjustment_day_id > 0))
  EXECUTE FROM validate_activetx_ind TO validate_activetx_ind_exit
  CALL echo(build("aps_status=",aps_status))
  CALL echo(build("age_in_years=",age_in_years))
  IF (age_in_years < 16)
   CALL echo("got less than 16")
   IF (age_in_years < 0)
    SET outcome_status = - (23110)
   ELSE
    SET outcome_status = - (23103)
   ENDIF
  ELSE
   EXECUTE FROM get_aps_info TO get_aps_info_exit
   EXECUTE FROM get_phys_res TO get_phys_res_exit
   IF (aps_status >= 0)
    EXECUTE FROM get_outcomes TO get_outcomes_exit
   ELSE
    SET outcome_status = aps_status
   ENDIF
  ENDIF
  EXECUTE FROM create_rad_rao TO create_rad_rao_exit
  EXECUTE FROM inactivate_rad_rao TO inactivate_rad_rao_exit
 ELSE
  SET outcome_status = - (1)
 ENDIF
#2799_recalc_exit
#validate_activetx_ind
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adj_tiss rat,
   code_value cv
  PLAN (ra
   WHERE (ra.risk_adjustment_id=recalc_record->risk_adjustment_id)
    AND ra.active_ind=1)
   JOIN (rat
   WHERE rat.risk_adjustment_id=ra.risk_adjustment_id
    AND rat.tiss_beg_dt_tm <= cnvtdatetime(recalc_record->cc_end_dt_tm)
    AND rat.tiss_end_dt_tm >= cnvtdatetime(recalc_record->cc_beg_dt_tm)
    AND rat.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=rat.tiss_cd
    AND cv.code_set=value(29747)
    AND cv.active_ind=1)
  HEAD REPORT
   recalc_record->vent_today_ind = - (1), recalc_record->activetx_ind = - (1), recalc_record->
   pa_line_today_ind = - (1)
  DETAIL
   IF ((recalc_record->vent_today_ind=- (1)))
    recalc_record->vent_today_ind = 0
   ENDIF
   IF ((recalc_record->activetx_ind=- (1)))
    recalc_record->activetx_ind = 0
   ENDIF
   IF ((recalc_record->pa_line_today_ind=- (1)))
    recalc_record->pa_line_today_ind = 0
   ENDIF
   IF (cv.display_key IN ("PEEP", "CONTVENT", "ASREP", "PRESSSUP", "CPAPPRES",
   "BIPAP"))
    recalc_record->vent_today_ind = 1
   ENDIF
   IF (cv.display_key="PALINE")
    recalc_record->pa_line_today_ind = 1
   ENDIF
   IF (substring(1,1,cv.definition)="Y")
    recalc_record->activetx_ind = 1
   ENDIF
  WITH nocounter
 ;end select
#validate_activetx_ind_exit
#get_aps_info
 SET aps_variable->sintubated = recalc_record->intubated_ind
 SET aps_variable->svent = recalc_record->vent_ind
 SET aps_variable->sdialysis = recalc_record->dialysis_ind
 SET aps_variable->seyes = recalc_record->eyes
 SET aps_variable->smotor = recalc_record->motor
 SET aps_variable->sverbal = recalc_record->verbal
 SET aps_variable->smeds = recalc_record->meds_ind
 SET aps_variable->dwurine = recalc_record->urine
 SET aps_variable->dwwbc = recalc_record->wbc
 IF ((recalc_record->temp < 50))
  SET aps_variable->dwtemp = recalc_record->temp
 ELSE
  SET aps_variable->dwtemp = (((recalc_record->temp - 32) * 5)/ 9)
 ENDIF
 SET aps_variable->dwrespiratoryrate = recalc_record->resp
 SET aps_variable->dwsodium = recalc_record->sodium
 SET aps_variable->dwheartrate = recalc_record->heartrate
 SET aps_variable->dwmeanbp = recalc_record->meanbp
 SET aps_variable->dwph = recalc_record->ph
 SET aps_variable->dwhematocrit = recalc_record->hematocrit
 SET aps_variable->dwcreatinine = recalc_record->creatinine
 SET aps_variable->dwalbumin = recalc_record->albumin
 SET aps_variable->dwpao2 = recalc_record->pao2
 SET aps_variable->dwpco2 = recalc_record->pco2
 SET aps_variable->dwbun = recalc_record->bun
 SET aps_variable->dwglucose = recalc_record->glucose
 SET aps_variable->dwbilirubin = recalc_record->bilirubin
 SET aps_variable->dwfio2 = recalc_record->fio2
 EXECUTE FROM 5000_get_carry_over TO 5099_get_carry_over_exit
 IF ((aps_variable->svent < 0))
  SET status = - (22003)
 ELSE
  SET status = uar_amsapscalculate(aps_variable)
 ENDIF
 SET aps_status = status
 SET aps_score = status
 IF (status < 0)
  SET aps_score = - (1)
 ENDIF
 IF ((recalc_record->cc_day=1))
  SET aps_day1 = aps_score
  SET aps_yesterday = 0
  SET day1meds = recalc_record->meds_ind
  SET day1verbal = recalc_record->verbal
  SET day1motor = recalc_record->motor
  SET day1eyes = recalc_record->eyes
  SET day1pao2 = recalc_record->pao2
  SET day1fio2 = recalc_record->fio2
 ELSE
  SET day_one_found = "N"
  SET yesterday_found = "N"
  SELECT INTO "nl:"
   FROM risk_adjustment ra,
    risk_adjustment_day rad
   PLAN (ra
    WHERE (ra.person_id=request->person_id)
     AND (ra.encntr_id=request->encntr_id)
     AND ra.icu_admit_dt_tm=cnvtdatetime(request->icu_admit_dt_tm)
     AND ra.active_ind=1)
    JOIN (rad
    WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
     AND rad.active_ind=1
     AND ((rad.cc_day=1) OR ((rad.cc_day=(recalc_record->cc_day - 1)))) )
   DETAIL
    age_in_years = ra.admit_age
    IF (rad.cc_day=1)
     aps_day1 = rad.aps_score, day_one_found = "Y"
     IF ((recalc_record->cc_day=2))
      aps_yesterday = rad.aps_score, yesterday_found = "Y"
     ENDIF
    ELSEIF ((rad.cc_day=(recalc_record->cc_day - 1)))
     aps_yesterday = rad.aps_score, yesterday_found = "Y"
    ENDIF
   WITH nocounter
  ;end select
  IF (((day_one_found="N") OR (yesterday_found="N")) )
   SET aps_status = - (1)
  ENDIF
 ENDIF
 CALL echo(build("Recalc_Record->cc_day = ",recalc_record->cc_day))
 CALL echo(build("aps_yesterday = ",aps_yesterday))
 CALL echo(build("aps_score = ",aps_score))
#get_aps_info_exit
#get_phys_res
 IF ((recalc_record->aids_ind=0)
  AND (recalc_record->hepaticfailure_ind=0)
  AND (recalc_record->lymphoma_ind=0)
  AND (recalc_record->metastaticcancer_ind=0)
  AND (recalc_record->leukemia_ind=0)
  AND (recalc_record->immunosuppression_ind=0)
  AND (recalc_record->cirrhosis_ind=0)
  AND (recalc_record->diabetes_ind=0)
  AND (recalc_record->copd_ind=0)
  AND (recalc_record->chronic_health_unavail_ind=0)
  AND (recalc_record->chronic_health_none_ind=0))
  SET phys_res_pts = - (1)
 ELSE
  SET phys_res_pts = 0
  IF (age_in_years BETWEEN 45 AND 59)
   SET phys_res_pts = 5
  ELSEIF (age_in_years BETWEEN 60 AND 64)
   SET phys_res_pts = 11
  ELSEIF (age_in_years BETWEEN 65 AND 69)
   SET phys_res_pts = 13
  ELSEIF (age_in_years BETWEEN 70 AND 74)
   SET phys_res_pts = 16
  ELSEIF (age_in_years BETWEEN 75 AND 84)
   SET phys_res_pts = 17
  ELSEIF (age_in_years > 84)
   SET phys_res_pts = 24
  ENDIF
  IF ((recalc_record->electivesurgery_ind != 1))
   IF ((recalc_record->aids_ind=1))
    SET phys_res_pts = (phys_res_pts+ 23)
   ELSEIF ((recalc_record->hepaticfailure_ind=1))
    SET phys_res_pts = (phys_res_pts+ 16)
   ELSEIF ((recalc_record->lymphoma_ind=1))
    SET phys_res_pts = (phys_res_pts+ 13)
   ELSEIF ((recalc_record->metastaticcancer_ind=1))
    SET phys_res_pts = (phys_res_pts+ 11)
   ELSEIF ((recalc_record->leukemia_ind=1))
    SET phys_res_pts = (phys_res_pts+ 10)
   ELSEIF ((recalc_record->immunosuppression_ind=1))
    SET phys_res_pts = (phys_res_pts+ 10)
   ELSEIF ((recalc_record->cirrhosis_ind=1))
    SET phys_res_pts = (phys_res_pts+ 4)
   ENDIF
  ENDIF
 ENDIF
#get_phys_res_exit
#get_outcomes
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=recalc_record->risk_adjustment_id)
    AND rad.cc_day=1
    AND rad.active_ind=1)
  DETAIL
   recalc_record->oobintubday1_ind = rad.intubated_ind, recalc_record->oobventday1_ind = rad.vent_ind,
   recalc_record->ventday1_ind = rad.vent_today_ind
  WITH nocounter
 ;end select
 SET aps_prediction->sicuday = recalc_record->cc_day
 SET aps_prediction->saps3day1 = aps_day1
 SET aps_prediction->saps3today = aps_score
 SET aps_prediction->saps3yesterday = aps_yesterday
 SET aps_prediction->sgender = gender
 SET aps_prediction->steachtype = teach_type_flag
 SET aps_prediction->sregion = region_flag
 SET aps_prediction->sbedcount = bedcount
 IF ((recalc_record->admit_source IN ("CHPAIN_CTR", "ICU", "ICU_TO_OR")))
  SET aps_prediction->sadmitsource = 5
 ELSEIF ((recalc_record->admit_source="OR"))
  SET aps_prediction->sadmitsource = 1
 ELSEIF ((recalc_record->admit_source="RR"))
  SET aps_prediction->sadmitsource = 2
 ELSEIF ((recalc_record->admit_source="ER"))
  SET aps_prediction->sadmitsource = 3
 ELSEIF ((recalc_record->admit_source="FLOOR"))
  SET aps_prediction->sadmitsource = 4
 ELSEIF ((recalc_record->admit_source="OTHER_HOSP"))
  SET aps_prediction->sadmitsource = 6
 ELSEIF ((recalc_record->admit_source="DIR_ADMIT"))
  SET aps_prediction->sadmitsource = 7
 ELSEIF ((recalc_record->admit_source IN ("SDU", "ICU_TO_SDU")))
  SET aps_prediction->sadmitsource = 8
 ENDIF
 SET aps_prediction->sgraftcount = recalc_record->nbr_grafts_performed
 SET aps_prediction->smeds = recalc_record->meds_ind
 SET aps_prediction->sverbal = recalc_record->verbal
 SET aps_prediction->smotor = recalc_record->motor
 SET aps_prediction->seyes = recalc_record->eyes
 SET aps_prediction->sage = age_in_years
 SET abc = fillstring(20," ")
 SET abc = format(request->icu_admit_dt_tm,"mm/dd/yyyy;;d")
 SET aps_prediction->szicuadmitdate = concat(trim(abc),char(0))
 SET abc = fillstring(20," ")
 SET abc = format(recalc_record->hosp_admit_dt_tm,"mm/dd/yyyy;;d")
 SET aps_prediction->szhospadmitdate = concat(trim(abc),char(0))
 SET aps_prediction->szadmitdiagnosis = concat(trim(recalc_record->admitdiagnosis),char(0))
 SET aps_prediction->bthrombolytics = recalc_record->thrombolytics_ind
 SET aps_prediction->bdiedinhospital = recalc_record->diedinhospital_ind
 SET aps_prediction->baids = recalc_record->aids_ind
 SET aps_prediction->bhepaticfailure = recalc_record->hepaticfailure_ind
 SET aps_prediction->blymphoma = recalc_record->lymphoma_ind
 SET aps_prediction->bmetastaticcancer = recalc_record->metastaticcancer_ind
 SET aps_prediction->bleukemia = recalc_record->leukemia_ind
 SET aps_prediction->bimmunosuppression = recalc_record->immunosuppression_ind
 SET aps_prediction->bcirrhosis = recalc_record->cirrhosis_ind
 IF ((recalc_record->aids_ind=0)
  AND (recalc_record->hepaticfailure_ind=0)
  AND (recalc_record->lymphoma_ind=0)
  AND (recalc_record->metastaticcancer_ind=0)
  AND (recalc_record->leukemia_ind=0)
  AND (recalc_record->immunosuppression_ind=0)
  AND (recalc_record->cirrhosis_ind=0)
  AND (recalc_record->diabetes_ind=0)
  AND (recalc_record->copd_ind=0)
  AND (recalc_record->chronic_health_unavail_ind=0)
  AND (recalc_record->chronic_health_none_ind=0))
  SET aps_prediction->baids = - (1)
  SET aps_prediction->bhepaticfailure = - (1)
  SET aps_prediction->blymphoma = - (1)
  SET aps_prediction->bmetastaticcancer = - (1)
  SET aps_prediction->bleukemia = - (1)
  SET aps_prediction->bimmunosuppression = - (1)
  SET aps_prediction->bcirrhosis = - (1)
 ENDIF
 SET aps_prediction->belectivesurgery = recalc_record->electivesurgery_ind
 SET aps_prediction->bactivetx = recalc_record->activetx_ind
 SET aps_prediction->breadmit = recalc_record->readmit_ind
 SET aps_prediction->bima = recalc_record->ima_ind
 SET aps_prediction->bmidur = recalc_record->midur_ind
 SET aps_prediction->bventday1 = recalc_record->ventday1_ind
 SET aps_prediction->boobventday1 = maxval(recalc_record->oobventday1_ind,recalc_record->ventday1_ind
  )
 SET aps_prediction->boobintubday1 = recalc_record->oobintubday1_ind
 SET aps_prediction->bdiabetes = recalc_record->diabetes_ind
 SET aps_prediction->bmanagementsystem = 1
 SET aps_prediction->dwvar03hspxlos = recalc_record->var03hspxlos
 SET aps_prediction->dwpao2 = recalc_record->pao2
 SET aps_prediction->dwfio2 = recalc_record->fio2
 SET aps_prediction->dwejectfx = recalc_record->ejectfx
 SET aps_prediction->dwcreatinine = recalc_record->creatinine
 IF ((recalc_record->discharge_location="FLOOR"))
  SET aps_prediction->sdischargelocation = 4
 ELSEIF ((recalc_record->discharge_location="ICU_TRANSFER"))
  SET aps_prediction->sdischargelocation = 5
 ELSEIF ((recalc_record->discharge_location="OTHER_HOSP"))
  SET aps_prediction->sdischargelocation = 6
 ELSEIF ((recalc_record->discharge_location="HOME"))
  SET aps_prediction->sdischargelocation = 7
 ELSEIF ((recalc_record->discharge_location="OTHER"))
  SET aps_prediction->sdischargelocation = 8
 ELSEIF ((recalc_record->discharge_location="DEATH"))
  SET aps_prediction->sdischargelocation = 9
 ELSE
  SET aps_prediction->sdischargelocation = - (1)
 ENDIF
 SET aps_prediction->svisitnumber = get_visit_reply->visit_number
 IF ((recalc_record->ami_location="ANT"))
  SET aps_prediction->samilocation = 1
 ELSEIF ((recalc_record->ami_location="ANTLAT"))
  SET aps_prediction->samilocation = 2
 ELSEIF ((recalc_record->ami_location="ANTSEP"))
  SET aps_prediction->samilocation = 3
 ELSEIF ((recalc_record->ami_location="INF"))
  SET aps_prediction->samilocation = 4
 ELSEIF ((recalc_record->ami_location="LAT"))
  SET aps_prediction->samilocation = 5
 ELSEIF ((recalc_record->ami_location="NONQ"))
  SET aps_prediction->samilocation = 6
 ELSEIF ((recalc_record->ami_location="POST"))
  SET aps_prediction->samilocation = 7
 ELSE
  SET aps_prediction->samilocation = - (1)
 ENDIF
 SET abc = fillstring(20," ")
 SET abc = format(request->icu_admit_dt_tm,"mm/dd/yyyy hh:mm;;d")
 SET aps_prediction->szicuadmitdatetime = concat(trim(abc),char(0))
 SET abc = fillstring(20," ")
 SET abc = format(recalc_record->hosp_admit_dt_tm,"mm/dd/yyyy hh:mm;;d")
 SET aps_prediction->szhospadmitdatetime = concat(trim(abc),char(0))
 SET aps_prediction->sday1meds = day1meds
 SET aps_prediction->sday1verbal = day1verbal
 SET aps_prediction->sday1motor = day1motor
 SET aps_prediction->sday1eyes = day1eyes
 SET aps_prediction->dwday1pao2 = day1pao2
 SET aps_prediction->dwday1fio2 = day1fio2
 EXECUTE FROM print_input TO print_input_exit
 SET status = uar_amscalculatepredictions(aps_prediction,aps_outcome)
 CALL echo(build("STATUS IS: ",status))
 IF (status < 0)
  CALL echo(build("uar_AmsCalculatePredictions err=",uar_amsraprinterror(status)))
 ELSE
  CALL echo(build("outcomes:",status))
 ENDIF
 SET outcome_status = status
#get_outcomes_exit
#create_rad_rao
 SET failed_ind = "N"
 SET ap2_qual = 0
 SET se_array_size = 0
 SET rad_id = 0.0
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   rad_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 IF (rad_id=0.0)
  CALL echo("get carenet failed")
  SET failed_ind = "Y"
  SET failed_text = "Error reading from carenet sequence, write new risk_adjustment_day row."
 ELSE
  IF (aps_score >= 0
   AND phys_res_pts >= 0)
   SET ap3_score = value((aps_score+ phys_res_pts))
  ELSE
   SET ap3_score = - (1)
  ENDIF
  SET reply->risk_adjustment_day_id = rad_id
  CALL echo(build("saving Recalc_Record->verbal_ce_id=",recalc_record->verbal_ce_id))
  INSERT  FROM risk_adjustment_day rad
   SET rad.risk_adjustment_day_id = rad_id, rad.risk_adjustment_id = ra_id, rad.cc_day =
    recalc_record->cc_day,
    rad.cc_beg_dt_tm = cnvtdatetime(recalc_record->cc_beg_dt_tm), rad.cc_end_dt_tm = cnvtdatetime(
     recalc_record->cc_end_dt_tm), rad.valid_from_dt_tm = cnvtdatetime(curdate,curtime3),
    rad.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), rad.intubated_ind = recalc_record->
    intubated_ind, rad.intubated_ce_id = recalc_record->intubated_ce_id,
    rad.vent_ind = recalc_record->vent_ind, rad.worst_gcs_eye_score = recalc_record->eyes, rad
    .eyes_ce_id = recalc_record->eyes_ce_id,
    rad.worst_gcs_motor_score = recalc_record->motor, rad.motor_ce_id = recalc_record->motor_ce_id,
    rad.worst_gcs_verbal_score = recalc_record->verbal,
    rad.verbal_ce_id = recalc_record->verbal_ce_id, rad.meds_ind = recalc_record->meds_ind, rad
    .meds_ce_id = recalc_record->meds_ce_id,
    rad.urine_output = recalc_record->urine_actual, rad.urine_24hr_output = recalc_record->urine, rad
    .worst_wbc_result = recalc_record->wbc,
    rad.wbc_ce_id = recalc_record->wbc_ce_id, rad.worst_temp = recalc_record->temp, rad.temp_ce_id =
    recalc_record->temp_ce_id,
    rad.worst_resp_result = recalc_record->resp, rad.resp_ce_id = recalc_record->resp_ce_id, rad
    .worst_sodium_result = recalc_record->sodium,
    rad.sodium_ce_id = recalc_record->sodium_ce_id, rad.worst_heart_rate = recalc_record->heartrate,
    rad.heartrate_ce_id = recalc_record->heartrate_ce_id,
    rad.mean_blood_pressure = recalc_record->meanbp, rad.worst_ph_result = recalc_record->ph, rad
    .ph_ce_id = recalc_record->ph_ce_id,
    rad.worst_hematocrit = recalc_record->hematocrit, rad.hematocrit_ce_id = recalc_record->
    hematocrit_ce_id, rad.worst_creatinine_result = recalc_record->creatinine,
    rad.creatinine_ce_id = recalc_record->creatinine_ce_id, rad.worst_albumin_result = recalc_record
    ->albumin, rad.albumin_ce_id = recalc_record->albumin_ce_id,
    rad.worst_pao2_result = recalc_record->pao2, rad.pao2_ce_id = recalc_record->pao2_ce_id, rad
    .worst_pco2_result = recalc_record->pco2,
    rad.pco2_ce_id = recalc_record->pco2_ce_id, rad.worst_bun_result = recalc_record->bun, rad
    .bun_ce_id = recalc_record->bun_ce_id,
    rad.worst_glucose_result = recalc_record->glucose, rad.glucose_ce_id = recalc_record->
    glucose_ce_id, rad.worst_bilirubin_result = recalc_record->bilirubin,
    rad.bilirubin_ce_id = recalc_record->bilirubin_ce_id, rad.worst_potassium_result = recalc_record
    ->potassium, rad.potassium_ce_id = recalc_record->potassium_ce_id,
    rad.worst_fio2_result = recalc_record->fio2, rad.fio2_ce_id = recalc_record->fio2_ce_id, rad
    .aps_score = aps_score,
    rad.aps_day1 = aps_day1, rad.aps_yesterday = aps_yesterday, rad.activetx_ind = recalc_record->
    activetx_ind,
    rad.vent_today_ind = recalc_record->vent_today_ind, rad.pa_line_today_ind = recalc_record->
    pa_line_today_ind, rad.outcome_status = outcome_status,
    rad.apache_iii_score = ap3_score, rad.apache_ii_score = - (1), rad.phys_res_pts = value(
     phys_res_pts),
    rad.active_ind = 1, rad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rad
    .active_status_prsnl_id = reqinfo->updt_id,
    rad.active_status_cd = reqdata->active_status_cd, rad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    rad.updt_id = reqinfo->updt_id,
    rad.updt_task = reqinfo->updt_task, rad.updt_applctx = 699096, rad.updt_cnt = 0,
    rad.vent_ce_id = recalc_record->vent_ce_id, rad.map_ce_ind = recalc_record->meanbp_ce_ind, rad
    .urine_ce_ind = recalc_record->urine_ce_ind
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed_ind = "Y"
   SET failed_text = "Error writing new risk_adjustment_day row."
   CALL echo("failed insert RAD")
  ELSE
   IF (ap2_qual=0)
    SELECT INTO "nl:"
     FROM risk_adjustment_event rae
     WHERE rae.risk_adjustment_id=ra_id
      AND rae.active_ind=1
      AND rae.beg_effective_dt_tm < cnvtdatetime(recalc_record->cc_end_dt_tm)
      AND rae.end_effective_dt_tm > cnvtdatetime(recalc_record->cc_beg_dt_tm)
     DETAIL
      IF (uar_get_code_display(rae.sentinel_event_code_cd)="SEPSIS*")
       ap2_qual = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((recalc_record->admitdiagnosis="SEPSIS*"))
    SET ap2_qual = 1
   ENDIF
   IF (ap2_qual=1)
    SET ap2_parameters->risk_adjustment_id = ra_id
    SET ap2_parameters->cc_day = recalc_record->cc_day
    SET ap2_parameters->cc_beg_dt_tm = cnvtdatetime(recalc_record->cc_beg_dt_tm)
    SET ap2_parameters->cc_end_dt_tm = cnvtdatetime(recalc_record->cc_end_dt_tm)
    EXECUTE dcp_calc_apache_ii_score
   ENDIF
   SET act_icu_ever = - (1.0)
   IF (outcome_status > 0)
    FOR (num = 1 TO 100)
      IF ((aps_outcome->qual[num].szequationname > " "))
       SET equation_name = trim(aps_outcome->qual[num].szequationname)
       IF ((recalc_record->cc_day=1))
        IF (equation_name="ACT_ICU_EVER")
         SET act_icu_ever = - (1.0)
         SET act_icu_ever = aps_outcome->qual[num].dwoutcome
        ENDIF
       ENDIF
       SET rao_id = 0.0
       SELECT INTO "nl:"
        j = seq(carenet_seq,nextval)
        FROM dual
        DETAIL
         rao_id = cnvtreal(j)
        WITH format, nocounter
       ;end select
       IF (rao_id=0.0)
        CALL echo("get carenet failed")
        SET failed_ind = "Y"
        SET failed_text =
        "Error reading from carenet sequence, write new risk_adjustment_outcomes row."
       ELSE
        INSERT  FROM risk_adjustment_outcomes rao
         SET rao.risk_adjustment_outcomes_id = rao_id, rao.risk_adjustment_day_id = rad_id, rao
          .equation_name = trim(equation_name),
          rao.outcome_value = aps_outcome->qual[num].dwoutcome, rao.valid_from_dt_tm = cnvtdatetime(
           curdate,curtime3), rao.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
          rao.active_ind = 1, rao.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rao
          .active_status_prsnl_id = reqinfo->updt_id,
          rao.active_status_cd = reqdata->active_status_cd, rao.updt_dt_tm = cnvtdatetime(curdate,
           curtime3), rao.updt_id = reqinfo->updt_id,
          rao.updt_task = reqinfo->updt_task, rao.updt_applctx = reqinfo->updt_applctx, rao.updt_cnt
           = 0
         WITH nocounter
        ;end insert
        SET aps_outcome->qual[num].szequationname = " "
        IF (curqual=0)
         SET failed_ind = "Y"
         SET failed_text = "Error writing new risk_adjustment_outcomes row."
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
 IF ((recalc_record->cc_day=1)
  AND failed_ind="N")
  SET therapy_level = - (1)
  IF ((((outcome_status=- (23117))) OR ((((outcome_status=- (23100))) OR ((outcome_status=- (23103))
  )) )) )
   IF ((recalc_record->activetx_ind=1))
    SET therapy_level = 5
   ELSEIF ((recalc_record->activetx_ind=0))
    SET therapy_level = 4
   ENDIF
  ELSE
   IF ((recalc_record->activetx_ind=1))
    SET therapy_level = 1
   ELSEIF ((recalc_record->activetx_ind=0)
    AND outcome_status > 0
    AND act_icu_ever >= 0)
    IF (((act_icu_ever * 100.0) <= 10.0))
     SET therapy_level = 2
    ELSE
     SET therapy_level = 3
    ENDIF
   ENDIF
  ENDIF
  UPDATE  FROM risk_adjustment ra
   SET ra.therapy_level = therapy_level
   WHERE ra.risk_adjustment_id=ra_id
   WITH nocounter
  ;end update
 ENDIF
#create_rad_rao_exit
#inactivate_rad_rao
 UPDATE  FROM risk_adjustment_day rad
  SET rad.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rad.active_ind = 0, rad
   .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   rad.updt_dt_tm = cnvtdatetime(curdate,curtime3), rad.updt_task = reqinfo->updt_task, rad
   .updt_applctx = reqinfo->updt_applctx,
   rad.updt_id = reqinfo->updt_id, rad.updt_cnt = (rad.updt_cnt+ 1)
  WHERE (rad.risk_adjustment_day_id=recalc_record->risk_adjustment_day_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed_ind = "Y"
  SET failed_text = build(risk_adjustment_day_id,"Error inactivating risk_adjustment_day row.")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  UPDATE  FROM risk_adjustment_outcomes rao
   SET rao.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rao.active_ind = 0, rao
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    rao.updt_dt_tm = cnvtdatetime(curdate,curtime3), rao.updt_task = reqinfo->updt_task, rao
    .updt_applctx = reqinfo->updt_applctx,
    rao.updt_id = reqinfo->updt_id, rao.updt_cnt = (rao.updt_cnt+ 1)
   WHERE (rao.risk_adjustment_day_id=recalc_record->risk_adjustment_day_id)
   WITH nocounter
  ;end update
 ENDIF
#inactivate_rad_rao_exit
#5000_get_carry_over
 SET stillneed2find = 0
 IF ((aps_variable->dwwbc=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((aps_variable->dwsodium=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((aps_variable->dwhematocrit=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((aps_variable->dwcreatinine=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((aps_variable->dwalbumin=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((aps_variable->dwbilirubin=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((aps_variable->dwbun=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((aps_variable->dwglucose=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 SET check_cc_day = recalc_day_num
 SET check_cc_day = (check_cc_day - 1)
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad
  PLAN (ra
   WHERE (ra.person_id=request->person_id)
    AND (ra.encntr_id=request->encntr_id)
    AND ra.icu_admit_dt_tm=cnvtdatetime(request->icu_admit_dt_tm)
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.cc_day <= check_cc_day
    AND rad.active_ind=1)
  ORDER BY rad.cc_day DESC
  DETAIL
   IF ((aps_variable->dwwbc=- (1))
    AND (rad.worst_wbc_result > - (1)))
    stillneed2find = (stillneed2find - 1), aps_variable->dwwbc = rad.worst_wbc_result
   ENDIF
   IF ((aps_variable->dwhematocrit=- (1))
    AND (rad.worst_hematocrit > - (1)))
    stillneed2find = (stillneed2find - 1), aps_variable->dwhematocrit = rad.worst_hematocrit
   ENDIF
   IF ((aps_variable->dwsodium=- (1))
    AND (rad.worst_sodium_result > - (1)))
    stillneed2find = (stillneed2find - 1), aps_variable->dwsodium = rad.worst_sodium_result
   ENDIF
   IF ((aps_variable->dwbun=- (1))
    AND (rad.worst_bun_result > - (1)))
    stillneed2find = (stillneed2find - 1), aps_variable->dwbun = rad.worst_bun_result
   ENDIF
   IF ((aps_variable->dwcreatinine=- (1))
    AND (rad.worst_creatinine_result > - (1)))
    stillneed2find = (stillneed2find - 1), aps_variable->dwcreatinine = rad.worst_creatinine_result
   ENDIF
   IF ((aps_variable->dwglucose=- (1))
    AND (rad.worst_glucose_result > - (1)))
    stillneed2find = (stillneed2find - 1), aps_variable->dwglucose = rad.worst_glucose_result
   ENDIF
   IF ((aps_variable->dwalbumin=- (1))
    AND (rad.worst_albumin_result > - (1)))
    stillneed2find = (stillneed2find - 1), aps_variable->dwalbumin = rad.worst_albumin_result
   ENDIF
   IF ((aps_variable->dwbilirubin=- (1))
    AND (rad.worst_bilirubin_result > - (1)))
    stillneed2find = (stillneed2find - 1), aps_variable->dwbilirubin = rad.worst_bilirubin_result
   ENDIF
  WITH nocounter
 ;end select
#5099_get_carry_over_exit
#print_input
 CALL echorecord(aps_prediction)
#print_input_exit
#9999_exit_program
 IF (failed_ind="Y")
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = failed_text
 ENDIF
 CALL echorecord(reply)
END GO
