CREATE PROGRAM dcp_upd_risk_adjustment:dba
 RECORD reply(
   1 risk_adjustment_id = f8
   1 risk_adjustment_day_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD sent_tiss_list(
   1 tisslist[*]
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 tiss_meaning = vc
     2 pa_line_ind = i2
     2 activetx_ind = i2
     2 vent_today_ind = i2
 )
 RECORD tiss_day_list(
   1 tiss_day[*]
     2 cc_day = i2
     2 cc_beg_dt_tm = dq8
     2 cc_end_dt_tm = dq8
     2 old_activetx_ind = i2
     2 old_pa_line_ind = i2
     2 old_vent_today_ind = i2
     2 activetx_ind = i2
     2 pa_line_ind = i2
     2 vent_today_ind = i2
 )
 RECORD tiss_list(
   1 list[95]
     2 code_value = f8
     2 tiss_name = vc
     2 tiss_num = i4
     2 ce_cd = f8
     2 acttx_ind = i2
 )
 RECORD ap2_parameters(
   1 risk_adjustment_id = f8
   1 cc_day = i2
   1 cc_beg_dt_tm = dq8
   1 cc_end_dt_tm = dq8
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
 RECORD get_visit_parameters(
   1 risk_adjustment_id = f8
 )
 DECLARE day_cnt = i4
 DECLARE failedrao_text = vc
 SET failedrao_text = fillstring(100," ")
 RECORD temp(
   1 dlist[*]
     2 risk_adjustment_id = f8
     2 risk_adjustment_day_id = f8
     2 cc_day = i4
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
 DECLARE status = i4
 DECLARE aps_status = i4
 DECLARE outcomestatus = i4
 DECLARE carry_flag = i4
 DECLARE wbc_temp = f8
 DECLARE hct_temp = f8
 DECLARE na_temp = f8
 DECLARE bun_temp = f8
 DECLARE cre_temp = f8
 DECLARE glu_temp = f8
 DECLARE alb_temp = f8
 DECLARE bil_temp = f8
 DECLARE actual_urine = f8
 DECLARE temp_tiss_key = vc
 DECLARE meaning_code(p1,p2) = f8
 DECLARE save_ce_ids_from_getting_nuked(p1) = null
 DECLARE accept_tiss_acttx_if_ind = i2
 DECLARE accept_tiss_nonacttx_if_ind = i2
 DECLARE parserstring = vc
 DECLARE apache_age(birth_dt_tm,admit_dt_tm) = i2
 DECLARE visit_num = i4
 DECLARE gcs_eyes_ce_id = f8
 DECLARE gcs_motor_ce_id = f8
 DECLARE gcs_verbal_ce_id = f8
 DECLARE gcs_meds_ce_id = f8
 DECLARE abg_intubated_ce_id = f8
 DECLARE map_ce_ind = i2
 DECLARE urine_ce_ind = i2
 DECLARE vent_ce_id = f8
 SET accept_tiss_nonacttx_if_ind = - (1)
 SET accept_tiss_acttx_if_ind = - (1)
 DECLARE failed_text = vc
 SET failed_ind = "Y"
 SET failed_text = fillstring(100," ")
 SET failed_text = "Initial call to DCP_UPD_RISK_ADJUSTMENT"
 DECLARE temp_tiss_cd = f8
 DECLARE original_cc_day = i2
 DECLARE discharge_location_meaning = vc
 SET day1meds = - (1)
 SET day1verbal = - (1)
 SET day1motor = - (1)
 SET day1eyes = - (1)
 SET day1pao2 = - (1.0)
 SET day1fio2 = - (1.0)
 EXECUTE apachertl
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
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 IF ((request->adm_data_changed_ind=0)
  AND (request->daily_data_changed_ind=0)
  AND (request->event_data_changed_ind=0)
  AND (request->tiss_data_changed_ind=0)
  AND (request->disch_data_changed_ind=0))
  SET failed_ind = "Y"
  SET failed_text = "Request indicates no adm, disch, event, tiss or daily changes/additions."
  GO TO 9999_exit_program
 ENDIF
 IF ((request->adm_data_changed_ind=0)
  AND (request->risk_adjustment_id=0))
  SET failed_text = "Risk_adjustment_id is required if not a new admit, request invalid."
  SET failed_ind = "Y"
  GO TO 9999_exit_program
 ENDIF
 CALL save_ce_ids_from_getting_nuked("")
 IF ((((request->adm_data_changed_ind=1)) OR ((((request->daily_data_changed_ind=1)) OR ((request->
 tiss_data_changed_ind=1))) )) )
  EXECUTE FROM load_encntr TO load_encntr_exit
  IF (failed_ind="Y")
   GO TO 9999_exit_program
  ENDIF
  EXECUTE FROM load_rar TO load_rar_exit
  EXECUTE FROM load_person TO load_person_exit
  IF (failed_ind="Y")
   GO TO 9999_exit_program
  ENDIF
 ENDIF
 EXECUTE FROM 2000_process TO 2099_process_exit
 SET failed_ind = "N"
 GO TO 9999_exit_program
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
#load_encntr_tiss
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_day_id=request->risk_adjustment_day_id)
    AND rad.active_ind=1)
  DETAIL
   request->activetx_ind = rad.activetx_ind, request->vent_today_ind = rad.vent_today_ind, request->
   pa_line_today_ind = rad.pa_line_today_ind
  WITH nocounter
 ;end select
#load_encntr_tiss_exit
#load_encntr
 SET org_id = 0.0
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id)
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  DETAIL
   request->diedinhospital_ind = - (1), org_id = e.organization_id
  WITH nocounter
 ;end select
 IF (org_id=0)
  SET failed_ind = "Y"
  SET failed_text = "Error loading a valid org_id from encounter table."
 ENDIF
#load_encntr_exit
#load_rar
 SET teach_flag_type = - (1)
 SELECT INTO "nl:"
  FROM risk_adjustment_ref rar
  PLAN (rar
   WHERE rar.organization_id=org_id)
  HEAD REPORT
   got_one = 0
  DETAIL
   IF (((rar.active_ind=1) OR (got_one=0)) )
    IF (rar.teach_type_flag IN (0, 1, 2))
     teach_flag_type = rar.teach_type_flag
    ENDIF
    IF (rar.region_flag IN (1, 2, 3, 4))
     hsp_region_flag = rar.region_flag
    ENDIF
    IF (rar.bed_count > 0)
     bedcount = rar.bed_count
    ENDIF
    accept_tiss_acttx_if_ind = rar.accept_tiss_acttx_if_ind, accept_tiss_nonacttx_if_ind = rar
    .accept_tiss_nonacttx_if_ind
   ENDIF
   got_one = 1
  WITH nocounter
 ;end select
 IF (teach_flag_type < 0)
  SET failed_ind = "Y"
  SET failed_text = build("Error reading risk_adjustment_ref table.",org_id)
 ENDIF
#load_rar_exit
#load_person
 SET age_in_years = - (1)
 SELECT INTO "nl:"
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person_id))
  HEAD REPORT
   agex = "            ", age_in_mo = 0
  DETAIL
   IF (p.sex_cd=male_cd)
    gender = 0
   ELSEIF (p.sex_cd=female_cd)
    gender = 1
   ENDIF
   age_in_years = apache_age(p.birth_dt_tm,request->hosp_admit_dt_tm)
  WITH nocounter
 ;end select
 IF (age_in_years < 0)
  SET failed_ind = "Y"
  SET failed_text = "Unable to get valid birth_dt_tm from person table."
 ENDIF
#load_person_exit
#get_aps_info
 SET aps_variable->sintubated = request->intubated_ind
 SET aps_variable->svent = request->vent_ind
 SET aps_variable->sdialysis = request->dialysis_ind
 SET aps_variable->seyes = request->eyes
 SET aps_variable->smotor = request->motor
 SET aps_variable->sverbal = request->verbal
 SET aps_variable->smeds = request->meds_ind
 SET aps_variable->dwurine = request->urine
 SET aps_variable->dwwbc = request->wbc
 IF ((request->temp < 50))
  SET aps_variable->dwtemp = request->temp
 ELSE
  SET aps_variable->dwtemp = (((request->temp - 32) * 5)/ 9)
 ENDIF
 SET aps_variable->dwrespiratoryrate = request->resp
 SET aps_variable->dwsodium = request->sodium
 SET aps_variable->dwheartrate = request->heartrate
 SET aps_variable->dwmeanbp = request->meanbp
 SET aps_variable->dwph = request->ph
 SET aps_variable->dwhematocrit = request->hematocrit
 SET aps_variable->dwcreatinine = request->creatinine
 SET aps_variable->dwalbumin = request->albumin
 SET aps_variable->dwpao2 = request->pao2
 SET aps_variable->dwpco2 = request->pco2
 SET aps_variable->dwbun = request->bun
 SET aps_variable->dwglucose = request->glucose
 SET aps_variable->dwbilirubin = request->bilirubin
 SET aps_variable->dwfio2 = request->fio2
 IF ((request->cc_day=1))
  SET day1meds = request->meds_ind
  SET day1verbal = request->verbal
  SET day1motor = request->motor
  SET day1eyes = request->eyes
  SET day1pao2 = request->pao2
  SET day1fio2 = request->fio2
 ENDIF
 EXECUTE FROM 5000_get_carry_over TO 5099_get_carry_over_exit
 SET status = - (1)
 IF ((request->vent_ind < 0))
  SET status = - (22003)
 ELSEIF (age_in_years < 16)
  SET status = - (23103)
 ELSE
  SET status = uar_amsapscalculate(aps_variable)
 ENDIF
 SET aps_status = status
 IF (status < 0)
  SET apsscore = - (1)
 ELSE
  SET apsscore = status
  IF ((request->cc_day=1))
   SET apsday1 = apsscore
   SET apsyesterday = 0
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
      AND ((rad.cc_day=1) OR ((rad.cc_day=(request->cc_day - 1))))
      AND rad.outcome_status >= 0)
    DETAIL
     IF (rad.cc_day=1)
      apsday1 = rad.aps_score, day_one_found = "Y"
      IF ((request->cc_day=2))
       apsyesterday = rad.aps_score, yesterday_found = "Y"
      ENDIF
     ELSEIF ((rad.cc_day=(request->cc_day - 1)))
      apsyesterday = rad.aps_score, yesterday_found = "Y"
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
  AND (request->hepaticfailure_ind=0)
  AND (request->lymphoma_ind=0)
  AND (request->metastaticcancer_ind=0)
  AND (request->leukemia_ind=0)
  AND (request->immunosuppression_ind=0)
  AND (request->cirrhosis_ind=0)
  AND (request->diabetes_ind=0)
  AND (request->copd_ind=0)
  AND (request->chronic_health_unavail_ind=0)
  AND (request->chronic_health_none_ind=0))
  SET phys_resv_pts = - (1)
 ELSE
  SET phys_resv_pts = 0
  IF (age_in_years BETWEEN 45 AND 59)
   SET phys_resv_pts = 5
  ELSEIF (age_in_years BETWEEN 60 AND 64)
   SET phys_resv_pts = 11
  ELSEIF (age_in_years BETWEEN 65 AND 69)
   SET phys_resv_pts = 13
  ELSEIF (age_in_years BETWEEN 70 AND 74)
   SET phys_resv_pts = 16
  ELSEIF (age_in_years BETWEEN 75 AND 84)
   SET phys_resv_pts = 17
  ELSEIF (age_in_years > 84)
   SET phys_resv_pts = 24
  ENDIF
  IF ((request->electivesurgery_ind != 1))
   IF ((request->aids_ind=1))
    SET phys_resv_pts = (phys_resv_pts+ 23)
   ELSEIF ((request->hepaticfailure_ind=1))
    SET phys_resv_pts = (phys_resv_pts+ 16)
   ELSEIF ((request->lymphoma_ind=1))
    SET phys_resv_pts = (phys_resv_pts+ 13)
   ELSEIF ((request->metastaticcancer_ind=1))
    SET phys_resv_pts = (phys_resv_pts+ 11)
   ELSEIF ((request->leukemia_ind=1))
    SET phys_resv_pts = (phys_resv_pts+ 10)
   ELSEIF ((request->immunosuppression_ind=1))
    SET phys_resv_pts = (phys_resv_pts+ 10)
   ELSEIF ((request->cirrhosis_ind=1))
    SET phys_resv_pts = (phys_resv_pts+ 4)
   ENDIF
  ENDIF
 ENDIF
#get_phys_res_exit
#get_outcomes
 SET request->ventday1_ind = - (2)
 SET request->oobventday1_ind = - (2)
 SET request->oobintubday1_ind = - (2)
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE rad.risk_adjustment_id=ra_id
    AND rad.cc_day=1
    AND rad.active_ind=1)
  DETAIL
   request->oobintubday1_ind = rad.intubated_ind, request->oobventday1_ind = rad.vent_ind, request->
   ventday1_ind = rad.vent_today_ind
  WITH nocounter
 ;end select
 SET get_visit_parameters->risk_adjustment_id = ra_id
 EXECUTE cco_get_apache_visit_number
 SET aps_prediction->sicuday = request->cc_day
 SET aps_prediction->saps3day1 = apsday1
 SET aps_prediction->saps3today = apsscore
 SET aps_prediction->saps3yesterday = apsyesterday
 SET aps_prediction->sgender = gender
 SET aps_prediction->steachtype = teach_flag_type
 SET aps_prediction->sregion = hsp_region_flag
 SET aps_prediction->sbedcount = bedcount
 IF ((request->admit_source IN ("CHPAIN_CTR", "ICU", "ICU_TO_OR")))
  SET aps_prediction->sadmitsource = 5
 ELSEIF ((request->admit_source="OR"))
  SET aps_prediction->sadmitsource = 1
 ELSEIF ((request->admit_source="RR"))
  SET aps_prediction->sadmitsource = 2
 ELSEIF ((request->admit_source="ER"))
  SET aps_prediction->sadmitsource = 3
 ELSEIF ((request->admit_source="FLOOR"))
  SET aps_prediction->sadmitsource = 4
 ELSEIF ((request->admit_source="OTHER_HOSP"))
  SET aps_prediction->sadmitsource = 6
 ELSEIF ((request->admit_source="DIR_ADMIT"))
  SET aps_prediction->sadmitsource = 7
 ELSEIF ((request->admit_source IN ("SDU", "ICU_TO_SDU")))
  SET aps_prediction->sadmitsource = 8
 ENDIF
 SET aps_prediction->sgraftcount = request->nbr_grafts_performed
 SET aps_prediction->smeds = request->meds_ind
 SET aps_prediction->sverbal = request->verbal
 SET aps_prediction->smotor = request->motor
 SET aps_prediction->seyes = request->eyes
 SET aps_prediction->sage = age_in_years
 SET abc = fillstring(20," ")
 SET abc = format(request->icu_admit_dt_tm,"mm/dd/yyyy;;d")
 SET aps_prediction->szicuadmitdate = concat(trim(abc),char(0))
 SET abc = fillstring(20," ")
 SET abc = format(request->hosp_admit_dt_tm,"mm/dd/yyyy;;d")
 SET aps_prediction->szhospadmitdate = concat(trim(abc),char(0))
 SET aps_prediction->szadmitdiagnosis = concat(trim(request->admitdiagnosis),char(0))
 SET aps_prediction->bthrombolytics = request->thrombolytics_ind
 SET aps_prediction->bdiedinhospital = request->diedinhospital_ind
 SET aps_prediction->baids = request->aids_ind
 SET aps_prediction->bhepaticfailure = request->hepaticfailure_ind
 SET aps_prediction->blymphoma = request->lymphoma_ind
 SET aps_prediction->bmetastaticcancer = request->metastaticcancer_ind
 SET aps_prediction->bleukemia = request->leukemia_ind
 SET aps_prediction->bimmunosuppression = request->immunosuppression_ind
 SET aps_prediction->bcirrhosis = request->cirrhosis_ind
 IF ((request->aids_ind=0)
  AND (request->hepaticfailure_ind=0)
  AND (request->lymphoma_ind=0)
  AND (request->metastaticcancer_ind=0)
  AND (request->leukemia_ind=0)
  AND (request->immunosuppression_ind=0)
  AND (request->cirrhosis_ind=0)
  AND (request->diabetes_ind=0)
  AND (request->copd_ind=0)
  AND (request->chronic_health_unavail_ind=0)
  AND (request->chronic_health_none_ind=0))
  SET aps_prediction->baids = - (1)
  SET aps_prediction->bhepaticfailure = - (1)
  SET aps_prediction->blymphoma = - (1)
  SET aps_prediction->bmetastaticcancer = - (1)
  SET aps_prediction->bleukemia = - (1)
  SET aps_prediction->bimmunosuppression = - (1)
  SET aps_prediction->bcirrhosis = - (1)
 ENDIF
 SET aps_prediction->belectivesurgery = request->electivesurgery_ind
 SET aps_prediction->bactivetx = request->activetx_ind
 SET aps_prediction->breadmit = request->readmit_ind
 SET aps_prediction->bima = request->ima_ind
 SET aps_prediction->bmidur = request->midur_ind
 SET aps_prediction->bventday1 = request->ventday1_ind
 SET aps_prediction->boobventday1 = maxval(request->oobventday1_ind,request->ventday1_ind)
 SET aps_prediction->boobintubday1 = request->oobintubday1_ind
 SET aps_prediction->bdiabetes = request->diabetes_ind
 SET aps_prediction->bmanagementsystem = 1
 SET aps_prediction->dwvar03hspxlos = request->var03hspxlos
 SET aps_prediction->dwpao2 = request->pao2
 SET aps_prediction->dwfio2 = request->fio2
 SET aps_prediction->dwejectfx = request->ejectfx
 SET aps_prediction->dwcreatinine = request->creatinine
 SET discharge_location_meaning = uar_get_code_meaning(request->discharge_location_cd)
 IF ((request->diedinicu_ind=1))
  SET discharge_location_meaning = "DEATH"
 ENDIF
 IF (discharge_location_meaning="FLOOR")
  SET aps_prediction->sdischargelocation = 4
 ELSEIF (discharge_location_meaning="ICU_TRANSFER")
  SET aps_prediction->sdischargelocation = 5
 ELSEIF (discharge_location_meaning="OTHER_HOSP")
  SET aps_prediction->sdischargelocation = 6
 ELSEIF (discharge_location_meaning="HOME")
  SET aps_prediction->sdischargelocation = 7
 ELSEIF (discharge_location_meaning="OTHER")
  SET aps_prediction->sdischargelocation = 8
 ELSEIF (discharge_location_meaning="DEATH")
  SET aps_prediction->sdischargelocation = 9
 ELSE
  SET aps_prediction->sdischargelocation = - (1)
 ENDIF
 SET aps_prediction->svisitnumber = get_visit_reply->visit_number
 IF ((request->ami_location="ANT"))
  SET aps_prediction->samilocation = 1
 ELSEIF ((request->ami_location="ANTLAT"))
  SET aps_prediction->samilocation = 2
 ELSEIF ((request->ami_location="ANTSEP"))
  SET aps_prediction->samilocation = 3
 ELSEIF ((request->ami_location="INF"))
  SET aps_prediction->samilocation = 4
 ELSEIF ((request->ami_location="LAT"))
  SET aps_prediction->samilocation = 5
 ELSEIF ((request->ami_location="NONQ"))
  SET aps_prediction->samilocation = 6
 ELSEIF ((request->ami_location="POST"))
  SET aps_prediction->samilocation = 7
 ELSE
  SET aps_prediction->samilocation = - (1)
 ENDIF
 SET abc = fillstring(20," ")
 SET abc = format(request->icu_admit_dt_tm,"mm/dd/yyyy hh:mm;;d")
 SET aps_prediction->szicuadmitdatetime = concat(trim(abc),char(0))
 SET abc = fillstring(20," ")
 SET abc = format(request->hosp_admit_dt_tm,"mm/dd/yyyy hh:mm;;d")
 SET aps_prediction->szhospadmitdatetime = concat(trim(abc),char(0))
 SET aps_prediction->sday1meds = day1meds
 SET aps_prediction->sday1verbal = day1verbal
 SET aps_prediction->sday1motor = day1motor
 SET aps_prediction->sday1eyes = day1eyes
 SET aps_prediction->dwday1pao2 = day1pao2
 SET aps_prediction->dwday1fio2 = day1fio2
 SET status = uar_amscalculatepredictions(aps_prediction,aps_outcome)
 IF (status < 0)
  CALL echo(build("uar_AmsCalculatePredictions err=",uar_amsraprinterror(status)))
 ENDIF
 SET outcomestatus = status
#get_outcomes_exit
#get_new_ra_id
 SET ra_id = 0.0
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   ra_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 IF (ra_id=0)
  SET failed_ind = "Y"
  SET failed_text = "Error reading from carenet sequence."
 ENDIF
#get_new_ra_id_exit
#1000_initialize
 SET reply->status_data.status = "F"
 SET failed_ind = "N"
 DECLARE equationname = vc
 DECLARE act_icu_ever = f8
 DECLARE therapy_level = i2
 DECLARE ra_id = i4 WITH protect
 SET act_icu_ever = - (1)
 SET therapy_level = - (1)
 SET teach_flag_type = 0
 SET hsp_region_flag = 1
 SET bedcount = 200
 SET apsscore = - (1)
 SET apsday1 = - (1)
 SET apsyesterday = - (1)
 SET age_in_years = 0
 SET gender = - (1)
 SET ra_id = 0.0
 SET recalc_ra_id = 0.0
 SET rad_id = 0.0
 SET risk_adjustment_id = 0.0
 SET tmp_risk_adjustment_day_id = 0.0
 SET hold_cc_day = 0
 SET original_cc_day = request->cc_day
 SET male_cd = meaning_code(57,"MALE")
 SET female_cd = meaning_code(57,"FEMALE")
 SET abc = fillstring(20," ")
 SET cont_flag = "Y"
 SET phys_resv_pts = 0
 SET icu_disch_dttm = cnvtdatetime("31-DEC-2100")
 IF (cnvtdatetime(request->icu_disch_dt_tm) > 0)
  SET icu_disch_dttm = cnvtdatetime(request->icu_disch_dt_tm)
 ENDIF
#1099_initialize_exit
#2000_process
 IF ((request->risk_adjustment_id=0.0))
  EXECUTE FROM get_new_ra_id TO get_new_ra_id_exit
  IF (failed_ind="N")
   EXECUTE FROM create_ra TO create_ra_exit
   IF (failed_ind="N")
    IF ((request->daily_data_changed_ind=1))
     EXECUTE FROM get_aps_info TO get_aps_info_exit
     EXECUTE FROM get_phys_res TO get_phys_res_exit
     EXECUTE FROM 3500_get_existing_tiss_flags TO 3599_get_existing_tiss_flags_exit
     EXECUTE FROM 3600_check_open_ended_tiss TO 3600_check_open_ended_tiss_exit
     IF (age_in_years < 16)
      SET outcomestatus = - (23103)
     ELSE
      IF (aps_status >= 0)
       EXECUTE FROM get_outcomes TO get_outcomes_exit
      ELSE
       SET outcomestatus = aps_status
      ENDIF
     ENDIF
     CALL echo("before CREATE_RAD_RAO #1")
     EXECUTE FROM create_rad_rao TO create_rad_rao_exit
     IF (failed_ind="N")
      SET reply->risk_adjustment_day_id = rad_id
     ENDIF
    ENDIF
    IF ((request->tiss_data_changed_ind=1))
     SET request->risk_adjustment_id = ra_id
     EXECUTE FROM 3300_tiss_list_to_database TO 3399_tiss_list_to_database_exit
     EXECUTE FROM 3400_tiss_database_to_request TO 3499_tiss_database_to_request_exit
    ELSE
     SET request->risk_adjustment_id = ra_id
     EXECUTE FROM 3500_get_existing_tiss_flags TO 3599_get_existing_tiss_flags_exit
     EXECUTE FROM 3600_check_open_ended_tiss TO 3600_check_open_ended_tiss_exit
    ENDIF
    IF ((request->event_data_changed_ind=1)
     AND failed_ind="N")
     EXECUTE FROM 3100_event TO 3199_event_exit
    ENDIF
   ENDIF
  ENDIF
 ELSEIF ((request->risk_adjustment_day_id=0.0)
  AND (request->daily_data_changed_ind=1)
  AND (request->adm_data_changed_ind=0))
  EXECUTE FROM get_aps_info TO get_aps_info_exit
  EXECUTE FROM get_phys_res TO get_phys_res_exit
  EXECUTE FROM 3500_get_existing_tiss_flags TO 3599_get_existing_tiss_flags_exit
  EXECUTE FROM 3600_check_open_ended_tiss TO 3600_check_open_ended_tiss_exit
  IF (age_in_years < 16)
   SET outcomestatus = - (23103)
  ELSE
   IF (aps_status >= 0)
    EXECUTE FROM get_outcomes TO get_outcomes_exit
   ELSE
    SET outcomestatus = aps_status
   ENDIF
  ENDIF
  SET ra_id = request->risk_adjustment_id
  EXECUTE FROM create_rad_rao TO create_rad_rao_exit
  IF (failed_ind="N")
   SET reply->risk_adjustment_day_id = rad_id
   IF ((request->disch_data_changed_ind=1))
    EXECUTE FROM 3000_disch TO 3099_disch_exit
   ENDIF
   IF ((request->tiss_data_changed_ind=1))
    EXECUTE FROM 3300_tiss_list_to_database TO 3399_tiss_list_to_database_exit
    EXECUTE FROM 3400_tiss_database_to_request TO 3499_tiss_database_to_request_exit
   ELSE
    EXECUTE FROM 3500_get_existing_tiss_flags TO 3599_get_existing_tiss_flags_exit
    EXECUTE FROM 3600_check_open_ended_tiss TO 3600_check_open_ended_tiss_exit
   ENDIF
   IF ((request->event_data_changed_ind=1)
    AND failed_ind="N")
    EXECUTE FROM 3100_event TO 3199_event_exit
   ENDIF
  ENDIF
 ELSEIF ((request->adm_data_changed_ind=0)
  AND (request->daily_data_changed_ind=1)
  AND (request->risk_adjustment_day_id > 0.0))
  IF ((request->tiss_data_changed_ind=0))
   EXECUTE FROM 3500_get_existing_tiss_flags TO 3599_get_existing_tiss_flags_exit
   EXECUTE FROM 3600_check_open_ended_tiss TO 3600_check_open_ended_tiss_exit
  ENDIF
  CALL echo("AT LINE 1241 FOR AN UPDATE!!!")
  EXECUTE FROM get_aps_info TO get_aps_info_exit
  EXECUTE FROM get_phys_res TO get_phys_res_exit
  EXECUTE FROM 3500_get_existing_tiss_flags TO 3599_get_existing_tiss_flags_exit
  EXECUTE FROM 3600_check_open_ended_tiss TO 3600_check_open_ended_tiss_exit
  IF (age_in_years < 16)
   SET outcomestatus = - (23103)
  ELSE
   IF (aps_status >= 0)
    EXECUTE FROM get_outcomes TO get_outcomes_exit
   ELSE
    SET outcomestatus = aps_status
   ENDIF
  ENDIF
  SET ra_id = request->risk_adjustment_id
  CALL echo("before CREATE_RAD_RAO #3")
  EXECUTE FROM list_to_inactivate_rad_rao TO list_to_inactivate_rad_rao_exit
  EXECUTE FROM create_rad_rao TO create_rad_rao_exit
  IF (failed_ind="N")
   SET reply->risk_adjustment_day_id = rad_id
   SET tmp_risk_adjustment_day_id = request->risk_adjustment_day_id
   EXECUTE FROM inactivate_rad_rao TO inactivate_rad_rao_exit
   IF (failed_ind="N")
    IF ((request->tiss_data_changed_ind=1))
     EXECUTE FROM 3300_tiss_list_to_database TO 3399_tiss_list_to_database_exit
     EXECUTE FROM 3400_tiss_database_to_request TO 3499_tiss_database_to_request_exit
    ENDIF
    SET cc_day = (request->cc_day - 1)
    SET hold_cc_day = request->cc_day
    SET hold_cc_beg_dt_tm = request->cc_beg_dt_tm
    SET hold_cc_end_dt_tm = request->cc_end_dt_tm
    SET recalc_ra_id = request->risk_adjustment_id
    SET cont_flag = "Y"
    WHILE (cont_flag="Y")
      EXECUTE FROM 2700_recalc TO 2799_recalc_exit
    ENDWHILE
    SET request->cc_day = hold_cc_day
    SET request->cc_beg_dt_tm = hold_cc_beg_dt_tm
    SET request->cc_end_dt_tm = hold_cc_end_dt_tm
    IF ((request->disch_data_changed_ind=1)
     AND failed_ind="N")
     EXECUTE FROM 3000_disch TO 3099_disch_exit
    ENDIF
    IF ((request->event_data_changed_ind=1)
     AND failed_ind="N")
     EXECUTE FROM 3100_event TO 3199_event_exit
    ENDIF
   ENDIF
  ENDIF
 ELSEIF ((request->adm_data_changed_ind=1)
  AND (request->daily_data_changed_ind=0))
  EXECUTE FROM get_new_ra_id TO get_new_ra_id_exit
  IF (failed_ind="N")
   SET risk_adjustment_id = request->risk_adjustment_id
   EXECUTE FROM inactivate_ra TO inactivate_ra_exit
   IF (failed_ind="N")
    EXECUTE FROM create_ra TO create_ra_exit
    IF (failed_ind="N")
     EXECUTE FROM update_events TO update_events_exit
     EXECUTE FROM update_tiss TO update_tiss_exit
     SET hold_cc_day = request->cc_day
     SET cc_day = 0
     SET recalc_ra_id = ra_id
     SET cont_flag = "Y"
     WHILE (cont_flag="Y")
       EXECUTE FROM 2700_recalc TO 2799_recalc_exit
     ENDWHILE
     IF ((request->event_data_changed_ind=1)
      AND failed_ind="N")
      EXECUTE FROM 3100_event TO 3199_event_exit
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ELSEIF ((request->adm_data_changed_ind=1)
  AND (request->daily_data_changed_ind=1)
  AND (request->risk_adjustment_day_id > 0.0))
  EXECUTE FROM 3500_get_existing_tiss_flags TO 3599_get_existing_tiss_flags_exit
  EXECUTE FROM 3600_check_open_ended_tiss TO 3600_check_open_ended_tiss_exit
  EXECUTE FROM get_aps_info TO get_aps_info_exit
  EXECUTE FROM get_phys_res TO get_phys_res_exit
  IF (age_in_years < 16)
   SET outcomestatus = - (23103)
  ELSE
   IF (aps_status >= 0)
    EXECUTE FROM get_outcomes TO get_outcomes_exit
   ELSE
    SET outcomestatus = aps_status
   ENDIF
  ENDIF
  SET ra_id = request->risk_adjustment_id
  EXECUTE FROM list_to_inactivate_rad_rao TO list_to_inactivate_rad_rao_exit
  EXECUTE FROM create_rad_rao TO create_rad_rao_exit
  IF (failed_ind="N")
   SET tmp_risk_adjustment_day_id = request->risk_adjustment_day_id
   EXECUTE FROM inactivate_rad_rao TO inactivate_rad_rao_exit
   IF (failed_ind="N")
    EXECUTE FROM get_new_ra_id TO get_new_ra_id_exit
    IF (failed_ind="N")
     SET risk_adjustment_id = request->risk_adjustment_id
     EXECUTE FROM inactivate_ra TO inactivate_ra_exit
     IF (failed_ind="N")
      EXECUTE FROM create_ra TO create_ra_exit
      IF (failed_ind="N")
       IF ((request->tiss_data_changed_ind=1))
        EXECUTE FROM 3300_tiss_list_to_database TO 3399_tiss_list_to_database_exit
        EXECUTE FROM 3400_tiss_database_to_request TO 3499_tiss_database_to_request_exit
       ENDIF
       EXECUTE FROM update_events TO update_events_exit
       EXECUTE FROM update_tiss TO update_tiss_exit
       SET hold_cc_day = request->cc_day
       SET cc_day = 0
       SET recalc_ra_id = ra_id
       SET cont_flag = "Y"
       WHILE (cont_flag="Y")
         EXECUTE FROM 2700_recalc TO 2799_recalc_exit
       ENDWHILE
       IF ((request->event_data_changed_ind=1)
        AND failed_ind="N")
        EXECUTE FROM 3100_event TO 3199_event_exit
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ELSEIF ((request->adm_data_changed_ind=1)
  AND (request->daily_data_changed_ind=1)
  AND (request->risk_adjustment_day_id=0.0))
  EXECUTE FROM get_aps_info TO get_aps_info_exit
  EXECUTE FROM get_phys_res TO get_phys_res_exit
  EXECUTE FROM 3500_get_existing_tiss_flags TO 3599_get_existing_tiss_flags_exit
  EXECUTE FROM 3600_check_open_ended_tiss TO 3600_check_open_ended_tiss_exit
  IF (age_in_years < 16)
   SET outcomestatus = - (23103)
  ELSE
   IF (aps_status >= 0)
    EXECUTE FROM get_outcomes TO get_outcomes_exit
   ELSE
    SET outcomestatus = aps_status
   ENDIF
  ENDIF
  SET ra_id = request->risk_adjustment_id
  EXECUTE FROM create_rad_rao TO create_rad_rao_exit
  IF (failed_ind="N")
   EXECUTE FROM get_new_ra_id TO get_new_ra_id_exit
   IF (failed_ind="N")
    SET risk_adjustment_id = request->risk_adjustment_id
    EXECUTE FROM inactivate_ra TO inactivate_ra_exit
    IF (failed_ind="N")
     EXECUTE FROM create_ra TO create_ra_exit
     IF (failed_ind="N")
      IF ((request->tiss_data_changed_ind=1))
       EXECUTE FROM 3300_tiss_list_to_database TO 3399_tiss_list_to_database_exit
       EXECUTE FROM 3400_tiss_database_to_request TO 3499_tiss_database_to_request_exit
      ELSE
       EXECUTE FROM 3500_get_existing_tiss_flags TO 3599_get_existing_tiss_flags_exit
       EXECUTE FROM 3600_check_open_ended_tiss TO 3600_check_open_ended_tiss_exit
      ENDIF
      EXECUTE FROM update_events TO update_events_exit
      EXECUTE FROM update_tiss TO update_tiss_exit
      SET cc_day = 0
      SET recalc_ra_id = ra_id
      SET cont_flag = "Y"
      WHILE (cont_flag="Y")
        EXECUTE FROM 2700_recalc TO 2799_recalc_exit
      ENDWHILE
      IF ((request->event_data_changed_ind=1)
       AND failed_ind="N")
       EXECUTE FROM 3100_event TO 3199_event_exit
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ELSEIF ((request->disch_data_changed_ind=1))
  EXECUTE FROM 3000_disch TO 3099_disch_exit
  IF ((request->event_data_changed_ind=1)
   AND failed_ind="N")
   SET ra_id = request->risk_adjustment_id
   EXECUTE FROM 3100_event TO 3199_event_exit
  ENDIF
 ELSEIF ((request->event_data_changed_ind=1))
  SET ra_id = request->risk_adjustment_id
  EXECUTE FROM 3100_event TO 3199_event_exit
 ENDIF
 IF ((request->tiss_data_changed_ind=1)
  AND failed_ind="N")
  SET hold_cc_day = request->cc_day
  SET cc_day = 0
  SET recalc_ra_id = ra_id
  SET cont_flag = "Y"
  WHILE (cont_flag="Y")
    EXECUTE FROM 2700_recalc TO 2799_recalc_exit
  ENDWHILE
 ENDIF
 IF (failed_ind="Y")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = failed_text
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reply->risk_adjustment_id = ra_id
  SET reqinfo->commit_ind = 1
 ENDIF
#2099_process_exit
#create_ra
 SET ad_cd = meaning_code(28984,request->admitdiagnosis)
 SET disease_cat_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value_group cvg
  PLAN (cvg
   WHERE cvg.code_set=28984
    AND cvg.child_code_value=ad_cd)
  DETAIL
   disease_cat_cd = cvg.parent_code_value
  WITH nocounter
 ;end select
 INSERT  FROM risk_adjustment ra
  SET ra.risk_adjustment_id = ra_id, ra.person_id = request->person_id, ra.encntr_id = request->
   encntr_id,
   ra.admit_icu_cd = request->admission_icu_cd, ra.med_service_cd = request->med_service_cd, ra
   .valid_from_dt_tm = cnvtdatetime(curdate,curtime3),
   ra.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), ra.dialysis_ind = request->
   dialysis_ind, ra.gender_flag = gender,
   ra.teach_type_flag = teach_flag_type, ra.region_flag = hsp_region_flag, ra.bed_count = bedcount,
   ra.admitsource_flag = request->admitsource_flag, ra.nbr_grafts_performed = request->
   nbr_grafts_performed, ra.adm_doc_id = request->adm_doc_id,
   ra.admit_age = age_in_years, ra.icu_admit_dt_tm = cnvtdatetime(request->icu_admit_dt_tm), ra
   .hosp_admit_dt_tm = cnvtdatetime(request->hosp_admit_dt_tm),
   ra.admit_diagnosis = request->admitdiagnosis, ra.disease_category_cd = disease_cat_cd, ra
   .thrombolytics_ind = request->thrombolytics_ind,
   ra.diedinhospital_ind = - (1), ra.diedinicu_ind = request->diedinicu_ind, ra.copd_flag = request->
   copd_flag,
   ra.copd_ind = request->copd_ind, ra.hrs_at_source = request->time_at_source, ra
   .chronic_health_unavail_ind = request->chronic_health_unavail_ind,
   ra.chronic_health_none_ind = request->chronic_health_none_ind, ra.aids_ind = request->aids_ind, ra
   .hepaticfailure_ind = request->hepaticfailure_ind,
   ra.lymphoma_ind = request->lymphoma_ind, ra.metastaticcancer_ind = request->metastaticcancer_ind,
   ra.leukemia_ind = request->leukemia_ind,
   ra.immunosuppression_ind = request->immunosuppression_ind, ra.cirrhosis_ind = request->
   cirrhosis_ind, ra.electivesurgery_ind = request->electivesurgery_ind,
   ra.readmit_ind = request->readmit_ind, ra.ima_ind = request->ima_ind, ra.midur_ind = request->
   midur_ind,
   ra.therapy_level = - (1), ra.diabetes_ind = request->diabetes_ind, ra.var03hspxlos_value = request
   ->var03hspxlos,
   ra.ejectfx_fraction = request->ejectfx, ra.admit_source = request->admit_source, ra
   .discharge_location_cd = request->discharge_location_cd,
   ra.body_system = request->body_system, ra.xfer_within_48hr_ind = request->xfer_within_48hr_ind, ra
   .readmit_within_24hr_ind = request->readmit_within_24hr_ind,
   ra.ami_location = request->ami_location, ra.ptca_device = request->ptca_device, ra.sv_graft_ind =
   request->sv_graft_ind,
   ra.mi_within_6mo_ind = request->mi_within_6mo_ind, ra.cc_during_stay_ind = request->
   cc_during_stay_ind, ra.icu_disch_dt_tm = cnvtdatetime(icu_disch_dttm),
   ra.active_ind = 1, ra.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ra
   .active_status_prsnl_id = reqinfo->updt_id,
   ra.active_status_cd = reqdata->active_status_cd, ra.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   ra.updt_id = reqinfo->updt_id,
   ra.updt_task = reqinfo->updt_task, ra.updt_applctx = reqinfo->updt_applctx, ra.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed_ind = "Y"
  SET failed_text = "Error writing new risk_adjustment row."
 ELSE
  SET reply->risk_adjustment_id = ra_id
 ENDIF
#create_ra_exit
#create_rad_rao
 SET ap2_qual = 0
 SET se_array_size = 0
 SET wbc_temp = - (1.00)
 SET hct_temp = - (1.00)
 SET na_temp = - (1.00)
 SET bun_temp = - (1.00)
 SET cre_temp = - (1.00)
 SET glu_temp = - (1.00)
 SET alb_temp = - (1.00)
 SET bil_temp = - (1.00)
 SET carry_flag = request->carry_over_flags
 IF (carry_flag < 0)
  SET carry_flag = 0
 ENDIF
 CALL echo("ABOUT TO GET NEW RAD_ID")
 SET rad_id = 0.0
 SELECT INTO "nl:"
  k = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   rad_id = cnvtreal(k)
  WITH format, nocounter
 ;end select
 IF (rad_id=0.0)
  SET failed_ind = "Y"
  SET failed_text = "Error reading from carenet sequence, write new risk_adjustment_day row."
 ELSE
  CALL echo(build("SETTING RAD_ID=",rad_id))
  IF ((request->cc_day=original_cc_day))
   EXECUTE FROM 5100_remove_carry_over_values TO 5199_remove_carry_over_values_exit
  ENDIF
  IF (apsscore >= 0
   AND phys_resv_pts >= 0)
   SET ap_3_score = value((apsscore+ phys_resv_pts))
  ELSE
   SET ap_3_score = - (1)
  ENDIF
  CALL echo("before insert RAD")
  CALL echo(build("rad_id=",rad_id))
  CALL echo(build("eyes_ce_id = ",gcs_eyes_ce_id))
  INSERT  FROM risk_adjustment_day rad
   SET rad.risk_adjustment_day_id = rad_id, rad.risk_adjustment_id = ra_id, rad.cc_day = request->
    cc_day,
    rad.cc_beg_dt_tm = cnvtdatetime(request->cc_beg_dt_tm), rad.cc_end_dt_tm = cnvtdatetime(request->
     cc_end_dt_tm), rad.valid_from_dt_tm = cnvtdatetime(curdate,curtime3),
    rad.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), rad.intubated_ind = request->
    intubated_ind, rad.intubated_ce_id = abg_intubated_ce_id,
    rad.vent_ind = request->vent_ind, rad.worst_gcs_eye_score = request->eyes, rad.eyes_ce_id =
    gcs_eyes_ce_id,
    rad.worst_gcs_motor_score = request->motor, rad.motor_ce_id = gcs_motor_ce_id, rad
    .worst_gcs_verbal_score = request->verbal,
    rad.verbal_ce_id = gcs_verbal_ce_id, rad.meds_ind = request->meds_ind, rad.meds_ce_id =
    gcs_meds_ce_id,
    rad.map_ce_ind = map_ce_ind, rad.urine_ce_ind = urine_ce_ind, rad.vent_ce_id = vent_ce_id,
    rad.urine_output = request->urine_actual, rad.urine_24hr_output = request->urine, rad
    .worst_wbc_result = request->wbc,
    rad.wbc_ce_id = request->wbc_ce_id, rad.worst_temp = request->temp, rad.temp_ce_id = request->
    temp_ce_id,
    rad.worst_resp_result = request->resp, rad.resp_ce_id = request->resp_ce_id, rad
    .worst_sodium_result = request->sodium,
    rad.sodium_ce_id = request->sodium_ce_id, rad.worst_heart_rate = request->heartrate, rad
    .heartrate_ce_id = request->heartrate_ce_id,
    rad.mean_blood_pressure = request->meanbp, rad.worst_ph_result = request->ph, rad.ph_ce_id =
    request->ph_ce_id,
    rad.worst_hematocrit = request->hematocrit, rad.hematocrit_ce_id = request->hematocrit_ce_id, rad
    .worst_creatinine_result = request->creatinine,
    rad.creatinine_ce_id = request->creatinine_ce_id, rad.worst_albumin_result = request->albumin,
    rad.albumin_ce_id = request->albumin_ce_id,
    rad.worst_pao2_result = request->pao2, rad.pao2_ce_id = request->pao2_ce_id, rad
    .worst_pco2_result = request->pco2,
    rad.pco2_ce_id = request->pco2_ce_id, rad.worst_bun_result = request->bun, rad.bun_ce_id =
    request->bun_ce_id,
    rad.worst_glucose_result = request->glucose, rad.glucose_ce_id = request->glucose_ce_id, rad
    .worst_bilirubin_result = request->bilirubin,
    rad.bilirubin_ce_id = request->bilirubin_ce_id, rad.worst_potassium_result = request->potassium,
    rad.potassium_ce_id = request->potassium_ce_id,
    rad.worst_fio2_result = request->fio2, rad.fio2_ce_id = request->fio2_ce_id, rad.aps_score =
    apsscore,
    rad.aps_day1 = apsday1, rad.aps_yesterday = apsyesterday, rad.activetx_ind = request->
    activetx_ind,
    rad.vent_today_ind = request->vent_today_ind, rad.pa_line_today_ind = request->pa_line_today_ind,
    rad.outcome_status = outcomestatus,
    rad.apache_iii_score = ap_3_score, rad.apache_ii_score = - (1), rad.phys_res_pts = value(
     phys_resv_pts),
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
   SET ap2_qual = 0
   SET se_array_size = size(request->selist,5)
   IF (se_array_size > 0)
    FOR (se_num = 1 TO se_array_size)
      IF (uar_get_code_display(request->selist[se_num].sentinel_event_code_cd)="SEPSIS*")
       SET ap2_qual = 1
      ENDIF
    ENDFOR
   ENDIF
   IF (ap2_qual=0)
    SELECT INTO "nl:"
     FROM risk_adjustment_event rae
     WHERE rae.risk_adjustment_id=ra_id
      AND rae.active_ind=1
      AND rae.beg_effective_dt_tm < cnvtdatetime(request->cc_end_dt_tm)
      AND rae.end_effective_dt_tm > cnvtdatetime(request->cc_beg_dt_tm)
     DETAIL
      IF (uar_get_code_display(rae.sentinel_event_code_cd)="SEPSIS*")
       ap2_qual = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->admitdiagnosis="SEPSIS*"))
    SET ap2_qual = 1
   ENDIF
   IF (ap2_qual=1)
    SET ap2_parameters->risk_adjustment_id = ra_id
    SET ap2_parameters->cc_day = request->cc_day
    SET ap2_parameters->cc_beg_dt_tm = cnvtdatetime(request->cc_beg_dt_tm)
    SET ap2_parameters->cc_end_dt_tm = cnvtdatetime(request->cc_end_dt_tm)
    EXECUTE dcp_calc_apache_ii_score
   ENDIF
   IF ((request->cc_day=original_cc_day))
    EXECUTE FROM 5200_put_carry_over_back TO 5299_put_carry_over_back_exit
   ENDIF
   IF (outcomestatus > 0)
    FOR (num = 1 TO 100)
      IF ((aps_outcome->qual[num].szequationname > " "))
       SET equationname = trim(aps_outcome->qual[num].szequationname)
       IF ((request->cc_day=1))
        IF (equationname="ACT_ICU_EVER")
         SET act_icu_ever = - (1.0)
         SET act_icu_ever = aps_outcome->qual[num].dwoutcome
        ENDIF
       ENDIF
       SET rao_id = 0.0
       SELECT INTO "nl:"
        l = seq(carenet_seq,nextval)
        FROM dual
        DETAIL
         rao_id = cnvtreal(l)
        WITH format, nocounter
       ;end select
       IF (rao_id=0.0)
        SET failed_ind = "Y"
        SET failed_text = "Error reading from carenet sequence."
       ENDIF
       INSERT  FROM risk_adjustment_outcomes rao
        SET rao.risk_adjustment_outcomes_id = rao_id, rao.risk_adjustment_day_id = rad_id, rao
         .equation_name = trim(equationname),
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
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
 IF ((request->cc_day=1)
  AND failed_ind="N")
  SET therapy_level = - (1)
  IF ((((outcomestatus=- (23100))) OR ((((outcomestatus=- (23103))) OR ((outcomestatus=- (23117))))
  )) )
   IF ((request->activetx_ind=1))
    SET therapy_level = 5
   ELSEIF ((request->activetx_ind=0))
    SET therapy_level = 4
   ENDIF
  ELSE
   IF ((request->activetx_ind=1))
    SET therapy_level = 1
   ELSEIF ((request->activetx_ind=0)
    AND outcomestatus > 0
    AND act_icu_ever >= 0)
    IF (((act_icu_ever * 100) <= 10))
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
#inactivate_ra
 SET junk_id = 0.0
 SET junk_id = risk_adjustment_id
 UPDATE  FROM risk_adjustment ra
  SET ra.valid_until_dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),- ((1/ 1440))), ra.active_ind
    = 0, ra.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra.updt_task = reqinfo->updt_task, ra.updt_applctx
    = reqinfo->updt_applctx,
   ra.updt_id = reqinfo->updt_id, ra.updt_cnt = (ra.updt_cnt+ 1)
  WHERE ra.risk_adjustment_id=junk_id
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed_ind = "Y"
  SET failed_text = "Error inactivating risk_adjustment row (600711)."
 ENDIF
#inactivate_ra_exit
#update_events
 SET junk_id = 0.0
 SET junk_id = risk_adjustment_id
 UPDATE  FROM risk_adjustment_event rae
  SET rae.risk_adjustment_id = ra_id, rae.updt_dt_tm = cnvtdatetime(curdate,curtime3), rae.updt_task
    = reqinfo->updt_task,
   rae.updt_applctx = reqinfo->updt_applctx, rae.updt_id = reqinfo->updt_id, rae.updt_cnt = (rae
   .updt_cnt+ 1)
  WHERE rae.risk_adjustment_id=junk_id
  WITH nocounter
 ;end update
#update_events_exit
#update_tiss
 SET junk_id = 0.0
 SET junk_id = risk_adjustment_id
 UPDATE  FROM risk_adj_tiss rat
  SET rat.risk_adjustment_id = ra_id, rat.updt_dt_tm = cnvtdatetime(curdate,curtime3), rat.updt_task
    = reqinfo->updt_task,
   rat.updt_applctx = reqinfo->updt_applctx, rat.updt_id = reqinfo->updt_id, rat.updt_cnt = (rat
   .updt_cnt+ 1)
  WHERE rat.risk_adjustment_id=junk_id
  WITH nocounter
 ;end update
#update_tiss_exit
#list_to_inactivate_rad_rao
 SET day_cnt = 0
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
    AND rad.active_ind=1
    AND (rad.cc_day=request->cc_day))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->dlist,cnt), temp->dlist[cnt].risk_adjustment_day_id = rad
   .risk_adjustment_day_id,
   temp->dlist[cnt].risk_adjustment_id = rad.risk_adjustment_id
  FOOT REPORT
   day_cnt = cnt
  WITH nocounter
 ;end select
#list_to_inactivate_rad_rao_exit
#inactivate_rad_rao
 IF (day_cnt > 0)
  FOR (y = 1 TO day_cnt)
   UPDATE  FROM risk_adjustment_day rad
    SET rad.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rad.active_ind = 0, rad
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     rad.updt_dt_tm = cnvtdatetime(curdate,curtime3), rad.updt_task = reqinfo->updt_task, rad
     .updt_applctx = reqinfo->updt_applctx,
     rad.updt_id = reqinfo->updt_id, rad.updt_cnt = (rad.updt_cnt+ 1)
    WHERE (rad.risk_adjustment_day_id=temp->dlist[y].risk_adjustment_day_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed_ind = "Y"
    SET failed_text = build(temp->dlist[y].risk_adjustment_day_id,
     " Error inactivating risk_adjustment_day row.")
    CALL echo(failed_text)
   ELSE
    UPDATE  FROM risk_adjustment_outcomes rao
     SET rao.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rao.active_ind = 0, rao
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      rao.updt_dt_tm = cnvtdatetime(curdate,curtime3), rao.updt_task = reqinfo->updt_task, rao
      .updt_applctx = reqinfo->updt_applctx,
      rao.updt_id = reqinfo->updt_id, rao.updt_cnt = (rao.updt_cnt+ 1)
     WHERE (rao.risk_adjustment_day_id=temp->dlist[y].risk_adjustment_day_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failedrao_text = build(temp->dlist[y].risk_adjustment_day_id,
      " Error inactivating risk_adjustment_outcomes row.")
     CALL echo(failedrao_text)
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
#inactivate_rad_rao_exit
#2700_recalc
 SET tmp_risk_adjustment_day_id = 0.0
 SET cc_day = (cc_day+ 1)
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
    AND rad.cc_day=cc_day
    AND rad.active_ind=1)
  DETAIL
   IF (rad.cc_day=cc_day)
    tmp_risk_adjustment_day_id = rad.risk_adjustment_day_id, request->cc_day = rad.cc_day, request->
    cc_beg_dt_tm = cnvtdatetime(rad.cc_beg_dt_tm),
    request->cc_end_dt_tm = cnvtdatetime(rad.cc_end_dt_tm), request->intubated_ind = rad
    .intubated_ind, abg_intubated_ce_id = rad.intubated_ce_id,
    request->vent_ind = rad.vent_ind, request->eyes = rad.worst_gcs_eye_score, gcs_eyes_ce_id = rad
    .eyes_ce_id,
    request->motor = rad.worst_gcs_motor_score, gcs_motor_ce_id = rad.eyes_ce_id, request->verbal =
    rad.worst_gcs_verbal_score,
    gcs_verbal_ce_id = rad.eyes_ce_id, request->meds_ind = rad.meds_ind, gcs_meds_ce_id = rad
    .eyes_ce_id,
    map_ce_ind = rad.map_ce_ind, urine_ce_ind = rad.urine_ce_ind, vent_ce_id = rad.vent_ce_id,
    request->urine_actual = rad.urine_output, request->urine = rad.urine_24hr_output, request->wbc =
    rad.worst_wbc_result,
    request->wbc_ce_id = rad.wbc_ce_id, request->temp = rad.worst_temp, request->temp_ce_id = rad
    .temp_ce_id,
    request->resp = rad.worst_resp_result, request->resp_ce_id = rad.resp_ce_id, request->sodium =
    rad.worst_sodium_result,
    request->sodium_ce_id = rad.sodium_ce_id, request->heartrate = rad.worst_heart_rate, request->
    heartrate_ce_id = rad.heartrate_ce_id,
    request->meanbp = rad.mean_blood_pressure, request->ph = rad.worst_ph_result, request->ph_ce_id
     = rad.ph_ce_id,
    request->hematocrit = rad.worst_hematocrit, request->hematocrit_ce_id = rad.hematocrit_ce_id,
    request->creatinine = rad.worst_creatinine_result,
    request->creatinine_ce_id = rad.creatinine_ce_id, request->albumin = rad.worst_albumin_result,
    request->albumin_ce_id = rad.albumin_ce_id,
    request->pao2 = rad.worst_pao2_result, request->pao2_ce_id = rad.pao2_ce_id, request->pco2 = rad
    .worst_pco2_result,
    request->pco2_ce_id = rad.pco2_ce_id, request->bun = rad.worst_bun_result, request->bun_ce_id =
    rad.bun_ce_id,
    request->glucose = rad.worst_glucose_result, request->glucose_ce_id = rad.glucose_ce_id, request
    ->bilirubin = rad.worst_bilirubin_result,
    request->bilirubin_ce_id = rad.bilirubin_ce_id, request->potassium = rad.worst_potassium_result,
    request->potassium_ce_id = rad.potassium_ce_id,
    request->fio2 = rad.worst_fio2_result, request->fio2_ce_id = rad.fio2_ce_id, request->
    activetx_ind = rad.activetx_ind,
    request->vent_today_ind = rad.vent_today_ind, request->pa_line_today_ind = rad.pa_line_today_ind
   ENDIF
  WITH nocounter
 ;end select
 IF (tmp_risk_adjustment_day_id > 0.0)
  SET request->risk_adjustment_day_id = tmp_risk_adjustment_day_id
  EXECUTE FROM get_aps_info TO get_aps_info_exit
  EXECUTE FROM get_phys_res TO get_phys_res_exit
  EXECUTE FROM 3500_get_existing_tiss_flags TO 3599_get_existing_tiss_flags_exit
  EXECUTE FROM 3600_check_open_ended_tiss TO 3600_check_open_ended_tiss_exit
  IF (age_in_years < 16)
   SET outcomestatus = - (23103)
  ELSE
   IF (aps_status >= 0)
    EXECUTE FROM get_outcomes TO get_outcomes_exit
   ELSE
    SET outcomestatus = aps_status
   ENDIF
  ENDIF
  SET ra_id = recalc_ra_id
  EXECUTE FROM list_to_inactivate_rad_rao TO list_to_inactivate_rad_rao_exit
  EXECUTE FROM create_rad_rao TO create_rad_rao_exit
  IF (failed_ind="N")
   IF (cc_day=hold_cc_day)
    SET reply->risk_adjustment_day_id = rad_id
   ENDIF
   CALL echo(build("SETTING REPLY RAD_ID=",rad_id))
   CALL echo(build("ABOUT TO INACTIVE OLD RAD row=",request->risk_adjustment_day_id))
   SET tmp_risk_adjustment_day_id = request->risk_adjustment_day_id
   EXECUTE FROM inactivate_rad_rao TO inactivate_rad_rao_exit
  ENDIF
  IF (failed_ind="Y")
   SET cont_flag = "N"
  ENDIF
 ELSE
  SET cont_flag = "N"
 ENDIF
#2799_recalc_exit
#3000_disch
 SET cc_day_start_time = 0700
 SELECT INTO "nl:"
  FROM encounter e,
   risk_adjustment_ref rar
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id))
   JOIN (rar
   WHERE rar.organization_id=e.organization_id)
  DETAIL
   cc_day_start_time = rar.icu_day_start_time
  WITH nocounter
 ;end select
 UPDATE  FROM risk_adjustment ra
  SET ra.icu_disch_dt_tm = cnvtdatetime(icu_disch_dttm), ra.diedinhospital_ind = - (1), ra
   .discharge_location_cd = request->discharge_location_cd,
   ra.diedinicu_ind = request->diedinicu_ind, ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra
   .updt_task = reqinfo->updt_task,
   ra.updt_applctx = reqinfo->updt_applctx, ra.updt_id = reqinfo->updt_id, ra.updt_cnt = (ra.updt_cnt
   + 1)
  WHERE (ra.risk_adjustment_id=request->risk_adjustment_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed_ind = "Y"
  SET failed_text = "Unable to update discharge info on RA row."
 ENDIF
 UPDATE  FROM risk_adj_tiss rat
  SET rat.tiss_end_dt_tm = cnvtdatetime(request->icu_disch_dt_tm), rat.updt_cnt = (rat.updt_cnt+ 1),
   rat.updt_id = reqinfo->updt_id,
   rat.updt_applctx = reqinfo->updt_applctx, rat.updt_dt_tm = cnvtdatetime(curdate,curtime3), rat
   .updt_task = reqinfo->updt_task
  WHERE (rat.risk_adjustment_id=request->risk_adjustment_id)
   AND rat.tiss_end_dt_tm > cnvtdatetime(request->icu_disch_dt_tm)
   AND rat.active_ind=1
  WITH nocounter
 ;end update
 IF (icu_disch_dttm=cnvtdatetime("31-DEC-2100"))
  SET temp_total_urine = - (1)
  SET temp_24hr_urine = - (1)
  SET cc_end_dt_tm_fixed = cnvtdatetime("31-DEC-2100")
  SET cc_beg_dt_tm_to_fix = cnvtdatetime("31-DEC-2100")
  SET rad_id_to_fix = 0.0
  SET junk = 1.0
  SET goturine = 0
  SELECT INTO "nl:"
   FROM risk_adjustment_day rad,
    risk_adjustment ra
   PLAN (ra
    WHERE (ra.risk_adjustment_id=request->risk_adjustment_id)
     AND ra.active_ind=1)
    JOIN (rad
    WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
     AND rad.active_ind=1)
   ORDER BY rad.cc_day DESC
   HEAD REPORT
    rad_id_to_fix = rad.risk_adjustment_day_id, cc_beg_dt_tm_to_fix = cnvtdatetime(rad.cc_beg_dt_tm),
    temp_total_urine = rad.urine_output
    IF (rad.cc_day=1)
     today_date = datetimefind(rad.cc_beg_dt_tm,"D","B","B"), today_date = cnvtdatetime(cnvtdate(
       today_date),cc_day_start_time), cc_end_dt_tm_fixed = datetimeadd(today_date,- (0.000694))
     IF (cc_end_dt_tm_fixed < rad.cc_beg_dt_tm)
      cc_end_dt_tm_fixed = datetimeadd(cc_end_dt_tm_fixed,1)
     ENDIF
     IF (datetimediff(cc_end_dt_tm_fixed,rad.cc_beg_dt_tm,3) < 8)
      cc_end_dt_tm_fixed = datetimeadd(cc_end_dt_tm_fixed,1)
     ENDIF
    ELSE
     cc_end_dt_tm_fixed = cnvtdatetime(datetimeadd(rad.cc_beg_dt_tm,0.999306))
    ENDIF
   WITH nocounter
  ;end select
  IF (rad_id_to_fix > 0.0)
   IF (temp_total_urine=0)
    SET temp_24hr_urine = 0
   ELSEIF (temp_total_urine > 0)
    SET d2 = abs(datetimediff(cnvtdatetime(cc_end_dt_tm_fixed),cnvtdatetime(cc_beg_dt_tm_to_fix),3))
    IF (d2 > 0)
     SET temp_24hr_urine = round(((temp_total_urine/ (d2+ 0.01667)) * 24),0)
    ENDIF
   ENDIF
   UPDATE  FROM risk_adjustment_day rad
    SET rad.cc_end_dt_tm = cnvtdatetime(cc_end_dt_tm_fixed), rad.urine_24hr_output = temp_24hr_urine
    WHERE rad.risk_adjustment_day_id=rad_id_to_fix
     AND rad.active_ind=1
    WITH nocounter
   ;end update
  ENDIF
 ENDIF
#3099_disch_exit
#3100_event
 UPDATE  FROM risk_adjustment_event rae
  SET rae.active_ind = 0
  WHERE rae.risk_adjustment_id=ra_id
  WITH nocounter
 ;end update
 SET cnt = size(request->selist,5)
 IF (cnt > 0)
  FOR (x = 1 TO cnt)
    IF ((request->selist[x].end_effective_dt_tm < request->selist[x].beg_effective_dt_tm))
     SET request->selist[x].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    ENDIF
    SET rae_id = 0.0
    SELECT INTO "nl:"
     m = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      rae_id = cnvtreal(m)
     WITH format, nocounter
    ;end select
    IF (rae_id=0.0)
     SET failed_ind = "Y"
     SET failed_text = "Error reading from carenet sequence."
    ENDIF
    INSERT  FROM risk_adjustment_event rae
     SET rae.risk_adjustment_event_id = rae_id, rae.risk_adjustment_id = ra_id, rae
      .sentinel_event_category_cd = request->selist[x].sentinel_event_category_cd,
      rae.beg_effective_dt_tm = cnvtdatetime(request->selist[x].beg_effective_dt_tm), rae
      .end_effective_dt_tm = cnvtdatetime(request->selist[x].end_effective_dt_tm), rae
      .sentinel_event_code_cd = request->selist[x].sentinel_event_code_cd,
      rae.sentinel_event_unit = request->selist[x].sentinel_event_unit, rae.preventable_ind = request
      ->selist[x].preventable_ind, rae.consequential_ind = request->selist[x].consequential_ind,
      rae.sentinel_event_comment = request->selist[x].sentinel_event_comment, rae.active_ind = 1, rae
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      rae.active_status_prsnl_id = reqinfo->updt_id, rae.active_status_cd = reqdata->active_status_cd,
      rae.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      rae.updt_task = reqinfo->updt_task, rae.updt_applctx = reqinfo->updt_applctx, rae.updt_id =
      reqinfo->updt_id,
      rae.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed_ind = "Y"
     SET failed_text = "Unable to write new ra_event rows."
     SET x = cnt
    ENDIF
  ENDFOR
 ENDIF
#3199_event_exit
#load_tiss_items_to_arrays
 SELECT INTO "nl:"
  FROM code_value cv1
  WHERE cv1.code_set=29747
   AND cv1.active_ind=1
  ORDER BY cv1.collation_seq
  HEAD REPORT
   tiss_cnt = 0
  DETAIL
   act_flag = "Z", tiss_cnt = (tiss_cnt+ 1), act_flag = substring(1,1,cv1.definition),
   tiss_list->list[tiss_cnt].code_value = cv1.code_value, tiss_list->list[tiss_cnt].tiss_name = cv1
   .cdf_meaning, tiss_list->list[tiss_cnt].tiss_num = cv1.collation_seq,
   tiss_list->list[tiss_cnt].ce_cd = 0.0
   IF (act_flag="Y")
    tiss_list->list[tiss_cnt].acttx_ind = 1
   ELSE
    tiss_list->list[tiss_cnt].acttx_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET parserstring = fillstring(5000," ")
 SET parserstring = build("rat.tiss_cd in (")
 IF (accept_tiss_acttx_if_ind=1
  AND accept_tiss_nonacttx_if_ind=1)
  SET parserstring = build(parserstring,format(tiss_list->list[1].code_value,"############.##"))
 ELSE
  SET got1 = 0
  FOR (x = 1 TO 95)
   IF ((tiss_list->list[x].acttx_ind=1)
    AND accept_tiss_acttx_if_ind=0)
    IF (got1=1)
     SET parserstring = build(parserstring,",")
    ENDIF
    SET parserstring = build(parserstring,trim(format(tiss_list->list[x].code_value,"############.##"
       )))
    SET got1 = 1
   ENDIF
   IF ((tiss_list->list[x].acttx_ind=0)
    AND accept_tiss_nonacttx_if_ind=0)
    IF (got1=1)
     SET parserstring = build(parserstring,",")
    ENDIF
    SET parserstring = build(parserstring,trim(format(tiss_list->list[x].code_value,"############.##"
       )))
    SET got1 = 1
   ENDIF
  ENDFOR
 ENDIF
 SET parserstring = build(parserstring,")")
#load_tiss_items_to_arrays_exit
#3300_tiss_list_to_database
 IF (accept_tiss_acttx_if_ind=0
  AND accept_tiss_nonacttx_if_ind=0)
  SET parserstring = "1 = 1"
 ELSE
  EXECUTE FROM load_tiss_items_to_arrays TO load_tiss_items_to_arrays_exit
 ENDIF
 SET temp_tiss_cd = 0.0
 SET junk_id = 0.0
 SET junk_id = request->risk_adjustment_id
 UPDATE  FROM risk_adj_tiss rat
  SET rat.active_ind = 0
  WHERE rat.risk_adjustment_id=junk_id
   AND rat.tiss_beg_dt_tm <= cnvtdatetime(request->cc_end_dt_tm)
   AND rat.tiss_end_dt_tm >= cnvtdatetime(request->cc_beg_dt_tm)
   AND parser(parserstring)
  WITH nocounter
 ;end update
 SET tisscnt = size(request->tisslist,5)
 IF (tisscnt > 0)
  FOR (tissx = 1 TO tisscnt)
    SET temp_tiss_cd = meaning_code(29747,value(request->tisslist[tissx].tiss_meaning))
    IF (cnvtdatetime(request->tisslist[tissx].end_effective_dt_tm) < cnvtdatetime(request->
     icu_admit_dt_tm))
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=29747
        AND (cv.display_key=request->tisslist[tissx].tiss_meaning)
        AND cv.active_ind=1)
      DETAIL
       IF (substring(2,1,cv.definition)="Y")
        request->tisslist[tissx].end_effective_dt_tm = request->tisslist[tissx].beg_effective_dt_tm
       ELSE
        request->tisslist[tissx].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       ENDIF
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed_ind = "Y"
      SET failed_text = "Error Reading TISS from CV Table[1]"
      GO TO 9999_exit_program
     ENDIF
    ENDIF
    SET rat_id = 0.0
    SELECT INTO "nl:"
     n = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      rat_id = cnvtreal(n)
     WITH format, nocounter
    ;end select
    IF (rat_id=0.0)
     SET failed_ind = "Y"
     SET failed_text = "Error reading from carenet sequence."
    ENDIF
    INSERT  FROM risk_adj_tiss rat
     SET rat.risk_adj_tiss_id = rat_id, rat.risk_adjustment_id = request->risk_adjustment_id, rat
      .tiss_beg_dt_tm = cnvtdatetime(request->tisslist[tissx].beg_effective_dt_tm),
      rat.tiss_end_dt_tm = cnvtdatetime(request->tisslist[tissx].end_effective_dt_tm), rat.tiss_cd =
      temp_tiss_cd, rat.active_ind = 1,
      rat.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rat.active_status_prsnl_id = reqinfo
      ->updt_id, rat.active_status_cd = reqdata->active_status_cd,
      rat.updt_dt_tm = cnvtdatetime(curdate,curtime3), rat.updt_task = reqinfo->updt_task, rat
      .updt_applctx = reqinfo->updt_applctx,
      rat.updt_id = reqinfo->updt_id, rat.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed_ind = "Y"
     SET failed_text = "Unable to write new ra_tiss rows."
     SET tissx = tisscnt
     GO TO 9999_exit_program
    ENDIF
  ENDFOR
 ENDIF
#3399_tiss_list_to_database_exit
#3400_tiss_database_to_request
 SET min_tiss_dt_tm = - (1.0)
 SET max_tiss_dt_tm = - (1.0)
 SET temp_tiss_cd = 0.0
 SET request->activetx_ind = - (1)
 SET request->vent_today_ind = - (1)
 SET request->pa_line_today_ind = - (1)
 SET request->ventday1_ind = - (1)
 SET tiss_arry_sz = size(request->tisslist,5)
 IF (tiss_arry_sz > 0)
  SET request->activetx_ind = 0
  SET request->vent_today_ind = 0
  SET request->pa_line_today_ind = 0
 ENDIF
 SET stat = alterlist(sent_tiss_list->tisslist,tiss_arry_sz)
 IF (tiss_arry_sz=0)
  SET stat = alterlist(sent_tiss_list->tisslist,1)
  SET sent_tiss_list->tisslist[1].tiss_meaning = "NB6796JUNKTISS"
  SET sent_tiss_list->tisslist[1].vent_today_ind = - (1)
  SET sent_tiss_list->tisslist[1].pa_line_ind = - (1)
  SET sent_tiss_list->tisslist[1].activetx_ind = - (1)
  SET sent_tiss_list->tisslist[1].beg_effective_dt_tm = request->cc_beg_dt_tm
  SET sent_tiss_list->tisslist[1].end_effective_dt_tm = request->cc_end_dt_tm
  SET min_tiss_dt_tm = request->cc_beg_dt_tm
  SET max_tiss_dt_tm = request->cc_end_dt_tm
 ELSE
  FOR (cnt = 1 TO tiss_arry_sz)
    SET sent_tiss_list->tisslist[cnt].vent_today_ind = 0
    SET sent_tiss_list->tisslist[cnt].pa_line_ind = 0
    SET sent_tiss_list->tisslist[cnt].activetx_ind = 0
    SET sent_tiss_list->tisslist[cnt].beg_effective_dt_tm = request->tisslist[cnt].
    beg_effective_dt_tm
    SET sent_tiss_list->tisslist[cnt].end_effective_dt_tm = request->tisslist[cnt].
    end_effective_dt_tm
    IF ((sent_tiss_list->tisslist[cnt].end_effective_dt_tm=0))
     SET sent_tiss_list->tisslist[cnt].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    ENDIF
    SET sent_tiss_list->tisslist[cnt].tiss_meaning = request->tisslist[cnt].tiss_meaning
    IF (cnt=1)
     SET min_tiss_dt_tm = request->tisslist[1].beg_effective_dt_tm
     SET max_tiss_dt_tm = request->tisslist[1].end_effective_dt_tm
    ELSE
     IF (cnvtdatetime(request->tisslist[cnt].beg_effective_dt_tm) < cnvtdatetime(min_tiss_dt_tm))
      SET min_tiss_dt_tm = request->tisslist[cnt].beg_effective_dt_tm
     ENDIF
     IF (cnvtdatetime(request->tisslist[cnt].end_effective_dt_tm) > cnvtdatetime(max_tiss_dt_tm))
      SET max_tiss_dt_tm = request->tisslist[cnt].end_effective_dt_tm
     ENDIF
    ENDIF
    IF ((request->tisslist[cnt].tiss_meaning IN ("PEEP", "CONTVENT", "ASREP", "PRESSSUP", "CPAP+PRES",
    "BIPAP")))
     SET sent_tiss_list->tisslist[cnt].vent_today_ind = 1
    ENDIF
    IF ((request->tisslist[cnt].tiss_meaning="PA_LINE"))
     SET sent_tiss_list->tisslist[cnt].pa_line_ind = 1
    ENDIF
    SET temp_tiss_cd = meaning_code(29747,request->tisslist[cnt].tiss_meaning)
    SET temp_tiss_key = cnvtupper(cnvtalphanum(request->tisslist[cnt].tiss_meaning))
    SELECT INTO "nl:"
     FROM code_value cv1
     PLAN (cv1
      WHERE cv1.code_set=29747
       AND cv1.display_key=temp_tiss_key
       AND cv1.active_ind=1)
     DETAIL
      IF (substring(1,1,cv1.definition)="Y")
       request->activetx_ind = 1, sent_tiss_list->tisslist[cnt].activetx_ind = 1
      ENDIF
      IF (substring(2,1,cv1.definition)="Y")
       sent_tiss_list->tisslist[cnt].end_effective_dt_tm = sent_tiss_list->tisslist[cnt].
       beg_effective_dt_tm
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed_ind = "Y"
     SET failed_text1 = build("Error Getting TISS from Code_Value table[2].",temp_tiss_cd)
     SET failed_text = build(failed_text1,"_",request->tisslist[cnt].tiss_meaning)
    ENDIF
  ENDFOR
 ENDIF
 IF (max_tiss_dt_tm=0)
  SET max_tiss_dt_tm = cnvtdatetime("31-DEC-2100")
 ENDIF
 SET curr_indx = 0
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
    AND rad.cc_end_dt_tm >= cnvtdatetime(min_tiss_dt_tm)
    AND rad.cc_beg_dt_tm <= cnvtdatetime(max_tiss_dt_tm)
    AND rad.active_ind=1)
  ORDER BY rad.cc_beg_dt_tm
  DETAIL
   curr_indx = (curr_indx+ 1), stat = alterlist(tiss_day_list->tiss_day,curr_indx), tiss_day_list->
   tiss_day[curr_indx].cc_day = rad.cc_day,
   tiss_day_list->tiss_day[curr_indx].cc_beg_dt_tm = rad.cc_beg_dt_tm, tiss_day_list->tiss_day[
   curr_indx].cc_end_dt_tm = rad.cc_end_dt_tm, tiss_day_list->tiss_day[curr_indx].old_activetx_ind =
   rad.activetx_ind,
   tiss_day_list->tiss_day[curr_indx].old_pa_line_ind = rad.pa_line_today_ind, tiss_day_list->
   tiss_day[curr_indx].old_vent_today_ind = rad.vent_today_ind, tiss_day_list->tiss_day[curr_indx].
   activetx_ind = - (1),
   tiss_day_list->tiss_day[curr_indx].pa_line_ind = - (1), tiss_day_list->tiss_day[curr_indx].
   vent_today_ind = - (1)
  WITH nocounter
 ;end select
 SET tiss_arry_sz = size(sent_tiss_list->tisslist,5)
 SET day_arry_sz = size(tiss_day_list->tiss_day,5)
 FOR (tiss_cnt = 1 TO tiss_arry_sz)
   FOR (day_cnt = 1 TO day_arry_sz)
    IF (day_cnt=1
     AND tiss_cnt=1)
     SET request->ventday1_ind = tiss_day_list->tiss_day[1].vent_today_ind
    ENDIF
    IF ((tiss_day_list->tiss_day[day_cnt].cc_beg_dt_tm <= sent_tiss_list->tisslist[tiss_cnt].
    end_effective_dt_tm)
     AND (tiss_day_list->tiss_day[day_cnt].cc_end_dt_tm >= sent_tiss_list->tisslist[tiss_cnt].
    beg_effective_dt_tm))
     IF ((((tiss_day_list->tiss_day[day_cnt].activetx_ind < 1)) OR ((sent_tiss_list->tisslist[
     tiss_cnt].activetx_ind=1))) )
      SET tiss_day_list->tiss_day[day_cnt].activetx_ind = sent_tiss_list->tisslist[tiss_cnt].
      activetx_ind
     ENDIF
     IF ((((tiss_day_list->tiss_day[day_cnt].pa_line_ind < 1)) OR ((sent_tiss_list->tisslist[tiss_cnt
     ].pa_line_ind=1))) )
      SET tiss_day_list->tiss_day[day_cnt].pa_line_ind = sent_tiss_list->tisslist[tiss_cnt].
      pa_line_ind
     ENDIF
     IF ((((tiss_day_list->tiss_day[day_cnt].vent_today_ind < 1)) OR ((sent_tiss_list->tisslist[
     tiss_cnt].vent_today_ind=1))) )
      SET tiss_day_list->tiss_day[day_cnt].vent_today_ind = sent_tiss_list->tisslist[tiss_cnt].
      vent_today_ind
     ENDIF
    ENDIF
   ENDFOR
 ENDFOR
 FOR (cnt = 1 TO day_arry_sz)
   IF ((tiss_day_list->tiss_day[cnt].cc_day=request->cc_day))
    SET request->pa_line_today_ind = tiss_day_list->tiss_day[cnt].pa_line_ind
    SET request->activetx_ind = tiss_day_list->tiss_day[cnt].activetx_ind
    SET request->vent_today_ind = tiss_day_list->tiss_day[cnt].vent_today_ind
   ENDIF
   SET junk_id = 0.0
   SET junk_id = request->risk_adjustment_id
   UPDATE  FROM risk_adjustment_day rad
    SET rad.activetx_ind = tiss_day_list->tiss_day[cnt].activetx_ind, rad.pa_line_today_ind =
     tiss_day_list->tiss_day[cnt].pa_line_ind, rad.vent_today_ind = tiss_day_list->tiss_day[cnt].
     vent_today_ind
    WHERE rad.risk_adjustment_id=junk_id
     AND (rad.cc_day=tiss_day_list->tiss_day[cnt].cc_day)
     AND rad.active_ind=1
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed_ind = "Y"
    SET failed_text = "Error updating risk_adjustment_day row with TISS info."
   ENDIF
 ENDFOR
#3499_tiss_database_to_request_exit
#3500_get_existing_tiss_flags
 SET request->activetx_ind = - (1)
 SET request->vent_today_ind = - (1)
 SET request->pa_line_today_ind = - (1)
 SET request->ventday1_ind = - (1)
 SET request->oobventday1_ind = - (1)
 SET request->oobintubday1_ind = - (1)
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_day_id=request->risk_adjustment_day_id)
    AND (rad.risk_adjustment_id=request->risk_adjustment_id)
    AND rad.active_ind=1)
  DETAIL
   request->activetx_ind = rad.activetx_ind, request->vent_today_ind = rad.vent_today_ind, request->
   pa_line_today_ind = rad.pa_line_today_ind
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
    AND rad.cc_day=1
    AND rad.active_ind=1)
  DETAIL
   request->ventday1_ind = rad.vent_today_ind, request->oobventday1_ind = rad.vent_ind, request->
   oobintubday1_ind = rad.intubated_ind
  WITH nocounter
 ;end select
#3599_get_existing_tiss_flags_exit
#3600_check_open_ended_tiss
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adj_tiss rat,
   code_value cv
  PLAN (ra
   WHERE (ra.risk_adjustment_id=request->risk_adjustment_id)
    AND ra.active_ind=1)
   JOIN (rat
   WHERE (rat.risk_adjustment_id=request->risk_adjustment_id)
    AND rat.tiss_beg_dt_tm < cnvtdatetime(request->cc_beg_dt_tm)
    AND rat.tiss_end_dt_tm >= cnvtdatetime(request->cc_end_dt_tm)
    AND rat.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=rat.tiss_cd
    AND cv.code_set=29747
    AND cv.active_ind=1)
  HEAD REPORT
   junk = "4444"
   IF ((request->vent_today_ind=- (1)))
    request->vent_today_ind = 0
   ENDIF
   IF ((request->activetx_ind=- (1)))
    request->activetx_ind = 0
   ENDIF
   IF ((request->pa_line_today_ind=- (1)))
    request->pa_line_today_ind = 0
   ENDIF
  DETAIL
   IF (cv.display_key IN ("PEEP", "CONTVENT", "ASREP", "PRESSSUP", "CPAP+PRES",
   "BIPAP"))
    request->vent_today_ind = 1
   ENDIF
   IF (cv.display_key="PA_LINE")
    request->pa_line_today_ind = 1
   ENDIF
   IF (substring(1,1,cv.definition)="Y")
    request->activetx_ind = 1
   ENDIF
  WITH nocounter
 ;end select
#3600_check_open_ended_tiss_exit
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
 CALL echo(build("request->cc_day=",request->cc_day))
 SET check_cc_day = request->cc_day
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
   CALL echo("IN DETAIL")
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
 CALL echo(build("aps_variable->dwwbc=",aps_variable->dwwbc))
#5099_get_carry_over_exit
#5100_remove_carry_over_values
 IF (band(carry_flag,1)=1)
  SET wbc_temp = request->wbc
  SET request->wbc = - (1.0)
 ENDIF
 IF (band(carry_flag,2)=2)
  SET hct_temp = request->hematocrit
  SET request->hematocrit = - (1.0)
 ENDIF
 IF (band(carry_flag,4)=4)
  SET na_temp = request->sodium
  SET request->sodium = - (1.0)
 ENDIF
 IF (band(carry_flag,8)=8)
  SET bun_temp = request->bun
  SET request->bun = - (1.0)
 ENDIF
 IF (band(carry_flag,16)=16)
  SET cre_temp = request->creatinine
  SET request->creatinine = - (1.0)
 ENDIF
 IF (band(carry_flag,32)=32)
  SET glu_temp = request->glucose
  SET request->glucose = - (1.0)
 ENDIF
 IF (band(carry_flag,64)=64)
  SET alb_temp = request->albumin
  SET request->albumin = - (1.0)
 ENDIF
 IF (band(carry_flag,128)=128)
  SET bil_temp = request->bilirubin
  SET request->bilirubin = - (1.0)
 ENDIF
#5199_remove_carry_over_values_exit
#5200_put_carry_over_back
 IF (band(carry_flag,1)=1)
  SET request->wbc = wbc_temp
 ENDIF
 IF (band(carry_flag,2)=2)
  SET request->hematocrit = hct_temp
 ENDIF
 IF (band(carry_flag,4)=4)
  SET request->sodium = na_temp
 ENDIF
 IF (band(carry_flag,8)=8)
  SET request->bun = bun_temp
 ENDIF
 IF (band(carry_flag,16)=16)
  SET request->creatinine = cre_temp
 ENDIF
 IF (band(carry_flag,32)=32)
  SET request->glucose = glu_temp
 ENDIF
 IF (band(carry_flag,64)=64)
  SET request->albumin = alb_temp
 ENDIF
 IF (band(carry_flag,128)=128)
  SET request->bilirubin = bil_temp
 ENDIF
#5299_put_carry_over_back_exit
 SUBROUTINE save_ce_ids_from_getting_nuked(p1)
   SELECT INTO "nl:"
    FROM risk_adjustment_day rad
    WHERE (rad.risk_adjustment_day_id=request->risk_adjustment_day_id)
     AND rad.active_ind=1
    DETAIL
     IF ((rad.worst_albumin_result=request->albumin)
      AND (request->albumin_ce_id=0))
      request->albumin_ce_id = rad.albumin_ce_id
     ENDIF
     IF ((rad.worst_bilirubin_result=request->bilirubin)
      AND (request->bilirubin_ce_id=0))
      request->bilirubin_ce_id = rad.bilirubin_ce_id
     ENDIF
     IF ((rad.worst_bun_result=request->bun)
      AND (request->bun_ce_id=0))
      request->bun_ce_id = rad.bun_ce_id
     ENDIF
     IF ((rad.worst_creatinine_result=request->creatinine)
      AND (request->creatinine_ce_id=0))
      request->creatinine_ce_id = rad.creatinine_ce_id
     ENDIF
     IF ((rad.worst_glucose_result=request->glucose)
      AND (request->glucose_ce_id=0))
      request->glucose_ce_id = rad.glucose_ce_id
     ENDIF
     IF ((rad.worst_heart_rate=request->heartrate)
      AND (request->heartrate_ce_id=0))
      request->heartrate_ce_id = rad.heartrate_ce_id
     ENDIF
     IF ((rad.worst_hematocrit=request->hematocrit)
      AND (request->hematocrit_ce_id=0))
      request->hematocrit_ce_id = rad.hematocrit_ce_id
     ENDIF
     IF ((rad.worst_potassium_result=request->potassium)
      AND (request->potassium_ce_id=0))
      request->potassium_ce_id = rad.potassium_ce_id
     ENDIF
     IF ((rad.worst_resp_result=request->resp)
      AND (request->resp_ce_id=0))
      request->resp_ce_id = rad.resp_ce_id
     ENDIF
     IF ((rad.worst_sodium_result=request->sodium)
      AND (request->sodium_ce_id=0))
      request->sodium_ce_id = rad.sodium_ce_id
     ENDIF
     IF ((rad.worst_temp=request->temp)
      AND (request->temp_ce_id=0))
      request->temp_ce_id = rad.temp_ce_id
     ENDIF
     IF ((rad.worst_wbc_result=request->wbc)
      AND (request->wbc_ce_id=0))
      request->wbc_ce_id = rad.wbc_ce_id
     ENDIF
     IF ((rad.worst_gcs_eye_score=request->eyes)
      AND (rad.worst_gcs_motor_score=request->motor)
      AND (rad.worst_gcs_verbal_score=request->verbal))
      gcs_eyes_ce_id = rad.eyes_ce_id, gcs_motor_ce_id = rad.motor_ce_id, gcs_verbal_ce_id = rad
      .verbal_ce_id
     ENDIF
     IF ((rad.meds_ind=request->meds_ind))
      gcs_meds_ce_id = rad.meds_ce_id
     ENDIF
     IF ((rad.vent_ind=request->vent_ind))
      vent_ce_id = rad.vent_ce_id
     ENDIF
     IF ((rad.intubated_ind=request->intubated_ind))
      abg_intubated_ce_id = rad.intubated_ce_id
     ENDIF
     IF ((rad.worst_ph_result=request->ph)
      AND (request->ph_ce_id=0)
      AND (rad.worst_fio2_result=request->fio2)
      AND (request->fio2_ce_id=0)
      AND (rad.worst_pao2_result=request->pao2)
      AND (request->pao2_ce_id=0)
      AND (rad.worst_pco2_result=request->pco2)
      AND (request->pco2_ce_id=0))
      request->ph_ce_id = rad.ph_ce_id, request->fio2_ce_id = rad.fio2_ce_id, request->pao2_ce_id =
      rad.pao2_ce_id,
      request->pco2_ce_id = rad.pco2_ce_id
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
#9999_exit_program
 IF (failed_ind="Y")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_UPD_APACHE_ADM_DISCH"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = failed_text
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
