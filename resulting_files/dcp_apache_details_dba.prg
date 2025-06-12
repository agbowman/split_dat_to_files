CREATE PROGRAM dcp_apache_details:dba
 RECORD reply(
   1 bedlist[1]
     2 bed_occupied_ind = i2
     2 non_predicted_pt_ind = i2
     2 risk_adjustment_id = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 person_id = f8
     2 encntr_id = f8
     2 name_full_formatted = vc
     2 attend_doc = vc
     2 attend_doc_id = f8
     2 reg_dt_tm = dq8
     2 birth_dt_tm = dq8
     2 sex_cd = f8
     2 age = vc
     2 age_in_years = i2
     2 med_service_cd = f8
     2 med_service_disp = vc
     2 admit_category = vc
     2 elective_surgery_ind = i2
     2 admit_diagnosis = vc
     2 icu_admit_date = dq8
     2 copdlevel = vc
     2 chronic_dialysis_ind = i2
     2 chronic_health = vc
     2 room_bed_disp = vc
     2 room_bed_init_disp = vc
     2 attend_doc_init = vc
     2 apache_three = i4
     2 apache_dt_tm = dq8
     2 apache_three_day_one = i4
     2 aps_day_one = i4
     2 aps_current = i4
     2 phys_res_pts = i4
     2 icu_risk_of_death = i4
     2 hosp_risk_of_death = i4
     2 risk_of_pac = i4
     2 active_treatment_ind = i2
     2 last_active_treatment_ind = i2
     2 discharge_alive = i4
     2 tomorrow_discharge_alive = i4
     2 today_risk_active_tx = i4
     2 tomorrow_risk_active_tx = i4
     2 actual_hosp_los = f8
     2 predicted_hosp_los = f8
     2 actual_icu_los = f8
     2 predicted_icu_los = f8
     2 predicted_vent_days = f8
     2 today_tiss_predict = f8
     2 raw_tiss = f8
     2 tomorrow_tiss_predict = f8
     2 day_5_icu_los = f8
     2 treatments_events[*]
       3 treatment_event_flag = c1
       3 treatment_event_disp = vc
     2 error_code = f8
     2 error_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 DECLARE meaning_code(p1,p2) = f8
 DECLARE apache_age(birth_dt_tm,admit_dt_tm) = i2
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_read TO 2999_read_exit
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
#1000_initialize
 SET reply->status_data.status = "F"
 DECLARE f_text = vc
 SET reply->bedlist[1].bed_occupied_ind = 0
 SET reply->bedlist[1].non_predicted_pt_ind = 0
 SET reply->bedlist[1].apache_three = - (1)
 SET reply->bedlist[1].apache_dt_tm = - (1)
 SET reply->bedlist[1].apache_three_day_one = - (1)
 SET reply->bedlist[1].aps_day_one = - (1)
 SET reply->bedlist[1].aps_current = - (1)
 SET reply->bedlist[1].phys_res_pts = - (1)
 SET reply->bedlist[1].icu_risk_of_death = - (1)
 SET reply->bedlist[1].hosp_risk_of_death = - (1)
 SET reply->bedlist[1].risk_of_pac = - (1)
 SET reply->bedlist[1].active_treatment_ind = - (1)
 SET reply->bedlist[1].last_active_treatment_ind = 0
 SET reply->bedlist[1].discharge_alive = - (1)
 SET reply->bedlist[1].tomorrow_discharge_alive = - (1)
 SET reply->bedlist[1].today_risk_active_tx = - (1)
 SET reply->bedlist[1].tomorrow_risk_active_tx = - (1)
 SET reply->bedlist[1].actual_hosp_los = - (1)
 SET reply->bedlist[1].predicted_hosp_los = - (1)
 SET reply->bedlist[1].actual_icu_los = - (1)
 SET reply->bedlist[1].predicted_icu_los = - (1)
 SET reply->bedlist[1].predicted_vent_days = - (1)
 SET reply->bedlist[1].today_tiss_predict = - (1)
 SET reply->bedlist[1].raw_tiss = - (1)
 SET reply->bedlist[1].tomorrow_tiss_predict = - (1)
 SET reply->bedlist[1].day_5_icu_los = - (1)
 SET reply->bedlist[1].chronic_health = fillstring(300," ")
 SET ambulatory_type_cd = meaning_code(222,"AMBULATORY")
 SET census_type_cd = meaning_code(339,"CENSUS")
 SET nurse_unit_type_cd = meaning_code(222,"NURSEUNIT")
 SET room_type_cd = meaning_code(222,"ROOM")
 SET attend_doc_cd = meaning_code(333,"ATTENDDOC")
 SET day_str = "   "
#1999_initialize_exit
#2000_read
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e,
   person p
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   agex = "            "
  DETAIL
   reply->bedlist[1].bed_occupied_ind = 1, reply->bedlist[1].encntr_id = e.encntr_id, reply->bedlist[
   1].person_id = p.person_id,
   reply->bedlist[1].name_full_formatted = trim(p.name_full_formatted,3), reply->bedlist[1].
   birth_dt_tm = p.birth_dt_tm, reply->bedlist[1].age = cnvtage(p.birth_dt_tm,e.reg_dt_tm,0),
   reply->bedlist[1].age_in_years = apache_age(p.birth_dt_tm,e.reg_dt_tm)
   IF ((reply->bedlist[1].age_in_years < 16))
    reply->bedlist[1].non_predicted_pt_ind = 1, f_text =
    "Patient under 16. Unable to calculate predictions. ", reply->bedlist[1].error_string = f_text,
    reply->bedlist[1].error_code = - (23103)
   ENDIF
   reply->bedlist[1].sex_cd = p.sex_cd, reply->bedlist[1].reg_dt_tm = e.reg_dt_tm
   IF (e.disch_dt_tm=0)
    reply->bedlist[1].actual_hosp_los = datetimediff(cnvtdatetime(curdate,curtime),e.reg_dt_tm,1)
   ELSE
    reply->bedlist[1].actual_hosp_los = datetimediff(e.disch_dt_tm,e.reg_dt_tm,1)
   ENDIF
   reply->bedlist[1].room_bed_disp = concat(trim(uar_get_code_display(e.loc_room_cd)),trim(
     uar_get_code_display(e.loc_bed_cd))), reply->bedlist[1].room_bed_init_disp = concat(trim(
     uar_get_code_display(e.loc_room_cd)),trim(uar_get_code_display(e.loc_bed_cd)),":",substring(1,1,
     p.name_first_key),trim(substring(1,1,p.name_middle_key)),
    substring(1,1,p.name_last_key)), reply->bedlist[1].loc_room_cd = e.loc_room_cd,
   reply->bedlist[1].loc_bed_cd = e.loc_bed_cd
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT
   IF ((request->icu_admit_dt_tm > cnvtdatetime((curdate - 999),curtime)))
    PLAN (ra
     WHERE (ra.person_id=request->person_id)
      AND (ra.encntr_id=request->encntr_id)
      AND ra.icu_admit_dt_tm=cnvtdatetime(request->icu_admit_dt_tm)
      AND ra.active_ind=1)
   ELSE
    PLAN (ra
     WHERE (ra.person_id=request->person_id)
      AND (ra.encntr_id=request->encntr_id)
      AND ra.icu_admit_dt_tm=cnvtdatetime(request->icu_admit_dt_tm)
      AND ra.active_ind=1)
   ENDIF
   INTO "nl:"
   FROM risk_adjustment ra
   HEAD REPORT
    dt_slash = " "
   DETAIL
    dt_slash = " ", reply->bedlist[1].risk_adjustment_id = ra.risk_adjustment_id, reply->bedlist[1].
    elective_surgery_ind = ra.electivesurgery_ind,
    reply->bedlist[1].admit_diagnosis = ra.admit_diagnosis, reply->bedlist[1].med_service_cd = ra
    .med_service_cd
    IF (ra.therapy_level=1)
     reply->bedlist[1].admit_category = "ACTIVE"
    ELSEIF (ra.therapy_level=2)
     reply->bedlist[1].admit_category = "LR-MONITOR"
    ELSEIF (ra.therapy_level=3)
     reply->bedlist[1].admit_category = "HR-MONITOR"
    ELSEIF (ra.therapy_level=4)
     reply->bedlist[1].admit_category = "NP-MONITOR"
    ELSEIF (ra.therapy_level=5)
     reply->bedlist[1].admit_category = "NP-ACTIVE"
    ENDIF
    reply->bedlist[1].icu_admit_date = ra.icu_admit_dt_tm
    IF (ra.icu_disch_dt_tm=cnvtdatetime("31-DEC-2100"))
     reply->bedlist[1].actual_icu_los = datetimediff(cnvtdatetime(curdate,curtime),ra.icu_admit_dt_tm,
      1)
    ELSE
     reply->bedlist[1].actual_icu_los = datetimediff(ra.icu_disch_dt_tm,ra.icu_admit_dt_tm,1)
    ENDIF
    IF (ra.copd_ind=1)
     reply->bedlist[1].copdlevel = cnvtstring(ra.copd_flag)
    ELSE
     reply->bedlist[1].copdlevel = "-1"
    ENDIF
    reply->bedlist[1].chronic_dialysis_ind = ra.dialysis_ind, reply->bedlist[1].attend_doc_id = ra
    .adm_doc_id
    IF (ra.aids_ind=1)
     reply->bedlist[1].chronic_health = trim(concat(reply->bedlist[1].chronic_health,dt_slash,
       "OTHER IMMUNE")), dt_slash = "/"
    ENDIF
    IF (ra.hepaticfailure_ind=1)
     reply->bedlist[1].chronic_health = trim(concat(reply->bedlist[1].chronic_health,dt_slash,
       "HEPATIC FAILURE")), dt_slash = "/"
    ENDIF
    IF (ra.lymphoma_ind=1)
     reply->bedlist[1].chronic_health = trim(concat(reply->bedlist[1].chronic_health,dt_slash,
       "LYMPHOMA")), dt_slash = "/"
    ENDIF
    IF (ra.metastaticcancer_ind=1)
     reply->bedlist[1].chronic_health = trim(concat(reply->bedlist[1].chronic_health,dt_slash,
       "METASTATIC CANCER")), dt_slash = "/"
    ENDIF
    IF (ra.leukemia_ind=1)
     reply->bedlist[1].chronic_health = trim(concat(reply->bedlist[1].chronic_health,dt_slash,
       "LEUKEMIA\MULTIPLE MYELOMA")), dt_slash = "/"
    ENDIF
    IF (ra.immunosuppression_ind=1)
     reply->bedlist[1].chronic_health = trim(concat(reply->bedlist[1].chronic_health,dt_slash,
       "IMMUNOSUPPRESSION")), dt_slash = "/"
    ENDIF
    IF (ra.cirrhosis_ind=1)
     reply->bedlist[1].chronic_health = trim(concat(reply->bedlist[1].chronic_health,dt_slash,
       "CIRRHOSIS")), dt_slash = "/"
    ENDIF
    IF (ra.copd_ind=1)
     IF (ra.copd_flag=2)
      reply->bedlist[1].chronic_health = trim(concat(reply->bedlist[1].chronic_health,dt_slash,
        "SEV_COPD")), dt_slash = "/"
     ELSEIF (ra.copd_flag=1)
      reply->bedlist[1].chronic_health = trim(concat(reply->bedlist[1].chronic_health,dt_slash,
        "MOD_COPD")), dt_slash = "/"
     ELSE
      reply->bedlist[1].chronic_health = trim(concat(reply->bedlist[1].chronic_health,dt_slash,
        "NOLIM_COPD")), dt_slash = "/"
     ENDIF
    ENDIF
    IF (ra.diabetes_ind=1)
     reply->bedlist[1].chronic_health = trim(concat(reply->bedlist[1].chronic_health,dt_slash,
       "DIABETES")), dt_slash = "/"
    ENDIF
    IF (ra.chronic_health_none_ind=1)
     reply->bedlist[1].chronic_health = "NONE"
    ENDIF
    IF (ra.chronic_health_unavail_ind=1)
     reply->bedlist[1].chronic_health = "UNAVAILABLE"
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM risk_adjustment_day rad,
    risk_adjustment_outcomes rao
   PLAN (rad
    WHERE (rad.risk_adjustment_id=reply->bedlist[1].risk_adjustment_id)
     AND rad.risk_adjustment_id > 0
     AND rad.active_ind=1)
    JOIN (rao
    WHERE rao.risk_adjustment_day_id=outerjoin(rad.risk_adjustment_day_id)
     AND rao.active_ind=outerjoin(1))
   ORDER BY rad.cc_day DESC
   HEAD REPORT
    pt_loaded = "N", details_loaded = "N", hold_cc_day = 0,
    dt_slash = " ", hosp_los_loaded = "N", icu_los_loaded = "N",
    last_act_tx_loaded = "N"
   HEAD rad.cc_day
    IF (pt_loaded="N")
     IF (rad.outcome_status >= 0)
      pt_loaded = "Y", hold_cc_day = rad.cc_day
     ENDIF
     reply->bedlist[1].apache_dt_tm = rad.valid_from_dt_tm, reply->bedlist[1].aps_day_one = rad
     .aps_day1
     IF (rad.cc_end_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND rad.cc_beg_dt_tm < cnvtdatetime(curdate,curtime3))
      reply->bedlist[1].active_treatment_ind = rad.activetx_ind, reply->bedlist[1].
      last_active_treatment_ind = rad.activetx_ind, last_act_tx_loaded = "Y"
     ENDIF
     IF ((reply->bedlist[1].aps_current=- (1)))
      reply->bedlist[1].aps_current = rad.aps_score
      IF (rad.aps_score >= 0
       AND rad.phys_res_pts >= 0)
       reply->bedlist[1].apache_three = (rad.phys_res_pts+ rad.aps_score)
      ELSE
       reply->bedlist[1].apache_three = - (1)
      ENDIF
     ENDIF
     reply->bedlist[1].phys_res_pts = rad.phys_res_pts
     IF (rad.aps_day1 >= 0
      AND rad.phys_res_pts >= 0)
      reply->bedlist[1].apache_three_day_one = (rad.aps_day1+ rad.phys_res_pts)
     ELSE
      reply->bedlist[1].apache_three_day_one = - (1)
     ENDIF
     IF (rad.outcome_status >= 0)
      IF (last_act_tx_loaded="N")
       IF (rad.cc_day > 1)
        reply->bedlist[1].last_active_treatment_ind = 0, last_act_tx_loaded = "Y"
       ELSE
        reply->bedlist[1].last_active_treatment_ind = rad.activetx_ind, last_act_tx_loaded = "Y"
       ENDIF
      ENDIF
     ELSE
      reply->bedlist[1].error_code = rad.outcome_status, day_str = cnvtstring(rad.cc_day,3,0,r)
      IF (day_str="00*")
       day_str = cnvtstring(rad.cc_day,2,0,r)
       IF (day_str="0*")
        day_str = cnvtstring(rad.cc_day,1,0,r)
       ENDIF
      ENDIF
      CASE (rad.outcome_status)
       OF - (22001):
        f_text = concat("Valid Temperature required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22002):
        f_text = concat("Valid Heart Rate required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22003):
        f_text = concat("Valid Resp Rate required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22004):
        f_text = concat("Valid Mean BP required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22005):
        f_text = concat("Valid Sodium required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22006):
        f_text = concat("Valid Glucose required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22007):
        f_text = concat("Valid Albumin required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22008):
        f_text = concat("Valid Creatinine required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22009):
        f_text = concat("Valid BUN required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22010):
        f_text = concat("Valid WBC required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22011):
        f_text = concat("Valid Urine Output required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22012):
        f_text = concat("Valid Bilirubin required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22013):
        f_text = concat("Valid PCO2 & pH required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22014):
        f_text = concat("Valid Hematocrit required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22015):
        f_text = concat("Valid paO2 & pcO2 required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22017):
        f_text = concat("Valid values for meds, eyes, motor & verbal required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22018):
        f_text = concat("Valid Heart Rate, Resp Rate & Mean BP required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (22019):
        f_text = concat("Minimum of 4 valid lab values required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23009):
        f_text = concat("Valid ICU Day required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23010):
        f_text = concat("Valid APS for today required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23011):
        f_text = concat("Valid APS for day one required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23013):
        f_text = concat("Valid DOB required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23014):
        f_text = concat("Valid Hosp Admit Date required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23015):
        f_text = concat("Valid ICU Admit Date required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23016):
        f_text = concat("Valid Admission Diagnosis required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23017):
        f_text = concat("Valid Admission Source required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23018):
        f_text = concat("Valid gender required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23019):
        f_text = concat("Valid Meds Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23020):
        f_text = concat("Valid Eye value (GCS) required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23021):
        f_text = concat("Valid Motor value (GCS) required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23022):
        f_text = concat("Valid Verbal value (GCS) required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23023):
        f_text = concat("Valid Thrombolytics Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23024):
        f_text = concat("Valid Other Immune Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23025):
        f_text = concat("Valid Hepatic Failure Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23026):
        f_text = concat("Valid Lymphoma Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23027):
        f_text = concat("Valid Metastatic Cancer Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23028):
        f_text = concat("Valid Leukemia Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23029):
        f_text = concat("Valid Immunosuppression Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23030):
        f_text = concat("Valid Cirrhosis Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23031):
        f_text = concat("Valid Elective Surgery Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23032):
        f_text = concat("Valid Active Treatment Indicator required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23033):
        f_text = concat("Valid chronic health information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23034):
        f_text = concat("Valid readmission information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23035):
        f_text = concat("Valid internal mammory artery information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23036):
        f_text = "Unable to calculate predictions, Hosp admission date is too early.",reply->bedlist[
        1].non_predicted_pt_ind = 1
       OF - (23037):
        f_text = concat("Valid Eye value (GCS) required for Day 1(Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23038):
        f_text = concat("Valid Motor value (GCS) required for Day 1(Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23039):
        f_text = concat("Valid Verbal value (GCS) required for Day 1(Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23040):
        f_text = "Unable to calculate predictions, ICU admission date is too early.",reply->bedlist[1
        ].non_predicted_pt_ind = 1
       OF - (23100):
        f_text = "Nonpredictive diagnosis, unable to calculate predictions.",reply->bedlist[1].
        non_predicted_pt_ind = 1
       OF - (23103):
        f_text = "Nonpredictive patient age (<16 years), unable to calculate predictions.",reply->
        bedlist[1].non_predicted_pt_ind = 1
       OF - (23110):
        f_text = "Invalid Age, unable to calculate predictions."
       OF - (23115):
        f_text = concat("Valid Creatinine required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23116):
        f_text = concat("Valid Eject FX information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23117):
        f_text = "Nonpredictive admission source (ICU), unable to calculate predictions.",reply->
        bedlist[1].non_predicted_pt_ind = 1
       OF - (23118):
        f_text = concat("Valid Dicharge Location required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23119):
        f_text = concat("Valid Visit Number information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       OF - (23120):
        f_text = concat("Valid AMI Location information required (Day ",trim(day_str),
         "). Unable to calculate predictions.")
       ELSE
        f_text = concat("An unrecognized error occurred - error number ",cnvtstring(reply->bedlist[1]
          .error_code)," (Day ",trim(day_str),"). Unable to calculate predictions.")
      ENDCASE
      reply->bedlist[1].error_string = f_text
     ENDIF
    ENDIF
   DETAIL
    IF (details_loaded="N")
     CASE (rao.equation_name)
      OF "TISS_TMR":
       reply->bedlist[1].tomorrow_tiss_predict = round(rao.outcome_value,0)
      OF "VENT_DAYS":
       IF (rad.cc_day=1)
        reply->bedlist[1].predicted_vent_days = round(rao.outcome_value,2)
       ENDIF
      OF "ICU_DEATH":
       reply->bedlist[1].icu_risk_of_death = round((rao.outcome_value * 100),0),
       IF (rad.cc_day=1
        AND (reply->bedlist[1].admit_diagnosis IN ("CARDARREST", "POISON", "NTCOMA", "CARDSHOCK",
       "PAPMUSCLE",
       "S-VALVAM", "S-VALVAO", "S-VALVMI", "S-VALVMR", "S-VALVPULM",
       "SVALVTRI", "S-CABGAOV", "S-CABGMIV", "S-CABGMVR", "S-CABGVALV",
       "S-LIVTRAN", "S-AAANEUUP", "S-TAANEURU", "S-CABG", "S-CABGREDO",
       "S-CABGROTH", "S-CABGWOTH")))
        reply->bedlist[1].today_risk_active_tx = 100
       ENDIF
      OF "HSP_DEATH":
       reply->bedlist[1].hosp_risk_of_death = round((rao.outcome_value * 100),0)
      OF "SWAN_GANZ":
       reply->bedlist[1].risk_of_pac = round((rao.outcome_value * 100),0)
      OF "DSCHG_ALIVE_TMR":
       reply->bedlist[1].tomorrow_discharge_alive = round((rao.outcome_value * 100),0)
      OF "NTL_ACT_DAY1":
       IF (rad.activetx_ind=1
        AND rad.cc_day=1)
        reply->bedlist[1].today_risk_active_tx = round((rao.outcome_value * 100),0)
       ENDIF
      OF "ACT_ICU_EVER":
       IF (rad.activetx_ind=0
        AND rad.cc_day=1)
        reply->bedlist[1].today_risk_active_tx = round((rao.outcome_value * 100),0)
       ENDIF
      OF "1ST_TISS":
       IF (rad.cc_day=1)
        reply->bedlist[1].today_tiss_predict = round(rao.outcome_value,0)
       ENDIF
      OF "ACT_TMR":
       reply->bedlist[1].tomorrow_risk_active_tx = round((rao.outcome_value * 100),0)
     ENDCASE
    ELSE
     IF (rao.equation_name="ACT_TMR"
      AND hold_cc_day > 1
      AND (rad.cc_day=(hold_cc_day - 1))
      AND details_loaded="Y"
      AND rad.outcome_status >= 0)
      reply->bedlist[1].today_risk_active_tx = round((rao.outcome_value * 100),0)
     ELSEIF (rao.equation_name="DSCHG_ALIVE_TMR"
      AND hold_cc_day > 1
      AND (rad.cc_day=(hold_cc_day - 1))
      AND details_loaded="Y"
      AND rad.outcome_status >= 0)
      reply->bedlist[1].discharge_alive = round((rao.outcome_value * 100),0)
     ELSEIF (rao.equation_name="TISS_TMR"
      AND hold_cc_day > 1
      AND (rad.cc_day=(hold_cc_day - 1))
      AND details_loaded="Y"
      AND rad.outcome_status >= 0)
      reply->bedlist[1].today_tiss_predict = round(rao.outcome_value,0)
     ENDIF
    ENDIF
    IF (rad.cc_day=5
     AND rad.outcome_status >= 0
     AND rao.equation_name="NTL_ICU_LOS")
     reply->bedlist[1].day_5_icu_los = round(rao.outcome_value,2)
    ENDIF
    IF (rad.cc_day=1
     AND rad.outcome_status >= 0)
     IF (rao.equation_name="HSP_LOS"
      AND hosp_los_loaded="N")
      reply->bedlist[1].predicted_hosp_los = round(rao.outcome_value,2)
     ELSEIF (rao.equation_name="ICU_LOS"
      AND icu_los_loaded="N")
      reply->bedlist[1].predicted_icu_los = round(rao.outcome_value,2)
     ELSEIF (rao.equation_name="VENT_DAYS")
      reply->bedlist[1].predicted_vent_days = round(rao.outcome_value,2)
     ENDIF
    ENDIF
   FOOT  rad.cc_day
    IF (rad.outcome_status >= 0)
     details_loaded = "Y"
    ENDIF
   WITH nocounter
  ;end select
  IF ((reply->bedlist[1].error_code=- (1)))
   SELECT INTO "nl:"
    FROM risk_adjustment_day rad
    PLAN (rad
     WHERE (rad.risk_adjustment_id=reply->bedlist[1].risk_adjustment_id)
      AND rad.active_ind=1)
    ORDER BY rad.cc_day
    HEAD REPORT
     missed_day_found = "N", compare_nbr = 1, missed_day = 0
    DETAIL
     IF (missed_day_found="N")
      IF (rad.cc_day=compare_nbr)
       compare_nbr = (compare_nbr+ 1)
      ELSE
       missed_day = compare_nbr, missed_day_found = "Y", day_str = cnvtstring(compare_nbr,3,0,r)
      ENDIF
     ENDIF
    FOOT REPORT
     IF (missed_day > 0
      AND missed_day_found="Y")
      IF (day_str="00*")
       day_str = cnvtstring(missed_day,2,0,r)
       IF (day_str="0*")
        day_str = cnvtstring(missed_day,1,0,r)
       ENDIF
      ENDIF
      reply->bedlist[1].error_string = concat("Missing data for day ",day_str,
       ". Unable to calculate predictions.")
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM risk_adjustment_event rae
   PLAN (rae
    WHERE (rae.risk_adjustment_id=reply->bedlist[1].risk_adjustment_id)
     AND rae.active_ind=1)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->bedlist[1].treatments_events,cnt), reply->bedlist[1].
    treatments_events[cnt].treatment_event_flag = "E",
    reply->bedlist[1].treatments_events[cnt].treatment_event_disp = trim(uar_get_code_display(rae
      .sentinel_event_code_cd))
   WITH nocounter
  ;end select
  IF ((reply->bedlist[1].attend_doc_id > 0))
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE (p.person_id=reply->bedlist[1].attend_doc_id))
    DETAIL
     reply->bedlist[1].attend_doc = p.name_full_formatted, reply->bedlist[1].attend_doc_init = concat
     (trim(substring(1,1,p.name_first_key)),trim(substring(1,1,p.name_last_key)))
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    epr.encntr_id
    FROM encntr_prsnl_reltn epr,
     prsnl p
    PLAN (epr
     WHERE (epr.encntr_id=reply->bedlist[1].encntr_id)
      AND epr.encntr_prsnl_r_cd=attend_doc_cd
      AND epr.active_ind=1
      AND epr.expiration_ind=0)
     JOIN (p
     WHERE p.person_id=epr.prsnl_person_id)
    DETAIL
     reply->bedlist[1].attend_doc_id = p.person_id, reply->bedlist[1].attend_doc = p
     .name_full_formatted, reply->bedlist[1].attend_doc_init = concat(trim(substring(1,1,p
        .name_first_key)),trim(substring(1,1,p.name_last_key)))
    WITH nocounter
   ;end select
  ENDIF
  IF ((reply->bedlist[1].bed_occupied_ind=1))
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#2999_read_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
