CREATE PROGRAM dcp_apache_ops_scan:dba
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 clist[*]
     2 org_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 risk_adjustment_id = f8
     2 risk_adjustment_id_new = f8
     2 sex_chg_ind = i2
     2 vent_flag_issue_ind = i2
     2 gender = i4
     2 new_gender = i4
     2 age_chg_ind = i2
     2 age = i4
     2 new_age = i4
     2 hosp_admit_dt_tm_chg_ind = i2
     2 hosp_admit_dt_tm = dq8
     2 new_hosp_admit_dt_tm = dq8
     2 icu_admit_dt_tm = dq8
     2 accept_worst_lab_ind = i2
     2 accept_worst_vitals_ind = i2
     2 accept_urine_output_ind = i2
     2 tiss_changed_ind = i2
     2 tiss_1st_day_changed = i2
     2 accept_tiss_acttx_if_ind = i2
     2 accept_tiss_nonacttx_if_ind = i2
     2 auto_calc_intubated_ind = i2
     2 dcnt = i2
     2 dlist[*]
       3 risk_adjustment_day_id = f8
       3 cc_day = i2
       3 clinical_event_id = f8
       3 cc_beg_dt_tm = dq8
       3 cc_end_dt_tm = dq8
       3 event_cd = f8
       3 lab_ind = i2
       3 vital_ind = i2
       3 unset_vent_ind = i2
       3 tiss_ce_ind = i2
       3 temp_ind = i2
       3 urine_ind = i2
       3 worst_resolved_ind = i2
       3 old_worst = f8
       3 old_worst_ce_id = f8
       3 old_vent_ind = i2
       3 new_vent_ind = i2
       3 new_worst = f8
       3 new_worst_ce_id = f8
       3 new_rel_intub = f8
       3 new_rel_intub_ce_id = f8
       3 set_rel_intub_ind = i2
       3 urine_total = f8
       3 urine_24hr = f8
       3 old_abg_weight = f8
       3 old_gcs_score = f8
 )
 RECORD parameters(
   1 risk_adjustment_id = f8
   1 beg_day_dt_tm = dq8
   1 end_day_dt_tm = dq8
   1 org_id = f8
   1 person_id = f8
   1 accept_tiss_acttx_if_ind = i2
   1 accept_tiss_nonacttx_if_ind = i2
   1 found_item = i2
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
   1 therapy_level = i4
   1 disease_category_cd = f8
   1 med_service_cd = f8
   1 admit_icu_cd = f8
   1 discharge_location = vc
   1 visit_number = i2
   1 ami_location = vc
 )
 RECORD temp4(
   1 dlist[*]
     2 risk_adjustment_id = f8
     2 risk_adjustment_day_id = f8
     2 cc_day = i4
     2 cc_beg_dt_tm = dq8
     2 cc_end_dt_tm = dq8
     2 intubated_ind = i2
     2 intub_ce_id = f8
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
 RECORD scan_tiss_list(
   1 list[94]
     2 code_value = f8
     2 tiss_name = vc
     2 tiss_num = i4
     2 ce_cd = f8
     2 acttx_ind = i2
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
 DECLARE check_for_string(p1,p2) = vc
 DECLARE ops_meaning_code(p1,p2) = f8
 DECLARE scan_num = i4 WITH noconstant(0)
 DECLARE status = i4
 DECLARE aps_status = i4
 DECLARE outcome_status = i4
 EXECUTE apachertl
 DECLARE use_map_ind = i2 WITH noconstant(0)
 DECLARE filtered_fio2 = vc
 DECLARE unset_vent_ind = i2 WITH noconstant(0), public
 DECLARE equationname = vc
 DECLARE apache_age(birth_dt_tm,admit_dt_tm) = i2
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
 SET day1meds = - (1)
 SET day1verbal = - (1)
 SET day1motor = - (1)
 SET day1eyes = - (1)
 SET day1pao2 = - (1.0)
 SET day1fio2 = - (1.0)
 SUBROUTINE ops_meaning_code(mc_codeset,mc_meaning)
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
 SET error_flag = "N"
 DECLARE error_string = vc
 SET ccnt = 0
 SET dcnt = 0
 SET one_critical_reg_change = "N"
 DECLARE act_icu_ever = f8
 SET act_icu_ever = - (1)
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad
  PLAN (ra
   WHERE ra.active_ind=1
    AND ra.icu_disch_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.cc_day=1
    AND rad.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->clist,cnt), temp->clist[cnt].risk_adjustment_id = ra
   .risk_adjustment_id,
   temp->clist[cnt].person_id = ra.person_id, temp->clist[cnt].encntr_id = ra.encntr_id, temp->clist[
   cnt].gender = ra.gender_flag,
   temp->clist[cnt].age = ra.admit_age, temp->clist[cnt].icu_admit_dt_tm = cnvtdatetime(ra
    .icu_admit_dt_tm), temp->clist[cnt].hosp_admit_dt_tm = cnvtdatetime(ra.hosp_admit_dt_tm),
   temp->clist[cnt].dcnt = 0
  FOOT REPORT
   ccnt = cnt
  WITH nocounter
 ;end select
 IF (ccnt=0)
  GO TO exit_program
 ENDIF
 SET male_cd = ops_meaning_code(57,"MALE")
 SET female_cd = ops_meaning_code(57,"FEMALE")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ccnt),
   person p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=temp->clist[d.seq].person_id)
    AND p.updt_dt_tm >= cnvtdatetime((curdate - 1),curtime3))
  ORDER BY d.seq
  HEAD d.seq
   new_gender = - (1), new_age = - (1), agex = "            ",
   age_in_mo = 0
  DETAIL
   IF (p.sex_cd=male_cd)
    new_gender = 0
   ELSEIF (p.sex_cd=female_cd)
    new_gender = 1
   ENDIF
   IF ((new_gender != temp->clist[d.seq].gender))
    temp->clist[d.seq].sex_chg_ind = 1, temp->clist[d.seq].new_gender = new_gender,
    one_critical_reg_change = "Y"
   ENDIF
   new_age = apache_age(p.birth_dt_tm,temp->clist[d.seq].hosp_admit_dt_tm)
   IF ((new_age != temp->clist[d.seq].age))
    temp->clist[d.seq].age_chg_ind = 1, temp->clist[d.seq].new_age = new_age, one_critical_reg_change
     = "Y"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ccnt),
   encounter e
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=temp->clist[d.seq].encntr_id)
    AND e.updt_dt_tm >= cnvtdatetime((curdate - 1),curtime3)
    AND e.reg_dt_tm != cnvtdatetime(temp->clist[d.seq].hosp_admit_dt_tm)
    AND e.active_ind=1)
  DETAIL
   temp->clist[d.seq].hosp_admit_dt_tm_chg_ind = 1, temp->clist[d.seq].new_hosp_admit_dt_tm =
   cnvtdatetime(e.reg_dt_tm), one_critical_reg_change = "Y"
  WITH nocounter
 ;end select
 SET accept_worst_lab_ind = 1
 SET accept_worst_vitals_ind = 1
 SET accept_urine_output_ind = 1
 SET accept_tiss_acttx_if_ind = 0
 SET accept_tiss_nonacttx_if_ind = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ccnt),
   encounter e,
   risk_adjustment_ref rar
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=temp->clist[d.seq].encntr_id)
    AND e.active_ind=1)
   JOIN (rar
   WHERE rar.organization_id=e.organization_id
    AND rar.active_ind=1)
  DETAIL
   temp->clist[d.seq].org_id = e.organization_id, temp->clist[d.seq].accept_worst_lab_ind = rar
   .accept_worst_lab_ind, temp->clist[d.seq].accept_worst_vitals_ind = rar.accept_worst_vitals_ind,
   temp->clist[d.seq].accept_urine_output_ind = rar.accept_urine_output_ind, temp->clist[d.seq].
   accept_tiss_acttx_if_ind = rar.accept_tiss_acttx_if_ind, temp->clist[d.seq].
   accept_tiss_nonacttx_if_ind = rar.accept_tiss_nonacttx_if_ind,
   temp->clist[d.seq].auto_calc_intubated_ind = rar.auto_calc_intubated_ind
   IF (rar.accept_worst_lab_ind=0)
    accept_worst_lab_ind = 0
   ENDIF
   IF (rar.accept_worst_vitals_ind=0)
    accept_worst_vitals_ind = 0
   ENDIF
   IF (rar.accept_urine_output_ind=0)
    accept_urine_output_ind = 0
   ENDIF
   IF (rar.accept_tiss_acttx_if_ind=1)
    accept_tiss_acttx_if_ind = 1
   ENDIF
   IF (rar.accept_tiss_nonacttx_if_ind=1)
    accept_tiss_nonacttx_if_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET new_possible_worst = "N"
 IF (accept_worst_lab_ind >= 0)
  SET wbc_cd = uar_get_code_by_cki(nullterm("CKI.EC!4046"))
  SET sodium_cd = uar_get_code_by_cki(nullterm("CKI.EC!3758"))
  SET hematocrit_cd = uar_get_code_by_cki(nullterm("CKI.EC!3404"))
  SET creatinine_cd = uar_get_code_by_cki(nullterm("CKI.EC!3256"))
  SET creatinine2_cd = uar_get_code_by_cki(nullterm("CKI.EC!8226"))
  SET albumin_cd = uar_get_code_by_cki(nullterm("CKI.EC!3025"))
  SET bilirubin_cd = uar_get_code_by_cki(nullterm("CKI.EC!3133"))
  SET potassium_cd = uar_get_code_by_cki(nullterm("CKI.EC!3681"))
  SET bun_cd = uar_get_code_by_cki(nullterm("CKI.EC!3142"))
  SET glucose_cd = uar_get_code_by_cki(nullterm("CKI.EC!3374"))
  SET glucose2_cd = uar_get_code_by_cki(nullterm("CKI.EC!5634"))
  SET glucose3_cd = uar_get_code_by_cki(nullterm("CKI.EC!3375"))
  SET glucose4_cd = uar_get_code_by_cki(nullterm("CKI.EC!3376"))
  SET glucose5_cd = uar_get_code_by_cki(nullterm("CKI.EC!3377"))
  SET glucose6_cd = uar_get_code_by_cki(nullterm("CKI.EC!3378"))
  SET glucose7_cd = uar_get_code_by_cki(nullterm("CKI.EC!3379"))
  SET glucose8_cd = uar_get_code_by_cki(nullterm("CKI.EC!3380"))
  SET glucose9_cd = uar_get_code_by_cki(nullterm("CKI.EC!3386"))
  SET glucose10_cd = uar_get_code_by_cki(nullterm("CKI.EC!3388"))
  SET pao2_cd = uar_get_code_by_cki(nullterm("CKI.EC!3670"))
  SET pco2_cd = uar_get_code_by_cki(nullterm("CKI.EC!3641"))
  SET fio2_cd = uar_get_code_by_cki(nullterm("CKI.EC!3333"))
  SET ph_cd = uar_get_code_by_cki(nullterm("CKI.EC!3648"))
  SET intub_cd = uar_get_code_by_cki(nullterm("CKI.EC!7666"))
  SET intub2_cd = uar_get_code_by_cki(nullterm("CKI.EC!7677"))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ccnt),
    clinical_event ce,
    risk_adjustment_day rad
   PLAN (d
    WHERE (temp->clist[d.seq].accept_worst_lab_ind >= 0))
    JOIN (ce
    WHERE (ce.person_id=temp->clist[d.seq].person_id)
     AND ce.updt_dt_tm > cnvtdatetime((curdate - 1),curtime)
     AND ((ce.view_level+ 0)=1)
     AND ((ce.publish_flag+ 0)=1)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ((ce.event_cd+ 0) IN (wbc_cd, sodium_cd, hematocrit_cd, creatinine_cd, creatinine2_cd,
    albumin_cd, bilirubin_cd, bun_cd, glucose_cd, glucose2_cd,
    glucose3_cd, glucose4_cd, glucose5_cd, glucose6_cd, glucose7_cd,
    glucose8_cd, glucose9_cd, glucose10_cd, potassium_cd, pao2_cd,
    pco2_cd, fio2_cd, ph_cd, intub_cd, intub2_cd))
     AND ce.event_cd > 0)
    JOIN (rad
    WHERE (rad.risk_adjustment_id=temp->clist[d.seq].risk_adjustment_id)
     AND rad.active_ind=1
     AND rad.cc_beg_dt_tm < ce.event_end_dt_tm
     AND rad.cc_end_dt_tm >= ce.event_end_dt_tm)
   ORDER BY d.seq, rad.cc_day
   HEAD d.seq
    dcnt = temp->clist[d.seq].dcnt
   HEAD rad.cc_day
    worst_pao2 = - (1.0), worst_pco2 = - (1.0), worst_fio2 = - (1.0),
    worst_ph = - (1.0), worst_intub = - (1.0), old_abg_wieght = - (1.0)
   DETAIL
    isnum = isnumeric(ce.event_tag), dcnt = (dcnt+ 1), stat = alterlist(temp->clist[d.seq].dlist,dcnt
     ),
    temp->clist[d.seq].dlist[dcnt].clinical_event_id = ce.clinical_event_id, temp->clist[d.seq].
    dlist[dcnt].risk_adjustment_day_id = rad.risk_adjustment_day_id, temp->clist[d.seq].dlist[dcnt].
    cc_day = rad.cc_day,
    temp->clist[d.seq].dlist[dcnt].cc_beg_dt_tm = cnvtdatetime(rad.cc_beg_dt_tm), temp->clist[d.seq].
    dlist[dcnt].cc_end_dt_tm = cnvtdatetime(rad.cc_end_dt_tm), temp->clist[d.seq].dlist[dcnt].
    event_cd = ce.event_cd,
    temp->clist[d.seq].dlist[dcnt].lab_ind = 1, temp->clist[d.seq].dlist[dcnt].vital_ind = 0, temp->
    clist[d.seq].dlist[dcnt].temp_ind = 0,
    temp->clist[d.seq].dlist[dcnt].urine_ind = 0, temp->clist[d.seq].dlist[dcnt].worst_resolved_ind
     = 0, temp->clist[d.seq].dlist[dcnt].new_rel_intub = - (1),
    temp->clist[d.seq].dlist[dcnt].new_rel_intub_ce_id = 0, temp->clist[d.seq].dlist[dcnt].
    set_rel_intub_ind = 0
    IF (ce.event_cd=wbc_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_wbc_result, temp->clist[d.seq].dlist[dcnt].
     old_worst_ce_id = rad.wbc_ce_id
    ELSEIF (ce.event_cd=sodium_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_sodium_result, temp->clist[d.seq].dlist[
     dcnt].old_worst_ce_id = rad.sodium_ce_id
    ELSEIF (ce.event_cd=hematocrit_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_hematocrit, temp->clist[d.seq].dlist[dcnt].
     old_worst_ce_id = rad.hematocrit_ce_id
    ELSEIF (ce.event_cd IN (creatinine_cd, creatinine2_cd))
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_creatinine_result, temp->clist[d.seq].
     dlist[dcnt].old_worst_ce_id = rad.creatinine_ce_id
    ELSEIF (ce.event_cd=albumin_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_albumin_result, temp->clist[d.seq].dlist[
     dcnt].old_worst_ce_id = rad.albumin_ce_id
    ELSEIF (ce.event_cd=bilirubin_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_bilirubin_result, temp->clist[d.seq].dlist[
     dcnt].old_worst_ce_id = rad.bilirubin_ce_id
    ELSEIF (ce.event_cd=potassium_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_potassium_result, temp->clist[d.seq].dlist[
     dcnt].old_worst_ce_id = rad.potassium_ce_id
    ELSEIF (ce.event_cd=bun_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_bun_result, temp->clist[d.seq].dlist[dcnt].
     old_worst_ce_id = rad.bun_ce_id
    ELSEIF (ce.event_cd IN (glucose_cd, glucose2_cd, glucose3_cd, glucose4_cd, glucose5_cd,
    glucose6_cd, glucose7_cd, glucose8_cd, glucose9_cd, glucose10_cd))
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_glucose_result, temp->clist[d.seq].dlist[
     dcnt].old_worst_ce_id = rad.glucose_ce_id
    ELSEIF (ce.event_cd=pao2_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_pao2_result, temp->clist[d.seq].dlist[dcnt]
     .old_worst_ce_id = rad.pao2_ce_id, worst_pao2 = rad.worst_pao2_result
    ELSEIF (ce.event_cd=pco2_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_pco2_result, temp->clist[d.seq].dlist[dcnt]
     .old_worst_ce_id = rad.pco2_ce_id, worst_pco2 = rad.worst_pco2_result
    ELSEIF (ce.event_cd=fio2_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_fio2_result, temp->clist[d.seq].dlist[dcnt]
     .old_worst_ce_id = rad.fio2_ce_id, worst_fio2 = rad.worst_fio2_result
    ELSEIF (ce.event_cd=ph_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_ph_result, temp->clist[d.seq].dlist[dcnt].
     old_worst_ce_id = rad.ph_ce_id, worst_ph = rad.worst_ph_result
    ELSEIF (ce.event_cd IN (intub_cd, intub2_cd))
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.intubated_ind, temp->clist[d.seq].dlist[dcnt].
     old_worst_ce_id = rad.intubated_ce_id, worst_intub = rad.intubated_ind
    ENDIF
    new_possible_worst = "Y"
   FOOT  rad.cc_day
    IF (worst_pao2 > 0
     AND worst_pco2 > 0
     AND worst_fio2 > 0
     AND worst_ph > 0
     AND worst_intub >= 0)
     IF (((worst_intub=0) OR (worst_fio2 < 50.00)) )
      IF (worst_pao2 < 50)
       temp->clist[d.seq].dlist[dcnt].old_abg_weight = 15
      ELSEIF (worst_pao2 < 70)
       temp->clist[d.seq].dlist[dcnt].old_abg_weight = 5
      ELSEIF (worst_pao2 < 80)
       temp->clist[d.seq].dlist[dcnt].old_abg_weight = 2
      ELSE
       temp->clist[d.seq].dlist[dcnt].old_abg_weight = 0
      ENDIF
     ELSE
      aado2 = (((worst_fio2 * 7.13) - worst_pao2) - worst_pco2)
      IF (aado2 < 100)
       temp->clist[d.seq].dlist[dcnt].old_abg_weight = 0
      ELSEIF (aado2 < 250)
       temp->clist[d.seq].dlist[dcnt].old_abg_weight = 7
      ELSEIF (aado2 < 350)
       temp->clist[d.seq].dlist[dcnt].old_abg_weight = 9
      ELSEIF (aado2 < 500)
       temp->clist[d.seq].dlist[dcnt].old_abg_weight = 11
      ELSE
       temp->clist[d.seq].dlist[dcnt].old_abg_weight = 14
      ENDIF
     ENDIF
    ENDIF
   FOOT  d.seq
    temp->clist[d.seq].dcnt = dcnt
   WITH nocounter
  ;end select
 ENDIF
 IF (accept_worst_vitals_ind >= 0)
  SET resp_cd = uar_get_code_by_cki(nullterm("CKI.EC!5501"))
  SET temp1_cd = uar_get_code_by_cki(nullterm("CKI.EC!5502"))
  SET temp2_cd = uar_get_code_by_cki(nullterm("CKI.EC!5505"))
  SET temp3_cd = uar_get_code_by_cki(nullterm("CKI.EC!5506"))
  SET temp4_cd = uar_get_code_by_cki(nullterm("CKI.EC!5507"))
  SET temp5_cd = uar_get_code_by_cki(nullterm("CKI.EC!5508"))
  SET temp6_cd = uar_get_code_by_cki(nullterm("CKI.EC!5509"))
  SET heartrate_cd = uar_get_code_by_cki(nullterm("CKI.EC!40"))
  SET pulse_cd = uar_get_code_by_cki(nullterm("CKI.EC!5500"))
  SET heartrate2_cd = uar_get_code_by_cki(nullterm("CKI.EC!7679"))
  SET heartrate3_cd = uar_get_code_by_cki(nullterm("CKI.EC!7187"))
  SET systolic_cd = uar_get_code_by_cki(nullterm("CKI.EC!7680"))
  SET diastolic_cd = uar_get_code_by_cki(nullterm("CKI.EC!7681"))
  SET systolic2_cd = uar_get_code_by_cki(nullterm("CKI.EC!75"))
  SET diastolic2_cd = uar_get_code_by_cki(nullterm("CKI.EC!26"))
  SET diastolic3_cd = uar_get_code_by_cki(nullterm("CKI.EC!9370"))
  SET diastolic4_cd = uar_get_code_by_cki(nullterm("CKI.EC!9371"))
  SET systolic3_cd = uar_get_code_by_cki(nullterm("CKI.EC!9369"))
  SET eyes_cd = uar_get_code_by_cki(nullterm("CKI.EC!5524"))
  SET motor_cd = uar_get_code_by_cki(nullterm("CKI.EC!5525"))
  SET verbal_cd = uar_get_code_by_cki(nullterm("CKI.EC!89"))
  SET meds_cd = uar_get_code_by_cki(nullterm("CKI.EC!7675"))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ccnt),
    clinical_event ce,
    risk_adjustment_day rad
   PLAN (d)
    JOIN (ce
    WHERE (ce.person_id=temp->clist[d.seq].person_id)
     AND ce.updt_dt_tm > cnvtdatetime((curdate - 1),curtime)
     AND ((ce.view_level+ 0)=1)
     AND ((ce.publish_flag+ 0)=1)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ((ce.event_cd+ 0) IN (resp_cd, temp1_cd, temp2_cd, temp3_cd, temp4_cd,
    temp5_cd, temp6_cd, pulse_cd, heartrate_cd, heartrate2_cd,
    heartrate3_cd, systolic_cd, diastolic_cd, systolic2_cd, diastolic2_cd,
    systolic3_cd, diastolic3_cd, diastolic3_cd, eyes_cd, motor_cd,
    verbal_cd, meds_cd))
     AND ce.event_cd > 0)
    JOIN (rad
    WHERE (rad.risk_adjustment_id=temp->clist[d.seq].risk_adjustment_id)
     AND rad.active_ind=1
     AND rad.cc_beg_dt_tm < ce.event_end_dt_tm
     AND rad.cc_end_dt_tm >= ce.event_end_dt_tm)
   ORDER BY d.seq, rad.cc_day
   HEAD d.seq
    dcnt = temp->clist[d.seq].dcnt
   HEAD rad.cc_day
    worst_eyes = - (1), worst_motor = - (1), worst_verbal = - (1),
    worst_meds = - (1)
   DETAIL
    isnum = isnumeric(ce.event_tag), dcnt = (dcnt+ 1), stat = alterlist(temp->clist[d.seq].dlist,dcnt
     ),
    temp->clist[d.seq].dlist[dcnt].clinical_event_id = ce.clinical_event_id, temp->clist[d.seq].
    dlist[dcnt].risk_adjustment_day_id = rad.risk_adjustment_day_id, temp->clist[d.seq].dlist[dcnt].
    cc_day = rad.cc_day,
    temp->clist[d.seq].dlist[dcnt].cc_beg_dt_tm = cnvtdatetime(rad.cc_beg_dt_tm), temp->clist[d.seq].
    dlist[dcnt].cc_end_dt_tm = cnvtdatetime(rad.cc_end_dt_tm), temp->clist[d.seq].dlist[dcnt].
    event_cd = ce.event_cd,
    temp->clist[d.seq].dlist[dcnt].lab_ind = 0
    IF ((((rad.vent_ind=- (1))) OR (rad.vent_ind=0
     AND rad.vent_today_ind=1)) )
     temp->clist[d.seq].dlist[dcnt].unset_vent_ind = 1, new_possible_worst = "Y"
    ELSE
     temp->clist[d.seq].dlist[dcnt].unset_vent_ind = 0
    ENDIF
    temp->clist[d.seq].dlist[dcnt].old_vent_ind = - (1), temp->clist[d.seq].dlist[dcnt].new_vent_ind
     = - (1), temp->clist[d.seq].dlist[dcnt].vital_ind = 1,
    temp->clist[d.seq].dlist[dcnt].temp_ind = 0
    IF (ce.event_cd IN (heartrate_cd, heartrate2_cd, heartrate3_cd, pulse_cd))
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_heart_rate, temp->clist[d.seq].dlist[dcnt].
     old_worst_ce_id = rad.heartrate_ce_id
    ELSEIF (ce.event_cd IN (temp1_cd, temp2_cd, temp3_cd, temp4_cd, temp5_cd,
    temp6_cd))
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_temp, temp->clist[d.seq].dlist[dcnt].
     old_worst_ce_id = rad.temp_ce_id
    ELSEIF (((ce.event_cd=systolic_cd) OR (((ce.event_cd=systolic2_cd) OR (ce.event_cd=systolic3_cd
    )) )) )
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.mean_blood_pressure
    ELSEIF (((ce.event_cd=diastolic_cd) OR (((ce.event_cd=diastolic2_cd) OR (((ce.event_cd=
    diastolic3_cd) OR (ce.event_cd=diastolic4_cd)) )) )) )
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.mean_blood_pressure
    ELSEIF (ce.event_cd=resp_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_resp_result, temp->clist[d.seq].dlist[dcnt]
     .old_worst_ce_id = rad.resp_ce_id, temp->clist[d.seq].dlist[dcnt].old_vent_ind = rad.vent_ind
    ELSEIF (ce.event_cd=eyes_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_gcs_eye_score, temp->clist[d.seq].dlist[
     dcnt].old_worst_ce_id = rad.eyes_ce_id, worst_eyes = rad.worst_gcs_eye_score
    ELSEIF (ce.event_cd=motor_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_gcs_motor_score, temp->clist[d.seq].dlist[
     dcnt].old_worst_ce_id = rad.motor_ce_id, worst_motor = rad.worst_gcs_motor_score
    ELSEIF (ce.event_cd=verbal_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.worst_gcs_verbal_score, temp->clist[d.seq].dlist[
     dcnt].old_worst_ce_id = rad.verbal_ce_id, worst_verbal = rad.worst_gcs_verbal_score
    ELSEIF (ce.event_cd=meds_cd)
     temp->clist[d.seq].dlist[dcnt].old_worst = rad.meds_ind, temp->clist[d.seq].dlist[dcnt].
     old_worst_ce_id = rad.meds_ce_id, worst_meds = rad.meds_ind
    ENDIF
    temp->clist[d.seq].dlist[dcnt].vital_ind = 1, temp->clist[d.seq].dlist[dcnt].urine_ind = 0, temp
    ->clist[d.seq].dlist[dcnt].worst_resolved_ind = 0,
    new_possible_worst = "Y"
   FOOT  rad.cc_day
    temp->clist[d.seq].dlist[dcnt].old_gcs_score = - (1)
    IF (worst_meds=1)
     temp->clist[d.seq].dlist[dcnt].old_gcs_score = 15
    ELSEIF (worst_motor > 0
     AND worst_eyes > 0
     AND worst_verbal > 0)
     temp->clist[d.seq].dlist[dcnt].old_gcs_score = ((worst_motor+ worst_eyes)+ worst_verbal)
    ENDIF
   FOOT  d.seq
    temp->clist[d.seq].dcnt = dcnt
   WITH nocounter
  ;end select
 ENDIF
 IF (accept_urine_output_ind >= 0)
  SET urine1_cd = uar_get_code_by_cki(nullterm("CKI.EC!6416"))
  SET urine2_cd = uar_get_code_by_cki(nullterm("CKI.EC!5723"))
  SET urine3_cd = uar_get_code_by_cki(nullterm("CKI.EC!5727"))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ccnt),
    clinical_event ce,
    risk_adjustment_day rad
   PLAN (d)
    JOIN (ce
    WHERE (ce.person_id=temp->clist[d.seq].person_id)
     AND ((ce.event_cd+ 0) IN (urine1_cd, urine2_cd, urine3_cd))
     AND ce.updt_dt_tm > cnvtdatetime((curdate - 1),curtime)
     AND ((ce.view_level+ 0)=1)
     AND ((ce.publish_flag+ 0)=1)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ce.event_cd > 0)
    JOIN (rad
    WHERE (rad.risk_adjustment_id=temp->clist[d.seq].risk_adjustment_id)
     AND rad.active_ind=1
     AND rad.cc_beg_dt_tm < ce.event_end_dt_tm
     AND rad.cc_end_dt_tm >= ce.event_end_dt_tm)
   ORDER BY d.seq, rad.cc_day
   HEAD d.seq
    dcnt = temp->clist[d.seq].dcnt
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     dcnt = (dcnt+ 1), stat = alterlist(temp->clist[d.seq].dlist,dcnt), temp->clist[d.seq].dlist[dcnt
     ].clinical_event_id = ce.clinical_event_id,
     temp->clist[d.seq].dlist[dcnt].risk_adjustment_day_id = rad.risk_adjustment_day_id, temp->clist[
     d.seq].dlist[dcnt].cc_day = rad.cc_day, temp->clist[d.seq].dlist[dcnt].cc_beg_dt_tm =
     cnvtdatetime(rad.cc_beg_dt_tm),
     temp->clist[d.seq].dlist[dcnt].cc_end_dt_tm = cnvtdatetime(rad.cc_end_dt_tm), temp->clist[d.seq]
     .dlist[dcnt].event_cd = ce.event_cd, temp->clist[d.seq].dlist[dcnt].lab_ind = 0,
     temp->clist[d.seq].dlist[dcnt].vital_ind = 0, temp->clist[d.seq].dlist[dcnt].temp_ind = 0, temp
     ->clist[d.seq].dlist[dcnt].urine_ind = 1,
     temp->clist[d.seq].dlist[dcnt].worst_resolved_ind = 0, temp->clist[d.seq].dlist[dcnt].old_worst
      = rad.urine_24hr_output, new_possible_worst = "Y"
    ENDIF
   FOOT  d.seq
    temp->clist[d.seq].dcnt = dcnt
   WITH nocounter
  ;end select
 ENDIF
 IF (((accept_tiss_acttx_if_ind=1) OR (accept_tiss_nonacttx_if_ind=1)) )
  EXECUTE FROM load_tiss_items_to_arrays TO load_tiss_items_to_arrays_exit
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ccnt),
    clinical_event ce,
    risk_adjustment_day rad
   PLAN (d
    WHERE (((temp->clist[d.seq].accept_tiss_acttx_if_ind=1)) OR ((temp->clist[d.seq].
    accept_tiss_nonacttx_if_ind=1))) )
    JOIN (ce
    WHERE (ce.person_id=temp->clist[d.seq].person_id)
     AND expand(scan_num,1,94,ce.event_cd,scan_tiss_list->list[scan_num].ce_cd)
     AND ce.updt_dt_tm > cnvtdatetime((curdate - 1),curtime)
     AND ((ce.view_level+ 0)=1)
     AND ((ce.publish_flag+ 0)=1)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ce.event_cd > 0)
    JOIN (rad
    WHERE (rad.risk_adjustment_id=temp->clist[d.seq].risk_adjustment_id)
     AND rad.active_ind=1
     AND ((ce.event_start_dt_tm = null
     AND rad.cc_beg_dt_tm <= ce.event_end_dt_tm
     AND rad.cc_end_dt_tm >= ce.event_end_dt_tm) OR (ce.event_start_dt_tm IS NOT null
     AND rad.cc_beg_dt_tm <= ce.event_end_dt_tm
     AND rad.cc_end_dt_tm >= ce.event_start_dt_tm)) )
   ORDER BY d.seq, rad.cc_day
   HEAD d.seq
    dcnt = temp->clist[d.seq].dcnt
   HEAD rad.cc_day
    tiss_found = 0
   DETAIL
    IF (tiss_found=0)
     dcnt = (dcnt+ 1), tiss_found = 1, stat = alterlist(temp->clist[d.seq].dlist,dcnt),
     temp->clist[d.seq].dlist[dcnt].clinical_event_id = ce.clinical_event_id, temp->clist[d.seq].
     dlist[dcnt].risk_adjustment_day_id = rad.risk_adjustment_day_id, temp->clist[d.seq].dlist[dcnt].
     cc_day = rad.cc_day,
     temp->clist[d.seq].dlist[dcnt].cc_beg_dt_tm = cnvtdatetime(rad.cc_beg_dt_tm), temp->clist[d.seq]
     .dlist[dcnt].cc_end_dt_tm = cnvtdatetime(rad.cc_end_dt_tm), temp->clist[d.seq].dlist[dcnt].
     event_cd = ce.event_cd,
     temp->clist[d.seq].dlist[dcnt].lab_ind = 0, temp->clist[d.seq].dlist[dcnt].vital_ind = 0, temp->
     clist[d.seq].dlist[dcnt].tiss_ce_ind = 1,
     temp->clist[d.seq].dlist[dcnt].temp_ind = 0, temp->clist[d.seq].dlist[dcnt].urine_ind = 0, temp
     ->clist[d.seq].dlist[dcnt].worst_resolved_ind = 0,
     temp->clist[d.seq].dlist[dcnt].old_worst = 0.0, new_possible_worst = "Y"
    ENDIF
   FOOT  d.seq
    temp->clist[d.seq].dcnt = dcnt
   WITH nocounter
  ;end select
 ENDIF
 IF (new_possible_worst="N"
  AND one_critical_reg_change="N")
  SET reply->status_data.status = "S"
  SET reply->subeventstatus[1].targetobjectvalue =
  "dcp_apache_ops_scan successful completion (no changes made)"
  SET reply->ops_event = "The scanner has run successfully."
  GO TO exit_program
 ENDIF
 IF (new_possible_worst="Y")
  SET one_new_worst = "N"
  SET ops_inerror_cd = ops_meaning_code(8,"INERROR")
  DECLARE urine = f8
  DECLARE urine_total = f8
  DECLARE wbc = f8
  DECLARE wbc_ce_id = f8
  DECLARE tempp = f8
  DECLARE temp_ce_id = f8
  DECLARE sodium = f8
  DECLARE sodium_ce_id = f8
  DECLARE heartrate = f8
  DECLARE heartrate_ce_id = f8
  DECLARE meanbp = f8
  DECLARE hematocrit = f8
  DECLARE hematocrit_ce_id = f8
  DECLARE creatinine = f8
  DECLARE creatinine_ce_id = f8
  DECLARE albumin = f8
  DECLARE albumin_ce_id = f8
  DECLARE bilirubin = f8
  DECLARE bilirubin_ce_id = f8
  DECLARE potassium = f8
  DECLARE potassium_ce_id = f8
  DECLARE bun = f8
  DECLARE bun_ce_id = f8
  DECLARE glucose = f8
  DECLARE glucose_ce_id = f8
  DECLARE pao2 = f8
  DECLARE pao2_ce_id = f8
  DECLARE pco2 = f8
  DECLARE pco2_ce_id = f8
  DECLARE fio2 = f8
  DECLARE fio2_cd_id = f8
  DECLARE ph = f8
  DECLARE ph_ce_id = f8
  DECLARE intub = f8
  DECLARE intub_ce_id = f8
  DECLARE old_abg_weight = i4
  DECLARE aado2 = f8
  DECLARE abg_flag = i2
  DECLARE worst_pao2 = f8
  DECLARE worst_pco2 = f8
  DECLARE worst_fio2 = f8
  DECLARE worst_ph = f8
  DECLARE worst_intub = f8
  DECLARE meds = f8
  DECLARE meds_ce_id = f8
  DECLARE motor = f8
  DECLARE motor_ce_id = f8
  DECLARE verbal = f8
  DECLARE verbal_ce_id = f8
  DECLARE eyes = f8
  DECLARE eyes_ce_id = f8
  DECLARE resp = f8
  DECLARE resp_ce_id = f8
  DECLARE vent = f8
  DECLARE vent_ce_id = f8
 ENDIF
 FOR (x = 1 TO ccnt)
  IF ((temp->clist[x].hosp_admit_dt_tm_chg_ind=1)
   AND (temp->clist[x].new_hosp_admit_dt_tm > cnvtdatetime(temp->clist[x].icu_admit_dt_tm)))
   EXECUTE FROM inactivate_ra TO inactivate_ra_exit
  ELSEIF ((((temp->clist[x].sex_chg_ind=1)) OR ((((temp->clist[x].age_chg_ind=1)) OR ((((temp->clist[
  x].hosp_admit_dt_tm_chg_ind=1)) OR ((temp->clist[x].vent_flag_issue_ind=1))) )) )) )
   EXECUTE FROM update_ra TO update_ra_exit
  ENDIF
  IF ((temp->clist[x].dcnt > 0))
   IF ((temp->clist[x].tiss_changed_ind=1))
    SET one_new_worst = "Y"
   ENDIF
   EXECUTE FROM new_worst_check TO new_worst_check_exit
  ENDIF
 ENDFOR
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reply->subeventstatus[1].targetobjectvalue = error_string
  SET reply->ops_event = error_string
 ELSE
  SET reply->status_data.status = "S"
  SET reply->subeventstatus[1].targetobjectvalue = "dcp_apache_ops_scan successful completion"
  SET reply->ops_event = "The scanner has run successfully."
  COMMIT
 ENDIF
 GO TO exit_program
#inactivate_ra
 SET day_cnt = 0
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
    AND rad.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp4->dlist,cnt), temp4->dlist[cnt].risk_adjustment_day_id = rad
   .risk_adjustment_day_id,
   temp4->dlist[cnt].risk_adjustment_id = rad.risk_adjustment_id
  FOOT REPORT
   day_cnt = cnt
  WITH nocounter
 ;end select
 IF (day_cnt > 0)
  FOR (y = 1 TO day_cnt)
   UPDATE  FROM risk_adjustment_outcomes rao
    SET rao.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rao.active_ind = 0, rao
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     rao.updt_dt_tm = cnvtdatetime(curdate,curtime3), rao.updt_task = reqinfo->updt_task, rao
     .updt_applctx = reqinfo->updt_applctx,
     rao.updt_id = reqinfo->updt_id, rao.updt_cnt = (rao.updt_cnt+ 1)
    WHERE (rao.risk_adjustment_day_id=temp4->dlist[y].risk_adjustment_day_id)
    WITH nocounter
   ;end update
   UPDATE  FROM risk_adjustment_day rad
    SET rad.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rad.active_ind = 0, rad
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     rad.updt_dt_tm = cnvtdatetime(curdate,curtime3), rad.updt_task = reqinfo->updt_task, rad
     .updt_applctx = reqinfo->updt_applctx,
     rad.updt_id = reqinfo->updt_id, rad.updt_cnt = (rad.updt_cnt+ 1)
    WHERE (rad.risk_adjustment_day_id=temp4->dlist[y].risk_adjustment_day_id)
    WITH nocounter
   ;end update
  ENDFOR
 ENDIF
 DELETE  FROM risk_adjustment_event rae
  WHERE (rae.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
  WITH nocounter
 ;end delete
 DELETE  FROM risk_adj_tiss rat
  WHERE (rat.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
  WITH nocounter
 ;end delete
 UPDATE  FROM risk_adjustment ra
  SET ra.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), ra.active_ind = 0, ra
   .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   ra.active_status_prsnl_id = reqinfo->updt_id, ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra
   .updt_task = reqinfo->updt_task,
   ra.updt_applctx = reqinfo->updt_applctx, ra.updt_id = reqinfo->updt_id, ra.updt_cnt = (ra.updt_cnt
   + 1)
  WHERE (ra.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
  WITH nocounter
 ;end update
#inactivate_ra_exit
#update_ra
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  PLAN (ra
   WHERE (ra.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
    AND ra.active_ind=1)
  DETAIL
   temp3->risk_adjustment_id = ra.risk_adjustment_id, temp3->person_id = ra.person_id, temp3->
   encntr_id = ra.encntr_id,
   temp3->icu_admit_dt_tm = cnvtdatetime(ra.icu_admit_dt_tm), temp3->icu_disch_dt_tm = cnvtdatetime(
    ra.icu_disch_dt_tm), temp3->admit_source = ra.admit_source,
   temp3->discharge_location = uar_get_code_meaning(ra.discharge_location_cd)
   IF (ra.diedinicu_ind=1)
    temp3->discharge_location = "DEATH"
   ENDIF
   temp3->admitsource_flag = ra.admitsource_flag, temp3->hrs_at_source = ra.hrs_at_source, temp3->
   body_system = ra.body_system,
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
   temp3->var03hspxlos = ra.var03hspxlos_value,
   temp3->ejectfx = ra.ejectfx_fraction, temp3->diedinicu_ind = ra.diedinicu_ind, temp3->adm_doc_id
    = ra.adm_doc_id,
   temp3->disease_category_cd = ra.disease_category_cd, temp3->med_service_cd = ra.med_service_cd,
   temp3->admit_icu_cd = ra.admit_icu_cd
  WITH nocounter
 ;end select
 SET hdeath_parameters->risk_adjustment_id = temp3->risk_adjustment_id
 EXECUTE cco_get_died_hosp_from_ra
 SET temp3->diedinhospital_ind = hdeath_reply->hosp_death_ind
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
   WHERE (ra.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_string = "Error inactivating risk_adjustment row."
  ELSE
   SET temp->clist[x].risk_adjustment_id_new = ra_id
   IF ((temp->clist[x].sex_chg_ind=1))
    SET temp3->gender = temp->clist[x].new_gender
   ENDIF
   IF ((temp->clist[x].age_chg_ind=1))
    SET temp3->age = temp->clist[x].new_age
   ENDIF
   IF ((temp->clist[x].hosp_admit_dt_tm_chg_ind=1))
    SET temp3->hosp_admit_dt_tm = cnvtdatetime(temp->clist[x].new_hosp_admit_dt_tm)
   ENDIF
   SET discharge_location_cd = uar_get_code_by("MEANING",4001995,temp3->discharge_location)
   INSERT  FROM risk_adjustment ra
    SET ra.risk_adjustment_id = ra_id, ra.person_id = temp3->person_id, ra.encntr_id = temp3->
     encntr_id,
     ra.icu_admit_dt_tm = cnvtdatetime(temp3->icu_admit_dt_tm), ra.icu_disch_dt_tm = cnvtdatetime(
      temp3->icu_disch_dt_tm), ra.admit_source = temp3->admit_source,
     ra.discharge_location_cd = discharge_location_cd, ra.admitsource_flag = temp3->admitsource_flag,
     ra.hrs_at_source = temp3->hrs_at_source,
     ra.body_system = temp3->body_system, ra.admit_diagnosis = temp3->admitdiagnosis, ra
     .disease_category_cd = temp3->disease_category_cd,
     ra.therapy_level = temp3->therapy_level, ra.xfer_within_48hr_ind = temp3->xfer_within_48hr_ind,
     ra.electivesurgery_ind = temp3->electivesurgery_ind,
     ra.readmit_ind = temp3->readmit_ind, ra.readmit_within_24hr_ind = temp3->readmit_within_24hr_ind,
     ra.admit_age = temp3->age,
     ra.hosp_admit_dt_tm = cnvtdatetime(temp3->hosp_admit_dt_tm), ra.gender_flag = temp3->gender, ra
     .teach_type_flag = temp3->teach_type_flag,
     ra.region_flag = temp3->region_flag, ra.bed_count = temp3->bedcount, ra.dialysis_ind = temp3->
     dialysis_ind,
     ra.aids_ind = temp3->aids_ind, ra.hepaticfailure_ind = temp3->hepaticfailure_ind, ra
     .lymphoma_ind = temp3->lymphoma_ind,
     ra.metastaticcancer_ind = temp3->metastaticcancer_ind, ra.leukemia_ind = temp3->leukemia_ind, ra
     .immunosuppression_ind = temp3->immunosuppression_ind,
     ra.cirrhosis_ind = temp3->cirrhosis_ind, ra.diabetes_ind = temp3->diabetes_ind, ra.copd_flag =
     temp3->copd_flag,
     ra.copd_ind = temp3->copd_ind, ra.chronic_health_unavail_ind = temp3->chronic_health_unavail_ind,
     ra.chronic_health_none_ind = temp3->chronic_health_none_ind,
     ra.ami_location = temp3->ami_location, ra.ptca_device = temp3->ptca_device, ra.thrombolytics_ind
      = temp3->thrombolytics_ind,
     ra.diedinhospital_ind = temp3->diedinhospital_ind, ra.nbr_grafts_performed = temp3->
     nbr_grafts_performed, ra.ima_ind = temp3->ima_ind,
     ra.midur_ind = temp3->midur_ind, ra.sv_graft_ind = temp3->sv_graft_ind, ra.mi_within_6mo_ind =
     temp3->mi_within_6mo_ind,
     ra.cc_during_stay_ind = temp3->cc_during_stay_ind, ra.var03hspxlos_value = temp3->var03hspxlos,
     ra.ejectfx_fraction = temp3->ejectfx,
     ra.diedinicu_ind = temp3->diedinicu_ind, ra.adm_doc_id = temp3->adm_doc_id, ra.therapy_level =
     temp3->therapy_level,
     ra.disease_category_cd = temp3->disease_category_cd, ra.med_service_cd = temp3->med_service_cd,
     ra.admit_icu_cd = temp3->admit_icu_cd,
     ra.valid_from_dt_tm = cnvtdatetime(curdate,curtime3), ra.valid_until_dt_tm = cnvtdatetime(
      "31-DEC-2100"), ra.active_ind = 1,
     ra.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ra.active_status_prsnl_id = reqinfo->
     updt_id, ra.active_status_cd = reqdata->active_status_cd,
     ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra.updt_task = reqinfo->updt_task, ra
     .updt_applctx = reqinfo->updt_applctx,
     ra.updt_id = reqinfo->updt_id, ra.updt_cnt = 0
    WITH nocounter
   ;end insert
   UPDATE  FROM risk_adjustment_event rae
    SET rae.risk_adjustment_id = ra_id, rae.updt_dt_tm = cnvtdatetime(curdate,curtime3), rae
     .updt_task = reqinfo->updt_task,
     rae.updt_applctx = reqinfo->updt_applctx, rae.updt_id = reqinfo->updt_id, rae.updt_cnt = (rae
     .updt_cnt+ 1)
    WHERE (rae.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
    WITH nocounter
   ;end update
   UPDATE  FROM risk_adj_tiss rat
    SET rat.risk_adjustment_id = ra_id, rat.updt_dt_tm = cnvtdatetime(curdate,curtime3), rat
     .updt_task = reqinfo->updt_task,
     rat.updt_applctx = reqinfo->updt_applctx, rat.updt_id = reqinfo->updt_id, rat.updt_cnt = (rat
     .updt_cnt+ 1)
    WHERE (rat.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
    WITH nocounter
   ;end update
  ENDIF
 ELSE
  SET error_flag = "Y"
  SET error_string = "Unable to get new ra_id from sequence bucket."
 ENDIF
 IF (error_flag="N")
  SET day_cnt = 0
  SELECT INTO "nl:"
   FROM risk_adjustment_day rad
   PLAN (rad
    WHERE (rad.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
     AND rad.active_ind=1)
   ORDER BY rad.cc_day
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(temp4->dlist,cnt), temp4->dlist[cnt].risk_adjustment_id = rad
    .risk_adjustment_id,
    temp4->dlist[cnt].risk_adjustment_day_id = rad.risk_adjustment_day_id, temp4->dlist[cnt].cc_day
     = rad.cc_day, temp4->dlist[cnt].cc_beg_dt_tm = cnvtdatetime(rad.cc_beg_dt_tm),
    temp4->dlist[cnt].cc_end_dt_tm = cnvtdatetime(rad.cc_end_dt_tm), temp4->dlist[cnt].intubated_ind
     = rad.intubated_ind, temp4->dlist[cnt].intub_ce_id = rad.intubated_ce_id,
    temp4->dlist[cnt].eyes = rad.worst_gcs_eye_score, temp4->dlist[cnt].motor = rad
    .worst_gcs_motor_score, temp4->dlist[cnt].verbal = rad.worst_gcs_verbal_score,
    temp4->dlist[cnt].meds_ind = rad.meds_ind, temp4->dlist[cnt].eyes_ce_id = rad.eyes_ce_id, temp4->
    dlist[cnt].motor_ce_id = rad.motor_ce_id,
    temp4->dlist[cnt].verbal_ce_id = rad.verbal_ce_id, temp4->dlist[cnt].meds_ce_id = rad.meds_ce_id,
    temp4->dlist[cnt].urine = rad.urine_output,
    temp4->dlist[cnt].urine_24hr = rad.urine_24hr_output, temp4->dlist[cnt].wbc = rad
    .worst_wbc_result, temp4->dlist[cnt].wbc_ce_id = rad.wbc_ce_id,
    temp4->dlist[cnt].temp = rad.worst_temp, temp4->dlist[cnt].temp_ce_id = rad.temp_ce_id, temp4->
    dlist[cnt].resp = rad.worst_resp_result,
    temp4->dlist[cnt].resp_ce_id = rad.resp_ce_id, temp4->dlist[cnt].vent_ind = rad.vent_ind, temp4->
    dlist[cnt].sodium = rad.worst_sodium_result,
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
    temp4->dlist[cnt].pco2_ce_id = rad.pco2_ce_id, temp4->dlist[cnt].bun = rad.worst_bun_result,
    temp4->dlist[cnt].bun_ce_id = rad.bun_ce_id,
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
  IF (day_cnt > 0)
   FOR (y = 1 TO day_cnt)
    UPDATE  FROM risk_adjustment_outcomes rao
     SET rao.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rao.active_ind = 0, rao
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      rao.updt_dt_tm = cnvtdatetime(curdate,curtime3), rao.updt_task = reqinfo->updt_task, rao
      .updt_applctx = reqinfo->updt_applctx,
      rao.updt_id = reqinfo->updt_id, rao.updt_cnt = (rao.updt_cnt+ 1)
     WHERE (rao.risk_adjustment_day_id=temp4->dlist[y].risk_adjustment_day_id)
     WITH nocounter
    ;end update
    UPDATE  FROM risk_adjustment_day rad
     SET rad.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rad.active_ind = 0, rad
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      rad.updt_dt_tm = cnvtdatetime(curdate,curtime3), rad.updt_task = reqinfo->updt_task, rad
      .updt_applctx = reqinfo->updt_applctx,
      rad.updt_id = reqinfo->updt_id, rad.updt_cnt = (rad.updt_cnt+ 1)
     WHERE (rad.risk_adjustment_day_id=temp4->dlist[y].risk_adjustment_day_id)
     WITH nocounter
    ;end update
   ENDFOR
   SET error_flag = "N"
   FOR (y = 1 TO day_cnt)
     EXECUTE FROM aps TO aps_exit
     IF ((temp4->dlist[y].outcome_status >= 0))
      EXECUTE FROM outcomes TO outcomes_exit
     ENDIF
     EXECUTE FROM create_rad TO create_rad_exit
     IF (error_flag="Y")
      SET y = day_cnt
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
#update_ra_exit
#aps
 SET aps_variable->sintubated = temp4->dlist[y].intubated_ind
 SET aps_variable->svent = temp4->dlist[y].vent_ind
 SET aps_variable->sdialysis = temp3->dialysis_ind
 SET aps_variable->seyes = temp4->dlist[y].eyes
 SET aps_variable->smotor = temp4->dlist[y].motor
 SET aps_variable->sverbal = temp4->dlist[y].verbal
 SET aps_variable->smeds = temp4->dlist[y].meds_ind
 SET aps_variable->dwurine = temp4->dlist[y].urine_24hr
 SET aps_variable->dwwbc = temp4->dlist[y].wbc
 IF ((temp4->dlist[y].temp < 50))
  SET aps_variable->dwtemp = temp4->dlist[y].temp
 ELSE
  SET aps_variable->dwtemp = (((temp4->dlist[y].temp - 32) * 5)/ 9)
 ENDIF
 SET aps_variable->dwrespiratoryrate = temp4->dlist[y].resp
 SET aps_variable->dwsodium = temp4->dlist[y].sodium
 SET aps_variable->dwheartrate = temp4->dlist[y].heartrate
 SET aps_variable->dwmeanbp = temp4->dlist[y].meanbp
 SET aps_variable->dwph = temp4->dlist[y].ph
 SET aps_variable->dwhematocrit = temp4->dlist[y].hematocrit
 SET aps_variable->dwcreatinine = temp4->dlist[y].creatinine
 SET aps_variable->dwalbumin = temp4->dlist[y].albumin
 SET aps_variable->dwpao2 = temp4->dlist[y].pao2
 SET aps_variable->dwpco2 = temp4->dlist[y].pco2
 SET aps_variable->dwbun = temp4->dlist[y].bun
 SET aps_variable->dwglucose = temp4->dlist[y].glucose
 SET aps_variable->dwbilirubin = temp4->dlist[y].bilirubin
 SET aps_variable->dwfio2 = temp4->dlist[y].fio2
 EXECUTE FROM 5000_get_carry_over TO 5099_get_carry_over_exit
 IF ((aps_variable->svent < 0))
  SET status = - (22003)
 ELSE
  SET status = uar_amsapscalculate(aps_variable)
  CALL echo(build("uar_AmsApsCalculate=",status))
 ENDIF
 SET temp4->dlist[y].outcome_status = status
 IF (status < 0)
  CALL echo(build("uar_AmsApsCalculate err=",uar_amsraprinterror(status)))
  SET temp4->dlist[y].aps_score = - (1)
  IF (y=1)
   SET temp4->dlist[y].aps_day1 = - (1)
   SET temp4->dlist[y].aps_yesterday = - (1)
  ENDIF
 ELSE
  SET temp4->dlist[y].aps_score = status
  IF (y=1)
   SET temp4->dlist[y].aps_day1 = temp4->dlist[y].aps_score
   SET temp4->dlist[y].aps_yesterday = 0
  ELSE
   SET day_one_found = "N"
   SET yesterday_found = "N"
   IF ((temp4->dlist[1].cc_day=1)
    AND (temp4->dlist[1].outcome_status >= 0))
    SET temp4->dlist[y].aps_day1 = temp4->dlist[1].aps_score
    SET day1meds = temp4->dlist[1].meds_ind
    SET day1verbal = temp4->dlist[1].verbal
    SET day1motor = temp4->dlist[1].motor
    SET day1eyes = temp4->dlist[1].eyes
    SET day1pao2 = temp4->dlist[1].pao2
    SET day1fio2 = temp4->dlist[1].fio2
    SET day_one_found = "Y"
   ENDIF
   IF (((temp4->dlist[(y - 1)].cc_day+ 1)=temp4->dlist[y].cc_day)
    AND (temp4->dlist[(y - 1)].outcome_status >= 0))
    SET temp4->dlist[y].aps_yesterday = temp4->dlist[(y - 1)].aps_score
    SET yesterday_found = "Y"
   ENDIF
   IF (((day_one_found="N") OR (yesterday_found="N")) )
    SET temp4->dlist[y].outcome_status = - (1)
   ENDIF
  ENDIF
 ENDIF
#aps_exit
#outcomes
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_day_id=temp4->dlist[y].risk_adjustment_day_id)
    AND rad.cc_day=1
    AND rad.active_ind=1)
  DETAIL
   temp3->ventday1_ind = rad.vent_today_ind, temp3->oobventday1_ind = rad.vent_ind, temp3->
   oobintubday1_ind = rad.intubated_ind
  WITH nocounter
 ;end select
 SET get_visit_parameters->risk_adjustment_id = temp4->dlist[y].risk_adjustment_id
 EXECUTE cco_get_apache_visit_number
 SET aps_prediction->sicuday = temp4->dlist[y].cc_day
 SET aps_prediction->saps3day1 = temp4->dlist[y].aps_day1
 SET aps_prediction->saps3today = temp4->dlist[y].aps_score
 SET aps_prediction->saps3yesterday = temp4->dlist[y].aps_yesterday
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
 ELSEIF ((temp3->admit_source="SDU"))
  SET aps_prediction->sadmitsource = 8
 ELSEIF ((temp3->admit_source="ICU_TO_SDU"))
  SET aps_prediction->sadmitsource = 8
 ENDIF
 SET aps_prediction->sgraftcount = temp3->nbr_grafts_performed
 SET aps_prediction->smeds = temp4->dlist[y].meds_ind
 SET aps_prediction->sverbal = temp4->dlist[y].verbal
 SET aps_prediction->smotor = temp4->dlist[y].motor
 SET aps_prediction->seyes = temp4->dlist[y].eyes
 SET aps_prediction->sage = temp3->age
 SET abc = fillstring(20," ")
 SET abc = format(temp3->icu_admit_dt_tm,"mm/dd/yyyy;;d")
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
 SET aps_prediction->bactivetx = temp4->dlist[y].activetx_ind
 SET aps_prediction->breadmit = temp3->readmit_ind
 SET aps_prediction->bima = temp3->ima_ind
 SET aps_prediction->bmidur = temp3->midur_ind
 SET aps_prediction->bventday1 = temp3->ventday1_ind
 SET aps_prediction->boobventday1 = maxval(temp3->oobventday1_ind,temp3->ventday1_ind)
 SET aps_prediction->boobintubday1 = temp3->oobintubday1_ind
 SET aps_prediction->bdiabetes = temp3->diabetes_ind
 SET aps_prediction->bmanagementsystem = 1
 SET aps_prediction->dwvar03hspxlos = temp3->var03hspxlos
 SET aps_prediction->dwpao2 = temp4->dlist[y].pao2
 SET aps_prediction->dwfio2 = temp4->dlist[y].fio2
 SET aps_prediction->dwejectfx = temp3->ejectfx
 SET aps_prediction->dwcreatinine = temp4->dlist[y].creatinine
 IF ((temp3->diedinicu_ind=1))
  SET temp3->discharge_location = "DEATH"
 ENDIF
 IF ((temp3->discharge_location="FLOOR"))
  SET aps_prediction->sdischargelocation = 4
 ELSEIF ((temp3->discharge_location="ICU_TRANSFER"))
  SET aps_prediction->sdischargelocation = 5
 ELSEIF ((temp3->discharge_location="OTHER_HOSP"))
  SET aps_prediction->sdischargelocation = 6
 ELSEIF ((temp3->discharge_location="HOME"))
  SET aps_prediction->sdischargelocation = 7
 ELSEIF ((temp3->discharge_location="OTHER"))
  SET aps_prediction->sdischargelocation = 8
 ELSEIF ((temp3->discharge_location="DEATH"))
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
 CALL echo(build("uar_AmsCalculatePredictions=",status))
 IF (status < 0)
  CALL echo(build("uar_AmsCalculatePredictions err=",uar_amsraprinterror(status)))
 ENDIF
 SET temp4->dlist[y].outcome_status = status
#outcomes_exit
#create_rad
 SET rad_id = 0.0
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   rad_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 IF (rad_id=0.0)
  SET error_string = "Error reading from carenet sequence, write new risk_adjustment_day row."
  SET error_flag = "Y"
 ELSE
  IF ((temp4->dlist[y].aps_score >= 0)
   AND (temp4->dlist[y].phys_res_pts >= 0))
   SET ap3_score = value((temp4->dlist[y].aps_score+ temp4->dlist[y].phys_res_pts))
  ELSE
   SET ap3_score = - (1)
  ENDIF
  INSERT  FROM risk_adjustment_day rad
   SET rad.risk_adjustment_day_id = rad_id, rad.risk_adjustment_id = ra_id, rad.cc_day = temp4->
    dlist[y].cc_day,
    rad.cc_beg_dt_tm = cnvtdatetime(temp4->dlist[y].cc_beg_dt_tm), rad.cc_end_dt_tm = cnvtdatetime(
     temp4->dlist[y].cc_end_dt_tm), rad.valid_from_dt_tm = cnvtdatetime(curdate,curtime3),
    rad.valid_until_dt_tm = cnvtdatetime("31-DEC-2100,00:00:00"), rad.intubated_ind = temp4->dlist[y]
    .intubated_ind, rad.intubated_ce_id = temp4->dlist[y].intub_ce_id,
    rad.vent_ind = temp4->dlist[y].vent_ind, rad.worst_gcs_eye_score = temp4->dlist[y].eyes, rad
    .worst_gcs_motor_score = temp4->dlist[y].motor,
    rad.worst_gcs_verbal_score = temp4->dlist[y].verbal, rad.meds_ind = temp4->dlist[y].meds_ind, rad
    .eyes_ce_id = temp4->dlist[y].eyes_ce_id,
    rad.motor_ce_id = temp4->dlist[y].motor_ce_id, rad.verbal_ce_id = temp4->dlist[y].verbal_ce_id,
    rad.meds_ce_id = temp4->dlist[y].meds_ce_id,
    rad.urine_output = temp4->dlist[y].urine, rad.urine_24hr_output = temp4->dlist[y].urine_24hr, rad
    .worst_wbc_result = temp4->dlist[y].wbc,
    rad.wbc_ce_id = temp4->dlist[y].wbc_ce_id, rad.worst_temp = temp4->dlist[y].temp, rad.temp_ce_id
     = temp4->dlist[y].temp_ce_id,
    rad.worst_resp_result = temp4->dlist[y].resp, rad.resp_ce_id = temp4->dlist[y].resp_ce_id, rad
    .worst_sodium_result = temp4->dlist[y].sodium,
    rad.sodium_ce_id = temp4->dlist[y].sodium_ce_id, rad.worst_heart_rate = temp4->dlist[y].heartrate,
    rad.heartrate_ce_id = temp4->dlist[y].heartrate_ce_id,
    rad.mean_blood_pressure = temp4->dlist[y].meanbp, rad.worst_ph_result = temp4->dlist[y].ph, rad
    .ph_ce_id = temp4->dlist[y].ph_ce_id,
    rad.worst_hematocrit = temp4->dlist[y].hematocrit, rad.hematocrit_ce_id = temp4->dlist[y].
    hematocrit_ce_id, rad.worst_creatinine_result = temp4->dlist[y].creatinine,
    rad.creatinine_ce_id = temp4->dlist[y].creatinine_ce_id, rad.worst_albumin_result = temp4->dlist[
    y].albumin, rad.albumin_ce_id = temp4->dlist[y].albumin_ce_id,
    rad.worst_pao2_result = temp4->dlist[y].pao2, rad.pao2_ce_id = temp4->dlist[y].pao2_ce_id, rad
    .worst_pco2_result = temp4->dlist[y].pco2,
    rad.pco2_ce_id = temp4->dlist[y].pco2_ce_id, rad.worst_bun_result = temp4->dlist[y].bun, rad
    .bun_ce_id = temp4->dlist[y].bun_ce_id,
    rad.worst_glucose_result = temp4->dlist[y].glucose, rad.glucose_ce_id = temp4->dlist[y].
    glucose_ce_id, rad.worst_bilirubin_result = temp4->dlist[y].bilirubin,
    rad.bilirubin_ce_id = temp4->dlist[y].bilirubin_ce_id, rad.worst_potassium_result = temp4->dlist[
    y].potassium, rad.potassium_ce_id = temp4->dlist[y].potassium_ce_id,
    rad.worst_fio2_result = temp4->dlist[y].fio2, rad.fio2_ce_id = temp4->dlist[y].fio2_ce_id, rad
    .aps_score = temp4->dlist[y].aps_score,
    rad.aps_day1 = temp4->dlist[y].aps_day1, rad.aps_yesterday = temp4->dlist[y].aps_yesterday, rad
    .activetx_ind = temp4->dlist[y].activetx_ind,
    rad.vent_today_ind = temp4->dlist[y].vent_today_ind, rad.pa_line_today_ind = temp4->dlist[y].
    pa_line_today_ind, rad.outcome_status = temp4->dlist[y].outcome_status,
    rad.apache_iii_score = ap3_score, rad.phys_res_pts = value(temp4->dlist[y].phys_res_pts), rad
    .active_ind = 1,
    rad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rad.active_status_prsnl_id = reqinfo->
    updt_id, rad.active_status_cd = reqdata->active_status_cd,
    rad.updt_dt_tm = cnvtdatetime(curdate,curtime3), rad.updt_id = reqinfo->updt_id, rad.updt_task =
    reqinfo->updt_task,
    rad.updt_applctx = reqinfo->updt_applctx, rad.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_string = "Error writing new risk_adjustment_day row."
   SET error_flag = "Y"
  ELSE
   SET ap2_qual = 0
   SELECT INTO "nl:"
    FROM risk_adjustment_event rae
    PLAN (rae
     WHERE rae.risk_adjustment_id=ra_id
      AND rae.active_ind=1)
    DETAIL
     IF (uar_get_code_display(rae.sentinel_event_code_cd)="SEPSIS*")
      ap2_qual = 1
     ENDIF
    WITH nocounter
   ;end select
   IF ((temp3->admitdiagnosis="SEPSIS*"))
    SET ap2_qual = 1
   ENDIF
   IF (ap2_qual=1)
    SET ap2_parameters->risk_adjustment_id = ra_id
    SET ap2_parameters->cc_day = temp4->dlist[y].cc_day
    SET ap2_parameters->cc_beg_dt_tm = cnvtdatetime(temp4->dlist[y].cc_beg_dt_tm)
    SET ap2_parameters->cc_end_dt_tm = cnvtdatetime(temp4->dlist[y].cc_end_dt_tm)
    EXECUTE dcp_calc_apache_ii_score
   ENDIF
   IF ((temp4->dlist[y].outcome_status > 0))
    IF ((temp4->dlist[y].cc_day=1))
     SET act_icu_ever = - (1)
    ENDIF
    FOR (num = 1 TO 100)
      IF ((aps_outcome->qual[num].szequationname > " "))
       SET equationname = trim(aps_outcome->qual[num].szequationname)
       IF ((temp4->dlist[y].cc_day=1))
        IF (equationname="ACT_ICU_EVER")
         SET act_icu_ever = - (1)
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
       ELSE
        INSERT  FROM risk_adjustment_outcomes rao
         SET rao.risk_adjustment_outcomes_id = rao_id, rao.risk_adjustment_day_id = rad_id, rao
          .equation_name = trim(equationname),
          rao.outcome_value = cnvtreal(aps_outcome->qual[num].dwoutcome), rao.valid_from_dt_tm =
          cnvtdatetime(curdate,curtime3), rao.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"
           ),
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
         SET error_string = "Error writing new risk_adjustment_outcomes row."
         SET error_flag = "Y"
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
 IF ((temp4->dlist[y].cc_day=1)
  AND error_flag="N")
  SET therapy_level = - (1)
  IF ((((temp4->dlist[y].outcome_status=- (23117))) OR ((((temp4->dlist[y].outcome_status=- (23100)))
   OR ((temp4->dlist[y].outcome_status=- (23103)))) )) )
   IF ((temp4->dlist[y].activetx_ind=1))
    SET therapy_level = 5
   ELSEIF ((temp4->dlist[y].activetx_ind=0))
    SET therapy_level = 4
   ENDIF
  ELSE
   IF ((temp4->dlist[y].activetx_ind=1))
    SET therapy_level = 1
   ELSEIF ((temp4->dlist[y].activetx_ind=0)
    AND act_icu_ever >= 0.0
    AND (temp4->dlist[y].outcome_status > 0))
    IF (((act_icu_ever * 100.0) < 10.0))
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
#create_rad_exit
#new_worst_check
 SET ce_id = 0.0
 SET unset_vent_ind = 0
 SET found_tiss_change = 0
 SET gcs_flag = 0
 SET last_day = 0
 SET abg_flag = 0
 FOR (y = 1 TO temp->clist[x].dcnt)
   IF ((last_day != temp->clist[x].dlist[y].cc_day))
    SET last_day = temp->clist[x].dlist[y].cc_day
    SET gcs_flag = 0
    SET abg_flag = 0
   ENDIF
   IF ((temp->clist[x].dlist[y].worst_resolved_ind=0))
    SET search_beg_dt_tm = cnvtdatetime(temp->clist[x].dlist[y].cc_beg_dt_tm)
    SET search_end_dt_tm = cnvtdatetime(temp->clist[x].dlist[y].cc_end_dt_tm)
    SET my_disp = uar_get_code_display(temp->clist[x].dlist[y].event_cd)
    IF ((temp->clist[x].dlist[y].tiss_ce_ind=1))
     SET parameters->risk_adjustment_id = temp->clist[x].risk_adjustment_id
     SET parameters->beg_day_dt_tm = cnvtdatetime(temp->clist[x].dlist[y].cc_beg_dt_tm)
     SET parameters->end_day_dt_tm = cnvtdatetime(temp->clist[x].dlist[y].cc_end_dt_tm)
     SET parameters->org_id = temp->clist[x].org_id
     SET parameters->person_id = temp->clist[x].person_id
     SET parameters->accept_tiss_acttx_if_ind = temp->clist[x].accept_tiss_acttx_if_ind
     SET parameters->accept_tiss_nonacttx_if_ind = temp->clist[x].accept_tiss_nonacttx_if_ind
     SET parameters->found_item = - (1)
     EXECUTE dcp_get_apache_tiss_from_ce
     IF ((parameters->found_item=1))
      SET found_tiss_change = 1
      SET temp->clist[x].tiss_changed_ind = 1
     ELSE
      SET temp->clist[x].tiss_changed_ind = 0
     ENDIF
    ELSE
     CASE (temp->clist[x].dlist[y].event_cd)
      OF wbc_cd:
       EXECUTE FROM worst_wbc TO worst_wbc_exit
      OF sodium_cd:
       EXECUTE FROM worst_sodium TO worst_sodium_exit
      OF hematocrit_cd:
       EXECUTE FROM worst_hematocrit TO worst_hematocrit_exit
      OF creatinine_cd:
       EXECUTE FROM worst_creatinine TO worst_creatinine_exit
      OF creatinine2_cd:
       EXECUTE FROM worst_creatinine TO worst_creatinine_exit
      OF albumin_cd:
       EXECUTE FROM worst_albumin TO worst_albumin_exit
      OF bilirubin_cd:
       EXECUTE FROM worst_bilirubin TO worst_bilirubin_exit
      OF potassium_cd:
       EXECUTE FROM worst_potassium TO worst_potassium_exit
      OF bun_cd:
       EXECUTE FROM worst_bun TO worst_bun_exit
      OF glucose_cd:
       EXECUTE FROM worst_glucose TO worst_glucose_exit
      OF glucose2_cd:
       EXECUTE FROM worst_glucose TO worst_glucose_exit
      OF glucose3_cd:
       EXECUTE FROM worst_glucose TO worst_glucose_exit
      OF glucose4_cd:
       EXECUTE FROM worst_glucose TO worst_glucose_exit
      OF glucose5_cd:
       EXECUTE FROM worst_glucose TO worst_glucose_exit
      OF glucose6_cd:
       EXECUTE FROM worst_glucose TO worst_glucose_exit
      OF glucose7_cd:
       EXECUTE FROM worst_glucose TO worst_glucose_exit
      OF glucose8_cd:
       EXECUTE FROM worst_glucose TO worst_glucose_exit
      OF glucose9_cd:
       EXECUTE FROM worst_glucose TO worst_glucose_exit
      OF glucose10_cd:
       EXECUTE FROM worst_glucose TO worst_glucose_exit
      OF temp1_cd:
       EXECUTE FROM worst_temp TO worst_temp_exit
      OF temp2_cd:
       EXECUTE FROM worst_temp TO worst_temp_exit
      OF temp3_cd:
       EXECUTE FROM worst_temp TO worst_temp_exit
      OF temp4_cd:
       EXECUTE FROM worst_temp TO worst_temp_exit
      OF temp5_cd:
       EXECUTE FROM worst_temp TO worst_temp_exit
      OF temp6_cd:
       EXECUTE FROM worst_temp TO worst_temp_exit
      OF urine1_cd:
       EXECUTE FROM urine_output TO urine_output_exit
      OF urine2_cd:
       EXECUTE FROM urine_output TO urine_output_exit
      OF urine3_cd:
       EXECUTE FROM urine_output TO urine_output_exit
      OF heartrate_cd:
       EXECUTE FROM worst_heartrate TO worst_heartrate_exit
      OF heartrate2_cd:
       EXECUTE FROM worst_heartrate TO worst_heartrate_exit
      OF heartrate3_cd:
       EXECUTE FROM worst_heartrate TO worst_heartrate_exit
      OF pulse_cd:
       EXECUTE FROM worst_heartrate TO worst_heartrate_exit
      OF systolic_cd:
       IF (use_map_ind=0)
        EXECUTE FROM worst_meanbp TO worst_meanbp_exit
       ENDIF
      OF diastolic_cd:
       IF (use_map_ind=0)
        EXECUTE FROM worst_meanbp TO worst_meanbp_exit
       ENDIF
      OF systolic2_cd:
       IF (use_map_ind=0)
        EXECUTE FROM worst_meanbp TO worst_meanbp_exit
       ENDIF
      OF diastolic2_cd:
       IF (use_map_ind=0)
        EXECUTE FROM worst_meanbp TO worst_meanbp_exit
       ENDIF
      OF systolic3_cd:
       IF (use_map_ind=0)
        EXECUTE FROM worst_meanbp TO worst_meanbp_exit
       ENDIF
      OF diastolic3_cd:
       IF (use_map_ind=0)
        EXECUTE FROM worst_meanbp TO worst_meanbp_exit
       ENDIF
      OF diastolic4_cd:
       IF (use_map_ind=0)
        EXECUTE FROM worst_meanbp TO worst_meanbp_exit
       ENDIF
      OF resp_cd:
       EXECUTE FROM worst_resp TO worst_resp_exit
      OF pao2_cd:
       IF (abg_flag=0)
        EXECUTE FROM worst_abg TO worst_abg_exit
        SET abg_flag = (abg_flag+ 1)
       ELSE
        EXECUTE FROM worst_abg_copy TO worst_abg_copy_exit
       ENDIF
       IF ((temp->clist[x].dlist[y].new_worst <= 0))
        SET temp->clist[x].dlist[y].new_worst = temp->clist[x].dlist[y].old_worst
        SET temp->clist[x].dlist[y].new_worst_ce_id = temp->clist[x].dlist[y].old_worst_ce_id
       ENDIF
      OF pco2_cd:
       IF (abg_flag=0)
        EXECUTE FROM worst_abg TO worst_abg_exit
        SET abg_flag = (abg_flag+ 1)
       ELSE
        EXECUTE FROM worst_abg_copy TO worst_abg_copy_exit
       ENDIF
       IF ((temp->clist[x].dlist[y].new_worst <= 0))
        SET temp->clist[x].dlist[y].new_worst = temp->clist[x].dlist[y].old_worst
        SET temp->clist[x].dlist[y].new_worst_ce_id = temp->clist[x].dlist[y].old_worst_ce_id
       ENDIF
      OF fio2_cd:
       IF (abg_flag=0)
        EXECUTE FROM worst_abg TO worst_abg_exit
        SET abg_flag = (abg_flag+ 1)
       ELSE
        EXECUTE FROM worst_abg_copy TO worst_abg_copy_exit
       ENDIF
       IF ((temp->clist[x].dlist[y].new_worst <= 0))
        SET temp->clist[x].dlist[y].new_worst = temp->clist[x].dlist[y].old_worst
        SET temp->clist[x].dlist[y].new_worst_ce_id = temp->clist[x].dlist[y].old_worst_ce_id
       ENDIF
      OF ph_cd:
       IF (abg_flag=0)
        EXECUTE FROM worst_abg TO worst_abg_exit
        SET abg_flag = (abg_flag+ 1)
       ELSE
        EXECUTE FROM worst_abg_copy TO worst_abg_copy_exit
       ENDIF
       IF ((temp->clist[x].dlist[y].new_worst <= 0))
        SET temp->clist[x].dlist[y].new_worst = temp->clist[x].dlist[y].old_worst
        SET temp->clist[x].dlist[y].new_worst_ce_id = temp->clist[x].dlist[y].old_worst_ce_id
       ENDIF
      OF intub_cd:
       IF (abg_flag=0)
        EXECUTE FROM worst_abg TO worst_abg_exit
        SET abg_flag = (abg_flag+ 1)
       ELSE
        EXECUTE FROM worst_abg_copy TO worst_abg_copy_exit
       ENDIF
       IF ((temp->clist[x].dlist[y].new_worst <= 0))
        SET temp->clist[x].dlist[y].new_worst = temp->clist[x].dlist[y].old_worst
        SET temp->clist[x].dlist[y].new_worst_ce_id = temp->clist[x].dlist[y].old_worst_ce_id
       ENDIF
      OF intub2_cd:
       IF (abg_flag=0)
        EXECUTE FROM worst_abg TO worst_abg_exit
        SET abg_flag = (abg_flag+ 1)
       ELSE
        EXECUTE FROM worst_abg_copy TO worst_abg_copy_exit
       ENDIF
       IF ((temp->clist[x].dlist[y].new_worst <= 0))
        SET temp->clist[x].dlist[y].new_worst = temp->clist[x].dlist[y].old_worst
        SET temp->clist[x].dlist[y].new_worst_ce_id = temp->clist[x].dlist[y].old_worst_ce_id
       ENDIF
      OF meds_cd:
       IF (gcs_flag=0)
        EXECUTE FROM worst_gcs TO worst_gcs_exit
        SET gcs_resolve_flag = temp->clist[x].dlist[y].worst_resolved_ind
        SET gcs_flag = (gcs_flag+ 1)
       ELSE
        EXECUTE FROM worst_gcs_copy TO worst_gcs_copy_exit
       ENDIF
       IF ((temp->clist[x].dlist[y].new_worst <= 0))
        SET temp->clist[x].dlist[y].new_worst = temp->clist[x].dlist[y].old_worst
        SET temp->clist[x].dlist[y].new_worst_ce_id = temp->clist[x].dlist[y].old_worst_ce_id
       ENDIF
      OF motor_cd:
       IF (gcs_flag=0)
        EXECUTE FROM worst_gcs TO worst_gcs_exit
        SET gcs_resolve_flag = temp->clist[x].dlist[y].worst_resolved_ind
        SET gcs_flag = (gcs_flag+ 1)
       ELSE
        EXECUTE FROM worst_gcs_copy TO worst_gcs_copy_exit
       ENDIF
       IF ((temp->clist[x].dlist[y].new_worst <= 0))
        SET temp->clist[x].dlist[y].new_worst = temp->clist[x].dlist[y].old_worst
        SET temp->clist[x].dlist[y].new_worst_ce_id = temp->clist[x].dlist[y].old_worst_ce_id
       ENDIF
      OF verbal_cd:
       IF (gcs_flag=0)
        EXECUTE FROM worst_gcs TO worst_gcs_exit
        SET gcs_resolve_flag = temp->clist[x].dlist[y].worst_resolved_ind
        SET gcs_flag = (gcs_flag+ 1)
       ELSE
        EXECUTE FROM worst_gcs_copy TO worst_gcs_copy_exit
       ENDIF
       IF ((temp->clist[x].dlist[y].new_worst <= 0))
        SET temp->clist[x].dlist[y].new_worst = temp->clist[x].dlist[y].old_worst
        SET temp->clist[x].dlist[y].new_worst_ce_id = temp->clist[x].dlist[y].old_worst_ce_id
       ENDIF
      OF eyes_cd:
       IF (gcs_flag=0)
        CALL echo("about to get worst gcs")
        EXECUTE FROM worst_gcs TO worst_gcs_exit
        SET gcs_resolve_flag = temp->clist[x].dlist[y].worst_resolved_ind
        SET gcs_flag = (gcs_flag+ 1)
       ELSE
        EXECUTE FROM worst_gcs_copy TO worst_gcs_copy_exit
       ENDIF
       IF ((temp->clist[x].dlist[y].new_worst <= 0))
        SET temp->clist[x].dlist[y].new_worst = temp->clist[x].dlist[y].old_worst
        SET temp->clist[x].dlist[y].new_worst_ce_id = temp->clist[x].dlist[y].old_worst_ce_id
       ENDIF
     ENDCASE
    ENDIF
   ENDIF
   IF ((temp->clist[x].dlist[y].worst_resolved_ind=0)
    AND (temp->clist[x].dlist[y].new_worst_ce_id <= 0)
    AND (temp->clist[x].dlist[y].old_worst_ce_id > 0))
    SET temp->clist[x].dlist[y].old_worst = - (1.0)
    SET temp->clist[x].dlist[y].worst_resolved_ind = 2
   ENDIF
 ENDFOR
 IF (((one_new_worst="Y") OR (found_tiss_change=1)) )
  SELECT INTO "nl:"
   FROM risk_adjustment ra
   PLAN (ra
    WHERE (ra.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
     AND ra.active_ind=1)
   DETAIL
    temp3->risk_adjustment_id = ra.risk_adjustment_id, temp3->person_id = ra.person_id, temp3->
    encntr_id = ra.encntr_id,
    temp3->icu_admit_dt_tm = cnvtdatetime(ra.icu_admit_dt_tm), temp3->icu_disch_dt_tm = cnvtdatetime(
     ra.icu_disch_dt_tm), temp3->admit_source = ra.admit_source,
    temp3->admitsource_flag = ra.admitsource_flag, temp3->discharge_location = uar_get_code_meaning(
     ra.discharge_location_cd), temp3->hrs_at_source = ra.hrs_at_source,
    temp3->body_system = ra.body_system, temp3->admitdiagnosis = ra.admit_diagnosis, temp3->
    disease_category_cd = ra.disease_category_cd,
    temp3->therapy_level = ra.therapy_level, temp3->xfer_within_48hr_ind = ra.xfer_within_48hr_ind,
    temp3->electivesurgery_ind = ra.electivesurgery_ind,
    temp3->readmit_ind = ra.readmit_ind, temp3->readmit_within_24hr_ind = ra.readmit_within_24hr_ind,
    temp3->age = ra.admit_age,
    temp3->hosp_admit_dt_tm = cnvtdatetime(ra.hosp_admit_dt_tm), temp3->gender = ra.gender_flag,
    temp3->teach_type_flag = ra.teach_type_flag,
    temp3->region_flag = ra.region_flag, temp3->bedcount = ra.bed_count, temp3->dialysis_ind = ra
    .dialysis_ind,
    temp3->aids_ind = ra.aids_ind, temp3->hepaticfailure_ind = ra.hepaticfailure_ind, temp3->
    lymphoma_ind = ra.lymphoma_ind,
    temp3->metastaticcancer_ind = ra.metastaticcancer_ind, temp3->leukemia_ind = ra.leukemia_ind,
    temp3->immunosuppression_ind = ra.immunosuppression_ind,
    temp3->cirrhosis_ind = ra.cirrhosis_ind, temp3->diabetes_ind = ra.diabetes_ind, temp3->copd_flag
     = ra.copd_flag,
    temp3->copd_ind = ra.copd_ind, temp3->chronic_health_unavail_ind = ra.chronic_health_unavail_ind,
    temp3->chronic_health_none_ind = ra.chronic_health_none_ind,
    temp3->ami_location = ra.ami_location, temp3->ptca_device = ra.ptca_device, temp3->
    thrombolytics_ind = ra.thrombolytics_ind,
    temp3->nbr_grafts_performed = ra.nbr_grafts_performed, temp3->ima_ind = ra.ima_ind, temp3->
    midur_ind = ra.midur_ind,
    temp3->sv_graft_ind = ra.sv_graft_ind, temp3->mi_within_6mo_ind = ra.mi_within_6mo_ind, temp3->
    cc_during_stay_ind = ra.cc_during_stay_ind,
    temp3->var03hspxlos = ra.var03hspxlos_value, temp3->ejectfx = ra.ejectfx_fraction, temp3->
    diedinicu_ind = ra.diedinicu_ind,
    temp3->adm_doc_id = ra.adm_doc_id, temp3->therapy_level = ra.therapy_level, temp3->
    disease_category_cd = ra.disease_category_cd,
    temp3->med_service_cd = ra.med_service_cd, temp3->admit_icu_cd = ra.admit_icu_cd
   WITH nocounter
  ;end select
  SET hdeath_parameters->risk_adjustment_id = temp3->risk_adjustment_id
  EXECUTE cco_get_died_hosp_from_ra
  SET temp3->diedinhospital_ind = hdeath_reply->hosp_death_ind
  SELECT INTO "nl:"
   FROM risk_adjustment_day rad
   PLAN (rad
    WHERE (rad.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
     AND rad.cc_day=1
     AND rad.active_ind=1)
   DETAIL
    temp3->ventday1_ind = rad.vent_today_ind, temp3->oobventday1_ind = rad.vent_ind, temp3->
    oobintubday1_ind = rad.intubated_ind
   WITH nocounter
  ;end select
  SET cc_day = 0
  FOR (y = 1 TO temp->clist[x].dcnt)
    IF ((((temp->clist[x].dlist[y].worst_resolved_ind=2)) OR ((temp->clist[x].dlist[y].tiss_ce_ind=1)
    )) )
     SET cc_day = temp->clist[x].dlist[y].cc_day
     SET y = temp->clist[x].dcnt
    ENDIF
  ENDFOR
  IF (cc_day=0)
   SET cc_day = 1
  ENDIF
  SET day_cnt = 0
  SELECT INTO "nl:"
   FROM risk_adjustment_day rad
   PLAN (rad
    WHERE (rad.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
     AND rad.active_ind=1)
   ORDER BY rad.cc_day
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(temp4->dlist,cnt), temp4->dlist[cnt].risk_adjustment_id = rad
    .risk_adjustment_id,
    temp4->dlist[cnt].risk_adjustment_day_id = rad.risk_adjustment_day_id, temp4->dlist[cnt].cc_day
     = rad.cc_day, temp4->dlist[cnt].cc_beg_dt_tm = cnvtdatetime(rad.cc_beg_dt_tm),
    temp4->dlist[cnt].cc_end_dt_tm = cnvtdatetime(rad.cc_end_dt_tm), temp4->dlist[cnt].intubated_ind
     = rad.intubated_ind, temp4->dlist[cnt].intub_ce_id = rad.intubated_ce_id,
    temp4->dlist[cnt].vent_ind = rad.vent_ind, temp4->dlist[cnt].eyes = rad.worst_gcs_eye_score,
    temp4->dlist[cnt].motor = rad.worst_gcs_motor_score,
    temp4->dlist[cnt].verbal = rad.worst_gcs_verbal_score, temp4->dlist[cnt].meds_ind = rad.meds_ind,
    temp4->dlist[cnt].eyes_ce_id = rad.eyes_ce_id,
    temp4->dlist[cnt].motor_ce_id = rad.motor_ce_id, temp4->dlist[cnt].verbal_ce_id = rad
    .verbal_ce_id, temp4->dlist[cnt].meds_ce_id = rad.meds_ce_id,
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
    temp4->dlist[cnt].pco2_ce_id = rad.pco2_ce_id, temp4->dlist[cnt].bun = rad.worst_bun_result,
    temp4->dlist[cnt].bun_ce_id = rad.bun_ce_id,
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
  IF (day_cnt > 0)
   FOR (y = cc_day TO day_cnt)
     UPDATE  FROM risk_adjustment_outcomes rao
      SET rao.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rao.active_ind = 0, rao
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       rao.updt_dt_tm = cnvtdatetime(curdate,curtime3), rao.updt_task = reqinfo->updt_task, rao
       .updt_applctx = reqinfo->updt_applctx,
       rao.updt_id = reqinfo->updt_id, rao.updt_cnt = (rao.updt_cnt+ 1)
      WHERE (rao.risk_adjustment_day_id=temp4->dlist[y].risk_adjustment_day_id)
      WITH nocounter
     ;end update
     UPDATE  FROM risk_adjustment_day rad
      SET rad.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rad.active_ind = 0, rad
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       rad.updt_dt_tm = cnvtdatetime(curdate,curtime3), rad.updt_task = reqinfo->updt_task, rad
       .updt_applctx = reqinfo->updt_applctx,
       rad.updt_id = reqinfo->updt_id, rad.updt_cnt = (rad.updt_cnt+ 1)
      WHERE (rad.risk_adjustment_day_id=temp4->dlist[y].risk_adjustment_day_id)
      WITH nocounter
     ;end update
     FOR (z = 1 TO temp->clist[x].dcnt)
       IF ((temp->clist[x].dlist[z].cc_day=temp4->dlist[y].cc_day))
        IF ((temp->clist[x].dlist[z].worst_resolved_ind=2))
         IF ((temp->clist[x].dlist[z].event_cd=wbc_cd))
          SET temp4->dlist[y].wbc = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].wbc_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=sodium_cd))
          SET temp4->dlist[y].sodium = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].sodium_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=hematocrit_cd))
          SET temp4->dlist[y].hematocrit = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].hematocrit_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd IN (creatinine_cd, creatinine2_cd)))
          SET temp4->dlist[y].creatinine = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].creatinine_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=albumin_cd))
          SET temp4->dlist[y].albumin = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].albumin_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=bilirubin_cd))
          SET temp4->dlist[y].bilirubin = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].bilirubin_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=potassium_cd))
          SET temp4->dlist[y].potassium = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].potassium_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=bun_cd))
          SET temp4->dlist[y].bun = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].bun_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd IN (glucose_cd, glucose2_cd, glucose3_cd,
         glucose4_cd, glucose5_cd,
         glucose6_cd, glucose7_cd, glucose8_cd, glucose9_cd, glucose10_cd)))
          SET temp4->dlist[y].glucose = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].glucose_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd IN (heartrate_cd, heartrate2_cd, heartrate3_cd,
         pulse_cd)))
          SET temp4->dlist[y].heartrate = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].heartrate_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((((temp->clist[x].dlist[z].event_cd=systolic_cd)) OR ((((temp->clist[x].dlist[z].
         event_cd=systolic2_cd)) OR ((temp->clist[x].dlist[z].event_cd=systolic3_cd))) )) )
          SET temp4->dlist[y].meanbp = temp->clist[x].dlist[z].new_worst
         ELSEIF ((((temp->clist[x].dlist[z].event_cd=diastolic_cd)) OR ((((temp->clist[x].dlist[z].
         event_cd=diastolic2_cd)) OR ((((temp->clist[x].dlist[z].event_cd=diastolic3_cd)) OR ((temp->
         clist[x].dlist[z].event_cd=diastolic4_cd))) )) )) )
          SET temp4->dlist[y].meanbp = temp->clist[x].dlist[z].new_worst
         ELSEIF ((temp->clist[x].dlist[z].event_cd IN (urine1_cd, urine2_cd, urine3_cd)))
          SET temp4->dlist[y].urine = temp->clist[x].dlist[z].urine_total
          SET temp4->dlist[y].urine_24hr = temp->clist[x].dlist[z].urine_24hr
         ELSEIF ((temp->clist[x].dlist[z].event_cd=resp_cd))
          SET temp4->dlist[y].resp = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].resp_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
          SET temp4->dlist[y].vent_ind = temp->clist[x].dlist[z].new_vent_ind
         ELSEIF ((temp->clist[x].dlist[z].event_cd IN (temp1_cd, temp2_cd, temp3_cd, temp4_cd,
         temp5_cd,
         temp6_cd)))
          SET temp4->dlist[y].temp = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].temp_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=pao2_cd))
          SET temp4->dlist[y].pao2 = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].pao2_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=pco2_cd))
          SET temp4->dlist[y].pco2 = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].pco2_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=fio2_cd))
          SET temp4->dlist[y].fio2 = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].fio2_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
          IF ((temp->clist[x].dlist[z].set_rel_intub_ind=1))
           SET temp4->dlist[y].intubated_ind = temp->clist[x].dlist[z].new_rel_intub
           SET temp4->dlist[y].intub_ce_id = temp->clist[x].dlist[z].new_rel_intub_ce_id
          ENDIF
         ELSEIF ((temp->clist[x].dlist[z].event_cd=ph_cd))
          SET temp4->dlist[y].ph = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].ph_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=intub_cd))
          SET temp4->dlist[y].intubated_ind = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].intub_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=intub2_cd))
          SET temp4->dlist[y].intubated_ind = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].intub_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=meds_cd))
          SET temp4->dlist[y].meds_ind = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].meds_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=eyes_cd))
          SET temp4->dlist[y].eyes = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].eyes_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=motor_cd))
          SET temp4->dlist[y].motor = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].motor_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
         ELSEIF ((temp->clist[x].dlist[z].event_cd=verbal_cd))
          SET temp4->dlist[y].verbal = temp->clist[x].dlist[z].new_worst
          SET temp4->dlist[y].verbal_ce_id = temp->clist[x].dlist[z].new_worst_ce_id
          IF ((temp4->dlist[y].meds_ind=- (1)))
           SET temp4->dlist[y].meds_ind = 0
          ENDIF
         ELSE
          CALL echo(build("other not mapped",uar_get_code_display(temp->clist[x].dlist[z].event_cd)))
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   SET error_flag = "N"
   FOR (y = cc_day TO day_cnt)
     EXECUTE FROM aps TO aps_exit
     IF ((temp4->dlist[y].outcome_status >= 0))
      EXECUTE FROM outcomes TO outcomes_exit
     ENDIF
     SET ra_id = temp->clist[x].risk_adjustment_id
     EXECUTE FROM create_rad TO create_rad_exit
     IF (error_flag="Y")
      SET y = day_cnt
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
#new_worst_check_exit
#worst_gcs
 SET hold_motor = - (1.0)
 SET hold_verbal = - (1.0)
 SET hold_eyes = - (1.0)
 SET hold_meds = - (1.0)
 SET hold_meds_ce_id = 0.0
 SET hold_eyes_ce_id = 0.0
 SET hold_motor_ce_id = 0.0
 SET hold_verbal_ce_id = 0.0
 SET temp_meds_ce_id = 0.0
 SET temp_eyes_ce_id = 0.0
 SET temp_motor_ce_id = 0.0
 SET temp_verbal_ce_id = 0.0
 SET gcs_total = 16.0
 SET temp_eyes = 0.0
 SET temp_motor = 0.0
 SET temp_verbal = 0.0
 SET temp_meds = 0.0
 SET hold_motor = - (1.0)
 SET hold_verbal = - (1.0)
 SET hold_eyes = - (1.0)
 SET hold_meds = - (1.0)
 SET eyes_cd = 0.0
 SET motor_cd = 0.0
 SET verbal_cd = 0.0
 SET meds_cd = 0.0
 SET eyes_cd = uar_get_code_by_cki(nullterm("CKI.EC!5524"))
 SET motor_cd = uar_get_code_by_cki(nullterm("CKI.EC!5525"))
 SET verbal_cd = uar_get_code_by_cki(nullterm("CKI.EC!89"))
 SET meds_cd = uar_get_code_by_cki(nullterm("CKI.EC!7675"))
 IF (((eyes_cd > 0.0
  AND motor_cd > 0.0
  AND verbal_cd > 0.0) OR (meds_cd > 0.0)) )
  SET rad_gcs_total = 16
  SET use_this_ra_id = temp->clist[x].risk_adjustment_id
  CALL echo(build("going to query on ra_id=",use_this_ra_id))
  SELECT INTO "nl:"
   FROM clinical_event ce,
    risk_adjustment ra,
    risk_adjustment_day rad
   PLAN (ce
    WHERE (ce.person_id=temp->clist[x].person_id)
     AND ((ce.event_cd=eyes_cd) OR (((ce.event_cd=motor_cd) OR (((ce.event_cd=verbal_cd) OR (ce
    .event_cd=meds_cd)) )) ))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != ops_inerror_cd
     AND ce.event_cd > 0)
    JOIN (ra
    WHERE ra.person_id=ce.person_id
     AND ra.risk_adjustment_id=use_this_ra_id
     AND ra.active_ind=1)
    JOIN (rad
    WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
     AND (rad.cc_day=temp->clist[x].dlist[y].cc_day)
     AND rad.active_ind=1)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm), cnvtdatetime(ce.updt_dt_tm)
   HEAD REPORT
    IF (rad.meds_ind=1)
     IF (rad.meds_ce_id=0)
      rad_gcs_total = 15
     ENDIF
    ELSEIF (rad.worst_gcs_eye_score > 0
     AND rad.worst_gcs_motor_score > 0
     AND rad.worst_gcs_verbal_score > 0)
     IF (rad.eyes_ce_id=0)
      rad_gcs_total = ((rad.worst_gcs_eye_score+ rad.worst_gcs_motor_score)+ rad
      .worst_gcs_verbal_score)
     ENDIF
    ENDIF
    temp_total = 0.0, hold_eyes = 0.0, hold_motor = 0.0,
    hold_verbal = 0.0, hold_meds = - (1.0), temp_eyes = 0.0,
    temp_motor = 0.0, temp_verbal = 0.0, temp_meds = - (1.0),
    isnum = 0
   HEAD ce.event_end_dt_tm
    temp_eyes = 0.0, temp_motor = 0.0, temp_verbal = 0.0,
    temp_meds = 0.0
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
      IF ((temp->clist[x].age < 6))
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
    IF ((temp_meds=- (1)))
     temp_meds = 0
    ENDIF
    IF (((temp_eyes > 0
     AND temp_motor > 0
     AND temp_verbal > 0) OR (temp_meds > 0)) )
     IF (temp_meds=1)
      temp_total = 15, temp_eyes = - (1), temp_motor = - (1),
      temp_verbal = - (1), temp_eyes_ce_id = 0, temp_motor_ce_id = 0,
      temp_verbal_ce_id = 0
     ELSE
      temp_total = ((temp_eyes+ temp_motor)+ temp_verbal)
     ENDIF
     IF (((temp_total < gcs_total) OR (gcs_total=0)) )
      gcs_total = temp_total, hold_eyes = temp_eyes, hold_motor = temp_motor,
      hold_verbal = temp_verbal, hold_meds = temp_meds, hold_eyes_ce_id = temp_eyes_ce_id,
      hold_motor_ce_id = temp_motor_ce_id, hold_verbal_ce_id = temp_verbal_ce_id, hold_meds_ce_id =
      temp_meds_ce_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (((gcs_total < 1) OR (gcs_total >= rad_gcs_total)) )
   SET temp->clist[x].dlist[y].worst_resolved_ind = 1
  ELSE
   SET one_new_worst = "Y"
   SET temp->clist[x].dlist[y].worst_resolved_ind = 2
   IF ((temp->clist[x].dlist[y].event_cd=meds_cd))
    SET temp->clist[x].dlist[y].new_worst = hold_meds
    SET temp->clist[x].dlist[y].new_worst_ce_id = hold_meds_ce_id
   ELSEIF ((temp->clist[x].dlist[y].event_cd=motor_cd))
    SET temp->clist[x].dlist[y].new_worst = hold_motor
    SET temp->clist[x].dlist[y].new_worst_ce_id = hold_motor_ce_id
   ELSEIF ((temp->clist[x].dlist[y].event_cd=eyes_cd))
    SET temp->clist[x].dlist[y].new_worst = hold_eyes
    SET temp->clist[x].dlist[y].new_worst_ce_id = hold_eyes_ce_id
   ELSEIF ((temp->clist[x].dlist[y].event_cd=verbal_cd))
    SET temp->clist[x].dlist[y].new_worst = hold_verbal
    SET temp->clist[x].dlist[y].new_worst_ce_id = hold_verbal_ce_id
   ENDIF
  ENDIF
 ENDIF
#worst_gcs_exit
#worst_gcs_copy
 SET temp->clist[x].dlist[y].worst_resolved_ind = gcs_resolve_flag
 IF (gcs_resolve_flag=2)
  IF ((temp->clist[x].dlist[y].event_cd=meds_cd))
   SET temp->clist[x].dlist[y].new_worst = hold_meds
   SET temp->clist[x].dlist[y].new_worst_ce_id = hold_meds_ce_id
  ELSEIF ((temp->clist[x].dlist[y].event_cd=motor_cd))
   SET temp->clist[x].dlist[y].new_worst = hold_motor
   SET temp->clist[x].dlist[y].new_worst_ce_id = hold_motor_ce_id
  ELSEIF ((temp->clist[x].dlist[y].event_cd=eyes_cd))
   SET temp->clist[x].dlist[y].new_worst = hold_eyes
   SET temp->clist[x].dlist[y].new_worst_ce_id = hold_eyes_ce_id
  ELSEIF ((temp->clist[x].dlist[y].event_cd=verbal_cd))
   SET temp->clist[x].dlist[y].new_worst = hold_verbal
   SET temp->clist[x].dlist[y].new_worst_ce_id = hold_verbal_ce_id
  ENDIF
 ENDIF
#worst_gcs_copy_exit
#urine_output
 SET urine = - (1)
 SET urine_total = - (1)
 SET event_tag_num = 0.0
 SET hold_tag = - (1.0)
 IF (urine1_cd <= 0.0
  AND urine2_cd <= 0.0
  AND urine3_cd <= 0.0)
  CALL echo("No Urine codes Defined")
 ELSE
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=temp->clist[x].person_id)
     AND ce.event_cd IN (urine1_cd, urine2_cd, urine3_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != ops_inerror_cd
     AND ce.event_cd > 0)
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
  SET d2 = datetimediff(search_end_dt_tm,search_beg_dt_tm,3)
  IF (hold_tag > 0)
   SET event_tag_num = ((hold_tag/ (d2+ 0.01667)) * 24)
   SET urine = round(event_tag_num,0)
   SET urine_total = hold_tag
  ELSE
   SET urine = - (1)
   SET urine_total = - (1)
  ENDIF
  IF ((((urine=temp->clist[x].dlist[y].old_worst)) OR ((urine=- (1)))) )
   SET temp->clist[x].dlist[y].worst_resolved_ind = 1
  ELSE
   SET temp->clist[x].dlist[y].new_worst = urine
   SET temp->clist[x].dlist[y].urine_total = urine_total
   SET temp->clist[x].dlist[y].urine_24hr = urine
   SET temp->clist[x].dlist[y].worst_resolved_ind = 2
   SET one_new_worst = "Y"
  ENDIF
 ENDIF
#urine_output_exit
#worst_wbc
 SET wbc_ce_id = 0.0
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
  SET wbc = temp->clist[x].dlist[y].old_worst
 ELSE
  SET wbc = - (1.0)
  SET event_tag_num = - (1.0)
 ENDIF
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res2_cd = 0.0
 SET res_cd = wbc_cd
 IF (res_cd > 0.0)
  SET midpoint = 11.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  SET wbc = event_tag_num
  SET wbc_ce_id = ce_id
 ENDIF
 IF ((wbc=temp->clist[x].dlist[y].old_worst))
  SET temp->clist[x].dlist[y].worst_resolved_ind = 1
 ELSE
  SET temp->clist[x].dlist[y].new_worst = wbc
  SET temp->clist[x].dlist[y].new_worst_ce_id = wbc_ce_id
  SET temp->clist[x].dlist[y].worst_resolved_ind = 2
  SET one_new_worst = "Y"
 ENDIF
#worst_wbc_exit
#worst_temp
 SET tempp = - (1.0)
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
  SET tempp = temp->clist[x].dlist[y].old_worst
 ELSE
  SET tempp = - (1.0)
  SET event_tag_num = - (1.0)
 ENDIF
 SET temp_ce_id = 0.0
 SET hold_tag = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET midpoint = 38
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=temp->clist[x].person_id)
    AND ce.event_cd IN (temp1_cd, temp2_cd, temp3_cd, temp4_cd, temp5_cd,
   temp6_cd)
    AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != ops_inerror_cd
    AND ce.event_cd > 0)
  ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
  HEAD REPORT
   hold_tag = 0.0, temp_temp = 0.0, temp_diff = - (1.0),
   hold_diff = - (1.0), isnum = 0
   IF (tempp > 0)
    temp_temp = tempp
    IF (temp_temp > 50)
     temp_temp = (((temp_temp - 32) * 5)/ 9)
    ENDIF
    hold_diff = abs((temp_temp - midpoint)), hold_tag = tempp
   ENDIF
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
    IF (ce.event_cd=temp4_cd)
     temp_temp = (temp_temp+ 1)
    ENDIF
    temp_diff = abs((temp_temp - midpoint))
    IF (temp_diff > hold_diff)
     hold_diff = temp_diff, hold_tag = cnvtreal(ce.event_tag), ce_id = ce.clinical_event_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (hold_tag > 0.0)
  SET tempp = hold_tag
 ELSE
  SET tempp = - (1)
 ENDIF
 SET temp_ce_id = ce_id
 IF ((tempp=temp->clist[x].dlist[y].old_worst))
  SET temp->clist[x].dlist[y].worst_resolved_ind = 1
 ELSE
  SET temp->clist[x].dlist[y].new_worst = tempp
  SET temp->clist[x].dlist[y].new_worst_ce_id = temp_ce_id
  SET temp->clist[x].dlist[y].worst_resolved_ind = 2
  SET one_new_worst = "Y"
 ENDIF
 FOR (z = 1 TO temp->clist[x].dcnt)
   IF ((temp->clist[x].dlist[y].cc_day=temp->clist[x].dlist[z].cc_day)
    AND (temp->clist[x].dlist[z].worst_resolved_ind=0)
    AND (temp->clist[x].dlist[z].event_cd IN (temp1_cd, temp2_cd, temp3_cd, temp4_cd, temp5_cd,
   temp6_cd)))
    SET temp->clist[x].dlist[z].worst_resolved_ind = 1
   ENDIF
 ENDFOR
#worst_temp_exit
#worst_resp
 SET event_tag_num = - (1.0)
 SET hold_resp = - (1.0)
 SET temp_resp = - (1.0)
 SET hold_vent = - (1.0)
 SET temp_vent = - (1.0)
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET hold_resp = temp->clist[x].dlist[y].old_worst
  SET hold_vent = temp->clist[x].dlist[y].old_vent_ind
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
 ENDIF
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET resp_cd = 0.0
 SET resp_cd = uar_get_code_by_cki(nullterm("CKI.EC!5501"))
 SET vent_cd = 0.0
 SET vent_cd = uar_get_code_by_cki(nullterm("CKI.EC!7676"))
 SET new_data_evt = 0.0
 IF (resp_cd > 0.0)
  SET midpoint = 19.0
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=temp->clist[x].person_id)
     AND ((ce.event_cd=resp_cd) OR (ce.event_cd=vent_cd))
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != ops_inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, hold_diff = - (1.0), temp_resp = 0.0,
    temp_vent = - (1.0), temp_diff = - (1.0)
    IF (event_tag_num > 0)
     hold_diff = abs((event_tag_num - midpoint))
    ENDIF
    isnum = 0
   HEAD ce.event_end_dt_tm
    temp_resp = 0.0, temp_vent = - (1.0), temp_diff = 0.0,
    temp_ce_id = 0.0, new_data_evt = 0.0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (ce.event_cd=vent_cd
     AND vent_cd > 0)
     isnum = 1
    ENDIF
    IF (isnum > 0)
     IF (ce.event_cd=resp_cd)
      temp_resp = cnvtreal(ce.event_tag), temp_ce_id = ce.clinical_event_id
     ELSEIF (ce.event_cd=vent_cd
      AND vent_cd > 0)
      temp_vent = 1, new_data_evt = 1
     ENDIF
    ENDIF
   FOOT  ce.event_end_dt_tm
    IF (temp_resp > 0)
     temp_diff = abs((temp_resp - midpoint))
     IF (vent_cd > 0
      AND new_data_evt=0)
      temp_vent = 0
     ENDIF
     IF (temp_diff > hold_diff)
      hold_diff = temp_diff, hold_resp = temp_resp, hold_vent = temp_vent,
      event_tag_num = temp_resp, ce_id = temp_ce_id
     ELSEIF (temp_diff=hold_diff)
      IF (((hold_vent < 0.0) OR (temp_vent=0
       AND hold_vent != 0)) )
       hold_vent = temp_vent, hold_resp = temp_resp, ce_id = temp_ce_id
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF ((hold_resp=temp->clist[x].dlist[y].old_worst))
   IF ((temp->clist[x].dlist[y].old_worst_ce_id=ce_id)
    AND (temp->clist[x].dlist[y].old_vent_ind > - (1)))
    SET temp->clist[x].dlist[y].worst_resolved_ind = 1
   ELSE
    SET temp->clist[x].dlist[y].new_worst = hold_resp
    SET temp->clist[x].dlist[y].new_vent_ind = hold_vent
    SET unset_vent_ind = 0
    SET temp->clist[x].dlist[y].new_worst_ce_id = ce_id
    SET temp->clist[x].dlist[y].worst_resolved_ind = 2
    SET one_new_worst = "Y"
   ENDIF
  ELSE
   SET temp->clist[x].dlist[y].new_worst = hold_resp
   SET temp->clist[x].dlist[y].new_vent_ind = hold_vent
   SET unset_vent_ind = 0
   SET temp->clist[x].dlist[y].new_worst_ce_id = ce_id
   SET temp->clist[x].dlist[y].worst_resolved_ind = 2
   SET one_new_worst = "Y"
  ENDIF
 ENDIF
#worst_resp_exit
#worst_sodium
 SET sodium = - (1.0)
 SET sodium_ce_id = 0.0
 SET event_tag_num = - (1.0)
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET sodium = temp->clist[x].dlist[y].old_worst
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
 ENDIF
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res2_cd = 0.0
 SET res_cd = sodium_cd
 IF (res_cd > 0.0)
  SET midpoint = 145.0
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  SET sodium = event_tag_num
  SET sodium_ce_id = ce_id
 ENDIF
 IF ((sodium=temp->clist[x].dlist[y].old_worst))
  SET temp->clist[x].dlist[y].worst_resolved_ind = 1
 ELSE
  SET temp->clist[x].dlist[y].new_worst = sodium
  SET temp->clist[x].dlist[y].new_worst_ce_id = sodium_ce_id
  SET temp->clist[x].dlist[y].worst_resolved_ind = 2
  SET one_new_worst = "Y"
 ENDIF
#worst_sodium_exit
#worst_heartrate
 SET heartrate = - (1.0)
 SET heartrate_ce_id = 0.0
 SET event_tag_num = - (1.0)
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET heartrate = temp->clist[x].dlist[y].old_worst
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
 ENDIF
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET midpoint = 75.0
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=temp->clist[x].person_id)
    AND ce.event_cd IN (heartrate_cd, pulse_cd, heartrate2_cd, heartrate3_cd)
    AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != ops_inerror_cd
    AND ce.event_cd > 0)
  ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
  HEAD REPORT
   hold_tag = 0.0, temp_res = 0.0, temp_diff = 0.0,
   hold_diff = - (1.0), isnum = 0
   IF (event_tag_num > 0)
    hold_diff = abs((event_tag_num - midpoint))
   ENDIF
  DETAIL
   isnum = isnumeric(ce.event_tag)
   IF (isnum > 0)
    temp_res = cnvtreal(ce.event_tag), temp_diff = abs((temp_res - midpoint))
    IF (temp_diff > hold_diff)
     hold_diff = temp_diff, event_tag_num = temp_res, ce_id = ce.clinical_event_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET heartrate = event_tag_num
 SET heartrate_ce_id = ce_id
 IF ((heartrate=temp->clist[x].dlist[y].old_worst))
  SET temp->clist[x].dlist[y].worst_resolved_ind = 1
 ELSE
  SET temp->clist[x].dlist[y].new_worst = heartrate
  SET temp->clist[x].dlist[y].new_worst_ce_id = heartrate_ce_id
  SET temp->clist[x].dlist[y].worst_resolved_ind = 2
  SET one_new_worst = "Y"
 ENDIF
#worst_heartrate_exit
#worst_meanbp
 SET meanbp = - (1.0)
 SET event_tag_num = - (1.0)
 SET temp_sys = 0.0
 SET temp_dia = 0.0
 SET midpoint = 0.0
 SET temp_meanbp = 0.0
 SET hold_meanbp = 0.0
 IF (((systolic_cd > 0.0
  AND diastolic_cd > 0.0) OR (((systolic2_cd > 0.0
  AND diastolic2_cd > 0.0) OR (systolic3_cd > 0.0
  AND ((diastolic3_cd > 0.0) OR (diastolic4_cd > 0.0)) )) )) )
  IF ((temp->clist[x].dlist[y].old_worst > 0))
   SET meanbp = temp->clist[x].dlist[y].old_worst
   SET event_tag_num = temp->clist[x].dlist[y].old_worst
  ENDIF
  SET midpoint = 90.00
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=temp->clist[x].person_id)
     AND ce.event_cd IN (systolic_cd, diastolic_cd, systolic2_cd, diastolic2_cd, systolic3_cd,
    diastolic3_cd, diastolic4_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != ops_inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_sys1 = 0.0, temp_sys2 = 0.0,
    temp_dia1 = 0.0, temp_dia2 = 0.0, temp_diff = - (1.0),
    hold_diff = - (1.0), isnum = 0
    IF (event_tag_num > 0)
     hold_tag = temp->clist[x].dlist[y].old_worst, hold_diff = abs((event_tag_num - midpoint))
    ENDIF
   HEAD ce.event_end_dt_tm
    temp_sys1 = 0.0, temp_dia1 = 0.0, temp_sys2 = 0.0,
    temp_dia2 = 0.0, temp_sys3 = 0.0, temp_dia3 = 0.0,
    temp_dia4 = 0.0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     IF (ce.event_cd=systolic_cd)
      temp_sys1 = cnvtreal(ce.event_tag)
     ELSEIF (ce.event_cd=systolic2_cd)
      temp_sys2 = cnvtreal(ce.event_tag)
     ELSEIF (ce.event_cd=diastolic_cd)
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
     temp_meanbp = (((temp_dia1 * 2)+ temp_sys1)/ 3), temp_diff = abs((temp_meanbp - midpoint))
     IF (((temp_diff > hold_diff) OR (event_tag_num=0)) )
      hold_diff = temp_diff, event_tag_num = temp_meanbp
     ENDIF
    ENDIF
    IF (temp_sys2 > 0
     AND temp_dia2 > 0)
     temp_meanbp = (((temp_dia2 * 2)+ temp_sys2)/ 3), temp_diff = abs((temp_meanbp - midpoint))
     IF (((temp_diff > hold_diff) OR (event_tag_num=0)) )
      hold_diff = temp_diff, event_tag_num = temp_meanbp
     ENDIF
    ENDIF
    IF (temp_sys3 > 0
     AND temp_dia3 > 0)
     temp_meanbp = (((temp_dia3 * 2)+ temp_sys3)/ 3), temp_diff = abs((temp_meanbp - midpoint))
     IF (((temp_diff > hold_diff) OR (event_tag_num=0)) )
      hold_diff = temp_diff, event_tag_num = temp_meanbp
     ENDIF
    ELSEIF (temp_sys3 > 0
     AND temp_dia4 > 0)
     temp_meanbp = (((temp_dia4 * 2)+ temp_sys3)/ 3), temp_diff = abs((temp_meanbp - midpoint))
     IF (((temp_diff > hold_diff) OR (event_tag_num=0)) )
      hold_diff = temp_diff, event_tag_num = temp_meanbp
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (event_tag_num > 0)
   SET meanbp = event_tag_num
  ELSE
   SET meanbp = - (1)
  ENDIF
  IF ((meanbp=temp->clist[x].dlist[y].old_worst))
   SET temp->clist[x].dlist[y].worst_resolved_ind = 1
  ELSE
   SET temp->clist[x].dlist[y].new_worst = meanbp
   SET temp->clist[x].dlist[y].worst_resolved_ind = 2
   SET one_new_worst = "Y"
  ENDIF
  FOR (z = 1 TO temp->clist[x].dcnt)
    IF ((temp->clist[x].dlist[y].cc_day=temp->clist[x].dlist[z].cc_day)
     AND (temp->clist[x].dlist[z].worst_resolved_ind=0)
     AND (temp->clist[x].dlist[z].event_cd IN (systolic_cd, diastolic_cd, systolic2_cd, diastolic2_cd,
    systolic3_cd,
    diastolic3_cd, diastolic4_cd)))
     SET temp->clist[x].dlist[z].worst_resolved_ind = 1
    ENDIF
  ENDFOR
 ENDIF
#worst_meanbp_exit
#worst_abg
 SET rad_abg_weight = - (1)
 SET hold_pao2 = - (1.0)
 SET hold_pao2_ce_id = 0.0
 SET hold_pco2 = - (1.0)
 SET hold_pco2_ce_id = 0.0
 SET hold_fio2 = - (1.0)
 SET hold_fio2_ce_id = 0.0
 SET hold_ph = - (1.0)
 SET hold_ph_ce_id = 0.0
 SET hold_intub = - (1.0)
 SET hold_intub_ce_id = 0.0
 SET temp_pao2 = - (1.0)
 SET temp_pao2_ce_id = 0.0
 SET temp_pco2 = - (1.0)
 SET temp_pco2_ce_id = 0.0
 SET temp_fio2 = - (1.0)
 SET temp_fio2_ce_id = 0.0
 SET temp_ph = - (1.0)
 SET temp_ph_ce_id = 0.0
 SET temp_intub = - (1.0)
 SET temp_intub_ce_id = 0.0
 SET temp_intub_autoset = 0.0
 SET temp_weight = - (1.0)
 SET hold_weight = - (1)
 SET pao2_weight = 0.0
 SET aado2_weight = 0.0
 IF (pco2_cd > 0.0
  AND pao2_cd > 0.0
  AND fio2_cd > 0.0
  AND ph_cd > 0.0
  AND ((intub_cd > 0.0) OR (((intub2_cd > 0.0) OR ((temp->clist[x].auto_calc_intubated_ind=1))) )) )
  SELECT INTO "nl:"
   FROM clinical_event ce,
    risk_adjustment ra,
    risk_adjustment_day rad
   PLAN (ce
    WHERE (ce.person_id=temp->clist[x].person_id)
     AND ce.event_cd IN (pao2_cd, pco2_cd, fio2_cd, ph_cd, intub_cd,
    intub2_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != ops_inerror_cd
     AND ce.event_cd > 0)
    JOIN (ra
    WHERE ra.person_id=ce.person_id
     AND (ra.risk_adjustment_id=temp->clist[x].risk_adjustment_id)
     AND ra.active_ind=1)
    JOIN (rad
    WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
     AND (rad.cc_day=temp->clist[x].dlist[y].cc_day)
     AND rad.active_ind=1)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    IF (rad.worst_pao2_result > 0
     AND rad.worst_pco2_result > 0
     AND rad.worst_fio2_result > 0
     AND rad.worst_ph_result > 0
     AND rad.intubated_ind >= 0)
     IF (((rad.intubated_ind=0) OR (rad.worst_fio2_result < 50)) )
      IF (rad.worst_pao2_result < 50)
       rad_abg_weight = 15
      ELSEIF (rad.worst_pao2_result < 70)
       rad_abg_weight = 5
      ELSEIF (rad.worst_pao2_result < 80)
       rad_abg_weight = 2
      ELSE
       rad_abg_weight = 0
      ENDIF
     ELSE
      aado2 = (((rad.worst_fio2_result * 7.13) - rad.worst_pao2_result) - rad.worst_pco2_result)
      IF (aado2 < 100)
       rad_abg_weight = 0
      ELSEIF (aado2 < 250)
       rad_abg_weight = 7
      ELSEIF (aado2 < 350)
       rad_abg_weight = 9
      ELSEIF (aado2 < 500)
       rad_abg_weight = 11
      ELSE
       rad_abg_weight = 14
      ENDIF
     ENDIF
    ENDIF
    hold_pao2 = - (1.0), hold_pao2_ce_id = 0.0, hold_pco2 = - (1.0),
    hold_pco2_ce_id = 0.0, hold_fio2 = - (1.0), hold_fio2_ce_id = 0.0,
    hold_ph = - (1.0), hold_ph_ce_id = 0.0, hold_intub = - (1.0),
    hold_intub_ce_id = 0.0, temp_pao2 = - (1.0), temp_pao2_ce_id = 0.0,
    temp_pco2 = - (1.0), temp_pco2_ce_id = 0.0, temp_fio2 = - (1.0),
    temp_fio2_ce_id = 0.0, temp_ph = - (1.0), temp_ph_ce_id = 0.0,
    temp_intub = - (1.0), temp_intub_ce_id = 0.0, isnum = 0
   HEAD ce.event_end_dt_tm
    temp_pao2 = - (1.0), temp_pao2_ce_id = 0.0, temp_pco2 = - (1.0),
    temp_pco2_ce_id = 0.0, temp_fio2 = - (1.0), temp_fio2_ce_id = 0.0,
    temp_ph = - (1.0), temp_ph_ce_id = 0.0, temp_intub = - (1.0),
    temp_intub_ce_id = 0.0, temp_intub_autoset = 0.0
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (ce.event_cd IN (intub_cd, intub2_cd))
     isnum = 1
    ENDIF
    IF (isnum > 0)
     IF (ce.event_cd=pao2_cd)
      temp_pao2 = cnvtreal(ce.event_tag), temp_pao2_ce_id = ce.clinical_event_id
     ELSEIF (ce.event_cd=pco2_cd)
      temp_pco2 = cnvtreal(ce.event_tag), temp_pco2_ce_id = ce.clinical_event_id
     ELSEIF (ce.event_cd=fio2_cd)
      isnum = isnumeric(ce.event_tag)
      IF (isnum > 0)
       temp_fio2 = cnvtreal(ce.event_tag), temp_fio2_ce_id = ce.clinical_event_id
      ELSE
       filtered_fio2 = check_for_string(ce.event_tag,"%")
       IF (isnumeric(filtered_fio2) > 0)
        temp_fio2 = cnvtreal(filtered_fio2), temp_fio2_ce_id = ce.clinical_event_id
       ENDIF
      ENDIF
      IF (temp_fio2 <= 1.0)
       temp_fio2 = (temp_fio2 * 100)
      ENDIF
     ELSEIF (ce.event_cd=ph_cd)
      temp_ph = cnvtreal(ce.event_tag), temp_ph_ce_id = ce.clinical_event_id
     ELSEIF (ce.event_cd=intub2_cd)
      temp_intub_ce_id = ce.clinical_event_id
      IF (cnvtupper(ce.event_tag) IN ("Y", "YES"))
       temp_intub = 1
      ELSE
       IF (temp_intub < 0)
        temp_intub = 0
       ENDIF
      ENDIF
     ELSEIF (ce.event_cd=intub_cd)
      temp_intub_ce_id = ce.clinical_event_id
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
    IF (temp_intub_ce_id=0
     AND (temp->clist[x].auto_calc_intubated_ind=1)
     AND ((temp_fio2 != rad.worst_fio2_result) OR (((temp_pao2 != rad.worst_pao2_result) OR (((
    temp_pco2 != rad.worst_pco2_result) OR (temp_ph != rad.worst_ph_result)) )) )) )
     IF (temp_pao2 > 0
      AND temp_pco2 > 0
      AND temp_fio2 > 0
      AND temp_ph > 0)
      IF (temp_fio2 > 50.00)
       temp_intub = 1
      ELSE
       temp_intub = 0
      ENDIF
      temp_intub_autoset = 1
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
      hold_weight = temp_weight, hold_pao2 = temp_pao2, hold_pao2_ce_id = temp_pao2_ce_id,
      hold_pco2 = temp_pco2, hold_pco2_ce_id = temp_pco2_ce_id, hold_fio2 = temp_fio2,
      hold_fio2_ce_id = temp_fio2_ce_id, hold_ph = temp_ph, hold_ph_ce_id = temp_ph_ce_id,
      hold_intub = temp_intub, hold_intub_ce_id = temp_intub_ce_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (hold_weight <= rad_abg_weight)
   SET temp->clist[x].dlist[y].worst_resolved_ind = 1
  ELSE
   SET temp->clist[x].dlist[y].worst_resolved_ind = 2
   SET one_new_worst = "Y"
   IF ((temp->clist[x].dlist[y].event_cd=pao2_cd))
    SET temp->clist[x].dlist[y].new_worst = hold_pao2
    SET temp->clist[x].dlist[y].new_worst_ce_id = hold_pao2_ce_id
   ELSEIF ((temp->clist[x].dlist[y].event_cd=pco2_cd))
    SET temp->clist[x].dlist[y].new_worst = hold_pco2
    SET temp->clist[x].dlist[y].new_worst_ce_id = hold_pco2_ce_id
   ELSEIF ((temp->clist[x].dlist[y].event_cd=fio2_cd))
    SET temp->clist[x].dlist[y].new_worst = hold_fio2
    SET temp->clist[x].dlist[y].new_worst_ce_id = hold_fio2_ce_id
   ELSEIF ((temp->clist[x].dlist[y].event_cd=ph_cd))
    SET temp->clist[x].dlist[y].new_worst = hold_ph
    SET temp->clist[x].dlist[y].new_worst_ce_id = hold_ph_ce_id
   ELSE
    SET temp->clist[x].dlist[y].new_worst = hold_intub
    SET temp->clist[x].dlist[y].new_worst_ce_id = hold_intub_ce_id
   ENDIF
   IF (temp_intub_autoset > 0)
    SET temp->clist[x].dlist[y].new_rel_intub = hold_intub
    SET temp->clist[x].dlist[y].new_rel_intub_ce_id = hold_intub_ce_id
    SET temp->clist[x].dlist[y].set_rel_intub_ind = 1
   ENDIF
  ENDIF
 ENDIF
#worst_abg_exit
#worst_abg_copy
 SET temp->clist[x].dlist[y].worst_resolved_ind = 2
 IF ((temp->clist[x].dlist[y].event_cd=pao2_cd))
  SET temp->clist[x].dlist[y].new_worst = hold_pao2
  SET temp->clist[x].dlist[y].new_worst_ce_id = hold_pao2_ce_id
 ELSEIF ((temp->clist[x].dlist[y].event_cd=pco2_cd))
  SET temp->clist[x].dlist[y].new_worst = hold_pco2
  SET temp->clist[x].dlist[y].new_worst_ce_id = hold_pco2_ce_id
 ELSEIF ((temp->clist[x].dlist[y].event_cd=fio2_cd))
  SET temp->clist[x].dlist[y].new_worst = hold_fio2
  SET temp->clist[x].dlist[y].new_worst_ce_id = hold_fio2_ce_id
 ELSEIF ((temp->clist[x].dlist[y].event_cd=ph_cd))
  SET temp->clist[x].dlist[y].new_worst = hold_ph
  SET temp->clist[x].dlist[y].new_worst_ce_id = hold_ph_ce_id
 ELSE
  SET temp->clist[x].dlist[y].new_worst = hold_intub
  SET temp->clist[x].dlist[y].new_worst_ce_id = hold_intub_ce_id
 ENDIF
#worst_abg_copy_exit
#worst_hematocrit
 SET hematocrit = - (1.0)
 SET hematocrit_ce_id = 0.0
 SET event_tag_num = - (1.0)
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
  SET hematocrit = temp->clist[x].dlist[y].old_worst
 ENDIF
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res2_cd = 0.0
 SET res_cd = hematocrit_cd
 IF (res_cd > 0.0)
  SET midpoint = 45.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  SET hematocrit = event_tag_num
  SET hematocrit_ce_id = ce_id
 ENDIF
 IF ((((hematocrit=temp->clist[x].dlist[y].old_worst)) OR ((hematocrit=- (1)))) )
  SET temp->clist[x].dlist[y].worst_resolved_ind = 1
 ELSE
  SET temp->clist[x].dlist[y].new_worst = hematocrit
  SET temp->clist[x].dlist[y].new_worst_ce_id = hematocrit_ce_id
  SET temp->clist[x].dlist[y].worst_resolved_ind = 2
  SET one_new_worst = "Y"
 ENDIF
#worst_hematocrit_exit
#worst_creatinine
 SET creatinine = - (1.0)
 SET creatinine_ce_id = 0.0
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res2_cd = 0.0
 SET res_cd = creatinine_cd
 SET res2_cd = creatinine2_cd
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET creatinine = temp->clist[x].dlist[y].old_worst
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
 ENDIF
 IF (((res_cd > 0.0) OR (res2_cd > 0.0)) )
  SET midpoint = 1
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=temp->clist[x].person_id)
     AND ce.event_cd IN (res_cd, res2_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != ops_inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_res = 0.0, temp_diff = 0.0,
    hold_diff = - (1.0), isnum = 0
    IF (event_tag_num > 0)
     hold_diff = abs((event_tag_num - midpoint))
    ENDIF
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_res = cnvtreal(ce.event_tag), temp_diff = abs((temp_res - midpoint))
     IF (temp_diff > hold_diff)
      hold_diff = temp_diff, event_tag_num = temp_res, ce_id = ce.clinical_event_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET creatinine = event_tag_num
  SET creatinine_ce_id = ce_id
 ENDIF
 IF ((creatinine=temp->clist[x].dlist[y].old_worst))
  SET temp->clist[x].dlist[y].worst_resolved_ind = 1
 ELSE
  SET temp->clist[x].dlist[y].new_worst = creatinine
  SET temp->clist[x].dlist[y].new_worst_ce_id = creatinine_ce_id
  SET temp->clist[x].dlist[y].worst_resolved_ind = 2
  SET one_new_worst = "Y"
 ENDIF
#worst_creatinine_exit
#worst_bilirubin
 SET bilirubin = - (1.0)
 SET bilirubin_ce_id = 0.0
 SET event_tag_num = - (1.0)
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res2_cd = 0.0
 SET res_cd = bilirubin_cd
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET bilirubin = temp->clist[x].dlist[y].old_worst
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
 ENDIF
 IF (res_cd > 0.0)
  EXECUTE FROM highest_result TO highest_result_exit
  SET bilirubin = event_tag_num
  SET bilirubin_ce_id = ce_id
 ENDIF
 IF ((bilirubin=temp->clist[x].dlist[y].old_worst))
  SET temp->clist[x].dlist[y].worst_resolved_ind = 1
 ELSE
  SET temp->clist[x].dlist[y].new_worst = bilirubin
  SET temp->clist[x].dlist[y].new_worst_ce_id = bilirubin_ce_id
  SET temp->clist[x].dlist[y].worst_resolved_ind = 2
  SET one_new_worst = "Y"
 ENDIF
#worst_bilirubin_exit
#worst_potassium
 SET potassium = - (1.0)
 SET potassium_ce_id = 0.0
 SET event_tag_num = - (1.0)
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res2_cd = 0.0
 SET res_cd = potassium_cd
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET potassium = temp->clist[x].dlist[y].old_worst
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
 ENDIF
 IF (res_cd > 0.0)
  SET midpoint = 4.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  SET potassium = event_tag_num
  SET potassium_ce_id = ce_id
 ENDIF
 IF ((potassium=temp->clist[x].dlist[y].old_worst))
  SET temp->clist[x].dlist[y].worst_resolved_ind = 1
 ELSE
  SET temp->clist[x].dlist[y].new_worst = potassium
  SET temp->clist[x].dlist[y].new_worst_ce_id = potassium_ce_id
  SET temp->clist[x].dlist[y].worst_resolved_ind = 2
  SET one_new_worst = "Y"
 ENDIF
#worst_potassium_exit
#worst_bun
 SET bun = - (1.0)
 SET bun_ce_id = 0.0
 SET event_tag_num = - (1.0)
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res2_cd = 0.0
 SET res_cd = bun_cd
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET bun = temp->clist[x].dlist[y].old_worst
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
 ENDIF
 IF (res_cd > 0.0)
  EXECUTE FROM highest_result TO highest_result_exit
  SET bun = event_tag_num
  SET bun_ce_id = ce_id
 ENDIF
 IF ((bun=temp->clist[x].dlist[y].old_worst))
  SET temp->clist[x].dlist[y].worst_resolved_ind = 1
 ELSE
  IF ((temp->clist[x].dlist[y].old_worst_ce_id=0)
   AND (temp->clist[x].dlist[y].old_worst > bun))
   SET do_nothing = 0
  ELSE
   SET temp->clist[x].dlist[y].new_worst = bun
   SET temp->clist[x].dlist[y].new_worst_ce_id = bun_ce_id
   SET temp->clist[x].dlist[y].worst_resolved_ind = 2
   SET one_new_worst = "Y"
  ENDIF
 ENDIF
#worst_bun_exit
#worst_albumin
 SET albumin = - (1.0)
 SET albumin_ce_id = 0.0
 SET event_tag_num = - (1.0)
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res2_cd = 0.0
 SET res_cd = albumin_cd
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET albumin = temp->clist[x].dlist[y].old_worst
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
 ENDIF
 IF (res_cd > 0.0)
  SET midpoint = 3.5
  EXECUTE FROM midpoint_rule TO midpoint_rule_exit
  SET albumin = event_tag_num
  SET albumin_ce_id = ce_id
 ENDIF
 IF ((albumin=temp->clist[x].dlist[y].old_worst))
  SET temp->clist[x].dlist[y].worst_resolved_ind = 1
 ELSE
  SET temp->clist[x].dlist[y].new_worst = albumin
  SET temp->clist[x].dlist[y].new_worst_ce_id = albumin_ce_id
  SET temp->clist[x].dlist[y].worst_resolved_ind = 2
  SET one_new_worst = "Y"
 ENDIF
#worst_albumin_exit
#worst_glucose
 SET glucose = - (1.0)
 SET glucose_ce_id = 0.0
 SET event_tag_num = - (1.0)
 IF ((temp->clist[x].dlist[y].old_worst > 0)
  AND (temp->clist[x].dlist[y].old_worst_ce_id=0))
  SET glucose = temp->clist[x].dlist[y].old_worst
  SET event_tag_num = temp->clist[x].dlist[y].old_worst
 ENDIF
 SET midpoint = 0.0
 SET ce_id = 0.0
 SET res_cd = 0.0
 SET res2_cd = 0.0
 SET res3_cd = 0.0
 SET res4_cd = 0.0
 SET res5_cd = 0.0
 SET res6_cd = 0.0
 SET res7_cd = 0.0
 SET res8_cd = 0.0
 SET res9_cd = 0.0
 SET res10_cd = 0.0
 SET res_cd = glucose_cd
 SET res2_cd = glucose2_cd
 SET res3_cd = glucose3_cd
 SET res4_cd = glucose4_cd
 SET res5_cd = glucose5_cd
 SET res6_cd = glucose6_cd
 SET res7_cd = glucose7_cd
 SET res8_cd = glucose8_cd
 SET res9_cd = glucose9_cd
 SET res10_cd = glucose10_cd
 IF (((res_cd > 0.0) OR (((res2_cd > 0.0) OR (((res3_cd > 0.0) OR (((res4_cd > 0.0) OR (((res5_cd >
 0.0) OR (((res6_cd > 0.0) OR (((res7_cd > 0.0) OR (((res8_cd > 0.0) OR (((res9_cd > 0.0) OR (
 res10_cd > 0.0)) )) )) )) )) )) )) )) )) )
  SET midpoint = 130
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.person_id=temp->clist[x].person_id)
     AND ce.event_cd IN (res_cd, res2_cd, res3_cd, res4_cd, res5_cd,
    res6_cd, res7_cd, res8_cd, res9_cd, res10_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != ops_inerror_cd
     AND ce.event_cd > 0)
   ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
   HEAD REPORT
    hold_tag = 0.0, temp_res = 0.0, temp_diff = 0.0,
    hold_diff = - (1.0), isnum = 0
    IF (event_tag_num > 0)
     hold_diff = abs((event_tag_num - midpoint))
    ENDIF
   DETAIL
    isnum = isnumeric(ce.event_tag)
    IF (isnum > 0)
     temp_res = cnvtreal(ce.event_tag), temp_diff = abs((temp_res - midpoint))
     IF (temp_diff > hold_diff)
      hold_diff = temp_diff, event_tag_num = temp_res, ce_id = ce.clinical_event_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET glucose = event_tag_num
  SET glucose_ce_id = ce_id
 ENDIF
 IF ((glucose=temp->clist[x].dlist[y].old_worst))
  SET temp->clist[x].dlist[y].worst_resolved_ind = 1
 ELSE
  SET temp->clist[x].dlist[y].new_worst = glucose
  SET temp->clist[x].dlist[y].new_worst_ce_id = glucose_ce_id
  SET temp->clist[x].dlist[y].worst_resolved_ind = 2
  SET one_new_worst = "Y"
 ENDIF
#worst_glucose_exit
#highest_result
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=temp->clist[x].person_id)
    AND ce.event_cd=res_cd
    AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != ops_inerror_cd
    AND ce.event_cd > 0)
  ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
  HEAD REPORT
   hold_tag = 0.0, temp_res = 0.0, isnum = 0
  DETAIL
   isnum = isnumeric(ce.event_tag)
   IF (isnum > 0)
    temp_res = cnvtreal(ce.event_tag)
    IF (temp_res > event_tag_num)
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
   WHERE (ce.person_id=temp->clist[x].person_id)
    AND ce.event_cd IN (res_cd, res2_cd)
    AND ce.event_end_dt_tm >= cnvtdatetime(search_beg_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(search_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != ops_inerror_cd
    AND ce.event_cd > 0)
  ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
  HEAD REPORT
   hold_tag = 0.0, temp_res = 0.0, temp_diff = 0.0,
   hold_diff = - (1.0)
   IF (event_tag_num > 0)
    hold_diff = abs((event_tag_num - midpoint))
   ENDIF
   isnum = 0
  DETAIL
   isnum = isnumeric(ce.event_tag)
   IF (isnum > 0)
    temp_res = cnvtreal(ce.event_tag), temp_diff = abs((temp_res - midpoint))
    IF (temp_diff > hold_diff)
     hold_diff = temp_diff, event_tag_num = temp_res, ce_id = ce.clinical_event_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#midpoint_rule_exit
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
 SET check_cc_day = y
 WHILE (stillneed2find > 0
  AND check_cc_day > 0)
  SET check_cc_day = (check_cc_day - 1)
  SELECT INTO "nl:"
   FROM risk_adjustment_day rad
   PLAN (rad
    WHERE (rad.risk_adjustment_id=temp4->dlist[y].risk_adjustment_id)
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
#load_tiss_items_to_arrays
 SELECT INTO "nl:"
  FROM code_value cv1
  WHERE cv1.code_set=29747
   AND cv1.active_ind=1
  ORDER BY cv1.collation_seq
  HEAD REPORT
   tiss_cnt = 0
  DETAIL
   IF (cv1.collation_seq=0)
    none_code_value = cv1.code_value
   ELSE
    act_flag = "Z", tiss_cnt = (tiss_cnt+ 1), act_flag = substring(1,1,cv1.definition),
    scan_tiss_list->list[tiss_cnt].code_value = cv1.code_value, scan_tiss_list->list[tiss_cnt].
    tiss_name = cv1.cdf_meaning, scan_tiss_list->list[tiss_cnt].tiss_num = cv1.collation_seq,
    scan_tiss_list->list[tiss_cnt].ce_cd = 0.0
    IF (act_flag="Y")
     scan_tiss_list->list[tiss_cnt].acttx_ind = 1
    ELSE
     scan_tiss_list->list[tiss_cnt].acttx_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (accept_tiss_acttx_if_ind=1)
  SET scan_tiss_list->list[1].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8133"))
  SET scan_tiss_list->list[2].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8134"))
  SET scan_tiss_list->list[3].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8135"))
  SET scan_tiss_list->list[4].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8136"))
  SET scan_tiss_list->list[5].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8137"))
  SET scan_tiss_list->list[6].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8138"))
  SET scan_tiss_list->list[7].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8139"))
  SET scan_tiss_list->list[8].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8140"))
  SET scan_tiss_list->list[9].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8141"))
  SET scan_tiss_list->list[10].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8142"))
  SET scan_tiss_list->list[11].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8143"))
  SET scan_tiss_list->list[12].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8144"))
  SET scan_tiss_list->list[13].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8145"))
  SET scan_tiss_list->list[14].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8146"))
  SET scan_tiss_list->list[15].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8147"))
  SET scan_tiss_list->list[16].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8148"))
  SET scan_tiss_list->list[17].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8149"))
  SET scan_tiss_list->list[18].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8150"))
  SET scan_tiss_list->list[19].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8151"))
  SET scan_tiss_list->list[20].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8152"))
  SET scan_tiss_list->list[21].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8153"))
  SET scan_tiss_list->list[22].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8154"))
  SET scan_tiss_list->list[23].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8155"))
  SET scan_tiss_list->list[24].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8156"))
  SET scan_tiss_list->list[25].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8157"))
  SET scan_tiss_list->list[26].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8158"))
  SET scan_tiss_list->list[27].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8159"))
  SET scan_tiss_list->list[28].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8160"))
  SET scan_tiss_list->list[29].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8161"))
  SET scan_tiss_list->list[30].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8162"))
  SET scan_tiss_list->list[31].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8163"))
  SET scan_tiss_list->list[32].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8164"))
  SET scan_tiss_list->list[33].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8165"))
  SET scan_tiss_list->list[92].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8223"))
  SET scan_tiss_list->list[93].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8224"))
  SET scan_tiss_list->list[94].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8225"))
 ENDIF
 IF (accept_tiss_nonacttx_if_ind=1)
  SET scan_tiss_list->list[34].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8166"))
  SET scan_tiss_list->list[35].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8167"))
  SET scan_tiss_list->list[36].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8168"))
  SET scan_tiss_list->list[37].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8169"))
  SET scan_tiss_list->list[38].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8170"))
  SET scan_tiss_list->list[39].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8171"))
  SET scan_tiss_list->list[40].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8172"))
  SET scan_tiss_list->list[41].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8173"))
  SET scan_tiss_list->list[42].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8174"))
  SET scan_tiss_list->list[43].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8175"))
  SET scan_tiss_list->list[44].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8176"))
  SET scan_tiss_list->list[45].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8177"))
  SET scan_tiss_list->list[46].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8178"))
  SET scan_tiss_list->list[47].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8179"))
  SET scan_tiss_list->list[48].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8180"))
  SET scan_tiss_list->list[49].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8181"))
  SET scan_tiss_list->list[50].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8182"))
  SET scan_tiss_list->list[51].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8183"))
  SET scan_tiss_list->list[52].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8184"))
  SET scan_tiss_list->list[53].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8185"))
  SET scan_tiss_list->list[54].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8186"))
  SET scan_tiss_list->list[55].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8187"))
  SET scan_tiss_list->list[56].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8188"))
  SET scan_tiss_list->list[57].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8189"))
  SET scan_tiss_list->list[58].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8190"))
  SET scan_tiss_list->list[59].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8191"))
  SET scan_tiss_list->list[60].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8192"))
  SET scan_tiss_list->list[61].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8193"))
  SET scan_tiss_list->list[62].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8194"))
  SET scan_tiss_list->list[63].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8195"))
  SET scan_tiss_list->list[64].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8196"))
  SET scan_tiss_list->list[65].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8197"))
  SET scan_tiss_list->list[66].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8198"))
  SET scan_tiss_list->list[67].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8199"))
  SET scan_tiss_list->list[68].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8200"))
  SET scan_tiss_list->list[69].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8201"))
  SET scan_tiss_list->list[70].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8202"))
  SET scan_tiss_list->list[71].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8203"))
  SET scan_tiss_list->list[72].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8204"))
  SET scan_tiss_list->list[73].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8205"))
  SET scan_tiss_list->list[74].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8206"))
  SET scan_tiss_list->list[75].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8207"))
  SET scan_tiss_list->list[76].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8208"))
  SET scan_tiss_list->list[77].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8209"))
  SET scan_tiss_list->list[78].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8210"))
  SET scan_tiss_list->list[79].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8211"))
  SET scan_tiss_list->list[80].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8212"))
  SET scan_tiss_list->list[81].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8213"))
  SET scan_tiss_list->list[82].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8214"))
  SET scan_tiss_list->list[83].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8215"))
  SET scan_tiss_list->list[84].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8216"))
  SET scan_tiss_list->list[85].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8217"))
  SET scan_tiss_list->list[86].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8218"))
  SET scan_tiss_list->list[87].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8219"))
  SET scan_tiss_list->list[88].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!5734"))
  SET scan_tiss_list->list[89].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8220"))
  SET scan_tiss_list->list[90].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8221"))
  SET scan_tiss_list->list[91].ce_cd = uar_get_code_by_cki(nullterm("CKI.EC!8222"))
 ENDIF
#load_tiss_items_to_arrays_exit
#exit_program
 CALL echorecord(reply)
END GO
