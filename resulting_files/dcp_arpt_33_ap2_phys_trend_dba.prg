CREATE PROGRAM dcp_arpt_33_ap2_phys_trend:dba
 RECORD rpt_params(
   1 output_device = vc
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 date_type = i2
   1 org_id = f8
   1 unit = f8
   1 unit_str = f8
   1 bed = vc
   1 ids[*]
     2 person_id = f8
     2 risk_id = f8
     2 bed_id = f8
     2 room_id = f8
     2 bed_desc = vc
     2 room_desc = vc
   1 icu_day = i2
   1 icu_admit_dt_tm = dq8
   1 beg_dt_disp = vc
   1 end_dt_disp = vc
   1 today = vc
   1 now = vc
   1 gen_on = vc
   1 date_type_disp = vc
   1 date_type_range_disp = vc
   1 unit_disp = vc
   1 org_name = vc
 )
 DECLARE meaning_code(p1,p1) = f8
 IF (isnumeric( $1))
  SET rpt_params->output_device = "MINE"
 ELSE
  SET rpt_params->output_device =  $1
 ENDIF
 IF (isnumeric( $2))
  SET rpt_params->beg_dt_tm = cnvtdatetime("")
 ELSE
  SET rpt_params->beg_dt_tm = cnvtdatetime( $2)
 ENDIF
 IF (isnumeric( $3))
  SET rpt_params->end_dt_tm = cnvtdatetime("")
 ELSE
  SET rpt_params->end_dt_tm = cnvtdatetime( $3)
 ENDIF
 IF (isnumeric( $4))
  SET rpt_params->date_type =  $4
 ELSE
  SET rpt_params->date_type = 1
 ENDIF
 IF (isnumeric( $5))
  SET rpt_params->org_id =  $5
 ELSE
  SET rpt_params->org_id = - (1)
 ENDIF
 IF (isnumeric( $7)=1)
  SET rpt_params->bed = "-1"
 ELSE
  SET rpt_params->bed =  $7
 ENDIF
 IF (trim(rpt_params->bed,3)="")
  SET rpt_params->bed = "-1"
 ENDIF
 IF (isnumeric( $9))
  SET rpt_params->icu_day =  $9
 ELSE
  SET rpt_params->icu_day = - (1)
 ENDIF
 IF (isnumeric( $10))
  SET rpt_params->icu_admit_dt_tm = cnvtdatetime("")
 ELSE
  SET rpt_params->icu_admit_dt_tm = cnvtdatetime( $10)
 ENDIF
 SET rpt_params->beg_dt_disp = format(rpt_params->beg_dt_tm,"DD-MMM-YYYY;;D")
 SET rpt_params->end_dt_disp = format(rpt_params->end_dt_tm,"DD-MMM-YYYY;;D")
 SET rpt_params->today = format(curdate,"mm/dd/yyyy ;;d")
 SET rpt_params->now = format(curtime,"hh:mm ;;m")
 SET rpt_params->gen_on = concat("Report generated on: ",rpt_params->today," ",rpt_params->now)
 IF ((rpt_params->date_type=3))
  SET rpt_params->date_type_disp = "For Hospital Admission Dates from "
 ELSEIF ((rpt_params->date_type=4))
  SET rpt_params->date_type_disp = "For Hospital Discharge Dates from "
 ELSEIF ((rpt_params->date_type=1))
  SET rpt_params->date_type_disp = "For ICU Admission Dates from "
 ELSE
  SET rpt_params->date_type_disp = "For ICU Discharge Dates from "
 ENDIF
 SET rpt_params->date_type_range_disp = concat(rpt_params->date_type_disp," ",rpt_params->beg_dt_disp,
  " to ",rpt_params->end_dt_disp)
 SELECT INTO "nl:"
  FROM code_value c
  WHERE (c.code_value= $6)
   AND ((c.code_set+ 0)=220)
   AND ((c.active_ind+ 0)=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt=1)
    rpt_params->unit_disp = c.display
   ELSE
    rpt_params->unit_disp = build(trim(rpt_params->unit_disp),", ",c.description)
   ENDIF
  FOOT REPORT
   cnt = 0
  WITH nocounter
 ;end select
 IF ((rpt_params->org_id=- (1)))
  SET rpt_params->org_name = "All Organizations"
 ELSE
  SELECT INTO "nl:"
   FROM organization o
   WHERE (o.organization_id=rpt_params->org_id)
    AND ((o.organization_id+ 0) != - (1))
    AND ((o.active_ind+ 0)=1)
   DETAIL
    rpt_params->org_name = trim(o.org_name,3)
   WITH nocounter
  ;end select
 ENDIF
 SET font80c = "{COLOR/0}{F/1}{CPI/10^}{LPI/6^}"
 SET font80 = "{COLOR/0}{F/9}{CPI/10^}{LPI/6^}"
 SET font110c = "{COLOR/0}{F/0}{CPI/14^}{LPI/8^}"
 SET font110 = "{COLOR/0}{F/8}{CPI/14^}{LPI/8^}"
 SET font140 = "{COLOR/0}{F/8}{CPI/16^}{LPI/10^}"
 SET dio_landscape = "{ps/792 0 translate 90 rotate/}"
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
 SET count = 0
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  WHERE (ra.risk_adjustment_id= $8)
   AND ra.active_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(rpt_params->ids,count), rpt_params->ids[count].risk_id = ra
   .risk_adjustment_id
  WITH nocounter
 ;end select
 RECORD pat_record(
   1 cnt = i4
   1 pat_data[*]
     2 person_id = f8
     2 ra_id = f8
     2 encntr_id = f8
     2 unit = vc
     2 bed = vc
     2 name = vc
     2 mrn = vc
     2 age = i4
     2 dob = dq8
     2 service = vc
     2 doc_id = f8
     2 doc_name = vc
     2 diagnosis = vc
     2 hosp_adm_dt = dq8
     2 system = vc
     2 icu_disch_dt = dq8
     2 icu_disch_stat = vc
     2 icu_admit_dt = dq8
     2 curr_icu_day = i4
     2 icu_pred_los = f8
     2 day_n = vc
     2 day_n_label = vc
     2 therapy = vc
     2 admit_source = vc
     2 chronic = vc
     2 elective_surg = vc
     2 readmit = vc
     2 hosp_disch_dt = dq8
     2 hosp_disch_stat = vc
     2 act_or_curr_icu_day_label = vc
     2 obs_value[*]
       3 icu_day = i4
       3 aps = i4
       3 ap2 = i4
       3 ap3 = i4
       3 temp = f8
       3 map = f8
       3 heart_rate = f8
       3 vent = vc
       3 resp_rate = f8
       3 gcs = i4
       3 eyes = i4
       3 motor = i4
       3 verbal = i4
       3 wbc = f8
       3 hematocrit = f8
       3 sodium = f8
       3 creatinine = f8
       3 potassium = f8
       3 intub = vc
       3 fio2 = f8
       3 pao2 = f8
       3 paco2 = f8
       3 ph = f8
       3 aado2 = f8
 )
 SET bed_id_ct = size(rpt_params->ids,5)
 SET mrn_cd = meaning_code(319,"MRN")
 SET nday_equation = 0
 SET deceased_cd = 0.0
 SET expired_cd = 0.0
 SET deceased_cd = meaning_code(19,"DECEASED")
 SET expired_cd = meaning_code(19,"EXPIRED")
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   encounter e,
   person p,
   (dummyt d  WITH seq = bed_id_ct)
  PLAN (d)
   JOIN (ra
   WHERE (ra.risk_adjustment_id=rpt_params->ids[d.seq].risk_id)
    AND ra.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  HEAD REPORT
   indx = 0
  DETAIL
   indx = (indx+ 1), pat_record->cnt = (pat_record->cnt+ 1), stat = alterlist(pat_record->pat_data,
    indx),
   pat_record->pat_data[indx].person_id = e.person_id, pat_record->pat_data[indx].encntr_id = e
   .encntr_id, pat_record->pat_data[indx].ra_id = ra.risk_adjustment_id,
   pat_record->pat_data[indx].icu_pred_los = - (1), pat_record->pat_data[indx].unit =
   uar_get_code_display(ra.admit_icu_cd), pat_record->pat_data[indx].bed = concat(rpt_params->ids[d
    .seq].room_desc,"-",rpt_params->ids[d.seq].bed_desc),
   pat_record->pat_data[indx].name = p.name_full_formatted, pat_record->pat_data[indx].age = ra
   .admit_age, pat_record->pat_data[indx].dob = p.birth_dt_tm,
   pat_record->pat_data[indx].service = uar_get_code_display(ra.med_service_cd), pat_record->
   pat_data[indx].doc_id = ra.adm_doc_id, pat_record->pat_data[indx].diagnosis = ra.admit_diagnosis,
   pat_record->pat_data[indx].hosp_adm_dt = e.reg_dt_tm, pat_record->pat_data[indx].system = ra
   .body_system, rpt_params->date_type_range_disp = concat("ICU Admission From ",format(ra
     .icu_admit_dt_tm,"dd-MMM-YYYY")," To ",format(ra.icu_disch_dt_tm,"dd-MMM-YYYY"))
   IF (uar_get_code_display(ra.disease_category_cd)="S/P CABG")
    pat_record->pat_data[indx].day_n_label = "Day 3 Equation (Y/N):", nday_equation = 3
   ELSE
    pat_record->pat_data[indx].day_n_label = "Day 7 Equation (Y/N):", nday_equation = 7
   ENDIF
   IF (ra.icu_disch_dt_tm != cnvtdatetime("31-DEC-2100 00:00"))
    IF (ra.diedinicu_ind=1)
     pat_record->pat_data[indx].icu_disch_stat = "D"
    ELSE
     pat_record->pat_data[indx].icu_disch_stat = "A"
    ENDIF
    pat_record->pat_data[indx].curr_icu_day = datetimediff(datetimeadd(ra.icu_disch_dt_tm,1),ra
     .icu_admit_dt_tm,1), pat_record->pat_data[indx].icu_disch_dt = ra.icu_disch_dt_tm, pat_record->
    pat_data[indx].act_or_curr_icu_day_label = "Actual LOS:"
   ELSE
    pat_record->pat_data[indx].icu_disch_stat = " ", pat_record->pat_data[indx].curr_icu_day =
    datetimediff(datetimeadd(cnvtdatetime(curdate,curtime3),1),ra.icu_admit_dt_tm,1), pat_record->
    pat_data[indx].act_or_curr_icu_day_label = "Current ICU Day:"
   ENDIF
   pat_record->pat_data[indx].icu_admit_dt = ra.icu_admit_dt_tm
   CASE (ra.therapy_level)
    OF 1:
     pat_record->pat_data[indx].therapy = "ACTIVE"
    OF 2:
     pat_record->pat_data[indx].therapy = "LR-MONITOR"
    OF 3:
     pat_record->pat_data[indx].therapy = "HR-MONITOR"
    OF 4:
     pat_record->pat_data[indx].therapy = "NP-MONITOR"
    OF 5:
     pat_record->pat_data[indx].therapy = "NP-ACTIVE"
    ELSE
     pat_record->pat_data[indx].therapy = ""
   ENDCASE
   pat_record->pat_data[indx].admit_source = ra.admit_source
   IF (((ra.chronic_health_unavail_ind=0) OR (ra.chronic_health_none_ind=0)) )
    IF (ra.aids_ind=1)
     pat_record->pat_data[indx].chronic = "OTHERIMMUN"
    ELSEIF (ra.hepaticfailure_ind=1)
     pat_record->pat_data[indx].chronic = "HEPFAILURE"
    ELSEIF (ra.lymphoma_ind=1)
     pat_record->pat_data[indx].chronic = "LYMPHOMA"
    ELSEIF (ra.metastaticcancer_ind=1)
     pat_record->pat_data[indx].chronic = "TUMOR/METS"
    ELSEIF (ra.leukemia_ind=1)
     pat_record->pat_data[indx].chronic = "LEUK/MYEL"
    ELSEIF (ra.immunosuppression_ind=1)
     pat_record->pat_data[indx].chronic = "IMMUNOSUP"
    ELSEIF (ra.cirrhosis_ind=1)
     pat_record->pat_data[indx].chronic = "CIRRHOSIS"
    ELSEIF (ra.diabetes_ind=1)
     pat_record->pat_data[indx].chronic = "DIABETES"
    ELSEIF (ra.copd_ind=1)
     IF (ra.copd_flag=0)
      pat_record->pat_data[indx].chronic = "NOLIM_COPD"
     ELSEIF (ra.copd_flag=1)
      pat_record->pat_data[indx].chronic = "MOD_COPD"
     ELSEIF (ra.copd_flag=2)
      pat_record->pat_data[indx].chronic = "SEV_COPD"
     ENDIF
    ENDIF
   ENDIF
   IF (ra.chronic_health_unavail_ind=1)
    pat_record->pat_data[indx].chronic = "UNAVAILABLE"
   ELSEIF (ra.chronic_health_none_ind=1)
    pat_record->pat_data[indx].chronic = "NONE"
   ENDIF
   IF ((pat_record->pat_data[indx].admit_source IN ("RR", "OR")))
    IF (ra.electivesurgery_ind=1)
     pat_record->pat_data[indx].elective_surg = "Y"
    ELSE
     pat_record->pat_data[indx].elective_surg = "N"
    ENDIF
   ELSE
    pat_record->pat_data[indx].elective_surg = "N/A"
   ENDIF
   IF (ra.readmit_ind=1)
    pat_record->pat_data[indx].readmit = "Y"
   ELSE
    pat_record->pat_data[indx].readmit = "N"
   ENDIF
   pat_record->pat_data[indx].hosp_disch_dt = e.disch_dt_tm
   IF (cnvtdatetime(e.disch_dt_tm) != cnvtdatetime(null))
    IF (ra.diedinicu_ind=1)
     pat_record->pat_data[indx].hosp_disch_stat = "D"
    ELSE
     IF (e.disch_disposition_cd IN (deceased_cd, expired_cd))
      pat_record->pat_data[indx].hosp_disch_stat = "D"
     ELSE
      pat_record->pat_data[indx].hosp_disch_stat = "A"
     ENDIF
     IF (p.deceased_dt_tm > e.reg_dt_tm
      AND p.deceased_dt_tm <= e.disch_dt_tm)
      pat_record->pat_data[indx].hosp_disch_stat = "D"
     ENDIF
    ENDIF
   ELSE
    pat_record->pat_data[indx].hosp_disch_stat = " "
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   (dummyt d  WITH seq = pat_record->cnt)
  PLAN (d)
   JOIN (ea
   WHERE (pat_record->pat_data[d.seq].encntr_id=ea.encntr_id)
    AND ea.encntr_alias_type_cd=mrn_cd
    AND ea.active_ind=1)
  DETAIL
   pat_record->pat_data[d.seq].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p,
   (dummyt d  WITH seq = pat_record->cnt)
  PLAN (d)
   JOIN (p
   WHERE (pat_record->pat_data[d.seq].doc_id=p.person_id)
    AND p.active_ind=1)
  DETAIL
   pat_record->pat_data[d.seq].doc_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM risk_adjustment_outcomes rao,
   risk_adjustment_day rad,
   risk_adjustment ra,
   (dummyt d  WITH seq = pat_record->cnt)
  PLAN (d)
   JOIN (ra
   WHERE (pat_record->pat_data[d.seq].ra_id=ra.risk_adjustment_id)
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.apache_ii_score > 0
    AND rad.active_ind=1)
   JOIN (rao
   WHERE rao.risk_adjustment_day_id=rad.risk_adjustment_day_id
    AND rao.equation_name="ICU_LOS"
    AND rao.active_ind=1)
  DETAIL
   IF (rad.cc_day=1)
    pat_record->pat_data[d.seq].icu_pred_los = rao.outcome_value
   ENDIF
   IF (nday_equation=7)
    IF (rad.cc_day >= 7)
     pat_record->pat_data[d.seq].day_n = "Y"
    ELSE
     pat_record->pat_data[d.seq].day_n = "N"
    ENDIF
   ELSEIF (nday_equation=3)
    IF (rad.cc_day >= 3)
     pat_record->pat_data[d.seq].day_n = "Y"
    ELSE
     pat_record->pat_data[d.seq].day_n = "N"
    ENDIF
   ELSE
    pat_record->pat_data[d.seq].day_n = "N/A"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad,
   risk_adjustment ra,
   (dummyt d  WITH seq = pat_record->cnt)
  PLAN (d)
   JOIN (ra
   WHERE (ra.risk_adjustment_id=pat_record->pat_data[d.seq].ra_id)
    AND ra.active_ind=1)
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.active_ind=1)
  ORDER BY d.seq, rad.cc_day
  HEAD REPORT
   indx = 0, last_ra_id = - (1.0)
  DETAIL
   IF (last_ra_id != ra.risk_adjustment_id)
    indx = 0, last_ra_id = ra.risk_adjustment_id
   ENDIF
   indx = (indx+ 1), stat = alterlist(pat_record->pat_data[d.seq].obs_value,indx), pat_record->
   pat_data[d.seq].obs_value[indx].icu_day = rad.cc_day,
   pat_record->pat_data[d.seq].obs_value[indx].aps = rad.aps_score, pat_record->pat_data[d.seq].
   obs_value[indx].ap2 = rad.apache_ii_score, pat_record->pat_data[d.seq].obs_value[indx].ap3 = rad
   .apache_iii_score
   IF (rad.worst_temp > 50)
    pat_record->pat_data[d.seq].obs_value[indx].temp = ((rad.worst_temp - 32.0) * (5.0/ 9.0))
   ELSE
    pat_record->pat_data[d.seq].obs_value[indx].temp = rad.worst_temp
   ENDIF
   pat_record->pat_data[d.seq].obs_value[indx].map = rad.mean_blood_pressure, pat_record->pat_data[d
   .seq].obs_value[indx].heart_rate = rad.worst_heart_rate
   IF (rad.vent_ind=1)
    pat_record->pat_data[d.seq].obs_value[indx].vent = "Yes"
   ELSEIF (rad.vent_ind=0)
    pat_record->pat_data[d.seq].obs_value[indx].vent = "No"
   ELSE
    pat_record->pat_data[d.seq].obs_value[indx].vent = "N/A"
   ENDIF
   pat_record->pat_data[d.seq].obs_value[indx].resp_rate = rad.worst_resp_result
   IF (rad.meds_ind=0)
    pat_record->pat_data[d.seq].obs_value[indx].gcs = ((rad.worst_gcs_eye_score+ rad
    .worst_gcs_motor_score)+ rad.worst_gcs_verbal_score)
   ENDIF
   pat_record->pat_data[d.seq].obs_value[indx].eyes = rad.worst_gcs_eye_score, pat_record->pat_data[d
   .seq].obs_value[indx].motor = rad.worst_gcs_motor_score, pat_record->pat_data[d.seq].obs_value[
   indx].verbal = rad.worst_gcs_verbal_score,
   pat_record->pat_data[d.seq].obs_value[indx].wbc = rad.worst_wbc_result, pat_record->pat_data[d.seq
   ].obs_value[indx].hematocrit = rad.worst_hematocrit, pat_record->pat_data[d.seq].obs_value[indx].
   sodium = rad.worst_sodium_result,
   pat_record->pat_data[d.seq].obs_value[indx].creatinine = rad.worst_creatinine_result, pat_record->
   pat_data[d.seq].obs_value[indx].potassium = rad.worst_potassium_result
   IF (rad.intubated_ind=1)
    pat_record->pat_data[d.seq].obs_value[indx].intub = "Yes"
   ELSEIF (rad.intubated_ind=0)
    pat_record->pat_data[d.seq].obs_value[indx].intub = "No"
   ELSE
    pat_record->pat_data[d.seq].obs_value[indx].intub = "N/A"
   ENDIF
   pat_record->pat_data[d.seq].obs_value[indx].fio2 = rad.worst_fio2_result, pat_record->pat_data[d
   .seq].obs_value[indx].pao2 = rad.worst_pao2_result, pat_record->pat_data[d.seq].obs_value[indx].
   paco2 = rad.worst_pco2_result,
   pat_record->pat_data[d.seq].obs_value[indx].ph = rad.worst_ph_result
   IF ((((rad.worst_fio2_result != - (1.00))) OR ((((rad.worst_pao2_result != - (1.00))) OR ((rad
   .worst_pco2_result != - (1.00)))) )) )
    pat_record->pat_data[d.seq].obs_value[indx].aado2 = (((rad.worst_fio2_result * 7.13) - rad
    .worst_pco2_result) - rad.worst_pao2_result)
   ELSE
    pat_record->pat_data[d.seq].obs_value[indx].aado2 = - (1)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO rpt_params->output_device
  FROM (dummyt d  WITH seq = 1)
  HEAD PAGE
   col 0, dio_landscape, col 50,
   font110, row + 1, line = fillstring(370,"-"),
   count = 1, date_full_disp = "                                           ", date_full_disp = concat
   ("Report generated on: ",rpt_params->today," ",rpt_params->now),
   col 0, font110c, row + 1,
   y_pos = 20, x_pos = 0,
   CALL print(calcpos(15,y_pos)),
   date_full_disp,
   CALL print(calcpos(600,y_pos)), "By Module: dcp_aprt_33_ap2_phys_trend",
   CALL print(calcpos(360,y_pos)), "APACHE For ICU", row + 1,
   y_pos = (y_pos+ 10), col 0, font80c,
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(245,y_pos)),
   "APACHE II Physiology Trend (Daily Worst Values)", row + 1, col 0,
   font110c, row + 1, y_pos = (y_pos+ 15),
   len = size(rpt_params->date_type_range_disp,1), x_pos = (400 - (len * 2.55)),
   CALL print(calcpos(x_pos,y_pos)),
   rpt_params->date_type_range_disp, row + 1, y_pos = (y_pos+ 15),
   line = fillstring(300,"-"),
   CALL print(calcpos(15,y_pos)), line,
   row + 1, y_pos = (y_pos+ 15), len = size(rpt_params->org_name,1),
   x_pos = (400 - (len * 2.5)),
   CALL print(calcpos(x_pos,y_pos)), rpt_params->org_name,
   row + 1, y_pos = (y_pos+ 10), len = size(rpt_params->unit_disp,1),
   x_pos = (400 - (len * 2.5)),
   CALL print(calcpos(x_pos,y_pos)), rpt_params->unit_disp,
   y_pos = (y_pos+ 30), row + 1
  DETAIL
   FOR (i = 1 TO pat_record->cnt)
     unit_bed = fillstring(50," "), unit_bed = concat(pat_record->pat_data[i].unit), dob = format(
      pat_record->pat_data[i].dob,"mm-dd-yyyy ;;d"),
     age = format(pat_record->pat_data[i].age,"### years;l"), age_dob = trim(concat(age," / ",dob)),
     icu_disch_dt_disp = format(pat_record->pat_data[i].icu_disch_dt,"mm/dd/yyyy hh:mm;;d")
     IF (icu_disch_dt_disp="12/31/2100 00:00")
      icu_disch_dt_disp = "                "
     ENDIF
     icu_admit_dt_disp = format(pat_record->pat_data[i].icu_admit_dt,"mm/dd/yyyy hh:mm;;d"),
     hosp_disch_dt_disp = format(pat_record->pat_data[i].hosp_disch_dt,"mm/dd/yyyy hh:mm;;d"),
     hosp_adm_dt_disp = format(pat_record->pat_data[i].hosp_adm_dt,"mm/dd/yy hh:mm;;d"),
     curr_icu_day_disp = format(pat_record->pat_data[i].curr_icu_day,"###")
     IF ((pat_record->pat_data[i].icu_pred_los=- (1)))
      icu_pred_los_disp = "N/A"
     ELSE
      icu_pred_los_disp = format(pat_record->pat_data[i].icu_pred_los,"###.##;l")
     ENDIF
     CALL print(calcpos(30,y_pos)), "Unit/Room-Bed ID: ",
     CALL print(calcpos(140,y_pos)),
     unit_bed,
     CALL print(calcpos(300,y_pos)), "Body System: ",
     CALL print(calcpos(415,y_pos)), pat_record->pat_data[i].system,
     CALL print(calcpos(560,y_pos)),
     "Admit Source: ",
     CALL print(calcpos(700,y_pos)), pat_record->pat_data[i].admit_source,
     row + 1, y_pos = (y_pos+ 10),
     CALL print(calcpos(30,y_pos)),
     "Patient Name:",
     CALL print(calcpos(140,y_pos)), pat_record->pat_data[i].name,
     CALL print(calcpos(300,y_pos)), "ICU Discharge Date:",
     CALL print(calcpos(415,y_pos)),
     icu_disch_dt_disp,
     CALL print(calcpos(560,y_pos)), "Chronic Health:",
     CALL print(calcpos(700,y_pos)), pat_record->pat_data[i].chronic, row + 1,
     y_pos = (y_pos+ 10),
     CALL print(calcpos(30,y_pos)), "Patient ID:",
     CALL print(calcpos(140,y_pos)), pat_record->pat_data[i].mrn,
     CALL print(calcpos(300,y_pos)),
     "ICU Discharge Status:",
     CALL print(calcpos(415,y_pos)), pat_record->pat_data[i].icu_disch_stat,
     CALL print(calcpos(560,y_pos)), "Elective Surgery (Y/N):",
     CALL print(calcpos(700,y_pos)),
     pat_record->pat_data[i].elective_surg, row + 1, y_pos = (y_pos+ 10),
     CALL print(calcpos(30,y_pos)), "Age/DOB:",
     CALL print(calcpos(140,y_pos)),
     age_dob,
     CALL print(calcpos(300,y_pos)), "ICU Admit Date:",
     CALL print(calcpos(415,y_pos)), icu_admit_dt_disp,
     CALL print(calcpos(560,y_pos)),
     "Readmission (Y/N):",
     CALL print(calcpos(700,y_pos)), pat_record->pat_data[i].readmit,
     row + 1, y_pos = (y_pos+ 10),
     CALL print(calcpos(30,y_pos)),
     "Service:",
     CALL print(calcpos(140,y_pos)), pat_record->pat_data[i].service,
     CALL print(calcpos(300,y_pos)), pat_record->pat_data[i].act_or_curr_icu_day_label,
     CALL print(calcpos(415,y_pos)),
     curr_icu_day_disp,
     CALL print(calcpos(560,y_pos)), "Hospital Discharge Date:",
     CALL print(calcpos(700,y_pos)), hosp_disch_dt_disp, row + 1,
     y_pos = (y_pos+ 10),
     CALL print(calcpos(30,y_pos)), "Physician Name:",
     CALL print(calcpos(140,y_pos)), pat_record->pat_data[i].doc_name,
     CALL print(calcpos(300,y_pos)),
     "Predicted ICU LOS:",
     CALL print(calcpos(415,y_pos)), icu_pred_los_disp,
     CALL print(calcpos(560,y_pos)), "Hospital Discharge Status:",
     CALL print(calcpos(700,y_pos)),
     pat_record->pat_data[i].hosp_disch_stat, row + 1, y_pos = (y_pos+ 10),
     CALL print(calcpos(30,y_pos)), "ICU Admit Diagnosis:",
     CALL print(calcpos(140,y_pos)),
     pat_record->pat_data[i].diagnosis,
     CALL print(calcpos(300,y_pos)), pat_record->pat_data[i].day_n_label,
     CALL print(calcpos(415,y_pos)), pat_record->pat_data[i].day_n, row + 1,
     y_pos = (y_pos+ 10),
     CALL print(calcpos(30,y_pos)), "Hospital Admit Date:",
     CALL print(calcpos(140,y_pos)), hosp_adm_dt_disp,
     CALL print(calcpos(300,y_pos)),
     "Admit Category:",
     CALL print(calcpos(415,y_pos)), pat_record->pat_data[i].therapy,
     row + 2, y_pos = (y_pos+ 20), num_col_on_page = 10,
     loop_cnt = 1, start_indx = 1, obs_cnt = size(pat_record->pat_data[i].obs_value,5)
     IF (obs_cnt > num_col_on_page)
      IF (mod(obs_cnt,num_col_on_page) > 0)
       loop_cnt = ((obs_cnt/ num_col_on_page)+ 1)
      ELSE
       loop_cnt = (obs_cnt/ num_col_on_page)
      ENDIF
      col_max = num_col_on_page
     ELSE
      loop_cnt = 1, col_max = obs_cnt
     ENDIF
     FOR (y = 1 TO loop_cnt)
       CALL print(calcpos(30,y_pos)), "ICU Day", column = 120
       FOR (x = start_indx TO col_max)
         column = (column+ 60), icu_day = format(pat_record->pat_data[i].obs_value[x].icu_day,"###;l"
          ),
         CALL print(calcpos(column,y_pos)),
         icu_day
       ENDFOR
       row + 2, y_pos = (y_pos+ 20),
       CALL print(calcpos(30,y_pos)),
       "APS", column = 120
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].aps < 0))
          aps = "N/A"
         ELSE
          aps = format(pat_record->pat_data[i].obs_value[x].aps,"###;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), aps
       ENDFOR
       row + 1, y_pos = (y_pos+ 10),
       CALL print(calcpos(30,y_pos)),
       "APACHE II", column = 120
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].ap2 < 0))
          ap2 = "N/A"
         ELSE
          ap2 = format(pat_record->pat_data[i].obs_value[x].ap2,"###;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), ap2
       ENDFOR
       row + 1, y_pos = (y_pos+ 10),
       CALL print(calcpos(30,y_pos)),
       "APACHE Score", column = 120
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].ap3 < 0))
          ap3 = "N/A"
         ELSE
          ap3 = format(pat_record->pat_data[i].obs_value[x].ap3,"###;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), ap3
       ENDFOR
       row + 1, y_pos = (y_pos+ 10),
       CALL print(calcpos(30,y_pos)),
       "AP2 Temps", column = 120
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].temp=- (1.00)))
          temp = "N/A   "
         ELSE
          temp = format(pat_record->pat_data[i].obs_value[x].temp,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), temp
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(30,y_pos)), "AP2 MAP"
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].map=- (1.00)))
          map = "N/A   "
         ELSE
          map = format(pat_record->pat_data[i].obs_value[x].map,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), map
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(30,y_pos)), "Heart Rate"
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].heart_rate=- (1.00)))
          heart_rate = "N/A   "
         ELSE
          heart_rate = format(pat_record->pat_data[i].obs_value[x].heart_rate,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), heart_rate
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(30,y_pos)), "AP2 Vent"
       FOR (x = start_indx TO col_max)
         column = (column+ 60),
         CALL print(calcpos(column,y_pos)), pat_record->pat_data[i].obs_value[x].vent
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(30,y_pos)), "AP2 Resp Rate"
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].resp_rate=- (1.00)))
          resp_rate = "N/A   "
         ELSE
          resp_rate = format(pat_record->pat_data[i].obs_value[x].resp_rate,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), resp_rate
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(30,y_pos)), "AP2 Glascow C.S."
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].gcs=null))
          gcs = "N/A"
         ELSE
          gcs = format(pat_record->pat_data[i].obs_value[x].gcs,"###;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), gcs
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(40,y_pos)), "AP2 Eyes"
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].eyes=- (1)))
          eyes = "N/A"
         ELSE
          eyes = format(pat_record->pat_data[i].obs_value[x].eyes,"###;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), eyes
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(40,y_pos)), "AP2 Motor"
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].motor=- (1)))
          motor = "N/A"
         ELSE
          motor = format(pat_record->pat_data[i].obs_value[x].motor,"###;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), motor
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(40,y_pos)), "AP2 Verbal"
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].verbal=- (1)))
          verbal = "N/A"
         ELSE
          verbal = format(pat_record->pat_data[i].obs_value[x].verbal,"###;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), verbal
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(30,y_pos)), "AP2 WBC", wbc = "##########"
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].wbc=- (1.00)))
          wbc = "N/A   "
         ELSE
          wbc = format(pat_record->pat_data[i].obs_value[x].wbc,"####.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), wbc
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(30,y_pos)), "AP2 Hematocrit", hematocrit = "##########"
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].hematocrit=- (1.00)))
          hematocrit = "N/A   "
         ELSE
          hematocrit = format(pat_record->pat_data[i].obs_value[x].hematocrit,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), hematocrit
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(30,y_pos)), "AP2 Sodium", sodium = "##########"
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].sodium=- (1.00)))
          sodium = "N/A   "
         ELSE
          sodium = format(pat_record->pat_data[i].obs_value[x].sodium,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), sodium
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(30,y_pos)), "AP2 Creatinine", creatinine = "##########"
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].creatinine=- (1.00)))
          creatinine = "N/A   "
         ELSE
          creatinine = format(pat_record->pat_data[i].obs_value[x].creatinine,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), creatinine
       ENDFOR
       row + 1, y_pos = (y_pos+ 10),
       CALL print(calcpos(30,y_pos)),
       "AP2 Potassium", column = 120, potassium = "##########"
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].potassium=- (1.00)))
          potassium = "N/A   "
         ELSE
          potassium = format(pat_record->pat_data[i].obs_value[x].potassium,"####.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), potassium
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(30,y_pos)), "AP2 ABG", row + 1,
       y_pos = (y_pos+ 10),
       CALL print(calcpos(40,y_pos)), "AP2 Intub",
       intub = "###########"
       FOR (x = start_indx TO col_max)
         column = (column+ 60),
         CALL print(calcpos(column,y_pos)), pat_record->pat_data[i].obs_value[x].intub
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(40,y_pos)), "AP2 FiO2", fio2 = "##########",
       prev_fio2 = - (1)
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].fio2=- (1.00)))
          fio2 = "N/A   "
         ELSE
          fio2 = format(pat_record->pat_data[i].obs_value[x].fio2,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), fio2
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(40,y_pos)), "AP2 PaO2", pao2 = "##########",
       prev_pao2 = - (1)
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].pao2=- (1.00)))
          pao2 = "N/A   "
         ELSE
          pao2 = format(pat_record->pat_data[i].obs_value[x].pao2,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), pao2
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(40,y_pos)), "AP2 PaCO2", paco2 = "##########",
       prev_paco2 = - (1)
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].paco2=- (1.00)))
          paco2 = "N/A   "
         ELSE
          paco2 = format(pat_record->pat_data[i].obs_value[x].paco2,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), paco2
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(40,y_pos)), "AP2 PH", ph = "##########",
       prev_ph = - (1.00)
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].ph=- (1.00)))
          ph = "N/A   "
         ELSE
          ph = format(pat_record->pat_data[i].obs_value[x].ph,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), ph
       ENDFOR
       row + 1, y_pos = (y_pos+ 10), column = 120,
       CALL print(calcpos(40,y_pos)), "AP2 AaDO2", aado2 = "##########",
       prev_aado2 = - (1.00)
       FOR (x = start_indx TO col_max)
         column = (column+ 60)
         IF ((pat_record->pat_data[i].obs_value[x].aado2=- (1.00)))
          aado2 = "N/A   "
         ELSE
          aado2 = format(pat_record->pat_data[i].obs_value[x].aado2,"###.##;l")
         ENDIF
         CALL print(calcpos(column,y_pos)), aado2
       ENDFOR
       start_indx = x
       IF ((((x - 1)+ num_col_on_page) > obs_cnt))
        col_max = obs_cnt
       ELSE
        col_max = ((x - 1)+ num_col_on_page)
       ENDIF
       IF (y < loop_cnt)
        BREAK
       ENDIF
     ENDFOR
     IF ((i < pat_record->cnt))
      BREAK
     ENDIF
   ENDFOR
  FOOT PAGE
   CALL print(calcpos(30,530)), "N/A = Not Available", row + 1,
   curr_page = format(curpage,"###"), page_disp = concat("------  Page ",trim(curr_page),"  ------"),
   CALL print(calcpos(330,550)),
   page_disp
  WITH dio = postscript, maxcol = 9000, maxrow = 80
 ;end select
END GO
