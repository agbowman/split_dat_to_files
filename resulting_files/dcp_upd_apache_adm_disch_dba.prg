CREATE PROGRAM dcp_upd_apache_adm_disch:dba
 RECORD reply(
   1 risk_adjustment_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 day_cnt = i2
   1 cc_day[*]
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 RECORD temp2(
   1 idlist[*]
     2 rad_id = f8
 )
 RECORD temp3(
   1 risk_adjustment_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 icu_admit_dt_tm = dq8
   1 icu_disch_dt_tm = dq8
   1 admit_source = vc
   1 med_service_cd = f8
   1 admit_icu_cd = f8
   1 admitsource_flag = i2
   1 hrs_at_source = i4
   1 body_system = vc
   1 admitdiagnosis = vc
   1 xfer_within_48hr_ind = i2
   1 electivesurgery_ind = i2
   1 readmit_ind = i2
   1 readmit_within_24hr_ind = i2
   1 age = i4
   1 hosp_admit_dt_tm = dq8
   1 gender = i4
   1 teach_type_flag = i2
   1 region_flag = i2
   1 bedcount = i4
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
   1 ami_location = vc
   1 ptca_device = vc
   1 thrombolytics_ind = i2
   1 diedinhospital_ind = i2
   1 nbr_grafts_performed = i4
   1 ima_ind = i2
   1 midur_ind = i2
   1 sv_graft_ind = i2
   1 mi_within_6mo_ind = i2
   1 cc_during_stay_ind = i2
   1 ventday1_ind = i2
   1 oobventday1_ind = i2
   1 oobintubday1_ind = i2
   1 var03hspxlos = f8
   1 ejectfx = f8
   1 diedinicu_ind = i2
   1 adm_doc_id = f8
   1 disease_category_cd = f8
   1 therapy_level = i4
   1 discharge_location_cd = f8
   1 visit_number = i2
 )
 RECORD temp4(
   1 dlist[*]
     2 risk_adjustment_id = f8
     2 risk_adjustment_day_id = f8
     2 cc_day = i4
     2 cc_beg_dt_tm = dq8
     2 cc_end_dt_tm = dq8
     2 intubated_ind = i2
     2 intubated_ce_id = f8
     2 vent_ind = i2
     2 eyes = i4
     2 eyes_ce_id = f8
     2 motor = i4
     2 motor_ce_id = f8
     2 verbal = i4
     2 verbal_ce_id = f8
     2 meds_ind = i2
     2 meds_ce_id = f8
     2 urine = f8
     2 urine_24hr = f8
     2 wbc = f8
     2 wbc_ce_id = f8
     2 temp = f8
     2 temp_ce_id = f8
     2 resp = f8
     2 resp_ce_id = f8
     2 sodium = f8
     2 sodium_ce_id = f8
     2 heartrate = f8
     2 heartrate_ce_id = f8
     2 meanbp = f8
     2 ph = f8
     2 ph_ce_id = f8
     2 hematocrit = f8
     2 hematocrit_ce_id = f8
     2 creatinine = f8
     2 creatinine_ce_id = f8
     2 albumin = f8
     2 albumin_ce_id = f8
     2 pao2 = f8
     2 pao2_ce_id = f8
     2 pco2 = f8
     2 pco2_ce_id = f8
     2 bun = f8
     2 bun_ce_id = f8
     2 glucose = f8
     2 glucose_ce_id = f8
     2 bilirubin = f8
     2 bilirubin_ce_id = f8
     2 potassium = f8
     2 potassium_ce_id = f8
     2 fio2 = f8
     2 fio2_ce_id = f8
     2 aps_score = i4
     2 aps_day1 = i4
     2 aps_yesterday = i4
     2 activetx_ind = i2
     2 vent_today_ind = i2
     2 pa_line_today_ind = i2
     2 outcome_status = i4
     2 apache_iii_score = i4
     2 phys_res_pts = i4
     2 ocnt = i4
     2 olist[*]
       3 equation_name = vc
       3 outcome = f8
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
 DECLARE status = i4
 DECLARE aps_status = i4
 DECLARE outcome_status = i4
 DECLARE meaning_code(p1,p2) = f8
 DECLARE filtered_fio2 = vc
 DECLARE check_for_string(p1,p2) = vc
 SET day1meds = - (1)
 SET day1verbal = - (1)
 SET day1motor = - (1)
 SET day1eyes = - (1)
 SET day1pao2 = - (1.0)
 SET day1fio2 = - (1.0)
 EXECUTE apachertl
 DECLARE stillneed2find = i2
 DECLARE check_cc_day = i2
 SET failed_ind = "Y"
 SET failed_text = fillstring(100," ")
 SET failed_text = "Initial call to DCP_UPD_APACHE_ADM_DISCH"
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 IF ((request->risk_adjustment_id=0.0))
  SET failed_ind = "Y"
  SET failed_text = "Risk_adjustment_id not populated in request, no updates made."
  GO TO 9999_exit_program
 ENDIF
 IF ((request->admit_time_chg_ind=1)
  AND (request->new_icu_admit_dt_tm=cnvtdatetime(old_adm_dt_tm)))
  SET failed_ind = "Y"
  SET failed_text = "Old & New admit dt/tm are equal, no updates made."
  GO TO 9999_exit_program
 ENDIF
 IF ((request->disch_time_chg_ind=1)
  AND (request->new_icu_disch_dt_tm=cnvtdatetime(old_disch_dt_tm)))
  SET failed_ind = "N"
  SET failed_text = "Old & New discharge dt/tm are equal, no updates made."
  GO TO 9999_exit_program
 ENDIF
 IF (ra_found="N")
  SET failed_ind = "Y"
  SET failed_text = build(request->risk_adjustment_id,
   "No active risk_adjustment row found for risk_adjustment_id in request.")
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM 1500_oth_cc_days TO 1599_oth_cc_days_exit
 IF ((request->admit_time_chg_ind=1))
  EXECUTE FROM 2000_adm TO 2099_adm_exit
 ELSEIF ((request->disch_time_chg_ind=1))
  IF ((request->new_icu_disch_dt_tm < cnvtdatetime(temp3->icu_admit_dt_tm)))
   SET failed_ind = "Y"
   SET failed_text = "New icu disch dt/tm < icu admit dt/tm, no updates made."
   GO TO 9999_exit_program
  ENDIF
  EXECUTE FROM 3900_determine_dc_day TO 3999_determine_dc_day_exit
  IF (old_dc_cc_day > 0
   AND new_dc_cc_day > 0)
   EXECUTE FROM 4000_disch TO 4099_disch_exit
  ELSE
   SET failed_ind = "Y"
   SET failed_text = "Invalid discharge dt/tm, no updates made."
   GO TO 9999_exit_program
  ENDIF
 ENDIF
 SET failed_ind = "N"
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
 SET success_flag = " "
 DECLARE fail_string = vc
 DECLARE v_equation_name = vc
 DECLARE act_icu_ever = f8
 DECLARE therapy_level = i2
 SET act_icu_ever = - (1)
 SET therapy_level = - (1)
 SET ra_found = "N"
 SET d1 = 0.0
 SET d2 = 0.0
 SET d3 = 0.0
 SET h1 = 0
 SET h2 = 0
 SET m1 = 0
 SET m2 = 0
 SET org_id = 0.0
 SET encntr_id = 0.0
 SET old_adm_dt_tm = cnvtdatetime(curdate,curtime3)
 SET old_disch_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reg_dt_tm = cnvtdatetime((curdate+ 10),curtime3)
 SET disch_dt_tm = cnvtdatetime((curdate+ 10),curtime3)
 SET beg_day1_dt_tm = cnvtdatetime((curdate+ 10),curtime3)
 SET end_day1_dt_tm = cnvtdatetime((curdate+ 10),curtime3)
 SET accept_worst_lab_ind = 1
 SET accept_worst_vitals_ind = 1
 SET accept_urine_output_ind = 1
 SET cc_day_start_time = 0700
 SET same_end_day1 = "N"
 SET inerror_cd = meaning_code(8,"INERROR")
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  PLAN (ra
   WHERE (ra.risk_adjustment_id=request->risk_adjustment_id)
    AND ra.risk_adjustment_id > 0.0
    AND ra.active_ind=1)
  DETAIL
   temp3->risk_adjustment_id = ra.risk_adjustment_id, temp3->person_id = ra.person_id, temp3->
   encntr_id = ra.encntr_id,
   temp3->icu_admit_dt_tm = cnvtdatetime(ra.icu_admit_dt_tm), temp3->icu_disch_dt_tm = cnvtdatetime(
    ra.icu_disch_dt_tm), temp3->admit_source = ra.admit_source,
   temp3->discharge_location_cd = ra.discharge_location_cd, temp3->med_service_cd = ra.med_service_cd,
   temp3->admitsource_flag = ra.admitsource_flag,
   temp3->admit_icu_cd = ra.admit_icu_cd, temp3->hrs_at_source = ra.hrs_at_source, temp3->body_system
    = ra.body_system,
   temp3->admitdiagnosis = ra.admit_diagnosis, temp3->disease_category_cd = ra.disease_category_cd,
   temp3->therapy_level = ra.therapy_level,
   temp3->xfer_within_48hr_ind = ra.xfer_within_48hr_ind, temp3->electivesurgery_ind = ra
   .electivesurgery_ind, temp3->readmit_ind = ra.readmit_ind,
   temp3->readmit_within_24hr_ind = ra.readmit_within_24hr_ind, temp3->age = ra.admit_age, temp3->
   hosp_admit_dt_tm = cnvtdatetime(ra.hosp_admit_dt_tm),
   temp3->gender = ra.gender_flag, temp3->teach_type_flag = ra.teach_type_flag, temp3->region_flag =
   ra.region_flag,
   temp3->bedcount = ra.bed_count, temp3->dialysis_ind = ra.dialysis_ind, temp3->aids_ind = ra
   .aids_ind,
   temp3->hepaticfailure_ind = ra.hepaticfailure_ind, temp3->lymphoma_ind = ra.lymphoma_ind, temp3->
   metastaticcancer_ind = ra.metastaticcancer_ind,
   temp3->leukemia_ind = ra.leukemia_ind, temp3->immunosuppression_ind = ra.immunosuppression_ind,
   temp3->cirrhosis_ind = ra.cirrhosis_ind,
   temp3->diabetes_ind = ra.diabetes_ind, temp3->copd_flag = ra.copd_flag, temp3->copd_ind = ra
   .copd_ind,
   temp3->chronic_health_unavail_ind = ra.chronic_health_unavail_ind, temp3->chronic_health_none_ind
    = ra.chronic_health_none_ind, temp3->ami_location = ra.ami_location,
   temp3->ptca_device = ra.ptca_device, temp3->thrombolytics_ind = ra.thrombolytics_ind, temp3->
   nbr_grafts_performed = ra.nbr_grafts_performed,
   temp3->ima_ind = ra.ima_ind, temp3->midur_ind = ra.midur_ind, temp3->sv_graft_ind = ra
   .sv_graft_ind,
   temp3->mi_within_6mo_ind = ra.mi_within_6mo_ind, temp3->cc_during_stay_ind = ra.cc_during_stay_ind,
   temp3->ventday1_ind = - (1),
   temp3->oobventday1_ind = - (1), temp3->oobintubday1_ind = - (1), temp3->var03hspxlos = ra
   .var03hspxlos_value,
   temp3->ejectfx = ra.ejectfx_fraction, temp3->diedinicu_ind = ra.diedinicu_ind, temp3->adm_doc_id
    = ra.adm_doc_id,
   old_adm_dt_tm = cnvtdatetime(ra.icu_admit_dt_tm), old_disch_dt_tm = cnvtdatetime(ra
    .icu_disch_dt_tm)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ra_found = "N"
 ELSE
  SET ra_found = "Y"
 ENDIF
 SET hdeath_parameters->risk_adjustment_id = temp3->risk_adjustment_id
 EXECUTE cco_get_died_hosp_from_ra
 SET temp3->diedinhospital_ind = hdeath_reply->hosp_death_ind
 IF (ra_found="Y")
  SELECT INTO "nl:"
   FROM encounter e
   WHERE (e.encntr_id=temp3->encntr_id)
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
    cc_day_start_time = rar.icu_day_start_time, accept_worst_lab_ind = rar.accept_worst_lab_ind,
    accept_worst_vitals_ind = rar.accept_worst_vitals_ind,
    accept_urine_output_ind = rar.accept_urine_output_ind
   WITH nocounter
  ;end select
 ENDIF
 SET get_visit_parameters->risk_adjustment_id = value(temp3->risk_adjustment_id)
 EXECUTE cco_get_apache_visit_number
 SET discharge_location_display = uar_get_code_meaning(temp3->discharge_location_cd)
 IF ((temp3->diedinicu_ind=1))
  SET discharge_location_display = "DEATH"
 ENDIF
#1099_initialize_exit
#1500_oth_cc_days
 SET abc = fillstring(20," ")
 SET abc2 = fillstring(20," ")
 IF ((request->admit_time_chg_ind=1))
  SET abc = format(request->new_icu_admit_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
 ELSE
  SET abc = format(temp3->icu_admit_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
 ENDIF
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
  SET virt_beg_day1_dt_tm = datetimeadd(beg_day1_dt_tm,1)
  SET end_day1_dt_tm = datetimeadd(end_day1_dt_tm,1)
  SET day_cnt = (day_cnt - 1)
 ELSE
  SET virt_beg_day1_dt_tm = cnvtdatetime(beg_day1_dt_tm)
 ENDIF
 SET beg_day1_dt_tm = cnvtdatetime(reg_dt_tm)
 SET stat = alterlist(temp->cc_day,value(day_cnt))
 FOR (x = 1 TO day_cnt)
   IF (x=1)
    SET temp->cc_day[x].beg_dt_tm = cnvtdatetime(beg_day1_dt_tm)
   ELSE
    SET temp->cc_day[x].beg_dt_tm = cnvtdatetime(virt_beg_day1_dt_tm)
   ENDIF
   SET temp->cc_day[x].end_dt_tm = cnvtdatetime(end_day1_dt_tm)
   SET virt_beg_day1_dt_tm = datetimeadd(virt_beg_day1_dt_tm,1)
   SET end_day1_dt_tm = datetimeadd(end_day1_dt_tm,1)
 ENDFOR
 SET temp->day_cnt = day_cnt
#1599_oth_cc_days_exit
#2000_adm
 SET cc_beg_dt_tm = cnvtdatetime((curdate+ 1000),curtime3)
 SET cc_end_dt_tm = cnvtdatetime((curdate+ 1000),curtime3)
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
    AND rad.cc_day=1
    AND rad.active_ind=1)
  DETAIL
   cc_beg_dt_tm = cnvtdatetime(rad.cc_beg_dt_tm), cc_end_dt_tm = cnvtdatetime(rad.cc_end_dt_tm),
   temp3->ventday1_ind = rad.vent_today_ind,
   temp3->oobventday1_ind = rad.vent_ind, temp3->oobintubday1_ind = rad.intubated_ind
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (day_cnt > 0
   AND (temp->cc_day[1].end_dt_tm=cnvtdatetime(cc_end_dt_tm)))
   SET same_end_day1 = "Y"
  ELSE
   SET same_end_day1 = "N"
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM risk_adjustment_day rad
   PLAN (rad
    WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
     AND rad.active_ind=1)
   DETAIL
    IF (rad.cc_beg_dt_tm=cnvtdatetime(temp->cc_day[rad.cc_day].beg_dt_tm)
     AND rad.cc_end_dt_tm=cnvtdatetime(temp->cc_day[rad.cc_day].end_dt_tm))
     same_end_day1 = "Y"
    ELSE
     same_end_day1 = "N"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (same_end_day1="N")
  SET day_cnt = 0
  SELECT INTO "nl:"
   FROM risk_adjustment_day rad
   PLAN (rad
    WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
     AND rad.active_ind=1)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(temp4->dlist,cnt), temp4->dlist[cnt].risk_adjustment_day_id =
    rad.risk_adjustment_day_id
   FOOT REPORT
    day_cnt = cnt
   WITH nocounter
  ;end select
  IF (day_cnt > 0)
   EXECUTE FROM upd_rao_rad TO upd_rao_rad_exit
  ENDIF
  SET temp3->icu_admit_dt_tm = cnvtdatetime(request->new_icu_admit_dt_tm)
  EXECUTE FROM 3000_update_ra TO 3099_update_ra_exit
  IF (success_flag="Y")
   SET reply->risk_adjustment_id = ra_id
   SET reqinfo->commit_ind = 1
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = fail_string
   SET reqinfo->commit_ind = 0
  ENDIF
 ELSE
  SET temp3->icu_admit_dt_tm = cnvtdatetime(request->new_icu_admit_dt_tm)
  EXECUTE FROM 3000_update_ra TO 3099_update_ra_exit
  IF (success_flag="Y")
   SET day_cnt = 0
   EXECUTE FROM load_rad_days TO load_rad_days_exit
   IF (day_cnt > 0)
    EXECUTE FROM upd_rao_rad TO upd_rao_rad_exit
    SET success_flag = "Y"
    FOR (x = 1 TO day_cnt)
     EXECUTE FROM 3100_rad TO 3199_rad_exit
     IF (success_flag="N")
      SET x = day_cnt
     ENDIF
    ENDFOR
   ENDIF
   IF (success_flag="Y")
    SET reply->risk_adjustment_id = ra_id
    SET reqinfo->commit_ind = 1
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "F"
    SET reqinfo->commit_ind = 0
   ENDIF
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = fail_string
   SET reqinfo->commit_ind = 0
  ENDIF
 ENDIF
#2099_adm_exit
#load_rad_days
 SELECT
  IF ((request->disch_time_chg_ind=1))
   PLAN (rad
    WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
     AND rad.cc_beg_dt_tm < cnvtdatetime(request->new_icu_disch_dt_tm)
     AND rad.active_ind=1)
  ELSE
   PLAN (rad
    WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
     AND rad.active_ind=1)
  ENDIF
  INTO "nl:"
  FROM risk_adjustment_day rad
  ORDER BY rad.cc_day
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp4->dlist,cnt), temp4->dlist[cnt].risk_adjustment_id = rad
   .risk_adjustment_id,
   temp4->dlist[cnt].risk_adjustment_day_id = rad.risk_adjustment_day_id, temp4->dlist[cnt].cc_day =
   rad.cc_day, temp4->dlist[cnt].cc_beg_dt_tm = cnvtdatetime(rad.cc_beg_dt_tm),
   temp4->dlist[cnt].cc_end_dt_tm = cnvtdatetime(rad.cc_end_dt_tm), temp4->dlist[cnt].intubated_ind
    = rad.intubated_ind, temp4->dlist[cnt].intubated_ce_id = rad.intubated_ce_id,
   temp4->dlist[cnt].vent_ind = rad.vent_ind, temp4->dlist[cnt].eyes = rad.worst_gcs_eye_score, temp4
   ->dlist[cnt].eyes_ce_id = rad.eyes_ce_id,
   temp4->dlist[cnt].motor = rad.worst_gcs_motor_score, temp4->dlist[cnt].motor_ce_id = rad
   .motor_ce_id, temp4->dlist[cnt].verbal = rad.worst_gcs_verbal_score,
   temp4->dlist[cnt].verbal_ce_id = rad.verbal_ce_id, temp4->dlist[cnt].meds_ind = rad.meds_ind,
   temp4->dlist[cnt].meds_ce_id = rad.meds_ce_id,
   temp4->dlist[cnt].urine = rad.urine_output, temp4->dlist[cnt].urine_24hr = rad.urine_24hr_output,
   temp4->dlist[cnt].wbc = rad.worst_wbc_result,
   temp4->dlist[cnt].wbc_ce_id = rad.wbc_ce_id, temp4->dlist[cnt].temp = rad.worst_temp, temp4->
   dlist[cnt].temp_ce_id = rad.temp_ce_id,
   temp4->dlist[cnt].resp = rad.worst_resp_result, temp4->dlist[cnt].resp_ce_id = rad.resp_ce_id,
   temp4->dlist[cnt].sodium = rad.worst_sodium_result,
   temp4->dlist[cnt].sodium_ce_id = rad.sodium_ce_id, temp4->dlist[cnt].heartrate = rad
   .worst_heart_rate, temp4->dlist[cnt].heartrate_ce_id = rad.heartrate_ce_id,
   temp4->dlist[cnt].meanbp = rad.mean_blood_pressure, temp4->dlist[cnt].ph = rad.worst_ph_result,
   temp4->dlist[cnt].ph_ce_id = rad.ph_ce_id,
   temp4->dlist[cnt].hematocrit = rad.worst_hematocrit, temp4->dlist[cnt].hematocrit_ce_id = rad
   .hematocrit_ce_id, temp4->dlist[cnt].creatinine = rad.worst_creatinine_result,
   temp4->dlist[cnt].creatinine_ce_id = rad.creatinine_ce_id, temp4->dlist[cnt].albumin = rad
   .worst_albumin_result, temp4->dlist[cnt].albumin_ce_id = rad.albumin_ce_id,
   temp4->dlist[cnt].pao2 = rad.worst_pao2_result, temp4->dlist[cnt].pao2_ce_id = rad.pao2_ce_id,
   temp4->dlist[cnt].pco2 = rad.worst_pco2_result,
   temp4->dlist[cnt].pco2_ce_id = rad.pco2_ce_id, temp4->dlist[cnt].bun = rad.worst_bun_result, temp4
   ->dlist[cnt].bun_ce_id = rad.bun_ce_id,
   temp4->dlist[cnt].glucose = rad.worst_glucose_result, temp4->dlist[cnt].glucose_ce_id = rad
   .glucose_ce_id, temp4->dlist[cnt].bilirubin = rad.worst_bilirubin_result,
   temp4->dlist[cnt].bilirubin_ce_id = rad.bilirubin_ce_id, temp4->dlist[cnt].potassium = rad
   .worst_potassium_result, temp4->dlist[cnt].potassium_ce_id = rad.potassium_ce_id,
   temp4->dlist[cnt].fio2 = rad.worst_fio2_result, temp4->dlist[cnt].fio2_ce_id = rad.fio2_ce_id,
   temp4->dlist[cnt].aps_score = rad.aps_score,
   temp4->dlist[cnt].aps_day1 = rad.aps_day1, temp4->dlist[cnt].aps_yesterday = rad.aps_yesterday,
   temp4->dlist[cnt].activetx_ind = rad.activetx_ind,
   temp4->dlist[cnt].vent_today_ind = rad.vent_today_ind, temp4->dlist[cnt].pa_line_today_ind = rad
   .pa_line_today_ind, temp4->dlist[cnt].outcome_status = rad.outcome_status,
   temp4->dlist[cnt].apache_iii_score = rad.apache_iii_score, temp4->dlist[cnt].phys_res_pts = rad
   .phys_res_pts
  FOOT REPORT
   day_cnt = cnt
  WITH nocounter
 ;end select
#load_rad_days_exit
#upd_rao_rad
 FOR (x = 1 TO day_cnt)
   UPDATE  FROM risk_adjustment_outcomes rao
    SET rao.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rao.active_ind = 0, rao
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     rao.updt_dt_tm = cnvtdatetime(curdate,curtime3), rao.updt_task = reqinfo->updt_task, rao
     .updt_applctx = reqinfo->updt_applctx,
     rao.updt_id = reqinfo->updt_id, rao.updt_cnt = (rao.updt_cnt+ 1)
    WHERE (rao.risk_adjustment_day_id=temp4->dlist[x].risk_adjustment_day_id)
    WITH nocounter
   ;end update
 ENDFOR
 UPDATE  FROM risk_adjustment_day rad
  SET rad.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rad.active_ind = 0, rad
   .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   rad.updt_dt_tm = cnvtdatetime(curdate,curtime3), rad.updt_task = reqinfo->updt_task, rad
   .updt_applctx = reqinfo->updt_applctx,
   rad.updt_id = reqinfo->updt_id, rad.updt_cnt = (rad.updt_cnt+ 1)
  WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
   AND rad.active_ind=1
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed_text = "CURQUAL = 0!!!!"
  GO TO 9999_exit_program
 ENDIF
#upd_rao_rad_exit
#upd_tiss
 UPDATE  FROM risk_adj_tiss rat
  SET rat.tiss_end_dt_tm = cnvtdatetime(request->new_icu_disch_dt_tm), rat.updt_cnt = (rat.updt_cnt+
   1), rat.updt_id = reqinfo->updt_id,
   rat.updt_applctx = reqinfo->updt_applctx, rat.updt_dt_tm = cnvtdatetime(curdate,curtime3), rat
   .updt_task = reqinfo->updt_task
  WHERE (rat.risk_adjustment_id=request->risk_adjustment_id)
   AND rat.tiss_end_dt_tm > cnvtdatetime(request->new_icu_disch_dt_tm)
   AND rat.active_ind=1
  WITH nocounter
 ;end update
#upd_tiss_exit
#3000_update_ra
 SET success_flag = "Y"
 SET ra_id = 0.0
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   ra_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 IF (ra_id > 0.0)
  UPDATE  FROM risk_adjustment ra
   SET ra.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), ra.active_ind = 0, ra
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    ra.active_status_prsnl_id = reqinfo->updt_id, ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra
    .updt_task = reqinfo->updt_task,
    ra.updt_applctx = reqinfo->updt_applctx, ra.updt_id = reqinfo->updt_id, ra.updt_cnt = (ra
    .updt_cnt+ 1)
   WHERE (ra.risk_adjustment_id=request->risk_adjustment_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET success_flag = "N"
   SET fail_string = "Error inactivating risk_adjustment row (600719)."
  ELSE
   INSERT  FROM risk_adjustment ra
    SET ra.risk_adjustment_id = ra_id, ra.person_id = temp3->person_id, ra.encntr_id = temp3->
     encntr_id,
     ra.icu_admit_dt_tm = cnvtdatetime(temp3->icu_admit_dt_tm), ra.icu_disch_dt_tm = cnvtdatetime(
      temp3->icu_disch_dt_tm), ra.admit_source = temp3->admit_source,
     ra.med_service_cd = temp3->med_service_cd, ra.admitsource_flag = temp3->admitsource_flag, ra
     .discharge_location_cd = temp3->discharge_location_cd,
     ra.admit_icu_cd = temp3->admit_icu_cd, ra.hrs_at_source = temp3->hrs_at_source, ra.body_system
      = temp3->body_system,
     ra.admit_diagnosis = temp3->admitdiagnosis, ra.disease_category_cd = temp3->disease_category_cd,
     ra.therapy_level = temp3->therapy_level,
     ra.xfer_within_48hr_ind = temp3->xfer_within_48hr_ind, ra.electivesurgery_ind = temp3->
     electivesurgery_ind, ra.readmit_ind = temp3->readmit_ind,
     ra.readmit_within_24hr_ind = temp3->readmit_within_24hr_ind, ra.admit_age = temp3->age, ra
     .hosp_admit_dt_tm = cnvtdatetime(temp3->hosp_admit_dt_tm),
     ra.gender_flag = temp3->gender, ra.teach_type_flag = temp3->teach_type_flag, ra.region_flag =
     temp3->region_flag,
     ra.bed_count = temp3->bedcount, ra.dialysis_ind = temp3->dialysis_ind, ra.aids_ind = temp3->
     aids_ind,
     ra.hepaticfailure_ind = temp3->hepaticfailure_ind, ra.lymphoma_ind = temp3->lymphoma_ind, ra
     .metastaticcancer_ind = temp3->metastaticcancer_ind,
     ra.leukemia_ind = temp3->leukemia_ind, ra.immunosuppression_ind = temp3->immunosuppression_ind,
     ra.cirrhosis_ind = temp3->cirrhosis_ind,
     ra.diabetes_ind = temp3->diabetes_ind, ra.copd_flag = temp3->copd_flag, ra.copd_ind = temp3->
     copd_ind,
     ra.chronic_health_unavail_ind = temp3->chronic_health_unavail_ind, ra.chronic_health_none_ind =
     temp3->chronic_health_none_ind, ra.ami_location = temp3->ami_location,
     ra.ptca_device = temp3->ptca_device, ra.thrombolytics_ind = temp3->thrombolytics_ind, ra
     .diedinhospital_ind = temp3->diedinhospital_ind,
     ra.nbr_grafts_performed = temp3->nbr_grafts_performed, ra.ima_ind = temp3->ima_ind, ra.midur_ind
      = temp3->midur_ind,
     ra.sv_graft_ind = temp3->sv_graft_ind, ra.mi_within_6mo_ind = temp3->mi_within_6mo_ind, ra
     .cc_during_stay_ind = temp3->cc_during_stay_ind,
     ra.var03hspxlos_value = temp3->var03hspxlos, ra.ejectfx_fraction = temp3->ejectfx, ra
     .diedinicu_ind = temp3->diedinicu_ind,
     ra.adm_doc_id = temp3->adm_doc_id, ra.valid_from_dt_tm = cnvtdatetime(curdate,curtime3), ra
     .valid_until_dt_tm = cnvtdatetime("31-DEC-2100"),
     ra.active_ind = 1, ra.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ra
     .active_status_prsnl_id = reqinfo->updt_id,
     ra.active_status_cd = reqdata->active_status_cd, ra.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     ra.updt_task = reqinfo->updt_task,
     ra.updt_applctx = reqinfo->updt_applctx, ra.updt_id = reqinfo->updt_id, ra.updt_cnt = 0
    WITH nocounter
   ;end insert
   UPDATE  FROM risk_adjustment_event rae
    SET rae.risk_adjustment_id = ra_id, rae.updt_dt_tm = cnvtdatetime(curdate,curtime3), rae
     .updt_task = reqinfo->updt_task,
     rae.updt_applctx = reqinfo->updt_applctx, rae.updt_id = reqinfo->updt_id, rae.updt_cnt = (rae
     .updt_cnt+ 1)
    WHERE (rae.risk_adjustment_id=request->risk_adjustment_id)
    WITH nocounter
   ;end update
   UPDATE  FROM risk_adj_tiss rat
    SET rat.risk_adjustment_id = ra_id, rat.updt_dt_tm = cnvtdatetime(curdate,curtime3), rat
     .updt_task = reqinfo->updt_task,
     rat.updt_applctx = reqinfo->updt_applctx, rat.updt_id = reqinfo->updt_id, rat.updt_cnt = (rat
     .updt_cnt+ 1)
    WHERE (rat.risk_adjustment_id=request->risk_adjustment_id)
    WITH nocounter
   ;end update
  ENDIF
 ELSE
  SET success_flag = "N"
  SET fail_string = "Unable to get new ra_id from sequence bucket."
 ENDIF
#3099_update_ra_exit
#3100_rad
 IF ((temp4->dlist[x].cc_day=1))
  IF (accept_worst_lab_ind=0)
   SET search_beg_dt_tm = cnvtdatetime(temp->cc_day[1].beg_dt_tm)
   SET search_end_dt_tm = cnvtdatetime(temp->cc_day[1].end_dt_tm)
   EXECUTE FROM 3200_worst_lab TO 3299_worst_lab_exit
  ENDIF
  IF (accept_worst_vitals_ind=0)
   SET search_beg_dt_tm = cnvtdatetime(temp->cc_day[1].beg_dt_tm)
   SET search_end_dt_tm = cnvtdatetime(temp->cc_day[1].end_dt_tm)
   EXECUTE FROM 3300_worst_vitals TO 3399_worst_vitals_exit
  ENDIF
  IF (accept_urine_output_ind=0)
   SET search_beg_dt_tm = cnvtdatetime(temp->cc_day[1].beg_dt_tm)
   SET search_end_dt_tm = cnvtdatetime(temp->cc_day[1].end_dt_tm)
   EXECUTE FROM 3400_urine TO 3499_urine_exit
  ELSE
   IF ((temp4->dlist[x].urine=- (1)))
    SET temp4->dlist[x].urine_24hr = - (1)
   ELSE
    SET d2 = abs(datetimediff(cnvtdatetime(temp3->icu_admit_dt_tm),cnvtdatetime(temp4->dlist[x].
       cc_end_dt_tm),3))
    SET temp4->dlist[x].urine_24hr = round(((temp4->dlist[x].urine/ d2) * 24),0)
   ENDIF
  ENDIF
 ENDIF
 IF ((temp3->age < 16))
  EXECUTE FROM 3500_aps TO 3599_aps_exit
  SET temp4->dlist[x].outcome_status = - (23103)
 ELSE
  IF ((temp4->dlist[x].outcome_status >= 0))
   SET day1meds = temp4->dlist[1].meds_ind
   SET day1verbal = temp4->dlist[1].verbal
   SET day1motor = temp4->dlist[1].motor
   SET day1eyes = temp4->dlist[1].eyes
   SET day1pao2 = temp4->dlist[1].pao2
   SET day1fio2 = temp4->dlist[1].fio2
   EXECUTE FROM 3600_outcomes TO 3699_outcomes_exit
  ENDIF
 ENDIF
 IF (x=1)
  SET temp4->dlist[x].cc_beg_dt_tm = cnvtdatetime(temp->cc_day[1].beg_dt_tm)
 ENDIF
 EXECUTE FROM 3700_create_rad TO 3799_create_rad_exit
#3199_rad_exit
#3200_worst_lab
 EXECUTE FROM worst_wbc TO worst_wbc_exit
 EXECUTE FROM worst_sodium TO worst_sodium_exit
 EXECUTE FROM worst_hematocrit TO worst_hematocrit_exit
 EXECUTE FROM worst_creatinine TO worst_creatinine_exit
 EXECUTE FROM worst_albumin TO worst_albumin_exit
 EXECUTE FROM worst_bilirubin TO worst_bilirubin_exit
 EXECUTE FROM worst_potassium TO worst_potassium_exit
 EXECUTE FROM worst_bun TO worst_bun_exit
 EXECUTE FROM worst_glucose TO worst_glucose_exit
 EXECUTE FROM worst_abg TO worst_abg_exit
#3299_worst_lab_exit
#worst_gcs
 SET gcs_total = 0.0
 SET temp_eyes = 0.0
 SET temp_motor = 0.0
 SET temp_verbal = 0.0
 SET temp_meds = 0.0
 SET found_new_worst = 0
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
  IF ((((temp4->dlist[x].eyes_ce_id > 0)) OR ((((temp4->dlist[x].motor_ce_id > 0)) OR ((((temp4->
  dlist[x].verbal_ce_id > 0)) OR ((temp4->dlist[x].meds_ce_id > 0))) )) )) )
   SET temp4->dlist[x].eyes = - (1)
   SET temp4->dlist[x].motor = - (1)
   SET temp4->dlist[x].verbal = - (1)
   SET temp4->dlist[x].meds_ind = - (1)
   SET temp4->dlist[x].eyes_ce_id = 0.0
   SET temp4->dlist[x].motor_ce_id = 0.0
   SET temp4->dlist[x].verbal_ce_id = 0.0
   SET temp4->dlist[x].meds_ce_id = 0.0
  ENDIF
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=temp3->person_id)
     AND ((ce.event_cd=eyes_cd) OR (((ce.event_cd=motor_cd) OR (((ce.event_cd=verbal_cd) OR (ce
    .event_cd=meds_cd)) )) ))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    temp_total = 0.0, hold_eyes = 0.0, hold_motor = 0.0,
    hold_verbal = 0.0, hold_meds = - (1.0), hold_eyes_ce_id = 0.0,
    hold_motor_ce_id = 0.0, hold_verbal_ce_id = 0.0, hold_meds_ce_id = 0.0,
    temp_eyes_ce_id = 0.0, temp_motor_ce_id = 0.0, temp_verbal_ce_id = 0.0,
    temp_meds_ce_id = 0.0, temp_eyes = 0.0, temp_motor = 0.0,
    temp_verbal = 0.0, temp_meds = 0.0
    IF ((((temp4->dlist[x].eyes_ce_id > 0)
     AND (temp4->dlist[x].motor_ce_id > 0)
     AND (temp4->dlist[x].verbal_ce_id > 0)) OR ((temp4->dlist[x].meds_ce_id > 0))) )
     hold_eyes = - (1.0), hold_motor = - (1.0), hold_verbal = - (1.0),
     hold_meds = - (1.0), hold_eyes_ce_id = 0.0, hold_motor_ce_id = 0.0,
     hold_verbal_ce_id = 0.0, hold_meds_ce_id = 0.0, gcs_total = 16
    ELSE
     hold_eyes = temp4->dlist[x].eyes, hold_motor = temp4->dlist[x].motor, hold_verbal = temp4->
     dlist[x].verbal,
     hold_meds = temp4->dlist[x].meds_ind, hold_eyes_ce_id = temp4->dlist[x].eyes_ce_id,
     hold_motor_ce_id = temp4->dlist[x].motor_ce_id,
     hold_verbal_ce_id = temp4->dlist[x].verbal_ce_id, hold_meds_ce_id = temp4->dlist[x].meds_ce_id
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
      IF ((temp3->age < 6))
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
    CALL echo(build("old total=",gcs_total))
    IF (((temp_eyes > 0
     AND temp_motor > 0
     AND temp_verbal > 0) OR (temp_meds > 0)) )
     IF (temp_meds=1)
      temp_total = 15
     ELSE
      temp_total = ((temp_eyes+ temp_motor)+ temp_verbal)
     ENDIF
     CALL echo(build("temp_total=",temp_total)),
     CALL echo(build("gcs_total=",gcs_total))
     IF (hold_eyes=temp_eyes
      AND hold_meds_ce_id < 1)
      hold_eyes_ce_id = temp_eyes_ce_id, hold_motor_ce_id = temp_motor_ce_id, hold_verbal_ce_id =
      temp_verbal_ce_id,
      hold_meds_ce_id = temp_meds_ce_id, found_new_worst = 1
     ENDIF
     IF (((temp_total < gcs_total) OR (gcs_total=0)) )
      gcs_total = temp_total, hold_eyes = temp_eyes, hold_motor = temp_motor,
      hold_verbal = temp_verbal, hold_meds = temp_meds, hold_eyes_ce_id = temp_eyes_ce_id,
      hold_motor_ce_id = temp_motor_ce_id, hold_verbal_ce_id = temp_verbal_ce_id, hold_meds_ce_id =
      temp_meds_ce_id,
      found_new_worst = 1
     ENDIF
    ENDIF
   FOOT REPORT
    IF (found_new_worst=1)
     temp4->dlist[x].eyes = hold_eyes, temp4->dlist[x].motor = hold_motor, temp4->dlist[x].verbal =
     hold_verbal,
     temp4->dlist[x].meds_ind = hold_meds, temp4->dlist[x].eyes_ce_id = hold_eyes_ce_id, temp4->
     dlist[x].motor_ce_id = hold_motor_ce_id,
     temp4->dlist[x].verbal_ce_id = hold_verbal_ce_id, temp4->dlist[x].meds_ce_id = hold_meds_ce_id,
     CALL echo(build("temp4->dlist[x].verbal_ce_id=",temp4->dlist[x].verbal_ce_id))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#worst_gcs_exit
#worst_wbc
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!4046")
 IF (res_cd > 0.0)
  SET midpoint = 11.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  IF (event_tag_num > 0)
   SET temp4->dlist[x].wbc = event_tag_num
   SET temp4->dlist[x].wbc_ce_id = ce_id
  ENDIF
 ENDIF
#worst_wbc_exit
#worst_sodium
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3758")
 IF (res_cd > 0.0)
  SET midpoint = 145
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  IF (event_tag_num > 0)
   SET temp4->dlist[x].sodium = event_tag_num
   SET temp4->dlist[x].sodium_ce_id = ce_id
  ENDIF
 ENDIF
#worst_sodium_exit
#worst_hematocrit
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3404")
 IF (res_cd > 0.0)
  SET midpoint = 45.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  IF (event_tag_num > 0)
   SET temp4->dlist[x].hematocrit = event_tag_num
   SET temp4->dlist[x].hematocrit_ce_id = ce_id
  ENDIF
 ENDIF
#worst_hematocrit_exit
#worst_creatinine
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3256")
 IF (res_cd > 0.0)
  SET midpoint = 1
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  IF (event_tag_num > 0)
   SET temp4->dlist[x].creatinine = event_tag_num
   SET temp4->dlist[x].creatinine_ce_id = ce_id
  ENDIF
 ENDIF
#worst_creatinine_exit
#worst_albumin
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3025")
 IF (res_cd > 0.0)
  SET midpoint = 3.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  IF (event_tag_num > 0)
   SET temp4->dlist[x].albumin = event_tag_num
   SET temp4->dlist[x].albumin_ce_id = ce_id
  ENDIF
 ENDIF
#worst_albumin_exit
#worst_bilirubin
 SET event_tag_num = - (1.0)
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3133")
 IF (res_cd > 0.0)
  EXECUTE FROM highest_result TO highest_result_exit
  IF (event_tag_num > 0)
   SET temp4->dlist[x].bilirubin = event_tag_num
   SET temp4->dlist[x].bilirubin_ce_id = ce_id
  ENDIF
 ENDIF
#worst_bilirubin_exit
#worst_potassium
 SET event_tag_num = - (1.0)
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3681")
 IF (res_cd > 0.0)
  SET midpoint = 4.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  IF (event_tag_num > 0)
   SET temp4->dlist[x].potassium = event_tag_num
   SET temp4->dlist[x].potassium_ce_id = ce_id
  ENDIF
 ENDIF
#worst_potassium_exit
#worst_bun
 SET event_tag_num = - (1.0)
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res_cd = uar_get_code_by_cki("CKI.EC!3142")
 IF (res_cd > 0.0)
  EXECUTE FROM highest_result TO highest_result_exit
  IF (event_tag_num > 0)
   SET temp4->dlist[x].bun = event_tag_num
   SET temp4->dlist[x].bun_ce_id = ce_id
  ENDIF
 ENDIF
#worst_bun_exit
#worst_glucose
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET gluc1_cd = uar_get_code_by_cki("CKI.EC!3374")
 SET gluc2_cd = uar_get_code_by_cki("CKI.EC!5634")
 IF (((gluc1_cd > 0.0) OR (gluc2_cd > 0.0)) )
  SET midpoint = 130.0
  SET hold_diff = - (1.0)
  SET temp_res = 0.0
  SET temp_diff = - (1.0)
  SET hold_tag = 0.0
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=temp3->person_id)
     AND ce.event_cd IN (gluc1_cd, gluc2_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_res = 0.0, temp_diff = - (1.0),
    hold_diff = - (1.0), isnum = 0, ce_id = 0.0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_res = cnvtreal(ce.event_tag), temp_diff = abs((temp_res - midpoint))
     IF (((temp_diff > hold_diff) OR (ce_id=0)) )
      hold_diff = temp_diff, event_tag_num = temp_res, ce_id = ce.clinical_event_id,
      found_new_worst = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (event_tag_num > 0)
   SET temp4->dlist[x].glucose = event_tag_num
   SET temp4->dlist[x].glucose_ce_id = ce_id
  ENDIF
 ENDIF
#worst_glucose_exit
#highest_result
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=temp3->person_id)
    AND ce.event_cd=res_cd
    AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != inerror_cd)
  ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
  HEAD REPORT
   hold_tag = 0.0, temp_res = 0.0, isnum = 0
  DETAIL
   isnum = isnumeric(ce.event_tag)
   IF (isnum > 0)
    temp_res = cnvtreal(ce.event_tag)
    IF (((temp_res > event_tag_num) OR (ce_id=0)) )
     event_tag_num = temp_res, ce_id = ce.clinical_event_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#highest_result_exit
#midpoint_rule
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=temp3->person_id)
    AND ce.event_cd=res_cd
    AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != inerror_cd)
  ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
  HEAD REPORT
   hold_tag = 0.0, temp_res = 0.0, temp_diff = 0.0,
   hold_diff = - (1.0), isnum = 0
  DETAIL
   isnum = isnumeric(ce.event_tag)
   IF (isnum > 0)
    temp_res = cnvtreal(ce.event_tag), temp_diff = abs((temp_res - midpoint))
    IF (((temp_diff > hold_diff) OR (ce_id=0)) )
     hold_diff = temp_diff, event_tag_num = temp_res, ce_id = ce.clinical_event_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#midpoint_rule_exit
#3300_worst_vitals
 EXECUTE FROM worst_temp TO worst_temp_exit
 EXECUTE FROM worst_resp TO worst_resp_exit
 EXECUTE FROM worst_heartrate TO worst_heartrate_exit
 EXECUTE FROM worst_meanbp TO worst_meanbp_exit
 EXECUTE FROM worst_gcs TO worst_gcs_exit
#3399_worst_vitals_exit
#worst_temp
 SET event_tag_num = - (1.0)
 SET hold_tag = - (1.0)
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
 IF (((temp1_cd > 0.0) OR (((temp2_cd > 0.0) OR (((temp3_cd > 0.0) OR (((ax_temp4_cd > 0.0) OR (((
 temp5_cd > 0.0) OR (temp6_cd > 0.0)) )) )) )) )) )
  SET midpoint = 38
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=temp3->person_id)
     AND ((ce.event_cd=temp1_cd) OR (((ce.event_cd=temp2_cd) OR (((ce.event_cd=temp3_cd) OR (((ce
    .event_cd=ax_temp4_cd) OR (((ce.event_cd=temp5_cd) OR (ce.event_cd=temp6_cd)) )) )) )) ))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_temp = 0.0, temp_diff = 0.0,
    hold_diff = - (1.0), isnum = 0
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
     IF (((temp_diff > hold_diff) OR (ce_id=0)) )
      hold_diff = temp_diff, hold_tag = cnvtreal(ce.event_tag), ce_id = ce.clinical_event_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (hold_tag > 0)
  SET temp4->dlist[x].temp = hold_tag
  SET temp4->dlist[x].temp_ce_id = ce_id
 ENDIF
#worst_temp_exit
#worst_resp
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET hold_resp = - (1.0)
 SET hold_diff = - (1.0)
 SET hold_vent = - (1.0)
 SET temp_resp = - (1.0)
 SET ce_id = 0.0
 SET temp_ce_id = 0.0
 SET resp_cd = 0.0
 SET resp_cd = uar_get_code_by_cki("CKI.EC!5501")
 SET vent_cd = 0.0
 SET vent_cd = uar_get_code_by_cki("CKI.EC!7676")
 IF (resp_cd > 0.0
  AND vent_cd > 0.0)
  SET midpoint = 19.0
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=temp3->person_id)
     AND ((ce.event_cd=resp_cd) OR (ce.event_cd=vent_cd))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, hold_resp = 0.0, hold_vent = - (1.0),
    hold_diff = - (1.0), temp_resp = 0.0, temp_vent = - (1.0),
    temp_diff = - (1.0), isnum = 0
   HEAD ce.event_end_dt_tm
    temp_resp = 0.0, temp_vent = - (1.0), temp_diff = - (1.0),
    temp_ce_id = 0.0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (ce.event_cd=vent_cd)
     isnum = 1
    ENDIF
    IF (isnum > 0)
     IF (ce.event_cd=resp_cd)
      temp_resp = cnvtreal(ce.event_tag), temp_ce_id = ce.clinical_event_id
      IF (temp_vent < 0)
       temp_vent = 0
      ENDIF
     ELSE
      temp_vent = 1
     ENDIF
    ENDIF
   FOOT  ce.event_end_dt_tm
    IF (temp_resp > 0
     AND temp_vent >= 0)
     temp_diff = abs((temp_resp - midpoint))
     IF (temp_diff >= hold_diff)
      IF (((temp_vent <= hold_vent) OR ((hold_vent=- (1)))) )
       hold_resp = temp_resp, hold_vent = temp_vent, event_tag_num = temp_resp,
       ce_id = temp_ce_id
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (hold_resp > 0
   AND hold_vent >= 0)
   SET temp4->dlist[x].resp = hold_resp
   SET temp4->dlist[x].vent_ind = hold_vent
   SET temp4->dlist[x].resp_ce_id = ce_id
   SET found_new_worst = 1
  ENDIF
 ENDIF
#worst_resp_exit
#worst_heartrate
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET hr1_cd = 0.0
 SET hr1_cd = uar_get_code_by_cki("CKI.EC!40")
 SET hr2_cd = 0.0
 SET hr2_cd = uar_get_code_by_cki("CKI.EC!5500")
 SET hr3_cd = 0.0
 SET hr3_cd = uar_get_code_by_cki("CKI.EC!7187")
 SET hr4_cd = 0.0
 SET hr4_cd = uar_get_code_by_cki("CKI.EC!7679")
 IF (((hr1_cd > 0.0) OR (((hr2_cd > 0.0) OR (((hr3_cd > 0.0) OR (hr4_cd > 0.0)) )) )) )
  SET midpoint = 75
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=temp3->person_id)
     AND ce.event_cd IN (hr1_cd, hr2_cd, hr3_cd, hr4_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_res = 0.0, temp_diff = 0.0,
    hold_diff = - (1.0), isnum = 0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_res = cnvtreal(ce.event_tag), temp_diff = abs((temp_res - midpoint))
     IF (((temp_diff > hold_diff) OR (ce_id=0)) )
      hold_diff = temp_diff, event_tag_num = temp_res, ce_id = ce.clinical_event_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (event_tag_num > 0)
   SET temp4->dlist[x].heartrate = event_tag_num
   SET temp4->dlist[x].heartrate_ce_id = ce_id
  ENDIF
 ENDIF
#worst_heartrate_exit
#worst_meanbp
 SET event_tag_num = - (1.0)
 SET temp_sys = 0.0
 SET temp_dia = 0.0
 SET midpoint = 0.0
 SET temp_meanbp = 0.0
 SET hold_meanbp = 0.0
 SET systolic1_cd = 0.0
 SET diastolic1_cd = 0.0
 SET systolic2_cd = 0.0
 SET diastolic2_cd = 0.0
 SET systolic1_cd = uar_get_code_by_cki("CKI.EC!75")
 SET diastolic1_cd = uar_get_code_by_cki("CKI.EC!26")
 SET systolic2_cd = uar_get_code_by_cki("CKI.EC!7680")
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
    WHERE (ce.person_id=temp3->person_id)
     AND ((ce.event_cd=systolic1_cd) OR (((ce.event_cd=diastolic1_cd) OR (((ce.event_cd=systolic2_cd)
     OR (((ce.event_cd=diastolic2_cd) OR (((ce.event_cd=systolic3_cd) OR (((ce.event_cd=diastolic3_cd
    ) OR (ce.event_cd=diastolic4_cd)) )) )) )) )) ))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_sys = 0.0, temp_dia = 0.0,
    temp_diff = 0.0, hold_diff = - (1.0), isnum = 0
   HEAD ce.event_end_dt_tm
    temp_sys = 0.0, temp_dia = 0.0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     IF (ce.event_cd IN (systolic1_cd, systolic2_cd, systolic3_cd))
      temp_sys = cnvtreal(ce.event_tag)
     ELSE
      temp_dia = cnvtreal(ce.event_tag)
     ENDIF
    ENDIF
   FOOT  ce.event_end_dt_tm
    IF (temp_sys > 0
     AND temp_dia > 0)
     temp_meanbp = (((temp_dia * 2)+ temp_sys)/ 3), temp_diff = abs((temp_meanbp - midpoint))
     IF (((temp_diff > hold_diff) OR (event_tag_num=0)) )
      hold_diff = temp_diff, event_tag_num = temp_meanbp
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (event_tag_num > 0)
   SET temp4->dlist[x].meanbp = event_tag_num
  ENDIF
 ENDIF
#worst_meanbp_exit
#3400_urine
 SET urine_total = - (1)
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
  GO TO 3499_urine_exit
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=temp3->person_id)
    AND ((ce.event_cd=urine1_cd) OR (((ce.event_cd=urine2_cd) OR (ce.event_cd=urine3_cd)) ))
    AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != inerror_cd)
  ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
  HEAD REPORT
   hold_tag = 0.0, temp_tag = 0.0, isnum = 0
  DETAIL
   isnum = isnumeric(ce.event_tag)
   IF (isnum > 0)
    temp_tag = cnvtreal(ce.event_tag), hold_tag = (hold_tag+ temp_tag)
   ENDIF
  WITH nocounter
 ;end select
 SET d2 = abs(datetimediff(search_beg_dt_tm,search_end_dt_tm,3))
 IF (hold_tag > 0)
  SET event_tag_num = ((hold_tag/ (d2+ 0.01667)) * 24)
  SET temp4->dlist[x].urine = round(hold_tag,0)
  SET temp4->dlist[x].urine_24hr = round(event_tag_num,0)
 ELSE
  SET temp4->dlist[x].urine = - (1)
  SET temp4->dlist[x].urine_24hr = - (1)
 ENDIF
#3499_urine_exit
#worst_abg
 SET hold_pao2 = 0.0
 SET hold_pco2 = 0.0
 SET hold_fio2 = 0.0
 SET hold_ph = 0.0
 SET hold_intub = - (1.0)
 SET temp_pao2 = 0.0
 SET temp_pco2 = 0.0
 SET temp_fio2 = 0.0
 SET temp_ph = 0.0
 SET temp_intub = - (1.0)
 SET hold_pao2_ce_id = 0.0
 SET hold_pco2_ce_id = 0.0
 SET hold_fio2_ce_id = 0.0
 SET hold_ph_ce_id = 0.0
 SET hold_intubated_ce_id = 0.0
 SET temp_pao2_ce_id = 0.0
 SET temp_pco2_ce_id = 0.0
 SET temp_fio2_ce_id = 0.0
 SET temp_ph_ce_id = 0.0
 SET temp_intubated_ce_id = 0.0
 SET temp_weight = - (1)
 SET hold_weight = - (1)
 SET pao2_weight = 0.0
 SET aado2_weight = 0.0
 SET aado2 = 0.0
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
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=temp3->person_id)
     AND ((ce.event_cd=pao2_cd) OR (((ce.event_cd=pco2_cd) OR (((ce.event_cd=fio2_cd) OR (((ce
    .event_cd=ph_cd) OR (((ce.event_cd=intub_cd) OR (ce.event_cd=intub2_cd)) )) )) )) ))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_pao2 = - (1.0), hold_pco2 = - (1.0), hold_fio2 = - (1.0),
    hold_ph = - (1.0), hold_intub = - (1.0), hold_intubated_ce_id = 0.0,
    hold_pao2_ce_id = 0.0, hold_pco2_ce_id = 0.0, hold_fio2_ce_id = 0.0,
    hold_ph_ce_id = 0.0, temp_pao2 = 0.0, temp_pco2 = 0.0,
    temp_fio2 = 0.0, temp_ph = 0.0, temp_intub = - (1.0),
    temp_intubated_ce_id = 0.0, temp_pao2_ce_id = 0.0, temp_pco2_ce_id = 0.0,
    temp_fio2_ce_id = 0.0, temp_ph_ce_id = 0.0, isnum = 0
   HEAD ce.event_end_dt_tm
    temp_pao2 = 0.0, temp_pco2 = 0.0, temp_fio2 = 0.0,
    temp_ph = 0.0, temp_intub = - (1.0), temp_intubated_ce_id = 0.0,
    temp_pao2_ce_id = 0.0, temp_pco2_ce_id = 0.0, temp_fio2_ce_id = 0.0,
    temp_ph_ce_id = 0.0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (ce.event_cd IN (intub_cd, intub2_cd))
     isnum = 1, temp_intubated_ce_id = ce.clinical_event_id
    ENDIF
    IF (ce.event_cd=fio2_cd)
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
     ELSEIF (ce.event_cd=intub2_cd)
      IF (cnvtupper(ce.event_tag)="Y")
       temp_intub = 1
      ELSE
       IF (temp_intub < 0)
        temp_intub = 0
       ENDIF
      ENDIF
     ELSEIF (ce.event_cd=intub_cd)
      CALL echo("Recognizing event_cd as intub_cd")
      IF (cnvtupper(ce.event_tag) IN ("ENDOTRACHEAL", "ENDOBRONCHIAL", "TRACHEOSTOMY"))
       temp_intub = 1
      ELSE
       IF (temp_intub < 0)
        temp_intub = 0
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   FOOT  ce.event_end_dt_tm
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
     ELSE
      aado2 = (((temp_fio2 * 7.13) - temp_pao2) - temp_pco2)
      IF (aado2 < 100)
       temp_weight = 0
      ELSEIF (aado2 < 250)
       temp_weight = 7
      ELSEIF (aado2 < 350)
       temp_weight = 9
      ELSEIF (aado2 < 500)
       temp_weight = 11
      ELSE
       temp_weight = 14
      ENDIF
     ENDIF
     IF (temp_weight > hold_weight)
      hold_weight = temp_weight, hold_pao2 = temp_pao2, hold_pco2 = temp_pco2,
      hold_fio2 = temp_fio2, hold_ph = temp_ph, hold_intub = temp_intub,
      hold_intubated_ce_id = temp_intubated_ce_id, hold_pao2_ce_id = temp_pao2_ce_id, hold_pco2_ce_id
       = temp_pco2_ce_id,
      hold_fio2_ce_id = temp_fio2_ce_id, hold_ph_ce_id = temp_ph_ce_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF ((hold_weight > - (1)))
   SET temp4->dlist[x].intubated_ind = hold_intub
   SET temp4->dlist[x].pao2 = hold_pao2
   SET temp4->dlist[x].pco2 = hold_pco2
   SET temp4->dlist[x].fio2 = hold_fio2
   SET temp4->dlist[x].ph = hold_ph
   SET temp4->dlist[x].intubated_ce_id = hold_intubated_ce_id
   SET temp4->dlist[x].pao2_ce_id = hold_pao2_ce_id
   SET temp4->dlist[x].pco2_ce_id = hold_pco2_ce_id
   SET temp4->dlist[x].fio2_ce_id = hold_fio2_ce_id
   SET temp4->dlist[x].ph_ce_id = hold_ph_ce_id
   CALL echo(build("hold_intubated_ce_id = ",temp4->dlist[x].intubated_ce_id))
   CALL echo(build("hold_pao2_ce_id = ",temp4->dlist[x].pao2_ce_id))
   CALL echo(build("hold_pco2_ce_id = ",temp4->dlist[x].pco2_ce_id))
   CALL echo(build("hold_fio2_ce_id = ",temp4->dlist[x].fio2_ce_id))
   CALL echo(build("hold_ph_ce_id = ",temp4->dlist[x].ph_ce_id))
   SET found_new_worst = 1
  ENDIF
 ELSE
  CALL echo("The zero value below is a missing CKI.")
  CALL echo(build("pao2_cd=",pao2_cd," pco2_cd=",pco2_cd," fio2_cd=",
    fio2_cd," ph_cd",ph_cd," intub_cd=",intub_cd,
    " intub2_cd=",intub2_cd))
 ENDIF
#worst_abg_exit
#3500_aps
 SET aps_variable->sintubated = - (1)
 SET aps_variable->svent = - (1)
 SET aps_variable->sdialysis = - (1)
 SET aps_variable->seyes = - (1)
 SET aps_variable->smotor = - (1)
 SET aps_variable->sverbal = - (1)
 SET aps_variable->smeds = - (1)
 SET aps_variable->dwurine = - (1)
 SET aps_variable->dwwbc = - (1)
 SET aps_variable->dwtemp = - (1)
 SET aps_variable->dwrespiratoryrate = - (1)
 SET aps_variable->dwsodium = - (1)
 SET aps_variable->dwheartrate = - (1)
 SET aps_variable->dwmeanbp = - (1)
 SET aps_variable->dwph = - (1)
 SET aps_variable->dwhematocrit = - (1)
 SET aps_variable->dwcreatinine = - (1)
 SET aps_variable->dwalbumin = - (1)
 SET aps_variable->dwpao2 = - (1)
 SET aps_variable->dwpco2 = - (1)
 SET aps_variable->dwbun = - (1)
 SET aps_variable->dwglucose = - (1)
 SET aps_variable->dwbilirubin = - (1)
 SET aps_variable->dwfio2 = - (1)
 SET tmp_size = size(temp4->dlist,5)
 CALL echo(build("dlist array size = ",tmp_size," while x = ",x))
 IF ((temp4->dlist[x].intubated_ind >= 0))
  SET aps_variable->sintubated = temp4->dlist[x].intubated_ind
 ENDIF
 IF ((temp4->dlist[x].vent_ind >= 0))
  SET aps_variable->svent = temp4->dlist[x].vent_ind
 ENDIF
 IF (temp3->dialysis_ind)
  SET aps_variable->sdialysis = temp3->dialysis_ind
 ENDIF
 IF ((temp4->dlist[x].eyes >= 0))
  SET aps_variable->seyes = temp4->dlist[x].eyes
 ENDIF
 IF ((temp4->dlist[x].motor >= 0))
  SET aps_variable->smotor = temp4->dlist[x].motor
 ENDIF
 IF ((temp4->dlist[x].verbal >= 0))
  SET aps_variable->sverbal = temp4->dlist[x].verbal
 ENDIF
 IF ((temp4->dlist[x].meds_ind >= 0))
  SET aps_variable->smeds = temp4->dlist[x].meds_ind
 ENDIF
 IF ((temp4->dlist[x].urine_24hr >= 0))
  SET aps_variable->dwurine = temp4->dlist[x].urine_24hr
 ENDIF
 IF ((temp4->dlist[x].wbc > 0))
  SET aps_variable->dwwbc = temp4->dlist[x].wbc
 ENDIF
 IF ((temp4->dlist[x].temp < 50))
  SET aps_variable->dwtemp = temp4->dlist[x].temp
 ELSE
  SET aps_variable->dwtemp = (((temp4->dlist[x].temp - 32) * 5)/ 9)
 ENDIF
 IF ((temp4->dlist[x].resp > 0))
  SET aps_variable->dwrespiratoryrate = temp4->dlist[x].resp
 ENDIF
 IF ((temp4->dlist[x].sodium > 0))
  SET aps_variable->dwsodium = temp4->dlist[x].sodium
 ENDIF
 IF ((temp4->dlist[x].heartrate > 0))
  SET aps_variable->dwheartrate = temp4->dlist[x].heartrate
 ENDIF
 IF ((temp4->dlist[x].meanbp > 0))
  SET aps_variable->dwmeanbp = temp4->dlist[x].meanbp
 ENDIF
 IF ((temp4->dlist[x].ph > 0))
  SET aps_variable->dwph = temp4->dlist[x].ph
 ENDIF
 IF ((temp4->dlist[x].hematocrit > 0))
  SET aps_variable->dwhematocrit = temp4->dlist[x].hematocrit
 ENDIF
 IF ((temp4->dlist[x].creatinine > 0))
  SET aps_variable->dwcreatinine = temp4->dlist[x].creatinine
 ENDIF
 IF ((temp4->dlist[x].albumin > 0))
  SET aps_variable->dwalbumin = temp4->dlist[x].albumin
 ENDIF
 IF ((temp4->dlist[x].pao2 > 0))
  SET aps_variable->dwpao2 = temp4->dlist[x].pao2
 ENDIF
 IF ((temp4->dlist[x].pco2 > 0))
  SET aps_variable->dwpco2 = temp4->dlist[x].pco2
 ENDIF
 IF ((temp4->dlist[x].bun > 0))
  SET aps_variable->dwbun = temp4->dlist[x].bun
 ENDIF
 IF ((temp4->dlist[x].glucose > 0))
  SET aps_variable->dwglucose = temp4->dlist[x].glucose
 ENDIF
 IF ((temp4->dlist[x].bilirubin > 0))
  SET aps_variable->dwbilirubin = temp4->dlist[x].bilirubin
 ENDIF
 IF ((temp4->dlist[x].fio2 > 0))
  SET aps_variable->dwfio2 = temp4->dlist[x].fio2
 ENDIF
 EXECUTE FROM 5000_get_carry_over TO 5099_get_carry_over_exit
 IF ((aps_variable->svent < 0))
  SET status = - (22003)
 ELSEIF ((temp3->age < 16))
  SET status = - (23103)
 ELSE
  SET status = uar_amsapscalculate(aps_variable)
 ENDIF
 SET temp4->dlist[x].outcome_status = status
 IF (status < 0)
  SET temp4->dlist[x].aps_score = - (1)
  IF (x=1)
   SET temp4->dlist[x].aps_day1 = - (1)
   SET temp4->dlist[x].aps_yesterday = - (1)
  ENDIF
 ELSE
  SET temp4->dlist[x].aps_score = status
  IF (x=1)
   SET temp4->dlist[x].aps_day1 = temp4->dlist[x].aps_score
   SET temp4->dlist[x].aps_yesterday = 0
  ELSE
   SET day_one_found = "N"
   SET yesterday_found = "N"
   IF ((temp4->dlist[1].cc_day=1)
    AND (temp4->dlist[1].outcome_status >= 0))
    SET temp4->dlist[x].aps_day1 = temp4->dlist[1].aps_score
    SET day_one_found = "Y"
    SET day1meds = temp4->dlist[1].meds_ind
    SET day1verbal = temp4->dlist[1].verbal
    SET day1motor = temp4->dlist[1].motor
    SET day1eyes = temp4->dlist[1].eyes
    SET day1pao2 = temp4->dlist[1].pao2
    SET day1fio2 = temp4->dlist[1].fio2
   ENDIF
   IF (((temp4->dlist[(x - 1)].cc_day+ 1)=temp4->dlist[x].cc_day)
    AND (temp4->dlist[(x - 1)].outcome_status >= 0))
    SET temp4->dlist[x].aps_yesterday = temp4->dlist[(x - 1)].aps_score
    SET yesterday_found = "Y"
   ENDIF
   IF (((day_one_found="N") OR (yesterday_found="N")) )
    SET temp4->dlist[x].outcome_status = - (1)
   ENDIF
  ENDIF
 ENDIF
#3599_aps_exit
#3600_outcomes
 SET aps_prediction->sicuday = temp4->dlist[x].cc_day
 SET aps_prediction->saps3day1 = temp4->dlist[x].aps_day1
 SET aps_prediction->saps3today = temp4->dlist[x].aps_score
 SET aps_prediction->saps3yesterday = temp4->dlist[x].aps_yesterday
 SET aps_prediction->sgender = temp3->gender
 SET aps_prediction->steachtype = temp3->teach_type_flag
 SET aps_prediction->sregion = temp3->region_flag
 SET aps_prediction->sbedcount = temp3->bedcount
 IF ((temp3->admit_source IN ("CHPAIN_CTR", "ICU", "ICU_TO_OR")))
  SET aps_prediction->sadmitsource = 5
 ELSEIF ((temp3->admit_source="OR"))
  SET aps_prediction->sadmitsource = 1
 ELSEIF ((temp3->admit_source="RR"))
  SET aps_prediction->sadmitsource = 2
 ELSEIF ((temp3->admit_source="ER"))
  SET aps_prediction->sadmitsource = 3
 ELSEIF ((temp3->admit_source="FLOOR"))
  SET aps_prediction->sadmitsource = 4
 ELSEIF ((temp3->admit_source="OTHER_HOSP"))
  SET aps_prediction->sadmitsource = 6
 ELSEIF ((temp3->admit_source="DIR_ADMIT"))
  SET aps_prediction->sadmitsource = 7
 ELSEIF ((temp3->admit_source IN ("SDU", "ICU_TO_SDU")))
  SET aps_prediction->sadmitsource = 8
 ENDIF
 SET aps_prediction->sgraftcount = temp3->nbr_grafts_performed
 SET aps_prediction->smeds = temp4->dlist[x].meds_ind
 SET aps_prediction->sverbal = temp4->dlist[x].verbal
 SET aps_prediction->smotor = temp4->dlist[x].motor
 SET aps_prediction->seyes = temp4->dlist[x].eyes
 SET aps_prediction->sage = temp3->age
 SET abc = fillstring(20," ")
 IF ((request->admit_time_chg_ind=1))
  SET abc = format(request->new_icu_admit_dt_tm,"mm/dd/yyyy;;d")
 ELSE
  SET abc = format(temp3->icu_admit_dt_tm,"mm/dd/yyyy;;d")
 ENDIF
 SET aps_prediction->szicuadmitdate = concat(trim(abc),char(0))
 SET abc = fillstring(20," ")
 SET abc = format(temp3->hosp_admit_dt_tm,"mm/dd/yyyy;;d")
 SET aps_prediction->szhospadmitdate = concat(trim(abc),char(0))
 SET aps_prediction->szadmitdiagnosis = concat(trim(temp3->admitdiagnosis),char(0))
 SET aps_prediction->bthrombolytics = temp3->thrombolytics_ind
 SET aps_prediction->bdiedinhospital = temp3->diedinhospital_ind
 SET aps_prediction->baids = temp3->aids_ind
 SET aps_prediction->bhepaticfailure = temp3->hepaticfailure_ind
 SET aps_prediction->blymphoma = temp3->lymphoma_ind
 SET aps_prediction->bmetastaticcancer = temp3->metastaticcancer_ind
 SET aps_prediction->bleukemia = temp3->leukemia_ind
 SET aps_prediction->bimmunosuppression = temp3->immunosuppression_ind
 SET aps_prediction->bcirrhosis = temp3->cirrhosis_ind
 IF ((temp3->aids_ind=0)
  AND (temp3->hepaticfailure_ind=0)
  AND (temp3->lymphoma_ind=0)
  AND (temp3->metastaticcancer_ind=0)
  AND (temp3->leukemia_ind=0)
  AND (temp3->immunosuppression_ind=0)
  AND (temp3->cirrhosis_ind=0)
  AND (temp3->diabetes_ind=0)
  AND (temp3->copd_ind=0)
  AND (temp3->chronic_health_unavail_ind=0)
  AND (temp3->chronic_health_none_ind=0))
  SET aps_prediction->baids = - (1)
  SET aps_prediction->bhepaticfailure = - (1)
  SET aps_prediction->blymphoma = - (1)
  SET aps_prediction->bmetastaticcancer = - (1)
  SET aps_prediction->bleukemia = - (1)
  SET aps_prediction->bimmunosuppression = - (1)
  SET aps_prediction->bcirrhosis = - (1)
 ENDIF
 SET aps_prediction->belectivesurgery = temp3->electivesurgery_ind
 SET aps_prediction->bactivetx = temp4->dlist[x].activetx_ind
 SET aps_prediction->breadmit = temp3->readmit_ind
 SET aps_prediction->bima = temp3->ima_ind
 SET aps_prediction->bmidur = temp3->midur_ind
 SET aps_prediction->bventday1 = temp3->ventday1_ind
 SET aps_prediction->boobventday1 = maxval(temp3->oobventday1_ind,temp3->ventday1_ind)
 SET aps_prediction->boobintubday1 = temp3->oobintubday1_ind
 SET aps_prediction->bdiabetes = temp3->diabetes_ind
 SET aps_prediction->bmanagementsystem = 1
 SET aps_prediction->dwvar03hspxlos = temp3->var03hspxlos
 SET aps_prediction->dwpao2 = temp4->dlist[x].pao2
 SET aps_prediction->dwfio2 = temp4->dlist[x].fio2
 SET aps_prediction->dwejectfx = temp3->ejectfx
 SET aps_prediction->dwcreatinine = temp4->dlist[x].creatinine
 IF (discharge_location_display="FLOOR")
  SET aps_prediction->sdischargelocation = 4
 ELSEIF (discharge_location_display="ICU_TRANSFER")
  SET aps_prediction->sdischargelocation = 5
 ELSEIF (discharge_location_display="OTHER_HOSP")
  SET aps_prediction->sdischargelocation = 6
 ELSEIF (discharge_location_display="HOME")
  SET aps_prediction->sdischargelocation = 7
 ELSEIF (discharge_location_display="OTHER")
  SET aps_prediction->sdischargelocation = 8
 ELSEIF (discharge_location_display="DEATH")
  SET aps_prediction->sdischargelocation = 9
 ELSE
  SET aps_prediction->sdischargelocation = - (1)
 ENDIF
 SET aps_prediction->svisitnumber = get_visit_reply->visit_number
 IF ((temp3->ami_location="ANT"))
  SET aps_prediction->samilocation = 1
 ELSEIF ((temp3->ami_location="ANTLAT"))
  SET aps_prediction->samilocation = 2
 ELSEIF ((temp3->ami_location="ANTSEP"))
  SET aps_prediction->samilocation = 3
 ELSEIF ((temp3->ami_location="INF"))
  SET aps_prediction->samilocation = 4
 ELSEIF ((temp3->ami_location="LAT"))
  SET aps_prediction->samilocation = 5
 ELSEIF ((temp3->ami_location="NONQ"))
  SET aps_prediction->samilocation = 6
 ELSEIF ((temp3->ami_location="POST"))
  SET aps_prediction->samilocation = 7
 ELSE
  SET aps_prediction->samilocation = - (1)
 ENDIF
 SET abc = fillstring(20," ")
 SET abc = format(temp3->icu_admit_dt_tm,"mm/dd/yyyy hh:mm;;d")
 SET aps_prediction->szicuadmitdatetime = concat(trim(abc),char(0))
 SET abc = fillstring(20," ")
 SET abc = format(temp3->hosp_admit_dt_tm,"mm/dd/yyyy hh:mm;;d")
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
 SET temp4->dlist[x].outcome_status = status
#3699_outcomes_exit
#3700_create_rad
 SET rad_id = 0.0
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   rad_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 IF (rad_id=0.0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error reading from carenet sequence, write new risk_adjustment_day row."
  SET success_flag = "N"
 ELSE
  IF ((temp4->dlist[x].aps_score >= 0)
   AND (temp4->dlist[x].phys_res_pts >= 0))
   SET ap3_score = value((temp4->dlist[x].aps_score+ temp4->dlist[x].phys_res_pts))
  ELSE
   SET ap3_score = - (1)
  ENDIF
  SET temp3->risk_adjustment_id = ra_id
  SET temp4->dlist[x].risk_adjustment_id = ra_id
  SET temp4->dlist[x].risk_adjustment_day_id = rad_id
  CALL echo("about to insert into RAD")
  CALL echo(build("temp4->dlist[x].cc_end_dt_tm=",format(temp4->dlist[x].cc_end_dt_tm,"@LONGDATETIME"
     )))
  INSERT  FROM risk_adjustment_day rad
   SET rad.risk_adjustment_day_id = rad_id, rad.risk_adjustment_id = ra_id, rad.cc_day = temp4->
    dlist[x].cc_day,
    rad.cc_beg_dt_tm = cnvtdatetime(temp4->dlist[x].cc_beg_dt_tm), rad.cc_end_dt_tm = cnvtdatetime(
     temp4->dlist[x].cc_end_dt_tm), rad.valid_from_dt_tm = cnvtdatetime(curdate,curtime3),
    rad.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), rad.intubated_ind = temp4->dlist[x]
    .intubated_ind, rad.intubated_ce_id = temp4->dlist[x].intubated_ce_id,
    rad.vent_ind = temp4->dlist[x].vent_ind, rad.worst_gcs_eye_score = temp4->dlist[x].eyes, rad
    .eyes_ce_id = temp4->dlist[x].eyes_ce_id,
    rad.worst_gcs_motor_score = temp4->dlist[x].motor, rad.motor_ce_id = temp4->dlist[x].motor_ce_id,
    rad.worst_gcs_verbal_score = temp4->dlist[x].verbal,
    rad.verbal_ce_id = temp4->dlist[x].verbal_ce_id, rad.meds_ind = temp4->dlist[x].meds_ind, rad
    .meds_ce_id = temp4->dlist[x].meds_ce_id,
    rad.urine_output = temp4->dlist[x].urine, rad.urine_24hr_output = temp4->dlist[x].urine_24hr, rad
    .worst_wbc_result = temp4->dlist[x].wbc,
    rad.wbc_ce_id = temp4->dlist[x].wbc_ce_id, rad.worst_temp = temp4->dlist[x].temp, rad.temp_ce_id
     = temp4->dlist[x].temp_ce_id,
    rad.worst_resp_result = temp4->dlist[x].resp, rad.resp_ce_id = temp4->dlist[x].resp_ce_id, rad
    .worst_sodium_result = temp4->dlist[x].sodium,
    rad.sodium_ce_id = temp4->dlist[x].sodium_ce_id, rad.worst_heart_rate = temp4->dlist[x].heartrate,
    rad.heartrate_ce_id = temp4->dlist[x].heartrate_ce_id,
    rad.mean_blood_pressure = temp4->dlist[x].meanbp, rad.worst_ph_result = temp4->dlist[x].ph, rad
    .ph_ce_id = temp4->dlist[x].ph_ce_id,
    rad.worst_hematocrit = temp4->dlist[x].hematocrit, rad.hematocrit_ce_id = temp4->dlist[x].
    hematocrit_ce_id, rad.worst_creatinine_result = temp4->dlist[x].creatinine,
    rad.creatinine_ce_id = temp4->dlist[x].creatinine_ce_id, rad.worst_albumin_result = temp4->dlist[
    x].albumin, rad.albumin_ce_id = temp4->dlist[x].albumin_ce_id,
    rad.worst_pao2_result = temp4->dlist[x].pao2, rad.pao2_ce_id = temp4->dlist[x].pao2_ce_id, rad
    .worst_pco2_result = temp4->dlist[x].pco2,
    rad.pco2_ce_id = temp4->dlist[x].pco2_ce_id, rad.worst_bun_result = temp4->dlist[x].bun, rad
    .bun_ce_id = temp4->dlist[x].bun_ce_id,
    rad.worst_glucose_result = temp4->dlist[x].glucose, rad.glucose_ce_id = temp4->dlist[x].
    glucose_ce_id, rad.worst_bilirubin_result = temp4->dlist[x].bilirubin,
    rad.bilirubin_ce_id = temp4->dlist[x].bilirubin_ce_id, rad.worst_potassium_result = temp4->dlist[
    x].potassium, rad.potassium_ce_id = temp4->dlist[x].potassium_ce_id,
    rad.worst_fio2_result = temp4->dlist[x].fio2, rad.fio2_ce_id = temp4->dlist[x].fio2_ce_id, rad
    .aps_score = temp4->dlist[x].aps_score,
    rad.aps_day1 = temp4->dlist[x].aps_day1, rad.aps_yesterday = temp4->dlist[x].aps_yesterday, rad
    .activetx_ind = temp4->dlist[x].activetx_ind,
    rad.vent_today_ind = temp4->dlist[x].vent_today_ind, rad.pa_line_today_ind = temp4->dlist[x].
    pa_line_today_ind, rad.outcome_status = temp4->dlist[x].outcome_status,
    rad.apache_iii_score = ap3_score, rad.phys_res_pts = value(temp4->dlist[x].phys_res_pts), rad
    .active_ind = 1,
    rad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rad.active_status_prsnl_id = reqinfo->
    updt_id, rad.active_status_cd = reqdata->active_status_cd,
    rad.updt_dt_tm = cnvtdatetime(curdate,curtime3), rad.updt_id = reqinfo->updt_id, rad.updt_task =
    reqinfo->updt_task,
    rad.updt_applctx = reqinfo->updt_applctx, rad.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error writing new risk_adjustment_day row."
   SET success_flag = "N"
  ELSE
   IF ((request->admit_time_chg_ind=1))
    IF ((temp4->dlist[x].outcome_status > 0))
     FOR (num = 1 TO 100)
       IF ((aps_outcome->qual[num].szequationname > " "))
        SET v_equation_name = trim(aps_outcome->qual[num].szequationname)
        IF ((temp4->dlist[x].cc_day=1))
         SET act_icu_ever = - (1)
         IF (v_equation_name="ACT_ICU_EVER")
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
        INSERT  FROM risk_adjustment_outcomes rao
         SET rao.risk_adjustment_outcomes_id = rao_id, rao.risk_adjustment_day_id = rad_id, rao
          .equation_name = trim(v_equation_name),
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
        IF (curqual=0)
         SET reply->status_data.subeventstatus[1].targetobjectvalue =
         "Error writing new risk_adjustment_outcomes row."
         SET success_flag = "N"
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    FOR (y = 1 TO temp4->dlist[x].ocnt)
      SET v_equation_name = trim(temp4->dlist[x].olist[y].equation_name)
      IF ((temp4->dlist[x].cc_day=1))
       SET act_icu_ever = - (1)
       IF (v_equation_name="ACT_ICU_EVER")
        SET act_icu_ever = temp4->dlist[x].olist[y].outcome
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
      INSERT  FROM risk_adjustment_outcomes rao
       SET rao.risk_adjustment_outcomes_id = rao_id, rao.risk_adjustment_day_id = rad_id, rao
        .equation_name = trim(temp4->dlist[x].olist[y].equation_name),
        rao.outcome_value = temp4->dlist[x].olist[y].outcome, rao.valid_from_dt_tm = cnvtdatetime(
         curdate,curtime3), rao.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
        rao.active_ind = 1, rao.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rao
        .active_status_prsnl_id = reqinfo->updt_id,
        rao.active_status_cd = reqdata->active_status_cd, rao.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), rao.updt_id = reqinfo->updt_id,
        rao.updt_task = reqinfo->updt_task, rao.updt_applctx = reqinfo->updt_applctx, rao.updt_cnt =
        0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Error writing new risk_adjustment_outcomes row."
       SET success_flag = "N"
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
#3799_create_rad_exit
#3900_determine_dc_day
 SET old_dc_cc_day = 0
 SET new_dc_cc_day = 0
 FOR (x = 1 TO temp->day_cnt)
   IF ((request->new_icu_disch_dt_tm >= cnvtdatetime(temp->cc_day[x].beg_dt_tm))
    AND (request->new_icu_disch_dt_tm <= cnvtdatetime(temp->cc_day[x].end_dt_tm)))
    SET new_dc_cc_day = x
    SET x = temp->day_cnt
   ENDIF
 ENDFOR
 IF (new_dc_cc_day=0
  AND (request->new_icu_disch_dt_tm >= cnvtdatetime((curdate+ 1),0)))
  SET new_dc_cc_day = 9999
 ENDIF
 FOR (x = 1 TO temp->day_cnt)
   IF ((temp3->icu_disch_dt_tm >= cnvtdatetime(temp->cc_day[x].beg_dt_tm))
    AND (temp3->icu_disch_dt_tm <= cnvtdatetime(temp->cc_day[x].end_dt_tm)))
    SET old_dc_cc_day = x
    SET x = temp->day_cnt
   ENDIF
 ENDFOR
 IF (old_dc_cc_day=0
  AND (temp3->icu_disch_dt_tm >= cnvtdatetime((curdate+ 1),0)))
  SET old_dc_cc_day = 9999
 ENDIF
#3999_determine_dc_day_exit
#4000_disch
 SET temp3->icu_disch_dt_tm = cnvtdatetime(request->new_icu_disch_dt_tm)
 IF (old_dc_cc_day=9999)
  UPDATE  FROM risk_adjustment ra
   SET ra.icu_disch_dt_tm = cnvtdatetime(temp3->icu_disch_dt_tm), ra.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), ra.updt_task = reqinfo->updt_task,
    ra.updt_applctx = reqinfo->updt_applctx, ra.updt_id = reqinfo->updt_id, ra.updt_cnt = (ra
    .updt_cnt+ 1)
   WHERE (ra.risk_adjustment_id=request->risk_adjustment_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET success_flag = "N"
   SET fail_string = "Unable to update dc date on risk_adjustment table."
  ELSE
   SET success_flag = "Y"
   SET ra_id = request->risk_adjustment_id
  ENDIF
 ELSE
  EXECUTE FROM 3000_update_ra TO 3099_update_ra_exit
 ENDIF
 IF (success_flag="Y")
  SET day_cnt = 0
  EXECUTE FROM load_rad_days TO load_rad_days_exit
  IF (day_cnt > 0)
   EXECUTE FROM load_rao TO load_rao_exit
   EXECUTE FROM upd_rao_rad TO upd_rao_rad_exit
   EXECUTE FROM upd_tiss TO upd_tiss_exit
   SET success_flag = "Y"
   FOR (x = 1 TO day_cnt)
     EXECUTE FROM 4100_rad TO 4199_rad_exit
     CALL echo(build("after 4100 success_flag = ",success_flag))
     IF (success_flag="N")
      SET x = day_cnt
     ENDIF
   ENDFOR
  ENDIF
  IF (success_flag="Y")
   SET reply->risk_adjustment_id = ra_id
   SET reqinfo->commit_ind = 1
   SET reply->status_data.status = "S"
  ELSE
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
  ENDIF
 ELSE
  SET reply->status_data.subeventstatus[1].targetobjectvalue = fail_string
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 SET x = new_dc_cc_day
 IF (new_dc_cc_day <= day_cnt)
  EXECUTE FROM 3500_aps TO 3599_aps_exit
  IF ((temp3->age < 16))
   SET temp4->dlist[x].outcome_status = - (23103)
  ELSE
   IF ((temp4->dlist[x].outcome_status >= 0))
    EXECUTE FROM 3600_outcomes TO 3699_outcomes_exit
   ENDIF
  ENDIF
  SET request->admit_time_chg_ind = 1
  SET x = day_cnt
  UPDATE  FROM risk_adjustment_outcomes rao
   SET rao.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rao.active_ind = 0, rao
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    rao.updt_dt_tm = cnvtdatetime(curdate,curtime3), rao.updt_task = reqinfo->updt_task, rao
    .updt_applctx = reqinfo->updt_applctx,
    rao.updt_id = reqinfo->updt_id, rao.updt_cnt = (rao.updt_cnt+ 1)
   WHERE (rao.risk_adjustment_day_id=temp4->dlist[x].risk_adjustment_day_id)
   WITH nocounter
  ;end update
  UPDATE  FROM risk_adjustment_day rad
   SET rad.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rad.active_ind = 0, rad
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    rad.updt_dt_tm = cnvtdatetime(curdate,curtime3), rad.updt_task = reqinfo->updt_task, rad
    .updt_applctx = reqinfo->updt_applctx,
    rad.updt_id = reqinfo->updt_id, rad.updt_cnt = (rad.updt_cnt+ 1)
   WHERE rad.risk_adjustment_id=ra_id
    AND rad.cc_day=day_cnt
    AND rad.active_ind=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL echo("inactive failed")
  ELSE
   CALL echo("inactive worked")
  ENDIF
  EXECUTE FROM 3700_create_rad TO 3799_create_rad_exit
 ENDIF
#4099_disch_exit
#load_rao
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = day_cnt),
   risk_adjustment_outcomes rao
  PLAN (d)
   JOIN (rao
   WHERE (rao.risk_adjustment_day_id=temp4->dlist[d.seq].risk_adjustment_day_id)
    AND rao.active_ind=1)
  HEAD d.seq
   ocnt = 0
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(temp4->dlist[d.seq].olist,ocnt), temp4->dlist[d.seq].olist[ocnt
   ].equation_name = trim(rao.equation_name),
   temp4->dlist[d.seq].olist[ocnt].outcome = rao.outcome_value
  FOOT  d.seq
   temp4->dlist[d.seq].ocnt = ocnt
  WITH nocounter
 ;end select
#load_rao_exit
#4100_rad
 IF ((temp4->dlist[x].cc_day < old_dc_cc_day)
  AND (temp4->dlist[x].cc_day < new_dc_cc_day))
  EXECUTE FROM 3700_create_rad TO 3799_create_rad_exit
 ELSEIF ((((temp4->dlist[x].cc_day=new_dc_cc_day)) OR ((temp4->dlist[x].cc_day=old_dc_cc_day))) )
  IF ((temp4->dlist[x].cc_day=new_dc_cc_day))
   SET temp4->dlist[x].cc_end_dt_tm = cnvtdatetime(request->new_icu_disch_dt_tm)
  ELSE
   SET temp4->dlist[x].cc_end_dt_tm = cnvtdatetime(temp->cc_day[old_dc_cc_day].end_dt_tm)
  ENDIF
  SET search_beg_dt_tm = cnvtdatetime(temp4->dlist[x].cc_beg_dt_tm)
  SET search_end_dt_tm = cnvtdatetime(temp4->dlist[x].cc_end_dt_tm)
  EXECUTE FROM 3200_worst_lab TO 3299_worst_lab_exit
  SET search_beg_dt_tm = cnvtdatetime(temp4->dlist[x].cc_beg_dt_tm)
  SET search_end_dt_tm = cnvtdatetime(temp4->dlist[x].cc_end_dt_tm)
  EXECUTE FROM 3300_worst_vitals TO 3399_worst_vitals_exit
  IF (accept_urine_output_ind=0)
   SET search_beg_dt_tm = cnvtdatetime(temp4->dlist[x].cc_beg_dt_tm)
   SET search_end_dt_tm = cnvtdatetime(temp4->dlist[x].cc_end_dt_tm)
   EXECUTE FROM 3400_urine TO 3499_urine_exit
  ELSE
   IF ((temp4->dlist[x].urine=- (1)))
    SET temp4->dlist[x].urine_24hr = - (1)
   ELSE
    SET d2 = abs(datetimediff(cnvtdatetime(temp4->dlist[x].cc_beg_dt_tm),cnvtdatetime(temp4->dlist[x]
       .cc_end_dt_tm),3))
    SET temp4->dlist[x].urine_24hr = round(((temp4->dlist[x].urine/ d2) * 24),0)
   ENDIF
  ENDIF
  EXECUTE FROM 3500_aps TO 3599_aps_exit
  IF ((temp3->age < 16))
   SET temp4->dlist[x].outcome_status = - (23103)
  ELSE
   IF ((temp4->dlist[x].outcome_status >= 0))
    EXECUTE FROM 3600_outcomes TO 3699_outcomes_exit
   ENDIF
  ENDIF
  EXECUTE FROM 3700_create_rad TO 3799_create_rad_exit
 ENDIF
#4199_rad_exit
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
 SET check_cc_day = x
 WHILE (stillneed2find > 0
  AND check_cc_day > 1)
  SET check_cc_day = (check_cc_day - 1)
  SELECT INTO "nl:"
   FROM risk_adjustment_day rad
   PLAN (rad
    WHERE (rad.risk_adjustment_id=temp4->dlist[1].risk_adjustment_id)
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
#5099_get_carry_over_exit
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
