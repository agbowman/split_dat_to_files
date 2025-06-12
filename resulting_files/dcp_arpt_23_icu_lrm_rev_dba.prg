CREATE PROGRAM dcp_arpt_23_icu_lrm_rev:dba
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
 RECORD units(
   1 cnt = i4
   1 tot_bed_count = i4
   1 unit[*]
     2 code = f8
     2 name = vc
     2 bed_count = i4
 )
 SELECT
  IF ((rpt_params->unit=- (1)))
   PLAN (rar
    WHERE rar.active_ind=1
     AND (rar.organization_id=rpt_params->org_id))
    JOIN (l
    WHERE l.organization_id=rar.organization_id
     AND l.icu_ind=1
     AND l.icu_ind=1)
    JOIN (l1
    WHERE ((l1.active_ind+ 0)=1)
     AND l1.parent_loc_cd=l.location_cd
     AND l1.root_loc_cd=0)
    JOIN (l2
    WHERE ((l2.active_ind+ 0)=1)
     AND l2.parent_loc_cd=l1.child_loc_cd
     AND l2.root_loc_cd=0)
  ELSE
   PLAN (rar
    WHERE rar.active_ind=1
     AND (rar.organization_id=rpt_params->org_id))
    JOIN (l
    WHERE l.organization_id=rar.organization_id
     AND (l.location_cd= $6)
     AND ((l.active_ind+ 0)=1)
     AND l.icu_ind=1)
    JOIN (l1
    WHERE ((l1.active_ind+ 0)=1)
     AND l1.parent_loc_cd=l.location_cd
     AND ((l1.root_loc_cd+ 0)=0))
    JOIN (l2
    WHERE ((l2.active_ind+ 0)=1)
     AND l2.parent_loc_cd=l1.child_loc_cd
     AND ((l2.root_loc_cd+ 0)=0))
  ENDIF
  INTO "nl:"
  FROM risk_adjustment_ref rar,
   location l,
   location_group l1,
   location_group l2
  ORDER BY rar.organization_id, l.location_cd
  HEAD REPORT
   unit_cnt = 0, tot_bed_cnt = 0, unit_bed_cnt = 0
  HEAD l.location_cd
   unit_cnt = (unit_cnt+ 1)
   IF (mod(unit_cnt,10)=1)
    stat = alterlist(units->unit,(unit_cnt+ 9))
   ENDIF
   units->unit[unit_cnt].code = l.location_cd, units->unit[unit_cnt].name = uar_get_code_display(l
    .location_cd), unit_bed_cnt = 0
  DETAIL
   tot_bed_cnt = (tot_bed_cnt+ 1), unit_bed_cnt = (unit_bed_cnt+ 1)
  FOOT  l.location_cd
   units->unit[unit_cnt].bed_count = unit_bed_cnt
  FOOT REPORT
   units->tot_bed_count = tot_bed_cnt, units->cnt = unit_cnt, stat = alterlist(units->unit,unit_cnt)
  WITH nocounter
 ;end select
 SET transfer_buffer_minutes = 1500
 RECORD risk_record(
   1 total_admit = i4
   1 total_readmit = i4
   1 risk[*]
     2 risk_id = f8
     2 icu_cd = f8
 )
 RECORD location_dt_tm(
   1 start_date = dq8
   1 end_date = dq8
 )
 SET admit_loc_in_clause = fillstring(5000," ")
 IF ((units->cnt > 0))
  SET admit_loc_in_clause = concat(" ra.admit_icu_cd in (",trim(cnvtstring(units->unit[1].code)))
  FOR (cnt = 2 TO units->cnt)
    SET admit_loc_in_clause = concat(trim(admit_loc_in_clause),",",trim(cnvtstring(units->unit[cnt].
       code)))
  ENDFOR
  SET admit_loc_in_clause = concat(trim(admit_loc_in_clause),")")
 ELSEIF ((units->cnt=0))
  SET admit_loc_in_clause = concat(trim(admit_loc_in_clause),"0=0")
 ENDIF
 SELECT
  IF ((rpt_params->date_type=4))
   PLAN (ra
    WHERE ra.icu_admit_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND ra.icu_disch_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND parser(admit_loc_in_clause)
     AND ((ra.active_ind+ 0)=1))
    JOIN (e
    WHERE ra.encntr_id=e.encntr_id
     AND ((e.disch_dt_tm+ 0) >= cnvtdatetime(rpt_params->beg_dt_tm))
     AND ((e.disch_dt_tm+ 0) <= cnvtdatetime(rpt_params->end_dt_tm))
     AND ((ra.active_ind+ 0)=1))
  ELSEIF ((rpt_params->date_type=1))
   PLAN (ra
    WHERE ra.icu_admit_dt_tm >= cnvtdatetime(rpt_params->beg_dt_tm)
     AND ra.icu_admit_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND parser(admit_loc_in_clause)
     AND ((ra.active_ind+ 0)=1))
    JOIN (e
    WHERE e.encntr_id=ra.encntr_id
     AND ((e.active_ind+ 0)=1))
  ELSEIF ((rpt_params->date_type=2))
   PLAN (ra
    WHERE ra.icu_admit_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND ra.icu_disch_dt_tm >= cnvtdatetime(rpt_params->beg_dt_tm)
     AND ra.icu_disch_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND parser(admit_loc_in_clause)
     AND ((ra.active_ind+ 0)=1))
    JOIN (e
    WHERE e.encntr_id=ra.encntr_id
     AND ((e.active_ind+ 0)=1))
  ELSE
   PLAN (ra
    WHERE ra.icu_admit_dt_tm >= cnvtdatetime(rpt_params->beg_dt_tm)
     AND ra.hosp_admit_dt_tm >= cnvtdatetime(rpt_params->beg_dt_tm)
     AND ra.hosp_admit_dt_tm <= cnvtdatetime(rpt_params->end_dt_tm)
     AND parser(admit_loc_in_clause)
     AND ((ra.active_ind+ 0)=1))
    JOIN (e
    WHERE ra.encntr_id=e.encntr_id
     AND ((ra.active_ind+ 0)=1))
  ENDIF
  INTO "nl:"
  FROM risk_adjustment ra,
   encounter e
  HEAD REPORT
   counter = 0
  DETAIL
   counter = (counter+ 1)
   IF (mod(counter,500)=1)
    stat = alterlist(risk_record->risk,(counter+ 499))
   ENDIF
   risk_record->risk[counter].risk_id = ra.risk_adjustment_id, risk_record->total_admit = (
   risk_record->total_admit+ 1), risk_record->risk[counter].icu_cd = ra.admit_icu_cd
   IF (ra.readmit_ind=1)
    risk_record->total_readmit = (risk_record->total_readmit+ 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(risk_record->risk,counter)
  WITH nocounter
 ;end select
 RECORD low_risk_monitor(
   1 cnt = i2
   1 data[*]
     2 last_name = vc
     2 person_id = f8
     2 encntr_id = f8
     2 risk_adjustment_id = f8
     2 mrn = vc
     2 doc_id = f8
     2 doc_srv = vc
     2 age = i4
     2 chi = vc
     2 admit_dx = vc
     2 icu_admit_dt = dq8
     2 hosp_outcome = f8
     2 risk_act_rx = f8
     2 admit_src = vc
     2 icu_los_act = f8
     2 icu_los_ntl = f8
     2 icu_los_5_ntl = f8
     2 icu_disch_stat = vc
     2 hosp_disch_stat = vc
 )
 RECORD pat_record(
   1 cnt = i2
   1 pat_data[*]
     2 r_risk_adjustment_id = f8
     2 e_encntr_id = f8
     2 r_person_id = f8
     2 ra_risk_adjustment_day_id = f8
     2 ra_cc_day = i4
     2 ra_outcome_status = i4
     2 r_icu_admit_dt_tm = dq8
     2 r_icu_disch_dt_tm = dq8
     2 r_hosp_admit_dt_tm = dq8
     2 r_hosp_disch_dt_tm = dq8
     2 e_name_last = vc
     2 r_admitdiagnosis = vc
     2 r_adm_doc_id = f8
     2 e_med_service_cd = vc
     2 r_age = i4
     2 r_chronic_health_none_ind = i2
     2 r_chronic_health_unavail_ind = i2
     2 r_cirrhosis_ind = i2
     2 r_copd_flag = i4
     2 r_copd_ind = i2
     2 r_diabetes_ind = i2
     2 r_dialysis_ind = i2
     2 r_hepaticfailure_ind = i2
     2 r_immunosuppression_ind = i2
     2 r_leukemia_ind = i2
     2 r_lymphoma_ind = i2
     2 r_metastaticcancer_ind = i2
     2 r_aids_ind = i2
     2 r_diedinhospital_ind = i2
     2 r_diedinicu_ind = i2
     2 r_readmit_ind = i2
 )
 SET deceased_cd = 0.0
 SET expired_cd = 0.0
 SET deceased_cd = meaning_code(19,"DECEASED")
 SET expired_cd = meaning_code(19,"EXPIRED")
 SET null_date = cnvtdatetime("31-DEC-2100 00:00:00")
 SET mrn_cd = meaning_code(319,"MRN")
 SET low_risk_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = risk_record->total_admit),
   risk_adjustment r,
   encounter e,
   risk_adjustment_day ra,
   person p
  PLAN (d)
   JOIN (r
   WHERE (r.risk_adjustment_id=risk_record->risk[d.seq].risk_id)
    AND r.active_ind=1)
   JOIN (ra
   WHERE ra.risk_adjustment_id=r.risk_adjustment_id
    AND ra.cc_day=1
    AND ra.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=r.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  ORDER BY p.name_last_key, p.name_first_key, r.icu_admit_dt_tm
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(pat_record->pat_data,cnt), pat_record->pat_data[cnt].
   r_risk_adjustment_id = r.risk_adjustment_id,
   pat_record->pat_data[cnt].e_encntr_id = e.encntr_id, pat_record->pat_data[cnt].
   ra_risk_adjustment_day_id = ra.risk_adjustment_day_id, pat_record->pat_data[cnt].ra_cc_day = ra
   .cc_day,
   pat_record->pat_data[cnt].ra_outcome_status = ra.outcome_status, pat_record->pat_data[cnt].
   r_icu_admit_dt_tm = r.icu_admit_dt_tm, pat_record->pat_data[cnt].r_icu_disch_dt_tm = r
   .icu_disch_dt_tm,
   pat_record->pat_data[cnt].r_hosp_admit_dt_tm = r.hosp_admit_dt_tm, pat_record->pat_data[cnt].
   r_hosp_disch_dt_tm = e.disch_dt_tm, pat_record->pat_data[cnt].e_name_last = p.name_last,
   pat_record->pat_data[cnt].r_admitdiagnosis = r.admit_diagnosis, pat_record->pat_data[cnt].
   r_adm_doc_id = r.adm_doc_id, pat_record->pat_data[cnt].e_med_service_cd = uar_get_code_display(r
    .med_service_cd),
   pat_record->pat_data[cnt].r_age = r.admit_age, pat_record->pat_data[cnt].r_chronic_health_none_ind
    = r.chronic_health_none_ind, pat_record->pat_data[cnt].r_chronic_health_unavail_ind = r
   .chronic_health_unavail_ind,
   pat_record->pat_data[cnt].r_cirrhosis_ind = r.cirrhosis_ind, pat_record->pat_data[cnt].r_copd_flag
    = r.copd_flag, pat_record->pat_data[cnt].r_copd_ind = r.copd_ind,
   pat_record->pat_data[cnt].r_diabetes_ind = r.diabetes_ind, pat_record->pat_data[cnt].
   r_dialysis_ind = r.dialysis_ind, pat_record->pat_data[cnt].r_hepaticfailure_ind = r
   .hepaticfailure_ind,
   pat_record->pat_data[cnt].r_immunosuppression_ind = r.immunosuppression_ind, pat_record->pat_data[
   cnt].r_leukemia_ind = r.leukemia_ind, pat_record->pat_data[cnt].r_lymphoma_ind = r.lymphoma_ind,
   pat_record->pat_data[cnt].r_metastaticcancer_ind = r.metastaticcancer_ind, pat_record->pat_data[
   cnt].r_aids_ind = r.aids_ind, pat_record->pat_data[cnt].r_person_id = r.person_id
   IF (r.diedinicu_ind=1)
    pat_record->pat_data[cnt].r_diedinhospital_ind = 1
   ELSE
    IF (e.disch_disposition_cd IN (deceased_cd, expired_cd))
     pat_record->pat_data[cnt].r_diedinhospital_ind = 1
    ELSE
     pat_record->pat_data[cnt].r_diedinhospital_ind = 0
    ENDIF
    IF (p.deceased_dt_tm > e.reg_dt_tm
     AND p.deceased_dt_tm <= e.disch_dt_tm)
     pat_record->pat_data[cnt].r_diedinhospital_ind = 1
    ENDIF
   ENDIF
   pat_record->pat_data[cnt].r_diedinicu_ind = r.diedinicu_ind, pat_record->pat_data[cnt].
   r_readmit_ind = r.readmit_ind
  FOOT REPORT
   pat_record->cnt = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  icu_los_act = datetimediff(pat_record->pat_data[d.seq].r_icu_disch_dt_tm,pat_record->pat_data[d.seq
   ].r_icu_admit_dt_tm,1)
  FROM (dummyt d  WITH seq = pat_record->cnt),
   risk_adjustment r,
   risk_adjustment_outcomes rao
  PLAN (d
   WHERE cnvtdatetime(pat_record->pat_data[d.seq].r_icu_disch_dt_tm) != cnvtdatetime(null_date))
   JOIN (r
   WHERE (r.risk_adjustment_id=pat_record->pat_data[d.seq].r_risk_adjustment_id)
    AND r.active_ind=1
    AND r.therapy_level=2)
   JOIN (rao
   WHERE (rao.risk_adjustment_day_id=pat_record->pat_data[d.seq].ra_risk_adjustment_day_id)
    AND rao.equation_name IN ("ACT_ICU_EVER", "NTL_HSP_DEATH", "NTL_ICU_LOS")
    AND rao.active_ind=1)
  HEAD REPORT
   cnt2 = 0
  HEAD r.risk_adjustment_id
   cnt2 = (cnt2+ 1), stat = alterlist(low_risk_monitor->data,cnt2), low_risk_monitor->data[cnt2].
   hosp_outcome = - (1),
   low_risk_monitor->data[cnt2].risk_act_rx = - (1), low_risk_monitor->data[cnt2].icu_los_ntl = - (1),
   low_risk_monitor->data[cnt2].icu_los_5_ntl = - (1),
   low_risk_monitor->data[cnt2].last_name = pat_record->pat_data[d.seq].e_name_last, low_risk_monitor
   ->data[cnt2].encntr_id = r.encntr_id, low_risk_monitor->data[cnt2].person_id = pat_record->
   pat_data[d.seq].r_person_id,
   low_risk_monitor->data[cnt2].risk_adjustment_id = r.risk_adjustment_id, low_risk_monitor->data[
   cnt2].doc_id = pat_record->pat_data[d.seq].r_adm_doc_id, low_risk_monitor->data[cnt2].doc_srv =
   pat_record->pat_data[d.seq].e_med_service_cd,
   low_risk_monitor->data[cnt2].age = pat_record->pat_data[d.seq].r_age, low_risk_monitor->data[cnt2]
   .admit_dx = pat_record->pat_data[d.seq].r_admitdiagnosis, low_risk_monitor->data[cnt2].
   icu_admit_dt = pat_record->pat_data[d.seq].r_icu_admit_dt_tm,
   low_risk_monitor->data[cnt2].admit_src = r.admit_source, low_risk_monitor->data[cnt2].icu_los_act
    = icu_los_act
   IF ((pat_record->pat_data[d.seq].r_diedinicu_ind=1))
    low_risk_monitor->data[cnt2].icu_disch_stat = "D"
   ELSE
    low_risk_monitor->data[cnt2].icu_disch_stat = "A"
   ENDIF
   IF ((pat_record->pat_data[d.seq].r_diedinhospital_ind=1))
    low_risk_monitor->data[cnt2].hosp_disch_stat = "D"
   ELSE
    low_risk_monitor->data[cnt2].hosp_disch_stat = "A"
   ENDIF
   IF ((pat_record->pat_data[d.seq].r_aids_ind=1))
    low_risk_monitor->data[cnt2].chi = "OTHERIMMUN"
   ELSEIF ((pat_record->pat_data[d.seq].r_hepaticfailure_ind=1))
    low_risk_monitor->data[cnt2].chi = "HEPFAILURE"
   ELSEIF ((pat_record->pat_data[d.seq].r_lymphoma_ind=1))
    low_risk_monitor->data[cnt2].chi = "LYMPHOMA"
   ELSEIF ((pat_record->pat_data[d.seq].r_metastaticcancer_ind=1))
    low_risk_monitor->data[cnt2].chi = "TUMOR/METS"
   ELSEIF ((pat_record->pat_data[d.seq].r_leukemia_ind=1))
    low_risk_monitor->data[cnt2].chi = "LEUK/MYEL"
   ELSEIF ((pat_record->pat_data[d.seq].r_immunosuppression_ind=1))
    low_risk_monitor->data[cnt2].chi = "IMMUNOSUP"
   ELSEIF ((pat_record->pat_data[d.seq].r_cirrhosis_ind=1))
    low_risk_monitor->data[cnt2].chi = "CIRRHOSIS"
   ELSEIF ((pat_record->pat_data[d.seq].r_copd_ind=1))
    IF ((pat_record->pat_data[d.seq].r_copd_flag=2))
     low_risk_monitor->data[cnt2].chi = "COPD_SEV"
    ELSEIF ((pat_record->pat_data[d.seq].r_copd_flag=1))
     low_risk_monitor->data[cnt2].chi = "COPD_MOD"
    ELSE
     low_risk_monitor->data[cnt2].chi = "COPD_NOLIM"
    ENDIF
   ELSEIF ((pat_record->pat_data[d.seq].r_diabetes_ind=1))
    low_risk_monitor->data[cnt2].chi = "DIABETES"
   ELSEIF ((pat_record->pat_data[d.seq].r_chronic_health_unavail_ind=1))
    low_risk_monitor->data[cnt2].chi = "UNAVAILABLE"
   ELSEIF ((pat_record->pat_data[d.seq].r_chronic_health_none_ind=1))
    low_risk_monitor->data[cnt2].chi = "NONE"
   ENDIF
  DETAIL
   IF (rao.equation_name="NTL_HSP_DEATH")
    low_risk_monitor->data[cnt2].hosp_outcome = (rao.outcome_value * 100)
   ENDIF
   IF (rao.equation_name="ACT_ICU_EVER")
    low_risk_monitor->data[cnt2].risk_act_rx = (rao.outcome_value * 100)
   ENDIF
   IF (rao.equation_name="NTL_ICU_LOS")
    low_risk_monitor->data[cnt2].icu_los_ntl = rao.outcome_value
   ENDIF
  FOOT REPORT
   low_risk_monitor->cnt = cnt2
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = low_risk_monitor->cnt),
   risk_adjustment r,
   risk_adjustment_day rad,
   risk_adjustment_outcomes rao
  PLAN (d)
   JOIN (r
   WHERE (r.risk_adjustment_id=low_risk_monitor->data[d.seq].risk_adjustment_id)
    AND r.active_ind=1
    AND r.therapy_level=2)
   JOIN (rad
   WHERE rad.risk_adjustment_id=r.risk_adjustment_id
    AND rad.cc_day=5
    AND rad.active_ind=1)
   JOIN (rao
   WHERE rao.risk_adjustment_day_id=rad.risk_adjustment_day_id
    AND rao.equation_name="NTL_ICU_LOS"
    AND rao.active_ind=1)
  DETAIL
   low_risk_monitor->data[d.seq].icu_los_5_ntl = rao.outcome_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = low_risk_monitor->cnt),
   encntr_alias ea
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_id=low_risk_monitor->data[d.seq].encntr_id)
    AND ea.encntr_id > 0.0
    AND ea.encntr_alias_type_cd=mrn_cd
    AND ea.active_ind=1)
  DETAIL
   low_risk_monitor->data[d.seq].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pat_record->cnt),
   risk_adjustment_outcomes rao
  PLAN (d)
   JOIN (rao
   WHERE (rao.risk_adjustment_day_id=pat_record->pat_data[d.seq].ra_risk_adjustment_day_id)
    AND rao.equation_name="NTL_1ST_TISS"
    AND rao.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
  FOOT REPORT
   low_risk_cnt = cnt
  WITH nocounter
 ;end select
 SELECT INTO rpt_params->output_device
  FROM (dummyt d  WITH seq = 1)
  HEAD PAGE
   col 0, dio_landscape, col 50,
   font110, row + 2, y_pos = 30,
   x_pos = 0, break_pos = 520, line = fillstring(370,"-"),
   count = 1, date_full_disp = fillstring(70," "), date_full_disp = concat("Report generated on: ",
    rpt_params->today," ",rpt_params->now),
   row + 1,
   CALL print(calcpos(15,y_pos)), date_full_disp,
   CALL print(calcpos(575,y_pos)), "By Module: dcp_arpt_23_icu_lrm_rev",
   CALL print(calcpos(362,y_pos)),
   "APACHE For ICU", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(365,y_pos)), "FOCUS Report", y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)), font80, row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(285,y_pos)), "ICU Admission Low Risk Monitor Review",
   row + 1,
   CALL print(calcpos(15,y_pos)), font110,
   row + 1, y_pos = (y_pos+ 15), len = size(rpt_params->date_type_range_disp,1),
   x_pos = (400 - (len * 2.25)),
   CALL print(calcpos(x_pos,y_pos)), rpt_params->date_type_range_disp,
   row + 1, y_pos = (y_pos+ 15), line = fillstring(150,"-"),
   CALL print(calcpos(180,y_pos)), line, row + 1,
   y_pos = (y_pos+ 15), len = size(rpt_params->org_name,1), x_pos = (400 - (len * 2.5)),
   CALL print(calcpos(x_pos,y_pos)), rpt_params->org_name, row + 1,
   y_pos = (y_pos+ 10), len = size(rpt_params->unit_disp,1), x_pos = (400 - (len * 2.5)),
   CALL print(calcpos(x_pos,y_pos)), rpt_params->unit_disp, y_pos = (y_pos+ 30),
   row + 1, line = fillstring(300,"-"),
   CALL print(calcpos(620,y_pos)),
   "ICU Length of Stay ", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(475,y_pos)), "% Risk of",
   CALL print(calcpos(675,y_pos)),
   "Pred",
   CALL print(calcpos(725,y_pos)), "Disch.",
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)),
   "Patient",
   CALL print(calcpos(80,y_pos)), "Patient",
   CALL print(calcpos(285,y_pos)), "Chronic",
   CALL print(calcpos(345,y_pos)),
   "ICU Admit",
   CALL print(calcpos(405,y_pos)), "ICU Admit",
   CALL print(calcpos(475,y_pos)), "Hospital",
   CALL print(calcpos(525,y_pos)),
   "% Risk of",
   CALL print(calcpos(650,y_pos)), "Pred",
   CALL print(calcpos(680,y_pos)), "Day5",
   CALL print(calcpos(730,y_pos)),
   "Status", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)), "Name",
   CALL print(calcpos(80,y_pos)),
   "ID",
   CALL print(calcpos(155,y_pos)), "Physician",
   CALL print(calcpos(220,y_pos)), "Service",
   CALL print(calcpos(260,y_pos)),
   "Age",
   CALL print(calcpos(285,y_pos)), "Health",
   CALL print(calcpos(345,y_pos)), "Diagnosis",
   CALL print(calcpos(410,y_pos)),
   "Date",
   CALL print(calcpos(475,y_pos)), "Death Ntl",
   CALL print(calcpos(527,y_pos)), "Act Rx",
   CALL print(calcpos(572,y_pos)),
   "Origin",
   CALL print(calcpos(620,y_pos)), "Act",
   CALL print(calcpos(650,y_pos)), "Ntl",
   CALL print(calcpos(680,y_pos)),
   "Ntl",
   CALL print(calcpos(715,y_pos)), "ICU",
   CALL print(calcpos(750,y_pos)), "Hosp", row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(10,y_pos)), line
  DETAIL
   FOR (x = 1 TO low_risk_monitor->cnt)
     row + 1, y_pos = (y_pos+ 10)
     IF (y_pos > break_pos
      AND (x < low_risk_monitor->cnt))
      BREAK
     ENDIF
     doc_id_disp = format(low_risk_monitor->data[x].doc_id,"###########;l"), age_disp = format(
      low_risk_monitor->data[x].age,"###;l"), icu_admit_dt_disp = format(low_risk_monitor->data[x].
      icu_admit_dt,"dd-mmm-yyyy ;;d")
     IF ((low_risk_monitor->data[x].hosp_outcome=- (1)))
      hosp_outcome_disp = " N/A  "
     ELSEIF ((low_risk_monitor->data[x].hosp_outcome <= 1))
      hosp_outcome_disp = " < 1%  "
     ELSEIF ((low_risk_monitor->data[x].hosp_outcome >= 99))
      hosp_outcome_disp = " >99% "
     ELSE
      hosp_outcome_disp = format(low_risk_monitor->data[x].hosp_outcome,"##.##%;r")
     ENDIF
     IF ((low_risk_monitor->data[x].risk_act_rx=- (1)))
      risk_act_rx_disp = " N/A  "
     ELSEIF ((low_risk_monitor->data[x].risk_act_rx < 1))
      risk_act_rx_disp = "< 1%  "
     ELSEIF ((low_risk_monitor->data[x].risk_act_rx > 99))
      risk_act_rx_disp = "> 99% "
     ELSE
      risk_act_rx_disp = format(low_risk_monitor->data[x].risk_act_rx,"##.##%;r")
     ENDIF
     icu_los_act = format(low_risk_monitor->data[x].icu_los_act,"###.#;r")
     IF ((low_risk_monitor->data[x].icu_los_ntl=- (1)))
      icu_los_ntl = " N/A "
     ELSE
      icu_los_ntl = format(low_risk_monitor->data[x].icu_los_ntl,"###.#;r")
     ENDIF
     IF ((low_risk_monitor->data[x].icu_los_5_ntl=- (1)))
      icu_los_5_ntl = " N/A "
     ELSE
      icu_los_5_ntl = format(low_risk_monitor->data[x].icu_los_5_ntl,"###.#;r")
     ENDIF
     srv = substring(1,6,low_risk_monitor->data[x].doc_srv),
     CALL print(calcpos(15,y_pos)), low_risk_monitor->data[x].last_name,
     CALL print(calcpos(80,y_pos)), low_risk_monitor->data[x].mrn,
     CALL print(calcpos(155,y_pos)),
     doc_id_disp,
     CALL print(calcpos(220,y_pos)), srv,
     CALL print(calcpos(260,y_pos)), age_disp,
     CALL print(calcpos(285,y_pos)),
     low_risk_monitor->data[x].chi,
     CALL print(calcpos(345,y_pos)), low_risk_monitor->data[x].admit_dx,
     CALL print(calcpos(405,y_pos)), icu_admit_dt_disp,
     CALL print(calcpos(475,y_pos)),
     hosp_outcome_disp,
     CALL print(calcpos(525,y_pos)), risk_act_rx_disp,
     CALL print(calcpos(565,y_pos)), low_risk_monitor->data[x].admit_src,
     CALL print(calcpos(620,y_pos)),
     icu_los_act,
     CALL print(calcpos(650,y_pos)), icu_los_ntl,
     CALL print(calcpos(680,y_pos)), icu_los_5_ntl,
     CALL print(calcpos(720,y_pos)),
     low_risk_monitor->data[x].icu_disch_stat,
     CALL print(calcpos(755,y_pos)), low_risk_monitor->data[x].hosp_disch_stat
   ENDFOR
   row + 3, y_pos = (y_pos+ 30)
   IF (((y_pos+ 30) > break_pos))
    BREAK
   ENDIF
   CALL print(calcpos(15,y_pos)), "Flagged patients..................:", surg_cnt = format(
    low_risk_monitor->cnt,"#######;l"),
   col + 1, surg_cnt, row + 1,
   y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)), "Total number of patients(see note):",
   pat_cnt = format(low_risk_cnt,"#######;l"), col + 1, pat_cnt,
   row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(25,y_pos)),
   "Note: Includes all ICU patients during this time period.", row + 1, y_pos = (y_pos+ 10),
   CALL print(calcpos(15,y_pos)), "Percentage........................:", flow_risk_cnt = 0.0,
   flow_risk_cnt = low_risk_cnt, pct_ratio = ((low_risk_monitor->cnt/ flow_risk_cnt) * 100), pct_disp
    = format(pct_ratio,"###.##%;l"),
   col + 1, pct_disp
  FOOT PAGE
   row + 1, curr_page = format(curpage,"###"), page_disp = concat("------  Page ",trim(curr_page),
    "  ------"),
   CALL print(calcpos(350,540)), page_disp
  WITH dio = postscript, maxcol = 900, maxrow = 80
 ;end select
END GO
