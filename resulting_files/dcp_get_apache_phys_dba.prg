CREATE PROGRAM dcp_get_apache_phys:dba
 RECORD reply(
   1 cc_day = i4
   1 risk_adjustment_day_id = f8
   1 cc_beg_dt_tm = dq8
   1 cc_end_dt_tm = dq8
   1 valid_from_dt_tm = dq8
   1 carry_over_flags = i4
   1 intubated_ind = i2
   1 intubated_ce_id = f8
   1 vent_ind = i2
   1 eyes = i4
   1 eyes_ce_id = f8
   1 motor = i4
   1 motor_ce_id = f8
   1 verbal = i4
   1 verbal_ce_id = f8
   1 meds_ind = i2
   1 meds_ce_id = f8
   1 urine = f8
   1 urine_total = f8
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
   1 activetx_ind = i2
   1 vent_today_ind = i2
   1 pa_line_today_ind = i2
   1 updt_name = vc
   1 updt_dt_tm = dq8
   1 accept_worst_lab_ind = i2
   1 accept_worst_vitals_ind = i2
   1 accept_urine_output_ind = i2
   1 oth_cc_day[*]
     2 oth_cc_beg_dt_tm = dq8
     2 oth_cc_end_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 cc_day[*]
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 RECORD aado2_set(
   1 weight = i2
   1 aado2 = f8
   1 pao2 = f8
   1 pco2 = f8
   1 fio2 = f8
   1 ph = f8
   1 intub = i2
   1 date = dq8
   1 intubated_ce_id = f8
   1 pao2_ce_id = f8
   1 pco2_ce_id = f8
   1 fio2_ce_id = f8
   1 ph_ce_id = f8
 )
 RECORD intub_set(
   1 weight = i2
   1 pao2 = f8
   1 pco2 = f8
   1 fio2 = f8
   1 ph = f8
   1 intub = i2
   1 date = dq8
   1 intubated_ce_id = f8
   1 pao2_ce_id = f8
   1 pco2_ce_id = f8
   1 fio2_ce_id = f8
   1 ph_ce_id = f8
 )
 RECORD recalc_parameters(
   1 risk_adjustment_id = f8
   1 cc_start_day = i2
 )
 RECORD recalc_record(
   1 risk_adjustment_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 cc_day = i2
   1 risk_adjustment_day_id = f8
   1 icu_admit_dt_tm = f8
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
 RECORD apache_recalc_reply(
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
 DECLARE failed_text = vc WITH noconstant(fillstring(300," "))
 DECLARE failed_ind = vc WITH noconstant("N")
 DECLARE carry_flag = i4
 DECLARE ra_id = f8
 DECLARE found_new_worst = i2
 DECLARE status = i4
 DECLARE aps_status = i4
 DECLARE outcome_status = i4
 DECLARE teach_type_flag = i2
 DECLARE region_flag = i2
 DECLARE bedcount = i4
 DECLARE apache_recalc_reply_ra_day_id = f8
 DECLARE age_in_years = i2
 DECLARE filtered_fio2 = vc
 DECLARE apache_age(birth_dt_tm,admit_dt_tm) = i2
 DECLARE check_for_string(p1,p2) = vc
 DECLARE meaning_code(p1,p2) = f8
 SET reqinfo->commit_ind = 1
 SET day1meds = - (1)
 SET day1verbal = - (1)
 SET day1motor = - (1)
 SET day1eyes = - (1)
 SET day1pao2 = - (1.0)
 SET day1fio2 = - (1.0)
 EXECUTE FROM pre_initialize_in TO pre_initialize_exit
 IF ((request->person_id > 0.0)
  AND (request->encntr_id > 0.0)
  AND (request->icu_admit_dt_tm < cnvtdatetime(curdate,curtime3)))
  EXECUTE FROM 1000_initialize TO 1099_initialize_exit
  CALL echo("TOP")
  IF ((request->cc_day > 0))
   CALL echo(build("request->cc_day=",request->cc_day))
   SET cc_day = request->cc_day
   EXECUTE FROM 2100_read_risk_adjustment TO 2199_risk_adjustment_exit
   CALL echo(build("ra_entry_found=",ra_entry_found))
   IF (ra_entry_found="Y")
    SET reply->status_data.status = "S"
    EXECUTE FROM 4100_chk_new_values TO 4199_chk_new_values_exit
    IF (found_new_worst=1
     AND (((reply->urine > - (1))) OR ((((reply->wbc > - (1))) OR ((((reply->temp > - (1))) OR ((((
    reply->resp > - (1))) OR ((((reply->sodium > - (1))) OR ((((reply->heartrate > - (1))) OR ((((
    reply->meanbp > - (1))) OR ((((reply->fio2 > - (1))) OR ((((reply->hematocrit > - (1))) OR ((((
    reply->creatinine > - (1))) OR ((((reply->albumin > - (1))) OR ((((reply->bilirubin > - (1))) OR
    ((((reply->eyes > - (1))) OR ((((reply->meds_ind > - (1))) OR ((((reply->potassium > - (1))) OR (
    (((reply->bun > - (1))) OR ((reply->glucose > - (1)))) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
    )) )
     CALL echo(build("1about to call 8000 reply->risk_adjustment_day_id=",reply->
       risk_adjustment_day_id))
     EXECUTE FROM 8000_save_worst_phys TO 8099_save_worst_phys_exit
     CALL echo(build("1 ra_id=",ra_id))
     SET recalc_parameters->risk_adjustment_id = ra_id
     SET recalc_parameters->cc_start_day = reply->cc_day
     IF ((recalc_parameters->cc_start_day > 0))
      EXECUTE FROM recalc_apache_predictions TO recalc_apache_predictions_exit
      CALL echo(build("1resetting reply->rad_id after RECALC = ",apache_recalc_reply_ra_day_id))
      SET reply->risk_adjustment_day_id = apache_recalc_reply_ra_day_id
     ENDIF
    ENDIF
    EXECUTE FROM 5000_get_carry_over TO 5099_get_carry_over_exit
    GO TO 9999_exit_program
   ENDIF
  ENDIF
  CALL echo("OTHER DAYS????")
  EXECUTE FROM 2200_read_ra TO 2299_read_ra_exit
  EXECUTE FROM 3000_oth_cc_days TO 3099_oth_cc_days_exit
  IF (ra_entry_found="Y")
   SET reply->status_data.status = "S"
   EXECUTE FROM 4000_chk_new_values TO 4099_chk_new_values_exit
   IF (found_new_worst=1
    AND (((reply->urine > - (1))) OR ((((reply->wbc > - (1))) OR ((((reply->temp > - (1))) OR ((((
   reply->resp > - (1))) OR ((((reply->sodium > - (1))) OR ((((reply->heartrate > - (1))) OR ((((
   reply->meanbp > - (1))) OR ((((reply->fio2 > - (1))) OR ((((reply->hematocrit > - (1))) OR ((((
   reply->eyes > - (1))) OR ((((reply->meds_ind > - (1))) OR ((((reply->creatinine > - (1))) OR ((((
   reply->albumin > - (1))) OR ((((reply->bilirubin > - (1))) OR ((((reply->potassium > - (1))) OR (
   (((reply->bun > - (1))) OR ((reply->glucose > - (1)))) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )
    CALL echo(build("2about to call 8000 reply->risk_adjustment_day_id=",reply->
      risk_adjustment_day_id))
    EXECUTE FROM 8000_save_worst_phys TO 8099_save_worst_phys_exit
    CALL echo(build("2 ra_id=",ra_id))
    SET recalc_parameters->risk_adjustment_id = ra_id
    SET recalc_parameters->cc_start_day = reply->cc_day
    IF ((recalc_parameters->cc_start_day > 0))
     EXECUTE FROM recalc_apache_predictions TO recalc_apache_predictions_exit
     CALL echo(build("2resetting reply->rad_id after RECALC = ",apache_recalc_reply_ra_day_id))
     SET reply->risk_adjustment_day_id = apache_recalc_reply_ra_day_id
    ENDIF
   ENDIF
   EXECUTE FROM 5000_get_carry_over TO 5099_get_carry_over_exit
   GO TO 9999_exit_program
  ENDIF
  CALL echo(build("just before 2000 call  reply->risk_adjustment_day_id=",reply->
    risk_adjustment_day_id))
  EXECUTE FROM 2000_read TO 2099_read_exit
  IF (found_new_worst=1
   AND (((reply->urine > - (1))) OR ((((reply->wbc > - (1))) OR ((((reply->temp > - (1))) OR ((((
  reply->resp > - (1))) OR ((((reply->sodium > - (1))) OR ((((reply->heartrate > - (1))) OR ((((reply
  ->meanbp > - (1))) OR ((((reply->fio2 > - (1))) OR ((((reply->hematocrit > - (1))) OR ((((reply->
  eyes > - (1))) OR ((((reply->meds_ind > - (1))) OR ((((reply->creatinine > - (1))) OR ((((reply->
  albumin > - (1))) OR ((((reply->bilirubin > - (1))) OR ((((reply->potassium > - (1))) OR ((((reply
  ->bun > - (1))) OR ((reply->glucose > - (1)))) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
   CALL echo(build("3about to call 8000 reply->risk_adjustment_day_id=",reply->risk_adjustment_day_id
     ))
   EXECUTE FROM 8000_save_worst_phys TO 8099_save_worst_phys_exit
   CALL echo(build("3 ra_id=",ra_id))
   SET recalc_parameters->risk_adjustment_id = ra_id
   SET recalc_parameters->cc_start_day = reply->cc_day
   IF ((recalc_parameters->cc_start_day > 0))
    EXECUTE FROM recalc_apache_predictions TO recalc_apache_predictions_exit
    CALL echo(build("3resetting reply->rad_id after RECALC = ",apache_recalc_reply_ra_day_id))
    SET reply->risk_adjustment_day_id = apache_recalc_reply_ra_day_id
   ENDIF
  ENDIF
  EXECUTE FROM 5000_get_carry_over TO 5099_get_carry_over_exit
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "QUERY"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_GET_APACHE_PHYS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Request not filled out properly: person_id,encntr_id & ",
   "icu_admit_dt_tm required. ICU admit dt/tm must be < current dt/tm.")
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
 SUBROUTINE check_for_string(input_string,search_string)
  IF (size(search_string,1) < size(input_string,1))
   SET input_size = size(input_string,1)
   SET search_size = size(search_string,1)
   SET start_pos = ((input_size - search_size)+ 1)
   SET check_string = substring(start_pos,search_size,input_string)
   IF (check_string=search_string)
    SET return_string = substring(1,(input_size - search_size),input_string)
   ELSE
    SET return_string = input_string
   ENDIF
  ELSE
   SET return_string = input_string
  ENDIF
  RETURN(return_string)
 END ;Subroutine
#pre_initialize_in
 SET reply->cc_day = - (1)
 SET reply->intubated_ind = - (1)
 SET reply->vent_ind = - (1)
 SET reply->urine = - (1)
 SET reply->urine_total = - (1)
 SET reply->wbc = - (1)
 SET reply->temp = - (1)
 SET reply->resp = - (1)
 SET reply->sodium = - (1)
 SET reply->heartrate = - (1)
 SET reply->meanbp = - (1)
 SET reply->ph = - (1)
 SET reply->hematocrit = - (1)
 SET reply->creatinine = - (1)
 SET reply->albumin = - (1)
 SET reply->pao2 = - (1)
 SET reply->pco2 = - (1)
 SET reply->bun = - (1)
 SET reply->glucose = - (1)
 SET reply->bilirubin = - (1)
 SET reply->potassium = - (1)
 SET reply->fio2 = - (1)
#pre_initialize_exit
#1000_initialize
 SET reply->status_data.status = "F"
 SET cc_day = 0
 SET ra_entry_found = "N"
 SET d1 = 0.0
 SET d2 = 0.0
 SET d3 = 0.0
 SET h1 = 0
 SET h2 = 0
 SET m1 = 0
 SET m2 = 0
 SET reg_dt_tm = cnvtdatetime((curdate+ 10),curtime3)
 SET disch_dt_tm = cnvtdatetime((curdate+ 10),curtime3)
 SET beg_day1_dt_tm = cnvtdatetime((curdate+ 10),curtime3)
 SET end_day1_dt_tm = cnvtdatetime((curdate+ 10),curtime3)
 SET cc_day_start_time = 0700
 SET event_tag_num = 0.0
 SET ce_id = 0.0
 SET last_cc_day_written = 0
 SET disch_ind = 0
 SET org_id = 0.0
 SET inerror_cd = meaning_code(8,"INERROR")
 SET reply->accept_worst_lab_ind = 1
 SET reply->accept_worst_vitals_ind = 1
 SET reply->accept_urine_output_ind = 1
 SET reply->urine = - (1)
 SET reply->urine_total = - (1)
 SET day_cnt = 0
 SET new_day_cnt = 0
 SET reply->carry_over_flags = 0
 SET carry_flag = 0
 SET found_new_worst = 0
 SET age_in_years = 0
 SET failed_ind = "N"
 SET failed_text = fillstring(100," ")
 SET auto_calc_intubated_ind = 0
 SELECT INTO "nl:"
  FROM encounter e
  WHERE (e.encntr_id=request->encntr_id)
   AND e.active_ind=1
  DETAIL
   org_id = e.organization_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM risk_adjustment_ref rar
  PLAN (rar
   WHERE rar.organization_id=org_id
    AND rar.active_ind=1)
  DETAIL
   cc_day_start_time = rar.icu_day_start_time, reply->accept_worst_lab_ind = rar.accept_worst_lab_ind,
   reply->accept_worst_vitals_ind = rar.accept_worst_vitals_ind,
   reply->accept_urine_output_ind = rar.accept_urine_output_ind, auto_calc_intubated_ind = rar
   .auto_calc_intubated_ind
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   person p
  PLAN (ra
   WHERE (ra.person_id=request->person_id)
    AND (ra.encntr_id=request->encntr_id)
    AND ra.icu_admit_dt_tm=cnvtdatetime(request->icu_admit_dt_tm)
    AND ra.active_ind=1)
   JOIN (p
   WHERE p.person_id=ra.person_id
    AND p.active_ind=1)
  DETAIL
   ra_id = ra.risk_adjustment_id, age_in_years = apache_age(p.birth_dt_tm,ra.hosp_admit_dt_tm)
  WITH nocounter
 ;end select
#1099_initialize_exit
#2000_read
 IF ((request->cc_day <= 0))
  SET cc_day = (last_cc_day_written+ 1)
  IF (cc_day > day_cnt)
   SET cc_day = day_cnt
  ENDIF
 ELSE
  SET cc_day = request->cc_day
 ENDIF
 IF ((recalc_parameters->cc_start_day < 1))
  SET recalc_parameters->cc_start_day = cc_day
 ENDIF
 IF (cc_day > day_cnt)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Requested icu day invalid for this subencounter."
 ELSE
  SET search_beg_dt_tm = cnvtdatetime(temp->cc_day[cc_day].beg_dt_tm)
  SET search_end_dt_tm = cnvtdatetime(temp->cc_day[cc_day].end_dt_tm)
  CALL echo("in initial read, settinf reply->rad_id = 0")
  SET reply->risk_adjustment_day_id = 0.0
  SET reply->cc_day = cc_day
  SET reply->cc_beg_dt_tm = cnvtdatetime(search_beg_dt_tm)
  SET reply->cc_end_dt_tm = cnvtdatetime(search_end_dt_tm)
  SET reply->valid_from_dt_tm = cnvtdatetime(curdate,curtime3)
  SET reply->meds_ind = - (1)
  SET reply->intubated_ind = - (1)
  SET reply->vent_ind = - (1)
  SET reply->activetx_ind = - (1)
  SET reply->vent_today_ind = - (1)
  SET reply->pa_line_today_ind = - (1)
  SET search_end_dt_tm = datetimeadd(search_end_dt_tm,0.000694)
  EXECUTE FROM worst_gcs TO worst_gcs_exit
  EXECUTE FROM urine_output TO urine_output_exit
  EXECUTE FROM worst_wbc TO worst_wbc_exit
  EXECUTE FROM worst_temp TO worst_temp_exit
  EXECUTE FROM worst_resp TO worst_resp_exit
  EXECUTE FROM worst_sodium TO worst_sodium_exit
  EXECUTE FROM worst_heartrate TO worst_heartrate_exit
  EXECUTE FROM worst_meanbp TO worst_meanbp_exit
  EXECUTE FROM worst_abg TO worst_abg_exit
  EXECUTE FROM worst_hematocrit TO worst_hematocrit_exit
  EXECUTE FROM worst_creatinine TO worst_creatinine_exit
  EXECUTE FROM worst_albumin TO worst_albumin_exit
  EXECUTE FROM worst_bilirubin TO worst_bilirubin_exit
  EXECUTE FROM worst_potassium TO worst_potassium_exit
  EXECUTE FROM worst_bun TO worst_bun_exit
  EXECUTE FROM worst_glucose TO worst_glucose_exit
  SET reply->status_data.status = "S"
 ENDIF
#2099_read_exit
#2100_read_risk_adjustment
 CALL echo("in 2100")
 CALL echo(build("request->person_id=",request->person_id))
 CALL echo(build("request->encntr_id=",request->encntr_id))
 CALL echo(build("request->icu_admit_dt_tm=",request->icu_admit_dt_tm))
 CALL echo(build("request->cc_day=",request->cc_day))
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
    AND (rad.cc_day=request->cc_day)
    AND rad.active_ind=1)
  DETAIL
   ra_entry_found = "Y", ra_id = ra.risk_adjustment_id, reply->risk_adjustment_day_id = rad
   .risk_adjustment_day_id,
   CALL echo(build("in 2100 read, setting reply->risk_adjustment_day_id=",reply->
    risk_adjustment_day_id)), reply->cc_day = rad.cc_day, reply->cc_beg_dt_tm = rad.cc_beg_dt_tm,
   reply->cc_end_dt_tm = rad.cc_end_dt_tm, reply->valid_from_dt_tm = rad.valid_from_dt_tm, reply->
   intubated_ind = rad.intubated_ind,
   reply->intubated_ce_id = rad.intubated_ce_id, reply->vent_ind = rad.vent_ind, reply->eyes = rad
   .worst_gcs_eye_score,
   reply->eyes_ce_id = rad.eyes_ce_id, reply->motor = rad.worst_gcs_motor_score, reply->motor_ce_id
    = rad.motor_ce_id,
   reply->verbal = rad.worst_gcs_verbal_score, reply->verbal_ce_id = rad.verbal_ce_id, reply->
   meds_ind = rad.meds_ind,
   reply->meds_ce_id = rad.meds_ce_id,
   CALL echo(build("settign reply = rad.meds_ce_id = ",rad.meds_ce_id)), reply->urine_total = rad
   .urine_output,
   reply->urine = rad.urine_24hr_output, reply->wbc = rad.worst_wbc_result, reply->wbc_ce_id = rad
   .wbc_ce_id,
   reply->temp = rad.worst_temp, reply->temp_ce_id = rad.temp_ce_id, reply->resp = rad
   .worst_resp_result,
   reply->resp_ce_id = rad.resp_ce_id, reply->sodium = rad.worst_sodium_result, reply->sodium_ce_id
    = rad.sodium_ce_id,
   reply->heartrate = rad.worst_heart_rate, reply->heartrate_ce_id = rad.heartrate_ce_id, reply->
   meanbp = rad.mean_blood_pressure,
   reply->ph = rad.worst_ph_result, reply->ph_ce_id = rad.ph_ce_id, reply->hematocrit = rad
   .worst_hematocrit,
   reply->hematocrit_ce_id = rad.hematocrit_ce_id, reply->creatinine = rad.worst_creatinine_result,
   reply->creatinine_ce_id = rad.creatinine_ce_id,
   reply->albumin = rad.worst_albumin_result, reply->albumin_ce_id = rad.albumin_ce_id, reply->pao2
    = rad.worst_pao2_result,
   reply->pao2_ce_id = rad.pao2_ce_id, reply->pco2 = rad.worst_pco2_result, reply->pco2_ce_id = rad
   .pco2_ce_id,
   reply->bun = rad.worst_bun_result, reply->bun_ce_id = rad.bun_ce_id, reply->glucose = rad
   .worst_glucose_result,
   reply->glucose_ce_id = rad.glucose_ce_id, reply->bilirubin = rad.worst_bilirubin_result, reply->
   bilirubin_ce_id = rad.bilirubin_ce_id,
   reply->potassium = rad.worst_potassium_result, reply->potassium_ce_id = rad.potassium_ce_id, reply
   ->fio2 = rad.worst_fio2_result,
   reply->fio2_ce_id = rad.fio2_ce_id, reply->activetx_ind = rad.activetx_ind, reply->vent_today_ind
    = rad.vent_today_ind,
   reply->pa_line_today_ind = rad.pa_line_today_ind, reply->updt_dt_tm = rad.updt_dt_tm
  WITH nocounter
 ;end select
 CALL echo("end of 2100, rad should have been set")
#2199_risk_adjustment_exit
#2200_read_ra
 SET last_cc_day_written = 0
 SET disch_ind = 0
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
    AND rad.active_ind=1)
  ORDER BY rad.cc_day
  DETAIL
   last_cc_day_written = rad.cc_day, ra_id = ra.risk_adjustment_id
   IF (((ra.icu_disch_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND (request->cc_day=0)) OR ((request->cc_day=0)
    AND rad.cc_beg_dt_tm < cnvtdatetime(curdate,curtime3)
    AND rad.cc_end_dt_tm >= cnvtdatetime(curdate,curtime3))) )
    ra_entry_found = "Y", disch_dt_tm = cnvtdatetime(ra.icu_disch_dt_tm), disch_ind = 1,
    reply->risk_adjustment_day_id = rad.risk_adjustment_day_id,
    CALL echo(build("in 2200read setting reply->risk_adjustment_day_id=",reply->
     risk_adjustment_day_id)), reply->cc_day = rad.cc_day,
    reply->cc_beg_dt_tm = rad.cc_beg_dt_tm, reply->cc_end_dt_tm = rad.cc_end_dt_tm, reply->
    valid_from_dt_tm = rad.valid_from_dt_tm,
    reply->intubated_ind = rad.intubated_ind, reply->intubated_ce_id = rad.intubated_ce_id, reply->
    vent_ind = rad.vent_ind,
    reply->eyes = rad.worst_gcs_eye_score, reply->eyes_ce_id = rad.eyes_ce_id, reply->motor = rad
    .worst_gcs_motor_score,
    reply->motor_ce_id = rad.motor_ce_id, reply->verbal = rad.worst_gcs_verbal_score, reply->
    verbal_ce_id = rad.verbal_ce_id,
    reply->meds_ind = rad.meds_ind, reply->meds_ce_id = rad.meds_ce_id,
    CALL echo(build("in 2200 setting reply->meds_ce_id=",rad.meds_ce_id)),
    reply->urine = rad.urine_24hr_output, reply->urine_total = rad.urine_output, reply->wbc = rad
    .worst_wbc_result,
    reply->wbc_ce_id = rad.wbc_ce_id, reply->temp = rad.worst_temp, reply->temp_ce_id = rad
    .temp_ce_id,
    reply->resp = rad.worst_resp_result, reply->resp_ce_id = rad.resp_ce_id, reply->sodium = rad
    .worst_sodium_result,
    reply->sodium_ce_id = rad.sodium_ce_id, reply->heartrate = rad.worst_heart_rate, reply->
    heartrate_ce_id = rad.heartrate_ce_id,
    reply->meanbp = rad.mean_blood_pressure, reply->ph = rad.worst_ph_result, reply->ph_ce_id = rad
    .ph_ce_id,
    reply->hematocrit = rad.worst_hematocrit, reply->hematocrit_ce_id = rad.hematocrit_ce_id, reply->
    creatinine = rad.worst_creatinine_result,
    reply->creatinine_ce_id = rad.creatinine_ce_id, reply->albumin = rad.worst_albumin_result, reply
    ->albumin_ce_id = rad.albumin_ce_id,
    reply->pao2 = rad.worst_pao2_result, reply->pao2_ce_id = rad.pao2_ce_id, reply->pco2 = rad
    .worst_pco2_result,
    reply->pco2_ce_id = rad.pco2_ce_id, reply->bun = rad.worst_bun_result, reply->bun_ce_id = rad
    .bun_ce_id,
    reply->glucose = rad.worst_glucose_result, reply->glucose_ce_id = rad.glucose_ce_id, reply->
    bilirubin = rad.worst_bilirubin_result,
    reply->bilirubin_ce_id = rad.bilirubin_ce_id, reply->potassium = rad.worst_potassium_result,
    reply->potassium_ce_id = rad.potassium_ce_id,
    reply->fio2 = rad.worst_fio2_result, reply->fio2_ce_id = rad.fio2_ce_id, reply->activetx_ind =
    rad.activetx_ind,
    reply->vent_today_ind = rad.vent_today_ind, reply->pa_line_today_ind = rad.pa_line_today_ind,
    reply->updt_dt_tm = rad.updt_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 IF (ra_entry_found="N")
  SELECT INTO "nl:"
   FROM risk_adjustment ra
   PLAN (ra
    WHERE (ra.person_id=request->person_id)
     AND (ra.encntr_id=request->encntr_id)
     AND ra.icu_admit_dt_tm=cnvtdatetime(request->icu_admit_dt_tm)
     AND ra.active_ind=1)
   DETAIL
    disch_dt_tm = cnvtdatetime(ra.icu_disch_dt_tm)
   WITH nocounter
  ;end select
 ENDIF
#2299_read_ra_exit
#3000_oth_cc_days
 SET abc = fillstring(20," ")
 SET abc2 = fillstring(20," ")
 SET abc = format(request->icu_admit_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
 SET abc2 = concat(substring(1,18,abc),"00")
 SET reg_dt_tm = cnvtdatetime(value(abc2))
 SET d1 = datetimediff(cnvtdatetime(curdate,cc_day_start_time),cnvtdatetime(curdate,curtime3))
 IF (d1 < 0)
  SET beg_curday_dt_tm = cnvtdatetime(curdate,cc_day_start_time)
  SET end_curday_dt_tm = cnvtdatetime((curdate+ 1),cc_day_start_time)
  SET end_curday_dt_tm = datetimeadd(end_curday_dt_tm,- (0.000694))
 ELSE
  SET beg_curday_dt_tm = cnvtdatetime((curdate - 1),cc_day_start_time)
  SET end_curday_dt_tm = cnvtdatetime(curdate,cc_day_start_time)
  SET end_curday_dt_tm = datetimeadd(end_curday_dt_tm,- (0.000694))
 ENDIF
 SET beg_day1_dt_tm = cnvtdatetime(beg_curday_dt_tm)
 SET end_day1_dt_tm = cnvtdatetime(end_curday_dt_tm)
 SET day_cnt = 1
 WHILE (beg_day1_dt_tm > reg_dt_tm)
   SET beg_day1_dt_tm = datetimeadd(beg_day1_dt_tm,- (1))
   SET end_day1_dt_tm = datetimeadd(end_day1_dt_tm,- (1))
   SET day_cnt = (day_cnt+ 1)
 ENDWHILE
 IF (datetimediff(end_day1_dt_tm,reg_dt_tm,3) < 8)
  IF (day_cnt > 1)
   SET virt_beg_day1_dt_tm = datetimeadd(beg_day1_dt_tm,1)
   SET end_day1_dt_tm = datetimeadd(end_day1_dt_tm,1)
   SET day_cnt = (day_cnt - 1)
  ELSE
   SET virt_beg_day1_dt_tm = datetimeadd(beg_day1_dt_tm,- (1))
   SET end_day1_dt_tm = datetimeadd(end_day1_dt_tm,1)
  ENDIF
 ELSE
  SET virt_beg_day1_dt_tm = cnvtdatetime(beg_day1_dt_tm)
 ENDIF
 SET beg_day1_dt_tm = cnvtdatetime(reg_dt_tm)
 SET stat = alterlist(temp->cc_day,value(day_cnt))
 SET stat = alterlist(reply->oth_cc_day,value(day_cnt))
 SET new_day_cnt = 0
 FOR (x = 1 TO day_cnt)
   IF (x=1)
    SET temp->cc_day[x].beg_dt_tm = cnvtdatetime(beg_day1_dt_tm)
    SET reply->oth_cc_day[x].oth_cc_beg_dt_tm = cnvtdatetime(beg_day1_dt_tm)
   ELSE
    SET temp->cc_day[x].beg_dt_tm = cnvtdatetime(virt_beg_day1_dt_tm)
    SET reply->oth_cc_day[x].oth_cc_beg_dt_tm = cnvtdatetime(virt_beg_day1_dt_tm)
   ENDIF
   SET temp->cc_day[x].end_dt_tm = cnvtdatetime(end_day1_dt_tm)
   SET reply->oth_cc_day[x].oth_cc_end_dt_tm = cnvtdatetime(end_day1_dt_tm)
   IF ((temp->cc_day[x].end_dt_tm >= cnvtdatetime(disch_dt_tm)))
    SET new_day_cnt = x
    SET stat = alterlist(temp->cc_day,value(new_day_cnt))
    SET stat = alterlist(reply->oth_cc_day,value(new_day_cnt))
    SET temp->cc_day[x].end_dt_tm = cnvtdatetime(disch_dt_tm)
    SET reply->oth_cc_day[x].oth_cc_end_dt_tm = cnvtdatetime(disch_dt_tm)
    SET x = day_cnt
   ELSE
    SET virt_beg_day1_dt_tm = datetimeadd(virt_beg_day1_dt_tm,1)
    SET end_day1_dt_tm = datetimeadd(end_day1_dt_tm,1)
   ENDIF
 ENDFOR
 IF (new_day_cnt > 0)
  SET day_cnt = new_day_cnt
 ENDIF
#3099_oth_cc_days_exit
#4000_chk_new_values
 SET search_beg_dt_tm = cnvtdatetime(reply->cc_beg_dt_tm)
 SET search_end_dt_tm = cnvtdatetime(reply->cc_end_dt_tm)
 SET search_end_dt_tm = datetimeadd(search_end_dt_tm,0.000694)
 EXECUTE FROM worst_gcs TO worst_gcs_exit
 EXECUTE FROM urine_output TO urine_output_exit
 EXECUTE FROM worst_wbc TO worst_wbc_exit
 EXECUTE FROM worst_temp TO worst_temp_exit
 EXECUTE FROM worst_resp TO worst_resp_exit
 EXECUTE FROM worst_sodium TO worst_sodium_exit
 EXECUTE FROM worst_heartrate TO worst_heartrate_exit
 EXECUTE FROM worst_meanbp TO worst_meanbp_exit
 EXECUTE FROM worst_abg TO worst_abg_exit
 EXECUTE FROM worst_hematocrit TO worst_hematocrit_exit
 EXECUTE FROM worst_creatinine TO worst_creatinine_exit
 EXECUTE FROM worst_albumin TO worst_albumin_exit
 EXECUTE FROM worst_bilirubin TO worst_bilirubin_exit
 EXECUTE FROM worst_potassium TO worst_potassium_exit
 EXECUTE FROM worst_bun TO worst_bun_exit
 EXECUTE FROM worst_glucose TO worst_glucose_exit
#4099_chk_new_values_exit
#4100_chk_new_values
 SET search_beg_dt_tm = cnvtdatetime(request->cc_beg_dt_tm)
 SET search_end_dt_tm = cnvtdatetime(request->cc_end_dt_tm)
 SET search_end_dt_tm = datetimeadd(search_end_dt_tm,0.000694)
 EXECUTE FROM worst_gcs TO worst_gcs_exit
 EXECUTE FROM urine_output TO urine_output_exit
 EXECUTE FROM worst_wbc TO worst_wbc_exit
 EXECUTE FROM worst_temp TO worst_temp_exit
 EXECUTE FROM worst_resp TO worst_resp_exit
 EXECUTE FROM worst_sodium TO worst_sodium_exit
 EXECUTE FROM worst_heartrate TO worst_heartrate_exit
 EXECUTE FROM worst_meanbp TO worst_meanbp_exit
 EXECUTE FROM worst_abg TO worst_abg_exit
 EXECUTE FROM worst_hematocrit TO worst_hematocrit_exit
 EXECUTE FROM worst_creatinine TO worst_creatinine_exit
 EXECUTE FROM worst_albumin TO worst_albumin_exit
 EXECUTE FROM worst_bilirubin TO worst_bilirubin_exit
 EXECUTE FROM worst_potassium TO worst_potassium_exit
 EXECUTE FROM worst_bun TO worst_bun_exit
 EXECUTE FROM worst_glucose TO worst_glucose_exit
#4199_chk_new_values_exit
#5000_get_carry_over
 SET stillneed2find = 0
 IF ((reply->wbc=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((reply->sodium=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((reply->hematocrit=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((reply->creatinine=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((reply->albumin=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((reply->bilirubin=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((reply->bun=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 IF ((reply->glucose=- (1)))
  SET stillneed2find = (stillneed2find+ 1)
 ENDIF
 SET check_cc_day = reply->cc_day
 SET carry_flag = 0
 WHILE (stillneed2find > 0
  AND check_cc_day > 1)
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
     AND rad.cc_day=check_cc_day
     AND rad.active_ind=1)
   ORDER BY rad.cc_day DESC
   DETAIL
    IF ((reply->wbc=- (1))
     AND rad.worst_wbc_result > 0)
     stillneed2find = (stillneed2find - 1), reply->wbc = rad.worst_wbc_result, carry_flag = bor(
      carry_flag,1)
    ENDIF
    IF ((reply->hematocrit=- (1))
     AND rad.worst_hematocrit > 0)
     stillneed2find = (stillneed2find - 1), reply->hematocrit = rad.worst_hematocrit, carry_flag =
     bor(carry_flag,2)
    ENDIF
    IF ((reply->sodium=- (1))
     AND rad.worst_sodium_result > 0)
     stillneed2find = (stillneed2find - 1), reply->sodium = rad.worst_sodium_result, carry_flag = bor
     (carry_flag,4)
    ENDIF
    IF ((reply->bun=- (1))
     AND rad.worst_bun_result > 0)
     stillneed2find = (stillneed2find - 1), reply->bun = rad.worst_bun_result, carry_flag = bor(
      carry_flag,8)
    ENDIF
    IF ((reply->creatinine=- (1))
     AND rad.worst_creatinine_result > 0)
     stillneed2find = (stillneed2find - 1), reply->creatinine = rad.worst_creatinine_result,
     carry_flag = bor(carry_flag,16)
    ENDIF
    IF ((reply->glucose=- (1))
     AND rad.worst_glucose_result > 0)
     stillneed2find = (stillneed2find - 1), reply->glucose = rad.worst_glucose_result, carry_flag =
     bor(carry_flag,32)
    ENDIF
    IF ((reply->albumin=- (1))
     AND rad.worst_albumin_result > 0)
     stillneed2find = (stillneed2find - 1), reply->albumin = rad.worst_albumin_result, carry_flag =
     bor(carry_flag,64)
    ENDIF
    IF ((reply->bilirubin=- (1))
     AND rad.worst_bilirubin_result > 0)
     stillneed2find = (stillneed2find - 1), reply->bilirubin = rad.worst_bilirubin_result, carry_flag
      = bor(carry_flag,128)
    ENDIF
   WITH nocounter
  ;end select
 ENDWHILE
 SET reply->carry_over_flags = carry_flag
#5099_get_carry_over_exit
#worst_gcs
 SET gcs_total = 0.0
 SET temp_eyes = 0.0
 SET temp_motor = 0.0
 SET temp_verbal = 0.0
 SET temp_meds = 0.0
 SET hold_motor = - (1.0)
 SET hold_verbal = - (1.0)
 SET hold_eyes = - (1.0)
 SET hold_meds = - (1.0)
 SET hold_eyes_ce_id = 0.0
 SET hold_motor_ce_id = 0.0
 SET hold_verbal_ce_id = 0.0
 SET hold_meds_ce_id = 0.0
 SET temp_eyes_ce_id = 0.0
 SET temp_motor_ce_id = 0.0
 SET temp_verbal_ce_id = 0.0
 SET temp_meds_ce_id = 0.0
 SET eyes_cd = 0.0
 SET motor_cd = 0.0
 SET verbal_cd = 0.0
 SET meds_cd = 0.0
 SET eyes_cd = uar_get_code_by_cki("CKI.EC!5524")
 SET motor_cd = uar_get_code_by_cki("CKI.EC!5525")
 SET verbal_cd = uar_get_code_by_cki("CKI.EC!89")
 SET meds_cd = uar_get_code_by_cki("CKI.EC!7675")
 IF (eyes_cd > 0.0
  AND motor_cd > 0.0
  AND verbal_cd > 0.0
  AND meds_cd > 0.0)
  IF ((((reply->eyes_ce_id > 0)) OR ((((reply->motor_ce_id > 0)) OR ((((reply->verbal_ce_id > 0)) OR
  ((reply->meds_ce_id > 0))) )) )) )
   SET reply->eyes = - (1)
   SET reply->motor = - (1)
   SET reply->verbal = - (1)
   SET reply->meds_ind = - (1)
   SET reply->eyes_ce_id = 0.0
   SET reply->motor_ce_id = 0.0
   SET reply->verbal_ce_id = 0.0
   SET reply->meds_ce_id = 0.0
  ENDIF
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ((ce.event_cd=eyes_cd) OR (((ce.event_cd=motor_cd) OR (((ce.event_cd=verbal_cd) OR (ce
    .event_cd=meds_cd)) )) ))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC, cnvtdatetime(ce.updt_dt_tm)
   HEAD REPORT
    temp_total = 0.0, hold_eyes = 0.0, hold_motor = 0.0,
    hold_verbal = 0.0, hold_meds = - (1.0), hold_eyes_ce_id = 0.0,
    hold_motor_ce_id = 0.0, hold_verbal_ce_id = 0.0, hold_meds_ce_id = 0.0,
    temp_eyes_ce_id = 0.0, temp_motor_ce_id = 0.0, temp_verbal_ce_id = 0.0,
    temp_meds_ce_id = 0.0, temp_eyes = 0.0, temp_motor = 0.0,
    temp_verbal = 0.0, temp_meds = 0.0
    IF ((((reply->eyes_ce_id > 0)
     AND (reply->motor_ce_id > 0)
     AND (reply->verbal_ce_id > 0)) OR ((reply->meds_ce_id > 0))) )
     hold_eyes = - (1.0), hold_motor = - (1.0), hold_verbal = - (1.0),
     hold_meds = - (1.0), hold_eyes_ce_id = 0.0, hold_motor_ce_id = 0.0,
     hold_verbal_ce_id = 0.0, hold_meds_ce_id = 0.0, gcs_total = 16
    ELSE
     hold_eyes = reply->eyes, hold_motor = reply->motor, hold_verbal = reply->verbal,
     hold_meds = reply->meds_ind, hold_eyes_ce_id = reply->eyes_ce_id, hold_motor_ce_id = reply->
     motor_ce_id,
     hold_verbal_ce_id = reply->verbal_ce_id, hold_meds_ce_id = reply->meds_ce_id
     IF (hold_meds=1)
      gcs_total = 15
     ELSE
      gcs_total = ((hold_eyes+ hold_motor)+ hold_verbal)
      IF (gcs_total < 3)
       gcs_total = 16
      ENDIF
     ENDIF
    ENDIF
    isnum = 0
   HEAD ce.event_end_dt_tm
    temp_eyes = 0.0, temp_motor = 0.0, temp_verbal = 0.0,
    temp_meds = 0.0, temp_eyes_ce_id = 0.0, temp_motor_ce_id = 0.0,
    temp_verbal_ce_id = 0.0, temp_meds_ce_id = 0.0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (ce.event_cd=meds_cd)
     isnum = 1
    ENDIF
    IF (ce.event_cd=eyes_cd)
     temp_eyes_ce_id = ce.clinical_event_id
     IF (cnvtupper(ce.event_tag)="SPONTANEOUSLY")
      temp_eyes = 4
     ENDIF
     IF (cnvtupper(ce.event_tag) IN ("TO SHOUT", "TO VERBAL COMMAND", "TO VOICE"))
      temp_eyes = 3
     ENDIF
     IF (cnvtupper(ce.event_tag)="TO PAIN")
      temp_eyes = 2
     ENDIF
     IF (cnvtupper(ce.event_tag) IN ("NONE", "NO RESPONSE"))
      temp_eyes = 1
     ENDIF
    ELSEIF (ce.event_cd=motor_cd)
     temp_motor_ce_id = ce.clinical_event_id
     IF (cnvtupper(ce.event_tag) IN ("OBEYS COMMANDS", "SPONTANEOUS", "OBEYS"))
      temp_motor = 6
     ENDIF
     IF (cnvtupper(ce.event_tag) IN ("LOCALIZES PAIN", "LOCALIZES TO NOXIOUS STIMULI"))
      temp_motor = 5
     ENDIF
     IF (cnvtupper(ce.event_tag) IN ("FLEXION-WITHDRAWAL", "WITHDRAWS"))
      temp_motor = 4
     ENDIF
     IF (cnvtupper(ce.event_tag) IN ("FLEXION-ABNORMAL (DECORTICATE RIGIDITY)", "ABNORMAL FLEXION"))
      temp_motor = 3
     ENDIF
     IF (cnvtupper(ce.event_tag) IN ("EXTENSION (DECEREBRATE RIGIDITY)", "ABNORMAL EXTENSION"))
      temp_motor = 2
     ENDIF
     IF (cnvtupper(ce.event_tag) IN ("NO RESPONSE", "FLACCID"))
      temp_motor = 1
     ENDIF
    ELSEIF (ce.event_cd=verbal_cd)
     temp_verbal_ce_id = ce.clinical_event_id
     IF (cnvtupper(ce.event_tag) IN ("SMILES AND COOS APPROPRIATELY", "ORIENTED",
     "APPROPRIATE WORDS/PHRASES", "ORIENTED AND CONVERSES"))
      temp_verbal = 5
     ENDIF
     IF (cnvtupper(ce.event_tag) IN ("CRIES AND IS CONSOLABLE", "CONFUSED",
     "DISORIENTED AND CONVERSES"))
      temp_verbal = 4
     ENDIF
     IF (cnvtupper(ce.event_tag) IN ("PERSISTENT, INAPPROPRIATE CRYING AND/OR SCREAMING",
     "PERSISTENT CRIES AND/OR SCREAMS"))
      temp_verbal = 3
     ENDIF
     IF (cnvtupper(ce.event_tag)="INAPPROPRIATE WORDS")
      IF (age_in_years < 6)
       temp_verbal = 4
      ELSE
       temp_verbal = 3
      ENDIF
     ENDIF
     IF (cnvtupper(ce.event_tag) IN ("GRUNTS, AGITATED AND RESTLESS", "GRUNTS",
     "INCOMPREHENSIBLE SOUNDS"))
      temp_verbal = 2
     ENDIF
     IF (cnvtupper(ce.event_tag) IN ("NONE", "NO RESPONSE"))
      temp_verbal = 1
     ENDIF
    ELSEIF (ce.event_cd=meds_cd)
     temp_meds_ce_id = ce.clinical_event_id, place = 0, place = findstring("ANESTHESIA",cnvtupper(ce
       .event_tag),1,0)
     IF (place=0)
      place = findstring("SEDATION",cnvtupper(ce.event_tag),1,0)
     ENDIF
     IF (place=0)
      place = findstring("PARALYTICS",cnvtupper(ce.event_tag),1,0)
     ENDIF
     IF (place > 0)
      temp_meds = 1
     ENDIF
    ENDIF
   FOOT  ce.event_end_dt_tm
    IF (((temp_eyes > 0
     AND temp_motor > 0
     AND temp_verbal > 0) OR (temp_meds > 0)) )
     IF (temp_meds=1)
      temp_motor = - (1), temp_verbal = - (1), temp_eyes = - (1),
      temp_eyes_ce_id = 0, temp_motor_ce_id = 0, temp_verbal_ce_id = 0,
      temp_total = 15
     ELSE
      temp_total = ((temp_eyes+ temp_motor)+ temp_verbal)
     ENDIF
     IF (hold_eyes=temp_eyes
      AND hold_motor=temp_motor
      AND hold_verbal=temp_verbal
      AND hold_meds=temp_meds
      AND hold_eyes_ce_id < 1
      AND hold_motor_ce_id < 1
      AND hold_verbal_ce_id < 1
      AND hold_meds_ce_id < 1)
      hold_eyes_ce_id = temp_eyes_ce_id, hold_motor_ce_id = temp_motor_ce_id, hold_verbal_ce_id =
      temp_verbal_ce_id,
      hold_meds_ce_id = temp_meds_ce_id, found_new_worst = 1
     ENDIF
     IF (((temp_total < gcs_total) OR (gcs_total=0)) )
      gcs_total = temp_total, hold_meds = temp_meds, hold_meds_ce_id = temp_meds_ce_id
      IF (temp_meds=1)
       hold_eyes = - (1), hold_verbal = - (1), hold_motor = - (1),
       hold_eyes_ce_id = 0.0, hold_motor_ce_id = 0.0, hold_verbal_ce_id = 0.0
      ELSE
       hold_eyes = temp_eyes, hold_motor = temp_motor, hold_verbal = temp_verbal,
       hold_eyes_ce_id = temp_eyes_ce_id, hold_motor_ce_id = temp_motor_ce_id, hold_verbal_ce_id =
       temp_verbal_ce_id
      ENDIF
      found_new_worst = 1
     ENDIF
    ENDIF
   FOOT REPORT
    IF (found_new_worst=1)
     reply->eyes = hold_eyes, reply->motor = hold_motor, reply->verbal = hold_verbal,
     reply->meds_ind = hold_meds, reply->eyes_ce_id = hold_eyes_ce_id, reply->motor_ce_id =
     hold_motor_ce_id,
     reply->verbal_ce_id = hold_verbal_ce_id, reply->meds_ce_id = hold_meds_ce_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#worst_gcs_exit
#urine_output
 SET found_urine = 0
 SET event_tag_num = 0.0
 SET hold_tag = - (1.0)
 SET urine1_cd = 0.0
 SET urine2_cd = 0.0
 SET urine3_cd = 0.0
 SET urine1_cd = uar_get_code_by_cki("CKI.EC!6416")
 SET urine2_cd = uar_get_code_by_cki("CKI.EC!5723")
 SET urine3_cd = uar_get_code_by_cki("CKI.EC!5727")
 IF (urine1_cd <= 0.0
  AND urine2_cd <= 0.0
  AND urine3_cd <= 0.0)
  CALL echo("No Urine codes Defined")
 ELSE
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ((ce.event_cd=urine1_cd) OR (((ce.event_cd=urine2_cd) OR (ce.event_cd=urine3_cd)) ))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_tag = 0.0, found_urine = 0,
    isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     found_urine = 1, temp_tag = cnvtreal(ce.event_tag), hold_tag = (hold_tag+ temp_tag)
    ENDIF
   WITH nocounter
  ;end select
  SET d2 = abs(datetimediff(search_beg_dt_tm,search_end_dt_tm,3))
  IF (found_urine=1)
   SET event_tag_num = ((hold_tag/ (d2+ 0.01667)) * 24)
   SET reply->urine = round(event_tag_num,0)
   SET reply->urine_total = hold_tag
   SET found_new_worst = 1
  ENDIF
 ENDIF
#urine_output_exit
#worst_wbc
 IF ((reply->wbc > 0)
  AND (reply->wbc_ce_id > 0))
  SET reply->wbc = - (1)
  SET reply->wbc_ce_id = 0.0
  SET event_tag_num = - (1.0)
  SET event_ce_id = 0
 ELSE
  SET event_tag_num = reply->wbc
  SET event_ce_id = reply->wbc_ce_id
 ENDIF
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!4046")
 IF (res_cd > 0.0)
  SET midpoint = 11.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  IF (ce_id > 0.0)
   SET reply->wbc = event_tag_num
   SET reply->wbc_ce_id = ce_id
  ENDIF
 ENDIF
#worst_wbc_exit
#worst_temp
 IF ((reply->temp > 0)
  AND (reply->temp_ce_id > 0))
  SET reply->temp = - (1)
  SET reply->temp_ce_id = 0
 ENDIF
 SET event_tag_num = - (1.0)
 SET hold_tag = - (1.0)
 SET hold_diff = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET temp1_cd = 0.0
 SET temp2_cd = 0.0
 SET temp3_cd = 0.0
 SET ax_temp4_cd = 0.0
 SET temp5_cd = 0.0
 SET temp6_cd = 0.0
 SET temp1_cd = uar_get_code_by_cki("CKI.EC!5502")
 SET temp2_cd = uar_get_code_by_cki("CKI.EC!5505")
 SET temp3_cd = uar_get_code_by_cki("CKI.EC!5506")
 SET ax_temp4_cd = uar_get_code_by_cki("CKI.EC!5507")
 SET temp5_cd = uar_get_code_by_cki("CKI.EC!5508")
 SET temp6_cd = uar_get_code_by_cki("CKI.EC!5509")
 IF (temp1_cd <= 0.0
  AND temp2_cd <= 0.0
  AND temp3_cd <= 0.0
  AND ax_temp4_cd <= 0.0
  AND temp5_cd <= 0.0
  AND temp6_cd <= 0.0)
  CALL echo("No Temp Coded Defined")
 ELSE
  SET midpoint = 38.0
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ((ce.event_cd=temp1_cd) OR (((ce.event_cd=temp2_cd) OR (((ce.event_cd=temp3_cd) OR (((ce
    .event_cd=ax_temp4_cd) OR (((ce.event_cd=temp5_cd) OR (ce.event_cd=temp6_cd)) )) )) )) ))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_temp = 0.0, temp_diff = - (1.0),
    hold_diff = - (1.0)
    IF ((reply->temp > 0))
     IF ((reply->temp >= 50))
      temp_temp = (((reply->temp - 32) * 5)/ 9)
     ELSE
      temp_temp = reply->temp
     ENDIF
     hold_diff = abs((temp_temp - midpoint)), hold_tag = reply->temp, ce_id = reply->temp_ce_id
    ENDIF
    isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_temp = cnvtreal(ce.event_tag)
     IF (temp_temp > 0
      AND temp_temp < 50)
      temp_temp = temp_temp
     ELSE
      temp_temp = (((temp_temp - 32) * 5)/ 9)
     ENDIF
     IF (ce.event_cd=ax_temp4_cd)
      temp_temp = (temp_temp+ 1)
     ENDIF
     temp_diff = abs((temp_temp - midpoint))
     IF (((temp_diff > hold_diff) OR (temp_diff=hold_diff
      AND ce_id=0)) )
      hold_diff = temp_diff, hold_tag = cnvtreal(ce.event_tag), ce_id = ce.clinical_event_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (hold_tag > 0)
   SET reply->temp = hold_tag
   SET found_new_worst = 1
  ENDIF
  SET reply->temp_ce_id = ce_id
 ENDIF
#worst_temp_exit
#worst_resp
 SET midpoint = 19.0
 SET saved_resp = reply->resp
 SET saved_vent = reply->vent_ind
 SET saved_ce_id = reply->resp_ce_id
 IF ((reply->resp >= 0))
  SET saved_diff = abs((midpoint - reply->resp))
 ELSE
  SET saved_diff = - (1)
 ENDIF
 SET hold_resp = - (1.0)
 SET hold_vent = - (1.0)
 SET hold_ce_id = 0.0
 SET hold_diff = - (1.0)
 SET temp_resp = - (1.0)
 SET temp_vent = - (1.0)
 SET resp_cd = 0.0
 SET resp_cd = uar_get_code_by_cki("CKI.EC!5501")
 DECLARE vent_cd = f8 WITH noconstant(0.0)
 SET vent_cd = uar_get_code_by_cki("CKI.EC!7676")
 SET new_data_evt = 0.0
 IF (resp_cd > 0.0)
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ((ce.event_cd=resp_cd) OR (ce.event_cd=vent_cd))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    isnum = - (1)
   HEAD ce.event_end_dt_tm
    new_data_evt = 0.0, temp_vent = - (1)
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (ce.event_cd=vent_cd
     AND vent_cd > 0)
     isnum = 1
    ENDIF
    IF (isnum > 0)
     IF (ce.event_cd=resp_cd)
      new_data_evt = 1, temp_resp = cnvtreal(ce.event_tag), temp_ce_id = ce.clinical_event_id
     ELSEIF (ce.event_cd=vent_cd
      AND vent_cd > 0)
      temp_vent = 1
     ENDIF
    ENDIF
   FOOT  ce.event_end_dt_tm
    IF (temp_resp >= 0)
     temp_diff = abs((temp_resp - midpoint))
     IF (vent_cd > 0
      AND new_data_evt=1
      AND temp_vent != 1)
      temp_vent = 0
     ENDIF
     IF (temp_diff > hold_diff)
      hold_diff = temp_diff, hold_resp = temp_resp, hold_vent = temp_vent,
      hold_ce_id = temp_ce_id
     ELSEIF (temp_diff=hold_diff)
      IF (((hold_vent < 0.0) OR (temp_vent=0
       AND hold_vent != 0)) )
       hold_vent = temp_vent, hold_resp = temp_resp, hold_ce_id = temp_ce_id
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (hold_resp >= 0)
   IF (hold_resp=saved_resp)
    SET reply->resp = hold_resp
    SET reply->resp_ce_id = hold_ce_id
    IF (((hold_ce_id=saved_ce_id) OR (saved_ce_id=0.0))
     AND (saved_vent > - (1)))
     SET reply->vent_ind = saved_vent
    ELSE
     SET reply->vent_ind = hold_vent
     IF (hold_vent != saved_vent)
      SET found_new_worst = 1
     ENDIF
    ENDIF
   ELSEIF (hold_diff > saved_diff)
    SET reply->resp = hold_resp
    SET reply->resp_ce_id = hold_ce_id
    SET reply->vent_ind = hold_vent
    SET found_new_worst = 1
   ELSE
    IF (saved_ce_id > 0)
     SET reply->resp = - (1)
     SET reply->resp_ce_id = 0.0
     SET reply->vent_ind = - (1)
    ELSE
     SET reply->resp = saved_resp
     SET reply->resp_ce_id = saved_ce_id
     SET reply->vent_ind = saved_vent
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#worst_resp_exit
#worst_sodium
 IF ((reply->sodium > 0)
  AND (reply->sodium_ce_id > 0))
  SET reply->sodium = - (1)
  SET reply->sodium_ce_id = 0.0
  SET event_tag_num = - (1.0)
  SET event_ce_id = 0
 ELSE
  SET event_tag_num = reply->sodium
  SET event_ce_id = reply->sodium_ce_id
 ENDIF
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3758")
 IF (res_cd > 0.0)
  SET midpoint = 145.0
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  IF (ce_id > 0.0)
   SET reply->sodium = event_tag_num
   SET reply->sodium_ce_id = ce_id
  ENDIF
 ENDIF
#worst_sodium_exit
#worst_heartrate
 SET saved_hr = 0.0
 SET saved_ce_id = 0.0
 SET saved_hr = reply->heartrate
 SET saved_ce_id = reply->heartrate_ce_id
 IF ((reply->heartrate > 0)
  AND (reply->heartrate_ce_id > 0))
  SET reply->heartrate = - (1)
  SET reply->heartrate_ce_id = 0
 ENDIF
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET hold_diff = - (1.0)
 SET hr1_cd = 0.0
 SET hr2_cd = 0.0
 SET hr3_cd = 0.0
 SET hr4_cd = 0.0
 SET hr1_cd = uar_get_code_by_cki("CKI.EC!40")
 SET hr2_cd = uar_get_code_by_cki("CKI.EC!5500")
 SET hr3_cd = uar_get_code_by_cki("CKI.EC!7187")
 SET hr4_cd = uar_get_code_by_cki("CKI.EC!7679")
 IF (((hr1_cd > 0.0) OR (((hr2_cd > 0.0) OR (((hr3_cd > 0.0) OR (hr4_cd > 0.0)) )) )) )
  SET midpoint = 75.0
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ce.event_cd IN (hr1_cd, hr2_cd, hr3_cd, hr4_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_res = 0.0, temp_diff = - (1.0),
    hold_diff = - (1.0)
    IF ((reply->heartrate > 0))
     hold_diff = abs((reply->heartrate - midpoint)), event_tag_num = reply->heartrate, ce_id = reply
     ->heartrate_ce_id
    ENDIF
    isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_res = cnvtreal(ce.event_tag), temp_diff = abs((temp_res - midpoint))
     IF (((temp_diff > hold_diff) OR (temp_diff=hold_diff
      AND ce_id=0)) )
      hold_diff = temp_diff, event_tag_num = temp_res, ce_id = ce.clinical_event_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (hold_diff >= 0)
   SET reply->heartrate = event_tag_num
   SET reply->heartrate_ce_id = ce_id
   IF ((saved_hr != reply->heartrate)
    AND (saved_ce_id != reply->heartrate_ce_id))
    SET found_new_worst = 1
    CALL echo("setting in HR")
   ENDIF
  ENDIF
 ENDIF
#worst_heartrate_exit
#worst_map
 SET event_tag_num = - (1.0)
 SET saved_map = 0.0
 SET saved_map = reply->meanbp
 IF ((reply->meanbp <= 0))
  SET reply->meanbp = - (1)
 ENDIF
 SET midpoint = 0.0
 SET hold_diff = - (1.0)
 SET temp_meanbp = 0.0
 SET hold_meanbp = 0.0
 SET map_cd = 0.0
 SET map_cd = uar_get_code_by_cki("CKI.EC!6882")
 IF (map_cd > 0.0)
  SET midpoint = 90.00
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ce.event_cd=map_cd
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_map = 0.0, temp_diff = - (1.0),
    hold_diff = - (1.0), isnum = 0
    IF ((reply->meanbp > 0))
     hold_diff = abs((reply->meanbp - midpoint)), event_tag_num = reply->meanbp
    ENDIF
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_map = cnvtreal(ce.event_tag)
    ENDIF
   FOOT  ce.event_end_dt_tm
    IF (temp_map > 0)
     temp_diff = abs((temp_meanbp - midpoint))
     IF (((temp_diff > hold_diff) OR (event_tag_num=0)) )
      hold_diff = temp_diff, event_tag_num = temp_meanbp
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (event_tag_num > 0)
   SET reply->meanbp = event_tag_num
   IF ((saved_map != reply->meanbp))
    SET found_new_worst = 1
    CALL echo("setting in MAP")
   ENDIF
  ENDIF
 ENDIF
#worst_map_exit
#worst_meanbp
 SET event_tag_num = - (1.0)
 SET saved_map = 0.0
 SET saved_map = reply->meanbp
 IF ((reply->meanbp < 0))
  SET reply->meanbp = - (1)
 ENDIF
 SET temp_sys = 0.0
 SET temp_dia = 0.0
 SET midpoint = 0.0
 SET hold_diff = - (1.0)
 SET temp_meanbp = 0.0
 SET hold_meanbp = 0.0
 SET systolic1_cd = 0.0
 SET diastolic1_cd = 0.0
 SET systolic2_cd = 0.0
 SET diastolic2_cd = 0.0
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
  SET midpoint = 90.00
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ce.event_cd IN (systolic1_cd, systolic2_cd, diastolic1_cd, diastolic2_cd, systolic3_cd,
    diastolic3_cd, diastolic4_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = - (1.0), temp_sys1 = - (1.0), temp_dia1 = - (1.0),
    temp_sys2 = - (1.0), temp_dia2 = - (1.0), temp_sys3 = - (1.0),
    temp_dia3 = - (1.0), temp_dia4 = - (1.0), temp_diff = - (1.0),
    hold_diff = - (1.0), isnum = 0
    IF ((reply->meanbp >= 0))
     hold_diff = abs((reply->meanbp - midpoint)), event_tag_num = reply->meanbp
    ENDIF
   HEAD ce.event_end_dt_tm
    temp_sys1 = - (1.0), temp_dia1 = - (1.0), temp_sys2 = - (1.0),
    temp_dia2 = - (1.0), temp_sys3 = - (1.0), temp_dia3 = - (1.0),
    temp_dia4 = - (1.0)
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
    IF ((temp_sys1 > - (1))
     AND (temp_dia1 > - (1)))
     temp_meanbp = (((temp_dia1 * 2)+ temp_sys1)/ 3), temp_diff = abs((temp_meanbp - midpoint))
     IF (((temp_diff > hold_diff) OR (event_tag_num=0)) )
      hold_diff = temp_diff, event_tag_num = temp_meanbp
     ENDIF
    ENDIF
    IF ((temp_sys2 > - (1))
     AND (temp_dia2 > - (1)))
     temp_meanbp = (((temp_dia2 * 2)+ temp_sys2)/ 3), temp_diff = abs((temp_meanbp - midpoint))
     IF (((temp_diff > hold_diff) OR (event_tag_num=0)) )
      hold_diff = temp_diff, event_tag_num = temp_meanbp
     ENDIF
    ENDIF
    IF ((temp_sys3 > - (1))
     AND (temp_dia3 > - (1)))
     temp_meanbp = (((temp_dia3 * 2)+ temp_sys3)/ 3), temp_diff = abs((temp_meanbp - midpoint))
     IF (((temp_diff > hold_diff) OR (event_tag_num=0)) )
      hold_diff = temp_diff, event_tag_num = temp_meanbp
     ENDIF
    ELSEIF ((temp_sys3 > - (1))
     AND (temp_dia4 > - (1)))
     temp_meanbp = (((temp_dia4 * 2)+ temp_sys3)/ 3), temp_diff = abs((temp_meanbp - midpoint))
     IF (((temp_diff > hold_diff) OR (event_tag_num=0)) )
      hold_diff = temp_diff, event_tag_num = temp_meanbp
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (event_tag_num >= 0)
   SET reply->meanbp = event_tag_num
   IF ((saved_map != reply->meanbp))
    SET found_new_worst = 1
    CALL echo("setting in MAP")
   ENDIF
  ENDIF
 ENDIF
#worst_meanbp_exit
#worst_abg
 SET saved_pao2 = reply->pao2
 SET saved_pco2 = reply->pco2
 SET saved_fio2 = reply->fio2
 SET saved_ph = reply->ph
 SET saved_intub = reply->intubated_ind
 IF ((reply->pao2 <= 0)
  AND (reply->pco2 <= 0)
  AND (reply->fio2 <= 0)
  AND (reply->ph <= 0)
  AND (reply->intubated_ind < 0))
  SET reply->pao2 = - (1)
  SET reply->pco2 = - (1)
  SET reply->fio2 = - (1)
  SET reply->ph = - (1)
  SET reply->intubated_ind = - (1)
  SET reply->intubated_ce_id = 0.0
  SET reply->pao2_ce_id = 0.0
  SET reply->pco2_ce_id = 0.0
  SET reply->fio2_ce_id = 0.0
  SET reply->ph_ce_id = 0.0
 ENDIF
 SET aado2_set->weight = - (1)
 SET aado2_set->aado2 = - (1.0)
 SET aado2_set->pao2 = - (1.0)
 SET aado2_set->pco2 = - (1.0)
 SET aado2_set->fio2 = - (1.0)
 SET aado2_set->ph = - (1.0)
 SET aado2_set->intub = - (1)
 SET aado2_set->pao2 = - (1.0)
 SET aado2_set->pco2 = - (1.0)
 SET aado2_set->fio2 = - (1.0)
 SET aado2_set->ph = - (1.0)
 SET aado2_set->intub = - (1)
 SET aado2_set->intubated_ce_id = 0.0
 SET aado2_set->pao2_ce_id = 0.0
 SET aado2_set->pco2_ce_id = 0.0
 SET aado2_set->fio2_ce_id = 0.0
 SET aado2_set->ph_ce_id = 0.0
 SET intub_set->weight = - (1)
 SET intub_set->pao2 = - (1.0)
 SET intub_set->pco2 = - (1.0)
 SET intub_set->fio2 = - (1.0)
 SET intub_set->ph = - (1.0)
 SET intub_set->intub = - (1)
 SET intub_set->intubated_ce_id = 0.0
 SET intub_set->pao2_ce_id = 0.0
 SET intub_set->pco2_ce_id = 0.0
 SET intub_set->fio2_ce_id = 0.0
 SET intub_set->ph_ce_id = 0.0
 SET temp_pao2 = 0.0
 SET temp_pco2 = 0.0
 SET temp_fio2 = 0.0
 SET temp_ph = 0.0
 SET temp_intub = - (1.0)
 SET temp_intubated_ce_id = 0.0
 SET temp_pao2_ce_id = 0.0
 SET temp_pco2_ce_id = 0.0
 SET temp_fio2_ce_id = 0.0
 SET temp_ph_ce_id = 0.0
 SET temp_intub_from_ceid = 0
 SET temp_weight = - (1)
 SET pao2_cd = 0.0
 SET pco2_cd = 0.0
 SET fio2_cd = 0.0
 SET ph_cd = 0.0
 SET intub_cd = 0.0
 SET intub2_cd = 0.0
 SET pao2_cd = uar_get_code_by_cki("CKI.EC!3670")
 SET pco2_cd = uar_get_code_by_cki("CKI.EC!3641")
 SET fio2_cd = uar_get_code_by_cki("CKI.EC!3333")
 SET ph_cd = uar_get_code_by_cki("CKI.EC!3648")
 SET intub_cd = uar_get_code_by_cki("CKI.EC!7666")
 SET intub2_cd = uar_get_code_by_cki("CKI.EC!7677")
 IF (pco2_cd > 0.0
  AND pao2_cd > 0
  AND fio2_cd > 0.0
  AND ph_cd > 0.0
  AND ((intub_cd > 0.0) OR (intub2_cd > 0.0)) )
  IF ((((reply->pao2 <= 0)) OR ((((reply->pco2 <= 0)) OR ((((reply->fio2 <= 0)) OR ((reply->ph <= 0)
  )) )) )) )
   SET reply->pao2 = - (1)
   SET reply->pco2 = - (1)
   SET reply->fio2 = - (1)
   SET reply->ph = - (1)
   SET reply->intubated_ind = - (1)
   SET reply->intubated_ce_id = 0.0
   SET reply->pao2_ce_id = 0.0
   SET reply->pco2_ce_id = 0.0
   SET reply->fio2_ce_id = 0.0
   SET reply->ph_ce_id = 0.0
  ENDIF
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ((ce.event_cd=pao2_cd) OR (((ce.event_cd=pco2_cd) OR (((ce.event_cd=fio2_cd) OR (((ce
    .event_cd=ph_cd) OR (((ce.event_cd=intub_cd) OR (ce.event_cd=intub2_cd)) )) )) )) ))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC, cnvtdatetime(ce.updt_dt_tm)
   HEAD ce.event_end_dt_tm
    temp_pao2 = - (1.0), temp_pco2 = - (1.0), temp_fio2 = - (1.0),
    temp_ph = - (1.0), temp_intub = - (1.0), temp_aado2 = - (1.0),
    temp_intub_from_ceid = 0
   DETAIL
    isnum = 0, isnum = isnumeric(ce.event_tag)
    IF (ce.event_cd=intub_cd)
     temp_intub_from_ceid = 1, temp_intubated_ce_id = ce.clinical_event_id
     IF (cnvtupper(ce.event_tag) IN ("ENDOTRACHEAL", "ENDOBRONCHIAL", "TRACHEOSTOMY"))
      temp_intub = 1
     ELSE
      IF (temp_intub < 0)
       temp_intub = 0
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd=intub2_cd)
     temp_intubated_ce_id = ce.clinical_event_id, temp_intub_from_ceid = 1
     IF (cnvtupper(ce.event_tag) IN ("Y", "YES"))
      temp_intub = 1
     ELSE
      IF (temp_intub < 0)
       temp_intub = 0
      ENDIF
     ENDIF
    ELSEIF (ce.event_cd=fio2_cd)
     temp_fio2_ce_id = ce.clinical_event_id
     IF (isnum > 0)
      temp_fio2 = cnvtreal(ce.event_tag)
     ELSE
      filtered_fio2 = check_for_string(ce.event_tag,"%")
      IF (isnumeric(filtered_fio2) > 0)
       temp_fio2 = cnvtreal(filtered_fio2)
      ENDIF
     ENDIF
     IF (temp_fio2 <= 1.0)
      temp_fio2 = (temp_fio2 * 100)
     ENDIF
    ELSEIF (isnum > 0)
     IF (ce.event_cd=pao2_cd)
      temp_pao2_ce_id = ce.clinical_event_id, temp_pao2 = cnvtreal(ce.event_tag)
     ELSEIF (ce.event_cd=pco2_cd)
      temp_pco2_ce_id = ce.clinical_event_id, temp_pco2 = cnvtreal(ce.event_tag)
     ELSEIF (ce.event_cd=ph_cd)
      temp_ph_ce_id = ce.clinical_event_id, temp_ph = cnvtreal(ce.event_tag)
     ENDIF
    ENDIF
   FOOT  ce.event_end_dt_tm
    IF (temp_intub_from_ceid=0
     AND auto_calc_intubated_ind=1
     AND (((temp_fio2 != reply->fio2)) OR ((((temp_pao2 != reply->pao2)) OR ((((temp_pco2 != reply->
    pco2)) OR ((temp_ph != reply->ph))) )) )) )
     IF (temp_pao2 > 0
      AND temp_pco2 > 0
      AND temp_fio2 > 0
      AND temp_ph > 0)
      IF (temp_fio2 > 50.00)
       temp_intub = 1
      ELSE
       temp_intub = 0
      ENDIF
     ENDIF
    ENDIF
    IF (temp_pao2 > 0
     AND temp_pco2 > 0
     AND temp_fio2 > 0
     AND temp_ph > 0
     AND temp_intub >= 0)
     IF (((temp_intub=0) OR (temp_fio2 < 50.00)) )
      IF (temp_pao2 < 50)
       temp_weight = 15
      ELSEIF (temp_pao2 < 70)
       temp_weight = 5
      ELSEIF (temp_pao2 < 80)
       temp_weight = 2
      ELSE
       temp_weight = 0
      ENDIF
      IF ((((temp_weight > intub_set->weight)) OR ((temp_weight=intub_set->weight)
       AND (temp_pao2 < intub_set->pao2))) )
       intub_set->weight = temp_weight, intub_set->pao2 = temp_pao2, intub_set->pco2 = temp_pco2,
       intub_set->fio2 = temp_fio2, intub_set->ph = temp_ph, intub_set->intub = temp_intub,
       intub_set->date = cnvtdatetime(ce.event_end_dt_tm), intub_set->intubated_ce_id =
       temp_intubated_ce_id, intub_set->pao2_ce_id = temp_pao2_ce_id,
       intub_set->pco2_ce_id = temp_pco2_ce_id, intub_set->fio2_ce_id = temp_fio2_ce_id, intub_set->
       ph_ce_id = temp_ph_ce_id
      ENDIF
     ELSE
      temp_aado2 = (((temp_fio2 * 7.13) - temp_pao2) - temp_pco2)
      IF (temp_aado2 < 100)
       temp_weight = 0
      ELSEIF (temp_aado2 < 250)
       temp_weight = 7
      ELSEIF (temp_aado2 < 350)
       temp_weight = 9
      ELSEIF (temp_aado2 < 500)
       temp_weight = 11
      ELSE
       temp_weight = 14
      ENDIF
      IF ((((temp_weight > aado2_set->weight)) OR ((temp_weight=aado2_set->weight)
       AND (temp_aado2 > aado2_set->aado2))) )
       aado2_set->weight = temp_weight, aado2_set->aado2 = temp_aado2, aado2_set->pao2 = temp_pao2,
       aado2_set->pco2 = temp_pco2, aado2_set->fio2 = temp_fio2, aado2_set->ph = temp_ph,
       aado2_set->intub = temp_intub, aado2_set->date = cnvtdatetime(ce.event_end_dt_tm), aado2_set->
       intubated_ce_id = temp_intubated_ce_id,
       aado2_set->pao2_ce_id = temp_pao2_ce_id, aado2_set->pco2_ce_id = temp_pco2_ce_id, aado2_set->
       fio2_ce_id = temp_fio2_ce_id,
       aado2_set->ph_ce_id = temp_ph_ce_id
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF ((temp_weight > - (1)))
   IF ((intub_set->weight=aado2_set->weight))
    IF (cnvtdatetime(intub_set->date) > cnvtdatetime(aado2_set->date))
     SET reply->pao2 = intub_set->pao2
     SET reply->pco2 = intub_set->pco2
     SET reply->fio2 = intub_set->fio2
     SET reply->ph = intub_set->ph
     SET reply->intubated_ind = intub_set->intub
     SET reply->intubated_ce_id = intub_set->intubated_ce_id
     SET reply->pao2_ce_id = intub_set->pao2_ce_id
     SET reply->pco2_ce_id = intub_set->pco2_ce_id
     SET reply->fio2_ce_id = intub_set->fio2_ce_id
     SET reply->ph_ce_id = intub_set->ph_ce_id
    ELSE
     SET reply->pao2 = aado2_set->pao2
     SET reply->pco2 = aado2_set->pco2
     SET reply->fio2 = aado2_set->fio2
     SET reply->ph = aado2_set->ph
     SET reply->intubated_ind = aado2_set->intub
     SET reply->intubated_ce_id = aado2_set->intubated_ce_id
     SET reply->pao2_ce_id = aado2_set->pao2_ce_id
     SET reply->pco2_ce_id = aado2_set->pco2_ce_id
     SET reply->fio2_ce_id = aado2_set->fio2_ce_id
     SET reply->ph_ce_id = aado2_set->ph_ce_id
    ENDIF
   ELSEIF ((intub_set->weight > aado2_set->weight))
    SET reply->pao2 = intub_set->pao2
    SET reply->pco2 = intub_set->pco2
    SET reply->fio2 = intub_set->fio2
    SET reply->ph = intub_set->ph
    SET reply->intubated_ind = intub_set->intub
    SET reply->intubated_ce_id = intub_set->intubated_ce_id
    SET reply->pao2_ce_id = intub_set->pao2_ce_id
    SET reply->pco2_ce_id = intub_set->pco2_ce_id
    SET reply->fio2_ce_id = intub_set->fio2_ce_id
    SET reply->ph_ce_id = intub_set->ph_ce_id
   ELSE
    SET reply->pao2 = aado2_set->pao2
    SET reply->pco2 = aado2_set->pco2
    SET reply->fio2 = aado2_set->fio2
    SET reply->ph = aado2_set->ph
    SET reply->intubated_ind = aado2_set->intub
    SET reply->intubated_ce_id = aado2_set->intubated_ce_id
    SET reply->pao2_ce_id = aado2_set->pao2_ce_id
    SET reply->pco2_ce_id = aado2_set->pco2_ce_id
    SET reply->fio2_ce_id = aado2_set->fio2_ce_id
    SET reply->ph_ce_id = aado2_set->ph_ce_id
   ENDIF
  ENDIF
  IF ((((saved_pao2 != reply->pao2)) OR ((((saved_pco2 != reply->pco2)) OR ((((saved_fio2 != reply->
  fio2)) OR ((((saved_ph != reply->ph)) OR ((saved_intub != reply->intubated_ind))) )) )) )) )
   SET found_new_worst = 1
  ENDIF
 ENDIF
#worst_abg_exit
#worst_hematocrit
 SET saved_hemat = reply->hematocrit
 SET saved_ce_id = reply->hematocrit_ce_id
 IF ((reply->hematocrit > 0)
  AND (reply->hematocrit_ce_id > 0))
  SET reply->hematocrit = - (1)
  SET reply->hematocrit_ce_id = 0
  SET event_tag_num = - (1.0)
  SET event_ce_id = 0
 ELSE
  SET event_tag_num = reply->hematocrit
  SET event_ce_id = reply->hematocrit_ce_id
 ENDIF
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3404")
 IF (res_cd > 0.0)
  SET midpoint = 45.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  IF (ce_id > 0.0)
   SET reply->hematocrit = event_tag_num
   SET reply->hematocrit_ce_id = ce_id
  ENDIF
  IF ((((saved_hemat != reply->hematocrit)) OR ((saved_ce_id != reply->hematocrit_ce_id))) )
   CALL echo("setting in HEMAT")
   SET found_new_worst = 1
  ENDIF
 ENDIF
#worst_hematocrit_exit
#worst_creatinine
 SET saved_creat = reply->creatinine
 SET saved_ce_id = reply->creatinine_ce_id
 IF ((reply->creatinine > 0)
  AND (reply->creatinine_ce_id > 0))
  SET reply->creatinine = - (1)
  SET reply->creatinine_ce_id = 0
 ENDIF
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET creat1_cd = 0.0
 SET creat2_cd = 0.0
 SET creat1_cd = uar_get_code_by_cki("CKI.EC!3256")
 SET creat2_cd = uar_get_code_by_cki("CKI.EC!8226")
 IF (((creat1_cd > 0.0) OR (creat2_cd > 0.0)) )
  SET midpoint = 0.0
  SET hold_diff = - (1.0)
  SET temp_res = 0.0
  SET temp_diff = - (1.0)
  SET hold_tag = 0.0
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ce.event_cd IN (creat1_cd, creat2_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_res = 0.0, temp_diff = - (1.0),
    hold_diff = - (1.0), isnum = 0, ce_id = 0.0
    IF ((reply->creatinine > 0))
     hold_diff = abs((reply->creatinine - midpoint)), event_tag_num = reply->creatinine, ce_id =
     reply->creatinine_ce_id
    ENDIF
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_res = cnvtreal(ce.event_tag), temp_diff = abs((temp_res - midpoint))
     IF (((temp_diff > hold_diff) OR (temp_diff=hold_diff
      AND ce_id=0)) )
      hold_diff = temp_diff, event_tag_num = temp_res, ce_id = ce.clinical_event_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (ce_id > 0.0)
   SET reply->creatinine = event_tag_num
   SET reply->creatinine_ce_id = ce_id
  ENDIF
  IF ((((saved_creat != reply->creatinine)) OR ((saved_ce_id != reply->creatinine_ce_id))) )
   SET found_new_worst = 1
   CALL echo("setting in create")
  ENDIF
 ENDIF
#worst_creatinine_exit
#worst_bilirubin
 SET saved_billi = reply->bilirubin
 SET saved_ce_id = reply->bilirubin_ce_id
 IF ((reply->bilirubin > 0)
  AND (reply->bilirubin_ce_id > 0))
  SET reply->bilirubin = - (1)
  SET reply->bilirubin_ce_id = 0
  SET event_tag_num = - (1.0)
  SET event_ce_id = 0
 ELSE
  SET event_tag_num = reply->bilirubin
  SET event_ce_id = reply->bilirubin_ce_id
 ENDIF
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3133")
 IF (res_cd > 0.0)
  EXECUTE FROM highest_result TO highest_result_exit
  IF (ce_id > 0.0)
   SET reply->bilirubin = event_tag_num
   SET reply->bilirubin_ce_id = ce_id
  ENDIF
  IF ((((saved_billi != reply->bilirubin)) OR ((saved_ce_id != reply->bilirubin_ce_id))) )
   SET found_new_worst = 1
  ENDIF
 ENDIF
#worst_bilirubin_exit
#worst_potassium
 SET saved_pot = reply->potassium
 SET saved_ce_id = reply->potassium_ce_id
 IF ((reply->potassium > 0)
  AND (reply->potassium_ce_id > 0))
  SET reply->potassium = - (1)
  SET reply->potassium_ce_id = 0
  SET event_tag_num = - (1.0)
  SET event_ce_id = 0
 ELSE
  SET event_tag_num = reply->potassium
  SET event_ce_id = reply->potassium_ce_id
 ENDIF
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3681")
 IF (res_cd > 0.0)
  SET midpoint = 4.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  IF (ce_id > 0.0)
   SET reply->potassium = event_tag_num
   SET reply->potassium_ce_id = ce_id
  ENDIF
  IF ((((saved_pot != reply->potassium)) OR ((saved_ce_id != reply->potassium_ce_id))) )
   SET found_new_worst = 1
  ENDIF
 ENDIF
#worst_potassium_exit
#worst_bun
 SET saved_bun = reply->bun
 SET saved_ce_id = reply->bun_ce_id
 IF ((reply->bun > 0)
  AND (reply->bun_ce_id > 0))
  SET reply->bun = - (1)
  SET reply->bun_ce_id = 0
  SET event_tag_num = - (1.0)
  SET event_ce_id = 0
 ELSE
  SET event_tag_num = reply->bun
  SET event_ce_id = reply->bun_ce_id
 ENDIF
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3142")
 IF (res_cd > 0.0)
  EXECUTE FROM highest_result TO highest_result_exit
  IF (ce_id > 0.0)
   SET reply->bun = event_tag_num
   SET reply->bun_ce_id = ce_id
  ENDIF
  IF ((((saved_bun != reply->bun)) OR ((saved_ce_id != reply->bun_ce_id))) )
   SET found_new_worst = 1
  ENDIF
 ENDIF
#worst_bun_exit
#worst_albumin
 SET saved_alb = reply->albumin
 SET saved_ce_id = reply->albumin_ce_id
 IF ((reply->albumin > 0)
  AND (reply->albumin_ce_id > 0))
  SET reply->albumin = - (1)
  SET reply->albumin_ce_id = 0
  SET event_tag_num = - (1.0)
  SET event_ce_id = 0
 ELSE
  SET event_tag_num = reply->albumin
  SET event_ce_id = reply->albumin_ce_id
 ENDIF
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3025")
 IF (res_cd > 0.0)
  SET midpoint = 3.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  IF (ce_id > 0.0)
   SET reply->albumin = event_tag_num
   SET reply->albumin_ce_id = ce_id
  ENDIF
  IF ((((saved_alb != reply->albumin)) OR ((saved_ce_id != reply->albumin_ce_id))) )
   SET found_new_worst = 1
   CALL echo("setting in albumin")
  ENDIF
 ENDIF
#worst_albumin_exit
#worst_glucose
 SET saved_gluc = reply->glucose
 SET saved_ce_id = reply->glucose_ce_id
 IF ((reply->glucose > 0)
  AND (reply->glucose_ce_id > 0))
  SET reply->glucose = - (1)
  SET reply->glucose_ce_id = 0
  SET rad_worst_glucose = - (1.0)
  SET rad_glucose_ce_id = 0
 ELSE
  SET rad_worst_glucose = reply->glucose
  SET rad_glucose_ce_id = reply->glucose_ce_id
 ENDIF
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET gluc1_cd = uar_get_code_by_cki("CKI.EC!3374")
 SET gluc2_cd = uar_get_code_by_cki("CKI.EC!5634")
 SET gluc3_cd = uar_get_code_by_cki("CKI.EC!3375")
 SET gluc4_cd = uar_get_code_by_cki("CKI.EC!3376")
 SET gluc5_cd = uar_get_code_by_cki("CKI.EC!3377")
 SET gluc6_cd = uar_get_code_by_cki("CKI.EC!3378")
 SET gluc7_cd = uar_get_code_by_cki("CKI.EC!3379")
 SET gluc8_cd = uar_get_code_by_cki("CKI.EC!3380")
 SET gluc9_cd = uar_get_code_by_cki("CKI.EC!3386")
 SET gluc10_cd = uar_get_code_by_cki("CKI.EC!3388")
 IF (((gluc1_cd > 0.0) OR (((gluc2_cd > 0.0) OR (((gluc3_cd > 0.0) OR (((gluc4_cd > 0.0) OR (((
 gluc5_cd > 0.0) OR (((gluc6_cd > 0.0) OR (((gluc7_cd > 0.0) OR (((gluc8_cd > 0.0) OR (((gluc9_cd >
 0.0) OR (gluc10_cd > 0.0)) )) )) )) )) )) )) )) )) )
  SET midpoint = 130.0
  SET hold_diff = - (1.0)
  SET temp_res = 0.0
  SET temp_diff = - (1.0)
  SET hold_tag = 0.0
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ce.event_cd IN (gluc1_cd, gluc2_cd, gluc3_cd, gluc4_cd, gluc5_cd,
    gluc6_cd, gluc7_cd, gluc8_cd, gluc9_cd, gluc10_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_res = 0.0, temp_diff = - (1.0),
    hold_diff = - (1.0), isnum = 0, ce_id = 0.0
    IF (rad_worst_glucose > 0)
     temp_res = cnvtreal(rad_worst_glucose), temp_diff = abs((temp_res - midpoint)), hold_diff =
     temp_diff,
     event_tag_num = temp_res, ce_id = rad_glucose_ce_id
    ENDIF
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_res = cnvtreal(ce.event_tag), temp_diff = abs((temp_res - midpoint))
     IF (((temp_diff > hold_diff) OR (temp_diff=hold_diff
      AND ce_id=0)) )
      hold_diff = temp_diff, event_tag_num = temp_res, ce_id = ce.clinical_event_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (ce_id > 0.0)
   SET reply->glucose = event_tag_num
   SET reply->glucose_ce_id = ce_id
  ENDIF
  IF ((((saved_gluc != reply->glucose)) OR ((saved_ce_id != reply->glucose_ce_id))) )
   SET found_new_worst = 1
   CALL echo("setting in glucose")
  ENDIF
 ENDIF
#worst_glucose_exit
#highest_result
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=request->person_id)
    AND ce.event_cd=res_cd
    AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != inerror_cd
    AND ce.event_cd > 0)
  ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
  HEAD REPORT
   temp_res = 0.0, isnum = 0
  DETAIL
   isnum = isnumeric(ce.event_tag)
   IF (isnum > 0)
    temp_res = cnvtreal(ce.event_tag)
    IF (((temp_res > event_tag_num) OR (temp_res=event_tag_num
     AND event_ce_id=0)) )
     event_tag_num = temp_res, ce_id = ce.clinical_event_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#highest_result_exit
#midpoint_rule
 IF (event_tag_num > 0)
  SET hold_diff = abs((event_tag_num - midpoint))
  SET temp_res = 0.0
  SET temp_diff = - (1.0)
  SET hold_tag = event_tag_num
 ELSE
  SET hold_diff = - (1.0)
  SET temp_res = 0.0
  SET temp_diff = - (1.0)
  SET hold_tag = 0.0
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=request->person_id)
    AND ce.event_cd=res_cd
    AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != inerror_cd
    AND ce.event_cd > 0)
  ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
  HEAD REPORT
   temp_res = 0.0, temp_diff = - (1.0), isnum = 0,
   ce_id = 0.0
  DETAIL
   isnum = isnumeric(ce.event_tag)
   IF (isnum > 0)
    temp_res = cnvtreal(ce.event_tag), temp_diff = abs((temp_res - midpoint))
    IF (((temp_diff > hold_diff) OR (temp_diff=hold_diff
     AND event_ce_id=0)) )
     hold_diff = temp_diff, event_tag_num = temp_res, ce_id = ce.clinical_event_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#midpoint_rule_exit
#8000_save_worst_phys
 CALL echo("top of recalc")
 CALL echo(build("reply->risk_adjustment_day_id=",reply->risk_adjustment_day_id))
 IF ((reply->risk_adjustment_day_id=0.0))
  CALL echo("if reply->risk_adjustment_day_id = 0.0 true")
  SET rad_id = 0.0
  SELECT INTO "nl:"
   j = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    rad_id = cnvtreal(j), reply->risk_adjustment_day_id = rad_id,
    CALL echo(build("setting reply->risk_adjustment_day_id=",reply->risk_adjustment_day_id))
   WITH format, nocounter
  ;end select
  IF (rad_id=0.0)
   SET failed_ind = "Y"
   SET failed_text = "Error reading from carenet sequence, write new risk_adjustment_day row."
  ELSE
   EXECUTE FROM load_old_aps TO load_old_aps_exit
   CALL echo("before insert RAD")
   CALL echo(build("rad_id=",reply->risk_adjustment_day_id))
   CALL echo(build("ra_id=",ra_id))
   CALL echo(build("cc_day=",reply->cc_day))
   CALL echo(build("about to insert into rad reply->meds_ce_id=",reply->meds_ce_id))
   INSERT  FROM risk_adjustment_day rad
    SET rad.risk_adjustment_day_id = rad_id, rad.risk_adjustment_id = ra_id, rad.cc_day = reply->
     cc_day,
     rad.cc_beg_dt_tm = cnvtdatetime(reply->cc_beg_dt_tm), rad.cc_end_dt_tm = cnvtdatetime(reply->
      cc_end_dt_tm), rad.valid_from_dt_tm = cnvtdatetime(curdate,curtime3),
     rad.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), rad.intubated_ind = reply->
     intubated_ind, rad.intubated_ce_id = reply->intubated_ce_id,
     rad.vent_ind = reply->vent_ind, rad.worst_gcs_eye_score = reply->eyes, rad.worst_gcs_motor_score
      = reply->motor,
     rad.worst_gcs_verbal_score = reply->verbal, rad.meds_ind = reply->meds_ind, rad.eyes_ce_id =
     reply->eyes_ce_id,
     rad.motor_ce_id = reply->motor_ce_id, rad.verbal_ce_id = reply->verbal_ce_id, rad.meds_ce_id =
     reply->meds_ce_id,
     rad.urine_output = reply->urine_total, rad.urine_24hr_output = reply->urine, rad
     .worst_wbc_result = reply->wbc,
     rad.wbc_ce_id = reply->wbc_ce_id, rad.worst_temp = reply->temp, rad.temp_ce_id = reply->
     temp_ce_id,
     rad.worst_resp_result = reply->resp, rad.resp_ce_id = reply->resp_ce_id, rad.worst_sodium_result
      = reply->sodium,
     rad.sodium_ce_id = reply->sodium_ce_id, rad.worst_heart_rate = reply->heartrate, rad
     .heartrate_ce_id = reply->heartrate_ce_id,
     rad.mean_blood_pressure = reply->meanbp, rad.worst_ph_result = reply->ph, rad.ph_ce_id = reply->
     ph_ce_id,
     rad.worst_hematocrit = reply->hematocrit, rad.hematocrit_ce_id = reply->hematocrit_ce_id, rad
     .worst_creatinine_result = reply->creatinine,
     rad.creatinine_ce_id = reply->creatinine_ce_id, rad.worst_albumin_result = reply->albumin, rad
     .albumin_ce_id = reply->albumin_ce_id,
     rad.worst_pao2_result = reply->pao2, rad.pao2_ce_id = reply->pao2_ce_id, rad.worst_pco2_result
      = reply->pco2,
     rad.pco2_ce_id = reply->pco2_ce_id, rad.worst_bun_result = reply->bun, rad.bun_ce_id = reply->
     bun_ce_id,
     rad.worst_glucose_result = reply->glucose, rad.glucose_ce_id = reply->glucose_ce_id, rad
     .worst_bilirubin_result = reply->bilirubin,
     rad.bilirubin_ce_id = reply->bilirubin_ce_id, rad.worst_potassium_result = reply->potassium, rad
     .potassium_ce_id = reply->potassium_ce_id,
     rad.worst_fio2_result = reply->fio2, rad.fio2_ce_id = reply->fio2_ce_id, rad.aps_score = - (1),
     rad.aps_day1 = aps_day1, rad.aps_yesterday = aps_yesterday, rad.activetx_ind = reply->
     activetx_ind,
     rad.vent_today_ind = reply->vent_today_ind, rad.pa_line_today_ind = reply->pa_line_today_ind,
     rad.outcome_status = - (1),
     rad.apache_iii_score = - (1), rad.apache_ii_score = - (1), rad.phys_res_pts = last_phys_res_pts,
     rad.active_ind = 1, rad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rad
     .active_status_prsnl_id = reqinfo->updt_id,
     rad.active_status_cd = reqdata->active_status_cd, rad.updt_dt_tm = cnvtdatetime(curdate,curtime3
      ), rad.updt_id = reqinfo->updt_id,
     rad.updt_task = reqinfo->updt_task, rad.updt_applctx = reqinfo->updt_applctx, rad.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed_ind = "Y"
    SET failed_text = "Error writing new risk_adjustment_day row."
    CALL echo("failed insert RAD")
    SET reqinfo->commit_ind = 0
    SET reply->status_data.status = "F"
   ELSE
    SET reqinfo->commit_ind = 1
    CALL echo("insert RAD worked")
   ENDIF
  ENDIF
 ELSE
  CALL echo("if reply->risk_adjustment_day_id = 0.0 false")
  CALL echo("cc_day record already exists")
  CALL echo("in update")
  CALL echo(build("aboutto update into rad reply->meds_ce_id=",reply->meds_ce_id))
  UPDATE  FROM risk_adjustment_day rad
   SET rad.intubated_ind = reply->intubated_ind, rad.intubated_ce_id = reply->intubated_ce_id, rad
    .vent_ind = reply->vent_ind,
    rad.worst_gcs_eye_score = reply->eyes, rad.worst_gcs_motor_score = reply->motor, rad
    .worst_gcs_verbal_score = reply->verbal,
    rad.meds_ind = reply->meds_ind, rad.eyes_ce_id = reply->eyes_ce_id, rad.motor_ce_id = reply->
    motor_ce_id,
    rad.verbal_ce_id = reply->verbal_ce_id, rad.meds_ce_id = reply->meds_ce_id, rad.urine_output =
    reply->urine_total,
    rad.urine_24hr_output = reply->urine, rad.worst_wbc_result = reply->wbc, rad.wbc_ce_id = reply->
    wbc_ce_id,
    rad.worst_temp = reply->temp, rad.temp_ce_id = reply->temp_ce_id, rad.worst_resp_result = reply->
    resp,
    rad.resp_ce_id = reply->resp_ce_id, rad.worst_sodium_result = reply->sodium, rad.sodium_ce_id =
    reply->sodium_ce_id,
    rad.worst_heart_rate = reply->heartrate, rad.heartrate_ce_id = reply->heartrate_ce_id, rad
    .mean_blood_pressure = reply->meanbp,
    rad.worst_ph_result = reply->ph, rad.ph_ce_id = reply->ph_ce_id, rad.worst_hematocrit = reply->
    hematocrit,
    rad.hematocrit_ce_id = reply->hematocrit_ce_id, rad.worst_creatinine_result = reply->creatinine,
    rad.creatinine_ce_id = reply->creatinine_ce_id,
    rad.worst_albumin_result = reply->albumin, rad.albumin_ce_id = reply->albumin_ce_id, rad
    .worst_pao2_result = reply->pao2,
    rad.pao2_ce_id = reply->pao2_ce_id, rad.worst_pco2_result = reply->pco2, rad.pco2_ce_id = reply->
    pco2_ce_id,
    rad.worst_bun_result = reply->bun, rad.bun_ce_id = reply->bun_ce_id, rad.worst_glucose_result =
    reply->glucose,
    rad.glucose_ce_id = reply->glucose_ce_id, rad.worst_bilirubin_result = reply->bilirubin, rad
    .bilirubin_ce_id = reply->bilirubin_ce_id,
    rad.worst_potassium_result = reply->potassium, rad.potassium_ce_id = reply->potassium_ce_id, rad
    .worst_fio2_result = reply->fio2,
    rad.fio2_ce_id = reply->fio2_ce_id, rad.active_ind = 1, rad.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    rad.active_status_prsnl_id = reqinfo->updt_id, rad.active_status_cd = reqdata->active_status_cd,
    rad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    rad.updt_id = reqinfo->updt_id, rad.updt_task = reqinfo->updt_task, rad.updt_applctx = reqinfo->
    updt_applctx,
    rad.updt_cnt = 0
   WHERE (rad.risk_adjustment_day_id=reply->risk_adjustment_day_id)
    AND rad.active_ind=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed_ind = "Y"
   SET failed_text = "Error updating risk_adjustment_day row."
   CALL echo("failed  update RAD")
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
  ELSE
   CALL echo("update RAD worked")
   SET reqinfo->commit_ind = 1
  ENDIF
 ENDIF
#8099_save_worst_phys_exit
#load_old_aps
 SET aps_day1 = - (1)
 SET aps_yesterday = - (1)
 SET last_outcome = - (1)
 SET last_phys_res_pts = - (1)
 IF ((reply->cc_day > 1))
  SELECT INTO "nl:"
   FROM risk_adjustment_day rad
   WHERE rad.risk_adjustment_id=ra_id
    AND (rad.cc_day=(reply->cc_day - 1))
    AND rad.active_ind=1
   DETAIL
    aps_day1 = rad.aps_day1, aps_yesterday = rad.aps_yesterday, last_outcome = rad.outcome_status,
    last_phys_res_pts = rad.phys_res_pts
   WITH nocounter
  ;end select
 ELSE
  SET last_outcome = 0
 ENDIF
#load_old_aps_exit
#recalc_apache_predictions
 DECLARE actual_urine = f8
 DECLARE act_icu_ever = f8
 SET aps_score = - (1)
 SET aps_day1 = - (1)
 SET aps_yesterday = - (1)
 SET gender = 0
 SET outcome_status = - (1)
 SET act_icu_ever = - (1.0)
 EXECUTE apachertl
 SET male_cd = meaning_code(57,"MALE")
 SET female_cd = meaning_code(57,"FEMALE")
 CALL echo("top of main recalc call")
 EXECUTE FROM load_rar TO load_rar_exit
 EXECUTE FROM load_person TO load_person_exit
 CALL echo("before 2700 recalc")
 EXECUTE FROM 2700_recalc TO 2799_recalc_exit
#recalc_apache_predictions_exit
#load_rar
 SET teach_type_flag = - (1)
 SET org_id = - (1.00)
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   encounter e,
   risk_adjustment_ref rar
  PLAN (ra
   WHERE (ra.risk_adjustment_id=recalc_parameters->risk_adjustment_id)
    AND ra.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1)
   JOIN (rar
   WHERE rar.organization_id=e.organization_id)
  DETAIL
   org_id = e.organization_id
   IF (rar.teach_type_flag IN (0, 1, 2))
    teach_type_flag = rar.teach_type_flag
   ELSE
    teach_type_flag = 0
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
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   person p
  PLAN (ra
   WHERE (ra.risk_adjustment_id=recalc_parameters->risk_adjustment_id)
    AND ra.active_ind=1)
   JOIN (p
   WHERE p.person_id=ra.person_id
    AND p.active_ind=1)
  HEAD REPORT
   agex = "            ", age_in_mo = 0
  DETAIL
   recalc_record->electivesurgery_ind = ra.electivesurgery_ind, recalc_record->readmit_ind = ra
   .readmit_ind, recalc_record->ima_ind = ra.ima_ind,
   recalc_record->midur_ind = ra.midur_ind, recalc_record->admitdiagnosis = ra.admit_diagnosis,
   recalc_record->admit_source = ra.admit_source,
   recalc_record->discharge_location = uar_get_code_meaning(ra.discharge_location_cd), recalc_record
   ->nbr_grafts_performed = ra.nbr_grafts_performed, recalc_record->hosp_admit_dt_tm = ra
   .hosp_admit_dt_tm,
   recalc_record->var03hspxlos = ra.var03hspxlos_value, recalc_record->ejectfx = ra.ejectfx_fraction,
   recalc_record->dialysis_ind = ra.dialysis_ind,
   recalc_record->aids_ind = ra.aids_ind, recalc_record->hepaticfailure_ind = ra.hepaticfailure_ind,
   recalc_record->lymphoma_ind = ra.lymphoma_ind,
   recalc_record->metastaticcancer_ind = ra.metastaticcancer_ind, recalc_record->leukemia_ind = ra
   .leukemia_ind, recalc_record->immunosuppression_ind = ra.immunosuppression_ind,
   recalc_record->cirrhosis_ind = ra.cirrhosis_ind, recalc_record->thrombolytics_ind = ra
   .thrombolytics_ind, recalc_record->diabetes_ind = ra.diabetes_ind,
   recalc_record->copd_ind = ra.copd_ind, recalc_record->chronic_health_unavail_ind = ra
   .chronic_health_unavail_ind, recalc_record->chronic_health_none_ind = ra.chronic_health_none_ind,
   recalc_record->ami_location = ra.ami_location, recalc_record->risk_adjustment_id =
   recalc_parameters->risk_adjustment_id, recalc_record->person_id = p.person_id,
   recalc_record->encntr_id = ra.encntr_id, recalc_record->icu_admit_dt_tm = ra.icu_admit_dt_tm
   IF (p.sex_cd=male_cd)
    gender = 0,
    CALL echo("MALE")
   ELSEIF (p.sex_cd=female_cd)
    gender = 1,
    CALL echo("FEMALE")
   ENDIF
   age_in_years = apache_age(p.birth_dt_tm,ra.hosp_admit_dt_tm)
  WITH nocounter
 ;end select
 SET hdeath_parameters->risk_adjustment_id = recalc_parameters->risk_adjustment_id
 EXECUTE cco_get_died_hosp_from_ra
 SET recalc_record->diedinhospital_ind = hdeath_reply->hosp_death_ind
 IF (age_in_years < 0)
  SET failed_ind = "Y"
  SET failed_text = "Unable to get valid birth_dt_tm from person table."
 ENDIF
 CALL echo(build("AGE IN YEARES",age_in_years))
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=recalc_parameters->risk_adjustment_id)
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
 SET risk_adjustment_day_id = 0.0
 SET cc_day = recalc_parameters->cc_start_day
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=recalc_parameters->risk_adjustment_id)
    AND (rad.cc_day=recalc_parameters->cc_start_day)
    AND ((rad.risk_adjustment_day_id+ 0) > 0)
    AND ((rad.risk_adjustment_id+ 0) > 0)
    AND rad.active_ind=1)
  DETAIL
   CALL echo("got rad record"),
   CALL echo(build("Recalc_parameters->risk_adjustment_id=",recalc_parameters->risk_adjustment_id)),
   CALL echo(build("cc_day=",rad.cc_day)),
   CALL echo(build("rad_id=",rad.risk_adjustment_day_id)), recalc_record->risk_adjustment_day_id =
   rad.risk_adjustment_day_id, recalc_record->cc_day = rad.cc_day,
   recalc_record->cc_beg_dt_tm = cnvtdatetime(rad.cc_beg_dt_tm), recalc_record->cc_end_dt_tm =
   cnvtdatetime(rad.cc_end_dt_tm), recalc_record->intubated_ind = rad.intubated_ind,
   recalc_record->intubated_ce_id = rad.intubated_ce_id, recalc_record->vent_ind = rad.vent_ind,
   recalc_record->eyes = rad.worst_gcs_eye_score,
   recalc_record->motor = rad.worst_gcs_motor_score, recalc_record->verbal = rad
   .worst_gcs_verbal_score, recalc_record->meds_ind = rad.meds_ind,
   recalc_record->eyes_ce_id = rad.eyes_ce_id, recalc_record->motor_ce_id = rad.motor_ce_id,
   recalc_record->verbal_ce_id = rad.verbal_ce_id,
   recalc_record->meds_ce_id = rad.meds_ce_id,
   CALL echo(build("setting Recalc_Record->meds_ce_id=",recalc_record->meds_ce_id)), actual_urine =
   rad.urine_output,
   recalc_record->urine = rad.urine_24hr_output, recalc_record->wbc = rad.worst_wbc_result,
   recalc_record->wbc_ce_id = rad.wbc_ce_id,
   recalc_record->temp = rad.worst_temp, recalc_record->temp_ce_id = rad.temp_ce_id, recalc_record->
   resp = rad.worst_resp_result,
   recalc_record->resp_ce_id = rad.resp_ce_id, recalc_record->sodium = rad.worst_sodium_result,
   recalc_record->sodium_ce_id = rad.sodium_ce_id,
   recalc_record->heartrate = rad.worst_heart_rate, recalc_record->heartrate_ce_id = rad
   .heartrate_ce_id, recalc_record->meanbp = rad.mean_blood_pressure,
   recalc_record->ph = rad.worst_ph_result, recalc_record->ph_ce_id = rad.ph_ce_id, recalc_record->
   hematocrit = rad.worst_hematocrit,
   recalc_record->hematocrit_ce_id = rad.hematocrit_ce_id, recalc_record->creatinine = rad
   .worst_creatinine_result, recalc_record->creatinine_ce_id = rad.creatinine_ce_id,
   recalc_record->albumin = rad.worst_albumin_result, recalc_record->albumin_ce_id = rad
   .albumin_ce_id, recalc_record->pao2 = rad.worst_pao2_result,
   recalc_record->pao2_ce_id = rad.pao2_ce_id, recalc_record->pco2 = rad.worst_pco2_result,
   recalc_record->pco2_ce_id = rad.pco2_ce_id,
   recalc_record->bun = rad.worst_bun_result, recalc_record->bun_ce_id = rad.bun_ce_id, recalc_record
   ->glucose = rad.worst_glucose_result,
   recalc_record->glucose_ce_id = rad.glucose_ce_id, recalc_record->bilirubin = rad
   .worst_bilirubin_result, recalc_record->bilirubin_ce_id = rad.bilirubin_ce_id,
   recalc_record->potassium = rad.worst_potassium_result, recalc_record->potassium_ce_id = rad
   .potassium_ce_id, recalc_record->fio2 = rad.worst_fio2_result,
   recalc_record->fio2_ce_id = rad.fio2_ce_id, recalc_record->activetx_ind = rad.activetx_ind,
   recalc_record->vent_today_ind = rad.vent_today_ind,
   recalc_record->pa_line_today_ind = rad.pa_line_today_ind
  WITH nocounter
 ;end select
 CALL echo(build("Recalc_Record->heartrate",recalc_record->heartrate))
 CALL echo(build("Recalc_Record->heartrate_ce_id",recalc_record->heartrate_ce_id))
 IF ((recalc_record->risk_adjustment_day_id > 0.0))
  IF (age_in_years < 16)
   SET outcome_status = - (23103)
   CALL echo("AGE LESS THAN 16")
  ELSE
   EXECUTE FROM get_aps_info TO get_aps_info_exit
   EXECUTE FROM get_phys_res TO get_phys_res_exit
   IF (aps_status >= 0)
    CALL echo("APS_STATUS >=0, GETTING OUTCOMES")
    EXECUTE FROM get_outcomes TO get_outcomes_exit
   ELSE
    SET outcome_status = aps_status
   ENDIF
  ENDIF
  CALL echo("going to create_rad_rao")
  EXECUTE FROM create_rad_rao TO create_rad_rao_exit
  CALL echo("going to inactivate_rad_rao")
  EXECUTE FROM inactivate_rad_rao TO inactivate_rad_rao_exit
 ELSE
  CALL echo(build("day_id !> 0",recalc_record->risk_adjustment_day_id))
 ENDIF
#2799_recalc_exit
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
 CALL echo(build("p1=",size(aps_variable),",p2=",size(aps_prediction),",p3=",
   size(aps_outcome)))
 EXECUTE FROM 6000_get_carry_over TO 6099_get_carry_over_exit
 SET status = - (1)
 IF ((aps_variable->svent < 0))
  SET status = - (22003)
 ELSEIF (age_in_years < 16)
  SET status = - (23103)
 ELSE
  SET status = uar_amsapscalculate(aps_variable)
  CALL echo(build("uar_AmsApsCalculate=",status))
 ENDIF
 SET aps_status = status
 IF (status < 0)
  CALL echo(build("uar_AmsApsCalculate err=",uar_amsraprinterror(status)))
  SET aps_score = - (1)
 ELSE
  CALL echo(build("aps score=",status))
  SET aps_score = status
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
     WHERE (ra.person_id=recalc_record->person_id)
      AND (ra.encntr_id=recalc_record->encntr_id)
      AND ra.icu_admit_dt_tm=cnvtdatetime(recalc_record->icu_admit_dt_tm)
      AND ra.active_ind=1)
     JOIN (rad
     WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
      AND rad.active_ind=1
      AND ((rad.cc_day=1) OR ((rad.cc_day=(recalc_record->cc_day - 1))))
      AND rad.outcome_status >= 0)
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
 ENDIF
#get_aps_info_exit
#get_phys_res
 IF ((request->aids_ind=0)
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
 CALL echo(build("phys_res=",phys_res_pts))
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
 SET abc = format(recalc_record->icu_admit_dt_tm,"mm/dd/yyyy;;d")
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
 SET status = uar_amscalculatepredictions(aps_prediction,aps_outcome)
 CALL echo(build("uar_AmsCalculatePredictions=",status))
 IF (status < 0)
  CALL echo(build("uar_AmsCalculatePredictions err=",uar_amsraprinterror(status)))
 ELSE
  CALL echo(build("outcomes",status))
 ENDIF
 SET outcome_status = status
#get_outcomes_exit
#create_rad_rao
 SET failed_ind = "N"
 SET ap2_qual = 0
 SET se_array_size = 0
 CALL echo("getting carenet_seq #")
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
  CALL echo("got carenet #")
  SET apache_recalc_reply_ra_day_id = rad_id
  CALL echo(build("before insert RAD_id=",rad_id))
  IF (aps_score >= 0
   AND phys_res_pts >= 0)
   SET ap3_score = value((aps_score+ phys_res_pts))
  ELSE
   SET ap3_score = - (1)
  ENDIF
  CALL echo(build("restting rad from Recalc_Record->meds_ce_id=",recalc_record->meds_ce_id))
  INSERT  FROM risk_adjustment_day rad
   SET rad.risk_adjustment_day_id = rad_id, rad.risk_adjustment_id = recalc_record->
    risk_adjustment_id, rad.cc_day = recalc_record->cc_day,
    rad.cc_beg_dt_tm = cnvtdatetime(recalc_record->cc_beg_dt_tm), rad.cc_end_dt_tm = cnvtdatetime(
     recalc_record->cc_end_dt_tm), rad.valid_from_dt_tm = cnvtdatetime(curdate,curtime3),
    rad.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), rad.intubated_ind = recalc_record->
    intubated_ind, rad.intubated_ce_id = recalc_record->intubated_ce_id,
    rad.vent_ind = recalc_record->vent_ind, rad.worst_gcs_eye_score = recalc_record->eyes, rad
    .worst_gcs_motor_score = recalc_record->motor,
    rad.worst_gcs_verbal_score = recalc_record->verbal, rad.meds_ind = recalc_record->meds_ind, rad
    .eyes_ce_id = recalc_record->eyes_ce_id,
    rad.motor_ce_id = recalc_record->motor_ce_id, rad.verbal_ce_id = recalc_record->verbal_ce_id, rad
    .meds_ce_id = recalc_record->meds_ce_id,
    rad.urine_output = actual_urine, rad.urine_24hr_output = recalc_record->urine, rad
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
    rad.updt_task = reqinfo->updt_task, rad.updt_applctx = reqinfo->updt_applctx, rad.updt_cnt = 0
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
     WHERE (rae.risk_adjustment_id=recalc_record->risk_adjustment_id)
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
    SET ap2_parameters->risk_adjustment_id = recalc_record->risk_adjustment_id
    SET ap2_parameters->cc_day = recalc_record->cc_day
    SET ap2_parameters->cc_beg_dt_tm = cnvtdatetime(recalc_record->cc_beg_dt_tm)
    SET ap2_parameters->cc_end_dt_tm = cnvtdatetime(recalc_record->cc_end_dt_tm)
    EXECUTE dcp_calc_apache_ii_score
   ENDIF
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
       CALL echo("before RAO insert")
       CALL echo(aps_outcome->qual[num].szequationname)
       CALL echo(aps_outcome->qual[num].dwoutcome)
       INSERT  FROM risk_adjustment_outcomes rao
        SET rao.risk_adjustment_outcomes_id = seq(carenet_seq,nextval), rao.risk_adjustment_day_id =
         rad_id, rao.equation_name = trim(equation_name),
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
       CALL echo("after RAO Insert")
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
    AND act_icu_ever >= 0.0)
    IF (((act_icu_ever * 100.0) <= 10.0))
     SET therapy_level = 2
    ELSE
     SET therapy_level = 3
    ENDIF
   ENDIF
  ENDIF
  UPDATE  FROM risk_adjustment ra
   SET ra.therapy_level = therapy_level
   WHERE (ra.risk_adjustment_id=recalc_record->risk_adjustment_id)
   WITH nocounter
  ;end update
 ENDIF
#create_rad_rao_exit
#inactivate_rad_rao
 CALL echo(build("in recalc inactivate Recalc_Record->risk_adjustment_day_id",recalc_record->
   risk_adjustment_day_id))
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
  CALL echo("inactivate failed in recalc")
  SET reqinfo->commit_ind = 0
 ELSE
  CALL echo("inactivate worked in recalc")
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
#6000_get_carry_over
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
 SET check_cc_day = recalc_parameters->cc_start_day
 WHILE (stillneed2find > 0
  AND check_cc_day > 0)
  SET check_cc_day = (check_cc_day - 1)
  SELECT INTO "nl:"
   FROM risk_adjustment ra,
    risk_adjustment_day rad
   PLAN (ra
    WHERE (ra.person_id=recalc_record->person_id)
     AND (ra.encntr_id=recalc_record->encntr_id)
     AND ra.icu_admit_dt_tm=cnvtdatetime(recalc_record->icu_admit_dt_tm)
     AND ra.active_ind=1)
    JOIN (rad
    WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
     AND rad.cc_day=check_cc_day
     AND rad.active_ind=1)
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
 ENDWHILE
#6099_get_carry_over_exit
#9999_exit_program
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "QUERY"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_GET_APACHE_PHYS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = failed_text
 ENDIF
 CALL echorecord(reply)
END GO
